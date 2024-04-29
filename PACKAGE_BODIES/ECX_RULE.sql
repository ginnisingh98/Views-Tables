--------------------------------------------------------
--  DDL for Package Body ECX_RULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECX_RULE" as
-- $Header: ECXRULEB.pls 120.2.12010000.1 2008/07/25 07:32:08 appldev ship $
--
--
-- rule (PUBLIC)
--   Standard XML Gateway Subscription rule function
-- IN:
--   p_subscription_guid - GUID of Subscription to be processed
--   p_event             - Event to be processes
-- NOTE:

saved_fnd_runtime_debug  pls_integer;

function outbound_rule(
                        p_subscription_guid in	   raw,
                        p_event		   in out nocopy wf_event_t
                      ) return varchar2
is
  transaction_type     	varchar2(240);
  transaction_subtype   varchar2(240);
  party_id	      	varchar2(240);
  party_site_id	      	varchar2(240);
  party_type            varchar2(200); --Bug #2183619
  document_number       varchar2(240);
  resultout             boolean;
  retcode		pls_integer;
  errmsg		varchar2(2000);
  debug_level           varchar2(2000);
  i_debug_level         pls_integer;
  parameterList         varchar2(200);
  ecx_exception_type    varchar2(200);
  l_module              varchar2(2000);

  cursor c_debug_level
  is select parameters
       from wf_event_subscriptions
      where guid = p_subscription_guid;


begin
  -- initialize declared variables
  l_module := 'ecx.plsql.ecx_rule.outbound_rule';

  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_procedure, l_module ||'.begin',
       'outbound_rule');
  end if;
  ecx_exception_type := null;

  transaction_type := p_event.getValueForParameter('ECX_TRANSACTION_TYPE');
  transaction_subtype := p_event.getValueForParameter('ECX_TRANSACTION_SUBTYPE');
  party_id := p_event.getValueForParameter('ECX_PARTY_ID');
  party_site_id := p_event.getValueForParameter('ECX_PARTY_SITE_ID');
  document_number := p_event.getValueForParameter('ECX_DOCUMENT_ID');
  -- Bug #2183619
  party_type := p_event.getValueForParameter('ECX_PARTY_TYPE');
  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'Guid: ' ||  p_subscription_guid);
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'Transaction Type ' || transaction_type);
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'Transaction Subtype ' || transaction_subtype);
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'Party Id ' || party_id);
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'Party Site Id ' || party_site_id);
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'Document Id ' || document_number);
  --Bug #2183619
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'party_type' || party_type);
  end if;

  open c_debug_level;
  fetch c_debug_level into debug_level;
  close c_debug_level;

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'Debug Level ' || debug_level);
  end if;

  i_debug_level := wf_event_functions_pkg.subscriptionparameters(debug_level, 'ECX_DEBUG_LEVEL');

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'Debug Level from subscription' || i_debug_level);
  end if;

  begin
      ecx_document.isDeliveryRequired
      (
         transaction_type,
	 transaction_subtype,
	 party_id,
	 party_site_id,
	 party_type, --Bug #2183619
         resultout,
         retcode,
         errmsg
      );

      parameterList := wf_rule.setParametersIntoParameterList(p_subscription_guid, p_event);


      --Return status of Default rule
      if (resultout) then
          return(wf_rule.default_rule(p_subscription_guid,p_event));
      else
          wf_event.setErrorInfo(p_event,'WARNING');
          -- MLS
          p_event.setErrorMessage(retcode||':'||ecx_debug.getMessage(errmsg,
                                                ecx_utils.i_errparams));
          if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
            wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
               'Resultout is FALSE- no delivery required.');
          end if;
          return 'WARNING';
      end if;
  exception
    when ecx_document.ecx_no_party_setup then
        if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level) then
          wf_log_pkg.string(wf_log_pkg.level_error, l_module,'No Party Setup');
        end if;
        ecx_exception_type := 'ecx_no_party_setup';
        wf_core.token('ECX_PARTY_ID', party_id);
        wf_core.token('ECX_PARTY_SITE_ID', party_site_id);
        wf_core.token('ECX_TRANSACTION_TYPE', transaction_type);
        wf_core.token('ECX_TRANSACTION_SUBTYPE', transaction_subtype);
        wf_core.raise('ECX_NO_PARTY_SETUP');
    when ecx_document.ecx_delivery_setup_error then
        if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level) then
          wf_log_pkg.string(wf_log_pkg.level_error, l_module,'Delivery Setup Error');
        end if;
        ecx_exception_type := 'ecx_delivery_setup_error';
        wf_core.token('ECX_PARTY_ID', party_id);
        wf_core.token('ECX_PARTY_SITE_ID', party_site_id);
        wf_core.token('ECX_TRANSACTION_TYPE', transaction_type);
        wf_core.token('ECX_TRANSACTION_SUBTYPE', transaction_subtype);
        wf_core.raise('ECX_DELIVERY_SETUP_ERROR');
    when ecx_utils.program_exit then
        if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level) then
          wf_log_pkg.string(wf_log_pkg.level_error, l_module,'Program Exit');
        end if;
        ecx_exception_type := 'program_exit';
        -- Get the MLS message
        wf_core.token('ECX_ERRMSG',ecx_debug.getMessage(ecx_utils.i_errbuf,
                                                        ecx_utils.i_errparams));
        wf_core.raise('ECX_PROGRAM_EXIT');
    when others then
        wf_core.raise('ECX_EVENT_ERROR');
  end;

exception
  when others then
    	Wf_Core.Context('ECX_RULE', 'OUTBOUND_RULE', p_event.getEventName(), p_subscription_guid);
        if(ecx_exception_type = 'ecx_no_party_setup') OR
          (ecx_exception_type = 'ecx_delivery_setup_error') OR
          (ecx_exception_type = 'program_exit') then
                 wf_event.setErrorInfo(p_event,'WARNING');
                 return 'WARNING';
        end if;
	wf_event.setErrorInfo(p_event,'ERROR');
        if (wf_log_pkg.level_unexpected >= fnd_log.g_current_runtime_level) then
          wf_log_pkg.string(wf_log_pkg.level_unexpected, l_module,
             'ERRMSG ' || errmsg);
          wf_log_pkg.string(wf_log_pkg.level_unexpected, l_module,
             'Unexpected Error');
        end if;
	return 'ERROR';
end outbound_rule;


-- Inbound_Rule (PUBLIC)
--   Standard XML Gateway Subscription rule function
-- IN:
--   p_subscription_guid - GUID of Subscription to be processed
--   p_event             - Event to be processes
-- NOTE: Determines the Inbound Transaction Queue
--
-- Standard inbound_rule function

function inbound_rule(
		       p_subscription_guid  in      raw,
	               p_event	            in out nocopy wf_event_t
		     ) return varchar2
is

  l_transaction_type    varchar2(240);
  l_transaction_subtype varchar2(240);
  l_standard_code       varchar2(2000);
  l_standard_type       varchar2(2000);
  i_queue_name		varchar2(2000);
  v_ect_inengobj        system.ecx_inengobj;
  v_enqueueoptions      dbms_aq.enqueue_options_t;
  v_messageproperties   dbms_aq.message_properties_t;
  v_msgid               raw(16);
  v_msgid_out           raw(16);
  i_trigger_id          number;
  debug_level           pls_integer;
  l_party_site_id       varchar2(200);   --Bug #2183619
  invalid_tp_setup      exception;
  l_tp_header_id        number;
  r_myparams 			varchar2(4000);
  r_transaction_type 		varchar2(4000);
  r_transaction_subtype 	varchar2(4000);
  r_party_site_id		varchar2(4000);
  r_dbg 			pls_integer;
  r_debug 			varchar2(2000);
  l_module                      varchar2(2000);

begin
  -- initialize declared variables
  l_module := 'ecx.plsql.ecx_rule.inbound_rule';
  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_procedure, l_module ||'.begin',
       'inbound_rule');
  end if;
  debug_level := 0;
  r_dbg :=0;

  v_msgid := p_event.getValueForParameter('ECX_MSGID');
  i_trigger_id := p_event.getValueForParameter('ECX_TRIGGER_ID');

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module, 'MsgId '|| v_msgid);
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'TriggerId '|| i_trigger_id);
  end if;

  ecx_debug.setErrorInfo(10,10, 'ECX_PROCESSING_RULE');
  ecx_errorlog.inbound_trigger(
                                 i_trigger_id,
                                 v_msgid,
                                 null,
                                 ecx_utils.i_ret_code,
                                 ecx_utils.i_errbuf
                               );


  -- Get the data from the Event
  l_transaction_type := p_event.getValueForParameter('ECX_TRANSACTION_TYPE');
  l_transaction_subtype := p_event.getValueForParameter('ECX_TRANSACTION_SUBTYPE');
  l_standard_code := p_event.getValueForParameter('ECX_MESSAGE_STANDARD');
  l_standard_type := p_event.getValueForParameter('ECX_MESSAGE_TYPE');
  -- we should pickup from event subscription and not from p_event VS
  --debug_level := p_event.getValueForParameter('ECX_DEBUG_LEVEL');
  --Party_site_id added for  Bug #2183619
  l_party_site_id := p_event.getValueForParameter('ECX_PARTY_SITE_ID');
  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'Transaction Type ' || l_transaction_type);
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'Transaction Subtype '||l_transaction_subtype);
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'Standard Code ' || l_standard_code);
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'Debug Mode ' || debug_level);
  --Party_site_id added for Bug #2183619
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'party_site_id  ' || l_party_site_id );
  end if;

  /*start of changes for Bug#2183619*/
  BEGIN

     select  queue_name ,
             tp_header_id
     into    i_queue_name,
             l_tp_header_id
     from    ecx_ext_processes eep,
             ecx_standards es,
             ecx_tp_details etd
     where   eep.ext_type       = l_transaction_type
     and     eep.ext_subtype    = l_transaction_subtype
     and     eep.direction      = 'IN'
     and     eep.standard_id    = es.standard_id
     and     es.standard_code   = l_standard_code
     and     es.standard_type   = l_standard_type
     and     etd.ext_process_id = eep.ext_process_id
     and     etd.source_tp_location_code  = l_party_site_id;
   Exception
   WHEN NO_DATA_FOUND THEN
		raise invalid_tp_setup;
   END;
   /*End of changes for bug #2183619*/

   if i_queue_name is not null then
     if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
       wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
          'Queue name '||i_queue_name);
     end if;

     -- Enqueue the Event on the Inbound Engine
     -- Determine the Debug Mode from the Subscription parameter for the transaction processing
   	begin
  		-- Get Params
		select 	parameters
		into 	r_myparams
		from 	wf_event_subscriptions
		where 	guid = p_subscription_guid;
	exception
	when others then
                if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level) then
		  wf_log_pkg.string(wf_log_pkg.level_error, l_module,
                     'Error in selecting parameters.');
                end if;
		ecx_debug.setErrorInfo(1,30,'ECX_PARAM_SELECT_ERROR',
		                            'p_guid',
                                             p_subscription_guid);
		wf_event.setErrorInfo(p_event,'ERROR');
		p_event.setErrorMessage(ecx_debug.getMessage(ecx_utils.i_errbuf,
                                                     ecx_utils.i_errparams));
		p_event.event_key := v_msgid;
                p_event.AddParameterToList('ECX_RETURN_CODE', ecx_utils.i_ret_code);
                p_event.AddParameterToList('ECX_ERROR_MSG',ecx_utils.i_errbuf);
                p_event.AddParameterToList('ECX_ERROR_PARAMS',ecx_utils.i_errparams);
                p_event.AddParameterToList('ECX_ERROR_TYPE', ecx_utils.error_type);
                p_event.AddParameterToList('ECX_TP_HEADER_ID', l_tp_header_id);
                p_event.addParameterToList('ECX_DIRECTION','IN');
		return 'ERROR';
	end;

        if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
  	  wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
             'Parameters from Subscription are:'||r_myparams);
        end if;
	begin
		-- Get debug level, and default if not found
		if r_myparams is not null
		then
                   r_dbg := wf_event_functions_pkg.subscriptionparameters(r_myparams,'ECX_DEBUG_LEVEL');
                   if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
                       wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
                          'ECX_DEBUG_LEVEL:'||r_dbg||'XX');
                   end if;

                   if r_dbg is null
                   then
                      debug_level := 0;
                   else
                      debug_level := r_dbg;
                   end if;
		end if;
	exception
	when others then
           if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
		wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
                   'Warning in getting DEBUG Parameters.'||SQLERRM);
           end if;
	end;

	begin
		-- Get TRANSACTION_TYPE
		if r_myparams is not null
		then
                  r_transaction_type := wf_event_functions_pkg.subscriptionparameters(r_myparams,'ECX_TRANSACTION_TYPE');
                   if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
                     wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
                        'ECX_TRANSACTION_TYPE:'||r_transaction_type);
                   end if;
		end if;
	exception
	when others then
            if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
		wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
                   'Warning in getting TRANSACTION_TYPE Parameters.');
            end if;
	end;

	begin
		-- Get TRANSACTION_SUBTYPE
		if r_myparams is not null
		then
                  r_transaction_subtype :=
                    wf_event_functions_pkg.subscriptionparameters(r_myparams,'ECX_TRANSACTION_SUBTYPE');
                  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
                    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
                       'ECX_TRANSACTION_SUBTYPE:'||r_transaction_subtype);
                  end if;
		end if;
	exception
	when others then
           if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
		wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
                   'Warning in getting TRANSACTION_SUBTYPE Parameters.');
           end if;
	end;

	begin
		-- Get PARTY_SITE_ID
          if r_myparams is not null then
            r_party_site_id 	:= wf_event_functions_pkg.subscriptionparameters(r_myparams,'ECX_PARTY_SITE_ID');
            if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
              wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
                 'ECX_PARTY_SITE_ID:'||r_party_site_id);
            end if;
          end if;
	exception
	when others then
          if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
            wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
               'Warning in getting PARTY_SITE_ID Parameter.');
          end if;
	end;

	if r_transaction_type is not null
	then
           if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
		wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
                   'r_transaction_type'||r_transaction_type||'XX'||l_transaction_type);
		wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
                   'r_dbg'||r_dbg);
           end if;
           if r_transaction_type = l_transaction_type
           then
		debug_level := r_dbg;
           end if;
           if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
               wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
                  'debug_level'||debug_level);

               -- Check for transaction_subtype also
               wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
                  'r_transaction_subtype'||r_transaction_subtype||
                  'XX'|| l_transaction_subtype);
               wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
                  'r_dbg'||r_dbg);
           end if;
           if r_transaction_subtype is not null
           then
		if r_transaction_subtype = l_transaction_subtype
		then
	 	  debug_level := r_dbg;
		end if;
           end if;
           if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
             wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
                'debug_level'||debug_level);

             -- Check for party_site_id also
             wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
                'r_party_site_id'||r_party_site_id);
             wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
                'l_party_site_id'||l_party_site_id);
             wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
                'r_dbg'||r_dbg);
           end if;
           if r_party_site_id is not null
           then
              if r_party_site_id = l_party_site_id
              then
                 debug_level := r_dbg;
              end if;
           end if;
           if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
             wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
                'debug_level'||debug_level);
           end if;
	end if;

     v_ect_inengobj := system.ecx_inengobj(v_msgid,debug_level);

     begin
	dbms_aq.enqueue(queue_name         => i_queue_name,
		        enqueue_options    => v_enqueueoptions,
		        message_properties => v_messageproperties,
		        payload            => v_ect_inengobj,
		        msgid              => v_msgid_out );

         ecx_debug.setErrorInfo(10,10, 'ECX_PROCESSING_MESSAGE');
         ecx_errorlog.inbound_trigger(
                                 i_trigger_id,
                                 v_msgid,
                                 v_msgid_out,
                                 ecx_utils.i_ret_code,
                                 ecx_utils.i_errbuf
                               );
        if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
          wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
             'Processed successfully.');
        end if;
	return 'SUCCESS';
      exception
	  when others then
                ecx_debug.setErrorInfo(1,30,'ECX_PROCESSING_ENQ_ERROR',
                                            'p_queue_name',
                                             i_queue_name);
                ecx_errorlog.inbound_trigger(
                                 i_trigger_id,
                                 v_msgid,
                                 v_msgid_out,
                                 ecx_utils.i_ret_code,
                                 ecx_utils.i_errbuf,
                                 ecx_utils.i_errparams);

              if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level) then
	        wf_log_pkg.string(wf_log_pkg.level_error, l_module,
                   'Error enqueuing to processing engine');
              end if;
              wf_event.setErrorInfo(p_event,'ERROR');
              --p_event.setErrorMessage('Error enqueuing to processing engine: ' || i_queue_name);
              -- MLS
              p_event.setErrorMessage(ecx_debug.getMessage(ecx_utils.i_errbuf,
                                                        ecx_utils.i_errparams));
              p_event.event_key := v_msgid;
              p_event.AddParameterToList('ECX_RETURN_CODE', ecx_utils.i_ret_code);
              p_event.AddParameterToList('ECX_ERROR_MSG',ecx_utils.i_errbuf);
              p_event.AddParameterToList('ECX_ERROR_PARAMS',ecx_utils.i_errparams);
              p_event.AddParameterToList('ECX_ERROR_TYPE', ecx_utils.error_type);
              p_event.AddParameterToList('ECX_TP_HEADER_ID', l_tp_header_id);
              p_event.addParameterToList('ECX_DIRECTION','IN');
              return 'ERROR';
      end;
   else
        ecx_debug.setErrorInfo(1,30,'ECX_NO_PROCESSING_QUEUE');
        ecx_errorlog.inbound_trigger(
                                 i_trigger_id,
                                 v_msgid,
                                 v_msgid_out,
                                 ecx_utils.i_ret_code,
                                 ecx_utils.i_errbuf
                                    );
        if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level) then
          wf_log_pkg.string(wf_log_pkg.level_error, l_module,
             'Queue name not found');
        end if;
        wf_event.setErrorInfo(p_event,'ERROR');
        -- MLS
        --p_event.setErrorMessage('Unable to determine processing engine queue.');
        p_event.setErrorMessage(ecx_debug.getMessage(ecx_utils.i_errbuf,
                                                     ecx_utils.i_errparams));
        p_event.event_key := v_msgid;
        p_event.AddParameterToList('ECX_RETURN_CODE', ecx_utils.i_ret_code);
        p_event.AddParameterToList('ECX_ERROR_MSG',ecx_utils.i_errbuf);
        p_event.AddParameterToList('ECX_ERROR_PARAMS',ecx_utils.i_errparams);
        p_event.AddParameterToList('ECX_ERROR_TYPE', ecx_utils.error_type);
        p_event.AddParameterToList('ECX_TP_HEADER_ID', l_tp_header_id);
        p_event.addParameterToList('ECX_DIRECTION','IN');

        return 'ERROR';
   end if;
exception
/* start of changes for bug #2183619*/
when too_many_rows then

        ecx_debug.setErrorInfo(2,30, 'ECX_MANY_PROCESSING_QUEUES');
        ecx_errorlog.inbound_trigger(
                                 i_trigger_id,
                                 v_msgid,
                                 v_msgid_out,
                                 ecx_utils.i_ret_code,
                                 ecx_utils.i_errbuf
                               );
        if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level) then
          wf_log_pkg.string(wf_log_pkg.level_error, l_module,
             'More than one row resulted while querying the queue name.');
        end if;
        wf_event.setErrorInfo(p_event,'ERROR');
        -- MLS
        --p_event.setErrorMessage('More than one row resulted while querying the Queue Name.');
        p_event.setErrorMessage(ecx_debug.getMessage(ecx_utils.i_errbuf,
                                                     ecx_utils.i_errparams));
        p_event.event_key := v_msgid;
        p_event.AddParameterToList('ECX_RETURN_CODE', ecx_utils.i_ret_code);
        p_event.AddParameterToList('ECX_ERROR_MSG',ecx_utils.i_errbuf);
        p_event.AddParameterToList('ECX_ERROR_PARAMS',ecx_utils.i_errparams);
        p_event.AddParameterToList('ECX_ERROR_TYPE', ecx_utils.error_type);
        p_event.AddParameterToList('ECX_TP_HEADER_ID', l_tp_header_id);
        p_event.addParameterToList('ECX_DIRECTION','IN');

        return 'ERROR';
when invalid_tp_setup then

        ecx_debug.setErrorInfo(2,30,'ECX_RULE_INVALID_TP_SETUP',
                                    'p_standard_code',
                                     l_standard_code,
                                     'p_transaction_type',
                                     l_transaction_type,
                                     'p_transaction_subtype',
                                     l_transaction_subtype,
                                     'p_party_site_id',
                                     l_party_site_id);


        ecx_errorlog.inbound_trigger(
                                 i_trigger_id,
                                 v_msgid,
                                 v_msgid_out,
                                 ecx_utils.i_ret_code,
                                 ecx_utils.i_errbuf,
                                 ecx_utils.i_errparams);

      if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level) then
        wf_log_pkg.string(wf_log_pkg.level_error, l_module,
                          'The Standard:'||l_standard_code||
                          ' Transaction Type:'||l_transaction_type||
                          ' SubType:'||l_transaction_subtype||
                          ' Location Code'||l_party_site_id||
                          ' is not enabled in the XML Gateway Server. Pls check your Setup');
        end if;
        wf_event.setErrorInfo(p_event,'ERROR');
        -- MLS
        p_event.setErrorMessage(ecx_debug.getMessage(ecx_utils.i_errbuf,
                                                     ecx_utils.i_errparams));
        p_event.event_key := v_msgid;
        p_event.AddParameterToList('ECX_RETURN_CODE', ecx_utils.i_ret_code);
        p_event.AddParameterToList('ECX_ERROR_MSG',ecx_utils.i_errbuf);
        p_event.AddParameterToList('ECX_ERROR_PARAMS',ecx_utils.i_errparams);
        p_event.AddParameterToList('ECX_ERROR_TYPE', ecx_utils.error_type);
        p_event.AddParameterToList('ECX_TP_HEADER_ID', l_tp_header_id);
        p_event.addParameterToList('ECX_DIRECTION','IN');

        return 'ERROR';
/* end of changes for bug #2183619*/
when others then
      ecx_debug.setErrorInfo(2,30, 'ECX_IN_RULE_PROCESING_ERROR');
      ecx_errorlog.inbound_trigger(
                                 i_trigger_id,
                                 v_msgid,
                                 v_msgid_out,
                                 ecx_utils.i_ret_code,
                                 ecx_utils.i_errbuf
                               );
      if (wf_log_pkg.level_unexpected >= fnd_log.g_current_runtime_level) then
        wf_log_pkg.string(wf_log_pkg.level_unexpected, l_module,
           'Error in processing inbound rule.');
      end if;
      wf_event.setErrorInfo(p_event,'ERROR');
      p_event.setErrorMessage(ecx_debug.getMessage(ecx_utils.i_errbuf,
                                                   ecx_utils.i_errparams));
      p_event.event_key := v_msgid;
      p_event.AddParameterToList('ECX_RETURN_CODE', ecx_utils.i_ret_code);
      p_event.AddParameterToList('ECX_ERROR_MSG',ecx_utils.i_errbuf);
      p_event.AddParameterToList('ECX_ERROR_PARAMS',ecx_utils.i_errparams);
      p_event.AddParameterToList('ECX_ERROR_TYPE', ecx_utils.error_type);
      p_event.AddParameterToList('ECX_TP_HEADER_ID', l_tp_header_id);
      p_event.addParameterToList('ECX_DIRECTION','IN');

      return 'ERROR';
end inbound_rule;

-- Inbound_Rule2 (PUBLIC)
--   Another XML Gateway Subscription rule function (does no validation)
--	quick and dirty, useful for a2a.
-- IN:
--   p_subscription_guid - GUID of Subscription to be processed
--   p_event             - Event to be processes
--
-- Another inbound_rule function

function inbound_rule2 (p_subscription_guid  in      raw,
               p_event in out nocopy wf_event_t) return varchar2 is

  myparams varchar2(4000);
  dbg pls_integer;
  mapcode Varchar2(240);
  l_module  Varchar2(2000);

begin
  l_module := 'ecx.plsql.ecx_rule.inbound_rule2';
  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_procedure, l_module ||'.begin',
       'inbound_rule2');
  end if;
  begin
    -- Get Params
    select parameters
      into myparams
      from wf_event_subscriptions
     where guid = p_subscription_guid;
  exception
    when others then
      if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
       wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
          'Error in selecting parameters.');
      end if;
       wf_event.setErrorInfo(p_event,'ERROR');
       return 'ERROR';
  end;

  begin
    -- Get debug level, and default if not found
    dbg := wf_event_functions_pkg.
		subscriptionparameters(myparams,'ECX_DEBUG_LEVEL');

    if dbg is null then
	dbg := 0;
    end if;
  exception
    when others then
       if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level) then
         wf_log_pkg.string(wf_log_pkg.level_error, l_module,
            'Error in getting ECX_DEBUG_LEVEL.');
       end if;
       wf_event.setErrorInfo(p_event,'ERROR');
       return 'ERROR';
  end;

  begin
    -- get map code
    mapcode := wf_event_functions_pkg.
		subscriptionparameters(myparams,'ECX_MAP_CODE');
  exception
    when others then
       if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level) then
         wf_log_pkg.string(wf_log_pkg.level_error, l_module,
                           'Error in getting ECX_MAP_CODE.');
       end if;
       wf_event.setErrorInfo(p_event,'ERROR');
       return 'ERROR';
  end;

  -- process
  ECX_STANDARD.ProcessXmlCover(i_map_code=> mapcode,
     			       i_inpayload => p_event.GetEventData(),
     			       i_debug_level => dbg);

  return 'SUCCESS';

exception
    when others then
       if (wf_log_pkg.level_unexpected >= fnd_log.g_current_runtime_level) then
         wf_log_pkg.string(wf_log_pkg.level_unexpected, l_module,
            'Error in processing inbound rule2.');
       end if;
       wf_event.setErrorInfo(p_event,'ERROR');
       return 'ERROR';
end inbound_rule2;


function exec_wf (p_subscription_guid in     raw,
                  p_event             in out nocopy wf_event_t,
                  p_wftype            in     varchar2,
                  p_wfname            in     varchar2
                  ) return varchar2
is
  l_out_guid   raw(16);
  l_to_guid    raw(16);
  l_wftype     varchar2(30);
  l_wfname     varchar2(30);
  l_res        varchar2(30);
  l_pri        number;
  l_ikey       varchar2(240);
  l_paramlist  wf_parameter_list_t;
  l_subparams  varchar2(4000);
  l_lcorrid    varchar2(240);
  l_map_code   varchar2(30);
  l_std_type   varchar2(30);
  l_std_code   varchar2(30);
  l_module     varchar2(2000);

begin
  l_module := 'ecx.plsql.ecx_rule.CreateTPMessage.exec_wf';
  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_procedure, l_module ||'.begin',
       'exec_wf');
  end if;

  select out_agent_guid, to_agent_guid, wf_process_type, wf_process_name,
         priority, parameters, map_code, standard_type, standard_code
  into   l_out_guid, l_to_guid, l_wftype, l_wfname, l_pri, l_subparams,
         l_map_code, l_std_type, l_std_code
  from   wf_event_subscriptions
  where  guid = p_subscription_guid;

  if (p_wftype is not null) then
    l_wftype := p_wftype;
    l_wfname := p_wfname;
  end if;

  -- Workflow --
  if (l_wftype is not null) then

    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
       wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
                        'Calling wf_engine.event()');
    end if;

    l_paramlist := p_event.Parameter_List;
    wf_event.AddParameterToList('SUB_GUID',  p_subscription_guid, l_paramlist);

    if p_event.getValueForParameter('ECX_MAP_CODE') is null then
       if l_map_code is not null then
          wf_event.AddParameterToList('ECX_MAP_CODE', l_map_code, l_paramlist);
       end if;
    end if;

    if p_event.getValueForParameter('ECX_MESSAGE_STANDARD') is null then
       if l_std_code is not null then
          wf_event.AddParameterToList('ECX_MESSAGE_STANDARD', l_std_code, l_paramlist);
       end if;
    end if;

    if p_event.getValueForParameter('ECX_MESSAGE_TYPE') is null then
       if l_std_type is not null then
          wf_event.AddParameterToList('ECX_MESSAGE_TYPE', l_std_type, l_paramlist);
       end if;
    end if;

    p_event.parameter_List := l_paramlist;

    if (l_wftype = 'WFERROR') then
      select to_char(WF_ERROR_PROCESSES_S.nextval) into l_ikey from dual;
    else
      l_ikey := nvl(p_event.Correlation_ID, p_event.Event_Key);
    end if;

    wf_engine.event(
       itemtype      => l_wftype,
       itemkey       => l_ikey,
       process_name  => l_wfname,
       event_message => p_event);
  end if;

  -- Route --
  /** single consumer queues do not need a To Agent  **/
  if (l_out_guid is not null) then
    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
       wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
                        'Routing...' || l_out_guid);
    end if;

    p_event.From_Agent := wf_event.newAgent(l_out_guid);
    p_event.To_Agent   := wf_event.newAgent(l_to_guid);
    p_event.Priority   := l_pri;
    p_event.Send_Date  := nvl(p_event.getSendDate(),sysdate);

    wf_event.send(p_event);
  end if;

  -- Debug --
  if (wf_log_pkg.wf_debug_flag = TRUE) then
    begin
      l_res := wf_rule.log(p_subscription_guid, p_event);
    exception
      when others then null;
    end;
  end if;

  return 'SUCCESS';
exception
  when others then
    wf_core.context('ECX_RULE', 'Exec_WF', p_event.getEventName(),
                                           p_subscription_guid);
    wf_event.setErrorInfo(p_event, 'ERROR');
    return 'ERROR';
end exec_wf;


procedure setEventParam(
  p_msgid                   in raw,
  p_transaction_type        in Varchar2,
  p_transaction_subtype     in Varchar2,
  p_message_code            in Varchar2,
  p_message_type            in Varchar2,
  p_party_id                in Varchar2,
  p_party_site_id           in Varchar2,
  p_protocol_type           in Varchar2,
  p_protocol_address        in Varchar2,
  p_username                in Varchar2,
  p_password                in Varchar2,
  p_attribute1              in Varchar2,
  p_attribute2              in Varchar2,
  p_attribute3              in Varchar2,
  p_attribute4              in Varchar2,
  p_attribute5              in Varchar2,
  p_internal_control_number in pls_integer,
  p_debug_mode              in varchar2,
  p_logfile                 in varchar2,
  p_status                  in varchar2,
  p_time_stamp              in varchar2,
  p_document_number         in varchar2,
  p_event                   in out nocopy wf_event_t)
is

  l_party_type          Varchar2(20);
  l_module              Varchar2(2000);
begin

  if (p_event is null or
      p_event.event_name is null) then
      return;
  end if;

  l_module := 'ecx.plsql.ecx_rule.ReceiveTPMessage.setEventParam';
  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_procedure, l_module ||'.begin',
       'setEventParam');
  end if;

  if ecx_utils.g_snd_tp_id is not null then
  begin
    select party_type
    into l_party_type
    from ecx_tp_headers
    where tp_header_id=ecx_utils.g_snd_tp_id;
  exception
    when others then
      if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
        wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
                          'Unable to determine party_type:' || l_party_type);
      end if;
    end;
  end if;

  p_event.addParameterToList('ECX_DEBUG_LEVEL', p_debug_mode);
  p_event.addParameterToList('ECX_RETURN_CODE', ecx_utils.i_ret_code);
  p_event.addParameterToList('ECX_ERROR_MSG',ecx_utils.i_errbuf);
  p_event.addParameterToList('ECX_ERROR_PARAMS',ecx_utils.i_errparams);
  p_event.addParameterToList('ECX_ERROR_TYPE',ecx_utils.error_type);
  p_event.addParameterToList('ECX_DIRECTION', ecx_utils.g_direction);
  p_event.addParameterToList('ECX_TRANSACTION_TYPE', ecx_utils.g_transaction_type);
  p_event.addParameterToList('ECX_TRANSACTION_SUBTYPE', ecx_utils.g_transaction_subtype);
  p_event.addParameterToList('ECX_TP_HEADER_ID', ecx_utils.g_snd_tp_id);
  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'Tp Header Id: '|| ecx_utils.g_snd_tp_id);
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'Mesage Type from doclogs: '|| p_message_type);
  end if;
  p_event.addParameterToList('ECX_MSGID', p_msgid);
  p_event.addParameterToList('ECX_MESSAGE_TYPE', p_message_type);
  p_event.addParameterToList('ECX_MESSAGE_STANDARD', p_message_code);
  p_event.addParameterToList('ECX_DOCUMENT_ID', p_document_number);
  p_event.addParameterToList('ECX_PARTY_ID', p_party_id);
  p_event.addParameterToList('ECX_PARTY_SITE_ID', p_party_site_id);
  p_event.addParameterToList('ECX_PARTY_TYPE', l_party_type);
  p_event.addParameterToList('ECX_PROTOCOL_TYPE', p_protocol_type);
  p_event.addParameterToList('ECX_PROTOCOL_ADDRESS', p_protocol_address);
  p_event.addParameterToList('ECX_USERNAME', p_username);
  p_event.addParameterToList('ECX_PASSWORD', p_password);
  p_event.addParameterToList('ECX_ATTRIBUTE1', p_attribute1);
  p_event.addParameterToList('ECX_ATTRIBUTE2', p_attribute2);
  p_event.addParameterToList('ECX_ATTRIBUTE3', p_attribute3);
  p_event.addParameterToList('ECX_ATTRIBUTE4', p_attribute4);
  p_event.addParameterToList('ECX_ATTRIBUTE5', p_attribute5);
  p_event.addParameterToList('ECX_LOGFILE', p_logfile);
  p_event.addParameterToList('ECX_ICN', p_internal_control_number);
  p_event.addParameterToList('ECX_STATUS', p_status);
  p_event.addParameterToList('ECX_TIME_STAMP', p_time_stamp);

exception
  when others then
    raise;

end setEventParam;


procedure processTPMessage (
  p_msgid               in raw,
  p_debug_mode          in varchar2,
  p_process_id          in varchar2)
is

  l_module    Varchar2(2000);

begin

  l_module := 'ecx.plsql.ecx_rule.ReceiveTPMessage.processTPMessage';
  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_procedure, l_module ||'.begin',
       'Starting inbound processing.');
  end if;
  savepoint before_processing;

  ecx_inbound_trig.wrap_validate_message
  (
    p_msgid,
    p_debug_mode
  );

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'Completed inbound processing.');
  end if;

  if(ecx_utils.g_ret_code = 1 )
  then
	ecx_debug.setErrorInfo(1, 10, 'ECX_MESSAGE_PROCESSED_WARNING');
  else
	ecx_debug.setErrorInfo(0, 10, 'ECX_MESSAGE_PROCESSED');
  end if;

  ecx_errorlog.inbound_engine(p_process_id,
                              ecx_utils.i_ret_code,
                              ecx_utils.i_errbuf);

exception
  when others then
    rollback to before_processing;
    if(ecx_utils.i_ret_code = 0) then
       ecx_utils.i_ret_code := 2;
       ecx_utils.i_errbuf := SQLERRM;
    end if;

    if (ecx_utils.i_errbuf is null) then
        ecx_utils.i_errbuf := SQLERRM;
    end if;

    if (ecx_utils.error_type is null)
       -- OR
       --(ecx_utils.error_type = 10 )
    then
        ecx_utils.error_type := 30;
    end if;

    begin
      ecx_errorlog.inbound_engine(p_process_id,
                                  ecx_utils.i_ret_code,
                                  ecx_utils.i_errbuf);
    exception
      when others then
        if (wf_log_pkg.level_unexpected >= fnd_log.g_current_runtime_level) then
          wf_log_pkg.string(wf_log_pkg.level_unexpected, l_module,
             'Error While Saving the Log: ' ||p_msgid);
          wf_log_pkg.string(wf_log_pkg.level_unexpected, l_module,
             'Logging Error Message: '|| substr(SQLERRM,1,200));
        end if;
    end;

    if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_error, l_module,
         'Exception in inbound processing.');
      wf_log_pkg.string(wf_log_pkg.level_error, l_module,
         'Error Type: '|| ecx_utils.error_type);
      wf_log_pkg.string(wf_log_pkg.level_error, l_module,
         'Return Code: '|| ecx_utils.i_ret_code);
      wf_log_pkg.string(wf_log_pkg.level_error, l_module,
         'Error Message: '|| ecx_utils.i_errbuf);
    end if;
    raise;
end processTPMessage;


function isTPEnabled (
  p_transaction_type     in varchar2,
  p_transaction_subtype  in varchar2,
  p_standard_code        in varchar2,
  p_standard_type        in varchar2,
  p_party_site_id        in varchar2,
  x_queue_name           out nocopy varchar2,
  x_tp_header_id         out nocopy number)

return boolean is

begin
  x_queue_name := null;
  x_tp_header_id := -1;

  select  queue_name ,
          tp_header_id
  into    x_queue_name,
          x_tp_header_id
  from    ecx_ext_processes eep,
          ecx_standards es,
          ecx_tp_details etd
  where   eep.ext_type       = p_transaction_type
  and     eep.ext_subtype    = p_transaction_subtype
  and     eep.direction      = 'IN'
  and     eep.standard_id    = es.standard_id
  and     es.standard_code   = p_standard_code
  and     es.standard_type   = p_standard_type
  and     etd.ext_process_id = eep.ext_process_id
  and     etd.source_tp_location_code  = p_party_site_id;

  return true;
Exception
  when others then
     return false;
end isTPEnabled;


procedure enqueue_msg (
  p_event        in  wf_event_t,
  p_queue_name   in  Varchar2,
  p_msgid_in     in  raw,
  x_msgid_out    out nocopy raw)
is

  l_ecx_inengobj       system.ecx_inengobj;
  l_debug_mode         pls_integer;
  l_enqueueoptions      dbms_aq.enqueue_options_t;
  l_messageproperties   dbms_aq.message_properties_t;
  l_msgid               raw(16);
  l_module              Varchar2(2000);

begin
  if (p_queue_name is null) then
    return;
  end if;

  l_module := 'ecx.plsq.ecx_rule.ReceiveTPMessage.enqueue_msg';
  l_debug_mode := p_event.getValueForParameter('ECX_DEBUG_LEVEL');

  l_ecx_inengobj := system.ecx_inengobj(p_msgid_in, l_debug_mode);

  dbms_aq.enqueue(queue_name         => p_queue_name,
                  enqueue_options    => l_enqueueoptions,
                  message_properties => l_messageproperties,
                  payload            => l_ecx_inengobj,
                  msgid              => x_msgid_out );

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
      'Enqueued to '||p_queue_name|| ' successfully.');
  end if;

exception
  when others then
    if (wf_log_pkg.level_unexpected >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_unexpected, l_module,
         'Error enqueuing to processing engine');
    end if;
    ecx_debug.setErrorInfo(1,30,'ECX_PROCESSING_ENQ_ERROR',
                           'p_queue_name', p_queue_name);
    raise;
end enqueue_msg;


procedure convertEcxToFndDebug (
  p_debug_mode      in  pls_integer)
is

begin

  if (p_debug_mode = 0) or
     (p_debug_mode = 1) then
    fnd_log.g_current_runtime_level := fnd_log.level_unexpected;
  elsif (p_debug_mode = 2) then
    fnd_log.g_current_runtime_level := fnd_log.level_procedure;
  elsif (p_debug_mode = 3) then
    fnd_log.g_current_runtime_level := fnd_log.level_statement;
  end if;

end convertEcxToFndDebug;


procedure setDebugMode (
  p_subscription_guid   in raw,
  p_transaction_type    in varchar2,
  p_transaction_subtype in varchar2,
  p_party_site_id       in varchar2,
  p_debug_mode          in pls_integer)
is

  l_debug_level         varchar2(2);
  l_transaction_type    varchar2(2000);
  l_transaction_subtype varchar2(2000);
  l_party_site_id       varchar2(2000);
  l_sub_param           varchar2(4000);

  cursor c_sub_param is
  select parameters
  from wf_event_subscriptions
  where guid = p_subscription_guid;

begin
  -- always takes event debug mode over the subscription debug mode.
  if p_debug_mode is not null then
     convertEcxToFndDebug(p_debug_mode);
     return;
  end if;

  -- get the debug level from subscription.
  open c_sub_param;
  fetch c_sub_param into l_sub_param;
  close c_sub_param;

  -- nothing is set to the subscription, so set the default debug mode.
  if (l_sub_param is null) then
    return;
  end if;

  l_debug_level := wf_event_functions_pkg.subscriptionparameters(l_sub_param,
                   'ECX_DEBUG_LEVEL');

  -- if no ecx_debug_level is specified, then it should use the profile option.
  if l_debug_level is null then
    return;
  end if;

  -- At this point, there is some debug level is set at subscription.
  l_transaction_type := wf_event_functions_pkg.subscriptionparameters(l_sub_param,
                        'ECX_TRANSACTION_TYPE');

  l_transaction_subtype := wf_event_functions_pkg.subscriptionparameters(l_sub_param,
                          'ECX_TRANSACTION_SUBTYPE');

  l_party_site_id := wf_event_functions_pkg.subscriptionparameters(l_sub_param,
                     'ECX_PARTY_SITE_ID');

  if (l_transaction_type is null) and  (l_party_site_id is null) and
     (l_transaction_subtype is null) then
      convertEcxToFndDebug(l_debug_level);
      return;
  end if;

  if (l_transaction_type is not null) and
     (l_transaction_type <> p_transaction_type) then
      return;
  end if;

  if (l_transaction_subtype is not null) and
     (l_transaction_subtype <> p_transaction_subtype) then
      return;
  end if;

  if (l_party_site_id is not null) and
     (l_party_site_id <> p_party_site_id) then
      return;
  end if;

  convertEcxToFndDebug(l_debug_level);

exception
  when others then
    raise;
end setDebugMode;

--
-- TPPreProcessing
-- Standard XML Gateway Subscription to perform User to TP and TP to
-- transaction validation and also to perform the initial logging
-- IN:
--   p_subscription_guid - GUID of Subscription to be processed
--   p_event             - Event to be processed
--

function TPPreProcessing(
  p_subscription_guid  in      raw,
  p_event              in out nocopy wf_event_t
) return varchar2
is
  l_msgid                   RAW(16);
  l_process_id              RAW(16);
  l_tran_type               varchar2(240);
  l_tran_subtype            varchar2(240);
  l_std_code                varchar2(2000);
  l_std_type                varchar2(2000);
  l_party_id                varchar2(256);
  l_party_site_id           varchar2(256);
  l_party_type              varchar2(50);
  l_protocol_type           varchar2(500);
  l_protocol_address        varchar2(2000);
  l_username                varchar2(500);
  l_password                varchar2(500);
  l_attribute1              varchar2(500);
  l_attribute2              varchar2(500);
  l_attribute3              varchar2(500);
  l_attribute4              varchar2(500);
  l_attribute5              varchar2(500);
  l_internal_control_number pls_integer;
  l_trigger_id              number;
  l_doc_number              varchar2(256);
  l_tp_user            varchar2(500);
  p_tp_header_id            varchar2(500);

  p_ret_code                pls_integer;
  p_errmsg                  varchar2(200);
  l_debug_mode              pls_integer;
  l_payload                 clob;
  is_valid		    varchar2(20);
  l_module		    varchar2(200);
  rule_exception            exception;

  cursor c_ecx_trigger_id is
  select ecx_trigger_id_s.NEXTVAL
  from dual;

begin

  l_module := 'ecx.plsql.ecx_rule.TPPreProcessing';
  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level)
  then
    wf_log_pkg.string(wf_log_pkg.level_procedure, l_module ||'.begin',
       'Starting TPPreProcessing rule function.');
  end if;

  -- validate the inbound request
  l_msgid := p_event.getValueForParameter('#MSG_ID');
  if l_msgid is null
  then
    l_msgid := p_event.getValueForParameter('ECX_MSGID');
     if l_msgid is null
     then
       return 'ERROR';
     end if;
  end if;

  open c_ecx_trigger_id;
  fetch c_ecx_trigger_id into l_trigger_id;
  close c_ecx_trigger_id;
  p_event.AddParameterToList('ECX_TRIGGER_ID', l_trigger_id);

  l_process_id := p_event.getValueForParameter('ECX_PROCESS_ID');
  if(l_process_id is null)
  then
    l_process_id := l_msgid;
  end if;

  l_tran_type := p_event.getValueForParameter('ECX_TRANSACTION_TYPE');
  l_tran_subtype := p_event.getValueForParameter('ECX_TRANSACTION_SUBTYPE');
  l_std_type := p_event.getValueForParameter('ECX_MESSAGE_TYPE');
  l_std_code := p_event.getValueForParameter('ECX_MESSAGE_STANDARD');
  l_party_site_id := p_event.getValueForParameter('ECX_PARTY_SITE_ID');
  l_tp_user := p_event.getValueForParameter('ECX_TP_USER');

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'l_tran_type: ' || l_tran_type);
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'l_tran_subtype: ' || l_tran_subtype);
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'l_std_type: ' || l_std_type);
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'l_std_code: ' || l_std_code);
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'l_party_site_id: ' || l_party_site_id);
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'l_tp_user: ' || l_tp_user);
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'l_trigger_id: ' || l_trigger_id);
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'l_process_id: ' || l_process_id);
  end if;

  is_valid := ecx_trading_partner_pvt.validateTPUser(
  	p_transaction_type     => l_tran_type,
	p_transaction_subtype  => l_tran_subtype,
	p_standard_code        => l_std_code,
	p_standard_type        => l_std_type,
	p_party_site_id        => l_party_site_id,
	p_user_name            => l_tp_user,
	x_tp_header_id         => p_tp_header_id,
	retcode                => p_ret_code,
	errmsg                 => p_errmsg);

  if(is_valid = 'N')
  then
    if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level)
    then
      wf_log_pkg.string(wf_log_pkg.level_error, l_module,
                        ecx_debug.getMessage(ecx_utils.i_errbuf,
                                             ecx_utils.i_errparams));
    end if;
    raise rule_exception;
  end if;

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level)
  then
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
                      'Validated User and TP Setup.');
  end if;

  -- retrieve the event parameters and perform the logging.
  l_doc_number := p_event.getValueForParameter('ECX_DOCUMENT_NUMBER');
  if(l_doc_number is null)
  then
    l_doc_number := l_trigger_id;
  end if;

  l_party_type := p_event.getValueForParameter('ECX_PARTY_TYPE');
  l_protocol_type := p_event.getValueForParameter('ECX_PROTOCOL_TYPE');
  l_protocol_address := p_event.getValueForParameter('ECX_PROTOCOL_ADDRESS');
  l_attribute1 := p_event.getValueForParameter('ECX_ATTRIBUTE1');
  l_attribute2 := p_event.getValueForParameter('ECX_ATTRIBUTE2');
  l_attribute3 := p_event.getValueForParameter('ECX_ATTRIBUTE3');
  l_attribute4 := p_event.getValueForParameter('ECX_ATTRIBUTE4');
  l_attribute5 := p_event.getValueForParameter('ECX_ATTRIBUTE5');

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level)
  then
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'l_party_type: ' || l_party_type);
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'l_protocol_type: ' || l_protocol_type);
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'l_protocol_address: ' || l_protocol_address);
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'l_attribute1: ' || l_attribute1);
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'l_attribute2: ' || l_attribute2);
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'l_attribute3: ' || l_attribute3);
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'l_attribute4: ' || l_attribute4);
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'l_attribute5: ' || l_attribute5);
  end if;

  -- this to make sure that the payload has something before
  -- insert into the doclog table.
  l_payload := p_event.getEventData();
  if (l_payload is null) or
     (dbms_lob.getlength(l_payload) = 0) then
    if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level)
    then
      wf_log_pkg.string(wf_log_pkg.level_error, l_module,
                        'Payload is null');
     end if;
     return 'ERROR';
  end if;

  ecx_errorlog.log_receivemessage (
  	caller			=> 'JMS Queue',
	status_text		=> 'SUCCESS',
	err_msg 		=> null,
	receipt_msgid 		=> l_msgid,
	trigger_id 		=> l_trigger_id,
	message_type 		=> l_std_type,
	message_standard 	=> l_std_code,
	transaction_type 	=> l_tran_type,
	transaction_subtype 	=> l_tran_subtype,
	document_number 	=> l_doc_number,
	partyid 		=> l_party_id,
	party_site_id 		=> l_party_site_id,
	party_type 		=> l_party_type,
	protocol_type 		=> l_protocol_type,
	protocol_address 	=> l_protocol_address,
	username 		=> l_username,
	encrypt_password 	=> l_password,
	attribute1 		=> l_attribute1,
	attribute2 		=> l_attribute2,
	attribute3 		=> l_attribute3,
	attribute4 		=> l_attribute4,
	attribute5 		=> l_attribute5,
	payload 		=> l_payload,
        returnval 		=> p_errmsg);

  if(p_errmsg <> 'SUCCESS')
  then
    if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level)
    then
      wf_log_pkg.string(wf_log_pkg.level_error, l_module,
                        ecx_debug.getMessage(ecx_utils.i_errbuf,
                                             ecx_utils.i_errparams));
    end if;
    raise rule_exception;
  end if;

return 'SUCCESS';
exception
  when others then
    ecx_errorlog.inbound_trigger(
    	l_trigger_id,
        l_msgid,
        l_process_id,
        ecx_utils.i_ret_code,
        ecx_utils.i_errbuf,
        ecx_utils.i_errparams
    );

    wf_event.setErrorInfo(p_event,'ERROR');
    p_event.setErrorMessage(ecx_debug.getMessage(ecx_utils.i_errbuf,
                                                 ecx_utils.i_errparams));
    p_event.event_key := l_msgid;
    p_event.AddParameterToList('ECX_RETURN_CODE', ecx_utils.i_ret_code);
    p_event.AddParameterToList('ECX_ERROR_MSG',ecx_utils.i_errbuf);
    p_event.AddParameterToList('ECX_ERROR_PARAMS',ecx_utils.i_errparams);
    p_event.AddParameterToList('ECX_ERROR_TYPE', ecx_utils.error_type);
    p_event.AddParameterToList('ECX_TP_HEADER_ID', p_tp_header_id);
    p_event.AddParameterToList('ECX_TRANSACTION_TYPE',l_tran_type);
    p_event.AddParameterToList('ECX_TRANSACTION_SUBTYPE',l_tran_subtype);
    p_event.AddParameterToList('ECX_PARTY_ID',l_party_id);
    p_event.AddParameterToList('ECX_PARTY_SITE_ID',l_party_site_id);
    p_event.AddParameterToList('ECX_PARTY_TYPE',l_party_type);
    p_event.addParameterToList('ECX_DIRECTION','IN');
    p_event.addParameterToList('ECX_MESSAGE_STANDARD',l_std_code);
    p_event.addParameterToList('ECX_MESSAGE_TYPE', l_std_type);
    p_event.addParameterToList('ECX_DOCUMENT_NUMBER', l_doc_number);
    return 'ERROR';
end TPPreProcessing;



-- ReceiveTPMessage
--   Standard XML Gateway Subscription rule function for inbound B2B
-- IN:
--   p_subscription_guid - GUID of Subscription to be processed
--   p_event             - Event to be processes
-- NOTE: Determines the Inbound Transaction Queue
--
-- Standard B2B inbound function

function ReceiveTPMessage(
  p_subscription_guid  in      raw,
  p_event              in out nocopy wf_event_t
) return varchar2
is
  l_queue_name              varchar2(80);
  l_agent_name              varchar2(30);
  l_process_id              varchar2(200);
  l_msgid                   RAW(16);
  l_transaction_type        varchar2(240);
  l_transaction_subtype     varchar2(240);
  l_message_code            varchar2(2000);
  l_message_type            varchar2(2000);
  l_party_id                varchar2(256);
  l_party_site_id           varchar2(256);
  l_party_type              varchar2(50);
  l_protocol_type           varchar2(500);
  l_protocol_address        varchar2(2000);
  l_username                varchar2(500);
  l_password                varchar2(500);
  l_attribute1              varchar2(500);
  l_attribute2              varchar2(500);
  l_attribute3              varchar2(500);
  l_attribute4              varchar2(500);
  l_attribute5              varchar2(500);
  l_internal_control_number pls_integer;
  l_trigger_id              number;
  l_retcode                 pls_integer;
  l_retmsg                  varchar2(200);
  l_debug_mode              pls_integer;
  l_document_number         varchar2(256);
  l_payload                 clob;
  l_logfile                 Varchar2(80);
  l_msgid_out               raw(16);
  l_status                  Varchar2(256);
  l_time_stamp              date;
  l_tp_header_id            number;
  l_direction               Varchar2(20);
  l_param_list              wf_parameter_list_t;
  l_module                  Varchar2(2000);
  rule_exception            exception;
  isSavedToDocLogs          boolean;
  isTPCheck                 boolean;
  err_msg                   varchar2(500);
  cursor c_ecx_trigger_id is
  select ecx_trigger_id_s.NEXTVAL
  from dual;

begin
  l_module := 'ecx.plsql.ecx_rule.ReceiveTPMessage';
  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_procedure, l_module ||'.begin',
       'Starting ReceiveTPMessage rule function.');
  end if;

  -- initialize declared variables
  l_msgid := null;
  l_retcode := 0;
  l_retmsg := null;

  saved_fnd_runtime_debug := fnd_log.g_current_runtime_level;

  -- Get the data from the Event
  l_msgid := p_event.getValueForParameter('#MSG_ID');
  if l_msgid is null then
    l_msgid := p_event.getValueForParameter('ECX_MSGID');
  end if;
  l_debug_mode := p_event.getValueForParameter('ECX_DEBUG_LEVEL');
  l_trigger_id := p_event.getValueForParameter('ECX_TRIGGER_ID');
  l_party_site_id := p_event.getValueForParameter('ECX_PARTY_SITE_ID');
  l_process_id := p_event.getValueForParameter('ECX_PROCESS_ID');

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'l_process_id: ' || l_process_id);
  end if;

  -- The first time to call the rule function should have
  -- a party_site_id and the second time won't have the party_id info.
  if (l_process_id is null) then
    l_process_id := l_msgid;
    begin
      select trigger_id into l_trigger_id
      from ecx_inbound_logs
      where msgid = l_msgid;
      if (l_trigger_id is null) then
	 raise null_trigger_id;
      end if;
    exception
      when others then
        open c_ecx_trigger_id;
        fetch c_ecx_trigger_id into l_trigger_id;
        close c_ecx_trigger_id;
    end;
    p_event.AddParameterToList('ECX_TRIGGER_ID', l_trigger_id);
    ecx_debug.setErrorInfo(10, 10,'ECX_DEQUEUED_LOGGED');
    isTPCheck := false;

  else
    ecx_debug.setErrorInfo(10,10, 'ECX_PROCESSING_RULE');
    isTPCheck := true;
    if l_trigger_id is null then
      begin
        select max(trigger_id) into l_trigger_id
        from ecx_inbound_logs
        where msgid = l_msgid;
      exception
        when others then
            open c_ecx_trigger_id;
            fetch c_ecx_trigger_id into l_trigger_id;
            close c_ecx_trigger_id;
      end;
    end if;
  end if;

  ecx_errorlog.inbound_trigger(
      l_trigger_id,
      l_msgid,
      l_process_id,
      ecx_utils.i_ret_code,
      ecx_utils.i_errbuf
  );

  l_queue_name := null;

  -- Debug for parameter
  l_param_list := p_event.getParameterList();

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
    for i in l_param_list.first..l_param_list.last loop
      wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
         l_param_list(i).GetName || ':' || l_param_list(i).GetValue);
    end loop;
  end if;

  -- need to check if the msgid has already exists in ecx_doclogs,
  -- if yes, then it is the second queue calling this subscription.
  -- Otherwise, it is the first queue, then it need to insert an entry to doclogs.
  ecx_errorlog.getDocLogDetails
    (
     l_msgid,
     l_message_type,
     l_message_code,
     l_transaction_type,
     l_transaction_subtype,
     l_document_number,
     l_party_id,
     l_party_site_id,
     l_protocol_type,
     l_protocol_address,
     l_username,
     l_password,
     l_attribute1,
     l_attribute2,
     l_attribute3,
     l_attribute4,
     l_attribute5,
     l_logfile,
     l_internal_control_number,
     l_status,
     l_time_stamp,
     l_direction,
     l_retcode,
     l_retmsg
     );

  if (l_retcode <> 0) then
    isSavedToDocLogs := false;
  else
    isSavedToDocLogs := true;
  end if;

  if not isSavedToDocLogs then

    -- this to make sure that the payload has something before
    -- insert into the doclog table.
    l_payload := p_event.getEventData();
    if (l_payload is null) or
       (dbms_lob.getlength(l_payload) = 0) then
       ecx_utils.i_ret_code := l_retcode;
       ecx_utils.i_errbuf  := l_retmsg;
       raise rule_exception;
    end if;

    l_transaction_type := p_event.getValueForParameter('ECX_TRANSACTION_TYPE');
    l_transaction_subtype := p_event.getValueForParameter('ECX_TRANSACTION_SUBTYPE');
    l_message_code := nvl(p_event.getValueForParameter('ECX_MESSAGE_STANDARD'), 'OAG');
    l_message_type := nvl(p_event.getValueForParameter('ECX_MESSAGE_TYPE'), 'XML');
    l_document_number := p_event.getValueForParameter('ECX_DOCUMENT_NUMBER');
    if(l_document_number is null) then
      l_document_number := l_trigger_id;
    end if;
    l_party_id := p_event.getValueForParameter('ECX_PARTY_ID');
    l_party_site_id := p_event.getValueForParameter('ECX_PARTY_SITE_ID');
    l_party_type := p_event.getValueForParameter('ECX_PARTY_TYPE');
    l_protocol_type := p_event.getValueForParameter('ECX_PROTOCOL_TYPE');
    l_protocol_address := p_event.getValueForParameter('ECX_PROTOCOL_ADDRESS');
    l_username := p_event.getValueForParameter('ECX_USERNAME');
    l_password := p_event.getValueForParameter('ECX_PASSWORD');
    l_attribute1 := p_event.getValueForParameter('ECX_ATTRIBUTE1');
    l_attribute2 := p_event.getValueForParameter('ECX_ATTRIBUTE2');
    l_attribute3 := p_event.getValueForParameter('ECX_ATTRIBUTE3');
    l_attribute4 := p_event.getValueForParameter('ECX_ATTRIBUTE4');
    l_attribute5 := p_event.getValueForParameter('ECX_ATTRIBUTE5');
    l_internal_control_number := p_event.getValueForParameter('ECX_ICN');

    if l_internal_control_number is null then
      select ecx_inlstn_s.nextval into l_internal_control_number from dual;
      p_event.AddParameterToList('ECX_ICN', l_internal_control_number);
    end if;

    -- Save the Copy of the Document
    begin
      ecx_errorlog.log_document(
        l_retcode,
        l_retmsg,
        l_msgid,
        l_message_type,
        l_message_code,
        l_transaction_type,
        l_transaction_subtype,
        l_document_number,
        l_party_id,
        l_party_site_id,
        l_party_type,
        l_protocol_type,
        l_protocol_address,
        l_username,
        l_password,
        l_attribute1,
        l_attribute2,
        l_attribute3,
        l_attribute4,
        l_attribute5,
        l_payload,
        l_internal_control_number,
        'Message received.',
        'IN',
        null
      );

      if (l_retcode = 0) then
        isSavedToDocLogs := true;

        if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
          wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
             'Saved Message to DocLogs');
        end if;
      end if;

      if (l_retcode = 1) then
        if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
          wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
             'Return Message: '|| l_retmsg);
        end if;
      elsif (l_retcode >= 2) then
        if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
          wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
               ecx_debug.getMessage(ecx_utils.i_errbuf, ecx_utils.i_errparams));
        end if;
        raise rule_exception;
      end if;
    end;  -- save to doc_logs
  end if;

--  if not (isTPCheck) then
-- The tp_header_id is derived now in case of both Inbound and Transaction queues.
-- Hence removed the check on isTPCheck.
    if not isTPEnabled(l_transaction_type, l_transaction_subtype,
                     l_message_code, l_message_type, l_party_site_id,
                     l_queue_name, l_tp_header_id) then

      if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level) then
        wf_log_pkg.string(wf_log_pkg.level_error, l_module,
                        'The Standard: '||l_message_code|| ',' ||
                        'Transaction Type: '||l_transaction_type|| ',' ||
                        'SubType:'||l_transaction_subtype|| ',' ||
                        'Location Code'||l_party_site_id||
                        ' is not enabled in the XML Gateway Server. '||
                        ' Pls check your Setup');
      end if;

      ecx_debug.setErrorInfo(2,30,'ECX_RULE_INVALID_TP_SETUP',
                             'p_standard_code', l_message_code,
                             'p_transaction_type', l_transaction_type,
                             'p_transaction_subtype', l_transaction_subtype,
                             'p_party_site_id', l_party_site_id);

       raise rule_exception;
    end if;
    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_statement, l_module, 'Validated TP Setup.');
    end if;
  -- end if;
-- In case the message is in Transaction queue, the message should be processed.
-- Hence the queue name should be null.

    if (isTPCheck) then
       l_queue_name := null;
    end if;

  -- start to do the inbound processing and then dispatch the product
  -- team specified event.
  if (l_queue_name is null) then
    ecx_utils.g_direction := 'IN';
    ecx_utils.g_transaction_type := l_transaction_type;
    ecx_utils.g_transaction_subtype := l_transaction_subtype;

    setDebugMode (
      p_subscription_guid   => p_subscription_guid,
      p_transaction_type    => l_transaction_type,
      p_transaction_subtype => l_transaction_subtype,
      p_party_site_id       => l_party_site_id,
      p_debug_mode          => l_debug_mode);

    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
                      'FND Debug level is set to '
                      || fnd_log.g_current_runtime_level );
    end if;
    processTPMessage(l_msgid, l_debug_mode, l_process_id);
    if (ecx_utils.i_ret_code <> 2) then
       if (ecx_utils.g_event is not null and
          ecx_utils.g_event.event_name is not null) then
          p_event := ecx_utils.g_event;

          setEventParam(
          p_msgid                   => l_msgid,
          p_transaction_type        => l_transaction_type,
          p_transaction_subtype     => l_transaction_subtype,
          p_message_code            => l_message_code,
          p_message_type            => l_message_type,
          p_party_id                => l_party_id,
          p_party_site_id           => l_party_site_id,
          p_protocol_type           => l_protocol_type,
          p_protocol_address        => l_protocol_address,
          p_username                => l_username,
          p_password                => l_password,
          p_attribute1              => l_attribute1,
          p_attribute2              => l_attribute2,
          p_attribute3              => l_attribute3,
          p_attribute4              => l_attribute4,
          p_attribute5              => l_attribute5,
          p_internal_control_number => l_internal_control_number,
          p_debug_mode              => l_debug_mode,
          p_logfile                 => l_logfile,
          p_status                  => l_status,
          p_time_stamp              => l_time_stamp,
          p_document_number         => l_document_number,
          p_event                   => p_event);

          if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
            wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
                            'Dispatch ' ||p_event.event_name);
          end if;
          wf_event.dispatch('EXTERNAL', null, p_event);
      end if;
    end if;
  else
    -- enqueue to the second queue.
    enqueue_msg(p_event, l_queue_name, l_msgid, l_process_id);
    p_event.setCorrelationId(l_process_id);
    --p_event.setEventKey(l_process_id);

    ecx_debug.setErrorInfo(10, 10, 'ECX_PROCESSING_MESSAGE');
    ecx_errorlog.inbound_trigger(
                 l_trigger_id,
                 l_msgid,
                 l_process_id,
                 ecx_utils.i_ret_code,
                 ecx_utils.i_errbuf
                 );
  end if;

  fnd_log.g_current_runtime_level := saved_fnd_runtime_debug;

  if (ecx_utils.i_ret_code = 2) then
     if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
        wf_log_pkg.string(wf_log_pkg.level_statement, l_module, 'Finished with Error.');
     end if;
     ecx_debug.setErrorInfo(2,30, 'ECX_IN_RULE_PROCESING_ERROR');
     raise rule_exception;
  end if;

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module, 'Finished with Success.');
  end if;
  return 'SUCCESS';

exception
  when others then
    fnd_log.g_current_runtime_level := saved_fnd_runtime_debug;
    ecx_errorlog.inbound_trigger(
                  l_trigger_id,
                  l_msgid,
                  l_process_id,
                  ecx_utils.i_ret_code,
                  ecx_utils.i_errbuf,
                  ecx_utils.i_errparams
                  );

    wf_event.setErrorInfo(p_event,'ERROR');
    p_event.setErrorMessage(ecx_debug.getMessage(ecx_utils.i_errbuf,
                                                 ecx_utils.i_errparams));
    if (p_event.event_key is null)
    then
      p_event.event_key := l_msgid;
    end if;
    p_event.AddParameterToList('ECX_RETURN_CODE', ecx_utils.i_ret_code);
    p_event.AddParameterToList('ECX_ERROR_MSG',ecx_utils.i_errbuf);
    p_event.AddParameterToList('ECX_ERROR_PARAMS',ecx_utils.i_errparams);
    p_event.AddParameterToList('ECX_ERROR_TYPE', ecx_utils.error_type);
    p_event.AddParameterToList('ECX_TP_HEADER_ID', l_tp_header_id);
    p_event.AddParameterToList('ECX_TRANSACTION_TYPE',l_transaction_type);
    p_event.AddParameterToList('ECX_TRANSACTION_SUBTYPE',l_transaction_subtype);
    p_event.AddParameterToList('ECX_PARTY_ID',l_party_id);
    p_event.AddParameterToList('ECX_PARTY_SITE_ID',l_party_site_id);
    p_event.AddParameterToList('ECX_PARTY_TYPE',l_party_type);
    p_event.addParameterToList('ECX_DIRECTION','IN');
    p_event.addParameterToList('ECX_MESSAGE_STANDARD',l_message_code);
    p_event.addParameterToList('ECX_MESSAGE_TYPE', l_message_type);
    p_event.addParameterToList('ECX_DOCUMENT_ID', l_document_number);

    return 'ERROR';

end ReceiveTPMessage;


function CreateTPMessage (
  p_subscription_guid  in            raw,
  p_event              in out nocopy wf_event_t
) return varchar2
is

  l_module   varchar2(2000);

begin
  l_module := 'ecx.plsql.ecx_rule.CreateTPMessage';
  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_procedure, l_module ||'.begin',
       'Starting CreateTPMessage rule function.');
  end if;
  return (exec_wf(p_subscription_guid, p_event, 'ECXSTD', 'OUTBOUND_B2B'));

end CreateTPMessage;


end ecx_rule;

/
