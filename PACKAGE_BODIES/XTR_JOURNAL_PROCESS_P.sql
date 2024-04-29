--------------------------------------------------------
--  DDL for Package Body XTR_JOURNAL_PROCESS_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_JOURNAL_PROCESS_P" as
/* $Header: xtrjrnlb.pls 120.30 2006/10/27 11:11:29 eaggarwa ship $ */
----------------------------------------------------------------------------------------------------------------
/* Impotant Notes
  The insert of the revaluation row (In procedure CALC_REVAL_PROCESS) is
  not being currently called from NEW_TRANSFER_TO_GL until we clear up
  how / what we are revaluing and if we should be creating Journals for each G/L contra
  agst REVAL G/L (all flagged ready for reversal) - should we only be reval g/ls after closeout
  to the Balance Sheet (ie only Asset / Liab A/c's should be revalued)
*/

--------------------------------------------------------------------------------------------------------------------------

debug_flag  varchar2(1) := 'F';

/* ---------------------------------------------------------------------
|  PRIVATE FUNCTION							|
|	GET_IG_CCID							|
|									|
|  DESCRIPTION								|
|	Private function to obtain principal or interest ccid for a IG	|
|	transaction from the xtr_ig_journal_structures table.		|
|									|
|  CALLED BY								|
|	Gen_Journals							|
|									|
|  PARAMETERS								|
|	in_prin_flag		get principal ccid flag.		|
|	in_int_flag		get interest ccid flag.	 		|
|	in_company_code		company code.            		|
|	in_cpty			counter party code.			|
|	in_curr			deal and cpty's bank account currency.	|
|	in_bank_acct_no		counter party's bank account number.	|
|									|
|  HISTORY								|
|       02/19/02	eklau	Created.				|
 --------------------------------------------------------------------- */



FUNCTION GET_IG_CCID (
 		in_prin_flag	in varchar2,
 		in_int_flag	in varchar2,
 		in_company_code	in varchar2,
 		in_cpty		in varchar2,
 		in_curr		in varchar2,
 		in_bank_acct_no	in varchar2)  RETURN NUMBER IS

 l_ccid	number(15) := null;

 Begin
    Select decode(nvl(in_prin_flag,'N'),
                      'Y', principal_gl,
                      (decode(nvl(in_int_flag,'N'), 'Y', interest_gl, NULL)))
           into l_ccid
    From   xtr_ig_journal_structures
    Where  company_code	= in_company_code
      and  cparty_code	= in_cpty
      and  cp_currency	= in_curr
      and  cp_acct_no	= in_bank_acct_no;

    Return (l_ccid);
    /* exception added by Ilavenil to fix bug # 2293339 issue 9 */
 Exception
    When others then
    Return null;
 End GET_IG_CCID;


/* -----------------------------------------------------------------------------
|  PUBLIC FUNCTION								|
|	GET_CLOSED_PERIOD_PARAM							|
|										|
|  DESCRIPTION									|
|	This function will return the company parameter setting for posting 	|
|	journal batches to closed GL periods.					|
|  CALLED BY									|
|	Procedure Journals.							|
|	Form XTRACJNL.								|
|  PARAMETERS									|
|	in_company_		company code.		(input, required)	|
|  HISTORY									|
|	06/21/2002	eklau	Created						|
 ----------------------------------------------------------------------------- */

FUNCTION GET_CLOSED_PERIOD_PARAM (in_company in varchar2) RETURN VARCHAR2 IS

l_param_value	XTR_COMPANY_PARAMETERS.parameter_value_code%TYPE := NULL;

Begin
   Select parameter_value_code into l_param_value
     from xtr_company_parameters
     where company_code = in_company
       and parameter_code = 'ACCNT_CLPER';

    Return (l_param_value);
Exception
    When others then
	FND_MESSAGE.Set_Name ('XTR','XTR_NO_CLOSE_PER_PARAM');
	FND_MESSAGE.Set_Token ('COMPANY_CODE', in_company);
	FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
	Return null;
End GET_CLOSED_PERIOD_PARAM;



/* --------------------------------------------------------------------- --------
|  PUBLIC PROCEDURE								|
|	Do_Journal_Process							|
|										|
|  DESCRIPTION									|
|	This procedure generate the G/L entries for a single or all		|
|	companies the user has access to for transactions up to the		|
|	cutoff date.								|
|  CALLED BY									|
|	Concurrent program submission manager.					|
|  PARAMETERS									|
|	errbuf						(out)			|
|	retcode						(out)			|
|	p_source_option		NRA/RA related batch	(in, optional)		|
|		'J' - Non-Reval/Non-Accrual related				|
|		null - Reval/Accrual related					|
|	p_company_code		company code.		(in, required)		|
|	p_batch_id_from		batch id low value	(in, dependant)		|
|	p_batch_id_to		batch id high value	(in, dependant)		|
|	p_cutoff_date		date.			(in, dependant)		|
|
|  HISTORY									|
|	12/16/98	eklau	Created						|
|       01/21/99	eklau	(1) Change source of suspense GL acct		|
|				from gl_reference to party_info table.		|
|				(2) Added a 'suspense_gl' column to the		|
|				journals table and populate it with 'Y'		|
|				if the company's suspense account was		|
|				used to create the journal entry.		|
|       04/29/99	eklau	(1) Removed acct period from parameters.	|
|				Generation process will now work off a		|
|				cutoff date, only DDA rows marked as not	|
|				having jrnls generated (journal_created		|
|				= 'N') on or before the	cutoff date		|
|				will be processed.				|
|				(2) Removed procedure REVERSE_JOURNALS		|
|				from pkg.  Journals are now updated on		|
|				a real-time basis from DB trigger call		|
|				to the procedure UPDATE_JOURNALS, when		|
|				a deal is cancelled.				|
|	05/24/99	eklau	(1) Added p_dummy_date parameter for		|
gen_journals|				use by concurrent prg validation only.		|
|       03/12/01        jhung (1) Add p_period_end,p_batch_id_from,     	|
|                                 p_batch_id_to, remove p_cutoff_date   	|
|                                 parameter for introduction of batch_id	|
|                                 concept.                              	|
 ----------------------------------------------------------------------------- */
PROCEDURE Do_Journal_Process
		(errbuf			OUT NOCOPY VARCHAR2,
		 retcode		OUT NOCOPY NUMBER,
		 p_source_option	IN  VARCHAR2,
		 p_company_code		IN  VARCHAR2,
		 p_batch_id_from     	IN  NUMBER,
		 p_batch_id_to		IN  NUMBER,
		 p_cutoff_date		IN  DATE)	IS
--
  p_curr_batch_id	XTR_BATCHES.BATCH_ID%TYPE;
  p_upgrade_batch	XTR_BATCHES.UPGRADE_BATCH%TYPE;
  p_period_start	DATE;
  p_period_end		DATE;


	CURSOR BATCH_SEQ is
		Select batch_id
		From XTR_BATCHES
		Where company_code = p_company_code
		and   batch_type is null
		and   batch_id between nvl(p_batch_id_from, batch_id) and nvl(p_batch_id_to, batch_id)
	        Order by batch_id asc;

	CURSOR BATCH_PERIOD is
		Select period_start, period_end, upgrade_batch
		From XTR_BATCHES
		Where batch_id = p_curr_batch_id;

	CURSOR FIND_USER (fnd_user_id in number) is
		select dealer_code
		from xtr_dealer_codes_v
		where user_id = fnd_user_id;
--
	CURSOR GET_SOB_INFO is
		select set_of_books_id
		from   xtr_parties_v
		where  party_type = 'C'
		and    party_code = p_company_code;
--
	CURSOR GET_SUSPENSE_CCID is
		select parameter_value_code   -- replaced a.suspense_ccid
		from   xtr_parties_v a,
                       xtr_company_parameters b
		where  a.party_code     = p_company_code
                and    a.party_code     = b.company_code
                and    b.parameter_code = 'ACCNT_SUSAC';
--
	CURSOR FIND_PRE_BATCH is     -- Find the previous Non-Reval/Non-Accrual related Batch ID
                select pre.batch_id
                from XTR_BATCHES PRE,
                     XTR_BATCHES CUR
                where cur.company_code = p_company_code
		and cur.batch_id = p_curr_batch_id
                and pre.company_code = cur.company_code
                and cur.period_start = (pre.period_end + 1)
		and pre.upgrade_batch <> 'Y'
		and pre.batch_type is null;

	l_pre_batch_id    XTR_BATCHES.BATCH_ID%TYPE;

	CURSOR CHK_EARLY_BATCH is    -- chck if the early batch id been generated journal
		select 1
		from XTR_BATCH_EVENTS
		where batch_id = l_pre_batch_id
		and EVENT_CODE = 'JRNLGN';
--
	CURSOR CHK_ACCRLS_AUTH is     -- check if the batch id has been authorized from accruals
		select 1
		from XTR_BATCH_EVENTS
		where batch_id = p_curr_batch_id
		and event_code = 'ACCRUAL'
		and authorized = 'Y';
--
        CURSOR CHK_JOURNAL_GEN is     -- check if the batch id has been generated in journals
		select 1
		from XTR_BATCH_EVENTS
		where batch_id = p_curr_batch_id
		and event_code = 'JRNLGN';

	fnd_user_id	number;
	pg_fp		utl_file.file_type;
	l_temp		NUMBER;
	ex_early_batch	EXCEPTION;
	ex_accrls_auth  EXCEPTION;
	ex_journal_gen	EXCEPTION;

   -- Added for flex journals.  2404342.  Creation of a new journal only batch.

   Cursor GEN_BATCH is
   Select XTR_BATCHES_S.NEXTVAL
    from  DUAL;

   l_retcode		NUMBER := 0;
   l_warn_flag		BOOLEAN;
   l_sub_retcode	NUMBER := 0;	-- Added for 1336492.

BEGIN

--	xtr_debug_pkg.enable_file_debug; -- RV 2293339 issue# 8
	IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	   xtr_debug_pkg.debug ('Do_Journal_Process: ' || '>> Do Journal Process.');
	END IF;

   If (p_source_option is null) then

      -- Process Reval/Accrual related batches.  Range of bid should be provided.
      -- If no range of batch id, all authorized accrual batches are to be processed.

      Open BATCH_SEQ;    -- Generate Journal. Start from smallest ID.
      Fetch BATCH_SEQ into p_curr_batch_id;
      While BATCH_SEQ%FOUND LOOP

         -- Added for flex journals.  2404342.  ekl
         -- Issue info message at beginning of each batch being processed.

         FND_MESSAGE.Set_Name ('XTR','XTR_START_GEN_BID');
         FND_MESSAGE.Set_Token ('BID', p_curr_batch_id);
         FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);

         -- End addition for 2404342.

         Open BATCH_PERIOD;
         Fetch BATCH_PERIOD into p_period_start, p_period_end, p_upgrade_batch;
         Close BATCH_PERIOD;

         IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
            xtr_debug_pkg.debug('Do_Journal_Process: ' || 'p_company_code = ' || p_company_code);
	    xtr_debug_pkg.debug('Do_Journal_Process: ' || 'p_curr_batch_id = ' || p_curr_batch_id);
            xtr_debug_pkg.debug('Do_Journal_Process: ' || 'p_period_start = ' || p_period_start);
            xtr_debug_pkg.debug('Do_Journal_Process: ' || 'p_period_end = ' || p_period_end);
         END IF;

	 -- Issue warning if journals have already been generated for the current batch id.
	 -- Proceed to next batch id in range.

	 Open CHK_JOURNAL_GEN;
	 Fetch CHK_JOURNAL_GEN into l_temp;
	 If CHK_JOURNAL_GEN%FOUND then
            Close CHK_JOURNAL_GEN;
            FND_MESSAGE.Set_Name('XTR', 'XTR_JOURNAL_GEN');
            FND_MESSAGE.Set_Token('BATCH', p_curr_batch_id);
            FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
            l_retcode := greatest(l_retcode,1);
            l_warn_flag := TRUE;
	 Else
            Close CHK_JOURNAL_GEN;
            l_warn_flag := FALSE;
	 End if;

         -- Added condition for flex jrnls.  2404342.  ekl
         -- With this logic, if a previously processed RA batch was encountered,
         -- a warning would be issued and processing can continue with the next
         -- batch ID in the given range.

         If (NOT l_warn_flag) then

            -- Raise error if the previous batch id has not generated journal
            Open FIND_PRE_BATCH;
            Fetch FIND_PRE_BATCH into l_pre_batch_id;
            If FIND_PRE_BATCH%FOUND then
               Open CHK_EARLY_BATCH;
               Fetch CHK_EARLY_BATCH into l_temp;
               If CHK_EARLY_BATCH%NOTFOUND then
	          Close CHK_EARLY_BATCH;
                  Raise ex_early_batch;
               Else
                  Close CHK_EARLY_BATCH;
               End if;
            End If;
            Close FIND_PRE_BATCH;

            -- Raise error if the current batch is not authorized from Accruals
            Open CHK_ACCRLS_AUTH;
            Fetch CHK_ACCRLS_AUTH into l_temp;
            If CHK_ACCRLS_AUTH%NOTFOUND then
               CLOSE CHK_ACCRLS_AUTH;
               Raise ex_accrls_auth;
            Else
               CLOSE CHK_ACCRLS_AUTH;
            End if;

            G_company_code := p_company_code;
            G_batch_id     := p_curr_batch_id;
            G_period_end   := p_period_end;
            --
            -- Set the dealer code
            --
            fnd_user_id := FND_GLOBAL.USER_ID;
            Open FIND_USER(fnd_user_id);
            Fetch FIND_USER into G_user;
            Close FIND_USER;

            IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
               xtr_debug_pkg.debug ('Do_Journal_Process: ' || 'FND_GLOBAL.user_id = ' || to_char(fnd_user_id));
            END IF;
            --
            --  Set sob info.
            --
            Open GET_SOB_INFO;
            Fetch GET_SOB_INFO into G_set_of_books_id;
            Close GET_SOB_INFO;

            Open GET_SUSPENSE_CCID;
            Fetch GET_SUSPENSE_CCID into G_suspense_ccid;
            Close GET_SUSPENSE_CCID;

            -- Begin 1336492 additions.
            -- Modified returned value type and meaning of Procedure Gen_Journals
            -- in order to handle warning status in addition to successful and error.

            l_sub_retcode := Gen_Journals(p_source_option, G_company_code, G_batch_id, G_period_end, p_upgrade_batch);
            l_retcode := greatest(l_retcode,l_sub_retcode);

            -- End 1336492 additions.

/* replaced by code above for 1336492.
            If (NOT Gen_Journals(p_source_option, G_company_code, G_batch_id, G_period_end, p_upgrade_batch)) then
	       l_retcode := greatest(l_retcode,2);
            --bug 2804548
            else
	       l_retcode := greatest(l_retcode,g_gen_journal_retcode);
            End If;
*/
            IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
               xtr_debug_pkg.debug ('Do_Journal_Process: ' || '<< Do Journal Process.');
            END IF;
--	    xtr_debug_pkg.disable_file_debug; -- RV 2293339 issue# 8

         End If; 	-- (NOT l_warn_flag)

         -- Added for flex journals.  2404342.  ekl
         -- Issue info message at end of each batch being processed.

         FND_MESSAGE.Set_Name ('XTR','XTR_END_GEN_BID');
         FND_MESSAGE.Set_Token ('BID', p_curr_batch_id);
         FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);

         -- End addition for 2404342.

         Fetch BATCH_SEQ into p_curr_batch_id;
      END LOOP;
      Close BATCH_SEQ;

   Elsif (p_source_option = 'J') then

      -- Process Non-Reval/Non-Accrual related journals.
      -- Will need to create a new journal only batch.

      Open  GEN_BATCH;
      Fetch GEN_BATCH into p_curr_batch_id;
      Close GEN_BATCH;

      -- Insert new row to XTR_BATCH when new batch process staring from accrual

      Insert into XTR_BATCHES(batch_id, company_code, period_start, period_end,
                              gl_group_id, upgrade_batch, created_by, creation_date,
                              last_updated_by, last_update_date, last_update_login, batch_type)
                      values (p_curr_batch_id, p_company_code, p_cutoff_date, p_cutoff_date,
                              null, 'N', fnd_global.user_id, sysdate,
                              fnd_global.user_id, sysdate, fnd_global.login_id, 'J');

      G_company_code := p_company_code;
      G_batch_id     := p_curr_batch_id;
      G_period_end   := p_cutoff_date;

      --
      -- Set the dealer code
      --
      fnd_user_id := FND_GLOBAL.USER_ID;
      Open FIND_USER(fnd_user_id);
      Fetch FIND_USER into G_user;
      Close FIND_USER;

      IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
         xtr_debug_pkg.debug ('Do_Journal_Process: ' || 'FND_GLOBAL.user_id = ' || to_char(fnd_user_id));
      END IF;
      --
      --  Set sob info.
      --
      Open GET_SOB_INFO;
      Fetch GET_SOB_INFO into G_set_of_books_id;
      Close GET_SOB_INFO;

      Open GET_SUSPENSE_CCID;
      Fetch GET_SUSPENSE_CCID into G_suspense_ccid;
      Close GET_SUSPENSE_CCID;

      -- Begin 1336492 additions.
      -- Modified returned value type and meaning of Procedure Gen_Journals
      -- in order to handle warning status in addition to successful and error.

      l_sub_retcode := Gen_Journals(p_source_option, G_company_code, G_batch_id, G_period_end, p_upgrade_batch);
      l_retcode := greatest(l_retcode,l_sub_retcode);

      -- End 1336492 additions.

/* replaced by code above for 1336492.

      If (NOT Gen_Journals(p_source_option, G_company_code, G_batch_id, G_period_end, 'N')) then
         l_retcode := greatest(l_retcode,2);
      --bug 2804548
      else
	 l_retcode := greatest(l_retcode,g_gen_journal_retcode);
      End If;
*/
   End If;

   retcode := l_retcode;

EXCEPTION
   when ex_journal_gen then
	FND_MESSAGE.Set_Name('XTR', 'XTR_JOURNAL_GEN');
	FND_MESSAGE.Set_Token('BATCH', p_curr_batch_id);
        FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
	retcode := greatest(l_retcode,2);
--	APP_EXCEPTION.Raise_exception;		-- Removed for 2404342.  Interferring with new wrapper procedure JOURNALS' put_line.
   when ex_accrls_auth then
	FND_MESSAGE.Set_Name('XTR', 'XTR_ACCRLS_AUTH');
	FND_MESSAGE.Set_Token('BATCH', p_curr_batch_id);
        FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
	retcode := greatest(l_retcode,2);
--	APP_EXCEPTION.Raise_exception;		-- Removed for 2404342.  Interferring with new wrapper procedure JOURNALS' put_line.
   when ex_early_batch then
	FND_MESSAGE.Set_Name('XTR', 'XTR_EARLY_BATCH');
	FND_MESSAGE.Set_Token('PRE_BATCH', l_pre_batch_id);
	FND_MESSAGE.Set_Token('CUR_BATCH', p_curr_batch_id);
        FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
	retcode := greatest(l_retcode,2);
--	APP_EXCEPTION.Raise_exception;		-- Removed for 2404342.  Interferring with new wrapper procedure JOURNALS' put_line.
END Do_Journal_Process;

------------------------------------------------------------------------------------

/* ---------------------------------------------------------------------
|  PUBLIC FUNCTION							|
|	Gen_Journals							|
|									|
|  DESCRIPTION								|
|	Function which generates journal entries for the given batch id.|
|	The batch can either be Reval/Accrual related or Non-Reval/	|
|	Accrual related, as specified by the parameter in_source_option.|
|	NOTE: An upgrade batch can only be a Reval/Accrual related	|
|	      batch.							|
|  CALLED BY								|
|	Procedure DO_JOURNAL_PROCESS.					|
|  PARAMETERS								|
|	in_source_option	NRA/RA related batch	(in, optional)	|
|		'J' - Non-Reval/Non-Accrual related			|
|		null - Reval/Accrual related				|
|	in_company		company code.		(required)	|
|	in_batch_id		batch id.		(required)	|
|	in_period_end		date.			(required)	|
|	in_upgrade_batch	Y/N flag.		(required)	|
|  HISTORY								|
|       04/29/99	eklau	(1) Changed update of JOURNAL_CREATED	|
|				in DDA from end of processing for the	|
|				amount date to upon change in deal_type	|
|				deal_number, transaction_number,	|
|				date_type, and amount_date for non 'EXP'|
|				deals.  For 'EXP' deals, it's upon chg	|
|				of deal number.				|
|				(2) Consolidated cursors Q2 and Q4.  Q4	|
|				originally processed 'CA' and 'IG' deals|
|				and Q2 all deals except the above and	|
|				'EXP'.					|
|				(3) Changed Q3 - EXP to be driven off	|
|				of the DDA table instead of the exposure|
|				transactions table.			|
|				(4) Q5 removed due to change in how we	|
|				post INTSET to DDA.  Should now be	|
|				handled by Q2.				|
|	05/26/99	eklau	(1) Added logic to calculate accounted	|
|				amounts.				|
|	08/13/99	eklau	(1) Added cursors Q4 and Q5 to handle	|
|				accruals and revaluations, respectively.|
|	02/19/02	eklau	Changed procedure to accomodate new	|
|				xtr_ig_journal_structure table for	|
|				re-arch of IG journaling in order to	|
|				achieve the new company to company IG	|
|				feature for patchset G.			|
 --------------------------------------------------------------------- */

FUNCTION GEN_JOURNALS
		(in_source_option	IN VARCHAR2,
		 in_company		IN VARCHAR2,
		 in_batch_id		IN NUMBER,
		 in_period_end		IN DATE,
                 in_upgrade_batch       IN VARCHAR2) RETURN NUMBER is
 --
 l_accounted_cr            NUMBER;
 l_accounted_dr            NUMBER;
 l_action_code             VARCHAR2(7);
 l_amount_date             DATE;
 l_amount_type             VARCHAR2(7);
 l_batch_id                NUMBER;
 l_bkr_client              VARCHAR2(1);
 l_bnk_ccid                NUMBER(15);
 l_ccid		           NUMBER(15);
 l_ccy                     VARCHAR2(15);
 l_trans_ccy		   VARCHAR2(15);
 l_company                 VARCHAR2(7);
 l_company1                VARCHAR2(7);
 l_credit_amt              NUMBER;
 l_date_type               VARCHAR2(7);
 l_deal_nos                NUMBER;
 l_deal_subtype            VARCHAR2(7);
 l_deal_type               VARCHAR2(7);
 l_debit_amt               NUMBER;
 l_dr_or_cr                VARCHAR2(2);
-- l_error_flag              VARCHAR2(1) := 'N';	-- removed for 1336492.
 l_event_id                NUMBER;
 l_portfolio               VARCHAR2(7);
 l_prev_amount_date        DATE;
 l_prev_date_type          VARCHAR2(7);
 l_prev_deal_nbr           NUMBER;
 l_prev_deal_type          VARCHAR2(7);
 l_prev_rowid              ROWID;
 l_prev_transaction_nbr    NUMBER;
 l_prod_ty                 VARCHAR2(10);
 l_pty_convert_type        VARCHAR2(30);
 l_pty_user_convert_type   VARCHAR2(30);
 l_reval_amt               NUMBER;
 l_row_id                  rowid;
 l_sob_currency            VARCHAR2(15);
 l_suspense_gl             VARCHAR2(1);
 l_sysdate                 DATE :=trunc(sysdate);
 l_tmp_amt                 NUMBER;
 l_transaction_nos         NUMBER;
 l_upgrade_reval           VARCHAR2(1) := 'N';
 l_q6_deal_no		   NUMBER;
 l_UNREAL		   BOOLEAN;
 l_CCYUNRL		   BOOLEAN;
 l_REAL			   BOOLEAN;
 l_CCYREAL		   BOOLEAN;
 l_EFF_EXIST		   BOOLEAN;
 l_create_journal          VARCHAR2(1);


 -- 4641750
 l_debit_amount number;
 l_credit_amount number;
 l_curr varchar2(7);
 l_curr_sell varchar2(7);
 l_curr_buy varchar2(7);

-- 4641750


  -- Bug 3805480 begin
 l_empty	number := 0;

 Cursor Entries (bid number) is
 Select 1
   from dual
  where exists (select null
                  from xtr_journals
                 where batch_id = bid);
 -- Bug 3805480 end

 Cursor EVENT_ID is
 Select XTR_BATCH_EVENTS_S.NEXTVAL
 From   DUAL;

 --------------------------------------------------------------------------------
 -- NOTE: Q2 will select all deal types except 'EXP' for journal generation.
 --       Tables e (DDA) and f (JEA) are the driving tables, with table a (JEA)
 --       linking back to itself on the same row as table f (JEA).
 -- Deals
 --------------------------------------------------------------------------------
 Cursor Q2 is
  select
   e.company_code						company_code
  ,c.deal_number						deal_number
  ,c.currency							currency
  ,a.deal_type							deal_type
  ,a.deal_subtype						deal_subtype
  ,nvl(a.product_type,'NOT APPLIC')				product_type
  ,a.portfolio_code						portfolio_code
  ,c.amount_type						amount_type
  ,decode(a.credit_or_debit,'DR',nvl(c.amount,0),0)		dr_amount
  ,decode(a.credit_or_debit,'CR',nvl(c.amount,0),0)		cr_amount
  ,c.transaction_number						transaction_number
  ,decode(a.get_gl_from_deal,
           'Y', g.code_combination_id,
                a.code_combination_id)				ccid
  ,c.client_broker_clracct					client_broker_clracct
  ,e.date_type							date_type
  ,e.amount_date                                 		amount_date    --  Reverted Back to amount_date Bug 5235988
  ,c.settlement_number						settlement_number
  ,a.get_prin_ccid_from_deal					use_prin_ccid_flag
  ,a.get_int_ccid_from_deal					use_int_ccid_flag
  ,c.cparty_account_no						cparty_account_no
  ,e.cparty_code						cparty_code
  ,a.action_code						action_code
  ,decode(a.deal_type,'CA','-1',c.dual_authorisation_by)	validated_by	-- Added for 1336492.
  ,c.account_no							co_account_no	-- Added for 1336492.
  from XTR_JOURNAL_ENTRY_ACTIONS a,
        XTR_DEAL_DATE_AMOUNTS     c,
        XTR_DEAL_DATE_AMOUNTS     e, 			-- To generate Journal for Bank Acct
        XTR_JOURNAL_ENTRY_ACTIONS f,			--  "     "      "     "    "   "
        XTR_BANK_ACCOUNTS         g
   where e.company_code       = in_company
   and   e.batch_id is null
   and   e.amount_date       <= in_period_end    -- Reverted Back to amount_date Bug 5235988
   and   e.deal_type NOT IN ('EXP')
   and   ((e.deal_type = 'BOND' and e.status_code not in ('CLOSED','CANCELLED')) or
          (e.deal_type <> 'BOND' and e.status_code <> 'CANCELLED'))
   and   f.company_code       = e.company_code
   and   f.deal_type          = e.deal_type
   and   f.deal_subtype       = e.deal_subtype
   and   f.product_type       = nvl(e.product_type,'NOT APPLIC')
   and   f.portfolio_code     = nvl(e.portfolio_code,'NOTAPPL')
   and   f.date_type          = e.date_type
   and   e.amount_date between nvl(f.effective_from, ADD_MONTHS(sysdate,-240)) and nvl(f.effective_to, sysdate)   -- flex journals--  Reverted Back to amount_date Bug 5235988
   and   e.date_type         <> 'REVAL'   -- jhung   3/14
   and   c.company_code       = e.company_code
   and   c.deal_number        = e.deal_number
   and   c.transaction_number = e.transaction_number
   and   c.amount            <> 0.00		-- 1336492
   and   ((e.deal_type = 'BOND' and c.status_code not in ('CLOSED','CANCELLED')) or
          (e.deal_type <> 'BOND' and c.status_code <> 'CANCELLED'))			-- Bug 3359347.
   and   a.company_code       = c.company_code
   and   a.deal_type          = c.deal_type
   and   a.deal_subtype       = c.deal_subtype
   and   a.product_type       = nvl(c.product_type,'NOT APPLIC')
   and   a.portfolio_code     = nvl(c.portfolio_code,'NOTAPPL')
   and   a.amount_type        = c.amount_type
   and   nvl(a.action_code,'x') = nvl(c.action_code,'x')
   and   a.rowid              = f.rowid
   and   g.party_code(+)      = c.company_code
   and   g.account_number(+)  = c.account_no
   and   g.currency(+)        = c.currency
   and   e.company_code IN (SELECT xca.party_code
                           FROM XTR_COMPANY_AUTHORITIES xca
			   WHERE xca.DEALER_CODE = xtr_user_access.dealer_code
			   AND xca.COMPANY_AUTHORISED_FOR_INPUT = 'Y' ) -- bug 5605716
   order by e.deal_type, e.deal_number, e.transaction_number, e.date_type, e.amount_date;

   Q2_REC  Q2%ROWTYPE;

 ----------------------------------------------------------------------------------------------
 -- NOTE: Q3 are for Exposure transactions.  EXP actions are not entered into JEA.
 --       They are entered into XTR_EXPOSURE_TYPES table by company/exposure type.
 --       However, DDA does get updated for Exposure transactions.  Two journal entries
 --       should be created for EXP deals, one for the exposure side and the other
 --       for the bank account side.  Journals should be generated only after the
 --       transaction has been settled, when no further changes to the transaction
 --       are allowed.
 --       Product type is currently not applicable for 'EXP' and will be denoted as
 --       'NOT APPLIC' in DDA and JOUNRNALS tables.
 --       Only a transaction number is assigned to exposures.  In DDA, this trans nbr will
 --       be used as the deal number and 0 will be used for the transaction number.  Therefore,
 --       there is the possibility of having the same deal number for two different deal types
 --       in DDA.  To be consistant, journal entries will also follow this format.
 ----------------------------------------------------------------------------------------------
 Cursor Q3 is
  select
    dda.company_code					company_code
   ,dda.deal_number					deal_number
   ,dda.currency					currency
   ,dda.deal_type					deal_type
   ,dda.deal_subtype					deal_subtype
   ,dda.product_type					product_type
   ,dda.portfolio_code					portfolio_code
   ,dda.amount_type					amount_type
   ,decode(dda.action_code,'PAY',nvl(dda.amount,0),0)	debit_amount
   ,decode(dda.action_code,'REC',nvl(dda.amount,0),0)	credit_amount
   ,dda.transaction_number				trans_number
   ,dda.amount_date                                     amount_date     --Reverted Back to amount_date Bug 5235988
   ,typ.code_combination_id				type_ccid
   ,bnk.code_combination_id				bank_ccid
   ,dda.settlement_number				settlement_number
   ,dda.date_type					date_type
   ,dda.action_code					action_code
   ,dda.dual_authorisation_by				validated_by		-- Added for 1336492.
  from XTR_DEAL_DATE_AMOUNTS_V    dda,
       XTR_EXPOSURE_TRANSACTIONS  exp,
       XTR_EXPOSURE_TYPES         typ,
       XTR_BANK_ACCOUNTS          bnk
 where dda.company_code        = in_company
   and dda.amount_date        <= in_period_end
   and dda.batch_id is null
   and dda.settle              = 'Y'
   and dda.deal_type           = 'EXP'
   and dda.deal_subtype        = 'FIRM'
   and dda.company_code        = exp.company_code
   and dda.transaction_number  = exp.transaction_number
   and dda.amount              <> 0.00			-- 1336492.
   and exp.company_code        = typ.company_code
   and exp.exposure_type       = typ.exposure_type
   and bnk.party_code (+)      = dda.company_code
   and bnk.account_number (+)  = dda.account_no
 order by exp.transaction_number			-- 1336492.
;

   Q3_REC  Q3%ROWTYPE;

 ----------------------------------------------------------------------------------------------
 --  NOTE: Q4 will process accruals from XTR_JOURNAL_ENTRY_ACTIONS
 --        (where date type = 'ACCRUAL') and join it to XTR_ACCRLS_AMORT
 --        to create journal entries.
 ----------------------------------------------------------------------------------------------
 Cursor Q4 is
  Select
    acc.batch_id			batch_id
   ,acc.company_code			company_code
   ,acc.deal_no				deal_number
   ,acc.currency			currency
   ,acc.deal_type			deal_type
   ,acc.deal_subtype			deal_subtype
   ,acc.product_type			product_type
   ,acc.portfolio_code			portfolio_code
   ,acc.amount_type			amount_type
   ,acc.accrls_amount			accrls_amount
   ,acc.trans_no			trans_number
   ,acc.period_to			amount_date
   ,jea.credit_or_debit			credit_or_debit
   ,jea.code_combination_id		ccid
   ,acc.rowid				row_id
   ,jea.date_type			date_type
   ,jea.action_code			action_code
  from xtr_accrls_amort acc,
       xtr_journal_entry_actions jea
 where acc.batch_id       = in_batch_id
   and jea.company_code   = in_company
   and jea.date_type      = 'ACCRUAL'
   and jea.company_code   = acc.company_code
   and jea.deal_type      = acc.deal_type
   and jea.deal_subtype   = acc.deal_subtype
   and jea.product_type   = acc.product_type
   and jea.portfolio_code = acc.portfolio_code
   and jea.amount_type    = acc.amount_type
   and jea.action_code    = acc.action_code
   and acc.period_to between nvl(jea.effective_from, ADD_MONTHS(sysdate,-240)) and NVL(JEA.effective_to, sysdate)  -- flex journals
   and acc.period_to     <= in_period_end
   and nvl(in_upgrade_batch,'N') <> 'I'  -- Do not generate accruals for inaugural batch
   order by acc.rowid
;

   Q4_REC  Q4%ROWTYPE;

 ----------------------------------------------------------------------------------------------
 -- NOTE: Q5 will process revaluations from XTR_REVALUATION_DETAILS.
 --       There is no amount_type column in the XTR_REVALUATION_DETAILS table.
 --       In the JEA setup, the amount type of 'UNREAL' and 'REAL' is intended
 --       to allow the user to post unrealized/realized gains/losses to different
 --       GL accounts.  In addition, any unrealized gains/losses will be flagged
 --       as requiring a reversal entry in the subsequent period when transferring
 --       XTR journals to the GL interface table.
 --       Instead, there are separate columns for REALIZED_PL and UNREALIZED_PL
 --       amounts in the XTR_REVALUATION_DETAILS table.  If the row is for a realized
 --       profit/loss, then there will be an amount in the REALIZED_PL column, etc.
 ----------------------------------------------------------------------------------------------
 Cursor Q5 is
    Select
      dnm.rowid			row_id
     ,dnm.batch_id		batch_id
     ,dnm.company_code		company_code
     ,dnm.deal_number		deal_number
     ,dnm.currency		reval_currency
     ,dea.currency		deal_currency
     ,dea.deal_type		deal_type
     ,dea.deal_subtype		deal_subtype
     ,dea.product_type		product_type
     ,dea.portfolio_code	portfolio_code
--   ,decode(jea.amount_type,'REAL',nvl(dnm.amount,0),0)
--   ,decode(jea.amount_type,'UNREAL',nvl(dnm.amount,0),0)
     ,dnm.amount		amount
     ,dnm.transaction_number	trans_number
     ,dnm.journal_date          journal_date	 --  Bug 1967109  replacing dnm.amount_date
     ,jea.credit_or_debit	credit_or_debit
     ,jea.code_combination_id	ccid
     ,jea.amount_type		amount_type
     ,jea.action_code		action_code
     ,jea.date_type		date_type
   from xtr_gain_loss_dnm         dnm,
        xtr_journal_entry_actions jea,
	xtr_deals                 dea
   where dnm.batch_id       = in_batch_id
     and jea.company_code   = in_company
     and jea.date_type      = dnm.date_type
     and jea.amount_type    = dnm.amount_type
     and jea.action_code    = dnm.action
     and jea.company_code   = dnm.company_code
     and jea.deal_type ||'' = dea.deal_type
     and ((jea.deal_type in ('FXO','BOND','NI','FRA','FX') and
           nvl(in_upgrade_batch,'N') = 'I' and l_upgrade_reval = 'Y') or
          ((nvl(in_upgrade_batch,'N')<> 'I') and
	    not(jea.deal_type = 'FX' and jea.deal_subtype = 'FORWARD')))
     and jea.deal_subtype   = dea.deal_subtype
     and jea.product_type   = dea.product_type
     and jea.portfolio_code = dea.portfolio_code
     and dnm.journal_date between nvl(jea.effective_from, ADD_MONTHS(sysdate,-240)) and nvl(jea.effective_to, sysdate)  -- flex journals
     and dnm.deal_number    = dea.deal_no
--   and dnm.amount_date <= in_period_end
--   and dnm.rate_error = 'N'  -- what do we substitute with this column?
    union
    ----------
    -- ONC  --
    ----------
    Select
      dnm.rowid			row_id
     ,dnm.batch_id		batch_id
     ,dnm.company_code		company_code
     ,dnm.deal_number		deal_number
     ,dnm.currency		reval_currency
     ,ro.currency		deal_currency
     ,ro.deal_type		deal_type
     ,ro.deal_subtype		deal_subtype
     ,ro.product_type		product_type
     ,ro.portfolio_code		portfolio_code
     ,dnm.amount		amount
     ,dnm.transaction_number	trans_number
     ,dnm.journal_date          journal_date	 --  Bug 1967109  replacing dnm.amount_date
     ,jea.credit_or_debit	credit_or_debit
     ,jea.code_combination_id	ccid
     ,jea.amount_type		amount_type
     ,jea.action_code		action_code
     ,jea.date_type		date_type
   from xtr_gain_loss_dnm         dnm,
        xtr_journal_entry_actions jea,
        xtr_rollover_transactions ro
   where dnm.batch_id       = in_batch_id
     and jea.company_code   = in_company
     and jea.date_type      = dnm.date_type
     and jea.amount_type    = dnm.amount_type
     and jea.action_code    = dnm.action
     and jea.company_code   = dnm.company_code
     and jea.deal_type ||'' = ro.deal_type
     and ro.deal_type = 'ONC'
     and ((nvl(in_upgrade_batch,'N') = 'I' and l_upgrade_reval = 'Y') or
          (nvl(in_upgrade_batch,'N')<> 'I'))
     and jea.deal_subtype   = ro.deal_subtype
     and jea.product_type   = ro.product_type
     and jea.portfolio_code = ro.portfolio_code
     and dnm.journal_date between nvl(jea.effective_from, ADD_MONTHS(sysdate,-240)) and nvl(jea.effective_to, sysdate)  -- flex journals
     and dnm.deal_number    = ro.deal_number
     and dnm.transaction_number = ro.transaction_number
    union
    --------
    -- IG --
    --------
    Select
      dnm.rowid			row_id
     ,dnm.batch_id		batch_id
     ,dnm.company_code		company_code
     ,dnm.deal_number		deal_number
     ,dnm.currency		reval_currency
     ,ig.currency		deal_currency
     ,'IG'			deal_type
     ,decode(sign(ig.balance_out),-1,'FUND','INVEST')  	deal_subtype
     ,ig.product_type		product_type
     ,ig.portfolio		portfolio_code
     ,dnm.amount		amount
     ,dnm.transaction_number	trans_number
     ,dnm.journal_date          journal_date	 --  Bug 1967109  replacing dnm.amount_date
     ,jea.credit_or_debit	credit_or_debit
     ,jea.code_combination_id	ccid
     ,jea.amount_type		amount_type
     ,jea.action_code		action_code
     ,jea.date_type		date_type
   from xtr_gain_loss_dnm         dnm,
        xtr_journal_entry_actions jea,
	xtr_intergroup_transfers  ig
   where dnm.batch_id            = in_batch_id
     and jea.company_code        = in_company
     and jea.date_type           = dnm.date_type
     and jea.amount_type         = dnm.amount_type
     and jea.action_code         = dnm.action
     and jea.company_code        = dnm.company_code
     and jea.deal_type           = ig.deal_type
     and ig.deal_type            = 'IG'
     and ((nvl(in_upgrade_batch,'N') = 'I' and l_upgrade_reval = 'Y') or
          (nvl(in_upgrade_batch,'N')<> 'I'))
     and jea.deal_subtype        = decode(sign(ig.balance_out),-1,'FUND','INVEST')
     and jea.product_type        = ig.product_type
     and jea.portfolio_code      = ig.portfolio
     and dnm.journal_date between nvl(jea.effective_from, ADD_MONTHS(sysdate,-240)) and nvl(jea.effective_to, sysdate)    -- flex journals
     and dnm.deal_number         = ig.deal_number
     and dnm.transaction_number  = ig.transaction_number
    union
    --------
    -- CA --
    --------
    Select
      dnm.rowid			row_id
     ,dnm.batch_id		batch_id
     ,dnm.company_code		company_code
     ,dnm.deal_number		deal_number
     ,dnm.currency		reval_currency
     ,ba.currency		deal_currency
     ,'CA'			deal_type
     ,decode(sign(bb.balance_cflow),-1,'FUND','INVEST')		deal_subtype
     ,'NOT APPLIC'		product_type
     ,ba.portfolio_code		portfolio_code
     ,dnm.amount		amount
     ,dnm.transaction_number	trans_number
     ,dnm.journal_date          journal_date	 --  Bug 1967109  replacing dnm.amount_date
     ,jea.credit_or_debit	credit_or_debit
     ,jea.code_combination_id	ccid
     ,jea.amount_type		amount_type
     ,jea.action_code		action_code
     ,jea.date_type		date_type
   from xtr_gain_loss_dnm         dnm,
        xtr_journal_entry_actions jea,
	xtr_revaluation_details   rd,
        xtr_bank_accounts         ba,
        xtr_bank_balances         bb
   where dnm.batch_id            = in_batch_id
     and jea.company_code        = in_company            -- JEA
     and jea.date_type           = dnm.date_type         -- DNM
     and jea.amount_type         = dnm.amount_type       -- DNM
     and jea.action_code         = dnm.action            -- DNM
     and jea.company_code        = dnm.company_code      -- DNM
     and jea.deal_type           = rd.deal_type          -- JEA
     and dnm.journal_date between nvl(jea.effective_from, ADD_MONTHS(sysdate,-240)) and nvl(jea.effective_to, sysdate)       -- flex journals
     and rd.deal_type            = 'CA'                  -- Reval Details
     and rd.deal_no              = dnm.deal_number       -- Reval Details
     and rd.batch_id             = dnm.batch_id          -- Reval Details
     and rd.period_to            = dnm.journal_date      -- Reval Details
     and rd.realized_flag        = 'Y'                   -- Reval Details
     and ba.party_code           = bb.company_code       -- Bank Balances
     and ba.account_number       = bb.account_number     -- Bank Balances
     and bb.balance_date         = dnm.journal_date      -- Bank Balances
     and jea.deal_subtype = decode(sign(bb.balance_cflow),
                                 -1,'FUND','INVEST')     -- JEA
     and jea.product_type        = 'NOT APPLIC'          -- JEA
     and jea.portfolio_code      = ba.portfolio_code     -- JEA
     and ba.party_code           = rd.company_code       -- Bank Account
     and ba.account_number       = rd.account_no         -- Bank Account
     and ba.currency             = rd.currencya          -- Bank Account
     and ((nvl(in_upgrade_batch,'N') = 'I' and l_upgrade_reval = 'Y') or
          (nvl(in_upgrade_batch,'N')<> 'I'))
   order by 1;


   Q5_REC	Q5%ROWTYPE;

 ------------------------------------------------------------------------------------------
 -- NOTE: Q6 will process FX Forward deals for Revaluations and
 -- Effectiveness testing journal entries only. This cursor will include
 -- the normal FX deals and hedge associated FX Forward deals.  This
 -- cursor will fetch all FX deals from XTR_GAIN_LOSS_DNM table with
 -- Amount_type/Date_type/Action combination defined in JEA set up, and
 -- process the reval_eff_flag equal to 'T' (Efffective testing results) first.
 -- If any of the flag 'T' is found, then the flag 'R' for the same deal
 -- number /amout type will not be journalized.
 -------------------------- ------------------------------------------------------------
 Cursor Q6 is Select
        dnm.rowid               row_id,
        dnm.batch_id            batch_id,
        dnm.company_code        company_code,
        dnm.deal_number         deal_number,
        dnm.currency            reval_currency,
        dnm.currency            deal_currency,
        dea.deal_type           deal_type,
        dea.deal_subtype        deal_subtype,
        dea.product_type        product_type,
        dea.portfolio_code      portfolio_code,
        dnm.amount              amount,
        dnm.transaction_number  trans_number,
        dnm.journal_date        journal_date,
        jea.credit_or_debit     credit_or_debit,
        jea.code_combination_id ccid,
        jea.amount_type         amount_type,
        jea.action_code         action_code,
        jea.date_type           date_type,
        dnm.reval_eff_flag	reval_eff_flag
        from XTR_GAIN_LOSS_DNM dnm,
                  XTR_DEALS dea,
                  XTR_JOURNAL_ENTRY_ACTIONS jea
        Where dnm.batch_id = in_batch_id
        And jea.company_code = in_company
        And jea.company_code = dnm.company_code
        And jea.amount_type = dnm.amount_type
        And jea.action_code = dnm.action
        And jea.deal_type = dea.deal_type
        And jea.deal_subtype = dea.deal_subtype
        And jea.product_type = dea.product_type
        And jea.portfolio_code = dea.portfolio_code
        And dea.deal_no = dnm.deal_number
        And jea.date_type = dnm.date_type
        And dnm.journal_date between nvl(jea.effective_from,
            ADD_MONTHS(sysdate,-240)) and nvl(jea.effective_to, sysdate)
        And jea.deal_type = 'FX'
        And jea.deal_subtype = 'FORWARD'
        Order by dnm.deal_number, dnm.reval_eff_flag desc;


    Q6_REC       Q6%ROWTYPE;

 ------------------------------------------------------------------------------------------
 -- NOTE: Q7 will process Hedge Items Revaluations process the CCYUNRL and UNREAL
 -- amount types based on Hedge Item accounting settings.
 -------------------------- ------------------------------------------------------------
 Cursor Q7 is Select
        dnm.rowid               row_id,
        dnm.batch_id            batch_id,
        dnm.company_code        company_code,
        dnm.deal_number         deal_number,
        dnm.currency            reval_currency,
        att.hedge_currency      deal_currency,
        'HEDGE'                 deal_type,
        str.hedge_type          deal_subtype,
        str.hedge_approach      product_type,
        att.strategy_code       portfolio_code,
        dnm.amount              amount,
        dnm.transaction_number  trans_number,
        dnm.journal_date        journal_date,
        hac.credit_or_debit     credit_or_debit,
        hac.code_combination_id ccid,
        hac.amount_type         amount_type,
        hac.action_code         action_code,
        hac.date_type           date_type
        from XTR_GAIN_LOSS_DNM dnm,
             XTR_HEDGE_JOURNAL_ACTIONS  hac,
             XTR_HEDGE_ATTRIBUTES  att,
             XTR_HEDGE_STRATEGIES  str
        Where dnm.batch_id = in_batch_id
        And hac.company_code = in_company
        And hac.company_code = dnm.company_code
        And hac.amount_type = dnm.amount_type
        And hac.action_code = dnm.action
	And hac.date_type   = dnm.date_type
	And str.strategy_code = att.strategy_code
        And att.hedge_attribute_id = dnm.deal_number
        And hac.code_combination_id is NOT NULL
        And str.hedge_approach = 'FIRMCOM';

    Q7_REC       Q7%ROWTYPE;

 ------------------------------------------------------------
 -- Obtain company's SOB currency and conversion rate type.
 ------------------------------------------------------------
 cursor COMPANY_INFO is
 select substr(sob.currency_code,1,3),
        cp.parameter_value_code,     -- replaced pty.conversion_type,
        dct.user_conversion_type
 from   xtr_parties_v pty,
        xtr_company_parameters cp,
        gl_sets_of_books sob,
        gl_daily_conversion_types dct
  where pty.party_code          = in_company
  and   cp.company_code         = pty.party_code
  and   cp.parameter_code       = 'ACCNT_EXRTP'
  and   pty.set_of_books_id     = sob.set_of_books_id
  and	cp.parameter_value_code = dct.conversion_type (+);
--and  	pty.conversion_type     = dct.conversion_type (+);

 -----------------------------------
 -- Find any upgrade reval details
 -----------------------------------
 cursor UPGRADE_REVAL is
 select b.upgrade_batch
 from   XTR_REVALUATION_DETAILS a,
        XTR_BATCHES b
 where  a.company_code  = in_company
 and    a.batch_id      = b.batch_id
 and    nvl(b.upgrade_batch,'N') = 'Y';
--
--bug 2804548
v_ChkCpnRateReset_out xtr_mm_covers.ChkCpnRateReset_out_rec;
v_ChkCpnRateReset_in xtr_mm_covers.ChkCpnRateReset_in_rec;

-- Bug 4634182

CURSOR C_NRA_PERIOD_FROM IS
SELECT min(journal_date)
FROM XTR_JOURNALS
WHERE batch_id = in_batch_id;

l_nra_period_from DATE;

-- End of Bug 4634182

   -- Begin 1336492 additions.

   Cursor VALREQ(p_param_name varchar2) is
   Select param_value
   from   xtr_pro_param
   where  param_name = p_param_name;

   l_valreq	XTR_PRO_PARAM.param_value%TYPE := NULL;
   l_val_flag	varchar2(1) := 'N';
   l_ret_value	number := 0;
   l_updt_flag	VARCHAR2(1) := 'Y';
   l_iac_valreq  xtr_pro_param.param_value%type;

   FUNCTION VALIDATED
             (l_deal_type	in varchar2,
              l_deal_no		in number,
              l_trans_no	in number,
              l_val_flag	in varchar2,
              l_co_account_no	in varchar2) RETURN BOOLEAN IS

      Cursor DEAL_VAL_BY is
      Select dual_authorisation_by
        from xtr_deals
       where deal_no = l_deal_no;

      Cursor GET_USER_DEAL_TYPE is
      Select user_deal_type
        from xtr_deal_types
       where deal_type = l_deal_type;




      l_deal_val_by	XTR_DEALS.dual_authorisation_by%TYPE := NULL;
      l_ret_value	boolean;
      l_user_deal_type	XTR_DEAL_TYPES.user_deal_type%TYPE := NULL;
      l_trans_no_1	number := l_trans_no;


   Begin
      If (l_val_flag is not null) then
         If (l_val_flag = 'Y') then
            l_ret_value := TRUE;
         Else
            l_ret_value := FALSE;
         End If;
      Else
         If (l_deal_type IN ('TMM','RTMM','BDO','FRA','IRO','SWPTN')) then
            l_trans_no_1 := null;
            Open  DEAL_VAL_BY;
            Fetch DEAL_VAL_BY into l_deal_val_by;
            Close DEAL_VAL_BY;

            If (l_deal_val_by is not null) then
               l_ret_value := TRUE;
            Else
               l_ret_value := FALSE;
            End If;
         Elsif (l_deal_type = 'CA') then
            l_ret_value := TRUE;
         Else
            l_ret_value := FALSE;
         End If;
      End If;

      If (l_deal_type in ('BOND','NI','FX','IRS','FXO')) then
         l_trans_no_1 := null;
      End If;

      If (NOT l_ret_value) then
         Open  GET_USER_DEAL_TYPE;
         Fetch GET_USER_DEAL_TYPE into l_user_deal_type;
         Close GET_USER_DEAL_TYPE;

         If (l_deal_type = 'CA') then
            l_user_deal_type := nvl(l_user_deal_type,l_deal_type) || ' : ' || l_co_account_no;
         Else
            l_user_deal_type := nvl(l_user_deal_type,l_deal_type);
         End If;

         Begin
            Insert into xtr_unval_deals_gt
                        (deal_type,
                         deal_number,
                         trans_number)
            values (l_user_deal_type, l_deal_no, l_trans_no_1);
         Exception
            when DUP_VAL_ON_INDEX then
               NULL;
            when OTHERS then
                FND_MESSAGE.Set_Name ('XTR','XTR_UNHANDLED_EXCEPTION');
                FND_MESSAGE.Set_Token ('PROCEDURE','GEN_JOURNALS:VALIDATED');
                FND_MESSAGE.Set_Token ('EVENT','INSERT_INTO_TEMP_TABLE');
                FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
          End;
      End If;
      return l_ret_value;

   Exception
      when others then
         If (DEAL_VAL_BY%ISOPEN) then
            Close DEAL_VAL_BY;
         End If;

         Begin
            Insert into xtr_unval_deals_gt
                        (deal_type,
                         deal_number,
                         trans_number)
            values (l_user_deal_type, l_deal_no, l_trans_no_1);
         Exception
            when DUP_VAL_ON_INDEX then
               NULL;
            when OTHERS then
                FND_MESSAGE.Set_Name ('XTR','XTR_UNHANDLED_EXCEPTION');
                FND_MESSAGE.Set_Token ('PROCEDURE','GEN_JOURNALS:VALIDATED');
                FND_MESSAGE.Set_Token ('EVENT','Inserting non-validated deal/transaction number into temp table.');
                FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
         End;
         return FALSE;
   End;

   PROCEDURE PRT_UNVAL_DEALS is

      Cursor UNVAL_DEALS is
      Select *
        from xtr_unval_deals_gt;

      unval_deals_rec	unval_deals%ROWTYPE;
   Begin
      Open  UNVAL_DEALS;
      Fetch UNVAL_DEALS into unval_deals_rec;
      If (UNVAL_DEALS%FOUND) then
         FND_FILE.Put_Line (FND_FILE.Log, null);
         FND_MESSAGE.Set_Name ('XTR','XTR_UNVAL_DEALS_LIST');
         FND_FILE.Put_Line (FND_FILE.Log, FND_MESSAGE.Get);
         FND_FILE.Put_Line (FND_FILE.Log, null);
         While (UNVAL_DEALS%FOUND)
         Loop
            FND_MESSAGE.Set_Name ('XTR','XTR_UNVAL_DEALS');
            FND_MESSAGE.Set_Token ('DEAL_TYPE', unval_deals_rec.deal_type);
            FND_MESSAGE.Set_Token ('DEAL_NO', rtrim(to_char(unval_deals_rec.deal_number)));
            FND_MESSAGE.Set_Token ('TRANS_NO', rtrim(to_char(unval_deals_rec.trans_number)));
            FND_FILE.Put_Line (FND_FILE.Log, FND_MESSAGE.Get);
            Fetch UNVAL_DEALS into unval_deals_rec;
         End Loop;
      End If;
      Close UNVAL_DEALS;
   End;

   -- End 1336492 additions.

begin
	IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	   xtr_debug_pkg.debug('GEN_JOURNALS: ' || '>> Gen Journals.');
	END IF;

	-- Begin 1336492 additions.

	Open  VALREQ('VAL_REQD_FOR_ACCT');
	Fetch VALREQ into l_valreq;
	Close VALREQ;
	l_valreq := nvl(l_valreq,'N');


        -- Bug 3800146 IAC redesign
        Open  VALREQ('DUAL_AUTHORISE_IAC');
	Fetch VALREQ into l_iac_valreq;
	Close VALREQ;
	l_iac_valreq := nvl(l_iac_valreq,'N');



	Delete from xtr_unval_deals_gt;

	-- End 1336492 addition.

        ----------------------------------------------------------
        -- Obtain company's SOB currency and conversion rate type.
        ----------------------------------------------------------
        Open COMPANY_INFO;
        Fetch COMPANY_INFO into l_sob_currency, l_pty_convert_type, l_pty_user_convert_type;
        Close COMPANY_INFO;

        ----------------------------------------------------------
	-- Start processing Q2 for all deal types except 'EXP'.
        ----------------------------------------------------------
	IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	   xtr_debug_pkg.debug('GEN_JOURNALS: ' || 'Opening Q2');
	END IF;

        Open Q2;
        Fetch Q2 INTO Q2_REC;

        l_batch_id             := in_batch_id;
	l_prev_deal_type       := Q2_REC.deal_type;
        l_prev_deal_nbr        := Q2_REC.deal_number;
        l_prev_transaction_nbr := Q2_REC.transaction_number;
        l_prev_date_type       := Q2_REC.date_type;
        l_prev_amount_date     := Q2_REC.amount_date;

	IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	   xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Entering Q2 loop.');
	END IF;

        WHILE Q2%FOUND LOOP

	   IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Company Code = '	|| Q2_REC.company_code);
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Deal Type = '		|| Q2_REC.deal_type);
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Deal Number = '	|| to_char(Q2_REC.deal_number));
   	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Transaction Nbr = '	|| to_char(Q2_REC.transaction_number));
   	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Amount Date = '	|| to_char(Q2_REC.amount_date,'MM/DD/RRRR'));
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Currency = '		|| Q2_REC.currency);
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Deal Subtype = '	|| Q2_REC.deal_subtype);
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Product Type = '	|| Q2_REC.product_type);
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Portfolio = '		|| Q2_REC.portfolio_code);
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Date Type = '		|| Q2_REC.date_type);
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Amount Type = '	|| Q2_REC.amount_type);
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Debit Amount = '	|| to_char(Q2_REC.dr_amount));
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Credit Amount = '	|| to_char(Q2_REC.cr_amount));
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'CCID = '		|| to_char(Q2_REC.ccid));
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Client Clr Acct = '	|| Q2_REC.client_broker_clracct);
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Settlement Number = '	|| to_char(Q2_REC.settlement_number));
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Use Prin CCID flag = '	|| Q2_REC.use_prin_ccid_flag);
   	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Use Int CCID flag  = '	|| Q2_REC.use_int_ccid_flag);
   	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Cpty Bank Acct Nbr = '	|| Q2_REC.cparty_account_no);
   	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Cpty Code = '		|| Q2_REC.cparty_code);
   	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Action Code = '	|| Q2_REC.action_code);
   	   END IF;

           -- Begin bug 1336492 additions.
           -- Added condition to prevent cashflow entry creation when deal has not been validated and
           -- system parameter is set to require validation prior to journaling.

           l_updt_flag := 'Y';

           If (Q2_REC.deal_type in ('TMM','RTMM','BDO','FRA','IRO','SWPTN')) then
              l_val_flag := null;

           elsif Q2_REC.deal_type = 'IAC' then        -- 3800146 IAC Redesign Added Lines

              if l_iac_valreq = 'N' then
                    l_val_flag := 'Y';
              else
                    If (Q2_REC.validated_by is NULL) then
                        l_val_flag := 'N';
                    Else
                        l_val_flag := 'Y';
                    End If;
               end if;                              -- 3800146 IAC Redesign Ended Lines

           Else
              If (Q2_REC.validated_by is NULL) then
                 l_val_flag := 'N';
               Else
                 l_val_flag := 'Y';
              End If;
           End If;

/* bug 4236929 -- added a new variable l_create_journal for creation of journals
 * and removed the if condition added during IAC Project */

           if   l_valreq = 'N' then
                l_create_journal := 'Y';
           else
                if  Q2_REC.deal_type  <> 'IAC' then
                    if VALIDATED(Q2_REC.deal_type, Q2_REC.deal_number,Q2_REC.transaction_number, l_val_flag, Q2_REC.co_account_no) then
                       l_create_journal := 'Y';
                    else
                       l_create_journal := 'N';
                    end if;
                else
                    if  l_iac_valreq = 'Y'  then
                        if VALIDATED(Q2_REC.deal_type, Q2_REC.deal_number,Q2_REC.transaction_number, l_val_flag, Q2_REC.co_account_no) then
                            l_create_journal := 'Y';
                        else
                            l_create_journal := 'N';
                        end if;
                    else
                       l_create_journal := 'Y';
                    end if;   --  l_iac_valreq
                end if;   -- q2_rec.deal_type
           end if;     -- l_valreq





        if l_create_journal = 'Y'  then

              --start bug 2804548
              --FND_FILE.Put_Line (FND_FILE.LOG, 'Q2 '||to_char(q2_rec.transaction_number));
              if q2_rec.deal_type in ('BOND','EXP') and
                 q2_rec.transaction_number is not null then
                 v_ChkCpnRateReset_in.deal_type:=q2_rec.deal_type;
                 v_ChkCpnRateReset_in.transaction_no:=q2_rec.transaction_number;
                 v_ChkCpnRateReset_in.deal_no:=q2_rec.deal_number;
                 xtr_mm_covers.check_coupon_rate_reset(v_ChkCpnRateReset_in,
				v_ChkCpnRateReset_out);
                 --if the coupon or its tax comp has not been reset
                 --print out a warning message.
                 if not v_ChkCpnRateReset_out.yes then
                    FND_MESSAGE.Set_Name ('XTR','XTR_COUPON_RESET_DEAL');
                    FND_MESSAGE.Set_Token ('DEAL_NO',v_ChkCpnRateReset_out.deal_no);
                    FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
--1336492                    g_gen_journal_retcode:=1;

                    -- 1336492 modification.
                    l_ret_value := greatest(l_ret_value,1);

                 end if;
              end if;
              --end bug 2804548

              If (l_deal_type NOT IN ('CA','IG')) then
                 If (nvl(Q2_REC.client_broker_clracct,'N') = 'Y') then

                    -- Reverse Journal around for a Client to Company settlement
                    -- through the Clearing Account (Only occurs in a Broker
                    -- situation where the Brokers Clearing Acct is used for the
                    -- purpose to CLEAR funds from the Cparty to Client

                    If (Q2_REC.dr_amount = 0) then
                       Q2_REC.dr_amount := Q2_REC.cr_amount;
                       Q2_REC.cr_amount := 0;
                    Elsif (Q2_REC.cr_amount = 0) then
                       Q2_REC.cr_amount := Q2_REC.dr_amount;
                       Q2_REC.dr_amount := 0;
                    End if;
                 End if;
              End If;

              /* Call private function to obtain ccid from counter party's bank account, */
              /* if it is an IG transaction with "dynamic" ccid selection.               */

              If (Q2_REC.ccid is NULL and Q2_REC.deal_type = 'IG') then
                 Q2_REC.ccid := GET_IG_CCID (
                 			Q2_REC.use_prin_ccid_flag,
                 			Q2_REC.use_int_ccid_flag,
                 			Q2_REC.company_code,
                 			Q2_REC.cparty_code,
                 			Q2_REC.currency,
                 			Q2_REC.cparty_account_no);
              End If;

              /* If ccid is null, use company's suspense ccid. */

              If (Q2_REC.ccid is NULL) then
                  Q2_REC.ccid := G_suspense_ccid;
                  l_suspense_gl := 'Y';
              Else
                  l_suspense_gl := null;
              End If;

              -- Calculate accounted_dr and accounted_cr amounts.

              BEGIN
                 l_accounted_dr := GL_CURRENCY_API.Convert_Amount (
	 		                 		Q2_REC.currency,
                 					l_sob_currency,
			                 		Q2_REC.amount_date,
			                 		l_pty_convert_type,
			                 		Q2_REC.dr_amount);

                 l_accounted_cr := GL_CURRENCY_API.Convert_Amount (
 		 					Q2_REC.currency,
 		 					l_sob_currency,
 		 					Q2_REC.amount_date,
 		 					l_pty_convert_type,
 		 					Q2_REC.cr_amount);

              EXCEPTION
                 when GL_CURRENCY_API.INVALID_CURRENCY then
                      FND_MESSAGE.Set_Name ('XTR','XTR_2206');
                      FND_MESSAGE.Set_Token ('CURR1',Q2_REC.currency);
                      FND_MESSAGE.Set_Token ('CURR2',l_sob_currency);
                      FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);

--1336492                      l_error_flag := 'Y';

                      -- 1336492 modification, replaces above l_error_flag.
                      l_ret_value := 2;
                      l_updt_flag := 'N';
                      -- end 1336492 modification.

                      Goto NEXT_Q2;

                 when GL_CURRENCY_API.NO_RATE then
                      FND_MESSAGE.Set_Name ('XTR','XTR_2207');
                      FND_MESSAGE.Set_Token ('CURR1',Q2_REC.currency);
                      FND_MESSAGE.Set_Token ('CURR2',l_sob_currency);
                      FND_MESSAGE.Set_Token ('XCHG_DATE',to_char(Q2_REC.amount_date));
                      FND_MESSAGE.Set_Token ('C_TYPE', nvl(l_pty_user_convert_type,l_pty_convert_type));
                      FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.get);

--1336492                      l_error_flag := 'Y';

                      -- 1336492 modification, replaces above l_error_flag.
                      l_ret_value := 2;
                      l_updt_flag := 'N';
                      -- end 1336492 modification.

                      Goto NEXT_Q2;
              END;

              BEGIN
                 Insert into XTR_JOURNALS
                        (batch_id,
  			 company_code,
                         journal_date,
			 orig_journal_date,
                         deal_number,
                         transaction_number,
                         deal_type,
                         deal_subtype,
                         product_type,
                         debit_amount,
                         credit_amount,
                         code_combination_id,
                         amount_type,
                         created_by,
                         created_on,
                         portfolio_code,
                         currency,
                         set_of_books_id,
                         suspense_gl,
                         accounted_dr,
                         accounted_cr,
                         settlement_number,
                         date_type,
                         action_code)
                  Values (l_batch_id,
			  Q2_REC.company_code,
                          nvl(Q2_REC.amount_date,to_date('01/01/1997','MM/DD/YYYY')),
                          nvl(Q2_REC.amount_date,to_date('01/01/1997','MM/DD/YYYY')),
                          Q2_REC.deal_number,
                          nvl(Q2_REC.transaction_number,999),
                          Q2_REC.deal_type,
                          Q2_REC.deal_subtype,
                          Q2_REC.product_type,
                          Q2_REC.dr_amount,
                          Q2_REC.cr_amount,
                          Q2_REC.ccid,
                          Q2_REC.amount_type,
                          G_user,
                          TRUNC(SYSDATE),
                          Q2_REC.portfolio_code,
                          Q2_REC.currency,
                          G_set_of_books_id,
                          l_suspense_gl,
                          l_accounted_dr,
                          l_accounted_cr,
                          Q2_REC.settlement_number,		-- Bug 4004772.
                          Q2_REC.date_type,
                          Q2_REC.action_code);
              EXCEPTION
                 when DUP_VAL_ON_INDEX then
                      NULL;
                 when OTHERS then
                      FND_MESSAGE.Set_Name ('XTR','XTR_UNHANDLED_EXCEPTION');
                      FND_MESSAGE.Set_Token ('PROCEDURE','GEN_JOURNALS');
                      FND_MESSAGE.Set_Token ('EVENT','Inserting journal into table.');
                      FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.get);

                      -- 1336492 addition.
                      l_ret_value := 2;
              END;

              <<NEXT_Q2>>

              Fetch Q2 INTO Q2_REC;

              l_batch_id := in_batch_id;

              -- Update DDA upon change in deal type, deal number, transaction number,
              -- date type, and amount date.

              If (Q2_REC.deal_type <> nvl(l_prev_deal_type,'@@@@@@@') or
                  Q2_REC.deal_number <> nvl(l_prev_deal_nbr,-1) or
                  Q2_REC.transaction_number <> nvl(l_prev_transaction_nbr,-1) or
                  Q2_REC.date_type <> nvl(l_prev_date_type,'@@@@@@@') or
                  Q2_REC.amount_date <> l_prev_amount_date) then

                  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
                     xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Change in deal type, deal #, trans #, date type, or amt date.');
                  END IF;

--1336492                  If (nvl(l_error_flag,'N') <> 'Y') then

                  -- 1336492 modification, replaces above l_error_flag condition.
                  If (nvl(l_updt_flag,'Y') = 'Y') then

                     IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
                        xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Update DDA journal created flag.');
                     END IF;

                     -- Update DDA to put BATCH_ID value once journal is generated

                     Update XTR_DEAL_DATE_AMOUNTS
                        set BATCH_ID = l_batch_id
                      where deal_type = l_prev_deal_type
                        and deal_number = l_prev_deal_nbr
                        and transaction_number = l_prev_transaction_nbr
                        and date_type = l_prev_date_type
                        and amount_date = l_prev_amount_date --Reverted Back to amount_date Bug 5235988
                        and batch_id is null;  -- prevent overwritting the previous batch_id

                    --Commit;
                 End If;	--  l_updt_flag = 'Y'.

                 l_prev_deal_type       := Q2_REC.deal_type;
                 l_prev_deal_nbr        := Q2_REC.deal_number;
                 l_prev_transaction_nbr := Q2_REC.transaction_number;
                 l_prev_date_type       := Q2_REC.date_type;
                 l_prev_amount_date     := Q2_REC.amount_date;
              End If;	--  new group of entries.
           Else
              -- Begin 1336492 additions.
              -- Deal/Trans not validated, bypass journal creation for this group of deal type, deal nbr, and trans nbr.

              IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
                 xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Deal/Trans not validated.  Bypass entry creation.');
              END IF;

--1336492              l_error_flag := 'Y';

              -- 1336492.  Replaces above l_error_flag.
              l_updt_flag := 'N';
              l_ret_value := greatest(l_ret_value,1);

              While (l_prev_deal_type = Q2_REC.deal_type and
                     nvl(l_prev_deal_nbr,-1) = Q2_REC.deal_number and
                     l_prev_transaction_nbr = Q2_REC.transaction_number)
              Loop
                 Fetch Q2 INTO Q2_REC;
                 Exit when Q2%NOTFOUND;
              End Loop;

              If (Q2%FOUND) then
                 l_prev_deal_type       := Q2_REC.deal_type;
                 l_prev_deal_nbr        := Q2_REC.deal_number;
                 l_prev_transaction_nbr := Q2_REC.transaction_number;
                 l_prev_date_type       := Q2_REC.date_type;
                 l_prev_amount_date     := Q2_REC.amount_date;
              Else
                 l_prev_deal_nbr        := null;
              End If;

              -- End 1336492 additions.
           End If;	-- deal/trans validated or no validation required.
        END LOOP;
        Close Q2;

        IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
           xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Exiting Q2.');
        END IF;

--1336492        If (l_prev_deal_nbr is NOT NULL and nvl(l_error_flag,'N') <> 'Y') then

        -- 1336492.
        -- Modified condition to use l_updt_flag instead of l_error_flag.
        If (l_prev_deal_nbr is NOT NULL and nvl(l_updt_flag,'Y') = 'Y') then

           IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
              xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Update last batch of Q2 data.');
           END IF;

           Update XTR_DEAL_DATE_AMOUNTS
              set batch_id  = l_batch_id
            where deal_type = l_prev_deal_type
              and date_type = l_prev_date_type
              and deal_number = l_prev_deal_nbr
              and transaction_number = l_prev_transaction_nbr
	      and amount_date = l_prev_amount_date --reverted Back to amount_date Bug 5235988
              and batch_id is null;  -- prevent overwritting the previous batch ID

           --Commit;

-- Removed for 1336492 to prevent rollback of unvalidated deals/transactions from the temporary table.
/*        Else
              -- Rollback only after entire cursor has been processed and errors were encountered.
              -- Otherwise, will cause "fetch out of sequence" error if done at "group" level.

              If (nvl(l_error_flag,'N') = 'Y') then
                 Rollback;
              End If;
*/
        End If;

        l_ccid                 := NULL;
        l_prev_deal_type       := NULL;
        l_prev_deal_nbr        := to_number(NULL);
        l_prev_transaction_nbr := to_number(NULL);
        l_prev_date_type       := NULL;
        l_prev_amount_date     := to_date(NULL);

        ---------------------------------------------------
        -- Q3 - Generate Journals for Exposure Transactions
        ---------------------------------------------------

        Open Q3;
        Fetch Q3 INTO Q3_REC;

	l_batch_id := in_batch_id;

	IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	   xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Entering Q3 loop.');
	END IF;

        While Q3%FOUND LOOP
        --
	   IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Company Code = ' 	|| Q3_REC.company_code);
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Deal Type = ' 		|| Q3_REC.deal_type);
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Deal Number = ' 	|| to_char(Q3_REC.deal_number));
   	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Transaction Nbr = ' 	|| to_char(Q3_REC.trans_number));
   	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Amount Date = ' 	|| to_char(Q3_REC.amount_date,'MM/DD/RRRR'));
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Currency = ' 		|| Q3_REC.currency);
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Deal Subtype = ' 	|| Q3_REC.deal_subtype);
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Product Type = ' 	|| Q3_REC.product_type);
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Amount Type = ' 	|| Q3_REC.amount_type);
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Debit Amount = ' 	|| to_char(Q3_REC.debit_amount));
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Credit Amount = ' 	|| to_char(Q3_REC.credit_amount));
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'CCID = ' 		|| to_char(Q3_REC.type_ccid));
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Bank CCID = ' 		|| to_char(Q3_REC.bank_ccid));
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Settlement # = ' 	|| to_char(Q3_REC.settlement_number));
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Date Type = ' 		|| Q3_REC.date_type);
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Action Code = '	|| Q3_REC.action_code);
	   END IF;

           -- 1336492 additions.
           -- Added logic to determine validation status of EXP transaction.
           -- If unvalidated and system param Validation Required for Accounting is set to 'Y',
           -- then prevent creation of journal entry for the transaction.

           l_updt_flag := 'Y';

           If (Q3_REC.validated_by is NULL) then
              l_val_flag := 'N';
           Else
              l_val_flag := 'Y';
           End If;

           If (l_valreq = 'Y' and VALIDATED(Q3_REC.deal_type, Q3_REC.deal_number, Q3_REC.trans_number, l_val_flag, null)) or
              (l_valreq = 'N') then

              --start bug 2804548
              if q3_rec.deal_type in ('BOND','EXP') and
                 q3_rec.trans_number is not null then
                 v_ChkCpnRateReset_in.deal_type:=q3_rec.deal_type;
                 v_ChkCpnRateReset_in.transaction_no:=q3_rec.trans_number;
                 v_ChkCpnRateReset_in.deal_no:=q3_rec.deal_number;
                 xtr_mm_covers.check_coupon_rate_reset(v_ChkCpnRateReset_in,
				 v_ChkCpnRateReset_out);
                 --if the coupon or its tax comp has not been reset
                 --print out a warning message.
                 if not v_ChkCpnRateReset_out.yes then
                    FND_MESSAGE.Set_Name ('XTR','XTR_COUPON_RESET_DEAL');
                    FND_MESSAGE.Set_Token ('DEAL_NO',v_ChkCpnRateReset_out.deal_no);
                    FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
--1336492                    g_gen_journal_retcode:=1;

                    -- 1336492.  Replaces above g_gen_journal_retcode.
                    l_ret_value := greatest(l_ret_value,1);

                 end if;
              end if;
              --end bug 2804548

              -- Use company's suspense ccid if l_ccid is null.

              If (Q3_REC.type_ccid is NULL) then
                 Q3_REC.type_ccid := G_suspense_ccid;
                 l_suspense_gl := 'Y';
              Else
                 l_suspense_gl := null;
              End If;

              -- Calculate accounted_dr and accounted_cr amounts.

              BEGIN
                 l_accounted_dr := GL_CURRENCY_API.Convert_Amount (
			                 		Q3_REC.currency,
                 					l_sob_currency,
			                 		Q3_REC.amount_date,
			                 		l_pty_convert_type,
			                 		Q3_REC.debit_amount);

                 l_accounted_cr := GL_CURRENCY_API.Convert_Amount (
 		 					Q3_REC.currency,
 		 					l_sob_currency,
 		 					Q3_REC.amount_date,
 		 					l_pty_convert_type,
 		 					Q3_REC.credit_amount);
              EXCEPTION
                 when GL_CURRENCY_API.INVALID_CURRENCY then
                      FND_MESSAGE.Set_Name ('XTR','XTR_2206');
                      FND_MESSAGE.Set_Token ('CURR1',Q3_REC.currency);
                      FND_MESSAGE.Set_Token ('CURR2',l_sob_currency);
                      FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
--1336492                      l_error_flag := 'Y';

                      -- 1336492.  Replaces l_error_flag.
                      l_ret_value := greatest(l_ret_value,2);
                      l_updt_flag := 'N';

                      Goto NEXT_Q3;

                 when GL_CURRENCY_API.NO_RATE then
                      FND_MESSAGE.Set_Name ('XTR','XTR_2207');
                      FND_MESSAGE.Set_Token ('CURR1',Q3_REC.currency);
                      FND_MESSAGE.Set_Token ('CURR2',l_sob_currency);
                      FND_MESSAGE.Set_Token ('XCHG_DATE',to_char(Q3_REC.amount_date));
                      FND_MESSAGE.Set_Token ('C_TYPE', nvl(l_pty_user_convert_type,l_pty_convert_type));
                      FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.get);
--1336492                      l_error_flag := 'Y';

                      -- 1336492.  Replaces l_error_flag.
                      l_ret_value := greatest(l_ret_value,2);
                      l_updt_flag := 'N';

                      Goto NEXT_Q3;
              END;

              BEGIN
                 Insert into XTR_JOURNALS
			(batch_id,
                         company_code,
                         journal_date,
			 orig_journal_date,
                         deal_number,
                         transaction_number,
                         deal_type,
                         deal_subtype,
                         product_type,
                         portfolio_code,
                         debit_amount,
                         credit_amount,
                         code_combination_id,
                         amount_type,
                         created_by,
                         created_on,
                         currency,
                         set_of_books_id,
                         suspense_gl,
                         accounted_dr,
                         accounted_cr,
                         settlement_number,
                         date_type,
                         action_code)
                  Values
                         (l_batch_id,
			  Q3_REC.company_code,
                          nvl(Q3_REC.amount_date,to_date('01/01/1997','MM/DD/YYYY')),
                          nvl(Q3_REC.amount_date,to_date('01/01/1997','MM/DD/YYYY')),
                          Q3_REC.deal_number,
                          nvl(Q3_REC.trans_number,999),
                          Q3_REC.deal_type,
                          Q3_REC.deal_subtype,
                          Q3_REC.product_type,
                          Q3_REC.portfolio_code,
                          Q3_REC.debit_amount,
                          Q3_REC.credit_amount,
                          Q3_REC.type_ccid,
                          Q3_REC.amount_type,
                          G_user,
                          trunc(SYSDATE),
                          Q3_REC.currency,
                          G_set_of_books_id,
                          l_suspense_gl,
                          l_accounted_dr,
                          l_accounted_cr,
                          Q3_REC.settlement_number,
                          Q3_REC.date_type,
                          Q3_REC.action_code);

              EXCEPTION
                 when DUP_VAL_ON_INDEX then
                      NULL;
                 when OTHERS then
                      FND_MESSAGE.Set_Name ('XTR','XTR_UNHANDLED_EXCEPTION');
                      FND_MESSAGE.Set_Token ('PROCEDURE','GEN_JOURNALS');
                      FND_MESSAGE.Set_Token ('EVENT','Inserting exposure journal into table.');
                      FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.get);

                      -- 1336492.
                      l_ret_value := greatest(l_ret_value,2);
              END;

              -- Create journal entry for bank acct side.

              If (Q3_REC.bank_ccid is NULL) then
                  Q3_REC.bank_ccid := G_suspense_ccid;
                  l_suspense_gl := 'Y';
              Else
                  l_suspense_gl := null;
              End If;

              -- "Flip" DR/CR from EXP jrnl entry for bank acct side.

              l_tmp_amt			:= Q3_REC.debit_amount;
              Q3_REC.debit_amount	:= Q3_REC.credit_amount;
              Q3_REC.credit_amount	:= l_tmp_amt;

              l_tmp_amt      := l_accounted_dr;
              l_accounted_dr := l_accounted_cr;
              l_accounted_cr := l_tmp_amt;

              BEGIN
                 Insert into XTR_JOURNALS
			(batch_id,
                         company_code,
                         journal_date,
			 orig_journal_date,
                         deal_number,
                         transaction_number,
                         deal_type,
                         deal_subtype,
                         product_type,
                         portfolio_code,
                         debit_amount,
                         credit_amount,
                         code_combination_id,
                         amount_type,
                         created_by,
                         created_on,
                         currency,
                         set_of_books_id,
                         suspense_gl,
                         accounted_dr,
                         accounted_cr,
                         settlement_number,
                         date_type,
                         action_code)
                  Values
                         (l_batch_id,
			  Q3_REC.company_code,
                          nvl(Q3_REC.amount_date,to_date('01/01/1997','MM/DD/YYYY')),
                          nvl(Q3_REC.amount_date,to_date('01/01/1997','MM/DD/YYYY')),
                          Q3_REC.deal_number,
                          nvl(Q3_REC.trans_number,999),
                          Q3_REC.deal_type,
                          Q3_REC.deal_subtype,
                          Q3_REC.product_type,
                          Q3_REC.portfolio_code,
                          Q3_REC.debit_amount,
                          Q3_REC.credit_amount,
                          Q3_REC.bank_ccid,
                          Q3_REC.amount_type,
                          G_user,
                          trunc(SYSDATE),
                          Q3_REC.currency,
                          G_set_of_books_id,
                          l_suspense_gl,
                          l_accounted_dr,
                          l_accounted_cr,
                          Q3_REC.settlement_number,
                          Q3_REC.date_type,
                          Q3_REC.action_code);

              EXCEPTION
                 when DUP_VAL_ON_INDEX then
                      NULL;
                 when OTHERS then
                      FND_MESSAGE.Set_Name ('XTR','XTR_UNHANDLED_EXCEPTION');
                      FND_MESSAGE.Set_Token ('PROCEDURE','GEN_JOURNALS');
                      FND_MESSAGE.Set_Token ('EVENT','Inserting exposure journal into table.');
                      FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.get);

                      -- 1336492.
                      l_ret_value := greatest(l_ret_value,2);

              END;

              -- 1336492.  Added update condition.

              If (nvl(l_updt_flag,'Y') = 'Y') then
                 Update XTR_DEAL_DATE_AMOUNTS
                    set BATCH_ID = l_batch_id
                  where company_code = in_company
                    and deal_type = 'EXP'
                    and deal_number = Q3_REC.deal_number
                    and settlement_number = Q3_REC.settlement_number
                    and settle = 'Y'
                    and batch_id is null;  -- prevent overwritting the previous batch_id
              End If;

              --Commit;
           Else
              -- branch added for 1336492.
              l_ret_value := greatest(l_ret_value,1);
           End If;  -- validated or acct does not require validation.

           <<NEXT_Q3>>

           Fetch Q3 INTO Q3_REC;

	   l_batch_id := in_batch_id;
        END LOOP;
        Close Q3;

-- Removed for 1336492 to preserve list of unvalidated deals being stored in temporary table.
/*
        -- If an error has already been encountered within the batch, rollback data.
        -- All cursors will be processed so that all errors will be logged for users to
        -- correct in one shot.  But none of the batch information should be committed.
        -- Rolling back each cursor will help in rollback segment utilization.

        If (nvl(l_error_flag,'N') = 'Y') then
           Rollback;
        End If;
*/
        ---------------------------------------
        -- Q4 - Generate Journals for Accruals.
        ---------------------------------------

	l_prev_rowid := null;
	l_row_id := null;

     -- Exclude accrual journal processing if Inaguaral batch or if batch is Non-Reval/Non-Accrual related.

     if (nvl(in_upgrade_batch,'N') <> 'I') and
        (in_source_option is null) then

        Open Q4;
        Fetch Q4 INTO Q4_REC;

	l_prev_rowid := l_row_id;

	IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	   xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Entering Q4 loop.');
	END IF;

        While Q4%FOUND LOOP
        --
	   IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Company Code = ' 	|| Q4_REC.company_code);
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Deal Type = ' 		|| Q4_REC.deal_type);
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Deal Number = ' 	|| to_char(Q4_REC.deal_number));
   	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Transaction Nbr = ' 	|| to_char(Q4_REC.trans_number));
   	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Amount Date = ' 	|| to_char(Q4_REC.amount_date,'MM/DD/RRRR'));
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Currency = ' 		|| Q4_REC.currency);
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Deal Subtype = ' 	|| Q4_REC.deal_subtype);
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Product Type = ' 	|| Q4_REC.product_type);
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Portfolio = ' 		|| Q4_REC.portfolio_code);
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Amount Type = ' 	|| Q4_REC.amount_type);
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Amount = ' 		|| to_char(Q4_REC.accrls_amount));
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'DR/CR = ' 		|| Q4_REC.credit_or_debit);
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'CCID = ' 		|| to_char(Q4_REC.ccid));
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Date Type = '		|| Q4_REC.date_type);
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Action Code = ' 	|| Q4_REC.action_code);
	   END IF;

           If (Q4_REC.accrls_amount = 0) then
              NULL;
           Else
              -- Use company's suspense ccid if l_ccid is null.

              If (Q4_REC.ccid is NULL) then
                  Q4_REC.ccid := G_suspense_ccid;
                  l_suspense_gl := 'Y';
              Else
                  l_suspense_gl := null;
              End If;

              -- Calculate accounted_dr and accounted_cr amounts.

              BEGIN
                 l_accounted_dr := 0;
                 l_accounted_cr := 0;

                 If (Q4_REC.credit_or_debit = 'DR') then
                    l_accounted_dr := GL_CURRENCY_API.Convert_Amount (
			                 		Q4_REC.currency,
                 					l_sob_currency,
			                 		Q4_REC.amount_date,
			                 		l_pty_convert_type,
			                 		Q4_REC.accrls_amount);
                 Else
		    l_accounted_cr := GL_CURRENCY_API.Convert_Amount (
 		 					Q4_REC.currency,
 		 					l_sob_currency,
 		 					Q4_REC.amount_date,
 		 					l_pty_convert_type,
 		 					Q4_REC.accrls_amount);
		 End If;

              EXCEPTION
                 when GL_CURRENCY_API.INVALID_CURRENCY then
                      FND_MESSAGE.Set_Name ('XTR','XTR_2206');
                      FND_MESSAGE.Set_Token ('CURR1',Q4_REC.currency);
                      FND_MESSAGE.Set_Token ('CURR2',l_sob_currency);
                      FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
--1336492		      l_error_flag := 'Y';
                      l_ret_value := greatest(l_ret_value,2);
                      Goto NEXT_Q4;

                 when GL_CURRENCY_API.NO_RATE then
                      FND_MESSAGE.Set_Name ('XTR','XTR_2207');
                      FND_MESSAGE.Set_Token ('CURR1',Q4_REC.currency);
                      FND_MESSAGE.Set_Token ('CURR2',l_sob_currency);
                      FND_MESSAGE.Set_Token ('XCHG_DATE',to_char(Q4_REC.amount_date));
                      FND_MESSAGE.Set_Token ('C_TYPE', nvl(l_pty_user_convert_type,l_pty_convert_type));
                      FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.get);
--1336492                      l_error_flag := 'Y';
                      l_ret_value := greatest(l_ret_value,2);
                      Goto NEXT_Q4;
              END;

              BEGIN
                 Insert into XTR_JOURNALS
			(batch_id,
                         company_code,
                         journal_date,
			 orig_journal_date,
                         deal_number,
                         transaction_number,
                         deal_type,
                         deal_subtype,
                         product_type,
                         portfolio_code,
                         debit_amount,
                         credit_amount,
                         code_combination_id,
                         amount_type,
                         created_by,
                         created_on,
                         currency,
                         set_of_books_id,
                         suspense_gl,
                         accounted_dr,
                         accounted_cr,
                         date_type,
                         action_code)
                  Values
                         (Q4_REC.batch_id,
			  Q4_REC.company_code,
                          nvl(Q4_REC.amount_date,to_date('01/01/1997','MM/DD/YYYY')),
                          nvl(Q4_REC.amount_date,to_date('01/01/1997','MM/DD/YYYY')),
                          Q4_REC.deal_number,
                          nvl(Q4_REC.trans_number,999),
                          Q4_REC.deal_type,
                          Q4_REC.deal_subtype,
                          Q4_REC.product_type,
                          Q4_REC.portfolio_code,
                          decode(Q4_REC.credit_or_debit,'DR',Q4_REC.accrls_amount,0),
                          decode(Q4_REC.credit_or_debit,'CR',Q4_REC.accrls_amount,0),
                          Q4_REC.ccid,
                          Q4_REC.amount_type,
                          G_user,
                          trunc(SYSDATE),
                          Q4_REC.currency,
                          G_set_of_books_id,
                          l_suspense_gl,
                          l_accounted_dr,
                          l_accounted_cr,
                          Q4_REC.date_type,
                          Q4_REC.action_code);

              EXCEPTION
                 when DUP_VAL_ON_INDEX then
                      NULL;
                 when OTHERS then
                      FND_MESSAGE.Set_Name ('XTR','XTR_UNHANDLED_EXCEPTION');
                      FND_MESSAGE.Set_Token ('PROCEDURE','GEN_JOURNALS');
                      FND_MESSAGE.Set_Token ('EVENT','Inserting accruals journal into table');
                      FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.get);

                      -- 1336492.
                      l_ret_value := greatest(l_ret_value,2);
              END;

           End If;  -- If zero amounts.

           <<NEXT_Q4>>

           Fetch Q4 INTO Q4_REC;

        END LOOP;
        Close Q4;

-- Removed for 1336492 to preserve list of unvalidated deals being stored in temporary table.
/*        If (nvl(l_error_flag,'N') = 'Y') then
           Rollback;
        End If;
*/
     end if; -- of <nvl(in_upgrade_batch,'N') <> 'I' and p_source_option is null>


        --------------------------------------------------
        -- Q5 - Generate Journal rows for Revaluations.
        --------------------------------------------------
	l_prev_rowid := null;
	l_row_id := null;

        -------------------------------------------------------------------------
        -- For inaugural batch, check if company has upgrade revaluation details
        -------------------------------------------------------------------------
        l_upgrade_reval := 'N';
        if (nvl(in_upgrade_batch,'N') = 'I') and
           (in_source_option is null) then

           Open UPGRADE_REVAL;
           Fetch UPGRADE_REVAL into l_upgrade_reval;
           if UPGRADE_REVAL%NOTFOUND then
              l_upgrade_reval := 'N';
           end if;
           Close UPGRADE_REVAL;
        end if;

     -----------------------------------------------------------------------------------------------
     -- If this is inaugural batch and there are no reval details, do not need to generate journals.
     -- Also exclude reval journals if batch is Non-Reval/Non-Accrual related.
     -----------------------------------------------------------------------------------------------
     if ((nvl(in_upgrade_batch,'N') = 'I' and l_upgrade_reval = 'Y') or nvl(in_upgrade_batch,'N') <> 'I') and
        (in_source_option is null) then

        Open Q5;
        Fetch Q5 INTO Q5_REC;

	l_prev_rowid := l_row_id;

	IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	   xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Entering Q5 loop.');
	END IF;

        While Q5%FOUND LOOP
           --
	   IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Company Code = ' 	|| Q5_REC.company_code);
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Deal Type = ' 		|| Q5_REC.deal_type);
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Deal Number = ' 	|| to_char(Q5_REC.deal_number));
   	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Transaction Nbr = ' 	|| to_char(Q5_REC.trans_number));
   	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Amount Date = ' 	|| to_char(Q5_REC.journal_date,'MM/DD/RRRR'));
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Currency = ' 		|| Q5_REC.reval_currency);
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Deal Subtype = ' 	|| Q5_REC.deal_subtype);
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Product Type = ' 	|| Q5_REC.product_type);
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Portfolio = ' 		|| Q5_REC.portfolio_code);
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Amount Type = ' 	|| Q5_REC.amount_type);
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Action Code = ' 	|| Q5_REC.action_code);
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Revaluation Amount = ' || to_char(Q5_REC.amount));
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'CCID = ' 		|| to_char(Q5_REC.ccid));
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'DR/CR = ' 		|| Q5_REC.credit_or_debit);
	      xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Date Type = '		|| Q5_REC.date_type);
	   END IF;

           If (nvl(Q5_REC.amount,0) = 0) then
              NULL;

           Else
              -- Use company's suspense ccid if l_ccid is null.

              If (Q5_REC.ccid is NULL) then
                  Q5_REC.ccid := G_suspense_ccid;
                  l_suspense_gl := 'Y';
              Else
                  l_suspense_gl := null;
              End If;

              -- Calculate accounted_dr and accounted_cr amounts.

              BEGIN
                 l_accounted_dr := 0;
                 l_accounted_cr := 0;
		 --l_tmp_amt := abs(l_realized_amt + l_unrealized_amt);

                 If (Q5_REC.credit_or_debit = 'DR') then
                    l_accounted_dr := GL_CURRENCY_API.Convert_Amount (
			                 		Q5_REC.reval_currency,
                 					l_sob_currency,
			                 		Q5_REC.journal_date,
			                 		l_pty_convert_type,
			                 		Q5_REC.amount);
                 Else
		    l_accounted_cr := GL_CURRENCY_API.Convert_Amount (
 		 					Q5_REC.reval_currency,
 		 					l_sob_currency,
 		 					Q5_REC.journal_date,
 		 					l_pty_convert_type,
 		 					Q5_REC.amount);
		 End If;

              EXCEPTION
                 when GL_CURRENCY_API.INVALID_CURRENCY then
                      FND_MESSAGE.Set_Name ('XTR','XTR_2206');
                      FND_MESSAGE.Set_Token ('CURR1',Q5_REC.reval_currency);
                      FND_MESSAGE.Set_Token ('CURR2',l_sob_currency);
                      FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
--1336492		      l_error_flag := 'Y';
                      l_ret_value := greatest(l_ret_value,2);
                      Goto NEXT_Q5;

                 when GL_CURRENCY_API.NO_RATE then
                      FND_MESSAGE.Set_Name ('XTR','XTR_2207');
                      FND_MESSAGE.Set_Token ('CURR1',Q5_REC.reval_currency);
                      FND_MESSAGE.Set_Token ('CURR2',l_sob_currency);
                      FND_MESSAGE.Set_Token ('XCHG_DATE',to_char(Q5_REC.journal_date));
                      FND_MESSAGE.Set_Token ('C_TYPE', nvl(l_pty_user_convert_type,l_pty_convert_type));
                      FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.get);
--1336492		      l_error_flag := 'Y';
                      l_ret_value := greatest(l_ret_value,2);
                      Goto NEXT_Q5;
              END;


--- bug 4641750   Added following lines
              if q5_rec.deal_type = 'FX' then

                  select currency_buy , currency_sell
                  into l_curr_buy, l_curr_sell
                  from
                  xtr_deals where deal_no = Q5_REC.deal_number;


                  if l_curr_buy = l_sob_currency then
                     l_curr := l_curr_sell;
                  elsif l_curr_sell = l_sob_currency then
                     l_curr := l_curr_buy;
                  end if;

               end if;


              if q5_rec.deal_type = 'FX' and (l_curr_buy = l_sob_currency or l_curr_sell =l_sob_currency) then
                      l_debit_amount := 0;
                      l_credit_amount := 0;


                  BEGIN
                         Insert into XTR_JOURNALS
		            	(batch_id,
                         company_code,
                         journal_date,
			 orig_journal_date,
                         deal_number,
                         transaction_number,
                         deal_type,
                         deal_subtype,
                         product_type,
                         portfolio_code,
                         debit_amount,
                         credit_amount,
                         code_combination_id,
                         amount_type,
                         created_by,
                         created_on,
                         currency,
                         set_of_books_id,
                         suspense_gl,
                         accounted_dr,
                         accounted_cr,
                         date_type,
                         action_code)
                  Values
                         (Q5_REC.batch_id,
		          Q5_REC.company_code,
                          nvl(Q5_REC.journal_date,to_date('01/01/1997','MM/DD/YYYY')),
                          nvl(Q5_REC.journal_date,to_date('01/01/1997','MM/DD/YYYY')),
                          Q5_REC.deal_number,
                          nvl(Q5_REC.trans_number,999),
                          Q5_REC.deal_type,
                          Q5_REC.deal_subtype,
                          Q5_REC.product_type,
                          Q5_REC.portfolio_code,
                          l_debit_amount,
                          l_credit_amount,
                          Q5_REC.ccid,
                          Q5_REC.amount_type,
                          G_user,
                          trunc(SYSDATE),
                          l_curr,
                          G_set_of_books_id,
                          l_suspense_gl,
                          l_accounted_dr,
                          l_accounted_cr,
                          Q5_REC.date_type,
                          Q5_REC.action_code);


              EXCEPTION
                 when DUP_VAL_ON_INDEX then
                      NULL;
                 when OTHERS then
                      FND_MESSAGE.Set_Name ('XTR','XTR_UNHANDLED_EXCEPTION');
                      FND_MESSAGE.Set_Token ('PROCEDURE','GEN_JOURNALS');
                      FND_MESSAGE.Set_Token ('EVENT','Inserting revaluation journal into table');
                      FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.get);

              END;


            else
-- bug 4641750 End code change



              BEGIN
                 Insert into XTR_JOURNALS
			(batch_id,
                         company_code,
                         journal_date,
			 orig_journal_date,
                         deal_number,
                         transaction_number,
                         deal_type,
                         deal_subtype,
                         product_type,
                         portfolio_code,
                         debit_amount,
                         credit_amount,
                         code_combination_id,
                         amount_type,
                         created_by,
                         created_on,
                         currency,
                         set_of_books_id,
                         suspense_gl,
                         accounted_dr,
                         accounted_cr,
                         date_type,
                         action_code)
                  Values
                         (Q5_REC.batch_id,
		          Q5_REC.company_code,
                          nvl(Q5_REC.journal_date,to_date('01/01/1997','MM/DD/YYYY')),
                          nvl(Q5_REC.journal_date,to_date('01/01/1997','MM/DD/YYYY')),
                          Q5_REC.deal_number,
                          nvl(Q5_REC.trans_number,999),
                          Q5_REC.deal_type,
                          Q5_REC.deal_subtype,
                          Q5_REC.product_type,
                          Q5_REC.portfolio_code,
                        --  decode(l_amount_type,'CCYREAL',0,'CCYAMRL',0,decode(l_dr_or_cr,'DR',l_reval_amt,0)),
                        --  decode(l_amount_type,'CCYREAL',0,'CCYAMRL',0,decode(l_dr_or_cr,'CR',l_reval_amt,0)),
                          decode(Q5_REC.amount_type,'CCYREAL',decode(Q5_REC.deal_type,'FX',
				decode(Q5_REC.credit_or_debit,'DR',Q5_REC.amount,0),0),'CCYAMRL',0,
				decode(Q5_REC.credit_or_debit,'DR',Q5_REC.amount,0)),
                          decode(Q5_REC.amount_type,'CCYREAL',decode(Q5_REC.deal_type,'FX',
				decode(Q5_REC.credit_or_debit,'CR',Q5_REC.amount,0),0),'CCYAMRL',0,
				decode(Q5_REC.credit_or_debit,'CR',Q5_REC.amount,0)),
                          Q5_REC.ccid,
                          Q5_REC.amount_type,
                          G_user,
                          trunc(SYSDATE),
                          decode(Q5_REC.amount_type, 'CCYREAL', decode(Q5_REC.deal_type, 'FX', Q5_REC.reval_currency, Q5_REC.deal_currency),
				'CCYAMRL',Q5_REC.deal_currency,Q5_REC.reval_currency), -- bug 2376980
                          G_set_of_books_id,
                          l_suspense_gl,
                          l_accounted_dr,
                          l_accounted_cr,
                          Q5_REC.date_type,
                          Q5_REC.action_code);

              EXCEPTION
                 when DUP_VAL_ON_INDEX then
                      NULL;
                 when OTHERS then
                      FND_MESSAGE.Set_Name ('XTR','XTR_UNHANDLED_EXCEPTION');
                      FND_MESSAGE.Set_Token ('PROCEDURE','GEN_JOURNALS');
                      FND_MESSAGE.Set_Token ('EVENT','Inserting revaluation journal into table');
                      FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.get);

                      -- 1336492.
                      l_ret_value := greatest(l_ret_value,2);
              END;

            END  If;  -- if fx deal and one currency is in SOB


           End If;  -- If zero amounts.

           <<NEXT_Q5>>

           Fetch Q5 INTO Q5_REC;
        END LOOP;
        Close Q5;

     end if;  -- of  <(in_upgrade_batch = 'I' and l_upgrade_reval = 'Y') or in_upgrade_batch <> 'I'>


        --------------------------------------------------
        -- Q6 - Generate Journal rows for FX Forward Revaluations
        -- and Retrospective test.
        --------------------------------------------------
        l_prev_rowid := null;
        l_row_id := null;
	l_q6_deal_no := null;

/*********** ***************************************************/
/* Set all amount type flags as FALSE in the beginning. System */
/* will process the eff flag with 'T' (retro) first.  If any of*/
/* the T record been found for the deal number, the associated */
/* amount flag will be set the 'TRUE', and syste should not    */
/* process 'R' record for the same deal number to avoid        */
/* duplication of journal entries.                             */
/***************************************************************/
      Open Q6;
      Fetch Q6 INTO Q6_REC;

      l_prev_rowid := l_row_id;

      IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
         xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Entering Q6 loop.');
      END IF;

      While Q6%FOUND LOOP
	If nvl(l_q6_deal_no, -1) <> Q6_REC.deal_number then
	   l_q6_deal_no := Q6_REC.deal_number;
	   l_UNREAL	:= FALSE;
	   l_CCYUNRL    := FALSE;
	   l_REAL	:= FALSE;
	   l_CCYREAL	:= FALSE;
	   l_EFF_EXIST  := FALSE;

	   If Q6_REC.reval_eff_flag = 'T' then
	      l_EFF_EXIST  := TRUE;
	   End if;

           If l_EFF_EXIST = TRUE then
              If Q6_REC.amount_type in ('UNREAL', 'NRECUNR') then
                   L_UNREAL := TRUE;
	      end if;
              If Q6_REC.amount_type in ('CCYUNRL', 'NRECCYU') then
                   L_CCYUNRL := TRUE;
	      end if;
              If Q6_REC.amount_type in ('REAL', 'NRECUNR') then
                   L_REAL := TRUE;
	      end if;
              If Q6_REC.amount_type in ('CCYREAL', 'NRECCYU') then
                   L_CCYREAL := TRUE;
	      end if;
           End if;
	end if;

        If l_EFF_EXIST = TRUE and
          ((Q6_REC.reval_eff_flag = 'R' and Q6_REC.amount_type = 'UNREAL' and
              l_UNREAL = TRUE) or
           (Q6_REC.reval_eff_flag = 'R' and Q6_REC.amount_type = 'CCYUNRL'
              and l_CCYUNRL = TRUE) or
           (Q6_REC.reval_eff_flag = 'R' and Q6_REC.amount_type = 'REAL' and
              l_REAL = TRUE) or
           (Q6_REC.reval_eff_flag = 'R' and Q6_REC.amount_type = 'CCYREAL'
              and l_CCYREAL = TRUE)) then
             NULL;  -- Do not process this Revaluations record
        Else  -- existing code

           IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
              xtr_debug_pkg.debug ('GEN_JOURNALS: ' ||'Company Code = '|| Q6_REC.company_code);
              xtr_debug_pkg.debug ('GEN_JOURNALS: ' ||'Deal Type = '  || Q6_REC.deal_type);
              xtr_debug_pkg.debug ('GEN_JOURNALS: ' ||'Deal Number = '|| to_char(Q6_REC.deal_number));
              xtr_debug_pkg.debug ('GEN_JOURNALS: ' ||'Transaction Nbr = '|| to_char(Q6_REC.trans_number));
              xtr_debug_pkg.debug ('GEN_JOURNALS: ' ||'Amount Date = '|| to_char(Q6_REC.journal_date,'MM/DD/RRRR'));
              xtr_debug_pkg.debug ('GEN_JOURNALS: ' ||'Currency = '|| Q6_REC.reval_currency);
              xtr_debug_pkg.debug ('GEN_JOURNALS: ' ||'Deal Subtype = '|| Q6_REC.deal_subtype);
              xtr_debug_pkg.debug ('GEN_JOURNALS: ' ||'Product Type = '|| Q6_REC.product_type);
              xtr_debug_pkg.debug ('GEN_JOURNALS: ' ||'Portfolio = '|| Q6_REC.portfolio_code);
              xtr_debug_pkg.debug ('GEN_JOURNALS: ' ||'Amount Type = '|| Q6_REC.amount_type);
              xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Action Code = '|| Q6_REC.action_code);
              xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Revaluation Amount = '|| to_char(Q6_REC.amount));
              xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'CCID = '|| to_char(Q6_REC.ccid));
              xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'DR/CR = '|| Q6_REC.credit_or_debit);
              xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Date Type = '|| Q6_REC.date_type);
           END IF;

           If (nvl(Q6_REC.amount,0) = 0) then
              NULL;
           Else
             -- Calculate accounted_dr and accounted_cr amounts.
              BEGIN
                 l_accounted_dr := 0;
                 l_accounted_cr := 0;

                 If (Q6_REC.credit_or_debit = 'DR') then
                    l_accounted_dr := GL_CURRENCY_API.Convert_Amount (
                                                        Q6_REC.reval_currency,
                                                        l_sob_currency,
                                                        Q6_REC.journal_date,
                                                        l_pty_convert_type,
                                                        Q6_REC.amount);
                 Else
                    l_accounted_cr := GL_CURRENCY_API.Convert_Amount (
                                                        Q6_REC.reval_currency,
                                                        l_sob_currency,
                                                        Q6_REC.journal_date,
                                                        l_pty_convert_type,
                                                        Q6_REC.amount);
                 End If;
              EXCEPTION
                 when GL_CURRENCY_API.INVALID_CURRENCY then
                      FND_MESSAGE.Set_Name ('XTR','XTR_2206');
                      FND_MESSAGE.Set_Token ('CURR1',Q6_REC.reval_currency);
                      FND_MESSAGE.Set_Token ('CURR2',l_sob_currency);
                      FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
                      l_ret_value := greatest(l_ret_value,2);
                      Goto NEXT_Q6;

                 when GL_CURRENCY_API.NO_RATE then
                      FND_MESSAGE.Set_Name ('XTR','XTR_2207');
                      FND_MESSAGE.Set_Token ('CURR1',Q6_REC.reval_currency);
                      FND_MESSAGE.Set_Token ('CURR2',l_sob_currency);
                      FND_MESSAGE.Set_Token ('XCHG_DATE',to_char(Q6_REC.journal_date));
                      FND_MESSAGE.Set_Token ('C_TYPE', nvl(l_pty_user_convert_type,l_pty_convert_type));
                      FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.get);
                      l_ret_value := greatest(l_ret_value,2);
                      Goto NEXT_Q6;
              END;


 --- bug 4641750   Added following lines

                  select currency_buy , currency_sell
                  into l_curr_buy, l_curr_sell
                  from
                  xtr_deals where deal_no = Q6_REC.deal_number;


                  if l_curr_buy = l_sob_currency then
                     l_curr := l_curr_sell;
                  elsif l_curr_sell = l_sob_currency then
                     l_curr := l_curr_buy;
                  end if;



                  if (l_curr_buy = l_sob_currency or l_curr_sell =l_sob_currency) then

                      l_debit_amount := 0;
                      l_credit_amount := 0;


                       BEGIN
                         Insert into XTR_JOURNALS
		            	(batch_id,
                         company_code,
                         journal_date,
			 orig_journal_date,
                         deal_number,
                         transaction_number,
                         deal_type,
                         deal_subtype,
                         product_type,
                         portfolio_code,
                         debit_amount,
                         credit_amount,
                         code_combination_id,
                         amount_type,
                         created_by,
                         created_on,
                         currency,
                         set_of_books_id,
                         suspense_gl,
                         accounted_dr,
                         accounted_cr,
                         date_type,
                         action_code)
                  Values
                         (Q6_REC.batch_id,
		          Q6_REC.company_code,
                          nvl(Q6_REC.journal_date,to_date('01/01/1997','MM/DD/YYYY')),
                          nvl(Q6_REC.journal_date,to_date('01/01/1997','MM/DD/YYYY')),
                          Q6_REC.deal_number,
                          nvl(Q6_REC.trans_number,999),
                          Q6_REC.deal_type,
                          Q6_REC.deal_subtype,
                          Q6_REC.product_type,
                          Q6_REC.portfolio_code,
                          l_debit_amount,
                          l_credit_amount,
                          Q6_REC.ccid,
                          Q6_REC.amount_type,
                          G_user,
                          trunc(SYSDATE),
                          l_curr,
                          G_set_of_books_id,
                          l_suspense_gl,
                          l_accounted_dr,
                          l_accounted_cr,
                          Q6_REC.date_type,
                          Q6_REC.action_code);


              EXCEPTION
                 when DUP_VAL_ON_INDEX then
                      NULL;
                 when OTHERS then
                      FND_MESSAGE.Set_Name ('XTR','XTR_UNHANDLED_EXCEPTION');
                      FND_MESSAGE.Set_Token ('PROCEDURE','GEN_JOURNALS');
                      FND_MESSAGE.Set_Token ('EVENT','Inserting revaluation journal into table');
                      FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.get);

              END;


            else


--- bug 4641750   Ended code change




              BEGIN
                 Insert into XTR_JOURNALS
                        (batch_id,
                         company_code,
                         journal_date,
                         orig_journal_date,
                         deal_number,
                         transaction_number,
                         deal_type,
                         deal_subtype,
                         product_type,
                         portfolio_code,
                         debit_amount,
                         credit_amount,
                         code_combination_id,
                         amount_type,
                         created_by,
                         created_on,
                         currency,
                         set_of_books_id,
                         suspense_gl,
                         accounted_dr,
                         accounted_cr,
                         date_type,
                         action_code)
                  Values
                         (Q6_REC.batch_id,
                          Q6_REC.company_code,
                          nvl(Q6_REC.journal_date,to_date('01/01/1997','MM/DD/YYYY')),
                          nvl(Q6_REC.journal_date,to_date('01/01/1997','MM/DD/YYYY')),
                          Q6_REC.deal_number,
                          nvl(Q6_REC.trans_number,999),
                          Q6_REC.deal_type,
                          Q6_REC.deal_subtype,
                          Q6_REC.product_type,
                          Q6_REC.portfolio_code,
                          decode(Q6_REC.credit_or_debit,'DR',Q6_REC.amount,0),
                          decode(Q6_REC.credit_or_debit,'CR',Q6_REC.amount,0),
                          Q6_REC.ccid,
                          Q6_REC.amount_type,
                          G_user,
                          trunc(SYSDATE),
                          decode(Q6_REC.amount_type, 'CCYREAL', Q6_REC.deal_currency,
                                Q6_REC.reval_currency),
                          G_set_of_books_id,
                          l_suspense_gl,
                          l_accounted_dr,
                          l_accounted_cr,
                          Q6_REC.date_type,
                          Q6_REC.action_code);

             if Q6_REC.reval_eff_flag = 'T' then
                FND_MESSAGE.set_name('XTR', 'XTR_HEDGE_JOURNAL_TREAT');
                FND_MESSAGE.Set_Token ('DEAL_NO', Q6_REC.deal_number);
                FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.get);
             End if;

              EXCEPTION
                 when DUP_VAL_ON_INDEX then
                      NULL;
                 when OTHERS then
                      FND_MESSAGE.Set_Name ('XTR','XTR_UNHANDLED_EXCEPTION');
                      FND_MESSAGE.Set_Token ('PROCEDURE','GEN_JOURNALS');
                      FND_MESSAGE.Set_Token ('EVENT','Inserting revaluation journal into table');
                      FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.get);
                      l_ret_value := greatest(l_ret_value,2);
              END;

              End if; -- Fx in SOB currency

           End If;  -- If zero amounts.
	End if;

        <<NEXT_Q6>>

           Fetch Q6 INTO Q6_REC;
        END LOOP;
        Close Q6;

        --------------------------------------------------
        -- Q7 - Generate Journal rows for Hedge Items.
        --------------------------------------------------
        l_prev_rowid := null;
        l_row_id := null;

        Open Q7;
        Fetch Q7 INTO Q7_REC;

        l_prev_rowid := l_row_id;

        IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
           xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Entering Q7 loop.');
        END IF;

        While Q7%FOUND LOOP
           --
           IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
              xtr_debug_pkg.debug ('GEN_JOURNALS: ' ||'Company Code = '|| Q7_REC.company_code);
              xtr_debug_pkg.debug ('GEN_JOURNALS: ' ||'Deal Type = '  || Q7_REC.deal_type);
              xtr_debug_pkg.debug ('GEN_JOURNALS: ' ||'Deal Number = '|| to_char(Q7_REC.deal_number));
              xtr_debug_pkg.debug ('GEN_JOURNALS: ' ||'Transaction Nbr = '|| to_char(Q7_REC.trans_number));
              xtr_debug_pkg.debug ('GEN_JOURNALS: ' ||'Amount Date = '|| to_char(Q7_REC.journal_date,'MM/DD/RRRR'));
              xtr_debug_pkg.debug ('GEN_JOURNALS: ' ||'Currency = '|| Q7_REC.reval_currency);
              xtr_debug_pkg.debug ('GEN_JOURNALS: ' ||'Deal Subtype = '|| Q7_REC.deal_subtype);
              xtr_debug_pkg.debug ('GEN_JOURNALS: ' ||'Product Type = '|| Q7_REC.product_type);
              xtr_debug_pkg.debug ('GEN_JOURNALS: ' ||'Portfolio = '|| Q7_REC.portfolio_code);
              xtr_debug_pkg.debug ('GEN_JOURNALS: ' ||'Amount Type = '|| Q7_REC.amount_type);
              xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Action Code = '|| Q7_REC.action_code);
              xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Revaluation Amount = '|| to_char(Q7_REC.amount));
              xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'CCID = '|| to_char(Q7_REC.ccid));
              xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'DR/CR = '|| Q7_REC.credit_or_debit);
              xtr_debug_pkg.debug ('GEN_JOURNALS: ' || 'Date Type = '|| Q7_REC.date_type);
           END IF;

           If (nvl(Q7_REC.amount,0) = 0) then
              NULL;
           Else
              -- Calculate accounted_dr and accounted_cr amounts.
              BEGIN
                 l_accounted_dr := 0;
                 l_accounted_cr := 0;

                 If (Q7_REC.credit_or_debit = 'DR') then
                    l_accounted_dr := GL_CURRENCY_API.Convert_Amount (
                                                        Q7_REC.reval_currency,
                                                        l_sob_currency,
                                                        Q7_REC.journal_date,
                                                        l_pty_convert_type,
                                                        Q7_REC.amount);
                 Else
                    l_accounted_cr := GL_CURRENCY_API.Convert_Amount (
                                                        Q7_REC.reval_currency,
                                                        l_sob_currency,
                                                        Q7_REC.journal_date,
                                                        l_pty_convert_type,
                                                        Q7_REC.amount);
                 End If;

              EXCEPTION
                 when GL_CURRENCY_API.INVALID_CURRENCY then
                      FND_MESSAGE.Set_Name ('XTR','XTR_2206');
                      FND_MESSAGE.Set_Token ('CURR1',Q7_REC.reval_currency);
                      FND_MESSAGE.Set_Token ('CURR2',l_sob_currency);
                      FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
                      l_ret_value := greatest(l_ret_value,2);
                      Goto NEXT_Q7;

                 when GL_CURRENCY_API.NO_RATE then
                      FND_MESSAGE.Set_Name ('XTR','XTR_2207');
                      FND_MESSAGE.Set_Token ('CURR1',Q7_REC.reval_currency);
                      FND_MESSAGE.Set_Token ('CURR2',l_sob_currency);
                      FND_MESSAGE.Set_Token ('XCHG_DATE',to_char(Q7_REC.journal_date));
                      FND_MESSAGE.Set_Token ('C_TYPE', nvl(l_pty_user_convert_type,l_pty_convert_type));
                      FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.get);
                      l_ret_value := greatest(l_ret_value,2);
                      Goto NEXT_Q7;
              END;
              BEGIN
                 Insert into XTR_JOURNALS
                        (batch_id,
                         company_code,
                         journal_date,
                         orig_journal_date,
                         deal_number,
                         transaction_number,
                         deal_type,
                         deal_subtype,
                         product_type,
                         portfolio_code,
                         debit_amount,
                         credit_amount,
                         code_combination_id,
                         amount_type,
                         created_by,
                         created_on,
                         currency,
                         set_of_books_id,
                         suspense_gl,
                         accounted_dr,
                         accounted_cr,
                         date_type,
                         action_code)
                  Values
                         (Q7_REC.batch_id,
                          Q7_REC.company_code,
                          nvl(Q7_REC.journal_date,to_date('01/01/1997','MM/DD/YYYY')),
                          nvl(Q7_REC.journal_date,to_date('01/01/1997','MM/DD/YYYY')),
                          Q7_REC.deal_number,
                          nvl(Q7_REC.trans_number,999),
                          Q7_REC.deal_type,
                          Q7_REC.deal_subtype,
                          Q7_REC.product_type,
                          Q7_REC.portfolio_code,
                          decode(Q7_REC.credit_or_debit,'DR',Q7_REC.amount,0),
                          decode(Q7_REC.credit_or_debit,'CR',Q7_REC.amount,0),
                          Q7_REC.ccid,
                          Q7_REC.amount_type,
                          G_user,
                          trunc(SYSDATE),
                          decode(Q7_REC.amount_type, 'CCYREAL', Q7_REC.deal_currency,
                                Q7_REC.reval_currency),
                          G_set_of_books_id,
                          l_suspense_gl,
                          l_accounted_dr,
                          l_accounted_cr,
                          Q7_REC.date_type,
                          Q7_REC.action_code);

              EXCEPTION
                 when DUP_VAL_ON_INDEX then
                      NULL;
                 when OTHERS then
                      FND_MESSAGE.Set_Name ('XTR','XTR_UNHANDLED_EXCEPTION');
                      FND_MESSAGE.Set_Token ('PROCEDURE','GEN_JOURNALS');
                      FND_MESSAGE.Set_Token ('EVENT','Inserting revaluation journal into table');
                      FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.get);
                      l_ret_value := greatest(l_ret_value,2);
              END;

           End If;  -- If zero amounts.

           <<NEXT_Q7>>

           Fetch Q7 INTO Q7_REC;
        END LOOP;
        Close Q7;


        ---------------------------------------------------------------------------------------
	-- If entire batch was successful, insert XTR_BATCH_EVENTS to add one more row to
	-- indicate journal batch has been generated.
        ---------------------------------------------------------------------------------------


--1336492        If (nvl(l_error_flag,'N') = 'N') then

        If (nvl(l_ret_value,0) < 2) then

           -- Bug 3805480 begin
           -- Added condition to check for RA batch w/o jrnl entries.
	   -- In such an event, do not create records in xtr_batches and
	   -- xtr_batch_events table for it.

	   If (nvl(in_source_option,'R') = 'J') then
	      l_empty := 0;
	      Open  Entries (in_batch_id);
	      Fetch Entries into l_empty;
	      Close Entries;
	   Else
	      l_empty := 1;
	   End If;

	   -- condition will always be true if RA batch.
	   If (l_empty = 1) then

	   -- Bug 3805480 end.

              Open  EVENT_ID;
              Fetch EVENT_ID into l_event_id;
              Close EVENT_ID;

              BEGIN
                 Insert into XTR_BATCH_EVENTS
                            (batch_event_id,
                             batch_id,
                             event_code,
                             authorized,
                             authorized_by,
                             authorized_on,
                             created_by,
                             creation_date,
                             last_updated_by,
                             last_update_date,
                             last_update_login)
                     values (l_event_id,
                             in_batch_id,
                             'JRNLGN',
                             'N',
                             null,
                             null,
                             fnd_global.user_id,
                             l_sysdate,
                             fnd_global.user_id,
                             l_sysdate,
                             fnd_global.login_id);
              EXCEPTION
                 when OTHERS then
                      FND_MESSAGE.Set_Name ('XTR','XTR_UNHANDLED_EXCEPTION');
                      FND_MESSAGE.Set_Token ('PROCEDURE','GEN_JOURNALS');
                      FND_MESSAGE.Set_Token ('EVENT','Inserting batch event record into table');
                      FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.get);
                      PRT_UNVAL_DEALS;			-- added for 1336492.
                      Rollback;
                      return 2;				-- modified for 1336492.
              END;

              PRT_UNVAL_DEALS;	-- added for 1336492.

              -- Added for Bug 4634182
              If(nvl(in_source_option,'Y') = 'J') then

              OPEN C_NRA_PERIOD_FROM;
              FETCH C_NRA_PERIOD_FROM into l_nra_period_from;
              CLOSE C_NRA_PERIOD_FROM;

                   If l_nra_period_from is not null then

                   Update xtr_batches
                   set period_start = l_nra_period_from
                   where batch_id = in_batch_id;

                   End if;

              End if;
-- End of Bug 4634182

              Commit;
           Else
              PRT_UNVAL_DEALS;	-- added for 1336492.
              Rollback;
	   End If;

           return l_ret_value;	-- modified for 1336492.
        Else
	   PRT_UNVAL_DEALS;
	   Rollback;
	   return l_ret_value;
        End If;

 End GEN_JOURNALS;

--------------------------------------------------------------------------------------------------------------------------
/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Update_Journals							|
|									|
|  DESCRIPTION								|
|	Procedure to delete or reverse journal entries when deals are	|
|	cancelled							|
|  CALLED BY								|
|	Various DB triggers in xtrtrigg.sql				|
|	XTRINFXR.fmb							|
|  PARAMETERS								|
|	l_deal_nos	deal number.		(required)		|
|	l_trans_nos	transaction number.	(required)		|
|	l_deal_type	deal type.		(required)		|
|  HISTORY								|
|									|
|  NOTES								|
|	Possible permetations of the JNL_REVERSAL_IND,			|
|	TRANSFER_TO_EXTERNAL_GL, and CANCELLED_IN_GL fields in		|
|	XTR_JOURNALS Table.						|
|									|
|  Reversal   Transfer to   Cancelled					|
|   Indic     External G/L    in G/L   Description			|
| ---------   ------------  ---------  --------------------------------	|
|    NULL         NULL        NULL     Journal was created but has not	|
|                                      been posted to the G/L.		|
|     C        XX-XXX-XX       Y       A Transaction was cancelled, the	|
|                                      journal has been transferred to	|
|                                      the G/L and it has been reversed	|
|                                      by creation of a reversal entry	|
|                                      in XTR_JOURNALS.			|
    R           NULL        NULL     Reversal entry created as a	|
|                                      result of a deal cancellation or	|
|                                      closure.  Ineligible for journal	|
|                                      clearing.                        |
|     R        XX-XXX-XX      NULL     Reveral entry that has been	|
|                                      transferred to the G/L.		|
 --------------------------------------------------------------------- */

PROCEDURE UPDATE_JOURNALS (l_deal_nos  IN NUMBER,
                           l_trans_nos IN NUMBER,
                           l_deal_type IN VARCHAR2) is
--
  CURSOR SEL_JNL is
		select company_code,
		       journal_date,
		       orig_journal_date,
		       deal_number,
		       transaction_number,
		       deal_type,
		       deal_subtype,
		       amount_type,
		       debit_amount,
		       credit_amount,
		       code_combination_id,
		       comments,
		       jnl_reversal_ind,
		       cancelled_in_gl,
		       created_by,
                       created_on,
                       updated_by,
                       updated_on,
                       product_type,
                       portfolio_code,
		       audit_indicator,
		       currency,
		       transfer_to_external_gl,
		       rowid,
		       suspense_gl,
		       accounted_cr,
		       accounted_dr,
		       set_of_books_id
		from XTR_JOURNALS
		where deal_number=l_deal_nos
		  and transaction_number=l_trans_nos
		  and deal_type=l_deal_type;
--
  CURSOR FIND_USER (fnd_user_id in number) is
		select dealer_code
		from xtr_dealer_codes_v
		where user_id = fnd_user_id;
--
 fnd_user_id	number;
 jnl_rec SEL_JNL%ROWTYPE;
--
 comment_msg	xtr_journals.comments%TYPE;
--
BEGIN
   --  Setup reversal comment message.

   FND_MESSAGE.set_name ('XTR','XTR_2115');
   comment_msg := FND_MESSAGE.get;

   --  Set the dealer code

   fnd_user_id := FND_GLOBAL.USER_ID;
   Open FIND_USER(fnd_user_id);
   Fetch FIND_USER into G_user;
   Close FIND_USER;

   -- Begin Processing.

   Open SEL_JNL;
   Fetch SEL_JNL into jnl_rec;
   While (SEL_JNL%FOUND) LOOP
      If (jnl_rec.TRANSFER_TO_EXTERNAL_GL is null) then
         delete from XTR_journals
         where rowid=jnl_rec.rowid;
      Else
         -- Create reversing journal entry.

         If (jnl_rec.DEBIT_AMOUNT > 0) then
            jnl_rec.CREDIT_AMOUNT := jnl_rec.DEBIT_AMOUNT;
            jnl_rec.DEBIT_AMOUNT := 0;
            jnl_rec.ACCOUNTED_CR := jnl_rec.ACCOUNTED_DR;
            jnl_rec.ACCOUNTED_DR := 0;
         Else
            jnl_rec.DEBIT_AMOUNT := jnl_rec.CREDIT_AMOUNT;
            jnl_rec.CREDIT_AMOUNT := 0;
            jnl_rec.ACCOUNTED_DR := jnl_rec.ACCOUNTED_DR;
            jnl_rec.ACCOUNTED_CR := 0;
         End If;

         INSERT into XTR_JOURNALS
                (COMPANY_CODE,
                 JOURNAL_DATE,
		 ORIG_JOURNAL_DATE,
                 DEAL_NUMBER,
                 TRANSACTION_NUMBER,
                 DEAL_TYPE,
                 DEAL_SUBTYPE,
                 AMOUNT_TYPE,
                 DEBIT_AMOUNT,
                 CREDIT_AMOUNT,
                 CODE_COMBINATION_ID,
                 COMMENTS,
                 CREATED_BY,
                 CREATED_ON,
                 PRODUCT_TYPE,
                 PORTFOLIO_CODE,
                 CURRENCY,
                 SET_OF_BOOKS_ID,
                 SUSPENSE_GL,
                 ACCOUNTED_CR,
                 ACCOUNTED_DR,
                 JNL_REVERSAL_IND)
          Values
                (jnl_rec.COMPANY_CODE,
                 jnl_rec.JOURNAL_DATE,
		 jnl_rec.ORIG_JOURNAL_DATE,
                 jnl_rec.DEAL_NUMBER,
                 jnl_rec.TRANSACTION_NUMBER,
                 jnl_rec.DEAL_TYPE,
                 jnl_rec.DEAL_SUBTYPE,
                 jnl_rec.AMOUNT_TYPE,
                 jnl_rec.DEBIT_AMOUNT,
                 jnl_rec.CREDIT_AMOUNT,
                 jnl_rec.CODE_COMBINATION_ID,
                 comment_msg,
                 G_user,
                 SYSDATE,
                 jnl_rec.PRODUCT_TYPE,
                 jnl_rec.PORTFOLIO_CODE,
                 jnl_rec.CURRENCY,
                 jnl_rec.SET_OF_BOOKS_ID,
                 jnl_rec.SUSPENSE_GL,
                 jnl_rec.ACCOUNTED_CR,
                 jnl_rec.ACCOUNTED_DR,
                 'R');

          If (SQL%FOUND) then
             UPDATE XTR_JOURNALS
                     set JNL_REVERSAL_IND = 'C',
                         CANCELLED_IN_GL  = 'Y'
                     where ROWID = jnl_rec.ROWID;
          End If;
       End If;

       Fetch SEL_JNL into jnl_rec;
   End LOOP;
   Close SEL_JNL;

EXCEPTION
    WHEN OTHERS THEN
         RAISE;
END UPDATE_JOURNALS;





/* -----------------------------------------------------------------------------
|  PUBLIC PROCEDURE								|
|	Journals								|
|										|
|  DESCRIPTION									|
|	This procedure is the main entry into the journal process, which	|
|	includes generation of revaluation/accrual related journals, 		|
|	non-revaluation/non-accrual related journals, and transfer of generated	|
|	journal batches.  							|
|  CALLED BY									|
|	SRS program executable XTRJRNAL and the journal form XTRACJNL.		|
|  PARAMETERS									|
|	errbuf			standard error text	(output, optional)	|
|	retcode			standard error code	(output, optional)	|
|	p_source_option		non-RA or RA related	(input, required)	|
|		'J' -- Non-Revaluation/Non-Accrual related.			|
|		null - Revaluation/Accrual related.				|
|	p_company_code		company code.		(input, optional)	|
|	p_batch_id_from		Batch ID range		(input, optional)	|
|	p_batch_id_to		Batch ID range		(input, optional)	|
|	p_cutoff_date		Batch cutoff date	(input, optional)	|
|	p_dummy_date		dummy used for SRS validation (input)		|
|	p_processing_option	generate/xfer/genxfer	(input, required)	|
|	p_closed_periods	handling of journals in closed periods during	|
|					transfer.	(input, optional)	|
|		'CLOSED' -- Uses closed period, no change.			|
|		'NXTOPEN' - Transfer with next GL open period start date.	|
|		null ------ Uses company parameter setting.			|
|	p_incl_transferred	include xfer batches	(input, optional)	|
|  HISTORY									|
|	06/21/2002	eklau	Created						|
 ----------------------------------------------------------------------------- */
PROCEDURE Journals
		(errbuf			OUT NOCOPY VARCHAR2,
		 retcode		OUT NOCOPY NUMBER,
		 p_source_option	IN  VARCHAR2,
		 p_company_code		IN  VARCHAR2,
		 p_batch_id_from     	IN  NUMBER,
		 p_batch_id_to		IN  NUMBER,
		 p_cutoff_date		IN  VARCHAR2,
		 p_dummy_date		IN  VARCHAR2,
		 p_processing_option	IN  VARCHAR2,
		 p_dummy_proc_opt	IN  VARCHAR2,
		 p_closed_periods	IN  VARCHAR2,
		 p_incl_transferred	IN  VARCHAR2,
                 p_multiple_acct        IN VARCHAR2 )	IS -- Modified Bug 4639287

--
   l_errbuf		VARCHAR2(255)	:= NULL;
   l_retcode		NUMBER		:= 0;
   l_sub_errbuf		VARCHAR2(255)	:= NULL;
   l_sub_retcode	NUMBER		:= 0;
   l_closed_param_code	XTR_COMPANY_PARAMETERS.parameter_value_code%TYPE;
   l_company_code	XTR_PARTY_INFO.party_code%TYPE;
   l_sob_id		XTR_PARTY_INFO.set_of_books_id%TYPE;
   l_cutoff_date	DATE := NULL;
   l_next_open_start	DATE := NULL;
   l_next_bid		NUMBER := NULL;

   Cursor USER_COMPANIES is
   	Select party_code, set_of_books_id
   	  from xtr_parties_v
   	 where party_type = 'C'
   	   and (party_code = nvl(p_company_code, party_code));

   Cursor BATCHES_BY_BID_RANGE (l_company_code IN VARCHAR2) is
   	Select batch_id
   	  from xtr_batches
   	 where batch_id between nvl(p_batch_id_from, batch_id) and nvl(p_batch_id_to, batch_id)
   	   and batch_id in (Select BA.batch_id
   	                      from xtr_batches BA,
   	                           xtr_batch_events BE
   	                     where BA.batch_id = BE.batch_id
   	                       and BE.event_code = 'JRNLGN'
   	                       and BA.company_code = l_company_code
   	                       and BA.upgrade_batch in ('I','N')
   	                       and ((p_source_option = 'J' and BA.batch_type = 'J') or
   	                            (p_source_option is null and BA.batch_type is null))
   	                       and ((nvl(p_incl_transferred,'N') = 'N' and BA.gl_group_id is null) or
   	                            (nvl(p_incl_transferred,'N') = 'Y')))
   	order by period_end, batch_id asc;

   Cursor BATCHES_BY_DATE (l_company_code IN VARCHAR2, l_cutoff_date IN DATE) is
   	Select batch_id
   	  from xtr_batches
   	 where period_end <= nvl(l_cutoff_date, sysdate)
   	   and batch_id in (Select BA.batch_id
   	                      from xtr_batches BA,
   	                           xtr_batch_events BE
   	                     where BA.batch_id = BE.batch_id
   	                       and BE.event_code = 'JRNLGN'
   	                       and BA.company_code = l_company_code
   	                       and BA.upgrade_batch in ('I','N')
   	                       and ((p_source_option = 'J' and BA.batch_type = 'J') or
   	                            (p_source_option is null and BA.batch_type is null))
   	                       and ((nvl(p_incl_transferred,'N') = 'N' and BA.gl_group_id is null) or
   	                            (nvl(p_incl_transferred,'N') = 'Y')))
	order by period_end, batch_id asc;

  -- Added below cursors for Bug 4639287
  cursor c_max_journal_date is
  select max(journal_date)
	from xtr_journals
	where batch_id = l_next_bid;

  cursor c_min_journal_date is
  select min(journal_date)
	from xtr_journals
	where batch_id = l_next_bid;

  cursor c_acctg_period(p_journal_date DATE) is
  select period_name
	from gl_periods per,
	     gl_sets_of_books sob,
	     xtr_parties_v pty
	where pty.party_code = l_company_code
	and sob.set_of_books_id = pty.set_of_books_id
	and sob.period_set_name = per.period_set_name
	and sob.accounted_period_type = per.period_type
	and p_journal_date between per.start_date and per.end_date
	and per.adjustment_period_flag = 'N';

l_max_journal_date DATE;
l_min_journal_date DATE;
l_min_period_name gl_periods.period_name%TYPE;
l_max_period_name gl_periods.period_name%TYPE;


BEGIN

   IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
      xtr_debug_pkg.debug ('>> PROCEDURE Journals.');
   END IF;

   l_cutoff_date := FND_DATE.Canonical_To_Date(p_cutoff_date);

   ----------------------  GENERATE JOURNAL BATCHES  -----------------------------

   If (p_processing_option in ('GENERATE','GENXFER')) then

      -- Request issued to generate or generate and transfer journals.

      If (p_source_option = 'J') then

         -- Generate journals for Non-Revaluation/Non-Accrual related
         -- data occuring on or before the cutoff date.

         If (p_cutoff_date is null) then

            -- Invalid combination.
            -- Cutoff date not provided for a Non-Revaluation/Non-Accrual
            -- related journal generation request.

            FND_MESSAGE.Set_Name ('XTR','XTR_NO_CUTOFF_DATE');
            FND_MESSAGE.Set_Token ('COMPANY_CODE', l_company_code);
            FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
            l_retcode := greatest(l_retcode,2);

         Elsif (p_batch_id_from is not null and p_batch_id_to is not null) then

            -- Invalid combination for Non-Revaluation/Non-Accrual
            -- related journal generation.
            -- Cannot already have a specific batch id range for a
            -- journal only batch that is about to be created.

            FND_MESSAGE.Set_Name ('XTR','XTR_INVALID_PARAMETER_COMBO');
            FND_MESSAGE.Set_Token ('BID_FROM', to_char(p_batch_id_from));
            FND_MESSAGE.Set_Token ('BID_TO', to_char(p_batch_id_to));
            FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
            l_retcode := greatest(l_retcode,2);

         Elsif (p_cutoff_date is not null) then

            Open  USER_COMPANIES;
            Fetch USER_COMPANIES into l_company_code, l_sob_id;
            While USER_COMPANIES%FOUND
            Loop
               l_sub_retcode := 0;

               FND_MESSAGE.Set_Name ('XTR','XTR_START_GEN_JRNL_BY_DATE');
               FND_MESSAGE.Set_Token ('COMPANY_CODE', l_company_code);
               FND_MESSAGE.Set_Token ('CUTOFF_DATE', p_cutoff_date);
               FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);

               Do_Journal_Process
                        (l_sub_errbuf,
                         l_sub_retcode,
                         p_source_option,
                         l_company_code,
                         to_number(null),
                         to_number(null),
                         l_cutoff_date);

               l_retcode := greatest(l_retcode,l_sub_retcode);

               FND_MESSAGE.Set_Name ('XTR','XTR_END_GEN_JRNL_BY_DATE');
               FND_MESSAGE.Set_Token ('COMPANY_CODE', l_company_code);
               FND_MESSAGE.Set_Token ('CUTOFF_DATE', p_cutoff_date);
               FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);

               Fetch USER_COMPANIES into l_company_code, l_sob_id;
            End Loop;
            Close USER_COMPANIES;
         End If;     -- existence of cutoff date

      Elsif (p_source_option is null) then

         -- Generate journals for Revaluation/Accrual related data
         -- from authorized batch(es) between the given batch id range.
         -- If batch range not provided, will generate journals for all
         -- authorized accrual batches for the given company.

         Open  USER_COMPANIES;
         Fetch USER_COMPANIES into l_company_code, l_sob_id;
         While USER_COMPANIES%FOUND
         Loop
            l_sub_retcode := 0;

            FND_MESSAGE.Set_Name ('XTR','XTR_START_GEN_JRNL_BY_BID');
            FND_MESSAGE.Set_Token ('COMPANY_CODE', l_company_code);
            FND_MESSAGE.Set_Token ('BID_FROM', to_char(p_batch_id_from));
            FND_MESSAGE.Set_Token ('BID_TO', to_char(p_batch_id_to));
            FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);

            Do_Journal_Process
                        (l_sub_errbuf,
                         l_sub_retcode,
                         p_source_option,
                         l_company_code,
                         p_batch_id_from,
                         p_batch_id_to,
                         to_date(null));

            l_retcode := greatest(l_retcode,l_sub_retcode);

            FND_MESSAGE.Set_Name ('XTR','XTR_END_GEN_JRNL_BY_BID');
            FND_MESSAGE.Set_Token ('COMPANY_CODE', l_company_code);
            FND_MESSAGE.Set_Token ('BID_FROM', to_char(p_batch_id_from));
            FND_MESSAGE.Set_Token ('BID_TO', to_char(p_batch_id_to));
            FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);

            Fetch USER_COMPANIES into l_company_code, l_sob_id;
         End Loop;
         Close USER_COMPANIES;
      End If;  -- source option.
   End If;     -- processing option.


   --------------------------  TRANSFER JOURNAL BATCHES  ---------------------------------


   If (p_processing_option in ('TRANSFER','GENXFER')) then

      -- Transferring of the previously or just processed batch(es) has been requested.

      Open  USER_COMPANIES;
      Fetch USER_COMPANIES into l_company_code, l_sob_id;
      While USER_COMPANIES%FOUND
      Loop
         -- Start journal transfer process for company.

         FND_MESSAGE.Set_Name ('XTR','XTR_START_XFER_JRNL');
         FND_MESSAGE.Set_Token ('COMPANY_CODE', l_company_code);
         FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);

         -- If no specific closed period posting denoted, use per company parameter.
         -- Otherwise, use the user overridden value.

         l_closed_param_code := null;
         If (p_closed_periods is null) then
            l_closed_param_code := GET_CLOSED_PERIOD_PARAM (l_company_code);
         Else
            l_closed_param_code := p_closed_periods;
         End If;


         -- Check for existence of a specific cutoff date first.
         -- If it exists, implies that Non-Reval/Non-Accrual journal
         -- batch(es) which have not been transferred have been
         -- requested for processing via the SRS program XTRJNLCA.
         --
         -- If cutoff date is not present, we will assume that a
         -- range of batch ids have been entered and one of two
         -- following scenerios has occurred:
         --
         -- 1.  Processing of a specific batch has been requested
         --     via the Journals form.  Batch can either be
         --     Non-Reval/Non-Accrual or Reval/Accrual related.
         --     In addition, it can be a previously transferred
         --     batch being re-transferred.  The p_source_option will
         --     be expected to properly reflect the batch source
         --     when the submission is executed.
         -- 2.  Processing of a specific batch range has been requested
         --     via the SRS program XTRJRNAL.  Reval/Accrual related batch(es)
         --     that have not been transferred for the specified batch range
         --     have been requested for processing.
         --
         -- If neither a cutoff date nor a range of batch ids are provided,
         -- then the routine will process all journal batch(es) for the specified
         -- companies which meets the criteria as determined by the parameters
         -- p_source_option and p_incl_transferred.

         If (l_cutoff_date is not null) then
            Open BATCHES_BY_DATE (l_company_code, l_cutoff_date);
         Else
            Open BATCHES_BY_BID_RANGE (l_company_code);
         End If;

         Loop
            If (l_cutoff_date is not null) then
               Fetch BATCHES_BY_DATE into l_next_bid;
               Exit  when BATCHES_BY_DATE%NOTFOUND;
            Else
               Fetch BATCHES_BY_BID_RANGE into l_next_bid;
               Exit  when BATCHES_BY_BID_RANGE%NOTFOUND;
            End If;

            l_sub_retcode := 0;

            -- Added below code for Bug 4639287
           If (p_multiple_acct = 'DONTALLOW') then
                open c_max_journal_date;
    	        fetch c_max_journal_date into l_max_journal_date;
                close c_max_journal_date;

                open c_min_journal_date;
        	    fetch c_min_journal_date into l_min_journal_date;
                close c_min_journal_date;

                open c_acctg_period(l_min_journal_date);
                fetch c_acctg_period into l_min_period_name;
  	            close c_acctg_period;

                open c_acctg_period(l_max_journal_date);
                fetch c_acctg_period into l_max_period_name;
  	            close c_acctg_period;

                If (nvl(l_min_period_name,'$$$') <> nvl(l_max_period_name,'@@@'))  then
                    l_sub_retcode := 1;
                    FND_MESSAGE.Set_Name ('XTR','XTR_START_XFER_JRNL_BATCH');
                    FND_MESSAGE.Set_Token ('COMPANY_CODE', l_company_code);
                    FND_MESSAGE.Set_Token ('BID', to_char(l_next_bid));
                    FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
                    FND_MESSAGE.Set_Name ('XTR','XTR_CONC_DIFF_ACCTG');
                    FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
                    FND_MESSAGE.Set_Name ('XTR','XTR_END_XFER_JRNL_BATCH');
                    FND_MESSAGE.Set_Token ('COMPANY_CODE', l_company_code);
                    FND_MESSAGE.Set_Token ('BID', to_char(l_next_bid));
                     FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
               l_retcode := greatest(l_retcode, l_sub_retcode);
                Else

                    XTR_ORACLE_FIN_INTERFACES_P.Transfer_Jnls
  					    (l_sub_errbuf,
	        	   	 	     l_sub_retcode,
        		   	 	    l_company_code,
        	    		 	 l_next_bid,
				 	    l_closed_param_code );     -- bug 4504734

            l_retcode := greatest(l_retcode, l_sub_retcode);
            End If;
         Else

            XTR_ORACLE_FIN_INTERFACES_P.Transfer_Jnls
  					(l_sub_errbuf,
	        	   	 	 l_sub_retcode,
        		   	 	 l_company_code,
        	    		 	 l_next_bid,
				 	 l_closed_param_code);  --bug 4504734

            l_retcode := greatest(l_retcode, l_sub_retcode);
         End if; -- End Bug 4639287

         End Loop;

         If (l_cutoff_date is not null) then
            Close BATCHES_BY_DATE;
         Else
            Close BATCHES_BY_BID_RANGE;
         End If;

         FND_MESSAGE.Set_Name ('XTR','XTR_END_XFER_JRNL');
         FND_MESSAGE.Set_Token ('COMPANY_CODE', l_company_code);
         FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);

         Fetch USER_COMPANIES into l_company_code, l_sob_id;
      End Loop;
   End If;

   If (l_retcode = 2) then
      retcode := -1;
   Else
      retcode := l_retcode;
   End If;

End JOURNALS;

-- Added override procedure Bug 4639287
PROCEDURE JOURNALS
		(errbuf			OUT NOCOPY VARCHAR2,
		 retcode		OUT NOCOPY NUMBER,
		 p_source_option	IN  VARCHAR2,
		 p_company_code		IN  VARCHAR2,
		 p_batch_id_from	IN  NUMBER,
		 p_batch_id_to		IN  NUMBER,
		 p_cutoff_date		IN  VARCHAR2,
		 p_dummy_date		IN  VARCHAR2,
		 p_processing_option	IN  VARCHAR2,
		 p_dummy_proc_opt	IN  VARCHAR2,
		 p_closed_periods	IN  VARCHAR2,
         p_incl_transferred	IN  VARCHAR2) IS

BEGIN


Journals(errbuf,
		 retcode,
		 p_source_option,
		 p_company_code	,
		 p_batch_id_from,
		 p_batch_id_to,
		 p_cutoff_date,
		 p_dummy_date,
		 p_processing_option,
		 p_dummy_proc_opt,
		 p_closed_periods,
         	 p_incl_transferred,
		 'ALLOW');

END JOURNALS;

--------------------------------------------------------------------------------------------------------------------------
end XTR_JOURNAL_PROCESS_P;

/
