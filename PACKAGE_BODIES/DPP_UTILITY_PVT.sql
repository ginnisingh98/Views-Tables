--------------------------------------------------------
--  DDL for Package Body DPP_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DPP_UTILITY_PVT" AS
/* $Header: dppvutlb.pls 120.43.12010000.12 2010/04/21 11:36:09 anbbalas ship $ */
PROCEDURE Check_Transaction(
   p_transaction_header_id IN NUMBER
  ,p_status_change             IN VARCHAR2
  ,x_rec_count                 OUT NOCOPY NUMBER
  ,x_msg_data                  OUT NOCOPY VARCHAR2
  ,x_return_status             OUT NOCOPY      VARCHAR2)
  IS
  l_item_number VARCHAR2(100);
  l_flag VARCHAR2(30) :=NULL;
  l_process_code VARCHAR2(100);

 CURSOR select_claims_csr(p_transaction_header_id IN VARCHAR2)
  IS
  SELECT ocl.claim_number
  FROM  ozf_claims_all ocl,
         dpp_transaction_claims_all dtcl
 WHERE dtcl.transaction_header_id = p_transaction_header_id
   AND dtcl.claim_type IN('SUPP_CUST_CL','SUPP_DSTR_CL','SUPP_DSTR_INC_CL','CUST_CL')
   AND dtcl.claim_id = ocl.claim_id
   AND ocl.status_code <> 'CLOSED';

 BEGIN
 x_rec_count := 0;
 x_msg_data := '';
 Fnd_Msg_Pub.initialize;

  x_return_status := fnd_api.g_ret_sts_success;

 IF p_status_change = 'CANCELLED' THEN
 BEGIN
 SELECT   DISTINCT 'Y' INTO l_flag
   FROM dpp_transaction_lines_all  dtla
 WHERE transaction_header_id = p_transaction_header_id
   AND update_purchasing_docs IN ('Y','P')  ;
    SELECT meaning
      INTO l_process_code
      FROM fnd_lookups
     WHERE lookup_type LIKE 'DPP_EXECUTION_PROCESSES%'
    AND lookup_code ='UPDTPO';
      fnd_message.set_name('DPP', 'DPP_EXE_PROCESS_REQUESTED');
      fnd_message.set_token('PROCESS_CODE', l_process_code);
      fnd_msg_pub.add;
  EXCEPTION WHEN OTHERS THEN
    NULL;
  END;


 BEGIN
   SELECT   DISTINCT 'Y' INTO l_flag
     FROM dpp_transaction_lines_all  dtla
    WHERE transaction_header_id = p_transaction_header_id
      AND update_inventory_costing IN ('Y','P')  ;
    SELECT meaning
      INTO l_process_code
      FROM fnd_lookups
     WHERE lookup_type LIKE 'DPP_EXECUTION_PROCESSES%'
    AND lookup_code ='INVC';
      fnd_message.set_name('DPP', 'DPP_EXE_PROCESS_REQUESTED');
      fnd_message.set_token('PROCESS_CODE', l_process_code);
      fnd_msg_pub.add;
    EXCEPTION WHEN OTHERS THEN
    NULL;
 END;


 BEGIN
   SELECT   DISTINCT 'Y' INTO l_flag
     FROM dpp_transaction_lines_all  dtla
    WHERE transaction_header_id = p_transaction_header_id
      AND update_item_list_price IN ('Y','P')  ;
    SELECT meaning
      INTO l_process_code
      FROM fnd_lookups
     WHERE lookup_type LIKE 'DPP_EXECUTION_PROCESSES%'
    AND lookup_code ='UPDTLP';
      fnd_message.set_name('DPP', 'DPP_EXE_PROCESS_REQUESTED');
      fnd_message.set_token('PROCESS_CODE', l_process_code);
      fnd_msg_pub.add;
    EXCEPTION WHEN OTHERS THEN
    NULL;
 END;

  BEGIN
   SELECT   DISTINCT 'Y' INTO l_flag
     FROM dpp_transaction_lines_all  dtla
    WHERE transaction_header_id = p_transaction_header_id
      AND supp_dist_claim_status IN ('Y','P')  ;
    SELECT meaning
      INTO l_process_code
      FROM fnd_lookups
     WHERE lookup_type LIKE 'DPP_EXECUTION_PROCESSES%'
    AND lookup_code ='DSTRINVCL';
      fnd_message.set_name('DPP', 'DPP_EXE_PROCESS_REQUESTED');
      fnd_message.set_token('PROCESS_CODE', l_process_code);
      fnd_msg_pub.add;
    EXCEPTION WHEN OTHERS THEN
    NULL;
 END;

 BEGIN
   SELECT   DISTINCT 'Y' INTO l_flag
     FROM dpp_customer_claims_all  dcca
    WHERE transaction_header_id = p_transaction_header_id
      AND supplier_claim_created IN ('Y','P')  ;
    SELECT meaning
      INTO l_process_code
      FROM fnd_lookups
     WHERE lookup_type LIKE 'DPP_EXECUTION_PROCESSES%'
    AND lookup_code ='CUSTINVCL';
      fnd_message.set_name('DPP', 'DPP_EXE_PROCESS_REQUESTED');
      fnd_message.set_token('PROCESS_CODE', l_process_code);
      fnd_msg_pub.add;
    EXCEPTION WHEN OTHERS THEN
    NULL;
 END;

  IF l_flag = 'Y' THEN
    fnd_message.set_name('DPP', 'DPP_TXN_NOT_CANCELLED');
    fnd_msg_pub.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

 ELSIF p_status_change = 'CLOSED' THEN

BEGIN
 SELECT   DISTINCT 'Y' INTO l_flag
 FROM dpp_execution_processes dep, dpp_transaction_lines_all  dtla
 WHERE dep.transaction_header_id = dtla.transaction_header_id
 AND dtla.transaction_header_id = p_transaction_header_id
 AND dep.process_code = 'UPDTPO'
 AND update_purchasing_docs IN ('N','P');
    SELECT meaning
      INTO l_process_code
      FROM fnd_lookups
     WHERE lookup_type LIKE 'DPP_EXECUTION_PROCESSES%'
    AND lookup_code ='UPDTPO';
      fnd_message.set_name('DPP', 'DPP_EXE_PROCESS_INCOMPLETE');
      fnd_message.set_token('PROCESS_CODE', l_process_code);
      fnd_msg_pub.add;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
  NULL;
  WHEN OTHERS THEN
    RAISE  FND_API.G_EXC_ERROR;
  END;


 BEGIN
   SELECT  DISTINCT 'Y' INTO l_flag
    FROM dpp_execution_processes dep, dpp_transaction_lines_all  dtla
    WHERE dep.transaction_header_id = dtla.transaction_header_id
    AND dtla.transaction_header_id = p_transaction_header_id
    AND dep.process_code = 'NTFYPO'
    AND notify_purchasing_docs IN ('N','P')  ;
    SELECT meaning
      INTO l_process_code
      FROM fnd_lookups
     WHERE lookup_type LIKE 'DPP_EXECUTION_PROCESSES%'
    AND lookup_code ='NTFYPO';
      fnd_message.set_name('DPP', 'DPP_EXE_PROCESS_INCOMPLETE');
      fnd_message.set_token('PROCESS_CODE', l_process_code);
      fnd_msg_pub.add;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
  NULL;
  WHEN OTHERS THEN
    RAISE  FND_API.G_EXC_ERROR;
  END;


 BEGIN
   SELECT  DISTINCT 'Y' INTO l_flag
    FROM dpp_execution_processes dep, dpp_transaction_lines_all  dtla
    WHERE dep.transaction_header_id = dtla.transaction_header_id
    AND dtla.transaction_header_id = p_transaction_header_id
    AND dep.process_code = 'INVC'
      AND update_inventory_costing IN ('N','P')  ;
    SELECT meaning
      INTO l_process_code
      FROM fnd_lookups
     WHERE lookup_type LIKE 'DPP_EXECUTION_PROCESSES%'
    AND lookup_code ='INVC';
      fnd_message.set_name('DPP', 'DPP_EXE_PROCESS_INCOMPLETE');
      fnd_message.set_token('PROCESS_CODE', l_process_code);
      fnd_msg_pub.add;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
  NULL;
  WHEN OTHERS THEN
    RAISE  FND_API.G_EXC_ERROR;
  END;

  BEGIN
   SELECT  DISTINCT 'Y' INTO l_flag
    FROM dpp_execution_processes dep, dpp_transaction_lines_all  dtla
    WHERE dep.transaction_header_id = dtla.transaction_header_id
    AND dtla.transaction_header_id = p_transaction_header_id
    AND dep.process_code = 'UPDTLP'
      AND update_item_list_price IN ('N','P')  ;
    SELECT meaning
      INTO l_process_code
      FROM fnd_lookups
     WHERE lookup_type LIKE 'DPP_EXECUTION_PROCESSES%'
    AND lookup_code ='UPDTLP';
      fnd_message.set_name('DPP', 'DPP_EXE_PROCESS_INCOMPLETE');
      fnd_message.set_token('PROCESS_CODE', l_process_code);
      fnd_msg_pub.add;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
  NULL;
  WHEN OTHERS THEN
    RAISE  FND_API.G_EXC_ERROR;
  END;

 BEGIN
   SELECT  DISTINCT 'Y' INTO l_flag
    FROM dpp_execution_processes dep, dpp_transaction_lines_all  dtla
    WHERE dep.transaction_header_id = dtla.transaction_header_id
    AND dtla.transaction_header_id = p_transaction_header_id
    AND dep.process_code = 'INPL'
      AND notify_inbound_pricelist IN ('N','P')  ;
    SELECT meaning
      INTO l_process_code
      FROM fnd_lookups
     WHERE lookup_type LIKE 'DPP_EXECUTION_PROCESSES%'
    AND lookup_code ='INPL';
      fnd_message.set_name('DPP', 'DPP_EXE_PROCESS_INCOMPLETE');
      fnd_message.set_token('PROCESS_CODE', l_process_code);
      fnd_msg_pub.add;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
  NULL;
  WHEN OTHERS THEN
    RAISE  FND_API.G_EXC_ERROR;
  END;

 BEGIN
   SELECT   DISTINCT 'Y' INTO l_flag
    FROM dpp_execution_processes dep, dpp_transaction_lines_all  dtla
    WHERE dep.transaction_header_id = dtla.transaction_header_id
    AND dtla.transaction_header_id = p_transaction_header_id
    AND dep.process_code = 'OUTPL'
      AND notify_outbound_pricelist IN ('N','P')  ;
    SELECT meaning
      INTO l_process_code
      FROM fnd_lookups
     WHERE lookup_type LIKE 'DPP_EXECUTION_PROCESSES%'
    AND lookup_code ='OUTPL';
      fnd_message.set_name('DPP', 'DPP_EXE_PROCESS_INCOMPLETE');
      fnd_message.set_token('PROCESS_CODE', l_process_code);
      fnd_msg_pub.add;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
  NULL;
  WHEN OTHERS THEN
    RAISE  FND_API.G_EXC_ERROR;
  END;

 BEGIN
   SELECT  DISTINCT 'Y' INTO l_flag
    FROM dpp_execution_processes dep, dpp_transaction_lines_all  dtla
    WHERE dep.transaction_header_id = dtla.transaction_header_id
    AND dtla.transaction_header_id = p_transaction_header_id
    AND dep.process_code = 'PROMO'
      AND notify_promotions_pricelist IN ('N','P')  ;
    SELECT meaning
      INTO l_process_code
      FROM fnd_lookups
     WHERE lookup_type LIKE 'DPP_EXECUTION_PROCESSES%'
    AND lookup_code ='PROMO';
      fnd_message.set_name('DPP', 'DPP_EXE_PROCESS_INCOMPLETE');
      fnd_message.set_token('PROCESS_CODE', l_process_code);
      fnd_msg_pub.add;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
  NULL;
  WHEN OTHERS THEN
    RAISE  FND_API.G_EXC_ERROR;
  END;

 BEGIN
   SELECT  DISTINCT 'Y' INTO l_flag
    FROM dpp_execution_processes dep, dpp_transaction_lines_all  dtla
    WHERE dep.transaction_header_id = dtla.transaction_header_id
    AND dtla.transaction_header_id = p_transaction_header_id
    AND dep.process_code = 'DSTRINVCL'
      AND supp_dist_claim_status IN  ('N','P','D')  ;
    SELECT meaning
      INTO l_process_code
      FROM fnd_lookups
     WHERE lookup_type LIKE 'DPP_EXECUTION_PROCESSES%'
    AND lookup_code ='DSTRINVCL';
      fnd_message.set_name('DPP', 'DPP_EXE_PROCESS_INCOMPLETE');
      fnd_message.set_token('PROCESS_CODE', l_process_code);
      fnd_msg_pub.add;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
  NULL;
  WHEN OTHERS THEN
    RAISE  FND_API.G_EXC_ERROR;
  END;

 BEGIN
   SELECT  DISTINCT 'Y' INTO l_flag
    FROM dpp_execution_processes dep, dpp_customer_claims_all  dcca
    WHERE dep.transaction_header_id = dcca.transaction_header_id
    AND dcca.transaction_header_id = p_transaction_header_id
    AND dep.process_code = 'CUSTINVCL'
      AND supplier_claim_created IN  ('N','P')  ;
    SELECT meaning
      INTO l_process_code
      FROM fnd_lookups
     WHERE lookup_type LIKE 'DPP_EXECUTION_PROCESSES%'
    AND lookup_code ='CUSTINVCL';
      fnd_message.set_name('DPP', 'DPP_EXE_PROCESS_INCOMPLETE');
      fnd_message.set_token('PROCESS_CODE', l_process_code);
      fnd_msg_pub.add;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
  NULL;
  WHEN OTHERS THEN
    RAISE  FND_API.G_EXC_ERROR;
  END;

  FOR select_claims_rec IN select_claims_csr(p_transaction_header_id)
  LOOP
      l_flag := 'Y';
      fnd_message.set_name('DPP', 'DPP_CLAIM_NOT_CLOSED');
      fnd_message.set_token('CLAIM_NUMBER',select_claims_rec.claim_number );
      fnd_msg_pub.add;
  END LOOP;
   END IF;
  IF l_flag = 'Y' THEN
    fnd_message.set_name('DPP', 'DPP_TXN_NOT_CLOSED');
    fnd_msg_pub.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_rec_count,
          p_data    => x_msg_data
      );
      IF x_rec_count > 1 THEN
          FOR I IN 1..x_rec_count LOOP
             x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
          END LOOP;
      END IF;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE', 'DPP_UTILITY_PVT.check_txnclose');
      fnd_message.set_token('ERRNO', sqlcode);
      fnd_message.set_token('REASON', sqlerrm);
      FND_MSG_PUB.add;

      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_rec_count,
          p_data  => x_msg_data
      );
      IF x_rec_count > 1 THEN
          FOR I IN 1..x_rec_count LOOP
             x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
          END LOOP;
      END IF;
END Check_Transaction;

PROCEDURE search_vendors(
    p_search_criteria IN  search_criteria_tbl_type
   ,x_vendor_tbl OUT NOCOPY vendor_tbl_type
   ,x_rec_count	OUT NOCOPY NUMBER
   ,x_return_status OUT NOCOPY VARCHAR2
   )
IS
    l_search_criteria_tbl	search_criteria_tbl_type := p_search_criteria;
    l_vendor_tbl   vendor_tbl_type;
    l_trunc_sysdate  DATE  := trunc(sysdate);
	 l_module CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_UTILITY_PVT.SEARCH_VENDORS';

    CURSOR get_vendor_csr (p_search_criteria IN VARCHAR2, p_search_text IN VARCHAR2) IS
				SELECT
					vendor_id,
					segment1 vendor_num,
					vendor_name
				FROM
					ap_suppliers pov
                                 WHERE enabled_flag = 'Y'
        AND hold_flag = 'N'
        --AND pov.party_id = hzp.party_id
        AND (l_trunc_sysdate >= NVL(TRUNC(start_date_active), l_trunc_sysdate) AND l_trunc_sysdate < NVL(TRUNC(end_date_active), l_trunc_sysdate + 1))
-- BETWEEN NVL(start_date_active, l_trunc_sysdate) AND NVL(end_date_active,l_trunc_sysdate)
        AND ((UPPER(vendor_name) like UPPER(p_search_text) || '%' AND p_search_criteria = 'VENDOR_NAME')
        OR (UPPER(segment1) like UPPER(p_search_text) || '%' AND p_search_criteria = 'VENDOR_NUMBER'))
        ORDER BY vendor_name,segment1;

BEGIN

  OPEN get_vendor_csr(NVL(l_search_criteria_tbl(1).search_criteria,'VENDOR_NAME'), NVL(l_search_criteria_tbl(1).search_text,'%'));
  LOOP

      FETCH get_vendor_csr BULK COLLECT INTO l_vendor_tbl;
      EXIT WHEN get_vendor_csr%NOTFOUND;
   END LOOP;

   CLOSE get_vendor_csr;
    x_rec_count  := l_vendor_tbl.COUNT;
    x_vendor_tbl := l_vendor_tbl;
    x_return_status := fnd_api.g_ret_sts_success;

    DPP_UTILITY_PVT.debug_message (FND_LOG.LEVEL_STATEMENT, l_module, 'search_vendors(): x_return_status: ' || x_return_status);

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UTILITY_PVT.search_vendors');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.ADD;

END search_vendors;

PROCEDURE search_vendor_sites(
    p_search_criteria IN  search_criteria_tbl_type
   ,x_vendor_site_tbl OUT NOCOPY vendor_site_tbl_type
   ,x_rec_count	OUT NOCOPY NUMBER
   ,x_return_status OUT NOCOPY VARCHAR2
   )
IS
l_search_criteria_tbl	 search_criteria_tbl_type := p_search_criteria;
l_vendor_site_tbl        vendor_site_tbl_type;
l_module                 CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_UTILITY_PVT.SEARCH_VENDOR_SITES';


    CURSOR get_vendor_sites_csr (p_search_criteria1 IN VARCHAR2,
                                 p_search_text1 IN VARCHAR2,
                                 p_search_criteria2 IN VARCHAR2,
                                 p_search_text2 IN VARCHAR2,
                                 p_search_criteria3 IN VARCHAR2,
                                 p_search_text3 IN VARCHAR2) IS
     SELECT apssa.vendor_id,
            apssa.vendor_site_id,
            apssa.vendor_site_code,
            apssa.address_line1,
            apssa.address_line2,
            apssa.address_line3,
            apssa.city,
            apssa.state,
            apssa.zip,
            apssa.country
       FROM ap_supplier_sites_all apssa,
            ozf_supp_trd_prfls_all ostp
      WHERE apssa.vendor_id = to_NUMBER(p_search_text1)
        AND ostp.supplier_id = apssa.vendor_id
        AND ostp.supplier_site_id = apssa.vendor_site_id
        AND ostp.org_id = apssa.org_id
        AND p_search_criteria1 = 'VENDOR_ID'
        AND nvl(apssa.rfq_only_site_flag, 'N')  ='N'
        AND NVL(apssa.inactive_date, TRUNC(SYSDATE +1)) > TRUNC(SYSDATE)
        AND UPPER(apssa.vendor_site_code) like UPPER(p_search_text2) || '%'
        AND p_search_criteria2 = 'VENDOR_SITE_CODE'
        AND apssa.org_id = to_NUMBER(p_search_text3)
        AND p_search_criteria3 = 'ORG_ID'
        ORDER BY apssa.vendor_site_code;
BEGIN

      x_rec_count := 0;

       IF l_search_criteria_tbl(1).search_text IS NULL THEN
             fnd_message.set_name('DPP', 'DPP_UI_LOV_NO_VENDORID');
             fnd_msg_pub.add;
          RAISE FND_API.G_EXC_ERROR;

       ELSIF l_search_criteria_tbl(3).search_text IS NULL THEN
             fnd_message.set_name('DPP', 'DPP_UI_LOV_NO_ORGID');
             fnd_msg_pub.add;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

  OPEN get_vendor_sites_csr(NVL(l_search_criteria_tbl(1).search_criteria,'VENDOR_ID'), l_search_criteria_tbl(1).search_text,
  													NVL(l_search_criteria_tbl(2).search_criteria,'VENDOR_SITE_CODE'), NVL(l_search_criteria_tbl(2).search_text,'%'),
  													NVL(l_search_criteria_tbl(3).search_criteria,'ORG_ID'), l_search_criteria_tbl(3).search_text);
  LOOP

   FETCH get_vendor_sites_csr BULK COLLECT INTO l_vendor_site_tbl;
   EXIT WHEN get_vendor_sites_csr%NOTFOUND;
   END LOOP;
   CLOSE get_vendor_sites_csr;

    x_rec_count := l_vendor_site_tbl.COUNT;
    x_vendor_site_tbl := l_vendor_site_tbl;
    x_return_status := fnd_api.g_ret_sts_success;

    DPP_UTILITY_PVT.debug_message (FND_LOG.LEVEL_STATEMENT, l_module, 'search_vendor_sites(): x_return_status: ' || x_return_status);

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UTILITY_PVT.search_vendor_sites');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.ADD;

END search_vendor_sites;

PROCEDURE search_vendor_contacts(
    p_search_criteria IN  search_criteria_tbl_type
   ,x_vendor_contact_tbl OUT NOCOPY vendor_contact_tbl_type
   ,x_rec_count	OUT NOCOPY NUMBER
   ,x_return_status OUT NOCOPY VARCHAR2
   )
IS
    l_search_criteria_tbl	search_criteria_tbl_type := p_search_criteria;
    l_vendor_contact_tbl   vendor_contact_tbl_type;
    l_module               CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_UTILITY_PVT.SEARCH_VENDOR_CONTACTS';

    CURSOR get_vendor_contacts_csr (p_search_criteria1 IN VARCHAR2, p_search_text1 IN VARCHAR2,
                                    p_search_criteria2 IN VARCHAR2, p_search_text2 IN VARCHAR2) IS
			SELECT assa.vendor_site_id,
                               poc.vendor_contact_id,
                               poc.first_name,
                               poc.middle_name,
                               poc.last_name,
                               poc.area_code
                               ||poc.phone phone,
                               poc.email_address,
                               poc.fax
                        FROM   po_vendor_contacts poc,
                               ap_supplier_sites_all assa
                        WHERE  assa.vendor_site_id = TO_NUMBER(p_search_text1)
                           AND assa.party_site_id = poc.org_party_site_id
                           AND assa.vendor_site_id = poc.vendor_site_id
                           AND p_search_criteria1 = 'VENDOR_SITE_ID'
                           AND NVL(poc.inactive_date,SYSDATE + 1) > SYSDATE
                           AND ((UPPER(first_name) LIKE UPPER(p_search_text2)
                           AND p_search_criteria2 = 'FIRST_NAME')
                           OR (UPPER(last_name) LIKE UPPER(p_search_text2)
                           AND p_search_criteria2 = 'LAST_NAME')
                           OR (UPPER(middle_name) LIKE UPPER(p_search_text2)
                           AND p_search_criteria2 = 'MIDDLE_NAME'))
                           ORDER BY poc.last_name,poc.first_name,poc.middle_name;

BEGIN

      x_rec_count := 0;

       IF l_search_criteria_tbl(1).search_text IS NULL THEN
             fnd_message.set_name('DPP', 'DPP_UI_LOV_NO_VENDORSITEID');
             fnd_msg_pub.add;

          RAISE fnd_api.g_exc_error;
       END IF;

  OPEN get_vendor_contacts_csr(NVL(l_search_criteria_tbl(1).search_criteria,'VENDOR_SITE_ID'), l_search_criteria_tbl(1).search_text,
  														 NVL(l_search_criteria_tbl(2).search_criteria,'FIRST_NAME'), NVL(l_search_criteria_tbl(2).search_text,'%'));
  LOOP
          FETCH get_vendor_contacts_csr BULK COLLECT INTO l_vendor_contact_tbl;
          EXIT WHEN get_vendor_contacts_csr%NOTFOUND;
   END LOOP;
   CLOSE get_vendor_contacts_csr;

    x_rec_count := l_vendor_contact_tbl.COUNT;
    x_vendor_contact_tbl := l_vendor_contact_tbl;
    x_return_status := fnd_api.g_ret_sts_success;

    DPP_UTILITY_PVT.debug_message (FND_LOG.LEVEL_STATEMENT, l_module, 'search_vendor_contacts(): x_return_status: ' || x_return_status);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UTILITY_PVT.search_vendor_contacts');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.ADD;

END search_vendor_contacts;

PROCEDURE search_items(
    p_search_criteria IN  search_criteria_tbl_type
   ,x_item_tbl OUT NOCOPY itemnum_tbl_type
   ,x_rec_count	OUT NOCOPY NUMBER
   ,x_return_status OUT NOCOPY VARCHAR2
   )
IS
    l_search_criteria_tbl		search_criteria_tbl_type := p_search_criteria;
    l_itemnum_tbl   				itemnum_tbl_type;
    l_supp_trade_profile_id	NUMBER;
    l_supp_item_count				NUMBER := 0;
    l_trunc_sysdate  DATE  := trunc(sysdate);
	 l_module               CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_UTILITY_PVT.SEARCH_ITEMS';

    CURSOR get_item_csr (p_search_criteria1 IN VARCHAR2,
                         p_search_text1 IN VARCHAR2,
                         p_search_criteria2 IN VARCHAR2,
                         p_search_text2 IN VARCHAR2,
                         p_supp_trade_profile_id IN NUMBER) IS
SELECT msi.inventory_item_id,
                msi.concatenated_segments,
                msi.description,
                occ.external_code
FROM   mtl_system_items_kfv msi,
       financials_system_params_all fspa,
       ozf_supp_code_conversions_all occ
WHERE  occ.internal_code = to_char(msi.inventory_item_id)
       AND occ.code_conversion_type = 'OZF_PRODUCT_CODES'
       AND occ.supp_trade_profile_id = p_supp_trade_profile_id
       AND occ.org_id = fspa.org_id
       AND TRUNC(SYSDATE) BETWEEN NVL(occ.start_date_active,TRUNC(SYSDATE)) AND
                                  NVL(occ.end_date_active,TRUNC(SYSDATE))
       AND msi.purchasing_item_flag = 'Y'
       AND msi.shippable_item_flag = 'Y'
       AND msi.enabled_flag = 'Y'
       AND nvl(msi.consigned_flag,2) = 2 -- 2=unconsigned
       AND msi.mtl_transactions_enabled_flag = 'Y'
       AND msi.organization_id = fspa.inventory_organization_id
       AND fspa.org_id = to_number(p_search_text1)
       AND p_search_criteria1 = 'ORG_ID'
       AND ((p_search_criteria2 = 'ITEM_NUMBER'
             AND UPPER(msi.concatenated_segments) LIKE UPPER(p_search_text2) || '%')
             OR (p_search_criteria2 = 'SUPPLIER_ITEM_NUMBER'
                 AND UPPER(occ.external_code) LIKE UPPER(p_search_text2) || '%'))
UNION
SELECT msi.inventory_item_id,
                msi.concatenated_segments,
                msi.description,
                null   external_code
FROM   mtl_system_items_kfv msi,
       financials_system_params_all fspa
WHERE  msi.purchasing_item_flag = 'Y'
       AND msi.shippable_item_flag = 'Y'
       AND msi.enabled_flag = 'Y'
       AND NVL(msi.consigned_flag,2) = 2 -- 2=unconsigned
       AND msi.mtl_transactions_enabled_flag = 'Y'
       AND msi.organization_id = fspa.inventory_organization_id
       AND fspa.org_id = to_number(p_search_text1)
       AND p_search_criteria1 = 'ORG_ID'
       AND p_search_criteria2 = 'ITEM_NUMBER'
       AND UPPER(msi.concatenated_segments) LIKE UPPER(p_search_text2) || '%'
       AND NOT EXISTS (SELECT 1
                       FROM   ozf_supp_code_conversions_all occ
                       WHERE  occ.internal_code = to_char(msi.inventory_item_id)
                              AND occ.code_conversion_type = 'OZF_PRODUCT_CODES'
                              AND occ.supp_trade_profile_id = p_supp_trade_profile_id
                              AND occ.org_id = to_number(p_search_text1)
                              AND TRUNC(SYSDATE) BETWEEN NVL(occ.start_date_active,TRUNC(SYSDATE)) AND
                                  NVL(occ.end_date_active,TRUNC(SYSDATE)))
      ORDER BY 2,4;

    CURSOR get_msi_item_csr (p_search_criteria1 IN VARCHAR2,
                         p_search_text1 IN VARCHAR2,
                         p_search_criteria2 IN VARCHAR2,
                         p_search_text2 IN VARCHAR2) IS
        SELECT DISTINCT msi.inventory_item_id,
				                msi.concatenated_segments,
				                msi.description,
		                    NULL external_code
		               FROM mtl_system_items_kfv msi,
		                   financials_system_params_all fspa
		                WHERE msi.organization_id = fspa.inventory_organization_id
		               AND msi.purchasing_item_flag = 'Y'
		               AND  msi.shippable_item_flag = 'Y'
		               AND msi.enabled_flag = 'Y'
		               AND NVL(msi.consigned_flag,2) = 2 -- 2=unconsigned
						       AND msi.mtl_transactions_enabled_flag = 'Y'
                   AND fspa.org_id = TO_NUMBER(p_search_text1)
		               AND p_search_criteria1 = 'ORG_ID'
                   AND p_search_criteria2 = 'ITEM_NUMBER'
                   AND UPPER(msi.concatenated_segments) like UPPER(p_search_text2) || '%'
                   ORDER BY msi.concatenated_segments;

 BEGIN

        x_rec_count := 0;

        IF l_search_criteria_tbl(1).search_text IS NULL THEN
              fnd_message.set_name('DPP', 'DPP_UI_LOV_NO_ORGID');
              fnd_msg_pub.add;

           RAISE fnd_api.g_exc_error;
       ELSIF l_search_criteria_tbl(3).search_text IS NULL THEN
              fnd_message.set_name('DPP', 'DPP_UI_LOV_NO_VENDORID');
              fnd_msg_pub.add;
           RAISE fnd_api.g_exc_error;
       ELSIF l_search_criteria_tbl(4).search_text IS NULL THEN
              fnd_message.set_name('DPP', 'DPP_UI_LOV_NO_VENDORSITEID');
              fnd_msg_pub.add;
           RAISE fnd_api.g_exc_error;
       END IF;

       BEGIN
         SELECT supp_trade_profile_id
           INTO l_supp_trade_profile_id
           FROM ozf_supp_trd_prfls_all
          WHERE supplier_id = to_number(l_search_criteria_tbl(3).search_text)
            AND supplier_site_id = to_number(l_search_criteria_tbl(4).search_text)
            AND org_id = l_search_criteria_tbl(1).search_text;
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
             l_supp_trade_profile_id := NULL;
       END;

       BEGIN
          SELECT count(*)
            INTO l_supp_item_count
            FROM ozf_supp_code_conversions_all
           WHERE supp_trade_profile_id = l_supp_trade_profile_id;

       END;

       IF l_supp_trade_profile_id IS NOT NULL THEN

           BEGIN
			         SELECT count(*)
			           INTO l_supp_item_count
			           FROM ozf_supp_code_conversions_all
			          WHERE supp_trade_profile_id = l_supp_trade_profile_id;

           END;

        IF l_supp_item_count > 0 THEN
						-- select from msi and occ (get_item_csr)
						OPEN get_item_csr(NVL(l_search_criteria_tbl(1).search_criteria,'ORG_ID'),
													l_search_criteria_tbl(1).search_text,
													NVL(l_search_criteria_tbl(2).search_criteria,'ITEM_NUMBER'),
													l_search_criteria_tbl(2).search_text,
													l_supp_trade_profile_id);
						LOOP

							FETCH get_item_csr BULK COLLECT INTO l_itemnum_tbl;
							EXIT WHEN get_item_csr%NOTFOUND;
						END LOOP;
						CLOSE get_item_csr;

				ELSE -- l_supp_item_count = 0
					 -- select only from msi (get_msi_item_csr)
					 OPEN get_msi_item_csr(NVL(l_search_criteria_tbl(1).search_criteria,'ORG_ID'),
															 l_search_criteria_tbl(1).search_text,
															 NVL(l_search_criteria_tbl(2).search_criteria,'ITEM_NUMBER'),
															 l_search_criteria_tbl(2).search_text);
					 LOOP

								FETCH get_msi_item_csr BULK COLLECT INTO l_itemnum_tbl;
								EXIT WHEN get_msi_item_csr%NOTFOUND;
					 END LOOP;
					 CLOSE get_msi_item_csr;

				END IF;

       ELSE

       -- select only from msi (get_msi_item_csr)
       OPEN get_msi_item_csr(NVL(l_search_criteria_tbl(1).search_criteria,'ORG_ID'),
			                     l_search_criteria_tbl(1).search_text,
			                     NVL(l_search_criteria_tbl(2).search_criteria,'ITEM_NUMBER'),
			                     l_search_criteria_tbl(2).search_text);
			 LOOP

			      FETCH get_msi_item_csr BULK COLLECT INTO l_itemnum_tbl;
			      EXIT WHEN get_msi_item_csr%NOTFOUND;
			 END LOOP;
       CLOSE get_msi_item_csr;

       END IF;

    x_rec_count := l_itemnum_tbl.COUNT;
    x_item_tbl := l_itemnum_tbl;
    x_return_status := fnd_api.g_ret_sts_success;

    DPP_UTILITY_PVT.debug_message (FND_LOG.LEVEL_STATEMENT, l_module, 'search_items(): x_return_status: ' || x_return_status);

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UTILITY_PVT.search_items');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.ADD;

END search_items;


-- API not used as of now. Bug#9375129
PROCEDURE search_customer_items(
    p_search_criteria IN  search_criteria_tbl_type
   ,x_customer_item_tbl OUT NOCOPY item_tbl_type
   ,x_rec_count	OUT NOCOPY NUMBER
   ,x_return_status OUT NOCOPY VARCHAR2
   )
IS
    l_search_criteria_tbl	search_criteria_tbl_type := p_search_criteria;
    l_customer_item_tbl   item_tbl_type;
	 l_module               CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_UTILITY_PVT.SEARCH_CUSTOMER_ITEMS';

    CURSOR get_customer_item_csr (p_search_criteria1 IN VARCHAR2, p_search_text1 IN VARCHAR2,
    									   p_search_criteria2 IN VARCHAR2, p_search_text2 IN VARCHAR2,
    									   p_search_criteria3 IN VARCHAR2, p_search_text3 IN VARCHAR2) IS
    SELECT DISTINCT
		  msi.inventory_item_id,
		  msi.concatenated_segments,
		  msi.description
		FROM
		  mtl_system_items_kfv msi,
		  mtl_parameters mp,
		  financials_system_params_all fspa,
  		oe_order_lines_all oola,
		  dpp_transaction_lines_all dtla
		WHERE
		dtla.transaction_header_id = TO_NUMBER(p_search_text1) and
		p_search_criteria1 = 'TRANSACTION_HEADER_ID' AND
					oola.inventory_item_id = dtla.inventory_item_id and
					(dtla.prior_price - NVL(dtla.supplier_new_price,0)) > 0 and
			dtla.org_id = oola.org_id and
		  purchasing_item_flag = 'Y'  AND
		  shippable_item_flag = 'Y' AND
                  msi.mtl_transactions_enabled_flag = 'Y' AND
		  msi.organization_id = mp.organization_id AND
		  mp.organization_id = fspa.inventory_organization_id AND
		  UPPER(segment1) like UPPER(p_search_text2) AND
      p_search_criteria2 = 'ITEM_NUMBER' AND
  		oola.org_id = fspa.org_id AND
  		oola.inventory_item_id = msi.inventory_item_id AND
  		oola.sold_to_org_id = to_number(p_search_text3) AND
  		p_search_criteria3 = 'CUST_ACCOUNT_ID'
  		ORDER BY msi.concatenated_segments;

BEGIN
      x_rec_count := 0;

        IF l_search_criteria_tbl(1).search_text IS NULL THEN
              fnd_message.set_name('DPP', 'DPP_UI_LOV_NO_TRANSACTIONID');
              fnd_msg_pub.add;

           RAISE fnd_api.g_exc_error;
       ELSIF l_search_criteria_tbl(3).search_text IS NULL THEN
              fnd_message.set_name('DPP', 'DPP_UI_LOV_NO_CUST_ACCT_ID');
              fnd_msg_pub.add;
           RAISE fnd_api.g_exc_error;
       END IF;

  OPEN get_customer_item_csr(NVL(l_search_criteria_tbl(1).search_criteria,'TRANSACTION_HEADER_ID'),
  													 l_search_criteria_tbl(1).search_text,
  							    				NVL(l_search_criteria_tbl(2).search_criteria,'ITEM_NUMBER'),
  							    				NVL(l_search_criteria_tbl(2).search_text,'%'),
  							    				l_search_criteria_tbl(3).search_criteria,
  							    				NVL(l_search_criteria_tbl(3).search_text,'CUST_ACCOUNT_ID'));
  LOOP

          FETCH get_customer_item_csr BULK COLLECT INTO l_customer_item_tbl;
          EXIT WHEN get_customer_item_csr%NOTFOUND;
   END LOOP;
   CLOSE get_customer_item_csr;

    x_rec_count := l_customer_item_tbl.COUNT;
    x_customer_item_tbl := l_customer_item_tbl;
    x_return_status := fnd_api.g_ret_sts_success;

    DPP_UTILITY_PVT.debug_message (FND_LOG.LEVEL_STATEMENT, l_module, 'search_customer_items(): x_return_status: ' || x_return_status);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UTILITY_PVT.search_customer_items');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.ADD;

END search_customer_items;


PROCEDURE search_customer_items_all(
    p_search_criteria IN  search_criteria_tbl_type
   ,x_customer_item_tbl OUT NOCOPY item_tbl_type
   ,x_rec_count	OUT NOCOPY NUMBER
   ,x_return_status OUT NOCOPY VARCHAR2
   )
IS
    l_search_criteria_tbl	search_criteria_tbl_type := p_search_criteria;
    l_customer_item_tbl   item_tbl_type;
	 l_module               CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_UTILITY_PVT.SEARCH_CUSTOMER_ITEMS_ALL';

    CURSOR get_customer_items_all_csr (p_search_criteria1 IN VARCHAR2, p_search_text1 IN VARCHAR2,
                                       p_search_criteria2 IN VARCHAR2, p_search_text2 IN VARCHAR2) IS

    SELECT
		  msi.inventory_item_id,
		  msi.concatenated_segments,
		  msi.description
		FROM
		  mtl_system_items_kfv msi,
		  dpp_transaction_lines_all dtla
		WHERE
		  dtla.transaction_header_id = TO_NUMBER(p_search_text1) AND
		  p_search_criteria1 = 'TRANSACTION_HEADER_ID' AND
                  (dtla.prior_price - NVL(dtla.supplier_new_price,0)) > 0 AND
		  purchasing_item_flag = 'Y'  AND
		  shippable_item_flag = 'Y' AND
                  msi.mtl_transactions_enabled_flag = 'Y' AND
                  dtla.inventory_item_id = msi.inventory_item_id AND
                  dtla.org_id = msi.organization_id AND
		  UPPER(segment1) like UPPER(p_search_text2) AND
                  p_search_criteria2 = 'ITEM_NUMBER'
  		ORDER BY msi.concatenated_segments;


BEGIN
      x_rec_count := 0;

        IF l_search_criteria_tbl(1).search_text IS NULL THEN
              fnd_message.set_name('DPP', 'DPP_UI_LOV_NO_TRANSACTIONID');
              fnd_msg_pub.add;

           RAISE fnd_api.g_exc_error;
       ELSIF l_search_criteria_tbl(3).search_text IS NULL THEN
              fnd_message.set_name('DPP', 'DPP_UI_LOV_NO_CUST_ACCT_ID');
              fnd_msg_pub.add;
           RAISE fnd_api.g_exc_error;
       END IF;

  OPEN get_customer_items_all_csr(NVL(l_search_criteria_tbl(1).search_criteria,'TRANSACTION_HEADER_ID'),
                                        l_search_criteria_tbl(1).search_text,
  				    	NVL(l_search_criteria_tbl(2).search_criteria,'ITEM_NUMBER'),
  					NVL(l_search_criteria_tbl(2).search_text,'%'));

  LOOP

          FETCH get_customer_items_all_csr BULK COLLECT INTO l_customer_item_tbl;
          EXIT WHEN get_customer_items_all_csr%NOTFOUND;
   END LOOP;
   CLOSE get_customer_items_all_csr;

    x_rec_count := l_customer_item_tbl.COUNT;
    x_customer_item_tbl := l_customer_item_tbl;
    x_return_status := fnd_api.g_ret_sts_success;

    DPP_UTILITY_PVT.debug_message (FND_LOG.LEVEL_STATEMENT, l_module, 'search_customer_items_all(): x_return_status: ' || x_return_status);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UTILITY_PVT.search_customer_items_all');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.ADD;

END search_customer_items_all;


PROCEDURE search_warehouses(
    p_search_criteria IN  search_criteria_tbl_type
   ,x_warehouse_tbl OUT NOCOPY warehouse_tbl_type
   ,x_rec_count	OUT NOCOPY NUMBER
   ,x_return_status OUT NOCOPY VARCHAR2
   )
IS
cursor get_warehouse_csr(p_search_criteria1 IN VARCHAR2, p_search_text1 IN VARCHAR2,
p_search_criteria2 IN VARCHAR2, p_search_text2 IN VARCHAR2) is
	SELECT
	  ood.organization_id warehouse_id,
	  ood.organization_code warehouse_code,
	  ood.organization_name warehouse_name
	FROM
	  org_organization_definitions ood
	WHERE
      operating_unit = to_number(p_search_text2)
      AND p_search_criteria2 = 'ORG_ID'
	  AND ((ood.organization_code  LIKE p_search_text1 || '%'
	  AND p_search_criteria1 = 'WAREHOUSE_CODE') OR
	  (ood.organization_name  LIKE p_search_text1 || '%'
	  AND p_search_criteria1 = 'WAREHOUSE_NAME'))
	  AND NVL(ood.disable_date,SYSDATE+1) > SYSDATE
	 ORDER BY ood.organization_name;

l_search_criteria_tbl	search_criteria_tbl_type := p_search_criteria;
l_warehouse_tbl warehouse_tbl_type;
l_module               CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_UTILITY_PVT.SEARCH_WAREHOUSES';

BEGIN
      x_rec_count := 0;
			x_return_status := fnd_api.g_ret_sts_success;
        IF l_search_criteria_tbl(2).search_text IS NULL THEN
              fnd_message.set_name('DPP', 'DPP_UI_LOV_NO_ORGID');
              fnd_msg_pub.add;

           RAISE FND_API.G_EXC_ERROR;
        END IF;
  OPEN get_warehouse_csr(NVL(l_search_criteria_tbl(1).search_criteria,'WAREHOUSE_CODE'),
  											NVL(l_search_criteria_tbl(1).search_text,'%'),
  											NVL(l_search_criteria_tbl(2).search_criteria,'ORG_ID'),
  											l_search_criteria_tbl(2).search_text);
  LOOP

          FETCH get_warehouse_csr BULK COLLECT INTO l_warehouse_tbl;
          EXIT WHEN get_warehouse_csr%NOTFOUND;
   END LOOP;
   CLOSE get_warehouse_csr;

   x_rec_count := l_warehouse_tbl.COUNT;
   x_warehouse_tbl := l_warehouse_tbl;

   DPP_UTILITY_PVT.debug_message (FND_LOG.LEVEL_STATEMENT, l_module, 'search_warehouses(): x_return_status: ' || x_return_status);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UTILITY_PVT.search_warehouses');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.ADD;
END search_warehouses;

PROCEDURE Get_CoveredInventory(
		p_hdr_rec		IN dpp_inv_hdr_rec_type
	 ,p_covered_inv_tbl	     IN OUT NOCOPY dpp_inv_cov_tbl_type
   ,x_return_status	     OUT 	  NOCOPY VARCHAR2
)
IS
    l_hdr_rec  dpp_inv_hdr_rec_type:= p_hdr_rec;
    l_covered_inv_tbl   dpp_inv_cov_tbl_type := p_covered_inv_tbl;
    l_covered_inv_wh_tbl    dpp_inv_cov_wh_tbl_type;
    l_covered_inv_rct_tbl    dpp_inv_cov_rct_tbl_type;
    l_num_count NUMBER;
    l_primary_uom_code				VARCHAR2(3);
	 l_module               CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_UTILITY_PVT.GET_COVEREDINVENTORY';

   CURSOR get_covered_inventory_csr (p_org_id IN NUMBER, p_effective_start_date DATE, p_effective_end_date DATE, p_inventory_item_id IN NUMBER) IS
		 SELECT
				 sum(case when ( (NVL(moqd.orig_date_received,moqd.date_received) >= p_effective_start_date)
                                             and  (NVL(moqd.orig_date_received,moqd.date_received) < p_effective_start_date))
                                 --BETWEEN p_effective_start_date and p_effective_end_date)
				  then moqd.transaction_quantity else 0 end) covered_qty,
				  sum(moqd.transaction_quantity) onhand_qty,
				  moqd.transaction_uom_code
		 FROM
					mtl_onhand_quantities_detail moqd,
					org_organization_definitions ood,
	  			mtl_parameters mp
		 WHERE
					moqd.organization_id = ood.organization_id  AND
				 moqd.inventory_item_id = p_inventory_item_id  AND
				 mp.organization_id = ood.organization_id  AND
	--      NVL(mp.consigned_flag,'N') = 'N' AND
	      NVL(ood.disable_date,SYSDATE + 1) > SYSDATE AND
				 ood.operating_unit = p_org_id AND
				 moqd.PLANNING_ORGANIZATION_ID = mp.organization_id
        AND moqd.OWNING_ORGANIZATION_ID = mp.organization_id
        AND moqd.PLANNING_TP_TYPE = 2
        AND moqd.OWNING_TP_TYPE = 2
        AND moqd.IS_CONSIGNED = 2
			GROUP BY moqd.transaction_uom_code;

	cursor get_covered_inv_wh_csr(p_org_id IN NUMBER, p_effective_start_date DATE, p_effective_end_date DATE, p_inventory_item_id IN NUMBER) is
	SELECT
	  SUM(moqd.transaction_quantity) sum,
	  ood.organization_name warehouse,
	  ood.organization_id warehouse_id
	FROM
	  mtl_onhand_quantities_detail moqd,
	  org_organization_definitions ood,
	  mtl_parameters mp
	WHERE
	  moqd.organization_id = ood.organization_id  AND
	  moqd.inventory_item_id = p_inventory_item_id AND
	  ood.operating_unit = p_org_id  AND
	  mp.organization_id = ood.organization_id  AND
	--  NVL(mp.consigned_flag,'N') = 'N' AND
	  NVL(ood.disable_date,SYSDATE + 1) > SYSDATE AND
	 ( (NVL(moqd.orig_date_received,moqd.date_received) >= p_effective_start_date)
            AND (NVL(moqd.orig_date_received,moqd.date_received) < p_effective_end_date ) )
          --BETWEEN p_effective_start_date and p_effective_end_date
	  AND moqd.PLANNING_ORGANIZATION_ID = mp.organization_id
		AND moqd.OWNING_ORGANIZATION_ID = mp.organization_id
		AND moqd.PLANNING_TP_TYPE = 2
		AND moqd.OWNING_TP_TYPE = 2
    AND moqd.IS_CONSIGNED = 2
	  GROUP BY ood.organization_name,
	  ood.organization_id;

	cursor get_covered_inv_rct_csr(p_org_id IN NUMBER, p_inventory_item_id IN NUMBER, p_warehouse_id IN NUMBER) is
	SELECT
	  TRUNC(NVL(moqd.orig_date_received,moqd.date_received)) date_received,
	  SUM(moqd.transaction_quantity) sum
	FROM
	  mtl_onhand_quantities_detail moqd,
	  org_organization_definitions ood,
	  mtl_parameters mp
	WHERE
	  moqd.organization_id = ood.organization_id  AND
	  moqd.inventory_item_id = p_inventory_item_id AND
	  ood.operating_unit = p_org_id AND
	  mp.organization_id = ood.organization_id  AND
	--  NVL(mp.consigned_flag,'N') = 'N' AND
	  NVL(ood.disable_date,SYSDATE + 1) > SYSDATE AND
    moqd.organization_id = p_warehouse_id AND
				 moqd.PLANNING_ORGANIZATION_ID = mp.organization_id
        AND moqd.OWNING_ORGANIZATION_ID = mp.organization_id
        AND moqd.PLANNING_TP_TYPE = 2
        AND moqd.OWNING_TP_TYPE = 2
        AND moqd.IS_CONSIGNED = 2
    GROUP BY TRUNC(NVL(moqd.orig_date_received,moqd.date_received));

BEGIN

    FOR i in l_covered_inv_tbl.FIRST..l_covered_inv_tbl.LAST
    LOOP

            FOR get_covered_inventory_rec IN get_covered_inventory_csr(l_hdr_rec.org_id, l_hdr_rec.effective_start_date, l_hdr_rec.effective_end_date, l_covered_inv_tbl(i).Inventory_ITem_ID)
            LOOP
            l_covered_inv_tbl(i).covered_quantity := NVL(get_covered_inventory_rec.covered_qty,0);
            l_covered_inv_tbl(i).onhand_quantity := NVL(get_covered_inventory_rec.onhand_qty,0);
            l_covered_inv_tbl(i).uom_code := get_covered_inventory_rec.transaction_uom_code;

            l_num_count := 0;

                FOR get_covered_inv_wh_rec IN get_covered_inv_wh_csr(l_hdr_rec.org_id, l_hdr_rec.effective_start_date, l_hdr_rec.effective_end_date, l_covered_inv_tbl(i).Inventory_ITem_ID)
                LOOP

                    l_num_count := l_num_count + 1;

                    l_covered_inv_wh_tbl(l_num_count).warehouse_name :=  get_covered_inv_wh_rec.warehouse;
                    l_covered_inv_wh_tbl(l_num_count).warehouse_id :=  get_covered_inv_wh_rec.warehouse_id;
                    l_covered_inv_wh_tbl(l_num_count).covered_quantity :=  NVL(get_covered_inv_wh_rec.sum,0);

                      OPEN get_covered_inv_rct_csr(l_hdr_rec.org_id, l_covered_inv_tbl(i).Inventory_ITem_ID, get_covered_inv_wh_rec.warehouse_id);
										  LOOP
										          FETCH get_covered_inv_rct_csr BULK COLLECT INTO l_covered_inv_rct_tbl;
										          EXIT WHEN get_covered_inv_rct_csr%NOTFOUND;
										   END LOOP;
   										CLOSE get_covered_inv_rct_csr;

   									l_covered_inv_wh_tbl(l_num_count).rct_line_tbl := l_covered_inv_rct_tbl;

                END LOOP;

              l_covered_inv_tbl(i).wh_line_tbl := l_covered_inv_wh_tbl;

            END LOOP;

						 IF l_covered_inv_tbl(i).onhand_quantity IS NULL THEN

								l_covered_inv_tbl(i).covered_quantity := 0;
								l_covered_inv_tbl(i).onhand_quantity  := 0;

								BEGIN
									SELECT primary_uom_code
										INTO l_primary_uom_code
										FROM mtl_system_items msi,
												 mtl_parameters mp
									 WHERE inventory_item_id = l_covered_inv_tbl(i).inventory_item_id
										 AND mp.organization_id = msi.organization_id
										 AND mp.organization_id = mp.master_organization_id
										 AND rownum = 1;
							 EXCEPTION
							    WHEN OTHERS THEN
											DPP_UTILITY_PVT.debug_message (FND_LOG.LEVEL_STATEMENT, l_module, 'Error in fetching primary UOM: ' || SQLERRM);
											x_return_status := FND_API.G_RET_STS_ERROR;
							 END;

								l_covered_inv_tbl(i).uom_code := l_primary_uom_code; -- Default to Primary UOM
           END IF;

        END LOOP;

    p_covered_inv_tbl := l_covered_inv_tbl;

    x_return_status := fnd_api.g_ret_sts_success;

    DPP_UTILITY_PVT.debug_message (FND_LOG.LEVEL_STATEMENT, l_module, 'get_coveredinventory(): x_return_status: ' || x_return_status);

EXCEPTION

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UTILITY_PVT.Get_CoveredInventory');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.ADD;

END Get_CoveredInventory;

PROCEDURE Get_InventoryDetails(
		p_hdr_rec							IN dpp_inv_hdr_rec_type
	 ,p_inventorydetails_tbl	     IN OUT NOCOPY inventorydetails_tbl_type
	 ,x_rec_count						OUT NOCOPY NUMBER
   ,x_return_status	     	OUT 	  NOCOPY VARCHAR2
)
IS
    l_hdr_rec  							 dpp_inv_hdr_rec_type:= p_hdr_rec;
    l_inventorydetails_tbl   inventorydetails_tbl_type := p_inventorydetails_tbl;

    l_inv_details_id 					NUMBER;
    l_user_id 								NUMBER := FND_GLOBAL.user_id;
    l_sysdate 								DATE := SYSDATE;
    l_include_flag  					VARCHAR2(1);
    l_flag  					VARCHAR2(1);
    l_days_out 								NUMBER;
    l_primary_uom_code				VARCHAR2(3);
	 l_module               CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_UTILITY_PVT.GET_INVENTORYDETAILS';

   CURSOR get_covered_inventory_csr (p_org_id IN NUMBER, p_effective_start_date DATE, p_effective_end_date DATE, p_inventory_item_id IN NUMBER) IS
		 SELECT
				 sum(case when ((NVL(moqd.orig_date_received,moqd.date_received) >= p_effective_start_date)
                                  AND (NVL(moqd.orig_date_received,moqd.date_received) < p_effective_end_date))
                                 --BETWEEN p_effective_start_date and p_effective_end_date)
				  then moqd.transaction_quantity else 0 end) covered_qty,
				  sum(moqd.transaction_quantity) onhand_qty,
				  moqd.transaction_uom_code
		 FROM
					mtl_onhand_quantities_detail moqd,
					org_organization_definitions ood,
	  			mtl_parameters mp
		 WHERE
					moqd.organization_id = ood.organization_id  AND
				 moqd.inventory_item_id = p_inventory_item_id  AND
				 mp.organization_id = ood.organization_id  AND
	 --     NVL(mp.consigned_flag,'N') = 'N' AND
	      NVL(ood.disable_date,SYSDATE + 1) > SYSDATE AND
				 ood.operating_unit = p_org_id AND
				 moqd.planning_organization_id = mp.organization_id
        AND moqd.owning_organization_id = mp.organization_id
        AND moqd.planning_tp_type = 2
        AND moqd.owning_tp_type = 2
        AND moqd.is_consigned = 2
			GROUP BY moqd.transaction_uom_code;

	cursor get_covered_inv_wh_csr(p_org_id IN NUMBER, p_effective_start_date DATE, p_effective_end_date DATE, p_inventory_item_id IN NUMBER) is
	SELECT
	  SUM(moqd.transaction_quantity) Covered_quantity,
	  ood.organization_name warehouse,
	  ood.organization_id warehouse_id
	FROM
	  mtl_onhand_quantities_detail moqd,
	  org_organization_definitions ood,
	  mtl_parameters mp
	WHERE
	  moqd.organization_id = ood.organization_id  AND
	  moqd.inventory_item_id = p_inventory_item_id AND
	  ood.operating_unit = p_org_id  AND
	  mp.organization_id = ood.organization_id  AND
	--  NVL(mp.consigned_flag,'N') = 'N' AND
	  NVL(ood.disable_date,SYSDATE + 1) > SYSDATE AND
	  ((NVL(moqd.orig_date_received, moqd.date_received) >= p_effective_start_date)
          AND (NVL(moqd.orig_date_received, moqd.date_received) < p_effective_end_date)) AND
          --BETWEEN p_effective_start_date and p_effective_end_date AND
				 moqd.PLANNING_ORGANIZATION_ID = mp.organization_id
        AND moqd.OWNING_ORGANIZATION_ID = mp.organization_id
        AND moqd.PLANNING_TP_TYPE = 2
        AND moqd.OWNING_TP_TYPE = 2
        AND moqd.IS_CONSIGNED = 2
	  GROUP BY ood.organization_name,
	  ood.organization_id;

	cursor get_covered_inv_rct_csr(p_org_id IN NUMBER, p_inventory_item_id IN NUMBER, p_warehouse_id IN NUMBER) is
	SELECT
	  (NVL(moqd.orig_date_received,moqd.date_received)) date_received,
	  SUM(moqd.transaction_quantity) Onhand_quantity
	FROM
	  mtl_onhand_quantities_detail moqd,
	  org_organization_definitions ood,
	  mtl_parameters mp
	WHERE
	  moqd.organization_id = ood.organization_id  AND
	  moqd.inventory_item_id = p_inventory_item_id AND
	  ood.operating_unit = p_org_id AND
	  mp.organization_id = ood.organization_id  AND
	--  NVL(mp.consigned_flag,'N') = 'N' AND
	  NVL(ood.disable_date,SYSDATE + 1) > SYSDATE AND
    moqd.organization_id = p_warehouse_id AND
				 moqd.planning_organization_id = mp.organization_id
        AND moqd.owning_organization_id = mp.organization_id
        AND moqd.planning_tp_type = 2
        AND moqd.owning_tp_type = 2
        AND moqd.is_consigned = 2
    GROUP BY (NVL(moqd.orig_date_received,moqd.date_received));

BEGIN

    x_rec_count := 0;
    x_return_status := fnd_api.g_ret_sts_success;
    IF l_hdr_rec.org_id IS NULL THEN
				FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
				FND_MESSAGE.set_token('ID', 'Org ID');
				FND_MSG_PUB.add;
				RAISE FND_API.G_EXC_ERROR;
    ELSIF l_hdr_rec.effective_start_date IS NULL THEN
				 FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
				 FND_MESSAGE.set_token('ID', 'Effective Start Date');
				 FND_MSG_PUB.add;
				 RAISE FND_API.G_EXC_ERROR;
		 ELSIF l_hdr_rec.effective_end_date IS NULL THEN
				 FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
				 FND_MESSAGE.set_token('ID', 'Effective End Date');
				 FND_MSG_PUB.add;
				 RAISE FND_API.G_EXC_ERROR;
     END IF;

    FOR i in l_inventorydetails_tbl.FIRST..l_inventorydetails_tbl.LAST
    LOOP

			 IF l_inventorydetails_tbl(i).Inventory_Item_ID IS NULL THEN
					 FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
					 FND_MESSAGE.set_token('ID', 'Inventory Item ID');
					 FND_MSG_PUB.add;
					 x_return_status := FND_API.G_RET_STS_ERROR;
				ELSE
            FOR get_covered_inventory_rec IN get_covered_inventory_csr(l_hdr_rec.org_id, l_hdr_rec.effective_start_date, l_hdr_rec.effective_end_date, l_inventorydetails_tbl(i).Inventory_Item_ID)
            LOOP
            l_inventorydetails_tbl(i).covered_quantity := NVL(get_covered_inventory_rec.covered_qty,0);
            l_inventorydetails_tbl(i).onhand_quantity := NVL(get_covered_inventory_rec.onhand_qty,0);
            l_inventorydetails_tbl(i).uom_code := get_covered_inventory_rec.transaction_uom_code;
            --IF covered inventory is negative then reassign it to 0
            IF l_inventorydetails_tbl(i).covered_quantity < 0 THEN
               l_inventorydetails_tbl(i).covered_quantity := 0;
            END IF;
            -- Delete existing rows in DPP_INVENTORY_DETAILS_ADJ_ALL (if any)
            DELETE
              FROM DPP_INVENTORY_DETAILS_ADJ_ALL
             WHERE INVENTORY_DETAILS_ID IN
             (SELECT INVENTORY_DETAILS_ID
                FROM DPP_INVENTORY_DETAILS_ALL
						 	 WHERE org_id = l_hdr_rec.org_id
							   AND transaction_line_id = l_inventorydetails_tbl(i).Transaction_Line_Id);

            -- Delete existing rows in DPP_INVENTORY_DETAILS_ALL (if any)
						DELETE
						  FROM DPP_INVENTORY_DETAILS_ALL
						 WHERE org_id = l_hdr_rec.org_id
							 AND transaction_line_id = l_inventorydetails_tbl(i).Transaction_Line_Id;
            --Get the ware house level details only if the covered inventory is > 0
            IF l_inventorydetails_tbl(i).covered_quantity > 0 THEN
             FOR get_covered_inv_wh_rec IN get_covered_inv_wh_csr(l_hdr_rec.org_id, l_hdr_rec.effective_start_date, l_hdr_rec.effective_end_date, l_inventorydetails_tbl(i).Inventory_ITem_ID)
             LOOP

						  BEGIN

							 SELECT DPP_INVENTORY_DETAILS_SEQ.nextval INTO l_inv_details_id FROM DUAL;
                                                         l_flag := 'N';
						   -- Insert new row
						   INSERT INTO DPP_INVENTORY_DETAILS_ALL(
												inventory_details_id,
												transaction_line_id,
												quantity,
												uom,
												include_flag,
												creation_date,
												created_by,
												last_update_date,
												last_updated_by,
												last_update_login,
												inventory_item_id,
												org_id,
												organization_id,
												object_version_number)
								 VALUES (	l_inv_details_id,
												l_inventorydetails_tbl(i).Transaction_Line_Id,
												get_covered_inv_wh_rec.Covered_quantity,
												l_inventorydetails_tbl(i).UOM_Code,
												'N',
												l_sysdate,
												l_user_id,
												l_sysdate,
												l_user_id,
												l_user_id,
												l_inventorydetails_tbl(i).inventory_item_id,
												l_hdr_rec.org_id,
												get_covered_inv_wh_rec.Warehouse_id,
												1
												);

 				     END;

					FOR get_covered_inv_rct_rec IN get_covered_inv_rct_csr(l_hdr_rec.org_id, l_inventorydetails_tbl(i).Inventory_ITem_ID, get_covered_inv_wh_rec.warehouse_id)
					LOOP

						 BEGIN
						 IF ((get_covered_inv_rct_rec.date_received >= l_hdr_rec.effective_start_date) AND (get_covered_inv_rct_rec.date_received < l_hdr_rec.effective_end_date)) THEN
								l_include_flag := 'Y';
                                                                l_flag := 'Y';
								l_days_out      := 0;
							ELSIF (get_covered_inv_rct_rec.date_received < l_hdr_rec.effective_start_date) THEN
								l_include_flag := 'N';
								l_days_out     := -(l_hdr_rec.effective_start_date - get_covered_inv_rct_rec.date_received);
                                                                l_days_out := floor(l_days_out);
							 ELSIF (get_covered_inv_rct_rec.date_received >= l_hdr_rec.effective_end_date) THEN
								l_include_flag := 'N';
								l_days_out     := (get_covered_inv_rct_rec.date_received - l_hdr_rec.effective_end_date);
                                                                l_days_out := ceil(l_days_out);
                                                                IF l_days_out = 0 THEN
                                                                   l_days_out := 1;
                                                                END IF;
							 END IF;
							END;

							INSERT
								INTO DPP_INVENTORY_DETAILS_ADJ_ALL(
								inv_details_adj_id,
								inventory_details_id,
								date_received,
								days_out,
								quantity,
								uom,
								comments,
								include_flag,
								creation_date,
								created_by,
								last_update_date,
								last_updated_by,
								last_update_login,
								org_id,
								object_version_number)
							VALUES(
								dpp_inv_details_adj_id_seq.nextval,
								l_inv_details_id,
								get_covered_inv_rct_rec.date_received,
								l_days_out,
								get_covered_inv_rct_rec.Onhand_quantity,
								l_inventorydetails_tbl(i).UOM_Code,
								null,
								l_include_flag,
								l_sysdate,
								l_user_id,
								l_sysdate,
								l_user_id,
								l_user_id,
								l_hdr_rec.org_id,
								1
							);

					 END LOOP; -- rct loop
                          IF l_flag = 'Y' THEN
                             UPDATE DPP_INVENTORY_DETAILS_ALL
                                SET include_flag = 'Y',
                                    object_version_number = object_version_number + 1,
                                    last_update_date = l_sysdate,
                                    last_updated_by = l_user_id,
                                    last_update_login = l_user_id
                              WHERE inventory_details_id = l_inv_details_id;
                          END IF;

		     END LOOP; -- w/h loop
                  END IF;--check if covered inventory  is > 0

       END LOOP; -- main loop

       IF l_inventorydetails_tbl(i).onhand_quantity IS NULL THEN

          l_inventorydetails_tbl(i).covered_quantity := 0;
			    l_inventorydetails_tbl(i).onhand_quantity  := 0;

			    BEGIN
			      SELECT primary_uom_code
			        INTO l_primary_uom_code
			        FROM mtl_system_items msi,
			             mtl_parameters mp
						 WHERE inventory_item_id = l_inventorydetails_tbl(i).inventory_item_id
						   AND mp.organization_id = msi.organization_id
						   AND mp.organization_id = mp.master_organization_id
						   AND rownum = 1;
				 EXCEPTION
				 		WHEN OTHERS THEN
								DPP_UTILITY_PVT.debug_message (FND_LOG.LEVEL_EXCEPTION, l_module, 'Error in fetching primary UOM: ' || SQLERRM);
								x_return_status := FND_API.G_RET_STS_ERROR;
				 END;

			    l_inventorydetails_tbl(i).uom_code := l_primary_uom_code; -- Default to Primary UOM
       END IF;

     END IF;

  END LOOP; -- tbl loop
	x_rec_count := l_inventorydetails_tbl.COUNT;
	p_inventorydetails_tbl := l_inventorydetails_tbl;

	DPP_UTILITY_PVT.debug_message (FND_LOG.LEVEL_STATEMENT, l_module, 'get_inventorydetails(): x_return_status: ' || x_return_status);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UTILITY_PVT.Get_InventoryDetails');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.ADD;

END Get_InventoryDetails;

PROCEDURE Get_CustomerInventory(
    p_hdr_rec	IN dpp_inv_hdr_rec_type
   ,p_cust_inv_tbl  IN OUT NOCOPY dpp_cust_inv_tbl_type
   ,x_rec_count	OUT NOCOPY NUMBER
   ,x_return_status  OUT  NOCOPY VARCHAR2
)
IS
l_hdr_rec      dpp_inv_hdr_rec_type  := p_hdr_rec;
l_cust_inv_tbl dpp_cust_inv_tbl_type := p_cust_inv_tbl;
l_module       CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_UTILITY_PVT.GET_CUSTOMERINVENTORY';

CURSOR get_customer_inventory_csr (p_effective_start_date  IN DATE,
				  p_effective_end_date  IN DATE ,
				  p_customer_id  IN NUMBER,
				  p_inventory_item_id IN NUMBER) IS
			    SELECT osta.primary_uom_code uom,
                                     sum(decode(osta.transfer_type, 'IN', nvl(osta.common_quantity,0), 0)) -  sum(decode(osta.transfer_type, 'OUT', nvl(osta.common_quantity,0), 0)) as end_inventory
                                FROM
                                      ozf_sales_transactions_all osta
                                      ,hz_parties hp
                                      ,hz_cust_accounts hca
                                WHERE osta.sold_to_party_id = hp.party_id
                                AND   osta.error_flag='N'
                                AND   osta.sold_to_party_id =hp.party_id
                                AND   hca.cust_account_id = p_customer_id
                                AND   hca.party_id = hp.party_id
                                AND   osta.inventory_item_id =p_inventory_item_id--<<Inventory Item ID>>
                                AND   ((osta.transaction_date >= p_effective_start_date) AND (osta.transaction_date < p_effective_end_date))
                                --between p_effective_start_date AND p_effective_end_date  --<<effective_start_date>> and <<effective_end_date>> --//'DD-Mon-YYYY' fromat
                                GROUP BY
                                osta.primary_uom_code;
BEGIN

  x_rec_count := 0;
  x_return_status := fnd_api.g_ret_sts_success;
    IF l_hdr_rec.effective_start_date IS NULL THEN
				 FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
				 FND_MESSAGE.set_token('ID', 'Effective Start Date');
				 FND_MSG_PUB.add;
				 RAISE FND_API.G_EXC_ERROR;
		 ELSIF l_hdr_rec.effective_end_date IS NULL THEN
				 FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
				 FND_MESSAGE.set_token('ID', 'Effective End Date');
				 FND_MSG_PUB.add;
				 RAISE FND_API.G_EXC_ERROR;
     END IF;

	    FOR i in l_cust_inv_tbl.FIRST..l_cust_inv_tbl.LAST
      LOOP

         IF l_cust_inv_tbl(i).Inventory_Item_ID IS NULL THEN
						 FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
						 FND_MESSAGE.set_token('ID', 'Inventory Item ID');
						 FND_MSG_PUB.add;
						 x_return_status := FND_API.G_RET_STS_ERROR;
         ELSIF l_cust_inv_tbl(i).Customer_ID IS NULL THEN
						 FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
						 FND_MESSAGE.set_token('ID', 'Customer ID');
						 FND_MSG_PUB.add;
						 x_return_status := FND_API.G_RET_STS_ERROR;
				 ELSE
            FOR get_customer_inventory_rec IN get_customer_inventory_csr(l_hdr_rec.effective_start_date,
                                                                         l_hdr_rec.effective_end_date,
                                                                         l_cust_inv_tbl(i).customer_ID,
                                                                         l_cust_inv_tbl(i).Inventory_ITem_ID)
            LOOP
							l_cust_inv_tbl(i).onhand_quantity := get_customer_inventory_rec.end_inventory;
							l_cust_inv_tbl(i).uom_code := get_customer_inventory_rec.uom;
            END LOOP;
          END IF;

        END LOOP;
	x_rec_count := l_cust_inv_tbl.COUNT;
	p_cust_inv_tbl := l_cust_inv_tbl;

   DPP_UTILITY_PVT.debug_message (FND_LOG.LEVEL_STATEMENT, l_module, 'get_customerInventory(): x_return_status: ' || x_return_status);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UTILITY_PVT.Get_CustomerInventory');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.ADD;
END Get_CustomerInventory;


PROCEDURE search_customers(
    p_search_criteria IN  search_criteria_tbl_type
   ,x_customer_tbl OUT NOCOPY customer_tbl_type
   ,x_rec_count	OUT NOCOPY NUMBER
   ,x_return_status OUT NOCOPY VARCHAR2
   )
IS
    l_search_criteria_tbl	search_criteria_tbl_type := p_search_criteria;
    l_customer_tbl   customer_tbl_type;
	 l_module               CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_UTILITY_PVT.SEARCH_CUSTOMERS';

    CURSOR get_customer_csr (
			p_search_criteria1 IN VARCHAR2, p_search_text1 IN VARCHAR2,
			p_search_criteria2 IN VARCHAR2, p_search_text2 IN VARCHAR2) IS
  SELECT
		  oola.sold_to_org_id,
		  hz.account_number,
		  hz.account_name
		FROM
		  oe_order_lines_all oola,
		  hz_cust_accounts hz,
		  dpp_transaction_headers_all dtha,
		  dpp_transaction_lines_all dtla
		WHERE
			oola.org_id = dtla.org_id and
			dtla.transaction_header_id = TO_NUMBER(p_search_text2) and
                        dtla.transaction_header_id = dtha.transaction_header_id and
			p_search_criteria2 = 'TRANSACTION_HEADER_ID'  	and
			oola.inventory_item_id = dtla.inventory_item_id and
			(dtla.prior_price - NVL(dtla.supplier_new_price,0)) > 0 and
			hz.cust_account_id = oola.sold_to_org_id and
			hz.status = 'A' and
                        (((actual_shipment_date >= (dtha.effective_start_date - dtha.days_covered))
                        AND (actual_shipment_date < dtha.effective_start_date))
                        OR (dtha.days_covered IS NULL AND actual_shipment_date < dtha.effective_start_date)) and
      ((UPPER(hz.account_name) like UPPER(p_search_text1) AND p_search_criteria1 = 'CUSTOMER_NAME')
        OR (UPPER(hz.account_number) like UPPER(p_search_text1) AND p_search_criteria1 = 'CUSTOMER_NUMBER'))
    GROUP BY oola.sold_to_org_id,
      		   hz.account_number,
		         hz.account_name
		ORDER BY hz.account_name,hz.account_number;

BEGIN
       x_rec_count := 0;
       x_return_status := fnd_api.g_ret_sts_success;
       IF l_search_criteria_tbl(2).search_text IS NULL THEN
             fnd_message.set_name('DPP', 'DPP_UI_LOV_NO_TRANSACTIONID');
             fnd_msg_pub.add;
           RAISE FND_API.G_EXC_ERROR;
       END IF;

  OPEN get_customer_csr(l_search_criteria_tbl(1).search_criteria,
  											NVL(l_search_criteria_tbl(1).search_text,'%'),
  									    NVL(l_search_criteria_tbl(2).search_criteria,'TRANSACTION_HEADER_ID'),
  									    l_search_criteria_tbl(2).search_text);
  LOOP
      FETCH get_customer_csr BULK COLLECT INTO l_customer_tbl;
      EXIT WHEN get_customer_csr%NOTFOUND;
   END LOOP;
   CLOSE get_customer_csr;

    x_rec_count := l_customer_tbl.COUNT;
    x_customer_tbl := l_customer_tbl;

    DPP_UTILITY_PVT.debug_message (FND_LOG.LEVEL_STATEMENT, l_module, 'search_customers(): x_return_status: ' || x_return_status);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UTILITY_PVT.search_customers');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.ADD;

END search_customers;


PROCEDURE search_customers_all(
    p_search_criteria IN  search_criteria_tbl_type
   ,x_customer_tbl OUT NOCOPY customer_tbl_type
   ,x_rec_count	OUT NOCOPY NUMBER
   ,x_return_status OUT NOCOPY VARCHAR2
   )
IS
    l_search_criteria_tbl	search_criteria_tbl_type := p_search_criteria;
    l_customer_tbl   customer_tbl_type;
	 l_module               CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_UTILITY_PVT.SEARCH_CUSTOMERS_ALL';

    CURSOR get_customers_all_csr (
			p_search_criteria1 IN VARCHAR2,
                        p_search_text1 IN VARCHAR2 --,
			--p_search_criteria2 IN VARCHAR2,
                        --p_search_text2 IN VARCHAR2
                        ) IS

  SELECT
                  hz.cust_account_id,
		  hz.account_number,
		  hz.account_name
		FROM
		  hz_cust_accounts hz
		WHERE
			--p_search_criteria2 = 'TRANSACTION_HEADER_ID'  	and
			hz.status = 'A' and
      ((UPPER(hz.account_name) like UPPER(p_search_text1) AND p_search_criteria1 = 'CUSTOMER_NAME')
        OR (UPPER(hz.account_number) like UPPER(p_search_text1) AND p_search_criteria1 = 'CUSTOMER_NUMBER'))
    ORDER BY hz.account_name,hz.account_number;

BEGIN
       x_rec_count := 0;
       x_return_status := fnd_api.g_ret_sts_success;
       IF l_search_criteria_tbl(2).search_text IS NULL THEN
             fnd_message.set_name('DPP', 'DPP_UI_LOV_NO_TRANSACTIONID');
             fnd_msg_pub.add;
           RAISE FND_API.G_EXC_ERROR;
       END IF;

  OPEN get_customers_all_csr(l_search_criteria_tbl(1).search_criteria,
			     NVL(l_search_criteria_tbl(1).search_text,'%') --,
                             --NVL(l_search_criteria_tbl(2).search_criteria,'TRANSACTION_HEADER_ID'),
                    	     --l_search_criteria_tbl(2).search_text
                             );
  LOOP
      FETCH get_customers_all_csr BULK COLLECT INTO l_customer_tbl;
      EXIT WHEN get_customers_all_csr%NOTFOUND;
   END LOOP;
   CLOSE get_customers_all_csr;

    x_rec_count := l_customer_tbl.COUNT;
    x_customer_tbl := l_customer_tbl;

    DPP_UTILITY_PVT.debug_message (FND_LOG.LEVEL_STATEMENT, l_module, 'search_customers_all(): x_return_status: ' || x_return_status);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UTILITY_PVT.search_customers_all');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.ADD;

END search_customers_all;


PROCEDURE Get_LastPrice(p_hdr_rec	  IN dpp_inv_hdr_rec_type
                       ,p_cust_price_tbl  IN OUT NOCOPY dpp_cust_price_tbl_type
                       ,x_rec_count	  OUT NOCOPY NUMBER
                       ,x_return_status	  OUT NOCOPY VARCHAR2
                       )
IS
l_hdr_rec  		dpp_inv_hdr_rec_type:= p_hdr_rec;
l_cust_price_tbl   	dpp_cust_price_tbl_type := p_cust_price_tbl;
l_functional_currency	VARCHAR2(15);
l_exchange_rate        	NUMBER;
l_to_amount		NUMBER;
l_return_status		VARCHAR2(1);
l_trunc_sysdate  DATE  := trunc(sysdate);
l_module               CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_UTILITY_PVT.GET_LASTPRICE';

CURSOR get_last_price_csr (p_org_id IN NUMBER,
                           p_inventory_item_id 	IN NUMBER,
                           p_customer_id  IN NUMBER,
                           p_uom_code 	IN VARCHAR2)
IS
 SELECT
   rctl.unit_selling_price last_price,
   rct.invoice_currency_code
 FROM
   ra_customer_trx_lines_all rctl,
   ra_customer_trx_all rct,
   ra_cust_trx_types_all rctt
 WHERE
   line_type 						= 'LINE'  AND
   inventory_item_id 		= p_inventory_item_id  AND
   uom_code 						= p_uom_code AND
   rct.customer_trx_id 	= rctl.customer_trx_id AND
   rct.org_id 					= p_org_id AND
   rctt.cust_trx_type_id = rct.cust_trx_type_id     AND
   rct.org_id 					= rctt.org_id     AND
   rctt.name 						= 'Invoice' AND
   rct.org_id 					= rctl.org_id AND
   rct.sold_to_customer_id = p_customer_id AND
   rct.complete_flag 		= 'Y' AND
   rctl.customer_trx_line_id = (
 SELECT
   MAX(rctl1.customer_trx_line_id)
 FROM
   ra_customer_trx_lines_all rctl1,
   ra_customer_trx_all rct1,
   ra_cust_trx_types_all rctt1
 WHERE
   line_type 					= 'LINE'  AND
   inventory_item_id 	= p_inventory_item_id  AND
   uom_code 					= p_uom_code AND
   rct1.customer_trx_id = rctl1.customer_trx_id AND
   rct1.org_id 				= p_org_id AND
   rctt1.cust_trx_type_id = rct1.cust_trx_type_id     AND
   rct1.org_id 				= rctt1.org_id     AND
   rctt1.name 				= 'Invoice' AND
   rct1.org_id 				= rctl1.org_id AND
   rct1.sold_to_customer_id = p_customer_id AND
   rct1.complete_flag = 'Y');

BEGIN

    x_rec_count := 0;
    x_return_status := fnd_api.g_ret_sts_success;
    IF l_hdr_rec.org_id IS NULL THEN
				 FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
				 FND_MESSAGE.set_token('ID', 'Org ID');
				 FND_MSG_PUB.add;
				 RAISE FND_API.G_EXC_ERROR;
     END IF;

    FOR i in l_cust_price_tbl.FIRST..l_cust_price_tbl.LAST
    LOOP

         IF l_cust_price_tbl(i).Inventory_Item_ID IS NULL THEN
						 FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
						 FND_MESSAGE.set_token('ID', 'Inventory Item ID');
						 FND_MSG_PUB.add;
						 x_return_status := FND_API.G_RET_STS_ERROR;
         ELSIF l_cust_price_tbl(i).Customer_ID IS NULL THEN
						 FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
						 FND_MESSAGE.set_token('ID', 'Customer ID');
						 FND_MSG_PUB.add;
						 x_return_status := FND_API.G_RET_STS_ERROR;
         ELSIF l_cust_price_tbl(i).UOM_Code IS NULL THEN
						 FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
						 FND_MESSAGE.set_token('ID', 'UOM Code');
						 FND_MSG_PUB.add;
						 x_return_status := FND_API.G_RET_STS_ERROR;
         ELSIF l_cust_price_tbl(i).price_change IS NULL THEN
						 FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
						 FND_MESSAGE.set_token('ID', 'Price Change');
						 FND_MSG_PUB.add;
						 x_return_status := FND_API.G_RET_STS_ERROR;
        ELSE
            FOR get_last_price_rec IN get_last_price_csr(l_hdr_rec.org_id,
                                                         l_cust_price_tbl(i).Inventory_Item_ID,
                                                         l_cust_price_tbl(i).Customer_ID,
                                                         l_cust_price_tbl(i).UOM_Code) LOOP
                l_cust_price_tbl(i).last_price := NVL(get_last_price_rec.last_price,0);
                l_cust_price_tbl(i).invoice_currency_code := nvl(get_last_price_rec.invoice_currency_code,l_hdr_rec.currency_code);
            END LOOP;
            IF l_cust_price_tbl(i).last_price IS NULL THEN
               l_cust_price_tbl(i).last_price := 0 ;
                l_cust_price_tbl(i).invoice_currency_code := l_hdr_rec.currency_code;
            END IF;
            --Get the converted Price change if the currency is different
            IF l_hdr_rec.currency_code <> l_cust_price_tbl(i).invoice_currency_code THEN
               --Call the convert currency API to get the converted value of Price change
               l_to_amount := 0;
               DPP_UTILITY_PVT.convert_currency( p_from_currency   => l_hdr_rec.currency_code
                                                ,p_to_currency     => l_cust_price_tbl(i).invoice_currency_code
                                                ,p_conv_type       => FND_API.G_MISS_CHAR
                                                ,p_conv_rate       => FND_API.G_MISS_NUM
                                                ,p_conv_date       => l_trunc_sysdate
                                                ,p_from_amount     => l_cust_price_tbl(i).price_change
                                                ,x_return_status   => l_return_status
                                                ,x_to_amount       => l_to_amount
                                                ,x_rate            => l_exchange_rate);

               DPP_UTILITY_PVT.debug_message (FND_LOG.LEVEL_STATEMENT, l_module, 'convert_currency(): x_return_status: ' || l_return_status);

               IF l_return_status = 'S' THEN
                  DPP_UTILITY_PVT.debug_message (FND_LOG.LEVEL_STATEMENT, l_module, 'convert_currency(): Exchange Rate : ' || l_exchange_rate);

                  l_cust_price_tbl(i).converted_price_change :=   l_to_amount;
               END IF;
            ELSE
               DPP_UTILITY_PVT.debug_message (FND_LOG.LEVEL_STATEMENT, l_module, 'No conversion of currency code required');

               l_cust_price_tbl(i).converted_price_change := l_cust_price_tbl(i).price_change;
            END IF;
	END IF;
    END LOOP;

  	x_rec_count 			:= l_cust_price_tbl.COUNT;
    p_cust_price_tbl 	:= l_cust_price_tbl;

    DPP_UTILITY_PVT.debug_message (FND_LOG.LEVEL_STATEMENT, l_module, 'get_lastprice(): x_return_status: ' || x_return_status);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UTILITY_PVT.Get_LastPrice');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.ADD;

END Get_LastPrice;

PROCEDURE Get_ListPrice(
		p_hdr_rec			IN dpp_inv_hdr_rec_type
	 ,p_listprice_tbl	     IN OUT NOCOPY dpp_list_price_tbl_type
	 ,x_rec_count	OUT NOCOPY NUMBER
   ,x_return_status	     OUT NOCOPY	  VARCHAR2
)
IS

l_header_rec  dpp_inv_hdr_rec_type:= p_hdr_rec;
l_listprice_tbl dpp_list_price_tbl_type := p_listprice_tbl;
l_inventory_organization_id NUMBER;
l_functional_currency	VARCHAR2(15);
l_exchange_rate        NUMBER;
l_to_amount			NUMBER;
l_return_status	VARCHAR2(1);
l_trunc_sysdate  DATE  := trunc(sysdate);
l_module         CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_UTILITY_PVT.GET_LISTPRICE';

CURSOR get_list_price_csr (p_organization_id IN NUMBER, p_inventory_item_id IN NUMBER) IS
SELECT
  msi.LIST_PRICE_PER_UNIT list_price
    FROM
  mtl_system_items msi,
  financials_system_params_all fspa
   WHERE
    msi.organization_id = fspa.inventory_organization_id and
    fspa.org_id = p_organization_id and
  msi.inventory_item_id = p_inventory_item_id;


BEGIN

     x_rec_count := 0;
     x_return_status := fnd_api.g_ret_sts_success;

     IF l_header_rec.org_id IS NULL THEN
				 FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
				 FND_MESSAGE.set_token('ID', 'Org ID');
				 FND_MSG_PUB.add;
				 RAISE FND_API.G_EXC_ERROR;
		 ELSIF l_header_rec.currency_code IS NULL THEN
				 FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
				 FND_MESSAGE.set_token('ID', 'Currency Code');
				 FND_MSG_PUB.add;
				 RAISE FND_API.G_EXC_ERROR;
     END IF;
     po_moac_utils_pvt.set_org_context(l_header_rec.org_id);

		SELECT inventory_organization_id
			INTO l_inventory_organization_id
			FROM financials_system_parameters;

              -- Call Currency Conversion API to convert to Txn Currency
               --Changed from ozf_sys_parameters_all to hr_operating_units
              SELECT  gs.currency_code
                INTO   l_functional_currency
                FROM   gl_sets_of_books gs
                ,      hr_operating_units hr
                WHERE  hr.set_of_books_id = gs.set_of_books_id
                AND    hr.organization_id = l_header_rec.org_id;

		FOR i in l_listprice_tbl.FIRST..l_listprice_tbl.LAST
		LOOP

				 IF l_listprice_tbl(i).Inventory_Item_ID IS NULL THEN
						 FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
						 FND_MESSAGE.set_token('ID', 'Inventory Item ID');
						 FND_MSG_PUB.add;
						 x_return_status := FND_API.G_RET_STS_ERROR;
				 ELSE
					 FOR get_list_price_rec IN get_list_price_csr(l_header_rec.org_id, l_listprice_tbl(i).Inventory_Item_ID)
					 LOOP
                                          IF l_functional_currency = l_header_rec.currency_code THEN
                                             l_to_amount := get_list_price_rec.list_price;
                                          ELSE
                                             l_to_amount := 0;
                                             DPP_UTILITY_PVT.convert_currency(
									 p_from_currency   => l_functional_currency
									,p_to_currency     => l_header_rec.currency_code
									,p_conv_type       => FND_API.G_MISS_CHAR
									,p_conv_rate       => FND_API.G_MISS_NUM
									,p_conv_date       => l_trunc_sysdate
									,p_from_amount     => get_list_price_rec.list_price
									,x_return_status   => l_return_status
									,x_to_amount       => l_to_amount
									,x_rate            => l_exchange_rate);
                                          END IF; --checking for same currency
                                          l_listprice_tbl(i).list_price := l_to_amount;
					 END LOOP;
				 END IF;
		END LOOP;

		x_rec_count := l_listprice_tbl.COUNT;
		p_listprice_tbl := l_listprice_tbl;

      DPP_UTILITY_PVT.debug_message (FND_LOG.LEVEL_STATEMENT, l_module, 'get_listprice(): x_return_status: ' || x_return_status);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UTILITY_PVT.Get_ListPrice');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.ADD;


END Get_ListPrice;

PROCEDURE Get_Vendor(
	p_vendor_rec IN OUT NOCOPY vendor_rec_type
	 ,x_rec_count		OUT NOCOPY NUMBER
   	,x_return_status	OUT NOCOPY	  VARCHAR2
)
IS

CURSOR get_vendor_csr(p_vendor_id IN NUMBER)
IS
	SELECT  segment1 vendor_num,
		 vendor_name
	FROM  ap_suppliers pov
			WHERE enabled_flag = 'Y'
			AND hold_flag = 'N'
			AND vendor_id = p_vendor_id;

l_vendor_rec vendor_rec_type := p_vendor_rec;
BEGIN
   x_rec_count := 0;
   x_return_status := fnd_api.g_ret_sts_success;

   IF l_vendor_rec.vendor_ID IS NULL THEN
	 		       FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
	 					 FND_MESSAGE.set_token('ID', 'Vendor ID');
	 		       FND_MSG_PUB.add;
	           RAISE FND_API.G_EXC_ERROR;
   END IF;
   FOR get_vendor_rec IN get_vendor_csr(l_vendor_rec.vendor_ID)
   LOOP
      l_vendor_rec.vendor_number := get_vendor_rec.vendor_num;
      l_vendor_rec.vendor_name := get_vendor_rec.vendor_name;
   		x_rec_count := 1;
   END LOOP;

   p_vendor_rec := l_vendor_rec;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UTILITY_PVT.Get_Vendor');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.ADD;
END Get_Vendor;

PROCEDURE Get_Vendor_Site(
	  p_vendor_site_rec IN OUT NOCOPY vendor_site_rec_type
	 ,x_rec_count		OUT NOCOPY NUMBER
   ,x_return_status	OUT NOCOPY	  VARCHAR2
)
IS
CURSOR get_vendor_site_csr (p_vendor_id IN NUMBER, p_vendor_site_id IN NUMBER)
IS
    SELECT
		  vendor_site_code,
		  address_line1,
		  address_line2,
		  address_line3,
		  city,
		  state,
		  zip,
		  country
		FROM
		  ap_supplier_sites_all
		WHERE
		  vendor_id = p_vendor_id AND
		  nvl(rfq_only_site_flag, 'N')  ='N'  AND
		   vendor_site_id = p_vendor_site_id;

l_vendor_site_rec vendor_site_rec_type := p_vendor_site_rec;
BEGIN
   x_rec_count := 0;
   x_return_status := fnd_api.g_ret_sts_success;

   IF l_vendor_site_rec.vendor_ID IS NULL THEN
				 FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
				 FND_MESSAGE.set_token('ID', 'Vendor ID');
				 FND_MSG_PUB.add;
				 RAISE FND_API.G_EXC_ERROR;
   ELSIF l_vendor_site_rec.vendor_site_ID IS NULL THEN
				 FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
				 FND_MESSAGE.set_token('ID', 'Vendor Site ID');
				 FND_MSG_PUB.add;
				 RAISE FND_API.G_EXC_ERROR;
   END IF;

   FOR get_vendor_site_rec IN get_vendor_site_csr(l_vendor_site_rec.vendor_ID,l_vendor_site_rec.vendor_site_ID)
   LOOP
      l_vendor_site_rec.vendor_site_code 	:= get_vendor_site_rec.vendor_site_code;
      l_vendor_site_rec.address_line1 		:= get_vendor_site_rec.address_line1;
      l_vendor_site_rec.address_line2 		:= get_vendor_site_rec.address_line2;
      l_vendor_site_rec.address_line3 		:= get_vendor_site_rec.address_line3;
      l_vendor_site_rec.city 							:= get_vendor_site_rec.city;
      l_vendor_site_rec.state 						:= get_vendor_site_rec.state;
      l_vendor_site_rec.zip 							:= get_vendor_site_rec.zip;
      l_vendor_site_rec.country 					:= get_vendor_site_rec.country;
      x_rec_count := 1;
   END LOOP;

   p_vendor_site_rec := l_vendor_site_rec;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UTILITY_PVT.Get_Vendor_Site');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.ADD;
END Get_Vendor_Site;

PROCEDURE Get_Vendor_Contact(
	 p_vendor_contact_rec IN OUT NOCOPY vendor_contact_rec_type
	 ,x_rec_count		OUT NOCOPY NUMBER
   	,x_return_status	OUT NOCOPY	  VARCHAR2
)
IS

   CURSOR get_vendor_contact_csr (p_vendor_site_id IN NUMBER, p_vendor_contact_id IN NUMBER)
   IS
			SELECT	poc.first_name ,
				poc.middle_name ,
				poc.last_name ,
				poc.area_code||poc.phone phone,
				poc.email_address ,
				poc.fax
			FROM    ap_supplier_sites_all assa,
				po_vendor_contacts poc
      WHERE assa.vendor_site_id = p_vendor_site_id
       AND assa.vendor_site_id = poc.vendor_site_id
        AND assa.party_site_id = poc.org_party_site_id
        AND poc.vendor_contact_id = p_vendor_contact_id;

   l_vendor_contact_rec vendor_contact_rec_type := p_vendor_contact_rec;

BEGIN
   x_rec_count := 0;
   x_return_status := fnd_api.g_ret_sts_success;

   IF l_vendor_contact_rec.vendor_site_ID IS NULL THEN
				 FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
				 FND_MESSAGE.set_token('ID', 'Vendor Site ID');
				 FND_MSG_PUB.add;
				 RAISE FND_API.G_EXC_ERROR;
   ELSIF l_vendor_contact_rec.vendor_contact_ID IS NULL THEN
				 FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
				 FND_MESSAGE.set_token('ID', 'Vendor Contact ID');
				 FND_MSG_PUB.add;
				 RAISE FND_API.G_EXC_ERROR;
   END IF;

  FOR get_vendor_contact_rec IN get_vendor_contact_csr(l_vendor_contact_rec.vendor_site_ID,l_vendor_contact_rec.vendor_contact_ID)
  LOOP
      l_vendor_contact_rec.contact_first_name 	:= get_vendor_contact_rec.first_name;
      l_vendor_contact_rec.contact_middle_name 	:= get_vendor_contact_rec.middle_name;
      l_vendor_contact_rec.contact_last_name 		:= get_vendor_contact_rec.last_name;
      l_vendor_contact_rec.contact_phone 				:= get_vendor_contact_rec.phone;
      l_vendor_contact_rec.contact_email_address := get_vendor_contact_rec.email_address;
      l_vendor_contact_rec.contact_fax 					:= get_vendor_contact_rec.fax;
      x_rec_count := 1;

   END LOOP;

   p_vendor_contact_rec := l_vendor_contact_rec;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UTILITY_PVT.Get_Vendor_Contact');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.ADD;
END Get_Vendor_Contact;

PROCEDURE Get_Warehouse(
	 p_warehouse_tbl 	IN OUT NOCOPY warehouse_tbl_type
	 ,x_rec_count			OUT NOCOPY NUMBER
   ,x_return_status	OUT NOCOPY	  VARCHAR2
)
IS

cursor get_warehouse_csr(p_organization_id IN NUMBER) is
	SELECT
	  ood.organization_name warehouse
	FROM
	  org_organization_definitions ood
	WHERE
	  ood.organization_id  = p_organization_id;
l_warehouse_tbl	warehouse_tbl_type := p_warehouse_tbl;
l_module               CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_UTILITY_PVT.GET_WAREHOUSE';

BEGIN
   x_rec_count := 0;
   x_return_status := fnd_api.g_ret_sts_success;



IF l_warehouse_tbl.COUNT > 0 THEN

   FOR i in l_warehouse_tbl.FIRST..l_warehouse_tbl.LAST
   LOOP
		 IF l_warehouse_tbl(i).warehouse_id IS NULL THEN
				 FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
				 FND_MESSAGE.set_token('ID', 'Warehouse ID');
				 FND_MSG_PUB.add;
				 x_return_status := FND_API.G_RET_STS_ERROR;
			ELSE
					FOR get_warehouse_rec IN get_warehouse_csr(l_warehouse_tbl(i).warehouse_id)
					LOOP
						 l_warehouse_tbl(i).warehouse_name := get_warehouse_rec.warehouse;
					END LOOP;
			END IF;
   END LOOP;
END IF;

   x_rec_count := l_warehouse_tbl.COUNT;
   p_warehouse_tbl := l_warehouse_tbl;

   DPP_UTILITY_PVT.debug_message (FND_LOG.LEVEL_STATEMENT, l_module, 'get_warehouse(): x_return_status: ' || x_return_status);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UTILITY_PVT.Get_Warehouse');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.ADD;
END Get_Warehouse;

PROCEDURE Get_Customer(
	 p_customer_tbl IN OUT NOCOPY customer_tbl_type
	,x_rec_count		OUT NOCOPY NUMBER
  ,x_return_status	OUT NOCOPY	  VARCHAR2
)
IS
CURSOR get_customer_csr (p_customer_id IN NUMBER) IS
  SELECT
		  hz.account_number,
		  hz.account_name
		FROM
		  hz_cust_accounts hz
		WHERE
		 hz.cust_account_id = p_customer_id;
   l_customer_tbl customer_tbl_type := 	p_customer_tbl;
	l_module       CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_UTILITY_PVT.GET_CUSTOMER';

BEGIN
    x_rec_count := 0;
    x_return_status := fnd_api.g_ret_sts_success;

		FOR i in l_customer_tbl.FIRST..l_customer_tbl.LAST
		LOOP

			 IF l_customer_tbl(i).customer_id IS NULL THEN
				 FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
				 FND_MESSAGE.set_token('ID', 'Customer ID');
				 FND_MSG_PUB.add;
				 x_return_status := FND_API.G_RET_STS_ERROR;
			 ELSE

				 FOR get_customer_rec IN get_customer_csr(l_customer_tbl(i).customer_id)
				 LOOP
						l_customer_tbl(i).customer_number := get_customer_rec.account_number;
						l_customer_tbl(i).customer_name := get_customer_rec.account_name;
				 END LOOP;

			END IF;

		END LOOP;

		x_rec_count 		:= l_customer_tbl.COUNT;
		p_customer_tbl 	:= l_customer_tbl;

      DPP_UTILITY_PVT.debug_message (FND_LOG.LEVEL_STATEMENT, l_module, 'get_customer(): x_return_status: ' || x_return_status);

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UTILITY_PVT.Get_Customer');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.ADD;
END Get_Customer;

PROCEDURE Get_Product(
	  p_item_tbl	     	IN OUT NOCOPY item_tbl_type
         ,p_org_id    IN    NUMBER
	 ,x_rec_count		OUT NOCOPY NUMBER
   ,x_return_status	OUT NOCOPY	  VARCHAR2
)
IS

l_org_id NUMBER;
l_module CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_UTILITY_PVT.GET_PRODUCT';

CURSOR Get_Product_csr (p_inventory_item_id IN NUMBER, p_org_id IN NUMBER)
IS
    SELECT concatenated_segments,
           description
    FROM mtl_system_items_kfv msi,
         financials_system_params_all fspa
    WHERE fspa.org_id = p_org_id and
          fspa.inventory_organization_id = msi.organization_id and
          msi.inventory_item_id = p_inventory_item_id;

l_item_tbl item_tbl_type := p_item_tbl;

BEGIN

   IF (p_org_id IS NOT NULL) THEN
       l_org_id := p_org_id;
   ELSE
             fnd_message.set_name('DPP', 'DPP_ORG_ID_NOTFOUND');
             fnd_msg_pub.add;

          RAISE fnd_api.g_exc_error;
   END IF;

   dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'debug: start ' || l_org_id);

   x_rec_count := 0;
   x_return_status := fnd_api.g_ret_sts_success;

		FOR i in l_item_tbl.FIRST..l_item_tbl.LAST
		LOOP

			 IF l_item_tbl(i).inventory_item_id IS NULL THEN
				 FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
				 FND_MESSAGE.set_token('ID', 'Inventory Item ID');
				 FND_MSG_PUB.add;
				 x_return_status := FND_API.G_RET_STS_ERROR;

			 ELSE

				 FOR Get_Product_rec IN Get_Product_csr(l_item_tbl(i).inventory_item_id, l_org_id)
				 LOOP
						l_item_tbl(i).item_number := Get_Product_rec.concatenated_segments;
						l_item_tbl(i).description := Get_Product_rec.description;
				 END LOOP;
			 END IF;
		END LOOP;

	x_rec_count := l_item_tbl.COUNT;
	p_item_tbl := l_item_tbl;

   DPP_UTILITY_PVT.debug_message (FND_LOG.LEVEL_STATEMENT, l_module, 'get_product(): x_return_status: ' || x_return_status);

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UTILITY_PVT.Get_Product');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.ADD;
END Get_Product;

--To be used incase we are storing the log messages in the fnd_log_messages table
--Currently all debug messages are going into the DPP_LOG_MESSAGES table

PROCEDURE debug_message (p_log_level      IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
                         p_module_name    IN VARCHAR2,
                         p_text           IN VARCHAR2)
IS

BEGIN

  IF( p_log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(p_log_level, p_module_name, p_text);
  END IF;

END debug_message;

/*
PROCEDURE debug_message(
   p_message_text   IN  VARCHAR2,
   p_message_level  IN  NUMBER := NULL
)
IS

PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

   INSERT INTO DPP_LOG_MESSAGES(LOG_ID,LOG_MESSAGE) VALUES(DPP_DEBUG_LOG_ID_SEQ.nextval, p_message_text);
   COMMIT;

END debug_message;
*/

PROCEDURE error_message(
   p_message_name VARCHAR2,
   p_token_name   VARCHAR2 := NULL,
   P_token_value  VARCHAR2 := NULL
)
IS
BEGIN
      FND_MESSAGE.set_name('DPP', p_message_name);
      IF p_token_name IS NOT NULL THEN
         FND_MESSAGE.set_token(p_token_name, p_token_value);
      END IF;
      FND_MSG_PUB.add;
END error_message;

PROCEDURE get_EmailAddress(
	  p_user_id IN NUMBER
	 ,x_email_address	OUT NOCOPY VARCHAR2
   ,x_return_status	OUT NOCOPY	  VARCHAR2
)
AS
CURSOR Get_Mail_ID_csr (p_user_id IN NUMBER)
IS
    select email_address
		from fnd_user
		where user_id = p_user_id;


l_user_id NUMBER := p_user_id;

BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   IF l_user_id IS NULL THEN
		 FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
		 FND_MESSAGE.set_token('ID', 'User ID');
		 FND_MSG_PUB.add;
		 RAISE FND_API.G_EXC_ERROR;
   ELSE

   FOR Get_Mail_ID_rec IN Get_Mail_ID_csr(l_user_id)
   LOOP
      x_email_address := Get_Mail_ID_rec.email_address;
   END LOOP;

   END IF;

   IF x_email_address IS NULL THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UTILITY_PVT.get_EmailAddress');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.ADD;
END get_EmailAddress;

PROCEDURE convert_currency(
   p_from_currency   IN       VARCHAR2
  ,p_to_currency     IN       VARCHAR2
  ,p_conv_type       IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR
  ,p_conv_rate       IN       NUMBER   DEFAULT FND_API.G_MISS_NUM
  ,p_conv_date       IN       DATE     DEFAULT SYSDATE
  ,p_from_amount     IN       NUMBER
  ,x_return_status   OUT NOCOPY      VARCHAR2
  ,x_to_amount       OUT NOCOPY      NUMBER
  ,x_rate            OUT NOCOPY      NUMBER)
IS
   l_conversion_type_profile    CONSTANT VARCHAR2(30) := 'DPP_CURRENCY_CONVERSION_TYPE';
   l_user_rate                  CONSTANT NUMBER       := 1;
   -- Currenty not used.
   -- this should be a profile
   l_max_roll_days              CONSTANT NUMBER       := -1;
   -- Negative so API rolls back to find the last conversion rate.
   -- this should be a profile
   l_denominator      NUMBER;   -- Not used in Marketing.
   l_numerator        NUMBER;   -- Not used in Marketing.
   l_conversion_type  VARCHAR2(30); -- Curr conversion type; see API doc for details.
	l_module           CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_UTILITY_PVT.CONVERT_CURRENCY';

BEGIN
   -- Initialize return status.
   x_return_status := fnd_api.g_ret_sts_success;
   -- condition added to pass conversion types
   IF p_conv_type = FND_API.G_MISS_CHAR THEN
     -- Get the currency conversion type from profile option
     l_conversion_type := fnd_profile.VALUE(l_conversion_type_profile);
     -- Conversion type cannot be null in profile
     IF l_conversion_type IS NULL THEN
         fnd_message.set_name('DPP', 'DPP_NO_EXCHANGE_TYPE');
         fnd_msg_pub.add;
       x_return_status := fnd_api.g_ret_sts_error;
       RETURN;
     END IF;
   ELSE
     l_conversion_type := p_conv_type;
   END IF;

   -- Call the proper GL API to convert the amount.
   gl_currency_api.convert_closest_amount(
      x_from_currency => p_from_currency
     ,x_to_currency => p_to_currency
     ,x_conversion_date => p_conv_date
     ,x_conversion_type => l_conversion_type
     ,x_user_rate => p_conv_rate
     ,x_amount => p_from_amount
     ,x_max_roll_days => l_max_roll_days
     ,x_converted_amount => x_to_amount
     ,x_denominator => l_denominator
     ,x_numerator => l_numerator
     ,x_rate => x_rate);
   --

EXCEPTION
   WHEN gl_currency_api.no_rate THEN
         fnd_message.set_name('DPP', 'DPP_NO_RATE');
         fnd_message.set_token('CURRENCY_FROM', p_from_currency);
         fnd_message.set_token('CURRENCY_TO', p_to_currency);
         fnd_msg_pub.add;

      x_return_status := fnd_api.g_ret_sts_error;
   WHEN gl_currency_api.invalid_currency THEN
         fnd_message.set_name('DPP', 'DPP_INVALID_CURR');
         fnd_message.set_token('CURRENCY_FROM', p_from_currency);
         fnd_message.set_token('CURRENCY_TO', p_to_currency);
         fnd_msg_pub.add;

      x_return_status := fnd_api.g_ret_sts_error;
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
         FND_MESSAGE.SET_NAME('FND', 'SQL_PLSQL_ERROR');
				 FND_MESSAGE.SET_TOKEN('ROUTINE', 'DPP_UTILITY_PVT.convert_currency');
				 FND_MESSAGE.SET_TOKEN('ERRNO', sqlcode);
			   FND_MESSAGE.SET_TOKEN('REASON', sqlerrm);
			   FND_MSG_PUB.ADD;
         DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_EXCEPTION, l_module, sqlerrm);

END convert_currency;

PROCEDURE calculate_functional_curr(
   p_from_amount          IN       NUMBER
  ,p_conv_date            IN       DATE DEFAULT SYSDATE
  ,p_tc_currency_code     IN       VARCHAR2
  ,p_org_id               IN       NUMBER DEFAULT NULL
  ,x_to_amount            OUT NOCOPY      NUMBER
  ,x_set_of_books_id      OUT NOCOPY      NUMBER
  ,x_mrc_sob_type_code    OUT NOCOPY      VARCHAR2
  ,x_fc_currency_code     OUT NOCOPY      VARCHAR2
  ,x_exchange_rate_type   IN OUT NOCOPY   VARCHAR2
  ,x_exchange_rate        IN OUT NOCOPY   NUMBER
  ,x_return_status        OUT NOCOPY      VARCHAR2)
IS
   l_conversion_type_profile    CONSTANT VARCHAR2(30) := 'DPP_CURRENCY_CONVERSION_TYPE';
   l_user_rate                  CONSTANT NUMBER       := 1;
   -- Currenty not used. --  this should be a profile
   l_max_roll_days              CONSTANT NUMBER       := -1;
   -- Negative so API rolls back to find the last conversion rate.
   -- this should be a profile
   l_denominator                         NUMBER;   -- Not used in Marketing.
   l_numerator                           NUMBER;   -- Not used in Marketing.
   l_conversion_type                     VARCHAR2(30);
   l_org_id                              NUMBER;
	l_module               CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_UTILITY_PVT.CALCULATE_FUNCTIONAL_CURR';

   -- Cursor to get the primary set_of_books_id ,functional_currency_code
   CURSOR c_get_gl_info(p_org_id   IN   NUMBER)
   IS
      SELECT  gs.set_of_books_id
      ,       gs.currency_code
      FROM   gl_sets_of_books gs
      ,      hr_operating_units hr
      WHERE  hr.set_of_books_id = gs.set_of_books_id
      AND    hr.organization_id = p_org_id;

BEGIN
   -- Initialize return status.
   x_return_status := fnd_api.g_ret_sts_success;

   --    Get the currency conversion type from profile option
   IF x_exchange_rate_type IS NULL THEN
      l_conversion_type := fnd_profile.VALUE(l_conversion_type_profile);
   ELSE
      l_conversion_type := x_exchange_rate_type;
   END IF;

   IF l_conversion_type IS NULL THEN
         fnd_message.set_name('DPP', 'DPP_NO_EXCHANGE_TYPE');
         fnd_msg_pub.add;

      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   ELSE
      IF ozf_utility_pvt.check_fk_exists('GL_DAILY_CONVERSION_TYPES',
                                         'CONVERSION_TYPE'
                         								,l_conversion_type) = fnd_api.g_false
    THEN
            fnd_message.set_name('DPP', 'DPP_WRONG_CONVERSION_TYPE');
            fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   /* use org_id if it is passed,
      otherwise get from login session */
   IF (p_org_id IS NOT NULL) THEN
       l_org_id := p_org_id;
   ELSE

       l_org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();

       IF l_org_id IS NULL THEN
             fnd_message.set_name('DPP', 'DPP_ORG_ID_NOTFOUND');
             fnd_msg_pub.add;

          RAISE fnd_api.g_exc_error;
       END IF;

   END IF;

   dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'debug: start ' || l_org_id);

   x_mrc_sob_type_code := 'P';
   OPEN c_get_gl_info(l_org_id);
   FETCH c_get_gl_info INTO x_set_of_books_id, x_fc_currency_code;

   IF c_get_gl_info%NOTFOUND THEN
         fnd_message.set_name('DPP', 'DPP_GL_SOB_NOTFOUND');
         fnd_msg_pub.add;

      RAISE fnd_api.g_exc_error;
   END IF;

   CLOSE c_get_gl_info;
   -- Call the proper GL API to convert the amount.
   gl_currency_api.convert_closest_amount(
      x_from_currency => p_tc_currency_code
     ,x_to_currency => x_fc_currency_code
     ,x_conversion_date => p_conv_date
     ,x_conversion_type => l_conversion_type
     ,x_user_rate => x_exchange_rate
     ,x_amount => p_from_amount
     ,x_max_roll_days => l_max_roll_days
     ,x_converted_amount => x_to_amount
     ,x_denominator => l_denominator
     ,x_numerator => l_numerator
     ,x_rate => x_exchange_rate);

   x_exchange_rate_type := l_conversion_type;
   --

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
   WHEN gl_currency_api.no_rate THEN
         fnd_message.set_name('DPP', 'DPP_NO_RATE');
         fnd_msg_pub.add;

      x_return_status := fnd_api.g_ret_sts_error;
   WHEN gl_currency_api.invalid_currency THEN
         fnd_message.set_name('DPP', 'DPP_INVALID_CURR');
         fnd_msg_pub.add;

      x_return_status := fnd_api.g_ret_sts_error;
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

				 FND_MESSAGE.SET_NAME('FND', 'SQL_PLSQL_ERROR');
				 FND_MESSAGE.SET_TOKEN('ROUTINE', 'DPP_UTILITY_PVT.Convert_functional_curr');
				 FND_MESSAGE.SET_TOKEN('ERRNO', sqlcode);
				 FND_MESSAGE.SET_TOKEN('REASON', sqlerrm);
			   FND_MSG_PUB.ADD;
END calculate_functional_curr;
END DPP_UTILITY_PVT;

/
