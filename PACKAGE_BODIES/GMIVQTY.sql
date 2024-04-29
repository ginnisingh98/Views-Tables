--------------------------------------------------------
--  DDL for Package Body GMIVQTY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMIVQTY" AS
/* $Header: GMIVQTYB.pls 120.0 2005/05/25 15:57:23 appldev noship $ */
/*  Body start of comments
 +==========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation                  |
 |                          Redwood Shores, CA, USA                         |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILE NAME                                                                |
 |    GMIVQTYB.pls                                                          |
 |                                                                          |
 | PACKAGE NAME                                                             |
 |    GMIVQTY                                                               |
 |                                                                          |
 | DESCRIPTION                                                              |
 |                                                                          |
 | CONTENTS                                                                 |
 |    Validate_Inventory_Posting                                            |
 |                                                                          |
 | HISTORY                                                                  |
 |    25-FEB-1999  M.Godfrey      Upgrade to R11                            |
 |    20/AUG/1999  H.Verdding Bug 951828 Change GMS package Calls to GMA    |
 |    27/OCT/1999  H.Verdding Bug 1042739 added l_qty_rec.orgn_code To      |
 |                            GMA_VALID_GRP.Validate_doc_no                 |
 |    23/May/2000  P.J.Schofield Major rewrite                              |
 |    01/Nov/2001  K.RajaSekhar  Bug 1962677 Code is changed to copy the    |
 |                               journal_comment value in the procedure     |
 |                               Validate_Inventory_Posting.                |
 |    27/Dec/2001  J.DiIorio     Bug#2117575 - 11.5.1I  Changed type 3 move |
 |                               to check to quantity for zero in addition  |
 |                               to check for null.                         |
 |                               Changed validate_inventory_posting.        |
 |    04/15/2002   Venkat Ramana Bug#2317115 Modified the select statement  |
 |                               in the function co_orgn_whse_valid.        |
 |    05/06/2002   Sastry/Ravi   BUG#2354190/2354168 Modified the code in   |
 |                               Procedure Validate_Inventory_Posting.      |
 |    30/Apr/2002  B.Ravishanker Bug#2340824 Modified code in the function  |
 |                               whse_locations_valid and                   |
 |                               Validate_Inventory_Posting procedure to    |
 |                               display the correct error message when the |
 |                               to_location is invalid (Marked for Purged).|
 |   07/02/2002   Jalaj Srivastava Bug 2483656
 |                               Modified to enable creation of journals    |
 |                               through inventory APIs
 |   11/11/2002   Joe DiIorio    Bug 2643440
 |                               11.5.1J - added nocopy.                    |
 |   21/11/2002   Sastry         Bug 2665243 Modified elsif condition       |
 |                               in procedure validate_inventory_posting.   |
 |   09/05/2003   Sastry         BUG 2861715 Modified code in Procedure     |
 |                               Validate_Inventory_Posting.                |
 |   10/09/2003   James Bernard  Bug 3127824 Modified code in               |
 |                               validate_inventory_posting so that user is |
 |                               allowed to move qty from source whse even  |
 |                               when on hand qty is NULL.Also modifed code |
 |                               so that negative qty not allowed message is|
 |                               displayed when onhand qty is going negative|
 |                               for IC$ALLOWNEGINV is zero.                |
 |   09/10/2003  James Bernard   Bug 3171345 Added code to set lot status of|
 |                               source whse to default lot status if the   |
 |                               destination whse also does not have any    |
 |                               lot status. If destination whse has a lot  |
 |                               status then the source whse will have lot  |
 |                               status of the destination whse. This is    |
 |                               is done if the onhand qty in source whse   |
 |                               is NULL while doing TRN transactions.      |
 +==========================================================================+
  Body end of comments
*/
/*  Global variables */
G_PKG_NAME      CONSTANT VARCHAR2(30) := 'GMIVQTY';
l_from_loct_ctl  NUMBER;
l_to_loct_ctl    NUMBER;
/* +=========================================================================+
 | FUNCTION NAME                                                           |
 |    Check_unposted_jnl_lot_status                                        |
 |                                                                         |
 | TYPE                                                                    |
 |    PRIVATE                                                              |
 |                                                                         |
 | USAGE                                                                   |
 |    Used to ascertain if any unposted journals exist for item / lot /    |
 |    sublot / whse_code / location with a different lot status            |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    This procedure checks for unposted journals for item / lot / sublot  |
 |    / whse_code / location with differnet lot status                     |
 |                                                                         |
 | PARAMETERS                                                              |
 |    p_item_id           Surrogate key of item                            |
 |    p_lot_id            Surrogate key of lot                             |
 |    p_whse_code         Warehouse code                                   |
 |    p_location          Location                                         |
 |    p_lot_status        Lot status to be checked for                     |
 |                                                                         |
 | RETURNS                                                                 |
 |    BOOLEAN                                                              |
 |                                                                         |
 | HISTORY                                                                 |
 |    01-OCT-1998      M.Godfrey     Created                               |
 +=========================================================================+
*/
FUNCTION Check_unposted_jnl_lot_status
( p_item_id      IN ic_item_mst.item_id%TYPE
, p_lot_id       IN ic_lots_mst.lot_id%TYPE
, p_whse_code    IN ic_whse_mst.whse_code%TYPE
, p_location     IN ic_loct_mst.location%TYPE
, p_lot_status   IN ic_lots_sts.lot_status%TYPE
)
RETURN BOOLEAN
IS

CURSOR ic_journal IS
SELECT
  count(*)
FROM
  ic_adjs_jnl a, ic_jrnl_mst j
WHERE
  a.item_id    = p_item_id AND
  a.lot_id     = p_lot_id AND
  a.whse_code  = p_whse_code AND
  a.location   = p_location AND
  a.journal_id = j.journal_id AND
  j.posted_ind = 0 AND
  j.delete_mark = 0 AND
  p_lot_status <> a.lot_status;

l_rows_found    NUMBER;

BEGIN

  OPEN ic_journal;

  FETCH ic_journal INTO l_rows_found;

  IF (ic_journal%NOTFOUND)
  THEN
    l_rows_found  :=0;
  END IF;

  CLOSE ic_journal;

  IF l_rows_found > 0
  THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      RAISE;

END Check_unposted_jnl_lot_status;

/* +=========================================================================+
 | FUNCTION NAME                                                           |
 |    Check_unposted_jnl_qc_grade                                          |
 |                                                                         |
 | TYPE                                                                    |
 |    PRIVATE                                                              |
 |                                                                         |
 | USAGE                                                                   |
 |    Used to ascertain if any unposted journals exist for item / lot /    |
 |    sublot / whse_code / location with a different QC grade              |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    This procedure checks for unposted journals for item / lot / sublot  |
 |    / whse_code / location with differnet QC grade                       |
 |                                                                         |
 | PARAMETERS                                                              |
 |    p_item_id           Surrogate key of item                            |
 |    p_lot_id            Surrogate key of lot                             |
 |    p_qc_grade          QC grade to be checked for                       |
 |                                                                         |
 | RETURNS                                                                 |
 |    BOOLEAN                                                              |
 |                                                                         |
 | HISTORY                                                                 |
 |    01-OCT-1998      M.Godfrey     Created                               |
 +=========================================================================+
*/
FUNCTION Check_unposted_jnl_qc_grade
( p_item_id      IN ic_item_mst.item_id%TYPE
, p_lot_id       IN ic_lots_mst.lot_id%TYPE
, p_qc_grade     IN qc_grad_mst.qc_grade%TYPE
)
RETURN BOOLEAN
IS

CURSOR ic_journal IS
SELECT
  count(*)
FROM
  ic_adjs_jnl a, ic_jrnl_mst j
WHERE
  a.item_id    = p_item_id AND
  a.lot_id     = p_lot_id AND
  a.journal_id = j.journal_id AND
  j.posted_ind = 0 AND
  j.delete_mark = 0 AND
  p_qc_grade   <> a.qc_grade;

l_rows_found    NUMBER;

BEGIN

  OPEN ic_journal;

  FETCH ic_journal INTO l_rows_found;

  IF (ic_journal%NOTFOUND)
  THEN
    l_rows_found  :=0;
  END IF;

  CLOSE ic_journal;

  IF l_rows_found > 0
  THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      RAISE;

END Check_unposted_jnl_qc_grade;


FUNCTION co_orgn_valid (p_qty_rec IN GMIGAPI.qty_rec_typ)
RETURN BOOLEAN
IS
  l_count   NUMBER;
BEGIN
  SELECT 1
  INTO   l_count
  FROM   sy_orgn_mst co,
         sy_orgn_mst org
  WHERE  co.orgn_code = p_qty_rec.co_code AND
         co.delete_mark = 0 AND
         org.orgn_code = p_qty_rec.orgn_code AND
         org.co_code = p_qty_rec.co_code AND
         org.delete_mark=0;

  RETURN TRUE;

  EXCEPTION
  WHEN OTHERS
  THEN
    RETURN FALSE;
END;


FUNCTION co_orgn_whse_valid
  (  p_qty_rec      IN  GMIGAPI.qty_rec_typ
   , x_from_loct_ctl OUT NOCOPY NUMBER
   , x_to_loct_ctl   OUT NOCOPY NUMBER
  )
RETURN BOOLEAN
IS
  l_from_whse    ic_whse_mst.whse_code%TYPE;
  l_to_whse      ic_whse_mst.whse_code%TYPE;
BEGIN
  l_from_whse := p_qty_rec.from_whse_code;
  /* **************************************************
     Jalaj Srivastava Bug 2483656
       added trans types 8 for move journal
     ************************************************** */
  IF p_qty_rec.trans_type IN (3,8)
  THEN l_to_whse := p_qty_rec.to_whse_code;
  ELSE l_to_whse := p_qty_rec.from_whse_code;
  END IF;
  -- BEGIN BUG#2317115 Venkata Ramana
  -- No need to check for the delete_mark of company because
  -- the company cannot be deleted without deleting the dependent Organizations.
  SELECT fw.loct_ctl, tw.loct_ctl
  INTO   x_from_loct_ctl, x_to_loct_ctl
  FROM   ic_whse_mst fw,
         ic_whse_mst tw,
         sy_orgn_mst fo,
         sy_orgn_mst toc
  WHERE  fw.whse_code = l_from_whse AND
         tw.whse_code = l_to_whse AND
         fo.orgn_code = fw.orgn_code AND
         toc.orgn_code = tw.orgn_code AND
         fw.delete_mark = 0 AND
         tw.delete_mark = 0 AND
         fo.delete_mark = 0 AND
         toc.delete_mark = 0;
  --END BUG#2317115
  RETURN TRUE;

  EXCEPTION

  WHEN OTHERS
  THEN
    RETURN FALSE;
END;


FUNCTION whse_locations_valid
  (p_qty_rec IN GMIGAPI.qty_rec_typ)
RETURN BOOLEAN
IS
  l_from_whse    ic_whse_mst.whse_code%TYPE;
  l_to_whse      ic_whse_mst.whse_code%TYPE;
  l_to_location  ic_loct_mst.location%TYPE;
  l_from_location ic_loct_mst.location%TYPE;
  l_count        NUMBER;
BEGIN
  l_from_whse := p_qty_rec.from_whse_code;
  l_from_location := p_qty_rec.from_location;

  /* **************************************************
     Jalaj Srivastava Bug 2483656
       added trans types 8,9 for journals
     ************************************************** */
  IF p_qty_rec.trans_type IN (3,4,8,9)
  THEN
    l_to_whse := p_qty_rec.to_whse_code;
    l_to_location := p_qty_rec.to_location;
  ELSE
    l_to_whse := p_qty_rec.from_whse_code;
    l_to_location := p_qty_rec.from_location;
  END IF;

  IF l_from_loct_ctl = 1
  AND l_from_location <> GMIGUTL.IC$DEFAULT_LOCT
  THEN
    SELECT 1
    INTO   l_count
    FROM   ic_loct_mst
    WHERE  whse_code = l_from_whse
    AND    location = l_from_location
    AND    delete_mark = 0;
  END IF;

  IF l_to_loct_ctl = 1
  AND l_to_location <> GMIGUTL.IC$DEFAULT_LOCT
  THEN
    SELECT 1
    INTO   l_count
    FROM   ic_loct_mst
    WHERE  whse_code = l_to_whse
    AND    location = l_to_location
    AND    delete_mark = 0;
  END IF;

  RETURN TRUE;

  EXCEPTION

  WHEN OTHERS
  THEN
    -- BEGIN BUG#2340824 Ravishanker B.
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_LOCATION');
    FND_MESSAGE.SET_TOKEN('ITEM_NO', P_qty_rec.item_no);
    --IF there is some problem in the 1st Select statement
    --the l_count is NULL and control gets into the IF part
    IF l_count IS NULL THEN
      FND_MESSAGE.SET_TOKEN('WHSE_CODE', P_qty_rec.from_whse_code);
      FND_MESSAGE.SET_TOKEN('LOCATION',P_qty_rec.from_location);
    --IF there is some problem in the 2nd Select statement
    --the l_count shall be '1' and control gets into the ELSE part
    ELSE
      FND_MESSAGE.SET_TOKEN('WHSE_CODE', P_qty_rec.to_whse_code);
      FND_MESSAGE.SET_TOKEN('LOCATION',P_qty_rec.to_location);
    END IF;
    FND_MSG_PUB.Add;
    -- END BUG#2340824
    RETURN FALSE;
END;


/* +=========================================================================+
 | PROCEDURE NAME                                                          |
 |    Validate_Inventory_Posting                                           |
 |                                                                         |
 | TYPE                                                                    |
 |    Public                                                               |
 |                                                                         |
 | USAGE                                                                   |
 |    Perform validation functions for inventory quantities posting        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    This procedure performs all the validation functions concerned with  |
 |    inventory quantity postings.                                         |
 |                                                                         |
 | PARAMETERS                                                              |
 |    p_qty_rec      Record datatype containing all inventory posting      |
 |                     data                                                |
 |    x_item_id        Surrogate key of the item                           |
 |    x_lot_id         Surrogate key of the lot                            |
 |    x_old_lot_status Original lot status of item/lot/location            |
 |    x_old_qc_grade   Original QC grade of item/lot                       |
 |    x_trans_rec      Record datatype containing all inventory posting    |
 |                     data                                                |
 |    x_return_status  'S'-success, 'E'-error, 'U'-unexpected error        |
 |    x_msg_count      Count of messages in message list                   |
 |    x_msg_data       Message data                                        |
 |                                                                         |
 | HISTORY                                                                 |
 |    01-OCT-1998      M.Godfrey     Created                               |
 |    16-AUG-1999      H.Verdding    Added Fix For B965832 Part 2          |
 |                                   Prevent Transactions Against          |
 |				      Default Lot.                         |
 |    17-AUG-1999      H.Verdding    Added Fix For B959444                 |
 |                                   Amended Deviation Logic               |
 |                                                                         |
 |    24-APR-2001      A. Mundhe     Bug 1735824 - Validate user name,     |
 |                                   co_code and orgn_code.                |
 |                                                                         |
 |    01/Nov/2001      K.RajaSekhar  Bug 1962677 Code is changed to copy   |
 |                                   the journal_comment value in to the   |
 |                                   out-parameter from the in-parameter   |
 |                                   record.                               |
 |                                                                         |
 |    06-Feb-2002      A. Mundhe     Bug 2206335 - Do not call the uom     |
 |                                   conversion routine if the user is     |
 |                                   trying to zero out the quantity or    |
 |                                   move entire quantity.                 |
 |                                                                         |
 |    18-Feb-2002		  A. Mundhe		 Bug 2206335 - If the user is trying to|
 |                                   zero out the qty then do not run the  |
 |                                   deviation logic as it is already      |
 |                                   accounted for.                        |
 |    06-May-2002      Sastry/Ravi   BUG#2354190/2354168 - Modified code so|
 |                                   that if user sets the profile option  |
 |                                   IC$MOVEDIFFSTAT for different values  |
 |                                   then in all cases API works properly. |
 |    30-Apr-2002      B Ravishanker Bug#2340824 - Changed the code to     |
 |                                   display the correct message when      |
 |                                   to_location is invalid                |
 |                                   (Marked for Purged).                  |
 |   Jalaj Srivastava Bug 2635964                                          |
 |      For status/grade immediate transactions, we need to capture        |
 |      the quantities also for storing in the database. Previously we     |
 |      stored zero for these transactions.                                |
 |   Sastry  Bug 2665343
 |      Modified elsif condition so that the error message cannot post to  |
 |      future date does not occur when a validate trans_date in past is   |
 |      passed.                                                            |
 |                                                                         |
 |   19-Aug-2003     A. Mundhe       Bug 2946031 - Display negative inv    |
 |                                   message correctly when profile        |
 |                                   IC$ALLOWNEGINV is zero and loct_onhand|
 |                                   is null.                              |
 |   Sastry  09/05/2003 BUG#2861715                                        |
 |      Added code to move/adjust the entire Onhand qty2 based on the      |
 |      parameter move_entire_qty when entire primary qty is moved/adjusted|
 |      for dual2 items.                                                   |
 |   10-Sep-2003  James Bernard   Bug 3127824 Modified code so that     |
 |                                   user is allowed to move qty even when |
 |                                   qty at source is NULL. Also modified  |
 |                                   code to display negative inv          |
 |                                   message correctly when profile        |
 |                                   IC$ALLOWNEGINV is zero and loct_onhand|
 |                                   is null.                              |
 |   09-OCT-2003  James Bernard  Bug 3171345 Added code to set lot status  |
 |                               of source whse to default status if the   |
 |                               destination whse also does not have any   |
 |                               lot status. If destination whse has a lot |
 |                               status then the source whse will have lot |
 |                               status of the destination whse. This is   |
 |                               is done if the onhand qty in source whse  |
 |                               is NULL while doing TRN transactions.     |
 |  25-AUG-2004   Supriya Malluru Bug 3711032 Added code to initalize from and to location |
 |                             controls to 0. |
 +=========================================================================+
*/
PROCEDURE Validate_Inventory_Posting
( p_api_version     IN  NUMBER
, p_validation_level IN NUMBER
, p_qty_rec          IN  GMIGAPI.qty_rec_typ
, p_ic_item_mst_row IN  ic_item_mst%ROWTYPE
, p_ic_item_cpg_row IN  ic_item_cpg%ROWTYPE
, p_ic_lots_mst_row IN  ic_lots_mst%ROWTYPE
, p_ic_lots_cpg_row IN  ic_lots_cpg%ROWTYPE
, x_ic_jrnl_mst_row OUT NOCOPY ic_jrnl_mst%ROWTYPE
, x_ic_adjs_jnl_row1 OUT NOCOPY ic_adjs_jnl%ROWTYPE
, x_ic_adjs_jnl_row2 OUT NOCOPY ic_adjs_jnl%ROWTYPE
, x_return_status   OUT NOCOPY VARCHAR2
, x_msg_count       OUT NOCOPY NUMBER
, x_msg_data        OUT NOCOPY VARCHAR2
)
IS
l_qty_rec               GMIGAPI.qty_rec_typ;
l_ic_whse_mst_rec       ic_whse_mst%ROWTYPE;
l_ic_loct_inv_row_from  ic_loct_inv%ROWTYPE;
l_ic_loct_inv_row_to    ic_loct_inv%ROWTYPE;
l_sy_reas_cds_row      sy_reas_cds%ROWTYPE;
l_qc_grad_mst_row      qc_grad_mst%ROWTYPE;
l_ic_lots_sts_row      ic_lots_sts%ROWTYPE;
l_qty2                  NUMBER;
l_onhand                NUMBER;
l_onhand2               NUMBER;
l_trans_type            NUMBER(2);
l_trans_code            VARCHAR2(4);
l_original_qc_grade     VARCHAR2(4);
l_original_lot_status   VARCHAR2(4);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);
l_return_status         VARCHAR2(1);
l_return_val            NUMBER;
l_neg_qty               NUMBER  :=0;
l_bad_location          NUMBER := 0;
-- Bug 1735824
l_user_name            fnd_user.user_name%TYPE;
l_user_id              fnd_user.user_id%TYPE;

-- Bug 2206335
l_check_deviation NUMBER := 1;
l_ccid NUMBER;
l_errmsg VARCHAR2(4000);
l_other_lines_qty  NUMBER := 0;
l_from_whse_co_code VARCHAR2(4);
CURSOR Cur_get_onhand_for_grade IS
  SELECT sum(loct_onhand),sum(loct_onhand2)
  FROM   ic_loct_inv
  WHERE  item_id = p_ic_item_mst_row.item_id
  AND    lot_id  = p_ic_lots_mst_row.lot_id;

--BEGIN BUG#3171345
CURSOR Cur_get_status IS
  SELECT lot_status
  FROM   ic_item_mst
  WHERE  item_id = p_ic_item_mst_row.item_id;
--END BUG#3171345

BEGIN
  /*  Store inputs locally */
  l_qty_rec     := p_qty_rec;
  l_trans_type    := p_qty_rec.trans_type;
  l_user_name  := p_qty_rec.user_name;

   -- Bug 1735824
   -- Validate the user name,co_code and orgn_code.
	GMA_GLOBAL_GRP.Get_who( p_user_name  => l_user_name
                        ,  x_user_id    => l_user_id
                        );

    IF l_user_id = 0
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_USER_NAME');
      FND_MESSAGE.SET_TOKEN('USER_NAME', l_user_name);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

	 IF NOT GMA_VALID_GRP.Validate_co_code(p_qty_rec.co_code)
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_CO_CODE');
      FND_MESSAGE.SET_TOKEN('CO_CODE',p_qty_rec.co_code);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

	 IF NOT GMA_VALID_GRP.Validate_orgn_code(l_qty_rec.orgn_code)
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_ORGN_CODE');
      FND_MESSAGE.SET_TOKEN('ORGN_CODE',p_qty_rec.orgn_code);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  IF l_trans_type BETWEEN 1 AND 10
  THEN
    NULL;
  ELSE
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_TRANS_TYPE');
    FND_MESSAGE.SET_TOKEN('TRANS_TYPE',l_trans_type);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  /*  Check that transaction type is applicable to item. If */
  /*  it's not, complain, otherwise set up a few defaults. */
  IF p_ic_item_mst_row.grade_ctl = 0 AND l_trans_type IN (5,10)
  OR p_ic_item_mst_row.status_ctl = 0 AND l_trans_type IN (4,9)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_INV_TRANS_TYPE_FOR_ITEM');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',l_qty_rec.item_no);
    FND_MESSAGE.SET_TOKEN('TRANS_TYPE', l_trans_type);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    /*  For STSI and GRDI default the uoms. For other types */
    /*  accept what we're given unless they're null, in which */
    /*  case default them. */
    IF (l_trans_type IN (4,5,9,10))
    THEN
      l_qty_rec.item_um   := p_ic_item_mst_row.item_um;
      l_qty_rec.item_um2  := p_ic_item_mst_row.item_um2;
    ELSE
      l_qty_rec.item_um   := nvl(l_qty_rec.item_um, p_ic_item_mst_row.item_um);
      l_qty_rec.item_um2  := nvl(l_qty_rec.item_um2, p_ic_item_mst_row.item_um2);
    END IF;

    IF (l_trans_type < 6)  THEN
       l_qty_rec.journal_ind := 'N';
    ELSE
       l_qty_rec.journal_ind := 'Y';
    END IF;
    IF l_trans_type = 1
    THEN
      l_trans_code := 'CREI';
    END IF;

    IF l_trans_type = 2
    THEN
      l_trans_code := 'ADJI';
    END IF;

    IF l_trans_type = 3
    THEN
      l_trans_code := 'TRNI';
    END IF;

    IF l_trans_type = 4
    THEN
      l_trans_code := 'STSI';
    END IF;

    IF l_trans_type = 5
    THEN
      l_trans_code := 'GRDI';
    END IF;
    IF l_trans_type = 6 THEN
      l_trans_code := 'CRER';
    END IF;
    IF l_trans_type = 7 THEN
      l_trans_code := 'ADJR';
    END IF;
    IF l_trans_type = 8 THEN
      l_trans_code := 'TRNR';
    END IF;
    IF l_trans_type = 9 THEN
      l_trans_code := 'STSR';
    END IF;
    IF l_trans_type = 10 THEN
      l_trans_code := 'GRDR';
    END IF;

    l_qty_rec.txn_type := substr(l_trans_code,1,3);
    IF (l_qty_rec.txn_type = 'CRE')  THEN
      l_qty_rec.lot_status := p_ic_item_mst_row.lot_status;
      l_qty_rec.qc_grade := p_ic_item_mst_row.qc_grade;
    END IF;

    IF (l_qty_rec.txn_type = 'STS')  THEN
      l_qty_rec.to_whse_code := l_qty_rec.from_whse_code;
      l_qty_rec.to_location := l_qty_rec.from_location;
    END IF;

    IF (l_qty_rec.txn_type = 'GRD')  THEN
      l_qty_rec.from_whse_code := NULL;
      l_qty_rec.from_location := NULL;
    END IF;

  END IF;


  /*  All transaction types need an item. Make sure we have  */
  /*  one which can be used  */
  IF p_ic_item_mst_row.item_id = 0
  OR p_ic_item_mst_row.delete_mark = 1
  OR p_ic_item_mst_row.noninv_ind = 1
  OR p_ic_item_mst_row.inactive_ind =1 AND GMIGUTL.IC$API_ALLOW_INACTIVE=0
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_ITEM_NO');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',l_qty_rec.item_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;


  /*  If the item is lot controlled, all transaction types need */
  /*  a lot. If it isn't lot controlled we can ignore whatever */
  /*  we're given and use the default lot. It should also be  */
  /*  borne in mind that sublot control does not necessarilly */
  /*  mean that we should have a sublot number. Also make sure  */
  /*  that attempts to transact against the default lot are */
  /*  blocked. */

  IF p_ic_item_mst_row.lot_ctl > 0
  THEN
    IF NVL(l_qty_rec.lot_no,GMIGUTL.IC$DEFAULT_LOT)=GMIGUTL.IC$DEFAULT_LOT
    OR p_ic_lots_mst_row.delete_mark = 1
    OR p_ic_lots_mst_row.inactive_ind = 1 AND GMIGUTL.IC$API_ALLOW_INACTIVE = 0
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_LOT_NO');
      FND_MESSAGE.SET_TOKEN('ITEM_NO',l_qty_rec.item_no);
      FND_MESSAGE.SET_TOKEN('LOT_NO',l_qty_rec.lot_no);
      FND_MESSAGE.SET_TOKEN('SUBLOT_NO',l_qty_rec.sublot_no);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE
    l_qty_rec.lot_no := GMIGUTL.IC$DEFAULT_LOT;
    l_qty_rec.sublot_no := NULL;
  END IF;


  /*  This next bit is a bit more complicated. For all transaction */
  /*  types the company must own the organisation. For STSI and GRDI */
  /*  transactions, the validation stops there. For CREI, ADJI and */
  /*  TRNI we need to ensure that the warehouse(s) belong to the */
  /*  organisation(s) too. Whilst doing this last check, the loct_*/
  /*  _ctl flags will be retrieved for later use in location */
  /*  validation. If any ownership verification fails we cannot */
  /*  proceed. */
 /*  Initialize from and to location control variables*/

  /* BUG 3711032  */
     l_from_loct_ctl:=0;
     l_to_loct_ctl:=0;

  IF l_trans_type IN (4,5,9,10)
  THEN
    IF co_orgn_valid (l_qty_rec)
    THEN
     NULL;
    ELSE
      FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_ORGN_CODE');
      FND_MESSAGE.SET_TOKEN('ORGN_CODE',l_qty_rec.orgn_code);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE
    IF co_orgn_whse_valid (l_qty_rec, l_from_loct_ctl, l_to_loct_ctl)
    THEN
      NULL;
    ELSE
      FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_ORGN_CODE');
      FND_MESSAGE.SET_TOKEN('ORGN_CODE',l_qty_rec.orgn_code);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;


  /*  Location control: If the item and the warehouse(s) are both */
  /*  location controlled then we must block attempts to transact */
  /*  against the default location. If either of them is not loct */
  /*  controlled then we can only transact against the default. */
  /*  */
  /*  If one of them is location controlled (loct_ctl=1) and the */
  /*  other is non-validated location controlled (loct_ctl=2) then */
  /*  we can accept whatever location is specified. */
  /*   */
  /*  For trans_types of 1,2,4 there will only be 1 warehouse and */
  /*  location. For trans_type=3 (TRNI) there will be 2 warehouse/ */
  /*  location combinations and the combinations should not match. */

  /*  For grade changes we don't care about locations so  */
  /*  even if we're given one, it is flattened. */

  IF l_trans_type IN (5,10)
  THEN
    l_qty_rec.from_location := GMIGUTL.IC$DEFAULT_LOCT;
    l_qty_rec.to_location := GMIGUTL.IC$DEFAULT_LOCT;
  ELSE
    IF NVL(l_qty_rec.from_location,GMIGUTL.IC$DEFAULT_LOCT)=GMIGUTL.IC$DEFAULT_LOCT
    THEN
      l_qty_rec.from_location := GMIGUTL.IC$DEFAULT_LOCT;
    END IF;

    IF NVL(l_qty_rec.to_location,GMIGUTL.IC$DEFAULT_LOCT)=GMIGUTL.IC$DEFAULT_LOCT
    THEN
      l_qty_rec.to_location := GMIGUTL.IC$DEFAULT_LOCT;
    END IF;

    l_bad_location := 0;

    IF p_ic_item_mst_row.loct_ctl > 0
    THEN
      IF l_from_loct_ctl > 0 AND
         l_qty_rec.from_location=GMIGUTL.IC$DEFAULT_LOCT
      OR l_trans_type in (3,4,8,9) AND
         l_to_loct_ctl>0 AND
         l_qty_rec.to_location=GMIGUTL.IC$DEFAULT_LOCT
      OR l_trans_type IN (3,8) AND
         l_qty_rec.from_whse_code=l_qty_rec.to_whse_code AND
         l_qty_rec.from_location=l_qty_rec.to_location
      THEN l_bad_location := 1;
      END IF;

      IF l_bad_location = 1
      THEN
        FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_LOCATION');
        FND_MESSAGE.SET_TOKEN('ITEM_NO', l_qty_rec.item_no);
        FND_MESSAGE.SET_TOKEN('WHSE_CODE', l_qty_rec.from_whse_code);
        FND_MESSAGE.SET_TOKEN('LOCATION',l_qty_rec.from_location);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      -- BEGIN BUG#2340824 Ravishanker B.
      ELSE
      IF whse_locations_valid (l_qty_rec) = FALSE THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      -- END BUG#2340824
      END IF;
    ELSE
      l_qty_rec.from_location := GMIGUTL.IC$DEFAULT_LOCT;
      l_qty_rec.to_location := GMIGUTL.IC$DEFAULT_LOCT;
    END IF;
  END IF;


  /*  If this is a grade change, ensure we have a different qc */
  /*  grade to the current one for the lot. For all other */
  /*  transactions we default it from the lot master. */

  IF (l_trans_type IN (5,10))
  THEN
    IF l_qty_rec.qc_grade <> p_ic_lots_mst_row.qc_grade
    THEN
      IF GMIGUTL.v_qc_grade(l_qty_rec.qc_grade, l_qc_grad_mst_row)
      THEN
        /*  Check for unposted journals with different QC grade */
        IF Check_unposted_jnl_qc_grade
           ( p_item_id          => p_ic_item_mst_row.item_id
           , p_lot_id           => p_ic_lots_mst_row.lot_id
           , p_qc_grade         => l_qty_rec.qc_grade
           )
        THEN
          FND_MESSAGE.SET_NAME('GMI','IC_API_UNPOSTED_JNL_QC_GRADE');
          FND_MESSAGE.SET_TOKEN('QC_GRADE',l_qty_rec.qc_grade);
          FND_MESSAGE.SET_TOKEN('ITEM_NO',l_qty_rec.item_no);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      ELSE
        FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_QC_GRADE');
        FND_MESSAGE.SET_TOKEN('QC_GRADE',l_qty_rec.qc_grade);
        FND_MESSAGE.SET_TOKEN('ITEM_NO',l_qty_rec.item_no);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    ELSE
      FND_MESSAGE.SET_NAME('GMI','IC_API_SAME_QC_GRADE');
      FND_MESSAGE.SET_TOKEN('ITEM_NO',l_qty_rec.item_no);
      FND_MESSAGE.SET_TOKEN('LOT_NO',l_qty_rec.lot_no);
      FND_MESSAGE.SET_TOKEN('SUBLOT_NO',l_qty_rec.sublot_no);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE
    l_qty_rec.qc_grade :=p_ic_lots_mst_row.qc_grade;
  END IF;



  /*  For anything other than grade changes we must ensure that we */
  /*  are not attempting to post into a closed period */

/* Jalaj Srivastava Bug 1427922 13-OCT-2000 */
/* For status and grade txns we do not need trans date validations */
/* BEGIN BUG#1492002 Sastry */
/* Transaction date should be less than sysdate including the timestamp*/
  IF (l_qty_rec.trans_type NOT IN (4,5,9,10))
  THEN
    l_return_val := GMICCAL.trans_date_validate
                      (  l_qty_rec.trans_date
                       , l_qty_rec.orgn_code
                       , l_qty_rec.from_whse_code
                                                 );
    IF l_return_val <> 0
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_CANNOT_POST_CLOSED');
      FND_MESSAGE.SET_TOKEN('ITEM_NO' , l_qty_rec.item_no);
      FND_MESSAGE.SET_TOKEN('TRANS_DATE', l_qty_rec.trans_date);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    -- Bug 2665243 Sastry  removed to_char
    ELSIF l_qty_rec.trans_date > SYSDATE
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_CANNOT_POST_FUTURE');
      FND_MESSAGE.SET_TOKEN('ITEM_NO' , l_qty_rec.item_no);
      FND_MESSAGE.SET_TOKEN('TRANS_DATE', l_qty_rec.trans_date);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;
/* END BUG#1492002 */
  /*  Validate Reason Code. All transaction types need a reason */
  /*  code. If this is a 'Quantity' transaction then the flags */
  /*  on the code must be checked against the quantity given. */
  /*  Note that there is no correlation between document */
  /*  types and reason codes. */

  IF GMIGUTL.v_reason_code
    ( p_reason_code    => l_qty_rec.reason_code
    , x_sy_reas_cds_row=> l_sy_reas_cds_row
    )
  THEN
    IF (l_trans_type IN (1,2,3,6,7,8))
    THEN
      IF l_sy_reas_cds_row.reason_type = 1 AND
         l_qty_rec.trans_qty < 0
      THEN
        FND_MESSAGE.SET_NAME('GMI','IC_API_DEC_NOT_ALLOWED');
        FND_MESSAGE.SET_TOKEN('ITEM_NO',l_qty_rec.item_no);
        FND_MESSAGE.SET_TOKEN('LOT_NO',l_qty_rec.lot_no);
        FND_MESSAGE.SET_TOKEN('SUBLOT_NO',l_qty_rec.sublot_no);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_sy_reas_cds_row.reason_type = 2 AND
	    l_qty_rec.trans_qty > 0
      THEN
        FND_MESSAGE.SET_NAME('GMI','IC_API_INC_NOT_ALLOWED');
        FND_MESSAGE.SET_TOKEN('ITEM_NO',l_qty_rec.item_no);
        FND_MESSAGE.SET_TOKEN('LOT_NO',l_qty_rec.lot_no);
        FND_MESSAGE.SET_TOKEN('SUBLOT_NO',l_qty_rec.sublot_no);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
  ELSE
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_REASON_CODE');
    FND_MESSAGE.SET_TOKEN('REASON_CODE',l_qty_rec.reason_code);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;


  /*  'Quantity' transactions must not have a zero quantity */
  /*  and transfers must be specified positively */

  IF l_trans_type  IN (3,8) AND l_qty_rec.trans_qty <= 0
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_MOVE_QTY_NOT_NEG');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',l_qty_rec.item_no);
    FND_MESSAGE.SET_TOKEN('LOT_NO',l_qty_rec.lot_no);
    FND_MESSAGE.SET_TOKEN('SUBLOT_NO',l_qty_rec.sublot_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    IF l_qty_rec.trans_qty =0
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_ZERO_QTY');
      FND_MESSAGE.SET_TOKEN('ITEM_NO',l_qty_rec.item_no);
      FND_MESSAGE.SET_TOKEN('LOT_NO',l_qty_rec.lot_no);
      FND_MESSAGE.SET_TOKEN('SUBLOT_NO',l_qty_rec.sublot_no);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;


  /*  See if we have any stock balances.  */
  /*  The presence or otherwise of stock drives the validation */
  /*  for lot_status and qc_grade appropriate to the transaction. */

  IF l_trans_type in (1,2,4,6,7,9)
  THEN
    GMIGUTL.get_loct_inv
      (  p_item_id     => p_ic_item_mst_row.item_id
       , p_whse_code   =>l_qty_rec.from_whse_code
       , p_lot_id      =>p_ic_lots_mst_row.lot_id
       , p_location    =>l_qty_rec.from_location
       , x_ic_loct_inv_row =>l_ic_loct_inv_row_from
      );
    /* *************************************************************
       Jalaj Srivastava Bug 2635964
       Need to populate only for status immediate transactions.
       ************************************************************* */
      IF (l_trans_type = 4) THEN
        l_onhand  := l_ic_loct_inv_row_from.loct_onhand;
        l_onhand2 := l_ic_loct_inv_row_from.loct_onhand2;
      END IF;
  ELSIF l_trans_type IN (3,8)
  THEN
    GMIGUTL.get_loct_inv
      (  p_item_id     => p_ic_item_mst_row.item_id
       , p_whse_code   =>l_qty_rec.from_whse_code
       , p_lot_id      =>p_ic_lots_mst_row.lot_id
       , p_location    =>l_qty_rec.from_location
       , x_ic_loct_inv_row =>l_ic_loct_inv_row_from
      );
    GMIGUTL.get_loct_inv
      (  p_item_id     => p_ic_item_mst_row.item_id
       , p_whse_code   =>l_qty_rec.to_whse_code
       , p_lot_id      =>p_ic_lots_mst_row.lot_id
       , p_location    =>l_qty_rec.to_location
       , x_ic_loct_inv_row =>l_ic_loct_inv_row_to
      );
  ELSIF l_trans_type IN (5,10) THEN
    /* *************************************************************
       Jalaj Srivastava Bug 2635964
       For grade transactions, there is no warehouse and location.
       The grade change affects the lot at all warehouse/location.
       To get onhand we need to sum up the onhands at all the
       warehouse/locations where the lot exists.
       Removed the code here which was seleting directly from
       ic_loct_inv using GMIVDBL.ic_loct_inv_select which uses a
       rownum? to restrict rows to 1.
       ************************************************************* */
    OPEN  Cur_get_onhand_for_grade;
    FETCH Cur_get_onhand_for_grade INTO l_onhand,l_onhand2;
    IF (Cur_get_onhand_for_grade%NOTFOUND) THEN
       l_onhand  := NULL;
       l_onhand2 := NULL;
    END IF;
    CLOSE Cur_get_onhand_for_grade;

  END IF;

  /*  Hang onto original status and grade as we'll need them */
  /*  when we set up the output journal rows */

  l_original_qc_grade := p_ic_lots_mst_row.qc_grade;
  l_original_lot_status := l_ic_loct_inv_row_from.lot_status;

  IF l_trans_type IN (1,6)
  THEN
  /*  If inventory create there should be no stock at location. */
    IF l_ic_loct_inv_row_from.loct_onhand IS NOT NULL
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_LOCT_ONHAND_EXISTS');
      FND_MESSAGE.SET_TOKEN('ITEM_NO',l_qty_rec.item_no);
      FND_MESSAGE.SET_TOKEN('LOT_NO',l_qty_rec.lot_no);
      FND_MESSAGE.SET_TOKEN('SUBLOT_NO',l_qty_rec.sublot_no);
      FND_MESSAGE.SET_TOKEN('WHSE_CODE',l_qty_rec.from_whse_code);
      FND_MESSAGE.SET_TOKEN('LOCATION',l_qty_rec.from_location);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      l_qty_rec.lot_status := p_ic_item_mst_row.lot_status;
      l_qty_rec.qc_grade := p_ic_item_mst_row.qc_grade;
    END IF;
  ELSIF l_trans_type IN (2,7)
  THEN
  /*  If adjusting there might or might not be stock */
    IF l_ic_loct_inv_row_from.loct_onhand IS NULL
    THEN
      l_qty_rec.lot_status := p_ic_item_mst_row.lot_status;
      l_qty_rec.qc_grade := p_ic_item_mst_row.qc_grade;
    ELSE
      l_qty_rec.lot_status := l_ic_loct_inv_row_from.lot_status;
      l_qty_rec.qc_grade := p_ic_lots_mst_row.qc_grade;
    END IF;
  ELSIF l_trans_type IN (3,8)
  THEN
  /*  If moving stock then there should be some at the source but */
  /*  not necessarilly at the target. */
    /* BUG#3127824 James Bernard */
    /* Modified code so that user is able to move qty even if source whse has NULL qty */
    /*IF l_ic_loct_inv_row_from.loct_onhand IS NULL
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_NO_LOCT_ONHAND');
      FND_MESSAGE.SET_TOKEN('ITEM_NO',l_qty_rec.item_no);
      FND_MESSAGE.SET_TOKEN('LOT_NO',l_qty_rec.lot_no);
      FND_MESSAGE.SET_TOKEN('SUBLOT_NO',l_qty_rec.sublot_no);
      FND_MESSAGE.SET_TOKEN('WHSE_CODE',l_qty_rec.from_whse_code);
      FND_MESSAGE.SET_TOKEN('LOCATION',l_qty_rec.from_location);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    ELSE*/
      /*==================================================
         27/Dec/2001  J.DiIorio     Bug#2117575 - 11.5.1I
        ================================================*/
      --BEGIN BUG James Bernard3171345
      IF p_ic_item_mst_row.status_ctl = 1 AND l_ic_loct_inv_row_from.lot_status IS NULL THEN
         --Check first if there is any/zero qty in the to whse ie destination whse.
         IF l_ic_loct_inv_row_to.lot_status IS NULL THEN
           OPEN Cur_get_status;
           FETCH Cur_get_status INTO l_ic_loct_inv_row_from.lot_status;
           l_original_lot_status:=l_ic_loct_inv_row_from.lot_status;
           CLOSE Cur_get_status;
         ELSE
           --There is zero/any qty in destination whse ..assign that status to the source as well.
           l_ic_loct_inv_row_from.lot_status:=l_ic_loct_inv_row_to.lot_status;
           l_original_lot_status:=l_ic_loct_inv_row_to.lot_status;
         END IF;
      END IF;
      --END BUG#3171345
      -- BEGIN BUG#2354190/2354168 Sastry/Ravi
      -- Modified the code to handle different cases when profile
      -- option IC$MOVEDIFFSTAT is set to different values.
      IF GMIGUTL.IC$MOVEDIFFSTAT =0 THEN
        IF (l_ic_loct_inv_row_to.loct_onhand IS NULL)
          or (NVL(l_ic_loct_inv_row_from.lot_status,' ') = NVL(l_ic_loct_inv_row_to.lot_status,' ')) THEN
            l_qty_rec.lot_status := l_ic_loct_inv_row_from.lot_status;
 	     ELSE
          FND_MESSAGE.SET_NAME('GMI','IC_API_MOVE_STATUS_ERR');
          FND_MESSAGE.SET_TOKEN('ITEM_NO',l_qty_rec.item_no);
          FND_MESSAGE.SET_TOKEN('LOT_NO',l_qty_rec.lot_no);
          FND_MESSAGE.SET_TOKEN('SUBLOT_NO',l_qty_rec.sublot_no);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      ELSIF GMIGUTL.IC$MOVEDIFFSTAT = 1 THEN
        IF (l_ic_loct_inv_row_to.loct_onhand IS NULL) THEN
          l_qty_rec.lot_status := l_ic_loct_inv_row_FROM.lot_status;
        ELSE
          l_qty_rec.lot_status := l_ic_loct_inv_row_TO.lot_status;
        END IF;
      ELSIF GMIGUTL.IC$MOVEDIFFSTAT =2 THEN
 	     IF (nvl(l_ic_loct_inv_row_to.loct_onhand,0) = 0)
	         or (NVL(l_ic_loct_inv_row_from.lot_status,' ') = NVL(l_ic_loct_inv_row_to.lot_status,' ')) THEN
    	        l_qty_rec.lot_status := l_ic_loct_inv_row_from.lot_status;
 	     ELSE
 	       FND_MESSAGE.SET_NAME('GMI','IC_API_MOVE_STATUS_ERR');
          FND_MESSAGE.SET_TOKEN('ITEM_NO',l_qty_rec.item_no);
          FND_MESSAGE.SET_TOKEN('LOT_NO',l_qty_rec.lot_no);
          FND_MESSAGE.SET_TOKEN('SUBLOT_NO',l_qty_rec.sublot_no);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
    -- END IF; BUG#3127824 James Bernard
    -- END BUG#2354190/2354168
  ELSIF l_trans_type IN (4,9)
  THEN
    IF l_ic_loct_inv_row_from.loct_onhand IS NULL
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_NO_LOCT_ONHAND');
      FND_MESSAGE.SET_TOKEN('ITEM_NO',l_qty_rec.item_no);
      FND_MESSAGE.SET_TOKEN('LOT_NO',l_qty_rec.lot_no);
      FND_MESSAGE.SET_TOKEN('SUBLOT_NO',l_qty_rec.sublot_no);
      FND_MESSAGE.SET_TOKEN('WHSE_CODE',l_qty_rec.from_whse_code);
      FND_MESSAGE.SET_TOKEN('LOCATION',l_qty_rec.from_location);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_qty_rec.lot_status = l_ic_loct_inv_row_from.lot_status
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_SAME_LOT_STATUS');
      FND_MESSAGE.SET_TOKEN('ITEM_NO',l_qty_rec.item_no);
      FND_MESSAGE.SET_TOKEN('LOT_NO',l_qty_rec.lot_no);
      FND_MESSAGE.SET_TOKEN('SUBLOT_NO',l_qty_rec.sublot_no);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_qty_rec.lot_status = p_ic_item_mst_row.lot_status
    THEN
      NULL;
    ELSE
      IF GMIGUTL.v_lot_status (l_qty_rec.lot_status, l_ic_lots_sts_row)
      THEN
        NULL;
      ELSE
        FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_LOT_STATUS');
        FND_MESSAGE.SET_TOKEN('LOT_STATUS',l_qty_rec.lot_status);
        FND_MESSAGE.SET_TOKEN('ITEM_NO',l_qty_rec.item_no);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END If;
    /*  Check for unposted journals with different lot status */
    IF Check_unposted_jnl_lot_status
       ( p_item_id          => p_ic_item_mst_row.item_id
       , p_lot_id           => p_ic_lots_mst_row.lot_id
       , p_whse_code        => l_qty_rec.from_whse_code
       , p_location         => l_qty_rec.from_location
       , p_lot_status       => l_qty_rec.lot_status
       )
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_UNPOSTED_JNL_LOT_STATUS');
      FND_MESSAGE.SET_TOKEN('LOT_STATUS',l_qty_rec.lot_status);
      FND_MESSAGE.SET_TOKEN('ITEM_NO',l_qty_rec.item_no);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE
    /*  For grade changes there should be a non-zero balance */
    IF NVL(l_onhand,0) = 0
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_NO_LOT_ONHAND');
      FND_MESSAGE.SET_TOKEN('ITEM_NO',l_qty_rec.item_no);
      FND_MESSAGE.SET_TOKEN('LOT_NO',l_qty_rec.lot_no);
      FND_MESSAGE.SET_TOKEN('SUBLOT_NO',l_qty_rec.sublot_no);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;


  /*  Before embarking on major number crunching, validate the */
  /*  primary uom of the quantity passed in. */
  IF l_qty_rec.item_um <> p_ic_item_mst_row.item_um
  THEN
    IF NOT GMA_VALID_GRP.Validate_um(l_qty_rec.item_um)
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_UOM');
      FND_MESSAGE.SET_TOKEN('ITEM_NO',l_qty_rec.item_no);
      FND_MESSAGE.SET_TOKEN('UOM',l_qty_rec.item_um);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;



  /*  FROM HERE ON, NOTHING HAS CHANGED -- */

  /*  Handle Quantities */
  /*  If primary Uom differs from item primary UoM then convert */
  /*  transaction quantity */
  IF (l_qty_rec.item_um <> p_ic_item_mst_row.item_um) OR
     (l_qty_rec.item_um IS NULL)
  THEN
    /*  If quantity to convert is negative then make positive for conversion */
    IF l_qty_rec.trans_qty < 0
    THEN
      l_neg_qty  := 1;
      l_qty_rec.trans_qty  := 0 - l_qty_rec.trans_qty;
    END IF;
    l_qty_rec.trans_qty :=GMICUOM.uom_conversion
                          ( pitem_id    =>p_ic_item_mst_row.item_id
                          , plot_id     =>p_ic_lots_mst_row.lot_id
                          , pcur_qty    =>l_qty_rec.trans_qty
                          , pcur_uom    =>l_qty_rec.item_um
                          , pnew_uom    =>p_ic_item_mst_row.item_um
                          , patomic     =>0
                          );
    /*  Negative quantity indicates UoM conversion failure */
    IF (l_qty_rec.trans_qty < 0)
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_UOM_CONVERSION_ERROR');
      FND_MESSAGE.SET_TOKEN('ITEM_NO',l_qty_rec.item_no);
      FND_MESSAGE.SET_TOKEN('FROM_UOM',l_qty_rec.item_um);
      FND_MESSAGE.SET_TOKEN('TO_UOM',p_ic_item_mst_row.item_um);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      l_qty_rec.item_um  :=p_ic_item_mst_row.item_um;
      /*  Reverse quantity sign if reversed above */
      IF l_neg_qty = 1
      THEN
        l_neg_qty  := 0;
        l_qty_rec.trans_qty  := 0 - l_qty_rec.trans_qty;

      END IF;
    END IF;
  END IF;

  /*  If dual unit of measure then convert to item secondary unit of measure */
  IF (p_ic_item_mst_row.dualum_ind > 0)
  THEN
    /* Bug 2206335 */
    /* Do not call the uom conversion routine if the user is trying to
       zero out the quantity or move entire quantity */
    IF ( (l_trans_type IN (2,7)) AND
         (l_qty_rec.trans_qty + l_ic_loct_inv_row_from.loct_onhand) = 0 )
    THEN
      -- BEGIN BUG#2861715 Sastry
      IF (p_ic_item_mst_row.dualum_ind = 2) THEN
        IF (UPPER(l_qty_rec.move_entire_qty) = 'Y') THEN
          l_qty2 := l_ic_loct_inv_row_from.loct_onhand2 * -1;
          l_qty_rec.trans_qty2  :=l_qty2;
          l_check_deviation := 0;
        ELSE
          l_qty2 := GMICUOM.uom_conversion
                    ( pitem_id    =>p_ic_item_mst_row.item_id
                    , plot_id     =>p_ic_lots_mst_row.lot_id
                    , pcur_qty    =>l_qty_rec.trans_qty
                    , pcur_uom    =>p_ic_item_mst_row.item_um
                    , pnew_uom    =>p_ic_item_mst_row.item_um2
                    , patomic     =>0
                    );
          l_check_deviation := 1;
        END IF;
      ELSE
        l_qty2 := l_ic_loct_inv_row_from.loct_onhand2 * -1;
        l_qty_rec.trans_qty2  :=l_qty2;
        l_check_deviation := 0;
      END IF;
      -- END BUG#2861715
    ELSIF( (l_trans_type IN (3,8)) AND
         (l_qty_rec.trans_qty - l_ic_loct_inv_row_from.loct_onhand) = 0 )
    THEN
      -- BEGIN BUG#2861715 Sastry
      -- Added code to move the entire Onhand qty2 based on the newly added parameter
      IF (p_ic_item_mst_row.dualum_ind = 2) THEN
        IF (UPPER(l_qty_rec.move_entire_qty) = 'Y') THEN
          l_qty2 := l_ic_loct_inv_row_from.loct_onhand2;
          l_qty_rec.trans_qty2  :=l_qty2;
          l_check_deviation := 0;
        ELSE
          l_qty2 := GMICUOM.uom_conversion
                    ( pitem_id    =>p_ic_item_mst_row.item_id
                    , plot_id     =>p_ic_lots_mst_row.lot_id
                    , pcur_qty    =>l_qty_rec.trans_qty
                    , pcur_uom    =>p_ic_item_mst_row.item_um
                    , pnew_uom    =>p_ic_item_mst_row.item_um2
                    , patomic     =>0
                    );
          l_check_deviation := 1;
        END IF;
      ELSE
        l_qty2 := l_ic_loct_inv_row_from.loct_onhand2;
        l_qty_rec.trans_qty2  :=l_qty2;
        l_check_deviation := 0;
      END IF;
      -- END BUG#2861715
    ELSE
    	/*  If quantity to convert is negative then make positive for conversion */
    	IF l_qty_rec.trans_qty < 0
    	THEN
      	l_neg_qty  := 1;
      	l_qty_rec.trans_qty  := 0 - l_qty_rec.trans_qty;
    	END IF;
    	l_qty2 :=GMICUOM.uom_conversion
     		      ( pitem_id    =>p_ic_item_mst_row.item_id
        		   , plot_id     =>p_ic_lots_mst_row.lot_id
           		, pcur_qty    =>l_qty_rec.trans_qty
           		, pcur_uom    =>p_ic_item_mst_row.item_um
           		, pnew_uom    =>p_ic_item_mst_row.item_um2
           		, patomic     =>0
           		);
    	/*  Negative quantity indicates UoM conversion failure */
    	IF (l_qty2 < 0)
    	THEN
      	FND_MESSAGE.SET_NAME('GMI','IC_API_UOM_CONVERSION_ERROR');
      	FND_MESSAGE.SET_TOKEN('ITEM_NO',l_qty_rec.item_no);
      	FND_MESSAGE.SET_TOKEN('FROM_UOM',p_ic_item_mst_row.item_um);
      	FND_MESSAGE.SET_TOKEN('TO_UOM',p_ic_item_mst_row.item_um2);
      	FND_MSG_PUB.Add;
      	RAISE FND_API.G_EXC_ERROR;
    	END IF;
    	/*  Reverse quantity sign if reversed above */
    	IF l_neg_qty = 1
    	THEN
      	l_neg_qty  := 0;
      	l_qty_rec.trans_qty  := 0 - l_qty_rec.trans_qty;
      	l_qty2         		:= 0 - l_qty2;
    	END IF;
  	END IF; /* 2206335 */

    /*  If fixed conversion then converted value is secondary qty */
    IF (p_ic_item_mst_row.dualum_ind = 1) OR
       (p_ic_item_mst_row.dualum_ind = 2 AND l_qty_rec.trans_qty2 = 0)
    THEN
      l_qty_rec.trans_qty2  :=l_qty2;
      l_qty_rec.item_um2    :=p_ic_item_mst_row.item_um2;
    ELSE
    /*  If secondary Uom differs from item secondary UoM then convert */
    /*  transaction quantity */
      IF (l_qty_rec.item_um2 <> p_ic_item_mst_row.item_um2)

      THEN
        /*  If quantity to convert is negative then make positive for conversion */
        IF l_qty_rec.trans_qty < 0
        THEN
          l_neg_qty  := 1;
          l_qty_rec.trans_qty2  := 0 - l_qty_rec.trans_qty2;
        END IF;
        l_qty_rec.trans_qty2 :=GMICUOM.uom_conversion
                               ( pitem_id    =>p_ic_item_mst_row.item_id
                               , plot_id     =>p_ic_lots_mst_row.lot_id
                               , pcur_qty    =>l_qty_rec.trans_qty2
                               , pcur_uom    =>l_qty_rec.item_um2
                               , pnew_uom    =>p_ic_item_mst_row.item_um2
                               , patomic     =>0
                               );
        /*  Negative quantity indicates UoM conversion failure */
        IF (l_qty_rec.trans_qty2 < 0)
        THEN
          FND_MESSAGE.SET_NAME('GMI','IC_API_UOM_CONVERSION_ERROR');
          FND_MESSAGE.SET_TOKEN('ITEM_NO',l_qty_rec.item_no);
          FND_MESSAGE.SET_TOKEN('FROM_UOM',l_qty_rec.item_um2);
          FND_MESSAGE.SET_TOKEN('TO_UOM',p_ic_item_mst_row.item_um2);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          l_qty_rec.item_um2  :=p_ic_item_mst_row.item_um2;
          /*  Reverse quantity sign if reversed above */
          IF l_neg_qty = 1
          THEN
            l_neg_qty  := 0;
            l_qty_rec.trans_qty2  := 0 - l_qty_rec.trans_qty2;
          END IF;
        END IF;
--Jalaj Srivastava Bug 1554040
      ELSE
           IF (l_qty_rec.trans_qty2 IS NULL) THEN
               l_qty_rec.trans_qty2  :=l_qty2;
           END IF;
      END IF;

      /*  Check deviation */
      /*  H.Verdding B959444 Amended Deviation Logic */

      -- Bug 2206335
      -- If the user is trying to zero out the qty then do not
      -- run the deviation logic as it is already accounted for.
      IF (l_check_deviation <> 0) THEN
      	IF (ABS(l_qty_rec.trans_qty2) >
	  			 ABS(l_qty2) * (1 + p_ic_item_mst_row.deviation_hi)) OR
             (ABS(l_qty_rec.trans_qty2) <
	          ABS(l_qty2) * (1 - p_ic_item_mst_row.deviation_lo))
          THEN
            FND_MESSAGE.SET_NAME('GMI','IC_API_QTY_TOLERANCE_ERROR');
            FND_MESSAGE.SET_TOKEN('ITEM_NO',l_qty_rec.item_no);
            FND_MESSAGE.SET_TOKEN('LOT_NO',l_qty_rec.lot_no);
            FND_MESSAGE.SET_TOKEN('SUBLOT_NO',l_qty_rec.sublot_no);
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
      END IF;
    END IF;
  ELSE
/* LE fix */
  l_qty_rec.item_um2    := NULL;
  l_qty_rec.trans_qty2  := NULL;
  END IF;
  /*  Check location inventory for becoming negative */
  IF (GMIGUTL.IC$ALLOWNEGINV = '0') THEN
  /* ******************************************************
     For ADJR/TRNR transactions check for other lines also
     ****************************************************** */
     IF (      (l_trans_type IN (7,8))
	   AND (    (l_qty_rec.journal_no IS NOT NULL)
                 OR (      (upper(l_qty_rec.journal_no) = 'PREVIOUS')
	              AND  (l_qty_rec.orgn_code = GMIGAPI.prev_orgn_code)
                    )
               )
        ) THEN

       SELECT nvl(sum(a.qty),0)
       INTO   l_other_lines_qty
       FROM   ic_jrnl_mst j, ic_adjs_jnl a
       WHERE  j.orgn_code    = l_qty_rec.orgn_code
       AND    j.journal_no   = nvl(l_qty_rec.journal_no,GMIGAPI.prev_journal_no)
       AND    a.journal_id   = j.journal_id
       AND    a.line_type   <> -1
       AND    a.item_id      = p_ic_item_mst_row.item_id
       AND    a.lot_id       = nvl(p_ic_lots_mst_row.lot_id,0)
       AND    a.whse_code    = l_qty_rec.from_whse_code
       AND    a.location     = nvl(l_qty_rec.from_location,GMIGUTL.IC$DEFAULT_LOCT);
     END IF;-- (      (l_trans_type IN (7,8))
    -- Bug 2946031
    -- Display negative qty not allowed message correctly if
    -- l_ic_loct_inv_row_from.loct_onhand is null.
    -- Bug 3127824 Added nvl function to l_ic_loct_inv_row_from.loct_onhand so that negative qty not
    -- allowed message is displayed properly when doing move immediate / Journal.
    IF (    (     (l_trans_type IN (1,2,6,7))
	      AND ((nvl(l_ic_loct_inv_row_from.loct_onhand,0) + l_qty_rec.trans_qty + l_other_lines_qty) < 0)
	    )
	 OR
            (     (l_trans_type IN (3,8))
	      AND ((nvl(l_ic_loct_inv_row_from.loct_onhand,0) - l_qty_rec.trans_qty - l_other_lines_qty) < 0)
            )
       ) THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_NEG_QTY_NOT_ALLOWED');
      FND_MESSAGE.SET_TOKEN('ITEM_NO',l_qty_rec.item_no);
      FND_MESSAGE.SET_TOKEN('LOT_NO',l_qty_rec.lot_no);
      FND_MESSAGE.SET_TOKEN('SUBLOT_NO',l_qty_rec.sublot_no);
      FND_MESSAGE.SET_TOKEN('WHSE_CODE',l_qty_rec.from_whse_code);
      FND_MESSAGE.SET_TOKEN('LOCATION',l_qty_rec.from_location);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  /*  Check move quantity if item is lot-indivisble */
  IF (p_ic_item_mst_row.lot_indivisible = 1) AND
     (l_trans_type IN (3,8)) AND
     (l_ic_loct_inv_row_from.loct_onhand <> l_qty_rec.trans_qty)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_LOT_INDIVISIBLE');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',l_qty_rec.item_no);
    FND_MESSAGE.SET_TOKEN('LOT_NO',l_qty_rec.lot_no);
    FND_MESSAGE.SET_TOKEN('SUBLOT_NO',l_qty_rec.sublot_no);
    FND_MESSAGE.SET_TOKEN('WHSE_CODE',l_qty_rec.from_whse_code);
    FND_MESSAGE.SET_TOKEN('LOCATION',l_qty_rec.from_location);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  IF (l_qty_rec.txn_type IN ('GRD','STS','TRN')) THEN
      x_ic_adjs_jnl_row1.acctg_unit_id   := NULL;
      x_ic_adjs_jnl_row1.acct_id         := NULL;
      x_ic_adjs_jnl_row2.acctg_unit_id   := NULL;
      x_ic_adjs_jnl_row2.acct_id         := NULL;
  END IF;
  /* *********************************************************
     Jalaj Srivastava Bug 2483656
     Charge accounts are only available from 11i family pack
     I onwards and for Create/Adjust only.
     ********************************************************* */
  IF (     (l_qty_rec.txn_type IN ('CRE','ADJ'))
       AND (GMIPVER.get_opm_11i_family_pack >= 9)
     )  THEN
     IF (     (l_qty_rec.acctg_unit_no IS NULL)
	  AND (l_qty_rec.acct_no IS NULL)
        ) THEN
            x_ic_adjs_jnl_row1.acctg_unit_id   := NULL;
	    x_ic_adjs_jnl_row1.acct_id         := NULL;
     ELSIF (     (l_qty_rec.acctg_unit_no IS NULL)
	      OR (l_qty_rec.acct_no IS NULL)
           ) THEN
     	       FND_MESSAGE.SET_NAME('GMI','GMI_API_CHARGE_ACCT');
               FND_MSG_PUB.Add;
	       RAISE FND_API.G_EXC_ERROR;
     ELSE
	   /* *********************************************************
	      Jalaj Srivastava
	      charge accounts are tied to the company of the warehouse
	      ********************************************************** */
	   SELECT co_code INTO l_from_whse_co_code
	   FROM   sy_orgn_mst
	   WHERE  orgn_code = (SELECT orgn_code
			       FROM   ic_whse_mst
			       WHERE  whse_code = l_qty_rec.from_whse_code);
	   gmf_validate_account.get_accu_acct_ids
	     ( p_co_code => l_from_whse_co_code
	      ,p_acctg_unit_no => l_qty_rec.acctg_unit_no
	      ,p_acct_no => l_qty_rec.acct_no
	      ,p_create_acct => 'Y'
	      ,x_acctg_unit_id => x_ic_adjs_jnl_row1.acctg_unit_id
	      ,x_acct_id => x_ic_adjs_jnl_row1.acct_id
	      ,x_ccid => l_ccid
	      ,x_status => l_return_status
	      ,x_errmsg => l_errmsg
             );
	     IF (x_ic_adjs_jnl_row1.acctg_unit_id = -1) THEN
		    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,substrb(l_errmsg,1,240));
                    FND_MSG_PUB.Add;
		    RAISE FND_API.G_EXC_ERROR;
             END IF;
     END IF;
  END IF; --IF (l_qty_rec.txn_type IN ('CRE','ADJ')) THEN


  /*  If we've reached this far then all is OK. Create the journalling */
  /*  rows ready to pass back to the calling API. */

  x_ic_jrnl_mst_row.journal_id    := NULL;
  x_ic_jrnl_mst_row.journal_no    := NULL;
  --BEGIN BUG#1962677 K.RajaSekhar
  x_ic_jrnl_mst_row.journal_comment := NULL;
  x_ic_jrnl_mst_row.journal_comment := l_qty_rec.journal_comment;
  --END BUG#1962677
  x_ic_jrnl_mst_row.posting_id    := 0;
  x_ic_jrnl_mst_row.print_cnt     := 0;
  --Jalaj Srivastava Bug 2483656
  IF (l_qty_rec.journal_ind = 'N') THEN --Immediate txn
      x_ic_jrnl_mst_row.posted_ind    := 1;
  ELSE
      x_ic_jrnl_mst_row.posted_ind    := 0;
  END IF;
  x_ic_jrnl_mst_row.orgn_code     := l_qty_rec.orgn_code;
  x_ic_jrnl_mst_row.creation_date := SYSDATE;
  x_ic_jrnl_mst_row.last_update_date := SYSDATE;
  -- Bug 1735824
  -- Use the user name passed to the API instead of
  -- defaulting to the setup user name.
  x_ic_jrnl_mst_row.created_by    := l_user_id;
  x_ic_jrnl_mst_row.last_updated_by := l_user_id;

  x_ic_jrnl_mst_row.delete_mark   := 0;
  x_ic_jrnl_mst_row.text_code     := NULL;
  x_ic_jrnl_mst_row.in_use        := 0;
  x_ic_jrnl_mst_row.last_update_login := NULL;
  x_ic_jrnl_mst_row.program_application_id := NULL;
  x_ic_jrnl_mst_row.program_id    := NULL;
  x_ic_jrnl_mst_row.program_update_date := NULL;
  x_ic_jrnl_mst_row.request_id    := NULL;
  x_ic_jrnl_mst_row.attribute1         := UPPER(l_qty_rec.attribute1);
  x_ic_jrnl_mst_row.attribute2         := UPPER(l_qty_rec.attribute2);
  x_ic_jrnl_mst_row.attribute3         := UPPER(l_qty_rec.attribute3);
  x_ic_jrnl_mst_row.attribute4         := UPPER(l_qty_rec.attribute4);
  x_ic_jrnl_mst_row.attribute5         := UPPER(l_qty_rec.attribute5);
  x_ic_jrnl_mst_row.attribute6         := UPPER(l_qty_rec.attribute6);
  x_ic_jrnl_mst_row.attribute7         := UPPER(l_qty_rec.attribute7);
  x_ic_jrnl_mst_row.attribute8         := UPPER(l_qty_rec.attribute8);
  x_ic_jrnl_mst_row.attribute9         := UPPER(l_qty_rec.attribute9);
  x_ic_jrnl_mst_row.attribute10        := UPPER(l_qty_rec.attribute10);
  x_ic_jrnl_mst_row.attribute11        := UPPER(l_qty_rec.attribute11);
  x_ic_jrnl_mst_row.attribute12        := UPPER(l_qty_rec.attribute12);
  x_ic_jrnl_mst_row.attribute13        := UPPER(l_qty_rec.attribute13);
  x_ic_jrnl_mst_row.attribute14        := UPPER(l_qty_rec.attribute14);
  x_ic_jrnl_mst_row.attribute15        := UPPER(l_qty_rec.attribute15);
  x_ic_jrnl_mst_row.attribute16        := UPPER(l_qty_rec.attribute16);
  x_ic_jrnl_mst_row.attribute17        := UPPER(l_qty_rec.attribute17);
  x_ic_jrnl_mst_row.attribute18        := UPPER(l_qty_rec.attribute18);
  x_ic_jrnl_mst_row.attribute19        := UPPER(l_qty_rec.attribute19);
  x_ic_jrnl_mst_row.attribute20        := UPPER(l_qty_rec.attribute20);
  x_ic_jrnl_mst_row.attribute21        := UPPER(l_qty_rec.attribute21);
  x_ic_jrnl_mst_row.attribute22        := UPPER(l_qty_rec.attribute22);
  x_ic_jrnl_mst_row.attribute23        := UPPER(l_qty_rec.attribute23);
  x_ic_jrnl_mst_row.attribute24        := UPPER(l_qty_rec.attribute24);
  x_ic_jrnl_mst_row.attribute25        := UPPER(l_qty_rec.attribute25);
  x_ic_jrnl_mst_row.attribute26        := UPPER(l_qty_rec.attribute26);
  x_ic_jrnl_mst_row.attribute27        := UPPER(l_qty_rec.attribute27);
  x_ic_jrnl_mst_row.attribute28        := UPPER(l_qty_rec.attribute28);
  x_ic_jrnl_mst_row.attribute29        := UPPER(l_qty_rec.attribute29);
  x_ic_jrnl_mst_row.attribute30        := UPPER(l_qty_rec.attribute30);
  x_ic_jrnl_mst_row.attribute_category := UPPER(l_qty_rec.attribute_category);

  x_ic_adjs_jnl_row1.trans_type      := l_trans_code;
  x_ic_adjs_jnl_row1.trans_flag      := 0;
  x_ic_adjs_jnl_row1.doc_id          := NULL;
  x_ic_adjs_jnl_row1.journal_id      := NULL;
  IF (l_qty_rec.journal_ind = 'N') THEN --Immediate txn
      x_ic_adjs_jnl_row1.completed_ind   := 1;
  ELSE
      x_ic_adjs_jnl_row1.completed_ind   := 0;
  END IF;
  x_ic_adjs_jnl_row1.whse_code       := l_qty_rec.from_whse_code;
  x_ic_adjs_jnl_row1.reason_code     := l_qty_rec.reason_code;
  x_ic_adjs_jnl_row1.doc_date        := l_qty_rec.trans_date;
  x_ic_adjs_jnl_row1.item_id         := p_ic_item_mst_row.item_id;
  x_ic_adjs_jnl_row1.item_um         := l_qty_rec.item_um;
  x_ic_adjs_jnl_row1.item_um2        := l_qty_rec.item_um2;
  x_ic_adjs_jnl_row1.lot_id          := p_ic_lots_mst_row.lot_id;
  x_ic_adjs_jnl_row1.location        := l_qty_rec.from_location;
  IF l_qty_rec.txn_type IN ('CRE','ADJ') OR l_trans_code IN ('STSR','GRDR')
  THEN
    x_ic_adjs_jnl_row1.qty             := NVL(l_qty_rec.trans_qty,0);
    x_ic_adjs_jnl_row1.qty2            := l_qty_rec.trans_qty2;
  ELSIF l_qty_rec.txn_type = 'TRN' THEN
    x_ic_adjs_jnl_row1.qty             := NVL(-l_qty_rec.trans_qty,0);
    x_ic_adjs_jnl_row1.qty2            := -l_qty_rec.trans_qty2;
    /* *************************************************************
       Jalaj Srivastava Bug 2635964
       For grade transactions, there is no warehouse and location.
       The grade change affects the lot at all warehouse/location.
       To get onhand we need to sum up the onhands at all the
       warehouse/locations where the lot exists.
       ************************************************************* */
  ELSIF l_trans_code IN ('STSI','GRDI') THEN
    x_ic_adjs_jnl_row1.qty  := -l_onhand;
    x_ic_adjs_jnl_row1.qty2 := -l_onhand2;
  END IF;
  x_ic_adjs_jnl_row1.line_id         := NULL;
  x_ic_adjs_jnl_row1.co_code         := l_qty_rec.co_code;
  x_ic_adjs_jnl_row1.orgn_code       := l_qty_rec.orgn_code;
  x_ic_adjs_jnl_row1.no_inv          := 0; /*   NOT NULL on database */
  x_ic_adjs_jnl_row1.no_trans        := NULL;
  x_ic_adjs_jnl_row1.creation_date   := SYSDATE;
  x_ic_adjs_jnl_row1.last_update_date := SYSDATE;
  -- Bug 1735824
  -- Use the user name passed to the API instead of
  -- defaulting to the setup user name.
  x_ic_adjs_jnl_row1.created_by      := l_user_id;
  x_ic_adjs_jnl_row1.last_updated_by := l_user_id;
  x_ic_adjs_jnl_row1.trans_cnt       := 1;
  x_ic_adjs_jnl_row1.last_update_login := NULL;
  x_ic_adjs_jnl_row1.program_application_id := NULL;
  x_ic_adjs_jnl_row1.program_id    := NULL;
  x_ic_adjs_jnl_row1.program_update_date := NULL;
  x_ic_adjs_jnl_row1.request_id    := NULL;
  IF l_qty_rec.txn_type IN ('TRN','STS','GRD')
  THEN
    x_ic_adjs_jnl_row1.qc_grade      := l_original_qc_grade;
    x_ic_adjs_jnl_row1.lot_status    := l_original_lot_status;
    x_ic_adjs_jnl_row1.line_type     := -1;
    x_ic_adjs_jnl_row2 := x_ic_adjs_jnl_row1;
    x_ic_adjs_jnl_row2.qc_grade := l_qty_rec.qc_grade;
    x_ic_adjs_jnl_row2.lot_status := l_qty_rec.lot_status;
    x_ic_adjs_jnl_row2.line_type := 1;
    x_ic_adjs_jnl_row2.location := l_qty_rec.to_location;
    x_ic_adjs_jnl_row2.whse_code := l_qty_rec.to_whse_code;
    /* *************************************************************
       Jalaj Srivastava Bug 2635964
       For grade transactions, there is no warehouse and location.
       The grade change affects the lot at all warehouse/location.
       To get onhand we need to sum up the onhands at all the
       warehouse/locations where the lot exists.
       ************************************************************* */
      x_ic_adjs_jnl_row2.qty  := -x_ic_adjs_jnl_row1.qty;
      x_ic_adjs_jnl_row2.qty2 := -x_ic_adjs_jnl_row1.qty2;
  ELSE
    x_ic_adjs_jnl_row1.qc_grade      := l_qty_rec.qc_grade;
    x_ic_adjs_jnl_row1.lot_status    := l_qty_rec.lot_status;
    x_ic_adjs_jnl_row1.line_type     := 0;
  END IF;
  FND_MSG_PUB.Count_AND_GET (  p_count =>  x_msg_count
                             , p_data  =>  x_msg_data
                            );
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_count =>  x_msg_count
                                 , p_data  =>  x_msg_data
                                );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_count =>  x_msg_count
                                 , p_data  =>  x_msg_data
                                );
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
/*           IF   FND_MSG_PUB.check_msg_level */
/*                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) */
/*           THEN */

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , 'Validate_Inventory_posting'
                              );
/*          END IF; */
      FND_MSG_PUB.Count_AND_GET (  p_count =>  x_msg_count
                                 , p_data  =>  x_msg_data
                                );

END Validate_Inventory_Posting;


PROCEDURE Construct_Txn_Rec
  ( p_ic_adjs_jnl_row IN ic_adjs_jnl%ROWTYPE
   ,x_tran_rec     OUT NOCOPY GMI_TRANS_ENGINE_PUB.ictran_rec
  )
IS
BEGIN
  x_tran_rec.item_id          := p_ic_adjs_jnl_row.item_id;
  x_tran_rec.line_id          := p_ic_adjs_jnl_row.line_id;
  x_tran_rec.co_code          := p_ic_adjs_jnl_row.co_code;
  x_tran_rec.orgn_code        := p_ic_adjs_jnl_row.orgn_code;
  x_tran_rec.whse_code        := p_ic_adjs_jnl_row.whse_code;
  x_tran_rec.lot_id           := p_ic_adjs_jnl_row.lot_id;
  x_tran_rec.location         := p_ic_adjs_jnl_row.location;
  x_tran_rec.doc_id           := p_ic_adjs_jnl_row.doc_id;
  x_tran_rec.doc_type         := p_ic_adjs_jnl_row.trans_type;
  x_tran_rec.doc_line         := p_ic_adjs_jnl_row.doc_line;
  x_tran_rec.line_type        := p_ic_adjs_jnl_row.line_type;
  x_tran_rec.reason_code      := p_ic_adjs_jnl_row.reason_code;

--Jalaj Srivastava Bug 1683162
--trans date should be the date entered by the user and not the sysdate

  x_tran_rec.trans_date       := p_ic_adjs_jnl_row.doc_date;
  x_tran_rec.trans_qty        := p_ic_adjs_jnl_row.qty;
  x_tran_rec.trans_qty2       := p_ic_adjs_jnl_row.qty2;
  x_tran_rec.qc_grade         := p_ic_adjs_jnl_row.qc_grade;
  x_tran_rec.lot_no           := NULL;
  x_tran_rec.sublot_no        := NULL;
  x_tran_rec.lot_status       := p_ic_adjs_jnl_row.lot_status;
  x_tran_rec.trans_stat       := NULL;
  x_tran_rec.trans_um         := p_ic_adjs_jnl_row.item_um;
  x_tran_rec.trans_um2        := p_ic_adjs_jnl_row.item_um2;
  x_tran_rec.staged_ind       := NULL;
  x_tran_rec.event_id         := NULL;
  x_tran_rec.text_code        := NULL;
  x_tran_rec.user_id          := p_ic_adjs_jnl_row.created_by;
  x_tran_rec.create_lot_index := NULL;
  x_tran_rec.non_inv          := NULL;
END construct_txn_rec;

END GMIVQTY;

/
