--------------------------------------------------------
--  DDL for Package Body AP_PARTYMERGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_PARTYMERGE_GRP" AS
/* $Header: apgsmrgb.pls 120.3.12010000.2 2009/10/14 11:21:41 ssontine ship $ */

G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_STATEMENT       CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME           CONSTANT VARCHAR2(100) := 'AP.PLSQL.AP_PartyMerge_PKG';
G_PKG_NAME		CONSTANT VARCHAR2(30)  := 'AP_PartyMerge_GRP';

--
-- Procedure Veto_PartySiteMerge
--

PROCEDURE Veto_PartySiteMerge
			(p_Entity_name            IN		VARCHAR2,
			 p_from_id                IN		NUMBER,
			 p_to_id                  IN OUT NOCOPY  NUMBER,
			 p_From_FK_id             IN		NUMBER,
			 p_To_FK_id               IN		NUMBER,
			 p_Parent_Entity_name     IN		VARCHAR2,
			 p_batch_id               IN		NUMBER,
			 p_Batch_Party_id         IN 		NUMBER,
			 x_return_status          IN OUT NOCOPY  VARCHAR2) IS

      l_vndrsites_not_merged    NUMBER;
      l_unpaid_invoices         NUMBER;
      l_po_unchecked_sites      NUMBER;
      l_no_mergedto_site        NUMBER;
      l_mismatch_merge_sites    NUMBER;
      l_debug_info		VARCHAR2(2000);
      l_api_name		CONSTANT VARCHAR2(30) := 'Veto_PartySiteMerge';

BEGIN

      x_return_status  :=  FND_API.G_RET_STS_SUCCESS;

     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                'p_Entity_name: '|| p_Entity_name);
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                'p_from_id: '|| p_from_id);
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                 'p_to_id: '|| p_to_id);
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                 'p_From_FK_id: '|| p_From_FK_id);
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                 'p_To_FK_id: '|| p_To_FK_id);
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                 'p_Parent_Entity_name: '|| p_Parent_Entity_name);
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                 'p_batch_id: '|| p_batch_id);
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                 'p_Batch_Party_id: '|| p_Batch_Party_id);
     END IF;

      ------------------------------------------------------------------------
      l_debug_info := 'Validating Veto Rule One';
      ------------------------------------------------------------------------
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

      -- Veto Rule 1
      -- there could be three cases
      -- case 1: data in HZ_PARTY_SITES + PAV + ADV
      -- case 2: data in HZ_PARTY_SITES + PAV
      -- case 3: data in HZ_PARTY_SITES
      -- the outerjoin takes care of case 2 and because we are using count(*)
      -- case 3 will be taken care of(resulting in count(*) = 0)

      SELECT count(*)
      INTO   l_vndrsites_not_merged
      FROM   ap_supplier_sites_all	pav,
             ap_duplicate_vendors_all	adv
      WHERE  pav.vendor_site_id         =  adv.duplicate_vendor_site_id(+)
      AND    pav.party_site_id		=  p_from_fk_id
      AND    nvl(adv.process_flag,'N') 	<>  'Y';


      IF l_vndrsites_not_merged > 0 THEN

         fnd_message.set_name('SQLAP','AP_PARTYSITE_VETO_FAIL');
         fnd_message.set_token('PARTY_SITE_ID', p_from_fk_id);
         fnd_msg_pub.ADD;
         x_return_status := FND_API.G_RET_STS_ERROR;

      END IF;

      ------------------------------------------------------------------------
      l_debug_info := 'Validating Veto Rule Two';
      ------------------------------------------------------------------------
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_ERROR THEN

         -- Veto Rule 2
         -- Checking for unpaid(including partially paid invoices) invoices
         -- associated with the party_site being merged
         -- We are not using the data from ap_duplicate_vendors for finding
         -- this because 3.1.2.1 of veto rules HLD

         SELECT COUNT(*)
         INTO   l_unpaid_invoices
         FROM   ap_invoices_all     ai,
                ap_supplier_sites_all pav
         WHERE  ai.vendor_site_id               = pav.vendor_site_id
         AND    pav.party_site_id               = p_from_fk_id
         AND    nvl(ai.payment_status_flag,'N') <> 'Y';

         IF l_unpaid_invoices > 0 THEN

            fnd_message.set_name('SQLAP','AP_PARTYSITE_VETO_FAIL');
            fnd_message.set_token('PARTY_SITE_ID', p_from_fk_id);
            fnd_msg_pub.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;

         END IF;
      END IF;

      ------------------------------------------------------------------------
      l_debug_info := 'Validating Veto Rule Three';
      ------------------------------------------------------------------------
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_ERROR THEN

         -- Veto Rule 3
         -- Checking if the user had not checked the Transfer PO Checkbox on
         -- the Supplier Merge Form
         -- Following results have been found on the Supplier Merge Form
         -- Invoices Option      PO       Copy           PROCESS FLAG
         -- All                  Y        Y              B
         -- Unpaid               Y        Y              B
         -- None                 Y        Y              P
         -- All                  N        Y              I
         -- Unpaid               N        Y              I
         -- None                 N        Y              I
         -- All                  Y        N              B
         -- Unpaid               Y        N              B
         -- None                 Y        N              P
         -- All                  N        N              I
         -- Unpaid               N        N              I
         -- None                 N        N              I
         -- Based on above results, it is assumed that Process Flag value 'I'
         -- implies PO checkbox value 'N'

         SELECT COUNT(*)
         INTO   l_po_unchecked_sites
         FROM   ap_duplicate_vendors_all adv,
                ap_supplier_sites_all    pav
         WHERE  pav.vendor_site_id    =  adv.duplicate_vendor_site_id
         AND    pav.party_site_id     =  p_from_fk_id
         AND    nvl(adv.process, 'N') =  'I';

         IF l_po_unchecked_sites > 0 THEN

            fnd_message.set_name('SQLAP','AP_PARTYSITE_VETO_FAIL');
            fnd_message.set_token('PARTY_SITE_ID', p_from_fk_id);
            fnd_msg_pub.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;

         END IF;
      END IF;

      ------------------------------------------------------------------------
      l_debug_info := 'Validating Veto Rule Four';
      ------------------------------------------------------------------------
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_ERROR THEN

         -- Veto Rule 4
         -- A Supplier/Supplier Site is associated with the merged-from
         -- Party/Party Site but there is no Supplier/Supplier Site
         -- associated with the merged-to Party/Party Site.

         SELECT  count(*)
         INTO    l_no_mergedto_site
         FROM    ap_supplier_sites_all pav
         WHERE   pav.party_site_id = p_from_fk_id
         AND NOT EXISTS
			(select vendor_site_id
			 from   ap_supplier_sites_all pav1
	                 where  pav1.party_site_id = p_to_fk_id);

         IF l_no_mergedto_site   > 0 THEN

            fnd_message.set_name('SQLAP','AP_PARTY_SUPP_MISS_VETO_FAIL');
            fnd_message.set_token('PARTY_SITE_ID', p_to_fk_id);
            fnd_msg_pub.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;

         END IF;
      END IF;

      ------------------------------------------------------------------------
      l_debug_info := 'Validating Veto Rule Five';
      ------------------------------------------------------------------------
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

       IF x_return_status <> FND_API.G_RET_STS_ERROR THEN

         -- Veto Rule 5
         -- Payables must confirm that the merged-from Party/Party Site
         -- and merged-to Party/Party Site are correlated th the same
         -- merged-from Supplier/Supplier Site and merged-to
         -- Supplier/Supplier Site.  For example, if Supplier A is merged
         -- into Supplier B and Supplier B is then merged into Supplier C,
         -- the user cannot merge Party A into Party C.  In this case,
         -- the corresponding merged-from Party and merged-to Party are
         -- not the same.

         SELECT count(*)
         INTO   l_mismatch_merge_sites
         FROM   ap_duplicate_vendors_all adv,
                ap_supplier_sites_all	 pav
         WHERE  pav.party_site_id 	 = p_from_fk_id
         AND    pav.vendor_site_id	 = adv.duplicate_vendor_site_id
         AND NOT EXISTS
			(select adv1.vendor_site_id
			   from ap_duplicate_vendors_all adv1,
				    ap_supplier_sites_all    pav1
			  where (adv1.vendor_site_id	  = pav1.vendor_site_id
			         or -- when 'from_fk' site is merged to 'to_fk' site
					 adv1.duplicate_vendor_site_id = pav.vendor_site_id
					 and adv1.vendor_id = pav1.vendor_id
					 and adv1.keep_site_flag = 'Y') --8888020
			    and pav1.party_site_id	  = p_to_fk_id);

         IF l_mismatch_merge_sites   > 0 THEN

            fnd_message.set_name('SQLAP','AP_PARTYSITE_VETO5_FAIL');
            fnd_message.set_token('PARTY_SITE_ID', p_from_fk_id);
            fnd_msg_pub.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;

         END IF;
      END IF;

EXCEPTION
	WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
		FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
		FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
		-- FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
		FND_MESSAGE.SET_TOKEN('PARAMETERS',
			                  'Entity Name = '|| p_Entity_name
			             ||', From Id = '|| to_char(p_from_id )
			             ||', To Id = '|| to_char(p_to_id )
			             ||', From Foreign Key = '|| to_char(p_From_FK_id)
			             ||', To Foreign Key = '|| to_char(p_To_FK_id)
			             ||', Parent Entity Name = '|| p_Parent_Entity_name
			             ||', Batch Id = '|| to_char(p_batch_id)
			             ||', Batch Party Id = '|| to_char(p_Batch_Party_id));
		FND_MSG_PUB.ADD;
           END IF;

           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Veto_PartySiteMerge;

--
-- Procedure Veto_PartyMerge
--

Procedure Veto_PartyMerge
		(p_Entity_name            IN		VARCHAR2,
		 p_from_id                IN		NUMBER,
		 p_to_id                  IN OUT NOCOPY NUMBER,
		 p_From_FK_id             IN		NUMBER,
		 p_To_FK_id               IN		NUMBER,
		 p_Parent_Entity_name     IN		VARCHAR2,
		 p_batch_id               IN		NUMBER,
		 p_Batch_Party_id         IN		NUMBER,
		 x_return_status          IN OUT NOCOPY VARCHAR2) IS

     l_unpaid_invoices         NUMBER;
     l_po_unchecked_sites      NUMBER;
     l_no_mergedto_site        NUMBER;
     l_mismatch_merge_sites    NUMBER;
     l_vndrsites_not_merged    NUMBER;
     l_api_name	CONSTANT      VARCHAR2(30) := 'Veto_PartyMerge';
     l_debug_info	      VARCHAR2(2000);

BEGIN

     x_return_status  :=  FND_API.G_RET_STS_SUCCESS;

     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                'p_Entity_name: '|| p_Entity_name);
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                'p_from_id: '|| p_from_id);
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                 'p_to_id: '|| p_to_id);
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                 'p_From_FK_id: '|| p_From_FK_id);
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                 'p_To_FK_id: '|| p_To_FK_id);
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                 'p_Parent_Entity_name: '|| p_Parent_Entity_name);
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                 'p_batch_id: '|| p_batch_id);
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                 'p_Batch_Party_id: '|| p_Batch_Party_id);
     END IF;

     ------------------------------------------------------------------------
     l_debug_info := 'Validating Veto Rule One';
     ------------------------------------------------------------------------
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;

     -- Veto Rule 1
     -- there could be four cases
     -- case 1: data in HZ_PARTIES + PAV + PVS + ADV
     -- case 2: data in HZ_PARTIES + PAV + PVS
     -- case 3: data in HZ_PARTIES + PAV
     -- case 4: data in HZ_PARTIES
     -- we do not need to do anything for case 3 (there won't be any
     -- transactions to merge if there are not sites for a vendor)
     -- case 4.
     -- The logic is if the vendor_sites exist then there must be records
     -- in adv for these vendor sites and all such records should have
     -- process_flag = 'Y' i.e. there should not be any row in adv with
     -- process_flag <> 'Y'. When data is missing in pov or/and pvs
     -- the sql below will return coun(*) as zero i.e. nothing to merge
     -- (go ahead) . when data is there in pov and pvs but not in adv,
     -- the outerjoin on adv will bring NULL on adv.process_flag hence
     -- nvl(adv.process_flag,'Y') <> 'Y' is counted .
     -- when data is there in all three pov, pvs and adv, all such rows
     -- will be counted by the sql where adv.process_flag <> 'Y' i.e.
     -- site has not yet been successfully merged.

     SELECT count(*)
     INTO   l_vndrsites_not_merged
     FROM   ap_suppliers  		 pov,
            ap_supplier_sites_all        pvs,
            ap_duplicate_vendors_all     adv
     WHERE  pov.party_id                 = p_from_fk_id
     AND    pov.vendor_id                = pvs.vendor_id
     AND    pvs.vendor_site_id           = adv.duplicate_vendor_site_id (+)
     AND    nvl(adv.process_flag, 'N')	 <> 'Y';

     IF l_vndrsites_not_merged > 0 THEN

        fnd_message.set_name('SQLAP','PARTY_VETO_FAIL');
        fnd_message.set_token('PARTY_ID', p_from_fk_id);
        fnd_msg_pub.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;

     END IF;

     ------------------------------------------------------------------------
     l_debug_info := 'Validating Veto Rule Two';
     ------------------------------------------------------------------------
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;

     IF x_return_status <> FND_API.G_RET_STS_ERROR THEN

        -- Veto Rule 2
        -- Checking for unpaid(including partially paid invoices) invoices
        -- associated with the party_site being merged
        -- We are not using the data from ap_duplicate_vendors for finding
        -- this because 3.1.2.1 of veto rules HLD
        -- as we are using count(*), in case if data not being there in any
        -- of the tables ai, pov, pvs, sql will return zero i.e. go ahead

        SELECT COUNT(*)
        INTO   l_unpaid_invoices
        FROM   ap_invoices_all	     ai,
               ap_suppliers	     pov,
               ap_supplier_sites_all pvs
        WHERE  ai.vendor_site_id                = pvs.vendor_site_id
        AND    pvs.vendor_id                    = pov.vendor_id
        AND    pov.party_id                     = p_from_fk_id
        AND    nvl(ai.payment_status_flag,'N')  <> 'Y';

         IF l_unpaid_invoices > 0 THEN

            fnd_message.set_name('SQLAP','AP_PARTY_VETO_FAIL');
            fnd_message.set_token('PARTY_ID', p_from_fk_id);
            fnd_msg_pub.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;

         END IF;
     END IF;

     ------------------------------------------------------------------------
     l_debug_info := 'Validating Veto Rule Three';
     ------------------------------------------------------------------------
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;

     IF x_return_status <> FND_API.G_RET_STS_ERROR THEN

        -- Veto Rule 3
        -- Checking if the user had not checked the Transfer PO Checkbox on
        -- the Supplier Merge Form
        -- Following results have been found on the Supplier Merge Form
        -- Invoices Option      PO       Copy           PROCESS FLAG
        -- All                  Y        Y              B
        -- Unpaid               Y        Y              B
        -- None                 Y        Y              P
        -- All                  N        Y              I
        -- Unpaid               N        Y              I
        -- None                 N        Y              I
        -- All                  Y        N              B
        -- Unpaid               Y        N              B
        -- None                 Y        N              P
        -- All                  N        N              I
        -- Unpaid               N        N              I
        -- None                 N        N              I
        -- Based on above results, it is assumed that Process Flag value 'I'
        -- implies PO checkbox value 'N'

        SELECT COUNT(*)
        INTO   l_po_unchecked_sites
        FROM   ap_duplicate_vendors_all adv,
               ap_supplier_sites_all    pvs,
               ap_suppliers		pov
        WHERE pov.party_id		= p_from_fk_id
        and   pov.vendor_id		= pvs.vendor_id
        and   pvs.vendor_site_id	= adv.duplicate_vendor_site_id
        and   nvl(adv.process, 'N')	= 'I';

        IF l_po_unchecked_sites > 0 THEN

           fnd_message.set_name('SQLAP','AP_PARTY_VETO_FAIL');
           fnd_message.set_token('PARTY_ID', p_from_fk_id);
           fnd_msg_pub.ADD;
           x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;
     END IF;

     ------------------------------------------------------------------------
     l_debug_info := 'Validating Veto Rule Four';
     ------------------------------------------------------------------------
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;

     IF x_return_status <> FND_API.G_RET_STS_ERROR THEN

        -- Veto Rule 4
        -- A Supplier/Supplier Site is associated with the merged-from
        -- Party/Party Site but there is no Supplier/Supplier Site
        -- associated with the merged-to Party/Party Site.
        -- we will check for existence of vendor_sites because in AP
        -- you cannot have transactions until you have vendor sites
        -- i.e. just having vendors will not help.

        SELECT count(*)
        INTO   l_no_mergedto_site
        FROM   ap_supplier_sites_all pvs,
               ap_suppliers          pov
        WHERE  pov.party_id	   = p_from_fk_id
        AND    pov.vendor_id	   = pvs.vendor_id
        AND NOT EXISTS
		     (select vendor_site_id
		      from   ap_supplier_sites_all pvs1,
			     ap_suppliers          pov1
		      where  pov1.party_id    = p_to_fk_id
		      and    pov1.vendor_id   = pvs1.vendor_id);

        IF l_no_mergedto_site   > 0 THEN

           fnd_message.set_name('SQLAP','AP_PARTY_SUPP_MISS_VETO_FAIL');
           fnd_message.set_token('PARTY_ID', p_to_fk_id);
           fnd_msg_pub.ADD;
           x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;
     END IF;

     ------------------------------------------------------------------------
     l_debug_info := 'Validating Veto Rule Five';
     ------------------------------------------------------------------------
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;

     IF x_return_status <> FND_API.G_RET_STS_ERROR THEN

        -- Veto Rule 5
        -- Payables must confirm that the merged-from Party/Party Site
        -- and merged-to Party/Party Site are correlated with the same
        -- merged-from Supplier/Supplier Site and merged-to
        -- Supplier/Supplier Site.  For example, if Supplier A is merged
        -- into Supplier B and Supplier B is then merged into Supplier C,
        -- the user cannot merge Party A into Party C.  In this case,
        -- the corresponding merged-from Party and merged-to Party are
        -- not the same.
        -- perf bug 5055689 - removed MJC by going to base tables
        SELECT count(*)
        INTO   l_mismatch_merge_sites
        FROM   ap_duplicate_vendors_all    adv,
               ap_supplier_sites_all	   apss,
               ap_suppliers		   aps
        WHERE  aps.party_id	  =  p_from_fk_id
        AND    aps.vendor_id	  =  apss.vendor_id
        AND    apss.vendor_site_id =  adv.duplicate_vendor_site_id
        AND NOT EXISTS
		      (select adv1.vendor_site_id
                 from ap_duplicate_vendors_all    adv1,
			          ap_supplier_sites_all       apss1,
			          ap_suppliers                aps1
		        where (adv1.vendor_site_id = apss1.vendor_site_id
                       or -- when 'from_fk' site is merged to 'to_fk' site
					   adv1.duplicate_vendor_site_id = apss.vendor_site_id
					   and adv1.vendor_id = apss1.vendor_id
					   and adv1.keep_site_flag = 'Y') --8888020
		          and apss1.vendor_id = aps1.vendor_id
		          and aps1.party_id = p_to_fk_id);

         IF l_mismatch_merge_sites   > 0 THEN

            fnd_message.set_name('SQLAP','AP_PARTY_VETO5_FAIL');
            fnd_message.set_token('PARTY_ID', p_from_id);
            fnd_msg_pub.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;

         END IF;
     END IF;

EXCEPTION
	WHEN OTHERS THEN

           IF (SQLCODE <> -20001) THEN
		FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
		FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
		-- FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
		FND_MESSAGE.SET_TOKEN('PARAMETERS',
					'Entity Name = '|| p_Entity_name
			             ||', From Id = '|| to_char(p_from_id )
			             ||', To Id = '|| to_char(p_to_id )
			             ||', From Foreign Key = '|| to_char(p_From_FK_id)
			             ||', To Foreign Key = '|| to_char(p_To_FK_id)
			             ||', Parent Entity Name = '|| p_Parent_Entity_name
			             ||', Batch Id = '|| to_char(p_batch_id)
			             ||', Batch Party Id = '|| to_char(p_Batch_Party_id));
		FND_MSG_PUB.ADD;
           END IF;

           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Veto_PartyMerge;

--
-- Procedure Update_PerPartyid
--

Procedure Update_PerPartyid
		(p_Entity_name        IN     VARCHAR2,
		 p_from_id            IN     NUMBER,
		 p_to_id              IN     NUMBER,
		 p_From_Fk_id         IN     NUMBER,
		 p_To_Fk_id           IN     NUMBER,
		 p_Parent_Entity_name IN     VARCHAR2,
		 p_batch_id           IN     NUMBER,
		 p_Batch_Party_id     IN     NUMBER,
		 x_return_status      IN OUT NOCOPY VARCHAR2) IS

     new_per_party_id	NUMBER := p_to_fk_id;
     old_per_party_id	NUMBER := p_from_fk_id;
     l_api_name		CONSTANT VARCHAR2(30) := 'Update_PerPartyid';
     l_debug_info	VARCHAR2(2000);

BEGIN

     x_return_status  :=  FND_API.G_RET_STS_SUCCESS;

     ------------------------------------------------------------------------
     l_debug_info := 'Updating po_vendor_contacts';
     ------------------------------------------------------------------------
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;

     UPDATE ap_supplier_contacts
--po_vendor_contacts
     SET    per_party_id   = new_per_party_id
     WHERE  per_party_id   = old_per_party_id;

EXCEPTION
	WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
		FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
		FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
		-- FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
		FND_MESSAGE.SET_TOKEN('PARAMETERS',
		                  'Entity Name = '|| p_Entity_name
		             ||', From Id = '|| to_char(p_from_id )
		             ||', To Id = '|| to_char(p_to_id )
		             ||', From Foreign Key = '|| to_char(p_From_FK_id)
		             ||', To Foreign Key = '|| to_char(p_To_FK_id)
		             ||', Parent Entity Name = '|| p_Parent_Entity_name
		             ||', Batch Id = '|| to_char(p_batch_id)
		             ||', Batch Party Id = '|| to_char(p_Batch_Party_id));
		FND_MSG_PUB.ADD;
           END IF;

           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Update_PerPartyid ;

--
-- Procedure Update_RelPartyid
--

Procedure Update_RelPartyid
		(p_Entity_name        IN     VARCHAR2,
		 p_from_id            IN     NUMBER,
		 p_to_id              IN     NUMBER,
		 p_From_Fk_id         IN     NUMBER,
		 p_To_Fk_id           IN     NUMBER,
		 p_Parent_Entity_name IN     VARCHAR2,
		 p_batch_id           IN     NUMBER,
		 p_Batch_Party_id     IN     NUMBER,
		 x_return_status      IN OUT NOCOPY VARCHAR2) IS

     new_rel_party_id  NUMBER := p_to_fk_id;
     old_rel_party_id  NUMBER := p_from_fk_id;
     l_api_name              CONSTANT VARCHAR2(30)   := 'Update_RelPartyid';
     l_debug_info            VARCHAR2(2000);

BEGIN

     x_return_status  :=  FND_API.G_RET_STS_SUCCESS;

     ------------------------------------------------------------------------
     l_debug_info := 'Updating po_vendor_contacts';
     ------------------------------------------------------------------------
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;

     UPDATE ap_supplier_contacts
--po_vendor_contacts
     SET    rel_party_id   = new_rel_party_id
     WHERE  rel_party_id = old_rel_party_id;

EXCEPTION
	WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
		FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
		FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
		-- FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
		FND_MESSAGE.SET_TOKEN('PARAMETERS',
				'Entity Name = '|| p_Entity_name
		             ||', From Id = '|| to_char(p_from_id )
		             ||', To Id = '|| to_char(p_to_id )
		             ||', From Foreign Key = '|| to_char(p_From_FK_id)
		             ||', To Foreign Key = '|| to_char(p_To_FK_id)
		             ||', Parent Entity Name = '|| p_Parent_Entity_name
		             ||', Batch Id = '|| to_char(p_batch_id)
		             ||', Batch Party Id = '|| to_char(p_Batch_Party_id));
		FND_MSG_PUB.ADD;
           END IF;

           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Update_RelPartyid;

--
-- Procedure Update_PartySiteid
--

Procedure Update_PartySiteid
		(p_Entity_name        IN     VARCHAR2,
		 p_from_id            IN     NUMBER,
		 p_to_id              IN     NUMBER,
		 p_From_Fk_id         IN     NUMBER,
		 p_To_Fk_id           IN     NUMBER,
		 p_Parent_Entity_name IN     VARCHAR2,
		 p_batch_id           IN     NUMBER,
		 p_Batch_Party_id     IN     NUMBER,
		 x_return_status      IN OUT NOCOPY VARCHAR2) IS

     new_party_site_id  NUMBER := p_to_fk_id;
     old_party_site_id  NUMBER := p_from_fk_id;
     l_api_name              CONSTANT VARCHAR2(30)   := 'Update_PartySiteid';
     l_debug_info            VARCHAR2(2000);

BEGIN

     x_return_status  :=  FND_API.G_RET_STS_SUCCESS;

     ------------------------------------------------------------------------
     l_debug_info := 'Updating po_vendor_contacts';
     ------------------------------------------------------------------------
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;

     UPDATE ap_supplier_contacts
-- po_vendor_contacts
     SET    party_site_id   = new_party_site_id
     WHERE  party_site_id = old_party_site_id;

EXCEPTION
	WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
		FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
		FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
		-- FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
		FND_MESSAGE.SET_TOKEN('PARAMETERS',
		                  'Entity Name = '|| p_Entity_name
		             ||', From Id = '|| to_char(p_from_id )
		             ||', To Id = '|| to_char(p_to_id )
		             ||', From Foreign Key = '|| to_char(p_From_FK_id)
		             ||', To Foreign Key = '|| to_char(p_To_FK_id)
		             ||', Parent Entity Name = '|| p_Parent_Entity_name
		             ||', Batch Id = '|| to_char(p_batch_id)
		             ||', Batch Party Id = '|| to_char(p_Batch_Party_id));
		FND_MSG_PUB.ADD;
           END IF;

           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Update_PartySiteid ;

END AP_PartyMerge_GRP;


/
