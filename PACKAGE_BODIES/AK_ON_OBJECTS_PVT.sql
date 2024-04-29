--------------------------------------------------------
--  DDL for Package Body AK_ON_OBJECTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AK_ON_OBJECTS_PVT" as
/* $Header: akdvonb.pls 120.6.12010000.2 2016/07/08 14:24:09 tshort ship $ */

--
-- Type definitions (only used within this package body)
--
-- Table containing the index numbers within the PL/SQL table in which
-- the first line of a certain business object type begins.
--
TYPE Index_Tbl_Type IS TABLE OF NUMBER
	INDEX BY BINARY_INTEGER;

--
-- global variables within this package body
--
G_buffer_tbl       AK_ON_OBJECTS_PUB.Buffer_Tbl_Type;

--==============================================
--  Procedure   REPLACE_ESCAPED_CHARS (local procedure)
--
--  Usage       Local procedure for replacing all escaped characters.
--              Not designed to be called from outside this package.
--
--  Desc        Replaces all escaped characters in the input string
--              such as \\ with their original characters.
--
--  Results     The procedure returns a string which is the result of
--              replacing all escaped characters with their original
--              characters.
--  Parameters  p_buffer : IN required
--                  The input string with escaped characters.
--==============================================
function REPLACE_ESCAPED_CHARS (
  p_buffer IN varchar2
) return varchar2 is
  l_buffer    AK_ON_OBJECTS_PUB.Buffer_Type;
begin
  l_buffer := REPLACE(p_buffer, '\"', '"');
  l_buffer := REPLACE(l_buffer, '\t', '	');   /* tab */
  l_buffer := REPLACE(l_buffer, '\n', '
');  /* newline - this is on the next line because the new line character
                  is included in the quotes*/
  l_buffer := REPLACE(l_buffer, '\\', '\');
  return l_buffer;
end REPLACE_ESCAPED_CHARS;

--==============================================
--  Function   REPLACE_SPECIAL_CHARS
--
--  Usage       Private function for replacing all special characters
--              with escaped characters.
--              This function is intended to be called only by other APIs
--              that are owned by the Core Modules Team (AK)
--
--  Desc        Replaces all special characters in the input string
--              with the corresponding escaped characters, for instance,
--              the 'tab' character will be replaced by '\t'.
--
--  Results     The procedure returns a string which is the result of
--              replacing all special characters with their corresponding
--              escaped characters.
--  Parameters  p_buffer : IN required
--                  The input string with special characters.
--==============================================
function REPLACE_SPECIAL_CHAR (
  p_buffer                  IN      VARCHAR2
) return VARCHAR2 is
  l_api_version_number      CONSTANT number := 1.0;
  l_api_name                CONSTANT varchar2(30) := 'Replace_Special_Char';
  l_buffer                  AK_ON_OBJECTS_PUB.Buffer_Type;
begin

  if (p_buffer is null) then
    return null;
  end if;

  --
  -- Add preceding backslash to special characters
  --
  l_buffer := REPLACE(p_buffer, '\', '\\');      /* backslash */
  l_buffer := REPLACE(l_buffer, '	', '\t');   /* tabs */
  l_buffer := REPLACE(l_buffer, '
', '\n');  /* newline  - this is on the next line because the new line character
                  is included in the quotes */
  return REPLACE(l_buffer, '"', '\"');           /* quote */

END REPLACE_SPECIAL_CHAR;

--==============================================
--  Procedure   APPEND_BUFFER_TABLES
--
--  Usage       Private procedure for appending one buffer table to the
--              end of another buffer table.
--              This procedure is intended to be called only by other APIs
--              that are owned by the Core Modules Team (AK)
--
--  Desc        Appends all elements in the from_table to the end of the
--              to_table. Both tables must be of type Buffer_Tbl_Type.
--
--  Results     The procedure returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_from_table : IN required
--                  The from buffer table containing elements to be
--                  appended to the end of the to buffer table.
--              p_to_table : IN OUT
--                  The target buffer table which will have the elements
--                  in the from table appended to it.
--==============================================
procedure APPEND_BUFFER_TABLES (
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_from_table               IN      AK_ON_OBJECTS_PUB.Buffer_Tbl_Type,
  p_to_table                 IN OUT NOCOPY  AK_ON_OBJECTS_PUB.Buffer_Tbl_Type
) is
  l_api_name                CONSTANT varchar2(30) := 'Append_Buffer_Tables';
  l_from_index   NUMBER;
  l_to_index     NUMBER;
begin
  --
  -- Return if from table is empty
  --
  if (p_from_table.count = 0) then
    p_return_status := FND_API.G_RET_STS_SUCCESS;
    return;
  end if;

  l_to_index := nvl(p_to_table.LAST, 0) + 1;

  for l_from_index in p_from_table.FIRST .. p_from_table.LAST LOOP
    if (p_from_table.EXISTS(l_from_index)) then
      p_to_table(l_to_index) := p_from_table(l_from_index);
      l_to_index := l_to_index + 1;
    end if;
  end loop;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
end APPEND_BUFFER_TABLES;

--==============================================
--  Procedure   DOWNLOAD_HEADER
--
--  Usage       Private procedure for writing standard header information
--              to a loader file.
--              This procedure is intended to be called only by other APIs
--              that are owned by the Core Modules Team (AK)
--
--  Desc        This procedure writes all the standard header information
--              including the DEFINE section to the loader file.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_nls_language : IN optional
--                  The NLS language of the database. If this is omitted,
--                  the default NLS language defined in the database
--                  will be used.
--              p_application_id : IN optional
--                  The application ID to be used to extract data from
--                  the database. If p_application_id is omitted, then
--                  either p_application_short_name must be given, or
--                  p_table_size must be greater than 0.
--              p_application_short_name : IN optional
--                  The application short name to be used to extract data
--                  from the database. If p_application_short_name is
--                  not provided, then either p_application_id must be
--                  given, or p_table_size must be greater than 0.
--                  p_application_short_name will be ignored if
--                  p_application_id is given.
--              p_table_size : IN required
--                  The size of the PL/SQL table containing the list of
--                  flows, objects, regions, or attributes to be extracted
--                  from the database. If p_table_size is 0, then either
--                  p_application_id or p_application_short_name must
--                  be provided.
--              p_download_by_object : IN required
--                  Must be one of the following literal defined in
--                  AK_ON_OBJECTS_PVT package:
--                    G_ATTRIBUTE - Caller is DOWNLOAD_ATTRIBUTE API
--                    G_OBJECT    - Caller is DOWNLOAD_OBJECT API
--                    G_REGION    - Caller is DOWNLOAD_REGION API
--                    G_FLOW      - Caller is DOWNLOAD_FLOW API
--                  This parameter is used to determine which portions
--                  of the DEFINE section should be written to the file.
--              p_nls_language_out : OUT
--                  This parameter will be loaded with p_nls_language if
--                  one is given, or with the default NLS language in the
--                  database if p_nls_language is not provided.
--              p_application_id_out : OUT
--                  This parameter will be loaded with p_application_id if
--                  one is given, or with the application ID of the
--                  p_application_short_name parameter if no application ID
--                  is provided. If both p_application_short_name and
--                  p_application_id are not given, the p_application_id_out
--                  will be null.
--==============================================
procedure DOWNLOAD_HEADER (
  p_validation_level        IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number      IN      NUMBER,
  p_return_status           OUT NOCOPY     VARCHAR2,
  p_nls_language            IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_application_id          IN      NUMBER := FND_API.G_MISS_NUM,
  p_application_short_name  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_table_size              IN      NUMBER,
  p_download_by_object      IN      VARCHAR2,
  p_nls_language_out        OUT NOCOPY     VARCHAR2,
  p_application_id_out      OUT NOCOPY     NUMBER
) is
  cursor l_get_appl_id_csr (short_name_param varchar2) is
  select application_id
  from   fnd_application_vl
  where  application_short_name = short_name_param;
  l_api_version_number CONSTANT number := 1.0;
  l_api_name           CONSTANT varchar2(30) := 'Download_Header';
  l_application_id number;
  l_header_tbl     AK_ON_OBJECTS_PUB.Buffer_Tbl_Type;
  l_index          NUMBER;
  l_nls_language   VARCHAR2(30);
  l_return_status  varchar2(1);
  l_sub_phase      varchar2(2);
  l_dbname	   varchar2(8);
begin
  --
  -- Check verion number
  --
  IF NOT FND_API.Compatible_API_Call (
    l_api_version_number, p_api_version_number, l_api_name,
    G_PKG_NAME) then
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return;
  END IF;

  --
  -- Either p_aplication_short_name, p_application_id, or a table with
  -- a list of attributes/regions/objects/flows to be extracted from
  -- the database must be provided
  --

  if ((p_application_short_name = FND_API.G_MISS_CHAR) or
      (p_application_short_name is null)) and
     ((p_application_id = FND_API.G_MISS_NUM) or
      (p_application_id is null)) and
     (p_table_size = 0)  then
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.SET_NAME('AK','AK_NO_SELECTION');
        FND_MSG_PUB.Add;
      end if;
      raise FND_API.G_EXC_ERROR;
  end if;

  --
  -- - Load l_application_id
  -- if an application short name is passed and no application ID is
  -- given, find the application ID from the application short name
  --
  l_application_id := p_application_id;

  if (p_application_short_name <> FND_API.G_MISS_CHAR) then

    -- /** Since we pass appl short name only from Java wrapper, this
	-- meesage is not necessary **/
    --if (p_application_id <> FND_API.G_MISS_NUM) then
      --if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      --  FND_MESSAGE.SET_NAME('AK','AK_APPL_SHORT_NAME_IGNORED');
      --  FND_MSG_PUB.Add;
      --end if;
    --else
	-- /***********************************************/
	if (p_application_id = FND_API.G_MISS_NUM) then
      open l_get_appl_id_csr(p_application_short_name);
      fetch l_get_appl_id_csr into l_application_id;
      if (l_get_appl_id_csr%notfound) then
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_APPL_SHORT_NAME_INVALID');
          FND_MESSAGE.SET_TOKEN('APPL_SHORT_NAME', p_application_short_name);
          FND_MSG_PUB.Add;
        end if;
        close l_get_appl_id_csr;
        raise FND_API.G_EXC_ERROR;
      end if;
      close l_get_appl_id_csr;
    end if;
  end if;

  --
  -- If no LANGUAGE CODE is given, use the default language code
  --
  if ((p_nls_language = FND_API.G_MISS_CHAR) or
      (p_nls_language is null)) then

      select userenv('LANG') into l_nls_language
      from dual;

  else
      l_nls_language := p_nls_language;
  end if;

  select sys_context('userenv','db_name') into l_dbname from dual;

  -- determine sub-phase
  --
  if ( p_download_by_object = AK_ON_OBJECTS_PVT.G_REGION ) then
    l_sub_phase := '24';
  elsif ( p_download_by_object = AK_ON_OBJECTS_PVT.G_FLOW or p_download_by_object = AK_ON_OBJECTS_PVT.G_SECURITY) then
    l_sub_phase := '20';
  elsif ( p_download_by_object = AK_ON_OBJECTS_PVT.G_ATTRIBUTE ) then
    l_sub_phase := '16';
  elsif ( p_download_by_object = AK_ON_OBJECTS_PVT.G_CUSTOM_REGION ) then
    l_sub_phase := '25';
  end if;

  --
  -- - Load file header information such as nls_language and
  --   codeset
  --
  l_index := 1;
  l_header_tbl(l_index) := '# Object Navigator Definition File';

  l_index := l_index + 1;
  l_header_tbl(l_index) := '#';

  l_index := l_index + 1;
  l_header_tbl(l_index) := '# $Hea' || 'der: $';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '# dbdrv: exec java oracle/apps/ak akload.class java '||'&'||'phase=dat+'||l_sub_phase||' \ ';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '# dbdrv: checkfile:~PROD:~PATH:~FILE '||'&'||'un_apps \';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '# dbdrv: '||'&'||'pw_apps '||'&'||'jdbc_protocol '||'&'||'jdbc_db_addr UPLOAD \';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '# dbdrv: '||'&'||'fullpath_~PROD_~PATH_~FILE NCUPDATE '||'&'||'env=NLS_LANG';

  l_index := l_index + 1;
  l_header_tbl(l_index) := '# Generated on ' ||
                           to_char(sysdate, 'YY/MM/DD HH24:MI:SS');

  l_index := l_index + 1;
  l_header_tbl(l_index) := '# Source Database ' || l_dbname;

  l_index := l_index + 1;
  l_header_tbl(l_index) := '#';

  l_index := l_index + 1;
  l_header_tbl(l_index) := 'LANGUAGE = "' || l_nls_language || '"';

-- commented out because it's now supporting multiple appl_id
--
--  l_index := l_index + 1;
--  l_header_tbl(l_index) := 'EXTRACT_BY_APPLICATION = ';
--  if (p_table_size = 0) then
--    l_header_tbl(l_index) := l_header_tbl(l_index) ||
--                             to_char(l_application_id);
--  else
--    l_header_tbl(l_index) := l_header_tbl(l_index) || '""';
--  end if;

  l_index := l_index + 1;
  l_header_tbl(l_index) := 'EXTRACT_BY_OBJECT = "' ||
                            p_download_by_object || '"';

  l_index := l_index + 1;
  l_header_tbl(l_index) := 'FILE_FORMAT_VERSION = '||to_char(AK_ON_OBJECTS_PUB.G_FILE_FORMAT_VER);

  --
  -- DEFINE section
  --
  -- Check if the Object type is valid values
  l_index := l_index + 1;
  l_header_tbl(l_index) := ' ';

  if (p_download_by_object in (AK_ON_OBJECTS_PVT.G_OBJECT,
           AK_ON_OBJECTS_PVT.G_REGION, AK_ON_OBJECTS_PVT.G_CUSTOM_REGION,
           AK_ON_OBJECTS_PVT.G_FLOW, AK_ON_OBJECTS_PVT.G_ATTRIBUTE)) then

  l_index := l_index + 1;
  l_header_tbl(l_index) := 'DEFINE ATTRIBUTE ';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  KEY ATTRIBUTE_APPLICATION_ID NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  KEY ATTRIBUTE_CODE VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  CTX ATTRIBUTE_LABEL_LENGTH NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE_VALUE_LENGTH NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE BOLD VARCHAR2(1)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ITALIC VARCHAR2(1)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE VERTICAL_ALIGNMENT VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE HORIZONTAL_ALIGNMENT VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE DATA_TYPE VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE UPPER_CASE_FLAG VARCHAR2(1)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE DEFAULT_VALUE_VARCHAR2 VARCHAR2(240)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE DEFAULT_VALUE_NUMBER NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE DEFAULT_VALUE_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE LOV_REGION REFERENCES REGION';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ITEM_STYLE VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE DISPLAY_HEIGHT NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE CSS_CLASS_NAME VARCHAR2(80)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE POPLIST_VIEWOBJECT VARCHAR2(240)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE POPLIST_DISPLAY_ATTRIBUTE VARCHAR2(80)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE POPLIST_VALUE_ATTRIBUTE VARCHAR2(80)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE CSS_LABEL_CLASS_NAME VARCHAR2(80)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE PRECISION NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  CTX EXPANSION NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  CTX ALS_MAX_LENGTH NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE_CATEGORY VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE1 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE2 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE3 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE4 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE5 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE6 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE7 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE8 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE9 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE10 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE11 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE12 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE13 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE14 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE15 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE CREATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE CREATION_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE LAST_UPDATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  CTX OWNER VARCHAR2(4000)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE LAST_UPDATE_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE LAST_UPDATE_LOGIN NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE NAME VARCHAR2(80)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  TRANS ATTRIBUTE_LABEL_LONG VARCHAR2(80)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  TRANS ATTRIBUTE_LABEL_SHORT VARCHAR2(40)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  TRANS DESCRIPTION VARCHAR2(2000)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := 'END ATTRIBUTE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := ' ';

  -- Check if the Object type is valid values
  if (p_download_by_object in (AK_ON_OBJECTS_PVT.G_OBJECT,
           AK_ON_OBJECTS_PVT.G_REGION, AK_ON_OBJECTS_PVT.G_CUSTOM_REGION,
	   AK_ON_OBJECTS_PVT.G_FLOW)) then
  l_index := l_index + 1;
  l_header_tbl(l_index) := 'DEFINE OBJECT';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  KEY DATABASE_OBJECT_NAME VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE APPLICATION_ID NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE PRIMARY_KEY_NAME REFERENCES UNIQUE_KEY';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE DEFAULTING_API_PKG VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE DEFAULTING_API_PROC VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE VALIDATION_API_PKG VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE VALIDATION_API_PROC VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE_CATEGORY VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE1 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE2 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE3 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE4 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE5 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE6 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE7 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE8 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE9 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE10 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE11 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE12 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE13 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE14 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE15 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE CREATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE CREATION_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE LAST_UPDATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  CTX OWNER VARCHAR2(4000)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE LAST_UPDATE_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE LAST_UPDATE_LOGIN NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  TRANS NAME VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  TRANS DESCRIPTION VARCHAR2(2000)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := ' ';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  DEFINE OBJECT_ATTRIBUTE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    KEY OBJECT_ATTRIBUTE_PK REFERENCES ATTRIBUTE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE COLUMN_NAME VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE_LABEL_LENGTH NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE DISPLAY_VALUE_LENGTH NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE BOLD VARCHAR2(1)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ITALIC VARCHAR2(1)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE VERTICAL_ALIGNMENT VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE HORIZONTAL_ALIGNMENT VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE DATA_SOURCE_TYPE VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE DATA_STORAGE_TYPE VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE TABLE_NAME VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE BASE_TABLE_COLUMN_NAME VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE REQUIRED_FLAG VARCHAR2(1)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE DEFAULT_VALUE_VARCHAR2 VARCHAR2(240)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE DEFAULT_VALUE_NUMBER NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE DEFAULT_VALUE_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE LOV_REGION REFERENCES REGION';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE LOV_FOREIGN_KEY_NAME REFERENCES FOREIGN_KEY';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE LOV_ATTRIBUTE REFERENCES ATTRIBUTE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE DEFAULTING_API_PKG VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE DEFAULTING_API_PROC VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE VALIDATION_API_PKG VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE VALIDATION_API_PROC VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE_CATEGORY VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE1 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE2 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE3 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE4 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE5 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE6 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE7 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE8 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE9 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE10 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE11 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE12 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE13 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE14 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE15 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE CREATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE CREATION_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE LAST_UPDATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    CTX OWNER VARCHAR2(4000)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE LAST_UPDATE_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE LAST_UPDATE_LOGIN NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    TRANS ATTRIBUTE_LABEL_LONG VARCHAR2(80)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    TRANS ATTRIBUTE_LABEL_SHORT VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := ' ';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    DEFINE ATTRIBUTE_NAVIGATION';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      KEY VALUE_VARCHAR2 VARCHAR2(240)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      KEY VALUE_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      KEY VALUE_NUMBER NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE TO_REGION REFERENCES REGION';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE_CATEGORY VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE1 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE2 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE3 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE4 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE5 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE6 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE7 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE8 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE9 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE10 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE11 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE12 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE13 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE14 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE15 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE CREATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE CREATION_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE LAST_UPDATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      CTX OWNER VARCHAR2(4000)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE LAST_UPDATE_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE LAST_UPDATE_LOGIN NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    END ATTRIBUTE_NAVIGATION';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  END OBJECT_ATTRIBUTE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := ' ';
  --
  -- Do not download Attribute_value
  --
  /*
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    DEFINE ATTRIBUTE_VALUE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      KEY KEY_VALUE_1 VARCHAR2(100)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      KEY KEY_VALUE_2 VARCHAR2(100)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      KEY KEY_VALUE_3 VARCHAR2(100)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      KEY KEY_VALUE_4 VARCHAR2(100)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      KEY KEY_VALUE_5 VARCHAR2(100)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      KEY KEY_VALUE_6 VARCHAR2(100)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      KEY KEY_VALUE_7 VARCHAR2(100)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      KEY KEY_VALUE_8 VARCHAR2(100)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      KEY KEY_VALUE_9 VARCHAR2(100)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      KEY KEY_VALUE_10 VARCHAR2(100)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE VALUE REFERENCES ATTRIBUTE_NAVIGATION';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE CREATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE CREATION_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE LAST_UPDATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      CTX OWNER VARCHAR2(4000)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE LAST_UPDATE_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE LAST_UPDATE_LOGIN NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    END ATTRIBUTE_VALUE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  END OBJECT_ATTRIBUTE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := ' ';
  */
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  DEFINE UNIQUE_KEY';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    KEY UNIQUE_KEY_NAME VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE APPLICATION_ID NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE_CATEGORY VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE1 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE2 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE3 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE4 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE5 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE6 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE7 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE8 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE9 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE10 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE11 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE12 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE13 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE14 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE15 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE CREATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE CREATION_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE LAST_UPDATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    CTX OWNER VARCHAR2(4000)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE LAST_UPDATE_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE LAST_UPDATE_LOGIN NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := ' ';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    DEFINE UNIQUE_KEY_COLUMN';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      KEY UNIQUE_KEY_COLUMNS_PK REFERENCES ATTRIBUTE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE UNIQUE_KEY_SEQUENCE NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE_CATEGORY VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE1 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE2 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE3 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE4 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE5 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE6 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE7 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE8 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE9 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE10 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE11 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE12 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE13 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE14 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE15 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE CREATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE CREATION_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE LAST_UPDATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      CTX OWNER VARCHAR2(4000)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE LAST_UPDATE_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE LAST_UPDATE_LOGIN NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    END UNIQUE_KEY_COLUMN';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  END UNIQUE_KEY';
  l_index := l_index + 1;
  l_header_tbl(l_index) := ' ';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  DEFINE FOREIGN_KEY';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    KEY FOREIGN_KEY_NAME VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE UNIQUE_KEY_NAME REFERENCES UNIQUE_KEY';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE APPLICATION_ID NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE_CATEGORY VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE1 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE2 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE3 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE4 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE5 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE6 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE7 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE8 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE9 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE10 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE11 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE12 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE13 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE14 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE15 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE CREATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE CREATION_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE LAST_UPDATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    CTX OWNER VARCHAR2(4000)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE LAST_UPDATE_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE LAST_UPDATE_LOGIN NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE FROM_TO_NAME VARCHAR2(45)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE FROM_TO_DESCRIPTION VARCHAR2(1500)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE TO_FROM_NAME VARCHAR2(45)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE TO_FROM_DESCRIPTION VARCHAR2(1500)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := ' ';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    DEFINE FOREIGN_KEY_COLUMN';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      KEY FOREIGN_KEY_COLUMNS_PK REFERENCES ATTRIBUTE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE FOREIGN_KEY_SEQUENCE NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE_CATEGORY VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE1 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE2 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE3 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE4 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE5 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE6 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE7 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE8 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE9 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE10 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE11 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE12 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE13 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE14 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE15 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE CREATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE CREATION_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE LAST_UPDATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      CTX OWNER VARCHAR2(4000)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE LAST_UPDATE_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE LAST_UPDATE_LOGIN NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    END FOREIGN_KEY_COLUMN';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  END FOREIGN_KEY';
  l_index := l_index + 1;
  l_header_tbl(l_index) := 'END OBJECT';
  l_index := l_index + 1;
  l_header_tbl(l_index) := ' ';
  l_index := l_index + 1;
  l_header_tbl(l_index) := 'DEFINE REGION';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  KEY REGION_APPLICATION_ID NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  KEY REGION_CODE VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE DATABASE_OBJECT_NAME REFERENCES OBJECT';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE REGION_STYLE VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE NUM_COLUMNS NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ICX_CUSTOM_CALL VARCHAR2(80)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE REGION_DEFAULTING_API_PKG VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE REGION_DEFAULTING_API_PROC VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE REGION_VALIDATION_API_PKG VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE REGION_VALIDATION_API_PROC VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE APPLICATIONMODULE_OBJECT_TYPE VARCHAR2(240)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE NUM_ROWS_DISPLAY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE REGION_OBJECT_TYPE VARCHAR2(240)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE IMAGE_FILE_NAME VARCHAR2(80)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ISFORM_FLAG VARCHAR2(1)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE HELP_TARGET VARCHAR2(240)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE STYLE_SHEET_FILENAME VARCHAR2(240)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE VERSION VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE APPLICATIONMODULE_USAGE_NAME VARCHAR2(80)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ADD_INDEXED_CHILDREN VARCHAR2(1)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE STATEFUL_FLAG VARCHAR2(1)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE FUNCTION_NAME VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE CHILDREN_VIEW_USAGE_NAME VARCHAR2(80)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE SEARCH_PANEL VARCHAR2(1)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ADVANCED_SEARCH_PANEL VARCHAR2(1)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE CUSTOMIZE_PANEL VARCHAR2(1)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE DEFAULT_SEARCH_PANEL VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE RESULTS_BASED_SEARCH VARCHAR2(1)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE DISPLAY_GRAPH_TABLE VARCHAR2(1)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE DISABLE_HEADER VARCHAR2(1)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE STANDALONE VARCHAR2(1)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE AUTO_CUSTOMIZATION_CRITERIA VARCHAR2(1)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE_CATEGORY VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE1 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE2 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE3 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE4 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE5 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE6 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE7 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE8 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE9 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE10 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE11 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE12 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE13 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE14 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE15 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE CREATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE CREATION_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE LAST_UPDATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  CTX OWNER VARCHAR2(4000)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE LAST_UPDATE_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE LAST_UPDATE_LOGIN NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  TRANS NAME VARCHAR2(80)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  TRANS DESCRIPTION VARCHAR2(2000)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := ' ';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  DEFINE REGION_ITEM';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    KEY REGION_ITEM_PK REFERENCES ATTRIBUTE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE DISPLAY_SEQUENCE NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE NODE_DISPLAY_FLAG VARCHAR2(1)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE NODE_QUERY_FLAG VARCHAR2(1)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    CTX ATTRIBUTE_LABEL_LENGTH NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE DISPLAY_VALUE_LENGTH NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE BOLD VARCHAR2(1)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ITALIC VARCHAR2(1)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE VERTICAL_ALIGNMENT VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE HORIZONTAL_ALIGNMENT VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ITEM_STYLE VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE OBJECT_ATTRIBUTE_FLAG VARCHAR2(1)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ICX_CUSTOM_CALL VARCHAR2(80)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE UPDATE_FLAG VARCHAR2(1)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE REQUIRED_FLAG VARCHAR2(1)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE SECURITY_CODE VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE DEFAULT_VALUE_VARCHAR2 VARCHAR2(240)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE DEFAULT_VALUE_NUMBER NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE DEFAULT_VALUE_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE LOV_REGION REFERENCES REGION';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE LOV_FOREIGN_KEY_NAME REFERENCES FOREIGN_KEY';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE LOV_ATTRIBUTE REFERENCES ATTRIBUTE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE LOV_DEFAULT_FLAG VARCHAR2(1)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE REGION_DEFAULTING_API_PKG VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE REGION_DEFAULTING_API_PROC VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE REGION_VALIDATION_API_PKG VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE REGION_VALIDATION_API_PROC VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ORDER_SEQUENCE NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ORDER_DIRECTION VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE DISPLAY_HEIGHT NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE SUBMIT VARCHAR2(1)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ENCRYPT VARCHAR2(1)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE CSS_CLASS_NAME VARCHAR2(80)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE VIEW_USAGE_NAME VARCHAR2(80)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE VIEW_ATTRIBUTE_NAME VARCHAR2(80)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE NESTED_REGION_APPLICATION_ID NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE NESTED_REGION_CODE VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE URL VARCHAR2(2000)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE POPLIST_VIEWOBJECT VARCHAR2(240)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE POPLIST_DISPLAY_ATTRIBUTE VARCHAR2(80)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE POPLIST_VALUE_ATTRIBUTE VARCHAR2(80)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE IMAGE_FILE_NAME VARCHAR2(80)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ITEM_NAME VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE CSS_LABEL_CLASS_NAME VARCHAR2(80)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE MENU_NAME VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE FLEXFIELD_NAME VARCHAR2(40)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE FLEXFIELD_APPLICATION_ID NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE TABULAR_FUNCTION_CODE VARCHAR2(10)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE TIP_TYPE VARCHAR2(10)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE TIP_MESSAGE_NAME VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE TIP_MESSAGE_APPLICATION_ID NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE FLEX_SEGMENT_LIST VARCHAR2(4000)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ENTITY_ID VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ANCHOR VARCHAR2(1)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE POPLIST_VIEW_USAGE_NAME VARCHAR2(80)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE USER_CUSTOMIZABLE VARCHAR2(1)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE SORTBY_VIEW_ATTRIBUTE_NAME VARCHAR2(80)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ADMIN_CUSTOMIZABLE VARCHAR2(1)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE INVOKE_FUNCTION_NAME VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    CTX EXPANSION NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    CTX ALS_MAX_LENGTH NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE INITIAL_SORT_SEQUENCE VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE CUSTOMIZATION_APPLICATION_ID NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE CUSTOMIZATION_CODE VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE_CATEGORY VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE1 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE2 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE3 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE4 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE5 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE6 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE7 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE8 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE9 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE10 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE11 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE12 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE13 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE14 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE15 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE CREATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE CREATION_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE LAST_UPDATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    CTX OWNER VARCHAR2(4000)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE LAST_UPDATE_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE LAST_UPDATE_LOGIN NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    TRANS ATTRIBUTE_LABEL_LONG VARCHAR2(80)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    TRANS ATTRIBUTE_LABEL_SHORT VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    TRANS DESCRIPTION VARCHAR2(2000)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      DEFINE REGION_LOV_RELATION';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        KEY LOV_REGION REFERENCES REGION';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        KEY LOV_ATTRIBUTE REFERENCES ATTRIBUTE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        KEY BASE_ATTRIBUTE REFERENCES ATTRIBUTE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        KEY DIRECTION_FLAG VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        BASE BASE_REGION_APPL_ID NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        BASE BASE_REGION_CODE VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        BASE REQUIRED_FLAG VARCHAR2(1)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        BASE CREATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        BASE CREATION_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        BASE LAST_UPDATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        CTX OWNER VARCHAR2(4000)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        BASE LAST_UPDATE_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        BASE LAST_UPDATE_LOGIN NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      END REGION_LOV_RELATION';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      DEFINE CATEGORY_USAGE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        KEY CATEGORY_ID NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        BASE CATEGORY_NAME VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        BASE APPLICATION_ID NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        BASE SHOW_ALL VARCHAR2(1)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        BASE CREATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        BASE CREATION_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        BASE LAST_UPDATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        CTX OWNER VARCHAR2(4000)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        BASE LAST_UPDATE_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        BASE LAST_UPDATE_LOGIN NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      END CATEGORY_USAGE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  END REGION_ITEM';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  DEFINE REGION_GRAPH';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    KEY GRAPH_NUMBER NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE GRAPH_STYLE NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE DISPLAY_FLAG VARCHAR2(1)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE DEPTH_RADIUS NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE CREATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE CREATION_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE LAST_UPDATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    CTX OWNER VARCHAR2(4000)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE LAST_UPDATE_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE LAST_UPDATE_LOGIN NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    TRANS GRAPH_TITLE VARCHAR2(240)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    TRANS Y_AXIS_LABEL VARCHAR2(80)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    TRANS LANGUAGE VARCHAR2(4)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    DEFINE REGION_COLUMN';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      KEY ATTRIBUTE_APPLICATION_ID NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      KEY ATTRIBUTE_CODE VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE CREATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE CREATION_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE LAST_UPDATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      CTX OWNER VARCHAR2(4000)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE LAST_UPDATE_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE LAST_UPDATE_LOGIN NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    END REGION_COLUMN';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  END REGION_GRAPH';
  l_index := l_index + 1;
  l_header_tbl(l_index) := 'END REGION';
  l_index := l_index + 1;
  l_header_tbl(l_index) := ' ';
  end if;

  if (p_download_by_object = AK_ON_OBJECTS_PVT.G_CUSTOM_REGION) then
  l_index := l_index + 1;
  l_header_tbl(l_index) := 'DEFINE CUSTOMIZATION';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  KEY CUSTOMIZATION_APPLICATION_ID NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  KEY CUSTOMIZATION_CODE VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  KEY REGION_APPLICATION_ID NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  KEY REGION_CODE VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE VERTICALIZATION_ID VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE LOCALIZATION_CODE VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ORG_ID NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE SITE_ID NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE RESPONSIBILITY_ID NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE WEB_USER_ID NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE CUSTOMIZATION_FLAG VARCHAR2(1)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE CUSTOMIZATION_LEVEL_ID NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE DEVELOPER_MODE VARCHAR2(1)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE REFERENCE_PATH VARCHAR2(100)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE FUNCTION_NAME VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE START_DATE_ACTIVE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE END_DATE_ACTIVE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE CREATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE CREATION_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE LAST_UPDATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  CTX OWNER VARCHAR2(4000)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE LAST_UPDATE_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE LAST_UPDATE_LOGIN NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  TRANS NAME VARCHAR2(80)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  TRANS DESCRIPTION VARCHAR2(2000)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := ' ';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  DEFINE CUSTOM_REGION';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    KEY PROPERTY_NAME VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE PROPERTY_VARCHAR2_VALUE VARCHAR2(2000)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE PROPERTY_NUMBER_VALUE NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE CRITERIA_JOIN_CONDITION VARCHAR2(3)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE CREATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE CREATION_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE LAST_UPDATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    CTX OWNER VARCHAR2(4000)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE LAST_UPDATE_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE LAST_UPDATE_LOGIN NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    TRANS PROPERTY_VARCHAR2_VALUE_TL VARCHAR2(2000)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  END CUSTOM_REGION';
  l_index := l_index + 1;
  l_header_tbl(l_index) := ' ';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  DEFINE CUSTOM_REGION_ITEM';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    KEY ATTRIBUTE_APPLICATION_ID NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    KEY ATTRIBUTE_CODE VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    KEY PROPERTY_NAME VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE PROPERTY_VARCHAR2_VALUE VARCHAR2(4000)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE PROPERTY_NUMBER_VALUE NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE PROPERTY_DATE_VALUE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE CREATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE CREATION_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE LAST_UPDATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    CTX OWNER VARCHAR2(4000)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE LAST_UPDATE_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE LAST_UPDATE_LOGIN NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    TRANS PROPERTY_VARCHAR2_VALUE_TL VARCHAR2(4000)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  END CUSTOM_REGION_ITEM';
  l_index := l_index + 1;
  l_header_tbl(l_index) := ' ';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  DEFINE CRITERIA';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    KEY ATTRIBUTE_APPLICATION_ID NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    KEY ATTRIBUTE_CODE VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    KEY SEQUENCE_NUMBER NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE OPERATION VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE VALUE_VARCHAR2 VARCHAR2(240)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE VALUE_NUMBER NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE VALUE_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE START_DATE_ACTIVE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE END_DATE_ACTIVE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE CREATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE CREATION_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE LAST_UPDATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    CTX OWNER VARCHAR2(4000)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE LAST_UPDATE_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE LAST_UPDATE_LOGIN NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  END CRITERIA';
  l_index := l_index + 1;
  l_header_tbl(l_index) := 'END CUSTOMIZATION';
  l_index := l_index + 1;
  l_header_tbl(l_index) := ' ';
  end if;

  if (p_download_by_object = AK_ON_OBJECTS_PVT.G_FLOW) then
  l_index := l_index + 1;
  l_header_tbl(l_index) := 'DEFINE FLOW';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  KEY FLOW_APPLICATION_ID NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  KEY FLOW_CODE VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE PRIMARY_PAGE REFERENCES FLOW_PAGE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE_CATEGORY VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE1 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE2 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE3 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE4 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE5 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE6 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE7 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE8 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE9 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE10 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE11 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE12 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE13 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE14 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE ATTRIBUTE15 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE CREATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE CREATION_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE LAST_UPDATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  CTX OWNER VARCHAR2(4000)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE LAST_UPDATE_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE LAST_UPDATE_LOGIN NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  TRANS NAME VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  TRANS DESCRIPTION VARCHAR2(2000)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := ' ';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  DEFINE FLOW_PAGE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    KEY PAGE_APPLICATION_ID NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    KEY PAGE_CODE VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE PRIMARY_REGION REFERENCES REGION';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE_CATEGORY VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE1 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE2 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE3 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE4 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE5 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE6 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE7 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE8 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE9 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE10 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE11 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE12 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE13 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE14 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE15 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE CREATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE CREATION_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE LAST_UPDATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    CTX OWNER VARCHAR2(4000)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE LAST_UPDATE_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE LAST_UPDATE_LOGIN NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    TRANS NAME VARCHAR2(80)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    TRANS DESCRIPTION VARCHAR2(2000)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := ' ';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    DEFINE FLOW_PAGE_REGION';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      KEY FLOW_PAGE_REGION_PK REFERENCES REGION';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE DISPLAY_SEQUENCE NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE REGION_STYLE VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE NUM_COLUMNS NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ICX_CUSTOM_CALL VARCHAR2(80)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE PARENT_REGION REFERENCES REGION';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE FOREIGN_KEY_NAME REFERENCES FOREIGN_KEY';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE_CATEGORY VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE1 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE2 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE3 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE4 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE5 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE6 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE7 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE8 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE9 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE10 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE11 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE12 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE13 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE14 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE ATTRIBUTE15 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE CREATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE CREATION_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE LAST_UPDATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      CTX OWNER VARCHAR2(4000)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE LAST_UPDATE_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      BASE LAST_UPDATE_LOGIN NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := ' ';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      DEFINE FLOW_PAGE_REGION_ITEM';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        KEY FLOW_PAGE_REGION_ITEM_PK REFERENCES ATTRIBUTE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        BASE TO_PAGE REFERENCES FLOW_PAGE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        BASE TO_URL_ATTRIBUTE REFERENCES ATTRIBUTE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        BASE ATTRIBUTE_CATEGORY VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        BASE ATTRIBUTE1 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        BASE ATTRIBUTE2 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        BASE ATTRIBUTE3 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        BASE ATTRIBUTE4 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        BASE ATTRIBUTE5 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        BASE ATTRIBUTE6 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        BASE ATTRIBUTE7 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        BASE ATTRIBUTE8 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        BASE ATTRIBUTE9 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        BASE ATTRIBUTE10 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        BASE ATTRIBUTE11 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        BASE ATTRIBUTE12 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        BASE ATTRIBUTE13 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        BASE ATTRIBUTE14 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        BASE ATTRIBUTE15 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        BASE CREATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        BASE CREATION_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        BASE LAST_UPDATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        CTX OWNER VARCHAR2(4000)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        BASE LAST_UPDATE_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '        BASE LAST_UPDATE_LOGIN NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '      END FLOW_PAGE_REGION_ITEM';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    END FLOW_PAGE_REGION';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  END FLOW_PAGE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := ' ';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  DEFINE FLOW_REGION_RELATION';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    KEY FOREIGN_KEY_NAME REFERENCES FOREIGN_KEY';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    KEY FROM_PAGE REFERENCES FLOW_PAGE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    KEY FROM_REGION REFERENCES REGION';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    KEY TO_PAGE REFERENCES FLOW_PAGE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    KEY TO_REGION REFERENCES REGION';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE APPLICATION_ID NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE_CATEGORY VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE1 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE2 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE3 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE4 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE5 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE6 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE7 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE8 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE9 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE10 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE11 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE12 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE13 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE14 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE ATTRIBUTE15 VARCHAR2(150)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE CREATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE CREATION_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE LAST_UPDATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    CTX OWNER VARCHAR2(4000)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE LAST_UPDATE_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE LAST_UPDATE_LOGIN NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  END FLOW_REGION_RELATION';
  l_index := l_index + 1;
  l_header_tbl(l_index) := 'END FLOW';
  l_index := l_index + 1;
  l_header_tbl(l_index) := ' ';

  end if;
  end if; -- the first if for checking Attribute, Flow, Region and Object

  if (p_download_by_object = AK_ON_OBJECTS_PVT.G_SECURITY) then
  l_index := l_index + 1;
  l_header_tbl(l_index) := 'DEFINE EXCLUDED_ITEMS';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  KEY RESPONSIBILITY_ID NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  KEY RESP_APPLICATION_ID NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  KEY ATTRIBUTE REFERENCES ATTRIBUTE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE CREATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE CREATION_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE LAST_UPDATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  CTX OWNER VARCHAR2(4000)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE LAST_UPDATE_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE LAST_UPDATE_LOGIN NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := 'END EXCLUDED_ITEMS';
  l_index := l_index + 1;
  l_header_tbl(l_index) := ' ';

  l_index := l_index + 1;
  l_header_tbl(l_index) := 'DEFINE RESP_SECURITY_ATTRIBUTES';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  KEY RESPONSIBILITY_ID NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  KEY RESP_APPLICATION_ID NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  KEY ATTRIBUTE REFERENCES ATTRIBUTE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE CREATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE CREATION_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE LAST_UPDATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  CTX OWNER VARCHAR2(4000)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE LAST_UPDATE_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE LAST_UPDATE_LOGIN NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := 'END RESP_SECURITY_ATTRIBUTES';
  l_index := l_index + 1;
  l_header_tbl(l_index) := ' ';
  end if;

  -- Check if the Object type is valid values
  if (p_download_by_object = AK_ON_OBJECTS_PVT.G_QUERYOBJ) then

  l_index := l_index + 1;
  l_header_tbl(l_index) := 'DEFINE QUERY_OBJECT';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  KEY QUERY_CODE VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE APPLICATION_ID NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE CREATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE CREATION_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE LAST_UPDATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  CTX OWNER VARCHAR2(4000)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE LAST_UPDATE_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE LAST_UPDATE_LOGIN NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := ' ';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  DEFINE QUERY_OBJECT_LINE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    KEY SEQ_NUM NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE QUERY_LINE_TYPE VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE QUERY_LINE VARCHAR2(4000)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE LINKED_PARAMETER VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE CREATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE CREATION_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE LAST_UPDATED_BY NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    CTX OWNER VARCHAR2(4000)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE LAST_UPDATE_DATE DATE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '    BASE LAST_UPDATE_LOGIN NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  END QUERY_OBJECT_LINE';
  l_index := l_index + 1;
  l_header_tbl(l_index) := 'END QUERY_OBJECT';
  l_index := l_index + 1;
  l_header_tbl(l_index) := ' ';

  end if; -- if G_QUERYOBJ

  -- Check if the Object type is valid values
  if (p_download_by_object = AK_ON_OBJECTS_PVT.G_AMPARAM_REGISTRY) then

  l_index := l_index + 1;
  l_header_tbl(l_index) := 'DEFINE AMPARAM_REGISTRY';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  KEY  APPLICATIONMODULE_DEFN_NAME VARCHAR2(240)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  KEY  PARAM_NAME VARCHAR2(80)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  KEY  PARAM_SOURCE VARCHAR2(30)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := '  BASE APPLICATION_ID NUMBER(15)';
  l_index := l_index + 1;
  l_header_tbl(l_index) := 'END AMPARAM_REGISTRY';
  l_index := l_index + 1;
  l_header_tbl(l_index) := ' ';

  end if; -- if G_AMPARAM_REGISTRY

  l_index := l_index + 1;
  l_header_tbl(l_index) := ' ';

  --
  -- Write the header information out to the flat file
  --
  AK_ON_OBJECTS_PVT.WRITE_FILE (
    p_return_status => l_return_status,
    p_buffer_tbl => l_header_tbl,
    p_write_mode => AK_ON_OBJECTS_PUB.G_OVERWRITE
  );
  if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
     (l_return_status = FND_API.G_RET_STS_ERROR) then
    --dbms_output.put_line(G_PKG_NAME || ': first write_File failed');
    RAISE FND_API.G_EXC_ERROR;
  end if;

  --
  -- Load output parameters and set return status to success
  --
  p_nls_language_out := l_nls_language;
  p_application_id_out := l_application_id;
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_HEADER_DOWNLOAD_ERROR');
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
end DOWNLOAD_HEADER;

--==============================================
--  Procedure   UPLOAD
--
--  Usage       Private API for loading flows, objects, regions,
--              and attributes from a loader file to the database.
--              This procedure is intended to be called only by other APIs
--              that are owned by the Core Modules Team (AK)
--
--  Desc        This API parses the header information and the DEFINE
--              section, and calls the appropriate private API to read
--              in all flow, object, region, attribute, security
--				and query object data
--              (including all the tables in these business objects)
--              from the loader file, and update them to the database.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters
--==============================================
procedure UPLOAD (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_init_msg_tbl             IN      BOOLEAN := FALSE,
  p_msg_count                OUT NOCOPY     NUMBER,
  p_msg_data                 OUT NOCOPY     VARCHAR2,
  p_return_status            OUT NOCOPY     VARCHAR2
) is
  l_upl_loader_cur       AK_ON_OBJECTS_PUB.LoaderCurTyp;	-- Cursor for upload
  l_api_version_number   CONSTANT number := 1.0;
  l_api_name             CONSTANT varchar2(30) := 'Upload';
  l_attribute_index      NUMBER := 0;
  l_attribute_index_tbl  Index_Tbl_Type;
  l_buffer_tbl           AK_ON_OBJECTS_PUB.Buffer_Tbl_Type;
  l_buffer               AK_ON_OBJECTS_PUB.Buffer_Type;
  l_buffer2              AK_ON_OBJECTS_PUB.Buffer_Type;
  l_column               varchar2(30);
  l_dummy                NUMBER;
  l_eof_flag             varchar2(1);
  l_extract_by_obj       varchar2(20);
  l_index                NUMBER;
  l_language             varchar2(30);
  l_line_num             NUMBER;
  l_line_num2            NUMBER;
  l_lines_read           NUMBER;
  l_object_index         NUMBER := 0;
  l_object_index_tbl     Index_Tbl_Type;
  l_object_name          varchar2(30);
  l_return_status        varchar2(1);
  l_state                NUMBER;
  l_timestamp            DATE := sysdate;
  l_token                AK_ON_OBJECTS_PUB.Buffer_Type;
  l_tbl_index            NUMBER;
  l_file_version         NUMBER;
  l_validation_level     NUMBER := FND_API.G_VALID_LEVEL_FULL;
  l_not_compatible_version	 BOOLEAN := TRUE;
  i						 NUMBER;
begin
  IF NOT FND_API.Compatible_API_Call (
    l_api_version_number, p_api_version_number, l_api_name,
    G_PKG_NAME) then
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return;
  END IF;

  -- Initialize the message table if requested.

  if p_init_msg_tbl then
    FND_MSG_PUB.initialize;
  end if;

--dbms_output.put_line(to_char(l_timestamp));

  -- Get total number of records in AK_LOADER_TEMP
  --
    select count(*) into G_UPL_TABLE_NUM
	from AK_LOADER_TEMP;

	l_lines_read := 0;

  --
  -- Retrieve the first non-blank, non-comment line
  --
  l_state := 0;
  l_eof_flag := 'N';
  l_buffer := null;
  l_line_num := 0;
  l_tbl_index := 0;

  --
  -- Process 2 times to make sure all forward dependencies could be
  -- resolved
  --
  -- First pass:
  l_index := 1;

  --dbms_output.put_line('**** Processing pass # ' || to_char(l_index) || ' ****');

  -- Open Upload Loader Cursor
  OPEN l_upl_loader_cur	FOR SELECT TBL_INDEX,LINE_CONTENT FROM ak_loader_temp
  where session_id = AK_ON_OBJECTS_PVT.G_SESSION_ID
  order by tbl_index;

  while (l_buffer is null and l_eof_flag = 'N' and l_tbl_index <=  G_UPL_TABLE_NUM) loop
    AK_ON_OBJECTS_PVT.READ_LINE (
        p_return_status => l_return_status,
        p_index => l_tbl_index,
        p_buffer => l_buffer,
        p_lines_read => l_lines_read,
        p_eof_flag => l_eof_flag,
		p_upl_loader_cur => l_upl_loader_cur
    );

    if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
       (l_return_status = FND_API.G_RET_STS_ERROR) then
        RAISE FND_API.G_EXC_ERROR;
    end if;
    l_line_num := l_line_num + l_lines_read;

    --
    -- discard comment lines
    --
      --
      -- trim leading spaces and discard comment lines
      --
    l_buffer := LTRIM(l_buffer);
    if (SUBSTR(l_buffer, 1, 1) = '#') then
        if (SUBSTR(l_buffer, 3,12) = 'Generated on') then
          AK_UPLOAD_GRP.G_GEN_DATE:= to_date(substr(l_buffer,16),'RR/MM/DD HH24:MI:SS');
        end if;
      l_buffer := null;
    end if;
  end loop;

  if (AK_UPLOAD_GRP.G_GEN_DATE is null) then
    AK_UPLOAD_GRP.G_GEN_DATE := l_timestamp;
  end if;

  --
  -- if we cannot even get one non-blank, non-comment line from
  -- the file, there is nothing to be processed in this file
  --
  if (l_buffer is null and l_eof_flag = 'Y' and l_tbl_index = G_UPL_TABLE_NUM) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_EMPTY_FILE');
      FND_MSG_PUB.Add;
    end if;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  --
  -- Parse the buffer read to obtain header information such as
  -- language and codeset
  --
  while (l_eof_flag = 'N') and (l_buffer is not null) loop
    --
    -- - get next token from buffer
    --

    AK_ON_OBJECTS_PVT.GET_TOKEN(
      p_return_status => l_return_status,
      p_in_buf => l_buffer,
      p_token => l_token
    );

    if (l_return_status = FND_API.G_RET_STS_ERROR) or
       (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.SET_NAME('AK','AK_GET_TOKEN_ERROR');
        FND_MSG_PUB.Add;
      end if;
      raise FND_API.G_EXC_ERROR;
    end if;
    --dbms_output.put_line(' State:' || l_state || 'Token:' || l_token);

    --
    -- - process token
    --
    if (l_state = 0) then
      if (l_token = 'BEGIN') then
        --
        -- Check for missing header info
        -- Language and codeset, and extract_by_object are required.
        --
        if (l_language is null) or (l_extract_by_obj is null) then
          if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.SET_NAME('AK','AK_HEADER_INFO_MISSING');
            FND_MSG_PUB.Add;
          end if;
          raise FND_API.G_EXC_ERROR;
        else
--  dbms_output.put_line('l_language is ' || l_language);
--  dbms_output.put_line('l_extract_by_obj is ' || l_extract_by_obj);
          l_state := 3;
        end if;
      elsif (l_token = 'LANGUAGE') or
            (l_token = 'EXTRACT_BY_OBJECT') or
            (l_token = 'FILE_FORMAT_VERSION') then
        l_column := l_token;
        l_state := 1;
      elsif (l_token = 'DEFINE') then
        l_state := 10;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED','BEGIN, LANGUAGE, CODESET, ' ||
                                'EXTRACT_BY_OBJECT, EXTRACT_BY_APPLICATION');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if; -- endif of (l_token = 'BEGIN')
    elsif (l_state = 1) then
      if (l_token = '=') then
        l_state := 2;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED','=');
          FND_MSG_PUB.Add;
        end if;
        --dbms_output.put_line('Expecting =');
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 2) then
      if (l_column = 'LANGUAGE') then
        l_language := UPPER(l_token);
      elsif (l_column = 'EXTRACT_BY_OBJECT') then
        if (UPPER(l_token) NOT IN (AK_ON_OBJECTS_PVT.G_ATTRIBUTE,
                                   AK_ON_OBJECTS_PVT.G_FLOW,
                                   AK_ON_OBJECTS_PVT.G_OBJECT,
                                   AK_ON_OBJECTS_PVT.G_REGION,
				   AK_ON_OBJECTS_PVT.G_CUSTOM_REGION,
                                   AK_ON_OBJECTS_PVT.G_SECURITY,
                                   AK_ON_OBJECTS_PVT.G_QUERYOBJ,
				   AK_ON_OBJECTS_PVT.G_AMPARAM_REGISTRY) ) then
          if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.SET_NAME('AK','AK_INVALID_COLUMN_VALUE');
            FND_MESSAGE.SET_TOKEN('COLUMN','EXTRACT_BY_OBJECT');
            FND_MSG_PUB.Add;
          end if;
          raise FND_API.G_EXC_ERROR;
        else
          l_extract_by_obj := UPPER(l_token);
	  AK_UPLOAD_GRP.G_EXTRACT_OBJ := l_extract_by_obj;
        end if;
      elsif (l_column = 'FILE_FORMAT_VERSION') then
	l_file_version := to_number(l_token);
	 AK_ON_OBJECTS_PUB.G_UPLOAD_FILE_VERSION := l_file_version;
	if ( l_file_version <> AK_ON_OBJECTS_PUB.G_FILE_FORMAT_VER and
		l_file_version <> AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER1 and
		l_file_version <> AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER2 and
		l_file_version <> AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER3 and
		l_file_version <> AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER4 and
		l_file_version <> AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER5 and
		l_file_version <> AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER6 and
		l_file_version <> AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER7 and
		l_file_version <> AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER8 and
		l_file_version <> AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER9 and
		l_file_version <> AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER10 and
		l_file_version <> AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER11 and
		l_file_version <> AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER12 and
		l_file_version <> AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER14 and
                l_file_version <> AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER15) then
          if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.SET_NAME('AK','AK_WRONG_FILE_VERSION');
            FND_MSG_PUB.Add;
          end if;
          raise FND_API.G_EXC_ERROR;
	end if; -- end if l_file_version
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED',l_column);
          FND_MSG_PUB.Add;
        end if;
        -- dbms_output.put_line('Expecting ' || l_column || ' value');
        raise FND_API.G_EXC_ERROR;
      end if;
      l_state := 0;
    elsif (l_state = 4) then
      if (l_token = 'BEGIN') then
        l_state := 5;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED','BEGIN');
          FND_MSG_PUB.Add;
        end if;
        -- dbms_output.put_line('Expecting BEGIN');
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 3) or (l_state = 5) then
      if (l_token = 'ATTRIBUTE') then
        -- call ak_attribute_pvt.upload --
        -- dbms_output.put_line('Calling attribute upload: ' ||
        --                      to_char(sysdate, 'MON-DD HH24:MI:SS'));
        --
        -- Update index table for attribute. Since some attributes refer
        -- to LOV objects which do not exists yet, we will need to remember
        -- where the ATTRIBUTE object begins so that we can upload it to
        -- the database again once all objects have been uploaded.
        --
        l_attribute_index := l_attribute_index + 1;
        l_attribute_index_tbl(l_attribute_index) :=G_buffer_tbl.prior(l_index);
        --
        -- Upload attribute information to the database
        --
        AK_ATTRIBUTE_PVT.UPLOAD_ATTRIBUTE (
          p_validation_level => l_validation_level,
          p_api_version_number => 1.0,
          p_return_status => l_return_status,
          p_index => l_tbl_index,
          p_loader_timestamp => l_timestamp,
          p_line_num => l_line_num,
          p_buffer => l_buffer,
 	  p_line_num_out => l_line_num2,
	  p_buffer_out => l_buffer2,
		  p_upl_loader_cur => l_upl_loader_cur,
		  p_pass => l_index
        );
	l_buffer := l_buffer2;
	l_line_num := l_line_num2;

        if (l_return_status = FND_API.G_RET_STS_ERROR) or
         (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
         raise FND_API.G_EXC_ERROR;
		else
		  -- commit the changes from uploading attribute
		  commit;
        end if;
-- dbms_output.put_line('l_buffer returned: ' || l_buffer);
      elsif (l_token = 'OBJECT') then
        -- call ak_object_pvt.upload --
        -- dbms_output.put_line('Calling object upload: ' ||
        --                      to_char(sysdate, 'MON-DD HH24:MI:SS'));
        --
        -- Update index table for object. Since some attribute navigation
        -- records refer to target regions which do not exists yet,
        -- we will need to remembewhere the OBJECT object begins so that we
        -- can upload them to the database again once all regions have been
        -- uploaded.
        --
        l_object_index := l_object_index + 1;
        l_object_index_tbl(l_object_index) :=G_buffer_tbl.prior(l_index);
        --
        -- Upload attribute information to the database
        --
        AK_OBJECT3_PVT.UPLOAD_OBJECT (
          p_validation_level => l_validation_level,
          p_api_version_number => 1.0,
          p_return_status => l_return_status,
          p_index => l_tbl_index,
          p_loader_timestamp => l_timestamp,
          p_line_num => l_line_num,
          p_buffer => l_buffer,
	  p_line_num_out => l_line_num2,
	  p_buffer_out => l_buffer2,
		  p_upl_loader_cur => l_upl_loader_cur,
		  p_pass => l_index
        );
        l_buffer := l_buffer2;
        l_line_num := l_line_num2;
        --dbms_output.put_line('Return from Upload Object to UPLOAD, return status = '||l_return_status);
        if (l_return_status = FND_API.G_RET_STS_ERROR) or
         (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
         raise FND_API.G_EXC_ERROR;
		else
		  -- commit the changes from uploading object
		  commit;
        end if;

      elsif (l_token = 'REGION') then
        -- call ak_region_pvt.upload --
        -- dbms_output.put_line('Calling region upload:'  ||
        --                      to_char(sysdate, 'MON-DD HH24:MI:SS'));
        AK_REGION2_PVT.UPLOAD_REGION (
          p_validation_level => l_validation_level,
          p_api_version_number => 1.0,
          p_return_status => l_return_status,
          p_index => l_tbl_index,
          p_loader_timestamp => l_timestamp,
          p_line_num => l_line_num,
          p_buffer => l_buffer,
	  p_line_num_out => l_line_num2,
	  p_buffer_out => l_buffer2,
		  p_upl_loader_cur => l_upl_loader_cur,
		  p_pass => l_index
        );
        l_buffer := l_buffer2;
        l_line_num := l_line_num2;
 -- dbms_output.put_line('l_buffer returned: ' || l_buffer);
        if (l_return_status = FND_API.G_RET_STS_ERROR) or
         (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
         raise FND_API.G_EXC_ERROR;
		else
		  -- commit the changes from uploading region
		  commit;
        end if;

      elsif (l_token = 'CUSTOMIZATION') then
        AK_CUSTOM2_PVT.UPLOAD_CUSTOM (
          p_validation_level => l_validation_level,
          p_api_version_number => 1.0,
          p_return_status => l_return_status,
          p_index => l_tbl_index,
          p_loader_timestamp => l_timestamp,
          p_line_num => l_line_num,
          p_buffer => l_buffer,
	  p_line_num_out => l_line_num2,
	  p_buffer_out => l_buffer2,
                  p_upl_loader_cur => l_upl_loader_cur,
                  p_pass => l_index
        );
        l_buffer := l_buffer2;
        l_line_num := l_line_num2;
        if (l_return_status = FND_API.G_RET_STS_ERROR) or
         (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
         raise FND_API.G_EXC_ERROR;
		else
		  -- commit the changes from uploading customization
		  commit;
        end if;

      elsif (l_token = 'FLOW') then
        -- call ak_flow_pvt.upload --
        -- dbms_output.put_line('Calling flow upload:' ||
        --                      to_char(sysdate, 'MON-DD HH24:MI:SS'));
        AK_FLOW2_PVT.UPLOAD_FLOW (
          p_validation_level => l_validation_level,
          p_api_version_number => 1.0,
          p_return_status => l_return_status,
          p_index => l_tbl_index,
          p_loader_timestamp => l_timestamp,
          p_line_num => l_line_num,
          p_buffer => l_buffer,
          p_line_num_out => l_line_num2,
	  p_buffer_out => l_buffer2,
		  p_upl_loader_cur => l_upl_loader_cur,
		  p_pass => l_index
        );
        l_buffer := l_buffer2;
        l_line_num := l_line_num2;
		-- dbms_output.put_line('Returning from flow upload: '||
        --                      to_char(sysdate, 'MON-DD HH24:MI:SS')||' status: '||l_return_status);
        if (l_return_status = FND_API.G_RET_STS_ERROR) or
         (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
         raise FND_API.G_EXC_ERROR;
		else
		  -- commit the changes from uploading flow
		  commit;
        end if;

      elsif (l_token = 'EXCLUDED_ITEMS' or l_token = 'RESP_SECURITY_ATTRIBUTES') then
        -- call ak_flow_pvt.upload --
        -- dbms_output.put_line('Calling security upload:' ||
        --                      to_char(sysdate, 'MON-DD HH24:MI:SS'));
        -- There's no need to pass SECURITY two times since there's
		-- no forward references problem in it
		--
        AK_SECURITY_PVT.UPLOAD_SECURITY (
          p_validation_level => l_validation_level,
          p_api_version_number => 1.0,
          p_return_status => l_return_status,
          p_index => l_tbl_index,
          p_loader_timestamp => l_timestamp,
          p_line_num => l_line_num,
          p_buffer => l_token ||' '||l_buffer,
	  p_line_num_out => l_line_num2,
	  p_buffer_out => l_buffer2,
		  p_upl_loader_cur => l_upl_loader_cur
        );
        l_buffer := l_buffer2;
        l_line_num := l_line_num2;
        if (l_return_status = FND_API.G_RET_STS_ERROR) or
         (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
         raise FND_API.G_EXC_ERROR;
		else
		  -- commit the changes from uploading security
		  commit;
        end if;

      elsif (l_token = 'QUERY_OBJECT') then
        -- call ak_region_pvt.upload --
        -- dbms_output.put_line('Calling query object upload:'  ||
        --                      to_char(sysdate, 'MON-DD HH24:MI:SS'));
        AK_QUERYOBJ_PVT.UPLOAD_QUERY_OBJECT (
          p_validation_level => l_validation_level,
          p_api_version_number => 1.0,
          p_return_status => l_return_status,
          p_index => l_tbl_index,
          p_loader_timestamp => l_timestamp,
          p_line_num => l_line_num,
          p_buffer => l_buffer,
	  p_line_num_out => l_line_num2,
	  p_buffer_out => l_buffer2,
		  p_upl_loader_cur => l_upl_loader_cur,
		  p_pass => l_index
        );
        l_buffer := l_buffer2;
        l_line_num := l_line_num2;
 -- dbms_output.put_line('l_buffer returned: ' || l_buffer);
        if (l_return_status = FND_API.G_RET_STS_ERROR) or
         (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
         raise FND_API.G_EXC_ERROR;
		else
		  -- commit the changes from uploading query object
		  commit;
        end if;

      elsif (l_token = 'AMPARAM_REGISTRY') then
        --
        -- Upload amparm_registry information to the database
        --
        AK_AMPARAM_REGISTRY_PVT.UPLOAD_AMPARAM_REGISTRY (
          p_validation_level => l_validation_level,
          p_api_version_number => 1.0,
          p_return_status => l_return_status,
          p_index => l_tbl_index,
          p_loader_timestamp => l_timestamp,
          p_line_num => l_line_num,
          p_buffer => l_buffer,
	  p_line_num_out => l_line_num2,
	  p_buffer_out => l_buffer2,
		  p_upl_loader_cur => l_upl_loader_cur,
		  p_pass => l_index
        );
        l_buffer := l_buffer2;
        l_line_num := l_line_num2;
        --dbms_output.put_line('Return from Upload Object to UPLOAD, return status = '||l_return_status);
        if (l_return_status = FND_API.G_RET_STS_ERROR) or
         (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
         raise FND_API.G_EXC_ERROR;
		else
		  -- commit the changes from uploading amparam_registry
		  commit;
        end if;

      else
--        dbms_output.put_line('Expecting ATTRIBUTE, OBJECT, REGION, FLOW,
--          EXCLUDED_ITEMS or RESP_SECURITY_ATTRIBUTES');
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED','ATTRIBUTE, OBJECT, REGION,
            FLOW, EXCLUDED_ITEMS, RESP_SECURITY_ATTRIBUTES OR QUERY_OBJECT');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
      l_state := 4;
--      l_buffer := '';  /* clears buffer so a different line will be read */
    elsif (l_state = 10) then
      l_object_name := l_token;
      l_state := 11;
    elsif (l_state = 11) then
      --
      -- ignores all tokens except END and BEGIN
      --
      if (l_token = 'END') then
        l_state := 12;
      elsif (l_token = 'BEGIN') then
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'END ' || l_object_name);
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 12) then
      if (l_token = l_object_name) then
        l_state := 0;
      else
        l_state := 11;
      end if;
    end if;

    --
    -- Get rid of leading white spaces, so that buffer would become
    -- null if the only thing in it are white spaces
    --
    l_buffer := LTRIM(l_buffer);

    --
    -- Get the next non-blank, non-comment line if current line is
    -- fully parsed
    --
    while (l_buffer is null and l_eof_flag = 'N' and l_tbl_index <=  G_UPL_TABLE_NUM) loop
      AK_ON_OBJECTS_PVT.READ_LINE (
        p_return_status => l_return_status,
        p_index => l_tbl_index,
        p_buffer => l_buffer,
        p_lines_read => l_lines_read,
        p_eof_flag => l_eof_flag,
		p_upl_loader_cur => l_upl_loader_cur
      );
      if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
         (l_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
      end if;
      l_line_num := l_line_num + l_lines_read;
      --
      -- trim leading spaces and discard comment lines
      --
      l_buffer := LTRIM(l_buffer);
      if (SUBSTR(l_buffer, 1, 1) = '#') then
        l_buffer := null;
      end if;
    end loop;

  end loop; -- End of while loop

  close l_upl_loader_cur; -- Close Upload cursor

  --
  -- Write a '# lines processed message' to the message stack
  --
--  dbms_output.put_line(to_char(l_line_num) || ' lines processed.');
--  FND_MESSAGE.SET_NAME('AK','AK_LINES_PROCESSED');
--  FND_MESSAGE.SET_TOKEN('NUMLINES', to_char(l_line_num));
--  FND_MSG_PUB.Add;

  -- ************* Starts second pass *****************

  l_index := 2;
  --
  -- Write message informing user whether this is the first pass or the
  -- second pass at reading the input file
  --
  FND_MESSAGE.SET_NAME('AK','AK_UPLOAD_PASS2' || to_char(l_index));
  FND_MSG_PUB.Add;

  AK_ATTRIBUTE_PVT.UPLOAD_ATTRIBUTE_SECOND (
    p_validation_level => p_validation_level,
    p_return_status => l_return_status,
    p_loader_timestamp => l_timestamp,
	p_pass => l_index
  );
  -- If API call returns with an error status, upload aborts
  if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
     (l_return_status = FND_API.G_RET_STS_ERROR) then
    RAISE FND_API.G_EXC_ERROR;
  end if; -- /* if l_return_status */

  AK_OBJECT2_PVT.UPLOAD_OBJECT_SECOND (
    p_validation_level => p_validation_level,
    p_return_status => l_return_status,
    p_loader_timestamp => l_timestamp,
	p_pass => l_index
  );
  -- If API call returns with an error status, upload aborts
  if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
     (l_return_status = FND_API.G_RET_STS_ERROR) then
    RAISE FND_API.G_EXC_ERROR;
  end if; -- /* if l_return_status */

  AK_REGION2_PVT.UPLOAD_REGION_SECOND (
    p_validation_level => p_validation_level,
    p_return_status => l_return_status,
    p_loader_timestamp => l_timestamp,
	p_pass => l_index
  );
  -- If API call returns with an error status, upload aborts
  if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
     (l_return_status = FND_API.G_RET_STS_ERROR) then
    RAISE FND_API.G_EXC_ERROR;
  end if; -- /* if l_return_status */

  AK_CUSTOM2_PVT.UPLOAD_CUSTOM_SECOND (
    p_validation_level => p_validation_level,
    p_return_status => l_return_status,
    p_loader_timestamp => l_timestamp,
        p_pass => l_index
  );
  -- If API call returns with an error status, upload aborts
  if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
     (l_return_status = FND_API.G_RET_STS_ERROR) then
    RAISE FND_API.G_EXC_ERROR;
  end if; -- /* if l_return_status */

  AK_FLOW2_PVT.UPLOAD_FLOW_SECOND (
    p_validation_level => p_validation_level,
    p_return_status => l_return_status,
    p_loader_timestamp => l_timestamp,
	p_pass => l_index
  );
  -- If API call returns with an error status, upload aborts
  if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
     (l_return_status = FND_API.G_RET_STS_ERROR) then
    RAISE FND_API.G_EXC_ERROR;
  end if; -- /* if l_return_status */

  -- ******* FUTURE ENHANCEMENT ********

  -- if extracting object by application ID, logic should be like this:
  --   for each flow with this application ID, with timestamp not
  --   equals to the loader timestamp, and created by and last updated
  --   by are both 1, call ak_object_pvt.delete with cascade = 'Y'.
  --   Then for each attribute referenced by any object attributes to be
  --   deleted, call ak_attribute_pvt.delete with cascade = 'N'.

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
end UPLOAD;

--=======================================================
--  Procedure   GET_TOKEN
--
--  Usage       Private procedure for returning the first token from
--              the given input string.
--              This function is intended to be called only by other APIs
--              that are owned by the Core Modules Team (AK)
--
--  Desc        This procedure parses the input string and returns the first
--              token in the string. It then removes that token from the
--              input string.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error (including parse error, such as empty input string)
--                  * Success
--              The procedure returns the first token in the input string
--              in the p_token parameter. It also removes the token from
--              the input string.
--  Parameters  p_in_buf : IN OUT
--                  The input string to be parsed. The procedure would
--                  remove the first token from this string before
--                  passing it back to the calling API.
--              p_token : OUT
--                  The first token parsed in the input string, with
--                  all the escaped characters in the token already
--                  replaced with their original characters.
--=======================================================
procedure GET_TOKEN (
  p_return_status           OUT NOCOPY     VARCHAR2,
  p_in_buf                  IN OUT NOCOPY  VARCHAR2,
  p_token                   OUT NOCOPY     VARCHAR2
) is
  l_api_name           CONSTANT varchar2(30) := 'Get_Token';
  l_num_slash number;
  l_start_pos number;
  l_end_pos   number;
  l_curr_pos  number;
  l_done      boolean;
begin
  p_in_buf := LTRIM(p_in_buf);

  if (p_in_buf is null) then
    p_token := null;
    --dbms_output.put_line('No more token');
    raise FND_API.G_EXC_ERROR;
  end if;

  l_start_pos := 1;
  l_curr_pos := 1;

  --
  -- If a quote is found, get string in quotes as token
  --
  IF (SUBSTR(p_in_buf, 1, 1) = '"') THEN
    l_done := FALSE;
    --
    -- find end quote. If a quote is preceeded with an odd number of
    -- backslashes, then it is not an end quote
    --
    WHILE not l_done LOOP
      l_end_pos := INSTR(p_in_buf, '"', l_curr_pos + 1);
      if (l_end_pos = 0) or (SUBSTR(p_in_buf, l_end_pos - 1, 1) <> '\') then
        l_done := TRUE;
      else
        l_num_slash := 1;
        l_curr_pos := l_end_pos - 2;
        while (SUBSTR(p_in_buf, l_curr_pos, 1) = '\') loop
          l_num_slash := l_num_slash + 1;
          l_curr_pos := l_curr_pos - 1;
        end LOOP;
        if (MOD(l_num_slash, 2) = 0) then
          l_done := TRUE;
        end if;
        --
        -- start next search from position of this quotation mark
        --
        l_curr_pos := l_end_pos;
      END IF;
    END LOOP;
    l_start_pos := l_start_pos + 1; /* don't include quote */

  --
  -- No quote found, get string up to next white space or end of line
  -- as token
  --
  ELSE
    l_end_pos := INSTR(p_in_buf, ' ');
    --
    -- if cannot find a terminating space, return whole string as token
    --
    if (l_end_pos = 0) then
      l_end_pos := length(p_in_buf) + 1;
    end if;
  END IF;

  if (l_end_pos > 0) then
    p_token := REPLACE_ESCAPED_CHARS(
                  SUBSTR(p_in_buf, l_start_pos, l_end_pos - l_start_pos) );
    p_in_buf := SUBSTR(p_in_buf, l_end_pos + 1, length(p_in_buf)- l_end_pos+1);
    p_return_status := FND_API.G_RET_STS_SUCCESS;
  else
    --
    -- error: missing end quote
    --
    p_token := null;
    -- dbms_output.put_line('Error - Missing end quote');
    raise FND_API.G_EXC_ERROR;
  end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
end GET_TOKEN;

--=======================================================
--  Procedure   READ_LINE
--
--  Usage       Private procedure for reading the next line from a file.
--              This function is intended to be called only by other APIs
--              that are owned by the Core Modules Team (AK)
--
--  Desc        This procedure reads the next logical line from a flat file
--              whose file has been read into a Global PL/SQL table.
--              A logical line may contain many physical lines in the
--              file, each except the last physical line has  a trailing
--              character indicating that the line is to be continued.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              The procedure returns the data read from the file into
--              the p_buffer parameter. It also return the number of physical
--              lines read when reading the next logical line through the
--              p_lines_read parameter. If the end-of-file is reached, the
--              p_eof_flag will be loaded with 'Y'.
--  Parameters
--				p_index: IN OUT required
--
--              p_buffer : OUT
--                  The buffer where the logical line read from the file
--                  will be loaded.
--              p_lines_read : OUT
--                  The number of lines read from the file when reading
--                  the current logical line
--              p_eof_flag : OUT
--                  This flag will be loaded with 'Y' if the procedure
--                  has encountered the end-of-file while trying to read
--                  the next line from the file.
--  Notes       This procedure will NOT close the file after the last
--              line is read - the caller must close the file by calling
--              the CLOSE_FILE API.
--=======================================================
procedure READ_LINE (
  p_return_status           OUT NOCOPY     VARCHAR2,
  p_index                   IN OUT NOCOPY  Number,
  p_buffer                  OUT NOCOPY     AK_ON_OBJECTS_PUB.Buffer_Type,
  p_lines_read              OUT NOCOPY     number,
  p_eof_flag                OUT NOCOPY     VARCHAR2,
  p_upl_loader_cur          IN OUT NOCOPY  AK_ON_OBJECTS_PUB.LoaderCurTyp
  )
  is
  l_api_name           CONSTANT varchar2(30) := 'Read_Line';
  l_buffer             AK_ON_OBJECTS_PUB.Buffer_Type;
  l_cont_buffer        AK_ON_OBJECTS_PUB.Buffer_Type;
  l_done               BOOLEAN := TRUE;
  l_lines_read         NUMBER := 0;
  l_index              NUMBER;
  l_return_status      VARCHAR2(1);
  l_dummy              NUMBER;
begin
  --
  -- Read next line from file.
  --

  l_index := p_index;

  l_index := l_index + 1;
  FETCH p_upl_loader_cur into l_dummy, l_buffer;

  l_lines_read := 1;
  --
  -- If line is a comment, (i.e. the first non-white space char is '#')
  -- then we do not need to check for continuation line. Simply
  -- return this line.
  --
  if (SUBSTR(LTRIM(l_buffer), 1, 1) = '#') then
    p_buffer := l_buffer;
  else
    --
    -- not a comment line, check for continuation lines
    --
    l_cont_buffer := null;
    l_done := FALSE;
    while (not l_done) loop
      if (SUBSTR(RTRIM(l_buffer), -1, 1) = '\') then
        --
        -- This line to be continued, add to buffer
        --
        l_cont_buffer := l_cont_buffer ||
                                 SUBSTR(l_buffer,1,length(l_buffer)-1);

		FETCH p_upl_loader_cur into l_dummy, l_buffer;

        l_lines_read := l_lines_read + 1;
		l_index := l_index + 1;
      else
        --
        -- line ends, load buffer
        --
        p_buffer := l_cont_buffer || l_buffer;
        l_done := TRUE;
      end if;
    end LOOP; /* while not l_done */
  end if; /* if comment line */

  --
  -- Return the number of physical lines read
  --
  p_lines_read := l_lines_read;
  p_eof_flag := 'N';
  p_index := l_index;
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    if not l_done then
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
        FND_MESSAGE.SET_NAME('AK','AK_UNEXPECTED_EOF_ERROR');
        FND_MSG_PUB.Add;
        p_return_status := FND_API.G_RET_STS_ERROR;
      end if;
    end if;
    p_return_status := FND_API.G_RET_STS_SUCCESS;
    p_lines_read := l_lines_read;
    p_eof_flag := 'Y';
	p_index := l_index;
  WHEN INVALID_CURSOR THEN
    --dbms_output.put_line('Invalid cursor');
    if not l_done then
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
        FND_MESSAGE.SET_NAME('AK','AK_UNEXPECTED_EOF_ERROR');
        FND_MSG_PUB.Add;
      end if;
    end if;
	p_return_status := FND_API.G_RET_STS_ERROR;
    p_lines_read := l_lines_read;
    p_eof_flag := 'Y';
	p_index := l_index;
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    p_eof_flag := 'Y';
    p_lines_read := l_lines_read;
end READ_LINE;

--=======================================================
--  Procedure   SET_WHO
--
--  Usage       Private procedure for setting the who columns values.
--              This function is intended to be called only by other APIs
--              that are owned by the Core Modules Team (AK)
--
--  Desc        This procedure returns to the caller the values of the
--              who columns for updating or creating a record. It returns
--              a different set of values depending on whether the update
--              is initiated by a user or by the loader.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_loader_timestamp : IN optional
--                  The timestamp to be used when the record are to be
--                  updated or created by the loader. It should not
--                  contain any value (ie, G_MISS_DATE) if the record
--                  is not being updated or created by the loader.
--              p_created_by : OUT
--                  It contains the value to be used for the CREATED_BY
--                  who column. This value should be ignored by the
--                  caller if the caller is only updating a record.
--              p_creation_date : OUT
--                  It contains the value to be used for the CREATION_DATE
--                  who column. This value should be ignored by the
--                  caller if the caller is only updating a record.
--              p_last_updated_by : OUT
--                  It contains the value to be used for the LAST_UPDATED_BY
--                  who column.
--              p_last_update_date : OUT
--                  It contains the value to be used for the LAST_UPDATE_DATE
--                  who column.
--              p_last_update_login : OUT
--                  It contains the value to be used for the
--                  LAST_UPDATE_LOGIN who column.
--=======================================================
procedure SET_WHO (
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
  p_created_by               OUT NOCOPY     NUMBER,
  p_creation_date            OUT NOCOPY     DATE,
  p_last_updated_by          OUT NOCOPY     NUMBER,
  p_last_update_date         OUT NOCOPY     DATE,
  p_last_update_login        OUT NOCOPY     NUMBER
) is
  l_api_name           CONSTANT varchar2(30) := 'Set_Who';
  l_file_version 	number;
begin

if AK_UPLOAD_GRP.G_UPLOAD_DATE is null then
   AK_UPLOAD_GRP.G_UPLOAD_DATE := AK_UPLOAD_GRP.G_GEN_DATE;
end if;
if (p_loader_timestamp <> FND_API.G_MISS_DATE) then
  l_file_version := AK_ON_OBJECTS_PUB.G_UPLOAD_FILE_VERSION;
    if ( l_file_version = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER1 or
                l_file_version = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER2 or
                l_file_version = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER3 or
                l_file_version = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER4 or
                l_file_version = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER5 or
                l_file_version = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER6 or
                l_file_version = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER7 or
                l_file_version = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER8 or
                l_file_version = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER9 or
                l_file_version = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER10 or
                l_file_version = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER11 or
                l_file_version = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER12) then
       if (AK_UPLOAD_GRP.G_UPLOAD_DATE is null and AK_UPLOAD_GRP.G_COMPARE_UPDATE = FALSE) then
	     AK_UPLOAD_GRP.G_UPLOAD_DATE := p_loader_timestamp;
       elsif (AK_UPLOAD_GRP.G_UPLOAD_DATE is null and AK_UPLOAD_GRP.G_COMPARE_UPDATE = TRUE) then
          if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
             FND_MESSAGE.SET_NAME('AK','AK_MISSING_GEN_DATE');
             FND_MSG_PUB.Add;
          end if;
          raise FND_API.G_EXC_ERROR;
       end if;
       p_created_by := 1;
       p_creation_date := AK_UPLOAD_GRP.G_UPLOAD_DATE;
       p_last_updated_by := 1;
       p_last_update_date := AK_UPLOAD_GRP.G_UPLOAD_DATE;
       p_last_update_login := 1;
  elsif ( l_file_version = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER15 or
		l_file_version = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER14) then
    -- called from loader
    	p_created_by := 2;
    	p_creation_date := AK_UPLOAD_GRP.G_UPLOAD_DATE;
    	p_last_updated_by := 2;
    	p_last_update_date := AK_UPLOAD_GRP.G_UPLOAD_DATE;
    	p_last_update_login := 1;
  end if;
else
    -- called from user procedure
    p_created_by := to_number(nvl(fnd_profile.value('USER_ID'),0));
    p_creation_date := sysdate;
    p_last_updated_by := to_number(nvl(fnd_profile.value('USER_ID'),0));
    p_last_update_date := sysdate;
    p_last_update_login := to_number(
	nvl(fnd_profile.value('LOGIN_ID'),0));
end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
END SET_WHO;


--=======================================================
--  Function    IS_UPDATEABLE
--
--  Usage       Private function for determining if record will be
--              updated.
--              This function is intended to be called only by other APIs
--              that are owned by the Core Modules Team (AK)
--
--  Desc        This function returns to the caller true or false
--              depending on the results of old manual AK logic for
--              determining updateablity, or for jlt files with
--              G_FORMAT_FILE_VER of 120.1 or greater uses
--              FND_LOAD_UTIL.UPLOAD_TEST.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_loader_timestamp : IN optional
--                  The timestamp to be used when the record are to be
--                  updated or created by the loader. It should not
--                  contain any value (ie, G_MISS_DATE) if the record
--                  is not being updated or created by the loader.
--              p_created_by : OUT
--                  It contains the value to be used for the CREATED_BY
--                  who column. This value should be ignored by the
--                  caller if the caller is only updating a record.
--              p_creation_date : OUT
--                  It contains the value to be used for the CREATION_DATE
--                  who column. This value should be ignored by the
--                  caller if the caller is only updating a record.
--              p_last_updated_by : OUT
--                  It contains the value to be used for the LAST_UPDATED_BY
--                  who column.
--              p_last_update_date : OUT
--                  It contains the value to be used for the LAST_UPDATE_DATE
--                  who column.
--              p_last_update_login : OUT
--                  It contains the value to be used for the
--                  LAST_UPDATE_LOGIN who column.
--=======================================================
--   p_file_id - FND_LOAD_UTIL.OWNER_ID(<OWNER attribute from data file>)
--   p_file_lud - LAST_UPDATE_DATE attribute from data file
--   p_db_id - LAST_UPDATED_BY of db row
--   p_db_lud - LAST_UPDATE_DATE of db row
--   p_custom_mode - CUSTOM_MODE FNDLOAD parameter value
function IS_UPDATEABLE (
  p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
  p_created_by               IN OUT NOCOPY	NUMBER,
  p_creation_date            IN OUT NOCOPY	DATE,
  p_last_updated_by          IN OUT NOCOPY	NUMBER,
  p_db_last_updated_by	     IN 	NUMBER,
  p_last_update_date         IN OUT NOCOPY 	DATE,
  p_db_last_update_date      IN         DATE,
  p_last_update_login        IN	OUT NOCOPY	NUMBER,
  p_create_or_update	     IN         VARCHAR2)
return boolean is
  l_return_status varchar2(1);
  l_file_version number;
  l_created_by             number;
  l_creation_date          date;
  l_last_update_date       date;
  l_last_update_login      number;
  l_last_updated_by        number;
  l_custom_mode		   varchar2(8);
begin

  l_file_version := AK_ON_OBJECTS_PUB.G_UPLOAD_FILE_VERSION;
  if (AK_UPLOAD_GRP.G_UPDATE_MODE or p_create_or_update = 'FORCE') then
	l_custom_mode := 'FORCE';
  elsif (AK_UPLOAD_GRP.G_NO_CUSTOM_UPDATE) then
        l_custom_mode := 'NCUPDATE';
  else
	l_custom_mode := 'INVALID';
  end if;
  -- IF VERSION 120.1 OR GREATER USE FND_LOAD_UTIL COMPARISON LOGIC
  if (l_file_version = AK_ON_OBJECTS_PUB.G_FILE_FORMAT_VER and
     (p_create_or_update = 'UPDATE' or p_create_or_update = 'FORCE')) then
  	if FND_LOAD_UTIL.UPLOAD_TEST (
		p_file_id => p_last_updated_by,
		p_file_lud => p_last_update_date,
		p_db_id => p_db_last_updated_by,
	        p_db_lud => p_db_last_update_date,
                p_custom_mode => l_custom_mode)
        then
		return TRUE;
        else
		return FALSE;
        end if;

  /* ELSIF JLT PRIOR TO R12 DO OLD COMPARISON CHECKING */
  elsif (l_file_version <> AK_ON_OBJECTS_PUB.G_FILE_FORMAT_VER) then
     if (AK_UPLOAD_GRP.G_NO_CUSTOM_UPDATE) then
        if (p_db_last_updated_by <> 1 and p_db_last_updated_by <> 2) then
           return FALSE;
        end if;
     end if;
     AK_UPLOAD_GRP.G_UPLOAD_DATE := p_last_update_date;
     AK_ON_OBJECTS_PVT.SET_WHO (
       	p_return_status => l_return_status,
       	p_loader_timestamp => p_loader_timestamp,
       	p_created_by => l_created_by,
       	p_creation_date => l_creation_date,
       	p_last_updated_by => l_last_updated_by,
       	p_last_update_date => l_last_update_date,
       	p_last_update_login => l_last_update_login);

     if (AK_UPLOAD_GRP.G_NON_SEED_DATA) then
        l_created_by := p_created_by;
        l_last_updated_by := p_last_updated_by;
        l_last_update_login := p_last_update_login;
     end if;

     p_created_by := l_created_by;
     p_creation_date := l_creation_date;
     p_last_updated_by := l_last_updated_by;
     p_last_update_date := l_last_update_date;
     p_last_update_login := l_last_update_login;

     if p_create_or_update = 'CREATE' then
  	return TRUE;
     elsif
       ((AK_UPLOAD_GRP.G_COMPARE_UPDATE = TRUE and
        (l_file_version = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER15 or
        l_file_version = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER14) and
        (p_db_last_updated_by = 1 or p_last_update_date > p_db_last_update_date))  or
        (AK_UPLOAD_GRP.G_COMPARE_UPDATE = TRUE and
              ( l_file_version = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER1 or
                l_file_version = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER2 or
                l_file_version = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER3 or
                l_file_version = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER4 or
                l_file_version = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER5 or
                l_file_version = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER6 or
                l_file_version = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER7 or
                l_file_version = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER8 or
                l_file_version = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER9 or
                l_file_version = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER10 or
                l_file_version = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER11 or
                l_file_version = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER12) and
            p_db_last_updated_by = 1)  or
            AK_UPLOAD_GRP.G_COMPARE_UPDATE = FALSE)
        THEN
           return TRUE;
     else return FALSE;
     end if;
 else return FALSE;
 end if;
 return TRUE;
end IS_UPDATEABLE;

--=======================================================
--  Procedure   WRITE_FILE
--
--  Usage       Private procedure for writing the contents in a PL/SQL
--              table to global PL/SQL table.
--              This function is intended to be called only by other APIs
--              that are owned by the Core Modules Team (AK)
--
--  Desc        This procedure writes the contents in the PL/SQL table passed
--              into the specified file. The file could be overwritten
--              or appended depending on the value of the parameter
--              p_write_mode.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters
--              p_buffer_tbl : IN required
--                  The PL/SQL table of type Buffer_Tbl_Type whose
--                  content is to be written to a file.
--              p_write_mode : IN optional
--                  It must be G_APPEND or G_OVERWRITE if a value
--                  is given. It tells this procedure whether to
--                  write the PL/SQL table contents to the end of the
--                  file (default), or to overwrite the file with the
--                  contents in the PL/SQL table.
--=======================================================
procedure WRITE_FILE (
  p_return_status           OUT NOCOPY     VARCHAR2,
  p_buffer_tbl              IN      AK_ON_OBJECTS_PUB.Buffer_Tbl_Type,
  p_write_mode              IN      VARCHAR2 := AK_ON_OBJECTS_PUB.G_APPEND
) is
  l_api_name           CONSTANT varchar2(30) := 'Write_File';
  l_buf_len            NUMBER;
  l_buf_written        NUMBER := 0;
  l_char_to_write      NUMBER;
  l_index              NUMBER;
  l_tbl_index          NUMBER;
  l_string_pos         NUMBER;
  l_buffer             VARCHAR2(2000);
begin

  --
  -- return without doing anything if buffer is empty
  --
  if (p_buffer_tbl.count = 0) then
   p_return_status := FND_API.G_RET_STS_SUCCESS;
   return;
  end if;

  --
  -- indicate error if write mode is not G_APPEND or G_OVERWRITE
  --
  if (p_write_mode <> AK_ON_OBJECTS_PUB.G_APPEND) and
     (p_write_mode <> AK_ON_OBJECTS_PUB.G_OVERWRITE) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
      FND_MESSAGE.SET_NAME('AK','AK_INVALID_WRITE_MODE');
      FND_MSG_PUB.Add;
    end if;
    raise FND_API.G_EXC_ERROR;
  end if;

  -- If it's append mode, start appending to the end of the global table
  --
  if (p_write_mode = AK_ON_OBJECTS_PUB.G_OVERWRITE AND AK_DOWNLOAD_GRP.G_WRITE_HEADER) then
      G_TBL_INDEX := 0;
  end if;

  --
  -- Write all lines from buffer to ak_loader_temp table.
  -- And break long lines into mulitple lines in the file.
  --
  G_WRITE_MODE := p_write_mode;

  for l_index in p_buffer_tbl.first .. p_buffer_tbl.last LOOP
    if (p_buffer_tbl.exists(l_index)) then
      l_buf_len := length(p_buffer_tbl(l_index));
      l_buf_written := 0;
      WHILE (l_buf_len > l_buf_written) LOOP
        l_char_to_write := LEAST(G_MAX_FILE_LINE_LEN - 1,
                                  l_buf_len - l_buf_written);
        if (l_buf_len > l_buf_written + l_char_to_write) then
          --
          -- write line with trailing backslash indicating line to be continued
          --
		  G_TBL_INDEX := G_TBL_INDEX + 1;
          l_buffer := SUBSTR(p_buffer_tbl(l_index),
                                         l_buf_written + 1, l_char_to_write) ||
                                         '\';
          --
	      -- write line to a physical temporary table (AK_LOADER_TEMP) in database
		  --
		  WRITE_TO_TABLE (
			p_buffer => l_buffer);
        else
          --
          -- write line without trailing backslash
          --
		  G_TBL_INDEX := G_TBL_INDEX + 1;
          l_buffer := SUBSTR(p_buffer_tbl(l_index),
                                         l_buf_written + 1, l_char_to_write);

          --
	      -- write line to a physical temporary table (AK_LOADER_TEMP) in database
		  --
		  WRITE_TO_TABLE (
			p_buffer => l_buffer);
        end if;
        l_buf_written := l_buf_written + l_char_to_write;
      END LOOP;
    end if;

  END LOOP;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
end WRITE_FILE;

--=======================================================
--  Procedure   WRITE_LOG_FILE
--
--  Usage       Private procedure for writing the contents in a PL/SQL
--              table to a file.
--              This function is intended to be called only by other APIs
--              that are owned by the Core Modules Team (AK)
--
--  Desc        This procedure writes the contents in the PL/SQL table passed
--              into the specified file. The file could be overwritten
--              or appended depending on the value of the parameter
--              p_write_mode.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters
--              p_buffer_tbl : IN required
--                  The PL/SQL table of type Buffer_Tbl_Type whose
--                  content is to be written to a file.
--              p_write_mode : IN optional
--                  It must be G_APPEND or G_OVERWRITE if a value
--                  is given. It tells this procedure whether to
--                  write the PL/SQL table contents to the end of the
--                  file (default), or to overwrite the file with the
--                  contents in the PL/SQL table.
--=======================================================
procedure WRITE_LOG_FILE (
  p_return_status           OUT NOCOPY     VARCHAR2,
  p_buffer_tbl              IN      AK_ON_OBJECTS_PUB.Buffer_Tbl_Type,
  p_write_mode              IN      VARCHAR2 := AK_ON_OBJECTS_PUB.G_APPEND
) is
  l_api_name           CONSTANT varchar2(30) := 'Write_File';
  l_buf_len            NUMBER;
  l_buf_written        NUMBER := 0;
  l_char_to_write      NUMBER;
  l_index              NUMBER;
  l_tbl_index          NUMBER;
  l_string_pos         NUMBER;
begin
  --
  -- return without doing anything if buffer is empty
  --
  if (p_buffer_tbl.count = 0) then
   p_return_status := FND_API.G_RET_STS_SUCCESS;
   --G_LOG_BUFFER_TBL.DELETE;
   return;
  end if;

  --
  -- indicate error if write mode is not G_APPEND or G_OVERWRITE
  --
  if (p_write_mode <> AK_ON_OBJECTS_PUB.G_APPEND) and
     (p_write_mode <> AK_ON_OBJECTS_PUB.G_OVERWRITE) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
      FND_MESSAGE.SET_NAME('AK','AK_INVALID_WRITE_MODE');
      FND_MSG_PUB.Add;
    end if;
    raise FND_API.G_EXC_ERROR;
  end if;

  -- If it's append mode, start appending to the end of the global table
  --
  if (p_write_mode = AK_ON_OBJECTS_PUB.G_APPEND) then
      l_tbl_index := G_LOG_BUFFER_TBL.count;
  else
      l_tbl_index := 0;
  end if;

  --
  -- Write all lines from buffer to file.
  -- And break long lines into mulitple lines in the file.
  --
  l_tbl_index := 0;
  G_WRITE_MODE := p_write_mode;
  for l_index in p_buffer_tbl.first .. p_buffer_tbl.last LOOP
    if (p_buffer_tbl.exists(l_index)) then
      l_buf_len := length(p_buffer_tbl(l_index));
      l_buf_written := 0;
      WHILE (l_buf_len > l_buf_written) LOOP
        l_char_to_write := LEAST(G_MAX_FILE_LINE_LEN - 1,
                                  l_buf_len - l_buf_written);
        if (l_buf_len > l_buf_written + l_char_to_write) then
          --
          -- write line with trailing backslash indicating line to be continued
          --
		  l_tbl_index := l_tbl_index + 1;
          G_LOG_BUFFER_TBL(l_tbl_index) := SUBSTR(p_buffer_tbl(l_index),
                                         l_buf_written + 1, l_char_to_write) ||
                                         '\';
        else
          --
          -- write line without trailing backslash
          --
		  l_tbl_index := l_tbl_index + 1;
          G_LOG_BUFFER_TBL(l_tbl_index) := SUBSTR(p_buffer_tbl(l_index),
                                         l_buf_written + 1, l_char_to_write);
        end if;
        l_buf_written := l_buf_written + l_char_to_write;
      END LOOP;
    end if;
  END LOOP;
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN STORAGE_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
end WRITE_LOG_FILE;


-- Insert into AK_LOADER_TEMP
--
procedure WRITE_TO_TABLE (
	p_buffer	IN	VARCHAR2
	) is
	insert_err  EXCEPTION;
	err_num     NUMBER;
	err_msg     VARCHAR2(100);
	l_api_name  CONSTANT varchar2(30) := 'Write_To_Table';
begin
	INSERT INTO ak_loader_temp (
		tbl_index,
		line_content,
		session_id
		) values (
		G_TBL_INDEX,
		p_buffer,
		AK_ON_OBJECTS_PVT.G_SESSION_ID
		);

if SQL%ROWCOUNT = 0 then
--	dbms_output.put_line('no rows has been inserted into ak_loader_temp');
	raise insert_err;
elsif SQL%NOTFOUND then
--	dbms_output.put_line('Error SQL%NOTFOUND');
	raise insert_err;
end if;

-- commit;

EXCEPTION
	WHEN insert_err THEN
	--	dbms_output.put_line('Exception insert_err ak_loader_temp');
          FND_MESSAGE.SET_NAME('AK','AK_LOADER_TEMP_EXCEPTION');
          FND_MSG_PUB.Add;
	WHEN OTHERS THEN
          FND_MESSAGE.SET_NAME('AK','AK_LOADER_TEMP_ERROR');
	  FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    	  FND_MSG_PUB.Add;
	--	err_num := SQLCODE;
	--	err_msg := SUBSTR(SQLERRM, 1, 100);
	--	dbms_output.put_line('Other errors in inserting into ak_loader_temp');
	--	dbms_output.put_line(to_char(err_num)||' '||err_msg);

end WRITE_TO_TABLE;


--=======================================================
--  Function    VALID_APPLICATION_ID
--
--  Usage       Private function for validating an application ID. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This function checks to see if the given application ID is
--              a valid application ID in the FND_APPLICATION table.
--
--  Results     This  function returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_application_id : IN required
--                  The application ID that needs to be checked against
--                  the FND_APPLICATION table.
--              This function will return TRUE if the application ID
--              exists in the FND_APPLICATION table, or FALSE otherwise.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
function VALID_APPLICATION_ID (
  p_api_version_number      IN      NUMBER,
  p_return_status           OUT NOCOPY     VARCHAR2,
  p_application_id          IN      NUMBER
) return BOOLEAN is
  cursor l_check_appl_id_csr is
    select 1
    from  FND_APPLICATION
    where application_id = p_application_id;
  l_api_version_number CONSTANT number := 1.0;
  l_api_name           CONSTANT varchar2(30) := 'Valid_Application_ID';
  l_dummy number;
begin
  IF NOT FND_API.Compatible_API_Call (
    l_api_version_number, p_api_version_number, l_api_name,
    G_PKG_NAME) then
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return FALSE;
  END IF;

  open l_check_appl_id_csr;
  fetch l_check_appl_id_csr into l_dummy;
  if (l_check_appl_id_csr%notfound) then
    close l_check_appl_id_csr;
    p_return_status := FND_API.G_RET_STS_SUCCESS;
    return FALSE;
  else
    close l_check_appl_id_csr;
    p_return_status := FND_API.G_RET_STS_SUCCESS;
    return TRUE;
  end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
    return FALSE;
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    return FALSE;
end VALID_APPLICATION_ID;

--=======================================================
--  Function    VALID_LOOKUP_CODE
--
--  Usage       Private function for validating a lookup code. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This function checks to see if the given lookup type and
--              lookup code exists in the AK_LOOKUP_CODES table.
--
--  Results     This  function returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_lookup_type : IN required
--                  The type of the lookup code to be verified
--              p_lookup_code : IN required
--                  The lookup code to be verified against AK_LOOKUP_CODES
--              This function will return TRUE if the lookup type and
--              lookup code exists in the AK_LOOKUP_CODES table, or
--              FALSE otherwise.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
function VALID_LOOKUP_CODE (
  p_api_version_number      IN      NUMBER,
  p_return_status           OUT NOCOPY     VARCHAR2,
  p_lookup_type             IN      VARCHAR2,
  p_lookup_code             IN      VARCHAR2
) return BOOLEAN is
  cursor l_checklookup_csr (lookup_type_parm varchar2,
			    lookup_code_parm varchar2)is
    select 1
    from  AK_LOOKUP_CODES
    where lookup_type = lookup_type_parm
    and   lookup_code = lookup_code_parm;
  l_api_version_number CONSTANT number := 1.0;
  l_api_name           CONSTANT varchar2(30) := 'Valid_Application_ID';
  l_dummy number;
begin
  IF NOT FND_API.Compatible_API_Call (
    l_api_version_number, p_api_version_number, l_api_name,
    G_PKG_NAME) then
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return FALSE;
  END IF;

  open l_checklookup_csr (p_lookup_type, p_lookup_code);
  fetch l_checklookup_csr into l_dummy;
  if (l_checklookup_csr%notfound) then
    close l_checklookup_csr;
    p_return_status := FND_API.G_RET_STS_SUCCESS;
    return FALSE;
  else
    close l_checklookup_csr;
    p_return_status := FND_API.G_RET_STS_SUCCESS;
    return TRUE;
  end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
    return FALSE;
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    return FALSE;
end VALID_LOOKUP_CODE;

--=======================================================
--  Function    VALID_YES_NO
--
--  Usage       Private function for validating a Y/N column. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This function checks to see if the given value is
--              either 'Y' or 'N'. It is used for checking for valid
--              data in columns that accepts only 'Y' or 'N' as valid
--              values.
--
--  Results     This  function returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_value : IN required
--                  The value to be checked
--              This function will return TRUE if the value is either
--              'Y' or 'N', or FALSE otherwise.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
function VALID_YES_NO (
  p_value                  IN VARCHAR2
) return BOOLEAN is
begin
  return ((p_value = 'Y') or (p_value = 'N'));
end VALID_YES_NO;

end AK_ON_OBJECTS_PVT;

/
