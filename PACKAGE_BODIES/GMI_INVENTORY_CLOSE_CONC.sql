--------------------------------------------------------
--  DDL for Package Body GMI_INVENTORY_CLOSE_CONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_INVENTORY_CLOSE_CONC" AS
/* $Header: gmisubrb.pls 115.9 2004/07/08 20:58:31 acataldo noship $ */

/* Added local variable for debugging - Bug 3684980 */
x_prev_time	DATE;
x_cur_time	DATE;
PROCEDURE RUN(
       errbuf           OUT NOCOPY VARCHAR2,
       retcode  	OUT NOCOPY VARCHAR2,
       P_sequence       IN	VARCHAR2,
       P_fiscal_year    IN	VARCHAR2,
       P_period         IN	VARCHAR2,
       P_period_id      IN	VARCHAR2,
       P_start_date     IN	VARCHAR2,
       P_end_date       IN	VARCHAR2,
       P_op_code        IN	VARCHAR2,
       P_orgn_code      IN      VARCHAR2,
       P_close_ind      IN	VARCHAR2)

IS

Cursor Get_Whse IS
Select whse_code from
gmi_clos_warehouses
where inventory_close_id = P_sequence
order by whse_code;

x_whse_code                IC_WHSE_MST.WHSE_CODE%TYPE;
l_iret                     NUMBER := -1;

x_period_id                NUMBER;
x_period                   NUMBER;
x_op_code                  NUMBER;
x_start_date               DATE;
x_end_date                 DATE;

/*BEGIN BUG#2589255 James Bernard */
/*Created a new local variable x_exception to handle exceptions */
x_exception 		   EXCEPTION;
/*END BUG#2589255 */

BEGIN
  errbuf := NULL;
  retcode := '0';
  x_close_err := 0;
  /********************************************************************
    Debugging Information.
   *******************************************************************/
  FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'INPUT PARAMETERS');
  FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'SEQUENCE   - '||P_sequence);
  FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'FISCAL YEAR- '||p_fiscal_year);
  FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'PERIOD     - '||p_period);
  FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'PERIOD ID  - '||p_period_id);
  FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'START DATE - '||P_start_date);
  FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'END DATE   - '||P_end_date);
  FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'OP CODE    - '||P_op_code);
  FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'ORGN CODE  - '||P_orgn_code);
  FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'CLOSE IND  - '||P_close_ind);

  /* Debugging statements - Bug 3684980 */
  x_cur_time := sysdate;
  FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Start of the Close process (ver 3)- '||
	to_char(x_cur_time, 'hh24:mi:ss') );
  x_prev_time := x_cur_time;


  OPEN Get_Whse;
  FETCH Get_Whse into x_whse_code;
  IF (Get_Whse%NOTFOUND) THEN
     CLOSE Get_Whse;
     FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'No Warehouse selected for Close');
     /*BEGIN BUG#2589255 James Bernard */
     /*Raising x_exception as GMI_CLOS_WAREHOUSES table has to be cleaned for */
     /*whse row being processed */
     RAISE x_exception;
     /*END BUG#2589255 */
     RETURN;
  END IF;

  LOOP
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'     ');
  	/* Debugging statements - Bug 3684980 */
  	x_cur_time := sysdate;
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Processing Warehouse '||x_whse_code || ' - '||
		to_char(x_cur_time, 'hh24:mi:ss') );
  	x_prev_time := x_cur_time;

    /**********************************************************
      Delete all rows from the
      ic_perd_bal table for this warehouse.
     **********************************************************/

     FND_MESSAGE.set_name('GMI', 'ICCAL_DELETE_PERD_MSG');
     FND_MESSAGE.set_token('WHSE', x_whse_code);
     X_msg := FND_MESSAGE.GET;
     x_cur_time := sysdate;
     FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'	'||X_msg || ' - '|| to_char(x_cur_time, 'hh24:mi:ss') );
     x_prev_time := x_cur_time;

     l_iret := GMICCAL.delete_ic_perd_bal(P_fiscal_year, P_period, x_whse_code);
     IF (l_iret < 0) THEN
        FND_MESSAGE.SET_NAME('GMI','IC_PERD_BAL_DELETE_ERR');
        FND_MESSAGE.set_token('ERRNO', TO_CHAR(l_iret));
        X_msg := FND_MESSAGE.GET;
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT,X_msg);
        /*BEGIN BUG#2589255 James Bernard */
        /*Raising x_exception as GMI_CLOS_WAREHOUSES table has to be cleaned for
        whse row being processed */
        RAISE x_exception;
        /*END BUG#2589255 */
        RETURN;
      END IF;
  	 /* Debugging statements - Bug 3684980 */
     x_cur_time := sysdate;
     FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'	Completed '||X_msg || ' - '||
		to_char(x_cur_time, 'hh24:mi:ss') );
     x_prev_time := x_cur_time;
     /***********************************************************
      Insert into ic_perd_bal for this warehouse.
     *********************************************************/

      FND_MESSAGE.set_name('GMI', 'ICCAL_CREATE_PERD_MSG');
      FND_MESSAGE.set_token('WHSE', x_whse_code);
      X_msg := FND_MESSAGE.GET;
  	  /* Debugging statements - Bug 3684980 */
      x_cur_time := sysdate;
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'	'||X_msg || ' - '||
		to_char(x_cur_time, 'hh24:mi:ss') );
     x_prev_time := x_cur_time;


x_period_id := to_number(P_period_id);
x_period := to_number(P_period);
x_op_code := to_number(P_op_code);
x_start_date :=  to_date(P_start_date,'YYYY/MM/DD HH24:MI:SS');
x_end_date :=  to_date(P_end_date,'YYYY/MM/DD HH24:MI:SS');

      inventory_close(P_fiscal_year,
                      x_period_id,
                      x_period,
                      x_whse_code,
                      x_op_code,
                      x_start_date,
                      x_end_date);
     IF (x_close_err = 1) THEN
        /*BEGIN BUG#2589255 James Bernard */
        /*Raising x_exception as GMI_CLOS_WAREHOUSES table has to be cleaned for
        whse row being processed */
        RAISE x_exception;
        /*END BUG#2589255 */
        RETURN;
     END IF;
  	  /* Debugging statements - Bug 3684980 */
      FND_MESSAGE.set_name('GMI', 'ICCAL_CREATE_PERD_MSG');
      FND_MESSAGE.set_token('WHSE', x_whse_code);
      X_msg := FND_MESSAGE.GET;
      x_cur_time := sysdate;
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'	Completed '||X_msg || ' - '||
		to_char(x_cur_time, 'hh24:mi:ss') );
      x_prev_time := x_cur_time;
     /**********************************************************
      Calculate Costs  --BUG#2230683 - removed calculate cost logic.
     *********************************************************/


     /********************************************************
      Update the status of the warehouse
      ********************************************************/
  	  /* Debugging statements - Bug 3684980 */
      FND_MESSAGE.set_name('GMI', 'ICCAL_UPDATEWHSE_STS_MSG');
      FND_MESSAGE.set_token('WHSE', x_whse_code);
      X_msg := FND_MESSAGE.GET;
      x_cur_time := sysdate;
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'	'||X_msg || ' - '|| to_char(x_cur_time, 'hh24:mi:ss') );
      x_prev_time := x_cur_time;

      l_iret := -1;
      l_iret := GMICCAL.whse_status_update(x_whse_code, P_fiscal_year,
                  P_period, P_close_ind);
      IF (l_iret < 0) THEN
        FND_MESSAGE.SET_NAME('GMI','IC_WHSE_STATUS_UPDATE_ERR');
        FND_MESSAGE.set_token('ERRNO', TO_CHAR(l_iret));
        X_msg := FND_MESSAGE.GET;
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT,X_msg);
        /*BEGIN BUG#2589255 James Bernard */
        /*Raising x_exception as GMI_CLOS_WAREHOUSES table has to be cleaned for
        whse row being processed */
        RAISE x_exception;
        /*END BUG#2589255 */
        RETURN;
      END IF;

  	  /* Debugging statements - Bug 3684980 */
      FND_MESSAGE.set_name('GMI', 'ICCAL_UPDATEWHSE_STS_MSG');
      FND_MESSAGE.set_token('WHSE', x_whse_code);
      X_msg := FND_MESSAGE.GET;
      x_cur_time := sysdate;
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'	Completed '||X_msg || ' - '||
		to_char(x_cur_time, 'hh24:mi:ss') );
      x_prev_time := x_cur_time;
      /***********************************************
        Clean up database for whse row processed.
       **********************************************/
      DELETE gmi_clos_warehouses
      where inventory_close_id = P_sequence AND
            whse_code = x_whse_code;
      IF (SQLCODE <> 0) THEN
         FND_MESSAGE.SET_NAME('GMI','IC_DELETE_CLOSE_ERROR');
         FND_MESSAGE.set_token('ERRORCODE', TO_CHAR(SQLCODE));
         X_msg := FND_MESSAGE.GET;
         FND_FILE.PUT_LINE (FND_FILE.OUTPUT,X_msg);
         RETURN;
      END IF;


      COMMIT;
      FETCH Get_Whse into x_whse_code;
      IF (Get_Whse%NOTFOUND) THEN
         EXIT;
      END IF;
  END LOOP;
  CLOSE Get_Whse;

  /*********************************************
    Update the Status of the Period if required.
   *********************************************/

  /* Debugging statements - Bug 3684980 */
  FND_MESSAGE.set_name('GMI', 'ICCAL_UPDATE_PERIOD_MSG');
  FND_MESSAGE.set_token('WHSE', x_whse_code);
  X_msg := FND_MESSAGE.GET;
  x_cur_time := sysdate;
  FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'	'||X_msg || ' - '|| to_char(x_cur_time, 'hh24:mi:ss') );
  x_prev_time := x_cur_time;

  l_iret := -1;
  l_iret := GMICCAL.period_status_update(P_orgn_code, p_fiscal_year,
                  P_period);

  IF(l_iret < 0) THEN
    FND_MESSAGE.SET_NAME('GMI','IC_WHSE_STATUS_UPDATE_ERR');
    FND_MESSAGE.set_token('ERRNO', TO_CHAR(l_iret));
    X_msg := FND_MESSAGE.GET;
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,X_msg);
    RETURN;
  END IF;

  FND_MESSAGE.set_name('GMI', 'ICCAL_UPDATE_PERIOD_MSG');
  FND_MESSAGE.set_token('WHSE', x_whse_code);
  /* Debugging statements - Bug 3684980 */
  x_cur_time := sysdate;
  FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'	Completed '||X_msg || ' - '|| to_char(x_cur_time, 'hh24:mi:ss') );
  x_prev_time := x_cur_time;

  /***********************************************
    If all is well, commit and give final message.
   **********************************************/

   COMMIT;
   FND_MESSAGE.SET_NAME('GMI','ICCAL_CLOSE_SUCCESS_MSG');
   X_msg := FND_MESSAGE.GET;
   /* Debugging statements - Bug 3684980 */
   x_cur_time := sysdate;
   FND_FILE.PUT_LINE (FND_FILE.OUTPUT,X_msg || ' - '|| to_char(x_cur_time, 'hh24:mi:ss') );
   x_prev_time := x_cur_time;
   RETURN;

   /*BEGIN BUG#2589255 James Bernard */
   /*Handling the user defined exception */
   EXCEPTION
        WHEN x_exception then
        /***********************************************
        Clean up GMI_CLOS_WAREHOUSE for whse row processed.
        **********************************************/
        DELETE gmi_clos_warehouses
        where inventory_close_id = P_sequence AND
            whse_code = x_whse_code;
        COMMIT;
        IF (SQL%ROWCOUNT = 0) THEN
          FND_MESSAGE.SET_NAME('GMI','IC_DELETE_CLOSE_ERROR');
          FND_MESSAGE.set_token('ERRORCODE', TO_CHAR(SQLCODE));
          X_msg := FND_MESSAGE.GET;
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT,X_msg);
          RETURN;
        END IF;

        WHEN fnd_file.utl_file_error THEN

        /***********************************************
        Clean up GMI_CLOS_WAREHOUSE for whse row processed.
        **********************************************/
        DELETE gmi_clos_warehouses
        where inventory_close_id = P_sequence AND
            whse_code = x_whse_code;
        COMMIT;
        IF (SQL%ROWCOUNT = 0) THEN
          FND_MESSAGE.SET_NAME('GMI','IC_DELETE_CLOSE_ERROR');
          FND_MESSAGE.set_token('ERRORCODE', TO_CHAR(SQLCODE));
          X_msg := FND_MESSAGE.GET;
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT,X_msg);
          RETURN;
        END IF;

        WHEN others THEN

        /***********************************************
        Clean up GMI_CLOS_WAREHOUSE for whse row processed.
        **********************************************/
        DELETE gmi_clos_warehouses
        where inventory_close_id = P_sequence AND
            whse_code = x_whse_code;
        COMMIT;
        IF (SQL%ROWCOUNT = 0) THEN
          FND_MESSAGE.SET_NAME('GMI','IC_DELETE_CLOSE_ERROR');
          FND_MESSAGE.set_token('ERRORCODE', TO_CHAR(SQLCODE));
          X_msg := FND_MESSAGE.GET;
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT,X_msg);
          RETURN;
        END IF;

   /*END BUG#2589255 */

END RUN;

/* =====================================================
      PROCEDURE:
        inventory_close

      DESCRIPTION:
        This PL/SQL procedure is responsible for
        inserting rows from the ic_perd_bal in conjuction
        with the running of a preliminary or Final close.
        This is the initial seeding of this table.
        Then it calculates the usage and yield

      SYNOPSIS:
        icprded1_process.inventory_close(pfiscal_year,
                              pprd_id,
                              pperiod,
                              pwhse_code,
                              pop_code,
                              pprd_start_date,
                              pprd_end_date);

        pfiscal_year - Fiscal Year of Calendar.
        pprd_id      - Period ID surrogate of period within
                       calendar.
        pperiod      - Period within calendar.
        pwhse_code   - warehouse code
        pop_code     - Operators identifier number.
        pprd_start_date - start date of the period
        pprd_end_date   - end date of the period

        BUG#2355980 VRA Srinivas 24-Jun-2002.
        Added the code for picking the correct lot_ststaus
        from the corresponding period.
  	     The lot_status is fetched from ic_adjs_jnl table in the
  	     query because if the item's status control is of type 2
  	     then no transactions will be inserted in ic_tran_cmp table.
        It is not required to use doc_type in the where clause
        because for TRNI and TRNR also based on the value of profile
        option IC$MOVEDIFFSTAT the status might change.
      ======================================================*/

 PROCEDURE inventory_close(pfiscal_year VARCHAR2,
                              pprd_id      NUMBER,
                              pperiod      NUMBER,
                              pwhse_code   VARCHAR2,
                              pop_code     NUMBER,
                              pprd_start_date DATE,
                              pprd_end_date   DATE) IS

   /* ================================================
      Local Variable definitions and initialization:
      ===============================================*/
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
    l_log_end_date  DATE            := NULL;
    uwhse_code      VARCHAR2(4);
    --BEGIN BUG#2355980 Srinivas
    x_lot_status     VARCHAR2(4);
    --END BUG#2355980

    /**********************************************
       Cursor Definitions:
     **********************************************/

    CURSOR usage_reason(v_reason_code reasoncode_type) IS
      SELECT reason_code
      FROM   sy_reas_cds
      WHERE  flow_type = 0
      AND    delete_mark = 0
      AND    reason_code = v_reason_code;

	/* Bug 3684980 - changed to ic_item_mst_b for perf. */
	/* Also only populated ic_perd_bal with non-zero rows */
    Cursor get_loct_onhand is
      SELECT v.item_id ,v.lot_id ,
             whse_code ,location ,ROUND(loct_onhand,9) onhand,
             ROUND(loct_onhand2,9) onhand2,
             v.lot_status,v.qchold_res_code
      from   ic_loct_inv v, ic_item_mst_b m
      WHERE  whse_code = pwhse_code
      AND    noninv_ind = 0
      AND    v.item_id = m.item_id
      AND    v.delete_mark = 0
      AND    (nvl(v.loct_onhand,0) <> 0 OR nvl(v.loct_onhand2,0) <> 0);

    get_loct_onhand_rec     get_loct_onhand%ROWTYPE;

     --BEGIN BUG#2355980 Srinivas

       Cursor lot_status_cur (x_item_id Number,x_lot_id Number,x_location varchar2,x_whse_code varchar2)
        IS
        SELECT lot_status
        FROM   ic_adjs_jnl
        WHERE  line_id  = (select max(line_id) from ic_adjs_jnl
        			WHERE   item_id = x_item_id
        			 AND    lot_id  = x_lot_id
        			 AND    location = x_location
        			 AND    whse_code = x_whse_code
				    AND    completed_ind = 1
        			 AND    Trunc(doc_date) BETWEEN Trunc(pprd_start_date)
        			 AND    Trunc(pprd_end_date));

      --END BUG#2355980

   /**********************************************
     Joe DiIorio 09/05/2001 BUG#1930560
     Added check for retrieving only inventory
     items.
    *********************************************/


	/* Bug 3684980 - changed to union all and ic_item_mst_b for perf. */
    CURSOR get_trans IS
      SELECT p.item_id, lot_id, whse_code,
             location, doc_type, line_type,
             reason_code, trans_date, trans_id,
             trans_qty, trans_qty2
      FROM   ic_tran_pnd p, ic_item_mst_b m
      WHERE  whse_code = uwhse_code
      AND    trans_date >= pprd_start_date
      AND    p.creation_date <= l_log_end_date
      AND    trans_qty <> 0
      AND    completed_ind = 1
      AND    p.delete_mark = 0
      AND    p.item_id = m.item_id
      AND    noninv_ind = 0
      UNION ALL
      SELECT c.item_id, lot_id, whse_code,
             location, doc_type, line_type,
             reason_code, trans_date, trans_id,
             trans_qty, trans_qty2
      FROM   ic_tran_cmp c, ic_item_mst_b m
      WHERE  whse_code = uwhse_code
      AND    trans_date >= pprd_start_date
      AND    c.creation_date <= l_log_end_date
      AND    trans_qty <> 0
      AND    c.item_id = m.item_id
      AND    noninv_ind = 0
      AND    doc_type NOT IN ('STSI', 'GRDI',
                              'STSR', 'GRDR')
      ORDER BY 1,2,3,4;

    BEGIN

COMMIT;
EXECUTE IMMEDIATE 'set transaction read only';
/* Debugging statements - Bug 3684980 */
x_cur_time := sysdate;
FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'		Before opening get_loct_onhand cursor - '||
	to_char(x_cur_time, 'hh24:mi:ss') );
x_prev_time := x_cur_time;

open get_loct_onhand;

/* Debugging statements - Bug 3684980 */
x_cur_time := sysdate;
FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'		After opening get_loct_onhand cursor - '||
	to_char(x_cur_time, 'hh24:mi:ss') );
x_prev_time := x_cur_time;

select sysdate into l_log_end_date from dual;
uwhse_code := UPPER(pwhse_code);

/* Debugging statements - Bug 3684980 */
x_cur_time := sysdate;
FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'		Before opening get_trans cursor - '||
	to_char(x_cur_time, 'hh24:mi:ss') );
x_prev_time := x_cur_time;

open get_trans;

/* Debugging statements - Bug 3684980 */
x_cur_time := sysdate;
FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'		After opening get_trans cursor - '||
	to_char(x_cur_time, 'hh24:mi:ss') );
x_prev_time := x_cur_time;
COMMIT;

/* Debugging statements - Bug 3684980 */
x_cur_time := sysdate;
FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'		Before insert into ic_perd_bal - '||
	to_char(x_cur_time, 'hh24:mi:ss') );
x_prev_time := x_cur_time;

LOOP
fetch get_loct_onhand into get_loct_onhand_rec;
EXIT WHEN get_loct_onhand%NOTFOUND;

       -- Bug 3684980 - removed update and executed single insert
       --BEGIN BUG#2355980 Srinivas
       x_lot_status := get_loct_onhand_rec.lot_status;
       OPEN lot_status_cur(get_loct_onhand_rec.item_id,get_loct_onhand_rec.lot_id,
                             get_loct_onhand_rec.location,get_loct_onhand_rec.whse_code);
       FETCH lot_status_cur into x_lot_status;
       CLOSE lot_status_cur;


      INSERT INTO ic_perd_bal
        (perd_bal_id, gl_posted_ind, period_id, fiscal_year,  --bug#2230683
         period, item_id, lot_id,
         whse_code, location, loct_onhand, loct_onhand2,
         loct_usage, loct_usage2, loct_yield, loct_yield2,
         loct_value, lot_status, qchold_res_code,
         log_end_date, creation_date, created_by, last_update_date,
         last_updated_by)
      VALUES(gmi_perd_bal_id_s.nextval,0, pprd_id, pfiscal_year, pperiod, get_loct_onhand_rec.item_id, get_loct_onhand_rec.lot_id,
             get_loct_onhand_rec.whse_code, get_loct_onhand_rec.location, get_loct_onhand_rec.onhand,
             get_loct_onhand_rec.onhand2, 0,0,0,0,0,
             x_lot_status, get_loct_onhand_rec.qchold_res_code, l_log_end_date,
             SYSDATE, pop_code, SYSDATE, pop_code);


          --END BUG#2355980


END LOOP;
CLOSE get_loct_onhand;
/* Debugging statements - Bug 3684980 */
x_cur_time := sysdate;
FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'		After insert into ic_perd_bal - '||
	to_char(x_cur_time, 'hh24:mi:ss') );
x_prev_time := x_cur_time;

/***********************************************
        calc_usage_yield

      DESCRIPTION:
        This PL/SQL block is responsible for
        calculating an item's usage and yield for
        a given period in the Inventory Calendar.
        This function is called from both the
        preliminary and final CLOSE process.
 ***********************************************/

FND_MESSAGE.set_name('GMI','ICCAL_PERD_MSG');
FND_MESSAGE.set_token('WHSE',pwhse_code);
X_msg := FND_MESSAGE.GET;
-- FND_FILE.PUT_LINE (FND_FILE.OUTPUT,X_msg);

      FETCH get_trans INTO
        l_item_id, l_lot_id, l_whse_code,
        l_location, l_doc_type, l_line_type,
        l_reason_code, l_trans_date, l_trans_id,
        l_trans_qty, l_trans_qty2;

 IF (get_trans%NOTFOUND) THEN
      CLOSE get_trans;
 ELSE

      l_prev_item_id  := l_item_id;
      l_prev_lot_id   := l_lot_id;
      l_prev_location := l_location;

/* Debugging statements - Bug 3684980 */
x_cur_time := sysdate;
FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'		Before Updating ic_perd_bal with transaction quantities - '||
	to_char(x_cur_time, 'hh24:mi:ss') );
x_prev_time := x_cur_time;

      LOOP
         /*==========================================
           This first condition checks to see if something
           has changed or we do not have anymore rows.  If
           this condition is true, it is time to write our
           results to the ic_perd_bal table.
           ==========================================*/
        IF (l_prev_item_id  <> l_item_id OR
            l_prev_lot_id   <> l_lot_id  OR
            l_prev_location <> l_location OR
            get_trans%NOTFOUND) THEN
            /*==========================================
            Item, lot or location has changed so
            let's grab what we accumulated and update
            the perpetual balances for this item, lot,
            and location.
             ==========================================*/
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
          /*============================================
             This could be because of a 'PURGE EMPTY BALANCES'
            was run on this particular item.  Therefore, the
            row does not exist so we have to insert it!
           ============================================*/
          INSERT INTO ic_perd_bal
            (perd_bal_id, gl_posted_ind, period_id, lot_id,  --bug#2230683
             whse_code, location, item_id,
             fiscal_year, period, loct_onhand, loct_onhand2,
             loct_usage, loct_usage2, loct_yield, loct_yield2,
             loct_value, lot_status, qchold_res_code,
             log_end_date, creation_date, created_by,
             last_update_date, last_updated_by, last_update_login)
           VALUES
             (gmi_perd_bal_id_s.nextval, 0, pprd_id, l_prev_lot_id,
              pwhse_code, l_prev_location,
              l_prev_item_id, pfiscal_year, pperiod,
              ROUND((0 - l_delta_qty), 9),
              ROUND((0 - l_delta_qty2), 9),
              ROUND(l_usage_qty, 9),
              ROUND(l_usage_qty2, 9),
              ROUND(l_yield_qty, 9),
              ROUND(l_yield_qty2, 9),
              0, NULL, NULL, l_log_end_date, SYSDATE, pop_code,
              SYSDATE,pop_code, NULL);
          END IF;

        /*==========================================
           Let's clear our accumulators!
        ==========================================*/
          l_delta_qty := 0;
          l_delta_qty2 := 0;
          l_usage_qty  := 0;
          l_usage_qty2 := 0;
          l_yield_qty  := 0;
          l_yield_qty2 := 0;
        END IF;  -- item/lot/location change if

        /*==================================
         If this was the last valid fetch then
         bail from loop!
        ==================================*/
        IF (get_trans%NOTFOUND) THEN
          EXIT;
        END IF;
        /*================================
         For the row we just fetched, determine if
        it's greater than the period end date. If
        it is, this is our delta quantity!
        ================================*/
        IF (l_trans_date > (pprd_end_date + .99999)) THEN
          l_delta_qty  := l_delta_qty  + l_trans_qty;
          l_delta_qty2 := l_delta_qty2 + l_trans_qty2;
        END IF;

        /*======================================
         Next accumulate our yields
          ======================================*/
        IF (l_doc_type = 'PROD' AND l_line_type > 0
            AND l_trans_date <= (pprd_end_date + .99999)) THEN
          l_yield_qty  := l_yield_qty  + l_trans_qty;
          l_yield_qty2 := l_yield_qty2 + l_trans_qty2;
        END IF;

        /*====  =======================
         Next accumulate our usages
          =============================*/
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
        /*==============================================
         Let's prepare for next fetch so we can determine
         if the item, lot, location has changed or not.
         ==============================================*/
        l_prev_item_id  := l_item_id;
        l_prev_lot_id   := l_lot_id;
        l_prev_location := l_location;

        FETCH get_trans INTO
          l_item_id, l_lot_id, l_whse_code,
          l_location, l_doc_type, l_line_type,
          l_reason_code, l_trans_date, l_trans_id,
          l_trans_qty, l_trans_qty2;

      END LOOP;

      CLOSE get_trans;
/* Debugging statements - Bug 3684980 */
 x_cur_time := sysdate;
 FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'		After Updating ic_perd_bal with transaction quantities - '||
	to_char(x_cur_time, 'hh24:mi:ss') );
 x_prev_time := x_cur_time;

 END IF;

      EXCEPTION
         WHEN OTHERS THEN
         FND_MESSAGE.SET_NAME('GMI','IC_CLOSE_GENERAL_ERROR');
         FND_MESSAGE.SET_TOKEN('ERRNO',TO_CHAR(SQLCODE));
         X_msg := FND_MESSAGE.GET;
         FND_FILE.PUT_LINE (FND_FILE.OUTPUT,X_msg);
         X_errmsg := SUBSTR(SQLERRM,1,159);
         FND_FILE.PUT_LINE (FND_FILE.OUTPUT,X_errmsg);
         x_close_err := 1;
         RETURN;

END inventory_close;

END;

/
