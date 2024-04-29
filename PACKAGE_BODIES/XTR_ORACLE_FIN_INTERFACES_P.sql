--------------------------------------------------------
--  DDL for Package Body XTR_ORACLE_FIN_INTERFACES_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_ORACLE_FIN_INTERFACES_P" as
/* $Header: xtrdistb.pls 120.4.12010000.3 2008/08/23 14:27:22 srsampat ship $ */

------------------------------------------------------------------------------------------------------
PROCEDURE UPDATE_DR(in_company_code	IN VARCHAR2,
		    in_batch_id         IN NUMBER,
                    in_jnl_date		IN DATE,
                    in_ccid		IN NUMBER,
                    in_gl_link_id	IN NUMBER,
                    in_ccy		IN VARCHAR2,
                    in_alt_jrnl_date	IN DATE) is

Begin

   /* Private procedure to update debit journal rows within the given batch id.      */
   /* Updated columns are the transferred date and the link id used by the drilldown */
   /* feature in GL which XTR does not have currently.                               */

   Update XTR_JOURNALS
      Set TRANSFER_TO_EXTERNAL_GL = trunc(sysdate),
          gl_sl_link_id = in_gl_link_id,
          alt_journal_date = in_alt_jrnl_date
    where batch_id = in_batch_id
      and journal_date = in_jnl_date
      and code_combination_id = in_ccid
      and currency = in_ccy
      and (nvl(debit_amount,0) <> 0 or nvl(accounted_dr,0) <> 0);

End UPDATE_DR;
--------------------------------------------------------------------------------------------------------
PROCEDURE UPDATE_CR(in_company_code	IN VARCHAR2,
		    in_batch_id         IN NUMBER,
                    in_jnl_date		IN DATE,
                    in_ccid		IN NUMBER,
                    in_gl_link_id	IN NUMBER,
                    in_ccy		IN VARCHAR2,
                    in_alt_jrnl_date	IN VARCHAR2) is
Begin

   /* Private procedure to update credit journal rows within the given batch id. */

   Update XTR_JOURNALS
      Set TRANSFER_TO_EXTERNAL_GL = trunc(sysdate),
          gl_sl_link_id = in_gl_link_id,
          alt_journal_date = in_alt_jrnl_date
    where batch_id = in_batch_id
      and JOURNAL_DATE = in_jnl_date
      and code_combination_id = in_ccid
      and currency = in_ccy
      and (nvl(credit_amount,0) <> 0 or nvl(accounted_cr,0) <> 0);

End UPDATE_CR;

/* ---------------------------------------------------------------------
|  PRIVATE FUNCTION							|
|	GET_NEXT_OPEN_START_DATE
|
|
|	Bug 4504734
|							|
|  DESCRIPTION								|
|	Function which will return the date of  the next open period	|
|	provided for the given set of books ID.
|
|									|
|  CALLED BY								|
|	Procedure TRANSFER_JNLS						|
|									|
|  PARAMETERS								|
|	in_sob_id	sob id		(in, required)			|
|	in_company_name	company name	(in, optional for msg use only)	|
|	in_jrnl_date	date		(in, required)			|
|									|
|  HISTORY								|
|       7/12/2006	eggarwa		Created.			|
|----------------------------------------------------------------------*/

FUNCTION GET_NEXT_OPEN_START_DATE (in_sob_id in number,in_company
varchar2,in_jrnl_date	IN DATE) RETURN DATE IS

l_next_start	DATE := to_date(null);

Begin

    Select min(start_date) into l_next_start
    from gl_period_statuses
    where application_id = 101
    and set_of_books_id = in_sob_id
    and closing_status in ('O','F')
    and adjustment_period_flag = 'N'
    and start_date >= in_jrnl_date;


    Return (l_next_start);
Exception

    When others then
	FND_MESSAGE.Set_Name ('XTR','XTR_NO_NEXT_OPEN_PERIOD');
	FND_MESSAGE.Set_Token ('COMPANY_CODE', in_company);
	FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
	Return to_date(null);

End GET_NEXT_OPEN_START_DATE;



/* ---------------------------------------------------------------------
|  PRIVATE FUNCTION							|
|	In_Open_Period							|
|									|
|  DESCRIPTION								|
|	Function which will return T/F value after determining if date	|
|	provided falls within an OPEN or FUTURE ENTRY journal period	|
|	for the given set of books ID.					|
|									|
|  CALLED BY								|
|	Procedure TRANSFER_JNLS						|
|									|
|  PARAMETERS								|
|	in_sob_id	sob id		(in, required)			|
|	in_sob_name	sob name	(in, optional for msg use only)	|
|	in_jrnl_date	date		(in, required)			|
|									|
|  HISTORY								|
|       6/26/2002	eklau		Created.			|
|----------------------------------------------------------------------*/

FUNCTION IN_OPEN_PERIOD (in_sob_id	IN NUMBER,
                         in_sob_name	IN VARCHAR2,
                         in_jrnl_date	IN DATE)  RETURN BOOLEAN IS
l_temp	number;

Begin
   Select 1 into l_temp
     from gl_period_statuses
    where application_id = 101
      and set_of_books_id = in_sob_id
      and adjustment_period_flag = 'N'
      and closing_status in ('O','F')
      and in_jrnl_date between start_date and end_date;

  If (SQL%FOUND) then
     return TRUE;
  Else
     return FALSE;
  End If;

Exception
   When NO_DATA_FOUND then
      return FALSE;
   When OTHERS then
      FND_MESSAGE.Set_Name ('XTR','XTR_CHK_JRNL_DATE_ERROR');
      FND_MESSAGE.Set_Token ('JNL_DATE', to_char(in_jrnl_date));
      FND_MESSAGE.Set_Token ('SOB_NAME', in_sob_name);
      FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
      return FALSE;
End;


/* ---------------------------------------------------------------------
|  PUBLIC FUNCTION							|
|	Balance_Batch							|
|									|
|  DESCRIPTION								|
|	Function which will return T/F value after determining if	|
|	batch is balanced, based on the sob cr/dr amounts.		|
|	   T = Balanced batch.						|
|	   F = Unbalanced batch.					|
|  CALLED BY								|
|	Procedure TRANSFER_JNLS						|
|	Form XTRACJNL							|
|									|
|  PARAMETERS								|
|	in_batch_id	batch id	(in, required)			|
|									|
|  HISTORY								|
|       6/26/2002	eklau		Created.			|
|----------------------------------------------------------------------*/

FUNCTION BALANCE_BATCH (in_batch_id	IN NUMBER)  RETURN BOOLEAN IS

   l_dummy	varchar2(1) := null;

    /* Bug 7233054 . Fixing rounding differences if any by adjusting the credit or debit
     amounts . If Allow Unbalanced Journals is set to No , and if there is rounding difference
     of .01  , then adjust credit/debit amounts to make it balanced */

   l_journaldate Date := null;
   l_diff number := null;
   l_rowid VARCHAR2(2000) := null;
   l_allow_unbal_jrnl varchar2(1) := null ;

   Cursor CHK_ALLOW_UNBAL_JRNL is
   Select
   PARAMETER_VALUE_CODE
   FROM XTR_COMPANY_PARAMETERS WHERE
   COMPANY_CODE in (Select distinct company_code from xtr_journals
   where batch_id = in_batch_id)
   and parameter_code = 'ACCNT_UNBAL';

   Cursor UPD_CREDIT(l_jrnl_date date) is
   Select rowid from xtr_journals
   Where batch_id = in_batch_id
   and journal_date = l_jrnl_date and nvl(accounted_cr,0) <> 0
   and accounted_cr = (Select min(accounted_cr) from xtr_journals
   Where batch_id = in_batch_id
   and journal_date = l_jrnl_date and nvl(accounted_cr,0) <> 0 );


   Cursor UPD_DEBIT(l_jrnl_date date) is
   Select rowid from xtr_journals
   Where batch_id = in_batch_id
   and journal_date = l_jrnl_date and nvl(accounted_dr,0) <> 0
   and accounted_dr = (Select min(accounted_dr) from xtr_journals
   Where batch_id = in_batch_id
   and journal_date = l_jrnl_date and nvl(accounted_dr,0) <> 0 );


   Cursor CHK_DIFF is
   Select journal_date,
   sum(nvl(accounted_dr,0)) - sum(nvl(accounted_cr,0)) difference
   From XTR_JOURNALS
   Where batch_id = in_batch_id
   Group By journal_date
   having sum(nvl(debit_amount,0)) = sum(nvl(credit_amount,0));

   -- Bug 7233054  end

   Cursor BALANCE is
   Select null
     From DUAL
    Where exists
          (Select null
             From XTR_JOURNALS
            Where batch_id = in_batch_id
            Group By journal_date
            Having sum(nvl(accounted_dr,0)) <> sum(nvl(accounted_cr,0)));

Begin
   -- Bug 7233054 start
   Open CHK_ALLOW_UNBAL_JRNL ;
   Fetch CHK_ALLOW_UNBAL_JRNL into l_allow_unbal_jrnl ;
   Close CHK_ALLOW_UNBAL_JRNL;
   If(l_allow_unbal_jrnl = 'N') then
   Open CHK_DIFF ;
   loop
   Fetch CHK_DIFF into l_journaldate,l_diff;
   exit when CHK_DIFF%notfound;
   if (abs(l_diff) = .01 ) then
     if (l_diff < 0 ) then
         Open  UPD_DEBIT(l_journaldate);
         fetch UPD_DEBIT into l_rowid;
         close UPD_DEBIT;
     	 update xtr_journals set accounted_dr=accounted_dr+.01
         where rowid = l_rowid;
         commit;
     else
          Open  UPD_CREDIT(l_journaldate);
          fetch UPD_CREDIT into l_rowid;
          close UPD_CREDIT;
     	  update xtr_journals set accounted_cr=accounted_cr+.01
          where rowid = l_rowid;
          commit;
      end if;
   end if;
   end loop;
   close CHK_DIFF;
   end if;
    -- Bug 7233054 End
   Open  BALANCE;
   Fetch BALANCE into l_dummy;

   If (BALANCE%NOTFOUND) then
      Close BALANCE;
      return TRUE;
   Else
      Close BALANCE;
      return FALSE;
   End If;

Exception
   When OTHERS then
      If (BALANCE%ISOPEN) then
         Close BALANCE;
      End If;
      return FALSE;
End;


/* ---------------------------------------------------------------------
|  PUBLIC FUNCTION							|
|	Get_Unbalance_Param						|
|									|
|  DESCRIPTION								|
|	Function which will return the setting of the company parameter	|
|	'Accounting - Allow Unbalanced Journal Transfer.'		|
|	   Y = Allow transfer.						|
|	   N = Do not allow transfer.					|
|	   null = default as applicable by calling routine.		|
|  CALLED BY								|
|	Procedure TRANSFER_JNLS						|
|	Form XTRACJNL							|
|									|
|  PARAMETERS								|
|	in_company	company_code	(in, required)			|
|									|
|  HISTORY								|
|       6/26/2002	eklau		Created.			|
|----------------------------------------------------------------------*/

FUNCTION GET_UNBALANCE_PARAM (in_company IN VARCHAR2)  RETURN VARCHAR2 IS

   l_param_code	XTR_COMPANY_PARAMETERS.parameter_value_code%TYPE := 'N';

    Cursor UNBAL_PARAM is
   Select parameter_value_code
     from XTR_COMPANY_PARAMETERS
    where company_code = in_company
      and parameter_code = 'ACCNT_UNBAL';
--

Begin
   Open  UNBAL_PARAM;
   Fetch UNBAL_PARAM into l_param_code;
   Close UNBAL_PARAM;

   return (l_param_code);

Exception
   When OTHERS then
      return (l_param_code);
End;


/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Transfer_Jnls							|
|									|
|  DESCRIPTION								|
|	Procedure which will transfer/re-transfer the given batch id 	|
|	from the XTR_JOURNALS table to the GL_INTERFACE table.		|
|									|
|  CALLED BY								|
|	Procedure XTR_JOURNAL_PROCESS_P.Journals.			|
|									|
|  PARAMETERS								|
|	in_company_code		company code		(in, required)	|
|	in_batch_id		batch id		(in, required)	|
|	in_closed_periods	closed per param	(in, optional)	|
|	   CLOSED  - No change, post to closed period.			|
|	   NXTOPEN - Change journal date to start date of next open GL	|
|		     period.						|
|	   null  --- Unable to locate the company param setting.	|
|	             If journals in closed periods are found, transfer	|
|	             transfer of batch will be aborted.			|
|									|
|  HISTORY
|     Bug 4504734  Removed parameter in_next_open_start         	|
|----------------------------------------------------------------------*/

PROCEDURE TRANSFER_JNLS(
			errbuff			OUT NOCOPY VARCHAR2,
			retcode			OUT NOCOPY NUMBER,
			in_company_code		IN  VARCHAR2,
			in_batch_id             IN  NUMBER,
			in_closed_periods	IN  VARCHAR2) IS
--
--  Public procedure which will create Journal Records in the
--  Oracle Financials GL_INTERFACE Table
--

l_set_of_books  gl_sets_of_books.set_of_books_id%TYPE	:= to_number(NULL);
l_trx_param     xtr_company_parameters.parameter_value_code%TYPE;
l_source_name	gl_je_sources.user_je_source_name%TYPE;
l_category_name	gl_je_categories.user_je_category_name%TYPE;
l_xchange_type	gl_daily_conversion_types.user_conversion_type%TYPE;
l_gl_link_id	XTR_JOURNALS.gl_sl_link_id%TYPE;
l_gl_group_id   GL_INTERFACE.group_id%TYPE;  -- add to record group id when tranfer
p_company_code  XTR_PARTY_INFO.party_code%TYPE;
l_rowid		VARCHAR2(30);

l_bal_flag		XTR_COMPANY_PARAMETERS.parameter_value_code%TYPE := NULL;
l_ok_to_xfer		BOOLEAN := FALSE;
l_sob_name		GL_SETS_OF_BOOKS.name%TYPE := NULL;
l_journal_date		DATE := to_date(null);
l_next_open_start       DATE := to_date(null);

--
cursor SOB_ID is
	select PTY.set_of_books_id, SOB.name
	from  XTR_PARTIES_V     PTY,
	      GL_SETS_OF_BOOKS  SOB
	where PTY.set_of_books_id = SOB.set_of_books_id
	  and PTY.party_code = p_company_code;
--
cursor TRX_PARAM is
	select parameter_value_code
        from XTR_COMPANY_PARAMETERS
	where company_code = p_company_code
        and parameter_code = 'ACCNT_JNTRM';-- determine the transfer method: SUMMARY or DETAIL

cursor JNL_SUMMARY is
	select	null				row_id,
		batch_id			batch_id,
		journal_date			journal_date,
		code_combination_id		ccid,
		currency			currency,
		sum(nvl(debit_amount,0)) 	debit,
		0 				credit,
		sum(nvl(accounted_dr,0)) 	acct_dr,
		0 				acct_cr,
                to_number(null)			trans_number,
                null				date_type,
                to_number(null)			deal_number,
                null				amount_type,
                null				action_code,
                null				deal_type,
                null				deal_subtype,
                null				product_type,
                null				portfolio_code
	from  XTR_JOURNALS
	where batch_id = G_batch_id
	  and (nvl(debit_amount,0) <> 0 or nvl(accounted_dr,0) <> 0)
	group by batch_id, journal_date, code_combination_id, currency
	UNION
	select	null				row_id,
		batch_id			batch_id,
		journal_date			journal_date,
		code_combination_id		ccid,
		currency			currency,
		0 				debit,
		sum(nvl(credit_amount,0)) 	credit,
		0  				acct_dr,
		sum(nvl(accounted_cr,0))  	acct_cr,
                to_number(null)			trans_number,
                null				date_type,
                to_number(null)			deal_number,
                null				amount_type,
                null				action_code,
                null				deal_type,
                null				deal_subtype,
                null				product_type,
                null				portfolio_code
	from XTR_JOURNALS
	where batch_id = G_batch_id
	and (nvl(credit_amount,0) <> 0 or nvl(accounted_cr,0) <> 0)
	group by batch_id, journal_date, code_combination_id, currency;
--
cursor JNL_DETAIL is
        select  rowid			row_id,
		batch_id		batch_id,
                journal_date		journal_date,
                code_combination_id	ccid,
                currency		currency,
                (nvl(debit_amount,0))	debit,
                nvl(credit_amount,0)	credit,
                (nvl(accounted_dr,0))	acct_dr,
                nvl(accounted_cr,0)	acct_cr,
                transaction_number	trans_number,
                date_type		date_type,
                deal_number		deal_number,
                amount_type		amount_type,
                action_code		action_code,
                deal_type		deal_type,
                deal_subtype		deal_subtype,
                product_type		product_type,
                portfolio_code		portfolio_code
        from XTR_JOURNALS
        where batch_id = G_batch_id
        and (nvl(debit_amount,0) <> 0 or nvl(accounted_dr,0) <> 0 or nvl(credit_amount,0) <> 0 or nvl(accounted_cr,0) <> 0);
--
JNL_REC		JNL_DETAIL%ROWTYPE;
--
cursor SOURCE_NAME is
	SELECT user_je_source_name
	FROM gl_je_sources
	WHERE je_source_name = 'Treasury';
--
cursor CATEGORY_NAME is
	select user_je_category_name
	from gl_je_categories
	where je_category_name = 'Treasury';
--
cursor EXCHANGE_TYPE is
	select user_conversion_type
	from gl_daily_conversion_types
	where conversion_type = (select conversion_type
				 from xtr_parties_v
				 where party_code = p_company_code);
--
cursor GL_GROUP_ID is
	select gl_interface_control_s.nextval
	  from dual;
--

BEGIN

SAVEPOINT sp_transfer;

   -- return code: 0 - success, 1 - warning, 2 - error.
   retcode := 0;

   p_company_code := Upper(in_company_code);
   G_batch_id     := in_batch_id;

   FND_MESSAGE.Set_Name ('XTR','XTR_START_XFER_JRNL_BATCH');
   FND_MESSAGE.Set_Token ('COMPANY_CODE', p_company_code);
   FND_MESSAGE.Set_Token ('BID', to_char(in_batch_id));
   FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);

   --
   Begin
      Open SOB_ID;
      Fetch SOB_ID INTO l_set_of_books, l_sob_name;
      Close SOB_ID;
   Exception
      When Others then
           FND_MESSAGE.Set_Name ('XTR','XTR_NO_SOB');
           FND_MESSAGE.Set_Token ('COMPANY_CODE', p_company_code);
           FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
           retcode := greatest(retcode,2);
           l_ok_to_xfer := FALSE;
   End;

   -- Obtain unbalanced journal batches transfer handling from company params.
   -- If no parameter is found, then any unbalanced batches will NOT be transferred.

   l_bal_flag := XTR_ORACLE_FIN_INTERFACES_P.Get_Unbalance_Param(p_company_code);
   If (l_bal_flag is null) then
      FND_MESSAGE.Set_Name ('XTR','XTR_NO_UNBAL_JRNL_PARAM');
      FND_MESSAGE.Set_Token ('COMPANY_CODE', p_company_code);
      FND_MESSAGE.Set_Token ('BID', in_batch_id);
      FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
      retcode := greatest(retcode,1);
      l_bal_flag := 'N';
   End if;

   -- If company is setup to not transfer unbalanced batches, check balance.
   --    Y = Yes, allow transfer.
   --    N = No, do not allow transfer.

   If (nvl(l_bal_flag, 'N') = 'N') then
      If (XTR_ORACLE_FIN_INTERFACES_P.Balance_Batch(in_batch_id)) then
         l_ok_to_xfer := TRUE;
      Else
         FND_MESSAGE.Set_Name ('XTR','XTR_UNBAL_JRNL_ERROR');
         FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
         retcode := greatest(retcode,2);
         l_ok_to_xfer := FALSE;
      End If;
   Else
      l_ok_to_xfer := TRUE;
   End If;

   -- Journal batch is either in balance or unbalanced transfer is allowed.

   If (l_ok_to_xfer) then

      Open SOURCE_NAME;
      Fetch SOURCE_NAME INTO l_source_name;
      Close SOURCE_NAME;

      Open CATEGORY_NAME;
      Fetch CATEGORY_NAME INTO l_category_name;
      Close CATEGORY_NAME;

      Open EXCHANGE_TYPE;
      Fetch EXCHANGE_TYPE INTO l_xchange_type;
      Close EXCHANGE_TYPE;

      Open GL_GROUP_ID;
      Fetch GL_GROUP_ID into l_gl_group_id;
      Close GL_GROUP_ID;

      Open TRX_PARAM;
      Fetch TRX_PARAM into l_trx_param;
      Close TRX_PARAM;

      If l_trx_param = 'DETAIL' then
         Open JNL_DETAIL;
      Else
         Open JNL_SUMMARY;
      End If;

      LOOP
         If l_trx_param = 'DETAIL' then
            Fetch JNL_DETAIL INTO JNL_REC;

            EXIT WHEN JNL_DETAIL%NOTFOUND;
         Else
            Fetch JNL_SUMMARY INTO JNL_REC;
            EXIT WHEN JNL_SUMMARY%NOTFOUND;
         End if;

         Select XTR_AE_LINK_ID_S.nextval
           into l_gl_link_id
           from dual;

         --
         -- Three possible values for the parameter in_closed_periods:
         --    CLOSED  - No change, post to closed period.
         --    NXTOPEN - Change journal date to start date of next open GL period.
         --    null  --- Unable to locate the company parameter setting.  If
         --              journals in closed periods are found, transfer of batch
         --              be aborted.
         --

         l_journal_date := JNL_REC.journal_date;

         If (nvl(in_closed_periods, 'NXTOPEN') = 'NXTOPEN') then
            If (NOT IN_OPEN_PERIOD (l_set_of_books, l_sob_name, JNL_REC.journal_date)) then

               -- Two possible values for the parameter in_next_open_start.
               --    Valid Date - Use this date as the journal date.
               --    null ------- N/A if in_closed_periods is not 'NXTOPEN', but transfer
               --                 of batch will be aborted if in_closed_periods is 'NXTOPEN'.

               -- bug  4504734
               l_next_open_start := GET_NEXT_OPEN_START_DATE (l_set_of_books,in_company_code, jnl_rec.journal_date);

               If (in_closed_periods is null) then
                  FND_MESSAGE.Set_Name ('XTR','XTR_XFER_NO_CLOSE_PER_PARAM');
                  FND_MESSAGE.Set_Token ('JNL_DATE', to_char(JNL_REC.journal_date,'DD-MON-YYYY'));
                  FND_MESSAGE.Set_Token ('COMPANY_CODE', p_company_code);
                  FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
                  retcode := greatest(retcode,2);
                  l_ok_to_xfer := FALSE;

               Elsif (l_next_open_start is null) then
                  FND_MESSAGE.Set_Name ('XTR','XTR_XFER_NO_NEXT_PERIOD');
                  FND_MESSAGE.Set_Token ('JNL_DATE', to_char(JNL_REC.journal_date,'DD-MON-YYYY'));
                  FND_MESSAGE.Set_Token ('SOB_NAME', l_sob_name);
                  FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
                  retcode := greatest(retcode,2);
                  l_ok_to_xfer := FALSE;

               Elsif (l_next_open_start is not null) then

                  -- Set the journal date to be the period start date of the next open GL period.
                  -- NOTE:  Although the journal date is being adjusted, the exchange rate date
                  --        does not change and thereby the debit/credit amounts in SOB currency
                  --        will not change.  They will be based on the original transaction date.
                  --        This is in accordance with how AP handles "sweeping" of closed period
                  --        journals into the next open period.

                  l_journal_date := l_next_open_start;
               End If;     -- [in_closed_period...]
            End If;        -- [not in_open_period...]
         End If;           -- [in_closed_period...]

         If (l_ok_to_xfer) then

            -- Continue to transfer info into the GL_Interface table.

            Insert into GL_INTERFACE(
         		status,
           		set_of_books_id,
           		code_combination_id,
           		user_je_source_name,
           		user_je_category_name,
			accounting_date,
			currency_code,
			date_created,
			created_by,
			actual_flag,
			entered_dr,
			entered_cr,
			currency_conversion_date,
			user_currency_conversion_type,
			accounted_dr,
			accounted_cr,
			gl_sl_link_id,
			group_id,
			reference21,
			reference22,
			reference23,
			reference24,
			reference25,
			reference26,
			reference27,
			reference28,
			reference29,
			reference30)
                Values ('NEW',
                        l_set_of_books,
                        JNL_REC.ccid,
                        l_source_name,
                        l_category_name,
                        l_journal_date,
		        JNL_REC.currency,
		        trunc(sysdate),
		        nvl(fnd_global.user_id,-1),
    		       'A',
		       JNL_REC.debit,
		       JNL_REC.credit,
		       JNL_REC.journal_date,
		       l_xchange_type,
		       JNL_REC.acct_dr,
		       JNL_REC.acct_cr,
		       l_gl_link_id,
		       l_gl_group_id,
		       JNL_REC.batch_id,
		       JNL_REC.trans_number,
		       JNL_REC.date_type,
		       JNL_REC.deal_number,
		       JNL_REC.amount_type,
		       JNL_REC.action_code,
		       JNL_REC.deal_type,
		       JNL_REC.deal_subtype,
		       JNL_REC.product_type,
		       JNL_REC.portfolio_code);

            -- Update XTR_JOURNALS table.  Mark transferred rows.

            If l_trx_param = 'DETAIL' then
               Update XTR_JOURNALS
                  Set TRANSFER_TO_EXTERNAL_GL = trunc(sysdate),
                      gl_sl_link_id = l_gl_link_id,
		      alt_journal_date = l_journal_date		-- bug 3461138
                where rowid = JNL_REC.row_id;
            Else
               If (l_journal_date = JNL_REC.journal_date) then
                  l_journal_date := to_date(null);
               End If;

               If (JNL_REC.debit <> 0 or JNL_REC.acct_dr <> 0) then
                  UPDATE_DR (in_company_code,
                             JNL_REC.batch_id,
                             JNL_REC.journal_date,
                             JNL_REC.ccid,
                             l_gl_link_id,
                             JNL_REC.currency,
                             l_journal_date);
               Else
                  UPDATE_CR (in_company_code,
                             JNL_REC.batch_id,
                             JNL_REC.journal_date,
                             JNL_REC.ccid,
                             l_gl_link_id,
                             JNL_REC.currency,
                             l_journal_date);
               End If;   -- [debit/credit <> 0 ...]
            End if;      -- [l_trx_param ...]
         End If;         -- [l_ok_to_xfer ... after closed period handling check]
      END LOOP;          -- [loop processing of xtr_journals recrods ...]

      If l_trx_param = 'DETAIL' then
         Close JNL_DETAIL;
      Else
         Close JNL_SUMMARY;
      End if;

      -- Update XTR_BATCHES table to put the GL_GROUP_ID in corresponding BATCH_ID
      -- if batch has been successfully transferred.

      If (l_ok_to_xfer) then
         Update XTR_BATCHES
            Set GL_GROUP_ID =  l_gl_group_id
          Where BATCH_ID = in_batch_id;

         -- Update XTR_BATCH_EVENTS table.Set authorized information once journal is transferred

         Update XTR_BATCH_EVENTS
            Set AUTHORIZED = 'Y',
                AUTHORIZED_BY = fnd_global.user_id,
                AUTHORIZED_ON = trunc(sysdate)
          Where batch_id = in_batch_id
            And event_code = 'JRNLGN';

         Commit;
      End If;     -- [l_ok_to_xfer... update batch tables after successful xfer]
   End If;        -- [l_ok_to_xfer... after validating "balanceness" of batch]

   If (NOT l_ok_to_xfer) then
      ROLLBACK TO SAVEPOINT sp_transfer;
   End If;

   FND_MESSAGE.Set_Name ('XTR','XTR_END_XFER_JRNL_BATCH');
   FND_MESSAGE.Set_Token ('COMPANY_CODE', p_company_code);
   FND_MESSAGE.Set_Token ('BID', to_char(in_batch_id));
   FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);

Exception
   When Others then
      FND_MESSAGE.Set_Name ('XTR','XTR_XFER_UNHANDLED_ERROR');
      FND_MESSAGE.Set_Token ('COMPANY_CODE', p_company_code);
      FND_MESSAGE.Set_Token ('BID', to_char(in_batch_id));
      FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);

      ROLLBACK TO SAVEPOINT sp_transfer;
      retcode := 2;
END TRANSFER_JNLS;
--------------------------------------------------------------------------------------------------------------

end XTR_ORACLE_FIN_INTERFACES_P;

/
