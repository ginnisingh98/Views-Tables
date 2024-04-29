--------------------------------------------------------
--  DDL for Package Body CLN_NTFYINVC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CLN_NTFYINVC_PKG" AS
/* $Header: CLN3C3B.pls 120.2 2006/10/04 11:28:07 bsaratna noship $ */

   l_debug_level        NUMBER;

   FUNCTION GET_AR_REJECTIONS_STRING(p_invoice_id             IN              NUMBER)
                                     RETURN VARCHAR2 IS

      l_parent_id               AP_INTERFACE_REJECTIONS.PARENT_ID%TYPE;
      l_reject_code             AP_INTERFACE_REJECTIONS.REJECT_LOOKUP_CODE%TYPE;
      l_error_reject_string     VARCHAR2(2000);
      l_count_failed_rows       VARCHAR2(10);

      CURSOR c_header_errors IS
            SELECT  PARENT_ID, REJECT_LOOKUP_CODE
              FROM  AP_INTERFACE_REJECTIONS
              WHERE PARENT_ID = p_invoice_id
                AND PARENT_TABLE = 'AP_INVOICES_INTERFACE';

      CURSOR c_line_errors IS
            SELECT  PARENT_ID, REJECT_LOOKUP_CODE
              FROM  AP_INTERFACE_REJECTIONS
              WHERE PARENT_ID in (SELECT INVOICE_LINE_ID FROM AP_INVOICE_LINES_INTERFACE WHERE INVOICE_ID = p_invoice_id)
                AND PARENT_TABLE = 'AP_INVOICE_LINES_INTERFACE';

   BEGIN
        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('------ Entering CLN_NTFYINVC_PKG.GET_AR_REJECTIONS_STRING API ------ ', 2);
        END IF;

        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('p_invoice_id : ' || p_invoice_id, 1);
        END IF;

        -- check for failed rows..
        BEGIN
                SELECT 'x'
                INTO l_count_failed_rows
                FROM DUAL
                WHERE EXISTS (
                                  SELECT 'x'
                                  FROM ap_interface_rejections air
                                  WHERE parent_table = 'AP_INVOICES_INTERFACE'
                                  AND parent_id = p_invoice_id
                                  UNION ALL
                                  SELECT 'x'
                                  FROM ap_interface_rejections air
                                  WHERE parent_table = 'AP_INVOICE_LINES_INTERFACE'
                                  AND parent_id in (select invoice_line_id from ap_invoice_lines_interface aili
                                                   where aili.invoice_id = p_invoice_id)
                             );
        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        cln_debug_pub.Add('No errors found in the interface rejections table', 1);
        END;

        IF (l_count_failed_rows = 'x') THEN
            l_error_reject_string         := '';

            OPEN c_header_errors;
            FETCH c_header_errors INTO l_parent_id, l_reject_code;

            IF (l_Debug_Level <= 1) THEN
               cln_debug_pub.Add('Entered Cursor to find error message at header', 1);
               cln_debug_pub.Add('Reject Lookup Code      '||l_reject_code, 1);
            END IF;

            CLOSE c_header_errors;

            l_error_reject_string := l_reject_code || ',';

            OPEN c_line_errors;
            LOOP
                FETCH c_line_errors INTO l_parent_id, l_reject_code;
                EXIT WHEN c_line_errors%NOTFOUND;
                -- process row here
                IF (l_Debug_Level <= 1) THEN
                      cln_debug_pub.Add('Entered Cursor to find error message at line level', 1);
                      cln_debug_pub.Add('Parent ID               '||l_parent_id, 1);
                      cln_debug_pub.Add('Reject Lookup Code      '||l_reject_code, 1);
                END IF;

                l_error_reject_string := l_error_reject_string || l_parent_id || ':' || l_reject_code || ',';
            END LOOP;

            CLOSE c_line_errors;

            IF (l_Debug_Level <= 1) THEN
                  cln_debug_pub.Add('Moving out of Cursor .....', 1);
            END IF;

            l_error_reject_string := substr(l_error_reject_string,1,length(l_error_reject_string)-1);
            l_error_reject_string := '%' || l_error_reject_string || '%';
        ELSE

           l_error_reject_string := NULL;
        END IF;

        IF (l_Debug_Level <= 1) THEN
                  cln_debug_pub.Add('l_error_reject_string : '||  l_error_reject_string, 1);
        END IF;

        RETURN l_error_reject_string;

        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('------ Exiting CLN_NTFYINVC_PKG.GET_AR_REJECTIONS_STRING API ------ ', 2);
        END IF;
   END GET_AR_REJECTIONS_STRING;


   PROCEDURE RAISE_3C4_EVENT(
           p_invoice_id              IN          NUMBER,
           p_internal_control_number IN          NUMBER,
           p_reference_id            IN          VARCHAR2,
           p_tp_header_id            IN          NUMBER,
           p_error_reject_string     IN          VARCHAR2) IS

           l_party_id                    NUMBER;
           l_party_site_id               NUMBER;
           l_party_type                  VARCHAR2(30);
           l_org_id                      NUMBER;

           l_errmsg                      VARCHAR2(2000);
           l_error_code                  NUMBER;
           l_error_msg                   VARCHAR2(1000);
           l_raise_3c4_parameters        wf_parameter_list_t;
           l_doc_id                      VARCHAR2(30);
           l_invoice_num                 VARCHAR2(100);
           l_po_num                      VARCHAR2(100);
           l_invoice_amt                 NUMBER;
           l_invoice_date                DATE;
   BEGIN

       IF (l_debug_level <= 2) THEN
         cln_debug_pub.Add('ENTERING CLN_NTFYINVC_PKG.RAISE_3C4_EVENT', 2);
       END IF;

       IF (l_debug_level <= 1) THEN
         cln_debug_pub.Add('p_invoice_id:' || p_invoice_id, 1);
         cln_debug_pub.Add('p_internal_control_number:' || p_internal_control_number, 1);
         cln_debug_pub.Add('p_reference_id:' || p_reference_id, 1);
         cln_debug_pub.Add('p_error_reject_string:' || p_error_reject_string, 1);
         cln_debug_pub.Add('p_tp_header_id:' || p_tp_header_id, 1);
       END IF;


        --this query return the corresponding Trading Partner values for an Internal Control Number.
        -- If it raises any exception then its Unexpected error, caught in the caller Procedure
        SELECT party_id, party_site_id, party_type
        INTO   l_party_id,l_party_site_id,l_party_type
        FROM   ecx_tp_headers
        WHERE  tp_header_id = p_tp_header_id;

        IF (l_debug_level <= 1) THEN
              cln_debug_pub.Add('Obtained party type:'|| l_party_type ,1);
              cln_debug_pub.Add('Obtained party id:'|| l_party_id ,1);
              cln_debug_pub.Add('Obtained party site id:'|| l_party_site_id ,1);
        END IF;

        -- this query returns the corresponding Organisation ID for the above obtained Trading Partner values
        -- If it raises any exception then its Unexpected error, caught in the caller Procedure
        SELECT  org_id
        INTO    l_org_id
        FROM    po_vendor_sites_all
        WHERE   vendor_id = l_party_id and vendor_site_id = l_party_site_id;

        IF (l_debug_level <= 1) THEN
              cln_debug_pub.Add('Obtained Org ID:'|| l_org_id ,1);
        END IF;


        -- Assigns the next value of 'CLN.CLN_3C4_DOCUMENT_NUM_S' sequence
        SELECT M4R_3C4_DOCUMENT_NUM_S.NEXTVAL
        INTO    l_doc_id
        FROM    dual;

        l_doc_id := 'CLN3C4OT-' || l_doc_id;

        IF (l_debug_level <= 1) THEN
              cln_debug_pub.Add('l_doc_id:'|| l_doc_id ,1);
        END IF;

        get_rejected_invoice_details(p_invoice_id, l_invoice_num, l_po_num, l_invoice_amt, l_invoice_date);

        IF (l_debug_level <= 1) THEN
              cln_debug_pub.Add('l_invoice_num :'|| l_invoice_num ,1);
        END IF;

        -- raise event to start 3c4 invoice error processing
        WF_EVENT.AddParameterToList('ECX_TRANSACTION_TYPE', 'CLN', l_raise_3c4_parameters);
        WF_EVENT.AddParameterToList('ECX_TRANSACTION_SUBTYPE', 'INV_REJECT_NOTIF_OUT', l_raise_3c4_parameters);
        WF_EVENT.AddParameterToList('ECX_PARTY_TYPE', l_party_type, l_raise_3c4_parameters);
        WF_EVENT.AddParameterToList('ECX_PARTY_ID', l_party_id, l_raise_3c4_parameters);
        WF_EVENT.AddParameterToList('ECX_PARTY_SITE_ID', l_party_site_id, l_raise_3c4_parameters);
        WF_EVENT.AddParameterToList('ECX_DOCUMENT_ID', l_doc_id, l_raise_3c4_parameters);
        WF_EVENT.AddParameterToList('ORG_ID', l_org_id, l_raise_3c4_parameters);
        WF_EVENT.AddParameterToList('VALIDATION_REQUIRED_YN', 'N', l_raise_3c4_parameters);
        WF_EVENT.AddParameterToList('CH_MESSAGE_BEFORE_GENERATE_XML', 'CLN_CH_COLLABORATION_CREATED', l_raise_3c4_parameters);
        WF_EVENT.AddParameterToList('CH_MESSAGE_AFTER_XML_SENT', 'CLN_3C4_XML_SENT', l_raise_3c4_parameters);
        WF_EVENT.AddParameterToList('ECX_DELIVERY_CHECK_REQUIRED', 'Y', l_raise_3c4_parameters);
        WF_EVENT.AddParameterToList('CH_MESSAGE_NO_TP_SETUP', 'CLN_CH_TP_SETUP_NOTFOUND', l_raise_3c4_parameters);
        WF_EVENT.AddParameterToList('ECX_PARAMETER1', P_invoice_id, l_raise_3c4_parameters);
        WF_EVENT.AddParameterToList('ECX_PARAMETER2', p_reference_id, l_raise_3c4_parameters);
        WF_EVENT.AddParameterToList('ECX_PARAMETER3', p_error_reject_string, l_raise_3c4_parameters);
        WF_EVENT.AddParameterToList('ECX_PARAMETER4', l_org_id, l_raise_3c4_parameters);
        WF_EVENT.AddParameterToList('ECX_PARAMETER5', l_invoice_amt, l_raise_3c4_parameters);
        WF_EVENT.AddParameterToList('DOCUMENT_NO', l_invoice_num, l_raise_3c4_parameters);

        --WF_EVENT.AddParameterToList('CLN_DOCUMENT_NUMBER', l_invoice_num, l_raise_3c4_parameters);
        --REFERENCE_ID?
        --@@@@ - Add these params
        --WF_EVENT.AddParameterToList('INVOICE_DATE', l_invoice_id, l_raise_3c4_parameters);
        --WF_EVENT.AddParameterToList('ECX_PARAMETER4', l_po_num, l_raise_3c4_parameters);
        --WF_EVENT.Raise('oracle.apps.cln.error.ntfyinvi',l_event_key, NULL, l_raise_3c4_parameters, NULL);
        WF_EVENT.Raise('oracle.apps.cln.common.xml.out',l_doc_id, NULL, l_raise_3c4_parameters, NULL);

        IF (l_Debug_Level <= 1) THEN
              cln_debug_pub.Add('---------3c4 event raised ---------', 1);
        END IF;

        IF (l_debug_level <= 1) THEN
           cln_debug_pub.Add('Exiting CLN_NTFYINVC_PKG.RAISE_3C4_EVENT', 1);
        END IF;

   END RAISE_3C4_EVENT;



-- Start of comments
--        API name         : Get_NotifyInvoice_Params
--        Type             : Private
--        Pre-reqs         : None.
--        Function         : Gets the necessary parameters for the outbound Notify Invoice transaction.
--        Version          : Current version         1.0
--                           Initial version         1.0
--        Notes            : This procedure is called from workflow(3C3 Outbound).
-- End of comments

   PROCEDURE Get_NotifyInvoice_Params(p_itemtype               IN              VARCHAR2,
                                      p_itemkey                IN              VARCHAR2,
                                      p_actid                  IN              NUMBER,
                                      p_funcmode               IN              VARCHAR2,
                                      x_resultout              IN OUT NOCOPY   VARCHAR2) IS

   l_transaction_type            VARCHAR2(240);
   l_transaction_subtype         VARCHAR2(240);
   l_document_direction          VARCHAR2(240);
   l_party_id                    NUMBER;
   l_party_site_id               NUMBER;
   l_party_type                  VARCHAR2(30);
   l_return_code                 PLS_INTEGER;
   l_errmsg                      VARCHAR2(2000);
   l_result                      BOOLEAN;
   l_error_code                  NUMBER;
   l_error_msg                   VARCHAR2(1000);
   l_customer_trx_id             NUMBER;
   l_inv_date                    DATE;
   l_canonical_date              VARCHAR2(100);
   l_doc_transfer_id             NUMBER;
   l_document_id                 VARCHAR2(100);
   l_ntfyinvc_seq                NUMBER;
   l_organization_id             NUMBER;
   l_trx_number                  VARCHAR2(100);

   BEGIN

       IF (l_debug_level <= 1) THEN
         cln_debug_pub.Add('ENTERING CLN_NTFYINVC_PKG.Get_NotifyInvoice_Params', 1);
         cln_debug_pub.Add('With the following parameters:', 1);
         cln_debug_pub.Add('itemtype:'   || p_itemtype, 1);
         cln_debug_pub.Add('itemkey:'    || p_itemkey, 1);
         cln_debug_pub.Add('actid:'      || p_actid, 1);
         cln_debug_pub.Add('funcmode:'   || p_funcmode, 1);
         cln_debug_pub.Add('resultout:'  || x_resultout, 1);
       END IF;

       l_transaction_type := 'CLN';
       l_transaction_subtype := 'NTFYINVCO';
       l_document_direction := 'OUT';
       l_party_type := 'C';
       l_result := FALSE;

       -- Do nothing in cancel or timeout mode
       IF (p_funcmode <> wf_engine.eng_run) THEN
           x_resultout := wf_engine.eng_null;
           return; -- do not raise the exception as it would end the workflow
       END IF;

       -- Retrieve Activity Attributes
       l_party_site_id  := Wf_Engine.GetActivityAttrText(p_itemtype, p_itemkey, p_actid, 'ECX_PARTY_SITE_ID');
       l_doc_transfer_id  := Wf_Engine.GetActivityAttrText(p_itemtype, p_itemkey, p_actid, 'ECX_DOCUMENT_ID');


       -- Get party id, party site id, org_id
       BEGIN

            SELECT party_id
            INTO l_party_id
            FROM hz_party_sites
            WHERE party_site_id = l_party_site_id;

        EXCEPTION
             WHEN OTHERS THEN

               IF (l_debug_level <= 1) THEN
                     cln_debug_pub.Add('Exception - Query for Party ID failed', 1);
               END IF;
        END;

        IF (l_debug_level <= 1) THEN
          cln_debug_pub.Add('CLN_NTFYINVC_PKG.Get_NotifyInvoice_Params: Parameter Lookups Completed', 1);
          cln_debug_pub.Add('With the following parameters:', 1);
          cln_debug_pub.Add('party_id:'    || l_party_id, 1);
          cln_debug_pub.Add('party_site_id:'      || l_party_site_id, 1);
          cln_debug_pub.Add('doc_transfer_id:'      || l_doc_transfer_id, 1);
        END IF;

        IF (l_debug_level <= 1) THEN
             cln_debug_pub.Add('XML Trading Partner Setup Check Succeeded', 1);
        END IF;

        BEGIN

           SELECT customer_trx_id, org_id, trx_number,trx_date
           INTO l_customer_trx_id, l_organization_id, l_trx_number,l_inv_date
           FROM CLN_3C3_INVOICE_V
           WHERE document_transfer_id =  l_doc_transfer_id AND ROWNUM < 2;

        EXCEPTION
           WHEN OTHERS THEN

             IF (l_debug_level <= 1) THEN
                 cln_debug_pub.Add('Exception - Querying the CLN_3C3_INVOICE_V failed', 1);
             END IF;
          END;

          -- generate Document Creation Date
         l_canonical_date := FND_DATE.DATE_TO_CANONICAL(l_inv_date);

          IF (l_debug_level <= 1) THEN
            cln_debug_pub.Add('l_canonical_date'||l_canonical_date, 1);
            cln_debug_pub.Add('customer_trx_id'||l_customer_trx_id, 1);
            cln_debug_pub.Add('org_id'||l_organization_id, 1);
            cln_debug_pub.Add('trx_number'||l_trx_number, 1);
            cln_debug_pub.Add('trx_date'||l_inv_date, 1);
          END IF;

         IF (l_debug_level <= 1) THEN
                cln_debug_pub.Add('Workflow Item Attributes are set as below:',1);
                cln_debug_pub.Add('Document Number'||l_trx_number, 1);
                cln_debug_pub.Add('ORG_ID'|| l_organization_id, 1);
                cln_debug_pub.Add('ECX_TRANSACTION_TYPE'|| l_transaction_type, 1);
                cln_debug_pub.Add('ECX_TRANSACTION_SUBTYPE'|| l_transaction_subtype, 1);
                cln_debug_pub.Add('ECX_PARTY_ID'|| l_party_id, 1);
                cln_debug_pub.Add('ECX_PARTY_SITE_ID'|| l_party_site_id, 1);
                cln_debug_pub.Add('ECX_PARTY_TYPE'|| l_party_type, 1);
                cln_debug_pub.Add('DOCUMENT_CREATION_DATE'|| l_canonical_date, 1);
                cln_debug_pub.Add('PROPRIETARY_DOCUMENT_ID'|| l_trx_number, 1);
                cln_debug_pub.Add('ECX_DOCUMENT_ID'|| l_doc_transfer_id, 1);
                cln_debug_pub.Add('EVENT_KEY'|| p_itemkey, 1);

         END IF;

         wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'DOCUMENT_NO', l_trx_number);
         wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'ORG_ID', l_organization_id);
         wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'ECX_TRANSACTION_TYPE', l_transaction_type);
         wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'ECX_TRANSACTION_SUBTYPE', l_transaction_subtype);
         wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'ECX_PARTY_ID', l_party_id);
         wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'ECX_PARTY_SITE_ID', l_party_site_id);
         wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'ECX_PARTY_TYPE', l_party_type);
         wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'ECX_DOCUMENT_ID', l_doc_transfer_id);
         wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'DOCUMENT_CREATION_DATE', l_canonical_date);
         wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'PROPRIETARY_DOCUMENT_ID', l_trx_number);
         wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'REFERENCE_ID', p_itemkey);
         wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'EVENT_KEY', p_itemkey);

         -- Reached Here. Successful execution.
         x_resultout := 'SUCCESS';
         IF (l_debug_level <= 1) THEN
            cln_debug_pub.Add('Result out '|| x_resultout, 1);
         END IF;

         IF (l_debug_level <= 2) THEN
            cln_debug_pub.Add('EXITING CLN_NTFYINVC_PKG.Get_NotifyInvoice_Params Successfully', 2);
         END IF;

   EXCEPTION
      WHEN OTHERS THEN
         l_error_code := SQLCODE;
         l_error_msg  := SQLERRM;

         IF (l_debug_level <= 1) THEN
            cln_debug_pub.Add('Exception ' || ':'  || l_error_code || ':' || l_error_msg, 1);
         END IF;

         x_resultout := 'ERROR';
         IF (l_debug_level <= 1) THEN
            cln_debug_pub.Add('Result out '|| x_resultout, 1);
         END IF;

        IF (l_debug_level <= 1) THEN
           cln_debug_pub.Add('Exiting CLN_NTFYINVC_PKG.Get_NotifyInvoice_Params with Error', 1);
        END IF;

   END Get_NotifyInvoice_Params;


-- Start of comments
--        API name        : GET_PAYMENT_TERM_CODE
--        Type            : Private
--        Pre-reqs        : None.
--        Function        : Gets the Payment Term Code.
--        Version         : Current version        1.0
--                          Previous version       1.0
--                          Initial version        1.0
--      Notes             :
-- End of comments


   PROCEDURE GET_PAYMENT_TERM_CODE(p_customer_trx_id   IN         NUMBER,
                                   x_pay_t_code        OUT NOCOPY VARCHAR2 ) IS

   l_error_code        NUMBER;
   l_error_msg         VARCHAR2(2000);

   BEGIN

   IF (l_debug_level <= 2) THEN
            cln_debug_pub.Add('Entering GET_PAYMENT_TERM_CODE',2);
   END IF;

   IF (l_debug_level <= 1) THEN
            cln_debug_pub.Add('p_customer_trx_id : '|| p_customer_trx_id, 1);
   END IF;


   -- Get the Payment Terms Code
   BEGIN

      SELECT name   --This is equivalent to TERM_NAME column of AR_XML_PAYMENT_TERMS_V
      INTO   x_pay_t_code
      FROM  ra_terms t, ar_payment_schedules_all ps
      WHERE t.term_id = ps.term_id
        AND ps.customer_trx_id = p_customer_trx_id
        AND rownum < 2;

   EXCEPTION
      WHEN OTHERS THEN

          IF (l_debug_level <= 1) THEN
              cln_debug_pub.Add('Inside when others while fetching payment term', 1);
          END IF;
          x_pay_t_code := null;

   END;

   IF (l_debug_level <= 1) THEN
            cln_debug_pub.Add('Payment term code : '|| x_pay_t_code, 1);
   END IF;

   IF (l_debug_level <= 2) THEN
            cln_debug_pub.Add('Exiting GET_PAYMENT_TERM_CODE',2);
   END IF;

   EXCEPTION
          WHEN OTHERS THEN
            l_error_code      := SQLCODE;
            l_error_msg       := SQLERRM;

            IF (l_Debug_Level <= 6) THEN
                cln_debug_pub.Add('Exception in GET_PAYMENT_TERM_CODE with Error code' || l_error_code ||
                'and Errror Message' || l_error_msg,6);
            END IF;

            IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('----------- ERROR:EXITING GET_PAYMENT_TERM_CODE ------------', 2);
            END IF;

  END GET_PAYMENT_TERM_CODE;


-- Start of comments
--        API name        : GET_TAX_AMOUNT_AND_CODE
--        Type            : Private
--        Pre-reqs        : None.
--        Function        : Gets the Tax Amount and the Tax Code.
--        Version         : Current version         1.0
--                          Previous version        1.0
--                          Initial version         1.0
--      Notes             :
-- End of comments


   PROCEDURE GET_TAX_AMOUNT_AND_CODE  (p_customer_trx_line_id   IN         NUMBER,
                                       x_tax_amount      OUT NOCOPY NUMBER,
                                       x_tax_code        OUT NOCOPY VARCHAR2) IS
   l_cust_trx_id      NUMBER;
   l_cust_trx_line_id NUMBER;
   l_error_code       NUMBER;
   l_error_msg        VARCHAR2(2000);

   BEGIN

   IF (l_debug_level <= 2) THEN
            cln_debug_pub.Add('Entering GET_TAX_AMOUNT_AND_CODE',2);
   END IF;

   IF (l_debug_level <= 1) THEN
            cln_debug_pub.Add('p_customer_trx_line_id : '|| p_customer_trx_line_id, 1);
   END IF;

   -- Sum all the Tax  amounts pertaining to the Trx Line Id
   BEGIN

   SELECT sum(tax_amount)
   INTO   x_tax_amount
   FROM   AR_XML_INVOICE_TAX_V
   WHERE  link_to_cust_trx_line_id = p_customer_trx_line_id;

   EXCEPTION
   WHEN OTHERS THEN
            l_error_code      := SQLCODE;
            l_error_msg       := SQLERRM;

            IF (l_Debug_Level <= 6) THEN
                cln_debug_pub.Add('Exception in calculating the Tax amount : ' || l_error_code ||
                'and Errror Message' || l_error_msg,6);
            END IF;

   END;

   IF (l_debug_level <= 1) THEN
            cln_debug_pub.Add('Tax Amount : '|| x_tax_amount, 1);
   END IF;

   IF x_tax_amount > 0 THEN
        x_tax_code := 'DEBIT';
   ELSE IF x_tax_amount <0 THEN
           x_tax_code := 'CREDIT';
        ELSE
             x_tax_code := 'ZERO REMIT';
        END IF;
   END IF;

   IF (l_debug_level <= 1) THEN
            cln_debug_pub.Add('Tax Code : '|| x_tax_code, 1);
   END IF;

   IF (l_debug_level <= 2) THEN
            cln_debug_pub.Add('Exiting GET_TAX_AMOUNT_AND_CODE',2);
   END IF;

    EXCEPTION
          WHEN OTHERS THEN
            l_error_code      := SQLCODE;
            l_error_msg       := SQLERRM;

            IF (l_Debug_Level <= 6) THEN
                cln_debug_pub.Add('Exception in GET_TAX_AMOUNT_AND_CODE with Error code' || l_error_code ||
                'and Errror Message' || l_error_msg,6);
            END IF;

            IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('----------- ERROR:EXITING GET_TAX_AMOUNT_AND_CODE ------------', 2);
            END IF;

  END GET_TAX_AMOUNT_AND_CODE;


-- Start of comments
--        API name         : GET_DOC_GENERATION_DATETIME
--        Type             : Private
--        Pre-reqs         : None.
--        Function         : Gets the Document Generation Date and Time.
--        Version          : Current version        1.0
--                          Previous version        1.0
--                          Initial version         1.0
--        Notes           :
-- End of comments


  PROCEDURE GET_DOC_GENERATION_DATETIME(p_doc_trnsfr_id   IN         NUMBER,
                                        x_doc_gen_dt      OUT NOCOPY VARCHAR2 ) IS

   l_trx_date          DATE;
   l_error_code        NUMBER;
   l_error_msg         VARCHAR2(2000);

   BEGIN

   IF (l_debug_level <= 2) THEN
            cln_debug_pub.Add('Entering GET_DOC_GENERATION_DATETIME',2);
   END IF;

   IF  (l_debug_level <= 1) THEN
            cln_debug_pub.Add('Document Transfer ID : '|| p_doc_trnsfr_id, 1);
   END IF;

   BEGIN

   SELECT trx_date
   INTO   l_trx_date
   FROM   CLN_3C3_INVOICE_V
   WHERE  document_transfer_id =  p_doc_trnsfr_id and rownum < 2;

   EXCEPTION
   WHEN OTHERS THEN
            l_error_code      := SQLCODE;
            l_error_msg       := SQLERRM;

            IF (l_Debug_Level <= 6) THEN
                cln_debug_pub.Add('Exception while querying for the trx_date : ' || l_error_code ||
                'and Errror Message' || l_error_msg,6);
            END IF;

   END;

   IF (l_debug_level <= 1) THEN
            cln_debug_pub.Add('Transaction Date before conversion : '|| l_trx_date, 1);
   END IF;

   IF (l_debug_level <= 2) THEN
            cln_debug_pub.Add('Calling ------- cln_rn_utils.convert_to_rn_datetime ----', 2);
   END IF;

   cln_rn_utils.convert_to_rn_datetime(l_trx_date,x_doc_gen_dt);

  IF (l_debug_level <= 1) THEN
        cln_debug_pub.Add('Out of ------- cln_rn_utils.convert_to_rn_datetime ---- ', 1);
        cln_debug_pub.Add('Transaction Date after conversion : '|| x_doc_gen_dt, 1);
   END IF;

   IF (l_debug_level <= 2) THEN
            cln_debug_pub.Add('Exiting GET_DOC_GENERATION_DATETIME',2);
   END IF;

    EXCEPTION
          WHEN OTHERS THEN
            l_error_code      := SQLCODE;
            l_error_msg       := SQLERRM;

            IF (l_Debug_Level <= 6) THEN
                cln_debug_pub.Add('Exception in GET_DOC_GENERATION_DATETIME with Error code' || l_error_code ||
                'and Errror Message' || l_error_msg,6);
            END IF;

            IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('----------- ERROR:EXITING GET_DOC_GENERATION_DATETIME ------------', 2);
            END IF;

 END GET_DOC_GENERATION_DATETIME;


-- Start of comments
--        API name        : GET_PO_SHIPMENT_INFO
--        Type            : Private
--        Pre-reqs        : None.
--        Function        : Gets the PO, Line and Shipment info. of a PO
--        Version         : Current version         1.0
--                          Previous version        1.0
--                          Initial version         1.0
--      Notes             : We may need to modify this to support get PO details
--                        : for SO auto created from delivery
-- End of comments
PROCEDURE GET_PO_SHIPMENT_INFO(
                              p_org_id       IN             VARCHAR2,
                              p_so_num       IN             VARCHAR2,
                              p_so_rev_num   IN             VARCHAR2,
                              p_so_lin_num   IN             VARCHAR2,
                              x_po_num       IN OUT NOCOPY  VARCHAR2,
                              x_po_line_num  IN OUT NOCOPY  VARCHAR2,
                              x_po_ship_num  IN OUT NOCOPY  VARCHAR2) AS
BEGIN
        l_debug_level := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));
        IF (l_debug_level <= 2) THEN
                cln_debug_pub.Add('Entering CLN_NTFYINVC_PKG.GET_PO_SHIPMENT_INFO',2);
                cln_debug_pub.Add('p_org_id     - '||p_org_id    ,2);
                cln_debug_pub.Add('p_so_num     - '||p_so_num    ,2);
                cln_debug_pub.Add('p_so_rev_num - '||p_so_rev_num,2);
                cln_debug_pub.Add('p_so_lin_num - '||p_so_lin_num,2);
        END IF;

        BEGIN

                SELECT  ol.orig_sys_document_ref,ol.orig_sys_line_ref, ol.orig_sys_shipment_ref
                INTO    x_po_num, x_po_line_num,x_po_ship_num
                FROM    oe_order_headers oh, oe_order_lines ol
                WHERE   oh.org_id    = ol.org_id
                  AND   oh.header_id = ol.header_id
                  AND   oh.org_id    = trim(p_org_id)
                  AND   oh.order_number   = to_number(trim(p_so_num))
                  AND   oh.version_number = nvl(to_number(trim(p_so_rev_num)),0)
                  AND   ol.line_number    = to_number(trim(p_so_lin_num))
                  AND   rownum < 2;

               IF (l_debug_level <= 1) THEN
                       cln_debug_pub.add('PO num  - ' || x_po_num,1);
                       cln_debug_pub.add('PO line - ' || x_po_line_num,1);
                       cln_debug_pub.add('PO ship - ' || x_po_ship_num,1);
               END IF;

        EXCEPTION
                WHEN OTHERS THEN
                        IF (l_debug_level <= 5) THEN
                                cln_debug_pub.Add('Error in CLN_NTFYINVC_PKG.GET_PO_SHIPMENT_INFO',5);
                                cln_debug_pub.Add('Error - ' ||  SQLCODE || SQLERRM,5);
                        END IF;
                        x_po_num      := null;
                        x_po_line_num := null;
                        x_po_ship_num := null;
        END;

END GET_PO_SHIPMENT_INFO;



-- Start of comments
--        API name         : CLN_UPDATE_DOCUMENT_STATUS
--        Type             : Private
--        Pre-reqs         : None.
--        Function         : Updates the status for the transaction in the 'ar_document_transfers' table.
--        Version          : Current version        1.0
--                          Previous version        1.0
--                          Initial version         1.0
--        Notes            :
-- End of comments

  PROCEDURE CLN_UPDATE_DOC_STATUS(p_itemtype                   IN              VARCHAR2,
                                      p_itemkey                IN              VARCHAR2,
                                      p_actid                  IN              NUMBER,
                                      p_funcmode               IN              VARCHAR2,
                                      x_resultout              IN OUT NOCOPY   VARCHAR2)  AS
 l_status        VARCHAR2(10);
 l_doc_id        VARCHAR2(1000);
 l_error_code    NUMBER;
 l_error_msg     VARCHAR2(2000);
 l_transaction_type     VARCHAR2(100);
 l_ext_trx_type         VARCHAR2(100);
 l_ext_trx_subtype      VARCHAR2(100);
 l_transaction_subtype  VARCHAR2(100);

 BEGIN

    -- set debug level
        l_debug_level := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));

    IF (l_debug_level <= 2) THEN
            cln_debug_pub.Add('Entering CLN_UPDATE_DOC_STATUS',2);
    END IF;

    l_doc_id  := Wf_Engine.GetActivityAttrText(p_itemtype, p_itemkey, p_actid, 'ECX_DOCUMENT_ID');
    IF (l_debug_level <= 1) THEN
            cln_debug_pub.Add('Document Transfer ID : '|| l_doc_id, 1);
    END IF;

    l_transaction_type := Wf_Engine.GetActivityAttrText(p_itemtype, p_itemkey, p_actid, 'ECX_TRANSACTION_TYPE');
    IF (l_debug_level <= 1) THEN
            cln_debug_pub.Add('l_transaction_type: '|| l_transaction_type, 1);
    END IF;

    l_transaction_subtype := Wf_Engine.GetActivityAttrText(p_itemtype, p_itemkey, p_actid, 'ECX_TRANSACTION_SUBTYPE');
    IF (l_debug_level <= 1) THEN
            cln_debug_pub.Add('l_transaction_subtype : '|| l_transaction_subtype, 1);
    END IF;

    BEGIN

      SELECT EXT_TYPE, EXT_SUBTYPE
      INTO   l_ext_trx_type,l_ext_trx_subtype
      FROM   ecx_ext_processes
      WHERE  transaction_id = (SELECT transaction_id
                               FROM   ecx_transactions
                               WHERE  transaction_type = l_transaction_type
                                      AND transaction_subtype = l_transaction_subtype);

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
             cln_debug_pub.Add('No Data found for External Transaction Type and  External Transaction Type', 1);
    END;

    IF (l_debug_level <= 1) THEN
            cln_debug_pub.Add('l_ext_trx_type: '|| l_ext_trx_type, 1);
            cln_debug_pub.Add('l_ext_trx_subtype : '|| l_ext_trx_subtype, 1);
    END IF;


    BEGIN
        SELECT 'x'
        INTO l_status
        FROM DUAL
             WHERE EXISTS (
                             SELECT 'x'
                             FROM ecx_doclogs
                             WHERE document_number = l_doc_id
                                   AND item_type = p_itemtype  -- Changed to fix Bug #5031346
                                   AND item_key = p_itemkey -- Changed to fix Bug #5031346
                                   AND direction = 'OUT');
     EXCEPTION

        WHEN NO_DATA_FOUND THEN
             cln_debug_pub.Add('No Data found in ecx_doclogs', 1);
     END;

     IF (l_debug_level <= 1) THEN
                cln_debug_pub.Add('l_status:   '|| l_status , 1);
     END IF;

    UPDATE ar_document_transfers
    SET    status = decode(l_status,'x','TRANSMITTED','FAILED')
    WHERE  document_transfer_id = l_doc_id;

    IF (l_debug_level <= 1) THEN
                cln_debug_pub.Add('ar_document_transfers row updated', 1);
    END IF;

    x_resultout := 'YES';

    IF (l_debug_level <= 2) THEN
           cln_debug_pub.Add('Exiting CLN_UPDATE_DOC_STATUS',2);
    END IF;
  EXCEPTION
     WHEN OTHERS THEN
            l_error_code      := SQLCODE;
            l_error_msg       := SQLERRM;

            IF (l_Debug_Level <= 6) THEN
                cln_debug_pub.Add('Exception in CLN_UPDATE_DOC_STATUS with Error code' || l_error_code ||
                'and Errror Message' || l_error_msg,6);
            END IF;

            x_resultout := 'ERRROR';
            IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('----------- ERROR:EXITING CLN_UPDATE_DOC_STATUS ------------', 2);
            END IF;

END CLN_UPDATE_DOC_STATUS;


-- Start of comments
--        API name         : RAISE_UPDATE
--        Type             : Private
--        Pre-reqs         : None.
--        Function         : This is the public procedure which raises an event to update collaboration passing the
--                           parameters so obtained.
--        Version          : Current version         1.0
--                           Initial version         1.0
--        Notes            : This procedure is called from the root of XGM map.
-- End of comments


   PROCEDURE RAISE_UPDATE      (p_document_id                  IN         VARCHAR2,
                                p_int_cnt_num                  IN         NUMBER,
                                p_org_id                       IN         NUMBER,
                                x_return_status                OUT NOCOPY VARCHAR2,
                                x_msg_data                     OUT NOCOPY VARCHAR2) IS

   l_msg_data                    VARCHAR2(100);
   l_error_code                  NUMBER;
   l_error_msg                   VARCHAR2(2000);


   -- parameters for document creation date
   l_date                        DATE;
   l_canonical_date              VARCHAR2(100);

   -- parameters for raising event
   l_update_cln_parameter_list   wf_parameter_list_t;

   BEGIN

         l_msg_data := '000';

        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Entering RAISE_UPDATE_EVENT procedure with parameters----', 1);
                cln_debug_pub.Add('Internal Control Number     :'||p_int_cnt_num, 1);
                cln_debug_pub.Add('Invoice Number              : '||p_document_id, 1);
                cln_debug_pub.Add('Organization ID             : '||p_org_id, 1);
         END IF;

         -- Standard Start of API savepoint
         SAVEPOINT   CHECK_COLLABORATION_PUB;

         SELECT sysdate
         INTO l_date
         FROM dual;

         l_canonical_date := FND_DATE.DATE_TO_CANONICAL(l_date);

         IF (l_Debug_Level <= 1) THEN
               cln_debug_pub.Add('Workflow event- oracle.apps.cln.ch.collaboration.update called with the following parameters',1);
               cln_debug_pub.Add('DOCUMENT_NO(Invoice Number): '|| p_document_id,1);
               cln_debug_pub.Add('DOCUMENT_CREATION_DATE     : ' || l_canonical_date,1);
         END IF;

         l_update_cln_parameter_list   := wf_parameter_list_t();

         WF_EVENT.AddParameterToList('DOCUMENT_STATUS', 'SUCCESS', l_update_cln_parameter_list);
         WF_EVENT.AddParameterToList('MESSAGE_TEXT', 'CLN_3C3_INVOICE_RCVD', l_update_cln_parameter_list);
         WF_EVENT.AddParameterToList('DOCUMENT_NO',p_document_id,l_update_cln_parameter_list);
         WF_EVENT.AddParameterToList('DOCUMENT_CREATION_DATE',l_canonical_date,l_update_cln_parameter_list);--sysdate
         WF_EVENT.AddParameterToList('XMLG_INTERNAL_CONTROL_NUMBER',p_int_cnt_num,l_update_cln_parameter_list);
         WF_EVENT.AddParameterToList('ORG_ID',p_org_id,l_update_cln_parameter_list);

         IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('-------- EVENT PARAMETERS SET-----------', 1);
                cln_debug_pub.Add('Workflow event- oracle.apps.cln.ch.collaboration.update', 1);
         END IF;

         wf_event.raise(p_event_name => 'oracle.apps.cln.ch.collaboration.update',
                        p_event_key  => p_document_id ||'.'|| p_int_cnt_num,
                        p_parameters => l_update_cln_parameter_list);


         x_return_status := FND_API.G_RET_STS_SUCCESS;
         x_msg_data:= 'SUCCESS';

         IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('x_return_status: '|| x_return_status, 2);
                cln_debug_pub.Add('x_msg_data: '|| x_msg_data, 2);
                cln_debug_pub.Add('----------- EXITING RAISE_UPDATE_EVENT ------------', 2);
         END IF;

   EXCEPTION
          WHEN OTHERS THEN
            l_error_code      := SQLCODE;
            l_error_msg       := SQLERRM;
            x_return_status   := FND_API.G_RET_STS_UNEXP_ERROR ;
            l_msg_data        := l_error_code||' : '||l_error_msg;
            x_msg_data        := l_msg_data;

            IF (l_Debug_Level <= 6) THEN
                 cln_debug_pub.Add('Error: '|| l_msg_data,6);
                 cln_debug_pub.Add('x_return_status: '|| x_return_status, 2);
                 cln_debug_pub.Add('----------- ERROR:EXITING RAISE_UPDATE_EVENT ------------', 6);
            END IF;

   END RAISE_UPDATE;

-- Start of comments
--        API name         : ERROR_HANDLER
--        Type             : Private
--        Pre-reqs         : None.
--        Function         :
--        Version          : Current version        1.0
--                          Previous version         1.0
--                          Initial version         1.0
--        Notes           :
-- End of comments


  PROCEDURE ERROR_HANDLER(p_internal_control_number   IN            NUMBER,
                          p_document_id               IN            NUMBER,
                          p_org_id                    IN            NUMBER,
                          x_notification_code         OUT NOCOPY    VARCHAR2,
                          x_notification_status       OUT NOCOPY    VARCHAR2,
                          x_return_status_tp          OUT NOCOPY    VARCHAR2,
                          x_return_desc_tp            OUT NOCOPY    VARCHAR2,
                          x_return_status             IN OUT NOCOPY VARCHAR2,
                          x_msg_data                  IN OUT NOCOPY VARCHAR2)  IS

    l_cln_ch_parameters         wf_parameter_list_t;

    l_error_code                NUMBER;
    l_error_msg                 VARCHAR2(2000);
    l_msg_data                  VARCHAR2(255);
    l_event_key                 NUMBER;

     -- parameters for document creation date
     l_date                     DATE;
     l_canonical_date           VARCHAR2(100);
     --l_ntfyinvc_seq             NUMBER;

  BEGIN

        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('------ Entering ERROR_HANDLER API ------ ', 2);
        END IF;

        -- generate doc creation date
        SELECT sysdate
        INTO l_date
        FROM dual;

        l_canonical_date := FND_DATE.DATE_TO_CANONICAL(l_date);

        -- here we do not initialize x_msg_data so as to account for the actual message coming from
        -- previous API calls.
        -- Parameters received

        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('-------------  Parameters Received   ------------ ', 1);
                cln_debug_pub.Add('Return Status                        - '||x_return_status,1);
                cln_debug_pub.Add('Message Data                         - '||x_msg_data,1);
                cln_debug_pub.Add('Internal Control Number              - '||p_internal_control_number,1);
                cln_debug_pub.Add('Document ID                          - '||p_document_id,1);
                cln_debug_pub.Add('Organization ID                      - '||p_org_id,1);
                cln_debug_pub.Add('------------------------------------------------- ', 1);
                cln_debug_pub.Add('Rollback all previous changes....',1);
        END IF;

        ROLLBACK TO CHECK_COLLABORATION_PUB;


        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('--------ERROR status   -------------',1);
        END IF;

        x_notification_code             := '3C3_IN02';
        x_notification_status           := 'ERROR';
        x_return_status_tp              := '99';
        x_return_desc_tp                := x_msg_data;

        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Msg for collaboration detail         - '||x_msg_data,1);
                cln_debug_pub.Add('-------------------------------------',1);
                cln_debug_pub.Add('------Calling RAISE_UPDATE_EVENT with ERROR status------',1);
        END IF;

        l_cln_ch_parameters             := wf_parameter_list_t();
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('---- SETTING EVENT PARAMETERS FOR UPDATE COLLABORATION ----', 1);
        END IF;

        IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('DOCUMENT_CREATION_DATE:' || l_canonical_date, 1);
                  cln_debug_pub.Add('DOCUMENT_NO:' || p_document_id, 1);
                  cln_debug_pub.Add('XMLG_INTERNAL_CONTROL_NUMBER:' || p_internal_control_number, 1);
                  cln_debug_pub.Add('ORG_ID:' || p_org_id, 1);
        END IF;

        l_event_key := p_internal_control_number;

        WF_EVENT.AddParameterToList('DOCUMENT_STATUS', 'ERROR', l_cln_ch_parameters);
        WF_EVENT.AddParameterToList('MESSAGE_TEXT', x_msg_data, l_cln_ch_parameters);
        WF_EVENT.AddParameterToList('XMLG_INTERNAL_CONTROL_NUMBER',p_internal_control_number,l_cln_ch_parameters);
        WF_EVENT.AddParameterToList('DOCUMENT_CREATION_DATE',l_canonical_date,l_cln_ch_parameters);
        WF_EVENT.AddParameterToList('DOCUMENT_NO',p_document_id,l_cln_ch_parameters);
        WF_EVENT.AddParameterToList('ORG_ID',p_org_id,l_cln_ch_parameters);

        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('------------------- EVENT PARAMETERS SET -------------------', 1);
                cln_debug_pub.Add('Workflow event- oracle.apps.cln.ch.collaboration.update', 1);
        END IF;

        WF_EVENT.Raise('oracle.apps.cln.ch.collaboration.update',l_event_key, NULL, l_cln_ch_parameters, NULL);

        -- this is required for the proper processing in workflow.
        x_return_status := FND_API.G_RET_STS_ERROR;

        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('the return status is :'||x_return_status,1);
        END IF;

        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('------- Exiting ERROR_HANDLER API --------- ',2);
        END IF;

    -- Exception Handling
    EXCEPTION
         WHEN OTHERS THEN
              l_error_code              :=SQLCODE;
              l_error_msg               :=SQLERRM;

              x_return_status           :=FND_API.G_RET_STS_UNEXP_ERROR ;

              FND_MESSAGE.SET_NAME('CLN','CLN_CH_UNEXPECTED_ERROR');
              FND_MESSAGE.SET_TOKEN('ERRORCODE',l_error_code);
              FND_MESSAGE.SET_TOKEN('ERRORMSG',l_error_msg);

              x_msg_data :=FND_MESSAGE.GET;
              IF (l_Debug_Level <= 6) THEN
                cln_debug_pub.Add('Unexpected Error in ERROR_HANDLER - '||  x_msg_data,6);
              END IF;

              IF (l_Debug_Level <= 6) THEN
                cln_debug_pub.Add('------- ERROR:Exiting ERROR_HANDLER API --------- ',6);
              END IF;

  END ERROR_HANDLER;



-- Start of comments
--        API name         : XGM_CHECK_STATUS
--        Type                : Private
--        Pre-reqs        : None.
--        Function        : This procedure returns 'True' in case the status inputted is 'S' and returns 'False'
--                        in case the status inputted is other than 'S'.
--        Version                : Current version        1.0
--                          Previous version         1.0
--                          Initial version         1.0
--      Notes           :
-- End of comments

  PROCEDURE XGM_CHECK_STATUS ( p_itemtype                  IN         VARCHAR2,
                               p_itemkey                   IN         VARCHAR2,
                               p_actid                     IN         NUMBER,
                               p_funcmode                  IN         VARCHAR2,
                               x_resultout                 OUT NOCOPY VARCHAR2 ) IS

         l_sender_header_id          NUMBER;
         l_party_id                  NUMBER;
         l_party_site_id             NUMBER;
         l_internal_control_number   NUMBER;
         l_return_status_tp          VARCHAR2(10);
         l_notification_code         VARCHAR2(10);
         l_party_type                VARCHAR2(20);
         l_notification_status       VARCHAR2(100);
         l_msg_data                  VARCHAR2(255);
         l_return_desc_tp            VARCHAR2(1000);
         l_error_code                NUMBER;
         l_error_msg                 VARCHAR2(2000);

  BEGIN

        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('------ Entering XGM_CHECK_STATUS API ------ ', 2);
        END IF;

        l_msg_data :='Status returned from XGM checked for further processing';

        -- Do nothing in cancel or timeout mode
          IF (p_funcmode <> wf_engine.eng_run) THEN
               x_resultout := wf_engine.eng_null;

             IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('Not in Running Mode...........Return Here',1);
             END IF;

             RETURN;
        END IF;

        -- Should be 00 for success
        l_return_status_tp := wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER7', TRUE);
        IF (l_Debug_Level <= 1) THEN
            cln_debug_pub.Add('Return Status as obtained from workflow  : '||l_return_status_tp,1);
        END IF;

        l_sender_header_id := TO_NUMBER(wf_engine.GetItemAttrText(p_itemtype, p_itemkey,'PARAMETER9', TRUE));
        IF (l_Debug_Level <= 1) THEN
            cln_debug_pub.Add('Trading Partner Header ID                : '||l_sender_header_id, 1);
        END IF;

        IF (l_sender_header_id IS NOT NULL) THEN

             BEGIN

                SELECT PARTY_ID, PARTY_SITE_ID,PARTY_TYPE
                INTO l_party_id, l_party_site_id, l_party_type
                FROM ECX_TP_HEADERS
                WHERE TP_HEADER_ID = l_sender_header_id ;

             EXCEPTION
             WHEN OTHERS THEN
                    l_error_code      := SQLCODE;
                    l_error_msg       := SQLERRM;

                    IF (l_Debug_Level <= 6) THEN
                        cln_debug_pub.Add('Exception while querying for Party values in XGM_CHECK_STATUS: ' || l_error_code ||
                        'and Errror Message' || l_error_msg,6);
                    END IF;

                     x_resultout := 'ERROR';

            END;

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Party ID                                 : '||l_party_id,1);
                        cln_debug_pub.Add('Party Site ID                            : '||l_party_site_id,1);
                        cln_debug_pub.Add('Party Type                               : '||l_party_type,1);
                END IF;

                wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'PARTY_ID', l_party_id);
                wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'PARTY_SITE_ID', l_party_site_id);
                wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'PARTY_TYPE', l_party_type);
        END IF;

        IF (l_return_status_tp = '00') THEN

            IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Return Status is Success',1);
            END IF;

            wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'RETURN_STATUS_TP', '00');
            wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'RETURN_MSG_TP', 'SUCCESS');
            wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'DOCUMENT_STATUS', 'SUCCESS');
            x_resultout := 'COMPLETE:'||'TRUE';

        ELSIF(l_return_status_tp = '99') THEN

            IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Return Status is Error',1);
            END IF;

            l_return_desc_tp := wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER8', TRUE);

            wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'RETURN_STATUS_TP', '99');
            wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'RETURN_MSG_TP', l_return_desc_tp);
            wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'DOCUMENT_STATUS', 'ERROR');
            wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER4', '3C3_IN02');

            IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Message for the trading partner   : '||l_return_desc_tp, 1);
            END IF;

            x_resultout := 'COMPLETE:'||'FALSE';
         END IF;

         IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('------- Exiting XGM_CHECK_STATUS API --------- ',2);
         END IF;

      -- Exception Handling
      EXCEPTION
        WHEN OTHERS THEN

            FND_MESSAGE.SET_NAME('CLN','CLN_CH_ACTIVITY_ERROR');
            FND_MESSAGE.SET_TOKEN('ITMTYPE',p_itemtype);
            FND_MESSAGE.SET_TOKEN('ITMKEY',p_itemkey);
            FND_MESSAGE.SET_TOKEN('ACTIVITY','CHECK_STATUS');

            -- we are not stopping the process becoz of this error,
            -- negative confirm bod is sent out with error occured here

            l_return_status_tp      := '99';
            l_return_desc_tp        := FND_MESSAGE.GET;

            wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'RETURN_STATUS_TP', l_return_status_tp);
            wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'RETURN_MSG_TP', l_return_desc_tp);
            wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'DOCUMENT_STATUS', 'ERROR');
            wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER4', '3C3_IN02');

            x_resultout := 'ERROR';
            CLN_NP_PROCESSOR_PKG.NOTIFY_ADMINISTRATOR(l_return_desc_tp);

            IF (l_Debug_Level <= 6) THEN
                cln_debug_pub.Add('------- ERROR:Exiting XGM_CHECK_STATUS API --------- ',6);
            END IF;

END XGM_CHECK_STATUS;


-- Start of comments
--        API name         : INVOICE_IMPORT_STATUS_HANDLER
--        Type             : Private
--        Pre-reqs         : None.
--        Function         : This API checks for the status and accordingly updates the collaboration. Also, on the basis
--                           of Input parameters, notifications are sent out to Buyer for his necessary actions.
--        Version          : Current version        1.0
--                           Previous version       1.0
--                           Initial version        1.0
--         Notes           :
-- End of comments


  PROCEDURE INVOICE_IMPORT_STATUS_HANDLER (p_itemtype                     IN         VARCHAR2,
                                           p_itemkey                      IN         VARCHAR2,
                                           p_actid                        IN         NUMBER,
                                           p_funcmode                     IN         VARCHAR2,
                                           x_resultout                    OUT NOCOPY VARCHAR2 )  IS

         l_error_code                   NUMBER;
         l_event_key                    NUMBER;
         l_request_id                   NUMBER;
         l_internal_control_number      NUMBER;
         l_invoice_id                   NUMBER;
         l_reference_id                 VARCHAR2(100);
         l_parent_table                 VARCHAR2(30);
         l_parent_id                    NUMBER(15);
         l_reject_code                  VARCHAR2(30);
         l_status_code                  VARCHAR2(2);
         l_count_failed_rows            VARCHAR2(2);
         l_notification_code            VARCHAR2(10);
         l_return_status_tp             VARCHAR2(10);
         l_process_each_row_for_errors  VARCHAR2(20);
         l_doc_status                   VARCHAR2(25);
         l_phase_code                   VARCHAR2(25);
         l_concurrent_msg               VARCHAR2(250);
         l_return_desc_tp               VARCHAR2(1000);
         l_error_reject_string          VARCHAR2(2000);
         l_update_coll_msg              VARCHAR2(2000);
         l_msg_data                     VARCHAR2(2000);
         l_error_msg                    VARCHAR2(2000);
         l_tp_header_id                 NUMBER;

  BEGIN


        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('------ Entering INVOICE_IMPORT_STATUS_HANDLER API ------ ', 2);
        END IF;

        l_msg_data                      :='Parameters defaulted to proper values based on the status obtained after running the Invoice Import concurrent program.';
        l_process_each_row_for_errors   := 'FALSE';
        x_resultout                     := 'COMPLETE:'||'TRUE';

        -- Do nothing in cancel or timeout mode

        IF (p_funcmode <> wf_engine.eng_run) THEN
            x_resultout := wf_engine.eng_null;

            IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Not in Running Mode...........Return Here',1);
            END IF;

            RETURN;
        END IF;

        -- Getting the values from the workflow.
        l_internal_control_number := TO_NUMBER(wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'EVENT_KEY', TRUE));

        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Internal Control Number                      : '||l_internal_control_number, 1);
        END IF;

        l_request_id              := TO_NUMBER(wf_engine.GetItemAttrText(p_itemtype, p_itemkey,'REQIDNAME', TRUE));
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Concurrent Program Request ID                : '||l_request_id, 1);
        END IF;

        l_notification_code       := wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER4', TRUE);
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Notification Code                            : '||l_notification_code, 1);
        END IF;

        l_invoice_id              := wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER6', TRUE);
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Invoice ID                                   : '||l_invoice_id, 1);
        END IF;

        l_reference_id              := wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER10', TRUE);
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Reference ID                                   : '||l_reference_id, 1);
        END IF;

        l_tp_header_id              := wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER9', TRUE);
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Trading Partner HeaderID                                   : '||l_tp_header_id, 1);
        END IF;

        l_doc_status            := 'SUCCESS';
        l_return_status_tp      := '00';
        l_return_desc_tp        := '3C3 Consumed Succesfully';
        l_update_coll_msg       := 'CLN_CH_XML_CONSUMED_SUCCESS';
        l_notification_code     := '3C3_IN02';

        BEGIN
                SELECT status_code,completion_text,phase_code
                INTO l_status_code, l_concurrent_msg,l_phase_code
                FROM fnd_concurrent_requests
                WHERE request_id = l_request_id;

                IF (l_Debug_Level <= 1) THEN
                       cln_debug_pub.Add('Status Code returned from concurrent Request : '||l_status_code, 1);
                       cln_debug_pub.Add('Phase Code returned from concurrent Request  : '||l_phase_code, 1);
                       cln_debug_pub.Add('Message From concurrent Request              : '||l_concurrent_msg, 1);
                END IF;

        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                       cln_debug_pub.Add('ERROR : Could not find the details for the Concurrent Request'||l_request_id, 1);
                       FND_MESSAGE.SET_NAME('CLN','CLN_CH_CONCURRENT_RQST');
                       FND_MESSAGE.SET_TOKEN('REQID',l_request_id);
                       l_msg_data               := FND_MESSAGE.GET;
                       -- default the status code so as to account for it in the collaboration hstry
                       l_status_code            := 'E';
                       l_concurrent_msg         := l_msg_data;
                       x_resultout := 'ERROR:Could not find the status for the Concurrent Request';
                       RETURN;
        END;


        IF (l_status_code NOT IN ('I','C','R')) THEN

            FND_MESSAGE.SET_NAME('CLN','CLN_CH_CONCURRENT_FAILED');
            FND_MESSAGE.SET_TOKEN('REQNAME','Invoice Import');
            FND_MESSAGE.SET_TOKEN('REQID',l_request_id);
            l_update_coll_msg       := FND_MESSAGE.GET;
            l_return_status_tp      := '99';
            l_return_desc_tp        := l_update_coll_msg;
            l_notification_code     := '3C3_IN02';
            l_doc_status            := 'ERROR';
            x_resultout := 'COMPLETE:'||'Concurrent Program Request failed';

        ELSE

            IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Processing for Concurrent Program Completed Normal ', 1);
            END IF;

            BEGIN
                  SELECT REJECT_REASON_STRING
                  INTO l_error_reject_string
                  FROM CLN_AP_INVOICE_REJECTION_ARCH
                  WHERE invoice_id = l_invoice_id;
            EXCEPTION
                  WHEN NO_DATA_FOUND then
                    --NO ERRORS stored in acrival table
                    l_error_reject_string := null;
            END;

            IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add(' l_error_reject_string from CLN_AP_INVOICE_REJECTION_ARCH : ' || l_error_reject_string, 1);
            END IF;

            IF l_error_reject_string is null THEN
               --If no errors found in CLN_AP_INVOICE_REJECTION_ARCH try to scan the interface table again
               l_error_reject_string := GET_AR_REJECTIONS_STRING(l_invoice_id);
            END IF;

            IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('l_error_reject_string from interface rejections : ' || l_error_reject_string, 1);
            END IF;

            IF (l_error_reject_string is not null) THEN
                IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('Some items failed import ', 1);
                END IF;

                -- Setting values for few rows falied import.
                FND_MESSAGE.SET_NAME('CLN','CLN_CH_CONCURRENT_SUCCESS_1');
                FND_MESSAGE.SET_TOKEN('REQNAME','Invoice Import');
                FND_MESSAGE.SET_TOKEN('REQID',l_request_id);
                l_update_coll_msg       := FND_MESSAGE.GET;
                l_return_desc_tp        := l_update_coll_msg;
                l_notification_code     := '3C3_IN02';
                l_doc_status            := 'ERROR';

                x_resultout := 'COMPLETE:'||'Concurrent Program Request Success, import failed for few items';

               IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('Message for update collaboration    = '||l_update_coll_msg, 1);
                 --cln_debug_pub.Add('Event Key for update collaboration  = '||l_event_key, 1);
               END IF;

               IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('Calling -----RAISE_3C4_EVENT------API', 2);
                 cln_debug_pub.Add('Invoice ID: '||l_invoice_id, 2);
                 cln_debug_pub.Add('l_internal_control_number: '||l_internal_control_number, 2);
                 cln_debug_pub.Add('l_reference_id: '||l_reference_id, 2);
                 cln_debug_pub.Add('l_tp_header_id: '||l_tp_header_id, 2);
                 cln_debug_pub.Add('l_error_reject_string: '||l_error_reject_string, 2);
               END IF;

               RAISE_3C4_EVENT(l_invoice_id,l_internal_control_number,l_reference_id,l_tp_header_id,l_error_reject_string);

               IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('Out of  -----RAISE_3C4_EVENT------API', 2);
               END IF;

           ELSE

              IF (l_Debug_Level <= 1) THEN
                   cln_debug_pub.Add('l_error_reject_string is NULL', 1);
              END IF;

              -- Setting values for Normal Completion Of the Concurrent Program

              FND_MESSAGE.SET_NAME('CLN','CLN_CH_CONCURRENT_SUCCESS_2');
              FND_MESSAGE.SET_TOKEN('REQNAME','Invoice Import');
              FND_MESSAGE.SET_TOKEN('REQID',l_request_id);

              l_update_coll_msg               := FND_MESSAGE.GET;
              l_return_desc_tp                := l_update_coll_msg;
              l_process_each_row_for_errors   := 'FALSE';
              x_resultout := 'COMPLETE:'||'Concurrent Program Request Success';

           END IF;

       END IF;

        IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('l_return_status_tp: '||l_return_status_tp, 1);
                 cln_debug_pub.Add('RETURN_MSG_TP: '||l_return_desc_tp, 1);
                 cln_debug_pub.Add('l_doc_status: '||l_doc_status, 1);
                 cln_debug_pub.Add('PARAMETER4: '||l_notification_code, 1);
        END IF;


        wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'RETURN_STATUS_TP', l_return_status_tp);
        wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'RETURN_MSG_TP', l_return_desc_tp);
        wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'DOCUMENT_STATUS',l_doc_status );
        wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER4', l_notification_code);
        wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'COLL_UPDATE_MSG', l_return_desc_tp);

        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('------- Exiting INVOICE_IMPORT_STATUS_HANDLER API --------- ',2);
        END IF;

    EXCEPTION

        WHEN OTHERS THEN
            l_error_code      := SQLCODE;
            l_error_msg       := SQLERRM;
            l_msg_data        := l_error_code||' : '||l_error_msg;

            IF (l_Debug_Level <= 6) THEN
                cln_debug_pub.Add(l_msg_data,6);
            END IF;

            x_resultout := 'ERROR' || l_msg_data;

            IF (l_Debug_Level <= 6) THEN
                cln_debug_pub.Add('------- Exiting INVOICE_IMPORT_STATUS_HANDLER API with errors --------- ',6);
            END IF;

  END INVOICE_IMPORT_STATUS_HANDLER;


-- Start of comments
--        API name         : UPDATE_INV_HEADER_INTERFACE
--        Type                : Private
--        Pre-reqs        : None.
--        Function        : This API checks for the status and accordingly updates the collaboration. Also, on the basis
--                        of Input parameters, notifications are sent out to Buyer for his necessary actions.
--        Version                : Current version        1.0
--                          Previous version         1.0
--                          Initial version         1.0
--      Notes           :
-- End of comments


   PROCEDURE UPDATE_INV_HEADER_INTERFACE( p_invoice_id                   IN            NUMBER,
                                          p_proprietary_doc_Identifier   IN            VARCHAR2,
                                          p_inv_curr_code                IN            VARCHAR2,
                                          p_inv_amount                   IN            NUMBER,
                                          p_inv_date                     IN            VARCHAR2,
                                          p_inv_type_lookup_code         IN            VARCHAR2,
                                          x_invoice_num                  IN OUT NOCOPY VARCHAR2,
                                          x_return_status                IN OUT NOCOPY VARCHAR2,
                                          x_msg_data                     IN OUT NOCOPY VARCHAR2 )   IS

         l_msg_data                    VARCHAR2(100);
         l_error_code                  NUMBER;
         l_error_msg                   VARCHAR2(2000);
         l_position                    NUMBER;
         l_db_inv_date                 DATE;
   BEGIN

         l_msg_data  := '000';


         IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('---------------- ENTERING CLN_NTFYINVC_PKG.UPDATE_INV_HEADER_INTERFACE -----------------', 2);
         END IF;

         x_return_status := FND_API.G_RET_STS_SUCCESS;

         IF (l_debug_level <= 1) THEN
            cln_debug_pub.Add('With the following parameters:', 1);
            cln_debug_pub.Add('p_invoice_id:'   || p_invoice_id, 1);
            cln_debug_pub.Add('p_proprietary_doc_Identifier:'   || p_proprietary_doc_Identifier, 1);
            cln_debug_pub.Add('P_inv_curr_code:'    || P_inv_curr_code, 1);
            cln_debug_pub.Add('P_inv_amount:'      || P_inv_amount, 1);
            cln_debug_pub.Add('p_inv_date:'   || p_inv_date, 1);
            cln_debug_pub.Add('p_inv_type_lookup_code:'  || p_inv_type_lookup_code, 1);
         END IF;

         x_invoice_num := p_proprietary_doc_identifier;

         IF (l_debug_level <= 1) THEN
            cln_debug_pub.Add('x_invoice_num:'  || x_invoice_num, 1);
         END IF;

         CLN_RN_UTILS.convert_to_db_date(p_inv_date,l_db_inv_date);

         IF (l_debug_level <= 1) THEN
            cln_debug_pub.Add('l_db_inv_date:'  || l_db_inv_date, 1);
         END IF;

         UPDATE ap_invoices_interface
         SET INVOICE_CURRENCY_CODE      = p_inv_curr_code,
             INVOICE_AMOUNT             = P_inv_amount,
             INVOICE_DATE               = l_db_inv_date,
             INVOICE_NUM                = p_proprietary_doc_identifier,
             vendor_email_address       = '3C4',
             source                     = 'XML GATEWAY'
             --INVOICE_TYPE_LOOKUP_CODE   = p_inv_type_lookup_code
         WHERE invoice_id = p_invoice_id;

         x_msg_data :='SUCCESS';

         IF (l_debug_level <= 1) THEN
            cln_debug_pub.Add('Update ap_invoices_interface, is successful' , 1);
            cln_debug_pub.Add('x_return_status:  '|| x_return_status , 1);
            cln_debug_pub.Add('x_msg_data:  '|| x_msg_data , 1);

         END IF;

         IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('---------------- EXITING CLN_NTFYINVC_PKG.UPDATE_INV_HEADER_INTERFACE -----------------', 2);
         END IF;
   EXCEPTION
          WHEN OTHERS THEN
            l_error_code      := SQLCODE;
            l_error_msg       := SQLERRM;

            x_return_status   := FND_API.G_RET_STS_UNEXP_ERROR ;
            l_msg_data        := l_error_code||' : '||l_error_msg;
            x_msg_data        := l_msg_data;

            IF (l_Debug_Level <= 6) THEN
                cln_debug_pub.Add('x_return_status:  '|| x_return_status , 1);
                cln_debug_pub.Add(l_msg_data,6);
            END IF;

            IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('---------------- EXITING CLN_NTFYINVC_PKG.UPDATE_INV_HEADER_INTERFACE with ERROR-----------------', 2);
            END IF;
   END UPDATE_INV_HEADER_INTERFACE;


   -- Start of comments
     -- API name        : NOTIFY_INVOICE_TO_SYSADMIN
     -- Type            : Private
     -- Pre-reqs        : None.
     -- Function        : This procedure notifies 3C3 Inbound to Sysadmin.
     -- Version         : Current version       1.0
     --                   Initial version       1.0
     -- Notes           : This procedure is called from the XML map(3C4 Inbound)
     -- End of comments

     PROCEDURE NOTIFY_INVOICE_TO_SYSADMIN (p_itemtype       IN VARCHAR2,
                                            p_itemkey        IN VARCHAR2,
                                            p_actid          IN NUMBER,
                                            p_funcmode       IN VARCHAR2,
                                            x_resultout      IN OUT NOCOPY VARCHAR2) AS

      -- declare local variables
      l_notif_code         VARCHAR2(100);
      l_notif_desc         VARCHAR2(2000);
      l_status             VARCHAR2(100);
      l_app_ref_id         VARCHAR2(100);
      l_return_code        VARCHAR2(10);
      l_return_desc        VARCHAR2(2000);
      l_coll_pt            VARCHAR2(100);
      l_intrl_cntrl_num    VARCHAR2(100);
      l_errmsg             VARCHAR2(2000);
      l_error_code         VARCHAR2(100);
      l_tp_id              VARCHAR2(255);

      BEGIN


           IF (l_debug_level <= 2) THEN
                  cln_debug_pub.Add('Entering the procedure NOTIFY_INVOICE_TO_SYSADMIN', 2);
           END IF;

           --  get the workflow activity attributes.
           l_notif_code:=wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid,'NOTIF_CODE');

           IF (l_debug_level <= 1) THEN
                 cln_debug_pub.Add('Notification_code:'|| l_notif_code , 1);
           END IF;

           l_notif_desc:=wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid,'NOTIF_DESC');

           IF (l_debug_level <= 1) THEN
                 cln_debug_pub.Add('Notification_description:'|| l_notif_desc , 1);
           END IF;

           l_status:=wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid,'STATUS');

           IF (l_debug_level <= 1) THEN
                cln_debug_pub.Add('Status:'|| l_status , 1);
           END IF;

           l_tp_id:=wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid,'TPID');

           IF (l_debug_level <= 1) THEN
                cln_debug_pub.Add('Trading Partner ID:'|| l_tp_id , 1);
           END IF;

           l_app_ref_id := '';

           l_coll_pt:=wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid,'COLL_POINT');

           IF (l_debug_level <= 1) THEN
                cln_debug_pub.Add('Collaboration Point:'|| l_coll_pt, 1);
           END IF;

           l_intrl_cntrl_num:=wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid,'XMLG_INTERNAL_CONTROL_NUMBER');

           IF (l_debug_level <= 1) THEN
                cln_debug_pub.Add('Internal Control Number:'|| l_intrl_cntrl_num, 1);
           END IF;

           IF (l_debug_level <= 2) THEN
                cln_debug_pub.Add('Calling the ----CLN_NP_PROCESSOR_PKG.TAKE_ACTIONS----- API with the above parameters...',2);
           END IF;
            -- Calls the CLN Notification Processing API to perform the pre-defined actions

            BEGIN
               CLN_NP_PROCESSOR_PKG.TAKE_ACTIONS( x_ret_code            => l_return_code ,
                                                  x_ret_desc            => l_return_desc,
                                                  p_notification_code   => l_notif_code,
                                                  p_notification_desc   => l_notif_desc,
                                                  p_status              => l_status,
                                                  p_tp_id               => l_tp_id,
                                                  p_reference           => l_app_ref_id,
                                                  p_coll_point          => l_coll_pt,
                                                  p_int_con_no          => l_intrl_cntrl_num);

               IF (l_debug_level <= 2) THEN
                  cln_debug_pub.Add('Exiting the ----CLN_NP_PROCESSOR_PKG.TAKE_ACTIONS----- API with the below parameters...',2);
               END IF;

               IF (l_debug_level <= 1) THEN
                  cln_debug_pub.Add('Return Code:'|| l_return_code, 1);
                  cln_debug_pub.Add('Return Description:'|| l_return_desc, 1);
               END IF;

          EXCEPTION
            WHEN OTHERS THEN
                 l_error_code := SQLCODE;
                 l_errmsg     := SQLERRM;

                 IF (l_debug_level <= 5) THEN
                      cln_debug_pub.Add('Exception in CLN_NP_PROCESSOR_PKG.TAKE_ACTIONS:' || l_error_code || ' : '||l_errmsg,5);
                 END IF;
         END;

         x_resultout := 'SUCCESS';

      EXCEPTION
          WHEN OTHERS THEN
               l_error_code := SQLCODE;
               l_errmsg     := SQLERRM;

               IF (l_debug_level <= 5) THEN
                   cln_debug_pub.Add('Exception in NOTIFY_INVOICE_TO_SYSADMIN:' || l_error_code || ':' || l_errmsg,5);
               END IF;

               x_resultout := 'ERROR';

               IF (l_debug_level <= 2) THEN
                  cln_debug_pub.Add('Exiting the ----NOTIFY_INVOICE_TO_SYSADMIN----- API with Resultout as ...'||x_resultout,2);
               END IF;

      END NOTIFY_INVOICE_TO_SYSADMIN;

   PROCEDURE TRIGGER_REJECTION(
                                      p_invoice_id             IN              NUMBER,
                                      p_group_id               IN              NUMBER,
                                      p_request_id             IN              NUMBER,
                                      p_external_doc_ref       IN              VARCHAR2) IS
      l_internal_control_number       NUMBER;
      l_error_reject_string           VARCHAR2(2000);
      l_invoice_number                VARCHAR2(100);
      l_invoice_date                  DATE;
      l_invoice_amount                NUMBER;
      l_po_number                     VARCHAR2(100);

      CURSOR c_header_errors IS
            SELECT  PARENT_ID, REJECT_LOOKUP_CODE
              FROM  AP_INTERFACE_REJECTIONS
              WHERE PARENT_ID = p_invoice_id
                AND PARENT_TABLE = 'AP_INVOICES_INTERFACE';

      CURSOR c_line_errors IS
            SELECT  PARENT_ID, REJECT_LOOKUP_CODE
              FROM  AP_INTERFACE_REJECTIONS
              WHERE PARENT_ID in (SELECT INVOICE_LINE_ID FROM AP_INVOICE_LINES_INTERFACE WHERE INVOICE_ID = p_invoice_id)
                AND PARENT_TABLE = 'AP_INVOICE_LINES_INTERFACE';

   BEGIN

        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('------ Entering CLN_NTFYINVC_PKG.TRIGGER_REJECTION API ------ ', 2);
        END IF;

        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('p_invoice_id : ' || p_invoice_id, 1);
                cln_debug_pub.Add('p_group_id : ' || p_group_id, 1);
                cln_debug_pub.Add('p_request_id : ' || p_request_id, 1);
                cln_debug_pub.Add('p_external_doc_ref : ' || p_external_doc_ref, 1);
        END IF;

        l_error_reject_string := GET_AR_REJECTIONS_STRING(p_invoice_id);

        IF (l_Debug_Level <= 1) THEN
                  cln_debug_pub.Add('l_error_reject_string : '||  l_error_reject_string, 1);
        END IF;

        l_internal_control_number :=  p_group_id;

        SELECT invoice_num, invoice_date, invoice_amount, po_number
          INTO l_invoice_number, l_invoice_date, l_invoice_amount, l_po_number
          FROM ap_invoices_interface
         WHERE invoice_id = p_invoice_id;

        IF (l_Debug_Level <= 1) THEN
                  cln_debug_pub.Add('Before inserting data into CLN_AP_INVOICE_REJECTION_ARCH', 1);
        END IF;

        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('l_invoice_number : ' || l_invoice_number, 1);
                cln_debug_pub.Add('l_invoice_date : ' || to_char(l_invoice_date,'yyyy-mm-dd hh24:mi:ss'), 1);
                cln_debug_pub.Add('l_invoice_amount : ' || l_invoice_amount, 1);
                cln_debug_pub.Add('l_po_number : ' || l_po_number, 1);
        END IF;

        INSERT INTO CLN_AP_INVOICE_REJECTION_ARCH(
                invoice_id,
                xmlg_internal_control_number,
                invoice_number,
                reference_id,
                po_number,
                invoice_amount,
                invoice_date,
                reject_reason_string,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                last_update_login)
        VALUES(
                p_invoice_id,
                p_group_id,
                l_invoice_number,
                p_external_doc_ref,
                l_po_number,
                l_invoice_amount,
                l_invoice_date,
                l_error_reject_string,
                sysdate,
                fnd_global.user_id,
                sysdate,
                fnd_global.user_id,
                fnd_global.login_id
               );

        IF (l_Debug_Level <= 1) THEN
                  cln_debug_pub.Add('Before inserting data', 1);
        END IF;

        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('------ Exiting CLN_NTFYINVC_PKG.TRIGGER_REJECTION API ------ ', 2);
        END IF;
   END TRIGGER_REJECTION;


   PROCEDURE GET_REJECTED_INVOICE_DETAILS(
                                      p_invoice_id             IN              NUMBER,
                                      x_invoice_num            IN OUT NOCOPY   VARCHAR2,
                                      x_po_num                 IN OUT NOCOPY   VARCHAR2,
                                      x_invoice_amt            IN OUT NOCOPY   NUMBER,
                                      x_invoice_date           IN OUT NOCOPY   DATE) IS
   BEGIN
        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('------ Entering CLN_NTFYINVC_PKG.GET_REJECTED_INVOICE_DETAILS API ------ ', 2);
        END IF;

        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('p_invoice_id : ' || p_invoice_id, 1);
        END IF;


        BEGIN
           SELECT invoice_num, po_number, invoice_amount, invoice_date
             INTO x_invoice_num, x_po_num, x_invoice_amt, x_invoice_date
             FROM ap_invoices_interface
            WHERE invoice_id = p_invoice_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                IF (l_debug_level <= 1) THEN
                       cln_debug_pub.Add('rows not available in ap_invoices_interface. Querying CLN_AP_INVOICE_REJECTION_ARCH',1);
                END IF;
                --The following query should not error out... If it errors out, Its an exception condition
                SELECT invoice_number, po_number, invoice_amount, invoice_date
                INTO  x_invoice_num, x_po_num, x_invoice_amt, x_invoice_date
                FROM   CLN_AP_INVOICE_REJECTION_ARCH
                WHERE  invoice_id = p_invoice_id;
        END;


        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('x_invoice_num : ' || x_invoice_num, 1);
                cln_debug_pub.Add('x_po_num : ' || x_po_num, 1);
                cln_debug_pub.Add('x_invoice_amt : ' || x_invoice_amt, 1);
                cln_debug_pub.Add('x_invoice_date : ' || to_char(x_invoice_date,'yyyy-mm-dd hh24:mi:ss'), 1);
        END IF;

        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('------ Exiting CLN_NTFYINVC_PKG.GET_REJECTED_INVOICE_DETAILS API ------ ', 2);
        END IF;

   END GET_REJECTED_INVOICE_DETAILS;

   BEGIN

   l_debug_level      := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));

END CLN_NTFYINVC_PKG;

/
