--------------------------------------------------------
--  DDL for Package Body RCV_EXTERNAL_INTERFACE_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_EXTERNAL_INTERFACE_SV" AS
/* $Header: RCVRSEVB.pls 120.0.12010000.6 2010/01/25 23:41:50 vthevark noship $ */

g_asn_debug       VARCHAR2(1)  := asn_debug.is_debug_on; -- Bug 9152790

G_PKG_NAME CONSTANT VARCHAR2(50) := 'RCV_EXTERNAL_INTERFACE_SV';


   /*===========================================================================
   |                                                                           |
   | PROCEDURE NAME   Raise_Event                                              |
   |                                                                           |
   | DESCRIPTION      This procedure raises an event in Work Flow.  It raises  |
   |                  an appropriate procedure depending on the parameters     |
   |                  passed.                                                  |
   |                                                                           |
   | MODIFICATION HISTORY                                                      |
   |                                                                           |
   | 24-Dec-09        Sunil Mididuddi    Created                               |
   |                                                                           |
   ============================================================================*/

   PROCEDURE Raise_Event ( P_txn_hist_record   IN     RCV_TRANSACTIONS_HISTORY_PKG.Txns_History_Record_Type,
                           P_xml_document_id   IN     NUMBER,
                           x_return_status     IN OUT NOCOPY  VARCHAR2)
   IS

      l_event_name VARCHAR2 (120);
      l_event_key  VARCHAR2 (30);

      l_return_status    VARCHAR2 (1);
      l_Transaction_Code VARCHAR2 (100);
      l_Org_ID           NUMBER;
      l_Party_Site_ID    NUMBER;
      l_txns_id          NUMBER := NULL;
      l_xml_document_id  NUMBER;

      l_msg_parameter_list  WF_PARAMETER_LIST_T;
      l_txn_hist_record RCV_TRANSACTIONS_HISTORY_PKG.Txns_History_Record_Type;

      l_wms_deployment_mode     varchar2(1);

      invalid_event_name  EXCEPTION;
      update_history      EXCEPTION;

   BEGIN

      IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('Entering RCV_EXTERNAL_INTERFACE_SV.Raise_Event Call');
          asn_debug.put_line('transaction_id is ' || P_txn_hist_record.transaction_id);
          asn_debug.put_line('transaction_status is ' || P_txn_hist_record.transaction_status);
     END IF;

      x_return_status := rcv_error_pkg.g_ret_sts_success;

      l_txn_hist_record := P_txn_hist_record;
      l_xml_document_id := P_xml_document_id;


      -- Get the event name from the Transaction History Table.
      l_event_name := l_txn_hist_record.Event_Name;

      -- Check if the event name is valid or not.

      IF ( l_event_name NOT IN ('oracle.apps.po.standalone.rcpto') ) THEN
         RAISE invalid_event_name;
      END IF;

      l_Transaction_Code := UPPER (SUBSTRB (l_event_name, INSTRB(l_Event_Name, '.', -1) + 1));

      IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('Transaction Code is ' || l_transaction_code);
      END If;

      l_event_key := l_txn_hist_record.Event_Key;
      l_wms_deployment_mode := WMS_DEPLOY.WMS_DEPLOYMENT_MODE;


      IF ( l_Transaction_Code in ('RCPTO') ) THEN --{

         IF (l_wms_deployment_mode = 'L') then

          SELECT trading_partner_site_id
          INTO l_Party_Site_ID
          FROM mtl_client_parameters
          WHERE client_id IN (SELECT cust_account_id
                              FROM hz_cust_accounts
                              WHERE party_id = P_txn_hist_record.trading_partner_id);


         ELSE

          l_Party_Site_ID  := P_txn_hist_record.trading_partner_id;

         END IF;


         IF (g_asn_debug = 'Y') THEN
             asn_debug.put_line('trading_partner_site_id is '||l_Party_Site_ID);
         END IF;

      END IF; --}


     IF ( l_wms_deployment_mode = 'L') then

         WF_EVENT.AddParameterToList (p_name  => 'ECX_PARTY_ID',
                                      p_value => l_txn_hist_record.Trading_Partner_ID,
                                      p_parameterlist => l_msg_parameter_list);

         WF_EVENT.AddParameterToList (p_name  => 'ECX_PARTY_SITE_ID',
                                      p_value => l_Party_Site_ID,
                                      p_parameterlist => l_msg_parameter_list);

         WF_EVENT.AddParameterToList (p_name  => 'ECX_PARTY_TYPE',
                                      p_value => 'C',
                                      p_parameterlist => l_msg_parameter_list);
          IF (g_asn_debug = 'Y') THEN
              asn_debug.put_line('Party Type is '|| 'C');
          END IF;

         WF_EVENT.AddParameterToList (p_name  => 'ECX_TRANSACTION_TYPE',
                                         p_value => 'PO',
                                         p_parameterlist => l_msg_parameter_list);
          IF (g_asn_debug = 'Y') THEN
              asn_debug.put_line('Transaction Type is '|| 'PO');
          END IF;


         WF_EVENT.AddParameterToList (p_name  => 'ECX_TRANSACTION_SUBTYPE',
                                         p_value => 'RCPTO',
                                         p_parameterlist => l_msg_parameter_list);
          IF (g_asn_debug = 'Y') THEN
              asn_debug.put_line('Transaction SubType is '|| 'RCPTO');
          END IF;

     ELSE

         WF_EVENT.AddParameterToList (p_name  => 'ECX_PARTY_ID',
                                      p_value => l_txn_hist_record.Trading_Partner_ID,
                                      p_parameterlist => l_msg_parameter_list);

         WF_EVENT.AddParameterToList (p_name  => 'ECX_PARTY_SITE_ID',
                                      p_value => l_Party_Site_ID,
                                      p_parameterlist => l_msg_parameter_list);

         WF_EVENT.AddParameterToList (p_name  => 'ECX_PARTY_TYPE',
                                      p_value => 'I',
                                      p_parameterlist => l_msg_parameter_list);
          IF (g_asn_debug = 'Y') THEN
              asn_debug.put_line('Party Type is '|| 'I');
          END IF;

         WF_EVENT.AddParameterToList (p_name  => 'ECX_TRANSACTION_TYPE',
                                         p_value => 'PO',
                                         p_parameterlist => l_msg_parameter_list);
          IF (g_asn_debug = 'Y') THEN
              asn_debug.put_line('Transaction Type is '|| 'PO');
          END IF;


         WF_EVENT.AddParameterToList (p_name  => 'ECX_TRANSACTION_SUBTYPE',
                                         p_value => 'RCPTO-INT',
                                         p_parameterlist => l_msg_parameter_list);
          IF (g_asn_debug = 'Y') THEN
              asn_debug.put_line('Transaction SubType is '|| 'RCPTO-INT');
          END IF;

      END IF;


         WF_EVENT.AddParameterToList (p_name  => 'ECX_DOCUMENT_ID',
                                      p_value => l_txn_hist_record.Entity_Number, --shipment_header_id
                                      p_parameterlist => l_msg_parameter_list);

          IF (g_asn_debug = 'Y') THEN
              asn_debug.put_line('Document ID is '|| l_txn_hist_record.Entity_Number);
          END IF;


         WF_EVENT.AddParameterToList (p_name  => 'USER_ID',
                               p_value => FND_GLOBAL.USER_ID,
                               p_parameterlist => l_msg_parameter_list);

          IF (g_asn_debug = 'Y') THEN
              asn_debug.put_line('User ID is '|| FND_GLOBAL.USER_ID);
          END IF;

         --
         WF_EVENT.AddParameterToList (p_name  => 'APPLICATION_ID',
                               p_value => FND_GLOBAL.RESP_APPL_ID,
                               p_parameterlist => l_msg_parameter_list);


          IF (g_asn_debug = 'Y') THEN
              asn_debug.put_line('Responsibility Application ID is '|| FND_GLOBAL.RESP_APPL_ID);
          END IF;


         WF_EVENT.AddParameterToList (p_name  => 'RESPONSIBILITY_ID',
                               p_value => FND_GLOBAL.RESP_ID,
                               p_parameterlist => l_msg_parameter_list);

          IF (g_asn_debug = 'Y') THEN
              asn_debug.put_line('Responsibility ID is '|| FND_GLOBAL.RESP_ID);
          END IF;


         WF_EVENT.AddParameterToList (p_name  => 'USER',
                                      p_value => FND_GLOBAL.user_name,
                                      p_parameterlist => l_msg_parameter_list);

          IF (g_asn_debug = 'Y') THEN
              asn_debug.put_line('User_Name is '||FND_GLOBAL.user_name);
          END IF;

         WF_EVENT.AddParameterToList (p_name  => 'ECX_PARAMETER1',
                                      p_value => l_txn_hist_record.Action_Type,
                                      p_parameterlist => l_msg_parameter_list);

         WF_EVENT.AddParameterToList (p_name  => 'ECX_PARAMETER2',
                                      p_value => l_txn_hist_record.Client_Code,
                                      p_parameterlist => l_msg_parameter_list);

          IF (g_asn_debug = 'Y') THEN
              asn_debug.put_line('ECX Parameter1 is '||l_txn_hist_record.Action_Type);
          END IF;

          IF (g_asn_debug = 'Y') THEN
              asn_debug.put_line('ECX Parameter2 is '||l_txn_hist_record.Client_Code);
          END IF;



          SELECT receipt_num
          INTO l_txn_hist_record.Entity_Number
          FROM rcv_shipment_headers
          WHERE shipment_header_id = l_txn_hist_record.Entity_Number;

          IF (g_asn_debug = 'Y') THEN
              asn_debug.put_line('Receipt Number is '||l_txn_hist_record.Entity_Number);
          END IF;

          RCV_TRANSACTIONS_HISTORY_PKG.Create_Update_Txns_History ( l_txn_hist_record,
                                                                    l_xml_document_id,
                                                                    l_txns_id,
                                                                    l_return_status );

          IF (g_asn_debug = 'Y') THEN
              asn_debug.put_line('l_txns_id is '||l_txns_id);
              asn_debug.put_line('l_return_status is '||To_Char(l_Return_Status));
          END IF;

          IF ( l_return_status <> rcv_error_pkg.g_ret_sts_success ) THEN
              IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('Raise_Event.l_Return_Status is '|| l_Return_Status);
              END IF;
              RAISE update_history;
          END IF;

         -- Commit the data into the Transaction History table.
         COMMIT;


      IF ( l_Transaction_Code IN ('RCPTO') ) THEN

          IF (g_asn_debug = 'Y') THEN
              asn_debug.put_line('Raising Business Event');
          END IF;

         WF_EVENT.raise ( p_event_name => l_event_name,
                          p_event_key  => l_event_key,
                          p_parameters => l_msg_parameter_list );

          IF (g_asn_debug = 'Y') THEN
              asn_debug.put_line('Completed the Business Event execution');
          END IF;

      END IF;

      IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('Exiting RCV_EXTERNAL_INTERFACE_SV.Raise_Event call');
      END IF;

   EXCEPTION
      WHEN invalid_event_name THEN
         x_return_status := rcv_error_pkg.g_ret_sts_error;
         IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('invalid_event_name exception has occured.');
         END IF;

      WHEN update_history THEN
         x_return_status := rcv_error_pkg.g_ret_sts_error;
         IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('update_history exception has occured.');
         END IF;

      WHEN OTHERS THEN
         x_return_status := rcv_error_pkg.g_ret_sts_unexp_error;

         IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('Unexpected error has occured. Oracle error message is '|| SQLERRM);
         END IF;

   END Raise_Event;

END RCV_EXTERNAL_INTERFACE_SV;

/
