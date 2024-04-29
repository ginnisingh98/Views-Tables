--------------------------------------------------------
--  DDL for Package IBU_SUBS_DOC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBU_SUBS_DOC_PKG" AUTHID CURRENT_USER as
/* $Header: ibusubds.pls 115.1 2003/09/18 23:28:57 mukhan noship $ */

        procedure set_msg_body_token(
					document_id in varchar2,
					display_type in varchar2,
					document in out nocopy varchar2,
					document_type in out nocopy varchar2);

end IBU_SUBS_DOC_PKG ;

 

/
