--------------------------------------------------------
--  DDL for Package ECX_OUTBOUND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECX_OUTBOUND" AUTHID CURRENT_USER as
-- $Header: ECXOUBXS.pls 120.1.12000000.1 2007/01/16 06:11:47 appldev ship $

/**
Main procedure call for Processing Outbound Documents.
**/
procedure process_outbound_documents
        (
	i_message_standard      IN      VARCHAR2,
	i_transaction_type      IN      VARCHAR2,
	i_transaction_subtype   IN      VARCHAR2,
	i_tp_id			IN	VARCHAR2,
	i_tp_site_id		IN	VARCHAR2,
	i_tp_type		IN	VARCHAR2,
	i_document_id		IN	VARCHAR2,
        i_map_code              IN      VARCHAR2,
	i_xmldoc		IN OUT  NOCOPY CLOB,
	i_message_type          IN      VARCHAR2 default 'XML'
	);

procedure GETXML
	(
	i_message_standard      IN      VARCHAR2 default null,
	i_transaction_type      IN      VARCHAR2 default null,
	i_transaction_subtype   IN      VARCHAR2 default null,
	i_tp_id			IN	VARCHAR2 default null,
	i_tp_site_id		IN	VARCHAR2 default null,
	i_tp_type		IN	VARCHAR2 default null,
	i_document_id		IN	VARCHAR2 default null,
        i_map_code              IN      VARCHAR2,
	i_debug_level		IN	pls_integer,
	i_xmldoc		IN OUT  NOCOPY CLOB ,
	i_ret_code		OUT	NOCOPY pls_integer,
	i_errbuf		OUT	NOCOPY varchar2,
	i_log_file		OUT	NOCOPY varchar2,
        i_message_type          IN      VARCHAR2 default 'XML'
	);

procedure putmsg
	(
	i_transaction_type      IN      VARCHAR2,
	i_transaction_subtype   IN      VARCHAR2,
	i_party_id              IN      VARCHAR2,
	i_party_site_id         IN      VARCHAR2,
	i_party_type            IN      VARCHAR2,
	i_document_id           IN      VARCHAR2,
	i_map_code              IN      VARCHAR2,
	i_message_type          IN      varchar2,
	i_message_standard      IN      varchar2,
	i_ext_type		in	varchar2,
	i_ext_subtype		in	varchar2,
	i_destination_code      IN      varchar2,
	i_destination_type      IN      varchar2,
	i_destination_address   IN      varchar2,
	i_username		IN	varchar2,
	i_password		IN	varchar2,
	i_attribute1		IN	varchar2,
	i_attribute2		IN	varchar2,
	i_attribute3		IN	varchar2,
	i_attribute4		IN	varchar2,
	i_attribute5		IN	varchar2,
	i_debug_level		IN	pls_integer,
        i_trigger_id            IN      number,
	i_msgid                 OUT     NOCOPY raw
	);

/* Wrapper procedure for backward comaptibilty */
procedure putmsg
	(
	i_transaction_type	IN	varchar2,
	i_transaction_subtype	IN	varchar2,
	i_party_id		IN	varchar2,
	i_party_site_id		IN	varchar2,
	i_party_type		IN	varchar2,
	i_document_id		IN	varchar2,
	i_parameter1		IN	varchar2,
	i_parameter2		IN	varchar2,
	i_parameter3		IN	varchar2,
	i_parameter4		IN	varchar2,
	i_parameter5		IN	varchar2,
	i_map_code		      IN	varchar2,
	i_message_type		IN	varchar2,
	i_message_standard	IN	varchar2,
	i_ext_type		      IN	varchar2,
	i_ext_subtype		IN	varchar2,
	i_destination_code	IN	varchar2,
	i_destination_type	IN	varchar2,
	i_destination_address	IN	varchar2,
	i_username		      IN	varchar2,
	i_password		      IN	varchar2,
	i_attribute1		IN	varchar2,
	i_attribute2		IN	varchar2,
	i_attribute3		IN	varchar2,
	i_attribute4		IN	varchar2,
	i_attribute5		IN	varchar2,
	i_debug_level		IN	pls_integer,
        i_trigger_id          IN    number,
	i_msgid			OUT	NOCOPY raw
	) ;


end ecx_outbound;

 

/
