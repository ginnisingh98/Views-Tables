--------------------------------------------------------
--  DDL for Package ECX_INBOUND_TRIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECX_INBOUND_TRIG" AUTHID CURRENT_USER as
-- $Header: ECXINBTS.pls 120.1.12000000.1 2007/01/16 06:11:12 appldev ship $

procedure getmsg_from_queue
	(
	i_queue_name    IN            varchar2,
	i_msgid         OUT  NOCOPY   RAW
	);

procedure processmsg_from_queue
	(
	i_queue_name            IN      varchar2,
	i_debug_level           IN      pls_integer
	);

procedure processmsg_from_table
	(
	i_msgid                 IN      RAW,
	i_debug_level           IN      pls_integer
	);

/** Old put_on_outbound**/
procedure put_on_outbound
        (
	i_xmldoc		IN OUT NOCOPY CLOB,
        i_document_number       IN            varchar2,
        i_tp_detail_id          IN            pls_integer
        );

procedure put_on_outbound
	(
	i_xmldoc		IN OUT	NOCOPY CLOB,
	i_document_number	IN	       varchar2,
	i_tp_detail_id		IN	       pls_integer,
        i_msgid                 IN             raw
	);

procedure wrap_validate_message
        (
        i_msgid                 IN         RAW,
        i_debug_level           IN         pls_integer,
        i_trigger_id            OUT NOCOPY pls_integer
        );

/** New wrap_validate_message - with BES **/
procedure wrap_validate_message
        (
        i_msgid                 IN      RAW,
        i_debug_level           IN      pls_integer
        );

procedure validate_message
        (
        m_msgid                 IN      raw,
        m_message_standard      IN      varchar2,
        m_ext_type              in      varchar2,
        m_ext_subtype           in      varchar2,
        m_party_ext_code        IN      varchar2,
        m_document_number       IN      varchar2,
        m_routing_ext_code      IN      varchar2,
        m_payload               IN      clob,
        m_message_type          IN      varchar2
        );

procedure processXML
	(
	i_map_code              IN      varchar2,
	i_payload		IN	CLOB,
	i_debug_level           IN      pls_integer,
	i_ret_code		OUT NOCOPY pls_integer,
	i_errbuf		OUT NOCOPY varchar2,
	i_log_file		OUT NOCOPY varchar2,
	o_payload		OUT NOCOPY CLOB,
        i_message_standard      IN         varchar2 default 'OAG',
        i_message_type          IN         varchar2 default 'XML'
	);

procedure reprocess
       (
        i_msgid                 IN         RAW,
        i_debug_level           IN         pls_integer,
        i_trigger_id            OUT NOCOPY number,
        i_retcode               OUT NOCOPY pls_integer,
        i_errbuf                OUT NOCOPY varchar2
       );


end ecx_inbound_trig;

 

/
