--------------------------------------------------------
--  DDL for Package Body RCV_TRANSACTIONS_UTIL2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_TRANSACTIONS_UTIL2" AS
/* $Header: RCVTXUTB.pls 120.0.12010000.7 2010/01/25 23:44:44 vthevark noship $ */

g_asn_debug       VARCHAR2(1)  := asn_debug.is_debug_on; -- Bug 9152790

G_PKG_NAME CONSTANT VARCHAR2(50) := 'RCV_TRANSACTIONS_UTIL2';


PROCEDURE Update_Txn_Hist_Success_WF(Item_type   IN     VARCHAR2,
                                     Item_key    IN     VARCHAR2,
                                     Actid       IN     NUMBER,
                                     Funcmode    IN     VARCHAR2,
                                     Resultout   OUT NOCOPY  VARCHAR2
                                             )

IS
l_return_status VARCHAR2(1);

update_history EXCEPTION;


BEGIN

 IF (g_asn_debug = 'Y') THEN
  asn_debug.put_line('Entering Update_Txn_Hist_Success_WF');
  asn_debug.put_line('item_type is '||item_type);
  asn_debug.put_line('item_key is '||item_key);
  asn_debug.put_line('actid is '||actid);
  asn_debug.put_line('funcmode is '||funcmode);
 END IF;


 IF ( funcmode = 'RUN' )  THEN

      Update_Txn_History ( Item_type,
                           Item_key,
                           'ST',
                           l_return_status
                         );

      IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('Update_Txn_Hist_Success_WF.l_return_status is '||l_return_status);
      END IF;

     IF ( l_return_status <> rcv_error_pkg.g_ret_sts_success ) THEN
            raise update_history;
     ELSE
            resultout := 'COMPLETE:SUCCESS';
        IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Update_Txn_Hist_Success_WF.resultout is '||resultout);
        END IF;
        RETURN;
     END IF;
 END IF;

 IF (g_asn_debug = 'Y') THEN
  asn_debug.put_line('Exiting Update_Txn_Hist_Success_WF');
 END IF;

EXCEPTION
  WHEN update_history THEN


        update mtl_txns_history
        set transaction_status = 'ER'
        where event_name = Item_type
        and event_key = Item_key
        and transaction_status = 'IP';

        resultout := 'COMPLETE:FAILURE';
        IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('update_history exception has occured.');
        END IF;
        raise;
  WHEN OTHERS THEN


        update mtl_txns_history
        set transaction_status = 'ER'
        where event_name = Item_type
        and event_key = Item_key
        and transaction_status = 'IP';

        resultout := 'COMPLETE:FAILURE';
        IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Unexpected error has occured. Oracle error message is '|| SQLERRM);
        END IF;
        raise;
END Update_Txn_Hist_Success_WF;


PROCEDURE Update_Txn_History ( p_item_type     IN      VARCHAR2,
                               p_item_key      IN      VARCHAR2,
                               p_transaction_status IN VARCHAR2,
                               x_return_status OUT NOCOPY      VARCHAR2
                              )
IS


pragma AUTONOMOUS_TRANSACTION;

l_txns_history_rec RCV_TRANSACTIONS_HISTORY_PKG.Txns_History_Record_Type;
l_document_type VARCHAR2(2);
l_txn_direction VARCHAR2(1);
l_txn_id NUMBER;
l_document_number NUMBER := NULL;
l_xml_document_id NUMBER := NULL;

update_history EXCEPTION;


BEGIN

  IF (g_asn_debug = 'Y') THEN
      asn_debug.put_line('Entering Update_Txn_History');
      asn_debug.put_line('p_transaction_status is '||p_transaction_status);
  END IF;


  IF ( p_item_type = 'PORCPTO' ) THEN
     l_document_type := 'RC';
     l_txn_direction := 'O';
  ELSE
     l_document_type := 'SA';
     l_txn_direction := 'O';
  END IF;


  rcv_transactions_history_pkg.Get_Txns_History( p_item_type,
                                                 p_item_key,
                                                 l_txn_direction,
                                                 l_document_type,
                                                 --l_document_number,
                                                 l_txns_history_rec,
                                                 x_return_status );


  IF (g_asn_debug = 'Y') THEN
      asn_debug.put_line('Update_Txn_History.x_return_status is '||x_return_status);
  END IF;


  l_txns_history_rec.transaction_status := p_transaction_status;

  IF ( x_return_status <> rcv_error_pkg.g_ret_sts_success ) THEN
     raise update_history;
  END IF;

  RCV_TRANSACTIONS_HISTORY_PKG.Create_Update_Txns_History (l_txns_history_rec,
                               l_xml_document_id,
                               l_txn_id,
                               x_return_status );

  IF (g_asn_debug = 'Y') THEN
      asn_debug.put_line('Update_Txn_History.x_return_status is '||x_return_status);
  END IF;

  IF ( x_return_status <> rcv_error_pkg.g_ret_sts_success ) THEN
     raise update_history;
  ELSE
     COMMIT;
  END IF;

  IF (g_asn_debug = 'Y') THEN
      asn_debug.put_line('Exiting Update_Txn_History');
  END IF;

EXCEPTION
  WHEN  update_history THEN


        update mtl_txns_history
        set transaction_status = 'ER'
        where event_name = p_item_type
        and event_key = p_item_key
        and transaction_status = 'IP';

        x_return_status := rcv_error_pkg.g_ret_sts_error;
        IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('update_history exception has occured.');
        END IF;
	ROLLBACK;
  WHEN OTHERS THEN


        update mtl_txns_history
        set transaction_status = 'ER'
        where event_name = p_item_type
        and event_key = p_item_key
        and transaction_status = 'IP';

        x_return_status := rcv_error_pkg.g_ret_sts_error;
        IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Unexpected error has occured. Oracle error message is '|| SQLERRM);
        END IF;
	ROLLBACK;
END Update_Txn_History;

  --k proj

PROCEDURE Send_Receipt_Confirmation ( P_Entity_ID        IN  NUMBER,
                                      P_Entity_Type      IN  VARCHAR2,
                                      P_Action_Type      IN  VARCHAR2,
                                      P_Document_Type    IN  VARCHAR2,
                                      P_Org_ID           IN  NUMBER,
                                      P_client_code      IN  VARCHAR2,
                                      p_xml_document_id  IN  NUMBER,
                                      X_Return_Status    OUT NOCOPY  VARCHAR2)
   IS

      l_orig_Event_Key          VARCHAR2 (240);
      l_curr_txn_hist_record  RCV_TRANSACTIONS_HISTORY_PKG.Txns_History_Record_Type;
      l_Return_Status   VARCHAR2 (1);
      l_wms_deployment_mode     VARCHAR2(1);
      l_party_id                NUMBER;
      l_xml_document_id         NUMBER;

      invalid_entity_type        EXCEPTION;
      invalid_action_type        EXCEPTION;
      invalid_doc_type           EXCEPTION;
      raise_event_error          EXCEPTION;

BEGIN


      IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('Entering Send_Receipt_Confirmation');
          asn_debug.put_line('Entity_ID is ' || P_Entity_ID);
          asn_debug.put_line('Entity Type is ' || P_Entity_Type);
          asn_debug.put_line('Action Type is ' || P_Action_Type);
          asn_debug.put_line('Dcument Type is ' || p_document_type);
          asn_debug.put_line('Org ID is ' || to_char(P_Org_ID));
          asn_debug.put_line('Client Code is '|| P_client_code);
                 asn_debug.put_line('XML Document ID is '|| to_char(p_xml_document_id));
      END IF;

      X_Return_Status := rcv_error_pkg.g_ret_sts_success;
      l_xml_document_id := P_xml_document_id;

      IF ( P_Entity_TYPE <> 'RCPT' ) THEN
         RAISE invalid_entity_type;
      ELSIF ( P_Action_TYPE <> 'A' ) THEN
         RAISE invalid_action_type;
      ELSIF ( P_Document_TYPE <> 'RC' ) THEN
         RAISE invalid_doc_type;
      END IF;

      SELECT po_wf_itemkey_s.NEXTVAL
      INTO   l_orig_Event_Key
      FROM   DUAL;

      l_curr_txn_hist_record.Document_Type         := P_Document_Type;
      l_curr_txn_hist_record.Document_Direction    := 'O';
      l_curr_txn_hist_record.Entity_Number         := P_Entity_ID;
      l_curr_txn_hist_record.Entity_Type           := P_Entity_TYPE;

      l_curr_txn_hist_record.Event_Name            := 'oracle.apps.po.standalone.rcpto';
      l_curr_txn_hist_record.Item_Type             := 'PORCPTO';
      l_curr_txn_hist_record.Event_Key             := l_orig_Event_Key;
      l_curr_txn_hist_record.Action_Type           := P_Action_Type;
      l_curr_txn_hist_record.Transaction_Status    := 'IP';
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

      END If;

      l_curr_txn_hist_record.Trading_Partner_ID    := l_party_id;


      IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('Item Type is ' || l_curr_txn_hist_record.Item_Type);
          asn_debug.put_line('Event Name is ' || l_curr_txn_hist_record.Event_Name);
          asn_debug.put_line('Event Key is ' || l_curr_txn_hist_record.Event_Key);
          asn_debug.put_line('Trading Partner ID is ' || To_Char(l_curr_txn_hist_record.Trading_Partner_ID));
          asn_debug.put_line('Document Type is ' || l_curr_txn_hist_record.Document_Type);
          asn_debug.put_line('Document Direction is ' || l_curr_txn_hist_record.Document_Direction);
          asn_debug.put_line('Document Number is ' || to_char(l_curr_txn_hist_record.Document_Number));
      END IF;


      /* Raise event will insert the record into the transaction history table
         for the current transaction.
      */

      RCV_EXTERNAL_INTERFACE_SV.Raise_Event ( l_curr_txn_hist_record,
                                              l_xml_document_id,
                                              l_Return_Status );


      IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('Send_Receipt_Confirmation.l_Return_Status is '||l_Return_Status);
          asn_debug.put_line('Exiting Send_Receipt_Confirmation');
      END IF;

      IF (l_Return_Status <> rcv_error_pkg.g_ret_sts_success ) THEN
         RAISE raise_event_error;
      END IF;

   EXCEPTION

      WHEN invalid_entity_type THEN
         X_Return_Status := rcv_error_pkg.g_ret_sts_error;
         IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('invalid_entity_type exception has occured');
         END IF;

      WHEN invalid_action_type THEN
         X_Return_Status := rcv_error_pkg.g_ret_sts_error;
         IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('invalid_action_type exception has occured');
         END IF;

      WHEN invalid_doc_type THEN
         X_Return_Status := rcv_error_pkg.g_ret_sts_error;
         IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('invalid_doc_type exception has occured');
         END IF;

      WHEN raise_event_error THEN
         X_Return_Status := rcv_error_pkg.g_ret_sts_error;
         IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('raise_event_error exception has occured, error message is '|| SQLERRM);
         END IF;

      WHEN OTHERS THEN
         X_Return_Status := rcv_error_pkg.g_ret_sts_error;
         IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('Unexpected error has occured. Oracle error message is '|| SQLERRM);
         END IF;
   END Send_Receipt_Confirmation;


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

  IF (g_asn_debug = 'Y') THEN
   asn_debug.put_line( 'Entering Send_Document');
  END IF;

  IF ( p_document_type = 'RC' ) THEN

      send_receipt_confirmation(p_entity_id,
                                p_entity_type,
                                p_action_type,
                                p_document_type,
                                p_organization_id,
                                p_client_code,
                                p_xml_document_id,
                                x_return_status);

      IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('Exiting Send_Document');
          asn_debug.put_line('Send_Document.x_return_status is '|| x_return_status);
      END IF;

  ELSE
     raise invalid_doc_type;
  END IF;

EXCEPTION

  WHEN  invalid_doc_type THEN
        x_return_status := rcv_error_pkg.g_ret_sts_error;

        IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('invalid_doc_type exception has occured.');
        END IF;

  WHEN  OTHERS THEN
        x_return_status := rcv_error_pkg.g_ret_sts_error;

        IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Unexpected error has occured. Oracle error message is '|| SQLERRM);
        END IF;

END Send_Document;


END RCV_TRANSACTIONS_UTIL2;

/
