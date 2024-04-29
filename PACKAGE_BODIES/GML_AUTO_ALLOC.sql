--------------------------------------------------------
--  DDL for Package Body GML_AUTO_ALLOC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_AUTO_ALLOC" AS
/*$Header: GMLALLCB.pls 115.6 2002/11/08 15:44:48 gmangari noship $*/

  FUNCTION Get_Available_Lots (V_session_id NUMBER, V_alloc_mode VARCHAR2, V_line_id NUMBER, V_item_id NUMBER, V_shipcust_id NUMBER,
                           V_whse_code VARCHAR2, V_qty NUMBER, V_order_um1 VARCHAR2, V_qty2 NUMBER,
                           V_grade_wanted VARCHAR2, V_sched_shipdate DATE) RETURN NUMBER IS
    CURSOR Cur_get_item_details IS
      SELECT item_no, lot_ctl, loct_ctl, grade_ctl, alloc_class, item_um, item_um2, dualum_ind,
             lot_indivisible
      FROM   ic_item_mst
      WHERE  item_id = V_item_id;
    ItemDetailsRec	Cur_get_item_details%ROWTYPE;

    CURSOR  Cur_get_whse_details IS
      SELECT loct_ctl
      FROM   ic_whse_mst
      WHERE  whse_code = V_whse_code;
    WhseDetailsRec	Cur_get_whse_details%ROWTYPE;
    CURSOR Cur_check_alloc IS
      SELECT 1
      FROM   sys.dual
      WHERE  EXISTS (SELECT 1
                     FROM   ic_tran_pnd
                     WHERE  line_id = V_line_id
                     AND    (lot_id > 0 OR location <> P_default_loct)
                     AND    delete_mark = 0
                     AND    doc_type = 'OPSO'
                     AND    trans_qty <> 0);
    X_exists		NUMBER(5);
    X_plan_qty		NUMBER;
    X_alloc_method      NUMBER(5);
    X_shelf_days	NUMBER(5);
    X_alloc_horizon	NUMBER(5);
    X_alloc_type	NUMBER(5);
    X_lot_qty		NUMBER(5);
    X_partial_ind	NUMBER(5);
    X_prefqc_grade	VARCHAR2(4);
    X_trans_date	DATE;
    X_temp_date		DATE;
    X_return_val	NUMBER(5);
    UOM_CONVERSION_ERROR	EXCEPTION;
    ITEM_NOT_FOUND		EXCEPTION;
    WHSE_NOT_FOUND		EXCEPTION;
    ITEM_WHSE_NOT_LOT_LOCT	EXCEPTION;
    ITEM_ALLOCATION_EXISTS	EXCEPTION;
    INVALID_ALLOCATION_MODE	EXCEPTION;
    ITEM_MISSING_ALLOCATION_CLASS	EXCEPTION;
    X_PROCEED_ALLOC  BOOLEAN DEFAULT TRUE;

  BEGIN
    P_session_id := V_session_id;
    OPEN Cur_get_item_details;
    FETCH Cur_get_item_details INTO ItemDetailsRec;
    IF Cur_get_item_details%NOTFOUND THEN
      CLOSE Cur_get_item_details;
      RAISE ITEM_NOT_FOUND;
    END IF;
    CLOSE Cur_get_item_details;

    OPEN Cur_get_whse_details;
    FETCH Cur_get_whse_details INTO WhseDetailsRec;
    IF Cur_get_whse_details%NOTFOUND THEN
      RAISE WHSE_NOT_FOUND;
    END IF;
    CLOSE Cur_get_whse_details;

    IF ItemDetailsRec.alloc_class IS NULL THEN
      RAISE ITEM_MISSING_ALLOCATION_CLASS;
    ELSIF (ItemDetailsRec.lot_ctl = 0) AND
          (ItemDetailsRec.loct_ctl * WhseDetailsRec.loct_ctl = 0) THEN
      RAISE ITEM_WHSE_NOT_LOT_LOCT;
    END IF;

    P_default_loct := FND_PROFILE.VALUE('IC$DEFAULT_LOCT');

    /* Check to see wether allocations exist */
    OPEN Cur_check_alloc;
    FETCH Cur_check_alloc INTO X_exists;
    IF Cur_check_alloc%FOUND THEN
      CLOSE Cur_check_alloc;
      RAISE ITEM_ALLOCATION_EXISTS;
    END IF;
    CLOSE Cur_check_alloc;

    /* convert to inventory uom  */
    IF (V_order_um1 <> ItemDetailsRec.item_um) THEN
      X_plan_qty := GMICUOM.uom_conversion(V_item_id, 0, V_qty, V_order_um1, ItemDetailsRec.item_um, 0);
      IF X_plan_qty < 0 THEN
        RAISE UOM_CONVERSION_ERROR;
      END IF;
    ELSE
      X_plan_qty := V_qty;
    END IF;

    Get_Alloc_Parameters(V_shipcust_id, ItemDetailsRec.alloc_class, X_alloc_method,
                         X_shelf_days, X_alloc_horizon, X_alloc_type, X_lot_qty,
                         X_partial_ind, X_prefqc_grade);
    IF ItemDetailsRec.grade_ctl > 0 THEN
      IF V_grade_wanted IS NOT NULL THEN
        X_prefqc_grade := V_grade_wanted;
      END IF;
    ELSE
      X_prefqc_grade := NULL;
    END IF;


    X_shelf_days := NVL(X_shelf_days,0);
    X_trans_date := V_sched_shipdate + X_shelf_days;


    X_temp_date := SYSDATE + NVL(X_alloc_horizon,0);

    IF (X_temp_date < V_sched_shipdate) THEN
        X_PROCEED_ALLOC := FALSE;
    END IF;


    /* Check to see wether the allocation class has been defined for auto or user inititated    */
    IF (((X_alloc_type = 1 AND V_alloc_mode = 'auto_all') OR (V_alloc_mode = 'auto_one')) AND
        V_qty > 0) THEN

      IF (X_PROCEED_ALLOC = TRUE) THEN
        X_Return_Val :=  fetch_lots(V_item_id, V_whse_code, X_prefqc_grade,
                                    X_trans_date, X_alloc_type, X_plan_qty, V_qty2,
                                    ItemDetailsRec.lot_ctl, WhseDetailsRec.loct_ctl, ItemDetailsRec.lot_indivisible,
                                    X_lot_qty, V_order_um1, ItemDetailsRec.item_um, ItemDetailsRec.item_um2, ItemDetailsRec.dualum_ind);
        IF X_return_val = 0 THEN
          IF X_partial_ind = 0 THEN
            clear_table;
            X_return_val := -1;
          END IF;
        END IF;
        RETURN  X_return_val;
      ELSE
        RETURN(-3);
      END IF;
    ELSE
      RAISE INVALID_ALLOCATION_MODE;
    END IF;
  EXCEPTION
    WHEN UOM_CONVERSION_ERROR THEN
      FND_MESSAGE.SET_NAME('GMI', 'IC_API_UOM_CONVERSION_ERROR');
      FND_MESSAGE.SET_TOKEN('FROM_UOM', V_order_um1);
      FND_MESSAGE.SET_TOKEN('TO_UOM', ItemDetailsRec.item_um);
      FND_MESSAGE.SET_TOKEN('ITEM_NO',  ItemDetailsRec.item_no);
      FND_MSG_PUB.ADD;
      RETURN(-1);
    WHEN ITEM_NOT_FOUND THEN
      FND_MESSAGE.SET_NAME('GMI', 'IC_API_INVALID_ITEM_NO');
      FND_MESSAGE.SET_TOKEN('ITEM_NO',  V_item_id);
      FND_MSG_PUB.ADD;
      RETURN(-1);
    WHEN WHSE_NOT_FOUND THEN
      FND_MESSAGE.SET_NAME('GMI', 'IC_API_INVALID_WHSE_CODE');
      FND_MESSAGE.SET_TOKEN('WHSE_CODE',  V_whse_code);
      FND_MSG_PUB.ADD;
      RETURN(-1);
    WHEN ITEM_WHSE_NOT_LOT_LOCT THEN
      FND_MESSAGE.SET_NAME('GML', 'OP_NOTLOT_LOCT');
      FND_MSG_PUB.ADD;
      RETURN(-1);
    WHEN ITEM_ALLOCATION_EXISTS THEN
      FND_MESSAGE.SET_NAME('GML', 'OP_SHIPQTYALLOCUSESUMMARY');
      FND_MSG_PUB.ADD;
      RETURN(-1);
    WHEN INVALID_ALLOCATION_MODE THEN
      FND_MESSAGE.SET_NAME('GMI', 'IC_INVALIDMODE');
      FND_MSG_PUB.ADD;
      RETURN(-1);
    WHEN ITEM_MISSING_ALLOCATION_CLASS THEN
      FND_MESSAGE.SET_NAME('GMI', 'IC_INV_ALLOC_CLASS');
      FND_MSG_PUB.ADD;
      RETURN(-1);
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('GMI', 'IC_AS_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR_TEXT',  sqlerrm);
      FND_MESSAGE.SET_TOKEN('PKG_NAME',  'GML_AUTO_ALLOC');
      FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME',  'GET_AVAILABLE_LOTS');
      FND_MSG_PUB.ADD;
      RETURN (-1);
  END Get_Available_Lots;


  PROCEDURE Get_Alloc_Parameters(V_shipcust_id NUMBER, V_alloc_class VARCHAR2, V_alloc_method IN OUT NOCOPY NUMBER,
  				    V_shelf_days IN OUT NOCOPY NUMBER, V_alloc_horizon IN OUT NOCOPY NUMBER,
  				    V_alloc_type IN OUT NOCOPY NUMBER, V_lot_qty IN OUT NOCOPY NUMBER,
  				    V_partial_ind IN OUT NOCOPY NUMBER, V_prefqc_grade IN OUT NOCOPY VARCHAR2) IS
    CURSOR Cur_qry_allocation(V_cust_id NUMBER) IS
      SELECT alloc_method, shelf_days, alloc_horizon,
                       alloc_type, lot_qty, partial_ind, prefqc_grade
      FROM    op_alot_prm
      WHERE   NVL(cust_id,0)  = V_cust_id -- This enables us to open
                                          -- the cursor when V_cust_id is null
      AND     alloc_class  = V_alloc_class
      AND     delete_mark  = 0;

    X_ans        NUMBER;
    X_cust_id  NUMBER;
  BEGIN
    /* try the specific class/cust_id combination first */
    OPEN Cur_qry_allocation(V_shipcust_id);
    FETCH Cur_qry_allocation INTO V_alloc_method,
                                  V_shelf_days,
                                  V_alloc_horizon,
                                  V_alloc_type,
                                  V_lot_qty,
                                  V_partial_ind,
                                  V_prefqc_grade;
    IF(Cur_qry_allocation% NOTFOUND) THEN
      /* try the generic one next */
      CLOSE Cur_qry_allocation;
      OPEN Cur_qry_allocation(0);
      FETCH Cur_qry_allocation INTO V_alloc_method,
                                    V_shelf_days,
                                    V_alloc_horizon,
                                    V_alloc_type,
                                    V_lot_qty,
                                    V_partial_ind,
                                    V_prefqc_grade;
      IF(Cur_qry_allocation% NOTFOUND) THEN
        /* if all else fails use the default values */
        V_alloc_method  := FND_PROFILE.VALUE('IC$ALLOC_METHOD');
        V_shelf_days    := FND_PROFILE.VALUE('IC$SHELF_DAYS');
        V_alloc_horizon := FND_PROFILE.VALUE('IC$ALLOC_HORIZON');
        V_alloc_type    := FND_PROFILE.VALUE('IC$ALLOC_TYPE');
        V_lot_qty       := FND_PROFILE.VALUE('IC$LOT_QTY');
        V_partial_ind   := NVL(FND_PROFILE.VALUE('IC$PARTIAL_IND'), 1);
      END IF;
    END IF;
    IF Cur_qry_allocation%ISOPEN THEN
      CLOSE Cur_qry_allocation;
    END IF;
  END Get_Alloc_Parameters;

  FUNCTION fetch_lots (V_item_id NUMBER, V_whse_code VARCHAR2, V_qc_grade VARCHAR2,
                       V_trans_date DATE, V_alloc_method NUMBER, V_qty NUMBER, V_qty2 NUMBER,
                       V_lot_ctl NUMBER, V_loct_ctl NUMBER, V_lot_indivisible NUMBER, V_lot_alloc NUMBER,
                       V_order_um1 VARCHAR2, V_item_um VARCHAR2, V_item_um2 VARCHAR2, V_dualum_ind NUMBER) RETURN NUMBER IS
    CURSOR Cur_get_lots IS
      SELECT lot_no, sublot_no, lot_id, lot_created ,
             expire_date, qc_grade, location,
             sum(loct_onhand) onhand_qty, sum(loct_onhand2) onhand_qty2,
             sum(commit_qty) commit_qty, sum(commit_qty2) commit_qty2,
             sum(loct_onhand) + sum(commit_qty) avail_qty,
             sum(loct_onhand2) + sum(commit_qty2) avail_qty2,
             sum(alloc_qty) as alloc_qty, sum(alloc_qty2) as alloc_qty2,
             trans_id,count(*) numb_trans_line
      FROM   op_tran_tmp
      WHERE  session_id  = P_session_id
      AND    item_id = V_item_id
      AND    whse_code = V_whse_code
      AND    expire_date > SYSDATE
      GROUP BY  lot_no, sublot_no, lot_id, lot_created,
            trans_id,expire_date, qc_grade, location
      ORDER BY DECODE(V_alloc_method, 0, lot_created, expire_date), qc_grade, DECODE(V_alloc_method, 0, expire_date, lot_created);

    LotDetailsRec	Cur_get_lots%ROWTYPE;
    X_Return_val   	NUMBER :=0;
    X_unalloc_qty  	NUMBER;
    X_unalloc_qty2 	NUMBER;
    X_numb_zero_trans  	NUMBER := 0;
    X_alloc_qty 	NUMBER :=0;
    X_alloc_qty2  	NUMBER :=0;
    X_full_alloc 	NUMBER := 0;
    UOM_CONVERSION_ERROR	EXCEPTION;
  BEGIN
    clear_table;
    insert_temp_rows (V_item_id, V_whse_code, V_qc_grade,
                      V_trans_date);
    OPEN Cur_get_lots;
    clear_table;
    X_unalloc_qty := V_qty;
    X_unalloc_qty2 := V_qty2;
    FETCH Cur_get_lots INTO LotDetailsRec;
    IF Cur_get_lots%FOUND THEN
      WHILE Cur_get_lots%FOUND LOOP
        X_alloc_qty := 0;
        X_alloc_qty2 := 0;
        IF (LotDetailsRec.avail_qty <= 0) AND (LotDetailsRec.alloc_qty = 0) THEN
          NULL;
        ELSE
          /* process lot divisible (lots may be divided) */
          IF (V_lot_indivisible <> 1) THEN
            /* Allow multiple lot allocation */
            IF (V_lot_alloc = 0) THEN
              IF (LotDetailsRec.avail_qty >= X_unalloc_qty) THEN
                X_alloc_qty := X_unalloc_qty;
                X_alloc_qty2:= X_unalloc_qty2;
              ELSE
                X_alloc_qty  := LotDetailsRec.avail_qty;
                X_alloc_qty2:= LotDetailsRec.avail_qty2;
              END IF;
            ELSE
              IF (LotDetailsRec.avail_qty >= X_unalloc_qty) THEN
                X_alloc_qty := X_unalloc_qty;
                X_alloc_qty2:= X_unalloc_qty2;
              END IF;
            END IF;
          /* lot_indivisible item */
          ELSE
            IF (LotDetailsRec.avail_qty <= X_unalloc_qty) THEN
              X_alloc_qty := LotDetailsRec.avail_qty;
              X_alloc_qty2:= LotDetailsRec.avail_qty2;
            END IF;
          END IF;
          IF X_alloc_qty > 0 THEN
            IF (V_dualum_ind = 1) THEN
              X_alloc_qty2 := GMICUOM.uom_conversion(V_item_id, LotDetailsRec.lot_id, X_alloc_qty, V_item_um, V_item_um2, 0);
              IF X_alloc_qty2 < 0 THEN
                RAISE UOM_CONVERSION_ERROR;
              END IF;
            ELSIF V_dualum_ind = 0 THEN
              X_alloc_qty2 := NULL;
            END IF;
            X_unalloc_qty  := X_unalloc_qty - X_alloc_qty;
            X_unalloc_qty2 := X_unalloc_qty2 - X_alloc_qty2;
/* B2064204            IF V_order_um1 <> V_item_um THEN
              X_alloc_qty := GMICUOM.uom_conversion(V_item_id, LotDetailsRec.lot_id, X_alloc_qty, V_item_um, V_order_um1, 0); */
              IF X_alloc_qty < 0 THEN
                RAISE UOM_CONVERSION_ERROR;
              END IF;
/*            END IF; */
            INSERT INTO op_tran_tmp (session_id, doc_id, line_id, item_id, lot_no, sublot_no,
                                     lot_id, lot_created, expire_date, qc_grade, whse_code, location,
                                     alloc_qty, alloc_qty2)
            VALUES                  (P_session_id, 1, 1, V_item_id, LotDetailsRec.lot_no, LotDetailsRec.sublot_no,
                                     LotDetailsRec.lot_id, LotDetailsRec.lot_created, LotDetailsRec.expire_date,
                                     LotDetailsRec.qc_grade, V_whse_code, LotDetailsRec.location,
                                     X_alloc_qty, X_alloc_qty2);
          END IF;
          IF (X_unalloc_qty <= 0) THEN
            X_full_alloc := 1;
            EXIT;
          END IF;
        END IF;
        FETCH Cur_get_lots INTO LotDetailsRec;
        EXIT WHEN Cur_get_lots%NOTFOUND;
      END LOOP;
      RETURN(X_full_alloc);
    END IF;
  EXCEPTION
    WHEN UOM_CONVERSION_ERROR THEN
      FND_MESSAGE.SET_NAME('GMI', 'IC_API_UOM_CONVERSION_ERROR');
      FND_MESSAGE.SET_TOKEN('FROM_UOM', V_item_um);
      FND_MESSAGE.SET_TOKEN('TO_UOM', V_order_um1);
      FND_MESSAGE.SET_TOKEN('ITEM_NO',  V_item_id);
      FND_MSG_PUB.ADD;
      RETURN(-1);
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('GMI', 'IC_AS_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR_TEXT',  sqlerrm);
      FND_MESSAGE.SET_TOKEN('PKG_NAME',  'GML_AUTO_ALLOC');
      FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME',  'FETCH_LOTS');
      FND_MSG_PUB.ADD;
      RETURN (-1);
  END fetch_lots;


  PROCEDURE insert_temp_rows (V_item_id NUMBER, V_whse_code VARCHAR2, V_qc_grade VARCHAR2,
                              V_trans_date DATE) IS
    X_Return_val number := 0;
  BEGIN

  -- Note that shelf days is taken into account by
  -- V_trans_date below.

    INSERT INTO op_tran_tmp
      (session_id,item_id, line_id, doc_id, lot_no, sublot_no,
       lot_id, lot_created, expire_date, qc_grade, whse_code, location,
       loct_onhand, loct_onhand2, commit_qty, commit_qty2, trans_id,
       id_count, alloc_qty, alloc_qty2 )
    SELECT
       P_session_id,l.item_id, -1,  -1, l.lot_no, l.sublot_no,
       l.lot_id, l.lot_created, l.expire_date,
       l.qc_grade, b.whse_code, b.location,
       b.loct_onhand, b.loct_onhand2, 0,
       0, 0, 0, 0, 0
    FROM   ic_lots_mst l, ic_loct_inv b, ic_lots_sts s
    WHERE  l.item_id        = V_item_id
    AND    whse_code        =  V_whse_code
    AND    expire_date      > V_trans_date
    AND    l.inactive_ind   = 0
    AND    b.item_id        = l.item_id
    AND    b.lot_id         = l.lot_id
    AND    (V_qc_grade IS NULL OR l.qc_grade = V_qc_grade)
    AND    s.lot_status     (+) = b.lot_status
    AND   nvl(s.order_proc_ind,1)  = 1
    AND   nvl(s.rejected_ind,0) = 0
    AND    b.loct_onhand    > 0 ;

    INSERT INTO op_tran_tmp
      (session_id,item_id, line_id, doc_id, lot_no, sublot_no,
        lot_id, lot_created, expire_date, qc_grade, whse_code, location,
        loct_onhand, loct_onhand2, commit_qty, commit_qty2, trans_id,
        id_count, alloc_qty, alloc_qty2 )
    SELECT
      P_session_id,t.item_id, -1, -1, l.lot_no, l.sublot_no, t.lot_id, l.lot_created,
      l.expire_date, l.qc_grade, t.whse_code, t.location, 0, 0, t.trans_qty,
      t.trans_qty2, 0, 0, 0, 0
    FROM  ic_item_mst i, ic_lots_mst l, ic_tran_pnd t
    WHERE t.item_id       = V_item_id
    AND   whse_code       = V_whse_code
    AND   expire_date     > V_trans_date
    AND   l.item_id       = t.item_id
    AND   l.inactive_ind  = 0
    AND   t.lot_id        = l.lot_id
    AND   (V_qc_grade IS NULL OR t.qc_grade = V_qc_grade)
    AND   t.delete_mark   = 0
    AND   t.completed_ind = 0
    AND   t.trans_qty     < 0
    AND   (t.lot_id       <> 0 OR (i.lot_ctl = 0 AND i.loct_ctl > 0) )
    AND   l.item_id       = i.item_id;
  END insert_temp_rows;

  PROCEDURE clear_table IS
  BEGIN
    DELETE FROM op_tran_tmp
    WHERE session_id = p_session_id;
  END clear_table;

END GML_AUTO_ALLOC;

/
