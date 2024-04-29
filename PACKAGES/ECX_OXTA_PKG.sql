--------------------------------------------------------
--  DDL for Package ECX_OXTA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECX_OXTA_PKG" AUTHID CURRENT_USER as
/* $Header: ECXOXTAS.pls 120.3 2005/07/29 11:21:14 susaha ship $ */

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
     p_protocol_type       out nocopy varchar2,
     p_protocol_address	   out nocopy varchar2,
     p_username		   out nocopy varchar2,
     p_password		   out nocopy varchar2,
     p_attribute1           out nocopy varchar2,
     p_attribute2           out nocopy varchar2,
     p_attribute3          out nocopy varchar2,
     p_attribute4	  out nocopy varchar2,
     p_attribute5	  out nocopy varchar2,
     p_payload		   out nocopy clob,
     p_msgid               out nocopy raw,
     p_org_msgid           out nocopy varchar2
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
     p_msgid               out nocopy raw
);

end ECX_OXTA_PKG;

 

/
