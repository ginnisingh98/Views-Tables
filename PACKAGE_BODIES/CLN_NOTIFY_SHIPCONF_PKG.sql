--------------------------------------------------------
--  DDL for Package Body CLN_NOTIFY_SHIPCONF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CLN_NOTIFY_SHIPCONF_PKG" AS
/* $Header: CLNNTSHB.pls 115.5 2003/11/19 06:02:29 rkrishan noship $ */
   l_debug_level        NUMBER := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));


--  Package
--      CLN_NOTIFY_SHIPCONF_PKG
--
--  Purpose
--      Body of package CLN_NOTIFY_SHIPCONF_PKG.
--
--  History
--      July-21-2003        Rahul Krishan         Created


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
         p_orig_ref                     IN VARCHAR2,
         p_delivery_doc_id              IN VARCHAR2,
         p_internal_control_number      IN NUMBER,
         p_partner_document_number      IN VARCHAR2 )

   IS
         l_cln_ch_parameters            wf_parameter_list_t;
         l_event_key                    NUMBER;
         l_error_code                   NUMBER;
         l_error_msg                    VARCHAR2(255);
         l_rosettanet_check_required    VARCHAR2(10);
         l_msg_data                     VARCHAR2(255);
         l_doc_status                   VARCHAR2(255);
         l_entity_number                VARCHAR2(30);

   BEGIN
         -- Sets the debug mode to be FILE
         -- l_debug_mode := cln_debug_pub.Set_Debug_Mode('FILE');

         IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('-------- ENTERING RAISE_UPDATE_EVENT --------------', 2);
         END IF;

         --  Initialize API return status to success
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         l_msg_data      := 'XML Gateway successfully consumes RN 3B13_Notify_of_Shipment_Confirmation inbound document';

         FND_MESSAGE.SET_NAME('CLN','CLN_WSH_SHIPCONF_CONSUMD');
         x_msg_data      := FND_MESSAGE.GET;

         IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('------------ PARAMETERS OBTAINED ----------', 1);
                cln_debug_pub.Add('Delivery Doc ID             ---- '||p_delivery_doc_id, 1);
                cln_debug_pub.Add('Internal Control Number     ---- '||p_internal_control_number, 1);
                cln_debug_pub.Add('Orig Reference              ---- '||p_orig_ref, 1);
                cln_debug_pub.Add('Partner Document Number     ---- '||p_partner_document_number, 1);
         END IF;

         IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('----------- SETTING DEFAULT VALUES ----------', 1);
         END IF;

         l_rosettanet_check_required  := 'TRUE'     ;
         l_doc_status                 := 'SUCCESS'  ;

         -- get a unique key for raising update collaboration event.
         SELECT  cln_generic_s.nextval INTO l_event_key FROM dual;

         IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Finding the delivery number corresponding to the delivery doc id', 1);
         END IF;

         BEGIN
                SELECT entity_number
                INTO l_entity_number
                FROM wsh_transactions_history
                WHERE document_number = p_delivery_doc_id
                AND document_direction = 'O';

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Delivery Number found as '||l_entity_number, 1);
                END IF;
         EXCEPTION
                WHEN NO_DATA_FOUND THEN
                     FND_MESSAGE.SET_NAME('CLN','CLN_WSH_TRANS_NF');
                     l_msg_data := FND_MESSAGE.GET;
                     IF (l_Debug_Level <= 1) THEN
                             cln_debug_pub.Add('Unable to find the transaction for the document id -'||p_delivery_doc_id,1);
                     END IF;
                     RAISE FND_API.G_EXC_ERROR;

                WHEN TOO_MANY_ROWS THEN
                     FND_MESSAGE.SET_NAME('CLN','CLN_WSH_TRANS_NOT_UNIQUE');
                     l_msg_data := FND_MESSAGE.GET;
                     IF (l_Debug_Level <= 1) THEN
                             cln_debug_pub.Add('More then one row found for the same documnet id -'||p_delivery_doc_id,1);
                     END IF;
                     RAISE FND_API.G_EXC_ERROR;
         END;


         l_cln_ch_parameters := wf_parameter_list_t();

         IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('-------- SETTING EVENT PARAMETERS -----------', 1);
         END IF;

         WF_EVENT.AddParameterToList('DOCUMENT_STATUS', l_doc_status, l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('ORIGINATOR_REFERENCE', p_orig_ref, l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('MESSAGE_TEXT', 'CLN_WSH_SHIPCONF_CONSUMD', l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('ROSETTANET_CHECK_REQUIRED',l_rosettanet_check_required,l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('DOCUMENT_NO',l_entity_number,l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('DOCUMENT_CREATION_DATE',to_char(SYSDATE,'YYYY-MM-DD HH24:MI:SS'),l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('PARTNER_DOCUMENT_NO',p_partner_document_number,l_cln_ch_parameters);
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
   --    REQ_ORDER_INF
   -- Purpose
   --    This API checks for the repeating tag value of RequestingOrderInformation and
   --    based on few parameters decides the value for other tags.
   --
   -- Arguments
   --
   -- Notes
   --    No specific notes.

   PROCEDURE REQ_ORDER_INF(
         x_return_status                IN OUT NOCOPY VARCHAR2,
         x_msg_data                     IN OUT NOCOPY VARCHAR2,
         p_gb_doc_code                  IN VARCHAR2,
         p_gb_partner_role              IN VARCHAR2,
         p_doc_identifier               IN VARCHAR2,
         x_cust_po_number               IN OUT NOCOPY VARCHAR2,
         x_delivery_name                IN OUT NOCOPY VARCHAR2 )
   IS
         l_error_code                   NUMBER;
         l_error_msg                    VARCHAR2(255);
         l_msg_data                     VARCHAR2(255);

   BEGIN

         IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('-------- ENTERING REQ_ORDER_INF ------------', 2);
         END IF;


         IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('----------- PARAMETERS OBTAINED ----------',1);
                cln_debug_pub.Add('GlobalDocumentReferenceTypeCode      ---- '||p_gb_doc_code,1);
                cln_debug_pub.Add('GlobalPartnerRoleClassificationCode  ---- '||p_gb_partner_role,1);
                cln_debug_pub.Add('ProprietaryDocumentIdentifier        ---- '||p_doc_identifier,1);
                cln_debug_pub.Add('------------------------------------------',1);
         END IF;

         IF ((p_gb_doc_code = 'Purchase Order') AND (p_gb_partner_role = 'Customer')) THEN
                x_cust_po_number := p_doc_identifier;
         END IF;

         IF ((p_gb_doc_code = 'Waybill') AND (p_gb_partner_role = 'Shipping Provider')) THEN
                x_delivery_name  := p_doc_identifier;
         END IF;

         IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('--------- EXITING REQ_ORDER_INF -------------', 2);
         END IF;

   EXCEPTION
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
                cln_debug_pub.Add('----------- ERROR:EXITING REQ_ORDER_INF ------------', 2);
            END IF;

   END REQ_ORDER_INF;


   -- Name
   --    UPDATE_NEW_DEL_INTERFACE
   -- Purpose
   --    This API updates the wsh_new_del_interface table with the waybill
   --    based on the delivery interface id inputted.
   --
   -- Arguments
   --
   -- Notes
   --    No specific notes.

   PROCEDURE UPDATE_NEW_DEL_INTERFACE(
         x_return_status                IN OUT NOCOPY VARCHAR2,
         x_msg_data                     IN OUT NOCOPY VARCHAR2,
         p_delivery_interface_id        IN VARCHAR2,
         p_delivery_name                IN VARCHAR2,
         p_waybill                      IN VARCHAR2 )

   IS
         l_error_code                   NUMBER;
         l_error_msg                    VARCHAR2(255);
         l_msg_data                     VARCHAR2(255);
         l_delivery_name                VARCHAR2(200);

   BEGIN

         IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('-------- ENTERING UPDATE_NEW_DEL_INTERFACE ------------', 2);
         END IF;


         IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('----------- PARAMETERS OBTAINED ----------',1);
                cln_debug_pub.Add('Delivery Interface ID                ---- '||p_delivery_interface_id,1);
                cln_debug_pub.Add('Document Number                      ---- '||p_delivery_name,1);
                cln_debug_pub.Add('Waybill                              ---- '||p_waybill,1);
                cln_debug_pub.Add('------------------------------------------',1);
         END IF;


         IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Finding the delivery number corresponding to the delivery doc id', 1);
         END IF;

         BEGIN
                SELECT entity_number
                INTO l_delivery_name
                FROM wsh_transactions_history
                WHERE document_number = p_delivery_name
                AND document_direction = 'O'
                AND rownum < 2;

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Delivery Name/Number found as '||l_delivery_name, 1);
                END IF;
         EXCEPTION
                WHEN NO_DATA_FOUND THEN
                     FND_MESSAGE.SET_NAME('CLN','CLN_WSH_TRANS_NF');
                     l_msg_data := FND_MESSAGE.GET;
                     IF (l_Debug_Level <= 1) THEN
                             cln_debug_pub.Add('Unable to find the transaction for the document number (of transaction history) -'||p_delivery_name,1);
                     END IF;
                     RAISE FND_API.G_EXC_ERROR;

                WHEN TOO_MANY_ROWS THEN
                     FND_MESSAGE.SET_NAME('CLN','CLN_WSH_TRANS_NOT_UNIQUE');
                     l_msg_data := FND_MESSAGE.GET;
                     IF (l_Debug_Level <= 1) THEN
                             cln_debug_pub.Add('More then one row found for the same documnet number  (of transaction history) -'||p_delivery_name,1);
                     END IF;
                     RAISE FND_API.G_EXC_ERROR;
         END;

         UPDATE WSH_NEW_DEL_INTERFACE
         SET WAYBILL                    = p_waybill,
             NAME                       = l_delivery_name
         WHERE DELIVERY_INTERFACE_ID    = p_delivery_interface_id ;

         IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('--------- EXITING UPDATE_NEW_DEL_INTERFACE -------------', 2);
         END IF;

   EXCEPTION
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
                cln_debug_pub.Add('----------- ERROR:EXITING UPDATE_NEW_DEL_INTERFACE ------------', 2);
            END IF;

   END UPDATE_NEW_DEL_INTERFACE;

END CLN_NOTIFY_SHIPCONF_PKG;

/
