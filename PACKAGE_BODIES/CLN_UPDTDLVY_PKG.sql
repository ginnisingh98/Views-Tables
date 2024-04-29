--------------------------------------------------------
--  DDL for Package Body CLN_UPDTDLVY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CLN_UPDTDLVY_PKG" AS
/* $Header: CLNUPDLB.pls 115.11 2004/04/29 21:09:23 cshih noship $ */

   /*=======================================================================+
   | FILENAME
   |   CLNUPDLB.sql
   |
   | DESCRIPTION
   |   PL/SQL package:  CLN_UPDTDLVY_PKG
   |
   | NOTES
   |   Created 9/26/03 chiung-fu.shih
   *=====================================================================*/


   -- Name: Get_UpdateDelivery_Params
   -- Purpose: Gets the necessary parameters for the outbound Update Delivery transaction
   -- Arguments: Normal Workflow API parameters
   PROCEDURE Get_Updatedelivery_Params(itemtype               IN              VARCHAR2,
                                       itemkey                IN              VARCHAR2,
                                       actid                  IN              NUMBER,
                                       funcmode               IN              VARCHAR2,
                                       resultout              IN OUT NOCOPY   VARCHAR2) IS
   l_debug_level                 NUMBER;

   x_progress                    VARCHAR2(100);
   transaction_type    	         varchar2(240);
   transaction_subtype           varchar2(240);
   document_direction            varchar2(240);
   message_text                  varchar2(240);
   party_id	      	         number;
   party_site_id	               number;
   party_type                    varchar2(30);
   return_code                   pls_integer;
   errmsg		               varchar2(2000);
   result		               boolean;
   l_error_code                  NUMBER;
   l_error_msg                   VARCHAR2(1000);
   p_shipment_header_id          NUMBER;

   -- parameters for document creation date
   l_date                        DATE;
   l_canonical_date              VARCHAR2(100);

   -- parameters for document id
   l_document_id                 VARCHAR2(100);
   l_updtdlvy_seq                NUMBER;
   l_organization_id             NUMBER;
   l_receipt_id                  NUMBER;

   -- reference ID
   l_ref_num                     VARCHAR2(100);


   BEGIN
      -- set debug level
      l_debug_level := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));

      if (l_debug_level <= 1) then
         cln_debug_pub.Add('ENTERING CLN_UPDTDLVY_PKG.Get_UpdateDelivery_Params', 1);
         cln_debug_pub.Add('With the following parameters:', 1);
         cln_debug_pub.Add('itemtype:'   || itemtype, 1);
         cln_debug_pub.Add('itemkey:'    || itemkey, 1);
         cln_debug_pub.Add('actid:'      || actid, 1);
         cln_debug_pub.Add('funcmode:'   || funcmode, 1);
         cln_debug_pub.Add('resultout:'  || resultout, 1);
      end if;

      -- initialize parameters
      x_progress := '000';
      transaction_type := 'CLN';
      transaction_subtype := 'UPDTDLVYO';
      document_direction := 'OUT';
      message_text := 'CLN_UPDL_MESSAGE_SENT';
      party_type := 'S';
      result := FALSE;

      x_progress := 'CLN_UPDTDLVY_PKG.Raise_Updatedelivery_Event: Parameters Initialized';
      if (l_debug_level <= 1) then
         cln_debug_pub.Add('Failure point ' || x_progress, 1);
      end if;

      -- Do nothing in cancel or timeout mode
      if (funcmode <> wf_engine.eng_run) then
         resultout := wf_engine.eng_null;
         return; -- do not raise the exception as it would end the workflow
      end if;

      -- Retrieve Activity Attributes
      p_shipment_header_id := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'SHIPMENT_HEADER_ID');

      if (p_shipment_header_id is null) then
         wf_core.token('SHIPMENT_HEADER_ID', 'NULL');
         wf_core.raise('WFSQL_ARGS');
      end if;

      -- logic to get parameters.
      SELECT h.vendor_id, h.vendor_site_id
      INTO party_id, party_site_id
      FROM rcv_shipment_headers h
      WHERE h.shipment_header_id = p_shipment_header_id;

      select FND_PROFILE.VALUE('ORG_ID')
      into l_organization_id
      from dual;

      if (l_debug_level <= 1) then
         cln_debug_pub.Add('CLN_UPDTDLVY_PKG.Raise_Updatedelivery_Event: Parameter Lookups Completed', 1);
         cln_debug_pub.Add('With the following parameters:', 1);
         cln_debug_pub.Add('p_shipment_header_id:'   || p_shipment_header_id, 1);
         cln_debug_pub.Add('party_id:'    || party_id, 1);
         cln_debug_pub.Add('party_site_id:'      || party_site_id, 1);
         cln_debug_pub.Add('l_organization_id:'   || l_organization_id, 1);
      end if;

      -- XML Setup Check
      ecx_document.isDeliveryRequired(
      transaction_type     => transaction_type,
      transaction_subtype  => transaction_subtype,
      party_id	           => party_id,
      party_site_id	       => party_site_id,
      party_type           => party_type,
      resultout	           => result,
      retcode		       => return_code,
      errmsg		       => errmsg);

      if (l_debug_level <= 1) then
         cln_debug_pub.Add('CLN_UPDTDLVY_PKG.Raise_Updatedelivery_Event : XML Trading Partner Setup Check Done', 1);
         cln_debug_pub.Add('With the following OUT parameters:', 1);
         cln_debug_pub.Add('retcode:' || return_code, 1);
         cln_debug_pub.Add('errmsg:' || errmsg, 1);
      end if;

      -- Decision on action depending on XML Setup Check
	if NOT(result) then

         x_progress := 'CLN_UPDTDLVY_PKG.Raise_Updatedelivery_Event : XML Trading Partner Setup Check Failed';
         if (l_debug_level <= 1) then
            cln_debug_pub.Add('Failure point ' || x_progress, 1);
         end if;

         resultout := 'FAIL';
      else

         x_progress := 'CLN_UPDTDLVY_PKG.Raise_Updatedelivery_Event : XML Trading Partner Setup Check Succeeded';
         if (l_debug_level <= 1) then
            cln_debug_pub.Add('Failure point ' || x_progress, 1);
         end if;

         SELECT h.receipt_num INTO l_receipt_id FROM rcv_shipment_headers h
         WHERE h.shipment_header_id = p_shipment_header_id;

         l_ref_num := l_receipt_id || '-' || sys_guid();

         -- create unique key
         SELECT CLN_UPDTDLVY_S.nextval into l_updtdlvy_seq from dual;
         l_document_id := to_char(l_receipt_id) || '.' || to_char(l_updtdlvy_seq);

         SELECT sysdate into l_date from dual;
         l_canonical_date := FND_DATE.DATE_TO_CANONICAL(l_date);

         x_progress := 'CLN_UPDTDLVY_PKG.Raise_Updatedelivery_Event : Created reference ID, unique key, and canonical date';
         if (l_debug_level <= 1) then
            cln_debug_pub.Add('Failure point ' || x_progress, 1);
         end if;

         -- pass parameters back to main itemtype attributes
         wf_engine.SetItemAttrText(itemtype, itemkey, 'XMLG_INTERNAL_TXN_TYPE', transaction_type);
         wf_engine.SetItemAttrText(itemtype, itemkey, 'XMLG_INTERNAL_TXN_SUBTYPE', transaction_subtype);
         wf_engine.SetItemAttrText(itemtype, itemkey, 'DOCUMENT_DIRECTION', document_direction);
         wf_engine.SetItemAttrText(itemtype, itemkey, 'XMLG_DOCUMENT_ID', l_document_id);
         wf_engine.SetItemAttrText(itemtype, itemkey, 'TRADING_PARTNER_ID', party_id);
         wf_engine.SetItemAttrText(itemtype, itemkey, 'TRADING_PARTNER_SITE', party_site_id);
         wf_engine.SetItemAttrText(itemtype, itemkey, 'TRADING_PARTNER_TYPE', party_type);
         wf_engine.SetItemAttrText(itemtype, itemkey, 'DOCUMENT_NO', l_document_id);
         wf_engine.SetItemAttrText(itemtype, itemkey, 'ORG_ID', l_organization_id);
         wf_engine.SetItemAttrText(itemtype, itemkey, 'ECX_TRANSACTION_TYPE', transaction_type);
         wf_engine.SetItemAttrText(itemtype, itemkey, 'ECX_TRANSACTION_SUBTYPE', transaction_subtype);
         wf_engine.SetItemAttrText(itemtype, itemkey, 'ECX_PARTY_ID', party_id);
         wf_engine.SetItemAttrText(itemtype, itemkey, 'ECX_PARTY_SITE_ID', party_site_id);
         wf_engine.SetItemAttrText(itemtype, itemkey, 'ECX_PARTY_TYPE', party_type);
         wf_engine.SetItemAttrText(itemtype, itemkey, 'ECX_DOCUMENT_ID', l_document_id);
         wf_engine.SetItemAttrText(itemtype, itemkey, 'MESSAGE_TEXT', message_text);
         wf_engine.SetItemAttrText(itemtype, itemkey, 'REFERENCE_ID', l_ref_num);
         wf_engine.SetItemAttrText(itemtype, itemkey, 'DOCUMENT_CREATION_DATE', l_canonical_date);

         -- Reached Here. Successful execution.
         if (l_debug_level <= 1) then
            cln_debug_pub.Add('EXITING CLN_UPDTDLVY_PKG.Raise_UpdateDelivery_Event Successfully', 1);
         end if;

         resultout := 'SUCCESS';
      end if;
   EXCEPTION
      WHEN OTHERS THEN
         l_error_code := SQLCODE;
         l_error_msg  := SQLERRM;
         if (l_debug_level <= 1) then
            cln_debug_pub.Add('Exception ' || ':'  || l_error_code || ':' || l_error_msg, 1);
         end if;

         x_progress := 'CLN_UPDTDLVY_PKG.Raise_Updatedelivery_Event : Error';
         if (l_debug_level <= 1) then
            cln_debug_pub.Add('Failure point ' || x_progress, 1);
         end if;

         resultout := 'ERROR:' || l_error_msg;
   END Get_Updatedelivery_Params;

   -- Name: getReceiptNum
   -- Purpose: gets the Receipt Number
   -- Arguments: Receipt Number concatenated with Message ID
   PROCEDURE getReceiptNum(ReceiptNumAndMsgId        IN           VARCHAR2,
                           ReceiptNum                OUT NOCOPY   VARCHAR2) IS
      l_debug_level                 NUMBER;
      MsgIdExists                   VARCHAR2(100);
      l_error_code                  NUMBER;
      l_error_msg                   VARCHAR2(1000);
   BEGIN
      -- init parameters
      l_debug_level := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));

      MsgIdExists := INSTR(ReceiptNumAndMsgId, '-', 1, 1);

      if(MsgIdExists = 0) then
         ReceiptNum := ReceiptNumAndMsgId;
      else
         ReceiptNum := RTRIM(RTRIM(ReceiptNumAndMsgId, 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'), '-');
      end if;

   EXCEPTION
      WHEN OTHERS THEN
         l_error_code := SQLCODE;
         l_error_msg  := SQLERRM;
         if (l_debug_level <= 1) then
            cln_debug_pub.Add('Exception ' || ':'  || l_error_code || ':' || l_error_msg, 1);
         end if;
   END getReceiptNum;


   -- Name: Process_Update_Delivery
   -- Purpose: Processes the Inbound Update Delivery XML Payload; currently just updates the collaboration history.
   -- Arguments: Shipment Number
   PROCEDURE Process_Update_Delivery   (p_receipt_id           IN              VARCHAR2,
                                        p_int_cnt_num          IN              NUMBER,
                                        p_delivery_num         IN              VARCHAR2,
                                        x_notification_code    IN OUT NOCOPY   VARCHAR2,
                                        x_doc_status           IN OUT NOCOPY   VARCHAR2) IS
   l_debug_level                 NUMBER;

   x_progress                    VARCHAR2(100);
   l_error_code                  NUMBER;
   l_error_msg                   VARCHAR2(1000);

   -- parameters for document creation date
   l_date                        DATE;
   l_canonical_date              VARCHAR2(100);

   -- parameters for raising event
   l_update_cln_event            VARCHAR2(100);
   l_event_key                   VARCHAR2(100);
   l_updtdlvy_seq                NUMBER;
   l_update_cln_parameter_list   wf_parameter_list_t;
   l_second_cln_parameter_list   wf_parameter_list_t;
   message_text                  varchar2(240);
   b_is_valid_delivery_num       BOOLEAN;
   l_temp                        VARCHAR(10);


   BEGIN
      -- initialize parameters
      l_debug_level := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));

      x_progress := '000';
      l_update_cln_event := 'oracle.apps.cln.ch.collaboration.add';
      l_update_cln_parameter_list := wf_parameter_list_t();
      l_second_cln_parameter_list := wf_parameter_list_t();
      message_text := 'CLN_UPDL_MESSAGE_RCVD';

      if (l_debug_level <= 2) then
         cln_debug_pub.Add('Entering CLN_UPDTDLVY_PKG.Process_Update_Delivery', 1);
      end if;
      if (l_debug_level <= 1) then
         cln_debug_pub.Add('With the parameters', 1);
         cln_debug_pub.Add('p_receipt_id : ' || p_receipt_id, 1);
         cln_debug_pub.Add('p_int_cnt_num : ' || p_int_cnt_num, 1);
         cln_debug_pub.Add('p_delivery_num : ' || p_delivery_num, 1);
      end if;


      x_progress := 'CLN_UPDTDLVY_PKG.Raise_Updatedelivery_Event: 01';
      if (l_debug_level <= 1) then
         cln_debug_pub.Add('Failure point ' || x_progress, 1);
      end if;

      -- create unique key
      SELECT CLN_UPDTDLVY_S.nextval into l_updtdlvy_seq from dual;
      l_event_key := p_receipt_id || '.' || to_char(l_updtdlvy_seq);

      SELECT sysdate into l_date from dual;
      l_canonical_date := FND_DATE.DATE_TO_CANONICAL(l_date);

      x_progress := 'CLN_SYNCCTLG_PKG.Showship_Raise_Event : 02';
      if (l_debug_level <= 1) then
         cln_debug_pub.Add('Failure point ' || x_progress, 1);
      end if;

      -- add parameters to list for update collaboration event
      wf_event.AddParameterToList(p_name => 'XMLG_INTERNAL_CONTROL_NUMBER',
                                  p_value => p_int_cnt_num,
                                  p_parameterlist => l_update_cln_parameter_list);
      wf_event.AddParameterToList(p_name => 'DOCUMENT_NO',
                                  p_value => p_delivery_num,
                                  p_parameterlist => l_update_cln_parameter_list);
      wf_event.AddParameterToList(p_name => 'PARTNER_DOCUMENT_NO',
                                  p_value => p_delivery_num,
                                  p_parameterlist => l_update_cln_parameter_list);
      wf_event.AddParameterToList(p_name => 'MESSAGE_TEXT',
                                  p_value => message_text,
                                  p_parameterlist => l_update_cln_parameter_list);
      wf_event.AddParameterToList(p_name => 'DOCUMENT_CREATION_DATE',
                                  p_value => l_canonical_date,
                                  p_parameterlist => l_update_cln_parameter_list);

      x_progress := 'CLN_SYNCCTLG_PKG.Process_Update_Delivery : 03';
      if (l_debug_level <= 1) then
         cln_debug_pub.Add('Failure point ' || x_progress, 1);
      end if;

      -- raise update collaboration event
      wf_event.raise(p_event_name => l_update_cln_event,
                     p_event_key  => l_event_key,
                     p_parameters => l_update_cln_parameter_list);

      x_progress := 'CLN_SYNCCTLG_PKG.Process_Update_Delivery : 04';


      /* Bug : 3529009
         Desc : Delivery number should be validated*/

      IF (l_debug_level <= 1) THEN
         cln_debug_pub.Add('About to validate the delivery number with shipping tables : '||p_delivery_num, 1);
      END IF;

      b_is_valid_delivery_num := true;
      BEGIN
         SELECT 1
         INTO l_temp
         FROM WSH_NEW_DELIVERIES
         WHERE name = p_delivery_num;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
         -- Invalid delivery number
         IF (l_debug_level <= 1) THEN
            cln_debug_pub.Add('Delivery number not found in wsh_new_deliveries', 1);
         END IF;
        b_is_valid_delivery_num := false;
      END;

      IF (l_debug_level <= 1) THEN
            cln_debug_pub.Add('About to set parameters to raise the matching delivery event', 1);
      END IF;
      -- Raise the event to update collaboraiton history, with matching delivery info
      wf_event.AddParameterToList(p_name => 'XMLG_INTERNAL_CONTROL_NUMBER',
                                  p_value => p_int_cnt_num,
                                  p_parameterlist => l_second_cln_parameter_list);
      wf_event.AddParameterToList(p_name => 'ORIGINATOR_REFERENCE',
                                  p_value => p_delivery_num,
                                  p_parameterlist => l_second_cln_parameter_list);

      IF b_is_valid_delivery_num THEN
         x_notification_code := '4B2_00';
         x_doc_status := 'SUCCESS';
         wf_event.AddParameterToList(p_name => 'DOCUMENT_STATUS',
                                     p_value => 'SUCCESS',
                                     p_parameterlist => l_second_cln_parameter_list);
         wf_event.AddParameterToList(p_name => 'MESSAGE_TEXT',
                                     p_value => 'CLN_4B2_VALID_DELIVERY_NUM',
                                     p_parameterlist => l_second_cln_parameter_list);
      ELSE
         x_notification_code := '4B2_02';
         x_doc_status := 'ERROR';
         wf_event.AddParameterToList(p_name => 'DOCUMENT_STATUS',
                                     p_value => 'ERROR',
                                     p_parameterlist => l_second_cln_parameter_list);
         wf_event.AddParameterToList(p_name => 'MESSAGE_TEXT',
                                     p_value => 'CLN_4B2_INVALID_DELIVERY_NUM',
                                     p_parameterlist => l_second_cln_parameter_list);
      END IF;

      if (l_debug_level <= 1) then
         cln_debug_pub.Add('About to raise the matching delivery event', 1);
      end if;

      -- raise update collaboration event
      wf_event.raise(p_event_name => l_update_cln_event,
                     p_event_key  => l_event_key||'.2',
                     p_parameters => l_second_cln_parameter_list);

      /* END Bug : 3529009 */

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

         x_progress := 'CLN_UPDTDLVY_PKG.Raise_Updatedelivery_Event : 05';
         if (l_debug_level <= 1) then
            cln_debug_pub.Add('Failure point ' || x_progress, 1);
         end if;

   END Process_Update_Delivery;

   -- Name
   --    GET_FROM_ROLE_ORG_ID
   -- Purpose
   --    Gets the Organization ID for a given Shipment Header Id
   -- Arguments
   --    Shipment Header Id
   -- Notes
   --    No specific notes

   FUNCTION GET_FROM_ROLE_ORG_ID
   (P_SHIPMENT_HEADER_ID IN  NUMBER)
   RETURN  NUMBER
   IS
      l_debug_level      NUMBER;

      l_org_id      	 NUMBER;
      l_return_msg       VARCHAR2(2000);
      l_debug_mode       VARCHAR2(300);
      l_error_code       NUMBER;
      l_error_msg        VARCHAR2(2000);
   BEGIN
      -- initialize parameters
      l_debug_level := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));
      l_org_id := 0;

      if (l_debug_level <= 1) then
         cln_debug_pub.Add('ENTERING GET_FROM_ROLE_ORG_ID', 1);
         cln_debug_pub.Add('With the following parameters:', 1);
         cln_debug_pub.Add('P_SHIPMENT_HEADER_ID:'   || P_SHIPMENT_HEADER_ID, 1);
      end if;

      SELECT o.organization_id
      INTO   l_org_id
      FROM per_people_f p, org_organization_definitions o, rcv_shipment_headers h
      WHERE nvl(h.shipped_date, h.last_update_date)
      BETWEEN NVL(p.effective_start_date, NVL(h.shipped_date, h.last_update_date))
      AND NVL(p.effective_end_date, NVL(h.shipped_date, h.last_update_date))
      AND p.person_id (+) = h.employee_id
      AND o.organization_id (+) =NVL( h.organization_id,h.ship_to_org_id)
      AND h.shipment_header_id = P_SHIPMENT_HEADER_ID;

      if (l_debug_level <= 1) then
         cln_debug_pub.Add('l_org_id:' || l_org_id, 1);
         cln_debug_pub.Add('EXITING GET_FROM_ROLE_ORG_ID', 1);
      end if;

      RETURN l_org_id;
   EXCEPTION
      WHEN OTHERS THEN
         l_error_code    := SQLCODE;
         l_error_msg     := SQLERRM;
         if (l_debug_level <= 1) then
            cln_debug_pub.Add('Exception ' || ':'  || l_error_code || ':' || l_error_msg, 1);
         end if;

         RETURN l_org_id;
   END GET_FROM_ROLE_ORG_ID;
END CLN_UPDTDLVY_PKG;

/
