--------------------------------------------------------
--  DDL for Package Body GML_RELEASE_SHIPMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_RELEASE_SHIPMENT_PKG" AS
/* $Header: GMLRLSHB.pls 115.4 2002/11/05 19:01:11 pkanetka noship $ */

 FUNCTION Check_negative_inv(v_bol_id NUMBER) RETURN NUMBER IS
   l_loct_inv t_loct_inv_tbl;
   l_tran_pnd t_loct_inv_tbl;

   CURSOR Cur_get_pending(pbol_id NUMBER) IS
     SELECT Item_id as item_id,
            Whse_code as whse_code,
            Lot_id as lot_id,
            Location as location,
            SUM(-Trans_qty) as qty,
            0 as valid_flag
     FROM   ic_tran_pnd
     WHERE  doc_type = 'OPSO'
           AND delete_mark <> 1
           AND completed_ind <> 1
           AND trans_qty <> 0
           AND line_id in (SELECT line_id
                           FROM   op_ordr_dtl
                           WHERE bol_id = pbol_id)
     GROUP BY item_id,whse_code,lot_id,location
     ORDER BY item_id,whse_code,lot_id,location;

   CURSOR Cur_get_loct_inv(pbol_id NUMBER) IS
     SELECT Item_id as item_id,
            Whse_code as whse_code,
            Lot_id as lot_id,
            Location as location,
            loct_onhand as qty,
            0 as valid_flag
     FROM   ic_loct_inv
     WHERE (item_id, whse_code, lot_id, location) in
            ( SELECT distinct item_id,
                              whse_code,
                              lot_id,
                              location
              FROM  ic_tran_pnd
            WHERE   doc_type = 'OPSO'
                  AND  delete_mark <> 1
                  AND  completed_ind <> 1
                  AND   trans_qty <> 0
                  AND line_id in ( SELECT line_id
                                   FROM   op_ordr_dtl
                                   WHERE bol_id = pbol_id))
     ORDER BY item_id,whse_code,lot_id,location;


/* Begin bug 1994824 - lswamy */
  CURSOR Cur_get_noninv_ind(pitem_id ic_item_mst.item_id%TYPE) IS
    SELECT noninv_ind
      FROM ic_item_mst
     WHERE item_id = pitem_id;
   l_noninv_ind ic_item_mst.noninv_ind%TYPE;
/* End bug 1994824 */

   l_counter     NUMBER DEFAULT 1;
   l_num_trans   NUMBER DEFAULT 0;
   l_num_onhand  NUMBER DEFAULT 0;
   l_loct_exists NUMBER DEFAULT 0;


 BEGIN

   OPEN Cur_get_pending(v_bol_id);
   LOOP
     FETCH Cur_get_pending INTO l_tran_pnd(l_counter);
     EXIT WHEN Cur_get_pending%NOTFOUND;
     l_counter := l_counter + 1;
   END LOOP;
   CLOSE Cur_get_pending;
   l_num_trans := l_tran_pnd.COUNT;

   l_counter := 1;

   OPEN Cur_get_loct_inv(v_bol_id);
   LOOP
     FETCH Cur_get_loct_inv INTO l_loct_inv(l_counter);
     EXIT WHEN Cur_get_loct_inv%NOTFOUND;
     l_counter := l_counter + 1;
   END LOOP;
   CLOSE Cur_get_loct_inv;
   l_num_onhand := l_loct_inv.COUNT;

   /* For Checking Negative Inventory */
   l_counter := 1;

   FOR i IN 1..l_num_trans LOOP
     l_loct_exists := 0;

     OPEN  cur_get_noninv_ind(l_tran_pnd(i).item_id);
     FETCH cur_get_noninv_ind INTO l_noninv_ind;
     CLOSE cur_get_noninv_ind;


     -- For a noninventory item, we set the valid flag to zero
     IF (l_noninv_ind = 1) THEN
       l_tran_pnd(i).valid_flag:= 0;
       l_counter := l_counter + 1;
     ELSE

        -- Loop to see if a record exists in IC_LOCT_INV
        FOR j IN 1..l_num_onhand LOOP
           IF (    (l_tran_pnd(i).item_id   = l_loct_inv(j).item_id)
               AND (l_tran_pnd(i).whse_code = l_loct_inv(j).whse_code)
               AND (l_tran_pnd(i).lot_id    = l_loct_inv(j).lot_id)
               AND (l_tran_pnd(i).location  = l_loct_inv(j).location)) THEN
               l_loct_exists := l_loct_exists + 1;
           END IF;
        END LOOP;

        IF (l_loct_exists = 0) THEN
          l_tran_pnd(i).valid_flag:= 1;
          l_counter := l_counter + 1;
        END IF;

        --  This loop checks if there is sufficient quantity in ic_tran_pnd
        FOR j IN 1..l_num_onhand LOOP
           IF (   (l_tran_pnd(i).item_id   = l_loct_inv(j).item_id)
              AND (l_tran_pnd(i).whse_code = l_loct_inv(j).whse_code)
              AND (l_tran_pnd(i).lot_id    = l_loct_inv(j).lot_id)
              AND (l_tran_pnd(i).location  = l_loct_inv(j).location)
              AND (l_tran_pnd(i).trans_qty > l_loct_inv(j).trans_qty)) THEN
                l_tran_pnd(i).valid_flag:= 1;
                l_counter := l_counter + 1;
           END IF;
        END LOOP;
     END IF; --noninv_ind=0

  END LOOP; -- i Loop ends

  FOR i IN 1..l_tran_pnd.COUNT LOOP
    IF (l_tran_pnd(i).valid_flag = 1) THEN
      RETURN(-1);
    END IF;
  END LOOP;
  RETURN(0);

 END Check_negative_inv;

END GML_RELEASE_SHIPMENT_PKG;

/
