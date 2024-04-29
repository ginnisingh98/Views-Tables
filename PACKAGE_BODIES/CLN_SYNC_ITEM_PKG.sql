--------------------------------------------------------
--  DDL for Package Body CLN_SYNC_ITEM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CLN_SYNC_ITEM_PKG" AS
/* $Header: CLNSYNIB.pls 120.1 2005/10/27 06:05:20 kkram noship $ */
   l_debug_level        NUMBER := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));

--  Package
--      CLN_SYNC_ITEM_PKG
--
--  Purpose
--      Body of package CLN_SYNC_ITEM_PKG.
--
--  History
--      July-21-2003        Rahul Krishan         Created


   -- Name
   --    SET_SAVEPOINT_SYNC_RN
   -- Purpose
   --    This procedure sets the savepoint for deletion event.
   --    Incase we find the item status as obselete while processing, we rollback to this point
   --
   -- Arguments
   --
   -- Notes
   --    No specific notes.

   PROCEDURE SET_SAVEPOINT_SYNC_RN
   IS
                l_error_code                            NUMBER;
                l_error_msg                             VARCHAR2(255);
                l_msg_data                              VARCHAR2(255);

   BEGIN
         IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('----- Entering SET_SAVEPOINT_SYNC_RN API ------- ',2);
         END IF;

         -- Standard Start of API savepoint
	 SAVEPOINT   CHECK_ITEM_DELETION_PUB;

         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('++++++++ SAVEPOINT SET ++++++++ ',1);
         END IF;

         IF (l_Debug_Level <= 2) THEN
              cln_debug_pub.Add('------- Exiting SET_SAVEPOINT_SYNC_RN API --------- ',2);
         END IF;

   -- Exception Handling
   EXCEPTION
        WHEN OTHERS THEN
             l_error_code       :=SQLCODE;
             l_error_msg        :=SQLERRM;
             l_msg_data         :='Unexpected Error  -'||l_error_code||' : '||l_error_msg;

             IF (l_Debug_Level <= 5) THEN
                     cln_debug_pub.Add(l_msg_data,6);
                     cln_debug_pub.Add('------- Exiting SET_SAVEPOINT_SYNC_RN API with an unexpected error --------- ',2);
             END IF;
   END SET_SAVEPOINT_SYNC_RN;


   -- Name
   --    CATEGRY_RESOL_RN
   -- Purpose
   --    This procedure takes an input of concatenated string of category name and
   --    category set name delimited by '|'.
   --    The input would be of the form 'CATNAME=xxxxxx|CATSETNAME=xxxxxxxxx'
   --    The output parameters individually carry the category name and category set name
   --    This procedure is called from the inbound XGM
   -- Arguments
   --
   -- Notes
   --    No specific notes.

   PROCEDURE Catgry_Resol_RN(
                p_concatgset            IN              VARCHAR2,
                x_insert                IN  OUT NOCOPY  VARCHAR2,
                x_catgry                OUT NOCOPY      VARCHAR2,
                x_catsetname            OUT NOCOPY      VARCHAR2 )
   IS
                l_error_code                            NUMBER;
                l_error_msg                             VARCHAR2(255);
                l_msg_data                              VARCHAR2(255);

   BEGIN
         -- Example is p_concatgset = CATNAME=208.460.463|CATSETNAME=Sales and Marketing
         IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('----- Entering Catgry_Resol_RN API ------- ',2);
         END IF;

         x_insert := 'TRUE';

         -- Parameters received
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('============= PARAMETER RECEIVED ================ ',1);
                 cln_debug_pub.Add('Category Name and Category Set Name    - '||p_concatgset,1);
                 cln_debug_pub.Add('=================================================',1);
         END IF;

         IF (p_concatgset IS NULL) OR (TRIM(p_concatgset) ='') THEN
                 IF (l_Debug_Level <= 1) THEN
                         cln_debug_pub.Add('Category Name and Category Set Name value is null',1);
                 END IF;
                 x_insert := 'FALSE';
         END IF;

         -- Getting the Category Name
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('Getting the Category Name',1);
         END IF;


         SELECT SUBSTR(p_concatgset, INSTR(p_concatgset,'=', 1, 1)+1,INSTR(p_concatgset,'|',1,1)-INSTR(p_concatgset,'=',1,1)-1)
         INTO x_catgry
         FROM dual;

         -- Category Name
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('Category Name  - '||x_catgry,1);
         END IF;

         -- Getting the Category Set Name
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('Getting the Category Set Name',1);
         END IF;

         SELECT SUBSTR(p_concatgset, INSTR(p_concatgset,'=', 1, 2)+1)
         INTO x_catsetname
         FROM dual;


         -- Category Set Name
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('Category Set Name  - '||x_catsetname,1);
         END IF;

         IF (l_Debug_Level <= 2) THEN
              cln_debug_pub.Add('------- Exiting Catgry_Resol_RN API --------- ',2);
         END IF;

   -- Exception Handling
   EXCEPTION
        WHEN OTHERS THEN
             l_error_code       :=SQLCODE;
             l_error_msg        :=SQLERRM;
             l_msg_data         :='Unexpected Error  -'||l_error_code||' : '||l_error_msg;
             x_insert           := 'FALSE';

             IF (l_Debug_Level <= 5) THEN
                     cln_debug_pub.Add(l_msg_data,6);
                     cln_debug_pub.Add('------- Exiting Catgry_Resol_RN API with an unexpected error --------- ',2);
             END IF;
   END Catgry_Resol_RN;


   -- Name
   --    RAISE_UPDATE_EVENT
   -- Purpose
   --    This is the public procedure which raises an event to update collaboration passing the
   --    parameters so obtained. This procedure is called from the root of XGM map
   --
   -- Arguments
   --
   -- Notes
   --    No specific notes.

   PROCEDURE RAISE_UPDATE_EVENT(
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_internal_control_number      IN NUMBER,
         p_sender_header_id             IN NUMBER,
         p_receiver_header_id           IN NUMBER,
         x_supplier_name                OUT NOCOPY VARCHAR2,
         x_master_organization_id       OUT NOCOPY NUMBER,
         x_set_process_id               OUT NOCOPY NUMBER,
         x_cost_group_id                OUT NOCOPY NUMBER)

   IS
         l_cln_ch_parameters            wf_parameter_list_t;
         l_event_key                    NUMBER;
         l_error_code                   NUMBER;
         l_party_id                     NUMBER;
         l_party_site_id                NUMBER;
         l_organization_id              NUMBER;
         l_master_organization_id       NUMBER;
         l_document_number              VARCHAR2(255);
         l_buyer_organization           VARCHAR2(255);
         l_msg_data                     VARCHAR2(255);
         l_supplier_name                VARCHAR2(255);
         l_error_msg                    VARCHAR2(2000);
         l_syncitem_seq                 NUMBER;

   BEGIN

         IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('***************************************************', 2);
                cln_debug_pub.Add('---------------- ENTERING XGM MAP -----------------', 2);
                cln_debug_pub.Add('***************************************************', 2);

                cln_debug_pub.Add('-------- ENTERING RAISE_UPDATE_EVENT --------------', 2);
         END IF;

         -- Standard Start of API savepoint
         SAVEPOINT   CHECK_COLLABORATION_PUB;

         --  Initialize API return status to success
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         l_msg_data      := 'XML Gateway successfully consumes SYNC ITEM inbound document';

         FND_MESSAGE.SET_NAME('CLN','CLN_CH_SYNC_ITEMS_CONSUMED');
         x_msg_data      := FND_MESSAGE.GET;

         -- get a unique key for set process id based on which the concurrent program will
         -- select the rows from the interface table and import them
         -- If the inventory folks come up with sequence..we haveto replace this
         SELECT  cln_generic_s.nextval INTO x_set_process_id FROM dual;

         -- get a unique value for the group id used in the costing interface tables.
         SELECT  cst_lists_s.nextval INTO x_cost_group_id FROM dual;


         IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('------------ PARAMETERS OBTAINED ----------', 1);
                cln_debug_pub.Add('Set Process ID              ---- '||x_set_process_id, 1);
                cln_debug_pub.Add('Group ID for costing        ---- '||x_cost_group_id, 1);
                cln_debug_pub.Add('Internal Control Number     ---- '||p_internal_control_number, 1);
                cln_debug_pub.Add('Sender Trading Partner ID   ---- '||p_sender_header_id, 1);
                cln_debug_pub.Add('Receiver Trading Partner ID ---- '||p_receiver_header_id, 1);
         END IF;

         IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('----------- SETTING DEFAULT VALUES ----------', 1);
         END IF;

         BEGIN
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('--------- FINDING DEFAULT ORGANIZATION--------', 1);
                END IF;

                SELECT PARTY_ID, PARTY_SITE_ID
                INTO l_party_id,l_party_site_id
                FROM ECX_TP_HEADERS
                WHERE TP_HEADER_ID = p_sender_header_id ;

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Party ID                 : '||l_party_id,1);
                        cln_debug_pub.Add('Party Site ID            : '||l_party_site_id,1);
                END IF;

                SELECT ORG_ID
                INTO l_organization_id
                FROM PO_VENDOR_SITES_ALL
                WHERE VENDOR_ID         = l_party_id
                AND VENDOR_SITE_ID      = l_party_site_id ;

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Organization ID          : '||l_organization_id,1);
                END IF;

                SELECT MASTER_ORGANIZATION_ID
                INTO l_master_organization_id
                FROM MTL_PARAMETERS
                WHERE ORGANIZATION_ID = l_organization_id ;

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Master Organization ID   : '||l_master_organization_id,1);
                END IF;
                x_master_organization_id := l_master_organization_id;

                SELECT NAME
                INTO l_buyer_organization
                FROM HR_ALL_ORGANIZATION_UNITS
                WHERE ORGANIZATION_ID = l_master_organization_id;

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Buyer Organization name  : '||l_buyer_organization,1);
                END IF;

                SELECT VENDOR_NAME
                INTO l_supplier_name
                FROM PO_VENDORS
                WHERE VENDOR_ID = l_party_id ;

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Supplier Name            : '||l_supplier_name,1);
                END IF;
                x_supplier_name  := l_supplier_name;


         EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_msg_data :='ERROR : Incorrect Trading Partner Details';
                    FND_MESSAGE.SET_NAME('CLN','CLN_CH_INCORRECT_TP_DETAILS');
                    x_msg_data := FND_MESSAGE.GET;
                    RAISE FND_API.G_EXC_ERROR;
         END;

         -- get a unique key for raising update collaboration event.
         SELECT  cln_generic_s.nextval INTO l_event_key FROM dual;

         l_cln_ch_parameters := wf_parameter_list_t();
         /* Bug: 3479100
         Desc : Document Number shuld be trading partner number.Running sequence Number

         l_document_number   := l_supplier_name||':'||l_buyer_organization||':'||to_char(sysdate,'YYYYMMDDHH:MM:SS');
         */
         SELECT CLN_SYNCITEM_S.nextval into l_syncitem_seq from dual;
         l_document_number := to_char(p_sender_header_id) || '.' || to_char(l_syncitem_seq);

         IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Document Number          : '||l_document_number, 1);
         END IF;

         IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('-------- SETTING EVENT PARAMETERS -----------', 1);
         END IF;

         WF_EVENT.AddParameterToList('DOCUMENT_STATUS', 'SUCCESS', l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('ORIGINATOR_REFERENCE', l_master_organization_id, l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('MESSAGE_TEXT', 'CLN_CH_SYNC_ITEMS_CONSUMED', l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('ROSETTANET_CHECK_REQUIRED','TRUE',l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('DOCUMENT_NO',l_document_number,l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('DOCUMENT_CREATION_DATE',to_char(SYSDATE,'YYYY-MM-DD HH24:MI:SS'),l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('XMLG_INTERNAL_CONTROL_NUMBER',p_internal_control_number,l_cln_ch_parameters);

         IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('-------- EVENT PARAMETERS SET-----------', 1);
                cln_debug_pub.Add('Workflow event- oracle.apps.cln.ch.collaboration.update', 1);
         END IF;

         WF_EVENT.Raise('oracle.apps.cln.ch.collaboration.update',l_event_key, NULL, l_cln_ch_parameters, NULL);


         IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add(l_msg_data,1);
         END IF;

         IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('----------- EXITING RAISE_UPDATE_EVENT ------------', 2);
         END IF;

   EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR ;

            IF (l_Debug_Level <= 4) THEN
                cln_debug_pub.Add(l_msg_data,4);
            END IF;

            IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('----------- ERROR:EXITING RAISE_UPDATE_EVENT ------------', 2);
            END IF;

         WHEN OTHERS THEN
            l_error_code      := SQLCODE;
            l_error_msg       := SQLERRM;
            x_return_status   := FND_API.G_RET_STS_UNEXP_ERROR ;
            l_msg_data        := l_error_code||' : '||l_error_msg;
            x_msg_data        := l_msg_data;
            IF (l_Debug_Level <= 6) THEN
                cln_debug_pub.Add(l_msg_data,6);
            END IF;

            IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('----------- ERROR:EXITING RAISE_UPDATE_EVENT ------------', 2);
            END IF;

   END RAISE_UPDATE_EVENT;


   -- Name
   --    RAISE_ADD_MSG_EVENT
   -- Purpose
   --    This is the public procedure which is used to raise an event that add messages into collaboration history passing
   --    these parameters so obtained.This procedure is called
   --    for each Item
   --
   -- Arguments
   --
   -- Notes
   --    No specific notes.

   PROCEDURE RAISE_ADD_MSG_EVENT(
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_sync_indicator               IN  VARCHAR2,
         p_supplier_name                IN  VARCHAR2,
         p_buyer_part_number            IN  VARCHAR2,
         p_supplier_part_number         IN  VARCHAR2,
         p_item_number                  IN  VARCHAR2,
         p_item_desc                    IN  VARCHAR2,
         p_item_revision                IN  VARCHAR2,
         p_organization_id              IN  NUMBER,
         p_new_revision_flag            IN  OUT NOCOPY VARCHAR2,
         p_new_deletion_flag            IN  OUT NOCOPY VARCHAR2,
         p_internal_control_number      IN  NUMBER,
         p_hazardous_class              IN  VARCHAR2,
         x_hazardous_id                 OUT NOCOPY NUMBER,
         x_notification_code            OUT NOCOPY VARCHAR2,
         x_inventory_item_id            OUT NOCOPY NUMBER )
   IS
         l_cln_ch_parameters            wf_parameter_list_t;
         l_event_key                    NUMBER;
         l_error_code                   NUMBER;
         l_inventory_item_id            NUMBER;
         l_count                        NUMBER;
         l_reference1                   VARCHAR2(50);
         l_error_msg                    VARCHAR2(255);
         l_msg_data                     VARCHAR2(255);
         l_dtl_msg                      VARCHAR2(255);

   BEGIN

         IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('-------- ENTERING RAISE_ADD_MSG_EVENT ------------', 2);
         END IF;

         --  Initialize API return status to success
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         l_msg_data     := 'Item Details recorded in the collaboration history';

         FND_MESSAGE.SET_NAME('CLN','CLN_CH_ITEM_DETAILS');
         x_msg_data := FND_MESSAGE.GET;

         -- get a unique key for raising add collaboration event.
         SELECT  cln_generic_s.nextval INTO l_event_key FROM dual;

         IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('----------- PARAMETERS OBTAINED ----------',1);
                cln_debug_pub.Add('Sync Indicator              ---- '||p_sync_indicator,1);
                cln_debug_pub.Add('Supplier name               ---- '||p_supplier_name,1);
                cln_debug_pub.Add('Buyer Part Number           ---- '||p_buyer_part_number,1);
                cln_debug_pub.Add('Supplier Part Number        ---- '||p_supplier_part_number,1);
                cln_debug_pub.Add('Item Number                 ---- '||p_item_number,1);
                cln_debug_pub.Add('Item Description            ---- '||p_item_desc,1);
                cln_debug_pub.Add('Item Revision               ---- '||p_item_revision,1);
                cln_debug_pub.Add('Revision Flag               ---- '||p_new_revision_flag,1);
                cln_debug_pub.Add('Deletion Flag               ---- '||p_new_deletion_flag,1);
                cln_debug_pub.Add('Organization Id             ---- '||p_organization_id,1);
                cln_debug_pub.Add('Hazard Class Description    ---- '||p_hazardous_class,1);
                cln_debug_pub.Add('Internal Control Number     ---- '||p_internal_control_number,1);
                cln_debug_pub.Add('------------------------------------------',1);
         END IF;

         -- defaulting the notification codes and status for success.
         IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('defaulting the notification codes and status for success.......',1);
         END IF;

         -- check for the Sync Indicator Flag
         IF (p_sync_indicator = 'Delete') THEN
                IF(p_new_deletion_flag = 'N')THEN
                        p_new_deletion_flag := 'Y';
                END IF;

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Item Marked For deletion : Item Number ='||p_item_number,1);
                END IF;

                FND_MESSAGE.SET_NAME('CLN','CLN_CH_ITEM_DELETION');
                FND_MESSAGE.SET_TOKEN('ITEMNUM',p_item_number);
                l_dtl_msg               := FND_MESSAGE.GET;

                l_reference1            := 'Sync Ind: Delete';
                x_notification_code     := 'SYN_ITM02';

                IF(p_new_revision_flag = 'Y')THEN
                     x_notification_code := 'SYN_ITM04';
                END IF;
         ELSIF (p_sync_indicator = 'A') THEN
                l_reference1  := 'Sync Ind:'||p_sync_indicator;
         ELSIF (p_sync_indicator = 'C') THEN
                l_reference1  := 'Sync Ind:'||p_sync_indicator;
         ELSE
                l_msg_data :='Unknown SYNC Indicator - '||p_sync_indicator;
                FND_MESSAGE.SET_NAME('CLN','CLN_CH_INCORRECT_SYNC_IND');
                FND_MESSAGE.SET_TOKEN('IND',p_sync_indicator);
                FND_MESSAGE.SET_TOKEN('SUPNAME',p_supplier_name);
                FND_MESSAGE.SET_TOKEN('ITEMNO',p_item_number);
                x_msg_data := FND_MESSAGE.GET;

                l_cln_ch_parameters := wf_parameter_list_t();

                IF (l_Debug_Level <= 1) THEN
                       cln_debug_pub.Add('---------- SETTING WORKFLOW PARAMETERS FOR INCORRECT SYNC IND---------', 1);
                END IF;

                WF_EVENT.AddParameterToList('REFERENCE_ID1','ERROR',l_cln_ch_parameters);
                WF_EVENT.AddParameterToList('REFERENCE_ID2','-',l_cln_ch_parameters);
                WF_EVENT.AddParameterToList('REFERENCE_ID3','-',l_cln_ch_parameters);
                WF_EVENT.AddParameterToList('DETAIL_MESSAGE',x_msg_data,l_cln_ch_parameters);
                WF_EVENT.AddParameterToList('DOCUMENT_TYPE', 'SYNC_ITEM', l_cln_ch_parameters);
                WF_EVENT.AddParameterToList('DOCUMENT_DIRECTION', 'IN', l_cln_ch_parameters);
                WF_EVENT.AddParameterToList('COLLABORATION_POINT', 'APPS', l_cln_ch_parameters);
                WF_EVENT.AddParameterToList('XMLG_INTERNAL_CONTROL_NUMBER',p_internal_control_number,l_cln_ch_parameters);

                IF (l_Debug_Level <= 1) THEN
                       cln_debug_pub.Add('----------------------------------------------', 1);
                       cln_debug_pub.Add('Workflow event- oracle.apps.cln.ch.collaboration.addmessage', 1);
                END IF;

                WF_EVENT.Raise('oracle.apps.cln.ch.collaboration.addmessage',l_event_key, NULL, l_cln_ch_parameters, NULL);

                RAISE  FND_API.G_EXC_ERROR;
         END IF;


         IF (p_sync_indicator <> 'Delete') THEN
                 -- check for new revision here only if the sync indicator is
                 -- not marked as delete .Set the revision flag here.
                BEGIN
                       IF (l_Debug_Level <= 1) THEN
                            cln_debug_pub.Add('check for new revision.....',1);
                       END IF;

                       SELECT DISTINCT inventory_item_id
                       INTO l_inventory_item_id
                       FROM mtl_system_items_kfv
                       WHERE concatenated_segments = p_item_number
                       AND   organization_id       = p_organization_id;

                       IF (l_Debug_Level <= 1) THEN
                            cln_debug_pub.Add('Inventory Item ID                 :'||l_inventory_item_id, 1);
                       END IF;

                       SELECT count(*)
                       INTO l_count
                       FROM mtl_item_revisions
                       WHERE inventory_item_id = l_inventory_item_id
                       AND organization_id     = p_organization_id
                       AND revision            = p_item_revision;

                       IF (l_Debug_Level <= 1) THEN
                            cln_debug_pub.Add('Number of matching Item revisions :'||l_count, 1);
                       END IF;

                       IF (l_count = 0) THEN -- need to check this
                               IF (l_Debug_Level <= 1) THEN
                                        cln_debug_pub.Add('Item with new Revision       : Item Number ='||p_item_number,1);
                               END IF;

                               FND_MESSAGE.SET_NAME('CLN','CLN_CH_NEW_ITEM_REVISION');
                               FND_MESSAGE.SET_TOKEN('ITEMNUM',p_item_number);
                               l_dtl_msg               := FND_MESSAGE.GET;

                               IF(p_new_revision_flag = 'N')THEN
                                     p_new_revision_flag := 'Y';

                                     x_notification_code := 'SYN_ITM03';

                                     IF(p_new_deletion_flag = 'Y')THEN
                                          x_notification_code := 'SYN_ITM04';
                                     END IF;

                               END IF;
                       END IF;

                EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                           IF (l_Debug_Level <= 1) THEN
                                cln_debug_pub.Add('Item consumed is a new Item : Item Number ='||p_item_number,1);
                           END IF;

                           -- default the value of inventory item id
                           x_inventory_item_id := NVL(l_inventory_item_id,0);
                END;

         END IF;

         IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('---------------------------------------------------',1);
                cln_debug_pub.Add('Notification Code          :'||x_notification_code,1);
                cln_debug_pub.Add('Reference 1                :'||l_reference1,1);
                cln_debug_pub.Add('Detail Message             :'||l_dtl_msg,1);
                cln_debug_pub.Add('---------------------------------------------------',1);
         END IF;


         -- checking for hazardous id from the hazardous description passed
         IF (p_hazardous_class IS NOT NULL) THEN
                BEGIN
                        IF (l_Debug_Level <= 1) THEN
                                cln_debug_pub.Add('Finding Hazard ID for the hazard class description',1);
                        END IF;

                        SELECT HAZARD_CLASS_ID
                        INTO x_hazardous_id
                        FROM PO_HAZARD_CLASSES_TL
                        WHERE HAZARD_CLASS= p_hazardous_class
                        AND LANGUAGE = USERENV('LANG');

                        IF (l_Debug_Level <= 1) THEN
                                cln_debug_pub.Add('Hazard ID      --'||x_hazardous_id,1);
                        END IF;

                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            IF (l_Debug_Level <= 1) THEN
                                cln_debug_pub.Add('Invalid Hazardous Description for the Item '||p_item_number,1);
                            END IF;
                            -- do we need to reject the whole lot for this simple validation failure ??
                END;
         END IF;

         l_cln_ch_parameters := wf_parameter_list_t();

         IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('---------- SETTING WORKFLOW PARAMETERS---------', 1);
         END IF;

         WF_EVENT.AddParameterToList('REFERENCE_ID1',l_reference1,l_cln_ch_parameters);
         --WF_EVENT.AddParameterToList('REFERENCE_ID2','Suplier:'||p_supplier_name,l_cln_ch_parameters);
         --WF_EVENT.AddParameterToList('REFERENCE_ID3','Buyer:'||p_buyer_part_number,l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('REFERENCE_ID2','Sup PartNo -'||p_supplier_part_number,l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('REFERENCE_ID3','ItemNo:'||p_item_number,l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('DETAIL_MESSAGE',l_dtl_msg,l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('DOCUMENT_TYPE', 'SYNC_ITEM', l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('DOCUMENT_DIRECTION', 'IN', l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('COLLABORATION_POINT', 'APPS', l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('XMLG_INTERNAL_CONTROL_NUMBER',p_internal_control_number,l_cln_ch_parameters);

         IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('----------------------------------------------', 1);
                cln_debug_pub.Add('Workflow event- oracle.apps.cln.ch.collaboration.addmessage', 1);
         END IF;

         WF_EVENT.Raise('oracle.apps.cln.ch.collaboration.addmessage',l_event_key, NULL, l_cln_ch_parameters, NULL);

         IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add(l_msg_data,1);
         END IF;

         IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('--------- EXITING RAISE_ADD_MSG_EVENT -------------', 2);
         END IF;

   EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;

            IF (l_Debug_Level <= 4) THEN
                cln_debug_pub.Add(l_msg_data,4);
            END IF;

            CLN_NP_PROCESSOR_PKG.NOTIFY_ADMINISTRATOR(x_msg_data);

            IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('----------- ERROR:EXITING RAISE_ADD_MSG_EVENT ------------', 2);
            END IF;

         WHEN OTHERS THEN
            l_error_code      := SQLCODE;
            l_error_msg       := SQLERRM;
            x_return_status   := FND_API.G_RET_STS_UNEXP_ERROR ;
            l_msg_data        := l_error_code||' : '||l_error_msg;
            x_msg_data        := l_msg_data;
            IF (l_Debug_Level <= 6) THEN
                cln_debug_pub.Add(l_msg_data,6);
            END IF;

            IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('----------- ERROR:EXITING RAISE_ADD_MSG_EVENT ------------', 2);
            END IF;

   END RAISE_ADD_MSG_EVENT;


   -- Name
   --    INSERT_DATA
   -- Purpose
   --    This is the public procedure which checks the status and also the SYNC indicator
   --    Based on this, global variable INSERT_DATA is set to 'TRUE' or 'FALSE'
   --
   -- Arguments
   --
   -- Notes
   --    No specific notes.

   PROCEDURE INSERT_DATA(
         p_return_status                IN VARCHAR2,
         p_sync_indicator               IN VARCHAR2,
         x_insert_data                  OUT NOCOPY VARCHAR2 )

   IS
         l_error_code                NUMBER;
         l_error_msg                 VARCHAR2(2000);
         l_msg_data                  VARCHAR2(255);

   BEGIN

         IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('---------- ENTERING INSERT_DATA ------------', 2);
         END IF;

         IF ((p_return_status = 'S') AND (p_sync_indicator <>'Delete')) THEN
                x_insert_data := 'TRUE';
         ELSE
                x_insert_data := 'FALSE';
         END IF;

         IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Data To be Inserted  -->'||x_insert_data, 1);
         END IF;

         IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('----------- EXITING INSERT_DATA ------------', 2);
         END IF;

   EXCEPTION
         WHEN OTHERS THEN
            IF (l_Debug_Level <=2 ) THEN
                cln_debug_pub.Add('----------- ERROR:EXITING INSERT_DATA ------------', 2);
            END IF;
   END INSERT_DATA;


  -- Name
  --   ERROR_HANDLER
  -- Purpose
  --
  -- Arguments
  --
  -- Notes
  --   No specific notes.

  PROCEDURE ERROR_HANDLER(
         x_return_status             IN OUT NOCOPY VARCHAR2,
         x_msg_data                  IN OUT NOCOPY VARCHAR2,
         p_org_ref                   IN VARCHAR2,
         p_internal_control_number   IN NUMBER,
         x_notification_code         OUT NOCOPY VARCHAR2,
         x_notification_status       OUT NOCOPY VARCHAR2,
         x_return_status_tp          OUT NOCOPY VARCHAR2,
         x_return_desc_tp            OUT NOCOPY VARCHAR2 )

  IS
         l_cln_ch_parameters         wf_parameter_list_t;
         l_event_key                 NUMBER;
         l_error_code                NUMBER;
         l_error_msg                 VARCHAR2(2000);
         l_msg_data                  VARCHAR2(255);
         l_msg_dtl_screen            VARCHAR2(2000);
         l_coll_status               VARCHAR2(255);
         l_msg_buffer                VARCHAR2(2000);

  BEGIN


        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('------ Entering ERROR_HANDLER API ------ ', 2);
        END IF;

        -- Initialize API return status to success
        l_msg_data :='Parameters set to their correct values when the return status is ERROR';

        -- here we do not initialize x_msg_data so as to account for the actual message coming from
        -- previous API calls.


        -- Parameters received
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('-------------  Parameters Received   ------------ ', 1);
                cln_debug_pub.Add('Return Status                        - '||x_return_status,1);
                cln_debug_pub.Add('Message Data                         - '||x_msg_data,1);
                cln_debug_pub.Add('Originator Reference                 - '||p_org_ref,1);
                cln_debug_pub.Add('Internal Control Number              - '||p_internal_control_number,1);
                cln_debug_pub.Add('------------------------------------------------- ', 1);
                cln_debug_pub.Add('Rollback all previous changes....',1);
        END IF;

        ROLLBACK TO CHECK_COLLABORATION_PUB;

        -- get a unique key for raising update collaboration event.
        SELECT  cln_generic_s.nextval INTO l_event_key FROM dual;

        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('--------ERROR status   -------------',1);
        END IF;

        x_notification_code             := 'SYN_ITM05';
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

        WF_EVENT.AddParameterToList('DOCUMENT_STATUS', 'ERROR', l_cln_ch_parameters);
        WF_EVENT.AddParameterToList('ORIGINATOR_REFERENCE', p_org_ref, l_cln_ch_parameters);
        WF_EVENT.AddParameterToList('MESSAGE_TEXT', x_msg_data, l_cln_ch_parameters);
        WF_EVENT.AddParameterToList('ROSETTANET_CHECK_REQUIRED','TRUE',l_cln_ch_parameters);
        WF_EVENT.AddParameterToList('XMLG_INTERNAL_CONTROL_NUMBER',p_internal_control_number,l_cln_ch_parameters);

        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('------------------- EVENT PARAMETERS SET -------------------', 1);
                cln_debug_pub.Add('Workflow event- oracle.apps.cln.ch.collaboration.update', 1);
        END IF;

        WF_EVENT.Raise('oracle.apps.cln.ch.collaboration.update',l_event_key, NULL, l_cln_ch_parameters, NULL);

        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add(l_msg_data,1);
        END IF;

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
              l_msg_data :='Unexpected Error in ERROR_HANDLER   -'||l_error_code||' : '||l_error_msg;
              IF (l_Debug_Level <= 6) THEN
                cln_debug_pub.Add(l_msg_data,6);
              END IF;

              IF (l_Debug_Level <= 6) THEN
                cln_debug_pub.Add('------- ERROR:Exiting ERROR_HANDLER API --------- ',6);
              END IF;

  END ERROR_HANDLER;



  -- Name
  --    XGM_CHECK_STATUS
  -- Purpose
  --    This procedure returns 'True' incase the status inputted is 'S' and returns 'False'
  --    incase the status inputted is other then 'S'
  -- Arguments
  --
  -- Notes
  --    No specific notes.

  PROCEDURE XGM_CHECK_STATUS (
         p_itemtype                  IN VARCHAR2,
         p_itemkey                   IN VARCHAR2,
         p_actid                     IN NUMBER,
         p_funcmode                  IN VARCHAR2,
         x_resultout                 OUT NOCOPY VARCHAR2 )
  IS
         l_error_code                NUMBER;
         l_sender_header_id          NUMBER;
         l_party_id                  NUMBER;
         l_party_site_id             NUMBER;
         l_event_key                 NUMBER;
         l_internal_control_number   NUMBER;
         l_return_status             VARCHAR2(10);
         l_return_status_tp          VARCHAR2(10);
         l_notification_code         VARCHAR2(10);
         l_org_item_import           VARCHAR2(10);
         l_party_type                VARCHAR2(20);
         l_supplier_name             VARCHAR2(100);
         l_notification_status       VARCHAR2(100);
         l_msg_data                  VARCHAR2(255);
         l_return_desc_tp            VARCHAR2(1000);
         l_error_msg                 VARCHAR2(2000);


  BEGIN


        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('------ Entering XGM_CHECK_STATUS API ------ ', 2);
        END IF;

        l_msg_data :='Status returned from XGM checked for further processing';

        -- Do nothing in cancel or timeout mode
        --
        IF (p_funcmode <> wf_engine.eng_run) THEN
            x_resultout := wf_engine.eng_null;
            IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Not in Running Mode...........Return Here',1);
            END IF;

            RETURN;
        END IF;

        -- Should be S for success
        l_return_status_tp := wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER7', TRUE);
        IF (l_Debug_Level <= 1) THEN
            cln_debug_pub.Add('Return Status as obtained from workflow  : '||l_return_status_tp,1);
        END IF;

        l_sender_header_id := TO_NUMBER(wf_engine.GetItemAttrText(p_itemtype, p_itemkey,'PARAMETER9', TRUE));
        IF (l_Debug_Level <= 1) THEN
            cln_debug_pub.Add('Trading Partner Header ID                : '||l_sender_header_id, 1);
        END IF;

        l_notification_code       := wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER4', TRUE);
        IF (l_Debug_Level <= 1) THEN
            cln_debug_pub.Add('Notification Code                        : '||l_notification_code, 1);
        END IF;

        l_notification_status     := wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER5', TRUE);
        IF (l_Debug_Level <= 1) THEN
            cln_debug_pub.Add('Notification Status                      : '||l_notification_status, 1);
        END IF;

        l_internal_control_number := TO_NUMBER(wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'EVENT_KEY', TRUE));
        IF (l_Debug_Level <= 1) THEN
            cln_debug_pub.Add('Internal Control Number                  : '||l_internal_control_number, 1);
        END IF;


        -- Get the user choice regarding the organization where the user wants to import the items
        l_org_item_import := FND_PROFILE.VALUE('CLN_ORG_ITEM_IMPRT');

        IF (l_Debug_Level <= 1) THEN
            cln_debug_pub.Add('Organization Choice                      : '||l_org_item_import, 1);
        END IF;

        IF (l_org_item_import IS NULL) OR (l_org_item_import = 'MASTER_ORG' ) THEN
                wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'CLN_ORG_ITEM_IMPORT','2' );
        ELSE
                wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'CLN_ORG_ITEM_IMPORT','1' );
        END IF;


        IF (l_sender_header_id IS NOT NULL) THEN

                -- generate an event key which is also passed as xmlg document id.
                SELECT  cln_generic_s.nextval INTO l_event_key FROM dual;
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('XMLG Document ID set as                  : '||l_event_key, 1);
                END IF;

                SELECT PARTY_ID, PARTY_SITE_ID,PARTY_TYPE
                INTO l_party_id, l_party_site_id, l_party_type
                FROM ECX_TP_HEADERS
                WHERE TP_HEADER_ID = l_sender_header_id ;

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Party ID                                 : '||l_party_id,1);
                        cln_debug_pub.Add('Party Site ID                            : '||l_party_site_id,1);
                        cln_debug_pub.Add('Party Type                               : '||l_party_type,1);
                END IF;

                SELECT VENDOR_NAME
                INTO l_supplier_name
                FROM PO_VENDORS
                WHERE VENDOR_ID = l_party_id ;

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Supplier Name                            : '||l_supplier_name,1);
                END IF;

                wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'PARTY_ID', l_party_id);
                wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'PARTY_SITE_ID', l_party_site_id);
                wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'PARTY_TYPE', l_party_type);
                wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'SUPPLIER_NAME', l_supplier_name);
                wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'XMLG_DOCUMENT_ID',l_event_key );

        END IF;

        -- send notification code to the buyer and seller.
        IF ((l_notification_code <> 'SYN_ITM01') OR (l_notification_code <> 'SYN_ITM05'))THEN

                IF (l_Debug_Level <= 1) THEN
                       cln_debug_pub.Add('Calling the CLN_NP_PROCESSOR_PKG.TAKE_ACTIONS API...', 1);
                END IF;

                CLN_NP_PROCESSOR_PKG.TAKE_ACTIONS(
                       x_ret_code            => l_return_status,
                       x_ret_desc            => l_msg_data,
                       p_notification_code   => l_notification_code,
                       p_notification_desc   => 'SUCCESS',
                       p_status              => 'SUCCESS',
                       p_tp_id               => l_sender_header_id,
                       p_reference           => NULL,
                       p_coll_point          => 'APPS',
                       p_int_con_no          => l_internal_control_number);

                IF (l_return_status <> 'S') THEN
                     IF (l_Debug_Level <= 1) THEN
                                 cln_debug_pub.Add(l_msg_data,1);
                     END IF;

                     RAISE FND_API.G_EXC_ERROR;
                END IF;
        END IF;
        ----------------


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
            wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER4', 'SYN_ITM05');

            IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Message for the trading partner   : '||l_return_desc_tp, 1);
            END IF;

            x_resultout := 'COMPLETE:'||'FALSE';
        END IF;



        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add(l_msg_data,1);
        END IF;

        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('------- Exiting XGM_CHECK_STATUS API --------- ',2);
        END IF;

  -- Exception Handling
  EXCEPTION
        WHEN OTHERS THEN
            WF_CORE.CONTEXT('CLN_SYNC_ITEM_PKG', 'XGM_CHECK_STATUS', p_itemtype, p_itemkey, to_char(p_actid), p_funcmode);

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
            wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER4', 'SYN_ITM05');

            x_resultout := 'COMPLETE:'||'FALSE';

            CLN_NP_PROCESSOR_PKG.NOTIFY_ADMINISTRATOR(l_return_desc_tp);

            IF (l_Debug_Level <= 6) THEN
                cln_debug_pub.Add('------- ERROR:Exiting XGM_CHECK_STATUS API --------- ',6);
            END IF;
  END XGM_CHECK_STATUS;


  -- Name
  --    ITEM_IMPORT_STATUS_HANDLER
  -- Purpose
  --    This API checks for the status and accordingly updates the collaboration. Also, on the basis
  --    of Input parameters, notifications are sent out to Buyer for his necessary actions.
  -- Arguments
  --
  -- Notes
  --    No specific notes.

  PROCEDURE ITEM_IMPORT_STATUS_HANDLER (
         p_itemtype                     IN VARCHAR2,
         p_itemkey                      IN VARCHAR2,
         p_actid                        IN NUMBER,
         p_funcmode                     IN VARCHAR2,
         x_resultout                    OUT NOCOPY VARCHAR2 )
  IS

         l_error_code                   NUMBER;
         l_event_key                    NUMBER;
         l_request_id                   NUMBER;
         l_internal_control_number      NUMBER;
         l_master_organization_id       NUMBER;
         l_set_process_id               NUMBER;
         l_sender_header_id             NUMBER;
         l_transaction_id               NUMBER;

         l_status_code                  VARCHAR2(2);
         l_count_failed_rows            VARCHAR2(2);
         l_notification_code            VARCHAR2(10);
         l_return_status_tp             VARCHAR2(10);
         l_process_each_row_for_errors  VARCHAR2(20);
         l_doc_status                   VARCHAR2(25);
         l_phase_code                   VARCHAR2(25);
         l_reference1                   VARCHAR2(100);
         l_notification_status          VARCHAR2(100);
         l_supplier_name                VARCHAR2(250);
         l_concurrent_msg               VARCHAR2(250);
         l_table_name                   VARCHAR2(250);
         l_return_desc_tp               VARCHAR2(1000);
         sql_statement_error_msg        VARCHAR2(2000);
         l_update_coll_msg              VARCHAR2(2000);
         l_msg_data                     VARCHAR2(2000);
         l_error_msg                    VARCHAR2(2000);

         l_cln_ch_parameters            wf_parameter_list_t;

         TYPE c_sys_interface_error     IS REF CURSOR;
         c_cursor_error                 c_sys_interface_error;

  BEGIN

        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('------ Entering ITEM_IMPORT_STATUS_HANDLER API ------ ', 2);
        END IF;

        l_msg_data                      :='Parameters defaulted to proper values based on the status obtained after running the Item Import concurrent program.';
        l_process_each_row_for_errors   := 'FALSE';
        x_resultout                     := 'COMPLETE:'||'TRUE';

        -- Do nothing in cancel or timeout mode
        --
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

        l_supplier_name := wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'SUPPLIER_NAME', TRUE);
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Supplier Name                                : '||l_supplier_name, 1);
        END IF;

        l_master_organization_id  := TO_NUMBER(wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER3', TRUE));
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Master Organization ID                       : '||l_master_organization_id, 1);
        END IF;

        l_set_process_id          := wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER6', TRUE);
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Set Process ID                               : '||l_set_process_id, 1);
        END IF;

        l_request_id              := TO_NUMBER(wf_engine.GetItemAttrText(p_itemtype, p_itemkey,'REQIDNAME', TRUE));
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Concurrent Program Request ID                : '||l_request_id, 1);
        END IF;

        l_notification_code       := wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER4', TRUE);
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Notification Code                            : '||l_notification_code, 1);
        END IF;


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
        END;

        l_update_coll_msg := NULL;

        IF (l_status_code NOT IN ('I','C','R')) THEN
                l_doc_status            := 'ERROR';

                --IF (l_concurrent_msg IS NOT NULL) THEN
                --        l_update_coll_msg       := l_concurrent_msg;
                --ELSE
                        FND_MESSAGE.SET_NAME('CLN','CLN_CH_CONCURRENT_FAILED');
                        FND_MESSAGE.SET_TOKEN('REQNAME','Item Import');
                        FND_MESSAGE.SET_TOKEN('REQID',l_request_id);
                        l_update_coll_msg       := FND_MESSAGE.GET;
                --END IF;
                l_return_status_tp      := '99';
                l_return_desc_tp        := l_update_coll_msg;
                l_notification_code     := 'SYN_ITM05';

                x_resultout := 'COMPLETE:'||'FALSE';

        ELSE
                l_doc_status            := 'SUCCESS';
                l_return_status_tp      := '00';

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Processing for Completed Normal status of Concurrent Program', 1);
                END IF;
        END IF;

          -- check for failed rows..
        BEGIN
                SELECT 'x'
                INTO l_count_failed_rows
                FROM DUAL
                WHERE EXISTS (
                                        /*SELECT 'x'
                                          FROM MTL_INTERFACE_ERRORS
                                          WHERE REQUEST_ID       = l_request_id
                                          AND TRANSACTION_ID > 0
                                          AND rownum < 2*/
                                          SELECT 'x'
                                          FROM mtl_system_items_interface msit
                                          WHERE process_flag IN (3,4)
                                          AND set_process_id = l_set_process_id
                                          UNION
                                          SELECT 'x'
                                          FROM mtl_item_revisions_interface mri
                                          WHERE process_flag IN (3,4)
                                          AND set_process_id = l_set_process_id
                                          UNION
                                          SELECT 'x'
                                          FROM mtl_item_categories_interface mici
                                          WHERE process_flag IN (3,4)
                                          AND set_process_id = l_set_process_id
                              );
        EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                         cln_debug_pub.Add('All Items successfully Imported for request ID -'||l_request_id, 1);
                         ---
        END;

          IF (l_count_failed_rows = 'x') THEN

               IF (l_Debug_Level <= 1) THEN
                     cln_debug_pub.Add('Few items failed to be imported ', 1);
               END IF;

               IF (l_update_coll_msg IS NULL) THEN
                     FND_MESSAGE.SET_NAME('CLN','CLN_CH_CONCURRENT_SUCCESS_1');
                     FND_MESSAGE.SET_TOKEN('REQNAME','Item Import');
                     FND_MESSAGE.SET_TOKEN('REQID',l_request_id);
                     l_update_coll_msg               := FND_MESSAGE.GET;
               END IF;

               l_return_desc_tp                := l_update_coll_msg;
               l_process_each_row_for_errors   := 'TRUE';
          ELSE
               IF (l_update_coll_msg IS NULL) THEN
                     FND_MESSAGE.SET_NAME('CLN','CLN_CH_CONCURRENT_SUCCESS_2');
                     FND_MESSAGE.SET_TOKEN('REQNAME','Item Import');
                     FND_MESSAGE.SET_TOKEN('REQID',l_request_id);
                     l_update_coll_msg         := FND_MESSAGE.GET;
               END IF;

               l_return_desc_tp                := l_update_coll_msg;
               l_process_each_row_for_errors   := 'FALSE';
          END IF;


          -- generate an event key which is also passed as event key for update collaboration .
          SELECT  cln_generic_s.nextval INTO l_event_key FROM dual;

          IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Message for update collaboration    = '||l_update_coll_msg, 1);
                cln_debug_pub.Add('Event Key for update collaboration  = '||l_event_key, 1);
          END IF;


          l_cln_ch_parameters := wf_parameter_list_t();
          WF_EVENT.AddParameterToList('DOCUMENT_STATUS', l_doc_status, l_cln_ch_parameters);
          WF_EVENT.AddParameterToList('ORIGINATOR_REFERENCE', l_master_organization_id, l_cln_ch_parameters);
          WF_EVENT.AddParameterToList('MESSAGE_TEXT', l_update_coll_msg, l_cln_ch_parameters);
          WF_EVENT.AddParameterToList('ROSETTANET_CHECK_REQUIRED','TRUE',l_cln_ch_parameters);
          WF_EVENT.AddParameterToList('XMLG_INTERNAL_CONTROL_NUMBER',l_internal_control_number,l_cln_ch_parameters);


          IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('-------- EVENT PARAMETERS SET-----------', 1);
                cln_debug_pub.Add('Workflow event- oracle.apps.cln.ch.collaboration.update', 1);
          END IF;

          WF_EVENT.Raise('oracle.apps.cln.ch.collaboration.update',l_event_key, NULL, l_cln_ch_parameters, NULL);

          IF (l_process_each_row_for_errors = 'TRUE') THEN

                    sql_statement_error_msg  :=   ' SELECT ERROR_MESSAGE, TRANSACTION_ID, TABLE_NAME'
                                                ||' FROM MTL_INTERFACE_ERRORS'
                                                ||' WHERE REQUEST_ID       = '||l_request_id
                                                ||' AND TRANSACTION_ID > 0';

                    IF (l_Debug_Level <= 1) THEN
                       cln_debug_pub.Add('Sql Query           '||sql_statement_error_msg, 1);
                    END IF;

                    OPEN c_cursor_error FOR sql_statement_error_msg;
                    LOOP
                        FETCH c_cursor_error INTO l_error_msg, l_transaction_id, l_table_name;
                        EXIT WHEN c_cursor_error%NOTFOUND;
                        -- process row here

                        IF (l_Debug_Level <= 1) THEN
                              cln_debug_pub.Add('Entered Cursor to find error message.......', 1);
                        END IF;

                        IF (l_Debug_Level <= 1) THEN
                              cln_debug_pub.Add('Error Message            '||l_error_msg, 1);
                        END IF;

                        IF (l_Debug_Level <= 1) THEN
                              cln_debug_pub.Add('Transaction ID           '||l_transaction_id, 1);
                        END IF;

                        IF (l_transaction_id IS NOT NULL) THEN
                                -- find out the item number from the query below.
                                -- this is reqd for the showing in final event details screen
                                BEGIN
                                        execute immediate 'select item_number from '||l_table_name ||' where TRANSACTION_ID = :1 and REQUEST_ID = :2'
                                        into l_reference1
                                        using l_transaction_id, l_request_id ;

                                        l_reference1 := 'Item No -'||l_reference1;

                                EXCEPTION
                                        WHEN OTHERS THEN
                                               cln_debug_pub.Add('Could not find the Item Number for the transaction ID', 1);
                                               l_reference1 := '-';
                                END;
                        ELSE
                                l_reference1 := ' - ';
                        END IF;
                        cln_debug_pub.Add('Item Number -'||l_reference1,1);

                        IF (l_Debug_Level <= 1) THEN
                              cln_debug_pub.Add('---------- SETTING WORKFLOW PARAMETERS---------', 1);
                        END IF;

                        -- generate an event key which is also passed as event key for add collaboration event.
                        SELECT  cln_generic_s.nextval INTO l_event_key FROM dual;


                        WF_EVENT.AddParameterToList('REFERENCE_ID1','ERROR',l_cln_ch_parameters);
                        IF (l_Debug_Level <= 1) THEN
                              cln_debug_pub.Add('---------- 1---------', 1);
                        END IF;
                        WF_EVENT.AddParameterToList('REFERENCE_ID2','Org ID:'||l_master_organization_id,l_cln_ch_parameters);
                        IF (l_Debug_Level <= 1) THEN
                              cln_debug_pub.Add('---------- 2---------', 1);
                        END IF;
                        --WF_EVENT.AddParameterToList('REFERENCE_ID3','Supplier:'||l_supplier_name,l_cln_ch_parameters);
                        --IF (l_Debug_Level <= 1) THEN
                        --      cln_debug_pub.Add('---------- 3---------', 1);
                        --END IF;
                        WF_EVENT.AddParameterToList('REFERENCE_ID3',l_reference1,l_cln_ch_parameters);
                        IF (l_Debug_Level <= 1) THEN
                              cln_debug_pub.Add('---------- 3---------', 1);
                        END IF;
                        WF_EVENT.AddParameterToList('DETAIL_MESSAGE',l_error_msg,l_cln_ch_parameters);
                        IF (l_Debug_Level <= 1) THEN
                              cln_debug_pub.Add('---------- 4---------', 1);
                        END IF;
                        WF_EVENT.AddParameterToList('DOCUMENT_TYPE', 'SYNC_ITEM', l_cln_ch_parameters);
                        WF_EVENT.AddParameterToList('DOCUMENT_DIRECTION', 'IN', l_cln_ch_parameters);
                        WF_EVENT.AddParameterToList('COLLABORATION_POINT', 'APPS', l_cln_ch_parameters);
                        WF_EVENT.AddParameterToList('XMLG_INTERNAL_CONTROL_NUMBER',l_internal_control_number,l_cln_ch_parameters);

                        IF (l_Debug_Level <= 1) THEN
                              cln_debug_pub.Add('----------------------------------------------', 1);
                              cln_debug_pub.Add('Workflow event- oracle.apps.cln.ch.collaboration.addmessage : Key '||l_event_key, 1);
                        END IF;

                        WF_EVENT.Raise('oracle.apps.cln.ch.collaboration.addmessage',l_event_key, NULL, l_cln_ch_parameters, NULL);

                        IF (l_Debug_Level <= 1) THEN
                              cln_debug_pub.Add('Moving out of Cursor .....', 1);
                        END IF;

                    END LOOP;
                    CLOSE c_cursor_error;
          END IF;

          wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'RETURN_STATUS_TP', l_return_status_tp);
          wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'RETURN_MSG_TP', l_return_desc_tp);
          wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'DOCUMENT_STATUS',l_doc_status );
          wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER4', l_notification_code);



          IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Return Status to Trading Partner   '||l_return_status_tp,1);
                cln_debug_pub.Add('Return Message to Trading Partner  '||l_return_desc_tp,1);
                cln_debug_pub.Add(l_msg_data,1);
          END IF;

          IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add(l_msg_data,1);
          END IF;

          IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('------- Exiting ITEM_IMPORT_STATUS_HANDLER API --------- ',2);
          END IF;

  EXCEPTION
        WHEN OTHERS THEN
            l_error_code      := SQLCODE;
            l_error_msg       := SQLERRM;
            l_msg_data        := l_error_code||' : '||l_error_msg;
            IF (l_Debug_Level <= 6) THEN
                cln_debug_pub.Add(l_msg_data,6);
            END IF;

            WF_CORE.CONTEXT('CLN_SYNC_ITEM_PKG', 'ITEM_IMPORT_STATUS_HANDLER', p_itemtype, p_itemkey, to_char(p_actid), p_funcmode);

            FND_MESSAGE.SET_NAME('CLN','CLN_CH_ACTIVITY_ERROR');
            FND_MESSAGE.SET_TOKEN('ITMTYPE',p_itemtype);
            FND_MESSAGE.SET_TOKEN('ITMKEY',p_itemkey);
            FND_MESSAGE.SET_TOKEN('ACTIVITY','STATUS_HANDLER');

            -- we are not stopping the process becoz of this error,
            -- negative confirm bod is sent out with error occured here
            l_return_status_tp      := '99';
            l_return_desc_tp        := FND_MESSAGE.GET;

            wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'RETURN_STATUS_TP', l_return_status_tp);
            wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'RETURN_MSG_TP', l_return_desc_tp);
            wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'DOCUMENT_STATUS','ERROR' );
            wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER4', 'SYN_ITM05');


            x_resultout := 'COMPLETE:'||'FALSE';

            CLN_NP_PROCESSOR_PKG.NOTIFY_ADMINISTRATOR(l_return_desc_tp);

            IF (l_Debug_Level <= 6) THEN
                cln_debug_pub.Add('------- ERROR:Exiting ITEM_IMPORT_STATUS_HANDLER API --------- ',6);
            END IF;

            -- return success so as to continue the workflow activity.
            RETURN;

  END ITEM_IMPORT_STATUS_HANDLER;


  -- Name
  --    SETUP_CST_INTERFACE_TABLE
  -- Purpose
  --    This API checks for the status and accordingly updates the costing interface table
  --    with the inventory_item_id for the items which got imported and also it deletes the
  --    the records for the items which falied to get imported
  --
  -- Arguments
  --
  -- Notes
  --    No specific notes.

  PROCEDURE SETUP_CST_INTERFACE_TABLE (
         p_itemtype                     IN VARCHAR2,
         p_itemkey                      IN VARCHAR2,
         p_actid                        IN NUMBER,
         p_funcmode                     IN VARCHAR2,
         x_resultout                    OUT NOCOPY VARCHAR2 )
  IS
         l_internal_control_number      NUMBER;
         l_inventory_item_id            NUMBER;
         l_inv_item_id_frm_temp         NUMBER;
         l_cst_group_id                 NUMBER;
         l_master_organization_id       NUMBER;
         l_manufacture_id               NUMBER;
         l_set_process_id               NUMBER;
         l_process_flag                 NUMBER;
         l_event_key                    NUMBER;
         l_error_code                   NUMBER;
         l_resource_id                  NUMBER;
         l_count                        NUMBER;

         l_check_cost_type              VARCHAR2(10);
         l_return_status                VARCHAR2(10);
         l_return_status_tp             VARCHAR2(10);
         l_check                        VARCHAR2(15);
         l_mfg_part_num                 VARCHAR2(30);
         l_item_number                  VARCHAR2(100);
         l_cost_type                    VARCHAR2(250);
         l_supplier_name                VARCHAR2(250);
         l_return_desc_tp               VARCHAR2(1000);
         sql_statement                  VARCHAR2(2000);
         sql_statement_1                VARCHAR2(2000);
         l_error_msg                    VARCHAR2(2000);
         l_msg_data                     VARCHAR2(2000);

         l_cln_ch_parameters            wf_parameter_list_t;
         TYPE c_sys_items_interface     IS REF CURSOR;
         c_cursor                       c_sys_items_interface;

  BEGIN

        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('------ Entering SETUP_CST_INTERFACE_TABLE API ------ ', 2);
        END IF;

        l_msg_data :='Costing interface tables populated with correct values of inventory_item_id';

        -- Do nothing in cancel or timeout mode
        --
        IF (p_funcmode <> wf_engine.eng_run) THEN
            x_resultout := wf_engine.eng_null;
            IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Not in Running Mode...........Return Here',1);
            END IF;
            RETURN;
        END IF;

        -- Getting the values from the workflow.
        l_master_organization_id  := TO_NUMBER(wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER3', TRUE));
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Master Organization ID         : '||l_master_organization_id, 1);
        END IF;

        l_set_process_id          := wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER6', TRUE);
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Set Process ID                 : '||l_set_process_id, 1);
        END IF;

        l_internal_control_number := TO_NUMBER(wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'EVENT_KEY', TRUE));
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Internal Control Number        : '||l_internal_control_number, 1);
        END IF;

        l_cst_group_id := TO_NUMBER(wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER10', TRUE));
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Costing Group ID               : '||l_cst_group_id, 1);
        END IF;

        l_supplier_name := wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'SUPPLIER_NAME', TRUE);
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Supplier Name                  : '||l_supplier_name, 1);
        END IF;


        -- Get the cost type from the profile values wherein the user wants to import the
        -- items
        l_cost_type := FND_PROFILE.VALUE('CLN_COST_TYPE');

        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Cost Type                      : '||l_cost_type, 1);
        END IF;

     /*
        IF (l_cost_type IS NULL) THEN
                FND_MESSAGE.SET_NAME('CLN','CLN_CH_COST_TYPE_NS');
                l_return_desc_tp         := FND_MESSAGE.GET;
                l_check                  := 'ERROR';
        END IF;
     */

        IF (l_cost_type IS NULL) THEN
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Cost Type not defined', 1);
                END IF;
        ELSE
                wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'COST_TYPE',l_cost_type );
        END IF;


        -- get the relevant resource id
        BEGIN
                SELECT resource_id
                INTO l_resource_id
                FROM BOM_RESOURCES
                WHERE cost_element_id = 1
                AND organization_id   = l_master_organization_id
                AND rownum < 2;

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Resource ID                    : '||l_resource_id, 1);
                END IF;

        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                       cln_debug_pub.Add('ERROR : Could not find the resource id for the particular cost_element_id and organization', 1);
                       FND_MESSAGE.SET_NAME('CLN','CLN_CH_RESOURCEID_NF');
                       l_return_desc_tp         := FND_MESSAGE.GET;
                       l_check                  := 'ERROR';
        END;

        IF (l_check = 'ERROR') THEN

                l_return_status_tp      := '99';
                wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'RETURN_STATUS_TP', l_return_status_tp);
                wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'RETURN_MSG_TP', l_return_desc_tp);
                wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'DOCUMENT_STATUS','ERROR' );
                wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER4', 'SYN_ITM05');

                -- generate an event key which is also passed as event key for update collaboration .
                SELECT  cln_generic_s.nextval INTO l_event_key FROM dual;

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Message for update collaboration    = '||l_msg_data, 1);
                        cln_debug_pub.Add('Event Key for update collaboration  = '||l_event_key, 1);
                END IF;

                l_cln_ch_parameters := wf_parameter_list_t();
                WF_EVENT.AddParameterToList('DOCUMENT_STATUS', 'ERROR', l_cln_ch_parameters);
                WF_EVENT.AddParameterToList('ORIGINATOR_REFERENCE', l_master_organization_id, l_cln_ch_parameters);
                WF_EVENT.AddParameterToList('MESSAGE_TEXT', l_return_desc_tp, l_cln_ch_parameters);
                WF_EVENT.AddParameterToList('ROSETTANET_CHECK_REQUIRED','TRUE',l_cln_ch_parameters);
                WF_EVENT.AddParameterToList('XMLG_INTERNAL_CONTROL_NUMBER',l_internal_control_number,l_cln_ch_parameters);


                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('-------- EVENT PARAMETERS SET-----------', 1);
                        cln_debug_pub.Add('Workflow event- oracle.apps.cln.ch.collaboration.update', 1);
                END IF;

                x_resultout := 'COMPLETE:'||'FALSE';

                WF_EVENT.Raise('oracle.apps.cln.ch.collaboration.update',l_event_key, NULL, l_cln_ch_parameters, NULL);

                IF (l_Debug_Level <= 6) THEN
                        cln_debug_pub.Add('------- ERROR:Exiting SETUP_CST_INTERFACE_TABLE API --------- ',6);
                END IF;

                RETURN;
        END IF;

        sql_statement :=    ' SELECT DISTINCT INVENTORY_ITEM_ID,'
                          ||' item_number, process_flag'
                          ||' FROM mtl_system_items_interface msit'
                          ||' WHERE process_flag IN (3,4)'
                          ||' AND set_process_id = '||l_set_process_id
                          ||' AND process_flag   IN (3,4)'
                          ||' UNION'
                          ||' SELECT DISTINCT INVENTORY_ITEM_ID,'
                          ||' item_number, process_flag'
                          ||' FROM mtl_item_revisions_interface mri'
                          ||' WHERE process_flag IN (3,4)'
                          ||' AND set_process_id = '||l_set_process_id
                          ||' AND process_flag   IN (3,4)'
                          ||' UNION'
                          ||' SELECT DISTINCT INVENTORY_ITEM_ID,'
                          ||' item_number, process_flag'
                          ||' FROM mtl_item_categories_interface mici'
                          ||' WHERE process_flag IN (3,4)'
                          ||' AND set_process_id = '||l_set_process_id
                          ||' AND process_flag   IN (3,4)';


        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Sql Query           '||sql_statement, 1);
        END IF;


        OPEN c_cursor FOR sql_statement;
        LOOP
                FETCH c_cursor INTO l_inventory_item_id, l_item_number, l_process_flag;
                EXIT WHEN c_cursor%NOTFOUND;
                -- process row here

                IF (l_Debug_Level <= 1) THEN
                      cln_debug_pub.Add('Entered Cursor 1.......', 1);
                END IF;

                IF (l_Debug_Level <= 1) THEN
                      cln_debug_pub.Add('Item Number             '||l_item_number, 1);
                END IF;

                IF (l_Debug_Level <= 1) THEN
                      cln_debug_pub.Add('Process Flag            '||l_process_flag, 1);
                END IF;

                IF (l_process_flag <> 7) OR (l_inventory_item_id IS NULL) OR (l_inventory_item_id = 0) THEN
                        IF (l_Debug_Level <= 1) THEN
                               cln_debug_pub.Add('Deleting the rows from the temp table for which the item import failed', 1);
                        END IF;

                        DELETE FROM CLN_CST_DTLS_TEMP
                        WHERE item_number     =  l_item_number
                        AND   group_id        =  l_cst_group_id;

                        IF (l_Debug_Level <= 1) THEN
                               cln_debug_pub.Add('Deletion of the rows successful', 1);
                        END IF;
                END IF;
        END LOOP;
        CLOSE c_cursor;

        sql_statement_1 :=  ' SELECT DISTINCT ITEM_NUMBER'
                          ||' FROM CLN_CST_DTLS_TEMP'
                          ||' WHERE group_id      = '|| l_cst_group_id;


        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Sql Query           '||sql_statement_1, 1);
        END IF;


        OPEN c_cursor FOR sql_statement_1;
        LOOP
                FETCH c_cursor INTO l_item_number;
                EXIT WHEN c_cursor%NOTFOUND;
                -- process row here

                IF (l_Debug_Level <= 1) THEN
                      cln_debug_pub.Add('Entered Cursor 2.......', 1);
                END IF;

                IF (l_Debug_Level <= 1) THEN
                      cln_debug_pub.Add('Item Number             '||l_item_number, 1);
                END IF;

                IF (l_Debug_Level <= 1) THEN
                      cln_debug_pub.Add('Obtaining the inventory item id from the mtl_system_items_b table', 1);
                END IF;

                BEGIN
                       SELECT inventory_item_id
                       INTO l_inventory_item_id
                       FROM mtl_system_items_b
                       WHERE SEGMENT1 = l_item_number AND organization_id = l_master_organization_id;

                       IF (l_Debug_Level <= 1) THEN
                                cln_debug_pub.Add('Inventory Item ID for the item number : '||l_item_number||' is = '||l_inventory_item_id, 1);
                       END IF;

                EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                            cln_debug_pub.Add('ERROR : Could not find the record in the mtl_system_items_b table for the item number -'||l_item_number, 1);
                            RAISE FND_API.G_EXC_ERROR;
                END;

                UPDATE CLN_CST_DTLS_TEMP
                SET inventory_item_id =  l_inventory_item_id,
                    resource_id       =  l_resource_id
                --  cost_type         =  l_cost_type
                WHERE item_number     =  l_item_number
                AND   group_id        =  l_cst_group_id;

                IF (l_Debug_Level <= 1) THEN
                       cln_debug_pub.Add('Updation of the rows successful', 1);
                END IF;

        END LOOP;
        CLOSE c_cursor;


        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Insertion of the rows in the interface table ......', 1);
        END IF;


        -- INSERTION OF THE DATA IN THE COSTING INTERFACE TABLE
        INSERT INTO CST_ITEM_CST_DTLS_INTERFACE
        (
           INVENTORY_ITEM_ID,
           ORGANIZATION_ID,
           RESOURCE_ID,
           USAGE_RATE_OR_AMOUNT,
           COST_ELEMENT_ID,
           PROCESS_FLAG,
           COST_TYPE,
           GROUP_ID,
           ITEM_NUMBER,
           ITEM_COST
        )(
                SELECT
                INVENTORY_ITEM_ID,
                ORGANIZATION_ID,
                RESOURCE_ID,
                USAGE_RATE_OR_AMOUNT,
                COST_ELEMENT_ID,
                PROCESS_FLAG,
                COST_TYPE,
                GROUP_ID,
                ITEM_NUMBER,
                ITEM_COST
                FROM
                CLN_CST_DTLS_TEMP
                WHERE group_id        =  l_cst_group_id
         );

         IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Insertion of the rows in the interface table successful', 1);
         END IF;

        wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'REQIDNAME',null);


        x_resultout := 'COMPLETE:'||'TRUE';

        IF (l_Debug_Level <= 1) THEN
               cln_debug_pub.Add('Status is TRUE',1);
        END IF;

        IF (l_Debug_Level <= 1) THEN
               cln_debug_pub.Add(l_msg_data,1);
        END IF;


        IF (l_Debug_Level <= 2) THEN
               cln_debug_pub.Add('------- Exiting SETUP_CST_INTERFACE_TABLE API --------- ',2);
        END IF;

  EXCEPTION
        WHEN OTHERS THEN
            l_error_code      := SQLCODE;
            l_error_msg       := SQLERRM;
            l_msg_data        := l_error_code||' : '||l_error_msg;
            IF (l_Debug_Level <= 6) THEN
                cln_debug_pub.Add(l_msg_data,6);
            END IF;

            WF_CORE.CONTEXT('CLN_SYNC_ITEM_PKG', 'SETUP_CST_INTERFACE_TABLE', p_itemtype, p_itemkey, to_char(p_actid), p_funcmode);

            FND_MESSAGE.SET_NAME('CLN','CLN_CH_ACTIVITY_ERROR');
            FND_MESSAGE.SET_TOKEN('ITMTYPE',p_itemtype);
            FND_MESSAGE.SET_TOKEN('ITMKEY',p_itemkey);
            FND_MESSAGE.SET_TOKEN('ACTIVITY','SET_CST_INTERFACE_TABLE');

            -- we are not stopping the process becoz of this error,
            -- negative confirm bod is sent out with error occured here
            l_return_status_tp      := '99';
            l_return_desc_tp        := FND_MESSAGE.GET;

            wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'RETURN_STATUS_TP', l_return_status_tp);
            wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'RETURN_MSG_TP', l_return_desc_tp);
            wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'DOCUMENT_STATUS','ERROR' );
            wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER4', 'SYN_ITM05');

            x_resultout := 'COMPLETE:'||'FALSE';

            CLN_NP_PROCESSOR_PKG.NOTIFY_ADMINISTRATOR(l_return_desc_tp);
            IF (l_Debug_Level <= 6) THEN
                cln_debug_pub.Add('------- ERROR:Exiting SETUP_CST_INTERFACE_TABLE API --------- ',6);
            END IF;

            -- return success so as to continue the workflow activity.
            RETURN;

  END SETUP_CST_INTERFACE_TABLE;


  -- Name
  --    UPDATE_COLLB_STATUS
  -- Purpose
  --    This API updates the collaboration history based on the status after the running of costing
  --    interface concurrent program
  --
  -- Arguments
  --
  -- Notes
  --    No specific notes.

  PROCEDURE UPDATE_COLLB_STATUS (
         p_itemtype                     IN VARCHAR2,
         p_itemkey                      IN VARCHAR2,
         p_actid                        IN NUMBER,
         p_funcmode                     IN VARCHAR2,
         x_resultout                    OUT NOCOPY VARCHAR2 )
  IS
         l_internal_control_number      NUMBER;
         l_cst_group_id                 NUMBER;
         l_master_organization_id       NUMBER;
         l_request_id                   NUMBER;
         l_error_code                   NUMBER;
         l_event_key                    NUMBER;
         l_sender_header_id             NUMBER;
         l_manufacture_id               NUMBER;


         l_status_code                  VARCHAR2(2);
         l_count_failed_rows            VARCHAR2(2);
         l_mfg_details                  VARCHAR2(10);
         l_return_status                VARCHAR2(10);
         l_return_status_tp             VARCHAR2(10);
         l_notification_code            VARCHAR2(10);
         l_doc_status                   VARCHAR2(25);
         l_phase_code                   VARCHAR2(25);
         l_process_each_row_for_errors  VARCHAR2(25);
         l_item_number                  VARCHAR2(100);
         l_message_standard		VARCHAR2(100);
         l_concurrent_msg               VARCHAR2(250);
         l_supplier_name                VARCHAR2(250);
         l_return_msg_tp                VARCHAR2(2000);
         l_return_desc_tp               VARCHAR2(2000);
         l_error_msg                    VARCHAR2(2000);
         l_msg_data                     VARCHAR2(2000);
         l_update_coll_msg              VARCHAR2(2000);
         sql_statement_error_msg        VARCHAR2(2000);
         l_cln_ch_parameters            wf_parameter_list_t;

         TYPE c_cst_items_interface     IS REF CURSOR;
         c_cursor_error                 c_cst_items_interface;

  BEGIN

        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('------ Entering UPDATE_COLLB_STATUS API ------ ', 2);
        END IF;

        l_msg_data :='Updating the collaboration history with the new status after running the Cost Import Process';

        -- Do nothing in cancel or timeout mode
        --
        IF (p_funcmode <> wf_engine.eng_run) THEN
            x_resultout := wf_engine.eng_null;
            IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Not in Running Mode...........Return Here',1);
            END IF;
            RETURN;
        END IF;

        -- Getting the values from the workflow.

        l_return_status_tp        := wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'RETURN_STATUS_TP', TRUE);
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Return Status for the trading partner        : '||l_return_status_tp, 1);
        END IF;

        l_notification_code       := wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER4', TRUE);
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Notification Code                            : '||l_notification_code, 1);
        END IF;

        l_internal_control_number := TO_NUMBER(wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'EVENT_KEY', TRUE));
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Internal Control Number                      : '||l_internal_control_number, 1);
        END IF;

        l_master_organization_id  := TO_NUMBER(wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER3', TRUE));
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Master Organization ID                       : '||l_master_organization_id, 1);
        END IF;

        l_request_id              := TO_NUMBER(wf_engine.GetItemAttrText(p_itemtype, p_itemkey,'REQIDNAME', TRUE));
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Concurrent Program Request ID                : '||l_request_id, 1);
        END IF;

        l_cst_group_id := TO_NUMBER(wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER10', TRUE));
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Costing Group ID                             : '||l_cst_group_id, 1);
        END IF;

        l_supplier_name := wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'SUPPLIER_NAME', TRUE);
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Supplier Name                                : '||l_supplier_name, 1);
        END IF;

        l_return_msg_tp := wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'RETURN_MSG_TP', TRUE);
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Message To Trading Partner                   : '||l_return_msg_tp, 1);
        END IF;

        l_sender_header_id := TO_NUMBER(wf_engine.GetItemAttrText(p_itemtype, p_itemkey,'PARAMETER9', TRUE));
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Trading Partner Header ID                    : '||l_sender_header_id, 1);
        END IF;


	IF l_internal_control_number IS NOT NULL THEN
             IF (l_Debug_Level <= 1) THEN
                  cln_debug_pub.Add('Internal Control Number is not Null', 1);
             END IF;

	     BEGIN
	     	  SELECT trim(message_standard)
	     	  INTO l_message_standard
		  FROM ecx_doclogs
		  WHERE INTERNAL_CONTROL_NUMBER = l_internal_control_number;
	     EXCEPTION
                WHEN NO_DATA_FOUND THEN
                       l_msg_data 		:= 'ECX DOCLOGS has no entry corresponding to the given Internal Control Number';
                       l_return_msg_tp 		:= 'Issues in the Trading Partner Setup. No Record in AQ';
                       l_return_status_tp 	:= '99';
	     END;

             IF (l_Debug_Level <= 1) THEN
                  cln_debug_pub.Add('Collaboration Standard - '||l_message_standard, 1);
             END IF;

	     wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'COLLABORATION_STANDARD', l_message_standard);
	END IF;


        -- sending out the notification incase of an error
        IF(l_return_status_tp = '99')THEN
            -- call take actions here......finally ....

           IF (l_Debug_Level <= 1) THEN
                  cln_debug_pub.Add('Calling the CLN_NP_PROCESSOR_PKG.TAKE_ACTIONS API...', 1);
           END IF;


           CLN_NP_PROCESSOR_PKG.TAKE_ACTIONS(
               x_ret_code            => l_return_status,
               x_ret_desc            => l_msg_data,
               p_notification_code   => 'SYN_ITM05',
               p_notification_desc   => l_return_msg_tp,
               p_status              => 'ERROR',
               p_tp_id               => l_sender_header_id,
               p_reference           => NULL,
               p_coll_point          => 'APPS',
               p_int_con_no          => l_internal_control_number);

            IF (l_return_status <> 'S') THEN
                IF (l_Debug_Level <= 1) THEN
                         cln_debug_pub.Add(l_msg_data,1);
                END IF;

                RAISE FND_API.G_EXC_ERROR;
            END IF;

           RETURN;
        END IF;

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
                       l_msg_data          := FND_MESSAGE.GET;
                       l_status_code       := 'E'; -- so that this case should be considered.
                       l_concurrent_msg    := l_msg_data;
        END;



        IF (l_status_code NOT IN ('I','C','R','G')) THEN
                l_doc_status            := 'ERROR';

                --IF (l_concurrent_msg IS NOT NULL) THEN
                --        l_update_coll_msg       := l_concurrent_msg;
                --ELSE
                        FND_MESSAGE.SET_NAME('CLN','CLN_CH_CONCURRENT_FAILED');
                        FND_MESSAGE.SET_TOKEN('REQNAME','Cost Import');
                        FND_MESSAGE.SET_TOKEN('REQID',l_request_id);
                        l_update_coll_msg       := FND_MESSAGE.GET;
                --END IF;
                l_return_status_tp      := '99';
                l_return_desc_tp        := l_update_coll_msg;

                -- WE NEED TO CALL TAKE ACTIONS FOR SENDING OUT THE NOTIFICATION CODES AND STATUS

        ELSE
                l_doc_status            := 'SUCCESS';
                l_return_status_tp      := '00';

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Processing for Completed Normal/Warning status of Concurrent Program', 1);
                END IF;

                -- check for failed rows..
                SELECT COUNT(*)
                INTO l_count_failed_rows
                FROM dual
                WHERE exists
                ( SELECT 'x'
                  FROM cst_item_cst_dtls_interface cicdi
                  WHERE error_flag = 'E'
                  AND group_id     =  l_cst_group_id
                  AND rownum < 2
                );

                IF (l_count_failed_rows > 0) THEN
                        IF (l_Debug_Level <= 1) THEN
                                cln_debug_pub.Add('Few items failed to be imported ', 1);
                        END IF;
                        FND_MESSAGE.SET_NAME('CLN','CLN_CH_CONCURRENT_SUCCESS_1');
                        FND_MESSAGE.SET_TOKEN('REQNAME','Cost Import');
                        FND_MESSAGE.SET_TOKEN('REQID',l_request_id);
                        l_update_coll_msg               := FND_MESSAGE.GET;
                        l_return_desc_tp                := l_update_coll_msg;
                        l_process_each_row_for_errors   := 'TRUE';
                ELSE
                        FND_MESSAGE.SET_NAME('CLN','CLN_CH_CONCURRENT_SUCCESS_2');
                        FND_MESSAGE.SET_TOKEN('REQNAME','Cost Import');
                        FND_MESSAGE.SET_TOKEN('REQID',l_request_id);
                        l_update_coll_msg               := FND_MESSAGE.GET;
                        l_return_desc_tp                := l_update_coll_msg;
                        l_process_each_row_for_errors   := 'FALSE';

                END IF;
          END IF;

          -- generate an event key which is also passed as event key for update collaboration .
          SELECT  cln_generic_s.nextval INTO l_event_key FROM dual;

          IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Message for update collaboration    = '||l_update_coll_msg, 1);
                cln_debug_pub.Add('Event Key for update collaboration  = '||l_event_key, 1);
          END IF;

          -- set the parameter list for the workflow
          l_cln_ch_parameters := wf_parameter_list_t();
          WF_EVENT.AddParameterToList('DOCUMENT_STATUS', l_doc_status, l_cln_ch_parameters);
          WF_EVENT.AddParameterToList('ORIGINATOR_REFERENCE', l_master_organization_id, l_cln_ch_parameters);
          WF_EVENT.AddParameterToList('MESSAGE_TEXT', l_update_coll_msg, l_cln_ch_parameters);
          WF_EVENT.AddParameterToList('ROSETTANET_CHECK_REQUIRED','TRUE',l_cln_ch_parameters);
          WF_EVENT.AddParameterToList('XMLG_INTERNAL_CONTROL_NUMBER',l_internal_control_number,l_cln_ch_parameters);


          IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('-------- EVENT PARAMETERS SET-----------', 1);
                cln_debug_pub.Add('Workflow event- oracle.apps.cln.ch.collaboration.update', 1);
          END IF;

          WF_EVENT.Raise('oracle.apps.cln.ch.collaboration.update',l_event_key, NULL, l_cln_ch_parameters, NULL);

          IF (l_return_status_tp = '99') THEN
                IF (l_Debug_Level <= 1) THEN
                     cln_debug_pub.Add('Message for the trading partner   : '||l_update_coll_msg, 1);
                END IF;

                wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'RETURN_STATUS_TP', '99');
                wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'RETURN_MSG_TP', l_update_coll_msg);
                wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'DOCUMENT_STATUS','ERROR' );
                wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER4', 'SYN_ITM05');


                -- SENDING OUT THE NOTIFICATION INCASE OF AN ERROR
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Calling the CLN_NP_PROCESSOR_PKG.TAKE_ACTIONS API...', 1);
                END IF;

                CLN_NP_PROCESSOR_PKG.TAKE_ACTIONS(
                    x_ret_code            => l_return_status,
                    x_ret_desc            => l_msg_data,
                    p_notification_code   => 'SYN_ITM05',
                    p_notification_desc   => l_update_coll_msg,
                    p_status              => 'ERROR',
                    p_tp_id               => l_sender_header_id,
                    p_reference           => NULL,
                    p_coll_point          => 'APPS',
                    p_int_con_no          => l_internal_control_number);

                 IF (l_return_status <> 'S') THEN
                     IF (l_Debug_Level <= 1) THEN
                              cln_debug_pub.Add(l_msg_data,1);
                     END IF;

                     RAISE FND_API.G_EXC_ERROR;
                 END IF;


                RETURN;
          END IF;


          IF (l_process_each_row_for_errors = 'TRUE') THEN

                -- find out the item number from the query below.
                -- this is reqd for the showing in final event details screen

                    sql_statement_error_msg  :=   ' SELECT ERROR_EXPLANATION, ITEM_NUMBER'
                                                ||' FROM CST_ITEM_CST_DTLS_INTERFACE'
                                                ||' WHERE ORGANIZATION_ID  = '||l_master_organization_id
                                                ||' AND GROUP_ID           = '||l_cst_group_id
                                                ||' AND ERROR_EXPLANATION IS NOT NULL';

                                                --||' AND ERROR_FLAG         = '||l_error_flag


                    OPEN c_cursor_error FOR sql_statement_error_msg;
                    LOOP
                        FETCH c_cursor_error INTO l_error_msg, l_item_number;
                        EXIT WHEN c_cursor_error%NOTFOUND;
                        -- process row here

                        IF (l_Debug_Level <= 1) THEN
                              cln_debug_pub.Add('Entered Cursor to find error message.......', 1);
                        END IF;

                        IF (l_Debug_Level <= 1) THEN
                              cln_debug_pub.Add('Error Message            '||l_error_msg, 1);
                        END IF;

                        IF (l_Debug_Level <= 1) THEN
                              cln_debug_pub.Add('---------- SETTING WORKFLOW PARAMETERS---------', 1);
                        END IF;

                        -- generate an event key which is also passed as event key for add collaboration event.
                        SELECT  cln_generic_s.nextval INTO l_event_key FROM dual;


                        WF_EVENT.AddParameterToList('REFERENCE_ID1','ERROR',l_cln_ch_parameters);
                        WF_EVENT.AddParameterToList('REFERENCE_ID2','Org ID : '||l_master_organization_id,l_cln_ch_parameters);
                        WF_EVENT.AddParameterToList('REFERENCE_ID3','Item No -'||l_item_number,l_cln_ch_parameters);
                        --WF_EVENT.AddParameterToList('REFERENCE_ID4',,l_cln_ch_parameters);
                        WF_EVENT.AddParameterToList('DETAIL_MESSAGE',l_error_msg,l_cln_ch_parameters);
                        WF_EVENT.AddParameterToList('DOCUMENT_TYPE', 'SYNC_ITEM', l_cln_ch_parameters);
                        WF_EVENT.AddParameterToList('DOCUMENT_DIRECTION', 'IN', l_cln_ch_parameters);
                        WF_EVENT.AddParameterToList('COLLABORATION_POINT', 'APPS', l_cln_ch_parameters);
                        WF_EVENT.AddParameterToList('XMLG_INTERNAL_CONTROL_NUMBER',l_internal_control_number,l_cln_ch_parameters);

                        IF (l_Debug_Level <= 1) THEN
                              cln_debug_pub.Add('----------------------------------------------', 1);
                              cln_debug_pub.Add('Workflow event- oracle.apps.cln.ch.collaboration.addmessage', 1);
                        END IF;

                        WF_EVENT.Raise('oracle.apps.cln.ch.collaboration.addmessage',l_event_key, NULL, l_cln_ch_parameters, NULL);

                        IF (l_Debug_Level <= 1) THEN
                              cln_debug_pub.Add('Moving out of Cursor to find error message.....', 1);
                        END IF;

                    END LOOP;
                    CLOSE c_cursor_error;
          END IF;

         IF (l_Debug_Level <= 1) THEN
               cln_debug_pub.Add('Looking for the Manufacturer Details.....', 1);
         END IF;

         -- get the relevant manufacturer id
         BEGIN
                SELECT MANUFACTURER_ID
                INTO l_manufacture_id
                FROM mtl_manufacturers
                WHERE MANUFACTURER_NAME =  l_supplier_name
                AND rownum < 2;

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Manufacturer ID     : ',l_manufacture_id);
                END IF;

                wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'MANUFACTURER_ID', l_manufacture_id);

          EXCEPTION
                WHEN NO_DATA_FOUND THEN
                       cln_debug_pub.Add('ERROR : Could not find details for the manufacturer',1);
                       FND_MESSAGE.SET_NAME('CLN','CLN_CH_MFG_DTLS_NF');
                       l_return_desc_tp         := FND_MESSAGE.GET;
                       l_mfg_details            := '99';
          END;


          IF (l_mfg_details = '99') THEN
                -- generate an event key which is also passed as event key for update collaboration .
                SELECT  cln_generic_s.nextval INTO l_event_key FROM dual;

                IF (l_Debug_Level <= 1) THEN
                      cln_debug_pub.Add('Message for update collaboration    = '||l_return_desc_tp, 1);
                      cln_debug_pub.Add('Event Key for update collaboration  = '||l_event_key, 1);
                      cln_debug_pub.Add('Message for the trading partner     = '||l_return_desc_tp, 1);
                END IF;

                l_cln_ch_parameters := wf_parameter_list_t();
                WF_EVENT.AddParameterToList('DOCUMENT_STATUS', 'ERROR', l_cln_ch_parameters);
                WF_EVENT.AddParameterToList('ORIGINATOR_REFERENCE', l_master_organization_id, l_cln_ch_parameters);
                WF_EVENT.AddParameterToList('MESSAGE_TEXT', l_return_desc_tp, l_cln_ch_parameters);
                WF_EVENT.AddParameterToList('ROSETTANET_CHECK_REQUIRED','TRUE',l_cln_ch_parameters);
                WF_EVENT.AddParameterToList('XMLG_INTERNAL_CONTROL_NUMBER',l_internal_control_number,l_cln_ch_parameters);


                IF (l_Debug_Level <= 1) THEN
                      cln_debug_pub.Add('-------- EVENT PARAMETERS SET-----------', 1);
                      cln_debug_pub.Add('Workflow event- oracle.apps.cln.ch.collaboration.update', 1);
                END IF;

                WF_EVENT.Raise('oracle.apps.cln.ch.collaboration.update',l_event_key, NULL, l_cln_ch_parameters, NULL);

                wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'RETURN_STATUS_TP', '99');
                wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'RETURN_MSG_TP', l_return_desc_tp);
                wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'DOCUMENT_STATUS','ERROR' );
                wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER4', 'SYN_ITM05');


                -- SENDING OUT THE NOTIFICATION INCASE OF AN ERROR
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Calling the CLN_NP_PROCESSOR_PKG.TAKE_ACTIONS API...', 1);
                END IF;

                CLN_NP_PROCESSOR_PKG.TAKE_ACTIONS(
                    x_ret_code            => l_return_status,
                    x_ret_desc            => l_msg_data,
                    p_notification_code   => 'SYN_ITM05',
                    p_notification_desc   => l_return_desc_tp,
                    p_status              => 'ERROR',
                    p_tp_id               => l_sender_header_id,
                    p_reference           => NULL,
                    p_coll_point          => 'APPS',
                    p_int_con_no          => l_internal_control_number);

                 IF (l_return_status <> 'S') THEN
                     IF (l_Debug_Level <= 1) THEN
                              cln_debug_pub.Add(l_msg_data,1);
                     END IF;

                     RAISE FND_API.G_EXC_ERROR;
                 END IF;

                RETURN;
          END IF;

          -- SENDING OUT THE NOTIFICATION INCASE OF A SUCCESS
          IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('Calling the CLN_NP_PROCESSOR_PKG.TAKE_ACTIONS API...', 1);
          END IF;


          CLN_NP_PROCESSOR_PKG.TAKE_ACTIONS(
              x_ret_code            => l_return_status,
              x_ret_desc            => l_msg_data,
              p_notification_code   => l_notification_code,
              p_notification_desc   => 'SUCCESS',
              p_status              => 'SUCCESS',
              p_tp_id               => l_sender_header_id,
              p_reference           => NULL,
              p_coll_point          => 'APPS',
              p_int_con_no          => l_internal_control_number);

          IF (l_return_status <> 'S') THEN
              IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add(l_msg_data,1);
              END IF;

              RAISE FND_API.G_EXC_ERROR;
          END IF;

          wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'RETURN_STATUS_TP', l_return_status_tp);
          wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'RETURN_MSG_TP', 'SUCCESS');

        IF (l_Debug_Level <= 1) THEN
              cln_debug_pub.Add(l_msg_data,1);
        END IF;


        IF (l_Debug_Level <= 2) THEN
              cln_debug_pub.Add('------- Exiting UPDATE_COLLB_STATUS API --------- ',2);
        END IF;

  EXCEPTION
        WHEN OTHERS THEN
            l_error_code      := SQLCODE;
            l_error_msg       := SQLERRM;
            l_msg_data        := l_error_code||' : '||l_error_msg;
            IF (l_Debug_Level <= 6) THEN
                cln_debug_pub.Add(l_msg_data,6);
            END IF;

            WF_CORE.CONTEXT('CLN_SYNC_ITEM_PKG', 'UPDATE_COLLB_STATUS', p_itemtype, p_itemkey, to_char(p_actid), p_funcmode);

            FND_MESSAGE.SET_NAME('CLN','CLN_CH_ACTIVITY_ERROR');
            FND_MESSAGE.SET_TOKEN('ITMTYPE',p_itemtype);
            FND_MESSAGE.SET_TOKEN('ITMKEY',p_itemkey);
            FND_MESSAGE.SET_TOKEN('ACTIVITY','STATUS_UPDATE');

            -- we are not stopping the process becoz of this error,
            -- negative confirm bod is sent out with error occured here
            l_return_status_tp      := '99';
            l_return_desc_tp        := FND_MESSAGE.GET;

            wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'RETURN_STATUS_TP', l_return_status_tp);
            wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'RETURN_MSG_TP', l_return_desc_tp);
            wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'DOCUMENT_STATUS','ERROR' );

            CLN_NP_PROCESSOR_PKG.NOTIFY_ADMINISTRATOR(FND_MESSAGE.GET);

            IF (l_Debug_Level <= 6) THEN
                cln_debug_pub.Add('------- ERROR:Exiting UPDATE_COLLB_STATUS API --------- ',6);
            END IF;

            -- return success so as to continue the workflow activity.
            RETURN;

  END UPDATE_COLLB_STATUS;


  -- Name
  --    MFG_PARTNUM_STATUS_CHECK
  -- Purpose
  --    This API checks for the status of the concurrent program for updating
  --    the manufacturing part number and incase of an error
  --    updates the collaboration history.
  --
  -- Arguments
  --
  -- Notes
  --    No specific notes.

  PROCEDURE MFG_PARTNUM_STATUS_CHECK (
         p_itemtype                     IN VARCHAR2,
         p_itemkey                      IN VARCHAR2,
         p_actid                        IN NUMBER,
         p_funcmode                     IN VARCHAR2,
         x_resultout                    OUT NOCOPY VARCHAR2 )
  IS
         l_internal_control_number      NUMBER;
         l_cst_group_id                 NUMBER;
         l_master_organization_id       NUMBER;
         l_request_id                   NUMBER;
         l_error_code                   NUMBER;
         l_event_key                    NUMBER;
         l_sender_header_id             NUMBER;

         l_status_code                  VARCHAR2(2);
         l_count_failed_rows            VARCHAR2(2);
         l_return_status                VARCHAR2(10);
         l_return_status_tp             VARCHAR2(10);
         l_notification_code            VARCHAR2(10);
         l_doc_status                   VARCHAR2(25);
         l_phase_code                   VARCHAR2(25);
         l_process_each_row_for_errors  VARCHAR2(25);
         l_item_number                  VARCHAR2(100);
         l_concurrent_msg               VARCHAR2(250);
         l_supplier_name                VARCHAR2(250);
         l_return_msg_tp                VARCHAR2(2000);
         l_return_desc_tp               VARCHAR2(2000);
         l_error_msg                    VARCHAR2(2000);
         l_msg_data                     VARCHAR2(2000);
         l_update_coll_msg              VARCHAR2(2000);
         l_cln_ch_parameters            wf_parameter_list_t;

  BEGIN

        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('------ Entering MFG_PARTNUM_STATUS_CHECK API ------ ', 2);
        END IF;

        l_msg_data :='Concurrent Program for the Manufacturing Part Number completed Normally.';

        -- Do nothing in cancel or timeout mode
        --
        IF (p_funcmode <> wf_engine.eng_run) THEN
            x_resultout := wf_engine.eng_null;
            IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Not in Running Mode...........Return Here',1);
            END IF;
            RETURN;
        END IF;

        -- Getting the values from the workflow.

        l_return_status_tp        := wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'RETURN_STATUS_TP', TRUE);
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Return Status for the trading partner        : '||l_return_status_tp, 1);
        END IF;

        l_notification_code       := wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER4', TRUE);
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Notification Code                            : '||l_notification_code, 1);
        END IF;

        l_internal_control_number := TO_NUMBER(wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'EVENT_KEY', TRUE));
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Internal Control Number                      : '||l_internal_control_number, 1);
        END IF;

        l_master_organization_id  := TO_NUMBER(wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER3', TRUE));
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Master Organization ID                       : '||l_master_organization_id, 1);
        END IF;

        l_request_id              := TO_NUMBER(wf_engine.GetItemAttrText(p_itemtype, p_itemkey,'REQIDNAME', TRUE));
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Concurrent Program Request ID                : '||l_request_id, 1);
        END IF;

        l_return_msg_tp := wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'RETURN_MSG_TP', TRUE);
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Message To Trading Partner                   : '||l_return_msg_tp, 1);
        END IF;

        l_sender_header_id := TO_NUMBER(wf_engine.GetItemAttrText(p_itemtype, p_itemkey,'PARAMETER9', TRUE));
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Trading Partner Header ID                    : '||l_sender_header_id, 1);
        END IF;

        l_cst_group_id := TO_NUMBER(wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER10', TRUE));
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Costing Group ID               : '||l_cst_group_id, 1);
        END IF;

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
                       l_msg_data          := FND_MESSAGE.GET;
                       l_status_code       := 'E'; -- so that this case should be considered.
                       l_concurrent_msg    := l_msg_data;
        END;

        IF (l_status_code NOT IN ('I','C','R','G')) THEN
                l_doc_status            := 'ERROR';

                IF (l_concurrent_msg IS NOT NULL) THEN
                        l_update_coll_msg       := l_concurrent_msg;
                ELSE
                        FND_MESSAGE.SET_NAME('CLN','CLN_CH_CONCURRENT_FAILED');
                        FND_MESSAGE.SET_TOKEN('REQNAME','MFG Part Number Import');
                        l_update_coll_msg       := FND_MESSAGE.GET;
                END IF;
                l_return_status_tp      := '99';
                l_return_desc_tp        := l_update_coll_msg;

                -- generate an event key which is also passed as event key for update collaboration .
                SELECT  cln_generic_s.nextval INTO l_event_key FROM dual;

                IF (l_Debug_Level <= 1) THEN
                      cln_debug_pub.Add('Message for update collaboration    = '||l_update_coll_msg, 1);
                      cln_debug_pub.Add('Event Key for update collaboration  = '||l_event_key, 1);
                END IF;


                l_cln_ch_parameters := wf_parameter_list_t();
                WF_EVENT.AddParameterToList('DOCUMENT_STATUS', l_doc_status, l_cln_ch_parameters);
                WF_EVENT.AddParameterToList('ORIGINATOR_REFERENCE', l_master_organization_id, l_cln_ch_parameters);
                WF_EVENT.AddParameterToList('MESSAGE_TEXT', l_update_coll_msg, l_cln_ch_parameters);
                WF_EVENT.AddParameterToList('ROSETTANET_CHECK_REQUIRED','TRUE',l_cln_ch_parameters);
                WF_EVENT.AddParameterToList('XMLG_INTERNAL_CONTROL_NUMBER',l_internal_control_number,l_cln_ch_parameters);


                IF (l_Debug_Level <= 1) THEN
                      cln_debug_pub.Add('-------- EVENT PARAMETERS SET-----------', 1);
                      cln_debug_pub.Add('Workflow event- oracle.apps.cln.ch.collaboration.update', 1);
                END IF;

                WF_EVENT.Raise('oracle.apps.cln.ch.collaboration.update',l_event_key, NULL, l_cln_ch_parameters, NULL);

                IF (l_Debug_Level <= 1) THEN
                     cln_debug_pub.Add('Message for the trading partner   : '||l_update_coll_msg, 1);
                END IF;

                wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'RETURN_STATUS_TP', '99');
                wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'RETURN_MSG_TP', l_update_coll_msg);
                wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'DOCUMENT_STATUS','ERROR' );
                wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER4', 'SYN_ITM05');


                -- SENDING OUT THE NOTIFICATION INCASE OF AN ERROR
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Calling the CLN_NP_PROCESSOR_PKG.TAKE_ACTIONS API...', 1);
                END IF;

                CLN_NP_PROCESSOR_PKG.TAKE_ACTIONS(
                    x_ret_code            => l_return_status,
                    x_ret_desc            => l_msg_data,
                    p_notification_code   => 'SYN_ITM05',
                    p_notification_desc   => l_update_coll_msg,
                    p_status              => 'ERROR',
                    p_tp_id               => l_sender_header_id,
                    p_reference           => NULL,
                    p_coll_point          => 'APPS',
                    p_int_con_no          => l_internal_control_number);

                 IF (l_return_status <> 'S') THEN
                     IF (l_Debug_Level <= 1) THEN
                              cln_debug_pub.Add(l_msg_data,1);
                     END IF;

                     RAISE FND_API.G_EXC_ERROR;
                 END IF;
        ELSE

                 IF (l_Debug_Level <= 1) THEN
                         cln_debug_pub.Add('Deleting the rows from the CLN_CST_DTLS_TEMP table...', 1);
                 END IF;

                 DELETE FROM CLN_CST_DTLS_TEMP
                 WHERE group_id        =  l_cst_group_id;

                 IF (l_Debug_Level <= 1) THEN
                         cln_debug_pub.Add('Rows from the CLN_CST_DTLS_TEMP table deleted...', 1);
                 END IF;

        END IF;

        IF (l_Debug_Level <= 1) THEN
              cln_debug_pub.Add(l_msg_data,1);
        END IF;

        IF (l_Debug_Level <= 2) THEN
              cln_debug_pub.Add('------- Exiting MFG_PARTNUM_STATUS_CHECK API --------- ',2);
        END IF;


  EXCEPTION
        WHEN OTHERS THEN
            l_error_code      := SQLCODE;
            l_error_msg       := SQLERRM;
            l_msg_data        := l_error_code||' : '||l_error_msg;
            IF (l_Debug_Level <= 6) THEN
                cln_debug_pub.Add(l_msg_data,6);
            END IF;

            WF_CORE.CONTEXT('CLN_SYNC_ITEM_PKG', 'MFG_PARTNUM_STATUS_CHECK', p_itemtype, p_itemkey, to_char(p_actid), p_funcmode);

            FND_MESSAGE.SET_NAME('CLN','CLN_CH_ACTIVITY_ERROR');
            FND_MESSAGE.SET_TOKEN('ITMTYPE',p_itemtype);
            FND_MESSAGE.SET_TOKEN('ITMKEY',p_itemkey);
            FND_MESSAGE.SET_TOKEN('ACTIVITY','MFG_PARTNUM_STATUS_CHECK');

            -- we are not stopping the process becoz of this error,
            -- negative confirm bod is sent out with error occured here
            l_return_status_tp      := '99';
            l_return_desc_tp        := FND_MESSAGE.GET;

            wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'RETURN_STATUS_TP', l_return_status_tp);
            wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'RETURN_MSG_TP', l_return_desc_tp);
            wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'DOCUMENT_STATUS','ERROR' );

            CLN_NP_PROCESSOR_PKG.NOTIFY_ADMINISTRATOR(FND_MESSAGE.GET);

            IF (l_Debug_Level <= 6) THEN
                cln_debug_pub.Add('------- ERROR:Exiting MFG_PARTNUM_STATUS_CHECK API --------- ',6);
            END IF;

            -- return success so as to continue the workflow activity.
            RETURN;

  END MFG_PARTNUM_STATUS_CHECK;




  -- Name
  --    UPDATE_COLLB_STATUS_RN
  -- Purpose
  --    This API updates the status of the collaboration based on the document status
  --    for Rosettanet supported Framework
  --
  -- Arguments
  --
  -- Notes
  --    No specific notes.

  PROCEDURE UPDATE_COLLB_STATUS_RN (
         p_itemtype                     IN VARCHAR2,
         p_itemkey                      IN VARCHAR2,
         p_actid                        IN NUMBER,
         p_funcmode                     IN VARCHAR2,
         x_resultout                    OUT NOCOPY VARCHAR2 )
  IS
         l_internal_control_number      NUMBER;
         l_error_code                   NUMBER;
         l_event_key                    NUMBER;
         l_master_organization_id       NUMBER;

         l_doc_status                   VARCHAR2(25);
         l_completed_status		VARCHAR2(25);

         l_error_msg                    VARCHAR2(2000);
         l_msg_data                     VARCHAR2(2000);
         l_update_coll_msg              VARCHAR2(2000);
         l_cln_ch_parameters            wf_parameter_list_t;

  BEGIN

        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('------ Entering UPDATE_COLLB_STATUS_RN API ------ ', 2);
        END IF;

	l_msg_data := 'Collaboration updated with appropriate status';

        --
        IF (p_funcmode <> wf_engine.eng_run) THEN
            x_resultout := wf_engine.eng_null;
            IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Not in Running Mode...........Return Here',1);
            END IF;
            RETURN;
        END IF;

        -- Getting the values from the workflow.
        l_doc_status	          := wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'DOCUMENT_STATUS', TRUE);
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Document Status                              : '||l_doc_status, 1);
        END IF;

        l_internal_control_number := TO_NUMBER(wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'EVENT_KEY', TRUE));
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Internal Control Number                      : '||l_internal_control_number, 1);
        END IF;

        l_master_organization_id  := TO_NUMBER(wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER3', TRUE));
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Master Organization ID                       : '||l_master_organization_id, 1);
        END IF;

        l_completed_status 	:=	'COMPLETED';
        -- Status set based on the doc status
        IF (l_doc_status  = 'ERROR') THEN
              l_completed_status 	:=	'ERROR';
        END IF;

        FND_MESSAGE.SET_NAME('CLN','CLN_2A12_SYNC_TRANX_COMPLETE');
	--  'Sync Item Transaction Completed';
	l_update_coll_msg      := FND_MESSAGE.GET;


        -- generate an event key which is also passed as event key for update collaboration .
        SELECT  cln_generic_s.nextval INTO l_event_key FROM dual;

        IF (l_Debug_Level <= 1) THEN
              cln_debug_pub.Add('Message for update collaboration    = '||l_update_coll_msg, 1);
              cln_debug_pub.Add('Event Key for update collaboration  = '||l_event_key, 1);
        END IF;

        l_cln_ch_parameters := wf_parameter_list_t();
        WF_EVENT.AddParameterToList('DOCUMENT_STATUS', l_doc_status, l_cln_ch_parameters);
        WF_EVENT.AddParameterToList('ORIGINATOR_REFERENCE', l_master_organization_id, l_cln_ch_parameters);
        WF_EVENT.AddParameterToList('MESSAGE_TEXT', l_update_coll_msg, l_cln_ch_parameters);
        WF_EVENT.AddParameterToList('XMLG_INTERNAL_CONTROL_NUMBER',l_internal_control_number,l_cln_ch_parameters);
        WF_EVENT.AddParameterToList('COLLABORATION_STATUS',l_completed_status,l_cln_ch_parameters);

        IF (l_Debug_Level <= 1) THEN
              cln_debug_pub.Add('-------- EVENT PARAMETERS SET-----------', 1);
              cln_debug_pub.Add('Workflow event- oracle.apps.cln.ch.collaboration.update', 1);
        END IF;

        WF_EVENT.Raise('oracle.apps.cln.ch.collaboration.update',l_event_key, NULL, l_cln_ch_parameters, NULL);

        IF (l_Debug_Level <= 1) THEN
              cln_debug_pub.Add(l_msg_data,1);
        END IF;

        IF (l_Debug_Level <= 2) THEN
              cln_debug_pub.Add('------- Exiting UPDATE_COLLB_STATUS_RN API --------- ',2);
        END IF;

  EXCEPTION
        WHEN OTHERS THEN
            l_error_code      := SQLCODE;
            l_error_msg       := SQLERRM;
            l_msg_data        := l_error_code||' : '||l_error_msg;
            IF (l_Debug_Level <= 6) THEN
                cln_debug_pub.Add(l_msg_data,6);
            END IF;

            IF (l_Debug_Level <= 6) THEN
                cln_debug_pub.Add('------- ERROR:Exiting UPDATE_COLLB_STATUS_RN API --------- ',6);
            END IF;

  END UPDATE_COLLB_STATUS_RN;


   -- Name
   --    ROLLBACK_CHANGES_RN
   -- Purpose
   --    This is the public procedure which is used to raise an event that add messages into collaboration history passing
   --    these parameters so obtained.This procedure is called when the item status in the
   --    inbound document is obselete
   --
   -- Arguments
   --
   -- Notes
   --    No specific notes.

   PROCEDURE ROLLBACK_CHANGES_RN(
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_supplier_name                IN  VARCHAR2,
         p_buyer_part_number            IN  VARCHAR2,
         p_supplier_part_number         IN  VARCHAR2,
         p_item_number                  IN  VARCHAR2,
         p_item_revision                IN  VARCHAR2,
         p_new_revision_flag            IN  OUT NOCOPY VARCHAR2,
         p_new_deletion_flag            IN  OUT NOCOPY VARCHAR2,
         p_internal_control_number      IN  NUMBER,
         x_notification_code            OUT NOCOPY VARCHAR2 )
   IS
         l_cln_ch_parameters            wf_parameter_list_t;
         l_event_key                    NUMBER;
         l_error_code                   NUMBER;
         l_inventory_item_id            NUMBER;
         l_count                        NUMBER;
         l_reference1                   VARCHAR2(50);
         l_error_msg                    VARCHAR2(255);
         l_msg_data                     VARCHAR2(255);
         l_dtl_msg                      VARCHAR2(255);

   BEGIN

         IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('-------- ENTERING ROLLBACK_CHANGES_RN ------------', 2);
         END IF;

         --  Initialize API return status to success
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         l_msg_data     := 'Item Details rolled back and recorded in the collaboration history';

         FND_MESSAGE.SET_NAME('CLN','CLN_CH_ITEM_DETAILS_ROLLED');
         x_msg_data := FND_MESSAGE.GET;

         ROLLBACK TO CHECK_ITEM_DELETION_PUB;


         -- get a unique key for raising add collaboration event.
         SELECT  cln_generic_s.nextval INTO l_event_key FROM dual;

         IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('----------- PARAMETERS OBTAINED ----------',1);
                cln_debug_pub.Add('Supplier name               ---- '||p_supplier_name,1);
                cln_debug_pub.Add('Buyer Part Number           ---- '||p_buyer_part_number,1);
                cln_debug_pub.Add('Supplier Part Number        ---- '||p_supplier_part_number,1);
                cln_debug_pub.Add('Item Number                 ---- '||p_item_number,1);
                cln_debug_pub.Add('Item Revision               ---- '||p_item_revision,1);
                cln_debug_pub.Add('Revision Flag               ---- '||p_new_revision_flag,1);
                cln_debug_pub.Add('Deletion Flag               ---- '||p_new_deletion_flag,1);
                cln_debug_pub.Add('Internal Control Number     ---- '||p_internal_control_number,1);
                cln_debug_pub.Add('------------------------------------------',1);
         END IF;

         -- defaulting the notification codes and status for success.
         IF (l_Debug_Level <= 1) THEN
               cln_debug_pub.Add('defaulting the notification codes and status for success.......',1);
         END IF;

         IF(p_new_deletion_flag = 'N')THEN
              p_new_deletion_flag := 'Y';
         END IF;

         IF (l_Debug_Level <= 1) THEN
               cln_debug_pub.Add('Item Marked For deletion : Item Number ='||p_item_number,1);
         END IF;

         FND_MESSAGE.SET_NAME('CLN','CLN_CH_ITEM_DELETION');
         FND_MESSAGE.SET_TOKEN('ITEMNUM',p_item_number);
         l_dtl_msg               := FND_MESSAGE.GET;

         l_reference1            := 'Sync Ind: Delete';
         x_notification_code     := 'SYN_ITM02';

         IF(p_new_revision_flag = 'Y')THEN
              x_notification_code := 'SYN_ITM04';
         END IF;

         IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('---------------------------------------------------',1);
                cln_debug_pub.Add('Notification Code          :'||x_notification_code,1);
                cln_debug_pub.Add('Reference 1                :'||l_reference1,1);
                cln_debug_pub.Add('Detail Message             :'||l_dtl_msg,1);
                cln_debug_pub.Add('---------------------------------------------------',1);
         END IF;


         l_cln_ch_parameters := wf_parameter_list_t();

         IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('---------- SETTING WORKFLOW PARAMETERS---------', 1);
         END IF;

         WF_EVENT.AddParameterToList('REFERENCE_ID1',l_reference1,l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('REFERENCE_ID2','Sup PartNo -'||p_supplier_part_number,l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('REFERENCE_ID3','ItemNo:'||p_item_number,l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('DETAIL_MESSAGE',l_dtl_msg,l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('DOCUMENT_TYPE', 'SYNC_ITEM', l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('DOCUMENT_DIRECTION', 'IN', l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('COLLABORATION_POINT', 'APPS', l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('XMLG_INTERNAL_CONTROL_NUMBER',p_internal_control_number,l_cln_ch_parameters);

         IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('----------------------------------------------', 1);
                cln_debug_pub.Add('Workflow event- oracle.apps.cln.ch.collaboration.addmessage', 1);
         END IF;

         WF_EVENT.Raise('oracle.apps.cln.ch.collaboration.addmessage',l_event_key, NULL, l_cln_ch_parameters, NULL);

         IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add(l_msg_data,1);
         END IF;

         IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('--------- EXITING ROLLBACK_CHANGES_RN -------------', 2);
         END IF;

   EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;

            IF (l_Debug_Level <= 4) THEN
                cln_debug_pub.Add(l_msg_data,4);
            END IF;

            CLN_NP_PROCESSOR_PKG.NOTIFY_ADMINISTRATOR(x_msg_data);

            IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('----------- ERROR:EXITING ROLLBACK_CHANGES_RN ------------', 2);
            END IF;

         WHEN OTHERS THEN
            l_error_code      := SQLCODE;
            l_error_msg       := SQLERRM;
            x_return_status   := FND_API.G_RET_STS_UNEXP_ERROR ;
            l_msg_data        := l_error_code||' : '||l_error_msg;
            x_msg_data        := l_msg_data;
            IF (l_Debug_Level <= 6) THEN
                cln_debug_pub.Add(l_msg_data,6);
            END IF;

            IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('----------- ERROR:EXITING ROLLBACK_CHANGES_RN ------------', 2);
            END IF;

   END ROLLBACK_CHANGES_RN;


END CLN_SYNC_ITEM_PKG;

/
