--------------------------------------------------------
--  DDL for Package Body AMS_LIST_QUERIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LIST_QUERIES_PKG" as
/* $Header: amstliqb.pls 120.3 2006/06/27 06:21:16 bmuthukr noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_LIST_QUERIES_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_LIST_QUERIES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstliqb.pls';


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createInsertBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Insert_Row(
          px_list_query_id   IN OUT NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_name    VARCHAR2,
          p_type    VARCHAR2,
          p_enabled_flag    VARCHAR2,
          p_primary_key    VARCHAR2,
          p_source_object_name  VARCHAR2,
          p_public_flag    VARCHAR2,
          px_org_id   IN OUT NOCOPY NUMBER,
          p_comments    VARCHAR2,
          p_act_list_query_used_by_id    NUMBER,
          p_arc_act_list_query_used_by    VARCHAR2,
          p_sql_string    VARCHAR2,
          p_parent_list_query_id number,
          p_sequence_order  in  number)

 IS
   x_rowid    VARCHAR2(30);


BEGIN

   IF (px_org_id IS NULL OR px_org_id = FND_API.G_MISS_NUM) THEN
       SELECT NVL(rtrim(ltrim(SUBSTRB(USERENV('CLIENT_INFO'),1,10))),
                     '')
       INTO px_org_id
       FROM DUAL;
   END IF;


   px_object_version_number := 1;


   INSERT INTO AMS_LIST_QUERIES_ALL(
           list_query_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           object_version_number,
           name,
           type,
           enabled_flag,
           primary_key,
           source_object_name  ,
           public_flag,
           org_id,
           comments,
           act_list_query_used_by_id,
           arc_act_list_query_used_by,
--           sql_string,
	  query,
          parent_list_query_id ,
          sequence_order
   ) VALUES (
           DECODE( px_list_query_id, FND_API.g_miss_num, NULL, px_list_query_id),
           DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
           null,--DECODE( p_name, FND_API.g_miss_char, NULL, p_name),
           DECODE( p_type, FND_API.g_miss_char, NULL, p_type),
           DECODE( p_enabled_flag, FND_API.g_miss_char, 'Y', p_enabled_flag),
           DECODE( p_primary_key, FND_API.g_miss_char, NULL, p_primary_key),
           DECODE( p_source_object_name, FND_API.g_miss_char, NULL, p_source_object_name),
           DECODE( p_public_flag, FND_API.g_miss_char,'N' , p_public_flag),
           DECODE( px_org_id, FND_API.g_miss_num, NULL, px_org_id),
           DECODE( p_comments, FND_API.g_miss_char, NULL, p_comments),
           DECODE( p_act_list_query_used_by_id, FND_API.g_miss_num, NULL, p_act_list_query_used_by_id),
           DECODE( p_arc_act_list_query_used_by, FND_API.g_miss_char, NULL, p_arc_act_list_query_used_by),
           DECODE( p_sql_string, FND_API.g_miss_char, NULL, p_sql_string),
           DECODE( p_parent_list_query_id, FND_API.g_miss_num, NULL, p_parent_list_query_id),
           DECODE( p_sequence_order, FND_API.g_miss_num, NULL, p_sequence_order));


	    insert into AMS_LIST_QUERIES_TL (
    LANGUAGE,
    SOURCE_LANG,
    NAME,
    DESCRIPTION,
    LIST_QUERY_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN
  ) select
    l.language_code,
    userenv('LANG'),
   decode(p_name ,FND_API.g_miss_char,null,p_name) ,
   decode(p_comments ,FND_API.g_miss_char,null,p_comments) ,
   decode(px_list_query_id ,FND_API.g_miss_num,null,px_list_query_id) ,
    sysdate,
    FND_GLOBAL.user_id,
    sysdate,
    FND_GLOBAL.user_id,
    FND_GLOBAL.conc_login_id
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AMS_LIST_QUERIES_TL T
    where T.list_query_id = px_list_query_id
    and T.LANGUAGE = L.LANGUAGE_CODE);

END Insert_Row;


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createUpdateBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Update_Row(
          p_list_query_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_name    VARCHAR2,
          p_type    VARCHAR2,
          p_enabled_flag    VARCHAR2,
          p_primary_key    VARCHAR2,
          p_source_object_name  VARCHAR2,
          p_public_flag    VARCHAR2,
          p_org_id    NUMBER,
          p_comments    VARCHAR2,
          p_act_list_query_used_by_id    NUMBER,
          p_arc_act_list_query_used_by    VARCHAR2,
          p_sql_string    VARCHAR2,
          p_parent_list_query_id number,
          p_sequence_order  in  number)
 IS
 BEGIN
    Update AMS_LIST_QUERIES_ALL
    SET
              list_query_id = DECODE( p_list_query_id, FND_API.g_miss_num, list_query_id, p_list_query_id),
              last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
              creation_date = DECODE( p_creation_date, FND_API.g_miss_date, creation_date, p_creation_date),
              created_by = DECODE( p_created_by, FND_API.g_miss_num, created_by, p_created_by),
              last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
              object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, 1, p_object_version_number+1 ),
              name = DECODE( p_name, FND_API.g_miss_char, name, p_name),
              type = DECODE( p_type, FND_API.g_miss_char, type, p_type),
              enabled_flag = DECODE( p_enabled_flag, FND_API.g_miss_char, enabled_flag, p_enabled_flag),
              primary_key = DECODE( p_primary_key, FND_API.g_miss_char, primary_key, p_primary_key),
              source_object_name = DECODE( p_source_object_name, FND_API.g_miss_char, NULL, p_source_object_name),
              public_flag = DECODE( p_public_flag, FND_API.g_miss_char, public_flag, p_public_flag),
              org_id = DECODE( p_org_id, FND_API.g_miss_num, org_id, p_org_id),
              comments = DECODE( p_comments, FND_API.g_miss_char, comments, p_comments),
              act_list_query_used_by_id = DECODE( p_act_list_query_used_by_id, FND_API.g_miss_num, act_list_query_used_by_id, p_act_list_query_used_by_id),
              arc_act_list_query_used_by = DECODE( p_arc_act_list_query_used_by, FND_API.g_miss_char, arc_act_list_query_used_by, p_arc_act_list_query_used_by),
--              sql_string =  DECODE( p_sql_string, FND_API.g_miss_char,sql_string, p_sql_string),
              query =  DECODE( p_sql_string, FND_API.g_miss_char,sql_string, p_sql_string),
              parent_list_query_id =  decode(p_parent_list_query_id, FND_API.g_miss_num, parent_list_query_id, p_parent_list_query_id),
              sequence_order =  decode(p_sequence_order, FND_API.g_miss_num, sequence_order, p_sequence_order)
   WHERE LIST_QUERY_ID = p_LIST_QUERY_ID
   AND   object_version_number = p_object_version_number;

   IF (SQL%NOTFOUND) THEN
RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
END Update_Row;


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createDeleteBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Delete_Row(
    p_LIST_QUERY_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM AMS_LIST_QUERIES_ALL
    WHERE LIST_QUERY_ID = p_LIST_QUERY_ID;
   If (SQL%NOTFOUND) then
RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;
 END Delete_Row ;



----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createLockBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Lock_Row(
          p_list_query_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_name    VARCHAR2,
          p_type    VARCHAR2,
          p_enabled_flag    VARCHAR2,
          p_primary_key    VARCHAR2,
          p_source_object_name  VARCHAR2,
          p_public_flag    VARCHAR2,
          p_org_id    NUMBER,
          p_comments    VARCHAR2,
          p_act_list_query_used_by_id    NUMBER,
          p_arc_act_list_query_used_by    VARCHAR2,
          p_sql_string    VARCHAR2,
          p_parent_list_query_id number,
          p_sequence_order  in  number)

 IS
   CURSOR C IS
        SELECT *
         FROM AMS_LIST_QUERIES_ALL
        WHERE LIST_QUERY_ID =  p_LIST_QUERY_ID
        FOR UPDATE of LIST_QUERY_ID NOWAIT;
   Recinfo C%ROWTYPE;
 BEGIN
    OPEN c;
    FETCH c INTO Recinfo;
    If (c%NOTFOUND) then
        CLOSE c;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    CLOSE C;
 END Lock_Row;

PROCEDURE load_row(
          p_owner            varchar2,
          p_list_query_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_name    VARCHAR2,
          p_type    VARCHAR2,
          p_enabled_flag    VARCHAR2,
          p_primary_key    VARCHAR2,
          p_source_object_name  VARCHAR2,
          p_public_flag    VARCHAR2,
          p_org_id    NUMBER,
          p_comments    VARCHAR2,
          p_act_list_query_used_by_id    NUMBER,
          p_arc_act_list_query_used_by    VARCHAR2,
          p_sql_string    VARCHAR2,
	  p_custom_mode    VARCHAR2

          ) is
l_d_object_version_number  number;
x_return_status    varchar2(1);
l_row_id    varchar2(100);
l_user_id    number;

l_object_version_number    NUMBER := p_object_version_number   ;
l_list_query_id    NUMBER := p_list_query_id   ;
l_org_id  number := p_org_id;
l_last_updated_by number;
l_obj_verno NUMBER;

cursor c_chk_col_exists is
select object_version_number
from   ams_list_queries_all
where  list_query_id = p_list_query_id;

CURSOR  c_obj_verno IS
      SELECT object_version_number, last_updated_by
      FROM   ams_list_queries_all
      where  list_query_id = p_list_query_id;

begin
  if p_OWNER = 'SEED' then
    l_user_id := 1;
  elsif p_OWNER = 'ORACLE' then
      l_user_id := 2;
  elsif p_OWNER = 'SYSADMIN' THEN
      l_user_id := 0;

  end if;
  open c_chk_col_exists;
  fetch c_chk_col_exists into l_d_object_version_number;
  if c_chk_col_exists%notfound then
     close c_chk_col_exists;

 Insert_Row(
          px_list_query_id   => l_list_query_id ,
          p_last_update_date    => p_last_update_date,
          p_last_updated_by    => p_last_updated_by,
          p_creation_date    => p_creation_date,
          p_created_by    => p_created_by,
          p_last_update_login    => p_last_update_login,
          px_object_version_number   => l_object_version_number,
          p_name    => p_name ,
          p_type    => p_type,
          p_enabled_flag    => p_enabled_flag ,
          p_primary_key    => p_primary_key,
          p_source_object_name => p_source_object_name   ,
          p_public_flag   => p_public_flag     ,
          px_org_id  => l_org_id    ,
          p_comments   => p_comments     ,
          p_act_list_query_used_by_id  => p_act_list_query_used_by_id    ,
          p_arc_act_list_query_used_by => p_arc_act_list_query_used_by   ,
          p_sql_string   => p_sql_string     ,
          p_parent_list_query_id => l_list_query_id,
          p_sequence_order => 1);
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
 else
    close c_chk_col_exists;

        OPEN c_obj_verno;
         FETCH c_obj_verno INTO l_obj_verno  ,l_last_updated_by;
          CLOSE c_obj_verno;


    if (l_last_updated_by in (1,2,0) OR
                 NVL(p_custom_mode,'PRESERVE')='FORCE') THEN


     Update_Row(
          p_list_query_id   => p_list_query_id     ,
          p_last_update_date  =>  p_last_update_date     ,
          p_last_updated_by   => p_last_updated_by     ,
          p_creation_date   => p_creation_date     ,
          p_created_by   => p_created_by     ,
          p_last_update_login   => p_last_update_login     ,
          p_object_version_number   => l_obj_verno     ,
          p_name   => p_name     ,
          p_type   => p_type     ,
          p_enabled_flag   => p_enabled_flag     ,
          p_primary_key   => p_primary_key     ,
          p_source_object_name => p_source_object_name   ,
          p_public_flag   => p_public_flag     ,
          p_org_id    => p_org_id    ,
          p_comments => p_comments   ,
          p_act_list_query_used_by_id   => p_act_list_query_used_by_id     ,
          p_arc_act_list_query_used_by  => p_arc_act_list_query_used_by    ,
          p_sql_string => p_sql_string,
          p_parent_list_query_id   => p_list_query_id     ,
          p_sequence_order   => 1     );

     end if;
      --
 end if;
end ;

--added for bug 5086232
procedure ADD_LANGUAGE
is
begin
  delete from AMS_LIST_QUERIES_TL T
  where not exists
    (select NULL
    from AMS_LIST_QUERIES_ALL B
    where B.LIST_QUERY_ID = T.LIST_QUERY_ID
    );

  update AMS_LIST_QUERIES_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from AMS_LIST_QUERIES_TL B
    where B.LIST_QUERY_ID = T.LIST_QUERY_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.LIST_QUERY_ID,
      T.LANGUAGE
  ) in (select
      SUBT.LIST_QUERY_ID,
      SUBT.LANGUAGE
    from AMS_LIST_QUERIES_TL SUBB, AMS_LIST_QUERIES_TL SUBT
    where SUBB.LIST_QUERY_ID = SUBT.LIST_QUERY_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AMS_LIST_QUERIES_TL (
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    NAME,
    DESCRIPTION,
    LIST_QUERY_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.NAME,
    B.DESCRIPTION,
    B.LIST_QUERY_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMS_LIST_QUERIES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMS_LIST_QUERIES_TL T
    where T.LIST_QUERY_ID = B.LIST_QUERY_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

PROCEDURE translate_row(
  p_list_query_id in number,
  p_name in varchar2,
  p_owner   in varchar2,
  p_custom_mode in varchar2
 )  is

  cursor c_last_updated_by is
	  select last_updated_by
	  FROM AMS_LIST_QUERIES_TL
	  where  LIST_QUERY_ID =  p_list_query_id
	  and  USERENV('LANG') = LANGUAGE;

l_last_updated_by number;

begin


     open c_last_updated_by;
     fetch c_last_updated_by into l_last_updated_by;
     close c_last_updated_by;

     if (l_last_updated_by in (1,2,0) OR
            NVL(p_custom_mode,'PRESERVE')='FORCE') THEN
	    update ams_list_queries_tl
	       set name= nvl(p_name, name),
  	           source_lang = userenv('LANG'),
	           last_update_date = sysdate,
	           last_updated_by = decode(p_owner, 'SEED', 1, 'ORACLE',2, 'SYSADMIN',0, -1),
	           last_update_login = 0
             where LIST_QUERY_ID = p_list_query_id
	       and userenv('LANG') in (language, source_lang);
     end if;

end TRANSLATE_ROW;

END AMS_LIST_QUERIES_PKG;

/
