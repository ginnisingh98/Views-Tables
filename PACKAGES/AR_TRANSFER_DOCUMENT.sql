--------------------------------------------------------
--  DDL for Package AR_TRANSFER_DOCUMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_TRANSFER_DOCUMENT" AUTHID CURRENT_USER as
/*$Header: ARTRSDCS.pls 115.2 2002/11/15 03:58:27 anukumar noship $ */

  procedure transfer_documents(errbuf    out NOCOPY varchar2,
                               retcode   out NOCOPY varchar2);

  procedure build_batch_error_message(	document_id	in	varchar2,
					display_type	in	varchar2,
					document	in out NOCOPY	varchar2,
					document_type	in out NOCOPY	varchar2);

  procedure build_batch_error_message_clob(document_id		in	varchar2,
					   display_type		in	varchar2,
					   document	  	in out NOCOPY	CLOB,
					   document_type	in out NOCOPY	varchar2);
end;

 

/
