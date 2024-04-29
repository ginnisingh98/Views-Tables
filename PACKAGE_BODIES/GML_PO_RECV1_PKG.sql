--------------------------------------------------------
--  DDL for Package Body GML_PO_RECV1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_PO_RECV1_PKG" AS
/* $Header: GMLRECVB.pls 115.9 2002/12/04 19:10:12 gmangari ship $ */


/*========================================================================+
 | PROCEDURE    store_id                                                  |
 |                                                                        |
 | DESCRIPTION  The procedure stores the po id and line id into the       |
 |              package variables, which will be used by sum_recv         |
 |              procedure later.                                          |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 |   20-NOV-97  Kenny    Created.                                         |
 |   23-NOV-99  NC - changed the variable names from v_ to G_             |
 |                                                                        |
 +========================================================================*/

  PROCEDURE store_id(p_po_id IN NUMBER, p_poline_id IN NUMBER) AS
  BEGIN

    G_po_id := p_po_id;
    G_poline_id := p_poline_id;


    IF (G_po_id IS NULL) OR (G_po_id = 0) THEN
       G_stock_ind := 1;
    ELSE
       G_stock_ind := 0;
    END IF;

  END;


 /*=======================================================================+
 | PROCEDURE     get_no                                                   |
 |                                                                        |
 | DESCRIPTION   This procedure obtains the po number and line number     |
 |               from the po id and line id.                              |
 |                                                                        |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 |   20-NOV-97  Kenny  ----  Created.                                     |
 |                                                                        |
 +========================================================================*/

  PROCEDURE get_no(v_po_no OUT NOCOPY VARCHAR2, v_line_no OUT NOCOPY NUMBER)
  AS
    CURSOR po_no_cur IS
    SELECT po_no
    FROM   po_ordr_hdr
    WHERE  po_id = G_po_id;

    CURSOR line_no_cur IS
    SELECT line_no
    FROM   po_ordr_dtl
    WHERE  line_id = G_poline_id;
  BEGIN
    OPEN  po_no_cur;
    FETCH po_no_cur INTO v_po_no;
    CLOSE po_no_cur;
    OPEN  line_no_cur;
    FETCH line_no_cur INTO v_line_no;
    CLOSE line_no_cur;
  END;


/*========================================================================+
 | PROCEDURE   check_mapping                                              |
 |                                                                        |
 |                                                                        |
 | DESCRIPTION  This procedure checks if the particular po line           |
 |              exists in mapping table and if so it's not finally        |
 |              closed and not canceled.                                  |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 |   20-NOV-97  Kenny  ----  Created.                                     |
 |                                                                        |
 +========================================================================*/

  FUNCTION check_mapping
  RETURN BOOLEAN
  IS
    CURSOR status_cur IS
    SELECT po_status
    FROM   cpg_oragems_mapping
    WHERE  po_id   = G_po_id
    AND    line_id = G_poline_id;

    v_status cpg_oragems_mapping.po_status%TYPE;

    err_num         NUMBER;
    err_msg         VARCHAR2(100);

  BEGIN

    OPEN  status_cur;
    FETCH status_cur INTO v_status;
    CLOSE status_cur;

    IF G_stock_ind = 1 THEN
      RETURN TRUE;
    END IF;

    /*cursor not found is taken care of here*/
    IF (v_status IS NULL) OR (v_status IN ('FINALLY CLOSED','CANCELLED')) THEN        /* PO does not exist or canceled or finally closed*/
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;

  EXCEPTION

    WHEN OTHERS THEN
      err_num := SQLCODE;
      err_msg := SUBSTRB(SQLERRM, 1, 100);
      RAISE_APPLICATION_ERROR(-20000, err_msg);

  END check_mapping;


/*========================================================================+
 | PROCEDURE      sum_recv                                                |
 |                                                                        |
 | DESCRIPTION    This procedure calculates the net received quantity     |
 |                and the net returned quantity for a particular PO line  |
 |                and insert into the receiving interface table.          |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 |   20-NOV-97  Kenny  ----  Created.                                     |
 |   26-JAN-99  T.Ricci removed and recv_status <> -1 in where for who    |
 |              column select BUG#795134                                  |
 |   23-NOV-99  NC deleted insert into cpg_receiving_interface.This table |
 |              nolonger exists in 11i.Instead, storing the data in global|
 |	 	vars which will be used later.                            |
 |   29-NOV-99  NC -ve received_qty's being sent to apps side if a receipt|
 |   		is voided after a return is made against it.Changed the   |
 |		received_qty to zero ( instead of a -ve number) in such   |
 |		cases.							  |
 |   04-FEB-2000 PB Bug# 1094230 - a voided return should be excluded form|
 |  		 the total returned quantity. 			          |
 | 		 If the received UOM is different that the Order UOM      |
 | 		 then the necessary conversions need to be made.Same      |
 | 		 applies to returned quantity			     	  |
 +========================================================================*/


  PROCEDURE sum_recv AS
    v_po_no           po_ordr_hdr.po_no%TYPE;
    v_line_no           po_ordr_dtl.line_no%TYPE;
    v_org_id            gl_plcy_mst.org_id%TYPE;
    v_orgn_code         po_ordr_hdr.orgn_code%TYPE;
    v_returned_qty      po_rtrn_dtl.return_qty1%TYPE;
    v_received_qty      po_recv_dtl.recv_qty1%TYPE;
    v_status            po_ordr_dtl.po_status%TYPE;
    v_actual_received_qty  NUMBER;
    v_created_by        po_recv_dtl.created_by%TYPE;
    v_last_updated_by   po_recv_dtl.last_updated_by%TYPE;
    v_last_update_login   po_recv_dtl.last_update_login%TYPE;

    v_order_um1	    VARCHAR2(4);

    x_total_recv_qty	NUMBER := 0 ;
    x_recv_ordr_qty	NUMBER := 0 ;
    x_recv_qty		NUMBER;
    x_recv_um		VARCHAR2(4);
    x_item_id		NUMBER;

    x_total_rtrn_qty	NUMBER := 0 ;
    x_rtrn_ordr_qty	NUMBER := 0 ;
    x_rtrn_qty		NUMBER;
    x_rtrn_um		VARCHAR2(4);



    err_num         NUMBER;
    err_msg         VARCHAR2(100);

    CURSOR po_org_cur(vc_po_id NUMBER) IS
    SELECT po_no, orgn_code
    FROM   po_ordr_hdr
    WHERE  po_id = vc_po_id;

    CURSOR line_no_cur(vc_po_id NUMBER, vc_line_id NUMBER) IS
    SELECT line_no,ORDER_UM1, item_id
    FROM   po_ordr_dtl
    WHERE  po_id = vc_po_id AND
           line_id = vc_line_id;

    CURSOR status_cur(vc_po_id NUMBER, vc_line_id NUMBER) IS
    SELECT po_status
    FROM   po_ordr_dtl
    WHERE  po_id = vc_po_id AND
           line_id = vc_line_id;

    CURSOR org_cur IS
    SELECT g.org_id
    FROM   gl_plcy_mst g, sy_orgn_mst o
    WHERE  o.orgn_code = v_orgn_code
    AND    o.co_code = g.co_code;

/* Added these 2 cursors for Bug# 1094230 */
    CURSOR recv_qty_cur IS
    SELECT NVL(sum(recv_qty1), 0),recv_um1
    FROM   po_recv_dtl
    WHERE  po_id       = G_po_id
    AND    poline_id   = G_poline_id
    AND    recv_status <> -1
    GROUP BY recv_um1;

    CURSOR rtrn_qty_cur IS
    SELECT NVL(SUM(return_qty1), 0),return_um1
    FROM   po_rtrn_dtl dtl , po_rtrn_hdr hdr
    WHERE  dtl.po_id = G_po_id
    AND    dtl.poline_id = G_poline_id
    AND    dtl.return_id = hdr.return_id
    AND    hdr.delete_mark <> 1
    GROUP BY return_um1;


BEGIN


 IF G_stock_ind = 0 THEN
    OPEN   po_org_cur(G_po_id);
    FETCH  po_org_cur   INTO v_po_no, v_orgn_code;
    CLOSE  po_org_cur;

    /* obtain the line_no corresponding to the given po_id and line_id*/
    /* from the po_ordr_dtl table*/

    OPEN   line_no_cur(G_po_id, G_poline_id);
    FETCH  line_no_cur  INTO  v_line_no,v_order_um1,x_item_id;
    CLOSE  line_no_cur;

    OPEN   org_cur;
    FETCH  org_cur INTO v_org_id;
    CLOSE  org_cur;


/*Begin  Bug# 1094230*/
-----------------------------------------------------------------------------
 BEGIN
      OPEN rtrn_qty_cur;
      FETCH	rtrn_qty_cur into x_rtrn_qty,x_rtrn_um;
      LOOP
	 x_rtrn_ordr_qty := 0 ;

         if x_rtrn_um <> v_order_um1
         then
                x_rtrn_ordr_qty := GMICUOM.uom_conversion
		                    	(x_item_id,0,
               				x_rtrn_qty,
                     			x_rtrn_um,
                     			v_order_um1,0);

               if x_rtrn_ordr_qty  < 0
               then
               	   x_rtrn_ordr_qty := x_rtrn_qty;
               end if;

 	else
		x_rtrn_ordr_qty := x_rtrn_qty;
	end if;

		x_total_rtrn_qty := x_total_rtrn_qty + nvl(x_rtrn_ordr_qty,0);


      		FETCH	rtrn_qty_cur into x_rtrn_qty,x_rtrn_um;

		if (rtrn_qty_cur%NOTFOUND)
		then
			exit;
		end if;
	END LOOP;
	CLOSE rtrn_qty_cur;
    END;


    BEGIN
      OPEN recv_qty_cur;
      FETCH	recv_qty_cur into x_recv_qty,x_recv_um;
      LOOP
	 x_recv_ordr_qty := 0 ;

         if x_recv_um <> v_order_um1
         then
                x_recv_ordr_qty := GMICUOM.uom_conversion
		                    	(x_item_id,0,
               				x_recv_qty,
                     			x_recv_um,
                     			v_order_um1,0);

               if x_recv_ordr_qty < 0
               then
               	   x_recv_ordr_qty := x_recv_qty;
               end if;

 	else
		x_recv_ordr_qty := x_recv_qty;
	end if;

		x_total_recv_qty := x_total_recv_qty + nvl(x_recv_ordr_qty,0);


      		FETCH	recv_qty_cur into x_recv_qty,x_recv_um;

		if (recv_qty_cur%NOTFOUND)
		then
			exit;
		end if;
	END LOOP;
	CLOSE recv_qty_cur;
    END;
/*End Bug 1094230 */
----------------------------------------------------------------------------------


/*Bug# 1094230 */
/*
    SELECT NVL(SUM(return_qty1), 0)
    INTO   v_returned_qty
    FROM   po_rtrn_dtl dtl , po_rtrn_hdr hdr
    WHERE  dtl.po_id = G_po_id
    AND    dtl.poline_id = G_poline_id
    AND    dtl.return_id = hdr.return_id;


    SELECT NVL(sum(recv_qty1), 0)
    INTO   v_received_qty
    FROM   po_recv_dtl
    WHERE  po_id       = G_po_id
    AND    poline_id   = G_poline_id
    AND    recv_status <> -1;
*/



    SELECT created_by, last_updated_by, last_update_login
    INTO   v_created_by, v_last_updated_by, v_last_update_login
    FROM   po_recv_dtl
    WHERE  po_id       = G_po_id
    AND    poline_id   = G_poline_id
/*    AND    recv_status <> -1 */
    AND last_update_date = (select max(last_update_date) from po_recv_dtl
    WHERE  po_id       = G_po_id
    AND    poline_id   = G_poline_id);
/*    AND    recv_status <> -1); */

    OPEN   status_cur(G_po_id, G_poline_id);
    FETCH  status_cur  INTO  v_status;
    CLOSE  status_cur;

/*Bug# 1094230 */
    /*v_actual_received_qty := v_received_qty - v_returned_qty;*/
    v_actual_received_qty := x_total_recv_qty - x_total_rtrn_qty;

   /* NC - 29-NOV-99 */
    IF (v_actual_received_qty < 0 ) THEN
       v_actual_received_qty := 0;
    END IF;

    /* NC -copy the data into the global variables. */

    G_po_no := v_po_no;
    G_line_no := v_line_no;
    G_org_id := v_org_id;
    G_po_status := v_status;
    G_actual_received_qty := v_actual_received_qty;
    G_returned_qty := x_total_rtrn_qty;
    G_po_status := v_status;
    G_created_by := v_created_by;

  END IF;

  EXCEPTION

    WHEN OTHERS THEN
      err_num := SQLCODE;
      err_msg := SUBSTRB(SQLERRM, 1, 100);
      RAISE_APPLICATION_ERROR(-20000, err_msg);
  END;

/*========================================================================
|                                                                        |
| PROCEDURE NAME  recv_mv                                                |
|                                                                        |
| DESCRIPTION  Procedure to move records from receiving interface        |
|              table to Oracle base tables                               |.
|                                                                        |
| MODIFICATION HISTORY                                                   |
|                                                                        |
| 10/22/97        Kenny Jiang  created                                   |
| 23-NOV-99  NC - Removed the cursor and all references to cpg_receiving_|
|		  interface table; and changed the code accordingly.     |
| 01-DEC-99  NC - Added the If condition for stock_ind                   |
|                                                                        |
=========================================================================*/

PROCEDURE recv_mv
IS


  v_po_header_id      cpg_oragems_mapping.po_header_id%TYPE;
  v_po_line_id        cpg_oragems_mapping.po_line_id%TYPE;
  v_line_location_id  cpg_oragems_mapping.po_line_location_id%TYPE;
  v_po_release_id     cpg_oragems_mapping.po_release_id%TYPE;

  err_num NUMBER;
  err_msg VARCHAR2(100);

BEGIN

   IF G_stock_ind = 0 THEN
      GML_PO_RECV2_PKG.get_oracle_id(G_po_id,
                    G_poline_id,
                    v_po_header_id,
                    v_po_line_id,
                    v_line_location_id,
                    v_po_release_id  );

      GML_PO_RECV2_PKG.update_line_locations (v_po_header_id,
                             v_po_line_id,
                             v_line_location_id,
                             v_po_release_id,
                             G_org_id,
                             G_po_status,
                             G_actual_received_qty,
                             G_returned_qty,
                             G_created_by,
                             SYSDATE);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    err_num := SQLCODE;
    err_msg := SUBSTRB(SQLERRM, 1, 100);
    RAISE_APPLICATION_ERROR(-20000, err_msg);

END recv_mv;

END GML_PO_RECV1_PKG;

/
