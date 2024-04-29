--------------------------------------------------------
--  DDL for Package Body CLN_SYNCCTLG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CLN_SYNCCTLG_PKG" AS
/* $Header: CLNSYCTB.pls 120.0 2005/05/24 16:16:42 appldev noship $ */

   /*=======================================================================+
   | FILENAME
   |   CLNSYCTB.sql
   |
   | DESCRIPTION
   |   PL/SQL package:  CLN_SYNCCTLG_PKG
   |
   | NOTES
   |   Created 6/03/03 chiung-fu.shih
   *=====================================================================*/

   PROCEDURE Syncctlg_Raise_Event(errbuf            OUT NOCOPY      VARCHAR2,
                                  retcode           OUT NOCOPY      VARCHAR2,
                                  p_tp_header_id    IN              NUMBER,
                                  p_list_header_id  IN              NUMBER,
                                  p_category_id     IN              NUMBER,
                                  p_from_items      IN              VARCHAR2,
                                  p_to_items        IN              VARCHAR2,
                                  p_currency_detail_id    IN        NUMBER,
                                  p_numitems_per_oag      IN        NUMBER) IS
   l_debug_level                 NUMBER;
   x_progress                    VARCHAR2(100);
   transaction_type    	         varchar2(240);
   transaction_subtype           varchar2(240);
   document_direction            varchar2(240);
   message_text                  varchar2(240);
   no_items_message_text         varchar2(240);
   party_id	      	         number;
   party_site_id	               number;
   party_type                    varchar2(30);
   return_code                   pls_integer;
   errmsg		               varchar2(2000);
   result		               boolean;
   l_error_code                  NUMBER;
   l_error_msg                   VARCHAR2(1000);

   l_subset_from                 VARCHAR2(100);
   l_subset_to                   VARCHAR2(100);

   l_auth_user_name              VARCHAR2(100);
   l_publisher_name              VARCHAR2(100);
   l_publisher_partnridx         VARCHAR2(100);

   -- parameters for raising event
   l_send_syct_event             VARCHAR2(100);
   l_create_cln_event            VARCHAR2(100);
   l_update_cln_event            VARCHAR2(100);
   l_event_key                   VARCHAR2(100);
   l_syncctlg_seq                NUMBER;
   l_send_syct_parameter_list    wf_parameter_list_t;
   l_create_cln_parameter_list   wf_parameter_list_t;
   l_update_cln_parameter_list   wf_parameter_list_t;
   l_operating_unit_id           NUMBER;
   l_inv_org_id                  NUMBER;
   l_date                        DATE;
   l_canonical_date              VARCHAR2(100);

   -- parameters for dealing with the number of items restriction
   counter                       BINARY_INTEGER;
   items_exist                   BOOLEAN;
   msgs_sent_flag                BOOLEAN;

   -- cursor to hold the list of items in price list to send
   CURSOR c_ItemsToSend IS
      select concatenated_segments
      from cln_procat_catitem_v cpcv, ecx_tp_headers eth
      where cpcv.list_header_id=p_list_header_id
      and cpcv.party_id=eth.party_id
      and eth.tp_header_id = p_tp_header_id
      and cpcv.organization_id = l_inv_org_id
      and (p_category_id is null or p_category_id in (select mcsvc.category_id from mtl_item_categories mic,
            mtl_category_set_valid_cats mcsvc where mcsvc.category_id = mic.category_id
            and mcsvc.category_set_id = mic.category_set_id and mic.inventory_item_id=cpcv.inventory_item_id
            and mic.organization_id=cpcv.organization_id))
      and ( p_from_items is null or cpcv.concatenated_segments>=p_from_items)
      and ( p_to_items is null or cpcv.concatenated_segments<=p_to_items)
      order by concatenated_segments;
   BEGIN
      -- set debug level
      l_debug_level := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));

      if (l_debug_level <= 2) then
         cln_debug_pub.Add('ENTERING CLN_SYNCCTLG_PKG.Syncctlg_Raise_Event', 1);
      end if;

      if (l_debug_level <= 1) then
         cln_debug_pub.Add('With the following parameters:', 1);
         cln_debug_pub.Add('p_tp_header_id:'   || p_tp_header_id, 1);
         cln_debug_pub.Add('p_list_header_id:'   || p_list_header_id, 1);
         cln_debug_pub.Add('p_category_id:'      || p_category_id, 1);
         cln_debug_pub.Add('p_from_items:'       || p_from_items, 1);
         cln_debug_pub.Add('p_to_items:'         || p_to_items, 1);
         cln_debug_pub.Add('p_currency_detail_id:'       || p_currency_detail_id, 1);
         cln_debug_pub.Add('p_numitems_per_oag:'         || p_numitems_per_oag, 1);
      end if;

      -- initialize parameters
      x_progress := '000';
      transaction_type := 'CLN';
      transaction_subtype := 'SYNCCTLGO';
      document_direction := 'OUT';
      message_text := 'CLN_SYCT_MESSAGE_SENT';
      no_items_message_text := 'CLN_SYCT_NO_ITEMS';
      party_type := 'C';
      result := FALSE;
      l_subset_from := NULL;
      l_subset_to := NULL;

      l_auth_user_name := fnd_global.user_name;

      l_send_syct_event := 'oracle.apps.cln.event.syncctlg';
      l_create_cln_event := 'oracle.apps.cln.ch.collaboration.create';
      l_update_cln_event := 'oracle.apps.cln.ch.collaboration.update';

      l_send_syct_parameter_list := wf_parameter_list_t();
      l_create_cln_parameter_list := wf_parameter_list_t();
      l_update_cln_parameter_list := wf_parameter_list_t();

      counter := 1;
      items_exist := FALSE;
      msgs_sent_flag := FALSE;

      if (l_debug_level <= 1) then
         cln_debug_pub.Add('p_tp_header_id:'   || p_tp_header_id, 1);
      end if;

      select eth.party_id, eth.party_site_id
      into party_id, party_site_id
      from ecx_tp_headers eth
      where eth.tp_header_id = p_tp_header_id;

      if (l_debug_level <= 1) then
         cln_debug_pub.Add('party_id:'   || party_id, 1);
         cln_debug_pub.Add('party_site_id:'   || party_site_id, 1);
      end if;

      select FND_PROFILE.VALUE('ORG_ID')
      into l_operating_unit_id
      from dual;

      if (l_debug_level <= 1) then
         cln_debug_pub.Add('l_operating_unit_id:'   || l_operating_unit_id, 1);
      end if;

      l_inv_org_id := qp_util.Get_Item_Validation_Org;
      if (l_debug_level <= 1) then
         cln_debug_pub.Add('l_inv_org_id:'   || l_inv_org_id, 1);
      end if;

      select haou.name, hla.ece_tp_location_code
      into l_publisher_name, l_publisher_partnridx
      from hr_all_organization_units haou, hr_locations_all hla
      where haou.location_id = hla.location_id
      and haou.organization_id = l_operating_unit_id;

      if (l_debug_level <= 1) then
         cln_debug_pub.Add('l_publisher_name:'   || l_publisher_name, 1);
         cln_debug_pub.Add('l_publisher_partnridx:'   || l_publisher_partnridx, 1);
      end if;

      x_progress := 'CLN_SYNCCTLG_PKG.Syncctlg_Raise_Event : Parameters Initialized';
      if (l_debug_level <= 1) then
         cln_debug_pub.Add('Failure point ' || x_progress, 1);
      end if;

      -- XML Setup Check
      if (l_debug_level <= 1) then
         cln_debug_pub.Add('Parameters before ecx_document.isDeliveryRequired:', 1);
         cln_debug_pub.Add('transaction_type:'   || transaction_type, 1);
         cln_debug_pub.Add('transaction_subtype:'   || transaction_subtype, 1);
         cln_debug_pub.Add('party_id:'      || party_id, 1);
         cln_debug_pub.Add('party_site_id:'   || party_site_id, 1);
         cln_debug_pub.Add('return_code:' || return_code, 1);
         cln_debug_pub.Add('errmsg:'      || errmsg, 1);
      end if;

      ecx_document.isDeliveryRequired(
      transaction_type       => transaction_type,
      transaction_subtype    => transaction_subtype,
      party_id	           => party_id,
      party_site_id	     => party_site_id,
      resultout	           => result,
      retcode		     => return_code,
      errmsg		     => errmsg);

      if (l_debug_level <= 1) then
         cln_debug_pub.Add('Values returned from ecx_document.isDeliveryRequired:', 1);
         cln_debug_pub.Add('return_code:'      || return_code, 1);
         cln_debug_pub.Add('errmsg:'      || errmsg, 1);
      end if;

      x_progress := 'CLN_SYNCCTLG_PKG.Syncctlg_Raise_Event : XML Setup Check';
      if (l_debug_level <= 1) then
         cln_debug_pub.Add('Failure point ' || x_progress, 1);
      end if;

      -- Decision on action depending on XML Setup Check
      if (l_debug_level <= 1) then
         cln_debug_pub.Add('Parameters:', 1);
         cln_debug_pub.Add('p_numitems_per_oag:'   || p_numitems_per_oag, 1);
      end if;

	   IF NOT(result) then
         --Trading partner not found. Nothing to do... Return from here
         x_progress := 'CLN_SYNCCTLG_PKG.Syncctlg_Raise_Event : No Trading Partner found during XML Setup Check';
         if (l_debug_level <= 1) then
            cln_debug_pub.Add('Failure point ' || x_progress, 1);
         end if;

      ELSIF p_numitems_per_oag IS NULL then -- no number specified, send in one message

         x_progress := 'CLN_SYNCCTLG_PKG.Syncctlg_Raise_Event : No Number Limit Specified';
         if (l_debug_level <= 1) then
            cln_debug_pub.Add('Failure point ' || x_progress, 1);
         end if;

         -- create unique key
         SELECT CLN_SYNCCTLG_S.nextval into l_syncctlg_seq from dual;
         if (l_debug_level <= 1) then
            cln_debug_pub.Add('l_syncctlg_seq:'   || l_syncctlg_seq, 1);
         end if;
         l_event_key := to_char(p_list_header_id) || '.' || to_char(l_syncctlg_seq);

         SELECT sysdate into l_date from dual;
         if (l_debug_level <= 1) then
            cln_debug_pub.Add('l_date:'   || l_date, 1);
         end if;
         l_canonical_date := FND_DATE.DATE_TO_CANONICAL(l_date);

         x_progress := 'CLN_SYNCCTLG_PKG.Syncctlg_Raise_Event : Created Unique Key';
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
                                     p_value => l_operating_unit_id,
                                     p_parameterlist => l_create_cln_parameter_list);
         wf_event.AddParameterToList(p_name => 'DOCUMENT_CREATION_DATE',
                                     p_value => l_canonical_date,
                                     p_parameterlist => l_create_cln_parameter_list);

         x_progress := 'CLN_SYNCCTLG_PKG.Syncctlg_Raise_Event : Initialize Create Event Parameters';
         if (l_debug_level <= 1) then
            cln_debug_pub.Add('Failure point ' || x_progress, 1);
         end if;

         -- raise create collaboration event
         wf_event.raise(p_event_name => l_create_cln_event,
                        p_event_key  => l_event_key,
                        p_parameters => l_create_cln_parameter_list);

         x_progress := 'CLN_SYNCCTLG_PKG.Syncctlg_Raise_Event : Create Event Raised';
         if (l_debug_level <= 1) then
            cln_debug_pub.Add('Failure point ' || x_progress, 1);
         end if;

         -- test to see if message contains any items
         OPEN c_ItemsToSend;
         FETCH c_ItemsToSend into l_subset_from;
         if (l_debug_level <= 1) then
            cln_debug_pub.Add('l_subset_from:'   || l_subset_from, 1);
         end if;
         l_subset_from := NULL;

         if c_ItemsToSend%FOUND then
            items_exist := TRUE;
         end if;
         CLOSE c_ItemsToSend;

         x_progress := 'CLN_SYNCCTLG_PKG.Syncctlg_Raise_Event : Items Existence Check';
         if (l_debug_level <= 1) then
            cln_debug_pub.Add('Failure point ' || x_progress, 1);
         end if;

         -- Decision on action depending on XML Setup Check
         if (items_exist) then
            x_progress := 'CLN_SYNCCTLG_PKG.Syncctlg_Raise_Event : Items Exist in Price List';
            if (l_debug_level <= 1) then
               cln_debug_pub.Add('Failure point ' || x_progress, 1);
            end if;

            -- add parameters to list for send show shipment document
            wf_event.AddParameterToList(p_name => 'ECX_TRANSACTION_TYPE',
                                     p_value => transaction_type,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'ECX_TRANSACTION_SUBTYPE',
                                     p_value => transaction_subtype,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'XMLG_INTERNAL_TXN_TYPE',
                                     p_value => transaction_type,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'XMLG_INTERNAL_TXN_SUBTYPE',
                                     p_value => transaction_subtype,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'DOCUMENT_DIRECTION',
                                     p_value => document_direction,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'ECX_PARTY_ID',
                                     p_value => party_id,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'ECX_PARTY_SITE_ID',
                                     p_value => party_site_id,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'ECX_PARTY_TYPE',
                                     p_value => party_type,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'TRADING_PARTNER_ID',
                                     p_value => party_id,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'TRADING_PARTNER_SITE',
                                     p_value => party_site_id,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'TRADING_PARTNER_TYPE',
                                     p_value => party_type,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'ECX_DOCUMENT_ID',
                                     p_value => l_event_key,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'XMLG_DOCUMENT_ID',
                                     p_value => l_event_key,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'DOCUMENT_NO',
                                     p_value => l_event_key,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'MESSAGE_TEXT',
                                     p_value => message_text,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'ORG_ID',
                                     p_value => l_inv_org_id,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'DOCUMENT_CREATION_DATE',
                                     p_value => l_canonical_date,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'ECX_PARAMETER1',
                                     p_value => NULL,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'ECX_PARAMETER2',
                                     p_value => NULL,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'ECX_PARAMETER3',
                                     p_value => NULL,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'ECX_PARAMETER4',
                                     p_value => NULL,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'ECX_PARAMETER5',
                                     p_value => NULL,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'LIST_HEADER_ID',
                                     p_value => p_list_header_id,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'CATEGORY_ID',
                                     p_value => p_category_id,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'FROM_ITEMS',
                                     p_value => p_from_items,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'TO_ITEMS',
                                     p_value => p_to_items,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'CURRENCY',
                                     p_value => p_currency_detail_id,
                                     p_parameterlist => l_send_syct_parameter_list);
            wf_event.AddParameterToList(p_name => 'SUBSET_FROM',
                                        p_value => l_subset_from,
                                        p_parameterlist => l_send_syct_parameter_list);
            wf_event.AddParameterToList(p_name => 'SUBSET_TO',
                                        p_value => l_subset_to,
                                        p_parameterlist => l_send_syct_parameter_list);
            wf_event.AddParameterToList(p_name => 'AUTH_USER_NAME',
                                        p_value => l_auth_user_name,
                                        p_parameterlist => l_send_syct_parameter_list);
            wf_event.AddParameterToList(p_name => 'PUBLISHER_NAME',
                                        p_value => l_auth_user_name,
                                        p_parameterlist => l_send_syct_parameter_list);
            wf_event.AddParameterToList(p_name => 'PUBLISHER_PARTNRIDX',
                                        p_value => l_auth_user_name,
                                        p_parameterlist => l_send_syct_parameter_list);

         x_progress := 'CLN_SYNCCTLG_PKG.Syncctlg_Raise_Event : Send Document Event Parameters Initialized';
         if (l_debug_level <= 1) then
            cln_debug_pub.Add('Failure point ' || x_progress, 1);
         end if;

         -- raise event for send show shipment document
         wf_event.raise(p_event_name => l_send_syct_event,
                        p_event_key  => l_event_key,
                        p_parameters => l_send_syct_parameter_list);

         -- Reached Here. Successful execution.
         x_progress := 'CLN_SYNCCTLG_PKG.Syncctlg_Raise_Event : Send Document Event Raised';
         if (l_debug_level <= 1) then
            cln_debug_pub.Add('Failure point ' || x_progress, 1);
         end if;

         else
            x_progress := 'CLN_SYNCCTLG_PKG.Syncctlg_Raise_Event : No Items Exist in Price List';
            if (l_debug_level <= 1) then
               cln_debug_pub.Add('Failure point ' || x_progress, 1);
            end if;

            -- add parameters to list for update collaboration event
            l_update_cln_parameter_list := wf_parameter_list_t();
            wf_event.AddParameterToList(p_name => 'XMLG_INTERNAL_TXN_TYPE',
                                        p_value => transaction_type,
                                        p_parameterlist => l_update_cln_parameter_list);
            wf_event.AddParameterToList(p_name => 'XMLG_INTERNAL_TXN_SUBTYPE',
                                        p_value => transaction_subtype,
                                        p_parameterlist => l_update_cln_parameter_list);
            wf_event.AddParameterToList(p_name => 'DOCUMENT_DIRECTION',
                                        p_value => document_direction,
                                        p_parameterlist => l_update_cln_parameter_list);
            wf_event.AddParameterToList(p_name => 'XMLG_DOCUMENT_ID',
                                        p_value => l_event_key,
                                        p_parameterlist => l_update_cln_parameter_list);
            wf_event.AddParameterToList(p_name => 'TRADING_PARTNER_ID',
                                        p_value => party_id,
                                        p_parameterlist => l_update_cln_parameter_list);
            wf_event.AddParameterToList(p_name => 'TRADING_PARTNER_SITE',
                                        p_value => party_site_id,
                                        p_parameterlist => l_update_cln_parameter_list);
            wf_event.AddParameterToList(p_name => 'TRADING_PARTNER_TYPE',
                                        p_value => party_type,
                                        p_parameterlist => l_update_cln_parameter_list);
            wf_event.AddParameterToList(p_name => 'DOCUMENT_NO',
                                        p_value => l_event_key,
                                        p_parameterlist => l_update_cln_parameter_list);
            wf_event.AddParameterToList(p_name => 'ORG_ID',
                                        p_value => l_operating_unit_id,
                                        p_parameterlist => l_update_cln_parameter_list);
            wf_event.AddParameterToList(p_name => 'DOCUMENT_STATUS',
                                        p_value => 'ERROR',
                                        p_parameterlist => l_update_cln_parameter_list);
            wf_event.AddParameterToList(p_name => 'MESSAGE_TEXT',
                                        p_value => no_items_message_text,
                                        p_parameterlist => l_update_cln_parameter_list);
            wf_event.AddParameterToList(p_name => 'DOCUMENT_CREATION_DATE',
                                        p_value => l_canonical_date,
                                        p_parameterlist => l_update_cln_parameter_list);

            x_progress := 'CLN_SYNCITEM_PKG.Syncctlg_Raise_Event : Initialize update event parameters';
            if (l_debug_level <= 1) then
                cln_debug_pub.Add('Failure point ' || x_progress, 1);
            end if;

            -- raise update collaboration event
            wf_event.raise(p_event_name => l_update_cln_event,
                           p_event_key  => l_event_key,
                           p_parameters => l_update_cln_parameter_list);

            x_progress := 'CLN_SYNCITEM_PKG.Syncctlg_Raise_Event : Update Event Raised';
            if (l_debug_level <= 1) then
               cln_debug_pub.Add('Failure point ' || x_progress, 1);
            end if;
         end if;

         -- Reached Here. Successful execution.
         x_progress := 'CLN_SYNCCTLG_PKG.Syncctlg_Raise_Event : Exiting No Number Limit Specified Branch';
         if (l_debug_level <= 1) then
            cln_debug_pub.Add('Failure point ' || x_progress, 1);
         end if;
      else -- number of items specified
         x_progress := 'CLN_SYNCCTLG_PKG.Syncctlg_Raise_Event : Number Limit Specified';
         if (l_debug_level <= 1) then
            cln_debug_pub.Add('Failure point ' || x_progress, 1);
         end if;

         -- open cursor for all the documents that will be sent
         OPEN c_ItemsToSend;

         LOOP -- begin of xml documents generation
		counter := 1; -- reset counter
            items_exist := FALSE; -- reset flag

            -- extract first item
            if (l_debug_level <= 1) then
               cln_debug_pub.Add('Parameters:', 1);
               cln_debug_pub.Add('p_numitems_per_oag:'   || p_numitems_per_oag, 1);
            end if;

            if p_numitems_per_oag >= 1 then
               FETCH c_ItemsToSend INTO l_subset_from;
               if (l_debug_level <= 1) then
                  cln_debug_pub.Add('l_subset_from:'   || l_subset_from, 1);
               end if;
               l_subset_to := l_subset_from;

               -- check if there are items left in the cursor. set flag so that you will update with error message.
               if (l_debug_level <= 1) then
                  cln_debug_pub.Add('Parameters:', 1);
               end if;

               if c_ItemsToSend%FOUND then
                  items_exist := TRUE;
               end if;
            end if;

            x_progress := 'CLN_SYNCCTLG_PKG.Syncctlg_Raise_Event : First Item Range' || l_subset_from;
            if (l_debug_level <= 1) then
               cln_debug_pub.Add('Failure point ' || x_progress, 1);
            end if;

            if (l_debug_level <= 1) then
               cln_debug_pub.Add('Parameters:', 1);
               cln_debug_pub.Add('counter:'   || counter, 1);
               cln_debug_pub.Add('p_numitems_per_oag:'   || p_numitems_per_oag, 1);
            end if;

            while counter < p_numitems_per_oag loop
              FETCH c_ItemsToSend INTO l_subset_to; -- extract last item number
              if (l_debug_level <= 1) then
                 cln_debug_pub.Add('l_subset_to:'   || l_subset_to, 1);
              end if;
              EXIT WHEN c_ItemsToSend%NOTFOUND; -- if we reached the end, then just send out what's left
              counter := counter + 1;
            end loop;

            x_progress := 'CLN_SYNCCTLG_PKG.Syncctlg_Raise_Event : Last Item Range' || l_subset_to;
            if (l_debug_level <= 1) then
               cln_debug_pub.Add('Failure point ' || x_progress, 1);
            end if;

            -- create unique key
            SELECT CLN_SYNCCTLG_S.nextval into l_syncctlg_seq from dual;
            if (l_debug_level <= 1) then
               cln_debug_pub.Add('l_syncctlg_seq:'   || l_syncctlg_seq, 1);
            end if;
            l_event_key := to_char(p_list_header_id) || '.' || to_char(l_syncctlg_seq);

            SELECT sysdate into l_date from dual;
            if (l_debug_level <= 1) then
               cln_debug_pub.Add('l_date:'   || l_date, 1);
            end if;
            l_canonical_date := FND_DATE.DATE_TO_CANONICAL(l_date);

            x_progress := 'CLN_SYNCCTLG_PKG.Syncctlg_Raise_Event : Unique key created';
            if (l_debug_level <= 1) then
               cln_debug_pub.Add('Failure point ' || x_progress, 1);
            end if;

            EXIT WHEN items_exist = FALSE; -- if we reached the end, then no items to send

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
                                     p_value => l_operating_unit_id,
                                     p_parameterlist => l_create_cln_parameter_list);
         wf_event.AddParameterToList(p_name => 'DOCUMENT_CREATION_DATE',
                                     p_value => l_canonical_date,
                                     p_parameterlist => l_create_cln_parameter_list);

            x_progress := 'CLN_SYNCCTLG_PKG.Syncctlg_Raise_Event : Create Event Parameters Setup';
            if (l_debug_level <= 1) then
                cln_debug_pub.Add('Failure point ' || x_progress, 1);
            end if;

            -- raise create collaboration event
            wf_event.raise(p_event_name => l_create_cln_event,
                           p_event_key  => l_event_key,
                           p_parameters => l_create_cln_parameter_list);

            x_progress := 'CLN_SYNCCTLG_PKG.Syncctlg_Raise_Event : Create Event Raised';
            if (l_debug_level <= 1) then
               cln_debug_pub.Add('Failure point ' || x_progress, 1);
            end if;

            -- add parameters to list for send show shipment document
            wf_event.AddParameterToList(p_name => 'ECX_TRANSACTION_TYPE',
                                     p_value => transaction_type,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'ECX_TRANSACTION_SUBTYPE',
                                     p_value => transaction_subtype,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'XMLG_INTERNAL_TXN_TYPE',
                                     p_value => transaction_type,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'XMLG_INTERNAL_TXN_SUBTYPE',
                                     p_value => transaction_subtype,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'DOCUMENT_DIRECTION',
                                     p_value => document_direction,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'ECX_PARTY_ID',
                                     p_value => party_id,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'ECX_PARTY_SITE_ID',
                                     p_value => party_site_id,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'ECX_PARTY_TYPE',
                                     p_value => party_type,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'TRADING_PARTNER_ID',
                                     p_value => party_id,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'TRADING_PARTNER_SITE',
                                     p_value => party_site_id,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'TRADING_PARTNER_TYPE',
                                     p_value => party_type,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'ECX_DOCUMENT_ID',
                                     p_value => l_event_key,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'XMLG_DOCUMENT_ID',
                                     p_value => l_event_key,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'DOCUMENT_NO',
                                     p_value => l_event_key,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'MESSAGE_TEXT',
                                     p_value => message_text,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'ORG_ID',
                                     p_value => l_inv_org_id,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'DOCUMENT_CREATION_DATE',
                                     p_value => l_canonical_date,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'ECX_PARAMETER1',
                                     p_value => NULL,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'ECX_PARAMETER2',
                                     p_value => NULL,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'ECX_PARAMETER3',
                                     p_value => NULL,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'ECX_PARAMETER4',
                                     p_value => NULL,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'ECX_PARAMETER5',
                                     p_value => NULL,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'LIST_HEADER_ID',
                                     p_value => p_list_header_id,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'CATEGORY_ID',
                                     p_value => p_category_id,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'FROM_ITEMS',
                                     p_value => p_from_items,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'TO_ITEMS',
                                     p_value => p_to_items,
                                     p_parameterlist => l_send_syct_parameter_list);
         wf_event.AddParameterToList(p_name => 'CURRENCY',
                                     p_value => p_currency_detail_id,
                                     p_parameterlist => l_send_syct_parameter_list);
            wf_event.AddParameterToList(p_name => 'SUBSET_FROM',
                                        p_value => l_subset_from,
                                        p_parameterlist => l_send_syct_parameter_list);
            wf_event.AddParameterToList(p_name => 'SUBSET_TO',
                                        p_value => l_subset_to,
                                        p_parameterlist => l_send_syct_parameter_list);
            wf_event.AddParameterToList(p_name => 'AUTH_USER_NAME',
                                        p_value => l_auth_user_name,
                                        p_parameterlist => l_send_syct_parameter_list);
            wf_event.AddParameterToList(p_name => 'PUBLISHER_NAME',
                                        p_value => l_auth_user_name,
                                        p_parameterlist => l_send_syct_parameter_list);
            wf_event.AddParameterToList(p_name => 'PUBLISHER_PARTNRIDX',
                                        p_value => l_auth_user_name,
                                        p_parameterlist => l_send_syct_parameter_list);

            x_progress := 'CLN_SYNCCTLG_PKG.Syncctlg_Raise_Event : Initialize Send Document Parameters';
            if (l_debug_level <= 1) then
               cln_debug_pub.Add('Failure point ' || x_progress, 1);
            end if;

            -- raise event for send show shipment document
            wf_event.raise(p_event_name => l_send_syct_event,
                           p_event_key  => l_event_key,
                           p_parameters => l_send_syct_parameter_list);

            -- set flag to say that at least one message was previously sent
            msgs_sent_flag := TRUE;

            x_progress := 'CLN_SYNCCTLG_PKG.Syncctlg_Raise_Event : Send Document Event Raised';
            if (l_debug_level <= 1) then
               cln_debug_pub.Add('Failure point ' || x_progress, 1);
            end if;

            EXIT WHEN c_ItemsToSend%NOTFOUND; -- same test again to see if all items have been extracted

         END LOOP;

         -- close cursor when done
         CLOSE c_ItemsToSend;

         if NOT(msgs_sent_flag) then

            x_progress := 'CLN_SYNCCTLG_PKG.Syncctlg_Raise_Event : Price List contains no items';
            if (l_debug_level <= 1) then
               cln_debug_pub.Add('Failure point ' || x_progress, 1);
            end if;

            -- add parameters to list for update collaboration event
            l_update_cln_parameter_list := wf_parameter_list_t();
            wf_event.AddParameterToList(p_name => 'XMLG_INTERNAL_TXN_TYPE',
                                        p_value => transaction_type,
                                        p_parameterlist => l_update_cln_parameter_list);
            wf_event.AddParameterToList(p_name => 'XMLG_INTERNAL_TXN_SUBTYPE',
                                        p_value => transaction_subtype,
                                        p_parameterlist => l_update_cln_parameter_list);
            wf_event.AddParameterToList(p_name => 'DOCUMENT_DIRECTION',
                                        p_value => document_direction,
                                        p_parameterlist => l_update_cln_parameter_list);
            wf_event.AddParameterToList(p_name => 'XMLG_DOCUMENT_ID',
                                        p_value => l_event_key,
                                        p_parameterlist => l_update_cln_parameter_list);
            wf_event.AddParameterToList(p_name => 'TRADING_PARTNER_ID',
                                        p_value => party_id,
                                        p_parameterlist => l_update_cln_parameter_list);
            wf_event.AddParameterToList(p_name => 'TRADING_PARTNER_SITE',
                                        p_value => party_site_id,
                                        p_parameterlist => l_update_cln_parameter_list);
            wf_event.AddParameterToList(p_name => 'TRADING_PARTNER_TYPE',
                                        p_value => party_type,
                                        p_parameterlist => l_update_cln_parameter_list);
            wf_event.AddParameterToList(p_name => 'DOCUMENT_NO',
                                        p_value => l_event_key,
                                        p_parameterlist => l_update_cln_parameter_list);
            wf_event.AddParameterToList(p_name => 'ORG_ID',
                                        p_value => l_operating_unit_id,
                                        p_parameterlist => l_update_cln_parameter_list);
            wf_event.AddParameterToList(p_name => 'DOCUMENT_STATUS',
                                        p_value => 'ERROR',
                                        p_parameterlist => l_update_cln_parameter_list);
            wf_event.AddParameterToList(p_name => 'MESSAGE_TEXT',
                                        p_value => no_items_message_text,
                                        p_parameterlist => l_update_cln_parameter_list);
            wf_event.AddParameterToList(p_name => 'DOCUMENT_CREATION_DATE',
                                        p_value => l_canonical_date,
                                        p_parameterlist => l_update_cln_parameter_list);

            x_progress := 'CLN_SYNCCTLG_PKG.Syncctlg_Raise_Event : Initialized update event parameters';
            if (l_debug_level <= 1) then
                cln_debug_pub.Add('Failure point ' || x_progress, 1);
            end if;

            -- raise update collaboration event
            wf_event.raise(p_event_name => l_update_cln_event,
                           p_event_key  => l_event_key,
                           p_parameters => l_update_cln_parameter_list);

            x_progress := 'CLN_SYNCCTLG_PKG.Syncctlg_Raise_Event : Update Event Raised';
            if (l_debug_level <= 1) then
               cln_debug_pub.Add('Failure point ' || x_progress, 1);
            end if;
         end if;

         -- Reached Here. Successful execution.
         x_progress := 'CLN_SYNCCTLG_PKG.Syncctlg_Raise_Event : Finished Number Limit loop';
         if (l_debug_level <= 1) then
            cln_debug_pub.Add('Failure point ' || x_progress, 1);
         end if;
      end if;

      -- Reached Here. Successful execution.
      if (l_debug_level <= 2) then
         cln_debug_pub.Add('EXITING CLN_SYNCCTLG_PKG.Syncctlg_Raise_Event Successfully', 1);
      end if;
   EXCEPTION
      WHEN OTHERS THEN
         l_error_code := SQLCODE;
         l_error_msg  := SQLERRM;
         if (l_debug_level <= 5) then
            cln_debug_pub.Add('Exception ' || ':'  || l_error_code || ':' || l_error_msg, 1);
         end if;

         x_progress := 'EXITING CLN_SYNCCTLG_PKG.Syncctlg_Raise_Event in Error ';
         if (l_debug_level <= 2) then
            cln_debug_pub.Add('Failure point ' || x_progress, 1);
         end if;
   END Syncctlg_Raise_Event;


END CLN_SYNCCTLG_PKG;

/
