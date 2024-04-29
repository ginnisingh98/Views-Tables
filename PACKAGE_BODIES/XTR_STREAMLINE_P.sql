--------------------------------------------------------
--  DDL for Package Body XTR_STREAMLINE_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_STREAMLINE_P" as
/* $Header: xtrstrmb.pls 120.7 2005/11/24 09:58:14 badiredd ship $ */
-------------------------------------------------------------------------------------------------


/*-------------------------------------------------------------------------*/
 FUNCTION REVAL_DETAILS_INCOMPLETE (p_company     IN VARCHAR2,
                                    p_batch_start IN DATE,
                                    p_batch_end   IN DATE,
                                    p_batch_id    IN NUMBER) RETURN BOOLEAN AS
/*-------------------------------------------------------------------------*
 *                                                                         *
 * To find if there are incomplete revaluation details in the batch.       *
 *                                                                         *
 *-------------------------------------------------------------------------*/

   l_dummy    VARCHAR2(1);
   l_batch_id NUMBER;

   cursor c_batch_id is
   select batch_id
   from   xtr_batches
   where  period_start = p_batch_start
   and    period_end   = p_batch_end
   and    company_code = p_company
   and    batch_type is null;            -- 3527080 exclude NRA batch

   cursor c_incomplete is
   select 'Y'
   from   xtr_revaluation_details
   where  batch_id               = l_batch_id
   and    company_code           = p_company
   and    nvl(complete_flag,'N') = 'N';


BEGIN
   --===================================  DEBUG ===============================================--
     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('REVAL_DETAILS_INCOMPLETE - In Parameters');
        xtr_risk_debug_pkg.dlog('p_company         ' , p_company);
        xtr_risk_debug_pkg.dlog('p_batch_start     ' , p_batch_start);
        xtr_risk_debug_pkg.dlog('p_batch_end       ' , p_batch_end);
        xtr_risk_debug_pkg.dlog('p_batch_id        ' , p_batch_id);
        xtr_risk_debug_pkg.dpop('REVAL_DETAILS_INCOMPLETE - In Parameters');
     END IF;
   --==========================================================================================--

   if p_batch_id is null then
      open  c_batch_id;
      fetch c_batch_id into l_batch_id;
      close c_batch_id;
   else
      l_batch_id := p_batch_id;
   end if;

   open  c_incomplete;
   fetch c_incomplete into l_dummy;
   if c_incomplete%notfound then
      close c_incomplete;
      return FALSE;
   end if;
   close c_incomplete;
   return TRUE;
END;


/*-------------------------------------------------------------------------*/
 FUNCTION RETRO_DETAILS_INCOMPLETE (p_company     IN VARCHAR2,
                                    p_batch_start IN DATE,
                                    p_batch_end   IN DATE,
                                    p_batch_id    IN NUMBER) RETURN BOOLEAN AS
/*-------------------------------------------------------------------------*
 * Bug 3378028  FAS                                                        *
 * To find if there are incomplete retrospective details in the batch.     *
 *                                                                         *
 *-------------------------------------------------------------------------*/

   l_dummy    VARCHAR2(1);
   l_batch_id NUMBER;

   cursor c_batch_id is
   select batch_id
   from   xtr_batches
   where  period_start = p_batch_start
   and    period_end   = p_batch_end
   and    company_code = p_company
   and    batch_type is null;

   cursor c_incomplete is
   select 'Y'
   from   xtr_hedge_retro_tests
   where  batch_id               = l_batch_id
   and    company_code           = p_company
   and    nvl(complete_flag,'N') = 'N';

BEGIN
   --===================================  DEBUG ===============================================--
     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('RETRO_DETAILS_INCOMPLETE - In Parameters');
        xtr_risk_debug_pkg.dlog('p_company         ' , p_company);
        xtr_risk_debug_pkg.dlog('p_batch_start     ' , p_batch_start);
        xtr_risk_debug_pkg.dlog('p_batch_end       ' , p_batch_end);
        xtr_risk_debug_pkg.dlog('p_batch_id        ' , p_batch_id);
        xtr_risk_debug_pkg.dpop('RETRO_DETAILS_INCOMPLETE - In Parameters');
     END IF;
   --==========================================================================================--

   if p_batch_id is null then
      open  c_batch_id;
      fetch c_batch_id into l_batch_id;
      close c_batch_id;
   else
      l_batch_id := p_batch_id;
   end if;

   open  c_incomplete;
   fetch c_incomplete into l_dummy;
   if c_incomplete%notfound then
      close c_incomplete;
      return FALSE;
   end if;
   close c_incomplete;
   return TRUE;
END;

/*---------------------------------------------------------------------*/
 FUNCTION GET_EVENT_STATUS (p_company     IN VARCHAR2,
                            p_batch_id    IN NUMBER,
                            p_batch_BED   IN DATE,     -- Batch End Date
                            p_event       IN VARCHAR2,
                            p_authorize   IN VARCHAR2) RETURN BOOLEAN AS
/*---------------------------------------------------------------------*
 |                                                                     |
 | To determine if a given p_event exists and/or authorised.           |
 |                                                                     |
 | p_authorize : 'Y' to check for authorise or NULL to check event     |
 |               exists.                                               |
 |                                                                     |
 | Valid p_event:  'RATES', 'REVAL', 'ACCRUAL', 'JOURNAL', 'TRANSFER'  |
 |                                                                     |
 *---------------------------------------------------------------------*/

   cursor find_rates is
   select  'Y'
   from    xtr_revaluation_rates
   where   batch_id     = nvl(p_batch_id, batch_id)
   and     company_code = p_company
   and     period_to    = nvl(p_batch_BED, period_to);

   cursor find_transfer is
   select  'Y'
   from    xtr_batches
   where   batch_id     = nvl(p_batch_id, batch_id)
   and     company_code = p_company
   and     period_end   = nvl(p_batch_BED, period_end)
   and     gl_group_id is not null
   and     batch_type is null;            -- 3527080 exclude NRA batch

   cursor find_event is
   select  'Y'
   from    xtr_batch_events a,
           xtr_batches b
   where   a.batch_id     = nvl(p_batch_id, a.batch_id)
   and     a.event_code   = p_event
   and     a.authorized   = nvl(p_authorize,a.authorized)
   and     b.batch_id     = a.batch_id
   and     b.company_code = p_company
   and     b.period_end   = nvl(p_batch_BED, b.period_end)
   and     b.batch_type is null;            -- 3527080 exclude NRA batch


   l_dummy VARCHAR2(1);

BEGIN
   --===================================  DEBUG ===============================================--
     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('GET_EVENT_STATUS - In Parameters');
        xtr_risk_debug_pkg.dlog('p_company         ', p_company);
        xtr_risk_debug_pkg.dlog('p_batch_id        ', p_batch_id);
        xtr_risk_debug_pkg.dlog('p_batch_BED       ', p_batch_BED);
        xtr_risk_debug_pkg.dlog('p_event           ', p_event);
        xtr_risk_debug_pkg.dlog('p_authorize       ', p_authorize);
        xtr_risk_debug_pkg.dpop('GET_EVENT_STATUS - In Parameters');
     END IF;
   --==========================================================================================--

   if p_event = C_RATES then
      open  find_rates;
      fetch find_rates into l_dummy;
      if find_rates%notfound then
         close find_rates;
         return FALSE;
      end if;
      close find_rates;
   ------------------------------------------
   -- This is included but is not used.
   ------------------------------------------
   elsif p_event = C_TRANSFER then
      open  find_transfer;
      fetch find_transfer into l_dummy;
      if find_transfer%notfound then
         close find_transfer;
         return FALSE;
      end if;
      close find_transfer;
   ------------------------------------------
   else
      open  find_event;
      fetch find_event into l_dummy;
      if find_event%notfound then
         close find_event;
         return FALSE;
      end if;
      close find_event;
   end if;
   return TRUE;

END;


/*---------------------------------------------------------------------*/
 FUNCTION EVENT_EXISTS (p_company   IN VARCHAR2,
                        p_batch_id  IN NUMBER,
                        p_batch_BED IN DATE,
                        p_event     IN VARCHAR2) RETURN BOOLEAN AS
/*---------------------------------------------------------------------*
 *                                                                     *
 * To check that event exists, authorise or unauthorised.              *
 *                                                                     *
 *---------------------------------------------------------------------*/
BEGIN
   --===================================  DEBUG ===============================================--
     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('EVENT_EXISTS - In Parameters');
        xtr_risk_debug_pkg.dlog('p_company         ', p_company);
        xtr_risk_debug_pkg.dlog('p_batch_id        ', p_batch_id);
        xtr_risk_debug_pkg.dlog('p_batch_BED       ', p_batch_BED);
        xtr_risk_debug_pkg.dlog('p_event           ', p_event);
        xtr_risk_debug_pkg.dpop('EVENT_EXISTS - In Parameters');
     END IF;
   --==========================================================================================--

   return GET_EVENT_STATUS (p_company, p_batch_id, p_batch_BED, p_event, NULL);

END;


/*---------------------------------------------------------------------*/
 FUNCTION EVENT_AUTHORIZED (p_company   IN VARCHAR2,
                            p_batch_id  IN NUMBER,
                            p_event     IN VARCHAR2) RETURN BOOLEAN AS
/*---------------------------------------------------------------------*
 *                                                                     *
 * To check that event exists and authorised.                          *
 *                                                                     *
 *---------------------------------------------------------------------*/
BEGIN
   --===================================  DEBUG ===============================================--
     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('EVENT_AUTHORIZED - In Parameters');
        xtr_risk_debug_pkg.dlog('p_company         ', p_company);
        xtr_risk_debug_pkg.dlog('p_batch_id        ', p_batch_id);
        xtr_risk_debug_pkg.dlog('p_event           ', p_event);
        xtr_risk_debug_pkg.dpop('EVENT_AUTHORIZED - In Parameters');
     END IF;
   --==========================================================================================--

   return GET_EVENT_STATUS (p_company, p_batch_id, NULL, p_event, 'Y');

END;


/*---------------------------------------------------------------------*/
 FUNCTION GET_PARTY_CREATED_ON (p_company   IN VARCHAR2) RETURN DATE AS
/*---------------------------------------------------------------------*
 *                                                                     *
 * To get creation date of company. Same logic as form.                *
 *                                                                     *
 *---------------------------------------------------------------------*/
   cursor party_created IS
   select created_on
   from   xtr_party_info
   where  party_code = p_company;

   l_date  DATE;

BEGIN

   open  PARTY_CREATED;
   fetch PARTY_CREATED into l_date;
   close PARTY_CREATED;

   --===================================  DEBUG ===============================================--
     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('GET_PARTY_CREATED_ON');
        xtr_risk_debug_pkg.dlog('p_company         ', p_company);
        xtr_risk_debug_pkg.dlog('l_date            ', l_date);
        xtr_risk_debug_pkg.dpop('GET_PARTY_CREATED_ON');
     END IF;
   --==========================================================================================--

   return l_date;

END;

/*---------------------------------------------------------------------*/
 FUNCTION LOCK_BATCH (p_batch_id        IN NUMBER,
                      p_company         IN VARCHAR2,
                      p_no_data_error   IN VARCHAR2,
                      p_locking_error   IN VARCHAR2) RETURN NUMBER AS
/*---------------------------------------------------------------------*
 *                                                                     *
 * Locks the entire batch.                                             *
 *                                                                     *
 *---------------------------------------------------------------------*/
   l_rowid  ROWID;

BEGIN
   --===================================  DEBUG ===============================================--
     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('LOCK_BATCH - In Parameters');
        xtr_risk_debug_pkg.dlog('p_batch_id        ' , p_batch_id);
        xtr_risk_debug_pkg.dlog('p_company         ' , p_company);
        xtr_risk_debug_pkg.dlog('p_no_data_error   ' , p_no_data_error);
        xtr_risk_debug_pkg.dlog('p_locking_error   ' , p_locking_error);
        xtr_risk_debug_pkg.dpop('LOCK_BATCH - In Parameters');
     END IF;
   --==========================================================================================--

   select rowid
   into   l_rowid
   from   xtr_batches
   where  batch_id     = p_batch_id
   and    company_code = p_company
   and    batch_type is null            -- 3527080 exclude NRA batch
   for update of last_update_date nowait;

   return(0);

EXCEPTION
   when no_data_found then
        rollback;
        FND_MESSAGE.Set_Name('XTR', p_no_data_error);
        FND_MESSAGE.Set_Token('BATCH', p_batch_id);
        FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
        FND_FILE.Put_Line (FND_FILE.LOG, ' ');
        --===================================  DEBUG ===============================================--
          IF xtr_risk_debug_pkg.g_Debug THEN
             xtr_risk_debug_pkg.dpush('LOCK_BATCH - error');
             xtr_risk_debug_pkg.dlog('Exception Error   ' , 'NO_DATA_FOUND');
             xtr_risk_debug_pkg.dpop('LOCK_BATCH - error');
          END IF;
        --==========================================================================================--
        return(2);
   when e_record_locked then
        rollback;
        FND_MESSAGE.Set_Name('XTR', p_locking_error);
        FND_MESSAGE.Set_Token('BATCH', p_batch_id);
        FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
        FND_FILE.Put_Line (FND_FILE.LOG, ' ');
        --===================================  DEBUG ===============================================--
           IF xtr_risk_debug_pkg.g_Debug THEN
              xtr_risk_debug_pkg.dpush('LOCK_BATCH - error');
              xtr_risk_debug_pkg.dlog('Exception Error   ' , 'E_RECORD_LOCKED');
              xtr_risk_debug_pkg.dpop('LOCK_BATCH - error');
           END IF;
        --==========================================================================================--
        return(2);
   when others then
        rollback;
        FND_MESSAGE.Set_Name('XTR', C_BATCH_ERROR);
        FND_MESSAGE.Set_Token('BATCH', p_batch_id);
        FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
        FND_FILE.Put_line (FND_FILE.LOG, sqlcode||'- '||sqlerrm(sqlcode));
        FND_FILE.Put_Line (FND_FILE.LOG, ' ');
        --===================================  DEBUG ===============================================--
           IF xtr_risk_debug_pkg.g_Debug THEN
              xtr_risk_debug_pkg.dpush('LOCK_BATCH - error');
              xtr_risk_debug_pkg.dlog('Exception Error   ' , 'OTHERS');
              xtr_risk_debug_pkg.dpop('LOCK_BATCH - error');
           END IF;
        --==========================================================================================--
        return(2);
END LOCK_BATCH;


/*---------------------------------------------------------------------*/
 FUNCTION LOCK_EVENT (p_batch_id        IN NUMBER,
                      p_event           IN VARCHAR2,
                      p_authorized      IN VARCHAR2,
                      p_no_data_error   IN VARCHAR2,
                      p_locking_error   IN VARCHAR2) RETURN NUMBER AS
/*---------------------------------------------------------------------*
 *                                                                     *
 *  p_authorized    - leave NULL if you are not concerned whether or   *
 *                    not event is authorised.                         *
 *                                                                     *
 *  p_no_data_error - error code for NO_DATA_FOUND                     *
 *                                                                     *
 *  p_locking_error - error code for record locked                     *
 *                                                                     *
 *---------------------------------------------------------------------*/
   l_rowid  ROWID;

BEGIN
   --===================================  DEBUG ===============================================--
     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('LOCK_EVENT - In Parameters');
        xtr_risk_debug_pkg.dlog('p_batch_id        ' , p_batch_id);
        xtr_risk_debug_pkg.dlog('p_event           ' , p_event);
        xtr_risk_debug_pkg.dlog('p_authorized      ' , p_authorized);
        xtr_risk_debug_pkg.dlog('p_no_data_error   ' , p_no_data_error);
        xtr_risk_debug_pkg.dlog('p_locking_error   ' , p_locking_error);
        xtr_risk_debug_pkg.dpop('LOCK_EVENT - In Parameters');
     END IF;
   --==========================================================================================--

   select rowid
   into   l_rowid
   from   xtr_batch_events a
   where  batch_id   = p_batch_id
   and    event_code = p_event
   and    authorized = nvl(p_authorized,authorized)
   for update of authorized nowait;

   return(0);

EXCEPTION
   when no_data_found then
        rollback;
        FND_MESSAGE.Set_Name('XTR', p_no_data_error);
        FND_MESSAGE.Set_Token('BATCH', p_batch_id);
        FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
        FND_FILE.Put_Line (FND_FILE.LOG, ' ');
        --===================================  DEBUG ===============================================--
          IF xtr_risk_debug_pkg.g_Debug THEN
             xtr_risk_debug_pkg.dpush('LOCK_EVENT - error');
             xtr_risk_debug_pkg.dlog('Exception Error   ' , 'NO_DATA_FOUND');
             xtr_risk_debug_pkg.dpop('LOCK_EVENT - error');
          END IF;
        --==========================================================================================--
        return(2);
   when e_record_locked then
        rollback;
        FND_MESSAGE.Set_Name('XTR', p_locking_error);
        FND_MESSAGE.Set_Token('BATCH', p_batch_id);
        FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
        FND_FILE.Put_Line (FND_FILE.LOG, ' ');
        --===================================  DEBUG ===============================================--
          IF xtr_risk_debug_pkg.g_Debug THEN
             xtr_risk_debug_pkg.dpush('LOCK_EVENT - error');
             xtr_risk_debug_pkg.dlog('Exception Error   ' , 'E_RECORD_LOCKED');
             xtr_risk_debug_pkg.dpop('LOCK_EVENT - error');
          END IF;
        --==========================================================================================--
        return(2);
   when others then
        rollback;
        FND_MESSAGE.Set_Name('XTR', C_BATCH_ERROR);
        FND_MESSAGE.Set_Token('BATCH', p_batch_id);
        FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
        FND_FILE.Put_line (FND_FILE.LOG, sqlcode||'- '||sqlerrm(sqlcode));
        FND_FILE.Put_Line (FND_FILE.LOG, ' ');
        --===================================  DEBUG ===============================================--
          IF xtr_risk_debug_pkg.g_Debug THEN
             xtr_risk_debug_pkg.dpush('LOCK_EVENT - error');
             xtr_risk_debug_pkg.dlog('Exception Error   ' , 'OTHERS');
             xtr_risk_debug_pkg.dpop('LOCK_EVENT - error');
          END IF;
        --==========================================================================================--
        return(2);
END LOCK_EVENT;


/*------------------------------------------------------------------------------*/
 FUNCTION  CHK_ELIGIBLE_COMPANY (p_company        IN  VARCHAR2,
                                 p_cutoff_date    IN  DATE,
                                 p_do_reval       IN  VARCHAR2,
                                 p_do_retro       IN  VARCHAR2,   -- 3378028 FAS
                                 p_start_process  IN  VARCHAR2,
                                 p_end_process    IN  VARCHAR2) RETURN NUMBER AS
/*------------------------------------------------------------------------------*
 *                                                                              *
 * To check if company has incomplete reval details, incomplete previous        *
 * batches, incomplete inaugural batch, etc.                                    *
 *                                                                              *
 *------------------------------------------------------------------------------*/

   cursor INCOMPLETE_TRANSFER_BATCH is
   select batch_id,
          period_start,
          period_end
   from   xtr_batches a
   where  company_code = p_company
   and    period_end  <= p_cutoff_date
   and    nvl(upgrade_batch,'N') = 'N'
   and    batch_type is null
   and    gl_group_id is null
   order by period_end, period_start;

   cursor INCOMPLETE_JOURNAL_BATCH is
   select batch_id,
          period_start,
          period_end
   from   xtr_batches a
   where  company_code = p_company
   and    period_end  <= p_cutoff_date
   and    nvl(upgrade_batch,'N') = 'N'
   and    batch_type is null
   and    not exists (select 1
                      from   XTR_BATCH_EVENTS b
                      where  b.batch_id  = a.batch_id
                      and    event_code  = C_JOURNAL)
   order by period_end, period_start;

   cursor INCOMPLETE_ACCRUAL_BATCH is
   select batch_id,
          period_start,
          period_end
   from   xtr_batches a
   where  company_code = p_company
   and    period_end  <= p_cutoff_date
   and    nvl(upgrade_batch,'N') = 'N'
   and    batch_type is null
   and    not exists (select 1
                      from   XTR_BATCH_EVENTS b
                      where  b.batch_id  = a.batch_id
                      and    event_code  = C_ACCRUAL
                      and    nvl(authorized,'N') = 'Y')
   order by period_end, period_start;

   ------------------------------------------------------------------------------------------------
   -- 3378028 FAS
   -- ===========
   -- An incomplete RETRO batch is one without authorised RETROET event and without ACCRUAL event.
   ------------------------------------------------------------------------------------------------
   cursor INCOMPLETE_RETRO_BATCH is
   select batch_id,
          period_start,
          period_end
   from   xtr_batches a
   where  company_code = p_company
   and    period_end  <= p_cutoff_date
   and    nvl(upgrade_batch,'N') = 'N'
   and    batch_type is null
   and    not exists (select 1
                      from   XTR_BATCH_EVENTS b
                      where  b.batch_id          = a.batch_id
                      and    event_code          = C_RETROET
                      and    nvl(authorized,'N') = 'Y')
   and    not exists (select 1
                      from   XTR_BATCH_EVENTS c
                      where  c.batch_id          = a.batch_id
                      and    event_code          = C_ACCRUAL)   -- Intended for company that skips RETROSPECTIVE TEST
                                                                -- Need not check for AUTHORIZED flag in this case.
   order by period_end, period_start;


   cursor INCOMPLETE_REVAL_BATCH is
   select batch_id,
          period_start,
          period_end
   from   xtr_batches a
   where  company_code = p_company
   and    period_end  <= p_cutoff_date
   and    nvl(upgrade_batch,'N') = 'N'
   and    batch_type is null
   and    not exists (select 1
                      from   XTR_BATCH_EVENTS b
                      where  b.batch_id          = a.batch_id
                      and    event_code          = C_REVAL
                      and    nvl(authorized,'N') = 'Y')
   order by period_end, period_start;

   cursor UPGRADE_REQUIRED is
   SELECT 'Y'
   FROM   xtr_batches              b,
          xtr_revaluation_details  a
   WHERE  b.company_code = p_company
   AND    b.batch_id     = a.batch_id
   AND    NVL(b.upgrade_batch,'N') = 'Y'
   AND    b.batch_type is null            -- 3527080 exclude NRA batch
   UNION
   SELECT 'Y'
   FROM   xtr_batches       b,
          xtr_accrls_amort  a
   WHERE  b.company_code = p_company
   AND    b.batch_id     = a.batch_id
   AND    NVL(b.upgrade_batch,'N') = 'Y'
   AND    b.batch_type is null;           -- 3527080 exclude NRA batch


   l_retcode          NUMBER      := 0;
   l_batch_id         NUMBER      := null;
   l_batch_start      DATE        := to_date(null);
   l_batch_end        DATE        := to_date(null);

   l_latest_BID       NUMBER      := null;
   l_dummy_BSD        DATE        := to_date(null);
   l_latest_BED       DATE        := to_date(null);
   l_group_id         NUMBER      := null;
   l_latest_upgrade   VARCHAR2(1) := null;
   l_upgrade_required VARCHAR2(1) := null;

   FUNCTION LOG_ERROR (p_err_code  IN VARCHAR2, p_batch_id  IN NUMBER, p_batch_BED IN DATE) RETURN NUMBER AS
   BEGIN
      --===================================  DEBUG ===============================================--
        IF xtr_risk_debug_pkg.g_Debug THEN
           xtr_risk_debug_pkg.dpush('CHK_ELIGIBLE_COMPANY - LOG_ERROR');
           xtr_risk_debug_pkg.dlog('p_err_code        ' , p_err_code);
           xtr_risk_debug_pkg.dlog('p_batch_id        ' , p_batch_id);
           xtr_risk_debug_pkg.dlog('p_batch_BED       ' , p_batch_BED);
           xtr_risk_debug_pkg.dpop('CHK_ELIGIBLE_COMPANY - LOG_ERROR');
        END IF;
      --==========================================================================================--

      FND_MESSAGE.Set_Name('XTR', p_err_code);
      if p_err_code in (C_NO_REVAL_DATA,    C_NO_ACCRUAL_DATA, C_NO_JOURNAL_DATA, C_INCOMPLETE_REVAL,
                        C_NO_RETROET_DATA,  C_INCOMPLETE_RETROET ) then           -- FAS 3378028 errors
         FND_MESSAGE.Set_Token('BATCH', p_batch_id);
      elsif p_err_code in (C_MISSING_REVAL, C_MISSING_ACCRUAL, C_MISSING_JOURNAL,
                           C_MISSING_RETROET) then                               -- FAS 3378028 errors
         FND_MESSAGE.Set_Token('BED', p_batch_BED);
      end if;
      FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
      FND_FILE.Put_Line (FND_FILE.LOG, ' ');
      return(2);

   END;

BEGIN
   --===================================  DEBUG ===============================================--
     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('CHK_ELIGIBLE_COMPANY - In Parameters');
        xtr_risk_debug_pkg.dlog('p_company         ' , p_company);
        xtr_risk_debug_pkg.dlog('p_cutoff_date     ' , p_cutoff_date);
        xtr_risk_debug_pkg.dlog('p_do_reval        ' , p_do_reval);
        xtr_risk_debug_pkg.dlog('p_do_retro        ' , p_do_retro);
        xtr_risk_debug_pkg.dlog('p_start_process   ' , p_start_process);
        xtr_risk_debug_pkg.dlog('p_end_process     ' , p_end_process);
        xtr_risk_debug_pkg.dpop('CHK_ELIGIBLE_COMPANY - In Parameters');
     END IF;
   --==========================================================================================--

      if p_end_process = C_PROCESS_REVAL and p_do_reval = 'Y' then
            open  INCOMPLETE_REVAL_BATCH;
            fetch INCOMPLETE_REVAL_BATCH into l_batch_id, l_batch_start, l_batch_end;
            close INCOMPLETE_REVAL_BATCH;
    --elsif p_end_process = C_PROCESS_RETROET and p_do_retro = 'Y' and p_do_reval = 'Y' then
      elsif p_end_process = C_PROCESS_RETROET and p_do_reval = 'Y' then  -- 3378028 FAS
            open  INCOMPLETE_RETRO_BATCH;
            fetch INCOMPLETE_RETRO_BATCH into l_batch_id, l_batch_start, l_batch_end;
            close INCOMPLETE_RETRO_BATCH;
      elsif p_end_process = C_PROCESS_ACCRUAL then
            open  INCOMPLETE_ACCRUAL_BATCH;
            fetch INCOMPLETE_ACCRUAL_BATCH into l_batch_id, l_batch_start, l_batch_end;
            close INCOMPLETE_ACCRUAL_BATCH;
      elsif p_end_process = C_PROCESS_JOURNAL then
            open  INCOMPLETE_JOURNAL_BATCH;
            fetch INCOMPLETE_JOURNAL_BATCH into l_batch_id, l_batch_start, l_batch_end;
            close INCOMPLETE_JOURNAL_BATCH;
      elsif p_end_process = C_PROCESS_TRANSFER then
            open  INCOMPLETE_TRANSFER_BATCH;
            fetch INCOMPLETE_TRANSFER_BATCH into l_batch_id, l_batch_start, l_batch_end;
            close INCOMPLETE_TRANSFER_BATCH;
      end if;

      --===================================  DEBUG ===============================================--
        IF xtr_risk_debug_pkg.g_Debug THEN
           xtr_risk_debug_pkg.dpush('CHK_ELIGIBLE_COMPANY - check incomplete batch');
           xtr_risk_debug_pkg.dlog('l_batch_id        ' , l_batch_id);
           xtr_risk_debug_pkg.dlog('l_batch_start     ' , l_batch_start);
           xtr_risk_debug_pkg.dlog('l_batch_end       ' , l_batch_end);
           xtr_risk_debug_pkg.dpop('CHK_ELIGIBLE_COMPANY - check incomplete batch');
        END IF;
      --==========================================================================================--

      if l_batch_id is not null then

            l_retcode := 1;   -- Batch is incomplete, but need to check other validations.

            if l_batch_end > p_cutoff_date then

               l_retcode := LOG_ERROR(C_COMPLETED_BATCH,null,null);  -- Batch End Date is completed.

            else

               --------------------------------------------------------------------------------------------------------
               -- Batch eligible - 3378028 FAS Begin
               --------------------------------------------------------------------------------------------------------
               if p_start_process = C_PROCESS_REVAL and p_do_reval = 'Y' then

                  if EVENT_EXISTS(p_company, l_batch_id,NULL, C_REVAL) then

                     if REVAL_DETAILS_INCOMPLETE (p_company, l_batch_start, l_batch_end, l_batch_id) then
                        l_retcode := LOG_ERROR(C_INCOMPLETE_REVAL, l_batch_id, null);
                     else
                        --=============================================================================================
                        -- 3378028 FAS
                        -- For companies that does not do RETRO and does not have incomplete REVAL event.
                        -- Should end process with error here so child process is not submitted.
                        --=============================================================================================
                        if p_do_retro = 'N' and p_end_process = C_PROCESS_RETROET then
                           if l_batch_end = p_cutoff_date and EVENT_AUTHORIZED (p_company, l_batch_id, C_REVAL) then
                              l_retcode := LOG_ERROR(C_COMPLETED_BATCH, null, null);
                              l_retcode := LOG_ERROR(C_COMPANY_SKIP_RETROET, l_batch_id, null);
                           end if;
                        end if;
                        --=============================================================================================
                     end if;
                  end if;

               elsif p_start_process = C_PROCESS_RETROET and p_do_retro = 'Y' then

                  if EVENT_EXISTS(p_company, l_batch_id,NULL, C_RETROET) then

                     if RETRO_DETAILS_INCOMPLETE (p_company, l_batch_start, l_batch_end, l_batch_id) then
                        l_retcode := LOG_ERROR(C_INCOMPLETE_RETROET, l_batch_id, null);
                     end if;

                  elsif not EVENT_AUTHORIZED (p_company, l_batch_id, C_REVAL) then
                     l_retcode := LOG_ERROR(C_NO_REVAL_DATA, l_batch_id, null);

                  end if;


               elsif p_start_process = C_PROCESS_ACCRUAL and p_do_reval = 'Y' then
                  if p_do_retro = 'Y' then
                     if not EVENT_AUTHORIZED (p_company, l_batch_id, C_RETROET) then
                        l_retcode := LOG_ERROR(C_NO_RETROET_DATA, l_batch_id, null);
                     end if;
                  else
                     if not EVENT_AUTHORIZED (p_company, l_batch_id, C_REVAL) then
                        l_retcode := LOG_ERROR(C_NO_REVAL_DATA, l_batch_id, null);
                     end if;
                  end if;
               --------------------------------------------------------------------------------------------------------
               -- 3378028 FAS End
               --------------------------------------------------------------------------------------------------------

               elsif p_start_process = C_PROCESS_JOURNAL then
                  if not EVENT_AUTHORIZED (p_company, l_batch_id,C_ACCRUAL) then
                     l_retcode := LOG_ERROR(C_NO_ACCRUAL_DATA, l_batch_id,null);
                  end if;

               elsif p_start_process = C_PROCESS_TRANSFER then
                  if not EVENT_EXISTS (p_company, l_batch_id,NULL,C_JOURNAL) then
                     l_retcode := LOG_ERROR(C_NO_JOURNAL_DATA, l_batch_id,null);
                  end if;
               end if;

            end if;  -- l_batch_end > p_cutoff_date

      else -- l_batch_id is null (no incomplete batches)

            GET_LATEST_BATCH (p_company, l_latest_BID, l_dummy_BSD, l_latest_BED,
                              l_group_id, l_latest_upgrade);

            if l_latest_upgrade = 'Y' then
               l_upgrade_required := 'N';
               open  UPGRADE_REQUIRED;
               fetch UPGRADE_REQUIRED into l_upgrade_required;
               close UPGRADE_REQUIRED;
               if l_upgrade_required = 'Y' then
                  l_retcode := LOG_ERROR(C_INAUGURAL_MISSING,null,null);
               end if;
            else
               if l_latest_BED >= p_cutoff_date then
                  l_retcode := LOG_ERROR(C_COMPLETED_BATCH,null,null);
               end if;
               if l_latest_upgrade = 'I' and l_group_id is null then
                  l_retcode := LOG_ERROR(C_INAUGURAL_TRANSFER,null,null);
               end if;
            end if;


            if l_retcode = 0 then
               -------------------------------------------------------
               -- 3378028 FAS
               --
               -- The following section is rewritten for FAS.
               ------------------------------------------------------
               --
               -- Check that start process is a valid one.
               -- For example, the last event was Journal and  it finished on 1/15/04.  Now user select to
               -- Start from Accrual to Journal with new Cutoff date  of 2/1/04.  Company starts from revaluation.
               -- In this case, program should error out because user need to start from Reval with the new Cutoff Date.
               --
               /***********************************************/
               /*               Start from RETRO              */
               /***********************************************/
               if p_start_process = C_PROCESS_RETROET and p_do_retro = 'Y' then
                  if not EVENT_EXISTS (p_company, null, p_cutoff_date, C_REVAL) then
                     l_retcode := LOG_ERROR (C_MISSING_REVAL, null, p_cutoff_date);
                  end if;

               /***********************************************/
               /*             Start from ACCRUAL              */
               /***********************************************/
               elsif p_start_process = C_PROCESS_ACCRUAL and p_do_reval = 'Y' then
                  if EVENT_EXISTS (p_company, null, p_cutoff_date, C_REVAL) then
                     if p_do_retro = 'Y' and not EVENT_EXISTS (p_company, null, p_cutoff_date, C_RETROET) then
                        l_retcode := LOG_ERROR (C_MISSING_RETROET, null, p_cutoff_date);
                     end if;
                  else
                     l_retcode := LOG_ERROR (C_MISSING_REVAL,null, p_cutoff_date);
                  end if;

               /***********************************************/
               /*             Start from JOURNAL              */
               /***********************************************/
               elsif p_start_process = C_PROCESS_JOURNAL then
                  if p_do_reval = 'N' or (p_do_reval = 'Y' and EVENT_EXISTS (p_company, null, p_cutoff_date, C_REVAL)) then
                     if p_do_retro = 'N' or (p_do_retro = 'Y' and EVENT_EXISTS (p_company, null, p_cutoff_date, C_RETROET)) then
                        if not EVENT_EXISTS (p_company, null, p_cutoff_date, C_ACCRUAL) then
                           l_retcode := LOG_ERROR (C_MISSING_ACCRUAL, null, p_cutoff_date);
                        end if;
                     else
                        l_retcode := LOG_ERROR (C_MISSING_RETROET, null, p_cutoff_date);
                     end if;
                  else
                     l_retcode := LOG_ERROR (C_MISSING_REVAL, null, p_cutoff_date);
                  end if;

               /***********************************************/
               /*             Start from TRANSFER             */
               /***********************************************/
               elsif p_start_process = C_PROCESS_TRANSFER then
                  if p_do_reval = 'N' or (p_do_reval = 'Y' and EVENT_EXISTS (p_company, null, p_cutoff_date, C_REVAL)) then
                     if p_do_retro = 'N' or (p_do_retro = 'Y' and EVENT_EXISTS (p_company, null, p_cutoff_date, C_RETROET)) then
                        if EVENT_EXISTS(p_company, null, p_cutoff_date, C_ACCRUAL) then
                           if not EVENT_EXISTS (p_company, null, p_cutoff_date, C_JOURNAL) then
                              l_retcode:= LOG_ERROR (C_MISSING_JOURNAL, null, p_cutoff_date);
                           end if;
                        else
                           l_retcode := LOG_ERROR (C_MISSING_ACCRUAL, null, p_cutoff_date);
                        end if;
                     else
                        l_retcode := LOG_ERROR (C_MISSING_RETROET, null, p_cutoff_date);
                     end if;
                  else
                     l_retcode := LOG_ERROR (C_MISSING_REVAL, null, p_cutoff_date);
                  end if;
               end if;

            end if;  -- l_retcode = 0

      end if;  -- l_batch_id is not null

      return(l_retcode);

END CHK_ELIGIBLE_COMPANY;


/*---------------------------------------------------------------------*/
 PROCEDURE GET_PREV_NORMAL_BATCH (p_company        IN  VARCHAR2,
                                  p_curr_BED       IN  DATE,
                                  p_prev_BID       OUT NOCOPY NUMBER,
                                  p_prev_BED       OUT NOCOPY DATE) AS
/*---------------------------------------------------------------------*
 |                                                                     |
 | Finds any previous normal batch information for locking purpose     |
 | in later processes.                                                 |
 | Only Reval/Accrual journals will be included.                       |
 |                                                                     |
 *---------------------------------------------------------------------*/

   cursor prev_normal is
   select batch_id,
          period_end
   from   xtr_batches
   where  company_code           = p_company
   and    period_end             < p_curr_BED
   and    nvl(upgrade_batch,'N') = 'N'
   and    batch_type is null                                   -- RA batch only
   order by period_end desc, period_start desc, batch_id desc;

   l_dummy NUMBER;

BEGIN
   p_prev_BID  := null;
   p_prev_BED  := to_date(null);

   open  prev_normal;
   fetch prev_normal into p_prev_BID, p_prev_BED;
   close prev_normal;

   --===================================  DEBUG ===============================================--
     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('GET_PREV_NORMAL_BATCH');
        xtr_risk_debug_pkg.dlog('p_company         ' , p_company);
        xtr_risk_debug_pkg.dlog('p_curr_BED        ' , p_curr_BED);
        xtr_risk_debug_pkg.dlog('p_prev_BID        ' , p_prev_BID);
        xtr_risk_debug_pkg.dlog('p_prev_BED        ' , p_prev_BED);
        xtr_risk_debug_pkg.dpop('GET_PREV_NORMAL_BATCH');
     END IF;
   --==========================================================================================--

END GET_PREV_NORMAL_BATCH;


/*---------------------------------------------------------------------*/
 PROCEDURE GET_LATEST_BATCH (p_company        IN  VARCHAR2,
                             p_batch_id       OUT NOCOPY NUMBER,
                             p_batch_start    OUT NOCOPY DATE,
                             p_batch_end      OUT NOCOPY DATE,
                             p_gl_group_id    OUT NOCOPY NUMBER,
                             p_upgrade_batch  OUT NOCOPY VARCHAR2) AS
/*---------------------------------------------------------------------*
 |                                                                     |
 | Finds the latest batch information.                                 |
 | Only Reval/Accrual journals will be included.                       |
 |                                                                     |
 *---------------------------------------------------------------------*/
   cursor last_batch is
   select batch_id,
          period_start,
          period_end,
          gl_group_id,
          nvl(upgrade_batch,'N')
   from   xtr_batches
   where  company_code  = p_company
   and    batch_type is null                                   -- RA batch only
   order by period_end desc, period_start desc, batch_id desc;

BEGIN

   p_batch_id      := null;
   p_batch_end     := to_date(null);
   p_gl_group_id   := null;
   p_upgrade_batch := null;

   open  last_batch;
   fetch last_batch into p_batch_id, p_batch_start, p_batch_end, p_gl_group_id, p_upgrade_batch;
   close last_batch;

   --===================================  DEBUG ===============================================--
     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('GET_LATEST_BATCH');
        xtr_risk_debug_pkg.dlog('p_company         ' , p_company);
        xtr_risk_debug_pkg.dlog('p_batch_id        ' , p_batch_id);
        xtr_risk_debug_pkg.dlog('p_batch_start     ' , p_batch_start);
        xtr_risk_debug_pkg.dlog('p_batch_end       ' , p_batch_end);
        xtr_risk_debug_pkg.dlog('p_gl_group_id     ' , p_gl_group_id);
        xtr_risk_debug_pkg.dlog('p_upgrade_batch   ' , p_upgrade_batch);
        xtr_risk_debug_pkg.dpop('GET_LATEST_BATCH');
     END IF;
   --==========================================================================================--

END;



/*-----------------------------------------------------------------------------*/
 PROCEDURE GENERATE_REVAL_RATES (p_company          IN      VARCHAR2,
                                 p_batch_start      IN      DATE,
                                 p_batch_end        IN      DATE,
                                 p_prev_batch_id    IN      NUMBER,
                                 p_batch_id         IN  OUT NOCOPY NUMBER,
					-- do not pass batch id for new batch
                                 p_retcode              OUT NOCOPY NUMBER) AS
/*------------------------------------------------------------------------------*
 *                                                                              *
 * Generates the reval rates -                                                  *
 *                   calls procedure XTR_REVAL_PROCESS_P.GET_ALL_REVAL_RATES    *
 *                                                                              *
 *------------------------------------------------------------------------------*/

BEGIN
   --===================================  DEBUG ===============================================--
     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('GENERATE_REVAL_RATES - In Parameters');
        xtr_risk_debug_pkg.dlog('p_company         ' , p_company);
        xtr_risk_debug_pkg.dlog('p_batch_start     ' , p_batch_start);
        xtr_risk_debug_pkg.dlog('p_batch_end       ' , p_batch_end);
        xtr_risk_debug_pkg.dlog('p_prev_batch_id   ' , p_prev_batch_id);
        xtr_risk_debug_pkg.dlog('p_batch_id        ' , p_batch_id);
        xtr_risk_debug_pkg.dpop('GENERATE_REVAL_RATES - In Parameters');
     END IF;
   --==========================================================================================--

   p_retcode  := 0;
   if p_prev_batch_id is not null then
      p_retcode := LOCK_EVENT(p_prev_batch_id,
                              C_REVAL,
                              C_AUTH_YES,
                              C_NO_REVAL_DATA,
                              C_LOCKED_REVAL);
   end if;

   /*===================================================*/
   /*    Calculate Revaluation Rates                    */
   /*===================================================*/
   if p_retcode = 0 then
      XTR_REVAL_PROCESS_P.GET_ALL_REVAL_RATES(p_company,
                                              p_batch_start,
                                              p_batch_end,
                                              'N',     -- only generate rates for Normal batch
                                              p_batch_id);
      COMMIT;
      FND_MESSAGE.Set_Name('XTR', C_GENERATED_RATES);
      FND_MESSAGE.Set_Token('BATCH', p_batch_id);
      FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
      FND_FILE.Put_Line (FND_FILE.LOG, ' ');

   end if;

   --===================================  DEBUG ===============================================--
     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('GENERATE_REVAL_RATES - Out Parameters');
        xtr_risk_debug_pkg.dlog('p_retcode       ' , p_retcode);
        xtr_risk_debug_pkg.dpop('GENERATE_REVAL_RATES - Out Parameters');
     END IF;
   --==========================================================================================--

END GENERATE_REVAL_RATES;


/*------------------------------------------------------------------------------*/
 PROCEDURE GENERATE_REVAL_DETAILS (p_retcode       OUT NOCOPY NUMBER,
                                   p_company       IN  VARCHAR2,
                                   p_batch_start   IN  DATE,
                                   p_batch_end     IN  DATE,
                                   p_batch_id      IN  NUMBER,
                                   p_prev_batch_id IN  NUMBER) AS
/*------------------------------------------------------------------------------*
 *                                                                              *
 * Generates the reval details -                                                *
 *                   calls procedure XTR_REVAL_PROCESS_P.CALC_REVALS            *
 *                                                                              *
 *------------------------------------------------------------------------------*/

   l_errbuf   VARCHAR2(255) := null;
   l_retcode  NUMBER := 0;
   l_batch_id NUMBER := 0;

   cursor c_batch_id is
   select batch_id
   from   xtr_batches
   where  period_start = p_batch_start
   and    period_end   = p_batch_end
   and    company_code = p_company
   and    batch_type is null;           -- 3527080 exclude NRA batch


BEGIN
   --===================================  DEBUG ===============================================--
     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('GENERATE_REVAL_DETAILS - In Parameters');
        xtr_risk_debug_pkg.dlog('p_company         ' , p_company);
        xtr_risk_debug_pkg.dlog('p_batch_start     ' , p_batch_start);
        xtr_risk_debug_pkg.dlog('p_batch_end       ' , p_batch_end);
        xtr_risk_debug_pkg.dlog('p_batch_id        ' , p_batch_id);
        xtr_risk_debug_pkg.dlog('p_prev_batch_id   ' , p_prev_batch_id);
        xtr_risk_debug_pkg.dpop('GENERATE_REVAL_DETAILS - In Parameters');
     END IF;
   --==========================================================================================--

   p_retcode := 0;

   if p_prev_batch_id is not null then
      p_retcode := LOCK_EVENT(p_prev_batch_id,
                              C_REVAL,
                              C_AUTH_YES,
                              C_NO_REVAL_DATA,
                              C_LOCKED_REVAL);
   end if;

   if p_retcode = 0 then
      p_retcode := LOCK_BATCH(p_batch_id,
                              p_company,
                              C_NO_BATCH,
                              C_LOCKED_BATCH);
   end if;

   /*===================================================*/
   /*     Calculate Revaluation Details                 */
   /*===================================================*/
   if p_retcode = 0 then
      XTR_REVAL_PROCESS_P.CALC_REVALS(l_errbuf,
                                      l_retcode,
                                      p_company,
                                      p_batch_id);

      --===================================  DEBUG ===============================================--
        IF xtr_risk_debug_pkg.g_Debug THEN
           xtr_risk_debug_pkg.dpush('GENERATE_REVAL_DETAILS - Retcode from CALC_REVALS');
           xtr_risk_debug_pkg.dlog('l_retcode       ' , l_retcode);
           xtr_risk_debug_pkg.dpop('GENERATE_REVAL_DETAILS - Retcode from CALC_REVALS');
        END IF;
      --==========================================================================================--

      l_retcode := nvl(l_retcode,0);

      /*=====================================================================================*/
      /*    Need to check since CALC_REVALS can return 0 if there are incomplete details     */
      /*=====================================================================================*/
      if l_retcode >= 0 then

         if p_batch_id is null then
            open  c_batch_id;
            fetch c_batch_id into l_batch_id;
            close c_batch_id;
         else
            l_batch_id := p_batch_id;
         end if;

         if REVAL_DETAILS_INCOMPLETE (p_company, p_batch_start, p_batch_end, l_batch_id) then

            FND_FILE.Put_Line (FND_FILE.LOG, ' ');
            FND_MESSAGE.Set_Name('XTR', C_INCOMPLETE_REVAL);
            FND_MESSAGE.Set_Token('BATCH', l_batch_id);
            FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
            FND_FILE.Put_Line (FND_FILE.LOG, ' ');
            p_retcode := 2;

         else
            FND_MESSAGE.Set_Name('XTR', C_GENERATED_REVAL);
            FND_MESSAGE.Set_Token('BATCH', l_batch_id);
            FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
            FND_FILE.Put_Line (FND_FILE.LOG, ' ');
            p_retcode := l_retcode;  -- return any retcode from revaluation
         end if;

      else
         rollback;
         p_retcode := 2;
      end if;

      COMMIT;

   end if;  -- p_retcode = 0

--================================  DEBUG ==================================--
     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('GENERATE_REVAL_DETAILS - Out Parameters');
        xtr_risk_debug_pkg.dlog('p_retcode       ' , p_retcode);
        xtr_risk_debug_pkg.dpop('GENERATE_REVAL_DETAILS - Out Parameters');
     END IF;
--==========================================================================--

END GENERATE_REVAL_DETAILS;

/*--------------------------------------------------------------------------*/
 PROCEDURE AUTHORIZE_REVAL_EVENT (p_retcode       OUT NOCOPY NUMBER,
                                  p_company       IN  VARCHAR2,
                                  p_batch_id      IN  NUMBER,
                                  p_prev_batch_id IN  NUMBER) AS
/*- -------------------------------------------------------------------------*
*                                                                              *
* Authorise the reval details.                                                 *
*                                                                              *
*---------------------------------------------------------------------------*/

BEGIN
--===================================  DEBUG ===============================--
     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('AUTHORIZE_REVAL_EVENT - In Parameters');
        xtr_risk_debug_pkg.dlog('p_company         ' , p_company);
        xtr_risk_debug_pkg.dlog('p_batch_id        ' , p_batch_id);
        xtr_risk_debug_pkg.dlog('p_prev_batch_id   ' , p_prev_batch_id);
        xtr_risk_debug_pkg.dpop('AUTHORIZE_REVAL_EVENT - In Parameters');
     END IF;
--==========================================================================--

   p_retcode := 0;

   if p_prev_batch_id is not null then
      p_retcode := LOCK_EVENT(p_prev_batch_id,
                              C_REVAL,
                              C_AUTH_YES,
                              C_NO_REVAL_DATA,
                              C_LOCKED_REVAL);
   end if;

   if p_retcode = 0 then
      p_retcode := LOCK_EVENT(p_batch_id,
                              C_REVAL,
                              NULL,
                              C_NO_REVAL_DATA,
                              C_LOCKED_REVAL);
   end if;

   if p_retcode = 0 then
      /*===================================================*/
      /*     Authorize Revaluation Details                 */
      /*===================================================*/
      /* 3050444 old issue 2
      update xtr_batch_events
      set    authorized        = 'Y',
             authorized_by     = fnd_global.user_id,
             authorized_on     = trunc(sysdate),
             last_updated_by   = fnd_global.user_id,
             last_update_date  = trunc(sysdate),
             last_update_login = fnd_global.user_id
      where  batch_id          = p_batch_id
      and    event_code        = C_REVAL;
      */

      -- 3050444 new issue 2
      BEGIN
         xtr_dnm_pkg.authorize(p_batch_id);
      EXCEPTION
         when others then
            p_retcode := 2;
      END;

      if p_retcode = 0 then
         COMMIT;

         FND_MESSAGE.Set_Name('XTR', C_AUTHORIZED_REVAL);
         FND_MESSAGE.Set_Token('BATCH', p_batch_id);
         FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
         FND_FILE.Put_Line (FND_FILE.LOG, ' ');

      end if;

   end if;

--=================================  DEBUG ===================================--
     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('AUTHORIZE_REVAL_EVENT - Out Parameters');
        xtr_risk_debug_pkg.dlog('p_retcode       ' , p_retcode);
        xtr_risk_debug_pkg.dpop('AUTHORIZE_REVAL_EVENT - Out Parameters');
     END IF;
--===========================================================================--

END AUTHORIZE_REVAL_EVENT;

/*--------------------------------------------------------------------------*/
 PROCEDURE GENERATE_RETRO_DETAILS (p_retcode       OUT NOCOPY NUMBER,
                                   p_company       IN  VARCHAR2,
                                   p_batch_start   IN  DATE,
                                   p_batch_end     IN  DATE,
                                   p_batch_id      IN  NUMBER,
                                   p_prev_batch_id IN  NUMBER) AS
/*----------------------------------------------------------------------------*
*                                                                              *
* Bug 3378028  FAS                                                             *
* Generates the retro details -                                                *
*                   call procedure XTR_HEDGE_PROCESS_P.RETRO_EFF_TEST          *
*                                                                              *
*-----------------------------------------------------------------------------*/

   l_errbuf   VARCHAR2(255) := null;
   l_retcode  NUMBER := 0;
   l_batch_id NUMBER := 0;

 BEGIN
   --===================================  DEBUG ===============================================--
     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('GENERATE_RETRO_DETAILS - In Parameters');
        xtr_risk_debug_pkg.dlog('p_company         ' , p_company);
        xtr_risk_debug_pkg.dlog('p_batch_start     ' , p_batch_start);
        xtr_risk_debug_pkg.dlog('p_batch_end       ' , p_batch_end);
        xtr_risk_debug_pkg.dlog('p_batch_id        ' , p_batch_id);
        xtr_risk_debug_pkg.dlog('p_prev_batch_id   ' , p_prev_batch_id);
        xtr_risk_debug_pkg.dpop('GENERATE_RETRO_DETAILS - In Parameters');
     END IF;
   --==========================================================================================--

   p_retcode := 0;

   if p_prev_batch_id is not null then
      -----------------------------------------------------
      -- If previous batch has RETROET event
      -----------------------------------------------------
      if  EVENT_EXISTS(p_company, p_prev_batch_id, null, C_RETROET)  then
          p_retcode := LOCK_EVENT(p_prev_batch_id,
                                  C_RETROET,
                                  C_AUTH_YES,
                                  C_NO_RETROET_DATA,
                                  C_LOCKED_RETROET);

      -----------------------------------------------------
      -- If previous batch does not have RETROET event
      -----------------------------------------------------
      else
         if not EVENT_EXISTS(p_company, p_prev_batch_id, null, C_ACCRUAL)  then
            ------------------------------------------------------
            -- Previous batch Should have ACCRUAL event, if not,
            -- the following will fail because RETROET is missing.
            -- THIS IS INTENDED.
            ------------------------------------------------------
            p_retcode := LOCK_EVENT(p_prev_batch_id,
                                    C_RETROET,
                                    NULL,
                                    C_NO_RETROET_DATA,
                                    C_LOCKED_RETROET);
         end if;
      end if;
   end if;

   if p_retcode = 0 then
      p_retcode := LOCK_EVENT(p_batch_id,
                              C_REVAL,
                              C_AUTH_YES,
                              C_NO_REVAL_DATA,
                              C_LOCKED_REVAL);

   end if;

   if p_retcode = 0 then
      XTR_HEDGE_PROCESS_P.RETRO_EFF_TEST(l_errbuf,
                                         l_retcode,
                                         p_company,
                                         p_batch_id);

      --===================================  DEBUG ===============================================--
        IF xtr_risk_debug_pkg.g_Debug THEN
           xtr_risk_debug_pkg.dpush('GENERATE_RETRO_DETAILS - Retcode from RETRO_EFF_TEST');
           xtr_risk_debug_pkg.dlog('l_retcode       ' , l_retcode);
           xtr_risk_debug_pkg.dpop('GENERATE_RETRO_DETAILS - Retcode from RETRO_EFF_TEST');
        END IF;
      --==========================================================================================--

      l_retcode := nvl(l_retcode,0);

      /*=============================================================*/
      /*    Check if retrospective tests has incomplete details      */
      /*=============================================================*/
      if l_retcode = 0 then  -- no special requirement for FAILURE/WARNING setting in retro process.

         if RETRO_DETAILS_INCOMPLETE(p_company,  p_batch_start, p_batch_end,p_batch_id) then
            FND_FILE.Put_Line (FND_FILE.LOG, ' ');
            FND_MESSAGE.Set_Name('XTR', C_INCOMPLETE_RETROET);
            FND_MESSAGE.Set_Token('BATCH', p_batch_id);
            FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
            FND_FILE.Put_Line (FND_FILE.LOG, ' ');
            p_retcode := 2;

         else

            FND_MESSAGE.Set_Name('XTR', C_GENERATED_RETROET);
            FND_MESSAGE.Set_Token('BATCH', p_batch_id);
            FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
            FND_FILE.Put_Line (FND_FILE.LOG, ' ');
            p_retcode := l_retcode;

         end if;

      else
         rollback;
         p_retcode := 2;
      end if;

      COMMIT;

   end if;  -- p_retcode = 0

   --===================================  DEBUG ===============================================--
     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('GENERATE_RETRO_DETAILS - Out Parameters');
        xtr_risk_debug_pkg.dlog('p_retcode       ' , p_retcode);
        xtr_risk_debug_pkg.dpop('GENERATE_RETRO_DETAILS - Out Parameters');
     END IF;
   --==========================================================================================--

 END GENERATE_RETRO_DETAILS;



/*----------------------------------------------------------------------------*/
 PROCEDURE AUTHORIZE_RETRO_EVENT (p_retcode       OUT NOCOPY NUMBER,
                                  p_company       IN  VARCHAR2,
                                  p_batch_id      IN  NUMBER,
                                  p_prev_batch_id IN  NUMBER) AS
/*-----------------------------------------------------------------------------*
*                                                                              *
* Bug 3378028  FAS                                                             *
* Authorise the retro details.                                                 *
*                                                                              *
*-----------------------------------------------------------------------------*/
 BEGIN

--===================================  DEBUG =================================--
     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('AUTHORIZE_RETRO_EVENT - In Parameters');
        xtr_risk_debug_pkg.dlog('p_company         ' , p_company);
        xtr_risk_debug_pkg.dlog('p_batch_id        ' , p_batch_id);
        xtr_risk_debug_pkg.dlog('p_prev_batch_id   ' , p_prev_batch_id);
        xtr_risk_debug_pkg.dpop('AUTHORIZE_RETRO_EVENT - In Parameters');
     END IF;
--============================================================================--

   p_retcode := 0;

   -------------------------------------------------------------
   -- ONLY needed if previous batch has RETROET event
   -------------------------------------------------------------
   if p_prev_batch_id is not null then
      if  EVENT_EXISTS(p_company, p_prev_batch_id, null, C_RETROET)  then
          ----------------------------------------------
          -- previous batch might not have RETROET event
          ----------------------------------------------
          p_retcode := LOCK_EVENT(p_prev_batch_id,
                                  C_RETROET,
                                  C_AUTH_YES,
                                  C_NO_RETROET_DATA,
                                  C_LOCKED_RETROET);
      else
         if not EVENT_EXISTS(p_company, p_prev_batch_id, null, C_ACCRUAL)  then
            ------------------------------------------------------
            -- Previous batch should have ACCRUAL event, so below
            -- is intended to fail because RETROET is missing.
            ------------------------------------------------------
            p_retcode := LOCK_EVENT(p_prev_batch_id,
                                    C_RETROET,
                                    NULL,
                                    C_NO_RETROET_DATA,
                                    C_LOCKED_RETROET);
         end if;
      end if;
   end if;

   ------------------------------
   -- Locks current RETROET event
   ------------------------------
   if p_retcode = 0 then
      p_retcode := LOCK_EVENT(p_batch_id,
                              C_RETROET,
                              NULL,
                              C_NO_RETROET_DATA,
                              C_LOCKED_RETROET);
   end if;

   if p_retcode = 0 then
      /*===================================================*/
      /*     Authorize Retrospective Details               */
      /*===================================================*/

      BEGIN

         XTR_HEDGE_PROCESS_P.AUTHORIZE(p_company, p_batch_id);

      EXCEPTION
         when others then
            p_retcode := 2;
      END;

      COMMIT;
      FND_MESSAGE.Set_Name('XTR', C_AUTHORIZED_RETROET);
      FND_MESSAGE.Set_Token('BATCH', p_batch_id);
      FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
      FND_FILE.Put_Line (FND_FILE.LOG, ' ');

   end if;

--===================================  DEBUG =================================--
     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('AUTHORIZE_RETRO_EVENT - Out Parameters');
        xtr_risk_debug_pkg.dlog('p_retcode       ' , p_retcode);
        xtr_risk_debug_pkg.dpop('AUTHORIZE_RETRO_EVENT - Out Parameters');
     END IF;
--============================================================================--

 END AUTHORIZE_RETRO_EVENT;

/*------------------------------------------------------------------------------*/
 PROCEDURE GENERATE_ACCRUAL_DETAILS (p_retcode       OUT NOCOPY NUMBER,
                                     p_company       IN  VARCHAR2,
                                     p_do_reval      IN  VARCHAR2,
                                     p_do_retro      IN  VARCHAR2,-- 3378028 FAS
                                     p_batch_start   IN  DATE,
                                     p_batch_end     IN  DATE,
                                     p_batch_id      IN  OUT NOCOPY NUMBER,
					-- do not pass batch id for new batch
                                     p_prev_batch_id IN  NUMBER) AS
/*------------------------------------------------------------------------------*
 *                                                                              *
 * Generates the accrual details -                                              *
 *      calls procedure XTR_ACCRUAL_PROCESS_P.CALCULATE_ACCRUAL_AMORTISATION    *
 *                                                                              *
 *------------------------------------------------------------------------------*/

   cursor cur_new_BID is
   select batch_id
   from   xtr_batches
   where  company_code = p_company
   and    period_start = p_batch_start
   and    period_end   = p_batch_end
   and    batch_type is null;           -- 3527080 exclude NRA batch

   l_errbuf  VARCHAR2(255) := null;

BEGIN
   --===================================  DEBUG ===============================================--
     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('GENERATE_ACCRUAL_DETAILS - In Parameters');
        xtr_risk_debug_pkg.dlog('p_company         ' , p_company);
        xtr_risk_debug_pkg.dlog('p_do_reval        ' , p_do_reval);
        xtr_risk_debug_pkg.dlog('p_do_retro        ' , p_do_retro);
        xtr_risk_debug_pkg.dlog('p_batch_start     ' , p_batch_start);
        xtr_risk_debug_pkg.dlog('p_batch_end       ' , p_batch_end);
        xtr_risk_debug_pkg.dlog('p_batch_id        ' , p_batch_id);
        xtr_risk_debug_pkg.dlog('p_prev_batch_id   ' , p_prev_batch_id);
        xtr_risk_debug_pkg.dpop('GENERATE_ACCRUAL_DETAILS - In Parameters');
     END IF;
   --==========================================================================================--

   p_retcode := 0;

   if p_prev_batch_id is not null then
      p_retcode := LOCK_EVENT(p_prev_batch_id,
                              C_ACCRUAL,
                              C_AUTH_YES,
                              C_NO_ACCRUAL_DATA,
                              C_LOCKED_ACCRUAL);
   end if;

   if p_retcode = 0 then
      if p_do_reval = 'Y' then
         if p_do_retro = 'Y' then   -- 3378028 FAS  Extra locking for Retrospective Testing.
            p_retcode := LOCK_EVENT(p_batch_id,
                                    C_RETROET,
                                    C_AUTH_YES,
                                    C_NO_RETROET_DATA,
                                    C_LOCKED_RETROET);
         else
            p_retcode := LOCK_EVENT(p_batch_id,
                                    C_REVAL,
                                    C_AUTH_YES,
                                    C_NO_REVAL_DATA,
                                    C_LOCKED_REVAL);
         end if;
      end if;
   end if;

   if p_retcode = 0 then
      /*===================================================*/
      /*     Calculate Accrual Details                     */
      /*===================================================*/
      XTR_ACCRUAL_PROCESS_P.CALCULATE_ACCRUAL_AMORTISATION(l_errbuf,
                                                           p_retcode,
                                                           p_company,
                                                           p_batch_id, -- no batch id for new batch
                                                           FND_DATE.date_to_canonical(p_batch_start),
                                                           FND_DATE.date_to_canonical(p_batch_end),
                                                           'N');
      --===================================  DEBUG ===============================================--
        IF xtr_risk_debug_pkg.g_Debug THEN
           xtr_risk_debug_pkg.dpush('GENERATE_ACCRUAL_DETAILS - Retcode from CALCULATE_ACCRUAL_AMORTISATION');
           xtr_risk_debug_pkg.dlog('p_retcode       ' , p_retcode);
           xtr_risk_debug_pkg.dpop('GENERATE_ACCRUAL_DETAILS - Retcode from CALCULATE_ACCRUAL_AMORTISATION');
        END IF;
      --==========================================================================================--

      p_retcode := nvl(p_retcode,0);  -- floating rate bond may return '1' as a warning

      if p_retcode = -1 then
         rollback;
         p_retcode := 2;

      else

         if p_batch_id is null then
            open  cur_new_BID;
            fetch cur_new_BID into p_batch_id;
            close cur_new_BID;
         end if;

         FND_MESSAGE.Set_Name('XTR', C_GENERATED_ACCRUAL);
         FND_MESSAGE.Set_Token('BATCH', p_batch_id);
         FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
         FND_FILE.Put_Line (FND_FILE.LOG, ' ');

      end if;

   end if;

   --===================================  DEBUG ===============================================--
     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('GENERATE_ACCRUAL_DETAILS - Out Parameters');
        xtr_risk_debug_pkg.dlog('p_retcode       ' , p_retcode);
        xtr_risk_debug_pkg.dpop('GENERATE_ACCRUAL_DETAILS - Out Parameters');
     END IF;
   --==========================================================================================--

END GENERATE_ACCRUAL_DETAILS;


/*------------------------------------------------------------------------------*/
 PROCEDURE AUTHORIZE_ACCRUAL_EVENT (p_retcode       OUT NOCOPY NUMBER,
                                    p_company       IN  VARCHAR2,
                                    p_batch_id      IN  NUMBER,
                                    p_prev_batch_id IN  NUMBER) AS
/*------------------------------------------------------------------------------*
 *                                                                              *
 * Authorise accrual details.                                                   *
 *                                                                              *
 *------------------------------------------------------------------------------*/

   l_rowid   ROWID;

BEGIN
   --===================================  DEBUG ===============================================--
     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('AUTHORIZE_ACCRUAL_EVENT - In Parameters');
        xtr_risk_debug_pkg.dlog('p_company         ' , p_company);
        xtr_risk_debug_pkg.dlog('p_batch_id        ' , p_batch_id);
        xtr_risk_debug_pkg.dlog('p_prev_batch_id   ' , p_prev_batch_id);
        xtr_risk_debug_pkg.dpop('AUTHORIZE_ACCRUAL_EVENT - In Parameters');
     END IF;
   --==========================================================================================--

   p_retcode := 0;

   if p_prev_batch_id is not null then
      p_retcode := LOCK_EVENT(p_prev_batch_id,
                              C_ACCRUAL,
                              C_AUTH_YES,
                              C_NO_ACCRUAL_DATA,
                              C_LOCKED_ACCRUAL);
   end if;

   if p_retcode = 0 then
      p_retcode := LOCK_EVENT(p_batch_id,
                              C_ACCRUAL,
                              NULL,
                              C_NO_ACCRUAL_DATA,
                              C_LOCKED_ACCRUAL);
   end if;

   if p_retcode = 0 then
      /*===================================================*/
      /*     Authorize Accrual Details                     */
      /*===================================================*/
      update xtr_batch_events
      set    authorized        = 'Y',
             authorized_by     = fnd_global.user_id,
             authorized_on     = trunc(sysdate),
             last_updated_by   = fnd_global.user_id,
             last_update_date  = trunc(sysdate),
             last_update_login = fnd_global.user_id
      where  batch_id          = p_batch_id
      and    event_code        = C_ACCRUAL;

      COMMIT;

      FND_MESSAGE.Set_Name('XTR', C_AUTHORIZED_ACCRUAL);
      FND_MESSAGE.Set_Token('BATCH', p_batch_id);
      FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
      FND_FILE.Put_Line (FND_FILE.LOG, ' ');

   end if;

   --===================================  DEBUG ===============================================--
     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('AUTHORIZE_ACCRUAL_EVENT - Out Parameters');
        xtr_risk_debug_pkg.dlog('p_retcode       ' , p_retcode);
        xtr_risk_debug_pkg.dpop('AUTHORIZE_ACCRUAL_EVENT - Out Parameters');
     END IF;
   --==========================================================================================--

END AUTHORIZE_ACCRUAL_EVENT;



/*------------------------------------------------------------------------------*/
 PROCEDURE GENERATE_JOURNAL_DETAILS (p_retcode        OUT NOCOPY NUMBER,
                                     p_company        IN  VARCHAR2,
                                     p_batch_id       IN  NUMBER,
                                     p_prev_batch_id  IN  NUMBER) AS
/*------------------------------------------------------------------------------*
 *                                                                              *
 * Generates the journal details -                                              *
 *      calls procedure  XTR_JOURNAL_PROCESS_P.JOURNALS                         *
 *                                                                              *
 *                                                                              *
 *------------------------------------------------------------------------------*/
   l_errbuf  VARCHAR2(255) := null;

BEGIN
   --===================================  DEBUG ===============================================--
     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('GENERATE_JOURNAL_DETAILS - In Parameters');
        xtr_risk_debug_pkg.dlog('p_company         ' , p_company);
        xtr_risk_debug_pkg.dlog('p_batch_id        ' , p_batch_id);
        xtr_risk_debug_pkg.dlog('p_prev_batch_id   ' , p_prev_batch_id);
        xtr_risk_debug_pkg.dpop('GENERATE_JOURNAL_DETAILS - In Parameters');
     END IF;
   --==========================================================================================--

   p_retcode := 0;

   if p_prev_batch_id is not null then
      p_retcode := LOCK_EVENT(p_prev_batch_id,
                              C_JOURNAL,
                              NULL,
                              C_NO_JOURNAL_DATA,
                              C_LOCKED_JOURNAL);
   end if;

   if p_retcode = 0 then
      p_retcode := LOCK_EVENT(p_batch_id,
                              C_ACCRUAL,
                              C_AUTH_YES,
                              C_NO_ACCRUAL_DATA,
                              C_LOCKED_ACCRUAL);
   end if;

   if p_retcode = 0 then
      /*===================================================*/
      /*     Calculate Journal Details                     */
      /*===================================================*/
      XTR_JOURNAL_PROCESS_P.JOURNALS(l_errbuf,
                                     p_retcode,
                                     null,              -- p_source_option
                                     p_company,
                                     p_batch_id,        -- p_batch_id_from
                                     p_batch_id,        -- p_batch_id_to
                                     null,              -- p_cutoff_date
                                     null,              -- p_dummy_date
                                     C_GENERATE,        -- p_processing_option
                                     null,              -- p_dummy_proc_opt
                                     null,
                                     'N');              -- p_incl_transferred

      p_retcode := nvl(p_retcode,0);

      if p_retcode = -1 then
         rollback;
         p_retcode := 2;

      else

         FND_MESSAGE.Set_Name('XTR', C_GENERATED_JOURNAL);
         FND_MESSAGE.Set_Token('BATCH', p_batch_id);
         FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
         FND_FILE.Put_Line (FND_FILE.LOG, ' ');

      end If;

   end if;

   --===================================  DEBUG ===============================================--
     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('GENERATE_JOURNAL_DETAILS - Out Parameters');
        xtr_risk_debug_pkg.dlog('p_retcode       ' , p_retcode);
        xtr_risk_debug_pkg.dpop('GENERATE_JOURNAL_DETAILS - Out Parameters');
     END IF;
   --==========================================================================================--

END GENERATE_JOURNAL_DETAILS;


/*------------------------------------------------------------------------------*/
 PROCEDURE TRANSFER_JOURNALS (p_retcode        OUT NOCOPY NUMBER,
                              p_company        IN  VARCHAR2,
                              p_batch_id       IN  NUMBER,
                              p_prev_batch_id  IN  NUMBER,
                              p_closed_periods IN  VARCHAR2) AS
/*------------------------------------------------------------------------------*
 *                                                                              *
 *  Transfer the journal details -                                              *
 *      calls procedure  XTR_JOURNAL_PROCESS_P.JOURNALS                         *
 *  This should only be called if process starts and ends after                 *
 *  transfer of journals.                                                       *
 *                                                                              *
 *------------------------------------------------------------------------------*/
   l_errbuf  VARCHAR2(255) := null;

BEGIN
   --===================================  DEBUG ===============================================--
     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('TRANSFER_JOURNALS - In Parameters');
        xtr_risk_debug_pkg.dlog('p_company         ' , p_company);
        xtr_risk_debug_pkg.dlog('p_batch_id        ' , p_batch_id);
        xtr_risk_debug_pkg.dlog('p_prev_batch_id   ' , p_prev_batch_id);
        xtr_risk_debug_pkg.dlog('p_closed_periods  ' , p_closed_periods);
        xtr_risk_debug_pkg.dpop('TRANSFER_JOURNALS - In Parameters');
     END IF;
   --==========================================================================================--

   p_retcode := 0;

   p_retcode := LOCK_EVENT(p_batch_id,
                           C_JOURNAL,
                           NULL,
                           C_NO_JOURNAL_DATA,
                           C_LOCKED_JOURNAL);

   if p_retcode = 0 then
      /*===================================================*/
      /*     Transfer Journal Details                      */
      /*===================================================*/
      XTR_JOURNAL_PROCESS_P.JOURNALS(l_errbuf,
                                     p_retcode,
                                     null,            -- p_source_option
                                     p_company,
                                     p_batch_id,      -- p_batch_id_from
                                     p_batch_id,      -- p_batch_id_to
                                     null,            -- p_cutoff_date
                                     null,            -- p_dummy_date
                                     C_TRANSFER,      -- p_processing_option
                                     null,            -- p_dummy_proc_opt
                                     p_closed_periods,
                                     'N',            -- p_incl_transferred
                                     G_MULTIPLE_ACCT); -- Bug 4639287 Multiple account Transfer

      p_retcode := nvl(p_retcode,0);

      if p_retcode = -1 then
         rollback;
         p_retcode := 2;

      else

         FND_MESSAGE.Set_Name('XTR', C_TRANSFERRED_JOURNAL);
         FND_MESSAGE.Set_Token('BATCH', p_batch_id);
         FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
         FND_FILE.Put_Line (FND_FILE.LOG, ' ');

      end If;

   end if;

   --===================================  DEBUG ===============================================--
     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('TRANSFER_JOURNALS - Out Parameters');
        xtr_risk_debug_pkg.dlog('p_retcode       ' , p_retcode);
        xtr_risk_debug_pkg.dpop('TRANSFER_JOURNALS - Out Parameters');
     END IF;
   --==========================================================================================--

END TRANSFER_JOURNALS;


/*------------------------------------------------------------------------------*/
 PROCEDURE REVAL_SUBPROCESS (p_retcode       OUT NOCOPY NUMBER,
                             p_company       IN  VARCHAR2,
                             p_cutoff_date   IN  DATE) AS
/*------------------------------------------------------------------------------*
 *                                                                              *
 * Process incomplete reval batches.                                            *
 * Only Reval/Accrual journals will be included.                                *
 *                                                                              *
 *------------------------------------------------------------------------------*/

   cursor INCOMPLETE_REVAL_BATCH is
   select batch_id,
          period_start,
          period_end
   from   xtr_batches a
   where  company_code = p_company
   and    period_end  <= p_cutoff_date
   and    batch_type is null
   and    nvl(upgrade_batch,'N') = 'N'
   and    not exists (select 1
                      from   xtr_batch_events b
                      where  b.batch_id          = a.batch_id
                      and    event_code          = C_REVAL
                      and    nvl(authorized,'N') = 'Y')
   order by period_end, period_start;

   l_sub_retcode  NUMBER := 0;
   l_batch_id     NUMBER;
   l_batch_start  DATE;
   l_batch_end    DATE;
   l_prvBID       NUMBER;
   l_prvBED       DATE;

BEGIN
   --===================================  DEBUG ===============================================--
     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('REVAL_SUBPROCESS - In Parameters');
        xtr_risk_debug_pkg.dlog('p_company         ' , p_company);
        xtr_risk_debug_pkg.dlog('p_cutoff_date     ' , p_cutoff_date);
        xtr_risk_debug_pkg.dpop('REVAL_SUBPROCESS - In Parameters');
     END IF;
   --==========================================================================================--

   p_retcode     := 0;
   l_prvBID      := null;

   open  INCOMPLETE_REVAL_BATCH;
   fetch INCOMPLETE_REVAL_BATCH into l_batch_id, l_batch_start, l_batch_end;
   while INCOMPLETE_REVAL_BATCH%FOUND and p_retcode <> 2 loop

      if l_prvBID is null then
         GET_PREV_NORMAL_BATCH(p_company, l_batch_end, l_prvBID, l_prvBED);
      end if;

      if not EVENT_EXISTS(p_company, l_batch_id, NULL, C_REVAL) then
         if not EVENT_EXISTS(p_company, l_batch_id, NULL, C_RATES) then
            GENERATE_REVAL_RATES(p_company,
                                 l_batch_start,
                                 l_batch_end,
                                 l_prvBID,
                                 l_batch_id,
                                 l_sub_retcode);
            p_retcode := greatest(l_sub_retcode, p_retcode);
         end if;

         if p_retcode = 0 then
            GENERATE_REVAL_DETAILS(l_sub_retcode,
                                   p_company,
                                   l_batch_start,
                                   l_batch_end,
                                   l_batch_id,
                                   l_prvBID);
            p_retcode := greatest(l_sub_retcode, p_retcode);
         end if;
      end if;

      if p_retcode <> 2 then
         AUTHORIZE_REVAL_EVENT(l_sub_retcode,
                               p_company,
                               l_batch_id,
                               l_prvBID);
         p_retcode := greatest(l_sub_retcode, p_retcode);

         if p_retcode <> 2 then
            l_prvBID := l_batch_id;
            l_prvBED := l_batch_end;
            fetch INCOMPLETE_REVAL_BATCH into l_batch_id, l_batch_start, l_batch_end;
         end if;

      end if;

   end loop;

   close INCOMPLETE_REVAL_BATCH;

   --===================================  DEBUG ===============================================--
     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('REVAL_SUBPROCESS - Out Parameters');
        xtr_risk_debug_pkg.dlog('p_retcode       ' , p_retcode);
        xtr_risk_debug_pkg.dpop('REVAL_SUBPROCESS - Out Parameters');
     END IF;
   --==========================================================================================--

END REVAL_SUBPROCESS;


/*------------------------------------------------------------------------------*/
 PROCEDURE CREATE_NEW_REVAL (p_retcode       OUT NOCOPY NUMBER,
                             p_company       IN  VARCHAR2,
                             p_incomplete    IN  VARCHAR2,
                             p_cutoff_date   IN  DATE) AS
/*------------------------------------------------------------------------------*
 *  Creates a new reval batch.                                                  *
 *  Only Reval/Accrual journals will be included.                               *
 *                                                                              *
 *------------------------------------------------------------------------------*/

   l_upgrade        VARCHAR2(1) := null;
   l_sub_retcode    NUMBER      := 0;
   l_batch_id       NUMBER;
   l_period_start   DATE;
   l_lastBSD        DATE;
   l_lastBED        DATE;
   l_prvBID         NUMBER := null;
   l_dummy_date     DATE;
   l_dummy_BID      NUMBER;
   l_dummy_id       NUMBER;

BEGIN
   --===================================  DEBUG ===============================================--
     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('CREATE_NEW_REVAL - In Parameters');
        xtr_risk_debug_pkg.dlog('p_company         ' , p_company);
        xtr_risk_debug_pkg.dlog('p_incomplete      ' , p_incomplete);
        xtr_risk_debug_pkg.dlog('p_cutoff_date     ' , p_cutoff_date);
        xtr_risk_debug_pkg.dpop('CREATE_NEW_REVAL - In Parameters');
     END IF;
   --==========================================================================================--

   p_retcode     := 0;

   GET_LATEST_BATCH (p_company, l_dummy_BID, l_lastBSD, l_lastBED, l_dummy_id, l_upgrade);

   ----------------------------------------------------------------------------------
   -- Only perform for a new batch if cutoff date is higher than last batch end date
   ----------------------------------------------------------------------------------
 --if p_incomplete = 'N' or (p_incomplete = 'Y' and l_lastBED < p_cutoff_date) then
   if ((p_incomplete = 'N' and nvl(l_lastBED,p_cutoff_date) <= p_cutoff_date and
        not EVENT_EXISTS (p_company, null,p_cutoff_date,C_RATES))
   or  (p_incomplete = 'Y' and l_lastBED < p_cutoff_date)) then

         if nvl(l_upgrade,'Y') = 'N' then
            GET_PREV_NORMAL_BATCH(p_company,p_cutoff_date,l_prvBID,l_dummy_date); -- l_lastBED
         end if;

         if l_upgrade is not null then
            if l_lastBED >= p_cutoff_date then
               FND_MESSAGE.Set_Name('XTR', C_COMPLETED_BATCH);
               FND_MESSAGE.Set_Token('BATCH_END', to_char(p_cutoff_date));
               FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
               FND_FILE.Put_Line (FND_FILE.LOG, ' ');
               p_retcode := 2;
            else
               l_period_start := l_lastBED + 1;
            end if;

         else  -- First batch

            l_period_start := GET_PARTY_CREATED_ON (p_company);

            -------------------------------------------------------
            -- In case cutoff date is earlier than created_on
            -------------------------------------------------------
            l_period_start := least(l_period_start, p_cutoff_date);

         end if;

         if p_retcode = 0 then

            GENERATE_REVAL_RATES(p_company,
                                 l_period_start,
                                 p_cutoff_date,
                                 l_prvBID,
                                 l_batch_id,
                                 l_sub_retcode);
            p_retcode := greatest(l_sub_retcode, p_retcode);

            if p_retcode = 0 then
               GENERATE_REVAL_DETAILS(l_sub_retcode,
                                      p_company,
                                      l_period_start,
                                      p_cutoff_date,
                                      l_batch_id,
                                      l_prvBID);
               p_retcode := greatest(l_sub_retcode, p_retcode);
            end if;

            if p_retcode <> 2 then
               AUTHORIZE_REVAL_EVENT(l_sub_retcode,
                                     p_company,
                                     l_batch_id,
                                     l_prvBID);
               p_retcode := greatest(l_sub_retcode, p_retcode);

            end if;

            if p_retcode = -1 then  -- just in case
               p_retcode := 2;
            elsif p_retcode <> 2 then
               FND_MESSAGE.Set_Name('XTR', C_NEW_BATCH);
               FND_MESSAGE.Set_Token('BATCH', l_batch_id);
               FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
               FND_FILE.Put_Line (FND_FILE.LOG, ' ');
            end if;

         end if; -- p_retcode = 0

   end if;

   --===================================  DEBUG ===============================================--
     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('CREATE_NEW_REVAL - Out Parameters');
        xtr_risk_debug_pkg.dlog('p_retcode       ' , p_retcode);
        xtr_risk_debug_pkg.dpop('CREATE_NEW_REVAL - Out Parameters');
     END IF;
   --==========================================================================================--

END CREATE_NEW_REVAL;


/*------------------------------------------------------------------------------*/
 PROCEDURE RETRO_SUBPROCESS   (p_retcode       OUT NOCOPY NUMBER,
                               p_company       IN  VARCHAR2,
                               p_cutoff_date   IN  DATE) AS
/*------------------------------------------------------------------------------*
 *                                                                              *
 * Bug 3378028  FAS                                                             *
 * Process incomplete retrospective test batches.                               *
 * Only Reval/Accrual journals will be included.                                *
 *                                                                              *
 *------------------------------------------------------------------------------*/
   cursor INCOMPLETE_RETRO_BATCH is
   select batch_id,
          period_start,
          period_end
   from   xtr_batches a
   where  company_code = p_company
   and    period_end  <= p_cutoff_date
   and    batch_type is null
   and    nvl(upgrade_batch,'N') = 'N'
   and    not exists (select 1
                      from   XTR_BATCH_EVENTS b
                      where  b.batch_id          = a.batch_id
                      and    event_code          = C_RETROET
                      and    nvl(authorized,'N') = 'Y')
   and    not exists (select 1
                      from   XTR_BATCH_EVENTS b
                      where  b.batch_id          = a.batch_id
                      and    event_code          = C_ACCRUAL)   -- Need not check for AUTHORISED flag
   order by period_end, period_start;

   l_sub_retcode  NUMBER := 0;
   l_batch_id     NUMBER;
   l_batch_start  DATE;
   l_batch_end    DATE;
   l_prvBID       NUMBER;
   l_prvBED       DATE;

BEGIN
   --===================================  DEBUG ===============================================--
     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('RETRO_SUBPROCESS   - In Parameters');
        xtr_risk_debug_pkg.dlog('p_company         ' , p_company);
        xtr_risk_debug_pkg.dlog('p_cutoff_date     ' , p_cutoff_date);
        xtr_risk_debug_pkg.dpop('RETRO_SUBPROCESS   - In Parameters');
     END IF;
   --==========================================================================================--

   p_retcode     := 0;
   l_prvBID      := null;

   open  INCOMPLETE_RETRO_BATCH;
   fetch INCOMPLETE_RETRO_BATCH into l_batch_id, l_batch_start, l_batch_end;
   while INCOMPLETE_RETRO_BATCH%FOUND and p_retcode <> 2 loop

      if l_prvBID is null then
         GET_PREV_NORMAL_BATCH(p_company, l_batch_end, l_prvBID, l_prvBED);

      end if;

      if not EVENT_EXISTS(p_company, l_batch_id, NULL, C_RETROET) then

         GENERATE_RETRO_DETAILS(l_sub_retcode,
                                p_company,
                                l_batch_start,
                                l_batch_end,
                                l_batch_id,
                                l_prvBID);
         p_retcode := greatest(l_sub_retcode, p_retcode);
      end if;

      if p_retcode <> 2 then

         if RETRO_DETAILS_INCOMPLETE (p_company, l_batch_start, l_batch_end, l_batch_id) then
            -----------------------------------------------------------------------------
            -- FAS 3378028
            -- If start from REVAL/RETRO and end at RETRO, but the first incomplete batch
            -- has RETRO event but some of the details are incomplete.
            -----------------------------------------------------------------------------
            FND_MESSAGE.Set_Name('XTR', C_INCOMPLETE_RETROET);
            FND_MESSAGE.Set_Token('BATCH', l_batch_id);
            FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
            FND_FILE.Put_Line (FND_FILE.LOG, ' ');
            p_retcode := 2;  -- should this be WARNING or ERROR

         else
            AUTHORIZE_RETRO_EVENT(l_sub_retcode,
                                  p_company,
                                  l_batch_id,
                                  l_prvBID);
            p_retcode := greatest(l_sub_retcode, p_retcode);
	    if p_retcode <> 2 then
               l_prvBID   := l_batch_id;
               l_prvBED   := l_batch_end;
               l_batch_id := null;
               fetch INCOMPLETE_RETRO_BATCH into l_batch_id, l_batch_start, l_batch_end;
            end if;
         end if;

      end if;
   end loop;
   close INCOMPLETE_RETRO_BATCH;

   --===================================  DEBUG ===============================================--
     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('RETRO_SUBPROCESS - Out Parameters');
        xtr_risk_debug_pkg.dlog('p_retcode       ' , p_retcode);
        xtr_risk_debug_pkg.dpop('RETRO_SUBPROCESS - Out Parameters');
     END IF;
   --==========================================================================================--

END RETRO_SUBPROCESS;


/*------------------------------------------------------------------------------*/
 PROCEDURE ACCRUAL_SUBPROCESS (p_retcode       OUT NOCOPY NUMBER,
                               p_company       IN  VARCHAR2,
                               p_do_reval      IN  VARCHAR2,
                               p_do_retro      IN  VARCHAR2,  -- 3378028 FAS
                               p_cutoff_date   IN  DATE) AS
/*------------------------------------------------------------------------------*
 *                                                                              *
 * Process incomplete accrual batches.                                          *
 *  Only Reval/Accrual journals will be included.                               *
 *                                                                              *
 *------------------------------------------------------------------------------*/

   cursor INCOMPLETE_ACCRUAL_BATCH is
   select batch_id,
          period_start,
          period_end
   from   xtr_batches a
   where  company_code = p_company
   and    period_end  <= p_cutoff_date
   and    batch_type is null
   and    nvl(upgrade_batch,'N') = 'N'
   and    not exists (select 1
                      from   XTR_BATCH_EVENTS b
                      where  b.batch_id          = a.batch_id
                      and    event_code          = C_ACCRUAL
                      and    nvl(authorized,'N') = 'Y')
   order by period_end, period_start;

   l_sub_retcode  NUMBER := 0;
   l_batch_id     NUMBER;
   l_batch_start  DATE;
   l_batch_end    DATE;
   l_prvBID       NUMBER;
   l_prvBED       DATE;

BEGIN
   --===================================  DEBUG ===============================================--
     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('ACCRUAL_SUBPROCESS - In Parameters');
        xtr_risk_debug_pkg.dlog('p_company         ' , p_company);
        xtr_risk_debug_pkg.dlog('p_do_reval        ' , p_do_reval);
        xtr_risk_debug_pkg.dlog('p_do_retro        ' , p_do_retro);
        xtr_risk_debug_pkg.dlog('p_cutoff_date     ' , p_cutoff_date);
        xtr_risk_debug_pkg.dpop('ACCRUAL_SUBPROCESS - In Parameters');
     END IF;
   --==========================================================================================--

   p_retcode     := 0;
   l_prvBID      := null;

   open  INCOMPLETE_ACCRUAL_BATCH;
   fetch INCOMPLETE_ACCRUAL_BATCH into l_batch_id, l_batch_start, l_batch_end;
   while INCOMPLETE_ACCRUAL_BATCH%FOUND and p_retcode <> 2 loop

      if l_prvBID is null then
         GET_PREV_NORMAL_BATCH(p_company, l_batch_end, l_prvBID, l_prvBED);
      end if;

      if not EVENT_EXISTS(p_company, l_batch_id, NULL, C_ACCRUAL) then
         GENERATE_ACCRUAL_DETAILS(l_sub_retcode,
                                  p_company,
                                  p_do_reval,
                                  p_do_retro,  -- 3378028 FAS
                                  l_batch_start,
                                  l_batch_end,
                                  l_batch_id,
                                  l_prvBID);
         p_retcode := greatest(l_sub_retcode, p_retcode);
      end if;

      if p_retcode <> 2 then

         AUTHORIZE_ACCRUAL_EVENT(l_sub_retcode,
                                 p_company,
                                 l_batch_id,
                                 l_prvBID);
         p_retcode := greatest(l_sub_retcode, p_retcode);

         if p_retcode <> 2 then
            l_prvBID := l_batch_id;
            l_prvBED := l_batch_end;
            fetch INCOMPLETE_ACCRUAL_BATCH into l_batch_id, l_batch_start, l_batch_end;
         end if;

      end if;

   end loop;

   close INCOMPLETE_ACCRUAL_BATCH;

   --===================================  DEBUG ===============================================--
     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('ACCRUAL_SUBPROCESS - Out Parameters');
        xtr_risk_debug_pkg.dlog('p_retcode       ' , p_retcode);
        xtr_risk_debug_pkg.dpop('ACCRUAL_SUBPROCESS - Out Parameters');
     END IF;
   --==========================================================================================--

END ACCRUAL_SUBPROCESS;


/*------------------------------------------------------------------------------*/
 PROCEDURE CREATE_NEW_ACCRUAL (p_retcode       OUT NOCOPY NUMBER,
                               p_company       IN  VARCHAR2,
                               p_do_reval      IN  VARCHAR2,
                               p_incomplete    IN  VARCHAR2,
                               p_cutoff_date   IN  DATE) AS
/*------------------------------------------------------------------------------*
 *  Creates a new accrual batch ONLY for company that does not use reval.       *
 *  Only Reval/Accrual journals will be included.                               *
 *                                                                              *
 *------------------------------------------------------------------------------*/

   l_upgrade        VARCHAR2(1) := null;
   l_sub_retcode    NUMBER      := 0;
   l_batch_id       NUMBER;
   l_period_start   DATE;
   l_lastBSD        DATE;
   l_lastBED        DATE;
   l_prvBID         NUMBER := null;
   l_dummy_date     DATE;
   l_dummy_BID      NUMBER;
   l_dummy_id       NUMBER;

BEGIN
   --===================================  DEBUG ===============================================--
     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('CREATE_NEW_ACCRUAL - In Parameters');
        xtr_risk_debug_pkg.dlog('p_company         ' , p_company);
        xtr_risk_debug_pkg.dlog('p_do_reval        ' , p_do_reval);
        xtr_risk_debug_pkg.dlog('p_incomplete      ' , p_incomplete);
        xtr_risk_debug_pkg.dlog('p_cutoff_date     ' , p_cutoff_date);
        xtr_risk_debug_pkg.dpop('CREATE_NEW_ACCRUAL - In Parameters');
     END IF;
   --==========================================================================================--

   p_retcode     := 0;

   GET_LATEST_BATCH (p_company, l_dummy_BID, l_lastBSD, l_lastBED, l_dummy_id, l_upgrade);

   ----------------------------------------------------------------------------------
   -- Only perform for a new batch if cutoff date is higher than last batch end date
   ----------------------------------------------------------------------------------
 --if p_incomplete = 'N' or (p_incomplete = 'Y' and l_lastBED < p_cutoff_date) then
   if ((p_incomplete = 'N' and nvl(l_lastBED,p_cutoff_date) <= p_cutoff_date and
        not EVENT_EXISTS (p_company, null,p_cutoff_date,C_ACCRUAL))
   or  (p_incomplete = 'Y' and l_lastBED < p_cutoff_date)) then

         if nvl(l_upgrade,'Y') = 'N' then
            GET_PREV_NORMAL_BATCH(p_company,p_cutoff_date,l_prvBID,l_dummy_date);
         end if;

         if l_upgrade is not null then
            if l_lastBED >= p_cutoff_date then
               FND_MESSAGE.Set_Name('XTR', C_COMPLETED_BATCH);
               FND_MESSAGE.Set_Token('BATCH_END', to_char(p_cutoff_date));
               FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
               FND_FILE.Put_Line (FND_FILE.LOG, ' ');
               p_retcode := 2;
            else
               l_period_start := l_lastBED + 1;
            end if;

         else  -- First batch

            l_period_start := GET_PARTY_CREATED_ON (p_company);

            -------------------------------------------------------
            -- In case cutoff date is earlier than created_on
            -------------------------------------------------------
            l_period_start := least(l_period_start, p_cutoff_date);

         end if;

         if p_retcode = 0 then

            GENERATE_ACCRUAL_DETAILS(p_retcode,
                                     p_company,
                                     p_do_reval,
                                     'N',          -- 3378028 FAS for p_do_reval
                                     l_period_start,
                                     p_cutoff_date,
                                     l_batch_id,
                                     l_prvBID);

            if p_retcode <> 2 then
               AUTHORIZE_ACCRUAL_EVENT(l_sub_retcode,
                                       p_company,
                                       l_batch_id,
                                       l_prvBID);
               p_retcode := greatest(l_sub_retcode, p_retcode);
            end if;

            if p_retcode <> 2 then
               FND_MESSAGE.Set_Name('XTR', C_NEW_BATCH);
               FND_MESSAGE.Set_Token('BATCH', l_batch_id);
               FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
               FND_FILE.Put_Line (FND_FILE.LOG, ' ');
            end if;

         end if;

   end if;

   --===================================  DEBUG ===============================================--
     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('CREATE_NEW_ACCRUAL - Out Parameters');
        xtr_risk_debug_pkg.dlog('p_retcode       ' , p_retcode);
        xtr_risk_debug_pkg.dpop('CREATE_NEW_ACCRUAL - Out Parameters');
     END IF;
   --==========================================================================================--

END CREATE_NEW_ACCRUAL;


/*---------------------------------------------------------------------------*/
 PROCEDURE JOURNAL_SUBPROCESS (p_retcode        OUT NOCOPY NUMBER,
                               p_company        IN  VARCHAR2,
                               p_cutoff_date    IN  DATE) AS
/*------------------------------------------------------------------------------*
 *                                                                              *
 * Process any incomplete journal batches.                                      *
 *                                                                              *
 *------------------------------------------------------------------------------*/
   cursor INCOMPLETE_JOURNAL_BATCH is
   select batch_id,
          period_start,
          period_end
   from   XTR_BATCHES a
   where  company_code = p_company
   and    period_end  <= p_cutoff_date
   and    batch_type is null
   and    nvl(upgrade_batch,'N') = 'N'
   and    not exists (select 1
                      from   XTR_BATCH_EVENTS b
                      where  b.batch_id  = a.batch_id
                      and    event_code  = C_JOURNAL)
   order by period_end, period_start;

   l_batch_id     NUMBER;
   l_batch_start  DATE;
   l_batch_end    DATE;
   l_prvBID       NUMBER;
   l_prvBED       DATE;
   l_sub_retcode  NUMBER := 0;

BEGIN
   --===================================  DEBUG ===============================================--
     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('JOURNAL_SUBPROCESS - In Parameters');
        xtr_risk_debug_pkg.dlog('p_company         ' , p_company);
        xtr_risk_debug_pkg.dlog('p_cutoff_date     ' , p_cutoff_date);
        xtr_risk_debug_pkg.dpop('JOURNAL_SUBPROCESS - In Parameters');
     END IF;
   --==========================================================================================--

   p_retcode     := 0;
   l_prvBID      := null;

   open  INCOMPLETE_JOURNAL_BATCH;
   fetch INCOMPLETE_JOURNAL_BATCH into l_batch_id, l_batch_start, l_batch_end;
   while INCOMPLETE_JOURNAL_BATCH%FOUND and p_retcode <> 2 loop

      if l_prvBID is null then
         GET_PREV_NORMAL_BATCH(p_company, l_batch_end, l_prvBID, l_prvBED);
      end if;

      GENERATE_JOURNAL_DETAILS(l_sub_retcode,
                               p_company,
                               l_batch_id,
                               l_prvBID);

      p_retcode := greatest(l_sub_retcode, p_retcode);

      if p_retcode <> 2 then
         l_prvBID := l_batch_id;
         l_prvBED := l_batch_end;
         fetch INCOMPLETE_JOURNAL_BATCH into l_batch_id, l_batch_start, l_batch_end;
      end if;

   end loop;

   close INCOMPLETE_JOURNAL_BATCH;

   --===================================  DEBUG ===============================================--
     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('JOURNAL_SUBPROCESS - Out Parameters');
        xtr_risk_debug_pkg.dlog('p_retcode       ' , p_retcode);
        xtr_risk_debug_pkg.dpop('JOURNAL_SUBPROCESS - Out Parameters');
     END IF;
   --==========================================================================================--

END JOURNAL_SUBPROCESS;


/*----------------------------------------------------------------------------*/
 PROCEDURE TRANSFER_SUBPROCESS (p_retcode         OUT NOCOPY NUMBER,
                                p_company         IN  VARCHAR2,
                                p_cutoff_date     IN  DATE,
                                p_closed_periods  IN  VARCHAR2) AS
/*------------------------------------------------------------------------------*
 *                                                                              *
 * Process any incomplete transfer batches.                                     *
 *                                                                              *
 *------------------------------------------------------------------------------*/
   cursor INCOMPLETE_TRANSFER_BATCH is
   select batch_id,
          period_start,
          period_end
   from   xtr_batches a
   where  company_code = p_company
   and    period_end  <= p_cutoff_date
   and    batch_type is null
   and    gl_group_id is null
   and    nvl(upgrade_batch,'N') = 'N'
   order by period_end, period_start;

   l_batch_id     NUMBER;
   l_batch_start  DATE;
   l_batch_end    DATE;
   l_prvBID       NUMBER;
   l_prvBED       DATE;
   l_sub_retcode  NUMBER := 0;

BEGIN
   --===================================  DEBUG ===============================================--
     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('TRANSFER_SUBPROCESS - In Parameters');
        xtr_risk_debug_pkg.dlog('p_company         ' , p_company);
        xtr_risk_debug_pkg.dlog('p_cutoff_date     ' , p_cutoff_date);
        xtr_risk_debug_pkg.dlog('p_closed_periods  ' , p_closed_periods);
        xtr_risk_debug_pkg.dpop('TRANSFER_SUBPROCESS - In Parameters');
     END IF;
   --==========================================================================================--

   p_retcode  := 0;
   l_prvBID   := null;
   l_batch_id := null;

   open  INCOMPLETE_TRANSFER_BATCH;
   fetch INCOMPLETE_TRANSFER_BATCH into l_batch_id, l_batch_start, l_batch_end;
   while INCOMPLETE_TRANSFER_BATCH%FOUND and p_retcode <> 2 loop
      if l_prvBID is null then
         GET_PREV_NORMAL_BATCH(p_company, l_batch_end, l_prvBID, l_prvBED);
      end if;

      TRANSFER_JOURNALS(l_sub_retcode,
                        p_company,
                        l_batch_id,
                        l_prvBID,
                        p_closed_periods);
      p_retcode := greatest(l_sub_retcode, p_retcode);

      if p_retcode <> 2 then
         l_prvBID   := l_batch_id;
         l_prvBED   := l_batch_end;
         l_batch_id := null;
         fetch INCOMPLETE_TRANSFER_BATCH into l_batch_id, l_batch_start, l_batch_end;
      end if;

   end loop;
   close INCOMPLETE_TRANSFER_BATCH;

   --===================================  DEBUG ===============================================--
     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('TRANSFER_SUBPROCESS - Out Parameters');
        xtr_risk_debug_pkg.dlog('p_retcode       ' , p_retcode);
        xtr_risk_debug_pkg.dpop('TRANSFER_SUBPROCESS - Out Parameters');
     END IF;
   --==========================================================================================--

END TRANSFER_SUBPROCESS;


/*------------------------------------------------------------------------------*/
 PROCEDURE PROCESS_COMPANY (p_errbuf          OUT NOCOPY VARCHAR2,
                            p_retcode         OUT NOCOPY NUMBER,
                            p_company         IN  VARCHAR2,
                            p_do_reval        IN  VARCHAR2,
                            p_do_retro        IN  VARCHAR2,  -- 3378028 FAS
                            p_incomplete      IN  VARCHAR2,
                            p_cutoff_date     IN  VARCHAR2,
                            p_start_process   IN  VARCHAR2,
                            p_end_process     IN  VARCHAR2,
                            p_closed_periods  IN  VARCHAR2,
                            p_multiple_acct   IN  VARCHAR2) AS  -- Bug 4639287
/*------------------------------------------------------------------------------*
 *                                                                              *
 *  Subprocess submitted by MAIN_PROCESS for each company.                      *
 *                                                                              *
 *------------------------------------------------------------------------------*/

   l_dummy        NUMBER;
   l_retcode      NUMBER := 0;
   l_cutoff_date  DATE   := FND_DATE.Canonical_To_Date(p_cutoff_date);

BEGIN

   --===================================  DEBUG ===============================================--
     xtr_risk_debug_pkg.start_conc_prog;
     IF xtr_risk_debug_pkg.g_Debug THEN
        --------------------------------------------------------------------------------------------------
        -- Special call only when debugging is switched on.
        --------------------------------------------------------------------------------------------------
        l_dummy := CHK_ELIGIBLE_COMPANY(p_company,l_cutoff_date,p_do_reval,p_do_retro,p_start_process,p_end_process);
        --------------------------------------------------------------------------------------------------
        xtr_risk_debug_pkg.dpush('PROCESS_COMPANY - In Parameters');
        xtr_risk_debug_pkg.dlog('p_company          ' , p_company);
        xtr_risk_debug_pkg.dlog('p_do_reval         ' , p_do_reval);
        xtr_risk_debug_pkg.dlog('p_do_retro         ' , p_do_retro);
        xtr_risk_debug_pkg.dlog('p_incomplete       ' , p_incomplete);
        xtr_risk_debug_pkg.dlog('p_cutoff_date      ' , p_cutoff_date);
        xtr_risk_debug_pkg.dlog('l_cutoff_date      ' , l_cutoff_date);
        xtr_risk_debug_pkg.dlog('p_start_process    ' , p_start_process);
        xtr_risk_debug_pkg.dlog('p_end_process      ' , p_end_process);
        xtr_risk_debug_pkg.dlog('p_closed_periods   ' , p_closed_periods);
        xtr_risk_debug_pkg.dpop('PROCESS_COMPANY - In Parameters');
     END IF;
   --==========================================================================================--

    G_MULTIPLE_ACCT := p_multiple_acct; -- Bug 4639287
    p_retcode := 0;
    FND_FILE.Put_Line (FND_FILE.LOG, ' ');

    --------------------------------------------------------------------
    -- 1. Revaluation
    --------------------------------------------------------------------

    if p_do_reval = 'Y' and p_start_process = C_PROCESS_REVAL then

       FND_FILE.Put_Line (FND_FILE.LOG, ' ');
       FND_MESSAGE.Set_Name('XTR', C_SUBPROCESS_REVAL);
       FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
       FND_FILE.Put_Line (FND_FILE.LOG, '============================================');

       if p_incomplete = 'Y' then
          REVAL_SUBPROCESS(l_retcode,
                           p_company,
                           l_cutoff_date);
          p_retcode := greatest(l_retcode, p_retcode);
       end if;
       if l_retcode <> 2 then
          CREATE_NEW_REVAL(l_retcode,
                           p_company,
                           p_incomplete,
                           l_cutoff_date);
          p_retcode := greatest(l_retcode, p_retcode);
       end if;
    end if;

    -------------------------------------------------------------
    --  2. Retrospective - FAS 3378028
    -------------------------------------------------------------
    -- Do not need to check for p_incomplete for subprocesses.  It is only needed for a NEW Reval or Accrual batch.
    -- For example, p_incomplete might be 'N' for Start Process of Reval.  And if End Process is Retro, then even though
    -- p_incomplete is 'N', Retro subprocess should continue.
    -- (If we check for p_incomplete, then Retro will not be  processed at all, which will be wrong.)
    --
    if p_do_retro = 'Y' and p_start_process <= C_PROCESS_RETROET and p_end_process >= C_PROCESS_RETROET then
       FND_FILE.Put_Line (FND_FILE.LOG, ' ');
       FND_MESSAGE.Set_Name('XTR', C_SUBPROCESS_RETROET);
       FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
       FND_FILE.Put_Line (FND_FILE.LOG, '============================================');
       RETRO_SUBPROCESS (l_retcode,
                         p_company,
                         l_cutoff_date);
       p_retcode := greatest(l_retcode, p_retcode);
    end if;

    --------------------------------------------------------------------
    -- 3. Accrual
    --------------------------------------------------------------------
    if p_start_process <= C_PROCESS_ACCRUAL and p_end_process >= C_PROCESS_ACCRUAL then

       FND_FILE.Put_Line (FND_FILE.LOG, ' ');
       FND_MESSAGE.Set_Name('XTR', C_SUBPROCESS_ACCRUAL);
       FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
       FND_FILE.Put_Line (FND_FILE.LOG, '============================================');

       ACCRUAL_SUBPROCESS (l_retcode,
                           p_company,
                           p_do_reval,
                           p_do_retro,  -- 3378028 FAS
                           l_cutoff_date);
       p_retcode := greatest(l_retcode, p_retcode);

       if p_do_reval = 'N' and l_retcode <> 2 then
          CREATE_NEW_ACCRUAL (l_retcode,
                              p_company,
                              p_do_reval,
                              p_incomplete,
                              l_cutoff_date);
          p_retcode := greatest(l_retcode, p_retcode);
       end if;
    end if;

    --------------------------------------------------------------------
    -- 4. Journals
    --------------------------------------------------------------------
    if p_start_process <= C_PROCESS_JOURNAL and p_end_process >= C_PROCESS_JOURNAL then

       FND_FILE.Put_Line (FND_FILE.LOG, ' ');
       FND_MESSAGE.Set_Name('XTR', C_SUBPROCESS_JOURNAL);
       FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
       FND_FILE.Put_Line (FND_FILE.LOG, '============================================');

       JOURNAL_SUBPROCESS (l_retcode,
                           p_company,
                           l_cutoff_date);
       p_retcode := greatest(l_retcode, p_retcode);
    end if;

    --------------------------------------------------------------------
    -- 5. Transfer
    --------------------------------------------------------------------
    if p_end_process = C_PROCESS_TRANSFER then

       FND_FILE.Put_Line (FND_FILE.LOG, ' ');
       FND_MESSAGE.Set_Name('XTR', C_SUBPROCESS_TRANSFER);
       FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
       FND_FILE.Put_Line (FND_FILE.LOG, '============================================');

       TRANSFER_SUBPROCESS (l_retcode,
                            p_company,
                            l_cutoff_date,
                            p_closed_periods);
       p_retcode := greatest(l_retcode, p_retcode);
    end if;

    if p_retcode = 2 then
       p_retcode := -1;
    end if;

   --===================================  DEBUG ===============================================--
      xtr_risk_debug_pkg.stop_conc_debug;
   --==========================================================================================--

END PROCESS_COMPANY;


/*----------------------------------------------------------------------------*/
 PROCEDURE MAIN_PROCESS (p_errbuf          OUT NOCOPY VARCHAR2,
                         p_retcode         OUT NOCOPY NUMBER,
                         p_company         IN  VARCHAR2,
                         p_cutoff_date     IN  VARCHAR2,
                         p_dummy_date      IN  VARCHAR2,
                         p_start_process   IN  VARCHAR2,
                         p_end_process     IN  VARCHAR2,
                         p_dummy_process   IN  VARCHAR2,
                         p_closed_periods  IN  VARCHAR2,
                         p_multiple_acct   IN  VARCHAR2) AS   -- Bug 4639287
/*------------------------------------------------------------------------------*
 *                                                                              *
 * Main Streamline Accounting Processing                                        *
 *                                                                              *
 *------------------------------------------------------------------------------*/

   cursor ALL_COMPANIES is
   select a.party_code,
          decode(b.PARAMETER_VALUE_CODE,'REVAL','Y','N'),
          c.PARAMETER_VALUE_CODE
   from   xtr_parties_v a,
          xtr_company_parameters b,
          xtr_company_parameters c
   where  a.party_code     = nvl(p_company,a.party_code)
   and    b.company_code   = a.party_code
   and    b.parameter_code = C_REVAL_PARAM
   and    c.company_code   = b.company_code
   and    c.parameter_code = C_RETRO_PARAM  -- 3378028 FAS
   order by a.party_code;

   l_company       XTR_PARTY_INFO.PARTY_CODE%TYPE;
   l_do_reval      VARCHAR2(1);
   l_do_retro      VARCHAR2(1);
   l_incomplete    VARCHAR2(1);

   l_retcode       NUMBER := 0;
   l_sub_retcode   NUMBER := 0;

   l_request_id    NUMBER := 0;
   l_success       NUMBER := 0;
   l_failure       NUMBER := 0;

   l_cutoff_date   DATE   := FND_DATE.Canonical_To_Date(p_cutoff_date);

BEGIN

   --===================================  DEBUG ===============================================--
     xtr_risk_debug_pkg.start_conc_prog;
     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('MAIN_PROCESS - In Parameters');
        xtr_risk_debug_pkg.dlog('p_company          ' , p_company);
        xtr_risk_debug_pkg.dlog('p_cutoff_date      ' , p_cutoff_date);
        xtr_risk_debug_pkg.dlog('l_cutoff_date      ' , l_cutoff_date);
        xtr_risk_debug_pkg.dlog('p_start_process    ' , p_start_process);
        xtr_risk_debug_pkg.dlog('p_end_process      ' , p_end_process);
        xtr_risk_debug_pkg.dlog('p_closed_periods   ' , p_closed_periods);
        xtr_risk_debug_pkg.dpop('MAIN_PROCESS - In Parameters');
     END IF;
   --==========================================================================================--

   -- 3378028 FAS  To check that new options are submitted.
   if p_start_process not in (C_PROCESS_REVAL, C_PROCESS_RETROET, C_PROCESS_ACCRUAL, C_PROCESS_JOURNAL, C_PROCESS_TRANSFER) or
      p_end_process   not in (C_PROCESS_REVAL, C_PROCESS_RETROET, C_PROCESS_ACCRUAL, C_PROCESS_JOURNAL, C_PROCESS_TRANSFER) then

      FND_MESSAGE.Set_Name('XTR',C_INVALID_STRM_PROCESS);
      FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
      l_retcode := 2;

   elsif l_cutoff_date > sysdate then

      FND_MESSAGE.Set_Name('XTR',C_CUTOFF_DATE_ERROR);
      FND_MESSAGE.Set_Token('CUTOFF', l_cutoff_date);
      FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
      l_retcode := 2;

   else

      FND_FILE.Put_Line (FND_FILE.LOG, ' ');

      open  ALL_COMPANIES;
      fetch ALL_COMPANIES into l_company, l_do_reval, l_do_retro;
      while ALL_COMPANIES%FOUND loop

         FND_FILE.Put_Line (FND_FILE.LOG, ' ');
         FND_FILE.Put_Line (FND_FILE.LOG, l_company);
         FND_FILE.Put_Line (FND_FILE.LOG, '============================================================================');

         l_sub_retcode := 0;
         l_incomplete  := 'N';

         --------------------------------------------------------------
         -- Check Company performs revaluation
         --------------------------------------------------------------
         --===================================  DEBUG ===============================================--
           IF xtr_risk_debug_pkg.g_Debug THEN
              xtr_risk_debug_pkg.dpush('MAIN_PROCESS Check Company perfoms revaluation');
              xtr_risk_debug_pkg.dlog('l_do_reval      ' , l_do_reval);
              xtr_risk_debug_pkg.dlog('l_do_retro      ' , l_do_retro);
              xtr_risk_debug_pkg.dlog('p_company       ' , p_company);
              xtr_risk_debug_pkg.dlog('p_start_process ' , p_start_process);
              xtr_risk_debug_pkg.dlog('p_end_process   ' , p_end_process);
              xtr_risk_debug_pkg.dpop('MAIN_PROCESS Check Company perfoms revaluation');
           END IF;
         --==========================================================================================--

         /*****************************************************/
         /* Terminate immediately if Start Process is invalid */
         /* Display warning if End Process is invalid         */
         /*****************************************************/

         if l_do_reval = 'N' then

         -- if (p_company is not null and p_start_process = C_PROCESS_REVAL) or     -- 3050444 old issue 1
         --    (p_company is null     and p_end_process   = C_PROCESS_REVAL) then   -- 3050444 old issue 1
         --
         -------------------------------------------------------------------------------------------------
         -- 3378028 FAS
         -- Modify 3050444 issue 1 fix.   For consistency, check Start instead of End Process
         -------------------------------------------------------------------------------------------------
         -- if (p_end_process = C_PROCESS_REVAL) then                               -- 3050444 new issue 1
         --
            if p_start_process = C_PROCESS_REVAL then
               FND_MESSAGE.Set_Name('XTR', C_COMPANY_NO_REVAL);
               FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
               FND_FILE.Put_Line (FND_FILE.LOG, ' ');
               l_sub_retcode := 2;
            elsif p_start_process = C_PROCESS_RETROET then
               FND_MESSAGE.Set_Name('XTR', C_COMPANY_NO_RETROET);
               FND_FILE.Put_Line(FND_FILE.LOG, FND_MESSAGE.Get);
               FND_FILE.Put_Line(FND_FILE.LOG, ' ');
               l_sub_retcode := 2;
            end if;

         else -- l_do_reval = 'Y'

           --------------------------------------------------------------------------------
           -- 3378028 Check that company runs retrospective testing.
           -- Only failed for companies starts from Reval and not use Effectiveness Testing
           --------------------------------------------------------------------------------
           if l_do_retro = 'N' and p_start_process = C_PROCESS_RETROET then
                FND_MESSAGE.Set_Name('XTR',C_COMPANY_NO_RETROET);
                FND_FILE.Put_Line(FND_FILE.LOG, FND_MESSAGE.Get);
                FND_FILE.Put_Line(FND_FILE.LOG, ' ');
                l_sub_retcode := 2;
           end if;

         end if;

         --------------------------------------------------------------
         -- Check eligibility
         --------------------------------------------------------------
         if l_sub_retcode = 0 then
            l_sub_retcode := CHK_ELIGIBLE_COMPANY(l_company,l_cutoff_date,l_do_reval,l_do_retro,p_start_process,p_end_process);

            if l_sub_retcode = 1 then
               l_incomplete := 'Y';
            else
               l_incomplete := 'N';
            end if;
         end if;

         --===================================  DEBUG ===============================================--
           IF xtr_risk_debug_pkg.g_Debug THEN
              xtr_risk_debug_pkg.dpush('MAIN_PROCESS After Eligibility');
              xtr_risk_debug_pkg.dlog('l_sub_retcode   ' , l_sub_retcode);
              xtr_risk_debug_pkg.dlog('l_incomplete    ' , l_incomplete);
              xtr_risk_debug_pkg.dpop('MAIN_PROCESS After Eligibility');
           END IF;
         --==========================================================================================--

         --------------------------------------------------------------
         -- Passed eligibility
         --------------------------------------------------------------
         if l_sub_retcode <> 2 then

            ---------------------------------------------------------------------------------
            -- 3378028 FAS
            -- Only WARNING for companies starts from Reval and not use Effectiveness Testing
            ---------------------------------------------------------------------------------
            if l_do_reval = 'Y' and l_do_retro = 'N' then
               ------------------------------------------------------------------------------------------------
               -- NOTE: if company's reval is all authorised and has no other process to perform, and
               --       if p_end_process = C_PROCESS_RETROET, then it should be caught in CHK_ELIGIBLE_COMPANY
               --       and a child process should not be submitted.
               ------------------------------------------------------------------------------------------------
               if p_start_process = C_PROCESS_REVAL and p_end_process >= C_PROCESS_RETROET then
                  FND_MESSAGE.Set_Name('XTR', C_COMPANY_SKIP_RETROET);
                  FND_FILE.Put_Line(FND_FILE.LOG, FND_MESSAGE.Get);
                  FND_FILE.Put_Line(FND_FILE.LOG, ' ');
                  -- Do not set l_sub_retcode to 1 here.
                  -- It is not necessary to display WARNING due to the possibilities of ALL companies
                  -- submitted and if ALL/many do not require to run Retrospective Testing we do not
                  -- want a list of child process submitted with a WARNING sign.
               end if;
            end if;

            l_sub_retcode := 0;
            l_request_id  := 0;

            --===================================  DEBUG ===============================================--
              IF xtr_risk_debug_pkg.g_Debug THEN
                 xtr_risk_debug_pkg.dpush('MAIN_PROCESS - In Parameters to XTRSTRMC');
                 xtr_risk_debug_pkg.dlog('l_company       ' , l_company);
                 xtr_risk_debug_pkg.dlog('l_do_reval      ' , l_do_reval);
                 xtr_risk_debug_pkg.dlog('l_do_retro      ' , l_do_retro);
                 xtr_risk_debug_pkg.dlog('l_incomplete    ' , l_incomplete);
                 xtr_risk_debug_pkg.dlog('p_cutoff_date   ' , p_cutoff_date);
                 xtr_risk_debug_pkg.dlog('p_start_process ' , p_start_process);
                 xtr_risk_debug_pkg.dlog('p_end_process   ' , p_end_process);
                 xtr_risk_debug_pkg.dlog('p_closed_periods' , p_closed_periods);
                 xtr_risk_debug_pkg.dpop('MAIN_PROCESS - In Parameters to XTRSTRMC');
              END IF;
            --==========================================================================================--

            l_request_id := FND_REQUEST.SUBMIT_REQUEST(
                                   'XTR','XTRSTRMC',   -- calls XTR_STREAMLINE_P.PROCESS_COMPANY
                                   '','',FALSE,
				   l_company,
                                   l_do_reval,
                                   l_do_retro,  -- 3378028 FAS
                                   l_incomplete,
                                   p_cutoff_date,
                                   p_start_process,
                                   p_end_process,
                                   p_closed_periods,
                                   p_multiple_acct,   -- Bug 4639287
                             	   CHR(0),'','','','','','','','','','',
                                   '','','','','','','','','','','','','','','','','','','','',
                                   '','','','','','','','','','','','','','','','','','','','',
                                   '','','','','','','','','','','','','','','','','','','','',
                                   '','','','','','','','','','','','','','','','','','','','');

            if l_request_id <> 0 then
               l_success := l_success + 1;
               FND_MESSAGE.Set_Name('XTR', C_SUBMIT_REQUEST);
               FND_MESSAGE.Set_Token('REQUEST', l_request_id);
               FND_MESSAGE.Set_Token('DATETIME', FND_DATE.date_to_canonical(sysdate));
               FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
               FND_FILE.Put_Line (FND_FILE.LOG, ' ');
            else
               l_failure := l_failure + 1;
               l_sub_retcode := 2;
               FND_MESSAGE.Set_Name('XTR', C_SUBMIT_FAILURE);
               FND_MESSAGE.Set_Token('COMPANY', p_company);
               FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
               FND_FILE.Put_Line (FND_FILE.LOG, ' ');
            end If;

         else  -- error in eligible check

            l_failure := l_failure + 1;

         end if; -- l_sub_retcode <> 2

         l_retcode := greatest(l_sub_retcode, l_retcode);
         fetch ALL_COMPANIES into l_company, l_do_reval, l_do_retro;

      end loop;
      close ALL_COMPANIES;

   end if;  -- l_retcode = 0 and if l_cutoff_date > sysdate then

   -----------------------------------------------------------
   -- Summary Log
   -----------------------------------------------------------
   FND_FILE.Put_Line    (FND_FILE.LOG, ' ');
   FND_FILE.Put_Line    (FND_FILE.LOG, ' ');
   FND_MESSAGE.Set_Name ('XTR', C_TOTAL_SUBMIT);
   FND_MESSAGE.Set_Token('TOTAL_SUBMIT', l_success);
   FND_FILE.Put_Line    (FND_FILE.LOG, FND_MESSAGE.Get);
   FND_MESSAGE.Set_Name ('XTR', C_TOTAL_FAIL);
   FND_MESSAGE.Set_Token('TOTAL_FAIL', l_failure);
   FND_FILE.Put_Line    (FND_FILE.LOG, FND_MESSAGE.Get);
   FND_MESSAGE.Set_Name ('XTR', C_TOTAL_COMPANY);
   FND_MESSAGE.Set_Token('TOTAL', l_success + l_failure);
   FND_FILE.Put_Line    (FND_FILE.LOG, FND_MESSAGE.Get);
   FND_FILE.Put_Line    (FND_FILE.LOG, ' ');
   -----------------------------------------------------------

   if l_retcode <> 0 then
      p_retcode := 1;       -- just warning, instead of '-1' for error
   else
      p_retcode := 0;
   end If;

   --===================================  DEBUG ===============================================--
     xtr_risk_debug_pkg.stop_conc_debug;
   --==========================================================================================--

END MAIN_PROCESS;
---------------------------------------------------------------------------------------------
end XTR_STREAMLINE_P;

/
