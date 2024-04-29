--------------------------------------------------------
--  DDL for Package Body AP_VENDOR_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_VENDOR_PARTY_MERGE_PKG" AS
/* $Header: apvdmrgb.pls 120.12.12010000.10 2011/06/13 06:01:47 kpasikan ship $ */

  --Global constants for logging
  G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AP_VENDOR_PARTY_MERGE_PKG';
  G_MSG_UERROR        CONSTANT NUMBER := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
  G_MSG_ERROR         CONSTANT NUMBER := FND_MSG_PUB.G_MSG_LVL_ERROR;
  G_MSG_SUCCESS       CONSTANT NUMBER := FND_MSG_PUB.G_MSG_LVL_SUCCESS;
  G_MSG_HIGH          CONSTANT NUMBER := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
  G_MSG_MEDIUM        CONSTANT NUMBER := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
  G_MSG_LOW           CONSTANT NUMBER := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;
  G_LINES_PER_FETCH   CONSTANT NUMBER := 1000;

  G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_LEVEL_UNEXPECTED      CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR           CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION       CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT           CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE       CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT       CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME           CONSTANT VARCHAR2(100)
                          := 'AP.PLSQL.AP_VENDOR_PARTY_MERGE_PKG';

-- Bug 5641382. Added the parameter v_dup_vendor_id to the procedure
PROCEDURE Other_Products_VendorMerge(v_dup_vendor_id IN NUMBER DEFAULT NULL,
                                     v_dup_vendor_site_id IN NUMBER DEFAULT NULL)
                                     /* Added extra parameter for bug 9501188*/
IS

--
l_return_status             VARCHAR2(50);
l_msg_data                  VARCHAR2(1000);
l_msg_count                 NUMBER;
l_msg_index_out             NUMBER;

/* Changes introduced for bug 9501188 - Start */
   l_xla_errbuf        VARCHAR2 (2000);
   l_xla_retcode       VARCHAR2 (100);
   l_xla_event_ids     xla_third_party_merge_pub.t_event_ids;
   l_xla_request_id    NUMBER;
   l_xla_ledger_id     NUMBER;
   l_source_id_int_1   NUMBER;

/* Changes introduced for bug 9501188 - End */

CURSOR Invoice_Cursor IS
SELECT 	dv.vendor_id                 C_VENDOR_ID,
       	dv.vendor_site_id            C_VENDOR_SITE_ID,
       	dv.duplicate_vendor_id       C_DUP_VENDOR_ID,
       	dv.duplicate_vendor_site_id  C_DUP_VENDOR_SITE_ID,
       	dv.entry_id                  C_ENTRY_ID,
        dv.org_id                    C_ORG_ID,
	a.vendor_name                C_VENDOR_NAME,
	b.vendor_name                C_DUP_VENDOR_NAME,
        a.party_id                   C_PARTY_ID,
        b.party_id                   C_DUP_PARTY_ID,
	c.vendor_site_code           C_VENDOR_SITE_CODE,
	d.vendor_site_code           C_DUP_VENDOR_SITE_CODE,
        c.party_site_id              C_PARTY_SITE_ID,
        d.party_site_id              C_DUP_PARTY_SITE_ID,
	dv.keep_site_flag            C_KEEP_SITE_FLAG,
	dv.paid_invoices_flag        C_PAID_INVOICES_FLAG,
	a.segment1                   C_NEW_VENDOR_NUMBER,
        b.segment1                   C_OLD_VENDOR_NUMBER
FROM   	ap_duplicate_vendors_all dv,
	ap_suppliers a,
	ap_suppliers b,
       	ap_supplier_sites_all c,
	ap_supplier_sites_all d
WHERE  	dv.process_flag='S'
AND    	a.vendor_id=dv.vendor_id
AND    	c.vendor_site_id=nvl(dv.vendor_site_id,duplicate_vendor_site_id)
AND    	b.vendor_id=dv.duplicate_vendor_id
AND  	d.vendor_site_id=dv.duplicate_vendor_site_id
AND     d.org_id = dv.org_id
AND     dv.process<>'P'
/* Added for Bug 5641382 */
AND     dv.duplicate_vendor_id = NVL(v_dup_vendor_id, dv.duplicate_vendor_id)
AND     dv.duplicate_vendor_site_id = NVL(v_dup_vendor_site_id, dv.duplicate_vendor_site_id); /* Added for bug 9501188 */

CURSOR PO_Cursor IS
SELECT 	dv.vendor_id                 C_VENDOR_ID,
       	dv.vendor_site_id            C_VENDOR_SITE_ID,
       	dv.duplicate_vendor_id       C_DUP_VENDOR_ID,
       	dv.duplicate_vendor_site_id  C_DUP_VENDOR_SITE_ID,
       	dv.entry_id                  C_ENTRY_ID,
        dv.org_id                    C_ORG_ID,
	a.vendor_name                C_VENDOR_NAME,
	b.vendor_name                C_DUP_VENDOR_NAME,
        a.party_id                   C_PARTY_ID,
        b.party_id                   C_DUP_PARTY_ID,
	c.vendor_site_code           C_VENDOR_SITE_CODE,
	d.vendor_site_code           C_DUP_VENDOR_SITE_CODE,
        c.party_site_id              C_PARTY_SITE_ID,
        d.party_site_id              C_DUP_PARTY_SITE_ID,
	dv.keep_site_flag            C_KEEP_SITE_FLAG,
	dv.paid_invoices_flag        C_PAID_INVOICES_FLAG,
	a.segment1                   C_NEW_VENDOR_NUMBER,
        b.segment1                   C_OLD_VENDOR_NUMBER
FROM   	ap_duplicate_vendors_all dv,
	ap_suppliers a,
	ap_suppliers b,
       	ap_supplier_sites_all c,
	ap_supplier_sites_all d
WHERE  	dv.process_flag in ('S','D')
AND    	a.vendor_id=dv.vendor_id
AND    	c.vendor_site_id=nvl(dv.vendor_site_id,duplicate_vendor_site_id)
AND    	b.vendor_id=dv.duplicate_vendor_id
AND  	d.vendor_site_id=dv.duplicate_vendor_site_id
AND     d.org_id  = dv.org_id
AND     dv.process<>'I'
/* Added for Bug 5641382 */
AND     dv.duplicate_vendor_id = NVL(v_dup_vendor_id, dv.duplicate_vendor_id)
AND     dv.duplicate_vendor_site_id = NVL(v_dup_vendor_site_id, dv.duplicate_vendor_site_id); /* Added for bug 9501188 */


l_Invoice_Row Invoice_Cursor%ROWTYPE;
l_PO_Row      PO_Cursor%ROWTYPE;

l_count_xla_gt   number;

/* Bug 9551257 Start */
l_active_site_count     number;
p_last_site_flag        varchar(3);
/* Bug 9551257 End */

BEGIN
  --
  --
  -- Process Invoice Related Impact Product Calls.

   /* Changes for bug 9501188 Start */

   l_xla_errbuf        := null;
   l_xla_retcode       := null;
   l_xla_request_id    := 0;
   l_xla_ledger_id     := 0;
   l_source_id_int_1   := 0;

   /* Changes for bug 9501188 End */

   /* Bug 9551257 Start */
   l_active_site_count := 0;
   p_last_site_flag := 'N';
   /* Bug 9551257 End */

  OPEN Invoice_Cursor;
  LOOP
    FETCH Invoice_Cursor INTO l_Invoice_Row;
    EXIT WHEN Invoice_Cursor%NOTFOUND;

    IF l_invoice_row.C_KEEP_SITE_FLAG = 'Y'   AND
       l_invoice_row.C_VENDOR_SITE_ID IS NULL THEN

        SELECT vendor_site_id
        INTO   l_invoice_row.C_VENDOR_SITE_ID
        FROM   ap_supplier_sites_all
        WHERE  vendor_id = l_invoice_row.C_VENDOR_ID
        AND    vendor_site_code = l_invoice_row.C_VENDOR_SITE_CODE
        AND    org_id = l_invoice_row.C_ORG_ID; --Bug#7307532

    END IF;

    /*Changes for bug 9551257 Start */

    FND_FILE.Put_Line(FND_FILE.Log,'Calling IBY API - Start');

    SELECT count(apps.vendor_site_id)
      INTO l_active_site_count
      FROM ap_suppliers aps, ap_supplier_sites_all apps
     WHERE aps.vendor_id = l_invoice_row.C_DUP_VENDOR_ID
       AND aps.vendor_id = apps.vendor_id
       AND apps.vendor_site_id <> l_invoice_row.C_DUP_VENDOR_SITE_ID
       AND apps.pay_site_flag = 'Y'
       AND apps.inactive_date is not null;

    IF l_active_site_count > 0 THEN
       p_last_site_flag := 'N';
    ELSE
       p_last_site_flag := 'Y';
    END IF;

    FND_FILE.Put_Line(FND_FILE.Log,'In IBY merge call, p_last_site_flag:'||p_last_site_flag);

    IBY_SUPP_BANK_MERGE_PUB.BANK_ACCOUNTS_MERGE(
       P_from_vendor_id => l_invoice_row.C_DUP_VENDOR_ID,
       P_to_vendor_id => l_invoice_row.C_VENDOR_ID,
       P_from_party_id => l_invoice_row.C_DUP_PARTY_ID,
       P_to_party_id => l_invoice_row.C_PARTY_ID,
       P_from_vendor_site_id => l_invoice_row.C_DUP_VENDOR_SITE_ID,
       P_to_vendor_site_id => l_invoice_row.C_VENDOR_SITE_ID,
       P_from_party_site_id => l_invoice_row.C_DUP_PARTY_SITE_ID,
       P_to_partysite_id => l_invoice_row.C_PARTY_SITE_ID,
       P_from_org_id => l_invoice_row.C_ORG_ID,
       P_to_org_id => l_invoice_row.C_ORG_ID,
       P_from_org_type => 'OPERATING_UNIT',
       P_to_org_type => 'OPERATING_UNIT',
       p_keep_site_flag => l_invoice_row.C_KEEP_SITE_FLAG,
       p_last_site_flag => p_last_site_flag,
       X_return_status => l_return_status,
       X_msg_count => l_msg_count,
       X_msg_data => l_msg_data
    );

    FND_FILE.Put_Line(FND_FILE.Log,'In IBY merge call, l_return_status:'||l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       --
       --
       IF l_msg_count > 0 THEN
          --
          --
          FOR i in 1..FND_MSG_PUB.Count_Msg LOOP
            FND_MSG_PUB.Get( p_msg_index     => i,
	                     p_encoded       => 'F',
			     p_data          => l_msg_data,
	                     p_msg_index_out => l_msg_index_out
                           );
            FND_FILE.Put_Line(FND_FILE.Log,l_msg_data);
          End LOOP;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    /*Changes for bug 9551257 End */

/* Changes introduced for bug 9501188 - Start */

    FND_FILE.Put_Line(FND_FILE.Log,'Calling XLA API - Start');

	  BEGIN
	    SELECT set_of_books_id into l_xla_ledger_id
	    FROM ap_system_parameters_all
	    WHERE org_id = l_invoice_row.C_ORG_ID
	    and rownum = 1;

     FND_FILE.Put_Line(FND_FILE.Log,'Fetching the ledge_id: '||l_xla_ledger_id||' and org_id:'||l_invoice_row.C_ORG_ID);

	  EXCEPTION
	  WHEN OTHERS THEN
	    FND_FILE.Put_Line(FND_FILE.Log,' Error fetching set of book id');
	    RAISE FND_API.G_EXC_ERROR;
	  END;

        BEGIN
           select count(1) into l_count_xla_gt from xla_events_gt;

        EXCEPTION
        WHEN OTHERS THEN
           l_count_xla_gt := 0;
        END;

       FND_FILE.Put_Line(FND_FILE.Log,'third_party_merge l_count_xla_gt:'||l_count_xla_gt);
       FND_FILE.Put_Line(FND_FILE.Log,'third_party_merge l_invoice_row.C_DUP_VENDOR_ID:'||l_invoice_row.C_DUP_VENDOR_ID||':');
       FND_FILE.Put_Line(FND_FILE.Log,'third_party_merge l_invoice_row.C_DUP_VENDOR_SITE_ID:'||l_invoice_row.C_DUP_VENDOR_SITE_ID||':');
       FND_FILE.Put_Line(FND_FILE.Log,'third_party_merge l_invoice_row.C_VENDOR_ID:'||l_invoice_row.C_VENDOR_ID);
       FND_FILE.Put_Line(FND_FILE.Log,'third_party_merge l_invoice_row.C_VENDOR_SITE_ID:'||l_invoice_row.C_VENDOR_SITE_ID);

       FND_FILE.Put_Line(FND_FILE.Log,'Before call to xla_third_party_merge_pub.third_party_merge...');

	   If (nvl(l_count_xla_gt,0) <> 0) then
             xla_third_party_merge_pub.third_party_merge (x_errbuf => l_xla_errbuf,
      						    x_retcode => l_xla_retcode,
      						    x_event_ids => l_xla_event_ids,
      						    x_request_id => l_xla_request_id,
      						    p_application_id => 200,
      						    p_ledger_id => l_xla_ledger_id,
      						    p_third_party_merge_date => sysdate,
      						    p_third_party_type => 'S',
      						    p_original_third_party_id => l_invoice_row.C_DUP_VENDOR_ID,
      						    p_original_site_id => l_invoice_row.C_DUP_VENDOR_SITE_ID,
      						    p_new_third_party_id => l_invoice_row.C_VENDOR_ID,
      						    p_new_site_id => l_invoice_row.C_VENDOR_SITE_ID,
      						    p_type_of_third_party_merge => 'PARTIAL',
      						    p_mapping_flag => 'N',
      						    p_execution_mode => 'SYNC',
      						    p_accounting_mode => 'F',
      						    p_transfer_to_gl_flag => 'Y',
      						    p_post_in_gl_flag => 'N'
      						   );

           FND_FILE.Put_Line(FND_FILE.Log, 'Call after procedure xla_third_party_merge_pub.third_party_merge:'||l_xla_retcode);
	   IF l_xla_retcode  <> 'S' then

    	    FND_FILE.Put_Line(FND_FILE.Log, 'Error on procedure call xla_third_party_merge_pub.third_party_merge call:'||l_xla_retcode);
    	    IF l_xla_errbuf IS NOT NULL THEN
    	      FND_FILE.PUT_LINE(FND_FILE.Log,'Error buffer l_xla_errbuf:'||l_xla_errbuf);
    	    END IF;
    	    RAISE FND_API.G_EXC_ERROR;
	   END IF;

	   FOR i IN l_xla_event_ids.FIRST .. l_xla_event_ids.LAST
	   LOOP

              IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||' AP_VENDOR_PARTY_MERGE_PKG.other_products_vendormerge: ',
                  'Merged event_id: '||l_xla_event_ids (i) );
              END IF;

	   END LOOP;

	   DELETE FROM xla_events_gt;

	   FND_FILE.Put_Line(FND_FILE.Log, 'Deleting the record of xla_events_gt');

        FND_FILE.Put_Line(FND_FILE.Log,'Calling XLA API - End');

      End if;
/* Changes introduced for bug 9501188 - End */


    FND_FILE.Put_Line(FND_FILE.Log,'Calling WSH API');

    -- Call WSH API
    WSH_VENDOR_PARTY_MERGE_PKG.Vendor_Party_Merge(
		   p_from_vendor_id => l_invoice_row.C_Dup_Vendor_Id,
		   p_to_vendor_id   => l_invoice_row.C_Vendor_Id,
		   p_from_party_id  => l_invoice_row.C_Dup_Party_Id,
		   p_to_party_id    => l_invoice_row.C_Party_Id,
		   p_from_vendor_site_id => l_invoice_row.C_Dup_Vendor_Site_Id,
		   p_to_vendor_site_id   => l_invoice_row.C_Vendor_Site_Id,
		   p_from_party_site_id  => l_invoice_row.C_Dup_Party_Site_Id,
		   p_to_partysite_id     => l_invoice_row.C_Party_Site_Id,
		   p_calling_mode        => 'INVOICE',
		   x_return_status       => l_return_status,
		   x_msg_count		 => l_msg_count,
		   x_msg_data		 => l_msg_data);


    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       --
       --
       IF l_msg_count > 0 THEN
          --
          --
          FOR i in 1..FND_MSG_PUB.Count_Msg LOOP
            FND_MSG_PUB.Get( p_msg_index     => i,
	                     p_encoded       => 'F',
			     p_data          => l_msg_data,
	                     p_msg_index_out => l_msg_index_out
                           );
            FND_FILE.Put_Line(FND_FILE.Log,l_msg_data);
          End LOOP;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    FND_FILE.Put_Line(FND_FILE.Log,'Calling Fixed Assets API');

    -- Fixed Assets
    FA_VendorMerge_GRP.Merge_Vendor(
	              p_api_version        => 1.0
	            , p_init_msg_list      => FND_API.G_FALSE
	            , p_commit             => FND_API.G_FALSE
	            , p_validation_level   => FND_API.G_VALID_LEVEL_FULL
	            , x_return_status      => l_return_status
	            , x_msg_count          => l_msg_count
	            , x_msg_data           => l_msg_data
	            , p_vendor_id          => l_invoice_row.C_Vendor_Id
	            , p_dup_vendor_id      => l_invoice_row.C_Dup_Vendor_Id
	            , p_vendor_site_id     => l_invoice_row.C_Vendor_Site_Id
	            , p_dup_vendor_site_id => l_invoice_row.C_Dup_Vendor_Site_Id
	            , p_party_id           => l_invoice_row.C_Party_Id
	            , p_dup_party_id       => l_invoice_row.C_Dup_Party_Id
	            , p_party_site_id      => l_invoice_row.C_Party_Site_Id
	            , p_dup_party_site_id  => l_invoice_row.C_Dup_Party_Site_Id
	            , p_segment1           => l_invoice_row.C_New_Vendor_Number
	            , p_dup_segment1       => l_invoice_row.C_Old_Vendor_Number
	            , p_vendor_name        => l_invoice_row.C_Vendor_Name);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       --
       --
       IF l_msg_count > 0 THEN
          --
          --
          FOR i in 1..FND_MSG_PUB.Count_Msg LOOP
            FND_MSG_PUB.Get( p_msg_index     => i,
	                     p_encoded       => 'F',
			     p_data          => l_msg_data,
	                     p_msg_index_out => l_msg_index_out
                           );
            FND_FILE.Put_Line(FND_FILE.Log,l_msg_data);
          End LOOP;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    FND_FILE.Put_Line(FND_FILE.Log,'Calling Trade Management API');

    -- Trade Management
    OZF_VENDORMERGE_GRP.Merge_Vendor(
	              p_api_version        => 1.0
	            , p_init_msg_list      => FND_API.G_FALSE
	            , p_commit             => FND_API.G_FALSE
	            , p_validation_level   => FND_API.G_VALID_LEVEL_FULL
	            , p_return_status      => l_return_status
	            , p_msg_count          => l_msg_count
	            , p_msg_data           => l_msg_data
	            , p_vendor_id          => l_invoice_row.C_Vendor_Id
	            , p_dup_vendor_id      => l_invoice_row.C_Dup_Vendor_Id
	            , p_vendor_site_id     => l_invoice_row.C_Vendor_Site_Id
	            , p_dup_vendor_site_id => l_invoice_row.C_Dup_Vendor_Site_Id
	            , p_party_id           => l_invoice_row.C_Party_Id
	            , p_dup_party_id       => l_invoice_row.C_Dup_Party_Id
	            , p_party_site_id      => l_invoice_row.C_Party_Site_Id
	            , p_dup_party_site_id  => l_invoice_row.C_Dup_Party_Site_Id);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       --
       --
       IF l_msg_count > 0 THEN
          --
          --
          FOR i in 1..FND_MSG_PUB.Count_Msg LOOP
            FND_MSG_PUB.Get( p_msg_index     => i,
	                     p_encoded       => 'F',
			     p_data          => l_msg_data,
	                     p_msg_index_out => l_msg_index_out
                           );
            FND_FILE.Put_Line(FND_FILE.Log,l_msg_data);
          End LOOP;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    FND_FILE.Put_Line(FND_FILE.Log,'Calling CMRO API');

    -- Complex Maintenance Repair and Overhaul
    AHL_VENDORMERGE_GRP.Merge_Vendor(
	              p_api_version        => 1.0
	            , p_init_msg_list      => FND_API.G_FALSE
	            , p_commit             => FND_API.G_FALSE
	            , p_validation_level   => FND_API.G_VALID_LEVEL_FULL
	            , x_return_status      => l_return_status
	            , x_msg_count          => l_msg_count
	            , x_msg_data           => l_msg_data
	            , p_vendor_id          => l_invoice_row.C_Vendor_Id
	            , p_dup_vendor_id      => l_invoice_row.C_Dup_Vendor_Id
	            , p_vendor_site_id     => l_invoice_row.C_Vendor_Site_Id
	            , p_dup_vendor_site_id => l_invoice_row.C_Dup_Vendor_Site_Id
	            , p_party_id           => l_invoice_row.C_Party_Id
	            , p_dup_party_id       => l_invoice_row.C_Dup_Party_Id
	            , p_party_site_id      => l_invoice_row.C_Party_Site_Id
	            , p_dup_party_site_id  => l_invoice_row.C_Dup_Party_Site_Id);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       --
       --
       IF l_msg_count > 0 THEN
          --
          --
          FOR i in 1..FND_MSG_PUB.Count_Msg LOOP
            FND_MSG_PUB.Get( p_msg_index     => i,
	                     p_encoded       => 'F',
			     p_data          => l_msg_data,
	                     p_msg_index_out => l_msg_index_out
                           );
            FND_FILE.Put_Line(FND_FILE.Log,l_msg_data);
          End LOOP;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    FND_FILE.Put_Line(FND_FILE.Log,'Calling Netting API');

    -- Netting
    FUN_VENDORMERGE_GRP.Merge_Vendor(
                      p_api_version        => 1.0
                    , p_init_msg_list      => FND_API.G_FALSE
                    , p_commit             => FND_API.G_FALSE
                    , p_validation_level   => FND_API.G_VALID_LEVEL_FULL
                    , p_return_status      => l_return_status
                    , p_msg_count          => l_msg_count
                    , p_msg_data           => l_msg_data
                    , p_vendor_id          => l_invoice_row.C_Vendor_Id
                    , p_dup_vendor_id      => l_invoice_row.C_Dup_Vendor_Id
                    , p_vendor_site_id     => l_invoice_row.C_Vendor_Site_Id
                    , p_dup_vendor_site_id => l_invoice_row.C_Dup_Vendor_Site_Id);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       --
       --
       IF l_msg_count > 0 THEN
          --
          --
          FOR i in 1..FND_MSG_PUB.Count_Msg LOOP
            FND_MSG_PUB.Get( p_msg_index     => i,
                             p_encoded       => 'F',
                             p_data          => l_msg_data,
                             p_msg_index_out => l_msg_index_out
                           );
            FND_FILE.Put_Line(FND_FILE.Log,l_msg_data);
          End LOOP;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    FND_FILE.Put_Line(FND_FILE.Log,'Calling iRecruitment API');

    -- iRecruitment
    IRC_VENDORMERGE_GRP.Merge_Vendor(
                      p_api_version        => 1.0
                    , p_init_msg_list      => FND_API.G_FALSE
                    , p_commit             => FND_API.G_FALSE
                    , p_validation_level   => FND_API.G_VALID_LEVEL_FULL
                    , p_return_status      => l_return_status
                    , p_msg_count          => l_msg_count
                    , p_msg_data           => l_msg_data
                    , p_vendor_id          => l_invoice_row.C_Vendor_Id
                    , p_dup_vendor_id      => l_invoice_row.C_Dup_Vendor_Id
                    , p_vendor_site_id     => l_invoice_row.C_Vendor_Site_Id
                    , p_dup_vendor_site_id => l_invoice_row.C_Dup_Vendor_Site_Id
                    , p_party_id           => l_invoice_row.C_Party_Id
                    , p_dup_party_id       => l_invoice_row.C_Dup_Party_Id
                    , p_party_site_id      => l_invoice_row.C_Party_Site_Id
                    , p_dup_party_site_id  => l_invoice_row.C_Dup_Party_Site_Id);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       --
       --
       IF l_msg_count > 0 THEN
          --
          --
          FOR i in 1..FND_MSG_PUB.Count_Msg LOOP
            FND_MSG_PUB.Get( p_msg_index     => i,
                             p_encoded       => 'F',
                             p_data          => l_msg_data,
                             p_msg_index_out => l_msg_index_out
                           );
            FND_FILE.Put_Line(FND_FILE.Log,l_msg_data);
          End LOOP;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Bug 6018743. Added the call to Oracle Loans API.
	FND_FILE.Put_Line(FND_FILE.Log,'Calling OKL API');

    --Oracle Loans
    OKL_VENDORMERGE_GRP.Merge_Vendor(
	              p_api_version        => 1.0
	            , p_init_msg_list      => FND_API.G_FALSE
	            , p_commit             => FND_API.G_FALSE
	            , p_validation_level   => FND_API.G_VALID_LEVEL_FULL
	            , p_return_status      => l_return_status
	            , p_msg_count          => l_msg_count
	            , p_msg_data           => l_msg_data
	            , p_vendor_id          => l_invoice_row.C_Vendor_Id
	            , p_dup_vendor_id      => l_invoice_row.C_Dup_Vendor_Id
	            , p_vendor_site_id     => l_invoice_row.C_Vendor_Site_Id
	            , p_dup_vendor_site_id => l_invoice_row.C_Dup_Vendor_Site_Id
	            , p_party_id           => l_invoice_row.C_Party_Id
	            , p_dup_party_id       => l_invoice_row.C_Dup_Party_Id
	            , p_party_site_id      => l_invoice_row.C_Party_Site_Id
	            , p_dup_party_site_id  => l_invoice_row.C_Dup_Party_Site_Id);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       --
       --
       IF l_msg_count > 0 THEN
          --
          --
          FOR i in 1..FND_MSG_PUB.Count_Msg LOOP
            FND_MSG_PUB.Get( p_msg_index     => i,
                             p_encoded       => 'F',
                             p_data          => l_msg_data,
                             p_msg_index_out => l_msg_index_out
                           );
            FND_FILE.Put_Line(FND_FILE.Log,l_msg_data);
          End LOOP;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- Bug 6018743 ends.

    /* Bug 9677677 Start - Localization */

     FND_FILE.Put_Line(FND_FILE.Log,'Calling JL API');

     JL_VENDORMERGE_GRP.Merge_Vendor(
                      p_api_version        => 1.0
                    , p_init_msg_list      => FND_API.G_FALSE
                    , p_commit             => FND_API.G_FALSE
                    , p_validation_level   => FND_API.G_VALID_LEVEL_FULL
                    , p_return_status      => l_return_status
                    , p_msg_count          => l_msg_count
                    , p_msg_data           => l_msg_data
                    , p_vendor_id          => l_invoice_row.C_Vendor_Id
                    , p_dup_vendor_id      => l_invoice_row.C_Dup_Vendor_Id
                    , p_vendor_site_id     => l_invoice_row.C_Vendor_Site_Id
                    , p_dup_vendor_site_id => l_invoice_row.C_Dup_Vendor_Site_Id
                    , p_party_id           => l_invoice_row.C_Party_Id
                    , p_dup_party_id       => l_invoice_row.C_Dup_Party_Id
                    , p_party_site_id      => l_invoice_row.C_Party_Site_Id
                    , p_dup_party_site_id  => l_invoice_row.C_Dup_Party_Site_Id
                  );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       --
       --
       IF l_msg_count > 0 THEN
          --
          --
          FOR i in 1..FND_MSG_PUB.Count_Msg LOOP
            FND_MSG_PUB.Get( p_msg_index     => i,
                             p_encoded       => 'F',
                             p_data          => l_msg_data,
                             p_msg_index_out => l_msg_index_out
                           );
            FND_FILE.Put_Line(FND_FILE.Log,l_msg_data);
          End LOOP;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    /* Bug 9677677 End - Localization */

    FND_FILE.Put_Line(FND_FILE.Log,'Invoices: Complete');

  END LOOP;
  CLOSE Invoice_Cursor;
  --
  --

  --
  --
  -- Process PO Related Impact Product Calls.
  OPEN PO_Cursor;
  LOOP
    FETCH PO_Cursor INTO l_PO_Row;
    EXIT WHEN PO_Cursor%NOTFOUND;

    IF l_po_row.C_KEEP_SITE_FLAG = 'Y'   AND
       l_po_row.C_VENDOR_SITE_ID IS NULL THEN

        SELECT vendor_site_id
        INTO   l_po_row.C_VENDOR_SITE_ID
        FROM   ap_supplier_sites_all
        WHERE  vendor_id = l_po_row.C_VENDOR_ID
        AND    vendor_site_code = l_po_row.C_VENDOR_SITE_CODE
        AND    org_id = l_po_row.C_ORG_ID;   --Bug#7307532

    END IF;

    FND_FILE.Put_Line(FND_FILE.Log,'PO: Calling WSH API');

    -- Call WSH API
    WSH_VENDOR_PARTY_MERGE_PKG.Vendor_Party_Merge(
                   P_From_Vendor_Id => l_PO_Row.C_Dup_Vendor_ID,
                   P_To_Vendor_Id   => l_PO_Row.C_Vendor_ID,
                   P_From_Party_Id  => l_PO_Row.C_Dup_Party_ID,
                   P_To_Party_Id    => l_PO_Row.C_Party_ID,
                   P_From_Vendor_Site_Id    => l_PO_Row.C_Dup_Vendor_Site_ID,
                   P_To_Vendor_Site_Id      => l_Po_Row.C_Vendor_Site_Id,
                   P_From_Party_Site_Id     => l_PO_Row.C_Dup_Party_Site_ID,
                   P_To_Partysite_id   => l_PO_Row.C_Party_Site_ID,
                   P_calling_mode      => 'PO',
                   x_return_status     => l_return_status,
                   x_msg_count         => l_msg_count,
                   x_msg_data          => l_msg_data);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       --
       --
       IF l_msg_count > 0 THEN
          --
          --
          FOR i in 1..FND_MSG_PUB.Count_Msg LOOP
            FND_MSG_PUB.Get( p_msg_index     => i,
                                      p_encoded       => 'F',
                                      p_data          => l_msg_data,
                                      p_msg_index_out => l_msg_index_out
                           );
            FND_FILE.Put_Line(FND_FILE.Log,l_msg_data);
          End LOOP;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

     FND_FILE.Put_Line(FND_FILE.Log,'PO: Calling MRP API');

     -- MRP
     MRP_VendorMerge_GRP.Merge_Vendor(
	              p_api_version        => 1.0
	            , p_init_msg_list      => FND_API.G_FALSE
	            , p_commit             => FND_API.G_FALSE
	            , p_validation_level   => FND_API.G_VALID_LEVEL_FULL
	            , x_return_status      => l_return_status
	            , x_msg_count          => l_msg_count
	            , x_msg_data           => l_msg_data
	            , p_vendor_id          => l_po_row.C_Vendor_Id
	            , p_vendor_site_id     => l_po_row.C_Vendor_Site_Id
	            , p_dup_vendor_id      => l_po_row.C_Dup_Vendor_Id
	            , p_dup_vendor_site_id => l_po_row.C_Dup_Vendor_Site_Id);

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        --
        --
        IF l_msg_count > 0 THEN
           --
           --
           FOR i in 1..FND_MSG_PUB.Count_Msg LOOP
               FND_MSG_PUB.Get( p_msg_index     => i,
                                p_encoded       => 'F',
                                p_data          => l_msg_data,
                                p_msg_index_out => l_msg_index_out
                              );
               FND_FILE.Put_Line(FND_FILE.Log,l_msg_data);
           END LOOP;
         END IF;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      FND_FILE.Put_Line(FND_FILE.Log,'PO: Calling Sourcing API');

      -- Sourcing
      PON_VENDORMERGE_GRP.Merge_Vendor(
		              p_api_version        => 1.0
		            , p_vendor_id          => l_po_row.C_Vendor_Id
		            , p_dup_vendor_id      => l_po_row.C_Dup_Vendor_Id
		            , p_vendor_site_id     => l_po_row.C_Vendor_Site_Id
		            , p_dup_vendor_site_id => l_po_row.C_Dup_Vendor_Site_Id
		            , p_party_id           => l_po_row.C_Party_Id
		            , p_dup_party_id       => l_po_row.C_Dup_Party_Id
		            , p_party_site_id      => l_po_row.C_Party_Site_Id
		            , p_dup_party_site_id  => l_po_row.C_Dup_Party_Site_Id
		            , p_init_msg_list      => FND_API.G_FALSE
		            , p_commit             => FND_API.G_FALSE
		            , p_validation_level   => FND_API.G_VALID_LEVEL_FULL
		            , p_return_status      => l_return_status
		            , p_msg_count          => l_msg_count
		            , p_msg_data           => l_msg_data);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      --
      --
        IF l_msg_count > 0 THEN
        --
        --
          FOR i in 1..FND_MSG_PUB.Count_Msg LOOP
              FND_MSG_PUB.Get( p_msg_index     => i,
                               p_encoded       => 'F',
                               p_data          => l_msg_data,
                               p_msg_index_out => l_msg_index_out
                             );
              FND_FILE.Put_Line(FND_FILE.Log,l_msg_data);
          END LOOP;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      FND_FILE.Put_Line(FND_FILE.Log,'PO: Calling iSP API');

      -- iSupplier Portal
      POS_VENDORMERGE_GRP.merge_vendor (
                         p_api_version => 1.0,
                         p_init_msg_list => fnd_api.g_false,
                         p_commit => fnd_api.g_false,
                         p_validation_level => fnd_api.g_valid_level_full,
                         p_return_status => l_return_status,
                         p_msg_count => l_msg_count,
                         p_msg_data => l_msg_data,
                         p_vendor_id          => l_po_row.C_Vendor_Id,
                         p_dup_vendor_id      => l_po_row.C_Dup_Vendor_Id,
                         p_vendor_site_id     => l_po_row.C_Vendor_Site_Id,
                         p_dup_vendor_site_id => l_po_row.C_Dup_Vendor_Site_Id,
                         p_party_id           => l_po_row.C_Party_Id,
                         p_dup_party_id       => l_po_row.C_Dup_Party_Id,
                         p_party_site_id      => l_po_row.C_Party_Site_Id,
                         p_dup_party_site_id  => l_po_row.C_Dup_Party_Site_Id);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      --
      --
        IF l_msg_count > 0 THEN
        --
        --
          FOR i in 1..FND_MSG_PUB.Count_Msg LOOP
              FND_MSG_PUB.Get( p_msg_index     => i,
                               p_encoded       => 'F',
                               p_data          => l_msg_data,
                               p_msg_index_out => l_msg_index_out
                             );
              FND_FILE.Put_Line(FND_FILE.Log,l_msg_data);
          END LOOP;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      FND_FILE.Put_Line(FND_FILE.Log,'PO: Calling Procurement API');

      -- Procurement
      PO_VENDORMERGE_GRP.merge_vendor (
                         p_api_version		=> 1.0,
                         p_init_msg_list	=> fnd_api.g_false,
                         p_commit		=> fnd_api.g_false,
                         p_validation_level	=> fnd_api.g_valid_level_full,
                         x_return_status	=> l_return_status,
                         x_msg_count		=> l_msg_count,
                         x_msg_data		=> l_msg_data,
                         p_vendor_id          	=> l_po_row.C_Vendor_Id,
                         p_dup_vendor_id      	=> l_po_row.C_Dup_Vendor_Id,
                         p_vendor_site_id     	=> l_po_row.C_Vendor_Site_Id,
                         p_dup_vendor_site_id 	=> l_po_row.C_Dup_Vendor_Site_Id,
                         p_party_id           	=> l_po_row.C_Party_Id,
                         p_dup_party_id       	=> l_po_row.C_Dup_Party_Id,
                         p_party_site_id      	=> l_po_row.C_Party_Site_Id,
                         p_dup_party_site_id  	=> l_po_row.C_Dup_Party_Site_Id);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      --
      --
        IF l_msg_count > 0 THEN
        --
        --
          FOR i in 1..FND_MSG_PUB.Count_Msg LOOP
              FND_MSG_PUB.Get( p_msg_index     => i,
                               p_encoded       => 'F',
                               p_data          => l_msg_data,
                               p_msg_index_out => l_msg_index_out
                             );
              FND_FILE.Put_Line(FND_FILE.Log,l_msg_data);
          END LOOP;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      FND_FILE.Put_Line(FND_FILE.Log,'PO: Complete');
      -- Bug 7592393 Start. Call to update receiving tables
      FND_FILE.Put_Line(FND_FILE.Log,'PO: Calling Receiving API');

      -- Receiving
      RCV_UTILITIES.Merge_Vendor ( p_commit	    => fnd_api.g_false,
                         x_return_status        => l_return_status,
                         x_msg_count            => l_msg_count,
                         x_msg_data             => l_msg_data,
                         p_vendor_id            => l_po_row.C_Vendor_Id,
                         p_vendor_site_id     	=> l_po_row.C_Vendor_Site_Id,
                         p_dup_vendor_id      	=> l_po_row.C_Dup_Vendor_Id,
                         p_dup_vendor_site_id 	=> l_po_row.C_Dup_Vendor_Site_Id);


      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF l_msg_count > 0 THEN
          FOR i in 1..FND_MSG_PUB.Count_Msg LOOP
              FND_MSG_PUB.Get( p_msg_index     => i,
                               p_encoded       => 'F',
                               p_data          => l_msg_data,
                               p_msg_index_out => l_msg_index_out
                             );
              FND_FILE.Put_Line(FND_FILE.Log,l_msg_data);
          END LOOP;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      -- Bug 7592393 End.


  END LOOP;
  CLOSE PO_Cursor;
  --

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      l_msg_count,
                        p_data                  =>      l_msg_data
                );
                IF Invoice_Cursor%ISOPEN THEN
                   CLOSE Invoice_Cursor;
                END IF;

                IF PO_Cursor%ISOPEN THEN
                   CLOSE PO_Cursor;
                END IF;

                ROLLBACK;
                APP_EXCEPTION.RAISE_EXCEPTION;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      l_msg_count,
                        p_data                  =>      l_msg_data
                );
                IF Invoice_Cursor%ISOPEN THEN
                   CLOSE Invoice_Cursor;
                END IF;

                IF PO_Cursor%ISOPEN THEN
                   CLOSE PO_Cursor;
                END IF;

                ROLLBACK;
                APP_EXCEPTION.RAISE_EXCEPTION;

        WHEN OTHERS THEN
                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                        FND_MSG_PUB.Add_Exc_Msg
                        (       G_PKG_NAME          ,
                                'AP_VENDOR_PARTY_MERGE_PKG.Other_Products_VendorMerge'
                        );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      l_msg_count,
                        p_data                  =>      l_msg_data
                );
                IF (SQLCODE <> -20001) THEN
                   FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
                   FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
		   FND_FILE.Put_Line(FND_FILE.Log,sqlerrm);
                END IF;

                IF Invoice_Cursor%ISOPEN THEN
                   CLOSE Invoice_Cursor;
                END IF;

                IF PO_Cursor%ISOPEN THEN
                   CLOSE PO_Cursor;
                END IF;

		ROLLBACK;
		APP_EXCEPTION.RAISE_EXCEPTION;

END Other_Products_VendorMerge;

PROCEDURE AP_TCA_Contact_Merge (
p_from_party_site_id           IN  NUMBER,
p_to_party_site_id             IN  NUMBER,
p_from_per_party_id	       IN  NUMBER,
p_to_org_party_id	       IN  NUMBER,
x_return_status                OUT NOCOPY VARCHAR2,
x_msg_count		       OUT NOCOPY NUMBER,
x_msg_data		       OUT NOCOPY VARCHAR2,
p_create_partysite_cont_pts    IN  VARCHAR2 DEFAULT 'N' --bug12571995
)
IS

l_relationship_rec            HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE;
l_relationship_id             NUMBER;
l_party_id		      NUMBER;
l_party_number		      NUMBER;
l_contact_point_id	      NUMBER;
l_old_relationship_id         NUMBER;
l_contact_point_rec	      HZ_CONTACT_POINT_v2pub.CONTACT_POINT_REC_TYPE;
l_edi_rec		      HZ_CONTACT_POINT_v2pub.EDI_REC_TYPE;
l_email_rec		      HZ_CONTACT_POINT_v2pub.EMAIL_REC_TYPE;
l_phone_rec		      HZ_CONTACT_POINT_v2pub.PHONE_REC_TYPE;
l_telex_rec		      HZ_CONTACT_POINT_v2pub.TELEX_REC_TYPE;
l_web_rec		      HZ_CONTACT_POINT_v2pub.WEB_REC_TYPE;
l_object_version_number	      NUMBER;
l_party_object_version_number NUMBER;
l_org_contact_rec             HZ_PARTY_CONTACT_V2PUB.org_contact_rec_type;
l_org_contact_id              NUMBER;
l_party_site_rec              HZ_PARTY_SITE_V2PUB.party_site_rec_type;
l_party_site_num	      VARCHAR2(1);
l_party_site_id               NUMBER;
l_party_site_number           VARCHAR2(30);
l_location_id                 NUMBER;
l_msg_index_out               NUMBER;
l_new_vendor_contact_id       NUMBER;
/* Bug 9639308 Procedure rewritten to check for existing org contacts and relationships,
               Improve error handling,
               Remove the commit
               Streamline c_contact_point cursor
               Add last update values to the ap_supplier_contacts update */
-- Bug 7297864- End
CURSOR c_contact_point (l_dup_from_party_id NUMBER, l_per_party_id NUMBER)  /* bug 9604355 */
IS
  select	hcpp.contact_point_id  contact_point_id,
      hcpp.owner_table_id contact_point_owner_id,
      hcpp.owner_table_name contact_point_owner_name
  from	hz_parties hp,
      hz_relationships hzr,
      hz_party_usg_assignments hpua,
      HZ_CONTACT_POINTS hcpp
  where hp.party_id = hzr.subject_id
  and hzr.subject_id = l_per_party_id  /* bug 9604355 */
  and hzr.relationship_type = 'CONTACT'
  and hzr.relationship_code = 'CONTACT_OF'
  and hzr.subject_type ='PERSON'
  and hzr.object_type = 'ORGANIZATION'
  and hzr.status = 'A'
  and hp.party_id not in	(select contact_party_id
              from pos_contact_requests pcr,
                pos_supplier_mappings psm
              where pcr.request_status='PENDING'
              and psm.mapping_id = pcr.mapping_id
              and psm.PARTY_ID = l_dup_from_party_id  /* :2 bug 9604355 */
              and contact_party_id is not null
              )
  and hpua.party_id = hp.party_id
  and hpua.status_flag = 'A'
  and hpua.party_usage_code = 'SUPPLIER_CONTACT'
  and hcpp.OWNER_TABLE_NAME(+) = 'HZ_PARTIES'
  and hcpp.OWNER_TABLE_ID(+) = hzr.PARTY_ID
  and hcpp.status = 'A';


BEGIN -- TCA_Contact_Merge Procedure begin

  FND_FILE.Put_Line(FND_FILE.Log,'Start AP_VENDOR_PARTY_MERGE_PKG.AP_TCA_Contact_Merge API call');

  -- For loop to fetch all contacts one by one
  FOR contact_loop_c IN ( SELECT vendor_contact_id,
                  per_party_id,
                  org_party_site_id,
                  org_contact_id,
                  party_site_id
              FROM ap_supplier_contacts
              WHERE org_party_site_id = p_from_party_site_id
              )
  LOOP

    FND_FILE.Put_Line(FND_FILE.Log,'Inside the loop of merge vendor_contact :'|| contact_loop_c.vendor_contact_id);

    --Initialization of new relationship rec - relationship between 'To Party' and 'Contact'
    l_relationship_rec.subject_id		:= contact_loop_c.per_party_id;
    l_relationship_rec.subject_type		:= 'PERSON';
    l_relationship_rec.subject_table_name	:= 'HZ_PARTIES';
    l_relationship_rec.object_id		:= p_to_org_party_id;
    l_relationship_rec.object_type		:= 'ORGANIZATION';
    l_relationship_rec.object_table_name	:= 'HZ_PARTIES';
    l_relationship_rec.relationship_code	:= 'CONTACT_OF';
    l_relationship_rec.relationship_type	:= 'CONTACT';
    l_relationship_rec.status		:= 'A';
    l_relationship_rec.created_by_module:='AP_SUPPLIERS_API';

    -- Added the following code for bug 9639308
    -- First check if relation already exists for the contact and supplier that we are trying to link. If so, no need to create new relationship.
    BEGIN
      SELECT vendor_contact_id
      INTO   l_new_vendor_contact_id
      FROM   ap_supplier_contacts apc
      WHERE  per_party_id = l_relationship_rec.subject_id
            --AND NVL(org_party_site_id, -1) = contact_loop_c.to_party_site_id;
      AND NVL(org_party_site_id, -1) = p_to_party_site_id;
    EXCEPTION
      WHEN no_data_found THEN
        l_new_vendor_contact_id := NULL;
    END;

    IF l_new_vendor_contact_id IS NULL THEN

      BEGIN
        SELECT relationship_id,
            party_id
        INTO   l_relationship_id,l_party_id
        FROM   hz_relationships
        WHERE  subject_id = l_relationship_rec.subject_id
        AND    subject_type = 'PERSON'
        AND    object_id = l_relationship_rec.object_id
        AND    object_type = 'ORGANIZATION'
        AND    status = 'A'
        AND    directional_flag = 'F';

      EXCEPTION
        WHEN no_data_found THEN
          l_relationship_id := NULL;
	  l_party_id := NULL;    --Bug9899876
      END;

      BEGIN
        IF l_relationship_id IS NOT NULL THEN
          SELECT org_contact_id
          INTO   l_org_contact_id
          FROM   hz_org_contacts
          WHERE  party_relationship_id = l_relationship_id;
        END IF;

      EXCEPTION
        WHEN no_data_found THEN
          l_org_contact_id := NULL;
      END;

      IF l_relationship_id IS NULL
        AND l_org_contact_id IS NULL
        AND contact_loop_c.org_contact_id IS NOT NULL THEN

        FND_FILE.Put_Line(FND_FILE.Log,'Inside if clause contact_loop_c.org_contact_id is not null');

        SELECT comments,
            contact_number,
            department_code,
            department,
            title,
            job_title,
            decision_maker_flag,
            job_title_code,
            reference_use_flag,
            rank
        INTO   l_org_contact_rec.comments,
            l_org_contact_rec.contact_number,
            l_org_contact_rec.department_code,
            l_org_contact_rec.department,
            l_org_contact_rec.title,
            l_org_contact_rec.job_title,
            l_org_contact_rec.decision_maker_flag,
            l_org_contact_rec.job_title_code,
            l_org_contact_rec.reference_use_flag,
            l_org_contact_rec.rank
        FROM   hz_org_contacts
        WHERE  org_contact_id = contact_loop_c.org_contact_id;

        l_org_contact_rec.created_by_module := 'AP_SUPPLIERS_API';
        l_org_contact_rec.party_rel_rec := l_relationship_rec;

        FND_FILE.Put_Line(FND_FILE.Log,'Inside if clause before calling hz_party_contact_v2pub.create_org_contact');

        hz_party_contact_v2pub.Create_org_contact('T',l_org_contact_rec,l_org_contact_id,l_relationship_id,
                            l_party_id,l_party_number,x_return_status,
                            x_msg_count,x_msg_data);

        FND_FILE.Put_Line(FND_FILE.Log,'Inside if clause after calling hz_party_contact_v2pub.create_org_contact');

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
          IF x_msg_count > 0 THEN
            FOR i IN 1.. fnd_msg_pub.count_msg LOOP
              fnd_msg_pub.Get(p_msg_index => i,p_encoded => 'F',p_data => x_msg_data,
                    p_msg_index_out => l_msg_index_out);

              FND_FILE.Put_Line(FND_FILE.Log,x_msg_data||' for Vendor contact : '||contact_loop_c.vendor_contact_id);
            END LOOP;
          END IF;
          RAISE fnd_api.g_exc_error;
        END IF;

      ELSIF l_relationship_id IS NULL
        AND l_org_contact_id IS NULL
        AND contact_loop_c.org_contact_id IS NULL THEN

        FND_FILE.Put_Line(FND_FILE.Log,'Inside else clause before calling hz_relationship_v2pub.create_relationship');

        hz_relationship_v2pub.Create_relationship('T',l_relationship_rec,l_relationship_id,
                            l_party_id,l_party_number,x_return_status,
                            x_msg_count,x_msg_data);

        FND_FILE.Put_Line(FND_FILE.Log,'Inside else clause after calling hz_relationship_v2pub.create_relationship');

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
          IF x_msg_count > 0 THEN
            FOR i IN 1.. fnd_msg_pub.count_msg LOOP
              fnd_msg_pub.Get(p_msg_index => i,p_encoded => 'F',p_data => x_msg_data,
                      p_msg_index_out => l_msg_index_out);

              FND_FILE.Put_Line(FND_FILE.Log,'Error : '||x_msg_data);
            END LOOP;
          END IF;
        RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      SELECT location_id
      INTO   l_location_id
      FROM   hz_party_sites
      WHERE  party_site_id = contact_loop_c.party_site_id;

      l_party_site_rec.location_id := l_location_id;
      l_party_site_rec.created_by_module := 'AP_SUPPLIERS_API';
      l_party_site_rec.application_id := 200;
      l_party_site_rec.party_id := l_party_id;

      BEGIN
        SELECT party_site_id
        INTO   l_party_site_id
        FROM   hz_party_sites
        WHERE  location_id = l_location_id
              AND party_id = l_party_id;

      EXCEPTION
        WHEN no_data_found THEN
          l_party_site_id := NULL;
      END;

      IF l_party_site_id IS NULL THEN
        fnd_profile.Get('HZ_GENERATE_PARTY_SITE_NUMBER',l_party_site_num);

        IF Nvl(l_party_site_num,'Y') = 'N' THEN
          SELECT hz_party_site_number_s.nextval
          INTO   l_party_site_rec.party_site_number
          FROM   dual;
        END IF;

        FND_FILE.Put_Line(FND_FILE.Log,'Inside loop before calling hz_party_site_v2pub.create_party_site');

        -- Create party_site between l_location_id and new party_id - l_party_id
        hz_party_site_v2pub.Create_party_site('T',p_party_site_rec => l_party_site_rec,
                          x_return_status => x_return_status,x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data,x_party_site_id => l_party_site_id,
                          x_party_site_number => l_party_site_number);

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
          IF x_msg_count > 0 THEN
            FOR i IN 1.. fnd_msg_pub.count_msg LOOP
              fnd_msg_pub.Get(p_msg_index => i,p_encoded => 'F',p_data => x_msg_data,
                      p_msg_index_out => l_msg_index_out);

              FND_FILE.Put_Line(FND_FILE.Log,'Error : '||x_msg_data);
            END LOOP;
          END IF;

          RAISE fnd_api.g_exc_error;
        END IF;

        FND_FILE.Put_Line(FND_FILE.Log,'Inside loop after calling hz_party_site_v2pub.create_party_site');

      END IF;

      BEGIN
        SELECT owner_table_id
        INTO   l_contact_point_rec.owner_table_id
        FROM   hz_contact_points
        WHERE  owner_table_id = l_party_id
              AND owner_table_name = 'HZ_PARTIES'
              AND status = 'A'
              AND ROWNUM < 2;
      EXCEPTION
        WHEN no_data_found THEN
          -- For loop to fetch all contact points belong to above contacts (Email-Ids and Phone numbers)
          FOR contact_point_loop_c IN c_contact_point(p_from_per_party_id, contact_loop_c.per_party_id) LOOP /* Bug 9604355 */
          FND_FILE.Put_Line(FND_FILE.Log,'inside second loop');
          BEGIN
            -- Fetching contact point details
            SELECT  contact_point_type,
                status,
                owner_table_name,
                primary_flag,
                orig_system_reference,
                content_source_type,
                contact_point_purpose,
                primary_by_purpose,
                edi_transaction_handling,
                edi_id_number,
                edi_payment_method,
                edi_payment_format,
                edi_remittance_method,
                edi_remittance_instruction,
                edi_tp_header_id,
                edi_ece_tp_location_code,
                email_format,
                email_address,
                phone_calling_calendar,
                last_contact_dt_time,
                timezone_id,
                phone_area_code,
                phone_country_code,
                phone_number,
                phone_extension,
                phone_line_type,
                telex_number,
                web_type,
                url,
                application_id
            INTO    l_contact_point_rec.contact_point_type,
                l_contact_point_rec.status,
                l_contact_point_rec.owner_table_name,
                l_contact_point_rec.primary_flag,
                l_contact_point_rec.orig_system_reference,
                l_contact_point_rec.content_source_type,
                l_contact_point_rec.contact_point_purpose,
                l_contact_point_rec.primary_by_purpose,
                l_edi_rec.edi_transaction_handling,
                l_edi_rec.edi_id_number,
                l_edi_rec.edi_payment_method,
                l_edi_rec.edi_payment_format,
                l_edi_rec.edi_remittance_method,
                l_edi_rec.edi_remittance_instruction,
                l_edi_rec.edi_tp_header_id,
                l_edi_rec.edi_ece_tp_location_code,
                l_email_rec.email_format,
                l_email_rec.email_address,
                l_phone_rec.phone_calling_calendar,
                l_phone_rec.last_contact_dt_time,
                l_phone_rec.timezone_id,
                l_phone_rec.phone_area_code,
                l_phone_rec.phone_country_code,
                l_phone_rec.phone_number,
                l_phone_rec.phone_extension,
                l_phone_rec.phone_line_type,
                l_telex_rec.telex_number,
                l_web_rec.web_type,
                l_web_rec.url,
                l_contact_point_rec.application_id
            FROM hz_contact_points
            WHERE contact_point_id = contact_point_loop_c.contact_point_id;

            l_contact_point_rec.owner_table_id := l_party_id;
            l_contact_point_rec.created_by_module := 'AP_SUPPLIERS_API';

            -- Creation of new contact points with new party_id
            hz_contact_point_v2pub.Create_contact_point('T',l_contact_point_rec,l_edi_rec,l_email_rec,
                                  l_phone_rec,l_telex_rec,l_web_rec,l_contact_point_id,
                                  x_return_status,x_msg_count,x_msg_data);
                  FND_FILE.Put_Line(FND_FILE.Log,'x_return_status: '||x_return_status);

            IF x_return_status <> fnd_api.g_ret_sts_success THEN
              IF x_msg_count > 0 THEN
                FOR i IN 1.. fnd_msg_pub.count_msg LOOP
                  fnd_msg_pub.Get(p_msg_index => i,p_encoded => 'F',p_data => x_msg_data,
                          p_msg_index_out => l_msg_index_out);
                  FND_FILE.Put_Line(FND_FILE.Log,'Error : '||x_msg_data);
                END LOOP;
              END IF;

              RAISE fnd_api.g_exc_error;
            END IF;
            FND_FILE.Put_Line(FND_FILE.Log,'end of second loop');
          EXCEPTION
            WHEN no_data_found THEN
              NULL;
          END;
          END LOOP;

      END;
        FND_FILE.Put_Line(FND_FILE.Log,'before creating ap_supplier_contacts');
        FND_FILE.Put_Line(FND_FILE.Log,'contact_loop_c.vendor_contact_id '
                      ||contact_loop_c.vendor_contact_id);

      BEGIN
        /* Bug 9559145 -- commenting below and writing new insert statement*/

        --UPDATE ap_supplier_contacts
        --SET org_party_site_id	= p_to_party_site_id,
        --  rel_party_id	= l_party_id,
        --  relationship_id	= l_relationship_id,
        --  party_site_id = l_party_site_id,
        --  org_contact_id = l_org_contact_id,
        --  last_update_date = sysdate,
        --  last_updated_by = FND_GLOBAL.USER_ID,
        --  last_update_login = FND_GLOBAL.LOGIN_ID,
        --  request_id = FND_GLOBAL.conc_request_id,
        --  program_application_id = FND_GLOBAL.prog_appl_id,
        --  program_id = FND_GLOBAL.conc_program_id
        --WHERE vendor_contact_id	= contact_loop_c.vendor_contact_id;

        FND_FILE.Put_Line(FND_FILE.Log,'creating new contact for to_party');

	INSERT INTO AP_SUPPLIER_CONTACTS
	(       VENDOR_CONTACT_ID,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		VENDOR_SITE_ID,
		LAST_UPDATE_LOGIN,
		CREATION_DATE,
		CREATED_BY,
		INACTIVE_DATE,
		FIRST_NAME,
		MIDDLE_NAME,
		LAST_NAME,
		PREFIX,
		TITLE,
		MAIL_STOP,
		AREA_CODE,
		PHONE,
		ATTRIBUTE_CATEGORY,
		ATTRIBUTE1,
		ATTRIBUTE2,
		ATTRIBUTE3,
		ATTRIBUTE4,
		ATTRIBUTE5,
		ATTRIBUTE6,
		ATTRIBUTE7,
		ATTRIBUTE8,
		ATTRIBUTE9,
		ATTRIBUTE10,
		ATTRIBUTE11,
		ATTRIBUTE12,
		ATTRIBUTE13,
		ATTRIBUTE14,
		ATTRIBUTE15,
		REQUEST_ID,
		PROGRAM_APPLICATION_ID,
		PROGRAM_ID,
		PROGRAM_UPDATE_DATE,
		CONTACT_NAME_ALT,
		FIRST_NAME_ALT,
		LAST_NAME_ALT,
		DEPARTMENT,
		EMAIL_ADDRESS,
		URL,
		ALT_AREA_CODE,
		ALT_PHONE,
		FAX_AREA_CODE,
		FAX,
		PER_PARTY_ID,
		RELATIONSHIP_ID,
		REL_PARTY_ID,
		PARTY_SITE_ID,
		ORG_CONTACT_ID,
		ORG_PARTY_SITE_ID)
	SELECT
		AP_SUP_SITE_CONTACT_INT_S.NEXTVAL,
		sysdate,
		FND_GLOBAL.USER_ID,
		VENDOR_SITE_ID,
		FND_GLOBAL.LOGIN_ID,
		CREATION_DATE,
		CREATED_BY,
		INACTIVE_DATE,
		FIRST_NAME,
		MIDDLE_NAME,
		LAST_NAME,
		PREFIX,
		TITLE,
		MAIL_STOP,
		AREA_CODE,
		PHONE,
		ATTRIBUTE_CATEGORY,
		ATTRIBUTE1,
		ATTRIBUTE2,
		ATTRIBUTE3,
		ATTRIBUTE4,
		ATTRIBUTE5,
		ATTRIBUTE6,
		ATTRIBUTE7,
		ATTRIBUTE8,
		ATTRIBUTE9,
		ATTRIBUTE10,
		ATTRIBUTE11,
		ATTRIBUTE12,
		ATTRIBUTE13,
		ATTRIBUTE14,
		ATTRIBUTE15,
		FND_GLOBAL.conc_request_id,
		FND_GLOBAL.prog_appl_id,
		FND_GLOBAL.conc_program_id,
		PROGRAM_UPDATE_DATE,
		CONTACT_NAME_ALT,
		FIRST_NAME_ALT,
		LAST_NAME_ALT,
		DEPARTMENT,
		EMAIL_ADDRESS,
		URL,
		ALT_AREA_CODE,
		ALT_PHONE,
		FAX_AREA_CODE,
		FAX,
		PER_PARTY_ID,
		l_relationship_id,
		l_party_id,
		l_party_site_id,
		l_org_contact_id,
		p_to_party_site_id
	FROM AP_SUPPLIER_CONTACTS
	WHERE vendor_contact_id = contact_loop_c.vendor_contact_id;

        FND_FILE.Put_Line(FND_FILE.Log,'No.of rows inserted '||SQL%ROWCOUNT);

        l_org_contact_id := NULL;   --Bug9899876

      EXCEPTION
        WHEN OTHERS THEN
          FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
          FND_FILE.Put_Line(FND_FILE.Log,sqlerrm);
          RAISE fnd_api.g_exc_error;
      END;
    ELSE
      FND_FILE.Put_Line(FND_FILE.Log,'Vendor contact already exists with same info ID : '
                        || l_new_vendor_contact_id);
    END IF;
  END LOOP;

  -- bug12571995 start
  IF p_create_partysite_cont_pts = 'Y'
  THEN
       FOR contact_point_loop_c IN (
               SELECT contact_point_id
                  FROM hz_contact_points
                 WHERE owner_table_name = 'HZ_PARTY_SITES'
                      AND owner_table_id = p_from_party_site_id
       ) LOOP
          FND_FILE.Put_Line(FND_FILE.Log,'inside party site contact points oop');
          BEGIN
            -- Fetching contact point details
            SELECT  contact_point_type,
                status,
                owner_table_name,
                primary_flag,
                orig_system_reference,
                content_source_type,
                contact_point_purpose,
                primary_by_purpose,
                edi_transaction_handling,
                edi_id_number,
                edi_payment_method,
                edi_payment_format,
                edi_remittance_method,
                edi_remittance_instruction,
                edi_tp_header_id,
                edi_ece_tp_location_code,
                email_format,
                email_address,
                phone_calling_calendar,
                last_contact_dt_time,
                timezone_id,
                phone_area_code,
                phone_country_code,
                phone_number,
                phone_extension,
                phone_line_type,
                telex_number,
                web_type,
                url,
                200
            INTO l_contact_point_rec.contact_point_type,
                l_contact_point_rec.status,
                l_contact_point_rec.owner_table_name,
                l_contact_point_rec.primary_flag,
                l_contact_point_rec.orig_system_reference,
                l_contact_point_rec.content_source_type,
                l_contact_point_rec.contact_point_purpose,
                l_contact_point_rec.primary_by_purpose,
                l_edi_rec.edi_transaction_handling,
                l_edi_rec.edi_id_number,
                l_edi_rec.edi_payment_method,
                l_edi_rec.edi_payment_format,
                l_edi_rec.edi_remittance_method,
                l_edi_rec.edi_remittance_instruction,
                l_edi_rec.edi_tp_header_id,
                l_edi_rec.edi_ece_tp_location_code,
                l_email_rec.email_format,
                l_email_rec.email_address,
                l_phone_rec.phone_calling_calendar,
                l_phone_rec.last_contact_dt_time,
                l_phone_rec.timezone_id,
                l_phone_rec.phone_area_code,
                l_phone_rec.phone_country_code,
                l_phone_rec.phone_number,
                l_phone_rec.phone_extension,
                l_phone_rec.phone_line_type,
                l_telex_rec.telex_number,
                l_web_rec.web_type,
                l_web_rec.url,
                l_contact_point_rec.application_id
            FROM hz_contact_points
            WHERE contact_point_id = contact_point_loop_c.contact_point_id;

            l_contact_point_rec.owner_table_id := p_to_party_site_id;
            l_contact_point_rec.created_by_module := 'AP_SUPPLIERS_API';

            -- Creation of new contact points with new party_site_id
            hz_contact_point_v2pub.Create_contact_point('T',l_contact_point_rec,l_edi_rec,l_email_rec,
                                  l_phone_rec,l_telex_rec,l_web_rec,l_contact_point_id,
                                  x_return_status,x_msg_count,x_msg_data);
                  FND_FILE.Put_Line(FND_FILE.Log,'x_return_status: '||x_return_status);

            IF x_return_status <> fnd_api.g_ret_sts_success THEN
              IF x_msg_count > 0 THEN
                FOR i IN 1.. fnd_msg_pub.count_msg LOOP
                  fnd_msg_pub.Get(p_msg_index => i,p_encoded => 'F',p_data => x_msg_data,
                          p_msg_index_out => l_msg_index_out);
                  FND_FILE.Put_Line(FND_FILE.Log,'Error : '||x_msg_data);
                END LOOP;
              END IF;

              RAISE fnd_api.g_exc_error;
            END IF;
            FND_FILE.Put_Line(FND_FILE.Log,'end of party site contact points loop');
          EXCEPTION
            WHEN no_data_found THEN
              NULL;
          END;
          END LOOP;

     END IF;
     --bug12571995 end

  FND_FILE.Put_Line(FND_FILE.Log,'End AP_VENDOR_PARTY_MERGE_PKG.AP_TCA_Contact_Merge API call');

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count,
                        p_data                  =>      x_msg_data
                );

                IF c_contact_point%ISOPEN THEN
                   CLOSE c_contact_point;
                END IF;

                ROLLBACK;
                x_return_status := FND_API.G_RET_STS_ERROR;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count,
                        p_data                  =>      x_msg_data
                );
                IF c_contact_point%ISOPEN THEN
                   CLOSE c_contact_point;
                END IF;

                ROLLBACK;
                APP_EXCEPTION.RAISE_EXCEPTION;

        WHEN OTHERS THEN
                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                        FND_MSG_PUB.Add_Exc_Msg
                        (       G_PKG_NAME          ,
                                'AP_VENDOR_PARTY_MERGE_PKG.AP_TCA_Contact_Merge'
                        );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count,
                        p_data                  =>      x_msg_data
                );
                IF (SQLCODE <> -20001) THEN
                   FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
                   FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
                   FND_FILE.Put_Line(FND_FILE.Log,sqlerrm);
                END IF;

                IF c_contact_point%ISOPEN THEN
                   CLOSE c_contact_point;
                END IF;

                ROLLBACK;
                APP_EXCEPTION.RAISE_EXCEPTION;

/* Bug 7297864- End Bug 9639308 End */
END AP_TCA_Contact_Merge;

END AP_VENDOR_PARTY_MERGE_PKG;

/
