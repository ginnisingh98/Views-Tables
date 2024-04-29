--------------------------------------------------------
--  DDL for Package Body GML_MOBILE_MOVE_ORDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_MOBILE_MOVE_ORDER" AS
  /* $Header: GMLMOMBB.pls 120.0 2005/05/25 16:18:40 appldev noship $ */



g_gtin_cross_ref_type VARCHAR2(25) := fnd_profile.value('INV:GTIN_CROSS_REFERENCE_TYPE');
g_gtin_code_length NUMBER := 14;

PROCEDURE Get_Allocation_Parameters(p_alloc_class IN VARCHAR2,
                                    p_org_id IN NUMBER,
                                    p_cust_id IN NUMBER,
                                    p_ship_to_org_id IN NUMBER,
                                    x_grade OUT NOCOPY VARCHAR2,
                                    x_return_status OUT NOCOPY VARCHAR2) IS
l_msg_count          NUMBER  := 0;
l_msg_data           VARCHAR2(2000);
l_return_status      VARCHAR2(1);
l_op_alot_prm_rec    op_alot_prm%ROWTYPE;

BEGIN

  GMI_ALLOCATION_RULES_PVT.GET_ALLOCATION_PARMS
                           ( p_alloc_class   => p_alloc_class,
                             p_org_id        => p_org_id,
                             p_of_cust_id    => p_cust_id,
                             p_ship_to_org_id=> p_ship_to_org_id,
                             x_return_status => x_return_status,
                             x_op_alot_prm   => l_op_alot_prm_rec,
                             x_msg_count     => l_msg_count,
                             x_msg_data      => l_msg_data
                            );

  x_grade := ' ';

  IF (l_return_status = FND_API.G_RET_STS_SUCCESS)
  THEN

    x_grade := l_op_alot_prm_rec.PREFQC_GRADE;

  END IF;

END Get_Allocation_Parameters;

PROCEDURE Save_Allocation(p_transaction_id   IN NUMBER,
                          p_lot_id           IN NUMBER,
                          p_location         IN VARCHAR2,
                          p_allocated_qty    IN NUMBER,
                          p_allocated_qty2   IN NUMBER,
                          p_grade            IN VARCHAR2,
                          p_lot_no           IN VARCHAR2,
                          p_lot_status       IN VARCHAR2,
                          p_transaction_date IN DATE,
                          p_reason_code      IN VARCHAR2,
                          p_item_id          IN NUMBER,
                          p_line_id          IN NUMBER,
                          p_warehouse_code   IN VARCHAR2,
                          p_line_detail_id   IN NUMBER,
                          p_transaction_um   IN VARCHAR2,
                          p_transaction_um2  IN VARCHAR2,
                          p_mo_line_id       IN NUMBER,
                          x_return_status    OUT NOCOPY VARCHAR2,
                          x_error_msg        OUT NOCOPY VARCHAR2) IS

  l_msg_count          NUMBER  := 0;
  l_msg_data           VARCHAR2(2000);
  l_return_status      VARCHAR2(1);
  l_ictran_rec         GMI_TRANS_ENGINE_PUB.ictran_rec;
  l_dummy              NUMBER;


  BEGIN

    l_ictran_rec.trans_id 	:= p_transaction_id;
    l_ictran_rec.lot_id 	:= p_lot_id;
    l_ictran_rec.location 	:= p_location;
    l_ictran_rec.trans_qty 	:= p_allocated_qty;
    l_ictran_rec.trans_qty2 	:= p_allocated_qty2;
    l_ictran_rec.qc_grade 	:= p_grade;
    l_ictran_rec.lot_no 	:= p_lot_no;
    l_ictran_rec.lot_status 	:= p_lot_status;
    l_ictran_rec.trans_date 	:= p_transaction_date;
    l_ictran_rec.reason_code    := p_reason_code;
    l_ictran_rec.item_id	:= p_item_id;
    l_ictran_rec.line_id 	:= p_line_id;
    l_ictran_rec.co_code 	:= NULL;
    l_ictran_rec.orgn_code	:= NULL;
    l_ictran_rec.whse_code 	:= p_warehouse_code;
    l_ictran_rec.doc_id 	:= NULL;
    l_ictran_rec.doc_type 	:= 'OMSO';
    l_ictran_rec.doc_line 	:= NULL;
    l_ictran_rec.line_detail_id := p_line_detail_id;
    l_ictran_rec.line_type	:= 0;
    l_ictran_rec.trans_stat 	:= NULL;
    l_ictran_rec.trans_um 	:= p_transaction_um;
    l_ictran_rec.trans_um2 	:= p_transaction_um2;
    l_ictran_rec.staged_ind 	:= 0;
    l_ictran_rec.event_id 	:= 0;
    l_ictran_rec.text_code 	:= 0;
    l_ictran_rec.user_id 	:= NULL;
    l_ictran_rec.create_lot_index := NULL;

    GMI_RESERVATION_UTIL.Set_Pick_Lots (
	     	p_ic_tran_rec    => l_ictran_rec
      	      , p_mo_line_id     => p_mo_line_id
              , p_commit	 => FND_API.G_FALSE
   	      , x_return_status  => x_return_status
   	      , x_msg_count      => l_msg_count
   	      , x_msg_data 	 => l_msg_data );

   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
   THEN
     FND_MSG_PUB.GET( p_msg_index     => 1,
                      p_data          => x_error_msg,
                      p_encoded       => 'F',
                      p_msg_index_out => l_dummy);
   END IF;


END Save_Allocation;


PROCEDURE Auto_Allocate(p_allow_delete  IN NUMBER,
                          p_mo_line_id    IN NUMBER,
                          p_transaction_header_id IN NUMBER,
                          p_move_order_type    IN NUMBER,
                          x_number_of_rows     OUT NOCOPY NUMBER,
                          x_qc_grade           OUT NOCOPY VARCHAR2,
                          x_detailed_qty       OUT NOCOPY NUMBER,
                          x_qty_UM             OUT NOCOPY VARCHAR2,
                          x_detailed_qty2      OUT NOCOPY NUMBER,
                          x_qty_UM2            OUT NOCOPY VARCHAR2,
                          x_return_status      OUT NOCOPY VARCHAR2,
                          x_error_msg          OUT NOCOPY VARCHAR2) IS

    l_return_status        VARCHAR2(10);
    l_count                NUMBER;
    l_dummy                NUMBER;
    l_msg                  VARCHAR2(2000);
    l_p_allow_delete	   VARCHAR2(3);

 BEGIN

  DBMS_TRANSACTION.SAVEPOINT('AUTO_DETAIL_SAVE');

  IF (p_allow_delete = 1) THEN
    l_p_allow_delete := 'YES';
  ELSE
    l_p_allow_delete := 'NO';
  END IF;


  GMI_Move_Order_Line_Util.Line_Auto_Detail
    (
	    p_mo_line_id              => p_mo_line_id
          , p_init_msg_list           => 1
       	  , p_transaction_header_id   => NULL
    	  , p_transaction_mode        => NULL
          , p_move_order_type         => p_move_order_type
	  , p_allow_delete	      => l_p_allow_delete
          , x_number_of_rows          => x_number_of_rows
          , x_qc_grade                => x_qc_grade
          , x_detailed_qty            => x_detailed_qty
          , x_qty_UM                  => x_qty_UM
          , x_detailed_qty2           => x_detailed_qty2
          , x_qty_UM2                 => x_qty_UM
          , x_return_status           => x_return_status
          , x_msg_count               => l_count
          , x_msg_data                => l_msg
    );


  IF (x_return_status <> 'S')
  THEN
     FND_MSG_PUB.GET( p_msg_index     => 1,
                      p_data          => x_error_msg,
                      p_encoded       => 'F',
                      p_msg_index_out => l_dummy);
     DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('AUTO_DETAIL_SAVE');
     x_return_status := 'E';
  END IF;

EXCEPTION
      WHEN others THEN
        x_return_status := 'E';
        DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('AUTO_DETAIL_SAVE');
        FND_Message.Set_Name('INV','UNEXP_ERROR_AUTO_DETAIL');
        x_error_msg := FND_MESSAGE.GET;

END Auto_Allocate;




PROCEDURE Get_Sales_Order_LoV( x_so_mo_lov OUT NOCOPY t_genref,
                         p_org_id IN NUMBER,
                         p_so_no  IN VARCHAR2) IS
BEGIN

  OPEN x_so_mo_lov FOR
    SELECT
    oeh.order_number,
    oeh.header_id,
    moh.request_number mo_number
  FROM
    ic_txn_request_headers moh,
    ic_txn_request_lines mol,
    oe_order_lines_all oel,
    oe_order_headers_all oeh
   WHERE oeh.header_id = oel.header_id
     AND oeh.order_number LIKE (p_so_no)
     AND   oel.line_id = mol.txn_source_line_id
     AND   moh.header_id = mol.header_id
     AND   mol.organization_id = p_org_id
     AND   mol.line_status in (3,7)
     GROUP BY oeh.order_number, oeh.header_id, moh.request_number
   ORDER BY oeh.order_number;

--  OPEN x_so_mo_lov FOR
--    SELECT
--    /*+ ORDERED
--    INDEX(moh ic_txn_request_headers_pk)
--    INDEX(oel oe_order_lines_u1)
--    INDEX(oeh oe_order_headers_u1)
--    */
--    oeh.order_number,
--    oeh.header_id,
--    moh.request_number mo_number
--   FROM
--    (SELECT /*+ INDEX(itr ic_txn_request_lines_n1) */
--             DISTINCT header_id, txn_source_line_id
--     FROM  ic_txn_request_lines itr
--     WHERE organization_id = p_org_id
--     AND   line_status in (3,7)
--     ) mol,
--    ic_txn_request_headers moh,
--    oe_order_lines_all oel,
--    oe_order_headers_all oeh
--   WHERE oeh.header_id = oel.header_id
--     AND oeh.order_number LIKE (p_so_no)
--     AND   oel.line_id = mol.txn_source_line_id
--     AND   oel.flow_status_code NOT IN ('CLOSED','CANCELLED')
--     AND   moh.header_id = mol.header_id
--     GROUP BY oeh.order_number, oeh.header_id, moh.request_number
--   ORDER BY oeh.order_number;

END Get_Sales_Order_LoV;

PROCEDURE Get_Item_LoV( x_mo_item_lov OUT NOCOPY t_genref,
                        p_org_id IN NUMBER,
                        p_item_no IN VARCHAR2) IS

 l_cross_ref VARCHAR2(204);

BEGIN


 l_cross_ref := lpad(Rtrim(p_item_no, '%'), g_gtin_code_length, '00000000000000');


  OPEN x_mo_item_lov FOR

       SELECT DISTINCT opi.item_no, opi.item_desc1, opi.item_id, mti.inventory_item_id
       FROM    mtl_system_items mti,
               ic_item_mst opi,
               ic_txn_request_lines l
       WHERE opi.item_no = mti.segment1
             and opi.item_no LIKE (p_item_no)
             and mti.organization_id = p_org_id
             and mti.inventory_item_flag = 'Y'
             and mti.inventory_item_id = l.inventory_item_id

       UNION

       SELECT DISTINCT opi.item_no, opi.item_desc1, opi.item_id, mti.inventory_item_id
       FROM    mtl_system_items mti,
               ic_item_mst opi,
               mtl_cross_references mcr
       WHERE
             mti.organization_id = p_org_id
             AND opi.item_no = mti.segment1
             AND mti.inventory_item_id = mcr.inventory_item_id
             AND    mcr.cross_reference_type = g_gtin_cross_ref_type
             AND    mcr.cross_reference      LIKE l_cross_ref
             AND    (mcr.organization_id = mti.organization_id
             OR
             mcr.org_independent_flag = 'Y');

END Get_Item_LoV;

PROCEDURE Get_Location_Lov( x_location_lov OUT NOCOPY t_genref,
                            p_location IN VARCHAR2,
                            p_item_id IN NUMBER,
                            p_whse_code IN VARCHAR2,
                            p_lot_id IN NUMBER,
                            p_neg_inv_allowed IN INTEGER) IS
  CURSOR Get_Loct_Ctl IS
    SELECT
      loct_ctl
    FROM
      ic_item_mst
    WHERE
      item_id = p_item_id;

  l_loct_ctl NUMBER(1);
  l_lot_id   NUMBER(20);

BEGIN

  OPEN Get_Loct_Ctl;
  FETCH Get_Loct_Ctl INTO l_loct_ctl;
  CLOSE Get_Loct_Ctl;

  IF p_lot_id <= 0 THEN
   l_lot_id := NULL;
  ELSE
   l_lot_id := p_lot_id;
  END IF;

  IF p_neg_inv_allowed  = 0 THEN

    IF l_loct_ctl <> 2 THEN

      OPEN x_location_lov FOR
       select distinct inv.location, NVL(loc.loct_desc, inv.location)
       from ic_loct_inv inv, ic_loct_mst loc
       where inv.whse_code = p_whse_code and inv.delete_mark = 0 and
           inv.location like (p_location)
           and inv.lot_id = nvl(l_lot_id,inv.lot_id)
           and inv.loct_onhand > 0
           and inv.item_id = p_item_id
           and loc.location = inv.location;
    ELSE

      OPEN x_location_lov FOR
       select distinct inv.location, NVL(loc.loct_desc, inv.location)
       from ic_loct_inv inv, ic_loct_mst loc
       where inv.whse_code = p_whse_code and inv.delete_mark = 0 and
           inv.location like (p_location)
           and inv.lot_id = nvl(l_lot_id,inv.lot_id)
           and inv.loct_onhand > 0
           and inv.item_id = p_item_id
           and loc.location(+) = inv.location;
    END IF;

   ELSE

    IF l_loct_ctl <> 2 THEN

      OPEN x_location_lov FOR
       select distinct inv.location, NVL(loc.loct_desc, inv.location)
       from ic_loct_inv inv, ic_loct_mst loc
        where inv.whse_code = p_whse_code and inv.delete_mark = 0 and
           inv.location like (p_location)
           and inv.lot_id = nvl(l_lot_id,inv.lot_id)
           and inv.item_id = p_item_id
           and loc.location = inv.location;
    ELSE

      OPEN x_location_lov FOR
       select distinct inv.location, NVL(loc.loct_desc, inv.location)
       from ic_loct_inv inv, ic_loct_mst loc
        where inv.whse_code = p_whse_code and inv.delete_mark = 0 and
           inv.location like (p_location)
           and inv.lot_id = nvl(l_lot_id,inv.lot_id)
           and inv.item_id = p_item_id
           and loc.location(+) = inv.location;
    END IF;

   END IF;

END Get_Location_Lov;

PROCEDURE Get_Lot_LoV( x_lot_lov         OUT NOCOPY t_genref,
                       p_lot_no          IN VARCHAR2,
                       p_item_id         IN NUMBER,
                       p_whse_code       IN VARCHAR2,
                       p_location        IN VARCHAR2,
                       p_pref_grade      IN VARCHAR2,
                       p_neg_inv_allowed IN INTEGER) IS
  l_location   VARCHAR2(4);
  l_pref_grade VARCHAR2(4);

BEGIN

  IF p_location IS NULL OR p_location = ' ' THEN
    l_location := NULL;
  ELSE
    l_location := p_location;
  END IF;

  IF p_pref_grade IS NULL OR p_pref_grade = ' ' THEN
    l_pref_grade := NULL;
  ELSE
    l_pref_grade := p_pref_grade;
  END IF;

  IF p_neg_inv_allowed  = 0 THEN

    IF l_pref_grade IS NULL THEN


      OPEN x_lot_lov FOR
         select distinct lot_no,sublot_no, a.lot_id,a.qc_grade, b.lot_status
         from ic_lots_mst a, ic_loct_inv b
         where a.lot_no like (p_lot_no) and a.lot_id <> 0 and a.lot_id =b.lot_id  and a.item_id = b.item_id and
             a.delete_mark = 0 and b.delete_mark = 0 and a.item_id = p_item_id and
             b.whse_code = p_whse_code and b.location = nvl(l_location,b.location)
              and b.loct_onhand > 0 and a.expire_date >= sysdate
         order by lot_no;

    ELSE

      OPEN x_lot_lov FOR
         select distinct lot_no,sublot_no, a.lot_id,a.qc_grade, b.lot_status
         from ic_lots_mst a, ic_loct_inv b
         where  a.lot_no like (p_lot_no) and a.lot_id <> 0 and a.lot_id =b.lot_id and a.item_id = b.item_id and
             a.delete_mark = 0 and b.delete_mark = 0 and a.item_id = p_item_id and
             b.whse_code = p_whse_code and b.location = nvl(l_location,b.location)
             and a.qc_grade = l_pref_grade
              and b.loct_onhand > 0 and a.expire_date >= sysdate
         order by lot_no;

    END IF;

  ELSE

    IF l_pref_grade IS NULL THEN

      OPEN x_lot_lov FOR
         select distinct lot_no,sublot_no, a.lot_id,a.qc_grade,b.lot_status
         from ic_lots_mst a, ic_loct_inv b
         where a.lot_no like (p_lot_no) and a.lot_id <> 0 and a.lot_id =b.lot_id
 and a.item_id = b.item_id and
             a.delete_mark = 0 and b.delete_mark = 0 and a.item_id = p_item_id and
             b.whse_code = p_whse_code and b.location = nvl(l_location,b.location)
              and a.expire_date >= sysdate
         order by lot_no;

    ELSE


      OPEN x_lot_lov FOR
         select distinct lot_no,sublot_no, a.lot_id,a.qc_grade,b.lot_status
         from ic_lots_mst a, ic_loct_inv b
         where a.lot_no like (p_lot_no) and a.lot_id <> 0 and a.lot_id =b.lot_id
 and a.item_id = b.item_id and
             a.delete_mark = 0 and b.delete_mark = 0 and a.item_id = p_item_id and
             b.whse_code = p_whse_code and b.location = nvl(l_location,b.location)
             and a.qc_grade = l_pref_grade
              and a.expire_date >= sysdate
         order by lot_no;

    END IF;

  END IF;

END Get_Lot_LoV;

PROCEDURE Get_Sub_Lot_LoV( x_sub_lot_lov     OUT NOCOPY t_genref,
                                       p_item_id         IN NUMBER,
                                       p_whse_code       IN VARCHAR2,
                                       p_location        IN VARCHAR2,
                                       p_lot_no          IN VARCHAR2,
                                       p_sublot_no       IN VARCHAR2,
                                       p_neg_inv_allowed IN INTEGER) IS
  l_location VARCHAR2(4);

BEGIN


  IF p_location IS NULL OR p_location = ' ' THEN
    l_location := NULL;
  ELSE
    l_location := p_location;
  END IF;

  IF p_neg_inv_allowed  = 0 THEN

    OPEN x_sub_lot_lov FOR
      select distinct sublot_no, a.qc_grade, b.lot_status, a.lot_id
      from ic_lots_mst a, ic_loct_inv b
      where a.lot_id <> 0 and a.lot_id = b.lot_id and a.item_id = b.item_id and
a.delete_mark = 0 and

            b.delete_mark = 0 and b.whse_code = p_whse_code and a.lot_no = p_lot_no and b.loct_onhand > 0
            and b.location = nvl(l_location, b.location) and a.expire_date >= sysdate and
            a.sublot_no LIKE (p_sublot_no) and a.item_id = p_item_id order by sublot_no;

   ELSE

    OPEN x_sub_lot_lov FOR
      select distinct sublot_no, a.qc_grade, b.lot_status, a.lot_id
      from ic_lots_mst a, ic_loct_inv b
      where a.lot_id <> 0 and a.lot_id = b.lot_id and a.item_id = b.item_id and
a.delete_mark = 0 and

            b.delete_mark = 0 and b.whse_code = p_whse_code and a.lot_no = p_lot_no
            and b.location = nvl(l_location, b.location) and a.expire_date >= sysdate and
            a.sublot_no LIKE (p_sublot_no) and a.item_id = p_item_id order by sublot_no;

   END IF;

END Get_Sub_Lot_LoV;


  PROCEDURE Get_Move_Order_LoV(x_pwmo_lov OUT NOCOPY t_genref,
                               p_organization_id IN NUMBER,
                               p_mo_req_number IN VARCHAR2) IS
  BEGIN
    OPEN x_pwmo_lov FOR
     SELECT   MAX(h.request_number)
             , MAX(h.description)
             , h.header_id
             , MAX(h.move_order_type)
             , DECODE(COUNT(l.line_number), 1, MAX(l.line_number), NULL)
             , DECODE(COUNT(l.line_id), 1, MAX(l.line_id), NULL)
          FROM ic_txn_request_headers h, ic_txn_request_lines l
         WHERE h.organization_id = p_organization_id
           AND h.request_number LIKE(p_mo_req_number)
           AND h.header_status IN(3, 7)
           AND l.organization_id = h.organization_id
           AND l.line_status IN(3, 7)
           AND l.header_id = h.header_id
         GROUP BY h.header_id;

  END Get_Move_Order_LoV;



  PROCEDURE Get_Delivery_LoV(x_delivery OUT NOCOPY t_genref,
                             p_organization_id IN NUMBER,
                             p_deliv_num IN VARCHAR2) IS
  BEGIN
    OPEN x_delivery FOR
      SELECT wnd.NAME, wnd.delivery_id
        FROM wsh_new_deliveries wnd, wsh_delivery_details wdd, wsh_delivery_assignments wda,
          ic_txn_request_lines ml

       WHERE wda.delivery_id = wnd.delivery_id
         AND wda.delivery_detail_id = wdd.delivery_detail_id
         AND wdd.move_order_line_id = ml.line_id
         AND wdd.organization_id = p_organization_id
         AND ml.quantity > NVL(ml.quantity_delivered, 0)
         AND wnd.NAME LIKE(p_deliv_num || '%');
  END;


  PROCEDURE Get_Pickslip_LoV(x_pickslip        OUT NOCOPY t_genref,
                             p_organization_id IN  NUMBER,
                             p_pickslip_num    IN  VARCHAR2) IS
  BEGIN

    OPEN x_pickslip FOR
      SELECT UNIQUE t.pick_slip_number
      FROM ic_tran_pnd t,
           ic_whse_mst i
     WHERE
      t.whse_code = i.whse_code AND
      i.mtl_organization_id = p_organization_id AND
      t.pick_slip_number LIKE(p_pickslip_num)
      AND t.delete_mark   = 0
      AND t.completed_ind = 0
      AND t.doc_type      = 'OMSO';


  END;


PROCEDURE Get_Reason_Code_Lov(x_reasonCodeLOV OUT NOCOPY t_genref,
                              p_reason_code   IN VARCHAR2) IS
BEGIN
   OPEN x_reasonCodeLOV for
     select
       reason_code,reason_desc1 from sy_reas_cds
     where
       reason_code like (p_reason_code) and
       delete_mark = 0
     order by 1;

END  Get_Reason_Code_Lov;

PROCEDURE get_stacked_messages(x_message OUT NOCOPY VARCHAR2)
  IS
     l_message VARCHAR2(2000);
     l_msg_count NUMBER;
BEGIN
   fnd_msg_pub.Count_And_Get
     (p_encoded => FND_API.g_false,
      p_count => l_msg_count,
      p_data => l_message
      );

   IF l_msg_count > 1 THEN
      FOR i IN 1..l_msg_count LOOP
         l_message := substr((l_message || '|' || FND_MSG_PUB.GET(p_msg_index => l_msg_count - i + 1,
                                                          p_encoded     => FND_API.g_false)),1,2000);
      END LOOP;
   END IF;

   fnd_msg_pub.delete_msg;

   x_message := l_message;

EXCEPTION
   WHEN OTHERS THEN
      NULL;

END get_stacked_messages;

END GML_MOBILE_MOVE_ORDER;

/
