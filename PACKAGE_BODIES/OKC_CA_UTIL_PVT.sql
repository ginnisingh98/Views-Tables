--------------------------------------------------------
--  DDL for Package Body OKC_CA_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CA_UTIL_PVT" as
/* $Header: OKCCAUTLB.pls 120.7 2006/04/26 15:53 muteshev noship $ */

   function bsa_subtype(  p_order_number in number)
      return oe_transaction_types_tl.name%type
   as
      result oe_transaction_types_tl.name%type;
   begin
      select t.name into result
      from
         oe_blanket_headers_all h,
         oe_transaction_types_all a,
         oe_transaction_types_tl t
      where t.transaction_type_id = h.order_type_id
      and a.transaction_type_id = t.transaction_type_id
      and t.language = USERENV('LANG')
      and a.sales_document_type_code = 'B'
      and h.order_number = p_order_number;
      return result;
   exception when others then return null;
   end;

   function so_subtype(  p_order_number in number)
      return oe_transaction_types_tl.name%type
   as
      result oe_transaction_types_tl.name%type;
   begin
      select t.name into result
      from
         oe_order_headers_all h,
         oe_transaction_types_all a,
         oe_transaction_types_tl t
      where t.transaction_type_id = h.order_type_id
      and a.transaction_type_id = t.transaction_type_id
      and t.language = USERENV('LANG')
      and a.sales_document_type_code = 'O'
      and h.order_number = p_order_number;
      return result;
   exception when others then return null;
   end;

   function article_title( p_article_version_id in number)
      return okc_articles_all.article_title%type
   as
      result okc_articles_all.article_title%type;
   begin
      select article_title into result
      from okc_articles_all a, okc_article_versions v
      where a.article_id = v.article_id
      and article_version_id = p_article_version_id;
      return result;
   exception when others then return null;
   end;

   function display_name( p_article_version_id in number)
      return okc_articles_all.article_title%type
   as
      result okc_articles_all.article_title%type;
   begin
      select nvl(display_name, article_title) into result
      from okc_articles_all a, okc_article_versions v
      where a.article_id = v.article_id
      and article_version_id = p_article_version_id;
      return result;
   exception when others then return null;
   end;

   function article_version_number( p_article_version_id in number)
      return okc_article_versions.article_version_number%type
   as
      result okc_article_versions.article_version_number%type;
   begin
      select article_version_number into result
      from okc_articles_all a, okc_article_versions v
      where a.article_id = v.article_id
      and article_version_id = p_article_version_id;
      return result;
   exception when others then return null;
   end;

   function article_id(  p_article_version_id in number)
      return okc_article_versions.article_id%type
   as
      result okc_article_versions.article_id%type;
   begin
      select article_id into result
      from okc_article_versions
      where article_version_id = p_article_version_id;
      return result;
   exception when others then return null;
   end;

   function org_id(  p_article_version_id in number)
      return okc_articles_all.org_id%type
   as
      result okc_articles_all.org_id%type;
   begin
      select org_id into result
      from okc_articles_all a, okc_article_versions v
      where a.article_id = v.article_id
      and article_version_id = p_article_version_id;
      return result;
   exception when others then return null;
   end;

   function latest_article_version_id( p_article_version_id in number,
                                       p_org_id in number)
      return okc_article_versions.article_version_id%type
   as
      result okc_article_versions.article_version_id%type;
      l_article_id okc_articles_all.article_id%type;
      l_org_id okc_articles_all.org_id%type;
   begin
      begin
         select a.article_id, org_id into l_article_id, l_org_id
         from okc_articles_all a, okc_article_versions v
         where a.article_id = v.article_id
         and article_version_id = p_article_version_id;
      exception when others then return null;
      end;
      if p_org_id = l_org_id then
         begin
            select article_version_id into result
            from okc_article_versions
            where article_id = l_article_id
            and article_status in ('APPROVED','ON_HOLD')
            and (start_date, article_version_number) = (
               select
                  max(start_date),
                  max(article_version_number)
               from
                  okc_article_versions
               where article_id = l_article_id
               and article_status in ('APPROVED','ON_HOLD')
            );
         exception when others then return null;
         end;
      else
         begin
            select article_version_id into result
            from okc_article_versions
            where article_id = l_article_id
            and global_yn = 'Y'
            and article_status in ('APPROVED','ON_HOLD')
            and (start_date, article_version_number) = (
               select
                  max(start_date),
                  max(article_version_number)
               from
                  okc_article_versions
               where article_id = l_article_id
               and article_status in ('APPROVED','ON_HOLD')
               and exists (
                  select 1 from okc_article_adoptions
                  where global_article_version_id = article_version_id
                  and local_org_id = p_org_id
                  and adoption_type = 'ADOPTED'
                  and adoption_status = 'APPROVED'
               )
            );
         exception when others then return null;
         end;
      end if;
      return result;
   exception when others then return null;
   end;

   function doc_type(   p_code in varchar2)
      return okc_bus_doc_types_tl.name%type
   as
      result okc_bus_doc_types_tl.name%type;
   begin
      select name into result
      from okc_bus_doc_types_tl
      where document_type = p_code
      and language = userenv('LANG');
      return result;
   exception when others then return null;
   end;

   function neg_supplier(  p_auction_header_id in number)
      return hz_parties.party_name%type
   as
      result hz_parties.party_name%type;
   begin
      select   party_name into result
      from  hz_parties p,
            pon_bid_headers b
      where trading_partner_id = party_id
      and   bid_status IN ('ACTIVE','DISQUALIFIED')
      and   auction_header_id = p_auction_header_id;
      return result;
   exception when TOO_MANY_ROWS then
      return fnd_message.get_string('OKC','OKC_REP_MULTIPLE_PARTIES');
   end;

   procedure remove_results( p_search_id in number) as
   begin
      delete okc_ca_documents_gt
      where srch_id = p_search_id;
   exception when others then null;
   end;

   procedure remove_included( p_search_id in number) as
   begin
      delete okc_ca_art_versions_gt
      where article_srch_id = p_search_id
      and article_flag = 'S';
   exception when others then null;
   end;

   procedure include_alternates( p_search_id in number,
                                 p_alternates in varchar2
                                 ) as
   begin
      if p_alternates = 'Y' THEN
         merge into okc_ca_art_versions_gt gt
         using (
            select
               article_srch_id,
               art.article_id,
               article_version_id,
               art.org_id,
               article_title,
               article_type,
               article_version_number,
               decode(global_yn, 'Y', 'GLOBAL', nvl(v.adoption_type, 'LOCAL')) adoption_type,
               org_name
            from
               okc_articles_all art,
               okc_article_versions v,
               (  select
                     orgu.organization_id org_id,
                     orgu.name org_name
                  from
                     hr_organization_information orgi,
                     hr_operating_units orgu
                  where orgi.org_information_context = 'OKC_TERMS_LIBRARY_DETAILS'
                  and   orgi.organization_id = orgu.organization_id
               ) org,
               (  select
                     target_article_id,
                     org_id,
                     article_srch_id
                  from
                     okc_article_relatns_all,
                     okc_ca_art_versions_gt
                  where source_article_id = article_id
                  and   org_id = article_org_id
                  and   article_srch_id = p_search_id
                  and   article_flag = 'U'
               ) r
            where art.article_id = v.article_id
            and   art.article_id = r.target_article_id
            and   art.org_id = r.org_id
            and   article_status in ('APPROVED','ON_HOLD')
            and   (start_date, article_version_number) = (
               select
                  max(start_date),
                  max(article_version_number)
               from
                  okc_article_versions
               where article_id = art.article_id
               and   article_status in ('APPROVED','ON_HOLD')
               )
            and org.org_id = art.org_id
            union all
            select
               article_srch_id,
               v.article_id,
               v.article_version_id,
               a.local_org_id,
               article_title,
               article_type,
               article_version_number,
               'ADOPTED' adoption_type,
               org_name
            from
               okc_articles_all art,
               okc_article_adoptions a,
               okc_article_versions v,
               (  select
                     orgu.organization_id org_id,
                     orgu.name org_name
                  from
                     hr_organization_information orgi,
                     hr_operating_units orgu
                  where orgi.org_information_context = 'OKC_TERMS_LIBRARY_DETAILS'
                  and   orgi.organization_id = orgu.organization_id
               ) org,
               (  select
                     target_article_id,
                     org_id,
                     article_srch_id
                  from
                     okc_article_relatns_all,
                     okc_ca_art_versions_gt
                  where source_article_id = article_id
                  and   org_id = article_org_id
                  and   article_srch_id = p_search_id
                  and   article_flag = 'U'
               ) r
            where art.article_id = v.article_id
            and   a.global_article_version_id = v.article_version_id
            and   v.article_id = r.target_article_id
            and   a.local_org_id = r.org_id
            and   article_status in ('APPROVED','ON_HOLD')
            and   a.adoption_type = 'ADOPTED'
            and   adoption_status = 'APPROVED'
            and   global_yn = 'Y'
            and   (start_date, article_version_number) = (
               select
                  max(start_date),
                  max(article_version_number)
               from
                  okc_article_versions v1,
                  okc_article_adoptions a1
               where global_yn = 'Y'
               and v1.article_version_id = a1.global_article_version_id
               and v1.article_status in ('APPROVED','ON_HOLD')
               and a1.adoption_type = 'ADOPTED'
               and a1.adoption_status = 'APPROVED'
               and a1.local_org_id = r.org_id
               and v1.article_id = v.article_id)
            and org.org_id = r.org_id
            ) alt
            ON (
               gt.article_srch_id = alt.article_srch_id
               and gt.article_id = alt.article_id
               and gt.article_version_id = alt.article_version_id
               and gt.article_org_id = alt.org_id
            )
            when matched then
            update set  gt.object_version_number = gt.object_version_number+1
            when not matched then
            insert (
               gt.article_srch_id,
               gt.article_id,
               gt.article_version_id,
               gt.article_org_id,
               gt.article_flag,
               gt.article_title,
               gt.article_type,
               gt.article_standard_yn,
               gt.article_version_number,
               gt.article_adoption_type,
               gt.article_org_name,
               gt.std_article_title,
               gt.std_article_version_number,
               gt.object_version_number)
            values (
               alt.article_srch_id,
               alt.article_id,
               alt.article_version_id,
               alt.org_id,
               'S',
               alt.article_title,
               alt.article_type,
               'Y',
               alt.article_version_number,
               alt.adoption_type,
               alt.org_name,
               null,null,1);
      end if;
   exception when others then null;
   end;

   procedure include_adoptions(  p_search_id in number,
                                 p_adoptions in varchar2
                                 ) as
   begin
      if p_adoptions = 'Y' THEN
         merge into okc_ca_art_versions_gt gt
         using (
            select
               article_srch_id,
               article_id,
               article_version_id,
               a.local_org_id,
               article_title,
               article_type,
               article_version_number,
               'ADOPTED' adoption_type,
               org_name
            from
               okc_article_adoptions a,
               okc_ca_art_versions_gt t,
               (  select
                     orgu.organization_id org_id,
                     orgu.name org_name
                  from
                     hr_organization_information orgi,
                     hr_operating_units orgu
                  where orgi.org_information_context = 'OKC_TERMS_LIBRARY_DETAILS'
                  and   orgi.organization_id = orgu.organization_id
               ) org
            where article_srch_id = p_search_id
--            and   article_flag = 'U'
            and   global_article_version_id = article_version_id
            and   article_adoption_type = 'GLOBAL'
            and   a.adoption_type = 'ADOPTED'
            and   a.adoption_status = 'APPROVED'
            and   article_standard_yn = 'Y'
            and   org.org_id = a.local_org_id
         ) ado
         on (
            gt.article_srch_id = ado.article_srch_id
            and gt.article_id = ado.article_id
            and gt.article_version_id = ado.article_version_id
            and gt.article_org_id = ado.local_org_id
         )
         when matched then
            update set gt.object_version_number = gt.object_version_number+1
         when not matched then
            insert (
               gt.article_srch_id,
               gt.article_id,
               gt.article_version_id,
               gt.article_org_id,
               gt.article_flag,
               gt.article_title,
               gt.article_type,
               gt.article_standard_yn,
               gt.article_version_number,
               gt.article_adoption_type,
               gt.article_org_name,
               gt.std_article_title,
               gt.std_article_version_number,
               gt.object_version_number)
            values (
               ado.article_srch_id,
               ado.article_id,
               ado.article_version_id,
               ado.local_org_id,
               'S',
               ado.article_title,
               ado.article_type,
               'Y',
               ado.article_version_number,
               ado.adoption_type,
               ado.org_name,
               null,null,1);
      end if;
   exception when others then null;
   end;

   procedure include_all_versions(  p_search_id in number,
                                    p_all_versions in varchar2
                                    ) as
   begin
      if p_all_versions = 'Y' THEN
         merge into okc_ca_art_versions_gt gt
         using (
         select
            article_srch_id,
            t.article_id,
            a.article_version_id,
            t.article_org_id,
            t.article_title,
            t.article_type,
            a.article_version_number,
            article_adoption_type,
            org_name
         from
            okc_article_versions a,
            okc_ca_art_versions_gt t,
            (  select
                  orgu.organization_id org_id,
                  orgu.name org_name
               from
                  hr_organization_information orgi,
                  hr_operating_units orgu
               where orgi.org_information_context = 'OKC_TERMS_LIBRARY_DETAILS'
               and   orgi.organization_id = orgu.organization_id
            ) org
         where t.article_srch_id = p_search_id
         and a.article_id = t.article_id
         and article_adoption_type in ('LOCAL','GLOBAL','LOCALIZED')
         and article_status in ('APPROVED','ON_HOLD')
         and org.org_id = article_org_id
         union all
         select
            article_srch_id,
            t.article_id,
            a.article_version_id,
            t.article_org_id,
            t.article_title,
            t.article_type,
            a.article_version_number,
            'ADOPTED' adoption_type,
            org_name
         from
            okc_article_versions a,
            okc_ca_art_versions_gt t,
            (  select
                  orgu.organization_id org_id,
                  orgu.name org_name
               from
                  hr_organization_information orgi,
                  hr_operating_units orgu
               where orgi.org_information_context = 'OKC_TERMS_LIBRARY_DETAILS'
               and   orgi.organization_id = orgu.organization_id
            ) org
         where t.article_srch_id = p_search_id
         and a.article_id = t.article_id
         and t.article_adoption_type = 'ADOPTED'
         and exists (
               select 1
               from okc_article_adoptions
               where local_org_id = t.article_org_id
               and global_article_version_id = a.article_version_id
               and adoption_type = 'ADOPTED'
               and adoption_status = 'APPROVED'
            )
            and org.org_id = article_org_id
         ) ver
         on (
            gt.article_srch_id = ver.article_srch_id
            and gt.article_id = ver.article_id
            and gt.article_version_id = ver.article_version_id
            and gt.article_org_id = ver.article_org_id
         )
         when matched then
            update set gt.object_version_number = gt.object_version_number+1
         when not matched then
            insert (
               gt.article_srch_id,
               gt.article_id,
               gt.article_version_id,
               gt.article_org_id,
               gt.article_flag,
               gt.article_title,
               gt.article_type,
               gt.article_standard_yn,
               gt.article_version_number,
               gt.article_adoption_type,
               gt.article_org_name,
               gt.std_article_title,
               gt.std_article_version_number,
               gt.object_version_number)
            values (
               ver.article_srch_id,
               ver.article_id,
               ver.article_version_id,
               ver.article_org_id,
               'S',
               ver.article_title,
               ver.article_type,
               'Y',
               ver.article_version_number,
               ver.article_adoption_type,
               ver.org_name,
               null,null,1);
      end if;
   exception when others then null;
   end;

   procedure include_non_standard(  p_search_id in number,
                                    p_non_standard in varchar2
                                    ) as
   begin
      if p_non_standard in ( 'A', 'N' ) then
         merge into okc_ca_art_versions_gt gt
         using (
            select
               article_srch_id,
               a.article_id,
               v.article_version_id,
               a.org_id,
               a.article_title,
               a.article_type,
               v.article_version_number,
               'NON-STANDARD' adoption_type,
               org_name,
               t.article_title std_article_title,
               t.article_version_number std_article_version_number
            from
               okc_articles_all a,
               okc_article_versions v,
               okc_ca_art_versions_gt t,
               (  select
                     orgu.organization_id org_id,
                     orgu.name org_name
                  from
                     hr_organization_information orgi,
                     hr_operating_units orgu
                  where orgi.org_information_context = 'OKC_TERMS_LIBRARY_DETAILS'
                  and   orgi.organization_id = orgu.organization_id
               ) org
            where a.article_id = v.article_id
            and standard_yn = 'N'
            and article_srch_id = p_search_id
            and t.article_version_id = std_article_version_id
            and t.article_org_id = org.org_id
            and t.article_org_id = a.org_id
            ) non
            on (
               gt.article_srch_id = non.article_srch_id
               and gt.article_id = non.article_id
               and gt.article_version_id = non.article_version_id
               and gt.article_org_id = non.org_id
               and gt.article_standard_yn = 'N'
            )
            when matched then
               update set gt.object_version_number = gt.object_version_number+1
            when not matched then
               insert (
                  gt.article_srch_id,
                  gt.article_id,
                  gt.article_version_id,
                  gt.article_org_id,
                  gt.article_flag,
                  gt.article_title,
                  gt.article_type,
                  gt.article_standard_yn,
                  gt.article_version_number,
                  gt.article_adoption_type,
                  gt.article_org_name,
                  gt.std_article_title,
                  gt.std_article_version_number,
                  gt.object_version_number)
               values (
                  non.article_srch_id,
                  non.article_id,
                  non.article_version_id,
                  non.org_id,
                  'S',
                  non.article_title,
                  non.article_type,
                  'N',
                  non.article_version_number,
                  null,
--                  non.adoption_type,
                  non.org_name,
                  non.std_article_title,
                  non.std_article_version_number,
                  1);
      end if;
   exception when others then null;
   end;

   procedure include_articles(   p_search_id in number,
                                 p_alternates in varchar2,
                                 p_adoptions in varchar2,
                                 p_all_versions in varchar2,
                                 p_non_standard in varchar2
                                 ) as
   begin
      remove_included(p_search_id);
      include_alternates(p_search_id, p_alternates);
      include_all_versions(p_search_id, p_all_versions);
      include_adoptions(p_search_id, p_adoptions);
      include_non_standard(p_search_id, p_non_standard);
   exception when others then null;
   end;

   function article_number(  p_article_id in number)
      return okc_articles_all.article_number%type
   as
      result okc_articles_all.article_number%type;
   begin
      select nvl(art.article_number, decode(std_article_version_id, null, art.article_number,
         (select
            a1.article_number
         from
            okc_articles_all a,
            okc_article_versions v,
            okc_article_versions v1,
            okc_articles_all a1
         where
            a.article_id = v.article_id
            and v.std_article_version_id = v1.article_version_id
            and v1.article_id = a1.article_id
            and a.article_id = art.article_id)
      )) article_number into result
      from okc_articles_all art,
         okc_article_versions ver
      where art.article_id = ver.article_id
      and art.article_id = p_article_id
      and rownum <= 1;
      return result;
   exception when others then return null;
   end;

end;

/
