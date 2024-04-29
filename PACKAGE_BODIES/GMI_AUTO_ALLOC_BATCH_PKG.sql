--------------------------------------------------------
--  DDL for Package Body GMI_AUTO_ALLOC_BATCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_AUTO_ALLOC_BATCH_PKG" AS
/* $Header: GMIALLCB.pls 120.1 2005/06/17 15:04:28 appldev  $ */
/* ===========================================================================
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 ===========================================================================
 |  FILENAME                                                               |
 |      GMIALLCB.pls                                                       |
 |                                                                         |
 |  DESCRIPTION                                                            |
 |      This package contains procedures relating to the Enhanced Auto     |
 |      Program                                                            |
 |          --    Auto_allocate_batch                                      |
 |  HISTORY                                                                |
 |       19-AUG-2002  nchekuri        Created                              |
 |                                                                         |
 |                                                                         |
 ===========================================================================
  API Name  : GMI_AUTO_ALLOC_BATCH_PKG
  Type      : Public Package Body
  Function  : This package contains procedures relating to the Enhanced Auto
              Allocation Engine.
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0
*/

/*  Global variables  */
G_PKG_NAME      CONSTANT  VARCHAR2(30):='GMI_AUTO_ALLOC_BATCH_PKG';


/* ========================================================================*/
/***************************************************************************/
/*
|    PARAMETERS:
|             p_api_version          Known api version
|             p_init_msg_list        FND_API.G_TRUE to reset list
|             p_commit               Commit flag. API commits if this is set.
|             x_return_status        Return status
|             x_msg_count            Number of messages in the list
|             x_msg_data             Text of messages
|             p_batch_id             Input batch id
|
|     VERSION   : current version         1.0
|                 initial version         1.0
|     COMMENT   :
|
|
|     Notes :
|
****************************************************************************
| ========================================================================  */




PROCEDURE Auto_Allocate_Batch
(
  errbuf          OUT NOCOPY VARCHAR2
 ,retcode         OUT NOCOPY VARCHAR2
 ,p_api_version   IN  NUMBER
 ,p_init_msg_list IN  VARCHAR2
 ,p_commit        IN  VARCHAR2
 ,p_batch_id      IN  NUMBER
) IS

-- Standard constants to be used to check for call compatibility.
l_api_version   CONSTANT        NUMBER          := 1.0;
l_api_name      CONSTANT        VARCHAR2(30):= 'allocate_opm_orders';

-- Local Variables.
l_msg_count      NUMBER  :=0;
l_msg_data       VARCHAR2(2000);
l_return_status  VARCHAR2(1);

x_msg_count      NUMBER  :=0;
x_msg_data       VARCHAR2(2000);
x_return_status  VARCHAR2(1);

l_wdd_rec        wsh_delivery_details%rowtype;
l_batch_rec      gmi_auto_allocation_batch%rowtype;
l_where_clause   VARCHAR2(3000):= NULL;
l_number_of_rows NUMBER;
l_order_by       VARCHAR2(3000):= NULL;
l_detailed_qty   NUMBER;
l_detailed_qty2  NUMBER;
l_qty_um         VARCHAR2(30);
l_qty_um2        VARCHAR2(30);
l_qc_grade       VARCHAR2(30);
l_ship_to_org_id NUMBER;
l_inventory_item_id NUMBER;
l_temp  BOOLEAN;


CURSOR get_wdd_line_cur(p_delivery_detail_id  IN NUMBER) Is
SELECT  *
FROM  wsh_delivery_details wdd
WHERE wdd.delivery_detail_id = p_delivery_detail_id;

CURSOR Get_Batch_Rec_Cur IS
SELECT *
 FROM  gmi_auto_allocation_batch
WHERE  batch_id = p_batch_id;

TYPE wdd_rc IS REF CURSOR;
wdd_cur1 wdd_rc;

Cursor get_whse_code_cur(p_organization_id IN NUMBER)
IS
Select whse_code
from ic_whse_mst
where mtl_organization_id= p_organization_id;

Cursor get_ship_to_org_cur(p_whse_code IN VARCHAR2)
IS
Select mtl_organization_id
From ic_whse_mst
Where whse_code= p_whse_code;

Cursor get_inventory_item_id_cur(p_item_id IN VARCHAR2)
IS
Select inventory_item_id
From ic_item_mst ic,
     mtl_system_items mtl
     where ic.item_id = p_item_id
 AND mtl.segment1 = ic.item_no;


BEGIN

   /*Int variables
    =========================================*/
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   retcode := x_return_status;

   /* Standard begin of API savepoint
   ===========================================*/
   SAVEPOINT Auto_Allocate_Batch_SP;

   /*Standard call to check for call compatibility.
      ==============================================*/

   IF NOT FND_API.compatible_api_call (
                                l_api_version,
                                p_api_version,
                                l_api_name,
                                G_PKG_NAME)
   THEN
      GMI_RESERVATION_UTIL.PrintLn('FND_API.compatible_api_call failed');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   /* Check p_init_msg_list
    =========================================*/
   IF FND_API.to_boolean(p_init_msg_list)
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   GMI_RESERVATION_UTIL.PrintLn (' After initialize IN Auto_allocation_batch');

   IF( NVL(p_batch_id,0) = 0 ) THEN
      GMI_RESERVATION_UTIL.PrintLn('Batch id is missing');
      FND_MESSAGE.Set_Name('GMI','Missing');
      FND_MESSAGE.Set_Token('MISSING', 'Batch_Id');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   OPEN get_batch_rec_cur;
   FETCH get_batch_rec_cur INTO l_batch_rec;

   IF(get_batch_rec_cur%NOTFOUND) THEN
      CLOSE get_batch_rec_cur;
      GMI_RESERVATION_UTIL.PrintLn('No record in the batch table for batch id: '|| p_batch_id );
      FND_MESSAGE.Set_Name('GMI','Missing');
      FND_MESSAGE.Set_Token('Missing','Batch_id');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   CLOSE get_batch_rec_cur;

   GMI_RESERVATION_UTIL.PrintLn(' After Fetching The Batchrec');

     /* The parameters available for search criteria are order_type,line_no to and from,
        delivery_detail_id to and from , whse_code,item_no, sched_shipdate to and from.
     */
     /* we assume the order(s) that need to be allocated are already pick_released. If
        to/from order_number is supplied then, delivery_detail_id range doesn't exist.
     */
     /* Construct the where clause to fetch the delivery records depending on the input
        parameters
     */


    /* To and From order Numbers */

    l_where_clause := 'Released_status = '||''''||'S'|| '''';  -- Check released_status = 'S' instead of 1 = 1 PK Bug 4025462

    IF( NVL(l_batch_rec.from_order_header_no,0) <> 0 )
    THEN
       l_where_clause := l_where_clause || ' AND source_header_number >= ' ;
       l_where_clause := l_where_clause ||'TO_CHAR(';
       l_where_clause := l_where_clause ||l_batch_rec.from_order_header_no ;
       l_where_clause := l_where_clause || ')';
    END IF;

    IF ( NVL(l_batch_rec.to_order_header_no,0) <> 0)
    THEN
       l_where_clause := l_where_clause || ' AND source_header_number <=  ' ;
       l_where_clause := l_where_clause ||'TO_CHAR(';
       l_where_clause := l_where_clause ||l_batch_rec.to_order_header_no ;
       l_where_clause := l_where_clause || ')';
       --||to_char(l_batch_rec.to_order_header_no) ;
    END IF;

    GMI_RESERVATION_UTIL.PrintLn('1: Where Clause is : ' || l_where_clause);

    /* To and from delivery_detail_ids */

    IF( NVL(l_batch_rec.from_delivery_detail_id,0) <> 0)
    THEN

       l_where_clause := l_where_clause ||
                ' AND delivery_detail_id >= ' || l_batch_rec.to_delivery_detail_id;
    END IF;

    IF ( NVL(l_batch_rec.to_delivery_detail_id,0) <> 0)
    THEN
       l_where_clause := l_where_clause ||
                '  AND delivery_detail_id <=  '|| l_batch_rec.to_delivery_detail_id;
    END IF;

    GMI_RESERVATION_UTIL.PrintLn('2: Where Clause is : ' || l_where_clause);

    /* Order type Id */

    IF ( NVL( l_batch_rec.order_type_id,0) <> 0 )
    THEN
       l_where_clause := l_where_clause ||
                '  AND source_header_type_id = ' ||  l_batch_rec.order_type_id ;
    END IF;

    GMI_RESERVATION_UTIL.PrintLn('3: Where Clause is : ' || l_where_clause);

    /* Sched Ship date */

     IF ( TO_CHAR(l_batch_rec.from_sched_ship_date) <> FND_API.G_MISS_CHAR AND
        TO_CHAR(l_batch_rec.from_sched_ship_date, 'DD-MON-YYYY') <> ' ')
     THEN
       l_where_clause := l_where_clause || ' AND TO_DATE(date_scheduled ';
       l_where_clause := l_where_clause || ',';
       l_where_clause := l_where_clause || '''';
       l_where_clause := l_where_clause || 'DD-MON-YY';
       l_where_clause := l_where_clause || '''';
       l_where_clause := l_where_clause || ')';
       l_where_clause := l_where_clause || '>=';
       l_where_clause := l_where_clause ||'TO_DATE( ';
       l_where_clause := l_where_clause || '''';
       l_where_clause := l_where_clause ||l_batch_rec.from_sched_ship_date;
       l_where_clause := l_where_clause || '''';
       l_where_clause := l_where_clause || ',';
       l_where_clause := l_where_clause || '''';
       l_where_clause := l_where_clause || 'DD-MON-YY';
       l_where_clause := l_where_clause || '''';
       l_where_clause := l_where_clause || ')';
     END IF;

     IF ( TO_CHAR(l_batch_rec.to_sched_ship_date) <> FND_API.G_MISS_CHAR AND
        TO_CHAR(l_batch_rec.to_sched_ship_date, 'DD-MON-YY') <> ' ')
     THEN
       l_where_clause := l_where_clause || ' AND TO_DATE(date_scheduled ';
       l_where_clause := l_where_clause || ',';
       l_where_clause := l_where_clause || '''';
       l_where_clause := l_where_clause || 'DD-MON-YY';
       l_where_clause := l_where_clause || '''';
       l_where_clause := l_where_clause || ')';
       l_where_clause := l_where_clause || '<=';
       l_where_clause := l_where_clause ||'TO_DATE( ';
       l_where_clause := l_where_clause || '''';
       l_where_clause := l_where_clause ||l_batch_rec.to_sched_ship_date;
       l_where_clause := l_where_clause || '''';
       l_where_clause := l_where_clause || ',';
       l_where_clause := l_where_clause || '''';
       l_where_clause := l_where_clause || 'DD-MON-YY';
       l_where_clause := l_where_clause || '''';
       l_where_clause := l_where_clause || ')';
     END IF;

     GMI_RESERVATION_UTIL.PrintLn('whse_code : '|| l_batch_rec.whse_code);

    /* Warehouse code ( ship_to_org_id) */
    IF ( NVL( l_batch_rec.whse_code,' ') <> ' ' )
    THEN
       OPEN get_ship_to_org_cur(l_batch_rec.whse_code);
       FETCH get_ship_to_org_cur INTO l_ship_to_org_id;
       IF(get_ship_to_org_cur%NOTFOUND)
       THEN
         GMI_RESERVATION_UTIL.PrintLn('Get_ship_to_org_cur failed, No Data found');
         CLOSE get_ship_to_org_cur;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
       CLOSE get_ship_to_org_cur;

       l_where_clause := l_where_clause || ' AND organization_id = ';
       l_where_clause := l_where_clause || l_ship_to_org_id ;

    END IF;


    /* item (inventory_item_id) */

    IF ( NVL( l_batch_rec.item_id,0) <> 0 )
    THEN

       OPEN get_inventory_item_id_cur(l_batch_rec.item_id);
       FETCH get_inventory_item_id_cur INTO l_inventory_item_id;
       IF(get_inventory_item_id_cur%NOTFOUND)
       THEN
         GMI_RESERVATION_UTIL.PrintLn('get_inventory_item_id_cur failed, No Data found');
         CLOSE get_inventory_item_id_cur;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
       CLOSE get_inventory_item_id_cur;

       l_where_clause := l_where_clause || ' AND inventory_item_id = ';
       l_where_clause := l_where_clause || l_inventory_item_id ;

    END IF;

    GMI_RESERVATION_UTIL.PrintLn('5: Where Clause is : ' || l_where_clause);

    /* fetch the delivery detail rec into l_wdd_line for the above where clause */

     OPEN wdd_cur1 FOR
      'SELECT * FROM wsh_delivery_details

         WHERE ' || l_where_clause ||
        'ORDER BY  delivery_detail_id ' ;
     LOOP
       gmi_reservation_util.println('before fetch');
       FETCH wdd_cur1 INTO l_wdd_rec;
       EXIT WHEN wdd_cur1%NOTFOUND;

          GMI_RESERVATION_UTIL.PrintLn('l_wdd_rec.delivery_detail_id'|| l_wdd_rec.delivery_detail_id);
          GMI_RESERVATION_UTIL.PrintLn('In Auto_allocation_batch Before calling Auto_Alloc_Wdd_line');
          /* Call auto_alloc_Wdd_line */

          Auto_Alloc_Wdd_Line (
                 p_api_version   => 1.0
                ,p_init_msg_list => FND_API.G_FALSE
                ,p_commit        => FND_API.G_FALSE
                ,p_wdd_rec       => l_wdd_rec
                ,p_batch_rec     => l_batch_rec
                ,x_number_of_rows    => l_number_of_rows
                ,x_qc_grade          => l_qc_grade
                ,x_detailed_qty      => l_detailed_qty
                ,x_qty_UM            => l_qty_um
                ,x_detailed_qty2     => l_detailed_qty2
                ,x_qty_UM2           => l_qty_um2
                ,x_return_status     => l_return_status
                ,x_msg_count         => l_msg_count
                ,x_msg_data          => l_msg_data);

           GMI_RESERVATION_UTIL.PrintLn('Status from auto_alloc_Wdd_line'|| l_return_status);

           IF (l_return_status =  WSH_UTIL_CORE.G_RET_STS_WARNING)
           THEN
              GMI_reservation_Util.PrintLn('Return_status from  Auto_Alloc_Wdd_Line : '||l_return_status);
              l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS( 'WARNING', '');
              retcode := 'C';

           ELSIF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
           THEN
              GMI_reservation_Util.PrintLn('Return_status from  Auto_Alloc_Wdd_Line : '||l_return_status);
              l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS( 'WARNING', '');
              FND_MESSAGE.Set_Name('GMI','GMI_AUTO_ALLOC_WDD_LINE_ERROR');
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
           END IF;
           x_return_status := l_return_status;

          /* If pick_confirm flag is set then, auto_pick_confirm */
          GMI_RESERVATION_UTIL.PrintLn('Pick_Confirm_Flag is set to : '|| l_batch_rec.pick_confirm_flag);

          IF ( l_batch_rec.pick_confirm_flag = 'Y' AND x_return_status = FND_API.G_RET_STS_SUCCESS)
          THEN
             GMI_RESERVATION_UTIL.PrintLn( 'pick_confirm_flag Is set to Y for batch_id : '|| p_batch_id);
             l_return_status := FND_API.G_RET_STS_SUCCESS;

             GMI_RESERVATION_UTIL.PrintLn( '  START PICK CONFIRMATION');

             IF(l_wdd_rec.released_status = 'S') THEN

                GMI_RESERVATION_UTIL.PrintLn( 'Before Call to Call_Pick_Confirm ');
                Call_Pick_Confirm (
                      p_mo_line_id                    =>    l_wdd_rec.move_order_line_id
                   ,  p_delivery_detail_id            =>    l_wdd_rec.delivery_detail_id
                   ,  p_init_msg_list                 =>    1
                   ,  p_move_order_type               =>    3
                   ,  x_delivered_qty                 =>   l_detailed_qty
                   ,  x_qty_UM                        =>   l_qty_um
                   ,  x_delivered_qty2                =>   l_detailed_qty2
                   ,  x_qty_UM2                       =>   l_qty_um2
                   ,  x_return_status                 =>   l_return_status
                   ,  x_msg_count                     =>   l_msg_count
                   ,  x_msg_data                      =>   l_msg_data);


                GMI_RESERVATION_UTIL.PrintLn('Status from Call_Pick_Confirm'|| l_return_status);
                IF(l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING)
                THEN
                  l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS( 'WARNING', '');
                  retcode := 'P';
                ELSIF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
                THEN
                   l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS( 'WARNING', '');
                   GMI_reservation_Util.PrintLn('Return_status from  call_pick_confirm : '||x_return_status);
                   FND_MESSAGE.Set_Name('GMI','GMI_PICK_CONFIRM_ERROR');
                   FND_MSG_PUB.Add;
                   RAISE FND_API.G_EXC_ERROR;
                END IF;

             ELSE
                GMI_RESERVATION_UTIL.PrintLn('Can Not Pick Confirm, The release status for the delivery_line is: '||
                        l_wdd_rec.released_status );
             END IF; /* IF released_status is 'S' */

          ELSE /* Pick Confirm Is set to 'N' */
             GMI_RESERVATION_UTIL.PrintLn( 'pick_confirm_flag Is set to N for batch_id : '|| p_batch_id);
          END IF;
    END LOOP;
GMI_RESERVATION_UTIL.PrintLn('ENd of auto_allocate_batch');

/* EXCEPTION HANDLING
====================*/
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
    --  ROLLBACK TO SAVEPOINT Auto_Allocate_Batch_SP;
    GMI_RESERVATION_UTIL.PrintLn('sqlcode : ' ||to_char(sqlcode));
    GMI_RESERVATION_UTIL.PrintLn('sqlerr : '|| SUBSTRB(SQLERRM, 1, 150));
    x_return_status := FND_API.G_RET_STS_ERROR;
    errbuf := SUBSTRB(SQLERRM, 1, 150);
    retcode := x_return_status;

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );
      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     -- ROLLBACK TO SAVEPOINT Auto_Allocate_Batch_SP;
      GMI_RESERVATION_UTIL.PrintLn('sqlcode : ' ||to_char(sqlcode));
    GMI_RESERVATION_UTIL.PrintLn('sqlerr : '|| SUBSTRB(SQLERRM, 1, 150));

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      errbuf := SUBSTRB(SQLERRM, 1, 150);
      retcode := x_return_status;


        FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );
         FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );
    WHEN OTHERS THEN
      --ROLLBACK TO SAVEPOINT Auto_Allocate_Batch_SP;
      GMI_RESERVATION_UTIL.PrintLn('sqlcode : ' ||to_char(sqlcode));
    GMI_RESERVATION_UTIL.PrintLn('sqlerr : '|| SUBSTRB(SQLERRM, 1, 150));

       FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       errbuf := SUBSTRB(SQLERRM, 1, 150);
       retcode := x_return_status;

      /*   Get message count and data */
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );


END Auto_Allocate_batch;

/* ========================================================================*/
/***************************************************************************/
/*
|    PARAMETERS:
|             p_api_version          Known api version
|             p_init_msg_list        FND_API.G_TRUE to reset list
|             p_commit               Commit flag. API commits if this is set.
|             x_return_status        Return status
|             x_msg_count            Number of messages in the list
|             x_msg_data             Text of messages
|             p_wdd_rec              wsh_delivery_details%rowtype
|             p_batch_rec            gmi_auto_allocation_batch%rowtype
|             x_number_of_rows
|             x_qc_grade
|             x_detailed_qty
|             x_qty_UM
|             x_detailed_qty2
|             x_qty_UM2
|
|
|     VERSION   : current version         1.0
|                 initial version         1.0
|     COMMENT   :
|
|
|     Notes :
|
****************************************************************************
| ========================================================================  */

PROCEDURE Auto_Alloc_wdd_Line (
     p_api_version      IN    NUMBER
  ,  p_init_msg_list    IN    VARCHAR2
  ,  p_commit           IN    VARCHAR2
  ,  p_wdd_rec          IN    wsh_delivery_details%rowtype
  ,  p_batch_rec        IN    gmi_auto_allocation_batch%rowtype
  ,  x_number_of_rows   OUT NOCOPY  NUMBER
  ,  x_qc_grade         OUT NOCOPY  VARCHAR2
  ,  x_detailed_qty     OUT NOCOPY  NUMBER
  ,  x_qty_UM           OUT NOCOPY  VARCHAR2
  ,  x_detailed_qty2    OUT NOCOPY  NUMBER
  ,  x_qty_UM2          OUT NOCOPY  VARCHAR2
  ,  x_return_status    OUT NOCOPY  VARCHAR2
  ,  x_msg_count        OUT NOCOPY  NUMBER
  ,  x_msg_data         OUT NOCOPY  VARCHAR2
)
IS

-- Standard constants to be used to check for call compatibility.
l_api_version   CONSTANT        NUMBER          := 1.0;
l_api_name      CONSTANT        VARCHAR2(30):= 'Auto_Alloc_Wdd_Line';

-- Local Variables.

l_msg_count             NUMBER  :=0;
l_msg_data              VARCHAR2(2000);
l_return_status         VARCHAR2(1);

l_detailed_qty                NUMBER               := 0;
l_ser_index                   NUMBER;
l_expiration_date             DATE;
x_success                     NUMBER;
l_transfer_to_location        NUMBER;
l_trans_id                     NUMBER;
l_lot_number                  NUMBER;
l_locator_id                  NUMBER;
l_subinventory_code           VARCHAR2(30);
l_transaction_quantity        NUMBER;
l_primary_quantity            NUMBER;
l_inventory_item_id           NUMBER;
l_message                     VARCHAR2(2000);
l_commit                      VARCHAR2(1);
l_whse_code                   VARCHAR2(10);
l_tran_rec                    GMI_TRANS_ENGINE_PUB.ictran_rec;
l_tran_row                    IC_TRAN_PND%ROWTYPE;


l_allocation_rec         GMI_Auto_Allocate_PUB.gmi_allocation_rec;
l_ic_item_mst_rec        GMI_Reservation_Util.ic_item_mst_rec;
--l_ic_item_mst_rec        ic_item_mst%ROWTYPE;
l_ic_item_mst            ic_item_mst%ROWTYPE;
l_old_transaction_rec    GMI_TRANS_ENGINE_PUB.ictran_rec;
l_op_alot_prm_rec        op_alot_prm%rowtype;

l_ic_whse_mst_rec        ic_whse_mst%rowtype;
l_total_qty              NUMBER;
l_total_qty2             NUMBER;

l_IC$DEFAULT_LOCT         VARCHAR2(255)DEFAULT NVL(FND_PROFILE.VALUE('IC$DEFAULT_LOCT'),' ') ;
l_GML$DEL_ALC_BEFORE_AUTO VARCHAR2(255) DEFAULT NVL(FND_PROFILE.VALUE('GML$DEL_AlC_BEFORE_AUTO'),' ') ;


Cursor get_whse_cur(p_whse_code IN VARCHAR2) IS
Select *
From ic_whse_mst
where whse_code=p_whse_code;

Cursor get_item_cur(p_item_id IN NUMBER) IS
Select *
From ic_item_mst
where item_id=p_item_id;


Cursor get_whse_code_cur(p_organization_id IN NUMBER)
IS
Select whse_code
from ic_whse_mst
where mtl_organization_id= p_organization_id;

CURSOR cur_txn_no_default ( p_line_id   IN NUMBER,
                             p_location  IN VARCHAR2,
                             p_item_id   IN NUMBER,
                             p_mo_line_id IN NUMBER)
IS
 SELECT SUM(ABS(trans_qty)),SUM(ABS(trans_qty2))
 FROM   ic_tran_pnd
 WHERE  line_id       = p_line_id
 AND    (  lot_id       > 0
        OR location <> p_location )
 AND       item_id       = p_item_id
 AND    doc_type      = 'OMSO'
 AND    staged_ind    = 0
 AND    completed_ind = 0
 AND    delete_mark   = 0
 AND    line_detail_id in
    (Select delivery_detail_id
     From wsh_delivery_details
     Where move_order_line_id = p_mo_line_id
        and released_status in ('R','S'));

/* Cursor For Existing Allocations */
CURSOR c_get_trans_id(p_delivery_detail_id IN NUMBER) IS
SELECT  ic.trans_id, ic.line_id
FROM    ic_tran_pnd ic, wsh_delivery_details wsh
WHERE   ic.line_detail_id = p_delivery_detail_id
   AND  wsh.delivery_detail_id = ic.line_detail_id
   AND  wsh.released_status IN ('R','S')
   AND  ic.doc_type = 'OMSO'
   AND  ic.delete_mark = 0
   AND  ic.staged_ind = 0
   AND  ic.completed_ind = 0
   AND     (ic.lot_id >0 OR ic.location <> 'l_IC$DEFAULT_LOCT');

ic_tran_tbl_row         c_get_trans_id%ROWTYPE;


BEGIN

   /*Init variables
   =========================================*/
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   /* Standard begin of API savepoint
   ===========================================*/
   SAVEPOINT Auto_Alloc_Wdd_Line_SP;

   /*Standard call to check for call compatibility.
      ==============================================*/

   IF NOT FND_API.compatible_api_call (
                                l_api_version,
                                p_api_version,
                                l_api_name,
                                G_PKG_NAME)
   THEN
      GMI_RESERVATION_UTIL.PrintLn('FND_API.compatible_api_call failed');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   /* Check p_init_msg_list
    =========================================*/
   IF FND_API.to_boolean(p_init_msg_list)
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   GMI_RESERVATION_UTIL.PrintLn('In Procedure Auto_Alloc_WDD_Line After Initialize');

  /* Below procedure fills in allocation record
       TYPE gmi_allocation_rec is RECORD
                ( doc_id            IC_TRAN_PND.DOC_ID%TYPE
                , line_id           IC_TRAN_PND.LINE_ID%TYPE
                , doc_line          IC_TRAN_PND.DOC_LINE%TYPE
                , line_detail_id    IC_TRAN_PND.LINE_DETAIL_ID%TYPE
                , item_no           IC_ITEM_MST.ITEM_NO%TYPE
                , whse_code         IC_WHSE_MST.WHSE_CODE%TYPE
                , co_code           OP_CUST_MST.CO_CODE%TYPE
                , cust_no           OP_CUST_MST.CUST_NO%TYPE
                , prefqc_grade      OP_ORDR_DTL.QC_GRADE_WANTED%TYPE
                , order_qty1        OP_ORDR_DTL.ORDER_QTY1%TYPE
                , order_qty2        OP_ORDR_DTL.ORDER_QTY2%TYPE
                , order_um1         OP_ORDR_DTL.ORDER_UM1%TYPE
                , order_um2         OP_ORDR_DTL.ORDER_UM2%TYPE
                , ship_to_org_id    oe_order_lines_all.SHIP_TO_ORG_ID%TYPE
                , of_cust_id        oe_order_lines_all.sold_to_org_id%TYPE
                , org_id            oe_order_lines_all.org_id%TYPE
                , trans_date        IC_TRAN_PND.TRANS_DATE%TYPE
                , user_id           FND_USER.USER_ID%TYPE
                , user_name         FND_USER.USER_NAME%TYPE
           );
   */

    OPEN Get_whse_code_cur(p_wdd_rec.organization_id);
    FETCH get_whse_code_cur into l_whse_code;

    IF(get_whse_code_cur%NOTFOUND)
    THEN
       GMI_RESERVATION_UTIL.PrintLn('Get_Whse_Code_cur Failed, No Data found');
       CLOSE get_whse_code_cur;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    CLOSE get_whse_code_cur;

    GMI_RESERVATION_UTIL.PrintLn('l_whse_code is '|| l_whse_code);
    GMI_RESERVATION_UTIL.PrintLn('Wdd org_id is '|| p_wdd_rec.organization_id);

    IF (NVL(p_batch_rec.delete_existing_aloc_flag,'N') = 'Y' OR
       (p_batch_rec.delete_existing_aloc_flag IS NULL AND UPPER(l_GML$DEL_ALC_BEFORE_AUTO) = 'YES') )
    THEN
       GMI_RESERVATION_UTIL.println('Delete_existing_aloc_flag is Y');

       OPEN c_get_trans_id(p_wdd_rec.delivery_detail_id);
       FETCH c_get_trans_id INTO ic_tran_tbl_row;

       IF (c_get_trans_id%FOUND)
       THEN
          GMI_RESERVATION_UTIL.println('In c_get_trans_id%FOUND');
          GMI_RESERVATION_UTIL.println('Deleting existing Allocations');
          WHILE c_get_trans_id%FOUND
          LOOP
             l_tran_rec.trans_id := ic_tran_tbl_row.trans_id;
             GMI_Reservation_Util.PrintLn('l_tran_rec.trans_id = ' || l_tran_rec.trans_id);
             GMI_Reservation_Util.PrintLn('Before Call to Delete Pending Transaction');

             GMI_TRANS_ENGINE_PUB.delete_pending_transaction (
                          1
                        , FND_API.G_FALSE
                        , FND_API.G_FALSE
                        , FND_API.G_VALID_LEVEL_FULL
                        , l_tran_rec
                        , l_tran_row
                        , x_return_status
                        , x_msg_count
                        , x_msg_data
                        );
             GMI_Reservation_Util.PrintLn('After Call to Delete Pending Transaction');
             GMI_Reservation_Util.PrintLn('Return from DELETE PENDING TRANS x_return_status = ' || x_return_status);

             IF x_return_status <> FND_API.G_RET_STS_SUCCESS
             THEN
             GMI_RESERVATION_UTIL.PrintLn('Error returned by Delete_Pending_Transaction');
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;

             FETCH c_get_trans_id INTO ic_tran_tbl_row;
          END LOOP;
          CLOSE c_get_trans_id;
       END IF;
    END IF;

    GMI_RESERVATION_UTIL.PrintLn('Before the call to Get_Allocation_Record ');

    Get_Allocation_Record (
         p_wdd_line           => p_wdd_rec
       , x_allocation_rec     => l_allocation_rec
       , x_ic_item_mst_rec    => l_ic_item_mst_rec
       , x_return_status      => x_return_status
       , x_msg_count          => x_msg_count
       , x_msg_data           => x_msg_data
       );

    GMI_RESERVATION_UTIL.PrintLn('Status from Get_Allocation_Record Is : '|| x_return_status);

    IF nvl(l_allocation_rec.order_qty1,0)=0 THEN
       GMI_RESERVATION_UTIL.println('Line is fully allocated, nothing to do, RETURN');
       RETURN;
    END IF;

  GMI_RESERVATION_UTIL.println('Will attempt to allocate '|| l_allocation_rec.order_qty1);


  OPEN Get_Whse_Cur(l_whse_code);
  FETCH Get_Whse_Cur Into l_ic_whse_mst_rec;
  IF(Get_Whse_Cur%NOTFOUND)
  THEN
     GMI_RESERVATION_UTIL.println('Get_Whse_Cur%Notfound');
     CLOSE Get_Whse_Cur;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  CLOSE Get_Whse_Cur;


  IF (l_ic_item_mst_rec.lot_ctl = 0 and l_ic_item_mst_rec.loct_ctl * l_ic_whse_mst_rec.loct_ctl = 0) THEN
     GMI_RESERVATION_UTIL.println('NON CONTROL . Auto allocation can not be performed');
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (nvl(l_ic_item_mst_rec.alloc_class, '%#S$%') = '%#S$%' ) THEN
     GMI_RESERVATION_UTIL.println('Alloc Class is missing from item set up.');
     GMI_RESERVATION_UTIL.println('Auto allocation can not be performed');
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  /* find out if there is default lot already */
  GMI_RESERVATION_UTIL.println('Before find_default_lot');
  GMI_RESERVATION_UTIL.find_default_lot
   (   x_return_status     => x_return_status,
       x_msg_count         => x_msg_count,
       x_msg_data          => x_msg_data,
       x_reservation_id    => l_trans_id,
       p_line_id           => p_wdd_rec.source_line_id

   );

  IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
     GMI_RESERVATION_UTIL.println('Error returned by find default lot');
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF nvl(l_trans_id, 0) <> 0 THEN
     GMI_RESERVATION_UTIL.println('Default trans exists');
  ELSE
     GMI_RESERVATION_UTIL.println('Create default trans ');
     GMI_RESERVATION_UTIL.create_dflt_lot_from_scratch
         ( p_whse_code                     => l_whse_code
         , p_line_id                       => p_wdd_rec.source_line_id
         , p_item_id                       => l_ic_item_mst_rec.item_id
         , p_qty1                          => p_wdd_rec.requested_quantity
         , p_qty2                          => p_wdd_rec.requested_quantity2
         , x_return_status                 => x_return_status
         , x_msg_count                     => x_msg_count
         , x_msg_data                      => x_msg_data
         );
     IF( l_return_status <> FND_API.G_RET_STS_SUCCESS ) then
        GMI_Reservation_Util.PrintLn('creating default lot returns error');
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
  END IF;

  GMI_RESERVATION_UTIL.println('Before Call To get allocation Parms');

  GMI_ALLOCATION_RULES_PVT.GET_ALLOCATION_PARMS
                           ( p_alloc_class   => l_ic_item_mst_rec.alloc_class,
                             p_org_id        => l_allocation_rec.org_id,
                             p_of_cust_id    => l_allocation_rec.of_cust_id,
                             p_ship_to_org_id=> l_allocation_rec.ship_to_org_id,
                             x_return_status => l_return_status,
                             x_op_alot_prm   => l_op_alot_prm_rec,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data
                            );


  GMI_RESERVATION_UTIL.println('Status from GET_ALLOCATION_PARMS : ' ||l_return_status);

  IF( l_return_status <> FND_API.G_RET_STS_SUCCESS ) then
        GMI_Reservation_Util.PrintLn('get allocation prm returns error');
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --l_commit := FND_API.G_FALSE;

  OPEN get_item_cur(l_ic_item_mst_rec.item_id);
  FETCH get_item_cur INTO l_ic_item_mst;

  IF (get_item_cur%NOTFOUND)
  THEN
     GMI_RESERVATION_UTIL.println('Get_Item_Cur%NOTFOUND');
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  CLOSE get_item_cur;

  GMI_RESERVATION_UTIL.println('Before Call To GMI_ALLOCATE_INVENTORY_PVT.Allocate_line');


  GMI_ALLOCATE_INVENTORY_PVT.ALLOCATE_LINE
        ( p_allocation_rec     => l_allocation_rec
        , p_ic_item_mst        => l_ic_item_mst
        , p_ic_whse_mst        => l_ic_whse_mst_rec
        , p_op_alot_prm        => l_op_alot_prm_rec
        , p_batch_id           => p_batch_rec.batch_id
        , x_allocated_qty1     => x_detailed_qty
        , x_allocated_qty2     => x_detailed_qty2
        , x_return_status      => x_return_status
        , x_msg_count          => x_msg_count
        , x_msg_data           => x_msg_data
        );

  GMI_RESERVATION_UTIL.println('After Call To GMI_ALLOCATE_INVENTORY_PVT.Allocate_line');
  GMI_RESERVATION_UTIL.println('GMI_ALLOCATE_INVENTORY_PVT.Allocate line status '|| x_return_status);

  IF x_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
     GMI_RESERVATION_UTIL.println('Warning returned  by allocate line ');
     RETURN;
  ELSIF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     GMI_RESERVATION_UTIL.println('Error returned  by allocate line ');
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  GMI_RESERVATION_UTIL.println('Before Call To  GMI_RESERVATION_UTIL.find_default_lot');
  GMI_RESERVATION_UTIL.find_default_lot
   (   x_return_status     => l_return_status,
       x_msg_count         => x_msg_count,
       x_msg_data          => x_msg_data,
       x_reservation_id    => l_trans_id,
       p_line_id           => p_wdd_rec.source_line_id
   );
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     GMI_RESERVATION_UTIL.println('Error returned by find default lot');
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_old_transaction_rec.trans_id := l_trans_id;
  IF GMI_TRAN_PND_DB_PVT.FETCH_IC_TRAN_PND
    (l_old_transaction_rec, l_old_transaction_rec )
  THEN
     GMI_RESERVATION_UTIL.PrintLn('balancing default lot for line_id '|| p_wdd_rec.source_line_id);
     GMI_RESERVATION_UTIL.balance_default_lot
       ( p_ic_default_rec            => l_old_transaction_rec
       , p_opm_item_id               => l_old_transaction_rec.item_id
       , x_return_status             => l_return_status
       , x_msg_count                 => x_msg_count
       , x_msg_data                  => x_msg_data
       );
     IF l_return_status <> FND_API.G_RET_STS_SUCCESS
     THEN
       GMI_RESERVATION_UTIL.PrintLn('Error returned by balancing default lot');
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
  END IF;

  OPEN cur_txn_no_default
                     ( p_line_id   =>  p_wdd_rec.source_line_id,
                       p_location   => FND_PROFILE.Value('IC$DEFAULT_LOCT'),
                       p_item_id    => l_ic_item_mst_rec.item_id,
                       p_mo_line_id => p_wdd_rec.move_order_line_id
                      );

  FETCH cur_txn_no_default INTO l_total_qty, l_total_qty2;
  IF cur_txn_no_default%NOTFOUND THEN
     CLOSE cur_txn_no_default;
     GMI_Reservation_Util.PrintLn('txn_no_default : NOTFOUND ');
     FND_MESSAGE.SET_NAME('GMI','GMI_REQUIRED_MISSING');
     RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE cur_txn_no_default;

  GMI_RESERVATION_UTIL.PrintLn('l_total_qty '||l_total_qty);
  GMI_RESERVATION_UTIL.PrintLn(' l_total_qty2 '||l_total_qty2);

  UPDATE ic_txn_request_lines
  SET   quantity_detailed = l_total_qty
      , secondary_quantity_detailed = l_total_qty2
  WHERE line_id = p_wdd_rec.move_order_line_id;

  IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)
  THEN
     x_return_status := FND_API.G_RET_STS_SUCCESS;
  END IF;

  GMI_RESERVATION_UTIL.PrintLn('Exiting Procedure Auto_Alloc_Wdd_Line Successfully');

/* EXCEPTION HANDLING
====================*/
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO SAVEPOINT Auto_Alloc_Wdd_Line_SP;

      x_return_status := FND_API.G_RET_STS_ERROR;

      GMI_RESERVATION_UTIL.PrintLn('In Exception FND_API.G_EXC_ERROR In Procedure Auto_Alloc_Wdd_Line ');

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );
      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO SAVEPOINT Auto_Alloc_Wdd_Line_SP;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      GMI_RESERVATION_UTIL.PrintLn('In Exception FND_API.G_EXC_UNEXPECTED_ERROR In Procedure Auto_Alloc_Wdd_Line ');

        FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );
         FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );
    WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT Auto_Alloc_Wdd_Line_SP;
       GMI_RESERVATION_UTIL.PrintLn('In Exception OTHERS In Procedure Auto_Alloc_Wdd_Line ');
       FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      /*   Get message count and data */
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

END auto_alloc_wdd_line;


PROCEDURE Call_Pick_Confirm
  (  p_mo_line_id          IN    NUMBER
  ,  p_delivery_detail_id  IN    NUMBER DEFAULT NULL
  ,  p_init_msg_list       IN    NUMBER
  ,  p_move_order_type     IN    NUMBER
  ,  x_delivered_qty       OUT NOCOPY  NUMBER
  ,  x_qty_UM              OUT NOCOPY  VARCHAR2
  ,  x_delivered_qty2      OUT NOCOPY  NUMBER
  ,  x_qty_UM2             OUT NOCOPY  VARCHAR2
  ,  x_return_status       OUT NOCOPY  VARCHAR2
  ,  x_msg_count           OUT NOCOPY  NUMBER
  ,  x_msg_data            OUT NOCOPY  VARCHAR2
  )
IS
l_api_version_number          CONSTANT NUMBER      := 1.0;
l_init_msg_list               VARCHAR2(255) := FND_API.G_TRUE;
l_api_name                    CONSTANT VARCHAR2(30) := 'Line_Pick_Confirm';
x_success                     NUMBER;

l_mo_hdr_rec                  GMI_Move_Order_Global.mo_hdr_rec;
l_mo_line_tbl                 GMI_Move_Order_Global.mo_line_tbl;
ll_mo_line_tbl                GMI_Move_Order_Global.mo_line_tbl;
l_mo_line_rec                 GMI_Move_Order_Global.mo_line_rec;
ll_mo_line_rec                GMI_Move_Order_Global.mo_line_rec;

l_return_status           VARCHAR2(1);
l_grouping_rule_id        NUMBER;
l_count                   NUMBER;
l_detail_rec_count        NUMBER;
l_success                 NUMBER;
l_request_number          VARCHAR2(80);
l_commit                  VARCHAR2(1);
l_allowed                 VARCHAR2(2);
l_max_qty                 NUMBER;
l_max_qty2                NUMBER;
l_transacted_qty          NUMBER;
l_transacted_qty2         NUMBER;
l_trans_qty               NUMBER;
l_trans_qty2              NUMBER;
l_del_trans_qty           NUMBER;
l_del_trans_qty2          NUMBER;

G_RET_STS_WARNING         EXCEPTION;

 CURSOR get_transacted_qty ( p_line_id   IN NUMBER
                            )
 is
 SELECT SUM(ABS(trans_qty)),SUM(ABS(trans_qty2))
 FROM   ic_tran_pnd
 WHERE  line_id       = p_line_id
 AND    doc_type      = 'OMSO'
 AND    completed_ind = 0
 AND    delete_mark   = 0
 AND    (line_detail_id is not null
        and line_detail_id in
           (  Select delivery_detail_id
              From wsh_delivery_details
              Where source_line_id = p_line_id
                 and released_status in ('Y','C')));   -- only the staged, and completed qtys should count
                                                       -- then add the current line
 CURSOR get_trans_qty_for_del ( p_line_id   NUMBER,
                                p_line_detail_id   NUMBER)
 is
 SELECT SUM(ABS(trans_qty)),SUM(ABS(trans_qty2))
 FROM   ic_tran_pnd
 WHERE  line_id       = p_line_id
 AND    doc_type      = 'OMSO'
 AND    completed_ind = 0
 AND    delete_mark   = 0
 AND    line_detail_id  = p_line_detail_id;

BEGIN
     /*  Init status :  */
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_init_msg_list = 1)
    THEN
       FND_MSG_PUB.Initialize;
    END IF;

    GMI_RESERVATION_UTIL.PrintLn('In Call_Pick_Confirm after initialize');
    /*  check what is the move order type. If it's a non pick wave mo,
      call the pick engine, otherwise, call the pick release api
      call directed pick and put away api
    */
    IF ( p_move_order_type = 3 )
    THEN
        /*  Get The Move Order line (1 line)  */
        l_mo_line_tbl(1) := GMI_Move_Order_Line_Util.Query_Row( p_mo_line_id);

        l_mo_line_rec.line_id := p_mo_line_id;

        l_mo_line_rec := l_mo_line_tbl(1);

        GMI_Move_Order_Line_Util.Lock_Row(
               p_mo_line_rec   => l_mo_line_rec
             , x_mo_line_rec   => ll_mo_line_rec
             , x_return_status => x_return_status);

        IF ( x_return_status = '54' )
        THEN
           GMI_Reservation_Util.PrintLn('(Auto_alloc_batch) Call_Pick_Confirm : the MO is locked for line_id='||p_mo_line_id);
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- for non ctl items, no allocation is made but the default trans
        -- qty is updated by the system, can not be over allocating

        /* this will be checked inside the API */

        OPEN get_transacted_qty (l_mo_line_rec.txn_source_line_id);
        FETCH get_transacted_qty Into l_transacted_qty, l_transacted_qty2;
        IF(get_transacted_qty%NOTFOUND)
        THEN
           GMI_Reservation_Util.PrintLn('get_transacted_qty%NOTFOUND');
           CLOSE get_transacted_qty;
        END IF;
        CLOSE get_transacted_qty;

        GMI_Reservation_Util.PrintLn('Total qtys have been transacted for source line '
                                         || l_mo_line_rec.txn_source_line_id);
        GMI_Reservation_Util.PrintLn('   total qty1 '|| l_transacted_qty);
        GMI_Reservation_Util.PrintLn('   total qty2 '|| l_transacted_qty2);

        OPEN get_trans_qty_for_del(l_mo_line_rec.txn_source_line_id, p_delivery_detail_id);
        FETCH get_trans_qty_for_del Into l_del_trans_qty, l_del_trans_qty2;
        IF(get_trans_qty_for_del%NOTFOUND )
        THEN
           CLOSE get_trans_qty_for_del;
        END IF;
        CLOSE get_trans_qty_for_del;

        GMI_Reservation_Util.PrintLn('Total qty1 being transacted '|| l_del_trans_qty);
        GMI_Reservation_Util.PrintLn('Total qty2 being transacted '|| l_del_trans_qty2);

        l_trans_qty := nvl(l_del_trans_qty,0);
        l_trans_qty2 := nvl(l_del_trans_qty2,0);

        GMI_RESERVATION_UTIL.PrintLn('Before Calling GMI_Pick_Wave_Confirm_PVT.Check_Shipping_Tolerances');

        GMI_Pick_Wave_Confirm_PVT.Check_Shipping_Tolerances
          (  x_return_status       => x_return_status,
             x_msg_count           => x_msg_count,
             x_msg_data            => x_msg_data,
             x_allowed             => l_allowed,
             x_max_quantity        => l_max_qty,
             x_max_quantity2       => l_max_qty2,
             p_line_id             => l_mo_line_rec.line_id,
             p_quantity            => l_trans_qty,
             p_quantity2           => l_trans_qty2
         );

        GMI_RESERVATION_UTIL.PrintLn('After Calling GMI_Pick_Wave_Confirm_PVT.Check_Shipping_Tolerances');
        GMI_RESERVATION_UTIL.PrintLn('Status from Check_Shipping_Tolerances : '||x_return_status);
        IF x_return_status  <> 'S' THEN
          fnd_message.set_name('INV', 'INV_CHECK_TOLERANCE_ERROR');
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          IF l_allowed = 'N' THEN
            GMI_Reservation_Util.PrintLn('WARNING!');
            GMI_Reservation_Util.PrintLn('MOVE ORDER line : line_id ='||l_mo_line_rec.line_id ||
                          ' can not be transacted because picked qty exceeds over shippment tolerance. '||
                          ' The allocated quantity is '|| l_mo_line_rec.quantity_detailed
                           ||' but the max allowed quantity is '||
                          l_max_qty || ' Please reduce allocation quantity ');
            x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
            RETURN;
          END IF ;
        END IF;

        GMI_Reservation_Util.PrintLn('(opm_dbg) mo_header_id ='||l_mo_line_tbl(1).header_id);
        GMI_Reservation_Util.PrintLn('(opm_dbg) mo_line_tbl.COUNT ='||l_mo_line_tbl.COUNT);

        SAVEPOINT GMI_Before_Pick_Confirm;
        l_commit := FND_API.G_FALSE;

        GMI_Reservation_Util.PrintLn('(opm_dbg) Before calling Pick_Confirm ='||l_mo_line_tbl(1).header_id);
        GMI_Pick_Wave_Confirm_PVT.Pick_Confirm(
            p_api_version_number     => 1.0,
            p_init_msg_lst           => FND_API.G_FALSE,
            p_validation_flag        => FND_API.G_VALID_LEVEL_FULL,
            p_commit                 => l_commit,
            p_delivery_detail_id     => p_delivery_detail_id,
            p_mo_line_tbl            => l_mo_line_tbl,
            x_mo_line_tbl            => ll_mo_line_tbl,
            x_return_status          => l_return_status,
            x_msg_data               => x_msg_data,
            x_msg_count              => x_msg_count);

        GMI_Reservation_Util.PrintLn('(opm_dbg) l_return_status from GMI_pick_wave_Confirm_pub.Pick_Confirm is ' || l_return_status);
        GMI_Reservation_Util.PrintLn('(opm_dbg) mo_line.count=' || ll_mo_line_tbl.count);
        /* Message('l_return_status from GMI_pick_release_pub.Auto_detail is ' || l_return_status); */

        IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS )
        THEN
           GMI_Reservation_Util.PrintLn('return error');
            FND_MESSAGE.Set_Name('GMI','PICK_CONFIRM_ERROR');
            FND_MESSAGE.Set_Token('WHERE', 'AFTER_CALL_PICK_CONFIRM');
            FND_MESSAGE.Set_Token('WHAT', 'UnexpectedError');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

                IF ( ll_mo_line_tbl.count = 0 )
        THEN
            GMI_Reservation_Util.PrintLn('return error');
            FND_MESSAGE.Set_Name('GMI','PICK_CONFIRM_ERROR');
            FND_MESSAGE.Set_Token('WHERE', 'MO_LINE_COUNT_0');
            FND_MESSAGE.Set_Token('WHAT', 'UnexpectedError');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

    END IF;


  GMI_Reservation_Util.PrintLn('(opm_dbg) Before setting the return value');
  /* ==================================================================
     Set the Returned values from the GMI_Reservation_Util.ic_tran_rec_tbl
    ================================================================== */
  x_delivered_qty  := ll_mo_line_tbl(1).quantity_delivered;

  GMI_Reservation_Util.PrintLn('(opm_dbg) Before setting the return value 1');
  x_qty_UM         := ll_mo_line_tbl(1).uom_code;

  GMI_Reservation_Util.PrintLn('(opm_dbg) Before setting the return value 2');
  x_delivered_qty2 := ll_mo_line_tbl(1).secondary_quantity_delivered;

  GMI_Reservation_Util.PrintLn('(opm_dbg) Before setting the return value 3');
  x_qty_UM2        := ll_mo_line_tbl(1).secondary_uom_code;

  GMI_Reservation_Util.PrintLn('(opm_dbg) End of GMI_auto_allocation_batch_pkg.Call_Pick_Confirm, l_return_status is '
     || l_return_status);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
/*          ROLLBACK TO SAVEPOINT GMI_Before_Pick_Confirm;  */

        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);

    WHEN G_RET_STS_WARNING THEN

        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;


    WHEN OTHERS THEN
/*          ROLLBACK TO SAVEPOINT GMI_Before_Pick_Confirm;  */

  IF (x_return_status = '54')
        THEN
           x_return_status := '54' ;
        ELSE
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        END IF;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Call_Pick_Confirm');
        END IF;
        FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);

END Call_Pick_Confirm;

PROCEDURE get_allocation_record
   ( p_wdd_line          IN  wsh_delivery_details%rowtype
   , x_allocation_rec    OUT NOCOPY GMI_Auto_Allocate_PUB.gmi_allocation_rec
   , x_ic_item_mst_rec   OUT NOCOPY GMI_Reservation_Util.ic_item_mst_rec
   , x_return_status     OUT NOCOPY VARCHAR2
   , x_msg_count         OUT NOCOPY NUMBER
   , x_msg_data          OUT NOCOPY VARCHAR2
   ) IS

l_api_name           CONSTANT VARCHAR2 (30) := 'Get_Allocation_Record';
l_tmp_qty            NUMBER;
l_header_id          NUMBER;
l_co_code           VARCHAR2(10);
x_orgn_code           VARCHAR2(10);
l_del_qty            NUMBER;
l_del_qty2           NUMBER;

/* ==== Cursors ============================================================== */
/*  removed from this cursor : */
/*     oe_order_header_all oeh, */
/*  AND   oeh.header_id  = oel.header_id */

CURSOR c_customer_and_so_info (oe_line_id IN NUMBER) IS
SELECT oel.sold_to_org_id
     , oel.ship_to_org_id
     , oel.line_number + (oel.shipment_number / 10)
     , oel.org_id
     , oel.schedule_ship_date
     , oel.header_id
FROM  oe_order_lines_all oel
WHERE  oel.line_id = p_wdd_line.source_line_id;

l_oe_line        c_customer_and_so_info%rowtype;
CURSOR c_user IS
SELECT user_id,
       user_name
FROM fnd_user
WHERE  user_id = FND_GLOBAL.USER_ID;

Cursor get_whse_code(p_organization_id IN NUMBER)
IS
Select whse_code
from ic_whse_mst
where mtl_organization_id= p_organization_id;
Cursor get_allocated_qty (p_line_id IN NUMBER
                        , p_line_detail_id IN NUMBER)
IS
Select abs(sum(nvl(trans_qty,0))), abs(sum(nvl(trans_qty2,0)))
From ic_tran_pnd
where line_id = p_line_id
  and line_detail_id = p_line_detail_id
  and doc_type = 'OMSO'
  and delete_mark = 0;
--   and completed_ind = 0; PK Bug 4025462 Do not check this.

Cursor Cur_get_process_org
       ( p_organization_id IN NUMBER)
       IS
SELECT w.whse_code,
       s.co_code,
       s.orgn_code
FROM   mtl_parameters p,
       ic_whse_mst w,
       sy_orgn_mst s
WHERE
      w.mtl_organization_id   = p.organization_id
AND   p.ORGANIZATION_ID       = p_organization_id
AND   s.orgn_code             = w.orgn_code
AND   s.orgn_code             = p.process_orgn_code
AND   p.process_enabled_flag  ='Y'
AND   s.delete_mark           = 0
AND   w.delete_mark           = 0;

BEGIN

GMI_RESERVATION_UTIL.PrintLn('Beginning of Get_Allocation_Record ');

/* ======================================================================= */
/*  Init variables  */
/* ======================================================================= */
x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN c_customer_and_so_info(x_allocation_rec.line_id);
    FETCH c_customer_and_so_info
         INTO x_allocation_rec.of_cust_id
           ,  x_allocation_rec.ship_to_org_id
           ,  x_allocation_rec.doc_line
           ,  x_allocation_rec.org_id
           ,  x_allocation_rec.trans_date
           ,  l_header_id
           ;

   IF (c_customer_and_so_info%NOTFOUND) THEN
      CLOSE c_customer_and_so_info;
      GMI_reservation_Util.PrintLn('Customer info not found');
      GMI_reservation_Util.PrintLn('in Util v: cust_no=NOTFOUND');
      FND_MESSAGE.Set_Name('GMI','GMI_CUST_INFO');
      FND_MESSAGE.Set_Token('SO_LINE_ID', x_allocation_rec.line_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   ELSE
      GMI_reservation_Util.PrintLn(' in Util v: cust_id='||x_allocation_rec.of_cust_id||',
                 doc_line='||x_allocation_rec.doc_line);
   END IF;
   CLOSE c_customer_and_so_info;

  /* ============================================================================================= */
  /*  Initialize the allocation record type */
  /*  Note that the Qty are not converted (only the Apps/OPM UOM) */
  /* ============================================================================================= */

   GMI_RESERVATION_UTIL.PrintLn('Set up Trans rec');
   x_allocation_rec.doc_id           := INV_SALESORDER.GET_SALESORDER_FOR_OEHEADER(l_header_id);

   IF ( x_allocation_rec.doc_id IS NULL ) THEN
      FND_MESSAGE.SET_NAME('GMI','INV_COULD_NOT_GET_MSO_HEADER');
      FND_MESSAGE.Set_Token('OE_HEADER_ID', l_header_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   OPEN get_allocated_qty (p_wdd_line.source_line_id, p_wdd_line.delivery_detail_id);
   FETCH get_allocated_qty Into l_del_qty, l_del_qty2;
   IF(get_allocated_qty%NOTFOUND)
   THEN
      GMI_RESERVATION_UTIL.PrintLn('get_allocated_qty%NOTFOUND');
      CLOSE get_allocated_qty;
   END IF;
   CLOSE get_allocated_qty;


   GMI_reservation_Util.PrintLn(' allocated qty for delivery '||l_del_qty);
   GMI_reservation_Util.PrintLn(' allocated qty2 for delivery '||l_del_qty2);

   x_allocation_rec.line_id          := p_wdd_line.source_line_id;
   x_allocation_rec.prefqc_grade     := p_wdd_line.preferred_grade;
   x_allocation_rec.order_qty1       := p_wdd_line.requested_quantity - nvl(l_del_qty,0);

   GMI_reservation_Util.PrintLn(' requested qty for delivery '||p_wdd_line.requested_quantity);

   IF x_allocation_rec.order_qty1 < 0 THEN
      x_allocation_rec.order_qty1       :=  0;
   END IF;

   x_allocation_rec.line_detail_id   := p_wdd_line.delivery_detail_id;

   OPEN get_whse_code(p_wdd_line.organization_id);
   FETCH get_whse_code INTO x_allocation_rec.whse_code;
   IF(get_whse_code%NOTFOUND)
   THEN
      GMI_RESERVATION_UTIL.PrintLn('get_whse_code%NOTFOUND');
      CLOSE get_whse_code;
   END IF;

   CLOSE get_whse_code;


   x_allocation_rec.user_id      := FND_GLOBAL.user_id;


   /* ============================================================================================= */
   /*  Check Source Type */
   /* ============================================================================================= */

   /* ============================================================================================= */
   /*  Get whse, and organization code from Process.               */
   /* ============================================================================================= */

   GMI_RESERVATION_UTIL.PrintLn('Before Opening cursor Cur_get_process_org');

   OPEN cur_get_process_org(p_wdd_line.organization_id);
   FETCH cur_get_process_org INTO x_allocation_rec.whse_code,l_co_code,x_orgn_code;
   IF(Cur_get_process_org%NOTFOUND) THEN
     CLOSE Cur_get_process_org;
     GMI_reservation_Util.PrintLn(' in end of Get_Allocation__Record ERROR:No rows found for cur_get_process_org.');
     FND_MESSAGE.Set_Name('GMI','GMI_GET_PROCESS_ORG');
     FND_MESSAGE.Set_Token('ORGANIZATION_ID', p_wdd_line.organization_id);
     FND_MSG_PUB.Add;
     RAISE FND_API.G_EXC_ERROR;
   ELSE
      CLOSE Cur_get_process_org;
   END IF;

   x_allocation_rec.co_code      := l_co_code;

   /* ============================================================================================= */
   /*  Get Item details */
   /* ============================================================================================= */
   GMI_RESERVATION_UTIL.PrintLn('Before get opm item from apps');

   GMI_RESERVATION_UTIL.Get_OPM_item_from_Apps(
           p_organization_id          => p_wdd_line.organization_id
         , p_inventory_item_id        => p_wdd_line.inventory_item_id
         , x_ic_item_mst_rec          => x_ic_item_mst_rec
         , x_return_status            => x_return_status
         , x_msg_count                => x_msg_count
         , x_msg_data                 => x_msg_data);


    GMI_reservation_Util.PrintLn(' in Util v: item_no='||x_ic_item_mst_rec.item_no);

   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
   THEN
      GMI_RESERVATION_UTIL.PrintLn('Status get opm item from apps '|| x_return_status);
      GMI_reservation_Util.PrintLn(' in end of GMI_Reservation_Util.Get_Allocation_Record
                 ERROR:Returned by Get_OPM_item_from_Apps.');
      FND_MESSAGE.Set_Name('GMI','GMI_OPM_ITEM');
      FND_MESSAGE.Set_Token('ORGANIZATION_ID', p_wdd_line.organization_id);
      FND_MESSAGE.Set_Token('INVENTORY_ITEM_ID', p_wdd_line.inventory_item_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   ELSE
      x_allocation_rec.item_no      := x_ic_item_mst_rec.item_no;
   END IF;

   /*
   IN A NEXT VERSION : CUST_ID is going to be returned
    */

   IF (x_ic_item_mst_rec.dualum_ind > 0) THEN
      x_allocation_rec.order_qty2   := p_wdd_line.requested_quantity2 - nvl(l_del_qty2,0);
      x_allocation_rec.order_um2    := x_ic_item_mst_rec.item_um2;

      IF x_allocation_rec.order_qty1 <= 0 THEN
         x_allocation_rec.order_qty2       :=  0;
      END IF;
   ELSE
      x_allocation_rec.order_qty2   := NULL;
      x_allocation_rec.order_um2    := NULL;
   END IF;

   /* ============================================================================================= */
   /*  Get User details not needed */
   /* ============================================================================================= */

   GMI_reservation_Util.PrintLn(' Exiting  Util Get_Allocation_Record:');

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      GMI_Reservation_Util.PrintLn('Exiting  Util Get_Allocation_Record: Error');
      x_return_status := FND_API.G_RET_STS_ERROR;

      /*   Get message count and data */
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

   WHEN OTHERS THEN
      GMI_Reservation_Util.PrintLn('Exiting  Util Get_Allocation_Record: ErrorOther');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      /*   Get message count and data */
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );


END Get_Allocation_Record;


PROCEDURE Insert_Row (
        p_auto_alloc_batch_rec  IN gmi_auto_allocation_batch%ROWTYPE )
IS
l_err_no NUMBER;
l_err_msg VARCHAR2(100);

BEGIN
   INSERT INTO GMI_AUTO_ALLOCATION_BATCH (
                BATCH_ID
                ,NAME
                ,FROM_ORDER_HEADER_NO
                ,TO_ORDER_HEADER_NO
                ,FROM_SCHED_SHIP_DATE
                ,TO_SCHED_SHIP_DATE
                ,FROM_LOT_NO
                ,TO_LOT_NO
                ,FROM_SUBLOT_NO
                ,TO_SUBLOT_NO
                ,ORDER_TYPE_ID
                ,FROM_EXPIRATION_DATE
                ,TO_EXPIRATION_DATE
                ,FROM_CREATION_DATE
                ,TO_CREATION_DATE
                ,LOCATION
                ,ITEM_ID
                ,WHSE_CODE
                ,LOT_STATUS
                ,TO_DELIVERY_DETAIL_ID
                ,PICK_CONFIRM_FLAG
                ,ALLOC_ALL_LOT_FLAG
                ,LOTS_INDIVISIBLE_FLAG
                ,OVERRIDE_RULES
                ,DELETE_EXISTING_ALOC_FLAG
                ,ATTRIBUTE_CATEGORY
                ,ATTRIBUTE1
                ,ATTRIBUTE2
                ,ATTRIBUTE3
                ,ATTRIBUTE4
                ,ATTRIBUTE5
                ,ATTRIBUTE6
                ,ATTRIBUTE7
                ,ATTRIBUTE8
                ,ATTRIBUTE9
                ,ATTRIBUTE11
                ,ATTRIBUTE12
                ,ATTRIBUTE13
                ,ATTRIBUTE14
                ,ATTRIBUTE15
                ,CREATION_DATE
                ,CREATED_BY
                ,LAST_UPDATE_DATE
                ,LAST_UPDATED_BY
                ,LAST_UPDATE_LOGIN
                ,PROGRAM_APPLICATION_ID
                ,PROGRAM_ID
                ,PROGRAM_UPDATE_DATE )

        VALUES  (
                p_auto_alloc_batch_rec.BATCH_ID
                ,p_auto_alloc_batch_rec.NAME
                ,p_auto_alloc_batch_rec.FROM_ORDER_HEADER_NO
                ,p_auto_alloc_batch_rec.TO_ORDER_HEADER_NO
                ,p_auto_alloc_batch_rec.FROM_SCHED_SHIP_DATE
                ,p_auto_alloc_batch_rec.TO_SCHED_SHIP_DATE
                ,p_auto_alloc_batch_rec.FROM_LOT_NO
                ,p_auto_alloc_batch_rec.TO_LOT_NO
                ,p_auto_alloc_batch_rec.FROM_SUBLOT_NO
                ,p_auto_alloc_batch_rec.TO_SUBLOT_NO
                ,p_auto_alloc_batch_rec.ORDER_TYPE_ID
                ,p_auto_alloc_batch_rec.FROM_EXPIRATION_DATE
                ,p_auto_alloc_batch_rec.TO_EXPIRATION_DATE
                ,p_auto_alloc_batch_rec.FROM_CREATION_DATE
                ,p_auto_alloc_batch_rec.TO_CREATION_DATE
                ,p_auto_alloc_batch_rec.LOCATION
                ,p_auto_alloc_batch_rec.ITEM_ID
                ,p_auto_alloc_batch_rec.WHSE_CODE
                ,p_auto_alloc_batch_rec.LOT_STATUS
                ,p_auto_alloc_batch_rec.TO_DELIVERY_DETAIL_ID
                ,p_auto_alloc_batch_rec.PICK_CONFIRM_FLAG
                ,p_auto_alloc_batch_rec.ALLOC_ALL_LOT_FLAG
                ,p_auto_alloc_batch_rec.LOTS_INDIVISIBLE_FLAG
                ,p_auto_alloc_batch_rec.OVERRIDE_RULES
                ,p_auto_alloc_batch_rec.DELETE_EXISTING_ALOC_FLAG
                ,p_auto_alloc_batch_rec.ATTRIBUTE_CATEGORY
                ,p_auto_alloc_batch_rec.ATTRIBUTE1
                ,p_auto_alloc_batch_rec.ATTRIBUTE2
                ,p_auto_alloc_batch_rec.ATTRIBUTE3
                ,p_auto_alloc_batch_rec.ATTRIBUTE4
                ,p_auto_alloc_batch_rec.ATTRIBUTE5
                ,p_auto_alloc_batch_rec.ATTRIBUTE6
                ,p_auto_alloc_batch_rec.ATTRIBUTE7
                ,p_auto_alloc_batch_rec.ATTRIBUTE8
                ,p_auto_alloc_batch_rec.ATTRIBUTE9
                ,p_auto_alloc_batch_rec.ATTRIBUTE11
                ,p_auto_alloc_batch_rec.ATTRIBUTE12
                ,p_auto_alloc_batch_rec.ATTRIBUTE13
                ,p_auto_alloc_batch_rec.ATTRIBUTE14
                ,p_auto_alloc_batch_rec.ATTRIBUTE15
                ,p_auto_alloc_batch_rec.CREATION_DATE
                ,p_auto_alloc_batch_rec.CREATED_BY
                ,p_auto_alloc_batch_rec.LAST_UPDATE_DATE
                ,p_auto_alloc_batch_rec.LAST_UPDATED_BY
                ,p_auto_alloc_batch_rec.LAST_UPDATE_LOGIN
                ,p_auto_alloc_batch_rec.PROGRAM_APPLICATION_ID
                ,p_auto_alloc_batch_rec.PROGRAM_ID
                ,p_auto_alloc_batch_rec.PROGRAM_UPDATE_DATE);

EXCEPTION
    WHEN OTHERS THEN

    l_err_no :=SQLCODE;
    l_err_msg :=SUBSTR(SQLERRM,1 ,100);

    WSH_UTIL_CORE.Println(' Line Insert Error => ' || l_err_no || l_err_msg);
        gmi_reservation_util.Println(' Line Insert Error => ' || l_err_no ||
                l_err_msg );

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Insert_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END Insert_Row;


FUNCTION Submit_Allocation_Request(P_Batch_Id IN  NUMBER)
 RETURN NUMBER IS

L_Request_Id            NUMBER;
l_msg   VARCHAR2(2000);
l_count  NUMBER;
l_status VARCHAR2(1) ;
l_version NUMBER ;

BEGIN
     l_version := 1.0;
     GMI_RESERVATION_UTIL.println('before submit_request');
     l_Request_Id := FND_REQUEST.Submit_Request('GML','GMIALLOC','','',FALSE,1.0,
                                FND_API.G_FALSE,FND_API.G_TRUE,p_batch_id);
 /*

                                              '','','','','','','','','','',
                                              '','','','','','','','','','',
                                              '','','','','','','','','','',
                                              '','','','','','','','','','',
                                              '','','','','','','','','','',
                                              '','','','','','','','','','',
                                              '','','','','','','','','','',
                                              '','','','','','','','','','',
                                              '','','','','','','','','','',
                                              '','','','','','','','','','');
   */
     IF(l_request_id = 0 )THEN
       FND_MESSAGE.RETRIEVE(l_msg);
       GMI_RESERVATION_UTIL.println('l_msg is :'|| l_msg);
     END IF;

     GMI_RESERVATION_UTIL.println('request_id is : '||l_request_id);
      Return L_Request_Id;

END Submit_allocation_request;


END GMI_AUTO_ALLOC_BATCH_PKG;

/
