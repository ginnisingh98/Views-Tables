--------------------------------------------------------
--  DDL for Package OKC_TEMPLATE_KEYWORD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_TEMPLATE_KEYWORD_PVT" AUTHID CURRENT_USER as
-- $Header: OKCVTKWS.pls 120.1 2005/09/14 16:09:31 muteshev noship $

procedure sync;
procedure optimize;
procedure sync_ctx(errbuf out nocopy varchar2, retcode out nocopy varchar2);
procedure optimize_ctx(errbuf out nocopy varchar2, retcode out nocopy varchar2);

end;

 

/
