--------------------------------------------------------
--  DDL for Package Body GMIUTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMIUTILS" AS
/* $Header: gmiutilb.pls 120.0 2005/05/25 16:00:37 appldev noship $
/* +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    get_doc_no                                                            |
 |                                                                          |
 | USAGE                                                                    |
 |    This will get the doc no from sy_docs_mst and commit the no so that   |
 |    there is no lock on the table.                                        |
 |    It is a AUTONOMOUS_TRANSACTION. will commit before the main           |
 |    transaction completes.                                                |
 |                                                                          |
 | RETURNS                                                                  |
 |    Via x_ OUT parameters                                                 |
 |                                                                          |
 | HISTORY                                                                  |
 |   Created  Jalaj Srivastava/Joe DiIorio                                  |
 |   Sastry 08/27/2003 BUG#3071034                                          |
 |   Added a new function get_inventory_item_id                             |
 |   Sastry 10/29/2003 BUG#3197801                                          |
 |   Modified the function get_inventory_item_id so that inventory_item_id  |
 |   is fetched only once if this function is called for the same item.     |
 |   Teresa Wong 6/7/2004 B3415691 - Enhancement for Serono                 |
 |   Added procedures to set and restore global var for profile		    |
 |   GMI: Allow Negative Inventory.  Added functions to recheck    	    |
 |   negative inventory and lot status. 			            |
 |   Teresa Wong 9/10/04 B3862819 - Modified lot_status_check for OMSO txns.|
 +==========================================================================+
*/
FUNCTION get_doc_no
( x_return_status        OUT NOCOPY       VARCHAR2
, x_msg_count            OUT NOCOPY       NUMBER
, x_msg_data             OUT NOCOPY       VARCHAR2
, p_doc_type  		 IN               sy_docs_seq.doc_type%TYPE
, p_orgn_code 		 IN               sy_docs_seq.orgn_code%TYPE
) RETURN VARCHAR2 IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  l_doc_no              VARCHAR2(10);

BEGIN

  SAVEPOINT get_doc_no;

  x_return_status :=FND_API.G_RET_STS_SUCCESS;

  l_doc_no 	  := GMA_GLOBAL_GRP.Get_doc_no (p_doc_type,p_orgn_code);

  COMMIT;

  return l_doc_no;

  FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK to get_doc_no;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK to get_doc_no;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

  WHEN OTHERS THEN
    ROLLBACK to get_doc_no;
    IF (SQLCODE IS NOT NULL) THEN
      FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_SQL_ERROR');
      FND_MESSAGE.SET_TOKEN('ERRCODE',SQLCODE);
      FND_MESSAGE.SET_TOKEN('ERRM',SQLERRM);
      FND_MSG_PUB.Add;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

END get_doc_no;

-- BEGIN BUG#3071034 Sastry
FUNCTION get_inventory_item_id
( p_item_no  IN varchar2
, p_reset_flag  IN BOOLEAN DEFAULT FALSE
) RETURN NUMBER IS
  CURSOR   get_inventory_item_id IS
    SELECT inventory_item_id
    FROM   mtl_system_items_b
    WHERE  segment1 = P_item_no and
    ROWNUM = 1;
  l_inventory_item_id NUMBER;

BEGIN
  IF P_reset_flag = TRUE THEN
    GMIUTILS.x_inventory_item_id := NULL;
    GMIUTILS.x_item_no := NULL;
  END IF;
  -- BUG#3197801 Sastry
  -- Added the OR condition
  IF GMIUTILS.x_inventory_item_id IS NULL OR GMIUTILS.x_item_no<> p_item_no THEN
    OPEN   get_inventory_item_id;
    FETCH  get_inventory_item_id INTO l_inventory_item_id ;
    CLOSE  get_inventory_item_id;
    GMIUTILS.x_inventory_item_id := l_inventory_item_id;
    GMIUTILS.x_item_no := p_item_no; -- BUG#3197801 Sastry
  END IF;
  RETURN GMIUTILS.x_inventory_item_id;
END get_inventory_item_id;
-- END BUG#3071034

/* +=========================================================================+
 | PROCEDURE NAME                                                          |
 |    Set_allow_neg_inv                                                    |
 |                                                                         |
 | USAGE                                                                   |
 |    Used to set G_allow_neg_inv to 1 (allow)                             |
 |    Can be called from ICCNVED before batch update gme api.              |
 |                                                                         |
 | PARAMETERS                                                              |
 |    None                                                                 |
 |                                                                         |
 | RETURNS                                                                 |
 |    global var updated                                                   |
 |                                                                         |
 | HISTORY                                                                 |
 |    Teresa Wong 6/2/2004 B3415691                                        |
 |                         Enhancement for Serono.                         |
 +=========================================================================+
*/
PROCEDURE set_allow_neg_inv
IS
BEGIN

  G_ALLOW_NEG_INV := 1;

END set_allow_neg_inv;

/* +=========================================================================+
 | PROCEDURE NAME                                                          |
 |    restore_allow_neg_inv                                                |
 |                                                                         |
 | USAGE                                                                   |
 |    Restore global variable G_allow_neg_inv to the profile               |
 |    IC$ALLOWNEGINV.  Can be called from ICCNVED after batch update.      |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    Used to restore global variable G_allow_neg_inv to the profile       |
 |    IC$ALLOWNEGINV.							   |
 |                                                                         |
 | PARAMETERS                                                              |
 |    None                                                                 |
 |                                                                         |
 | RETURNS                                                                 |
 |    global var updated                                                   |
 |                                                                         |
 | HISTORY                                                                 |
 |    Teresa Wong 6/2/2004 B3415691                                        |
 |                         Enhancement for Serono.                         |
 +=========================================================================+
*/
PROCEDURE restore_allow_neg_inv
IS
BEGIN

  G_ALLOW_NEG_INV := NVL(fnd_profile.value('IC$ALLOWNEGINV'), 0);

END restore_allow_neg_inv;

/* +=========================================================================+
 | PROCEDURE NAME                                                          |
 |    neg_inv_check							   |
 |                                                                         |
 | USAGE                                                                   |
 |    Recheck negative inventory balance at the time of save.              |
 |    If transaction causes inventory to go negative in primary or         |
 |    secondary quantity, then report error.				   |
 |                                                                         |
 | PARAMETERS                                                              |
 |    item id, whse code, lot id, location, transaction primary quantity,  |
 |    secondary quantity 						   |
 |                                                                         |
 | RETURNS                                                                 |
 |    True if check passes 						   |
 |    False if check fails						   |
 |    error on message stack if check fails 				   |
 |                                                                         |
 | HISTORY                                                                 |
 |    Teresa Wong 6/7/2004 B3415691                                        |
 |                         Enhancement for Serono.                         |
 +=========================================================================+
*/
FUNCTION neg_inv_check
(
 p_item_id	IN NUMBER,
 p_whse_code	IN VARCHAR2,
 p_lot_id	IN NUMBER,
 p_location	IN VARCHAR2,
 p_qty		IN NUMBER,
 p_qty2		IN NUMBER
)
RETURN BOOLEAN
IS
l_onhand        NUMBER := 0;
l_onhand2       NUMBER := 0;

Cursor get_balance (
v_item_id IN NUMBER,
v_whse IN VARCHAR2,
v_lot_id IN NUMBER,
v_location IN VARCHAR2) IS
SELECT loct_onhand, loct_onhand2
FROM ic_loct_inv
WHERE item_id = v_item_id
AND whse_code = v_whse
AND lot_id = v_lot_id
AND location = v_location;

BEGIN
 IF G_allow_neg_inv = 0 THEN
        OPEN get_balance(
                p_item_id,
                p_whse_code,
                p_lot_id,
                p_location);
        FETCH get_balance into l_onhand, l_onhand2;
        CLOSE get_balance;

	/* If transaction causes inventory to go negative in
 	   either primary or secondary qty, then report error */
        IF ( (l_onhand + p_qty) < 0 OR (l_onhand2 + p_qty2) < 0 )THEN
                FND_MESSAGE.SET_NAME('GMI','IC_INVQTYNEG');
                FND_MSG_PUB.Add;
                RETURN FALSE;
        END IF;
 END IF;

 RETURN TRUE;

 EXCEPTION

        WHEN OTHERS THEN

        FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                                 , 'neg_inv_check');
        RETURN FALSE;

END neg_inv_check;

/* +=========================================================================+
 | PROCEDURE NAME                                                          |
 |    lot_status_check							   |
 |                                                                         |
 | USAGE                                                                   |
 |    Recheck lot status of a transaction at the time of save.             |
 |    1) If the default status and lot status of the transaction are not   |
 |    allowed according to GMI: Move Different Status profile, then report |
 |    error.								   |
 |    2) If the lot status is not valid for the document type of the       |
 |    transaction, then report error.					   |
 |                                                                         |
 | PARAMETERS                                                              |
 |    item id, whse code, lot_id, location, 				   |
 |    document type, qty, and lot status of the transaction    		   |
 |                                                                         |
 | RETURNS                                                                 |
 |    True if check passes						   |
 |    False if check fails						   |
 |    error on message stack if check fails 				   |
 |                                                                         |
 | HISTORY                                                                 |
 |    Teresa Wong 6/1/2004 B3415691                                        |
 |                         Enhancement for Serono.                         |
 |    Teresa Wong 9/3/2004 B3862819					   |
 |			   Modified the check for OMSO doc.		   |
 +=========================================================================+
*/
FUNCTION lot_status_check
(
 p_item_id	IN NUMBER,
 p_whse_code	IN VARCHAR2,
 p_lot_id	IN NUMBER,
 p_location	IN VARCHAR2,
 p_doc_type	IN VARCHAR2,
 p_line_type	IN NUMBER,
 p_trans_qty	IN NUMBER,
 p_lot_status	IN VARCHAR2
)
RETURN BOOLEAN
IS

l_item_mst_rec		ic_item_mst%ROWTYPE;
l_loct_inv_rec		ic_loct_inv%ROWTYPE;
l_lot_no		ic_lots_mst.lot_no%TYPE;
l_sublot_no             ic_lots_mst.sublot_no%TYPE;
l_sts_ctl       	NUMBER;
l_net           	NUMBER;
l_ord           	NUMBER;
l_ship          	NUMBER;
l_prod          	NUMBER;
l_rej           	NUMBER;
l_move_diff_sts		NUMBER(5);
l_valid_move_diff_sts  	BOOLEAN := FALSE;
l_valid_sts_doc     	BOOLEAN := FALSE;

Cursor get_lots_ind (V_lot_sts IN VARCHAR2) IS
SELECT
	nettable_ind, order_proc_ind, shipping_ind, prod_ind, rejected_ind
FROM
	ic_lots_sts
WHERE
	lot_status = V_lot_sts;

Cursor get_lot_no(V_lot_id IN NUMBER) IS
SELECT
	lot_no, sublot_no
FROM
	ic_lots_mst
WHERE
	lot_id = V_lot_id;

BEGIN
 /* fetch item details */
 l_item_mst_rec.item_id := p_item_id;
 IF NOT gmivdbl.ic_item_mst_select (
	p_ic_item_mst_row     => l_item_mst_rec,
	x_ic_item_mst_row     => l_item_mst_rec
 ) THEN
	RETURN FALSE;
 END IF;

 /* item is status controlled, do the checks */
 IF (l_item_mst_rec.status_ctl = 1) THEN
    /* fetch location inventory details */
    gmigutl.get_loct_inv (
	p_item_id		=> p_item_id,
	p_whse_code		=> p_whse_code,
	p_lot_id		=> p_lot_id,
	p_location		=> p_location,
	x_ic_loct_inv_row	=> l_loct_inv_rec
    );

    IF (p_doc_type = 'PROD') AND (p_trans_qty > 0) THEN
	/* begin move diff status check for production */
	l_move_diff_sts := FND_PROFILE.VALUE('IC$MOVEDIFFSTAT');

	/* check default status and lot status to see if they
	   are allowed per GMI: Move Different Status profile */
	IF l_move_diff_sts = 0 THEN
	   IF (l_loct_inv_rec.loct_onhand IS NULL) OR
	      (NVL (p_lot_status, ' ') = NVL (l_loct_inv_rec.lot_status, ' ')) THEN
		l_valid_move_diff_sts := TRUE;
	   END IF;
	ELSIF l_move_diff_sts = 1 THEN
	   l_valid_move_diff_sts := TRUE;
	ELSIF l_move_diff_sts = 2 THEN
	   IF (NVL (l_loct_inv_rec.loct_onhand, 0) = 0) OR
              (NVL (p_lot_status, ' ') = NVL (l_loct_inv_rec.lot_status, ' ')) THEN
	   l_valid_move_diff_sts := TRUE;
	   END IF;
	END IF;

	/* If the lot status is not valid per profile, then
	   report error */
	IF NOT l_valid_move_diff_sts THEN
		OPEN get_lot_no(l_loct_inv_rec.lot_id);
		FETCH get_lot_no INTO l_lot_no,l_sublot_no;
		CLOSE get_lot_no;

        	FND_MESSAGE.SET_NAME('GMI','IC_API_MOVE_STATUS_ERR');
        	FND_MESSAGE.SET_TOKEN('ITEM_NO',l_item_mst_rec.item_no);
        	FND_MESSAGE.SET_TOKEN('LOT_NO',l_lot_no);
        	FND_MESSAGE.SET_TOKEN('SUBLOT_NO',l_sublot_no);
                FND_MSG_PUB.Add;
                RETURN FALSE;
	END IF;
    END IF; /* end of move diff sts check */

    /* check if status is valid for the doc type */
    IF (l_loct_inv_rec.lot_status IS NULL) THEN
	IF (p_doc_type = 'CREI') OR (p_doc_type = 'CRER') THEN
		l_valid_sts_doc := TRUE;
	END IF;
    END IF;

    /* examine item's default lot status if onhand not available */
    IF (l_loct_inv_rec.lot_status IS NULL) THEN
    	OPEN get_lots_ind(p_lot_status);
    ELSE
    	OPEN get_lots_ind(l_loct_inv_rec.lot_status);
    END IF;
    FETCH get_lots_ind into l_net, l_ord, l_ship, l_prod, l_rej;
    IF (get_lots_ind%NOTFOUND) THEN
	CLOSE get_lots_ind;
    ELSE
	CLOSE get_lots_ind;

	IF (p_doc_type = 'PROD') THEN
		IF ( p_line_type IN (1, 2) AND l_rej = 0 ) THEN
			l_valid_sts_doc := TRUE;
		ELSIF ( p_line_type = -1 AND l_prod = 1 AND l_rej = 0 ) THEN
			l_valid_sts_doc := TRUE;
		END IF;
	ELSIF (p_doc_type = 'OMSO') THEN
		-- TKW B3862819 Lot status is valid for line type of
		-- 1 - internal order and 2 - drop ship
		-- irrespective of actual lot status for OMSO txn.
		-- Order flag is not required to be 1 for
		-- line type of 0.

		IF ( p_line_type = 0 AND l_ship = 1 AND l_rej = 0 )
		   OR ( p_line_type > 0) THEN
			l_valid_sts_doc := TRUE;
		END IF;
	ELSE
		l_valid_sts_doc := TRUE;
	END IF;
    END IF;

    /* If the lot status is not valid for the document type
       of the transaction, then report error */
    IF NOT l_valid_sts_doc THEN
	FND_MESSAGE.SET_NAME('GMI','IC_INVLOTSTST');
	FND_MSG_PUB.Add;
	RETURN FALSE;
    END IF;
 END IF;

 RETURN TRUE;

 EXCEPTION

        WHEN OTHERS THEN
        	FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
               		                 , 'Lot_status_check');
	        RETURN FALSE;

END lot_status_check;

END GMIUTILS;

/
