--------------------------------------------------------
--  DDL for Package Body INV_TRANSACTIONS_UTIL2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_TRANSACTIONS_UTIL2" AS
/* $Header: INVUTL2B.pls 120.0.12010000.2 2010/02/03 20:40:36 musinha noship $ */

g_debug      NUMBER :=  NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

G_PKG_NAME CONSTANT VARCHAR2(50) := 'INV_TRANSACTIONS_UTIL2';

PROCEDURE Update_Txn_Hist_Err_WF(	Item_type 	IN	VARCHAR2,
					Item_key	IN	VARCHAR2,
					Actid		IN	NUMBER,
					Funcmode	IN	VARCHAR2,
					Resultout	OUT NOCOPY 	VARCHAR2
                       	 	     )

IS
l_return_status VARCHAR2(1);

update_history EXCEPTION;


BEGIN

 if (g_debug = 1) then
    inv_trx_util_pub.TRACE('Entering Update_Txn_Hist_Err_WF', 'INV_TRANSACTIONS_UTIL2', 9);
    inv_trx_util_pub.TRACE('item_type is '||item_type, 'INV_TRANSACTIONS_UTIL2', 9);
    inv_trx_util_pub.TRACE('item_key is '||item_key, 'INV_TRANSACTIONS_UTIL2', 9);
    inv_trx_util_pub.TRACE('actid is '||actid, 'INV_TRANSACTIONS_UTIL2', 9);
    inv_trx_util_pub.TRACE('funcmode is '||funcmode, 'INV_TRANSACTIONS_UTIL2', 9);
 end if;

  IF ( funcmode = 'RUN' )  THEN
     Update_Txn_History ( Item_type,
			  Item_key,
			  'ER',
                          l_return_status
                        );

     if (g_debug = 1) then
       inv_trx_util_pub.TRACE('l_return_status is '||l_return_status, 'INV_TRANSACTIONS_UTIL2', 9);
     end if;

     IF ( l_return_status <> rcv_error_pkg.g_ret_sts_success ) THEN
	    raise update_history;
     ELSE
	resultout := 'COMPLETE:SUCCESS';
        if (g_debug = 1) then
          inv_trx_util_pub.TRACE('resultout is '||resultout, 'INV_TRANSACTIONS_UTIL2', 9);
        end if;
        RETURN;
     END IF;

  END IF;

EXCEPTION
  WHEN update_history THEN
	resultout := 'COMPLETE:FAILURE';
        if (g_debug = 1) then
          inv_trx_util_pub.TRACE('update_history exception has occured', 'INV_TRANSACTIONS_UTIL2', 9);
        end if;
        raise;
  WHEN OTHERS THEN
	resultout := 'COMPLETE:FAILURE';
        if (g_debug = 1) then
          inv_trx_util_pub.TRACE('Unexpected error has occured. Oracle error message is '|| SQLERRM, 'INV_TRANSACTIONS_UTIL2', 9);
        end if;
        raise;
END Update_Txn_Hist_Err_WF;

PROCEDURE Update_Txn_Hist_Success_WF(	Item_type 	IN	VARCHAR2,
					Item_key	IN	VARCHAR2,
					Actid		IN	NUMBER,
					Funcmode	IN	VARCHAR2,
					Resultout	OUT NOCOPY 	VARCHAR2
                       	 	     )

IS
l_return_status VARCHAR2(1);

update_history EXCEPTION;


BEGIN

 if (g_debug = 1) then
    inv_trx_util_pub.TRACE('Entering Update_Txn_Hist_Success_WF', 'INV_TRANSACTIONS_UTIL2', 9);
    inv_trx_util_pub.TRACE('item_type is '||item_type, 'INV_TRANSACTIONS_UTIL2', 9);
    inv_trx_util_pub.TRACE('item_key is '||item_key, 'INV_TRANSACTIONS_UTIL2', 9);
    inv_trx_util_pub.TRACE('actid is '||actid, 'INV_TRANSACTIONS_UTIL2', 9);
    inv_trx_util_pub.TRACE('funcmode is '||funcmode, 'INV_TRANSACTIONS_UTIL2', 9);
 end if;

 IF ( funcmode = 'RUN' )  THEN


      Update_Txn_History ( Item_type,
			   Item_key,
			   'ST',
			   l_return_status
			 );

      if (g_debug = 1) then
          inv_trx_util_pub.TRACE('Update_Txn_Hist_Success_WF.l_return_status is '||l_return_status, 'INV_TRANSACTIONS_UTIL2', 9);
      end if;

     IF ( l_return_status <> rcv_error_pkg.g_ret_sts_success ) THEN
	    raise update_history;
     ELSE
	resultout := 'COMPLETE:SUCCESS';
        if (g_debug = 1) then
          inv_trx_util_pub.TRACE('Update_Txn_Hist_Success_WF.resultout is '||resultout, 'INV_TRANSACTIONS_UTIL2', 9);
        end if;
        RETURN;
     END IF;
 END IF;

 if (g_debug = 1) then
   inv_trx_util_pub.TRACE('Exiting Update_Txn_Hist_Success_WF', 'INV_TRANSACTIONS_UTIL2', 9);
 end if;

 resultout := 'COMPLETE:SUCCESS';

EXCEPTION
  WHEN update_history THEN

	update mtl_txns_history
        set transaction_status = 'ER'
        where event_name = Item_type
        and event_key = Item_key
        and transaction_status = 'IP';


        resultout := 'COMPLETE:FAILURE';
        if (g_debug = 1) then
          inv_trx_util_pub.TRACE('update_history exception has occured.', 'INV_TRANSACTIONS_UTIL2', 9);
        end if;
	raise;
  WHEN OTHERS THEN

        update mtl_txns_history
        set transaction_status = 'ER'
        where event_name = Item_type
        and event_key = Item_key
        and transaction_status = 'IP';


        resultout := 'COMPLETE:FAILURE';
        if (g_debug = 1) then
          inv_trx_util_pub.TRACE('Unexpected error has occured. Oracle error message is '|| SQLERRM, 'INV_TRANSACTIONS_UTIL2', 9);
        end if;
        raise;
END Update_Txn_Hist_Success_WF;


PROCEDURE Update_Txn_History ( p_item_type     IN      VARCHAR2,
                               p_item_key      IN      VARCHAR2,
                               p_transaction_status IN VARCHAR2,
                               x_return_status OUT NOCOPY      VARCHAR2
                              )
IS


pragma AUTONOMOUS_TRANSACTION;

l_txns_history_rec INV_TRANSACTIONS_HISTORY_PKG.Txns_History_Record_Type;
l_document_type VARCHAR2(10);
l_txn_direction VARCHAR2(10);
l_txn_id NUMBER;
l_document_number NUMBER := NULL;
l_xml_document_id NUMBER := NULL;
l_dummy  NUMBER := 0;

update_history EXCEPTION;


BEGIN

  if (g_debug = 1) then
     inv_trx_util_pub.TRACE('Entering Update_Txn_History', 'INV_TRANSACTIONS_UTIL2', 9);
     inv_trx_util_pub.TRACE('p_transaction_status is '||p_transaction_status, 'INV_TRANSACTIONS_UTIL2', 9);
  end if;

  IF ( p_item_type = 'INVADJTO' ) THEN
     l_document_type := 'ADJ';
     l_txn_direction := 'O';
  ELSE
     l_document_type := 'SA';
     l_txn_direction := 'O';
  END IF;

  if (g_debug = 1) then
       inv_trx_util_pub.TRACE('entity number: '||l_txns_history_rec.entity_number, 'INV_TRANSACTIONS_HISTORY_PKG', 9);
  end if;

  inv_transactions_history_pkg.Get_Txns_History( p_item_type,
						 p_item_key,
						 l_txn_direction,
						 l_document_type,
						 l_txns_history_rec,
						 x_return_status );



  if (g_debug = 1) then
     inv_trx_util_pub.TRACE('Update_Txn_History.x_return_status is '||x_return_status, 'INV_TRANSACTIONS_UTIL2', 9);
  end if;

  l_txns_history_rec.transaction_status := p_transaction_status;

  IF ( x_return_status <> rcv_error_pkg.g_ret_sts_success ) THEN
     raise update_history;
  END IF;

  INV_TRANSACTIONS_HISTORY_PKG.Create_Update_Txns_History ( l_txns_history_rec,
                               l_xml_document_id, -- being passed as null at this point
                               l_txn_id,
                               x_return_status );


  if (g_debug = 1) then
     inv_trx_util_pub.TRACE('Update_Txn_History.x_return_status is '||x_return_status, 'INV_TRANSACTIONS_UTIL2', 9);
  end if;

  IF ( x_return_status <> rcv_error_pkg.g_ret_sts_success ) THEN
     raise update_history;
  ELSE
     COMMIT;
  END IF;

  if (g_debug = 1) then
     inv_trx_util_pub.TRACE('Exiting Update_Txn_History', 'INV_TRANSACTIONS_UTIL2', 9);
  end if;

EXCEPTION
  WHEN  update_history THEN

        update mtl_txns_history
        set transaction_status = 'ER'
        where event_name = p_item_type
        and event_key = p_item_key
        and transaction_status = 'IP';

        x_return_status := rcv_error_pkg.g_ret_sts_error;
        if (g_debug = 1) then
           inv_trx_util_pub.TRACE('update_history exception has occured.', 'INV_TRANSACTIONS_UTIL2', 9);
        end if;
        ROLLBACK;
  WHEN OTHERS THEN

        update mtl_txns_history
        set transaction_status = 'ER'
        where event_name = p_item_type
        and event_key = p_item_key
        and transaction_status = 'IP';

	x_return_status := rcv_error_pkg.g_ret_sts_error;
        if (g_debug = 1) then
           inv_trx_util_pub.TRACE('Unexpected error has occured. Oracle error message is '|| SQLERRM, 'INV_TRANSACTIONS_UTIL2', 9);
        end if;
        ROLLBACK;
END Update_Txn_History;

  --k proj

PROCEDURE send_inventory_adjustment ( P_Entity_ID        IN  NUMBER,
                                      P_Entity_Type      IN  VARCHAR2,
                                      P_Action_Type      IN  VARCHAR2,
                                      P_Document_Type    IN  VARCHAR2,
                                      P_Org_ID           IN  NUMBER,
                                      P_client_code      IN  VARCHAR2,
				      p_xml_document_id  IN  NUMBER,
                                      X_Return_Status    OUT NOCOPY  VARCHAR2 )
   IS

      l_orig_Event_Key          VARCHAR2 (240);
      l_curr_txn_hist_record  INV_TRANSACTIONS_HISTORY_PKG.Txns_History_Record_Type;
      l_Return_Status   VARCHAR2 (1);
      l_wms_deployment_mode     VARCHAR2(1);
      l_party_id                NUMBER;
      l_xml_document_id         NUMBER;

      invalid_entity_type        EXCEPTION;
      invalid_action_type        EXCEPTION;
      invalid_doc_type           EXCEPTION;
      raise_event_error          EXCEPTION;

BEGIN

      if (g_debug = 1) then
         inv_trx_util_pub.TRACE('Entering send_inventory_adjustment', 'INV_TRANSACTIONS_UTIL2', 9);
         inv_trx_util_pub.TRACE('Entity_ID is ' || P_Entity_ID, 'INV_TRANSACTIONS_UTIL2', 9);
         inv_trx_util_pub.TRACE('Entity Type is ' || P_Entity_Type, 'INV_TRANSACTIONS_UTIL2', 9);
         inv_trx_util_pub.TRACE('Action Type is ' || P_Action_Type, 'INV_TRANSACTIONS_UTIL2', 9);
         inv_trx_util_pub.TRACE('Dcument Type is ' || p_document_type, 'INV_TRANSACTIONS_UTIL2', 9);
         inv_trx_util_pub.TRACE('Org ID is ' || to_char(P_Org_ID), 'INV_TRANSACTIONS_UTIL2', 9);
         inv_trx_util_pub.TRACE('Client Code is '|| P_client_code, 'INV_TRANSACTIONS_UTIL2', 9);
         inv_trx_util_pub.TRACE('XML Document ID is '|| to_char(p_xml_document_id), 'INV_TRANSACTIONS_UTIL2', 9);
      end if;

      X_Return_Status := rcv_error_pkg.g_ret_sts_success;

      IF ( P_Entity_TYPE <> 'INVADJ' ) THEN
         RAISE invalid_entity_type;
      ELSIF ( P_Action_TYPE <> 'A' ) THEN
         RAISE invalid_action_type;
      ELSIF ( P_Document_TYPE <> 'ADJ' ) THEN
         RAISE invalid_doc_type;
      END IF;

      l_xml_document_id := P_xml_document_id;

      SELECT po_wf_itemkey_s.NEXTVAL
      INTO   l_orig_Event_Key
      FROM   DUAL;

      l_curr_txn_hist_record.Document_Type         := P_Document_Type;
      l_curr_txn_hist_record.Document_Direction    := 'O';
      l_curr_txn_hist_record.Entity_Number         := P_Entity_ID;
      l_curr_txn_hist_record.Entity_Type           := P_Entity_TYPE;

      l_curr_txn_hist_record.Event_Name            := 'oracle.apps.inv.standalone.adjo';
      l_curr_txn_hist_record.Item_Type             := 'INVADJTO';
      l_curr_txn_hist_record.Event_Key             := l_orig_Event_Key;
      l_curr_txn_hist_record.Action_Type           := P_Action_Type;
      l_curr_txn_hist_record.Transaction_Status    := 'IP';
      --l_curr_txn_hist_record.ecx_message_id        := p_xml_document_id;
      l_curr_txn_hist_record.Document_Number       := P_Entity_ID;

      l_wms_deployment_mode := wms_deploy.wms_deployment_mode;

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

      end If;

      l_curr_txn_hist_record.Trading_Partner_ID    := l_party_id;

      if (g_debug = 1) then
         inv_trx_util_pub.TRACE('Item Type is ' || l_curr_txn_hist_record.Item_Type, 'INV_TRANSACTIONS_UTIL2', 9);
         inv_trx_util_pub.TRACE('Event Name is ' || l_curr_txn_hist_record.Event_Name, 'INV_TRANSACTIONS_UTIL2', 9);
         inv_trx_util_pub.TRACE('Event Key is ' || l_curr_txn_hist_record.Event_Key, 'INV_TRANSACTIONS_UTIL2', 9);
         inv_trx_util_pub.TRACE('Trading Partner ID is ' || To_Char(l_curr_txn_hist_record.Trading_Partner_ID), 'INV_TRANSACTIONS_UTIL2', 9);
         inv_trx_util_pub.TRACE('Document Type is ' || l_curr_txn_hist_record.Document_Type, 'INV_TRANSACTIONS_UTIL2', 9);
         inv_trx_util_pub.TRACE('Document Direction is ' || l_curr_txn_hist_record.Document_Direction, 'INV_TRANSACTIONS_UTIL2', 9);
         inv_trx_util_pub.TRACE('Document Number is ' || to_char(l_curr_txn_hist_record.Document_Number), 'INV_TRANSACTIONS_UTIL2', 9);
      end if;


      /* Raise event will insert the record into the transaction history table
         for the current transaction.
      */

      INV_EXTERNAL_INTERFACE_SV.Raise_Event ( l_curr_txn_hist_record,
                                              l_xml_document_id,
                                              l_Return_Status );

      if (g_debug = 1) then
         inv_trx_util_pub.TRACE('send_inventory_adjustment.l_Return_Status is '||l_Return_Status, 'INV_TRANSACTIONS_UTIL2', 9);
         inv_trx_util_pub.TRACE('Exiting send_inventory_adjustment', 'INV_TRANSACTIONS_UTIL2', 9);
      end if;

      IF (l_Return_Status <> rcv_error_pkg.g_ret_sts_success ) THEN
         RAISE raise_event_error;
      END IF;

   EXCEPTION

      WHEN invalid_entity_type THEN
         X_Return_Status := rcv_error_pkg.g_ret_sts_error;
         if (g_debug = 1) then
            inv_trx_util_pub.TRACE('invalid_entity_type exception has occured', 'INV_TRANSACTIONS_UTIL2', 9);
         end if;

      WHEN invalid_action_type THEN
         X_Return_Status := rcv_error_pkg.g_ret_sts_error;
         if (g_debug = 1) then
            inv_trx_util_pub.TRACE('invalid_action_type exception has occured', 'INV_TRANSACTIONS_UTIL2', 9);
         end if;

      WHEN invalid_doc_type THEN
         X_Return_Status := rcv_error_pkg.g_ret_sts_error;
         if (g_debug = 1) then
            inv_trx_util_pub.TRACE('invalid_doc_type exception has occured', 'INV_TRANSACTIONS_UTIL2', 9);
         end if;

      WHEN raise_event_error THEN
         X_Return_Status := rcv_error_pkg.g_ret_sts_error;
         if (g_debug = 1) then
            inv_trx_util_pub.TRACE('raise_event_error exception has occured, error message is '|| SQLERRM, 'INV_TRANSACTIONS_UTIL2', 9);
         end if;

      WHEN OTHERS THEN
         X_Return_Status := rcv_error_pkg.g_ret_sts_error;
         if (g_debug = 1) then
            inv_trx_util_pub.TRACE('Unexpected error has occured. Oracle error message is '|| SQLERRM, 'INV_TRANSACTIONS_UTIL2', 9);
         end if;

   END send_inventory_adjustment;


PROCEDURE Send_Document( p_entity_id IN NUMBER,
			 p_entity_type IN VARCHAR2,
			 p_action_type IN VARCHAR2,
			 p_document_type IN VARCHAR2,
			 p_organization_id IN NUMBER,
                         p_client_code     IN VARCHAR2,
			 p_xml_document_id IN NUMBER,
			 x_return_status OUT NOCOPY  VARCHAR2)

IS

invalid_doc_type EXCEPTION;

BEGIN

  if (g_debug = 1) then
    inv_trx_util_pub.TRACE('Entering Send_Document', 'INV_TRANSACTIONS_UTIL2', 9);
  end if;

  IF ( p_document_type = 'ADJ' ) THEN

      send_inventory_adjustment(p_entity_id,
                                p_entity_type,
                                p_action_type,
                                p_document_type,
                                p_organization_id,
                                p_client_code,
				p_xml_document_id,
                                x_return_status);

      if (g_debug = 1) then
         inv_trx_util_pub.TRACE('Exiting Send_Document', 'INV_TRANSACTIONS_UTIL2', 9);
         inv_trx_util_pub.TRACE('Send_Document.x_return_status is '|| x_return_status, 'INV_TRANSACTIONS_UTIL2', 9);
      end if;

  ELSE
     raise invalid_doc_type;
  END IF;

EXCEPTION

  WHEN  invalid_doc_type THEN
        x_return_status := rcv_error_pkg.g_ret_sts_error;

        if (g_debug = 1) then
           inv_trx_util_pub.TRACE('invalid_doc_type exception has occured.', 'INV_TRANSACTIONS_UTIL2', 9);
        end if;

  WHEN  OTHERS THEN
        x_return_status := rcv_error_pkg.g_ret_sts_error;

        if (g_debug = 1) then
           inv_trx_util_pub.TRACE('Unexpected error has occured. Oracle error message is '|| SQLERRM, 'INV_TRANSACTIONS_UTIL2', 9);
        end if;

END Send_Document;


END INV_TRANSACTIONS_UTIL2;

/
