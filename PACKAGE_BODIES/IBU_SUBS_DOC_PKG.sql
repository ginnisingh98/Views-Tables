--------------------------------------------------------
--  DDL for Package Body IBU_SUBS_DOC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBU_SUBS_DOC_PKG" as
/* $Header: ibusubdb.pls 115.1 2003/09/18 23:30:09 mukhan noship $ */

	PROCEDURE set_msg_body_token (document_id in varchar2,
							display_type in varchar2,
							document in out nocopy varchar2,
							document_type in out nocopy varchar2)
	IS
	BEGIN
		document := document_id;
	end;

end IBU_SUBS_DOC_PKG;

/
