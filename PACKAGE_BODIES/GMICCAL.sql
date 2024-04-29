--------------------------------------------------------
--  DDL for Package Body GMICCAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMICCAL" AS
/* $Header: gmiccalb.pls 115.10 2003/03/21 14:32:30 jdiiorio ship $ */
/*  =============================================
    FUNCTION:
      trans_date_validate

    DESCRIPTION:
      This PL/SQL function is responsible for
      determining if the date passed in is in a
      valid inventory calendar period based on
      the organization code passed in.

    SYNOPSIS:
      iret := GMICCAL.trans_date_validate(trans_date, porgn_code,
              pwhse_code);

      trans_date - transaction date in format
                   dd-mmm-yyyy hh24:mi:ss
      porgn_code - organization code of type
                   ic_cldr_dtl.orgn_code%TYPE;
      pwhse_code - warehouse code of type
                   ic_whse_mst.whse_code%TYPE;

    RETURNS:
     <-29 RDBMS Oracle Error.
      -29 Warehouse code is not found.
      -28 Warehouse code not passed as a parameter.
      -27 Organization code not passed as a parameter.
      -26 Transaction date not passed as a parameter.
      -25 Warehouse has been closed for the period.
      -24 Company Code not found.
      -23 Date is within a closed inventory calendar period.
      -22 Period end date and close indicator not found.
      -21 Fiscal Yr and Fiscal Yr beginning date not found.
       0 Success
    HISTORY:
    WJ Harris III  03-DEC-98  Resynch r11.0
    Break validation of warehouse code in this
    function only to accomodate defect found in
    plant/warehouse effectivities and production.
    Warehouse validation will be done ONLY on the
    warehouse code.
    Jalaj Srivastava Bug 1579270
    The orgn code passed in as parameter is the document
    orgn code which should not be used for determining
    the fiscal year and the period for the company.
    We need the orgn code of the organization which owns
    the whse code.
    ============================================= */
  FUNCTION trans_date_validate(trans_date DATE,
                               porgn_code VARCHAR2,
                               pwhse_code VARCHAR2)
                               RETURN NUMBER IS
/*  Variable Declarations
    ===================== */
    l_period_date enddate_type;
    l_begin_date  enddate_type;
    l_fiscal_yr   ic_cldr_dtl.fiscal_year%TYPE;
    l_period_ind  ic_cldr_dtl.closed_period_ind%TYPE;
    l_period      ic_cldr_dtl.period%TYPE;
    lp_co_code    orgn_type;
    lp_orgn_code  orgn_type;
    l_whse_code   whse_type;
    iret          NUMBER;

    /* Cursor Definitions
       ================== */
    CURSOR   get_yr_begin_date IS
      SELECT   max(begin_date)
      FROM     ic_cldr_hdr
      WHERE    begin_date <= trans_date
      AND      delete_mark = 0
      AND      UPPER(orgn_code) = UPPER(lp_co_code);

    CURSOR get_fiscal_yr IS
      SELECT fiscal_year
      FROM   ic_cldr_hdr
      WHERE  begin_date = l_begin_date
      AND    delete_mark = 0
      AND    orgn_code  = UPPER(lp_co_code);

    CURSOR get_period_date IS
      SELECT   MIN(Period_end_date)
      FROM     ic_cldr_dtl
      WHERE    TRUNC(period_end_date, 'DD') >=
               TRUNC(trans_date, 'DD')
      AND      fiscal_year = l_fiscal_yr
      AND      UPPER(orgn_code) = UPPER(lp_co_code);

    CURSOR  get_period_info IS
      SELECT  closed_period_ind, period
      FROM    ic_cldr_dtl
      WHERE   fiscal_year = l_fiscal_yr
      AND     period_end_date = l_period_date
      AND     UPPER(orgn_code) = UPPER(lp_co_code);

    CURSOR is_whse_closed IS
      SELECT   whse_code
      FROM     ic_whse_sts
      WHERE    whse_code = UPPER(pwhse_code)
      AND      fiscal_year = l_fiscal_yr
      AND      period = l_period
      AND      close_whse_ind <> 3;

    CURSOR is_whse_there IS
      SELECT   whse_code
      FROM     ic_whse_sts
      WHERE    whse_code = UPPER(pwhse_code)
      AND      fiscal_year = l_fiscal_yr
      AND      period = l_period;

    CURSOR validate_whse IS
      SELECT   whse_code
      FROM     ic_whse_mst
      where    whse_code = UPPER(pwhse_code)
      AND      delete_mark = 0;

    CURSOR get_whse_orgn_code IS
      SELECT   orgn_code
      FROM     ic_whse_mst
      where    whse_code = UPPER(pwhse_code);
--no need for checking the delete mark here
    /* ================================================ */
    BEGIN

      l_period_date := NULL;
      l_fiscal_yr   := NULL;
      lp_co_code    := NULL;
      l_whse_code   := NULL;
      l_period_ind  := 0;

  /*  ======================================
      OK .. Let's validate our parameter
      list shall we.
      ====================================== */

      IF(trans_date IS NULL) THEN
        RETURN INVCAL_DATE_PARM_ERR;
      END IF;

      IF(porgn_code IS NULL) THEN
        RETURN INVCAL_ORGN_PARM_ERR;
      END IF;

      IF(pwhse_code IS NULL) THEN
        RETURN INVCAL_WHSE_PARM_ERR;
      END IF;

      /* =======================================
         Determine organization which owns
         the whse.
         =======================================  */
      OPEN get_whse_orgn_code;
      FETCH get_whse_orgn_code INTO
        lp_orgn_code;
      IF(get_whse_orgn_code%NOTFOUND) THEN
        CLOSE get_whse_orgn_code;
        RETURN INVCAL_WHSE_ERR;
      END IF;
      CLOSE get_whse_orgn_code;


      /* =======================================
      Step One - determine company
      code of organization which owns the whse.
      This calls the determine_company() function
      =======================================  */

      iret := GMICCAL.determine_company(lp_orgn_code, lp_co_code);
      IF(iret <> 0) THEN
        RETURN INVCAL_CO_ERR;

      END IF;

      /* ========================================
      Step Two - Validate the warehouse passed
      ======================================== */
      OPEN validate_whse;
      FETCH validate_whse INTO
        l_whse_code;
      IF(validate_whse%NOTFOUND) THEN

        CLOSE validate_whse;
        RETURN INVCAL_WHSE_ERR;
      END IF;
      CLOSE validate_whse;

  /*  ==================================
      Step Three - determine the
      Fiscal Yr. and the begining date
      of the transaction date passed in.
      ================================== */
      OPEN get_yr_begin_date;
      FETCH get_yr_begin_date INTO l_begin_date;

      IF(get_yr_begin_date%NOTFOUND) THEN

        CLOSE get_yr_begin_date;
        RETURN INVCAL_FISCALYR_ERR;
      END IF;

      IF(l_begin_date IS NULL) THEN
        CLOSE get_yr_begin_date;
        RETURN INVCAL_FISCALYR_ERR;
      END IF;

      CLOSE get_yr_begin_date;
/*    ============================================
      STEP 4
      Get the Fiscal Year associated to the begin
      date fetched.
      ============================================ */
      OPEN get_fiscal_yr;
      FETCH get_fiscal_yr INTO l_fiscal_yr;

      IF(get_fiscal_yr%NOTFOUND) THEN

        CLOSE get_fiscal_yr;
        RETURN INVCAL_FISCALYR_ERR;
      END IF;
      CLOSE get_fiscal_yr;
      /*============================================
      STEP 5
      Fetch the period end date based on Fiscal
      Year, company, and transaction date.
      ============================================ */
      OPEN get_period_date;
      FETCH get_period_date INTO l_period_date;

      IF(get_period_date%NOTFOUND) THEN

        CLOSE get_period_date;
        RETURN INVCAL_PERIOD_ERR;

      ELSIF(l_period_date IS NULL) THEN
        CLOSE get_period_date;
        RETURN INVCAL_PERIOD_ERR;
      END IF;
      CLOSE get_period_date;

      /* ===========================================
      STEP 6
      Fetch the period and closed indicator.
      Determine if the period is opened or closed.
      1 = Open period
      2 = Preliminary Close (This is still opened)
      3 = The bad boy is closed.  No Transactions
      allowed.
      ============================================ */
      OPEN get_period_info;
      FETCH get_period_info INTO l_period_ind, l_period;

      IF(get_period_info%NOTFOUND) THEN

        CLOSE get_period_info;
        RETURN INVCAL_PERIOD_ERR;

      ELSIF(l_period_ind < 3) THEN

        /* ===========================================
        If the calendar period is open for business
        we must also ensure that the warehouse has
        not been final closed and is also open for
        business!
        =========================================== */
        OPEN is_whse_there;
        FETCH is_whse_there INTO l_whse_code;
        IF(is_whse_there%NOTFOUND) THEN
          /* Never entered Inventory Close Form
          ===================================== */
          CLOSE is_whse_there;
          CLOSE get_period_info;
          RETURN 0;
        END IF;
        CLOSE is_whse_there;

        /* ============================================
        Warehouse exists in the warehouse Status table
        so let's determine if it is closed.
        ============================================== */
        OPEN is_whse_closed;
        FETCH is_whse_closed INTO l_whse_code;
        IF(is_whse_closed%NOTFOUND) THEN

          CLOSE is_whse_closed;
          CLOSE get_period_info;
          RETURN INVCAL_WHSE_CLOSED;
        ELSE
          CLOSE is_whse_closed;
          CLOSE get_period_info;
          RETURN 0;
        END IF;

      /* ===========================================
      We have a date in a closed Inventory
      Calendar Period.  Notify calling program.
      =========================================== */
      ELSIF(l_period_ind = 3) THEN
        CLOSE get_period_info;
        RETURN INVCAL_PERIOD_CLOSED;
      END IF;
      CLOSE get_period_info;

      EXCEPTION
        WHEN OTHERS THEN

          RETURN SQLCODE;
    END trans_date_validate;
  /* =============================================
      FUNCTION:
        delete_ic_perd_bal

      DESCRIPTION:
        This PL/SQL function is responsible for
        deleting rows from the ic_perd_bal in conjuction
        with the rerunning of a preliminary close.

      SYNOPSIS:
        iret := GMICCAL.delete_ic_perd_bal(pfiscal_yr, pperiod,
                pwhse_code);

        pfiscal_yr - The fiscal year for the Calendar.
        pperiod    - The period within the Fiscal year.
        pwhse_code - warehouse code

      RETURNS:
         0 Success

      HISTORY:
      M Petrosino 25-Mar-1999 B859062
      delete_ic_perd_bal was missing a return value.
      added return 0 to function.
      ============================================= */
  FUNCTION delete_ic_perd_bal(pfiscal_year VARCHAR2,
                              pperiod    NUMBER,
                              pwhse_code VARCHAR2)
                              RETURN NUMBER IS

    /* ========================================*/
    BEGIN

      DELETE from ic_perd_bal
      WHERE  fiscal_year = UPPER(pfiscal_year)
      AND    period = pperiod
      AND    whse_code = UPPER(pwhse_code);

      IF (SQL%ROWCOUNT = 0 ) THEN
        /* This is not an error ..... it means
        there were no rows to delete dude!
        =================================== */
      RETURN 0;
      END IF;

      RETURN 0;

      EXCEPTION
        WHEN OTHERS THEN
          RETURN SQLCODE;
    END delete_ic_perd_bal;
  /* =============================================
      FUNCTION:
        insert_ic_perd_bal

      DESCRIPTION:
        This PL/SQL function is responsible for
        inserting rows from the ic_perd_bal in conjuction
        with the running of a preliminary or Final close.
        This is the initial seeding of this table.

      SYNOPSIS:
        iret := GMICCAL.insert_ic_perd_bal(pwhse_code);

        pfiscal_year - Fiscal Year of Calendar.
        pper_id      - Period ID surrogate of period within
                       calendar.
        pperiod      - Period within calendar.
        pwhse_code   - warehouse code
        pop_code     - Operators identifier number.

      RETURNS:
         < 0 Oracle RDBMS error.
        >= 0 The number of rows inserted.
      ============================================= */
  FUNCTION insert_ic_perd_bal(pfiscal_year VARCHAR2,
                              pper_id      NUMBER,
                              pperiod      NUMBER,
                              pwhse_code   VARCHAR2,
                              pop_code     NUMBER)
                              RETURN NUMBER IS

    /* ========================================*/
    BEGIN

      INSERT INTO ic_perd_bal
        (perd_bal_id, gl_posted_ind, period_id, fiscal_year,  --bug#2230683
         period, item_id, lot_id,
         whse_code, location, loct_onhand, loct_onhand2,
         loct_usage, loct_usage2, loct_yield, loct_yield2,
         loct_value, lot_status, qchold_res_code,
         log_end_date, creation_date, created_by, last_update_date,
         last_updated_by)
      SELECT gmi_perd_bal_id_s.nextval, 0, pper_id, pfiscal_year,
             pperiod, item_id, lot_id,
             whse_code, location, ROUND(loct_onhand, 9),
             ROUND(loct_onhand2, 9), 0,0,0,0,0,
             lot_status, qchold_res_code, SYSDATE,
             SYSDATE, pop_code, SYSDATE, pop_code
      FROM   ic_loct_inv
      WHERE  whse_code = pwhse_code
      AND    delete_mark = 0 ;

      RETURN SQL%ROWCOUNT;

      EXCEPTION
        WHEN OTHERS THEN

          RETURN SQLCODE;
    END insert_ic_perd_bal;
  /* =============================================
      FUNCTION:
        calc_usage_yield

      DESCRIPTION:
        This PL/SQL function is responsible for
        calculating an item's usage and yield for
        a given period in the Inventory Calendar.
        This function is called from both the
        preliminary and final CLOSE process.

      SYNOPSIS:
        iret := GMICCAL.calc_usage_yield(pwhse_code, pprd_start_date,
                  pprd_end_date, plog_end_date, pperiod,
                  pfiscal_year, pop_code);

        pwhse_code      - warehouse code
        pprd_start_date - start date of the period
        pprd_end_date   - end date of the period
        plog_end_date   - current date.
        pperiod         - Period within calendar.
        pfiscal_year    - Fiscal Year of Calendar.
        pop_code        - Operators identifier number.

      RETURNS:
         < 0 Oracle RDBMS error.
           0 Success.
      ============================================= */
  FUNCTION calc_usage_yield(pwhse_code      VARCHAR2,
                            pprd_start_date DATE,
                            pprd_end_date   DATE,
                            plog_end_date   DATE,
                            pperiod         NUMBER,
                            pprd_id         NUMBER,
                            pfiscal_year    VARCHAR2,
                            pop_code        NUMBER)
                            RETURN NUMBER IS

    /* Local Variable definitions and initialization:
    ================================================= */
    l_item_id       item_srg_type   := 0;
    l_prev_item_id  item_srg_type   := 0;
    l_lot_id        lot_srg_type    := 0;
    l_prev_lot_id   lot_srg_type    := 0;
    l_whse_code     whse_type       := NULL;
    l_location      location_type   := NULL;
    l_prev_location location_type   := NULL;
    l_doc_type      doc_type        := NULL;
    l_line_type     ln_type         := NULL;
    l_reason_code   reasoncode_type := NULL;
    l_reason        reasoncode_type := NULL;
    l_trans_date    DATE            := NULL;
    l_trans_id      trans_srg_type  := 0;
    l_trans_qty     quantity_type   := 0;
    l_trans_qty2    quantity_type   := 0;
    l_yield_qty     quantity_type   := 0;
    l_yield_qty2    quantity_type   := 0;
    l_usage_qty     quantity_type   := 0;
    l_usage_qty2    quantity_type   := 0;
    l_delta_qty     quantity_type   := 0;
    l_delta_qty2    quantity_type   := 0;

    /* Cursor Definitions:
       =================== */
    CURSOR usage_reason(v_reason_code reasoncode_type) IS
      SELECT reason_code
      FROM   sy_reas_cds
      WHERE  flow_type = 0
      AND    delete_mark = 0
      AND    reason_code = v_reason_code;

    CURSOR get_trans IS
      SELECT item_id, lot_id, whse_code,
             location, doc_type, line_type,
             reason_code, trans_date, trans_id,
             trans_qty, trans_qty2
      FROM   ic_tran_pnd
      WHERE  whse_code = UPPER(pwhse_code)
      AND    trans_date >= pprd_start_date
      AND    creation_date <= plog_end_date
      AND    trans_qty <> 0
      AND    completed_ind = 1
      AND    delete_mark = 0
      UNION
      SELECT item_id, lot_id, whse_code,
             location, doc_type, line_type,
             reason_code, trans_date, trans_id,
             trans_qty, trans_qty2
      FROM   ic_tran_cmp
      WHERE  whse_code = UPPER(pwhse_code)
      AND    trans_date >= pprd_start_date
      AND    creation_date <= plog_end_date
      AND    trans_qty <> 0
      AND    doc_type NOT IN ('STSI', 'GRDI',
                              'STSR', 'GRDR')
      ORDER BY 1,2,3,4;

    /* ======================================== */
    BEGIN

      OPEN get_trans;
      FETCH get_trans INTO
        l_item_id, l_lot_id, l_whse_code,
        l_location, l_doc_type, l_line_type,
        l_reason_code, l_trans_date, l_trans_id,
        l_trans_qty, l_trans_qty2;

      IF(get_trans%NOTFOUND) THEN
        CLOSE get_trans;
        RETURN 0;
      END IF;

      l_prev_item_id  := l_item_id;
      l_prev_lot_id   := l_lot_id;
      l_prev_location := l_location;

      /* =================================================== */
      LOOP
        /*  This first condition checks to see if something
        has changed or we do not have anymore rows.  If
        this condition is true, it is time to write our
        results to the ic_perd_bal table.
        =============================================== */
        IF (l_prev_item_id  <> l_item_id OR
            l_prev_lot_id   <> l_lot_id  OR
            l_prev_location <> l_location OR
            get_trans%NOTFOUND) THEN


          /* Item, lot or location has changed so
          let's grab what we accumulated and update
          the perpetual balances for this item, lot,
          and location.
          =========================================== */
          UPDATE ic_perd_bal
          SET    loct_onhand = loct_onhand - ROUND(l_delta_qty, 9),
                 loct_onhand2 = loct_onhand2 - ROUND(l_delta_qty2, 9),
                 loct_usage   = ROUND(l_usage_qty, 9),
                 loct_usage2  = ROUND(l_usage_qty2, 9),
                 loct_yield   = ROUND(l_yield_qty, 9),
                 loct_yield2  = ROUND(l_yield_qty2, 9),
                 last_update_date = SYSDATE,
                 last_updated_by  = pop_code
          WHERE  period_id    = pprd_id
          AND    lot_id       = l_prev_lot_id
          AND    whse_code    = pwhse_code
          AND    location     = l_prev_location
          AND    item_id      = l_prev_item_id
          AND    fiscal_year  = pfiscal_year
          AND    period       = pperiod;

          IF(SQL%ROWCOUNT = 0) THEN
            /* This could be because of a 'PURGE EMPTY BALANCES'
            was run on this particular item.  Therefore, the
            row does not exist so we have to insert it!
            ================================================*/
          INSERT INTO ic_perd_bal
            (perd_bal_id, gl_posted_ind, period_id, lot_id,  --bug#2230683
             whse_code, location, item_id,
             fiscal_year, period, loct_onhand, loct_onhand2,
             loct_usage, loct_usage2, loct_yield, loct_yield2,
             loct_value, lot_status, qchold_res_code,
             log_end_date, creation_date, created_by,
             last_update_date, last_updated_by, last_update_login)
           VALUES
             (gmi_perd_bal_id_s.nextval, 0, pprd_id, l_prev_lot_id, --bug#2230683
              pwhse_code, l_prev_location,
              l_prev_item_id, pfiscal_year, pperiod,
              ROUND((0 - l_delta_qty), 9),
              ROUND((0 - l_delta_qty2), 9),
              ROUND(l_usage_qty, 9),
              ROUND(l_usage_qty2, 9),
              ROUND(l_yield_qty, 9),
              ROUND(l_yield_qty2, 9),
              0, NULL, NULL, SYSDATE, SYSDATE, pop_code,
              SYSDATE,pop_code, NULL);
          END IF;

          /* Let's clear our accumulators!
          ================================ */
          l_delta_qty := 0;
          l_delta_qty2 := 0;
          l_usage_qty  := 0;
          l_usage_qty2 := 0;
          l_yield_qty  := 0;
          l_yield_qty2 := 0;

        END IF;

        /* If this was the last valid fetch then
        bail from loop!
        ===================================== */
        IF(get_trans%NOTFOUND) THEN
          EXIT;
        END IF;

        /* For the row we just fetched, determine if
        it's greater than the period end date. If
        it is, this is our delta quantity!
        =========================================
        Joe DiIorio 06-JAN-1999 Bug#655581 Changed period
        end date check from '+1' to '+.99999 to correct
        problem where transactions from next day in period
        are included in close balances.
        ========================================= */
        IF(l_trans_date > (pprd_end_date + .99999)) THEN
          l_delta_qty  := l_delta_qty  + l_trans_qty;
          l_delta_qty2 := l_delta_qty2 + l_trans_qty2;
        END IF;

        /* Next accumulate our yields
        ==========================
        Joe DiIorio 06-JAN-1999 Bug#655581 Changed period
        end date check from '+1' to '+.99999 to correct
        problem where transactions from next day in period
        are included in close balances.
        ========================== */
        IF (l_doc_type = 'PROD' AND l_line_type > 0
            AND l_trans_date <= (pprd_end_date + .99999)) THEN
          l_yield_qty  := l_yield_qty  + l_trans_qty;
          l_yield_qty2 := l_yield_qty2 + l_trans_qty2;
        END IF;

        /* Next accumulate our usages
        ==========================
        Joe DiIorio 06-JAN-1999 Bug#655581 Changed period
        end date check from '+1' to '+.99999 to correct
        problem where transactions from next day in period
        are included in close balances.
        ========================== */
        IF (l_doc_type = 'PROD' AND l_line_type < 0
            AND l_trans_date <= (pprd_end_date + .99999)) THEN
          l_usage_qty  := l_usage_qty  + l_trans_qty;
          l_usage_qty2 := l_usage_qty2 + l_trans_qty2;
        ELSIF (l_doc_type = 'ADJI' OR l_doc_type = 'ADJR'
            AND l_trans_date <= (pprd_end_date + .99999)) THEN
          OPEN usage_reason(l_reason_code);
          FETCH usage_reason INTO
            l_reason;
          IF(usage_reason%FOUND) THEN
            l_usage_qty  := l_usage_qty  + l_trans_qty;
            l_usage_qty2 := l_usage_qty2 + l_trans_qty2;
          END IF;
          CLOSE usage_reason;

        END IF;

        /* Let's prepare for next fetch so we can determine
        if the item, lot, location has changed or not.
        ================================================ */
        l_prev_item_id  := l_item_id;
        l_prev_lot_id   := l_lot_id;
        l_prev_location := l_location;

        FETCH get_trans INTO
          l_item_id, l_lot_id, l_whse_code,
          l_location, l_doc_type, l_line_type,
          l_reason_code, l_trans_date, l_trans_id,
          l_trans_qty, l_trans_qty2;
      END LOOP;
      /* ======================================================== */
      CLOSE get_trans;
      RETURN 0;


      EXCEPTION
        WHEN OTHERS THEN

          RETURN SQLCODE;
    END calc_usage_yield;
  /* =============================================
      FUNCTION:
        whse_status_update

      DESCRIPTION:
        This PL/SQL function is responsible for
        updating the warehouse status
        as the result of either an inventory calendar
        preliminary or final close of a warehouse.

      SYNOPSIS:
        iret := GMICCAL.whse_status_update(pwhse_code,
                pperiod, pclose_type);

        pwhse_code  - warehouse which has been preliminary
                      or final closed.
        pfiscal_year- The company fiscal Year for the
                      inventory calendar.
        pperiod     - The inventory calendar period.
        pclose_type - 2 denotes preliminary close of warehouse.
                      3 denotes Final Close of warehouse.

      RETURNS:
          0 Success
        -30 Update warehouse status error.
      HISTORY:
        Sastry  05/17/2002 BUG#2356476
        Modified the Update statement to update the columns
        last_updated_by,last_update_date and last_update_login.
      ============================================= */
  FUNCTION whse_status_update(pwhse_code   VARCHAR2,
                              pfiscal_year VARCHAR2,
                              pperiod      NUMBER,
                              pclose_type  NUMBER) RETURN NUMBER IS

    /* ================================================ */
    BEGIN
      -- BEGIN BUG#2356476 Sastry
      -- Also update last_updated_by,last_update_date and last_update_login.
      UPDATE ic_whse_sts
        SET log_end_date = SYSDATE,
            close_whse_ind = pclose_type,
            last_updated_by = FND_GLOBAL.USER_ID,
			   last_update_date = SYSDATE,
			   last_update_login = FND_GLOBAL.LOGIN_ID
      WHERE fiscal_year = pfiscal_year
      AND   period      = pperiod
      AND   whse_code   = UPPER(pwhse_code);
      -- END BUG#2356476

      IF(SQL%ROWCOUNT = 0) THEN
        RETURN INVCAL_WHSESTS_UPDATE_ERR;
      END IF;

      RETURN 0;

      EXCEPTION
        WHEN OTHERS THEN

          RETURN SQLCODE;

    END whse_status_update;
  /* =============================================
      FUNCTION:
        period_status_update

      DESCRIPTION:
        This PL/SQL function is responsible for
        updating the Inventory Calendar Period status
        as the result of either an inventory calendar
        preliminary or final close of a warehouse.

      SYNOPSIS:
        iret := GMICCAL.period_status_update(pco_code,
                pfiscal_year, pperiod, pclose_type);

        pco_code    - The company for the Inventory Calendar.
        pfiscal_year- The fiscal year of the Calendar.
        pperiod     - The inventory calendar period.

      RETURNS:
          0 Success
        -31 Update period status error.
      ============================================= */
  FUNCTION period_status_update(pco_code     VARCHAR2,
                                pfiscal_year VARCHAR2,
                                pperiod      NUMBER) RETURN NUMBER IS
    /* Local Variables:
    ================ */
    l_whse_code  whse_type := NULL;
    l_close_type NUMBER    := NULL;

    /* Cursor Definitions
       ================== */
    CURSOR determine_type IS
      SELECT s.whse_code
      FROM   ic_whse_sts s, ic_whse_mst w,
             sy_orgn_mst o
      WHERE  o.co_code = UPPER(pco_code)
      AND    w.orgn_code = o.orgn_code
      AND    s.whse_code = w.whse_code
      AND    s.fiscal_year = pfiscal_year
      AND    s.period = pperiod
      AND    s.close_whse_ind <> 3;

    /* ================================================ */
    BEGIN

      OPEN determine_type;
      FETCH determine_type INTO
        l_whse_code;

      IF(l_whse_code IS NULL) THEN
        /* All the warehouses are final closed
        ====================================== */
        l_close_type := 3;
      ELSE
        /* Some of the warehouses are still opened
        ========================================== */
        l_close_type := 2;
      END IF;
      CLOSE determine_type;


      UPDATE ic_cldr_dtl
        SET  closed_period_ind = l_close_type,
             last_update_date = SYSDATE
      WHERE  orgn_code = pco_code
      AND    fiscal_year = pfiscal_year
      AND    period      = pperiod;

      IF(SQL%ROWCOUNT = 0) THEN
        RETURN INVCAL_PRDSTS_UPDATE_ERR;
      END IF;
      RETURN 0;

      EXCEPTION
        WHEN OTHERS THEN

          RETURN SQLCODE;


    END period_status_update;
  /* =============================================
      FUNCTION:
        determine_company

      DESCRIPTION:
        This PL/SQL function is responsible for
        determining the company associated to the
        passed in organization code.

      SYNOPSIS:
        iret := GMICCAL.determine_company(porgn_code,
                pout_orgn_code);

        porgn_code - organization code of type
                     ic_cldr_dtl.orgn_code%TYPE;
        porgn_code - will hold the company code of type
                     ic_cldr_dtl.orgn_code%TYPE;


      RETURNS:
          0 Success
        -41 Company not found.
        -42 Organization not valid.
       <-42 RDBMS Oracle Error.
      ============================================= */
  FUNCTION determine_company(porgn_code VARCHAR2,
    pout_co_code IN OUT NOCOPY VARCHAR2) RETURN NUMBER IS

    /* Local Variables
    =============== */
    l_orgn_code orgn_type;
    l_company   orgn_type;

    /* Cursor Definitions
    ================== */
    CURSOR validate_orgn_code IS
      SELECT orgn_code
      FROM   sy_orgn_mst
      WHERE  orgn_code = UPPER(porgn_code)
      AND    delete_mark = 0;

    CURSOR get_company IS
      SELECT UPPER(co_code)
      FROM   sy_orgn_mst
      WHERE  orgn_code = UPPER(porgn_code)
      AND    delete_mark = 0;

    /* ================================================ */
    BEGIN

      l_orgn_code := NULL;
      l_company   := NULL;


      /* Step One - determine if we have a
      valid organization being passed.
      If we do not inform the caller and
      bail!
      ================================== */
      OPEN validate_orgn_code;
      FETCH validate_orgn_code INTO l_orgn_code;

      IF(validate_orgn_code%NOTFOUND) THEN

        CLOSE validate_orgn_code;
        RETURN ORGN_VAL_ERR;

      END IF;
      CLOSE validate_orgn_code;
      /* ===================================
      Step Two - Determine the company
      associated to the organization
      =================================== */
      OPEN get_company;
      FETCH get_company INTO l_company;

      IF(get_company%NOTFOUND) THEN
        CLOSE get_company;
        RETURN ORGN_CO_ERR;

      END IF;
      CLOSE get_company;

      /* ==================================
      We have been successful!  Return
      the company code to the caller
      and a status of zero.
      ================================== */
      pout_co_code := l_company;


      RETURN 0;


      EXCEPTION
        WHEN OTHERS THEN

          RETURN SQLCODE;
    END determine_company;

  END;

/
