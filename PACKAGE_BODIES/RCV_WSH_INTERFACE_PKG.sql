--------------------------------------------------------
--  DDL for Package Body RCV_WSH_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_WSH_INTERFACE_PKG" AS
/* $Header: RCVWSHIB.pls 120.0.12010000.20 2013/02/27 13:24:24 honwei noship $*/

/*===========================================================================

                     Private procedures and functions

===========================================================================*/
  FUNCTION get_uom_from_code
    (   p_uom_code          IN   VARCHAR2 )
  RETURN VARCHAR2 IS
  l_unit_of_measure  mtl_units_of_measure.unit_of_measure%TYPE;
  BEGIN

      IF (p_uom_code IS NULL) THEN
          RETURN NULL;
      END IF;

      SELECT unit_of_measure
      INTO   l_unit_of_measure
      FROM   mtl_units_of_measure
      WHERE  uom_code = p_uom_code;

      RETURN l_unit_of_measure;
  EXCEPTION
    WHEN OTHERS THEN
       IF (g_asn_debug = 'Y') THEN
             asn_debug.put_line('Unexpected exception in get_uom_from_code : ' || SQLERRM);
       END IF;
     raise fnd_api.g_exc_unexpected_error;
  END get_uom_from_code;

  --RTV2 rtv project phase 2 : start
  -- Get_return_lpn_id() function should not be used to fetch lpn_id after cancellation
  -- as wsh_delivery_assignments.parent_delivery_detail_id is cleared after cancellation.
  FUNCTION get_return_lpn_id
    (   p_wdd_id          IN   NUMBER)
  RETURN NUMBER IS
  l_lpn_id number;
  BEGIN

      IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('p_wdd_id : ' || p_wdd_id);
      END IF;
      IF (p_wdd_id IS NULL) THEN
          RETURN NULL;
      END IF;

      SELECT  wdd.lpn_id
      into    l_lpn_id
      FROM    wsh_delivery_Details wdd, wsh_delivery_assignments wda
      WHERE   wdd.delivery_detail_id(+) = wda.parent_delivery_detail_id
      AND     wda.delivery_detail_id = p_wdd_id;

      IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('l_lpn_id : ' || l_lpn_id);
      END IF;
      RETURN l_lpn_id;
  EXCEPTION
    WHEN OTHERS THEN
       IF (g_asn_debug = 'Y') THEN
             asn_debug.put_line('Unexpected exception in get_return_lpn_id : ' || SQLERRM);
       END IF;
       raise fnd_api.g_exc_unexpected_error;
  END get_return_lpn_id;

  PROCEDURE unmark_wdd_lpn(p_wdd_rec           IN   wsh_delivery_details%rowtype,
                           p_lpn_id            IN   NUMBER DEFAULT NULL,
                           x_return_status     OUT  NOCOPY VARCHAR2,
                           x_msg_count         OUT  NOCOPY NUMBER,
                           x_msg_data          OUT  NOCOPY VARCHAR2) IS
  l_lpn_id                          NUMBER := NULL;
  l_message                         VARCHAR2(2000);
  BEGIN

      IF (p_lpn_id IS NOT NULL) THEN
      	  l_lpn_id := p_lpn_id;
      END IF;

      IF (l_lpn_id IS NULL) THEN
          RETURN;
      END IF;

      wms_return_sv.unmark_returns
         (x_return_status        => x_return_status,
          x_msg_count            => x_msg_count,
          x_msg_data             => x_msg_data,
          p_rcv_trx_interface_id => p_wdd_rec.source_line_id,
          p_ret_transaction_type => 'RETURN TO VENDOR',
          p_lpn_id               => l_lpn_id,
          p_item_id              => p_wdd_rec.inventory_item_id,
          p_item_revision        => p_wdd_rec.revision,
          p_org_id               => p_wdd_rec.organization_id,
          p_lot_number           => p_wdd_rec.lot_number);

       IF (nvl(x_msg_count,0) = 0) THEN
           asn_debug.put_line('unmark lpn successfully');
       ELSE
           asn_debug.put_line(' Could not unmark lpn      :  ----> ' || l_lpn_id);
           asn_debug.put_line(' Could not unmark for item :  ----> ' || p_wdd_rec.inventory_item_id);
           FOR i IN 1..x_msg_count LOOP
               l_message := fnd_msg_pub.get(I, 'F');
               asn_debug.put_line(substr(l_message,1,255));
           end LOOP;
       END IF;

  EXCEPTION
    WHEN OTHERS THEN
       IF (g_asn_debug = 'Y') THEN
             asn_debug.put_line('Unexpected exception in unmark_wdd_lpn with lpn_id : '||l_lpn_id||', SQLERRM:' || SQLERRM);
       END IF;
       raise fnd_api.g_exc_unexpected_error;
  END unmark_wdd_lpn;

  PROCEDURE remove_RTV_order
    (   p_bkup_rti_id          IN   NUMBER) IS
  BEGIN
       DELETE FROM rcv_transactions_interface
       WHERE  interface_transaction_id = p_bkup_rti_id;
       IF (g_asn_debug = 'Y') THEN
           asn_debug.put_line('DELETED RTI');
       END IF;
       --
       BEGIN
          DELETE FROM rcv_lots_interface
          WHERE  interface_transaction_id = p_bkup_rti_id;

          IF (g_asn_debug = 'Y') THEN
              asn_debug.put_line('DELETED RLI');
          END IF;
       EXCEPTION
          WHEN OTHERS THEN NULL;
       END;
       --
       BEGIN
          DELETE FROM rcv_serials_interface
          WHERE  interface_transaction_id = p_bkup_rti_id;

          IF (g_asn_debug = 'Y') THEN
              asn_debug.put_line('DELETED RSI');
          END IF;
       EXCEPTION
          WHEN OTHERS THEN NULL;
       END;
       --
       BEGIN
          DELETE FROM mtl_transaction_lots_temp
          WHERE  product_transaction_id = p_bkup_rti_id;

          IF (g_asn_debug = 'Y') THEN
              asn_debug.put_line('DELETED MTLT');
          END IF;
       EXCEPTION
          WHEN OTHERS THEN NULL;
       END;
       --
       BEGIN
          DELETE FROM mtl_serial_numbers_temp
          WHERE  product_transaction_id = p_bkup_rti_id;

          IF (g_asn_debug = 'Y') THEN
              asn_debug.put_line('DELETED MSNT');
          END IF;
       EXCEPTION
          WHEN OTHERS THEN NULL;
       END;

       --
  EXCEPTION
    WHEN OTHERS THEN
       IF (g_asn_debug = 'Y') THEN
             asn_debug.put_line('Unexpected exception in remove_RTV_order : ' || SQLERRM);
       END IF;
       raise fnd_api.g_exc_unexpected_error;
  END remove_RTV_order;
  --RTV2 rtv project phase 2 : end

  --
  PROCEDURE create_return_reservation
  (  p_wdd_rec           IN          WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type,
     p_lpn_id            IN          NUMBER,      ---- RTV2 rtv project phase 2
     x_return_status     OUT  NOCOPY VARCHAR2,    ---- RTV2 rtv project phase 2
     x_msg_count         OUT  NOCOPY NUMBER,      ---- RTV2 rtv project phase 2
     x_msg_data          OUT  NOCOPY VARCHAR2) IS ---- RTV2 rtv project phase 2

  l_rsv_rec                         INV_Reservation_GLOBAL.MTL_RESERVATION_REC_TYPE := NULL;
  l_api_version                     CONSTANT NUMBER := 1.0;
  l_api_name                        CONSTANT VARCHAR2(30) := 'Process_Line';
  l_dummy_sn                        INV_Reservation_Global.Serial_Number_Tbl_Type;
  --l_api_return_status               VARCHAR2(1);
  --l_msg_count                       NUMBER;
  --l_msg_data                        VARCHAR2(2000);
  l_message                         VARCHAR2(2000);
  l_qty_succ_reserved               NUMBER;
  l_org_wide_res_id                 NUMBER;
  x_no_violation                    BOOLEAN;--RTV2 rtv project phase 2

  BEGIN
       l_rsv_rec.demand_source_type_id := 13;
       l_rsv_rec.supply_source_type_id := 13;
       l_rsv_rec.organization_id       := p_wdd_rec.organization_id;
       l_rsv_rec.inventory_item_id     := p_wdd_rec.inventory_item_id;
       l_rsv_rec.demand_source_name    := p_wdd_rec.source_header_number;
       l_rsv_rec.reservation_quantity  := p_wdd_rec.src_requested_quantity;
       l_rsv_rec.reservation_uom_code  := p_wdd_rec.src_requested_quantity_uom;
       l_rsv_rec.revision              := p_wdd_rec.revision;
       l_rsv_rec.subinventory_code     := p_wdd_rec.subinventory;
       l_rsv_rec.locator_id            := p_wdd_rec.locator_id;
       l_rsv_rec.lot_number            := p_wdd_rec.lot_number;
       l_rsv_rec.detailed_quantity     := 0;
       l_rsv_rec.requirement_date      := sysdate;
       --Bug# 10090672
       l_rsv_rec.ship_ready_flag       := 1;
       l_rsv_rec.staged_flag           := 'Y';
       --RTV2 rtv project phase 2 : start
       l_rsv_rec.lpn_id                := p_lpn_id;
       IF (g_asn_debug = 'Y') THEN
           asn_debug.put_line('In create_return_reservation,p_lpn_id : ' || p_lpn_id);
       END IF;
       --We need to call clear_quantity_cache, as for multiple lines cases
       --if one line fails, the qty tree will be cached with incorrect qty
       inv_quantity_tree_pub.clear_quantity_cache;
       IF (g_asn_debug = 'Y') THEN
           asn_debug.put_line('inv_quantity_tree_pub.clear_quantity_cache ');
       END IF;
       --RTV2 rtv project phase 2 : end

       INV_Reservation_PUB.Create_Reservation
               (
                  p_api_version_number        => 1.0
                , p_init_msg_lst              => fnd_api.G_TRUE
                , x_return_status             => x_return_status --RTV2 rtv project phase 2
                , x_msg_count                 => x_msg_count     --RTV2 rtv project phase 2
                , x_msg_data                  => x_msg_data      --RTV2 rtv project phase 2
                , p_rsv_rec                   => l_rsv_rec
                , p_serial_number             => l_dummy_sn
                , x_serial_number             => l_dummy_sn
                , p_partial_reservation_flag  => fnd_api.g_true
                , p_force_reservation_flag    => fnd_api.g_false
                , p_validation_flag           => fnd_api.g_true
                , x_quantity_reserved         => l_qty_succ_reserved
                , x_reservation_id            => l_org_wide_res_id
                );

       IF (nvl(x_msg_count,0) = 0) THEN
           asn_debug.put_line('Created reservation successfully');--RTV2 rtv project phase 2
       ELSE
           asn_debug.put_line(' Could not reserve for org  :  ----> ' || p_wdd_rec.organization_id);
           asn_debug.put_line(' Could not reserve for item :  ----> ' || p_wdd_rec.inventory_item_id);
           FOR i IN 1..x_msg_count LOOP                          --RTV2 rtv project phase 2
               l_message := fnd_msg_pub.get(I, 'F');
               asn_debug.put_line(substr(l_message,1,255));
           end LOOP;
       END IF;
  EXCEPTION
    WHEN OTHERS THEN
       IF (g_asn_debug = 'Y') THEN
             asn_debug.put_line('Unexpected exception in create_return_reservation : ' || SQLERRM);
       END IF;
       raise fnd_api.g_exc_unexpected_error;
  END create_return_reservation;
  --

  PROCEDURE relieve_return_reservation
  (  p_wdd_rec           IN   WSH_DELIVERY_DETAILS%ROWTYPE,
     p_lpn_id            IN   NUMBER,             ---- RTV2 rtv project phase 2
     x_return_status     OUT  NOCOPY VARCHAR2,    ---- RTV2 rtv project phase 2
     x_msg_count         OUT  NOCOPY NUMBER,      ---- RTV2 rtv project phase 2
     x_msg_data          OUT  NOCOPY VARCHAR2) IS ---- RTV2 rtv project phase 2

    --l_return_status        VARCHAR2(1);
    --l_msg_count            NUMBER;
    --l_msg_data             VARCHAR2(240);
    l_ship_qty             NUMBER;
    l_user_line            VARCHAR2(30);
    l_demand_class         VARCHAR2(30);
    l_mps_flag             NUMBER;
    l_message              VARCHAR2(2000);

  BEGIN

       IF (g_asn_debug = 'Y') THEN
             asn_debug.put_line('Relieving reservation against WDD : ' || p_wdd_rec.delivery_detail_id);
       END IF;

       inv_trx_relief_c_pvt.rsv_relief
          ( x_return_status      => x_return_status,-- RTV2 rtv project phase 2
            x_msg_count          => x_msg_count,    -- RTV2 rtv project phase 2
            x_msg_data           => x_msg_data,     -- RTV2 rtv project phase 2
            x_ship_qty           => l_ship_qty,
            x_userline           => l_user_line,
            x_demand_class       => l_demand_class,
            x_mps_flag           => l_mps_flag,
            p_organization_id    => p_wdd_rec.organization_id,
            p_inventory_item_id  => p_wdd_rec.inventory_item_id,
            p_subinv             => p_wdd_rec.subinventory,
            p_locator            => p_wdd_rec.locator_id,
            p_lotnumber          => p_wdd_rec.lot_number,
            p_revision           => p_wdd_rec.revision,
            p_dsrc_type          => 13,
            p_header_id          => NULL,
            p_dsrc_name          => p_wdd_rec.source_header_number,
            p_dsrc_line          => NULL,
            p_dsrc_delivery      => NULL,
            p_qty_at_puom        => p_wdd_rec.shipped_quantity,
            p_lpn_id             => p_lpn_id);                 -- RTV2 rtv project phase 2

       IF (nvl(x_msg_count,0) = 0) THEN                        -- RTV2 rtv project phase 2
           asn_debug.put_line('Relieved reservation successfully');
       ELSE
           asn_debug.put_line(' Could not relieve reservation for org  :  ----> ' || p_wdd_rec.organization_id);
           asn_debug.put_line(' Could not relieve reservation for item :  ----> ' || p_wdd_rec.inventory_item_id);
           FOR i IN 1..x_msg_count LOOP                        -- RTV2 rtv project phase 2
               l_message := fnd_msg_pub.get(I, 'F');
               asn_debug.put_line(substr(l_message,1,255));
           end LOOP;
       END IF;

  EXCEPTION
    WHEN OTHERS THEN
       IF (g_asn_debug = 'Y') THEN
             asn_debug.put_line('Unexpected exception in relieve_return_reservation : ' || SQLERRM);
       END IF;
       raise fnd_api.g_exc_unexpected_error;
  END relieve_return_reservation;

  -- RTV2 rtv project phase 2 : start
  PROCEDURE relieve_return_reservation
  (  p_wdd_rec   IN       WSH_DELIVERY_DETAILS%ROWTYPE) IS

    l_lpn_id               NUMBER;
    l_return_status        VARCHAR2(1);
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(240);

  BEGIN
       l_lpn_id := get_return_lpn_id(p_wdd_rec.delivery_detail_id);

       relieve_return_reservation(p_wdd_rec          => p_wdd_rec,
                                  p_lpn_id           => l_lpn_id,
                                  x_return_status    => l_return_status,
                                  x_msg_count        => l_msg_count,
                                  x_msg_data         => l_msg_data);

       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           raise fnd_api.g_exc_unexpected_error;
       END IF;
  EXCEPTION
    WHEN OTHERS THEN
       IF (g_asn_debug = 'Y') THEN
             asn_debug.put_line('Unexpected exception in relieve_return_reservation : ' || SQLERRM);
       END IF;
       raise fnd_api.g_exc_unexpected_error;
  END relieve_return_reservation;
  --
  PROCEDURE rollback_rtp_fail( p_wdd_rec   IN wsh_delivery_details%rowtype,
                               p_group_id  IN NUMBER) IS
  l_lpn_id                 NUMBER;
  l_new_rti_id             NUMBER;
  l_new_org_id             NUMBER;
  l_wdd_rec                WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type;
  l_wdd_rec2               wsh_delivery_details%rowtype;
  l_return_status          VARCHAR2(1);
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(2000);
  BEGIN
     SELECT lpn_id,
            interface_transaction_id,
            to_organization_id
     INTO   l_lpn_id,
            l_new_rti_id,
            l_new_org_id
     FROM   rcv_transactions_interface
     WHERE  group_id = p_group_id
     AND    interface_source_line_id = p_wdd_rec.delivery_detail_id;

     --re-create MR
     IF (l_new_org_id = p_wdd_rec.organization_id) THEN
         l_wdd_rec.organization_id             := p_wdd_rec.organization_id;
         l_wdd_rec.inventory_item_id           := p_wdd_rec.inventory_item_id;
         l_wdd_rec.source_header_number        := p_wdd_rec.source_header_number;
         l_wdd_rec.src_requested_quantity      := p_wdd_rec.src_requested_quantity;
         l_wdd_rec.src_requested_quantity_uom  := p_wdd_rec.src_requested_quantity_uom;
         l_wdd_rec.revision                    := p_wdd_rec.revision;
         l_wdd_rec.subinventory                := p_wdd_rec.subinventory;
         l_wdd_rec.locator_id                  := p_wdd_rec.locator_id;
         l_wdd_rec.lot_number                  := p_wdd_rec.lot_number;
         create_return_reservation (p_wdd_rec          => l_wdd_rec,
                                    p_lpn_id           => l_lpn_id,
                                    x_return_status    => l_return_status,
                                    x_msg_count        => l_msg_count,
                                    x_msg_data         => l_msg_data);
         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
             raise fnd_api.g_exc_unexpected_error;
         END IF;
     END IF;

     --unmark against new rti id
     IF (l_lpn_id IS NOT NULL) THEN
         l_wdd_rec2.source_line_id              := l_new_rti_id;
         l_wdd_rec2.organization_id             := l_new_org_id;
         l_wdd_rec2.inventory_item_id           := p_wdd_rec.inventory_item_id;
         l_wdd_rec2.revision                    := p_wdd_rec.revision;
         l_wdd_rec2.lot_number                  := p_wdd_rec.lot_number;
         unmark_wdd_lpn(p_wdd_rec          => l_wdd_rec2,
                        p_lpn_id           => l_lpn_id,
                        x_return_status    => l_return_status,
                        x_msg_count        => l_msg_count,
                        x_msg_data         => l_msg_data);
         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
             raise fnd_api.g_exc_unexpected_error;
         END IF;
     END IF;
  EXCEPTION
     WHEN OTHERS THEN
         IF (g_asn_debug = 'Y') THEN
             asn_debug.put_line('Unexpected exception in rollback_rtp_fail : ' || SQLERRM);
         END IF;
         raise fnd_api.g_exc_unexpected_error;
  END;
  --this procedure is used for RTV in receipt org only.
  PROCEDURE marklpn_rtp_fail( p_group_id  IN NUMBER) IS
  CURSOR    remark_lpns IS
  SELECT    rtv_rti.interface_transaction_id,
            rtv_rti.transaction_type,
            rtv_rti.item_id,
            rtv_rti.item_revision,
            rtv_rti.use_mtl_serial,
            rtv_rti.use_mtl_lot,
            rtv_rti.to_organization_id,
            rtv_rti.from_subinventory,
            rtv_rti.from_locator_id,
            new_rti.transfer_lpn_id,
            new_rti.uom_code,
            sum(new_rti.quantity) quantity
  FROM      rcv_transactions_interface new_rti,
            rcv_transactions_interface rtv_rti,
            wsh_delivery_Details wdd
  WHERE     new_rti.group_id = p_group_id
  AND       new_rti.interface_source_line_id IS NOT NULL
  AND       new_rti.transfer_lpn_id IS NOT NULL
  AND       new_rti.processing_mode_code = 'ONLINE'
  AND       new_rti.interface_source_line_id = wdd.delivery_detail_id
  AND       rtv_rti.interface_transaction_id = wdd.source_line_id
  AND       rtv_rti.group_id = wdd.source_header_id
  AND       rtv_rti.processing_status_code = 'WSH_INTERFACED'
  AND       wdd.source_code = 'RTV'
  AND       wdd.container_flag = 'N'
  GROUP BY  rtv_rti.interface_transaction_id, rtv_rti.transaction_type,new_rti.transfer_lpn_id,
            rtv_rti.item_id,rtv_rti.item_revision,rtv_rti.use_mtl_serial, rtv_rti.use_mtl_lot,
            rtv_rti.to_organization_id, rtv_rti.from_subinventory,rtv_rti.from_locator_id,
            new_rti.uom_code;
  l_return_status                   VARCHAR2(1);
  l_msg_count                       NUMBER;
  l_msg_data                        VARCHAR2(2000);
  l_message                         VARCHAR2(2000);
  BEGIN
  	FOR mark_rec IN remark_lpns LOOP
     	  --re-mark with master rti id
        wms_return_sv.MARK_RETURNS(
                      x_return_status        => l_return_status,
                      x_msg_count            => l_msg_count,
                      x_msg_data             => l_msg_data,
                      p_rcv_trx_interface_id => mark_rec.interface_transaction_id,
                      p_ret_transaction_type => mark_rec.transaction_type,
                      p_lpn_id               => mark_rec.transfer_lpn_id,
                      p_item_id              => mark_rec.item_id,
                      p_item_revision        => mark_rec.item_revision,
                      p_quantity             => mark_rec.quantity,
                      p_uom                  => mark_rec.uom_code,
                      p_serial_controlled    => mark_rec.use_mtl_serial,
                      p_lot_controlled       => mark_rec.use_mtl_lot,
                      p_org_id               => mark_rec.to_organization_id,
                      p_subinventory         => mark_rec.from_subinventory,
                      p_locator_id           => mark_rec.from_locator_id);

         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
             asn_debug.put_line(' Could not remark lpn      :  ----> ' || mark_rec.transfer_lpn_id);
             asn_debug.put_line(' Could not remark for item :  ----> ' || mark_rec.item_id);
             FOR i IN 1..l_msg_count LOOP
                 l_message := fnd_msg_pub.get(i, 'F');
                 asn_debug.put_line(substr(l_message,1,255));
             end LOOP;
             raise fnd_api.g_exc_unexpected_error;
         END IF;
    END LOOP;
  EXCEPTION
     WHEN OTHERS THEN
         IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Unexpected exception in marklpn_rtp_fail : ' || SQLERRM);
         END IF;
         raise fnd_api.g_exc_unexpected_error;
  END;
  -- RTV2 rtv project phase 2 : end
/*===========================================================================

  PROCEDURE NAME:	create_delivery_details()

===========================================================================*/

  PROCEDURE create_delivery_details
    (  p_return_org_id      IN   NUMBER,
       p_interface_txn_id   IN   NUMBER,
       p_use_mtl_lot        IN   NUMBER,
       p_use_mtl_serial     IN   NUMBER,
       p_ship_to            IN   NUMBER,
       p_site_use           IN   NUMBER
    ) IS

  CURSOR lot_cursor IS
  SELECT *
  FROM   mtl_transaction_lots_temp
  WHERE  transaction_temp_id = p_interface_txn_id;

  l_progress                VARCHAR2(3);
  rti_rec                   RCV_TRANSACTIONS_INTERFACE%ROWTYPE;
  l_primary_uom             VARCHAR2(25);
  l_price		    NUMBER;
  l_price_in_fc             NUMBER;
  l_currency	            VARCHAR2(3);
  l_functional_currency	    VARCHAR2(3);
  l_currency_conv_type      VARCHAR2(30);
  l_rate                    NUMBER;
  l_sob_id                  NUMBER;
  l_wdd_tbl                 WSH_GLBL_VAR_STRCT_GRP.delivery_details_Attr_tbl_Type;
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);
  l_IN_rec                  WSH_GLBL_VAR_STRCT_GRP.detailInRecType;
  l_OUT_rec                 WSH_GLBL_VAR_STRCT_GRP.detailOutRecType;
  l_return_status           VARCHAR2(2000);
  l_new_temp_id             NUMBER;
  e_wdd_creation_error      EXCEPTION;
  e_location_error          EXCEPTION;
  e_con_wdd_creation_error  EXCEPTION;  --RTV2 rtv project phase 2
  e_mr_creation_error       EXCEPTION;  --RTV2 rtv project phase 2


  BEGIN

     IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Entering create_delivery_details');
     END IF;

     l_progress := '000';
     SELECT *
     INTO   rti_rec
     FROM   rcv_transactions_interface
     WHERE  interface_transaction_id = p_interface_txn_id;

     l_progress := '010';
     l_IN_rec.caller      := 'WSH_PUB';
     l_IN_rec.action_code := 'CREATE';

     -- Load rti data into wdd table structure
     l_wdd_tbl(1).source_code                 := 'RTV';
     l_wdd_tbl(1).source_header_number        := rti_rec.group_id;
     l_wdd_tbl(1).source_header_id            := rti_rec.group_id;
     l_wdd_tbl(1).source_line_id              := rti_rec.interface_transaction_id;
     l_wdd_tbl(1).po_shipment_line_id         := rti_rec.shipment_line_id;
     l_wdd_tbl(1).inventory_item_id           := rti_rec.item_id;
     l_wdd_tbl(1).item_description            := rti_rec.item_description;
     l_wdd_tbl(1).revision                    := rti_rec.item_revision;
     l_wdd_tbl(1).original_revision           := rti_rec.item_revision;
     l_wdd_tbl(1).src_requested_quantity      := rti_rec.quantity;
     l_wdd_tbl(1).src_requested_quantity_uom  := rti_rec.uom_code;
     l_wdd_tbl(1).src_requested_quantity2     := rti_rec.secondary_quantity;
     l_wdd_tbl(1).src_requested_quantity_uom2 := rti_rec.secondary_uom_code;
     l_wdd_tbl(1).requested_quantity2         := rti_rec.secondary_quantity; --  Bug 12768069
     l_wdd_tbl(1).requested_quantity_uom2     := rti_rec.secondary_uom_code; --  Bug 12768069
     l_wdd_tbl(1).subinventory                := rti_rec.from_subinventory;
     l_wdd_tbl(1).original_subinventory       := rti_rec.from_subinventory;
     l_wdd_tbl(1).locator_id                  := rti_rec.from_locator_id;
     l_wdd_tbl(1).original_locator_id         := rti_rec.from_locator_id;
     l_wdd_tbl(1).date_requested              := rti_rec.transaction_date;
     l_wdd_tbl(1).date_scheduled              := rti_rec.transaction_date;
     l_wdd_tbl(1).created_by                  := rti_rec.created_by;
     l_wdd_tbl(1).creation_date               := rti_rec.creation_date;
     l_wdd_tbl(1).last_update_date            := rti_rec.last_update_date;
     l_wdd_tbl(1).last_update_login           := rti_rec.last_update_login;
     l_wdd_tbl(1).last_updated_by             := rti_rec.last_updated_by;
     l_wdd_tbl(1).consignee_flag              := 'V';
     l_wdd_tbl(1).customer_id                 := rti_rec.vendor_id;
     l_wdd_tbl(1).organization_id             := p_return_org_id;
     l_wdd_tbl(1).org_id                      := rti_rec.org_id;
     l_wdd_tbl(1).released_status             := 'X';
     l_wdd_tbl(1).inv_interfaced_flag         := 'N';
     l_wdd_tbl(1).oe_interfaced_flag          := 'X';
     l_wdd_tbl(1).container_flag              := 'N';
     l_wdd_tbl(1).pickable_flag               := 'N';
     l_wdd_tbl(1).wv_frozen_flag              := 'N';
     l_wdd_tbl(1).ship_to_location_id         := p_ship_to;
     l_wdd_tbl(1).ship_to_site_use_id         := p_site_use;

     l_progress := '020';
     BEGIN
         SELECT substr (nvl(max(to_number(source_line_number)),0.1)+1, 1, instr(nvl(max(to_number(source_line_number)),0.1)+1,'.')-1) || '.1'
         INTO   l_wdd_tbl(1).source_line_number
         FROM   wsh_delivery_details
         WHERE  source_header_number  = to_char(rti_rec.group_id)
         AND    source_code = 'RTV';
     EXCEPTION
        WHEN OTHERS THEN
             l_wdd_tbl(1).source_line_number := '1.1';
     END;

     l_progress := '030';
     SELECT invoice_currency_code
     INTO   l_currency
     FROM   ap_supplier_sites_all
     WHERE  vendor_id      = rti_rec.vendor_id
     AND    vendor_site_id = rti_rec.vendor_site_id;

     l_progress := '040';
     wsh_util_core.get_location_id ('ORG', p_return_org_id, l_wdd_tbl(1).ship_from_location_id, l_return_status);

     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         raise e_location_error;
     END IF;

     l_progress := '050';
     l_return_status := NULL;
     IF (rti_rec.shipment_line_id IS NULL) THEN

         SELECT currency_code, set_of_books_id
         INTO   l_functional_currency, l_sob_id
         FROM   cst_organization_definitions
         WHERE  organization_id = p_return_org_id;

         l_price_in_fc := INV_CYC_LOVS.get_item_cost
                          ( in_org_id     => p_return_org_id,
                            in_item_id    => rti_rec.item_id,
                            in_locator_id => rti_rec.from_locator_id);

         IF (g_asn_debug = 'Y') THEN
             asn_debug.put_line('l_functional_currency : ' || l_functional_currency);
             asn_debug.put_line('l_price_in_fc         : ' || l_price_in_fc);
         END IF;

         IF (l_currency IS NOT NULL AND l_currency <> l_functional_currency) THEN
             l_progress := '055';
             fnd_profile.get('IC_CURRENCY_CONVERSION_TYPE', l_currency_conv_type);

             l_rate := po_core_s.get_conversion_rate
                       ( l_sob_id,
                         l_currency,
                         rti_rec.transaction_date,
                         l_currency_conv_type );

             IF (g_asn_debug = 'Y') THEN
                 asn_debug.put_line('l_currency_conv_type : ' || l_currency_conv_type);
                 asn_debug.put_line('l_rate               : ' || l_rate);
             END IF;

             l_price := l_price_in_fc * l_rate ;

         ELSE
             l_progress := '060';
             l_currency := l_functional_currency;
             l_price    := l_price_in_fc;
         END IF;

     ELSE
         l_progress := '070';
         l_currency := rti_rec.currency_code;

         SELECT NVL (pll.price_override, pol.unit_price)
         INTO   l_price
         FROM   po_line_locations_all pll,
                po_lines_all          pol
         WHERE  pol.po_line_id = pll.po_line_id
         AND    pol.po_line_id = rti_rec.po_line_id
         AND    pll.line_location_id = rti_rec.po_line_location_id;
     END IF;

     l_wdd_tbl(1).currency_code := l_currency;
     l_wdd_tbl(1).unit_price    := l_price;

     IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('currency   : ' || l_wdd_tbl(1).currency_code);
         asn_debug.put_line('unit_price : ' || l_wdd_tbl(1).unit_price);
     END IF;

     l_progress := '080';

       SELECT msi.primary_uom_code,
              msi.primary_unit_of_measure,
              msi.weight_uom_code,
              msi.unit_weight,
              wsh_wv_utils.convert_uom
                          (msi.weight_uom_code,
                           msi.weight_uom_code,
                           (msi.unit_weight *  wsh_wv_utils.convert_uom( rti_rec.uom_code,
                                                                         msi.primary_uom_code,
                                                                         rti_rec.quantity,
                                                                         rti_rec.item_id) ),
                           rti_rec.item_id) WEIGHT,
              msi.volume_uom_code,
              msi.unit_volume,
              wsh_wv_utils.convert_uom
                          (msi.volume_uom_code,
                           msi.volume_uom_code,
                           (msi.unit_volume *  wsh_wv_utils.convert_uom( rti_rec.uom_code,
                                                                         msi.primary_uom_code,
                                                                         rti_rec.quantity,
                                                                         rti_rec.item_id) ),
                           rti_rec.item_id) VOLUME
       INTO   l_wdd_tbl(1).requested_quantity_uom,
              l_primary_uom,
              l_wdd_tbl(1).weight_uom_code,
              l_wdd_tbl(1).unit_weight,
              l_wdd_tbl(1).net_weight,
              l_wdd_tbl(1).volume_uom_code,
              l_wdd_tbl(1).unit_volume,
              l_wdd_tbl(1).volume
       FROM   mtl_system_items  msi
       WHERE  msi.inventory_item_id = rti_rec.item_id
       AND    msi.organization_id   = p_return_org_id;

       l_wdd_tbl(1).gross_weight   := l_wdd_tbl(1).net_weight;

     IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('l_wdd_tbl(1).requested_quantity_uom : ' || l_wdd_tbl(1).requested_quantity_uom);
         asn_debug.put_line('l_wdd_tbl(1).weight_uom_code        : ' || l_wdd_tbl(1).weight_uom_code);
         asn_debug.put_line('l_wdd_tbl(1).unit_weight            : ' || l_wdd_tbl(1).unit_weight);
         asn_debug.put_line('l_wdd_tbl(1).net_weight             : ' || l_wdd_tbl(1).net_weight);
         asn_debug.put_line('l_wdd_tbl(1).gross_weight           : ' || l_wdd_tbl(1).gross_weight);
         asn_debug.put_line('l_wdd_tbl(1).volume_uom_code        : ' || l_wdd_tbl(1).volume_uom_code);
         asn_debug.put_line('l_wdd_tbl(1).unit_volume            : ' || l_wdd_tbl(1).unit_volume);
         asn_debug.put_line('l_wdd_tbl(1).volume                 : ' || l_wdd_tbl(1).volume);
     END IF;

     l_progress := '090';
     IF (p_use_mtl_lot <> 2) THEN
         l_progress := '100';
         l_return_status := NULL;
         l_msg_data      := NULL;
         l_msg_count     := NULL;

         IF (rti_rec.uom_code <> l_wdd_tbl(1).requested_quantity_uom) THEN
             po_uom_s.uom_convert
                  ( from_quantity => rti_rec.quantity,
                    from_uom      => rti_rec.unit_of_measure,
                    item_id       => rti_rec.item_id,
                    to_uom        => l_primary_uom,
                    to_quantity   => l_wdd_tbl(1).requested_quantity);
         ELSE
            l_wdd_tbl(1).requested_quantity := rti_rec.quantity;
         END IF;

         IF (p_use_mtl_serial in (2,5)) THEN
             l_wdd_tbl(1).shipped_quantity := l_wdd_tbl(1).requested_quantity;
             l_wdd_tbl(1).transaction_temp_id := p_interface_txn_id;
         END IF;

         wsh_interface_grp.create_update_delivery_detail
               (  p_api_version_number => 1.0,
                  p_init_msg_list      => FND_API.G_TRUE,
                  p_commit             => NULL,
                  x_return_status      => l_return_status,
                  x_msg_count          => l_msg_count,
                  x_msg_data           => l_msg_data,
                  p_detail_info_tab    => l_wdd_tbl,
                  p_IN_rec             => l_IN_rec,
                  x_OUT_rec            => l_OUT_rec );

         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
             l_progress := '120';
             raise e_wdd_creation_error;
         END IF;

         --RTV2 rtv project phase 2 : start
         --Calling wms api To create container wdd and assignment
         --We need delivery_detail_id to call wms api and create reservation
         l_wdd_tbl(1).delivery_detail_id   := l_OUT_rec.detail_ids(1);
         IF (rti_rec.TRANSFER_LPN_ID IS NOT NULL) THEN

             wms_return_sv.Create_Update_Containers_RTV
               (  x_return_status      => l_return_status,
                  x_msg_count          => l_msg_count,
                  x_msg_data           => l_msg_data,
                  p_interface_txn_id   => rti_rec.interface_transaction_id,
                  p_wdd_table          => l_wdd_tbl);

         END IF;

         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
             l_progress := '130';
             raise e_con_wdd_creation_error;
         END IF;

         l_progress := '150';
         create_return_reservation (p_wdd_rec          => l_wdd_tbl(1),
                                    p_lpn_id           => rti_rec.transfer_lpn_id,
                                    x_return_status    => l_return_status,
                                    x_msg_count        => l_msg_count,
                                    x_msg_data         => l_msg_data);

         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
             l_progress := '160';
             raise e_mr_creation_error;
         END IF;
         l_wdd_tbl(1).delivery_detail_id := NULL;
         --RTV2 rtv project phase 2 : end

     ELSE
         l_progress := '200';
         FOR lot_rec IN lot_cursor LOOP

            l_wdd_tbl(1).lot_number             := lot_rec.lot_number;
            l_wdd_tbl(1).original_lot_number    := lot_rec.lot_number;
            l_wdd_tbl(1).transaction_temp_id    := lot_rec.serial_transaction_temp_id;

            IF (rti_rec.uom_code <> l_wdd_tbl(1).requested_quantity_uom) THEN
                po_uom_s.uom_convert
                     ( from_quantity => lot_rec.transaction_quantity,
                       from_uom      => rti_rec.unit_of_measure,
                       item_id       => rti_rec.item_id,
                       to_uom        => l_primary_uom,
                       to_quantity   => l_wdd_tbl(1).requested_quantity);
            ELSE
                l_wdd_tbl(1).requested_quantity := lot_rec.transaction_quantity;
            END IF;

            IF (p_use_mtl_serial in (2,5)) THEN
                l_wdd_tbl(1).shipped_quantity := l_wdd_tbl(1).requested_quantity;
            END IF;

            wsh_interface_grp.create_update_delivery_detail
               (  p_api_version_number => 1.0,
                  p_init_msg_list      => NULL,
                  p_commit             => NULL,
                  x_return_status      => l_return_status,
                  x_msg_count          => l_msg_count,
                  x_msg_data           => l_msg_data,
                  p_detail_info_tab    => l_wdd_tbl,
                  p_IN_rec             => l_IN_rec,
                  x_OUT_rec            => l_OUT_rec );

            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                l_progress := '250';
                raise e_wdd_creation_error;
            END IF;

            --RTV2 rtv project phase 2 : start
            --Calling wms api To create container wdd and assignment
            --We need delivery_detail_id to call wms api and create reservation
            l_wdd_tbl(1).delivery_detail_id   := l_OUT_rec.detail_ids(1);
            IF (rti_rec.TRANSFER_LPN_ID IS NOT NULL) THEN

                wms_return_sv.Create_Update_Containers_RTV
                 (  x_return_status      => l_return_status,
                    x_msg_count          => l_msg_count,
                    x_msg_data           => l_msg_data,
                    p_interface_txn_id   => rti_rec.interface_transaction_id,
                    p_wdd_table          => l_wdd_tbl);

            END IF;

            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                l_progress := '260';
                raise e_con_wdd_creation_error;
            END IF;

            l_progress := '270';

            create_return_reservation (p_wdd_rec          => l_wdd_tbl(1),
                                       p_lpn_id           => rti_rec.TRANSFER_LPN_ID,
                                       x_return_status    => l_return_status,
                                       x_msg_count        => l_msg_count,
                                       x_msg_data         => l_msg_data);

            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                l_progress := '280';
                raise e_mr_creation_error;
            END IF;
            l_wdd_tbl(1).delivery_detail_id := NULL;
            --RTV2 rtv project phase 2 : end
         END LOOP;

     END IF;

  l_progress := '300';
  IF (g_asn_debug = 'Y') THEN
      asn_debug.put_line('Leaving create_delivery_details');
  END IF;

  EXCEPTION
    WHEN e_location_error THEN
       IF (g_asn_debug = 'Y') THEN
           asn_debug.put_line('e_wsh_loc_error in create_delivery_details : ' || l_progress);
       END IF;

       fnd_msg_pub.count_and_get (p_encoded      => 'T',
                                  p_count        => l_msg_count,
                                  p_data         => l_msg_data
                                  );

       FOR x IN 1 .. l_msg_count LOOP
           l_msg_data := fnd_msg_pub.get (x, 'F');
       END LOOP;

       po_message_s.sql_error('rcv_wsh_interface_pkg.create_delivery_details', l_msg_data, sqlcode);
       raise fnd_api.g_exc_error;

    WHEN e_wdd_creation_error THEN
       IF (g_asn_debug = 'Y') THEN
           asn_debug.put_line('e_wdd_creation_error in create_delivery_details : ' || l_progress);
       END IF;
       l_msg_data := fnd_msg_pub.get (1, 'F');
       po_message_s.sql_error('rcv_wsh_interface_pkg.create_delivery_details', l_msg_data, sqlcode);
       raise fnd_api.g_exc_error;

    --RTV2 rtv project phase 2 : start
    WHEN e_con_wdd_creation_error THEN
       IF (g_asn_debug = 'Y') THEN
           asn_debug.put_line('e_con_wdd_creation_error in create_delivery_details : ' || l_progress);
       END IF;
       fnd_msg_pub.count_and_get (p_encoded      => 'T',
                                  p_count        => l_msg_count,
                                  p_data         => l_msg_data
                                  );

       FOR x IN 1 .. l_msg_count LOOP
           l_msg_data := fnd_msg_pub.get (x, 'F');
       END LOOP;
       po_message_s.sql_error('rcv_wsh_interface_pkg.create_delivery_details', l_msg_data, sqlcode);
       raise fnd_api.g_exc_error;

    WHEN e_mr_creation_error THEN
       IF (g_asn_debug = 'Y') THEN
           asn_debug.put_line('e_mr_creation_error in create_delivery_details : ' || l_progress);
       END IF;
       fnd_msg_pub.count_and_get (p_encoded      => 'T',
                                  p_count        => l_msg_count,
                                  p_data         => l_msg_data
                                  );

       FOR x IN 1 .. l_msg_count LOOP
           l_msg_data := fnd_msg_pub.get (x, 'F');
       END LOOP;
       po_message_s.sql_error('rcv_wsh_interface_pkg.create_delivery_details', l_msg_data, sqlcode);
       raise fnd_api.g_exc_error;
    --RTV2 rtv project phase 2 : end

    WHEN OTHERS THEN
       IF (g_asn_debug = 'Y') THEN
           asn_debug.put_line('Unexpected exception in create_delivery_details : ' || SQLERRM);
           asn_debug.put_line('l_progress : ' || l_progress);
       END IF;
       po_message_s.sql_error('rcv_wsh_interface_pkg.create_delivery_details', 'Unexpected exception', sqlcode);
       raise fnd_api.g_exc_unexpected_error;
  END create_delivery_details;

/*===========================================================================

  PROCEDURE NAME:	interface_to_rcv()

===========================================================================*/

  PROCEDURE interface_to_rcv (p_delivery_id   IN NUMBER, p_return_status  OUT NOCOPY VARCHAR2) IS

  -- Cursor for picking Returns agaist no document
  CURSOR   wdd_cursor_1 IS
  SELECT   wdd.*
  FROM     wsh_delivery_details       wdd,
           wsh_delivery_assignments   wda,
           rcv_transactions_interface rti
  WHERE    wda.delivery_detail_id = wdd.delivery_detail_id
  AND      wda.delivery_id = p_delivery_id
  AND      wdd.source_code = 'RTV'
  AND      wdd.released_status = 'C'
  AND      wdd.inv_interfaced_flag <> 'Y'
  AND      wdd.container_flag = 'N'
  AND      wdd.source_line_id = rti.interface_transaction_id
  AND      rti.processing_status_code = 'WSH_INTERFACED'
  AND      wdd.organization_id = rti.to_organization_id
  AND      rti.shipment_line_id IS NULL
  ORDER BY source_line_id, source_line_number;

  -- Cursor for picking Returns made from the Receipt's org
  CURSOR   wdd_cursor_2 IS
  SELECT   wdd.*
  FROM     wsh_delivery_details       wdd,
           wsh_delivery_assignments   wda,
           rcv_transactions_interface rti
  WHERE    wda.delivery_detail_id = wdd.delivery_detail_id
  AND      wda.delivery_id = p_delivery_id
  AND      wdd.source_code = 'RTV'
  AND      wdd.released_status = 'C'
  AND      wdd.inv_interfaced_flag <> 'Y'
  AND      wdd.container_flag = 'N'
  AND      wdd.source_line_id = rti.interface_transaction_id
  AND      rti.processing_status_code = 'WSH_INTERFACED'
  AND      wdd.organization_id = rti.to_organization_id
  AND      rti.shipment_line_id IS NOT NULL
  AND      NOT EXISTS (SELECT 1 from rcv_transactions rt
                       WHERE  rt.transaction_type = 'RETURN TO VENDOR'
                       AND    rt.interface_source_line_id = wdd.delivery_detail_id)
  ORDER BY source_line_id, source_line_number;

  -- Cursor for picking Returns made from an org different from Receipt's org for Direct org txr
  CURSOR   wdd_cursor_3 IS
  SELECT   wdd.*
  FROM     wsh_delivery_details       wdd,
           wsh_delivery_assignments   wda,
           rcv_transactions_interface rti
  WHERE    wda.delivery_detail_id = wdd.delivery_detail_id
  AND      wda.delivery_id = p_delivery_id
  AND      wdd.source_code = 'RTV'
  AND      wdd.released_status = 'C'
  AND      wdd.inv_interfaced_flag <> 'Y'
  AND      wdd.container_flag = 'N'
  AND      wdd.source_line_id = rti.interface_transaction_id
  AND      rti.processing_status_code = 'WSH_INTERFACED'
  AND      wdd.organization_id <> rti.to_organization_id
  AND      rti.shipment_line_id IS NOT NULL
  AND      NOT EXISTS (SELECT 1
                       FROM   mtl_material_transactions mmt
                       WHERE  mmt.picking_line_id = wdd.delivery_detail_id)
  ORDER BY source_line_id, source_line_number;

  -- Cursor for picking Returns made from an org different from Receipt's org which are pending after DIrect org txr.
  CURSOR   wdd_cursor_4 IS
  SELECT   wdd.*
  FROM     wsh_delivery_details       wdd,
           wsh_delivery_assignments   wda,
           rcv_transactions_interface rti
  WHERE    wda.delivery_detail_id = wdd.delivery_detail_id
  AND      wda.delivery_id = p_delivery_id
  AND      wdd.source_code = 'RTV'
  AND      wdd.released_status = 'C'
  AND      wdd.inv_interfaced_flag <> 'Y'
  AND      wdd.container_flag = 'N'
  AND      wdd.source_line_id = rti.interface_transaction_id
  AND      rti.processing_status_code = 'WSH_INTERFACED'
  AND      wdd.organization_id <> rti.to_organization_id
  AND      rti.shipment_line_id IS NOT NULL
  AND      EXISTS (SELECT 1
                   FROM   mtl_material_transactions mmt
                   WHERE  mmt.picking_line_id = wdd.delivery_detail_id)
  AND      NOT EXISTS (SELECT 1 from rcv_transactions rt
                       WHERE  rt.transaction_type = 'RETURN TO VENDOR'
                       AND    rt.interface_source_line_id = wdd.delivery_detail_id)
  ORDER BY source_line_id, source_line_number;

  -- Cursors for picking wdds that should be updated as inv_interfaced.
  CURSOR   wdd_cursor_5 IS
  SELECT   wdd.delivery_detail_id
  FROM     wsh_delivery_details       wdd,
           wsh_delivery_assignments   wda,
           rcv_transactions           rt
  WHERE    wda.delivery_detail_id = wdd.delivery_detail_id
  AND      wda.delivery_id = p_delivery_id
  AND      wdd.source_code = 'RTV'
  AND      wdd.released_status = 'C'
  AND      wdd.inv_interfaced_flag <> 'Y'
  AND      wdd.container_flag = 'N'
  AND      wdd.delivery_detail_id = rt.interface_source_line_id
  AND      rt.transaction_type = 'RETURN TO VENDOR'
  FOR UPDATE OF inv_interfaced_flag nowait;

  CURSOR   wdd_cursor_6 IS
  SELECT   wdd.delivery_detail_id
  FROM     wsh_delivery_details       wdd,
           wsh_delivery_assignments   wda,
           mtl_material_transactions  mmt
  WHERE    wda.delivery_detail_id = wdd.delivery_detail_id
  AND      wda.delivery_id = p_delivery_id
  AND      wdd.source_code = 'RTV'
  AND      wdd.released_status = 'C'
  AND      wdd.inv_interfaced_flag <> 'Y'
  AND      wdd.container_flag = 'N'
  AND      wdd.delivery_detail_id = mmt.picking_line_id
  AND      mmt.transaction_type_id = 1005
  FOR UPDATE OF inv_interfaced_flag nowait;

  l_header_id            NUMBER;
  l_group_id             NUMBER;
  l_INVTM_status         VARCHAR2(2);
  l_RCVTM_status         VARCHAR2(2);
  l_case_1_status        VARCHAR2(1) := 'S';
  l_case_2_status        VARCHAR2(1) := 'S';
  l_case_3_status        VARCHAR2(1) := 'S';
  l_case_4_status        VARCHAR2(1) := 'S';
  l_case_5_status        VARCHAR2(1) := 'S';
  l_return_status        VARCHAR2(1) := null;
  l_index                NUMBER:= 0;
  l_detail_rows          wsh_util_core.id_tab_type;

  BEGIN
    IF (g_asn_debug = 'Y') THEN
        asn_debug.put_line('Inside interface_to_rcv : p_delivery_id => ' || p_delivery_id);
    END IF;

    ----------------------------------------- Return agaist no document ---------------------------
    BEGIN

      SAVEPOINT SP_InvTM;
        --
        l_header_id := NULL;
        l_INVTM_status := NULL;

        FOR wdd_rec IN wdd_cursor_1 LOOP
            IF ( l_header_id IS NULL) THEN
                 IF (g_asn_debug = 'Y') THEN
                     asn_debug.put_line('-------------------------------------------');
                     asn_debug.put_line('    Processing Returns without receipts');
                     asn_debug.put_line('-------------------------------------------');
                 END IF;
                 SELECT mtl_material_transactions_s.nextval INTO l_header_id FROM DUAL; -- Bug 11831232
            END IF;
            load_mtl_interfaces ('Issue out', wdd_rec, l_header_id, p_delivery_id);
        END LOOP;

        IF (l_header_id IS NOT NULL) THEN
            process_txn(l_header_id, l_INVTM_status);

            IF (l_INVTM_status = 'S') THEN
                perform_post_TM_updates ('INV', p_delivery_id);
                COMMIT;
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line ('Returns without receipts processed successfully');
                END IF;

            ELSE
                ROLLBACK TO SP_InvTM;
                l_case_1_status := l_INVTM_status;
            END IF;
        END IF;
        asn_debug.put_line(' l_case_1_status => ' || l_case_1_status);
        --
    EXCEPTION
     WHEN OTHERS THEN
       IF (g_asn_debug = 'Y') THEN
           asn_debug.put_line ('Case1 Unexpected exception : ' || SQLERRM);
       END IF;
       l_case_1_status := 'E';
       ROLLBACK TO SP_InvTM;
    END;

    ----------------------------------------- Return from Receipt org ---------------------------
    BEGIN

      SAVEPOINT SP_RcvTM;
        --
        l_group_id := NULL;
        l_RCVTM_status := NULL;

        FOR wdd_rec IN wdd_cursor_2 LOOP
            IF ( l_group_id IS NULL) THEN
                 IF (g_asn_debug = 'Y') THEN
                     asn_debug.put_line('-------------------------------------------');
                     asn_debug.put_line('   Processing Returns in the Receipt org');
                     asn_debug.put_line('-------------------------------------------');
                 END IF;
                 SELECT rcv_interface_groups_s.nextval INTO l_group_id FROM DUAL; -- Bug 11831232
            END IF;
            load_rcv_interfaces (p_delivery_id, wdd_rec,l_group_id);
            relieve_return_reservation (wdd_rec);
        END LOOP;

        IF (l_group_id IS NOT NULL) THEN
            COMMIT;
            invoke_rtp (l_group_id, l_RCVTM_status);

            IF (l_RCVTM_status = 'S') THEN
                perform_post_TM_updates ('RCV', p_delivery_id);
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line ('Returns within receipts org processed successfully');
                END IF;
            ELSE
                --RTV2 rtv project phase 2 : start
                FOR wdd_rec IN wdd_cursor_2 LOOP
                    rollback_rtp_fail(wdd_rec, l_group_id);
                END LOOP;
                marklpn_rtp_fail(l_group_id);
                --RTV2 rtv project phase 2 : end
                clean_up_after_rtp (p_delivery_id, l_group_id);
                l_case_2_status := l_RCVTM_status;
            END IF;
            COMMIT;
        END IF;
        asn_debug.put_line(' l_case_2_status => ' || l_case_2_status);
        --
    EXCEPTION
     WHEN OTHERS THEN
       IF (g_asn_debug = 'Y') THEN
           asn_debug.put_line ('Case2 Unexpected exception : ' || SQLERRM);
       END IF;
       l_case_2_status := 'E';
       ROLLBACK TO SP_RcvTM;
    END;

    ----------------------------------------- Direct transfers from Return hub ---------------------------
    BEGIN

      SAVEPOINT SP_IOT;
        --
        l_header_id := NULL;
        l_INVTM_status := NULL;

        FOR wdd_rec IN wdd_cursor_3 LOOP
            IF ( l_header_id IS NULL) THEN
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('-------------------------------------------');
                    asn_debug.put_line('Processing Direct transfers from Return hub');
                    asn_debug.put_line('-------------------------------------------');
                END IF;
                SELECT mtl_material_transactions_s.nextval INTO l_header_id FROM DUAL; -- Bug 11831232
            END IF;
            load_mtl_interfaces ('Direct Transfer', wdd_rec, l_header_id, p_delivery_id);
        END LOOP;

        IF (l_header_id IS NOT NULL) THEN
            process_txn(l_header_id, l_INVTM_status);

            IF (l_INVTM_status = 'S') THEN
                COMMIT;
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line ('Direct Transfer processed successfully');
                END IF;
            ELSE
                ROLLBACK TO SP_IOT;
                l_case_3_status := l_INVTM_status;
            END IF;
        END IF;
        asn_debug.put_line(' l_case_3_status => ' || l_case_3_status);
        --
    EXCEPTION
     WHEN OTHERS THEN
       IF (g_asn_debug = 'Y') THEN
           asn_debug.put_line ('Case3 Unexpected exception : ' || SQLERRM);
       END IF;
       l_case_3_status := 'E';
       ROLLBACK;
    END;
    ----------------------------------------- Returns after Direct txr ---------------------------

    BEGIN
      SAVEPOINT SP_Rcv;
        --
        l_group_id := NULL;
        l_RCVTM_status := NULL;

        FOR wdd_rec IN wdd_cursor_4 LOOP
            IF ( l_group_id IS NULL) THEN
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('-------------------------------------------');
                    asn_debug.put_line('    Processing Returns after Direct txr');
                    asn_debug.put_line('-------------------------------------------');
                END IF;
                SELECT rcv_interface_groups_s.nextval INTO l_group_id FROM DUAL; -- Bug 11831232
            END IF;
            load_rcv_interfaces (p_delivery_id, wdd_rec,l_group_id);
        END LOOP;

        IF (l_group_id IS NOT NULL) THEN
            COMMIT;
            invoke_rtp (l_group_id, l_RCVTM_status);

            IF (l_RCVTM_status = 'S') THEN
                perform_post_TM_updates ('RCV', p_delivery_id);
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line ('Returns after Direct txr processed successfully');
                END IF;
            ELSE
                --RTV2 rtv project phase 2 : start
                FOR wdd_rec IN wdd_cursor_4 LOOP
                    rollback_rtp_fail(wdd_rec, l_group_id);
                END LOOP;
                --RTV2 rtv project phase 2 : end
                clean_up_after_rtp (p_delivery_id, l_group_id);
                l_case_4_status := l_RCVTM_status;
            END IF;
            COMMIT;
        END IF;
        asn_debug.put_line(' l_case_4_status => ' || l_case_4_status);
    EXCEPTION
     WHEN OTHERS THEN
       IF (g_asn_debug = 'Y') THEN
           asn_debug.put_line ('Case4 Unexpected exception : ' || SQLERRM);
       END IF;
       l_case_4_status := 'E';
       ROLLBACK;
    END;
    ----------------------------------------- Set WDDs as interfaced  ---------------------------

    BEGIN
        --
        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('-------------------------------------------');
            asn_debug.put_line('  Checking for completely processed WDDs');
            asn_debug.put_line('-------------------------------------------');
        END IF;
        --
        asn_debug.put_line('Picking RT interfaced WDDs');

        FOR wdd_rec IN wdd_cursor_5 LOOP
            l_index := l_index + 1;
            l_detail_rows(l_index) := (wdd_rec.delivery_detail_id);

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('l_detail_rows(' || l_index || ') => ' || l_detail_rows(l_index));
            END IF;
        END LOOP;
        --
        asn_debug.put_line('Picking MMT interfaced WDDs');

        FOR wdd_rec IN wdd_cursor_6 LOOP
            l_index := l_index + 1;
            l_detail_rows(l_index) := (wdd_rec.delivery_detail_id);

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('l_detail_rows(' || l_index || ') => ' || l_detail_rows(l_index));
            END IF;
        END LOOP;
        --
        IF (l_index > 0) THEN
            WSH_INTEGRATION.update_delivery_details
	           ( p_detail_rows   => l_detail_rows,
	             x_return_status => l_return_status);

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('l_return_status => ' || l_return_status);
            END IF;
        END IF;

        IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            l_case_5_status := 'E';
        ELSE
            COMMIT;
        END IF;

        asn_debug.put_line(' l_case_5_status => ' || l_case_5_status);
        --
        IF (l_case_1_status = 'S' AND l_case_2_status = 'S' AND l_case_3_status = 'S' AND l_case_4_status = 'S' AND l_case_5_status = 'S') THEN
            p_return_status := 'S';
        ELSE
            p_return_status := 'E';
        END IF;

        IF (g_asn_debug = 'Y') THEN
           asn_debug.put_line('Leaving interface_to_rcv : p_delivery_id => ' || p_delivery_id || ', p_return_status => ' || p_return_status);
        END IF;

    EXCEPTION
     WHEN OTHERS THEN
       IF (g_asn_debug = 'Y') THEN
           asn_debug.put_line ('Case5 Unexpected exception : ' || SQLERRM);
       END IF;
       p_return_status := 'E';
       ROLLBACK;
    END;
    --
  END interface_to_rcv;

/*===========================================================================

  PROCEDURE NAME:	invoke_RTP ()

===========================================================================*/

  PROCEDURE invoke_RTP
      (p_group_id           IN NUMBER,
       p_return_status      OUT NOCOPY VARCHAR2 ) IS

  l_rcv_count       NUMBER := 0;
  l_timeout         NUMBER := 172800;
  l_status          NUMBER;
  l_outcome         VARCHAR2(200) := NULL;
  l_msg             VARCHAR2(200) := NULL;
  l_msg01           VARCHAR2(200) := NULL;
  l_msg02           VARCHAR2(200) := NULL;
  l_msg03           VARCHAR2(200) := NULL;
  l_msg04           VARCHAR2(200) := NULL;
  l_msg05           VARCHAR2(200) := NULL;
  l_msg06           VARCHAR2(200) := NULL;
  l_msg07           VARCHAR2(200) := NULL;
  l_msg08           VARCHAR2(200) := NULL;
  l_msg09           VARCHAR2(200) := NULL;
  l_msg10           VARCHAR2(200) := NULL;
  l_msg11           VARCHAR2(200) := NULL;
  l_msg12           VARCHAR2(200) := NULL;
  l_msg13           VARCHAR2(200) := NULL;
  l_msg14           VARCHAR2(200) := NULL;
  l_msg15           VARCHAR2(200) := NULL;
  l_msg16           VARCHAR2(200) := NULL;
  l_msg17           VARCHAR2(200) := NULL;
  l_msg18           VARCHAR2(200) := NULL;
  l_msg19           VARCHAR2(200) := NULL;
  l_msg20           VARCHAR2(200) := NULL;
  l_str             VARCHAR2(4000) := NULL;

  BEGIN

     asn_debug.put_line('Inside invoke_RTP');

     SELECT COUNT(*)
     INTO   l_rcv_count
     FROM   rcv_transactions_interface
     WHERE  group_id = p_group_id;
     asn_debug.put_line('RTI record count for group_id ' || p_group_id || ' : ' || l_rcv_count);

     l_status := fnd_transaction.synchronous
                   ( l_timeout, l_outcome, l_msg, 'PO', 'RCVTPO', 'ONLINE',  p_group_id,
                     NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                     NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

     SELECT COUNT(*)
     INTO   l_rcv_count
     FROM   rcv_transactions
     WHERE  group_id = p_group_id;
     asn_debug.put_line('RT record count for group_id ' || p_group_id || ' : ' || l_rcv_count);

     IF (l_status = 0 and (l_outcome NOT IN ('WARNING', 'ERROR'))) THEN
         p_return_status := 'S';
         IF (g_asn_debug = 'Y') THEN
             asn_debug.put_line('RCV transaction processed successfully');
         END IF;

     ELSIF (l_status = 1) THEN
         p_return_status := 'E';
         IF (g_asn_debug = 'Y') THEN
             asn_debug.put_line('RCVTM timeout!');
         END IF;

     ELSIF (l_status = 2) THEN
         p_return_status := 'E';
         IF (g_asn_debug = 'Y') THEN
             asn_debug.put_line('RCV Manager not available!');
         END IF;

     ELSIF (l_status = 3 or (l_outcome IN ('WARNING', 'ERROR'))) THEN
         p_return_status := 'E';
         IF (g_asn_debug = 'Y') THEN
             asn_debug.put_line('RCV Manager failed!');
         END IF;
         l_status := fnd_transaction.get_values
                 ( l_msg01, l_msg02, l_msg03, l_msg04, l_msg05,
                   l_msg06, l_msg07, l_msg08, l_msg09, l_msg10,
                   l_msg11, l_msg12, l_msg13, l_msg14, l_msg15,
                   l_msg16, l_msg17, l_msg18, l_msg19, l_msg20 );

         l_str := l_msg01;
         IF (l_msg02 IS NOT NULL) THEN l_str := l_str || ' ' || l_msg02; END IF;
         IF (l_msg03 IS NOT NULL) THEN l_str := l_str || ' ' || l_msg03; END IF;
         IF (l_msg04 IS NOT NULL) THEN l_str := l_str || ' ' || l_msg04; END IF;
         IF (l_msg05 IS NOT NULL) THEN l_str := l_str || ' ' || l_msg05; END IF;
         IF (l_msg06 IS NOT NULL) THEN l_str := l_str || ' ' || l_msg06; END IF;
         IF (l_msg07 IS NOT NULL) THEN l_str := l_str || ' ' || l_msg07; END IF;
         IF (l_msg08 IS NOT NULL) THEN l_str := l_str || ' ' || l_msg08; END IF;
         IF (l_msg09 IS NOT NULL) THEN l_str := l_str || ' ' || l_msg09; END IF;
         IF (l_msg10 IS NOT NULL) THEN l_str := l_str || ' ' || l_msg10; END IF;
         IF (l_msg11 IS NOT NULL) THEN l_str := l_str || ' ' || l_msg11; END IF;
         IF (l_msg12 IS NOT NULL) THEN l_str := l_str || ' ' || l_msg12; END IF;
         IF (l_msg13 IS NOT NULL) THEN l_str := l_str || ' ' || l_msg13; END IF;
         IF (l_msg14 IS NOT NULL) THEN l_str := l_str || ' ' || l_msg14; END IF;
         IF (l_msg15 IS NOT NULL) THEN l_str := l_str || ' ' || l_msg15; END IF;
         IF (l_msg16 IS NOT NULL) THEN l_str := l_str || ' ' || l_msg16; END IF;
         IF (l_msg17 IS NOT NULL) THEN l_str := l_str || ' ' || l_msg17; END IF;
         IF (l_msg18 IS NOT NULL) THEN l_str := l_str || ' ' || l_msg18; END IF;
         IF (l_msg19 IS NOT NULL) THEN l_str := l_str || ' ' || l_msg19; END IF;
         IF (l_msg20 IS NOT NULL) THEN l_str := l_str || ' ' || l_msg20; END IF;

         IF (g_asn_debug = 'Y') THEN
             asn_debug.put_line('Error is : ' || l_str);
         END IF;
     END IF;

     asn_debug.put_line('Leaving invoke_RTP');

  EXCEPTION
    WHEN OTHERS THEN
         p_return_status := 'E';
         IF (g_asn_debug = 'Y') THEN
             asn_debug.put_line ('Case3 Unexpected exception from invoke_RTP: ' || SQLERRM);
         END IF;
  END invoke_RTP;

/*===========================================================================

  PROCEDURE NAME:	process_txn ()

===========================================================================*/

  PROCEDURE process_txn
      (p_header_id          IN NUMBER,
       p_return_status      OUT NOCOPY VARCHAR2) IS

  l_return_status        VARCHAR2(2);
  l_msg_count            NUMBER;
  l_msg_data             VARCHAR2(2000);
  l_trans_count          NUMBER;
  l_status               NUMBER;
  e_INVTM_error          EXCEPTION;

  BEGIN
       l_status := inv_txn_manager_pub.process_transactions
                 ( p_api_version      => 1.0,
                   p_init_msg_list    => FND_API.G_TRUE,
                   p_commit           => FND_API.G_FALSE,
                   p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                   x_return_status    => l_return_status,
                   x_msg_count        => l_msg_count,
                   x_msg_data         => l_msg_data,
                   x_trans_count      => l_trans_count,
                   p_table            => 1,
                   p_header_id        => p_header_id);

       IF (l_status <> 0) THEN
           raise e_INVTM_error;
       END IF;

       p_return_status := 'S';
       IF (g_asn_debug = 'Y') THEN
           asn_debug.put_line('INV transaction processed successfully');
       END IF;

  EXCEPTION
      WHEN e_INVTM_error THEN
           IF (g_asn_debug = 'Y') THEN
              asn_debug.put_line('INV transaction failed');
              asn_debug.put_line('l_msg_count : ' || l_msg_count);
              asn_debug.put_line('l_msg_data  : ' || l_msg_data);
           END IF;
           p_return_status := 'E';

      WHEN OTHERS THEN
           IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line ('Unexpected exception in process_txn: ' || SQLERRM);
           END IF;
           p_return_status := 'E';
  END process_txn;

/*===========================================================================

  PROCEDURE NAME:	load_mtl_interfaces ()

===========================================================================*/
  PROCEDURE load_mtl_interfaces
      ( p_txn_desc      IN      VARCHAR2,
        p_wdd_rec       IN      wsh_delivery_details%rowtype,
        p_header_id     IN      NUMBER,
        p_delivery_id   IN      NUMBER) IS

  CURSOR  msnt_cursor IS
  SELECT  *
  FROM    mtl_serial_numbers_temp
  WHERE   transaction_temp_id = p_wdd_rec.transaction_temp_id;

  l_temp_id              NUMBER; -- Bug 11831232
  l_deliver_subinv       rcv_transactions.subinventory%TYPE := NULL;
  l_deliver_locator      NUMBER := NULL;
  l_receipt_org          NUMBER := NULL;
  l_account_id           NUMBER := NULL;
  l_serial_temp_id       NUMBER := NULL;
  l_ou_id                NUMBER;
  l_txn_cost             NUMBER;
  l_functional_currency	 VARCHAR2(3);
  l_return_status        VARCHAR2(2);
  l_msg_count            NUMBER;
  l_msg_data             VARCHAR2(2000);
  l_txn_date             date;
  l_txn_reference        mtl_transactions_interface.transaction_reference%TYPE;
  --RTV2 rtv project phase 2 : start
  l_transfer_lpn_id      NUMBER;
  l_lpn_id               NUMBER;
  l_wms_rec_org          VARCHAR2(2);
  --RTV2 rtv project phase 2 : end

  BEGIN

      IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('Entering load_mtl_interfaces');
          asn_debug.put_line('p_txn_desc   : ' || p_txn_desc);
      END IF;

      --RTV2 rtv project phase 2 : start
      l_lpn_id := get_return_lpn_id(p_wdd_rec.delivery_detail_id);
      l_transfer_lpn_id := l_lpn_id;
      --
      IF (p_txn_desc = 'Direct Transfer') THEN
          --
          SELECT rt.subinventory, rt.locator_id, rt.organization_id, rti.rma_reference, mp.WMS_ENABLED_FLAG -- Bug 12974284
          INTO   l_deliver_subinv, l_deliver_locator, l_receipt_org, l_txn_reference, l_wms_rec_org   -- Bug 12974284
          FROM   rcv_transactions           rt,
                 rcv_transactions_interface rti,
                 mtl_parameters mp
          WHERE  rt.transaction_id = rti.parent_transaction_id
          AND    rti.interface_transaction_id = p_wdd_rec.source_line_id
          AND    rt.transaction_type = 'DELIVER'
          AND    mp.organization_id = rt.organization_id;

          IF (g_asn_debug = 'Y') THEN
              asn_debug.put_line('l_deliver_subinv  : ' || l_deliver_subinv);
              asn_debug.put_line('l_deliver_locator : ' || l_deliver_locator);
              asn_debug.put_line('l_receipt_org     : ' || l_receipt_org);
              asn_debug.put_line('l_wms_rec_org     : ' || l_wms_rec_org);
          END IF;

          IF(nvl(l_wms_rec_org, 'N') = 'N') THEN
          	 l_transfer_lpn_id := NULL;
          END IF;
       --RTV2 rtv project phase 2 : end

          --
      ELSIF (p_txn_desc = 'Issue out') THEN

             l_transfer_lpn_id := null; --RTV2 rtv project phase 2

             SELECT ap_accrual_account
             INTO   l_account_id
             FROM   mtl_parameters
             WHERE  organization_id = p_wdd_rec.organization_id;

             IF (g_asn_debug = 'Y') THEN
             asn_debug.put_line('l_account_id : ' || l_account_id);
             END IF;

             IF (l_account_id IS NULL) THEN
                 raise fnd_api.g_exc_unexpected_error;
             END IF;
             --
             SELECT currency_code, operating_unit
             INTO   l_functional_currency, l_ou_id
             FROM   cst_organization_definitions
             WHERE  organization_id = p_wdd_rec.organization_id;

             IF (g_asn_debug = 'Y') THEN
                 asn_debug.put_line('l_functional_currency : ' || l_functional_currency);
             END IF;

             IF (p_wdd_rec.currency_code IS NOT NULL AND p_wdd_rec.currency_code <> l_functional_currency) THEN
                 l_txn_cost := inv_transaction_flow_pub.convert_currency
                         ( p_org_id                   => l_ou_id,
	                   p_transfer_price           => p_wdd_rec.unit_price,
	                   p_currency_code            => p_wdd_rec.currency_code,
	                   p_transaction_date         => p_wdd_rec.date_requested,
	                   p_logical_txn              => 'N',
	                   x_functional_currency_code => l_functional_currency,
	                   x_return_status            => l_return_status,
	                   x_msg_data                 => l_msg_data,
                           x_msg_count                => l_msg_count);

                 IF  (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
                      raise fnd_api.g_exc_unexpected_error;
                 END IF;
             END IF;
             IF (g_asn_debug = 'Y') THEN
                 asn_debug.put_line('l_functional_currency : ' || l_functional_currency);
                 asn_debug.put_line('l_txn_cost            : ' || l_txn_cost);
             END IF;
             --
      ELSE
             RETURN;
      END IF;
      --RTV2 rtv project phase 2 : start
      IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('l_lpn_id              : ' || l_lpn_id);
          asn_debug.put_line('l_transfer_lpn_id     : ' || l_transfer_lpn_id);
      END IF;
      --RTV2 rtv project phase 2 : end

      --
      SELECT  wts.actual_departure_date
      INTO    l_txn_date
      FROM    wsh_new_deliveries       wnd,
              wsh_delivery_legs        wdl,
              wsh_trip_stops           wts
      WHERE   wnd.delivery_id = wdl.delivery_id
      AND     wdl.pick_up_stop_id = wts.stop_id
      AND     wnd.initial_pickup_location_id = wts.stop_location_id
      AND     wnd.delivery_id = p_delivery_id;
      --
      SELECT  rma_reference
      INTO    l_txn_reference
      FROM    rcv_transactions_interface
      WHERE   interface_transaction_id = p_wdd_rec.source_line_id; -- Bug 12974284
      --
      SELECT  mtl_material_transactions_s.nextval INTO l_temp_id FROM DUAL; -- Bug 11831232
      --
      INSERT INTO mtl_transactions_interface
             ( transaction_header_id,
               transaction_interface_id,
               source_code,
               transaction_source_name,
               source_header_id,
               source_line_id,
               picking_line_id,
               process_flag,
               validation_required,
               transaction_mode,
               lock_flag,
               last_update_date,
               last_updated_by,
               creation_date,
               created_by,
               last_update_login,
               inventory_item_id,
               revision,
               transaction_quantity,
               transaction_uom,
               secondary_transaction_quantity,  -- Bug 12768025
               secondary_uom_code,              -- Bug 12768025
               transaction_date,
               organization_id,
               transfer_organization,
               subinventory_code,
               transfer_subinventory,
               locator_id,
               transfer_locator,
               transaction_source_type_id,
               transaction_type_id,
               transaction_action_id,
               distribution_account_id,
               currency_code,
               transaction_cost,
               transaction_reference, -- Bug 12974284
               lpn_id,                -- RTV2 rtv project phase 2
               transfer_lpn_id        -- RTV2 rtv project phase 2
             )
      SELECT   p_header_id,
               l_temp_id,
               p_txn_desc,
               p_wdd_rec.source_header_number,
               p_wdd_rec.source_header_id,
               p_wdd_rec.source_line_id,
               p_wdd_rec.delivery_detail_id,
               1,
               2,
               3,
               2,
               sysdate,
               p_wdd_rec.last_updated_by,
               sysdate,
               p_wdd_rec.created_by,
               p_wdd_rec.last_update_login,
               p_wdd_rec.inventory_item_id,
               p_wdd_rec.revision,
               decode(p_txn_desc,'Direct Transfer',p_wdd_rec.shipped_quantity, 'Issue out', p_wdd_rec.shipped_quantity * -1),
               p_wdd_rec.requested_quantity_uom,
               decode(p_txn_desc,'Direct Transfer',p_wdd_rec.shipped_quantity2, 'Issue out', p_wdd_rec.shipped_quantity2 * -1),           -- Bug 12768025
               p_wdd_rec.requested_quantity_uom2, -- Bug 12768025
               l_txn_date,
               p_wdd_rec.organization_id,
               l_receipt_org,
               p_wdd_rec.subinventory,
               decode(p_txn_desc,'Direct Transfer', l_deliver_subinv, 'Issue out', NULL),
               p_wdd_rec.locator_id,
               decode(p_txn_desc,'Direct Transfer', l_deliver_locator, 'Issue out', NULL),
               13,
               decode(p_txn_desc,'Direct Transfer', 3, 'Issue out', 1005),
               decode(p_txn_desc,'Direct Transfer', 3, 'Issue out', 1),
               l_account_id,
               decode(p_txn_desc,'Direct Transfer', NULL, 'Issue out', l_functional_currency),
               l_txn_cost,
               l_txn_reference, -- Bug 12974284
               l_lpn_id,         -- RTV2 rtv project phase 2
               l_transfer_lpn_id -- RTV2 rtv project phase 2
      FROM     DUAL;

      IF (g_asn_debug = 'Y') THEN
           asn_debug.put_line('Inserted MTI with transaction_interface_id : ' || l_temp_id);
      END IF;

      load_lot_serial_interfaces ('INV', p_wdd_rec, l_temp_id);

      --RTV2 rtv project phase 2 : start
      unmark_wdd_lpn(p_wdd_rec          => p_wdd_rec,
                     p_lpn_id           => l_lpn_id,
                     x_return_status    => l_return_status,
                     x_msg_count        => l_msg_count,
                     x_msg_data         => l_msg_data);
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          raise fnd_api.g_exc_unexpected_error;
      END IF;
      --RTV2 rtv project phase 2 : end

      IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('Leaving load_mtl_interfaces');
      END IF;

  EXCEPTION
    WHEN OTHERS THEN
         IF (g_asn_debug = 'Y') THEN
             asn_debug.put_line('Unexpected exception in load_mtl_interfaces : ' || SQLERRM);
             raise;
         END IF;

  END load_mtl_interfaces;

 /*===========================================================================

   PROCEDURE NAME:	load_rcv_interfaces ()

 ===========================================================================*/
  PROCEDURE load_rcv_interfaces (
            p_delivery_id   IN      NUMBER,
            p_wdd_rec       IN      wsh_delivery_details%rowtype,
            p_group_id      IN      NUMBER) IS

  l_rti_id               NUMBER; -- Bug 11831232
  l_shipped_uom          mtl_units_of_measure.unit_of_measure%TYPE;
  l_shipped_uom2         mtl_units_of_measure.unit_of_measure%TYPE := NULL;
  l_primary_qty          NUMBER;
  l_marker_flag          BOOLEAN := FALSE;
  rti_rec                rcv_transactions_interface%ROWTYPE;
  l_rev_control          NUMBER;
  l_txn_date             date;
  l_from_subinventory    rcv_transactions_interface.from_subinventory%TYPE;
  l_from_locator_id      NUMBER;
  --RTV2 rtv project phase 2 : start
  l_rec_wms_org          VARCHAR2(1);
  l_return_status        VARCHAR2(1);
  l_msg_count            NUMBER;
  l_msg_data             VARCHAR2(2000);
  e_load_rti_error1      EXCEPTION;
  --RTV2 rtv project phase 2 : end

  BEGIN

      IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('Entering load_rcv_interfaces');
      END IF;
      --
      l_shipped_uom  := get_uom_from_code (p_wdd_rec.requested_quantity_uom);
      l_shipped_uom2 := get_uom_from_code (p_wdd_rec.requested_quantity_uom2);

      IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('l_shipped_uom  : ' || l_shipped_uom);
          asn_debug.put_line('l_shipped_uom2 : ' || l_shipped_uom2);
      END IF;
      --
      SELECT *
      INTO   rti_rec
      FROM   rcv_transactions_interface
      WHERE  interface_transaction_id = p_wdd_rec.source_line_id;

      IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('rti_rec.primary_unit_of_measure : ' || rti_rec.primary_unit_of_measure);
          asn_debug.put_line('rti_rec.to_organization_id      : ' || rti_rec.to_organization_id);
      END IF;

      --RTV2 rtv project phase 2 : start
      IF (rti_rec.transfer_lpn_id IS NOT NULL) THEN
      	  IF (rti_rec.to_organization_id <> p_wdd_rec.organization_id) THEN
      	      SELECT WMS_ENABLED_FLAG
      	      INTO   l_rec_wms_org
      	      FROM   mtl_parameters
      	      WHERE  organization_id = rti_rec.to_organization_id;

      	      IF (NVL(l_rec_wms_org, 'N') = 'N') THEN
      	      	  rti_rec.transfer_lpn_id := NULL;
      	      ELSE
      	      	  --we need to re-fetch lpn from wdd, since we support lpn split.
      	      	  rti_rec.transfer_lpn_id := get_return_lpn_id(p_wdd_rec.delivery_detail_id);
      	      END IF;
      	  ELSE
              --we need to re-fetch lpn from wdd, since we support lpn split.
              rti_rec.transfer_lpn_id := get_return_lpn_id(p_wdd_rec.delivery_detail_id);
      	  END IF;
      END IF;

      rti_rec.lpn_id := rti_rec.transfer_lpn_id;
      IF (rti_rec.lpn_id IS NULL) THEN
      	  rti_rec.lpn_group_id := NULL;
      END IF;
      --RTV2 rtv project phase 2 : end

      --
      IF (l_shipped_uom <> rti_rec.primary_unit_of_measure) THEN
          po_uom_s.uom_convert
               ( from_quantity => p_wdd_rec.shipped_quantity,
                 from_uom      => l_shipped_uom,
                 item_id       => p_wdd_rec.inventory_item_id,
                 to_uom        => rti_rec.primary_unit_of_measure,
                 to_quantity   => l_primary_qty);
      ELSE
          l_primary_qty := p_wdd_rec.shipped_quantity;
      END IF;

      IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('l_primary_qty : ' || l_primary_qty);
      END IF;
      --
      IF (rti_rec.item_revision IS NOT NULL) THEN
          SELECT revision_qty_control_code
          INTO   l_rev_control
          FROM   mtl_system_items msi
          WHERE  msi.organization_id = rti_rec.to_organization_id
          AND    msi.inventory_item_id = rti_rec.item_id;

          IF (g_asn_debug = 'Y') THEN
              asn_debug.put_line('l_rev_control : ' || l_rev_control);
          END IF;

          IF (l_rev_control = 1) THEN
              rti_rec.item_revision := NULL;
          END IF;
      END IF;
      --
      IF (rti_rec.to_organization_id <> p_wdd_rec.organization_id) THEN
          SELECT rt.subinventory, rt.locator_id
          INTO   l_from_subinventory, l_from_locator_id
          FROM   rcv_transactions rt
          WHERE  rt.transaction_id = rti_rec.parent_transaction_id
          AND    rt.transaction_type = 'DELIVER';
      ELSE
          l_from_subinventory  := rti_rec.from_subinventory;
          l_from_locator_id    := rti_rec.from_locator_id;
      END IF;
      --
      IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('l_from_subinventory : ' || l_from_subinventory);
          asn_debug.put_line('l_from_locator_id   : ' || l_from_locator_id);
      END IF;
      --
      SELECT  wts.actual_departure_date
      INTO    l_txn_date
      FROM    wsh_new_deliveries       wnd,
              wsh_delivery_legs        wdl,
              wsh_trip_stops           wts
      WHERE   wnd.delivery_id = wdl.delivery_id
      AND     wdl.pick_up_stop_id = wts.stop_id
      AND     wnd.initial_pickup_location_id = wts.stop_location_id
      AND     wnd.delivery_id = p_delivery_id;
      --
      SELECT  rcv_transactions_interface_s.nextval INTO l_rti_id FROM DUAL; -- Bug 11831232
      --
      INSERT INTO rcv_transactions_interface
          (  receipt_source_code,
             interface_transaction_id,
             interface_source_line_id,
             group_id,
             last_update_date,
             last_updated_by,
             created_by,
             creation_date,
             last_update_login,
             source_document_code,
             destination_type_code,
             transaction_date,
             quantity,
             unit_of_measure,
             secondary_quantity,
             secondary_unit_of_measure,
             primary_quantity,
             primary_unit_of_measure,
             uom_code,
             shipment_header_id,
             shipment_line_id,
             substitute_unordered_code,
             employee_id,
             parent_transaction_id,
             inspection_status_code,
             inspection_quality_code,
             po_header_id,
             po_release_id,
             po_line_id,
             po_line_location_id,
             po_distribution_id,
             po_revision_num,
             po_unit_price,
             currency_code,
             currency_conversion_rate,
             currency_conversion_date,
             currency_conversion_type,
             routing_header_id,
             routing_step_id,
             comments,
             attribute_category,
             attribute1,
             attribute2,
             attribute3,
             attribute4,
             attribute5,
             attribute6,
             attribute7,
             attribute8,
             attribute9,
             attribute10,
             attribute11,
             attribute12,
             attribute13,
             attribute14,
             attribute15,
             transaction_type,
             location_id,
             processing_status_code,
             processing_mode_code,
             transaction_status_code,
             category_id,
             vendor_lot_num,
             reason_id,
             item_id,
             item_revision,
             to_organization_id,
             deliver_to_location_id,
             destination_context,
             vendor_id,
             deliver_to_person_id,
             wip_entity_id,
             wip_line_id,
             wip_repetitive_schedule_id,
             wip_operation_seq_num,
             wip_resource_seq_num,
             bom_resource_id,
             from_organization_id,
             receipt_exception_flag,
             department_code,
             item_description,
             movement_id,
             use_mtl_lot,
             use_mtl_serial,
             rma_reference,
             ussgl_transaction_code,
             government_context,
             vendor_site_id,
             oe_order_header_id,
             oe_order_line_id,
             customer_id,
             customer_site_id,
             create_debit_memo_flag,
             lpn_id,
             transfer_lpn_id,
             lpn_group_id,
             from_subinventory,
             from_locator_id,
             subinventory,
             locator_id,
             org_id,
             lcm_shipment_line_id,
             unit_landed_cost,
             validation_flag
          )
      VALUES
          (  rti_rec.receipt_source_code,
             l_rti_id,
             p_wdd_rec.delivery_detail_id,
             p_group_id,
             sysdate,
             rti_rec.last_updated_by,
             rti_rec.created_by,
             sysdate,
             rti_rec.last_update_login,
             rti_rec.source_document_code,
             rti_rec.destination_type_code,
             l_txn_date,
             p_wdd_rec.shipped_quantity,
             l_shipped_uom,
             p_wdd_rec.shipped_quantity2,
             l_shipped_uom2,
             l_primary_qty,
             rti_rec.primary_unit_of_measure,
             p_wdd_rec.requested_quantity_uom, -- Bug 14340673
             rti_rec.shipment_header_id,
             rti_rec.shipment_line_id,
             rti_rec.substitute_unordered_code,
             rti_rec.employee_id,
             rti_rec.parent_transaction_id,
             rti_rec.inspection_status_code,
             rti_rec.inspection_quality_code,
             rti_rec.po_header_id,
             rti_rec.po_release_id,
             rti_rec.po_line_id,
             rti_rec.po_line_location_id,
             rti_rec.po_distribution_id,
             rti_rec.po_revision_num,
             rti_rec.po_unit_price,
             rti_rec.currency_code,
             rti_rec.currency_conversion_rate,
             rti_rec.currency_conversion_date,
             rti_rec.currency_conversion_type,
             rti_rec.routing_header_id,
             rti_rec.routing_step_id,
             rti_rec.comments,
             rti_rec.attribute_category,
             rti_rec.attribute1,
             rti_rec.attribute2,
             rti_rec.attribute3,
             rti_rec.attribute4,
             rti_rec.attribute5,
             rti_rec.attribute6,
             rti_rec.attribute7,
             rti_rec.attribute8,
             rti_rec.attribute9,
             rti_rec.attribute10,
             rti_rec.attribute11,
             rti_rec.attribute12,
             rti_rec.attribute13,
             rti_rec.attribute14,
             rti_rec.attribute15,
             rti_rec.transaction_type,
             rti_rec.location_id,
             'PENDING',
             'ONLINE',
             'PENDING',
             rti_rec.category_id,
             rti_rec.vendor_lot_num,
             rti_rec.reason_id,
             rti_rec.item_id,
             rti_rec.item_revision,
             rti_rec.to_organization_id,
             rti_rec.deliver_to_location_id,
             rti_rec.destination_context,
             rti_rec.vendor_id,
             rti_rec.deliver_to_person_id,
             rti_rec.wip_entity_id,
             rti_rec.wip_line_id,
             rti_rec.wip_repetitive_schedule_id,
             rti_rec.wip_operation_seq_num,
             rti_rec.wip_resource_seq_num,
             rti_rec.bom_resource_id,
             rti_rec.from_organization_id,
             rti_rec.receipt_exception_flag,
             rti_rec.department_code,
             rti_rec.item_description,
             rti_rec.movement_id,
             rti_rec.use_mtl_lot,
             rti_rec.use_mtl_serial,
             rti_rec.rma_reference,
             rti_rec.ussgl_transaction_code,
             rti_rec.government_context,
             rti_rec.vendor_site_id,
             rti_rec.oe_order_header_id,
             rti_rec.oe_order_line_id,
             rti_rec.customer_id,
             rti_rec.customer_site_id,
             rti_rec.create_debit_memo_flag,
             rti_rec.lpn_id,
             rti_rec.transfer_lpn_id,
             rti_rec.lpn_group_id,
             l_from_subinventory,
             l_from_locator_id,
             rti_rec.subinventory,
             rti_rec.locator_id,
             rti_rec.org_id,
             rti_rec.lcm_shipment_line_id,
             rti_rec.unit_landed_cost,
             'Y'
           );

      IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('Inserted RTI with transaction_interface_id : ' || l_rti_id);
      END IF;
      --
      load_lot_serial_interfaces ('RCV', p_wdd_rec, l_rti_id);

      --RTV2 rtv project phase 2 : start
      --We just need to unmark lpn for wdd which has related lpn and RTV is from receipt org.
      --As for RTV org different from RCV org, we already unmark lpn before performing direct org xfer.
      IF (rti_rec.transfer_lpn_id IS NOT NULL AND rti_rec.to_organization_id = p_wdd_rec.organization_id) THEN
          unmark_wdd_lpn(p_wdd_rec          => p_wdd_rec,
                         p_lpn_id           => rti_rec.transfer_lpn_id,
                         x_return_status    => l_return_status,
                         x_msg_count        => l_msg_count,
                         x_msg_data         => l_msg_data);
          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              raise fnd_api.g_exc_unexpected_error;
          END IF;
      END IF;
      --Re-mark lpn for new RTIs
      IF( rti_rec.transfer_lpn_id IS NOT NULL) THEN
          wms_return_sv.MARK_RETURNS(
                       x_return_status        => l_return_status,
                       x_msg_count            => l_msg_count,
                       x_msg_data             => l_msg_data,
                       p_rcv_trx_interface_id => l_rti_id,
                       p_ret_transaction_type => rti_rec.transaction_type,
                       p_lpn_id               => rti_rec.transfer_lpn_id,
                       p_item_id              => rti_rec.item_id,
                       p_item_revision        => rti_rec.item_revision,
                       p_quantity             => p_wdd_rec.shipped_quantity,
                       p_uom                  => p_wdd_rec.requested_quantity_uom,
                       p_serial_controlled    => rti_rec.use_mtl_serial,
                       p_lot_controlled       => rti_rec.use_mtl_lot,
                       p_org_id               => rti_rec.to_organization_id,
                       p_subinventory         => l_from_subinventory,
                       p_locator_id           => l_from_locator_id);

          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              raise fnd_api.g_exc_unexpected_error;
          END IF;
      END IF;
      --RTV2 rtv project phase 2 : end

      IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('Leaving load_rcv_interfaces');
      END IF;

  EXCEPTION
    WHEN OTHERS THEN
         IF (g_asn_debug = 'Y') THEN
             asn_debug.put_line('Unexpected exception in load_rcv_interfaces : ' || SQLERRM);
             raise;
         END IF;

  END load_rcv_interfaces;

 /*===========================================================================

   PROCEDURE NAME:	load_lot_serial_interfaces ()

 ===========================================================================*/
  PROCEDURE load_lot_serial_interfaces (
            p_source        IN      VARCHAR2,
            p_wdd_rec       IN      wsh_delivery_details%rowtype,
            p_parent_id     IN      NUMBER) IS

  CURSOR  WSN_cursor IS
  SELECT  *
  FROM    wsh_serial_numbers
  WHERE   delivery_detail_id = p_wdd_rec.delivery_detail_id;

  l_temp_id              NUMBER;
  l_serial_temp_id       NUMBER  := NULL;
  l_prod_txn_id          NUMBER  := NULL;
  l_serial_control       NUMBER;
  l_lot_control          NUMBER;
  l_source_allows_lot    BOOLEAN := TRUE;
  l_source_allows_serial BOOLEAN := TRUE;
  l_lot_inserted         BOOLEAN := FALSE;
  l_serial_inserted      BOOLEAN := FALSE;
  l_serial_tagged        NUMBER  := 1;
  l_rti_org_id           NUMBER;
  l_rti_item_id          NUMBER;

  BEGIN

       IF (g_asn_debug = 'Y') THEN
           asn_debug.put_line('Entering load_lot_serial_interfaces : Source => ' || p_source || ' ,parent => ' || p_parent_id);
       END IF;

       IF (p_wdd_rec.lot_number IS NULL AND p_wdd_rec.transaction_temp_id IS NULL) THEN
           IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('No lot/serial attached to WDD : ' || p_wdd_rec.delivery_detail_id);
           END IF;
           RETURN;
       END IF;
       --
       IF (p_source = 'RCV') THEN
           SELECT msi.lot_control_code, msi.serial_number_control_code,
                  rti.to_organization_id, rti.item_id
           INTO   l_lot_control, l_serial_control, l_rti_org_id, l_rti_item_id
           FROM   mtl_system_items msi,
                  rcv_transactions_interface rti
           WHERE  msi.organization_id = rti.to_organization_id
           AND    msi.inventory_item_id = rti.item_id
           AND    rti.interface_transaction_id = p_parent_id;

           l_serial_tagged := inv_cache.get_serial_tagged (l_rti_org_id, l_rti_item_id , 36);

           IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('l_serial_control : ' || l_serial_control || ' ,l_lot_control : ' || l_lot_control || ', l_serial_tagged : ' || l_serial_tagged);
           END IF;

           IF (l_lot_control <> 2) THEN
               l_source_allows_lot := FALSE;
           END IF;

           IF (l_serial_control NOT IN (2,5) AND l_serial_tagged <> 2) THEN
               l_source_allows_serial := FALSE;
           END IF;

           l_prod_txn_id := p_parent_id;
       END IF;
       --
       IF (l_source_allows_lot AND p_wdd_rec.lot_number IS NOT NULL ) THEN
           IF (p_source = 'INV') THEN
               l_temp_id := p_parent_id;
           ELSIF (p_source = 'RCV') THEN
               SELECT mtl_material_transactions_s.nextval INTO l_temp_id FROM DUAL; -- Bug 11831232
           END IF;
           --
           INSERT INTO mtl_transaction_lots_interface
                  ( transaction_interface_id,
                    last_update_date,
                    last_updated_by,
                    creation_date,
                    created_by,
                    last_update_login,
                    lot_number,
                    transaction_quantity,
                    primary_quantity,
                    product_code,
                    product_transaction_id,
                    attribute_category,
                    attribute1,
                    attribute2,
                    attribute3,
                    attribute4,
                    attribute5,
                    attribute6,
                    attribute7,
                    attribute8,
                    attribute9,
                    attribute10,
                    attribute11,
                    attribute12,
                    attribute13,
                    attribute14,
                    attribute15
                  )
           SELECT   l_temp_id,
                    sysdate,
                    p_wdd_rec.last_updated_by,
                    sysdate,
                    p_wdd_rec.created_by,
                    p_wdd_rec.last_update_login,
                    p_wdd_rec.lot_number,
                    p_wdd_rec.shipped_quantity,
                    p_wdd_rec.shipped_quantity,
                    mtlt.product_code,
                    l_prod_txn_id,
                    mtlt.attribute_category,
                    mtlt.attribute1,
                    mtlt.attribute2,
                    mtlt.attribute3,
                    mtlt.attribute4,
                    mtlt.attribute5,
                    mtlt.attribute6,
                    mtlt.attribute7,
                    mtlt.attribute8,
                    mtlt.attribute9,
                    mtlt.attribute10,
                    mtlt.attribute11,
                    mtlt.attribute12,
                    mtlt.attribute13,
                    mtlt.attribute14,
                    mtlt.attribute15
           FROM     mtl_transaction_lots_temp mtlt
           WHERE    mtlt.transaction_temp_id (+) = p_wdd_rec.source_line_id
           AND      mtlt.lot_number = p_wdd_rec.lot_number;

           l_lot_inserted := TRUE;

           IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Inserted MTLI for Lot# : ' || p_wdd_rec.lot_number);
           END IF;

       END IF;
       --
       IF (l_source_allows_serial) THEN
           FOR wsn_rec IN WSN_cursor LOOP

               IF (l_serial_temp_id IS NULL) THEN
                   IF (p_source = 'INV') THEN
                       IF (l_lot_inserted) THEN
                           SELECT mtl_material_transactions_s.nextval INTO l_serial_temp_id FROM DUAL; -- Bug 11831232
                       ELSE
                           l_serial_temp_id := p_parent_id;
                       END IF;
                   ELSIF (p_source = 'RCV') THEN
                          SELECT mtl_material_transactions_s.nextval INTO l_serial_temp_id FROM DUAL; -- Bug 11831232
                   END IF;
               END IF;
               --
               -- Transfer tagged serial to receipt org if return is done from another org ie, direct txr is completed at this point.
               IF (l_serial_tagged = 2 AND l_rti_org_id <> p_wdd_rec.organization_id) THEN
                   UPDATE mtl_serial_numbers
                   SET    current_organization_id = l_rti_org_id
                   WHERE  inventory_item_id = l_rti_item_id
                   AND    current_organization_id = p_wdd_rec.organization_id
                   AND    serial_number between wsn_rec.fm_serial_number and nvl(wsn_rec.to_serial_number,wsn_rec.fm_serial_number) -- Bug 10120533
                   AND    length(serial_number) = length(wsn_rec.fm_serial_number);                                                 -- Bug 10120533
               END IF;

               -- This will be changed to pick from WSN once shipping patch is ready.
               INSERT INTO mtl_serial_numbers_interface
               (    transaction_interface_id,
                    product_code,
                    product_transaction_id,
                    last_update_date,
                    last_updated_by,
                    creation_date,
                    created_by,
                    last_update_login,
                    fm_serial_number,
                    to_serial_number,
                    attribute_category,
                    attribute1,
                    attribute2,
                    attribute3,
                    attribute4,
                    attribute5,
                    attribute6,
                    attribute7,
                    attribute8,
                    attribute9,
                    attribute10,
                    attribute11,
                    attribute12,
                    attribute13,
                    attribute14,
                    attribute15,
                    serial_attribute_category,
		    c_attribute1,
		    c_attribute2,
		    c_attribute3,
		    c_attribute4,
		    c_attribute5,
		    c_attribute6,
		    c_attribute7,
		    c_attribute8,
		    c_attribute9,
		    c_attribute10,
		    c_attribute11,
		    c_attribute12,
		    c_attribute13,
		    c_attribute14,
		    c_attribute15,
		    c_attribute16,
		    c_attribute17,
		    c_attribute18,
		    c_attribute19,
		    c_attribute20,
		    d_attribute1,
		    d_attribute2,
		    d_attribute3,
		    d_attribute4,
		    d_attribute5,
		    d_attribute6,
		    d_attribute7,
		    d_attribute8,
		    d_attribute9,
		    d_attribute10,
		    n_attribute1,
		    n_attribute2,
		    n_attribute3,
		    n_attribute4,
		    n_attribute5,
		    n_attribute6,
		    n_attribute7,
		    n_attribute8,
		    n_attribute9,
		    n_attribute10,
		    territory_code,
		    time_since_new,
		    cycles_since_new,
		    time_since_overhaul,
		    cycles_since_overhaul,
		    time_since_repair,
		    cycles_since_repair,
		    time_since_visit,
		    cycles_since_visit,
		    time_since_mark,
		    cycles_since_mark,
		    number_of_repairs
               )
               SELECT
                    l_serial_temp_id,
                    'RCV',
                    l_prod_txn_id,
                    sysdate,
                    wsn_rec.last_updated_by,
                    sysdate,
                    wsn_rec.created_by,
                    wsn_rec.last_update_login,
                    wsn_rec.fm_serial_number,
                    wsn_rec.to_serial_number,
                    wsn_rec.attribute_category,
                    wsn_rec.attribute1,
                    wsn_rec.attribute2,
                    wsn_rec.attribute3,
                    wsn_rec.attribute4,
                    wsn_rec.attribute5,
                    wsn_rec.attribute6,
                    wsn_rec.attribute7,
                    wsn_rec.attribute8,
                    wsn_rec.attribute9,
                    wsn_rec.attribute10,
                    wsn_rec.attribute11,
                    wsn_rec.attribute12,
                    wsn_rec.attribute13,
                    wsn_rec.attribute14,
                    wsn_rec.attribute15,
                    wsn_rec.serial_attribute_category,
		    wsn_rec.c_attribute1,
		    wsn_rec.c_attribute2,
		    wsn_rec.c_attribute3,
		    wsn_rec.c_attribute4,
		    wsn_rec.c_attribute5,
		    wsn_rec.c_attribute6,
		    wsn_rec.c_attribute7,
		    wsn_rec.c_attribute8,
		    wsn_rec.c_attribute9,
		    wsn_rec.c_attribute10,
		    wsn_rec.c_attribute11,
		    wsn_rec.c_attribute12,
		    wsn_rec.c_attribute13,
		    wsn_rec.c_attribute14,
		    wsn_rec.c_attribute15,
		    wsn_rec.c_attribute16,
		    wsn_rec.c_attribute17,
		    wsn_rec.c_attribute18,
		    wsn_rec.c_attribute19,
		    wsn_rec.c_attribute20,
		    wsn_rec.d_attribute1,
		    wsn_rec.d_attribute2,
		    wsn_rec.d_attribute3,
		    wsn_rec.d_attribute4,
		    wsn_rec.d_attribute5,
		    wsn_rec.d_attribute6,
		    wsn_rec.d_attribute7,
		    wsn_rec.d_attribute8,
		    wsn_rec.d_attribute9,
		    wsn_rec.d_attribute10,
		    wsn_rec.n_attribute1,
		    wsn_rec.n_attribute2,
		    wsn_rec.n_attribute3,
		    wsn_rec.n_attribute4,
		    wsn_rec.n_attribute5,
		    wsn_rec.n_attribute6,
		    wsn_rec.n_attribute7,
		    wsn_rec.n_attribute8,
		    wsn_rec.n_attribute9,
		    wsn_rec.n_attribute10,
		    wsn_rec.territory_code,
		    wsn_rec.time_since_new,
		    wsn_rec.cycles_since_new,
		    wsn_rec.time_since_overhaul,
		    wsn_rec.cycles_since_overhaul,
		    wsn_rec.time_since_repair,
		    wsn_rec.cycles_since_repair,
		    wsn_rec.time_since_visit,
		    wsn_rec.cycles_since_visit,
		    wsn_rec.time_since_mark,
		    wsn_rec.cycles_since_mark,
		    wsn_rec.number_of_repairs
               FROM dual;
               --
               l_serial_inserted := TRUE;
               IF (g_asn_debug = 'Y') THEN
                   asn_debug.put_line('Inserted MSNI : fm_serial_number : ' || wsn_rec.fm_serial_number || ' and to_serial_number : ' || wsn_rec.to_serial_number );
               END IF;

           END LOOP;
       END IF;
       --
       IF (l_lot_inserted AND l_serial_inserted) THEN
           UPDATE  mtl_transaction_lots_interface
           SET     serial_transaction_temp_id = l_serial_temp_id
           WHERE   transaction_interface_id = l_temp_id;
       END IF;
       --
       IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('Leaving load_lot_serial_interfaces');
       END IF;

  EXCEPTION
    WHEN OTHERS THEN
         IF (g_asn_debug = 'Y') THEN
             asn_debug.put_line('Unexpected exception in load_lot_serial_interfaces : ' || SQLERRM);
             raise;
         END IF;

  END load_lot_serial_interfaces;

/*===========================================================================

  PROCEDURE NAME:	perform_post_TM_updates ()

===========================================================================*/
  PROCEDURE perform_post_TM_updates
    (  p_TM_source          IN         VARCHAR2,
       p_delivery_id        IN         NUMBER) IS

    -- Cursor for picking successfully processed return RT lines
    CURSOR   wdd_rt_cursor IS
    SELECT   wdd.delivery_detail_id,
             wdd.inventory_item_id,
             wdd.shipped_quantity,
             wdd.requested_quantity_uom     shipped_uom_code,
             wdd.shipped_quantity2,
             wdd.requested_quantity_uom2    shipped_uom_code2,
             rti.interface_transaction_id   bkup_rti_id,
             rti.quantity                   bkup_rti_quantity,
             rti.unit_of_measure            bkup_rti_uom,
             rti.primary_unit_of_measure    bkup_rti_puom,
             rti.secondary_unit_of_measure  bkup_rti_suom,
             rti.source_doc_unit_of_measure bkup_rti_src_uom
    FROM     wsh_delivery_details       wdd,
             wsh_delivery_assignments   wda,
             rcv_transactions           rt,
             rcv_transactions_interface rti
    WHERE    wda.delivery_detail_id = wdd.delivery_detail_id
    AND      wda.delivery_id = p_delivery_id
    AND      wdd.source_code = 'RTV'
    AND      wdd.released_status = 'C'
    AND      wdd.inv_interfaced_flag <> 'Y'
    AND      wdd.container_flag = 'N'
    AND      wdd.delivery_detail_id = rt.interface_source_line_id
    AND      rt.transaction_type = 'RETURN TO VENDOR'
    AND      wdd.source_line_id = rti.interface_transaction_id
    AND      rti.processing_status_code = 'WSH_INTERFACED'
    ORDER BY bkup_rti_id, delivery_detail_id
    FOR UPDATE;


    -- Cursor for picking successfully issued out MMT lines
    CURSOR   wdd_mmt_cursor IS
    SELECT   wdd.delivery_detail_id,
             wdd.inventory_item_id,
             wdd.shipped_quantity,
             wdd.requested_quantity_uom     shipped_uom_code,
             wdd.shipped_quantity2,
             wdd.requested_quantity_uom2    shipped_uom_code2,
             rti.interface_transaction_id   bkup_rti_id,
             rti.quantity                   bkup_rti_quantity,
             rti.unit_of_measure            bkup_rti_uom,
             rti.primary_unit_of_measure    bkup_rti_puom,
             rti.secondary_unit_of_measure  bkup_rti_suom,
             rti.source_doc_unit_of_measure bkup_rti_src_uom
    FROM     wsh_delivery_details       wdd,
             wsh_delivery_assignments   wda,
             mtl_material_transactions  mmt,
             rcv_transactions_interface rti
    WHERE    wda.delivery_detail_id = wdd.delivery_detail_id
    AND      wda.delivery_id = p_delivery_id
    AND      wdd.source_code = 'RTV'
    AND      wdd.released_status = 'C'
    AND      wdd.inv_interfaced_flag <> 'Y'
    AND      wdd.container_flag = 'N'
    AND      wdd.delivery_detail_id = mmt.picking_line_id
    AND      wdd.source_line_id = rti.interface_transaction_id
    AND      rti.processing_status_code = 'WSH_INTERFACED'
    ORDER BY bkup_rti_id, delivery_detail_id
    FOR UPDATE;

    pre_rti_id  NUMBER   := NULL; --RTV project phase 2
    pre_rti_qty NUMBER   := NULL; --RTV project phase 2
  BEGIN
    IF (p_TM_source = 'RCV') THEN
        asn_debug.put_line('perform_post_TM_updates for returned RTs');
        FOR c_rec IN wdd_rt_cursor LOOP
            --RTV project phase 2 : start
            IF (c_rec.bkup_rti_id = pre_rti_id) THEN
                c_rec.bkup_rti_quantity := pre_rti_qty;
            END IF;
            --RTV project phase 2 : end
            adjust_rcv_quantities
              ( p_delivery_detail_id    => c_rec.delivery_detail_id,
                p_item_id               => c_rec.inventory_item_id,
                p_wdd_shipped_qty       => c_rec.shipped_quantity,
                p_wdd_shipped_uom_code  => c_rec.shipped_uom_code,
                p_wdd_shipped_qty2      => c_rec.shipped_quantity2,
                p_wdd_shipped_uom_code2 => c_rec.shipped_uom_code2,
                p_bkup_rti_id           => c_rec.bkup_rti_id,
                p_bkup_rti_quantity     => c_rec.bkup_rti_quantity,
                p_bkup_rti_uom          => c_rec.bkup_rti_uom,
                p_bkup_rti_puom         => c_rec.bkup_rti_puom,
                p_bkup_rti_suom         => c_rec.bkup_rti_suom,
                p_bkup_rti_src_uom      => c_rec.bkup_rti_src_uom);
             pre_rti_id  := c_rec.bkup_rti_id;       --RTV project phase 2
             pre_rti_qty := c_rec.bkup_rti_quantity; --RTV project phase 2
        END LOOP;

    ELSIF (p_TM_source = 'INV') THEN
        asn_debug.put_line('perform_post_TM_updates for issued out MMTs');
        FOR c_rec IN wdd_mmt_cursor LOOP
            --RTV project phase 2 : start
            IF (c_rec.bkup_rti_id = pre_rti_id) THEN
                c_rec.bkup_rti_quantity := pre_rti_qty;
            END IF;
            --RTV project phase 2 : end
            adjust_rcv_quantities
              ( p_delivery_detail_id    => c_rec.delivery_detail_id,
                p_item_id               => c_rec.inventory_item_id,
                p_wdd_shipped_qty       => c_rec.shipped_quantity,
                p_wdd_shipped_uom_code  => c_rec.shipped_uom_code,
                p_wdd_shipped_qty2      => c_rec.shipped_quantity2,
                p_wdd_shipped_uom_code2 => c_rec.shipped_uom_code2,
                p_bkup_rti_id           => c_rec.bkup_rti_id,
                p_bkup_rti_quantity     => c_rec.bkup_rti_quantity,
                p_bkup_rti_uom          => c_rec.bkup_rti_uom,
                p_bkup_rti_puom         => c_rec.bkup_rti_puom,
                p_bkup_rti_suom         => c_rec.bkup_rti_suom,
                p_bkup_rti_src_uom      => c_rec.bkup_rti_src_uom);
             pre_rti_id  := c_rec.bkup_rti_id;       --RTV project phase 2
             pre_rti_qty := c_rec.bkup_rti_quantity; --RTV project phase 2
        END LOOP;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
         IF (g_asn_debug = 'Y') THEN
             asn_debug.put_line('Unexpected exception in adjust_lot_data : ' || SQLERRM);
             raise;
         END IF;
  END perform_post_TM_updates;

/*===========================================================================

  PROCEDURE NAME:	adjust_rcv_quantities ()

===========================================================================*/
  PROCEDURE adjust_rcv_quantities
    (  p_delivery_detail_id    IN            NUMBER   ,
       p_item_id               IN            NUMBER   ,
       p_wdd_shipped_qty       IN            NUMBER   ,
       p_wdd_shipped_uom_code  IN            VARCHAR2 ,
       p_wdd_shipped_qty2      IN            NUMBER   ,
       p_wdd_shipped_uom_code2 IN            VARCHAR2 ,
       p_bkup_rti_id           IN            NUMBER   ,
       p_bkup_rti_quantity     IN OUT NOCOPY NUMBER   , --RTV project phase 2
       p_bkup_rti_uom          IN            VARCHAR2 ,
       p_bkup_rti_puom         IN            VARCHAR2 ,
       p_bkup_rti_suom         IN            VARCHAR2 ,
       p_bkup_rti_src_uom      IN            VARCHAR2 ) IS


  l_shipped_uom      mtl_units_of_measure.unit_of_measure%TYPE;
  l_shipped_sec_uom  mtl_units_of_measure.unit_of_measure%TYPE;
  l_txn_qty          NUMBER;
  l_shipped_qty      NUMBER;
  l_shipped_qty2     NUMBER := 0;
  l_primary_qty      NUMBER;
  l_src_uom_qty      NUMBER := NULL;
  e_Overship_Error   EXCEPTION;

  BEGIN
      --
      IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('p_delivery_detail_id    : ' || p_delivery_detail_id);
          asn_debug.put_line('p_item_id               : ' || p_item_id);
          asn_debug.put_line('p_wdd_shipped_qty       : ' || p_wdd_shipped_qty);
          asn_debug.put_line('p_wdd_shipped_uom_code  : ' || p_wdd_shipped_uom_code);
          asn_debug.put_line('p_wdd_shipped_uom_code2 : ' || p_wdd_shipped_uom_code2);
          asn_debug.put_line('p_bkup_rti_id           : ' || p_bkup_rti_id);
          asn_debug.put_line('p_bkup_rti_quantity     : ' || p_bkup_rti_quantity);
          asn_debug.put_line('p_bkup_rti_uom          : ' || p_bkup_rti_uom);
          asn_debug.put_line('p_bkup_rti_puom         : ' || p_bkup_rti_puom);
          asn_debug.put_line('p_bkup_rti_suom         : ' || p_bkup_rti_suom);
          asn_debug.put_line('p_bkup_rti_src_uom      : ' || p_bkup_rti_src_uom);
      END IF;
      --
      l_shipped_uom := get_uom_from_code (p_wdd_shipped_uom_code);
      IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('l_shipped_uom : ' || l_shipped_uom);
      END IF;
      --
      IF (l_shipped_uom <> p_bkup_rti_uom) THEN
          po_uom_s.uom_convert
              ( from_quantity => p_wdd_shipped_qty,
                from_uom      => l_shipped_uom,
                item_id       => p_item_id,
                to_uom        => p_bkup_rti_uom,
                to_quantity   => l_shipped_qty);
      ELSE
          l_shipped_qty := p_wdd_shipped_qty;
      END IF;

      l_txn_qty := p_bkup_rti_quantity - l_shipped_qty;
      p_bkup_rti_quantity :=  l_txn_qty;                --RTV project phase 2

      IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('l_shipped_qty : ' || l_shipped_qty);
          asn_debug.put_line('l_txn_qty     : ' || l_txn_qty);
      END IF;
      --
      IF (l_txn_qty > 0) THEN

          IF (l_shipped_uom <> p_bkup_rti_puom) THEN
              po_uom_s.uom_convert
                 ( from_quantity => p_wdd_shipped_qty,
                   from_uom      => l_shipped_uom,
                   item_id       => p_item_id,
                   to_uom        => p_bkup_rti_puom,
                   to_quantity   => l_primary_qty);
          ELSE
                   l_primary_qty :=  p_wdd_shipped_qty;
          END IF;
          IF (g_asn_debug = 'Y') THEN
              asn_debug.put_line('p_bkup_rti_puom : ' || p_bkup_rti_puom);
              asn_debug.put_line('l_primary_qty   : ' || l_primary_qty);
          END IF;
          --
          l_shipped_sec_uom := get_uom_from_code (p_wdd_shipped_uom_code2);
          IF (g_asn_debug = 'Y') THEN
              asn_debug.put_line('l_shipped_sec_uom  : ' || l_shipped_sec_uom);
          END IF;

          IF (p_bkup_rti_suom IS NOT NULL) THEN
              IF (l_shipped_sec_uom <> p_bkup_rti_suom) THEN
                  po_uom_s.uom_convert
                     ( from_quantity => p_wdd_shipped_qty2,
                       from_uom      => l_shipped_sec_uom,
                       item_id       => p_item_id,
                       to_uom        => p_bkup_rti_suom,
                       to_quantity   => l_shipped_qty2);
              ELSE
                     l_shipped_qty2 := p_wdd_shipped_qty2;
              END IF;
          END IF;

          IF (g_asn_debug = 'Y') THEN
              asn_debug.put_line('p_bkup_rti_suom : ' || p_bkup_rti_suom);
              asn_debug.put_line('l_shipped_qty2  : ' || l_shipped_qty2);
          END IF;
          --
          IF (p_bkup_rti_src_uom IS NOT NULL) THEN
             IF (nvl(p_bkup_rti_uom, -99) <> nvl(p_bkup_rti_src_uom,-99)) THEN
                 po_uom_s.uom_convert
                    ( from_quantity => l_txn_qty,
                      from_uom      => p_bkup_rti_uom,
                      item_id       => p_item_id,
                      to_uom        => p_bkup_rti_src_uom,
                      to_quantity   => l_src_uom_qty);
             ELSE
                      l_src_uom_qty := l_txn_qty;
             END IF;
          END IF;

          IF (g_asn_debug = 'Y') THEN
              asn_debug.put_line('l_src_uom_qty   : ' || l_src_uom_qty);
          END IF;
          --
          UPDATE  rcv_transactions_interface
          SET     quantity            = l_txn_qty,
                  secondary_quantity  = secondary_quantity - l_shipped_qty2,
                  primary_quantity    = primary_quantity - l_primary_qty,
                  source_doc_quantity = l_src_uom_qty
          WHERE   interface_transaction_id = p_bkup_rti_id;

      ELSIF (l_txn_qty = 0) THEN
             --RTV project phase 2 : start
             --move original code into a new private procedure,as cancellation also use that.
             remove_RTV_order(p_bkup_rti_id);
             --RTV project phase 2 : end
      ELSE
            raise e_Overship_Error;
      END IF;
      --
  EXCEPTION
    WHEN e_Overship_Error  THEN
         IF (g_asn_debug = 'Y') THEN
             asn_debug.put_line('Overship error');
             raise;
         END IF;
    WHEN OTHERS THEN
         IF (g_asn_debug = 'Y') THEN
             asn_debug.put_line('Unexpected exception in adjust_lot_data : ' || SQLERRM);
             raise;
         END IF;
  END adjust_rcv_quantities;

/*===========================================================================

  PROCEDURE NAME:	clean_up_after_rtp ()

===========================================================================*/
  PROCEDURE clean_up_after_rtp
    (  p_delivery_id         IN         NUMBER,
       p_group_id            IN         NUMBER) IS

  BEGIN

      -- Deleting errored RTI/MSNI/MTLI
      BEGIN
        DELETE FROM mtl_serial_numbers_interface
        WHERE  product_transaction_id IN
               (SELECT interface_transaction_id
                FROM   rcv_transactions_interface
                WHERE  group_id = p_group_id
                AND    processing_mode_code = 'ONLINE');

      EXCEPTION
        WHEN OTHERS THEN NULL;
      END;
      asn_debug.put_line('After deleting MSNI : count = ' || sql%rowcount);
      --
      BEGIN
        DELETE FROM mtl_transaction_lots_interface
        WHERE  product_transaction_id IN
               (SELECT interface_transaction_id
                FROM   rcv_transactions_interface
                WHERE  group_id = p_group_id
                AND    processing_mode_code = 'ONLINE');

      EXCEPTION
        WHEN OTHERS THEN NULL;
      END;
      asn_debug.put_line('After deleting MTLI : count = ' || sql%rowcount);
      --
      DELETE FROM rcv_transactions_interface
      WHERE  group_id = p_group_id
      AND    processing_mode_code = 'ONLINE';
      asn_debug.put_line('After deleting RTI : count = ' || sql%rowcount);
      --
  EXCEPTION
    WHEN OTHERS THEN
         IF (g_asn_debug = 'Y') THEN
             asn_debug.put_line('Unexpected exception in clean_up_after_rtp : ' || SQLERRM);
             raise;
         END IF;
  END clean_up_after_rtp;

/*===========================================================================

  PROCEDURE NAME:	cancel_rtv_lines ()

===========================================================================*/
  PROCEDURE cancel_rtv_lines
    (  p_rti_id_tbl          IN         RCV_WSH_INTERFACE_PKG.RTI_id_tbl ) IS

  l_changed_attributes      WSH_INTERFACE.ChangedAttributeTabType;
  l_wdd_cancel_qty          NUMBER;
  l_return_status           VARCHAR2(1);
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);
  l_source_header_id        NUMBER;
  l_item_id                 NUMBER;
  l_rti_qty                 NUMBER;
  l_rti_uom                 VARCHAR2(25);
  l_rti_puom                VARCHAR2(25);
  l_rti_suom                VARCHAR2(25);
  l_rti_src_uom             VARCHAR2(25);
  l_wdd_uom_code            VARCHAR2(3);
  l_wdd_uom                 VARCHAR2(25);
  l_rti_cancel_qty          NUMBER;
  l_rti_new_qty             NUMBER;
  l_rti_new_pqty            NUMBER := NULL;
  l_rti_new_sqty            NUMBER := NULL;
  l_rti_new_src_qty         NUMBER := NULL;
  e_cancel_error1           EXCEPTION; -- Bug 10089980
  e_cancel_error2           EXCEPTION; -- Bug 10089980
  e_cancel_MR_error         EXCEPTION; -- RTV2 rtv project phase 2
  e_cancel_lpn_wdd_error    EXCEPTION; -- RTV2 rtv project phase 2
  e_cancel_unmark_lpn_error EXCEPTION; -- RTV2 rtv project phase 2

  CURSOR cancelled_wdd_cur (p_src_line_id NUMBER) IS
  SELECT *
  FROM   wsh_delivery_details
  WHERE  source_code = 'RTV'
  AND    source_line_id = p_src_line_id
  AND    released_status = 'D'
  AND    container_flag = 'N';

  -- RTV2 rtv project phase 2 : start
  CURSOR cancelled_lpn_cur (p_src_line_id NUMBER) IS
  SELECT distinct wdd1.lpn_id,
                  wdd2.delivery_detail_id,
                  wdd1.delivery_detail_id lpn_wdd_id
  FROM   wsh_delivery_details wdd1,
         wsh_delivery_Details wdd2,
         wsh_delivery_assignments wda
  WHERE  wdd2.source_code = 'RTV'
  AND    wdd2.source_line_id = p_src_line_id
  AND    wdd1.container_flag = 'Y'
  AND    wdd1.lpn_id is not null
  AND    wdd2.container_flag = 'N'
  AND    wdd1.delivery_detail_id = wda.parent_delivery_detail_id
  AND    wdd2.delivery_detail_id = wda.delivery_detail_id
  ORDER BY lpn_wdd_id;

  TYPE content_wdd_lpns     IS TABLE OF cancelled_lpn_cur%ROWTYPE INDEX BY BINARY_INTEGER;
  l_wdd_lpns                content_wdd_lpns;
  l_lpn_id                  NUMBER := NULL;
  l_transfer_lpn_id         NUMBER := NULL;
  l_count                   NUMBER;
  -- RTV2 rtv project phase 2 : end

  BEGIN
    IF (g_asn_debug = 'Y') THEN
        asn_debug.put_line('Entering cancel_rtv_lines');
    END IF;

    FOR i IN 1 .. p_rti_id_tbl.COUNT LOOP
        wsh_integration.get_cancel_qty_allowed
                  ( p_source_code         => 'RTV',
                    p_source_line_id      => p_rti_id_tbl(i),
                    x_cancel_qty_allowed  => l_wdd_cancel_qty,
                    x_return_status       => l_return_status,
                    x_msg_count           => l_msg_count,
                    x_msg_data            => l_msg_data );

        IF l_return_status = 'S' THEN
           IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('l_wdd_cancel_qty     : ' || l_wdd_cancel_qty);
           END IF;

           IF l_wdd_cancel_qty > 0 THEN
              SELECT item_id,
                     quantity,
                     unit_of_measure,
                     primary_unit_of_measure,
                     secondary_unit_of_measure,
                     source_doc_unit_of_measure,
                     transfer_lpn_id    -- RTV2 rtv project phase 2
              INTO   l_item_id,
                     l_rti_qty,
                     l_rti_uom,
                     l_rti_puom,
                     l_rti_suom,
                     l_rti_src_uom,
                     l_transfer_lpn_id   -- RTV2 rtv project phase 2
              FROM   rcv_transactions_interface
              WHERE  interface_transaction_id = p_rti_id_tbl(i)
              AND    transaction_type = 'RETURN TO VENDOR';

              SELECT max(source_header_id), max(requested_quantity_uom)
              INTO   l_source_header_id,
                     l_wdd_uom_code
              FROM   wsh_delivery_details
              WHERE  source_line_id = p_rti_id_tbl(i)
              AND    source_code = 'RTV';

              IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('l_item_id          : ' || l_item_id);
                  asn_debug.put_line('l_rti_qty          : ' || l_rti_qty );
                  asn_debug.put_line('l_rti_uom          : ' || l_rti_uom);
                  asn_debug.put_line('l_rti_puom         : ' || l_rti_puom);
                  asn_debug.put_line('l_rti_suom         : ' || l_rti_suom);
                  asn_debug.put_line('l_rti_src_uom      : ' || l_rti_src_uom);
                  asn_debug.put_line('l_source_header_id : ' || l_source_header_id);
                  asn_debug.put_line('l_wdd_uom_code     : ' || l_wdd_uom_code);
              END IF;

              l_wdd_uom := get_uom_from_code (l_wdd_uom_code);

              IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('l_wdd_uom          : ' || l_wdd_uom);
              END IF;

              l_changed_attributes(1).source_code        := 'RTV';
              l_changed_attributes(1).source_header_id   := l_source_header_id;
              l_changed_attributes(1).source_line_id     := p_rti_id_tbl(i);
              l_changed_attributes(1).ordered_quantity   := 0;
              l_changed_attributes(1).order_quantity_uom := l_wdd_uom_code;
              l_changed_attributes(1).shipped_flag       := 'N';
              l_changed_attributes(1).action_flag        := 'U';

              --RTV2 rtv project phase 2 : start
              --Before cancelling , keep association between content wdd and lpns.
              IF (l_transfer_lpn_id IS NOT NULL) THEN
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('open cursor cancelled_lpn_cur before cancellation. ' );
                END IF;
                OPEN  cancelled_lpn_cur(p_rti_id_tbl(i));
                FETCH cancelled_lpn_cur BULK COLLECT INTO l_wdd_lpns;
                CLOSE cancelled_lpn_cur;
              END IF;
              --RTV2 rtv project phase 2 : end


              WSH_INTERFACE.Update_Shipping_Attributes
               ( p_source_code         => 'RTV',
                 p_changed_attributes  => l_changed_attributes,
                 x_return_status       => l_return_status);

              IF (l_return_status = 'S') THEN
                 --
                 FOR wdd_rec IN cancelled_wdd_cur (p_rti_id_tbl(i)) LOOP
                     wdd_rec.shipped_quantity := wdd_rec.cancelled_quantity;
                     wdd_rec.lot_number       := wdd_rec.original_lot_number;
                     wdd_rec.subinventory     := wdd_rec.original_subinventory;
                     wdd_rec.locator_id       := wdd_rec.original_locator_id;
                     wdd_rec.revision         := wdd_rec.original_revision;

                     --RTV2 rtv project phase 2 : start
                     l_lpn_id := null;
                     IF(l_transfer_lpn_id IS NOT NULL) THEN
                        FOR indx IN 1 .. l_wdd_lpns.COUNT LOOP
                            IF( wdd_rec.delivery_detail_id = l_wdd_lpns(indx).delivery_detail_id ) THEN
                            	  l_lpn_id      := l_wdd_lpns(indx).lpn_id;
                                IF (g_asn_debug = 'Y') THEN
                                    asn_debug.put_line('before calling wms_return_sv.unmark_returns for lpn_id:'|| l_lpn_id);
                                END IF;
                                --we should pass lpn_id here, since we are not able to fetch lpn_id
                                --from wsh_delivery_assignments
                                unmark_wdd_lpn(p_wdd_rec          => wdd_rec,
                                               p_lpn_id           => l_lpn_id,
                                               x_return_status    => l_return_status,
                                               x_msg_count        => l_msg_count,
                                               x_msg_data         => l_msg_data);
                                IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                                    raise e_cancel_unmark_lpn_error;
                                END IF;
                                --check if relevant contaienr wdd  is fully cancelled , if yes, delete it.
                                SELECT count(1)
                                INTO   l_count
                                FROM   wsh_delivery_assignments
                                WHERE  parent_delivery_detail_id = l_wdd_lpns(indx).lpn_wdd_id;
                                IF( l_count = 0 ) THEN
                                    IF (g_asn_debug = 'Y') THEN
                                        asn_debug.put_line('before deleting container wdd :'||l_wdd_lpns(indx).lpn_wdd_id);
                                    END IF;
                                    wsh_container_actions.delete_containers
                                      (p_container_id     => l_wdd_lpns(indx).lpn_wdd_id,
                                       x_return_status    => l_return_status);
                                    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                                        raise e_cancel_lpn_wdd_error;
                                    END IF;
                                END IF;
                            	  EXIT;
                            END IF;
                        END LOOP;
                     END IF;
                     --we should pass lpn_id here, since we are not able to fetch lpn_id
                     --from wsh_delivery_assignments
                     relieve_return_reservation(p_wdd_rec          => wdd_rec,
                                                p_lpn_id           => l_lpn_id,
                                                x_return_status    => l_return_status,
                                                x_msg_count        => l_msg_count,
                                                x_msg_data         => l_msg_data);
                     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                         raise e_cancel_MR_error;
                     END IF;
                     --RTV2 rtv project phase 2 : end
                 END LOOP;
                 IF (g_asn_debug = 'Y') THEN
                     asn_debug.put_line('After relieve_return_reservation Loop');
                 END IF;
                 --
                 IF (l_rti_uom <> l_wdd_uom) THEN
                     po_uom_s.uom_convert
                       ( from_quantity => l_wdd_cancel_qty,
                         from_uom      => l_wdd_uom,
                         item_id       => l_item_id,
                         to_uom        => l_rti_uom,
                         to_quantity   => l_rti_cancel_qty);
                 ELSE
                     l_rti_cancel_qty := l_wdd_cancel_qty;
                 END IF;

                 l_rti_new_qty := l_rti_qty - l_rti_cancel_qty;
                 IF (g_asn_debug = 'Y') THEN
                     asn_debug.put_line('l_rti_new_qty       : ' || l_rti_new_qty);
                 END IF;
                 --
                 IF (l_rti_new_qty > 0) THEN
                     --
                     IF (l_rti_uom <> l_rti_puom) THEN
                         po_uom_s.uom_convert
                           ( from_quantity => l_rti_new_qty,
                             from_uom      => l_rti_uom,
                             item_id       => l_item_id,
                             to_uom        => l_rti_puom,
                             to_quantity   => l_rti_new_pqty);
                     ELSE
                         l_rti_new_pqty := l_rti_new_qty;
                     END IF;

                     IF (g_asn_debug = 'Y') THEN
                         asn_debug.put_line('l_rti_new_pqty      : ' || l_rti_new_pqty);
                     END IF;
                     --
                     IF (l_rti_suom IS NOT NULL) THEN
                         IF (l_rti_uom <> l_rti_suom) THEN
                             po_uom_s.uom_convert
                               ( from_quantity => l_rti_new_qty,
                                 from_uom      => l_rti_uom,
                                 item_id       => l_item_id,
                                 to_uom        => l_rti_suom,
                                 to_quantity   => l_rti_new_sqty);
                         ELSE
                               l_rti_new_sqty := l_rti_new_qty;
                         END IF;
                     END IF;

                     IF (g_asn_debug = 'Y') THEN
                         asn_debug.put_line('l_rti_new_sqty      : ' || l_rti_new_sqty);
                     END IF;
                     --
                     IF (l_rti_src_uom IS NOT NULL) THEN

                         IF (l_rti_uom <> l_rti_src_uom) THEN
                             po_uom_s.uom_convert
                               ( from_quantity => l_rti_new_qty,
                                 from_uom      => l_rti_uom,
                                 item_id       => l_item_id,
                                 to_uom        => l_rti_src_uom,
                                 to_quantity   => l_rti_new_src_qty);
                         ELSE
                             l_rti_new_src_qty := l_rti_new_qty;
                         END IF;
                     END IF;

                     IF (g_asn_debug = 'Y') THEN
                         asn_debug.put_line('l_rti_new_src_qty   : ' || l_rti_new_src_qty);
                     END IF;
                     --
                     UPDATE rcv_transactions_interface
                     SET    quantity            = l_rti_new_qty,
                            primary_quantity    = l_rti_new_pqty,
                            secondary_quantity  = l_rti_new_sqty,
                            source_doc_quantity = l_rti_new_src_qty
                     WHERE  interface_transaction_id = p_rti_id_tbl(i);
                 ELSE
                     --RTV project phase 2 : start
                     --call remove_RTV_order() instead of delete RTI directly, as we also need to handle
                     --serial and lot interface tables.
                     --DELETE FROM rcv_transactions_interface
                     --WHERE  interface_transaction_id = p_rti_id_tbl(i);
                     remove_RTV_order(p_rti_id_tbl(i));
                     --RTV project phase 2 : end
                 END IF;
                 --
              ELSE
                 raise e_cancel_error2; -- Bug 10089980
              END IF;
           END IF;
        ELSE
           raise e_cancel_error1; -- Bug 10089980
        END IF;

    END LOOP;

    IF (g_asn_debug = 'Y') THEN
        asn_debug.put_line('Leaving cancel_rtv_line');
    END IF;

  EXCEPTION
    -- Bug 10089980 : Start
    WHEN e_cancel_error1 THEN
         IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('wsh_integration.get_cancel_qty_allowed returned error!');
         END IF;
         l_msg_data := fnd_msg_pub.get (1, 'F');
         po_message_s.sql_error('wsh_integration.get_cancel_qty_allowed', l_msg_data, sqlcode);
         raise fnd_api.g_exc_error;

    WHEN e_cancel_error2 THEN
         IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('wsh_interface.update_shipping_attributes returned error!');
         END IF;
         fnd_msg_pub.count_and_get (p_encoded      => 'T',
                                    p_count        => l_msg_count,
                                    p_data         => l_msg_data
                                    );

         FOR x IN 1 .. l_msg_count LOOP
             l_msg_data := fnd_msg_pub.get (x, 'F');
         END LOOP;

         po_message_s.sql_error('wsh_interface.update_shipping_attributes', l_msg_data, sqlcode);
         raise fnd_api.g_exc_error;
    -- Bug 10089980 : End

    WHEN e_cancel_MR_error THEN
         IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('inv_trx_relief_c_pvt.rsv_relief returned error!');
         END IF;
         fnd_msg_pub.count_and_get (p_encoded      => 'T',
                                    p_count        => l_msg_count,
                                    p_data         => l_msg_data
                                    );

         FOR x IN 1 .. l_msg_count LOOP
             l_msg_data := fnd_msg_pub.get (x, 'F');
         END LOOP;

         po_message_s.sql_error('rcv_wsh_interface_pkg.cancel_rtv_lines', l_msg_data, sqlcode);
         raise fnd_api.g_exc_error;

    WHEN e_cancel_unmark_lpn_error THEN
         IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('wms_return_sv.unmark_returns returned error!');
         END IF;
         fnd_msg_pub.count_and_get (p_encoded      => 'T',
                                    p_count        => l_msg_count,
                                    p_data         => l_msg_data
                                    );

         FOR x IN 1 .. l_msg_count LOOP
             l_msg_data := fnd_msg_pub.get (x, 'F');
         END LOOP;

         po_message_s.sql_error('rcv_wsh_interface_pkg.cancel_rtv_lines', l_msg_data, sqlcode);
         raise fnd_api.g_exc_error;

    WHEN e_cancel_lpn_wdd_error THEN
         IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('whs_container_actions.delete_containers returned error!');
         END IF;
         l_msg_data := fnd_msg_pub.get (1, 'F');
         po_message_s.sql_error('rcv_wsh_interface_pkg.cancel_rtv_lines', l_msg_data, sqlcode);
         raise fnd_api.g_exc_error;

    WHEN OTHERS THEN
         IF (g_asn_debug = 'Y') THEN
             asn_debug.put_line('Unexpected exception in cancel_rtv_lines : ' || SQLERRM);
         END IF;
         po_message_s.sql_error('rcv_wsh_interface_pkg.cancel_rtv_lines', 'Unexpected exception', sqlcode);
         raise fnd_api.g_exc_unexpected_error;
  END cancel_rtv_lines;

END RCV_WSH_INTERFACE_PKG;

/
