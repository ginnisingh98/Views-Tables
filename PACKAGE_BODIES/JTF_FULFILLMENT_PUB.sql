--------------------------------------------------------
--  DDL for Package Body JTF_FULFILLMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_FULFILLMENT_PUB" AS
/* $Header: jtfgfmpb.pls 120.0 2005/05/11 08:14:40 appldev ship $ */
------------------------------------------------------------------
--             Copyright (c) 1999 Oracle Corporation            --
--                Redwood Shores, California, USA               --
--                     All rights reserved.                     --
------------------------------------------------------------------
-- PACKAGE
--    JTF_Fulfillment_PUB
--
-- PURPOSE
--    Private API for Physical fulfillment.
--
-- HISTORY

-- PROCEDURE
--   create_fulfill_physical
--
-- PURPOSE
--    This procedure inserts physical fulfillment.
--
-- PARAMETERS
--
-- DESCRIPTION
--  This procedure create one order for physical fulfillment
--  and insert into JTF_FM_request_history. Then inserts info of each deliverable
--  into JTF_FM_request_content. One order can have multiple collaterals.

------------------------------------------------------------
g_pkg_name   CONSTANT VARCHAR2(30):='JTF_Fulfillment_PUB';


PROCEDURE  create_fulfill_physical
(
  p_init_msg_list         IN   VARCHAR2
 ,p_api_version           IN   NUMBER
 ,p_commit                IN   VARCHAR2
 ,x_return_status         OUT NOCOPY VARCHAR2
 ,x_msg_count             OUT NOCOPY NUMBER
 ,x_msg_data              OUT NOCOPY VARCHAR2
 ,p_order_header_rec      IN   ORDER_HEADER_REC_TYPE
 ,p_order_line_tbl        IN   ORDER_LINE_TBL_TYPE
 ,x_order_header_rec      OUT NOCOPY ASO_ORDER_INT.order_header_rec_type
 ,x_request_history_id    OUT NOCOPY  NUMBER
)
IS

  l_qte_header_rec       ASO_QUOTE_PUB.Qte_Header_Rec_Type :=ASO_QUOTE_PUB.G_MISS_QTE_HEADER_REC;
  l_qte_line_tbl         ASO_QUOTE_PUB.Qte_Line_Tbl_Type   := ASO_QUOTE_PUB.G_MISS_QTE_LINE_TBL;
  l_hd_shipment_tbl      ASO_QUOTE_PUB.Shipment_tbl_Type   := ASO_QUOTE_PUB.G_MISS_Shipment_TBL;
  l_ln_shipment_tbl      ASO_QUOTE_PUB.Shipment_tbl_Type   := ASO_QUOTE_PUB.G_MISS_Shipment_TBL;

  l_request_history_rec  JTF_Request_History_PVT.request_history_rec_type;

   l_control_rec          ASO_ORDER_INT.control_rec_type;

   x_order_line_tbl       ASO_ORDER_INT.Order_Line_tbl_type;

-- Assuming a valid collateral ID is passed
-----Collateral existing in the OM's inventory organization
-----Collateral has a inventory item created for it.
-----Collateral is available and active
-----Is a physical collateral

-- Kit containing Kits is not supported.
-- Only physical collaterals which are not kits with an  inventory_item_id are picked for
-- the original kit.

  CURSOR cur_get_collateral_items(p_collateral_id NUMBER) IS
  SELECT delv.INVENTORY_ITEM_ID
   FROM ams_deliverables_all_b delv
  WHERE delv.deliverable_id = p_collateral_id
  UNION
  SELECT delv.INVENTORY_ITEM_ID
  FROM ams_deliverables_all_b delv,
       mtl_system_items_b msi
  WHERE delv.deliverable_id in (select deliverable_kit_part_id
                             FROM ams_deliv_kit_items
                            WHERE deliverable_kit_id = p_collateral_id)
    AND delv.inventory_item_id is not null
    AND nvl(delv.kit_flag,'N')='N'
    AND delv.status_code='AVAILABLE'
    AND delv.active_flag = 'Y'
    AND delv.can_fulfill_physical_flag = 'Y'
    AND delv.actual_avail_to_date > sysdate
    AND msi.inventory_item_id = delv.inventory_item_id
    AND msi.organization_id   = p_order_header_rec.inv_organization_id
    and msi.customer_order_flag = 'Y'
    and msi.shippable_item_flag = 'Y';

  line_index number := 0;
  shipment_index number := 0;

  CURSOR cur_get_primary_uom (p_item_id NUMBER) IS
  SELECT msi.primary_uom_code
    FROM mtl_system_items_b msi
   WHERE msi.inventory_item_id = p_item_id
     AND msi.organization_id = p_order_header_rec.inv_organization_id;

BEGIN

   SAVEPOINT  fulfill_collateral_request;

   l_control_rec.book_flag := FND_API.G_TRUE;
   l_control_rec.calculate_price := FND_API.G_FALSE;

   FND_MSG_PUB.Initialize;

 -- Process Order Header

    l_qte_header_rec.party_id           := p_order_header_rec.cust_party_id;
    l_qte_header_rec.quote_source_code  := p_order_header_rec.quote_source_code;

    IF p_order_header_rec.cust_account_id IS NOT NULL THEN
     l_qte_header_rec.cust_account_id    := p_order_header_rec.cust_account_id;
    END IF;

    IF p_order_header_rec.sold_to_contact_id IS NOT NULL THEN
      l_qte_header_rec.org_contact_id := p_order_header_rec.sold_to_contact_id;
    END IF;

    l_qte_header_rec.invoice_to_party_id := p_order_header_rec.inv_party_id;
    l_qte_header_rec.invoice_to_party_site_id := p_order_header_rec.inv_party_site_id;
    l_qte_header_rec.order_type_id := fnd_profile.value('AMS_ORDER_TYPE');
    l_qte_header_rec.marketing_source_code_id := p_order_header_rec.marketing_source_code_id;
    l_qte_header_rec.employee_person_id := p_order_header_rec.employee_id;

-- Process Order Header Shipment information

    l_hd_shipment_tbl(1).ship_to_party_site_id := p_order_header_rec.ship_party_site_id;


  -- Process Order Lines
 FOR coll_rec IN cur_get_collateral_items(p_order_header_rec.collateral_id) LOOP
   IF coll_rec.inventory_item_id is NOT NULL THEN
     line_index := line_index + 1;
     l_qte_line_tbl(line_index).inventory_item_id := coll_rec.inventory_item_id;
     l_qte_line_tbl(line_index).line_quote_price := 0;
     l_qte_line_tbl(line_index).line_list_price := 0;

     OPEN cur_get_primary_uom(coll_rec.inventory_item_id);
     FETCH cur_get_primary_uom INTO l_qte_line_tbl(line_index).UOM_code;
     CLOSE cur_get_primary_uom;

     l_qte_line_tbl(line_index).line_category_code := p_order_header_rec.line_category_code;

   -- Process Shipment information for each order line
   FOR i IN P_ORDER_LINE_TBL.first..P_ORDER_LINE_TBL.last LOOP

     IF p_order_line_tbl.exists(i) THEN
      shipment_index := shipment_index + 1;
      l_ln_shipment_tbl(shipment_index).qte_line_index := line_index;
      l_ln_shipment_tbl(shipment_index).quantity := p_order_line_tbl(i).quantity;
      l_ln_shipment_tbl(shipment_index).ship_to_party_id := p_order_line_tbl(i).ship_party_id;
      l_ln_shipment_tbl(shipment_index).ship_to_party_site_id := p_order_line_tbl(i).ship_party_site_id;
      l_ln_shipment_tbl(shipment_index).ship_method_code := p_order_line_tbl(i).ship_method_code;

    END IF;

   END LOOP;
  END IF;
 END LOOP;

      ASO_ORDER_INT.create_order(
        p_api_version_number          => 1.0
       ,p_init_msg_list               => FND_API.g_false
       ,p_commit                      => FND_API.g_false
       ,p_qte_rec                     => l_qte_header_rec
       ,p_qte_line_tbl                => l_qte_line_tbl
       ,p_header_shipment_tbl         => l_hd_shipment_tbl
       ,p_line_shipment_tbl           => l_ln_shipment_tbl
       ,p_control_rec                 => l_control_rec
       ,x_order_header_rec            => x_order_header_rec
       ,x_order_line_tbl              => x_order_line_tbl
       ,x_return_status               => x_return_status
       ,x_msg_count                   => x_msg_count
       ,x_msg_data                    => x_msg_data
      );

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN





    l_request_history_rec.app_info := 690;
    l_request_history_rec.order_id := x_order_header_rec.order_header_id;

    JTF_Request_History_PVT.Create_Request_History(
      p_api_version_number  => p_api_version,
      p_init_msg_list       => p_init_msg_list,
      p_commit              => p_commit,
      p_validation_level    => 1,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data,
      p_request_history_rec => l_request_history_rec,
      x_request_history_id  => x_request_history_id
    );




     IF p_commit = Fnd_Api.g_true THEN
       COMMIT WORK;
     END IF;
   ELSIF x_return_status = Fnd_Api.g_ret_sts_error THEN
     RAISE Fnd_Api.G_EXC_ERROR;
   ELSE
     RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;
 EXCEPTION
 WHEN Fnd_Api.G_EXC_ERROR THEN
      x_return_status := Fnd_Api.g_ret_sts_error ;
      ROLLBACK TO fulfill_collateral_request;
 WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
     ROLLBACK TO fulfill_collateral_request;
 WHEN OTHERS THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_erroR ;
     ROLLBACK TO fulfill_collateral_request;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( 'JTF_PHYSICAL_FULFILLMENT_PUB','fulfill_collateral_request');
     END IF;
     Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );
END create_fulfill_physical;
END JTF_Fulfillment_PUB;

/
