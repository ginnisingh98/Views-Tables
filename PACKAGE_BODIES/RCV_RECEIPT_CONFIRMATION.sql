--------------------------------------------------------
--  DDL for Package Body RCV_RECEIPT_CONFIRMATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_RECEIPT_CONFIRMATION" AS
/* $Header: RCVRCCNB.pls 120.0.12010000.12 2010/04/13 11:32:34 smididud noship $ */

g_asn_debug      VARCHAR2(1)  := asn_debug.is_debug_on; -- Bug 9152790

PROCEDURE send_confirmation (x_errbuf         OUT NOCOPY VARCHAR2,
                             x_retcode        OUT NOCOPY NUMBER,
                             p_deploy_mode    IN VARCHAR2,
                             p_client_code    IN VARCHAR2,
                             p_org_id         IN NUMBER,
			     p_dummy_client   IN VARCHAR2,
                             p_trx_date_from  IN VARCHAR2,
                             p_trx_date_to    IN VARCHAR2,
                             p_rcpt_from      IN NUMBER,
                             p_rcpt_to        IN NUMBER,
                             p_xml_doc_id     IN NUMBER) IS

l_event_name       VARCHAR2(100);
l_return_status   VARCHAR2(1);
temp_shid         NUMBER := NULL;
p_shid_from       NUMBER := NULL;
p_shid_to         NUMBER := NULL;
xml_doc_id        NUMBER := NULL;
trx_date_from         VARCHAR2(100);
trx_date_to           VARCHAR2(100);
l_trx_date_from       DATE;
l_trx_date_to         DATE;
l_wms_deployment_mode VARCHAR2(2);



  CURSOR get_rcv_headers_1(l_trx_date_from DATE, l_trx_date_to DATE) IS
  SELECT distinct rsh.shipment_header_id
  FROM rcv_shipment_headers rsh,
       rcv_shipment_lines rsl,
       rcv_transactions rt
  WHERE rsh.ship_to_org_id = p_org_id
  AND wms_deploy.get_client_code(rsl.item_id) =  p_client_code
  AND rt.transaction_date BETWEEN nvl(l_trx_date_from,rt.transaction_date) AND nvl(l_trx_date_to, rt.transaction_date)
  AND rsh.shipment_header_id BETWEEN nvl(p_shid_from,rsh.shipment_header_id) AND nvl(p_shid_to, rsh.shipment_header_id)
  AND rsh.shipment_header_id = rt.shipment_header_id
  AND rt.shipment_line_id = rsl.shipment_line_id
  AND Nvl(rt.xml_document_id,-99) = nvl(p_xml_doc_id,-99)
  AND Nvl(rt.receipt_confirmation_extracted,'N') not in ('Y','P')
  AND (rt.transaction_type IN ('DELIVER') OR
       (rt.TRANSACTION_TYPE IN ('CORRECT', 'RETURN TO RECEIVING')
                AND EXISTS (SELECT '1' FROM rcv_transactions rt2
                            WHERE rt.parent_transaction_id = rt2.transaction_id
                            AND rt2.transaction_type = 'DELIVER')
       ) OR
       (rt.TRANSACTION_TYPE IN ('CORRECT')
                AND EXISTS (SELECT '1' FROM rcv_transactions rt3
                            WHERE rt.parent_transaction_id = rt3.transaction_id
                            AND rt3.transaction_type = 'RETURN TO RECEIVING')
       )
    ) order by shipment_header_id asc;

  CURSOR get_rcv_headers_2(l_trx_date_from DATE, l_trx_date_to DATE) IS
  SELECT distinct rsh.shipment_header_id
  FROM rcv_shipment_headers rsh,
       rcv_shipment_lines rsl,
       rcv_transactions rt
  WHERE rsh.ship_to_org_id = p_org_id
  AND wms_deploy.get_client_code(rsl.item_id) =  p_client_code
  AND rt.transaction_date BETWEEN nvl(l_trx_date_from,rt.transaction_date) AND nvl(l_trx_date_to, rt.transaction_date)
  AND rsh.shipment_header_id BETWEEN nvl(p_shid_from,rsh.shipment_header_id) AND nvl(p_shid_to, rsh.shipment_header_id)
  AND rt.xml_document_id = p_xml_doc_id
  AND rsh.shipment_header_id = rt.shipment_header_id
  AND rt.shipment_line_id = rsl.shipment_line_id
  AND Nvl(rt.receipt_confirmation_extracted,'N') in ('Y')
  AND (rt.transaction_type IN ('DELIVER') OR
       (rt.TRANSACTION_TYPE IN ('CORRECT', 'RETURN TO RECEIVING')
                AND EXISTS (SELECT '1' FROM rcv_transactions rt2
                            WHERE rt.parent_transaction_id = rt2.transaction_id
                            AND rt2.transaction_type = 'DELIVER')
       ) OR
       (rt.TRANSACTION_TYPE IN ('CORRECT')
                AND EXISTS (SELECT '1' FROM rcv_transactions rt3
                            WHERE rt.parent_transaction_id = rt3.transaction_id
                            AND rt3.transaction_type = 'RETURN TO RECEIVING')
       )
    ) order by shipment_header_id asc;

  CURSOR get_rcv_headers_3(l_trx_date_from DATE, l_trx_date_to DATE) IS
  SELECT distinct rsh.shipment_header_id
  FROM rcv_shipment_headers rsh,
       rcv_transactions rt
  WHERE rsh.ship_to_org_id = p_org_id
  AND rt.transaction_date BETWEEN nvl(l_trx_date_from,rt.transaction_date) AND nvl(l_trx_date_to, rt.transaction_date)
  AND rsh.shipment_header_id BETWEEN nvl(p_shid_from,rsh.shipment_header_id) AND nvl(p_shid_to, rsh.shipment_header_id)
  AND rsh.shipment_header_id = rt.shipment_header_id
  AND Nvl(rt.xml_document_id,-99) = nvl(p_xml_doc_id,-99)
  AND Nvl(rt.receipt_confirmation_extracted,'N') not in ('Y','P')
  AND (rt.transaction_type IN ('DELIVER') OR
       (rt.TRANSACTION_TYPE IN ('CORRECT', 'RETURN TO RECEIVING')
                AND EXISTS (SELECT '1' FROM rcv_transactions rt2
                            WHERE rt.parent_transaction_id = rt2.transaction_id
                            AND rt2.transaction_type = 'DELIVER')
       ) OR
       (rt.TRANSACTION_TYPE IN ('CORRECT')
                AND EXISTS (SELECT '1' FROM rcv_transactions rt3
                            WHERE rt.parent_transaction_id = rt3.transaction_id
                            AND rt3.transaction_type = 'RETURN TO RECEIVING')
       )
    ) order by shipment_header_id asc;

  CURSOR get_rcv_headers_4(l_trx_date_from DATE, l_trx_date_to DATE) IS
  SELECT distinct rsh.shipment_header_id
  FROM rcv_shipment_headers rsh,
       rcv_transactions rt
  WHERE rsh.ship_to_org_id = p_org_id
  AND rt.transaction_date BETWEEN nvl(l_trx_date_from,rt.transaction_date) AND nvl(l_trx_date_to, rt.transaction_date)
  AND rsh.shipment_header_id BETWEEN nvl(p_shid_from,rsh.shipment_header_id) AND nvl(p_shid_to, rsh.shipment_header_id)
  AND rsh.shipment_header_id = rt.shipment_header_id
  AND rt.xml_document_id = p_xml_doc_id
  AND Nvl(rt.receipt_confirmation_extracted,'N') in ('Y')
  AND (rt.transaction_type IN ('DELIVER') OR
       (rt.TRANSACTION_TYPE IN ('CORRECT', 'RETURN TO RECEIVING')
                AND EXISTS (SELECT '1' FROM rcv_transactions rt2
                            WHERE rt.parent_transaction_id = rt2.transaction_id
                            AND rt2.transaction_type = 'DELIVER')
       ) OR
       (rt.TRANSACTION_TYPE IN ('CORRECT')
                AND EXISTS (SELECT '1' FROM rcv_transactions rt3
                            WHERE rt.parent_transaction_id = rt3.transaction_id
                            AND rt3.transaction_type = 'RETURN TO RECEIVING')
       )
    ) order by shipment_header_id asc;

  grh   get_rcv_headers_1%ROWTYPE;

BEGIN

l_wms_deployment_mode := wms_deploy.wms_deployment_mode;

IF (g_asn_debug = 'Y') THEN
    asn_debug.put_line('Deployment Mode is '|| l_wms_deployment_mode);
END IF;

IF (l_wms_deployment_mode not in ('L','D')) THEN
    RETURN;
END IF;

IF (g_asn_debug = 'Y') THEN
    asn_debug.put_line('Entering send_confirmation call');
    asn_debug.put_line('p_org_id is '||p_org_id);
    asn_debug.put_line('p_client_code is '||p_client_code);
    asn_debug.put_line('p_xml_doc_id is ' ||p_xml_doc_id);
END IF;


x_errbuf := 'Success';
x_retcode := 0;


IF p_rcpt_from IS NOT NULL AND p_rcpt_to IS NULL THEN
   p_shid_from := p_rcpt_from;
   p_shid_to := p_rcpt_from;
END IF;

IF p_rcpt_from IS NULL AND p_rcpt_to IS NOT NULL THEN
   p_shid_from := p_rcpt_to;
   p_shid_to := p_rcpt_to;
END IF;

IF p_rcpt_from IS NOT NULL AND p_rcpt_to IS NOT NULL THEN
   p_shid_from := p_rcpt_from;
   p_shid_to := p_rcpt_to;
END IF;


IF p_shid_from IS NOT NULL AND p_shid_to IS NOT NULL THEN

   IF p_shid_from > p_shid_to THEN
      temp_shid := p_shid_from;
      p_shid_from := p_shid_to;
      p_shid_to := temp_shid;
    END IF;

END IF;

IF p_xml_doc_id IS NOT NULL THEN
   xml_doc_id := p_xml_doc_id;
end if;


IF (g_asn_debug = 'Y') THEN
    asn_debug.put_line('p_shid_from is '||p_shid_from);
    asn_debug.put_line('p_shid_to is '||p_shid_to);
END IF;


IF p_trx_date_from IS NOT NULL AND p_trx_date_to IS NULL THEN
   trx_date_from := FND_DATE.date_to_canonical(to_date(p_trx_date_from, 'YYYY/MM/DD HH24:MI:SS'));
   l_trx_date_from := to_Date(trx_date_from, 'YYYY/MM/DD HH24:MI:SS');
   l_trx_date_to   := SYSDATE;
END IF;

IF p_trx_date_from IS NULL AND p_trx_date_to IS NOT NULL THEN
   trx_date_to   := FND_DATE.date_to_canonical(to_date(p_trx_date_to, 'YYYY/MM/DD HH24:MI:SS'));
   l_trx_date_from := null;
   l_trx_date_to  := to_Date(trx_date_to, 'YYYY/MM/DD HH24:MI:SS');
END IF;

IF p_trx_date_from IS NOT NULL AND p_trx_date_to IS NOT NULL THEN
   trx_date_from   := FND_DATE.date_to_canonical(to_date(p_trx_date_from, 'YYYY/MM/DD HH24:MI:SS'));
   trx_date_to     := FND_DATE.date_to_canonical(to_date(p_trx_date_to, 'YYYY/MM/DD HH24:MI:SS'));
   l_trx_date_from := to_Date(trx_date_from, 'YYYY/MM/DD HH24:MI:SS');
   l_trx_date_to  := to_Date(trx_date_to, 'YYYY/MM/DD HH24:MI:SS');
END IF;

IF (g_asn_debug = 'Y') THEN
    asn_debug.put_line('From Trxn Date = ' ||to_char(l_trx_date_from,'DD-MON-YYYY HH24:MI:SS'));
    asn_debug.put_line('To Trxn Date = ' || to_char(l_trx_date_to,'DD-MON-YYYY HH24:MI:SS'));
    asn_debug.put_line('xml_doc_id = '||xml_doc_id);
END IF;

l_event_name  := 'oracle.apps.po.standalone.rcpto';

IF ( p_xml_doc_id is null and p_client_code is not null ) THEN

       IF (g_asn_debug = 'Y') THEN
           asn_debug.put_line('Opening cursor get_rcv_headers_1');
       END IF;

       OPEN get_rcv_headers_1(l_trx_date_from,l_trx_date_to);

ELSIF (p_xml_doc_id is not null and p_client_code is not null) THEN

       IF (g_asn_debug = 'Y') THEN
           asn_debug.put_line('Opening cursor get_rcv_headers_2');
       END IF;

       OPEN get_rcv_headers_2(l_trx_date_from,l_trx_date_to);

ELSIF (p_xml_doc_id is null and p_client_code is null) THEN

       IF (g_asn_debug = 'Y') THEN
           asn_debug.put_line('Opening cursor get_rcv_headers_3');
       END IF;

       OPEN get_rcv_headers_3(l_trx_date_from,l_trx_date_to);

ELSIF (p_xml_doc_id is not null and p_client_code is null) THEN

       IF (g_asn_debug = 'Y') THEN
           asn_debug.put_line('Opening cursor get_rcv_headers_4');
       END IF;

       OPEN get_rcv_headers_4(l_trx_date_from,l_trx_date_to);

END IF;

LOOP

IF get_rcv_headers_1%ISOPEN THEN
       IF (g_asn_debug = 'Y') THEN
           asn_debug.put_line('Fetching cursor get_rcv_headers_1');
       END IF;
       FETCH get_rcv_headers_1 INTO grh;

   IF (get_rcv_headers_1%NOTFOUND) THEN
       IF (g_asn_debug = 'Y') THEN
           asn_debug.put_line('Closing cursor get_rcv_headers_1');
       END IF;
       CLOSE get_rcv_headers_1;
       EXIT;
   END IF;

ELSIF get_rcv_headers_2%ISOPEN THEN
       IF (g_asn_debug = 'Y') THEN
           asn_debug.put_line('Fetching cursor get_rcv_headers_2');
       END IF;
       FETCH get_rcv_headers_2 INTO grh;

   IF (get_rcv_headers_2%NOTFOUND) THEN
       IF (g_asn_debug = 'Y') THEN
           asn_debug.put_line('Closing cursor get_rcv_headers_2');
       END IF;
       CLOSE get_rcv_headers_2;
       EXIT;
   END IF;

ELSIF get_rcv_headers_3%ISOPEN THEN
       IF (g_asn_debug = 'Y') THEN
           asn_debug.put_line('Fetching cursor get_rcv_headers_3');
       END IF;
       FETCH get_rcv_headers_3 INTO grh;

   IF (get_rcv_headers_3%NOTFOUND) THEN
       IF (g_asn_debug = 'Y') THEN
           asn_debug.put_line('Closing cursor get_rcv_headers_3');
       END IF;
       CLOSE get_rcv_headers_3;
       EXIT;
   END IF;

ELSIF get_rcv_headers_4%ISOPEN THEN
       IF (g_asn_debug = 'Y') THEN
           asn_debug.put_line('Fetching cursor get_rcv_headers_4');
       END IF;
       FETCH get_rcv_headers_4 INTO grh;

   IF (get_rcv_headers_4%NOTFOUND) THEN
       IF (g_asn_debug = 'Y') THEN
           asn_debug.put_line('Closing cursor get_rcv_headers_4');
       END IF;
       CLOSE get_rcv_headers_4;  EXIT;
   END IF;
END IF;


IF (xml_doc_id is NULL) THEN

   IF (l_wms_deployment_mode = 'L') then

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('WMS Deploy Mode is LSP');
                asn_debug.put_line('Updating rt.receipt_confirmation_extracted flag to P');
            END IF;

            UPDATE rcv_transactions rt
            SET rt.receipt_confirmation_extracted  = 'P'
            WHERE rt.shipment_header_id = grh.shipment_header_id
            AND nvl(rt.receipt_confirmation_extracted, 'N') = 'N'
            AND (rt.transaction_type IN ('DELIVER') OR
                 (rt.TRANSACTION_TYPE IN ('CORRECT', 'RETURN TO RECEIVING')
                            AND EXISTS (SELECT '1' FROM rcv_transactions rt2
                                        WHERE rt.parent_transaction_id = rt2.transaction_id
                                        AND rt2.transaction_type = 'DELIVER')
                 ) OR
                 (rt.TRANSACTION_TYPE IN ('CORRECT')
                            AND EXISTS (SELECT '1' FROM rcv_transactions rt3
                                        WHERE rt.parent_transaction_id = rt3.transaction_id
                                        AND rt3.transaction_type = 'RETURN TO RECEIVING')
                 )
                )
            AND EXISTS (SELECT '1' FROM rcv_shipment_lines rsl
                        WHERE rsl.shipment_line_id = rt.shipment_line_id
                        AND wms_deploy.get_client_code(rsl.item_id) =  p_client_code);

   ELSE

           IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('WMS Deploy Mode is Distributed');
                asn_debug.put_line('Updating rt.receipt_confirmation_extracted flag to P');
            END IF;


            UPDATE rcv_transactions rt
            SET rt.receipt_confirmation_extracted  = 'P'
            WHERE rt.shipment_header_id = grh.shipment_header_id
            AND nvl(rt.receipt_confirmation_extracted, 'N') = 'N'
            AND (rt.transaction_type IN ('DELIVER') OR
                 (rt.TRANSACTION_TYPE IN ('CORRECT', 'RETURN TO RECEIVING')
                            AND EXISTS (SELECT '1' FROM rcv_transactions rt2
                                        WHERE rt.parent_transaction_id = rt2.transaction_id
                                        AND rt2.transaction_type = 'DELIVER')
                 ) OR
                 (rt.TRANSACTION_TYPE IN ('CORRECT')
                            AND EXISTS (SELECT '1' FROM rcv_transactions rt3
                                        WHERE rt.parent_transaction_id = rt3.transaction_id
                                        AND rt3.transaction_type = 'RETURN TO RECEIVING')
                 )
                );

   END IF;

   COMMIT;

END IF;


RCV_TRANSACTIONS_UTIL2.Send_Document(
    p_entity_id       => grh.shipment_header_id,
    p_entity_type     => 'RCPT',
    p_action_type     => 'A',
    p_document_type   => 'RC',
    p_organization_id => p_org_id,
    p_client_code     => p_client_code,
    p_xml_document_id => p_xml_doc_id,
    x_return_status   => l_return_status);

IF (g_asn_debug = 'Y') THEN
    asn_debug.put_line('Send_Document.l_return_status is ' || l_return_status);
    asn_debug.put_line('Exiting Send_Document call');
END IF;

IF (l_return_status <> rcv_error_pkg.g_ret_sts_success) THEN
      IF (xml_doc_id is null) THEN

        IF (l_wms_deployment_mode = 'L') then

           IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('WMS Deploy Mode is LSP');
                asn_debug.put_line('Resetting rt.receipt_confirmation_extracted flag to null');
            END IF;

            UPDATE rcv_transactions rt
            SET rt.receipt_confirmation_extracted  = null,
                rt.xml_document_id = null
            WHERE rt.shipment_header_id = grh.shipment_header_id
            AND nvl(rt.receipt_confirmation_extracted, 'N') = 'P'
            AND (rt.transaction_type IN ('DELIVER') OR
                 (rt.TRANSACTION_TYPE IN ('CORRECT', 'RETURN TO RECEIVING')
                            AND EXISTS (SELECT '1' FROM rcv_transactions rt2
                                        WHERE rt.parent_transaction_id = rt2.transaction_id
                                        AND rt2.transaction_type = 'DELIVER')
                 ) OR
                 (rt.TRANSACTION_TYPE IN ('CORRECT')
                            AND EXISTS (SELECT '1' FROM rcv_transactions rt3
                                        WHERE rt.parent_transaction_id = rt3.transaction_id
                                        AND rt3.transaction_type = 'RETURN TO RECEIVING')
                 )
                )
            AND EXISTS (SELECT '1' FROM rcv_shipment_lines rsl
                        WHERE rsl.shipment_line_id = rt.shipment_line_id
                        AND wms_deploy.get_client_code(rsl.item_id) =  p_client_code);

        ELSE

           IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('WMS Deploy Mode is Distributed');
                asn_debug.put_line('Resetting rt.receipt_confirmation_extracted flag to null');
            END IF;

            UPDATE rcv_transactions rt
            SET rt.receipt_confirmation_extracted  = null,
                rt.xml_document_id = null
            WHERE rt.shipment_header_id = grh.shipment_header_id
            AND nvl(rt.receipt_confirmation_extracted, 'N') = 'P'
            AND (rt.transaction_type IN ('DELIVER') OR
                 (rt.TRANSACTION_TYPE IN ('CORRECT', 'RETURN TO RECEIVING')
                            AND EXISTS (SELECT '1' FROM rcv_transactions rt2
                                        WHERE rt.parent_transaction_id = rt2.transaction_id
                                        AND rt2.transaction_type = 'DELIVER')
                 ) OR
                 (rt.TRANSACTION_TYPE IN ('CORRECT')
                            AND EXISTS (SELECT '1' FROM rcv_transactions rt3
                                        WHERE rt.parent_transaction_id = rt3.transaction_id
                                        AND rt3.transaction_type = 'RETURN TO RECEIVING')
                 )
                );

        END IF;

      END IF;
END IF;

END LOOP;

      IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('Exit Loop');
          asn_debug.put_line('Exiting send_confirmation call');
      END IF;

COMMIT;

EXCEPTION
    WHEN OTHERS THEN

       IF (g_asn_debug = 'Y') THEN
           asn_debug.put_line('Exception : '||sqlerrm||' occurred in Send_Confirmation');
       END IF;
       ROLLBACK;

       IF ( get_rcv_headers_1%ISOPEN) THEN
          IF (g_asn_debug = 'Y') THEN
              asn_debug.put_line('Closing cursor get_rcv_headers_1 in exception block');
          END IF;
          close get_rcv_headers_1;
       END IF;

       IF ( get_rcv_headers_2%ISOPEN) THEN
          IF (g_asn_debug = 'Y') THEN
              asn_debug.put_line('Closing cursor get_rcv_headers_2 in exception block');
          END IF;
          close get_rcv_headers_2;
       END IF;

       IF ( get_rcv_headers_3%ISOPEN) THEN
          IF (g_asn_debug = 'Y') THEN
              asn_debug.put_line('Closing cursor get_rcv_headers_3 in exception block');
          END IF;
          close get_rcv_headers_3;
       END IF;

      IF ( get_rcv_headers_4%ISOPEN) THEN
          IF (g_asn_debug = 'Y') THEN
              asn_debug.put_line('Closing cursor get_rcv_headers_4 in exception block');
          END IF;
          close get_rcv_headers_4;
       END IF;

       x_errbuf := 'Error';
       x_retcode := 2;

 END send_confirmation;


 PROCEDURE get_ou_name(p_org_id NUMBER, p_ou_name OUT NOCOPY varchar2) IS
 l_ou_name VARCHAR2(240);
 BEGIN
    SELECT organization_name
    INTO l_ou_name
    FROM org_organization_definitions
    WHERE organization_id = p_org_id;

    p_ou_name := l_ou_name;

 EXCEPTION
 WHEN OTHERS THEN
 p_ou_name := NULL;
 END;

 END rcv_receipt_confirmation;

/
