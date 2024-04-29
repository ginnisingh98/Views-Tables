--------------------------------------------------------
--  DDL for Package Body OE_SYNC_ORDER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_SYNC_ORDER_PVT" AS
/* $Header: OEXVGNOB.pls 120.2.12010000.15 2009/12/16 14:32:36 snimmaga ship $ */

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'OE_SYNC_ORDER_PVT';


--
-- Start : Added for Enh. 7244277 (To solve bug 7622467)
--
-- Procedure to get customer details based on site use ID and site use code.
--
PROCEDURE get_customer_details
(
    p_site_use_id      IN  NUMBER,
    p_site_use_code    IN  VARCHAR2,
    x_customer_id      OUT NOCOPY NUMBER,
    x_customer_name    OUT NOCOPY VARCHAR2,
    x_customer_number  OUT NOCOPY VARCHAR2,
    x_customer_site_id OUT NOCOPY NUMBER,
    x_party_site_id    OUT NOCOPY NUMBER
) IS
--
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  oe_debug_pub.add('Entering get_customer_details:  ', 5);
  oe_debug_pub.add('  p_site_use_id = '   || p_site_use_id, 5);
  oe_debug_pub.add('  p_site_use_code = ' || p_site_use_code, 5);

  SELECT cust.cust_account_id,
         party.party_name,
         cust.account_number,
         site.cust_acct_site_id,
         cas.party_site_id
      INTO   x_customer_id,
             x_customer_name,
             x_customer_number,
             x_customer_site_id,
             x_party_site_id
  FROM
         hz_cust_site_uses site,
         hz_cust_acct_sites cas,
         hz_cust_accounts cust,
         hz_parties party
  WHERE site.site_use_code = p_site_use_code
  AND   site_use_id = p_site_use_id
  AND   site.cust_acct_site_id = cas.cust_acct_site_id
  AND   cas.cust_account_id = cust.cust_account_id
  AND   cust.party_id=party.party_id;

  oe_debug_pub.add('  Calculated customer_id: ' || x_customer_id, 5);
  oe_debug_pub.add('  Calculated customer_name: ' || x_customer_name, 5);
  oe_debug_pub.add('  Calculated customer_number: ' || x_customer_number, 5);
  oe_debug_pub.add('  Calculated customer_site_id: ' || x_customer_site_id, 5);
  oe_debug_pub.add('  Calculated party_site_id: ' || x_party_site_id, 5);
  oe_debug_pub.add('Exiting get_customer_details...', 5);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
   Null;

  When too_many_rows then
   Null;

  When others then
   Null;

END get_customer_details;

-- This function retrieves the org_contact_id from the party layer,
-- given the cust_acct_role_id from the customer layer.
FUNCTION get_party_org_contact_id
(
  p_cust_acct_role_id IN number
)
RETURN NUMBER
IS
  l_org_contact_id NUMBER;
BEGIN
  IF ( p_cust_acct_role_id IS NULL ) THEN
    RETURN NULL;
  END IF;

  SELECT org_contact_id
      INTO  l_org_contact_id
    FROM    hz_org_contacts oc,
            hz_cust_account_roles car,
            hz_relationships r
    WHERE     r.party_id            = car.party_id
    AND       r.relationship_id     = oc.party_relationship_id
    AND       cust_account_role_id  = p_cust_acct_role_id
    AND       r.directional_flag    = 'F'
  ;

  RETURN l_org_contact_id;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;

-- End : Added for Enh. 7244277 (solving bug 7622467)


PROCEDURE  INSERT_SYNC_HEADER
(
  P_HEADER_REC    OE_Order_PUB.Header_Rec_Type,
  P_CHANGE_TYPE   VARCHAR2,
  p_req_id        NUMBER,
  X_RETURN_STATUS OUT NOCOPY  VARCHAR2

)
IS
 l_itemkey 	NUMBER;
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

 -- Start: Added for Enh. 7244277 (solving bug 7622467)
 l_customer_id              number;
 l_customer_name            varchar2(256);
 l_customer_number          varchar2(256);
 l_bill_to_cust_site_id     number;
 l_bill_to_party_site_id    number;
 -- End  : Added for Enh. 7244277 (solving bug 7622467)
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  ' ENTERING OE_SYNC_ORDER_PVT.INSERT_SYNC_HEADER :'||
                      'header id :'||P_HEADER_REC.HEADER_ID || ' p_change type :'||P_CHANGE_TYPE);
  END IF;

  -- Retrieve the value: invoice_to_customer_id. (Bug # 7622467)
  IF ( p_header_rec.invoice_to_org_id IS NOT NULL ) THEN
        get_customer_details
        (
           p_site_use_id      => p_header_rec.invoice_to_org_id,
           p_site_use_code    => 'BILL_TO',
           x_customer_id      => l_customer_id,
           x_customer_name    => l_customer_name,
           x_customer_number  => l_customer_number,
           x_customer_site_id => l_bill_to_cust_site_id,
           x_party_site_id    => l_bill_to_party_site_id
        );
  END IF;

            INSERT INTO oe_header_acks
               (header_id
               ,acknowledgment_type
               ,last_ack_code
               ,request_id
               ,sold_to_org_id
               ,change_sequence
               ,flow_status_code
               ,orig_sys_document_ref
               ,order_number
               ,ordered_date
               ,org_id
               ,order_source_id
            -- Start: Added for Enh. 7244277
               ,invoice_address_id             -- Bug # 7622467
               ,price_list_id                  -- Bug # 7644412
            -- End  : Added for Enh. 7244277
               ,creation_date
               ,transactional_curr_code) -- 9182921
            VALUES (
               P_HEADER_REC.header_id
              ,'SEBL_SYNC'
              ,P_HEADER_REC.flow_status_code
              ,p_req_id
              ,p_header_rec.sold_to_org_id
              ,p_header_rec.change_sequence
              ,decode(p_change_type, 'APPLY', 'ON_HOLD',
                                      'RELEASE', 'RELEASED',
                                       p_header_rec.flow_status_code)
              ,p_header_rec.orig_sys_document_ref
              ,p_header_rec.order_number
              ,p_header_rec.ordered_date
              ,p_header_rec.org_id
              ,p_header_rec.order_source_id
            -- Start: Added for Enh. 7244277
              ,l_bill_to_party_site_id
              ,p_header_rec.price_list_id
            -- End  : Added for Enh. 7244277
              ,sysdate
              ,p_header_rec.transactional_curr_code); -- Bug 9182921

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  ' EXITING OE_SYNC_ORDER_PVT.INSERT_SYNC_HEADER');
  END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        --  Get message count and data
     IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  ' OE_SYNC_ORDER_PVT -G_EXC_ERROR');
     END IF;

   WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  ' OE_SYNC_ORDER_PVT - G_RET_STS_UNEXP_ERROR');
        END IF;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'OE_SYNC_ORDER_PVT.INSERT_SYNC_HEADER'
            );
        END IF;
END;

PROCEDURE  INSERT_SYNC_LINE
(
  p_line_rec       oe_order_pub.line_rec_type,
  p_change_type    varchar2,
  p_req_id         number,
  x_return_status  out NOCOPY varchar2
)
IS
  l_itemkey 	         number;
  l_parent_rec           oe_order_pub.line_rec_type;
  l_tmp_flow_status_code varchar2(256);
  l_count                number;
  l_debug_level CONSTANT number := oe_debug_pub.g_debug_level;

  -- Customer Information
  o_ship_to_cust_id         number;
  o_ship_to_cust_site_id    number;
  o_ship_to_party_site_id   number;
  o_bill_to_cust_id         number;
  o_bill_to_cust_site_id    number;
  o_bill_to_party_site_id   number;
  o_cust_name               varchar2(256);
  o_cust_num                number;

  o_ship_to_prty_cntct_id   number;
  o_bill_to_prty_cntct_id   number;
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  ' ENTERING OE_SYNC_ORDER_PVT.INSERT_SYNC_LINE :'||
                    'line id :'||P_LINE_REC.LINE_ID || ' p_change type :'||P_CHANGE_TYPE||
			'flow status' || p_line_rec.flow_status_code);
  END IF;

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  '  l_itemkey' || l_itemkey);
     oe_debug_pub.add(  '  itemtypecode' || p_line_rec.item_type_code);
     oe_debug_pub.add(  '  split from line' || p_line_rec.split_from_line_id);
  END IF;

  IF p_line_rec.item_type_code='CONFIG' and p_line_rec.split_from_line_id IS NOT NULL THEN
          oe_line_util.query_row(
                                p_line_id  => p_line_rec.top_model_line_id
                               ,x_line_rec => l_parent_rec
                               );
     oe_debug_pub.add(  'top model  split from line' || l_parent_rec.split_from_line_id);
  END IF;

  -- Retrieve the ORG_CONTACT_ID based on
  --   p_line_rec.[invoice ship]_to_contact_id
  o_ship_to_prty_cntct_id := get_party_org_contact_id(
                               p_line_rec.ship_to_contact_id
                             );
  o_bill_to_prty_cntct_id := get_party_org_contact_id(
                               p_line_rec.invoice_to_contact_id
                             );

  -- Retrieve the value: invoice_to_customer_id
  IF ( p_line_rec.invoice_to_org_id IS NOT NULL ) THEN
        get_customer_details
        (
           p_site_use_id      => p_line_rec.invoice_to_org_id,
           p_site_use_code    => 'BILL_TO',
           x_customer_id      => o_bill_to_cust_id,
           x_customer_name    => o_cust_name,
           x_customer_number  => o_cust_num,
           x_customer_site_id => o_bill_to_cust_site_id,
           x_party_site_id    => o_bill_to_party_site_id
        );
  END IF;

  -- Retrieve the value: ship_to_customer_id
  IF ( p_line_rec.ship_to_org_id IS NOT NULL ) THEN
        get_customer_details
        (
           p_site_use_id      => p_line_rec.ship_to_org_id,
           p_site_use_code    => 'SHIP_TO',
           x_customer_id      => o_ship_to_cust_id,
           x_customer_name    => o_cust_name,
           x_customer_number  => o_cust_num,
           x_customer_site_id => o_ship_to_cust_site_id,
           x_party_site_id    => o_ship_to_party_site_id
        );
  END IF;


         INSERT INTO oe_line_acks
            (header_id
            ,line_id
            ,acknowledgment_type
            ,last_ack_code
            ,request_id
            ,change_sequence
            ,flow_status_code
            ,ordered_quantity
            ,schedule_arrival_date
            ,schedule_ship_date
            ,config_header_id
            ,config_rev_nbr
            ,configuration_id
            ,orig_sys_document_ref
            ,orig_sys_line_ref
            ,orig_sys_shipment_ref
            ,split_from_line_id
  	        ,inventory_item_id
            ,org_id
            ,order_source_id
            ,order_quantity_uom
            ,top_model_line_id
            ,item_type_code
	    -- Start: enh. 7244277
            ,line_number
            ,tax_value
            ,agreement_id
            ,payment_term_id
            ,promise_date
            ,shipping_method_code
            ,shipment_priority_code
            ,freight_terms_code
            ,ship_to_customer_id
            ,ship_to_contact_id
            ,ship_to_org_id
            ,invoice_to_customer_id
            ,invoice_to_contact_id
            ,invoice_to_org_id
            ,unit_selling_price                   -- 7644412
            ,price_list_id                        -- 7644412
            ,unit_list_price                      -- 7644412
            ,unit_list_price_per_pqty             -- 7644412
            ,unit_percent_base_price              -- 7644412
            ,unit_selling_price_per_pqty          -- 7644412
            ,pricing_date                         -- 7644412
            ,ship_to_address_id
            -- End : enh. 7244277
            ,creation_date
            -- O2C25
            ,ship_from_org_id
            ,ship_from_org
            ,ship_to_org
            ,invoice_to_org
            ,line_category_code)  -- 9151484
         VALUES(
             p_line_rec.header_id
            ,decode(p_line_rec.item_type_code,'CONFIG',p_line_rec.top_model_line_id,p_line_rec.line_id)
            ,'SEBL_SYNC'
            ,p_line_rec.flow_status_code
            ,p_req_id
            ,p_line_rec.change_sequence
            ,decode(p_change_type, 'APPLY', 'ON_HOLD',
                                   'RELEASE', 'RELEASED',
                                    p_line_rec.flow_status_code
                   )
            ,p_line_rec.ordered_quantity
            ,p_line_rec.schedule_arrival_date
            ,p_line_rec.schedule_ship_date
            ,p_line_rec.config_header_id
            ,p_line_rec.config_rev_nbr
            ,p_line_rec.configuration_id
            ,p_line_rec.orig_sys_document_ref
            ,p_line_rec.orig_sys_line_ref
            ,p_line_rec.orig_sys_shipment_ref
            ,decode(p_line_rec.item_type_code,'CONFIG',l_parent_rec.split_from_line_id,p_line_rec.split_from_line_id)
            ,p_line_rec.inventory_item_id
            ,p_line_rec.org_id
            ,p_line_rec.order_source_id
            ,p_line_rec.order_quantity_uom
            ,p_line_rec.top_model_line_id
            ,p_line_rec.item_type_code
	         -- Start : Enh. 7244277
            ,p_line_rec.line_number
            -- ,Decode(p_line_rec.line_category_code,'RETURN',-p_line_rec.tax_value, p_line_rec.tax_value) -- Bug 8977354
	        ,p_line_rec.tax_value
            ,p_line_rec.agreement_id
            ,p_line_rec.payment_term_id
            ,p_line_rec.promise_date
            ,p_line_rec.shipping_method_code
            ,p_line_rec.shipment_priority_code
            ,p_line_rec.freight_terms_code
            ,o_ship_to_cust_id
            ,o_ship_to_prty_cntct_id
            ,p_line_rec.ship_to_org_id
            ,o_bill_to_cust_id
            ,o_bill_to_prty_cntct_id
            ,p_line_rec.invoice_to_org_id
            ,p_line_rec.unit_selling_price
            ,p_line_rec.price_list_id
            ,p_line_rec.unit_list_price
            ,p_line_rec.unit_list_price_per_pqty
            ,p_line_rec.unit_percent_base_price
            ,p_line_rec.unit_selling_price_per_pqty
            ,p_line_rec.pricing_date
            ,o_ship_to_party_site_id
            -- End : enh. 7244277
            ,SYSDATE
            -- O2C25
            ,p_line_rec.ship_from_org_id
            ,Oe_Genesis_Util.Inventory_Org(p_line_rec.ship_from_org_id)
            ,Oe_Genesis_Util.Inventory_Org(p_line_rec.ship_to_org_id)
            ,Oe_Genesis_Util.Inventory_Org(p_line_rec.invoice_to_org_id)
            ,p_line_rec.line_category_code -- 9151484
         );

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  ' EXITING OE_SYNC_ORDER_PVT.INSERT_SYNC_LINE');
  END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        --  Get message count and data

     IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  ' OE_SYNC_ORDER_PVT -G_EXC_ERROR');
     END IF;
   WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  ' OE_SYNC_ORDER_PVT - G_RET_STS_UNEXP_ERROR');
        END IF;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'OE_SYNC_ORDER_PVT.INSERT_SYNC_LINE'
            );
        END IF;

END;

PROCEDURE sync_header_line(p_header_rec         IN OE_Order_Pub.Header_Rec_Type
                          ,p_line_rec           IN OE_Order_PUB.Line_Rec_Type
                          ,p_hdr_req_id         IN NUMBER DEFAULT NULL
                          ,p_lin_req_id         IN NUMBER DEFAULT NULL
                          ,p_change_type        IN VARCHAR2 DEFAULT NULL
                          ,p_hold_source_id     IN NUMBER DEFAULT NULL
                          ,p_order_hold_id      IN NUMBER DEFAULT NULL
                          ,p_hold_release_id    IN NUMBER DEFAULT NULL) IS

   CURSOR get_hdr_for_hldsrc_cur IS
      SELECT ohdr.header_id
	    , ohld.line_id
            ,'SEBL_SYNC'
            ,ohdr.flow_status_code
            ,ohdr.request_id
            ,ohdr.sold_to_org_id
            ,ohdr.change_sequence
            ,ohdr.orig_sys_document_ref
            ,ohdr.order_number
            ,ohdr.ordered_date
            ,ohdr.org_id
            ,ohdr.order_source_id
           ,ohld.released_flag
         FROM oe_order_headers_all ohdr,
              oe_order_holds_all ohld,
              oe_order_sources osrc -- to remove hardcoding on order_source_id
         WHERE ohdr.header_id       = ohld.header_id
           -- AND ohdr.order_source_id = 28
           AND ohdr.order_source_id = osrc.order_source_id
           and osrc.aia_enabled_flag = 'Y'
           AND ohld.hold_source_id  = p_hold_source_id
           AND decode(p_change_type,'RELEASE',ohld.hold_release_id,-99)
                       = decode(p_change_type,'RELEASE',p_hold_release_id,-99)
           AND ohdr.booked_flag     = 'Y'
           AND flow_status_code    <> 'ENTERED'
        ORDER BY ohld.header_id;

   CURSOR get_ord_hld_cur IS
         SELECT ooh.header_id
               ,ooh.line_id
	     FROM oe_order_holds ooh,
              oe_order_headers_all h,
              oe_order_sources osrc -- to remove hardcoding on order_source_id
         WHERE h.header_id       = ooh.header_id
          -- AND   h.order_source_id = 28
         AND   h.order_source_id = osrc.order_source_id
         AND   osrc.aia_enabled_flag = 'Y'
         AND   ooh.order_hold_id = p_order_hold_id;


    l_line_rec         OE_Order_PUB.Line_Rec_Type;
    l_header_rec       OE_Order_PUB.Header_Rec_Type;
    l_prev_header_id   NUMBER;

    l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
    l_itemkey              number;
    l_return_status        VARCHAR2(1);

BEGIN
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('OE_sync_order_PVT - Entering sync_header_line');
      oe_debug_pub.add('sync_header_line - p_header_id     : '||p_header_rec.header_id);
      oe_debug_pub.add('sync_header_line - booked_flag     : '||p_header_rec.booked_flag);
      oe_debug_pub.add('sync_header_line - p_line_id       : '||p_line_rec.line_id);
      oe_debug_pub.add('sync_header_line - p_hdr_req_id    : '||p_hdr_req_id);
      oe_debug_pub.add('sync_header_line - p_lin_req_id    : '||p_lin_req_id);
      oe_debug_pub.add('sync_header_line - p_change_type   : '||p_change_type);
      oe_debug_pub.add('sync_header_line - p_hold_source_id: '||p_hold_source_id);
      oe_debug_pub.add('sync_header_line - p_order_hold_id : '||p_order_hold_id);
      oe_debug_pub.add('sync_header_line - p_hold_release_id : '||p_hold_release_id);
   END IF;

   -- Fix of bug 8205201
   IF ( NOT oe_genesis_util.source_aia_enabled(p_header_rec.order_source_id) )
   THEN
     oe_debug_pub.ADD('sync_header_line - Order # ' || p_header_rec.order_number
           || ', ' || ' order source id: ' || p_header_rec.order_source_id);
     oe_debug_pub.ADD('sync_header_line - not processing non-AIA order/quote...');
     RETURN;
   ELSE
     oe_debug_pub.ADD('sync_header_line - p_header_rec.order_source_id: ' ||
                      p_header_rec.order_source_id);
     oe_debug_pub.ADD('sync_header_line - processing synch operation on AIA...');
   END IF;
   -- End of fix of bug 8205201

   IF p_change_type IN ('APPLY', 'RELEASE') THEN

      IF (p_line_rec.line_id IS NOT NULL AND
         p_header_rec.booked_flag = 'Y') THEN

         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('sync_header_line- APPLY- Inserting row into oe_line_acks for p_line_id');
         END IF;

          select OE_XML_MESSAGE_SEQ_S.nextval
          into l_itemkey
          from dual;

          INSERT_SYNC_lINE(P_LINE_rec       => P_LINE_rec,
            		   p_change_type   => p_change_type,
                           p_req_id        => l_itemkey,         -- XXXX
	         	   X_RETURN_STATUS => L_RETURN_STATUS);

         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('sync_header_line -APPLY- Inserting into oe_line_acks for p_line_id is DONE'||l_return_status);
         END IF;

          IF p_header_rec.header_id IS NOT NULL THEN
            IF l_debug_level  > 0 THEN
              oe_debug_pub.add(' INSERT_SYNC_HEADER - inserting for apply holds ');
            END IF;

                 INSERT_SYNC_HEADER(p_header_rec     => p_header_rec,
             			    p_change_type   => null,   --TODO
                                    p_req_id        => l_itemkey, --XXXX
             			    x_return_status => l_return_status);
          END IF;
          IF l_debug_level  > 0 THEN
               oe_debug_pub.add('sync_header_line - APPLY-inserted into line acks');
          END IF;

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add('sync_header_line - Raise BPEL event by calling raise_bpel_out_event1');
         END IF;

          IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
   		raise_bpel_out_event(p_header_id        => p_header_rec.header_id
                                          ,p_line_id          => p_line_rec.line_id
                                          ,p_hdr_req_id       => l_itemkey  --XXXX
                                          ,p_lin_req_id       => l_itemkey  --XXXX
                                          ,p_change_type      => p_change_type
                                          ,p_hold_source_id   => p_hold_source_id
                                          ,p_order_hold_id    => p_order_hold_id);
          END IF;
      ELSIF p_line_rec.line_id IS NULL AND
         p_header_rec.header_id IS NOT NULL AND
         p_header_rec.booked_flag = 'Y' THEN

         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('sync_header_line - Inserting row into oe_header_acks for header_id');
         END IF;
                   select OE_XML_MESSAGE_SEQ_S.nextval
                   into l_itemkey
                   from dual;

                   INSERT_SYNC_HEADER(p_header_rec     => p_header_rec,
             			      p_change_type   => p_change_type,
                                      p_req_id        => l_itemkey, --XXXX
				      x_return_status => l_return_status);

         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('sync_header_line - Inserting into oe_header_acks for header_id is DONE');
         END IF;

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('sync_header_line - Raise BPEL event by calling raise_bpel_out_event2');
        END IF;

        IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                        raise_bpel_out_event(p_header_id                 => p_header_rec.header_id
                                          ,p_line_id                     => p_line_rec.line_id
                                          ,p_hdr_req_id                  => l_itemkey --XXXX
                                          ,p_lin_req_id                  => l_itemkey      --XXXX
                                          ,p_change_type                 => p_change_type
                                          ,p_hold_source_id              => p_hold_source_id
                                          ,p_order_hold_id               => p_order_hold_id);
        END IF;

      ELSIF p_line_rec.line_id IS NULL AND
         p_header_rec.header_id IS NULL AND
         p_hold_source_id IS NOT NULL THEN

         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('sync_header_line - Inserting row into oe_header_acks for p_hold_source_id');
         END IF;


         FOR hdr_rec IN get_hdr_for_hldsrc_cur
         LOOP

         BEGIN
          l_return_status := FND_API.G_RET_STS_SUCCESS;

          IF l_debug_level  > 0 THEN
            oe_debug_pub.add('sync_header_line- in loop -released flag'||hdr_rec.released_flag);
          END IF;
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add('sync_header_line- hdr_rec.line_id: '||hdr_rec.line_id);
          END IF;


          IF hdr_rec.line_id IS NULL THEN

            select OE_XML_MESSAGE_SEQ_S.nextval
              into l_itemkey
             from dual;

         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('sync_header_line - l_itemkey '|| l_itemkey);
         END IF;

            INSERT INTO oe_header_acks
            (header_id
            ,acknowledgment_type
            ,last_ack_code
            ,request_id
            ,sold_to_org_id
            ,change_sequence
            ,flow_status_code
            ,orig_sys_document_ref
            ,order_number
            ,ordered_date
            ,org_id
            ,order_source_id)
         VALUES
            (hdr_rec.header_id
            ,'SEBL_SYNC'
            ,hdr_rec.flow_status_code
            ,l_itemkey
            ,hdr_rec.sold_to_org_id
            ,hdr_rec.change_sequence
            ,decode(p_change_type, 'APPLY', 'ON_HOLD',
                                   'RELEASE', 'RELEASED',
                                    hdr_rec.flow_status_code)
            ,hdr_rec.orig_sys_document_ref
            ,hdr_rec.order_number
            ,hdr_rec.ordered_date
            ,hdr_rec.org_id
            ,hdr_rec.order_source_id);

         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('sync_header_line - after insert');
         END IF;
       ELSE -- hdr_rec.line_id is NULL
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('sync_header_line - hdr_rec.header_id'||hdr_rec.header_id);
            oe_debug_pub.add('sync_header_line - l_prev_header_id'||l_prev_header_id);
         END IF;
          If hdr_rec.header_id <> nvl(l_prev_header_id,-1) THEN
            select OE_XML_MESSAGE_SEQ_S.nextval
              into l_itemkey
            from dual;

            IF l_debug_level  > 0 THEN
               oe_debug_pub.add('sync_header_line-l_prev_header_id=' || l_prev_header_id);
               oe_debug_pub.add('sync_header_line-hdr_rec.header_id=' || hdr_rec.header_id);
               oe_debug_pub.add('sync_header_line-l_item_key=' || l_itemkey );
            END IF;
            INSERT INTO oe_header_acks
            (header_id
            ,acknowledgment_type
            ,last_ack_code
            ,request_id
            ,sold_to_org_id
            ,change_sequence
            ,flow_status_code
            ,orig_sys_document_ref
            ,order_number
            ,ordered_date
            ,org_id
            ,order_source_id)
         VALUES
            (hdr_rec.header_id
            ,'SEBL_SYNC'
            ,hdr_rec.flow_status_code
            ,l_itemkey
            ,hdr_rec.sold_to_org_id
            ,hdr_rec.change_sequence
            ,hdr_rec.flow_status_code
            ,hdr_rec.orig_sys_document_ref
            ,hdr_rec.order_number
            ,hdr_rec.ordered_date
            ,hdr_rec.org_id
            ,hdr_rec.order_source_id);

            l_prev_header_id := hdr_rec.header_id;
          END IF;

          IF l_debug_level  > 0 THEN
                     oe_debug_pub.add('sync_header_line - calling query row ');
          END IF;
          oe_line_util.query_row(
                                p_line_id  => hdr_rec.line_id
                               ,x_line_rec => l_line_rec
                               );
          INSERT_SYNC_lINE(P_LINE_REC       => L_LINE_REC,
            		         p_change_type    => p_change_type,
                                 p_req_id         => l_itemkey,  --XXXX
	         	         X_RETURN_STATUS  => L_RETURN_STATUS);
          IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
               IF l_debug_level  > 0 THEN
                    oe_debug_pub.add('sync_header_line - Line inserted');
               END IF;
          END IF;

      END IF; -- hdr_rec.line_id

      IF l_debug_level  > 0 THEN
           oe_debug_pub.add('sync_header_line - Raise BPEL event by calling raise_bpel_out_event3');
      END IF;

      raise_bpel_out_event(
                    p_header_id        => hdr_rec.header_id
                   ,p_line_id          => hdr_rec.line_id
                   ,p_hdr_req_id       => l_itemkey  --XXXX
                   ,p_lin_req_id       => l_itemkey       --XXXX
                   ,p_change_type      => p_change_type
                   ,p_hold_source_id   => p_hold_source_id
                   ,p_order_hold_id    => p_order_hold_id);

      EXCEPTION
                WHEN FND_API.G_EXC_ERROR THEN
                 IF l_debug_level  > 0 THEN
                   oe_debug_pub.add('sync_header_line - G_EXC_ERROR Inside Main LOOP for Header/LineID: '
                                    || hdr_rec.header_id || '/' || hdr_rec.line_id);
                 END IF;
                 l_return_status := FND_API.G_RET_STS_ERROR;

                WHEN OTHERS THEN
                 IF l_debug_level  > 0 THEN
                   oe_debug_pub.add('sync_header_line - OTHERS Inside Main LOOP for Header/LineID: '
                                    || hdr_rec.header_id || '/' || hdr_rec.line_id);
                 END IF;
                l_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                  THEN
                  OE_MSG_PUB.Add_Exc_Msg
                  (   G_PKG_NAME
                   ,'OE_SYNC_ORDER_PVT.SYNC_HEADER_LINE'
                  );
                END IF;
       END;

     END LOOP;

         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('sync_header_line - Inserting into oe_header_acks for p_hold_source_id is DONE');
         END IF;
      END IF;
   END IF;

-- Start: commented out superfluous code for bug 8667900

/*
   IF p_change_type = 'RELEASE' AND
      p_order_hold_id IS NOT NULL THEN

      FOR ord_rec IN get_ord_hld_cur
      LOOP
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('sync_header_line -RELEASE-QUERING HEADER RECORD');
         END IF;

         -- Bug 8463870
         if ( p_header_rec.header_id IS NULL ) then
           oe_debug_pub.add('.... Querying header_rec using API...');
           OE_Header_UTIL.Query_Row
              (p_header_id            => ord_rec.header_id
              ,x_header_rec           => l_header_rec
              );
         else
           oe_debug_pub.add('.... Assigning from passed in parameters...');
           l_header_rec := p_header_rec;
         end if;

         IF ord_rec.line_id IS NOT NULL THEN
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('sync_header_line -RELEASE-QUERING LINE RECORD');
         END IF;

          -- Bug 8463870
          if ( p_line_rec.line_id is NULL ) then
            oe_debug_pub.add('.... Querying line_rec using API...');
            oe_line_util.query_row(
                                  p_line_id  => ord_rec.line_id
                                 ,x_line_rec => l_line_rec
                                  );
          else
            oe_debug_pub.add('... Assigning from passed in parameters...');
            l_line_rec := p_line_rec;
          end if;

          select OE_XML_MESSAGE_SEQ_S.nextval
          into l_itemkey
          from dual;

          IF l_debug_level  > 0 THEN
            oe_debug_pub.add('sync_header_line -RELEASE-BEFORE INSERTING HEADER ');
          END IF;

          INSERT_SYNC_HEADER(p_header_rec    => l_header_rec,
             	       	     p_change_type   => null,
                             p_req_id        => l_itemkey,
                             x_return_status => l_return_status);

          IF l_debug_level  > 0 THEN
            oe_debug_pub.add('sync_header_line -RELEASE-BEFORE INSERTING LINE ');
          END IF;
          INSERT_SYNC_LINE(P_LINE_REC        => l_line_rec,
            		   p_change_type     => p_change_type,
                             p_req_id        => l_itemkey,
	         	   X_RETURN_STATUS   => L_RETURN_STATUS);

           IF l_debug_level  > 0 THEN
           oe_debug_pub.add('sync_header_line - Raise BPEL event by calling raise_bpel_out_event5');
           END IF;

	   IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                      raise_bpel_out_event(
                           p_header_id        => ord_rec.header_id
                          ,p_line_id          => ord_rec.line_id
                          ,p_hdr_req_id       => l_itemkey
                          ,p_lin_req_id       => l_itemkey
                          ,p_change_type      => p_change_type
                          ,p_hold_source_id   => p_hold_source_id
                          ,p_order_hold_id    => p_order_hold_id);
           END IF;
         ELSIF ord_rec.line_id IS NULL AND
               ord_rec.header_id IS NOT NULL THEN

          select OE_XML_MESSAGE_SEQ_S.nextval
          into l_itemkey
          from dual;

                   INSERT_SYNC_HEADER(p_header_rec     => l_header_rec,
             	       	              p_change_type    => p_change_type,
                                      p_req_id         => l_itemkey, --XXXX
				      x_return_status  => l_return_status);
         IF l_debug_level  > 0 THEN
          oe_debug_pub.add('sync_header_line - Raise BPEL event by calling raise_bpel_out_event6');
         END IF;

	   IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
    			raise_bpel_out_event(p_header_id      => ord_rec.header_id
                                          ,p_line_id          => ord_rec.line_id
                                          ,p_hdr_req_id       => l_itemkey --XXXX
                                          ,p_lin_req_id       => l_itemkey --XXXX
                                          ,p_change_type      => p_change_type
                                          ,p_hold_source_id   => p_hold_source_id
                                          ,p_order_hold_id    => p_order_hold_id);
    	   END IF;
         END IF;
      END LOOP;
   END IF;
*/
-- Complete: commenting superfluous code bug 8667900

   IF l_debug_level  > 0 THEN
     oe_debug_pub.add('sync_header_line - Raise BPEL event by calling raise_bpel_out_event');
   END IF;


      /* To handle other change types */

   IF  p_change_type NOT IN ('APPLY','RELEASE') THEN

          IF l_debug_level  > 0 THEN
               oe_debug_pub.add('sync_header_line - inserted into header acks');
          END IF;
          IF p_header_rec.header_id IS NOT NULL THEN

                 INSERT_SYNC_HEADER(p_header_rec     => p_header_rec,
             	       	            p_change_type   => p_change_type,
                                    p_req_id        => p_hdr_req_id,
				    x_return_status => l_return_status);
          END IF;
          IF l_debug_level  > 0 THEN
               oe_debug_pub.add('sync_header_line - inserted into line acks');
          END IF;


          IF l_debug_level  > 0 THEN
               oe_debug_pub.add('sync_header_line - before calling bpel');
               oe_debug_pub.add('sync_header_line - flow status'||p_line_rec.flow_status_code);
          END IF;

	  /* logging business event */

    	  raise_bpel_out_event(p_header_id        => p_header_rec.header_id
                                          ,p_line_id          => p_line_rec.line_id
                                          ,p_hdr_req_id       => p_hdr_req_id
                                          ,p_lin_req_id       => p_lin_req_id  --XXXX
                                          ,p_change_type      => p_change_type
                                          ,p_hold_source_id   => p_hold_source_id
                                          ,p_order_hold_id    => p_order_hold_id);
   END IF;

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('OE_sync_order_PVT - Exiting sync_header_line');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, 'sync_header_line');
      END IF;

END sync_header_line;

PROCEDURE process_order_sync(p_header_id          IN NUMBER
                            ,p_hdr_req_id         IN NUMBER
                            ,p_line_id            IN NUMBER
                            ,p_lin_req_id         IN NUMBER
                            ,p_hold_source_id     IN NUMBER
                            ,p_order_hold_id      IN NUMBER
                            ,p_change_type        IN VARCHAR2
                            ,p_hdr_ack_tbl        OUT NOCOPY oe_acknowledgment_pub.header_ack_tbl_type
                            ,p_line_ack_tbl       OUT NOCOPY oe_acknowledgment_pub.line_ack_tbl_type
                            ,x_return_status      OUT NOCOPY VARCHAR2
                            ,x_msg_count          OUT NOCOPY NUMBER
                            ,x_msg_data           OUT NOCOPY VARCHAR2
                            ) IS

   i   NUMBER := 0;
   j   NUMBER := 0;
   l_hdr_ack_rec    oe_acknowledgment_pub.header_ack_rec_type;
   l_line_ack_rec   oe_acknowledgment_pub.line_ack_rec_type;

   -- Cursor modified for Enh. 7244277, 7644412
   CURSOR get_hdr_req_cur IS
      SELECT
         HEADER_ID ,ORIG_SYS_DOCUMENT_REF ,ORDER_NUMBER,
         ORDERED_DATE ,ORG_ID ,CHANGE_DATE,
         CHANGE_SEQUENCE ,SOLD_TO_ORG_ID ,ORDER_SOURCE_ID,
         REQUEST_ID ,ACKNOWLEDGMENT_TYPE ,FLOW_STATUS_CODE,
         INVOICE_ADDRESS_ID, PRICE_LIST_ID,
         TRANSACTIONAL_CURR_CODE --Bug 9182921
      FROM   oe_header_acks
      WHERE  request_id = p_hdr_req_id;

   -- Cursor modified for Enh. 7244277, 7644412, 7644426
   CURSOR get_line_req_cur IS
      SELECT
        HEADER_ID, ORIG_SYS_DOCUMENT_REF, ORIG_SYS_LINE_REF,
        CHANGE_DATE ,CHANGE_SEQUENCE ,ORDER_NUMBER,
        SOLD_TO_ORG_ID ,CONFIGURATION_ID ,CONFIG_REV_NBR,
        CONFIG_HEADER_ID ,CONFIG_LINE_REF ,TOP_MODEL_LINE_ID,
        INVENTORY_ITEM_ID ,LINE_ID ,LINE_NUMBER,
        ORDER_SOURCE_ID ,ORDERED_QUANTITY ,ORG_ID,
        REQUEST_ID ,SCHEDULE_ARRIVAL_DATE ,SCHEDULE_SHIP_DATE,
        ACKNOWLEDGMENT_TYPE ,FLOW_STATUS_CODE ,SPLIT_FROM_LINE_REF,
        SPLIT_FROM_SHIPMENT_REF ,SPLIT_FROM_LINE_ID, TAX_VALUE,
        AGREEMENT_ID, PAYMENT_TERM_ID, PROMISE_DATE, SHIP_FROM_ORG_ID,
        SHIPPING_METHOD_CODE, SHIPMENT_PRIORITY_CODE, FREIGHT_TERMS_CODE,
        SHIP_TO_CUSTOMER_ID, SHIP_TO_CONTACT_ID, SHIP_TO_ORG_ID,
        INVOICE_TO_CUSTOMER_ID, INVOICE_TO_CONTACT_ID, INVOICE_TO_ORG_ID,
        UNIT_SELLING_PRICE, PRICE_LIST_ID, UNIT_LIST_PRICE,
        UNIT_LIST_PRICE_PER_PQTY, UNIT_PERCENT_BASE_PRICE,
        UNIT_SELLING_PRICE_PER_PQTY, PRICING_DATE, SHIP_TO_ADDRESS_ID,
        SHIP_FROM_ORG, SHIP_TO_ORG, INVOICE_TO_ORG,
        ITEM_TYPE_CODE,    -- 9131629
        LINE_CATEGORY_CODE -- 9151484
      FROM   oe_line_acks
      WHERE  request_id = p_lin_req_id;

    l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

    l_hdr_rec_ctr       NUMBER := 0;
    l_line_rec_ctr      NUMBER := 0;

BEGIN

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('OE_sync_order_PVT - Entering process_order_sync');
      oe_debug_pub.add('process_order_sync - p_header_id     : '||p_header_id);
      oe_debug_pub.add('process_order_sync - p_line_id       : '||p_line_id);
      oe_debug_pub.add('process_order_sync - p_hdr_req_id    : '||p_hdr_req_id);
      oe_debug_pub.add('process_order_sync - p_lin_req_id    : '||p_lin_req_id);
      oe_debug_pub.add('process_order_sync - p_change_type   : '||p_change_type);
      oe_debug_pub.add('process_order_sync - p_hold_source_id: '||p_hold_source_id);
      oe_debug_pub.add('process_order_sync - p_order_hold_id : '||p_order_hold_id);
   END IF;


   IF p_hdr_req_id IS NOT NULL AND
      p_hdr_req_id <> 0 THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('process_order_sync - Getting data to populate p_hdr_ack_tbl');
      END IF;
      l_hdr_rec_ctr := 0;
      FOR hdr_rec IN get_hdr_req_cur LOOP
          l_hdr_rec_ctr := l_hdr_rec_ctr + 1;
          p_hdr_ack_tbl(l_hdr_rec_ctr).HEADER_ID             := hdr_rec.HEADER_ID;
          p_hdr_ack_tbl(l_hdr_rec_ctr).ORIG_SYS_DOCUMENT_REF := hdr_rec.ORIG_SYS_DOCUMENT_REF;
          p_hdr_ack_tbl(l_hdr_rec_ctr).ORDER_NUMBER          := hdr_rec.ORDER_NUMBER;
          p_hdr_ack_tbl(l_hdr_rec_ctr).ORDERED_DATE          := hdr_rec.ORDERED_DATE;
          p_hdr_ack_tbl(l_hdr_rec_ctr).ORG_ID                := hdr_rec.ORG_ID;
          p_hdr_ack_tbl(l_hdr_rec_ctr).CHANGE_DATE           := hdr_rec.CHANGE_DATE;
          p_hdr_ack_tbl(l_hdr_rec_ctr).CHANGE_SEQUENCE       := hdr_rec.CHANGE_SEQUENCE;
          p_hdr_ack_tbl(l_hdr_rec_ctr).SOLD_TO_ORG_ID        := hdr_rec.SOLD_TO_ORG_ID;
          p_hdr_ack_tbl(l_hdr_rec_ctr).ORDER_SOURCE_ID       := hdr_rec.ORDER_SOURCE_ID;
          p_hdr_ack_tbl(l_hdr_rec_ctr).REQUEST_ID            := hdr_rec.REQUEST_ID;
          p_hdr_ack_tbl(l_hdr_rec_ctr).ACKNOWLEDGMENT_TYPE   := hdr_rec.ACKNOWLEDGMENT_TYPE;
          p_hdr_ack_tbl(l_hdr_rec_ctr).FLOW_STATUS_CODE      := hdr_rec.FLOW_STATUS_CODE;
          p_hdr_ack_tbl(l_hdr_rec_ctr).INVOICE_ADDRESS_ID    := hdr_rec.INVOICE_ADDRESS_ID;
          p_hdr_ack_tbl(l_hdr_rec_ctr).PRICE_LIST_ID         := hdr_rec.PRICE_LIST_ID;
          -- Bug 9131629
          p_hdr_ack_tbl(l_hdr_rec_ctr).TRANSACTIONAL_CURR_CODE  := hdr_rec.TRANSACTIONAL_CURR_CODE;
      END LOOP;
   END IF;

   IF p_lin_req_id IS NOT NULL AND
      p_lin_req_id <> 0 THEN

       IF l_debug_level  > 0 THEN
            oe_debug_pub.add('process_order_sync - Getting data to populate p_line_ack_tbl');
       END IF;
       l_line_rec_ctr := 0;
       FOR line_rec IN get_line_req_cur LOOP
             l_line_rec_ctr := l_line_rec_ctr + 1;
             p_line_ack_tbl(l_line_rec_ctr).HEADER_ID              := line_rec.HEADER_ID;
             p_line_ack_tbl(l_line_rec_ctr).ORIG_SYS_DOCUMENT_REF  := line_rec.ORIG_SYS_DOCUMENT_REF;
             p_line_ack_tbl(l_line_rec_ctr).ORIG_SYS_LINE_REF      := line_rec.ORIG_SYS_LINE_REF;
             p_line_ack_tbl(l_line_rec_ctr).CHANGE_DATE            := line_rec.CHANGE_DATE;
             p_line_ack_tbl(l_line_rec_ctr).CHANGE_SEQUENCE        := line_rec.CHANGE_SEQUENCE;
             p_line_ack_tbl(l_line_rec_ctr).ORDER_NUMBER           := line_rec.ORDER_NUMBER;
             p_line_ack_tbl(l_line_rec_ctr).SOLD_TO_ORG_ID         := line_rec.SOLD_TO_ORG_ID;
             p_line_ack_tbl(l_line_rec_ctr).CONFIGURATION_ID       := line_rec.CONFIGURATION_ID;
             p_line_ack_tbl(l_line_rec_ctr).CONFIG_REV_NBR         := line_rec.CONFIG_REV_NBR;
             p_line_ack_tbl(l_line_rec_ctr).CONFIG_HEADER_ID       := line_rec.CONFIG_HEADER_ID;
             p_line_ack_tbl(l_line_rec_ctr).CONFIG_LINE_REF        := line_rec.CONFIG_LINE_REF;
             p_line_ack_tbl(l_line_rec_ctr).TOP_MODEL_LINE_ID      := line_rec.TOP_MODEL_LINE_ID;
             p_line_ack_tbl(l_line_rec_ctr).INVENTORY_ITEM_ID      := line_rec.INVENTORY_ITEM_ID;
             p_line_ack_tbl(l_line_rec_ctr).LINE_ID                := line_rec.LINE_ID;
             p_line_ack_tbl(l_line_rec_ctr).LINE_NUMBER            := line_rec.LINE_NUMBER;
             p_line_ack_tbl(l_line_rec_ctr).ORDER_SOURCE_ID        := line_rec.ORDER_SOURCE_ID;
             p_line_ack_tbl(l_line_rec_ctr).ORDERED_QUANTITY       := line_rec.ORDERED_QUANTITY;
             p_line_ack_tbl(l_line_rec_ctr).ORG_ID                 := line_rec.ORG_ID;
             p_line_ack_tbl(l_line_rec_ctr).REQUEST_ID             := line_rec.REQUEST_ID;
             p_line_ack_tbl(l_line_rec_ctr).SCHEDULE_ARRIVAL_DATE  := line_rec.SCHEDULE_ARRIVAL_DATE;
             p_line_ack_tbl(l_line_rec_ctr).SCHEDULE_SHIP_DATE     := line_rec.SCHEDULE_SHIP_DATE;
             p_line_ack_tbl(l_line_rec_ctr).ACKNOWLEDGMENT_TYPE    := line_rec.ACKNOWLEDGMENT_TYPE;
             p_line_ack_tbl(l_line_rec_ctr).FLOW_STATUS_CODE       := line_rec.FLOW_STATUS_CODE;
             p_line_ack_tbl(l_line_rec_ctr).SPLIT_FROM_LINE_REF    := line_rec.SPLIT_FROM_LINE_REF;
             p_line_ack_tbl(l_line_rec_ctr).SPLIT_FROM_SHIPMENT_REF:= line_rec.SPLIT_FROM_SHIPMENT_REF;
             p_line_ack_tbl(l_line_rec_ctr).SPLIT_FROM_LINE_ID     := line_rec.SPLIT_FROM_LINE_ID;
	         -- Start : Added for Enh. 7244277, 7644412, 7644426
             p_line_ack_tbl(l_line_rec_ctr).TAX_VALUE              := line_rec.TAX_VALUE;
             p_line_ack_tbl(l_line_rec_ctr).AGREEMENT_ID           := line_rec.AGREEMENT_ID;
             p_line_ack_tbl(l_line_rec_ctr).PAYMENT_TERM_ID        := line_rec.PAYMENT_TERM_ID;
             p_line_ack_tbl(l_line_rec_ctr).PROMISE_DATE           := line_rec.PROMISE_DATE;
             p_line_ack_tbl(l_line_rec_ctr).SHIP_FROM_ORG_ID       := line_rec.SHIP_FROM_ORG_ID;
             p_line_ack_tbl(l_line_rec_ctr).SHIPPING_METHOD_CODE   := line_rec.SHIPPING_METHOD_CODE;
             p_line_ack_tbl(l_line_rec_ctr).SHIPMENT_PRIORITY_CODE := line_rec.SHIPMENT_PRIORITY_CODE;
             p_line_ack_tbl(l_line_rec_ctr).FREIGHT_TERMS_CODE     := line_rec.FREIGHT_TERMS_CODE;
             p_line_ack_tbl(l_line_rec_ctr).SHIP_TO_CUSTOMER_ID    := line_rec.SHIP_TO_CUSTOMER_ID;
             p_line_ack_tbl(l_line_rec_ctr).SHIP_TO_CONTACT_ID     := line_rec.SHIP_TO_CONTACT_ID;
             p_line_ack_tbl(l_line_rec_ctr).SHIP_TO_ORG_ID         := line_rec.SHIP_TO_ORG_ID;
             p_line_ack_tbl(l_line_rec_ctr).INVOICE_TO_CUSTOMER_ID := line_rec.INVOICE_TO_CUSTOMER_ID;
             p_line_ack_tbl(l_line_rec_ctr).INVOICE_TO_CONTACT_ID  := line_rec.INVOICE_TO_CONTACT_ID;
             p_line_ack_tbl(l_line_rec_ctr).INVOICE_TO_ORG_ID      := line_rec.INVOICE_TO_ORG_ID;
             p_line_ack_tbl(l_line_rec_ctr).UNIT_SELLING_PRICE     := line_rec.UNIT_SELLING_PRICE;
             p_line_ack_tbl(l_line_rec_ctr).PRICE_LIST_ID          := line_rec.PRICE_LIST_ID;
             p_line_ack_tbl(l_line_rec_ctr).UNIT_LIST_PRICE        := line_rec.UNIT_LIST_PRICE;
             p_line_ack_tbl(l_line_rec_ctr).UNIT_LIST_PRICE_PER_PQTY := line_rec.UNIT_LIST_PRICE_PER_PQTY;
             p_line_ack_tbl(l_line_rec_ctr).UNIT_PERCENT_BASE_PRICE := line_rec.UNIT_PERCENT_BASE_PRICE;
             p_line_ack_tbl(l_line_rec_ctr).UNIT_SELLING_PRICE_PER_PQTY := line_rec.UNIT_SELLING_PRICE_PER_PQTY;
             p_line_ack_tbl(l_line_rec_ctr).PRICING_DATE := line_rec.PRICING_DATE;
             p_line_ack_tbl(l_line_rec_ctr).SHIP_TO_ADDRESS_ID := line_rec.SHIP_TO_ADDRESS_ID;
             -- End : Added for Enh. 7244277, 7644412, 7644426
             p_line_ack_tbl(l_line_rec_ctr).SHIP_FROM_ORG := line_rec.SHIP_FROM_ORG;
             p_line_ack_tbl(l_line_rec_ctr).SHIP_TO_ORG := line_rec.SHIP_TO_ORG;
             p_line_ack_tbl(l_line_rec_ctr).INVOICE_TO_ORG := line_rec.INVOICE_TO_ORG;
             -- Bug 9131629
             p_line_ack_tbl(l_line_rec_ctr).ITEM_TYPE_CODE := line_rec.ITEM_TYPE_CODE;
             -- Bug 9151484
             p_line_ack_tbl(l_line_rec_ctr).LINE_CATEGORY_CODE := line_rec.LINE_CATEGORY_CODE;
       END LOOP;
   END IF;


   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('OE_SYNC_ORDER_PVT - Exiting process_order_sync');
   END IF;

EXCEPTION
   WHEN OTHERS THEN
     oe_debug_pub.add('EXCEPTION in OE_SYNC_ORDER_PVT');
      IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, 'process_order_sync');
      END IF;

END process_order_sync;

PROCEDURE raise_bpel_out_event(p_header_id          IN NUMBER DEFAULT NULL
                              ,p_line_id            IN NUMBER DEFAULT NULL
                              ,p_hdr_req_id         IN NUMBER DEFAULT NULL
                              ,p_lin_req_id         IN NUMBER DEFAULT NULL
                              ,p_change_type        IN VARCHAR2 DEFAULT NULL
                              ,p_hold_source_id     IN NUMBER DEFAULT NULL
                              ,p_order_hold_id      IN NUMBER DEFAULT NULL) IS

   l_parameter_list    wf_parameter_list_t := wf_parameter_list_t();
   l_itemkey           NUMBER;
   l_event_name        VARCHAR2(50);
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('OE_SYNC_ORDER_PVT - Entering raise_bpel_out_event');
      oe_debug_pub.add('raise_bpel_out_event - p_header_id     : '||p_header_id);
      oe_debug_pub.add('raise_bpel_out_event - p_line_id       : '||p_line_id);
      oe_debug_pub.add('raise_bpel_out_event - p_hdr_req_id    : '||p_hdr_req_id);
      oe_debug_pub.add('raise_bpel_out_event - p_lin_req_id    : '||p_lin_req_id);
      oe_debug_pub.add('raise_bpel_out_event - p_change_type   : '||p_change_type);
      oe_debug_pub.add('raise_bpel_out_event - p_hold_source_id: '||p_hold_source_id);
      oe_debug_pub.add('raise_bpel_out_event - p_order_hold_id : '||p_order_hold_id);
      oe_debug_pub.add('raise_bpel_out_event - Adding parameters to l_parameter_list');
   END IF;

   wf_event.AddParameterToList(p_name          => 'HEADER_ID'
                              ,p_value         => NVL(p_header_id, 0)
                              ,p_parameterlist => l_parameter_list);

   wf_event.AddParameterToList(p_name          => 'LINE_ID'
                              ,p_value         => NVL(p_line_id, 0)
                              ,p_parameterlist => l_parameter_list);

   wf_event.AddParameterToList(p_name          => 'HDR_REQ_ID'
                              ,p_value         => NVL(p_hdr_req_id, 0)
                              ,p_parameterlist => l_parameter_list);

   wf_event.AddParameterToList(p_name          => 'LIN_REQ_ID'
                              ,p_value         => NVL(p_lin_req_id, 0)
                              ,p_parameterlist => l_parameter_list);

   wf_event.AddParameterToList(p_name          => 'CHANGE_TYPE'
                              ,p_value         => NVL(p_change_type, 'XXX')
                              ,p_parameterlist => l_parameter_list);

   wf_event.AddParameterToList(p_name          => 'HOLD_SOURCE_ID'
                              ,p_value         => NVL(p_hold_source_id, 0)
                              ,p_parameterlist => l_parameter_list);

   wf_event.AddParameterToList(p_name          => 'ORDER_HOLD_ID'
                              ,p_value         => NVL(p_order_hold_id, 0)
                              ,p_parameterlist => l_parameter_list);

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('raise_bpel_out_event - Finished adding parameters to l_parameter_list');
   END IF;

   SELECT OE_XML_MESSAGE_SEQ_S.nextval /* New one to be seeded */
   INTO   l_itemkey
   FROM   DUAL;

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('raise_bpel_out_event - Generated value of l_itemkey: '||l_itemkey);
   END IF;

   l_event_name := 'oracle.apps.ont.genesis.outbound.update';
   wf_event.raise(p_event_name => l_event_name
                 ,p_event_key =>  l_itemkey
                 ,p_parameters => l_parameter_list);

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('raise_bpel_out_event - l_event_name: '||l_event_name);
      oe_debug_pub.add('raise_bpel_out_event - Raising event...');
   END IF;


   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('OE_SYNC_ORDER_PVT - Exiting raise_bpel_out_event');
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, 'raise_bpel_out_event');
      END IF;

END raise_bpel_out_event;

END OE_SYNC_ORDER_PVT;

/
