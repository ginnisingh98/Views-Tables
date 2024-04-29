--------------------------------------------------------
--  DDL for Package OKC_ARTICLE_KEYWORD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_ARTICLE_KEYWORD_PVT" AUTHID CURRENT_USER as
-- $Header: OKCVAKWS.pls 120.2.12010000.3 2011/07/05 13:09:51 harchand ship $

procedure sync;
procedure optimize;
function article_title(p_article_version_id in number) return varchar2;

procedure sync_ctx(errbuf out nocopy varchar2, retcode out nocopy varchar2);
procedure optimize_ctx(errbuf out nocopy varchar2, retcode out nocopy varchar2);

procedure create_ctx(errbuf out nocopy varchar2, retcode out nocopy varchar2,p_index_parallel NUMBER DEFAULT -1);
procedure crt;

end;

/

  GRANT EXECUTE ON "APPS"."OKC_ARTICLE_KEYWORD_PVT" TO "OKC";
