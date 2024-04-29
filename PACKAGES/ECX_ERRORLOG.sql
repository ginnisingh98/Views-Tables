--------------------------------------------------------
--  DDL for Package ECX_ERRORLOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECX_ERRORLOG" AUTHID CURRENT_USER as
-- $Header: ECXERRS.pls 120.5 2005/11/08 21:15:41 susaha ship $
/*#
 * This interface contains routines to track and report message delivery data.
 * @rep:scope public
 * @rep:product ECX
 * @rep:lifecycle active
 * @rep:displayname XML Gateway Message Delivery
 * @rep:compatibility S
 */

ecx_log_exit      exception;
procedure inbound_engine
	(
	i_process_id		IN	RAW,
	i_status		IN	varchar2,
	i_errmsg		IN	varchar2,
        i_errparams             IN      varchar2 default null
	);

procedure outbound_engine
	(
	i_trigger_id		IN	number,
	i_status		IN	varchar2,
	i_errmsg		IN	varchar2,
	i_outmsgid		IN	RAW,
        i_errparams             IN      varchar2 default null,
        i_party_type            IN      varchar2 default null
	);

/*#
 * Used by both Oracle and non Oracle messaging systems to report
 * delivery status. The status information is written to the XML Gateway
 * log tables to track and report transaction delivery data.
 * @param i_outmsgid Message ID for the outbound message delivered by the messaging system
 * @param i_status Message delivery status as reported by the messaging system.
 * @param i_errmsg Error messages reported by the messaging system
 * @param i_timestamp Time stamp from the messaging system indicating when it processed the outbound message
 * @param o_ret_code Return code for the procedure
 * @param o_ret_msg Return message for the procedure
 * @param i_errparams Error Parameter
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname  XML Gateway Message Delivery
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY ECX_MESSAGE_DELIVERY
 */
procedure external_system
	(
	i_outmsgid		IN	RAW,
	i_status		In	pls_integer,
	i_errmsg		IN	varchar2,
	i_timestamp		IN	date,
	o_ret_code		OUT	NOCOPY pls_integer,
	o_ret_msg		OUT	NOCOPY varchar2,
        i_errparams             IN      varchar2 default null
	);


procedure send_error
	(
	i_ret_code		IN	pls_integer,
	i_errbuf		IN	varchar2,
	i_snd_tp_id		IN	varchar2,
	i_document_number	In	varchar2,
	i_transaction_type	IN	varchar2,
	o_ret_code		OUT	NOCOPY pls_integer,
	o_ret_msg		OUT	NOCOPY varchar2
	);

procedure send_msg_api
        (
        x_retcode               OUT     NOCOPY pls_integer,
        x_retmsg                OUT     NOCOPY varchar2,
        p_retcode               IN      pls_integer,
        p_errbuf                IN      varchar2,
        p_error_type            IN      pls_integer default 20,
        p_party_id              IN      varchar2,
        p_party_site_id         IN      varchar2,
        p_transaction_type      IN      varchar2,
        p_transaction_subtype   IN      varchar2,
        p_party_type            IN      varchar2 default null,
        p_document_number       IN      varchar2 default null
        );

procedure inbound_trigger
        (
        i_trigger_id    IN      number,
        i_msgid         IN      raw,
        i_process_id    IN      raw,
        i_status        IN      varchar2,
        i_errmsg        IN      varchar2,
        i_errparams     IN      varchar2 default null
        );

procedure outbound_trigger
        (
        i_trigger_id            IN      number,
        i_transaction_type      IN      varchar2,
        i_transaction_subtype   IN      varchar2,
        i_party_id              IN      number,
        i_party_site_id         IN      varchar2,
        i_party_type            IN      varchar2 default null,--bug #2183619
        i_document_number       IN      varchar2,
        i_status                IN      varchar2,
        i_errmsg                IN      varchar2,
        i_errparams             IN      varchar2 default null
        );

procedure log_document
        (
        o_retcode              OUT    NOCOPY pls_integer,
        o_retmsg               OUT    NOCOPY varchar2,
        i_msgid                 IN    raw,
        i_message_type          IN    varchar2,
        i_message_standard      IN    varchar2,
        i_transaction_type      IN    varchar2,
        i_transaction_subtype   IN    varchar2,
        i_document_number       IN    varchar2,
        i_partyid               IN    varchar2,
        i_party_site_id         IN    varchar2,
        i_party_type            IN    varchar2,
        i_protocol_type         IN    varchar2,
        i_protocol_address      IN    varchar2,
        i_username              IN    varchar2,
        i_password              IN    varchar2,
        i_attribute1            IN    varchar2,
        i_attribute2            IN    varchar2,
        i_attribute3            IN    varchar2,
        i_attribute4            IN    varchar2,
        i_attribute5            IN    varchar2,
        i_payload               IN    clob,
        i_internal_control_num  IN    number    default null,
        i_status                IN    varchar2  default null,
        i_direction             IN    varchar2  default 'IN',
        i_outmsgid              IN    raw       default null,
        i_logfile               IN    varchar2  default null,
        i_item_type             IN    varchar2  default null,
        i_item_key              IN    varchar2  default null,
        i_activity_id           IN    varchar2  default null,
        i_event_name            IN    varchar2  default null,
        i_event_key             IN    varchar2  default null,
        i_cb_event_name         IN    varchar2  default null,
        i_cb_event_key          IN    varchar2  default null,
        i_block_mode            IN    varchar2  default null
       );


procedure update_log_document
       (
        i_msgid       In   raw,
        i_outmsgid    In   raw,
        i_status      In   varchar2,
        i_logfile     In   varchar2,
        i_update_type In   varchar2
       );
procedure getDoclogDetails
	(
	i_msgid                         in      raw,
	i_message_type                  OUT     NOCOPY varchar2,
	i_message_standard              OUT     NOCOPY varchar2,
	i_transaction_type              OUT     NOCOPY varchar2,
	i_transaction_subtype           OUT	NOCOPY  varchar2,
	i_document_number               OUT     NOCOPY varchar2,
	i_party_id                      OUT     NOCOPY varchar2,
	i_party_site_id                 OUT     NOCOPY varchar2,
	i_protocol_type                 OUT     NOCOPY varchar2,
	i_protocol_address              OUT     NOCOPY varchar2,
	i_username                      OUT     NOCOPY varchar2,
	i_password                      OUT     NOCOPY varchar2,
	i_attribute1                    OUT     NOCOPY varchar2,
	i_attribute2                    OUT     NOCOPY varchar2,
	i_attribute3                    OUT     NOCOPY varchar2,
	i_attribute4                    OUT     NOCOPY varchar2,
	i_attribute5                    OUT     NOCOPY varchar2,
	i_logfile                       OUT     NOCOPY varchar2,
	i_internal_control_number       OUT     NOCOPY number,
	i_status                        OUT     NOCOPY varchar2,
	i_time_stamp                     OUT    NOCOPY date,
	i_direction                     OUT     NOCOPY varchar2,
	 /* Bug 2241292 */
        o_retcode                       OUT    NOCOPY pls_integer,
        o_retmsg                        OUT    NOCOPY varchar2

	);

procedure log_resend(
        o_retcode        OUT   NOCOPY pls_integer,
        o_retmsg         OUT   NOCOPY varchar2,
        i_resend_msgid    IN   raw,
        i_msgid           IN   raw,
        i_errmsg          IN   varchar2,
        i_status          IN   varchar2,
        i_timestamp       IN   date
);

procedure outbound_log (
        p_event    IN    wf_event_t);

procedure log_receivemessage (
        caller varchar2,
	status_text varchar2,
	err_msg varchar2,
	receipt_msgid raw,
	trigger_id pls_integer,
	message_type varchar2,
	message_standard varchar2,
	transaction_type varchar2,
	transaction_subtype varchar2,
	document_number varchar2,
	partyid varchar2,
	party_site_id varchar2,
	party_type varchar2,
	protocol_type varchar2,
	protocol_address varchar2,
	username varchar2,
	encrypt_password varchar2,
	attribute1 varchar2,
	attribute2 varchar2,
	attribute3 varchar2,
	attribute4 varchar2,
	attribute5 varchar2,
	payload clob,
        returnval out nocopy varchar2);

end ecx_errorlog;

 

/
