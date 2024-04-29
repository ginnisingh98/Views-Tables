--------------------------------------------------------
--  DDL for Package Body GMI_PICK_CONFIRM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_PICK_CONFIRM_PUB" AS
/*  $Header: GMIPCAPB.pls 115.6 2004/03/11 19:23:36 nchekuri noship $ */
/* +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMIPPWCB.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains public procedures relating to GMI             |
 |     Pick  Confirmation.                                                 |
 |                                                                         |
 |                                                                         |
 | HISTORY                                                                 |
 |     20-NOV-2002  nchekuri 	Created					   |
 |                                                                         |
 |                                                                         |
 +=========================================================================+

  API Name  : GMI_PICK_CONFIRM_PUB
  Type      : Public Package Body
  Function  : This package contains Public Utilities used for
              the Pick Confirm process.
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0
*/

/* Global variables  */
G_PKG_NAME  CONSTANT  VARCHAR2(30) :='GMI_PICK_CONFIRM_PUB';
G_DEBUG_FILE_LOCATION VARCHAR2(255):= NULL;


/* ========================================================================*/
/***************************************************************************/
/*
|    PARAMETERS:
|             p_api_version          Known api version
|             p_init_msg_list        FND_API.G_TRUE to reset list
|             p_commit               Commit flag. API commits if this is set.
| 	      p_mo_line_id	     Move order line id to pick confirm
|	      p_delivery_detail_id   Delivery detail id to pick confirm
|             x_return_status        Return status
|             x_msg_count            Number of messages in the list
|             x_msg_data             Text of messages
|
|     VERSION   : current version         1.0
|                 initial version         1.0
|     COMMENT   : Pick confirms a Move order line or a delivery detail line.

|
|     Notes :
|       --      If move order line is passed all the delivery details that belong
|	        to the move order are pick confirmed.
|	--      If a delivery detail line is passed only that delivery detail is
|		pick confirmed.
|
****************************************************************************
| ========================================================================  */


PROCEDURE PICK_CONFIRM
  (
     p_api_version           IN  NUMBER
   , p_init_msg_list         IN  VARCHAR2
   , p_commit                IN  VARCHAR2
   , p_mo_line_id            IN  NUMBER
   , p_delivery_detail_id    IN  NUMBER
   , p_bk_ordr_if_no_alloc   IN  VARCHAR2   -- Bug 3274586
   , x_return_status         OUT NOCOPY VARCHAR2
   , x_msg_count             OUT NOCOPY NUMBER
   , x_msg_data              OUT NOCOPY VARCHAR2
  )
 IS


-- Standard constants to be used to check for call compatibility.
l_api_version  	CONSTANT        NUMBER          := 1.0;
l_api_name      CONSTANT        VARCHAR2(30):= 'PICK_CONFIRM';


-- Local Variables.

l_mo_line_row       ic_txn_request_lines%ROWTYPE;
l_mo_line_rec	    GMI_MOVE_ORDER_GLOBAL.mo_line_rec;
ll_mo_line_rec	    GMI_MOVE_ORDER_GLOBAL.mo_line_rec;
l_mo_line_tbl       GMI_MOVE_ORDER_GLOBAL.mo_line_tbl;
-- HW BUG#:3142323
ll_mo_line_tbl       GMI_MOVE_ORDER_GLOBAL.mo_line_tbl;

l_count    NUMBER := 0;

l_ship_from_org_id      NUMBER;
l_inventory_item_id	NUMBER;
l_default_lot		VARCHAR2(32);
l_default_loct	        VARCHAR2(32);
l_ic_item_mst_rec	ic_item_mst_b%ROWTYPE;
l_ic_whse_mst_rec	ic_whse_mst%ROWTYPE;

l_loct_ctl              NUMBER;

-- Exceptions
l_warning		EXCEPTION;

  CURSOR move_order_line_cur(p_mo_line_id NUMBER) IS
  SELECT *
    FROM ic_txn_request_lines
   WHERE line_id = p_mo_line_id;

  CURSOR move_order_line_cur2(p_delivery_detail_id NUMBER) IS
  SELECT ic.*
    FROM wsh_delivery_details wsh,
         ic_txn_request_lines ic
   WHERE ic.line_id = wsh.move_order_line_id
     AND wsh.delivery_detail_id = p_delivery_detail_id;

  -- Bug 3274586
  CURSOR get_whse_code_dtl (p_organization_id IN NUMBER) IS
  SELECT *
    FROM ic_whse_mst
   WHERE mtl_organization_id= p_organization_id;

  CURSOR trans_with_no_default_cur(p_line_id NUMBER
					,p_mo_line_id NUMBER) IS
  SELECT count(*)
    FROM ic_tran_pnd
   WHERE delete_mark   = 0
     AND completed_ind = 0
     AND staged_ind    = 0
     AND (lot_id <> 0 OR location <> l_default_loct)
     AND doc_type      = 'OMSO'
     AND line_id       = p_line_id
     AND line_detail_id in (
         SELECT delivery_detail_id
           FROM wsh_delivery_details
          WHERE move_order_line_id = p_mo_line_id);

  CURSOR trans_with_default_cur(p_line_id NUMBER)IS
  SELECT count(*)
    FROM ic_tran_pnd
   WHERE delete_mark   = 0
     AND completed_ind = 0
     AND staged_ind    = 0
     AND doc_type      = 'OMSO'
     AND line_id       = p_line_id;

 BEGIN
    /*Init variables
    =========================================*/
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_default_lot := FND_PROFILE.VALUE('IC$DEFAULT_LOT');
   l_default_loct := FND_PROFILE.VALUE('IC$DEFAULT_LOCT');


   /* Standard begin of API savepoint
   ===========================================*/
   SAVEPOINT Pick_Confirm_SP;


   /*Standard call to check for call compatibility.
      ==============================================*/

   IF NOT FND_API.compatible_api_call (
                                l_api_version,
                                p_api_version,
                                l_api_name,
                                G_PKG_NAME)
   THEN
      PrintMsg('FND_API.compatible_api_call failed');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   /* Check p_init_msg_list
    =========================================*/
   IF FND_API.to_boolean(p_init_msg_list)
   THEN
      FND_MSG_PUB.initialize;
   END IF;



   /* Print the input parameters to the Debug File
    ==============================================*/

    PrintMsg('The Input Parameters are :  ');
    PrintMsg('=========================   ');
    PrintMsg('  p_api_version           : '||p_api_version);
    PrintMsg('  p_init_msg_list         : '||p_init_msg_list);
    PrintMsg('  p_commit                : '||p_commit);
    PrintMsg('  p_mo_line_id            : '||p_mo_line_id);
    PrintMsg('  p_delivery_detail_id    : '||p_delivery_detail_id);
    PrintMsg('=========================   ');
    PrintMsg('   ');

    /*====================================
      Validations
    ======================================*/

    /* Mo_line_id
    ==============*/
    /* If Move Order Line Id is passed then See if there's atleast one
       delivery that has the status 'S'- 'Released to Warehouse' */

    IF( NVL(p_mo_line_id,0) <> 0 )
    THEN

       OPEN move_order_line_cur(p_mo_line_id);
       FETCH move_order_line_cur INTO l_mo_line_row;

       IF(move_order_line_cur%NOTFOUND )
       THEN
          CLOSE move_order_line_cur;
	  PrintMsg('No move order line found for this mo_line_id : '||
					p_mo_line_id);
	  FND_MESSAGE.SET_NAME('GMI','GMI_API_INVALID_MO_LINE_ID');
	  FND_MESSAGE.SET_TOKEN('MO_LINE_ID ',p_mo_line_id );
	  FND_MSG_PUB.Add;
	  RAISE FND_API.G_EXC_ERROR;
       END IF;

       CLOSE move_order_line_cur;
    /* Else see if delivery line is passed */
    ELSIF( NVL(p_delivery_detail_id,0) <> 0)
    THEN

       OPEN move_order_line_cur2(p_delivery_detail_id);
       FETCH move_order_line_cur2 INTO l_mo_line_row;

       IF(move_order_line_cur2%NOTFOUND )
       THEN
	  PrintMsg('ERROR: No move order line found for this delivery_detail_id : '||
					p_delivery_detail_id);
          CLOSE move_order_line_cur2;
	  FND_MESSAGE.SET_NAME('GMI','GMI_API_INVALID_DEL_DETAIL_ID');
	  FND_MESSAGE.SET_TOKEN('DEL_DETAIL_ID',p_delivery_detail_id );
	  FND_MSG_PUB.Add;
	  RAISE FND_API.G_EXC_ERROR;
       END IF;
       CLOSE move_order_line_cur2;
    /* Neither the move order nor the delivery detail is passed */
    ELSE
       PrintMsg('ERROR: No move order line or delivery delivery detail line is passed ');
       FND_MESSAGE.SET_NAME('GMI','GMI_API_NO_INPUT_LINE_ID');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
    END IF;


   -- Get OPM Item Id from  Inventory_item_id

   GMI_OM_ALLOC_API_PUB.Get_Item_Details(
           p_organization_id          => l_mo_line_row.organization_id
         , p_inventory_item_id        => l_mo_line_row.inventory_item_id
         , x_ic_item_mst_rec          => l_ic_item_mst_rec
         , x_return_status            => x_return_status
         , x_msg_count                => x_msg_count
         , x_msg_data                 => x_msg_data) ;


   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
   THEN
      PrintMsg('ERROR - Get Item Details returned Error ');
      FND_MESSAGE.Set_Name('GMI','GMI_API_ITEM_NOT_FOUND');
      FND_MESSAGE.Set_Token('INVENTORY_ITEM_ID', l_mo_line_row.organization_id);
      FND_MESSAGE.Set_Token('ORGANIZATION_ID', l_mo_line_row.inventory_item_id);
      FND_MESSAGE.Set_Token('LINE_ID', l_mo_line_row.line_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   /* Print the Item Details */

    PrintMsg('The Item Details :  '   );
    PrintMsg('=========================   ');
    PrintMsg('  item_no           : '||l_ic_item_mst_rec.item_no);
    PrintMsg('  item_id           : '||l_ic_item_mst_rec.item_id);
    PrintMsg('  lot_ctl           : '||l_ic_item_mst_rec.lot_ctl);
    PrintMsg('  loct_ctl          : '||l_ic_item_mst_rec.loct_ctl);
    PrintMsg('========================= ');
    PrintMsg('   ');

    -- Bug 3274586
    OPEN  get_whse_code_dtl (l_mo_line_row.organization_id);
    FETCH get_whse_code_dtl into l_ic_whse_mst_rec;
    IF( get_whse_code_dtl%NOTFOUND )
    THEN
       CLOSE get_whse_code_dtl;
       PrintMsg('ERROR - Warehouse does not exist ');
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE get_whse_code_dtl;

    PrintMsg('The Warehouse Details :  '   );
    PrintMsg('=========================   ');
    PrintMsg('  whse_code         : '||l_ic_whse_mst_rec.whse_code);
    PrintMsg('  loct_ctl          : '||l_ic_whse_mst_rec.loct_ctl);
    PrintMsg('========================= ');
    PrintMsg('   ');

    l_loct_ctl := nvl(l_ic_item_mst_rec.loct_ctl,0) * nvl(l_ic_whse_mst_rec.loct_ctl,0);

    PrintMsg('Lot ctl: '|| l_ic_item_mst_rec.lot_ctl ||' Effective location ctl: '||l_loct_ctl);

   IF (l_ic_item_mst_rec.lot_ctl = 0 AND l_loct_ctl = 0)
   THEN
      PrintMsg('No control or non inventory item situation');
      OPEN  trans_with_default_cur(l_mo_line_row.txn_source_line_id);
      FETCH trans_with_default_cur INTO l_count;

      IF( trans_with_default_cur%NOTFOUND )
      THEN
         CLOSE trans_with_default_cur;
         PrintMsg('ERROR - trans_with_default_cur failed ');
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE trans_with_default_cur;

   ELSE
      PrintMsg('Either lot control or location control situation');
      /* Either lot or location controlled condition */
      OPEN trans_with_no_default_cur(l_mo_line_row.txn_source_line_id,l_mo_line_row.line_id);
      FETCH trans_with_no_default_cur INTO l_count;

      IF( trans_with_no_default_cur%NOTFOUND )
      THEN
         CLOSE trans_with_no_default_cur;
         PrintMsg('ERROR - trans_with_no_default_cur failed ');
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE trans_with_no_default_cur;

   END IF;

   /* If there are no allocations, Nothing to pick confirm */

   PrintMsg('Number of applicable allocations: '||l_count);

   -- Bug 3274586 - Use the parameter value p_bk_ordr_if_no_alloc to bypass the allocations
   --               exist check.
   PrintMsg('p_bk_ordr_if_no_alloc: '||p_bk_ordr_if_no_alloc);

   IF( l_count = 0) AND (UPPER(p_bk_ordr_if_no_alloc) <> 'Y')
   THEN
      PrintMsg('ERROR - No applicable allocations for mo_line_id : '||l_mo_line_row.line_id
				    ||' and delivery_detail_id : '||p_delivery_detail_id );
      FND_MESSAGE.Set_Name('GMI','GMI_API_NO_ALLOCATIONS');
      FND_MESSAGE.Set_Token('MO_LINE_ID', l_mo_line_row.line_id);
      FND_MESSAGE.Set_Token('DELIVERY_DETAIL_ID', p_delivery_detail_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   /*  Get The Move Order line (1 line)  in to l_mo_line_tbl(1)
       This has to be done 'coz the pvt expects mo_line_tbl */

   PrintMsg('Before - Query the move order line');

   l_mo_line_tbl(1) := GMI_MOVE_ORDER_LINE_UTIL.Query_Row( l_mo_line_row.line_id);

   PrintMsg('Before lock move order row');

   GMI_MOVE_ORDER_LINE_UTIL.Lock_Row(
        p_mo_line_rec   => l_mo_line_tbl(1)
      , x_mo_line_rec   => ll_mo_line_rec
      , x_return_status => x_return_status);

    PrintMsg('status from lock row'||x_return_status);

   IF ( x_return_status = '54' )
   THEN
      PrintMsg('ERROR : Pick_Confirm : the MO is locked for line_id= '|| l_mo_line_row.line_id);
      FND_MESSAGE.Set_Name('GMI','GMI_API_MO_LINE_LOCKED');
      FND_MESSAGE.Set_Token('MO_LINE_ID', l_mo_line_row.line_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;


/*  Check That we have at least one Move Order Line Rec   */

  IF ( l_mo_line_tbl.count = 0 )
  THEN
      PrintMsg('No rows to pick confirm');
      FND_MESSAGE.SET_NAME('GMI', 'GMI_API_NO_LINES_TO_PICK_CONF');
      FND_MESSAGE.Set_Token('MO_LINE_ID', l_mo_line_row.line_id);
      FND_MESSAGE.Set_Token('DELIVERY_DETAIL_ID', p_delivery_detail_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  PrintMsg('Before calling GMI_PICK_WAVE_CONFIRM_PVT.PICK_CONFIRM');

-- HW BUG#:3142323 changed l_mo_line_tbl  to ll_mo_line_tbl
-- NC Bug#3483078 send p_commit as FALSE and commit after the call depending on the return status
  GMI_PICK_WAVE_CONFIRM_PVT.PICK_CONFIRM
  (
     p_api_version_number  => p_api_version
   , p_init_msg_lst        => p_init_msg_list
   , p_commit              => FND_API.G_FALSE
   , p_delivery_detail_id  => p_delivery_detail_id
   , p_mo_LINE_tbl         => l_mo_line_tbl
   , x_mo_LINE_tbl         => ll_mo_line_tbl
   , x_return_status       => x_return_status
   , x_msg_count           => x_msg_count
   , x_msg_data            => x_msg_data
  );

  /* Commit if p_commit is set to true and return_status is not error */
  IF(p_commit = FND_API.G_TRUE AND x_return_status <>  FND_API.G_RET_STS_ERROR) THEN
    COMMIT;
  END IF;

  IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING )
  THEN
     PrintMsg('WARNING : Returning from Pick_Confirm_Pvt with Warning');
     FND_MESSAGE.SET_NAME('GMI','GMI_API_PICK_CONFIRM_WARNING');
     FND_MESSAGE.SET_TOKEN('MO_LINE_ID',l_mo_line_rec.line_id);
     FND_MESSAGE.SET_TOKEN('DELIVERY_DETAIL_ID',p_delivery_detail_id);
     FND_MSG_PUB.Add;
     RAISE L_WARNING;

  ELSIF (x_return_status <> FND_API.G_RET_STS_SUCCESS )
  THEN
     PrintMsg('ERROR : Returning from Pick_Confirm_Pvt with error');
     FND_MESSAGE.SET_NAME('GMI','GMI_API_PICK_CONFIRM_ERROR');
     FND_MESSAGE.SET_TOKEN('MO_LINE_ID',l_mo_line_rec.line_id);
     FND_MESSAGE.SET_TOKEN('DELIVERY_DETAIL_ID',p_delivery_detail_id);
     FND_MSG_PUB.Add;
     RAISE FND_API.G_EXC_ERROR;
  ELSE
    PrintMsg('SUCCESS : Returning from Pick_Confirm_Pvt with success');
  END IF;



/* EXCEPTION HANDLING
====================*/
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      --ROLLBACK TO SAVEPOINT Pick_Confirm_SP;


      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );
      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       --ROLLBACK TO SAVEPOINT Pick_Confirm_SP;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );
      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );
    WHEN L_WARNING THEN
       --ROLLBACK TO SAVEPOINT Pick_Confirm_SP;
       x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );
      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data);

    WHEN OTHERS THEN
      --ROLLBACK TO SAVEPOINT Pick_Confirm_SP;
      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      /*   Get message count and data */
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );
END Pick_Confirm;

/*--+=========================================================================+
--| PROCEDURE NAME                                                          |
--|    PrintMsg                                                             |
--|                                                                         |
--| USAGE                                                                   |
--|                                                                         |
--| DESCRIPTION                                                             |
--|    Used  Print Debug messages in a log file                             |
--|                                                                         |
--| PARAMETERS                                                              |
--|    p_msg            VARCHAR2  Message text                              |
--|    p_file_name      VARCHAR2  File Name                                 |
--|                                                                         |
--| HISTORY                                                                 |
--|    29-SEP-2002      NC            Created                               |
============================================================================*/

PROCEDURE PrintMsg
   ( p_msg                           IN  VARCHAR2
   , p_file_name                     IN  VARCHAR2
   ) IS

CURSOR get_log_file_location IS
SELECT NVL( SUBSTR( value, 1, instr( value, ',')-1), value)
FROM v$parameter
WHERE name = 'utl_file_dir';

l_log                UTL_FILE.file_type;
l_file_name          VARCHAR2(80);

BEGIN

   IF (p_file_name = '0')
   THEN
      l_file_name := 'PickConfirm';
   ELSE
      l_file_name := p_file_name;
   END IF;

   l_file_name := l_file_name|| USERENV('SESSIONID');

   IF (G_DEBUG_FILE_LOCATION IS NULL) THEN
      OPEN   get_log_file_location;
      FETCH  get_log_file_location into G_DEBUG_FILE_LOCATION;
      CLOSE  get_log_file_location;
   END IF;

   l_log := UTL_FILE.fopen(G_DEBUG_FILE_LOCATION, l_file_name, 'a');

   IF UTL_FILE.IS_OPEN(l_log) THEN
      UTL_FILE.put_line(l_log, p_msg);
      UTL_FILE.fflush(l_log);
      UTL_FILE.fclose(l_log);
   END IF;


EXCEPTION

    WHEN OTHERS THEN
       NULL;

END PrintMsg;

END GMI_PICK_CONFIRM_PUB;

/
