--------------------------------------------------------
--  DDL for Package Body INV_EXTERNAL_INTERFACE_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_EXTERNAL_INTERFACE_SV" AS
/* $Header: INVRSEVB.pls 120.0.12010000.2 2010/02/03 20:37:04 musinha noship $ */

g_debug      NUMBER :=  NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

G_PKG_NAME CONSTANT VARCHAR2(50) := 'INV_EXTERNAL_INTERFACE_SV';


   /*===========================================================================
   |                                                                           |
   | PROCEDURE NAME   Raise_Event                                              |
   |                                                                           |
   | DESCRIPTION      This procedure raises an event in Work Flow.  It raises  |
   |                  an appropriate procedure depending on the parameters     |
   |                  passed.                                                  |
   |                                                                           |                               |
   |                                                                           |
   ============================================================================*/

   PROCEDURE Raise_Event ( P_txn_hist_record   IN     INV_TRANSACTIONS_HISTORY_PKG.Txns_History_Record_Type,
                           P_xml_document_id   IN     VARCHAR2,
                           x_return_status     IN OUT NOCOPY  VARCHAR2)
   IS

      l_event_name VARCHAR2 (120);
      l_Event_Key  VARCHAR2 (30);

      l_Return_Status    VARCHAR2 (1);
      l_Transaction_Code VARCHAR2 (100);
      l_Org_ID           NUMBER;
      l_Party_Site_ID    NUMBER;
      l_txns_id          NUMBER;
      l_xml_document_id  NUMBER;

      l_msg_parameter_list  WF_PARAMETER_LIST_T;
      l_txn_hist_record INV_TRANSACTIONS_HISTORY_PKG.Txns_History_Record_Type;

      l_wms_deployment_mode     varchar2(1);

      invalid_event_name  EXCEPTION;
      update_history      EXCEPTION;

   BEGIN

      if (g_debug = 1) then
        inv_trx_util_pub.TRACE('Entering INV_EXTERNAL_INTERFACE_SV.Raise_Event', 'INV_EXTERNAL_INTERFACE_SV', 9);
        inv_trx_util_pub.TRACE('transaction_id is ' || P_txn_hist_record.transaction_id, 'INV_EXTERNAL_INTERFACE_SV', 9);
        inv_trx_util_pub.TRACE('transaction_status is ' || P_txn_hist_record.transaction_status, 'INV_EXTERNAL_INTERFACE_SV', 9);
      end if;

      x_return_status := rcv_error_pkg.g_ret_sts_success;

      l_txn_hist_record := P_txn_hist_record;
      l_xml_document_id := P_xml_document_id;

      -- Get the event name from the Transaction History Table.
      l_event_name := l_txn_hist_record.Event_Name;

      -- Check if the event name is valid or not.
      IF ( l_event_name NOT IN ('oracle.apps.inv.standalone.adjo') ) THEN
         RAISE invalid_event_name;
      END IF;


      l_Transaction_Code := UPPER (SUBSTRB (l_event_name, INSTRB(l_Event_Name, '.', -1) + 1));

      if (g_debug = 1) then
            inv_trx_util_pub.TRACE('l_transaction_code is '||l_transaction_code, 'INV_EXTERNAL_INTERFACE_SV', 9);
      end if;

      l_Event_Key := l_txn_hist_record.Event_Key;
      l_wms_deployment_mode := WMS_DEPLOY.WMS_DEPLOYMENT_MODE;


      IF ( l_Transaction_Code in ('ADJO') ) THEN --{
         -- Generate the document number for outgoing documents.


          if (g_debug = 1) then
            inv_trx_util_pub.TRACE('trading_partner_id is '||P_txn_hist_record.trading_partner_id, 'INV_EXTERNAL_INTERFACE_SV', 9);
          end if;

          IF (l_wms_deployment_mode = 'L') THEN

          SELECT trading_partner_site_id
          INTO l_Party_Site_ID
          FROM mtl_client_parameters
          WHERE client_id IN (SELECT cust_account_id
                              FROM hz_cust_accounts
                              WHERE party_id = P_txn_hist_record.trading_partner_id);


         ELSE

          l_Party_Site_ID  := P_txn_hist_record.trading_partner_id;

         END IF;


          if (g_debug = 1) then
            inv_trx_util_pub.TRACE('trading_partner_site_id is '||l_Party_Site_ID, 'INV_EXTERNAL_INTERFACE_SV', 9);
          end if;

      END IF; --}



         WF_EVENT.AddParameterToList (p_name  => 'ECX_PARTY_ID',
                                      p_value => l_txn_hist_record.Trading_Partner_ID,
                                      p_parameterlist => l_msg_parameter_list);

         WF_EVENT.AddParameterToList (p_name  => 'ECX_PARTY_SITE_ID',
                                      p_value => l_Party_Site_ID,
                                      p_parameterlist => l_msg_parameter_list);

         IF ( l_wms_deployment_mode = 'L') then

           WF_EVENT.AddParameterToList (p_name  => 'ECX_PARTY_TYPE',
                                        p_value => 'C',
                                        p_parameterlist => l_msg_parameter_list);

           if (g_debug = 1) then
             inv_trx_util_pub.TRACE('Party Type is C', 'INV_EXTERNAL_INTERFACE_SV', 9);
           end if;

         ELSE

           WF_EVENT.AddParameterToList (p_name  => 'ECX_PARTY_TYPE',
                                        p_value => 'I',
                                        p_parameterlist => l_msg_parameter_list);

           if (g_debug = 1) then
             inv_trx_util_pub.TRACE('Party Type is I', 'INV_EXTERNAL_INTERFACE_SV', 9);
           end if;

         END IF;

         WF_EVENT.AddParameterToList (p_name  => 'ECX_DOCUMENT_ID',
                                      p_value => l_txn_hist_record.Entity_Number, -- entity_id
                                      p_parameterlist => l_msg_parameter_list);
         if (g_debug = 1) then
           inv_trx_util_pub.TRACE('Document ID is '|| l_txn_hist_record.Entity_Number, 'INV_EXTERNAL_INTERFACE_SV', 9);
         end if;


         WF_EVENT.AddParameterToList (p_name  => 'USER_ID',
                               p_value => FND_GLOBAL.USER_ID,
                               p_parameterlist => l_msg_parameter_list);

         if (g_debug = 1) then
           inv_trx_util_pub.TRACE('User ID is '|| FND_GLOBAL.USER_ID, 'INV_EXTERNAL_INTERFACE_SV', 9);
         end if;


         WF_EVENT.AddParameterToList (p_name  => 'APPLICATION_ID',
                               p_value => FND_GLOBAL.RESP_APPL_ID,
                               p_parameterlist => l_msg_parameter_list);

         if (g_debug = 1) then
           inv_trx_util_pub.TRACE('Responsibility Application ID is '|| FND_GLOBAL.RESP_APPL_ID, 'INV_EXTERNAL_INTERFACE_SV', 9);
         end if;


         WF_EVENT.AddParameterToList (p_name  => 'RESPONSIBILITY_ID',
                               p_value => FND_GLOBAL.RESP_ID,
                               p_parameterlist => l_msg_parameter_list);
         if (g_debug = 1) then
           inv_trx_util_pub.TRACE('Responsibility ID is '|| FND_GLOBAL.RESP_ID, 'INV_EXTERNAL_INTERFACE_SV', 9);
         end if;


         WF_EVENT.AddParameterToList (p_name  => 'ECX_TRANSACTION_TYPE',
                                         p_value => 'INV',
                                         p_parameterlist => l_msg_parameter_list);
         if (g_debug = 1) then
           inv_trx_util_pub.TRACE('Transaction Type is '|| 'INV', 'INV_EXTERNAL_INTERFACE_SV', 9);
         end if;


         IF ( l_wms_deployment_mode = 'L') then

            WF_EVENT.AddParameterToList (p_name  => 'ECX_TRANSACTION_SUBTYPE',
                                         p_value => 'ADJ',
                                         p_parameterlist => l_msg_parameter_list);
            if (g_debug = 1) then
               inv_trx_util_pub.TRACE('Transaction SubType is '|| 'ADJ', 'INV_EXTERNAL_INTERFACE_SV', 9);
            end if;

         ELSE

            WF_EVENT.AddParameterToList (p_name  => 'ECX_TRANSACTION_SUBTYPE',
                                         p_value => 'ADJ-INT',
                                         p_parameterlist => l_msg_parameter_list);
            if (g_debug = 1) then
               inv_trx_util_pub.TRACE('Transaction SubType is '|| 'ADJ-INT', 'INV_EXTERNAL_INTERFACE_SV', 9);
            end if;

         END IF;


         WF_EVENT.AddParameterToList (p_name  => 'USER',
                                      p_value => FND_GLOBAL.user_name,
                                      p_parameterlist => l_msg_parameter_list);
         if (g_debug = 1) then
           inv_trx_util_pub.TRACE('User_Name is '||FND_GLOBAL.user_name, 'INV_EXTERNAL_INTERFACE_SV', 9);
         end if;


         WF_EVENT.AddParameterToList (p_name  => 'ECX_PARAMETER1',
                                      p_value => l_txn_hist_record.Entity_Number, --l_txn_hist_record.Action_Type,
                                      p_parameterlist => l_msg_parameter_list);
         if (g_debug = 1) then
           inv_trx_util_pub.TRACE('ECX Parameter1 is '||l_txn_hist_record.Entity_Number, 'INV_EXTERNAL_INTERFACE_SV', 9);
         end if;


         WF_EVENT.AddParameterToList (p_name  => 'ECX_PARAMETER2',
                                      p_value => l_txn_hist_record.Client_Code,
                                      p_parameterlist => l_msg_parameter_list);
         if (g_debug = 1) then
           inv_trx_util_pub.TRACE('ECX Parameter2 is '||l_txn_hist_record.Client_Code, 'INV_EXTERNAL_INTERFACE_SV', 9);
         end if;


          INV_TRANSACTIONS_HISTORY_PKG.Create_Update_Txns_History ( l_txn_hist_record,
                                                                    l_xml_document_id,
                                                                    l_txns_id,
                                                                    l_return_status );


          if (g_debug = 1) then
           inv_trx_util_pub.TRACE('l_txns_id is '||l_txns_id, 'INV_EXTERNAL_INTERFACE_SV', 9);
           inv_trx_util_pub.TRACE('l_return_status is '||To_Char(l_Return_Status), 'INV_EXTERNAL_INTERFACE_SV', 9);
          end if;

          IF ( l_Return_Status <> rcv_error_pkg.g_ret_sts_success ) THEN
	      if (g_debug = 1) then
                inv_trx_util_pub.TRACE('Raise_Event.l_Return_Status is '|| l_Return_Status, 'INV_EXTERNAL_INTERFACE_SV', 9);
              end if;
              RAISE update_history;
          END IF;

         -- Commit the data into the Transaction History table for the views.
         COMMIT;


      IF ( l_Transaction_Code IN ('ADJO') ) THEN

          if (g_debug = 1) then
           inv_trx_util_pub.TRACE('Raising Business Event', 'INV_EXTERNAL_INTERFACE_SV', 9);
          end if;

          WF_EVENT.raise ( p_event_name => l_event_name,
                           p_event_key  => l_Event_Key,
                           p_parameters => l_msg_parameter_list );

          if (g_debug = 1) then
           inv_trx_util_pub.TRACE('Completed the Business Event execution', 'INV_EXTERNAL_INTERFACE_SV', 9);
          end if;

      END IF;

      if (g_debug = 1) then
         inv_trx_util_pub.TRACE('Exiting RCV_EXTERNAL_INTERFACE_SV.Raise_Event', 'INV_EXTERNAL_INTERFACE_SV', 9);
      end if;

   EXCEPTION
      WHEN invalid_event_name THEN
         x_return_status := rcv_error_pkg.g_ret_sts_error;
         if (g_debug = 1) then
           inv_trx_util_pub.TRACE('invalid_event_name exception has occured.', 'INV_EXTERNAL_INTERFACE_SV', 9);
         end if;

      WHEN update_history THEN
         x_return_status := rcv_error_pkg.g_ret_sts_error;
         if (g_debug = 1) then
           inv_trx_util_pub.TRACE('update_history exception has occured.', 'INV_EXTERNAL_INTERFACE_SV', 9);
         end if;

      WHEN OTHERS THEN
         x_return_status := rcv_error_pkg.g_ret_sts_unexp_error;

         if (g_debug = 1) then
           inv_trx_util_pub.TRACE('Unexpected error has occured. Oracle error message is '|| SQLERRM, 'INV_EXTERNAL_INTERFACE_SV', 9);
         end if;

   END Raise_Event;

END INV_EXTERNAL_INTERFACE_SV;

/
