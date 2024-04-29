--------------------------------------------------------
--  DDL for Package Body CLN_SYNCITEM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CLN_SYNCITEM_PKG" AS
/* $Header: CLNSYITB.pls 120.4 2006/11/02 10:56:05 slattupa noship $ */
 l_debug_level        NUMBER := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));
 g_party_id           VARCHAR2(40);

--  Package
--      CLN_SYNCITEM_PKG
--
--  Purpose
--      Body of package CLN_SYNCITEM_PKG.
--
--  History
--      July-21-2003        Rahul Krishan         Created


   -- Name
   --    GET_PARTY_ID
   -- Purpose
   --    This function returns the trading party id where the Payload needs to be sent
   --
   -- Arguments
   --
   -- Notes
   --    No specific notes.
   FUNCTION GET_PARTY_ID
   RETURN NUMBER
   IS
   BEGIN
      RETURN g_party_id;
   END;


    -- Name
    --    GET_CUST_ACCT_ID
    -- Purpose
    --    This function returns the customer account id
    --
    -- Arguments
    --
    -- Notes
    --    No specific notes.
    FUNCTION GET_CUST_ACCT_ID
    RETURN NUMBER
    IS
        l_cust_acct_id                 NUMBER;

    BEGIN

       IF (l_Debug_Level <= 2) THEN
            cln_debug_pub.Add('----- Entering GET_CUST_ACCT_ID API ------- ',2);
       END IF;

       SELECT hca.cust_account_id cust_account_id
       INTO l_cust_acct_id
       FROM hz_cust_accounts hca
       WHERE hca.party_id = CLN_SYNCITEM_PKG.GET_PARTY_ID();

       IF (l_Debug_Level <= 2) THEN
             cln_debug_pub.Add('Customer Account ID '||l_cust_acct_id,2);
             cln_debug_pub.Add('----- Entering GET_CUST_ACCT_ID API ------- ',2);
       END IF;

       RETURN l_cust_acct_id;

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
               IF (l_Debug_Level <= 1) THEN
                     cln_debug_pub.Add('Unable to find the customer details',1);
               END IF;
    END;


    -- Name
    --      SET_PARTY_ID
    -- Purpose
    --    This procedure is called from the 2A12 XGM and while the inprocessing mode
    --    is carried out. This makes sure that the view cln_2a12_party_v gets value
    --    This procedure sets the party id so as to maintain the
    --    context from within the XGM.
    --
    -- Arguments
    --
    -- Notes
    --    No specific notes.

    PROCEDURE SET_PARTY_ID  ( p_tp_party_id  IN         NUMBER)

    IS
    l_debug_level                 NUMBER;

    BEGIN

      IF (l_Debug_Level <= 2) THEN
            cln_debug_pub.Add('----- Entering SET_PARTY_ID API ------- ',2);
      END IF;

      g_party_id := p_tp_party_id;

      IF (l_Debug_Level <= 2) THEN
            cln_debug_pub.Add('----- Party Id set as   '||g_party_id,1);
            cln_debug_pub.Add('----- Exting SET_PARTY_ID API ------- ',2);
      END IF;

    END;



   -- Name
   --    RAISE_SYNCITEM_EVENT
   -- Purpose
   --    This procedure is called from the 2A12 concurrent program.
   --    This captures the user input and after processing raises an event for
   --    for outbound processing.
   -- Arguments
   --
   -- Notes
   --    No specific notes.
   PROCEDURE Raise_Syncitem_Event(
                errbuf                          OUT NOCOPY      VARCHAR2,
                retcode                         OUT NOCOPY      VARCHAR2,
                p_tp_header_id                  IN              NUMBER,
                p_inventory_org_id              IN              NUMBER,
                p_category_set_id               IN              NUMBER,
                p_category_id                   IN              NUMBER,
                p_catalog_category_id           IN              NUMBER,
                p_item_status                   IN              VARCHAR2,
                p_from_items                    IN              VARCHAR2,
                p_to_items                      IN              VARCHAR2,
                p_numitems_per_payload          IN              NUMBER)

   IS

                l_genwf_cln_parameter_list      wf_parameter_list_t;
                l_profile_value                 VARCHAR2(100);

                l_date                          DATE;

                l_error_code                    NUMBER;
                l_event_key                     NUMBER;
                l_tp_header_id                  NUMBER;
                l_syncitem_seq                  NUMBER;
                l_organization_id               NUMBER;
                l_view_party_id                 NUMBER;
                --l_dummy_count                 NUMBER;


                l_canonical_date                VARCHAR2(100);
                l_from_items                    VARCHAR2(100);
                l_to_items                      VARCHAR2(100);

                l_from_items_subset             VARCHAR2(100);
                l_to_items_subset               VARCHAR2(100);

                l_error_msg                     VARCHAR2(255);
                l_msg_data                      VARCHAR2(255);
                l_doc_number                    VARCHAR2(255);
                l_xmlg_transaction_type         VARCHAR2(255);
                l_xmlg_transaction_subtype      VARCHAR2(255);
                l_xmlg_document_id              VARCHAR2(255);
                l_tr_partner_type               VARCHAR2(255);
                l_tr_partner_id                 VARCHAR2(255);
                l_tr_partner_site               VARCHAR2(255);
                l_party_name                    VARCHAR2(255);
                l_doc_dir                       VARCHAR2(255);
                l_dummy_check                   VARCHAR2(2);
                l_counter                       BINARY_INTEGER;
                l_items_exist                   BOOLEAN;


      -- cursor to hold the list of items to send
      CURSOR c_ItemsToSend ( p_inventory_org_id         NUMBER,
                             p_category_set_id          NUMBER,
                             p_category_id              NUMBER,
                             p_catalog_category_id      NUMBER,
                             p_item_status              VARCHAR2,
                             p_from_items               VARCHAR2,
                             p_to_items                 VARCHAR2)
      IS
      SELECT concatenated_segments
      FROM CLN_ITEMMST_ITEMHEADER_V
      WHERE ORGANIZATION_ID= p_inventory_org_id
      AND ( p_category_set_id IS NULL OR
            p_category_set_id IN
                    (  SELECT mcsvc.category_set_id
                       FROM mtl_item_categories mic, mtl_category_set_valid_cats mcsvc
                       WHERE mcsvc.category_set_id = mic.category_set_id AND
                             mic.inventory_item_id = CLN_ITEMMST_ITEMHEADER_V.INVENTORY_ITEM_ID AND
                             mic.organization_id   = p_inventory_org_id
                    )
          )
      AND ( p_category_id IS NULL OR
            p_category_id IN
                    (   SELECT mcsvc.category_id
                        FROM mtl_item_categories mic, mtl_category_set_valid_cats mcsvc
                        WHERE mcsvc.category_id     = mic.category_id AND
                              mic.inventory_item_id = CLN_ITEMMST_ITEMHEADER_V.INVENTORY_ITEM_ID AND
                              mic.organization_id   = p_inventory_org_id
                    )
          )
      AND ( p_catalog_category_id IS NULL OR
            p_catalog_category_id IN
                    (   SELECT micgk.item_catalog_group_id
                        FROM mtl_item_catalog_groups_kfv micgk
                        WHERE micgk.item_catalog_group_id = CLN_ITEMMST_ITEMHEADER_V.item_catalog_group_id
                    )
          )
      AND ( p_item_status IS NULL OR
            INVENTORY_ITEM_STATUS_CODE = p_item_status)
      AND (
            CONCATENATED_SEGMENTS >=  nvl(p_from_items,CONCATENATED_SEGMENTS)
            AND
            CONCATENATED_SEGMENTS <=  nvl(p_to_items,CONCATENATED_SEGMENTS)
          )
      ORDER BY concatenated_segments;

 BEGIN

        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('----- Entering Raise_Syncitem_Event API ------- ',2);
        END IF;


        -- Initialize API return status to success
        l_msg_data              := 'Successfully called the CLN API to kick off sync items event';


        -- Parameters received from the concurrrent program
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('== PARAMETERS RECEIVED FROM CONCURRENT PROGRAM== ',1);
                cln_debug_pub.Add('Trading Partner Header ID               - '||p_tp_header_id,1);
                cln_debug_pub.Add('Inventory Org ID                        - '||p_inventory_org_id,1);
                cln_debug_pub.Add('Category Set ID                         - '||p_category_set_id,1);
                cln_debug_pub.Add('Category ID                             - '||p_category_id,1);
                cln_debug_pub.Add('Catalog Category ID                     - '||p_catalog_category_id,1);
                cln_debug_pub.Add('Item Status                             - '||p_item_status,1);
                cln_debug_pub.Add('From Items [Concatenated Segment]       - '||p_from_items,1);
                cln_debug_pub.Add('To Items   [Concatenated Segment]       - '||p_to_items,1);
                cln_debug_pub.Add('Number Of Items /Message                - '||p_numitems_per_payload,1);
                cln_debug_pub.Add('=================================================',1);
        END IF;


        -- Getting Trading Partner Details
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Getting Trading Partner Details Using Tp_Header_Id',1);
        END IF;

        BEGIN

                select eth.party_type, eth.party_id, eth.party_site_id
                INTO l_tr_partner_type, l_tr_partner_id, l_tr_partner_site
                from ecx_tp_headers eth
                where eth.tp_header_id = p_tp_header_id;

                -- this is reqd for setting the view cln_2a12_party_v
                g_party_id := l_tr_partner_id;



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
                cln_debug_pub.Add('======== Trading Partner Details Found =========',1);
                cln_debug_pub.Add('Trading Partner Type - '||l_tr_partner_type,1);
                cln_debug_pub.Add('Trading Partner ID   - '||l_tr_partner_id,1);
                cln_debug_pub.Add('Trading Partner Site - '||l_tr_partner_site,1);
                cln_debug_pub.Add('Trading Partner Name - '||l_party_name,1);
        END IF;


        -- Defaulting based on some business logic

        l_from_items    :=      p_from_items;
        l_to_items      :=      p_to_items;


        BEGIN
             IF (l_Debug_Level <= 1) THEN
                   cln_debug_pub.Add('Checking for the users choice ....',1);
             END IF;


             l_profile_value := fnd_profile.VALUE ('CLN_ITEM_SEND_CUST_XREF_ONLY');

             IF (l_Debug_Level <= 1) THEN
                   cln_debug_pub.Add('profile value for - CLN_ITEM_SEND_CUST_XREF_ONLY -'||l_profile_value,1);
             END IF;

	     -- Modified the query below due to performance hit. Bug #4946778

               SELECT 'x' into l_dummy_check FROM dual
	       WHERE EXISTS (SELECT 'X' FROM mtl_system_items_b_kfv msib, --mtl_system_items_vl msib,
	       	                             mtl_customer_item_xrefs mcix, -- mtl_item_revisions mir,
					     po_hazard_classes_tl phct,
					     MTL_CUSTOMER_ITEMS MCI,
					     HZ_PARTIES HZP,
					     MFG_LOOKUPS MFL ,
					     HZ_CUST_ACCOUNTS HZC,
					     AR_LOOKUPS ARL
                                       WHERE mcix.customer_item_id = mci.customer_item_id AND
                                             mcix.inventory_item_id(+)= msib.inventory_item_id AND
					     mcix.master_organization_id =msib.organization_id AND
					     mci.customer_id(+) =  cln_syncitem_pkg.get_cust_acct_id () AND
					     -- msib.inventory_item_id = mir.inventory_item_id(+) AND
					     -- msib.organization_id = mir.organization_id(+) AND
					     MCI.CUSTOMER_CATEGORY_CODE = ARL.LOOKUP_CODE(+) AND
					     msib.service_item_flag = 'N' AND
					     msib.inventory_item_flag = 'Y' AND
					     msib.customer_order_enabled_flag = 'Y' AND
					     MCI.INACTIVE_FLAG = 'N' AND
					     HZC.PARTY_ID = HZP.PARTY_ID AND HZC.STATUS = 'A' AND
					     msib.hazard_class_id = phct.hazard_class_id(+) AND
					     MCI.CUSTOMER_ID = HZC.CUST_ACCOUNT_ID AND
					     MCI.ITEM_DEFINITION_LEVEL = MFL.LOOKUP_CODE AND
					     MFL.LOOKUP_TYPE = 'INV_ITEM_DEFINITION_LEVEL' AND
					     --mir.revision = (SELECT MAX (revision) FROM mtl_item_revisions WHERE inventory_item_id = mir.inventory_item_id AND
					     --organization_id = mir.organization_id) AND
					     phct.LANGUAGE(+) = USERENV ('lang')      AND
					     ARL.ENABLED_FLAG(+) = 'Y' AND
					     ARL.LOOKUP_TYPE(+) = 'ADDRESS_CATEGORY' AND
					     TRUNC(SYSDATE) BETWEEN NVL(TRUNC((ARL.START_DATE_ACTIVE(+))),SYSDATE) AND
					     NVL(TRUNC((ARL.END_DATE_ACTIVE(+))), SYSDATE) AND
					     ( ( NVL (fnd_profile.VALUE ('CLN_ITEM_SEND_CUST_XREF_ONLY'),'N') = 'Y' AND  mci.customer_item_number IS NOT NULL ) OR
					     NVL (fnd_profile.VALUE ('CLN_ITEM_SEND_CUST_XREF_ONLY'), 'N') ='N' ) AND
					     ( p_category_set_id IS NULL OR   p_category_set_id IN
                                                                            (  SELECT mcsvc.category_set_id
                                                                               FROM mtl_item_categories mic,
									            mtl_category_set_valid_cats mcsvc
                                                                               WHERE mcsvc.category_set_id = mic.category_set_id AND
                                                                                     mic.inventory_item_id = msib.INVENTORY_ITEM_ID AND
										     mic.organization_id   = p_inventory_org_id  )
                                             ) AND
					     ( p_category_id IS NULL OR  p_category_id IN
                                                                          ( SELECT mic.category_id
                                                                            FROM mtl_item_categories mic
									    WHERE  mic.category_id = p_category_id AND
									           mic.inventory_item_id = msib.INVENTORY_ITEM_ID AND
                                                                                   mic.organization_id   = p_inventory_org_id   )
                                             )AND
					     ( p_catalog_category_id IS NULL OR  p_catalog_category_id IN
                                                                              (   SELECT micgk.item_catalog_group_id
                                                                                  FROM mtl_item_catalog_groups_kfv micgk
                                                                                  WHERE micgk.item_catalog_group_id = msib.item_catalog_group_id)
                                             )AND
					     ( p_item_status IS NULL OR msib.INVENTORY_ITEM_STATUS_CODE = p_item_status)AND
					     ( msib.CONCATENATED_SEGMENTS >= NVL(l_from_items,msib.CONCATENATED_SEGMENTS)  AND
                                               msib.CONCATENATED_SEGMENTS <= NVL(l_to_items,msib.CONCATENATED_SEGMENTS)));


        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                     FND_MESSAGE.SET_NAME('CLN','CLN_CH_NO_ROW_SELECTED');
                     l_msg_data := FND_MESSAGE.GET;
                     IF (l_Debug_Level <= 1) THEN
                             cln_debug_pub.Add('No records found for the user input',1);
                     END IF;

                     RAISE FND_API.G_EXC_ERROR;
        END;

        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('User input seems valid.....',1);
        END IF;

        -- Get the document creation date as canonical date
        SELECT sysdate into l_date from dual;
        l_canonical_date := FND_DATE.DATE_TO_CANONICAL(l_date);

        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Canonical Date set as - '||l_canonical_date,1);
        END IF;


        -- Generic attribute list for generic outbound workflow
        l_genwf_cln_parameter_list :=        wf_parameter_list_t();


        wf_event.AddParameterToList(p_name              => 'ECX_PARTY_ID',
                                    p_value             => l_tr_partner_id,
                                    p_parameterlist     => l_genwf_cln_parameter_list);

        wf_event.AddParameterToList(p_name              => 'ECX_PARTY_SITE_ID',
                                    p_value             => l_tr_partner_site,
                                    p_parameterlist     => l_genwf_cln_parameter_list);

        wf_event.AddParameterToList(p_name              => 'ECX_PARTY_TYPE',
                                    p_value             => l_tr_partner_type,
                                    p_parameterlist     => l_genwf_cln_parameter_list);

        wf_event.AddParameterToList(p_name              => 'ECX_TRANSACTION_TYPE',
                                    p_value             => 'CLN',
                                    p_parameterlist     => l_genwf_cln_parameter_list);

        wf_event.AddParameterToList(p_name              => 'ECX_TRANSACTION_SUBTYPE',
                                    p_value             => 'SYNCITEMO',
                                    p_parameterlist     => l_genwf_cln_parameter_list);

        wf_event.AddParameterToList(p_name              => 'ECX_DELIVERY_CHECK_REQUIRED',
                                    p_value             => 'YES',
                                    p_parameterlist     => l_genwf_cln_parameter_list);

        wf_event.AddParameterToList(p_name              => 'MAP_PARAMETER1',
                                    p_value             => p_inventory_org_id,
                                    p_parameterlist     => l_genwf_cln_parameter_list);

        wf_event.AddParameterToList(p_name              => 'MAP_PARAMETER2',
                                    p_value             => p_category_set_id,
                                    p_parameterlist     => l_genwf_cln_parameter_list);

        wf_event.AddParameterToList(p_name              => 'MAP_PARAMETER3',
                                    p_value             => p_category_id,
                                    p_parameterlist     => l_genwf_cln_parameter_list);

        wf_event.AddParameterToList(p_name              => 'MAP_PARAMETER4',
                                    p_value             => p_catalog_category_id,
                                    p_parameterlist     => l_genwf_cln_parameter_list);

        wf_event.AddParameterToList(p_name              => 'MAP_PARAMETER5',
                                    p_value             => p_item_status,
                                    p_parameterlist     => l_genwf_cln_parameter_list);

        wf_event.AddParameterToList(p_name              => 'MAP_PARAMETER6',
                                    p_value             => l_from_items,
                                    p_parameterlist     => l_genwf_cln_parameter_list);

        wf_event.AddParameterToList(p_name              => 'MAP_PARAMETER7',
                                    p_value             => l_to_items,
                                    p_parameterlist     => l_genwf_cln_parameter_list);

        wf_event.AddParameterToList(p_name              => 'ORG_ID',
                                    p_value             => p_inventory_org_id,
                                    p_parameterlist     => l_genwf_cln_parameter_list);

        wf_event.AddParameterToList(p_name              => 'DOCUMENT_CAREATION_DATE',
                                    p_value             => l_canonical_date,
                                    p_parameterlist     => l_genwf_cln_parameter_list);

        wf_event.AddParameterToList(p_name              => 'VALIDATION_REQUIRED_YN',
                                    p_value             => 'N',
                                    p_parameterlist     => l_genwf_cln_parameter_list);

        wf_event.AddParameterToList(p_name              => 'CH_MESSAGE_BEFORE_GENERATE_XML',
                                    p_value             => 'CLN_CH_COLLABORATION_CREATED',
                                    p_parameterlist     => l_genwf_cln_parameter_list);

        wf_event.AddParameterToList(p_name              => 'CH_MESSAGE_AFTER_XML_SENT',
                                    p_value             => 'CLN_SYNC_ITEM_XML_SENT',
                                    p_parameterlist     => l_genwf_cln_parameter_list);

        wf_event.AddParameterToList(p_name              => 'COLLABORATION_STATUS_SET',
                                    p_value             => 'Y',
                                    p_parameterlist     => l_genwf_cln_parameter_list);

        wf_event.AddParameterToList(p_name              => 'CH_MESSAGE_NO_TP_SETUP',
                                    p_value             => 'CLN_CH_TP_SETUP_NOTFOUND',
                                    p_parameterlist     => l_genwf_cln_parameter_list);



        IF(p_numitems_per_payload IS NULL ) THEN
            IF (l_Debug_Level <= 1) THEN
                  cln_debug_pub.Add('Workflow event- oracle.apps.cln.common.xml.out', 1);
            END IF;


            -- create unique key
            SELECT CLN_SYNCITEM_S.nextval into l_syncitem_seq from dual;
            l_event_key := to_char(p_tp_header_id) || '.' || to_char(l_syncitem_seq);

            IF (l_Debug_Level <= 1) THEN
                   cln_debug_pub.Add('Event Key  set as                   - '||l_event_key,1);
            END IF;

            wf_event.AddParameterToList(p_name              => 'ECX_DOCUMENT_ID',
                                        p_value             => l_event_key,
                                        p_parameterlist     => l_genwf_cln_parameter_list);

            wf_event.AddParameterToList(p_name              => 'XML_EVENT_KEY',
                                        p_value             => l_event_key,
                                        p_parameterlist     => l_genwf_cln_parameter_list);

            wf_event.AddParameterToList(p_name              => 'DOCUMENT_NO',
                                        p_value             => l_event_key,
                                        p_parameterlist     => l_genwf_cln_parameter_list);

            IF (l_Debug_Level <= 1) THEN
                  cln_debug_pub.Add('raising event as -  oracle.apps.cln.common.xml.out',1);
            END IF;

            -- raise event for send show shipment document
            wf_event.raise(p_event_name => 'oracle.apps.cln.common.xml.out',
                           p_event_key  => l_event_key,
                           p_parameters => l_genwf_cln_parameter_list);



        ELSIF (p_numitems_per_payload >= 1) THEN

            -- open cursor for all the documents that will be sent
            OPEN c_ItemsToSend (p_inventory_org_id,
                                p_category_set_id,
                                p_category_id,
                                p_catalog_category_id,
                                p_item_status,
                                l_from_items,
                                l_to_items );

            LOOP -- begin of xml documents generation
                  l_counter     := 1; -- reset counter

                  IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Counter set as           - '||l_counter,1);
                  END IF;

                  -- extract first item
                  FETCH c_ItemsToSend INTO l_from_items;
                  EXIT WHEN c_ItemsToSend%NOTFOUND;

                  IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('start item of the message found as              - '||l_from_items,1);
                  END IF;

                  l_to_items    := l_from_items; -- jst incase this is the last item

                  WHILE l_counter < p_numitems_per_payload LOOP
                        FETCH c_ItemsToSend INTO l_to_items; -- extract last item number
                        EXIT WHEN c_ItemsToSend%NOTFOUND; -- if we reached the end, then just send out what's left

                        IF (l_Debug_Level <= 1) THEN
                              cln_debug_pub.Add('intermediatory end item of the message found as  - '||l_to_items,1);
                        END IF;

                        l_counter := l_counter + 1;

                        IF (l_Debug_Level <= 1) THEN
                              cln_debug_pub.Add('Counter value raised to       - '||l_counter,1);
                        END IF;
                  END LOOP;

                  IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('end item of the message found as                - '||l_to_items,1);
                  END IF;

                  -- create unique key
                  SELECT CLN_SYNCITEM_S.nextval INTO l_syncitem_seq FROM dual;
                  l_event_key := to_char(p_tp_header_id) || '.' || to_char(l_syncitem_seq);


                  IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Event Key  set as                   - '||l_event_key,1);
                  END IF;

                  -- setting the generic workflow parameters
                  wf_event.AddParameterToList(p_name              => 'MAP_PARAMETER6',
                                              p_value             => l_from_items,
                                              p_parameterlist     => l_genwf_cln_parameter_list);

                  wf_event.AddParameterToList(p_name              => 'MAP_PARAMETER7',
                                              p_value             => l_to_items,
                                              p_parameterlist     => l_genwf_cln_parameter_list);

                  wf_event.AddParameterToList(p_name              => 'ECX_DOCUMENT_ID',
                                              p_value             => l_event_key,
                                              p_parameterlist     => l_genwf_cln_parameter_list);

                  wf_event.AddParameterToList(p_name              => 'XML_EVENT_KEY',
                                              p_value             => l_event_key,
                                              p_parameterlist     => l_genwf_cln_parameter_list);

                  wf_event.AddParameterToList(p_name              => 'DOCUMENT_NO',
                                              p_value             => l_event_key,
                                              p_parameterlist     => l_genwf_cln_parameter_list);

                  IF (l_Debug_Level <= 1) THEN
                         cln_debug_pub.Add('raising event as -  oracle.apps.cln.common.xml.out',1);
                  END IF;

                  -- raise event for send show shipment document
                  wf_event.raise(p_event_name => 'oracle.apps.cln.common.xml.out',
                                 p_event_key  => l_event_key,
                                 p_parameters => l_genwf_cln_parameter_list);

                  IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('....Event Raised...',1);
                  END IF;
            END LOOP;

            CLOSE c_ItemsToSend;
        END IF;


        retcode  := 0;
        errbuf   := 'Successful';

        -- check the error message
        IF (l_Debug_Level <= 1) THEN
              cln_debug_pub.Add(l_msg_data,1);
        END IF;

        IF (l_Debug_Level <= 2) THEN
              cln_debug_pub.Add('------- Exiting Raise_Syncitem_Event API --------- ',2);
        END IF;

 -- Exception Handling
 EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
             retcode          := 2 ;
             errbuf           := l_msg_data;
             IF (l_Debug_Level <= 5) THEN
                     cln_debug_pub.Add(l_msg_data,4);
                     cln_debug_pub.Add('------- Exiting Raise_Syncitem_Event API with error --------- ',2);
             END IF;


        WHEN OTHERS THEN
             l_error_code       :=SQLCODE;
             l_error_msg        :=SQLERRM;
             retcode          :=2 ;
             FND_MESSAGE.SET_NAME('CLN','CLN_CH_UNEXPECTED_ERROR');
             FND_MESSAGE.SET_TOKEN('ERRORCODE',l_error_code);
             FND_MESSAGE.SET_TOKEN('ERRORMSG',l_error_msg);
             l_msg_data         :='Unexpected Error  -'||l_error_code||' : '||l_error_msg;
             errbuf           := l_msg_data;
             IF (l_Debug_Level <= 5) THEN
                     cln_debug_pub.Add(l_msg_data,6);
                     cln_debug_pub.Add('------- Exiting Raise_Syncitem_Event API with an unexpected error --------- ',2);
             END IF;


 END Raise_Syncitem_Event;


   -- Name
   --      SEND_SYNCITEM_DELETE
   -- Purpose
   --    This procedure is called from the 2A12 Workflow.
   --    This procedure checks for the Trading Partner setup. Also, sets the WF Item
   --    attributes and raises the Sync Item event.
   --
   -- Arguments
   --
   -- Notes
   --    No specific notes.

   PROCEDURE Send_Syncitem_Delete(itemtype        in            varchar2,
                                    itemkey       in            varchar2,
                                    actid         in            number,
                                    funcmode      in            varchar2,
                                    resultout     in out NOCOPY varchar2) IS
   l_debug_level                 NUMBER;

   x_progress                    VARCHAR2(100);
   transaction_type              varchar2(240);
   transaction_subtype           varchar2(240);
   document_direction            varchar2(240);
   message_text                  varchar2(240);
   party_id                      number;
   party_site_id                 number;
   party_type                    varchar2(30);
   return_code                   pls_integer;
   errmsg                        varchar2(2000);
   result                        boolean;
   l_error_code                  NUMBER;
   l_error_msg                   VARCHAR2(1000);

   -- parameters for create collaboration date
   l_date                        DATE;
   l_canonical_date              VARCHAR2(100);

   -- parameters for raising event
   l_send_shsp_event             VARCHAR2(100);
   l_create_cln_event            VARCHAR2(100);
   l_event_key                   VARCHAR2(100);
   l_syncitem_seq                NUMBER;
   l_send_syit_parameter_list    wf_parameter_list_t;
   l_create_cln_parameter_list   wf_parameter_list_t;
   l_organization_id             NUMBER;
   l_tp_header_id                NUMBER;
   p_inventory_item_id           NUMBER;
   p_org_id                      NUMBER;

   -- cursor to hold the list of trading partners to send to
   CURSOR c_TradingPartners IS
        select eth.tp_header_id
      from ecx_tp_headers eth, ecx_tp_details etd, ecx_ext_processes eep,
        ecx_transactions et, hz_parties hp, hz_party_sites hps, hz_locations hl
      where eth.tp_header_id = etd.tp_header_id
      and etd.EXT_PROCESS_ID = eep.EXT_PROCESS_ID and eth.party_id = hp.party_id
        and eth.party_site_id = hps.party_site_id and hps.location_id = hl.location_id
        and eep.transaction_id = et.transaction_id and et.transaction_type = 'CLN'
        and et.transaction_subtype = 'SYNCITEMDELO' and eep.direction = 'OUT';

   BEGIN
      l_debug_level := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));

      x_progress                    := '000';
      transaction_type                := 'CLN';
      transaction_subtype           := 'SYNCITEMDELO';
      document_direction            := 'OUT';
      message_text                  := 'CLN_SYIT_MESSAGE_SENT';
      party_type                    := 'C';
      result                        := FALSE;
      l_send_shsp_event             := 'oracle.apps.cln.event.syncitem';
      l_create_cln_event            := 'oracle.apps.cln.ch.collaboration.create';
      l_send_syit_parameter_list    := wf_parameter_list_t();
      l_create_cln_parameter_list   := wf_parameter_list_t();

      x_progress := 'CLN_SYNCITEM_PKG.Send_Syncitem_Delete : Entered Procedure';
      if (l_debug_level <= 1) then
         cln_debug_pub.Add('Failure point ' || x_progress, 1);
      end if;

      -- get organization ID
      select FND_PROFILE.VALUE('ORG_ID')
      into l_organization_id
      from dual;

      -- Retrieve Activity Attributes
      p_inventory_item_id := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'INVENTORY_ITEM_ID');
      p_org_id := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'ORGANIZATION_ID');
      l_organization_id := p_org_id;

        OPEN c_TradingPartners; -- open cursor

        LOOP
         -- get next trading partner
           FETCH c_TradingPartners INTO l_tp_header_id;

         -- if no trading partner, then finished.
           EXIT WHEN c_TradingPartners%NOTFOUND;

         -- get parameters for that particular trading partner
         select eth.party_id, eth.party_site_id
         into party_id, party_site_id
         from ecx_tp_headers eth
         where eth.tp_header_id = l_tp_header_id;

         x_progress := 'CLN_SYNCITEM_PKG.Send_Syncitem_Delete : Initialized procedure parameters';
         if (l_debug_level <= 1) then
            cln_debug_pub.Add('Failure point ' || x_progress, 1);
         end if;

         -- XML Setup Check
         ecx_document.isDeliveryRequired(
         transaction_type       => transaction_type,
         transaction_subtype    => transaction_subtype,
         party_id                     => party_id,
         party_site_id          => party_site_id,
         resultout              => result,
         retcode                        => return_code,
         errmsg                 => errmsg);

         x_progress := 'CLN_SYNCITEM_PKG.Send_Syncitem_Delete : XML Setup Check Done';
         if (l_debug_level <= 1) then
            cln_debug_pub.Add('Failure point ' || x_progress, 1);
         end if;

         -- Decision on action depending on XML Setup Check
           if NOT(result) then -- XML not setup

            x_progress := 'CLN_SYNCITEM_PKG.Send_Syncitem_Delete : XML Setup does not exist';
            if (l_debug_level <= 1) then
               cln_debug_pub.Add('Failure point ' || x_progress, 1);
            end if;
         else
            x_progress := 'CLN_SYNCITEM_PKG.Send_Syncitem_Delete : XML Setup exists';
            if (l_debug_level <= 1) then
               cln_debug_pub.Add('Failure point ' || x_progress, 1);
            end if;

            -- create unique key
            SELECT CLN_SYNCITEM_S.nextval into l_syncitem_seq from dual;
            l_event_key := to_char(l_tp_header_id) || '.' || to_char(l_syncitem_seq);

            SELECT sysdate into l_date from dual;
            l_canonical_date := FND_DATE.DATE_TO_CANONICAL(l_date);

            x_progress := 'CLN_SYNCITEM_PKG.Send_Syncitem_Delete : Unique key created';
            if (l_debug_level <= 1) then
               cln_debug_pub.Add('Failure point ' || x_progress, 1);
            end if;

            -- add parameters to list for create collaboration event
            wf_event.AddParameterToList(p_name => 'XMLG_INTERNAL_TXN_TYPE',
                                        p_value => transaction_type,
                                        p_parameterlist => l_create_cln_parameter_list);
            wf_event.AddParameterToList(p_name => 'XMLG_INTERNAL_TXN_SUBTYPE',
                                        p_value => transaction_subtype,
                                        p_parameterlist => l_create_cln_parameter_list);
            wf_event.AddParameterToList(p_name => 'DOCUMENT_DIRECTION',
                                        p_value => document_direction,
                                        p_parameterlist => l_create_cln_parameter_list);
            wf_event.AddParameterToList(p_name => 'XMLG_DOCUMENT_ID',
                                        p_value => l_event_key,
                                        p_parameterlist => l_create_cln_parameter_list);
            wf_event.AddParameterToList(p_name => 'TRADING_PARTNER_ID',
                                        p_value => party_id,
                                        p_parameterlist => l_create_cln_parameter_list);
            wf_event.AddParameterToList(p_name => 'TRADING_PARTNER_SITE',
                                        p_value => party_site_id,
                                        p_parameterlist => l_create_cln_parameter_list);
            wf_event.AddParameterToList(p_name => 'TRADING_PARTNER_TYPE',
                                        p_value => party_type,
                                        p_parameterlist => l_create_cln_parameter_list);
            wf_event.AddParameterToList(p_name => 'DOCUMENT_NO',
                                        p_value => l_event_key,
                                        p_parameterlist => l_create_cln_parameter_list);
            wf_event.AddParameterToList(p_name => 'ORG_ID',
                                        p_value => l_organization_id,
                                        p_parameterlist => l_create_cln_parameter_list);
            wf_event.AddParameterToList(p_name => 'DOCUMENT_CREATION_DATE',
                                        p_value => l_canonical_date,
                                        p_parameterlist => l_create_cln_parameter_list);

            x_progress := 'CLN_SYNCITEM_PKG.Send_Syncitem_Delete : Create Event Parameters Setup';
            if (l_debug_level <= 1) then
                cln_debug_pub.Add('Failure point ' || x_progress, 1);
            end if;

            -- raise create collaboration event
            wf_event.raise(p_event_name => l_create_cln_event,
                           p_event_key  => l_event_key,
                           p_parameters => l_create_cln_parameter_list);

            x_progress := 'CLN_SYNCITEM_PKG.Send_Syncitem_Delete : Create Event Raised';
            if (l_debug_level <= 1) then
               cln_debug_pub.Add('Failure point ' || x_progress, 1);
            end if;

            -- add parameters to list for send sync item document
            wf_event.AddParameterToList(p_name => 'ECX_TRANSACTION_TYPE',
                                        p_value => transaction_type,
                                        p_parameterlist => l_send_syit_parameter_list);
            wf_event.AddParameterToList(p_name => 'ECX_TRANSACTION_SUBTYPE',
                                        p_value => transaction_subtype,
                                        p_parameterlist => l_send_syit_parameter_list);
            wf_event.AddParameterToList(p_name => 'XMLG_INTERNAL_TXN_TYPE',
                                        p_value => transaction_type,
                                        p_parameterlist => l_send_syit_parameter_list);
            wf_event.AddParameterToList(p_name => 'XMLG_INTERNAL_TXN_SUBTYPE',
                                        p_value => transaction_subtype,
                                        p_parameterlist => l_send_syit_parameter_list);
            wf_event.AddParameterToList(p_name => 'DOCUMENT_DIRECTION',
                                        p_value => document_direction,
                                        p_parameterlist => l_send_syit_parameter_list);
            wf_event.AddParameterToList(p_name => 'ECX_PARTY_ID',
                                        p_value => party_id,
                                        p_parameterlist => l_send_syit_parameter_list);
            wf_event.AddParameterToList(p_name => 'ECX_PARTY_SITE_ID',
                                        p_value => party_site_id,
                                        p_parameterlist => l_send_syit_parameter_list);
            wf_event.AddParameterToList(p_name => 'ECX_PARTY_TYPE',
                                        p_value => party_type,
                                        p_parameterlist => l_send_syit_parameter_list);
            wf_event.AddParameterToList(p_name => 'TRADING_PARTNER_ID',
                                        p_value => party_id,
                                        p_parameterlist => l_send_syit_parameter_list);
            wf_event.AddParameterToList(p_name => 'TRADING_PARTNER_SITE',
                                        p_value => party_site_id,
                                        p_parameterlist => l_send_syit_parameter_list);
            wf_event.AddParameterToList(p_name => 'TRADING_PARTNER_TYPE',
                                        p_value => party_type,
                                        p_parameterlist => l_send_syit_parameter_list);
            wf_event.AddParameterToList(p_name => 'ECX_DOCUMENT_ID',
                                        p_value => l_event_key,
                                        p_parameterlist => l_send_syit_parameter_list);
            wf_event.AddParameterToList(p_name => 'XMLG_DOCUMENT_ID',
                                        p_value => l_event_key,
                                        p_parameterlist => l_send_syit_parameter_list);
            wf_event.AddParameterToList(p_name => 'DOCUMENT_NO',
                                        p_value => l_event_key,
                                        p_parameterlist => l_send_syit_parameter_list);
            wf_event.AddParameterToList(p_name => 'MESSAGE_TEXT',
                                        p_value => message_text,
                                        p_parameterlist => l_send_syit_parameter_list);
            wf_event.AddParameterToList(p_name => 'ORG_ID',
                                        p_value => l_organization_id,
                                        p_parameterlist => l_send_syit_parameter_list);
            wf_event.AddParameterToList(p_name => 'ECX_PARAMETER1',
                                        p_value => NULL,
                                        p_parameterlist => l_send_syit_parameter_list);
            wf_event.AddParameterToList(p_name => 'ECX_PARAMETER2',
                                        p_value => NULL,
                                        p_parameterlist => l_send_syit_parameter_list);
            wf_event.AddParameterToList(p_name => 'ECX_PARAMETER3',
                                        p_value => NULL,
                                        p_parameterlist => l_send_syit_parameter_list);
            wf_event.AddParameterToList(p_name => 'ECX_PARAMETER4',
                                        p_value => NULL,
                                        p_parameterlist => l_send_syit_parameter_list);
            wf_event.AddParameterToList(p_name => 'ECX_PARAMETER5',
                                        p_value => NULL,
                                        p_parameterlist => l_send_syit_parameter_list);
            wf_event.AddParameterToList(p_name => 'INVENTORY_ITEM_ID', -- may possibly need this
                                        p_value => p_inventory_item_id,
                                        p_parameterlist => l_send_syit_parameter_list);
            wf_event.AddParameterToList(p_name => 'ORGANIZATION_ID',
                                        p_value => p_org_id,
                                        p_parameterlist => l_send_syit_parameter_list);
            wf_event.AddParameterToList(p_name => 'DOCUMENT_CREATION_DATE',
                                        p_value => l_canonical_date,
                                        p_parameterlist => l_send_syit_parameter_list);

            x_progress := 'CLN_SYNCITEM_PKG.Send_Syncitem_Delete : Initialize Send Document Parameters';
            if (l_debug_level <= 1) then
               cln_debug_pub.Add('Failure point ' || x_progress, 1);
            end if;

            -- raise event for send show shipment document
            wf_event.raise(p_event_name => l_send_shsp_event,
                           p_event_key  => l_event_key,
                           p_parameters => l_send_syit_parameter_list);

            x_progress := 'CLN_SYNCITEM_PKG.Send_Syncitem_Delete : Send Document Event Raised';
            if (l_debug_level <= 1) then
               cln_debug_pub.Add('Failure point ' || x_progress, 1);
            end if;
         end if;

      END LOOP;

      -- close cursor when done
      CLOSE c_TradingPartners;

      -- Reached Here. Successful execution.
      x_progress := 'CLN_SYNCITEM_PKG.Send_Syncitem_Delete : Exiting Procedure';
      if (l_debug_level <= 1) then
         cln_debug_pub.Add('Failure point ' || x_progress, 1);
      end if;

      resultout := 'COMPLETE:T';
   EXCEPTION
      WHEN OTHERS THEN
         l_error_code := SQLCODE;
         l_error_msg  := SQLERRM;
         if (l_debug_level <= 1) then
            cln_debug_pub.Add('Exception ' || ':'  || l_error_code || ':' || l_error_msg, 1);
         end if;

         x_progress := 'CLN_SYNCITEM_PKG.Send_Syncitem_Delete : ERROR';
         if (l_debug_level <= 1) then
            cln_debug_pub.Add('Failure point ' || x_progress, 1);
         end if;
   END Send_Syncitem_Delete;


  -- Name
  --      ARCHIVE_DELETED_ITEMS
  -- Purpose
  --    This procedure is called from the 2A12 Workflow.
  --    This procedure archives the deleted items into 'cln_itemmst_deleted_items' table.
  --
  -- Arguments
  --
  -- Notes
  --    No specific notes.

   PROCEDURE Archive_Deleted_Items(itemtype       in            varchar2,
                                    itemkey       in            varchar2,
                                    actid         in            number,
                                    funcmode      in            varchar2,
                                    resultout     in out NOCOPY varchar2) IS
   l_debug_level                 NUMBER;

   x_progress                    VARCHAR2(100);
   l_error_code                  NUMBER;
   l_error_msg                   VARCHAR2(1000);
   p_inventory_item_id           NUMBER:= Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'INVENTORY_ITEM_ID');
   p_org_id                      NUMBER:= Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'ORGANIZATION_ID');
   p_concatenated_segments       VARCHAR2(50);
   p_item_type                   VARCHAR2(30);
   p_primary_uom_code            VARCHAR2(3);
   p_customer_item_number        VARCHAR2(50);

   --cursor to hold all the associated records of the deleted item.
   CURSOR  c_DeletedItems
   IS
   SELECT distinct msib.concatenated_segments, msib.item_type, msib.primary_uom_code, mci.customer_item_number
   FROM mtl_system_items_b_kfv msib, mtl_system_items_tl msit, mtl_customer_item_xrefs mcix, mtl_customer_items mci,
        mtl_item_revisions mir, mtl_item_catalog_groups_kfv micgk, po_hazard_classes_tl phct
        WHERE msib.inventory_item_id = msit.inventory_item_id(+) and msib.inventory_item_id = mcix.inventory_item_id(+)
            and mcix.customer_item_id = mci.customer_item_id(+) and msib.inventory_item_id = mir.inventory_item_id(+)
            and msit.organization_id = msib.organization_id and mir.organization_id = msib.organization_id
            and msib.service_item_flag = 'N' and msib.inventory_item_flag = 'Y'
            and msib.item_catalog_group_id = micgk.item_catalog_group_id(+) and msib.hazard_class_id = phct.hazard_class_id(+)
            and msib.inventory_item_id = p_inventory_item_id and msib.organization_id = p_org_id;

   BEGIN


      resultout := 'COMPLETE:T';
      l_debug_level := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));
      x_progress := 'CLN_SYNCITEM_PKG.Archive_Deleted_Items : Entered Procedure';
      if (l_debug_level <= 1) then
         cln_debug_pub.Add('Failure point ' || x_progress, 1);
      end if;



      FOR del_rec in c_DeletedItems LOOP

        --table to hold the records of the deleted item, index being (inventory_item_id, customer_item_number)
        INSERT INTO cln_itemmst_deleted_items
         (inventory_item_id, organization_id, concatenated_segments, item_type, primary_uom_code, customer_item_number)
        VALUES
         (p_inventory_item_id, p_org_id, del_rec.concatenated_segments, del_rec.item_type, del_rec.primary_uom_code, del_rec.customer_item_number);

      END LOOP;


         -- Reached Here. Successful execution.
      x_progress := 'CLN_SYNCITEM_PKG.Archive_Deleted_Items : Exiting Procedure';
      if (l_debug_level <= 1) then
          cln_debug_pub.Add('Failure point ' || x_progress, 1);
      end if;

      EXCEPTION

         WHEN OTHERS THEN
            l_error_code := SQLCODE;
            l_error_msg  := SQLERRM;
            if (l_debug_level <= 1) then
                cln_debug_pub.Add('Exception ' || ':'  || l_error_code || ':' || l_error_msg, 1);
            end if;

            x_progress := 'CLN_SYNCITEM_PKG.Archive_Deleted_Items : ERROR';
            if (l_debug_level <= 1) then
                cln_debug_pub.Add('Failure point ' || x_progress, 1);
            end if;
          resultout := 'COMPLETE:F';
   END Archive_Deleted_Items;


  -- Name
  --      DELETE_ARCHIVED_ITEMS
  -- Purpose
  --    This procedure is called from the 2A12 Workflow.
  --    This procedure deletes the archived items from the 'cln_itemmst_deleted_items'.
  --
  -- Arguments
  --
  -- Notes
  --    Commented the code for fixing bug 3875383

   PROCEDURE Delete_Archived_Items(itemtype       in            varchar2,
                                    itemkey       in            varchar2,
                                    actid         in            number,
                                    funcmode      in            varchar2,
                                    resultout     in out NOCOPY varchar2) IS
   l_debug_level                 NUMBER;

   x_progress                    VARCHAR2(100);
   l_error_code                  NUMBER;
   l_error_msg                   VARCHAR2(1000);
   p_inventory_item_id           NUMBER;
   p_org_id                      NUMBER;

   BEGIN
      /* Commented the code for deletion for fixing bug 3875383*/
      /******
      l_debug_level := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));
      x_progress := 'CLN_SYNCITEM_PKG.Delete_Archived_Items : Entered Procedure';
      if (l_debug_level <= 1) then
         cln_debug_pub.Add('Failure point ' || x_progress, 1);
      end if;

      -- Retrieve Activity Attributes
      p_inventory_item_id := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'INVENTORY_ITEM_ID');
      p_org_id := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'ORGANIZATION_ID');

      DELETE FROM cln_itemmst_deleted_items
      WHERE inventory_item_id = p_inventory_item_id AND organization_id = p_org_id;

      -- Reached Here. Successful execution.
      x_progress := 'CLN_SYNCITEM_PKG.Delete_Archived_Items : Exiting Procedure';
      if (l_debug_level <= 1) then
         cln_debug_pub.Add('Failure point ' || x_progress, 1);
      end if;
      ******/
      resultout := 'COMPLETE:T';
   EXCEPTION
      WHEN OTHERS THEN
         l_error_code := SQLCODE;
         l_error_msg  := SQLERRM;
         if (l_debug_level <= 1) then
            cln_debug_pub.Add('Exception ' || ':'  || l_error_code || ':' || l_error_msg, 1);
         end if;

         x_progress := 'CLN_SYNCITEM_PKG.Delete_Archived_Items : ERROR';
         if (l_debug_level <= 1) then
            cln_debug_pub.Add('Failure point ' || x_progress, 1);
         end if;
   END Delete_Archived_Items;

END CLN_SYNCITEM_PKG;

/
