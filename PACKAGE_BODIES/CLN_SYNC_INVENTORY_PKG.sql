--------------------------------------------------------
--  DDL for Package Body CLN_SYNC_INVENTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CLN_SYNC_INVENTORY_PKG" AS
/* $Header: CLNSINVB.pls 120.1 2005/11/03 05:12:17 kkram noship $ */
   l_debug_level        NUMBER := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));

--  Package
--      CLN_SYNC_INVENTORY_PKG
--
--  Purpose
--      Body of package CLN_SYNC_INVENTORY_PKG.
--
--  History
--      April-17-2003  Rahul Krishan         Created



   -- Name
   --   RAISE_REPORT_GEN_EVENT
   -- Purpose
   --   The main purpose ofthis API is to capture the parameters reqd. for the generation of the
   --    inventory report as inputted by the user using concurrent program.
   -- Arguments
   --
   -- Notes
   --   No specific notes.

 PROCEDURE RAISE_REPORT_GEN_EVENT(
      x_errbuf                          OUT NOCOPY VARCHAR2,
      x_retcode                         OUT NOCOPY NUMBER,
      p_inv_user                        IN NUMBER,
      p_inv_org                         IN NUMBER,
      p_sub_inv                         IN VARCHAR2,
      p_lot_number                      IN VARCHAR2,
      p_item_category                   IN NUMBER,
      p_item_number_from                IN VARCHAR2,
      p_item_number_to                  IN VARCHAR2,
      p_item_revision_from              IN VARCHAR2,
      p_item_revision_to                IN VARCHAR2,
      p_diposition_available            IN VARCHAR2,
      p_diposition_blocked              IN VARCHAR2,
      p_diposition_allocated            IN VARCHAR2  )
 IS

      l_error_code                      NUMBER;
      l_error_msg                       VARCHAR2(255);
      l_msg_data                        VARCHAR2(255);
      l_debug_mode                      VARCHAR2(255);
      l_event_key                       NUMBER;
      l_cln_inv_parameters              wf_parameter_list_t;
      l_tp_header_id                    NUMBER;
      l_doc_number                      VARCHAR2(255);
      l_xmlg_transaction_type           VARCHAR2(255);
      l_xmlg_transaction_subtype        VARCHAR2(255);
      l_xmlg_document_id                VARCHAR2(255);
      l_tr_partner_type                 VARCHAR2(255);
      l_tr_partner_id                   VARCHAR2(255);
      l_tr_partner_site                 VARCHAR2(255);
      l_party_name                      VARCHAR2(255);
      l_doc_dir                         VARCHAR2(255);
      l_dummy_check                     VARCHAR2(10);


 BEGIN

        -- Sets the debug mode to be FILE
        --l_debug_mode :=cln_debug_pub.Set_Debug_Mode('FILE');

        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('----- Entering RAISE_REPORT_GEN_EVENT API ------- ',2);
        END IF;


        -- Initialize API return status to success
        l_msg_data := 'Successfully called the CLN API to kick off the report generation for inventory';

        -- Parameters received
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('== PARAMETERS RECEIVED FROM CONCURRENT PROGRAM== ',1);
                cln_debug_pub.Add('Inventory Organization                  - '||p_inv_org,1);
                cln_debug_pub.Add('Inventory Information User              - '||p_inv_user,1);
                cln_debug_pub.Add('Inventory Disposition (Available)       - '||p_diposition_available,1);
                cln_debug_pub.Add('Inventory Disposition (Blocked)         - '||p_diposition_blocked,1);
                cln_debug_pub.Add('Inventory Disposition (Allocated)       - '||p_diposition_allocated,1);
                cln_debug_pub.Add('Sub Inventory                           - '||p_sub_inv,1);
                cln_debug_pub.Add('Lot Number                              - '||p_lot_number,1);
                cln_debug_pub.Add('Item Category                           - '||p_item_category,1);
                cln_debug_pub.Add('Item Number[Concatenated Segment](From) - '||p_item_number_from,1);
                cln_debug_pub.Add('Item Number[Concatenated Segment](To)   - '||p_item_number_to,1);
                cln_debug_pub.Add('Item Revision Number (From)             - '||p_item_revision_from,1);
                cln_debug_pub.Add('Item Revision Number (To)               - '||p_item_revision_to,1);
                cln_debug_pub.Add('=================================================',1);
        END IF;



        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Setting Event Key....',1);
        END IF;

        SELECT cln_generic_s.nextval INTO l_event_key FROM Dual;
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Event Key  set as                   - '||l_event_key,1);

                cln_debug_pub.Add('Getting Trading Partner Details Using Tp_Header_Id',1);
        END IF;

        BEGIN

                SELECT etph.party_type, etpv.party_id, etpv.party_site_id, etpv.party_name
                INTO l_tr_partner_type, l_tr_partner_id, l_tr_partner_site, l_party_name
                FROM ecx_tp_headers_v etpv, ecx_tp_headers etph
                WHERE  etph.tp_header_id = p_inv_user
                AND etph.tp_header_id  = etpv.tp_header_id;


        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                     FND_MESSAGE.SET_NAME('CLN','CLN_CH_TP_DETAILS_NOT_FOUND');
                     l_msg_data := FND_MESSAGE.GET;
                     IF (l_Debug_Level <= 1) THEN
                             cln_debug_pub.Add('Unable to find the set up details for the trading partner',1);
                     END IF;

                     RAISE FND_API.G_EXC_ERROR;
                WHEN TOO_MANY_ROWS THEN
                     FND_MESSAGE.SET_NAME('CLN','CLN_CH_TP_DETAILS_NOT_UNIQUE');
                     l_msg_data := FND_MESSAGE.GET;
                     IF (l_Debug_Level <= 1) THEN
                             cln_debug_pub.Add('More then one row found for the same trading partner set up',1);
                     END IF;

                     RAISE FND_API.G_EXC_ERROR;
        END;
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Trading Partner Details Found',1);
        END IF;


        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Defaulting XMLG Document ID with a running sequence',1);
        END IF;

        SELECT cln_generic_s.nextval INTO l_xmlg_document_id FROM Dual;

        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Defaulting Documnet No with sysdate',1);
        END IF;


        SELECT TO_CHAR(cln_sync_inv_doc_s.nextval) INTO l_doc_number FROM Dual;

        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Checking for user input.....',1);
        END IF;

        BEGIN
                --SELECT inventory_item_id
                SELECT 'x' INTO l_dummy_check FROM DUAL
                WHERE EXISTS(
                SELECT 'x'
                FROM CLN_INVENTORY_REPORT_V
                WHERE organization_id = p_inv_org
                AND (concatenated_segments BETWEEN nvl(p_item_number_from,concatenated_segments) AND nvl(p_item_number_to,concatenated_segments))
		AND (((p_item_revision_from IS NULL OR p_item_revision_to IS NULL) AND CLN_INVENTORY_REPORT_V.REVISION_QTY_CONTROL_CODE =1)or revision BETWEEN nvl(p_item_revision_from,revision) AND nvl(p_item_revision_to,revision))
                AND EXISTS ( SELECT 'X' FROM MTL_ITEM_CATEGORIES MIC
                              WHERE (CLN_INVENTORY_REPORT_V.INVENTORY_ITEM_ID = MIC.INVENTORY_ITEM_ID(+)
                                AND CLN_INVENTORY_REPORT_V.ORGANIZATION_ID = MIC.ORGANIZATION_ID(+))
                                AND MIC.category_id = nvl(p_item_category,MIC.category_id))
                AND EXISTS (
                             SELECT 'X' FROM mtl_secondary_inventories msi, mtl_onhand_quantities_detail moqd
                              WHERE msi.organization_id = moqd.organization_id
                                AND msi.secondary_inventory_name = moqd.subinventory_code
                                AND msi.organization_id = CLN_INVENTORY_REPORT_V.organization_id
                                AND msi.secondary_inventory_name = NVL(p_sub_inv,msi.secondary_inventory_name)
                                AND moqd.inventory_item_id = CLN_INVENTORY_REPORT_V.inventory_item_id
                                AND (CLN_INVENTORY_REPORT_V.revision IS NULL OR moqd.revision IS NULL OR moqd.revision = CLN_INVENTORY_REPORT_V.revision)
                           )
                AND ( (p_lot_number IS NULL AND CLN_INVENTORY_REPORT_V.LOT_CONTROL_CODE = 1) OR
                      EXISTS (
                                SELECT 'X' FROM MTL_LOT_NUMBERS MLN
                                WHERE CLN_INVENTORY_REPORT_V.inventory_item_id = mln.inventory_item_id(+)
                                  AND CLN_INVENTORY_REPORT_V.organization_id = mln.organization_id(+)
                                  AND mln.lot_number = NVL(p_lot_number,mln.lot_number)
                             )
                    )
                );

        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                     FND_MESSAGE.SET_NAME('CLN','CLN_CH_NO_ROW_SELECTED');
                     l_msg_data := FND_MESSAGE.GET;
                     IF (l_Debug_Level <= 1) THEN
                             cln_debug_pub.Add('No records found for the user input',1);
                     END IF;

                     RAISE FND_API.G_EXC_ERROR;
                WHEN TOO_MANY_ROWS THEN
                     IF (l_Debug_Level <= 1) THEN
                             cln_debug_pub.Add('More then one row found for the user input',1);
                     END IF;

        END;
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('User input seems valid.....',1);
        END IF;


        l_cln_inv_parameters := wf_parameter_list_t();
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('---------- SETTING WORKFLOW PARAMETERS---------', 1);
        END IF;

        WF_EVENT.AddParameterToList('INV_ORGANIZATION',p_inv_org,l_cln_inv_parameters);
        WF_EVENT.AddParameterToList('TP_HEADER_ID',p_inv_user,l_cln_inv_parameters);
        WF_EVENT.AddParameterToList('INV_DIS_AVAILABLE',p_diposition_available,l_cln_inv_parameters);
        WF_EVENT.AddParameterToList('INV_DIS_BLOCKED',p_diposition_blocked,l_cln_inv_parameters);
        WF_EVENT.AddParameterToList('INV_DIS_ALLOCATED',p_diposition_allocated,l_cln_inv_parameters);
        WF_EVENT.AddParameterToList('SUB_INV',p_sub_inv,l_cln_inv_parameters);
        WF_EVENT.AddParameterToList('LOT_NUMBER', p_lot_number, l_cln_inv_parameters);
        WF_EVENT.AddParameterToList('ITEM_CATEGORY', p_item_category, l_cln_inv_parameters);
        WF_EVENT.AddParameterToList('ITEM_NUMBER_FROM', p_item_number_from, l_cln_inv_parameters);
        WF_EVENT.AddParameterToList('ITEM_NUMBER_TO', p_item_number_to, l_cln_inv_parameters);
        WF_EVENT.AddParameterToList('ITEM_REV_NUMBER_FROM',p_item_revision_from,l_cln_inv_parameters);
        WF_EVENT.AddParameterToList('ITEM_REV_NUMBER_TO',p_item_revision_to,l_cln_inv_parameters);
        WF_EVENT.AddParameterToList('TRADING_PARTNER_TYPE',l_tr_partner_type,l_cln_inv_parameters);
        WF_EVENT.AddParameterToList('TRADING_PARTNER_ID', l_tr_partner_id,l_cln_inv_parameters);
        WF_EVENT.AddParameterToList('TRADING_PARTNER_SITE', l_tr_partner_site,l_cln_inv_parameters);
        WF_EVENT.AddParameterToList('DOCUMENT_NO', l_doc_number,l_cln_inv_parameters);
        WF_EVENT.AddParameterToList('XMLG_DOCUMENT_ID', l_xmlg_document_id,l_cln_inv_parameters);
        WF_EVENT.AddParameterToList('TRADING_PARTNER_NAME', l_party_name,l_cln_inv_parameters);
        WF_EVENT.AddParameterToList('XMLG_INTERNAL_TXN_TYPE', 'CLN',l_cln_inv_parameters);
        WF_EVENT.AddParameterToList('XMLG_INTERNAL_TXN_SUBTYPE', 'INVRT',l_cln_inv_parameters);
        WF_EVENT.AddParameterToList('DOCUMENT_DIRECTION', 'OUT',l_cln_inv_parameters);


        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('======== PARAMETERS DEFAULTED ======== ',1);
                cln_debug_pub.Add('DOCUMENT_NO                    ----- >>> '||l_doc_number,1);
                cln_debug_pub.Add('XMLG EXT TRANSACTION TYPE      ----- >>> '||'INVENTORY',1);
                cln_debug_pub.Add('XMLG EXT TRANSACTION SUBTYPE   ----- >>> '||'SYNC',1);
                cln_debug_pub.Add('XMLG INT TRANSACTION TYPE      ----- >>> '||'CLN',1);
                cln_debug_pub.Add('XMLG INT TRANSACTION SUBTYPE   ----- >>> '||'INVRT',1);
                cln_debug_pub.Add('XMLG DOCUMENT ID               ----- >>> '||l_xmlg_document_id,1);
                cln_debug_pub.Add('DOCUMENT DIRECTION             ----- >>> '||'OUT',1);
                cln_debug_pub.Add('TRADING PARTNER TYPE           ----- >>> '||l_tr_partner_type,1);
                cln_debug_pub.Add('TRADING PARTNER ID             ----- >>> '||l_tr_partner_id,1);
                cln_debug_pub.Add('TRADING PARTNER SITE           ----- >>> '||l_tr_partner_site,1);
                cln_debug_pub.Add('TRADING PARTNER NAME           ----- >>> '||l_party_name,1);
                cln_debug_pub.Add('=======================================  ',1);
        END IF;


        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Workflow event- oracle.apps.cln.inv.genreport', 1);
        END IF;

        WF_EVENT.Raise('oracle.apps.cln.inv.genreport',l_event_key, NULL, l_cln_inv_parameters, NULL);

        x_retcode  := 0;
        x_errbuf   := 'Successful';

        -- check the error message
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add(l_msg_data,1);
        END IF;

        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('------- Exiting RAISE_REPORT_GEN_EVENT API --------- ',2);
        END IF;


 -- Exception Handling
 EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
             x_retcode          := 2 ;
             x_errbuf           := l_msg_data;
             IF (l_Debug_Level <= 5) THEN
                     cln_debug_pub.Add(l_msg_data,4);
                     cln_debug_pub.Add('------- Exiting RAISE_REPORT_GEN_EVENT API --------- ',2);
             END IF;


        WHEN OTHERS THEN
             l_error_code       :=SQLCODE;
             l_error_msg        :=SQLERRM;
             x_retcode          :=2 ;
             FND_MESSAGE.SET_NAME('CLN','CLN_CH_UNEXPECTED_ERROR');
             FND_MESSAGE.SET_TOKEN('ERRORCODE',l_error_code);
             FND_MESSAGE.SET_TOKEN('ERRORMSG',l_error_msg);
             l_msg_data         :='Unexpected Error  -'||l_error_code||' : '||l_error_msg;
             x_errbuf           := l_msg_data;
             IF (l_Debug_Level <= 5) THEN
                     cln_debug_pub.Add(l_msg_data,6);
                     cln_debug_pub.Add('------- Exiting RAISE_REPORT_GEN_EVENT API --------- ',2);
             END IF;


 END RAISE_REPORT_GEN_EVENT;


    -- Name
    --   GET_XML_TAG_VALUES
    -- Purpose
    --   The main purpose ofthis API is to call the inventory API - INVPQTTS.pls and
    --   based on the user input through concurrent program and also using the profile
    --   option calculate quantity on hand, avaliable to use , quantity blocked and allocated.
    --
    -- Arguments
    --
    -- Notes
    --   No specific notes.

  PROCEDURE GET_XML_TAG_VALUES(
       x_return_status                   OUT NOCOPY VARCHAR2,
       x_msg_data                        OUT NOCOPY VARCHAR2,
       p_inv_org                         IN NUMBER,
       p_diposition_available            IN VARCHAR2,
       p_diposition_blocked              IN VARCHAR2,
       p_diposition_allocated            IN VARCHAR2,
       p_sub_inv                         IN VARCHAR2,
       p_lot_number                      IN VARCHAR2,
       p_item_number                     IN NUMBER,
       p_item_revision                   IN VARCHAR2,
       p_lot_ctrl_number                 IN NUMBER,
       p_item_revision_ctrl_number       IN NUMBER,
       p_tp_type                         IN VARCHAR2,
       p_tp_id                           IN NUMBER,
       p_tp_site_id                      IN VARCHAR2,
       p_xmlg_transaction_type           IN VARCHAR2, --
       p_xmlg_transaction_subtype        IN VARCHAR2, --
       p_xmlg_document_id                IN VARCHAR2, --
       p_xml_event_key                   IN VARCHAR2, --
       p_xmlg_internal_control_number    IN NUMBER,   --
       x_customer_item_number            OUT NOCOPY VARCHAR2,
       x_quantity_on_hand                OUT NOCOPY NUMBER,
       x_quantity_blocked                OUT NOCOPY NUMBER,
       x_quantity_allocated              OUT NOCOPY NUMBER )
  IS

       l_error_code                      NUMBER;
       l_error_msg                       VARCHAR2(2000);
       l_msg_data                        VARCHAR2(255);
       l_debug_mode                      VARCHAR2(255);
       l_revision                        VARCHAR2(255);
       l_return_status                   VARCHAR2(255);
       l_doc_status                      VARCHAR2(20);
       l_msg_count                       NUMBER;

       -- QUANTITY ---
       l_qty_on_hand                     NUMBER;
       l_reserved_qty_on_hand            NUMBER;
       l_quantity_reserved               NUMBER;
       l_quantity_suggested              NUMBER;
       l_available_to_transaction        NUMBER;
       l_available_to_reserve            NUMBER;
       l_blocked_qty                     NUMBER;

       l_is_revision_control             BOOLEAN;
       l_is_lot_control                  BOOLEAN;

       l_inv_atp_code                    NUMBER;
       l_availability_type               NUMBER;
       l_tree_mode                       NUMBER;
       l_onhand_source                   NUMBER;
       l_coll_id                         NUMBER;

       ----FOR PROFILE-----
       l_profile_blocked_qty_eq          VARCHAR2(200);

  BEGIN

         -- Sets the debug mode to be FILE
         --l_debug_mode :=cln_debug_pub.Set_Debug_Mode('FILE');

         IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('----- Entering GET_XML_TAG_VALUES API ------- ',2);
         END IF;


         -- Initialize API return status to success
         l_msg_data := 'successfully obtained quantity values for On Hand/ Available To use / Blocked / Allocated Items';

         -- Parameters received
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('== PARAMETERS RECEIVED FROM XGM================== ',1);
                 cln_debug_pub.Add('Inventory Organization             - '||p_inv_org,1);
                 cln_debug_pub.Add('Inventory Disposition (Available)  - '||p_diposition_available,1);
                 cln_debug_pub.Add('Inventory Disposition (Blocked)    - '||p_diposition_blocked,1);
                 cln_debug_pub.Add('Inventory Disposition (Allocated   - '||p_diposition_allocated,1);
                 cln_debug_pub.Add('Sub Inventory                      - '||p_sub_inv,1);
                 cln_debug_pub.Add('Lot Number                         - '||p_lot_number,1);
                 cln_debug_pub.Add('Item Number (ID)                   - '||p_item_number,1);
                 cln_debug_pub.Add('Item Revision                      - '||p_item_revision,1);
                 cln_debug_pub.Add('Trading Partner Type               - '||p_tp_type,1);
                 cln_debug_pub.Add('Trading Partner ID                 - '||p_tp_id,1);
                 cln_debug_pub.Add('Lot Control Number                 - '||p_lot_ctrl_number,1);
                 cln_debug_pub.Add('Item Rev Control Number            - '||p_item_revision_ctrl_number,1);
                 cln_debug_pub.Add('Trading Partner Site ID            - '||p_tp_site_id,1);
                 cln_debug_pub.Add('XMLG Transaction Type              - '||p_xmlg_transaction_type,1);
                 cln_debug_pub.Add('XMLG Transaction Sub Type          - '||p_xmlg_transaction_subtype,1);
                 cln_debug_pub.Add('XMLG Document ID                   - '||p_xmlg_document_id,1);
                 cln_debug_pub.Add('XML Event Key                      - '||p_xml_event_key,1);
                 cln_debug_pub.Add('Internal Control Number            - '||p_xmlg_internal_control_number,1);
                 cln_debug_pub.Add('=================================================',1);
         END IF;



         IF (p_item_revision_ctrl_number = 2) THEN
                IF (p_item_revision IS NULL) THEN
                    l_is_revision_control := FALSE;

	            IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Set the value of l_is_revision_control = FALSE',1);
                    END IF;
                ELSE
                    l_is_revision_control := TRUE;

	            IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Set the value of l_is_revision_control = TRUE',1);
                    END IF;
                END IF;
         END IF;

         IF (p_lot_ctrl_number = 2) THEN
		IF (p_lot_number IS NULL) THEN
                    l_is_lot_control := FALSE;

                    IF (l_Debug_Level <= 1) THEN
                	cln_debug_pub.Add('Set the value of l_is_lot_control = FALSE',1);
                    END IF;
                ELSE
                    l_is_lot_control := TRUE;

                    IF (l_Debug_Level <= 1) THEN
                	cln_debug_pub.Add('Set the value of l_is_lot_control = TRUE',1);
                    END IF;
                END IF;
         END IF;

         IF( p_tp_type = 'C') THEN
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Check for the Customer type- C and assign the item name accordingly',1);
                END IF;

                BEGIN
                        SELECT mci.customer_item_number
                        INTO x_customer_item_number
                        FROM
                              mtl_customer_items mci  ,
                              mtl_customer_item_xrefs mcix
                        WHERE mcix.master_organization_id = p_inv_org
                          AND mcix.inventory_item_id = p_item_number
                          AND mci.customer_id = p_tp_id
                          AND mci.customer_item_id(+) = mcix.customer_item_id;
                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           IF (l_Debug_Level <= 1) THEN
                                   cln_debug_pub.Add('Customer Item Number Not Found ',1);
                           END IF;

                END;
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Item number defined for the customer is :'||x_customer_item_number,1);
                END IF;

         END IF;


         -- Check for Profile value of Blocked Quantity
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('Check for the profile value of the Blocked quantity',1);
         END IF;

         l_profile_blocked_qty_eq  := FND_PROFILE.VALUE('CLN_DEF_BLOCKED_QTY');
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('Blocked Quantity Eq set up in Profile value :'||l_profile_blocked_qty_eq,1);
         END IF;


         IF ( l_profile_blocked_qty_eq = 'NON_NETTABLE') THEN
             l_tree_mode           := 2;
             l_onhand_source       := 2;
             BEGIN
                  SELECT nvl(sum(moqd.primary_transaction_quantity),0)
                  INTO x_quantity_blocked
                  FROM mtl_onhand_quantities_detail moqd, mtl_secondary_inventories msi
                  WHERE moqd.organization_id = p_inv_org
                  AND moqd.inventory_item_id = p_item_number
                  AND moqd.subinventory_code = msi.secondary_inventory_name
                  AND moqd.organization_id   = msi.organization_id
                  AND msi.availability_type  = 2
                  AND moqd.subinventory_code = nvl(p_sub_inv,moqd.subinventory_code)
                  AND (p_item_revision IS NULL OR moqd.revision IS NULL OR moqd.revision = p_item_revision)
                  AND (p_lot_number IS NULL OR moqd.lot_number = p_lot_number);
              EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                       -- unreached code
                       IF (l_Debug_Level <= 1) THEN
                               cln_debug_pub.Add('No Rows selected from the SQL statement used for calculating Blocked Qty',1);
                       END IF;

              END;
              IF (l_Debug_Level <= 1) THEN
                      cln_debug_pub.Add('Blocked Quantity   :'||x_quantity_blocked,1);
              END IF;

         ELSIF ( l_profile_blocked_qty_eq = 'NON_ATPABLE') THEN
             l_tree_mode           := 2;
             l_onhand_source       := 1;

             BEGIN
                  SELECT nvl(sum(moqd.primary_transaction_quantity),0)
                  INTO x_quantity_blocked
                  FROM mtl_onhand_quantities_detail moqd, mtl_secondary_inventories msi
                  WHERE moqd.organization_id = p_inv_org
                    AND moqd.inventory_item_id = p_item_number
                    AND moqd.subinventory_code = msi.secondary_inventory_name
                    AND moqd.organization_id = msi.organization_id
                    AND msi.inventory_atp_code = 2
                    AND moqd.subinventory_code = nvl(p_sub_inv,moqd.subinventory_code)
                    AND (p_item_revision IS NULL OR moqd.revision IS NULL OR moqd.revision = p_item_revision)
                    AND (p_lot_number IS NULL OR moqd.lot_number = p_lot_number);
             EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                       -- unreached code
                       IF (l_Debug_Level <= 1) THEN
                               cln_debug_pub.Add('No Rows selected from the SQL statement used for calculating Blocked Qty',1);
                       END IF;

             END;
             IF (l_Debug_Level <= 1) THEN
                     cln_debug_pub.Add('Blocked Quantity   :'||x_quantity_blocked,1);
             END IF;

         ELSIF ( l_profile_blocked_qty_eq = 'NON_NETTABLE_OR_NON_ATPABLE') THEN
             l_tree_mode           := 2;
             l_onhand_source       := inv_quantity_tree_pvt.g_atpable_nettable_only;

             BEGIN
                  SELECT nvl(sum(moqd.primary_transaction_quantity),0)
                  INTO x_quantity_blocked
                  FROM mtl_onhand_quantities_detail moqd, mtl_secondary_inventories msi
                  WHERE moqd.organization_id = p_inv_org
                    AND moqd.inventory_item_id = p_item_number
                    AND moqd.subinventory_code = msi.secondary_inventory_name
                    AND moqd.organization_id = msi.organization_id
                    AND (msi.inventory_atp_code = 2 OR msi.availability_type = 2)
                    AND moqd.subinventory_code = nvl(p_sub_inv,moqd.subinventory_code)
                    AND (p_item_revision IS NULL OR moqd.revision IS NULL OR moqd.revision = p_item_revision)
                    AND (p_lot_number IS NULL OR moqd.lot_number = p_lot_number);
             EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                       -- unreached code
                       IF (l_Debug_Level <= 1) THEN
                               cln_debug_pub.Add('No Rows selected from the SQL statement used for calculating Blocked Qty',1);
                       END IF;

             END;
             IF (l_Debug_Level <= 1) THEN
                     cln_debug_pub.Add('Blocked Quantity   :'||x_quantity_blocked,1);
             END IF;

         END IF;

         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('Tree Mode          : '||l_tree_mode,1);
                 cln_debug_pub.Add('OnHand Source      : '||l_onhand_source,1);

                 cln_debug_pub.Add('Call Inventory API .....',1);
         END IF;


         inv_quantity_tree_pub.query_quantities
                (  p_api_version_number       => 1
                 , p_init_msg_lst             => fnd_api.g_true
                 , x_return_status            => x_return_status
                 , x_msg_count                => l_msg_count
                 , x_msg_data                 => l_msg_data
                 , p_organization_id          => p_inv_org
                 , p_inventory_item_id        => p_item_number
                 , p_tree_mode                => l_tree_mode
                 , p_is_revision_control      => l_is_revision_control
                 , p_is_lot_control           => l_is_lot_control
                 , p_is_serial_control        => false
                 --   , p_demand_source_type_id    IN  NUMBER   DEFAULT -9999
                 --   , p_demand_source_header_id  IN  NUMBER   DEFAULT -9999
                 --   , p_demand_source_line_id    IN  NUMBER   DEFAULT -9999
                 --   , p_demand_source_name       IN  VARCHAR2 DEFAULT NULL
                 --   , p_lot_expiration_date      IN  DATE     DEFAULT NULL
                 , p_revision                 => p_item_revision
                 , p_lot_number               => p_lot_number
                 , p_subinventory_code        => p_sub_inv
                 , p_locator_id               => null
                 , p_onhand_source            => l_onhand_source
                 , x_qoh                      => l_qty_on_hand
                 , x_rqoh                     => l_reserved_qty_on_hand
                 , x_qr                       => l_quantity_reserved
                 , x_qs                       => l_quantity_suggested
                 , x_att                      => l_available_to_transaction
                 , x_atr                      => l_available_to_reserve
                 --   , p_transfer_subinventory_code IN  VARCHAR2 DEFAULT NULL
                 --   , p_cost_group_id            IN  NUMBER DEFAULT NULL
                 --   , p_lpn_id                   IN  NUMBER DEFAULT NULL
                 --   , p_transfer_locator_id      IN  NUMBER DEFAULT NULL
               );


         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('== PARAMETERS RECEIVED FROM INVENTORY API== ',1);
                 cln_debug_pub.Add('Return Status                      - '||x_return_status,1);
                 cln_debug_pub.Add('Message Count                      - '||l_msg_count,1);
                 cln_debug_pub.Add('Message Data                       - '||l_msg_data,1);
                 cln_debug_pub.Add('Quanity on Hand                    - '||l_qty_on_hand,1);
                 cln_debug_pub.Add('Reserved Quanity on Hand           - '||l_reserved_qty_on_hand,1);
                 cln_debug_pub.Add('Quantity Reserved                  - '||l_quantity_reserved,1);
                 cln_debug_pub.Add('Quanity Suggested                  - '||l_quantity_suggested,1);
                 cln_debug_pub.Add('Quantity Available for Transaction - '||l_available_to_transaction,1);
                 cln_debug_pub.Add('Quantity Available to Reserve      - '||l_available_to_reserve,1);
                 cln_debug_pub.Add('=================================================',1);
         END IF;


         IF ( x_return_status <> 'S') THEN
                x_msg_data   := l_msg_data;
                l_msg_data   :='Error in Inventory API. Detail error msg -> '||l_msg_data;
                IF (l_Debug_Level <= 2) THEN
                        cln_debug_pub.Add(' Error : '||l_msg_data,2);
                END IF;

                RAISE FND_API.G_EXC_ERROR;
         END IF;


         IF((p_diposition_blocked = 'Null') OR (p_diposition_blocked IS NULL)) THEN
                x_quantity_blocked := NULL;
         END IF;

         IF((p_diposition_allocated = 'Null') OR (p_diposition_allocated IS NULL)) THEN
                x_quantity_allocated := NULL;
         ELSE
                x_quantity_allocated := l_quantity_reserved + l_quantity_suggested;
         END IF;
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('Allocated Quantity : '||x_quantity_allocated,1);
                 cln_debug_pub.Add('Blocked Quantity   : '||x_quantity_blocked,1);
         END IF;


         IF (p_diposition_available  = 'Available To Use') THEN
             x_quantity_on_hand   := l_qty_on_hand - (l_quantity_reserved + l_quantity_suggested);-- qty on hand already takes out blocked
         ELSE
             IF (l_Debug_Level <= 1) THEN
                     cln_debug_pub.Add('Call Inventory API for calculating On Hand Qty : ',1);
                     cln_debug_pub.Add('Tree Mode          : '||2,1);
                     cln_debug_pub.Add('OnHand Source      : '||3,1);
             END IF;


             inv_quantity_tree_pub.query_quantities
                (  p_api_version_number       => 1
                 , p_init_msg_lst             => fnd_api.g_true
                 , x_return_status            => x_return_status
                 , x_msg_count                => l_msg_count
                 , x_msg_data                 => l_msg_data
                 , p_organization_id          => p_inv_org
                 , p_inventory_item_id        => p_item_number
                 , p_tree_mode                => 2
                 , p_is_revision_control      => l_is_revision_control
                 , p_is_lot_control           => l_is_lot_control
                 , p_is_serial_control        => false
                 --   , p_demand_source_type_id    IN  NUMBER   DEFAULT -9999
                 --   , p_demand_source_header_id  IN  NUMBER   DEFAULT -9999
                 --   , p_demand_source_line_id    IN  NUMBER   DEFAULT -9999
                 --   , p_demand_source_name       IN  VARCHAR2 DEFAULT NULL
                 --   , p_lot_expiration_date      IN  DATE     DEFAULT NULL
                 , p_revision                 => p_item_revision
                 , p_lot_number               => p_lot_number
                 , p_subinventory_code        => p_sub_inv
                 , p_locator_id               => null
                 , p_onhand_source            => 3
                 , x_qoh                      => l_qty_on_hand
                 , x_rqoh                     => l_reserved_qty_on_hand
                 , x_qr                       => l_quantity_reserved
                 , x_qs                       => l_quantity_suggested
                 , x_att                      => l_available_to_transaction
                 , x_atr                      => l_available_to_reserve
                 --   , p_transfer_subinventory_code IN  VARCHAR2 DEFAULT NULL
                 --   , p_cost_group_id            IN  NUMBER DEFAULT NULL
                 --   , p_lpn_id                   IN  NUMBER DEFAULT NULL
                 --   , p_transfer_locator_id      IN  NUMBER DEFAULT NULL
               );

             IF ( x_return_status <> 'S') THEN
                   x_msg_data   := l_msg_data;
                   l_msg_data   :='Error in Inventory API. Detail error msg -> '||l_msg_data;
                   IF (l_Debug_Level <= 1) THEN
                           cln_debug_pub.Add(' Error : '||l_msg_data,1);
                   END IF;

                   RAISE FND_API.G_EXC_ERROR;
             END IF;
             x_quantity_on_hand   := l_qty_on_hand;
         END IF;

         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('On Hand Quantity is  = '||x_quantity_on_hand,1);
         END IF;


         FND_MESSAGE.SET_NAME('CLN','CLN_INV_REPORT_GENERATED');
         l_msg_data            := FND_MESSAGE.GET;
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('Success Message : '||l_msg_data,1);
         END IF;

         IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('------- Exiting GET_XML_TAG_VALUES API --------- ',2);
         END IF;

         x_return_status := 'S';

 -- Exception Handling
 EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR ;
             IF (l_Debug_Level <= 5) THEN
                     cln_debug_pub.Add(l_msg_data,4);
                     cln_debug_pub.Add('------- Exiting GET_XML_TAG_VALUES API --------- ',2);
             END IF;


        WHEN OTHERS THEN
             l_error_code       :=SQLCODE;
             l_error_msg        :=SQLERRM;
             x_return_status   := FND_API.G_RET_STS_UNEXP_ERROR ;
             FND_MESSAGE.SET_NAME('CLN','CLN_CH_UNEXPECTED_ERROR');
             FND_MESSAGE.SET_TOKEN('ERRORCODE',l_error_code);
             FND_MESSAGE.SET_TOKEN('ERRORMSG',l_error_msg);
             l_msg_data         :='Unexpected Error  -'||l_error_code||' : '||l_error_msg;
             x_msg_data         := l_msg_data;
             IF (l_Debug_Level <= 5) THEN
                     cln_debug_pub.Add(l_msg_data,6);
                     cln_debug_pub.Add('------- Exiting GET_XML_TAG_VALUES API --------- ',2);
             END IF;


 END GET_XML_TAG_VALUES;

END CLN_SYNC_INVENTORY_PKG;

/
