--------------------------------------------------------
--  DDL for Package Body GMI_PURGE_EMPTY_BAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_PURGE_EMPTY_BAL_PKG" AS
/* $Header: GMIPEBLB.pls 120.0 2005/05/25 15:49:20 appldev noship $ */
  PROCEDURE Purge_empty_balance( err_buf      		OUT NOCOPY VARCHAR2,
  	                         ret_code     		OUT NOCOPY VARCHAR2,
  				 p_item_from 		IN  VARCHAR2, 		/* Bug 3377672 Start */
                                 p_item_to  		IN  VARCHAR2,
                                 p_whse_from 		IN  VARCHAR2,
                                 p_whse_to 		IN  VARCHAR2,
                                 p_inv_class 		IN  VARCHAR2,
                                 p_lot_ind     		IN  NUMBER DEFAULT 0,	-- 0-No; 1-Yes
                                 p_purge_precision 	IN  NUMBER DEFAULT 9,
	                         p_criteria_id 		IN  NUMBER DEFAULT 0 	/* Bug 3377672 End */
	                       ) IS

    CURSOR Cur_get_purg_info(l_criteria_id NUMBER) IS
      SELECT *
      FROM  ic_purg_prm
      WHERE criteria_id = l_criteria_id
         AND process_ind = 1
         AND delete_mark = 0;



    l_del_count         NUMBER := 0;
    l_zero_count        NUMBER := 0;
    l_sdate             DATE;
    l_where_clause      VARCHAR2 (500);
    l_where1            VARCHAR2 (500);
    --l_where2            VARCHAR2 (500); --Created the variable. BUG#2552369
    l_loct_onhand       NUMBER;
    l_cursor_id         INTEGER;
    l_dummy             INTEGER;
    l_select_stmt       LONG;
    l_item_no           ic_item_mst.item_no%TYPE;
    l_whse_code         ic_whse_mst.whse_code%type;
    l_location          ic_loct_mst.location%type;
    l_row_id            VARCHAR2(100);
    l_lot_no            ic_lots_mst.lot_no%type;
    l_from_item         ic_item_mst.item_no%type;
    l_to_item           ic_item_mst.item_no%type;
    l_from_whse         ic_whse_mst.whse_code%type;
    l_to_whse           ic_whse_mst.whse_code%type;
    l_inv_class         VARCHAR2(10);
    l_lot_ind           NUMBER;
    l_purg_rec          Cur_get_purg_info%rowtype;
    l_loct_onhand2      NUMBER;
    l_qchold_res_code   VARCHAR2(10);
    l_lot_status        VARCHAR2(10);
    l_default_lot       VARCHAR2(32);
    invalid_arguments   EXCEPTION;
    l_purge_precision      NUMBER;   /* 3377672 Purge Empty Balances Enh -- Added the variable*/

  BEGIN


   /* 3377672 Purge Empty Balances Enh -- Added IF Condition */
   /* Query the ic_purg_prm only if this package is called from the Purge Empty Balances FORM. */

    IF (p_criteria_id > 0) THEN
      OPEN Cur_get_purg_info(p_criteria_id);
      FETCH Cur_get_purg_info INTO l_purg_rec;
      IF (Cur_get_purg_info%NOTFOUND) THEN
        CLOSE Cur_get_purg_info;
        RAISE invalid_arguments;
        RETURN;
      END IF;
      CLOSE Cur_get_purg_info;

    END IF;		      /* 3377672 Purge Empty Balances Enh. Added End If */



    l_default_lot 		:= FND_PROFILE.VALUE('IC$DEFAULT_LOT');

    l_from_item 		:= NVL(l_purg_rec.itemno_from,p_item_from);            /* Bug 3377672 Purge Empty Balances Start */
    l_to_item   		:= NVL(l_purg_rec.itemno_thru,p_item_to);
    l_from_whse 		:= NVL(l_purg_rec.whse_from,p_whse_from);
    l_to_whse   		:= NVL(l_purg_rec.whse_thru,p_whse_to);
    l_inv_class 		:= NVL(l_purg_rec.inv_class,p_inv_class);
    l_lot_ind   		:= NVL(l_purg_rec.lot_ind,NVL(p_lot_ind,0));
    l_purge_precision    	:= NVL(l_purg_rec.purge_precision,p_purge_precision);  /* Bug 3377672 Purge Empty Balances End */


    l_where_clause := ' b.item_id  ';

/*===================================================
   BUG#2935108 - added the following where clauses
  ==================================================*/
    l_where_clause := l_where_clause || ' AND item_no between nvl(:fitm,item_no) and nvl(:titm,item_no)';

    l_where_clause := l_where_clause || ' AND a.whse_code between nvl(:fwh,a.whse_code) and nvl(:twh,a.whse_code)';

    l_where_clause := l_where_clause || ' AND nvl(b.inv_class,'' '')  = nvl(:inclass, nvl(b.inv_class,'' ''))';

    l_where_clause := l_where_clause || ' AND b.lot_ctl = decode(:lotind,1,1,b.lot_ctl)';

    --BEGIN BUG#2552369 V. Ajay Kumar
    --Commented the l_where1 clause below and modified it accordingly.
    --l_where1 := l_where1 || ' AND a.loct_onhand >= 0 AND a.loct_onhand <= .000000001 ';



    /* Dinesh 3377672 - Purge Empty Balances Enh. --  Start
       Depending on the Purge_precision select the rows eligible for purge, instead of hardcoding to 9 decimal precisions
       If loct_onhand quantity is zero or less than the 0.1^purge_precision then it is eligible for purge*/

     -- l_where1 := l_where1 || ' AND (a.loct_onhand = 0 OR abs(a.loct_onhand) <= .000000001)';
        l_where1 := l_where1 || ' AND (a.loct_onhand = 0 OR abs(a.loct_onhand) <= POWER(0.1,:purge_precision))';

    /* Dinesh 3377672 - Purge Empty Balances Enh. -- End */



    --Do not purge the empty balances if the item is used in Inventory Transfers.
    --Bug#3315228 Ramakrishna Commented the l_where2 to purge the empty balances even the item
    --is used in Inventory Transfers.
      /* l_where2 := l_where2 || ' AND NOT EXISTS (SELECT item_id FROM IC_TRAN_PND p '||
                                                ' WHERE doc_type = '||'''XFER''' ||
						' AND a.whse_code = p.whse_code '||
						' AND a.lot_id = p.lot_id '||
                                                ' AND a.location = p.location '||
                                                ' AND a.item_id = p.item_id '||
                                                ' AND p.delete_mark = 0) '; */

    --Add l_where2 to the l_select_stmt.
    --Bug#3315228 Ramakrishna the l_where2 is taken out from the select statement
    l_select_stmt := 'SELECT b.item_no,a.whse_code,a.location, ' ||
                     ' a.loct_onhand,a.rowid, a.loct_onhand2,a.qchold_res_code, ' ||
                     ' a.lot_status,decode(c.lot_no,'||''''||l_default_lot||''''||',NULL,c.lot_no) lot_no ' ||
                     ' FROM ic_loct_inv a,ic_item_mst b,ic_lots_mst c  ' ||
                     ' WHERE a.item_id =  '|| l_where_clause || l_where1
                     ||' and a.lot_id = c.lot_id and b.item_id = c.item_id ';
    --END BUG#2552369

    l_cursor_id := DBMS_SQL.OPEN_CURSOR;

    DBMS_SQL.PARSE(l_cursor_id,l_select_stmt,DBMS_SQL.V7);

    DBMS_SQL.BIND_VARIABLE(l_cursor_id,':fitm',l_from_item);
    DBMS_SQL.BIND_VARIABLE(l_cursor_id,':titm',l_to_item);
    DBMS_SQL.BIND_VARIABLE(l_cursor_id,':fwh',l_from_whse);
    DBMS_SQL.BIND_VARIABLE(l_cursor_id,':twh',l_to_whse);
    DBMS_SQL.BIND_VARIABLE(l_cursor_id,':inclass',l_inv_class);
    DBMS_SQL.BIND_VARIABLE(l_cursor_id,':lotind',l_lot_ind);
    DBMS_SQL.BIND_VARIABLE(l_cursor_id,':purge_precision',l_purge_precision);  /* Dinesh 3377672 - Purge Empty Balances Enh. */

    DBMS_SQL.DEFINE_COLUMN(l_cursor_id,1,l_item_no,32);
    DBMS_SQL.DEFINE_COLUMN(l_cursor_id,2,l_whse_code,4);
    DBMS_SQL.DEFINE_COLUMN(l_cursor_id,3,l_location,32);
    DBMS_SQL.DEFINE_COLUMN(l_cursor_id,4,l_loct_onhand);
    DBMS_SQL.DEFINE_COLUMN(l_cursor_id,5,l_row_id,100);
    DBMS_SQL.DEFINE_COLUMN(l_cursor_id,6,l_loct_onhand2);
    DBMS_SQL.DEFINE_COLUMN(l_cursor_id,7,l_qchold_res_code,10);
    DBMS_SQL.DEFINE_COLUMN(l_cursor_id,8,l_lot_status,10);
    DBMS_SQL.DEFINE_COLUMN(l_cursor_id,9,l_lot_no,32);


    l_dummy :=  DBMS_SQL.EXECUTE(l_cursor_id);


     WHILE (DBMS_SQL.FETCH_ROWS(l_cursor_id) <> 0) LOOP
     BEGIN
       DBMS_SQL.COLUMN_VALUE(l_cursor_id,1,l_item_no);
       DBMS_SQL.COLUMN_VALUE(l_cursor_id,2,l_whse_code);
       DBMS_SQL.COLUMN_VALUE(l_cursor_id,3,l_location);
       DBMS_SQL.COLUMN_VALUE(l_cursor_id,4,l_loct_onhand);
       DBMS_SQL.COLUMN_VALUE(l_cursor_id,5,l_row_id);
       DBMS_SQL.COLUMN_VALUE(l_cursor_id,6,l_loct_onhand2);
       DBMS_SQL.COLUMN_VALUE(l_cursor_id,7,l_qchold_res_code);
       DBMS_SQL.COLUMN_VALUE(l_cursor_id,8,l_lot_status);
       DBMS_SQL.COLUMN_VALUE(l_cursor_id,9,l_lot_no);

       --BEGIN BUG#2552369 V. Ajay Kumar
       --Commented the additional WHERE clause from the DELETE statement.

       DELETE
       FROM  ic_loct_inv
       WHERE rowid             =  l_row_id;
       --AND loct_onhand     >= 0
       --AND loct_onhand     <= .000000001;

       --END BUG#2552369

       IF (SQL%FOUND) THEN
         commit;
         l_del_count := l_del_count + 1;

         IF (l_loct_onhand = 0) THEN
            l_zero_count := l_zero_count + 1;
         END IF;
         FND_MESSAGE.SET_NAME('GMI','GMI_CONC_REQUEST_PURGE_LOG');
         FND_MESSAGE.SET_TOKEN('ITEM_NO',l_item_no);
         FND_MESSAGE.SET_TOKEN('LOT_NO',l_lot_no);
         FND_MESSAGE.SET_TOKEN('WHSE',l_whse_code);
         FND_MESSAGE.SET_TOKEN('LOC',l_location);
         FND_MESSAGE.SET_TOKEN('QTY',to_char(l_loct_onhand));
         FND_FILE.PUT(FND_FILE.LOG,FND_MESSAGE.GET);
         FND_FILE.NEW_LINE(FND_FILE.LOG,1);
       END IF;
     END;
   END LOOP;
   DBMS_SQL.CLOSE_CURSOR(l_cursor_id);

   /******** 3377672 Purge Empty Balances Enhancement - Start *********/
   /* Added IF Condition -- Update the ic_purg_prm only if it is called from Purge Empty Balances Form*/

   IF (p_criteria_id > 0) THEN

     UPDATE ic_purg_prm
     SET   run_date         = sysdate,
           process_ind      = 2,
           deleted_rowcount = l_del_count,
           zero_rowcount    = l_zero_count
     WHERE criteria_id      = p_criteria_id;

     COMMIT;

  END IF ; 			-- Added END IF
  /******** 3377672 Purge Empty Balances Enhancment - End********/

    EXCEPTION
      WHEN invalid_arguments THEN
      	FND_MESSAGE.SET_NAME('GMI','GMI_CONC_REQUEST_INVALID_ARG');
      	FND_MESSAGE.SET_TOKEN('C',to_char(p_criteria_id));
      	FND_FILE.PUT(FND_FILE.LOG,FND_MESSAGE.GET);
        FND_FILE.NEW_LINE(FND_FILE.LOG,1);
      WHEN OTHERS THEN
        FND_FILE.PUT(FND_FILE.LOG,SQLERRM);
        FND_FILE.NEW_LINE(FND_FILE.LOG,1);
        raise;
  END Purge_empty_balance;
END GMI_PURGE_EMPTY_BAL_PKG;

/
