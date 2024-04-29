--------------------------------------------------------
--  DDL for Package Body OPIMPDAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPIMPDAT" AS
/*$Header: OPIMDATB.pls 120.1 2005/06/10 12:10:44 appldev  $ */


procedure get_push_dates(
    I_ORG_ID                  IN    NUMBER,
    I_FROM_DATE               IN    DATE,        -- user entered date
    I_TO_DATE                 IN    DATE,        -- user-entered date
    I_LAST_PUSH_MIN_DATE      IN    DATE,
    O_PUSH_START_INV_TXN_DATE OUT NOCOPY  DATE,
    O_PUSH_START_WIP_TXN_DATE OUT NOCOPY  DATE,
    O_PUSH_LAST_INV_TXN_ID    OUT NOCOPY  NUMBER,
    O_PUSH_LAST_WIP_TXN_ID    OUT NOCOPY  NUMBER,
    O_PUSH_LAST_INV_TXN_DATE  OUT NOCOPY  DATE,
    O_PUSH_LAST_WIP_TXN_DATE  OUT NOCOPY  DATE,
    O_PUSH_END_TXN_DATE       OUT NOCOPY  DATE,
    O_FIRST_PUSH              OUT NOCOPY  NUMBER,    -- 1=YES, 0=NO
    O_ERR_NUM                 OUT NOCOPY  NUMBER,
    O_ERR_CODE                OUT NOCOPY  VARCHAR2,
    O_ERR_MSG                 OUT NOCOPY  VARCHAR2,
    O_TXN_FLAG                OUT NOCOPY  NUMBER
)  IS
    l_push_inv_start_date     DATE;
    l_push_wip_start_date     DATE;
    l_push_inv_end_date       DATE;
    l_push_wip_end_date       DATE;
    l_push_inv_start_txn_id   NUMBER;
    l_push_wip_start_txn_id   NUMBER;
    l_push_inv_end_txn_id     NUMBER;
    l_push_wip_end_txn_id     NUMBER;
    l_prev_push_inv_txn_date  DATE;
    l_prev_push_inv_txn_id    NUMBER;
    l_prev_push_wip_txn_date  DATE;
    l_prev_push_wip_txn_id    NUMBER;
    l_inv_txn_id              NUMBER;
    l_inv_txn_date            DATE;
    l_wip_txn_id              NUMBER;
    l_wip_txn_date            DATE;
    l_last_push_date          DATE;
    l_from_date               DATE;
    l_inv_from_date           DATE;
    l_wip_from_date           DATE;
    l_first_push_date         DATE;
    l_costed_flag             VARCHAR2(1);
    l_first_push              NUMBER;
    l_txn_flag                NUMBER;
    l_err_num                 NUMBER;
    l_err_code                VARCHAR2(240);
    l_err_msg                 VARCHAR2(240);
    l_stmt_num                NUMBER;
    process_error             EXCEPTION;
    no_from_date              EXCEPTION;
    no_date_range             EXCEPTION;
    l_look_for_txn_id         DATE;
    l_from_date_per_close     DATE;
    l_per_open_flag          VARCHAR2 (1);

BEGIN

    -- Initialize local variables
    l_err_num := 0;
    l_err_code := '';
    l_err_msg := '';
    l_first_push := 0;   -- not the first push process
    l_txn_flag := 0;     -- have both MMT and WT tranx
    l_last_push_date := NULL;
    l_from_date := NULL;
    l_inv_from_date := NULL;
    l_wip_from_date := NULL;
    l_inv_txn_id := 0;
    l_costed_flag := 'N';
    l_inv_txn_id := 0;
    l_wip_txn_id := 0;
    l_prev_push_inv_txn_id := 0;
    l_prev_push_wip_txn_id := 0;
    l_push_inv_start_txn_id := 0;
    l_push_wip_start_txn_id := 0;

    /*-------------------------------
    ** Determine start process date
    --------------------------------*/

    EDW_LOG.PUT_LINE('from date: ' || to_char(i_from_date));
    EDW_LOG.PUT_LINE('to date: '|| to_char(i_to_date));
    EDW_LOG.PUT_LINE('org id: ' || to_char(i_org_id));

    -- Get last push date and last push transaction id for organization

    l_stmt_num := 10;
    select max(last_push_date)
      into l_last_push_date
      from opi_ids_push_date_log pdl
      where pdl.organization_id = i_org_id;


    -- if there is no push log record for the organization,
    -- and no user_entered date, it is because there have not
    -- been any transactions thru the last push date.
    -- Notes:  if this is the very first push for all orgs, the
    -- calling program would not invoke this procedure unless it
    -- has a user-entered start date.

    if l_last_push_date is NULL then       -- no push date log record
        l_first_push      := 1;    -- it is the first push

        if i_from_date is null  then        -- use min date of last push
            l_stmt_num := 20;
            select trunc (min(transaction_date)) --Dinkar 10/11/02
              into l_inv_from_date
              from mtl_material_transactions
              where organization_id = i_org_id
                and costed_flag is null;

            l_stmt_num := 30;
            select trunc (min(wt.transaction_date)) --Dinkar 10/11/02
              into l_wip_from_date
              from wip_transactions wt
              where organization_id = i_org_id;
        end if;     -- end 'from' date is null
        l_prev_push_inv_txn_id := 0;
        l_prev_push_wip_txn_id := 0;
    else                             -- push date log record exists
        l_stmt_num := 40;
        select pdl.last_push_inv_txn_date,  -- push date log dates are trunc'ed
             pdl.last_push_inv_txn_id,
             pdl.last_push_wip_txn_date,
             pdl.last_push_wip_txn_id
          into
             l_prev_push_inv_txn_date,
             l_prev_push_inv_txn_id,
             l_prev_push_wip_txn_date,
             l_prev_push_wip_txn_id
          from opi_ids_push_date_log pdl
          where pdl.organization_id = i_org_id
            and pdl.last_push_date = l_last_push_date;

        l_inv_from_date := l_prev_push_inv_txn_date;
        l_wip_from_date := l_prev_push_wip_txn_date;

    -- Check for from date older than the first pushed transaction date.
    -- If so, set the first push flag so that beginning balance can be
    -- re-calculated.
        l_stmt_num := 50;
        select min(trx_date)
          into l_first_push_date
          from opi_ids_push_log
          where organization_id = i_org_id;

        if i_from_date is not null
            and i_from_date < l_first_push_date then
            l_first_push := 1;
        end if;

    end if;    -- end checking for push log record

    -- Get the calculated INV from date
    l_stmt_num := 60;

    calc_from_date(i_org_id,
                   i_from_date,
                   l_inv_from_date,
                   l_first_push,
                   l_from_date,     -- start date got back from call
                   l_err_num,
                   l_err_code,
                   l_err_msg);
    if l_err_num <> 0 then
        raise process_error;
    end if;


    EDW_LOG.PUT_LINE('lp_i_txn_date: ' || to_char(l_prev_push_inv_txn_date));
    EDW_LOG.PUT_LINE('(60) lp_i_txn_id: ' || to_char(l_prev_push_inv_txn_id));
    EDW_LOG.PUT_LINE('(60) lp_w_txn_date: ' || to_char(l_prev_push_wip_txn_date));
    EDW_LOG.PUT_LINE('(60) lp_w_txn_id: ' || to_char(l_prev_push_wip_txn_id));

    -- Usually this l_from_date is the last collected date, since there
    -- could have been data entered on that last collected day after the
    -- ETL was run.
    -- The one case we do not want to go back to this date is when
    -- the last collected date was the ending date of a closed period
    -- and the period had been closed before the collection was made.
    -- In that case, there is no need to go back and collect the end of
    -- period day and consequently all the period start and period end
    -- rows.
    -- The one exception is during the first push
    IF ((l_last_push_date IS NOT NULL) and
        (trunc (l_last_push_date) > trunc (l_from_date)))
    THEN

        BEGIN
            select trunc (schedule_close_date), open_flag
              into l_from_date_per_close, l_per_open_flag
              from org_acct_periods
             where organization_id = i_org_id
               and period_start_date <= trunc (l_from_date)
               and schedule_close_date >= trunc (l_from_date);

            -- if the l_from_date is the closing date of the period,
            -- and the period is closed, then move the from date to
            -- start of the next period i.e. to the next day
            IF ((l_from_date_per_close = trunc (l_from_date)) and
                (l_per_open_flag = 'N')) THEN
                l_from_date := trunc (l_from_date) + 1;
            END IF;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                null;          --no need to change l_from_date
        END;

    END IF;

    /*--------------------------------------------------------------
    l_push_inv_start_date is one of the following:
      1. Backdated transaction date (costed backdated trx)
      2. Period start date
      3. From date passed by user from conc program
      4. Previous Push date (from previous collection
    -------------------------------------------------------------------*/
    l_stmt_num := 70;

    l_push_inv_start_date := l_from_date;

    /*---------------------------------------------------------------------
    -- Check for back-dated transaction and change the start date if needed.
    ----------------------------------------------------------------------*/
    -- Get first transaction id of the start date

    l_stmt_num := 90;
/*   select min(mmt.transaction_id)
      into l_push_inv_start_txn_id
      from mtl_material_transactions mmt
      where trunc (mmt.transaction_date) >= l_push_inv_start_date
        and mmt.organization_id = i_org_id
        and mmt.costed_flag is null;
*/
    -- ltong (02/19/2003). Added filter to Consigned Inventory Transactions.
    select min(mmt.transaction_id)
      into l_push_inv_start_txn_id
      from mtl_material_transactions mmt
      where mmt.transaction_id > l_prev_push_inv_txn_id
        and mmt.organization_id = i_org_id
        and mmt.costed_flag is null
        AND MMT.organization_id =  NVL(MMT.owning_organization_id, MMT.organization_id)
        AND NVL(MMT.OWNING_TP_TYPE,2) = 2;

    l_stmt_num := 90;
    select trunc (min(mmt.transaction_date))
      into l_inv_txn_date
      from mtl_material_transactions mmt
      where mmt.transaction_id >= l_push_inv_start_txn_id
        and mmt.organization_id = i_org_id
        and mmt.costed_flag is null;

    -- Need to adjust start date only if it is not the first push

    if (l_inv_txn_date < l_prev_push_inv_txn_date)
        and l_first_push <> 1 then
        l_push_inv_start_date := l_inv_txn_date;
    end if;


    /*--------------------------------------------------
    ** Determine end process date and MMT transaction id
    --------------------------------------------------*/
    -- Check if user enters 'to' date.
    -- User does not specify 'to' date ==> process until sysdate if there are
    -- costed transactions.
    -- User_specified 'to' date <= last push date ==> process
    -- until the last push date.
    -- User_specified 'to' date > last push date ==> process thru 'to' date.

    if i_to_date is null then
        l_push_inv_end_date := trunc (sysdate);
    elsif i_to_date <= l_prev_push_inv_txn_date then
        l_push_inv_end_date := l_prev_push_inv_txn_date;
    else
        l_push_inv_end_date := trunc (i_to_date);
    end if;


    l_inv_txn_id := 0;

    -- Get the first uncosted transaction prior to the end date.
    l_stmt_num := 100;
    select nvl(min(transaction_id),0)
      into l_inv_txn_id
      from mtl_material_transactions mmt
      where mmt.organization_id = i_org_id
        AND mmt.transaction_date >= trunc (l_push_inv_start_date)  -- rjin 10/31/02
        and mmt.transaction_date <= trunc (l_push_inv_end_date) + 0.99999
        and mmt.costed_flag is not null;

    -- If uncosted transactions exist prior to end date,
    -- change the end date to the day before the uncosted transaction's
    -- txn date. Otherwise, leave the end date alone.
    l_stmt_num := 110;
    if l_inv_txn_id > 0 then
        select trunc (mmt.transaction_date)
          into l_inv_txn_date
          from mtl_material_transactions mmt
          where mmt.transaction_id = l_inv_txn_id;
        l_push_inv_end_date := (l_inv_txn_date - 1);
    end if;


    -- before assigning, we need to make the data range is a valid one
    IF l_push_inv_end_date < l_push_inv_start_date THEN
        RAISE no_date_range;
    END IF;

    /*--------------------------------------------------------------------
    -- Get the final first and last MMT transaction to be procesed,
    -- now that we have the final transaction date range.
    ---------------------------------------------------------------------*/

    l_stmt_num := 130;
    /* Select the min and max transaction id from between the period start
       date and the collection end date. This is different from the
       previous approach where we get the date from between collection start
       and end date. The reason is to avoid occluding collection backdated
       transactions e.g in the following scenario:
       Suppose we backdate a trx. on 18th Jan to the 1st Jan with id 100.
       Then collect 1st Jan to 15th Jan. The last pushed trx id is 100, not
       the max (transaction_id) of 15th Jan.
       Then collect 15th Jan to 17th Jan. The last pushed trx id is now
       max (transaction_id) of 17th Jan which is less than 100.
       Now collect 18th to 25th.
       Since the trx id of 100 belonging to a transaction dated on
       1st Jan is greater than the last pushed transaction id,
       the collection of 18th to 25th will go back to the first.
       This can be avoided if we collect the max trx id from the start of
       period instead of the start of the collection period.
       However, there might be backdated transactions to within the
       period collected that might be past the collection period. In the
       example here, there could be a backdated transaction for the 2nd Jan,
       created after 25th Jan. If the transaction has already been entered,
       then it will be collected with the rest of the data from 1st Jan, and
       so is not a problem. If not, then the transaction has not been made
       yet and will have a transaction id greater than the last pushed
       transaction id when it is made.
    */
    BEGIN
        select period_start_date
          into l_look_for_txn_id
          from org_acct_periods
         where organization_id = i_org_id
           and period_start_date <= trunc (l_push_inv_start_date)
           and schedule_close_date >= trunc (l_push_inv_start_date);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN   -- for start date before period
            l_look_for_txn_id := l_push_inv_start_date;

    END;

    EDW_LOG.PUT_LINE ('Looking for txns from: ' || l_look_for_txn_id);

    select nvl(min(transaction_id),0),
           nvl(max(transaction_id),0)
      into l_push_inv_start_txn_id,
           l_push_inv_end_txn_id
      from mtl_material_transactions mmt
      where mmt.organization_id = i_org_id
        and mmt.transaction_date between l_look_for_txn_id
            and trunc (l_push_inv_end_date) + 0.99999
        and mmt.costed_flag is null;

    -- If it's a first push and there are no INV transactions for date range
    -- set flag to process only beginning balances.  Otherwise, set trxn flag
    -- and set push txn id to previous push's last txn id.

    if (l_push_inv_start_txn_id = 0 or
        l_push_inv_start_txn_id is null) then
        l_txn_flag := 2;   -- set flag to process WT only
        EDW_LOG.PUT_LINE('OPIMPDAT.get_push_dates - '
                         || 'No INV transactions for date range');
        if l_first_push = 1 then
            l_first_push := 2;
        else
            l_push_inv_end_txn_id := l_prev_push_inv_txn_id;
        end if;     -- end checking first push
    end if;     -- end checking null start txn id

    -- since we mean to collect the entire end date, set the end date
    -- to 23:59:59
    l_push_inv_end_date := to_date ( to_char (l_push_inv_end_date, 'DD-MM-YYYY') || ' 23:59:59', 'DD-MM-YYYY HH24:MI:SS');

    -- assign output values
    o_push_start_inv_txn_date := l_push_inv_start_date;
    o_push_end_txn_date := l_push_inv_end_date;
    o_push_last_inv_txn_id := l_push_inv_end_txn_id;
    o_push_last_inv_txn_date := l_push_inv_end_date;
    o_first_push := l_first_push;
    o_txn_flag := l_txn_flag;

    -- if start transaction date is beyond the 'to' date, let user know
    -- that there are no MMT transactions to be processed and move
    -- the transaction start date back to the calculated from date.
    if (o_push_start_inv_txn_date > trunc (i_to_date))   -- Dinkar 10/11/02
        or (o_push_start_inv_txn_date is null)  then
        o_push_start_inv_txn_date := trunc (l_from_date);

        EDW_LOG.PUT_LINE('OPIMPDAT.get_push_dates - no INV transactions to process ');
        EDW_LOG.PUT_LINE('Org id: ' || to_char(i_org_id));
        EDW_LOG.PUT_LINE('Start INV Push Date :'
                         || to_char(o_push_start_inv_txn_date,
                                    'DD-MON-YYYY HH24:MI:SS'));
        EDW_LOG.PUT_LINE('End INV Push Date :'
                         || to_char(o_push_end_txn_date,
                                    'DD-MON-YYYY HH24:MI:SS'));
    end if;

    /*********************************************************************
    == Determine WIP transaction date and id range
    **********************************************************************/
    /*-------------------------------------------
    -- Identify WIP start transaction date and id.
    --------------------------------------------*/
    -- Get the calculated WIP start date
    l_from_date := null;
    l_err_num := 0;
    l_err_code := '';
    l_err_msg := '';

    /**********************************************************************
     * NOTE - WE ARE NOW CHANGING OUR APPROACH FOR THE WIP START DATE.
     * THE WIP START DATE WILL BE ALWAYS THE SAME AS THE INV START DATE.
     * THIS IS NEEDED BECAUSE WE DELETE EVERYTHING FROM THE PUSH LOG STARTING
     * AT THE INV START DATE.
     * THE ONE CASE DROPPED IS THAT OF A WIP TRANSACTION THAT IS BACKDATED TO
     * BEFORE THE INV START DATE.
     * WE FEEL THAT THIS WOULD BE A VERY RARE CASE, AND NEGLIGIBLE IN
     * COMPARISON TO THE ONHAND INVENTORY AND CAN THEREFORE BE IGNORED.
     * digupta - 03/17/02
     **********************************************************************/

    l_stmt_num := 140;
    l_push_wip_start_date := o_push_start_inv_txn_date;

/*
   calc_from_date(i_org_id,
                  i_from_date,
                  l_wip_from_date,
                  l_first_push,
                  l_from_date,       -- start date got from call
                  l_err_num,
                  l_err_code,
                  l_err_msg);
   if l_err_num <> 0 then
      raise process_error;
   end if;
*/
/*
DBMS_OUTPUT.PUT_LINE('WIP l_from_date: ' || to_char(l_from_date));
*/

/*
-- Get the first date that have transactions, including the last push date.
   l_stmt_num := 150;
   select trunc (min(wt.transaction_date))
      into l_wip_txn_date
      from wip_transactions wt
      where wt.organization_id = i_org_id
        and wt.transaction_date >= l_from_date;
*/
/*
-- Get the last transaction of that first date
   l_stmt_num := 160;
   select max(wt.transaction_id)
      into l_wip_txn_id
      from wip_transactions wt
      where wt.organization_id = i_org_id
        and wt.transaction_date BETWEEN trunc(l_wip_txn_date) and
            trunc (l_wip_txn_date) + 0.99999;
*/
/*
-- If the start date is the same day than the last push date, we should re-process
-- the last push date if there are unpushed transactions.  Otherwise, just move on.

   if trunc(l_wip_txn_date) = trunc(l_prev_push_wip_txn_date)
      and l_wip_txn_id <= l_prev_push_wip_txn_id then
         l_push_wip_start_date := l_wip_txn_date + 1;
   else
      -- have unpushed transaction in the last push date
      l_push_wip_start_date := l_wip_txn_date;
   end if;
*/
/*
-- Get the first transaction id of the start date
   l_stmt_num := 170;
   Select min(wt.transaction_id)
      into l_push_wip_start_txn_id
      from wip_transactions wt
      where wt.organization_id = i_org_id
        and wt.transaction_date >= l_push_wip_start_date;
*/
    /*-------------------------------------------------
    -- Determine end process date and WT transaction id
    --------------------------------------------------*/
    if i_to_date is null then
        l_push_wip_end_date := trunc (sysdate);   -- Dinkar 10/11/02
    elsif i_to_date <= l_prev_push_wip_txn_date then
        l_push_wip_end_date := l_prev_push_wip_txn_date;
    else
        l_push_wip_end_date := trunc (i_to_date);  -- Dinkar 10/11/02
    end if;

    -- So that INV and WIP are in sync, process both thru the earliest date
    -- that INV can be processed.

    if l_push_wip_end_date > l_push_inv_end_date
        and l_push_inv_end_date is not null then
        l_push_wip_end_date := l_push_inv_end_date;
    end if;


    /*---------------------------------------------------------------------
    -- Check for back-dated transaction and change the WIP start date if needed
    ----------------------------------------------------------------------*/
/*
   l_stmt_num := 190;
   l_wip_txn_date := null;
   select trunc (min(wt.transaction_date))   -- Dinkar 10/11/02
      into l_wip_txn_date
      from wip_transactions wt
      where wt.organization_id = i_org_id
        and wt.transaction_id >= l_push_wip_start_txn_id;

   if l_wip_txn_date < l_prev_push_wip_txn_date
      and l_first_push <> 1 then
      l_push_wip_start_date := l_wip_txn_date;
   end if;
*/
    /*--------------------------------------------------------------------
    -- Get the first and last WT transactions to be procesed,
    -- now that we have the final transaction date range.
    -- The min transaction id will be found not from the wip start date,
    -- but the period start date of the period the wip dates lie in.
    -- This way, we don't oscillate back and forth with the dates --
    -- see comment for statement 130 above.
    ---------------------------------------------------------------------*/

    l_stmt_num := 200;

    BEGIN
        select period_start_date
          into l_look_for_txn_id
          from org_acct_periods
         where organization_id = i_org_id
           and period_start_date <= trunc (l_push_inv_start_date)
           and schedule_close_date >= trunc (l_push_inv_start_date);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN   -- for start date before period
            l_look_for_txn_id := l_push_inv_start_date;

    END;

    select min(wt.transaction_id), max(wt.transaction_id)
      into l_push_wip_start_txn_id,
           l_push_wip_end_txn_id
      from wip_transactions wt
      where wt.organization_id = i_org_id
        and wt.transaction_date between l_look_for_txn_id
                                 and trunc (l_push_wip_end_date) + 0.99999;

    -- since we mean to collect the entire end date, set the end date
    -- to 23:59:59
    l_push_wip_end_date := to_date ( to_char (l_push_wip_end_date, 'DD-MM-YYYY') || ' 23:59:59', 'DD-MM-YYYY HH24:MI:SS');

    o_push_start_wip_txn_date := l_push_wip_start_date;
    o_push_last_wip_txn_id := l_push_wip_end_txn_id;
    o_push_last_wip_txn_date := l_push_wip_end_date;

    o_err_num := l_err_num;
    o_err_code := l_err_code;
    o_err_msg := l_err_msg;

    -- If there are no WIP transactions for date range
    -- set transaction flag and set last tranx id to the previous push's
    -- last trxn id.

    if (l_push_wip_start_txn_id = 0 or
        l_push_wip_start_txn_id is null) then
        o_push_last_wip_txn_id := l_prev_push_wip_txn_id;
        EDW_LOG.PUT_LINE('OPIMPDAT.get_push_dates - '
                         || 'No WIP transactions for date range');
        if o_txn_flag = 0 then   -- reset flag to process MMT only
            o_txn_flag := 1;
        end if;
   end if;

    -- If the start date is beyond the user-entered end date,
    -- let user know that there are no wip transactions to process
    -- and move the start date back to the calculated from date

    if (o_push_start_wip_txn_date > trunc (i_to_date))  -- Dinkar 10/11/02
        or (o_push_start_wip_txn_date is null)  then
        o_push_start_wip_txn_date := trunc (l_from_date); -- Dinkar 10/11/02

        EDW_LOG.PUT_LINE('OPIMPDAT.get_push_dates - no WIP transactions to process');
        EDW_LOG.PUT_LINE('Org id: ' || to_char(i_org_id));
        EDW_LOG.PUT_LINE('Start WIP Push Date :'
                        || to_char(o_push_start_wip_txn_date,
                                  'DD-MON-YYYY HH24:MI:SS'));
        EDW_LOG.PUT_LINE('End WIP Push Date :'
                         || to_char(o_push_end_txn_date,
                                    'DD-MON-YYYY HH24:MI:SS'));
    end if;

    EDW_LOG.PUT_LINE('OPIMPDAT.get_push_dates-');
    EDW_LOG.PUT_LINE('Org id: ' || to_char(i_org_id));
    EDW_LOG.PUT_LINE('Start Push Date for INV:'
                     || to_char(o_push_start_inv_txn_date,
                                'DD-MON-YYYY HH24:MI:SS'));
    EDW_LOG.PUT_LINE('Start Push Date for WIP:'
                     || to_char(o_push_start_wip_txn_date,
                                'DD-MON-YYYY HH24:MI:SS'));
    EDW_LOG.PUT_LINE('End Push Date: '
                     || to_char(o_push_end_txn_date,
                                'DD-MON-YYYY HH24:MI:SS'));

EXCEPTION
    when process_error then
        o_err_num := l_err_num;
        o_err_code := l_err_code;
        o_err_msg := l_err_msg;

    when no_from_date then
        o_err_num := 9999;
        o_err_msg := 'OPIMPDAT.get_push_dates ('
                     || to_char(l_stmt_num)
                     || ')';
        EDW_LOG.PUT_LINE('No user-entered from date for initial push');
        EDW_LOG.PUT_LINE('Org id: ' ||to_char(i_org_id));

    WHEN no_date_range THEN
        o_err_num := 9999;
        o_err_msg := 'OPIMPDAT.get_push_dates ('
                     || to_char(l_stmt_num)
                     || ')';
        EDW_LOG.PUT_LINE('Not a valid date range since push from date is later than push to date');
        EDW_LOG.PUT_LINE('INV push start date ' || l_push_inv_start_date );
        EDW_LOG.PUT_LINE('INV push end date   ' || l_push_inv_end_date );
        EDW_LOG.PUT_LINE('Org id: ' ||to_char(i_org_id));

    when others then
        o_err_num := SQLCODE;
        o_err_msg := 'OPIMPDAT.get_push_dates - ('
                     || to_char(l_stmt_num)
                     || '): '
                     || substr(SQLERRM, 1,200);
END get_push_dates;

/*============================================================
== PROCEDURE
==   calc_from_date
==
== DESCRIPTION
== This procedure will determine the first transaction dates
== for INV and WIP.  It expects the calling program to always
== pass the i_from_parameter with a valid value.
==
== If it's a first push:
==   i_from_date = null ==> from date = beg date of period containing
==                                      first transaction date
==   i_from_date != null ==> from date = beg date of period containing
==                                       the user-entered 'from' date
==
== If it's not a first push:
==   i_from_date = null ==> use last push transaction date
==   i_from_date != null ==> user last push txn date or user's
==                           from date, whichever is older
==   from date = i_from date if period is open or same closed period
==                           as last push date
==                otherwise, from date is the beg date of period.
======================================================================*/
PROCEDURE calc_from_date(
    i_org_id                 IN   NUMBER,
    i_from_date              IN   DATE,
    i_txn_date               IN   DATE,
    i_first_push             IN   NUMBER,      -- 1=yes, 0=no
    o_calc_from_date         OUT  NOCOPY DATE,
    o_err_num                OUT  NOCOPY NUMBER,
    o_err_code               OUT  NOCOPY VARCHAR2,
    o_err_msg                OUT  NOCOPY VARCHAR2
)  IS
    l_from_date              DATE;
    l_last_txn_date          DATE;
    l_calc_from_date         DATE;
    l_per_start_date         DATE;
    l_sched_close_date       DATE;
    l_per_close_date         DATE;
    l_err_num                NUMBER;
    l_err_code               VARCHAR2(240);
    l_err_msg                VARCHAR2(240);
    l_stmt_num               NUMBER;

BEGIN

    l_err_num := 0;
    l_err_code := null;
    l_err_msg:= null;
    l_from_date := trunc (i_from_date);

    -- If user-defined from date is null, use transaction date as
    -- from date to start with.  If there is user's from date, use it
    -- only if it is older than transaction date; otherwise, use
    -- transaction date.

    if i_from_date is null then
        l_from_date := i_txn_date;
    elsif i_txn_date is not null
        and i_from_date > i_txn_date then
        l_from_date := i_txn_date;
    else
        l_from_date := i_from_date;
    end if;

    BEGIN
        -- Get period dates
        l_stmt_num := 10;
        select trunc (oap.period_start_date),     --Dinkar 10/11/02
               trunc (oap.schedule_close_date),   --Dinkar 10/11/02
               trunc (oap.period_close_date)      --Dinkar 10/11/02
          into l_per_start_date,
               l_sched_close_date,
               l_per_close_date
          from org_acct_periods oap
          where organization_id = i_org_id
            and oap.period_start_date <= l_from_date
            and oap.schedule_close_date >= l_from_date;

        if i_first_push <> 1 then       -- not a first push

            if (trunc(l_from_date) = trunc(l_sched_close_date))
                or (l_per_close_date is null)           -- period is open
                or (l_per_close_date is not null        -- period is closed
                       /* last push date within same period */
                      and i_txn_date is not null
                      and (i_txn_date >= l_per_start_date
                      and i_txn_date <= l_sched_close_date)) then
                          l_calc_from_date := l_from_date; -- no change in date
            else
                l_calc_from_date := l_per_start_date;
            end if;

        else              -- first push
            l_calc_from_date := l_per_start_date;
        end if;

    EXCEPTION
        when no_data_found then
            l_calc_from_date := i_from_date;

    END;

    o_calc_from_date := l_calc_from_date;
    o_err_num := l_err_num;
    o_err_code := l_err_code;
    o_err_msg  := l_err_msg;

EXCEPTION
    when others then
        o_err_num := SQLCODE;
        o_err_msg := 'OPIMPDAT.calc_from_date - ('
                     || to_char(l_stmt_num)
                     || '): '
                     || substr(SQLERRM, 1,200);
END calc_from_date;

END OPIMPDAT;

/
