--------------------------------------------------------
--  DDL for Package Body GMI_TRANS_ENGINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_TRANS_ENGINE_PVT" AS
/* $Header: GMIVTXNB.pls 115.38 2004/06/17 23:04:23 txyu ship $ */
/* ***************************************************************
 *                                                             *
 * Package  GMI_TRANS_ENGINE_PVT                               *
 *                                                             *
 * Contents CREATE_PENDING_TRANSACTION                         *
 *          DELETE_PENDING_TRANSACTION                         *
 *          UPDATE_PENDING_TRANSACTION                         *
 *          UPDATE_PENDING_TO_COMPLETED                        *
 *          CREATE_COMPLETED_TRANSACTION                       *
 *                                                             *
 * Use      This is the top level of the private layer for the *
 *          Inventory Transaction Processor.                   *
 *                                                             *
 * History                                                     *
 *          Written by Harminder Verdding, OPM Development     *
 *                                                             *
 * 23-May-00 P.J.Schofield for B1294915. Added Completed       *
 *          Transaction support and also logic for XFER        *
 *          pending transactions                               *
 * 13-OCT-00 Jalaj Srivastava Bug 1427922.
 *           Grade and status txns can happen in closed
 *           periods.
 *           Added logic for grade changes                     *
 * 14-JUN-01 H Verdding Bug 1834369 .
 *           Encapsulated Validate Trans Date Logic With new
 *           Function CHECK_PERIOD_CLOSE.
 * 24-AUG-01 Added line_detail_id BUG#1675561
 *	     Added NVL(p_tran_rec.trans_date,SYSDATE)  for     *
 *           creation_date in COMPLETED_TRANSACTION_BUILD per  *
 *           Karen's request.                                  *
 * 03-OCT-01 H Verdding Bug 2025933
 *           Added Fetch to get noninv Value For Item          *
 *================================================
 *   Joe DiIorio 10/22/2001 11.5.1H BUG#2064443
 *   Added reason code assigment.
 *================================================
 *   Joe DiIorio 04/08/2002 11.5.1I BUG#2248778
 *   Added Whse code to message ic_api_txn_post_closed.
 *   Jatinder 4/11/2002 - removed extra comments character
 *   which were causing the compilation error.
 *   Thomas Daniel 04/18/2002 11.5.1I BUG#2322973
 *   In the close_period_check function added code to invoke the
 *   trans date validate routine with the sysdate only if the
 *   period was closed for the passed in trans date. Also added
 *   specific messaging to the return codes from trans date validate.
 *
 *  VRA Srinivas  26/Apr/2002 BUG#2341493
 *  Changed the code to not to insert into IC_TRAN_CMP when
 *  DOC_TYPE is STSI and STATUS_CTL is No Inventory.
 *  Jalaj Srivastava 07/24/02 Bug 2483644
 *  Modified create completed transaction to accept/process
 *  journal transactions doc types also.
 *  Jalaj Srivastava Bug 2519568
 *  Removed DML code for ic_summ_inv since, now ic_summ_inv is
 *  a view created from the data in ic_loct_inv and ic_tran_pnd
 *  Joe DiIorio      Bug 2643440  11.5.1J
 *  Added nocopy.
 *  Joe DiIorio      Bug 3090255  11.5.10L  08/15/2003
 *  Added field intorder_posted_ind.
 *  Jeff Baird       Bug #3409615  02/05/2004
 *  Added who columns to update of ic_lots_mst.
 *  Jeff Baird       Bug #3434156  02/10/2004
 *  Corrected column name in above fix.
 *  V.Anitha         BUG#3526733   14-APR-2004
 *  Added colum reverse_id column in create_completed_transactions
 *  and COMPLETED_TRANSACTION_BUILD procedures.
 *  Teresa Wong      B3415691 	   6/7/2004
 *  Enhancement for Serono (Pls refer to B3599127)
 *  Modified update_pending_to_completed
 *  to ensure the completed transaction reflected
 *  the lot status and qc grade of the lot in ic_loct_inv
 *  at the time the transaction took place
 *********************************************************************
*/
/* Global variables */
G_PKG_NAME  CONSTANT  VARCHAR2(30):='GMI_TRANS_ENGINE_PVT';

PROCEDURE CREATE_PENDING_TRANSACTION
( p_api_version      IN  NUMBER
, p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE
, p_commit           IN  VARCHAR2 := FND_API.G_FALSE
, p_validation_level IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL
, p_tran_rec         IN  GMI_TRANS_ENGINE_PUB.ictran_rec
, x_tran_row         OUT NOCOPY IC_TRAN_PND%ROWTYPE
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY NUMBER
, x_msg_data         OUT NOCOPY VARCHAR2
)
IS
  l_api_name           CONSTANT VARCHAR2 (30) := 'CREATE_PENDING_TRANSACTION';
  l_api_version        CONSTANT NUMBER        := 1.0;
  l_tran_rec           GMI_TRANS_ENGINE_PUB.ictran_rec;
  l_tran_rec_val       GMI_TRANS_ENGINE_PUB.ictran_rec;
  l_tran_row           IC_TRAN_PND%ROWTYPE;
  l_msg_count          NUMBER  :=0;
  l_return_val         NUMBER  :=0;
  l_retry_flag         NUMBER  :=1;
  l_msg_data           VARCHAR2(2000);
  l_return_status      VARCHAR2(1);
BEGIN
  /* Standard Start OF API savepoint*/
  SAVEPOINT create_pending_transaction;

  /* Initialize API return status to sucess*/
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /*  Move transaction Table record to local*/
  /*  This has to be done to add new trans id record */
  l_tran_rec   := p_tran_rec;

  IF p_validation_level = FND_API.G_VALID_LEVEL_FULL
  THEN
    SET_DEFAULTS (p_tran_rec => p_tran_rec, x_tran_rec => l_tran_rec);
  END IF;

  /* Validate Trans Date For Posting Into Closed Periods.*/

  IF NOT CLOSE_PERIOD_CHECK
    ( p_tran_rec   => l_tran_rec,
      p_retry_flag => l_retry_flag,
      x_tran_rec   => l_tran_rec
    )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

 /* ***********************************************************
    Jalaj Srivastava Bug 2519568
    Removed DML code for ic_summ_inv since, now ic_summ_inv is
    a view created from the data in ic_loct_inv and ic_tran_pnd
    *********************************************************** */

  PENDING_TRANSACTION_BUILD
  ( p_tran_rec           => l_tran_rec
  , x_tran_row           => l_tran_row
  , x_return_status      => l_return_status
  );

  /* Call the IC_TRAN_PND INSERT procedure to insert this record. */

  IF NOT GMI_TRAN_PND_DB_PVT.INSERT_IC_TRAN_PND
    ( p_tran_row => l_tran_row, x_tran_row => x_tran_row)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  /* Standard Check of p_commit. */

  IF FND_API.to_boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_pending_transaction;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_pending_transaction;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );
    WHEN OTHERS THEN
      ROLLBACK TO create_pending_transaction;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

END CREATE_PENDING_TRANSACTION;



PROCEDURE CREATE_COMPLETED_TRANSACTION
( p_api_version      IN  NUMBER
, p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE
, p_commit           IN  VARCHAR2 := FND_API.G_FALSE
, p_validation_level IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL
, p_tran_rec         IN  GMI_TRANS_ENGINE_PUB.ictran_rec
, x_tran_row         OUT NOCOPY IC_TRAN_CMP%ROWTYPE
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY NUMBER
, x_msg_data         OUT NOCOPY VARCHAR2
, p_table_name       IN  VARCHAR2 := 'IC_TRAN_CMP'
)
IS
  l_api_name           CONSTANT VARCHAR2 (30) := 'CREATE_COMPLETED_TRANSACTION';
  l_api_version        CONSTANT NUMBER        := 1.0;
  l_tran_rec           GMI_TRANS_ENGINE_PUB.ictran_rec;
  l_tran_cmp           IC_TRAN_CMP%ROWTYPE;
  l_tran_pnd           IC_TRAN_PND%ROWTYPE;
  l_msg_count          NUMBER  :=0;
  l_return_val         NUMBER  :=0;
  l_retry_flag         NUMBER  :=0;
  l_msg_data           VARCHAR2(2000);
  l_return_status      VARCHAR2(1);
  -- BEGIN Bug# 2341493 VRA Srinivas  26/04/2002
  l_status_ctl	       NUMBER;
  --END Bug# 2341493
  l_ic_loct_inv_row_in          ic_loct_inv%ROWTYPE;
  l_ic_loct_inv_row_out          ic_loct_inv%ROWTYPE;

   -- BEGIN Bug# 2341493 VRA Srinivas  26/04/2002
  CURSOR Cur_status_ctl(pitem_id NUMBER) IS
  SELECT
    status_ctl
  FROM
    ic_item_mst
  WHERE
    item_id = pitem_id;
   --END Bug# 2341493

BEGIN
  /* Standard Start OF API savepoint */
  SAVEPOINT create_completed_transaction;
  /*  Standard call to check for call compatibility. */
  IF NOT FND_API.Compatible_API_CALL
    (l_api_version , p_api_version , l_api_name , G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  /*  Initialize message list if p_int_msg_list is set TRUE. */
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  /*  Initialize API return status to sucess */
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /*   Move transaction Table record to local */
   /*  This has to be done to add new trans id record */
  l_tran_rec    := p_tran_rec;

  IF p_validation_level = FND_API.G_VALID_LEVEL_FULL THEN
    SET_DEFAULTS (  p_tran_rec => p_tran_rec ,x_tran_rec => l_tran_rec);
  END IF;

/* Jalaj Srivastava Bug 1427922 */
/* Grade and status txns do not require trans date validation. */

 --Jalaj Srivastava Bug 2483644
 --Now journal txns would also be posted using these APIs
 IF (substr(l_tran_rec.doc_type,1,3) NOT IN ('STS','GRD')) THEN


   IF NOT CLOSE_PERIOD_CHECK
     ( p_tran_rec   => l_tran_rec,
       p_retry_flag => l_retry_flag,
       x_tran_rec   => l_tran_rec
     )
     THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

 END IF;

  /* Jalaj Srivastava Bug 1427922 */
 --Jalaj Srivastava Bug 2483644
 --Now journal txns would also be posted using these APIs
  IF ( (l_tran_rec.non_inv = 0) AND (substr(l_tran_rec.doc_type,1,3) <> 'GRD') )
    THEN
    GMI_LOCT_INV_PVT.UPDATING_IC_LOCT_INV
      (
       p_tran_rec      => l_tran_rec,
       x_return_status =>l_return_status
      );

    /*  if errors were found then Raise Exception  */
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

    /*  Update Inventory Balances ( Actuals).  */
 /* ***********************************************************
    Jalaj Srivastava Bug 2519568
    Removed DML code for ic_summ_inv since, now ic_summ_inv is
    a view created from the data in ic_loct_inv and ic_tran_pnd
    *********************************************************** */


/*  Jalaj Srivastava Bug 1427922 */
/*  Added logic for grade txns and to update ic_lots_mst for change in gradeREM  */

 --Jalaj Srivastava Bug 2483644
 --Now journal txns would also be posted using these APIs
IF (substr(l_tran_rec.doc_type,1,3) = 'GRD') THEN

    /*  Update ic_lots_mst with the new grade */

    update ic_lots_mst set
      qc_grade         = l_tran_rec.qc_grade,
      last_update_date = SYSDATE,
      last_updated_by  = p_tran_rec.user_id
    where  item_id     = l_tran_rec.item_id
    and    lot_id      = l_tran_rec.lot_id
    and    delete_mark = 0;

-- Bug #3409615 (JKB) Added who columns above.

END IF; /*  IF (l_tran_rec.doc_type = 'GRDI') */

   /*  end of bug 1427922REM ---------------------------- */

    /*  Call the IC_TRAN_CMP INSERT procedure to insert this record. */

  IF p_table_name = 'IC_TRAN_CMP'
  THEN
    --BEGIN Bug# 2341493 VRA Srinivas  26/04/2002
    --Do not insert into ic_tran_cmp if the status control
    --of the item is set to 'No Inventory'
    OPEN Cur_status_ctl(p_tran_rec.item_id);
    FETCH Cur_status_ctl INTO l_status_ctl;
    CLOSE Cur_status_ctl;
    --Jalaj Srivastava Bug 2483644
    --Now journal txns would also be posted using these APIs
    IF (l_status_ctl = 2 AND  substr(p_tran_rec.doc_type,1,3) = 'STS')
    THEN
      NULL;
    ELSE
     -- END Bug# 2341493

    	/*  Call the IC_TRAN_CMP INSERT procedure to insert this record. */
    	l_tran_cmp.trans_id      	    := p_tran_rec.trans_id;
    	l_tran_cmp.item_id       	    := p_tran_rec.item_id;
    	l_tran_cmp.line_id       	    := p_tran_rec.line_id;
    	l_tran_cmp.co_code 	    	    := p_tran_rec.co_code;
    	l_tran_cmp.orgn_code     	    := p_tran_rec.orgn_code;
    	l_tran_cmp.whse_code     	    := p_tran_rec.whse_code;
    	l_tran_cmp.reason_code        := p_tran_rec.reason_code;
    	l_tran_cmp.lot_id        	    := p_tran_rec.lot_id;
    	l_tran_cmp.location      	    := p_tran_rec.location;
    	l_tran_cmp.doc_type           := p_tran_rec.doc_type;
    	l_tran_cmp.doc_id       	    := p_tran_rec.doc_id;
    	l_tran_cmp.doc_line      	    := NVL(p_tran_rec.doc_line,0);
    	l_tran_cmp.line_type          := NVL(p_tran_rec.line_type,0);
    	l_tran_cmp.creation_date      := SYSDATE;
    	l_tran_cmp.trans_date         := NVL(p_tran_rec.trans_date,SYSDATE);
    	l_tran_cmp.trans_qty          := p_tran_rec.trans_qty;
    	l_tran_cmp.trans_qty2         := p_tran_rec.trans_qty2;
    	l_tran_cmp.qc_grade    	    := p_tran_rec.qc_grade;
    	l_tran_cmp.lot_status    	    := p_tran_rec.lot_status;
    	l_tran_cmp.trans_stat    	    := p_tran_rec.trans_stat;
    	l_tran_cmp.trans_um      	    := p_tran_rec.trans_um;
    	l_tran_cmp.trans_um2          := p_tran_rec.trans_um2;
    	l_tran_cmp.op_code       	    := p_tran_rec.user_id;
    	l_tran_cmp.gl_posted_ind      := 0; /* Always 0 */
    	l_tran_cmp.event_id      	    := NVL(p_tran_rec.event_id,0);
    	l_tran_cmp.text_code          := p_tran_rec.text_code;
    	l_tran_cmp.last_update_date   := SYSDATE;
    	l_tran_cmp.last_updated_by    := p_tran_rec.user_id;
    	l_tran_cmp.created_by    	    := p_tran_rec.user_id;
    	l_tran_cmp.line_detail_id     := NVL(p_tran_rec.line_detail_id,NULL);
        /*============================================
           BUG#3090255 Populated intorder_posted_ind
          ==========================================*/
    	l_tran_cmp.intorder_posted_ind := NVL(p_tran_rec.intorder_posted_ind,0);

    	IF NOT GMI_TRAN_CMP_PVT.INSERT_IC_TRAN_CMP
      	( p_tran_row => l_tran_cmp, x_tran_row => x_tran_row)
    	THEN
      		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    	END IF;
    -- BEGIN Bug# 2341493 VRA Srinivas  26/04/2002
    END IF; -- l_status_ctl =2 and p_tran_rec.doc_type='STSI')
    -- END Bug# 2341493

 ELSE
    /*  Call the IC_TRAN_PND INSERT procedure to insert this record. */
    l_tran_pnd.trans_id      	    := p_tran_rec.trans_id;
    l_tran_pnd.item_id       	    := p_tran_rec.item_id;
    l_tran_pnd.line_id       	    := p_tran_rec.line_id;
    l_tran_pnd.co_code 	    	    := p_tran_rec.co_code;
    l_tran_pnd.orgn_code     	    := p_tran_rec.orgn_code;
    l_tran_pnd.whse_code     	    := p_tran_rec.whse_code;
    l_tran_pnd.reason_code        := p_tran_rec.reason_code;
    l_tran_pnd.lot_id        	    := p_tran_rec.lot_id;
    l_tran_pnd.location      	    := p_tran_rec.location;
    l_tran_pnd.doc_type           := p_tran_rec.doc_type;
    l_tran_pnd.doc_id       	    := p_tran_rec.doc_id;
    l_tran_pnd.doc_line      	    := NVL(p_tran_rec.doc_line,0);
    l_tran_pnd.line_type          := NVL(p_tran_rec.line_type,0);
    l_tran_pnd.creation_date      := SYSDATE;
    l_tran_pnd.trans_date         := NVL(p_tran_rec.trans_date,SYSDATE);
    l_tran_pnd.trans_qty          := p_tran_rec.trans_qty;
    l_tran_pnd.trans_qty2         := p_tran_rec.trans_qty2;
    l_tran_pnd.qc_grade    	    := p_tran_rec.qc_grade;
    l_tran_pnd.lot_status    	    := p_tran_rec.lot_status;
    l_tran_pnd.trans_stat    	    := p_tran_rec.trans_stat;
    l_tran_pnd.trans_um      	    := p_tran_rec.trans_um;
    l_tran_pnd.trans_um2          := p_tran_rec.trans_um2;
    l_tran_pnd.op_code       	    := p_tran_rec.user_id;
    l_tran_pnd.gl_posted_ind      := 0; /* Always 0 */
    l_tran_pnd.event_id      	    := NVL(p_tran_rec.event_id,0);
    l_tran_pnd.text_code          := p_tran_rec.text_code;
    l_tran_pnd.last_update_date   := SYSDATE;
    l_tran_pnd.last_updated_by    := p_tran_rec.user_id;
    l_tran_pnd.created_by    	    := p_tran_rec.user_id;
    l_tran_pnd.staged_ind         := p_tran_rec.staged_ind;
    l_tran_pnd.completed_ind      := 1;
    l_tran_pnd.delete_mark        := 0;
    l_tran_pnd.line_detail_id     := NVL(p_tran_rec.line_detail_id,NULL);
    /*============================================
       BUG#3090255 Populated intorder_posted_ind
      ==========================================*/
    l_tran_pnd.intorder_posted_ind := NVL(p_tran_rec.intorder_posted_ind,0);
    /*============================================
       BUG#3526733 Populated reverse_id
      ==========================================*/
    l_tran_pnd.reverse_id          := p_tran_rec.reverse_id;

    IF NOT GMI_TRAN_PND_DB_PVT.INSERT_IC_TRAN_PND
      ( p_tran_row => l_tran_pnd, x_tran_row => l_tran_pnd)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /* Need to sort out the return row to the caller.... */
    x_tran_row.trans_id      	    := l_tran_pnd.trans_id;
    x_tran_row.item_id       	    := l_tran_pnd.item_id;
    x_tran_row.line_id       	    := l_tran_pnd.line_id;
    x_tran_row.co_code 	    	    := l_tran_pnd.co_code;
    x_tran_row.orgn_code     	    := l_tran_pnd.orgn_code;
    x_tran_row.whse_code     	    := l_tran_pnd.whse_code;
    x_tran_row.reason_code        := l_tran_pnd.reason_code;
    x_tran_row.lot_id        	    := l_tran_pnd.lot_id;
    x_tran_row.location      	    := l_tran_pnd.location;
    x_tran_row.doc_type           := l_tran_pnd.doc_type;
    x_tran_row.doc_id       	    := l_tran_pnd.doc_id;
    x_tran_row.doc_line      	    := l_tran_pnd.doc_line;
    x_tran_row.line_type          := l_tran_pnd.line_type;
    x_tran_row.creation_date      := l_tran_pnd.creation_date;
    x_tran_row.trans_date         := l_tran_pnd.trans_date;
    x_tran_row.trans_qty          := l_tran_pnd.trans_qty;
    x_tran_row.trans_qty2         := l_tran_pnd.trans_qty2;
    x_tran_row.qc_grade    	    := l_tran_pnd.qc_grade;
    x_tran_row.lot_status    	    := l_tran_pnd.lot_status;
    x_tran_row.trans_stat    	    := l_tran_pnd.trans_stat;
    x_tran_row.trans_um      	    := l_tran_pnd.trans_um;
    x_tran_row.trans_um2          := l_tran_pnd.trans_um2;
    x_tran_row.op_code       	    := l_tran_pnd.op_code;
    x_tran_row.gl_posted_ind      := l_tran_pnd.gl_posted_ind;
    x_tran_row.event_id      	    := l_tran_pnd.event_id;
    x_tran_row.text_code          := l_tran_pnd.text_code;
    x_tran_row.last_update_date   := l_tran_pnd.last_update_date;
    x_tran_row.last_updated_by    := l_tran_pnd.op_code;
    x_tran_row.created_by    	    := l_tran_pnd.op_code;
    x_tran_row.line_detail_id      := NVL(l_tran_pnd.line_detail_id,NULL);
    /*============================================
       BUG#3090255 Populated intorder_posted_ind
      ==========================================*/
    x_tran_row.intorder_posted_ind := NVL(l_tran_pnd.intorder_posted_ind,0);
    /*============================================
       BUG#3526733 Populated reverse_id
      ==========================================*/
    -- 3575580
    -- Commented the lines below as reverse id does not exist in ic_tran_cmp.
    -- x_tran_row.reverse_id          := l_tran_pnd.reverse_id;

 END IF;


  /*  Standard Check of p_commit. */
  IF FND_API.to_boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_completed_transaction;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_completed_transaction;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );
    WHEN OTHERS THEN
      ROLLBACK TO create_completed_transaction;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

END CREATE_COMPLETED_TRANSACTION;


PROCEDURE DELETE_PENDING_TRANSACTION
( p_api_version      IN  NUMBER
, p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE
, p_commit           IN  VARCHAR2 := FND_API.G_FALSE
, p_validation_level IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL
, p_tran_rec         IN  GMI_TRANS_ENGINE_PUB.ictran_rec
, x_tran_row         OUT NOCOPY IC_TRAN_PND%ROWTYPE
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY NUMBER
, x_msg_data         OUT NOCOPY VARCHAR2
)
IS
  l_api_name           CONSTANT VARCHAR2 (30) := 'DELETE_PENDING_TRANSACTION';
  l_api_version        CONSTANT NUMBER        := 1.0;
  l_tran_rec           GMI_TRANS_ENGINE_PUB.ictran_rec;
  l_tran_fetch_rec     GMI_TRANS_ENGINE_PUB.ictran_rec;
  l_msg_count          NUMBER  :=0;
  l_return_val         NUMBER  :=0;
  l_msg_data           VARCHAR2(2000);
  l_return_status      VARCHAR2(1);
  l_trans_id           IC_TRAN_PND.TRANS_ID%TYPE;
  l_tran_row           IC_TRAN_PND%ROWTYPE;
BEGIN
  /*  Standard Start OF API savepoint */
  SAVEPOINT delete_pending_transaction;

  /*  Initialize API return status to sucess */
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /* Move transaction Table record to local*/
  /* This has to be done to add new trans id record */
  l_tran_rec    := p_tran_rec;

  IF p_validation_level = FND_API.G_VALID_LEVEL_FULL
  THEN
    SET_DEFAULTS (  p_tran_rec => p_tran_rec ,x_tran_rec => l_tran_rec);
  END IF;

  /*  COMMENTED OUT Validate Trans Date For Posting Into Closed Periods.

  l_return_val := GMICCAL.trans_date_validate (  l_tran_rec.trans_date
                                                 , l_tran_rec.orgn_code
                                                 , l_tran_rec.whse_code
                                                );
  ==============================================
    Joe DiIorio 04/08/2002 11.5.1I BUG#2248778
    Jatinder - Removed the comment characters from
    this code.
  ============================================
  IF (l_return_val <> 0)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_TXN_POST_CLOSED');
    FND_MESSAGE.SET_TOKEN('DATE',l_tran_rec.trans_date);
    FND_MESSAGE.SET_TOKEN('WAREH',l_tran_rec.whse_code);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  */

  /*  Call the IC_TRAN_PND FETCH procedure to FETCH this record. */

  IF NOT GMI_TRAN_PND_DB_PVT.FETCH_IC_TRAN_PND
     ( p_tran_rec => l_tran_rec, x_tran_fetch_rec => l_tran_fetch_rec )
  THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  /*  Check If this is A Non-Inventory Item  */

  IF l_tran_rec.non_inv = 0
  THEN
    /*  Negate The Quantities */

    l_tran_fetch_rec.trans_qty  := l_tran_fetch_rec.trans_qty  *-1;
    l_tran_fetch_rec.trans_qty2 := l_tran_fetch_rec.trans_qty2 *-1;

 /* ***********************************************************
    Jalaj Srivastava Bug 2519568
    Removed DML code for ic_summ_inv since, now ic_summ_inv is
    a view created from the data in ic_loct_inv and ic_tran_pnd
    *********************************************************** */
 END IF;

  /*  Call Create_pending_transaction to build ic_tran_pnd%rowtype; */

  PENDING_TRANSACTION_BUILD
    ( p_tran_rec           => l_tran_fetch_rec
    , x_tran_row           => l_tran_row
    , x_return_status      => l_return_status
    );

  /*  Call the IC_TRAN_PND DELETE procedure to Logically Delete this record. */

  IF NOT GMI_TRAN_PND_DB_PVT.DELETE_IC_TRAN_PND
    ( p_tran_row => l_tran_row )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  /*  Standard Check of p_commit. */
  IF FND_API.to_boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;

  x_tran_row := l_tran_row;

  x_return_status := l_return_status;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO delete_pending_transaction;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_pending_transaction;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );
    WHEN OTHERS THEN
      ROLLBACK TO delete_pending_transaction;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

END DELETE_PENDING_TRANSACTION;

PROCEDURE UPDATE_PENDING_TRANSACTION
( p_api_version      IN  NUMBER
, p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE
, p_commit           IN  VARCHAR2 := FND_API.G_FALSE
, p_validation_level IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL
, p_tran_rec         IN  GMI_TRANS_ENGINE_PUB.ictran_rec
, x_tran_row         OUT NOCOPY IC_TRAN_PND%ROWTYPE
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY NUMBER
, x_msg_data         OUT NOCOPY VARCHAR2
)
IS
  l_api_name           CONSTANT VARCHAR2 (30) := 'UPDATE_PENDING_TRANSACTION';
  l_api_version        CONSTANT NUMBER        := 1.0;
  l_tran_rec           GMI_TRANS_ENGINE_PUB.ictran_rec;
  l_tran_fetch_rec     GMI_TRANS_ENGINE_PUB.ictran_rec;
  l_msg_count          NUMBER  :=0;
  l_return_val         NUMBER  :=0;
  l_retry_flag         NUMBER  :=1;
  l_msg_data           VARCHAR2(2000);
  l_return_status      VARCHAR2(1);
  l_trans_id           IC_TRAN_PND.TRANS_ID%TYPE;
  l_tran_row           IC_TRAN_PND%ROWTYPE;
  l_old_qc_grade       VARCHAR2(4);
  l_new_qc_grade       VARCHAR2(4);
BEGIN
  /*  Standard Start OF API savepoint */
  SAVEPOINT update_pending_transaction;

  /*  Initialize API return status to sucess */
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /*  Move transaction Table record to local */
  l_tran_rec    := p_tran_rec;

  IF p_validation_level = FND_API.G_VALID_LEVEL_FULL
  THEN
    SET_DEFAULTS
    (  p_tran_rec => p_tran_rec
      ,x_tran_rec => l_tran_rec
    );
  END IF;

  /*  Validate Trans Date For Posting Into Closed Periods. */

  IF NOT CLOSE_PERIOD_CHECK
    ( p_tran_rec   => l_tran_rec,
      p_retry_flag => l_retry_flag,
      x_tran_rec   => l_tran_rec
    )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;



  IF l_tran_rec.non_inv = 0
  THEN
    /*  Get Previous Transaction Using Input Tran rec. */

    IF NOT GMI_TRAN_PND_DB_PVT.FETCH_IC_TRAN_PND
      ( p_tran_rec => l_tran_rec, x_tran_fetch_rec => l_tran_fetch_rec )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /*  Compare the old tran rec QC_GRADE AND WHSE_CODE */
    /*  to determine If we are still updating same RECORD */
    /*  or we have changed record charateristics. */

    /* Add Following To Get NULL QC_GRADE Logic */
    l_old_qc_grade := NVL(l_tran_fetch_rec.qc_grade,FND_API.g_miss_char);
    l_new_qc_grade := NVL(l_tran_fetch_rec.qc_grade,FND_API.g_miss_char);

    IF l_tran_fetch_rec.whse_code <> l_tran_rec.whse_code
    OR l_old_qc_grade <> l_new_qc_grade
    THEN
      /*  Negate Out Previous Transactions  */
      l_tran_fetch_rec.trans_qty  := l_tran_fetch_rec.trans_qty  * -1;
      l_tran_fetch_rec.trans_qty2 := l_tran_fetch_rec.trans_qty2 * -1;

      /*   Reset OLD Demand  */

 /* ***********************************************************
    Jalaj Srivastava Bug 2519568
    Removed DML code for ic_summ_inv since, now ic_summ_inv is
    a view created from the data in ic_loct_inv and ic_tran_pnd
    *********************************************************** */

    ELSE
      /*  Update Previous Demand  */

      l_tran_fetch_rec.trans_qty  := l_tran_rec.trans_qty
                                  - l_tran_fetch_rec.trans_qty;
      l_tran_fetch_rec.trans_qty2 := l_tran_rec.trans_qty2
                                  - l_tran_fetch_rec.trans_qty2;


   END IF;
  END IF;

  /*  Call the IC_TRAN_PND INSERT procedure to insert this record. */
  /*  Call Create_pending_transaction to build ic_tran_pnd%rowtype; */

  PENDING_TRANSACTION_BUILD
  ( p_tran_rec           => l_tran_rec
  , x_tran_row           => l_tran_row
  , x_return_status      => l_return_status
  );


  IF NOT GMI_TRAN_PND_DB_PVT.UPDATE_IC_TRAN_PND
    ( p_tran_row => l_tran_row)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  /* Standard Check of p_commit. */
  IF FND_API.to_boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;

  x_tran_row := l_tran_row;

  x_return_status := l_return_status;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_pending_transaction;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_pending_transaction;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );
    WHEN OTHERS THEN
      ROLLBACK TO update_pending_transaction;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );
END UPDATE_PENDING_TRANSACTION;

PROCEDURE UPDATE_PENDING_TO_COMPLETED
( p_api_version      IN  NUMBER
, p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE
, p_commit           IN  VARCHAR2 := FND_API.G_FALSE
, p_validation_level IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL
, p_tran_rec         IN  GMI_TRANS_ENGINE_PUB.ictran_rec
, x_tran_row         OUT NOCOPY IC_TRAN_PND%ROWTYPE
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY NUMBER
, x_msg_data         OUT NOCOPY VARCHAR2
)
IS
  l_api_name           CONSTANT VARCHAR2 (30) := 'UPDATE_PENDING_TO_TRANSACTION';
  l_api_version        CONSTANT NUMBER        := 1.0;
  l_tran_rec           GMI_TRANS_ENGINE_PUB.ictran_rec;
  l_tran_fetch_rec     GMI_TRANS_ENGINE_PUB.ictran_rec;
  l_msg_count          NUMBER  :=0;
  l_return_val         NUMBER  :=0;
  l_retry_flag         NUMBER  :=0;
  l_msg_data           VARCHAR2(2000);
  l_return_status      VARCHAR2(1);
  l_trans_id           IC_TRAN_PND.TRANS_ID%TYPE;
  l_tran_row           IC_TRAN_PND%ROWTYPE;
  -- TKW B3415691 (Pls refer to 3599127)
  l_item_mst_rec       ic_item_mst%ROWTYPE;

  /* TKW B3415691 - Enhancement for Serono (Pls refer to B3599127) */
  /* Added two cursors to get lot_status and qc_grade */
  CURSOR Cur_lot_status(
	v_item_id IN NUMBER,
	v_whse IN VARCHAR2,
	v_lot_id IN NUMBER,
	v_location IN VARCHAR2) IS
  SELECT
	lot_status
  FROM
	ic_loct_inv
  WHERE
	item_id = v_item_id
	AND whse_code = v_whse
	AND lot_id = v_lot_id
	AND location = v_location;

  CURSOR Cur_qc_grade(v_lot_id IN NUMBER) IS
  SELECT
	DECODE(i.lot_id, 0, NULL, m.qc_grade)
  FROM
	ic_loct_inv i,
	ic_lots_mst m
  WHERE
	m.lot_id = i.lot_id
	AND i.lot_id = v_lot_id;

BEGIN
  /* Standard Start OF API savepoint */
  SAVEPOINT complete_pending_transaction;

  /* Initialize API return status to sucess */
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /* 1.Move transaction Table record to local */
  l_tran_rec    := p_tran_rec;

  IF p_validation_level = FND_API.G_VALID_LEVEL_FULL
  THEN
    SET_DEFAULTS
    (
       p_tran_rec => p_tran_rec
      ,x_tran_rec => l_tran_rec
    );

  END IF;

  /* Validate Trans Date For Posting Into Closed Periods. */


  IF NOT CLOSE_PERIOD_CHECK
    ( p_tran_rec   => l_tran_rec,
      p_retry_flag => l_retry_flag,
      x_tran_rec   => l_tran_rec
    )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  IF l_tran_rec.non_inv = 0
  THEN
    /* Get Previous Transaction Using Input Tran rec. */

    IF NOT GMI_TRAN_PND_DB_PVT.FETCH_IC_TRAN_PND
      (
        p_tran_rec         => l_tran_rec,
        x_tran_fetch_rec   => l_tran_fetch_rec
      )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /*  Negate Out Previous Transactions  */

    l_tran_fetch_rec.trans_qty  := l_tran_fetch_rec.trans_qty  * -1;
    l_tran_fetch_rec.trans_qty2 := l_tran_fetch_rec.trans_qty2 * -1;

    /*  Reset OLD Demand  */

 /* ***********************************************************
    Jalaj Srivastava Bug 2519568
    Removed DML code for ic_summ_inv since, now ic_summ_inv is
    a view created from the data in ic_loct_inv and ic_tran_pnd
    *********************************************************** */

    GMI_LOCT_INV_PVT.UPDATING_IC_LOCT_INV
    (
       p_tran_rec      => l_tran_rec,
       x_return_status =>l_return_status
    );

    /* if errors were found then Raise Exception  */

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  END IF;

  /* TKW B3415691 - Enhancement for Serono (Pls refer to B3599127) */
  /* Added code to ensure the completed transaction reflected
     the lot status and qc grade of the lot in ic_loct_inv
     at the time the transaction took place */
  l_item_mst_rec.item_id := l_tran_rec.item_id;
  IF NOT gmivdbl.ic_item_mst_select (
	p_ic_item_mst_row     => l_item_mst_rec,
	x_ic_item_mst_row     => l_item_mst_rec
  ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (l_item_mst_rec.status_ctl > 0 ) THEN
	OPEN Cur_lot_status(
		l_tran_rec.item_id,
		l_tran_rec.whse_code,
		l_tran_rec.lot_id,
		l_tran_rec.location);
	FETCH Cur_lot_status INTO l_tran_rec.lot_status;
	CLOSE Cur_lot_status;
  END IF;

  IF (l_item_mst_rec.grade_ctl > 0 ) THEN
	OPEN Cur_qc_grade(l_tran_rec.lot_id);
	FETCH Cur_qc_grade INTO l_tran_rec.qc_grade;
	CLOSE Cur_qc_grade;
  END IF;

  /* Call Create_pending_transaction to build ic_tran_pnd%rowtype; */

  COMPLETED_TRANSACTION_BUILD
  ( p_tran_rec           => l_tran_rec
  , x_tran_row           => l_tran_row
  , x_return_status      => l_return_status
  );

  IF NOT GMI_TRAN_PND_DB_PVT.UPDATE_IC_TRAN_PND ( p_tran_row => l_tran_row)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  /* Standard Check of p_commit.*/
  IF FND_API.to_boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;

  x_tran_row := l_tran_row;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO complete_pending_transaction;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO complete_pending_transaction;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );
    WHEN OTHERS THEN
      ROLLBACK TO complete_pending_transaction;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

END UPDATE_PENDING_TO_COMPLETED;


PROCEDURE PENDING_TRANSACTION_BUILD
( p_tran_rec           IN  GMI_TRANS_ENGINE_PUB.ictran_rec
, x_tran_row           OUT NOCOPY IC_TRAN_PND%ROWTYPE
, x_return_status      OUT NOCOPY VARCHAR2
)
IS
  l_return_status VARCHAR2(1) :=FND_API.G_RET_STS_SUCCESS;
  l_tran_row         IC_TRAN_PND%ROWTYPE;
BEGIN
  x_tran_row.trans_id      	:= p_tran_rec.trans_id;
  x_tran_row.item_id       	:= p_tran_rec.item_id;
  x_tran_row.line_id       	:= p_tran_rec.line_id;
  x_tran_row.co_code 	    	:= p_tran_rec.co_code;
  x_tran_row.orgn_code     	:= p_tran_rec.orgn_code;
  x_tran_row.whse_code     	:= p_tran_rec.whse_code;
  x_tran_row.lot_id        	:= NVL(p_tran_rec.lot_id,0);
  x_tran_row.location      	:= NVL(p_tran_rec.location,
                                     GMIGUTL.IC$DEFAULT_LOCT);
  x_tran_row.doc_type       	:= p_tran_rec.doc_type;
  x_tran_row.doc_id       	:= p_tran_rec.doc_id;
  x_tran_row.doc_line      	:= NVL(p_tran_rec.doc_line,0);
  x_tran_row.line_type      	:= NVL(p_tran_rec.line_type,0);
  x_tran_row.creation_date   	:= SYSDATE;
  x_tran_row.trans_date      	:= NVL(p_tran_rec.trans_date,SYSDATE);
  x_tran_row.trans_qty      	:= p_tran_rec.trans_qty;
  x_tran_row.trans_qty2      	:= p_tran_rec.trans_qty2;
  x_tran_row.qc_grade    	:= p_tran_rec.qc_grade;
  x_tran_row.lot_status    	:= p_tran_rec.lot_status;
  x_tran_row.trans_stat    	:= p_tran_rec.trans_stat;
  x_tran_row.trans_um      	:= p_tran_rec.trans_um;
  x_tran_row.trans_um2      	:= p_tran_rec.trans_um2;
  x_tran_row.op_code      	:= p_tran_rec.user_id;
  x_tran_row.completed_ind   	:= 0; /* Always 0 For Pending */
  x_tran_row.staged_ind      	:= p_tran_rec.staged_ind;
  x_tran_row.gl_posted_ind   	:= 0; /* Always 0 */
  x_tran_row.event_id      	:= NVL(p_tran_rec.event_id,0);
  x_tran_row.delete_mark     	:= 0; /* Always 0 */
  x_tran_row.text_code      	:= p_tran_rec.text_code;
  x_tran_row.last_update_date	:= SYSDATE;
  x_tran_row.last_updated_by 	:= p_tran_rec.user_id;
  x_tran_row.created_by    	:= p_tran_rec.user_id;
  x_tran_row.line_detail_id     := NVL(p_tran_rec.line_detail_id,NULL);
  /*================================================
     Joe DiIorio 10/22/2001 11.5.1H BUG#2064443
     Added reason code assigment.
    =============================================*/
  x_tran_row.reason_code        := p_tran_rec.reason_code;
  /*============================================
    BUG#3090255 Populated intorder_posted_ind
   ==========================================*/
  x_tran_row.intorder_posted_ind := NVL(p_tran_rec.intorder_posted_ind,0);
  x_return_status := l_return_status;

EXCEPTION
   WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               ,'PENDING_TRANSACTION_BUILD'
                              );


END PENDING_TRANSACTION_BUILD;

PROCEDURE COMPLETED_TRANSACTION_BUILD
( p_tran_rec           IN  GMI_TRANS_ENGINE_PUB.ictran_rec
, x_tran_row           OUT NOCOPY IC_TRAN_PND%ROWTYPE
, x_return_status      OUT NOCOPY VARCHAR2
)
IS
l_return_status VARCHAR2(1) :=FND_API.G_RET_STS_SUCCESS;
l_tran_row         IC_TRAN_PND%ROWTYPE;

BEGIN

x_tran_row.trans_id      	:= p_tran_rec.trans_id;
x_tran_row.item_id       	:= p_tran_rec.item_id;
x_tran_row.line_id       	:= p_tran_rec.line_id;
x_tran_row.co_code 	    	     := p_tran_rec.co_code;
x_tran_row.orgn_code     	:= p_tran_rec.orgn_code;
x_tran_row.whse_code     	:= p_tran_rec.whse_code;
x_tran_row.lot_id        	:= NVL(p_tran_rec.lot_id,0);
x_tran_row.location      	:= NVL(p_tran_rec.location,
                                       GMIGUTL.IC$DEFAULT_LOCT);
x_tran_row.doc_type       	:= p_tran_rec.doc_type;
x_tran_row.doc_id       	     := p_tran_rec.doc_id;
x_tran_row.doc_line      	:= NVL(p_tran_rec.doc_line,0);
x_tran_row.line_type      	:= NVL(p_tran_rec.line_type,0);
/* NC 8/16/02 Commenting the below line. There's no need to update the
creation date when completing the pending transaction. The creation_date
should always reflect the date when the transaction is created.The DML
update statement had already been commented in GMI_TRAN_PND_DB_PVT.update_ic_tran_pnd for bug#2385934)
x_tran_row.creation_date     	:= NVL(p_tran_rec.trans_date,SYSDATE);
*/
x_tran_row.trans_date      	:= NVL(p_tran_rec.trans_date,SYSDATE);
x_tran_row.trans_qty      	:= p_tran_rec.trans_qty;
x_tran_row.trans_qty2      	:= p_tran_rec.trans_qty2;
x_tran_row.qc_grade    		:= p_tran_rec.qc_grade;
x_tran_row.lot_status    	:= p_tran_rec.lot_status;
x_tran_row.trans_stat    	:= p_tran_rec.trans_stat;
x_tran_row.trans_um      	:= p_tran_rec.trans_um;
x_tran_row.trans_um2      	:= p_tran_rec.trans_um2;
x_tran_row.op_code      	     := p_tran_rec.user_id;
x_tran_row.completed_ind     	:= 1; /* Always 1 For Completed */
x_tran_row.staged_ind      	:= p_tran_rec.staged_ind;
x_tran_row.gl_posted_ind     	:= 0; /* Always 0 */
x_tran_row.event_id      	:= NVL(p_tran_rec.event_id,0);
x_tran_row.delete_mark      	:= 0; /* NVL(p_tran_rec.delete_mark,0);*/
x_tran_row.text_code      	:= p_tran_rec.text_code;
x_tran_row.last_update_date  	:= SYSDATE;
x_tran_row.last_updated_by   	:= p_tran_rec.user_id;
x_tran_row.created_by    	:= p_tran_rec.user_id;
x_tran_row.line_detail_id       := NVL(p_tran_rec.line_detail_id,NULL);
/*================================================
  Joe DiIorio 10/22/2001 11.5.1H BUG#2064443
  Added reason code assigment.
  =============================================*/
x_tran_row.reason_code          := p_tran_rec.reason_code;
/*============================================
  BUG#3090255 Populated intorder_posted_ind
 ==========================================*/
x_tran_row.intorder_posted_ind := NVL(p_tran_rec.intorder_posted_ind,0);
x_return_status := l_return_status;
/*============================================
  BUG#3526733 Populated reverse_id
  ==========================================*/
x_tran_row.reverse_id           := p_tran_rec.reverse_id;


EXCEPTION
   WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               ,'COMPLETED_TRANSACTION_BUILD'
                              );




END COMPLETED_TRANSACTION_BUILD;

PROCEDURE SET_DEFAULTS
( p_tran_rec           IN   GMI_TRANS_ENGINE_PUB.ictran_rec
, x_tran_rec           OUT  NOCOPY GMI_TRANS_ENGINE_PUB.ictran_rec
)
IS

CURSOR c_get_noninv_ind ( p_item_id IN NUMBER)
IS
SELECT noninv_ind
FROM   ic_item_mst
WHERE  item_id = p_item_id;

l_noninv  NUMBER;

BEGIN
/* This Procedure will default Values Into Rec Type  */
/* If declared as NULL: */

  x_tran_rec := p_tran_rec;

  IF p_tran_rec.trans_date is NULL THEN
     x_tran_rec.trans_date :=SYSDATE;
  END IF;

  IF p_tran_rec.user_id is NULL THEN
     x_tran_rec.user_id   :=FND_GLOBAL.user_id;
  END IF;
  --Jalaj Srivastava Bug 2483644
  --C routines were using non_inv as 2 for grade txns
  --that is no longer required as the code will check for
  --GRDI, GRDR doc type
  --this is only for records created before PL/SQL APIs
  --were used for posting the journals.
  IF (p_tran_rec.non_inv is NULL OR p_tran_rec.non_inv = 2) THEN
     -- derive the value
     -- H Verdding Bug 2025933

     OPEN  c_get_noninv_ind(p_tran_rec.item_id);
     FETCH c_get_noninv_ind INTO l_noninv;
     CLOSE c_get_noninv_ind;

     x_tran_rec.non_inv   := l_noninv;

  END IF;

  IF p_tran_rec.staged_ind is NULL THEN
     x_tran_rec.staged_ind :=0;
  END IF;

  IF p_tran_rec.trans_qty2 = FND_API.G_MISS_NUM THEN
     x_tran_rec.trans_qty2 := NULL;
  END IF;

END SET_DEFAULTS;


FUNCTION CLOSE_PERIOD_CHECK
(
 p_tran_rec        IN GMI_TRANS_ENGINE_PUB.ictran_rec,
 p_retry_flag      IN NUMBER,
 x_tran_rec        IN OUT NOCOPY GMI_TRANS_ENGINE_PUB.ictran_rec
)
RETURN BOOLEAN
IS

l_return_val       NUMBER :=0;
l_tran_rec         GMI_TRANS_ENGINE_PUB.ictran_rec;

BEGIN

/* This is a Encapsulated version of the period close
   validaton routine that exists in GMI, it currently only
   returns a number rather that populating the message stack
   I will only check for and report closed period posting
   of transactions. However we can add other validations later
   when required.
*/

  /* Assume that all values for Rec are correct , this is validated
     in the public layer */

  l_tran_rec := p_tran_rec;

  /* Validate Trans Date For Posting Into Closed Periods */


  l_return_val := GMICCAL.trans_date_validate (  l_tran_rec.trans_date,
                                                 l_tran_rec.orgn_code,
                                                 l_tran_rec.whse_code
                                                );

 /*==============================================
  Thomas Daniel 04/17/2002 11.5.1I BUG#2322973
  Only check for the sysdate if the calendar is
  closed for the trans date passed in
  ============================================*/
  IF (l_return_val IN (GMICCAL.INVCAL_PERIOD_CLOSED,
                       GMICCAL.INVCAL_WHSE_CLOSED)) THEN


    IF p_retry_flag = 1 THEN

      -- Set the trans date to sysdate and re-try

      l_tran_rec.trans_date := SYSDATE;

      l_return_val := GMICCAL.trans_date_validate
                      (l_tran_rec.trans_date,
                       l_tran_rec.orgn_code,
                       l_tran_rec.whse_code
                      );
    END IF;

  END IF;

  IF l_return_val <> 0 THEN
    /*==============================================
    Thomas Daniel 04/17/2002 11.5.1I BUG#2322973
    Added specific messages for each return from
    the calendar validation.
    ============================================*/
    IF l_return_val = GMICCAL.INVCAL_FISCALYR_ERR THEN
      FND_MESSAGE.SET_NAME('GMI','IC_CAL_FISCALYR_ERR');
      FND_MSG_PUB.Add;
    ELSIF l_return_val = GMICCAL.INVCAL_PERIOD_ERR THEN
      FND_MESSAGE.SET_NAME('GMI','IC_CAL_CLOSED_IND_ERR');
      FND_MSG_PUB.Add;
    ELSIF l_return_val = GMICCAL.INVCAL_ORGN_PARM_ERR THEN
      FND_MESSAGE.SET_NAME('GMI','IC_INVALID_ORGN_ERR');
      FND_MSG_PUB.Add;
    ELSIF l_return_val = GMICCAL.INVCAL_CO_ERR THEN
      FND_MESSAGE.SET_NAME('GMI','IC_COCODEERR');
      FND_MSG_PUB.Add;
    ELSIF l_return_val = GMICCAL.INVCAL_WHSE_PARM_ERR THEN
      FND_MESSAGE.SET_NAME('GMI','IC_BLANKWHSE');
      FND_MSG_PUB.Add;
    ELSIF l_return_val = GMICCAL.INVCAL_WHSE_ERR THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_WHSE_CODE');
      FND_MESSAGE.SET_TOKEN('WHSE_CODE',l_tran_rec.whse_code);
      FND_MSG_PUB.Add;
    ELSIF l_return_val IN (GMICCAL.INVCAL_PERIOD_CLOSED,
                           GMICCAL.INVCAL_WHSE_CLOSED) THEN
      /*==============================================
        Joe DiIorio 04/08/2002 11.5.1I BUG#2248778
        ============================================*/
      FND_MESSAGE.SET_NAME('GMI','IC_API_TXN_POST_CLOSED');
      FND_MESSAGE.SET_TOKEN('DATE',l_tran_rec.trans_date);
      FND_MESSAGE.SET_TOKEN('WAREH',l_tran_rec.whse_code);
      FND_MSG_PUB.Add;
    ELSE
      FND_MESSAGE.SET_NAME('GMI','ICCAL_GENL_ERR');
      FND_MSG_PUB.Add;
    END IF;

    RETURN FALSE;
  END IF;

  x_tran_rec := l_tran_rec;

  RETURN TRUE;

EXCEPTION

    WHEN OTHERS THEN

          FND_MESSAGE.SET_NAME('GMI','UNEXPECTED ERROR CHECK MISSING');

         RETURN FALSE;


END  close_period_check;



END GMI_TRANS_ENGINE_PVT;

/
