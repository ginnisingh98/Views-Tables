--------------------------------------------------------
--  DDL for Package Body GMI_LOCT_INV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_LOCT_INV_PVT" AS
/*  $Header: GMIVBULB.pls 115.17 2004/07/07 14:46:47 jgogna ship $ */
/* +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |     GMIVBULB.pls                                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains private definitions For Business Layer        |
 |     Logic For IC_LOCT_INV                                               |
 |                                                                         |
 | HISTORY                                                                 |
 |     12-JAN-2000  H.Verdding                                             |
 |     11-OCT-2000  Jalaj Srivastava Bug 1427888                           |
 |     Jalaj Srivastava Bug 2483644 06/08/2002                             |
 |     Included changes to process journal transactions also.              |
 |     For destination move line the status needs to be updated.           |
 |     28-OCT-2002  Joe DiIorio Bug #2643440 - 11.5.1J - added nocopy.     |
 |    Jalaj Srivastava Bug 3158806                                         |
 |      Update ic_lots_cpg with hold_date if it is the first yielding      |
 |      transaction.                                                       |
 |    27-FEB-2004  Jatinder Gogna - 3470841                                |
 |                 Compute the lot dates for the first yielding transaction|
 |     7-JUN-2004  Teresa Wong B3415691 - Enhancement for Serono           |
 |                 Added code to recheck negative inventory and lot        |
 |                 status at the time of save.                             |
 |    24-JUN-2004  Teresa Wong B3415691 - Enhancement for Serono           |
 |		   Added code to update lot status in ic_loct_inv          |
 |		   for yield transaction only if GMI: Move Different Status|
 |		   was set to 2 and the onhand of the lot in the location  |
 |		   into which it was being yielded to was 0.               |
 |     6-JUL-2004  Jatinder Gogna - 3739308                                |
 |                 Set the dates to MAX date if the item is grade          |
 |                 controlled and intervals are NULL or zero               |
 +=========================================================================+
  API Name  : GMI_LOCT_INV_PVT
  Type      : Public
  Function  : This package contains private procedures used to create
              IC_LOCT_INV transactions
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0

  Previous Vers : 1.0

  Initial Vers  : 1.0
  Notes

  Body end of comments
*/
/*  Global variables */
G_PKG_NAME  CONSTANT  VARCHAR2(30):='GMI_LOCT_INV_PVT';

PROCEDURE UPDATING_IC_LOCT_INV
(
  p_tran_rec         IN  GMI_TRANS_ENGINE_PUB.ictran_rec,
  x_return_status    OUT NOCOPY VARCHAR2
)
IS
err_msg    VARCHAR2(200);
err_num    NUMBER;
l_loct_inv IC_LOCT_INV%ROWTYPE;
l_loct_inv_rec	ic_loct_inv%ROWTYPE; /* TKW B3415691 */

BEGIN

   /*   Initialize return status to sucess */
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   /*  Copy required Fields From Ic_tran_rec record Type. */

   l_loct_inv.item_id          := p_tran_rec.item_id;
   l_loct_inv.lot_id           := p_tran_rec.lot_id;
   l_loct_inv.whse_code        := p_tran_rec.whse_code;
   l_loct_inv.lot_status       := p_tran_rec.lot_status;
   l_loct_inv.loct_onhand      := p_tran_rec.trans_qty;
   l_loct_inv.loct_onhand2     := p_tran_rec.trans_qty2;
   l_loct_inv.text_code        := p_tran_rec.text_code;
   l_loct_inv.delete_mark      := 0;
   l_loct_inv.location         := p_tran_rec.location;

   /*  Do we Just need User_id Only -----  */

   l_loct_inv.last_updated_by  := p_tran_rec.user_id;
   l_loct_inv.created_by       := p_tran_rec.user_id;
   l_loct_inv.last_update_date := SYSDATE;
   l_loct_inv.creation_date    := SYSDATE;


   /* TKW 6/7/2004 B3415691 */
   IF NOT GMIUTILS.NEG_INV_CHECK
    ( p_item_id		=>      l_loct_inv.item_id,
      p_whse_code	=>      l_loct_inv.whse_code,
      p_lot_id		=>      l_loct_inv.lot_id,
      p_location	=>      l_loct_inv.location,
      p_qty		=> 	p_tran_rec.trans_qty,
      p_qty2		=> 	p_tran_rec.trans_qty2
    )
   THEN
        RAISE FND_API.G_EXC_ERROR;
   END IF;

   /* TKW 6/7/2004 B3415691 */
   IF NOT GMIUTILS.LOT_STATUS_CHECK
    ( p_item_id		=>	l_loct_inv.item_id,
      p_whse_code	=>      l_loct_inv.whse_code,
      p_lot_id		=>      l_loct_inv.lot_id,
      p_location	=>      l_loct_inv.location,
      p_doc_type	=>	p_tran_rec.doc_type,
      p_line_type	=>	p_tran_rec.line_type,
      p_trans_qty	=>      p_tran_rec.trans_qty,
      p_lot_status	=>	p_tran_rec.lot_status
    )
   THEN
        RAISE FND_API.G_EXC_ERROR;
   END IF;

   /*  Update Inventory LOCTary Table -- */
/* Jalaj Srivastava Bug 1427888 11-OCT-2000 */
/* For status txn it the status needs to be updated in ic_loct_inv */
/* For destination move transaction, the status needs to be updated */
/*  For grade txn nothing needs to be updated in ic_loct_inv */
/* ****************************************************
   Jalaj Srivastava Bug 2483644
   Now journal txns would also be posted using these APIs
   ***************************************************** */
IF (substr(p_tran_rec.doc_type,1,3) <> 'GRD') THEN
 IF (substr(p_tran_rec.doc_type,1,3) ='STS') THEN
  IF (GMI_LOCT_INV_DB_PVT.UPDATE_IC_LOCT_INV
       ( p_loct_inv       => l_loct_inv,
         p_status_updated => 1,
         p_qty_updated    => 0
       )
     ) THEN
        RETURN;
  END IF;
 ELSE
   /* Jalaj Srivastava Bug 3158806
        Update ic_lots_cpg with hold_date if it is the first yielding transaction.
        and hold date is null. update_ic_loct_inv internally calls insert_ic_loct_inv
        if there is no existing inventory*/
   Update ic_lots_cpg
   Set    ic_hold_date = (select p_tran_rec.trans_date + ic_hold_days
                          from   ic_item_cpg
                          where  item_id = l_loct_inv.item_id
                                  )
   Where  item_id = l_loct_inv.item_id and
          lot_id  = l_loct_inv.lot_id  and
          ic_hold_date is NULL         and
          not exists (select 1
                      from   ic_loct_inv
                      where  item_id = l_loct_inv.item_id
                      and    lot_id  = l_loct_inv.lot_id
                     );

  /* JG - 3470841 - Compute the lot dates for the first yielding transactions */

   IF ((p_tran_rec.doc_type = 'PROD' and p_tran_rec.line_type = -1) or (p_tran_rec.doc_type = 'OMSO')) THEN
	NULL; /* Not a yielding transaction */
   ELSE
       /* 3739308 - Set the dates to MAX date if the item is grade controlled and intervals
	are NULL or zero */
       update ic_lots_mst
       set (lot_created, expire_date, retest_date, expaction_date) =
    	( select nvl(lot_created, p_tran_rec.trans_date),
    		nvl(expire_date, decode (grade_ctl + nvl(shelf_life,0), 0,
			GMA_GLOBAL_GRP.SY$MAX_DATE, p_tran_rec.trans_date + nvl(shelf_life,0))),
    		nvl(retest_date, decode (grade_ctl + nvl(shelf_life,0), 0,
			GMA_GLOBAL_GRP.SY$MAX_DATE, p_tran_rec.trans_date + nvl(retest_interval,0))),
    		nvl(expaction_date, decode (grade_ctl + nvl(shelf_life,0), 0,
			GMA_GLOBAL_GRP.SY$MAX_DATE, p_tran_rec.trans_date + nvl(shelf_life,0) +
    				nvl(expaction_interval,0)))
    	  from ic_item_mst_b
    	where item_id = l_loct_inv.item_id)
       Where  item_id = l_loct_inv.item_id and
              lot_id  = l_loct_inv.lot_id and
    	      lot_created is NULL;
   END IF;


  IF (GMI_LOCT_INV_DB_PVT.UPDATE_IC_LOCT_INV
       ( p_loct_inv       => l_loct_inv,
         p_status_updated => 0,
         p_qty_updated    => 1
       )
     ) THEN

     /* ************************************************
	Jalaj Srivastava BUg 2483644
	Now, we know the row exists.
	Update with the new lot status (if any)
	*********************************************** */
         IF (     (substr(p_tran_rec.doc_type,1,3) ='TRN')
	      AND (p_tran_rec.line_type = 1)
            ) THEN
	        IF (GMI_LOCT_INV_DB_PVT.UPDATE_IC_LOCT_INV
		      ( p_loct_inv       => l_loct_inv,
		        p_status_updated => 1,
		        p_qty_updated    => 0
					    )
		      ) THEN
                  	   RETURN;
	        END IF;
         END IF;

	/**********************************************
	 TKW B3415691 - Update with new lot status
	 for yield transaction if profile
 	 GMI: Move Different Status is Not Allowed with
	 Exception and onhand of the lot in the location
	 into which it is being yielded is 0
	 ***********************************************/
	IF (p_tran_rec.doc_type = 'PROD'
	    AND p_tran_rec.line_type = 1
	    AND FND_PROFILE.VALUE('IC$MOVEDIFFSTAT') = 2 ) THEN
		gmigutl.get_loct_inv (
			p_item_id		=> p_tran_rec.item_id,
			p_whse_code		=> p_tran_rec.whse_code,
			p_lot_id		=> p_tran_rec.lot_id,
			p_location		=> p_tran_rec.location,
			x_ic_loct_inv_row	=> l_loct_inv_rec
		);

		IF (NVL (l_loct_inv_rec.loct_onhand, 0) - p_tran_rec.trans_qty = 0) THEN
			IF (GMI_LOCT_INV_DB_PVT.UPDATE_IC_LOCT_INV
				( p_loct_inv       => l_loct_inv,
				  p_status_updated => 1,
				  p_qty_updated    => 0
				)
			   ) THEN
				RETURN;
			END IF; /* update lot status */
		END IF; /* onhand is 0 */
	END IF; /* yield transaction and profile = 2 */
  ELSE /* We are Going to create New record */
    /* Jalaj Srivastava Bug 3158806
         This part actually never gets called. update internally calls insert_ic_loct_inv.*/

     IF(GMI_LOCT_INV_DB_PVT.INSERT_IC_LOCT_INV( p_loct_inv => l_loct_inv)) THEN
       RETURN;
     ELSE
        FND_MESSAGE.SET_NAME('GMI','GMI_IC_LOCT_INV_INSERT');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
     END IF;
  END IF;
 END IF;
END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                             , 'UPDATING_IC_LOCT_INV'
                            );



END UPDATING_IC_LOCT_INV;

END GMI_LOCT_INV_PVT;

/
