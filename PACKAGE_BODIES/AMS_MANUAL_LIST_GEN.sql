--------------------------------------------------------
--  DDL for Package Body AMS_MANUAL_LIST_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_MANUAL_LIST_GEN" AS
/* $Header: amsvlmlb.pls 120.3.12010000.2 2008/08/11 08:52:06 amlal ship $ */

g_list_header_id         ams_list_headers_all.list_header_id%type;
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

AMS_LOG_PROCEDURE constant number := FND_LOG.LEVEL_PROCEDURE;
AMS_LOG_EXCEPTION constant Number := FND_LOG.LEVEL_EXCEPTION;
AMS_LOG_STATEMENT constant Number := FND_LOG.LEVEL_STATEMENT;

AMS_LOG_PROCEDURE_ON boolean := AMS_UTILITY_PVT.logging_enabled(AMS_LOG_PROCEDURE);
AMS_LOG_EXCEPTION_ON boolean := AMS_UTILITY_PVT.logging_enabled(AMS_LOG_EXCEPTION);
AMS_LOG_STATEMENT_ON boolean := AMS_UTILITY_PVT.logging_enabled(AMS_LOG_STATEMENT);

G_module_name constant varchar2(100):='oracle.apps.ams.plsql.'||g_pkg_name;

PROCEDURE WRITE_TO_ACT_LOG(p_msg_data in VARCHAR2,
                           p_arc_log_used_by in VARCHAR2 ,--DEFAULT 'LIST',
                           p_log_used_by_id in number )--DEFAULT g_list_header_id)
                           IS
 PRAGMA AUTONOMOUS_TRANSACTION;
 l_return_status VARCHAR2(1);
BEGIN
  AMS_UTILITY_PVT.CREATE_LOG(
                             x_return_status    => l_return_status,
                             p_arc_log_used_by  => 'LIST',
                             p_log_used_by_id   => g_list_header_id,
                             p_msg_data         => p_msg_data);
  COMMIT;
END WRITE_TO_ACT_LOG;

PROCEDURE form_sql_statement(p_list_header_id in number,
                             p_master_type        in varchar2,
                             p_child_types     in child_type,
                             x_final_string OUT NOCOPY varchar2
                             ) is
-- child_type      IS TABLE OF VARCHAR2(80) INDEX  BY BINARY_INTEGER;
l_data_source_types varchar2(2000);
l_field_col_tbl JTF_VARCHAR2_TABLE_100;
l_source_col_tbl JTF_VARCHAR2_TABLE_100;
l_view_tbl JTF_VARCHAR2_TABLE_100;
cursor c_master_source_type is
select source_object_name , source_object_name || '.' || source_object_pk_field
from ams_list_src_types
where source_type_code = p_master_type;
cursor c_child_source_type (l_child_src_type varchar2 )is
select a.source_object_name ,
       a.source_object_name || '.' || b.sub_source_type_pk_column
       ,b.master_source_type_pk_column
from ams_list_src_types  a, ams_list_src_type_assocs b
where a.source_type_code = l_child_src_type
and   b.sub_source_type_id = a.list_source_type_id;
l_count                   number;
l_master_object_name      varchar2(4000);
l_child_object_name       varchar2(4000);
l_master_primary_key      varchar2(1000);
l_child_primary_key       varchar2(32767);
l_from_clause             varchar2(32767);
l_where_clause            varchar2(32767);
l_select_clause           varchar2(32767);
l_insert_clause           varchar2(32767);
l_final_sql               varchar2(32767);
l_insert_sql              varchar2(32767);
l_no_of_chunks            number;
l_master_fkey             Varchar2(30);
l_dummy_primary_key      varchar2(1000);

l_api_name            CONSTANT VARCHAR2(30)  := 'master_source_type_view';
l_full_name           CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

l_created_by                NUMBER;  --batoleti added this var. For bug# 6688996

/* batoleti. Bug# 6688996. Added the below cursor */
    CURSOR cur_get_created_by (x_list_header_id IN NUMBER) IS
      SELECT created_by
      FROM ams_list_headers_all
      WHERE list_header_id= x_list_header_id;


begin
     WRITE_TO_ACT_LOG(' manual list ->p_master_type'
                                   || p_master_type,'LIST',p_list_header_id);

    IF (AMS_LOG_PROCEDURE_ON) THEN
       AMS_UTILITY_PVT.debug_message(AMS_LOG_PROCEDURE,g_module_name||'.'||l_api_name,l_full_name||':Start');
    END IF;

open  c_master_source_type;
fetch c_master_source_type into l_master_object_name , l_master_primary_key;
close c_master_source_type;
     WRITE_TO_ACT_LOG('manual list->' || l_master_object_name,'LIST',p_list_header_id);
l_from_clause :=  ' FROM ' || l_master_object_name;
l_data_source_types := ' ('|| ''''|| p_master_type ||'''';
l_where_clause := 'where 1 = 1 ';

l_count  := p_child_types.count();
if l_count > 0  then
   for i in 1..p_child_types.last
   loop
      l_data_source_types := l_data_source_types || ','|| ''''
                             || p_child_types(i)||'''' ;
      open  c_child_source_type(p_child_types(i));
      fetch c_child_source_type into l_child_object_name ,
                                     l_child_primary_key
                                     ,l_master_fkey;
      if l_master_fkey is not null then
         l_dummy_primary_key := l_master_object_name || '.'|| l_master_fkey;
      else
         l_dummy_primary_key := l_master_primary_key;
      end if;
      l_from_clause := l_from_clause || ','|| l_child_object_name ;
      l_where_clause := l_where_clause || 'and '
                              ||l_dummy_primary_key || ' = '
                        || l_child_primary_key || '(+)';
      close c_child_source_type;
   end loop;
end if;
  WRITE_TO_ACT_LOG('manual->after child'  || l_where_clause,'LIST',p_list_header_id);
l_data_source_types := l_data_source_types || ') ' ;

 EXECUTE IMMEDIATE
     'BEGIN
      SELECT b.field_column_name ,
               c.source_object_name,
               b.source_column_name
        BULK COLLECT INTO :1 ,:2  ,:3
        FROM ams_list_src_fields b, ams_list_src_types c
        WHERE b.list_source_type_id = c.list_source_type_id
          and b.DE_LIST_SOURCE_TYPE_CODE IN  '|| l_data_source_types ||
          ' AND b.ROWID >= (SELECT MAX(a.ROWID)
                            FROM ams_list_src_fields a
                           WHERE a.field_column_name= b.field_column_name
                            AND  a.DE_LIST_SOURCE_TYPE_CODE IN '
                                 || l_data_source_types || ') ;
      END; '
  USING OUT l_field_col_tbl ,OUT l_view_tbl , OUT l_source_col_tbl ;
for i in 1 .. l_field_col_tbl.last
loop
  l_insert_clause  := l_insert_clause || ' ,' || l_field_col_tbl(i) ;
  l_select_clause  := l_select_clause || ' ,' ||
                      l_view_tbl(i) || '.'||l_source_col_tbl(i) ;
  --WRITE_TO_ACT_LOG('imp: select clause'||i||':->' || l_select_clause,'LIST',p_list_header_id);
end loop;
  WRITE_TO_ACT_LOG('manual list:before insert_sql ','LIST',p_list_header_id);

       -- batoleti  coding starts for bug# 6688996
      l_created_by := 0;

       OPEN cur_get_created_by(p_list_header_id);

       FETCH cur_get_created_by INTO l_created_by;
       CLOSE cur_get_created_by;

   -- batoleti  coding ends for bug# 6688996


  l_insert_sql := 'insert into ams_list_entries        '||
                   '( LIST_SELECT_ACTION_FROM_NAME,    '||
                   '  LIST_ENTRY_SOURCE_SYSTEM_ID ,    '||
                   '  LIST_ENTRY_SOURCe_SYSTEM_TYPE,   '||
                   ' list_select_action_id ,           '||
                   ' rank ,                            '||
                   ' list_header_id,last_update_date,  '||
                   ' last_updated_by,creation_date,created_by,'||
                   'list_entry_id, '||
                   'object_version_number, ' ||
                   'source_code                     , ' ||
                   'source_code_for_id              , ' ||
                   'arc_list_used_by_source         , ' ||
                   'arc_list_select_action_from     , ' ||
                   'pin_code                        , ' ||
                   'view_application_id             , ' ||
                   'manually_entered_flag           , ' ||
                   'marked_as_random_flag           , ' ||
                   'marked_as_duplicate_flag        , ' ||
                   'part_of_control_group_flag      , ' ||
                   'exclude_in_triggered_list_flag  , ' ||
                   'enabled_flag ' ||
                   l_insert_clause || ' ) ' ||
                   'select ' ||
                   l_master_primary_key ||','||
                   l_master_primary_key ||','||
                   ''''||p_master_type||''''||','||
                   0 || ',' ||1||','||
                    p_list_header_id || ',' ||''''||
                   to_char(sysdate )|| ''''||','||
                   to_char(FND_GLOBAL.login_id )|| ',' ||''''||
                   to_char(sysdate )|| ''''||','||
                   l_created_by|| ',' ||
                   'ams_list_entries_s.nextval'  || ','||
                   1 || ','||
                   ''''||'NONE'                ||''''     || ','||
                   0                           || ','     ||
                   ''''||'NONE'                ||''''     || ','||
                   ''''||'NONE'                ||''''     || ','||
                   'ams_list_entries_s.currval'|| ','||
                   530              || ','||
                   ''''||'Y'  ||''''|| ','||
                   ''''||'N'  ||''''|| ','||
                   ''''||'N'  ||''''|| ','||
                   ''''||'N'  ||''''|| ','||
                   ''''||'N'  ||''''|| ','||
                   ''''||'Y'  ||''''||
                   l_select_clause ;

/* commented OUT NOCOPY becuase of performance reasons
     l_final_sql := l_insert_sql || '  ' ||
                  l_from_clause ||  '  '||
                  l_where_clause   || ' and  ' ||
                   l_master_primary_key ||
                     '||  '||''''||p_master_type ||''''|| ' = ' ;
*/
  WRITE_TO_ACT_LOG('form_sql_statement:before final sql ','LIST',p_list_header_id);
     l_final_sql := l_insert_sql || '  ' ||
                  l_from_clause ||  '  '||
                  l_where_clause   || ' and  ' ||
                   l_master_primary_key|| ' = ' ;
     x_final_string := l_final_sql;
  --WRITE_TO_ACT_LOG('form_sql_statement:after final sql ','LIST',p_list_header_id);
     l_no_of_chunks  := ceil(length(l_final_sql)/2000 );
     for i in 1 ..l_no_of_chunks
     loop
        WRITE_TO_ACT_LOG(substr(l_final_sql,(2000*i) - 1999,2000),'LIST',p_list_header_id);
     end loop;
   IF (AMS_LOG_PROCEDURE_ON) THEN
     AMS_UTILITY_PVT.debug_message(AMS_LOG_PROCEDURE,g_module_name||'.'||l_api_name,l_full_name||': END ');
   END IF;

exception
 WHEN OTHERS THEN
        WRITE_TO_ACT_LOG('Error : '|| sqlerrm,'LIST',p_list_header_id);
end form_sql_statement;

--- manual entries changes start: musman
PROCEDURE do_bulk_insert
(   p_sql_string IN VARCHAR2
   ,p_list_header_id    in  NUMBER
   ,p_primary_key_tbl   IN  JTF_NUMBER_TABLE--primary_key_Tbl_Type ,
   ,x_added_entry_count OUT NOCOPY NUMBER
   ,x_return_status     OUT NOCOPY VARCHAR2
   ,x_msg_count         OUT NOCOPY NUMBER
   ,x_msg_data          OUT NOCOPY VARCHAR2
   )IS

l_api_name constant varchar2(30) := 'do_bulk_insert';
l_full_name  CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS ;
   IF (AMS_LOG_PROCEDURE_ON) THEN
       AMS_UTILITY_PVT.debug_message(AMS_LOG_PROCEDURE,g_module_name||'.'||l_api_name,l_full_name||':Start');
    END IF;

  IF (AMS_LOG_STATEMENT_ON) THEN
    AMS_UTILITY_PVT.debug_message(
         AMS_LOG_STATEMENT ,g_module_name||'.'||l_api_name
     ,' P_list_header_id :'||p_list_header_id||' ,p_primary_key_tbl count :'||p_primary_key_tbl.count);
  END IF;

  EXECUTE IMMEDIATE
    'BEGIN
         FORALL  i  in :1 .. :2    '
          || '  ' || p_sql_string || ' :tab(i)
          and
         not exists (select 1
                     from  ams_list_entries
                     where list_entry_source_system_id = :tab(i)
                       and list_header_id  = :5 and enabled_flag=''Y'');
      :6 := SQL%ROWCOUNT;
     END; '
   using p_primary_key_tbl.first,
         p_primary_key_tbl.last,
         p_primary_key_tbl,
         p_list_header_id,
	 OUT x_added_entry_count;
  --x_added_entry_count := SQL%ROWCOUNT;
  --WRITE_TO_ACT_LOG('MARZIA ADDED ENTRY SQL%ROWCOUNT' || x_added_entry_count,'LIST',p_list_header_id);

  IF (AMS_LOG_STATEMENT_ON) THEN
    AMS_UTILITY_PVT.debug_message(
         AMS_LOG_STATEMENT      ,g_module_name||'.'||l_api_name
     ,' ADDED ENTRY SQL%ROWCOUNT  :'||x_added_entry_count);
  END IF;

  IF (AMS_LOG_PROCEDURE_ON) THEN
     AMS_UTILITY_PVT.debug_message(AMS_LOG_PROCEDURE,g_module_name||'.'||l_api_name,l_full_name||': END ');
  END IF;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.g_ret_sts_error ;
      FND_MSG_PUB.Count_AND_Get
         ( p_count       =>      x_msg_count,
           p_data        =>      x_msg_data,
           p_encoded    =>      FND_API.G_FALSE
          );
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.g_ret_sts_unexp_error ;
     FND_MSG_PUB.Count_AND_Get
         ( p_count           =>      x_msg_count,
           p_data            =>      x_msg_data,
           p_encoded        =>      FND_API.G_FALSE
          );
 WHEN OTHERS  THEN
        x_return_status := FND_API.g_ret_sts_unexp_erroR ;
       IF (AMS_LOG_PROCEDURE_ON) THEN
        AMS_UTILITY_PVT.debug_message(AMS_LOG_PROCEDURE,g_module_name||'.'||l_api_name,' In Others exception handling ');
      END IF;

      IF (AMS_LOG_EXCEPTION_ON) THEN
        AMS_UTILITY_PVT.debug_message(AMS_LOG_EXCEPTION,g_module_name||'.'||l_api_name,'SQLCODE:' || SQLCODE || ' SQLERRM: ' || SQLERRM);
      END IF;        WRITE_TO_ACT_LOG('Error : '|| sqlerrm,'LIST',p_list_header_id);


     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_AND_Get
       ( p_count           =>      x_msg_count,
         p_data            =>      x_msg_data,
         p_encoded         =>      FND_API.G_FALSE
        );

END do_bulk_insert;
--- manual entries changes start: musman
PROCEDURE process_manual_list(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_list_header_id    in  NUMBER,
   p_primary_key_tbl   IN  JTF_NUMBER_TABLE,--primary_key_Tbl_Type ,
   p_master_type       in  VARCHAR2
   , x_added_entry_count OUT NOCOPY NUMBER --- manual entries changes added: musman
) IS
l_api_name constant varchar2(30) := 'process_manual_list';
l_full_name   CONSTANT VARCHAR2(100) := g_pkg_name ||'.'|| l_api_name;

l_list_header_id number;
l_api_version       CONSTANT NUMBER := 1.0;

l_child_types child_type      ;
cursor c_mapping_types(p_master_type varchar2) is
SELECT list_source_type_id
FROM   ams_list_src_types a
WHERE a.source_type_code = p_master_type
  AND a.master_source_type_flag = 'Y';
cursor c_mapping_subtypes(p_master_type_id
                          ams_list_src_type_assocs.master_source_type_id%type)is
select source_type_code
from   ams_list_src_types a,
       ams_list_src_type_assocs b
where  b.master_source_type_id = p_master_type_id
  and  b.sub_source_type_id  = a.list_source_type_id;

/* bug:4467062 fix:musman
cursor c_count_list_entries(cur_p_list_header_id number) is
select sum(decode(enabled_flag,'N',0,1)),
       sum(decode(enabled_flag,'Y',0,1)),
       sum(1),
       sum(decode(part_of_control_group_flag,'Y',1,0)),
       sum(decode(marked_as_random_flag,'Y',1,0)),
       sum(decode(marked_as_duplicate_flag,'Y',1,0)),
       sum(decode(manually_entered_flag,
                     'Y',decode(enabled_flag,'Y','1',0),
                     0))
from ams_list_entries
where list_header_id = cur_p_list_header_id ;
*/
--- manual entries changes added: musman
cursor c_get_max_entries
is
select   no_of_rows_max_requested - no_of_rows_active
from ams_list_headers_all
where list_header_id = p_list_header_id ;

     l_no_of_chunks number;
l_master_type_id number;
l_source_type_code varchar2(30);

l_sql_string           VARCHAR2(32767);
l_min_rows                number;
l_new_status              varchar2(30);
l_new_status_id           number;
l_no_of_rows_duplicates         number;
l_no_of_rows_in_list            number;
l_no_of_rows_active             number;
l_no_of_rows_inactive           number;
l_no_of_rows_manually_entered   number;
l_no_of_rows_in_ctrl_group      number;
l_no_of_rows_random             number;

l_allowed_spaces NUMBER ;
p_added_entry_count NUMBER;
l_primary_tbl JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();

l_added_entry_count  NUMBER;
l_rows_to_add        NUMBER;
l_remaining_Spaces   NUMBER;
l_start_counter      NUMBER;
l_end_counter        NUMBER;
j NUMBER;

--rmbhanda bug#5197904 start
t_master_type_id     NUMBER;
l_child_count number :=0;

cursor c_mapping_childtypes(p_master_type_id
                          ams_list_src_type_assocs.master_source_type_id%type)
IS
select source_type_code
from   ams_list_src_types a,
       ams_list_src_type_assocs b
where  b.master_source_type_id = p_master_type_id
  and  b.sub_source_type_id  = a.list_source_type_id
and    b.enabled_flag = 'Y'
and    a.enabled_flag = 'Y'
and  exists (select 'x' from ams_list_src_fields
                 where list_source_type_id = b.sub_source_type_id
                   and field_column_name is not null) ;

p_mapping_childtype_rec c_mapping_childtypes%rowtype;
l_no_of_rows_duplicated NUMBER;

--rmbhanda bug#5197904 end

BEGIN

  SAVEPOINT process_manual_list;
  g_list_header_id :=  p_list_header_id;

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF (AMS_LOG_PROCEDURE_ON) THEN
    AMS_UTILITY_PVT.debug_message(AMS_LOG_PROCEDURE,g_module_name||'.'||l_api_name,l_full_name||':Start');
  END IF;


  IF NOT FND_API.compatible_api_call
   (
      l_api_version,
      p_api_version,
      l_api_name,
      g_pkg_name
   )THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;
  x_return_status  := FND_API.G_RET_STS_SUCCESS;

  update ams_list_entries
  set marked_flag =  null
  where list_header_id = p_list_header_id ;

--- manual entries changes start: musman
  OPEN c_get_max_entries;
  FETCH c_get_max_entries INTO l_allowed_spaces;
  CLOSE c_get_max_entries;

  IF (AMS_LOG_STATEMENT_ON) THEN
    AMS_UTILITY_PVT.debug_message(
         AMS_LOG_STATEMENT      ,g_module_name||'.'||l_api_name
     ,' l_allowed_spaces  :'||l_allowed_spaces);
  END IF;

  -- if user has not specified the max space, adding all the entries
  IF l_allowed_spaces IS NULL THEN
    l_allowed_spaces :=  p_primary_key_tbl.count;
  END IF;
  -- intialize the out param
  x_added_entry_count := 0;

  -- only if space is allowed then forming the sql
  IF l_allowed_spaces > 0 THEN

     -- rmbhanda bug#5197904 start - retrieve all the child types for the given master type -no hard codes
    /*if p_master_type = 'PERSON_LIST' then
      l_child_types(1) := 'PERSON_PHONE1';
    end if;
    if p_master_type = 'ORGANIZATION_CONTACT_LIST' then
      l_child_types(1) := 'ORGANIZATION_PHONE1';
      l_child_types(2) := 'ORGANIZATION_LIST';
    end if;*/

    open c_mapping_types(p_master_type);
    loop
	    fetch c_mapping_types
		     into t_master_type_id;
	    exit when c_mapping_types%notfound;
    end loop;
    close c_mapping_types;

    open c_mapping_childtypes(t_master_type_id);
    loop
	    fetch c_mapping_childtypes
		into p_mapping_childtype_rec;
	    exit when c_mapping_childtypes%notfound;

	    l_child_count := l_child_count +1;
	    l_child_types(l_child_count) := p_mapping_childtype_rec.source_type_code;
    end loop;
    close c_mapping_childtypes;

    --rmbhanda bug#5197904 end

    form_sql_statement( p_list_header_id => p_list_header_id,
                       p_master_type   => p_master_type ,
                       p_child_types   => l_child_types,
                       x_final_string  => l_sql_string
                             ) ;
    /*
    EXECUTE IMMEDIATE
     'BEGIN
          FORALL  i  in :1 .. :2    '
           || '  ' || p_sql_string || ' :tab(i)
           and
          not exists (select 1
                      from  ams_list_entries
                      where list_entry_source_system_id = :tab(i)
                        and list_header_id  = :5 and enabled_flag=''Y'');

      END; '
    using p_primary_key_tbl.first,
          p_primary_key_tbl.last,
          p_primary_key_tbl,
          p_list_header_id; */

    l_rows_to_add := p_primary_key_tbl.count;
    IF l_rows_to_add <= l_allowed_spaces THEN
      do_bulk_insert(
        p_sql_string       => l_sql_string
      ,p_list_header_id    => p_list_header_id
      ,p_primary_key_tbl   => p_primary_key_tbl
      ,x_added_entry_count => l_added_entry_count
      ,x_return_status     => x_return_status
      ,x_msg_count         => x_msg_count
      ,x_msg_data          => x_msg_data );

      x_added_entry_count := l_added_entry_count;

    ELSIF l_rows_to_add > l_allowed_spaces THEN
      -- written the logic if the user trying to add entries is larger than allowed space
      -- trying to form a new pl/sql table of allowed space and doing bulkInsert.if the entries
      -- are not added due to duplicate, then looping thru the user sent data to the remaining spaces
      -- and doing bulk insert, until the allowed space is reached or loop through all added entries (p_primary_key_tbl)
      l_remaining_Spaces := l_allowed_spaces;
      l_start_counter := 1;
      l_end_counter := l_remaining_Spaces;

      IF (AMS_LOG_STATEMENT_ON) THEN
       AMS_UTILITY_PVT.debug_message(AMS_LOG_STATEMENT,g_module_name||'.'||l_api_name
                 ,'FIRST TIME ::l_remaining_Spaces :'||l_remaining_Spaces||', l_start_counter:'||l_start_counter||',l_end_counter:'||l_end_counter );
      END IF;

      WHILE l_remaining_Spaces >0 LOOP
        l_primary_tbl.extend(l_remaining_Spaces);
	j := 1;
        for i in l_start_counter..l_end_counter LOOP
          l_primary_tbl(j) := p_primary_key_tbl(i);
	  j:= J+1;
        end loop;

        do_bulk_insert(
           p_sql_string       => l_sql_string
        , p_list_header_id    => p_list_header_id
        , p_primary_key_tbl   => l_primary_tbl
        , x_added_entry_count => l_added_entry_count
        , x_return_status     => x_return_status
        , x_msg_count         => x_msg_count
        , x_msg_data          => x_msg_data );

        x_added_entry_count := x_added_entry_count + l_added_entry_count;

       IF (AMS_LOG_STATEMENT_ON) THEN
        AMS_UTILITY_PVT.debug_message(AMS_LOG_STATEMENT,g_module_name||'.'||l_api_name
                 ,'IN THE LOOP before reset ::l_remaining_Spaces :'||l_remaining_Spaces||
                 ', l_start_counter:'||l_start_counter||',l_end_counter:'||l_end_counter );
        AMS_UTILITY_PVT.debug_message(AMS_LOG_STATEMENT,g_module_name||'.'||l_api_name
                 ,'x_added_entry_count :'||x_added_entry_count );
       END IF;

       IF l_remaining_spaces = l_added_entry_count THEN
         EXIT;
       ELSE
        l_remaining_Spaces := l_allowed_spaces - x_added_entry_count;
        l_start_counter := l_end_counter + 1;

        IF ((l_start_counter > l_rows_to_add)
        OR (l_remaining_spaces = 0 ))THEN
          Exit;
        END IF;
        --l_end_counter := l_start_counter + (l_remaining_spaces-1);
        l_end_counter := l_end_counter +l_remaining_Spaces ;
        l_primary_tbl.delete;
        l_primary_tbl := JTF_NUMBER_TABLE();

        IF l_end_counter > l_rows_to_add THEN
          l_end_counter := l_rows_to_add;
        END IF;
       END IF;
       IF (AMS_LOG_STATEMENT_ON) THEN
        AMS_UTILITY_PVT.debug_message(AMS_LOG_STATEMENT,g_module_name||'.'||l_api_name
                 ,'IN THE LOOP after reset ::l_remaining_Spaces :'||l_remaining_Spaces||', l_start_counter:'||l_start_counter||',l_end_counter:'||l_end_counter );
       END IF;

      END LOOP;

    END IF;
--- manual entries changes end: musman
/* bug:4467062 fix:musman
  open c_count_list_entries(p_list_header_id);
  fetch c_count_list_entries
   into l_no_of_rows_active            ,
        l_no_of_rows_inactive          ,
        l_no_of_rows_in_list           ,
        l_no_of_rows_in_ctrl_group     ,
        l_no_of_rows_random            ,
        l_no_of_rows_duplicates        ,
        l_no_of_rows_manually_entered  ;
  close c_count_list_entries;
*/

 SELECT nvl(no_of_rows_min_requested,0)
 INTO   l_min_rows
 FROM   ams_list_headers_all
 WHERE  list_header_id = p_list_header_id;

 if l_min_rows > l_no_of_rows_active then
    l_new_status :=  'DRAFT';
    l_new_status_id   :=  300;
 else
    l_new_status :=  'AVAILABLE';
    l_new_status_id   :=  303;
 end if;
 /* bug:4467062 fix:musman
  update ams_list_headers_all
  set no_of_rows_in_list           = l_no_of_rows_in_list,
      no_of_rows_active            = l_no_of_rows_active,
      no_of_rows_inactive          = l_no_of_rows_inactive,
      no_of_rows_in_ctrl_group     = l_no_of_rows_in_ctrl_group,
      no_of_rows_random            = l_no_of_rows_random,
      no_of_rows_duplicates        = l_no_of_rows_duplicates,
      no_of_rows_manually_entered  = l_no_of_rows_manually_entered       ,
      status_code                  = l_new_status,
      user_status_id               = l_new_status_id,
      status_date                  = sysdate
  WHERE  list_header_id            = p_list_header_id;
  */

   -- rmbhanda bug#5197904 start - Mark duplicate entries as disabled.

  UPDATE ams_list_entries a
         SET a.enabled_flag  = 'N',
             a.marked_as_duplicate_flag = 'Y'
       WHERE a.list_header_id = p_list_header_id
         and a.enabled_flag = 'Y'
	 and a.manually_entered_flag ='Y'
         AND a.rowid >  (SELECT min(b.rowid)
                           from ams_list_entries  b
                          where b.list_header_id = p_list_header_id
                            and b.party_id = a.party_id
                            and b.enabled_flag = 'Y'
			    and b.manually_entered_flag ='Y'
                   );

  l_no_of_rows_duplicated := sql%rowcount;

/*update ams_list_headers_all
  set no_of_rows_in_list           = no_of_rows_in_list + x_added_entry_count,
      no_of_rows_active            = no_of_rows_active + x_added_entry_count,
      no_of_rows_manually_entered  = no_of_rows_manually_entered + x_added_entry_count,
      status_code                  = l_new_status,
      user_status_id               = l_new_status_id,
      status_date                  = sysdate
  WHERE  list_header_id            = p_list_header_id; */

  --Update active rows/duplicate records count based on the no. of rows duplicated.

  update ams_list_headers_all
  set no_of_rows_in_list           = no_of_rows_in_list + x_added_entry_count,
      no_of_rows_active            = no_of_rows_active + x_added_entry_count - l_no_of_rows_duplicated ,
      no_of_rows_manually_entered  = no_of_rows_manually_entered + x_added_entry_count,
      status_code                  = l_new_status,
      user_status_id               = l_new_status_id,
      status_date                  = sysdate,
      no_of_rows_duplicates        = no_of_rows_duplicates + l_no_of_rows_duplicated
  WHERE  list_header_id            = p_list_header_id;

  -- rmbhanda bug#5197904 end


 END IF;

   IF x_return_status =  fnd_api.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;
   IF p_commit = FND_API.g_true then
      COMMIT WORK;
   END IF;

   FND_MSG_PUB.Count_AND_Get
       ( p_count           =>      x_msg_count,
         p_data            =>      x_msg_data,
         p_encoded         =>      FND_API.G_FALSE );

   IF (AMS_LOG_PROCEDURE_ON) THEN
     AMS_UTILITY_PVT.debug_message(AMS_LOG_PROCEDURE,g_module_name||'.'||l_api_name,l_full_name||': END ');
   END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.g_ret_sts_error ;
     ROLLBACK TO process_manual_list;
      FND_MSG_PUB.Count_AND_Get
         ( p_count       =>      x_msg_count,
           p_data        =>      x_msg_data,
           p_encoded    =>      FND_API.G_FALSE
          );
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.g_ret_sts_unexp_error ;
        ROLLBACK TO process_manual_list;
     FND_MSG_PUB.Count_AND_Get
         ( p_count           =>      x_msg_count,
           p_data            =>      x_msg_data,
           p_encoded        =>      FND_API.G_FALSE
          );
 WHEN OTHERS  THEN
        x_return_status := FND_API.g_ret_sts_unexp_erroR ;
        ROLLBACK TO process_manual_list;
       IF (AMS_LOG_PROCEDURE_ON) THEN
        AMS_UTILITY_PVT.debug_message(AMS_LOG_PROCEDURE,g_module_name||'.'||l_api_name
                              ,' In Others exception handling ');
      END IF;

      IF (AMS_LOG_EXCEPTION_ON) THEN
        AMS_UTILITY_PVT.debug_message(AMS_LOG_EXCEPTION,g_module_name||'.'||l_api_name
                         ,'SQLCODE:' || SQLCODE || ' SQLERRM: ' || SQLERRM);
      END IF;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_AND_Get
       ( p_count           =>      x_msg_count,
         p_data            =>      x_msg_data,
         p_encoded         =>      FND_API.G_FALSE
        );

END;

--Wrapper API added for supporting contact list created from OSO
--bug 4348939
PROCEDURE process_manual_list(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_list_header_id    in  NUMBER,
   p_primary_key_tbl   IN  JTF_NUMBER_TABLE,--primary_key_Tbl_Type ,
   p_master_type       in  VARCHAR2
-- , x_added_entry_count OUT NOCOPY NUMBER --- manual entries changes added:musman
) IS

x_added_entry_count NUMBER;

BEGIN

process_manual_list(
   p_api_version,
   p_init_msg_list,
   p_commit,
   p_validation_level,
   x_return_status,
   x_msg_count,
   x_msg_data,
   p_list_header_id,
   p_primary_key_tbl,
   p_master_type,
   x_added_entry_count --- manual entries changes added:musman
);

END process_manual_list;


PROCEDURE process_employee_list(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_list_header_id    in  NUMBER,
   p_primary_key_tbl   IN  primary_key_Tbl_Type ,
   p_last_name_tbl     IN  varchar2_Tbl_Type ,
   p_first_name_tbl    IN  varchar2_Tbl_Type ,
   p_email_tbl         IN  varchar2_Tbl_Type ,
   p_master_type       in  VARCHAR2
) IS
l_api_name constant varchar2(30) := 'process_employee_list';
l_list_header_id number;
l_api_version       CONSTANT NUMBER := 1.0;

cursor c_count_list_entries(cur_p_list_header_id number) is
select sum(decode(enabled_flag,'N',0,1)),
       sum(decode(enabled_flag,'Y',0,1)),
       sum(1),
       sum(decode(part_of_control_group_flag,'Y',1,0)),
       sum(decode(marked_as_random_flag,'Y',1,0)),
       sum(decode(marked_as_duplicate_flag,'Y',1,0)),
       sum(decode(manually_entered_flag,
                     'Y',decode(enabled_flag,'Y','1',0),
                     0))
from ams_list_entries
where list_header_id = cur_p_list_header_id ;

l_master_type_id number;
l_source_type_code varchar2(30);


l_min_rows                number;
l_new_status              varchar2(30);
l_new_status_id           number;
l_no_of_rows_duplicates         number;
l_no_of_rows_in_list            number;
l_no_of_rows_active             number;
l_no_of_rows_inactive           number;
l_no_of_rows_manually_entered   number;
l_no_of_rows_in_ctrl_group      number;
l_no_of_rows_random             number;

l_created_by                NUMBER;  --batoleti added this var. For bug# 6688996

/* batoleti. Bug# 6688996. Added the below cursor */
    CURSOR cur_get_created_by (x_list_header_id IN NUMBER) IS
      SELECT created_by
      FROM ams_list_headers_all
      WHERE list_header_id= x_list_header_id;


BEGIN

   SAVEPOINT process_employee_list;

   IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call
   (
      l_api_version,
      p_api_version,
      l_api_name,
      g_pkg_name
   )
   THEN
        RAISE FND_API.g_exc_unexpected_error;
   END IF;
   x_return_status  := FND_API.G_RET_STS_SUCCESS;

        -- batoleti  coding starts for bug# 6688996
      l_created_by := 0;

       OPEN cur_get_created_by(p_list_header_id);

       FETCH cur_get_created_by INTO l_created_by;
       CLOSE cur_get_created_by;

   -- batoleti  coding ends for bug# 6688996

   FORALL I in p_primary_key_tbl.first .. p_primary_key_tbl.last
       INSERT INTO ams_List_Entries
         ( list_entry_id                   ,
         last_update_date                ,
         last_updated_by                 ,
         creation_date                   ,
         created_by                      ,
         last_update_login               ,
         list_header_id                  ,
         list_select_action_id           ,
         arc_list_select_action_from     ,
         list_select_action_from_name    ,
         source_code                     ,
         source_code_for_id              ,
         arc_list_used_by_source         ,
         pin_code                        ,
         list_entry_source_system_id     ,
         list_entry_source_system_type   ,
         view_application_id             ,
         manually_entered_flag           ,
         marked_as_random_flag           ,
         marked_as_duplicate_flag        ,
         part_of_control_group_flag      ,
         exclude_in_triggered_list_flag  ,
         enabled_flag,
         marked_flag ,
         object_version_number,
         first_name,
         last_name,
         email_address
        )
        ( select ams_list_entries_s.nextval,
                 sysdate,
                 fnd_global.user_id,
                 sysdate,
                 nvl(l_created_by, fnd_global.user_id),
                 fnd_global.conc_login_id,
                 p_list_header_id,
                 0,
                 'NONE',
                 'NONE',
                 'NONE',
                 0,
                 p_list_header_id,
                 ams_list_entries_s.currval,
                 p_primary_key_tbl(i)   ,
                 p_master_type,
                 530,
                 'Y',
                 'N',
                 'N',
                 'N',
                 'N',
                 'Y',
                 'Y',
                  1,
                  p_first_name_tbl(i),
                  p_last_name_tbl(i),
                  p_email_tbl(i)
          from   dual
          where not exists (select 'x'
                      from  ams_list_entries
                      where list_entry_source_system_id = p_primary_key_tbl(i)
                        and list_header_id  = p_list_header_id));



  open c_count_list_entries(p_list_header_id);
  fetch c_count_list_entries
   into l_no_of_rows_active            ,
        l_no_of_rows_inactive          ,
        l_no_of_rows_in_list           ,
        l_no_of_rows_in_ctrl_group     ,
        l_no_of_rows_random            ,
        l_no_of_rows_duplicates        ,
        l_no_of_rows_manually_entered  ;
  close c_count_list_entries;


 SELECT nvl(no_of_rows_min_requested,0)
 INTO   l_min_rows
 FROM   ams_list_headers_all
 WHERE  list_header_id = p_list_header_id;

 if l_min_rows > l_no_of_rows_active then
    l_new_status :=  'DRAFT';
    l_new_status_id   :=  300;
 else
    l_new_status :=  'AVAILABLE';
    l_new_status_id   :=  303;
 end if;
  update ams_list_headers_all
  set no_of_rows_in_list           = l_no_of_rows_in_list,
      no_of_rows_active            = l_no_of_rows_active,
      no_of_rows_inactive          = l_no_of_rows_inactive,
      no_of_rows_in_ctrl_group     = l_no_of_rows_in_ctrl_group,
      no_of_rows_random            = l_no_of_rows_random,
      no_of_rows_duplicates        = l_no_of_rows_duplicates,
      no_of_rows_manually_entered  = l_no_of_rows_manually_entered       ,
      status_code                  = l_new_status,
      user_status_id               = l_new_status_id,
      status_date                  = sysdate
  WHERE  list_header_id            = p_list_header_id;


   IF x_return_status =  fnd_api.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;
   IF p_commit = FND_API.g_true then
      COMMIT WORK;
   END IF;

   FND_MSG_PUB.Count_AND_Get
       ( p_count           =>      x_msg_count,
         p_data            =>      x_msg_data,
         p_encoded         =>      FND_API.G_FALSE );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.g_ret_sts_error ;
     ROLLBACK TO process_employee_list;
      FND_MSG_PUB.Count_AND_Get
         ( p_count       =>      x_msg_count,
           p_data        =>      x_msg_data,
           p_encoded    =>      FND_API.G_FALSE
          );
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.g_ret_sts_unexp_error ;
        ROLLBACK TO process_employee_list;
     FND_MSG_PUB.Count_AND_Get
         ( p_count           =>      x_msg_count,
           p_data            =>      x_msg_data,
           p_encoded        =>      FND_API.G_FALSE
          );
 WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_erroR ;
        ROLLBACK TO process_employee_list;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_AND_Get
       ( p_count           =>      x_msg_count,
         p_data            =>      x_msg_data,
         p_encoded         =>      FND_API.G_FALSE
        );

END;
END AMS_MANUAL_LIST_GEN ;

/
