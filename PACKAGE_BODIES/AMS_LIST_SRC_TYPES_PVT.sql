--------------------------------------------------------
--  DDL for Package Body AMS_LIST_SRC_TYPES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LIST_SRC_TYPES_PVT" AS
/* $Header: amsvstvb.pls 120.3 2005/06/07 11:53:44 appldev  $ */

-----------------------------------------------------------
-- PACKAGE
--   AMS_LIST_SRC_TYPES_PVT
--
-- PURPOSE
--      The purpose of this package is to creat and update the
--      views for Master list source type.
--      The following cases are handled.
--              1. Create Master view for new source type.
--              2. Update the Master view for new source type.
--              3. Create/Update the Master view in case a new
--                 Sub source type is added or deleted.
--              4. Create/Update ALL the Master view in case a new
--                 item is added/deleted from the Sub source type.
--
--
-- PROCEDURES
--
--
-- PARAMETERS
--           INPUT
--
--
--           OUTPUT
--
-- HISTORY
--      19-Apr-2001 usingh      Created.
-- ---------------------------------------------------------


-- This procedure create or updates the Master source type view.

AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

AMS_LOG_PROCEDURE_ON boolean := AMS_UTILITY_PVT.logging_enabled(FND_LOG.LEVEL_PROCEDURE);
AMS_LOG_EXCEPTION_ON boolean := AMS_UTILITY_PVT.logging_enabled(FND_LOG.LEVEL_exception);
AMS_LOG_STATEMENT_ON boolean := AMS_UTILITY_PVT.logging_enabled(FND_LOG.LEVEL_STATEMENT);

AMS_LOG_PROCEDURE constant number := FND_LOG.LEVEL_PROCEDURE;
AMS_LOG_EXCEPTION constant Number := FND_LOG.LEVEL_EXCEPTION;
AMS_LOG_STATEMENT constant Number := FND_LOG.LEVEL_STATEMENT;

G_PKG_NAME      CONSTANT VARCHAR2(30):='AMS_LIST_SRC_TYPES_PVT';
G_module_name constant varchar2(100):='oracle.apps.ams.plsql.'||g_pkg_name;

PROCEDURE master_source_type_view(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_list_source_type_id  IN NUMBER
                      ) IS

 TYPE I_LIST_SOURCE_FIELD_IDLIST       IS TABLE OF AMS_LIST_SRC_FIELDS.LIST_SOURCE_FIELD_ID%TYPE
 INDEX BY BINARY_INTEGER;

 TYPE I_COLUMN_NAME_LIST              IS TABLE OF VARCHAR2(30)
 INDEX BY BINARY_INTEGER;

 TYPE I_COLUMN_HEADING_LIST           IS TABLE OF VARCHAR2(120)
 INDEX BY BINARY_INTEGER;

 I_COLUMN_NAME          I_COLUMN_NAME_LIST;
 I_COLUMN_HEADING       I_COLUMN_HEADING_LIST;
 I_LIST_SOURCE_FIELD_ID I_LIST_SOURCE_FIELD_IDLIST;
 i_sql_string           VARCHAR2(32767);
 i_view_name            VARCHAR2(200);
 i_list_source_name     VARCHAR2(120);
 i_dup_source_name      VARCHAR2(120) := 'A';
 i_rows                 NUMBER := 1000;
 i_counter              NUMBER := 0;
 i_comma                VARCHAR2(1) := ',';
 i_exists               VARCHAR2(1);
 i_number               NUMBER := 0;
 i_mst_source           VARCHAR2(120);
 i_st_source            VARCHAR2(120);
 i_mst_exists           VARCHAR2(1);
 i_st_counter           NUMBER := 0;
 i_le_ss_type           VARCHAR2(120);
 L_SUB_SOURCE_TYPE_ID   NUMBER;
 L_FAX_SUB_SOURCE_TYPE_ID   NUMBER;
 l_total_sub_types      NUMBER;
 l_count_sub_type       NUMBER;
 l_no_of_chunks         NUMBER;


 cursor c_list_src_type_name is
        SELECT SUBSTR(REPLACE(source_type_code,' ','_'),1,20), source_type_code
	FROM ams_list_src_types --ams_list_src_types_vl
         WHERE list_source_type_id =  p_list_source_type_id;


cursor c_master is
        SELECT list_source_field_id, field_column_name, substr(replace(source_column_name,' ','_'),1,26)
          FROM ams_list_src_fields --ams_list_src_fields_vl
         WHERE list_source_type_id = p_list_source_type_id
           AND field_column_name <> 'CUSTOMER_NAME'
           AND upper(source_column_name) not in ('PARTY_ID','PARTY_NAME')
           AND nvl(enabled_flag,'Y') = 'Y';

cursor c_all_sub_types is
     SELECT distinct asa.sub_source_type_id
       FROM ams_list_src_fields asf,
            ams_list_src_type_assocs asa
      WHERE asa.master_source_type_id =  p_list_source_type_id
        AND asa.sub_source_type_id    =asf.list_source_type_id
        AND asf.field_column_name <> 'CUSTOMER_NAME'
        AND nvl(asf.enabled_flag,'Y') = 'Y'
        AND nvl(asa.enabled_flag,'Y') = 'Y'
	ORDER BY asa.SUB_SOURCE_TYPE_ID;
/* --SQL ID:11755972  Fix -- musman
 SELECT aso.SUB_SOURCE_TYPE_ID
 FROM  ams_list_src_type_assocs aso
 WHERE aso.master_source_type_id = p_list_source_type_id
   AND nvl(aso.enabled_flag,'Y') = 'Y'  -- bug:4055791:musman checking for the enabled flag of the associations
           and aso.SUB_SOURCE_TYPE_ID in (
               SELECT distinct asa.sub_source_type_id
                 FROM ams_list_src_fields_vl asf,
                      ams_list_src_type_assocs asa,
                      ams_list_src_types_vl ast
                WHERE asa.master_source_type_id = aso.master_source_type_id
                  AND asa.sub_source_type_id    = aso.SUB_SOURCE_TYPE_ID
                  AND asa.sub_source_type_id    = asf.list_source_type_id
                  AND asa.sub_source_type_id    = ast.list_source_type_id
                  AND asf.field_column_name <> 'CUSTOMER_NAME'
                  AND nvl(asa.enabled_flag,'Y') = 'Y'  -- bug:4055791:musman checking for the enabled flag of the associations
                  AND nvl(asf.enabled_flag,'Y') = 'Y')
        ORDER BY aso.SUB_SOURCE_TYPE_ID;
*/


cursor c_total_sub_types is
   SELECT count(distinct asa.sub_source_type_id)
     FROM ams_list_src_fields asf
          ,ams_list_src_type_assocs asa
    WHERE asa.master_source_type_id =  p_list_source_type_id
    AND asa.sub_source_type_id    = asf.list_source_type_id
    AND asf.field_column_name <> 'CUSTOMER_NAME'
    AND nvl(asf.enabled_flag,'Y') = 'Y'
    AND nvl(asa.enabled_flag,'Y') = 'Y';

/* SQL ID: 11755988 Fix --musman
        SELECT count(*) FROM  ams_list_src_type_assocs aso
        WHERE aso.master_source_type_id = p_list_source_type_id
          AND nvl(aso.enabled_flag,'Y') = 'Y'  -- bug:4055791:musman checking for the enabled flag of the associations
           and aso.SUB_SOURCE_TYPE_ID in (
               SELECT distinct asa.sub_source_type_id
                 FROM ams_list_src_fields_vl asf,
                      ams_list_src_type_assocs asa,
                      ams_list_src_types_vl ast
                WHERE asa.master_source_type_id = aso.master_source_type_id
                  AND asa.sub_source_type_id    = aso.SUB_SOURCE_TYPE_ID
                  AND asa.sub_source_type_id    = asf.list_source_type_id
                  AND asa.sub_source_type_id    = ast.list_source_type_id
                  AND nvl(asa.enabled_flag,'Y') = 'Y'  -- bug:4055791:musman checking for the enabled flag of the associations
                  AND asf.field_column_name <> 'CUSTOMER_NAME'
                  AND nvl(asf.enabled_flag,'Y') = 'Y');
*/


cursor c_fax_sub_types is
        SELECT list_source_type_id FROM ams_list_src_types_vl WHERE source_type_code = 'FAX';

 cursor c_sub_type is
 SELECT asf.list_source_field_id, asf.field_column_name, substr(replace(asf.source_column_name,' ','_'),1,26)||'_S'||to_char(i_number)
   FROM ams_list_src_fields asf,
        ams_list_src_type_assocs asa
  WHERE asa.master_source_type_id = p_list_source_type_id
    AND asa.sub_source_type_id    = L_SUB_SOURCE_TYPE_ID
    AND asa.sub_source_type_id    = asf.list_source_type_id
    AND asf.field_column_name <> 'CUSTOMER_NAME'
    AND nvl(asa.enabled_flag,'Y') = 'Y'
    AND nvl(asf.enabled_flag,'Y') = 'Y';
 /* SQL ID: 11756019 Fix
  SELECT asf.list_source_field_id, asf.field_column_name, substr(replace(asf.source_column_name,' ','_'),1,26)||'_S'||to_char(i_number)
          FROM ams_list_src_fields_vl asf,
               ams_list_src_type_assocs asa,
               ams_list_src_types_vl ast
         WHERE asa.master_source_type_id = p_list_source_type_id
           AND asa.sub_source_type_id    = L_SUB_SOURCE_TYPE_ID
           AND asa.sub_source_type_id    = asf.list_source_type_id
           AND asa.sub_source_type_id    = ast.list_source_type_id
           AND asf.field_column_name <> 'CUSTOMER_NAME'
           AND nvl(asa.enabled_flag,'Y') = 'Y'  --bug:4055791:musman checking for the enabled flag of the associations
           AND nvl(asf.enabled_flag,'Y') = 'Y';
        --  ORDER BY asf.source_column_name;
*/

 cursor c_count_sub_type is
   SELECT count(*)
   FROM ams_list_src_fields asf,
        ams_list_src_type_assocs asa
  WHERE asa.master_source_type_id = p_list_source_type_id
    AND asa.sub_source_type_id    = L_SUB_SOURCE_TYPE_ID
    AND asa.sub_source_type_id    = asf.list_source_type_id
    AND asf.field_column_name <> 'CUSTOMER_NAME'
    AND nvl(asf.enabled_flag,'Y') = 'Y'
    AND nvl(asa.enabled_flag,'Y') = 'Y';
/* SQL ID: 11756034 fix: musman
  SELECT count(*)
          FROM ams_list_src_fields_vl asf,
               ams_list_src_type_assocs asa,
               ams_list_src_types_vl ast
         WHERE asa.master_source_type_id = p_list_source_type_id
           AND asa.sub_source_type_id    = L_SUB_SOURCE_TYPE_ID
           AND asa.sub_source_type_id    = asf.list_source_type_id
           AND asa.sub_source_type_id    = ast.list_source_type_id
           AND asf.field_column_name <> 'CUSTOMER_NAME'
           AND nvl(asf.enabled_flag,'Y') = 'Y'
           AND nvl(asa.enabled_flag,'Y') = 'Y';  --bug:4055791:musman checking for the enabled flag of the associations
*/

/* -- looks like this cursor has not been used : musman
 cursor c_dup_st is
       SELECT COUNT(*)
          FROM ams_list_src_fields_vl asf,
               ams_list_src_type_assocs asa,
               ams_list_src_types_vl ast
         WHERE asa.master_source_type_id = p_list_source_type_id
           AND asa.sub_source_type_id    = asf.list_source_type_id
           AND asa.sub_source_type_id    = ast.list_source_type_id
           AND NVL(asf.enabled_flag,'Y') = 'Y'
           AND SUBSTR(asf.source_column_name,1,28) = i_st_source;
*/

 cursor c_master_exists is
        SELECT 'Y'
          FROM ams_list_src_fields --ams_list_src_fields_vl
         WHERE list_source_type_id = p_list_source_type_id
           AND field_column_name <> 'CUSTOMER_NAME'
                 AND upper(source_column_name) not in ('PARTY_ID','PARTY_NAME')
           AND nvl(enabled_flag,'Y') = 'Y'
           AND ROWNUM < 2;

 cursor c_sub_type_exists is
       SELECT 'Y'
          FROM ams_list_src_fields asf, --ams_list_src_fields_vl asf,
               ams_list_src_type_assocs asa
         WHERE asa.master_source_type_id = p_list_source_type_id
           AND asa.sub_source_type_id    = asf.list_source_type_id
           AND NVL(asf.enabled_flag,'Y') = 'Y'
           AND nvl(asa.enabled_flag,'Y') = 'Y'  --bug:4055791:musman checking for the enabled flag of the associations
                   AND ROWNUM < 2;

 cursor c_mst_exist is
        SELECT 'Y'
          FROM ams_list_src_fields_vl
         WHERE list_source_type_id = p_list_source_type_id
           AND nvl(enabled_flag,'Y') = 'Y'
           AND substr(source_column_name,1,28) = i_mst_source ;


  l_api_name            CONSTANT VARCHAR2(30)  := 'master_source_type_view';
  l_api_version         CONSTANT NUMBER        := 1.0;
  l_full_name           CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

 -- Status Local Variables
 l_return_status               VARCHAR2(1);  -- Return value from procedures
 l_msg_count                   NUMBER ;
 l_msg_data                    VARCHAR2(2000);


 BEGIN

   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   -- Initialize message list IF p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
   END IF;


   -- Debug Message

    IF (AMS_LOG_PROCEDURE_ON) THEN
       AMS_UTILITY_PVT.debug_message(AMS_LOG_PROCEDURE,g_module_name||'.'||l_api_name,l_full_name||':Start');
    END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN
       FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW', l_api_name||': Start', TRUE);
       FND_MSG_PUB.Add;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (AMS_LOG_STATEMENT_ON) THEN
     AMS_UTILITY_PVT.debug_message(AMS_LOG_STATEMENT,g_module_name||'.'||l_api_name,'Generating the tar views for :'||p_list_source_type_id);
   END IF;

   OPEN c_list_src_type_name;
   FETCH c_list_src_type_name into i_list_source_name, i_le_ss_type;
   CLOSE c_list_src_type_name;

   i_view_name  := 'AMS_TAR_'||i_list_source_name||'_V';
   i_sql_string := ' CREATE OR REPLACE VIEW '||i_view_name||' AS SELECT ';

   i_sql_string := i_sql_string||'LIST_ENTRY_ID LIST_ENTRY_ID  , ';
   i_sql_string := i_sql_string||'LIST_HEADER_ID LIST_HEADER_ID  , ';
   i_sql_string := i_sql_string||'LIST_SELECT_ACTION_ID LIST_SELECT_ACTION_ID  , ';
   i_sql_string := i_sql_string||'SOURCE_CODE_FOR_ID SOURCE_CODE_FOR_ID  , ';
   i_sql_string := i_sql_string||'LIST_ENTRY_SOURCE_SYSTEM_ID LIST_ENTRY_SOURCE_SYSTEM_ID  , ';
   i_sql_string := i_sql_string||'PARTY_ID PARTY_ID ,   ';
   i_sql_string := i_sql_string||'CUSTOMER_NAME PARTY_NAME ,   ';
   i_sql_string := i_sql_string||'CURR_CP_TIME_ZONE CURR_CP_TIME_ZONE ,  ';
   i_sql_string := i_sql_string||'CURR_CP_ID CURR_CP_ID  , ';
   i_sql_string := i_sql_string||'CURR_CP_COUNTRY_CODE CURR_CP_COUNTRY_CODE ,  ';
   i_sql_string := i_sql_string||'CURR_CP_INDEX CURR_CP_INDEX  , ';
   i_sql_string := i_sql_string||'CURR_CP_AREA_CODE CURR_CP_AREA_CODE ,  ';
   i_sql_string := i_sql_string||'CURR_CP_PHONE_NUMBER CURR_CP_PHONE_NUMBER ,  ';
   i_sql_string := i_sql_string||'CURR_CP_RAW_PHONE_NUMBER CURR_CP_RAW_PHONE_NUMBER ,  ';
   i_sql_string := i_sql_string||'NEXT_CALL_TIME NEXT_CALL_TIME  , ';
   i_sql_string := i_sql_string||'DO_NOT_USE_FLAG DO_NOT_USE_FLAG  , ';
   i_sql_string := i_sql_string||'CALLBACK_FLAG CALLBACK_FLAG  , ';
   i_sql_string := i_sql_string||'RECORD_OUT_FLAG RECORD_OUT_FLAG ,  ';
   i_sql_string := i_sql_string||'ENABLED_FLAG ENABLED_FLAG  , ';
   i_sql_string := i_sql_string||'NEWLY_UPDATED_flag  NEWLY_UPDATED_flag   , ';
   i_sql_string := i_sql_string||'PIN_CODE PIN_CODE  , ';
   i_sql_string := i_sql_string||'CURR_CP_TIME_ZONE_AUX CURR_CP_TIME_ZONE_AUX , ';
   i_sql_string := i_sql_string||'DO_NOT_USE_REASON DO_NOT_USE_REASON , ';
   i_sql_string := i_sql_string||'RECORD_RELEASE_TIME RECORD_RELEASE_TIME , ';
   i_sql_string := i_sql_string||'SOURCE_CODE SOURCE_CODE   ';

   i_exists := null;
   OPEN c_master_exists;
   FETCH c_master_exists into i_exists;
   CLOSE c_master_exists;
   if i_exists = 'Y' then
     i_sql_string := i_sql_string||' , ';
     OPEN c_master;
     LOOP
       FETCH c_master BULK COLLECT into I_LIST_SOURCE_FIELD_ID, I_COLUMN_NAME, I_COLUMN_HEADING LIMIT i_rows;
        EXIT when c_master%notfound;
     END LOOP;
     CLOSE c_master;

     FOR i IN I_LIST_SOURCE_FIELD_ID.FIRST..I_LIST_SOURCE_FIELD_ID.LAST
     LOOP
      i_counter := i_counter + 1;
      if I_LIST_SOURCE_FIELD_ID.LAST = i_counter then
           i_comma := ' ';
      end if;
      if I_COLUMN_NAME(i) <> 'PARTY_ID' then
         i_sql_string := i_sql_string||I_COLUMN_NAME(i)||'  '||I_COLUMN_HEADING(i)||i_comma;
      end if;
     END LOOP;
   end if;


-- ********************************88
   i_exists := null;
   OPEN c_sub_type_exists;
   FETCH c_sub_type_exists into i_exists;
   CLOSE c_sub_type_exists;
   if i_exists = 'Y' then
      i_sql_string := i_sql_string||' ,';
      I_LIST_SOURCE_FIELD_ID.DELETE;
      I_COLUMN_NAME.DELETE;
      I_COLUMN_HEADING.DELETE;
      i_counter := 0;
      i_comma := ',';

      open c_fax_sub_types;
      fetch c_fax_sub_types into L_FAX_SUB_SOURCE_TYPE_ID;
      close c_fax_sub_types;

      open c_total_sub_types;
      fetch c_total_sub_types into l_total_sub_types;
      close c_total_sub_types;

      open c_all_sub_types;
      LOOP
       fetch c_all_sub_types into L_SUB_SOURCE_TYPE_ID;
       exit when c_all_sub_types%notfound;
       i_number := i_number + 1;

       IF (AMS_LOG_STATEMENT_ON) THEN
          AMS_UTILITY_PVT.debug_message(AMS_LOG_STATEMENT,g_module_name||'.'||l_api_name,'L_SUB_SOURCE_TYPE_ID:'||L_SUB_SOURCE_TYPE_ID);
       END IF;


       OPEN c_sub_type;
       LOOP
        FETCH c_sub_type BULK COLLECT into I_LIST_SOURCE_FIELD_ID, I_COLUMN_NAME, I_COLUMN_HEADING LIMIT i_rows;
        EXIT when c_sub_type%notfound;
       END LOOP;
       CLOSE c_sub_type;

       i_counter := 0;
       FOR i IN I_LIST_SOURCE_FIELD_ID.FIRST..I_LIST_SOURCE_FIELD_ID.LAST
       LOOP
       i_counter := i_counter + 1;
       if i_number = l_total_sub_types then
         open c_count_sub_type;
         fetch c_count_sub_type into l_count_sub_type;
         close c_count_sub_type;
         if l_count_sub_type = i_counter then
            i_comma := ' ';
         end if;
       end if;
        if L_FAX_SUB_SOURCE_TYPE_ID = L_SUB_SOURCE_TYPE_ID then
           if I_COLUMN_HEADING(i) = 'PHONE_NUMBER'||'_S'||to_char(i_number) then
              I_COLUMN_HEADING(i) := 'FAX_'||I_COLUMN_HEADING(i);
           end if;
           if I_COLUMN_HEADING(i) = 'PHONE_AREA_CODE'||'_S'||to_char(i_number)  then
              I_COLUMN_HEADING(i) := 'FAX_'||I_COLUMN_HEADING(i);
           end if;
           if I_COLUMN_HEADING(i) = 'PHONE_COUNTRY_CODE'||'_S'||to_char(i_number)  then
              I_COLUMN_HEADING(i) := 'FAX_'||I_COLUMN_HEADING(i);
           end if;
        end if;
        i_sql_string := i_sql_string||I_COLUMN_NAME(i)||'  '||I_COLUMN_HEADING(i)||i_comma;
       END LOOP;

      END LOOP;  -- for c_all_sub_types cursor
      close c_all_sub_types;
   end if;  -- if i_exists = 'Y' then

   i_sql_string := i_sql_string||' FROM AMS_LIST_ENTRIES WHERE LIST_ENTRY_SOURCE_SYSTEM_TYPE = '||''''||i_le_ss_type||'''';
   IF (AMS_LOG_STATEMENT_ON) THEN
     l_no_of_chunks  := ceil(length(i_sql_string)/2000 );
     for i in 1 ..l_no_of_chunks
     loop
        AMS_UTILITY_PVT.debug_message(AMS_LOG_STATEMENT,G_module_name||'.'||l_api_name,substr(i_sql_string,(2000*i) - 1999,2000));
     end loop;
   END IF;
   EXECUTE IMMEDIATE i_sql_string;
/*
  exception
     when others then
         raise;
*/
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
   THEN
      FND_MESSAGE.Set_Name('AMS', 'API_SUCCESS');
       FND_MESSAGE.Set_Token('ROW', l_api_name, TRUE);
      FND_MSG_PUB.Add;
   END IF;


   IF (AMS_DEBUG_HIGH_ON) THEN
      FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('ROW', l_api_name||': END', TRUE);
      FND_MSG_PUB.Add;
   END IF;

   IF (AMS_LOG_PROCEDURE_ON) THEN
     AMS_UTILITY_PVT.debug_message(AMS_LOG_PROCEDURE,g_module_name||'.'||l_api_name,l_full_name||': END ');
   END IF;

   -- Standard call to get message count AND IF count is 1, get message info.
   FND_MSG_PUB.Count_AND_Get
          ( p_count           =>      x_msg_count,
            p_data            =>      x_msg_data,
            p_encoded     =>      FND_API.G_FALSE
          );

   IF (AMS_LOG_PROCEDURE_ON) THEN
     AMS_UTILITY_PVT.debug_message(AMS_LOG_PROCEDURE,g_module_name||'.'||l_api_name,'$$$$$$$$$: END :$$$$$$');
   END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      IF (AMS_LOG_PROCEDURE_ON) THEN
        AMS_UTILITY_PVT.debug_message(AMS_LOG_PROCEDURE,g_module_name||'.'||l_api_name,' execution ERROR has been raised ');
      END IF;

       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_AND_Get
       ( p_count           =>      x_msg_count,
         p_data            =>      x_msg_data,
         p_encoded         =>      FND_API.G_FALSE
       );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (AMS_LOG_PROCEDURE_ON) THEN
        AMS_UTILITY_PVT.debug_message(AMS_LOG_PROCEDURE,g_module_name||'.'||l_api_name,' Unexpected error has been raised ');
      END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_AND_Get
       ( p_count           =>      x_msg_count,
         p_data            =>      x_msg_data,
         p_encoded     =>      FND_API.G_FALSE
       );


   WHEN OTHERS THEN


      IF (AMS_LOG_PROCEDURE_ON) THEN
        AMS_UTILITY_PVT.debug_message(AMS_LOG_PROCEDURE,g_module_name||'.'||l_api_name,' In Others exception handling ');
      END IF;

      IF (AMS_LOG_EXCEPTION_ON) THEN
        AMS_UTILITY_PVT.debug_message(AMS_LOG_EXCEPTION,g_module_name||'.'||l_api_name,'SQLCODE:' || SQLCODE || ' SQLERRM: ' || SQLERRM);
      END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
       THEN
               FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;

       FND_MSG_PUB.Count_AND_Get
       ( p_count           =>      x_msg_count,
         p_data            =>      x_msg_data,
         p_encoded         =>      FND_API.G_FALSE
       );

 END master_source_type_view;

PROCEDURE update_all_master_views(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_list_source_type_id  IN NUMBER
                      ) IS

 i_master_source_type_id        NUMBER;

 cursor c_all_master is
        SELECT master_source_type_id
        FROM ams_list_src_type_assocs
        WHERE sub_source_type_id = p_list_source_type_id
         -- AND enabled_flag = 'Y'     --we have to re-generate the parent after assoc is disabled
          AND master_source_type_id in (14,30)  ; --- only if the master is person or organization contact

 l_api_name            CONSTANT VARCHAR2(30)  := 'master_source_type_view';
 l_api_version         CONSTANT NUMBER        := 1.0;
 l_full_name           CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

 -- Status Local Variables
 l_return_status               VARCHAR2(1);  -- Return value from procedures
 l_msg_count                   NUMBER ;
 l_msg_data                    VARCHAR2(2000);


begin
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   -- Initialize message list IF p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN
       FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW', l_api_name||': Start', TRUE);
       FND_MSG_PUB.Add;
   END IF;

    IF (AMS_LOG_PROCEDURE_ON) THEN
       AMS_UTILITY_PVT.debug_message(AMS_LOG_PROCEDURE,g_module_name||'.'||l_api_name,l_full_name||':Start');
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
 OPEN c_all_master;
 LOOP
   FETCH c_all_master into i_master_source_type_id;
   EXIT when c_all_master%notfound;
   master_source_type_view(l_api_version,
                           FND_API.G_FALSE,
                           FND_API.G_VALID_LEVEL_FULL,
                           x_return_status,
                           x_msg_count,
                           x_msg_data,
                           i_master_source_type_id);

   IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   ELSIF x_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   END IF;
 END LOOP;
 CLOSE c_all_master;

/*
  exception
     when others then
         raise;
*/
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
   THEN
      FND_MESSAGE.Set_Name('AMS', 'API_SUCCESS');
      FND_MESSAGE.Set_Token('ROW', l_Api_name, TRUE);
      FND_MSG_PUB.Add;
   END IF;


   IF (AMS_DEBUG_HIGH_ON) THEN
      FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('ROW', l_api_name||': END', TRUE);
      FND_MSG_PUB.Add;
   END IF;

   IF (AMS_LOG_PROCEDURE_ON) THEN
     AMS_UTILITY_PVT.debug_message(AMS_LOG_PROCEDURE,g_module_name||'.'||l_api_name,l_full_name||': END ');
   END IF;

   -- Standard call to get message count AND IF count is 1, get message info.
   FND_MSG_PUB.Count_AND_Get
          ( p_count           =>      x_msg_count,
            p_data            =>      x_msg_data,
            p_encoded     =>      FND_API.G_FALSE
          );

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR ;

      IF (AMS_LOG_PROCEDURE_ON) THEN
        AMS_UTILITY_PVT.debug_message(AMS_LOG_PROCEDURE,g_module_name||'.'||l_api_name,' execution ERROR has been raised ');
      END IF;

       FND_MSG_PUB.Count_AND_Get
       ( p_count           =>      x_msg_count,
         p_data            =>      x_msg_data,
         p_encoded         =>      FND_API.G_FALSE
       );
       IF c_all_master%ISOPEN THEN
          CLOSE c_all_master;
       END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (AMS_LOG_PROCEDURE_ON) THEN
        AMS_UTILITY_PVT.debug_message(AMS_LOG_PROCEDURE,g_module_name||'.'||l_api_name,' Unexpected error has been raised ');
      END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_AND_Get
       ( p_count           =>      x_msg_count,
         p_data            =>      x_msg_data,
         p_encoded     =>      FND_API.G_FALSE
       );
       IF c_all_master%ISOPEN THEN
          CLOSE c_all_master;
       END IF;


   WHEN OTHERS THEN

      IF (AMS_LOG_PROCEDURE_ON) THEN
        AMS_UTILITY_PVT.debug_message(AMS_LOG_PROCEDURE,g_module_name||'.'||l_api_name,' In Others exception handling ');
      END IF;

      IF (AMS_LOG_EXCEPTION_ON) THEN
        AMS_UTILITY_PVT.debug_message(AMS_LOG_EXCEPTION,g_module_name||'.'||l_api_name,'SQLCODE:' || SQLCODE || ' SQLERRM: ' || SQLERRM);
      END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
       THEN
               FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       IF c_all_master%ISOPEN THEN
          CLOSE c_all_master;
       END IF;


       FND_MSG_PUB.Count_AND_Get
       ( p_count           =>      x_msg_count,
         p_data            =>      x_msg_data,
         p_encoded         =>      FND_API.G_FALSE
       );

end update_all_master_views;



PROCEDURE process_views(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
     p_list_source_type_id       IN  NUMBER
                      ) IS

 i_list_source_type     VARCHAR2(30);
 i_master_flag          VARCHAR2(1);

 l_api_name            CONSTANT VARCHAR2(30)  := 'process_views';
 l_api_version         CONSTANT NUMBER        := 1.0;
 l_full_name           CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
 -- Status Local Variables
 l_return_status               VARCHAR2(1);  -- Return value from procedures

 cursor c_source_type is
        SELECT list_source_type, master_source_type_flag FROM ams_list_src_types_vl
         WHERE list_source_type_id = p_list_source_type_id;


begin


   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   -- Initialize message list IF p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON)  THEN
       FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW', l_api_name||': Start', TRUE);
       FND_MSG_PUB.Add;
   END IF;


   IF (AMS_LOG_PROCEDURE_ON) THEN
       AMS_UTILITY_PVT.debug_message(AMS_LOG_PROCEDURE,g_module_name||'.'||l_api_name,l_full_name||':Start');
       AMS_UTILITY_PVT.debug_message(AMS_LOG_PROCEDURE,g_module_name||'.'||l_api_name,'Passed in List Source Type Id is:'||p_list_source_type_id);
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN  c_source_type;
   FETCH c_source_type into i_list_source_type, i_master_flag;
   CLOSE c_source_type;

   if i_list_source_type = 'TARGET' then
     IF i_master_flag = 'Y'
     AND (p_list_source_type_id = 14 OR p_list_source_type_id = 30) ---person or organization contact
     THEN
        IF (AMS_LOG_STATEMENT_ON) THEN
           AMS_UTILITY_PVT.debug_message(AMS_LOG_STATEMENT,g_module_name||'.'||l_api_name,'calling the master_source_type_view');
        END IF;

        master_source_type_view(
          l_api_version,
          FND_API.G_FALSE,
          FND_API.G_VALID_LEVEL_FULL,
          x_return_status,
          x_msg_count,
          x_msg_data,
          p_list_source_type_id);

     else
        IF (AMS_LOG_STATEMENT_ON) THEN
           AMS_UTILITY_PVT.debug_message(AMS_LOG_STATEMENT,g_module_name||'.'||l_api_name,'calling the update_all_master_views');
        END IF;

        update_all_master_views(
          l_api_version,
          FND_API.G_FALSE,
          FND_API.G_VALID_LEVEL_FULL,
          x_return_status,
          x_msg_count,
          x_msg_data,
          p_list_source_type_id);

     end if;

     IF (AMS_LOG_STATEMENT_ON) THEN
        AMS_UTILITY_PVT.debug_message(AMS_LOG_STATEMENT,g_module_name||'.'||l_api_name,'Return Status is:'||x_return_status);
     END IF;

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS
     THEN
        AMS_UTILITY_PVT.debug_message('Error Generating the tar views');
        FND_MESSAGE.set_name('AMS', 'AMS_ERR_LIST_GEN_TAR_VIEW');
        FND_MSG_PUB.Add;
        RAISE FND_API.g_exc_error;
     END IF;

   END IF;


   /* -- commented out old code.
     if i_master_flag = 'Y' then
        master_source_type_view(p_list_source_type_id);
      else
        update_all_master_views(p_list_source_type_id);
     end if;
   end if;


  exception
    when others then
         raise;
*/
   -- Success Message
   -- MMSG
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
   THEN
      FND_MESSAGE.Set_Name('AMS', 'API_SUCCESS');
       FND_MESSAGE.Set_Token('ROW', l_api_name, TRUE);
      FND_MSG_PUB.Add;
   END IF;


   IF (AMS_DEBUG_HIGH_ON) THEN
      FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('ROW', l_api_name||': END', TRUE);
      FND_MSG_PUB.Add;
   END IF;

   IF (AMS_LOG_PROCEDURE_ON) THEN
     AMS_UTILITY_PVT.debug_message(AMS_LOG_PROCEDURE,g_module_name||'.'||l_api_name,l_full_name||': END ');
   END IF;


   -- Standard call to get message count AND IF count is 1, get message info.
   FND_MSG_PUB.Count_AND_Get
          ( p_count           =>      x_msg_count,
            p_data            =>      x_msg_data,
            p_encoded     =>      FND_API.G_FALSE
          );

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      IF (AMS_LOG_PROCEDURE_ON) THEN
        AMS_UTILITY_PVT.debug_message(AMS_LOG_PROCEDURE,g_module_name||'.'||l_api_name,' execution ERROR has been raised ');
      END IF;

       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_AND_Get
       ( p_count           =>      x_msg_count,
         p_data            =>      x_msg_data,
         p_encoded         =>      FND_API.G_FALSE
       );


   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      IF (AMS_LOG_PROCEDURE_ON) THEN
        AMS_UTILITY_PVT.debug_message(AMS_LOG_PROCEDURE,g_module_name||'.'||l_api_name,' Unexpected error has been raised ');
      END IF;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_AND_Get
       ( p_count           =>      x_msg_count,
         p_data            =>      x_msg_data,
         p_encoded     =>      FND_API.G_FALSE
       );

   WHEN OTHERS THEN

      IF (AMS_LOG_PROCEDURE_ON) THEN
        AMS_UTILITY_PVT.debug_message(AMS_LOG_PROCEDURE,g_module_name||'.'||l_api_name,' In Others exception handling ');
      END IF;

      IF (AMS_LOG_EXCEPTION_ON) THEN
        AMS_UTILITY_PVT.debug_message(AMS_LOG_EXCEPTION,g_module_name||'.'||l_api_name,'SQLCODE:' || SQLCODE || ' SQLERRM: ' || SQLERRM);
      END IF;


       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
       THEN
               FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;

       FND_MSG_PUB.Count_AND_Get
       ( p_count           =>      x_msg_count,
         p_data            =>      x_msg_data,
         p_encoded         =>      FND_API.G_FALSE
       );
end process_views;

end AMS_LIST_SRC_TYPES_PVT;

/
