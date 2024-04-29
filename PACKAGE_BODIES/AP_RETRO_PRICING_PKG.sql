--------------------------------------------------------
--  DDL for Package Body AP_RETRO_PRICING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_RETRO_PRICING_PKG" AS
/* $Header: apretrob.pls 120.29.12010000.14 2010/10/27 12:53:25 dawasthi ship $ */

G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AP_RETRO_PRICING_PKG';
G_MSG_UERROR        CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
G_MSG_ERROR         CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_ERROR;
G_MSG_SUCCESS       CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_SUCCESS;
G_MSG_HIGH          CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
G_MSG_MEDIUM        CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
G_MSG_LOW           CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;
G_LINES_PER_FETCH   CONSTANT NUMBER       := 1000;

G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_UNEXPECTED      CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
G_LEVEL_ERROR           CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
G_LEVEL_EXCEPTION       CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_EVENT           CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
G_LEVEL_PROCEDURE       CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT       CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME           CONSTANT VARCHAR2(100) := 'AP.PLSQL.AP_RETRO_PRICING_PKG.';


/*=============================================================================
 |  PROCEDURE - insert_ap_inv_interface()
 |
 |  DESCRIPTION
 |      Private procedure called from Create_Instructions. Program identifies PO
 |      suppliers that are listed in the PO view within the report parameters.
 |      It then populates the Payables Open Interface Table with one instruction
 |      record per supplier.  Each header record will include: a source of PPA,
 |      the supplier ID, userid of the PO user and a unique group_id for the CADIP.
 |
 |  PARAMETERS
 |      p_group_id       - Unique group_id generated in Create_Instructions
 |      p_org_id         - Org Id of the PO User
 |      p_po_user_id     - PO's User Id
 |      p_vendor_id      - Vendor Id
 |      p_vendor_site_id - Vendor Site Id
 |      p_po_header_id   - Valid PO's Header Id
 |      p_po_release_id  - Valid PO Release Id
 |      P_calling_sequence -  Calling sequence
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
PROCEDURE insert_ap_inv_interface (
           p_group_id         IN     VARCHAR2,
           p_org_id           IN     NUMBER,
           p_po_user_id       IN     NUMBER,
           p_vendor_id        IN     NUMBER,
           p_vendor_site_id   IN     NUMBER,
           p_po_header_id     IN     NUMBER,
           p_po_release_id    IN     NUMBER,
           p_calling_sequence IN     VARCHAR2) IS

l_vendor_id_list            id_list_type;
l_vendor_num_list           vendor_num_list_type;
l_vendor_name_list          vendor_name_list_type;


current_calling_sequence    VARCHAR2(2000);
debug_info                  VARCHAR2(2000);
l_api_name              CONSTANT VARCHAR2(200) := 'INSERT_AP_INV_INTERFACE';

--Bug 5048503 added new ref cursor variable
Type vendorcur          is REF CURSOR;
vendor_cur              vendorcur;
sql_stmt                varchar2(4000);

/* Bug 5048503. will replace the cursor def with dynamic query
CURSOR vendor  IS
SELECT DISTINCT pd.vendor_id,
       pv.segment1,  -- supplier number
       pv.vendor_name
  FROM po_ap_retroactive_dist_v pd,
       po_vendors pv
 WHERE mo_global.check_access(pd.org_id) = 'Y'
   AND pd.vendor_id = pv.vendor_id
   AND pd.invoice_adjustment_flag = 'R'
   AND pd.org_id         = p_org_id
   AND pd.vendor_id      = DECODE(p_vendor_id, NULL,
                                  pd.vendor_id, p_vendor_id)
   AND pd.po_header_id   = DECODE(p_po_header_id, NULL,
                                  pd.po_header_id, p_po_header_id)
   -- Commented out until bug 4484058 is resolved.
   AND pd.vendor_site_id = DECODE(p_vendor_site_id, NULL,
                                  pd.vendor_site_id, p_vendor_site_id)
   AND NVL(pd.po_release_id, 1)  = DECODE(p_po_release_id, NULL,
                                          NVL(pd.po_release_id,1),
                                              p_po_release_id);*/
   --
BEGIN
  --
  current_calling_sequence := 'init<-'||P_calling_sequence;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_RETRO_PRICING_PKG.INSERT_AP_INV_INTERFACE(+)');
 END IF;

-- Bug 5048503 : starts
  -------------------------------------------------
  debug_info := ' dynamic query for Vendor_cursor';
  -------------------------------------------------

  sql_stmt :=  'SELECT DISTINCT pd.vendor_id,
                pv.segment1,  -- supplier number
                pv.vendor_name
                FROM po_ap_retroactive_dist_v pd,
                     po_vendors pv
                WHERE mo_global.check_access(pd.org_id) = ''Y''
                AND pd.vendor_id = pv.vendor_id
                AND pd.invoice_adjustment_flag = ''R'' ' ;

  IF ( p_org_id is NOT NULL) then
      sql_stmt := sql_stmt ||' AND pd.org_id = ' || p_org_id  ;
  END IF;
  IF ( p_vendor_id is NOT NULL) then
      sql_stmt := sql_stmt ||' AND pd.vendor_id = ' || p_vendor_id ;
  END IF;
  IF ( p_po_header_id is NOT NULL) then
      sql_stmt := sql_stmt ||' AND pd.po_header_id = '|| p_po_header_id  ;
  END IF;
  IF ( p_vendor_site_id is NOT NULL) then
      sql_stmt := sql_stmt ||' AND pd.vendor_site_id  = ' || p_vendor_site_id ;
  END IF;
  IF ( p_po_release_id is NOT NULL) then
      sql_stmt := sql_stmt ||' AND NVL(pd.po_release_id, 1) = '
                           || p_po_release_id ;
  END IF;

  -----------------------------------------------
  debug_info := 'Step 4a. build l_vendor_list';
  -----------------------------------------------

 -- open the cursor for the dynamic select stmt
  OPEN vendor_cur for sql_stmt;

  FETCH vendor_cur
  BULK COLLECT INTO l_vendor_id_list,
                    l_vendor_num_list,
                    l_vendor_name_list;

  CLOSE vendor_cur;

-- Bug 5048503 : ends

/* commented for Bug 5048503
  OPEN vendor;
  FETCH vendor
  BULK COLLECT INTO l_vendor_id_list,
                    l_vendor_num_list,
                    l_vendor_name_list;
  CLOSE vendor;
*/
  ---------------------------------------------------------
  debug_info := 'Step 4b.Insert into ap_invoices_interface';
  ----------------------------------------------------------
  FORALL I IN 1 .. l_vendor_id_list.count
         INSERT INTO ap_invoices_interface
                   (org_id,
                    invoice_id,
                    source,
                    vendor_id,
                    vendor_num,
                    vendor_name,
                    group_id,
                    created_by,
                    creation_date,
                    last_updated_by,
                    last_update_date,
                    last_update_login,
                    request_id)
          VALUES   (p_org_id,
                    AP_INVOICES_INTERFACE_S.nextval,
                    'PPA',
                    l_vendor_id_list(i),
                    l_vendor_num_list(i),
                    l_vendor_name_list(i),
                    p_group_id,
                    p_po_user_id,
                    SYSDATE,                   --creation_date
                    FND_GLOBAL.user_id,        --last_updated_by
                    SYSDATE,                   --last_update_date
                    FND_GLOBAL.conc_login_id,  --last_update_login
                    FND_GLOBAL.conc_request_id --request_id
                   );


  --------------------------------------------------
  debug_info := 'Step 4c. Clear PL/SQL tables';
  --------------------------------------------------
  l_vendor_id_list.DELETE;
  l_vendor_num_list.DELETE;
  l_vendor_name_list.DELETE;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
   FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_RETRO_PRICING_PKG.INSERT_AP_INV_INTERFACE(-)');
 END IF;



EXCEPTION
   --
   WHEN OTHERS THEN
      IF (SQLCODE <> -20001 ) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info );
        FND_MESSAGE.SET_TOKEN('PARAMETERS','P_vendor_id: '||TO_CHAR(P_vendor_id)
                                        ||',P_vendor_site_id: '||TO_CHAR(P_vendor_site_id)
                                        ||',p_po_header_id: '||TO_CHAR(p_po_header_id)
                                        ||',P_vendor_site_id: '||TO_CHAR(P_vendor_site_id)
                                        ||',p_po_release_id: '||TO_CHAR(p_po_release_id)
                                        ||',p_po_user_id: '||TO_CHAR(p_po_user_id)
                                        ||',p_org_id: '||TO_CHAR(p_org_id));
   END IF;

   debug_info := 'In Others Exception';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,debug_info);
   END IF;
   --
-- Bug 5048503. changed vendor to vendor_cur
   IF ( vendor_cur%ISOPEN ) THEN
        CLOSE vendor_cur;
   END IF;
    --
   APP_EXCEPTION.RAISE_EXCEPTION;
   --
END insert_ap_inv_interface;



/*=============================================================================
 |  PROCEDURE - insert_ap_inv_lines_interface()
 |
 |  DESCRIPTION
 |      Private procedure called from Create_Instructions. Program identifies
 |      for header record, a unique line record for each retropriced PO shipment.
 |
 |  PARAMETERS
 |      p_group_id       - Unique group_id generated in Create_Instructions
 |      p_org_id         - Org Id of the PO User
 |      p_po_user_id     - PO's User Id
 |      p_vendor_id      - Vendor Id
 |      p_vendor_site_id - Vendor Site Id
 |      p_po_header_id   - Valid PO's Header Id
 |      p_po_release_id  - Valid PO Release Id
 |      P_calling_sequence -  Calling sequence
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/


PROCEDURE insert_ap_inv_lines_interface (
           p_group_id         IN  VARCHAR2,
           p_org_id           IN  NUMBER,
           p_po_user_id       IN  NUMBER,
           p_vendor_id        IN  NUMBER,
           p_vendor_site_id   IN  NUMBER,
           p_po_header_id     IN  NUMBER,
           p_po_release_id    IN  NUMBER,
           p_calling_sequence IN  VARCHAR2) IS

l_po_line_loc_id_list       id_list_type;
l_po_header_id_list         id_list_type;
l_po_line_id_list           id_list_type;
l_po_release_id_list        id_list_type;
l_invoice_id_list           id_list_type;
l_unit_price_list           id_list_type;
l_po_number_list            po_number_list_type;
l_po_line_number_list       id_list_type;
l_release_num_list          id_list_type;
l_po_shipment_num_list      id_list_type;


current_calling_sequence    VARCHAR2(2000);
debug_info                  VARCHAR2(2000);

CURSOR shipment IS
SELECT DISTINCT pd.line_location_id,
       pll.shipment_num,
       pd.po_header_id,
       ph.segment1,
       pd.po_line_id,
       pl.line_num,
       pd.po_release_id,
       pr.release_num,
       pd.price_override,
       aii.invoice_id
  FROM po_ap_retroactive_dist_v pd,
       po_headers_all ph,
       po_releases_all pr,
       po_lines_all pl,
       po_line_locations_all pll,
       ap_invoices_interface aii
 WHERE mo_global.check_access(pd.org_id) = 'Y'
   AND pd.po_header_id = ph.po_header_id
   AND pd.po_release_id =  pr.po_release_id(+)
   AND pd.po_line_id    =  pl.po_line_id
   AND pd.line_location_id = pll.line_location_id
   AND pd.invoice_adjustment_flag = 'R'
   AND pd.org_id         = aii.org_id
   AND aii.vendor_id     = pd.vendor_id
   AND aii.source        = 'PPA'
   AND aii.group_id      = p_group_id
   AND aii.org_id        = p_org_id
   AND pd.vendor_id      = DECODE(p_vendor_id, NULL,
                                  pd.vendor_id, p_vendor_id)
   AND pd.po_header_id   = DECODE(p_po_header_id, NULL,
                                  pd.po_header_id, p_po_header_id)
  AND pd.vendor_site_id = DECODE(p_vendor_site_id, NULL,
                                 pd.vendor_site_id, p_vendor_site_id)
  AND NVL(pd.po_release_id, 1)  = DECODE(p_po_release_id, NULL,
                                         NVL(pd.po_release_id,1),
                                             p_po_release_id);

   num BINARY_INTEGER := 1;
   l_api_name CONSTANT VARCHAR2(200) := 'insert_ap_inv_lines_interface';
  --
BEGIN


  current_calling_sequence := 'insert_ap_inv_lines_interface<-'||P_calling_sequence;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
      	'AP_RETRO_PRICING_PKG.INSERT_AP_INV_LINES_INTERFACE(+)');
   END IF;
  -----------------------------------------------
  debug_info := 'Step 5a. build shipment list';
  -----------------------------------------------

  --bugfix:4681253
  FOR num IN 1..1000 LOOP

   l_po_line_loc_id_list(num) := NULL;
   l_po_shipment_num_list(num) := NULL;
   l_po_header_id_list(num) := NULL;
   l_po_number_list(num) := NULL;
   l_po_line_id_list(num) := NULL;
   l_po_line_number_list(num) := NULL;
   l_release_num_list(num) := NULL;
   l_unit_price_list(num) := NULL;
   l_invoice_id_list(num) := NULL;

  END LOOP;

  OPEN shipment;
  FETCH shipment
  BULK COLLECT INTO l_po_line_loc_id_list,
                    l_po_shipment_num_list,
                    l_po_header_id_list,
                    l_po_number_list,
                    l_po_line_id_list,
                    l_po_line_number_list,
		    --Commented out until bug 4484058 is resolved.
                    l_po_release_id_list,
                    l_release_num_list,
                    l_unit_price_list,
                    l_invoice_id_list;
  CLOSE shipment;

  ------------------------------------------------------
  debug_info := 'Step 5b.Insert into ap_invoice_lines_interface';
  -------------------------------------------------------
  --Bugfix:4681253, added the IF condition and modified the FORALL from
  --'1..count' to 'first..last'.
  IF (l_po_line_loc_id_list.COUNT > 0) THEN

     FORALL i IN nvl(l_po_line_loc_id_list.first,0) .. l_po_line_loc_id_list.last
       INSERT INTO  ap_invoice_lines_interface
                    (invoice_id,
                    invoice_line_id,
                    po_header_id,
                    po_number,
                    po_line_id,
                    po_line_number,
                 --   po_release_id,
                   -- release_num,
                    po_line_location_id,
                    po_shipment_num,
                    unit_price,
                    created_by,
                    creation_date,
                    last_updated_by,
                    last_update_date,
                    last_update_login)
           VALUES  (l_invoice_id_list(i),
                    AP_INVOICE_LINES_INTERFACE_S.nextval,
                    l_po_header_id_list(i),
                    l_po_number_list(i),
                    l_po_line_id_list(i),
                    l_po_line_number_list(i),
                    --l_po_release_id_list(i),
                    --l_release_num_list(i),
                    l_po_line_loc_id_list(i),
                    l_po_shipment_num_list(i),
                    l_unit_price_list(i),
                    p_po_user_id,
                    SYSDATE,                   --creation_date
                    FND_GLOBAL.user_id,        --last_updated_by
                    SYSDATE,                   --last_update_date
                    FND_GLOBAL.conc_login_id   --last_update_login
                    );

		    --Introduced below UPDATE for bug#9573078
		    -- and commented in CREATE_INSTRUCTIONS procedure
		    -- at step3

		    FORALL i in 1..l_po_line_loc_id_list.COUNT
                    UPDATE PO_DISTRIBUTIONS_ALL
                    SET    invoice_adjustment_flag = 'S'
                    WHERE  line_location_id = l_po_line_loc_id_list(i);

   END IF; /* l_po_line_loc_id_list.count > 0 */


  --------------------------------------------------
  debug_info := 'Step 5c. Clear PL/SQL tables';
  --------------------------------------------------

  l_po_line_loc_id_list.DELETE;
  l_po_header_id_list.DELETE;
  l_po_line_id_list.DELETE;
  l_po_release_id_list.DELETE;
  l_invoice_id_list.DELETE;
  l_unit_price_list.DELETE;
  l_po_number_list.DELETE;
  l_po_line_number_list.DELETE;
  l_release_num_list.DELETE;
  l_po_shipment_num_list.DELETE;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_RETRO_PRICING_PKG.INSERT_AP_INV_LINES_INTERFACE(-)');
  END IF;


EXCEPTION

  WHEN OTHERS THEN

   IF (SQLCODE <> -20001 ) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info );
        FND_MESSAGE.SET_TOKEN('PARAMETERS','P_vendor_id: '||TO_CHAR(P_vendor_id)
                                        ||',P_vendor_site_id: '||TO_CHAR(P_vendor_site_id)
                                        ||',p_po_header_id: '||TO_CHAR(p_po_header_id)
                                        ||',P_vendor_site_id: '||TO_CHAR(P_vendor_site_id)
                                        ||',p_po_release_id: '||TO_CHAR(p_po_release_id)
                                        ||',p_po_user_id: '||TO_CHAR(p_po_user_id)
                                        ||',p_org_id: '||TO_CHAR(p_org_id));
    END IF;

    debug_info := 'In Others Exception';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,debug_info);
    END IF;
    --
    IF ( shipment%ISOPEN ) THEN
        CLOSE shipment;
    END IF;
    --
    APP_EXCEPTION.RAISE_EXCEPTION;

END insert_ap_inv_lines_interface;


/*=============================================================================
 |  FUNCTION - Create_Instructions()
 |
 |  DESCRIPTION
 |      Main Public procedure for the CADIP called from before report trigger
 |      of APXCADIP. The parameters to the program can limit the process to a
 |      single supplier, site, PO, or release.This program overloads the Invoice
 |      Interface with Instructions. CADIP then initiates the Payables Open
 |      Interface Import program for the instruction records in the interface
 |      using the GROUP_ID(Gateway Batch) as a program parameter. If the
 |      instructions are rejected then CADIP can be resubmitted. Open Interface
 |      Import on resubmission runs for all Instruction rejections(GROUP_ID
 |      is NULL).
 |
 |  PARAMETERS
 |      p_org_id           - Org Id of the PO User
 |      p_po_user_id       - PO's User Id
 |      p_vendor_id        - Vendor Id: Concurrent program parameter
 |      p_vendor_site_id   - Vendor Site Id: Concurrent program parameter
 |      p_po_header_id     - Valid PO's Header Id: Concurrent program parameter
 |      p_po_release_id    - Valid PO Release Id: Concurrent program parameter
 |      P_calling_sequence - Calling sequence
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
FUNCTION Create_Instructions (
           p_vendor_id              IN            NUMBER,
           p_vendor_site_id         IN            NUMBER,
           p_po_header_id           IN            NUMBER,
           p_po_release_id          IN            NUMBER,
           p_po_user_id             IN            NUMBER,
           p_resubmit_flag          IN            VARCHAR2,
           errbuf                      OUT NOCOPY VARCHAR2,
           retcode                     OUT NOCOPY NUMBER,
           p_import_conc_request_id    OUT NOCOPY NUMBER,
           p_calling_sequence       IN            VARCHAR2)
RETURN BOOLEAN IS

l_org_id                     NUMBER;
l_ou_count                   NUMBER;
l_ou_name                    VARCHAR2(240);

Request_Submission_Failure   EXCEPTION;
Allow_paid_Invoice_Adjust    EXCEPTION;
current_calling_sequence     VARCHAR2(2000);
debug_info                   VARCHAR2(1000);

l_allow_paid_invoice_adjust  VARCHAR2(1);
l_group_id                   AP_INVOICES_INTERFACE.group_id%TYPE;
l_po_line_loc_id_list        id_list_type;
l_batch_id                   NUMBER;
l_batch_num                  NUMBER;
l_batch_control_flag         VARCHAR2(1) := 'N';
l_request_id                 NUMBER;
l_msg                        VARCHAR2(2000);
l_batch_name		     VARCHAR2(200);

l_api_name CONSTANT VARCHAR2(200) := 'CREATE_INSTRUCTIONS';

l_org_id_list            id_list_type;

CURSOR orgs  IS
SELECT DISTINCT pd.org_id
  FROM po_ap_retroactive_dist_v pd,
       po_vendors pv
 WHERE mo_global.check_access(pd.org_id) = 'Y'
   AND pd.vendor_id = pv.vendor_id
   AND pd.invoice_adjustment_flag = 'R'
   AND pd.vendor_id      = DECODE(p_vendor_id, NULL,
                                  pd.vendor_id, p_vendor_id)
   AND pd.po_header_id   = DECODE(p_po_header_id, NULL,
                                  pd.po_header_id, p_po_header_id)
   AND pd.vendor_site_id = DECODE(p_vendor_site_id, NULL,
                                  pd.vendor_site_id, p_vendor_site_id)
   AND NVL(pd.po_release_id, 1)  = DECODE(p_po_release_id, NULL,
                                          NVL(pd.po_release_id,1),
                                              p_po_release_id);
 l_use_batch_controls VARCHAR2(30) := NULL; --added for bug#6926296
BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence := 'CADIP<-'||P_calling_sequence ;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_RETRO_PRICING_PKG.CREATE_INSTRUCTIONS(+)');
   END IF;

   -----------------------------------------------------------------
   debug_info := 'Step 1. Generate a Group Id(Invoice Gateway Batch';
   -----------------------------------------------------------------
	-- Although we are using the  ap_batches_s to generate
	-- the Invoice_gateway_batch name, it has no relationship
	-- with the Invoice Batch_name(used if the batch control options
	IF p_resubmit_flag <> 'Y' THEN
	    SELECT  ap_batches_s.nextval
	      INTO  l_batch_id
	      FROM  sys.dual;
	END IF;
	--Gateway Batch
	l_group_id := 'PPA' || ':' || to_char(l_batch_id);

	 --Commenting the below code for bug#6926296
	--Bugfix:4681253
	/*select decode(nvl(fpov1.profile_option_value,'N'),
	'N', lc.displayed_field)
	INTO l_batch_name
	FROM fnd_profile_option_values fpov1,
	    fnd_profile_options fpo1,
	    ap_lookup_codes lc
	WHERE fpov1.profile_option_id = fpo1.profile_option_id
	AND fpo1.profile_option_name ='AP_USE_INV_BATCH_CONTROLS'
	AND fpov1.level_id = 10004
	AND lc.lookup_type ='NLS REPORT PARAMETER'
	and lc.lookup_code = 'NA'
	AND rownum = 1;*/
  --End of commenting code for bug#6926296

  --Added the below code for bug#6926296
   l_use_batch_controls := fnd_profile.value('AP_USE_INV_BATCH_CONTROLS');
	if nvl(l_use_batch_controls,'N') = 'N' then
	  select lc.displayed_field
	    into l_batch_name
	   from ap_lookup_codes lc
	  where lc.lookup_type = 'NLS REPORT PARAMETER'
	    and lc.lookup_code = 'NA';
	end if;
   --End of code addition for bug#6926296

  -----------------------------------------------------------
  debug_info := 'Step 2. Get the distinct Org Ids.';
  -----------------------------------------------------------
   OPEN orgs;
   FETCH orgs
   BULK COLLECT INTO l_org_id_list;
   CLOSE orgs;

    FOR I IN 1 .. l_org_id_list.count
    LOOP

        l_org_id := l_org_id_list(i);
        -----------------------------------------------------------------
        debug_info := 'Step 2a. Check Allow Adjustments to paid Invoices'||
                      to_char(l_org_id) ;
        -----------------------------------------------------------------
		SELECT NVL(ALLOW_PAID_INVOICE_ADJUST, 'N')
		INTO   l_allow_paid_invoice_adjust
		FROM   ap_system_parameters_all
		WHERE  org_id = l_org_id_list(i);

		IF  l_allow_paid_invoice_adjust = 'N' THEN
		  FND_MESSAGE.SET_NAME('SQLAP', 'ALLOW_PAID_INVOICE_ADJUST');
		  RAISE Allow_paid_Invoice_Adjust;
		END IF;



		-----------------------------------------------------------------
		debug_info := 'Step 2b.  Populate AP_INVOICES_INTERFACE';
		-----------------------------------------------------------------
		   IF p_resubmit_flag <> 'Y' THEN

		     AP_RETRO_PRICING_PKG.insert_ap_inv_interface (
		          l_group_id,
		          l_org_id,
		          p_po_user_id,
		          p_vendor_id,
		          p_vendor_site_id,
		          p_po_header_id,
		          p_po_release_id,
		          current_calling_sequence);
		   END IF;

		---------------------------------------------------------------
		debug_info := 'Step 2c.  Populate AP_INVOICE_LINES_INTERFACE';
	        ----------------------------------------------------------------
		   IF p_resubmit_flag <> 'Y' THEN

		     AP_RETRO_PRICING_PKG.insert_ap_inv_lines_interface(
		        l_group_id,
		        l_org_id,
		        p_po_user_id,
		        p_vendor_id,       -- IN
		        p_vendor_site_id,  -- IN
		        p_po_header_id,    -- IN
		        p_po_release_id,   -- IN
		        current_calling_sequence);

		   END IF;

                 --Commented below code for bug#9573078
		   --and introduced in insert_ap_inv_lines_interface
		   --procedure.

              /*  ---------------------------------------------------------------
                debug_info := 'Step 3.  Update the PO View';
                ---------------------------------------------------------------
                IF p_resubmit_flag <> 'Y' THEN

                  FORALL i in 1..l_po_line_loc_id_list.COUNT

                    UPDATE PO_AP_RETROACTIVE_DIST_V
                    SET    invoice_adjustment_flag = 'S'
                    WHERE  line_location_id = l_po_line_loc_id_list(i);

                END IF; */

  END LOOP;

  -----------------------------------------------------------
  debug_info := 'Step 4.  Submit Invoice Import';
  -----------------------------------------------------------
   IF p_resubmit_flag = 'Y' THEN
       l_group_id := NULL;
   END IF;


 l_request_id := FND_REQUEST.SUBMIT_REQUEST(
                  'SQLAP',
                  'APXIIMPT',
                  '', '', FALSE,
                  '',
                  'PPA',
                  l_group_id,
                  l_batch_name,
                  '','','','','','','',
                  chr(0),'', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '');

    IF l_request_id <> 0 THEN
       p_import_conc_request_id := l_request_id;
       commit;
    ELSE
        RAISE Request_Submission_Failure;
    END IF;
   --

    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_RETRO_PRICING_PKG.CREATE_INSTRUCTIONS(-)');
    END IF;

    RETURN(TRUE);
    --
EXCEPTION
    WHEN  Allow_paid_Invoice_Adjust  THEN

      FND_FILE.PUT_LINE(FND_FILE.LOG, fnd_message.GET);
      debug_info := 'In Allow_paid_Invoice_Adjust Exception';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,debug_info);
      END IF;


      RETURN TRUE;

    WHEN request_submission_failure THEN
       l_msg := FND_MESSAGE.GET;
       FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
       FND_MESSAGE.SET_TOKEN('ERROR',l_msg);
       FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
       FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info );
       FND_MESSAGE.SET_TOKEN('PARAMETERS','P_vendor_id: '||TO_CHAR(P_vendor_id)
                                        ||',P_vendor_site_id: '||TO_CHAR(P_vendor_site_id)
                                        ||',p_po_header_id: '||TO_CHAR(p_po_header_id)
                                        ||',P_vendor_site_id: '||TO_CHAR(P_vendor_site_id)
                                        ||',p_po_release_id: '||TO_CHAR(p_po_release_id)
                                        ||',p_po_user_id: '||TO_CHAR(p_po_user_id)
                                        ||',p_org_id: '||TO_CHAR(l_org_id)
                                        ||',p_resubmit_flag: '||p_resubmit_flag);

      debug_info := 'In request_submission_failure Exception';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,debug_info);
      END IF;

      RETURN FALSE;

  WHEN OTHERS THEN
      IF (SQLCODE <> -20001 ) THEN
	        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
	        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
	        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
	        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info );
	        FND_MESSAGE.SET_TOKEN('PARAMETERS','P_vendor_id: '||TO_CHAR(P_vendor_id)
	                                        ||',P_vendor_site_id: '||TO_CHAR(P_vendor_site_id)
	                                        ||',p_po_header_id: '||TO_CHAR(p_po_header_id)
	                                        ||',P_vendor_site_id: '||TO_CHAR(P_vendor_site_id)
	                                        ||',p_po_release_id: '||TO_CHAR(p_po_release_id)
	                                        ||',p_po_user_id: '||TO_CHAR(p_po_user_id)
	                                        ||',p_org_id: '||TO_CHAR(l_org_id)
	                                        ||',p_resubmit_flag: '||p_resubmit_flag);
    END IF;

    debug_info := 'In Others Exception';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,debug_info);
    END IF;

    APP_EXCEPTION.RAISE_EXCEPTION;
    RETURN FALSE;
	    --
END Create_Instructions;


/*===============================================================================
 |  FUNCTION - Reverse_Existing_Ppa_Dists()
 |
 |  DESCRIPTION
 |        This function is called from Reverse_Existing_Ppa for every Po Price
 |  Adjustment line on the active PPA. It effectively reverses all the
 |  distributions on a Po Price Adjustment Line for a PPA.
 |
 |  PARAMETERS
 |      p_instruction_id
 |      p_ppa_lines_rec
 |      p_existing_ppa_lines_rec IN
 |      P_calling_sequence - Calling sequence
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *==============================================================================*/
FUNCTION Reverse_Existing_Ppa_Dists(
              p_instruction_id          IN NUMBER,
              p_ppa_lines_rec           IN AP_RETRO_PRICING_PKG.invoice_lines_rec_type,
              p_existing_ppa_lines_rec  IN AP_RETRO_PRICING_PKG.invoice_lines_rec_type,
              P_calling_sequence        IN VARCHAR2)
RETURN BOOLEAN IS

CURSOR Existing_ppa_invoice_dists   IS
SELECT  accounting_date,
        accrual_posted_flag,
        amount,
        asset_book_type_code,
        asset_category_id,
        assets_addition_flag,
        assets_tracking_flag,
        attribute_category,
        attribute1,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        award_id,
        awt_flag,
        awt_group_id,
        awt_tax_rate_id,
        base_amount,
        batch_id,
        cancellation_flag,
        cash_posted_flag,
        corrected_invoice_dist_id,
        corrected_quantity,
        country_of_supply,
        created_by,
        description,
        dist_code_combination_id,
        dist_match_type,
        distribution_class,
        distribution_line_number,
        encumbered_flag,
        expenditure_item_date,
        expenditure_organization_id,
        expenditure_type,
        final_match_flag,
        global_attribute_category,
        global_attribute1,
        global_attribute10,
        global_attribute11,
        global_attribute12,
        global_attribute13,
        global_attribute14,
        global_attribute15,
        global_attribute16,
        global_attribute17,
        global_attribute18,
        global_attribute19,
        global_attribute2,
        global_attribute20,
        global_attribute3,
        global_attribute4,
        global_attribute5,
        global_attribute6,
        global_attribute7,
        global_attribute8,
        global_attribute9,
        income_tax_region,
        inventory_transfer_status,
        invoice_distribution_id,
        invoice_id,
        invoice_line_number,
        line_type_lookup_code,
        match_status_flag,
        matched_uom_lookup_code,
        merchant_document_number,
        merchant_name,
        merchant_reference,
        merchant_tax_reg_number,
        merchant_taxpayer_id,
        org_id,
        pa_addition_flag,
        pa_quantity,
        period_name,
        po_distribution_id,
        posted_flag,
        project_id,
        quantity_invoiced,
        rcv_transaction_id,
        related_id,
        reversal_flag,
        rounding_amt,
        set_of_books_id,
        task_id,
        type_1099,
        unit_price,
        p_instruction_id,      --instruction_id,
        NULL,                    --charge_applicable_to_dist_id
        INTENDED_USE,
        WITHHOLDING_TAX_CODE_ID,
        PROJECT_ACCOUNTING_CONTEXT,
        REQ_DISTRIBUTION_ID,
        REFERENCE_1,
        REFERENCE_2,
        NULL,                   -- line_group_number
        PA_CC_AR_INVOICE_ID,
        PA_CC_AR_INVOICE_LINE_NUM,
        PA_CC_PROCESSED_CODE,
	pay_awt_group_id  --bug6817107
   FROM ap_invoice_distributions_all
  WHERE invoice_id          = p_existing_ppa_lines_rec.invoice_id
    AND invoice_line_number = p_existing_ppa_lines_rec.line_number
    AND  NVL(cancellation_flag, 'N' ) <> 'Y'
    AND NVL(reversal_flag, 'N' ) <> 'Y';

l_existing_ppa_dist_list   AP_RETRO_PRICING_PKG.invoice_dists_list_type;
l_ppa_invoice_dists_list   AP_RETRO_PRICING_PKG.invoice_dists_list_type;

current_calling_sequence   VARCHAR2(1000);
debug_info                 VARCHAR2(1000);
l_api_name                 CONSTANT VARCHAR2(200) := 'Reverse_Existing_Ppa_Dists';


BEGIN

  current_calling_sequence := 'AP_RETRO_PRICING_PKG.Reverse_Existing_Ppa_Dists'
                    ||P_Calling_Sequence;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_RETRO_PRICING_PKG.Reverse_Existing_Ppa_Dists(+)');
  END IF;

  ---------------------------------------------------------------------------
  debug_info := 'Reverse_Existing_Ppa_Dists Step 1. Open cursor '
                 ||'existing_ppa_invoice_dists';
  ---------------------------------------------------------------------------
  OPEN existing_ppa_invoice_dists;
  FETCH existing_ppa_invoice_dists
  BULK COLLECT INTO l_existing_ppa_dist_list;
  CLOSE existing_ppa_invoice_dists;
  --
  ---------------------------------------------------------------------------
  debug_info := 'Reverse_Existing_Ppa_Dists  Step 2.  Compute Reversal PPA Dist';
  ---------------------------------------------------------------------------
  FOR i IN 1..l_existing_ppa_dist_list.COUNT
  LOOP
      l_ppa_invoice_dists_list(i)   := l_existing_ppa_dist_list(i);
      l_ppa_invoice_dists_list(i).invoice_id          :=  p_ppa_lines_rec.invoice_id;
      l_ppa_invoice_dists_list(i).invoice_line_number :=  p_ppa_lines_rec.line_number;
  --    l_ppa_invoice_dists_list(i).invoice_distribution_id :=  AP_RETRO_PRICING_UTIL_PKG.get_invoice_distribution_id;
      l_ppa_invoice_dists_list(i).invoice_distribution_id := Null;
      l_ppa_invoice_dists_list(i).distribution_line_number := i;  -- Bug 5525506
      l_ppa_invoice_dists_list(i).dist_match_type     := 'ADJUSTMENT_CORRECTION';
      l_ppa_invoice_dists_list(i).distribution_class  := 'PERMANENT';
      l_ppa_invoice_dists_list(i).accounting_date     := SYSDATE;
      l_ppa_invoice_dists_list(i).period_name         := AP_INVOICES_PKG.get_period_name(SYSDATE);
      l_ppa_invoice_dists_list(i).accrual_posted_flag := 'N';
      l_ppa_invoice_dists_list(i).cash_posted_flag    := 'N';
      l_ppa_invoice_dists_list(i).posted_flag         := 'N';
      l_ppa_invoice_dists_list(i).amount              := (-1)*l_existing_ppa_dist_list(i).amount;
      l_ppa_invoice_dists_list(i).unit_price          := (-1)*l_existing_ppa_dist_list(i).unit_price;
      --For base currency invoices NULL*(-1) = NULL
      l_ppa_invoice_dists_list(i).base_amount         := (-1)*l_existing_ppa_dist_list(i).base_amount;

      l_ppa_invoice_dists_list(i).match_status_flag   := NULL;
      l_ppa_invoice_dists_list(i).encumbered_flag     := 'N';
      l_ppa_invoice_dists_list(i).corrected_invoice_dist_id := l_existing_ppa_dist_list(i).invoice_distribution_id;
      l_ppa_invoice_dists_list(i).corrected_quantity  :=  l_existing_ppa_dist_list(i).corrected_quantity;
      l_ppa_invoice_dists_list(i).quantity_invoiced    := NULL;
      l_ppa_invoice_dists_list(i).final_match_flag     := 'N';
      l_ppa_invoice_dists_list(i).assets_addition_flag := 'U';

      IF l_ppa_invoice_dists_list(i).assets_tracking_flag = 'Y' THEN
         l_ppa_invoice_dists_list(i).asset_book_type_code := p_ppa_lines_rec.asset_book_type_code;
         l_ppa_invoice_dists_list(i).asset_category_id    := p_ppa_lines_rec.asset_category_id;
      END IF;

      IF l_ppa_invoice_dists_list(i).project_id IS NOT NULL THEN
        l_ppa_invoice_dists_list(i).pa_Addition_flag := 'N';
      ELSE
        l_ppa_invoice_dists_list(i).pa_Addition_flag := 'E';
      END IF;
      l_ppa_invoice_dists_list(i).inventory_transfer_status := 'N';
      l_ppa_invoice_dists_list(i).created_by := p_ppa_lines_rec.created_by;
      l_ppa_invoice_dists_list(i).INTENDED_USE := l_existing_ppa_dist_list(i).INTENDED_USE;
      l_ppa_invoice_dists_list(i).WITHHOLDING_TAX_CODE_ID := l_existing_ppa_dist_list(i).WITHHOLDING_TAX_CODE_ID;
      l_ppa_invoice_dists_list(i).PROJECT_ACCOUNTING_CONTEXT := l_existing_ppa_dist_list(i).PROJECT_ACCOUNTING_CONTEXT;
      l_ppa_invoice_dists_list(i).REQ_DISTRIBUTION_ID := l_existing_ppa_dist_list(i).REQ_DISTRIBUTION_ID;
      l_ppa_invoice_dists_list(i).REFERENCE_1 := l_existing_ppa_dist_list(i).REFERENCE_1;
      l_ppa_invoice_dists_list(i).REFERENCE_2 := l_existing_ppa_dist_list(i).REFERENCE_2;
      l_ppa_invoice_dists_list(i).LINE_GROUP_NUMBER := l_existing_ppa_dist_list(i).LINE_GROUP_NUMBER;
      l_ppa_invoice_dists_list(i).PA_CC_AR_INVOICE_ID := l_existing_ppa_dist_list(i).PA_CC_AR_INVOICE_ID;
      l_ppa_invoice_dists_list(i).PA_CC_AR_INVOICE_LINE_NUM := l_existing_ppa_dist_list(i).PA_CC_AR_INVOICE_LINE_NUM;
      l_ppa_invoice_dists_list(i).PA_CC_PROCESSED_CODE := l_existing_ppa_dist_list(i).PA_CC_PROCESSED_CODE;


      END LOOP;

      ------------------------------------------------------------------------
      debug_info := 'Reverse_Existing_Ppa_Dists Step 3. Insert PPA Reversal '
                     ||' Dists in the Global Temp Table';
      ------------------------------------------------------------------------
      FORALL i IN 1..l_ppa_invoice_dists_list.COUNT
               INSERT INTO ap_ppa_invoice_dists_gt values  l_ppa_invoice_dists_list(i);


      ----------------------------------------------------------------------
      debug_info := 'Reverse_Existing_Ppa_Dists Step 4. Clear PL/SQL tables';
      ----------------------------------------------------------------------
      l_existing_ppa_dist_list.DELETE;
      l_ppa_invoice_dists_list.DELETE;

    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_RETRO_PRICING_PKG.Reverse_Existing_Ppa_Dists(-)');
  END IF;
  --
  RETURN(TRUE);
  --
EXCEPTION
 WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
      debug_info := 'In Others Exception';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,debug_info);
      END IF;
    END IF;
    --
    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      SQLERRM);
      END IF;
    END IF;
    --
    IF ( existing_ppa_invoice_dists%ISOPEN ) THEN
        CLOSE existing_ppa_invoice_dists;
    END IF;
    --
    RETURN(FALSE);

END Reverse_Existing_Ppa_Dists;


/*=============================================================================
 |  FUNCTION - Reverse_Existing_Ppa()
 |
 |  DESCRIPTION
 |        If the PPA already exists for a base match line then all the PO PRICE
 |  ADJUSTMENT lines of the active PPA will be reversed via call to this
 |  function. This function is called once for every new PPA Document
 |
 |  Note: There will be only one active PPA document(which itself has not been
 |        reversed by  another PPA document) per base matched INVOICE for a
 |        particular shipment.
 |
 |  PARAMETERS
 |      p_instruction_id
 |      p_ppa_invoice_rec
 |      p_instruction_lines_rec
 |      p_existing_ppa_inv_id
 |      P_calling_sequence - Calling sequence
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
FUNCTION Reverse_Existing_Ppa(
           p_instruction_id     IN NUMBER,
           p_ppa_invoice_rec      IN AP_RETRO_PRICING_PKG.invoice_rec_type,
           p_instruction_lines_rec      IN AP_RETRO_PRICING_PKG.instruction_lines_rec_type,
           p_existing_ppa_inv_id IN NUMBER,
           P_calling_sequence    IN VARCHAR2)
RETURN BOOLEAN    IS
CURSOR existing_ppa_lines IS
SELECT invoice_id,
       line_number,
       line_type_lookup_code,
       requester_id,
       description,
       line_source,
       org_id,
       inventory_item_id,
       item_description,
       serial_number,
       manufacturer,
       model_number,
       generate_dists,
       match_type,
       default_dist_ccid,
       prorate_across_all_items,
       accounting_date,
       period_name,
       deferred_acctg_flag,
       set_of_books_id,
       amount,
       base_amount,
       rounding_amt,
       quantity_invoiced,
       unit_meas_lookup_code,
       unit_price,
       discarded_flag,
       cancelled_flag,
       income_tax_region,
       type_1099,
       corrected_inv_id,
       corrected_line_number,
       po_header_id,
       po_line_id,
       po_release_id,
       po_line_location_id,
       po_distribution_id,
       rcv_transaction_id,
       final_match_flag,
       assets_tracking_flag,
       asset_book_type_code,
       asset_category_id,
       project_id,
       task_id,
       expenditure_type,
       expenditure_item_date,
       expenditure_organization_id,
       award_id,
       awt_group_id,
       pay_awt_group_id,--bug6817107
       receipt_verified_flag,
       receipt_required_flag,
       receipt_missing_flag,
       justification,
       expense_group,
       start_expense_date,
       end_expense_date,
       receipt_currency_code,
       receipt_conversion_rate,
       receipt_currency_amount,
       daily_amount,
       web_parameter_id,
       adjustment_reason,
       merchant_document_number,
       merchant_name,
       merchant_reference,
       merchant_tax_reg_number,
       merchant_taxpayer_id,
       country_of_supply,
       credit_card_trx_id,
       company_prepaid_invoice_id,
       cc_reversal_flag,
       creation_date,
       created_by,
       attribute_category,
       attribute1,
       attribute2,
       attribute3,
       attribute4,
       attribute5,
       attribute6,
       attribute7,
       attribute8,
       attribute9,
       attribute10,
       attribute11,
       attribute12,
       attribute13,
       attribute14,
       attribute15,
       global_attribute_category,
       global_attribute1,
       global_attribute2,
       global_attribute3,
       global_attribute4,
       global_attribute5,
       global_attribute6,
       global_attribute7,
       global_attribute8,
       global_attribute9,
       global_attribute10,
       global_attribute11,
       global_attribute12,
       global_attribute13,
       global_attribute14,
       global_attribute15,
       global_attribute16,
       global_attribute17,
       global_attribute18,
       global_attribute19,
       global_attribute20,
       primary_intended_use,
       ship_to_location_id,
       product_type,
       product_category,
       product_fisc_classification,
       user_defined_fisc_class,
       trx_business_category,
       summary_tax_line_id,
       tax_regime_code,
       tax,
       tax_jurisdiction_code,
       tax_status_code,
       tax_rate_id,
       tax_rate_code,
       tax_rate,
       wfapproval_status,
       pa_quantity,
       p_instruction_id,   --instruction_id
       'PPA',              --adj_type
       cost_factor_id,      --cost_factor_id
       TAX_CLASSIFICATION_CODE,
       SOURCE_APPLICATION_ID         ,
       SOURCE_EVENT_CLASS_CODE         ,
       SOURCE_ENTITY_CODE         ,
       SOURCE_TRX_ID         ,
       SOURCE_LINE_ID         ,
       SOURCE_TRX_LEVEL_TYPE         ,
       PA_CC_AR_INVOICE_ID         ,
       PA_CC_AR_INVOICE_LINE_NUM         ,
       PA_CC_PROCESSED_CODE         ,
       REFERENCE_1         ,
       REFERENCE_2         ,
       DEF_ACCTG_START_DATE         ,
       DEF_ACCTG_END_DATE         ,
       DEF_ACCTG_NUMBER_OF_PERIODS         ,
       DEF_ACCTG_PERIOD_TYPE         ,
       REFERENCE_KEY5         ,
       PURCHASING_CATEGORY_ID         ,
       LINE_GROUP_NUMBER         ,
       WARRANTY_NUMBER         ,
       REFERENCE_KEY3         ,
       REFERENCE_KEY4         ,
       APPLICATION_ID         ,
       PRODUCT_TABLE         ,
       REFERENCE_KEY1         ,
       REFERENCE_KEY2         ,
       RCV_SHIPMENT_LINE_ID
  FROM ap_invoice_lines_all
 WHERE invoice_id = p_existing_ppa_inv_id
   AND line_source = 'PO PRICE ADJUSTMENT'
   AND match_type = 'PO_PRICE_ADJUSTMENT'
   AND line_type_lookup_code = 'RETROITEM'
   AND discarded_flag <> 'Y'
   AND cancelled_flag <> 'Y';

l_ppa_lines_rec            AP_RETRO_PRICING_PKG.invoice_lines_rec_type;
l_existing_ppa_lines_rec   AP_RETRO_PRICING_PKG.invoice_lines_rec_type;
l_existing_ppa_lines_list  AP_RETRO_PRICING_PKG.invoice_lines_list_type;
Ppa_Line_Reversal_failure  EXCEPTION;
current_calling_sequence   VARCHAR2(1000);
debug_info                 VARCHAR2(1000);

BEGIN
   --
   current_calling_sequence := 'AP_RETRO_PRICING_PKG.Reverse_Existing_Ppa'
                  ||P_Calling_Sequence;
   ---------------------------------------------------------------------------
   debug_info := 'Reverse_Existing_Ppa Step 1. Open Existing PPA Lines';
   ---------------------------------------------------------------------------
   OPEN existing_ppa_lines;
   FETCH existing_ppa_lines
   BULK COLLECT INTO l_existing_ppa_lines_list;
   CLOSE existing_ppa_lines;
   --
   -- Create PPA Lines that are reversal of all existing
   -- PO Price Adjustment Lines of the PPA
   ---------------------------------------------------------------------------
   debug_info := 'Reverse_Existing_Ppa Step 2. Compute Reversal PPA Lines';
   ---------------------------------------------------------------------------
   FOR i IN 1..l_existing_ppa_lines_list.COUNT
   LOOP
      l_existing_ppa_lines_rec := l_existing_ppa_lines_list(i);
      --
      l_ppa_lines_rec      := l_existing_ppa_lines_rec;
      --
      l_ppa_lines_rec.invoice_id   := p_ppa_invoice_rec.invoice_id;
      l_ppa_lines_rec.line_number  := AP_RETRO_PRICING_UTIL_PKG.get_max_ppa_line_num(
                                           p_ppa_invoice_Rec.invoice_id) + 1;
      l_ppa_lines_rec.line_source  := 'ADJUSTMENT CORRECTION';
      l_ppa_lines_rec.line_type_lookup_code := 'RETROITEM';
      l_ppa_lines_rec.requester_id := NVL(p_instruction_lines_rec.requester_id,
                                       l_existing_ppa_lines_rec.requester_id);
      l_ppa_lines_rec.description  := NVL(p_instruction_lines_rec.description,
                                        l_existing_ppa_lines_rec.description);
      l_ppa_lines_rec.default_dist_ccid := NULL;
      l_ppa_lines_rec.generate_dists           := 'D';
      l_ppa_lines_rec.prorate_across_all_items := 'N';

      l_ppa_lines_rec.accounting_date := NVL(p_instruction_lines_rec.accounting_date,
                    AP_INVOICES_PKG.get_GL_date(p_ppa_invoice_rec.invoice_date));
      l_ppa_lines_rec.period_name     := AP_INVOICES_PKG.get_period_name(l_ppa_lines_rec.accounting_date);
      --
      l_ppa_lines_rec.deferred_Acctg_flag := 'N';

      l_ppa_lines_rec.amount := (-1)*l_existing_ppa_lines_rec.amount;
      l_ppa_lines_rec.quantity_invoiced  := l_existing_ppa_lines_rec.quantity_invoiced;
      l_ppa_lines_rec.unit_price  := (-1)*l_existing_ppa_lines_rec.unit_price;
      l_ppa_lines_rec.discarded_flag := 'N';
      l_ppa_lines_rec.cancelled_flag := 'N';
      l_ppa_lines_rec.corrected_inv_id := l_existing_ppa_lines_rec.invoice_id;
      l_ppa_lines_rec.corrected_line_number := l_existing_ppa_lines_rec.line_number;
      l_ppa_lines_rec.final_match_flag := 'N';
      l_ppa_lines_rec.award_id := NVL(p_instruction_lines_rec.award_id,
                                      l_existing_ppa_lines_rec.award_id);
      l_ppa_lines_rec.created_by := p_ppa_invoice_rec.created_by;
      l_ppa_lines_rec.instruction_id       := p_instruction_id;
      l_ppa_lines_rec.adj_type := 'PPA';   -- Bug 5525506

       l_ppa_lines_rec.TAX_CLASSIFICATION_CODE := l_existing_ppa_lines_rec.TAX_CLASSIFICATION_CODE;
       l_ppa_lines_rec.SOURCE_APPLICATION_ID := l_existing_ppa_lines_rec.SOURCE_APPLICATION_ID;
       l_ppa_lines_rec.SOURCE_EVENT_CLASS_CODE := l_existing_ppa_lines_rec.SOURCE_EVENT_CLASS_CODE;
       l_ppa_lines_rec.SOURCE_ENTITY_CODE := l_existing_ppa_lines_rec.SOURCE_ENTITY_CODE;
       l_ppa_lines_rec.SOURCE_TRX_ID := l_existing_ppa_lines_rec.SOURCE_TRX_ID;
       l_ppa_lines_rec.SOURCE_LINE_ID := l_existing_ppa_lines_rec.SOURCE_LINE_ID;
       l_ppa_lines_rec.SOURCE_TRX_LEVEL_TYPE := l_existing_ppa_lines_rec.SOURCE_TRX_LEVEL_TYPE;
       l_ppa_lines_rec.PA_CC_AR_INVOICE_ID := l_existing_ppa_lines_rec.PA_CC_AR_INVOICE_ID;
       l_ppa_lines_rec.PA_CC_AR_INVOICE_LINE_NUM := l_existing_ppa_lines_rec.PA_CC_AR_INVOICE_LINE_NUM;
       l_ppa_lines_rec.PA_CC_PROCESSED_CODE := l_existing_ppa_lines_rec.PA_CC_PROCESSED_CODE;
       l_ppa_lines_rec.REFERENCE_1 := l_existing_ppa_lines_rec.REFERENCE_1;
       l_ppa_lines_rec.REFERENCE_2 := l_existing_ppa_lines_rec.REFERENCE_2;
       l_ppa_lines_rec.DEF_ACCTG_START_DATE := l_existing_ppa_lines_rec.DEF_ACCTG_START_DATE;
       l_ppa_lines_rec.DEF_ACCTG_END_DATE := l_existing_ppa_lines_rec.DEF_ACCTG_END_DATE;
       l_ppa_lines_rec.DEF_ACCTG_NUMBER_OF_PERIODS := l_existing_ppa_lines_rec.DEF_ACCTG_NUMBER_OF_PERIODS;
       l_ppa_lines_rec.DEF_ACCTG_PERIOD_TYPE := l_existing_ppa_lines_rec.DEF_ACCTG_PERIOD_TYPE;
       l_ppa_lines_rec.REFERENCE_KEY5 := l_existing_ppa_lines_rec.REFERENCE_KEY5;
       l_ppa_lines_rec.PURCHASING_CATEGORY_ID := l_existing_ppa_lines_rec.PURCHASING_CATEGORY_ID;
       l_ppa_lines_rec.LINE_GROUP_NUMBER  := NULL;
       l_ppa_lines_rec.WARRANTY_NUMBER := l_existing_ppa_lines_rec.WARRANTY_NUMBER;
       l_ppa_lines_rec.REFERENCE_KEY3 := l_existing_ppa_lines_rec.REFERENCE_KEY3;
       l_ppa_lines_rec.REFERENCE_KEY4 := l_existing_ppa_lines_rec.REFERENCE_KEY4;
       l_ppa_lines_rec.APPLICATION_ID := l_existing_ppa_lines_rec.APPLICATION_ID;
       l_ppa_lines_rec.PRODUCT_TABLE := l_existing_ppa_lines_rec.PRODUCT_TABLE;
       l_ppa_lines_rec.REFERENCE_KEY1 := l_existing_ppa_lines_rec.REFERENCE_KEY1;
       l_ppa_lines_rec.REFERENCE_KEY2 := l_existing_ppa_lines_rec.REFERENCE_KEY2;
       l_ppa_lines_rec.RCV_SHIPMENT_LINE_ID := l_existing_ppa_lines_rec.RCV_SHIPMENT_LINE_ID;
      --
      ------------------------------------------------------------------------
      debug_info := 'Reverse_Existing_Ppa Step 3. Insert temp PPA Reversal '
                     ||'Line';
      ------------------------------------------------------------------------
      IF (AP_RETRO_PRICING_UTIL_PKG.Create_Line(
              l_ppa_lines_rec,
              current_calling_sequence) <> TRUE) THEN
         --
         IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
             AP_IMPORT_UTILITIES_PKG.Print(
             AP_IMPORT_INVOICES_PKG.g_debug_switch,
             'insert_rejections<- '||current_calling_sequence);
         END IF;
         --
         Raise Ppa_Line_Reversal_failure;
         --
      END IF;

      ----------------------------------------------------------------------
      debug_info := 'Reverse_Existing_Ppa Step 4. Compute PPA Dist Reversal';
      ----------------------------------------------------------------------
      IF (Reverse_Existing_Ppa_Dists(
                  p_instruction_id,
                  l_ppa_lines_rec,
                  l_existing_ppa_lines_rec,
                  current_calling_sequence) <> TRUE) THEN
         --
         IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
             AP_IMPORT_UTILITIES_PKG.Print(
             AP_IMPORT_INVOICES_PKG.g_debug_switch,
             'Reverse_Existing_Ppa_Dists<- '||current_calling_sequence);
         END IF;
         --
         Raise Ppa_Line_Reversal_failure;
         --
      END IF;
      --
   END LOOP;
   --
   ----------------------------------------------------------------------
   debug_info := 'Reverse_Existing_Ppa Step 5. Clear PL/SQL tables';
   ----------------------------------------------------------------------
   l_existing_ppa_lines_list.DELETE;
   --
   RETURN(TRUE);
   --
EXCEPTION
 WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      SQLERRM);
      END IF;
    END IF;
    --
    IF ( existing_ppa_lines%ISOPEN ) THEN
        CLOSE existing_ppa_lines;
    END IF;
    --
    RETURN(FALSE);
    --
END Reverse_Existing_Ppa;


/*=============================================================================
 |  FUNCTION - Create_Zero_Amt_Adj_Line()
 |
 |  DESCRIPTION
 |      This function is used to create zero-amount RetroItem or RetroTax lines
 |  on the original lines to reverse and redistribute all outstanding IPV and
 |  TIPV
 |
 |  PARAMETERS
 |      p_instruction_id
 |      p_created_by
 |      p_correcting
 |      p_lines_rec
 |      p_adj_lines_rec
 |      P_calling_sequence - Calling sequence
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
FUNCTION Create_Zero_Amt_Adj_Line(
           p_instruction_id  IN     NUMBER,
           p_created_by       IN     NUMBER,
           p_correcting       IN     VARCHAR2,
           p_lines_rec        IN     AP_RETRO_PRICING_PKG.invoice_lines_rec_type,
           p_adj_lines_rec       OUT NOCOPY AP_RETRO_PRICING_PKG.invoice_lines_rec_type,
           P_calling_sequence IN     VARCHAR2)
RETURN BOOLEAN IS

l_adj_lines_rec              AP_RETRO_PRICING_PKG.invoice_lines_rec_type;
current_calling_sequence     VARCHAR2(1000);
debug_info                   VARCHAR2(1000);
Zero_Amt_Adj_Line_Failure    EXCEPTION;

BEGIN
   --
   current_calling_sequence := 'AP_RETRO_PRICING_PKG.Create_Zero_Amt_Adj_Line'
                ||P_Calling_Sequence;
   ---------------------------------------------------------------------------
   debug_info := 'Create_Zero_Amt_Adj_Line Step 1. Zero Amt Adj Line';
   ---------------------------------------------------------------------------
   l_adj_lines_rec             := p_lines_rec;
   l_adj_lines_rec.line_number := AP_INVOICES_UTILITY_PKG.get_max_inv_line_num(
                                     p_lines_rec.invoice_id) +
                                  AP_RETRO_PRICING_UTIL_PKG.get_max_ppa_line_num(
                                          p_lines_rec.invoice_id) + 1;
   IF p_correcting = 'IPV' THEN
       l_adj_lines_rec.line_type_lookup_code := 'RETROITEM' ;
	   --'Redistribution of IPV due to Retroactive Pricing of Purchase Order'
	   FND_MESSAGE.SET_NAME('SQLAP', 'AP_RETRO_IPV_REDIST');
	   l_adj_lines_rec.description := FND_MESSAGE.GET;
   ELSE
      l_adj_lines_rec.line_type_lookup_code := 'RETROTAX' ;
	   --'Redistribution of TIPV due to Retroactive Pricing of Purchase Order'
	   FND_MESSAGE.SET_NAME('SQLAP', 'AP_RETRO_TIPV_REDIST');
	   l_adj_lines_rec.description := FND_MESSAGE.GET;
   END IF;
   --
   l_adj_lines_rec.line_source           := 'ADJUSTMENT CORRECTION';
   l_adj_lines_rec.generate_dists        := 'D';
   l_adj_lines_rec.match_type            := 'ADJUSTMENT_CORRECTION';
   --
   l_adj_lines_rec.accounting_date := AP_INVOICES_PKG.get_GL_date(SYSDATE);
   l_adj_lines_rec.period_name     := AP_INVOICES_PKG.get_period_name(
                                          l_adj_lines_rec.accounting_date);
   --
   l_adj_lines_rec.amount                := 0;
   l_adj_lines_rec.base_amount           := 0;
   l_adj_lines_rec.rounding_amt          := 0;
   l_adj_lines_rec.quantity_invoiced     := NULL;
   l_adj_lines_rec.unit_meas_lookup_code := NULL;
   l_adj_lines_rec.unit_price            := NULL;
   l_adj_lines_rec.wfapproval_status     := 'NOT_REQUIRED';
   l_adj_lines_rec.corrected_inv_id      := p_lines_rec.invoice_id;
   l_adj_lines_rec.corrected_line_number := p_lines_rec.line_number;
   l_adj_lines_rec.pa_quantity           := NULL;
   l_adj_lines_rec.creation_date         := SYSDATE;
   l_adj_lines_rec.created_by            := p_created_by;
   l_adj_lines_rec.instruction_id       := p_instruction_id;
   l_adj_lines_rec.adj_type              := 'ADJ';
   --
   --Create reversal PPA Line for the existing PPA
   ---------------------------------------------------------------------------
   debug_info := 'Create_Zero_Amt_Adj_Line Step 2. Insert the Adj Line in '
                 ||'the Global Temp Table';
   ----------------------------------------------------------------------------
   IF (AP_RETRO_PRICING_UTIL_PKG.Create_Line(
            l_adj_lines_rec,
            current_calling_sequence) <> TRUE) THEN
     --
     IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch,
             'Create_Line<- '||current_calling_sequence);
     END IF;
     --
     Raise Zero_Amt_Adj_Line_Failure;
     --
   END IF;
   --
   p_adj_lines_rec := l_adj_lines_rec;
   --
   RETURN (TRUE);
   --
EXCEPTION
 WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      SQLERRM);
      END IF;
    END IF;

    RETURN(FALSE);

END Create_Zero_Amt_Adj_Line;


/*============================================================================
 |  FUNCTION - Create_Adjustment_Corrections()
 |
 |  DESCRIPTION
 |     This function is called in context of PC Line for the following type
 |     of lines --
 |     1. Zero Amount RetroItem line that adjusts the  the price correction
 |        line
 |     2. Zero Amount RetroTax Lines that adjust the Tax lines allocated to
 |        the PC Line
 |
 |     The function reverses the RetroExpense(NonRecoverable Tax) associated
 |     with the Zero Amount RetoItem(RetroTax) line on the Original Invoice.
 |     The function also reverses the associated ERV(If Any?) with the
 |     RetroItem and RetrTax Lines.
 |
 |  NOTE: ERV and Base Amount Calculations for the Adjustment Correction
 |        Lines are not during validation process. However for the Po Price
 |        Adjustment Lines on the PPA Doc the ERV and Base Amount
 |        Calculations are done during the Validation Process.
 |
 |  PARAMETERS
 |      p_base_currency_code
 |      p_instruction_id
 |      p_ppa_invoice_rec
 |      p_instruction_lines_rec
 |      p_lines_rec
 |      P_calling_sequence - Calling sequence
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *==========================================================================*/
FUNCTION Create_Adjustment_Corrections(
            p_ppa_invoice_rec       IN AP_RETRO_PRICING_PKG.invoice_rec_type,
            p_base_currency_code    IN VARCHAR2,
            p_adj_lines_rec         IN AP_RETRO_PRICING_PKG.invoice_lines_rec_type,
            P_calling_sequence      IN VARCHAR2)
RETURN BOOLEAN IS


CURSOR adj_corr_dists IS
SELECT  accounting_date,
        accrual_posted_flag,
        amount,
        asset_book_type_code,
        asset_category_id,
        assets_addition_flag,
        assets_tracking_flag,
        attribute_category,
        attribute1,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        award_id,
        awt_flag,
        awt_group_id,
        awt_tax_rate_id,
        base_amount,
        batch_id,
        cancellation_flag,
        cash_posted_flag,
        corrected_invoice_dist_id,
        corrected_quantity,
        country_of_supply,
        created_by,
        description,
        dist_code_combination_id,
        dist_match_type,
        distribution_class,
        distribution_line_number,
        encumbered_flag,
        expenditure_item_date,
        expenditure_organization_id,
        expenditure_type,
        final_match_flag,
        global_attribute_category,
        global_attribute1,
        global_attribute10,
        global_attribute11,
        global_attribute12,
        global_attribute13,
        global_attribute14,
        global_attribute15,
        global_attribute16,
        global_attribute17,
        global_attribute18,
        global_attribute19,
        global_attribute2,
        global_attribute20,
        global_attribute3,
        global_attribute4,
        global_attribute5,
        global_attribute6,
        global_attribute7,
        global_attribute8,
        global_attribute9,
        income_tax_region,
        inventory_transfer_status,
        invoice_distribution_id,
        invoice_id,
        invoice_line_number,
        line_type_lookup_code,
        match_status_flag,
        matched_uom_lookup_code,
        merchant_document_number,
        merchant_name,
        merchant_reference,
        merchant_tax_reg_number,
        merchant_taxpayer_id,
        org_id,
        pa_addition_flag,
        pa_quantity,
        period_name,
        po_distribution_id,
        posted_flag,
        project_id,
        quantity_invoiced,
        rcv_transaction_id,
        related_id,
        reversal_flag,
        rounding_amt,
        set_of_books_id,
        task_id,
        type_1099,
        unit_price,
        instruction_id,          --instruction_id
        NULL,                       --charge_applicable_dist_id
        INTENDED_USE,
        WITHHOLDING_TAX_CODE_ID,
        PROJECT_ACCOUNTING_CONTEXT,
        REQ_DISTRIBUTION_ID,
        REFERENCE_1,
        REFERENCE_2,
        NULL,                   -- line_group_number
        PA_CC_AR_INVOICE_ID,
        PA_CC_AR_INVOICE_LINE_NUM,
        PA_CC_PROCESSED_CODE,
	pay_awt_group_id  --bug6817107
FROM   ap_ppa_invoice_dists_gt
WHERE  invoice_id =  p_adj_lines_rec.invoice_id
AND    invoice_line_number = p_adj_lines_rec.line_number
AND    line_type_lookup_code IN ('RETROEXPENSE', 'RETROACCRUAL', 'ERV')
ORDER BY invoice_distribution_id;

l_ppa_lines_rec            AP_RETRO_PRICING_PKG.invoice_lines_rec_type;
l_ppa_invoice_dists_list   AP_RETRO_PRICING_PKG.invoice_dists_list_type;
l_adj_dists_list           AP_RETRO_PRICING_PKG.invoice_dists_list_type;

i                              INTEGER;
l_dist_total                   NUMBER;
l_line_amount                  NUMBER  := 0;  --bug#9573078
l_line_base_amount             NUMBER  := 0;  --bug#9573078

current_calling_sequence       VARCHAR2(1000);
debug_info                     VARCHAR2(1000);
Adj_Correction_Lines_Failure EXCEPTION;

BEGIN
   --
   current_calling_sequence :=
      'AP_RETRO_PRICING_PKG.Create_Adjustment_Corrections'||P_Calling_Sequence;
   --
   ---------------------------------------------------------------------------
    debug_info := 'Create_Adjustment_Corrections Step 1. Compute Adj Corr Line ';
   ---------------------------------------------------------------------------
   -- Compute PPA Line
   l_ppa_lines_rec := p_adj_lines_rec;
   l_ppa_lines_rec.invoice_id := p_ppa_invoice_rec.invoice_id;
   l_ppa_lines_rec.line_number  := AP_RETRO_PRICING_UTIL_PKG.get_max_ppa_line_num(
                                                    p_ppa_invoice_rec.invoice_id) + 1;
   l_ppa_lines_rec.corrected_inv_id := p_adj_lines_rec.invoice_id;
   l_ppa_lines_rec.corrected_line_number := p_adj_lines_rec.line_number;
   --
   ----------------------------------------------------------------------------
   debug_info := 'Create_Adjustment_Corrections Step 2. Insert the Adj Line in the'
                  ||' Global Temp Table';
   ----------------------------------------------------------------------------
   IF (AP_RETRO_PRICING_UTIL_PKG.Create_Line(
           l_ppa_lines_rec,
           current_calling_sequence) <> TRUE) THEN
      --
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,
          'insert_rejections<- '||current_calling_sequence);
      END IF;
      --
      Raise Adj_Correction_Lines_Failure;
      --
   END IF;
   ----------------------------------------------------------------------------
   debug_info := 'Create_Adjustment_Corrections Step 3. Open cursor adj_corr_dists';
   ----------------------------------------------------------------------------
   OPEN adj_corr_dists;
   FETCH adj_corr_dists
   BULK COLLECT INTO l_adj_dists_list;
   CLOSE adj_corr_dists;
   --
   ----------------------------------------------------------------------------
   debug_info := 'Create_Adjustment_Corrections Step 4. Compute PPA Adjustment Dists';
   ----------------------------------------------------------------------------
   FOR i IN 1..l_adj_dists_list.COUNT
   LOOP
       l_ppa_invoice_dists_list(i) := l_adj_dists_list(i);
       --
       l_ppa_invoice_dists_list(i).invoice_id := l_ppa_lines_rec.invoice_id;
       l_ppa_invoice_dists_list(i).invoice_line_number := l_ppa_lines_rec.line_number;
      -- l_ppa_invoice_dists_list(i).invoice_distribution_id := AP_RETRO_PRICING_UTIL_PKG.get_invoice_distribution_id;
       l_ppa_invoice_dists_list(i).invoice_distribution_id := Null;
       l_ppa_invoice_dists_list(i).distribution_line_number := i;
       l_ppa_invoice_dists_list(i).amount       := (-1)*l_adj_dists_list(i).amount;
       l_ppa_invoice_dists_list(i).base_amount  := (-1)*l_adj_dists_list(i).base_amount;
       l_ppa_invoice_dists_list(i).rounding_amt := (-1)*l_adj_dists_list(i).rounding_amt;
       l_ppa_invoice_dists_list(i).match_status_flag := NULL;  --bug#9573078
       l_ppa_invoice_dists_list(i).encumbered_flag   := 'N';   --bug#9573078
       --
       l_line_amount      := l_line_amount + l_ppa_invoice_dists_list(i).amount;
       l_line_base_amount := l_line_base_amount + l_ppa_invoice_dists_list(i).base_amount;
       --
   END LOOP;
   --
   l_ppa_lines_rec.amount := l_line_amount;
   l_ppa_lines_rec.base_amount := l_line_base_amount;

   ----------------------------------------------------------------------------
   debug_info := 'Create_Adjustment_Corrections Step 5. Insert the Adj Dists in the'
                  ||' Global Temp Table';
   ----------------------------------------------------------------------------
    FORALL i IN 1..l_ppa_invoice_dists_list.COUNT
         INSERT INTO ap_ppa_invoice_dists_gt values  l_ppa_invoice_dists_list(i);

   ----------------------------------------------------------------------------
   debug_info := 'Create_Adjustment_Corrections Step 6. Update Related Id';
   ----------------------------------------------------------------------------
     UPDATE ap_ppa_invoice_dists_gt  d1
        SET related_id = invoice_distribution_id
      WHERE invoice_id = l_ppa_lines_rec.invoice_id
        AND invoice_line_number = l_ppa_lines_rec.line_number
        AND related_id = ( SELECT related_id
                             FROM ap_ppa_invoice_dists_gt d2
                            WHERE d1.related_id = d2.related_id
                              AND line_type_lookup_code = 'ERV');


      --Introduced below UPDATE for bug#9573078

      UPDATE ap_ppa_invoice_lines_gt l1
        SET amount = l_ppa_lines_rec.amount,
            base_amount = l_ppa_lines_rec.base_amount
      WHERE invoice_id = l_ppa_lines_rec.invoice_id
        AND line_number = l_ppa_lines_rec.line_number;

   -------------------------------------------------------------------------
   debug_info := 'Create_Adjustment_Corrections Step 7. Clear PL/SQL tables';
   -------------------------------------------------------------------------
   l_ppa_invoice_dists_list.DELETE;
   l_adj_dists_list.DELETE;
   --
   RETURN(TRUE);


RETURN(TRUE);

EXCEPTION
 WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;
    --
    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      SQLERRM);
      END IF;
    END IF;
    --
    IF ( adj_corr_dists%ISOPEN ) THEN
        CLOSE adj_corr_dists;
    END IF;
    --
    RETURN(FALSE);

END Create_Adjustment_Corrections;


/*=============================================================================
 |  FUNCTION - Reverse_Redistribute_IPV()
 |
 |  DESCRIPTION
 |        This program is called from Process_Retroprice_Adjustments for every
 |  the Base Matched( or a price correction or quantity correction line) that
 |  has not been retro adjusted. This procedure creates a zero amount PPA
 |  correction adjustment line . Distributions are created in the Temp tables
 |  such that there are no net charges to the IPV A/c. If the original line had
 |  ERV then the IPV amount is redistributed to the charge a/c and the ERV a/c.
 |
 |
 |  PARAMETERS
 |      p_base_currency_code
 |      p_instruction_id
 |      p_created_by
 |      p_lines_rec
 |      p_adj_lines_rec     --OUT
 |      p_erv_dists_exist   --OUT
 |      P_calling_sequence  --Calling sequence
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
FUNCTION Reverse_Redistribute_IPV(
            p_ppa_invoice_rec    IN AP_RETRO_PRICING_PKG.invoice_rec_type,
            p_base_currency_code IN VARCHAR2,
            p_instruction_id     IN NUMBER,
            p_created_by         IN NUMBER,
            p_lines_rec          IN AP_RETRO_PRICING_PKG.invoice_lines_rec_type,
            p_erv_dists_exist       OUT NOCOPY VARCHAR2,
            P_calling_sequence   IN VARCHAR2)
RETURN BOOLEAN IS

CURSOR ipv_dists(
         c_rows        NUMBER) IS
SELECT  aid1.accounting_date,
        aid1.accrual_posted_flag,
        aid1.amount,
        aid1.asset_book_type_code,
        aid1.asset_category_id,
        aid1.assets_addition_flag,
        aid1.assets_tracking_flag,
        aid1.attribute_category,
        aid1.attribute1,
        aid1.attribute10,
        aid1.attribute11,
        aid1.attribute12,
        aid1.attribute13,
        aid1.attribute14,
        aid1.attribute15,
        aid1.attribute2,
        aid1.attribute3,
        aid1.attribute4,
        aid1.attribute5,
        aid1.attribute6,
        aid1.attribute7,
        aid1.attribute8,
        aid1.attribute9,
        aid1.award_id,
        aid1.awt_flag,
        aid1.awt_group_id,
        aid1.awt_tax_rate_id,
        aid1.base_amount,
        aid1.batch_id,
        aid1.cancellation_flag,
        aid1.cash_posted_flag,
        aid1.corrected_invoice_dist_id,
        aid1.corrected_quantity,
        aid1.country_of_supply,
        aid1.created_by,
        aid1.description,
        aid1.dist_code_combination_id,
        aid1.dist_match_type,
        aid1.distribution_class,
        aid1.distribution_line_number,
        aid1.encumbered_flag,
        aid1.expenditure_item_date,
        aid1.expenditure_organization_id,
        aid1.expenditure_type,
        aid1.final_match_flag,
        aid1.global_attribute_category,
        aid1.global_attribute1,
        aid1.global_attribute10,
        aid1.global_attribute11,
        aid1.global_attribute12,
        aid1.global_attribute13,
        aid1.global_attribute14,
        aid1.global_attribute15,
        aid1.global_attribute16,
        aid1.global_attribute17,
        aid1.global_attribute18,
        aid1.global_attribute19,
        aid1.global_attribute2,
        aid1.global_attribute20,
        aid1.global_attribute3,
        aid1.global_attribute4,
        aid1.global_attribute5,
        aid1.global_attribute6,
        aid1.global_attribute7,
        aid1.global_attribute8,
        aid1.global_attribute9,
        aid1.income_tax_region,
        aid1.inventory_transfer_status,
        aid1.invoice_distribution_id,
        aid1.invoice_id,
        aid1.invoice_line_number,
        aid1.line_type_lookup_code,
        aid1.match_status_flag,
        aid1.matched_uom_lookup_code,
        aid1.merchant_document_number,
        aid1.merchant_name,
        aid1.merchant_reference,
        aid1.merchant_tax_reg_number,
        aid1.merchant_taxpayer_id,
        aid1.org_id,
        aid1.pa_addition_flag,
        aid1.pa_quantity,
        aid1.period_name,
        aid1.po_distribution_id,
        aid1.posted_flag,
        aid1.project_id,
        aid1.quantity_invoiced,
        aid1.rcv_transaction_id,
        aid1.related_id,
        aid1.reversal_flag,
        aid1.rounding_amt,
        aid1.set_of_books_id,
        aid1.task_id,
        aid1.type_1099,
        aid1.unit_price,
        p_instruction_id,        --instruction_id
        NULL,                      --charge_applicable_to_dist_id
        aid1.INTENDED_USE,
        aid1.WITHHOLDING_TAX_CODE_ID,
        aid1.PROJECT_ACCOUNTING_CONTEXT,
        aid1.REQ_DISTRIBUTION_ID,
        aid1.REFERENCE_1,
        aid1.REFERENCE_2,
        NULL,                   -- line_group_number
        aid1.PA_CC_AR_INVOICE_ID,
        aid1.PA_CC_AR_INVOICE_LINE_NUM,
        aid1.PA_CC_PROCESSED_CODE,
	aid1.pay_awt_group_id   --bug6817107
 FROM   ap_invoice_distributions_all aid1,
        (SELECT rownum r FROM ap_invoice_distributions_all  WHERE ROWNUM <= c_rows) aid2
 WHERE  aid1.invoice_id =  p_lines_rec.invoice_id
 AND    aid1.invoice_line_number = p_lines_rec.line_number
 AND    aid2.r <= c_rows
 AND    aid1.line_type_lookup_code = 'IPV'
 AND    NVL(aid1.cancellation_flag, 'N' ) <> 'Y'
 AND    NVL( aid1.reversal_flag, 'N' ) <> 'Y'
 AND    NOT EXISTS (SELECT 1
                    FROM ap_invoice_distributions_all  aid3
                    WHERE aid3.corrected_invoice_dist_id = aid1.invoice_distribution_id
                    AND aid3.line_type_lookup_code IN ('RETROACCRUAL', 'RETROEXPENSE')
                    );
 -- Distribution should not have been Adjusted by prior PPA's. Adjustment
 -- Corr is done once. However the PO price adjustment will be done
 -- w.r.t modified PO unit price.

l_adj_lines_rec            AP_RETRO_PRICING_PKG.invoice_lines_rec_type;
l_adj_dists_list           AP_RETRO_PRICING_PKG.invoice_dists_list_type;
l_ipv_dists_list           AP_RETRO_PRICING_PKG.invoice_dists_list_type;
l_ipv_dists_exist          VARCHAR2(1);

l_rows                     NUMBER;
l_po_exchange_rate         NUMBER;
l_rcv_exchange_rate        NUMBER;
l_original_exchange_rate   NUMBER;
i                          INTEGER;
l_correcting               VARCHAR2(5) := 'IPV';

current_calling_sequence   VARCHAR2(1000);
debug_info                 VARCHAR2(1000);
Reverse_Redist_IPV_FAILURE    EXCEPTION;

BEGIN

   current_calling_sequence := 'AP_RETRO_PRICING_PKG.Reverse_Redistribute_IPV'
                ||P_Calling_Sequence;
   ---------------------------------------------------------------------------
   debug_info := 'Reverse_Redistribute_IPV Step 1. Compute Zero Amt Adj Line';
   ---------------------------------------------------------------------------
   --

   IF (Create_Zero_Amt_Adj_Line(
              p_instruction_id,
              p_created_by,
              l_correcting,
              p_lines_rec,
              l_adj_lines_rec,    --OUT
              current_calling_sequence) <> TRUE) THEN
      --
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   'Create_Zero_Amt_Adj_Line<- '||current_calling_sequence);
      END IF;
      --
      Raise Reverse_Redist_IPV_FAILURE;
      --
   END IF;
   --
   ---------------------------------------------------------------------------
   debug_info := 'Reverse_Redistribute_IPV Step 2. Get Exchange rate for the '
                  ||'Original Invoice';
   ---------------------------------------------------------------------------
   SELECT NVL(exchange_rate, 1)
     INTO l_original_exchange_rate
     FROM ap_invoices_all
    WHERE invoice_id = p_lines_rec.invoice_id;

   --------------------------------------------------------------------------
   debug_info := 'Reverse_Redistribute_IPV Step 3. Check IF Erv Dists Exist';
   --------------------------------------------------------------------------
   IF (AP_RETRO_PRICING_UTIL_PKG.Erv_Dists_exists(
          p_lines_rec.invoice_id,
          p_lines_rec.line_number,
          p_erv_dists_exist) <> TRUE) THEN
      --
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,
          'Erv_Dists_exists<- '||current_calling_sequence);
      END IF;
      --
      Raise Reverse_Redist_IPV_FAILURE;
      --
   END IF;
   --

   IF p_erv_dists_exist = 'Y' THEN
      l_rows := 3;
   ELSE
      l_rows := 2;
   END IF;
   --
   ---------------------------------------------------------------------------
   debug_info := 'Reverse_Redistribute_IPV Step 4. Open cursor ipv_dists_list';
   ---------------------------------------------------------------------------
   OPEN ipv_dists(
          l_rows);
    FETCH ipv_dists
    BULK COLLECT INTO l_ipv_dists_list;
    CLOSE ipv_dists;

   ---------------------------------------------------------------------------
   debug_info := 'Reverse_Redistribute_IPV Step 5. Redistribute IPV due to '
                  ||'Retropricing';
   ----------------------------------------------------------------------------
    i :=1;
    WHILE i <= (l_ipv_dists_list.COUNT  - l_rows + 1)
    LOOP

      --------------------
      --IPV Dist
      --------------------
      --IPV Adj Dist copies Existing IPV Dist
      l_adj_dists_list(i) := l_ipv_dists_list(i);
      l_adj_dists_list(i).invoice_id :=  l_adj_lines_rec.invoice_id;
      l_adj_dists_list(i).invoice_line_number := l_adj_lines_rec.line_number;
      --l_adj_dists_list(i).invoice_distribution_id := AP_RETRO_PRICING_UTIL_PKG.get_invoice_distribution_id;
      l_adj_dists_list(i).invoice_distribution_id := Null;
      l_adj_dists_list(i).distribution_line_number := i;
      l_adj_dists_list(i).line_type_lookup_code    := 'IPV';
      l_adj_dists_list(i).dist_match_type           := 'ADJUSTMENT_CORRECTION';

     --'Reversal of IPV due to Retroactive Pricing of Purchase Order'
      FND_MESSAGE.SET_NAME('SQLAP', 'AP_RETRO_IPV_REVERSAL');
      l_adj_dists_list(i).description := FND_MESSAGE.GET;

      l_adj_dists_list(i).dist_code_combination_id := l_ipv_dists_list(i).dist_code_combination_id;

      l_adj_dists_list(i).accounting_date := SYSDATE;
      l_adj_dists_list(i).period_name := l_adj_lines_rec.period_name;

      l_adj_dists_list(i).amount       := (-1)*l_ipv_dists_list(i).amount;
      l_adj_dists_list(i).base_amount  := (-1)*l_ipv_dists_list(i).base_amount;
      l_adj_dists_list(i).rounding_amt := (-1)*l_ipv_dists_list(i).rounding_amt;

      l_adj_dists_list(i).posted_flag         := 'N';
      l_adj_dists_list(i).cash_posted_flag    := 'N';
      l_adj_dists_list(i).accrual_posted_flag := 'N';

      --Following fields will be NULL as we do not select it.
      --accounting_event_id
      --upgrade_posted_amount

      l_adj_dists_list(i).created_by := l_adj_lines_rec.created_by;

      l_adj_dists_list(i).related_id  := l_ipv_dists_list(i).related_id;
      l_adj_dists_list(i).corrected_invoice_dist_id := l_ipv_dists_list(i).invoice_distribution_id;
      l_adj_dists_list(i).unit_price := (-1)*l_ipv_dists_list(i).unit_price;
      l_adj_dists_list(i).match_status_flag  := l_ipv_dists_list(i).match_status_flag; -- Bug 549166
      l_adj_dists_list(i).encumbered_flag    := 'N';

      -- Bug 5509712. Comment out following line
      l_adj_dists_list(i).po_distribution_id := l_ipv_dists_list(i).po_distribution_id;
      l_adj_dists_list(i).rcv_transaction_id := l_ipv_dists_list(i).rcv_transaction_id  ;

      --l_adj_dists_list(i).po_distribution_id := NULL;
      --l_adj_dists_list(i).rcv_transaction_id := NULL;

       -- Start of bug# 9504423
       IF l_adj_dists_list(i).project_id IS NOT NULL THEN
         l_adj_dists_list(i).pa_Addition_flag := 'N';
       ELSE
         l_adj_dists_list(i).pa_Addition_flag := 'E';
       END IF;
      --End bug#9504423


      ---------------
      -- Expense Dist
      ---------------
      l_adj_dists_list(i+1)   := l_adj_dists_list(i);
      --l_adj_dists_list(i+1).invoice_distribution_id := AP_RETRO_PRICING_UTIL_PKG.get_invoice_distribution_id;
      l_adj_dists_list(i+1).invoice_distribution_id := Null;
      l_adj_dists_list(i+1).distribution_line_number := i+1;
      --
      IF p_lines_rec.match_type = 'PRICE_CORRECTION' THEN
         l_adj_dists_list(i+1).line_type_lookup_code := AP_RETRO_PRICING_UTIL_PKG.get_dist_type_lookup_code(
                                                        l_ipv_dists_list(i).corrected_invoice_dist_id);
         l_adj_dists_list(i+1).dist_code_combination_id :=
                AP_RETRO_PRICING_UTIL_PKG.get_ccid(l_ipv_dists_list(i).corrected_invoice_dist_id);

      ELSE --p_lines_rec.match_type IN ('ITEM_TO_PO', 'ITEM_TO_RECEIPT', 'QTY_CORRECTION') THEN
         l_adj_dists_list(i+1).line_type_lookup_code := AP_RETRO_PRICING_UTIL_PKG.get_dist_type_lookup_code(
                                                            l_ipv_dists_list(i).related_id);
         l_adj_dists_list(i+1).dist_code_combination_id :=
                  AP_RETRO_PRICING_UTIL_PKG.get_ccid(l_ipv_dists_list(i).related_id);
         --
      END IF;
      --
      l_adj_dists_list(i+1).amount      := l_ipv_dists_list(i).amount;
      l_adj_dists_list(i+1).base_amount :=
            AP_UTILITIES_PKG.ap_round_currency(
                   l_ipv_dists_list(i+1).amount*l_original_exchange_rate,
                   p_base_currency_code);

      l_adj_dists_list(i+1).rounding_amt := l_ipv_dists_list(i).rounding_amt;

      IF (l_rows = 3) THEN
         l_adj_dists_list(i+1).related_id := l_adj_dists_list(i+1).invoice_distribution_id;
      ELSE
         l_adj_dists_list(i+1).related_id := NULL;
      END IF;

    --  l_adj_dists_list(i+1).corrected_invoice_dist_id := l_ipv_dists_list(i).invoice_distribution_id;

      l_adj_dists_list(i+1).unit_price := l_ipv_dists_list(i).unit_price;

      -- Bug 5509712
      l_adj_dists_list(i+1).po_distribution_id := l_ipv_dists_list(i).po_distribution_id;
      l_adj_dists_list(i+1).rcv_transaction_id := l_ipv_dists_list(i).rcv_transaction_id  ;

      -------------
      --ERV Dist
      -------------
      --  Only if the base invoice has ERV create the Erv Dist
      IF l_rows=3 THEN
         l_adj_dists_list(i+2)   :=  l_adj_dists_list(i+1);
         --l_adj_dists_list(i+2).invoice_distribution_id := AP_RETRO_PRICING_UTIL_PKG.get_invoice_distribution_id;
         l_adj_dists_list(i+2).invoice_distribution_id := Null;
         l_adj_dists_list(i+2).distribution_line_number := i+2;

         l_adj_dists_list(i+2).line_type_lookup_code   := 'ERV';

          -- automatically set by assignment of line 2.
         --l_adj_dists_list(i+2).related_id := l_adj_dists_list(i+1).invoice_distribution_id; --or related_dist_id

         l_adj_dists_list(i+2).amount  :=  0;
         --
         IF (p_lines_rec.rcv_transaction_id IS NOT NULL) THEN
            l_rcv_exchange_rate := AP_RETRO_PRICING_UTIL_PKG.get_exchange_rate(
                                      'RECEIPT',
                                      p_lines_rec.rcv_transaction_id);
            l_adj_dists_list(i+2).base_amount :=
                AP_UTILITIES_PKG.ap_round_currency(
                    l_ipv_dists_list(i+2).amount*(l_original_exchange_rate - l_rcv_exchange_rate),
                    p_base_currency_code);
         ELSE
            l_po_exchange_rate  := AP_RETRO_PRICING_UTIL_PKG.get_exchange_rate(
                                      'PO',
                                      p_lines_rec.po_header_id);
            l_adj_dists_list(i+2).base_amount :=
                AP_UTILITIES_PKG.ap_round_currency(
                    l_ipv_dists_list(i+2).base_amount*(l_original_exchange_rate - l_po_exchange_rate),
                    p_base_currency_code);
         END IF;
         -- Adjust Expense Dist Amount

         l_adj_dists_list(i+2).rounding_amt := 0;

         l_adj_dists_list(i+2).dist_code_combination_id := AP_RETRO_PRICING_UTIL_PKG.get_erv_ccid(
                                                                   l_adj_dists_list(i+2).corrected_invoice_dist_id);
        -- l_adj_dists_list(i+2).corrected_invoice_dist_id := l_ipv_dists_list(i).invoice_distribution_id;
         l_adj_dists_list(i+2).unit_price := NULL;

          -- Bug 5509712
         l_adj_dists_list(i+2).po_distribution_id := l_ipv_dists_list(i).po_distribution_id;
         l_adj_dists_list(i+2).rcv_transaction_id := l_ipv_dists_list(i).rcv_transaction_id  ;

         --
      END IF;
      --
      i:=i+ l_rows;  --loop counter
      --
     END LOOP;

     -------------------------------------------------------------------------
     debug_info := 'Reverse_Redistribute_IPV Step 6. Insert the Adj Dists in '
                    ||'the Global Temp Table ';
     -------------------------------------------------------------------------
     FORALL i IN 1..l_adj_dists_list.COUNT
          INSERT INTO ap_ppa_invoice_dists_gt values  l_adj_dists_list(i);
     --

     -------------------------------------------------------------------------
     debug_info := 'Reverse_Redistribute_IPV Step 7. Clear PL/SQL tables';
     -------------------------------------------------------------------------
     l_ipv_dists_list.DELETE;
     l_adj_dists_list.DELETE;

     -------------------------------------------------------------------------
     debug_info := 'Reverse_Redistribute_IPV Step 8. Reverse outstanding price'
                   ||' correction';
     -------------------------------------------------------------------------
     IF p_lines_rec.match_type = 'PRICE_CORRECTION' THEN
        --
        IF (Create_Adjustment_Corrections(
                    p_ppa_invoice_rec,
                    p_base_currency_code,
                    l_adj_lines_rec,
                    current_calling_sequence) <> TRUE) THEN
          --
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
              AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'Create_Adjustment_Corrections<- '||current_calling_sequence);
          END IF;
          --
          Raise Reverse_Redist_IPV_FAILURE;
        END IF;
        --
     END IF;

RETURN (TRUE);

EXCEPTION
 WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      SQLERRM);
      END IF;
    END IF;
    --
    IF ( ipv_dists%ISOPEN ) THEN
        CLOSE ipv_dists;
    END IF;
    --
    RETURN(FALSE);
    --
END Reverse_Redistribute_IPV;

/*=============================================================================
 |  FUNCTION - Reverse_Redistribute_TIPV()
 |
 |  DESCRIPTION
 |           This program is called from Process_TIPV_Reversal for every
 |  Tax line that is matched to original line that has not been retro-adjusted.
 |  This procedure creates a zero amount Tax adjustment line . Distributions
 |  are created in the Temp tables such that there are no net charges to the
 |  TIPV A/c. If the tax line has a TERV then the TIPV amount is redistributed
 |  to the nonrecoverable charge a/c and the TERV a/c.
 |
 |  Note: Payables only support Exclusive Tax for PO Matched Invoices and as a
 |        consequence TIPV distributions exist only for Tax Lines that are
 |        allocated to the original line
 |
 |  PARAMETERS
 |      p_base_currency_code
 |      p_instruction_id
 |      p_created_by
 |      p_original_exchange_rate
 |      p_lines_rec
 |      p_tax_lines_rec
 |      p_erv_dists_exist
 |      P_calling_sequence - Calling sequence
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
FUNCTION Reverse_Redistribute_TIPV(
            p_ppa_invoice_rec        IN AP_RETRO_PRICING_PKG.invoice_rec_type,
            p_base_currency_code     IN VARCHAR2,
            p_instruction_id         IN NUMBER,
            p_created_by             IN NUMBER,
            p_original_exchange_rate IN NUMBER,
            p_lines_rec              IN AP_RETRO_PRICING_PKG.invoice_lines_rec_type,
            p_tax_lines_rec          IN AP_RETRO_PRICING_PKG.invoice_lines_rec_type,
            P_calling_sequence       IN VARCHAR2)
RETURN BOOLEAN IS

CURSOR tipv_dists(
         c_rows                IN   NUMBER) IS
SELECT  aid1.accounting_date,
        aid1.accrual_posted_flag,
        aid1.amount,
        aid1.asset_book_type_code,
        aid1.asset_category_id,
        aid1.assets_addition_flag,
        aid1.assets_tracking_flag,
        aid1.attribute_category,
        aid1.attribute1,
        aid1.attribute10,
        aid1.attribute11,
        aid1.attribute12,
        aid1.attribute13,
        aid1.attribute14,
        aid1.attribute15,
        aid1.attribute2,
        aid1.attribute3,
        aid1.attribute4,
        aid1.attribute5,
        aid1.attribute6,
        aid1.attribute7,
        aid1.attribute8,
        aid1.attribute9,
        aid1.award_id,
        aid1.awt_flag,
        aid1.awt_group_id,
        aid1.awt_tax_rate_id,
        aid1.base_amount,
        aid1.batch_id,
        aid1.cancellation_flag,
        aid1.cash_posted_flag,
        aid1.corrected_invoice_dist_id,
        aid1.corrected_quantity,
        aid1.country_of_supply,
        aid1.created_by,
        aid1.description,
        aid1.dist_code_combination_id,
        aid1.dist_match_type,
        aid1.distribution_class,
        aid1.distribution_line_number,
        aid1.encumbered_flag,
        aid1.expenditure_item_date,
        aid1.expenditure_organization_id,
        aid1.expenditure_type,
        aid1.final_match_flag,
        aid1.global_attribute_category,
        aid1.global_attribute1,
        aid1.global_attribute10,
        aid1.global_attribute11,
        aid1.global_attribute12,
        aid1.global_attribute13,
        aid1.global_attribute14,
        aid1.global_attribute15,
        aid1.global_attribute16,
        aid1.global_attribute17,
        aid1.global_attribute18,
        aid1.global_attribute19,
        aid1.global_attribute2,
        aid1.global_attribute20,
        aid1.global_attribute3,
        aid1.global_attribute4,
        aid1.global_attribute5,
        aid1.global_attribute6,
        aid1.global_attribute7,
        aid1.global_attribute8,
        aid1.global_attribute9,
        aid1.income_tax_region,
        aid1.inventory_transfer_status,
        aid1.invoice_distribution_id,
        aid1.invoice_id,
        aid1.invoice_line_number,
        aid1.line_type_lookup_code,
        aid1.match_status_flag,
        aid1.matched_uom_lookup_code,
        aid1.merchant_document_number,
        aid1.merchant_name,
        aid1.merchant_reference,
        aid1.merchant_tax_reg_number,
        aid1.merchant_taxpayer_id,
        aid1.org_id,
        aid1.pa_addition_flag,
        aid1.pa_quantity,
        aid1.period_name,
        aid1.po_distribution_id,
        aid1.posted_flag,
        aid1.project_id,
        aid1.quantity_invoiced,
        aid1.rcv_transaction_id,
        aid1.related_id,
        aid1.reversal_flag,
        aid1.rounding_amt,
        aid1.set_of_books_id,
        aid1.task_id,
        aid1.type_1099,
        aid1.unit_price,
        p_instruction_id,        --instruction_id
        aid1.charge_applicable_to_dist_id,
        aid1.INTENDED_USE,
        aid1.WITHHOLDING_TAX_CODE_ID,
        aid1.PROJECT_ACCOUNTING_CONTEXT,
        aid1.REQ_DISTRIBUTION_ID,
        aid1.REFERENCE_1,
        aid1.REFERENCE_2,
        NULL,                   -- line_group_number
        aid1.PA_CC_AR_INVOICE_ID,
        aid1.PA_CC_AR_INVOICE_LINE_NUM,
        aid1.PA_CC_PROCESSED_CODE,
	aid1.pay_awt_group_id --bugu6817107
 FROM   ap_invoice_distributions_all aid1,
        (SELECT rownum r FROM ap_invoice_distributions_all  WHERE ROWNUM <= c_rows) aid2
 WHERE  aid1.invoice_id =  p_tax_lines_rec.invoice_id
 AND    aid1.invoice_line_number = p_tax_lines_rec.line_number
 AND    aid2.r <= c_rows
 AND    aid1.line_type_lookup_code = 'TIPV'
 AND    NVL(aid1.cancellation_flag, 'N' ) <> 'Y'
 AND    NVL( aid1.reversal_flag, 'N' ) <> 'Y'
 AND    NOT EXISTS (SELECT 1
                      FROM ap_invoice_distributions_all  aid3
                     WHERE aid3.corrected_invoice_dist_id = aid1.invoice_distribution_id
                       AND aid3.line_type_lookup_code IN ('RETROTAX'))
 AND   aid1.charge_applicable_to_dist_id IN
	                (SELECT invoice_distribution_id
	                   FROM ap_invoice_distributions_all
	                  WHERE invoice_id  = p_lines_rec.invoice_id
                       --Bug5485084 replaced p_tax_lines_rec with p_lines_rec
	                    AND invoice_line_number = p_lines_rec.line_number);
 -- Distribution should not have been Adjusted by prior PPA's. Adjustment
 -- Corr is done once.
l_tipv_adj_lines_rec       AP_RETRO_PRICING_PKG.invoice_lines_rec_type;
l_tipv_adj_dists_list      AP_RETRO_PRICING_PKG.invoice_dists_list_type;
l_tipv_dists_list          AP_RETRO_PRICING_PKG.invoice_dists_list_type;
l_terv_ccid       AP_INVOICE_DISTRIBUTIONS_ALL.dist_code_combination_id%TYPE;
l_terv_dists_exist                VARCHAR2(1);
l_rows                            NUMBER;
l_po_exchange_rate                NUMBER;
l_rcv_exchange_rate               NUMBER;
l_original_exchange_rate          NUMBER;
i                                 INTEGER;
l_correcting                      VARCHAR2(5) := 'TIPV';
current_calling_sequence          VARCHAR2(1000);
debug_info                        VARCHAR2(1000);
Tipv_Adjustment_Corr_Failure      EXCEPTION;

BEGIN
   --
   current_calling_sequence := 'AP_RETRO_PRICING_PKG.Reverse_Redistribute_TIPV'
                ||P_Calling_Sequence;
   ---------------------------------------------------------------------------
   debug_info := 'Reverse_Redistribute_TIPV Step 1. Compute Zero Amt TAX '
                  ||'Adj Line ';
   ----------------------------------------------------------------------------


   IF (Create_Zero_Amt_Adj_Line(
         p_instruction_id,
         p_created_by,
         l_correcting,
         p_tax_lines_rec,
         l_tipv_adj_lines_rec, --OUT
         current_calling_sequence) <> TRUE) THEN
       --
       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
           AP_IMPORT_UTILITIES_PKG.Print(
             AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'Create_Zero_Amt_Adj_Line<- '||current_calling_sequence);
        END IF;
       --
       Raise Tipv_Adjustment_Corr_Failure;
       --
    END IF;
    --
    ---------------------------------------------------------------------------
    debug_info := 'Reverse_Redistribute_TIPV Step 2. Check IF Terv Dists '
                   ||'exists ';
    --------------------------------------------------------------------------
    IF (AP_RETRO_PRICING_UTIL_PKG.Terv_Dists_exists(
          p_tax_lines_rec.invoice_id,
          p_tax_lines_rec.line_number,
          l_terv_dists_exist) <> TRUE) THEN
      --
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,
          'Terv_Dists_exists<- '||current_calling_sequence);
      END IF;
      --
      Raise Tipv_Adjustment_Corr_Failure;
      --
   END IF;
   --
   --Set the number of rows to be retrieved
   IF l_terv_dists_exist = 'Y' THEN
      l_rows := 3;
   ELSE
      l_rows := 2;
   END IF;
   --
   ---------------------------------------------------------------------------
   debug_info := 'Reverse_Redistribute_TIPV Step 3. Open cursor tipv_dists';
   --------------------------------------------------------------------------
   OPEN tipv_dists(
          l_rows);
   FETCH tipv_dists
   BULK COLLECT INTO l_tipv_dists_list;
   CLOSE tipv_dists;
   --
   ---------------------------------------------------------------------------
   debug_info := 'Reverse_Redistribute_TIPV Step 4. Redistribute TIPV due '
                 ||'to Retropricing ';
   ---------------------------------------------------------------------------
   i:=1;  --Bug5485084
   WHILE i <= (l_tipv_dists_list.COUNT  - l_rows + 1)
   LOOP
        --------------------
        --TIPV Dist
        --------------------
        --TIPV Adj Dist copies Existing TIPV Dist
        l_tipv_adj_dists_list(i) := l_tipv_dists_list(i);
        l_tipv_adj_dists_list(i).invoice_id := l_tipv_adj_lines_rec.invoice_id;
        l_tipv_adj_dists_list(i).invoice_line_number := l_tipv_adj_lines_rec.line_number;
        --l_tipv_adj_dists_list(i).invoice_distribution_id := AP_RETRO_PRICING_UTIL_PKG.get_invoice_distribution_id;
        l_tipv_adj_dists_list(i).invoice_distribution_id := Null;
        l_tipv_adj_dists_list(i).distribution_line_number := i;
        l_tipv_adj_dists_list(i).line_type_lookup_code    := 'TIPV';
        l_tipv_adj_dists_list(i).dist_match_type   := 'ADJUSTMENT_CORRECTION';

        --'Reversal of TIPV due to Retroactive Pricing of Purchase Order'
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_RETRO_TIPV_REVERSAL');
        l_tipv_adj_dists_list(i).description := FND_MESSAGE.GET;

        l_tipv_adj_dists_list(i).dist_code_combination_id := l_tipv_dists_list(i).dist_code_combination_id;

        l_tipv_adj_dists_list(i).accounting_date := SYSDATE;
        l_tipv_adj_dists_list(i).period_name := l_tipv_adj_lines_rec.period_name;

        l_tipv_adj_dists_list(i).amount       := (-1)*l_tipv_dists_list(i).amount;
        l_tipv_adj_dists_list(i).base_amount  := (-1)*l_tipv_dists_list(i).base_amount;
        l_tipv_adj_dists_list(i).rounding_amt := (-1)*l_tipv_dists_list(i).rounding_amt;

        l_tipv_adj_dists_list(i).posted_flag         := 'N';
        --Following fields will be NULL as we do not select it.
        --accounting_event_id
        --upgrade_posted_amount

        l_tipv_adj_dists_list(i).created_by := l_tipv_adj_lines_rec.created_by;

        l_tipv_adj_dists_list(i).related_id  := l_tipv_dists_list(i).related_id;
        l_tipv_adj_dists_list(i).corrected_invoice_dist_id := l_tipv_dists_list(i).invoice_distribution_id;
        l_tipv_adj_dists_list(i).charge_applicable_to_dist_id := l_tipv_dists_list(i).charge_applicable_to_dist_id;

        l_tipv_adj_dists_list(i).cash_posted_flag    := 'N';
        l_tipv_adj_dists_list(i).accrual_posted_flag := 'N';
        l_tipv_adj_dists_list(i).match_status_flag   := l_tipv_dists_list(i).match_status_flag;
        l_tipv_adj_dists_list(i).encumbered_flag     := 'N';
        --l_tipv_adj_dists_list(i).po_distribution_id  := NULL;
        --l_tipv_adj_dists_list(i).rcv_transaction_id  := NULL;

        -- Bug 5509712
        l_tipv_adj_dists_list(i).po_distribution_id := l_tipv_dists_list(i).po_distribution_id;
        l_tipv_adj_dists_list(i).rcv_transaction_id := l_tipv_dists_list(i).rcv_transaction_id;

	  --Start bug#9504423
	IF l_tipv_adj_dists_list(i).project_id IS NOT NULL THEN
               l_tipv_adj_dists_list(i).pa_Addition_flag := 'N';
        ELSE
               l_tipv_adj_dists_list(i).pa_Addition_flag := 'E';
        END IF;
         --End bug#9504423

        --------------------------
        -- NonRecoverable Tax Dist
        ----------------------------
        l_tipv_adj_dists_list(i+1)   := l_tipv_adj_dists_list(i);
        --l_tipv_adj_dists_list(i).invoice_distribution_id := AP_RETRO_PRICING_UTIL_PKG.get_invoice_distribution_id;
        l_tipv_adj_dists_list(i+1).invoice_distribution_id := Null;
        l_tipv_adj_dists_list(i+1).distribution_line_number := i+1;

        l_tipv_adj_dists_list(i+1).line_type_lookup_code := 'NONREC_TAX';


        l_tipv_adj_dists_list(i+1).amount      := l_tipv_dists_list(i).amount; --Bug5485084 removed -1
        l_tipv_adj_dists_list(i+1).base_amount :=
            AP_UTILITIES_PKG.ap_round_currency(
              l_tipv_dists_list(i+1).amount*p_original_exchange_rate,
              p_base_currency_code);

        l_tipv_adj_dists_list(i+1).rounding_amt := l_tipv_dists_list(i).rounding_amt;

        IF (l_rows = 3) THEN
          l_tipv_adj_dists_list(i+1).related_id := l_tipv_adj_dists_list(i+1).invoice_distribution_id;
        ELSE
          l_tipv_adj_dists_list(i+1).related_id := NULL;
        END IF;

        l_tipv_adj_dists_list(i+1).charge_applicable_to_dist_id :=
            AP_RETRO_PRICING_UTIL_PKG.Get_corresponding_retro_DistId(
                         p_lines_rec.match_type,
                         l_tipv_dists_list(i+1).charge_applicable_to_dist_id);

         l_tipv_adj_dists_list(i+1).dist_code_combination_id :=
                       AP_RETRO_PRICING_UTIL_PKG.Get_ccid(
                               l_tipv_dists_list(i+1).charge_applicable_to_dist_id);  --Bug5485084 replaced l_tipv_adj_dists_list with l_tipv_dists_list

         -- Bug 5509712
         l_tipv_adj_dists_list(i+1).po_distribution_id := l_tipv_dists_list(i).po_distribution_id;
         l_tipv_adj_dists_list(i+1).rcv_transaction_id := l_tipv_dists_list(i).rcv_transaction_id;

         -------------
         --TERV Dist
         -------------
         --  Only if the base invoice has ERV create the Terv Dist
         IF l_rows=3 THEN
            l_tipv_adj_dists_list(i+2)   :=  l_tipv_adj_dists_list(i+1);
            --l_tipv_adj_dists_list(i+2).invoice_distribution_id :=
             --                     AP_RETRO_PRICING_UTIL_PKG.get_invoice_distribution_id;
            l_tipv_adj_dists_list(i+2).invoice_distribution_id := Null;
            l_tipv_adj_dists_list(i+2).distribution_line_number := i+2;

            l_tipv_adj_dists_list(i+2).line_type_lookup_code   := 'TERV';
            l_tipv_adj_dists_list(i+2).amount  :=  0;
            --
            --NOTE: Exchange Rate is always calculated w.r.t base match line
            IF (p_lines_rec.rcv_transaction_id IS NOT NULL) THEN
                l_rcv_exchange_rate := AP_RETRO_PRICING_UTIL_PKG.get_exchange_rate(
                                          'RECEIPT',
                                          p_lines_rec.rcv_transaction_id);
              l_tipv_adj_dists_list(i+2).base_amount :=
               AP_UTILITIES_PKG.ap_round_currency(
                   l_tipv_dists_list(i+2).amount*(p_original_exchange_rate - l_rcv_exchange_rate),
                   p_base_currency_code);
            ELSE
              l_po_exchange_rate  := AP_RETRO_PRICING_UTIL_PKG.get_exchange_rate(
                                        'PO',
                                        p_lines_rec.po_header_id);
              l_tipv_adj_dists_list(i+2).base_amount :=
                 AP_UTILITIES_PKG.ap_round_currency(
                   l_tipv_dists_list(i+2).amount*(p_original_exchange_rate - l_po_exchange_rate),
                   p_base_currency_code);
            END IF;

            l_tipv_adj_dists_list(i+2).rounding_amt := NULL;

            --l_tipv_adj_dists_list(i+2).related_id := l_tipv_adj_dists_list(i+1).invoice_distribution_id; --or related_dist_id
            l_tipv_adj_dists_list(i+2).charge_applicable_to_dist_id :=
                  l_tipv_adj_dists_list(i+1).charge_applicable_to_dist_id;

            l_tipv_adj_dists_list(i+2).dist_code_combination_id :=  AP_RETRO_PRICING_UTIL_PKG.get_terv_ccid(
                                                                   l_tipv_adj_dists_list(i+2).corrected_invoice_dist_id);

            -- Bug 5509712
            l_tipv_adj_dists_list(i+2).po_distribution_id := l_tipv_dists_list(i).po_distribution_id;
            l_tipv_adj_dists_list(i+2).rcv_transaction_id := l_tipv_dists_list(i).rcv_transaction_id;

         END IF;
         --
         i:=i+ l_rows;  --loop counter
         --
    END LOOP;

    --------------------------------------------------------------------------
    debug_info := 'Reverse_Redistribute_TIPV Step 4. Insert the '
                  ||'Adjustments in the Global Temp Table';
    --------------------------------------------------------------------------
    FORALL i IN 1..l_tipv_adj_dists_list.COUNT
          INSERT INTO ap_ppa_invoice_dists_gt values  l_tipv_adj_dists_list(i);

    -------------------------------------------------------------------------
    debug_info := 'Reverse_Redistribute_TIPV Step 5. Clear PL/SQL tables';
    -------------------------------------------------------------------------
     l_tipv_adj_dists_list.DELETE;
     l_tipv_dists_list.DELETE;

    ---------------------------------------------------------------------------
    debug_info := 'Reverse_Redistribute_TIPV Step 6. Reverse outstanding PC';
    ---------------------------------------------------------------------------
    IF p_lines_rec.match_type = 'PRICE_CORRECTION' THEN
        IF (Create_Adjustment_Corrections(
                   p_ppa_invoice_rec,
                   p_base_currency_code,
                   l_tipv_adj_lines_rec,
                   current_calling_sequence) <> TRUE) THEN
          --
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
              AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'Create_Adjustment_Corrections<- '||current_calling_sequence);
          END IF;
          --
          Raise Tipv_Adjustment_Corr_Failure;
        END IF;
        --
    END IF;
    --
RETURN (TRUE);


EXCEPTION
 WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      SQLERRM);
      END IF;
    END IF;
    --
    IF ( tipv_dists%ISOPEN ) THEN
        CLOSE tipv_dists;
    END IF;
    --
  RETURN(FALSE);
  --
END Reverse_Redistribute_TIPV;



/*=============================================================================
 |  FUNCTION - Process_TIPV_Reversal()
 |
 |  DESCRIPTION
 |          This program is called from Process_Retroprice_Adjustments for every
 |  the Base Matched( or a price correction or quantity correction line) that
 |  has not been retro adjusted had has Taxes associated with it. This procedure
 |  calls Reverse_Redistribute_TIPV for every Tax line associted with the
 |  original line.
 |
 |  Note: Payables only support Exclusive Tax for PO Matched Invoices and as a
 |        consequence TIPV distributions exist only for Tax Lines that are
 |        allocated to the original line that have IPV's on the original line.
 |        TIPV is the component of Tax that is due to the IPV on the line that the
 |        tax is allocated to.
 |
 |  PARAMETERS
 |      p_base_currency_code
 |      p_instruction_id
 |      p_created_by
 |      p_lines_rec
 |      p_tax_lines_list
 |      P_calling_sequence - Calling sequence
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
FUNCTION Process_TIPV_Reversal(
            p_ppa_invoice_rec    IN AP_RETRO_PRICING_PKG.invoice_rec_type,
            p_base_currency_code IN VARCHAR2,
            p_instruction_id    IN NUMBER,
            p_created_by         IN NUMBER,
            p_lines_rec          IN AP_RETRO_PRICING_PKG.invoice_lines_rec_type,
            p_tax_lines_list     IN AP_RETRO_PRICING_PKG.invoice_lines_list_type,
            P_calling_sequence   IN VARCHAR2)
RETURN BOOLEAN IS


l_tax_lines_rec        AP_RETRO_PRICING_PKG.invoice_lines_rec_type;
--l_tax_lines_list       AP_RETRO_PRICING_PKG.invoice_lines_list_type;
l_original_exchange_rate   NUMBER;
current_calling_sequence   VARCHAR2(1000);
debug_info                 VARCHAR2(1000);

Process_TIPV_Adj_failure EXCEPTION;

BEGIN
    --
    current_calling_sequence :=
    'AP_RETRO_PRICING_PKG.Process_TIPV_Reversal<-'
    ||P_calling_sequence;

    ---------------------------------------------------------------------------
    debug_info := 'Process_TIPV_Reversal Step 1. Get Exchange rate for the '
                  ||'Original Invoice';
    ---------------------------------------------------------------------------
    SELECT exchange_rate
      INTO l_original_exchange_rate
      FROM ap_invoices_all
     WHERE invoice_id = p_lines_rec.invoice_id;


    --------------------------------------------------------------------------
    debug_info := 'Process_TIPV_Reversal Step 2. Reverse_Redistribute_TIPV'
                  ||' for Exclusive Tax';
    --------------------------------------------------------------------------
    FOR i in 1..p_tax_lines_list.COUNT
    LOOP
    --
    l_tax_lines_rec := p_tax_lines_list(i);
    --
    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
    AP_IMPORT_UTILITIES_PKG.Print(
    AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;
    IF (Reverse_Redistribute_TIPV(
           p_ppa_invoice_rec,
           p_base_currency_code,
           p_instruction_id,
           p_created_by,
           l_original_exchange_rate,
           p_lines_rec,
           l_tax_lines_rec,
           p_calling_sequence) <> TRUE) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,
           'Reverse_Redistribute_TIPV<- '||current_calling_sequence);
      END IF;
      Raise Process_TIPV_Adj_failure;
    END IF;
    --
    END LOOP;  --Tax_line loop
    --
    RETURN(TRUE);
    --
EXCEPTION
WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,SQLERRM);
      END IF;
    END IF;
    RETURN(FALSE);

END Process_TIPV_Reversal;

/*============================================================================
 |  FUNCTION - Create_Po_Price_Adjustments()
 |
 |  DESCRIPTION
 |     This program is called in context of base match line (or qty
 |     correction line) and creates a PPA Line in the  global temp tables.
 |     For base match(or qty corr) line the program creates a RETROITEM line
 |     of matchtype PO PRICE ADJUSTMENT which records the delta in price.
 |
 |     NOTE: This program will be called for subsequent Retoprices on the PO
 |           which would be driven by the Instruction in the Interface Lines.
 |
 |  PARAMETERS
 |      p_base_currency_code
 |      p_instruction_id
 |      p_ppa_invoice_rec
 |      p_instruction_lines_rec
 |      p_lines_rec
 |      P_calling_sequence - Calling sequence
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *==========================================================================*/
FUNCTION Create_Po_Price_Adjustments(
            p_base_currency_code   IN VARCHAR2,
            p_instruction_id       IN NUMBER,
            p_ppa_invoice_rec      IN AP_RETRO_PRICING_PKG.invoice_rec_type,
            p_instruction_lines_rec      IN AP_RETRO_PRICING_PKG.instruction_lines_rec_type,
            p_lines_rec            IN AP_RETRO_PRICING_PKG.invoice_lines_rec_type,
            P_calling_sequence     IN VARCHAR2)
RETURN BOOLEAN IS


CURSOR item_dists IS
SELECT  accounting_date,
        accrual_posted_flag,
        amount,
        asset_book_type_code,
        asset_category_id,
        assets_addition_flag,
        assets_tracking_flag,
        attribute_category,
        attribute1,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        award_id,
        awt_flag,
        awt_group_id,
        awt_tax_rate_id,
        base_amount,
        batch_id,
        cancellation_flag,
        cash_posted_flag,
        corrected_invoice_dist_id,
        corrected_quantity,
        country_of_supply,
        created_by,
        description,
        dist_code_combination_id,
        dist_match_type,
        distribution_class,
        distribution_line_number,
        encumbered_flag,
        expenditure_item_date,
        expenditure_organization_id,
        expenditure_type,
        final_match_flag,
        global_attribute_category,
        global_attribute1,
        global_attribute10,
        global_attribute11,
        global_attribute12,
        global_attribute13,
        global_attribute14,
        global_attribute15,
        global_attribute16,
        global_attribute17,
        global_attribute18,
        global_attribute19,
        global_attribute2,
        global_attribute20,
        global_attribute3,
        global_attribute4,
        global_attribute5,
        global_attribute6,
        global_attribute7,
        global_attribute8,
        global_attribute9,
        income_tax_region,
        inventory_transfer_status,
        invoice_distribution_id,
        invoice_id,
        invoice_line_number,
        line_type_lookup_code,
        match_status_flag,
        matched_uom_lookup_code,
        merchant_document_number,
        merchant_name,
        merchant_reference,
        merchant_tax_reg_number,
        merchant_taxpayer_id,
        org_id,
        pa_addition_flag,
        pa_quantity,
        period_name,
        po_distribution_id,
        posted_flag,
        project_id,
        quantity_invoiced,
        rcv_transaction_id,
        NULL,                   --related_id,
        reversal_flag,
        rounding_amt,
        set_of_books_id,
        task_id,
        type_1099,
        unit_price,
        p_instruction_id,          --instruction_id
        NULL,                       --charge_applicable_dist_id
        INTENDED_USE,
        WITHHOLDING_TAX_CODE_ID,
        PROJECT_ACCOUNTING_CONTEXT,
        REQ_DISTRIBUTION_ID,
        REFERENCE_1,
        REFERENCE_2,
        NULL,                   -- line_group_number
        PA_CC_AR_INVOICE_ID,
        PA_CC_AR_INVOICE_LINE_NUM,
        PA_CC_PROCESSED_CODE,
	pay_awt_group_id    --bug6817107
FROM   ap_invoice_distributions_all
WHERE  invoice_id =  p_lines_rec.invoice_id
AND    invoice_line_number = p_lines_rec.line_number
AND    line_type_lookup_code IN ('ITEM', 'ACCRUAL');

l_ppa_lines_rec          AP_RETRO_PRICING_PKG.invoice_lines_rec_type;
l_ppa_invoice_dists_list AP_RETRO_PRICING_PKG.invoice_dists_list_type;
l_item_dists_list        AP_RETRO_PRICING_PKG.invoice_dists_list_type;

l_rows                     NUMBER;
l_po_exchange_rate         NUMBER;
l_rcv_exchange_rate        NUMBER;
i                          INTEGER;
l_dist_total               NUMBER;
l_rounding_amount          NUMBER;
l_rounding_dist            INTEGER;
l_max_dist_amount          NUMBER;

current_calling_sequence   VARCHAR2(1000);
debug_info                 VARCHAR2(1000);
Po_Price_Adj_Failure       EXCEPTION;
l_api_name constant varchar2(200) := 'Create_Po_Price_Adjustments';

BEGIN
   --
   current_calling_sequence :=
      'AP_RETRO_PRICING_PKG.Create_Po_Price_Adjustments'||P_Calling_Sequence;

    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_RETRO_PRICING_PKG.Create_Po_Price_Adjustments(+)');
    END IF;
   --
   ---------------------------------------------------------------------------
    debug_info := 'Create_Po_Price_Adjustments Step 1. Compute Po Price Adj '
                  ||'Line';
   ---------------------------------------------------------------------------
   -- Compute PPA Line
   l_ppa_lines_rec              := p_lines_rec;
   l_ppa_lines_rec.invoice_id   := p_ppa_invoice_rec.invoice_id;
   l_ppa_lines_rec.line_number  := AP_RETRO_PRICING_UTIL_PKG.get_max_ppa_line_num(
                                                      p_ppa_invoice_rec.invoice_id) + 1;
   l_ppa_lines_rec.line_type_lookup_code := 'RETROITEM';
   l_ppa_lines_rec.requester_id := NVL(p_instruction_lines_rec.requester_id, p_lines_rec.requester_id);
   l_ppa_lines_rec.description  := NVL(p_instruction_lines_rec.description, p_lines_rec.description);

   l_ppa_lines_rec.default_dist_ccid    := NULL;
   l_ppa_lines_rec.generate_dists       := 'D';
   l_ppa_lines_rec.prorate_across_all_items := 'N';

   IF (p_instruction_lines_rec.accounting_date is NOT NULL) THEN
       l_ppa_lines_rec.accounting_date := AP_INVOICES_PKG.get_GL_date(
                                             p_instruction_lines_rec.accounting_date);
   ELSE
       l_ppa_lines_rec.accounting_date := AP_INVOICES_PKG.get_GL_date(SYSDATE);
   END IF;

   l_ppa_lines_rec.period_name := AP_INVOICES_PKG.get_period_name(
                                         l_ppa_lines_rec.accounting_date);
   l_ppa_lines_rec.deferred_acctg_flag := 'N';

   l_ppa_lines_rec.line_source  := 'PO PRICE ADJUSTMENT';
   l_ppa_lines_rec.match_type   := 'PO_PRICE_ADJUSTMENT';

   l_ppa_lines_rec.amount :=
            AP_UTILITIES_PKG.ap_round_currency(
                 p_lines_rec.quantity_invoiced*(p_instruction_lines_rec.unit_price - p_lines_rec.unit_price),
                 p_ppa_invoice_rec.invoice_currency_code);

   l_ppa_lines_rec.unit_price  := p_instruction_lines_rec.unit_price - p_lines_rec.unit_price;

   --
   l_ppa_lines_rec.discarded_flag  := 'N';
   l_ppa_lines_rec.cancelled_flag  := 'N';
   --
   l_ppa_lines_rec.corrected_inv_id := p_lines_rec.invoice_id;
   l_ppa_lines_rec.corrected_line_number := p_lines_rec.line_number;
   l_ppa_lines_rec.final_match_flag := 'N';
   --
   l_ppa_lines_rec.award_id   := NVL(p_instruction_lines_rec.award_id, p_lines_rec.award_id);
   l_ppa_lines_rec.created_by      := p_ppa_invoice_rec.created_by;
   l_ppa_lines_rec.instruction_id := p_instruction_id;
   l_ppa_lines_rec.adj_type        := 'PPA';

   debug_info := 'Insert the PPA Line in the Global Temp Table';
   IF (AP_RETRO_PRICING_UTIL_PKG.Create_Line(
           l_ppa_lines_rec,
           current_calling_sequence) <> TRUE) THEN
      --
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,
          'insert_rejections<- '||current_calling_sequence);
      END IF;
      --
      Raise Po_Price_Adj_Failure;
      --
   END IF;

   ----------------------------------------------------------------------------
   debug_info := 'Create_Po_Price_Adjustments Step 2. Open cursor item_dists';
   ----------------------------------------------------------------------------
   OPEN item_dists;
   FETCH item_dists
   BULK COLLECT INTO l_item_dists_list;
   CLOSE item_dists;

   -----------------------------------------------------------------------
   debug_info := 'Create_Po_Price_Adjustments Step 3. Compute PPA Dists';
   ------------------------------------------------------------------------
   FOR i IN 1..l_item_dists_list.COUNT
   LOOP
     --
     l_ppa_invoice_dists_list(i)   := l_item_dists_list(i);

     l_ppa_invoice_dists_list(i).invoice_id := l_ppa_lines_rec.invoice_id;
     l_ppa_invoice_dists_list(i).invoice_line_number := l_ppa_lines_rec.line_number;
     --l_ppa_invoice_dists_list(i).invoice_distribution_id := AP_RETRO_PRICING_UTIL_PKG.get_invoice_distribution_id;
     l_ppa_invoice_dists_list(i).invoice_distribution_id := Null;
     l_ppa_invoice_dists_list(i).distribution_line_number := i;
     /*select max(distribution_line_number) + 1
     into l_ppa_invoice_dists_list(i).distribution_line_number
     from ap_ppa_invoice_dists_gt
     where invoice_id = l_ppa_lines_rec.invoice_id
     and   invoice_line_number = l_ppa_lines_rec.line_number; */
     -- line_type_lookup_code = 'RETROITEM' for Price Corrections
     l_ppa_invoice_dists_list(i).line_type_lookup_code := AP_RETRO_PRICING_UTIL_PKG.get_dist_type_lookup_code(
                                                       l_item_dists_list(i).invoice_distribution_id);
     l_ppa_invoice_dists_list(i).dist_match_type     := 'PO_PRICE_ADJUSTMENT';
     l_ppa_invoice_dists_list(i).distribution_class := 'PERMANENT';
     l_ppa_invoice_dists_list(i).accounting_date := SYSDATE;
     l_ppa_invoice_dists_list(i).period_name := l_ppa_lines_rec.period_name;
     l_ppa_invoice_dists_list(i).accrual_posted_flag := 'N';
     l_ppa_invoice_dists_list(i).cash_posted_flag := 'N';
     l_ppa_invoice_dists_list(i).posted_flag := 'N';
     --
     --quantity_invoiced and corrected_quantity are same for Qty Corrections
     IF p_lines_rec.match_type = 'QTY_CORRECTION'  THEN
        l_ppa_invoice_dists_list(i).amount  :=
             AP_UTILITIES_PKG.ap_round_currency(
                l_item_dists_list(i).corrected_quantity*(p_instruction_lines_rec.unit_price - p_lines_rec.unit_price),
                p_ppa_invoice_rec.invoice_currency_code);
     ELSE
         l_ppa_invoice_dists_list(i).amount  :=
             AP_UTILITIES_PKG.ap_round_currency(
                l_item_dists_list(i).quantity_invoiced*(p_instruction_lines_rec.unit_price - p_lines_rec.unit_price),
                p_ppa_invoice_rec.invoice_currency_code);

     END IF;
     --
     l_ppa_invoice_dists_list(i).base_amount :=
                AP_UTILITIES_PKG.ap_round_currency(
                     l_ppa_invoice_dists_list(i).amount*p_ppa_invoice_rec.exchange_rate,
                     p_base_currency_code);

     --l_ppa_invoice_dists_list(i).rounding_amount := NULL;  -not selected
     --
     l_ppa_invoice_dists_list(i).match_status_flag         := NULL;
     l_ppa_invoice_dists_list(i).encumbered_flag           := 'N';
     l_ppa_invoice_dists_list(i).reversal_flag             := 'N';
     l_ppa_invoice_dists_list(i).cancellation_flag         := 'N';
     l_ppa_invoice_dists_list(i).corrected_invoice_dist_id := l_item_dists_list(i).invoice_distribution_id;
     l_ppa_invoice_dists_list(i).corrected_quantity        := NVL(l_item_dists_list(i).corrected_quantity,
                                                                  l_item_dists_list(i).quantity_invoiced);
     l_ppa_invoice_dists_list(i).quantity_invoiced         := NULL;

     l_ppa_invoice_dists_list(i).unit_price := l_ppa_lines_rec.unit_price;
     --
     l_ppa_invoice_dists_list(i).final_match_flag      := 'N';
     l_ppa_invoice_dists_list(i).assets_addition_flag  := 'U';

     IF l_ppa_invoice_dists_list(i).assets_tracking_flag = 'Y' THEN
        l_ppa_invoice_dists_list(i).asset_book_type_code := p_lines_rec.asset_book_type_code;
        l_ppa_invoice_dists_list(i).asset_category_id    := p_lines_rec.asset_category_id;
     END IF;
     --
     IF l_ppa_invoice_dists_list(i).project_id IS NOT NULL THEN
        l_ppa_invoice_dists_list(i).pa_Addition_flag := 'N';
     ELSE
        l_ppa_invoice_dists_list(i).pa_Addition_flag := 'E';
     END IF;
     --
     l_ppa_invoice_dists_list(i).inventory_transfer_status := 'N';
     l_ppa_invoice_dists_list(i).created_by            := p_ppa_invoice_rec.created_by;
     l_ppa_invoice_dists_list(i).inventory_transfer_status := 'N';
     l_ppa_invoice_dists_list(i).created_by := l_ppa_lines_rec.created_by;
     --
     l_dist_total := l_dist_total +  l_ppa_invoice_dists_list(i).amount;
     --
   END LOOP;

   --If line_amount <> total_dist_line_amount
   --update MAX of the largest dist
   debug_info := 'Round max of the largest PPA Dist';
   IF (l_dist_total <> l_ppa_lines_rec.amount) THEN
     l_rounding_amount := l_ppa_lines_rec.amount -l_dist_total;
      FOR i IN 1..l_item_dists_list.COUNT
      LOOP
        IF i = 1 THEN
          l_max_dist_amount := l_ppa_invoice_dists_list(i).amount;
        END IF;
        IF l_item_dists_list(i).amount > l_max_dist_amount  THEN
           l_max_dist_amount := l_ppa_invoice_dists_list(i).amount;
               l_rounding_dist := i;
        END IF;
      END LOOP;
      --
      l_ppa_invoice_dists_list(l_rounding_dist).amount :=
                 l_rounding_amount + l_ppa_invoice_dists_list(i).amount;
      --
   END IF;

   ---------------------------------------------------------------------------
   debug_info := 'Create_Po_Price_Adjustments Step 4. Insert the PPA Dists in'
                 ||' the Global Temp Table';
   ---------------------------------------------------------------------------
   FORALL i IN 1..l_ppa_invoice_dists_list.COUNT
         INSERT INTO ap_ppa_invoice_dists_gt values  l_ppa_invoice_dists_list(i);

   -------------------------------------------------------------------------
   debug_info := 'Create_Po_Price_Adjustments Step 5. Clear PL/SQL tables';
   -------------------------------------------------------------------------
   l_ppa_invoice_dists_list.DELETE;
   l_item_dists_list.DELETE;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_RETRO_PRICING_PKG.Create_Po_Price_Adjustments(-)');
   END IF;
   --
   RETURN(TRUE);
   --
EXCEPTION
 WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;
    --
    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      SQLERRM);
      END IF;
    END IF;
    --
    IF ( item_dists%ISOPEN ) THEN
        CLOSE item_dists;
    END IF;
    --
    RETURN(FALSE);

END Create_Po_Price_Adjustments;


/*==============================================================================
 |  FUNCTION - Process_Retroprice_Adjustments()
 |
 |  DESCRIPTION
 |      This program is called from Import_Retroprice_Adjustments for every
 |      base matched invoice line that is a candidate for retropricing. The
 |      program has the following logic to populate the Global Temp tables:
 |      1.Reverse IPV and TIPV on the Base Matched Lines(as well as all Price
 |        Corrections and Quantity Corrections done on the base matched line)
 |        and popuate the Temp tables with Zero Amt Adjustment Correction Lines.
 |      2.Create PPA correction adjustment lines in the Temp Tables to reverse
 |         any outstanding price correction.
 |      3.Create PO price adjustment lines to record the delta in price in the
 |        Global Temporary Tables.
 |      4.If PPA already exists for the original base match line then Reverse
 |        all po price adjustment lines for the existing PPA.
 |
 |
 |  PARAMETERS
 |      p_base_currency_code
 |      p_base_match_lines_list
 |      p_instruction_rec
 |      p_instruction_lines_rec
 |      p_batch_id
 |      P_calling_sequence - Calling sequence
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
FUNCTION Process_Retroprice_Adjustments(
           p_base_currency_code    IN VARCHAR2,
           p_base_match_lines_list IN AP_RETRO_PRICING_PKG.invoice_lines_list_type,
           p_instruction_rec       IN AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
           p_instruction_lines_rec IN AP_RETRO_PRICING_PKG.instruction_lines_rec_type,
           p_batch_id              IN NUMBER,
           p_calling_sequence      IN VARCHAR2)
RETURN BOOLEAN IS

l_base_match_lines_rec    AP_RETRO_PRICING_PKG.invoice_lines_rec_type;
l_pc_lines_list           AP_RETRO_PRICING_PKG.invoice_lines_list_type;
l_pc_lines_rec            AP_RETRO_PRICING_PKG.invoice_lines_rec_type;
l_qc_lines_list           AP_RETRO_PRICING_PKG.invoice_lines_list_type;
l_qc_lines_rec            AP_RETRO_PRICING_PKG.invoice_lines_rec_type;
l_adj_lines_rec           AP_RETRO_PRICING_PKG.invoice_lines_rec_type;

l_tax_lines_list          AP_RETRO_PRICING_PKG.invoice_lines_list_type;
l_ppa_invoice_rec         AP_RETRO_PRICING_PKG.invoice_rec_type;

l_prev_invoice_id         NUMBER(15);
l_existing_ppa_inv_id     NUMBER(15);
l_ppa_exists              VARCHAR2(1);
l_adj_corr_exists         VARCHAR2(1);
l_pc_exists               VARCHAR2(1);
l_qc_exists               VARCHAR2(1);
l_ipv_dists_exist         VARCHAR2(1);
l_erv_dists_exist         VARCHAR2(1);
l_TIPV_exist              VARCHAR2(1);
debug_info                VARCHAR2(1000);
current_calling_sequence  VARCHAR2(1000);

Process_Retro_Adj_failure EXCEPTION;
l_api_name constant varchar2(200) := 'Process_Retroprice_Adjustments';

BEGIN
  --
  current_calling_sequence :=
  'AP_RETRO_PRICING_PKG.Process_Retroprice_Adjustments<-'
  ||P_calling_sequence;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_RETRO_PRICING_PKG.Process_Retroprice_Adjustments(+)');
   END IF;

   debug_info := 'Inside the procedure Process_Retroprice Adjustments';

   IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
       AP_IMPORT_UTILITIES_PKG.Print(
         AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
   END IF;

  FOR i IN 1..p_base_match_lines_list.COUNT
  LOOP
    --
    l_base_match_lines_rec := p_base_match_lines_list(i);

    ------------------------------------------------------------------------------
    debug_info := 'Process Retroprice Adjustments Step 1. Insert Temp PPA Invoice l_base_match_lines_rec.invoice_id,l_prev_invoice_id  '||l_base_match_lines_rec.invoice_id||','||l_prev_invoice_id;
    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
       AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;
    ------------------------------------------------------------------------------
    --Bugfix:4281253
    IF  (l_base_match_lines_rec.invoice_id <> nvl(l_prev_invoice_id,0))
    THEN
      --
      IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
         AP_IMPORT_UTILITIES_PKG.Print(
         AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;
      --
      debug_info := '8889999 l_base_match_lines_rec.amount is '||l_base_match_lines_rec.amount;
      IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;


      IF (AP_RETRO_PRICING_UTIL_PKG.Create_ppa_Invoice(
              p_instruction_rec.invoice_id,
              l_base_match_lines_rec.invoice_id,
              l_base_match_lines_rec.line_number,
              p_batch_id,
              l_ppa_invoice_rec,     --OUT
              current_calling_sequence) <> TRUE) THEN

         IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
             AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   'Create_ppa_Invoice<- '||current_calling_sequence);
         END IF;
         Raise Process_Retro_Adj_failure;

      END IF;
      --   Bug 5525506. Remove the following END IF below
      --
      --      l_prev_invoice_id :=  l_base_match_lines_rec.invoice_id;
      --
      --   END IF;  -- l_prev_invoice_id

      --------------------------------------------------------------------------
      debug_info := 'Process Retroprice Adjustments Step 2. Check if '
                  ||'ppa_already_exists';
      IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
         AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;
      --------------------------------------------------------------------------
      IF (AP_RETRO_PRICING_UTIL_PKG.ppa_already_exists(
          l_base_match_lines_rec.invoice_id,
          l_base_match_lines_rec.line_number,
          l_ppa_exists,         --OUT
          l_existing_ppa_inv_id --OUT
          ) <> TRUE) THEN

        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
           AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   'ppa_already_exists<- '||current_calling_sequence);
        END IF;
        Raise Process_Retro_Adj_failure;
      END IF;

      debug_info := 'Existing PPA Invoice Id: '||l_existing_ppa_inv_id;
      IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
         AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;


      -- PPA Docs have two types of lines --
      -- 1. Adjustment Correction: To reverse any outstanding price correction.
      -- 2. PO Price Adjustment: To record the delta in price in the Global
      --    Temporary Tables.
      -- The Reversal Process should not reverse the lines associated with Price
      -- Corrections on the PPA.

      ----------------------------------------------------------------------------
      debug_info := 'Process Retroprice Adjustments Step 3. Reverse_Existing_Ppa';
      IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
         AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;
      ----------------------------------------------------------------------------
      IF (l_ppa_exists = 'Y')  THEN
       --  l_base_match_lines_rec.invoice_id <> l_prev_invoice_id) THEN
        debug_info := 'PPA exists for this Invoice ';
        IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
           AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
        END IF;
        IF  (Reverse_Existing_Ppa(
                p_instruction_rec.invoice_id,
                l_ppa_invoice_rec,
                p_instruction_lines_rec,
                l_existing_ppa_inv_id,
                current_calling_sequence) <> TRUE) THEN
          --
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   'Reverse_Existing_Ppa<- '||current_calling_sequence);
          END IF;
          --
          Raise Process_Retro_Adj_failure;
          --
        END IF; --Compute Ppa_reversal
      END IF; --l_ppa_exists

      --
      l_prev_invoice_id :=  l_base_match_lines_rec.invoice_id;
      --
    END IF;  -- l_prev_invoice_id. Bug 5525506

   ----------------------------------------------------------------------------
    debug_info := 'Process Retroprice Adjustments Step 4. Check if IPV Dists'
                  ||' Exists';
    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
       AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;
   ----------------------------------------------------------------------------
    -- If this base matched line has already been Adjusted by a line
    -- then no adjustments are required on this line. However adjustments
    -- may be required on the PC or QC for this base matched line
    --
    IF (AP_RETRO_PRICING_UTIL_PKG.Ipv_Dists_exists(
          l_base_match_lines_rec.invoice_id,
          l_base_match_lines_rec.line_number,
          l_ipv_dists_exist         --OUT
          ) <> TRUE) THEN
      --
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   'Ipv_Dists_exists<- '||current_calling_sequence);
      END IF;
      --
      Raise Process_Retro_Adj_failure;
    END IF;
    --
   ------------------------------------------------------------------------
    debug_info := 'Process Retroprice Adjustments Step 5. Check if Adj Corr'
                  ||' Exists';
    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
       AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;
   -------------------------------------------------------------------------
    IF (AP_RETRO_PRICING_UTIL_PKG.Adj_Corr_Exists(
               l_base_match_lines_rec.invoice_id,
               l_base_match_lines_rec.line_number,
               l_adj_corr_exists) <> TRUE) THEN
        --
         IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   'Adj_Corr_Exists<- '||current_calling_sequence);
         END IF;
         Raise Process_Retro_Adj_failure;
    END IF;
    --
    IF  (l_ipv_dists_exist = 'Y') AND ( l_adj_corr_exists = 'N') THEN
    --
        -----------------------------------------------------------------------
        debug_info := 'Process Retroprice Adjustments Step 6. '
                       ||'Reverse_Redistribute_IPV for the base matched line';
        IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
          AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
        END IF;
        -----------------------------------------------------------------------
        --
        IF (Reverse_Redistribute_IPV(
                         l_ppa_invoice_rec,
                         p_base_currency_code,
                         p_instruction_rec.invoice_id,
                         p_instruction_rec.created_by,
                         l_base_match_lines_rec,
                         l_erv_dists_exist,
                         current_calling_sequence) <> TRUE) THEN
          --
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,
                'Reverse_Redistribute_IPV<- '||current_calling_sequence);
          END IF;
          --
          Raise Process_Retro_Adj_failure;
          --
        END IF;
        --

        ----------------------------------------------------------------------
        debug_info := 'Process Retroprice Adjustments Step 7. '||
                      'Check if TIPV Dists Exists for the base matched Line';
        IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
          AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
        END IF;
        ----------------------------------------------------------------------
        IF (AP_RETRO_PRICING_UTIL_PKG.Tipv_Exists(
              l_base_match_lines_rec.invoice_id,
              l_base_match_lines_rec.line_number,
              l_tax_lines_list,
              l_tipv_exist) <> TRUE) THEN
           --
           IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
               AP_IMPORT_UTILITIES_PKG.Print(
               AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'Tipv_Exists<- '||current_calling_sequence);
           END IF;
           --
           Raise Process_Retro_Adj_failure;
           --
        END IF;
        --
        IF  l_tipv_exist = 'Y' THEN
            --
            -----------------------------------------------------------------
            debug_info := 'Process Retroprice Adjustments Step 8. '
              ||'Process_TIPV_Reversal for the base matched line';
            IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
               AP_IMPORT_UTILITIES_PKG.Print(
                 AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
            END IF;
            -----------------------------------------------------------------
            IF (Process_TIPV_Reversal(
                             l_ppa_invoice_rec,
                             p_base_currency_code,
                             p_instruction_rec.invoice_id,
                             p_instruction_rec.created_by,
                             l_base_match_lines_rec,
                             l_tax_lines_list,
                             current_calling_sequence) <> TRUE) THEN
              --
              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                    AP_IMPORT_UTILITIES_PKG.Print(
                    AP_IMPORT_INVOICES_PKG.g_debug_switch,
                    'Process_TIPV_Reversal<- '||current_calling_sequence);
              END IF;
              --
              Raise Process_Retro_Adj_failure;
              --
            END IF;
            --
        END IF;

    END IF;  --ipv dists and l_adj_corr

    -- Create PPA Line even if the IPV's don't exist for the Base Match Line
    --------------------------------------------------------------------------
    debug_info := 'Process Retroprice Adjustments Step 9. '
                   ||'Create_Po_Price_Adjustments for the base matched line';
    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
       AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;
    --------------------------------------------------------------------------
    --
    -- Bug 5469166. Not Calling Create_Po_Price_Adjustment id the wash scenario
    IF (p_instruction_lines_rec.unit_price <> l_base_match_lines_rec.unit_price) THEN

      IF (Create_Po_Price_Adjustments(
             p_base_currency_code,
             p_instruction_rec.invoice_id,
             l_ppa_invoice_rec,
             p_instruction_lines_rec,
             l_base_match_lines_rec,
             current_calling_sequence) <> TRUE) THEN
        --
         IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch,
             'Create_Po_Price_Adjustments<- '||current_calling_sequence);
         END IF;
       --
         Raise Process_Retro_Adj_failure;
       --
      END IF;

    END IF;

    -- Price Corrections
    -------------------------------------------------------------------------
    debug_info := 'Process Retroprice Adjustments Step 10. IF PC Exists';
    -------------------------------------------------------------------------
    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
         AP_IMPORT_UTILITIES_PKG.Print(
         AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;
    --
    IF (AP_RETRO_PRICING_UTIL_PKG.Corrections_exists(
              l_base_match_lines_rec.invoice_id,
              l_base_match_lines_rec.line_number,
               'PRICE_CORRECTION',  --Modified spelling for bug#9573078
              l_pc_lines_list,
              l_pc_exists) <> TRUE) THEN
       --
       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
           AP_IMPORT_UTILITIES_PKG.Print(
             AP_IMPORT_INVOICES_PKG.g_debug_switch,
             'Corrections_exists<- '||current_calling_sequence);
       END IF;
       --
       Raise Process_Retro_Adj_failure;
       --
    END IF;

    IF  (l_pc_exists = 'Y') THEN
      --
      FOR i in 1..l_pc_lines_list.COUNT
      LOOP
         --
         l_pc_lines_rec :=  l_pc_lines_list(i);
         --
         -- IPV Dists always exist for Price Corrections
         ---------------------------------------------------------------------
         debug_info := 'Process Retroprice Adjustments Step 11. Check if IPV '
                        ||'Dists Exist for PC';
         IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
           AP_IMPORT_UTILITIES_PKG.Print(
             AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
         END IF;
         ---------------------------------------------------------------------
         IF (AP_RETRO_PRICING_UTIL_PKG.Ipv_Dists_exists(
                l_pc_lines_rec.invoice_id,
                l_pc_lines_rec.line_number,
                l_ipv_dists_exist) <> TRUE) THEN
            --
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   'Ipv_Dists_exists<- '||current_calling_sequence);
            END IF;
            Raise Process_Retro_Adj_failure;
         END IF;
         --
         ---------------------------------------------------------------------
         debug_info := 'Process Retroprice Adjustments Step 12. Check if Adj '
                       ||'Corr Exists for PC';
         IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
           AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
         END IF;
         ---------------------------------------------------------------------
         IF (AP_RETRO_PRICING_UTIL_PKG.Adj_Corr_Exists(
               l_pc_lines_rec.invoice_id,
               l_pc_lines_rec.line_number,
               l_adj_corr_exists) <> TRUE) THEN
            --
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   'Adj_Corr_Exists<- '||current_calling_sequence);
            END IF;
           Raise Process_Retro_Adj_failure;
         END IF;

         IF  (l_ipv_dists_exist = 'Y') AND ( l_adj_corr_exists = 'N') THEN
           --
           ------------------------------------------------------------------
           debug_info := 'Process Retroprice Adjustments Step 13. '
                       ||'Reverse_Redistribute_IPV for the PC line';
           IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
             AP_IMPORT_UTILITIES_PKG.Print(
               AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
           END IF;
           ------------------------------------------------------------------
           IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
             AP_IMPORT_UTILITIES_PKG.Print(
             AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
           END IF;
           --
           IF (Reverse_Redistribute_IPV(
                         l_ppa_invoice_rec,
                         p_base_currency_code,
                         p_instruction_rec.invoice_id,
                         p_instruction_rec.created_by,
                         l_pc_lines_rec,
                         l_erv_dists_exist,
                         current_calling_sequence) <> TRUE) THEN
              --
              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                  AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   'Reverse_Redistribute_IPV<- '||current_calling_sequence);
              END IF;
              --
              Raise Process_Retro_Adj_failure;
              --
           END IF;
           --
           -------------------------------------------------------------------
           debug_info := 'Process Retroprice Adjustments Step 14. '||
                         'Check if TIPV Dists Exists for the PC Line';
           IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
             AP_IMPORT_UTILITIES_PKG.Print(
               AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
           END IF;
           -------------------------------------------------------------------
           IF (AP_RETRO_PRICING_UTIL_PKG.Tipv_Exists(
                  l_pc_lines_rec.invoice_id,
                  l_pc_lines_rec.line_number,
                  l_tax_lines_list,
                  l_tipv_exist) <> TRUE) THEN
               --
               IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                   AP_IMPORT_UTILITIES_PKG.Print(
                   AP_IMPORT_INVOICES_PKG.g_debug_switch,
                  'Tipv_Exists<- '||current_calling_sequence);
               END IF;
               --
               Raise Process_Retro_Adj_failure;
               --
           END IF;
           --
           IF  l_tipv_exist = 'Y' THEN
                --
                --------------------------------------------------------------
                debug_info := 'Process Retroprice Adjustments Step 15. '
                             ||'Process_TIPV_Reversal for the PC line';
                IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
                   AP_IMPORT_UTILITIES_PKG.Print(
                      AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
                END IF;
                --------------------------------------------------------------
                IF (Process_TIPV_Reversal(
                                 l_ppa_invoice_rec,
                                 p_base_currency_code,
                                 p_instruction_rec.invoice_id,
                                 p_instruction_rec.created_by,
                                 l_pc_lines_rec,
                                 l_tax_lines_list,
                                 current_calling_sequence) <> TRUE) THEN
                  --
                  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                        AP_IMPORT_UTILITIES_PKG.Print(
                        AP_IMPORT_INVOICES_PKG.g_debug_switch,
                        'Process_TIPV_Reversal<- '||current_calling_sequence);
                  END IF;
                  --
                  Raise Process_Retro_Adj_failure;
                  --
                END IF;
                --
           END IF;


            -- PPA Line should only be created for a PC Line if the
            -- if the PC  Lines have not been adjustment corrected.
            -- NOTE : PC's always have IPV Dists
            -----------------------------------------------------------------
            debug_info := 'Process Retroprice Adjustments Step 16. '
                           ||'Create_Po_Price_Adjustments for the PC line';
            ------------------------------------------------------------------
            IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
               AP_IMPORT_UTILITIES_PKG.Print(
               AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
            END IF;
            --

         END IF;  --ipv dists and l_adj_corr
         --
       END LOOP;  --PC Loop
       --
    END IF; -- If PC Exists

    -- Quantity Corrections
    ----------------------------------------------------------------------
    debug_info := 'Process Retroprice Adjustments Step 17. IF QC Exists';
    ----------------------------------------------------------------------
    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
         AP_IMPORT_UTILITIES_PKG.Print(
         AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;
    --
    IF (AP_RETRO_PRICING_UTIL_PKG.Corrections_exists(
              l_base_match_lines_rec.invoice_id,
              l_base_match_lines_rec.line_number,
              'QTY_CORRECTION',  --Modified spelling for bug#9573078
              l_qc_lines_list,
              l_qc_exists) <> TRUE) THEN
       --
       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
           AP_IMPORT_UTILITIES_PKG.Print(
             AP_IMPORT_INVOICES_PKG.g_debug_switch,
             'Corrections_exists<- '||current_calling_sequence);
       END IF;
       --
       Raise Process_Retro_Adj_failure;
       --
    END IF;
    --
    IF  (l_qc_exists = 'Y') THEN
      --
      FOR i in 1..l_qc_lines_list.COUNT
      LOOP
         --
         l_qc_lines_rec :=  l_qc_lines_list(i);
         --
         ---------------------------------------------------------------------
         debug_info := 'Process Retroprice Adjustments Step 18. Check if IPV '
                        ||'Dists Exist for QC';
         ---------------------------------------------------------------------
         IF (AP_RETRO_PRICING_UTIL_PKG.Ipv_Dists_exists(
                l_qc_lines_rec.invoice_id,
                l_qc_lines_rec.line_number,
                l_ipv_dists_exist) <> TRUE) THEN
            --
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   'Ipv_Dists_exists<- '||current_calling_sequence);
            END IF;
            Raise Process_Retro_Adj_failure;
         END IF;
         --
         -------------------------------------------------------------------------
         debug_info := 'Process Retroprice Adjustments Step 19. Check if Adj '
                        ||'Corr Exists for QC';
         -------------------------------------------------------------------------
         IF (AP_RETRO_PRICING_UTIL_PKG.Adj_Corr_Exists(
               l_qc_lines_rec.invoice_id,
               l_qc_lines_rec.line_number,
               l_adj_corr_exists) <> TRUE) THEN
            --
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   'Adj_Corr_Exists<- '||current_calling_sequence);
            END IF;
           Raise Process_Retro_Adj_failure;
         END IF;
         --
         IF  (l_ipv_dists_exist = 'Y') AND ( l_adj_corr_exists = 'N') THEN
           --
           --------------------------------------------------------------
           debug_info := 'Process Retroprice Adjustments Step 20. '
                          ||'Reverse_Redistribute_IPV for the QC line';
           ----------------------------------------------------------------
           IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
             AP_IMPORT_UTILITIES_PKG.Print(
             AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
           END IF;
           --
           IF (Reverse_Redistribute_IPV(
                     l_ppa_invoice_rec,
                     p_base_currency_code,
                     p_instruction_rec.invoice_id,
                     p_instruction_rec.created_by,
                     l_qc_lines_rec,
                     l_erv_dists_exist,
                     current_calling_sequence) <> TRUE) THEN
              --
              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                  AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   'Reverse_Redistribute_IPV<- '||current_calling_sequence);
              END IF;
              --
              Raise Process_Retro_Adj_failure;
              --
           END IF;
           --

          --------------------------------------------------------------------
           debug_info := 'Process Retroprice Adjustments Step 21. '||
                          'Check if TIPV Dists Exists for the QC Line';
           -------------------------------------------------------------------
           IF (AP_RETRO_PRICING_UTIL_PKG.Tipv_Exists(
                  l_qc_lines_rec.invoice_id,
                  l_qc_lines_rec.line_number,
                  l_tax_lines_list,
                  l_tipv_exist) <> TRUE) THEN
               --
               IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                   AP_IMPORT_UTILITIES_PKG.Print(
                   AP_IMPORT_INVOICES_PKG.g_debug_switch,
                  'Tipv_Exists<- '||current_calling_sequence);
               END IF;
               --
               Raise Process_Retro_Adj_failure;
               --
           END IF;
           --
           IF  l_tipv_exist = 'Y' THEN
                --
                --------------------------------------------------------------
                debug_info := 'Process Retroprice Adjustments Step 22. '||
                               'Process_TIPV_Reversal for the PC line';
                --------------------------------------------------------------
                IF (Process_TIPV_Reversal(
                                 l_ppa_invoice_rec,
                                 p_base_currency_code,
                                 p_instruction_rec.invoice_id,
                                 p_instruction_rec.created_by,
                                 l_qc_lines_rec,
                                 l_tax_lines_list,
                                 current_calling_sequence) <> TRUE) THEN
                  --
                  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                        AP_IMPORT_UTILITIES_PKG.Print(
                        AP_IMPORT_INVOICES_PKG.g_debug_switch,
                        'Process_TIPV_Reversal<- '||current_calling_sequence);
                  END IF;
                  --
                  Raise Process_Retro_Adj_failure;
                  --
                END IF;
                --
           END IF;


         END IF; --l_ipv_dists_Exist and l_adj_corr_Exists

         -----------------------------------------------------------------
            debug_info := 'Process Retroprice Adjustments Step 23. '
                   ||'Create_Po_Price_Adjustments for the QC line';
         ------------------------------------------------------------------
         IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
               AP_IMPORT_UTILITIES_PKG.Print(
               AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
         END IF;
         --

	 --Introduced below IF clause for bug#9573078
	 IF (p_instruction_lines_rec.unit_price <> l_qc_lines_rec.unit_price) THEN
         IF (Create_Po_Price_Adjustments(
                   p_base_currency_code,
                   p_instruction_rec.invoice_id,
                   l_ppa_invoice_rec,
                   p_instruction_lines_rec,
                   l_qc_lines_rec,
                   current_calling_sequence) <> TRUE) THEN
            --
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                   AP_IMPORT_UTILITIES_PKG.Print(
                   AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   'Create_Po_Price_Adjustments<- '||current_calling_sequence);
            END IF;
            --
            Raise Process_Retro_Adj_failure;
         END IF;
	  END IF; --unit price check
         --
      END LOOP;  --QC loop
      --
    END IF; -- If QC Exists

 END LOOP; --Base Match Line List

  -------------------------------------------------------------------------
   debug_info := 'Process Retroprice Adjustments Step 24 Clear PL/SQL tables';
   -------------------------------------------------------------------------
   l_pc_lines_list.DELETE;
   l_qc_lines_list.DELETE;
   l_tax_lines_list.DELETE;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_RETRO_PRICING_PKG.Process_Retroprice_Adjustments(-)');
   END IF;
   --
   RETURN(TRUE);
   --
EXCEPTION
 WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,SQLERRM);
      END IF;
    END IF;
    RETURN(FALSE);

END Process_Retroprice_Adjustments;


/*=============================================================================
 |  FUNCTION - Insert_Zero_Amt_Adjustments()
 |
 |  DESCRIPTION
 |       This function creates Zero Amount RetroItem and RetoTax lines on all
 |  the original invoices that need retro adjustment for a vendor. Furthermore
 |  this function reverses and redistributes all outstanding IPV and TIPV
 |  distributions
 |
 |
 |  PARAMETERS
 |      p_base_currency_code
 |      p_base_match_lines_list
 |      p_instruction_rec
 |      p_instruction_lines_rec
 |      p_batch_id
 |      P_calling_sequence - Calling sequence
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |  Bug 5353893 -- Added NVL to the WHO Columns so that in cases
 |                 when it is null we will use the "Standalone Batch
 |                 Process" as the possible user.
 |
 *============================================================================*/
FUNCTION Insert_Zero_Amt_Adjustments(
            -- p_instruction_id         IN NUMBER, --Commented for bug#9573078
	     p_invoice_id            IN NUMBER,  --bug#9573078
             p_line_number           IN NUMBER,  --bug#9573078
             p_calling_sequence        IN VARCHAR2)
RETURN BOOLEAN IS

current_calling_sequence    VARCHAR2(1000);
debug_info                  VARCHAR2(1000);

BEGIN
   --
   current_calling_sequence :=
    'AP_RETRO_PRICING_PKG.Insert_Zero_Amt_Adjustments<-'
    ||P_calling_sequence;

   ---------------------------------------------------------------------------
   debug_info := 'Insert_Zero_Amt_Adjustments Step 1. Insert into '
                 ||'AP_INVOICE_LINES_ALL';
   ---------------------------------------------------------------------------
   INSERT INTO AP_INVOICE_LINES_ALL(
                    invoice_id,
                    line_number,
                    line_type_lookup_code,
                    requester_id,
                    description,
                    line_source,
                    org_id,
                    inventory_item_id,
                    item_description,
                    serial_number,
                    manufacturer,
                    model_number,
                    generate_dists,
                    match_type,
                    default_dist_ccid,
                    prorate_across_all_items,
                    accounting_date,
                    period_name,
                    deferred_acctg_flag,
                    set_of_books_id,
                    amount,
                    base_amount,
                    rounding_amt,
                    quantity_invoiced,
                    unit_meas_lookup_code,
                    unit_price,
                    discarded_flag,
                    cancelled_flag,
                    income_tax_region,
                    type_1099,
                    corrected_inv_id,
                    corrected_line_number,
                    po_header_id,
                    po_line_id,
                    po_release_id,
                    po_line_location_id,
                    po_distribution_id,
                    rcv_transaction_id,
                    final_match_flag,
                    assets_tracking_flag,
                    asset_book_type_code,
                    asset_category_id,
                    project_id,
                    task_id,
                    expenditure_type,
                    expenditure_item_date,
                    expenditure_organization_id,
                    award_id,
                    awt_group_id,
		    pay_awt_group_id,--bug6817107
                    receipt_verified_flag,
                    receipt_required_flag,
                    receipt_missing_flag,
                    justification,
                    expense_group,
                    start_expense_date,
                    end_expense_date,
                    receipt_currency_code,
                    receipt_conversion_rate,
                    receipt_currency_amount,
                    daily_amount,
                    web_parameter_id,
                    adjustment_reason,
                    merchant_document_number,
                    merchant_name,
                    merchant_reference,
                    merchant_tax_reg_number,
                    merchant_taxpayer_id,
                    country_of_supply,
                    credit_card_trx_id,
                    company_prepaid_invoice_id,
                    cc_reversal_flag,
                    creation_date,
                    created_by,
                    attribute_category,
                    attribute1,
                    attribute2,
                    attribute3,
                    attribute4,
                    attribute5,
                    attribute6,
                    attribute7,
                    attribute8,
                    attribute9,
                    attribute10,
                    attribute11,
                    attribute12,
                    attribute13,
                    attribute14,
                    attribute15,
                    global_attribute_category,
                    global_attribute1,
                    global_attribute2,
                    global_attribute3,
                    global_attribute4,
                    global_attribute5,
                    global_attribute6,
                    global_attribute7,
                    global_attribute8,
                    global_attribute9,
                    global_attribute10,
                    global_attribute11,
                    global_attribute12,
                    global_attribute13,
                    global_attribute14,
                    global_attribute15,
                    global_attribute16,
                    global_attribute17,
                    global_attribute18,
                    global_attribute19,
                    global_attribute20,
                    primary_intended_use,
                    ship_to_location_id,
                    product_type,
                    product_category,
                    product_fisc_classification,
                    user_defined_fisc_class,
                    trx_business_category,
                    summary_tax_line_id,
                    tax_regime_code,
                    tax,
                    tax_jurisdiction_code,
                    tax_status_code,
                    tax_rate_id,
                    tax_rate_code,
                    tax_rate,
                    wfapproval_status,
                    pa_quantity,
                    last_updated_by,
                    last_update_date)
            SELECT  invoice_id,
                    line_number,
                    line_type_lookup_code,
                    requester_id,
                    description,
                    line_source,
                    org_id,
                    inventory_item_id,
                    item_description,
                    serial_number,
                    manufacturer,
                    model_number,
                    generate_dists,
                    match_type,
                    default_dist_ccid,
                    prorate_across_all_items,
                    accounting_date,
                    period_name,
                    deferred_acctg_flag,
                    set_of_books_id,
                    amount,
                    base_amount,
                    rounding_amt,
                    quantity_invoiced,
                    unit_meas_lookup_code,
                    unit_price,
                    discarded_flag,
                    cancelled_flag,
                    income_tax_region,
                    type_1099,
                    corrected_inv_id,
                    corrected_line_number,
                    po_header_id,
                    po_line_id,
                    po_release_id,
                    po_line_location_id,
                    po_distribution_id,
                    rcv_transaction_id,
                    final_match_flag,
                    assets_tracking_flag,
                    asset_book_type_code,
                    asset_category_id,
                    project_id,
                    task_id,
                    expenditure_type,
                    expenditure_item_date,
                    expenditure_organization_id,
                    award_id,
                    awt_group_id,
		    pay_awt_group_id,--bug6817107
                    receipt_verified_flag,
                    receipt_required_flag,
                    receipt_missing_flag,
                    justification,
                    expense_group,
                    start_expense_date,
                    end_expense_date,
                    receipt_currency_code,
                    receipt_conversion_rate,
                    receipt_currency_amount,
                    daily_amount,
                    web_parameter_id,
                    adjustment_reason,
                    merchant_document_number,
                    merchant_name,
                    merchant_reference,
                    merchant_tax_reg_number,
                    merchant_taxpayer_id,
                    country_of_supply,
                    credit_card_trx_id,
                    company_prepaid_invoice_id,
                    cc_reversal_flag,
                    nvl(creation_date,sysdate),
                    nvl(created_by,5),
                    attribute_category,
                    attribute1,
                    attribute2,
                    attribute3,
                    attribute4,
                    attribute5,
                    attribute6,
                    attribute7,
                    attribute8,
                    attribute9,
                    attribute10,
                    attribute11,
                    attribute12,
                    attribute13,
                    attribute14,
                    attribute15,
                    global_attribute_category,
                    global_attribute1,
                    global_attribute2,
                    global_attribute3,
                    global_attribute4,
                    global_attribute5,
                    global_attribute6,
                    global_attribute7,
                    global_attribute8,
                    global_attribute9,
                    global_attribute10,
                    global_attribute11,
                    global_attribute12,
                    global_attribute13,
                    global_attribute14,
                    global_attribute15,
                    global_attribute16,
                    global_attribute17,
                    global_attribute18,
                    global_attribute19,
                    global_attribute20,
                    primary_intended_use,
                    ship_to_location_id,
                    product_type,
                    product_category,
                    product_fisc_classification,
                    user_defined_fisc_class,
                    trx_business_category,
                    summary_tax_line_id,
                    tax_regime_code,
                    tax,
                    tax_jurisdiction_code,
                    tax_status_code,
                    tax_rate_id,
                    tax_rate_code,
                    tax_rate,
                    wfapproval_status,
                    pa_quantity,
                    nvl(created_by,5),
                    nvl(creation_date,sysdate)
            FROM    ap_ppa_invoice_lines_gt
          --Introduced new and modified existing conditions for bug#9573078
	        --instruction_id = p_instruction_id
	    WHERE  invoice_id = p_invoice_id
             AND corrected_inv_id = p_invoice_id
             AND corrected_line_number = p_line_number
             AND     adj_type = 'ADJ';
      --
      ------------------------------------------------------------------------------
      debug_info := 'Insert_Zero_Amt_Adjustments Step 2. Insert into AP_INVOICE_DISTRIBUTIONS_ALL';
      ------------------------------------------------------------------------------
      INSERT INTO ap_invoice_distributions_all(
                accounting_date,
                accrual_posted_flag,
                amount,
                asset_book_type_code,
                asset_category_id,
                assets_addition_flag,
                assets_tracking_flag,
                attribute_category,
                attribute1,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                award_id,
                awt_flag,
                awt_group_id,
		pay_awt_group_id,--bug6817107
                awt_tax_rate_id,
                base_amount,
                batch_id,
                cancellation_flag,
                cash_posted_flag,
                corrected_invoice_dist_id,
                corrected_quantity,
                country_of_supply,
                created_by,
                creation_date,
                description,
                dist_code_combination_id,
                dist_match_type,
                distribution_class,
                distribution_line_number,
                encumbered_flag,
                expenditure_item_date,
                expenditure_organization_id,
                expenditure_type,
                final_match_flag,
                global_attribute_category,
                global_attribute1,
                global_attribute10,
                global_attribute11,
                global_attribute12,
                global_attribute13,
                global_attribute14,
                global_attribute15,
                global_attribute16,
                global_attribute17,
                global_attribute18,
                global_attribute19,
                global_attribute2,
                global_attribute20,
                global_attribute3,
                global_attribute4,
                global_attribute5,
                global_attribute6,
                global_attribute7,
                global_attribute8,
                global_attribute9,
                income_tax_region,
                inventory_transfer_status,
                invoice_distribution_id,
                invoice_id,
                invoice_line_number,
                line_type_lookup_code,
                match_status_flag,
                matched_uom_lookup_code,
                merchant_document_number,
                merchant_name,
                merchant_reference,
                merchant_tax_reg_number,
                merchant_taxpayer_id,
                org_id,
                pa_addition_flag,
                pa_quantity,
                period_name,
                po_distribution_id,
                posted_flag,
                project_id,
                quantity_invoiced,
                rcv_transaction_id,
                reversal_flag,
                rounding_amt,
                set_of_books_id,
                task_id,
                type_1099,
                unit_price,
		--Freight and Special Charges
		rcv_charge_addition_flag,
                last_updated_by,
                last_update_date)
       SELECT d.accounting_date,
              d.accrual_posted_flag,
              d.amount,
              d.asset_book_type_code,
              d.asset_category_id,
              d.assets_addition_flag,
              d.assets_tracking_flag,
              d.attribute_category,
              d.attribute1,
              d.attribute10,
              d.attribute11,
              d.attribute12,
              d.attribute13,
              d.attribute14,
              d.attribute15,
              d.attribute2,
              d.attribute3,
              d.attribute4,
              d.attribute5,
              d.attribute6,
              d.attribute7,
              d.attribute8,
              d.attribute9,
              d.award_id,
              d.awt_flag,
              d.awt_group_id,
	      d.pay_awt_group_id,--bug6817107
              d.awt_tax_rate_id,
              d.base_amount,
              d.batch_id,
              d.cancellation_flag,
              d.cash_posted_flag,
              d.corrected_invoice_dist_id,
              d.corrected_quantity,
              d.country_of_supply,
              nvl(d.created_by,5),
              SYSDATE,
              d.description,
              d.dist_code_combination_id,
              d.dist_match_type,
              d.distribution_class,
              d.distribution_line_number,
              d.encumbered_flag,
              d.expenditure_item_date,
              d.expenditure_organization_id,
              d.expenditure_type,
              d.final_match_flag,
              d.global_attribute_category,
              d.global_attribute1,
              d.global_attribute10,
              d.global_attribute11,
              d.global_attribute12,
              d.global_attribute13,
              d.global_attribute14,
              d.global_attribute15,
              d.global_attribute16,
              d.global_attribute17,
              d.global_attribute18,
              d.global_attribute19,
              d.global_attribute2,
              d.global_attribute20,
              d.global_attribute3,
              d.global_attribute4,
              d.global_attribute5,
              d.global_attribute6,
              d.global_attribute7,
              d.global_attribute8,
              d.global_attribute9,
              d.income_tax_region,
              d.inventory_transfer_status,
              ap_invoice_distributions_s.NEXTVAL, --d.invoice_distribution_id,
              d.invoice_id,
              d.invoice_line_number,
              d.line_type_lookup_code,
              d.match_status_flag,
              d.matched_uom_lookup_code,
              d.merchant_document_number,
              d.merchant_name,
              d.merchant_reference,
              d.merchant_tax_reg_number,
              d.merchant_taxpayer_id,
              d.org_id,
              d.pa_addition_flag,
              d.pa_quantity,
              d.period_name,
              d.po_distribution_id,
              d.posted_flag,
              d.project_id,
              d.quantity_invoiced,
              d.rcv_transaction_id,
              d.reversal_flag,
              d.rounding_amt,
              d.set_of_books_id,
              d.task_id,
              d.type_1099,
              d.unit_price,
	      'N',
              nvl(d.created_by,5),
              SYSDATE
          FROM ap_ppa_invoice_dists_gt d,
               ap_ppa_invoice_lines_gt l
         --Introduced new and modified existing conditions for bug#9573078
          --d.instruction_id = p_instruction_id
	  WHERE  l.invoice_id = p_invoice_id
             AND l.corrected_inv_id = p_invoice_id
             AND l.corrected_line_number = p_line_number
             AND l.adj_type = 'ADJ'
             AND d.invoice_id = l.invoice_id
             AND d.invoice_line_number = l.line_number;
    --
    RETURN(TRUE);
    --

EXCEPTION
WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,SQLERRM);
      END IF;
    END IF;
    RETURN(FALSE);

END Insert_Zero_Amt_Adjustments;

/*=============================================================================
 |  FUNCTION - Validate_Temp_Ppa_Invoices()
 |
 |  DESCRIPTION
 |         This program leverages the Import Validation routines to validate
 |  all the PPA Invoices and Invoices Lines in the Temp table for a vendor.
 |  If any Invoice is returned with a status of 'N' then this program returns
 |  with a instr_status of N , meaning that instruction would be rejected in
 |  the interface table and neither Retroprice Adjustments would be made to
 |  the Original Invoices for the vendor nor any PPA documents would be created
 |  for the vendor.
 |
 |  PARAMETERS
 |      p_instruction_id
 |      p_base_currency_code
 |      p_multi_currency_flag
 |      p_set_of_books_id
 |      p_default_exchange_rate_type
 |      p_make_rate_mandatory_flag
 |      p_gl_date_from_get_info
 |      p_gl_date_from_receipt_flag
 |      p_positive_price_tolerance
 |      p_pa_installed
 |      p_qty_tolerance
 |      p_max_qty_ord_tolerance
 |      p_base_min_acct_unit
 |      p_base_precision
 |      p_chart_of_accounts_id
 |      p_freight_code_combination_id
 |      p_purch_encumbrance_flag
 |      p_calc_user_xrate
 |      p_default_last_updated_by
 |      p_default_last_update_login
 |      p_instr_status_flag
 |      P_calling_sequence - Calling sequence
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
FUNCTION Validate_Temp_Ppa_Invoices(
            p_instruction_id               IN     NUMBER,
            p_base_currency_code            IN     VARCHAR2,
            p_multi_currency_flag           IN     VARCHAR2,
            p_set_of_books_id               IN     NUMBER,
            p_default_exchange_rate_type    IN     VARCHAR2,
            p_make_rate_mandatory_flag      IN     VARCHAR2,
            p_gl_date_from_get_info         IN     DATE,
            p_gl_date_from_receipt_flag     IN     VARCHAR2,
            p_positive_price_tolerance      IN     NUMBER,
            p_pa_installed                  IN     VARCHAR2,
            p_qty_tolerance                 IN     NUMBER,
            p_max_qty_ord_tolerance         IN     NUMBER,
            p_base_min_acct_unit            IN     NUMBER,
            p_base_precision                IN     NUMBER,
            p_chart_of_accounts_id          IN     NUMBER,
            p_freight_code_combination_id   IN     NUMBER,
            p_purch_encumbrance_flag        IN     VARCHAR2,
            p_calc_user_xrate               IN     VARCHAR2,
            p_default_last_updated_by       IN     NUMBER,
            p_default_last_update_login     IN     NUMBER,
            p_instr_status_flag                OUT NOCOPY VARCHAR2,
            p_calling_sequence              IN     VARCHAR2)
RETURN BOOLEAN IS

CURSOR invoice_header  IS
SELECT  invoice_id,
        invoice_num,
        invoice_type_lookup_code,
        invoice_date,
        NULL, --po_number should be NULL at the Invoice Header level
        vendor_id,
        NULL, --vendor_num,
        NULL, --vendor_name,
        vendor_site_id,
        NULL, --vendor_site_code,
        invoice_amount,
        invoice_currency_code,
        exchange_rate,
        exchange_rate_type,
        exchange_date,
        terms_id,
        NULL, --terms_name,
        terms_date,
        description,
        awt_group_id,
        NULL, --awt_group_name,
	pay_awt_group_id,  --bug6817107
	NULL,--pay_awt_group_name --bug6817107
        amount_applicable_to_discount,
        NULL, --last_update_date,
        NULL, --last_updated_by,
        NULL, --last_update_login,
        creation_date,
        created_by,
        NULL, --status,
        trim(attribute_category) attribute_category,
        trim(attribute1) attribute1,
        trim(attribute2) attribute2,
        trim(attribute3) attribute3,
        trim(attribute4) attribute4,
        trim(attribute5) attribute5,
        trim(attribute6) attribute6,
        trim(attribute7) attribute7,
        trim(attribute8) attribute8,
        trim(attribute9) attribute9,
        trim(attribute10) attribute10,
        trim(attribute11) attribute11,
        trim(attribute12) attribute12,
        trim(attribute13) attribute13,
        trim(attribute14) attribute14,
        trim(attribute15) attribute15,
        trim(global_attribute_category) global_attribute_category,
        trim(global_attribute1) global_attribute1,
        trim(global_attribute2) global_attribute2,
        trim(global_attribute3) global_attribute3,
        trim(global_attribute4) global_attribute4,
        trim(global_attribute5) global_attribute5,
        trim(global_attribute6) global_attribute6,
        trim(global_attribute7) global_attribute7,
        trim(global_attribute8) global_attribute8,
        trim(global_attribute9) global_attribute9,
        trim(global_attribute10) global_attribute10,
        trim(global_attribute11) global_attribute11,
        trim(global_attribute12) global_attribute12,
        trim(global_attribute13) global_attribute13,
        trim(global_attribute14) global_attribute14,
        trim(global_attribute15) global_attribute15,
        trim(global_attribute16) global_attribute16,
        trim(global_attribute17) global_attribute17,
        trim(global_attribute18) global_attribute18,
        trim(global_attribute19) global_attribute19,
        trim(global_attribute20) global_attribute20,
        payment_currency_code,
        payment_cross_rate,
        NULL, --payment_cross_rate_type,
        NULL, --payment_cross_rate_date,
        NULL, --doc_category_code,
        NULL, --voucher_num,
        payment_method_code, --4552701
        pay_group_lookup_code,
        goods_received_date,
        invoice_received_date,
        NULL, --gl_date,
        accts_pay_code_combination_id,
        NULL, --accts_pay_code_concatenated, -- bug 6603310
        exclusive_payment_flag,
        NULL, --prepay_num,
        NULL, --prepay_line_num,
        NULL, --prepay_apply_amount,
        NULL, --prepay_gl_date,
        NULL, --invoice_includes_prepay_flag,
        NULL, --no_xrate_base_amount,
        requester_id,
        org_id,
        NULL, --operating_unit,
        source,
        NULL, --group_id,
        NULL, --request_id,
        NULL, --workflow_flag,
        NULL, --vendor_email_address,
        NULL, --calc_tax_during_import_flag,
        NULL, --control_amount,
        NULL, --add_tax_to_inv_amt_flag,
        NULL, --tax_related_invoice_id,
        NULL, --taxation_country,
        NULL, --document_sub_type,
        NULL, --supplier_tax_invoice_number,
        NULL, --supplier_tax_invoice_date,
        NULL, --supplier_tax_exchange_rate,
        NULL, --tax_invoice_recording_date,
        NULL, --tax_invoice_internal_seq,
        NULL, --legal_entity_id,
        NULL, --set_of_books_id,
        NULL, --tax_only_rcv_matched_flag,
        NULL, --tax_only_flag,
        NULL, --apply_advances_flag
	NULL, --application_id
	NULL, --product_table
	NULL, --reference_key1
	NULL, --reference_key2
	NULL, --reference_key3
	NULL, --reference_key4
	NULL, --reference_key5
	NULL, --reference_1
	NULL, --reference_2
        NULL,  --net_of_retainage_flag
        null,  --4552701, added nulls below so this code would compile
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
	null,  -- original_invoice_amount bug7357218
	null,   -- dispute_reason bug7357218
	null,	-- 7535348 adding nulls to compile code, after third party payments
	null,
	null,
	null,
	null,
	null
	/* Added for bug 10226070 */
	,NULL /* Requester_last_name */
	,NULL /* Requester_first_name */
  FROM  ap_ppa_invoices_gt
  WHERE instruction_id = p_instruction_id;

---
CURSOR invoice_lines(
               c_invoice_id  NUMBER) IS
SELECT NULL,   --rowid
       invoice_line_id, --invoice_line_id,
       line_type_lookup_code,
       line_number,
       NULL, --line_group_number,
       amount,
       NULL, -- base amount
       accounting_date,
       NULL, --period name
       deferred_acctg_flag,
       NULL, --def_acctg_start_date,
       NULL, --def_acctg_end_date,
       NULL, --def_acctg_number_of_periods,
       NULL, --def_acctg_period_type,
       description,
       prorate_across_all_items,
       NULL, -- match_type
       po_header_id,
       NULL, --po_number,
       po_line_id,
       NULL, --po_line_number,
       po_release_id,
       NULL, --release_num,
       po_line_location_id,
       NULL, --po_shipment_num,
       po_distribution_id,
       NULL, --po_distribution_num,
       unit_meas_lookup_code,
       inventory_item_id,
       item_description,
       quantity_invoiced,
       NULL, --ship_to_location_code,
       unit_price,
       final_match_flag,
       NULL, --distribution_set_id,
       NULL, --distribution_set_name,
       NULL, -- partial segments
       NULL, --dist_code_concatenated,
       NULL, --dist_code_combination_id,
       awt_group_id,
       NULL, --awt_group_name,
       pay_awt_group_id,  --bug6817107
       NULL,--pay_awt_group_name --bug6817107
       NULL, --balancing_segment,
       NULL, --cost_center_segment,
       NULL, --account_segment,
       attribute_category,
       attribute1,
       attribute2,
       attribute3,
       attribute4,
       attribute5,
       attribute6,
       attribute7,
       attribute8,
       attribute9,
       attribute10,
       attribute11,
       attribute12,
       attribute13,
       attribute14,
       attribute15,
       global_attribute_category,
       global_attribute1,
       global_attribute2,
       global_attribute3,
       global_attribute4,
       global_attribute5,
       global_attribute6,
       global_attribute7,
       global_attribute8,
       global_attribute9,
       global_attribute10,
       global_attribute11,
       global_attribute12,
       global_attribute13,
       global_attribute14,
       global_attribute15,
       global_attribute16,
       global_attribute17,
       global_attribute18,
       global_attribute19,
       global_attribute20,
       project_id,
       task_id,
       award_id,
       expenditure_type,
       expenditure_item_date,
       expenditure_organization_id,
       NULL, --pa_addition_flag,
       pa_quantity,
       NULL, --stat_amount,
       type_1099,
       income_tax_region,
       assets_tracking_flag,
       asset_book_type_code,
       asset_category_id,
       serial_number,
       manufacturer,
       model_number,
       NULL, --warranty_number,
       NULL, --price_correction_flag,
       NULL, --price_correct_inv_num,
       NULL, -- corrected_inv_id           -- for price corrections via import
       NULL, --price_correct_inv_line_num,
       NULL, --receipt_number,
       NULL, --receipt_line_number,
       rcv_transaction_id,
       NULL, --rcv_shipment_line_id  --Bug7344899
       NULL, --match_option,
       NULL, --packing_slip,
       NULL, --vendor_item_num,
       NULL, --taxable_flag,
       NULL, --pa_cc_ar_invoice_id,
       NULL, --pa_cc_ar_invoice_line_num,
       NULL, --pa_cc_processed_code,
       NULL, --reference_1,
       NULL, --reference_2,
       credit_card_trx_id,
       requester_id,
       org_id,
       NULL, -- program_application_id
       NULL, -- program_id
       NULL, -- request_id
       NULL,  -- program_update_date
       NULL, --control_amount,
       NULL, --assessable_value,
       default_dist_ccid,
       primary_intended_use,
       ship_to_location_id,
       product_type,
       product_category,
       product_fisc_classification,
       user_defined_fisc_class,
       trx_business_category,
       tax_regime_code,
       tax,
       NULL,  --   tax_jurisdiction_code,
       tax_status_code,
       tax_rate_id,
       tax_rate_code,
       tax_rate,
       NULL,         --incl_in_taxable_line_flag
       NULL,	     --application_id
       NULL,	     --product_table
       NULL,	     --reference_key1
       NULL,	     --reference_key2
       NULL,	     --reference_key3
       NULL,         --reference_key4
       NULL,         --reference_key5
       NULL,	     --purchasing_category
       NULL,	     --purchasing_category_id
       cost_factor_id,  --cost_factor_id
       NULL,          --cost_factor_name
       NULL,	      		--source_application_id
       NULL,          		--source_entity_code
       NULL,          		--source_event_class_code
       NULL,	      		--source_trx_id
       NULL,	        	--source_line_id
       NULL,			--source_trx_level_type
       NULL,			--tax_classification_code
       NULL,                    --retained_amount
       NULL,                     --amount_includes_tax_flag  -- Bug 5436859
       --Bug6277609 starts Added the following columns to record
       NULL,                    --cc_reversal_flag
       NULL,                    --company_prepaid_invoice_id,
       NULL,                    --expense_group
       NULL,                    --justification
       NULL,                    --merchant_document_number,
       NULL,                    --merchant_name
       NULL,                    --merchant_reference
       NULL,                    --merchant_taxpayer_id
       NULL,                    --merchant_tax_reg_number
       NULL,                    --receipt_conversion_rate
       NULL,                    --receipt_conversion_amount
       NULL,                    --receipt_currency_code
       NULL                    --country_of_supply
       ,NULL			  --expense_start_date. Bug 8658097
       ,NULL			  --expense_end_date. Bug 8658097
       --Bug6277609 ends
	   /* Added for bug 10226070 */
   	,NULL /* Requester_last_name */
   	,NULL /* Requester_first_name */
 FROM ap_ppa_invoice_lines_gt
WHERE invoice_id = c_invoice_id
 ORDER BY line_number;

l_invoice_header_rec  AP_IMPORT_INVOICES_PKG.r_invoice_info_rec;
l_invoice_header_list AP_IMPORT_INVOICES_PKG.t_invoice_table;
l_invoice_lines_rec   AP_IMPORT_INVOICES_PKG.r_line_info_Rec;
l_invoice_lines_list  AP_IMPORT_INVOICES_PKG.t_lines_table;


l_fatal_error_flag       VARCHAR2(1);             -- OUT NOCOPY
l_invoice_status         VARCHAR2(1) :='Y';
l_instruction_status     VARCHAR2(1);
l_match_mode             VARCHAR2(25);
l_min_acct_unit_inv_curr NUMBER;
l_precision_inv_curr     NUMBER;

l_conc_request_id        NUMBER;
l_prepay_appl_info       ap_prepay_pkg.Prepay_Appl_Tab;
l_prepay_period_name     VARCHAR2(25);
l_allow_interest_invoices VARCHAR2(1);

--Contract Payments: Tolerance Redesign Project
l_positive_price_tolerance NUMBER;
l_negative_price_tolerance NUMBER;
l_qty_tolerance 	   NUMBER;
l_qty_rec_tolerance        NUMBER;
l_max_qty_ord_tolerance    NUMBER;
l_max_qty_rec_tolerance    NUMBER;
l_amt_tolerance		   NUMBER;
l_amt_rec_tolerance        NUMBER;
l_max_amt_ord_tolerance    NUMBER;
l_max_amt_rec_tolerance	   NUMBER;
l_goods_ship_amt_tolerance NUMBER;
l_goods_rate_amt_tolerance NUMBER;
l_goods_total_amt_tolerance NUMBER;
l_services_ship_amt_tolerance  NUMBER;
l_services_rate_amt_tolerance  NUMBER;
l_services_total_amt_tolerance NUMBER;
l_prepay_invoice_id	 NUMBER;
l_prepay_case_name	 VARCHAR2(50);

debug_info               VARCHAR2(1000);
current_calling_sequence VARCHAR2(1000);

ppa_validation_failure   EXCEPTION;
l_api_name constant VARCHAR2(200) := 'Validate_Temp_Ppa_Invoices';


BEGIN
   --
   current_calling_sequence :=
    'AP_RETRO_PRICING_PKG.Validate_Temp_Ppa_Invoices<-'
    ||P_calling_sequence;

    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_RETRO_PRICING_PKG.Validate_Temp_Ppa_Invoices(+)');
    END IF;
   --
   ---------------------------------------------------------------------------
   debug_info := 'Validate_Temp_Ppa_Invoices Step 1. Open Invoice_Header';
   ---------------------------------------------------------------------------
   OPEN invoice_header;
   FETCH invoice_header
   BULK COLLECT INTO  l_invoice_header_list;
   CLOSE invoice_header;

   --------------------------------------------------------------------------
     debug_info := 'Validate_Temp_Ppa_Invoices Step 2. Invoice Num: '||
     		    l_invoice_header_rec.invoice_num;
   --------------------------------------------------------------------------
   FOR i IN 1..l_invoice_header_list.COUNT  LOOP

      l_invoice_header_rec := l_invoice_header_list(i);

      SELECT auto_calculate_interest_flag
      INTO l_allow_interest_invoices
      FROM ap_system_parameters
      WHERE org_id = l_invoice_header_rec.org_id;

      --
      IF (AP_IMPORT_VALIDATION_PKG.v_check_invoice_validation
               (l_invoice_header_rec,           -- IN OUT NOCOPY
                l_match_mode,                   -- OUT    ---no longer used.
                l_min_acct_unit_inv_curr,       -- OUT NOCOPY  --used in lines val. for dist set
                l_precision_inv_curr,           -- OUT NOCOPY --in val. of lineamt and inv amt.
		l_positive_price_tolerance,	-- OUT
		l_negative_price_tolerance,     -- OUT
		l_qty_tolerance	,		-- OUT
		l_qty_rec_tolerance,		-- OUT
		l_max_qty_ord_tolerance,	-- OUT
		l_max_qty_rec_tolerance,	-- OUT
		l_amt_tolerance,		-- OUT
		l_amt_rec_tolerance,		-- OUT
		l_max_amt_ord_tolerance,	-- OUT
		l_max_amt_rec_tolerance ,       -- OUT
		l_goods_ship_amt_tolerance,     -- OUT
		l_goods_rate_amt_tolerance ,    -- OUT
		l_goods_total_amt_tolerance,    -- OUT
		l_services_ship_amt_tolerance,  -- OUT
		l_services_rate_amt_tolerance,  -- OUT
		l_services_total_amt_tolerance, -- OUT
                p_base_currency_code,           -- IN
                p_multi_currency_flag,          -- IN
                p_set_of_books_id,              -- IN
                p_default_exchange_rate_type,   -- IN
                p_make_rate_mandatory_flag,     -- IN
                p_default_last_updated_by,      -- IN
                p_default_last_update_login,    -- IN
                l_fatal_error_flag,             -- OUT NOCOPY
                l_invoice_status,               -- OUT NOCOPY
                p_calc_user_xrate,              -- IN
                l_prepay_period_name,           -- IN OUT
		l_prepay_invoice_id,		-- OUT
		l_prepay_case_name,		-- OUT
                l_conc_request_id,               --IN
		l_allow_interest_invoices,	--
                current_calling_sequence) <> TRUE) THEN
      --
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'v_check_invoice_validation<-'||current_calling_sequence);
        END IF;
        Raise ppa_validation_failure;
        --
      END IF; --v_check_invoice_validation

      debug_info := 'Temp Invoice Validation Status,fatal_error_flag are : '||l_invoice_status||','||l_fatal_error_flag;
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
           AP_IMPORT_UTILITIES_PKG.Print(
	       AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;

      IF (( l_invoice_status = 'Y') AND
          (NVL(l_fatal_error_flag,'N') = 'N')) THEN

	 --  Start 9740137
         ---------------------------------------------------------------------
         debug_info := 'Validate_Temp_Ppa_Invoices Step 2.1 '
                       ||'Updating exchange rate in gt header table';
         ---------------------------------------------------------------------

           IF( l_invoice_header_rec.EXCHANGE_RATE IS NOT NULL) THEN

	     UPDATE  ap_ppa_invoices_gt
             set exchange_rate = l_invoice_header_rec.EXCHANGE_RATE
             where invoice_id = l_invoice_header_rec.invoice_id
               and exchange_rate is null
	       and exchange_rate_type <> 'User';

	  END IF;

        --End 9740137
         ---------------------------------------------------------------------
         debug_info := 'Validate_Temp_Ppa_Invoices Step 3. '
                       ||'Open invoice_lines';
         ---------------------------------------------------------------------
         OPEN invoice_lines(l_invoice_header_Rec.invoice_id);
         FETCH invoice_lines
         BULK COLLECT INTO  l_invoice_lines_list;
         CLOSE invoice_lines;
         --
         ---------------------------------------------------------------------
         debug_info := 'Validate_Temp_Ppa_Invoices Step 4. Call '
                       ||'v_check_lines_validation';
         ---------------------------------------------------------------------
         IF (AP_IMPORT_VALIDATION_PKG.v_check_lines_validation (
                    l_invoice_header_Rec,             -- IN
                    l_invoice_lines_list,             -- IN --change it to IN parameter
                    p_gl_date_from_get_info,          -- IN
                    p_gl_date_from_receipt_flag,      -- IN
                    p_positive_price_tolerance,       -- IN
                    p_pa_installed,                   -- IN
                    l_qty_tolerance,                  -- IN
		    l_amt_tolerance,		      -- IN
                    l_max_qty_ord_tolerance,          -- IN
		    l_max_amt_ord_tolerance,	      -- IN
                    l_min_acct_unit_inv_curr,         -- IN from v_check_invoice_validation
                    l_precision_inv_curr,             -- IN from v_check_invoice_validation
                    p_base_currency_code,             -- IN
                    p_base_min_acct_unit,             -- IN
                    p_base_precision,                 -- IN
                    p_set_of_books_id,                -- IN
                    NULL,                             -- IN --5448579. Asset Book
                    p_chart_of_accounts_id,           -- IN
                    p_freight_code_combination_id,    -- IN
                    p_purch_encumbrance_flag,         -- IN
		    NULL, --p_retainage_ccid	      -- IN
                    p_default_last_updated_by,        -- IN
                    p_default_last_update_login,      -- IN
                    l_invoice_status,                 -- OUT NOCOPY
                    current_calling_sequence) <> TRUE) THEN

            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
                  'v_check_lines_validation<-'||current_calling_sequence);
            END IF;
            --
            Raise ppa_validation_failure;
            --
         END IF;  --v_check_lines_validation
         --
      END IF; -- l_invoice_status
      --
      debug_info := 'Temp Invoice Line Validation Status,fatal_error_flag are : '||l_invoice_status||','||l_fatal_error_flag;
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
           AP_IMPORT_UTILITIES_PKG.Print(
               AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;

      IF  ((l_invoice_status = 'N')  AND
           NVL(l_fatal_error_flag,'N') = 'N' ) THEN
          --
          p_instr_status_flag := 'N';
      ELSE
          p_instr_status_flag := 'Y';
          --
      END IF;
      --
   END LOOP;  --invoice_header
   --

   -------------------------------------------------------------------------
   debug_info := 'Validate_Temp_Ppa_Invoices Step 5. Clear Header PL/SQL table';
   -------------------------------------------------------------------------
   l_invoice_header_list.DELETE;
   l_invoice_lines_list.DELETE;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_RETRO_PRICING_PKG.Validate_Temp_Ppa_Invoices(-)');
  END IF;

   RETURN(TRUE);
   --
EXCEPTION
WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,SQLERRM);
      END IF;
    END IF;
    --
    IF ( invoice_header%ISOPEN ) THEN
        CLOSE invoice_header;
    END IF;
    --
    IF ( invoice_lines%ISOPEN ) THEN
        CLOSE invoice_lines;
    END IF;
    --
    RETURN(FALSE);

END Validate_Temp_Ppa_Invoices;


/*=============================================================================
 |  FUNCTION - Insert_Ppa_Invoices()
 |
 |  DESCRIPTION
 |      After validating a all proposed PPA's for a vendor(instruction), this
 |  function insert PPA documents in the Transaction Tables. It also creates payment schedules for the
 |  for all the PPA invoices for a valid insruction(Vendor).
 |
 |  PARAMETERS
 |      p_instruction_id
 |      p_ppa_invoices_count
 |      p_ppa_invoices_total
 |      P_calling_sequence - Calling sequence
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
FUNCTION Insert_Ppa_Invoices(
             p_instruction_id         IN            NUMBER,
             p_ppa_invoices_count         OUT NOCOPY NUMBER,
             p_ppa_invoices_total         OUT NOCOPY NUMBER,
             p_calling_sequence        IN            VARCHAR2)
RETURN BOOLEAN IS

CURSOR ppa_invoices IS
SELECT invoice_id,
       vendor_id,
       vendor_site_id,
       terms_id,
       terms_date,
       payment_cross_rate,
       invoice_currency_code,
       payment_currency_code,
       invoice_amount,
       base_amount,
       amount_applicable_to_discount,
       payment_method_code, --4552701
       exclusive_payment_flag,
       FND_GLOBAL.user_id, --bugfix:4681253
       FND_GLOBAL.user_id, --bugfix:4681253
       batch_id,
       org_id
FROM   ap_ppa_invoices_gt
WHERE  instruction_id = p_instruction_id
AND    instr_status_flag = 'Y';

l_ppa_invoice_id                NUMBER;

l_vendor_id                     AP_INVOICES_ALL.vendor_id%TYPE;
l_vendor_site_id                AP_INVOICES_ALL.vendor_site_id%TYPE;
l_payment_cross_rate            AP_INVOICES_ALL.payment_cross_rate%TYPE;
l_invoice_currency_code         AP_INVOICES_ALL.invoice_currency_code%TYPE;
l_payment_currency_code         AP_INVOICES_ALL.payment_currency_code%TYPE;
l_payment_cross_rate_date       AP_INVOICES_ALL.payment_cross_rate_date%TYPE;
l_invoice_type_lookup_code      AP_INVOICES_ALL.invoice_type_lookup_code%TYPE;
l_payment_method_code           iby_payment_methods_vl.payment_method_code%TYPE;
l_amt_applicable_to_discount    AP_INVOICES_ALL.amount_applicable_to_discount%TYPE;
l_invoice_amount                AP_INVOICES_ALL.invoice_amount%TYPE;
l_base_amount                   AP_INVOICES_ALL.base_amount%TYPE;
l_exclusive_payment_flag        AP_INVOICES_ALL.exclusive_payment_flag%TYPE;
l_terms_id                      AP_INVOICES_ALL.terms_id%TYPE;
l_terms_date                    AP_INVOICES_ALL.terms_date%TYPE;
l_batch_id                      AP_INVOICES_ALL.batch_id%TYPE;
l_set_of_books_id               AP_INVOICES_ALL.set_of_books_id%TYPE;
l_org_id                        AP_INVOICES_ALL.org_id%TYPE;
l_doc_category_code             AP_INVOICES_ALL.doc_category_code%TYPE;
l_doc_sequence_id               AP_INVOICES_ALL.doc_sequence_id%TYPE;
l_doc_sequence_value            AP_INVOICES_ALL.doc_sequence_value%TYPE;

l_pay_curr_invoice_amount       NUMBER;
l_payment_priority              NUMBER;
l_invoice_amount_limit          NUMBER;
l_hold_future_payments_flag     VARCHAR2(1);
l_supplier_hold_reason          VARCHAR2(240);
l_seq_num_profile               VARCHAR2(80);
l_return_code                   NUMBER;
l_dbseqnm                       VARCHAR2(30);
l_seqassid                      NUMBER;

l_created_by                    NUMBER;
l_last_updated_by               NUMBER;
l_last_update_login             NUMBER;

l_ppa_invoices_count            NUMBER;
l_ppa_invoices_total            NUMBER;
i                               INTEGER;

debug_info                      VARCHAR2(1000);
current_calling_sequence        VARCHAR2(1000);

ppa_creation_failure            EXCEPTION;
l_api_name constant varchar2(200) := 'Insert_PPa_Invoices';

BEGIN
   --
   current_calling_sequence :=
    'AP_RETRO_PRICING_PKG.Insert_Ppa_Invoices<-'
    ||P_calling_sequence;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_RETRO_PRICING_PKG.Insert_Ppa_Invoices(+)');
   END IF;
   --
   i := 1;
   l_ppa_invoices_count := 0;
   l_ppa_invoices_total  := 0;
   --
   -----------------------------------------------------------------------
   debug_info := 'Insert_Ppa_Invoices Step 1. Open cursor Ppa_invoices';
   IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
   END IF;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,debug_info);
   END IF;

   -----------------------------------------------------------------------
   OPEN  ppa_invoices;
   LOOP
      FETCH ppa_invoices
      INTO l_ppa_invoice_id,
           l_vendor_id,
           l_vendor_site_id,
           l_terms_id,
           l_terms_date,
           l_payment_cross_rate,
           l_invoice_currency_code,
           l_payment_currency_code,
           l_invoice_amount,
           l_base_amount,
           l_amt_applicable_to_discount,
           l_payment_method_code,
           l_exclusive_payment_flag,
           l_created_by,
	   l_last_updated_by,  --Bugfix:4681253
           l_batch_id,
           l_org_id;
      EXIT WHEN ppa_invoices%NOTFOUND;
      --
      l_ppa_invoices_count  := l_ppa_invoices_count + i;
      l_ppa_invoices_total  := l_ppa_invoices_total + l_invoice_amount;
      --
      ------------------------------------------------------------------
      debug_info := 'Insert_Ppa_Invoices Step 2. Get Info';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
         AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,debug_info);
      END IF;
      -------------------------------------------------------------------
      IF (l_invoice_currency_code <> l_payment_currency_code) AND
         (l_payment_cross_rate is NOT NULL) THEN
         --
         l_pay_curr_invoice_amount := ap_utilities_pkg.ap_round_currency(
                                        l_invoice_amount *l_payment_cross_rate,
                                        l_payment_currency_code);
      --Bugfix:4681253
      ELSE
         l_pay_curr_invoice_amount := l_invoice_amount;

      END IF;
       --
      SELECT DECODE(l_invoice_type_lookup_code,
                     'CREDIT','N',
                      l_exclusive_payment_flag), --4552701 don't get this flag from vendors table
            payment_priority,
            invoice_amount_limit,
            hold_future_payments_flag,
            hold_reason
       INTO l_exclusive_payment_flag,
            l_payment_priority,
            l_invoice_amount_limit,
            l_hold_future_payments_flag,
            l_supplier_hold_reason
       FROM po_vendor_sites_all
      WHERE vendor_id = l_vendor_id
        AND vendor_site_id = l_vendor_site_id;
      --
  -- bug8514744, moved the fetch of the next doc sequence, and the
  -- doc sequence value from apretrub.pls at the time of PPA GT
  -- insertion, to the time of actual invoice creation
  -------------------------------------------
  debug_info := 'Create_Ppa_Invoice Step :4 Doc_sequence_Num';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(
         AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
   END IF;
  -------------------------------------------
  FND_PROFILE.GET('UNIQUE:SEQ_NUMBERS',l_seq_num_profile);
  IF (l_seq_num_profile  IN ('A','P')) THEN

     l_doc_category_code := 'PO ADJ INV';

     --Bug5769161 (adding exception handling)
     BEGIN

     SELECT SEQ.db_sequence_name,
            SEQ.doc_sequence_id,
            SA.doc_sequence_assignment_id,
            asp.set_of_books_id
       INTO l_dbseqnm,
            l_doc_sequence_id,
            l_seqassid,
            l_set_of_books_id
       FROM fnd_document_sequences SEQ,
            fnd_doc_sequence_assignments SA,
            ap_system_parameters_all asp
      WHERE SEQ.doc_sequence_id        = SA.doc_sequence_id
        AND SA.application_id          = 200
        AND SA.category_code           = l_doc_category_code
        AND (NVL(SA.method_code,'A') = 'A')
        AND (SA.set_of_books_id = asp.set_of_books_id)
        AND asp.org_id = l_org_id
        AND SYSDATE -- never null
             BETWEEN SA.start_date
             AND NVL(SA.end_date, TO_DATE('31/12/4712','DD/MM/YYYY'));

     ---------------------------------------
     debug_info :=  'Create_Ppa_Invoice Step :5 Get doc sequence val';
     IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
       AP_IMPORT_UTILITIES_PKG.Print(
         AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
     END IF;
     ----------------------------------------

     l_return_code := FND_SEQNUM.GET_SEQ_VAL(
                         200,
                         l_doc_category_code,
                         l_set_of_books_id,
                         'A',
                         SYSDATE,
                         l_doc_sequence_value,
                         l_doc_sequence_id,
                         'N','N');

      debug_info := 'After fetching the doc sequence'||
                     l_doc_category_code||'--'||
                     l_set_of_books_id||'--'||
                     l_doc_sequence_value||'--'||
                     l_doc_sequence_id;

      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
         AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,debug_info);
      END IF;


     EXCEPTION
       WHEN no_data_found THEN
            NULL;

     END;

     debug_info := 'after FND_SEQNUM.GET_SEQ_VAL';
     IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
       AP_IMPORT_UTILITIES_PKG.Print(
         AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
     END IF;

  END IF;

      ------------------------------------------------------------------------
      debug_info := 'Insert_Ppa_Invoices Step 3. Insert into AP_INVOICES_ALL, l_ppa_invoice_id is'||l_ppa_invoice_id;
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
         AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,debug_info);
      END IF;
      ------------------------------------------------------------------------
      INSERT INTO ap_invoices_All(
                accts_pay_code_combination_id,
                amount_applicable_to_discount,
                approval_ready_flag,
                attribute_category,
                attribute1,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                award_id,
                awt_flag,
                awt_group_id,
		pay_awt_group_id,--bug6817107
                base_amount,
                description,
                exchange_date,
                exchange_rate,
                exchange_rate_type,
                exclusive_payment_flag,
                expenditure_item_date,
                expenditure_organization_id,
                expenditure_type,
                global_attribute_category,
                global_attribute1,
                global_attribute10,
                global_attribute11,
                global_attribute12,
                global_attribute13,
                global_attribute14,
                global_attribute15,
                global_attribute16,
                global_attribute17,
                global_attribute18,
                global_attribute19,
                global_attribute2,
                global_attribute20,
                global_attribute3,
                global_attribute4,
                global_attribute5,
                global_attribute6,
                global_attribute7,
                global_attribute8,
                global_attribute9,
                goods_received_date,
                invoice_amount,
                invoice_currency_code,
                invoice_date,
                invoice_id,
                invoice_num,
                invoice_received_date,
                invoice_type_lookup_code,
                org_id,
                pa_default_dist_ccid,
                pay_group_lookup_code,
                payment_cross_rate,
                payment_currency_code,
                payment_method_code,
                payment_status_flag,
                project_id,
                requester_id,
                set_of_books_id,
                source,
                task_id,
                terms_date,
                terms_id,
                vendor_id,
                vendor_site_id,
                wfapproval_status,
                creation_date,
                created_by,
                last_updated_by,
                last_update_date,
                last_update_login,
		gl_date,
                APPLICATION_ID ,
                BANK_CHARGE_BEARER ,
                DELIVERY_CHANNEL_CODE ,
                DISC_IS_INV_LESS_TAX_FLAG ,
                DOCUMENT_SUB_TYPE	,
                EXCLUDE_FREIGHT_FROM_DISCOUNT	,
                EXTERNAL_BANK_ACCOUNT_ID	,
                LEGAL_ENTITY_ID	,
                NET_OF_RETAINAGE_FLAG	,
                PARTY_ID	,
                PARTY_SITE_ID	,
                PAYMENT_CROSS_RATE_DATE	,
                PAYMENT_CROSS_RATE_TYPE	,
                PAYMENT_FUNCTION	,
                PAYMENT_REASON_CODE	,
                PAYMENT_REASON_COMMENTS	,
                PAY_CURR_INVOICE_AMOUNT	,
                PAY_PROC_TRXN_TYPE_CODE	,
                PORT_OF_ENTRY_CODE	,
                POSTING_STATUS	,
                PO_HEADER_ID	,
                PRODUCT_TABLE	,
                PROJECT_ACCOUNTING_CONTEXT	,
                QUICK_PO_HEADER_ID	,
                REFERENCE_1	,
                REFERENCE_2	,
                REFERENCE_KEY1	,
                REFERENCE_KEY2	,
                REFERENCE_KEY3	,
                REFERENCE_KEY4	,
                REFERENCE_KEY5	,
                REMITTANCE_MESSAGE1	,
                REMITTANCE_MESSAGE2	,
                REMITTANCE_MESSAGE3	,
                SETTLEMENT_PRIORITY	,
                SUPPLIER_TAX_EXCHANGE_RATE ,
                SUPPLIER_TAX_INVOICE_DATE	,
                SUPPLIER_TAX_INVOICE_NUMBER	,
                TAXATION_COUNTRY	,
                TAX_INVOICE_INTERNAL_SEQ ,
                TAX_INVOICE_RECORDING_DATE	,
                TAX_RELATED_INVOICE_ID	,
                TRX_BUSINESS_CATEGORY	,
                UNIQUE_REMITTANCE_IDENTIFIER	,
                URI_CHECK_DIGIT	,
                USER_DEFINED_FISC_CLASS,
                DOC_CATEGORY_CODE,
                DOC_SEQUENCE_ID,
                DOC_SEQUENCE_VALUE)
      SELECT    accts_pay_code_combination_id,
                amount_applicable_to_discount,
                approval_ready_flag,
                attribute_category,
                attribute1,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                award_id,
                awt_flag,
                awt_group_id,
		pay_awt_group_id,--bug6817107
                base_amount,
                description,
                exchange_date,
                exchange_rate,
                exchange_rate_type,
                exclusive_payment_flag,
                expenditure_item_date,
                expenditure_organization_id,
                expenditure_type,
                global_attribute_category,
                global_attribute1,
                global_attribute10,
                global_attribute11,
                global_attribute12,
                global_attribute13,
                global_attribute14,
                global_attribute15,
                global_attribute16,
                global_attribute17,
                global_attribute18,
                global_attribute19,
                global_attribute2,
                global_attribute20,
                global_attribute3,
                global_attribute4,
                global_attribute5,
                global_attribute6,
                global_attribute7,
                global_attribute8,
                global_attribute9,
                goods_received_date,
                invoice_amount,
                invoice_currency_code,
                invoice_date,
                invoice_id,
                invoice_num,
                invoice_received_date,
                invoice_type_lookup_code,
                org_id,
                pa_default_dist_ccid,
                pay_group_lookup_code,
                payment_cross_rate,
                payment_currency_code,
                payment_method_code,
                payment_status_flag,
                project_id,
                requester_id,
                set_of_books_id,
                source,
                task_id,
                terms_date,
                terms_id,
                vendor_id,
                vendor_site_id,
                wfapproval_status,
                SYSDATE,                   --creation_date
                FND_GLOBAL.user_id,        --created_by
                FND_GLOBAL.user_id,        --last_updated_by
                SYSDATE,                   --last_update_date
                FND_GLOBAL.conc_login_id,   --last_update_login
		SYSDATE,			   --4681253
                APPLICATION_ID ,
                BANK_CHARGE_BEARER ,
                DELIVERY_CHANNEL_CODE ,
                DISC_IS_INV_LESS_TAX_FLAG ,
                DOCUMENT_SUB_TYPE       ,
                EXCLUDE_FREIGHT_FROM_DISCOUNT   ,
                EXTERNAL_BANK_ACCOUNT_ID        ,
                LEGAL_ENTITY_ID ,
                NET_OF_RETAINAGE_FLAG   ,
                PARTY_ID        ,
                PARTY_SITE_ID   ,
                PAYMENT_CROSS_RATE_DATE     ,
                PAYMENT_CROSS_RATE_TYPE ,
                PAYMENT_FUNCTION        ,
                PAYMENT_REASON_CODE     ,
                PAYMENT_REASON_COMMENTS ,
                PAY_CURR_INVOICE_AMOUNT ,
                PAY_PROC_TRXN_TYPE_CODE ,
                PORT_OF_ENTRY_CODE      ,
                POSTING_STATUS  ,
                PO_HEADER_ID    ,
                PRODUCT_TABLE   ,
                PROJECT_ACCOUNTING_CONTEXT      ,
                QUICK_PO_HEADER_ID      ,
                REFERENCE_1     ,
                REFERENCE_2     ,
                REFERENCE_KEY1  ,
                REFERENCE_KEY2  ,
                REFERENCE_KEY3  ,
                REFERENCE_KEY4  ,
                REFERENCE_KEY5  ,
                REMITTANCE_MESSAGE1     ,
                REMITTANCE_MESSAGE2     ,
                REMITTANCE_MESSAGE3     ,
                SETTLEMENT_PRIORITY     ,
                SUPPLIER_TAX_EXCHANGE_RATE ,
                SUPPLIER_TAX_INVOICE_DATE       ,
                SUPPLIER_TAX_INVOICE_NUMBER     ,
                TAXATION_COUNTRY        ,
                TAX_INVOICE_INTERNAL_SEQ ,
                TAX_INVOICE_RECORDING_DATE      ,
                TAX_RELATED_INVOICE_ID  ,
                TRX_BUSINESS_CATEGORY   ,
                UNIQUE_REMITTANCE_IDENTIFIER    ,
                URI_CHECK_DIGIT ,
                USER_DEFINED_FISC_CLASS,
                l_doc_category_code,
                l_doc_sequence_id,
                l_doc_sequence_value
      FROM      ap_ppa_invoices_gt
      WHERE     instruction_id = p_instruction_id
      AND       invoice_id = l_ppa_invoice_id
      AND       instr_status_flag = 'Y';
      --
      -------------------------------------------------------------------
      debug_info := 'Insert_Ppa_Invoices Step 4. AP_Create_From_Terms';
      debug_info := 'p_invoice_id : '||l_ppa_invoice_id
      		   || ',p_terms_id : '||l_terms_id
		   || ',p_last_updated_by : '||l_last_updated_by
		   || ',p_created_by : '||l_created_by
		   || ',p_payment_priority : '||l_payment_priority
		    ||',p_batch_id : '||l_batch_id
		    ||',p_terms_date : '||l_terms_date
		    ||',p_invoice_amount : '||l_invoice_amount
		    ||',p_pay_curr_invoice_amount : '||l_pay_curr_invoice_amount
		    ||', p_payment_cross_rate : '||l_payment_cross_rate
		    ||',p_amount_for_discount : '||NVL(l_amt_applicable_to_discount,
		                                                l_invoice_amount)
	            ||',p_payment_method : '||l_payment_method_code
		    ||',p_invoice_currency : '||l_invoice_currency_code
		    ||',p_payment_currency : '||l_payment_currency_code;

      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,debug_info);
      END IF;

      -------------------------------------------------------------------
      AP_CREATE_PAY_SCHEDS_PKG.AP_Create_From_Terms(
           p_invoice_id               =>l_ppa_invoice_id,
           p_terms_id                 =>l_terms_id,
           p_last_updated_by          =>l_last_updated_by,
           p_created_by               =>l_created_by,
           p_payment_priority         =>l_payment_priority,
           p_batch_id                 =>l_batch_id,
           p_terms_date               =>l_terms_date,
           p_invoice_amount           =>l_invoice_amount,
           p_pay_curr_invoice_amount  =>l_pay_curr_invoice_amount,
           p_payment_cross_rate       =>l_payment_cross_rate,
           p_amount_for_discount      =>NVL(l_amt_applicable_to_discount,
                                            l_invoice_amount),
           p_payment_method           =>l_payment_method_code,
           p_invoice_currency         =>l_invoice_currency_code,
           p_payment_currency         =>l_payment_currency_code,
           p_calling_sequence         =>current_calling_sequence);
      --
      ------------------------------------------------------------------------
      debug_info := 'Insert_Ppa_Invoices Step 5. Insert into '
                    ||'AP_INVOICE_LINES_ALL ';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
         AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,debug_info);
      END IF;

      ------------------------------------------------------------------------
      INSERT INTO AP_INVOICE_LINES_ALL(
                    invoice_id,
                    line_number,
                    line_type_lookup_code,
                    requester_id,
                    description,
                    line_source,
                    org_id,
                    inventory_item_id,
                    item_description,
                    serial_number,
                    manufacturer,
                    model_number,
                    generate_dists,
                    match_type,
                    default_dist_ccid,
                    prorate_across_all_items,
                    accounting_date,
                    period_name,
                    deferred_acctg_flag,
                    set_of_books_id,
                    amount,
                    base_amount,
                    rounding_amt,
                    quantity_invoiced,
                    unit_meas_lookup_code,
                    unit_price,
                    discarded_flag,
                    cancelled_flag,
                    income_tax_region,
                    type_1099,
                    corrected_inv_id,
                    corrected_line_number,
                    po_header_id,
                    po_line_id,
                    po_release_id,
                    po_line_location_id,
                    po_distribution_id,
                    rcv_transaction_id,
                    final_match_flag,
                    assets_tracking_flag,
                    asset_book_type_code,
                    asset_category_id,
                    project_id,
                    task_id,
                    expenditure_type,
                    expenditure_item_date,
                    expenditure_organization_id,
                    award_id,
                    awt_group_id,
		    pay_awt_group_id,--bug6817107
                    receipt_verified_flag,
                    receipt_required_flag,
                    receipt_missing_flag,
                    justification,
                    expense_group,
                    start_expense_date,
                    end_expense_date,
                    receipt_currency_code,
                    receipt_conversion_rate,
                    receipt_currency_amount,
                    daily_amount,
                    web_parameter_id,
                    adjustment_reason,
                    merchant_document_number,
                    merchant_name,
                    merchant_reference,
                    merchant_tax_reg_number,
                    merchant_taxpayer_id,
                    country_of_supply,
                    credit_card_trx_id,
                    company_prepaid_invoice_id,
                    cc_reversal_flag,
                    attribute_category,
                    attribute1,
                    attribute2,
                    attribute3,
                    attribute4,
                    attribute5,
                    attribute6,
                    attribute7,
                    attribute8,
                    attribute9,
                    attribute10,
                    attribute11,
                    attribute12,
                    attribute13,
                    attribute14,
                    attribute15,
                    global_attribute_category,
                    global_attribute1,
                    global_attribute2,
                    global_attribute3,
                    global_attribute4,
                    global_attribute5,
                    global_attribute6,
                    global_attribute7,
                    global_attribute8,
                    global_attribute9,
                    global_attribute10,
                    global_attribute11,
                    global_attribute12,
                    global_attribute13,
                    global_attribute14,
                    global_attribute15,
                    global_attribute16,
                    global_attribute17,
                    global_attribute18,
                    global_attribute19,
                    global_attribute20,
                    primary_intended_use,
                    ship_to_location_id,
                    product_type,
                    product_category,
                    product_fisc_classification,
                    user_defined_fisc_class,
                    trx_business_category,
                    summary_tax_line_id,
                    tax_regime_code,
                    tax,
                    tax_jurisdiction_code,
                    tax_status_code,
                    tax_rate_id,
                    tax_rate_code,
                    tax_rate,
                    wfapproval_status,
                    pa_quantity,
                    creation_date,
                    created_by,
                    last_updated_by,
                    last_update_date,
                    last_update_login,
                    program_application_id,
                    program_id,
                    program_update_date,
                    request_id)
            SELECT  invoice_id,
                    line_number,
                    line_type_lookup_code,
                    requester_id,
                    description,
                    line_source,
                    org_id,
                    inventory_item_id,
                    item_description,
                    serial_number,
                    manufacturer,
                    model_number,
                    generate_dists,
                    match_type,
                    default_dist_ccid,
                    prorate_across_all_items,
                    accounting_date,
                    period_name,
                    deferred_acctg_flag,
                    set_of_books_id,
                    amount,
                    base_amount,
                    rounding_amt,
                    quantity_invoiced,
                    unit_meas_lookup_code,
                    unit_price,
                    discarded_flag,
                    cancelled_flag,
                    income_tax_region,
                    type_1099,
                    corrected_inv_id,
                    corrected_line_number,
                    po_header_id,
                    po_line_id,
                    po_release_id,
                    po_line_location_id,
                    po_distribution_id,
                    rcv_transaction_id,
                    final_match_flag,
                    assets_tracking_flag,
                    asset_book_type_code,
                    asset_category_id,
                    project_id,
                    task_id,
                    expenditure_type,
                    expenditure_item_date,
                    expenditure_organization_id,
                    award_id,
                    awt_group_id,
		    pay_awt_group_id,--bug6817107
                    receipt_verified_flag,
                    receipt_required_flag,
                    receipt_missing_flag,
                    justification,
                    expense_group,
                    start_expense_date,
                    end_expense_date,
                    receipt_currency_code,
                    receipt_conversion_rate,
                    receipt_currency_amount,
                    daily_amount,
                    web_parameter_id,
                    adjustment_reason,
                    merchant_document_number,
                    merchant_name,
                    merchant_reference,
                    merchant_tax_reg_number,
                    merchant_taxpayer_id,
                    country_of_supply,
                    credit_card_trx_id,
                    company_prepaid_invoice_id,
                    cc_reversal_flag,
                    attribute_category,
                    attribute1,
                    attribute2,
                    attribute3,
                    attribute4,
                    attribute5,
                    attribute6,
                    attribute7,
                    attribute8,
                    attribute9,
                    attribute10,
                    attribute11,
                    attribute12,
                    attribute13,
                    attribute14,
                    attribute15,
                    global_attribute_category,
                    global_attribute1,
                    global_attribute2,
                    global_attribute3,
                    global_attribute4,
                    global_attribute5,
                    global_attribute6,
                    global_attribute7,
                    global_attribute8,
                    global_attribute9,
                    global_attribute10,
                    global_attribute11,
                    global_attribute12,
                    global_attribute13,
                    global_attribute14,
                    global_attribute15,
                    global_attribute16,
                    global_attribute17,
                    global_attribute18,
                    global_attribute19,
                    global_attribute20,
                    primary_intended_use,
                    ship_to_location_id,
                    product_type,
                    product_category,
                    product_fisc_classification,
                    user_defined_fisc_class,
                    trx_business_category,
                    summary_tax_line_id,
                    tax_regime_code,
                    tax,
                    tax_jurisdiction_code,
                    tax_status_code,
                    tax_rate_id,
                    tax_rate_code,
                    tax_rate,
                    wfapproval_status,
                    pa_quantity,
                    SYSDATE,                   --creation_date
                    FND_GLOBAL.user_id,        --created_by
                    FND_GLOBAL.user_id,        --last_updated_by
                    SYSDATE,                   --last_update_date
                    FND_GLOBAL.conc_login_id,  --last_update_login
                    FND_GLOBAL.prog_appl_id,   --program_application_id
                    FND_GLOBAL.conc_program_id,--program_id
                    SYSDATE,                   -- program_update_date
                    FND_GLOBAL.conc_request_id --request_id
            FROM    ap_ppa_invoice_lines_gt
            WHERE   instruction_id = p_instruction_id
            AND     invoice_id = l_ppa_invoice_id;
	     --Commented for bug#9573078.
           -- AND     adj_type = 'PPA';
      --
      ------------------------------------------------------------------------
      debug_info := 'Insert_Ppa_Invoices Step 5. Insert into '
                     ||'AP_INVOICE_DISTRIBUTIONS_ALL ';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
         AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,debug_info);
      END IF;
      ------------------------------------------------------------------------
      INSERT INTO ap_invoice_distributions_all(
                accounting_date,
                accrual_posted_flag,
                amount,
                asset_book_type_code,
                asset_category_id,
                assets_addition_flag,
                assets_tracking_flag,
                attribute_category,
                attribute1,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                award_id,
                awt_flag,
                awt_group_id,
		pay_awt_group_id,--bug6817107
                awt_tax_rate_id,
                base_amount,
                batch_id,
                cancellation_flag,
                cash_posted_flag,
                corrected_invoice_dist_id,
                corrected_quantity,
                country_of_supply,
                description,
                dist_code_combination_id,
                dist_match_type,
                distribution_class,
                distribution_line_number,
                encumbered_flag,
                expenditure_item_date,
                expenditure_organization_id,
                expenditure_type,
                final_match_flag,
                global_attribute_category,
                global_attribute1,
                global_attribute10,
                global_attribute11,
                global_attribute12,
                global_attribute13,
                global_attribute14,
                global_attribute15,
                global_attribute16,
                global_attribute17,
                global_attribute18,
                global_attribute19,
                global_attribute2,
                global_attribute20,
                global_attribute3,
                global_attribute4,
                global_attribute5,
                global_attribute6,
                global_attribute7,
                global_attribute8,
                global_attribute9,
                income_tax_region,
                inventory_transfer_status,
                invoice_distribution_id,
                invoice_id,
                invoice_line_number,
                line_type_lookup_code,
                match_status_flag,
                matched_uom_lookup_code,
                merchant_document_number,
                merchant_name,
                merchant_reference,
                merchant_tax_reg_number,
                merchant_taxpayer_id,
                org_id,
                pa_addition_flag,
                pa_quantity,
                period_name,
                po_distribution_id,
                posted_flag,
                project_id,
                quantity_invoiced,
                rcv_transaction_id,
                reversal_flag,
                rounding_amt,
                set_of_books_id,
                task_id,
                type_1099,
                unit_price,
                creation_date,
                created_by,
                last_updated_by,
                last_update_date,
                last_update_login,
                program_application_id,
                program_id,
                program_update_date,
                request_id,
	        --Freight and Special Charges
	        rcv_charge_addition_flag)
         SELECT accounting_date,
                accrual_posted_flag,
                amount,
                asset_book_type_code,
                asset_category_id,
                assets_addition_flag,
                assets_tracking_flag,
                attribute_category,
                attribute1,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                award_id,
                awt_flag,
                awt_group_id,
		pay_awt_group_id,--bug6817107
                awt_tax_rate_id,
                base_amount,
                batch_id,
                cancellation_flag,
                cash_posted_flag,
                corrected_invoice_dist_id,
                corrected_quantity,
                country_of_supply,
                description,
                dist_code_combination_id,
                dist_match_type,
                distribution_class,
                distribution_line_number,
                encumbered_flag,
                expenditure_item_date,
                expenditure_organization_id,
                expenditure_type,
                final_match_flag,
                global_attribute_category,
                global_attribute1,
                global_attribute10,
                global_attribute11,
                global_attribute12,
                global_attribute13,
                global_attribute14,
                global_attribute15,
                global_attribute16,
                global_attribute17,
                global_attribute18,
                global_attribute19,
                global_attribute2,
                global_attribute20,
                global_attribute3,
                global_attribute4,
                global_attribute5,
                global_attribute6,
                global_attribute7,
                global_attribute8,
                global_attribute9,
                income_tax_region,
                inventory_transfer_status,
                ap_invoice_distributions_s.NEXTVAL, --invoice_distribution_id,
                invoice_id,
                invoice_line_number,
                line_type_lookup_code,
                match_status_flag,
                matched_uom_lookup_code,
                merchant_document_number,
                merchant_name,
                merchant_reference,
                merchant_tax_reg_number,
                merchant_taxpayer_id,
                org_id,
                pa_addition_flag,
                pa_quantity,
                period_name,
                po_distribution_id,
                posted_flag,
                project_id,
                quantity_invoiced,
                rcv_transaction_id,
                reversal_flag,
                rounding_amt,
                set_of_books_id,
                task_id,
                type_1099,
                unit_price,
                SYSDATE,                     --creation_date,
                FND_GLOBAL.user_id,          --created_by,
                FND_GLOBAL.user_id,          --last_updated_by,
                SYSDATE,                     --last_update_date,
                FND_GLOBAL.conc_login_id,    --last_update_login,
                FND_GLOBAL.prog_appl_id,     --program_application_id,
                FND_GLOBAL.conc_program_id,  --program_id,
                SYSDATE,                     --program_update_date,
                FND_GLOBAL.conc_request_id,  --request_id,
		'N'			     --rcv_charge_addition_flag
           FROM ap_ppa_invoice_dists_gt
          WHERE instruction_id = p_instruction_id
            AND invoice_id = l_ppa_invoice_id;

          -- Bug 5525506
          UPDATE ap_invoices_all
          set invoice_amount = (select sum(amount)
                                from ap_invoice_lines_all
                                where invoice_id = l_ppa_invoice_id)
          where invoice_id = l_ppa_invoice_id;
      --
   END LOOP;
   CLOSE  ppa_invoices;
   --
   p_ppa_invoices_count          := l_ppa_invoices_count;
   p_ppa_invoices_total          := l_ppa_invoices_total;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_RETRO_PRICING_PKG.Insert_Ppa_Invoices(-)');
   END IF;
   --
   RETURN(TRUE);
   --
EXCEPTION
WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,SQLERRM);
      END IF;
    END IF;
    IF ( ppa_invoices%ISOPEN ) THEN
        CLOSE ppa_invoices;
    END IF;
    RETURN(FALSE);

END Insert_Ppa_Invoices;



/*=============================================================================
 |  FUNCTION - Import_Retroprice_Adjustments()
 |
 |  DESCRIPTION
 |     Main Public procedure called from the Payables Open Interface Import
 |     Program ("import") which treats the records in the interface tables
 |     as "invoice instructions" rather than each record as an individual
 |     invoice. For recods with source='PPA' the program makes all necessary
 |     adjustments to original invoices and will create the new adjustment
 |     documents in Global Temp Tables.This program will then leverage the
 |     the import validations for the new adjustment docs in the temp tables.
 |     For every instruction the control will return to the Import Program
 |     resulting in Instruction with the status of PROCESSED or REJECTED.
 |     PROCESSED Instructions results in adjustment correction being made
 |     to the original Invoices alongwith the creation of PPA Documents.
 |
 |
 |  IN-PARAMETERS
 |   p_instruction_rec -- Record in the AP_INVOICE_INTERFACE with source=PPA
 |   p_base_currency_code
 |   p_multi_currency_flag
 |   p_set_of_books_id
 |   p_default_exchange_rate_type
 |   p_make_rate_mandatory_flag
 |   p_gl_date_from_get_info
 |   p_gl_date_from_receipt_flag
 |   p_positive_price_tolerance
 |   p_pa_installed
 |   p_qty_tolerance
 |   p_max_qty_ord_tolerance
 |   p_base_min_acct_unit
 |   p_base_precision
 |   p_chart_of_accounts_id
 |   p_freight_code_combination_id
 |   p_purch_encumbrance_flag
 |   p_calc_user_xrate
 |   p_default_last_updated_by
 |   p_default_last_update_login
 |   p_instr_status_flag -- status of the Instruction
 |   p_invoices_count --OUT Count of PPA Invoices Created
 |   p_invoices_total --OUT PPA Invoice Total --to be updated in the Inv Batch
 |   p_invoices_base_amt_total  --OUT PPA Invoice Total
 |   P_calling_sequence - Calling Sequence
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
FUNCTION Import_Retroprice_Adjustments(
           p_instruction_rec   IN     AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
           p_base_currency_code            IN     VARCHAR2,
           p_multi_currency_flag           IN     VARCHAR2,
           p_set_of_books_id               IN     NUMBER,
           p_default_exchange_rate_type    IN     VARCHAR2,
           p_make_rate_mandatory_flag      IN     VARCHAR2,
           p_gl_date_from_get_info         IN     DATE,
           p_gl_date_from_receipt_flag     IN     VARCHAR2,
           p_positive_price_tolerance      IN     NUMBER,
           p_pa_installed                  IN     VARCHAR2,
           p_qty_tolerance                 IN     NUMBER,
           p_max_qty_ord_tolerance         IN     NUMBER,
           p_base_min_acct_unit            IN     NUMBER,
           p_base_precision                IN     NUMBER,
           p_chart_of_accounts_id          IN     NUMBER,
           p_freight_code_combination_id   IN     NUMBER,
           p_purch_encumbrance_flag        IN     VARCHAR2,
           p_calc_user_xrate               IN     VARCHAR2,
           p_default_last_updated_by       IN     NUMBER,
           p_default_last_update_login     IN     NUMBER,
           p_instr_status_flag                OUT NOCOPY VARCHAR2,
           p_invoices_count                   OUT NOCOPY NUMBER,
           p_invoices_total                   OUT NOCOPY NUMBER,
           P_calling_sequence              IN     VARCHAR2)
RETURN BOOLEAN IS

CURSOR instruction_lines IS
SELECT invoice_id,
       invoice_line_id,
       po_line_location_id,
       accounting_date,
       unit_price,
       requester_id,
       description,
       award_id,
       created_by
FROM   ap_invoice_lines_interface
WHERE  invoice_id = p_instruction_rec.invoice_id;

l_invoice_id_list         AP_RETRO_PRICING_PKG.id_list_type;
l_base_match_lines_list   AP_RETRO_PRICING_PKG.invoice_lines_list_type;
l_instruction_lines_list  AP_RETRO_PRICING_PKG.instruction_lines_list_type;
l_batch_id                NUMBER;
l_invoices_count          NUMBER;
l_invoices_total          NUMBER;
l_invoices_base_amt_total NUMBER;

debug_info                VARCHAR2(1000);
current_calling_sequence  VARCHAR2(1000);

Import_Retro_Adj_failure  EXCEPTION;
l_instr_status_flag       VARCHAR2(1) := 'Y';
l_instr_status_flag1      VARCHAR2(1) := 'Y';    --Bug5769161
l_orig_invoices_valid     VARCHAR2(1);

--Contract Payments: Added this cursor so as to
--replace the direct updates to po_distributions/po_line_locations
--with single api.

l_po_ap_dist_rec               PO_AP_DIST_REC_TYPE;
l_po_ap_line_loc_rec           PO_AP_LINE_LOC_REC_TYPE;
l_return_status                VARCHAR2(100);
l_msg_data                     VARCHAR2(4000);
l_po_distribution_id	       NUMBER;
l_po_line_location_id	       NUMBER;
l_amount_billed		       NUMBER;
l_shipment_amount_billed       NUMBER;
l_uom_code		       ap_invoice_distributions_all.matched_uom_lookup_code%TYPE;
l_last_update_login	       NUMBER;
l_request_id		       NUMBER;
l_api_name CONSTANT VARCHAR2(200) := 'Import_Retroprice_Adjustments';
l_base_match_lines_rec    AP_RETRO_PRICING_PKG.invoice_lines_rec_type;  -- Bug 5525506
l_ppa_exists                   VARCHAR2(1);
l_seq_num_profile              VARCHAR2(1);
l_existing_ppa_inv_id          NUMBER;

--Introduced below variables for bug#9573078
l_pc_lines_list           AP_RETRO_PRICING_PKG.invoice_lines_list_type;
l_pc_lines_rec            AP_RETRO_PRICING_PKG.invoice_lines_rec_type;
l_qc_lines_list           AP_RETRO_PRICING_PKG.invoice_lines_list_type;
l_qc_lines_rec            AP_RETRO_PRICING_PKG.invoice_lines_rec_type;
l_pc_exists               VARCHAR2(1);
l_qc_exists               VARCHAR2(1);


CURSOR po_shipments IS
SELECT pd.line_location_id,
       SUM(d.amount)
FROM ap_ppa_invoice_dists_gt d,
     ap_ppa_invoice_lines_gt l,
     po_distributions_all pd
--bug#9573078 Introduced new conditions to put join lines_gt
--and dists_gt with line number
WHERE d.instruction_id = p_instruction_rec.invoice_id
AND d.po_distribution_id = pd.po_distribution_id
AND pd.invoice_adjustment_flag = 'S'
AND d.invoice_id = l.invoice_id
AND d.invoice_line_number = l.line_number
GROUP BY pd.line_location_id;


CURSOR po_dists(c_po_line_location_id IN NUMBER) IS
SELECT d.po_distribution_id,
       d.matched_uom_lookup_code,
       d.amount,
       FND_GLOBAL.conc_login_id,
       FND_GLOBAL.conc_request_id
FROM ap_ppa_invoice_dists_gt d,
     ap_ppa_invoice_lines_gt l,
     po_distributions_all pd
--bug#9573078 Introduced new conditions to put join lines_gt
--and dists_gt with line number
WHERE pd.line_location_id = c_po_line_location_id
AND pd.invoice_adjustment_flag = 'S'
AND d.po_distribution_id = pd.po_distribution_id
AND d.instruction_id = p_instruction_rec.invoice_id
AND d.invoice_id = l.invoice_id
AND d.invoice_line_number = l.line_number;

l_invoice_id NUMBER;
l_invoice_amount number;
l_invoice_currency_code VARCHAR2(100);
l_accounting_event_id number;
--
BEGIN
   --
   current_calling_sequence :=
   'AP_RETRO_PRICING_PKG.Import_Retroprice_Adjustments<-'||P_calling_sequence;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_RETRO_PRICING_PKG.Import_Retroprice_Adjustments(+)');
   END IF;
   ---------------------------------------------------------------------------
   -- Step 1.Check if the base matched Invoices affected by retropricing are
   -- Valid. Also all the Price Corrections and Quantity corrections on the
   --affected base match Invoices should be valid for the vendor.
   ---------------------------------------------------------------------------
   debug_info := 'Import_Retroprice_Adjustments Step 1. '
                  ||'Are_Original_Invoices_Valid';
   IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
   END IF;
   --
   IF (AP_RETRO_PRICING_UTIL_PKG.Are_Original_Invoices_Valid(
         p_instruction_rec.invoice_id,
         p_instruction_rec.org_id,
         l_orig_invoices_valid) <> TRUE)  THEN
       --
       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
           AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,
           'Are_Original_Invoices_Valid<-' ||current_calling_sequence);
       END IF;
       RAISE Import_Retro_Adj_failure;
   END IF;
   --
   IF  l_orig_invoices_valid = 'N' THEN
   --
       IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
             'AP_INVOICES_INTERFACE',
              p_instruction_rec.invoice_id,
             'ORIGINAL INVOICE NOT VALIDATED',
              FND_GLOBAL.user_id,
              FND_GLOBAL.login_id,
              current_calling_sequence) <>  TRUE) THEN
              --
              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   'insert_rejections<- '||current_calling_sequence);
              END IF;
              Raise Import_Retro_Adj_failure;
       END IF; -- Insert rejections
       --
       l_instr_status_flag := 'N';
       --
   END IF;
   --
   --------------------------------------------------------------------------
   -- Step 2. Are there any Holds other than the Price Holds on the base
   -- matched Invoices(along with the PC and QC) for the vendor
   ------------------------------------------------------------------------
   debug_info := 'Import_Retroprice_Adjustments Step 2. Are_Holds_Ok';
   IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
       AP_IMPORT_UTILITIES_PKG.Print(
         AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
   END IF;
   --
   IF (AP_RETRO_PRICING_UTIL_PKG.Are_Holds_Ok(
          p_instruction_rec.invoice_id,
          p_instruction_rec.org_id,
          l_orig_invoices_valid) <> TRUE)  THEN
          --
         IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'Are_Holds_Ok<-' ||current_calling_sequence);
         END IF;
         RAISE Import_Retro_Adj_failure;
   END IF;
   --
   IF  l_orig_invoices_valid = 'N' THEN
       --Insert rejections
       IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
             ('AP_INVOICES_INTERFACE',
              p_instruction_rec.invoice_id,
             'ORIGINAL INVOICE HAS A HOLD',
              FND_GLOBAL.user_id,
              FND_GLOBAL.login_id,
              current_calling_sequence) <>  TRUE) THEN
           IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   'insert_rejections<- '||current_calling_sequence);
           END IF;
           Raise Import_Retro_Adj_failure;
       END IF; -- Insert rejections
       --
       l_instr_status_flag := 'N';
       --
    END IF;


   --------------------------------------------------------------------------
   -- Step 2.1. If sequence_numbering is always used, is there a sequence
   --           assigned to the document class of 'PO ADJ INV'
   --           Added for the bug5769161
   ------------------------------------------------------------------------
   debug_info := 'Import_Retroprice_Adjustments Step 2.1 Is sequence Assigned';
   IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
       AP_IMPORT_UTILITIES_PKG.Print(
         AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
   END IF;
   --
   IF (AP_RETRO_PRICING_UTIL_PKG.Is_Sequence_Assigned(
          'PO ADJ INV',
          p_instruction_rec.org_id,
          l_orig_invoices_valid) <> TRUE)  THEN
          --
         IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'Is_Sequence_Assigned<-' ||current_calling_sequence);
         END IF;
         RAISE Import_Retro_Adj_failure;
   END IF;
   --
   FND_PROFILE.GET('UNIQUE:SEQ_NUMBERS',l_seq_num_profile);
   IF  ((l_orig_invoices_valid = 'N') and (l_seq_num_profile = 'A')) THEN
       --Insert rejections
       IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
             ('AP_INVOICES_INTERFACE',
              p_instruction_rec.invoice_id,
             'NO SEQUENCE DEFINED FOR PPA',
              FND_GLOBAL.user_id,
              FND_GLOBAL.login_id,
              current_calling_sequence) <>  TRUE) THEN
           IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   'insert_rejections<- '||current_calling_sequence);
           END IF;
           Raise Import_Retro_Adj_failure;
       END IF; -- Insert rejections
       --
       l_instr_status_flag := 'N';
       --
    END IF;


    -----------------------------------------------------------------------
    -- STEP 3. Derive Batch_id from the Batch Name(Group_id in APII ).
    -----------------------------------------------------------------------
    debug_info := 'Import_Retroprice_Adjustments Step 3. Derive Batch_Id';
    IF l_instr_status_flag = 'Y'  THEN
      debug_info := 'Import_Retroprice_Adjustments 3. Derive Batch Id, p_instruction_rec.group_id is'||p_instruction_rec.group_id;
      IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
         AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;
      --
      --Bugfix:4681253
      l_batch_id := TO_NUMBER(substr(p_instruction_rec.group_id, 5));
      --
    END IF;

    --------------------------------------------------------------------------
    -- STEP 4. Get Instruction Lines(Retropricing Affected
    -- Shipment Lines) for the vendor
    --------------------------------------------------------------------------
    debug_info := 'Import_Retroprice_Adjustments Step 4.Open instruction_lines';
    IF l_instr_status_flag = 'Y' THEN
      IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
         AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;

      OPEN instruction_lines;
      FETCH instruction_lines
      BULK COLLECT INTO  l_instruction_lines_list;
      CLOSE instruction_lines;

      FOR i IN 1..l_instruction_lines_list.COUNT
      LOOP
        ----------------------------------------------------------------------
        -- STEP 4.1. Get Base Match Lines for the instruction_line(Shipment)
        ----------------------------------------------------------------------
        debug_info := 'Import_Retroprice_Adjustments Step 4.1. Get Base Match Lines';
        IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
           AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
        END IF;

        IF (AP_RETRO_PRICING_UTIL_PKG.Get_Base_Match_Lines(
               p_instruction_rec.invoice_id,
               l_instruction_lines_list(i).invoice_line_id,
               l_base_match_lines_list,
               current_calling_sequence) <> TRUE) THEN
          --
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   'Get_Base_Match_Lines<- '||current_calling_sequence);
           END IF;
           Raise Import_Retro_Adj_failure;
          --
        END IF;
        --
        ----------------------------------------------------------------------
        -- STEP 4.2 Process Retroprice Adjustments for the affected Shipment
        ----------------------------------------------------------------------
        debug_info := 'Import_Retroprice_Adjustments Step 4.2.'
                       ||' Process_Retroprice_Adjustments ';
        IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
           AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
        END IF;
        --

        IF (AP_RETRO_PRICING_PKG.Process_Retroprice_Adjustments(
               p_base_currency_code,
               l_base_match_lines_list,
               p_instruction_rec,
               l_instruction_lines_list(i),
               l_batch_id,
               current_calling_sequence) <> TRUE) THEN
          --
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   'Process_Retroprice_Adjustments<- '||current_calling_sequence);
          END IF;
          Raise Import_Retro_Adj_failure;
          --
        END IF;
        --
        debug_info := 'Import_Retroprice_Adjustments Step 4.3. Clear Header PL/SQL table';
        l_base_match_lines_list.DELETE;
        --
      END LOOP; --instr lines
      --
      debug_info := 'Import_Retroprice_Adjustments Step 4.4. Clear Header PL/SQL table';
      -- Bug 9010175 - commented l_instruction_lines_list.DELETE as we'll use
      -- it again to Insert Zero Amount Adjustments for Original Invoices
      --
      -- l_instruction_lines_list.DELETE;
      --
    END IF;  --instr_status_flag

    -----------------------------------------------------------------------
    -- STEP 5. Update Invoice Totals for PPA Documents created in the Temp
    --         tables.
    -----------------------------------------------------------------------
    debug_info := 'Import_Retroprice_Adjustments 5. Update Invoice Amounts, p_instruction_rec.invoice_id is'||p_instruction_rec.invoice_id;
    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
         AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    UPDATE AP_ppa_invoices_gt H
       SET invoice_amount = AP_RETRO_PRICING_UTIL_PKG.get_invoice_amount(
                                 invoice_id,
                                 invoice_currency_code)
     WHERE instruction_id = p_instruction_rec.invoice_id;

    --------------------------------------------------------------------------
    -- STEP 6. Validate PPA Invoices
    --------------------------------------------------------------------------
    debug_info := 'Import_Retroprice_Adjustments 6. Validate_Temp_Ppa_Invoices';
    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
         AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    IF  (Validate_Temp_Ppa_Invoices(
            p_instruction_rec.invoice_id,
            p_base_currency_code,
            p_multi_currency_flag,
            p_set_of_books_id,
            p_default_exchange_rate_type,
            p_make_rate_mandatory_flag,
            p_gl_date_from_get_info,
            p_gl_date_from_receipt_flag,
            p_positive_price_tolerance,
            p_pa_installed,
            p_qty_tolerance,
            p_max_qty_ord_tolerance,
            p_base_min_acct_unit,
            p_base_precision,
            p_chart_of_accounts_id,
            p_freight_code_combination_id,
            p_purch_encumbrance_flag,
            p_calc_user_xrate,
            p_default_last_updated_by,
            p_default_last_update_login,
            l_instr_status_flag1,            --Bug5769161
            current_calling_sequence)  <> TRUE) THEN
       --
       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
           AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,
             'Validate_Temp_Ppa_Invoices<- '||current_calling_sequence);
       END IF;
       RAISE Import_Retro_Adj_failure;
       --
    END IF;

    --Bug5769161
    --Updating the value of the flag l_instr_status_flag
    --on the basis of the value returned from the validation
    --of temporary ppa invoices. This has to added to take care
    --of the case in which any of the checks in steps
    --1, 2 or 2.1 fail

    IF l_instr_status_flag1 = 'N' then
       l_instr_status_flag := l_instr_status_flag1;
    END IF;

    ----------------------------------------------------------------------------
    -- STEP 7. Update insr_status in the Global Temp Table
    ----------------------------------------------------------------------------
    debug_info := 'l_instr_status_flag: '||l_instr_status_flag;
    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
         AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;


    debug_info := 'Import_Retroprice_Adjustments 8. Update Instruction Status';
    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
         AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    p_instr_status_flag := l_instr_status_flag;

    IF l_instr_status_flag = 'Y' THEN
       UPDATE ap_ppa_invoices_gt
          SET instr_status_flag = 'Y'
        WHERE instruction_id = p_instruction_rec.invoice_id;
    ELSE
       UPDATE ap_ppa_invoices_gt
          SET instr_status_flag = 'N'
        WHERE instruction_id = p_instruction_rec.invoice_id;
    END IF;

    --------------------------------------------------------------------------
    -- STEP 8. Discard all lines for a PPA Header if they add up to zero for
    -- a shipment line(There is only one PPA for a Shipment)
    --------------------------------------------------------------------------
    debug_info := 'Import_Retroprice_Adjustments 8. Discard PPA lines if SUM=0';
    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
         AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    -- Bug 5469166. Uncomment the following section. In case of wash there is no
    -- need to create PPA invoice
    IF l_instr_status_flag = 'Y' THEN
      --
      debug_info := 'Import_Retroprice_Adjustments 8.1. delete from '
                    ||'ap_ppa_invoices_gt';
       DELETE FROM ap_ppa_invoices_gt apig
       WHERE  instruction_id = p_instruction_rec.invoice_id
	 --bug#9573078
	 --AND invoice_amount = 0
	 AND NOT EXISTS (select 'No lines'
                         from ap_ppa_invoice_lines_gt apilg
                         where apilg.invoice_id = apig.invoice_id
			  and nvl(amount,0) <> 0)
        RETURNING invoice_id
        BULK COLLECT INTO l_invoice_id_list;

      debug_info := 'Import_Retroprice_Adjustments 8.2. delete from '
                     ||'ap_ppa_invoice_lines_gt';
      FORALL i IN  l_invoice_id_list.FIRST..l_invoice_id_list.LAST
        DELETE FROM ap_ppa_invoice_lines_gt
         WHERE invoice_id = l_invoice_id_list(i)
           AND instruction_id = p_instruction_rec.invoice_id;

      debug_info := 'Import_Retroprice_Adjustments 8.3. delete from '
                     ||'ap_ppa_invoice_dists_gt';
      FORALL i IN  l_invoice_id_list.FIRST..l_invoice_id_list.LAST
        DELETE FROM ap_ppa_invoice_dists_gt D
         WHERE invoice_id = l_invoice_id_list(i)
           AND instruction_id = p_instruction_rec.invoice_id;
      --
    END IF;

    -------------------------------------------------------------------------
    -- STEP 9. Insert Zero Amount Adjustments for Original Invoices
    -------------------------------------------------------------------------
    debug_info := 'Import_Retroprice_Adjustments 9.0. '||
                 ' Processing for base match line zero adjustment';
    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
         AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

  FOR i IN 1..l_instruction_lines_list.COUNT
  LOOP
        -- Bug 9010175 - Added outer loop over l_instruction_lines_list and
        -- call to AP_RETRO_PRICING_UTIL_PKG.Get_Base_Match_Lines to fetch
        -- l_base_match_lines_list for each instruction lines list.
        ----------------------------------------------------------------------
        -- STEP 9.1. Get Base Match Lines for the instruction_line(Shipment)
        ----------------------------------------------------------------------
        debug_info := 'Import_Retroprice_Adjustments Step 9.1. Get Base Match
Lines';
        IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
           AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
        END IF;

        IF (AP_RETRO_PRICING_UTIL_PKG.Get_Base_Match_Lines(
               p_instruction_rec.invoice_id,
               l_instruction_lines_list(i).invoice_line_id,
               l_base_match_lines_list,
               current_calling_sequence) <> TRUE) THEN
          --
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   'Get_Base_Match_Lines<- '||current_calling_sequence);
           END IF;
           Raise Import_Retro_Adj_failure;
          --
        END IF;


    FOR i IN 1..l_base_match_lines_list.COUNT
    LOOP
    --
    l_base_match_lines_rec := l_base_match_lines_list(i);

    debug_info := 'Import_Retroprice_Adjustments 9.1 Check PPA already exists';
    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
         AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    IF (AP_RETRO_PRICING_UTIL_PKG.ppa_already_exists(
          l_base_match_lines_rec.invoice_id,
          l_base_match_lines_rec.line_number,
          l_ppa_exists,         --OUT
          l_existing_ppa_inv_id --OUT
          ) <> TRUE) THEN

        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
           AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   'ppa_already_exists<- '||current_calling_sequence);
        END IF;
        Raise Import_Retro_Adj_failure;
     END IF;

    debug_info := 'Import_Retroprice_Adjustments 9.2 Zero Amount Adjustments';
    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
         AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    IF  (l_instr_status_flag = 'Y' AND
         l_ppa_exists = 'N')  THEN   -- Bug 5525506
      --
      IF (Insert_Zero_Amt_Adjustments(
               --p_instruction_rec.invoice_id, --Commented for bug#9573078
		 l_base_match_lines_rec.invoice_id, --bug#9573078
                 l_base_match_lines_rec.line_number, --bug#9573078
                 current_calling_sequence) <> TRUE) THEN
         --
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   'Insert_Zero_Amt_Adjustments<- '||current_calling_sequence);
        END IF;
        Raise Import_Retro_Adj_failure;
        --
      END IF;

      --Commented below code for bug#9573078 and introduced
       --at below location, out of the loop

      --Bug5485084 added following loop to create events
    /*  FOR invs in ( SELECT distinct apilg.invoice_id
                      FROM ap_ppa_invoice_lines_gt apilg
                     WHERE apilg.instruction_id = p_instruction_rec.invoice_id
		     --Bug:9926348 added NOT exists to exclude PPA invoice
                      and not exists (select apig.invoice_id
                                      from ap_ppa_invoices_gt apig
                                      where apig.invoice_id = apilg.invoice_id))
      loop

      AP_Accounting_Events_Pkg.Create_Events(
            p_event_type => 'INVOICES',
            p_doc_type => NULL,
            p_doc_id => invs.invoice_id,
            p_accounting_date => NULL,
            p_accounting_event_id => l_accounting_event_id,
            p_checkrun_name => NULL,
            p_calling_sequence => current_calling_sequence);
      end loop; */
      --End bug#9573078


     --Start bug#9573078
    --Introduced below code to insert all adjustment lines/dists of base match lines
    --price and quantity corrections, in corresponding actual invoices

    debug_info := 'Import_Retroprice_Adjustments Step 9.4. Get price corrections for base match line';
    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
           AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
     END IF;

    IF (AP_RETRO_PRICING_UTIL_PKG.Corrections_exists(
              l_base_match_lines_rec.invoice_id,
              l_base_match_lines_rec.line_number,
              'PRICE_CORRECTION',
              l_pc_lines_list,
              l_pc_exists) <> TRUE) THEN

          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
              AP_IMPORT_UTILITIES_PKG.Print(
               AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'Corrections_exists<- '||current_calling_sequence);
          END IF;

          Raise Import_Retro_Adj_failure;

    END IF;
    IF  (l_pc_exists = 'Y') THEN
      FOR i in 1..l_pc_lines_list.COUNT  LOOP

	 l_pc_lines_rec :=  l_pc_lines_list(i);
         IF (Insert_Zero_Amt_Adjustments(
                l_pc_lines_rec.invoice_id,
                l_pc_lines_rec.line_number,
                current_calling_sequence) <> TRUE) THEN

              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   'Insert_Zero_Amt_Adjustments<- '||current_calling_sequence);
              END IF;
              Raise Import_Retro_Adj_failure;
           END IF;
         END LOOP;
    END IF;

debug_info := 'Import_Retroprice_Adjustments Step 9.5. Get Quantity corrections for base match line';
    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
           AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    IF (AP_RETRO_PRICING_UTIL_PKG.Corrections_exists(
              l_base_match_lines_rec.invoice_id,
              l_base_match_lines_rec.line_number,
              'QTY_CORRECTION',
              l_qc_lines_list,
              l_qc_exists) <> TRUE) THEN

         IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(
             AP_IMPORT_INVOICES_PKG.g_debug_switch,
             'Corrections_exists<- '||current_calling_sequence);
        END IF;

        Raise Import_Retro_Adj_failure;
    END IF;

    IF  (l_qc_exists = 'Y') THEN
       FOR i in 1..l_qc_lines_list.COUNT LOOP
           l_qc_lines_rec :=  l_qc_lines_list(i);

       IF (Insert_Zero_Amt_Adjustments(
                l_qc_lines_rec.invoice_id,
                l_qc_lines_rec.line_number,
                current_calling_sequence) <> TRUE) THEN

              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   'Insert_Zero_Amt_Adjustments<- '||current_calling_sequence);
              END IF;
              Raise Import_Retro_Adj_failure;
           END IF;
         END LOOP;
    END IF;
    --End bug#9573078

    END IF; -- instr_status_flag and ppa_exists check

    END LOOP; -- end loop over l_base_match_lines_list
  END LOOP; -- end loop over l_instruction_lines_list -- bug 9010175

    ---------------------------------------------------------------------------
    -- STEP 10. Insert PPA Invoices
    ---------------------------------------------------------------------------
    debug_info := 'Import_Retroprice_Adjustments 10. Insert_Ppa_Invoices l_instr_status_flag is '||l_instr_status_flag;
    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
         AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    IF l_instr_status_flag = 'Y' THEN
      --
      IF (Insert_Ppa_Invoices(
                p_instruction_rec.invoice_id,
                p_invoices_count,
                p_invoices_total,
                current_calling_sequence) <> TRUE) THEN
        --
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   'Insert_Ppa_Invoices<- '||current_calling_sequence);
        END IF;
        Raise Import_Retro_Adj_failure;
        --
      END IF;

    --Introduced below code for bug#9573078 and commented
    --at above location, inside loop

     --Bug5485084 added following loop to create events
      FOR invs in(  SELECT distinct invoice_id
                    FROM ap_ppa_invoice_lines_gt apilg
                    WHERE apilg.instruction_id = p_instruction_rec.invoice_id
                     and not exists (select invoice_id
                                     from ap_ppa_invoices_gt apig
                                     where apig.invoice_id = apilg.invoice_id))
      LOOP

      AP_Accounting_Events_Pkg.Create_Events(
            p_event_type => 'INVOICES',
            p_doc_type => NULL,
            p_doc_id => invs.invoice_id,
            p_accounting_date => NULL,
            p_accounting_event_id => l_accounting_event_id,
            p_checkrun_name => NULL,
            p_calling_sequence => current_calling_sequence);
      END LOOP;
      --End bug#9573078

    END IF;

    --------------------------------------------------------------------------
    -- STEP 10. Update Amount, Invoice Adjustment Flag in PO Distributions
    --------------------------------------------------------------------------
    debug_info := 'Import_Retroprice_Adjustments 11. Update PO_DISTRIBUTIONS';
    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
         AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;



    IF l_instr_status_flag = 'Y' THEN

       OPEN po_shipments;

       LOOP

          FETCH po_shipments INTO l_po_line_location_id,
			       l_shipment_amount_billed;

          EXIT WHEN po_shipments%NOTFOUND;

          l_po_ap_dist_rec := PO_AP_DIST_REC_TYPE.create_object();

          OPEN po_dists(l_po_line_location_id);

          LOOP

             FETCH po_dists INTO l_po_distribution_id,
			   l_uom_code,
			   l_amount_billed,
			   l_last_update_login,
			   l_request_id;
             EXIT WHEN po_dists%NOTFOUND;


             l_po_ap_dist_rec.add_change(p_po_distribution_id => l_po_distribution_id,
                                p_uom_code           => l_uom_code,
                                p_quantity_billed    => NULL,
                                p_amount_billed      => l_amount_billed,
                                p_quantity_financed  => NULL,
                                p_amount_financed    => NULL,
                                p_quantity_recouped  => NULL,
                                p_amount_recouped    => NULL,
                                p_retainage_withheld_amt => NULL,
                                p_retainage_released_amt => NULL,
				p_last_update_login  => l_last_update_login,
				p_request_id	     => l_request_id);

          END LOOP;

          CLOSE po_dists;

          l_po_ap_line_loc_rec := PO_AP_LINE_LOC_REC_TYPE.create_object(
                                 p_po_line_location_id => l_po_line_location_id,
                                 p_uom_code            => l_uom_code,
                                 p_quantity_billed     => NULL,
                                 p_amount_billed       => l_shipment_amount_billed,
                                 p_quantity_financed  => NULL,
                                 p_amount_financed    => NULL,
                                 p_quantity_recouped  => NULL,
                                 p_amount_recouped    => NULL,
                                 p_retainage_withheld_amt => NULL,
                                 p_retainage_released_amt => NULL,
				 p_last_update_login  => l_last_update_login,
				 p_request_id	      => l_request_id
                                );

          PO_AP_INVOICE_MATCH_GRP.Update_Document_Ap_Values(
                                        P_Api_Version => 1.0,
                                        P_Line_Loc_Changes_Rec => l_po_ap_line_loc_rec,
                                        P_Dist_Changes_Rec     => l_po_ap_dist_rec,
                                        X_Return_Status        => l_return_status,
                                        X_Msg_Data             => l_msg_data);

       END LOOP;

       CLOSE po_shipments;

       --bug#9573078
        --Introduced below UPDATE to NULL invoice_adjustment_flag
	--if all process done successfully.

        UPDATE po_distributions_all pd
          SET invoice_adjustment_flag = NULL
        WHERE invoice_adjustment_flag = 'S'
          AND po_distribution_id IN (
                 SELECT d.po_distribution_id
                   FROM ap_ppa_invoice_dists_gt d,
                        ap_ppa_invoice_lines_gt l
                  WHERE d.instruction_id = p_instruction_rec.invoice_id
		  AND   d.po_distribution_id = pd.po_distribution_id
		  AND   l.invoice_id = d.invoice_id
                  AND   l.line_number = d.invoice_line_number);

    ELSE

       UPDATE po_distributions_all pd
          SET last_update_date  = SYSDATE,
              last_updated_by   = FND_GLOBAL.user_id,
              last_update_login = FND_GLOBAL.conc_login_id,
              request_id        = FND_GLOBAL.conc_request_id,
              invoice_adjustment_flag = 'R'
        WHERE invoice_adjustment_flag = 'S'
          AND po_distribution_id IN (
                 SELECT d.po_distribution_id
                   FROM ap_ppa_invoice_dists_gt d,
                        ap_ppa_invoice_lines_gt l
                  WHERE l.instruction_id = d.instruction_id
                 -- AND   l.adj_type        = 'PPA' Commented for bug#9573078
                  AND   d.instruction_id = p_instruction_rec.invoice_id
                  AND   d.po_distribution_id = pd.po_distribution_id);

    END IF;

    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_RETRO_PRICING_PKG.Import_Retroprice_Adjustments(-)');
    END IF;
    --
    RETURN (TRUE);
    --
EXCEPTION
 WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);

      debug_info := 'In Others Exception';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,debug_info);
      END IF;

    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,SQLERRM);
      END IF;
    END IF;
    --
    IF ( instruction_lines%ISOPEN ) THEN
        CLOSE instruction_lines;
    END IF;
    --
    RETURN(FALSE);

END Import_Retroprice_Adjustments;


END AP_RETRO_PRICING_PKG;

/
