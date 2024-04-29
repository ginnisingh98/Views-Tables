--------------------------------------------------------
--  DDL for Package OKC_CA_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_CA_UTIL_PVT" AUTHID CURRENT_USER as
/* $Header: OKCCAUTLS.pls 120.4 2006/04/17 16:05:30 muteshev noship $ */

   procedure include_articles(   p_search_id in number,
                                 p_alternates in varchar2,
                                 p_adoptions in varchar2,
                                 p_all_versions in varchar2,
                                 p_non_standard in varchar2
                                 );
   procedure remove_results(  p_search_id in number);
   procedure remove_included( p_search_id in number);
   function article_title(  p_article_version_id in number)
      return okc_articles_all.article_title%type;
   function display_name(  p_article_version_id in number)
      return okc_articles_all.article_title%type;
   function article_version_number(  p_article_version_id in number)
      return okc_article_versions.article_version_number%type;
   function article_id(  p_article_version_id in number)
      return okc_article_versions.article_id%type;
   function org_id(  p_article_version_id in number)
      return okc_articles_all.org_id%type;
   function latest_article_version_id( p_article_version_id in number,
                                       p_org_id in number)
      return okc_article_versions.article_version_id%type;
   function doc_type(   p_code in varchar2)
      return okc_bus_doc_types_tl.name%type;
   function neg_supplier(  p_auction_header_id in number)
      return hz_parties.party_name%type;

   function bsa_subtype(  p_order_number in number)
      return oe_transaction_types_tl.name%type;
   function so_subtype(  p_order_number in number)
      return oe_transaction_types_tl.name%type;

   function article_number(  p_article_id in number)
      return okc_articles_all.article_number%type;

end;

 

/
