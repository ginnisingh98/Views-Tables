--------------------------------------------------------
--  DDL for Package Body INV_ONHAND_BALANCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_ONHAND_BALANCE" AS
/* $Header: INVEINVB.pls 120.0.12010000.6 2010/04/12 19:40:01 kdong noship $ */

g_debug      NUMBER :=1;--   NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);


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

PROCEDURE Raise_Event ( P_txn_hist_record  IN     INV_TRANSACTIONS_HISTORY_PKG.Txns_History_Record_Type,
                       P_xml_document_id   IN     NUMBER,
                       x_return_status     IN OUT NOCOPY  VARCHAR2)
IS

  l_event_name VARCHAR2 (120);
  l_Event_Key  VARCHAR2 (30);

  l_Return_Status    VARCHAR2 (1);
  l_Transaction_Code VARCHAR2 (100);
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
    inv_trx_util_pub.TRACE('Entering Raise_Event', 'INV_ONHAND_BALANCE', 9);
    inv_trx_util_pub.TRACE('transaction_id is ' || P_txn_hist_record.transaction_id, 'INV_ONHAND_BALANCE', 9);
    inv_trx_util_pub.TRACE('transaction_status is ' || P_txn_hist_record.transaction_status, 'INV_ONHAND_BALANCE', 9);
  end if;

  x_return_status := rcv_error_pkg.g_ret_sts_success;

  l_txn_hist_record := P_txn_hist_record;
  l_xml_document_id := P_xml_document_id;

  -- Get the event name from the Transaction History Table.
  l_event_name := l_txn_hist_record.Event_Name;

  -- Check if the event name is valid or not.
  IF ( l_event_name NOT IN ('oracle.apps.inv.standalone.onhand') ) THEN
     RAISE invalid_event_name;
  END IF;


  l_Transaction_Code := UPPER (SUBSTRB (l_event_name, INSTRB(l_Event_Name, '.', -1) + 1));

  if (g_debug = 1) then
        inv_trx_util_pub.TRACE('l_transaction_code is '||l_transaction_code, 'INV_ONHAND_BALANCE', 9);
  end if;

  l_Event_Key := l_txn_hist_record.Event_Key;
  l_wms_deployment_mode := WMS_DEPLOY.WMS_DEPLOYMENT_MODE;


  IF ( l_Transaction_Code in ('ONHAND') ) THEN --{
     -- Generate the document number for outgoing documents.


      if (g_debug = 1) then
        inv_trx_util_pub.TRACE('trading_partner_id is '||P_txn_hist_record.trading_partner_id, 'INV_ONHAND_BALANCE', 9);
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
        inv_trx_util_pub.TRACE('trading_partner_site_id is '||l_Party_Site_ID, 'INV_ONHAND_BALANCE', 9);
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
         inv_trx_util_pub.TRACE('Party Type is C', 'INV_ONHAND_BALANCE', 9);
       end if;

     ELSE

       WF_EVENT.AddParameterToList (p_name  => 'ECX_PARTY_TYPE',
                                    p_value => 'I',
                                    p_parameterlist => l_msg_parameter_list);

       if (g_debug = 1) then
         inv_trx_util_pub.TRACE('Party Type is I', 'INV_ONHAND_BALANCE', 9);
       end if;

     END IF;

     WF_EVENT.AddParameterToList (p_name  => 'ECX_DOCUMENT_ID',
                                  p_value => l_xml_document_id, --l_txn_hist_record.Entity_Number, -- entity_id
                                  p_parameterlist => l_msg_parameter_list);
     if (g_debug = 1) then
       inv_trx_util_pub.TRACE('Document ID is '|| l_txn_hist_record.Entity_Number, 'INV_ONHAND_BALANCE', 9);
     end if;


     WF_EVENT.AddParameterToList (p_name  => 'USER_ID',
                           p_value => FND_GLOBAL.USER_ID,
                           p_parameterlist => l_msg_parameter_list);

     if (g_debug = 1) then
       inv_trx_util_pub.TRACE('User ID is '|| FND_GLOBAL.USER_ID, 'INV_ONHAND_BALANCE', 9);
     end if;


     WF_EVENT.AddParameterToList (p_name  => 'APPLICATION_ID',
                           p_value => FND_GLOBAL.RESP_APPL_ID,
                           p_parameterlist => l_msg_parameter_list);

     if (g_debug = 1) then
       inv_trx_util_pub.TRACE('Responsibility Application ID is '|| FND_GLOBAL.RESP_APPL_ID, 'INV_ONHAND_BALANCE', 9);
     end if;


     WF_EVENT.AddParameterToList (p_name  => 'RESPONSIBILITY_ID',
                           p_value => FND_GLOBAL.RESP_ID,
                           p_parameterlist => l_msg_parameter_list);
     if (g_debug = 1) then
       inv_trx_util_pub.TRACE('Responsibility ID is '|| FND_GLOBAL.RESP_ID, 'INV_ONHAND_BALANCE', 9);
     end if;


     WF_EVENT.AddParameterToList (p_name  => 'ECX_TRANSACTION_TYPE',
                                     p_value => 'INV',
                                     p_parameterlist => l_msg_parameter_list);
     if (g_debug = 1) then
       inv_trx_util_pub.TRACE('Transaction Type is '|| 'INV', 'INV_ONHAND_BALANCE', 9);
     end if;


     IF ( l_wms_deployment_mode = 'L') then

        WF_EVENT.AddParameterToList (p_name  => 'ECX_TRANSACTION_SUBTYPE',
                                     p_value => 'ONHAND',
                                     p_parameterlist => l_msg_parameter_list);
        if (g_debug = 1) then
           inv_trx_util_pub.TRACE('Transaction SubType is '|| 'ONHAND', 'INV_ONHAND_BALANCE', 9);
        end if;

     ELSE

        WF_EVENT.AddParameterToList (p_name  => 'ECX_TRANSACTION_SUBTYPE',
                                     p_value => 'ONHAND-IN',
                                     p_parameterlist => l_msg_parameter_list);
        if (g_debug = 1) then
           inv_trx_util_pub.TRACE('Transaction SubType is '|| 'ONHAND', 'INV_ONHAND_BALANCE', 9);
        end if;

     END IF;


     WF_EVENT.AddParameterToList (p_name  => 'USER',
                                  p_value => FND_GLOBAL.user_name,
                                  p_parameterlist => l_msg_parameter_list);
     if (g_debug = 1) then
       inv_trx_util_pub.TRACE('User_Name is '||FND_GLOBAL.user_name, 'INV_ONHAND_BALANCE', 9);
     end if;


     WF_EVENT.AddParameterToList (p_name  => 'ECX_PARAMETER1',
                                  p_value => l_txn_hist_record.Entity_Number, --l_txn_hist_record.Action_Type,
                                  p_parameterlist => l_msg_parameter_list);
     if (g_debug = 1) then
       inv_trx_util_pub.TRACE('ECX Parameter1 is '||l_txn_hist_record.Action_Type, 'INV_ONHAND_BALANCE', 9);
     end if;


     WF_EVENT.AddParameterToList (p_name  => 'ECX_PARAMETER2',
                                  p_value => l_txn_hist_record.Client_Code,
                                  p_parameterlist => l_msg_parameter_list);
     if (g_debug = 1) then
       inv_trx_util_pub.TRACE('ECX Parameter2 is '||l_txn_hist_record.Client_Code, 'INV_ONHAND_BALANCE', 9);
     end if;

     INV_TRANSACTIONS_HISTORY_PKG.Create_Update_Txns_History ( l_txn_hist_record,
                                                                l_xml_document_id,
                                                                l_txns_id,
                                                                l_return_status );


      if (g_debug = 1) then
       inv_trx_util_pub.TRACE('l_txns_id is '||l_txns_id, 'INV_ONHAND_BALANCE', 9);
       inv_trx_util_pub.TRACE('l_return_status is '||To_Char(l_Return_Status), 'INV_ONHAND_BALANCE', 9);
      end if;

      IF ( l_Return_Status <> rcv_error_pkg.g_ret_sts_success ) THEN
   if (g_debug = 1) then
            inv_trx_util_pub.TRACE('Raise_Event.l_Return_Status is '|| l_Return_Status, 'INV_ONHAND_BALANCE', 9);
          end if;
          RAISE update_history;
      END IF;

     -- Commit the data into the Transaction History table for the views.
     COMMIT;


  IF ( l_Transaction_Code IN ('ADJO', 'SHLO','ONHAND') ) THEN

      if (g_debug = 1) then
       inv_trx_util_pub.TRACE('Raising Business Event', 'INV_ONHAND_BALANCE', 9);
      end if;

      WF_EVENT.raise ( p_event_name => l_event_name,
                       p_event_key  => l_Event_Key,
                       p_parameters => l_msg_parameter_list );

      if (g_debug = 1) then
       inv_trx_util_pub.TRACE('Completed the Business Event execution', 'INV_ONHAND_BALANCE', 9);
      end if;

  END IF;

  if (g_debug = 1) then
     inv_trx_util_pub.TRACE('Exiting Raise_Event', 'INV_ONHAND_BALANCE', 9);
  end if;

EXCEPTION
  WHEN invalid_event_name THEN
     x_return_status := rcv_error_pkg.g_ret_sts_error;
     if (g_debug = 1) then
       inv_trx_util_pub.TRACE('invalid_event_name exception has occured.', 'INV_ONHAND_BALANCE', 9);
     end if;

  WHEN update_history THEN
     x_return_status := rcv_error_pkg.g_ret_sts_error;
     if (g_debug = 1) then
       inv_trx_util_pub.TRACE('update_history exception has occured.', 'INV_ONHAND_BALANCE', 9);
     end if;

  WHEN OTHERS THEN
     x_return_status := rcv_error_pkg.g_ret_sts_unexp_error;

     if (g_debug = 1) then
       inv_trx_util_pub.TRACE('Unexpected error has occured. Oracle error message is '|| SQLERRM, 'INV_ONHAND_BALANCE', 9);
     end if;

END Raise_Event;

PROCEDURE Send_Onhand_Document( P_Entity_ID        IN  NUMBER,
                                P_Entity_Type      IN  VARCHAR2,
                                P_Action_Type      IN  VARCHAR2,
                                P_Document_Type    IN  VARCHAR2,
                                P_Org_ID           IN  NUMBER,
                                P_client_code      IN  VARCHAR2,
                                p_xml_document_id  IN  NUMBER,
                                X_Return_Status    OUT NOCOPY  VARCHAR2)
   IS

      l_orig_Event_Key          VARCHAR2 (240);
      l_curr_txn_hist_record    inv_transactions_history_pkg.Txns_History_Record_Type;
      l_Return_Status           VARCHAR2 (1);
      l_wms_deployment_mode     VARCHAR2(1);
      l_party_id                NUMBER;
      l_xml_document_id         NUMBER;

      invalid_entity_type        EXCEPTION;
      invalid_action_type        EXCEPTION;
      invalid_doc_type           EXCEPTION;
      raise_event_error          EXCEPTION;

BEGIN


      IF (g_debug = 1) THEN
         inv_trx_util_pub.TRACE('Entering Send_Onhand_Document', 'INV_ONHAND_BALANCE', 9);
         inv_trx_util_pub.TRACE('Entity_ID is ' || P_Entity_ID, 'INV_ONHAND_BALANCE', 9);
         inv_trx_util_pub.TRACE('Action Type is ' || P_Action_Type, 'INV_ONHAND_BALANCE', 9);
         inv_trx_util_pub.TRACE('Doc Type is ' || P_Document_Type, 'INV_ONHAND_BALANCE', 9);
         inv_trx_util_pub.TRACE('p_org_id is ' || P_Org_ID, 'INV_ONHAND_BALANCE', 9);
         inv_trx_util_pub.TRACE('P_client_code is ' || P_client_code, 'INV_ONHAND_BALANCE', 9);
         inv_trx_util_pub.TRACE('p_xml_document_id is ' || p_xml_document_id, 'INV_ONHAND_BALANCE', 9);

      END IF;

      X_Return_Status := rcv_error_pkg.g_ret_sts_success;
      l_xml_document_id := P_xml_document_id;

      IF ( P_Entity_TYPE <> 'INVMOQD' ) THEN
         RAISE invalid_entity_type;
      ELSIF ( P_Action_TYPE <> 'A' ) THEN
         RAISE invalid_action_type;
      ELSIF ( P_Document_TYPE <> 'ONHAND' ) THEN
         RAISE invalid_doc_type;
      END IF;

      SELECT po_wf_itemkey_s.NEXTVAL
      INTO   l_orig_Event_Key
      FROM   DUAL;

      l_curr_txn_hist_record.Document_Type         := P_Document_Type;
      l_curr_txn_hist_record.Document_Direction    := 'O';
      l_curr_txn_hist_record.Entity_Number         := P_Entity_ID;
      l_curr_txn_hist_record.Entity_Type           := P_Entity_TYPE;

      l_curr_txn_hist_record.Event_Name            := 'oracle.apps.inv.standalone.onhand';
      l_curr_txn_hist_record.Item_Type             := 'INVMOQD';
      l_curr_txn_hist_record.Event_Key             := l_orig_Event_Key;
      l_curr_txn_hist_record.Action_Type           := P_Action_Type;
      l_curr_txn_hist_record.Transaction_Status    := 'ST';
      l_curr_txn_hist_record.Document_Number       := l_xml_document_id; --P_Entity_ID;

      l_wms_deployment_mode := wms_deploy.wms_deployment_mode;

      inv_trx_util_pub.TRACE('l_wms_deployment_mode ' || l_wms_deployment_mode, 'INV_ONHAND_BALANCE', 9);

      If (l_wms_deployment_mode = 'L') then

      l_curr_txn_hist_record.Client_Code           := P_client_code;

      SELECT party_id
      INTO l_party_id
      FROM hz_cust_accounts
      WHERE cust_account_id IN (SELECT client_id
                                FROM mtl_client_parameters
                                WHERE client_code = P_client_code);
      else

      select location_id
      into l_party_id
      from hr_organization_units_v
      where organization_id = P_Org_ID
      and rownum = 1;

      END If;

      l_curr_txn_hist_record.Trading_Partner_ID    := l_party_id;


      IF (g_debug = 1) THEN
         inv_trx_util_pub.TRACE('Item Type is ' || l_curr_txn_hist_record.Item_Type, 'INV_ONHAND_BALANCE', 9);
         inv_trx_util_pub.TRACE('Event Name is ' || l_curr_txn_hist_record.Event_Name, 'INV_ONHAND_BALANCE', 9);
         inv_trx_util_pub.TRACE('Event Key is ' || l_curr_txn_hist_record.Event_Key, 'INV_ONHAND_BALANCE', 9);
         inv_trx_util_pub.TRACE('Trading Partner ID is ' || To_Char(l_curr_txn_hist_record.Trading_Partner_ID), 'INV_ONHAND_BALANCE', 9);
         inv_trx_util_pub.TRACE('Document Type is ' || l_curr_txn_hist_record.Document_Type, 'INV_ONHAND_BALANCE', 9);
         inv_trx_util_pub.TRACE('Document Direction is ' || l_curr_txn_hist_record.Document_Direction, 'INV_ONHAND_BALANCE', 9);
         inv_trx_util_pub.TRACE('Document Number is ' || to_char(l_curr_txn_hist_record.Document_Number), 'INV_ONHAND_BALANCE', 9);
      END IF;


      /* Raise event will insert the record into the transaction history table
         for the current transaction.
      */

      Raise_Event ( l_curr_txn_hist_record,
                    l_xml_document_id,
                    l_Return_Status );


      IF (g_debug = 1) THEN
         inv_trx_util_pub.TRACE('Send_Receipt_Confirmation.l_Return_Status is '||l_Return_Status, 'INV_ONHAND_BALANCE', 9);
         inv_trx_util_pub.TRACE('Exiting Send_Onhand_Document', 'INV_ONHAND_BALANCE', 9);

      END IF;

      IF (l_Return_Status <> rcv_error_pkg.g_ret_sts_success ) THEN
         RAISE raise_event_error;
      END IF;

   EXCEPTION

      WHEN invalid_entity_type THEN
         X_Return_Status := rcv_error_pkg.g_ret_sts_error;
         IF (g_debug = 1) THEN
          inv_trx_util_pub.TRACE('invalid_entity_type exception has occured', 'INV_ONHAND_BALANCE', 9);
         END IF;

      WHEN invalid_action_type THEN
         X_Return_Status := rcv_error_pkg.g_ret_sts_error;
         IF (g_debug = 1) THEN
          inv_trx_util_pub.TRACE('invalid_action_type exception has occured', 'INV_ONHAND_BALANCE', 9);
         END IF;

      WHEN invalid_doc_type THEN
         X_Return_Status := rcv_error_pkg.g_ret_sts_error;
         IF (g_debug = 1) THEN
          inv_trx_util_pub.TRACE('invalid_doc_type exception has occured', 'INV_ONHAND_BALANCE', 9);
         END IF;

      WHEN raise_event_error THEN
         X_Return_Status := rcv_error_pkg.g_ret_sts_error;
         IF (g_debug = 1) THEN
          inv_trx_util_pub.TRACE('raise_event_error exception has occured, error message is '|| SQLERRM, 'INV_ONHAND_BALANCE', 9);
         END IF;

      WHEN OTHERS THEN
         X_Return_Status := rcv_error_pkg.g_ret_sts_error;
         IF (g_debug = 1) THEN
          inv_trx_util_pub.TRACE('Unexpected error has occured. Oracle error message is '|| SQLERRM, 'INV_ONHAND_BALANCE', 9);
         END IF;

END Send_Onhand_Document;



PROCEDURE send_onhand (x_errbuf          OUT  NOCOPY VARCHAR2,
                       x_retcode         OUT  NOCOPY NUMBER,
                       p_org_id          IN NUMBER,
                       p_deploy_mode     IN NUMBER DEFAULT null,
                       p_client_code     IN VARCHAR2,
                       p_warehouse_id    IN NUMBER,
                       p_client          IN VARCHAR2,
                       p_item_id         IN NUMBER,
                       p_subinventory    IN VARCHAR2,
                       p_locator         IN VARCHAR2,
                       p_lot             IN VARCHAR2,
                       p_grp             IN NUMBER DEFAULT  1,
                       p_display_lot     IN NUMBER DEFAULT  2) IS

l_return_status     VARCHAR2(1);
l_xml_doc_id        NUMBER;
l_entity_id         NUMBER;
l_org_id            NUMBER;
l_group_by          VARCHAR2(1000);
l_select_stmt       VARCHAR2(2000);
l_where_stmt        VARCHAR2(2000);
l_insert_stmt       VARCHAR2(2000);
l_stmt              varchar2(9000);
l_ret               BOOLEAN;
BEGIN

  if (g_debug = 1) then
      inv_trx_util_pub.TRACE('Entering send_onhand', 'INV_ONHAND_BALANCE', 9);
      inv_trx_util_pub.TRACE('p_org_id is '||p_org_id, 'INV_ONHAND_BALANCE', 9);
      inv_trx_util_pub.TRACE('p_warehouse_id is '||p_warehouse_id, 'INV_ONHAND_BALANCE', 9);
      inv_trx_util_pub.TRACE('p_deploy_mode is '||p_deploy_mode, 'INV_ONHAND_BALANCE', 9);
      inv_trx_util_pub.TRACE('p_client_code is '||p_client_code, 'INV_ONHAND_BALANCE', 9);
      inv_trx_util_pub.TRACE('p_item_id is ' ||p_item_id, 'INV_ONHAND_BALANCE', 9);
      inv_trx_util_pub.TRACE('p_subinventory is ' ||p_subinventory, 'INV_ONHAND_BALANCE', 9);
      inv_trx_util_pub.TRACE('p_locator is ' ||p_locator, 'INV_ONHAND_BALANCE', 9);
      inv_trx_util_pub.TRACE('p_lot is ' ||p_lot, 'INV_ONHAND_BALANCE', 9);
      inv_trx_util_pub.TRACE('p_grp is ' ||p_grp, 'INV_ONHAND_BALANCE', 9);
      inv_trx_util_pub.TRACE('p_display_lot is ' ||p_display_lot, 'INV_ONHAND_BALANCE', 9);
  end if;


  x_errbuf := 'Success';
  x_retcode := 0;

  --initialize
  begin
  delete from MTL_LSP_ONHAND_BALANCE_TMP;
  if (g_debug = 1) then
     inv_trx_util_pub.TRACE('Initialize, rows deleted : '||sql%rowcount, 'INV_ONHAND_BALANCE', 9);
  end if;

  exception
    when others then
         if (g_debug = 1) then
             inv_trx_util_pub.TRACE('Exception : '||sqlerrm||' occurred in delete_temp_table', 'INV_ONHAND_BALANCE', 9);
         end if;
         ROLLBACK;

  end;

  if p_warehouse_id is not null then
     l_org_id := p_warehouse_id;
  else
     l_org_id := p_org_id;
  end if;

  begin

    select  mtl_txns_history_s.nextval
    into l_entity_id
    from dual;

  exception
    when others then
      l_entity_id := -1;
  end;

  l_xml_doc_id :=l_entity_id;

  if (g_debug = 1) then
     inv_trx_util_pub.TRACE('l_entity_id is ' || l_entity_id, 'INV_ONHAND_BALANCE', 9);
  end if;

  l_insert_stmt :='insert into MTL_LSP_ONHAND_BALANCE_TMP(ITEM_ID, ITEM, ITEM_DESCRIPTION, PRIMARY_UOM, PRIMARY_QUANTITY, SECONDARY_UOM, SECONDARY_QUANTITY, CATEGORY, CONTAINERIZED_FLAG, ONHAND_STATUS, SNAPSHOT_DATE, XML_DOCUMENT_ID ';
  l_select_stmt :='select item_id, item, ITEM_DESCRIPTION, PRIMARY_UOM, sum(PRIMARY_QUANTITY), SECONDARY_UOM, sum(SECONDARY_QUANTITY), CATEGORY, CONTAINERIZED_FLAG, ONHAND_STATUS, SNAPSHOT_DATE, '||l_xml_doc_id;
  l_where_stmt := 'where 1 = 1';
  l_group_by :=' group by item_id, item, ITEM_DESCRIPTION, PRIMARY_UOM,SECONDARY_UOM, CATEGORY, CONTAINERIZED_FLAG, ONHAND_STATUS, SNAPSHOT_DATE  ';

  if p_item_id is not null then
     l_where_stmt := l_where_stmt||' and item_id = '||p_item_id;
  end if;

  if p_grp = 2 then
   l_insert_stmt :=l_insert_stmt||',WAREHOUSE, WAREHOUSE_ID ';
   l_select_stmt :=l_select_stmt||',WAREHOUSE, WAREHOUSE_ID ';
   l_group_by :=l_group_by||',WAREHOUSE,  WAREHOUSE_ID ';
  end if;

  if p_grp = 3 then
   l_insert_stmt :=l_insert_stmt||',WAREHOUSE, WAREHOUSE_ID,SUBINVENTORY ';
   l_select_stmt :=l_select_stmt||',WAREHOUSE, WAREHOUSE_ID,SUBINVENTORY ';
   l_group_by :=l_group_by||',WAREHOUSE,  WAREHOUSE_ID, SUBINVENTORY ';
  end if;

  if p_grp = 4 then
   l_insert_stmt :=l_insert_stmt||',WAREHOUSE, WAREHOUSE_ID,SUBINVENTORY,LOCATOR ';
   l_select_stmt :=l_select_stmt||',WAREHOUSE, WAREHOUSE_ID,SUBINVENTORY,LOCATOR ';
   l_group_by :=l_group_by||',WAREHOUSE,  WAREHOUSE_ID,SUBINVENTORY,LOCATOR ';
  end if;

  if p_display_lot = 1 then
   l_insert_stmt :=l_insert_stmt||',LOT ';
   l_select_stmt :=l_select_stmt||',LOT ';
   l_group_by :=l_group_by||', LOT ';
  end if;

  if p_warehouse_id is not null then
    l_where_stmt :=l_where_stmt||' and WAREHOUSE_ID ='||p_warehouse_id;
  end if;
  if p_client_code is not null then
    l_where_stmt :=l_where_stmt||' and wms_deploy.get_client_code(item_id) ='''||p_client_code||''' ';
  end if;
  if p_subinventory is not null then
    l_where_stmt :=l_where_stmt||' and SUBINVENTORY = '''||p_subinventory||''' ';
  end if;
  if p_locator is not null then
    l_where_stmt :=l_where_stmt||' and LOCATOR =(select concatenated_segments from mtl_item_locations_kfv where inventory_location_id='||p_locator||')';
  end if;
  if p_lot is not null then
    l_where_stmt :=l_where_stmt||' and LOT = '''||p_lot||''' ';
  end if;

  l_stmt := l_insert_stmt||') '||l_select_stmt||' from mtl_onhand_sync_v '||l_where_stmt||l_group_by;

  inv_trx_util_pub.TRACE('l_insert_stmt : '||l_insert_stmt, 'INV_ONHAND_BALANCE', 9);
  inv_trx_util_pub.TRACE('l_select_stmt : '||l_select_stmt, 'INV_ONHAND_BALANCE', 9);
  inv_trx_util_pub.TRACE('l_where_stmt : '||l_where_stmt, 'INV_ONHAND_BALANCE', 9);
  inv_trx_util_pub.TRACE('l_group_by : '||l_group_by, 'INV_ONHAND_BALANCE', 9);

  EXECUTE IMMEDIATE l_stmt ;


  if (g_debug = 1) then
     inv_trx_util_pub.TRACE('Rows inserted : '||sql%rowcount, 'INV_ONHAND_BALANCE', 9);
  end if;

  Send_Onhand_Document (P_Entity_ID        => l_entity_id,
                        P_Entity_Type      => 'INVMOQD',
                        P_Action_Type      => 'A',
                        P_Document_Type    => 'ONHAND',
                        P_Org_ID           => l_org_id,
                        P_client_code      => p_client_code,
                        p_xml_document_id  => l_xml_doc_id,
                        X_Return_Status    => l_return_status );

  if (g_debug = 1) then
     inv_trx_util_pub.TRACE('Send_Onhand_Document.l_return_status is ' || l_return_status, 'INV_ONHAND_BALANCE', 9);
     inv_trx_util_pub.TRACE('Exiting Send_Document call', 'INV_ONHAND_BALANCE', 9);
  end if;

  if l_return_status <> rcv_error_pkg.g_ret_sts_success then
     l_ret :=fnd_concurrent.set_completion_status('ERROR', 'Error');
  end if;

  COMMIT;

EXCEPTION
    WHEN OTHERS THEN

       if (g_debug = 1) then
           inv_trx_util_pub.TRACE('Exception : '||sqlerrm||' occurred in Send_Onhand_Document', 'INV_ONHAND_BALANCE', 9);
       end if;
       ROLLBACK;

       l_ret :=fnd_concurrent.set_completion_status('ERROR', 'Error');

       x_errbuf := 'Error';
       x_retcode := 2;

END send_onhand;



END inv_onhand_balance;

/
