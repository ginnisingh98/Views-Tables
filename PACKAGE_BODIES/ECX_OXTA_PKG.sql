--------------------------------------------------------
--  DDL for Package Body ECX_OXTA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECX_OXTA_PKG" as
/* $Header: ECXOXTAB.pls 120.2 2005/06/30 11:17:27 appldev ship $ */

procedure oxta_dequeue
(
     p_queue_name          in varchar2,
     p_message_type        out nocopy varchar2,
     p_message_standard	   out nocopy varchar2,
     p_transaction_type    out nocopy varchar2,
     p_transaction_subtype out nocopy varchar2,
     p_document_number     out nocopy varchar2,
     p_partyid             out nocopy varchar2,
     p_party_site_id       out nocopy varchar2,
     p_party_type          out nocopy varchar2,
     p_protocol_type		   out nocopy varchar2,
     p_protocol_address		 out nocopy varchar2,
     p_username		         out nocopy varchar2,
     p_password		         out nocopy varchar2,
     p_attribute1		       out nocopy varchar2,
     p_attribute2		       out nocopy varchar2,
     p_attribute3		       out nocopy varchar2,
     p_attribute4		       out nocopy varchar2,
     p_attribute5		       out nocopy varchar2,
     p_payload		         out nocopy clob,
     p_msgid               out nocopy raw,
     p_org_msgid           out nocopy varchar2
)  is
v_message	        system.ecxmsg;
v_dequeueoptions	dbms_aq.dequeue_options_t;
v_messageproperties	dbms_aq.message_properties_t;
l_password              varchar2(500);
l_errmsg		varchar2(2000);
l_retcode		pls_integer;
no_messages           exception;
pragma exception_init (no_messages, -25228);

begin
    	v_dequeueoptions.navigation := dbms_aq.FIRST_MESSAGE;
    	v_dequeueoptions.wait := dbms_aq.NO_WAIT;
    	v_dequeueoptions.correlation := 'OXTA';


		dbms_aq.dequeue
		(
		queue_name=>p_queue_name,
		dequeue_options=>v_dequeueoptions,
		message_properties=>v_messageproperties,
		payload=>v_message,
		msgid=>p_msgid
		);


     		p_message_type        	:= v_message.message_type;
     		p_message_standard	:= v_message.message_standard;
     		p_transaction_type      := v_message.transaction_type;
     		p_transaction_subtype   := v_message.transaction_subtype;
     		p_document_number       := v_message.document_number;
     		p_partyid	        := v_message.partyid;
     		p_party_site_id	        := v_message.party_site_id;
     		p_party_type	        := v_message.party_type;
     		p_protocol_type	        := v_message.protocol_type;
     		p_protocol_address	:= v_message.protocol_address;
     		p_username		:= v_message.username;
     		p_password		:= v_message.password;
     		p_attribute1	   	:= v_message.attribute1;
     		p_attribute2	   	:= v_message.attribute2;
     		p_attribute3	   	:= v_message.attribute3;
     		p_attribute4	   	:= v_message.attribute4;
     		p_attribute5	   	:= v_message.attribute5;
     		p_payload		:= v_message.payload;
     		p_org_msgid           	:= v_message.attribute5;


exception
when no_messages then
	raise no_messages;
end oxta_dequeue;

procedure oxta_enqueue
(
     p_queue_name          in varchar2,
     p_message_type        in varchar2,
     p_message_standard	   in varchar2,
     p_transaction_type    in varchar2,
     p_transaction_subtype in varchar2,
     p_document_number     in varchar2,
     p_partyid	           in varchar2,
     p_party_site_id       in varchar2,
     p_party_type          in varchar2,
     p_protocol_type		   in varchar2,
     p_protocol_address		 in varchar2,
     p_username		         in varchar2,
     p_password		         in varchar2,
     p_attribute1		       in varchar2,
     p_attribute2		       in varchar2,
     p_attribute3		       in varchar2,
     p_attribute4		       in varchar2,
     p_attribute5		       in varchar2,
     p_payload		         in clob,
     p_org_msgid           in varchar2,
     p_delay               in number,
     p_msgid               out nocopy raw
)  is
v_message	        system.ecxmsg;
v_enqueueoptions	dbms_aq.enqueue_options_t;
v_messageproperties	dbms_aq.message_properties_t;
begin

    v_message := system.ecxmsg( p_message_type,
                         p_message_standard,
                         p_transaction_type,
                         p_transaction_subtype,
                         p_document_number,
                         p_partyid,
                         p_party_site_id,
                         p_party_type,
                         p_protocol_type,
                         p_protocol_address,
                         p_username,
                         p_password,
                         p_payload,
                         p_attribute1,
                         p_attribute2,
                         p_attribute3,
                         p_attribute4,
                         p_org_msgid);

    v_messageproperties.correlation := 'OXTA';
    v_messageproperties.delay := p_delay;

		dbms_aq.enqueue
			(
			queue_name=>p_queue_name,
			enqueue_options=>v_enqueueoptions,
			message_properties=>v_messageproperties,
			payload=>v_message,
			msgid=>p_msgid
			);

end oxta_enqueue;

end ECX_OXTA_PKG;

/
