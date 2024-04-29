--------------------------------------------------------
--  DDL for Package Body AMS_LIST_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LIST_UTIL_PKG" as
/* $Header: amsvlutb.pls 115.7 2002/11/22 19:49:58 jieli ship $ */
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE  get_supp_sql_string(
p_object_type in VARCHAR2,
p_object_id   in NUMBER,
x_where_clause OUT NOCOPY VARCHAR2,
x_status OUT NOCOPY VARCHAR2
) is
  l_rule_id        NUMBER;
  l_list_header_id NUMBER;
  l_media_id       NUMBER;
  l_campaign_id    NUMBER;
  l_string         VARCHAR2(4000);
  i                NUMBER := 0;
  l_col_string     VARCHAR2(2000);
  l_column         VARCHAR2(60);
  l_return_status  VARCHAR2(1);



  cursor c_get_camp_id is
  select  ac.campaign_id
    from ams_campaign_schedules_vl ac
   where ac.schedule_id = p_object_id;

  cursor c_get_list(cur_campaign_id number) is
         SELECT acr.list_header_id
           FROM ams_list_cont_restrictions acr , ams_list_headers_all alh
          WHERE acr.list_header_id  =  alh.list_header_id
            and alh.status_code not in ('DRAFT','CANCELLED','ARCHIVED')
            and alh.list_type = 'SUPPRESSION'
            and (   acr.do_not_contact_flag = 'Y'
                 or acr.list_used_by_id = cur_campaign_id
                 or acr.media_id = 20
                 ) ;


begin
  open c_get_camp_id ;
  fetch c_get_camp_id into l_campaign_id;
  close c_get_camp_id ;

     i := 0;
     open  c_get_list(l_campaign_id);
     loop
        fetch c_get_list into l_list_header_id ;
        exit when c_get_list%notfound;
        if i = 0 then
           l_string := l_string|| 'ale_01.list_header_id in ( ';
           l_string := l_string|| l_list_header_id   ;
        else
           l_string := l_string|| ','|| l_list_header_id;
        end if;
        i := 1;
     end loop;
     close  c_get_list;
     if i = 1 then
           l_string := l_string|| ')';
           x_where_clause  := 'select ale_01.party_id ' ||
                              'from  ams_list_entries ale_01 '||
                              'where ' || l_string ;
           x_status := FND_API.G_RET_STS_SUCCESS ;
     else
         x_where_clause := '';
         x_status := FND_API.G_RET_STS_ERROR ;
     end if;



exception
     when others then
         x_where_clause := '';
         x_status := FND_API.G_RET_STS_ERROR ;
end;

PROCEDURE get_supp_sql_string(
                      p_list_header_id in NUMBER,
                      p_table_alias in varchar2,
                      p_object_type in varchar2 ,--default null,
                      p_object_id in number ,--default null,
                      p_media_type in number ,--default 'EMAIL',
                      p_where_clause  OUT NOCOPY varchar2
                     ) IS

  l_rule_id        NUMBER;
  l_list_header_id NUMBER;
  l_media_id       NUMBER;
  l_campaign_id    NUMBER;
  l_string         VARCHAR2(4000);
  i                NUMBER := 0;
  l_col_string     VARCHAR2(2000);
  l_column         VARCHAR2(60);
  l_return_status  VARCHAR2(1);



  cursor c_get_rule_id is
  select am.dedupe_rule_id, ac.campaign_id, am.media_id
    from ams_campaign_schedules_vl ac, ams_media_vl am
   where ac.activity_id = am.media_id
   and am.dedupe_rule_id is not null
   and ac.schedule_id = p_object_id;

  cursor c_get_list(cur_campaign_id number, cur_media_id number) is
         SELECT acr.list_header_id
           FROM ams_list_cont_restrictions acr , ams_list_headers_all alh
          WHERE acr.list_header_id  =  alh.list_header_id
            and alh.status_code not in ('DRAFT','CANCELLED','ARCHIVED')
            and alh.list_type = 'SUPPRESSION'
            and (   acr.do_not_contact_flag = 'Y'
                 or acr.list_used_by_id = cur_campaign_id
                 or acr.media_id = cur_media_id) ;

  cursor c_rule_field(cur_rule_id number) is
         SELECT field_column_name
           FROM ams_list_rule_fields
          WHERE list_rule_id =  cur_rule_id;

begin
  open c_get_rule_id ;
  fetch c_get_rule_id into l_rule_id, l_campaign_id, l_media_id;
  close c_get_rule_id ;

  if l_rule_id is not null then
     l_string := ' and not exists ( select '||''''|| 'x'||'''';
     l_string := l_string||'  from ams_list_entries where ' ;

     i := 0;
     open c_rule_field(l_rule_id);
     LOOP
        fetch c_rule_field into l_column;
        exit when c_rule_field%notfound;
        if i = 0 then
           l_string := l_string|| 'ams_list_entries.'||l_column || ' = ';
           l_string := l_string|| p_table_alias||'.'||l_column  || ' ';
        else
           l_string := l_string|| ' and ams_list_entries.'||l_column || ' = ';
           l_string := l_string|| p_table_alias||'.'||l_column  || ' ';
        end if;
        i := 1;
     END LOOP;
     close c_rule_field;
     l_string := l_string||'' ;


     i := 0;
     open  c_get_list(l_campaign_id, l_media_id );
     loop
        fetch c_get_list into l_list_header_id ;
        exit when c_get_list%notfound;
        if i = 0 then
           l_string := l_string|| 'ams_list_entries.list_header_id in ( ';
           l_string := l_string|| l_list_header_id   ;
        else
           l_string := l_string|| ','|| l_list_header_id;
        end if;
        i := 1;
     end loop;
     close  c_get_list;
 end if ;
     if i = 1 then
           l_string := l_string|| ')';
     else
         l_string := ' and 1 = 1';
     end if;

 p_where_clause  := l_string;

  exception
     when others then
     null;
end get_supp_sql_string;
END AMS_LIST_UTIL_PKG ;

/
