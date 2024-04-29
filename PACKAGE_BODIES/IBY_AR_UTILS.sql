--------------------------------------------------------
--  DDL for Package Body IBY_AR_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_AR_UTILS" AS
/* $Header: ibyarutb.pls 120.7.12010000.10 2010/01/19 09:43:01 lmallick ship $*/


 --
 -- NOTE
 --   For performance reasons this function returns a concatenation
 --   of DocumentReceivable and DocumentReceivableCount
 --
 FUNCTION get_document_receivable
 (
 p_tangibleid      IN iby_trxn_summaries_all.tangibleid%TYPE,
 p_trxntypeid      IN iby_trxn_summaries_all.trxntypeid%TYPE,
 p_card_data_level IN iby_trxn_core.card_data_level%TYPE,
 p_instrument_type IN iby_trxn_summaries_all.instrtype%TYPE
 )
 RETURN XMLType
 IS

 BEGIN

  -- Stub out the code
  RETURN NULL;

 END get_document_receivable;


 -- Overloaded form of the earlier API. This is transaction
 -- extension driven. The earlier function has been obsoleted.
 --
 -- NOTE
 --   For performance reasons this function returns a concatenation
 --   of DocumentReceivable and DocumentReceivableCount
 --
 -- Bug # 8301765
 -- Added input parameter p_source_view : Name of the invoking view name.
 FUNCTION get_document_receivable
 (
 p_extension_id    IN iby_trxn_summaries_all.initiator_extension_id%TYPE,
 p_trxntypeid      IN iby_trxn_summaries_all.trxntypeid%TYPE,
 p_card_data_level IN iby_trxn_core.card_data_level%TYPE,
 p_instrument_type IN iby_trxn_summaries_all.instrtype%TYPE,
 p_source_view     IN VARCHAR2
 )
 RETURN XMLType
 IS
   l_doc_rec  XMLType;

   CURSOR l_doc_rec_csr
   (c_extension_id iby_trxn_summaries_all.initiator_extension_id%TYPE) IS
     SELECT
       XMLConcat(XMLAgg(document_headers),
                 XMLElement("DocumentReceivableCount",count(trxn_extension_id)))
     FROM iby_xml_fndcpt_doc_headers_v
     WHERE trxn_extension_id = c_extension_id;
 BEGIN

   -- only supported for capture trxn's
   IF (NOT p_trxntypeid IN (8,9,100)) THEN
     RETURN null;
   END IF;

   -- Bug # 8301765 : Performance issue
   -- IBY_AR_UTILS.get_document_receivable() will be invoked from two views (ibyxmlv.odf)
   -- IBY_XML_FNDCPT_ORDER_1_0_V and IBY_XML_FNDCPT_ORDER_PN_1_0_V
   -- If either Pcard level is 0 or invoking view is IBY_XML_FNDCPT_ORDER_1_0_V then return NULL
   IF((p_source_view = 'IBY_XML_FNDCPT_ORDER_1_0_V') AND ( p_instrument_type <> 'BANKACCOUNT' )
               AND   (NVL(p_card_data_level,'0') = '0')) THEN
   RETURN NULL;
   END IF;

   IF (l_doc_rec_csr%ISOPEN) THEN
     CLOSE l_doc_rec_csr;
   END IF;

   OPEN l_doc_rec_csr(p_extension_id);
   FETCH l_doc_rec_csr INTO l_doc_rec;
   IF (l_doc_rec_csr%NOTFOUND) THEN
     l_doc_rec := NULL;
   END IF;
   CLOSE l_doc_rec_csr;
   RETURN l_doc_rec;

 END get_document_receivable;


 -- Overloaded form of the earlier API.This restricts the Invoice details
 -- based on the instrument type. The earlier function has been kept
 --  for backward compatibility.
 -- NOTE
 --   For performance reasons this function returns a concatenation
 --   of DocumentReceivable and DocumentReceivableCount
 --
 -- Bug # 8713025
 -- Added input parameter p_process_profile : process profile code of the transaction.

 FUNCTION get_document_receivable
 (
 p_extension_id    IN iby_trxn_summaries_all.initiator_extension_id%TYPE,
 p_trxntypeid      IN iby_trxn_summaries_all.trxntypeid%TYPE,
 p_card_data_level IN iby_trxn_core.card_data_level%TYPE,
 p_instrument_type IN iby_trxn_summaries_all.instrtype%TYPE,
 p_process_profile IN iby_trxn_summaries_all.process_profile_code%TYPE,
 p_source_view     IN VARCHAR2
 )
 RETURN XMLType
 IS
   l_doc_rec  XMLType;
   l_exclude_flag VARCHAR2(1);

   CURSOR l_doc_rec_csr
   (c_extension_id iby_trxn_summaries_all.initiator_extension_id%TYPE) IS
     SELECT
       XMLConcat(XMLAgg(document_headers),
                 XMLElement("DocumentReceivableCount",count(trxn_extension_id)))
     FROM iby_xml_fndcpt_doc_headers_v
     WHERE trxn_extension_id = c_extension_id;
 BEGIN

   -- only supported for capture trxn's
   IF (NOT p_trxntypeid IN (8,9,100)) THEN
     RETURN null;
   END IF;

   IF ( (p_source_view = 'IBY_XML_FNDCPT_ORDER_1_0_V') AND NVL(p_card_data_level,'0') = '0') THEN

     IF ( upper(p_instrument_type) = 'CREDITCARD')
     THEN
       SELECT  sp.exclude_trxn_det_extraction
         INTO  l_exclude_flag
         FROM  IBY_FNDCPT_USER_CC_PF_B up
               ,IBY_FNDCPT_SYS_CC_PF_B  sp
        WHERE  up.user_cc_profile_code = p_process_profile
          AND  up.sys_cc_profile_code = sp.sys_cc_profile_code;

     ELSIF ( upper(p_instrument_type) = 'BANKACCOUNT')
     THEN
       SELECT  sp.exclude_trxn_det_extraction
         INTO  l_exclude_flag
         FROM  IBY_FNDCPT_USER_EFT_PF_B up
               ,IBY_FNDCPT_SYS_EFT_PF_B  sp
        WHERE  up.user_eft_profile_code = p_process_profile
          AND  up.sys_eft_profile_code = sp.sys_eft_profile_code;

     ELSE
       SELECT  sp.exclude_trxn_det_extraction
         INTO  l_exclude_flag
         FROM  IBY_FNDCPT_USER_DC_PF_B up
               ,IBY_FNDCPT_SYS_DC_PF_B  sp
        WHERE  up.user_dc_profile_code = p_process_profile
          AND  up.sys_dc_profile_code = sp.sys_dc_profile_code;

      END IF;

     IF ( NVL(l_exclude_flag,'N') = 'Y') THEN
           RETURN null;
     END IF;

   END IF;

   IF (l_doc_rec_csr%ISOPEN) THEN
     CLOSE l_doc_rec_csr;
   END IF;

   OPEN l_doc_rec_csr(p_extension_id);
   FETCH l_doc_rec_csr INTO l_doc_rec;
   IF (l_doc_rec_csr%NOTFOUND) THEN
     l_doc_rec := NULL;
   END IF;
   CLOSE l_doc_rec_csr;
   RETURN l_doc_rec;

 END get_document_receivable;

 PROCEDURE call_get_payment_info(
               p_payment_server_order_num IN
                              ar_cash_receipts.payment_server_order_num%TYPE,
               x_customer_trx_id OUT NOCOPY
                              ar_receivable_applications.customer_trx_id%TYPE,
               x_return_status   OUT NOCOPY VARCHAR2,
               x_msg_count       OUT NOCOPY NUMBER,
               x_msg_data        OUT NOCOPY VARCHAR2
               ) IS

 l_receipt_header            ar_cash_receipts%ROWTYPE;
 l_app_type  ar_receivable_applications.status%TYPE :='APP';
 l_app_tbl_type AR_PUBLIC_UTILS.application_tbl_type;
 l_app_rec_type ar_receivable_applications%ROWTYPE;

 BEGIN
     x_customer_trx_id := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF p_payment_server_order_num IS NOT NULL THEN

         AR_PUBLIC_UTILS.get_payment_info(
             p_payment_server_order_num,
             l_app_type,
             l_receipt_header,
             l_app_tbl_type,
             x_return_status,
             x_msg_count,
             x_msg_data);

         IF l_app_tbl_type.COUNT = 1 THEN
            x_customer_trx_id := l_app_tbl_type(1).applied_customer_trx_id;
         END IF;

     END IF;

 EXCEPTION
    WHEN others THEN
      x_msg_count := 1;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'IBY_AR_UTILS.CALL_GET_PAYMENT_INFO ERROR: ' || x_msg_data;
 END;

 FUNCTION call_get_payment_info
 (p_payment_server_order_num IN
   ar_cash_receipts.payment_server_order_num%TYPE)
 RETURN ar_receivable_applications.customer_trx_id%TYPE
 IS
   l_trx_id ar_receivable_applications.customer_trx_id%TYPE;
   l_ret_status VARCHAR2(2000);
   l_msg_count NUMBER;
   l_msg_data VARCHAR2(5000);
 BEGIN

   call_get_payment_info
     (p_payment_server_order_num,l_trx_id,l_ret_status,l_msg_count,l_msg_data);
   RETURN l_trx_id;

 END call_get_payment_info;

 FUNCTION get_order_freight_amount(p_customer_trx_id IN
   ar_invoice_header_v.customer_trx_id%TYPE)
 RETURN NUMBER
 IS
   l_freight_amount NUMBER := 0;

   CURSOR c_header_freight
   (ci_cust_trx_id ar_invoice_header_v.customer_trx_id%TYPE)
   IS
     SELECT extended_amount
     FROM ar_invoice_lines_v
     WHERE (link_to_cust_trx_line_id IS NULL)
       AND (line_type = 'FREIGHT')
       AND (customer_trx_id = ci_cust_trx_id);

   CURSOR c_freight_total
   (ci_cust_trx_id ar_invoice_header_v.customer_trx_id%TYPE)
   IS
     SELECT SUM(extended_amount)
     FROM ar_invoice_lines_v
     WHERE
       (line_type = 'FREIGHT')
       AND (customer_trx_id = ci_cust_trx_id);

 BEGIN

   IF (c_header_freight%ISOPEN) THEN
     CLOSE c_header_freight;
   END IF;
   IF (c_freight_total%ISOPEN) THEN
     CLOSE c_freight_total;
   END IF;

   OPEN c_header_freight(p_customer_trx_id);
   FETCH c_header_freight INTO l_freight_amount;
   IF (c_header_freight%NOTFOUND) THEN
     l_freight_amount:=0;
   END IF;
   CLOSE c_header_freight;

   IF (l_freight_amount>0) THEN
     RETURN l_freight_amount;
   END IF;
   --
   -- if no header-level amount exists, then take
   -- the sum of all line-level freight charges
   --
   OPEN c_freight_total(p_customer_trx_id);
   FETCH c_freight_total INTO l_freight_amount;
   IF (c_freight_total%NOTFOUND) THEN
     l_freight_amount := 0;
   END IF;
   CLOSE c_freight_total;

   RETURN NVL(l_freight_amount,0);
 END get_order_freight_amount;

 FUNCTION get_order_tax_amount
  (p_customer_trx_id IN ar_invoice_header_v.customer_trx_id%TYPE,
   p_tax_type        IN VARCHAR2)
 RETURN NUMBER
 IS
   l_tax_total NUMBER := 0;

   CURSOR c_line_items
   (ci_cust_trx_id ar_invoice_header_v.customer_trx_id%TYPE)
   IS
     SELECT customer_trx_line_id
     FROM ar_invoice_lines_v
     WHERE
       ( line_type = 'LINE')
       AND (customer_trx_id = ci_cust_trx_id);

 BEGIN

   FOR order_line IN c_line_items(p_customer_trx_id) LOOP
     l_tax_total := get_line_tax_amount(p_customer_trx_id,
                      order_line.customer_trx_line_id,
                      p_tax_type);
   END LOOP;

   RETURN l_tax_total;
 END get_order_tax_amount;

 FUNCTION get_order_amount
  (p_customer_trx_id IN ar_invoice_header_v.customer_trx_id%TYPE)
 RETURN NUMBER
 IS
   l_order_total NUMBER := 0;

   CURSOR c_line_items
   (ci_cust_trx_id ar_invoice_header_v.customer_trx_id%TYPE)
   IS
     SELECT extended_amount
     FROM ar_invoice_lines_v
     WHERE
       ( line_type = 'LINE')
       AND (customer_trx_id = ci_cust_trx_id);
 BEGIN

   FOR order_line IN c_line_items(p_customer_trx_id) LOOP
     l_order_total := l_order_total + NVL(order_line.extended_amount,0);
   END LOOP;

   RETURN l_order_total;
 END get_order_amount;

 FUNCTION get_line_tax_amount
  (p_customer_trx_id IN ar_invoice_header_v.customer_trx_id%TYPE,
   p_customer_trx_line_id IN ar_invoice_lines_v.customer_trx_line_id%TYPE,
   p_tax_type             IN VARCHAR2)
 RETURN NUMBER
 IS

   l_sales_tax_total NUMBER := 0;
   l_vat_tax_total NUMBER := 0;

   CURSOR c_tax_items
   (ci_cust_trx_id ar_invoice_lines_v.customer_trx_id%TYPE,
    ci_cust_trx_line_id ar_invoice_lines_v.link_to_cust_trx_line_id%TYPE)
   IS
     SELECT extended_amount, location_rate_id, location_segment_id
     FROM ar_invoice_lines_v
     WHERE
       (line_type='TAX')
       AND (customer_trx_id = ci_cust_trx_id)
       AND (link_to_cust_trx_line_id = ci_cust_trx_line_id);

 BEGIN

   FOR tax_line IN c_tax_items(p_customer_trx_id,p_customer_trx_line_id) LOOP
     IF (NOT tax_line.location_rate_id IS NULL)
	     OR (NOT tax_line.location_segment_id IS NULL)
     THEN
       l_sales_tax_total := l_sales_tax_total + NVL(tax_line.extended_amount,0);
     ELSE
       l_vat_tax_total := l_vat_tax_total + NVL(tax_line.extended_amount,0);
     END IF;
   END LOOP;

   IF (p_tax_type = G_TAX_TYPE_SALES) THEN
     RETURN l_sales_tax_total;
   ELSIF (p_tax_type = G_TAX_TYPE_VAT) THEN
     RETURN l_vat_tax_total;
   ELSE
     RETURN 0;
   END IF;

 END get_line_tax_amount;

 FUNCTION get_line_tax_rate
  (p_customer_trx_id IN ar_invoice_header_v.customer_trx_id%TYPE,
   p_customer_trx_line_id IN ar_invoice_lines_v.customer_trx_line_id%TYPE,
   p_tax_type             IN VARCHAR2)
 RETURN NUMBER
 IS
   l_sales_rate_total NUMBER := 0;
   l_vat_rate_total NUMBER := 0;

   l_sales_count NUMBER := 0;
   l_vat_count NUMBER := 0;

   CURSOR c_tax_items
   (ci_cust_trx_id ar_invoice_lines_v.customer_trx_id%TYPE,
    ci_cust_trx_line_id ar_invoice_lines_v.link_to_cust_trx_line_id%TYPE)
   IS
     SELECT location_rate_id, location_segment_id, tax_rate
     FROM ar_invoice_lines_v
     WHERE
       (line_type='TAX')
       AND (customer_trx_id = ci_cust_trx_id)
       AND (link_to_cust_trx_line_id = ci_cust_trx_line_id);

 BEGIN

   FOR tax_line IN c_tax_items(p_customer_trx_id,p_customer_trx_line_id) LOOP
     IF (NOT tax_line.location_rate_id IS NULL)
	     OR (NOT tax_line.location_segment_id IS NULL)
	 THEN
       l_sales_rate_total := l_sales_rate_total + NVL(tax_line.tax_rate,0);
       l_sales_count := l_sales_count + 1;
     ELSE
       l_vat_rate_total := l_vat_rate_total + NVL(tax_line.tax_rate,0);
       l_vat_count := l_vat_count + 1;
     END IF;
   END LOOP;

   IF (p_tax_type = G_TAX_TYPE_SALES) THEN
     RETURN (l_sales_rate_total/GREATEST(l_sales_count,1));
   ELSIF (p_tax_type = G_TAX_TYPE_VAT) THEN
     RETURN (l_vat_rate_total/GREATEST(l_vat_count,1));
   ELSE
     RETURN 0;
   END IF;

 END get_line_tax_rate;

  -- Return: The Authorization Flag for the given Transaction Extension Id
 PROCEDURE get_authorization_status
 (p_trxn_extension_id  IN iby_fndcpt_tx_operations.trxn_extension_id%TYPE,
  x_auth_flag   OUT NOCOPY VARCHAR2)
 IS
   l_dbg_mod VARCHAR2(100) := 'IBY_AR_UTILS' || '.get_authorization_status';
 BEGIN
 SELECT decode(summ.status,   NULL,   'N',   'Y') AUTHORIZED_FLAG
         into x_auth_flag
   FROM iby_trxn_summaries_all summ
      , iby_fndcpt_tx_operations op
   WHERE summ.transactionid = op.transactionid
      AND reqtype = 'ORAPMTREQ'
      AND status IN(0,  100)
      AND op.trxn_extension_id = p_trxn_extension_id
      AND op.transactionid = (SELECT MIN(transactionid)
                                   FROM iby_fndcpt_tx_operations
                                   WHERE trxn_extension_id = op.trxn_extension_id)
      AND ((trxntypeid IN(2,  3))
	    OR
	   (trxntypeid = 20
            AND summ.trxnmid = (SELECT MAX(trxnmid)
                                FROM iby_trxn_summaries_all summ1,
                                     iby_fndcpt_tx_operations op1
                                WHERE summ1.transactionid = op1.transactionid
                                AND summ1.reqtype = 'ORAPMTREQ'
                                AND summ1.status IN(0, 100)
                                AND summ1.trxntypeid IN(2,  3,   20)
                                AND op1.trxn_extension_id = op.trxn_extension_id
				)
	    )
	   );
      EXCEPTION
        WHEN others THEN
	  iby_debug_pub.add('Exception thrown!. Error: ' || SQLERRM,
                      IBY_DEBUG_PUB.G_LEVEL_EXCEPTION,l_dbg_mod);

          x_auth_flag:='N';
 END;

END IBY_AR_UTILS;

/
