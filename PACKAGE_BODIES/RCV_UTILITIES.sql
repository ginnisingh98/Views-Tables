--------------------------------------------------------
--  DDL for Package Body RCV_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_UTILITIES" AS
/* $Header: RCVUTILB.pls 120.1.12010000.5 2014/02/26 20:53:12 vthevark noship $*/

   -- Read the profile option that enables/disables the debug log
   g_asn_debug      VARCHAR2(1)  := asn_debug.is_debug_on; -- Bug 9152790

   /* This API is called by AP in their Supplier Merge program  */

   PROCEDURE Merge_Vendor
          ( p_commit             IN   VARCHAR2 default FND_API.G_FALSE,
            x_return_status      OUT  NOCOPY VARCHAR2,
            x_msg_count          OUT  NOCOPY NUMBER,
            x_msg_data           OUT  NOCOPY VARCHAR2,
            p_vendor_id          IN   NUMBER,
            p_vendor_site_id     IN   NUMBER,
            p_dup_vendor_id      IN   NUMBER,
            p_dup_vendor_site_id IN   NUMBER
          ) IS

          l_last_updated_by    NUMBER;

   BEGIN

       IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('p_vendor_id:         ' || p_vendor_id);
            asn_debug.put_line('p_vendor_site_id     ' || p_vendor_site_id);
            asn_debug.put_line('p_dup_vendor_id      ' || p_dup_vendor_id);
            asn_debug.put_line('p_dup_vendor_site_id ' || p_dup_vendor_site_id);
       END IF;

       --  Initialize API return status to success
       x_return_status   := FND_API.G_RET_STS_SUCCESS;
       l_last_updated_by := FND_GLOBAL.user_id;

       /* Per discussion with AP:
          - value of message count should be 0 and data should be null
  	    FND_MSG_PUB.cound_and_get should not be called to fetch the values of count and data.
          - No RCV specific messages will be returned from this api
       */

       x_msg_count := 0;
       x_msg_data := null;

       -- Updating rcv_shipment_headers
       UPDATE rcv_shipment_headers
       SET    vendor_id        = p_vendor_id,
              vendor_site_id   = p_vendor_site_id,
              last_updated_by  = l_last_updated_by,
              last_update_date = sysdate
       WHERE  receipt_source_code = 'VENDOR'
       AND    vendor_id  = p_dup_vendor_id
       AND    vendor_site_id is not null
       AND    vendor_site_id = p_dup_vendor_site_id ;

       UPDATE rcv_shipment_headers
       SET    vendor_id        = p_vendor_id,
              last_updated_by  = l_last_updated_by,
              last_update_date = sysdate
       WHERE  receipt_source_code = 'VENDOR'
       AND    vendor_id = p_dup_vendor_id
       AND    vendor_site_id is null;

       IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Updating rcv_shipment_headers: count =' || sql%rowcount);
       END IF;

       -- Updating rcv_transactions
       UPDATE rcv_transactions
       SET    vendor_id        = p_vendor_id,
              vendor_site_id   = p_vendor_site_id,
              last_updated_by  = l_last_updated_by,
              last_update_date = sysdate
       WHERE  source_document_code = 'PO'
       AND    vendor_id = p_dup_vendor_id
       AND    vendor_site_id = p_dup_vendor_site_id ;

       IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('After updating rcv_transactions: count =' || sql%rowcount);
       END IF;

       -- Updating rcv_headers_interface
       UPDATE rcv_headers_interface
       SET    vendor_id        = p_vendor_id,
              vendor_site_id   = p_vendor_site_id,
              last_updated_by  = l_last_updated_by,
              last_update_date = sysdate
       WHERE  receipt_source_code = 'VENDOR'
       AND    vendor_id = p_dup_vendor_id
       AND    vendor_site_id is not null
       AND    vendor_site_id = p_dup_vendor_site_id ;

       UPDATE rcv_headers_interface
       SET    vendor_id        = p_vendor_id,
              last_updated_by  = l_last_updated_by,
              last_update_date = sysdate
       WHERE  receipt_source_code = 'VENDOR'
       AND    vendor_id = p_dup_vendor_id
       AND    vendor_site_id is null;

       IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('After updating rcv_headers_interface: count =' || sql%rowcount);
       END IF;

       -- Updating rcv_transactions_interface
       UPDATE rcv_transactions_interface
       SET    vendor_id        = p_vendor_id,
              vendor_site_id   = p_vendor_site_id,
              last_updated_by  = l_last_updated_by,
              last_update_date = sysdate
       WHERE  source_document_code = 'PO'
       AND    vendor_id       = p_dup_vendor_id
       AND    vendor_site_id is not null
       AND    vendor_site_id  = p_dup_vendor_site_id ;

       UPDATE rcv_transactions_interface
       SET    vendor_id        = p_vendor_id,
              last_updated_by  = l_last_updated_by,
              last_update_date = sysdate
       WHERE  source_document_code = 'PO'
       AND    vendor_id       = p_dup_vendor_id
       AND    vendor_site_id is null;

       IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('After updating rcv_transactions_interface: count =' || sql%rowcount);
       END IF;

       IF (g_asn_debug = 'Y') THEN
           asn_debug.put_line('x_return_status: ' ||  x_return_status);
           asn_debug.put_line('x_msg_count: '     ||  x_msg_count);
           asn_debug.put_line('x_msg_data: '      ||  x_msg_data);
       END IF;

       IF FND_API.To_Boolean( p_commit ) THEN
	  COMMIT WORK;
       END IF;

   EXCEPTION
       WHEN OTHERS THEN
       ROLLBACK;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

       IF (g_asn_debug = 'Y') THEN
           asn_debug.put_line('x_return_status: ' ||  x_return_status);
           asn_debug.put_line('x_msg_count: '     ||  x_msg_count);
           asn_debug.put_line('x_msg_data: '      ||  x_msg_data);
       END IF;

   END Merge_Vendor;


   -- Bug 7579045: This API is used by AP for AP-LCM integration.
   PROCEDURE Get_RtLcmInfo
          ( p_rcv_transaction_id             IN  NUMBER,
            x_lcm_account_id                 OUT NOCOPY NUMBER,
            x_tax_variance_account_id        OUT NOCOPY NUMBER,
            x_def_charges_account_id         OUT NOCOPY NUMBER,
            x_exchange_variance_account_id   OUT NOCOPY NUMBER,
            x_inv_variance_account_id        OUT NOCOPY NUMBER
          ) IS

          x_progress    VARCHAR2(3) := '000';
	  x_pll_id      NUMBER;
          x_org_id      NUMBER;
          x_lcm_flag    VARCHAR2(1);

   BEGIN
          IF (g_asn_debug = 'Y') THEN
              asn_debug.put_line('In Get_RtLcmInfo: p_rcv_transaction_id' ||  p_rcv_transaction_id);
          END IF;

	  SELECT rt.po_line_location_id,
                 rt.organization_id,
	         nvl(pll.lcm_flag,'N')
	  INTO   x_pll_id,
                 x_org_id,
	         x_lcm_flag
	  FROM   rcv_transactions      rt,
	         po_line_locations_all pll
	  WHERE  rt.po_line_location_id is not null
	  AND    rt.po_line_location_id = pll.line_location_id
	  AND    transaction_id = p_rcv_transaction_id;

          IF (g_asn_debug = 'Y') THEN
              asn_debug.put_line('x_progress' ||  x_progress);
              asn_debug.put_line('x_pll_id' ||  x_pll_id);
              asn_debug.put_line('x_org_id' ||  x_org_id);
              asn_debug.put_line('x_lcm_flag' ||  x_lcm_flag);
          END IF;

	  x_progress := '010';

	  IF (x_lcm_flag = 'Y') THEN
	      SELECT lcm_account_id,
	             tax_variance_account_id,
	             def_charges_account_id,
	             exchange_variance_account_id,
	             inv_variance_account_id
              INTO   x_lcm_account_id,
	             x_tax_variance_account_id,
	             x_def_charges_account_id,
	             x_exchange_variance_account_id,
	             x_inv_variance_account_id
              FROM   rcv_parameters
              WHERE  organization_id = x_org_id;
          END IF;

          IF (g_asn_debug = 'Y') THEN
              asn_debug.put_line('x_lcm_account_id' ||  x_lcm_account_id);
              asn_debug.put_line('x_tax_variance_account_id' ||  x_tax_variance_account_id);
              asn_debug.put_line('x_def_charges_account_id' ||  x_def_charges_account_id);
              asn_debug.put_line('x_exchange_variance_account_id' ||  x_exchange_variance_account_id);
              asn_debug.put_line('x_inv_variance_account_id' ||  x_inv_variance_account_id);
          END IF;

   EXCEPTION
       WHEN OTHERS THEN
          x_lcm_account_id := null;
          x_tax_variance_account_id := null;
          x_def_charges_account_id := null;
          x_exchange_variance_account_id := null;
          x_inv_variance_account_id := null;

          IF (g_asn_debug = 'Y') THEN
              asn_debug.put_line('Error in Get_RtLcmInfo: ' ||  x_progress);
          END IF;
   END Get_RtLcmInfo;

   PROCEDURE get_lock_handle (p_lock_name IN VARCHAR2, p_lock_handle IN OUT NOCOPY VARCHAR2) IS
   PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
     dbms_lock.allocate_unique( lockname    => p_lock_name
                               ,lockhandle  => p_lock_handle);
     IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line ('l_lock_name   = ' || p_lock_name);
         asn_debug.put_line ('l_lock_handle = ' || p_lock_handle);
     END IF;
   END get_lock_handle;

END  RCV_UTILITIES;

/
