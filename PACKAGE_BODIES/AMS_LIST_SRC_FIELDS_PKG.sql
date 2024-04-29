--------------------------------------------------------
--  DDL for Package Body AMS_LIST_SRC_FIELDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LIST_SRC_FIELDS_PKG" as
/* $Header: amstlsfb.pls 120.3 2006/06/07 08:40:33 bmuthukr noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_LIST_SRC_FIELDS_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_LIST_SRC_FIELDS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstlsfb.pls';


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
          px_list_source_field_id   IN OUT NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_de_list_source_type_code    VARCHAR2,
          p_list_source_type_id    NUMBER,
          p_field_table_name    VARCHAR2,
          p_field_column_name    VARCHAR2,
          p_source_column_name    VARCHAR2,
          p_source_column_meaning    VARCHAR2,
          p_enabled_flag    VARCHAR2,
          p_start_position    NUMBER,
          p_end_position    NUMBER,
          p_FIELD_DATA_TYPE               VARCHAR2,
          p_FIELD_DATA_SIZE               NUMBER ,
          p_DEFAULT_UI_CONTROL            VARCHAR2,
          p_FIELD_LOOKUP_TYPE             VARCHAR2,
          p_FIELD_LOOKUP_TYPE_VIEW_NAME   VARCHAR2,
          p_ALLOW_LABEL_OVERRIDE          VARCHAR2 ,
          p_FIELD_USAGE_TYPE              VARCHAR2,
          p_dialog_enabled                VARCHAR2,
	  p_analytics_flag                VARCHAR2,
	  p_auto_binning_flag             VARCHAR2,
	  p_no_of_buckets                 NUMBER,
          p_attb_lov_id                   number,
          p_lov_defined_flag              varchar2,
	  p_column_type                   varchar2
)
IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := 1;


   INSERT INTO AMS_LIST_SRC_FIELDS(
           list_source_field_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           object_version_number,
           de_list_source_type_code,
           list_source_type_id,
           field_table_name,
           field_column_name,
           source_column_name,
           enabled_flag,
           start_position,
           end_position,
           FIELD_DATA_TYPE              ,
           FIELD_DATA_SIZE              ,
           DEFAULT_UI_CONTROL           ,
           FIELD_LOOKUP_TYPE            ,
           FIELD_LOOKUP_TYPE_VIEW_NAME  ,
           ALLOW_LABEL_OVERRIDE         ,
           FIELD_USAGE_TYPE             ,
           dialog_enabled               ,
    	   analytics_flag               ,
	   auto_binning_flag            ,
	   no_of_buckets                ,
           attb_lov_id                  ,
           lov_defined_flag             ,
	   column_type
   ) VALUES (
           DECODE( px_list_source_field_id, FND_API.g_miss_num, NULL, px_list_source_field_id),
           DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
           DECODE( p_de_list_source_type_code, FND_API.g_miss_char, NULL, p_de_list_source_type_code),
           DECODE( p_list_source_type_id, FND_API.g_miss_num, NULL, p_list_source_type_id),
           DECODE( p_field_table_name, FND_API.g_miss_char, NULL, p_field_table_name),
           DECODE( p_field_column_name, FND_API.g_miss_char, NULL, p_field_column_name),
           DECODE( p_source_column_name, FND_API.g_miss_char, NULL, p_source_column_name),
           DECODE( p_enabled_flag, FND_API.g_miss_char, NULL, p_enabled_flag),
           DECODE( p_start_position, FND_API.g_miss_num, NULL, p_start_position),
	   DECODE( p_end_position, FND_API.g_miss_num, NULL, p_end_position),
	   decode( p_FIELD_DATA_TYPE ,FND_API.g_miss_char,null,p_field_data_type),
	   decode( p_FIELD_DATA_SIZE ,FND_API.g_miss_num,null,p_field_data_size),
	   decode( p_DEFAULT_UI_CONTROL ,FND_API.g_miss_char,null,p_DEFAULT_UI_CONTROL ),
	   decode( p_FIELD_LOOKUP_TYPE,FND_API.g_miss_char,null,p_FIELD_LOOKUP_TYPE),
	   decode( p_FIELD_LOOKUP_TYPE_VIEW_NAME,FND_API.g_miss_char,null,p_FIELD_LOOKUP_TYPE_VIEW_NAME),
	   decode( p_ALLOW_LABEL_OVERRIDE ,FND_API.g_miss_char,null,p_ALLOW_LABEL_OVERRIDE ),
	   decode( p_FIELD_USAGE_TYPE,FND_API.g_miss_char,null,p_FIELD_USAGE_TYPE),
	   decode( p_dialog_enabled,FND_API.g_miss_char,null,p_dialog_enabled),
	   decode( p_analytics_flag,FND_API.g_miss_char,null,p_analytics_flag),
           decode( p_auto_binning_flag,FND_API.g_miss_char,null,p_auto_binning_flag),
	   decode( p_no_of_buckets,FND_API.g_miss_char,null,p_no_of_buckets),
	   decode( p_attb_lov_id,FND_API.g_miss_num,null,p_attb_lov_id),
	   decode( p_lov_defined_flag,FND_API.g_miss_char,null,p_lov_defined_flag),
	   decode( p_column_type,FND_API.g_miss_char,null,p_column_type)
);

  insert into AMS_LIST_SRC_FIELDS_TL (
    LANGUAGE,
    SOURCE_LANG,
    source_column_meaning,
    LIST_SOURCE_field_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATE_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN
  ) select
    l.language_code,
    userenv('LANG'),
    DECODE( p_source_column_meaning, FND_API.g_miss_char, NULL, p_source_column_meaning),
    DECODE( px_list_source_field_id, FND_API.g_miss_num, NULL, px_list_source_field_id),
--Modified for bug 5237401. bmuthukr
/*
    sysdate,
    FND_GLOBAL.user_id,
    sysdate,
    FND_GLOBAL.user_id,
*/
    DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
    DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
    DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
    DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
--
    FND_GLOBAL.conc_login_id
    from FND_LANGUAGES L
    where L.INSTALLED_FLAG in ('I', 'B')
    and not exists
    (select NULL
    from AMS_LIST_SRC_FIELDS_TL T
    where T.LIST_source_field_ID = px_LIST_SOURCE_field_ID
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
          p_list_source_field_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_de_list_source_type_code    VARCHAR2,
          p_list_source_type_id    NUMBER,
          p_field_table_name    VARCHAR2,
          p_field_column_name    VARCHAR2,
          p_source_column_name    VARCHAR2,
          p_source_column_meaning    VARCHAR2,
          p_enabled_flag    VARCHAR2,
          p_start_position    NUMBER,
          p_end_position    NUMBER,
          p_FIELD_DATA_TYPE               VARCHAR2,
          p_FIELD_DATA_SIZE               NUMBER ,
          p_DEFAULT_UI_CONTROL            VARCHAR2,
          p_FIELD_LOOKUP_TYPE             VARCHAR2,
          p_FIELD_LOOKUP_TYPE_VIEW_NAME   VARCHAR2,
          p_ALLOW_LABEL_OVERRIDE          VARCHAR2 ,
          p_FIELD_USAGE_TYPE              VARCHAR2,
          p_dialog_enabled                VARCHAR2,
 	  p_analytics_flag                VARCHAR2,
	  p_auto_binning_flag             VARCHAR2,
	  p_no_of_buckets                 NUMBER,
          p_attb_lov_id                   number,
          p_lov_defined_flag              varchar2,
	  p_column_type                   varchar2
)

 IS
 BEGIN
    Update AMS_LIST_SRC_FIELDS
    SET
              list_source_field_id = DECODE( p_list_source_field_id, FND_API.g_miss_num, list_source_field_id, p_list_source_field_id),
              last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
              creation_date = DECODE( p_creation_date, FND_API.g_miss_date, creation_date, p_creation_date),
              created_by = DECODE( p_created_by, FND_API.g_miss_num, created_by, p_created_by),
              last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
              object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, 1, p_object_version_number+1 ),
              de_list_source_type_code = DECODE( p_de_list_source_type_code, FND_API.g_miss_char, de_list_source_type_code, p_de_list_source_type_code),
              list_source_type_id = DECODE( p_list_source_type_id, FND_API.g_miss_num, list_source_type_id, p_list_source_type_id),
              field_table_name = DECODE( p_field_table_name, FND_API.g_miss_char, field_table_name, p_field_table_name),
              field_column_name = DECODE( p_field_column_name, FND_API.g_miss_char, field_column_name, p_field_column_name),
              source_column_name = DECODE( p_source_column_name, FND_API.g_miss_char, source_column_name, p_source_column_name),
              enabled_flag = DECODE( p_enabled_flag, FND_API.g_miss_char, enabled_flag, p_enabled_flag),
              start_position = DECODE( p_start_position, FND_API.g_miss_num, start_position, p_start_position),
              end_position = DECODE( p_end_position, FND_API.g_miss_num, end_position, p_end_position),
              FIELD_DATA_TYPE =  decode( p_FIELD_DATA_TYPE ,FND_API.g_miss_char,FIELD_DATA_TYPE ,p_field_data_type),
              FIELD_DATA_SIZE = decode( p_FIELD_DATA_SIZE ,FND_API.g_miss_num,FIELD_DATA_SIZE,p_field_data_size),
              DEFAULT_UI_CONTROL= decode( p_DEFAULT_UI_CONTROL ,FND_API.g_miss_char,DEFAULT_UI_CONTROL,p_DEFAULT_UI_CONTROL ),
              FIELD_LOOKUP_TYPE = decode( p_FIELD_LOOKUP_TYPE,FND_API.g_miss_char,FIELD_LOOKUP_TYPE,p_FIELD_LOOKUP_TYPE),
              FIELD_LOOKUP_TYPE_VIEW_NAME = decode( p_FIELD_LOOKUP_TYPE_VIEW_NAME,FND_API.g_miss_char,FIELD_LOOKUP_TYPE_VIEW_NAME,p_FIELD_LOOKUP_TYPE_VIEW_NAME),
              ALLOW_LABEL_OVERRIDE=  decode( p_ALLOW_LABEL_OVERRIDE ,FND_API.g_miss_char,ALLOW_LABEL_OVERRIDE ,p_ALLOW_LABEL_OVERRIDE ),
              FIELD_USAGE_TYPE= decode( p_FIELD_USAGE_TYPE,FND_API.g_miss_char,FIELD_USAGE_TYPE,p_FIELD_USAGE_TYPE),
              dialog_enabled= decode( p_dialog_enabled,FND_API.g_miss_char,dialog_enabled,p_dialog_enabled),
	      analytics_flag = decode( p_analytics_flag,FND_API.g_miss_char,analytics_flag,p_analytics_flag),
	      auto_binning_flag = decode( p_auto_binning_flag,FND_API.g_miss_char,auto_binning_flag,p_auto_binning_flag),
              no_of_buckets = decode( p_no_of_buckets,FND_API.g_miss_num,no_of_buckets,p_no_of_buckets),
	      attb_lov_id = decode( p_attb_lov_id,FND_API.g_miss_num,attb_lov_id,p_attb_lov_id),
              lov_defined_flag = decode( p_lov_defined_flag,FND_API.g_miss_char,lov_defined_flag,p_lov_defined_flag),
	      column_type = decode( p_column_type,FND_API.g_miss_char,column_type,p_column_type)

   WHERE LIST_SOURCE_FIELD_ID = p_LIST_SOURCE_FIELD_ID
   AND   object_version_number = p_object_version_number;

   IF (SQL%NOTFOUND) THEN
RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

  update AMS_LIST_SRC_FIELDS_TL set
    SOURCE_column_meaning = DECODE( p_source_column_meaning, FND_API.g_miss_char, source_column_meaning, p_source_column_meaning),
    LAST_UPDATE_DATE = sysdate,
    -- Modified for bug 5237401. bmuthukr
    --LAST_UPDATE_BY = FND_GLOBAL.user_id,
    last_update_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_update_by, p_last_updated_by),
    LAST_UPDATE_LOGIN = FND_GLOBAL.conc_login_id,
    SOURCE_LANG = userenv('LANG')
  where list_source_field_id = p_list_source_field_id
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

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
    p_LIST_SOURCE_FIELD_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM AMS_LIST_SRC_FIELDS
    WHERE LIST_SOURCE_FIELD_ID = p_LIST_SOURCE_FIELD_ID;
   If (SQL%NOTFOUND) then
RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;

   DELETE FROM AMS_LIST_SRC_FIELDS_TL
    WHERE LIST_SOURCE_FIELD_ID = p_LIST_SOURCE_FIELD_ID;
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
          p_list_source_field_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_de_list_source_type_code    VARCHAR2,
          p_list_source_type_id    NUMBER,
          p_field_table_name    VARCHAR2,
          p_field_column_name    VARCHAR2,
          p_source_column_name    VARCHAR2,
          p_source_column_meaning    VARCHAR2,
          p_enabled_flag    VARCHAR2,
          p_start_position    NUMBER,
          p_end_position    NUMBER,
          p_FIELD_DATA_TYPE               VARCHAR2,
          p_FIELD_DATA_SIZE               NUMBER ,
          p_DEFAULT_UI_CONTROL            VARCHAR2,
          p_FIELD_LOOKUP_TYPE             VARCHAR2,
          p_FIELD_LOOKUP_TYPE_VIEW_NAME   VARCHAR2,
          p_ALLOW_LABEL_OVERRIDE          VARCHAR2,
          p_FIELD_USAGE_TYPE              VARCHAR2,
          p_dialog_enabled                VARCHAR2,
 	  p_analytics_flag                VARCHAR2,
	  p_auto_binning_flag             VARCHAR2,
	  p_no_of_buckets                 NUMBER,
          p_attb_lov_id                   number,
          p_lov_defined_flag              varchar2,
	  p_column_type                   varchar2
)

 IS
   CURSOR C IS
        SELECT *
         FROM AMS_LIST_SRC_FIELDS
        WHERE LIST_SOURCE_FIELD_ID =  p_LIST_SOURCE_FIELD_ID
        FOR UPDATE of LIST_SOURCE_FIELD_ID NOWAIT;
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

PROCEDURE Insert_Row(
          px_list_source_field_id   IN OUT NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_de_list_source_type_code    VARCHAR2,
          p_list_source_type_id    NUMBER,
          p_field_table_name    VARCHAR2,
          p_field_column_name    VARCHAR2,
          p_source_column_name    VARCHAR2,
          p_source_column_meaning    VARCHAR2,
          p_enabled_flag    VARCHAR2,
          p_start_position    NUMBER,
          p_end_position    NUMBER,
          p_FIELD_DATA_TYPE               VARCHAR2,
          p_FIELD_DATA_SIZE               NUMBER ,
          p_DEFAULT_UI_CONTROL            VARCHAR2,
          p_FIELD_LOOKUP_TYPE             VARCHAR2,
          p_FIELD_LOOKUP_TYPE_VIEW_NAME   VARCHAR2,
          p_ALLOW_LABEL_OVERRIDE          VARCHAR2 ,
          p_FIELD_USAGE_TYPE              VARCHAR2,
          p_dialog_enabled                VARCHAR2,
	  p_analytics_flag                VARCHAR2,
	  p_auto_binning_flag             VARCHAR2,
	  p_no_of_buckets                 NUMBER,
          p_attb_lov_id                   number,
          p_lov_defined_flag              varchar2,
          p_USED_IN_LIST_ENTRIES          VARCHAR2,
          p_CHART_ENABLED_FLAG            VARCHAR2,
          p_DEFAULT_CHART_TYPE            VARCHAR2,
          p_USE_FOR_SPLITTING_FLAG        VARCHAR2,
	  p_column_type                   varchar2
)
IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := 1;


   INSERT INTO AMS_LIST_SRC_FIELDS(
           list_source_field_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           object_version_number,
           de_list_source_type_code,
           list_source_type_id,
           field_table_name,
           field_column_name,
           source_column_name,
           enabled_flag,
           start_position,
           end_position,
           FIELD_DATA_TYPE               ,
           FIELD_DATA_SIZE               ,
           DEFAULT_UI_CONTROL            ,
           FIELD_LOOKUP_TYPE             ,
           FIELD_LOOKUP_TYPE_VIEW_NAME   ,
           ALLOW_LABEL_OVERRIDE          ,
           FIELD_USAGE_TYPE              ,
           dialog_enabled                ,
    	   analytics_flag                ,
	   auto_binning_flag             ,
	   no_of_buckets                 ,
           attb_lov_id                   ,
           lov_defined_flag              ,
           USED_IN_LIST_ENTRIES          ,
           CHART_ENABLED_FLAG            ,
           DEFAULT_CHART_TYPE            ,
           USE_FOR_SPLITTING_FLAG        ,
	   column_type
   ) VALUES (
           DECODE( px_list_source_field_id, FND_API.g_miss_num, NULL, px_list_source_field_id),
           DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
           DECODE( p_de_list_source_type_code, FND_API.g_miss_char, NULL, p_de_list_source_type_code),
           DECODE( p_list_source_type_id, FND_API.g_miss_num, NULL, p_list_source_type_id),
           DECODE( p_field_table_name, FND_API.g_miss_char, NULL, p_field_table_name),
           DECODE( p_field_column_name, FND_API.g_miss_char, NULL, p_field_column_name),
           DECODE( p_source_column_name, FND_API.g_miss_char, NULL, p_source_column_name),
           DECODE( p_enabled_flag, FND_API.g_miss_char, NULL, p_enabled_flag),
           DECODE( p_start_position, FND_API.g_miss_num, NULL, p_start_position),
	   DECODE( p_end_position, FND_API.g_miss_num, NULL, p_end_position),
	   decode( p_FIELD_DATA_TYPE ,FND_API.g_miss_char,null,p_field_data_type),
	   decode( p_FIELD_DATA_SIZE ,FND_API.g_miss_num,null,p_field_data_size),
	   decode( p_DEFAULT_UI_CONTROL ,FND_API.g_miss_char,null,p_DEFAULT_UI_CONTROL ),
	   decode( p_FIELD_LOOKUP_TYPE,FND_API.g_miss_char,null,p_FIELD_LOOKUP_TYPE),
	   decode( p_FIELD_LOOKUP_TYPE_VIEW_NAME,FND_API.g_miss_char,null,p_FIELD_LOOKUP_TYPE_VIEW_NAME),
	   decode( p_ALLOW_LABEL_OVERRIDE ,FND_API.g_miss_char,null,p_ALLOW_LABEL_OVERRIDE ),
	   decode( p_FIELD_USAGE_TYPE,FND_API.g_miss_char,null,p_FIELD_USAGE_TYPE),
	   decode( p_dialog_enabled,FND_API.g_miss_char,null,p_dialog_enabled),
	   decode( p_analytics_flag,FND_API.g_miss_char,null,p_analytics_flag),
           decode( p_auto_binning_flag,FND_API.g_miss_char,null,p_auto_binning_flag),
	   decode( p_no_of_buckets,FND_API.g_miss_char,null,p_no_of_buckets),
	   decode( p_attb_lov_id,FND_API.g_miss_num,null,p_attb_lov_id),
	   decode( p_lov_defined_flag,FND_API.g_miss_char,null,p_lov_defined_flag),
	   decode( p_used_in_list_entries,FND_API.g_miss_char,null,p_used_in_list_entries),
	   decode( p_chart_enabled_flag,FND_API.g_miss_char,null,p_chart_enabled_flag),
	   decode( p_default_chart_type,FND_API.g_miss_char,null,p_default_chart_type),
	   decode( p_use_for_splitting_flag,FND_API.g_miss_char,null,p_use_for_splitting_flag),
	   decode( p_column_type,FND_API.g_miss_char,null,p_column_type)
  );

  insert into AMS_LIST_SRC_FIELDS_TL (
    LANGUAGE,
    SOURCE_LANG,
    source_column_meaning,
    LIST_SOURCE_field_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATE_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN
  ) select
    l.language_code,
    userenv('LANG'),
    DECODE( p_source_column_meaning, FND_API.g_miss_char, NULL, p_source_column_meaning),
    DECODE( px_list_source_field_id, FND_API.g_miss_num, NULL, px_list_source_field_id),
--Added for bug 5237401. bmuthukr
/*
    sysdate,
    FND_GLOBAL.user_id,
    sysdate,
    FND_GLOBAL.user_id,
*/
    DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
    DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
    DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
    DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
--
    FND_GLOBAL.conc_login_id
    from FND_LANGUAGES L
    where L.INSTALLED_FLAG in ('I', 'B')
    and not exists
    (select NULL
    from AMS_LIST_SRC_FIELDS_TL T
    where T.LIST_source_field_ID = px_LIST_SOURCE_field_ID
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
          p_list_source_field_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_de_list_source_type_code    VARCHAR2,
          p_list_source_type_id    NUMBER,
          p_field_table_name    VARCHAR2,
          p_field_column_name    VARCHAR2,
          p_source_column_name    VARCHAR2,
          p_source_column_meaning    VARCHAR2,
          p_enabled_flag    VARCHAR2,
          p_start_position    NUMBER,
          p_end_position    NUMBER,
          p_FIELD_DATA_TYPE               VARCHAR2,
          p_FIELD_DATA_SIZE               NUMBER ,
          p_DEFAULT_UI_CONTROL            VARCHAR2,
          p_FIELD_LOOKUP_TYPE             VARCHAR2,
          p_FIELD_LOOKUP_TYPE_VIEW_NAME   VARCHAR2,
          p_ALLOW_LABEL_OVERRIDE          VARCHAR2 ,
          p_FIELD_USAGE_TYPE              VARCHAR2,
          p_dialog_enabled                VARCHAR2,
 	  p_analytics_flag                VARCHAR2,
	  p_auto_binning_flag             VARCHAR2,
	  p_no_of_buckets                 NUMBER,
          p_attb_lov_id                   number,
          p_lov_defined_flag              varchar2,
          p_USED_IN_LIST_ENTRIES          VARCHAR2,
          p_CHART_ENABLED_FLAG            VARCHAR2,
          p_DEFAULT_CHART_TYPE            VARCHAR2,
          p_USE_FOR_SPLITTING_FLAG        VARCHAR2,
	  p_column_type                   varchar2
)

 IS
 BEGIN
    Update AMS_LIST_SRC_FIELDS
    SET
              list_source_field_id = DECODE( p_list_source_field_id, FND_API.g_miss_num, list_source_field_id, p_list_source_field_id),
              last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
              creation_date = DECODE( p_creation_date, FND_API.g_miss_date, creation_date, p_creation_date),
              created_by = DECODE( p_created_by, FND_API.g_miss_num, created_by, p_created_by),
              last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
              object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, 1, p_object_version_number+1 ),
              de_list_source_type_code = DECODE( p_de_list_source_type_code, FND_API.g_miss_char, de_list_source_type_code, p_de_list_source_type_code),
              list_source_type_id = DECODE( p_list_source_type_id, FND_API.g_miss_num, list_source_type_id, p_list_source_type_id),
              field_table_name = DECODE( p_field_table_name, FND_API.g_miss_char, field_table_name, p_field_table_name),
              field_column_name = DECODE( p_field_column_name, FND_API.g_miss_char, field_column_name, p_field_column_name),
              source_column_name = DECODE( p_source_column_name, FND_API.g_miss_char, source_column_name, p_source_column_name),
              enabled_flag = DECODE( p_enabled_flag, FND_API.g_miss_char, enabled_flag, p_enabled_flag),
              start_position = DECODE( p_start_position, FND_API.g_miss_num, start_position, p_start_position),
              end_position = DECODE( p_end_position, FND_API.g_miss_num, end_position, p_end_position),
              FIELD_DATA_TYPE =  decode( p_FIELD_DATA_TYPE ,FND_API.g_miss_char,FIELD_DATA_TYPE ,p_field_data_type),
              FIELD_DATA_SIZE = decode( p_FIELD_DATA_SIZE ,FND_API.g_miss_num,FIELD_DATA_SIZE,p_field_data_size),
              DEFAULT_UI_CONTROL= decode( p_DEFAULT_UI_CONTROL ,FND_API.g_miss_char,DEFAULT_UI_CONTROL,p_DEFAULT_UI_CONTROL ),
              FIELD_LOOKUP_TYPE = decode( p_FIELD_LOOKUP_TYPE,FND_API.g_miss_char,FIELD_LOOKUP_TYPE,p_FIELD_LOOKUP_TYPE),
              FIELD_LOOKUP_TYPE_VIEW_NAME = decode( p_FIELD_LOOKUP_TYPE_VIEW_NAME,FND_API.g_miss_char,FIELD_LOOKUP_TYPE_VIEW_NAME,p_FIELD_LOOKUP_TYPE_VIEW_NAME),
              ALLOW_LABEL_OVERRIDE=  decode( p_ALLOW_LABEL_OVERRIDE ,FND_API.g_miss_char,ALLOW_LABEL_OVERRIDE ,p_ALLOW_LABEL_OVERRIDE ),
              FIELD_USAGE_TYPE= decode( p_FIELD_USAGE_TYPE,FND_API.g_miss_char,FIELD_USAGE_TYPE,p_FIELD_USAGE_TYPE),
              dialog_enabled= decode( p_dialog_enabled,FND_API.g_miss_char,dialog_enabled,p_dialog_enabled),
	      analytics_flag = decode( p_analytics_flag,FND_API.g_miss_char,analytics_flag,p_analytics_flag),
	      auto_binning_flag = decode( p_auto_binning_flag,FND_API.g_miss_char,auto_binning_flag,p_auto_binning_flag),
	      no_of_buckets = decode( p_no_of_buckets,FND_API.g_miss_num,no_of_buckets,p_no_of_buckets),
	      attb_lov_id = decode( p_attb_lov_id,FND_API.g_miss_num,attb_lov_id,p_attb_lov_id),
	      lov_defined_flag = decode( p_lov_defined_flag,FND_API.g_miss_char,lov_defined_flag,p_lov_defined_flag),
	      used_in_list_entries = decode( p_used_in_list_entries,FND_API.g_miss_char,used_in_list_entries,p_used_in_list_entries),
	      chart_enabled_flag = decode( p_chart_enabled_flag,FND_API.g_miss_char,chart_enabled_flag,p_chart_enabled_flag),
	      default_chart_type = decode( p_default_chart_type,FND_API.g_miss_char,default_chart_type,p_default_chart_type),
	      use_for_splitting_flag = decode( p_use_for_splitting_flag,FND_API.g_miss_char,use_for_splitting_flag,p_use_for_splitting_flag),
              column_type = decode( p_column_type,FND_API.g_miss_char,column_type,p_column_type)
   WHERE LIST_SOURCE_FIELD_ID = p_LIST_SOURCE_FIELD_ID
   AND   object_version_number = p_object_version_number;

   IF (SQL%NOTFOUND) THEN
RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

  update AMS_LIST_SRC_FIELDS_TL set
    SOURCE_column_meaning = DECODE( p_source_column_meaning, FND_API.g_miss_char, source_column_meaning, p_source_column_meaning),
    LAST_UPDATE_DATE = sysdate,
    -- Added for bug 5237401. bmuthukr.
    --LAST_UPDATE_BY = FND_GLOBAL.user_id,
    last_update_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_update_by, p_last_updated_by),
    LAST_UPDATE_LOGIN = FND_GLOBAL.conc_login_id,
    SOURCE_LANG = userenv('LANG')
  where list_source_field_id = p_list_source_field_id
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

   IF (SQL%NOTFOUND) THEN
RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


END Update_Row;

PROCEDURE load_row (
  x_list_source_field_id IN NUMBER,
  x_de_list_source_type_code IN VARCHAR2,
  x_list_source_type_id IN NUMBER,
  x_field_table_name IN VARCHAR2,
  x_field_column_name IN VARCHAR2,
  x_source_column_name IN VARCHAR2,
  x_enabled_flag IN VARCHAR2,
  x_start_position IN NUMBER,
  x_end_position IN NUMBER,
  x_FIELD_DATA_TYPE               VARCHAR2,
  x_FIELD_DATA_SIZE               NUMBER ,
  x_DEFAULT_UI_CONTROL            VARCHAR2,
  x_FIELD_LOOKUP_TYPE             VARCHAR2,
  x_FIELD_LOOKUP_TYPE_VIEW_NAME   VARCHAR2,
  x_ALLOW_LABEL_OVERRIDE          VARCHAR2,
  x_FIELD_USAGE_TYPE              VARCHAR2,
  x_dialog_enabled                VARCHAR2,
  x_source_column_meaning IN VARCHAR2,
  x_owner IN VARCHAR2,
  x_custom_mode IN VARCHAR2,
  x_analytics_flag                VARCHAR2,
  x_auto_binning_flag             VARCHAR2,
  x_no_of_buckets                 NUMBER,
  x_attb_lov_id                   number,
  x_lov_defined_flag              varchar2,
  x_USED_IN_LIST_ENTRIES          VARCHAR2,
  x_CHART_ENABLED_FLAG            VARCHAR2,
  x_DEFAULT_CHART_TYPE            VARCHAR2,
  x_USE_FOR_SPLITTING_FLAG        VARCHAR2,
  x_column_type                   varchar2
)
IS
   l_user_id   number := 0;
   l_obj_verno  number;
   l_dummy_char  varchar2(1);
   l_row_id    varchar2(100);
   l_list_source_field_id   number;
   l_last_updated_by number;

   CURSOR  c_obj_verno IS
     SELECT object_version_number, last_updated_by
     FROM   ams_list_src_fields
     WHERE  list_source_field_id =  x_list_source_field_id;

   CURSOR c_chk_exists is
     SELECT 'x'
     FROM   ams_list_src_fields
     WHERE  list_source_field_id = x_list_source_field_id;

   CURSOR c_get_id is
      SELECT ams_list_src_fields_s.NEXTVAL
      FROM DUAL;
BEGIN
   if X_OWNER = 'SEED' then
      l_user_id := 1;
   elsif X_OWNER = 'ORACLE' then
      l_user_id := 2;
  elsif X_OWNER = 'SYSADMIN' THEN
     l_user_id := 0;
   end if;

   OPEN c_chk_exists;
   FETCH c_chk_exists INTO l_dummy_char;
   IF c_chk_exists%notfound THEN
      CLOSE c_chk_exists;

      IF x_list_source_field_id IS NULL THEN
         OPEN c_get_id;
         FETCH c_get_id INTO l_list_source_field_id;
         CLOSE c_get_id;
      ELSE
         l_list_source_field_id := x_list_source_field_id;
      END IF;

      l_obj_verno := 1;

      ams_list_src_fields_pkg.Insert_Row (
         px_list_source_field_id   => l_list_source_field_id,
         p_last_update_date    => SYSDATE,
         p_last_updated_by   => l_user_id,
         p_creation_date    => SYSDATE,
         p_created_by               => l_user_id,
         p_last_update_login        => 0,
         px_object_version_number    => l_obj_verno,
         p_de_list_source_type_code => x_de_list_source_type_code,
         p_list_source_type_id      => x_list_source_type_id,
         p_field_table_name         => x_field_table_name,
         p_field_column_name        => x_field_column_name,
         p_source_column_name       => x_source_column_name,
         p_source_column_meaning    => x_source_column_meaning,
         p_enabled_flag             => x_enabled_flag,
         p_start_position           => x_start_position,
         p_end_position             => x_end_position,
         p_FIELD_DATA_TYPE          => x_FIELD_DATA_TYPE     ,
         p_FIELD_DATA_SIZE          => x_FIELD_DATA_SIZE     ,
         p_DEFAULT_UI_CONTROL       => x_DEFAULT_UI_CONTROL  ,
         p_FIELD_LOOKUP_TYPE        => x_FIELD_LOOKUP_TYPE   ,
         p_FIELD_LOOKUP_TYPE_VIEW_NAME => x_FIELD_LOOKUP_TYPE_VIEW_NAME,
         p_ALLOW_LABEL_OVERRIDE     => x_ALLOW_LABEL_OVERRIDE     ,
         p_FIELD_USAGE_TYPE         => x_FIELD_USAGE_TYPE        ,
         p_dialog_enabled           => x_dialog_enabled,
	 p_analytics_flag           => x_analytics_flag,
         p_auto_binning_flag        => x_auto_binning_flag,
         p_no_of_buckets            => x_no_of_buckets,
         p_attb_lov_id              => x_attb_lov_id                   ,
         p_lov_defined_flag         => x_lov_defined_flag         ,
         p_USED_IN_LIST_ENTRIES     => x_USED_IN_LIST_ENTRIES    ,
         p_CHART_ENABLED_FLAG       => x_CHART_ENABLED_FLAG       ,
         p_DEFAULT_CHART_TYPE       => x_DEFAULT_CHART_TYPE        ,
         p_USE_FOR_SPLITTING_FLAG   => x_USE_FOR_SPLITTING_FLAG,
	 p_column_type              => x_column_type
      );
   ELSE
      CLOSE c_chk_exists;
      OPEN c_obj_verno;
      FETCH c_obj_verno INTO l_obj_verno  ,l_last_updated_by;
      CLOSE c_obj_verno;

 if (l_last_updated_by in (1,2,0) OR
          NVL(x_custom_mode,'PRESERVE')='FORCE') THEN


      ams_list_src_fields_pkg.Update_Row (
         p_list_source_field_id     => x_list_source_field_id,
         p_last_update_date         => SYSDATE,
         p_last_updated_by          => l_user_id,
         p_last_update_login        => 0,
         p_creation_date           => SYSDATE,
         p_created_by               => l_user_id,
         p_object_version_number    => l_obj_verno,
         p_de_list_source_type_code => x_de_list_source_type_code,
         p_list_source_type_id      => x_list_source_type_id,
         p_field_table_name         => x_field_table_name,
         p_field_column_name        => x_field_column_name,
         p_source_column_name       => x_source_column_name,
         p_enabled_flag             => x_enabled_flag,
         p_start_position           => x_start_position,
         p_end_position             => x_end_position,
         p_FIELD_DATA_TYPE          => x_FIELD_DATA_TYPE     ,
         p_FIELD_DATA_SIZE          => x_FIELD_DATA_SIZE     ,
         p_DEFAULT_UI_CONTROL       => x_DEFAULT_UI_CONTROL  ,
         p_FIELD_LOOKUP_TYPE        => x_FIELD_LOOKUP_TYPE   ,
         p_FIELD_LOOKUP_TYPE_VIEW_NAME => x_FIELD_LOOKUP_TYPE_VIEW_NAME,
         p_ALLOW_LABEL_OVERRIDE     => x_ALLOW_LABEL_OVERRIDE     ,
         p_FIELD_USAGE_TYPE         => x_FIELD_USAGE_TYPE        ,
         p_dialog_enabled           => x_dialog_enabled,
         p_source_column_meaning    => x_source_column_meaning,
	 p_analytics_flag           => x_analytics_flag,
         p_auto_binning_flag        => x_auto_binning_flag,
         p_no_of_buckets            => x_no_of_buckets,
         p_attb_lov_id              => x_attb_lov_id  ,
         p_lov_defined_flag         => x_lov_defined_flag         ,
         p_USED_IN_LIST_ENTRIES     => x_USED_IN_LIST_ENTRIES    ,
         p_CHART_ENABLED_FLAG       => x_CHART_ENABLED_FLAG       ,
         p_DEFAULT_CHART_TYPE       => x_DEFAULT_CHART_TYPE        ,
         p_USE_FOR_SPLITTING_FLAG   => x_USE_FOR_SPLITTING_FLAG,
	 p_column_type              => x_column_type
      );
    end if;
   END IF;
END load_row;

procedure TRANSLATE_ROW(
  x_list_source_field_id IN NUMBER,
  x_source_column_meaning IN VARCHAR2,
  x_owner   in VARCHAR2,
  x_custom_mode in VARCHAR2
 )  is

  cursor c_last_updated_by is
                  select last_update_by
                  FROM AMS_LIST_SRC_FIELDS_TL
                  where  list_source_field_id =  x_list_source_field_id
                  and  USERENV('LANG') = LANGUAGE;

        l_last_updated_by number;


begin

     open c_last_updated_by;
     fetch c_last_updated_by into l_last_updated_by;
     close c_last_updated_by;

     if (l_last_updated_by in (1,2,0) OR
            NVL(x_custom_mode,'PRESERVE')='FORCE') THEN

    update AMS_LIST_SRC_FIELDS_TL set
       source_column_meaning = nvl(x_source_column_meaning,
                                    source_column_meaning),
       source_lang = userenv('LANG'),
       last_update_date = sysdate,
       last_update_by = decode(x_owner, 'SEED', 1, 'ORACLE', 2, 'SYSADMIN', 0, -1),
       last_update_login = 0
    where  list_source_field_id = x_list_source_field_id
    and      userenv('LANG') in (language, source_lang);

    end if;
end TRANSLATE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AMS_LIST_SRC_FIELDS_TL T
  where not exists
    (select NULL
    from AMS_LIST_SRC_FIELDS B
    where B.LIST_SOURCE_FIELD_ID = T.LIST_SOURCE_FIELD_ID
    );

  update AMS_LIST_SRC_FIELDS_TL T set (
      SOURCE_COLUMN_MEANING
    ) = (select
      B.SOURCE_COLUMN_MEANING
    from AMS_LIST_SRC_FIELDS_TL B
    where B.LIST_SOURCE_FIELD_ID = T.LIST_SOURCE_FIELD_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.LIST_SOURCE_FIELD_ID,
      T.LANGUAGE
  ) in (select
      SUBT.LIST_SOURCE_FIELD_ID,
      SUBT.LANGUAGE
    from AMS_LIST_SRC_FIELDS_TL SUBB, AMS_LIST_SRC_FIELDS_TL SUBT
    where SUBB.LIST_SOURCE_FIELD_ID = SUBT.LIST_SOURCE_FIELD_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.SOURCE_COLUMN_MEANING <> SUBT.SOURCE_COLUMN_MEANING
      or (SUBB.SOURCE_COLUMN_MEANING is null and SUBT.SOURCE_COLUMN_MEANING is not null)
      or (SUBB.SOURCE_COLUMN_MEANING is not null and SUBT.SOURCE_COLUMN_MEANING is null)
  ));

  insert into AMS_LIST_SRC_FIELDS_TL (
    LAST_UPDATE_LOGIN,
    SOURCE_COLUMN_MEANING,
    CREATION_DATE,
    CREATED_BY,
    LIST_SOURCE_FIELD_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATE_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.LAST_UPDATE_LOGIN,
    B.SOURCE_COLUMN_MEANING,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LIST_SOURCE_FIELD_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_BY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMS_LIST_SRC_FIELDS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMS_LIST_SRC_FIELDS_TL T
    where T.LIST_SOURCE_FIELD_ID = B.LIST_SOURCE_FIELD_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

END AMS_LIST_SRC_FIELDS_PKG;

/
