--------------------------------------------------------
--  DDL for Package Body RCV_INSERT_FROM_INL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_INSERT_FROM_INL" AS
/* $Header: RCVINSTB.pls 120.0.12010000.14 2013/11/18 06:23:49 yilali noship $ */

  PROCEDURE insert_rcv_tables (p_int_rec        IN rti_rec_table,
                               p_ship_header_id IN NUMBER)
  IS

  l_user_defined_ship_num_code          VARCHAR2(25);
  l_next_ship_num                       NUMBER;
  l_ship_num                            NUMBER;
  l_ship_type_id                        NUMBER;
  l_legal_entity_id                     NUMBER;
  l_taxation_country                    VARCHAR2(2);
  l_ship_header_int_id                  NUMBER;
  l_group_id                            NUMBER;
  l_party_id                            NUMBER;
  l_party_site_id                       NUMBER;
  l_ship_line_type_id                   NUMBER;
  l_trx_business_category               VARCHAR2(240);
  l_line_intended_use                   VARCHAR2(240);
  l_product_fisc_classification         VARCHAR2(240);
  l_product_category                    VARCHAR2(240);
  l_product_type                        VARCHAR2(240);
  l_user_defined_fisc_class             VARCHAR2(30);
  l_output_tax_classf_code              VARCHAR2(50);
  l_ship_lines_int_id                   NUMBER;
  l_org_id                              NUMBER;
  st                                    NUMBER := 1;

  l_vendor_id                           NUMBER;
  l_vendor_site_id                      NUMBER;
  l_ship_to_org_id                      NUMBER;
  l_receipt_num                         VARCHAR2(500);
  l_req_id                              NUMBER := 0;
  l_header_interface_id                 NUMBER;
  l_notice_creation_date                DATE;
  l_transaction_type                    VARCHAR2(50);
  l_processing_status_code              VARCHAR2(50);
  l_receipt_source_code                 VARCHAR2(50);
  l_validation_flag                     VARCHAR2(50);

  l_po_header_id                        NUMBER;
  l_po_line_id                          NUMBER;
  l_po_release_id                       NUMBER;

  l_interface_source_code               VARCHAR2(50);
  l_processing_mode_code                VARCHAR2(50);
  l_transaction_status_code             VARCHAR2(50);
  l_interface_transaction_id            NUMBER;

  cursor c_rcv_header(l_ship_header_id IN NUMBER, l_ship_line_group_id IN NUMBER)
  IS
  SELECT sh.organization_id,
-- Bug #7661019
         sh.ship_num||'.'||TO_CHAR(slg.ship_line_group_num) ship_num,
         sh.ship_header_id,
         ship_date,
         slg.ship_line_group_id,
         slg.party_id,
         slg.party_site_id,
         sh.org_id,
         slg.src_type_code
  FROM inl_ship_headers sh,
       inl_ship_line_groups slg
  WHERE sh.ship_header_id = slg.ship_header_id
  AND   sh.ship_header_id = l_ship_header_id
  AND   slg.ship_line_group_id = l_ship_line_group_id
  AND   slg.src_type_code = 'PO';

  l_rcv_header c_rcv_header%ROWTYPE;

  currentLineGrpId    NUMBER;
  l_primary_uom       VARCHAR2(25); /* Bug 8210608: Added to fetch unit_of_measure from uom_code */
  l_secondary_uom     VARCHAR2(25); -- Bug 8911750

  BEGIN

     asn_debug.put_line('Entering RCV_INSERT_FROM_INL.insert_rcv_tables' || to_char(sysdate,'DD-MON-YYYY HH:MI:SS'));
     asn_debug.put_line ('count: '||p_int_rec.COUNT);

     currentLineGrpId := -9999;
     for i in 1..p_int_rec.COUNT loop


	 if (currentLineGrpId <> p_int_rec(i).ship_line_group_id) then

	     if (currentLineGrpId <> -9999) then -- It is not the first record

/*
	        update RCV_TRANSACTIONS_INTERFACE RTI
		  set PROCESSING_STATUS_CODE = 'PENDING'
	       where RTI.header_interface_id = ( select rhi.header_interface_id
	                                         from rcv_headers_interface rhi
						 where rhi.header_interface_id = rti.header_interface_id
						 and rhi.group_id = rti.group_id
						 and rhi.receipt_header_id = p_int_rec(i).shipment_header_id)
	       and RTI.PROCESSING_STATUS_CODE = 'INSERTING';

	       asn_debug.put_line ('no of rows updated: '|| SQL%ROWCOUNT);

	       update rcv_headers_interface
	          set receipt_header_id = NULL
	       where receipt_header_id = p_int_rec(i).shipment_header_id;

*/

	       COMMIT;

	       -- launch RTP
	       -- bug 16274612 set OU_ID =NULL
               l_req_id := fnd_request.submit_request('PO', 'RVCTP',null,null,false,'BATCH',l_group_id,NULL,NULL,
               NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
               NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
               NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
               NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
               NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
               NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
               NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
               NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
               NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
               NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
               NULL, NULL, NULL, NULL, NULL, NULL);

	       asn_debug.put_line ('request id: '||l_req_id);

	       if (l_req_id <= 0 or l_req_id is null) then
	           raise fnd_api.g_exc_unexpected_error;
	       end if;

             -- null;

	     end if;

	     asn_debug.put_line ('ship line group id: '||p_int_rec(i).ship_line_group_id);

	     SELECT RCV_HEADERS_INTERFACE_S.NEXTVAL
             INTO   l_header_interface_id
             FROM   dual;

             SELECT RCV_INTERFACE_GROUPS_S.NEXTVAL
             INTO   l_group_id
             FROM   dual;

             l_notice_creation_date   := SYSDATE;
             l_transaction_type       := 'NEW';
             l_processing_status_code := 'PENDING';
             l_receipt_source_code    := 'VENDOR';
             l_validation_flag        := 'Y';

             asn_debug.put_line ('header interface id: '||l_header_interface_id);
             asn_debug.put_line ('group id: '||l_group_id);

	     /*
                receipt_header_id is used to store the LCM shipment header id in order to populate the
		next set of RTI columnss with the corresponding columns of the earlier set of RTIs.
	     */

             asn_debug.put_line ('ship_date: '||l_rcv_header.ship_date);

	     open c_rcv_header(p_ship_header_id, p_int_rec(i).ship_line_group_id);
	     fetch c_rcv_header into l_rcv_header;

	     /*SELECT apv.vendor_id,
                    aps.vendor_site_id
             INTO   l_vendor_id,
                    l_vendor_site_id
             FROM ap_supplier_sites aps,
                  ap_suppliers      apv
             WHERE aps.party_site_id = l_rcv_header.party_site_id
             AND   apv.party_id      = l_rcv_header.party_id
             AND   aps.org_id        = l_rcv_header.org_id;*/

	     -- Bug #8354404
      	     SELECT ph.vendor_id,
             	    ph.vendor_site_id
	       INTO l_vendor_id,
             	    l_vendor_site_id
               FROM po_headers ph,
             	    po_line_locations pll
       	      WHERE ph.po_header_id = pll.po_header_id
                AND pll.line_location_id = p_int_rec(i).ship_line_source_id;


	     INSERT INTO RCV_HEADERS_INTERFACE
             (header_interface_id,
              group_id,
              processing_status_code,
              receipt_source_code,
              transaction_type,
              ship_to_organization_id,
              notice_creation_date,
              vendor_id,
              vendor_site_id,
              validation_flag,
              shipped_date,
              shipment_num,
	      asn_type,
              EXPECTED_RECEIPT_DATE,                         --add by bug 16982460
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login)
              VALUES
	      (l_header_interface_id,
              l_group_id,
              l_processing_status_code,
              l_receipt_source_code,
              l_transaction_type,
	      l_rcv_header.organization_id,
              l_notice_creation_date,
              l_vendor_id,
              l_vendor_site_id,
              l_validation_flag,
              l_rcv_header.ship_date,
              l_rcv_header.ship_num,
	      'LCM',
              sysdate,                                       --add by bug 16982460
              sysdate,
              fnd_global.user_id,
              sysdate,
              fnd_global.user_id,
              fnd_global.login_id);

              currentLineGrpId := p_int_rec(i).ship_line_group_id;

              IF c_rcv_header%ISOPEN THEN
                 CLOSE c_rcv_header;
              END IF;

              asn_debug.put_line ('inserted header');

         end if;

	    asn_debug.put_line ('ship line group ID: '||p_int_rec(i).ship_line_group_id);

            l_interface_source_code   := 'LCM';
            l_transaction_type        := 'SHIP';
            l_processing_status_code  := 'PENDING';
            l_processing_mode_code    := 'BATCH';
            l_transaction_status_code := 'PENDING';
            l_receipt_source_code     := 'VENDOR';
            l_validation_flag         := 'Y';

	    SELECT pll.po_header_id, pll.po_line_id, pll.po_release_id
            INTO   l_po_header_id, l_po_line_id, l_po_release_id
            FROM   po_line_locations pll,
                   po_headers ph
            WHERE  ph.po_header_id = pll.po_header_id
            AND    pll.line_location_id = p_int_rec(i).ship_line_source_id;


            /* Bug 8210608: Fetching unit_of_measure from uom_code */
            BEGIN

            SELECT UNIT_OF_MEASURE
            INTO   l_primary_uom
            FROM   mtl_units_of_measure_vl
            WHERE  uom_code = p_int_rec(i).primary_uom_code;

            EXCEPTION
               WHEN OTHERS THEN
                  l_primary_uom := NULL;
            END;

            -- Bug 8911750
            BEGIN
            SELECT UNIT_OF_MEASURE
            INTO   l_secondary_uom
            FROM   mtl_units_of_measure_vl
            WHERE  uom_code = p_int_rec(i).secondary_uom_code;

            EXCEPTION
               WHEN OTHERS THEN
                  l_secondary_uom := NULL;
            END;


	    SELECT RCV_TRANSACTIONS_INTERFACE_S.NEXTVAL
            INTO   l_interface_transaction_id
            FROM   dual;

            asn_debug.put_line ('interface id: '||l_interface_transaction_id);
            asn_debug.put_line ('lcm line id: '||p_int_rec(i).interface_source_line_id);
            asn_debug.put_line ('landed cost: '||p_int_rec(i).unit_landed_cost);

               INSERT INTO rcv_transactions_interface
               (interface_transaction_id,      -- 01
                group_id,                      -- 02
                lpn_group_id,                  -- 03
                transaction_type,              -- 04
                transaction_date,              -- 05
                processing_status_code,        -- 06
                processing_mode_code,          -- 07
                transaction_status_code,       -- 08
                quantity,                      -- 09
                uom_code,                      -- 10
                ship_to_location_id,           -- 11
                vendor_item_num,               -- 12
                interface_source_code,         -- 13
                interface_source_line_id,      -- 14
                item_id,                       -- 15
                item_num,                      -- 16
                item_description,              -- 17
                receipt_source_code,           -- 18
                vendor_id,                     -- 19
                vendor_site_id,                -- 20
                source_document_code,          -- 21
                po_header_id,                  -- 22
                po_line_id,                    -- 23
                po_release_id,                 -- 24
                po_line_location_id,           -- 25
                header_interface_id,           -- 26
                validation_flag,               -- 27
                org_id,                        -- 28
                to_organization_id,            -- 29
                location_id,                   -- 30
                deliver_to_location_id,        -- 31
                last_update_date,              -- 32
                last_updated_by,               -- 33
                creation_date,                 -- 34
                created_by,                    -- 35
                last_update_login,             -- 36
		lcm_shipment_line_id,              -- 37
                unit_landed_cost,              -- 38
		auto_transact_code,                -- 39
                primary_quantity,              -- 40 /* Bug 8210608 */
                primary_unit_of_measure,       -- 41 /* Bug 8210608 */
                secondary_quantity,            -- 42 /* Bug 8911750 */
                secondary_uom_code,            -- 43 /* Bug 8911750 */
                secondary_unit_of_measure,     -- 44 /* Bug 8911750 */
                EXPECTED_RECEIPT_DATE)         -- 45 add by 16982460
                VALUES(
		l_interface_transaction_id,           -- 01
                l_group_id,                       -- 02
                l_group_id,                       -- 03
                l_transaction_type,               -- 04
                sysdate,                          -- 05
                l_processing_status_code,         -- 06
                l_processing_mode_code,           -- 07
                l_transaction_status_code,        -- 08
                p_int_rec(i).txn_qty,             -- 09
                p_int_rec(i).txn_uom_code,        -- 10
                p_int_rec(i).location_id,         -- 11
                p_int_rec(i).VENDOR_PRODUCT_NUM,  -- 12 --Added for bug # 17631658
                l_interface_source_code,          -- 13
                p_int_rec(i).ship_line_id,        -- 14
                p_int_rec(i).inventory_item_id,   -- 15
                NULL,                             -- 16
                p_int_rec(i).item_description,    -- 17
                l_receipt_source_code,            -- 18
                l_vendor_id,                      -- 19
                l_vendor_site_id,                 -- 20
                p_int_rec(i).src_type_code,       -- 21
                l_po_header_id,                   -- 22
                l_po_line_id,                     -- 23
                l_po_release_id,                  -- 24
                p_int_rec(i).ship_line_source_id, -- 25
                l_header_interface_id,            -- 26
                l_validation_flag,                -- 27
                p_int_rec(i).org_id,              -- 28
                p_int_rec(i).organization_id,     -- 29
                p_int_rec(i).location_id,         -- 30
                p_int_rec(i).location_id,         -- 31
                sysdate,                          -- 32
                fnd_global.user_id,               -- 33
                sysdate,                          -- 34
                fnd_global.user_id,               -- 35
                fnd_global.login_id,              -- 36
                p_int_rec(i).ship_line_id,        -- 37
		p_int_rec(i).unit_landed_cost,        -- 38
		'SHIP',                               -- 39
                p_int_rec(i).primary_qty,         -- 40   /* Bug 8210608 */
                l_primary_uom,                    -- 41   /* Bug 8210608 */
                p_int_rec(i).secondary_qty,       -- 42   /* Bug 8911750 */
                p_int_rec(i).secondary_uom_code,  -- 43   /* Bug 8911750 */
                l_secondary_uom,                  -- 44   /* Bug 8911750 */
                sysdate);                         -- 45 add by 16982460
       asn_debug.put_line('inserted line');

     end loop;
     COMMIT;

     -- launch RTP
     -- bug 16274612 set OU_ID =NULL
     l_req_id := fnd_request.submit_request('PO', 'RVCTP',null,null,false,'BATCH',l_group_id,NULL,NULL,
     NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
     NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
     NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL, NULL, NULL,
     NULL, NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL, NULL,
     NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL, NULL,
     NULL, NULL, NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL,
     NULL,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
     NULL, NULL, NULL, NULL, NULL,NULL, NULL, NULL, NULL, NULL,
     NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
     NULL, NULL, NULL, NULL, NULL, NULL);

     asn_debug.put_line ('request id: '||l_req_id);

     if (l_req_id <= 0 or l_req_id is null) then
        raise fnd_api.g_exc_unexpected_error;
     end if;

  EXCEPTION
    WHEN OTHERS THEN

      IF c_rcv_header%ISOPEN THEN
         CLOSE c_rcv_header;
      END IF;

      ROLLBACK;

      asn_debug.put_line('the error is:  ' || sqlcode ||' '||substr(SQLERRM, 1, 1000));

  END insert_rcv_tables;

END RCV_INSERT_FROM_INL;


/
