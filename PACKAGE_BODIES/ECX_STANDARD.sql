--------------------------------------------------------
--  DDL for Package Body ECX_STANDARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECX_STANDARD" as
-- $Header: ECXWACTB.pls 120.1.12010000.3 2009/02/24 21:51:10 cpeixoto ship $

/** bug 3357213 */
/**
 * Other errors
*/
PROCESSOR_ERR CONSTANT NUMBER := -20100;
NULL_ERR CONSTANT NUMBER := -20103;
G_PKG_NAME      CONSTANT    VARCHAR2(15):=  'ECX_STANDARD';
/** bug 3357213 */

MAX_JAVA_MEMORY CONSTANT NUMBER := 1 * 1024 * 1024 *1024;  -- bug 6889689


function setMaxJavaMemorySize(num number) return number     -- bug 6889689
is language java name
'oracle.aurora.vm.OracleRuntime.setMaxMemorySize(long) returns long';


procedure addItemAttributes
	(
	itemtype	in	varchar2,
	itemkey		in	varchar2
	)
is
begin
	begin
		wf_engine.SetItemAttrNumber(itemtype,itemkey,'ECX_ERROR_TYPE',ecx_utils.error_type);
	exception
	when others then

		-- If item attribute does not exist then create it;

		if ( wf_core.error_name = 'WFENG_ITEM_ATTR' ) then
			wf_engine.AddItemAttr(itemtype,itemkey,'ECX_ERROR_TYPE',null,ecx_utils.error_type,null);
		else
			raise;
		end if;
	end;

	begin
		wf_engine.SetItemAttrText(itemtype,itemkey,'ECX_LOG_FILE',ecx_utils.g_logfile);
	exception
	when others then

		-- If item attribute does not exist then create it;

		if ( wf_core.error_name = 'WFENG_ITEM_ATTR' ) then
			wf_engine.AddItemAttr(itemtype,itemkey,'ECX_LOG_FILE',ecx_utils.g_logfile,null,null);
		else
			raise;
		end if;
	end;
exception
when others then
	raise;
end addItemAttributes;

procedure prepareWS(itemtype   in            VARCHAR2,
                    itemkey    in            VARCHAR2,
                    actid      in            NUMBER,
                    p_event    in out nocopy WF_EVENT_T)
is

  i_ws_soapaction          VARCHAR2(240)       := NULL;
  i_ws_svc_namespace       VARCHAR2(240)       := NULL;
  i_ws_port_operation      VARCHAR2(240)       := NULL;
  i_ws_hdr_impl_class      VARCHAR2(240)       := NULL;
  i_ws_res_impl_class      VARCHAR2(240)       := NULL;
  i_ws_consumer            VARCHAR2(240)       := NULL;
  i_parameterList          WF_PARAMETER_LIST_T := NULL;

begin

   if (p_event is not null) then
     i_parameterList := wf_event_t.getParameterList(p_event);

     -- Retrieve or default Web Services related event parameters if exists
     i_ws_soapaction := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'SOAPACTION', true);
     if (i_ws_soapaction is null) then
         i_ws_soapaction := Wf_Engine.GetItemAttrText(itemtype, itemkey, 'SOAPACTION', true);
         if (i_ws_soapaction is null) and (i_parameterList is not null) then
             i_ws_soapaction := wf_event.getValueForParameter('SOAPACTION', i_parameterList);
         end if;
     end if;
     if (i_ws_soapaction is null) then
         i_ws_soapaction := ' '; -- defaulting
     end if;

     i_ws_svc_namespace := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'WS_SERVICE_NAMESPACE', true);
     if (i_ws_svc_namespace is null) then
         i_ws_svc_namespace := Wf_Engine.GetItemAttrText(itemtype, itemkey, 'WS_SERVICE_NAMESPACE', true);
         if (i_ws_svc_namespace is null) and (i_parameterList is not null) then
             i_ws_svc_namespace := wf_event.getValueForParameter('WS_SERVICE_NAMESPACE', i_parameterList);
         end if;
     end if;
     if (i_ws_svc_namespace is null) then
           i_ws_svc_namespace := 'http://xmlns.oracle.com/apps/fnd/XMLGateway'; -- defaulting
     end if;

     i_ws_port_operation :=  Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'WS_PORT_OPERATION', true);
     if (i_ws_port_operation is null) then
         i_ws_port_operation := Wf_Engine.GetItemAttrText(itemtype, itemkey, 'WS_PORT_OPERATION', true);
         if (i_ws_port_operation is null) and (i_parameterList is not null) then
             i_ws_port_operation := wf_event.getValueForParameter('WS_PORT_OPERATION', i_parameterList);
         end if;
     end if;
     if (i_ws_port_operation is null) then
         i_ws_port_operation := 'ReceiveDocument'; -- defaulting
     end if;

     i_ws_hdr_impl_class := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'WS_HEADER_IMPL_CLASS', true);
     if (i_ws_hdr_impl_class is null) then
         i_ws_hdr_impl_class := Wf_Engine.GetItemAttrText(itemtype, itemkey, 'WS_HEADER_IMPL_CLASS', true);
         if (i_ws_hdr_impl_class is null) and (i_parameterList is not null) then
             i_ws_hdr_impl_class := wf_event.getValueForParameter('WS_HEADER_IMPL_CLASS', i_parameterList);
         end if;
     end if;
     if (i_ws_hdr_impl_class is null) then
         i_ws_hdr_impl_class := 'oracle.apps.fnd.wf.ws.client.DefaultHeaderGenerator'; -- defaulting
     end if;

     i_ws_res_impl_class := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'WS_RESPONSE_IMPL_CLASS', true);
     if (i_ws_res_impl_class is null) then
         i_ws_res_impl_class := Wf_Engine.GetItemAttrText(itemtype, itemkey, 'WS_RESPONSE_IMPL_CLASS', true);
         if (i_ws_res_impl_class is null) and (i_parameterList is not null) then
             i_ws_res_impl_class := wf_event.getValueForParameter('WS_RESPONSE_IMPL_CLASS', i_parameterList);
         end if;
     end if;
     if (i_ws_res_impl_class is null) then
         i_ws_res_impl_class := 'oracle.apps.fnd.wf.ws.client.WfWsResponse'; -- defaulting
     end if;

     i_ws_consumer := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'WS_CONSUMER', true);
     if (i_ws_consumer is null) then
         i_ws_consumer := Wf_Engine.GetItemAttrText(itemtype, itemkey, 'WS_CONSUMER', true);
         if (i_ws_consumer is null) and (i_parameterList is not null) then
             i_ws_consumer := wf_event.getValueForParameter('WS_CONSUMER', i_parameterList);
         end if;
     end if;
     if (i_ws_consumer is null) then
         i_ws_consumer := 'ecx'; -- defaulting
     end if;

     -- add these properties to p_event
     p_event.addParameterToList('SOAPACTION', i_ws_soapaction);
     p_event.addParameterToList('WS_SERVICE_NAMESPACE', i_ws_svc_namespace);
     p_event.addParameterToList('WS_PORT_OPERATION', i_ws_port_operation);
     p_event.addParameterToList('WS_HEADER_IMPL_CLASS', i_ws_hdr_impl_class);
     p_event.addParameterToList('WS_RESPONSE_IMPL_CLASS', i_ws_res_impl_class);
     p_event.addParameterToList('WS_CONSUMER', i_ws_consumer);

   end if;

exception
   when others then
      raise;
end prepareWS;


procedure XMLtoXMLCover
	(
	i_map_code              IN         varchar2,
	i_inpayload		IN	   CLOB,
	i_outpayload		OUT NOCOPY CLOB,
	i_debug_level           IN      pls_integer
	)
is
retcode			pls_integer;
errmsg			varchar2(2000);
logfile			varchar2(200);
g_instlmode		varchar2(100);
begin
  	ecx_inbound_trig.ProcessXML
		(
		i_map_code,
		i_inpayload,
		i_debug_level,
		retcode,
		errmsg,
		logfile,
		i_outpayload
		);

	if retcode = 0
	then
		return;
	elsif retcode = 1
	then
		g_instlmode := wf_core.translate('WF_INSTALL');
		IF g_instlmode = 'EMBEDDED'
		THEN
			wf_core.token('ECX_ERRMSG',ecx_debug.getMessage(errmsg,
                                           ecx_utils.i_errparams));
			wf_core.token('ECX_LOGFILE',logfile);
			wf_core.raise('ECX_PROCESS_XMLERROR_EMBD');
		ELSE
			wf_core.token('ECX_ERRMSG',ecx_debug.getMessage(errmsg,
                                           ecx_utils.i_errparams));
			wf_core.token('ECX_LOGFILE',logfile);
			wf_core.raise('ECX_PROCESS_XMLERROR');
		END IF;
	else
		g_instlmode := wf_core.translate('WF_INSTALL');
		IF g_instlmode = 'EMBEDDED'
		THEN
			wf_core.token('ECX_ERRMSG',ecx_debug.getMessage(errmsg,
                                           ecx_utils.i_errparams));
			wf_core.token('ECX_LOGFILE',logfile);
			wf_core.raise('ECX_PROGRAM_EXIT_EMBD');
		ELSE
			wf_core.token('ECX_ERRMSG',ecx_debug.getMessage(errmsg,
                                           ecx_utils.i_errparams));
			wf_core.token('ECX_LOGFILE',logfile);
			wf_core.raise('ECX_PROGRAM_EXIT');
		END IF;
	end if;
exception
when others then
    wf_core.context('ECX_STANDARD','XMLtoXMLCover',i_map_code,i_debug_level);
    raise;
end XMLtoXMLCover;

procedure processXMLCover
	(
	i_map_code              IN      varchar2,
	i_inpayload		IN	CLOB,
	i_debug_level           IN      pls_integer
	)
is
retcode			pls_integer;
errmsg			varchar2(2000);
logfile			varchar2(200);
i_outpayload		CLOB;
g_instlmode		varchar2(100);
begin
  	ecx_inbound_trig.ProcessXML
		(
		i_map_code,
		i_inpayload,
		i_debug_level,
		retcode,
		errmsg,
		logfile,
		i_outpayload
		);

	if retcode = 0
	then
		return;
	elsif retcode = 1
	then
		g_instlmode := wf_core.translate('WF_INSTALL');
		IF g_instlmode = 'EMBEDDED'
		THEN
			wf_core.token('ECX_ERRMSG',ecx_debug.getMessage(errmsg,
                                           ecx_utils.i_errparams));
			wf_core.token('ECX_LOGFILE',logfile);
			wf_core.raise('ECX_PROCESS_XMLERROR_EMBD');
		ELSE
			wf_core.token('ECX_ERRMSG',ecx_debug.getMessage(errmsg,
                                           ecx_utils.i_errparams));
			wf_core.token('ECX_LOGFILE',logfile);
			wf_core.raise('ECX_PROCESS_XMLERROR');
		END IF;
	else
		g_instlmode := wf_core.translate('WF_INSTALL');
		IF g_instlmode = 'EMBEDDED'
		THEN
			wf_core.token('ECX_ERRMSG',ecx_debug.getMessage(errmsg,
                                           ecx_utils.i_errparams));
			wf_core.token('ECX_LOGFILE',logfile);
			wf_core.raise('ECX_PROGRAM_EXIT_EMBD');
		ELSE
			wf_core.token('ECX_ERRMSG',ecx_debug.getMessage(errmsg,
                                           ecx_utils.i_errparams));
			wf_core.token('ECX_LOGFILE',logfile);
			wf_core.raise('ECX_PROGRAM_EXIT');
		END IF;
	end if;
exception
when others then
    wf_core.context('ECX_STANDARD','processXMLCover',i_map_code,i_debug_level);
    raise;
end processXMLCover;

procedure getXMLCover
	(
	i_message_standard      IN      VARCHAR2 default null,
	i_transaction_type      IN      VARCHAR2 default null,
	i_transaction_subtype   IN      VARCHAR2 default null,
        i_tp_type               IN      VARCHAR2 default null,
	i_tp_id			IN	VARCHAR2 default null,
	i_tp_site_id		IN	VARCHAR2 default null,
	i_document_id		IN	VARCHAR2 default null,
        i_map_code              IN      VARCHAR2,
	i_debug_level		IN	pls_integer,
	i_xmldoc		IN OUT  NOCOPY CLOB,
	i_message_type          IN      VARCHAR2 default 'XML'
	)
is
retcode			pls_integer;
errmsg			varchar2(2000);
logfile			varchar2(200);
g_instlmode		varchar2(100);
begin
  	ecx_outbound.getXML
			(
                        i_message_standard      => i_message_standard,
			i_map_code 		=> i_map_code,
			i_transaction_type 	=> i_transaction_type,
			i_transaction_subtype 	=> i_transaction_subtype,
                        i_tp_type               => i_tp_type,
			i_tp_id			=> i_tp_id,
			i_tp_site_id		=> i_tp_site_id,
        		i_document_id 		=> i_document_id,
	               	i_debug_level		=> i_debug_level,
	               	i_xmldoc 		=> i_xmldoc,
	               	i_ret_code 		=> retcode,
	               	i_errbuf 		=> errmsg,
	               	i_log_file		=> logfile,
                        i_message_type          => i_message_type
			);
	if retcode = 0
	then
		return;
	elsif retcode = 1
	then
		g_instlmode := wf_core.translate('WF_INSTALL');
		IF g_instlmode = 'EMBEDDED'
		THEN
			wf_core.token('ECX_ERRMSG',ecx_debug.getMessage(errmsg,
                                           ecx_utils.i_errparams));
			wf_core.token('ECX_LOGFILE',logfile);
			wf_core.raise('ECX_GET_XMLERROR_EMBD');
		ELSE
			wf_core.token('ECX_ERRMSG',ecx_debug.getMessage(errmsg,
                                           ecx_utils.i_errparams));
			wf_core.token('ECX_LOGFILE',logfile);
			wf_core.raise('ECX_GET_XMLERROR');
		END IF;
	else
		g_instlmode := wf_core.translate('WF_INSTALL');
		IF g_instlmode = 'EMBEDDED'
		THEN
			wf_core.token('ECX_ERRMSG',ecx_debug.getMessage(errmsg,
                                           ecx_utils.i_errparams));
			wf_core.token('ECX_LOGFILE',logfile);
			wf_core.raise('ECX_PROGRAM_EXIT_EMBD');
		ELSE
			wf_core.token('ECX_ERRMSG',ecx_debug.getMessage(errmsg,
                                           ecx_utils.i_errparams));
			wf_core.token('ECX_LOGFILE',logfile);
			wf_core.raise('ECX_PROGRAM_EXIT');
		END IF;
	end if;
exception
when others then
    wf_core.context('ECX_STANDARD','getXMLCover',i_message_standard,i_transaction_type,i_transaction_subtype);
    raise;
end getXMLCover;

/** (Synchronous) Send Direct api to avoid racing condition **/
procedure sendDirectCover(
        transaction_type      	IN     VARCHAR2,
        transaction_subtype    	IN     VARCHAR2,
	party_id		IN     VARCHAR2,
	party_site_id		IN     VARCHAR2,
        party_type              IN     VARCHAR2,  --bug #2183619
        document_id           	IN     VARCHAR2,
        debug_mode            	IN     PLS_INTEGER,
	i_msgid			OUT    NOCOPY RAW
	)
is
retcode			pls_integer;
errmsg			varchar2(2000);
g_instlmode		varchar2(100);
begin

     	ecx_document.sendDirect
			     (
			     transaction_type 	 => transaction_type,
			     transaction_subtype => transaction_subtype,
			     party_id 		 => party_id,
			     party_site_id 	 => party_site_id,
                             party_type         => party_type,--bug #2183619
			     document_id 	 => document_id,
			     debug_mode 	 => debug_mode,
			     i_msgid 		 => i_msgid,
			     retcode 		 => retcode,
			     errmsg 		 => errmsg
			     );
	if retcode = 0
	then
		return;
	elsif retcode = 1
	then
		g_instlmode := wf_core.translate('WF_INSTALL');
		IF g_instlmode = 'EMBEDDED'
		THEN
			wf_core.token('ECX_ERRMSG',ecx_debug.getMessage(errmsg,
                                           ecx_utils.i_errparams));
	        	wf_core.token('ECX_LOGFILE',ecx_utils.g_logfile);
			wf_core.raise('ECX_SENDDIRECT_ERROR_EMBD');
		ELSE
			wf_core.token('ECX_ERRMSG',ecx_debug.getMessage(errmsg,
                                           ecx_utils.i_errparams));
	        	wf_core.token('ECX_LOGFILE',ecx_utils.g_logfile);
			wf_core.raise('ECX_SENDDIRECT_ERROR');
		END IF;
	else
		g_instlmode := wf_core.translate('WF_INSTALL');
		IF g_instlmode = 'EMBEDDED'
		THEN
			wf_core.token('ECX_ERRMSG',ecx_debug.getMessage(errmsg,
                                           ecx_utils.i_errparams));
			wf_core.token('ECX_LOGFILE',ecx_utils.g_logfile);
			wf_core.raise('ECX_PROGRAM_EXIT_EMBD');
		ELSE
			wf_core.token('ECX_ERRMSG',ecx_debug.getMessage(errmsg,
                                           ecx_utils.i_errparams));
			wf_core.token('ECX_LOGFILE',ecx_utils.g_logfile);
			wf_core.raise('ECX_PROGRAM_EXIT');
		END IF;
	end if;
exception
when others then
    wf_core.context('ECX_STANDARD','sendDirectCover',transaction_type,transaction_subtype);
    raise;
end sendDirectCover;


-- setEventDetails (PUBLIC)
--   Standard XML Gateway Raise Event
-- IN:
--   eventname      - Event to be processes
--   eventkey       - Event key
--   parameter1..10 - Event Parameters
-- NOTE:
--   Called from the XML gateway engine as a post processing action
--
-- VS - Why only parameters 1.10?  Why not the the full 100?
-- We will change when the pl/sql has the capability to bind the PL/SQL table as datatype.
procedure setEventDetails(
        eventname       in      varchar2,
        eventkey        in      varchar2,
        parameter1      in      varchar2,
        parameter2      in      varchar2,
        parameter3      in      varchar2,
        parameter4      in      varchar2,
        parameter5      in      varchar2,
        parameter6      in      varchar2,
        parameter7      in      varchar2,
        parameter8      in      varchar2,
        parameter9      in      varchar2,
        parameter10     in      varchar2,
        retcode         OUT NOCOPY pls_integer,
        retmsg          OUT NOCOPY varchar2)
is
  x_from_agt            wf_agent_t := wf_agent_t(null,null);
  x_to_agt              wf_agent_t := wf_agent_t(null,null);

begin
  wf_event_t.initialize(ecx_utils.g_event);
  /**
    Set the Event Data with the passed in parameters,
    so that the Business Event can be raised.
  **/

  ecx_utils.g_event.setEventName(ltrim(rtrim(eventName)));
  ecx_utils.g_event.setEventKey(ltrim(rtrim(eventKey)));

  /**
      x_from_agt has to be set.
      In this case, what is the from agent? Inbound engine?!
      Setting it to null for now.
   **/

  ecx_utils.g_event.from_agent := x_from_agt ;
  ecx_utils.g_event.to_agent := x_to_agt ;

  ecx_utils.g_event.addParameterToList('PARAMETER1', parameter1);
  ecx_utils.g_event.addParameterToList('PARAMETER2', parameter2);
  ecx_utils.g_event.addParameterToList('PARAMETER3', parameter3);
  ecx_utils.g_event.addParameterToList('PARAMETER4', parameter4);
  ecx_utils.g_event.addParameterToList('PARAMETER5', parameter5);
  ecx_utils.g_event.addParameterToList('PARAMETER6', parameter6);
  ecx_utils.g_event.addParameterToList('PARAMETER7', parameter7);
  ecx_utils.g_event.addParameterToList('PARAMETER8', parameter8);
  ecx_utils.g_event.addParameterToList('PARAMETER9', parameter9);
  ecx_utils.g_event.addParameterToList('PARAMETER10', parameter10);

  retcode :=0;
  retmsg := ecx_debug.getTranslatedMessage('ECX_BUSINESS_EVT_SET');

exception
  when others then
	retcode := 2;
        retmsg := ecx_debug.getTranslatedMessage('ECX_BUSINESS_EVT_SET_ERROR');
        wf_core.raise('ECX_EVENT_ERROR');
end setEventDetails;


-- Generate (PUBLIC)
--   Standard XML Gateway to generate event data
-- IN:
--   p_event_name     - Event to be processes
--   p_event_key      - Event key
--   p_parameter_list - parameter list
-- OUT
--   CLOB	    - Event data
-- NOTE:
--   Called from the XML gateway engine as a post processing action
--
-- KH Comment: Do we need a version of this ofr the A2A case. map_code,doc_id only

function generate
		(
		p_event_name	    	in	varchar2,
		p_event_key	    	in 	varchar2,
        	p_parameter_list 	in 	wf_parameter_list_t
		) return CLOB
is
  p_ret_code		pls_integer;
  p_errbuf		varchar2(2000);
  p_xmldoc		clob;
  ecx_getxml    	exception;
  transaction_type	varchar2(240);
  transaction_subtype	varchar2(240);
  party_id		varchar2(240);
  party_site_id		varchar2(240);
  document_id		varchar2(240);
  debug_level		pls_integer:=0;
  map_code		varchar2(200);
begin


  -- VS - map_code = event_name WHY...Lets's discuss
  --      map_code ect. should come from paramter list

  dbms_lob.createtemporary(p_xmldoc,true,dbms_lob.session);
  map_code := wf_event.getValueForParameter('ECX_MAP_CODE',p_parameter_list);
  debug_level := wf_event.getValueForParameter('ECX_DEBUG_LEVEL',p_parameter_list);
  /** Which exception to use here for throwing the Error to BES **/
  if (map_code is null ) then
     wf_core.token('MAP_CODE','NULL');
     wf_core.raise('WFSQL_ARGS');
  end if;

  /** Everything else is optional set of parameters **/
  transaction_type 	:= wf_event.getValueForParameter('ECX_TRANSACTION_TYPE',p_parameter_list);
  transaction_subtype 	:= wf_event.getValueForParameter('ECX_TRANSACTION_SUBTYPE',p_parameter_list);
  party_id 		:= wf_event.getValueForParameter('ECX_PARTY_ID',p_parameter_list);
  party_site_id 	:= wf_event.getValueForParameter('ECX_PARTY_SITE_ID',p_parameter_list);
  document_id 		:= wf_event.getValueForParameter('ECX_DOCUMENT_ID',p_parameter_list);

   if ecx_utils.g_event is null
   then
   	wf_event_t.initialize(ecx_utils.g_event);
   end if;

   ecx_utils.g_event.setparameterlist(p_parameter_list);


  		getXMLCover
			(
			i_map_code 		=> map_code,
			i_transaction_type 	=> transaction_type,
			i_transaction_subtype 	=> transaction_subtype,
			i_tp_id			=> party_id,
			i_tp_site_id		=> party_site_id,
        		i_document_id 		=> document_id,
	               	i_debug_level		=> debug_level,
	               	i_xmldoc 		=> p_xmldoc
			);

	-- Removed for time being as the parameters are IN type only.
  	--wf_event.addParameterToList('ECX_ERROR_TYPE', ecx_utils.error_type,p_parameter_list);
  	--wf_event.addParameterToList('ECX_LOG_FILE', ecx_utils.g_logfile,p_parameter_list);
  	--dbms_lob.freetemporary(p_xmldoc);
   	return p_xmldoc;
exception
when others then
    wf_core.context('ECX_STANDARD', 'Generate', p_event_name, p_event_key);
    raise;
end Generate;

-- XMLtoXML
--   Standard Workflow Activity XMLtoXML
--   Processes a given XML. The Output is an XML /a API call.
-- OUT
--   result - null
-- ACTIVITY ATTRIBUTES REFERENCED
--   MAP_CODE          - text value  (required)
--   ECX_EVENT_MESSAGE_IN     -  event value (required )
--   ECX_EVENT_MESSAGE_OUT     - event value (optional )
-- NOTE:

procedure XMLtoXML  (itemtype   in varchar2,
		     itemkey    in varchar2,
		     actid      in number,
		     funcmode   in varchar2,
		     resultout  in out NOCOPY varchar2	)
is
  i_debug_level		pls_integer;
  i_map_code		varchar2(200);
  i_outpayload		clob;
  i_log_file		varchar2(2000);
  i_ret_code		pls_integer;
  i_errbuf		varchar2(2000);
  i_inevent		wf_event_t;
  i_outevent		wf_event_t;
  ecx_process_xml 	exception;
  i_error_type		pls_integer;
  aname_error_type	varchar2(30);
  aname_log_file	varchar2(30);
  aname                 varchar2(30);
  atype                 varchar2(8);
  aformat               varchar2(240);
  asubtype              varchar2(8);
  a1name                 varchar2(30);
  a1type                 varchar2(8);
  a1format               varchar2(240);
  a1subtype              varchar2(8);

begin
  -- Set the Global itemtype,itemkey and the activity_id
  ecx_utils.g_item_type := itemtype;
  ecx_utils.g_item_key := itemkey;
  ecx_utils.g_activity_id := actid;

  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then
    resultout := wf_engine.eng_null;
    return;
  end if;

  -- Get ecx map code

  i_map_code  := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'ECX_MAP_CODE');
  if (i_map_code is null ) then
     wf_core.token('ECX_MAP_CODE','NULL');
     wf_core.raise('WFSQL_ARGS');
  end if;



  i_debug_level  	:= nvl(wf_engine.GetItemAttrText(itemtype,itemkey,'ECX_DEBUG_LEVEL',true),0);


    -- Verify that the attr type = EVENT

	i_inevent  := Wf_Engine.GetActivityAttrEvent(itemtype, itemkey, actid, 'ECX_EVENT_MESSAGE_IN');
	if (i_inevent is null ) then
		wf_core.token('ECX_EVENT_MESSAGE_IN','NULL');
		wf_core.raise('WFSQL_ARGS');
	end if;

	aname := wf_engine.GetActivityAttrText(itemtype, itemkey, actid, 'ECX_EVENT_MESSAGE_OUT');
	if ( aname is null ) then
		wf_core.token('ECX_EVENT_MESSAGE_OUT','NULL');
		wf_core.raise('WFSQL_ARGS');
	end if;

	--Wf_Engine.GetItemAttrInfo(itemtype, aname ,atype, asubtype, aformat);
	--if (atype <> 'EVENT' ) then
		--wf_core.token('VTYPE',atype);
		--wf_core.raise('WFXXXV_VTYPE');
	--end if;

	i_outevent  := Wf_Engine.GetItemAttrEvent(itemtype, itemkey, aname);

  -- extract payload and pass to ECX

  	XMLtoXMLCover
		(
		i_map_code,
		i_inevent.event_data,
		i_outevent.event_data,
		i_debug_level
		);

	addItemAttributes(itemtype,itemkey);
	wf_engine.SetItemAttrEvent(itemtype,itemkey,aname,i_outevent);

  resultout := 'COMPLETE:';
exception
when others then
    Wf_Core.Context('ECX_STANDARD', 'XMLtoXML',itemtype,itemkey, to_char(actid), funcmode);
    raise;
end XMLtoXML;

procedure ProcessXML(itemtype   in varchar2,
		     itemkey    in varchar2,
		     actid      in number,
		     funcmode   in varchar2,
		     resultout  in out NOCOPY varchar2	)
is
  i_debug_level		pls_integer;
  i_map_code		varchar2(200);
  i_payload		clob;
  i_outpayload		clob;
  i_log_file		varchar2(2000);
  i_ret_code		pls_integer;
  i_errbuf		varchar2(2000);
  i_event		wf_event_t;
  ecx_process_xml 	exception;
  i_error_type		pls_integer;
  aname_error_type	varchar2(30);
  aname_log_file	varchar2(30);

begin
  -- Set the Global itemtype,itemkey and the activity_id
  ecx_utils.g_item_type := itemtype;
  ecx_utils.g_item_key := itemkey;
  ecx_utils.g_activity_id := actid;

  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then
    resultout := wf_engine.eng_null;
    return;
  end if;

  -- Get ecx map code

  i_map_code  := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'ECX_MAP_CODE');
  if (i_map_code is null ) then
     wf_core.token('ECX_MAP_CODE','NULL');
     wf_core.raise('WFSQL_ARGS');
  end if;



  i_debug_level  := nvl(wf_engine.GetItemAttrText(itemtype,itemkey,'ECX_DEBUG_LEVEL',true),0);
  i_event  := Wf_Engine.GetActivityAttrEvent(itemtype, itemkey, actid, 'ECX_EVENT_MESSAGE');
  if (i_event is null ) then
     wf_core.token('ECX_EVENT_MESSAGE','NULL');
     wf_core.raise('WFSQL_ARGS');
  end if;

  -- extract payload and pass to ECX

  i_payload := i_event.event_data;

  	processXMLCover
		(
		i_map_code,
		i_payload,
		i_debug_level
		);

	addItemAttributes(itemtype,itemkey);


  resultout := 'COMPLETE:';
exception
  when others then
    Wf_Core.Context('ECX_STANDARD', 'PROCESSXML',itemtype,itemkey, to_char(actid), funcmode);
    raise;
end processXML;

-- IsDeliveryRequired
--   Standard ECX Workflow Activity
--   Determine if trading partner is enabled to recieve document
-- OUT
--   result - T - Trading Partner is enabled
--            F - Trading Partner is NOT enabled
-- ACTIVITY ATTRIBUTES REFERENCED
--   TRANSACTION_TYPE    - text value (required)
--   TRANSACTION_SUBTYPE - text value (required)
--   PARTY_ID		 - text value (required)
--   PARTY_SITE_ID	 - text value (optional)
-- NOTE:

procedure isDeliveryRequired (itemtype   in varchar2,
                     	      itemkey    in varchar2,
                     	      actid      in number,
                     	      funcmode   in varchar2,
                              resultout  in out NOCOPY varchar2)
is
  transaction_type   	 varchar2(240);
  transaction_subtype    varchar2(240);
  party_id	      	 varchar2(240);
  party_site_id	      	 varchar2(240);
  party_type             VARCHAR2(300); --Bug #2183619
  aname                  varchar2(30);  --Bug #2215677
  retcode		 pls_integer;
  errmsg		 varchar2(2000);
  result		boolean := FALSE;
  i_confirmation	 number; --Bug #2215677
  g_instlmode		varchar2(100);
begin

  -- Set the Global itemtype,itemkey and the activity_id
  ecx_utils.g_item_type := itemtype;
  ecx_utils.g_item_key := itemkey;
  ecx_utils.g_activity_id := actid;

  -- Do nothing in cancel or timeout mode

  if (funcmode <> wf_engine.eng_run) then
    resultout := wf_engine.eng_null;
    return;
  end if;

  -- Retreive Activity Attributes

  transaction_type  := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'ECX_TRANSACTION_TYPE');
  if ( transaction_type is null ) then
	wf_core.token('ECX_TRANSACTION_TYPE','NULL');
        wf_core.raise('WFSQL_ARGS');
  end if;

  transaction_subtype  := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'ECX_TRANSACTION_SUBTYPE');
  if ( transaction_subtype is null ) then
	wf_core.token('ECX_TRANSACTION_SUBTYPE','NULL');
        wf_core.raise('WFSQL_ARGS');
  end if;

  party_site_id  := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'ECX_PARTY_SITE_ID');
  if ( party_site_id is null ) then
	wf_core.token('ECX_PARTY_SITE_ID','NULL');
        wf_core.raise('WFSQL_ARGS');
  end if;

  -- party_id is optional. Only party_site_id is required

  party_id  := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'ECX_PARTY_ID');
  /* Start of bug #2183619 */
  party_type  := Wf_Engine.GetActivityAttrText(itemtype, itemkey,actid, 'ECX_PARTY_TYPE', true);
  /* End of bug #2183619*/

  /* Start of changes for Bug #2215677*/
	-- Get confirmation status of the trading partner.
        aname := wf_engine.GetActivityAttrText(itemtype, itemkey, actid,
		 'ECX_CONFIRMATION_FLAG', ignore_notfound => true);
        if (aname is not null) then
        ecx_document.getConfirmationStatus(
			i_transaction_type    => transaction_type,
			i_transaction_subtype => transaction_subtype,
			i_party_id	    => party_id,
			i_party_site_id	    => party_site_id,
			i_party_type          => party_type,
			o_confirmation      => i_confirmation
			);
	wf_engine.SetItemAttrText (     itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => aname,
                                        avalue   =>  i_confirmation);
        end if;
/* End of changes for Bug #2215677*/


  		ecx_document.isDeliveryRequired
			(
			transaction_type    => transaction_type,
			transaction_subtype => transaction_subtype,
			party_id	    => party_id,
			party_site_id	    => party_site_id,
                        party_type          => party_type, --bug #2183619
			resultout	    => result,
			retcode		    => retcode,
			errmsg		    => errmsg
			);
		if (result)
		then
      			-- Reached Here. Successful execution.
      			resultout := 'COMPLETE:T';
		else
			resultout := 'COMPLETE:F';
		end if;
exception
when ecx_document.ecx_transaction_not_defined then
    	wf_core.context('ECX_STANDARD','isDeliveryRequiredCover',transaction_type,transaction_subtype, party_id,party_site_id);
	wf_core.token('ECX_TRANSACTION_TYPE', transaction_type);
	wf_core.token('ECX_TRANSACTION_SUBTYPE', transaction_subtype);
	wf_core.raise('ECX_TRANSACTION_NOT_DEFINED');
when ecx_document.ecx_delivery_setup_error then
    	wf_core.context('ECX_STANDARD','isDeliveryRequiredCover',transaction_type,transaction_subtype, party_id,party_site_id);
        wf_core.token('ECX_PARTY_ID', party_id);
	wf_core.token('ECX_PARTY_SITE_ID', party_site_id);
	wf_core.token('ECX_TRANSACTION_TYPE', transaction_type);
	wf_core.token('ECX_TRANSACTION_SUBTYPE', transaction_subtype);
    	wf_core.raise('ECX_DELIVERY_SETUP_ERROR');

when ecx_utils.program_exit then
    	wf_core.context('ECX_STANDARD','isDeliveryRequiredCover',transaction_type,transaction_subtype, party_id,party_site_id);
	g_instlmode := wf_core.translate('WF_INSTALL');
	IF g_instlmode = 'EMBEDDED'
	THEN
		wf_core.token('ECX_ERRMSG',ecx_debug.getMessage(ecx_utils.i_errbuf,
                                                        ecx_utils.i_errparams));
		wf_core.token('ECX_LOGFILE',ecx_utils.g_logfile);
		wf_core.raise('ECX_PROGRAM_EXIT_EMBD');
	ELSE
		wf_core.token('ECX_ERRMSG',ecx_debug.getMessage(errmsg,
                                          ecx_utils.i_errparams));
		wf_core.token('ECX_LOGFILE',ecx_utils.g_logfile);
		wf_core.raise('ECX_PROGRAM_EXIT');
	END IF;

when others then
	raise;
end isDeliveryRequired;


-- Send
--   Standard ECX Workflow Activity
--   Send Event to AQ for delivery
-- OUT
--   result - null
--
-- ACTIVITY ATTRIBUTES REFERENCED
--   TRANSACTION_TYPE    - text value (required)
--   TRANSACTION_SUBTYPE - text value (required)
--   PARTY_ID		 - text value (optional)
--   PARTY_SITE_ID	 - text value (required)
--   DOCUMENT_D		 - text value (required)
--   PARAMETER1..5	 - text value (optional)
--   SEND_MODE		 - Text (lookup: SYNCH ASYNCH ) (required)
-- NOTE:

procedure send(itemtype	  in varchar2,
	       itemkey	  in varchar2,
	       actid	  in number,
	       funcmode	  in varchar2,
	       resultout  in out NOCOPY varchar2)
is
  transaction_type	varchar2(240);
  transaction_subtype	varchar2(240);
  party_id		varchar2(240);
  party_site_id		varchar2(240);
  party_type            varchar2(200); -- bug #2183619
  document_id		varchar2(240);
  parameter1		varchar2(240);
  parameter2		varchar2(240);
  parameter3		varchar2(240);
  parameter4		varchar2(240);
  parameter5		varchar2(240);

  debug_mode		pls_integer:=0;
  send_mode		varchar2(20);
  msgid			raw(16);
  trigger_id		binary_integer;
  retcode		binary_integer:=0;
  errmsg		varchar2(2000);
  aname  		varchar2(30);
  atype			varchar2(8);
  aformat		varchar2(240);
  asubtype		varchar2(8);
  result		varchar2(30);
  status		varchar2(8);
begin
  -- Set the Global itemtype,itemkey and the activity_id
  ecx_utils.g_item_type := itemtype;
  ecx_utils.g_item_key := itemkey;
  ecx_utils.g_activity_id := actid;

  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then
    resultout := wf_engine.eng_null;
    return;
  end if;

  -- We need to determine which parameters are required and which are optional

  transaction_type  := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'ECX_TRANSACTION_TYPE');
  if ( transaction_type is null ) then
	wf_core.token('ECX_TRANSACTION_TYPE','NULL');
	wf_core.raise('WFSQL_ARGS');
  end if;

  transaction_subtype  := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'ECX_TRANSACTION_SUBTYPE');
  if ( transaction_subtype is null ) then
	wf_core.token('ECX_TRANSACTION_SUBTYPE','NULL');
	wf_core.raise('WFSQL_ARGS');
  end if;

  party_site_id	 := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'ECX_PARTY_SITE_ID');
  if ( transaction_type <> 'ECX' and transaction_subtype <> 'CBODO' )
  then
  	if ( party_site_id is null )
	then
		wf_core.token('ECX_PARTY_SITE_ID','NULL');
		wf_core.raise('WFSQL_ARGS');
  	end if;
  end if;

  -- party_id is optional. Only party_site_id is required

  party_id  := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'ECX_PARTY_ID');
  /* Start of bug #2183619 */
     party_type  := Wf_Engine.GetActivityAttrText(itemtype, itemkey,actid, 'ECX_PARTY_TYPE', ignore_notfound => true);

  /* End of bug #2183619 */

  -- It is an optional Field
  document_id  := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'ECX_DOCUMENT_ID');
  /**
  if ( document_id is null ) then
	wf_core.token('ECX_DOCUMENT_ID','NULL');
	wf_core.raise('WFSQL_ARGS');
  end if;
  **/

  debug_mode  := nvl(Wf_Engine.GetItemAttrText(itemtype, itemkey, 'ECX_DEBUG_LEVEL',true),0);

	/** Check for the Item Attribute of type ECX_EVENT_MESSAGE. If found , then use that to initialize the
	global variable for ecx_utils.g_event or create a local instance.
	**/
	begin
		-- Initialize the Event before using it.
		wf_event_t.initialize(ecx_utils.g_event);
		ecx_utils.g_event  := Wf_Engine.GetItemAttrEvent(itemtype, itemkey,'ECX_EVENT_MESSAGE');
	exception
	when others then
		if ecx_utils.g_event is null
		then
			wf_event_t.initialize(ecx_utils.g_event);
		end if;
	end;


  	/* Start of changes for bug 2120165 */
	parameter1  := Wf_Engine.GetActivityAttrText(itemtype, itemkey,actid, 'ECX_PARAMETER1');
	parameter2  := Wf_Engine.GetActivityAttrText(itemtype, itemkey,actid, 'ECX_PARAMETER2');
	parameter3  := Wf_Engine.GetActivityAttrText(itemtype, itemkey,actid, 'ECX_PARAMETER3');
	parameter4  := Wf_Engine.GetActivityAttrText(itemtype, itemkey,actid, 'ECX_PARAMETER4');
	parameter5  := Wf_Engine.GetActivityAttrText(itemtype, itemkey,actid, 'ECX_PARAMETER5');
	/* End of changes for bug 2120165*/

	-- Add the above Parameters to the Global Event Message Object
	-- For backward compatability , we are passing ECX_PARAMETER1 -> PARAMETER1 on the Engine.
	ecx_utils.g_event.addparametertolist('PARAMETER1',parameter1);
	ecx_utils.g_event.addparametertolist('PARAMETER2',parameter2);
	ecx_utils.g_event.addparametertolist('PARAMETER3',parameter3);
	ecx_utils.g_event.addparametertolist('PARAMETER4',parameter4);
	ecx_utils.g_event.addparametertolist('PARAMETER5',parameter5);


  send_mode  := Wf_Engine.GetActivityAttrText(itemtype, itemkey,actid, 'ECX_SEND_MODE');

  wf_Item_Activity_Status.Result(itemtype, itemkey, actid, status, result);

  --  KH comment:  There is a more efficient way of doing this.  The execution test
  --               Should come before any attributes are retrived

	if (result = wf_engine.eng_null)
	then
	-- Second execution.
	-- Wait is completed, return complete result.
	-- Call the XML gateway Outbound Engine
        -- party type is added as one more parameter with bug #2183619
     		sendDirectCover
				(
				transaction_type 	=> transaction_type,
			     	transaction_subtype 	=> transaction_subtype,
			     	party_id 	 	=> party_id,
			     	party_site_id 	 	=> party_site_id,
                                party_type              => party_type,
			     	document_id 	 	=> document_id,
			     	debug_mode 	 	=> debug_mode,
			     	i_msgid			=> msgid
				);

        	aname := wf_engine.GetActivityAttrText(itemtype, itemkey, actid, 'ECX_MSGID_ATTR');
        	wf_engine.SetItemAttrText(itemtype,itemkey,aname,msgid);

		addItemAttributes(itemtype,itemkey);

		resultout := wf_engine.eng_completed||':'||wf_engine.eng_null;
	else
		-- First execution.
		-- Check for A-synch or Synch Mode
		if ( send_mode = 'ASYNCH')
		then
			-- If Async , deffer the executio
			resultout := wf_engine.eng_deferred;
		elsif ( ( send_mode is null ) or ( send_mode = 'SYNCH' ) )
		then
			-- Call the XML gateway Outbound Engine
                        -- added party_type with bug #2183619
     			sendDirectCover
				(
				transaction_type 	=> transaction_type,
			     	transaction_subtype 	=> transaction_subtype,
			     	party_id 	 	=> party_id,
			     	party_site_id 	 	=> party_site_id,
                                party_type              => party_type,
			     	document_id 	 	=> document_id,
			     	debug_mode 	 	=> debug_mode,
			     	i_msgid			=> msgid
				);

        		aname := wf_engine.GetActivityAttrText(itemtype, itemkey, actid, 'ECX_MSGID_ATTR');
        		wf_engine.SetItemAttrText(itemtype,itemkey,aname,msgid);

			addItemAttributes(itemtype,itemkey);

			resultout := wf_engine.eng_completed||':'||wf_engine.eng_null;
		end if;
	end if;

exception
  when others then
    Wf_Core.Context('ECX_STANDARD', 'Send', itemtype, itemkey, to_char(actid), funcmode);
    raise;
end send;

-- GetXMLTP
--   Standard ECX Workflow Activity
--   Retrieve XML document
-- OUT
--   result - null
--
-- ACTIVITY ATTRIBUTES REFERENCED
--   TRANSACTION_TYPE    - text value (Required)
--   TRANSACTION_SUBTYPE - text value (Required)
--   PARTY_SITE_ID	 - text value (Required)
--   PARTY_ID		 - text value (optional)
--   DOCUMENT_D		 - text value (Required)
--   EVENT_NAME		 - text value (optional)
--   EVENT_KEY		 - text value (optional)
--   PARAMETER1..5	 - text value (optional)
--
--   EVENT_MESSAGE       - Item ATTR  (required)
-- NOTE:

procedure GetXMLTP(itemtype   in varchar2,
		   itemkey    in varchar2,
		   actid      in number,
		   funcmode   in varchar2,
	 	   resultout  in out NOCOPY varchar2)
is
  i_debug_level		pls_integer :=0;
  retcode		pls_integer;
  errmsg		varchar2(2000);
  transaction_type     	VARCHAR2(240);
  transaction_subtype  	VARCHAR2(240);
  party_id	      	varchar2(240);
  party_site_id	      	varchar2(240);
  document_id          	varchar2(240);

  parameter1		varchar2(240);
  parameter2		varchar2(240);
  parameter3		varchar2(240);
  parameter4		varchar2(240);
  parameter5		varchar2(240);
  event_name		varchar2(240);
  event_key		varchar2(240);
  i_event		wf_event_t;
  aname		        varchar2(30);
  evt_name	        varchar2(30);
  atype			varchar2(8);
  aformat		varchar2(240);
  asubtype		varchar2(8);
  i_error_type		pls_integer;

  p_party_type          varchar2(240);
  p_message_type        varchar2(240);
  p_message_standard	varchar2(240);
  p_ext_type            varchar2(240);
  p_ext_subtype         varchar2(240);
  p_source_code         varchar2(240);
  p_destination_code    varchar2(240);
  p_destination_type    varchar2(240);
  p_destination_address varchar2(2000);
  p_username            ecx_tp_details.username%TYPE;
  p_password            ecx_tp_details.password%TYPE;
  p_map_code            varchar2(240);
  p_queue_name          varchar2(240);
  p_tp_header_id        pls_integer;

  p_party_id            varchar2(240);
  p_party_site_id       varchar2(240);
  i_agt_guid            wf_agents.guid%TYPE;
  trigger_id            number := 0;
  i_param_list          wf_parameter_list_t;
  i_from_agent          wf_agent_t;
  i_from_agent_name     varchar2(240);
  i_from_system_name    varchar2(240);
  g_instlmode		varchar2(100);

  cursor c1
  is
  select  ecx_trigger_id_s.NEXTVAL
  from    dual;

begin
  -- Set the Global itemtype,itemkey and the activity_id
  ecx_utils.g_item_type := itemtype;
  ecx_utils.g_item_key := itemkey;
  ecx_utils.g_activity_id := actid;

  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then
    resultout := wf_engine.eng_null;
    return;
  end if;


  i_debug_level  := nvl(Wf_Engine.GetItemAttrText(itemtype, itemkey, 'ECX_DEBUG_LEVEL',true),0);


  -- Retreive Activity Attributes

  transaction_type  := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'ECX_TRANSACTION_TYPE');
  if ( transaction_type is null ) then
	wf_core.token('ECX_TRANSACTION_TYPE','NULL');
        wf_core.raise('WFSQL_ARGS');
  end if;

  transaction_subtype  := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'ECX_TRANSACTION_SUBTYPE');
    if ( transaction_subtype is null ) then
	wf_core.token('ECX_TRANSACTION_SUBTYPE','NULL');
        wf_core.raise('WFSQL_ARGS');
  end if;

  party_site_id  := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'ECX_PARTY_SITE_ID');

  if ( transaction_type <> 'ECX' and transaction_subtype <> 'CBODO' )
  then
    if ( party_site_id is null ) then
      wf_core.token('ECX_PARTY_SITE_ID','NULL');
      wf_core.raise('WFSQL_ARGS');
    end if;
  end if;

  -- party_id is optional. Only party_site_id is required

  party_id  := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'ECX_PARTY_ID');

  /* Start of bug #2183619 */

  p_party_type  := Wf_Engine.GetActivityAttrText(itemtype, itemkey,actid, 'ECX_PARTY_TYPE', true);

  /* End of bug #2183619*/

  document_id  := Wf_Engine.GetActivityAttrTEXT(itemtype, itemkey, actid, 'ECX_DOCUMENT_ID');


  -- Verify that the attr type = EVENT

  evt_name := wf_engine.GetActivityAttrText(itemtype, itemkey, actid, 'ECX_EVENT_MESSAGE');
  if ( evt_name is null ) then
	wf_core.token('ECX_EVENT_MESSAGE','NULL');
	wf_core.raise('WFSQL_ARGS');
  end if;

  Wf_Engine.GetItemAttrInfo(itemtype, evt_name ,atype, asubtype, aformat);
  if (atype <> 'EVENT' ) then
        wf_core.token('VTYPE',atype);
	wf_core.raise('WFXXXV_VTYPE');
  end if;

  i_event  	:= Wf_Engine.GetItemAttrEvent(itemtype, itemkey, evt_name);
  /**
  Populate the Parameters in the original event Object being passed. if it is null , initialize and create
  a new Instance and populate the variables
  if i_event is null
  then
 	wf_event_t.initialize(ecx_utils.g_event);
  else
	ecx_utils.g_event := i_event;
  end if;
  **/

	/* Always initialize ecx_utils.g_event before using it */
  	wf_event_t.initialize(ecx_utils.g_event);
    	if i_event is not null
	then
		ecx_utils.g_event := i_event;
	End If;

  parameter1  := Wf_Engine.GetActivityAttrText(itemtype, itemkey,actid, 'ECX_PARAMETER1');
  parameter2  := Wf_Engine.GetActivityAttrText(itemtype, itemkey,actid, 'ECX_PARAMETER2');
  parameter3  := Wf_Engine.GetActivityAttrText(itemtype, itemkey,actid, 'ECX_PARAMETER3');
  parameter4  := Wf_Engine.GetActivityAttrText(itemtype, itemkey,actid, 'ECX_PARAMETER4');
  parameter5  := Wf_Engine.GetActivityAttrText(itemtype, itemkey,actid, 'ECX_PARAMETER5');
  -- Add the above Parameters to the Global Event Message Object
  -- For backward compatability , we are passing ECX_PARAMETER1 -> PARAMETER1 on the Engine.
  ecx_utils.g_event.addparametertolist('PARAMETER1',parameter1);
  ecx_utils.g_event.addparametertolist('PARAMETER2',parameter2);
  ecx_utils.g_event.addparametertolist('PARAMETER3',parameter3);
  ecx_utils.g_event.addparametertolist('PARAMETER4',parameter4);
  ecx_utils.g_event.addparametertolist('PARAMETER5',parameter5);

  open    c1;
  fetch   c1 into trigger_id;
  close   c1;

  -- invoke trigger_outbound which will invoke outbound_trigger, getConfirmation and
  -- get_delivery_attribs
    ecx_debug.setErrorInfo(10,10,'ECX_TRIGGER_OUTBOUND');
    ecx_document.trigger_outbound(transaction_type, transaction_subtype,
                                party_id, party_site_id,
                                document_id, ecx_utils.i_ret_code,
                                ecx_utils.i_errbuf, trigger_id,
                                p_party_type, p_party_id, p_party_site_id,
                                p_message_type, p_message_standard,
	                        p_ext_type, p_ext_subtype, p_source_code,
	                        p_destination_code, p_destination_type,
                                p_destination_address, p_username, p_password,
                                p_map_code, p_queue_name, p_tp_header_id
                                );
  -- do outbound logging
  ecx_debug.setErrorInfo(10,10, 'ECX_PROCESSING_MESSAGE');
        ecx_errorlog.outbound_engine (trigger_id,
                                ecx_utils.i_ret_code,
                                ecx_utils.i_errbuf,
                                null,null,p_party_type
                                );

  -- prepare WS related event if it is SOAP protocol type
  if (upper(p_destination_type) = 'SOAP') then
    prepareWS(itemtype, itemkey, actid, ecx_utils.g_event);
  end if;

  -- if the from agent is not yet set by users, reset it based on the retrieve
  -- protocol_type. Otherwise, honor whatever has been set by the users.
  if (not ecx_utils.g_event.GetFromAgent() is null)
  then
    i_from_agent_name := ecx_utils.g_event.GetFromAgent().GetName();
    i_from_system_name := ecx_utils.g_event.GetFromAgent().GetSystem();
  end if;

  if (i_from_agent_name is null AND i_from_system_name is null)
     or (i_from_agent_name = 'WF_DEFERRED')
  then
     if (upper(p_destination_type) = 'SOAP') then
         i_from_agent_name := 'WF_WS_JMS_OUT';
     else
         if (upper(p_destination_type) = 'JMS') then
	    if(p_destination_address is null) then
                i_from_agent_name := 'WF_JMS_OUT';
            else
                i_from_agent_name := p_destination_address;
            end if;
         else
            i_from_agent_name := 'ECX_OUTBOUND';
         end if;
     end if;

     begin
       select name
       into   i_from_system_name
       from   wf_systems
       where  guid = wf_core.translate('WF_SYSTEM_GUID');
     exception
       when others then
         raise;
     end;

     i_from_agent := wf_agent_t(i_from_agent_name, i_from_system_name);
     ecx_utils.g_event.setFromAgent(i_from_agent);

  end if;

  getXMLcover
	(
        i_message_standard      => p_message_standard,
	i_map_code 	    	=> p_map_code,
      	i_transaction_type    	=> transaction_type,
      	i_transaction_subtype 	=> transaction_subtype,
        i_tp_type               => p_party_type,
      	i_tp_id		    	=> p_party_id,
      	i_tp_site_id	    	=> p_party_site_id,
        i_document_id 	    	=> document_id,
	i_debug_level	    	=> i_debug_level,
	i_xmldoc 		=> ecx_utils.g_event.event_data,
        i_message_type          => p_message_type);

  ecx_debug.setErrorInfo(0,10,'ECX_MESSAGE_CREATED');
  ecx_errorlog.outbound_engine (trigger_id,
                                ecx_utils.i_ret_code,
                                ecx_utils.i_errbuf,
      				null,null,p_party_type
	      			);

  -- Following part is needed only when getxmltp is used with wf_event.send
  -- set ecx_utils.g_event with the envelope information. This will later be used
  -- by the queue handler to enqueue on ECX_OUTBOUND
  ecx_utils.g_event.addParameterToList('PARTY_TYPE', p_party_type);
  ecx_utils.g_event.addParameterToList('PARTYID', p_party_id);
  ecx_utils.g_event.addParameterToList('PARTY_SITE_ID', p_source_code);
  ecx_utils.g_event.addParameterToList('DOCUMENT_NUMBER', ecx_utils.g_document_id);
  ecx_utils.g_event.addParameterToList('MESSAGE_TYPE', p_message_type);
  ecx_utils.g_event.addParameterToList('MESSAGE_STANDARD', p_message_standard);
  ecx_utils.g_event.addParameterToList('TRANSACTION_TYPE', p_ext_type);
  ecx_utils.g_event.addParameterToList('TRANSACTION_SUBTYPE', p_ext_subtype);
  ecx_utils.g_event.addParameterToList('PROTOCOL_TYPE', p_destination_type);
  ecx_utils.g_event.addParameterToList('PROTOCOL_ADDRESS', p_destination_address);
  ecx_utils.g_event.addParameterToList('USERNAME', p_username);
  ecx_utils.g_event.addParameterToList('PASSWORD', p_password);
  ecx_utils.g_event.addParameterToList('ATTRIBUTE1', ecx_utils.g_company_name);
  ecx_utils.g_event.addParameterToList('ATTRIBUTE2', null);
  ecx_utils.g_event.addParameterToList('ATTRIBUTE3', p_destination_code);
  ecx_utils.g_event.addParameterToList('ATTRIBUTE4', null);
  ecx_utils.g_event.addParameterToList('ATTRIBUTE5', null);
  ecx_utils.g_event.addParameterToList('LOGFILE', ecx_utils.g_logfile);
  ecx_utils.g_event.addParameterToList('TRIGGER_ID', trigger_id);
  ecx_utils.g_event.addParameterToList('ITEM_TYPE', itemtype);
  ecx_utils.g_event.addParameterToList('ITEM_KEY', itemkey);

   -- Populate event structure and set item attribute

  if event_name is not null
  then
  	i_event.SetEventName(event_name);
  end if;

  if event_key is not null
  then
  	i_event.SetEventKey(event_key);
  end if;

  -- set the event data back
  wf_engine.SetItemAttrEvent(itemtype, itemkey, evt_name, ecx_utils.g_event);

   addItemAttributes(itemtype,itemkey);

   resultout := 'COMPLETE:';

exception
when ecx_document.ecx_transaction_not_defined then
	ecx_errorlog.outbound_trigger
        	(
                trigger_id, transaction_type, transaction_subtype,
                p_party_id, p_party_site_id, p_party_type,
                document_id, ecx_utils.i_ret_code, ecx_utils.i_errbuf
                );

        wf_core.context('ECX_STANDARD','getXMLTP',transaction_type,transaction_subtype,party_id,party_site_id);
        wf_core.token('ECX_TRANSACTION_TYPE', transaction_type);
        wf_core.token('ECX_TRANSACTION_SUBTYPE', transaction_subtype);
        wf_core.raise('ECX_TRANSACTION_NOT_DEFINED');
when ecx_document.ecx_no_delivery_required then
	ecx_errorlog.outbound_trigger
          	(
                trigger_id, transaction_type, transaction_subtype,
                p_party_id, p_party_site_id, p_party_type,
                document_id, ecx_utils.i_ret_code, ecx_utils.i_errbuf
                );

        wf_core.context('ECX_STANDARD','getXMLTP',transaction_type,transaction_subtype,party_id,party_site_id);
	g_instlmode := wf_core.translate('WF_INSTALL');
	IF g_instlmode = 'EMBEDDED'
	THEN
		wf_core.token('ECX_ERRMSG',ecx_debug.getMessage(ecx_utils.i_errbuf,
                                                        ecx_utils.i_errparams));
		wf_core.token('ECX_LOGFILE',ecx_utils.g_logfile);
		wf_core.raise('ECX_PROGRAM_EXIT_EMBD');
	ELSE
		wf_core.token('ECX_ERRMSG',ecx_debug.getMessage(errmsg,
                                          ecx_utils.i_errparams));
		wf_core.token('ECX_LOGFILE',ecx_utils.g_logfile);
		wf_core.raise('ECX_PROGRAM_EXIT');
	END IF;
when ecx_document.ecx_no_party_setup then
	ecx_errorlog.outbound_trigger
          	(
                trigger_id, transaction_type, transaction_subtype,
                p_party_id, p_party_site_id, p_party_type,
                document_id, ecx_utils.i_ret_code, ecx_utils.i_errbuf
                );

    	wf_core.context('ECX_STANDARD','getXMLTP',transaction_type,transaction_subtype,party_id,party_site_id);
        wf_core.token('ECX_PARTY_ID', party_id);
	wf_core.token('ECX_PARTY_SITE_ID', party_site_id);
	wf_core.token('ECX_TRANSACTION_TYPE', transaction_type);
	wf_core.token('ECX_TRANSACTION_SUBTYPE', transaction_subtype);
	wf_core.raise('ECX_NO_PARTY_SETUP');
when ecx_document.ecx_delivery_setup_error then
	ecx_errorlog.outbound_trigger
          	(
                trigger_id, transaction_type, transaction_subtype,
                p_party_id, p_party_site_id, p_party_type,
                document_id, ecx_utils.i_ret_code, ecx_utils.i_errbuf
                );

    	wf_core.context('ECX_STANDARD','getXMLTP',transaction_type,transaction_subtype,party_id,party_site_id);
        wf_core.token('ECX_PARTY_ID', party_id);
	wf_core.token('ECX_PARTY_SITE_ID', party_site_id);
	wf_core.token('ECX_TRANSACTION_TYPE', transaction_type);
	wf_core.token('ECX_TRANSACTION_SUBTYPE', transaction_subtype);
    	wf_core.raise('ECX_DELIVERY_SETUP_ERROR');
when ecx_utils.program_exit then
	ecx_errorlog.outbound_trigger
          	(
                trigger_id, transaction_type, transaction_subtype,
                p_party_id, p_party_site_id, p_party_type,
                document_id, ecx_utils.i_ret_code, ecx_utils.i_errbuf
                );

    	wf_core.context('ECX_STANDARD','getXMLTP',transaction_type,transaction_subtype,party_id,party_site_id);
	g_instlmode := wf_core.translate('WF_INSTALL');
	IF g_instlmode = 'EMBEDDED'
	THEN
		wf_core.token('ECX_ERRMSG',ecx_debug.getMessage(ecx_utils.i_errbuf,
                                                        ecx_utils.i_errparams));
		wf_core.token('ECX_LOGFILE',ecx_utils.g_logfile);
		wf_core.raise('ECX_PROGRAM_EXIT_EMBD');
	ELSE
		wf_core.token('ECX_ERRMSG',ecx_debug.getMessage(ecx_utils.i_errbuf,
                                                        ecx_utils.i_errparams));
		wf_core.token('ECX_LOGFILE',ecx_utils.g_logfile);
		wf_core.raise('ECX_PROGRAM_EXIT');
	END IF;
when others then
	ecx_errorlog.outbound_trigger
                (
                trigger_id, transaction_type, transaction_subtype,
                p_party_id, p_party_site_id, p_party_type,
                document_id, ecx_utils.i_ret_code, ecx_utils.i_errbuf
                );

    	Wf_Core.Context('ECX_STANDARD', 'getXMLTP', itemtype, itemkey, to_char(actid), funcmode);
    	raise;
end getXMLTP;


-- GetXML
--   Standard ECX Workflow Activity
--   Retrieve XML document
-- OUT
--   result - null
--
-- ACTIVITY ATTRIBUTES REFERENCED
--   MAP_CODE		 - text value (required)
--   DOCUMENT_ID         - text value (required)
--   EVENT_NAME		 - text value (optional)
--   EVENT_KEY		 - text value (optional)
--   PARAMETER1..5	 - text value (optional)
--
--   EVENT_MESSAGE       - Item ATTR  (required)
-- NOTE:

procedure GetXML(itemtype   in varchar2,
		 itemkey    in varchar2,
		 actid      in number,
		 funcmode   in varchar2,
	 	 resultout  in out NOCOPY varchar2)
is
  i_debug_level		pls_integer :=0;
  i_map_code		varchar2(200);
  retcode		pls_integer;
  errmsg		varchar2(2000);
  transaction_type	varchar2(200);
  transaction_subtype	varchar2(200);
  party_id		number;    /* Bug 2122579 */
  party_site_id		number;
  document_id          	varchar2(240);

  parameter1		varchar2(240);
  parameter2		varchar2(240);
  parameter3		varchar2(240);
  parameter4		varchar2(240);
  parameter5		varchar2(240);

  /* Variabledeclarations for Bug 2120165*/
  i_evt             wf_event_t;
  i_param_name      varchar2(30);
  i_param_value     varchar2(2000);
  counter             number ;
  /* End of changes for bug 2120165*/

  event_name		varchar2(240);
  event_key		varchar2(240);
  i_event		wf_event_t;
  aevent_name		varchar2(240);
  aname		        varchar2(30);
  evt_name              varchar2(30);
  atype			varchar2(8);
  aformat		varchar2(240);
  asubtype		varchar2(8);
  i_error_type		pls_integer;
  dummy_number          number;
  pECX_MAX_JAVA_MEMORY  varchar2(30);


begin

  fnd_profile.get('ECX_MAX_JAVA_MEMORY',pECX_MAX_JAVA_MEMORY);

  if pECX_MAX_JAVA_MEMORY is null then
     dummy_number:= setMaxJavaMemorySize(MAX_JAVA_MEMORY);   -- bug 6889689
  else
     dummy_number:= setMaxJavaMemorySize( to_number(pECX_MAX_JAVA_MEMORY) * 1024 * 1024 ); -- bug 7121350
  end if;


  -- Set the Global itemtype,itemkey and the activity_id
  ecx_utils.g_item_type := itemtype;
  ecx_utils.g_item_key := itemkey;
  ecx_utils.g_activity_id := actid;

  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then
    resultout := wf_engine.eng_null;
    return;
  end if;
  i_map_code  := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'ECX_MAP_CODE');
  if (i_map_code is null ) then
     wf_core.token('ECX_MAP_CODE','NULL');
     wf_core.raise('WFSQL_ARGS');
  end if;


  document_id  		:= Wf_Engine.GetActivityAttrTEXT(itemtype, itemkey, actid, 'ECX_DOCUMENT_ID');
  i_debug_level  		:= nvl(Wf_Engine.GetItemAttrText(itemtype, itemkey, 'ECX_DEBUG_LEVEL',true),0);
  event_name 		:= Wf_Engine.GetActivityAttrText(itemtype, itemkey,actid, 'ECX_EVENT_NAME');
  event_key 		:= Wf_Engine.GetActivityAttrText(itemtype, itemkey,actid, 'ECX_EVENT_KEY');

  /*  Start changes for bug Bug 2120165 */
  parameter1  		:= Wf_Engine.GetActivityAttrText(itemtype, itemkey,actid, 'ECX_PARAMETER1');
  parameter2  		:= Wf_Engine.GetActivityAttrText(itemtype, itemkey,actid, 'ECX_PARAMETER2');
  parameter3  		:= Wf_Engine.GetActivityAttrText(itemtype, itemkey,actid, 'ECX_PARAMETER3');
  parameter4  		:= Wf_Engine.GetActivityAttrText(itemtype, itemkey,actid, 'ECX_PARAMETER4');
  parameter5  		:= Wf_Engine.GetActivityAttrText(itemtype, itemkey,actid, 'ECX_PARAMETER5');

  -- Verify that the attr type = EVENT

  evt_name := wf_engine.GetActivityAttrText(itemtype, itemkey, actid, 'ECX_EVENT_MESSAGE');
  if ( evt_name is null ) then
	wf_core.token('ECX_EVENT_MESSAGE','NULL');
	wf_core.raise('WFSQL_ARGS');
  end if;

  Wf_Engine.GetItemAttrInfo(itemtype, evt_name ,atype, asubtype, aformat);
  if (atype <> 'EVENT' ) then
        wf_core.token('VTYPE',atype);
	wf_core.raise('WFXXXV_VTYPE');
  end if;

  i_event  	:= Wf_Engine.GetItemAttrEvent(itemtype, itemkey, evt_name);

  /**
  Populate the Parameters in the original event Object being passed. if it is null , initialize and create
  a new Instance and populate the variables
  if i_event is null
  then
 	wf_event_t.initialize(ecx_utils.g_event);
  else
	ecx_utils.g_event := i_event;
  end if;
  **/

  	/*Always initialize ecx_utils.g_event before using it */
	wf_event_t.initialize(ecx_utils.g_event);
	if i_event is not null
	then
		ecx_utils.g_event := i_event;
	End If;


  -- Add the above Parameters to the Global Event Message Object
  -- For backward compatability , we are passing ECX_PARAMETER1 -> PARAMETER1 on the Engine.
  ecx_utils.g_event.addparametertolist('PARAMETER1',parameter1);
  ecx_utils.g_event.addparametertolist('PARAMETER2',parameter2);
  ecx_utils.g_event.addparametertolist('PARAMETER3',parameter3);
  ecx_utils.g_event.addparametertolist('PARAMETER4',parameter4);
  ecx_utils.g_event.addparametertolist('PARAMETER5',parameter5);

  -- KH comment: is null values for TP info going to casue an issue in GetXMLCover
  getXMLcover(i_map_code 	    => i_map_code,
	      i_transaction_type    => transaction_type,
	      i_transaction_subtype => transaction_subtype,
	      i_tp_id		    => party_id,
	      i_tp_site_id	    => party_site_id,
              i_document_id 	    => document_id,
	      i_debug_level	    => i_debug_level,
	      i_xmldoc 		    => ecx_utils.g_event.event_data
	      );

  -- Populate event structure and set item attribute

  if event_name is not null
  then
  	i_event.SetEventName(event_name);
  end if;

  if event_key is not null
  then
  	i_event.SetEventKey(event_key);
  end if;

  -- set the event data back
  wf_engine.SetItemAttrEvent(itemtype, itemkey, evt_name, ecx_utils.g_event);

   addItemAttributes(itemtype,itemkey);

  resultout := 'COMPLETE:';

exception
  when others then
    	Wf_Core.Context('ECX_STANDARD', 'getXML', itemtype, itemkey, to_char(actid), funcmode);
    	raise;
end getXML;



procedure Reprocess_Inbound
    (
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2
    )
is
message_id	varchar2(200);
retcode		pls_integer;
errmsg		varchar2(2000);
debug_level	pls_integer :=0;
trigger_id	pls_integer;
error_type	pls_integer;
aname		varchar2(200);
aname_trigger_id	varchar2(200);
aname_error_type	varchar2(200);
aname_logfile		varchar2(200);
g_instlmode		varchar2(100);
begin

	-- Set the Global itemtype,itemkey and the activity_id
	ecx_utils.g_item_type := itemtype;
	ecx_utils.g_item_key := itemkey;
	ecx_utils.g_activity_id := actid;

  -- RUN mode - normal process execution

  if (funcmode = 'RUN') then

    message_id := wf_engine.GetActivityAttrText(itemtype, itemkey, actid, 'ECX_MSGID');
    debug_level  := nvl(Wf_Engine.GetItemAttrText(itemtype, itemkey,'ECX_DEBUG_LEVEL',true),0);

		ecx_inbound_trig.reprocess
			(
			i_msgid 	=> 	message_id,
			i_debug_level	=> 	debug_level,
			i_trigger_id	=>	trigger_id,
			i_retcode	=>	retcode,
			i_errbuf	=> 	errmsg
			);

    	aname_trigger_id := 	wf_engine.GetItemAttrText(itemtype, itemkey, 'ECX_TRIGGER_ID',true);

	if aname_trigger_id is not null
	then
		wf_engine.SetItemAttrNumber(itemtype,itemkey,aname_trigger_id,trigger_id);
	end if;


   	addItemAttributes(itemtype,itemkey);

	if retcode = 0
	then
                result := 'COMPLETE:';
		return;
	elsif retcode = 1
	then
		g_instlmode := wf_core.translate('WF_INSTALL');
		IF g_instlmode = 'EMBEDDED'
		THEN
			wf_core.token('ECX_ERRMSG',ecx_debug.getMessage(errmsg,
                                           ecx_utils.i_errparams));
			wf_core.token('ECX_LOGFILE',ecx_utils.g_logfile);
			wf_core.raise('ECX_REPROCESS_INBOUND_EMBD');
		ELSE
			wf_core.token('ECX_ERRMSG',ecx_debug.getMessage(errmsg,
                                           ecx_utils.i_errparams));
			wf_core.token('ECX_LOGFILE',ecx_utils.g_logfile);
			wf_core.raise('ECX_REPROCESS_INBOUND');
		END IF;

	else
		g_instlmode := wf_core.translate('WF_INSTALL');
		IF g_instlmode = 'EMBEDDED'
		THEN
			wf_core.token('ECX_ERRMSG',ecx_debug.getMessage(errmsg,
                                           ecx_utils.i_errparams));
			wf_core.token('ECX_LOGFILE',ecx_utils.g_logfile);
			wf_core.raise('ECX_PROGRAM_EXIT_EMBD');
		ELSE
			wf_core.token('ECX_ERRMSG',ecx_debug.getMessage(errmsg,
                                           ecx_utils.i_errparams));
			wf_core.token('ECX_LOGFILE',ecx_utils.g_logfile);
			wf_core.raise('ECX_PROGRAM_EXIT');
		END IF;
	end if;

   result  := 'COMPLETE:';
   return;

  end if;


  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.

  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE:';
    return;
  end if;



  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null

  result := '';
  return;

exception
when others then
  wf_core.context('ECX_STANDARD', 'Reprocess_Inbound',itemtype, itemkey, to_char(actid),funcmode,retcode, errmsg);
  raise;
end Reprocess_Inbound;

procedure resend
    (
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2
    )
is
message_id		varchar2(200);
retcode			pls_integer;
errmsg			varchar2(2000);
begin

	-- Set the Global itemtype,itemkey and the activity_id
	ecx_utils.g_item_type := itemtype;
	ecx_utils.g_item_key := itemkey;
	ecx_utils.g_activity_id := actid;


  -- RUN mode - normal process execution

  if (funcmode = 'RUN') then

    	message_id := wf_engine.GetActivityAttrText(itemtype, itemkey, actid, 'ECX_MSGID');

		ecx_document.resend
			(
			i_msgid 	=> 	message_id,
                        i_flag		=>      'Y',
			retcode		=>	retcode,
			errmsg		=> 	errmsg
			);


	if retcode = 0
	then
                result := 'COMPLETE:';
		return;
	elsif retcode = 1
	then
		wf_core.token('ECX_ERRMSG',ecx_debug.getMessage(errmsg,
                                           ecx_utils.i_errparams));
		wf_core.raise('ECX_RESEND_WARNING');
	else
		wf_core.token('ECX_ERRMSG',ecx_debug.getMessage(errmsg,
                                           ecx_utils.i_errparams));
		wf_core.raise('ECX_RESEND_ERROR');
	end if;

   result  := 'COMPLETE:';
   return;

  end if;


  -- CANCEL mode - activity 'compensation'

  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.

  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE:';
    return;
  end if;



  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null

  result := '';
  return;

exception
when others then
  wf_core.context('ECX_STANDARD', 'ReSend',itemtype, itemkey, to_char(actid),funcmode,retcode, ecx_debug.getMessage(errmsg,ecx_utils.i_errparams));
  raise;
end resend;

-- getEventDetails (PUBLIC)
--   Standard XML Gateway Event API
-- OUT:
--   eventname      - Event to the processes
--   eventkey       - Event key
-- NOTE:
--   Called from the MD maintained as a GLobal parameter by the XML gateway engine

procedure getEventDetails
	(
	eventname       out NOCOPY     varchar2,
	eventkey        out NOCOPY     varchar2,
	itemtype        out NOCOPY     varchar2,
	itemkey         out NOCOPY     varchar2,
	parentitemtype  out NOCOPY     varchar2,
	parentitemkey   out NOCOPY     varchar2,
	retcode         OUT NOCOPY     pls_integer,
	retmsg          OUT NOCOPY     varchar2
	)
is
i_string 		varchar2(2000);
i_start_pos		pls_integer;
p_parameter_list	wf_parameter_list_t;
begin
	retcode 	:=0;
	retmsg 		:=null;

	eventname 	:= null;
	eventkey 	:= null;
	itemtype 	:= null;
	itemkey 	:= null;
	parentitemtype 	:= null;
	parentitemkey 	:= null;

	if ecx_utils.g_event is not null
	then
		eventname := ecx_utils.g_event.event_name;
		eventkey  := ecx_utils.g_event.event_key;
		itemtype  := ecx_utils.g_item_type;
		itemkey   := ecx_utils.g_item_key;

		p_parameter_list := ecx_utils.g_event.parameter_list;
		if p_parameter_list is not null
		then
  			i_string := wf_event.getValueForParameter('#CONTEXT',p_parameter_list);
			if i_string is not null
			then
				i_start_pos := instrb(i_string,':',1,1);
				parentitemtype := substr(i_string,1,i_start_pos-1);
				parentitemkey :=  substr(i_string,i_start_pos+1,length(i_string));
			end if;
		end if;
	end if;

exception
when others then
	retcode 	:= 2;
	retmsg 		:= substr(SQLERRM,1,200);
end getEventDetails;

-- getEventDetails (PUBLIC)
--   Standard XML Gateway Event API
-- OUT:
--   eventname      - Event to the processes
--   eventkey       - Event key
-- NOTE:
--   Called from the MD maintained as a GLobal parameter by the XML gateway engine
procedure getEventSystem
	(
	from_agent      out NOCOPY     varchar2,
	to_agent        out NOCOPY     varchar2,
	from_system     out NOCOPY     varchar2,
	to_system       out NOCOPY     varchar2,
	retcode         OUT NOCOPY     pls_integer,
	retmsg          OUT NOCOPY     varchar2
	)
is
begin
	retcode 	:=0;
	retmsg 		:=null;
	from_agent	:= null;
	to_agent	:= null;
	from_system	:= null;
	to_system	:= null;

	if ecx_utils.g_event is not null
	then
		if ecx_utils.g_event.from_agent is not null
		then
			from_agent 	:= ecx_utils.g_event.from_agent.name;
			from_system   	:= ecx_utils.g_event.from_agent.system;
		else
			-- Use the Local System
			from_system 	:= wf_event.local_system_name;
		end if;

		if ecx_utils.g_event.to_agent is not null
		then
			to_agent   	:= ecx_utils.g_event.to_agent.name;
			to_system   	:= ecx_utils.g_event.to_agent.system;
		else
			-- Use the Local System
			from_system 	:= wf_event.local_system_name;
		end if;
	end if;

exception
when others then
	retcode := 2;
	retmsg := substr(SQLERRM,1,200);
end getEventSystem;

function getReferenceId
	return varchar2
is
i_eventname		varchar2(240);
i_eventkey		varchar2(240);
i_itemtype		varchar2(8);
i_itemkey		varchar2(240);
i_parentitemtype	varchar2(8);
i_parentitemkey		varchar2(240);
i_from_system		varchar2(240);
i_retcode		pls_integer;
i_retmsg		varchar2(2000);

begin
	getEventDetails
	(
	eventname => i_eventname,
	eventkey => i_eventkey,
	itemtype => i_itemtype,
	itemkey => i_itemkey,
	parentitemtype => i_parentitemtype,
	parentitemkey => i_parentitemkey,
	retcode => i_retcode,
	retmsg => i_retmsg
	);

	if ecx_utils.g_event.from_agent is not null
	then
		i_from_system := ecx_utils.g_event.from_agent.system;
	else
		i_from_system := wf_event.local_system_name;
	end if;

	return i_from_system||':'||i_eventname||':'||i_eventkey;

end getReferenceId;

/**
  This API enables user to perform XSLT transformation on a any given xml file
**/
procedure perform_xslt_transformation
	(
	i_xml_file		in out	NOCOPY clob,
	i_xslt_file_name	in	varchar2,
	i_xslt_file_ver		in	varchar2,
	i_xslt_application_code	in	varchar2,
        i_retcode		out	NOCOPY pls_integer,
	i_retmsg		out	NOCOPY varchar2,
        i_dtd_file_name         in      varchar2,
        i_dtd_root_element      in      varchar2,
        i_dtd_version           in      varchar2
	)
is
   l_parser		xmlparser.parser;
   l_xml_doc		xmlDOM.DOMDocument;
   i_version    	number;
   l_dtd_payload        clob;
   l_doctype            xmlDOM.DOMDocumentType;

   cursor get_dtd is
   select payload
   from   ecx_dtds
   where  filename = i_dtd_file_name
   and    root_element = i_dtd_root_element
   and    (version = i_dtd_version or i_dtd_version is null);

   dummy_number          number;
   pECX_MAX_JAVA_MEMORY  varchar2(30);

begin
   -- check for nulls
   if (i_xml_file is null)
   then
      i_retcode := 2;
      i_retmsg := ecx_debug.getTranslatedMessage('ECX_XML_FILE_NULL');
      return;
   end if;

   if(i_xslt_file_name is null)
   then
      i_retcode := 2;
      i_retmsg := ecx_debug.getTranslatedMessage('ECX_XSLT_FILE_NULL');
      return;
   end if;

   if (i_xslt_application_code is null)
   then
      i_retcode := 2;
      i_retmsg := ecx_debug.getTranslatedMessage('ECX_XSLT_APP_CODE_NULL');
      return;
   end if;

   fnd_profile.get('ECX_MAX_JAVA_MEMORY',pECX_MAX_JAVA_MEMORY);

   if pECX_MAX_JAVA_MEMORY is null then
      dummy_number:= setMaxJavaMemorySize(MAX_JAVA_MEMORY);   -- bug 6889689
   else
      dummy_number:= setMaxJavaMemorySize( to_number(pECX_MAX_JAVA_MEMORY) * 1024 * 1024 ); -- bug 7121350
   end if;


   -- if version is null, select the max version for the provided
   -- details. If max version does not exists assume version to be 0.0
   if (i_xslt_file_ver is null)
   then
      begin
         select max(version)
         into   i_version
         from   ecx_files
         where   application_code = i_xslt_application_code
         and     name = i_xslt_file_name
         and    type = 'XSLT';
      exception
         when others then
            i_version := 0.0;
      end;
   else
      i_version := to_number(i_xslt_file_ver,'999999999999999.999');
   end if;

   -- get dtd information
   if (not (i_dtd_file_name is null) AND not (i_dtd_root_element is null))
   then
      open  get_dtd;
      fetch get_dtd
      into  l_dtd_payload;
      close get_dtd;
   end if;

   -- convert i_xml_file from CLOB to DOMNode and set in ecx_utils.g_xmldoc
   l_parser := xmlparser.newParser;

   if (l_dtd_payload is not null)
   then
      -- set the dtd in the parser instance
      xmlparser.parseDTDCLOB(l_parser, l_dtd_payload, i_dtd_root_element);
      xmlparser.setValidationMode (l_parser, true);
      l_doctype := xmlparser.getDocType (l_parser);
      xmlparser.setDocType (l_parser, l_doctype);
   end if;

   xmlparser.parseCLOB(l_parser, i_xml_file);

   l_xml_doc := xmlparser.getDocument(l_parser);

   ecx_utils.g_xmldoc := xmlDOM.makeNode(l_xml_doc);

   -- call transform_xml_with_xslt to do the transformation
   ecx_actions.transform_xml_with_xslt (i_xslt_file_name,
                                        i_version,
                                        i_xslt_application_code
                                       );
   -- get the transformed xml from ecx_utils.g_xml_doc
   -- convert from DOMNode to clob and set it in original xmlfile

   /* Bug #2517237 : Trim the Clob before writing the transformed xml */
   dbms_lob.trim(i_xml_file, 0);

   xmlDOM.writeToClob(ecx_utils.g_xmldoc, i_xml_file);

   -- free all the used variables
   l_dtd_payload := null;
   xmlparser.freeParser(l_parser);
   ecx_utils.g_xmldoc := null;
   ecx_utils.g_logdir := null;
   ecx_utils.g_logfile := null;
   if (not xmldom.isNull(l_xml_doc))
   then
      xmldom.freeDocument(l_xml_doc);
   end if;

   i_retcode := 0;
   i_retmsg := ecx_debug.getTranslatedMessage('ECX_XSLT_TRANSFORMED');

exception
   when ecx_utils.program_exit then
      i_retcode := ecx_utils.i_ret_code;
      i_retmsg := ecx_debug.getMessage(ecx_utils.i_errbuf,ecx_utils.i_errparams);

      -- free all the used variables
      l_dtd_payload := null;
      xmlparser.freeParser(l_parser);
      ecx_utils.g_xmldoc := null;
      ecx_utils.g_logdir := null;
      ecx_utils.g_logfile := null;
      ecx_utils.i_ret_code := 0;
      ecx_utils.i_errbuf := null;
      ecx_utils.i_errparams := null;
      if (not xmldom.isNull(l_xml_doc))
      then
        xmldom.freeDocument(l_xml_doc);
      end if;
   when others then
      i_retmsg:= SQLERRM || ' - ECX_STANDARD.PERFORM_XSLT_TRANSFORMATION';
      i_retcode := 2;

      -- free all the used variables
      l_dtd_payload := null;
      xmlparser.freeParser(l_parser);
      ecx_utils.g_xmldoc := null;
      ecx_utils.g_logdir := null;
      ecx_utils.g_logfile := null;
      ecx_utils.i_ret_code := 0;
      ecx_utils.i_errbuf := null;
      ecx_utils.i_errparams := null;
      if (not xmldom.isNull(l_xml_doc))
      then
         xmldom.freeDocument(l_xml_doc);
      end if;
end perform_xslt_transformation;



/** bug 3357213 */
-- -------------------------------------------------------------------------------------------
-- API name 	: GET_VALUE_FOR_XPATH
--
-- Type		    : Public
--
-- Pre-reqs	  : None
--
-- Function	  : Returns Value of the Node from the XML Document for the specified XPATH.
--              Incase of multiple occurrences, a list of comma-separated values is returned
--
-- Parameters
--	IN    : p_api_version       IN    NUMBER
--            : p_XML_DOCUMENT      IN    CLOB
--            : p_XPATH_EXPRESSION  IN    VARCHAR2
--
--	OUT   : x_return_status     OUT   VARCHAR2
--	      : x_msg_data	    OUT   VARCHAR2
--            : x_XPATH_VALUE       OUT   VARCHAR2
--
--	Version		: Current version       1.0
--			  Initial version 	1.0
--
--	Notes		  :
--
-- -------------------------------------------------------------------------------------------

PROCEDURE GET_VALUE_FOR_XPATH (
  p_api_version       IN                        NUMBER,
  x_return_status	    OUT   NOCOPY	VARCHAR2,
  x_msg_data		    OUT   NOCOPY	VARCHAR2,
  p_XML_DOCUMENT      IN    CLOB,
  p_XPATH_EXPRESSION  IN    VARCHAR2,
  x_XPATH_VALUE       OUT   NOCOPY    VARCHAR2
)
IS
	l_api_version   CONSTANT NUMBER 	:= 1.0;
	l_api_name	CONSTANT VARCHAR2(30)	:= 'GET_VALUE_FOR_XPATH';

  l_parser         XMLPARSER.PARSER;
  l_dom_document   XMLDOM.DOMDOCUMENT;
  l_node_list      XMLDOM.DOMNODELIST;
  l_node           XMLDOM.DOMNODE;

  INVALID_NODE_IN_NODELIST  EXCEPTION;
BEGIN
    -- Standard call to check for call compatibility
    IF NOT fnd_api.Compatible_API_Call ( l_api_version, p_api_version, l_api_name, G_PKG_NAME )
      THEN	RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Associate a new instance of XML Parser
    l_parser := XMLPARSER.newParser;

    --Attach the XML Clob to the XML Parser
    XMLPARSER.parseClob(l_parser, p_XML_DOCUMENT);

    --Obtain the XML Clob in DOM Document Format
    l_dom_document := XMLPARSER.getDocument(l_parser);
    XMLParser.freeParser(l_parser);

    --Obtain the nodes, present at the location specified by the XPATH Expression
    l_node_list := XSLPROCESSOR.selectNodes(XMLDOM.makeNode(l_dom_document),p_XPATH_EXPRESSION);

    FOR i IN 1..XMLDOM.getLength(l_node_list) LOOP
      -- Fetch node with index (i-1) from nodelist
      l_node := XMLDOM.ITEM(l_node_list, i-1);

      --If no nodes are present raise error
      IF (XMLDOM.isNull(l_node)) THEN
        RAISE INVALID_NODE_IN_NODELIST;
      END IF;

      --Check if current node has any child nodes
      IF XMLDOM.hasChildNodes(l_node) THEN
        l_node := XMLDOM.getFirstChild(l_node);
        LOOP
          IF XMLDOM.getNodeType(l_node) = XMLDOM.TEXT_NODE THEN
            -- Append x_XPATH_VALUE with Previous x_XPATH_VALUE and
            -- include a comma at the end to generate a list of comma separated values.
            x_XPATH_VALUE := x_XPATH_VALUE || TRIM(XMLDOM.getNodeValue(l_node)) || ',';
            EXIT;
          END IF;

          l_node := XMLDOM.getNextSibling(l_node);
          EXIT WHEN XMLDOM.isNull(l_node);
        END LOOP;
      END IF;

    END LOOP;

    --Removing the extra comma from the end of the string
    x_XPATH_VALUE := SUBSTR(x_XPATH_VALUE, 0, LENGTH(x_XPATH_VALUE)-1);
    XMLDOM.freeDocument(l_dom_document);

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_XPATH_VALUE := NULL;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    x_msg_data := 'G_EXC_UNEXPECTED_ERROR';
    fnd_message.Set_Name( 'EDR', 'EDR_PLS_STDMSG_GENERATED' );
    fnd_message.Set_Token( 'ERR_CODE', SQLCODE );
    fnd_message.Set_Token( 'ERR_MESG', SQLERRM );
    fnd_msg_pub.Add;

  WHEN INVALID_NODE_IN_NODELIST THEN
    x_XPATH_VALUE := NULL;
		x_return_status := FND_API.G_RET_STS_ERROR;

    x_msg_data := 'INVALID_NODE_IN_NODELIST';
    fnd_message.Set_Name( 'EDR', 'EDR_PLS_STDMSG_GENERATED' );
    fnd_message.Set_Token( 'ERR_CODE', SQLCODE );
    fnd_message.Set_Token( 'ERR_MESG', SQLERRM );
    fnd_msg_pub.Add;

  WHEN OTHERS THEN
    x_XPATH_VALUE := NULL;
    IF SQLCODE = PROCESSOR_ERR THEN
    	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      x_msg_data := 'PROCESSOR_ERR';
      fnd_message.Set_Name( 'EDR', 'EDR_PLS_STDMSG_GENERATED' );
      fnd_message.Set_Token( 'ERR_CODE', SQLCODE );
      fnd_message.Set_Token( 'ERR_MESG', SQLERRM );
      fnd_msg_pub.Add;
    ELSIF SQLCODE = NULL_ERR THEN
    	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      x_msg_data := 'NULL_ERR';
      fnd_message.Set_Name( 'EDR', 'EDR_PLS_STDMSG_GENERATED' );
      fnd_message.Set_Token( 'ERR_CODE', SQLCODE );
      fnd_message.Set_Token( 'ERR_MESG', SQLERRM );
      fnd_msg_pub.Add;
    ELSE
    	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      x_msg_data := 'EDR_PLS_STDMSG_UNEXPECTED';
      fnd_message.Set_Name( 'EDR', 'EDR_PLS_STDMSG_GENERATED' );
      fnd_message.Set_Token( 'ERR_CODE', SQLCODE );
      fnd_message.Set_Token( 'ERR_MESG', SQLERRM );
      fnd_msg_pub.Add;
  END IF;
END GET_VALUE_FOR_XPATH;

/** bug 3357213 */

end ecx_standard;

/
