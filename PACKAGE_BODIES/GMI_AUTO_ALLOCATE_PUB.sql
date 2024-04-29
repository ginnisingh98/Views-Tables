--------------------------------------------------------
--  DDL for Package Body GMI_AUTO_ALLOCATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_AUTO_ALLOCATE_PUB" AS
/*  $Header: GMIPALLB.pls 120.0 2005/05/25 16:00:00 appldev noship $  */

/*  Global variables */
/*  Set package name */
/*  ================ */
G_PKG_NAME  CONSTANT  VARCHAR2(30):='GMI_AUTO_ALLOCATE_PUB';

/* +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    Allocate_Inventory                                                    |
 |                                                                          |
 | TYPE                                                                     |
 |    Public                                                                |
 |                                                                          |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    Auto Allocate Inventory against a sales/shipment line                 |
 |                                                                          |
 | PARAMETERS                                                               |
 |    p_api_version      IN  NUMBER       - Api Version                     |
 |    p_init_msg_list    IN  VARCHAR2     - Message Initialization Ind.     |
 |    p_commit           IN  VARCHAR2     - Commit Indicator                |
 |    p_validation_level IN  VARCHAR2     - Validation Level (Not Used)     |
 |    p_allocation_rec   IN  gmi_allocation_rec - Allocation requirements   |
 |    x_reservation_id   OUT NOCOPY NUMBER       - Trans_id from ic_tran_pnd       |
 |    x_allocated_qty1   OUT NOCOPY NUMBER       - Qty allocated in order_um1      |
 |    x_allocated_qty1   OUT NOCOPY NUMBER       - Qty allocated in order_um2      |
 |    x_return_status    OUT NOCOPY VARCHAR2     - Return Status                   |
 |    x_msg_count        OUT NOCOPY NUMBER       - Number of messages              |
 |    x_msg_data         OUT NOCOPY VARCHAR2     - Messages in encoded format      |
 |                                                                          |
 |                                                                          |
 | HISTORY                                                                  |
 | B1731567 - Distinguish co_code associated with cust_no from co_code
 |            associated with the whse and inventory transactions           |
 +==========================================================================+
*/
PROCEDURE ALLOCATE_INVENTORY
( p_api_version        IN  NUMBER
, p_init_msg_list      IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_commit             IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_validation_level   IN  VARCHAR2        DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_allocation_rec     IN  gmi_allocation_rec
, x_reservation_id     OUT NOCOPY NUMBER
, x_allocated_qty1     OUT NOCOPY NUMBER
, x_allocated_qty2     OUT NOCOPY NUMBER
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
)
IS
l_api_name           CONSTANT VARCHAR2 (30) := 'ALLOCATE_INVENTORY';
l_api_version        CONSTANT NUMBER        := 1.0;
l_allocated_qty1     NUMBER  :=0;
l_allocated_qty2     NUMBER  :=0;
l_msg_count          NUMBER  :=0;
l_msg_data           VARCHAR2(2000);
l_return_status      VARCHAR2(1);
l_allocation_rec     gmi_allocation_rec;
-- HW BUG#:2643440 Need to change out parameter name
ll_allocation_rec     gmi_allocation_rec;
l_ic_item_mst_rec    ic_item_mst%ROWTYPE;
l_ic_item_cpg_rec    ic_item_cpg%ROWTYPE;
l_ic_whse_mst_rec    ic_whse_mst%ROWTYPE;
l_op_alot_prm_rec    op_alot_prm%ROWTYPE;


/* B1731567 - identify co_code associated with whse and orgn_code
================================================================*/
CURSOR sy_orgn_mst_c1 is
SELECT co_code
FROM sy_orgn_mst
WHERE orgn_code = l_ic_whse_mst_rec.orgn_code;


BEGIN

  /* Standard Start OF API savepoint
  =================================*/
  SAVEPOINT allocate_inventory;
  oe_debug_pub.add('OPM allocation engine start',1);

  /*Standard call to check for call compatibility.
  ==============================================*/
  IF NOT FND_API.Compatible_API_CALL (  l_api_version
                                      , p_api_version
                                      , l_api_name
                                      , G_PKG_NAME
                                      )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  /*Initialize message list if p_int_msg_list is set TRUE.
  ======================================================*/
  IF FND_API.to_boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;

  /*Initialize API return status to sucess
  =======================================*/
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /*Move allocation record to local variable
  ========================================*/
  l_allocation_rec := p_allocation_rec;

  /*Validate input parameters
  ==========================*/
  oe_debug_pub.add('OPM allocation engine validate input parms',1);
-- HW BUG#: 2643440 pass  ll_allocation_rec as out
  GMI_VALIDATE_ALLOCATION_PVT.VALIDATE_INPUT_PARMS
            (p_allocation_rec       => l_allocation_rec,
             x_ic_item_mst_rec      => l_ic_item_mst_rec,
             x_ic_whse_mst_rec      => l_ic_whse_mst_rec,
             x_allocation_rec       => ll_allocation_rec,
             x_return_status        => l_return_status,
             x_msg_count            => l_msg_count,
             x_msg_data             => l_msg_data);

  /*Return if validation failures detected
  =======================================*/
  IF l_return_status = FND_API.G_RET_STS_ERROR
  THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  /* Check for existing allocations.
  Auto Allocation cannot proceed where specific allocations already exist
  since this could lead to manual allocations being overwritten
  ======================================================================*/
  oe_debug_pub.add('OPM allocation engine check for existing txns',1);
  /*IF GMI_ALLOCATE_INVENTORY_PVT.CHECK_EXISTING_ALLOCATIONS
            (p_doc_id               => l_allocation_rec.doc_id,
             p_line_id              => l_allocation_rec.line_id,
             p_lot_ctl              => l_ic_item_mst_rec.lot_ctl,
             p_item_loct_ctl        => l_ic_item_mst_rec.loct_ctl,
             p_whse_loct_ctl        => l_ic_whse_mst_rec.loct_ctl  )
  THEN
    oe_debug_pub.add('OPM allocation exit because allocations exist',1);
    FND_MESSAGE.SET_NAME('GML','GML_CANNOT_AUTO_ALLOC');
    FND_MESSAGE.SET_TOKEN('ITEM_NO', l_ic_item_mst_rec.item_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;*/

  /* Retrieve allocation rules defined for this item/customer
  ==========================================================*/
  oe_debug_pub.add('OPM allocation main - about to fetch allocation parms',1);
-- HW BUG#:2643440 chaged l_allocation_rec to ll_allocation_rec
  GMI_ALLOCATION_RULES_PVT.GET_ALLOCATION_PARMS
                           ( p_alloc_class   => l_ic_item_mst_rec.alloc_class,
                             p_org_id        => ll_allocation_rec.org_id,
                             p_of_cust_id    => ll_allocation_rec.of_cust_id,
                             p_ship_to_org_id=> ll_allocation_rec.ship_to_org_id,
                             x_return_status => l_return_status,
                             x_op_alot_prm   => l_op_alot_prm_rec,
                             x_msg_count     => l_msg_count,
                             x_msg_data      => l_msg_data
                            );

  /* if no allocation rules found, then Raise Exception and return
  ===============================================================*/
  --B1655007 Update exception handling
  If (l_return_status = FND_API.G_RET_STS_ERROR)
  THEN
    FND_MESSAGE.SET_NAME('GML','GML_NO_ALLOCATION_PARMS'); /* NEW */
    FND_MESSAGE.SET_TOKEN('ALLOC_CLASS', l_ic_item_mst_rec.alloc_class);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  /* B1731567 - identify co_code associated with whse and orgn_code
                it may differ from that associated with the cust_no
  ================================================================*/
-- HW BUG#:2643440 use ll_allocation_rec instead of l_allocation_rec
  OPEN sy_orgn_mst_c1;
  FETCH sy_orgn_mst_c1 INTO ll_allocation_rec.co_code;

  /* Report error if row not located
  =================================*/
  IF (sy_orgn_mst_c1%NOTFOUND)
  THEN
    CLOSE sy_orgn_mst_c1;
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_ORGN_CODE');
    FND_MESSAGE.SET_TOKEN('ORGN_CODE',l_ic_whse_mst_rec.orgn_code);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    CLOSE sy_orgn_mst_c1;
  END IF;

  /*Select inventory in accordance with allocation rules
  =====================================================*/
  oe_debug_pub.add('OPM allocation engine - now allocate the line',1);
-- HW BUG#:2643440 Use  ll_allocation_rec instead of l_allocation_rec
  GMI_ALLOCATE_INVENTORY_PVT.ALLOCATE_LINE
                            ( p_allocation_rec => ll_allocation_rec,
                              p_ic_item_mst => l_ic_item_mst_rec,
                              p_ic_whse_mst => l_ic_whse_mst_rec,
                              p_op_alot_prm => l_op_alot_prm_rec,
                              x_allocated_qty1 => l_allocated_qty1,
                              x_allocated_qty2 => l_allocated_qty2,
                              x_return_status  => l_return_status,
                              x_msg_count      => l_msg_count,
                              x_msg_data       => l_msg_data
                            );

  If (l_return_status = FND_API.G_RET_STS_ERROR)
  THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  oe_debug_pub.add('OPM allocation engine - final primary allocation is  '|| l_allocated_qty1);
  x_allocated_qty1 := l_allocated_qty1;
  x_allocated_qty2 := l_allocated_qty2;

/* EXCEPTION HANDLING
====================*/

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO allocate_inventory;
    /* dbms_output.put_line('ERROR - rollback'); */
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO allocate_inventory;
    /* dbms_output.put_line('UNEXPECTED ERROR - rollback'); */
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );
    WHEN OTHERS THEN
      ROLLBACK TO allocate_inventory;
    /* dbms_output.put_line('UNTRAPPED ERROR - rollback'); */
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

END ALLOCATE_INVENTORY;
END GMI_AUTO_ALLOCATE_PUB;

/
