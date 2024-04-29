--------------------------------------------------------
--  DDL for Package Body CLN_WSH_SHIP_ORDER_OUT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CLN_WSH_SHIP_ORDER_OUT_PKG" AS
/* $Header: CLNWSHSB.pls 115.4 2004/02/04 10:09:38 kkram noship $ */
-- Package
--   CLN_WSH_SO_PKG
--
-- Purpose
--    Specification of package body: CLN_WSH_SO_PKG.
--    This package bunbles all the procedures
--    required for 3B12 Shipping implementation
--
-- History
--    Oct-6-2003       Viswanthan Umapathy         Created


l_debug_level        NUMBER := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));

   -- Name
   --    CREATE_COLLABORATION
   -- Purpose
   --    creates a new collaboration in the collaboration history
   -- Arguments
   --
   -- Notes
   --    No specific notes

      PROCEDURE CREATE_COLLABORATION(
         x_return_status             OUT NOCOPY VARCHAR2,
         x_msg_data                  OUT NOCOPY VARCHAR2,
         p_delivery_number           IN VARCHAR2,
         p_tp_type                   IN VARCHAR2,
         p_tp_id                     IN VARCHAR2,
         p_tp_site_id                IN VARCHAR2,
         p_doc_dir                   IN VARCHAR2,
         p_txn_type                  IN VARCHAR2,
         p_txn_subtype               IN VARCHAR2,
         p_xmlg_doc_id               IN VARCHAR2,
         p_doc_creation_date         IN DATE,
         p_appl_ref_id               IN VARCHAR2,
         p_int_ctl_num               IN VARCHAR2)
      IS
         PRAGMA AUTONOMOUS_TRANSACTION;
         l_return_status    VARCHAR2(1000);
         l_return_msg       VARCHAR2(2000);
         l_debug_mode       VARCHAR2(300);
         l_error_code       NUMBER;
         l_error_msg        VARCHAR2(2000);
         l_tp_id            NUMBER;
         l_msg_text         VARCHAR2(1000);
         l_cln_ch_parameters  wf_parameter_list_t;
         l_event_key          NUMBER;
         l_entity_number    VARCHAR2(30);
      BEGIN
         -- Sets the debug mode to be FILE
         l_debug_mode := cln_debug_pub.Set_Debug_Mode('FILE');

         SAVEPOINT SO_PROCESSING_TXN;

         --  Initialize API return status to success
         x_return_status := FND_API.G_RET_STS_SUCCESS;

         FND_MESSAGE.SET_NAME('CLN','CLN_G_RET_MSG_SUCCESS');
         x_msg_data := FND_MESSAGE.GET;

         IF (l_Debug_Level <= 2) THEN
            cln_debug_pub.Add('ENTERING CREATE_COLLABORATION', 2);
         END IF;

         -- Parameters List
         IF (l_Debug_Level <= 1) THEN
            cln_debug_pub.Add('With the following parameters:', 1);
            cln_debug_pub.Add('p_delivery_number:'   || p_delivery_number, 1);
            cln_debug_pub.Add('p_tp_type:'           || p_tp_type, 1);
            cln_debug_pub.Add('p_tp_id:'             || p_tp_id, 1);
            cln_debug_pub.Add('p_tp_site_id:'        || p_tp_site_id, 1);
            cln_debug_pub.Add('p_doc_dir:'           || p_doc_dir, 1);
            cln_debug_pub.Add('p_txn_type:'          || p_txn_type, 1);
            cln_debug_pub.Add('p_txn_subtype:'       || p_txn_subtype, 1);
            cln_debug_pub.Add('p_xmlg_doc_id:'       || p_xmlg_doc_id, 1);
            cln_debug_pub.Add('p_doc_creation_date:' || p_doc_creation_date, 1);
            cln_debug_pub.Add('p_appl_ref_id:'       || p_appl_ref_id, 1);
         END IF;

         SELECT cln_generic_s.nextval INTO l_event_key FROM dual;

         l_cln_ch_parameters := wf_parameter_list_t();

         -- This query can never fail
         SELECT ENTITY_NUMBER
         INTO   l_entity_number
         FROM   WSH_TRANSACTIONS_HISTORY
         WHERE  ENTITY_TYPE ='DLVY'
            AND DOCUMENT_NUMBER = p_delivery_number
            AND ROWNUM < 2;


         -- Set event parameters
         WF_EVENT.AddParameterToList('DOCUMENT_NO', l_entity_number, l_cln_ch_parameters);     --l_entity_number holds delivery number. p_delivery_number holds shipping document number in wsh_transactions_history

         WF_EVENT.AddParameterToList('TRADING_PARTNER_TYPE', p_tp_type, l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('TRADING_PARTNER_ID', p_tp_id, l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('TRADING_PARTNER_SITE', p_tp_site_id, l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('DOCUMENT_DIRECTION', p_doc_dir, l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('XMLG_INTERNAL_TXN_TYPE', p_txn_type, l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('XMLG_INTERNAL_TXN_SUBTYPE', p_txn_subtype, l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('XMLG_DOCUMENT_ID', p_xmlg_doc_id, l_cln_ch_parameters);

         WF_EVENT.AddParameterToList('DOCUMENT_CREATION_DATE', to_char(p_doc_creation_date, 'YYYY-MM-DD HH24:MI:SS'), l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('REFERENCE_ID', p_appl_ref_id, l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('XMLG_INTERNAL_CONTROL_NUMBER', p_int_ctl_num, l_cln_ch_parameters);

         -- Raise create collaboration event
         WF_EVENT.Raise('oracle.apps.cln.ch.collaboration.create',
                          l_event_key, NULL, l_cln_ch_parameters, NULL);

         IF (l_Debug_Level <= 1) THEN
            cln_debug_pub.Add('Workflow event- oracle.apps.cln.ch.collaboration.create raised', 1);
         END IF;

         COMMIT;

         IF (l_Debug_Level <= 2) THEN
            cln_debug_pub.Add('EXITING CREATE_COLLABORATION', 2);
         END IF;

      EXCEPTION
         WHEN OTHERS THEN
            ROLLBACK;
            IF (l_Debug_Level <= 6) THEN
               cln_debug_pub.Add('Rolledback the autonomous transaction');
            END IF;
            l_error_code    := SQLCODE;
            l_error_msg     := SQLERRM;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            x_msg_data      := l_error_code||' : '||l_error_msg;
            IF (l_Debug_Level <= 6) THEN
               cln_debug_pub.Add(x_msg_data, 6);
            END IF;
            x_msg_data := 'While trying to create a collaboration'
                                    || ' for 3B12 outbound document delivery number '
                                    || l_entity_number
                                    || ', the following error is encountered:'
                                    || x_msg_data;
            IF (l_Debug_Level <= 2) THEN
               cln_debug_pub.Add('EXITING CREATE_COLLABORATION', 2);
            END IF;
      END CREATE_COLLABORATION;



   -- Name
   --    UPDATE_COLLABORATION
   -- Purpose
   --    Updates the collaboration in the collaboration history
   -- Arguments
   --
   -- Notes
   --    No specific notes

      PROCEDURE UPDATE_COLLABORATION(
         x_return_status             OUT NOCOPY VARCHAR2,
         x_msg_data                  OUT NOCOPY VARCHAR2,
         p_delivery_number           IN VARCHAR2,
         p_tp_type                   IN VARCHAR2,
         p_tp_id                     IN VARCHAR2,
         p_tp_site_id                IN VARCHAR2,
         p_doc_dir                   IN VARCHAR2,
         p_txn_type                  IN VARCHAR2,
         p_txn_subtype               IN VARCHAR2,
         p_xmlg_doc_id               IN VARCHAR2,
         p_appl_ref_id               IN VARCHAR2,
         p_int_ctrl_num              IN VARCHAR2)
      IS
         l_return_status    VARCHAR2(1000);
         l_return_msg       VARCHAR2(2000);
         l_debug_mode       VARCHAR2(300);
         l_error_code       NUMBER;
         l_error_msg        VARCHAR2(2000);
         l_msg_text         VARCHAR2(2000);
         l_cln_ch_parameters  wf_parameter_list_t;
         l_event_key          NUMBER;
         l_entity_number    VARCHAR2(30);

      BEGIN
         -- Sets the debug mode to be FILE
         l_debug_mode := cln_debug_pub.Set_Debug_Mode('FILE');

         --  Initialize API return status to success
         x_return_status := FND_API.G_RET_STS_SUCCESS;

         FND_MESSAGE.SET_NAME('CLN','CLN_SHIP_ORDER_REQ_RN_GEN');
         -- Ship Order Request Generated
         l_msg_text := FND_MESSAGE.GET;

         IF (l_Debug_Level <= 2) THEN
            cln_debug_pub.Add('ENTERING UPDATE_COLLABORATION', 2);
         END IF;

         -- Parameters List
         IF (l_Debug_Level <= 1) THEN
            cln_debug_pub.Add('With the following parameters:', 1);
            cln_debug_pub.Add('p_delivery_number:'   || p_delivery_number, 1);
            cln_debug_pub.Add('p_tp_type:'           || p_tp_type, 1);
            cln_debug_pub.Add('p_tp_id:'             || p_tp_id, 1);
            cln_debug_pub.Add('p_tp_site_id:'        || p_tp_site_id, 1);
            cln_debug_pub.Add('p_doc_dir:'           || p_doc_dir, 1);
            cln_debug_pub.Add('p_txn_type:'          || p_txn_type, 1);
            cln_debug_pub.Add('p_txn_subtype:'       || p_txn_subtype, 1);
            cln_debug_pub.Add('p_xmlg_doc_id:'       || p_xmlg_doc_id, 1);
            cln_debug_pub.Add('p_appl_ref_id:'       || p_appl_ref_id, 1);
            cln_debug_pub.Add('p_int_ctrl_num:'      || p_int_ctrl_num, 1);
         END IF;

         -- This query can never fail
         SELECT ENTITY_NUMBER
         INTO   l_entity_number
         FROM   WSH_TRANSACTIONS_HISTORY
         WHERE  ENTITY_TYPE ='DLVY'
            AND DOCUMENT_NUMBER = p_delivery_number
            AND ROWNUM < 2;

         SELECT cln_generic_s.nextval INTO l_event_key FROM dual;

         l_cln_ch_parameters := wf_parameter_list_t();

         -- Set event parameters
         WF_EVENT.AddParameterToList('XMLG_INTERNAL_CONTROL_NUMBER', p_int_ctrl_num, l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('REFERENCE_ID', p_appl_ref_id, l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('TRADING_PARTNER_TYPE', p_tp_type, l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('TRADING_PARTNER_ID', p_tp_id, l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('TRADING_PARTNER_SITE', p_tp_site_id, l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('DOCUMENT_DIRECTION', p_doc_dir, l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('XMLG_INTERNAL_TXN_TYPE', p_txn_type, l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('XMLG_INTERNAL_TXN_SUBTYPE', p_txn_subtype, l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('XMLG_DOCUMENT_ID', p_xmlg_doc_id, l_cln_ch_parameters);
         -- WF_EVENT.AddParameterToList('ORIGINATOR_REFERENCE', p_delivery_number, l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('MESSAGE_TEXT', l_msg_text, l_cln_ch_parameters);

         -- Raise update collaboration event
         WF_EVENT.Raise('oracle.apps.cln.ch.collaboration.update',
                          l_event_key, NULL, l_cln_ch_parameters, NULL);
         cln_debug_pub.Add('Workflow event- oracle.apps.cln.ch.collaboration.update raised', 1);

         IF (l_Debug_Level <= 2) THEN
            cln_debug_pub.Add('EXITING UPDATE_COLLABORATION', 2);
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            ROLLBACK;
            IF (l_Debug_Level <= 6) THEN
               cln_debug_pub.Add('Rolledback the autonomous transaction');
            END IF;
            l_error_code    := SQLCODE;
            l_error_msg     := SQLERRM;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            x_msg_data      := l_error_code||' : '||l_error_msg;
            IF (l_Debug_Level <= 6) THEN
               cln_debug_pub.Add(x_msg_data, 3);
            END IF;
            x_msg_data := 'While trying to update the collaboration'
                                    || ' for 3B12 outbound document delivery number '
                                    || l_entity_number
                                    || ', the following error is encountered:'
                                    || x_msg_data;
            IF (l_Debug_Level <= 2) THEN
               cln_debug_pub.Add('EXITING UPDATE_COLLABORATION', 2);
            END IF;
      END UPDATE_COLLABORATION;



   -- Name
   --    GET_DELIVERY_INFORMATION
   -- Purpose
   --    Gets the required additional delievry information
   --    for a Delivery Document Number
   -- Arguments
   --    Delivery Document Number
   -- Notes
   --    No specific notes

      PROCEDURE GET_DELIVERY_INFORMATION(
         x_return_status             OUT NOCOPY VARCHAR2,
         x_msg_data                  OUT NOCOPY VARCHAR2,
         p_document_number           IN VARCHAR2,
         x_customer_po_number        OUT NOCOPY VARCHAR2,
         x_customer_id               OUT NOCOPY NUMBER,
         x_delivery_creation_date    OUT NOCOPY DATE)
      IS
         l_debug_mode       VARCHAR2(300);
         l_error_code       NUMBER;
         l_error_msg        VARCHAR2(2000);
      BEGIN
         -- Sets the debug mode to be FILE
         l_debug_mode := cln_debug_pub.Set_Debug_Mode('FILE');

         --  Initialize API return status to success
         x_return_status := FND_API.G_RET_STS_SUCCESS;

         IF (l_Debug_Level <= 2) THEN
            cln_debug_pub.Add('ENTERING GET_DELIVERY_INFORMATION', 2);
         END IF;

         -- Parameters List
         IF (l_Debug_Level <= 1) THEN
            cln_debug_pub.Add('With the following parameters:', 1);
            cln_debug_pub.Add('p_document_number:'   || p_document_number, 1);
         END IF;

         SELECT WDD.CUST_PO_NUMBER, WDD.CUSTOMER_ID, WND.CREATION_DATE
         INTO   x_customer_po_number, x_customer_id, x_delivery_creation_date
         FROM   WSH_NEW_DELIVERIES WND,
                WSH_TRANSACTIONS_HISTORY WTH,
                WSH_DELIVERY_DETAILS WDD,
                WSH_DELIVERY_ASSIGNMENTS WDA
         WHERE  WTH.ENTITY_NUMBER = WND.NAME
            AND WTH.ENTITY_TYPE ='DLVY'
            AND WTH.DOCUMENT_DIRECTION = 'O'
            AND WTH.DOCUMENT_NUMBER = P_DOCUMENT_NUMBER
            AND WDD.CONTAINER_FLAG = 'N'
            AND WDD.DELIVERY_DETAIL_ID = WDA.DELIVERY_DETAIL_ID
            AND WDA.DELIVERY_ID = WND.DELIVERY_ID
            AND ROWNUM < 2;

         IF (l_Debug_Level <= 1) THEN
            cln_debug_pub.Add('x_customer_po_number:'   || x_customer_po_number, 1);
            cln_debug_pub.Add('x_customer_id:'   || x_customer_id, 1);
            cln_debug_pub.Add('x_delivery_creation_date:'   || x_delivery_creation_date, 1);
         END IF;

         IF (l_Debug_Level <= 2) THEN
            cln_debug_pub.Add('EXITING GET_DELIVERY_INFORMATION', 2);
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            l_error_code    := SQLCODE;
            l_error_msg     := SQLERRM;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            x_msg_data      := l_error_code||' : '||l_error_msg;
            IF (l_Debug_Level <= 6) THEN
               cln_debug_pub.Add(x_msg_data, 3);
            END IF;
            x_msg_data := 'While trying to retrieve the additional delivery information'
                                    || ' for a 3B12 outbound document delivery number '
                                    || p_document_number
                                    || ', the following error is encountered:'
                                    || x_msg_data;
            IF (l_Debug_Level <= 2) THEN
               cln_debug_pub.Add('EXITING GET_DELIVERY_INFORMATION', 2);
            END IF;
      END GET_DELIVERY_INFORMATION;



   -- Name
   --    GET_FROM_ROLE_ORG_ID
   -- Purpose
   --    Gets the Organization ID for a given Delivery Document Number
   -- Arguments
   --    Delivery Document Number
   -- Notes
   --    No specific notes

   FUNCTION GET_FROM_ROLE_ORG_ID
   (P_DOCUMENT_NUMBER IN  NUMBER)
   RETURN  NUMBER
   IS
      l_org_id   NUMBER DEFAULT 0;
      l_return_msg       VARCHAR2(2000);
      l_debug_mode       VARCHAR2(300);
      l_error_code       NUMBER;
      l_error_msg        VARCHAR2(2000);
   BEGIN

      -- Sets the debug mode to be FILE
      l_debug_mode := cln_debug_pub.Set_Debug_Mode('FILE');

      IF (l_Debug_Level <= 2) THEN
         cln_debug_pub.Add('ENTERING GET_FROM_ROLE_ORG_ID', 2);
      END IF;

      -- Parameters List
      IF (l_Debug_Level <= 1) THEN
         cln_debug_pub.Add('With the following parameters:', 1);
         cln_debug_pub.Add('P_DOCUMENT_NUMBER:'   || P_DOCUMENT_NUMBER, 1);
      END IF;

      SELECT WND.ORGANIZATION_ID
      INTO   l_org_id
      FROM   WSH_NEW_DELIVERIES WND,
             WSH_TRANSACTIONS_HISTORY WTH
      WHERE  WTH.ENTITY_NUMBER = WND.NAME
        AND  WTH.ENTITY_TYPE ='DLVY'
        AND  WTH.DOCUMENT_DIRECTION = 'O'
        AND  WTH.DOCUMENT_NUMBER = P_DOCUMENT_NUMBER;

      IF (l_Debug_Level <= 1) THEN
         cln_debug_pub.Add('l_org_id:' || l_org_id, 1);
      END IF;

      IF (l_Debug_Level <= 2) THEN
         cln_debug_pub.Add('EXITING GET_FROM_ROLE_ORG_ID', 2);
      END IF;

      RETURN l_org_id;
   EXCEPTION
      WHEN OTHERS THEN
         l_error_code    := SQLCODE;
         l_error_msg     := SQLERRM;
         l_return_msg      := l_error_code||' : '||l_error_msg;
         IF (l_Debug_Level <= 6) THEN
            cln_debug_pub.Add(l_return_msg, 3);
         END IF;
         l_return_msg := 'While trying to get the organizationid '
                                    || ' for 3B12 outbound document delivery number '
                                    || P_DOCUMENT_NUMBER
                                    || ', the following error is encountered:'
                                    || l_return_msg;
         IF (l_Debug_Level <= 2) THEN
            cln_debug_pub.Add('EXITING GET_FROM_ROLE_ORG_ID', 2);
         END IF;
         RETURN l_org_id;
   END GET_FROM_ROLE_ORG_ID;



   -- Name
   --    GET_TO_ROLE_LOCATION_ID
   -- Purpose
   --    Gets the toRole Location ID for a given Delivery Document Number
   -- Arguments
   --    Delivery Document Number
   -- Notes
   --    No specific notes

   FUNCTION GET_TO_ROLE_LOCATION_ID
   (P_DOCUMENT_NUMBER IN  NUMBER)
   RETURN  NUMBER
   IS
      l_loc_id   NUMBER DEFAULT 0;
      l_return_msg       VARCHAR2(2000);
      l_debug_mode       VARCHAR2(300);
      l_error_code       NUMBER;
      l_error_msg        VARCHAR2(2000);
   BEGIN

      -- Sets the debug mode to be FILE
      l_debug_mode := cln_debug_pub.Set_Debug_Mode('FILE');

      IF (l_Debug_Level <= 2) THEN
         cln_debug_pub.Add('ENTERING GET_TO_ROLE_LOCATION_ID', 2);
      END IF;

      -- Parameters List
      IF (l_Debug_Level <= 1) THEN
         cln_debug_pub.Add('With the following parameters:', 1);
         cln_debug_pub.Add('P_DOCUMENT_NUMBER:'   || P_DOCUMENT_NUMBER, 1);
      END IF;

      SELECT WND.INITIAL_PICKUP_LOCATION_ID
      INTO   l_loc_id
      FROM   WSH_NEW_DELIVERIES WND,
             WSH_TRANSACTIONS_HISTORY WTH
      WHERE  WTH.ENTITY_NUMBER = WND.NAME
        AND  WTH.ENTITY_TYPE ='DLVY'
        AND  WTH.DOCUMENT_DIRECTION = 'O'
        AND  WTH.DOCUMENT_NUMBER = P_DOCUMENT_NUMBER;

      IF (l_Debug_Level <= 1) THEN
         cln_debug_pub.Add('l_loc_id:' || l_loc_id, 1);
      END IF;

      IF (l_Debug_Level <= 2) THEN
         cln_debug_pub.Add('EXITING GET_TO_ROLE_LOCATION_ID', 2);
      END IF;
      RETURN l_loc_id;
   EXCEPTION
      WHEN OTHERS THEN
         l_error_code    := SQLCODE;
         l_error_msg     := SQLERRM;
         l_return_msg      := l_error_code||' : '||l_error_msg;
         IF (l_Debug_Level <= 6) THEN
            cln_debug_pub.Add(l_return_msg, 3);
         END IF;
         l_return_msg := 'While trying to get the toRole Location ID '
                                    || ' for 3B12 outbound document delivery number '
                                    || P_DOCUMENT_NUMBER
                                    || ', the following error is encountered:'
                                    || l_return_msg;
         IF (l_Debug_Level <= 2) THEN
            cln_debug_pub.Add('EXITING GET_TO_ROLE_LOCATION_ID', 2);
         END IF;
         RETURN l_loc_id;
   END GET_TO_ROLE_LOCATION_ID;

END CLN_WSH_SHIP_ORDER_OUT_PKG;

/
