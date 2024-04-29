--------------------------------------------------------
--  DDL for Package Body GMI_ALLOCATE_INVENTORY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_ALLOCATE_INVENTORY_PVT" AS
/*  $Header: GMIVALIB.pls 120.1 2005/08/30 08:23:33 nchekuri noship $  */

/*  Global variables */
G_PKG_NAME  CONSTANT  VARCHAR2(30):='GMI_ALLOCATE_INVENTORY_PVT';


/* +=========================================================================+
 | PROCEDURE NAME                                                          |
 |    Allocate Line                                                        |
 |                                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    Analyze available inventory at the most detailed level to locate     |
 |    stock suitable for allocation to the current shipment/order line.    |
 |    Allocation must be in accordance with the rules defined in the       |
 |    allocation parameters op_alot_prm.                                   |
 |    The quantity successfully allocated is returned expressed in the     |
 |    inventory item primary and secondary unit of measure.                |
 |                                                                         |
 | PARAMETERS                                                              |
 |    p_line_id            IN  NUMBER                                      |
 |    p_trans_date         IN  DATE                                        |
 |    p_ic_item_mst        IN  ic_item_mst%ROWTYPE                         |
 |    p_ic_whse_mst        IN  ic_whse_mst%ROWTYPE                         |
 |    p_op_alot_prm        IN  op_alot_prm%ROWTYPE                         |
 |    x_allocated_qty1     OUT NUMBER                                      |
 |    x_allocated_qty2     OUT NUMBER                                      |
 |    x_return_status      OUT VARCHAR2                                    |
 |    x_msg_count          OUT NUMBER                                      |
 |    x_msg_data           OUT VARCHAR2                                    |
 |                                                                         |
 | HISTORY                                                                 |
 |    15-DEC-1999      K.Y.Hunt      Created                               |
 |    APR-2003         NC  Added logic for Auto Alloc Batch  Enhacements   |
 |                     and did some cleanup.                               |
 +=========================================================================+
*/
PROCEDURE ALLOCATE_LINE
( p_allocation_rec     IN  GMI_AUTO_ALLOCATE_PUB.gmi_allocation_rec
, p_ic_item_mst        IN  ic_item_mst%ROWTYPE
, p_ic_whse_mst        IN  ic_whse_mst%ROWTYPE
, p_op_alot_prm        IN  op_alot_prm%ROWTYPE
, p_batch_id	       IN  NUMBER
, x_allocated_qty1     OUT NOCOPY NUMBER
, x_allocated_qty2     OUT NOCOPY NUMBER
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
)
IS
l_api_name              CONSTANT VARCHAR2 (30) := 'ALLOCATE_LINE';
l_msg_count             NUMBER  :=0;
l_msg_data              VARCHAR2(2000);
l_return_status         VARCHAR2(1);
l_allocation_successful VARCHAR2(1);
l_available_inventory1  NUMBER;
l_inventory_qty1        NUMBER :=0;
l_unallocated_qty1      NUMBER(19,9) :=0;
l_unallocated_qty2      NUMBER(19,9);
l_allocated_qty1        NUMBER :=0;
l_allocated_qty2        NUMBER :=0;
l_trans_qty1            NUMBER :=0;
l_trans_qty2            NUMBER(19,9) :=0;
l_loct_onhand           NUMBER;
l_loct_onhand2          NUMBER;
l_commit_qty            NUMBER;
l_commit_qty2           NUMBER;
l_lot_no                IC_LOTS_MST.LOT_NO%TYPE :=0;
l_sublot_no             IC_LOTS_MST.SUBLOT_NO%TYPE :=0;
l_loct_ctl              NUMBER(2);
l_lot_id                IC_LOTS_MST.LOT_ID%TYPE :=0;
l_lot_status            IC_TRAN_PND.LOT_STATUS%TYPE;
l_lot_created           IC_LOTS_MST.LOT_CREATED%TYPE;
l_location              IC_TRAN_PND.LOCATION%TYPE;
l_expire_date           IC_LOTS_MST.EXPIRE_DATE%TYPE;
l_qc_grade              IC_LOTS_MST.QC_GRADE%TYPE;
l_shelf_date            IC_TRAN_PND.TRANS_DATE%TYPE;

ll_shelf_date	   	VARCHAR2(32);
l_from_expiration_date  VARCHAR2(32);
l_to_expiration_date    VARCHAR2(32);
l_from_creation_date    VARCHAR2(32);
l_to_creation_date      VARCHAR2(32);
/*
ll_shelf_date	   	IC_TRAN_PND.TRANS_DATE%TYPE;
l_from_expiration_date  IC_TRAN_PND.TRANS_DATE%TYPE;
l_to_expiration_date    IC_TRAN_PND.TRANS_DATE%TYPE;
l_from_creation_date    IC_TRAN_PND.TRANS_DATE%TYPE;
l_to_creation_date      IC_TRAN_PND.TRANS_DATE%TYPE;
*/
l_override_rules 	NUMBER DEFAULT 0;
l_whse_code		IC_WHSE_MST.WHSE_CODE%TYPE;
l_IC$DEFAULT_LOCT       IC_LOCT_MST.LOCATION%TYPE;
l_where_clause          VARCHAR2(3000):= NULL;
l_order_by              VARCHAR2(1000):= NULL;
l_tran_rec              GMI_TRANS_ENGINE_PUB.ictran_rec;
l_tran_row              IC_TRAN_PND%ROWTYPE;
l_allocation_rec        GMI_AUTO_ALLOCATE_PUB.gmi_allocation_rec;
l_batch_rec             GMI_AUTO_ALLOCATION_BATCH%ROWTYPE;
l_lot_indivisible       NUMBER;
l_lot_qty		NUMBER;
l_lots_specified	NUMBER DEFAULT 1; /* 0=No lots specified, 1= 1 specified,2= Multiple specified */
l_overpick_enabled      VARCHAR2(1);

  --2722339 	EMC 	Auto Alloc QC Spec Match Project
  l_grade_or_qcmatch_flag NUMBER DEFAULT 0;
  l_prm_prefqc_grade    VARCHAR2(10) DEFAULT null;
  find_cust_spec_rec    GMD_SPEC_MATCH_GRP.customer_spec_rec_type;
  l_out_rec             BOOLEAN;
  l_spec_hdr_id         NUMBER;
  l_spec_vr_id          NUMBER;
  l_spec_return_status	VARCHAR2(1);
  l_header_id		NUMBER;
  l_schedule_ship_date	DATE;
  l_org_id		NUMBER;
  l_sold_to_org_id	NUMBER;
  l_ship_to_org_id	NUMBER;
  l_preferred_grade	IC_LOTS_MST.QC_GRADE%TYPE;
  l_message_data	VARCHAR2(500);
  l_alloc_all_lot_flag  VARCHAR2(1);


  result_lot_match_tbl  GMD_SPEC_MATCH_GRP.result_lot_match_tbl;
  result_flag		NUMBER DEFAULT 0 ;
  x2_return_status      VARCHAR2(1);
  x2_message_data       VARCHAR2(500);

  CURSOR Get_order_line_info IS
    Select
           header_id,
           sold_to_org_id,
           schedule_ship_date,
           ship_to_org_id,
           org_id,
           preferred_grade
    From oe_order_lines_all
    Where line_id =  p_allocation_rec.line_id;

CURSOR Get_Batch_Rec_Cur(p_batch_id NUMBER) IS
SELECT *
  FROM gmi_auto_allocation_batch
 WHERE batch_id = p_batch_id;

TYPE rc IS REF CURSOR;
ic_inventory_view_c1 rc;

BEGIN
  /*Initialize return status to success
  ====================================*/
 GMI_Reservation_Util.PrintLn('(Alloc PVT) GMIVALIB.pls Alloc Inventory Pvt');

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /*Standard Start OF API savepoint
  ================================*/
  SAVEPOINT allocate_line;
  gmi_reservation_util.println('OPM Allocation Engine - start allocate line',1);

  /*Get required system constants
  ==============================*/
  l_IC$DEFAULT_LOCT := FND_PROFILE.VALUE('IC$DEFAULT_LOCT');
  l_overpick_enabled := FND_PROFILE.VALUE('WSH_OVERPICK_ENABLED');

  /* dbms_output.put_line('default loct is ' || l_IC$DEFAULT_LOCT); */
  /* NC */
  IF (NVL(p_batch_id,0) <> 0) THEN
     OPEN Get_Batch_Rec_Cur(p_batch_id);
     FETCH Get_Batch_Rec_Cur INTO l_batch_rec;

     IF(Get_Batch_Rec_Cur%NOTFOUND) THEN
       CLOSE Get_Batch_Rec_Cur;
     END IF;

     CLOSE Get_Batch_Rec_Cur;
  END IF;

  IF( NVL(p_batch_id,0) = 0 )
  THEN
    l_override_rules := 0;
  ELSIF(l_batch_rec.override_rules = 'Y')
  THEN
    l_override_rules := 1;
  ELSE l_override_rules := 0;
  END IF;

  l_lot_qty := p_op_alot_prm.lot_qty;

  /*Check allocation horizon
  =========================*/

  /* dbms_output.put_line */
  /*   ('allocation horizon is set to '|| p_op_alot_prm.alloc_horizon); */
  /* dbms_output.put_line */
  /*   ('trans date ' || p_allocation_rec.trans_date || ' vs  system date ' || SYSDATE); */

  gmi_reservation_util.println
    ('OPM Allocation Engine - allocation parameter used is ' || p_op_alot_prm.allocrule_id);
  gmi_reservation_util.println
    ('OPM Allocation Engine - allocation horizon is ' || p_op_alot_prm.alloc_horizon);

  IF (l_override_rules = 0 AND p_op_alot_prm.alloc_horizon > 0) AND
   (p_allocation_rec.trans_date > (SYSDATE + p_op_alot_prm.alloc_horizon)) THEN
    /*   dbms_output.put_line('allocation horizon is out - using '|| p_op_alot_prm.alloc_horizon); */
    GMI_RESERVATION_UTIL.println('Allocation Horizon error: Scheduled ship date falls outside the allocation horizon');
    FND_MESSAGE.SET_NAME('GML','SO_E_ALLOC_HORIZON_ERR');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  /*If order UM differs from inventory UM, conversion is required.
  The allocations are recorded as transactions written in the inventory UM
  =======================================================================*/
  IF (p_allocation_rec.order_um1 <> p_ic_item_mst.item_um) THEN
    GMICUOM.icuomcv(pitem_id  => p_ic_item_mst.item_id,
                    plot_id   => l_lot_id,
                    pcur_qty  => p_allocation_rec.order_qty1,
                    pcur_uom  => p_allocation_rec.order_um1,
                    pnew_uom  => p_ic_item_mst.item_um,
                    onew_qty  => l_inventory_qty1);
  ELSE
    l_inventory_qty1 := p_allocation_rec.order_qty1;
  END IF;

  l_unallocated_qty1 := l_inventory_qty1;


  /*Build WHERE clause according to the item/whse attributes
  =========================================================*/
  gmi_reservation_util.println('OPM ALLOCATION ENGINE - build where clause',1);
  /* dbms_output.put_line('BUILD WHERE CLAUSE '); */
  IF (l_override_rules = 1)
  THEN
     l_shelf_date :=  p_allocation_rec.trans_date;
  ELSE
     l_shelf_date := p_allocation_rec.trans_date + p_op_alot_prm.shelf_days;
  END IF;
  ll_shelf_date := TO_CHAR(l_shelf_date,'DD-MON-YYYY, HH:MI:SS');

  l_whse_code := p_ic_whse_mst.whse_code;

  l_where_clause :=
    'item_id = '|| p_ic_item_mst.item_id ;
  l_where_clause := l_where_clause ||' AND whse_code = ';
  l_where_clause := l_where_clause || '''';
  l_where_clause := l_where_clause || l_whse_code ;
  l_where_clause := l_where_clause || '''';
  l_where_clause := l_where_clause ||' AND loct_onhand >= 0 ';

  /* expiration date */
  l_where_clause := l_where_clause ||' AND expire_date > ';
  l_where_clause := l_where_clause ||'TO_DATE( ';
  l_where_clause := l_where_clause || '''';
  l_where_clause := l_where_clause ||ll_shelf_date;
  l_where_clause := l_where_clause || '''';
  l_where_clause := l_where_clause || ',';
  l_where_clause := l_where_clause || '''';
  l_where_clause := l_where_clause || 'DD-MON-YYYY, HH:MI:SS';
  l_where_clause := l_where_clause || '''';
  l_where_clause := l_where_clause || ')';

  IF (p_ic_item_mst.lot_ctl = 0) THEN
    l_where_clause := l_where_clause ||
                      ' and lot_id = 0 ';
  ELSE
    l_where_clause := l_where_clause ||
                      ' and lot_id > 0 ';
  END IF;

  /*Overall location control is determined by looking at both the item and whse
  =============================================================================*/
  l_loct_ctl := p_ic_item_mst.loct_ctl * p_ic_whse_mst.loct_ctl;
  GMI_RESERVATION_UTIL.PrintLn('loct ctl set to ' || l_loct_ctl || ' from ' || p_ic_item_mst.loct_ctl
	|| ' and ' || p_ic_whse_mst.loct_ctl );

  IF l_loct_ctl = 0 THEN
    l_where_clause := l_where_clause || ' AND location = ';
    l_where_clause := l_where_clause || '''' ;
    l_where_clause := l_where_clause || l_IC$default_loct ;
    l_where_clause := l_where_clause || '''';
  ELSE
    l_where_clause := l_where_clause || ' AND location <> ';
    l_where_clause := l_where_clause || '''';
    l_where_clause := l_where_clause || l_IC$default_loct ;
    l_where_clause := l_where_clause || '''';
  END IF;

  /*Apply preferred QC grade if appropriate
  ========================================*/
  GMI_RESERVATION_UTIL.println('(ALLOC PVT) :l_allocation_rec.prefqc_grade'|| l_allocation_rec.prefqc_grade);
  GMI_Reservation_Util.PrintLn('(Alloc PVT) p_allocation_rec.prefqc_grade =  ' || p_allocation_rec.prefqc_grade);
  GMI_Reservation_Util.PrintLn('(Alloc PVT) p_op_alot_prm.prefqc_grade =  ' || p_op_alot_prm.prefqc_grade);

   --2722339 	EMC 	Auto Alloc QC Spec Match Project
   --If matching on Grade, preference is given to grade taken from sales order
   --line. Otherwise, grade is taken from Sales Order/Shipping Parameter form.


   IF (l_override_rules = 1)
   THEN
      l_grade_or_qcmatch_flag := 0;
      l_prm_prefqc_grade := NULL;
   ELSE
      l_grade_or_qcmatch_flag :=  p_op_alot_prm.grade_or_qc_flag;
      l_prm_prefqc_grade := p_op_alot_prm.prefqc_grade;
   END IF;


   l_allocation_rec.prefqc_grade := p_allocation_rec.prefqc_grade;
   GMI_RESERVATION_UTIL.println('Im here :l_allocation_rec.prefqc_grade'|| l_allocation_rec.prefqc_grade);

   IF (NVL(l_grade_or_qcmatch_flag,0) = 0) THEN
      IF (l_override_rules = 1) THEN
         l_allocation_rec.prefqc_grade := null;
      ELSE
         IF p_ic_item_mst.grade_ctl = 1 AND
            l_allocation_rec.prefqc_grade is NOT NULL THEN
	    l_where_clause := l_where_clause || ' and qc_grade = :v_qc_grade ';
	    l_allocation_rec.prefqc_grade := p_allocation_rec.prefqc_grade;
	    GMI_Reservation_Util.PrintLn('(Alloc PVT) l_where_clause 1=  ' || l_where_clause);
         ELSIF p_ic_item_mst.grade_ctl = 1 AND
            l_prm_prefqc_grade IS NOT NULL THEN
	    l_where_clause := l_where_clause || ' and qc_grade = :v_qc_grade ';
	    l_allocation_rec.prefqc_grade := l_prm_prefqc_grade;
	    GMI_Reservation_Util.PrintLn('(Alloc PVT) l_where_clause 2=  ' || l_where_clause);
         END IF;
      END IF;
   END IF;

/*
   IF (NVL(l_grade_or_qcmatch_flag,0) = 0) THEN

      IF ( p_ic_item_mst.grade_ctl = 1 AND l_allocation_rec.prefqc_grade is NOT NULL)
      THEN
         l_allocation_rec.prefqc_grade := p_allocation_rec.prefqc_grade;
      ELSIF( p_ic_item_mst.grade_ctl = 1 AND l_prm_prefqc_grade IS NOT NULL)
      THEN
          l_allocation_rec.prefqc_grade := l_prm_prefqc_grade;
      END IF;

      GMI_RESERVATION_UTIL.println('l_allocation_rec.prefqc_grade'|| l_allocation_rec.prefqc_grade);

      l_where_clause := l_where_clause || ' and qc_grade = ';
      l_where_clause := l_where_clause || '''' ;
      l_where_clause := l_where_clause || l_allocation_rec.prefqc_grade;
      l_where_clause := l_where_clause || '''';

      GMI_Reservation_Util.PrintLn('(Alloc PVT) l_where_clause 1=  ' || l_where_clause);
   END IF;
*/

   GMI_RESERVATION_UTIL.PrintLn('(Auto_Alloc) 1 WHERE clause is now '|| l_where_clause);
   GMI_RESERVATION_UTIL.PrintLn('WHSE IS '|| p_ic_whse_mst.whse_code);
   GMI_RESERVATION_UTIL.PrintLn('item_no item_id: ' ||p_ic_item_mst.item_no ||' '|| p_ic_item_mst.item_id);
   GMI_RESERVATION_UTIL.PrintLn('QC Grade to be used is '|| p_allocation_rec.prefqc_grade);

   GMI_RESERVATION_UTIL.PrintLn('Using a shelf date of '|| l_shelf_date );

   IF(l_batch_rec.from_lot_no <> FND_API.G_MISS_CHAR AND
        nvl (l_batch_rec.from_lot_no,'%$%') <> '%$%')
   THEN
     l_where_clause := l_where_clause || ' and  lot_no >= ';
     l_where_clause := l_where_clause || '''' ;
     l_where_clause := l_where_clause || l_batch_rec.from_lot_no ;
     l_where_clause := l_where_clause || '''';

     IF (l_batch_rec.to_lot_no <> FND_API.G_MISS_CHAR AND
        nvl (l_batch_rec.to_lot_no,'%$%') <> '%$%')
     THEN
        IF( l_batch_rec.from_lot_no <> l_batch_rec.to_lot_no)
        THEN
          l_lots_specified:= 2;
        END IF;
     END IF;
   ELSE
     l_lots_specified := 0;
   END IF;


   IF(l_batch_rec.to_lot_no <> FND_API.G_MISS_CHAR AND
        nvl (l_batch_rec.to_lot_no,'%$%') <> '%$%')
   THEN
     l_where_clause := l_where_clause || ' and  lot_no  <= ';
     l_where_clause := l_where_clause || '''' ;
     l_where_clause := l_where_clause || l_batch_rec.to_lot_no ;
     l_where_clause := l_where_clause || '''';

     IF(l_lots_specified = 0)
     THEN
       l_lots_specified := 1;
     END IF;
   END IF;

   GMI_RESERVATION_UTIL.PrintLn('(Auto_Alloc) 2 WHERE clause is now '|| l_where_clause);

   IF ( (l_lots_specified = 0 OR l_lots_specified = 2) AND l_batch_rec.alloc_all_lot_flag = 'Y'
        AND l_override_rules <> 1 AND l_lot_qty = 1)
   THEN
     GMI_RESERVATION_UTIL.PrintLn('WARNING! Allocation Parameters Conflict with Allocation Criteria on the form...');
     GMI_RESERVATION_UTIL.PrintLn('Allocation Parametrs require that allocation is made from a single lot. Allocate All Specified Lots is chosen on the screen and No Lots/Multiple Lots are specified; Returning........');
     x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
     RETURN;
   END IF;


   IF (l_batch_rec.from_sublot_no <> FND_API.G_MISS_CHAR and
        nvl(l_batch_rec.from_sublot_no,'%$%') <> '%$%')
   THEN
      l_where_clause := l_where_clause || ' and sublot_no >= ';
      l_where_clause := l_where_clause || '''' ;
      l_where_clause := l_where_clause || l_batch_rec.from_sublot_no ;
      l_where_clause := l_where_clause || '''';
   END IF;

   IF (l_batch_rec.to_sublot_no <> FND_API.G_MISS_CHAR and
        nvl(l_batch_rec.to_sublot_no,'%$%') <> '%$%')
   THEN
      l_where_clause := l_where_clause || ' and sublot_no <= ';
      l_where_clause := l_where_clause || '''' ;
      l_where_clause := l_where_clause || l_batch_rec.to_sublot_no ;
      l_where_clause := l_where_clause || '''';
   END IF;

   GMI_RESERVATION_UTIL.PrintLn('From creation date'|| l_batch_rec.from_creation_date);
   GMI_RESERVATION_UTIL.PrintLn('to_char(from creation date)'|| to_char(l_batch_rec.from_creation_date));
   GMI_RESERVATION_UTIL.PrintLn('(Auto_Alloc) 3 WHERE clause is now '|| l_where_clause);

   IF ( TO_CHAR(l_batch_rec.from_creation_date) <> FND_API.G_MISS_CHAR AND
        TO_CHAR(l_batch_rec.from_creation_date, 'DD-MON-YYYY') <> ' ')
   THEN
      l_from_creation_date := TO_CHAR(l_batch_rec.from_creation_date,'DD-MON-YYYY');

      l_where_clause := l_where_clause || ' and lot_created >= ';
      l_where_clause := l_where_clause ||'TO_DATE( ';
      l_where_clause := l_where_clause || '''';
      l_where_clause := l_where_clause ||l_from_creation_date;
      l_where_clause := l_where_clause || '''';
      l_where_clause := l_where_clause || ',';
      l_where_clause := l_where_clause || '''';
      l_where_clause := l_where_clause || 'DD-MON-YYYY HH:MI:SS';
      l_where_clause := l_where_clause || '''';
      l_where_clause := l_where_clause || ')';
   END IF;

   GMI_RESERVATION_UTIL.PrintLn('(Auto_alloc)4 WHERE clause is now '|| l_where_clause);

   IF ( TO_CHAR(l_batch_rec.to_creation_date) <> FND_API.G_MISS_CHAR AND
        TO_CHAR(l_batch_rec.to_creation_date, 'DD-MON-YYYY') <> ' ')
   THEN
      l_to_creation_date := TO_CHAR((l_batch_rec.to_creation_date + 1),'DD-MON-YYYY');

      l_where_clause := l_where_clause || ' and lot_created <= ';
      l_where_clause := l_where_clause ||'TO_DATE( ';
      l_where_clause := l_where_clause || '''';
      l_where_clause := l_where_clause ||l_to_creation_date;
      l_where_clause := l_where_clause || '''';
      l_where_clause := l_where_clause || ',';
      l_where_clause := l_where_clause || '''';
      l_where_clause := l_where_clause || 'DD-MON-YYYY HH:MI:SS';
      l_where_clause := l_where_clause || '''';
      l_where_clause := l_where_clause || ')';
   END IF;

   IF ( TO_CHAR(l_batch_rec.from_expiration_date) <> FND_API.G_MISS_CHAR AND
        TO_CHAR(l_batch_rec.from_expiration_date, 'DD-MON-YYYY') <> ' ')
   THEN
      l_from_expiration_date := TO_CHAR(l_batch_rec.from_expiration_date,'DD-MON-YYYY');

      l_where_clause := l_where_clause || ' and expire_date >= ';
      l_where_clause := l_where_clause ||'TO_DATE( ';
      l_where_clause := l_where_clause || '''';
      l_where_clause := l_where_clause ||l_from_expiration_date;
      l_where_clause := l_where_clause || '''';
      l_where_clause := l_where_clause || ',';
      l_where_clause := l_where_clause || '''';
      l_where_clause := l_where_clause || 'DD-MON-YYYY';
      l_where_clause := l_where_clause || '''';
      l_where_clause := l_where_clause || ')';

   END IF;

   GMI_RESERVATION_UTIL.PrintLn('(Auto_Alloc) 5 WHERE clause is now '|| l_where_clause);

   IF ( TO_CHAR(l_batch_rec.to_expiration_date) <> FND_API.G_MISS_CHAR AND
        TO_CHAR(l_batch_rec.to_expiration_date, 'DD-MON-YYYY') <> ' ')
   THEN
      l_to_expiration_date := TO_CHAR((l_batch_rec.to_expiration_date+1),'DD-MON-YYYY');

      l_where_clause := l_where_clause || ' and expire_date <= ';
      l_where_clause := l_where_clause ||'TO_DATE( ';
      l_where_clause := l_where_clause || '''';
      l_where_clause := l_where_clause ||l_to_expiration_date;
      l_where_clause := l_where_clause || '''';
      l_where_clause := l_where_clause || ',';
      l_where_clause := l_where_clause || '''';
      l_where_clause := l_where_clause || 'DD-MON-YYYY';
      l_where_clause := l_where_clause || '''';
      l_where_clause := l_where_clause || ')';
   END IF;


   IF ( l_batch_rec.lot_status <> FND_API.G_MISS_CHAR AND
        nvl(l_batch_rec.lot_status,'%$%') <> '%$%')
   THEN
      l_where_clause := l_where_clause || ' and lot_status = ';
      l_where_clause := l_where_clause || '''' ;
      l_where_clause := l_where_clause || l_batch_rec.lot_status;
      l_where_clause := l_where_clause || '''';
   END IF;

   IF ( l_batch_rec.location <> FND_API.G_MISS_CHAR AND
        nvl(l_batch_rec.location,'%$%') <> '%$%')
   THEN
      l_where_clause := l_where_clause || ' and location = ';
      l_where_clause := l_where_clause || '''' ;
      l_where_clause := l_where_clause || l_batch_rec.location;
      l_where_clause := l_where_clause || '''';
   END IF;
   GMI_RESERVATION_UTIL.PrintLn('(Auto_Alloc) 6 WHERE clause is now '|| l_where_clause);

  /*Order rows according to the allocation method chosen
  =====================================================*/
  IF ( l_override_rules = 0 )  THEN
    IF (p_op_alot_prm.alloc_method = 0) THEN       /*  FIFO */
       l_order_by := ' lot_created' ;
    ELSE                                           /*  FEFO */
       l_order_by := ' expire_date';
    END IF;
  ELSE
     l_order_by := ' NULL';
  END IF;

  GMI_Reservation_Util.PrintLn('About to open cursor for dynamic SQL');
  gmi_reservation_util.println('OPM ALLOCATION ENGINE - open cursor for dynamic SQL',1);

 GMI_Reservation_Util.PrintLn('(Alloc PVT) l_grade_or_qcmatch_flag =  ' || l_grade_or_qcmatch_flag);
 GMI_Reservation_Util.PrintLn('(Alloc PVT) p_ic_item_mst.grade_ctl =  ' || p_ic_item_mst.grade_ctl);

   --2722339 	EMC 	Auto Alloc QC Spec Match Project
   --When Customer Spec is indicated on OPALOTED.fmb, grade is not used
   --in select.  When Grade is specified and a grade is specified on the
   --sales order line and/or OPALOTED.fmb, grade is used as part of the select
   --criteria. When either item is not grade controlled or no grade is
   --specified on so line or form,no grade is used as part of select.
   IF (NVL(l_grade_or_qcmatch_flag,0) = 1 ) THEN
    GMI_Reservation_Util.PrintLn('(Alloc PVT) Select A ') ;

    OPEN ic_inventory_view_c1 for
      'SELECT sum(loct_onhand),sum(loct_onhand2),
            sum(commit_qty),sum(commit_qty2),
            sum(loct_onhand) + sum(commit_qty),
            lot_no,sublot_no,lot_id,lot_status,
            lot_created,location,expire_date,qc_grade
            FROM ic_item_inv_v
       WHERE ' || l_where_clause  ||
       ' GROUP BY lot_no,sublot_no,lot_id,lot_status,
                  lot_created,location,expire_date,qc_grade' ||
       ' HAVING sum(loct_onhand) + sum(commit_qty) > 0 ' ||
       ' ORDER BY ' || l_order_by;
   ELSIF
     (NVL(l_grade_or_qcmatch_flag,0) = 0  AND
      p_ic_item_mst.grade_ctl = 1 AND
      l_allocation_rec.prefqc_grade is NOT NULL)  THEN
    BEGIN

    GMI_Reservation_Util.PrintLn('(Alloc PVT) Select B ') ;
    GMI_RESERVATION_UTIL.PRINTLN('where clause B'|| l_where_clause);
    GMI_RESERVATION_UTIL.PRINTLN('l_order_by'|| l_order_by);

    OPEN ic_inventory_view_c1 for
      'SELECT sum(loct_onhand),sum(loct_onhand2),
            sum(commit_qty),sum(commit_qty2),
            sum(loct_onhand) + sum(commit_qty),
            lot_no,sublot_no,lot_id,lot_status,
            lot_created,location,expire_date,qc_grade
            FROM ic_item_inv_v
       WHERE ' || l_where_clause  ||
       ' GROUP BY lot_no,sublot_no,lot_id,lot_status,
                  lot_created,location,expire_date,qc_grade' ||
       ' HAVING sum(loct_onhand) + sum(commit_qty) > 0 ' ||
       ' ORDER BY ' || l_order_by
         using l_allocation_rec.prefqc_grade;

    EXCEPTION
       WHEN OTHERS THEN
	   GMI_RESERVATION_UTIL.println('sqlerror'|| SUBSTRB(SQLERRM, 1, 100));
    END;
    GMI_Reservation_Util.PrintLn('(Alloc PVT) Select B after query') ;
   ELSIF
     (NVL(l_grade_or_qcmatch_flag,0) = 0  AND
      (p_ic_item_mst.grade_ctl <> 1 OR
      l_allocation_rec.prefqc_grade is NULL))  THEN
    GMI_Reservation_Util.PrintLn('(Alloc PVT) Select C ') ;
    GMI_Reservation_Util.PrintLn('(Alloc PVT) where clause' ||l_where_clause) ;

    OPEN ic_inventory_view_c1 for
      'SELECT sum(loct_onhand),sum(loct_onhand2),
            sum(commit_qty),sum(commit_qty2),
            sum(loct_onhand) + sum(commit_qty),
            lot_no,sublot_no,lot_id,lot_status,
            lot_created,location,expire_date,qc_grade
            FROM ic_item_inv_v
       WHERE ' || l_where_clause  ||
       ' GROUP BY lot_no,sublot_no,lot_id,lot_status,
                  lot_created,location,expire_date,qc_grade' ||
       ' HAVING sum(loct_onhand) + sum(commit_qty) > 0 '||
       ' ORDER BY ' || l_order_by;
  END IF;

   --2722339 	EMC 	Auto Alloc QC Spec Match Project
   --Call GMD_QC_SPEC_MATCH logic to determine whether spec_hdr_id exists.
  GMI_RESERVATION_UTIL.println('Alloc PVT after the cursor IF');

  IF (NVL(l_grade_or_qcmatch_flag,0) = 1) THEN
    OPEN Get_order_line_info;
    FETCH Get_order_line_info INTO
           l_header_id,
           l_sold_to_org_id,
           l_schedule_ship_date,
           l_ship_to_org_id,
           l_org_id,
           l_preferred_grade;
    CLOSE Get_order_line_info;

    find_cust_spec_rec.item_id := p_ic_item_mst.item_id;
    --find_cust_spec_rec.grade :=  l_allocation_rec.prefqc_grade;
    find_cust_spec_rec.orgn_code := NULL;
    find_cust_spec_rec.whse_code := p_ic_whse_mst.whse_code;
    find_cust_spec_rec.cust_id := l_sold_to_org_id;
    find_cust_spec_rec.date_effective := l_schedule_ship_date;
    find_cust_spec_rec.org_id := l_org_id;
    find_cust_spec_rec.ship_to_site_id := l_ship_to_org_id;
    find_cust_spec_rec.order_id := l_header_id;
    find_cust_spec_rec.order_line := NULL;
    find_cust_spec_rec.order_line_id :=p_allocation_rec.line_id;
    find_cust_spec_rec.look_in_other_orgn := 'Y';
    find_cust_spec_rec.exact_match := 'N';

    GMI_Reservation_Util.PrintLn('(Alloc PVT) Calling GMD_SPEC_MATCH_GRP.find_customer_spec ') ;
     l_out_rec := GMD_SPEC_MATCH_GRP.find_customer_spec
                     (p_customer_spec_rec      => find_cust_spec_rec
                     ,x_spec_id                => l_spec_hdr_id
                     ,x_spec_vr_id             => l_spec_vr_id
                     ,x_return_status          => l_spec_return_status
                     ,x_message_data           => l_message_data );
  END IF;
  GMI_Reservation_Util.PrintLn('(Alloc PVT) l_spec_hdr_id = ' || nvl(l_spec_hdr_id,0));


  --If spec_hdr_id exists, determine whether a customer match exists.
  --Otherwise, go through regular allocation code.

  LOOP
     GMI_Reservation_Util.PrintLn('(Alloc PVT) l_allocated_qty1 = ' || l_allocated_qty1) ;
     GMI_Reservation_Util.PrintLn('(Alloc PVT) l_inventory_qty1 = ' || l_inventory_qty1) ;

     IF (p_batch_id IS NULL OR l_batch_rec.alloc_all_lot_flag <> 'Y' OR
         l_overpick_enabled = 'N')
     THEN
        EXIT WHEN l_allocated_qty1 >= l_inventory_qty1;
     END IF;
     -- EXIT WHEN l_allocated_qty1 = l_inventory_qty1;
     --l_allocation_successful := NULL;

     FETCH ic_inventory_view_c1 INTO l_loct_onhand,l_loct_onhand2,
          l_commit_qty,l_commit_qty2,l_available_inventory1,
          l_lot_no,l_sublot_no,l_lot_id,l_lot_status,
          l_lot_created,l_location,l_expire_date,l_qc_grade;

     IF ic_inventory_view_c1%NOTFOUND THEN
       GMI_Reservation_Util.PrintLn('(Alloc PVT) Inside LOOP no rows bailing') ;
       gmi_reservation_util.println('OPM ALLOCATION ENGINE - no inventory rows found',1);
     END IF;

     EXIT WHEN ic_inventory_view_c1%NOTFOUND;

     --2722339 	EMC 	Auto Alloc QC Spec Match Project
     --If spec_hdr_id exists, determine whether a customer match exists.
     --Otherwise, go through regular allocation code.

     IF ( l_spec_hdr_id >0) THEN
      /* Commented since these dont exist in 12.0 ; P1 SCM Build bug #4561095
       result_lot_match_tbl(1).item_id := p_ic_item_mst.item_id;
       result_lot_match_tbl(1).lot_id := l_lot_id;
       result_lot_match_tbl(1).whse_code := p_ic_whse_mst.whse_code;
       result_lot_match_tbl(1).location := l_location;
    */

       GMI_Reservation_Util.PrintLn('(Alloc PVT) calling GMD_SPEC_MATCH_GRP.get_spec_match');

       GMD_SPEC_MATCH_GRP.get_result_match_for_spec
                (       p_spec_id           => l_spec_hdr_id
                ,       p_lots              => result_lot_match_tbl
                ,       x_return_status     => x2_return_status
                ,       x_message_data      => x2_message_data) ;

       GMI_Reservation_Util.PrintLn('(Alloc PVT) result_lot_match_tbl.COUNT = ' || nvl(result_lot_match_tbl.COUNT,0));
       GMI_Reservation_Util.PrintLn('(Alloc PVT) result_lot_match_tbl(1).spec_match_type = ' || result_lot_match_tbl(1).spec_match_type);


       IF (x2_return_status = 'S' AND result_lot_match_tbl.COUNT >0) THEN
          IF (result_lot_match_tbl(1).spec_match_type = 'A') THEN
              result_flag := 1;
              GMI_Reservation_Util.PrintLn('(Alloc PVT) result_flag = ' || result_flag);
          END IF;
       END IF;
    END IF; /*end l_spec_hdr_id >0 condition 1 */

    /*Interpret the rules on spliting the lot
    ========================================*/
    GMI_RESERVATION_UTIL.PrintLn('examining whse/lot_no/id/location/grade '
       || p_ic_whse_mst.whse_code || '/' || l_lot_no || '/' ||
       l_lot_id || '/' || l_location || '/' || l_qc_grade );

    gmi_reservation_util.println('examining whse/lot_no/id/location/grade '
      || p_ic_whse_mst.whse_code || '/' || l_lot_no || '/' ||
      l_lot_id || '/' || l_location || '/' || l_qc_grade );

    GMI_RESERVATION_UTIL.PrintLn('onhand    is ' || l_loct_onhand);
    GMI_RESERVATION_UTIL.PrintLn('committed is ' || l_commit_qty );
    GMI_RESERVATION_UTIL.PrintLn('available is ' || l_available_inventory1);
    GMI_RESERVATION_UTIL.PrintLn('what is lot_qty config '|| p_op_alot_prm.lot_qty);


    --2722339 	EMC 	Auto Alloc QC Spec Match Project
    --If Customer Spec indicated, allocate only to matched result rows

    GMI_Reservation_Util.PrintLn('(Alloc PVT) result flag : ' ||result_flag ) ;
    -- Bug 3180256 (adding NVL below)
    IF (result_flag = 1 OR NVL(l_grade_or_qcmatch_flag,0) = 0) THEN
        GMI_Reservation_Util.PrintLn('(Alloc PVT) Following regular logic flow.') ;
        l_lot_indivisible := p_ic_item_mst.lot_indivisible;
        IF( l_batch_rec.alloc_all_lot_flag = 'Y' OR
             l_batch_rec.lots_indivisible_flag = 'Y')
        THEN
           l_lot_indivisible := 1;
        END IF;
        l_lot_qty := p_op_alot_prm.lot_qty;
        IF(l_batch_rec.override_rules = 'Y')
        THEN
          l_lot_qty := 0;
        END IF;
        IF (l_lot_indivisible = 0)
        THEN           /*  lot can be split */
          GMI_RESERVATION_UTIL.PrintLn('lot_indivisible is off');
          IF (l_available_inventory1 >= l_unallocated_qty1) THEN
             l_trans_qty1 := l_unallocated_qty1;
             l_allocated_qty1 := l_allocated_qty1 + l_unallocated_qty1;
             l_unallocated_qty1 := 0;
             /*  demand fulfilled so invoke transaction processor */
             l_allocation_successful := 'Y';
          ELSIF (l_lot_qty = 0 )
                    /*  Use any number of lots  */
          THEN
              GMI_RESERVATION_UTIL.PrintLn('any number of lots ');
              GMI_RESERVATION_UTIL.PrintLn('available is less than required ' ||
                  l_available_inventory1 || ' ' || l_unallocated_qty1);
              l_trans_qty1 := l_available_inventory1;
              l_allocated_qty1 := l_allocated_qty1 + l_available_inventory1;
              l_unallocated_qty1 := l_inventory_qty1 - l_allocated_qty1;
              /*  demand fulfilled so invoke transaction processor */
              l_allocation_successful := 'Y';
          END IF;
        END IF;
        /* Deal with the lot indivisible scenario
        ========================================*/
        IF (l_lot_indivisible = 1)
                               /*  lot must not be split */
        THEN
           GMI_RESERVATION_UTIL.PrintLn('lot_indivisible is ON');
           IF (l_available_inventory1 <= l_unallocated_qty1) THEN
              GMI_RESERVATION_UTIL.PrintLn('less inventory than we need'
                     || l_available_inventory1 || ' versus ' || l_unallocated_qty1);
              l_trans_qty1 := l_available_inventory1;
              l_allocated_qty1 := l_allocated_qty1 + l_available_inventory1;
              l_unallocated_qty1 := l_inventory_qty1 - l_allocated_qty1;
              /*  invoke transaction processor */
              l_allocation_successful := 'Y';

           ELSIF (l_overpick_enabled = 'Y')THEN
              GMI_RESERVATION_UTIL.PrintLn('Lot indivisible is On or Alloc_all_lot_flag = Y');
              GMI_RESERVATION_UTIL.PrintLn('Allocating all the available inv for this row');
              l_trans_qty1 := l_available_inventory1;
              l_allocated_qty1 := l_allocated_qty1 + l_available_inventory1;
              l_unallocated_qty1 := l_inventory_qty1 - l_allocated_qty1;
              l_allocation_successful := 'Y';
           END IF;
        END IF;

        /*If suitable stock has been located, write a transaction to ic_tran_pnd
        =======================================================================*/
        GMI_Reservation_Util.PrintLn('(Alloc PVT) l_allocation_successful = ' || l_allocation_successful);
        If l_allocation_successful = 'Y' THEN
            /*Convert allocated qty to secondary UM where appropriate
            ========================================================*/
            GMI_RESERVATION_UTIL.PrintLn('secondary UM conv');
            IF p_ic_item_mst.dualum_ind > 0 THEN
              GMICUOM.icuomcv(pitem_id  => p_ic_item_mst.item_id,
                             plot_id   => l_lot_id,
                             pcur_qty  => l_trans_qty1,
                             pcur_uom  => p_ic_item_mst.item_um,
                             pnew_uom  => p_ic_item_mst.item_um2,
                             onew_qty  => l_trans_qty2);
            END IF;
            GMI_RESERVATION_UTIL.PrintLn('invoke txn engine');
            GMI_RESERVATION_UTIL.PrintLn('write txn for qty ' || l_trans_qty1);
            gmi_reservation_util.println('OPM ALLOCATION ENGINE - invoke transaction engine',1);
            /*Set up parameters in readiness for writing a pending transaction
            =================================================================*/
           l_tran_rec.trans_id   := NULL;
           l_tran_rec.item_id    := p_ic_item_mst.item_id;
           l_tran_rec.line_id    := p_allocation_rec.line_id;
           l_tran_rec.co_code    := p_allocation_rec.co_code;
           l_tran_rec.orgn_code  := p_ic_whse_mst.orgn_code;
           l_tran_rec.whse_code  := p_ic_whse_mst.whse_code;
           l_tran_rec.lot_id     := l_lot_id;
           l_tran_rec.location   := l_location;
           l_tran_rec.doc_id     := p_allocation_rec.doc_id;
           l_tran_rec.doc_type   := 'OMSO';
           l_tran_rec.doc_line   := p_allocation_rec.doc_line;
           l_tran_rec.line_type  := 0;
           l_tran_rec.trans_date := p_allocation_rec.trans_date;
           l_tran_rec.trans_qty := l_trans_qty1 * -1;
           IF p_ic_item_mst.dualum_ind > 0 THEN
             l_tran_rec.trans_qty2 := l_trans_qty2 * -1;
           ELSE
             l_tran_rec.trans_qty2 := NULL;
           END IF;

           IF p_ic_item_mst.grade_ctl > 0 THEN
             l_tran_rec.qc_grade :=  l_qc_grade;
           ELSE
             l_tran_rec.qc_grade :=  NULL;
           END IF;

           IF p_ic_item_mst.lot_ctl > 0 THEN
             l_tran_rec.lot_status := l_lot_status;
           ELSE
             l_tran_rec.lot_status := NULL;
           END IF;
           l_tran_rec.trans_um   := p_ic_item_mst.item_um;
           l_tran_rec.trans_um2  := p_ic_item_mst.item_um2;
           l_tran_rec.non_inv    := p_ic_item_mst.NONINV_IND;
           l_tran_rec.create_lot_index := 0;
           l_tran_rec.staged_ind := 0;
           l_tran_rec.text_code := NULL;
           l_tran_rec.user_id := p_allocation_rec.user_id;
           l_tran_rec.line_detail_id := p_allocation_rec.line_detail_id;

           GMI_Reservation_Util.PrintLn('(Alloc PVT) inserting trans ' );
           GMI_SHIPPING_UTIL.print_debug(l_tran_rec,'inserting');
           GMI_TRANS_ENGINE_PUB.create_pending_transaction
                             (p_api_version      => 1.0,
                              p_init_msg_list    => FND_API.G_TRUE,
                              p_commit           => FND_API.G_FALSE,
                              p_validation_level => FND_API.G_VALID_LEVEL_NONE,
                              p_tran_rec         => l_tran_rec,
                              x_tran_row         => l_tran_row,
                              x_return_status    => l_return_status,
                              x_msg_count        => l_msg_count,
                              x_msg_data         => l_msg_data
                             );

           IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             CLOSE ic_inventory_view_c1;
             RAISE FND_API.G_EXC_ERROR;
           ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           /* dbms_output.put_line('unexpected error back from txn engine'); */
             CLOSE ic_inventory_view_c1;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
         END IF; /*  ===== END OF ALLOCATION */
     END IF; /* result_flag = 1 OR l_grade_qcmatch_flag = 0*/
     --2722339 	EMC 	Auto Alloc QC Spec Match Project
     result_flag :=0;
     GMI_Reservation_Util.PrintLn('(Alloc PVT) end of try, result_flag = ' || result_flag);
  END LOOP;
  CLOSE ic_inventory_view_c1;


/* dbms_output.put_line('End of allocation loop'); */
  /*If partial allocation is NOT allowed, rollback any partial allocation
  and reset quantities to their original values
  Also if the item is not lot/location controlled, it is not possible to
  record a partial allocation; the whole quantity must be written against
  the default lot/location.
  ========================================================================*/

  IF (l_unallocated_qty1 > 0 and (p_op_alot_prm.partial_ind = 0 AND (l_override_rules = 0 ) ) )
   OR (l_unallocated_qty1 > 0 and p_ic_item_mst.lot_ctl = 0 AND l_loct_ctl = 0)
  THEN
/*   dbms_output.put_line  */
/*     ('Demand not fully met and partial alloc not allowed - special rollback'); */
    GMI_Reservation_Util.PrintLn('(Alloc PVT) partial not allowed, roll back ');
    GMI_Reservation_Util.PrintLn('(Alloc PVT) partial _ind'|| p_op_alot_prm.partial_ind);
    GMI_Reservation_Util.PrintLn('(Alloc PVT) lot_ctl '|| p_ic_item_mst.lot_ctl);
    GMI_Reservation_Util.PrintLn('(Alloc PVT) loct_ctl '|| l_loct_ctl);
    ROLLBACK to allocate_line;
    l_allocated_qty1 := 0;
    l_allocated_qty2 := 0;
    l_unallocated_qty1 := l_inventory_qty1;
    l_unallocated_qty2 := p_allocation_rec.order_qty2;
  END IF;

/* dbms_output.put_line('carry out final UM conversions'); */

  /*Convert allocated qty to secondary um if necessary
  ===================================================*/
  IF l_allocated_qty1 > 0 AND p_ic_item_mst.dualum_ind > 0 THEN
  /* dbms_output.put_line('convert allocated_qty to secondary'); */
    l_lot_id := 0;
    GMICUOM.icuomcv(pitem_id  => p_ic_item_mst.item_id,
                    plot_id   => l_lot_id,
                    pcur_qty  => l_allocated_qty1,
                    pcur_uom  => p_ic_item_mst.item_um,
                    pnew_uom  => p_ic_item_mst.item_um2,
                    onew_qty  => l_allocated_qty2);
    l_unallocated_qty2 := p_allocation_rec.order_qty2 - l_allocated_qty2;
  ELSIF l_allocated_qty1 = 0 AND p_ic_item_mst.dualum_ind > 0 THEN
    l_unallocated_qty2 := p_allocation_rec.order_qty2;
  ELSIF p_ic_item_mst.dualum_ind = 0 THEN
    l_allocated_qty2 := NULL;
    l_unallocated_qty2 := NULL;
  END IF;
  /*Convert allocated qty back to order_um if necessary
  ====================================================*/
  IF (l_allocated_qty1) > 0 AND
     (p_allocation_rec.order_um1 <> p_ic_item_mst.item_um) THEN
    l_lot_id := 0;
  /* dbms_output.put_line('convert allocated_qty to order_um'); */
    GMICUOM.icuomcv(pitem_id  => p_ic_item_mst.item_id,
                    plot_id   => l_lot_id,
                    pcur_qty  => l_allocated_qty1,
                    pcur_uom  => p_ic_item_mst.item_um,
                    pnew_uom  => p_allocation_rec.order_um1,
                    onew_qty  => x_allocated_qty1);
  ELSE
    x_allocated_qty1 := l_allocated_qty1;
  END IF;
  x_allocated_qty2 := l_allocated_qty2;

  /*Adjust the DEFAULT LOT transaction to reflect unallocated_qty
  =============================================================*/
  IF p_allocation_rec.prefqc_grade IS NOT NULL THEN
    l_allocation_rec.prefqc_grade := p_allocation_rec.prefqc_grade;
  ELSE
    l_allocation_rec.prefqc_grade := l_prm_prefqc_grade;
  END IF;
  GMI_ALLOCATE_INVENTORY_PVT.Balance_Default_Lot
                             (p_default_qty1 => l_unallocated_qty1 * -1,
                              p_default_qty2 => l_unallocated_qty2 * -1,
                              p_allocation_rec => p_allocation_rec,
                              p_ic_item_mst => p_ic_item_mst,
                              p_ic_whse_mst => p_ic_whse_mst,
                              x_return_status  => l_return_status,
                              x_msg_count      => l_msg_count,
                              x_msg_data       => l_msg_data
                            );

  GMI_Reservation_Util.PrintLn('(Alloc PVT) exiting, x_allocated_qty1 '|| x_allocated_qty1);
  GMI_Reservation_Util.PrintLn('(Alloc PVT) exiting, x_allocated_qty2 '|| x_allocated_qty2);
  /* EXCEPTION HANDLING
  ====================*/

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

END Allocate_Line;

/* +=========================================================================+
 | PROCEDURE NAME                                                          |
 |    Balance Default Lot                                                  |
 |                                                                         |
 | USAGE                                                                   |
 |    Ensure any unallocated qty is recorded against the DEFAULT LOT       |
 |                                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    Ensure any unallocated qty is recorded against the DEFAULT LOT       |
 |                                                                         |
 | PARAMETERS                                                              |
 |                                                                         |
 | HISTORY                                                                 |
 |    15-DEC-1999      K.Y.Hunt      Created                               |
 +=========================================================================+
*/
PROCEDURE BALANCE_DEFAULT_LOT
( p_default_qty1       IN  NUMBER
, p_default_qty2       IN  NUMBER
, p_allocation_rec     IN  GMI_AUTO_ALLOCATE_PUB.gmi_allocation_rec
, p_ic_item_mst        IN  ic_item_mst%ROWTYPE
, p_ic_whse_mst        IN  ic_whse_mst%ROWTYPE
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
)
IS
l_api_name             CONSTANT VARCHAR2 (30) := 'BALANCE_DEFAULT_LOT';
IC$DEFAULT_LOCT        VARCHAR2(255);
l_trans_id             NUMBER;
l_msg_count            NUMBER  :=0;
l_msg_data             VARCHAR2(2000);
l_return_status        VARCHAR2(1);
l_tran_rec             GMI_TRANS_ENGINE_PUB.ictran_rec;
l_tran_row             IC_TRAN_PND%ROWTYPE;
l_default_trans        ic_tran_pnd%ROWTYPE;

CURSOR ic_tran_pnd_c1 is
SELECT /*+ INDEX (ic_tran_pnd, ic_tran_pndi3) */ *
FROM ic_tran_pnd
WHERE item_id = p_ic_item_mst.item_id AND
    line_id = p_allocation_rec.line_id AND
    lot_id  = 0 AND
    doc_type= 'OMSO' AND
    completed_ind = 0 AND
    delete_mark = 0 AND
    location = IC$DEFAULT_LOCT;

BEGIN

/* dbms_output.put_line('start of balance_default_lot  '); */
/* dbms_output.put_line('one and two are ' || p_default_qty1 || ' and ' || p_default_qty2); */
  /*Initialize return status to success
  ====================================*/
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IC$DEFAULT_LOCT := FND_PROFILE.VALUE('IC$DEFAULT_LOCT');

/* dbms_output.put_line('DEFAULT LOT retrieved as '|| IC$DEFAULT_LOCT); */

  /*Determine whether or not a row exists for the DEFAULT LOT
  ==========================================================*/
  OPEN ic_tran_pnd_c1;
  FETCH ic_tran_pnd_c1 INTO l_default_trans;
  IF ic_tran_pnd_c1%NOTFOUND THEN
    CLOSE ic_tran_pnd_c1;
    /*Set up parameters in readiness for writing a pending transaction
    =================================================================*/
    l_tran_rec.trans_id   := NULL;
    l_tran_rec.item_id    := p_ic_item_mst.item_id;
    l_tran_rec.line_id    := p_allocation_rec.line_id;
    l_tran_rec.co_code    := p_allocation_rec.co_code;
    l_tran_rec.orgn_code  := p_ic_whse_mst.orgn_code;
    l_tran_rec.whse_code  := p_ic_whse_mst.whse_code;
    l_tran_rec.lot_id     := 0;
    l_tran_rec.location   := IC$DEFAULT_LOCT;
    l_tran_rec.doc_id     := p_allocation_rec.doc_id;
    l_tran_rec.doc_type   := 'OMSO';
    l_tran_rec.doc_line   := p_allocation_rec.doc_line;
    l_tran_rec.line_type  := 0;
    l_tran_rec.trans_date := p_allocation_rec.trans_date;
    l_tran_rec.trans_qty  := p_default_qty1;
    IF p_ic_item_mst.dualum_ind > 0 THEN
      l_tran_rec.trans_qty2 := p_default_qty2;
    ELSE
      l_tran_rec.trans_qty2 := NULL;
    END IF;

    /* If there is a preferred grade, target this within the transaction
    details.  Grade may be used within planning in the future so it should
    be logged.
    =====================================================================*/
    IF p_allocation_rec.prefqc_grade is NOT NULL THEN
      l_tran_rec.qc_grade :=  p_allocation_rec.prefqc_grade;
    END IF;

    /* Regardless of lot control attribute, set lot status to null for
    the DEFAULT posting.  This will highlight the quantity as nettable
    for MRP purposes.
    ===================================================================*/
    l_tran_rec.lot_status := NULL;
    l_tran_rec.trans_um   := p_ic_item_mst.item_um;
    l_tran_rec.trans_um2  := p_ic_item_mst.item_um2;
    l_tran_rec.staged_ind := 0;
    l_tran_rec.text_code  := NULL;
    l_tran_rec.user_id    := p_allocation_rec.user_id;
    l_tran_rec.non_inv    := p_ic_item_mst.NONINV_IND;
    l_tran_rec.create_lot_index := 0;
  /* dbms_output.put_line('write a NEW default LOT txn'); */
    GMI_TRANS_ENGINE_PUB.create_pending_transaction
                         (p_api_version      => 1.0,
                          p_init_msg_list    => FND_API.G_TRUE,
                          p_commit           => FND_API.G_FALSE,
                          p_validation_level => FND_API.G_VALID_LEVEL_NONE,
                          p_tran_rec         => l_tran_rec,
                          x_tran_row         => l_tran_row,
                          x_return_status    => l_return_status,
                          x_msg_count        => l_msg_count,
                          x_msg_data         => l_msg_data
                         );

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    /* dbms_output.put_line('unexpected error return from txn engine'); */
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  ELSE
    CLOSE ic_tran_pnd_c1;

    /*This is a UPDATE scenario so ..........
    Set up parameters in readiness for updating the pending transaction
    ====================================================================*/
    l_tran_rec.trans_id  := l_default_trans.trans_id;
    l_tran_rec.item_id   := l_default_trans.item_id;
    l_tran_rec.line_id   := l_default_trans.line_id;
    l_tran_rec.co_code   := l_default_trans.co_code;
    l_tran_rec.orgn_code := l_default_trans.orgn_code;
    l_tran_rec.whse_code := l_default_trans.whse_code;
    l_tran_rec.lot_id   :=  l_default_trans.lot_id;
    l_tran_rec.location :=  l_default_trans.location;
    l_tran_rec.doc_id   :=  l_default_trans.doc_id;
    l_tran_rec.doc_type := 'OMSO';
    l_tran_rec.doc_line :=  l_default_trans.doc_line;
    l_tran_rec.line_type := l_default_trans.line_type;
    l_tran_rec.trans_date := l_default_trans.trans_date;
    l_tran_rec.trans_qty :=  p_default_qty1;
    IF p_ic_item_mst.dualum_ind > 0 THEN
      l_tran_rec.trans_qty2 := p_default_qty2;
    ELSE
      l_tran_rec.trans_qty2 := NULL;
    END IF;

    IF p_ic_item_mst.grade_ctl > 0 THEN
      l_tran_rec.qc_grade :=  p_allocation_rec.prefqc_grade;
    ELSE
      l_tran_rec.qc_grade :=  NULL;
    END IF;

    l_tran_rec.lot_status := p_ic_item_mst.lot_status;
    l_tran_rec.trans_um   := l_default_trans.trans_um;
    l_tran_rec.trans_um2  := l_default_trans.trans_um2;
    l_tran_rec.staged_ind := l_default_trans.staged_ind;
    l_tran_rec.user_id := p_allocation_rec.user_id;
    l_tran_rec.non_inv    := p_ic_item_mst.NONINV_IND;
    l_tran_rec.create_lot_index := 0;
  /* dbms_output.put_line('UPDATE the existing default LOT txn'); */
    GMI_TRANS_ENGINE_PUB.update_pending_transaction
                         (p_api_version      => 1.0,
                          p_init_msg_list    => FND_API.G_TRUE,
                          p_commit           => FND_API.G_FALSE,
                          p_validation_level => FND_API.G_VALID_LEVEL_NONE,
                          p_tran_rec         => l_tran_rec,
                          x_tran_row         => l_tran_row,
                          x_return_status    => l_return_status,
                          x_msg_count        => l_msg_count,
                          x_msg_data         => l_msg_data
                         );
  END IF;


  /* EXCEPTION HANDLING
  ====================*/

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

END Balance_Default_Lot;

/* +=========================================================================+
 | FUNCTION NAME                                                           |
 |    Check_existing_allocations                                           |
 |                                                                         |
 | TYPE                                                                    |
 |    PRIVATE                                                              |
 |                                                                         |
 | USAGE                                                                   |
 |    Used to determine whether allocations already exist against the      |
 |    order/shipment line in question                                      |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    This function checks ic_tran_pnd for outstanding allocations         |
 |    against the order/shipment line.                                     |
 |                                                                         |
 | PARAMETERS                                                              |
 |    p_doc_id            Surrogate key relating to the order/shipment     |
 |    p_line_id           Surrogate key realting to the order line         |
 |                                                                         |
 | RETURNS                                                                 |
 |    BOOLEAN                                                              |
 |                                                                         |
 | HISTORY                                                                 |
 |    06-JAN-2000      Karen Y. Hunt        Created                        |
 +=========================================================================+
*/
FUNCTION Check_existing_allocations
( p_doc_id        IN ic_tran_pnd.doc_id%TYPE
, p_line_id       IN ic_tran_pnd.line_id%TYPE
, p_lot_ctl       IN ic_item_mst.lot_ctl%TYPE
, p_item_loct_ctl IN ic_item_mst.loct_ctl%TYPE
, p_whse_loct_ctl IN ic_whse_mst.loct_ctl%TYPE
)
RETURN BOOLEAN
IS
l_api_name             CONSTANT VARCHAR2 (30) := 'CHECK_EXISTING_ALLOCATIONS';
l_sum_trans_qty        NUMBER;
IC$DEFAULT_LOCT        VARCHAR2(255);

/*  Scenario a) item has lot control */
/*  ================================ */
CURSOR ic_tran_pnd_c1 IS
SELECT /*+ INDEX (ic_tran_pnd, ic_tran_pndi3) */
  sum(trans_qty)
FROM
  ic_tran_pnd
WHERE
  doc_id        = p_doc_id AND
  line_id       = p_line_id AND
  doc_type      = 'OMSO' AND
  lot_id        > 0 AND
--  completed_ind = 0 AND
  delete_mark   = 0;

/*  Scenario b) item has location control */
/*  ===================================== */
CURSOR ic_tran_pnd_c2 IS
SELECT /*+ INDEX (ic_tran_pnd, ic_tran_pndi3) */
  sum(trans_qty)
FROM
  ic_tran_pnd
WHERE
  doc_id        = p_doc_id AND
  line_id       = p_line_id AND
  location      <>IC$DEFAULT_LOCT AND
  doc_type      = 'OMSO' AND
-- completed_ind = 0 AND
  delete_mark   = 0;

/*  Scenario c) item has NO lot or location control */
/*  =============================================== */
CURSOR ic_tran_pnd_c3 IS
SELECT /*+ INDEX (ic_tran_pnd, ic_tran_pndi3) */
  sum(trans_qty)
FROM
  ic_tran_pnd
WHERE
  doc_id        = p_doc_id AND
  line_id       = p_line_id AND
  doc_type      = 'OMSO' AND
--  completed_ind = 0 AND
  delete_mark   = 0;


BEGIN
  IF p_lot_ctl > 0 THEN
  /* dbms_output.put_line('check allocations for lot control '); */
    OPEN ic_tran_pnd_c1;
    FETCH ic_tran_pnd_c1 into l_sum_trans_qty;
    IF (ic_tran_pnd_c1%NOTFOUND) THEN
      l_sum_trans_qty  :=0;
    END IF;
    CLOSE ic_tran_pnd_c1;
  ELSIF (p_item_loct_ctl > 0 OR p_whse_loct_ctl > 0) THEN
  /* dbms_output.put_line('check allocations for location control '); */
    IC$DEFAULT_LOCT := FND_PROFILE.VALUE('IC$DEFAULT_LOCT');
    OPEN ic_tran_pnd_c2;
    FETCH ic_tran_pnd_c2 into l_sum_trans_qty;
    IF (ic_tran_pnd_c2%NOTFOUND) THEN
      l_sum_trans_qty  :=0;
    END IF;
    CLOSE ic_tran_pnd_c2;
  ELSE
  /* dbms_output.put_line('check allocations - no lot/loct control '); */
    OPEN ic_tran_pnd_c3;
    FETCH ic_tran_pnd_c3 into l_sum_trans_qty;
    IF (ic_tran_pnd_c3%NOTFOUND) THEN
      l_sum_trans_qty  :=0;
    END IF;
    CLOSE ic_tran_pnd_c3;
  END IF;


  IF l_sum_trans_qty <> 0 THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
    /* dbms_output.put_line('problem checking existing allocations '); */
      RAISE;

END Check_existing_allocations;

/* +=========================================================================+
 | FUNCTION NAME                                                           |
 |    Allocations_Exist                                                    |
 |                                                                         |
 | TYPE                                                                    |
 |    PRIVATE                                                              |
 |                                                                         |
 | USAGE                                                                   |
 |    Used to determine whether allocations already exist against the      |
 |    order/shipment line in question                                      |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    This function checks ic_tran_pnd for outstanding allocations         |
 |    against the order/shipment line.                                     |
 |                                                                         |
 | PARAMETERS                                                              |
 |    p_doc_id            Surrogate key relating to the order/shipment     |
 |    p_line_id           Surrogate key realting to the order line         |
 |                                                                         |
 | RETURNS                                                                 |
 |    BOOLEAN                                                              |
 |                                                                         |
 | HISTORY                                                                 |
 |    06-JAN-2000      Karen Y. Hunt        Created                        |
 +=========================================================================+
*/
FUNCTION Unstaged_Allocations_Exist
( p_doc_id        IN ic_tran_pnd.doc_id%TYPE
, p_line_id       IN ic_tran_pnd.line_id%TYPE
)
RETURN BOOLEAN
IS
l_api_name             CONSTANT VARCHAR2 (30) := 'ALLOCATIONS_EXIST';
l_sum_trans_qty        NUMBER;
IC$DEFAULT_LOCT        VARCHAR2(255) := FND_PROFILE.VALUE('IC$DEFAULT_LOCT');

CURSOR ic_tran_pnd_c1 IS
SELECT  /*+ INDEX (ic_tran_pnd, ic_tran_pndi3) */
  sum(trans_qty)
FROM
  ic_tran_pnd
WHERE
  doc_id        = p_doc_id AND
  line_id       = p_line_id AND
  doc_type      = 'OMSO' AND
  ((lot_id       > 0) OR
  (location     <>IC$DEFAULT_LOCT)) AND
  staged_ind    <> 1 AND
  doc_type      = 'OMSO' AND
  completed_ind = 0 AND
  delete_mark   = 0;

BEGIN
  OPEN ic_tran_pnd_c1;
  FETCH ic_tran_pnd_c1 into l_sum_trans_qty;
  IF (ic_tran_pnd_c1%NOTFOUND) THEN
    l_sum_trans_qty  :=0;
  END IF;

  IF l_sum_trans_qty <> 0 THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      RAISE;

END Unstaged_Allocations_Exist;

END GMI_ALLOCATE_INVENTORY_PVT;

/
