--------------------------------------------------------
--  DDL for Package ECX_ENG_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECX_ENG_UTILS" AUTHID CURRENT_USER as
-- $Header: ECXENUTS.pls 120.3 2005/10/30 23:37:23 susaha ship $
PWD_SPEC_CODE	CONSTANT	VARCHAR(50) := '#WF_DECRYPT#';

g_server_tz	varchar2(2000);
procedure convert_to_cxml_date (p_ora_date	in	date,
				x_cxml_date	out	NOCOPY varchar2
			       );
procedure convert_to_cXML_datetime (p_ora_date	in	date,
				    x_cxml_date	out	NOCOPY varchar2
				   );
procedure convert_from_cXML_datetime (p_cxml_date   in      varchar2,
                                      x_ora_date    out     NOCOPY date
                                     );

procedure generate_cXML_payloadID (p_document_number  in     varchar2,
                                   x_payload_id       out   NOCOPY varchar2);

procedure get_tp_pwd (
                     x_password         OUT NOCOPY Varchar2
                     );

procedure convertEncryCodeClob(
                               p_clob      IN           CLOB,
                               x_clob      OUT  NOCOPY  CLOB
                               );

end ecx_eng_utils;

 

/
