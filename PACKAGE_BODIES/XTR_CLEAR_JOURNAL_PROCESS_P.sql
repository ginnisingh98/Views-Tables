--------------------------------------------------------
--  DDL for Package Body XTR_CLEAR_JOURNAL_PROCESS_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_CLEAR_JOURNAL_PROCESS_P" as
/* $Header: xtrcljnb.pls 120.3 2005/06/29 06:01:05 badiredd ship $ */
----------------------------------------------------------------------------------------------------------------

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Clear_Journal_Process						|
|									|
|  DESCRIPTION								|
|	This procedure merely accepts input parameters and performs	|
|	necessary data conversion then calls the main procedure		|
|	CLEAR_JOURNALS to clear journals created within the input date	|
|	range.								|
|  CALLED BY								|
|	Concurrent program submission manager and XTRACJNL.		|
|  PARAMETERS								|
|	p_company_code	company code.		(required)		|
|	p_start_date	date.			(required)		|
|	p_end_date	date.			(required)		|
|  HISTORY								|
|	05/19/99	eklau	Created					|
 --------------------------------------------------------------------- */


PROCEDURE Clear_Journal_Process
		(errbuf			OUT NOCOPY VARCHAR2,
		 retcode		OUT NOCOPY NUMBER,
		 p_company_code		IN VARCHAR2,
		 p_batch_id_from	IN NUMBER,
		 p_batch_id_to		IN NUMBER) IS

  p_curr_batch_id       XTR_BATCHES.BATCH_ID%TYPE;
  p_period_start        DATE;
  p_period_end          DATE;
  p_event_code		XTR_BATCH_EVENTS.EVENT_CODE%TYPE :='JRNLGN';

        CURSOR BATCH_SEQ is
        Select batch_id
        From XTR_BATCHES
        Where company_code = p_company_code
        and   batch_id between p_batch_id_from and p_batch_id_to
        Order by batch_id desc;

        CURSOR BATCH_PERIOD is
        Select period_start, period_end
        From XTR_BATCHES
        Where batch_id = p_curr_batch_id;

	CURSOR CHK_TRANS_GL is    -- Check if the current batch has been transferred
	Select 1
	From XTR_BATCHES
	Where batch_id = p_curr_batch_id
	and gl_group_id is not null;

	CURSOR FIND_LATE_BATCH is
	Select e.batch_id
	From XTR_BATCHES B, XTR_BATCH_EVENTS E
	Where b.batch_id = e.batch_id
        and  e.batch_id > p_curr_batch_id
 	and  b.company_code = p_company_code
        and  e.event_code = p_event_code
        and b.batch_type is null
	order by e.batch_id asc;
	l_late_batch_id      XTR_BATCHES.BATCH_ID%TYPE;

/*	CURSOR CHK_LATE_BATCH is
	Select 1
	From XTR_BATCHES
	where batch_id = l_late_batch_id
	and gl_group_id is not null;    */

	ex_late_batch	EXCEPTION;
	ex_trans_gl     EXCEPTION;
	l_temp		NUMBER;
	v_batch_type Xtr_Batches.Batch_Type%Type;

--
BEGIN
--	xtr_debug_pkg.enable_debug (null,null);
	IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	   xtr_debug_pkg.debug('>>XTR_CLEAR_JOURNAL_PROCESS_P.Clear_Journal_Process');
	END IF;

   Open BATCH_SEQ;
   Fetch BATCH_SEQ into p_curr_batch_id;
   While BATCH_SEQ%FOUND LOOP   -- Delete Batches.Start from greatest ID.

	-- Raise exception if the deleted batch id has been transferred to GL
	Open CHK_TRANS_GL;
	Fetch CHK_TRANS_GL into l_temp;
        If CHK_TRANS_GL%FOUND then
	   Close CHK_TRANS_GL;
	   Raise ex_trans_gl;
	Else
           Close CHK_TRANS_GL;
	End if;

        Select batch_type
        Into v_batch_type
        From Xtr_Batches
        Where batch_id = p_curr_batch_id;

        If nvl(v_batch_type, 'R') <> 'J' then
	-- Raise exception if the deleted batch id which has later batch id existed.
	   Open FIND_LATE_BATCH;
    	   Fetch FIND_LATE_BATCH into l_late_batch_id;
  	   If FIND_LATE_BATCH%FOUND then
	      Close FIND_LATE_BATCH;
  	      Raise ex_late_batch;
  	   Else
              Close FIND_LATE_BATCH;
	   End if;
        End if;

        G_company_code := p_company_code;
	G_batch_id     := p_curr_batch_id;
--	G_start_date   := p_period_start;
--	G_end_date     := p_period_end;

	Clear_Journals(G_company_code,G_batch_id);

	IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	   xtr_debug_pkg.debug('<<XTR_CLEAR_JOURNAL_PROCESS_P.Clear_Journal_Process');
	END IF;

        Fetch BATCH_SEQ into p_curr_batch_id;
   END LOOP;
   Close BATCH_SEQ;


EXCEPTION
   when ex_trans_gl then
	FND_MESSAGE.Set_Name('XTR', 'XTR_TRANS_GL');
	FND_MESSAGE.Set_Token('BATCH', p_curr_batch_id);
	APP_EXCEPTION.Raise_exception;
   when ex_late_batch then
	FND_MESSAGE.Set_Name('XTR', 'XTR_LATE_BATCH');
	FND_MESSAGE.Set_Token('CUR_BATCH', p_curr_batch_id);
	FND_MESSAGE.Set_Token('LATE_BATCH', l_late_batch_id);
	APP_EXCEPTION.Raise_exception;

END Clear_Journal_Process;

-------------------------------------------------------------------------------------------------------------
/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Clear_Journals							|
|									|
|  DESCRIPTION								|
|	Procedure to delete non-transferred journal entries for the	|
|	specified company and date range and reset the 'journal_created'|
|	flag in DDA to allow for re-generation of journals at a later	|
|	date.								|
|  CALLED BY								|
|	Clear_Journal_Process						|
|  PARAMETERS								|
|	in_company	company code.		(required)		|
|	in_start_date	date.			(required)		|
|	in_end_date	date.			(required)		|
|  HISTORY								|
|       05/19/99	eklau	Created.				|
|	06/15/99	eklau   Added logic to exclude clearing journal	|
|				lines with status = 'R' in column	|
|				JNL_REVERSAL_IND.  These are reversal	|
|				entries for closed/cancelled deals which|
|				no longer have associating DDA rows.	|
 --------------------------------------------------------------------- */

PROCEDURE CLEAR_JOURNALS
		(in_company		IN VARCHAR2,
		 in_batch_id            IN NUMBER) is

	Cursor GET_BATCH_TYPE is
	Select batch_type
	  from xtr_batches
	 where batch_id = in_batch_id;

	l_batch_type	XTR_BATCHES.batch_type%TYPE := null;
        p_event_code	XTR_BATCH_EVENTS.EVENT_CODE%TYPE :='JRNLGN';
--
Begin
	IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	   xtr_debug_pkg.debug('>>XTR_CLEAR_JOURNAL_PROCESS_P.Clear_Journals');
           xtr_debug_pkg.debug('CLEAR_JOURNALS: ' || 'Current Batch = ' || to_char(in_batch_id));
        END IF;

        -- Turn BATCH_ID to null value once we delete journals.
           Update XTR_DEAL_DATE_AMOUNTS
              Set BATCH_ID = null
            Where company_code = in_company
              and batch_id = in_batch_id;

        --Remove jnl lines in JOURNALS after successful reset DDA batch ID to null.

                Delete from XTR_JOURNALS
                Where company_code = in_company
                and batch_id = in_batch_id;

        -- Update XTR_BATCH_EVENTS, remove the journal_generate row
        Delete from  XTR_BATCH_EVENTS
        Where  batch_id = in_batch_id
        and    event_code = p_event_code;

        -- Flex Journals.
        -- If Non-Reval/Non-Accrual related batch, need to remove existence
        -- of batch from XTR_BATCHES also.

        Open  GET_BATCH_TYPE;
        Fetch GET_BATCH_TYPE into l_batch_type;
        Close GET_BATCH_TYPE;

        If (nvl(l_batch_type,'X') = 'J') then
           Delete from XTR_BATCHES
           Where  batch_id = in_batch_id;
        End If;

	Commit;

	IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	   xtr_debug_pkg.debug('<<XTR_CLEAR_JOURNAL_PROCESS_P.Clear_Journals');
	END IF;

End CLEAR_JOURNALS;

--------------------------------------------------------------------------------------------------------------------------
END XTR_CLEAR_JOURNAL_PROCESS_P;

/
