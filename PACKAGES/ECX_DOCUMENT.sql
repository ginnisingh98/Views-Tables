--------------------------------------------------------
--  DDL for Package ECX_DOCUMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECX_DOCUMENT" AUTHID CURRENT_USER AS
-- $Header: ECXSENDS.pls 120.3 2005/10/30 23:57:31 susaha ship $
/** Exceptions raised from the ecx_document **/
ecx_transaction_not_defined     exception;
ecx_no_party_setup              exception;
ecx_delivery_setup_error        exception;
ecx_no_delivery_required        exception;

/** (A-Synchronous) Send api **/
procedure send(
        transaction_type      	IN     	VARCHAR2,
        transaction_subtype    	IN     	VARCHAR2,
	party_id		IN     	VARCHAR2,
	party_site_id		IN     	VARCHAR2,
        party_type              IN      VARCHAR2 default null,--bug #2183619
        document_id           	IN     	VARCHAR2,
	parameter1		IN	VARCHAR2	default null,
	parameter2		IN	VARCHAR2	default null,
	parameter3		IN	VARCHAR2	default null,
	parameter4		IN	VARCHAR2	default null,
	parameter5		IN	VARCHAR2	default null,
        debug_mode            	IN     	PLS_INTEGER DEFAULT 0,
	trigger_id		OUT    	NOCOPY PLS_INTEGER,
	retcode		        OUT    	NOCOPY PLS_INTEGER,
	errmsg			OUT    	NOCOPY VARCHAR2
	);

/** (Synchronous) Send Direct api to avoid racing condition **/
procedure sendDirect(
        transaction_type      	IN     VARCHAR2,
        transaction_subtype    	IN     VARCHAR2,
	party_id		IN     VARCHAR2,
	party_site_id		IN     VARCHAR2,
        party_type              IN     VARCHAR2 default null, --bug #2183619
        document_id           	IN     VARCHAR2,
        debug_mode            	IN     PLS_INTEGER DEFAULT 0,
	i_msgid			OUT    NOCOPY RAW,
	retcode		        OUT    NOCOPY PLS_INTEGER,
	errmsg			OUT    NOCOPY VARCHAR2
	);

/*  This is used by the CM */
/*procedure send_cm(
	retcode		        OUT    NOCOPY number,
	errmsg			OUT    NOCOPY VARCHAR2 ,
        transaction_type      	IN     VARCHAR2,
        transaction_subtype    	IN     VARCHAR2,
	party_id		IN     VARCHAR2,
	party_site_id		IN     VARCHAR2,
        document_id           	IN     VARCHAR2,
	parameter1		IN     VARCHAR2,
	parameter2		IN     VARCHAR2,
	parameter3		IN     VARCHAR2,
	parameter4		IN     VARCHAR2,
	parameter5		IN     VARCHAR2,
	call_type		IN     varchar2,
        debug_mode            	IN     number DEFAULT 0
	);
*/
procedure isDeliveryRequired
	(
	transaction_type      IN     VARCHAR2,
	transaction_subtype   IN     VARCHAR2,
	party_id              IN     varchar2,
	party_site_id         IN     varchar2,
        party_type            IN     VARCHAR2 default null,--bug #2183619
	resultout             OUT    NOCOPY boolean,
	retcode               OUT    NOCOPY PLS_INTEGER,
	errmsg                OUT    NOCOPY VARCHAR2
	);

procedure getExtPartyInfo
	(
	transaction_type      IN     VARCHAR2,
	transaction_subtype   IN     VARCHAR2,
	party_id              IN     varchar2,
	party_site_id         IN     varchar2,
        party_type            IN     VARCHAR2 default null,--bug #2183619
	ext_type              OUT    NOCOPY varchar2,
	ext_subtype           OUT    NOCOPY varchar2,
	source_code           OUT    NOCOPY varchar2,
	destination_code      OUT    NOCOPY varchar2,
	retcode               OUT    NOCOPY PLS_INTEGER,
	errmsg                OUT    NOCOPY VARCHAR2
	);
PROCEDURE get_delivery_attribs
	(
	i_transaction_type      IN      varchar2,
	i_transaction_subtype   IN      varchar2,
	i_party_id              IN      varchar2,
	i_party_site_id         IN      varchar2,
	i_party_type            IN OUT  NOCOPY varchar2, --bug #2183619
	i_standard_type         OUT     NOCOPY varchar2,
	i_standard_code         OUT     NOCOPY varchar2,
	i_ext_type              OUT     NOCOPY varchar2,
	i_ext_subtype           OUT     NOCOPY varchar2,
	i_source_code           OUT     NOCOPY varchar2,
	i_destination_code      OUT     NOCOPY varchar2,
	i_destination_type      OUT     NOCOPY varchar2,
	i_destination_address   OUT     NOCOPY varchar2,
	i_username              OUT     NOCOPY varchar2,
	i_password              OUT     NOCOPY varchar2,
	i_map_code              OUT     NOCOPY varchar2,
	i_queue_name            OUT     NOCOPY varchar2,
	i_tp_header_id          OUT     NOCOPY pls_integer
	);

PROCEDURE get_delivery_attribs
	(
	transaction_type      	IN      varchar2,
	transaction_subtype   	IN      varchar2,
	party_id              	IN      varchar2,
	party_site_id         	IN      varchar2,
	party_type              IN OUT  NOCOPY varchar2, --Bug #2183619
	standard_type         	OUT     NOCOPY varchar2,
	standard_code         	OUT     NOCOPY varchar2,
	ext_type              	OUT     NOCOPY varchar2,
	ext_subtype           	OUT     NOCOPY varchar2,
	source_code           	OUT     NOCOPY varchar2,
	destination_code      	OUT     NOCOPY varchar2,
	destination_type      	OUT     NOCOPY varchar2,
	destination_address   	OUT     NOCOPY varchar2,
	username              	OUT     NOCOPY varchar2,
	password              	OUT     NOCOPY varchar2,
	map_code              	OUT     NOCOPY varchar2,
	queue_name            	OUT     NOCOPY varchar2,
	tp_header_id          	OUT     NOCOPY pls_integer,
	retcode			OUT	NOCOPY pls_integer,
	retmsg			OUT	NOCOPY varchar2
	);

PROCEDURE resend
	(
	i_msgid     IN      RAW,
	retcode     OUT     NOCOPY PLS_INTEGER,
	errmsg      OUT     NOCOPY VARCHAR2,
        i_flag      IN      varchar2 default null
	);
/* Added new procedure for bug #2215677*/
procedure getConfirmationStatus
(
        i_transaction_type      IN     VARCHAR2,
        i_transaction_subtype   IN     VARCHAR2,
	i_party_id	        IN     varchar2,
	i_party_site_id	        IN     varchar2,
        i_party_type            IN     varchar2 default null,
	o_confirmation	        OUT    NOCOPY number
);


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
		            );

end ecx_document;

 

/
