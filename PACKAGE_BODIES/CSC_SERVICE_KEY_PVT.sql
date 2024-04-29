--------------------------------------------------------
--  DDL for Package Body CSC_SERVICE_KEY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_SERVICE_KEY_PVT" AS
/* $Header: cscvpskb.pls 120.6 2006/04/17 21:14:32 kjhamb noship $ */

 -- This procedure accepts service key name, service key value and returns all
 -- ID information that are found when search is made on a servcie key name and
 -- value.
 PROCEDURE Service_Key_Search (
    p_skey_name IN VARCHAR2,
    p_skey_value IN VARCHAR2,
    x_hdr_info_tbl OUT NOCOPY HDR_INFO_TBL_TYPE )
 IS
   -- Local Variable declaration
   l_skey_value 	VARCHAR2(2000);
   l_skey_name 		VARCHAR2(40);
   l_party_id		NUMBER;
   l_object_id		NUMBER;
   l_incident_id	NUMBER;
   l_contact_point_type VARCHAR2(30);
   l_contact_type	VARCHAR2(100);
   l_count 		NUMBER :=0;
   l_hdr_info_tbl       CSC_SERVICE_KEY_PVT.hdr_info_tbl_type;
   l_sold_to_contact_id NUMBER;

   -- Cursor declaration for Service Keys

   -- Service Request
   -- Querying Customer information using service request number
   CURSOR SR_Customer_Cur IS
	SELECT incident_id, customer_id, customer_phone_id, customer_email_id,
	       account_id
   	FROM cs_incidents_all_b
	WHERE incident_number = l_skey_value;

  -- Querying Contact Information using Incident Id
   CURSOR SR_Contact_Cur IS
  	SELECT party_id, contact_point_id, contact_point_type, contact_type
 	FROM cs_hz_sr_contact_points
	WHERE primary_flag = 'Y' AND
	      --contact_type <> 'EMPLOYEE' AND
	      incident_id = l_incident_id;

  -- Querying secondary contact point for a contact
   CURSOR SR_sec_cont_pt_cur  IS
	SELECT contact_point_id, contact_point_type
	FROM cs_hz_sr_contact_points
	WHERE incident_id = l_incident_id AND
	      party_id = l_party_id AND
	      contact_point_type = l_contact_point_type AND
	      rownum < 2;

   -- Querying subject party id for a contact
    CURSOR party_cont_sub_id_cur IS
	SELECT subject_id
	FROM hz_relationships
	WHERE party_id = l_party_id AND
	      subject_type = 'PERSON' AND
              object_id = l_object_id;

   -- Invoice Number
    CURSOR invoice_num_cur IS
	SELECT cust_acct.party_id, cust_acct.cust_account_id, customer_trx_id, ra.org_id org_id
	FROM hz_cust_accounts cust_acct, ra_customer_trx_all ra
	WHERE cust_acct.cust_account_id = ra.bill_to_customer_id AND
	      ra.complete_flag = 'Y' AND
	      ra.cust_trx_type_id IN
			( SELECT cust_trx_type_id FROM ra_cust_trx_types_all
			  WHERE type = 'INV') AND
	      ra.trx_number = l_skey_value;

   -- Invoice Number -- MOAC
    CURSOR invoice_num_moac_cur IS
	SELECT cust_acct.party_id, cust_acct.cust_account_id, customer_trx_id, ra.org_id org_id
	FROM hz_cust_accounts cust_acct, ra_customer_trx ra
	WHERE cust_acct.cust_account_id = ra.bill_to_customer_id AND
	      ra.complete_flag = 'Y' AND
	      ra.cust_trx_type_id IN
			( SELECT cust_trx_type_id FROM ra_cust_trx_types
			  WHERE type = 'INV') AND
	      ra.trx_number = l_skey_value;

    -- Order Number
    CURSOR order_num_cur IS
	SELECT hza.party_id, hza.cust_account_id, oe.header_id, oe.org_id, oe.sold_to_contact_id
	FROM oe_order_headers_all oe, hz_cust_accounts hza
	WHERE oe.sold_to_org_id = hza.cust_account_id AND
	      oe.order_number = l_skey_value;

     CURSOR order_contact_cur IS
        SELECT party_id
        FROM hz_cust_account_roles
        WHERE cust_account_role_id = l_sold_to_contact_id;


  -- Order Number -- MOAC
    CURSOR order_num_moac_cur IS
	SELECT hza.party_id, hza.cust_account_id, oe.header_id, oe.org_id, oe.sold_to_contact_id
	FROM oe_order_headers oe, hz_cust_accounts hza
	WHERE oe.sold_to_org_id = hza.cust_account_id AND
	      oe.order_number = l_skey_value;

  -- RMA Number
    CURSOR rma_num_cur IS
	SELECT hza.party_id, hza.cust_account_id, oe.header_id, oe.org_id, oe.sold_to_contact_id
	FROM oe_order_headers_all oe, hz_cust_accounts hza
	WHERE oe.sold_to_org_id = hza.cust_account_id AND
-- Bug Fix 5136678 Added 'Mixed' Category Code
	      oe.order_category_code IN ('RETURN','MIXED') AND
	      oe.order_number = l_skey_value;

  -- RMA Number MOAC
    CURSOR rma_num_moac_cur IS
	SELECT hza.party_id, hza.cust_account_id, oe.header_id, oe.org_id, oe.sold_to_contact_id
	FROM oe_order_headers oe, hz_cust_accounts hza
	WHERE oe.sold_to_org_id = hza.cust_account_id AND
--Bug Fix 5136678 Added 'Mixed' Category Code
	      oe.order_category_code IN ('RETURN','MIXED') AND
	      oe.order_number = l_skey_value;

  -- Contract Number
    CURSOR contract_num_cur IS
	SELECT party_id, contract_id
	FROM oks_ent_hdr_summary_v
        WHERE contract_number = l_skey_value;

   -- System
    CURSOR system_cur IS
	SELECT hca.party_id, hca.cust_account_id, csb.system_id
	FROM csi_systems_vl csb, hz_cust_accounts hca
	WHERE csb.customer_id = hca.cust_account_id
	AND csb.name = l_skey_value;

   -- Tag Number
    CURSOR tag_num_cur IS
	SELECT item.owner_party_id, item.owner_party_account_id, instance_id
	FROM csi_item_instances item
	WHERE item.external_reference IS NOT NULL
	AND item.external_reference = l_skey_value;

  -- Serial Number
    CURSOR serial_num_cur IS
	SELECT item.owner_party_id, item.owner_party_account_id, instance_id
	FROM csi_item_instances item
	WHERE item.serial_number  IS NOT NULL
	AND item.serial_number = l_skey_value;

  -- Instance Name
   CURSOR instance_name_cur IS
       SELECT owner_party_id, owner_party_account_id, instance_id
       FROM csi_item_instances
       WHERE owner_party_source_table = 'HZ_PARTIES'
       AND instance_description IS NOT NULL
       AND instance_description = l_skey_value;

  -- Instance Number
   CURSOR instance_num_cur IS
       SELECT owner_party_id, owner_party_account_id, instance_id
       FROM csi_item_instances
       WHERE owner_party_source_table = 'HZ_PARTIES'
       AND instance_number IS NOT NULL
       AND instance_number = l_skey_value;

  --SSN
   CURSOR SSN_cur IS
 	SELECT party_id
        FROM hz_parties
	WHERE jgzz_fiscal_code = l_skey_value;


BEGIN

   l_skey_value := p_skey_value;
   l_skey_name  := p_skey_name;
   IF JTF_USR_HKS.ok_to_Execute('CSC_SERVICE_KEY_PVT', 'SERVICE_KEY_SEARCH', 'B', 'C') THEN
      CSC_Service_Key_CUHK.Service_Key_Search_Pre(p_skey_name => l_skey_name,
						  p_skey_value => l_skey_value,
						  x_hdr_info_tbl => l_hdr_info_tbl);
      x_hdr_info_tbl := l_hdr_info_tbl;
   ELSE
    IF p_skey_name = 'SERVICE_REQUEST_NUMBER' THEN
      FOR sr_customer_rec IN sr_customer_cur
      LOOP
	  l_count := l_count + 1;
	  x_hdr_info_tbl(l_count).cust_party_id := sr_customer_rec.customer_id;
          l_object_id := x_hdr_info_tbl(l_count).cust_party_id;
	  x_hdr_info_tbl(l_count).cust_phone_id :=
					sr_customer_rec.customer_phone_id;
	  x_hdr_info_tbl(l_count).cust_email_id :=
					sr_customer_rec.customer_email_id;
	  x_hdr_info_tbl(l_count).account_id := sr_customer_rec.account_id;
          l_incident_id := sr_customer_rec.incident_id;
	  x_hdr_info_tbl(l_count).service_key_id := l_incident_id;

          --IF l_incident_id IS NOT NULL THEN
	     FOR sr_contact_rec IN sr_contact_cur
  	     LOOP
	         l_contact_type := sr_contact_rec.contact_type;
	         IF l_contact_type = 'EMPLOYEE' THEN
		   x_hdr_info_tbl(l_count).employee_id :=
						sr_contact_rec.party_id;
                 ELSE
		   x_hdr_info_tbl(l_count).rel_party_id :=
						sr_contact_rec.party_id;
                 END IF;
                 l_party_id :=  sr_contact_rec.party_id;
		 l_contact_point_type := sr_contact_rec.contact_point_type;

 		 IF l_contact_point_type = 'PHONE' THEN
		    x_hdr_info_tbl(l_count).rel_phone_id :=
					sr_contact_rec.contact_point_id;
		    l_contact_point_type := 'EMAIL';
		    FOR sr_sec_cont_pt_rec IN sr_sec_cont_pt_cur
		    LOOP
		       x_hdr_info_tbl(l_count).rel_email_id :=
				  	sr_sec_cont_pt_rec.contact_point_id;
		    END LOOP;
 		 ELSIF l_contact_point_type = 'EMAIL' THEN
		    x_hdr_info_tbl(l_count).rel_email_id :=
					sr_contact_rec.contact_point_id;
		    l_contact_point_type := 'PHONE';
		    FOR sr_sec_cont_pt_rec IN sr_sec_cont_pt_cur
		    LOOP
		       x_hdr_info_tbl(l_count).rel_phone_id :=
				  	sr_sec_cont_pt_rec.contact_point_id;
		    END LOOP;
		 END IF;
		 l_party_id :=  x_hdr_info_tbl(l_count).rel_party_id;
		 FOR sr_cont_sub_id_rec IN party_cont_sub_id_cur
  		 LOOP
		     x_hdr_info_tbl(l_count).per_party_id :=
					sr_cont_sub_id_rec.subject_id;
		 END LOOP;
	     END LOOP;
	     IF x_hdr_info_tbl(l_count).rel_party_id = x_hdr_info_tbl(l_count).cust_party_id AND
                 x_hdr_info_tbl(l_count).per_party_id IS NULL THEN
                 x_hdr_info_tbl(l_count).per_party_id := x_hdr_info_tbl(l_count).cust_party_id;
             END IF;

	  --END IF;

      END LOOP;

   ELSIF p_skey_name = 'INVOICE_NUMBER' THEN
    if mo_global.get_access_mode = 'M' then
     FOR invoice_num_rec IN invoice_num_moac_cur
     LOOP
	l_count := l_count + 1;
	x_hdr_info_tbl(l_count).cust_party_id  := invoice_num_rec.party_id;
	x_hdr_info_tbl(l_count).account_id     := invoice_num_rec.cust_account_id;
	x_hdr_info_tbl(l_count).service_key_id := invoice_num_rec.customer_trx_id;
        -- Added org_id as part of the MOAC project. This org_id will be used to
        -- populate the oeprating unit in the header.
	x_hdr_info_tbl(l_count).org_id := invoice_num_rec.org_id;
     END LOOP;
    else
     FOR invoice_num_rec IN invoice_num_cur
     LOOP
	l_count := l_count + 1;
	x_hdr_info_tbl(l_count).cust_party_id  := invoice_num_rec.party_id;
	x_hdr_info_tbl(l_count).account_id     := invoice_num_rec.cust_account_id;
	x_hdr_info_tbl(l_count).service_key_id := invoice_num_rec.customer_trx_id;
        -- Added org_id as part of the MOAC project. This org_id will be used to
        -- populate the oeprating unit in the header.
	x_hdr_info_tbl(l_count).org_id := invoice_num_rec.org_id;
     END LOOP;
    end if;

   ELSIF p_skey_name = 'ORDER_NUMBER' THEN
    IF mo_global.get_access_mode = 'M' THEN
     FOR order_num_rec IN order_num_moac_cur
     LOOP
	l_count := l_count + 1;
	x_hdr_info_tbl(l_count).cust_party_id  := order_num_rec.party_id;
	x_hdr_info_tbl(l_count).account_id     := order_num_rec.cust_account_id;
	x_hdr_info_tbl(l_count).service_key_id := order_num_rec.header_id;
        -- Added org_id as part of the MOAC project. This org_id will be used to
        -- populate the oeprating unit in the header.
	x_hdr_info_tbl(l_count).org_id := order_num_rec.org_id;

        -- Included following logic to identify Contact for the order
        l_sold_to_contact_id := order_num_rec.sold_to_contact_id;
        FOR order_contact_rec IN order_contact_cur
        LOOP
            x_hdr_info_tbl(l_count).rel_party_id := order_contact_rec.party_id;
        END LOOP;
        l_party_id := x_hdr_info_tbl(l_count).rel_party_id;
        l_object_id := x_hdr_info_tbl(l_count).cust_party_id;
        FOR order_cont_sub_id_rec IN party_cont_sub_id_cur
        LOOP
            x_hdr_info_tbl(l_count).per_party_id :=  order_cont_sub_id_rec.subject_id;
        END LOOP;
	IF x_hdr_info_tbl(l_count).rel_party_id = x_hdr_info_tbl(l_count).cust_party_id AND
           x_hdr_info_tbl(l_count).per_party_id IS NULL THEN
           x_hdr_info_tbl(l_count).per_party_id := x_hdr_info_tbl(l_count).cust_party_id;
        END IF;

     END LOOP;
    ELSE
     FOR order_num_rec IN order_num_cur
     LOOP
	l_count := l_count + 1;
	x_hdr_info_tbl(l_count).cust_party_id  := order_num_rec.party_id;
	x_hdr_info_tbl(l_count).account_id     := order_num_rec.cust_account_id;
	x_hdr_info_tbl(l_count).service_key_id := order_num_rec.header_id;
        -- Added org_id as part of the MOAC project. This org_id will be used to
        -- populate the oeprating unit in the header.
	x_hdr_info_tbl(l_count).org_id := order_num_rec.org_id;

        -- Included following logic to identify Contact for the order
        l_sold_to_contact_id := order_num_rec.sold_to_contact_id;
	FOR order_contact_rec IN order_contact_cur
        LOOP
            x_hdr_info_tbl(l_count).rel_party_id := order_contact_rec.party_id;
        END LOOP;
        l_party_id := x_hdr_info_tbl(l_count).rel_party_id;
        l_object_id := x_hdr_info_tbl(l_count).cust_party_id;
        FOR order_cont_sub_id_rec IN party_cont_sub_id_cur
        LOOP
              x_hdr_info_tbl(l_count).per_party_id :=  order_cont_sub_id_rec.subject_id;
        END LOOP;
	IF x_hdr_info_tbl(l_count).rel_party_id = x_hdr_info_tbl(l_count).cust_party_id AND
           x_hdr_info_tbl(l_count).per_party_id IS NULL THEN
           x_hdr_info_tbl(l_count).per_party_id := x_hdr_info_tbl(l_count).cust_party_id;
        END IF;

      END LOOP;
     END IF;

   ELSIF p_skey_name = 'RMA_NUMBER' THEN
    IF mo_global.get_access_mode = 'M' THEN
     FOR rma_num_rec IN rma_num_moac_cur
     LOOP
	l_count := l_count + 1;
	x_hdr_info_tbl(l_count).cust_party_id  := rma_num_rec.party_id;
	x_hdr_info_tbl(l_count).account_id     := rma_num_rec.cust_account_id;
	x_hdr_info_tbl(l_count).service_key_id := rma_num_rec.header_id;
        -- Added org_id as part of the MOAC project. This org_id will be used to
        -- populate the oeprating unit in the header.
	x_hdr_info_tbl(l_count).org_id := rma_num_rec.org_id;

        -- Included following logic to identify Contact for the order
        l_sold_to_contact_id := rma_num_rec.sold_to_contact_id;
        FOR rma_contact_rec IN order_contact_cur
        LOOP
           x_hdr_info_tbl(l_count).rel_party_id := rma_contact_rec.party_id;
        END LOOP; -- end loop for order_contact_rec
        l_party_id := x_hdr_info_tbl(l_count).rel_party_id;
        l_object_id := x_hdr_info_tbl(l_count).cust_party_id;
        FOR rma_cont_sub_id_rec IN party_cont_sub_id_cur
        LOOP
           x_hdr_info_tbl(l_count).per_party_id :=  rma_cont_sub_id_rec.subject_id;
        END LOOP; -- end loop for order_cont_sub_id_rec
	IF x_hdr_info_tbl(l_count).rel_party_id = x_hdr_info_tbl(l_count).cust_party_id AND
           x_hdr_info_tbl(l_count).per_party_id IS NULL THEN
           x_hdr_info_tbl(l_count).per_party_id := x_hdr_info_tbl(l_count).cust_party_id;
        END IF;

      END LOOP; -- end loop for rma_num_rec

    ELSE  -- else for mo_global.get_access_mode

     FOR rma_num_rec IN rma_num_cur
     LOOP
	l_count := l_count + 1;
	x_hdr_info_tbl(l_count).cust_party_id  := rma_num_rec.party_id;
	x_hdr_info_tbl(l_count).account_id     := rma_num_rec.cust_account_id;
	x_hdr_info_tbl(l_count).service_key_id := rma_num_rec.header_id;
        -- Added org_id as part of the MOAC project. This org_id will be used to
        -- populate the oeprating unit in the header.
	x_hdr_info_tbl(l_count).org_id := rma_num_rec.org_id;

        -- Included following logic to identify Contact for the order
        l_sold_to_contact_id := rma_num_rec.sold_to_contact_id;
        FOR rma_contact_rec IN order_contact_cur
        LOOP
           x_hdr_info_tbl(l_count).rel_party_id := rma_contact_rec.party_id;
        END LOOP; -- end loop for rma_contact_rec
        l_party_id := x_hdr_info_tbl(l_count).rel_party_id;
        l_object_id := x_hdr_info_tbl(l_count).cust_party_id;
        FOR rma_cont_sub_id_rec IN party_cont_sub_id_cur
        LOOP
            x_hdr_info_tbl(l_count).per_party_id :=  rma_cont_sub_id_rec.subject_id;
        END LOOP; -- end loop for rma_cont_sub_id_rec
	IF x_hdr_info_tbl(l_count).rel_party_id = x_hdr_info_tbl(l_count).cust_party_id AND
           x_hdr_info_tbl(l_count).per_party_id IS NULL THEN
           x_hdr_info_tbl(l_count).per_party_id := x_hdr_info_tbl(l_count).cust_party_id;
        END IF;

     END LOOP; -- end loop for rma_num_rec
    END IF; -- end if for mo_global.get_access_mode

   ELSIF p_skey_name = 'CONTRACT_NUMBER' THEN
     FOR contract_num_rec IN contract_num_cur
     LOOP
	l_count := l_count + 1;
	x_hdr_info_tbl(l_count).cust_party_id  := contract_num_rec.party_id;
	x_hdr_info_tbl(l_count).service_key_id := contract_num_rec.contract_id;
     END LOOP;
   ELSIF p_skey_name = 'SYSTEM_NUMBER' THEN
     FOR system_rec IN system_cur
     LOOP
	l_count := l_count + 1;
	x_hdr_info_tbl(l_count).cust_party_id  := system_rec.party_id;
	x_hdr_info_tbl(l_count).account_id     := system_rec.cust_account_id;
	x_hdr_info_tbl(l_count).service_key_id := system_rec.system_id;
     END LOOP;
   ELSIF p_skey_name = 'EXTERNAL_REFERENCE' THEN
     FOR tag_num_rec IN tag_num_cur
     LOOP
	l_count := l_count + 1;
	x_hdr_info_tbl(l_count).cust_party_id  := tag_num_rec.owner_party_id;
	x_hdr_info_tbl(l_count).account_id     := tag_num_rec.owner_party_account_id;
	x_hdr_info_tbl(l_count).service_key_id := tag_num_rec.instance_id;
     END LOOP;
   ELSIF p_skey_name = 'SERIAL_NUMBER' THEN
     FOR serial_num_rec IN serial_num_cur
     LOOP
	l_count := l_count + 1;
	x_hdr_info_tbl(l_count).cust_party_id  := serial_num_rec.owner_party_id;
	x_hdr_info_tbl(l_count).account_id     := serial_num_rec.owner_party_account_id;
	x_hdr_info_tbl(l_count).service_key_id := serial_num_rec.instance_id;
     END LOOP;
   ELSIF p_skey_name = 'INSTANCE_NAME' THEN
     FOR instance_name_rec IN instance_name_cur
     LOOP
	l_count := l_count + 1;
	x_hdr_info_tbl(l_count).cust_party_id  := instance_name_rec.owner_party_id;
	x_hdr_info_tbl(l_count).account_id     := instance_name_rec.owner_party_account_id;
	x_hdr_info_tbl(l_count).service_key_id := instance_name_rec.instance_id;
     END LOOP;
   ELSIF p_skey_name = 'INSTANCE_NUMBER' THEN
     FOR instance_num_rec IN instance_num_cur
     LOOP
	l_count := l_count + 1;
	x_hdr_info_tbl(l_count).cust_party_id  := instance_num_rec.owner_party_id;
	x_hdr_info_tbl(l_count).account_id     := instance_num_rec.owner_party_account_id;
	x_hdr_info_tbl(l_count).service_key_id := instance_num_rec.instance_id;
     END LOOP;
   ELSIF p_skey_name = 'SSN' THEN
     FOR SSN_rec in SSN_cur
     LOOP
	l_count := l_count + 1;
        x_hdr_info_tbl(l_count).cust_party_id  := SSN_rec.party_id;
     END LOOP;
   END IF;

   END IF;
 EXCEPTION
 --WHEN INVALID_NUMBER THEN
    --FND_MESSAGE.Set_Name('CSC', 'CSC_INVALID_NUMBER');
    --FND_MESSAGE.Set_Token('PARAMETER', 'Order');
    --APP_EXCEPTION.raise_exception;
 WHEN OTHERS THEN
     FND_MSG_PUB.Build_Exc_Msg( p_pkg_name => 'CSC_SERVICE_KEY_PVT',
				p_procedure_name => 'Service_Key_Search');
     APP_EXCEPTION.raise_exception;
 END Service_Key_Search;

END CSC_SERVICE_KEY_PVT;

/
