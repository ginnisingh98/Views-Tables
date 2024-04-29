--------------------------------------------------------
--  DDL for Package Body CLN_SHOWSHIP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CLN_SHOWSHIP_PKG" AS
/* $Header: CLNSHSPB.pls 115.13 2004/04/22 21:12:58 cshih noship $ */
   /*=======================================================================+
   | FILENAME
   |   CLNSHSPB.sql
   |
   | DESCRIPTION
   |   PL/SQL package:  CLN_SHOWSHIP_PKG
   |
   | NOTES
   |   Created 1/10/03 chiung-fu.shih
   *=====================================================================*/

   PROCEDURE Showship_Raise_Event(errbuf         OUT NOCOPY      VARCHAR2,
                                  retcode        OUT NOCOPY      VARCHAR2,
                                  p_delivery_id  IN              NUMBER,
dummy1	IN              VARCHAR2,
dummy2	IN              VARCHAR2,
dummy3	IN              VARCHAR2,
dummy4	IN              VARCHAR2,
dummy5	IN              VARCHAR2,
dummy6	IN              VARCHAR2,
dummy7	IN              VARCHAR2,
dummy8	IN              VARCHAR2,
dummy9	IN              VARCHAR2,
dummy10	IN              VARCHAR2,
dummy11	IN              VARCHAR2,
dummy12	IN              VARCHAR2,
dummy13	IN              VARCHAR2,
dummy14	IN              VARCHAR2,
dummy15	IN              VARCHAR2,
dummy16	IN              VARCHAR2,
dummy17	IN              VARCHAR2,
dummy18	IN              VARCHAR2,
dummy19	IN              VARCHAR2,
dummy20	IN              VARCHAR2,
dummy21	IN              VARCHAR2,
dummy22	IN              VARCHAR2,
dummy23	IN              VARCHAR2,
dummy24	IN              VARCHAR2,
dummy25	IN              VARCHAR2,
dummy26	IN              VARCHAR2,
dummy27	IN              VARCHAR2,
dummy28	IN              VARCHAR2,
dummy29	IN              VARCHAR2,
dummy30	IN              VARCHAR2,
dummy31	IN              VARCHAR2,
dummy32	IN              VARCHAR2,
dummy33	IN              VARCHAR2,
dummy34	IN              VARCHAR2,
dummy35	IN              VARCHAR2,
dummy36	IN              VARCHAR2,
dummy37	IN              VARCHAR2,
dummy38	IN              VARCHAR2,
dummy39	IN              VARCHAR2,
dummy40	IN              VARCHAR2,
dummy41	IN              VARCHAR2,
dummy42	IN              VARCHAR2,
dummy43	IN              VARCHAR2,
dummy44	IN              VARCHAR2,
dummy45	IN              VARCHAR2,
dummy46	IN              VARCHAR2,
dummy47	IN              VARCHAR2,
dummy48	IN              VARCHAR2,
dummy49	IN              VARCHAR2,
dummy50	IN              VARCHAR2,
dummy51	IN              VARCHAR2,
dummy52	IN              VARCHAR2,
dummy53	IN              VARCHAR2,
dummy54	IN              VARCHAR2,
dummy55	IN              VARCHAR2,
dummy56	IN              VARCHAR2,
dummy57	IN              VARCHAR2,
dummy58	IN              VARCHAR2,
dummy59	IN              VARCHAR2,
dummy60	IN              VARCHAR2,
dummy61	IN              VARCHAR2,
dummy62	IN              VARCHAR2,
dummy63	IN              VARCHAR2,
dummy64	IN              VARCHAR2,
dummy65	IN              VARCHAR2,
dummy66	IN              VARCHAR2,
dummy67	IN              VARCHAR2,
dummy68	IN              VARCHAR2,
dummy69	IN              VARCHAR2,
dummy70	IN              VARCHAR2,
dummy71	IN              VARCHAR2,
dummy72	IN              VARCHAR2,
dummy73	IN              VARCHAR2,
dummy74	IN              VARCHAR2,
dummy75	IN              VARCHAR2,
dummy76	IN              VARCHAR2,
dummy77	IN              VARCHAR2,
dummy78	IN              VARCHAR2,
dummy79	IN              VARCHAR2,
dummy80	IN              VARCHAR2,
dummy81	IN              VARCHAR2,
dummy82	IN              VARCHAR2,
dummy83	IN              VARCHAR2,
dummy84	IN              VARCHAR2,
dummy85	IN              VARCHAR2,
dummy86	IN              VARCHAR2,
dummy87	IN              VARCHAR2,
dummy88	IN              VARCHAR2,
dummy89	IN              VARCHAR2,
dummy90	IN              VARCHAR2,
dummy91	IN              VARCHAR2,
dummy92	IN              VARCHAR2,
dummy93	IN              VARCHAR2,
dummy94	IN              VARCHAR2,
dummy95	IN              VARCHAR2,
dummy96	IN              VARCHAR2,
dummy97	IN              VARCHAR2,
dummy98	IN              VARCHAR2,
dummy99	IN              VARCHAR2) IS
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

   cnt				   number;

   -- parameters for raising event
   l_send_shsp_event             VARCHAR2(100);
   l_create_cln_event            VARCHAR2(100);
   l_event_key                   VARCHAR2(100);
   l_showship_seq                NUMBER;
   l_send_shsp_parameter_list    wf_parameter_list_t;
   l_create_cln_parameter_list   wf_parameter_list_t;
   l_organization_id             NUMBER;
   l_date                        DATE;
   l_canonical_date              VARCHAR2(100);

   -- parameters needed for time stamp API
   l_time_stamp_date_old         DATE;
   l_time_stamp_seq_old          NUMBER;
   l_time_stamp_date_new         DATE;
   l_time_stamp_seq_new          NUMBER;

   -- cursor to hold the XML Setup Check query and to retrieve the current time stamp date
   CURSOR c_XML_Setup IS
      select hps.party_site_id, hps.party_id, wnd.asn_date_sent, wnd.asn_seq_number, wnd.organization_id
      from   wsh_new_deliveries  wnd, wsh_locations wl, hz_party_sites hps
      where  wnd.delivery_id = p_delivery_id
      and    wnd.ultimate_dropoff_location_id = wl.wsh_location_id
      and    wl.LOCATION_SOURCE_CODE = 'HZ'
      and    wl.SOURCE_LOCATION_ID = hps.location_id;

   BEGIN
      -- initialize parameters
      l_debug_level := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));
      x_progress := '000';
      transaction_type := 'CLN';
      transaction_subtype := 'SHOWSHIPO';
      document_direction := 'OUT';
      message_text := 'CLN_SHSP_MESSAGE_SENT';
      party_type := 'C';
      result := FALSE;
      l_send_shsp_event := 'oracle.apps.cln.event.showship';
      l_create_cln_event := 'oracle.apps.cln.ch.collaboration.create';
      l_send_shsp_parameter_list := wf_parameter_list_t();
      l_create_cln_parameter_list := wf_parameter_list_t();

      x_progress := 'CLN_SHOWSHIP_PKG.Showship_Raise_Event : 01';
      if (l_debug_level <= 1) then
         cln_debug_pub.Add('Failure point ' || x_progress, 1);
      end if;

      -- Getting parameters for XML Setup Check and retrieves current time stamp date
      OPEN c_XML_Setup;
      LOOP
         FETCH c_XML_Setup INTO party_site_id, party_id, l_time_stamp_date_old, l_time_stamp_seq_old, l_organization_id;
         EXIT WHEN c_XML_Setup%NOTFOUND;
      END LOOP;

      cnt := c_XML_Setup%ROWCOUNT;

      x_progress := 'CLN_SHOWSHIP_PKG.Showship_Raise_Event : 02';
      if (l_debug_level <= 1) then
         cln_debug_pub.Add('Failure point ' || x_progress, 1);
      end if;

      -- only perform check if one record is returned
      if(cnt = 1) or NOT(result) then
       -- XML Setup Check
         ecx_document.isDeliveryRequired(
	      transaction_type       => transaction_type,
	      transaction_subtype    => transaction_subtype,
	      party_id	           => party_id,
	      party_site_id	     => party_site_id,
	      resultout	           => result,
	      retcode		     => return_code,
	      errmsg		     => errmsg);

         x_progress := 'CLN_SHOWSHIP_PKG.Showship_Raise_Event : 03';
         if (l_debug_level <= 1) then
            cln_debug_pub.Add('Failure point ' || x_progress, 1);
         end if;
      else
       -- returned more than one record
         result := FALSE;

         x_progress := 'CLN_SHOWSHIP_PKG.Showship_Raise_Event : 04';
         if (l_debug_level <= 1) then
            cln_debug_pub.Add('Failure point ' || x_progress, 1);
         end if;
      end if;

      -- Validations
	select count(*) into cnt
      from   wsh_new_deliveries wnd,
             wsh_delivery_assignments wda
      where  wnd.delivery_id   = wda.delivery_id
      and    wda.delivery_id   = p_delivery_id
      and    wnd.status_code not in ('SR','SC','OP');

      x_progress := 'CLN_SHOWSHIP_PKG.Showship_Raise_Event : 05';
         if (l_debug_level <= 1) then
            cln_debug_pub.Add('Failure point ' || x_progress, 1);
         end if;

      -- Decision on action depending on XML Setup Check and Validations
	if (cnt = 0) or NOT(result) then

         x_progress := 'CLN_SHOWSHIP_PKG.Showship_Raise_Event : 06';
         if (l_debug_level <= 1) then
            cln_debug_pub.Add('Failure point ' || x_progress, 1);
         end if;

      else

         x_progress := 'CLN_SHOWSHIP_PKG.Showship_Raise_Event : 07';
         if (l_debug_level <= 1) then
            cln_debug_pub.Add('Failure point ' || x_progress, 1);
         end if;

         -- create unique key
         SELECT CLN_SHOWSHIP_S.nextval into l_showship_seq from dual;
         l_event_key := to_char(p_delivery_id) || '.' || to_char(l_showship_seq);

         SELECT sysdate into l_date from dual;
         l_canonical_date := FND_DATE.DATE_TO_CANONICAL(l_date);

         x_progress := 'CLN_SHOWSHIP_PKG.Showship_Raise_Event : 08';
         if (l_debug_level <= 1) then
            cln_debug_pub.Add('Failure point ' || x_progress, 1);
         end if;

         -- call time stamp date API to get the new time stamp date
         WSH_ECE_VIEWS_DEF.update_del_asn_info(
              x_delivery_id => p_delivery_id,
              x_time_stamp_sequence_number => l_time_stamp_seq_old,
              x_time_stamp_date => l_time_stamp_date_old,
              x_g_time_stamp_sequence_number => l_time_stamp_seq_new,
              x_g_time_stamp_date => l_time_stamp_date_new);

         x_progress := 'CLN_SHOWSHIP_PKG.Showship_Raise_Event : 09';
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
                                     p_value => p_delivery_id,
                                     p_parameterlist => l_create_cln_parameter_list);
         wf_event.AddParameterToList(p_name => 'ORG_ID',
                                     p_value => l_organization_id,
                                     p_parameterlist => l_create_cln_parameter_list);
         wf_event.AddParameterToList(p_name => 'DOCUMENT_CREATION_DATE',
                                     p_value => l_canonical_date,
                                     p_parameterlist => l_create_cln_parameter_list);

         x_progress := 'CLN_SHOWSHIP_PKG.Showship_Raise_Event : 10';
         if (l_debug_level <= 1) then
            cln_debug_pub.Add('Failure point ' || x_progress, 1);
         end if;

         -- raise create collaboration event
         wf_event.raise(p_event_name => l_create_cln_event,
                        p_event_key  => l_event_key,
                        p_parameters => l_create_cln_parameter_list);

         x_progress := 'CLN_SHOWSHIP_PKG.Showship_Raise_Event : 11';
         if (l_debug_level <= 1) then
            cln_debug_pub.Add('Failure point ' || x_progress, 1);
         end if;

         -- add parameters to list for send show shipment document
         wf_event.AddParameterToList(p_name => 'ECX_TRANSACTION_TYPE',
                                     p_value => transaction_type,
                                     p_parameterlist => l_send_shsp_parameter_list);
         wf_event.AddParameterToList(p_name => 'ECX_TRANSACTION_SUBTYPE',
                                     p_value => transaction_subtype,
                                     p_parameterlist => l_send_shsp_parameter_list);
         wf_event.AddParameterToList(p_name => 'XMLG_INTERNAL_TXN_TYPE',
                                     p_value => transaction_type,
                                     p_parameterlist => l_send_shsp_parameter_list);
         wf_event.AddParameterToList(p_name => 'XMLG_INTERNAL_TXN_SUBTYPE',
                                     p_value => transaction_subtype,
                                     p_parameterlist => l_send_shsp_parameter_list);
         wf_event.AddParameterToList(p_name => 'DOCUMENT_DIRECTION',
                                     p_value => document_direction,
                                     p_parameterlist => l_send_shsp_parameter_list);
         wf_event.AddParameterToList(p_name => 'ECX_PARTY_ID',
                                     p_value => party_id,
                                     p_parameterlist => l_send_shsp_parameter_list);
         wf_event.AddParameterToList(p_name => 'ECX_PARTY_SITE_ID',
                                     p_value => party_site_id,
                                     p_parameterlist => l_send_shsp_parameter_list);
         wf_event.AddParameterToList(p_name => 'ECX_PARTY_TYPE',
                                     p_value => party_type,
                                     p_parameterlist => l_send_shsp_parameter_list);
         wf_event.AddParameterToList(p_name => 'TRADING_PARTNER_ID',
                                     p_value => party_id,
                                     p_parameterlist => l_send_shsp_parameter_list);
         wf_event.AddParameterToList(p_name => 'TRADING_PARTNER_SITE',
                                     p_value => party_site_id,
                                     p_parameterlist => l_send_shsp_parameter_list);
         wf_event.AddParameterToList(p_name => 'TRADING_PARTNER_TYPE',
                                     p_value => party_type,
                                     p_parameterlist => l_send_shsp_parameter_list);
         wf_event.AddParameterToList(p_name => 'ECX_DOCUMENT_ID',
                                     p_value => l_event_key,
                                     p_parameterlist => l_send_shsp_parameter_list);
         wf_event.AddParameterToList(p_name => 'XMLG_DOCUMENT_ID',
                                     p_value => l_event_key,
                                     p_parameterlist => l_send_shsp_parameter_list);
         wf_event.AddParameterToList(p_name => 'DOCUMENT_NO',
                                     p_value => p_delivery_id,
                                     p_parameterlist => l_send_shsp_parameter_list);
         wf_event.AddParameterToList(p_name => 'MESSAGE_TEXT',
                                     p_value => message_text,
                                     p_parameterlist => l_send_shsp_parameter_list);
         wf_event.AddParameterToList(p_name => 'ORG_ID',
                                     p_value => l_organization_id,
                                     p_parameterlist => l_send_shsp_parameter_list);
         wf_event.AddParameterToList(p_name => 'DOCUMENT_CREATION_DATE',
                                     p_value => l_canonical_date,
                                     p_parameterlist => l_send_shsp_parameter_list);
         wf_event.AddParameterToList(p_name => 'ECX_PARAMETER1',
                                     p_value => l_time_stamp_date_new,
                                     p_parameterlist => l_send_shsp_parameter_list);
         wf_event.AddParameterToList(p_name => 'ECX_PARAMETER2',
                                     p_value => p_delivery_id,
                                     p_parameterlist => l_send_shsp_parameter_list);

         -- raise event for send show shipment document
         wf_event.raise(p_event_name => l_send_shsp_event,
                        p_event_key  => l_event_key,
                        p_parameters => l_send_shsp_parameter_list);

         -- Reached Here. Successful execution.
         x_progress := 'CLN_SHOWSHIP_PKG.Showship_Raise_Event : 12';
         if (l_debug_level <= 1) then
            cln_debug_pub.Add('Failure point ' || x_progress, 1);
         end if;
      end if;
   EXCEPTION
      WHEN OTHERS THEN
         l_error_code := SQLCODE;
         l_error_msg  := SQLERRM;
         if (l_debug_level <= 1) then
            cln_debug_pub.Add('Exception ' || ':'  || l_error_code || ':' || l_error_msg, 1);
         end if;

         x_progress := 'CLN_SHOWSHIP_PKG.Showship_Raise_Event : 13';
         if (l_debug_level <= 1) then
            cln_debug_pub.Add('Failure point ' || x_progress, 1);
         end if;
   END Showship_Raise_Event;

END CLN_SHOWSHIP_PKG;

/
