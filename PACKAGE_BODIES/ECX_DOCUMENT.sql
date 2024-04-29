--------------------------------------------------------
--  DDL for Package Body ECX_DOCUMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECX_DOCUMENT" AS
-- $Header: ECXSENDB.pls 120.8.12010000.2 2008/08/22 20:02:43 cpeixoto ship $

l_procedure          PLS_INTEGER := ecx_debug.g_procedure;
l_statement          PLS_INTEGER := ecx_debug.g_statement;
l_unexpected         PLS_INTEGER := ecx_debug.g_unexpected;
l_procedureEnabled   boolean     := ecx_debug.g_procedureEnabled;
l_statementEnabled   boolean     := ecx_debug.g_statementEnabled;
l_unexpectedEnabled  boolean     := ecx_debug.g_unexpectedEnabled;

/**
Get COnfirmation Document Data
**/
/* Bug 2122579 */
procedure getConfirmation
	(
	p_transaction_type	in	varchar2,
	p_transaction_subtype	in	varchar2,
        p_party_type            in      varchar2 ,--Bug #2183619
	p_document_id		in	varchar2,
	i_party_id		OUT	NOCOPY number,
	i_party_site_id		OUT     NOCOPY number
	)
is

i_method_name   varchar2(2000) := 'ecx_document.getConfirmation';

i_location_code		varchar2(200);
i_transaction_type	varchar2(200);
i_transaction_subtype   varchar2(200);
i_confirmation		pls_integer;
begin
if (l_procedureEnabled) then
 ecx_debug.push(i_method_name);
end if;
if(l_statementEnabled) then
  ecx_debug.log(l_statement,'transaction_type',p_transaction_type,i_method_name);
  ecx_debug.log(l_statement,'transaction_subtype',p_transaction_subtype,i_method_name);
  ecx_debug.log(l_statement,'party type', p_party_type,i_method_name);
  ecx_debug.log(l_statement,'document_id',p_document_id,i_method_name);
end if;


	begin
                select  party_site_id,
                        transaction_type,
                        transaction_subtype,
                        field8
                into    i_location_code,
                        i_transaction_type,
                        i_transaction_subtype,
                        i_confirmation
                from    ecx_doclogs
                where   internal_control_number = p_document_id;
	exception
	when no_data_found then
                ecx_debug.setErrorInfo(2,30,'ECX_CONFIRM_DOC_NOT_FOUND');
	        raise ecx_utils.program_exit;
	end;

	if i_transaction_type = 'BOD'
	then
                ecx_debug.setErrorInfo(2,30,'ECX_CONFIRM_GENERATE_FAILED');
		raise ecx_utils.program_exit;
	end if;

        if(l_statementEnabled) then
            ecx_debug.log(l_statement, 'Document Confirmation',i_confirmation,i_method_name);
	end if;

        /* Here we are checking to see if the sender of the inbound requested confirmation
           for the document */
        if i_confirmation = 0
        then
               ecx_debug.setErrorInfo(0,10,'ECX_CONFIRM_NOT_REQUESTED',
                                            'p_transaction_type',
                                             i_transaction_type,
                                             'p_transaction_subtype',
                                             i_transaction_subtype,
                                             'p_document_id',
                                             p_document_id,
                                             'p_location_code',
                                             i_location_code);
               raise ecx_no_delivery_required;
        end if;

	begin
           -- Added check for party type for bug #2183619
	   select  	party_id,
			party_site_id,
			confirmation
	   into		i_party_id,
			i_party_site_id,
			i_confirmation
	   from    	ecx_ext_processes eep,
                        ecx_transactions et,
		   	ecx_standards es,
			ecx_tp_headers eth,
			ecx_tp_details etd
           where        et.transaction_type = p_transaction_type
           and          et.transaction_subtype = p_transaction_subtype
           and          (p_party_type is null or eth.party_type = p_party_type)
           and          eep.transaction_id = et.transaction_id
	   and     	eep.direction = 'OUT'
	   and     	eep.standard_id = es.standard_id
	   and     	es.standard_code = 'OAG'
	   and		etd.source_tp_location_code = i_location_code
	   and		etd.tp_header_id = eth.tp_header_id
	   and		etd.ext_process_id = eep.ext_process_id;
	   --and		rownum < 2;

	exception
	when no_data_found then
                ecx_debug.setErrorInfo(2,30,'ECX_CONFIRM_TP_NOT_SETUP',
                                            'p_transaction_type',
                                             p_transaction_type,
                                             'p_transaction_subtype',
                                             p_transaction_subtype,
                                             'p_location_code',
                                             i_location_code);
		raise ecx_utils.program_exit;

      /* Start of bug #2183619*/
       when too_many_rows then
                ecx_debug.setErrorInfo(2,30,'ECX_PARTY_TYPE_NOT_SET ');
		raise ecx_utils.program_exit;
      /* End of bug #2183619 */

	end;
if(l_statementEnabled) then
  ecx_debug.log(l_statement,'i_party_id',i_party_id,i_method_name);
  ecx_debug.log(l_statement,'i_party_site_id',i_party_site_id,i_method_name);
end if;
if (l_procedureEnabled) then
  ecx_debug.pop(i_method_name);
end if;
exception
when ecx_no_delivery_required then
        if (l_procedureEnabled) then
         ecx_debug.pop(i_method_name);
        end if;
        raise;
when ecx_utils.program_exit then
        if (l_procedureEnabled) then
         ecx_debug.pop(i_method_name);
        end if;
        raise ecx_utils.program_exit;
when others then
        ecx_debug.setErrorInfo(2,30,SQLERRM ||'- ECX_DOCUMENT.getConfirmation');
	if (l_procedureEnabled) then
         ecx_debug.pop(i_method_name);
        end if;
	raise ecx_utils.program_exit;
end getConfirmation;

/**
Format and Queue the Outbound Engine Object for delivery
**/
procedure put_on_engqueue
	(
	p_queue_name			in	varchar2,
	p_transaction_type		in	varchar2,
	p_transaction_subtype		in	varchar2,
	p_document_id			in	varchar2,
	p_map_code			in	varchar2,
	p_message_type			in	varchar2,
	p_message_standard		in	varchar2,
	p_party_id			in	varchar2,
	p_party_site_id			in	varchar2,
	p_party_type			in	varchar2,
	p_ext_type			in	varchar2,
	p_ext_subtype			in	varchar2,
	p_party_source_location_code	in	varchar2,
	p_destination_type		in	varchar2,
	p_destination_address		in	varchar2,
	p_username			in	varchar2,
	p_password			in	varchar2,
	p_attribute1			IN	varchar2,
	p_attribute2			IN	varchar2,
	p_party_target_location_code	IN	varchar2,
	p_attribute4			IN	varchar2,
	p_attribute5			IN	varchar2,
	p_param1			IN	varchar2,
	p_param2			IN	varchar2,
	p_param3			IN	varchar2,
	p_param4			IN	varchar2,
	p_param5			IN	varchar2,
	o_msgid				out	NOCOPY raw
	)
is

i_method_name   varchar2(2000) := 'ecx_document.put_on_engqueue';

v_message		system.ecx_outengobj;
v_enqueueoptions     	dbms_aq.enqueue_options_t;
v_messageproperties  	dbms_aq.message_properties_t;

begin
if (l_procedureEnabled) then
 ecx_debug.push(i_method_name);
end if;

if(l_statementEnabled) then
  ecx_debug.log(l_statement,'p_queue_name',p_queue_name,i_method_name);
  ecx_debug.log(l_statement,'p_transaction_type',p_transaction_type,i_method_name);
  ecx_debug.log(l_statement,'p_transaction_subtype',p_transaction_subtype,i_method_name);
  ecx_debug.log(l_statement,'p_document_id',p_document_id,i_method_name);
  ecx_debug.log(l_statement,'p_map_code',p_map_code,i_method_name);
  ecx_debug.log(l_statement,'p_message_type',p_message_type,i_method_name);
  ecx_debug.log(l_statement,'p_message_standard',p_message_standard,i_method_name);
  ecx_debug.log(l_statement,'p_party_id',p_party_id,i_method_name);
  ecx_debug.log(l_statement,'p_party_site_id',p_party_site_id,i_method_name);
  ecx_debug.log(l_statement,'p_party_type',p_party_type,i_method_name);
  ecx_debug.log(l_statement,'p_ext_type',p_ext_type,i_method_name);
  ecx_debug.log(l_statement,'p_ext_subtype',p_ext_subtype,i_method_name);
  ecx_debug.log(l_statement,'p_party_source_location_code',p_party_source_location_code,i_method_name);
  ecx_debug.log(l_statement,'p_destination_type',p_destination_type,i_method_name);
  ecx_debug.log(l_statement,'p_destination_address',p_destination_address,i_method_name);
  ecx_debug.log(l_statement,'p_username',p_username,i_method_name);
  ecx_debug.log(l_statement,'p_password',p_password,i_method_name);
  ecx_debug.log(l_statement,'p_attribute1',p_attribute1,i_method_name);
  ecx_debug.log(l_statement,'p_attribute2',p_attribute2,i_method_name);
  ecx_debug.log(l_statement,'p_party_target_location_code',p_party_target_location_code,i_method_name);
  ecx_debug.log(l_statement,'p_attribute4',p_attribute4,i_method_name);
  ecx_debug.log(l_statement,'p_attribute5',p_attribute5,i_method_name);
  ecx_debug.log(l_statement,'p_param1',p_param1,i_method_name);
  ecx_debug.log(l_statement,'p_param2',p_param2,i_method_name);
  ecx_debug.log(l_statement,'p_param3',p_param3,i_method_name);
  ecx_debug.log(l_statement,'p_param4',p_param4,i_method_name);
  ecx_debug.log(l_statement,'p_param5',p_param5,i_method_name);
end if;

			v_message := system.ecx_outengobj
				(
				p_transaction_type,
				p_transaction_subtype,
				p_document_id,
				p_map_code,
				p_message_type,
				p_message_standard,
				p_party_id,
				p_party_site_id,
				p_party_type,
				p_ext_type,
				p_ext_subtype,
				p_party_source_location_code,
				p_destination_type,
				p_destination_address,
				p_username,
				p_password,
				p_attribute1,
				p_attribute2,
				p_party_target_location_code,
				p_attribute4,
				p_attribute5,
				p_param1,
				p_param2,
				p_param3,
				p_param4,
				p_param5
				);

   				dbms_aq.enqueue
					(
   					queue_name => p_queue_name,
   					enqueue_options => v_enqueueoptions,
   					message_properties => v_messageproperties,
   					payload => v_message,
   					msgid => o_msgid
					);
if(l_statementEnabled) then
 ecx_debug.log(l_statement,'o_msgid',o_msgid,i_method_name);
end if;
if (l_procedureEnabled) then
  ecx_debug.pop(i_method_name);
end if;
exception
when others then
        ecx_debug.setErrorInfo(2,30,SQLERRM ||'- ECX_DOCUMENT.PUT_ON_ENGQUEUE');
	if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
        end if;
	raise ecx_utils.program_exit;
end put_on_engqueue;

/* Get Delivery Attributes */
PROCEDURE get_delivery_attribs
		(
		i_transaction_type	IN	varchar2,
		i_transaction_subtype	IN	varchar2,
		i_party_id 		IN 	varchar2,
		i_party_site_id		IN	varchar2,
		i_party_type		IN OUT	NOCOPY varchar2,--bug #2183619
		i_standard_type		OUT	NOCOPY varchar2,
		i_standard_code		OUT	NOCOPY varchar2,
		i_ext_type		OUT	NOCOPY varchar2,
		i_ext_subtype		OUT	NOCOPY varchar2,
		i_source_code		OUT	NOCOPY varchar2,
		i_destination_code	OUT	NOCOPY varchar2,
		i_destination_type	OUT	NOCOPY varchar2,
		i_destination_address	OUT	NOCOPY varchar2,
		i_username		OUT	NOCOPY varchar2,
		i_password		OUT	NOCOPY varchar2,
		i_map_code		OUT	NOCOPY varchar2,
		i_queue_name		OUT	NOCOPY varchar2,
		i_tp_header_id		OUT	NOCOPY pls_integer
		)
IS

i_method_name   varchar2(2000) := 'ecx_document.get_delivery_attribs';

i_hub_user_id		number;
i_transaction_id        number;
i_hub_id                number;
i_connection_type       varchar2(30);
BEGIN
if (l_procedureEnabled) then
  ecx_debug.push(i_method_name);
end if;

if(l_statementEnabled) then
  ecx_debug.log(l_statement,'i_transaction_type',i_transaction_type,i_method_name);
  ecx_debug.log(l_statement,'i_transaction_subtype',i_transaction_subtype,i_method_name);
  ecx_debug.log(l_statement,'i_party_id',i_party_id,i_method_name);
  ecx_debug.log(l_statement,'i_party_site_id',i_party_site_id,i_method_name);
  ecx_debug.log(l_statement,'party_type',i_party_type,i_method_name);
end if;

        /** Validate whether the transaction exists ... **/
      Begin
        /* Added check for party type for bug #2183619 */
        select  transaction_id
        into    i_transaction_id
        from    ecx_transactions
        where   transaction_type = i_transaction_type
          and   transaction_subtype = i_transaction_subtype
          and   (i_party_type is null or party_type = i_party_type);
      Exception
      /* Start of bug #2183619*/
       when too_many_rows then
                ecx_debug.setErrorInfo(2,30,'ECX_PARTY_TYPE_NOT_SET');
		raise ecx_utils.program_exit;
      /* End of bug #2183619 */
      When Others then
                 /** Email goes to Sys Admin***/
                ecx_debug.setErrorInfo(1,30,'ECX_TRANSACTION_NOT_FOUND',
                                            'p_transaction_type',
                                            i_transaction_type,
                                            'p_transaction_subtype',
                                            i_transaction_subtype,
                                            'p_party_type',
                                            i_party_type);
		raise ecx_transaction_not_defined;
      End;
      begin
      -- Added check for party type for bug #2183619
	select	es.standard_type		standard_type,
		es.standard_code		standard_code,
		source_tp_location_code 	source,
		external_tp_location_code 	destination,
		protocol_type,
                protocol_address,
		username,
		password,
		hub_user_id,
                connection_type,
                hub_id ,
		map_code,
		eep.queue_name	queue_name,
		eep.ext_type	ext_type,
		eep.ext_subtype	ext_subtype,
		eth.party_type  party_type,
		eth.tp_header_id	tp_header_id,
		etd.tp_detail_id
        into    i_standard_type,
		i_standard_code,
		i_source_code,
		i_destination_code,
		i_destination_type,
                i_destination_address,
		i_username,
		i_password,
		i_hub_user_id,
                i_connection_type,
                i_hub_id,
		i_map_code,
		i_queue_name,
		i_ext_type,
		i_ext_subtype,
		i_party_type,
		i_tp_header_id,
		ecx_utils.g_tp_dtl_id
	from 	ecx_tp_details 		etd,
		ecx_tp_headers  	eth,
		ecx_ext_processes 	eep,
		ecx_transactions	et,
		ecx_standards		es,
		ecx_mappings		em
        where   ( eth.party_id	= i_party_id or i_party_id is null )
	and	eth.party_site_id = i_party_site_id
	and	eth.party_type = et.party_type
	and	eth.tp_header_id = etd.tp_header_id
	and	et.transaction_type = i_transaction_type
	and	et.transaction_subtype = i_transaction_subtype
        and     (i_party_type is null or et.party_type = i_party_type)
	and	et.transaction_id = eep.transaction_id
	and	es.standard_id = eep.standard_id
	and	eep.ext_process_id = etd.ext_process_id
	and	eep.direction = 'OUT'
	and	em.map_id = etd.map_id;
exception
/* Start of bug #2183619*/
       when too_many_rows then
                ecx_debug.setErrorInfo(2,30,'ECX_PARTY_TYPE_NOT_SET');
		raise ecx_utils.program_exit;
      /* End of bug #2183619 */
when others then
                  /** Email goes to Sys Admin***/
                ecx_debug.setErrorInfo(1,30,'ECX_DELIVERY_TP_NOT_SETUP',
                                            'p_transaction_type',
                                             i_transaction_type,
                                            'p_transaction_subtype',
                                             i_transaction_subtype,
                                            'p_party_site_id',
                                             i_party_site_id,
                                            'p_party_id',
                                             i_party_id,
                                            'p_party_type',
                                             i_party_type);

		raise ecx_no_party_setup;
end;
        -- Bug #2449729
        /* If the connection type is not DIRECT get the protocol_type,
           protocol_address from ecx_hubs and username,password
           from ecx_hub_users */
        if (i_connection_type <> 'DIRECT')
	then
              begin
                   select protocol_type,
                          protocol_address
                   into   i_destination_type,
                          i_destination_address
                   from ecx_hubs
                        where hub_id=i_hub_id;

                   if (i_hub_user_id is not null) then

                      select hub_entity_code,
                             username,
                             password
                      into   i_source_code,
                             i_username,
                             i_password
                      from ecx_hub_users
                      where hub_user_id = i_hub_user_id;

                   end if;

		exception
		when others then
                         /** Email goes to Sys Admin***/
                      ecx_debug.setErrorInfo(1,30,'ECX_DELIVERY_HUB_NOT_SETUP');
		      raise ecx_delivery_setup_error;
		end;
	end if;

if(l_statementEnabled) then
  ecx_debug.log(l_statement,'i_party_type',i_party_type,i_method_name);
  ecx_debug.log(l_statement,'i_standard_type',i_standard_type,i_method_name);
  ecx_debug.log(l_statement,'i_standard_code',i_standard_code,i_method_name);
  ecx_debug.log(l_statement,'i_ext_type',i_ext_type,i_method_name);
  ecx_debug.log(l_statement,'i_ext_subtype',i_ext_subtype,i_method_name);
  ecx_debug.log(l_statement,'i_source_code',i_source_code,i_method_name);
  ecx_debug.log(l_statement,'i_destination_code',i_destination_code,i_method_name);
  ecx_debug.log(l_statement,'i_destination_type',i_destination_type,i_method_name);
  ecx_debug.log(l_statement,'i_destination_address',i_destination_address,i_method_name);
  ecx_debug.log(l_statement,'i_username',i_username,i_method_name);
  ecx_debug.log(l_statement,'i_password',i_password,i_method_name);
  ecx_debug.log(l_statement,'i_queue_name',i_queue_name,i_method_name);
  ecx_debug.log(l_statement,'i_map_code',i_map_code,i_method_name);
  ecx_debug.log(l_statement,'i_tp_header_id',i_tp_header_id,i_method_name);
end if;
if (l_procedureEnabled) then
 ecx_debug.pop(i_method_name);
end if;
EXCEPTION
when ecx_transaction_not_defined then
        if (l_procedureEnabled) then
         ecx_debug.pop(i_method_name);
        end if;
        raise;
when ecx_no_party_setup then
        if (l_procedureEnabled) then
         ecx_debug.pop(i_method_name);
        end if;
	raise;
when ecx_no_delivery_required then
        if (l_procedureEnabled) then
         ecx_debug.pop(i_method_name);
        end if;
	raise;
when ecx_delivery_setup_error then
        if (l_procedureEnabled) then
         ecx_debug.pop(i_method_name);
        end if;
	raise;
WHEN ECX_UTILS.PROGRAM_EXIT THEN
	if (l_procedureEnabled) then
         ecx_debug.pop(i_method_name);
        end if;
	raise ecx_utils.program_exit;
WHEN OTHERS THEN
        ecx_debug.setErrorInfo(2,30,SQLERRM ||'- ECX_DOCUMENT.GET_DELIVERY_ATTRIBS');
	if (l_procedureEnabled) then
         ecx_debug.pop(i_method_name);
        end if;
	raise ecx_utils.program_exit;
END get_delivery_attribs;

/* This SEND is used by the CM */
/*PROCEDURE send_cm(
	retcode		      OUT    NOCOPY number,
	errmsg		      OUT    NOCOPY VARCHAR2,
        transaction_type      IN     VARCHAR2,
        transaction_subtype   IN     VARCHAR2,
	party_id	      IN     varchar2,
	party_site_id	      IN     varchar2,
        document_id           IN     varchar2,
	parameter1	      IN     varchar2,
	parameter2	      IN     varchar2,
	parameter3	      IN     varchar2,
	parameter4	      IN     varchar2,
	parameter5	      IN     varchar2,
	call_type	      IN     varchar2,
        debug_mode            IN     number
) IS
i_trigger_id number;
i_msgid		RAW(16);
BEGIN
	if call_type = 'ASYNC'
	then
       		send(
			transaction_type,
			transaction_subtype,
			party_id,
			party_site_id,
			document_id,
			parameter1,
			parameter2,
			parameter3,
			parameter4,
			parameter5,
            		debug_mode,
			i_trigger_id,
			retcode,
			errmsg
			);

	elsif call_type = 'SYNC'
	then
		senddirect
			(
			transaction_type,
			transaction_subtype,
			party_id,
			party_site_id,
			document_id,
			parameter1,
			parameter2,
			parameter3,
			parameter4,
			parameter5,
            	debug_mode,
			i_msgid,
			retcode,
			errmsg
			);
	end if;

exception
  when others then
       null;
END;
*/


/**
  Helper method. This procedure will call getConfirmation, outbound_trigger and
  get_delivery_attribs
**/
procedure trigger_outbound (transaction_type 	    IN	varchar2,
                            transaction_subtype     IN  varchar2,
                            party_id 		    IN  varchar2,
                            party_site_id 	    IN  varchar2,
                            document_id	 	    IN  varchar2,
                            status 		    IN  varchar2,
                            errmsg		    IN  varchar2,
                            trigger_id 		    IN  varchar2,
                            p_party_type 	    IN OUT NOCOPY varchar2,
                            p_party_id		    OUT NOCOPY varchar2,
                            p_party_site_id 	    OUT NOCOPY varchar2,
                            p_message_type 	    OUT NOCOPY varchar2,
                            p_message_standard 	    OUT NOCOPY varchar2,
	                    p_ext_type 		    OUT NOCOPY varchar2,
                            p_ext_subtype 	    OUT NOCOPY varchar2,
                            p_source_code	    OUT NOCOPY varchar2,
	                    p_destination_code 	    OUT NOCOPY varchar2,
                            p_destination_type 	    OUT NOCOPY varchar2,
                            p_destination_address   OUT NOCOPY varchar2,
	                    p_username 		    OUT NOCOPY varchar2,
                            p_password 		    OUT NOCOPY varchar2,
                            p_map_code		    OUT NOCOPY varchar2,
	                    p_queue_name 	    OUT NOCOPY varchar2,
                            p_tp_header_id          OUT NOCOPY varchar2
		            )
is
i_method_name   varchar2(2000) := 'ecx_document.trigger_outbound';
begin
--   if (logging_mode = 'Y') then
      ecx_errorlog.outbound_trigger (
                                 trigger_id,
                                 transaction_type,
                                 transaction_subtype,
                                 party_id,
                                 party_site_id,
                                 p_party_type, --Bug #2183619
                                 document_id,
                                 status, --'10',
                                 errmsg --'Triggering outbound...'
                                );
--   end if;

   /** Check for COnfirmation BOD **/
   if 	transaction_type = 'ECX'
   	and transaction_subtype = 'CBODO'
   then
      getConfirmation (
		      transaction_type,
		      transaction_subtype,
                      p_party_type , --Bug #2183619
		      document_id,
		      p_party_id,
		      p_party_site_id
		      );
   else
      p_party_id := party_id;
      p_party_site_id := party_site_id;
   end if;

      get_delivery_attribs (
	   		transaction_type,
			transaction_subtype,
			p_party_id,
			p_party_site_id,
			p_party_type,
			p_message_type,
			p_message_standard,
			p_ext_type,
			p_ext_subtype,
			p_source_code,
			p_destination_code,
			p_destination_type,
			p_destination_address,
			p_username,
			p_password,
			p_map_code,
			p_queue_name,
			p_tp_header_id
			);
exception
/* raised only by getConfirmation at this point */
WHEN ECX_NO_DELIVERY_REQUIRED THEN
   if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
   end if;
   raise;
when ecx_transaction_not_defined then
   if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
   end if;
   raise;
when ecx_no_party_setup then
   if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
   end if;
   raise;
when ecx_delivery_setup_error then
   if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
   end if;
   raise;
when ecx_utils.program_exit then
   if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
   end if;
   raise ecx_utils.program_exit;
when others then
   ecx_debug.setErrorInfo(2,30,SQLERRM ||'- ECX_DOCUMENT.TRIGGER_OUTBOUND');
   if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
   end if;
   raise ecx_utils.program_exit;
end trigger_outbound;


/* The SEND routine A-Synchronous Call */
PROCEDURE send(
        transaction_type      IN     VARCHAR2,
        transaction_subtype   IN     VARCHAR2,
	party_id	      IN     varchar2,
	party_site_id	      IN     varchar2,
        party_type            IN     varchar2 , --bug #2183619
        document_id           IN     varchar2,
	parameter1	      IN     varchar2 ,
	parameter2	      IN     varchar2 ,
	parameter3	      IN     varchar2 ,
	parameter4	      IN     varchar2 ,
	parameter5	      IN     varchar2 ,
        debug_mode            IN     PLS_INTEGER ,
	trigger_id	      OUT    NOCOPY PLS_INTEGER,
	retcode		      OUT    NOCOPY PLS_INTEGER,
	errmsg		      OUT    NOCOPY VARCHAR2
) IS
g_instlmode         VARCHAR2(100);
i_debug_level		pls_integer;
i_method_name   varchar2(2000) := 'ecx_document.send';

i_path 			varchar2(80);
v_message            	system.ecx_outengobj;

p_message_type		varchar2(200);
p_message_standard	varchar2(200);
p_ext_type		varchar2(200);
p_ext_subtype		varchar2(200);
p_destination_type	varchar2(200);
p_destination_address	ecx_tp_details.protocol_address%TYPE;
p_username		ecx_tp_details.username%TYPE;
p_password		ecx_tp_details.password%TYPE;
p_map_code		varchar2(200);
p_queue_name		varchar2(200);
p_attribute1		varchar2(200);
p_attribute2		varchar2(200);
p_attribute3		varchar2(200);
p_attribute4		varchar2(200);
p_attribute5		varchar2(200);
p_source_code		varchar2(200);
p_destination_code	varchar2(200);

p_party_id	        number; /* BUg 2122579 */
p_party_site_id	        number;
i_msgid			raw(16);
i_count			pls_integer:=0;
p_party_type            varchar2(200);
p_aflog_module_name         VARCHAR2(2000) ;


cursor c1
is
select	ecx_trigger_id_s.NEXTVAL
from	dual;

-- logging enabled
ecx_logging_enabled boolean := false;
logging_enabled varchar2(20);
module varchar2(2000);

begin
--before calling this API we need to re-initialize ecx_debug.g_v_module_name
ecx_debug.g_v_module_name :='ecx.plsql.';
ecx_debug.module_enabled(transaction_type,transaction_subtype,document_id);
  g_instlmode := wf_core.translate('WF_INSTALL');

  if(g_instlmode = 'EMBEDDED')
  then
    fnd_profile.get('AFLOG_ENABLED',logging_enabled);
    fnd_profile.get('AFLOG_MODULE',module);
    if(logging_enabled = 'Y' AND ((lower(module) like 'ecx%'
	AND instr(lower(ecx_debug.g_v_module_name),rtrim(lower(module),'%'))> 0)
	OR module='%')
       AND FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) then
      ecx_logging_enabled := true;
    end if;
  elsif(g_instlmode = 'STANDALONE')
  then
    if (i_debug_level > 0) then
      ecx_logging_enabled := true;
    end if;
  end if;
-- /logging enabled

--Get the Trigger Id
open 	c1;
fetch	c1 into trigger_id;
close	c1;

p_party_type := party_type ; --bug #2183619

IF (ecx_logging_enabled ) THEN

	--- Sets the Log Directory in both Standalone and the Embedded mode
	ecx_utils.getLogDirectory;
	p_aflog_module_name := 'trig.';
	IF (transaction_type is not null) THEN
		p_aflog_module_name := p_aflog_module_name||transaction_type||'.';
	END IF;
	IF (transaction_subtype is not null) THEN
		p_aflog_module_name := p_aflog_module_name||transaction_subtype||'.';
	END IF;
	IF (document_id is not null) THEN
		p_aflog_module_name := p_aflog_module_name||document_id||'.';
	END IF;
	IF (trigger_id is not null) THEN
		p_aflog_module_name := p_aflog_module_name||trigger_id;
	END IF;
	p_aflog_module_name := p_aflog_module_name||'.log';

	ecx_debug.enable_debug_new(debug_mode, ecx_utils.g_logdir, 'TRIG'||transaction_type||transaction_subtype||
		document_id||trigger_id||'.log', p_aflog_module_name);
END IF;

/* Assign local variables with the ecx_debug global variables*/
l_procedure          := ecx_debug.g_procedure;
l_statement          := ecx_debug.g_statement;
l_unexpected         := ecx_debug.g_unexpected;
l_procedureEnabled   := ecx_debug.g_procedureEnabled;
l_statementEnabled   := ecx_debug.g_statementEnabled;
l_unexpectedEnabled  := ecx_debug.g_unexpectedEnabled;

if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
end if;

if(l_statementEnabled) then
  ecx_debug.log(l_statement,'transaction_type', transaction_type,i_method_name);
  ecx_debug.log(l_statement,'transaction_subtype', transaction_subtype,i_method_name);
  ecx_debug.log(l_statement,'party_id', party_id,i_method_name);
  ecx_debug.log(l_statement,'party_site_id', party_site_id,i_method_name);
  ecx_debug.log(l_statement,'document_id', document_id,i_method_name);
  ecx_debug.log(l_statement,'parameter1', parameter1,i_method_name);
  ecx_debug.log(l_statement,'parameter2', parameter2,i_method_name);
  ecx_debug.log(l_statement,'parameter3', parameter3,i_method_name);
  ecx_debug.log(l_statement,'parameter4', parameter4,i_method_name);
  ecx_debug.log(l_statement,'parameter5', parameter5,i_method_name);
  ecx_debug.log(l_statement,'debug_mode',debug_mode,i_method_name);
end if;

/**
Initialize the ecx_utils.i_ret_code and i_errbuf variables;
**/
ecx_utils.i_ret_code :=0;
ecx_utils.i_errbuf := null;
--MLS
ecx_utils.i_errparams := null;
i_count :=0;

-- invoke trigger_outbound which will invoke outbound_trigger, getConfirmation and
-- get_delivery_attribs
ecx_debug.setErrorInfo(10,10,'ECX_TRIGGER_OUTBOUND');
trigger_outbound (transaction_type, transaction_subtype,
                  party_id, party_site_id,
                  document_id, ecx_utils.i_ret_code,
                  ecx_utils.i_errbuf, trigger_id,
                  p_party_type, p_party_id, p_party_site_id, p_message_type,
                  p_message_standard, p_ext_type, p_ext_subtype, p_source_code,
	          p_destination_code, p_destination_type, p_destination_address,
	          p_username, p_password, p_map_code,
	          p_queue_name, ecx_utils.g_rec_tp_id);

-- take appropriate action for destination_type
If p_destination_type = 'NONE' Then
    /** No email Action required **/
       ecx_debug.setErrorInfo(0,10,'ECX_DELIVERY_NOT_REQUIRED');
       raise ecx_no_delivery_required;
Elsif p_destination_address is null
then
   /** Email goes to Sys Admin***/

   ecx_debug.setErrorInfo(1,30,'ECX_DESTINATION_ADDR_NULL',
                               'p_party_site_id',
                                p_party_site_id,
                                'p_source_code',
                                p_source_code);
   raise ecx_delivery_setup_error;
end if;

			put_on_engqueue
				(
				p_queue_name,
				transaction_type,
				transaction_subtype,
				document_id,
				p_map_code,
				p_message_type,
				p_message_standard,
				p_party_id,
				p_party_site_id,
				p_party_type,
				p_ext_type,
				p_ext_subtype,
				p_source_code,
				p_destination_type,
				p_destination_address,
				p_username,
				p_password,
				null,
				null,
				p_destination_code,
				null,
				null,
				parameter1,
				parameter2,
				parameter3,
				parameter4,
				parameter5,
				i_msgid
				);

--- Assign the values back to the program OUT variables.
retcode := ecx_utils.i_ret_code;
errmsg := ecx_utils.i_errbuf;

if(l_statementEnabled) then
  ecx_debug.log(l_statement,'trigger_id',trigger_id,i_method_name);
end if;
if(l_unexpectedEnabled) then
  ecx_debug.log(l_unexpected,'retcode',retcode,i_method_name);
  ecx_debug.log(l_unexpected,'errmsg',ecx_debug.getMessage(errmsg,
                        ecx_utils.i_errparams),i_method_name); --MLS
end if;

if (l_procedureEnabled) then
  ecx_debug.pop(i_method_name);
end if;

IF (ecx_logging_enabled ) THEN
	ecx_debug.print_log;
	ecx_debug.disable_debug;
END IF;

EXCEPTION
/* raised only by getConfirmation at this point */
WHEN ECX_NO_DELIVERY_REQUIRED THEN
        retcode := ecx_utils.i_ret_code;
        errmsg := ecx_utils.i_errbuf;
        if(l_unexpectedEnabled) then
           ecx_debug.log(l_unexpected,'i_ret_code',ecx_utils.i_ret_code,i_method_name);
           ecx_debug.log(l_unexpected,'i_errmsg',ecx_utils.i_errbuf || ' at ECX_DOCUMENT.SEND',
	                i_method_name);
           ecx_debug.log(l_unexpected,'retcode',retcode,i_method_name);
           ecx_debug.log(l_unexpected,'errmsg',ecx_debug.getMessage(errmsg,
                                ecx_utils.i_errparams),i_method_name); --MLS
           ecx_debug.log(l_unexpected,'errtype',ecx_utils.error_type,i_method_name);
	end if;
        if (l_procedureEnabled) then
         ecx_debug.pop(i_method_name);
        end if;

	IF (ecx_logging_enabled ) THEN
		ecx_debug.print_log;
		ecx_debug.disable_debug;
	END IF;

        ecx_errorlog.outbound_trigger
                                (
                                trigger_id,
                                transaction_type,
                                transaction_subtype,
                                party_id,
                                party_site_id,
                                p_party_type, --bug #2183619
                                document_id,
                                ecx_utils.i_ret_code,
                                ecx_utils.i_errbuf,
                                ecx_utils.i_errparams --MLS
                                );
WHEN ECX_UTILS.PROGRAM_EXIT THEN
	retcode := ecx_utils.i_ret_code;
	errmsg := ecx_utils.i_errbuf;
	if(l_unexpectedEnabled) then
           ecx_debug.log(l_unexpected,'i_ret_code',ecx_utils.i_ret_code,i_method_name);
	   ecx_debug.log(l_unexpected,'i_errmsg',ecx_utils.i_errbuf ||SQLERRM||' at ECX_DOCUMENT.SEND',
	                i_method_name);
           ecx_debug.log(l_unexpected,'retcode',retcode,i_method_name);
           ecx_debug.log(l_unexpected,'errmsg',ecx_debug.getMessage(errmsg,
                                ecx_utils.i_errparams),i_method_name); --MLS
	end if;
        if (l_procedureEnabled) then
         ecx_debug.pop(i_method_name);
        end if;

	IF (ecx_logging_enabled ) THEN
		ecx_debug.print_log;
		ecx_debug.disable_debug;
	END IF;


        ecx_errorlog.outbound_trigger
                                (
                                trigger_id,
                                transaction_type,
                                transaction_subtype,
                                party_id,
                                party_site_id,
                   	        p_party_type, --bug #2183619
                                document_id,
                                ecx_utils.i_ret_code,
                                ecx_utils.i_errbuf,
                                ecx_utils.i_errparams --MLS
                                );

WHEN OTHERS THEN
        ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_DOCUMENT.SEND');
	retcode := ecx_utils.i_ret_code;
	errmsg  := ecx_utils.i_errbuf;
	if(l_unexpectedEnabled) then
           ecx_debug.log(l_unexpected,'i_ret_code',ecx_utils.i_ret_code,i_method_name);
	   ecx_debug.log(l_unexpected,'i_errmsg',SQLERRM||' at ECX_DOCUMENT.SEND',i_method_name);
	   ecx_debug.log(l_unexpected,'retcode',retcode,i_method_name,i_method_name);
           ecx_debug.log(l_unexpected,'errmsg',errmsg,i_method_name,i_method_name);
	end if;
        if (l_procedureEnabled) then
         ecx_debug.pop(i_method_name);
        end if;

	IF (ecx_logging_enabled ) THEN
		ecx_debug.print_log;
		ecx_debug.disable_debug;
	END IF;

        ecx_errorlog.outbound_trigger
                                (
                                trigger_id,
                                transaction_type,
                                transaction_subtype,
                                party_id,
                                party_site_id,
                                p_party_type, --bug #2183619
                                document_id,
                                ecx_utils.i_ret_code,
                                ecx_utils.i_errbuf,
                                ecx_utils.i_errparams
                                );
end send;


/* The SEND routine Synchronous Call */
PROCEDURE sendDirect(
        transaction_type      IN     VARCHAR2,
        transaction_subtype   IN     VARCHAR2,
	party_id	      IN     varchar2,
	party_site_id	      IN     varchar2,
        party_type            IN     VARCHAR2 ,--bug #2183619
        document_id           IN     varchar2,
        debug_mode            IN     PLS_INTEGER ,
	i_msgid		      OUT    NOCOPY RAW,
	retcode		      OUT    NOCOPY PLS_INTEGER,
	errmsg		      OUT    NOCOPY VARCHAR2
) IS
g_instlmode         VARCHAR2(100);
i_debug_level		pls_integer;
i_method_name   varchar2(2000) := 'ecx_document.sendDirect';
i_path 			varchar2(80);
v_message            	system.ecx_outengobj;

p_message_type		varchar2(200);
p_message_standard	varchar2(200);
p_ext_type		varchar2(200);
p_ext_subtype		varchar2(200);
p_destination_type	varchar2(200);
p_username		ecx_tp_details.username%TYPE;
p_password		ecx_tp_details.password%TYPE;
p_map_code		varchar2(200);
p_queue_name		varchar2(200);
p_attribute1		varchar2(200);
p_attribute2		varchar2(200);
p_attribute3		varchar2(200);
p_attribute4		varchar2(200);
p_attribute5		varchar2(200);
p_source_code		varchar2(2000);
p_destination_code		varchar2(200);
p_destination_address		ecx_tp_details.protocol_address%TYPE;

p_party_id		number; /* Bug 2122579 */
p_party_site_id		number;
i_count			pls_integer:=0;
trigger_id		pls_integer;
/* Start changes for Bug 2120165 */
i_paramCount Number;
i_parameterList		wf_parameter_list_t;
i_parameter		wf_parameter_t;
/* End of changes for Bug 2120165 */

cursor c1
is
select	ecx_trigger_id_s.NEXTVAL
from	dual;

p_party_type varchar2(200);
p_aflog_module_name         VARCHAR2(2000) ;

-- logging enabled
ecx_logging_enabled boolean := false;
logging_enabled varchar2(20);
module varchar2(2000);

begin
--before calling this API we need to re-initialize ecx_debug.g_v_module_name
ecx_debug.g_v_module_name :='ecx.plsql.';
ecx_debug.module_enabled(transaction_type,transaction_subtype,document_id);
  g_instlmode := wf_core.translate('WF_INSTALL');

  if(g_instlmode = 'EMBEDDED')
  then
    fnd_profile.get('AFLOG_ENABLED',logging_enabled);
    fnd_profile.get('AFLOG_MODULE',module);
     if(logging_enabled = 'Y' AND ((lower(module) like 'ecx%'
	AND instr(lower(ecx_debug.g_v_module_name),rtrim(lower(module),'%'))> 0)
	OR module='%')
       AND FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) then
      ecx_logging_enabled := true;
    end if;
  elsif(g_instlmode = 'STANDALONE')
  then
    if (i_debug_level > 0) then
      ecx_logging_enabled := true;
    end if;
  end if;
-- /logging enabled
p_party_type := party_type; --bug #2183619
--p_party_type :=  Wf_Engine.GetActivityAttrText('2120165', 21,279943, 'ECX_PARTY_TYPE', ignore_notfound => true);

--Get the Run Id
	open 	c1;
	fetch	c1 into trigger_id;
	close	c1;

IF (ecx_logging_enabled ) THEN

	--- Sets the Log Directory in both Standalone and the Embedded mode
	ecx_utils.getLogDirectory;
	ecx_utils.g_logfile := 'TRIG'||transaction_type||transaction_subtype||document_id||trigger_id||'.log';

	p_aflog_module_name := 'trig.';
	IF (transaction_type is not null) THEN
		p_aflog_module_name := p_aflog_module_name||transaction_type||'.';
	END IF;
	IF (transaction_subtype is not null) THEN
		p_aflog_module_name := p_aflog_module_name||transaction_subtype||'.';
	END IF;
	IF (document_id is not null) THEN
		p_aflog_module_name := p_aflog_module_name||document_id||'.';
	END IF;
	IF (trigger_id is not null) THEN
		p_aflog_module_name := p_aflog_module_name||trigger_id;
	END IF;

	p_aflog_module_name := p_aflog_module_name||'.log';

	ecx_debug.enable_debug_new(debug_mode, ecx_utils.g_logdir,ecx_utils.g_logfile, p_aflog_module_name);
END IF;

/* Assign local variables with the ecx_debug global variables*/
l_procedure          := ecx_debug.g_procedure;
l_statement          := ecx_debug.g_statement;
l_unexpected         := ecx_debug.g_unexpected;
l_procedureEnabled   := ecx_debug.g_procedureEnabled;
l_statementEnabled   := ecx_debug.g_statementEnabled;
l_unexpectedEnabled  := ecx_debug.g_unexpectedEnabled;

if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
end if;

if(l_statementEnabled) then
 ecx_debug.log(l_statement,'transaction_type', transaction_type,i_method_name);
 ecx_debug.log(l_statement,'transaction_subtype', transaction_subtype,i_method_name);
 ecx_debug.log(l_statement,'party_id', party_id,i_method_name);
 ecx_debug.log(l_statement,'party_site_id', party_site_id,i_method_name);
 ecx_debug.log(l_statement,'document_id', document_id,i_method_name);
 ecx_debug.log(l_statement,'party_type', party_type,i_method_name);
 ecx_debug.log(l_statement,'debug_mode',debug_mode,i_method_name);
end if;

/** check for the Event Object. If null , initialize it **/
if ecx_utils.g_event is null
then
	wf_event_t.initialize(ecx_utils.g_event);
end if;
i_parameterlist := wf_event_t.getParameterList(ecx_utils.g_event);
if(l_statementEnabled) then
	if i_parameterList is not null
	then
		for i in i_parameterList.FIRST..i_parameterList.LAST
		loop
			i_parameter := i_parameterList(i);
			ecx_debug.log(l_statement,i_parameter.getName(),i_parameter.getValue(),i_method_name);
		end loop;
		end if;
end if;

/**
Initialize the ecx_utils.i_ret_code and i_errbuf variables;
**/
ecx_utils.i_ret_code :=0;
ecx_utils.i_errbuf := null;
--MLS
ecx_utils.i_errparams := null;

-- make a new procedure which will invoke outbound_trigger, getConfirmation and
-- get_delivery_attribs
ecx_debug.setErrorInfo(10,10,'ECX_TRIGGER_OUTBOUND');
trigger_outbound (transaction_type, transaction_subtype,
                  party_id, party_site_id,
                  document_id, ecx_utils.i_ret_code,
                  ecx_utils.i_errbuf,  trigger_id,
                  p_party_type, p_party_id, p_party_site_id, p_message_type,
                  p_message_standard, p_ext_type, p_ext_subtype, p_source_code,
      	          p_destination_code, p_destination_type, p_destination_address,
	          p_username, p_password, p_map_code,
	          p_queue_name, ecx_utils.g_rec_tp_id);

-- take appropriate action for destination_type
If p_destination_type = 'NONE' Then
   /** No email Action required **/
       ecx_debug.setErrorInfo(0,10,'ECX_DELIVERY_NOT_REQUIRED');
       raise ecx_no_delivery_required;
Elsif p_destination_address is null
then
   ecx_debug.setErrorInfo(1,30,'ECX_DESTINATION_ADDR_NULL',
                               'p_party_site_id',
                                p_party_site_id,
                                'p_source_code',
                                p_source_code);
   raise ecx_delivery_setup_error;
end if;

			ECX_OUTBOUND.putmsg
				(
				transaction_type,
				transaction_subtype,
				p_party_id,
				p_party_site_id,
				p_party_type,
				document_id,
				p_map_code,
				p_message_type,
				p_message_standard,
				p_ext_type,
				p_ext_subtype,
				p_source_code,
				p_destination_type,
				p_destination_address,
				p_username,
				p_password,
				ecx_utils.g_company_name,
				null,
				p_destination_code,
				null,
				null,
				debug_mode,
                                trigger_id,
				i_msgid
				);

--- Assign the values back to the program OUT variables.
retcode := ecx_utils.i_ret_code;
errmsg := ecx_utils.i_errbuf;

if(l_unexpectedEnabled) then
  ecx_debug.log(l_unexpected,'retcode',retcode,i_method_name);
  ecx_debug.log(l_unexpected,'errmsg',ecx_debug.getMessage(errmsg,
                        ecx_utils.i_errparams),i_method_name); --MLS
end if;
if(l_statementEnabled) then
  ecx_debug.log(l_statement,'i_msgid',i_msgid,i_method_name);
end if;

if (l_procedureEnabled) then
  ecx_debug.pop(i_method_name);
end if;

IF (ecx_logging_enabled ) THEN
	ecx_debug.print_log;
	ecx_debug.disable_debug;
END IF;


EXCEPTION
/* raised only by getConfirmation at this point */
WHEN ECX_NO_DELIVERY_REQUIRED THEN
        retcode := ecx_utils.i_ret_code;
        errmsg := ecx_utils.i_errbuf;
        if(l_unexpectedEnabled) then
            ecx_debug.log(l_unexpected,'i_ret_code',ecx_utils.i_ret_code,i_method_name);
            ecx_debug.log(l_unexpected,'i_errmsg',ecx_utils.i_errbuf || ' at ECX_DOCUMENT.SENDDIRECT',
	             i_method_name);
            ecx_debug.log(l_unexpected,'retcode',retcode,i_method_name);
            ecx_debug.log(l_unexpected,'errmsg',ecx_debug.getMessage(errmsg,
                                ecx_utils.i_errparams),i_method_name); --MLS
            ecx_debug.log(l_unexpected,'errtype',ecx_utils.error_type,i_method_name);
	end if;
        if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
        end if;

	IF (ecx_logging_enabled ) THEN
		ecx_debug.print_log;
		ecx_debug.disable_debug;
	END IF;

        ecx_errorlog.outbound_trigger
                                (
                                trigger_id,
                                transaction_type,
                                transaction_subtype,
                                party_id,
                                party_site_id,
                                p_party_type, --bug #2183619
                                document_id,
                                ecx_utils.i_ret_code,
                                ecx_utils.i_errbuf,
                                ecx_utils.i_errparams --MLS
                                );
WHEN ECX_TRANSACTION_NOT_DEFINED THEN
        retcode := ecx_utils.i_ret_code;
        errmsg := ecx_utils.i_errbuf;
         if(l_unexpectedEnabled) then
            ecx_debug.log(l_unexpected,'i_ret_code',ecx_utils.i_ret_code,i_method_name);
            ecx_debug.log(l_unexpected,'i_errmsg',ecx_utils.i_errbuf || ' at ECX_DOCUMENT.SENDDIRECT',
	             i_method_name);
            ecx_debug.log(l_unexpected,'retcode',retcode,i_method_name);
            ecx_debug.log(l_unexpected,'errmsg',ecx_debug.getMessage(errmsg,
                                ecx_utils.i_errparams),i_method_name); --MLS
            ecx_debug.log(l_unexpected,'errtype',ecx_utils.error_type,i_method_name);
	 end if;
         if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
        end if;

	IF (ecx_logging_enabled ) THEN
		ecx_debug.print_log;
		ecx_debug.disable_debug;
	END IF;

        ecx_errorlog.outbound_trigger
                                (
                                trigger_id,
                                transaction_type,
                                transaction_subtype,
                                party_id,
                                party_site_id,
                                p_party_type, --bug #2183619
                                document_id,
                                ecx_utils.i_ret_code,
                                ecx_utils.i_errbuf,
                                ecx_utils.i_errparams --MLS
                                );

WHEN ECX_NO_PARTY_SETUP THEN
        retcode := ecx_utils.i_ret_code;
        errmsg := ecx_utils.i_errbuf;

        if(l_unexpectedEnabled) then
            ecx_debug.log(l_unexpected,'i_ret_code',ecx_utils.i_ret_code,i_method_name);
            ecx_debug.log(l_unexpected,'i_errmsg',ecx_utils.i_errbuf || ' at ECX_DOCUMENT.SENDDIRECT',
	             i_method_name);
            ecx_debug.log(l_unexpected,'retcode',retcode,i_method_name);
            ecx_debug.log(l_unexpected,'errmsg',ecx_debug.getMessage(errmsg,
                                ecx_utils.i_errparams),i_method_name); --MLS
            ecx_debug.log(l_unexpected,'errtype',ecx_utils.error_type,i_method_name);
	end if;
         if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
        end if;

	IF (ecx_logging_enabled ) THEN
		ecx_debug.print_log;
		ecx_debug.disable_debug;
	END IF;


        ecx_errorlog.outbound_trigger
                                (
                                trigger_id,
                                transaction_type,
                                transaction_subtype,
                                party_id,
                                party_site_id,
                                p_party_type, --bug #2183619
                                document_id,
                                ecx_utils.i_ret_code,
                                ecx_utils.i_errbuf,
                                ecx_utils.i_errparams --MLS
                                );

WHEN ECX_DELIVERY_SETUP_ERROR THEN
        retcode := ecx_utils.i_ret_code;
        errmsg := ecx_utils.i_errbuf;

        if(l_unexpectedEnabled) then
            ecx_debug.log(l_unexpected,'i_ret_code',ecx_utils.i_ret_code,i_method_name);
            ecx_debug.log(l_unexpected,'i_errmsg',ecx_utils.i_errbuf || ' at ECX_DOCUMENT.SENDDIRECT',
	             i_method_name);
            ecx_debug.log(l_unexpected,'retcode',retcode,i_method_name);
            ecx_debug.log(l_unexpected,'errmsg',ecx_debug.getMessage(errmsg,
                                ecx_utils.i_errparams),i_method_name); --MLS
            ecx_debug.log(l_unexpected,'errtype',ecx_utils.error_type,i_method_name);
	end if;
         if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
        end if;

	IF (ecx_logging_enabled ) THEN
		ecx_debug.print_log;
		ecx_debug.disable_debug;
	END IF;

        ecx_errorlog.outbound_trigger
                                (
                                trigger_id,
                                transaction_type,
                                transaction_subtype,
                                party_id,
                                party_site_id,
                                p_party_type, --bug #2183619
                                document_id,
                                ecx_utils.i_ret_code,
                                ecx_utils.i_errbuf,
                                ecx_utils.i_errparams --MLS
                                );
WHEN ECX_UTILS.PROGRAM_EXIT THEN
	retcode := ecx_utils.i_ret_code;
        errmsg := ecx_utils.i_errbuf;

	if(l_unexpectedEnabled) then
            ecx_debug.log(l_unexpected,'i_ret_code',ecx_utils.i_ret_code,i_method_name);
            ecx_debug.log(l_unexpected,'i_errmsg',ecx_utils.i_errbuf || ' at ECX_DOCUMENT.SENDDIRECT',
	             i_method_name);
            ecx_debug.log(l_unexpected,'retcode',retcode,i_method_name);
            ecx_debug.log(l_unexpected,'errmsg',ecx_debug.getMessage(errmsg,
                                ecx_utils.i_errparams),i_method_name); --MLS
            ecx_debug.log(l_unexpected,'errtype',ecx_utils.error_type,i_method_name);
	end if;
         if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
        end if;

	IF (ecx_logging_enabled ) THEN
		ecx_debug.print_log;
		ecx_debug.disable_debug;
	END IF;

        ecx_errorlog.outbound_trigger
                                (
                                trigger_id,
                                transaction_type,
                                transaction_subtype,
                                party_id,
                                party_site_id,
                                p_party_type, --bug #2183619
                                document_id,
                                ecx_utils.i_ret_code,
                                ecx_utils.i_errbuf,
                                ecx_utils.i_errparams --MLS
                                );
WHEN OTHERS THEN
        ecx_debug.setErrorInfo(2,30, SQLERRM||' - ECX_DOCUMENT.SENDDIRECT');
	retcode := ecx_utils.i_ret_code;
        errmsg := ecx_utils.i_errbuf;
	if(l_unexpectedEnabled) then
            ecx_debug.log(l_unexpected,'i_ret_code',ecx_utils.i_ret_code,i_method_name);
            ecx_debug.log(l_unexpected,'i_errmsg',ecx_utils.i_errbuf || ' at ECX_DOCUMENT.SENDDIRECT',
	             i_method_name);
            ecx_debug.log(l_unexpected,'retcode',retcode,i_method_name);
            ecx_debug.log(l_unexpected,'errmsg',ecx_debug.getMessage(errmsg,
                                ecx_utils.i_errparams),i_method_name); --MLS
            ecx_debug.log(l_unexpected,'errtype',ecx_utils.error_type,i_method_name);
	end if;
         if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
        end if;

	IF (ecx_logging_enabled ) THEN
		ecx_debug.print_log;
		ecx_debug.disable_debug;
	END IF;

        ecx_errorlog.outbound_trigger
                                (
                                trigger_id,
                                transaction_type,
                                transaction_subtype,
                                party_id,
                                party_site_id,
                                p_party_type, --bug #2183619
                                document_id,
                                ecx_utils.i_ret_code,
                                ecx_utils.i_errbuf,
                                ecx_utils.i_errparams --MLS
                                );
end senddirect;

procedure isDeliveryRequired
	(
        transaction_type      IN     VARCHAR2,
        transaction_subtype   IN     VARCHAR2,
	party_id	      IN     varchar2,
	party_site_id	      IN     varchar2,
        party_type            IN     varchar2 , --bug #2183619
        resultout             OUT    NOCOPY boolean,
	retcode		      OUT    NOCOPY PLS_INTEGER,
	errmsg		      OUT    NOCOPY VARCHAR2
	)
is
p_message_type		varchar2(200);
p_message_standard	varchar2(200);
p_ext_type		varchar2(200);
p_ext_subtype		varchar2(200);
p_destination_type	varchar2(200);
p_username		ecx_tp_details.username%TYPE;
p_password		ecx_tp_details.password%TYPE;
p_map_code		varchar2(200);
p_queue_name		varchar2(200);
p_source_code		varchar2(2000);
p_destination_code	varchar2(200);
p_destination_address	 ecx_tp_details.protocol_address%TYPE;
p_party_type            varchar2(200);

begin
p_party_type := party_type; --bug #2183619
	begin
		get_delivery_attribs
			(
			transaction_type,
			transaction_subtype,
			party_id,
			party_site_id,
			p_party_type,
			p_message_type,
			p_message_standard,
			p_ext_type,
			p_ext_subtype,
			p_source_code,
			p_destination_code,
			p_destination_type,
			p_destination_address,
			p_username,
			p_password,
			p_map_code,
			p_queue_name,
			ecx_utils.g_rec_tp_id
			);
		-- take appropriate action for destination_type
		If p_destination_type = 'NONE' Then
                        /** No email Action required **/
                      ecx_debug.setErrorInfo(0,10,'ECX_DELIVERY_NOT_REQUIRED');
           	      resultout := FALSE;
	   	      raise ecx_no_delivery_required;
		Elsif p_destination_address is null
		then
                        ecx_debug.setErrorInfo(1,30,'ECX_DESTINATION_ADDR_NULL',
                               'p_party_site_id',
                                party_site_id,
                                'p_source_code',
                                p_source_code);
		        resultout := FALSE;
	   		raise ecx_delivery_setup_error;
		end if;

                resultout := TRUE;
		exception
                when ecx_transaction_not_defined then
			resultout := FALSE;
			raise;
		when ecx_no_party_setup then
			resultout := FALSE;
		when ecx_no_delivery_required then
			resultout := FALSE;
		when ecx_delivery_setup_error then
			resultout := FALSE;
			raise;
                when ecx_utils.program_exit then
         		resultout := FALSE;
                        raise;
		when others then
			resultout := FALSE;
			raise ecx_utils.program_exit;
		end;
                -- Changed for MLS
                ecx_debug.setErrorInfo(0,10,'ECX_SUCCESSFUL_TP_LKP');
                errmsg:=ecx_utils.i_errbuf;
		retcode :=ecx_utils.i_ret_code;

exception
when ecx_transaction_not_defined then
        retcode := ecx_utils.i_ret_code;
        errmsg := ecx_utils.i_errbuf;
	raise;
when ecx_delivery_setup_error then
        retcode := ecx_utils.i_ret_code;
        errmsg := ecx_utils.i_errbuf;
	raise;
when ecx_utils.program_exit then
	retcode := ecx_utils.i_ret_code;
	errmsg := ecx_utils.i_errbuf;
	raise ecx_utils.program_exit;
when others then
	retcode := 2;
	errmsg := SQLERRM;
	raise;
end isDeliveryRequired;

procedure getExtPartyInfo
	(
        transaction_type      IN     VARCHAR2,
        transaction_subtype   IN     VARCHAR2,
	party_id	      IN     varchar2,
	party_site_id	      IN     varchar2,
        party_type            IN     VARCHAR2 ,--bug #2183619
	ext_type	      OUT    NOCOPY varchar2,
	ext_subtype	      OUT    NOCOPY varchar2,
	source_code	      OUT    NOCOPY varchar2,
	destination_code      OUT    NOCOPY varchar2,
	retcode		      OUT    NOCOPY PLS_INTEGER,
	errmsg		      OUT    NOCOPY VARCHAR2
	)
is
p_message_type		varchar2(200);
p_message_standard	varchar2(200);
p_destination_type	varchar2(200);
p_username		ecx_tp_details.username%TYPE;
p_password		ecx_tp_details.password%TYPE;
p_map_code		varchar2(200);
p_queue_name		varchar2(200);
p_destination_address	ecx_tp_details.protocol_address%TYPE;
p_party_type            varchar2(200);

begin
p_party_type := party_type; --bug #2183619
	get_delivery_attribs
		(
		transaction_type,
		transaction_subtype,
		party_id,
		party_site_id,
		p_party_type,
		p_message_type,
		p_message_standard,
		ext_type,
		ext_subtype,
		source_code,
		destination_code,
		p_destination_type,
		p_destination_address,
		p_username,
		p_password,
		p_map_code,
		p_queue_name,
		ecx_utils.g_rec_tp_id
		);

	-- take appropriate action for destination_type
	If p_destination_type = 'NONE' Then
                /** No email Action required **/
                ecx_debug.setErrorInfo(0,10,'ECX_DELIVERY_NOT_REQUIRED');
		raise ecx_no_delivery_required;
	Elsif p_destination_address is null
	then
                ecx_debug.setErrorInfo(1,30,'ECX_DESTINATION_ADDR_NULL',
                               'p_party_site_id',
                                party_site_id,
                                'p_source_code',
                                source_code);
	   	raise ecx_delivery_setup_error;
	end if;

        --Changed for MLS
        ecx_debug.setErrorInfo(0,10,'ECX_SUCCESSFUL_TP_LKP');
	retcode:=ecx_utils.i_ret_code;
	errmsg:=ecx_utils.i_errbuf;
exception
when ecx_no_party_setup then
	retcode := ecx_utils.i_ret_code;
	errmsg := ecx_utils.i_errbuf;
when ecx_no_delivery_required then
	retcode := ecx_utils.i_ret_code;
	errmsg := ecx_utils.i_errbuf;
when ecx_delivery_setup_error then
	retcode := ecx_utils.i_ret_code;
	errmsg := ecx_utils.i_errbuf;
when ecx_utils.program_exit then
	retcode := ecx_utils.i_ret_code;
	errmsg := ecx_utils.i_errbuf;
when others then
	retcode := 2;
	errmsg := SQLERRM;
end getExtPartyInfo;

PROCEDURE get_delivery_attribs
	(
	transaction_type      IN      varchar2,
	transaction_subtype   IN      varchar2,
	party_id              IN      varchar2,
	party_site_id         IN      varchar2,
	party_type            IN OUT  NOCOPY varchar2, --bug #2183619
	standard_type         OUT     NOCOPY varchar2,
	standard_code         OUT     NOCOPY varchar2,
	ext_type              OUT     NOCOPY varchar2,
	ext_subtype           OUT     NOCOPY varchar2,
	source_code           OUT     NOCOPY varchar2,
	destination_code      OUT     NOCOPY varchar2,
	destination_type      OUT     NOCOPY varchar2,
	destination_address   OUT     NOCOPY varchar2,
	username              OUT     NOCOPY varchar2,
	password              OUT     NOCOPY varchar2,
	map_code              OUT     NOCOPY varchar2,
	queue_name            OUT     NOCOPY varchar2,
	tp_header_id          OUT     NOCOPY pls_integer,
	retcode               OUT     NOCOPY pls_integer,
	retmsg                OUT     NOCOPY varchar2
	)
is
begin
		get_delivery_attribs
			(
			transaction_type,
			transaction_subtype,
			party_id,
			party_site_id,
			party_type,
			standard_type,
			standard_code,
			ext_type,
			ext_subtype,
			source_code,
			destination_code,
			destination_type,
			destination_address,
			username,
			password,
			map_code,
			queue_name,
			tp_header_id
			);
--Changed for MLS
ecx_debug.setErrorInfo(0,10,'ECX_SUCCESSFUL_TP_LKP');
retcode:=ecx_utils.i_ret_code;
retmsg:=ecx_utils.i_errbuf;
exception
when ecx_no_party_setup then
	retcode := ecx_utils.i_ret_code;
	retmsg := ecx_utils.i_errbuf;
when ecx_no_delivery_required then
	retcode := ecx_utils.i_ret_code;
	retmsg := ecx_utils.i_errbuf;
when ecx_delivery_setup_error then
	retcode := ecx_utils.i_ret_code;
	retmsg := ecx_utils.i_errbuf;
when ecx_utils.program_exit then
	retcode := ecx_utils.i_ret_code;
	retmsg := ecx_utils.i_errbuf;
when others then
	retcode := 2;
	retmsg := SQLERRM;
end get_delivery_attribs;

PROCEDURE resend
	(
	i_msgid		IN	RAW,
	retcode		OUT	NOCOPY PLS_INTEGER,
	errmsg		OUT	NOCOPY VARCHAR2,
        i_flag          IN      varchar2
	) IS

  Cursor c1(l_msgid in RAW) is
	Select	msgid,
               	message_type,
   		message_standard,
		transaction_type,
		transaction_subtype,
		document_number,
                party_type,
		partyid,
		party_site_id,
		protocol_type,
		protocol_address,
		username,
		password,
		attribute1,
		attribute2,
		attribute3,
		attribute4,
		attribute5,
		payload,
		time_stamp,
		status,
		direction
	From	ECX_DOCLOGS
	Where	msgid = l_msgid ;

  cursor c_tp_details
        (
        p_ext_type              IN      varchar2,
        p_ext_subtype           IN      varchar2,
        p_party_ext_code        in      varchar2,
        p_message_standard      in      varchar2,
        p_message_type          in      varchar2
        )
        is
        select  etd.protocol_type,
                etd.protocol_address,
                etd.username,
                etd.password,
                etd.connection_type,
                hub_id,
                hub_user_id
        from    ecx_tp_details etd,
                ecx_ext_processes eep,
                ecx_standards es
        where   etd.source_tp_location_code     = p_party_ext_code
        and     eep.ext_type                    = p_ext_type
        and     eep.ext_subtype                 = p_ext_subtype
        and     eep.ext_process_id              = etd.ext_process_id
        and     eep.standard_id                 = es.standard_id
        and     es.standard_code                = p_message_standard
        and     es.standard_type                = nvl(p_message_type, 'XML')
        and     eep.direction                   = 'OUT';

	c1_rec  c1%ROWTYPE;

  	o_retcode             pls_integer;
  	o_retmsg              varchar2(2000):= null;
        i_event               wf_event_t;
        i_from_agt            wf_agent_t := wf_agent_t(NULL, NULL);
        i_system              varchar2(200);
        l_protocol_type       varchar2(2000);
        l_protocol_address    varchar2(2000);
        l_username            varchar2(2000);
        l_password            varchar2(2000);
        l_use_old_info        boolean := false;
        l_connection_type     varchar2(200);
        l_hub_user_id         number;
        l_hub_id              number;


Begin
  --- Pick the messagefrom ECX_DOCLOGS and put it on the ECX_OUTBOUND
  --- ue again
  --- k the latest info for communication method updates if any
  --- ate ecx_external_retry table before enqueueing

  If ( i_msgid is  NULL ) Then
    -- MLS
    ecx_debug.setErrorInfo(1,30,'ECX_MSGID_NOT_NULL');
    retcode   := ecx_utils.i_ret_code;
    errmsg    := ecx_utils.i_errbuf;
    return;
  End If;

  Open c1(i_msgid);
  Fetch c1 into c1_rec;

  If c1%NOTFOUND Then
    -- MLS
    ecx_debug.setErrorInfo(1,30,'ECX_MSGID_NOT_FOUND','p_msgid',i_msgid);
    retcode    :=  ecx_utils.i_ret_code;
    errmsg     :=  ecx_utils.i_errbuf;
    Close c1;
    return;
  End If;

  Close c1;

  If ( c1_rec.party_site_id is NULL       OR
       c1_rec.transaction_type is NULL    OR
       c1_rec.transaction_subtype is NULL	 )
  Then
           -- MLS
    ecx_debug.setErrorInfo(1,30,'ECX_INVALID_TXN_PARAMS');
    retcode := ecx_utils.i_ret_code;
    errmsg  := ecx_utils.i_errbuf;
    return;
  End IF;

  open c_tp_details
  (
    c1_rec.transaction_type,
    c1_rec.transaction_subtype,
    c1_rec.party_site_id,
    c1_rec.message_standard,
    c1_rec.message_type
  );

  fetch c_tp_details into
    l_protocol_type,
    l_protocol_address,
    l_username,
    l_password,
    l_connection_type,
    l_hub_id,
    l_hub_user_id;

  if c_tp_details%NOTFOUND then
     -- Using old Information
     l_use_old_info := true;
  end if;
  close c_tp_details;

  /* If the connection type is not DIRECT get the protocol_type,
     protocol_address from ecx_hubs and username,password
     from ecx_hub_users */
   if ((not l_use_old_info) AND (l_connection_type <> 'DIRECT')) then
   begin
     select protocol_type,
            protocol_address
     into   l_protocol_type,
            l_protocol_address
     from ecx_hubs
     where hub_id=l_hub_id;

     if (l_hub_user_id is not null) then
         select username,
                password
         into   l_username,
                l_password
         from   ecx_hub_users
         where hub_user_id = l_hub_user_id;
     end if;

     exception
       when no_data_found then
       -- Using old Information
          l_use_old_info := true;
       end;
   end if;

   if l_use_old_info then
      l_protocol_type := c1_rec.protocol_type;
      l_protocol_address := c1_rec.protocol_address;
      l_username := c1_rec.username;
      l_password := c1_rec.password;
   end if;

        -- call wf_ecx_qh.enqueue with the correct parameters
        wf_event_t.initialize(i_event);
        i_event.addParameterToList('RESEND', 'Y');
        i_event.addParameterToList('ECX_MSG_ID', c1_rec.msgid);
        i_event.addParameterToList('MESSAGE_TYPE', c1_rec.message_type);
        i_event.addParameterToList('MESSAGE_STANDARD', c1_rec.message_standard);
        i_event.addParameterToList('TRANSACTION_TYPE', c1_rec.transaction_type);
        i_event.addParameterToList('TRANSACTION_SUBTYPE', c1_rec.transaction_subtype);
        i_event.addParameterToList('DOCUMENT_NUMBER', c1_rec.document_number);
        i_event.addParameterToList('PARTY_TYPE', c1_rec.party_type);
        i_event.addParameterToList('PARTYID', c1_rec.partyid);
        i_event.addParameterToList('PARTY_SITE_ID', c1_rec.party_site_id);
        i_event.addParameterToList('PROTOCOL_TYPE', l_protocol_type);
        i_event.addParameterToList('PROTOCOL_ADDRESS', l_protocol_address);
        i_event.addParameterToList('USERNAME', l_username);
        i_event.addParameterToList('PASSWORD', l_password);
        i_event.addParameterToList('ATTRIBUTE1', c1_rec.attribute1);
        i_event.addParameterToList('ATTRIBUTE2', c1_rec.attribute2);
        i_event.addParameterToList('ATTRIBUTE3', c1_rec.attribute3);
        i_event.addParameterToList('ATTRIBUTE4', c1_rec.attribute4);
        i_event.addParameterToList('ATTRIBUTE5', c1_rec.attribute5);
        i_event.addParameterToList('DIRECTION', c1_rec.direction);
        i_event.event_data := c1_rec.payload;

        -- set the from agent
        if (upper(l_protocol_type) = 'SOAP') then
          i_from_agt.setname('WF_WS_JMS_OUT');

          -- set default Web Services related attributes^M
          ecx_utils.g_event.addParameterToList('WS_SERVICE_NAMESPACE',
                           'http://xmlns.oracle.com/apps/fnd/XMLGateway');
          ecx_utils.g_event.addParameterToList('WS_PORT_OPERATION',
                            'ReceiveDocument');
          ecx_utils.g_event.addParameterToList('WS_HEADER_IMPL_CLASS',
                            'oracle.apps.fnd.wf.ws.client.DefaultHeaderGenerator');
          ecx_utils.g_event.addParameterToList('WS_RESPONSE_IMPL_CLASS',
                            'oracle.apps.fnd.wf.ws.client.WfWsResponse');

        else

          if (upper(l_protocol_type) = 'JMS') then
	    if(l_protocol_address is null) then
                i_from_agt.setname('WF_JMS_OUT');
	    else
                i_from_agt.setname(l_protocol_address);
            end if;
	  else
            i_from_agt.setname('ECX_OUTBOUND');
          end if;
        end if;

        select  name
        into    i_system
        from    wf_systems
        where   guid = wf_core.translate('WF_SYSTEM_GUID');

        i_from_agt.setsystem(i_system);
        i_event.setFromAgent(i_from_agt);
        wf_event.send(i_event);
        -- MLS
        ecx_debug.setErrorInfo(0,10,'ECX_RESEND_TRIGGERED');
        retcode    := ecx_utils.i_ret_code;
	errmsg     := ecx_utils.i_errbuf;

        ecx_errorlog.outbound_log(i_event);

        if (i_flag <> 'Y') then
          commit;
        end if;

  Exception
	When Others Then
	If c1%ISOPEN Then
	   Close c1;
	End IF;

        if (ecx_out_wf_qh.retmsg is null AND ecx_out_wf_qh.retcode = 0)
        then
                -- MLS
                ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_DOCUMENT.RESEND');
		retcode := ecx_utils.i_ret_code;
		errmsg  := ecx_utils.i_errbuf;
	else
                -- MLS
                ecx_debug.setErrorInfo(ecx_out_wf_qh.retcode,30,
                                       ecx_out_wf_qh.retmsg);
		retcode := ecx_utils.i_ret_code;
          	errmsg := ecx_utils.i_errbuf;
	end if;

        if (i_flag <> 'Y') then
           rollback;
        end if;
  End Resend;

/* new API added for bug #2215677 to return trading partner
   confirmation status */
procedure getConfirmationStatus
(
        i_transaction_type    IN     VARCHAR2,
        i_transaction_subtype IN     VARCHAR2,
	i_party_id	      IN     varchar2,
	i_party_site_id	      IN     varchar2,
        i_party_type          IN     varchar2 ,
	o_confirmation	      OUT    NOCOPY number
	)
as
begin


	select	etd.confirmation into o_confirmation
	from 	ecx_tp_details 		etd,
		ecx_tp_headers  	eth,
		ecx_ext_processes 	eep,
		ecx_transactions	et,
		ecx_standards		es,
		ecx_mappings		em
        where   ( eth.party_id	= i_party_id or i_party_id is null )
	and	eth.party_site_id = i_party_site_id
	and	eth.party_type = et.party_type
	and	eth.tp_header_id = etd.tp_header_id
	and	et.transaction_type = i_transaction_type
	and	et.transaction_subtype = i_transaction_subtype
      	and   (i_party_type is null or et.party_type = i_party_type)
	and	et.transaction_id = eep.transaction_id
	and	es.standard_id = eep.standard_id
	and	eep.ext_process_id = etd.ext_process_id
	and	eep.direction = 'OUT'
	and	em.map_id = etd.map_id;



exception
	when no_data_found then
               ecx_debug.setErrorInfo(2,30,'ECX_CONFIRM_STATUS_NOT_FOUND');
               raise ecx_utils.program_exit;


       when too_many_rows then
                ecx_debug.setErrorInfo(2,30,'ECX_PARTY_TYPE_NOT_SET ');
		raise ecx_utils.program_exit;


	when others then
                 ecx_debug.setErrorInfo(2,30, SQLERRM ||'- ECX_DOCUMENT.getConfirmationstatus');
		raise ecx_utils.program_exit;
end getConfirmationstatus;

end ecx_document;

/
