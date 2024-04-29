--------------------------------------------------------
--  DDL for Package OXTA_ECX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OXTA_ECX_PKG" AUTHID CURRENT_USER as
/* $Header: ECXOXTAS.pls 115.3 2001/12/11 10:12:46 pkm ship        $ */

procedure oxta_dequeue
(
     p_queue_name          in varchar2,
     p_message_type        out varchar2,
     p_message_standard	   out varchar2,
     p_transaction_type    out varchar2,
     p_transaction_subtype out varchar2,
     p_document_number     out varchar2,
     p_partyid             out varchar2,
     p_party_site_id       out varchar2,
     p_party_type          out varchar2,
     p_protocol_type		   out varchar2,
     p_protocol_address		 out varchar2,
     p_username		         out varchar2,
     p_password		         out varchar2,
     p_attribute1		       out varchar2,
     p_attribute2		       out varchar2,
     p_attribute3		       out varchar2,
     p_attribute4		       out varchar2,
     p_attribute5		       out varchar2,
     p_payload		         out clob,
     p_msgid               out raw,
     p_org_msgid           out varchar2
);

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
     p_msgid               out raw
);

end OXTA_ECX_PKG;

 

/
