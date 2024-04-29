--------------------------------------------------------
--  DDL for Package Body GML_MOBILE_RECEIPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_MOBILE_RECEIPT" AS
  /* $Header: GMLMRCVB.pls 120.0 2005/05/25 16:19:23 appldev noship $ */

g_pkg_name CONSTANT VARCHAR2(30) := 'GML_MOBILE_RECEIPT';

--yannamal 4189249 Added NOCOPY for x_return_status and x_error_msg
PROCEDURE Check_Lot_Status(p_lot_id        IN NUMBER,
                           p_lot_num       IN VARCHAR2,
                           p_sublot_num    IN VARCHAR2,
                           p_item_id       IN NUMBER,
                           p_org_id        IN NUMBER,
                           p_locator_id    IN NUMBER,
                           p_reason_code   IN VARCHAR2,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_error_msg     OUT NOCOPY VARCHAR2) IS

v_location              VARCHAR2(20);
v_opm_item_id           NUMBER;
v_inv_lot_status        VARCHAR2(5) := NULL;
v_item_rec              IC_ITEM_MST%ROWTYPE;
v_inv_loct_onhand       NUMBER := 0;

v_processing_mode       VARCHAR2(15);

---l_trans_rec             GMIGAPI.qty_rec_typ := GML_MLT_CNTR_RCPT.gmigapi_qty_format;


l_ic_jrnl_mst_row       ic_jrnl_mst%ROWTYPE;
l_ic_adjs_jnl_row1      ic_adjs_jnl%ROWTYPE;
l_ic_adjs_jnl_row2      ic_adjs_jnl%ROWTYPE;
l_status                VARCHAR2(1);
l_count                 NUMBER;
l_data                  VARCHAR2(2000);
l_count_msg             NUMBER;
l_dummy_cnt             NUMBER  :=0;
l_reason_code_security  VARCHAR2(10) := 'N';

RECV_DIFF_STATUS_ERROR  EXCEPTION;
ERRORS                  EXCEPTION;

l_message_data          VARCHAR2(2000);

l_move_diff_status INTEGER := FND_PROFILE.VALUE('IC$MOVEDIFFSTAT');


BEGIN
  x_return_status := 'S';
  v_opm_item_id := p_item_id;

  SELECT *
  INTO    v_item_rec
  FROM    ic_item_mst
  WHERE  item_id        = v_opm_item_id;

  IF p_locator_id > 0 THEN
    SELECT location
    INTO v_location
    FROM ic_loct_mst
    WHERE inventory_location_id = p_locator_id;
  ELSE
    v_location := FND_PROFILE.VALUE('IC$DEFAULT_LOCT');
  END IF;

  IF v_item_rec.status_ctl = 0 THEN
     RETURN;
  END IF;


  BEGIN
      SELECT    lot_status, loct_onhand
      INTO      v_inv_lot_status, v_inv_loct_onhand
      FROM      ic_loct_inv ilv, ic_whse_mst w
      WHERE     ilv.item_id     = v_opm_item_id
      AND       ilv.lot_id      = p_lot_id
      AND       w.mtl_organization_id = p_org_id
      AND       ilv.whse_code   = w.whse_code
      AND       ilv.location    = v_location;

      EXCEPTION
         WHEN OTHERS THEN
           v_inv_lot_status := NULL;
   END;


   IF l_move_diff_status = 0 THEN
      IF (v_inv_lot_status IS NOT NULL) AND (v_inv_lot_status <> v_item_rec.lot_status) THEN
         FND_MESSAGE.SET_NAME('GML', 'GML_CANT_RECV_DIFF_STATUS');
         RAISE RECV_DIFF_STATUS_ERROR;
      END IF;
   ELSIF l_move_diff_status = 2 THEN
      IF v_inv_lot_status IS NOT NULL
         AND v_inv_lot_status <> v_item_rec.lot_status
         AND v_inv_loct_onhand <> 0 THEN
            FND_MESSAGE.SET_NAME('GML', 'GML_CANT_RECV_DIFF_STATUS');
            RAISE RECV_DIFF_STATUS_ERROR;
      END IF;
   END IF;

   EXCEPTION
       WHEN RECV_DIFF_STATUS_ERROR THEN
        x_error_msg := FND_MESSAGE.GET;
        x_return_status := 'E';
       WHEN ERRORS THEN
        x_return_status := 'U';
       WHEN OTHERS THEN
        x_return_status := 'U';


END check_lot_status;


PROCEDURE GET_PO_LINE_ITEM_NUM_LOV(x_po_line_num_lov OUT NOCOPY t_genref,
			      p_organization_id IN NUMBER,
			      p_po_header_id IN NUMBER,
			      p_mobile_form IN VARCHAR2,
			      p_po_line_num IN VARCHAR2,
                              p_inventory_item_id IN VARCHAR2)
  IS
BEGIN
   IF p_mobile_form = 'RECEIPT' THEN
      OPEN x_po_line_num_lov FOR
	select distinct pl.line_num
             , pl.po_line_id
             , pl.item_description
             , pl.item_id
             , pl.item_revision
             , msi.concatenated_segments
             , msi.outside_operation_flag
             , mum.uom_code
          from po_lines_all pl
             , mtl_units_of_measure mum
             , mtl_system_items_kfv msi
         where pl.item_id = msi.inventory_item_id (+)
           and mum.UNIT_OF_MEASURE(+) = pl.UNIT_MEAS_LOOKUP_CODE
           and Nvl(msi.organization_id, p_organization_id) = p_organization_id
           and pl.po_header_id = p_po_header_id
 	   and exists (SELECT 'Valid PO Shipments'
                        FROM po_line_locations_all poll
                       WHERE poll.po_header_id = pl.po_header_id
			 AND poll.po_line_id = pl.po_line_id
                         AND Nvl(poll.approved_flag,'N') =  'Y'
                         AND Nvl(poll.cancel_flag,'N') = 'N'
                         AND receiving_routing_id = 3 --- Direct only supported by OPM
                         -- AND poll.closed_code = 'OPEN' -- Bug 2859355
		         AND Nvl(poll.closed_code,'OPEN') NOT IN ('CLOSED', 'FINALLY CLOSED','CLOSED FOR RECEIVING')
                         AND poll.shipment_type IN ('STANDARD','BLANKET','SCHEDULED')
                         AND poll.ship_to_organization_id = p_organization_id)
           AND pl.line_num LIKE (p_po_line_num)
           AND nvl(pl.item_id,-999) LIKE nvl(p_inventory_item_id,'%')
           UNION ALL
	   select distinct pl.line_num
             , pl.po_line_id
             , pl.item_description
             , pl.item_id
             , pl.item_revision
             , msi.concatenated_segments
             , msi.outside_operation_flag
             , mum.uom_code
          from po_lines_all pl
             , mtl_units_of_measure mum
             , mtl_system_items_kfv msi
             , mtl_related_items mri
         where Nvl(msi.organization_id, p_organization_id) = p_organization_id
           and mum.UNIT_OF_MEASURE(+) = pl.UNIT_MEAS_LOOKUP_CODE
           and pl.po_header_id = p_po_header_id
 	   and exists (SELECT 'Valid PO Shipments'
                        FROM po_line_locations_all poll
                       WHERE poll.po_header_id = pl.po_header_id
			 AND poll.po_line_id = pl.po_line_id
                         AND Nvl(poll.approved_flag,'N') =  'Y'
                         AND Nvl(poll.cancel_flag,'N') = 'N'
                         AND receiving_routing_id = 3 --- Direct only supported by OPM
                         -- AND poll.closed_code = 'OPEN' --Bug 2859355
		         AND Nvl(poll.closed_code,'OPEN') NOT IN ('CLOSED','FINALLY CLOSED','CLOSED FOR RECEIVING')
                         AND poll.shipment_type IN ('STANDARD','BLANKET','SCHEDULED')
                         AND poll.ship_to_organization_id = p_organization_id)
           AND pl.line_num LIKE (p_po_line_num)
           AND ( (mri.related_item_id = msi.inventory_item_id
                 and pl.item_id = mri.inventory_item_id
                 and msi.inventory_item_id like p_inventory_item_id )
                 or
                 (mri.inventory_item_id = msi.inventory_item_id
                 and pl.item_id = mri.related_item_id  and mri.reciprocal_flag = 'Y'
                 and msi.inventory_item_id like p_inventory_item_id )
               )
           order by 1;
    ELSE
      OPEN x_po_line_num_lov FOR
	select distinct pl.line_num
             , pl.po_line_id
             , pl.item_description
             , pl.item_id
             , pl.item_revision
             , msi.concatenated_segments
	     , msi.outside_operation_flag
             , mum.uom_code
	FROM rcv_supply rsup
             , mtl_units_of_measure mum
	     , po_lines_all pl
             , mtl_system_items_kfv msi
	 WHERE rsup.po_line_id = pl.po_line_id
           and mum.UNIT_OF_MEASURE(+) = pl.UNIT_MEAS_LOOKUP_CODE
	   AND pl.item_id = msi.inventory_item_id (+)
           and Nvl(msi.organization_id, p_organization_id) = p_organization_id
           and rsup.po_header_id = p_po_header_id
           AND pl.line_num LIKE (p_po_line_num)
         order by pl.line_num;
   END IF;
END GET_PO_LINE_ITEM_NUM_LOV;

PROCEDURE Get_UoM_LoV_RcV(x_uoms            OUT NOCOPY t_genref,
			  p_organization_id IN NUMBER,
			  p_item_id         IN NUMBER,
			  p_uom_type        IN NUMBER,
			  p_uom_code        IN VARCHAR2) IS

  BEGIN

    IF (p_item_id IS NOT NULL AND  p_item_id > 0) THEN
      OPEN x_uoms FOR
        SELECT
                 uom_code
               , unit_of_measure
               , description
               , uom_class
               , PO_GML_DB_COMMON.GET_OPM_UOM_CODE(uom_code)
            FROM mtl_item_uoms_view
           WHERE organization_id = p_organization_id
             AND inventory_item_id(+) = p_item_id
             AND NVL(uom_type, 3) = NVL(p_uom_type, 3)
             AND uom_code LIKE (p_uom_code)
	     ORDER BY Upper(uom_code);

    END IF;

  END get_uom_lov_rcv;

PROCEDURE Get_Lot_LoV( x_lot_lov OUT NOCOPY t_genref,
                       p_item_id IN NUMBER,
                       p_lot_no IN VARCHAR2) IS
BEGIN


  OPEN x_lot_lov FOR
  select a.lot_no,a.sublot_no,a.expire_date,a.lot_id
  from  ic_lots_mst a, ic_item_mst b
  where a.item_id= p_item_id
  and    a.lot_id <> 0
  and   a.lot_no like (p_lot_no)
  and   a.delete_mark=0
  and  b.item_id = a.item_id
  and b.delete_mark=0
  order by 1,2;

END Get_Lot_LoV;

PROCEDURE Get_SubLot_LoV( x_sublot_lov OUT NOCOPY t_genref,
                       p_item_id IN NUMBER,
                       p_lot_no IN VARCHAR2,
                       p_sublot_no IN VARCHAR2) IS
BEGIN

OPEN x_sublot_lov FOR
select sublot_no ,expire_date,lot_id
from ic_lots_mst
where item_id= p_item_id
and lot_no = p_lot_no
and sublot_no like (p_sublot_no)
and lot_id <>0
and delete_mark=0
order by sublot_no;

END  Get_SubLot_LoV;

PROCEDURE Get_Reason_Code_LoV( x_reason_code_lov OUT NOCOPY t_genref,
                               p_reason_code     IN VARCHAR2) IS
BEGIN

OPEN x_reason_code_lov FOR
select reason_code,reason_desc1
from sy_reas_cds
where reason_code like (p_reason_code) AND
delete_mark = 0
order by 1;

END Get_Reason_Code_LoV;

PROCEDURE Get_Location_Lov( x_location_lov OUT NOCOPY t_genref,
                            p_location IN VARCHAR2,
                            p_item_id IN NUMBER,
                            p_whse_code IN VARCHAR2,
                            p_lot_id IN NUMBER) IS

l_default_loc VARCHAR2(30) := FND_PROFILE.VALUE('IC$DEFAULT_LOCT');

BEGIN

    OPEN x_location_lov FOR
     select distinct location, NVL(loct_desc, location), INVENTORY_LOCATION_ID
     from ic_loct_mst
     where whse_code = p_whse_code and delete_mark = 0 and
           location like (p_location) and
           location <> l_default_loc;

END Get_Location_Lov;


  -- This api creates a record in the  MTL_TRANSACTION_LOTS_INTERFACE
  -- It checks if the p_transaction_temp_id is null, if it is, then it
  -- generates a new id and returns that.
  PROCEDURE insert_lot(
    p_transaction_interface_id   IN OUT NOCOPY NUMBER
  , p_product_transaction_id     IN OUT NOCOPY NUMBER
  , p_created_by                 IN            NUMBER
  , p_transaction_qty            IN            NUMBER
  , p_secondary_qty              IN            NUMBER
  , p_primary_qty                IN            NUMBER
  , p_lot_number                 IN            VARCHAR2
  , p_sublot_number              IN            VARCHAR2
  , p_expiration_date            IN            DATE
  , p_secondary_unit_of_measure  IN            VARCHAR2
  , p_reason_code                IN            VARCHAR2
  , x_return_status              OUT NOCOPY    VARCHAR2
  , x_msg_data                   OUT NOCOPY    VARCHAR2
  ) IS
    l_return   NUMBER;
    l_lot_count NUMBER       := 0;
    l_msg_count NUMBER;
  BEGIN

    x_return_status  := fnd_api.g_ret_sts_success;

    --If the lot number and transaction_interface_id combination already exists
    --then add the specified transaction_quantity and primary_quantity to the
    --current lot interface record.
    IF p_transaction_interface_id IS NOT NULL THEN
      BEGIN
        SELECT 1
          INTO l_lot_count
          FROM mtl_transaction_lots_interface
         WHERE transaction_interface_id = p_transaction_interface_id
           AND Ltrim(Rtrim(lot_number)) = Ltrim(Rtrim(p_lot_number))
           AND Ltrim(Rtrim(sublot_num)) = Ltrim(Rtrim(p_sublot_number))
           AND ROWNUM = 1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_lot_count  := 0;
        WHEN OTHERS THEN
          l_lot_count  := 0;
      END;


      IF l_lot_count = 1 THEN
        UPDATE  mtl_transaction_lots_interface
        SET     transaction_quantity = transaction_quantity + p_transaction_qty
              , primary_quantity = primary_quantity + p_primary_qty
              , reason_code = p_reason_code
        WHERE   transaction_interface_id = p_transaction_interface_id
        AND     Ltrim(Rtrim(lot_number)) = Ltrim(Rtrim(p_lot_number))
        AND     Ltrim(Rtrim(sublot_num)) = Ltrim(Rtrim(p_sublot_number));


        RETURN;
      END IF;
    END IF;


    --Generate transaction_interface_id if the parameter is NULL
    IF (p_transaction_interface_id IS NULL) THEN
      SELECT  mtl_material_transactions_s.NEXTVAL
      INTO    p_transaction_interface_id
      FROM    sys.dual;
    END IF;

    --Generate production_transaction_id if the parameter is NULL
    IF (p_product_transaction_id IS NULL) THEN
      SELECT  rcv_transactions_interface_s.NEXTVAL
      INTO    p_product_transaction_id
      FROM    sys.dual;
    END IF;

    INSERT INTO MTL_TRANSACTION_LOTS_INTERFACE (
             transaction_interface_id
           , last_update_date
           , last_updated_by
           , creation_date
           , created_by
           , last_update_login
           , lot_number
           , sublot_num
           , lot_expiration_date
           , transaction_quantity
           , primary_quantity
           , secondary_transaction_quantity
           , reason_code
           , product_transaction_id
           , product_code
            )
    VALUES (
             p_transaction_interface_id
           , SYSDATE
           , FND_GLOBAL.USER_ID
           , SYSDATE
           , FND_GLOBAL.USER_ID
           , FND_GLOBAL.LOGIN_ID
           , Ltrim(Rtrim(p_lot_number))
           , Ltrim(Rtrim(p_sublot_number))
           , p_expiration_date
           , p_transaction_qty
           , p_primary_qty
           , p_secondary_qty
           , p_reason_code
           , p_product_transaction_id
           , 'RCV'
     );


  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.count_and_get (
          p_encoded =>  FND_API.G_FALSE
        , p_count   =>  l_msg_count
        , p_data    =>  x_msg_data );
  END insert_lot;



  PROCEDURE rcv_clear_global IS
    l_return_status VARCHAR2(1)   := fnd_api.g_ret_sts_success;
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(400);
  BEGIN
    gml_rcv_std_rcpt_apis.g_shipment_header_id      := NULL;
    gml_rcv_std_rcpt_apis.g_rcpt_match_table_gross.DELETE;
    gml_rcv_std_rcpt_apis.g_receipt_detail_index    := 1;
    gml_rcv_std_rcpt_apis.g_dummy_lpn_id            := NULL;
    inv_rcv_common_apis.g_rcv_global_var             := NULL;

    clear_lot_rec;

  -- clear the message stack.
    fnd_msg_pub.delete_msg;

    COMMIT;
  END rcv_clear_global;

  PROCEDURE clear_lot_rec IS
  BEGIN
     gml_rcv_std_rcpt_apis.g_rcpt_lot_qty_rec_tb.DELETE;
  END clear_lot_rec;

  PROCEDURE get_uom_code(
			  x_return_status      OUT NOCOPY    VARCHAR2
			, x_uom_code           OUT NOCOPY    VARCHAR2
			, p_po_header_id       IN            NUMBER
                        , p_item_id            IN            NUMBER
                        , p_organization_id    IN            NUMBER
			) IS
       l_count      NUMBER;

  BEGIN
        x_return_status  := fnd_api.g_ret_sts_success;

        x_uom_code := '@@@';
	l_count    := 0;

          IF p_po_header_id IS NOT NULL AND p_item_id IS NOT NULL THEN

            BEGIN
            SELECT COUNT(DISTINCT pol.unit_meas_lookup_code)
             INTO l_count
             FROM po_lines pol
            WHERE pol.po_header_id = p_po_header_id
              AND pol.unit_meas_lookup_code IS NOT NULL
              AND pol.item_id = p_item_id
	      AND pol.po_line_id IN (SELECT poll.po_line_id
	                          FROM po_line_locations_all poll, po_lines_all po
                                  WHERE poll.po_header_id = po.po_header_id
                                  AND Nvl(poll.approved_flag,'N') =  'Y'
                                  AND Nvl(poll.cancel_flag,'N') = 'N'
                                  AND Nvl(poll.closed_code,'OPEN') NOT IN ('CLOSED','FINALLY CLOSED','CLOSED FOR RECEIVING')
                                  AND poll.shipment_type IN ('STANDARD','BLANKET','SCHEDULED')
                                  AND poll.ship_to_organization_id = p_organization_id
                                  AND poll.po_line_id = po.po_line_id
                                  AND po.item_id = p_item_id
                                  AND po.po_header_id = p_po_header_id);
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
              l_count  := 0;
            END;

          IF l_count = 1 THEN

            BEGIN
            SELECT mum.uom_code
             INTO x_uom_code
             FROM po_lines pol
                  , mtl_units_of_measure mum
            WHERE pol.po_header_id = p_po_header_id
              AND pol.unit_meas_lookup_code IS NOT NULL
              AND pol.item_id = p_item_id
              AND mum.UNIT_OF_MEASURE(+) = pol.UNIT_MEAS_LOOKUP_CODE
              AND pol.po_line_id IN (SELECT poll.po_line_id
                                  FROM po_line_locations_all poll, po_lines_all po
                                  WHERE poll.po_header_id = po.po_header_id
                                  AND Nvl(poll.approved_flag,'N') =  'Y'
                                  AND Nvl(poll.cancel_flag,'N') = 'N'
                                  AND Nvl(poll.closed_code,'OPEN') NOT IN ('CLOSED', 'FINALLY CLOSED','CLOSED FOR RECEIVING')
                                  AND poll.shipment_type IN ('STANDARD','BLANKET','SCHEDULED')
                                  AND poll.ship_to_organization_id = p_organization_id
                                  AND poll.po_line_id = po.po_line_id
                                  AND po.item_id = p_item_id
                                  AND po.po_header_id = p_po_header_id)
                                  AND ROWNUM < 2;
            EXCEPTION
              WHEN OTHERS THEN
                 x_uom_code := '@@@';
            END;

          END IF;
       END IF;
   EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'get_uom_code');
      END IF;

  END get_uom_code;

  PROCEDURE Create_Lot(p_item_id       IN NUMBER,
                       p_item_no       IN VARCHAR2,
                       p_lot_no        IN VARCHAR2,
                       p_sublot_no     IN VARCHAR2,
                       p_vendor_id     IN NUMBER,
                       x_lot_id        OUT NOCOPY NUMBER,
                       x_return_status OUT NOCOPY VARCHAR2,
                       x_error_msg     OUT NOCOPY VARCHAR2) IS


    l_lot_rec           GMIGAPI.lot_rec_typ;
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_ic_lots_mst_row   ic_lots_mst%ROWTYPE;
    l_ic_lots_cpg_row   ic_lots_cpg%ROWTYPE;

BEGIN

    x_return_status := 'S';
    x_error_msg := '';


    l_lot_rec.item_no          := p_item_no;
    l_lot_rec.lot_no           := p_lot_no;
    l_lot_rec.sublot_no        := p_sublot_no;
    l_lot_rec.lot_desc         := NULL;
    l_lot_rec.qc_grade         := NULL;
    l_lot_rec.lot_created      := SYSDATE;
    l_lot_rec.expire_date      := NULL;
    l_lot_rec.origination_type := 3;
    l_lot_rec.vendor_lot_no    := NULL;
    l_lot_rec.user_name        := FND_GLOBAL.user_name;

    IF (GMIGUTL.SETUP(l_lot_rec.user_name)) THEN
         GMIPAPI.create_lot(
		         p_api_version      => 3.0
		       , p_init_msg_list    => 'T'
		       , p_commit           => 'F'
		       , p_validation_level => 100
		       , p_lot_rec          => l_lot_rec
		       , x_ic_lots_mst_row  => l_ic_lots_mst_row
		       , x_ic_lots_cpg_row  => l_ic_lots_cpg_row
		       , x_return_status    => x_return_status
		       , x_msg_count        => l_msg_count
		       , x_msg_data         => l_msg_data
		       );

/*
dbms_output.put_line('error code in API = '||x_return_status);
dbms_output.put_line('error in API = '||l_msg_data);
dbms_output.put_line('error in API count= '||l_msg_count);
*/
        IF (x_return_status = 'S') THEN
          x_lot_id := l_ic_lots_mst_row.lot_id;
        ELSE
	 For I IN 1..l_msg_count LOOP
	   l_msg_data := fnd_msg_pub.get(I,'F');
--                FND_MESSAGE.SET_STRING (x_msg_data);

---dbms_output.put_line('error = '||l_msg_data);
	 END LOOP;
         x_error_msg := l_msg_data;
        END IF;
     ELSE
       FND_MESSAGE.SET_NAME('GMI','GMI_XML_CONFIRM_DESCRTN_LOT_F');
       x_error_msg := FND_MESSAGE.GET;
       x_return_status := 'E';
     END IF;

  END Create_Lot;

--yannamal 4189249 Added NOCOPY for x_message
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


PROCEDURE GET_DOC_LOV(x_doc_num_lov        OUT NOCOPY t_genref,
		      p_organization_id    IN  NUMBER,
		      p_doc_number         IN  VARCHAR2,
		      p_mobile_form        IN  VARCHAR2,
		      p_manual_po_num_type IN  VARCHAR2,
		      p_shipment_header_id IN  VARCHAR2,
		      p_inventory_item_id  IN  VARCHAR2,
		      p_item_description   IN  VARCHAR2,
		      p_doc_type           IN  VARCHAR2,
		      p_vendor_prod_num    IN  VARCHAR2)

   IS
BEGIN

    IF p_mobile_form = 'RECEIPT' THEN
      OPEN x_doc_num_lov FOR
        -- This select takes care of Vendor Item and any non-expense item
        -- and cross ref item case.
   	SELECT DISTINCT
        -- DOCTYPE PO
        meaning                    FIELD0
        , poh.segment1             FIELD1
	, to_char(poh.po_header_id)         FIELD2
	, poh.type_lookup_code     FIELD3
	, PO_VENDORS_SV2.GET_VENDOR_NAME_FUNC(POH.VENDOR_ID) FIELD4
	, to_char(poh.vendor_id)      FIELD5
	, to_char(poh.vendor_site_id) FIELD6
	, 'Vendor'                    FIELD7
	, poh.note_to_receiver        FIELD8
        , Decode(p_manual_po_num_type,'NUMERIC', null, poh.segment1 )           FIELD9
        , to_char(Decode(p_manual_po_num_type,'NUMERIC', to_number(poh.segment1),null))  FIELD10
        , null                        FIELD11
        , lookup_code                 FIELD12
	FROM po_headers poh,
             fnd_lookup_values_vl flv
	WHERE flv.lookup_code = 'PO'
          AND flv.lookup_type = 'DOC_TYPE'
          AND nvl(flv.start_date_active, sysdate)<=sysdate
          AND nvl(flv.end_date_active,sysdate)>=sysdate
          AND flv.enabled_flag = 'Y'
          AND exists (SELECT 'Valid PO Shipments'
		        FROM po_line_locations_all poll
		       WHERE poh.po_header_id = poll.po_header_id
		         AND Nvl(poll.approved_flag,'N') =  'Y'
		         AND Nvl(poll.cancel_flag,'N') = 'N'
		         -- AND poll.closed_code = 'OPEN' -- Bug 2859335
                         AND receiving_routing_id = 3 --- Direct only supported by OPM
		         AND Nvl(poll.closed_code,'OPEN') NOT IN ('CLOSED', 'FINALLY CLOSED','CLOSED FOR RECEIVING', 'CLOSED') -- 3687249
		         AND poll.shipment_type IN ('STANDARD','BLANKET','SCHEDULED')
     			 AND poll.ship_to_organization_id = p_organization_id)
        -- Bug 2859355 Added the Extra conditions for poh.
	AND POH.TYPE_LOOKUP_CODE IN ('STANDARD','PLANNED', 'BLANKET','CONTRACT')
	AND NVL(POH.CANCEL_FLAG, 'N') IN ('N', 'I')
	AND NVL(POH.CLOSED_CODE, 'OPEN') NOT IN ('CLOSED', 'FINALLY CLOSED','CLOSED FOR RECEIVING', 'CLOSED') -- 3152693
	AND poh.segment1 LIKE (p_doc_number)
        AND  exists ( select 'x'
                        from po_lines_all pl
                           , mtl_system_items_kfv msi
                       where pl.item_id = msi.inventory_item_id (+)
                         and Nvl(msi.organization_id, p_organization_id) = p_organization_id
                         and pl.po_header_id = poh.po_header_id
		      AND Nvl(pl.vendor_product_num,' ') =
		      Nvl(p_vendor_prod_num, Nvl(pl.vendor_product_num,' '))
                         and Nvl(pl.item_id,-999) like Nvl(p_inventory_item_id,'%')
                    )
        AND p_item_description is null
        UNION
        -- This Select Handles Substitute Items
   	SELECT DISTINCT
        -- DOCTYPE PO
        meaning                             FIELD0
        , poh.segment1                      FIELD1
	, to_char(poh.po_header_id)         FIELD2
	, poh.type_lookup_code              FIELD3
	, PO_VENDORS_SV2.GET_VENDOR_NAME_FUNC(POH.VENDOR_ID) FIELD4
	, to_char(poh.vendor_id)               FIELD5
	, to_char(poh.vendor_site_id)          FIELD6
	, 'Vendor'                             FIELD7
	, poh.note_to_receiver                 FIELD8
        , Decode(p_manual_po_num_type,'NUMERIC', null, poh.segment1 )           FIELD9
        , to_char(Decode(p_manual_po_num_type,'NUMERIC', to_number(poh.segment1),null))  FIELD10
        , null                                 FIELD11
        , lookup_code                          FIELD12
	FROM po_headers poh,
             fnd_lookup_values_vl flv
	WHERE flv.lookup_code = 'PO'
          AND flv.lookup_type = 'DOC_TYPE'
          AND nvl(flv.start_date_active, sysdate)<=sysdate
          AND nvl(flv.end_date_active,sysdate)>=sysdate
          AND flv.enabled_flag = 'Y'
          AND exists (SELECT 'Valid PO Shipments'
		        FROM po_line_locations_all poll
		       WHERE poh.po_header_id = poll.po_header_id
		         AND Nvl(poll.approved_flag,'N') =  'Y'
		         AND Nvl(poll.cancel_flag,'N') = 'N'
		         -- AND poll.closed_code = 'OPEN' -- Bug 2859355
                         AND receiving_routing_id = 3 --- Direct only supported by OPM
		         AND Nvl(poll.closed_code,'OPEN') NOT IN ('CLOSED', 'FINALLY CLOSED','CLOSED FOR RECEIVING', 'CLOSED') -- 3687249
		         AND poll.shipment_type IN ('STANDARD','BLANKET','SCHEDULED')
     			 AND poll.ship_to_organization_id = p_organization_id)
        -- Bug 2859355 Added the Extra conditions for poh.
	AND POH.TYPE_LOOKUP_CODE IN ('STANDARD','PLANNED', 'BLANKET','CONTRACT')
	AND NVL(POH.CANCEL_FLAG, 'N') IN ('N', 'I')
	AND NVL(POH.CLOSED_CODE, 'OPEN') NOT IN ('CLOSED', 'FINALLY CLOSED','CLOSED FOR RECEIVING', 'CLOSED')  -- 3152693
	AND poh.segment1 LIKE (p_doc_number)
        AND  exists ( select 'x'
                        from po_lines_all pl
                           , mtl_related_items mri
                           , mtl_system_items_kfv msi
                       Where msi.organization_id = p_organization_id
                         and (( mri.related_item_id = msi.inventory_item_id
                         and pl.item_id = mri.inventory_item_id
                         and msi.inventory_item_id like p_inventory_item_id ) or
                           ( mri.inventory_item_id = msi.inventory_item_id
                         and pl.item_id = mri.related_item_id  and mri.reciprocal_flag = 'Y'
                         and msi.inventory_item_id like p_inventory_item_id ))
                         and pl.po_header_id = poh.po_header_id
			  AND Nvl(pl.vendor_product_num,' ') =
			  Nvl(p_vendor_prod_num,Nvl(pl.vendor_product_num,' '))
                    )
        AND p_item_description is null
        UNION
        -- This Select Handles Expense Items
   	SELECT DISTINCT
        -- DOCTYPE PO
        meaning                             FIELD0
        , poh.segment1                      FIELD1
	, to_char(poh.po_header_id)         FIELD2
	, poh.type_lookup_code              FIELD3
	, PO_VENDORS_SV2.GET_VENDOR_NAME_FUNC(POH.VENDOR_ID) FIELD4
	, to_char(poh.vendor_id)               FIELD5
	, to_char(poh.vendor_site_id)          FIELD6
	, 'Vendor'                             FIELD7
	, poh.note_to_receiver                 FIELD8
        , Decode(p_manual_po_num_type,'NUMERIC', null, poh.segment1 )           FIELD9
        , to_char(Decode(p_manual_po_num_type,'NUMERIC', to_number(poh.segment1),null))  FIELD10
        , null                                 FIELD11
        , lookup_code                          FIELD12
	FROM po_headers poh,
             fnd_lookup_values_vl flv
	WHERE flv.lookup_code = 'PO'
          AND flv.lookup_type = 'DOC_TYPE'
          AND nvl(flv.start_date_active, sysdate)<=sysdate
          AND nvl(flv.end_date_active,sysdate)>=sysdate
          AND flv.enabled_flag = 'Y'
	  AND exists (SELECT 'Valid PO Shipments'
		        FROM po_line_locations_all poll
		       WHERE poh.po_header_id = poll.po_header_id
		         AND Nvl(poll.approved_flag,'N') =  'Y'
		         AND Nvl(poll.cancel_flag,'N') = 'N'
                         AND receiving_routing_id = 3 --- Direct only supported by OPM
		         -- AND poll.closed_code = 'OPEN' --Bug 2859355
		         AND Nvl(poll.closed_code,'OPEN') NOT IN ('CLOSED', 'FINALLY CLOSED','CLOSED FOR RECEIVING', 'CLOSED') -- 3687249
		         AND poll.shipment_type IN ('STANDARD','BLANKET','SCHEDULED')
     			 AND poll.ship_to_organization_id = p_organization_id)
        -- Bug 2859355 Added the Extra conditions for poh.
	AND POH.TYPE_LOOKUP_CODE IN ('STANDARD','PLANNED', 'BLANKET','CONTRACT')
	AND NVL(POH.CANCEL_FLAG, 'N') IN ('N', 'I')
	AND NVL(POH.CLOSED_CODE, 'OPEN') NOT IN ('CLOSED', 'FINALLY CLOSED','CLOSED FOR RECEIVING', 'CLOSED') -- 3152693
	AND poh.segment1 LIKE (p_doc_number)
        AND  exists ( select 'x'
                        from  po_lines_all pol
                             ,mtl_units_of_measure mum
                       where mum.UNIT_OF_MEASURE(+) = pol.UNIT_MEAS_LOOKUP_CODE
                         and mum.base_uom_flag(+) = 'Y'
                         and pol.ITEM_ID is null
                         and pol.item_description like p_item_description||'%'
                         AND pol.po_header_id = poh.po_header_id
			    AND Nvl(pol.vendor_product_num,' ') =
			    Nvl(p_vendor_prod_num,Nvl(pol.vendor_product_num,' '))
                    )
        AND p_item_description is not null
	ORDER BY 1,2
        ;
   END IF;

END get_doc_lov;



PROCEDURE GET_ITEM_LOV_RECEIVING (
x_Items                               OUT NOCOPY t_genref,
p_Organization_Id                     IN NUMBER,
p_Concatenated_Segments               IN VARCHAR2,
p_poHeaderID                          IN VARCHAR2,
p_poReleaseID                         IN VARCHAR2,
p_poLineID                            IN VARCHAR2,
p_shipmentHeaderID                    IN VARCHAR2,
p_oeOrderHeaderID                     IN VARCHAR2,
p_reqHeaderID                         IN VARCHAR2,
p_projectId                           IN VARCHAR2,
p_taskId                              IN VARCHAR2,
p_pjmorg                              IN VARCHAR2,
p_crossreftype                        IN VARCHAR2
)

IS
-- Changes for GTIN CrossRef Type
--
g_gtin_cross_ref_type VARCHAR2(25) := fnd_profile.value('INV:GTIN_CROSS_REFERENCE_TYPE');
g_gtin_code_length NUMBER := 14;
g_crossref         VARCHAR2(40) := lpad(Rtrim(p_concatenated_segments, '%'), g_gtin_code_length, '00000000000000');

BEGIN


-- if  ( ( p_doctype = 'PO') or  (p_doctype = 'RMA') or (p_doctype = 'REQ') or (p_doctype = 'SHIP') )
-- then

if  (p_poHeaderID is not null       or
     p_poReleaseID is not null      or
     p_oeOrderHeaderID is not null  or
     p_shipmentHeaderID is not null or
     p_reqHeaderID is not null      or
     p_projectId is not null        or
     p_taskId is not null )
then

-- *****************************
---- Case for Document Info already entered in the session , txn starts with document ID
-- *****************************

if (p_poHeaderID is not null ) then
-- *****************************
--- START  OF PO HEADER  ID SECTION
-- *****************************

  if  ( p_pjmorg = 1) then --and ( p_projectId is not null ) )  then

-- *****************************
---- Start of  PJM BASED Tran.
-- *****************************

      if (p_poReleaseID is not null) then
-- *****************************
--- releaseBased  PJM Transaction
-- *****************************
         open x_items for
         select concatenated_segments,
         inventory_item_id,
         description,
         Nvl(revision_qty_control_code,1),
         Nvl(lot_control_code, 1),
         Nvl(serial_number_control_code, 1),
         Nvl(restrict_subinventories_code, 2),
         Nvl(restrict_locators_code, 2),
         Nvl(location_control_code, 1),
         primary_uom_code,
         Nvl(inspection_required_flag, 'N'),
         Nvl(shelf_life_code, 1),
         Nvl(shelf_life_days,0),
         Nvl(allowed_units_lookup_code, 2),
         Nvl(effectivity_control,1),
         0,
         0,
         Nvl(default_serial_status_id,1),
         Nvl(serial_status_enabled,'N'),
         Nvl(default_lot_status_id,0),
         Nvl(lot_status_enabled,'N'),
         '',
         'N',
         inventory_item_flag,
         0,
         inventory_asset_flag,
         outside_operation_flag
         from mtl_system_items_kfv
         WHERE organization_id = p_Organization_Id
         and concatenated_segments like p_concatenated_segments
         and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
         and inventory_item_id IN (SELECT pol.item_id FROM po_lines_all pol
         where pol.po_header_id =   p_poHeaderID
         and exists (select 1 from po_line_locations_all pll WHERE NVL(pll.closed_code,'OPEN')
         not in ('CLOSED', 'FINALLY CLOSED', 'CLOSED FOR RECEIVING') and
         Nvl(pll.ship_to_organization_id, p_organization_id) = p_organization_id and
         pll.po_header_id = p_poHeaderID
         and pll.po_release_id = p_poReleaseID
         and pll.po_line_id = pol.po_line_id
         AND Nvl(pll.cancel_flag,'N') = 'N'
         and pll.receiving_routing_id = 3)
         and  exists (select 1 from po_distributions_all pd where pd.po_header_id =  p_poHeaderID
         and pd.po_line_id = pol.po_line_id
         and pd.po_release_id = p_poReleaseID
         and ((p_projectId is null or pd.project_id = p_projectId)
               and (p_taskId is null or pd.task_id = p_taskId)
             )
        )
        )
        UNION ALL
        -- Substitute Item SQL
        select distinct msi.concatenated_segments,
        msi.inventory_item_id,
        msi.description,
        Nvl(msi.revision_qty_control_code,1),
        Nvl(msi.lot_control_code, 1),
        Nvl(msi.serial_number_control_code, 1),
        Nvl(msi.restrict_subinventories_code, 2),
        Nvl(msi.restrict_locators_code,2),
        Nvl(msi.location_control_code,1),
        msi.primary_uom_code,
        Nvl(msi.inspection_required_flag,'N'),
        Nvl(msi.shelf_life_code, 1),
        Nvl(msi.shelf_life_days,0),
        Nvl(msi.allowed_units_lookup_code, 2),
        Nvl(msi.effectivity_control,1),
        0,
        0,
        Nvl(msi.default_serial_status_id,1),
        Nvl(msi.serial_status_enabled,'N'),
        Nvl(msi.default_lot_status_id,0),
        Nvl(msi.lot_status_enabled,'N'),
        msia.concatenated_segments,
        'S',
        msi.inventory_item_flag,
        0,
        msi.inventory_asset_flag,
        msi.outside_operation_flag
        from po_lines_all pol
        ,mtl_related_items mri
        ,mtl_system_items_kfv msi
        ,mtl_system_items_kfv msia
        where msi.organization_id =  p_organization_id
        and msi.concatenated_segments like  p_concatenated_segments
        and pol.po_header_id = p_poHeaderID
        and pol.item_id = msia.inventory_item_id
        and msia.organization_id = p_organization_id
        and ((    mri.related_item_id = msi.inventory_item_id
        and pol.item_id = mri.inventory_item_id) or
         (    mri.inventory_item_id = msi.inventory_item_id
         and pol.item_id = mri.related_item_id
         and mri.reciprocal_flag = 'Y'))
         and exists (select 1 from  po_line_locations_all pll
                           where NVL(pll.closed_code,'OPEN')
                           not in ('CLOSED', 'FINALLY CLOSED', 'CLOSED FOR RECEIVING')
        and Nvl(pll.ship_to_organization_id, p_organization_id) = p_organization_id
        and   Nvl(pll.allow_substitute_receipts_flag, 'N') = 'Y'
        and   pll.po_header_id = pol.po_header_id
        and   pll.po_line_id = pol.po_line_id
        and   pll.po_release_id = p_poReleaseID
         AND Nvl(pll.cancel_flag,'N') = 'N'
        and   pll.receiving_routing_id = 3)
        and  exists (select 1 from po_distributions_all pd where pd.po_header_id =  p_poHeaderID
        and pd.po_line_id = pol.po_line_id
        and pd.po_release_id = p_poReleaseID
        and ((p_projectId is null or pd.project_id = p_projectId)
               and (p_taskId is null or pd.task_id = p_taskId)
             )
        )
        UNION ALL
        -- Vendor Item SQL
        select distinct pol.vendor_product_num,
        msi.inventory_item_id,
        msi.description,
        Nvl(msi.revision_qty_control_code,1),
        Nvl(msi.lot_control_code, 1),
        Nvl(msi.serial_number_control_code, 1),
        Nvl(msi.restrict_subinventories_code, 2),
        Nvl(msi.restrict_locators_code,2),
        Nvl(msi.location_control_code,1),
        msi.primary_uom_code,
        Nvl(msi.inspection_required_flag,'N'),
        Nvl(msi.shelf_life_code, 1),
        Nvl(msi.shelf_life_days,0),
        Nvl(msi.allowed_units_lookup_code, 2),
        Nvl(msi.effectivity_control,1),
        0,
        0,
        Nvl(msi.default_serial_status_id,1),
        Nvl(msi.serial_status_enabled,'N'),
        Nvl(msi.default_lot_status_id,0),
        Nvl(msi.lot_status_enabled,'N'),
        msi.concatenated_segments,
        'Y',
        msi.inventory_item_flag,
        0,
        msi.inventory_asset_flag,
        msi.outside_operation_flag
        from po_lines_all pol
        , mtl_system_items_kfv msi
        where organization_id =  p_organization_id
        and pol.vendor_product_num like  p_concatenated_segments
        and pol.item_id = msi.inventory_item_id
        and  pol.vendor_product_num IS NOT NULL
        and pol.po_header_id =  p_poHeaderID
        and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
        and inventory_item_id IN (SELECT pol.item_id FROM po_lines_all pol
        where pol.po_header_id =   p_poHeaderID
        and exists (select 1 from po_line_locations_all pll WHERE NVL(pll.closed_code,'OPEN')
        not in ('CLOSED', 'FINALLY CLOSED', 'CLOSED FOR RECEIVING') and
        Nvl(pll.ship_to_organization_id, p_organization_id) = p_organization_id and
        pll.po_header_id = p_poHeaderID
        and pll.po_release_id = p_poReleaseID
        and pll.po_line_id = pol.po_line_id
         AND Nvl(pll.cancel_flag,'N') = 'N'
        and   pll.receiving_routing_id = 3)
        and  exists (select 1 from po_distributions_all pd where pd.po_header_id =  p_poHeaderID
        and pd.po_line_id = pol.po_line_id
        and pd.po_release_id = p_poReleaseID
        and ((p_projectId is null or pd.project_id = p_projectId)
               and (p_taskId is null or pd.task_id = p_taskId)
             )
        )
        )
        UNION ALL
        -- non item Master
        select distinct pol.item_description,
        to_number(''),
        pol.item_description,
        1,
        1,
        1,
        2,
        2,
        1,
        mum.uom_code,
        'N',
        1,
        0,
        2,
        1,
        0,
        0,
        1,
        'N',
        0,
        'N',
        '',
        'N',
        'N',
        0,
        to_char(NULL),
        'N'
        from po_lines_all pol
        , mtl_units_of_measure mum
        -- Bug 2619063, 2614016
        -- Modified to select the base uom for the uom class defined on po.
        where mum.uom_class = (SELECT mum2.uom_class
                                 FROM mtl_units_of_measure mum2
                                WHERE mum2.unit_of_measure(+) = pol.unit_meas_lookup_code)
        and mum.base_uom_flag = 'Y'
        and pol.ITEM_ID is null
        and pol.item_description is not null
        and pol.po_header_id = p_poHeaderID
        and pol.item_description like  p_concatenated_segments
        and  exists (select 1 from po_distributions_all pd where pd.po_header_id =  p_poHeaderID
        and pd.po_line_id = pol.po_line_id
        and pd.po_release_id = p_poReleaseID
        and ((p_projectId is null or pd.project_id = p_projectId)
               and (p_taskId is null or pd.task_id = p_taskId)
             )
        )
        UNION ALL
        -- Cross Ref  SQL
        select distinct msi.concatenated_segments,
        ---select distinct mcr.cross_reference,
        msi.inventory_item_id,
        msi.description,
        Nvl(msi.revision_qty_control_code,1),
        Nvl(msi.lot_control_code, 1),
        Nvl(msi.serial_number_control_code, 1),
        Nvl(msi.restrict_subinventories_code, 2),
        Nvl(msi.restrict_locators_code,2),
        Nvl(msi.location_control_code,1),
        msi.primary_uom_code,
        Nvl(msi.inspection_required_flag,'N'),
        Nvl(msi.shelf_life_code, 1),
        Nvl(msi.shelf_life_days,0),
        Nvl(msi.allowed_units_lookup_code, 2),
        Nvl(msi.effectivity_control,1),
        0,
        0,
        Nvl(msi.default_serial_status_id,1),
        Nvl(msi.serial_status_enabled,'N'),
        Nvl(msi.default_lot_status_id,0),
        Nvl(msi.lot_status_enabled,'N'),
        ---msi.concatenated_segments,
        mcr.cross_reference,
        'C',
        msi.inventory_item_flag,
        0,
        msi.inventory_asset_flag,
        msi.outside_operation_flag
        from po_lines_all pol
        ,mtl_system_items_kfv msi
        ,mtl_cross_references mcr
        where msi.organization_id = p_organization_id
        and ( (mcr.cross_reference_type = p_crossreftype
               and mcr.cross_reference like  p_concatenated_segments
              ) or
              ( mcr.cross_reference_type = g_gtin_cross_ref_type
               AND mcr.cross_reference      LIKE g_crossref )
            )
        and ( (mcr.org_independent_flag = 'Y') or (mcr.org_independent_flag = 'N'
        and mcr.organization_id = p_organization_id
               ) )
        and mcr.inventory_item_id = msi.inventory_item_id
        and pol.item_id = msi.inventory_item_id
        and pol.po_header_id = p_poHeaderID
        and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
        and msi.inventory_item_id IN (SELECT pol.item_id FROM po_lines_all pol
        where pol.po_header_id =   p_poHeaderID
        and exists (select 1 from po_line_locations_all pll WHERE NVL(pll.closed_code,'OPEN')
        not in ('CLOSED', 'FINALLY CLOSED', 'CLOSED FOR RECEIVING') and
        Nvl(pll.ship_to_organization_id, p_organization_id) = p_organization_id and
        pll.po_header_id = p_poHeaderID
        and pll.po_release_id = p_poReleaseID
        and pll.po_line_id = pol.po_line_id
         AND Nvl(pll.cancel_flag,'N') = 'N'
        and   pll.receiving_routing_id = 3)
        and  exists (select 1 from po_distributions_all pd where pd.po_header_id =
        p_poHeaderID
        and pd.po_line_id = pol.po_line_id
        and pd.po_release_id = p_poReleaseID
        and ((p_projectId is null or pd.project_id = p_projectId)
               and (p_taskId is null or pd.task_id = p_taskId)
             )
        )
        )
        ;
      elsif  (p_poLineID IS NOT NULL) then
-- *****************************
----- lineBased PJM Transaction
-- *****************************
        open x_items for
        select concatenated_segments,
        inventory_item_id,
        description,
        Nvl(revision_qty_control_code,1),
        Nvl(lot_control_code, 1),
        Nvl(serial_number_control_code, 1),
        Nvl(restrict_subinventories_code, 2),
        Nvl(restrict_locators_code, 2),
        Nvl(location_control_code, 1),
        primary_uom_code,
        Nvl(inspection_required_flag, 'N'),
        Nvl(shelf_life_code, 1),
        Nvl(shelf_life_days,0),
        Nvl(allowed_units_lookup_code, 2),
        Nvl(effectivity_control,1),
        0,
        0,
        Nvl(default_serial_status_id,1),
        Nvl(serial_status_enabled,'N'),
        Nvl(default_lot_status_id,0),
        Nvl(lot_status_enabled,'N'),
        '',
        'N',
        inventory_item_flag,
        0,
        inventory_asset_flag,
        outside_operation_flag
        from mtl_system_items_kfv
        WHERE organization_id = p_Organization_Id
        and concatenated_segments like p_concatenated_segments
        and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
        and inventory_item_id IN (SELECT pol.item_id FROM po_lines_all pol WHERE
        pol.po_header_id = p_poHeaderID
        and pol.po_line_id = p_poLineID
        and exists (select 1 from po_line_locations_all pll where NVL(pll.closed_code, 'OPEN')
        not in ('CLOSED', 'FINALLY CLOSED' , 'CLOSED FOR RECEIVING' )
        and Nvl(pll.ship_to_organization_id, p_organization_id) = p_organization_id
        and  pll.po_header_id = p_poHeaderID
        and pll.po_line_id = p_poLineID
         AND Nvl(pll.cancel_flag,'N') = 'N'
        and pll.receiving_routing_id = 3
        )  and  exists (select 1 from po_distributions_all pd
        where pd.po_header_id =  p_poHeaderID
        and pd.po_line_id = p_poLineID
        and pd.po_line_id = pol.po_line_id
        and ((p_projectId is null or pd.project_id = p_projectId)
               and (p_taskId is null or pd.task_id = p_taskId)
             )
        )
        )
        UNION ALL
        -- Substitute Item SQL
        select distinct msi.concatenated_segments,
        msi.inventory_item_id,
        msi.description,
        Nvl(msi.revision_qty_control_code,1),
        Nvl(msi.lot_control_code, 1),
        Nvl(msi.serial_number_control_code, 1),
        Nvl(msi.restrict_subinventories_code, 2),
        Nvl(msi.restrict_locators_code,2),
        Nvl(msi.location_control_code,1),
        msi.primary_uom_code,
        Nvl(msi.inspection_required_flag,'N'),
        Nvl(msi.shelf_life_code, 1),
        Nvl(msi.shelf_life_days,0),
        Nvl(msi.allowed_units_lookup_code, 2),
        Nvl(msi.effectivity_control,1),
        0,
        0,
        Nvl(msi.default_serial_status_id,1),
        Nvl(msi.serial_status_enabled,'N'),
        Nvl(msi.default_lot_status_id,0),
        Nvl(msi.lot_status_enabled,'N'),
        msia.concatenated_segments,
        'S',
        msi.inventory_item_flag,
        0,
        msi.inventory_asset_flag,
        msi.outside_operation_flag
        from po_lines_all pol
        ,mtl_related_items mri
       ,mtl_system_items_kfv msi
       ,mtl_system_items_kfv msia
        where msi.organization_id =  p_organization_id
        and msi.concatenated_segments like  p_concatenated_segments
        and pol.po_header_id = p_poHeaderID
        and pol.item_id = msia.inventory_item_id
        and msia.organization_id = p_organization_id
        and ((    mri.related_item_id = msi.inventory_item_id
        and pol.item_id = mri.inventory_item_id) or
         (    mri.inventory_item_id = msi.inventory_item_id
         and pol.item_id = mri.related_item_id
         and mri.reciprocal_flag = 'Y'))
         and pol.po_line_id = p_poLineID
         and exists (select 1 from  po_line_locations_all pll
                  where NVL(pll.closed_code,'OPEN') not in
        ('CLOSED', 'FINALLY CLOSED', 'CLOSED FOR RECEIVING')
        and Nvl(pll.ship_to_organization_id, p_organization_id) = p_organization_id
                and   Nvl(pll.allow_substitute_receipts_flag, 'N') = 'Y'
                 and   pll.po_header_id = pol.po_header_id
                 and   pll.po_line_id = pol.po_line_id
         AND Nvl(pll.cancel_flag,'N') = 'N'
                 and pll.receiving_routing_id = 3)
        and  exists ( select 1 from po_distributions_all pd
        where pd.po_header_id =  p_poHeaderID
        and pd.po_line_id = p_poLineID
        and pd.po_line_id = pol.po_line_id
        and ((p_projectId is null or pd.project_id = p_projectId)
               and (p_taskId is null or pd.task_id = p_taskId)
             )
        )
        UNION ALL
        -- Vendor Item SQL
        select distinct pol.vendor_product_num,
        msi.inventory_item_id,
        msi.description,
        Nvl(msi.revision_qty_control_code,1),
        Nvl(msi.lot_control_code, 1),
        Nvl(msi.serial_number_control_code, 1),
        Nvl(msi.restrict_subinventories_code, 2),
        Nvl(msi.restrict_locators_code,2),
        Nvl(msi.location_control_code,1),
        msi.primary_uom_code,
        Nvl(msi.inspection_required_flag,'N'),
        Nvl(msi.shelf_life_code, 1),
        Nvl(msi.shelf_life_days,0),
        Nvl(msi.allowed_units_lookup_code, 2),
        Nvl(msi.effectivity_control,1),
        0,
        0,
        Nvl(msi.default_serial_status_id,1),
        Nvl(msi.serial_status_enabled,'N'),
        Nvl(msi.default_lot_status_id,0),
        Nvl(msi.lot_status_enabled,'N'),
        msi.concatenated_segments,
        'Y',
        msi.inventory_item_flag,
        0,
        msi.inventory_asset_flag,
        msi.outside_operation_flag
        from po_lines_all pol
        , mtl_system_items_kfv msi
        where organization_id =  p_organization_id
        and pol.vendor_product_num like  p_concatenated_segments
        and pol.item_id = msi.inventory_item_id
        and  pol.vendor_product_num IS NOT NULL
        and pol.po_header_id =  p_poHeaderID
        and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
        and inventory_item_id IN (SELECT pl.item_id FROM po_lines_all pl WHERE
        pl.po_header_id = p_poHeaderID
        and pl.po_line_id = p_poLineID
        and exists (select 1 from po_line_locations_all pll where NVL(pll.closed_code, 'OPEN')
        not in ('CLOSED', 'FINALLY CLOSED' , 'CLOSED FOR RECEIVING' )
        and Nvl(pll.ship_to_organization_id, p_organization_id) = p_organization_id
        and  pll.po_header_id = p_poHeaderID
        and pll.po_line_id = p_poLineID
         AND Nvl(pll.cancel_flag,'N') = 'N'
        and pll.receiving_routing_id = 3)
        and  exists (select 1 from po_distributions_all pd
        where pd.po_header_id =  p_poHeaderID
        and pd.po_line_id = pol.po_line_id
        and pd.po_line_id = p_poLineID
        and ((p_projectId is null or pd.project_id = p_projectId)
               and (p_taskId is null or pd.task_id = p_taskId)
             )
        )
        )
        UNION ALL
        -- non item Master
        select distinct pol.item_description,
        to_number(''),
        pol.item_description,
        1,
        1,
        1,
        2,
        2,
        1,
        mum.uom_code,
        'N',
        1,
        0,
        2,
        1,
        0,
        0,
        1,
        'N',
        0,
        'N',
        '',
        'N',
        'N',
        0,
        to_char(NULL),
        'N'
        from po_lines_all pol
        , mtl_units_of_measure mum
        -- Bug 2619063, 2614016
        -- Modified to select the base uom for the uom class defined on po.
        where mum.uom_class = (SELECT mum2.uom_class
                                 FROM mtl_units_of_measure mum2
                                WHERE mum2.unit_of_measure(+) = pol.unit_meas_lookup_code)
        and mum.base_uom_flag = 'Y'
        and pol.ITEM_ID is null
        and pol.item_description is not null
        and pol.po_header_id = p_poHeaderID
        and pol.item_description like  p_concatenated_segments
        and  exists ( select 1 from po_distributions_all pd
        where pd.po_header_id =  p_poHeaderID
        and pd.po_line_id = p_poLineID
        and pd.po_line_id = pol.po_line_id
        and ((p_projectId is null or pd.project_id = p_projectId)
               and (p_taskId is null or pd.task_id = p_taskId)
             )
        )
        UNION ALL
        -- Cross Ref  SQL
        ---select distinct mcr.cross_reference,
        select distinct msi.concatenated_segments,
        msi.inventory_item_id,
        msi.description,
        Nvl(msi.revision_qty_control_code,1),
        Nvl(msi.lot_control_code, 1),
        Nvl(msi.serial_number_control_code, 1),
        Nvl(msi.restrict_subinventories_code, 2),
        Nvl(msi.restrict_locators_code,2),
        Nvl(msi.location_control_code,1),
        msi.primary_uom_code,
        Nvl(msi.inspection_required_flag,'N'),
        Nvl(msi.shelf_life_code, 1),
        Nvl(msi.shelf_life_days,0),
        Nvl(msi.allowed_units_lookup_code, 2),
        Nvl(msi.effectivity_control,1),
        0,
        0,
        Nvl(msi.default_serial_status_id,1),
        Nvl(msi.serial_status_enabled,'N'),
        Nvl(msi.default_lot_status_id,0),
        Nvl(msi.lot_status_enabled,'N'),
        ---msi.concatenated_segments,
        mcr.cross_reference,
        'C',
        msi.inventory_item_flag,
        0,
        msi.inventory_asset_flag,
        msi.outside_operation_flag
        from po_lines_all pol
        ,mtl_system_items_kfv msi
        ,mtl_cross_references mcr
        where msi.organization_id = p_organization_id
        and ( (mcr.cross_reference_type = p_crossreftype
               and mcr.cross_reference like  p_concatenated_segments
              ) or
              ( mcr.cross_reference_type = g_gtin_cross_ref_type
               AND mcr.cross_reference      LIKE g_crossref )
            )
        and ( (mcr.org_independent_flag = 'Y') or (mcr.org_independent_flag = 'N'
        and mcr.organization_id = p_organization_id
               ) )
        and mcr.inventory_item_id = msi.inventory_item_id
        and pol.item_id = msi.inventory_item_id
        and pol.po_header_id = p_poHeaderID
        and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
        and msi.inventory_item_id IN (SELECT pl.item_id FROM po_lines_all pl WHERE
        pl.po_header_id = p_poHeaderID
        and pl.po_line_id = p_poLineID
        and exists (select 1 from po_line_locations_all pll where NVL(pll.closed_code, 'OPEN')
        not in ('CLOSED', 'FINALLY CLOSED' , 'CLOSED FOR RECEIVING' )
        and Nvl(pll.ship_to_organization_id,p_organization_id) = p_organization_id
        and  pll.po_header_id = p_poHeaderID
        and pll.po_line_id = p_poLineID
         AND Nvl(pll.cancel_flag,'N') = 'N'
        and pll.receiving_routing_id = 3
        )  and  exists (select 1 from po_distributions_all pd
        where pd.po_header_id =  p_poHeaderID
        and pd.po_line_id = pol.po_line_id
        and pd.po_line_id = p_poLineID
        and ((p_projectId is null or pd.project_id = p_projectId)
               and (p_taskId is null or pd.task_id = p_taskId)
             )
        )
        )
        ;
      else
-- *****************************
--- headerBased PJM Transaction
-- *****************************
        open x_items for
        select concatenated_segments,
        inventory_item_id,
        description,
        Nvl(revision_qty_control_code,1),
        Nvl(lot_control_code, 1),
        Nvl(serial_number_control_code, 1),
        Nvl(restrict_subinventories_code, 2),
        Nvl(restrict_locators_code, 2),
        Nvl(location_control_code, 1),
        primary_uom_code,
        Nvl(inspection_required_flag, 'N'),
        Nvl(shelf_life_code, 1),
        Nvl(shelf_life_days,0),
        Nvl(allowed_units_lookup_code, 2),
        Nvl(effectivity_control,1),
        0,
        0,
        Nvl(default_serial_status_id,1),
        Nvl(serial_status_enabled,'N'),
        Nvl(default_lot_status_id,0),
        Nvl(lot_status_enabled,'N'),
        '',
        'N',
        inventory_item_flag,
        0,
        inventory_asset_flag,
        outside_operation_flag
        from mtl_system_items_kfv
        WHERE organization_id = p_Organization_Id
        and concatenated_segments like p_concatenated_segments
        and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
        and inventory_item_id IN
        ( SELECT pol.item_id FROM po_lines_all pol WHERE pol.po_header_id =
        p_poHeaderID
        and exists (select 1 from po_line_locations_all pll where NVL(pll.closed_code,'OPEN')
        not in ('CLOSED', 'FINALLY CLOSED', 'CLOSED FOR RECEIVING')  and  pll.po_header_id =
        p_poHeaderID and pll.po_line_id = pol.po_line_id
        and Nvl(pll.ship_to_organization_id, p_organization_id) = p_organization_id
         AND Nvl(pll.cancel_flag,'N') = 'N'
        and pll.receiving_routing_id = 3)
        and  exists
        (select 1 from po_distributions_all pd
        where pd.po_header_id =  p_poHeaderID
        and pd.po_line_id = pol.po_line_id
        and ((p_projectId is null or pd.project_id = p_projectId)
               and (p_taskId is null or pd.task_id = p_taskId)
             )
        )
        )
        UNION ALL
        -- Substitute Item SQL
        select distinct msi.concatenated_segments,
        msi.inventory_item_id,
        msi.description,
        Nvl(msi.revision_qty_control_code,1),
        Nvl(msi.lot_control_code, 1),
        Nvl(msi.serial_number_control_code, 1),
        Nvl(msi.restrict_subinventories_code, 2),
        Nvl(msi.restrict_locators_code,2),
        Nvl(msi.location_control_code,1),
        msi.primary_uom_code,
        Nvl(msi.inspection_required_flag,'N'),
        Nvl(msi.shelf_life_code, 1),
        Nvl(msi.shelf_life_days,0),
        Nvl(msi.allowed_units_lookup_code, 2),
        Nvl(msi.effectivity_control,1),
        0,
        0,
        Nvl(msi.default_serial_status_id,1),
        Nvl(msi.serial_status_enabled,'N'),
        Nvl(msi.default_lot_status_id,0),
        Nvl(msi.lot_status_enabled,'N'),
        msia.concatenated_segments,
        'S',
        msi.inventory_item_flag,
        0,
        msi.inventory_asset_flag,
        msi.outside_operation_flag
        from po_lines_all pol
        ,mtl_related_items mri
       ,mtl_system_items_kfv msi
       ,mtl_system_items_kfv msia
        where msi.organization_id =  p_organization_id
        and msi.concatenated_segments like  p_concatenated_segments
        and pol.po_header_id = p_poHeaderID
        and pol.item_id = msia.inventory_item_id
        and msia.organization_id = p_organization_id
        and ((    mri.related_item_id = msi.inventory_item_id
        and pol.item_id = mri.inventory_item_id) or
         (    mri.inventory_item_id = msi.inventory_item_id
         and pol.item_id = mri.related_item_id
         and mri.reciprocal_flag = 'Y'))
         and exists (select 1 from  po_line_locations_all pll
                   where NVL(pll.closed_code,'OPEN') not in ('CLOSED', 'FINALLY CLOSED',
        'CLOSED FOR RECEIVING')
        and Nvl(pll.ship_to_organization_id, p_organization_id) = p_organization_id
                               and   Nvl(pll.allow_substitute_receipts_flag, 'N') = 'Y'
                               and   pll.po_header_id = pol.po_header_id
                               and   pll.po_line_id = pol.po_line_id
         AND Nvl(pll.cancel_flag,'N') = 'N'
        and pll.receiving_routing_id = 3)
        and  exists
        (select 1 from po_distributions_all pd
        where pd.po_header_id =  p_poHeaderID
        and pd.po_line_id = pol.po_line_id
        and ((p_projectId is null or pd.project_id = p_projectId)
               and (p_taskId is null or pd.task_id = p_taskId)
             )
        )
        UNION ALL
        -- Vendor Item SQL
        select distinct pol.vendor_product_num,
        msi.inventory_item_id,
        msi.description,
        Nvl(msi.revision_qty_control_code,1),
        Nvl(msi.lot_control_code, 1),
        Nvl(msi.serial_number_control_code, 1),
        Nvl(msi.restrict_subinventories_code, 2),
        Nvl(msi.restrict_locators_code,2),
        Nvl(msi.location_control_code,1),
        msi.primary_uom_code,
        Nvl(msi.inspection_required_flag,'N'),
        Nvl(msi.shelf_life_code, 1),
        Nvl(msi.shelf_life_days,0),
        Nvl(msi.allowed_units_lookup_code, 2),
        Nvl(msi.effectivity_control,1),
        0,
        0,
        Nvl(msi.default_serial_status_id,1),
        Nvl(msi.serial_status_enabled,'N'),
        Nvl(msi.default_lot_status_id,0),
        Nvl(msi.lot_status_enabled,'N'),
        msi.concatenated_segments,
        'Y',
        msi.inventory_item_flag,
        0,
        msi.inventory_asset_flag,
        msi.outside_operation_flag
        from po_lines_all pol
        , mtl_system_items_kfv msi
        where organization_id =  p_organization_id
        and pol.vendor_product_num like  p_concatenated_segments
        and pol.item_id = msi.inventory_item_id
        and  pol.vendor_product_num IS NOT NULL
        and pol.po_header_id =  p_poHeaderID
        and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
        and inventory_item_id IN
        ( SELECT pl.item_id FROM po_lines_all pl WHERE pl.po_header_id =
        p_poHeaderID
        and exists (select 1 from po_line_locations_all pll where NVL(pll.closed_code,'OPEN')
        not in ('CLOSED', 'FINALLY CLOSED', 'CLOSED FOR RECEIVING')  and  pll.po_header_id =
        p_poHeaderID and pll.po_line_id = pl.po_line_id
        and Nvl(pll.ship_to_organization_id, p_organization_id) = p_organization_id
         AND Nvl(pll.cancel_flag,'N') = 'N'
        and pll.receiving_routing_id = 3)
               and  exists
        (select 1 from po_distributions_all pd
        where pd.po_header_id =  p_poHeaderID
        and pd.po_line_id = pol.po_line_id
        and ((p_projectId is null or pd.project_id = p_projectId)
               and (p_taskId is null or pd.task_id = p_taskId)
             )
        )
        )
        UNION ALL
        -- non item Master
        select distinct pol.item_description,
        to_number(''),
        pol.item_description,
        1,
        1,
        1,
        2,
        2,
        1,
        mum.uom_code,
        'N',
        1,
        0,
        2,
        1,
        0,
        0,
        1,
        'N',
        0,
        'N',
        '',
        'N',
        'N',
        0,
        to_char(NULL),
        'N'
        from po_lines_all pol
        , mtl_units_of_measure mum
        -- Bug 2619063, 2614016
        -- Modified to select the base uom for the uom class defined on po.
        where mum.uom_class = (SELECT mum2.uom_class
                                 FROM mtl_units_of_measure mum2
                                WHERE mum2.unit_of_measure(+) = pol.unit_meas_lookup_code)
        and mum.base_uom_flag = 'Y'
        and pol.ITEM_ID is null
        and pol.item_description is not null
        and pol.po_header_id = p_poHeaderID
        and pol.item_description like  p_concatenated_segments
        and  exists
        (select 1 from po_distributions_all pd
        where pd.po_header_id =  p_poHeaderID
        and pd.po_line_id = pol.po_line_id
        and ((p_projectId is null or pd.project_id = p_projectId)
               and (p_taskId is null or pd.task_id = p_taskId)
             )
        )
        UNION ALL
        -- Cross Ref  SQL
        ---select distinct mcr.cross_reference,
        select distinct msi.concatenated_segments,
        msi.inventory_item_id,
        msi.description,
        Nvl(msi.revision_qty_control_code,1),
        Nvl(msi.lot_control_code, 1),
        Nvl(msi.serial_number_control_code, 1),
        Nvl(msi.restrict_subinventories_code, 2),
        Nvl(msi.restrict_locators_code,2),
        Nvl(msi.location_control_code,1),
        msi.primary_uom_code,
        Nvl(msi.inspection_required_flag,'N'),
        Nvl(msi.shelf_life_code, 1),
        Nvl(msi.shelf_life_days,0),
        Nvl(msi.allowed_units_lookup_code, 2),
        Nvl(msi.effectivity_control,1),
        0,
        0,
        Nvl(msi.default_serial_status_id,1),
        Nvl(msi.serial_status_enabled,'N'),
        Nvl(msi.default_lot_status_id,0),
        Nvl(msi.lot_status_enabled,'N'),
       --- msi.concatenated_segments,
        mcr.cross_reference,
        'C',
        msi.inventory_item_flag,
        0,
        msi.inventory_asset_flag,
        msi.outside_operation_flag
        from po_lines_all pol
        ,mtl_system_items_kfv msi
        ,mtl_cross_references mcr
        where msi.organization_id = p_organization_id
        and ( (mcr.cross_reference_type = p_crossreftype
               and mcr.cross_reference like  p_concatenated_segments
              ) or
              ( mcr.cross_reference_type = g_gtin_cross_ref_type
               AND mcr.cross_reference      LIKE g_crossref )
            )
        and ( (mcr.org_independent_flag = 'Y') or (mcr.org_independent_flag = 'N'
        and mcr.organization_id = p_organization_id
               ) )
        and mcr.inventory_item_id = msi.inventory_item_id
        and pol.item_id = msi.inventory_item_id
        and pol.po_header_id = p_poHeaderID
        and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
        and msi.inventory_item_id IN
        ( SELECT pl.item_id FROM po_lines_all pl WHERE pl.po_header_id =
        p_poHeaderID
          and exists (select 1 from po_line_locations_all pll where NVL(pll.closed_code,'OPEN')
          not in ('CLOSED', 'FINALLY CLOSED', 'CLOSED FOR RECEIVING')
        and Nvl(pll.ship_to_organization_id, p_organization_id) = p_organization_id
          and  pll.po_header_id =   p_poHeaderID and pll.po_line_id = pl.po_line_id
         AND Nvl(pll.cancel_flag,'N') = 'N'
        and pll.receiving_routing_id = 3)
                 and  exists
        (select 1 from po_distributions_all pd
        where pd.po_header_id =  p_poHeaderID
        and pd.po_line_id = pol.po_line_id
        and ((p_projectId is null or pd.project_id = p_projectId)
               and (p_taskId is null or pd.task_id = p_taskId)
             )
         )
        )
        ;
      end if;
      -- End of PJM Based Tran
  else

-- *****************************
--- Start of not PJM BASED Tran.
-- *****************************

      if (p_poReleaseID is not null) then
-- *****************************
-- Release Based Transaction
-- *****************************
        open x_items for
        select concatenated_segments,
        inventory_item_id,
        description,
        Nvl(revision_qty_control_code,1),
        Nvl(lot_control_code, 1),
        Nvl(serial_number_control_code, 1),
        Nvl(restrict_subinventories_code, 2),
        Nvl(restrict_locators_code, 2),
        Nvl(location_control_code, 1),
        primary_uom_code,
        Nvl(inspection_required_flag, 'N'),
        Nvl(shelf_life_code, 1),
        Nvl(shelf_life_days,0),
        Nvl(allowed_units_lookup_code, 2),
        Nvl(effectivity_control,1),
        0,
        0,
        Nvl(default_serial_status_id,1),
        Nvl(serial_status_enabled,'N'),
        Nvl(default_lot_status_id,0),
        Nvl(lot_status_enabled,'N'),
        '',
        'N',
        inventory_item_flag,
        0,
        inventory_asset_flag,
        outside_operation_flag
        from mtl_system_items_kfv
        WHERE organization_id = p_Organization_Id
              and concatenated_segments like p_concatenated_segments
              and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
              and inventory_item_id IN (SELECT pol.item_id FROM po_lines_all pol
        where pol.po_header_id =   p_poHeaderID
        and exists (select 1 from po_line_locations_all pll WHERE NVL(pll.closed_code,'OPEN')
        not in ('CLOSED','FINALLY CLOSED', 'CLOSED FOR RECEIVING') and
        Nvl(pll.ship_to_organization_id, p_organization_id) = p_organization_id and
        pll.po_header_id = p_poHeaderID
        and pll.po_release_id = p_poReleaseID
        and pll.po_line_id = pol.po_line_id
         AND Nvl(pll.cancel_flag,'N') = 'N'
        and pll.receiving_routing_id = 3)
        )
        UNION ALL
        -- Substitute ITEM SQL
        select distinct msi.concatenated_segments,
        msi.inventory_item_id,
        msi.description,
        Nvl(msi.revision_qty_control_code,1),
        Nvl(msi.lot_control_code, 1),
        Nvl(msi.serial_number_control_code, 1),
        Nvl(msi.restrict_subinventories_code, 2),
        Nvl(msi.restrict_locators_code,2),
        Nvl(msi.location_control_code,1),
        msi.primary_uom_code,
        Nvl(msi.inspection_required_flag,'N'),
        Nvl(msi.shelf_life_code, 1),
        Nvl(msi.shelf_life_days,0),
        Nvl(msi.allowed_units_lookup_code, 2),
        Nvl(msi.effectivity_control,1),
        0,
        0,
        Nvl(msi.default_serial_status_id,1),
        Nvl(msi.serial_status_enabled,'N'),
        Nvl(msi.default_lot_status_id,0),
        Nvl(msi.lot_status_enabled,'N'),
        msia.concatenated_segments,
        'S',
        msi.inventory_item_flag,
        0,
        msi.inventory_asset_flag,
        msi.outside_operation_flag
        from po_lines_all pol
        ,mtl_related_items mri
        ,mtl_system_items_kfv msi
       ,mtl_system_items_kfv msia
        where msi.organization_id =  p_organization_id
        and msi.concatenated_segments like  p_concatenated_segments
        and pol.po_header_id = p_poHeaderID
        and pol.item_id = msia.inventory_item_id
        and msia.organization_id = p_organization_id
        and ((    mri.related_item_id = msi.inventory_item_id
        and pol.item_id = mri.inventory_item_id) or
         (    mri.inventory_item_id = msi.inventory_item_id
         and pol.item_id = mri.related_item_id
         and mri.reciprocal_flag = 'Y'))
         and exists (select 1 from  po_line_locations_all pll
                                   where NVL(pll.closed_code,'OPEN')
                                   not in ('CLOSED', 'FINALLY CLOSED', 'CLOSED FOR RECEIVING')
        and Nvl(pll.ship_to_organization_id, p_organization_id) = p_organization_id
        and   Nvl(pll.allow_substitute_receipts_flag, 'N') = 'Y'
        and   pll.po_header_id = pol.po_header_id
        and   pll.po_line_id = pol.po_line_id
        and   pll.po_release_id = p_poReleaseID
         AND Nvl(pll.cancel_flag,'N') = 'N'
        and pll.receiving_routing_id = 3)
        UNION ALL
        -- Vendor Item SQL
        select distinct pol.vendor_product_num,
        msi.inventory_item_id,
        msi.description,
        Nvl(msi.revision_qty_control_code,1),
        Nvl(msi.lot_control_code, 1),
        Nvl(msi.serial_number_control_code, 1),
        Nvl(msi.restrict_subinventories_code, 2),
        Nvl(msi.restrict_locators_code,2),
        Nvl(msi.location_control_code,1),
        msi.primary_uom_code,
        Nvl(msi.inspection_required_flag,'N'),
        Nvl(msi.shelf_life_code, 1),
        Nvl(msi.shelf_life_days,0),
        Nvl(msi.allowed_units_lookup_code, 2),
        Nvl(msi.effectivity_control,1),
        0,
        0,
        Nvl(msi.default_serial_status_id,1),
        Nvl(msi.serial_status_enabled,'N'),
        Nvl(msi.default_lot_status_id,0),
        Nvl(msi.lot_status_enabled,'N'),
        msi.concatenated_segments,
        'Y',
        msi.inventory_item_flag,
        0,
        msi.inventory_asset_flag,
        msi.outside_operation_flag
        from po_lines_all pol
        , mtl_system_items_kfv msi
        where organization_id =  p_organization_id
        and pol.vendor_product_num like  p_concatenated_segments
        and pol.item_id = msi.inventory_item_id
        and  pol.vendor_product_num IS NOT NULL
        and pol.po_header_id =  p_poHeaderID
        and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
        and inventory_item_id IN (SELECT pol.item_id FROM po_lines_all pol
        where pol.po_header_id =   p_poHeaderID
        and exists (select 1 from po_line_locations_all pll WHERE NVL(pll.closed_code,'OPEN')
        not in ('CLOSED', 'FINALLY CLOSED', 'CLOSED FOR RECEIVING') and
        pll.po_header_id = p_poHeaderID
        and Nvl(pll.ship_to_organization_id, p_organization_id) = p_organization_id
        and pll.po_release_id = p_poReleaseID
        and pll.po_line_id = pol.po_line_id
         AND Nvl(pll.cancel_flag,'N') = 'N'
        and pll.receiving_routing_id = 3)
        )
        UNION ALL
        -- non item Master
        select distinct pol.item_description,
        to_number(''),
        pol.item_description,
        1,
        1,
        1,
        2,
        2,
        1,
        mum.uom_code,
        'N',
        1,
        0,
        2,
        1,
        0,
        0,
        1,
        'N',
        0,
        'N',
        '',
        'N',
        'N',
        0,
        to_char(NULL),
        'N'
        from po_lines_all pol
        , mtl_units_of_measure mum
        -- Bug 2619063, 2614016
        -- Modified to select the base uom for the uom class defined on po.
        where mum.uom_class = (SELECT mum2.uom_class
                                 FROM mtl_units_of_measure mum2
                                WHERE mum2.unit_of_measure(+) = pol.unit_meas_lookup_code)
        and mum.base_uom_flag = 'Y'
        and pol.ITEM_ID is null
        and pol.item_description is not null
        and pol.po_header_id = p_poHeaderID
        and pol.item_description like  p_concatenated_segments
        UNION ALL
        -- Cross Ref  SQL
        select distinct msi.concatenated_segments,
        ---select distinct mcr.cross_reference,
        msi.inventory_item_id,
        msi.description,
        Nvl(msi.revision_qty_control_code,1),
        Nvl(msi.lot_control_code, 1),
        Nvl(msi.serial_number_control_code, 1),
        Nvl(msi.restrict_subinventories_code, 2),
        Nvl(msi.restrict_locators_code,2),
        Nvl(msi.location_control_code,1),
        msi.primary_uom_code,
        Nvl(msi.inspection_required_flag,'N'),
        Nvl(msi.shelf_life_code, 1),
        Nvl(msi.shelf_life_days,0),
        Nvl(msi.allowed_units_lookup_code, 2),
        Nvl(msi.effectivity_control,1),
        0,
        0,
        Nvl(msi.default_serial_status_id,1),
        Nvl(msi.serial_status_enabled,'N'),
        Nvl(msi.default_lot_status_id,0),
        Nvl(msi.lot_status_enabled,'N'),
       --- msi.concatenated_segments,
        mcr.cross_reference,
        'C',
        msi.inventory_item_flag,
        0,
        msi.inventory_asset_flag,
        msi.outside_operation_flag
        from po_lines_all pol
        ,mtl_system_items_kfv msi
        ,mtl_cross_references mcr
        where msi.organization_id = p_organization_id
        and ( (mcr.cross_reference_type = p_crossreftype
               and mcr.cross_reference like  p_concatenated_segments
              ) or
              ( mcr.cross_reference_type = g_gtin_cross_ref_type
               AND mcr.cross_reference      LIKE g_crossref )
            )
        and ( (mcr.org_independent_flag = 'Y') or (mcr.org_independent_flag = 'N'
        and mcr.organization_id = p_organization_id
               ) )
        and mcr.inventory_item_id = msi.inventory_item_id
        and pol.item_id = msi.inventory_item_id
        and pol.po_header_id = p_poHeaderID
        and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
        and msi.inventory_item_id IN (SELECT pol.item_id FROM po_lines_all pol
        where pol.po_header_id =   p_poHeaderID
        and exists (select 1 from po_line_locations_all pll WHERE NVL(pll.closed_code,'OPEN')
        not in ('CLOSED', 'FINALLY CLOSED', 'CLOSED FOR RECEIVING') and
        pll.po_header_id = p_poHeaderID
        and Nvl(pll.ship_to_organization_id, p_organization_id) = p_organization_id
        and pll.po_release_id = p_poReleaseID
        and pll.po_line_id = pol.po_line_id
         AND Nvl(pll.cancel_flag,'N') = 'N'
        and pll.receiving_routing_id = 3)
        )
        ;
      elsif  (p_poLineID IS NOT NULL) then
-- *****************************
--  Deafult Line Based  Tran
--- ***************************
        open x_items for
        select concatenated_segments,
        inventory_item_id,
        description,
        Nvl(revision_qty_control_code,1),
        Nvl(lot_control_code, 1),
        Nvl(serial_number_control_code, 1),
        Nvl(restrict_subinventories_code, 2),
        Nvl(restrict_locators_code, 2),
        Nvl(location_control_code, 1),
        primary_uom_code,
        Nvl(inspection_required_flag, 'N'),
        Nvl(shelf_life_code, 1),
        Nvl(shelf_life_days,0),
        Nvl(allowed_units_lookup_code, 2),
        Nvl(effectivity_control,1),
        0,
        0,
        Nvl(default_serial_status_id,1),
        Nvl(serial_status_enabled,'N'),
        Nvl(default_lot_status_id,0),
        Nvl(lot_status_enabled,'N'),
        '',
        'N',
        inventory_item_flag,
        0,
        inventory_asset_flag,
        outside_operation_flag
        from mtl_system_items_kfv
        WHERE organization_id = p_Organization_Id
              and concatenated_segments like p_concatenated_segments
              and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
              and inventory_item_id IN (SELECT pl.item_id FROM po_lines_all pl WHERE
        pl.po_header_id = p_poHeaderID
        and pl.po_line_id = p_poLineID
        and exists (select 1 from po_line_locations_all pll where NVL(pll.closed_code,
        'OPEN')
        not in ('CLOSED','FINALLY CLOSED' , 'CLOSED FOR RECEIVING' )
        and  pll.po_header_id = p_poHeaderID
        and Nvl(pll.ship_to_organization_id, p_organization_id) = p_organization_id
        and pll.po_line_id = p_poLineID
         AND Nvl(pll.cancel_flag,'N') = 'N'
        and pll.receiving_routing_id = 3
        ))
        UNION ALL
        -- Substitute Item SQL
        select distinct msi.concatenated_segments,
        msi.inventory_item_id,
        msi.description,
        Nvl(msi.revision_qty_control_code,1),
        Nvl(msi.lot_control_code, 1),
        Nvl(msi.serial_number_control_code, 1),
        Nvl(msi.restrict_subinventories_code, 2),
        Nvl(msi.restrict_locators_code,2),
        Nvl(msi.location_control_code,1),
        msi.primary_uom_code,
        Nvl(msi.inspection_required_flag,'N'),
        Nvl(msi.shelf_life_code, 1),
        Nvl(msi.shelf_life_days,0),
        Nvl(msi.allowed_units_lookup_code, 2),
        Nvl(msi.effectivity_control,1),
        0,
        0,
        Nvl(msi.default_serial_status_id,1),
        Nvl(msi.serial_status_enabled,'N'),
        Nvl(msi.default_lot_status_id,0),
        Nvl(msi.lot_status_enabled,'N'),
        msia.concatenated_segments,
        'S',
        msi.inventory_item_flag,
        0,
        msi.inventory_asset_flag,
        msi.outside_operation_flag
        from po_lines_all pol
        ,mtl_related_items mri
        ,mtl_system_items_kfv msi
        ,mtl_system_items_kfv msia
        where msi.organization_id =  p_organization_id
        and msi.concatenated_segments like  p_concatenated_segments
        and pol.po_header_id = p_poHeaderID
        and pol.item_id = msia.inventory_item_id
        and msia.organization_id = p_organization_id
        and ((    mri.related_item_id = msi.inventory_item_id
        and pol.item_id = mri.inventory_item_id) or
        (    mri.inventory_item_id = msi.inventory_item_id
        and pol.item_id = mri.related_item_id
        and mri.reciprocal_flag = 'Y'))
        and pol.po_line_id = p_poLineID
        and exists (select 1 from  po_line_locations_all pll
                          where NVL(pll.closed_code,'OPEN') not in
        ('CLOSED', 'FINALLY CLOSED', 'CLOSED FOR RECEIVING')
        and   Nvl(pll.allow_substitute_receipts_flag, 'N') = 'Y'
        and   pll.po_header_id = pol.po_header_id
        and Nvl(pll.ship_to_organization_id, p_organization_id) = p_organization_id
        and   pll.po_line_id = pol.po_line_id
        and pll.receiving_routing_id = 3)
        UNION ALL
        -- Vendor Item SQL
        select distinct pol.vendor_product_num,
        msi.inventory_item_id,
        msi.description,
        Nvl(msi.revision_qty_control_code,1),
        Nvl(msi.lot_control_code, 1),
        Nvl(msi.serial_number_control_code, 1),
        Nvl(msi.restrict_subinventories_code, 2),
        Nvl(msi.restrict_locators_code,2),
        Nvl(msi.location_control_code,1),
        msi.primary_uom_code,
        Nvl(msi.inspection_required_flag,'N'),
        Nvl(msi.shelf_life_code, 1),
        Nvl(msi.shelf_life_days,0),
        Nvl(msi.allowed_units_lookup_code, 2),
        Nvl(msi.effectivity_control,1),
        0,
        0,
        Nvl(msi.default_serial_status_id,1),
        Nvl(msi.serial_status_enabled,'N'),
        Nvl(msi.default_lot_status_id,0),
        Nvl(msi.lot_status_enabled,'N'),
        msi.concatenated_segments,
        'Y',
        msi.inventory_item_flag,
        0,
        msi.inventory_asset_flag,
        msi.outside_operation_flag
        from po_lines_all pol
        ,mtl_system_items_kfv msi
        where organization_id =  p_organization_id
        and pol.vendor_product_num like  p_concatenated_segments
        and pol.item_id = msi.inventory_item_id
        and  pol.vendor_product_num IS NOT NULL
        and pol.po_header_id =  p_poHeaderID
        and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
        and inventory_item_id IN (SELECT pl.item_id FROM po_lines_all pl WHERE
        pl.po_header_id = p_poHeaderID
        and pl.po_line_id = p_poLineID
        and exists (select 1 from po_line_locations_all pll where NVL(pll.closed_code,
        'OPEN')
        not in ('CLOSED', 'FINALLY CLOSED' , 'CLOSED FOR RECEIVING' )
        and  pll.po_header_id = p_poHeaderID
        and Nvl(pll.ship_to_organization_id, p_organization_id) = p_organization_id
        and pll.po_line_id = p_poLineID
         AND Nvl(pll.cancel_flag,'N') = 'N'
        and pll.receiving_routing_id = 3
        ))
        UNION ALL
        -- non item Master
        select distinct pol.item_description,
        to_number(''),
        pol.item_description,
        1,
        1,
        1,
        2,
        2,
        1,
        mum.uom_code,
        'N',
        1,
        0,
        2,
        1,
        0,
        0,
        1,
        'N',
        0,
        'N',
        '',
        'N',
        'N',
        0,
        to_char(NULL),
        'N'
        from po_lines_all pol
        , mtl_units_of_measure mum
        -- Bug 2619063, 2614016
        -- Modified to select the base uom for the uom class defined on po.
        where mum.uom_class = (SELECT mum2.uom_class
                                 FROM mtl_units_of_measure mum2
                                WHERE mum2.unit_of_measure(+) = pol.unit_meas_lookup_code)
        and mum.base_uom_flag = 'Y'
        and pol.ITEM_ID is null
        and pol.item_description is not null
        and pol.po_header_id = p_poHeaderID
        and pol.item_description like  p_concatenated_segments
        UNION ALL
        -- Cross Ref  SQL
        ---select distinct mcr.cross_reference,
        select distinct msi.concatenated_segments,
        msi.inventory_item_id,
        msi.description,
        Nvl(msi.revision_qty_control_code,1),
        Nvl(msi.lot_control_code, 1),
        Nvl(msi.serial_number_control_code, 1),
        Nvl(msi.restrict_subinventories_code, 2),
        Nvl(msi.restrict_locators_code,2),
        Nvl(msi.location_control_code,1),
        msi.primary_uom_code,
        Nvl(msi.inspection_required_flag,'N'),
        Nvl(msi.shelf_life_code, 1),
        Nvl(msi.shelf_life_days,0),
        Nvl(msi.allowed_units_lookup_code, 2),
        Nvl(msi.effectivity_control,1),
        0,
        0,
        Nvl(msi.default_serial_status_id,1),
        Nvl(msi.serial_status_enabled,'N'),
        Nvl(msi.default_lot_status_id,0),
        Nvl(msi.lot_status_enabled,'N'),
        ---msi.concatenated_segments,
        mcr.cross_reference,
        'C',
        msi.inventory_item_flag,
        0,
        msi.inventory_asset_flag,
        msi.outside_operation_flag
        from po_lines_all pol
        ,mtl_system_items_kfv msi
        ,mtl_cross_references mcr
        where msi.organization_id = p_organization_id
        and ( (mcr.cross_reference_type = p_crossreftype
               and mcr.cross_reference like  p_concatenated_segments
              ) or
              ( mcr.cross_reference_type = g_gtin_cross_ref_type
               AND mcr.cross_reference      LIKE g_crossref )
            )
        and ( (mcr.org_independent_flag = 'Y') or (mcr.org_independent_flag = 'N'
        and mcr.organization_id = p_organization_id
               ) )
        and mcr.inventory_item_id = msi.inventory_item_id
        and pol.item_id = msi.inventory_item_id
        and pol.po_header_id = p_poHeaderID
        and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
        and msi.inventory_item_id IN (SELECT pl.item_id FROM po_lines_all pl WHERE
        pl.po_header_id = p_poHeaderID
        and pl.po_line_id = p_poLineID
        and exists (select 1 from po_line_locations_all pll where NVL(pll.closed_code,
        'OPEN')
        not in ('CLOSED', 'FINALLY CLOSED' , 'CLOSED FOR RECEIVING' )
        and  pll.po_header_id = p_poHeaderID
        and Nvl(pll.ship_to_organization_id, p_organization_id) = p_organization_id
        and pll.po_line_id = p_poLineID
         AND Nvl(pll.cancel_flag,'N') = 'N'
        and pll.receiving_routing_id = 3
        ))
        ;
      else
-- *****************************
--      Deafult headerBased  Tran
-- ***************************
        open x_Items for
        select concatenated_segments,
        inventory_item_id,
        description,
        Nvl(revision_qty_control_code,1),
        Nvl(lot_control_code, 1),
        Nvl(serial_number_control_code, 1),
        Nvl(restrict_subinventories_code, 2),
        Nvl(restrict_locators_code, 2),
        Nvl(location_control_code, 1),
        primary_uom_code,
        Nvl(inspection_required_flag, 'N'),
        Nvl(shelf_life_code, 1),
        Nvl(shelf_life_days,0),
        Nvl(allowed_units_lookup_code, 2),
        Nvl(effectivity_control,1),
        0,
        0,
        Nvl(default_serial_status_id,1),
        Nvl(serial_status_enabled,'N'),
        Nvl(default_lot_status_id,0),
        Nvl(lot_status_enabled,'N'),
        '',
        'N',
        inventory_item_flag,
        0,
        inventory_asset_flag,
        outside_operation_flag
        from mtl_system_items_kfv
        WHERE organization_id = p_Organization_Id
        and concatenated_segments like p_concatenated_segments
        and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
        and inventory_item_id IN
        ( SELECT pl.item_id FROM po_lines_all pl WHERE pl.po_header_id = p_poHeaderID
        and exists (select 1 from po_line_locations_all pll where NVL(pll.closed_code,'OPEN')
        not in ('CLOSED', 'FINALLY CLOSED', 'CLOSED FOR RECEIVING')
        and  pll.po_header_id = p_poHeaderID
        and Nvl(pll.ship_to_organization_id, p_organization_id) = p_organization_id
        and pll.po_line_id = pl.po_line_id
         AND Nvl(pll.cancel_flag,'N') = 'N'
        and pll.receiving_routing_id = 3)
        )
        UNION ALL
        -- Substitute Item SQL
        select distinct msi.concatenated_segments,
        msi.inventory_item_id,
        msi.description,
        Nvl(msi.revision_qty_control_code,1),
        Nvl(msi.lot_control_code, 1),
        Nvl(msi.serial_number_control_code, 1),
        Nvl(msi.restrict_subinventories_code, 2),
        Nvl(msi.restrict_locators_code,2),
        Nvl(msi.location_control_code,1),
        msi.primary_uom_code,
        Nvl(msi.inspection_required_flag,'N'),
        Nvl(msi.shelf_life_code, 1),
        Nvl(msi.shelf_life_days,0),
        Nvl(msi.allowed_units_lookup_code, 2),
        Nvl(msi.effectivity_control,1),
        0,
        0,
        Nvl(msi.default_serial_status_id,1),
        Nvl(msi.serial_status_enabled,'N'),
        Nvl(msi.default_lot_status_id,0),
        Nvl(msi.lot_status_enabled,'N'),
        msia.concatenated_segments,
        'S',
        msi.inventory_item_flag,
        0,
        msi.inventory_asset_flag,
        msi.outside_operation_flag
        from po_lines_all pol
        ,mtl_related_items mri
        ,mtl_system_items_kfv msi
       ,mtl_system_items_kfv msia
        where msi.organization_id =  p_organization_id
        and msi.concatenated_segments like  p_concatenated_segments
        and pol.po_header_id = p_poHeaderID
        and pol.item_id = msia.inventory_item_id
        and msia.organization_id = p_organization_id
        and ((    mri.related_item_id = msi.inventory_item_id
        and pol.item_id = mri.inventory_item_id) or
        (    mri.inventory_item_id = msi.inventory_item_id
        and pol.item_id = mri.related_item_id
        and mri.reciprocal_flag = 'Y'))
        and exists (select 1 from  po_line_locations_all pll
                           where NVL(pll.closed_code,'OPEN') not in ('CLOSED','FINALLY CLOSED',
        'CLOSED FOR RECEIVING')
        and   Nvl(pll.allow_substitute_receipts_flag, 'N') = 'Y'
        and   pll.po_header_id = pol.po_header_id
        and Nvl(pll.ship_to_organization_id, p_organization_id) = p_organization_id
        and   pll.po_line_id = pol.po_line_id
         AND Nvl(pll.cancel_flag,'N') = 'N'
        and pll.receiving_routing_id = 3)
        UNION ALL
        -- Vendor Item SQL
        select distinct pol.vendor_product_num,
        msi.inventory_item_id,
        msi.description,
        Nvl(msi.revision_qty_control_code,1),
        Nvl(msi.lot_control_code, 1),
        Nvl(msi.serial_number_control_code, 1),
        Nvl(msi.restrict_subinventories_code, 2),
        Nvl(msi.restrict_locators_code,2),
        Nvl(msi.location_control_code,1),
        msi.primary_uom_code,
        Nvl(msi.inspection_required_flag,'N'),
        Nvl(msi.shelf_life_code, 1),
        Nvl(msi.shelf_life_days,0),
        Nvl(msi.allowed_units_lookup_code, 2),
        Nvl(msi.effectivity_control,1),
        0,
        0,
        Nvl(msi.default_serial_status_id,1),
        Nvl(msi.serial_status_enabled,'N'),
        Nvl(msi.default_lot_status_id,0),
        Nvl(msi.lot_status_enabled,'N'),
        msi.concatenated_segments,
        'Y',
        msi.inventory_item_flag,
        0,
        msi.inventory_asset_flag,
        msi.outside_operation_flag
        from po_lines_all pol
        , mtl_system_items_kfv msi
        where organization_id =  p_organization_id
        and pol.vendor_product_num like  p_concatenated_segments
        and pol.item_id = msi.inventory_item_id
        and  pol.vendor_product_num IS NOT NULL
        and pol.po_header_id =  p_poHeaderID
        and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
        and inventory_item_id IN
        ( SELECT pl.item_id FROM po_lines_all pl WHERE pl.po_header_id =
        p_poHeaderID
        and exists (select 1 from po_line_locations_all pll where
        NVL(pll.closed_code,'OPEN')
        not in ('CLOSED', 'FINALLY CLOSED', 'CLOSED FOR RECEIVING')
        and  pll.po_header_id = p_poHeaderID
        and Nvl(pll.ship_to_organization_id, p_organization_id) = p_organization_id
        and pll.po_line_id = pl.po_line_id
         AND Nvl(pll.cancel_flag,'N') = 'N'
        and pll.receiving_routing_id = 3)
        )
        UNION ALL
        -- non item Master
        select distinct pol.item_description,
        to_number(''),
        pol.item_description,
        1,
        1,
        1,
        2,
        2,
        1,
        mum.uom_code,
        'N',
        1,
        0,
        2,
        1,
        0,
        0,
        1,
        'N',
        0,
        'N',
        '',
        'N',
        'N',
        0,
        to_char(NULL),
        'N'
        from po_lines_all pol
        , mtl_units_of_measure mum
        -- Bug 2619063, 2614016
        -- Modified to select the base uom for the uom class defined on po.
        where mum.uom_class = (SELECT mum2.uom_class
                                 FROM mtl_units_of_measure mum2
                                WHERE mum2.unit_of_measure(+) = pol.unit_meas_lookup_code)
        and mum.base_uom_flag = 'Y'
        and pol.ITEM_ID is null
        and pol.item_description is not null
        and pol.po_header_id = p_poHeaderID
        and pol.item_description like  p_concatenated_segments
        UNION ALL
        -- Cross Ref  SQL
        ---select distinct mcr.cross_reference,
        select distinct msi.concatenated_segments,
        msi.inventory_item_id,
        msi.description,
        Nvl(msi.revision_qty_control_code,1),
        Nvl(msi.lot_control_code, 1),
        Nvl(msi.serial_number_control_code, 1),
        Nvl(msi.restrict_subinventories_code, 2),
        Nvl(msi.restrict_locators_code,2),
        Nvl(msi.location_control_code,1),
        msi.primary_uom_code,
        Nvl(msi.inspection_required_flag,'N'),
        Nvl(msi.shelf_life_code, 1),
        Nvl(msi.shelf_life_days,0),
        Nvl(msi.allowed_units_lookup_code, 2),
        Nvl(msi.effectivity_control,1),
        0,
        0,
        Nvl(msi.default_serial_status_id,1),
        Nvl(msi.serial_status_enabled,'N'),
        Nvl(msi.default_lot_status_id,0),
        Nvl(msi.lot_status_enabled,'N'),
       --- msi.concatenated_segments,
        mcr.cross_reference,
        'C',
        msi.inventory_item_flag,
        0,
        msi.inventory_asset_flag,
        msi.outside_operation_flag
        from po_lines_all pol
        ,mtl_system_items_kfv msi
        ,mtl_cross_references mcr
        where msi.organization_id = p_organization_id
        and ( (mcr.cross_reference_type = p_crossreftype
               and mcr.cross_reference like  p_concatenated_segments
              ) or
              ( mcr.cross_reference_type = g_gtin_cross_ref_type
               AND mcr.cross_reference      LIKE g_crossref )
            )
        and ( (mcr.org_independent_flag = 'Y') or (mcr.org_independent_flag = 'N'
        and mcr.organization_id = p_organization_id
               ) )
        and mcr.inventory_item_id = msi.inventory_item_id
        and pol.item_id = msi.inventory_item_id
        and pol.po_header_id = p_poHeaderID
        and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
        and msi.inventory_item_id IN
        ( SELECT pl.item_id FROM po_lines_all pl WHERE pl.po_header_id = p_poHeaderID
        and exists (select 1 from po_line_locations_all pll where NVL(pll.closed_code,'OPEN')
        not in ('CLOSED', 'FINALLY CLOSED', 'CLOSED FOR RECEIVING')
        and  pll.po_header_id = p_poHeaderID
        and Nvl(pll.ship_to_organization_id, p_organization_id) = p_organization_id
        and pll.po_line_id = pl.po_line_id
         AND Nvl(pll.cancel_flag,'N') = 'N'
        and pll.receiving_routing_id = 3)
        )
        ;

      end if;

-- *****************************
-- End of not PJM Based Tran
-- *****************************

end if;

-- *****************************
--- END OF PO HEADER  ID SECTION
-- *****************************

elsif  (p_shipmentHeaderID is not null ) then
-- *****************************
--- START  OF SHIPMENT HEADER  ID SECTION
-- *****************************
      open x_Items for
      select concatenated_segments,
       inventory_item_id,
       description,
       Nvl(revision_qty_control_code,1),
       Nvl(lot_control_code, 1),
       Nvl(serial_number_control_code, 1),
       Nvl(restrict_subinventories_code, 2),
       Nvl(restrict_locators_code, 2),
       Nvl(location_control_code, 1),
       primary_uom_code,
       Nvl(inspection_required_flag, 'N'),
       Nvl(shelf_life_code, 1),
       Nvl(shelf_life_days,0),
       Nvl(allowed_units_lookup_code, 2),
       Nvl(effectivity_control,1),
       0,
       0,
       Nvl(default_serial_status_id,1),
       Nvl(serial_status_enabled,'N'),
       Nvl(default_lot_status_id,0),
       Nvl(lot_status_enabled,'N'),
       '',
       'N',
       inventory_item_flag,
       0,
       inventory_asset_flag,
       outside_operation_flag
       from mtl_system_items_kfv msn,
            rcv_shipment_lines rsl
       WHERE msn.organization_id = p_Organization_Id
       and msn.concatenated_segments like p_concatenated_segments
       and (msn.purchasing_enabled_flag = 'Y' OR msn.stock_enabled_flag = 'Y')
       and rsl.SHIPMENT_HEADER_ID = p_shipmentHeaderID
       -- This was fix for bug 2740648/2752094
       AND rsl.shipment_line_status_code in ('EXPECTED','PARTIALLY RECEIVED')
       and rsl.item_id = msn.inventory_item_id
      UNION
          -- bug 2775596
          -- added unions for the substitute item and vendor item
          -- if receiving an ASN.
        -- Vendor Item SQL
        select distinct pol.vendor_product_num,
        msi.inventory_item_id,
        msi.description,
        Nvl(msi.revision_qty_control_code,1),
        Nvl(msi.lot_control_code, 1),
        Nvl(msi.serial_number_control_code, 1),
        Nvl(msi.restrict_subinventories_code, 2),
        Nvl(msi.restrict_locators_code,2),
        Nvl(msi.location_control_code,1),
        msi.primary_uom_code,
        Nvl(msi.inspection_required_flag,'N'),
        Nvl(msi.shelf_life_code, 1),
        Nvl(msi.shelf_life_days,0),
        Nvl(msi.allowed_units_lookup_code, 2),
        Nvl(msi.effectivity_control,1),
        0,
        0,
        Nvl(msi.default_serial_status_id,1),
        Nvl(msi.serial_status_enabled,'N'),
        Nvl(msi.default_lot_status_id,0),
        Nvl(msi.lot_status_enabled,'N'),
        msi.concatenated_segments,
        'Y',
        msi.inventory_item_flag,
        0,
        msi.inventory_asset_flag,
        msi.outside_operation_flag
        from po_lines_all pol
        ,mtl_system_items_kfv msi
        , rcv_shipment_lines rsl
        where organization_id =  p_Organization_Id
        and pol.vendor_product_num like  p_concatenated_segments
        and pol.item_id = msi.inventory_item_id
        and pol.vendor_product_num IS NOT NULL
        and pol.po_header_id = Nvl(p_poheaderid,pol.po_header_id)
        and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
        and inventory_item_id IN (SELECT pl.item_id
                                  FROM po_lines_all pl
                                  WHERE pl.po_header_id = rsl.po_header_id
                                  and pl.po_line_id = rsl.po_line_id
                                  and exists (select 1 from
                                              po_line_locations_all pll
                                              where NVL(pll.closed_code,'OPEN')
                                                       not in ('CLOSED', 'FINALLY CLOSED' , 'CLOSED FOR RECEIVING' )
                                              and  pll.po_header_id = rsl.po_header_id
        and Nvl(pll.ship_to_organization_id, p_organization_id) = p_organization_id
                                              and pll.po_line_id = rsl.po_line_id
         AND Nvl(pll.cancel_flag,'N') = 'N'
                                              and pll.receiving_routing_id = 3
                                              ))
        AND pol.po_line_id = rsl.po_line_id
        and rsl.SHIPMENT_HEADER_ID = p_shipmentHeaderID
        AND rsl.shipment_line_status_code in ('EXPECTED','PARTIALLY RECEIVED')
        AND rsl.source_document_code = 'PO'
       UNION
        -- Bug 2775532
        -- This section is non item master stuff for ASNs
        select distinct pol.item_description,
        to_number(''),
        pol.item_description,
        1,
        1,
        1,
        2,
        2,
        1,
        mum.uom_code,
        'N',
        1,
        0,
        2,
        1,
        0,
        0,
        1,
        'N',
        0,
        'N',
        '',
        'N',
        'N',
        0,
        to_char(NULL),
        'N'
        from po_lines_all pol
        , mtl_units_of_measure mum
        , rcv_shipment_lines rsl
        -- Bug 2619063, 2614016
        -- Modified to select the base uom for the uom class defined on po.
        where mum.uom_class = (SELECT mum2.uom_class
                                 FROM mtl_units_of_measure mum2
                                WHERE mum2.unit_of_measure(+) = pol.unit_meas_lookup_code)
        and mum.base_uom_flag = 'Y'
        and pol.ITEM_ID is null
        and pol.item_description is not null
        and pol.po_header_id = Nvl(p_poheaderid,pol.po_header_id)
        and pol.item_description like  p_concatenated_segments
        AND pol.po_line_id = rsl.po_line_id
        and rsl.SHIPMENT_HEADER_ID = p_shipmentHeaderID
        AND rsl.shipment_line_status_code in ('EXPECTED','PARTIALLY RECEIVED')
        AND rsl.source_document_code = 'PO'
       UNION
       -- This Section for GTIN Cross Ref
       ---select mcr.cross_reference,
        select distinct msn.concatenated_segments,
       msn.inventory_item_id,
       msn.description,
       Nvl(msn.revision_qty_control_code,1),
       Nvl(msn.lot_control_code, 1),
       Nvl(msn.serial_number_control_code, 1),
       Nvl(msn.restrict_subinventories_code, 2),
       Nvl(msn.restrict_locators_code, 2),
       Nvl(msn.location_control_code, 1),
       msn.primary_uom_code,
       Nvl(msn.inspection_required_flag, 'N'),
       Nvl(msn.shelf_life_code, 1),
       Nvl(msn.shelf_life_days,0),
       Nvl(msn.allowed_units_lookup_code, 2),
       Nvl(msn.effectivity_control,1),
       0,
       0,
       Nvl(msn.default_serial_status_id,1),
       Nvl(msn.serial_status_enabled,'N'),
       Nvl(msn.default_lot_status_id,0),
       Nvl(msn.lot_status_enabled,'N'),
       '',
       'N',
       msn.inventory_item_flag,
       0,
       msn.inventory_asset_flag,
       msn.outside_operation_flag
       from mtl_system_items_kfv msn,
            rcv_shipment_lines rsl,
            mtl_cross_references mcr
       WHERE msn.organization_id = p_Organization_Id
        and ( mcr.cross_reference_type = g_gtin_cross_ref_type
               AND mcr.cross_reference      LIKE g_crossref
            )
        and ( (mcr.org_independent_flag = 'Y') or (mcr.org_independent_flag = 'N'
        and mcr.organization_id = p_organization_id
               ) )
       and mcr.inventory_item_id = msn.inventory_item_id
       and (msn.purchasing_enabled_flag = 'Y' OR msn.stock_enabled_flag = 'Y')
       and rsl.SHIPMENT_HEADER_ID = p_shipmentHeaderID
       and rsl.item_id = msn.inventory_item_id
       ;


-- *****************************
--- END  OF SHIPMENT HEADER  ID SECTION
-- *****************************

elsif (p_oeOrderHeaderID is not null) then

-- *****************************
--- START  OF OE ORDER HEADER  ID SECTION
-- *****************************

       open x_items for
       select concatenated_segments,
       inventory_item_id,
       description,
       Nvl(revision_qty_control_code,1),
       Nvl(lot_control_code, 1),
       Nvl(serial_number_control_code, 1),
       Nvl(restrict_subinventories_code, 2),
       Nvl(restrict_locators_code, 2),
       Nvl(location_control_code, 1),
       primary_uom_code,
       Nvl(inspection_required_flag, 'N'),
       Nvl(shelf_life_code, 1),
       Nvl(shelf_life_days,0),
       Nvl(allowed_units_lookup_code, 2),
       Nvl(effectivity_control,1),
       0,
       0,
       Nvl(default_serial_status_id,1),
       Nvl(serial_status_enabled,'N'),
       Nvl(default_lot_status_id,0),
       Nvl(lot_status_enabled,'N'),
       '',
       'N',
       inventory_item_flag,
       0,
       inventory_asset_flag,
       outside_operation_flag
       from mtl_system_items_kfv
       WHERE organization_id = p_Organization_Id
       and concatenated_segments like p_concatenated_segments
       and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
       and inventory_item_id IN (SELECT oel.inventory_item_id FROM
       oe_order_lines_all oel WHERE oel.HEADER_ID = p_oeOrderHeaderID
       and oel.ORDERED_QUANTITY > NVL(oel.SHIPPED_QUANTITY,0)
       and ((p_projectId is null or oel.project_id = p_projectId)
             and (p_taskID is null or oel.task_id = p_taskId )) )
       UNION
       -- This Section Added for GTIN Cross Ref
       ---select mcr.cross_reference,
        select distinct msi.concatenated_segments,
       msi.inventory_item_id,
       msi.description,
       Nvl(msi.revision_qty_control_code,1),
       Nvl(msi.lot_control_code, 1),
       Nvl(msi.serial_number_control_code, 1),
       Nvl(msi.restrict_subinventories_code, 2),
       Nvl(msi.restrict_locators_code, 2),
       Nvl(msi.location_control_code, 1),
       msi.primary_uom_code,
       Nvl(msi.inspection_required_flag, 'N'),
       Nvl(msi.shelf_life_code, 1),
       Nvl(msi.shelf_life_days,0),
       Nvl(msi.allowed_units_lookup_code, 2),
       Nvl(msi.effectivity_control,1),
       0,
       0,
       Nvl(msi.default_serial_status_id,1),
       Nvl(msi.serial_status_enabled,'N'),
       Nvl(msi.default_lot_status_id,0),
       Nvl(msi.lot_status_enabled,'N'),
       '',
       'N',
       msi.inventory_item_flag,
       0,
       msi.inventory_asset_flag,
       msi.outside_operation_flag
       from mtl_system_items_kfv msi
           ,mtl_cross_references mcr
       WHERE msi.organization_id = p_Organization_Id
        and ( mcr.cross_reference_type = g_gtin_cross_ref_type
               AND mcr.cross_reference      LIKE g_crossref
            )
        and ( (mcr.org_independent_flag = 'Y') or (mcr.org_independent_flag = 'N'
        and mcr.organization_id = p_organization_id
               ) )
       and mcr.inventory_item_id = msi.inventory_item_id
       and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
       and msi.inventory_item_id IN (SELECT oel.inventory_item_id FROM
       oe_order_lines_all oel WHERE oel.HEADER_ID = p_oeOrderHeaderID
       and oel.ORDERED_QUANTITY > NVL(oel.SHIPPED_QUANTITY,0)
       and ((p_projectId is null or oel.project_id = p_projectId)
             and (p_taskID is null or oel.task_id = p_taskId )) ) ;

-- *****************************
--- END  OF OE ORDER HEADER  ID SECTION
-- *****************************

elsif  (p_reqHeaderID is not null) then

-- *****************************
--- START  OF REQ HEADER  ID SECTION
-- *****************************

       open x_items for
       select concatenated_segments,
       inventory_item_id,
       description,
       Nvl(revision_qty_control_code,1),
       Nvl(lot_control_code, 1),
       Nvl(serial_number_control_code, 1),
       Nvl(restrict_subinventories_code, 2),
       Nvl(restrict_locators_code, 2),
       Nvl(location_control_code, 1),
       primary_uom_code,
       Nvl(inspection_required_flag, 'N'),
       Nvl(shelf_life_code, 1),
       Nvl(shelf_life_days,0),
       Nvl(allowed_units_lookup_code, 2),
       Nvl(effectivity_control,1),
       0,
       0,
       Nvl(default_serial_status_id,1),
       Nvl(serial_status_enabled,'N'),
       Nvl(default_lot_status_id,0),
       Nvl(lot_status_enabled,'N'),
       '',
       'N',
       inventory_item_flag,
       0,
       inventory_asset_flag,
       outside_operation_flag
       from mtl_system_items_kfv
       WHERE organization_id = p_Organization_Id
       and concatenated_segments like p_concatenated_segments
       and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
       and  exists (SELECT 1 FROM po_requisition_lines_all  prl,
       rcv_shipment_lines rsl  , po_req_distributions_all prd
       WHERE prl.requisition_header_id = p_reqHeaderID
       and rsl.item_id = inventory_item_id
       and prl.requisition_line_id = rsl.requisition_line_id
       and prl.requisition_line_id  = prd.requisition_line_id
       and (p_projectId is null or prd.project_id = p_projectId)
       and (p_taskId is null or prd.task_id = p_taskId)
       )
       UNION
       -- Section for GTIN Cross Ref.
       ---select mcr.cross_reference,
        select distinct msi.concatenated_segments,
       msi.inventory_item_id,
       msi.description,
       Nvl(msi.revision_qty_control_code,1),
       Nvl(msi.lot_control_code, 1),
       Nvl(msi.serial_number_control_code, 1),
       Nvl(msi.restrict_subinventories_code, 2),
       Nvl(msi.restrict_locators_code, 2),
       Nvl(msi.location_control_code, 1),
       msi.primary_uom_code,
       Nvl(msi.inspection_required_flag, 'N'),
       Nvl(msi.shelf_life_code, 1),
       Nvl(msi.shelf_life_days,0),
       Nvl(msi.allowed_units_lookup_code, 2),
       Nvl(msi.effectivity_control,1),
       0,
       0,
       Nvl(msi.default_serial_status_id,1),
       Nvl(msi.serial_status_enabled,'N'),
       Nvl(msi.default_lot_status_id,0),
       Nvl(msi.lot_status_enabled,'N'),
       '',
       'N',
       msi.inventory_item_flag,
       0,
       msi.inventory_asset_flag,
       msi.outside_operation_flag
       from mtl_system_items_kfv  msi
           ,mtl_cross_references mcr
       WHERE msi.organization_id = p_Organization_Id
        and ( mcr.cross_reference_type = g_gtin_cross_ref_type
               AND mcr.cross_reference      LIKE g_crossref
            )
        and ( (mcr.org_independent_flag = 'Y') or (mcr.org_independent_flag = 'N'
        and mcr.organization_id = p_organization_id
               ) )
       and mcr.inventory_item_id = msi.inventory_item_id
       and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
       and  exists (SELECT 1 FROM po_requisition_lines_all  prl,
       rcv_shipment_lines rsl  , po_req_distributions_all prd
       WHERE prl.requisition_header_id = p_reqHeaderID
       and rsl.item_id = msi.inventory_item_id
       and prl.requisition_line_id = rsl.requisition_line_id
       and prl.requisition_line_id  = prd.requisition_line_id
       and (p_projectId is null or prd.project_id = p_projectId)
       and (p_taskId is null or prd.task_id = p_taskId)
       ) ;

-- *****************************
--- END  OF REQ HEADER  ID SECTION
-- *****************************

end if;   --- End of doc Entered transaction

else

-- *****************************
---- Case for Document Info is not  entered in the session , i.e transaction starts with Item
-- *****************************
       open x_items for
       select concatenated_segments,
       inventory_item_id,
       description,
       Nvl(revision_qty_control_code,1),
       Nvl(lot_control_code, 1),
       Nvl(serial_number_control_code, 1),
       Nvl(restrict_subinventories_code, 2),
       Nvl(restrict_locators_code, 2),
       Nvl(location_control_code, 1),
       primary_uom_code,
       Nvl(inspection_required_flag, 'N'),
       Nvl(shelf_life_code, 1),
       Nvl(shelf_life_days,0),
       Nvl(allowed_units_lookup_code, 2),
       Nvl(effectivity_control,1),
       0,
       0,
       Nvl(default_serial_status_id,1),
       Nvl(serial_status_enabled,'N'),
       Nvl(default_lot_status_id,0),
       Nvl(lot_status_enabled,'N'),
       '',
       'N',
       inventory_item_flag,
       0,
       inventory_asset_flag,
       outside_operation_flag
       from mtl_system_items_kfv
       WHERE organization_id = p_Organization_Id
       and concatenated_segments like p_concatenated_segments
       and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
       UNION
       --- Substitute Item SQL
       select distinct msi.concatenated_segments,
       msi.inventory_item_id,
       msi.description,
       Nvl(msi.revision_qty_control_code,1),
       Nvl(msi.lot_control_code, 1),
       Nvl(msi.serial_number_control_code, 1),
       Nvl(msi.restrict_subinventories_code, 2),
       Nvl(msi.restrict_locators_code,2),
       Nvl(msi.location_control_code,1),
       msi.primary_uom_code,
       Nvl(msi.inspection_required_flag,'N'),
       Nvl(msi.shelf_life_code, 1),
       Nvl(msi.shelf_life_days,0),
        Nvl(msi.allowed_units_lookup_code, 2),
       Nvl(msi.effectivity_control,1),
       0,
       0,
       Nvl(msi.default_serial_status_id,1),
       Nvl(msi.serial_status_enabled,'N'),
       Nvl(msi.default_lot_status_id,0),
       Nvl(msi.lot_status_enabled,'N'),
       '',
      'N',
       msi.inventory_item_flag,
       0,
       msi.inventory_asset_flag,
       msi.outside_operation_flag
       from po_lines_all pol
       ,mtl_related_items mri
       ,mtl_system_items_kfv msi
       ,mtl_system_items_kfv msia
       where msi.organization_id = p_organization_id
       and msi.concatenated_segments like  p_concatenated_segments
       and pol.item_id = msia.inventory_item_id
       and msia.organization_id = p_organization_id
       and ((mri.related_item_id = msi.inventory_item_id
       and pol.item_id = mri.inventory_item_id) or
       (mri.inventory_item_id = msi.inventory_item_id
       and pol.item_id = mri.related_item_id
       and mri.reciprocal_flag = 'Y'))
       and exists ( select 1 from  po_line_locations_all pll
       where
       -- pll.closed_code = 'OPEN' -- Bug 2859355
          Nvl(pll.closed_code,'OPEN') NOT IN ('CLOSED','FINALLY CLOSED','CLOSED FOR RECEIVING')
       and Nvl(pll.allow_substitute_receipts_flag, 'N') = 'Y'
       and pll.po_header_id = pol.po_header_id
        and Nvl(pll.ship_to_organization_id, p_organization_id) = p_organization_id
       and pll.po_line_id = pol.po_line_id
         AND Nvl(pll.cancel_flag,'N') = 'N'
       and pll.receiving_routing_id = 3)
       UNION ALL
       ---- Vendor Item SQL
       select distinct pol.vendor_product_num,
       msi.inventory_item_id,
       msi.description,
       Nvl(msi.revision_qty_control_code,1),
       Nvl(msi.lot_control_code, 1),
       Nvl(msi.serial_number_control_code, 1),
       Nvl(msi.restrict_subinventories_code, 2),
       Nvl(msi.restrict_locators_code,2),
       Nvl(msi.location_control_code,1),
       msi.primary_uom_code,
       Nvl(msi.inspection_required_flag,'N'),
       Nvl(msi.shelf_life_code, 1),
       Nvl(msi.shelf_life_days,0),
       Nvl(msi.allowed_units_lookup_code, 2),
       Nvl(msi.effectivity_control,1),
       0,
       0,
       Nvl(msi.default_serial_status_id,1),
       Nvl(msi.serial_status_enabled,'N'),
       Nvl(msi.default_lot_status_id,0),
       Nvl(msi.lot_status_enabled,'N'),
       msi.concatenated_segments,
       'Y',
       msi.inventory_item_flag,
       0,
       msi.inventory_asset_flag,
       msi.outside_operation_flag
       from po_lines_all pol
       ,mtl_system_items_kfv msi
       where organization_id = p_organization_id
       and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
       and pol.vendor_product_num like p_concatenated_segments
       and pol.item_id = msi.inventory_item_id
       AND pol.vendor_product_num IS NOT NULL
       UNION ALL
       --- Cross Ref SQL
       ---select distinct mcr.cross_reference,
        select distinct msi.concatenated_segments,
       msi.inventory_item_id,
       msi.description,
        Nvl(msi.revision_qty_control_code,1),
       Nvl(msi.lot_control_code, 1),
       Nvl(msi.serial_number_control_code, 1),
       Nvl(msi.restrict_subinventories_code, 2),
       Nvl(msi.restrict_locators_code,2),
       Nvl(msi.location_control_code,1),
       msi.primary_uom_code,
       Nvl(msi.inspection_required_flag,'N'),
       Nvl(msi.shelf_life_code, 1),
       Nvl(msi.shelf_life_days,0),
       Nvl(msi.allowed_units_lookup_code, 2),
       Nvl(msi.effectivity_control,1),
       0,
       0,
       Nvl(msi.default_serial_status_id,1),
       Nvl(msi.serial_status_enabled,'N'),
       Nvl(msi.default_lot_status_id,0),
       Nvl(msi.lot_status_enabled,'N'),
      --- msi.concatenated_segments,
       mcr.cross_reference,
       'C',
       msi.inventory_item_flag,
       0,
       msi.inventory_asset_flag,
       msi.outside_operation_flag
       from
       mtl_system_items_kfv msi
       ,mtl_cross_references mcr
       where msi.organization_id = p_organization_id
        and ( (mcr.cross_reference_type = p_crossreftype
               and mcr.cross_reference like  p_concatenated_segments
              ) or
              ( mcr.cross_reference_type = g_gtin_cross_ref_type
               AND mcr.cross_reference      LIKE g_crossref )
            )
        and ( (mcr.org_independent_flag = 'Y') or (mcr.org_independent_flag = 'N'
        and mcr.organization_id = p_organization_id
               ) )
       and mcr.inventory_item_id = msi.inventory_item_id
       and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
       UNION ALL
       -- Non Item Master
       select distinct pol.item_description,
       to_number(''),
       pol.item_description,
       1,
       1,
       1,
       2,
       2,
       1,
       mum.uom_code,
       'N',
       1,
       0,
       2,
       1,
       0,
       0,
        1,
       'N',
       0,
       'N',
       '',
       'N',
       'N',
       0,
       to_char(NULL),
       'N'
       from po_lines_all pol
       ,mtl_units_of_measure mum
        -- Bug 2619063, 2614016
        -- Modified to select the base uom for the uom class defined on po.
       where mum.uom_class = (SELECT mum2.uom_class
                                FROM mtl_units_of_measure mum2
                               WHERE mum2.unit_of_measure(+) = pol.unit_meas_lookup_code)
       and mum.base_uom_flag = 'Y'
       and pol.ITEM_ID is null
       and pol.item_description is not null
       and pol.item_description like p_concatenated_segments
 ;
end if;

END GET_ITEM_LOV_RECEIVING ;

PROCEDURE GET_COUNTRY_LOV
  (x_country_lov OUT NOCOPY t_genref,
   p_country IN VARCHAR2 )
IS
BEGIN
  OPEN x_country_lov FOR
       SELECT  territory_code, territory_short_name
         FROM  fnd_territories_vl
        WHERE  territory_code LIKE p_country || '%'
     ORDER BY  territory_code;
END GET_COUNTRY_LOV;


  PROCEDURE Get_Sub_Lov_RcV(x_sub OUT NOCOPY t_genref,
                            p_organization_id IN NUMBER,
                            p_item_id IN NUMBER,
                            p_sub IN VARCHAR2,
                            p_restrict_subinventories_code IN NUMBER,
                            p_transaction_type_id IN NUMBER,
                            p_wms_installed IN VARCHAR2) IS

  BEGIN
    IF (p_item_id IS NULL
        OR p_restrict_subinventories_code <> 1
       ) THEN
      OPEN x_sub FOR
        SELECT   msub.secondary_inventory_name
               , NVL(msub.locator_type, 1)
               , msub.description
               , msub.asset_inventory
               , lpn_controlled_flag
            FROM mtl_secondary_inventories msub
           WHERE msub.organization_id = p_organization_id
             AND NVL(msub.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
             AND msub.secondary_inventory_name LIKE (p_sub)
             AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL,
p_transaction_type_id, NULL, NULL, p_organization_id, p_item_id,
 msub.secondary_inventory_name, NULL, NULL, NULL, 'Z') = 'Y'
        ORDER BY UPPER(msub.secondary_inventory_name);
    ELSE
      -- It is a restricted item,
      OPEN x_sub FOR
        SELECT   msub.secondary_inventory_name
               , NVL(msub.locator_type, 1)
               , msub.description
               , msub.asset_inventory
               , lpn_controlled_flag
            FROM mtl_secondary_inventories msub
           WHERE msub.organization_id = p_organization_id
             AND NVL(msub.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
             AND msub.secondary_inventory_name LIKE (p_sub)
             AND EXISTS( SELECT NULL
                           FROM mtl_item_sub_inventories mis
                          WHERE mis.organization_id = NVL(p_organization_id,
mis.organization_id)

                            AND mis.inventory_item_id = p_item_id
                            AND mis.secondary_inventory = msub.secondary_inventory_name)
             AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL,
p_transaction_type_id, NULL, NULL, p_organization_id, p_item_id,
msub.secondary_inventory_name, NULL, NULL, NULL, 'Z') = 'Y'
        ORDER BY UPPER(msub.secondary_inventory_name);
    END IF;
  END get_sub_lov_rcv;


PROCEDURE Calculate_Secondary_Qty(
  p_item_no			IN  VARCHAR2
, p_unit_of_measure 		IN  VARCHAR2
, p_quantity			IN  NUMBER
, p_lot_no			IN  VARCHAR2
, p_sublot_no			IN  VARCHAR2
, p_secondary_unit_of_measure 	IN  VARCHAR2
, x_secondary_quantity   	OUT NOCOPY	NUMBER
)

IS

l_opm_um_code	       	 VARCHAR2(25);
l_passed_opm_sec_um_code VARCHAR2(25);
l_opm_item_id 	NUMBER;
l_opm_dualum_ind   	 NUMBER;
l_opm_secondary_um       VARCHAR2(25);
l_lot_id               NUMBER;

v_ret_val		 NUMBER;

Cursor Cr_get_opm_attr IS
Select ilm.item_id,
       ilm.dualum_ind,
       ilm.item_um2
From   ic_item_mst ilm
Where  ilm.item_no = p_item_no;

CURSOR Get_Lot_Id (p_item_id NUMBER) IS
SELECT lot_id
FROM ic_lots_mst
WHERE item_id = p_item_id AND
      lot_no = p_lot_no;

CURSOR Get_LotSubLot_Id (p_item_id NUMBER) IS
SELECT lot_id
FROM ic_lots_mst
WHERE item_id = p_item_id AND
      lot_no = p_lot_no AND
      sublot_no = p_sublot_no;
BEGIN

  IF p_secondary_unit_of_measure IS NULL OR p_item_no IS NULL
  THEN
     RETURN;
  ELSE
     --Get opm attributes for the item.
     Open  Cr_get_opm_attr;
     Fetch Cr_get_opm_attr Into l_opm_item_id, l_opm_dualum_ind, l_opm_secondary_um;

     IF (Cr_get_opm_attr%NOTFOUND) THEN
       --item not an opm item do nothing just return
        CLOSE Cr_get_opm_attr;
       RETURN;
     END IF;
     CLOSE Cr_get_opm_attr;

     --if item is not dualum control then return doing nothing.
     IF l_opm_dualum_ind = 0 THEN
         RETURN;
     END IF;

     --Get opm uom code for the passed apps unit of measure.
     IF p_unit_of_measure IS NOT NULL THEN
        BEGIN

           l_opm_um_code := po_gml_db_common.get_opm_uom_code(p_unit_of_measure);

        EXCEPTION WHEN OTHERS THEN
          RETURN;
        END;
     ELSE
        RETURN;
     END IF;

     IF p_lot_no IS NULL OR p_lot_no = '' THEN
        l_lot_id := 0;
     ELSIF p_sublot_no IS NULL OR p_sublot_no = '' THEN

       Open  Get_Lot_Id (l_opm_item_id);
       Fetch Get_Lot_Id Into l_lot_id;

       IF (Get_Lot_Id%NOTFOUND) THEN
         l_lot_id := 0;
       END IF;

       CLOSE Get_Lot_Id;

     ELSE
       Open  Get_LotSubLot_Id (l_opm_item_id);
       Fetch Get_LotSubLot_Id Into l_lot_id;

       IF (Get_LotSubLot_Id%NOTFOUND) THEN
         l_lot_id := 0;
       END IF;

       CLOSE Get_LotSubLot_Id;
     END IF;

     GMICUOM.icuomcv ( l_opm_item_id,
                       l_lot_id,
                       p_quantity,
                       l_opm_um_code,
                       l_opm_secondary_um,
                       x_secondary_quantity );

  END IF;


EXCEPTION
  WHEN OTHERS THEN
    NULL;

END Calculate_Secondary_Qty;



  -- This returns the locator id for an existing locator and if
  -- it does not exist then it creates a new one.
  PROCEDURE get_dynamic_locator(x_location_id OUT NOCOPY NUMBER,
                                x_description OUT NOCOPY VARCHAR2,
                                x_result OUT NOCOPY VARCHAR2,
                                x_exist_or_create OUT NOCOPY VARCHAR2,
                                p_org_id IN NUMBER,
                                p_sub_code IN VARCHAR2,
                                p_concat_segs IN VARCHAR2)
IS

    l_keystat_val        BOOLEAN;
    l_sub_default_status NUMBER;
    l_validity_check     VARCHAR2(10);
    l_wms_org            BOOLEAN;
    l_loc_type           NUMBER;
    l_return_status      VARCHAR2(10);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(20);
    l_label_status       VARCHAR2(20);
    l_status_rec         inv_material_status_pub.mtl_status_update_rec_type;

  BEGIN
    x_result          := 'S';
    l_validity_check  := 'passed';

    BEGIN
      SELECT inventory_location_id
           , description
        INTO x_location_id
           , x_description
        FROM mtl_item_locations_kfv
       WHERE organization_id = p_org_id
         AND subinventory_code = p_sub_code
         AND concatenated_segments = p_concat_segs
         AND ROWNUM < 2;

      x_exist_or_create  := 'EXISTS';
      RETURN;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_keystat_val  :=
            fnd_flex_keyval.validate_segs(operation => 'CREATE_COMB_NO_AT',
            appl_short_name => 'INV', key_flex_code => 'MTLL', structure_number => 101,
            concat_segments => p_concat_segs, values_or_ids => 'V', data_set => p_org_id);


        IF (l_keystat_val = FALSE) THEN
--dbms_output.put_line('ERROR 1');
          x_result           := 'E';
          x_exist_or_create  := '';
          RETURN;
        ELSE
          x_location_id      := fnd_flex_keyval.combination_id;

          x_exist_or_create  := 'EXISTS';

          IF fnd_flex_keyval.new_combination THEN
            x_exist_or_create  := 'CREATE';

            IF p_sub_code IS NOT NULL THEN
              BEGIN
                ---  check validity
                SELECT 'failed'
                  INTO l_validity_check
                  FROM DUAL

                 WHERE EXISTS( SELECT subinventory_code
                                 FROM mtl_item_locations_kfv
                                WHERE concatenated_segments = p_concat_segs
                                  AND p_sub_code <> subinventory_code
                                  AND organization_id = p_org_id);
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  NULL;
              END;

              IF l_validity_check = 'failed' THEN
                x_result           := 'E';
                x_exist_or_create  := '';
                RETURN;
              END IF;

              SELECT NVL(default_loc_status_id, 1)
                INTO l_sub_default_status
                FROM mtl_secondary_inventories
               WHERE organization_id = p_org_id
                 AND secondary_inventory_name = p_sub_code;


              l_loc_type  := NULL;

              UPDATE mtl_item_locations
                 SET subinventory_code = p_sub_code
                   , status_id = l_sub_default_status
                   , inventory_location_type = l_loc_type
               WHERE organization_id = p_org_id
                 AND inventory_location_id = x_location_id;
            END IF;
          ELSE
            BEGIN
              ---  check validity
              SELECT 'failed'
                INTO l_validity_check
                FROM DUAL
               WHERE EXISTS( SELECT subinventory_code
                               FROM mtl_item_locations_kfv
                              WHERE concatenated_segments = p_concat_segs
                                AND p_sub_code <> subinventory_code
                                AND organization_id = p_org_id);
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                NULL;
            END;

            IF l_validity_check = 'failed' THEN
              x_result           := 'E';
              x_exist_or_create  := '';
              RETURN;
            END IF;
          END IF;

          IF x_exist_or_create = 'CREATE' THEN
            -- If a new locator is created then create a status history for it,
           -- bug# 1695432

            l_status_rec.organization_id        := p_org_id;
            l_status_rec.inventory_item_id      := NULL;
            l_status_rec.lot_number             := NULL;
            l_status_rec.serial_number          := NULL;
            l_status_rec.update_method          := inv_material_status_pub.g_update_method_manual;

            l_status_rec.status_id              := l_sub_default_status;
            l_status_rec.zone_code              := p_sub_code;
            l_status_rec.locator_id             := x_location_id;
            l_status_rec.creation_date          := SYSDATE;
            l_status_rec.created_by             := fnd_global.user_id;
            l_status_rec.last_update_date       := SYSDATE;
            l_status_rec.last_update_login      := fnd_global.user_id;
            l_status_rec.initial_status_flag    := 'Y';
            l_status_rec.from_mobile_apps_flag  := 'Y';
            inv_material_status_pkg.insert_status_history(l_status_rec);
            -- Do we need this for OPM ??
            -- If a new locator is created, call label printing API

            inv_label.print_label_manual_wrap(
              x_return_status              => l_return_status
            , x_msg_count                  => l_msg_count
            , x_msg_data                   => l_msg_data
            , x_label_status               => l_label_status
            , p_business_flow_code         => 24
            , p_organization_id            => p_org_id
            , p_subinventory_code          => p_sub_code
            , p_locator_id                 => x_location_id
            );
          END IF;
        END IF;
    END;
  END Get_Dynamic_Locator;



  PROCEDURE get_prj_loc_lov(
    x_locators               OUT    NOCOPY t_genref
  , p_organization_id        IN     NUMBER
  , p_subinventory_code      IN     VARCHAR2
  , p_restrict_locators_code IN     NUMBER
  , p_inventory_item_id      IN     NUMBER
  , p_concatenated_segments  IN     VARCHAR2
  , p_transaction_type_id    IN     NUMBER
  , p_wms_installed          IN     VARCHAR2
  , p_project_id             IN     NUMBER
  , p_task_id                IN     NUMBER
  ) IS
    x_return_status VARCHAR2(100);
    x_display       VARCHAR2(100);
    x_project_col   NUMBER;
    x_task_col      NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

BEGIN


  IF p_concatenated_segments IS NOT NULL THEN
       IF p_Restrict_Locators_Code = 1  THEN --Locators restricted to predefined list

        OPEN x_Locators FOR
          select a.inventory_location_id,
                 INV_PROJECT.GET_LOCSEGS(a.concatenated_segments),
                 nvl( a.description, -1)
          FROM mtl_item_locations_kfv a,mtl_secondary_locators b, ic_loct_mst l
          WHERE b.organization_id = p_Organization_Id
          AND  b.inventory_item_id = p_Inventory_Item_Id
          AND  a.inventory_location_id = l.inventory_location_id
          AND nvl(a.disable_date, trunc(sysdate+1)) > trunc(sysdate)
          AND  b.subinventory_code = p_Subinventory_Code
          AND a.inventory_location_id = b.secondary_locator
          AND a.concatenated_segments LIKE (p_concatenated_segments||'%')
       /* BUG#2810405: To show only common locators in the LOV */
/*
          AND inv_material_status_grp.is_status_applicable
             ( p_wms_installed,
               NULL,
               p_transaction_type_id,
               NULL,
               NULL,
               p_Organization_Id,
               p_Inventory_Item_Id,
               p_Subinventory_Code,
               a.inventory_location_id,
               NULL,
               NULL,
               'L') = 'Y'
*/
           ORDER BY 2;

       ELSE --Locators not restricted

        OPEN x_Locators FOR
          select a.inventory_location_id,
                 INV_PROJECT.GET_LOCSEGS(concatenated_segments),
                 description
          FROM mtl_item_locations_kfv a, ic_loct_mst l
          WHERE organization_id = p_Organization_Id
          AND subinventory_code = p_Subinventory_Code
          AND  a.inventory_location_id = l.inventory_location_id
          AND nvl(disable_date, trunc(sysdate+1)) > trunc(sysdate)
          AND concatenated_segments LIKE (p_concatenated_segments||'%' )
       /* BUG#2810405: To show only common locators in the LOV */
/*
          AND inv_material_status_grp.is_status_applicable
             ( p_wms_installed,
               NULL,
               p_transaction_type_id,
               NULL,
               NULL,
               p_Organization_Id,
               p_Inventory_Item_Id,
               p_Subinventory_Code,
               inventory_location_id,
               NULL,
               NULL,
               'L') = 'Y'
*/
         ORDER BY 2;
       END IF;
    ELSE /*Non PJM Org concatenated segments null*/
       IF p_Restrict_Locators_Code = 1  THEN --Locators restricted to predefined list

        OPEN x_Locators FOR
          select a.inventory_location_id,
                 INV_PROJECT.GET_LOCSEGS(a.concatenated_segments),
                 nvl( a.description, -1)
          FROM mtl_item_locations_kfv a,mtl_secondary_locators b, ic_loct_mst l
          WHERE b.organization_id = p_Organization_Id
          AND  b.inventory_item_id = p_Inventory_Item_Id
          AND  a.inventory_location_id = l.inventory_location_id
          AND nvl(a.disable_date, trunc(sysdate+1)) > trunc(sysdate)
          AND  b.subinventory_code = p_Subinventory_Code
          AND a.inventory_location_id = b.secondary_locator
          /* BUG#2810405: To show only common locators in the LOV */
/*
          AND inv_material_status_grp.is_status_applicable
             ( p_wms_installed,
               NULL,
               p_transaction_type_id,
               NULL,
               NULL,
               p_Organization_Id,
               p_Inventory_Item_Id,
               p_Subinventory_Code,
               a.inventory_location_id,
               NULL,
               NULL,
               'L') = 'Y'
*/
           ORDER BY 2;

       ELSE --Locators not restricted
        OPEN x_Locators FOR
          select a.inventory_location_id,
                 INV_PROJECT.GET_LOCSEGS(concatenated_segments),
                 description
          FROM mtl_item_locations_kfv a, ic_loct_mst l
          WHERE organization_id = p_Organization_Id
          AND subinventory_code = p_Subinventory_Code
          AND  a.inventory_location_id = l.inventory_location_id
          AND nvl(disable_date, trunc(sysdate+1)) > trunc(sysdate)
          /* BUG#2810405: To show only common locators in the LOV */
/*
          AND inv_material_status_grp.is_status_applicable
             ( p_wms_installed,
               NULL,
               p_transaction_type_id,
               NULL,
               NULL,
               p_Organization_Id,
               p_Inventory_Item_Id,
               p_Subinventory_Code,
               inventory_location_id,
               NULL,
               NULL,
               'L') = 'Y'
*/
         ORDER BY 2;
       END IF;
    END IF;

END get_prj_loc_lov;

END GML_MOBILE_RECEIPT;

/
