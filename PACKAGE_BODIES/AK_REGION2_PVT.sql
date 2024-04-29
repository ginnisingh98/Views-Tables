--------------------------------------------------------
--  DDL for Package Body AK_REGION2_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AK_REGION2_PVT" as
/* $Header: akdvre2b.pls 120.4 2006/11/30 23:19:34 tshort ship $ */

--=======================================================
--  Procedure   UPLOAD_REGION
--
--  Usage       Private API for loading regions from a
--              loader file to the database.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API reads the region data (including region
--              items) stored in the loader file currently being
--              processed, parses the data, and loads them to the
--              database. The tables are updated with the timestamp
--              passed. This API will process the file until the
--              EOF is reached, a parse error is encountered, or when
--              data for a different business object is read from the file.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_index : IN OUT required
--                  Index of PL/SQL file to be processed.
--              p_loader_timestamp : IN required
--                  The timestamp to be used when creating or updating
--                  records
--              p_line_num : IN optional
--                  The first line number in the file to be processed.
--                  It is used for keeping track of the line number
--                  read so that this info can be included in the
--                  error message when a parse error occurred.
--              p_buffer : IN required
--                  The content of the first line to be processed.
--                  The calling API has already read the first line
--                  that needs to be parsed by this API, so this
--                  line won't be read from the file again.
--              p_line_num_out : OUT
--                  The number of the last line in the loader file
--                  that is read by this API.
--              p_buffer_out : OUT
--                  The content of the last line read by this API.
--                  If an EOF has not reached, this line would
--                  contain the beginning of another business object
--                  that will need to be processed by another API.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure UPLOAD_REGION (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_index                    IN OUT NOCOPY  NUMBER,
  p_loader_timestamp         IN      DATE,
  p_line_num                 IN NUMBER := FND_API.G_MISS_NUM,
  p_buffer                   IN AK_ON_OBJECTS_PUB.Buffer_Type,
  p_line_num_out             OUT NOCOPY    NUMBER,
  p_buffer_out               OUT NOCOPY    AK_ON_OBJECTS_PUB.Buffer_Type,
  p_upl_loader_cur           IN OUT NOCOPY  AK_ON_OBJECTS_PUB.LoaderCurTyp,
  p_pass                     IN      NUMBER := 1
) is
  cursor l_check_fnd_category_name_csr (p_category_id in number) is
     select name
     from fnd_document_categories
     where category_id = p_category_id;
  cursor l_check_fnd_category_id_csr (p_category_name in varchar2) is
     select category_id
     from fnd_document_categories
     where name =p_category_name;
  cursor l_get_region_item_csr (region_appl_id_param number,
  region_code_param varchar2) is
     select ATTRIBUTE_APPLICATION_ID, ATTRIBUTE_CODE
     from   AK_REGION_ITEMS
     where  region_application_id = region_appl_id_param
     and    region_code = region_code_param;
  l_api_version_number       CONSTANT number := 1.0;
  l_api_name                 CONSTANT varchar2(30) := 'Upload_Region';
  l_item_index               NUMBER := 0;
  l_item_rec                 AK_REGION_PUB.Item_Rec_Type;
  l_item_tbl                 AK_REGION_PUB.Item_Tbl_Type;
--  l_graph_index		     NUMBER := 0;
--  l_graph_rec		     AK_REGION_PUB.Graph_Rec_Type;
--  l_empty_graph_rec	     AK_REGION_PUB.Graph_Rec_Type;
--  l_graph_tbl		     AK_REGION_PUB.Graph_Tbl_Type;
--  l_graph_column_index	     NUMBER := 0;
--  l_graph_column_rec	     AK_REGION_GRAPH_COLUMNS%ROWTYPE;
--  l_empty_graph_column_rec   AK_REGION_GRAPH_COLUMNS%ROWTYPE;
--  l_graph_column_tbl	     AK_REGION_PUB.Graph_Column_Tbl_Type;
  l_buffer                   AK_ON_OBJECTS_PUB.Buffer_Type;
  l_column                   varchar2(30);
  l_dummy                    NUMBER;
  l_eof_flag                 VARCHAR2(1);
  l_index                    NUMBER;
  l_line_num                 NUMBER;
  l_lines_read               NUMBER;
  l_more_region              BOOLEAN := TRUE;
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(2000);
  l_region_index             NUMBER := 0;
  l_lov_relation_index		 NUMBER := 0;
  l_category_usage_index     NUMBER := 0;
  l_region_rec               AK_REGION_PUB.Region_Rec_Type;
  l_region_tbl               AK_REGION_PUB.Region_Tbl_Type;
  l_lov_relation_rec		 AK_REGION_LOV_RELATIONS%ROWTYPE;
  l_empty_lov_relation_rec	 AK_REGION_LOV_RELATIONS%ROWTYPE;
  l_lov_relation_tbl		 AK_REGION_PUB.Lov_Relation_Tbl_Type;
  l_category_usage_rec		 AK_CATEGORY_USAGES%ROWTYPE;
  l_empty_category_usage_rec	 AK_CATEGORY_USAGES%ROWTYPE;
  l_category_usage_tbl		 AK_REGION_PUB.Category_Usages_Tbl_Type;
  l_return_status            varchar2(1);
  l_saved_token              AK_ON_OBJECTS_PUB.Buffer_Type;
  l_state                    NUMBER;
  l_token                    AK_ON_OBJECTS_PUB.Buffer_Type;
  l_value_count              NUMBER;
  l_copy_redo_flag           BOOLEAN := FALSE;
  l_user_id1				 NUMBER;
  l_user_id2				 NUMBER;
  l_update1                  DATE;
  l_update2                  DATE;
begin
  --dbms_output.put_line('Started region upload: ' ||
  --                            to_char(sysdate, 'MON-DD HH24:MI:SS'));

  IF NOT FND_API.Compatible_API_Call (
    l_api_version_number, p_api_version_number, l_api_name,
    G_PKG_NAME) then
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return;
  END IF;

 -- 5665840 - removed savepoint as child  procedures do the savepoint/
 -- rollback/commit
  --SAVEPOINT Start_Upload;

  -- Retrieve the first non-blank, non-comment line
  l_state := 0;
  l_eof_flag := 'N';
  --
  -- if calling from ak_on_objects.upload (ie, loader timestamp is given),
  -- the tokens 'BEGIN REGION' has already been parsed. Set initial
  -- buffer to 'BEGIN REGION' before reading the next line from the
  -- file. Otherwise, set initial buffer to null.
  --
  if (p_loader_timestamp <> FND_API.G_MISS_DATE) then
    l_buffer := 'BEGIN REGION ' || p_buffer;
  else
    l_buffer := null;
  end if;

  if (p_line_num = FND_API.G_MISS_NUM) then
    l_line_num := 0;
  else
    l_line_num := p_line_num;
  end if;

  while (l_buffer is null and l_eof_flag = 'N' and p_index <=  AK_ON_OBJECTS_PVT.G_UPL_TABLE_NUM) loop
      AK_ON_OBJECTS_PVT.READ_LINE (
        p_return_status => l_return_status,
        p_index => p_index,
        p_buffer => l_buffer,
        p_lines_read => l_lines_read,
        p_eof_flag => l_eof_flag,
        p_upl_loader_cur => p_upl_loader_cur
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

  --
  -- Error if there is nothing to be read from the file
  --
  if (l_buffer is null and l_eof_flag = 'Y') then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_EMPTY_BUFFER');
      FND_MSG_PUB.Add;
    end if;
    raise FND_API.G_EXC_ERROR;
  end if;

  -- Read tokens from file, one at a time

  while (l_eof_flag = 'N') and (l_buffer is not null)
        and (l_more_region) loop

    AK_ON_OBJECTS_PVT.GET_TOKEN(
      p_return_status => l_return_status,
      p_in_buf => l_buffer,
      p_token => l_token
    );

--dbms_output.put_line(' State:' || l_state || 'Token:' || l_token);

    if (l_return_status = FND_API.G_RET_STS_ERROR) or
       (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.SET_NAME('AK','AK_GET_TOKEN_ERROR');
        FND_MSG_PUB.Add;
      end if;
      --dbms_output.put_line(l_api_name || ' Error parsing buffer');
      raise FND_API.G_EXC_ERROR;
    end if;


    --
    -- REGION (states 0 - 19)
    --
    if (l_state = 0) then
      if (l_token = 'BEGIN') then
        l_state := 1;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED','BEGIN');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 1) then
      if (l_token = 'REGION') then
        --== Clear out previous column data  ==--
    l_region_rec := AK_REGION_PUB.G_MISS_REGION_REC;
       l_state := 2;
      else
        -- Found the beginning of a non-region object,
        -- rebuild last line and pass it back to the caller
        -- (ak_on_objects_pvt.upload).
        p_buffer_out := 'BEGIN ' || l_token || ' ' || l_buffer;
        l_more_region := FALSE;
      end if;
    elsif (l_state = 2) then
      if (l_token is not null) then
        l_region_rec.region_application_id := to_number(l_token);
        l_state := 3;
      else
        --dbms_output.put_line('Expecting region application ID');
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 3) then
      if (l_token is not null) then
        l_region_rec.region_code := l_token;
        l_value_count := null;
        l_state := 10;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED','REGION_CODE');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 10) then
      if (l_token = 'BEGIN') then
        l_state := 13;
      elsif (l_token = 'END') then
        l_state := 19;
      elsif (l_token = 'DATABASE_OBJECT_NAME') or
        (l_token = 'REGION_STYLE') or
            (l_token = 'ICX_CUSTOM_CALL') or
            (l_token = 'NUM_COLUMNS') or
            (l_token = 'REGION_DEFAULTING_API_PKG') or
            (l_token = 'REGION_DEFAULTING_API_PROC') or
            (l_token = 'REGION_VALIDATION_API_PKG') or
            (l_token = 'REGION_VALIDATION_API_PROC') or
            (l_token = 'APPLICATIONMODULE_OBJECT_TYPE') or
            (l_token = 'NUM_ROWS_DISPLAY') or
            (l_token = 'REGION_OBJECT_TYPE') or
            (l_token = 'IMAGE_FILE_NAME') or
            (l_token = 'ISFORM_FLAG') or
			(l_token = 'HELP_TARGET') or
			(l_token = 'STYLE_SHEET_FILENAME') or
			(l_token = 'VERSION') or
			(l_token = 'APPLICATIONMODULE_USAGE_NAME') or
			(l_token = 'ADD_INDEXED_CHILDREN') or
			(l_token = 'STATEFUL_FLAG') or
			(l_token = 'FUNCTION_NAME') or
			(l_token = 'CHILDREN_VIEW_USAGE_NAME') or
			(l_token = 'SEARCH_PANEL') or
			(l_token = 'ADVANCED_SEARCH_PANEL') or
			(l_token = 'CUSTOMIZE_PANEL') or
			(l_token = 'DEFAULT_SEARCH_PANEL') or
			(l_token = 'RESULTS_BASED_SEARCH') or
			(l_token = 'DISPLAY_GRAPH_TABLE') or
                        (l_token = 'DISABLE_HEADER') or
                        (l_token = 'STANDALONE') or
			(l_token = 'AUTO_CUSTOMIZATION_CRITERIA') or
			(l_token = 'ATTRIBUTE_CATEGORY') or
			(l_token = 'ATTRIBUTE1') or
			(l_token = 'ATTRIBUTE2') or
			(l_token = 'ATTRIBUTE3') or
			(l_token = 'ATTRIBUTE4') or
			(l_token = 'ATTRIBUTE5') or
			(l_token = 'ATTRIBUTE6') or
			(l_token = 'ATTRIBUTE7') or
			(l_token = 'ATTRIBUTE8') or
			(l_token = 'ATTRIBUTE9') or
			(l_token = 'ATTRIBUTE10') or
			(l_token = 'ATTRIBUTE11') or
			(l_token = 'ATTRIBUTE12') or
			(l_token = 'ATTRIBUTE13') or
			(l_token = 'ATTRIBUTE14') or
			(l_token = 'ATTRIBUTE15') or
            (l_token = 'NAME') or
            (l_token = 'DESCRIPTION')  or
                        (l_token = 'CREATED_BY') or
                        (l_token = 'CREATION_DATE') or
                        (l_token = 'LAST_UPDATED_BY') or
                        (l_token = 'OWNER') or
                        (l_token = 'LAST_UPDATE_DATE') or
                        (l_token = 'LAST_UPDATE_LOGIN') then
        l_column := l_token;
        l_state := 11;
      else
      --
      -- error if not expecting attribute values added by the translation team
      -- or if we have read in more than a certain number of values
      -- for the same DB column
      --
        l_value_count := l_value_count + 1;
        --
        -- save second value. It will be the token with error if
        -- it turns out that there is a parse error on this line.
        --
        if (l_value_count = 2) then
          l_saved_token := l_token;
        end if;
        if (l_value_count > AK_ON_OBJECTS_PUB.G_MAX_NUM_LOADER_VALUES) or
           (l_value_count is null) then
          if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_EFIELD');
            FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
            if (l_value_count is null) then
              FND_MESSAGE.SET_TOKEN('TOKEN', l_token);
            else
              FND_MESSAGE.SET_TOKEN('TOKEN',l_saved_token);
            end if;
            FND_MESSAGE.SET_TOKEN('EXPECTED','REGION');
            FND_MSG_PUB.Add;
          end if;
--        dbms_output.put_line('Expecting region field, BEGIN, or END');
          raise FND_API.G_EXC_ERROR;
        end if;
      end if;
    elsif (l_state = 11) then
      if (l_token = '=') then
        l_state := 12;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED','=');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 12) then
      l_value_count := 1;
      if (l_column = 'DATABASE_OBJECT_NAME') then
         l_region_rec.database_object_name := l_token;
      elsif (l_column = 'REGION_STYLE') then
         l_region_rec.region_style := l_token;
      elsif (l_column = 'ICX_CUSTOM_CALL') then
         l_region_rec.icx_custom_call := l_token;
      elsif (l_column = 'NUM_COLUMNS') then
         l_region_rec.num_columns := to_number(l_token);
      elsif (l_column = 'REGION_DEFAULTING_API_PKG') then
         l_region_rec.region_defaulting_api_pkg := l_token;
      elsif (l_column = 'REGION_DEFAULTING_API_PROC') then
         l_region_rec.region_defaulting_api_proc := l_token;
      elsif (l_column = 'REGION_VALIDATION_API_PKG') then
         l_region_rec.region_validation_api_pkg := l_token;
      elsif (l_column = 'REGION_VALIDATION_API_PROC') then
         l_region_rec.region_validation_api_proc := l_token;
      elsif (l_column = 'APPLICATIONMODULE_OBJECT_TYPE') then
         l_region_rec.applicationmodule_object_type := l_token;
      elsif (l_column = 'NUM_ROWS_DISPLAY') then
         l_region_rec.num_rows_display := l_token;
      elsif (l_column = 'REGION_OBJECT_TYPE') then
         l_region_rec.region_object_type := l_token;
      elsif (l_column = 'IMAGE_FILE_NAME') then
         l_region_rec.image_file_name := l_token;
      elsif (l_column = 'ISFORM_FLAG') then
         l_region_rec.isform_flag := l_token;
      elsif (l_column = 'HELP_TARGET') then
         l_region_rec.help_target := l_token;
      elsif (l_column = 'STYLE_SHEET_FILENAME') then
         l_region_rec.style_sheet_filename := l_token;
      elsif (l_column = 'VERSION') then
         l_region_rec.version := l_token;
      elsif (l_column = 'APPLICATIONMODULE_USAGE_NAME') then
         l_region_rec.applicationmodule_usage_name := l_token;
      elsif (l_column = 'ADD_INDEXED_CHILDREN') then
         l_region_rec.add_indexed_children := l_token;
      elsif (l_column = 'STATEFUL_FLAG') then
         l_region_rec.stateful_flag := l_token;
      elsif (l_column = 'FUNCTION_NAME') then
         l_region_rec.function_name := l_token;
      elsif (l_column = 'CHILDREN_VIEW_USAGE_NAME') then
         l_region_rec.children_view_usage_name := l_token;
      elsif (l_column = 'SEARCH_PANEL') then
         l_region_rec.search_panel := l_token;
      elsif (l_column = 'ADVANCED_SEARCH_PANEL') then
         l_region_rec.advanced_search_panel := l_token;
      elsif (l_column = 'CUSTOMIZE_PANEL') then
         l_region_rec.customize_panel := l_token;
      elsif (l_column = 'DEFAULT_SEARCH_PANEL') then
         l_region_rec.default_search_panel := l_token;
      elsif (l_column = 'RESULTS_BASED_SEARCH') then
         l_region_rec.results_based_search := l_token;
      elsif (l_column = 'DISPLAY_GRAPH_TABLE') then
         l_region_rec.display_graph_table := l_token;
      elsif (l_column = 'DISABLE_HEADER') then
         l_region_rec.disable_header := l_token;
      elsif (l_column = 'STANDALONE') then
         l_region_rec.standalone := l_token;
      elsif (l_column = 'AUTO_CUSTOMIZATION_CRITERIA') then
         l_region_rec.auto_customization_criteria := l_token;
      elsif (l_column = 'ATTRIBUTE_CATEGORY') then
         l_region_rec.attribute_category := l_token;
      elsif (l_column = 'ATTRIBUTE1') then
         l_region_rec.attribute1 := l_token;
      elsif (l_column = 'ATTRIBUTE2') then
         l_region_rec.attribute2 := l_token;
      elsif (l_column = 'ATTRIBUTE3') then
         l_region_rec.attribute3 := l_token;
      elsif (l_column = 'ATTRIBUTE4') then
         l_region_rec.attribute4 := l_token;
      elsif (l_column = 'ATTRIBUTE5') then
         l_region_rec.attribute5 := l_token;
      elsif (l_column = 'ATTRIBUTE6') then
         l_region_rec.attribute6 := l_token;
      elsif (l_column = 'ATTRIBUTE7') then
         l_region_rec.attribute7 := l_token;
      elsif (l_column = 'ATTRIBUTE8') then
         l_region_rec.attribute8 := l_token;
      elsif (l_column = 'ATTRIBUTE9') then
         l_region_rec.attribute9 := l_token;
      elsif (l_column = 'ATTRIBUTE10') then
         l_region_rec.attribute10 := l_token;
      elsif (l_column = 'ATTRIBUTE11') then
         l_region_rec.attribute11 := l_token;
      elsif (l_column = 'ATTRIBUTE12') then
         l_region_rec.attribute12 := l_token;
      elsif (l_column = 'ATTRIBUTE13') then
         l_region_rec.attribute13 := l_token;
      elsif (l_column = 'ATTRIBUTE14') then
         l_region_rec.attribute14 := l_token;
      elsif (l_column = 'ATTRIBUTE15') then
         l_region_rec.attribute15 := l_token;
      elsif (l_column = 'NAME') then
         l_region_rec.name := l_token;
      elsif (l_column = 'DESCRIPTION') then
         l_region_rec.description := l_token;
      elsif (l_column = 'CREATED_BY') then
         l_region_rec.created_by := to_number(l_token);
      elsif (l_column = 'CREATION_DATE') then
         l_region_rec.creation_date := to_date(l_token,
                                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
      elsif (l_column = 'LAST_UPDATED_BY') then
         l_region_rec.last_updated_by := to_number(l_token);
      elsif (l_column = 'OWNER') then
         l_region_rec.last_updated_by := FND_LOAD_UTIL.OWNER_ID(l_token);
      elsif (l_column = 'LAST_UPDATE_DATE') then
         l_region_rec.last_update_date := to_date(l_token,
                                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
      elsif (l_column = 'LAST_UPDATE_LOGIN') then
         l_region_rec.last_update_login := to_number(l_token);
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', l_column);
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
      l_state := 10;
    elsif (l_state = 13) then
      if (l_token = 'REGION_ITEM') then
        --== Clear out previous region item column data  ==--
        --   and load region key values into record        --
		l_item_rec := AK_REGION_PUB.G_MISS_ITEM_REC;
        l_item_rec.region_application_id := l_region_rec.region_application_id;
        l_item_rec.region_code := l_region_rec.region_code;
        l_state := 20;
	  elsif ( l_token = 'REGION_LOV_RELATION') then
	    -- clear out previous region lov relation column data --
        --   and load region item key values into record        --
		l_lov_relation_rec := l_empty_lov_relation_rec;
		l_lov_relation_rec.region_application_id := l_item_rec.region_application_id;
		l_lov_relation_rec.region_code := l_item_rec.region_code;
		l_lov_relation_rec.attribute_application_id := l_item_rec.attribute_application_id;
		l_lov_relation_rec.attribute_code := l_item_rec.attribute_code;
		l_state := 100;
	  elsif ( l_token = 'CATEGORY_USAGE') then
	    -- clear out previous region lov relation column data --
        --   and load region item key values into record        --
		l_category_usage_rec := l_empty_category_usage_rec;
		l_category_usage_rec.region_application_id := l_item_rec.region_application_id;
		l_category_usage_rec.region_code := l_item_rec.region_code;
		l_category_usage_rec.attribute_application_id := l_item_rec.attribute_application_id;
		l_category_usage_rec.attribute_code := l_item_rec.attribute_code;
		l_state := 200;
	elsif (l_token = 'REGION_GRAPH') then
	  -- clear out previous region graph data --
	  -- and load region graph key values into record --
--	  	l_graph_rec := l_empty_graph_rec;
--		l_graph_rec.region_application_id := l_region_rec.region_application_id;
--		l_graph_rec.region_code := l_region_rec.region_code;
		l_state := 300;
	elsif (l_token = 'REGION_GRAPH_COLUMN') then
	  -- clear out previous region graph column data --
	  -- and load region graph column key values into record --
--		l_graph_column_rec := l_empty_graph_column_rec;
--		l_graph_column_rec.region_application_id := l_graph_rec.region_application_id;
--		l_graph_column_rec.region_code := l_graph_rec.region_code;
--		l_graph_column_rec.graph_number := l_graph_rec.graph_number;
		l_state := 400;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'REGION_ITEM, REGION_LOV_RELATION, CATEGORY_USAGE');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 19) then
      if (l_token = 'REGION') then
        l_state := 0;
        l_region_index := l_region_index + 1;
        l_region_tbl(l_region_index) := l_region_rec;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'REGION');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;

    --
    -- REGION_ITEM (states 20 - 39)
    --
    elsif (l_state = 20) then
      if (l_token is not null) then
        l_item_rec.attribute_application_id := to_number(l_token);
        l_state := 21;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'ATTRIBUTE_APPLICATION_ID');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 21) then
      if (l_token is not null) then
        l_item_rec.attribute_code := l_token;
        l_value_count := null;
        l_state := 30;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'ATTRIBUTE_CODE');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 30) then
      if (l_token = 'END') then
        l_state := 39;
	  elsif (l_token = 'BEGIN') then
		l_state := 13;
      elsif (l_token = 'DISPLAY_SEQUENCE') or
        (l_token = 'NODE_DISPLAY_FLAG') or
        (l_token = 'NODE_QUERY_FLAG') or
            (l_token = 'ATTRIBUTE_LABEL_LENGTH') or
            (l_token = 'DISPLAY_VALUE_LENGTH') or
            (l_token = 'BOLD') or
            (l_token = 'ITALIC') or
            (l_token = 'VERTICAL_ALIGNMENT') or
            (l_token = 'HORIZONTAL_ALIGNMENT') or
            (l_token = 'ITEM_STYLE') or
            (l_token = 'OBJECT_ATTRIBUTE_FLAG') or
            (l_token = 'ICX_CUSTOM_CALL') or
            (l_token = 'UPDATE_FLAG') or
            (l_token = 'REQUIRED_FLAG') or
            (l_token = 'SECURITY_CODE') or
            (l_token = 'DEFAULT_VALUE_VARCHAR2') or
            (l_token = 'DEFAULT_VALUE_NUMBER') or
            (l_token = 'DEFAULT_VALUE_DATE') or
            (l_token = 'LOV_REGION') or
            (l_token = 'LOV_FOREIGN_KEY_NAME') or
            (l_token = 'LOV_ATTRIBUTE') or
            (l_token = 'LOV_DEFAULT_FLAG') or
            (l_token = 'REGION_DEFAULTING_API_PKG') or
            (l_token = 'REGION_DEFAULTING_API_PROC') or
            (l_token = 'REGION_VALIDATION_API_PKG') or
            (l_token = 'REGION_VALIDATION_API_PROC') or
            (l_token = 'ORDER_SEQUENCE') or
	    (l_token = 'INITIAL_SORT_SEQUENCE') or
	    (l_token = 'CUSTOMIZATION_APPLICATION_ID') or
            (l_token = 'CUSTOMIZATION_CODE') or
            (l_token = 'ORDER_DIRECTION') or
            (l_token = 'SUBMIT') or
            (l_token = 'ENCRYPT') or
            (l_token = 'DISPLAY_HEIGHT') or
            (l_token = 'CSS_CLASS_NAME') or
            (l_token = 'VIEW_USAGE_NAME') or
            (l_token = 'VIEW_ATTRIBUTE_NAME') or
            (l_token = 'NESTED_REGION_APPLICATION_ID') or
            (l_token = 'NESTED_REGION_CODE') or
            (l_token = 'URL') or
            (l_token = 'POPLIST_VIEWOBJECT') or
            (l_token = 'POPLIST_DISPLAY_ATTRIBUTE') or
            (l_token = 'POPLIST_VALUE_ATTRIBUTE') or
            (l_token = 'IMAGE_FILE_NAME') or
            (l_token = 'ITEM_NAME') or
            (l_token = 'CSS_LABEL_CLASS_NAME') or
			(l_token = 'MENU_NAME') or
			(l_token = 'FLEXFIELD_NAME') or
			(l_token = 'FLEXFIELD_APPLICATION_ID') or
			(l_token = 'TABULAR_FUNCTION_CODE') or
			(l_token = 'TIP_TYPE') or
			(l_token = 'TIP_MESSAGE_NAME') or
			(l_token = 'TIP_MESSAGE_APPLICATION_ID') or
			(l_token = 'FLEX_SEGMENT_LIST') or
			(l_token = 'ENTITY_ID') or
			(l_token = 'ANCHOR') or
			(l_token = 'POPLIST_VIEW_USAGE_NAME') or
                        (l_token = 'USER_CUSTOMIZABLE') or
			(l_token = 'SORTBY_VIEW_ATTRIBUTE_NAME') or
			(l_token = 'ADMIN_CUSTOMIZABLE') or
			(l_token = 'INVOKE_FUNCTION_NAME') or
			(l_token = 'EXPANSION') or
			(l_token = 'ALS_MAX_LENGTH') or
			(l_token = 'ATTRIBUTE_CATEGORY') or
			(l_token = 'ATTRIBUTE1') or
			(l_token = 'ATTRIBUTE2') or
			(l_token = 'ATTRIBUTE3') or
			(l_token = 'ATTRIBUTE4') or
			(l_token = 'ATTRIBUTE5') or
			(l_token = 'ATTRIBUTE6') or
			(l_token = 'ATTRIBUTE7') or
			(l_token = 'ATTRIBUTE8') or
			(l_token = 'ATTRIBUTE9') or
			(l_token = 'ATTRIBUTE10') or
			(l_token = 'ATTRIBUTE11') or
			(l_token = 'ATTRIBUTE12') or
			(l_token = 'ATTRIBUTE13') or
			(l_token = 'ATTRIBUTE14') or
			(l_token = 'ATTRIBUTE15') or
                        (l_token = 'CREATED_BY') or
                        (l_token = 'CREATION_DATE') or
                        (l_token = 'LAST_UPDATED_BY') or
                        (l_token = 'OWNER') or
                        (l_token = 'LAST_UPDATE_DATE') or
                        (l_token = 'LAST_UPDATE_LOGIN') or
            (l_token = 'ATTRIBUTE_LABEL_LONG') or
            (l_token = 'ATTRIBUTE_LABEL_SHORT') or
            (l_token = 'DESCRIPTION') then
        l_column := l_token;
        l_state := 31;
      else
      --
      -- error if not expecting attribute values added by the translation team
      -- or if we have read in more than a certain number of values
      -- for the same DB column
      --
        l_value_count := l_value_count + 1;
        --
        -- save second value. It will be the token with error if
        -- it turns out that there is a parse error on this line.
        --
        if (l_value_count = 2) then
          l_saved_token := l_token;
        end if;
        if (l_value_count > AK_ON_OBJECTS_PUB.G_MAX_NUM_LOADER_VALUES) or
           (l_value_count is null) then
          if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_EFIELD');
            FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
            if (l_value_count is null) then
              FND_MESSAGE.SET_TOKEN('TOKEN', l_token);
            else
              FND_MESSAGE.SET_TOKEN('TOKEN',l_saved_token);
            end if;
            FND_MESSAGE.SET_TOKEN('EXPECTED','REGION_ITEM');
            FND_MSG_PUB.Add;
          end if;
          raise FND_API.G_EXC_ERROR;
        end if;
      end if;
    elsif (l_state = 31) then
      if (l_token = '=') then
        l_state := 32;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', '=');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 32) then
      l_value_count := 1;
      if (l_column = 'DISPLAY_SEQUENCE') then
         l_item_rec.DISPLAY_SEQUENCE := to_number(l_token);
         l_state := 30;
      elsif (l_column = 'NODE_DISPLAY_FLAG') then
         l_item_rec.NODE_DISPLAY_FLAG := l_token;
         l_state := 30;
      elsif (l_column = 'NODE_QUERY_FLAG') then
         l_item_rec.NODE_QUERY_FLAG := l_token;
         l_state := 30;
      elsif (l_column = 'ATTRIBUTE_LABEL_LENGTH') then
         l_item_rec.ATTRIBUTE_LABEL_LENGTH := to_number(l_token);
         l_state := 30;
      elsif (l_column = 'DISPLAY_VALUE_LENGTH') then
         l_item_rec.DISPLAY_VALUE_LENGTH := to_number(l_token);
         l_state := 30;
      elsif (l_column = 'BOLD') then
         l_item_rec.BOLD := l_token;
         l_state := 30;
      elsif (l_column = 'ITALIC') then
         l_item_rec.ITALIC := l_token;
         l_state := 30;
      elsif (l_column = 'VERTICAL_ALIGNMENT') then
         l_item_rec.VERTICAL_ALIGNMENT := l_token;
         l_state := 30;
      elsif (l_column = 'HORIZONTAL_ALIGNMENT') then
         l_item_rec.HORIZONTAL_ALIGNMENT := l_token;
         l_state := 30;
      elsif (l_column = 'ITEM_STYLE') then
         l_item_rec.ITEM_STYLE := l_token;
         l_state := 30;
      elsif (l_column = 'OBJECT_ATTRIBUTE_FLAG') then
         l_item_rec.OBJECT_ATTRIBUTE_FLAG := l_token;
         l_state := 30;
      elsif (l_column = 'ICX_CUSTOM_CALL') then
         l_item_rec.ICX_CUSTOM_CALL := l_token;
         l_state := 30;
      elsif (l_column = 'UPDATE_FLAG') then
         l_item_rec.update_flag := l_token;
         l_state := 30;
      elsif (l_column = 'REQUIRED_FLAG') then
         l_item_rec.required_flag := l_token;
         l_state := 30;
      elsif (l_column = 'SECURITY_CODE') then
         l_item_rec.security_code := l_token;
         l_state := 30;
      elsif (l_column = 'DEFAULT_VALUE_VARCHAR2') then
         l_item_rec.default_value_varchar2 := l_token;
         l_state := 30;
      elsif (l_column = 'DEFAULT_VALUE_NUMBER') then
         l_item_rec.default_value_number := to_number(l_token);
         l_state := 30;
      elsif (l_column = 'DEFAULT_VALUE_DATE') then
         l_item_rec.default_value_date := to_date(l_token,
                                               AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
         l_state := 30;
      elsif (l_column = 'LOV_REGION') then
         l_item_rec.lov_region_application_id := to_number(l_token);
         l_state := 34;
      elsif (l_column = 'LOV_FOREIGN_KEY_NAME') then
         l_item_rec.lov_foreign_key_name := l_token;
         l_state := 30;
      elsif (l_column = 'LOV_ATTRIBUTE') then
         l_item_rec.lov_attribute_application_id := to_number(l_token);
         l_state := 34;
      elsif (l_column = 'LOV_DEFAULT_FLAG') then
         l_item_rec.lov_default_flag := l_token;
         l_state := 30;
      elsif (l_column = 'REGION_DEFAULTING_API_PKG') then
         l_item_rec.REGION_defaulting_api_pkg := l_token;
         l_state := 30;
      elsif (l_column = 'REGION_DEFAULTING_API_PROC') then
         l_item_rec.REGION_defaulting_api_proc := l_token;
         l_state := 30;
      elsif (l_column = 'REGION_VALIDATION_API_PKG') then
         l_item_rec.REGION_validation_api_pkg := l_token;
         l_state := 30;
      elsif (l_column = 'REGION_VALIDATION_API_PROC') then
         l_item_rec.REGION_validation_api_proc := l_token;
         l_state := 30;
      elsif (l_column = 'ORDER_SEQUENCE') then
         l_item_rec.order_sequence := to_number(l_token);
         l_state := 30;
      elsif (l_column = 'INITIAL_SORT_SEQUENCE') then
	 l_item_rec.initial_sort_sequence := l_token;
         l_state := 30;
      elsif (l_column = 'CUSTOMIZATION_APPLICATION_ID') then
         l_item_rec.customization_application_id := l_token;
         l_state := 30;
      elsif (l_column = 'CUSTOMIZATION_CODE') then
         l_item_rec.customization_code := l_token;
         l_state := 30;
      elsif (l_column = 'ORDER_DIRECTION') then
         l_item_rec.ORDER_DIRECTION := l_token;
         l_state := 30;
      elsif (l_column = 'SUBMIT') then
         l_item_rec.SUBMIT := l_token;
         l_state := 30;
      elsif (l_column = 'ENCRYPT') then
         l_item_rec.ENCRYPT := l_token;
         l_state := 30;
      elsif (l_column = 'DISPLAY_HEIGHT') then
         l_item_rec.DISPLAY_HEIGHT := to_number(l_token);
         l_state := 30;
      elsif (l_column = 'CSS_CLASS_NAME') then
         l_item_rec.CSS_CLASS_NAME := l_token;
         l_state := 30;
      elsif (l_column = 'VIEW_USAGE_NAME') then
         l_item_rec.VIEW_USAGE_NAME := l_token;
         l_state := 30;
      elsif (l_column = 'VIEW_ATTRIBUTE_NAME') then
         l_item_rec.VIEW_ATTRIBUTE_NAME := l_token;
         l_state := 30;
      elsif (l_column = 'NESTED_REGION_APPLICATION_ID') then
         l_item_rec.NESTED_REGION_APPLICATION_ID := to_number(l_token);
         l_state := 30;
      elsif (l_column = 'NESTED_REGION_CODE') then
         l_item_rec.NESTED_REGION_CODE := l_token;
         l_state := 30;
      elsif (l_column = 'URL') then
         l_item_rec.URL := l_token;
         l_state := 30;
      elsif (l_column = 'POPLIST_VIEWOBJECT') then
         l_item_rec.POPLIST_VIEWOBJECT := l_token;
         l_state := 30;
      elsif (l_column = 'POPLIST_DISPLAY_ATTRIBUTE') then
         l_item_rec.POPLIST_DISPLAY_ATTR := l_token;
         l_state := 30;
      elsif (l_column = 'POPLIST_VALUE_ATTRIBUTE') then
         l_item_rec.POPLIST_VALUE_ATTR := l_token;
         l_state := 30;
      elsif (l_column = 'IMAGE_FILE_NAME') then
         l_item_rec.IMAGE_FILE_NAME := l_token;
         l_state := 30;
      elsif (l_column = 'ITEM_NAME') then
         l_item_rec.ITEM_NAME := l_token;
         l_state := 30;
      elsif (l_column = 'CSS_LABEL_CLASS_NAME') then
         l_item_rec.CSS_LABEL_CLASS_NAME := l_token;
         l_state := 30;
      elsif (l_column = 'MENU_NAME') then
         l_item_rec.MENU_NAME := l_token;
         l_state := 30;
      elsif (l_column = 'FLEXFIELD_NAME') then
         l_item_rec.FLEXFIELD_NAME := l_token;
         l_state := 30;
      elsif (l_column = 'FLEXFIELD_APPLICATION_ID') then
         l_item_rec.FLEXFIELD_APPLICATION_ID := l_token;
         l_state := 30;
      elsif (l_column = 'TABULAR_FUNCTION_CODE') then
         l_item_rec.TABULAR_FUNCTION_CODE := l_token;
         l_state := 30;
      elsif (l_column = 'TIP_TYPE') then
         l_item_rec.TIP_TYPE := l_token;
         l_state := 30;
      elsif (l_column = 'TIP_MESSAGE_NAME') then
         l_item_rec.TIP_MESSAGE_NAME := l_token;
         l_state := 30;
      elsif (l_column = 'TIP_MESSAGE_APPLICATION_ID') then
         l_item_rec.TIP_MESSAGE_APPLICATION_ID := l_token;
         l_state := 30;
      elsif (l_column = 'FLEX_SEGMENT_LIST') then
         l_item_rec.FLEX_SEGMENT_LIST := l_token;
         l_state := 30;
      elsif (l_column = 'ENTITY_ID') then
         l_item_rec.ENTITY_ID := l_token;
         l_state := 30;
      elsif (l_column = 'ANCHOR') then
         l_item_rec.ANCHOR := l_token;
         l_state := 30;
      elsif (l_column = 'POPLIST_VIEW_USAGE_NAME') then
         l_item_rec.POPLIST_VIEW_USAGE_NAME := l_token;
         l_state := 30;
      elsif (l_column = 'USER_CUSTOMIZABLE') then
         l_item_rec.USER_CUSTOMIZABLE := l_token;
         l_state := 30;
      elsif (l_column = 'SORTBY_VIEW_ATTRIBUTE_NAME') then
         l_item_rec.SORTBY_VIEW_ATTRIBUTE_NAME := l_token;
         l_state := 30;
      elsif (l_column = 'ADMIN_CUSTOMIZABLE') then
	 l_item_rec.ADMIN_CUSTOMIZABLE := l_token;
	 l_state := 30;
      elsif (l_column = 'INVOKE_FUNCTION_NAME') then
	 l_item_rec.INVOKE_FUNCTION_NAME := l_token;
	 l_state := 30;
      elsif (l_column = 'EXPANSION') then
         l_item_rec.EXPANSION := l_token;
         l_state := 30;
      elsif (l_column = 'ALS_MAX_LENGTH') then
         l_item_rec.ALS_MAX_LENGTH := l_token;
         l_state := 30;
      elsif (l_column = 'ATTRIBUTE_CATEGORY') then
         l_item_rec.attribute_category := l_token;
         l_state := 30;
      elsif (l_column = 'ATTRIBUTE1') then
         l_item_rec.attribute1 := l_token;
         l_state := 30;
      elsif (l_column = 'ATTRIBUTE2') then
         l_item_rec.attribute2 := l_token;
         l_state := 30;
      elsif (l_column = 'ATTRIBUTE3') then
         l_item_rec.attribute3 := l_token;
         l_state := 30;
      elsif (l_column = 'ATTRIBUTE4') then
         l_item_rec.attribute4 := l_token;
         l_state := 30;
      elsif (l_column = 'ATTRIBUTE5') then
         l_item_rec.attribute5 := l_token;
         l_state := 30;
      elsif (l_column = 'ATTRIBUTE6') then
         l_item_rec.attribute6 := l_token;
         l_state := 30;
      elsif (l_column = 'ATTRIBUTE7') then
         l_item_rec.attribute7 := l_token;
         l_state := 30;
      elsif (l_column = 'ATTRIBUTE8') then
         l_item_rec.attribute8 := l_token;
         l_state := 30;
      elsif (l_column = 'ATTRIBUTE9') then
         l_item_rec.attribute9 := l_token;
         l_state := 30;
      elsif (l_column = 'ATTRIBUTE10') then
         l_item_rec.attribute10 := l_token;
         l_state := 30;
      elsif (l_column = 'ATTRIBUTE11') then
         l_item_rec.attribute11 := l_token;
         l_state := 30;
      elsif (l_column = 'ATTRIBUTE12') then
         l_item_rec.attribute12 := l_token;
         l_state := 30;
      elsif (l_column = 'ATTRIBUTE13') then
         l_item_rec.attribute13 := l_token;
         l_state := 30;
      elsif (l_column = 'ATTRIBUTE14') then
         l_item_rec.attribute14 := l_token;
         l_state := 30;
      elsif (l_column = 'ATTRIBUTE15') then
         l_item_rec.attribute15 := l_token;
         l_state := 30;
      elsif (l_column = 'CREATED_BY') then
         l_item_rec.created_by := to_number(l_token);
         l_state := 30;
      elsif (l_column = 'CREATION_DATE') then
         l_item_rec.creation_date := to_date(l_token,
                                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
         l_state := 30;
      elsif (l_column = 'LAST_UPDATED_BY') then
         l_item_rec.last_updated_by := to_number(l_token);
         l_state := 30;
      elsif (l_column = 'OWNER') then
         l_item_rec.last_updated_by := FND_LOAD_UTIL.OWNER_ID(l_token);
         l_state := 30;
      elsif (l_column = 'LAST_UPDATE_DATE') then
         l_item_rec.last_update_date := to_date(l_token,
                                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
         l_state := 30;
      elsif (l_column = 'LAST_UPDATE_LOGIN') then
         l_item_rec.last_update_login := to_number(l_token);
         l_state := 30;
      elsif (l_column = 'ATTRIBUTE_LABEL_LONG') then
         l_item_rec.ATTRIBUTE_LABEL_LONG := l_token;
         l_state := 30;
      elsif (l_column = 'ATTRIBUTE_LABEL_SHORT') then
         l_item_rec.ATTRIBUTE_LABEL_SHORT := l_token;
         l_state := 30;
      elsif (l_column = 'DESCRIPTION') then
         l_item_rec.DESCRIPTION := l_token;
         l_state := 30;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', l_column || ' value');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 34) then
      if (l_column = 'LOV_REGION') then
         l_item_rec.lov_region_code := l_token;
         l_state := 30;
      elsif (l_column = 'LOV_ATTRIBUTE') then
         l_item_rec.lov_attribute_code := l_token;
         l_state := 30;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', l_column);
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 39) then
      if (l_token = 'REGION_ITEM') then
        l_value_count := null;
        l_state := 10;
        l_item_index := l_item_index + 1;
        l_item_tbl(l_item_index) := l_item_rec;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'REGION_ITEM');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;

    --
    -- REGION_LOV_RELATION (states 100 - 139)
    --
    elsif (l_state = 100) then
      if (l_token is not null) then
        l_lov_relation_rec.lov_region_appl_id := to_number(l_token);
        l_state := 101;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'LOV_REGION_APPL_ID');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 101) then
      if (l_token is not null) then
        l_lov_relation_rec.lov_region_code := l_token;
        l_value_count := null;
        l_state := 102;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'LOV_REGION_CODE');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 102) then
      if (l_token is not null) then
        l_lov_relation_rec.lov_attribute_appl_id := to_number(l_token);
        l_state := 103;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'LOV_ATTRIBUTE_APPL_ID');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 103) then
      if (l_token is not null) then
        l_lov_relation_rec.lov_attribute_code := l_token;
        l_value_count := null;
        l_state := 104;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'LOV_ATTRIBUTE_CODE');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 104) then
      if (l_token is not null) then
        l_lov_relation_rec.base_attribute_appl_id := to_number(l_token);
        l_state := 105;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'BASE_ATTRIBUTE_APPL_ID');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 105) then
      if (l_token is not null) then
        l_lov_relation_rec.base_attribute_code := l_token;
        l_value_count := null;
        l_state := 106;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'BASE_ATTRIBUTE_CODE');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 106) then
      if (l_token is not null) then
        l_lov_relation_rec.direction_flag := l_token;
        l_value_count := null;
        l_state := 130;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'DIRECTION_FLAG');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 130) then
      if (l_token = 'END') then
        l_state := 139;
	  elsif ( l_token = 'BASE_REGION_APPL_ID' ) or
		( l_token = 'BASE_REGION_CODE' ) or
		( l_token = 'REQUIRED_FLAG' ) or
		(l_token = 'CREATED_BY') or
		(l_token = 'CREATION_DATE') or
		(l_token = 'LAST_UPDATED_BY') or
                (l_token = 'OWNER') or
		(l_token = 'LAST_UPDATE_DATE') or
		(l_token = 'LAST_UPDATE_LOGIN') then
        l_column := l_token;
        l_state := 131;
      else
      --
      -- error if not expecting attribute values added by the translation team
      -- or if we have read in more than a certain number of values
      -- for the same DB column
      --
        l_value_count := l_value_count + 1;
        --
        -- save second value. It will be the token with error if
        -- it turns out that there is a parse error on this line.
        --
        if (l_value_count = 2) then
          l_saved_token := l_token;
        end if;
        if (l_value_count > AK_ON_OBJECTS_PUB.G_MAX_NUM_LOADER_VALUES) or
           (l_value_count is null) then
          if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_EFIELD');
            FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
            if (l_value_count is null) then
              FND_MESSAGE.SET_TOKEN('TOKEN', l_token);
            else
              FND_MESSAGE.SET_TOKEN('TOKEN',l_saved_token);
            end if;
            FND_MESSAGE.SET_TOKEN('EXPECTED','REGION_LOV_RELATION');
            FND_MSG_PUB.Add;
          end if;
          raise FND_API.G_EXC_ERROR;
        end if;
      end if;
    elsif (l_state = 131) then
      if (l_token = '=') then
        l_state := 132;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', '=');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 132) then
      l_value_count := 1;
      if (l_column = 'BASE_REGION_APPL_ID') then
        l_lov_relation_rec.BASE_REGION_APPL_ID := to_number(l_token);
        l_state := 130;
      elsif (l_column = 'BASE_REGION_CODE') then
         l_lov_relation_rec.BASE_REGION_CODE := l_token;
         l_state := 130;
      elsif (l_column = 'REQUIRED_FLAG') then
         l_lov_relation_rec.REQUIRED_FLAG := l_token;
         l_state := 130;
      elsif (l_column = 'CREATED_BY') then
         l_lov_relation_rec.created_by := to_number(l_token);
         l_state := 130;
      elsif (l_column = 'CREATION_DATE') then
         l_lov_relation_rec.creation_date := to_date(l_token,
                                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
         l_state := 130;
      elsif (l_column = 'LAST_UPDATED_BY') then
         l_lov_relation_rec.last_updated_by := to_number(l_token);
         l_state := 130;
      elsif (l_column = 'OWNER') then
         l_lov_relation_rec.last_updated_by := FND_LOAD_UTIL.OWNER_ID(l_token);
         l_state := 130;
      elsif (l_column = 'LAST_UPDATE_DATE') then
         l_lov_relation_rec.last_update_date := to_date(l_token,
                                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
         l_state := 130;
      elsif (l_column = 'LAST_UPDATE_LOGIN') then
         l_lov_relation_rec.last_update_login := to_number(l_token);
         l_state := 130;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', l_column || ' value');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 139) then
      if (l_token = 'REGION_LOV_RELATION') then
        l_value_count := null;
        l_state := 30;
        l_lov_relation_index := l_lov_relation_index + 1;
        l_lov_relation_tbl(l_lov_relation_index) := l_lov_relation_rec;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'REGION_LOV_RELATION');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;

    --
    -- CATEGORY_USAGE (states 200 - 239)
    --
    elsif (l_state = 200) then
      if (l_token is not null) then
        l_category_usage_rec.category_id := to_number(l_token);
--	select name into l_category_usage_rec.category_name from fnd_document_categories where category_id = l_category_usage_rec.category_id;
        l_value_count := null;
        l_state := 230;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'CATEGORY_ID');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 230) then
      if (l_token = 'END') then
        l_state := 239;
	elsif (l_token = 'CATEGORY_NAME') or
		(l_token = 'APPLICATION_ID') or
		(l_token = 'SHOW_ALL') or
                        (l_token = 'CREATED_BY') or
                        (l_token = 'CREATION_DATE') or
                        (l_token = 'LAST_UPDATED_BY') or
                        (l_token = 'OWNER') or
                        (l_token = 'LAST_UPDATE_DATE') or
                        (l_token = 'LAST_UPDATE_LOGIN') then
	l_column := l_token;
	l_state := 231;
      else
      --
      -- error if not expecting attribute values added by the translation team
      -- or if we have read in more than a certain number of values
      -- for the same DB column
      --
        l_value_count := l_value_count + 1;
        --
        -- save second value. It will be the token with error if
        -- it turns out that there is a parse error on this line.
        --
        if (l_value_count = 2) then
          l_saved_token := l_token;
        end if;
        if (l_value_count > AK_ON_OBJECTS_PUB.G_MAX_NUM_LOADER_VALUES) or
           (l_value_count is null) then
          if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_EFIELD');
            FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
            if (l_value_count is null) then
              FND_MESSAGE.SET_TOKEN('TOKEN', l_token);
            else
              FND_MESSAGE.SET_TOKEN('TOKEN',l_saved_token);
            end if;
            FND_MESSAGE.SET_TOKEN('EXPECTED','CATEGORY_USAGE');
            FND_MSG_PUB.Add;
          end if;
          raise FND_API.G_EXC_ERROR;
        end if;
      end if;
    elsif (l_state = 231) then
      if (l_token = '=') then
        l_state := 232;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', '=');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 232) then
      l_value_count := 1;
      if (l_column = 'CATEGORY_NAME') then
	 l_category_usage_rec.CATEGORY_NAME := l_token;
	 l_state := 230;
      elsif (l_column = 'APPLICATION_ID') then
         l_category_usage_rec.APPLICATION_ID := to_number(l_token);
         l_state := 230;
      elsif (l_column = 'SHOW_ALL') then
         l_category_usage_rec.SHOW_ALL := l_token;
         l_state := 230;
      elsif (l_column = 'CREATED_BY') then
         l_category_usage_rec.created_by := to_number(l_token);
         l_state := 230;
      elsif (l_column = 'CREATION_DATE') then
         l_category_usage_rec.creation_date := to_date(l_token,
                                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
         l_state := 230;
      elsif (l_column = 'LAST_UPDATED_BY') then
         l_category_usage_rec.last_updated_by := to_number(l_token);
         l_state := 230;
      elsif (l_column = 'OWNER') then
         l_category_usage_rec.last_updated_by := FND_LOAD_UTIL.OWNER_ID(l_token);
         l_state := 230;
      elsif (l_column = 'LAST_UPDATE_DATE') then
         l_category_usage_rec.last_update_date := to_date(l_token,
                                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
         l_state := 230;
      elsif (l_column = 'LAST_UPDATE_LOGIN') then
         l_category_usage_rec.last_update_login := to_number(l_token);
         l_state := 230;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', l_column || ' value');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 239) then
      if (l_token = 'CATEGORY_USAGE') then
        l_value_count := null;
        l_state := 30;
        l_category_usage_index := l_category_usage_index + 1;
        l_category_usage_tbl(l_category_usage_index) := l_category_usage_rec;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'CATEGORY_USAGE');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;

    --
    -- REGION_GRAPH (states 300 - 339)
    --
    elsif (l_state = 300) then
      if (l_token is not null) then
--        l_graph_rec.graph_number := to_number(l_token);
 	l_state := 310;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'GRAPH_NUMBER');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 310) then
      if (l_token = 'END') then
        l_state := 319;
          elsif (l_token = 'BEGIN') then
                l_state := 13;
      elsif (l_token = 'GRAPH_STYLE') or
		(l_token = 'DISPLAY_FLAG') or
		(l_token = 'DEPTH_RADIUS') or
		(l_token = 'GRAPH_TITLE') or
		(l_token = 'Y_AXIS_LABEL') or
                        (l_token = 'CREATED_BY') or
                        (l_token = 'CREATION_DATE') or
                        (l_token = 'LAST_UPDATED_BY') or
                        (l_token = 'LAST_UPDATE_DATE') or
                        (l_token = 'LAST_UPDATE_LOGIN') then
	l_column := l_token;
	l_state := 311;
      else
      --
      -- error if not expecting attribute values added by the translation team
      -- or if we have read in more than a certain number of values
      -- for the same DB column
      --
        l_value_count := l_value_count + 1;
        --
        -- save second value. It will be the token with error if
        -- it turns out that there is a parse error on this line.
        --
        if (l_value_count = 2) then
          l_saved_token := l_token;
        end if;
        if (l_value_count > AK_ON_OBJECTS_PUB.G_MAX_NUM_LOADER_VALUES) or
           (l_value_count is null) then
          if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_EFIELD');
            FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
            if (l_value_count is null) then
              FND_MESSAGE.SET_TOKEN('TOKEN', l_token);
            else
              FND_MESSAGE.SET_TOKEN('TOKEN',l_saved_token);
            end if;
            FND_MESSAGE.SET_TOKEN('EXPECTED','REGION_GRAPH');
            FND_MSG_PUB.Add;
          end if;
          raise FND_API.G_EXC_ERROR;
        end if;
      end if;
    elsif (l_state = 311) then
      if (l_token = '=') then
        l_state := 312;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', '=');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 312) then
      l_value_count := 1;
      if (l_column = 'GRAPH_STYLE') then
--	l_graph_rec.GRAPH_STYLE := to_number(l_token);
	l_state := 310;
      elsif (l_column = 'DISPLAY_FLAG') then
--	l_graph_rec.DISPLAY_FLAG := l_token;
	l_state := 310;
      elsif (l_column = 'DEPTH_RADIUS') then
--	l_graph_rec.DEPTH_RADIUS := to_number(l_token);
   	l_state := 310;
      elsif (l_column = 'GRAPH_TITLE') then
--	l_graph_rec.GRAPH_TITLE := l_token;
	l_state := 310;
      elsif (l_column = 'Y_AXIS_LABEL') then
--	l_graph_rec.Y_AXIS_LABEL := l_token;
	l_state := 310;
      elsif (l_column = 'CREATED_BY') then
--         l_graph_rec.created_by := to_number(l_token);
         l_state := 310;
      elsif (l_column = 'CREATION_DATE') then
--         l_graph_rec.creation_date := to_date(l_token,
--                                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
         l_state := 310;
      elsif (l_column = 'LAST_UPDATED_BY') then
--         l_graph_rec.last_updated_by := to_number(l_token);
         l_state := 310;
      elsif (l_column = 'LAST_UPDATE_DATE') then
--         l_graph_rec.last_update_date := to_date(l_token,
--                                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
         l_state := 310;
      elsif (l_column = 'LAST_UPDATE_LOGIN') then
--         l_graph_rec.last_update_login := to_number(l_token);
         l_state := 310;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', l_column || ' value');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 319) then
      if (l_token = 'REGION_GRAPH') then
        l_value_count := null;
        l_state := 10;
--        l_graph_index := l_graph_index + 1;
--	l_graph_tbl(l_graph_index) := l_graph_rec;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'REGION_GRAPH');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;

    --
    -- REGION_GRAPH_COLUMN (400 - 449)
    --
    elsif (l_state = 400) then
      if (l_token is not null) then
--        l_graph_column_rec.attribute_application_id := to_number(l_token);
        l_state := 401;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'ATTRIBUTE_APPLICATION_ID');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 401) then
      if (l_token is not null) then
--        l_graph_column_rec.attribute_code := l_token;
        l_value_count := null;
        l_state := 410;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'ATTRIBUTE_CODE');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 410) then
      if (l_token = 'END') then
        l_state := 419;
      else
      --
      -- error if not expecting attribute values added by the translation team
      -- or if we have read in more than a certain number of values
      -- for the same DB column
      --
        l_value_count := l_value_count + 1;
        --
        -- save second value. It will be the token with error if
        -- it turns out that there is a parse error on this line.
        --
        if (l_value_count = 2) then
          l_saved_token := l_token;
        end if;
        if (l_value_count > AK_ON_OBJECTS_PUB.G_MAX_NUM_LOADER_VALUES) or
           (l_value_count is null) then
          if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_EFIELD');
            FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
            if (l_value_count is null) then
              FND_MESSAGE.SET_TOKEN('TOKEN', l_token);
            else
              FND_MESSAGE.SET_TOKEN('TOKEN',l_saved_token);
            end if;
            FND_MESSAGE.SET_TOKEN('EXPECTED','REGION_GRAPH_COLUMN');
            FND_MSG_PUB.Add;
          end if;
          raise FND_API.G_EXC_ERROR;
        end if;
      end if;
    elsif (l_state = 419) then
      if (l_token = 'REGION_GRAPH_COLUMN') then
        l_value_count := null;
        l_state := 310;
--        l_graph_column_index := l_graph_column_index + 1;
--	l_graph_column_tbl(l_graph_column_index) := l_graph_column_rec;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'REGION_GRAPH_COLUMN');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;

    end if; -- if l_state = ...

    -- Get rid of leading white spaces, so that buffer would become
    -- null if the only thing in it are white spaces
    l_buffer := LTRIM(l_buffer);

    -- Get the next non-blank, non-comment line if current line is
    -- fully parsed
    while (l_buffer is null and l_eof_flag = 'N' and p_index <=  AK_ON_OBJECTS_PVT.G_UPL_TABLE_NUM) loop
      AK_ON_OBJECTS_PVT.READ_LINE (
        p_return_status => l_return_status,
        p_index => p_index,
        p_buffer => l_buffer,
        p_lines_read => l_lines_read,
        p_eof_flag => l_eof_flag,
        p_upl_loader_cur => p_upl_loader_cur
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

  end LOOP;

  -- If the loops end in a state other then at the end of a region
  -- (state 0) or when the beginning of another business object was
  -- detected, then the file must have ended prematurely, which is an error
  if (l_state <> 0) and (l_more_region) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
      FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
      FND_MESSAGE.SET_TOKEN('TOKEN', 'END OF FILE');
      FND_MESSAGE.SET_TOKEN('EXPECTED', null);
      FND_MSG_PUB.Add;
    end if;
    --dbms_output.put_line('Unexpected END OF FILE: state is ' ||
    --            to_char(l_state));
    raise FND_API.G_EXC_ERROR;
  end if;

  --
  -- create or update all regions to the database
  --
  if (l_region_tbl.count > 0) then
    for l_index in l_region_tbl.FIRST .. l_region_tbl.LAST loop
      if (l_region_tbl.exists(l_index)) then
        if AK_REGION_PVT.REGION_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_region_application_id =>
                               l_region_tbl(l_index).region_application_id,
            p_region_code => l_region_tbl(l_index).region_code) then
               /* REMOVE DELETE FUNCTIONALITY DURING UPLOAD
		--Delete all region items under this region only when the
		--jlt file was extracted in the REGION mode
		if (AK_UPLOAD_GRP.G_EXTRACT_OBJ = 'REGION') then
		   for l_item_rec in l_get_region_item_csr(
		      l_region_tbl(l_index).region_application_id,
		      l_region_tbl(l_index).region_code) LOOP
			AK_REGION_PVT.DELETE_ITEM (
			p_validation_level => p_validation_level,
			p_api_version_number => 1.0,
			p_msg_count => l_msg_count,
              		p_msg_data => l_msg_data,
			p_return_status => l_return_status,
			p_region_application_id =>
				l_region_tbl(l_index).region_application_id,
			p_region_code => l_region_tbl(l_index).region_code,
			p_attribute_application_id =>
				l_item_rec.attribute_application_id,
			p_attribute_code => l_item_rec.attribute_code,
			p_delete_cascade => 'N');
		   end loop;
		end if;
          */
          --
          -- Update Regions only if G_UPDATE_MODE is TRUE
          --
          if (AK_UPLOAD_GRP.G_UPDATE_MODE) then
            AK_REGION_PVT.UPDATE_REGION (
              p_validation_level => p_validation_level,
              p_api_version_number => 1.0,
              p_msg_count => l_msg_count,
              p_msg_data => l_msg_data,
              p_return_status => l_return_status,
              p_region_application_id =>
                                  l_region_tbl(l_index).region_application_id,
              p_region_code => l_region_tbl(l_index).region_code,
              p_database_object_name =>l_region_tbl(l_index).database_object_name,
              p_region_style => l_region_tbl(l_index).region_style,
              p_num_columns => l_region_tbl(l_index).num_columns,
              p_icx_custom_call => l_region_tbl(l_index).icx_custom_call,
              p_region_defaulting_api_pkg =>
                 l_region_tbl(l_index).region_defaulting_api_pkg,
              p_region_defaulting_api_proc =>
                 l_region_tbl(l_index).region_defaulting_api_proc,
              p_region_validation_api_pkg =>
                 l_region_tbl(l_index).region_validation_api_pkg,
              p_region_validation_api_proc =>
                 l_region_tbl(l_index).region_validation_api_proc,
              p_appmodule_object_type =>
                 l_region_tbl(l_index).applicationmodule_object_type,
              p_num_rows_display =>
                 l_region_tbl(l_index).num_rows_display,
              p_region_object_type =>
                 l_region_tbl(l_index).region_object_type,
              p_image_file_name =>
                 l_region_tbl(l_index).image_file_name,
              p_isform_flag => l_region_tbl(l_index).isform_flag,
			  p_help_target => l_region_tbl(l_index).help_target,
	  p_style_sheet_filename => l_region_tbl(l_index).style_sheet_filename,
			  p_version => l_region_tbl(l_index).version,
			  p_applicationmodule_usage_name => l_region_tbl(l_index).applicationmodule_usage_name,
	  p_add_indexed_children => l_region_tbl(l_index).add_indexed_children,
	  p_stateful_flag => l_region_tbl(l_index).stateful_flag,
	  p_function_name => l_region_tbl(l_index).function_name,
	  p_children_view_usage_name => l_region_tbl(l_index).children_view_usage_name,
	 p_search_panel => l_region_tbl(l_index).search_panel,
	 p_advanced_search_panel => l_region_tbl(l_index).advanced_search_panel,
	 p_customize_panel => l_region_tbl(l_index).customize_panel,
	 p_default_search_panel => l_region_tbl(l_index).default_search_panel,
	 p_results_based_search => l_region_tbl(l_index).results_based_search,
	 p_display_graph_table => l_region_tbl(l_index).display_graph_table,
	 p_disable_header => l_region_tbl(l_index).disable_header,
	 p_standalone => l_region_tbl(l_index).standalone,
	 p_auto_customization_criteria => l_region_tbl(l_index).auto_customization_criteria,
              p_attribute_category => l_region_tbl(l_index).attribute_category,
			  p_attribute1 => l_region_tbl(l_index).attribute1,
			  p_attribute2 => l_region_tbl(l_index).attribute2,
			  p_attribute3 => l_region_tbl(l_index).attribute3,
			  p_attribute4 => l_region_tbl(l_index).attribute4,
			  p_attribute5 => l_region_tbl(l_index).attribute5,
			  p_attribute6 => l_region_tbl(l_index).attribute6,
			  p_attribute7 => l_region_tbl(l_index).attribute7,
			  p_attribute8 => l_region_tbl(l_index).attribute8,
			  p_attribute9 => l_region_tbl(l_index).attribute9,
			  p_attribute10 => l_region_tbl(l_index).attribute10,
			  p_attribute11 => l_region_tbl(l_index).attribute11,
			  p_attribute12 => l_region_tbl(l_index).attribute12,
			  p_attribute13 => l_region_tbl(l_index).attribute13,
			  p_attribute14 => l_region_tbl(l_index).attribute14,
			  p_attribute15 => l_region_tbl(l_index).attribute15,
              p_name => l_region_tbl(l_index).name,
              p_description => l_region_tbl(l_index).description,
	p_created_by  => l_region_tbl(l_index).created_by,
	p_creation_date  => l_region_tbl(l_index).creation_date,
	p_last_updated_by  => l_region_tbl(l_index).last_updated_by,
	p_last_update_date  => l_region_tbl(l_index).last_update_date,
	p_last_update_login  => l_region_tbl(l_index).last_update_login,
              p_loader_timestamp => p_loader_timestamp,
		      p_pass => p_pass,
              p_copy_redo_flag => l_copy_redo_flag
            );
		  elsif (AK_UPLOAD_GRP.G_NO_CUSTOM_UPDATE) then
			-- do not update customized data
			select ar.last_updated_by, art.last_updated_by,
			       ar.last_update_date, art.last_update_date
 			into l_user_id1, l_user_id2, l_update1, l_update2
			from ak_regions ar, ak_regions_tl art
			where ar.region_code = l_region_tbl(l_index).region_code
			and ar.region_application_id = l_region_tbl(l_index).region_application_id
			and ar.region_code = art.region_code
			and ar.region_application_id = art.region_application_id
			and art.language = userenv('LANG');
			/*if (( l_user_id1 = 1 or l_user_id1 = 2 ) and
				( l_user_id2 = 1 or l_user_id2 = 2 )) then*/
                if (AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
                  p_loader_timestamp => p_loader_timestamp,
                  p_created_by => l_region_tbl(l_index).created_by,
                  p_creation_date => l_region_tbl(l_index).creation_date,
                  p_last_updated_by => l_region_tbl(l_index).last_updated_by,
                  p_db_last_updated_by => l_user_id1,
                  p_last_update_date => l_region_tbl(l_index).last_update_date,
                  p_db_last_update_date => l_update1,
                  p_last_update_login => l_region_tbl(l_index).last_update_login,
                  p_create_or_update => 'UPDATE') and

                   AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
                  p_loader_timestamp => p_loader_timestamp,
                  p_created_by => l_region_tbl(l_index).created_by,
                  p_creation_date => l_region_tbl(l_index).creation_date,
                  p_last_updated_by => l_region_tbl(l_index).last_updated_by,
                  p_db_last_updated_by => l_user_id2,
                  p_last_update_date => l_region_tbl(l_index).last_update_date,
                  p_db_last_update_date => l_update2,
                  p_last_update_login => l_region_tbl(l_index).last_update_login,
                  p_create_or_update => 'UPDATE')) then

	            AK_REGION_PVT.UPDATE_REGION (
	              p_validation_level => p_validation_level,
	              p_api_version_number => 1.0,
	              p_msg_count => l_msg_count,
	              p_msg_data => l_msg_data,
	              p_return_status => l_return_status,
	              p_region_application_id =>
	                                  l_region_tbl(l_index).region_application_id,
	              p_region_code => l_region_tbl(l_index).region_code,
	              p_database_object_name =>l_region_tbl(l_index).database_object_name,
	              p_region_style => l_region_tbl(l_index).region_style,
	              p_num_columns => l_region_tbl(l_index).num_columns,
	              p_icx_custom_call => l_region_tbl(l_index).icx_custom_call,
	              p_region_defaulting_api_pkg =>
	                 l_region_tbl(l_index).region_defaulting_api_pkg,
	              p_region_defaulting_api_proc =>
	                 l_region_tbl(l_index).region_defaulting_api_proc,
	              p_region_validation_api_pkg =>
	                 l_region_tbl(l_index).region_validation_api_pkg,
	              p_region_validation_api_proc =>
	                 l_region_tbl(l_index).region_validation_api_proc,
	              p_appmodule_object_type =>
    	             l_region_tbl(l_index).applicationmodule_object_type,
        	      p_num_rows_display =>
            	     l_region_tbl(l_index).num_rows_display,
	              p_region_object_type =>
    	             l_region_tbl(l_index).region_object_type,
	              p_image_file_name =>
    	             l_region_tbl(l_index).image_file_name,
        	      p_isform_flag => l_region_tbl(l_index).isform_flag,
				  p_help_target => l_region_tbl(l_index).help_target,
				  p_style_sheet_filename => l_region_tbl(l_index).style_sheet_filename,
				  p_version => l_region_tbl(l_index).version,
				  p_applicationmodule_usage_name => l_region_tbl(l_index).applicationmodule_usage_name,
				  p_add_indexed_children => l_region_tbl(l_index).add_indexed_children,
				  p_stateful_flag => l_region_tbl(l_index).stateful_flag,
				  p_function_name => l_region_tbl(l_index).function_name,
				  p_children_view_usage_name => l_region_tbl(l_index).children_view_usage_name,
	p_search_panel => l_region_tbl(l_index).search_panel,
	p_advanced_search_panel => l_region_tbl(l_index).advanced_search_panel,
	p_customize_panel => l_region_tbl(l_index).customize_panel,
	p_default_search_panel => l_region_tbl(l_index).default_search_panel,
	p_results_based_search => l_region_tbl(l_index).results_based_search,
	p_display_graph_table => l_region_tbl(l_index).display_graph_table,
	p_disable_header => l_region_tbl(l_index).disable_header,
	p_standalone => l_region_tbl(l_index).standalone,
	p_auto_customization_criteria => l_region_tbl(l_index).auto_customization_criteria,
	              p_attribute_category => l_region_tbl(l_index).attribute_category,
				  p_attribute1 => l_region_tbl(l_index).attribute1,
				  p_attribute2 => l_region_tbl(l_index).attribute2,
				  p_attribute3 => l_region_tbl(l_index).attribute3,
				  p_attribute4 => l_region_tbl(l_index).attribute4,
				  p_attribute5 => l_region_tbl(l_index).attribute5,
				  p_attribute6 => l_region_tbl(l_index).attribute6,
				  p_attribute7 => l_region_tbl(l_index).attribute7,
				  p_attribute8 => l_region_tbl(l_index).attribute8,
				  p_attribute9 => l_region_tbl(l_index).attribute9,
				  p_attribute10 => l_region_tbl(l_index).attribute10,
				  p_attribute11 => l_region_tbl(l_index).attribute11,
				  p_attribute12 => l_region_tbl(l_index).attribute12,
				  p_attribute13 => l_region_tbl(l_index).attribute13,
				  p_attribute14 => l_region_tbl(l_index).attribute14,
				  p_attribute15 => l_region_tbl(l_index).attribute15,
	              p_name => l_region_tbl(l_index).name,
	              p_description => l_region_tbl(l_index).description,
		p_created_by => l_region_tbl(l_index).created_by,
		p_creation_date => l_region_tbl(l_index).creation_date,
		p_last_updated_by => l_region_tbl(l_index).last_updated_by,
		p_last_update_date => l_region_tbl(l_index).last_update_date,
		p_last_update_login => l_region_tbl(l_index).last_update_login,
	              p_loader_timestamp => p_loader_timestamp,
			      p_pass => p_pass,
	              p_copy_redo_flag => l_copy_redo_flag
	            );
			end if; -- /* if ( l_user_id1 = 1 and l_user_id2 = 1 ) */
          end if; -- /* if G_UPDATE_MODE G_NC_UPDATE_MODE*/
        else
          AK_REGION_PVT.CREATE_REGION (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
            p_region_application_id =>
                                l_region_tbl(l_index).region_application_id,
            p_region_code => l_region_tbl(l_index).region_code,
            p_database_object_name =>l_region_tbl(l_index).database_object_name,
            p_region_style => l_region_tbl(l_index).region_style,
            p_num_columns => l_region_tbl(l_index).num_columns,
            p_icx_custom_call => l_region_tbl(l_index).icx_custom_call,
            p_region_defaulting_api_pkg =>
               l_region_tbl(l_index).region_defaulting_api_pkg,
            p_region_defaulting_api_proc =>
               l_region_tbl(l_index).region_defaulting_api_proc,
            p_region_validation_api_pkg =>
               l_region_tbl(l_index).region_validation_api_pkg,
            p_region_validation_api_proc =>
               l_region_tbl(l_index).region_validation_api_proc,
            p_appmodule_object_type =>
               l_region_tbl(l_index).applicationmodule_object_type,
            p_num_rows_display =>
               l_region_tbl(l_index).num_rows_display,
            p_region_object_type =>
               l_region_tbl(l_index).region_object_type,
            p_image_file_name =>
               l_region_tbl(l_index).image_file_name,
            p_isform_flag => l_region_tbl(l_index).isform_flag,
			p_help_target => l_region_tbl(l_index).help_target,
			p_style_sheet_filename => l_region_tbl(l_index).style_sheet_filename,
			p_version => l_region_tbl(l_index).version,
			p_applicationmodule_usage_name => l_region_tbl(l_index).applicationmodule_usage_name,
			p_add_indexed_children => l_region_tbl(l_index).add_indexed_children,
			p_stateful_flag => l_region_tbl(l_index).stateful_flag,
			p_function_name => l_region_tbl(l_index).function_name,
			p_children_view_usage_name => l_region_tbl(l_index).children_view_usage_name,
	p_search_panel => l_region_tbl(l_index).search_panel,
	p_advanced_search_panel => l_region_tbl(l_index).advanced_search_panel,
	p_customize_panel => l_region_tbl(l_index).customize_panel,
	p_default_search_panel => l_region_tbl(l_index).default_search_panel,
	p_results_based_search => l_region_tbl(l_index).results_based_search,
	p_display_graph_table => l_region_tbl(l_index).display_graph_table,
	p_disable_header => l_region_tbl(l_index).disable_header,
	p_standalone => l_region_tbl(l_index).standalone,
	p_auto_customization_criteria => l_region_tbl(l_index).auto_customization_criteria,
            p_attribute_category => l_region_tbl(l_index).attribute_category,
			p_attribute1 => l_region_tbl(l_index).attribute1,
			p_attribute2 => l_region_tbl(l_index).attribute2,
			p_attribute3 => l_region_tbl(l_index).attribute3,
			p_attribute4 => l_region_tbl(l_index).attribute4,
			p_attribute5 => l_region_tbl(l_index).attribute5,
			p_attribute6 => l_region_tbl(l_index).attribute6,
			p_attribute7 => l_region_tbl(l_index).attribute7,
			p_attribute8 => l_region_tbl(l_index).attribute8,
			p_attribute9 => l_region_tbl(l_index).attribute9,
			p_attribute10 => l_region_tbl(l_index).attribute10,
			p_attribute11 => l_region_tbl(l_index).attribute11,
			p_attribute12 => l_region_tbl(l_index).attribute12,
			p_attribute13 => l_region_tbl(l_index).attribute13,
			p_attribute14 => l_region_tbl(l_index).attribute14,
			p_attribute15 => l_region_tbl(l_index).attribute15,
            p_name => l_region_tbl(l_index).name,
            p_description => l_region_tbl(l_index).description,
	p_created_by => l_region_tbl(l_index).created_by,
	p_creation_date => l_region_tbl(l_index).creation_date,
	p_last_updated_by => l_region_tbl(l_index).last_updated_by,
	p_last_update_date => l_region_tbl(l_index).last_update_date,
	p_last_update_login => l_region_tbl(l_index).last_update_login,
            p_loader_timestamp => p_loader_timestamp,
		    p_pass => p_pass,
            p_copy_redo_flag => l_copy_redo_flag
          );
        end if; -- /* if REGION_EXISTS */
        --
        -- If API call returns with an error status, upload aborts
        if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
        (l_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        end if; -- /* if l_return_status */
		--
		-- if validation fails, then this record should go to second pass
		if (l_copy_redo_flag) then
		  G_REGION_REDO_INDEX := G_REGION_REDO_INDEX + 1;
		  G_REGION_REDO_TBL(G_REGION_REDO_INDEX) := l_region_tbl(l_index);
		  l_copy_redo_flag := FALSE;
		end if; --/* if l_copy_redo_flag */
      end if;
    end loop;
  end if;

  --
  -- create or update all region items to the database
  --
  if (l_item_tbl.count > 0) then
    for l_index in l_item_tbl.FIRST .. l_item_tbl.LAST loop
      if (l_item_tbl.exists(l_index)) then
        if AK_REGION_PVT.ITEM_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_region_application_id =>l_item_tbl(l_index).region_application_id,
            p_region_code => l_item_tbl(l_index).region_code,
            p_attribute_application_id =>
                                   l_item_tbl(l_index).attribute_application_id,
            p_attribute_code => l_item_tbl(l_index).attribute_code) then
          --
          -- Update Region Items only if G_UPDATE_MODE is TRUE
          --
          if (AK_UPLOAD_GRP.G_UPDATE_MODE) then
            AK_REGION_PVT.UPDATE_ITEM (
              p_validation_level => p_validation_level,
              p_api_version_number => 1.0,
              p_msg_count => l_msg_count,
              p_msg_data => l_msg_data,
              p_return_status => l_return_status,
              p_region_application_id =>l_item_tbl(l_index).region_application_id,
              p_region_code => l_item_tbl(l_index).region_code,
              p_attribute_application_id =>
                               l_item_tbl(l_index).attribute_application_id,
              p_attribute_code => l_item_tbl(l_index).attribute_code,
              p_display_sequence => l_item_tbl(l_index).display_sequence,
              p_node_display_flag => l_item_tbl(l_index).node_display_flag,
              p_node_query_flag => l_item_tbl(l_index).node_query_flag,
              p_attribute_label_length =>
                               l_item_tbl(l_index).attribute_label_length,
              p_display_value_length =>
                               l_item_tbl(l_index).display_value_length,
              p_bold => l_item_tbl(l_index).bold,
              p_italic => l_item_tbl(l_index).italic,
              p_vertical_alignment => l_item_tbl(l_index).vertical_alignment,
              p_horizontal_alignment => l_item_tbl(l_index).horizontal_alignment,
              p_item_style => l_item_tbl(l_index).item_style,
              p_object_attribute_flag =>l_item_tbl(l_index).object_attribute_flag,
              p_icx_custom_call => l_item_tbl(l_index).icx_custom_call,
              p_update_flag => l_item_tbl(l_index).update_flag,
              p_required_flag => l_item_tbl(l_index).required_flag,
              p_security_code => l_item_tbl(l_index).security_code,
              p_default_value_varchar2 =>
                 l_item_tbl(l_index).default_value_varchar2,
              p_default_value_number =>
                 l_item_tbl(l_index).default_value_number,
              p_default_value_date =>
                 l_item_tbl(l_index).default_value_date,
              p_lov_region_application_id =>
                 l_item_tbl(l_index).lov_region_application_id,
              p_lov_region_code => l_item_tbl(l_index).lov_region_code,
              p_lov_foreign_key_name => l_item_tbl(l_index).lov_foreign_key_name,
              p_lov_attribute_application_id =>
                 l_item_tbl(l_index).lov_attribute_application_id,
              p_lov_attribute_code => l_item_tbl(l_index).lov_attribute_code,
              p_lov_default_flag => l_item_tbl(l_index).lov_default_flag,
              p_region_defaulting_api_pkg =>
                 l_item_tbl(l_index).region_defaulting_api_pkg,
              p_region_defaulting_api_proc =>
                 l_item_tbl(l_index).region_defaulting_api_proc,
              p_region_validation_api_pkg =>
                 l_item_tbl(l_index).region_validation_api_pkg,
              p_region_validation_api_proc =>
                 l_item_tbl(l_index).region_validation_api_proc,
              p_order_sequence => l_item_tbl(l_index).order_sequence,
              p_order_direction => l_item_tbl(l_index).order_direction,
		  p_display_height => l_item_tbl(l_index).display_height,
			  p_submit => l_item_tbl(l_index).submit,
			  p_encrypt => l_item_tbl(l_index).encrypt,
			  p_css_class_name => l_item_tbl(l_index).css_class_name,
			  p_view_usage_name =>l_item_tbl(l_index).view_usage_name,
			  p_view_attribute_name =>l_item_tbl(l_index).view_attribute_name,
			  p_nested_region_appl_id =>l_item_tbl(l_index).nested_region_application_id,
			  p_nested_region_code =>l_item_tbl(l_index).nested_region_code,
			  p_url =>l_item_tbl(l_index).url,
			  p_poplist_viewobject =>l_item_tbl(l_index).poplist_viewobject,
			  p_poplist_display_attr =>l_item_tbl(l_index).poplist_display_attr,
			  p_poplist_value_attr =>l_item_tbl(l_index).poplist_value_attr,
			  p_image_file_name =>l_item_tbl(l_index).image_file_name,
			  p_item_name =>l_item_tbl(l_index).item_name,
			  p_css_label_class_name => l_item_tbl(l_index).css_label_class_name,
			  p_menu_name => l_item_tbl(l_index).menu_name,
			  p_flexfield_name => l_item_tbl(l_index).flexfield_name,
			  p_flexfield_application_id => l_item_tbl(l_index).flexfield_application_id,
              p_tabular_function_code    => l_item_tbl(l_index).tabular_function_code,
              p_tip_type                 => l_item_tbl(l_index).tip_type,
              p_tip_message_name         => l_item_tbl(l_index).tip_message_name,
              p_tip_message_application_id  => l_item_tbl(l_index).tip_message_application_id ,
              p_flex_segment_list        => l_item_tbl(l_index).flex_segment_list,
              p_entity_id  => l_item_tbl(l_index).entity_id,
              p_anchor     => l_item_tbl(l_index).anchor,
              p_poplist_view_usage_name => l_item_tbl(l_index).poplist_view_usage_name,
	      p_user_customizable => l_item_tbl(l_index).user_customizable,
              p_sortby_view_attribute_name => l_item_tbl(l_index).sortby_view_attribute_name,
	      p_admin_customizable => l_item_tbl(l_index).admin_customizable,
	      p_invoke_function_name => l_item_tbl(l_index).invoke_function_name,
	      p_expansion => l_item_tbl(l_index).expansion,
	      p_als_max_length => l_item_tbl(l_index).als_max_length,
              p_initial_sort_sequence => l_item_tbl(l_index).initial_sort_sequence,
	      p_customization_application_id => l_item_tbl(l_index).customization_application_id,
	      p_customization_code => l_item_tbl(l_index).customization_code,
              p_attribute_category => l_item_tbl(l_index).attribute_category,
			  p_attribute1 => l_item_tbl(l_index).attribute1,
			  p_attribute2 => l_item_tbl(l_index).attribute2,
			  p_attribute3 => l_item_tbl(l_index).attribute3,
			  p_attribute4 => l_item_tbl(l_index).attribute4,
			  p_attribute5 => l_item_tbl(l_index).attribute5,
			  p_attribute6 => l_item_tbl(l_index).attribute6,
			  p_attribute7 => l_item_tbl(l_index).attribute7,
			  p_attribute8 => l_item_tbl(l_index).attribute8,
			  p_attribute9 => l_item_tbl(l_index).attribute9,
			  p_attribute10 => l_item_tbl(l_index).attribute10,
			  p_attribute11 => l_item_tbl(l_index).attribute11,
			  p_attribute12 => l_item_tbl(l_index).attribute12,
			  p_attribute13 => l_item_tbl(l_index).attribute13,
			  p_attribute14 => l_item_tbl(l_index).attribute14,
			  p_attribute15 => l_item_tbl(l_index).attribute15,
              p_attribute_label_long => l_item_tbl(l_index).attribute_label_long,
              p_attribute_label_short =>l_item_tbl(l_index).attribute_label_short,
              p_description =>l_item_tbl(l_index).description,
		p_created_by => l_item_tbl(l_index).created_by,
		p_creation_date => l_item_tbl(l_index).creation_date,
		p_last_updated_by => l_item_tbl(l_index).last_updated_by,
		p_last_update_date => l_item_tbl(l_index).last_update_date,
		p_last_update_login => l_item_tbl(l_index).last_update_login,
              p_loader_timestamp => p_loader_timestamp,
  		      p_pass => p_pass,
              p_copy_redo_flag => l_copy_redo_flag
            );
		  -- update non-customized data only
		  elsif ( AK_UPLOAD_GRP.G_NO_CUSTOM_UPDATE ) then
			select ari.last_updated_by, arit.last_updated_by,
			       ari.last_update_date, arit.last_update_date
			into l_user_id1, l_user_id2, l_update1, l_update2
			from ak_region_items ari, ak_region_items_tl arit
			where ari.region_code = l_item_tbl(l_index).region_code
			and ari.region_application_id = l_item_tbl(l_index).region_application_id
			and ari.attribute_code = l_item_tbl(l_index).attribute_code
			and ari.attribute_application_id = l_item_tbl(l_index).attribute_application_id
			and ari.region_code = arit.region_code
			and ari.region_application_id = arit.region_application_id
			and ari.attribute_code = arit.attribute_code
			and ari.attribute_application_id = arit.attribute_application_id
			and arit.language = userenv('LANG');
			/*if (( l_user_id1 = 1 or l_user_id1 = 2 ) and
				( l_user_id2 = 1 or l_user_id2 = 2 )) then*/
                if (AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
                      p_loader_timestamp => p_loader_timestamp,
                      p_created_by => l_item_tbl(l_index).created_by,
                      p_creation_date => l_item_tbl(l_index).creation_date,
                      p_last_updated_by => l_item_tbl(l_index).last_updated_by,
                      p_db_last_updated_by => l_user_id1,
                      p_last_update_date => l_item_tbl(l_index).last_update_date,
                      p_db_last_update_date => l_update1,
                      p_last_update_login => l_item_tbl(l_index).last_update_login,
                      p_create_or_update => 'UPDATE') and

                   AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
                      p_loader_timestamp => p_loader_timestamp,
                      p_created_by => l_item_tbl(l_index).created_by,
                      p_creation_date => l_item_tbl(l_index).creation_date,
                      p_last_updated_by => l_item_tbl(l_index).last_updated_by,
                      p_db_last_updated_by => l_user_id2,
                      p_last_update_date => l_item_tbl(l_index).last_update_date,
                      p_db_last_update_date => l_update2,
                      p_last_update_login => l_item_tbl(l_index).last_update_login,
                      p_create_or_update => 'UPDATE')) then

	            AK_REGION_PVT.UPDATE_ITEM (
	              p_validation_level => p_validation_level,
	              p_api_version_number => 1.0,
	              p_msg_count => l_msg_count,
	              p_msg_data => l_msg_data,
	              p_return_status => l_return_status,
	              p_region_application_id =>l_item_tbl(l_index).region_application_id,
	              p_region_code => l_item_tbl(l_index).region_code,
	              p_attribute_application_id =>
	                               l_item_tbl(l_index).attribute_application_id,
	              p_attribute_code => l_item_tbl(l_index).attribute_code,
	              p_display_sequence => l_item_tbl(l_index).display_sequence,
	              p_node_display_flag => l_item_tbl(l_index).node_display_flag,
	              p_node_query_flag => l_item_tbl(l_index).node_query_flag,
	              p_attribute_label_length =>
	                               l_item_tbl(l_index).attribute_label_length,
	              p_display_value_length =>
	                               l_item_tbl(l_index).display_value_length,
	              p_bold => l_item_tbl(l_index).bold,
	              p_italic => l_item_tbl(l_index).italic,
	              p_vertical_alignment => l_item_tbl(l_index).vertical_alignment,
	              p_horizontal_alignment => l_item_tbl(l_index).horizontal_alignment,
	              p_item_style => l_item_tbl(l_index).item_style,
	              p_object_attribute_flag =>l_item_tbl(l_index).object_attribute_flag,
	              p_icx_custom_call => l_item_tbl(l_index).icx_custom_call,
	              p_update_flag => l_item_tbl(l_index).update_flag,
	              p_required_flag => l_item_tbl(l_index).required_flag,
	              p_security_code => l_item_tbl(l_index).security_code,
	              p_default_value_varchar2 =>
	                 l_item_tbl(l_index).default_value_varchar2,
	              p_default_value_number =>
	                 l_item_tbl(l_index).default_value_number,
	              p_default_value_date =>
	                 l_item_tbl(l_index).default_value_date,
	              p_lov_region_application_id =>
	                 l_item_tbl(l_index).lov_region_application_id,
	              p_lov_region_code => l_item_tbl(l_index).lov_region_code,
	              p_lov_foreign_key_name => l_item_tbl(l_index).lov_foreign_key_name,
	              p_lov_attribute_application_id =>
	                 l_item_tbl(l_index).lov_attribute_application_id,
	              p_lov_attribute_code => l_item_tbl(l_index).lov_attribute_code,
	              p_lov_default_flag => l_item_tbl(l_index).lov_default_flag,
	              p_region_defaulting_api_pkg =>
	                 l_item_tbl(l_index).region_defaulting_api_pkg,
	              p_region_defaulting_api_proc =>
	                 l_item_tbl(l_index).region_defaulting_api_proc,
	              p_region_validation_api_pkg =>
	                 l_item_tbl(l_index).region_validation_api_pkg,
	              p_region_validation_api_proc =>
	                 l_item_tbl(l_index).region_validation_api_proc,
	              p_order_sequence => l_item_tbl(l_index).order_sequence,
	              p_order_direction => l_item_tbl(l_index).order_direction,
				  p_display_height => l_item_tbl(l_index).display_height,
				  p_submit => l_item_tbl(l_index).submit,
				  p_encrypt => l_item_tbl(l_index).encrypt,
				  p_css_class_name => l_item_tbl(l_index).css_class_name,
				  p_view_usage_name =>l_item_tbl(l_index).view_usage_name,
				  p_view_attribute_name =>l_item_tbl(l_index).view_attribute_name,
				  p_nested_region_appl_id =>l_item_tbl(l_index).nested_region_application_id,
				  p_nested_region_code =>l_item_tbl(l_index).nested_region_code,
				  p_url =>l_item_tbl(l_index).url,
				  p_poplist_viewobject =>l_item_tbl(l_index).poplist_viewobject,
				  p_poplist_display_attr =>l_item_tbl(l_index).poplist_display_attr,
				  p_poplist_value_attr =>l_item_tbl(l_index).poplist_value_attr,
				  p_image_file_name =>l_item_tbl(l_index).image_file_name,
				  p_item_name =>l_item_tbl(l_index).item_name,
				  p_css_label_class_name => l_item_tbl(l_index).css_label_class_name,
				  p_menu_name => l_item_tbl(l_index).menu_name,
				  p_flexfield_name => l_item_tbl(l_index).flexfield_name,
				  p_flexfield_application_id => l_item_tbl(l_index).flexfield_application_id,
                  p_tabular_function_code    => l_item_tbl(l_index).tabular_function_code,
                  p_tip_type                 => l_item_tbl(l_index).tip_type,
                  p_tip_message_name          => l_item_tbl(l_index).tip_message_name,
                  p_tip_message_application_id  => l_item_tbl(l_index).tip_message_application_id ,
                  p_flex_segment_list        => l_item_tbl(l_index).flex_segment_list,
                  p_entity_id  => l_item_tbl(l_index).entity_id,
                  p_anchor => l_item_tbl(l_index).anchor,
                  p_poplist_view_usage_name => l_item_tbl(l_index).poplist_view_usage_name,
		  p_user_customizable => l_item_tbl(l_index).user_customizable,
                  p_sortby_view_attribute_name => l_item_tbl(l_index).sortby_view_attribute_name,
		  p_admin_customizable => l_item_tbl(l_index).admin_customizable,
		  p_invoke_function_name => l_item_tbl(l_index).invoke_function_name,
		  p_expansion => l_item_tbl(l_index).expansion,
		  p_als_max_length => l_item_tbl(l_index).als_max_length,
		  p_initial_sort_sequence => l_item_tbl(l_index).initial_sort_sequence,
		  p_customization_application_id => l_item_tbl(l_index).customization_application_id,
		  p_customization_code => l_item_tbl(l_index).customization_code,
	              p_attribute_category => l_item_tbl(l_index).attribute_category,
				  p_attribute1 => l_item_tbl(l_index).attribute1,
				  p_attribute2 => l_item_tbl(l_index).attribute2,
				  p_attribute3 => l_item_tbl(l_index).attribute3,
				  p_attribute4 => l_item_tbl(l_index).attribute4,
				  p_attribute5 => l_item_tbl(l_index).attribute5,
				  p_attribute6 => l_item_tbl(l_index).attribute6,
				  p_attribute7 => l_item_tbl(l_index).attribute7,
				  p_attribute8 => l_item_tbl(l_index).attribute8,
				  p_attribute9 => l_item_tbl(l_index).attribute9,
				  p_attribute10 => l_item_tbl(l_index).attribute10,
				  p_attribute11 => l_item_tbl(l_index).attribute11,
				  p_attribute12 => l_item_tbl(l_index).attribute12,
				  p_attribute13 => l_item_tbl(l_index).attribute13,
				  p_attribute14 => l_item_tbl(l_index).attribute14,
				  p_attribute15 => l_item_tbl(l_index).attribute15,
	              p_attribute_label_long => l_item_tbl(l_index).attribute_label_long,
	              p_attribute_label_short =>l_item_tbl(l_index).attribute_label_short,
				  p_description => l_item_tbl(l_index).description,
		p_created_by => l_item_tbl(l_index).created_by,
		p_creation_date => l_item_tbl(l_index).creation_date,
		p_last_updated_by => l_item_tbl(l_index).last_updated_by,
		p_last_update_date => l_item_tbl(l_index).last_update_date,
		p_last_update_login => l_item_tbl(l_index).last_update_login,
	              p_loader_timestamp => p_loader_timestamp,
	  		      p_pass => p_pass,
	              p_copy_redo_flag => l_copy_redo_flag
	            );
			end if; /* if l_user_id1 = 1 and l_user_id2 = 1 */
          end if; -- /* if G_UPDATE_MODE G_NO_CUSTOM_UPDATE */
        else
          AK_REGION_PVT.CREATE_ITEM (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
            p_region_application_id =>l_item_tbl(l_index).region_application_id,
            p_region_code => l_item_tbl(l_index).region_code,
            p_attribute_application_id =>
                             l_item_tbl(l_index).attribute_application_id,
            p_attribute_code => l_item_tbl(l_index).attribute_code,
            p_display_sequence => l_item_tbl(l_index).display_sequence,
            p_node_display_flag => l_item_tbl(l_index).node_display_flag,
            p_node_query_flag => l_item_tbl(l_index).node_query_flag,
            p_attribute_label_length =>
                             l_item_tbl(l_index).attribute_label_length,
            p_display_value_length =>
                             l_item_tbl(l_index).display_value_length,
            p_bold => l_item_tbl(l_index).bold,
            p_italic => l_item_tbl(l_index).italic,
            p_vertical_alignment => l_item_tbl(l_index).vertical_alignment,
            p_horizontal_alignment => l_item_tbl(l_index).horizontal_alignment,
            p_item_style => l_item_tbl(l_index).item_style,
            p_object_attribute_flag =>l_item_tbl(l_index).object_attribute_flag,
            p_icx_custom_call => l_item_tbl(l_index).icx_custom_call,
            p_update_flag => l_item_tbl(l_index).update_flag,
            p_required_flag => l_item_tbl(l_index).required_flag,
            p_security_code => l_item_tbl(l_index).security_code,
            p_default_value_varchar2 =>
               l_item_tbl(l_index).default_value_varchar2,
            p_default_value_number =>
               l_item_tbl(l_index).default_value_number,
            p_default_value_date =>
               l_item_tbl(l_index).default_value_date,
            p_lov_region_application_id =>
               l_item_tbl(l_index).lov_region_application_id,
            p_lov_region_code => l_item_tbl(l_index).lov_region_code,
            p_lov_foreign_key_name => l_item_tbl(l_index).lov_foreign_key_name,
            p_lov_attribute_application_id =>
               l_item_tbl(l_index).lov_attribute_application_id,
            p_lov_attribute_code => l_item_tbl(l_index).lov_attribute_code,
            p_lov_default_flag => l_item_tbl(l_index).lov_default_flag,
            p_region_defaulting_api_pkg =>
               l_item_tbl(l_index).region_defaulting_api_pkg,
            p_region_defaulting_api_proc =>
               l_item_tbl(l_index).region_defaulting_api_proc,
            p_region_validation_api_pkg =>
               l_item_tbl(l_index).region_validation_api_pkg,
            p_region_validation_api_proc =>
               l_item_tbl(l_index).region_validation_api_proc,
            p_order_sequence => l_item_tbl(l_index).order_sequence,
            p_order_direction => l_item_tbl(l_index).order_direction,
			p_display_height => l_item_tbl(l_index).display_height,
			p_submit => l_item_tbl(l_index).submit,
			p_encrypt => l_item_tbl(l_index).encrypt,
			p_css_class_name => l_item_tbl(l_index).css_class_name,
			p_view_usage_name =>l_item_tbl(l_index).view_usage_name,
			p_view_attribute_name =>l_item_tbl(l_index).view_attribute_name,
			p_nested_region_appl_id =>l_item_tbl(l_index).nested_region_application_id,
			p_nested_region_code =>l_item_tbl(l_index).nested_region_code,
			p_url =>l_item_tbl(l_index).url,
			p_poplist_viewobject =>l_item_tbl(l_index).poplist_viewobject,
			p_poplist_display_attr =>l_item_tbl(l_index).poplist_display_attr,
			p_poplist_value_attr =>l_item_tbl(l_index).poplist_value_attr,
			p_image_file_name =>l_item_tbl(l_index).image_file_name,
			p_item_name => l_item_tbl(l_index).item_name,
			p_css_label_class_name => l_item_tbl(l_index).css_label_class_name,
			p_menu_name => l_item_tbl(l_index).menu_name,
			p_flexfield_name => l_item_tbl(l_index).flexfield_name,
			p_flexfield_application_id => l_item_tbl(l_index).flexfield_application_id,
            p_tabular_function_code    => l_item_tbl(l_index).tabular_function_code,
            p_tip_type                 => l_item_tbl(l_index).tip_type,
            p_tip_message_name         => l_item_tbl(l_index).tip_message_name,
            p_tip_message_application_id  => l_item_tbl(l_index).tip_message_application_id ,
            p_flex_segment_list        => l_item_tbl(l_index).flex_segment_list,
            p_entity_id  => l_item_tbl(l_index).entity_id ,
            p_anchor => l_item_tbl(l_index).anchor,
            p_poplist_view_usage_name => l_item_tbl(l_index).poplist_view_usage_name,
	    p_user_customizable => l_item_tbl(l_index).user_customizable,
            p_sortby_view_attribute_name => l_item_tbl(l_index).sortby_view_attribute_name,
	    p_admin_customizable => l_item_tbl(l_index).admin_customizable,
	    p_invoke_function_name => l_item_tbl(l_index).invoke_function_name,
	    p_expansion => l_item_tbl(l_index).expansion,
	    p_als_max_length => l_item_tbl(l_index).als_max_length,
            p_initial_sort_sequence => l_item_tbl(l_index).initial_sort_sequence,
	    p_customization_application_id => l_item_tbl(l_index).customization_application_id,
	    p_customization_code => l_item_tbl(l_index).customization_code,
            p_attribute_category => l_item_tbl(l_index).attribute_category,
			p_attribute1 => l_item_tbl(l_index).attribute1,
			p_attribute2 => l_item_tbl(l_index).attribute2,
			p_attribute3 => l_item_tbl(l_index).attribute3,
			p_attribute4 => l_item_tbl(l_index).attribute4,
			p_attribute5 => l_item_tbl(l_index).attribute5,
			p_attribute6 => l_item_tbl(l_index).attribute6,
			p_attribute7 => l_item_tbl(l_index).attribute7,
			p_attribute8 => l_item_tbl(l_index).attribute8,
			p_attribute9 => l_item_tbl(l_index).attribute9,
			p_attribute10 => l_item_tbl(l_index).attribute10,
			p_attribute11 => l_item_tbl(l_index).attribute11,
			p_attribute12 => l_item_tbl(l_index).attribute12,
			p_attribute13 => l_item_tbl(l_index).attribute13,
			p_attribute14 => l_item_tbl(l_index).attribute14,
			p_attribute15 => l_item_tbl(l_index).attribute15,
            p_attribute_label_long => l_item_tbl(l_index).attribute_label_long,
            p_attribute_label_short =>l_item_tbl(l_index).attribute_label_short,
			p_description => l_item_tbl(l_index).description,
		p_created_by => l_item_tbl(l_index).created_by,
		p_creation_date => l_item_tbl(l_index).creation_date,
		p_last_updated_by => l_item_tbl(l_index).last_updated_by,
		p_last_update_date => l_item_tbl(l_index).last_update_date,
		p_last_update_login => l_item_tbl(l_index).last_update_login,
            p_loader_timestamp => p_loader_timestamp,
		    p_pass => p_pass,
            p_copy_redo_flag => l_copy_redo_flag
          );
        end if; -- /* if ITEM_EXISTS */
        --
        -- If API call returns with an error status, upload aborts
        if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
        (l_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        end if; -- /* if l_return_status */
		--
		-- if validation fails, then this record should go to second pass
		if (l_copy_redo_flag) then
		  G_ITEM_REDO_INDEX := G_ITEM_REDO_INDEX + 1;
		  G_ITEM_REDO_TBL(G_ITEM_REDO_INDEX) := l_item_tbl(l_index);
		  l_copy_redo_flag := FALSE;
		end if; --/* if l_copy_redo_flag */
      end if; -- /* if l_item_tbl.exists */
    end loop;
  end if; -- /* if l_item_tbl.count > 0 */

  --
  -- create or update all region lov relations to the database
  --
  if (l_lov_relation_tbl.count > 0) then
    for l_index in l_lov_relation_tbl.FIRST .. l_lov_relation_tbl.LAST loop
      if (l_lov_relation_tbl.exists(l_index)) then
	    if ( l_lov_relation_tbl(l_index).base_region_appl_id is null ) then
		  l_lov_relation_tbl(l_index).base_region_appl_id := l_lov_relation_tbl(l_index).region_application_id;
		end if;
		if ( l_lov_relation_tbl(l_index).base_region_code is null ) then
  		  l_lov_relation_tbl(l_index).base_region_code := l_lov_relation_tbl(l_index).region_code;
		end if;
        if AK_REGION2_PVT.LOV_RELATION_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_region_application_id =>
                               l_lov_relation_tbl(l_index).region_application_id,
            p_region_code => l_lov_relation_tbl(l_index).region_code,
            p_attribute_application_id =>
            					l_lov_relation_tbl(l_index).attribute_application_id,
            p_attribute_code => l_lov_relation_tbl(l_index).attribute_code,
            p_lov_region_appl_id => l_lov_relation_tbl(l_index).lov_region_appl_id,
            p_lov_region_code => l_lov_relation_tbl(l_index).lov_region_code,
            p_lov_attribute_appl_id =>
            					l_lov_relation_tbl(l_index).lov_attribute_appl_id,
            p_lov_attribute_code => l_lov_relation_tbl(l_index).lov_attribute_code,
			p_base_attribute_appl_id => l_lov_relation_tbl(l_index).base_attribute_appl_id,
			p_base_attribute_code => l_lov_relation_tbl(l_index).base_attribute_code,
            p_direction_flag => l_lov_relation_tbl(l_index).direction_flag,
	    p_base_region_appl_id => l_lov_relation_tbl(l_index).base_region_appl_id,
	    p_base_region_code => l_lov_relation_tbl(l_index).base_region_code) then
          --
          -- Update Region lov relations if G_UPDATE_MODE is TRUE
          -- Also update Region Lov relations if G_NO_CUSTOM_UPDATE since there's
		  -- no customized data in this table, do not update if G_NO_UPDATE_MODE
		  --
          if (AK_UPLOAD_GRP.G_UPDATE_MODE or AK_UPLOAD_GRP.G_NO_CUSTOM_UPDATE) then
            AK_REGION2_PVT.UPDATE_LOV_RELATION (
              p_validation_level => p_validation_level,
              p_api_version_number => 1.0,
              p_msg_count => l_msg_count,
              p_msg_data => l_msg_data,
              p_return_status => l_return_status,
              p_region_application_id =>
                                  l_lov_relation_tbl(l_index).region_application_id,
              p_region_code => l_lov_relation_tbl(l_index).region_code,
              p_attribute_application_id =>
                                  l_lov_relation_tbl(l_index).attribute_application_id,
              p_attribute_code => l_lov_relation_tbl(l_index).attribute_code,
			  p_lov_region_appl_id => l_lov_relation_tbl(l_index).lov_region_appl_id,
			  p_lov_region_code => l_lov_relation_tbl(l_index).lov_region_code,
			  p_lov_attribute_appl_id => l_lov_relation_tbl(l_index).lov_attribute_appl_id,
			  p_lov_attribute_code => l_lov_relation_tbl(l_index).lov_attribute_code,
			  p_base_attribute_appl_id => l_lov_relation_tbl(l_index).base_attribute_appl_id,
			  p_base_attribute_code => l_lov_relation_tbl(l_index).base_attribute_code,
              p_direction_flag => l_lov_relation_tbl(l_index).direction_flag,
	      p_base_region_appl_id => l_lov_relation_tbl(l_index).base_region_appl_id,
	      p_base_region_code => l_lov_relation_tbl(l_index).base_region_code,
			  p_required_flag => l_lov_relation_tbl(l_index).required_flag,
		p_created_by => l_lov_relation_tbl(l_index).created_by,
		p_creation_date => l_lov_relation_tbl(l_index).creation_date,
		p_last_updated_by => l_lov_relation_tbl(l_index).last_updated_by,
		p_last_update_date => l_lov_relation_tbl(l_index).last_update_date,
		p_last_update_login => l_lov_relation_tbl(l_index).last_update_login,
              p_loader_timestamp => p_loader_timestamp,
		      p_pass => p_pass,
              p_copy_redo_flag => l_copy_redo_flag
            );
		  end if;
        else
          AK_REGION2_PVT.CREATE_LOV_RELATION (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
              p_region_application_id =>
                                  l_lov_relation_tbl(l_index).region_application_id,
              p_region_code => l_lov_relation_tbl(l_index).region_code,
              p_attribute_application_id =>
                                  l_lov_relation_tbl(l_index).attribute_application_id,
              p_attribute_code => l_lov_relation_tbl(l_index).attribute_code,
			  p_lov_region_appl_id => l_lov_relation_tbl(l_index).lov_region_appl_id,
			  p_lov_region_code => l_lov_relation_tbl(l_index).lov_region_code,
			  p_lov_attribute_appl_id => l_lov_relation_tbl(l_index).lov_attribute_appl_id,
			  p_lov_attribute_code => l_lov_relation_tbl(l_index).lov_attribute_code,
			  p_base_attribute_appl_id => l_lov_relation_tbl(l_index).base_attribute_appl_id,
			  p_base_attribute_code => l_lov_relation_tbl(l_index).base_attribute_code,
              p_direction_flag => l_lov_relation_tbl(l_index).direction_flag,
	      p_base_region_appl_id => l_lov_relation_tbl(l_index).base_region_appl_id,
	      p_base_region_code => l_lov_relation_tbl(l_index).base_region_code,
			  p_required_flag => l_lov_relation_tbl(l_index).required_flag,
	p_created_by => l_lov_relation_tbl(l_index).created_by,
	p_creation_date => l_lov_relation_tbl(l_index).creation_date,
	p_last_updated_by => l_lov_relation_tbl(l_index).last_updated_by,
	p_last_update_date => l_lov_relation_tbl(l_index).last_update_date,
	p_last_update_login => l_lov_relation_tbl(l_index).lasT_update_login,
            p_loader_timestamp => p_loader_timestamp,
		    p_pass => p_pass,
            p_copy_redo_flag => l_copy_redo_flag
          );
        end if; -- /* if REGION_EXISTS */
        --
        -- If API call returns with an error status, upload aborts
        if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
        (l_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        end if; -- /* if l_return_status */
		--
		-- if validation fails, then this record should go to second pass
		-- validation usually fails when referenced record has not been created yet
		if (l_copy_redo_flag) then
		  G_LOV_RELATION_REDO_INDEX := G_LOV_RELATION_REDO_INDEX + 1;
		  G_LOV_RELATION_REDO_TBL(G_LOV_RELATION_REDO_INDEX) := l_lov_relation_tbl(l_index);
		  l_copy_redo_flag := FALSE;
		end if; --/* if l_copy_redo_flag */
      end if; -- /* end if l_lov_relation_tbl.exists(l_index) */
    end loop; -- /* end for l_index in l_lov_relation_tbl */
  end if;

  --
  -- create or update all region item category relations to the database
  --
  if (l_category_usage_tbl.count > 0) then
    for l_index in l_category_usage_tbl.FIRST .. l_category_usage_tbl.LAST loop
      if (l_category_usage_tbl.exists(l_index)) then
       if (l_category_usage_tbl(l_index).category_name is null) then
	 open l_check_fnd_category_name_csr(l_category_usage_tbl(l_index).category_id);
	 fetch l_check_fnd_category_name_csr into l_category_usage_tbl(l_index).category_name;
	 if (l_check_fnd_category_name_csr%notfound) then
	    FND_MESSAGE.SET_NAME('AK','AK_CATEGORY_USAGE_SKIPPED');
	     FND_MESSAGE.SET_TOKEN('KEY', to_char(l_category_usage_tbl(l_index).category_id));
      	    FND_MSG_PUB.Add;
	 end if;
	 close l_check_fnd_category_name_csr;
       elsif (l_category_usage_tbl(l_index).category_name is not null) then
         open l_check_fnd_category_id_csr(l_category_usage_tbl(l_index).category_name);
         fetch l_check_fnd_category_id_csr into l_category_usage_tbl(l_index).category_id;
         if (l_check_fnd_category_id_csr%notfound) then
    	    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
      		FND_MESSAGE.SET_NAME('AK','AK_FND_CATEGORY_DOES_NOT_EXIST');
             FND_MESSAGE.SET_TOKEN('KEY', (l_category_usage_tbl(l_index).category_name));
      		FND_MSG_PUB.Add;
            end if;
            close l_check_fnd_category_id_csr;
            raise FND_API.G_EXC_ERROR;
         end if;
	 close l_check_fnd_category_id_csr;
       end if;

	if (l_category_usage_tbl(l_index).category_name is not null) then
        if ( AK_REGION2_PVT.CATEGORY_USAGE_EXISTS(
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_region_application_id =>
                               l_category_usage_tbl(l_index).region_application_id,
            p_region_code => l_category_usage_tbl(l_index).region_code,
            p_attribute_application_id =>
            					l_category_usage_tbl(l_index).attribute_application_id,
            p_attribute_code => l_category_usage_tbl(l_index).attribute_code,
            p_category_name => l_category_usage_tbl(l_index).category_name) = false)  then
          AK_REGION2_PVT.CREATE_CATEGORY_USAGE (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
              p_region_application_id =>
                                  l_category_usage_tbl(l_index).region_application_id,
              p_region_code => l_category_usage_tbl(l_index).region_code,
              p_attribute_application_id =>
                                  l_category_usage_tbl(l_index).attribute_application_id,
              p_attribute_code => l_category_usage_tbl(l_index).attribute_code,
			  p_category_name => l_category_usage_tbl(l_index).category_name,
		p_category_id => l_category_usage_tbl(l_index).category_id,
		p_application_id => l_category_usage_tbl(l_index).application_id,
		p_show_all => l_category_usage_tbl(l_index).show_all,
		p_created_by => l_category_usage_tbl(l_index).created_by,
		p_creation_date => l_category_usage_tbl(l_index).creation_date,
		p_last_updated_by => l_category_usage_tbl(l_index).last_updated_by,
		p_last_update_date => l_category_usage_tbl(l_index).last_update_date,
		p_last_update_login => l_category_usage_tbl(l_index).last_update_login,
            p_loader_timestamp => p_loader_timestamp,
		    p_pass => p_pass,
            p_copy_redo_flag => l_copy_redo_flag
          );
        else
          AK_REGION2_PVT.UPDATE_CATEGORY_USAGE (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
              p_region_application_id =>
                                  l_category_usage_tbl(l_index).region_application_id,
              p_region_code => l_category_usage_tbl(l_index).region_code,
              p_attribute_application_id =>
                                  l_category_usage_tbl(l_index).attribute_application_id,
              p_attribute_code => l_category_usage_tbl(l_index).attribute_code,
                          p_category_name => l_category_usage_tbl(l_index).category_name,
                p_category_id => l_category_usage_tbl(l_index).category_id,
                p_application_id => l_category_usage_tbl(l_index).application_id,
                p_show_all => l_category_usage_tbl(l_index).show_all,
		p_created_by => l_category_usage_tbl(l_index).created_by,
		p_creation_date => l_category_usage_tbl(l_index).creation_date,
                p_last_updated_by => l_category_usage_tbl(l_index).last_updated_by,
                p_last_update_date => l_category_usage_tbl(l_index).last_update_date,
                p_last_update_login => l_category_usage_tbl(l_index).last_update_login,
            p_loader_timestamp => p_loader_timestamp,
                    p_pass => p_pass,
            p_copy_redo_flag => l_copy_redo_flag
          );
        end if; -- /* if CATEGORY_USAGE_EXISTS */
	end if;
        --
        -- If API call returns with an error status, upload aborts
        if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
        (l_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        end if; -- /* if l_return_status */
		--
		-- if validation fails, then this record should go to second pass
		-- validation usually fails when referenced record has not been created yet
--		if (l_copy_redo_flag) then
--		  G_LOV_RELATION_REDO_INDEX := G_LOV_RELATION_REDO_INDEX + 1;
--		  G_LOV_RELATION_REDO_TBL(G_LOV_RELATION_REDO_INDEX) := l_lov_relation_tbl(l_index);
--		  l_copy_redo_flag := FALSE;
--		end if; --/* if l_copy_redo_flag */
      end if; -- /* end if l_category_usage_tbl.exists(l_index) */
    end loop; -- /* end for l_index in l_category_usage_tbl */
  end if;

/*
  --
  -- create or update all region graphs to the database
  --
  if (l_graph_tbl.count > 0) then
    for l_index in l_graph_tbl.FIRST .. l_graph_tbl.LAST loop
      if (l_graph_tbl.exists(l_index)) then
        if AK_REGION_PVT.GRAPH_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_region_application_id => l_graph_tbl(l_index).region_application_id,
            p_region_code => l_graph_tbl(l_index).region_code,
	    p_graph_number => l_graph_tbl(l_index).graph_number) then
          --
          -- Update Region Graphs only if G_UPDATE_MODE is TRUE
          --
          if (AK_UPLOAD_GRP.G_UPDATE_MODE) then
            AK_REGION_PVT.UPDATE_GRAPH (
              p_validation_level => p_validation_level,
              p_api_version_number => 1.0,
              p_msg_count => l_msg_count,
              p_msg_data => l_msg_data,
              p_return_status => l_return_status,
              p_region_application_id =>l_graph_tbl(l_index).region_application_id,
	      p_region_code => l_graph_tbl(l_index).region_code,
	      p_graph_number => l_graph_tbl(l_index).graph_number,
	      p_graph_style => l_graph_tbl(l_index).graph_style,
	      p_display_flag => l_graph_tbl(l_index).display_flag,
	      p_depth_radius => l_graph_tbl(l_index).depth_radius,
	      p_graph_title => l_graph_tbl(l_index).graph_title,
	      p_y_axis_label => l_graph_tbl(l_index).y_axis_label,
		p_created_by => l_graph_tbl(l_index).created_by,
		p_creation_date => l_graph_tbl(l_index).creation_date,
		p_last_updated_by => l_graph_tbl(l_index).last_updated_by,
		p_last_update_date => l_graph_tbl(l_index).last_update_date,
		p_last_update_login => l_graph_tbl(l_index).last_update_login,
              p_loader_timestamp => p_loader_timestamp,
                      p_pass => p_pass,
              p_copy_redo_flag => l_copy_redo_flag
            );
                  -- update non-customized data only
          elsif ( AK_UPLOAD_GRP.G_NO_CUSTOM_UPDATE ) then
                select arg.last_updated_by, argt.last_updated_by into l_user_id1, l_user_id2
                from ak_region_graphs arg, ak_region_graphs_tl argt
                where arg.region_code = l_graph_tbl(l_index).region_code
		and arg.region_application_id = l_graph_tbl(l_index).region_application_id
		and arg.graph_number = l_graph_tbl(l_index).graph_number
		and arg.region_code = argt.region_code
		and arg.region_application_id = argt.region_application_id
		and arg.graph_number = argt.graph_number
		and argt.language = userenv('LANG');
		if (( l_user_id1 = 1 or l_user_id1 = 2 ) and
			( l_user_id2 = 1 or l_user_id2 = 2 )) then
                    AK_REGION_PVT.UPDATE_GRAPH (
                      p_validation_level => p_validation_level,
                      p_api_version_number => 1.0,
                      p_msg_count => l_msg_count,
                      p_msg_data => l_msg_data,
                      p_return_status => l_return_status,
                      p_region_application_id =>l_graph_tbl(l_index).region_application_id,
		      p_region_code => l_graph_tbl(l_index).region_code,
		      p_graph_number => l_graph_tbl(l_index).graph_number,
		      p_graph_style => l_graph_tbl(l_index).graph_style,
		      p_display_flag => l_graph_tbl(l_index).display_flag,
		      p_depth_Radius => l_graph_tbl(l_index).depth_radius,
		      p_graph_title => l_graph_tbl(l_index).graph_title,
		      p_y_axis_label => l_graph_tbl(l_index).y_axis_label,
                p_created_by => l_graph_tbl(l_index).created_by,
                p_creation_date => l_graph_tbl(l_index).creation_date,
                p_last_updated_by => l_graph_tbl(l_index).last_updated_by,
                p_last_update_date => l_graph_tbl(l_index).last_update_date,
                p_last_update_login => l_graph_tbl(l_index).last_update_login,
                      p_loader_timestamp => p_loader_timestamp,
                              p_pass => p_pass,
                      p_copy_redo_flag => l_copy_redo_flag
                    );
                end if; -- if l_user_id1 = 1 and l_user_id2 = 1
          end if; --  if G_UPDATE_MODE G_NO_CUSTOM_UPDATE
        else
          AK_REGION_PVT.CREATE_GRAPH (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
            p_region_application_id =>l_graph_tbl(l_index).region_application_id,
	    p_region_code => l_graph_tbl(l_index).region_code,
	    p_graph_number => l_graph_tbl(l_index).graph_number,
	    p_graph_style => l_graph_tbl(l_index).graph_style,
	    p_display_flag => l_graph_tbl(l_index).display_flag,
	    p_depth_radius => l_graph_tbl(l_index).depth_radius,
	    p_graph_title => l_graph_tbl(l_index).graph_title,
	    p_y_axis_label => l_graph_tbl(l_index).y_axis_label,
                p_created_by => l_graph_tbl(l_index).created_by,
                p_creation_date => l_graph_tbl(l_index).creation_date,
                p_last_updated_by => l_graph_tbl(l_index).last_updated_by,
                p_last_update_date => l_graph_tbl(l_index).last_update_date,
                p_last_update_login => l_graph_tbl(l_index).last_update_login,
            p_loader_timestamp => p_loader_timestamp,
                    p_pass => p_pass,
            p_copy_redo_flag => l_copy_redo_flag
          );
        end if; --  if ITEM_EXISTS
        --
        -- If API call returns with an error status, upload aborts
        if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
        (l_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        end if; --  if l_return_status
                --
               -- if validation fails, then this record should go to second pass
		if (l_copy_redo_flag) then
                  G_GRAPH_REDO_INDEX := G_GRAPH_REDO_INDEX + 1;
		  G_GRAPH_REDO_TBL(G_GRAPH_REDO_INDEX) := l_graph_tbl(l_index);
		  l_copy_redo_flag := FALSE;
                end if; -- if l_copy_redo_flag
      end if; --  if l_item_tbl.exists
    end loop;
  end if; --  if l_item_tbl.count > 0

  --
  -- create or update all region graph columns to the database
  -- commented out update due to no updateable columns
  --
  if (l_graph_column_tbl.count > 0) then
    for l_index in l_graph_column_tbl.FIRST .. l_graph_column_tbl.LAST loop
      if (l_graph_column_tbl.exists(l_index)) then
         if (AK_REGION2_PVT.GRAPH_COLUMN_EXISTS(
	   p_api_version_number => 1.0,
	   p_return_status => l_return_status,
	   p_region_application_id => l_graph_column_tbl(l_index).region_application_id,
	   p_region_code => l_graph_column_tbl(l_index).region_code,
	   p_graph_number => l_graph_column_tbl(l_index).graph_number,
	   p_attribute_application_id => l_graph_column_tbl(l_index).attribute_application_id,
	   p_attribute_code => l_graph_column_tbl(l_index).attribute_code) = false) then */
/*          --
          -- Update Region graph columns if G_UPDATE_MODE is TRUE
          --
          if (AK_UPLOAD_GRP.G_UPDATE_MODE) then
            AK_REGION2_PVT.UPDATE_GRAPH_COLUMN (
              p_validation_level => p_validation_level,
              p_api_version_number => 1.0,
              p_msg_count => l_msg_count,
              p_msg_data => l_msg_data,
              p_return_status => l_return_status,
              p_region_application_id =>l_graph_column_tbl(l_index).region_application_id,
	      p_region_code => l_graph_column_tbl(l_index).region_code,
	      p_graph_number => l_graph_column_tbl(l_index).graph_number,
	      p_attribute_application_id => l_graph_column_tbl(l_index).attribute_application_id,
	      p_attribute_code => l_graph_column_tbl(l_index).attribute_code,
		p_created_by => l_graph_column_tbl(l_index).created_by,
		p_creation_date => l_graph_column_tbl(l_index).creation_date,
		p_last_updated_by => l_graph_column_tbl(l_index).last_updated_by,
		p_last_update_date => l_graph_column_tbl(l_index).last_update_date,
		p_last_update_login => l_graph_column_tbl(l_index).last_update_login,
              p_loader_timestamp => p_loader_timestamp,
                      p_pass => p_pass,
              p_copy_redo_flag => l_copy_redo_flag
            );
                  -- update non-customized data only
          elsif ( AK_UPLOAD_GRP.G_NO_CUSTOM_UPDATE ) then
		select last_updated_by into l_user_id1
		from ak_region_graph_columns
	 	where region_code = l_graph_column_tbl(l_index).region_code
		and region_application_id = l_graph_column_tbl(l_index).region_application_id
		and graph_number = l_graph_column_tbl(l_index).graph_number
		and attribute_application_id = l_graph_column_tbl(l_index).attribute_application_id
		and attribute_code = l_graph_column_tbl(l_index).attribute_code;
		if ( l_user_id1 = 1 or l_user_id1 = 2) then
		AK_REGION2_PVT.UPDATE_GRAPH_COLUMN (
                      p_validation_level => p_validation_level,
                      p_api_version_number => 1.0,
                      p_msg_count => l_msg_count,
                      p_msg_data => l_msg_data,
                      p_return_status => l_return_status,
                      p_region_application_id => l_graph_column_tbl(l_index).region_application_id,
		      p_region_code => l_graph_column_tbl(l_index).region_code,
		      p_graph_number => l_graph_column_tbl(l_index).graph_number,
		      p_attribute_application_id => l_graph_column_tbl(l_index).attribute_application_id,
		      p_attribute_code => l_graph_column_tbl(l_index).attribute_code,
                p_created_by => l_graph_column_tbl(l_index).created_by,
                p_creation_date => l_graph_column_tbl(l_index).creation_date,
                p_last_updated_by => l_graph_column_tbl(l_index).last_updated_by,
                p_last_update_date => l_graph_column_tbl(l_index).last_update_date,
                p_last_update_login => l_graph_column_tbl(l_index).last_update_login,
                      p_loader_timestamp => p_loader_timestamp,
                              p_pass => p_pass,
                      p_copy_redo_flag => l_copy_redo_flag
                    );
                end if; */ /*if l_user_id1 = 1 */ /*
          end if; -- */ /* if G_UPDATE_MODE G_NO_CUSTOM_UPDATE */ /*
        else */
/*
          AK_REGION2_PVT.CREATE_GRAPH_COLUMN (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
            p_region_application_id => l_graph_column_tbl(l_index).region_application_id,
	    p_region_code => l_graph_column_tbl(l_index).region_code,
	    p_graph_number => l_graph_column_tbl(l_index).graph_number,
	    p_attribute_application_id => l_graph_column_tbl(l_index).attribute_application_id,
	    p_attribute_code => l_graph_column_tbl(l_index).attribute_code,
                p_created_by => l_graph_column_tbl(l_index).created_by,
                p_creation_date => l_graph_column_tbl(l_index).creation_date,
                p_last_updated_by => l_graph_column_tbl(l_index).last_updated_by,
                p_last_update_date => l_graph_column_tbl(l_index).last_update_date,
                p_last_update_login => l_graph_column_tbl(l_index).last_update_login,
            p_loader_timestamp => p_loader_timestamp,
                    p_pass => p_pass,
            p_copy_redo_flag => l_copy_redo_flag
          );
        end if; --  if GRAPH_EXISTS
        --
        -- If API call returns with an error status, upload aborts
        if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
        (l_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        end if; --  if l_return_status
                --
                -- if validation fails, then this record should go to second pass
                if (l_copy_redo_flag) then
                  G_GRAPH_COLUMN_REDO_INDEX := G_GRAPH_COLUMN_REDO_INDEX + 1;
		  G_GRAPH_COLUMN_REDO_TBL(G_GRAPH_COLUMN_REDO_INDEX) := l_graph_column_tbl(l_index);
		  l_copy_redo_flag := FALSE;
                end if; -- if l_copy_redo_flag
      end if; --  if l_graph_tbl.exists
    end loop;
  end if; --  if l_graph_tbl.count > 0
*/

  --
  -- Load line number of the last file line processed
  --
  p_line_num_out := l_line_num;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  --dbms_output.put_line('Leaving region upload: ' ||
  --                            to_char(sysdate, 'MON-DD HH24:MI:SS'));

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
    --rollback to Start_Upload;
  WHEN VALUE_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('AK','AK_REGION_VALUE_ERROR');
    FND_MESSAGE.SET_TOKEN('KEY',to_char(l_region_rec.region_application_id)||' '||
    						l_region_rec.region_code);
    FND_MSG_PUB.Add;
	FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240)||': '||l_column||'='||l_token );
	FND_MSG_PUB.Add;
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --rollback to Start_Upload;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;
end UPLOAD_REGION;

--=======================================================
--  Procedure   UPLOAD_REGION_SECOND
--
--  Usage       Private API for loading regions that were
--              failed during its first pass
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API reads the region data from PL/SQL table
--              that was prepared during 1st pass, then processes
--              the data, and loads them to the database. The tables
--              are updated with the timestamp passed. This API
--              will process the file until the EOF is reached,
--              a parse error is encountered, or when data for
--              a different business object is read from the file.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_validation_level : IN required
--                  validation level
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure UPLOAD_REGION_SECOND (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
  p_pass                     IN      NUMBER := 2
) is
  l_api_name                 CONSTANT varchar2(30) := 'Upload_Region_Second';
  l_rec_index                NUMBER;
  l_return_status            VARCHAR2(1);
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(240);
  l_copy_redo_flag           BOOLEAN;
  l_user_id1				 NUMBER;
  l_user_id2				 NUMBER;
  l_update1				DATE;
  l_update2				DATE;
begin
  --
  -- create or update all regions to the database
  --
  if (G_REGION_REDO_INDEX > 0) then
    for l_index in G_REGION_REDO_TBL.FIRST .. G_REGION_REDO_TBL.LAST loop
      if (G_REGION_REDO_TBL.exists(l_index)) then
        if AK_REGION_PVT.REGION_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_region_application_id =>
                               G_REGION_REDO_TBL(l_index).region_application_id,
            p_region_code => G_REGION_REDO_TBL(l_index).region_code) then
          AK_REGION_PVT.UPDATE_REGION (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
            p_region_application_id =>
                                G_REGION_REDO_TBL(l_index).region_application_id,
            p_region_code => G_REGION_REDO_TBL(l_index).region_code,
            p_database_object_name =>G_REGION_REDO_TBL(l_index).database_object_name,
            p_region_style => G_REGION_REDO_TBL(l_index).region_style,
            p_num_columns => G_REGION_REDO_TBL(l_index).num_columns,
            p_icx_custom_call => G_REGION_REDO_TBL(l_index).icx_custom_call,
            p_region_defaulting_api_pkg =>
               G_REGION_REDO_TBL(l_index).region_defaulting_api_pkg,
            p_region_defaulting_api_proc =>
               G_REGION_REDO_TBL(l_index).region_defaulting_api_proc,
            p_region_validation_api_pkg =>
               G_REGION_REDO_TBL(l_index).region_validation_api_pkg,
            p_region_validation_api_proc =>
               G_REGION_REDO_TBL(l_index).region_validation_api_proc,
            p_appmodule_object_type =>
               G_REGION_REDO_TBL(l_index).applicationmodule_object_type,
            p_num_rows_display =>
               G_REGION_REDO_TBL(l_index).num_rows_display,
            p_region_object_type =>
               G_REGION_REDO_TBL(l_index).region_object_type,
            p_image_file_name =>
               G_REGION_REDO_TBL(l_index).image_file_name,
            p_isform_flag => G_REGION_REDO_TBL(l_index).isform_flag,
            p_help_target => G_REGION_REDO_TBL(l_index).help_target,
            p_style_sheet_filename => G_REGION_REDO_TBL(l_index).style_sheet_filename,
			p_version => G_REGION_REDO_TBL(l_index).version,
			p_applicationmodule_usage_name => G_REGION_REDO_TBL(l_index).applicationmodule_usage_name,
			p_add_indexed_children => G_REGION_REDO_TBL(l_index).add_indexed_children,
			p_stateful_flag => G_REGION_REDO_TBL(l_index).stateful_flag,
			p_function_name => G_REGION_REDO_TBL(l_index).function_name,
			p_children_view_usage_name => G_REGION_REDO_TBL(l_index).children_view_usage_name,
	 p_search_panel => G_REGION_REDO_TBL(l_index).search_panel,
         p_advanced_search_panel => G_REGION_REDO_TBL(l_index).advanced_search_panel,
         p_customize_panel => G_REGION_REDO_TBL(l_index).customize_panel,
         p_default_search_panel => G_REGION_REDO_TBL(l_index).default_search_panel,
         p_results_based_search => G_REGION_REDO_TBL(l_index).results_based_search,
         p_display_graph_table => G_REGION_REDO_TBL(l_index).display_graph_table,
	 p_disable_header => G_REGION_REDO_TBL(l_index).disable_header,
	 p_standalone => G_REGION_REDO_TBL(l_index).standalone,
	 p_auto_customization_criteria => G_REGION_REDO_TBL(l_index).auto_customization_criteria,
            p_attribute_category => G_REGION_REDO_TBL(l_index).attribute_category,
			p_attribute1 => G_REGION_REDO_TBL(l_index).attribute1,
			p_attribute2 => G_REGION_REDO_TBL(l_index).attribute2,
			p_attribute3 => G_REGION_REDO_TBL(l_index).attribute3,
			p_attribute4 => G_REGION_REDO_TBL(l_index).attribute4,
			p_attribute5 => G_REGION_REDO_TBL(l_index).attribute5,
			p_attribute6 => G_REGION_REDO_TBL(l_index).attribute6,
			p_attribute7 => G_REGION_REDO_TBL(l_index).attribute7,
			p_attribute8 => G_REGION_REDO_TBL(l_index).attribute8,
			p_attribute9 => G_REGION_REDO_TBL(l_index).attribute9,
			p_attribute10 => G_REGION_REDO_TBL(l_index).attribute10,
			p_attribute11 => G_REGION_REDO_TBL(l_index).attribute11,
			p_attribute12 => G_REGION_REDO_TBL(l_index).attribute12,
			p_attribute13 => G_REGION_REDO_TBL(l_index).attribute13,
			p_attribute14 => G_REGION_REDO_TBL(l_index).attribute14,
			p_attribute15 => G_REGION_REDO_TBL(l_index).attribute15,
            p_name => G_REGION_REDO_TBL(l_index).name,
            p_description => G_REGION_REDO_TBL(l_index).description,
		p_created_by => G_REGION_REDO_TBL(l_index).created_by,
		p_creation_date => G_REGION_REDO_TBL(l_index).creation_date,
		p_last_updated_by => G_REGION_REDO_TBL(l_index).last_updated_by,
		p_last_update_date => G_REGION_REDO_TBL(l_index).last_update_date,
		p_last_update_login => G_REGION_REDO_TBL(l_index).last_update_login,
            p_loader_timestamp => p_loader_timestamp,
		    p_pass => p_pass,
            p_copy_redo_flag => l_copy_redo_flag
          );
        else
          AK_REGION_PVT.CREATE_REGION (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
            p_region_application_id =>
                                G_REGION_REDO_TBL(l_index).region_application_id,
            p_region_code => G_REGION_REDO_TBL(l_index).region_code,
            p_database_object_name =>G_REGION_REDO_TBL(l_index).database_object_name,
            p_region_style => G_REGION_REDO_TBL(l_index).region_style,
            p_num_columns => G_REGION_REDO_TBL(l_index).num_columns,
            p_icx_custom_call => G_REGION_REDO_TBL(l_index).icx_custom_call,
            p_region_defaulting_api_pkg =>
               G_REGION_REDO_TBL(l_index).region_defaulting_api_pkg,
            p_region_defaulting_api_proc =>
               G_REGION_REDO_TBL(l_index).region_defaulting_api_proc,
            p_region_validation_api_pkg =>
               G_REGION_REDO_TBL(l_index).region_validation_api_pkg,
            p_region_validation_api_proc =>
               G_REGION_REDO_TBL(l_index).region_validation_api_proc,
            p_appmodule_object_type =>
               G_REGION_REDO_TBL(l_index).applicationmodule_object_type,
            p_num_rows_display =>
               G_REGION_REDO_TBL(l_index).num_rows_display,
            p_region_object_type =>
               G_REGION_REDO_TBL(l_index).region_object_type,
            p_image_file_name =>
               G_REGION_REDO_TBL(l_index).image_file_name,
            p_isform_flag => G_REGION_REDO_TBL(l_index).isform_flag,
            p_help_target => G_REGION_REDO_TBL(l_index).help_target,
            p_style_sheet_filename => G_REGION_REDO_TBL(l_index).style_sheet_filename,
			p_version => G_REGION_REDO_TBL(l_index).version,
			p_applicationmodule_usage_name => G_REGION_REDO_TBL(l_index).applicationmodule_usage_name,
            p_add_indexed_children => G_REGION_REDO_TBL(l_index).add_indexed_children,
	    p_stateful_flag => G_REGION_REDO_TBL(l_index).stateful_flag,
	    p_function_name => G_REGION_REDO_TBL(l_index).function_name,
	    p_children_view_usage_name => G_REGION_REDO_TBL(l_index).children_view_usage_name,
	p_search_panel => G_REGION_REDO_TBL(l_index).search_panel,
        p_advanced_search_panel => G_REGION_REDO_TBL(l_index).advanced_search_panel,
        p_customize_panel => G_REGION_REDO_TBL(l_index).customize_panel,
        p_default_search_panel => G_REGION_REDO_TBL(l_index).default_search_panel,
        p_results_based_search => G_REGION_REDO_TBL(l_index).results_based_search,
        p_display_graph_table => G_REGION_REDO_TBL(l_index).display_graph_table,
	p_disable_header => G_REGION_REDO_TBL(l_index).disable_header,
	p_standalone => G_REGION_REDO_TBL(l_index).standalone,
	p_auto_customization_criteria => G_REGION_REDO_TBL(l_index).auto_customization_criteria,
        p_attribute_category => G_REGION_REDO_TBL(l_index).attribute_category,
			p_attribute1 => G_REGION_REDO_TBL(l_index).attribute1,
			p_attribute2 => G_REGION_REDO_TBL(l_index).attribute2,
			p_attribute3 => G_REGION_REDO_TBL(l_index).attribute3,
			p_attribute4 => G_REGION_REDO_TBL(l_index).attribute4,
			p_attribute5 => G_REGION_REDO_TBL(l_index).attribute5,
			p_attribute6 => G_REGION_REDO_TBL(l_index).attribute6,
			p_attribute7 => G_REGION_REDO_TBL(l_index).attribute7,
			p_attribute8 => G_REGION_REDO_TBL(l_index).attribute8,
			p_attribute9 => G_REGION_REDO_TBL(l_index).attribute9,
			p_attribute10 => G_REGION_REDO_TBL(l_index).attribute10,
			p_attribute11 => G_REGION_REDO_TBL(l_index).attribute11,
			p_attribute12 => G_REGION_REDO_TBL(l_index).attribute12,
			p_attribute13 => G_REGION_REDO_TBL(l_index).attribute13,
			p_attribute14 => G_REGION_REDO_TBL(l_index).attribute14,
			p_attribute15 => G_REGION_REDO_TBL(l_index).attribute15,
            p_name => G_REGION_REDO_TBL(l_index).name,
            p_description => G_REGION_REDO_TBL(l_index).description,
	p_created_by => G_REGION_REDO_TBL(l_index).created_by,
	p_creation_date => G_REGION_REDO_TBL(l_index).creation_date,
	p_last_updated_by => G_REGION_REDO_TBL(l_index).last_updated_by,
	p_last_update_date => G_REGION_REDO_TBL(l_index).last_update_date,
	p_last_update_login => G_REGION_REDO_TBL(l_index).last_update_login,
            p_loader_timestamp => p_loader_timestamp,
		    p_pass => p_pass,
            p_copy_redo_flag => l_copy_redo_flag
          );
        end if; -- /* if REGION_EXISTS */
        --
        -- If API call returns with an error status, upload aborts
        if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
        (l_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        end if; -- /* if l_return_status */
      end if; -- /* if G_REGION_REDO_TBL.exists(l_index) */
    end loop;
  end if; -- /* if G_REGION_REDO_INDEX > 0 */

  --
  -- create or update all region items to the database
  --
  if (G_ITEM_REDO_INDEX > 0) then
    for l_index in G_ITEM_REDO_TBL.FIRST .. G_ITEM_REDO_TBL.LAST loop
      if (G_ITEM_REDO_TBL.exists(l_index)) then
        if AK_REGION_PVT.ITEM_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_region_application_id =>G_ITEM_REDO_TBL(l_index).region_application_id,
            p_region_code => G_ITEM_REDO_TBL(l_index).region_code,
            p_attribute_application_id =>
                                   G_ITEM_REDO_TBL(l_index).attribute_application_id,
            p_attribute_code => G_ITEM_REDO_TBL(l_index).attribute_code) then
          --
          -- Update Region Items only if G_UPDATE_MODE is TRUE
          --
          if (AK_UPLOAD_GRP.G_UPDATE_MODE) then
            AK_REGION_PVT.UPDATE_ITEM (
              p_validation_level => p_validation_level,
              p_api_version_number => 1.0,
              p_msg_count => l_msg_count,
              p_msg_data => l_msg_data,
              p_return_status => l_return_status,
              p_region_application_id =>G_ITEM_REDO_TBL(l_index).region_application_id,
              p_region_code => G_ITEM_REDO_TBL(l_index).region_code,
              p_attribute_application_id =>
                               G_ITEM_REDO_TBL(l_index).attribute_application_id,
              p_attribute_code => G_ITEM_REDO_TBL(l_index).attribute_code,
              p_display_sequence => G_ITEM_REDO_TBL(l_index).display_sequence,
              p_node_display_flag => G_ITEM_REDO_TBL(l_index).node_display_flag,
              p_node_query_flag => G_ITEM_REDO_TBL(l_index).node_query_flag,
              p_attribute_label_length =>
                               G_ITEM_REDO_TBL(l_index).attribute_label_length,
              p_display_value_length =>
                               G_ITEM_REDO_TBL(l_index).display_value_length,
              p_bold => G_ITEM_REDO_TBL(l_index).bold,
              p_italic => G_ITEM_REDO_TBL(l_index).italic,
              p_vertical_alignment => G_ITEM_REDO_TBL(l_index).vertical_alignment,
              p_horizontal_alignment => G_ITEM_REDO_TBL(l_index).horizontal_alignment,
              p_item_style => G_ITEM_REDO_TBL(l_index).item_style,
              p_object_attribute_flag =>G_ITEM_REDO_TBL(l_index).object_attribute_flag,
              p_icx_custom_call => G_ITEM_REDO_TBL(l_index).icx_custom_call,
              p_update_flag => G_ITEM_REDO_TBL(l_index).update_flag,
              p_required_flag => G_ITEM_REDO_TBL(l_index).required_flag,
              p_security_code => G_ITEM_REDO_TBL(l_index).security_code,
              p_default_value_varchar2 =>
                 G_ITEM_REDO_TBL(l_index).default_value_varchar2,
              p_default_value_number =>
                 G_ITEM_REDO_TBL(l_index).default_value_number,
              p_default_value_date =>
                 G_ITEM_REDO_TBL(l_index).default_value_date,
              p_lov_region_application_id =>
                 G_ITEM_REDO_TBL(l_index).lov_region_application_id,
              p_lov_region_code => G_ITEM_REDO_TBL(l_index).lov_region_code,
              p_lov_foreign_key_name => G_ITEM_REDO_TBL(l_index).lov_foreign_key_name,
              p_lov_attribute_application_id =>
                 G_ITEM_REDO_TBL(l_index).lov_attribute_application_id,
              p_lov_attribute_code => G_ITEM_REDO_TBL(l_index).lov_attribute_code,
              p_lov_default_flag => G_ITEM_REDO_TBL(l_index).lov_default_flag,
              p_region_defaulting_api_pkg =>
                 G_ITEM_REDO_TBL(l_index).region_defaulting_api_pkg,
              p_region_defaulting_api_proc =>
                 G_ITEM_REDO_TBL(l_index).region_defaulting_api_proc,
              p_region_validation_api_pkg =>
                 G_ITEM_REDO_TBL(l_index).region_validation_api_pkg,
              p_region_validation_api_proc =>
                 G_ITEM_REDO_TBL(l_index).region_validation_api_proc,
              p_order_sequence => G_ITEM_REDO_TBL(l_index).order_sequence,
              p_order_direction => G_ITEM_REDO_TBL(l_index).order_direction,
			  p_display_height => G_ITEM_REDO_TBL(l_index).display_height,
			  p_submit => G_ITEM_REDO_TBL(l_index).submit,
			  p_encrypt => G_ITEM_REDO_TBL(l_index).encrypt,
			  p_css_class_name => G_ITEM_REDO_TBL(l_index).css_class_name,
			  p_view_usage_name => G_ITEM_REDO_TBL(l_index).view_usage_name,
			  p_view_attribute_name => G_ITEM_REDO_TBL(l_index).view_attribute_name,
			  p_nested_region_appl_id => G_ITEM_REDO_TBL(l_index).nested_region_application_id,
			  p_nested_region_code => G_ITEM_REDO_TBL(l_index).nested_region_code,
			  p_url => G_ITEM_REDO_TBL(l_index).url,
			  p_poplist_viewobject => G_ITEM_REDO_TBL(l_index).poplist_viewobject,
			  p_poplist_display_attr => G_ITEM_REDO_TBL(l_index).poplist_display_attr,
			  p_poplist_value_attr => G_ITEM_REDO_TBL(l_index).poplist_value_attr,
			  p_image_file_name => G_ITEM_REDO_TBL(l_index).image_file_name,
			  p_item_name => G_ITEM_REDO_TBL(l_index).description,
			  p_css_label_class_name => G_ITEM_REDO_TBL(l_index).css_label_class_name,
			  p_menu_name => G_ITEM_REDO_TBL(l_index).menu_name,
			  p_flexfield_name => G_ITEM_REDO_TBL(l_index).flexfield_name,
			  p_flexfield_application_id => G_ITEM_REDO_TBL(l_index).flexfield_application_id,
              p_tabular_function_code    => G_ITEM_REDO_TBL(l_index).tabular_function_code,
              p_tip_type                 => G_ITEM_REDO_TBL(l_index).tip_type,
              p_tip_message_name         => G_ITEM_REDO_TBL(l_index).tip_message_name,
              p_tip_message_application_id  => G_ITEM_REDO_TBL(l_index).tip_message_application_id ,
              p_flex_segment_list        => G_ITEM_REDO_TBL(l_index).flex_segment_list,
              p_entity_id  => G_ITEM_REDO_TBL(l_index).entity_id ,
              p_anchor => G_ITEM_REDO_TBL(l_index).anchor,
              p_poplist_view_usage_name => G_ITEM_REDO_TBL(l_index).poplist_view_usage_name,
	      p_user_customizable => G_ITEM_REDO_TBL(l_index).user_customizable,
              p_sortby_view_attribute_name => G_ITEM_REDO_TBL(l_index).sortby_view_attribute_name,
	      p_admin_customizable => G_ITEM_REDO_TBL(l_index).admin_customizable,
	      p_invoke_function_name => G_ITEM_REDO_TBL(l_index).invoke_function_name,
	      p_expansion => G_ITEM_REDO_TBL(l_index).expansion,
	      p_als_max_length => G_ITEM_REDO_TBL(l_index).als_max_length,
              p_initial_sort_sequence => G_ITEM_REDO_TBL(l_index).initial_sort_sequence,
	      p_customization_application_id => G_ITEM_REDO_TBL(l_index).customization_application_id,
	      p_customization_code => G_ITEM_REDO_TBL(l_index).customization_code,
              p_attribute_category => G_ITEM_REDO_TBL(l_index).attribute_category,
			  p_attribute1 => G_ITEM_REDO_TBL(l_index).attribute1,
			  p_attribute2 => G_ITEM_REDO_TBL(l_index).attribute2,
			  p_attribute3 => G_ITEM_REDO_TBL(l_index).attribute3,
			  p_attribute4 => G_ITEM_REDO_TBL(l_index).attribute4,
			  p_attribute5 => G_ITEM_REDO_TBL(l_index).attribute5,
			  p_attribute6 => G_ITEM_REDO_TBL(l_index).attribute6,
			  p_attribute7 => G_ITEM_REDO_TBL(l_index).attribute7,
			  p_attribute8 => G_ITEM_REDO_TBL(l_index).attribute8,
			  p_attribute9 => G_ITEM_REDO_TBL(l_index).attribute9,
			  p_attribute10 => G_ITEM_REDO_TBL(l_index).attribute10,
			  p_attribute11 => G_ITEM_REDO_TBL(l_index).attribute11,
			  p_attribute12 => G_ITEM_REDO_TBL(l_index).attribute12,
			  p_attribute13 => G_ITEM_REDO_TBL(l_index).attribute13,
			  p_attribute14 => G_ITEM_REDO_TBL(l_index).attribute14,
			  p_attribute15 => G_ITEM_REDO_TBL(l_index).attribute15,
              p_attribute_label_long => G_ITEM_REDO_TBL(l_index).attribute_label_long,
              p_attribute_label_short =>G_ITEM_REDO_TBL(l_index).attribute_label_short,
			  p_description => G_ITEM_REDO_TBL(l_index).description,
	p_created_by => G_ITEM_REDO_TBL(l_index).created_by,
	p_creation_date => G_ITEM_REDO_TBL(l_index).creation_date,
	p_last_updated_by => G_ITEM_REDO_TBL(l_index).last_updated_by,
	p_last_update_date => G_ITEM_REDO_TBL(l_index).last_update_date,
	p_last_update_login => G_ITEM_REDO_TBL(l_index).last_update_login,
              p_loader_timestamp => p_loader_timestamp,
  		      p_pass => p_pass,
              p_copy_redo_flag => l_copy_redo_flag
            );
		  elsif ( AK_UPLOAD_GRP.G_NO_CUSTOM_UPDATE ) then
			select ari.last_updated_by, arit.last_updated_by,
			       ari.last_update_date, arit.last_update_date
			into l_user_id1, l_user_id2, l_update1, l_update2
			from ak_region_items ari, ak_region_items_tl arit
			where ari.region_code = G_ITEM_REDO_TBL(l_index).region_code
			and ari.region_application_id = G_ITEM_REDO_TBL(l_index).region_application_id
			and ari.attribute_code = G_ITEM_REDO_TBL(l_index).attribute_code
			and ari.attribute_application_id = G_ITEM_REDO_TBL(l_index).attribute_application_id
			and ari.region_code = arit.region_code
			and ari.region_application_id = arit.region_application_id
			and ari.attribute_code = arit.attribute_code
			and ari.attribute_application_id = arit.attribute_application_id
			and arit.language = userenv('LANG');
			/*if (( l_user_id1 = 1 or l_user_id1 = 2) and
				( l_user_id2 = 1 or l_user_id2 = 2 )) then*/
                if (AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
                      p_loader_timestamp => p_loader_timestamp,
                      p_created_by => G_ITEM_REDO_TBL(l_index).created_by,
                      p_creation_date => G_ITEM_REDO_TBL(l_index).creation_date,
                      p_last_updated_by => G_ITEM_REDO_TBL(l_index).last_updated_by,
                      p_db_last_updated_by => l_user_id1,
                      p_last_update_date => G_ITEM_REDO_TBL(l_index).last_update_date,
                      p_db_last_update_date => l_update1,
                      p_last_update_login => G_ITEM_REDO_TBL(l_index).last_update_login,
                      p_create_or_update => 'UPDATE') and

                   AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
                      p_loader_timestamp => p_loader_timestamp,
                      p_created_by => G_ITEM_REDO_TBL(l_index).created_by,
                      p_creation_date => G_ITEM_REDO_TBL(l_index).creation_date,
                      p_last_updated_by => G_ITEM_REDO_TBL(l_index).last_updated_by,
                      p_db_last_updated_by => l_user_id2,
                      p_last_update_date => G_ITEM_REDO_TBL(l_index).last_update_date,
                      p_db_last_update_date => l_update2,
                      p_last_update_login => G_ITEM_REDO_TBL(l_index).last_update_login,
                      p_create_or_update => 'UPDATE')) then

	            AK_REGION_PVT.UPDATE_ITEM (
	              p_validation_level => p_validation_level,
	              p_api_version_number => 1.0,
	              p_msg_count => l_msg_count,
	              p_msg_data => l_msg_data,
	              p_return_status => l_return_status,
	              p_region_application_id =>G_ITEM_REDO_TBL(l_index).region_application_id,
	              p_region_code => G_ITEM_REDO_TBL(l_index).region_code,
	              p_attribute_application_id =>
	                               G_ITEM_REDO_TBL(l_index).attribute_application_id,
	              p_attribute_code => G_ITEM_REDO_TBL(l_index).attribute_code,
	              p_display_sequence => G_ITEM_REDO_TBL(l_index).display_sequence,
	              p_node_display_flag => G_ITEM_REDO_TBL(l_index).node_display_flag,
	              p_node_query_flag => G_ITEM_REDO_TBL(l_index).node_query_flag,
	              p_attribute_label_length =>
	                               G_ITEM_REDO_TBL(l_index).attribute_label_length,
	              p_display_value_length =>
	                               G_ITEM_REDO_TBL(l_index).display_value_length,
	              p_bold => G_ITEM_REDO_TBL(l_index).bold,
	              p_italic => G_ITEM_REDO_TBL(l_index).italic,
	              p_vertical_alignment => G_ITEM_REDO_TBL(l_index).vertical_alignment,
	              p_horizontal_alignment => G_ITEM_REDO_TBL(l_index).horizontal_alignment,
	              p_item_style => G_ITEM_REDO_TBL(l_index).item_style,
	              p_object_attribute_flag =>G_ITEM_REDO_TBL(l_index).object_attribute_flag,
	              p_icx_custom_call => G_ITEM_REDO_TBL(l_index).icx_custom_call,
	              p_update_flag => G_ITEM_REDO_TBL(l_index).update_flag,
	              p_required_flag => G_ITEM_REDO_TBL(l_index).required_flag,
	              p_security_code => G_ITEM_REDO_TBL(l_index).security_code,
	              p_default_value_varchar2 =>
	                 G_ITEM_REDO_TBL(l_index).default_value_varchar2,
	              p_default_value_number =>
	                 G_ITEM_REDO_TBL(l_index).default_value_number,
	              p_default_value_date =>
	                 G_ITEM_REDO_TBL(l_index).default_value_date,
	              p_lov_region_application_id =>
	                 G_ITEM_REDO_TBL(l_index).lov_region_application_id,
	              p_lov_region_code => G_ITEM_REDO_TBL(l_index).lov_region_code,
	              p_lov_foreign_key_name => G_ITEM_REDO_TBL(l_index).lov_foreign_key_name,
	              p_lov_attribute_application_id =>
	                 G_ITEM_REDO_TBL(l_index).lov_attribute_application_id,
	              p_lov_attribute_code => G_ITEM_REDO_TBL(l_index).lov_attribute_code,
	              p_lov_default_flag => G_ITEM_REDO_TBL(l_index).lov_default_flag,
	              p_region_defaulting_api_pkg =>
	                 G_ITEM_REDO_TBL(l_index).region_defaulting_api_pkg,
	              p_region_defaulting_api_proc =>
	                 G_ITEM_REDO_TBL(l_index).region_defaulting_api_proc,
	              p_region_validation_api_pkg =>
	                 G_ITEM_REDO_TBL(l_index).region_validation_api_pkg,
	              p_region_validation_api_proc =>
	                 G_ITEM_REDO_TBL(l_index).region_validation_api_proc,
	              p_order_sequence => G_ITEM_REDO_TBL(l_index).order_sequence,
	              p_order_direction => G_ITEM_REDO_TBL(l_index).order_direction,
				  p_display_height => G_ITEM_REDO_TBL(l_index).display_height,
				  p_submit => G_ITEM_REDO_TBL(l_index).submit,
				  p_encrypt => G_ITEM_REDO_TBL(l_index).encrypt,
				  p_css_class_name => G_ITEM_REDO_TBL(l_index).css_class_name,
				  p_view_usage_name => G_ITEM_REDO_TBL(l_index).view_usage_name,
				  p_view_attribute_name => G_ITEM_REDO_TBL(l_index).view_attribute_name,
				  p_nested_region_appl_id => G_ITEM_REDO_TBL(l_index).nested_region_application_id,
				  p_nested_region_code => G_ITEM_REDO_TBL(l_index).nested_region_code,
				  p_url => G_ITEM_REDO_TBL(l_index).url,
				  p_poplist_viewobject => G_ITEM_REDO_TBL(l_index).poplist_viewobject,
				  p_poplist_display_attr => G_ITEM_REDO_TBL(l_index).poplist_display_attr,
				  p_poplist_value_attr => G_ITEM_REDO_TBL(l_index).poplist_value_attr,
				  p_image_file_name => G_ITEM_REDO_TBL(l_index).image_file_name,
				  p_item_name => G_ITEM_REDO_TBL(l_index).item_name,
				  p_css_label_class_name => G_ITEM_REDO_TBL(l_index).css_label_class_name,
				  p_menu_name => G_ITEM_REDO_TBL(l_index).menu_name,
				  p_flexfield_name => G_ITEM_REDO_TBL(l_index).flexfield_name,
				  p_flexfield_application_id => G_ITEM_REDO_TBL(l_index).flexfield_application_id,
                  p_tabular_function_code    => G_ITEM_REDO_TBL(l_index).tabular_function_code,
                  p_tip_type                 => G_ITEM_REDO_TBL(l_index).tip_type,
                  p_tip_message_name         => G_ITEM_REDO_TBL(l_index).tip_message_name,
                  p_tip_message_application_id  => G_ITEM_REDO_TBL(l_index).tip_message_application_id ,
                  p_flex_segment_list        => G_ITEM_REDO_TBL(l_index).flex_segment_list,
                  p_entity_id  => G_ITEM_REDO_TBL(l_index).entity_id ,
                  p_anchor => G_ITEM_REDO_TBL(l_index).anchor,
                  p_poplist_view_usage_name => G_ITEM_REDO_TBL(l_index).poplist_view_usage_name,
		  p_user_customizable => G_ITEM_REDO_TBL(l_index).user_customizable,
                  p_sortby_view_attribute_name => G_ITEM_REDO_TBL(l_index).sortby_view_attribute_name,
		  p_admin_customizable => G_ITEM_REDO_TBL(l_index).admin_customizable,
		  p_invoke_function_name => G_ITEM_REDO_TBL(l_index).invoke_function_name,
		  p_expansion => G_ITEM_REDO_TBL(l_index).expansion,
		  p_als_max_length => G_ITEM_REDO_TBL(l_index).als_max_length,
                  p_initial_sort_sequence => G_ITEM_REDO_TBL(l_index).initial_sort_sequence,
		  p_customization_application_id => G_ITEM_REDO_TBL(l_index).customization_application_id,
		  p_customization_code => G_ITEM_REDO_TBL(l_index).customization_code,
	              p_attribute_category => G_ITEM_REDO_TBL(l_index).attribute_category,
				  p_attribute1 => G_ITEM_REDO_TBL(l_index).attribute1,
				  p_attribute2 => G_ITEM_REDO_TBL(l_index).attribute2,
				  p_attribute3 => G_ITEM_REDO_TBL(l_index).attribute3,
				  p_attribute4 => G_ITEM_REDO_TBL(l_index).attribute4,
				  p_attribute5 => G_ITEM_REDO_TBL(l_index).attribute5,
				  p_attribute6 => G_ITEM_REDO_TBL(l_index).attribute6,
				  p_attribute7 => G_ITEM_REDO_TBL(l_index).attribute7,
				  p_attribute8 => G_ITEM_REDO_TBL(l_index).attribute8,
				  p_attribute9 => G_ITEM_REDO_TBL(l_index).attribute9,
				  p_attribute10 => G_ITEM_REDO_TBL(l_index).attribute10,
				  p_attribute11 => G_ITEM_REDO_TBL(l_index).attribute11,
				  p_attribute12 => G_ITEM_REDO_TBL(l_index).attribute12,
				  p_attribute13 => G_ITEM_REDO_TBL(l_index).attribute13,
				  p_attribute14 => G_ITEM_REDO_TBL(l_index).attribute14,
				  p_attribute15 => G_ITEM_REDO_TBL(l_index).attribute15,
	              p_attribute_label_long => G_ITEM_REDO_TBL(l_index).attribute_label_long,
	              p_attribute_label_short =>G_ITEM_REDO_TBL(l_index).attribute_label_short,
				  p_description => G_ITEM_REDO_TBL(l_index).description,
		p_created_by => G_ITEM_REDO_TBL(l_index).created_by,
		p_creation_date => G_ITEM_REDO_TBL(l_index).creation_date,
		p_last_updated_by => G_ITEM_REDO_TBL(l_index).last_updated_by,
		p_last_update_date => G_ITEM_REDO_TBL(l_index).last_update_date,
		p_last_update_login => G_ITEM_REDO_TBL(l_index).last_update_login,
	              p_loader_timestamp => p_loader_timestamp,
	  		      p_pass => p_pass,
	              p_copy_redo_flag => l_copy_redo_flag
	            );
			end if; -- /* if l_user_id1 = 1 and l_user_id2 = 1 */
          end if; -- /* if G_UPDATE_MODE G_NO_CUSTOM_UPDATE*/
        else
          AK_REGION_PVT.CREATE_ITEM (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
            p_region_application_id =>G_ITEM_REDO_TBL(l_index).region_application_id,
            p_region_code => G_ITEM_REDO_TBL(l_index).region_code,
            p_attribute_application_id =>
                             G_ITEM_REDO_TBL(l_index).attribute_application_id,
            p_attribute_code => G_ITEM_REDO_TBL(l_index).attribute_code,
            p_display_sequence => G_ITEM_REDO_TBL(l_index).display_sequence,
            p_node_display_flag => G_ITEM_REDO_TBL(l_index).node_display_flag,
            p_node_query_flag => G_ITEM_REDO_TBL(l_index).node_query_flag,
            p_attribute_label_length =>
                             G_ITEM_REDO_TBL(l_index).attribute_label_length,
            p_display_value_length =>
                             G_ITEM_REDO_TBL(l_index).display_value_length,
            p_bold => G_ITEM_REDO_TBL(l_index).bold,
            p_italic => G_ITEM_REDO_TBL(l_index).italic,
            p_vertical_alignment => G_ITEM_REDO_TBL(l_index).vertical_alignment,
            p_horizontal_alignment => G_ITEM_REDO_TBL(l_index).horizontal_alignment,
            p_item_style => G_ITEM_REDO_TBL(l_index).item_style,
            p_object_attribute_flag =>G_ITEM_REDO_TBL(l_index).object_attribute_flag,
            p_icx_custom_call => G_ITEM_REDO_TBL(l_index).icx_custom_call,
            p_update_flag => G_ITEM_REDO_TBL(l_index).update_flag,
            p_required_flag => G_ITEM_REDO_TBL(l_index).required_flag,
            p_security_code => G_ITEM_REDO_TBL(l_index).security_code,
            p_default_value_varchar2 =>
               G_ITEM_REDO_TBL(l_index).default_value_varchar2,
            p_default_value_number =>
               G_ITEM_REDO_TBL(l_index).default_value_number,
            p_default_value_date =>
               G_ITEM_REDO_TBL(l_index).default_value_date,
            p_lov_region_application_id =>
               G_ITEM_REDO_TBL(l_index).lov_region_application_id,
            p_lov_region_code => G_ITEM_REDO_TBL(l_index).lov_region_code,
            p_lov_foreign_key_name => G_ITEM_REDO_TBL(l_index).lov_foreign_key_name,
            p_lov_attribute_application_id =>
               G_ITEM_REDO_TBL(l_index).lov_attribute_application_id,
            p_lov_attribute_code => G_ITEM_REDO_TBL(l_index).lov_attribute_code,
            p_lov_default_flag => G_ITEM_REDO_TBL(l_index).lov_default_flag,
            p_region_defaulting_api_pkg =>
               G_ITEM_REDO_TBL(l_index).region_defaulting_api_pkg,
            p_region_defaulting_api_proc =>
               G_ITEM_REDO_TBL(l_index).region_defaulting_api_proc,
            p_region_validation_api_pkg =>
               G_ITEM_REDO_TBL(l_index).region_validation_api_pkg,
            p_region_validation_api_proc =>
               G_ITEM_REDO_TBL(l_index).region_validation_api_proc,
            p_order_sequence => G_ITEM_REDO_TBL(l_index).order_sequence,
            p_order_direction => G_ITEM_REDO_TBL(l_index).order_direction,
			p_display_height => G_ITEM_REDO_TBL(l_index).display_height,
			p_submit => G_ITEM_REDO_TBL(l_index).submit,
			p_encrypt => G_ITEM_REDO_TBL(l_index).encrypt,
			p_css_class_name => G_ITEM_REDO_TBL(l_index).css_class_name,
			p_view_usage_name => G_ITEM_REDO_TBL(l_index).view_usage_name,
			p_view_attribute_name => G_ITEM_REDO_TBL(l_index).view_attribute_name,
			p_nested_region_appl_id => G_ITEM_REDO_TBL(l_index).nested_region_application_id,
			p_nested_region_code => G_ITEM_REDO_TBL(l_index).nested_region_code,
			p_url => G_ITEM_REDO_TBL(l_index).url,
			p_poplist_viewobject => G_ITEM_REDO_TBL(l_index).poplist_viewobject,
			p_poplist_display_attr => G_ITEM_REDO_TBL(l_index).poplist_display_attr,
			p_poplist_value_attr => G_ITEM_REDO_TBL(l_index).poplist_value_attr,
			p_image_file_name => G_ITEM_REDO_TBL(l_index).image_file_name,
			p_css_label_class_name => G_ITEM_REDO_TBL(l_index).css_label_class_name,
			p_menu_name => G_ITEM_REDO_TBL(l_index).menu_name,
			p_flexfield_name => G_ITEM_REDO_TBL(l_index).flexfield_name,
			p_flexfield_application_id => G_ITEM_REDO_TBL(l_index).flexfield_application_id,
            p_tabular_function_code    => G_ITEM_REDO_TBL(l_index).tabular_function_code,
            p_tip_type                 => G_ITEM_REDO_TBL(l_index).tip_type,
            p_tip_message_name         => G_ITEM_REDO_TBL(l_index).tip_message_name,
            p_tip_message_application_id  => G_ITEM_REDO_TBL(l_index).tip_message_application_id ,
            p_flex_segment_list        => G_ITEM_REDO_TBL(l_index).flex_segment_list,
            p_entity_id  => G_ITEM_REDO_TBL(l_index).entity_id ,
            p_anchor => G_ITEM_REDO_TBL(l_index).anchor,
            p_poplist_view_usage_name => G_ITEM_REDO_TBL(l_index).poplist_view_usage_name,
	    p_user_customizable => G_ITEM_REDO_TBL(l_index).user_customizable,
            p_sortby_view_attribute_name => G_ITEM_REDO_TBL(l_index).sortby_view_attribute_name,
	    p_admin_customizable => G_ITEM_REDO_TBL(l_index).admin_customizable,
	    p_invoke_function_name => G_ITEM_REDO_TBL(l_index).invoke_function_name,
	    p_expansion => G_ITEM_REDO_TBL(l_index).expansion,
	    p_als_max_length => G_ITEM_REDO_TBL(l_index).als_max_length,
            p_initial_sort_sequence => G_ITEM_REDO_TBL(l_index).initial_sort_sequence,
	    p_customization_application_id => G_ITEM_REDO_TBL(l_index).customization_application_id,
	    p_customization_code => G_ITEM_REDO_TBL(l_index).customization_code,
            p_attribute_category => G_ITEM_REDO_TBL(l_index).attribute_category,
			p_attribute1 => G_ITEM_REDO_TBL(l_index).attribute1,
			p_attribute2 => G_ITEM_REDO_TBL(l_index).attribute2,
			p_attribute3 => G_ITEM_REDO_TBL(l_index).attribute3,
			p_attribute4 => G_ITEM_REDO_TBL(l_index).attribute4,
			p_attribute5 => G_ITEM_REDO_TBL(l_index).attribute5,
			p_attribute6 => G_ITEM_REDO_TBL(l_index).attribute6,
			p_attribute7 => G_ITEM_REDO_TBL(l_index).attribute7,
			p_attribute8 => G_ITEM_REDO_TBL(l_index).attribute8,
			p_attribute9 => G_ITEM_REDO_TBL(l_index).attribute9,
			p_attribute10 => G_ITEM_REDO_TBL(l_index).attribute10,
			p_attribute11 => G_ITEM_REDO_TBL(l_index).attribute11,
			p_attribute12 => G_ITEM_REDO_TBL(l_index).attribute12,
			p_attribute13 => G_ITEM_REDO_TBL(l_index).attribute13,
			p_attribute14 => G_ITEM_REDO_TBL(l_index).attribute14,
			p_attribute15 => G_ITEM_REDO_TBL(l_index).attribute15,
            p_attribute_label_long => G_ITEM_REDO_TBL(l_index).attribute_label_long,
            p_attribute_label_short =>G_ITEM_REDO_TBL(l_index).attribute_label_short,
			p_description => G_ITEM_REDO_TBL(l_index).description,
		p_created_by => G_ITEM_REDO_TBL(l_index).created_by,
		p_creation_date => G_ITEM_REDO_TBL(l_index).creation_date,
		p_last_updated_by => G_ITEM_REDO_TBL(l_index).last_updated_by,
		p_last_update_date => G_ITEM_REDO_TBL(l_index).lasT_update_date,
		p_last_update_login => G_ITEM_REDO_TBL(l_index).last_update_login,
            p_loader_timestamp => p_loader_timestamp,
		    p_pass => p_pass,
            p_copy_redo_flag => l_copy_redo_flag
          );
        end if; -- /* if ITEM_EXISTS */
        --
        -- If API call returns with an error status, upload aborts
        if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
        (l_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        end if; -- /* if l_return_status */
      end if; -- /* if G_ITEM_REDO_TBL.exists */
    end loop;
  end if;

  --
  -- create or update all region lov relations to the database
  --
  if (G_LOV_RELATION_REDO_INDEX > 0) then
    for l_index in G_LOV_RELATION_REDO_TBL.FIRST .. G_LOV_RELATION_REDO_TBL.LAST loop
      if (G_LOV_RELATION_REDO_TBL.exists(l_index)) then
	    if ( G_LOV_RELATION_REDO_TBL(l_index).base_region_appl_id is null ) then
		  G_LOV_RELATION_REDO_TBL(l_index).base_region_appl_id := G_LOV_RELATION_REDO_TBL(l_index).region_application_id;
		end if;
		if ( G_LOV_RELATION_REDO_TBL(l_index).base_region_code is null ) then
  		  G_LOV_RELATION_REDO_TBL(l_index).base_region_code := G_LOV_RELATION_REDO_TBL(l_index).region_code;
		end if;

        if AK_REGION2_PVT.LOV_RELATION_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_region_application_id =>
                               G_LOV_RELATION_REDO_TBL(l_index).region_application_id,
            p_region_code => G_LOV_RELATION_REDO_TBL(l_index).region_code,
            p_attribute_application_id =>
            					G_LOV_RELATION_REDO_TBL(l_index).attribute_application_id,
            p_attribute_code => G_LOV_RELATION_REDO_TBL(l_index).attribute_code,
            p_lov_region_appl_id => G_LOV_RELATION_REDO_TBL(l_index).lov_region_appl_id,
            p_lov_region_code => G_LOV_RELATION_REDO_TBL(l_index).lov_region_code,
            p_lov_attribute_appl_id =>
            					G_LOV_RELATION_REDO_TBL(l_index).lov_attribute_appl_id,
            p_lov_attribute_code => G_LOV_RELATION_REDO_TBL(l_index).lov_attribute_code,
			p_base_attribute_appl_id => G_LOV_RELATION_REDO_TBL(l_index).base_attribute_appl_id,
			p_base_attribute_code => G_LOV_RELATION_REDO_TBL(l_index).base_attribute_code,
            p_direction_flag => G_LOV_RELATION_REDO_TBL(l_index).direction_flag,
	    p_base_region_appl_id => G_LOV_RELATION_REDO_TBL(l_index).base_region_appl_id,
	    p_base_region_code => G_LOV_RELATION_REDO_TBL(l_index).base_region_code) then
          AK_REGION2_PVT.UPDATE_LOV_RELATION (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
            p_region_application_id =>
                                G_LOV_RELATION_REDO_TBL(l_index).region_application_id,
            p_region_code => G_LOV_RELATION_REDO_TBL(l_index).region_code,
            p_attribute_application_id =>
                                G_LOV_RELATION_REDO_TBL(l_index).attribute_application_id,
            p_attribute_code => G_LOV_RELATION_REDO_TBL(l_index).attribute_code,
			p_lov_region_appl_id => G_LOV_RELATION_REDO_TBL(l_index).lov_region_appl_id,
			p_lov_region_code => G_LOV_RELATION_REDO_TBL(l_index).lov_region_code,
			p_lov_attribute_appl_id => G_LOV_RELATION_REDO_TBL(l_index).lov_attribute_appl_id,
			p_lov_attribute_code => G_LOV_RELATION_REDO_TBL(l_index).lov_attribute_code,
			p_base_attribute_appl_id => G_LOV_RELATION_REDO_TBL(l_index).base_attribute_appl_id,
			p_base_attribute_code => G_LOV_RELATION_REDO_TBL(l_index).base_attribute_code,
            p_direction_flag => G_LOV_RELATION_REDO_TBL(l_index).direction_flag,
	    p_base_region_appl_id => G_LOV_RELATION_REDO_TBL(l_index).base_region_appl_id,
	    p_base_region_code => G_LOV_RELATION_REDO_TBL(l_index).base_region_code,
			p_required_flag => G_LOV_RELATION_REDO_TBL(l_index).required_flag,
            p_loader_timestamp => p_loader_timestamp,
		    p_pass => p_pass,
            p_copy_redo_flag => l_copy_redo_flag
          );
        else
          AK_REGION2_PVT.CREATE_LOV_RELATION (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
            p_region_application_id =>
                                G_LOV_RELATION_REDO_TBL(l_index).region_application_id,
            p_region_code => G_LOV_RELATION_REDO_TBL(l_index).region_code,
            p_attribute_application_id =>
                                G_LOV_RELATION_REDO_TBL(l_index).attribute_application_id,
            p_attribute_code => G_LOV_RELATION_REDO_TBL(l_index).attribute_code,
			p_lov_region_appl_id => G_LOV_RELATION_REDO_TBL(l_index).lov_region_appl_id,
			p_lov_region_code => G_LOV_RELATION_REDO_TBL(l_index).lov_region_code,
			p_lov_attribute_appl_id => G_LOV_RELATION_REDO_TBL(l_index).lov_attribute_appl_id,
			p_lov_attribute_code => G_LOV_RELATION_REDO_TBL(l_index).lov_attribute_code,
			p_base_attribute_appl_id => G_LOV_RELATION_REDO_TBL(l_index).base_attribute_appl_id,
			p_base_attribute_code => G_LOV_RELATION_REDO_TBL(l_index).base_attribute_code,
            p_direction_flag => G_LOV_RELATION_REDO_TBL(l_index).direction_flag,
	    p_base_region_appl_id => G_LOV_RELATION_REDO_TBL(l_index).base_region_appl_id,
	    p_base_region_code => G_LOV_RELATION_REDO_TBL(l_index).base_region_code,
			p_required_flag => G_LOV_RELATION_REDO_TBL(l_index).required_flag,
	p_created_by => G_LOV_RELATION_REDO_TBL(l_index).created_by,
	p_creation_date => G_LOV_RELATION_REDO_TBL(l_index).creation_date,
	p_last_updated_by => G_LOV_RELATION_REDO_TBL(l_index).last_updated_by,
	p_last_update_date => G_LOV_RELATION_REDO_TBL(l_index).last_update_date,
	p_last_update_login => G_LOV_RELATION_REDO_TBL(l_index).last_update_login,
            p_loader_timestamp => p_loader_timestamp,
		    p_pass => p_pass,
            p_copy_redo_flag => l_copy_redo_flag
          );
        end if; -- /* if LOV_RELATION_EXISTS */
        --
        -- If API call returns with an error status, upload aborts
        if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
        (l_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        end if; -- /* if l_return_status */
      end if; -- /* if G_LOV_RELATION_REDO_TBL.exists(l_index) */
    end loop;
  end if; -- /* if G_LOV_RELATION_REDO_INDEX > 0 */

  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  p_return_status := FND_API.G_RET_STS_ERROR;
  FND_MSG_PUB.Count_And_Get (
   p_count => l_msg_count,
   p_data => l_msg_data);
WHEN OTHERS THEN
  p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                         SUBSTR (SQLERRM, 1, 240) );
  FND_MSG_PUB.Count_And_Get (
    p_count => l_msg_count,
    p_data => l_msg_data);

end UPLOAD_REGION_SECOND;

--=======================================================
--  Procedure   CHECK_DISPLAY_SEQUENCE
--
--  Usage       Private API for making sure that the
--              display sequence is unique for a given region
--              code.
--
--  Desc        This API updates a region item, if necessary
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region Item columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure CHECK_DISPLAY_SEQUENCE (
  p_validation_level        IN      NUMBER,
  p_region_code             IN      VARCHAR2,
  p_region_application_id   IN      NUMBER,
  p_attribute_code          IN      VARCHAR2,
  p_attribute_application_id IN     NUMBER,
  p_display_sequence        IN      NUMBER,
  p_return_status           OUT NOCOPY     VARCHAR2,
  p_msg_count               OUT NOCOPY     NUMBER,
  p_msg_data                OUT NOCOPY     VARCHAR2,
  p_pass                    IN      NUMBER,
  p_copy_redo_flag          IN OUT NOCOPY  BOOLEAN
) is
  cursor l_ri_csr ( region_code_param IN VARCHAR2,
                    region_application_id_param IN NUMBER,
                    display_sequence_param IN NUMBER) is
    select *
    from   ak_region_items
    where  region_code = region_code_param
    and    region_application_id = region_application_id_param
    and    display_sequence = display_sequence_param;

  cursor l_ri_tl_csr (  region_code_param IN VARCHAR2,
                        region_application_id_param IN NUMBER,
                        attribute_code_param IN VARCHAR2,
                        attribute_application_id_param IN NUMBER,
                        lang_param IN VARCHAR2) is
    select *
    from   ak_region_items_tl
    where  region_code = region_code_param
    and    region_application_id = region_application_id_param
    and    attribute_code = attribute_code_param
    and    attribute_application_id = attribute_application_id_param
    and    language = lang_param;

  l_lang                    varchar2(30);
  l_api_name                CONSTANT varchar2(30) := 'Check_Display_Sequence';
  l_new_display_sequence    NUMBER;
  l_return_status           VARCHAR2(1);
  l_ri_rec                  ak_region_items%ROWTYPE;
  l_orig_ri_rec             ak_region_items%ROWTYPE;
  l_ri_tl_rec               ak_region_items_tl%ROWTYPE;

begin
  l_return_status := FND_API.G_RET_STS_SUCCESS;
  open l_ri_csr(    p_region_code,
                    p_region_application_id,
                    p_display_sequence);
  fetch l_ri_csr into l_ri_rec;

  --** Does it exists?
  if (l_ri_csr%found) then
    if ((l_ri_rec.attribute_code <> p_attribute_code) or
        (l_ri_rec.attribute_application_id <> p_attribute_application_id)) then
        --** Save it.
        l_orig_ri_rec := l_ri_rec;

        --** Get the TL entry
        select userenv('LANG') into l_lang from dual;
        open l_ri_tl_csr(   p_region_code,
                            p_region_application_id,
                            l_ri_rec.attribute_code,
                            l_ri_rec.attribute_application_id,
                            l_lang);
        fetch l_ri_tl_csr into l_ri_tl_rec;

        --** Bump up the display sequence value of the region item record
        l_new_display_sequence := p_display_sequence + 1000000;
        close l_ri_csr;
        open l_ri_csr(  p_region_code,
                        p_region_application_id,
                        l_new_display_sequence);
        fetch l_ri_csr into l_ri_rec;

        --** Keep looping until you can't find a record.
        while (l_ri_csr%found) loop
          close l_ri_csr;
          l_new_display_sequence := l_new_display_sequence + 1;
          open l_ri_csr(  p_region_code,
                          p_region_application_id,
                          l_new_display_sequence);
          fetch l_ri_csr into l_ri_rec;
        end loop;

        --** ASSUMPTION: You have found a unique sequence number for this region.
        AK_REGION_PVT.UPDATE_ITEM (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => p_msg_count,
            p_msg_data => p_msg_data,
            p_return_status => l_return_status,
            p_region_application_id =>l_orig_ri_rec.region_application_id,
            p_region_code => l_orig_ri_rec.region_code,
            p_attribute_application_id => l_orig_ri_rec.attribute_application_id,
            p_attribute_code => l_orig_ri_rec.attribute_code,
            p_display_sequence => l_new_display_sequence,
            p_node_display_flag => l_orig_ri_rec.node_display_flag,
            p_node_query_flag => l_orig_ri_rec.node_query_flag,
            p_attribute_label_length => l_orig_ri_rec.attribute_label_length,
            p_display_value_length => l_orig_ri_rec.display_value_length,
            p_bold => l_orig_ri_rec.bold,
            p_italic => l_orig_ri_rec.italic,
            p_vertical_alignment => l_orig_ri_rec.vertical_alignment,
            p_horizontal_alignment => l_orig_ri_rec.horizontal_alignment,
            p_item_style => l_orig_ri_rec.item_style,
            p_object_attribute_flag =>l_orig_ri_rec.object_attribute_flag,
            p_icx_custom_call => l_orig_ri_rec.icx_custom_call,
            p_update_flag => l_orig_ri_rec.update_flag,
            p_required_flag => l_orig_ri_rec.required_flag,
            p_security_code => l_orig_ri_rec.security_code,
            p_default_value_varchar2 => l_orig_ri_rec.default_value_varchar2,
            p_default_value_number => l_orig_ri_rec.default_value_number,
            p_default_value_date => l_orig_ri_rec.default_value_date,
            p_lov_region_application_id => l_orig_ri_rec.lov_region_application_id,
            p_lov_region_code => l_orig_ri_rec.lov_region_code,
            p_lov_foreign_key_name => l_orig_ri_rec.lov_foreign_key_name,
            p_lov_attribute_application_id => l_orig_ri_rec.lov_attribute_application_id,
            p_lov_attribute_code => l_orig_ri_rec.lov_attribute_code,
            p_lov_default_flag => l_orig_ri_rec.lov_default_flag,
            p_region_defaulting_api_pkg => l_orig_ri_rec.region_defaulting_api_pkg,
            p_region_defaulting_api_proc => l_orig_ri_rec.region_defaulting_api_proc,
            p_region_validation_api_pkg => l_orig_ri_rec.region_validation_api_pkg,
            p_region_validation_api_proc => l_orig_ri_rec.region_validation_api_proc,
            p_order_sequence => l_orig_ri_rec.order_sequence,
            p_order_direction => l_orig_ri_rec.order_direction,
			p_display_height => l_orig_ri_rec.display_height,
			p_submit => l_orig_ri_rec.submit,
			p_encrypt => l_orig_ri_rec.encrypt,
			p_css_class_name => l_orig_ri_rec.css_class_name,
			p_view_usage_name =>l_orig_ri_rec.view_usage_name,
			p_view_attribute_name =>l_orig_ri_rec.view_attribute_name,
			p_nested_region_appl_id =>l_orig_ri_rec.nested_region_application_id,
			p_nested_region_code =>l_orig_ri_rec.nested_region_code,
			p_url =>l_orig_ri_rec.url,
			p_poplist_viewobject =>l_orig_ri_rec.poplist_viewobject,
			p_poplist_display_attr =>l_orig_ri_rec.poplist_display_attribute,
			p_poplist_value_attr =>l_orig_ri_rec.poplist_value_attribute,
			p_image_file_name =>l_orig_ri_rec.image_file_name,
			p_item_name => l_orig_ri_rec.item_name,
			p_css_label_class_name => l_orig_ri_rec.css_label_class_name,
			p_menu_name => l_orig_ri_rec.menu_name,
			p_flexfield_name => l_orig_ri_rec.flexfield_name,
			p_flexfield_application_id => l_orig_ri_rec.flexfield_application_id,
            p_tabular_function_code    => l_orig_ri_rec.tabular_function_code,
            p_tip_type                 => l_orig_ri_rec.tip_type,
            p_tip_message_name         => l_orig_ri_rec.tip_message_name,
            p_tip_message_application_id  => l_orig_ri_rec.tip_message_application_id ,
            p_flex_segment_list        => l_orig_ri_rec.flex_segment_list,
            p_entity_id  => l_orig_ri_rec.entity_id,
            p_anchor => l_orig_ri_rec.anchor,
            p_poplist_view_usage_name => l_orig_ri_rec.poplist_view_usage_name,
	    p_user_customizable => l_orig_ri_rec.user_customizable,
            p_sortby_view_attribute_name => l_orig_ri_rec.sortby_view_attribute_name,
	    p_admin_customizable => l_orig_ri_rec.admin_customizable,
	    p_invoke_function_name => l_orig_ri_rec.invoke_function_name,
	    p_expansion => l_orig_ri_rec.expansion,
	    p_als_max_length => l_orig_ri_rec.als_max_length,
            p_initial_sort_sequence => l_orig_ri_rec.initial_sort_sequence,
	    p_customization_application_id => l_orig_ri_rec.customization_application_id,
	    p_customization_code => l_orig_ri_rec.customization_code,
            p_attribute_category => l_orig_ri_rec.attribute_category,
			p_attribute1 => l_orig_ri_rec.attribute1,
			p_attribute2 => l_orig_ri_rec.attribute2,
			p_attribute3 => l_orig_ri_rec.attribute3,
			p_attribute4 => l_orig_ri_rec.attribute4,
			p_attribute5 => l_orig_ri_rec.attribute5,
			p_attribute6 => l_orig_ri_rec.attribute6,
			p_attribute7 => l_orig_ri_rec.attribute7,
			p_attribute8 => l_orig_ri_rec.attribute8,
			p_attribute9 => l_orig_ri_rec.attribute9,
			p_attribute10 => l_orig_ri_rec.attribute10,
			p_attribute11 => l_orig_ri_rec.attribute11,
			p_attribute12 => l_orig_ri_rec.attribute12,
			p_attribute13 => l_orig_ri_rec.attribute13,
			p_attribute14 => l_orig_ri_rec.attribute14,
			p_attribute15 => l_orig_ri_rec.attribute15,
            p_attribute_label_long => l_ri_tl_rec.attribute_label_long,
            p_attribute_label_short =>l_ri_tl_rec.attribute_label_short,
			p_description => l_ri_tl_rec.description,
		p_created_by => l_ri_tl_rec.created_by,
		p_creation_date => l_ri_tl_rec.creation_date,
		p_last_updated_by => l_ri_tl_rec.last_updated_by,
		p_last_update_date => l_ri_tl_rec.last_update_date,
		p_last_update_login => l_ri_tl_rec.last_update_login,
            p_pass => p_pass,
            p_copy_redo_flag => p_copy_redo_flag
          );
    end if;
  end if;

  p_return_status := l_return_status;
  close l_ri_csr;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;

end CHECK_DISPLAY_SEQUENCE;

/*
--=======================================================
--  Function    GRAPH_COLUMN_EXISTS
--
--  Usage       Private API for checking for the existence of
--              a region graph column with the given key values. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API check to see if a region graph column record
--              exists with the given key values.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              This function will return TRUE if such an object
--              attribute exists, or FALSE otherwise.
--  Parameters  Region Graph Column key columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
FUNCTION GRAPH_COLUMN_EXISTS (
  p_api_version_number          IN      NUMBER,
  p_return_status                       OUT NOCOPY             VARCHAR2,
  p_region_application_id       IN              NUMBER,
  p_region_code                         IN              VARCHAR2,
  p_attribute_application_id IN         NUMBER,
  p_attribute_code                      IN              VARCHAR2,
  p_graph_number			IN		NUMBER
) return boolean is
  cursor l_check_graph_column_csr is
    select 1
    from  AK_REGION_GRAPH_COLUMNS
    where region_application_id = p_region_application_id
    and   region_code = p_region_code
    and   attribute_application_id = p_attribute_application_id
    and   attribute_code = p_attribute_code
    and   graph_number = p_graph_number;

  l_api_version_number CONSTANT number := 1.0;
  l_api_name           CONSTANT varchar2(30) := 'Graph_Column_Exists';
  l_dummy              number;
begin
  IF NOT FND_API.Compatible_API_Call (
    l_api_version_number, p_api_version_number, l_api_name,
    G_PKG_NAME) then
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return FALSE;
  END IF;

  open l_check_graph_column_csr;
  fetch l_check_graph_column_csr into l_dummy;
  if (l_check_graph_column_csr%notfound) then
    close l_check_graph_column_csr;
    p_return_status := FND_API.G_RET_STS_SUCCESS;
     return FALSE;
  else
    close l_check_graph_column_csr;
    p_return_status := FND_API.G_RET_STS_SUCCESS;
    return TRUE;
  end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
    return FALSE;
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;
    return FALSE;
end GRAPH_COLUMN_EXISTS;
*/

--=======================================================
--  Function    LOV_RELATION_EXISTS
--
--  Usage       Private API for checking for the existence of
--              a region lov relation with the given key values. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API check to see if a region lov relation record
--              exists with the given key values.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              This function will return TRUE if such an object
--              attribute exists, or FALSE otherwise.
--  Parameters  Region Lov Relation key columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
FUNCTION LOV_RELATION_EXISTS (
  p_api_version_number		IN      NUMBER,
  p_return_status			OUT NOCOPY		VARCHAR2,
  p_region_application_id	IN		NUMBER,
  p_region_code				IN		VARCHAR2,
  p_attribute_application_id IN		NUMBER,
  p_attribute_code			IN		VARCHAR2,
  p_lov_region_appl_id		IN		NUMBER,
  p_lov_region_code			IN		VARCHAR2,
  p_lov_attribute_appl_id	IN		NUMBER,
  p_lov_attribute_code		IN		VARCHAR2,
  p_base_attribute_appl_id	IN		NUMBER,
  p_base_attribute_code		IN		VARCHAR2,
  p_direction_flag			IN		VARCHAR2,
  p_base_region_appl_id		IN		NUMBER,
  p_base_region_code		IN		VARCHAR2
) return boolean is
  cursor l_check_lov_relation_csr is
    select 1
    from  AK_REGION_LOV_RELATIONS
    where region_application_id = p_region_application_id
    and   region_code = p_region_code
    and   attribute_application_id = p_attribute_application_id
    and   attribute_code = p_attribute_code
    and   lov_region_appl_id = p_lov_region_appl_id
    and   lov_region_code = p_lov_region_code
    and   lov_attribute_appl_id = p_lov_attribute_appl_id
    and   lov_attribute_code = p_lov_attribute_code
	and   base_attribute_appl_id = p_base_attribute_appl_id
	and   base_attribute_code = p_base_attribute_code
    and   direction_flag = p_direction_flag
    and   base_region_appl_id = p_base_region_appl_id
    and   base_region_code = p_base_region_code;

  l_api_version_number CONSTANT number := 1.0;
  l_api_name           CONSTANT varchar2(30) := 'Lov_Relation_Exists';
  l_dummy              number;
begin
  IF NOT FND_API.Compatible_API_Call (
    l_api_version_number, p_api_version_number, l_api_name,
    G_PKG_NAME) then
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return FALSE;
  END IF;

  open l_check_lov_relation_csr;
  fetch l_check_lov_relation_csr into l_dummy;
  if (l_check_lov_relation_csr%notfound) then
    close l_check_lov_relation_csr;
    p_return_status := FND_API.G_RET_STS_SUCCESS;
     return FALSE;
  else
    close l_check_lov_relation_csr;
    p_return_status := FND_API.G_RET_STS_SUCCESS;
    return TRUE;
  end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
    return FALSE;
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;
    return FALSE;
end LOV_RELATION_EXISTS;

/*
--=======================================================
--  Function    VALIDATE_GRAPH_COLUMN
--
--  Usage       Private API for validating a region graph column. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Perform validation on a region graph column record.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              In addition, this function returns TRUE if all
--              validation tests are passed, or FALSE otherwise.
--  Parameters  Region graph column columns
--              p_caller : IN required
--                  Must be one of the following values defined
--                  in package AK_ON_OBJECTS_PVT:
--                  - G_CREATE   (if calling from the Create API)
--                  - G_DOWNLOAD (if calling from the Download API)
--                  - G_UPDATE   (if calling from the Update API)
--
--  Note        This API is intended for performing record-level
--              validation. It is not designed for item-level
--              validation.
--
--  Version     Initial version number  =   1.1
--=======================================================
FUNCTION VALIDATE_GRAPH_COLUMN (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_region_application_id    IN      NUMBER := FND_API.G_MISS_NUM,
  p_region_code              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute_application_id IN      NUMBER := FND_API.G_MISS_NUM,
  p_attribute_code           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_graph_number	     IN      NUMBER := FND_API.G_MISS_NUM,
  p_pass		     IN      NUMBER := 2,
  p_caller		     IN      VARCHAR2
) return boolean is
  cursor l_check_region_graph_csr (param_region_code in varchar2,
  param_region_appl_id in number, param_graph_number in number) is
    select  1
    from    AK_REGION_GRAPHS
    where   region_application_id = param_region_appl_id
    and     region_code = param_region_code
    and     graph_number = param_graph_number;

  cursor l_check_region_item_csr (param_region_code in varchar2,
  param_region_appl_id in number, param_attr_appl_id in number,
  param_attr_code in varchar2) is
    select 1
    from   AK_REGION_ITEMS
    where  region_application_id = param_region_appl_id
    and    region_code = param_region_code
    and    attribute_application_id = param_attr_appl_id
    and    attribute_code = param_attr_code;

  l_api_version_number      CONSTANT number := 1.0;
  l_api_name                CONSTANT varchar2(30) := 'validate_graph_column';

  l_dummy                   NUMBER;
  l_error                   BOOLEAN;
  l_return_status           VARCHAR2(1);
begin

  IF NOT FND_API.Compatible_API_Call (
    l_api_version_number, p_api_version_number, l_api_name,
    G_PKG_NAME) then
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return FALSE;
  END IF;

  l_error := FALSE;

  --** if validation level is none, no validation is necessary
  if (p_validation_level = FND_API.G_VALID_LEVEL_NONE) then
    p_return_status := FND_API.G_RET_STS_SUCCESS;
    return TRUE;
  end if;

  --** check that key columns are not null and not missing **
  if ((p_region_application_id is null) or
      (p_region_application_id = FND_API.G_MISS_NUM)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'REGION_APPLICATION_ID');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_region_code is null) or
      (p_region_code = FND_API.G_MISS_CHAR)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'REGION_CODE');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_attribute_application_id is null) or
      (p_attribute_application_id = FND_API.G_MISS_NUM)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'ATTRIBUTE_APPLICATION_ID');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_attribute_code is null) or
      (p_attribute_code = FND_API.G_MISS_CHAR)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'ATTRIBUTE_CODE');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_graph_number is null) or
      (p_graph_number = FND_API.G_MISS_NUM)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'GRAPH_NUMBER');
      FND_MSG_PUB.Add;
    end if;
  end if;

  -- - Check that the parent region item exists
  open l_check_region_item_csr(p_region_code, p_region_application_id, p_attribute_application_id, p_attribute_code);
  fetch l_check_region_item_csr into l_dummy;
  if (l_check_region_item_csr%notfound) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_INVALID_REG_ITEM_REFERENCE');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
                           ' ' || p_region_code ||' '||
			   to_char(p_attribute_application_id) || ' '||
			   p_attribute_code);
      FND_MSG_PUB.Add;
    end if;
  end if;
  close l_check_region_item_csr;

  -- - Check that the parent region graph exists
  open l_check_region_graph_csr(p_region_code, p_region_application_id, p_graph_number);
  fetch l_check_Region_graph_csr into l_dummy;
  if (l_check_region_graph_csr%notfound) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_INVALID_REG_GRAPH_REFERENCE');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
                           ' ' || p_region_code ||' '||
                           p_graph_number);
      FND_MSG_PUB.Add;
    end if;
  end if;
  close l_check_region_graph_csr;

  -- return true if no error, false otherwise
  p_return_status := FND_API.G_RET_STS_SUCCESS;
  return (not l_error);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
    return FALSE;
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;
    return FALSE;

end VALIDATE_GRAPH_COLUMN;
*/

--=======================================================
--  Function    VALIDATE_LOV_RELATION
--
--  Usage       Private API for validating a region lov relation. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Perform validation on a region lov relation record.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              In addition, this function returns TRUE if all
--              validation tests are passed, or FALSE otherwise.
--  Parameters  Region lov relation columns
--              p_caller : IN required
--                  Must be one of the following values defined
--                  in package AK_ON_OBJECTS_PVT:
--                  - G_CREATE   (if calling from the Create API)
--                  - G_DOWNLOAD (if calling from the Download API)
--                  - G_UPDATE   (if calling from the Update API)
--
--  Note        This API is intended for performing record-level
--              validation. It is not designed for item-level
--              validation.
--
--  Version     Initial version number  =   1.1
--=======================================================
FUNCTION VALIDATE_LOV_RELATION (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_region_application_id    IN      NUMBER := FND_API.G_MISS_NUM,
  p_region_code              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute_application_id IN      NUMBER := FND_API.G_MISS_NUM,
  p_attribute_code           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_lov_region_appl_id    	 IN      NUMBER := FND_API.G_MISS_NUM,
  p_lov_region_code          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_lov_attribute_appl_id	 IN      NUMBER := FND_API.G_MISS_NUM,
  p_lov_attribute_code       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_base_attribute_appl_id	 IN      NUMBER := FND_API.G_MISS_NUM,
  p_base_attribute_code		 IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_direction_flag			 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
  p_base_region_appl_id		IN	NUMBER := FND_API.G_MISS_NUM,
  p_base_region_code		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_caller                   IN      VARCHAR2,
  p_pass                     IN      NUMBER := 2
) return boolean is
  cursor l_check_region_csr (param_region_code in varchar2, param_region_appl_id in number) is
    select  1
    from    AK_REGIONS
    where   region_application_id = param_region_appl_id
    and     region_code = param_region_code;

  cursor l_check_region_item_csr (param_region_code in varchar2, param_region_appl_id in number,
  						param_attr_code in varchar2, param_attr_appl_id number) is
    select  1
    from    AK_REGION_ITEMS
    where   region_application_id = param_region_appl_id
    and     region_code = param_region_code
    and     attribute_application_id = param_attr_appl_id;

  l_api_version_number      CONSTANT number := 1.0;
  l_api_name                CONSTANT varchar2(30) := 'validate_lov_relation';

  l_dummy                   NUMBER;
  l_error                   BOOLEAN;
  l_return_status           VARCHAR2(1);
begin

  IF NOT FND_API.Compatible_API_Call (
    l_api_version_number, p_api_version_number, l_api_name,
    G_PKG_NAME) then
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return FALSE;
  END IF;

  l_error := FALSE;

  --** if validation level is none, no validation is necessary
  if (p_validation_level = FND_API.G_VALID_LEVEL_NONE) then
    p_return_status := FND_API.G_RET_STS_SUCCESS;
    return TRUE;
  end if;

  --** check that key columns are not null and not missing **
  if ((p_region_application_id is null) or
      (p_region_application_id = FND_API.G_MISS_NUM)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'REGION_APPLICATION_ID');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_region_code is null) or
      (p_region_code = FND_API.G_MISS_CHAR)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'REGION_CODE');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_attribute_application_id is null) or
      (p_attribute_application_id = FND_API.G_MISS_NUM)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'ATTRIBUTE_APPLICATION_ID');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_attribute_code is null) or
      (p_attribute_code = FND_API.G_MISS_CHAR)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'ATTRIBUTE_CODE');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_lov_region_appl_id is null) or
      (p_lov_region_appl_id = FND_API.G_MISS_NUM)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'REGION_APPLICATION_ID');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_lov_region_code is null) or
      (p_lov_region_code = FND_API.G_MISS_CHAR)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'REGION_CODE');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_lov_attribute_appl_id is null) or
      (p_lov_attribute_appl_id = FND_API.G_MISS_NUM)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'ATTRIBUTE_APPLICATION_ID');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_lov_attribute_code is null) or
      (p_lov_attribute_code = FND_API.G_MISS_CHAR)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'ATTRIBUTE_CODE');
      FND_MSG_PUB.Add;
    end if;
  end if;

-- do not raise an error for now, there are ppl who has an old jlt file and upload
--  it manually to a database which contains this patch
/**
  if ((p_base_region_appl_id is null) or
      (p_base_region_appl_id = FND_API.G_MISS_NUM)) then

    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'BASE_REGION_APPL_ID');
      FND_MSG_PUB.Add;
    end if;
  end if;
**/

-- do not raise an error for now, there are ppl who has an old jlt file and upload
--  it manually to a database which contains this patch
/**
  if ((p_base_region_code is null) or
      (p_base_region_code = FND_API.G_MISS_CHAR)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'BASE_REGION_CODE');
      FND_MSG_PUB.Add;
    end if;
  end if;
**/

  -- these two columns are not part of primary key but cannot be null
  --
  if ((p_base_attribute_appl_id is null) or
      (p_base_attribute_appl_id = FND_API.G_MISS_NUM)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'BASE_ATTRIBUTE_APPL_ID');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_base_attribute_code is null) or
      (p_base_attribute_code = FND_API.G_MISS_CHAR)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'BASE_ATTRIBUTE_CODE');
      FND_MSG_PUB.Add;
    end if;
  end if;

  -- - Check that the parent region item exists
  open l_check_region_item_csr(p_region_code, p_region_application_id,
  						p_attribute_code, p_attribute_application_id);
  fetch l_check_region_item_csr into l_dummy;
  if (l_check_region_item_csr%notfound) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_INVALID_REG_ITEM_REFERENCE');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
                           ' ' || p_region_code ||' '||
                           to_char(p_attribute_application_id)||' '||p_attribute_code);
      FND_MSG_PUB.Add;
    end if;
  end if;
  close l_check_region_item_csr;

  -- - Check that the lov region exists
  open l_check_region_csr(p_lov_region_code, p_lov_region_appl_id);
  fetch l_check_region_csr into l_dummy;
  if (l_check_region_csr%notfound) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_INVALID_LOV_REG_REFERENCE');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_lov_region_appl_id) ||
                           ' ' || p_lov_region_code );
      FND_MSG_PUB.Add;
    end if;
  end if;
  close l_check_region_csr;

  -- - Check that the lov region item exists
  open l_check_region_item_csr(p_lov_region_code, p_lov_region_appl_id,
  						p_lov_attribute_code, p_lov_attribute_appl_id);
  fetch l_check_region_item_csr into l_dummy;
  if (l_check_region_item_csr%notfound) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_INVALID_LOV_ITEM_REFERENCE');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_lov_region_appl_id) ||
                           ' ' || p_lov_region_code ||' '||
                           to_char(p_lov_attribute_appl_id)||' '||p_lov_attribute_code);
      FND_MSG_PUB.Add;
    end if;
  end if;
  close l_check_region_item_csr;

  -- - Check that the base region item exists
  open l_check_region_item_csr(p_base_region_code, p_base_region_appl_id,
  						p_base_attribute_code, p_base_attribute_appl_id);
  fetch l_check_region_item_csr into l_dummy;
  if (l_check_region_item_csr%notfound) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_INVALID_BASE_ITEM_REF');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_lov_region_appl_id) ||
                           ' ' || p_lov_region_code ||' '||
                           to_char(p_base_attribute_appl_id)||' '||p_base_attribute_code);
      FND_MSG_PUB.Add;
    end if;
  end if;
  close l_check_region_item_csr;

  -- direction_flag
  if ( (p_direction_flag <> FND_API.G_MISS_CHAR) and
  		(p_direction_flag is not null) )then
    if (NOT AK_ON_OBJECTS_PVT.VALID_LOOKUP_CODE (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_lookup_type  => 'LOV_DIRECTION',
            p_lookup_code => p_direction_flag)) then
      l_error := TRUE;
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
        FND_MESSAGE.SET_NAME('AK','AK_INVALID_COLUMN_VALUE');
        FND_MESSAGE.SET_TOKEN('COLUMN','DIRECTION_FLAG');
        FND_MSG_PUB.Add;
      end if;
    end if;
  else
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'DIRECTION_FLAG');
      FND_MSG_PUB.Add;
    end if;
  end if;

  -- return true if no error, false otherwise
  p_return_status := FND_API.G_RET_STS_SUCCESS;
  return (not l_error);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
    return FALSE;
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;
    return FALSE;

end VALIDATE_LOV_RELATION;

/*
--=======================================================
--  Procedure   CREATE_GRAPH_COLUMN
--
--  Usage       Private API for creating a region graph column. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Creates a region graph column using the given info.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will create the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.1
--=======================================================
PROCEDURE CREATE_GRAPH_COLUMN (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_init_msg_tbl             IN      BOOLEAN := FALSE,
  p_msg_count                OUT NOCOPY     NUMBER,
  p_msg_data                 OUT NOCOPY     VARCHAR2,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_region_application_id    IN      NUMBER := FND_API.G_MISS_NUM,
  p_region_code              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute_application_id IN      NUMBER := FND_API.G_MISS_NUM,
  p_attribute_code           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_graph_number	     IN      NUMBER := FND_API.G_MISS_NUM,
  p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
  p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
  p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
  p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
  p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM,
  p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
  p_pass                     IN      NUMBER,
  p_copy_redo_flag           IN OUT NOCOPY  BOOLEAN
) is

  l_api_version_number CONSTANT number := 1.0;
  l_api_name           CONSTANT varchar2(30) := 'Create_Graph_Column';
  l_created_by         number;
  l_creation_date      date;
  l_last_update_date   date;
  l_last_update_login  number;
  l_last_updated_by    number;
  l_return_status      varchar2(1);

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

  savepoint start_create_graph_column;

  --** check to see if row already exists **
  if AK_REGION2_PVT.GRAPH_COLUMN_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_region_application_id => p_region_application_id,
            p_region_code => p_region_code,
            p_attribute_application_id => p_attribute_application_id,
            p_attribute_code => p_attribute_code,
	    p_graph_number => p_graph_number) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
      FND_MESSAGE.SET_NAME('AK','AK_GRAPH_COLUMN_EXISTS');
      FND_MSG_PUB.Add;
    end if;
    raise FND_API.G_EXC_ERROR;
  end if;

  --** validate table columns passed in **
  if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
    if not AK_REGION2_PVT.VALIDATE_GRAPH_COLUMN (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_region_application_id => p_region_application_id,
            p_region_code => p_region_code,
            p_attribute_application_id => p_attribute_application_id,
            p_attribute_code => p_attribute_code,
	    p_graph_number => p_graph_number,
            p_caller => AK_ON_OBJECTS_PVT.G_CREATE,
                        p_pass => p_pass
          ) then
      -- Do not raise an error if it's the first pass
          if (p_pass = 1) then
            p_copy_redo_flag := TRUE;
      else
        raise FND_API.G_EXC_ERROR;
      end if;
    end if;
  end if;

  -- Create record if no validation error was found

  -- Set WHO columns
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

  insert into AK_REGION_GRAPH_COLUMNS (
	    REGION_APPLICATION_ID,
    REGION_CODE,
        ATTRIBUTE_APPLICATION_ID,
        ATTRIBUTE_CODE,
	GRAPH_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    p_region_application_id,
    p_region_code,
        p_attribute_application_id,
        p_attribute_code,
	p_graph_number,
    l_creation_date,
    l_created_by,
    l_last_update_date,
    l_last_updated_by,
    l_last_update_login
  );

--  ** commit the insert **
--  commit;

  if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
    FND_MESSAGE.SET_NAME('AK','AK_GRAPH_COLUMN_CREATED');
    FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||' ' ||
                                        p_region_code||' '||
					to_char(p_attribute_application_id)||
					' '||p_attribute_code||' '||
					to_char(p_graph_number));
    FND_MSG_PUB.Add;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);

EXCEPTION
  WHEN VALUE_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_GRAPH_COLUMN_VALUE_ERROR');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||' '||
                                        p_region_code||' '||
					to_char(p_attribute_application_id)||
					' '||p_attribute_code||' '||
					to_char(p_graph_number));
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
    rollback to start_create_graph_column;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    rollback to start_create_graph_column;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);

end CREATE_GRAPH_COLUMN;
*/

--=======================================================
--  Procedure   CREATE_LOV_RELATION
--
--  Usage       Private API for creating a region lov relation. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Creates a region lov relation using the given info.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will create the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.1
--=======================================================
PROCEDURE CREATE_LOV_RELATION (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_init_msg_tbl             IN      BOOLEAN := FALSE,
  p_msg_count                OUT NOCOPY     NUMBER,
  p_msg_data                 OUT NOCOPY     VARCHAR2,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_region_application_id    IN      NUMBER := FND_API.G_MISS_NUM,
  p_region_code              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute_application_id IN      NUMBER := FND_API.G_MISS_NUM,
  p_attribute_code           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_lov_region_appl_id    	 IN      NUMBER := FND_API.G_MISS_NUM,
  p_lov_region_code          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_lov_attribute_appl_id	 IN      NUMBER := FND_API.G_MISS_NUM,
  p_lov_attribute_code       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_base_attribute_appl_id IN      NUMBER := FND_API.G_MISS_NUM,
  p_base_attribute_code     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_direction_flag			 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
  p_base_region_appl_id		IN 	NUMBER := FND_API.G_MISS_NUM,
  p_base_region_code		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_required_flag			IN		VARCHAR2 := FND_API.G_MISS_CHAR,
  p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
  p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
  p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
  p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
  p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM,
  p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
  p_pass                     IN      NUMBER,
  p_copy_redo_flag           IN OUT NOCOPY  BOOLEAN
) is

  l_api_version_number CONSTANT number := 1.0;
  l_api_name           CONSTANT varchar2(30) := 'Create_Lov_Relation';
  l_created_by         number;
  l_creation_date      date;
  l_direction_flag     VARCHAR2(30) := null;
  l_required_flag      VARCHAR2(1) := 'N';
  l_last_update_date   date;
  l_last_update_login  number;
  l_last_updated_by    number;
  l_return_status      varchar2(1);

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

  savepoint start_create_lov_relation;

  --** check to see if row already exists **
  if AK_REGION2_PVT.LOV_RELATION_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_region_application_id => p_region_application_id,
            p_region_code => p_region_code,
            p_attribute_application_id => p_attribute_application_id,
            p_attribute_code => p_attribute_code,
            p_lov_region_appl_id => p_lov_region_appl_id,
            p_lov_region_code => p_lov_region_code,
            p_lov_attribute_appl_id => p_lov_attribute_appl_id,
            p_lov_attribute_code => p_lov_attribute_code,
	    p_base_attribute_appl_id => p_base_attribute_appl_id,
	    p_base_attribute_code => p_base_attribute_code,
            p_direction_flag => p_direction_flag,
	    p_base_region_appl_id => p_base_region_appl_id,
	    p_base_region_code => p_base_region_code) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
      FND_MESSAGE.SET_NAME('AK','AK_LOV_RELATION_EXISTS');
      FND_MSG_PUB.Add;
    end if;
    raise FND_API.G_EXC_ERROR;
  end if;

  --** validate table columns passed in **
  if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
    if not AK_REGION2_PVT.VALIDATE_LOV_RELATION (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_region_application_id => p_region_application_id,
            p_region_code => p_region_code,
	    p_attribute_application_id => p_attribute_application_id,
            p_attribute_code => p_attribute_code,
            p_lov_region_appl_id => p_lov_region_appl_id,
            p_lov_region_code => p_lov_region_code,
            p_lov_attribute_appl_id => p_lov_attribute_appl_id,
            p_lov_attribute_code => p_lov_attribute_code,
	    p_base_attribute_appl_id => p_base_attribute_appl_id,
	    p_base_attribute_code => p_base_attribute_code,
            p_direction_flag => p_direction_flag,
	    p_base_region_appl_id => p_base_region_appl_id,
	    p_base_region_code => p_base_region_code,
            p_caller => AK_ON_OBJECTS_PVT.G_CREATE,
			p_pass => p_pass
          ) then
      -- Do not raise an error if it's the first pass
	  if (p_pass = 1) then
	    p_copy_redo_flag := TRUE;
      else
        raise FND_API.G_EXC_ERROR;
      end if;
    end if;
  end if;

  -- default a value for required_flag column if no value is given
  if ( p_required_flag <> FND_API.G_MISS_CHAR and p_required_flag is not null ) then
	l_required_flag := p_required_flag;
  end if;

  if (p_created_by <> FND_API.G_MISS_NUM) then
    l_created_by := p_created_by;
  end if;

  if (p_creation_date <> FND_API.G_MISS_DATE) then
    l_creation_date := p_creation_date;
  end if;

  if (p_last_updated_by <> FND_API.G_MISS_NUM) then
    l_last_updated_by := p_last_updated_by;
  end if;

  if (p_last_update_date <> FND_API.G_MISS_DATE) then
    l_last_update_date := p_last_update_date;
  end if;

  if (p_last_update_login <> FND_API.G_MISS_NUM) then
    l_last_update_login := p_last_update_login;
  end if;


  -- Create record if no validation error was found
  --  NOTE - Calling IS_UPDATEABLE for backward compatibility
  --  old jlt files didn't have who columns and IS_UPDATEABLE
  --  calls SET_WHO which populates those columns, for later
  --  jlt files IS_UPDATEABLE will always return TRUE for CREATE

if AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
       p_loader_timestamp => p_loader_timestamp,
       p_created_by => l_created_by,
       p_creation_date => l_creation_date,
       p_last_updated_by => l_last_updated_by,
       p_db_last_updated_by => null,
       p_last_update_date => l_last_update_date,
       p_db_last_update_date => null,
       p_last_update_login => l_last_update_login,
       p_create_or_update => 'CREATE') then
     null;
  end if;

  insert into AK_REGION_LOV_RELATIONS (
    REGION_APPLICATION_ID,
    REGION_CODE,
	ATTRIBUTE_APPLICATION_ID,
	ATTRIBUTE_CODE,
	LOV_REGION_APPL_ID,
	LOV_REGION_CODE,
	LOV_ATTRIBUTE_APPL_ID,
	LOV_ATTRIBUTE_CODE,
	BASE_ATTRIBUTE_APPL_ID,
	BASE_ATTRIBUTE_CODE,
	DIRECTION_FLAG,
	BASE_REGION_APPL_ID,
	BASE_REGION_CODE,
	REQUIRED_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    p_region_application_id,
    p_region_code,
	p_attribute_application_id,
	p_attribute_code,
	p_lov_region_appl_id,
	p_lov_region_code,
	p_lov_attribute_appl_id,
	p_lov_attribute_code,
	p_base_attribute_appl_id,
	p_base_attribute_code,
	p_direction_flag,
	p_base_region_appl_id,
	p_base_region_code,
	l_required_flag,
    l_creation_date,
    l_created_by,
    l_last_update_date,
    l_last_updated_by,
    l_last_update_login
  );

--  /** commit the insert **/
--  commit;

  if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
    FND_MESSAGE.SET_NAME('AK','AK_LOV_RELATION_CREATED');
    FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||' ' ||
   					p_region_code||' '||to_char(p_attribute_application_id)||
   					' '||p_attribute_code||' '||
   					to_char(p_lov_region_appl_id)||' '||p_lov_region_code||
   					' '||to_char(p_lov_attribute_appl_id)||' '||
   					p_lov_region_code||' '||to_char(p_base_attribute_appl_id)||
   					' '||p_base_attribute_code);
    FND_MSG_PUB.Add;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);

EXCEPTION
  WHEN VALUE_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_REGION_VALUE_ERROR');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||' '||
   					p_region_code||' '||to_char(p_attribute_application_id)||
   					' '||p_attribute_code||' '||
   					to_char(p_lov_region_appl_id)||' '||p_lov_region_code||
   					' '||to_char(p_lov_attribute_appl_id)||' '||
   					p_lov_region_code||' '||to_char(p_base_attribute_appl_id)||
   					' '||p_base_attribute_code);
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
    rollback to start_create_lov_relation;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
  WHEN FND_API.G_EXC_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_REGION_NOT_CREATED');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||' '||
   					p_region_code||' '||to_char(p_attribute_application_id)||
   					' '||p_attribute_code||' '||
   					to_char(p_lov_region_appl_id)||' '||p_lov_region_code||
   					' '||to_char(p_lov_attribute_appl_id)||' '||
   					p_lov_region_code||' '||to_char(p_base_attribute_appl_id)||
   					' '||p_base_attribute_code);
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
    rollback to start_create_lov_relation;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    rollback to start_create_region;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);

end CREATE_LOV_RELATION;

/*
--=======================================================
--  Procedure   UPDATE_GRAPH_COLUMN
--
--  Usage       Private API for updating a region graph column.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API updates a region graph column using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region graph column columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will update the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
PROCEDURE UPDATE_GRAPH_COLUMN (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_init_msg_tbl             IN      BOOLEAN := FALSE,
  p_msg_count                OUT NOCOPY     NUMBER,
  p_msg_data                 OUT NOCOPY     VARCHAR2,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_region_application_id    IN      NUMBER := FND_API.G_MISS_NUM,
  p_region_code              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute_application_id IN      NUMBER := FND_API.G_MISS_NUM,
  p_attribute_code           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_graph_number	     IN      NUMBER := FND_API.G_MISS_NUM,
  p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
  p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
  p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
  p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
  p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM,
  p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
  p_pass                     IN      NUMBER,
  p_copy_redo_flag           IN OUT NOCOPY  BOOLEAN
) is
  cursor l_get_row_csr is
    select *
    from  AK_REGION_GRAPH_COLUMNS
    where REGION_APPLICATION_ID = p_region_application_id
    and   REGION_CODE = p_region_code
        and   ATTRIBUTE_APPLICATION_ID = p_attribute_application_id
        and   ATTRIBUTE_CODE = p_attribute_code
	and   GRAPH_NUMBER = p_graph_number
	for update of GRAPH_NUMBER;
  l_api_version_number      CONSTANT number := 1.0;
  l_api_name                CONSTANT varchar2(30) := 'Update_Graph_Column';
  l_created_by              number;
  l_creation_date           date;
  l_graph_column_rec        AK_REGION_GRAPH_COLUMNS%ROWTYPE;
  l_last_update_date        date;
  l_last_update_login       number;
  l_last_updated_by         number;
  l_return_status           varchar2(1);
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

  savepoint start_update_graph_columns;

  --** retrieve ak_region_graph_columns row if it exists **
  open l_get_row_csr;
  fetch l_get_row_csr into l_graph_column_rec;
  if (l_get_row_csr%notfound) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
      FND_MESSAGE.SET_NAME('AK','AK_GRAPH_COLUMN_DOES_NOT_EXIST');
      FND_MSG_PUB.Add;
    end if;
    --dbms_output.put_line(l_api_name || 'Error - Row does not exist');
    close l_get_row_csr;
    raise FND_API.G_EXC_ERROR;
  end if;
  close l_get_row_csr;

  --** validate table columns passed in **
  if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
    if not AK_REGION2_PVT.VALIDATE_GRAPH_COLUMN (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_region_application_id => p_region_application_id,
            p_region_code => p_region_code,
            p_attribute_application_id => p_attribute_application_id,
            p_attribute_code => p_attribute_code,
	    p_graph_number => p_graph_number,
            p_caller => AK_ON_OBJECTS_PVT.G_UPDATE,
                        p_pass => p_pass
      ) then
      --dbms_output.put_line(l_api_name || 'validation failed');
      -- Do not raise an error if it's the first pass
          if (p_pass = 1) then
            p_copy_redo_flag := TRUE;
      else
        raise FND_API.G_EXC_ERROR;
      end if; --  if p_pass
    end if;
  end if;

  --** Load record to be updated to the database **
  --** - first load nullable columns **


  --** - next, load non-null, non-key columns **

  -- Set WHO columns
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

  update AK_REGION_GRAPH_COLUMNS set
      LAST_UPDATE_DATE = l_last_update_date,
      LAST_UPDATED_BY = l_last_updated_by,
      LAST_UPDATE_LOGIN = l_last_update_login
  where REGION_APPLICATION_ID = p_region_application_id
  and   REGION_CODE = p_region_code
  and   ATTRIBUTE_APPLICATION_ID = p_attribute_application_id
  and   ATTRIBUTE_CODE = p_attribute_code
  and   GRAPH_NUMBER = p_graph_number;
  if (sql%notfound) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_GRAPH_COLUMN_UPDATE_FAILED');
      FND_MSG_PUB.Add;
    end if;
    raise FND_API.G_EXC_ERROR;
  end if;

--  ** commit the update **
--  commit;

  if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
    FND_MESSAGE.SET_NAME('AK','AK_GRAPH_COLUMN_UPDATED');
    FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
                                 ' ' || p_region_code);
    FND_MSG_PUB.Add;
  end if;

   p_return_status := FND_API.G_RET_STS_SUCCESS;

  FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);

EXCEPTION
  WHEN VALUE_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_GRAPH_COLUMN_VALUE_ERROR');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||' '||
                                        p_region_code||' '||
					to_char(p_attribute_application_id)||
					' '||p_attribute_code||' '||
					to_char(p_graph_number));
      FND_MSG_PUB.Add;
    end if;
    rollback to start_update_graph_column;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
  WHEN FND_API.G_EXC_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_GRAPH_COLUMN_NOT_UPDATED');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||' '||
                                        p_region_code||' '||
					to_char(p_attribute_application_id)||
					' '||p_attribute_code||' '||
					to_char(p_graph_number));
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
    rollback to start_update_graph_column;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    rollback to start_update_graph_column;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
     FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);

end UPDATE_GRAPH_COLUMN;
*/

--=======================================================
--  Procedure   UPDATE_LOV_RELATION
--
--  Usage       Private API for updating a region lov relation.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API updates a region lov relation using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region lov relation columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will update the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
PROCEDURE UPDATE_LOV_RELATION (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_init_msg_tbl             IN      BOOLEAN := FALSE,
  p_msg_count                OUT NOCOPY     NUMBER,
  p_msg_data                 OUT NOCOPY     VARCHAR2,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_region_application_id    IN      NUMBER := FND_API.G_MISS_NUM,
  p_region_code              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute_application_id IN      NUMBER := FND_API.G_MISS_NUM,
  p_attribute_code           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_lov_region_appl_id    	 IN      NUMBER := FND_API.G_MISS_NUM,
  p_lov_region_code          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_lov_attribute_appl_id	 IN      NUMBER := FND_API.G_MISS_NUM,
  p_lov_attribute_code       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_base_attribute_appl_id	 IN      NUMBER := FND_API.G_MISS_NUM,
  p_base_attribute_code		 IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_direction_flag			 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
  p_base_region_appl_id		IN	NUMBER := FND_API.G_MISS_NUM,
  p_base_region_code		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_required_flag			 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
  p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
  p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
  p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
  p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
  p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM,
  p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
  p_pass                     IN      NUMBER,
  p_copy_redo_flag           IN OUT NOCOPY  BOOLEAN
) is
  cursor l_get_row_csr is
    select *
    from  AK_REGION_LOV_RELATIONS
    where REGION_APPLICATION_ID = p_region_application_id
    and   REGION_CODE = p_region_code
	and   ATTRIBUTE_APPLICATION_ID = p_attribute_application_id
	and   ATTRIBUTE_CODE = p_attribute_code
    and   LOV_REGION_APPL_ID = p_lov_region_appl_id
    and   LOV_REGION_CODE = p_lov_region_code
	and   LOV_ATTRIBUTE_APPL_ID = p_lov_attribute_appl_id
	and   LOV_ATTRIBUTE_CODE = p_lov_attribute_code
	and	  BASE_ATTRIBUTE_APPL_ID = p_base_attribute_appl_id
	and   BASE_ATTRIBUTE_CODE = p_base_attribute_code
	and   DIRECTION_FLAG =p_direction_flag
	and   BASE_REGION_APPL_ID = p_base_region_appl_id
	and   BASE_REGION_CODE = p_base_region_code
    for update of REQUIRED_FLAG;
  l_api_version_number      CONSTANT number := 1.0;
  l_api_name                CONSTANT varchar2(30) := 'Update_Lov_Relation';
  l_created_by              number;
  l_creation_date           date;
  l_lov_relation_rec        AK_REGION_LOV_RELATIONS%ROWTYPE;
  l_required_flag			varchar2(1) := 'N';
  l_last_update_date        date;
  l_last_update_login       number;
  l_last_updated_by         number;
  l_return_status           varchar2(1);
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

  savepoint start_update_lov_relation;

  --** retrieve ak_region_lov_relations row if it exists **
  open l_get_row_csr;
  fetch l_get_row_csr into l_lov_relation_rec;
  if (l_get_row_csr%notfound) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
      FND_MESSAGE.SET_NAME('AK','AK_LOV_REGION_DOES_NOT_EXIST');
      FND_MSG_PUB.Add;
    end if;
    --dbms_output.put_line(l_api_name || 'Error - Row does not exist');
    close l_get_row_csr;
    raise FND_API.G_EXC_ERROR;
  end if;
  close l_get_row_csr;

  --** validate table columns passed in **
  if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
    if not AK_REGION2_PVT.VALIDATE_LOV_RELATION (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_region_application_id => p_region_application_id,
            p_region_code => p_region_code,
	    p_attribute_application_id => p_attribute_application_id,
            p_attribute_code => p_attribute_code,
            p_lov_region_appl_id => p_lov_region_appl_id,
            p_lov_region_code => p_lov_region_code,
            p_lov_attribute_appl_id => p_lov_attribute_appl_id,
            p_lov_attribute_code => p_lov_attribute_code,
	    p_base_attribute_appl_id => p_base_attribute_appl_id,
	    p_base_attribute_code => p_base_attribute_code,
            p_direction_flag => p_direction_flag,
	    p_base_region_appl_id => p_base_region_appl_id,
	    p_base_region_code => p_base_region_code,
            p_caller => AK_ON_OBJECTS_PVT.G_UPDATE,
			p_pass => p_pass
      ) then
      --dbms_output.put_line(l_api_name || 'validation failed');
      -- Do not raise an error if it's the first pass
	  if (p_pass = 1) then
	    p_copy_redo_flag := TRUE;
      else
        raise FND_API.G_EXC_ERROR;
      end if; -- /* if p_pass */
    end if;
  end if;

  --** Load record to be updated to the database **
  --** - first load nullable columns **


  --** - next, load non-null, non-key columns **

  -- default a value for required_flag column if no value is given
  if ( p_required_flag <> FND_API.G_MISS_CHAR and p_required_flag is not null ) then
	l_lov_relation_rec.required_flag := p_required_flag;
  else
  	l_lov_relation_rec.required_flag := l_required_flag;
  end if;

  if (p_created_by <> FND_API.G_MISS_NUM) then
    l_created_by := p_created_by;
  end if;

  if (p_creation_date <> FND_API.G_MISS_DATE) then
    l_creation_date := p_creation_date;
  end if;

  if (p_last_updated_by <> FND_API.G_MISS_NUM) then
    l_last_updated_by := p_last_updated_by;
  end if;

  if (p_last_update_date <> FND_API.G_MISS_DATE) then
    l_last_update_date := p_last_update_date;
  end if;

  if (p_last_update_login <> FND_API.G_MISS_NUM) then
    l_last_update_login := p_last_update_login;
  end if;

  -- Set WHO columns
  if AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
       p_loader_timestamp => p_loader_timestamp,
       p_created_by => l_created_by,
       p_creation_date => l_creation_date,
       p_last_updated_by => l_last_updated_by,
       p_db_last_updated_by => l_lov_relation_rec.last_updated_by,
       p_last_update_date => l_last_update_date,
       p_db_last_update_date => l_lov_relation_rec.last_update_date,
       p_last_update_login => l_last_update_login,
       p_create_or_update => 'UPDATE') then

  update AK_REGION_LOV_RELATIONS set
      REQUIRED_FLAG = l_lov_relation_rec.required_flag,
      LAST_UPDATE_DATE = l_last_update_date,
      LAST_UPDATED_BY = l_last_updated_by,
      LAST_UPDATE_LOGIN = l_last_update_login
  where REGION_APPLICATION_ID = p_region_application_id
  and   REGION_CODE = p_region_code
  and	ATTRIBUTE_APPLICATION_ID = p_attribute_application_id
  and   ATTRIBUTE_CODE = p_attribute_code
  and   LOV_REGION_APPL_ID = p_lov_region_appl_id
  and   LOV_REGION_CODE = p_lov_region_code
  and   LOV_ATTRIBUTE_APPL_ID = p_lov_attribute_appl_id
  and   LOV_ATTRIBUTE_CODE = p_lov_attribute_code
  and	BASE_ATTRIBUTE_APPL_ID = p_base_attribute_appl_id
  and	BASE_ATTRIBUTE_CODE = p_base_attribute_code
  and	DIRECTION_FLAG = p_direction_flag
  and   BASE_REGION_APPL_ID = p_base_region_appl_id
  and   BASE_REGION_CODE = p_base_region_code;
  if (sql%notfound) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_LOV_RELATION_UPDATE_FAILED');
      FND_MSG_PUB.Add;
    end if;
    raise FND_API.G_EXC_ERROR;
  end if;

--  /** commit the update **/
--  commit;

  if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
    FND_MESSAGE.SET_NAME('AK','AK_LOV_RELATION_UPDATED');
    FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
                                 ' ' || p_region_code);
    FND_MSG_PUB.Add;
  end if;

  end if;
   p_return_status := FND_API.G_RET_STS_SUCCESS;

  FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);

EXCEPTION
  WHEN VALUE_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_LOV_RELATION_VALUE_ERROR');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||' '||
   					p_region_code||' '||to_char(p_attribute_application_id)||
   					' '||p_attribute_code||' '||
   					to_char(p_lov_region_appl_id)||' '||p_lov_region_code||
   					' '||to_char(p_lov_attribute_appl_id)||' '||
   					p_lov_region_code||' '||to_char(p_base_attribute_appl_id)||
   					' '||p_base_attribute_code||' '||p_direction_flag ||
					' '||to_char(p_base_region_appl_id)||' '||p_base_region_code);
      FND_MSG_PUB.Add;
    end if;
    rollback to start_update_lov_relation;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
  WHEN FND_API.G_EXC_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_LOV_RELATION_NOT_UPDATED');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||' '||
   					p_region_code||' '||to_char(p_attribute_application_id)||
   					' '||p_attribute_code||' '||
   					to_char(p_lov_region_appl_id)||' '||p_lov_region_code||
   					' '||to_char(p_lov_attribute_appl_id)||' '||
   					p_lov_region_code||' '||to_char(p_base_attribute_appl_id)||
   					' '||p_base_attribute_code);
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
    rollback to start_update_lov_relation;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    rollback to start_update_lov_relation;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
     FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);

end UPDATE_LOV_RELATION;

--=======================================================
--  Function    CATEGORY_USAGE_EXISTS
--
--  Usage       Private API for checking for the existence of
--              a region item category usage with the given key values. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API check to see if a region item category usage record
--              exists with the given key values.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              This function will return TRUE if such an object
--              attribute exists, or FALSE otherwise.
--  Parameters  Region Lov Relation key columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
FUNCTION CATEGORY_USAGE_EXISTS (
  p_api_version_number		IN      NUMBER,
  p_return_status			OUT NOCOPY		VARCHAR2,
  p_region_application_id	IN		NUMBER,
  p_region_code				IN		VARCHAR2,
  p_attribute_application_id IN		NUMBER,
  p_attribute_code			IN		VARCHAR2,
  p_category_name	        	IN		VARCHAR2
) return boolean is
  cursor l_check_category_usage_csr is
    select 1
    from  AK_CATEGORY_USAGES
    where region_application_id = p_region_application_id
    and   region_code = p_region_code
    and   attribute_application_id = p_attribute_application_id
    and   attribute_code = p_attribute_code
    and   category_name = p_category_name;
  l_api_version_number CONSTANT number := 1.0;
  l_api_name           CONSTANT varchar2(30) := 'Category_Usage_Exists';
  l_dummy              number;
begin
  IF NOT FND_API.Compatible_API_Call (
    l_api_version_number, p_api_version_number, l_api_name,
    G_PKG_NAME) then
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return FALSE;
  END IF;

  open l_check_category_usage_csr;
  fetch l_check_category_usage_csr into l_dummy;
  if (l_check_category_usage_csr%notfound) then
    close l_check_category_usage_csr;
    p_return_status := FND_API.G_RET_STS_SUCCESS;
     return FALSE;
  else
    close l_check_category_usage_csr;
    p_return_status := FND_API.G_RET_STS_SUCCESS;
    return TRUE;
  end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
    return FALSE;
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;
    return FALSE;
end CATEGORY_USAGE_EXISTS;

--=======================================================
--  Function    VALIDATE_CATEGORY_USAGE
--
--  Usage       Private API for validating a region item category usage. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Perform validation on a region lov relation record.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              In addition, this function returns TRUE if all
--              validation tests are passed, or FALSE otherwise.
--  Parameters  Region lov relation columns
--              p_caller : IN required
--                  Must be one of the following values defined
--                  in package AK_ON_OBJECTS_PVT:
--                  - G_CREATE   (if calling from the Create API)
--                  - G_DOWNLOAD (if calling from the Download API)
--                  - G_UPDATE   (if calling from the Update API)
--
--  Note        This API is intended for performing record-level
--              validation. It is not designed for item-level
--              validation.
--
--  Version     Initial version number  =   1.1
--=======================================================
FUNCTION VALIDATE_CATEGORY_USAGE (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_region_application_id    IN      NUMBER := FND_API.G_MISS_NUM,
  p_region_code              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute_application_id IN      NUMBER := FND_API.G_MISS_NUM,
  p_attribute_code           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_category_name    	         IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_category_id			IN 	NUMBER := FND_API.G_MISS_NUM,
  p_application_id		IN	NUMBER := FND_API.G_MISS_NUM,
  p_show_all			IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_caller                   IN      VARCHAR2,
  p_pass                     IN      NUMBER := 2
) return boolean is

  cursor l_check_region_item_csr (param_region_code in varchar2, param_region_appl_id in number,
  						param_attr_code in varchar2, param_attr_appl_id number) is
    select  item_style
    from    AK_REGION_ITEMS
    where   region_application_id = param_region_appl_id
    and     region_code = param_region_code
    and     attribute_application_id = param_attr_appl_id
    and     attribute_code = param_attr_code;

  cursor l_check_category_csr (param_category_name in varchar2) is
    select 1
	from fnd_document_categories_vl
	where name = param_category_name;

  l_api_version_number      CONSTANT number := 1.0;
  l_api_name                CONSTANT varchar2(30) := 'validate_category_usage';

  l_item_style              VARCHAR2(30);
  l_dummy		    NUMBER;
  l_error                   BOOLEAN;
  l_return_status           VARCHAR2(1);
begin

  IF NOT FND_API.Compatible_API_Call (
    l_api_version_number, p_api_version_number, l_api_name,
    G_PKG_NAME) then
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return FALSE;
  END IF;

  l_error := FALSE;

  --** if validation level is none, no validation is necessary
  if (p_validation_level = FND_API.G_VALID_LEVEL_NONE) then
    p_return_status := FND_API.G_RET_STS_SUCCESS;
    return TRUE;
  end if;

  --** check that key columns are not null and not missing **
  if ((p_region_application_id is null) or
      (p_region_application_id = FND_API.G_MISS_NUM)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'REGION_APPLICATION_ID');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_region_code is null) or
      (p_region_code = FND_API.G_MISS_CHAR)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'REGION_CODE');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_attribute_application_id is null) or
      (p_attribute_application_id = FND_API.G_MISS_NUM)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'ATTRIBUTE_APPLICATION_ID');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_attribute_code is null) or
      (p_attribute_code = FND_API.G_MISS_CHAR)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'ATTRIBUTE_CODE');
      FND_MSG_PUB.Add;
    end if;
  end if;

  -- - Check that the parent region item exists
  open l_check_region_item_csr(p_region_code, p_region_application_id,
  						p_attribute_code, p_attribute_application_id);
  fetch l_check_region_item_csr into l_item_style;
  if (l_check_region_item_csr%notfound) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_INVALID_REG_ITEM_REFERENCE');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
                           ' ' || p_region_code ||' '||
                           to_char(p_attribute_application_id)||' '||p_attribute_code);
      FND_MSG_PUB.Add;
    end if;
  else
    if ( l_item_style <> 'ATTACHMENT_LINK' AND l_item_style <> 'ATTACHMENT_IMAGE' AND
		l_item_style <> 'ATTACHMENT_TABLE') then
	l_error := TRUE;
	if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
	  FND_MESSAGE.SET_NAME('AK','AK_INVALID_ITEM_STYLE');
	  FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
                               ' ' || p_region_code ||' '||
                                to_char(p_attribute_application_id)||' '||p_attribute_code||'  '||l_item_style);
	  FND_MSG_PUB.Add;
	end if;
    end if; -- l_item_style <> 'ATTACHMENT%'
  end if;
  close l_check_region_item_csr;

  -- - Check that the category exists
  open l_check_category_csr(p_category_name);
  fetch l_check_category_csr into l_dummy;
  if (l_check_category_csr%notfound) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_INVALID_CATEGORY_REFERENCE');
      FND_MESSAGE.SET_TOKEN('KEY', p_category_name);
      FND_MSG_PUB.Add;
    end if;
  end if;
  close l_check_category_csr;

  -- return true if no error, false otherwise
  p_return_status := FND_API.G_RET_STS_SUCCESS;
  return (not l_error);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
    return FALSE;
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;
    return FALSE;

end VALIDATE_CATEGORY_USAGE;

--=======================================================
--  Procedure   CREATE_CATEGORY_USAGE
--
--  Usage       Private API for creating a region item category usage. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Creates a region item category usage using the given info.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will create the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.1
--=======================================================
PROCEDURE CREATE_CATEGORY_USAGE (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_init_msg_tbl             IN      BOOLEAN := FALSE,
  p_msg_count                OUT NOCOPY     NUMBER,
  p_msg_data                 OUT NOCOPY     VARCHAR2,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_region_application_id    IN      NUMBER := FND_API.G_MISS_NUM,
  p_region_code              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute_application_id IN      NUMBER := FND_API.G_MISS_NUM,
  p_attribute_code           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_category_name	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_category_id         	 IN      NUMBER := FND_API.G_MISS_NUM,
  p_application_id	     IN      NUMBER := FND_API.G_MISS_NUM,
  p_show_all		     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
  p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
  p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
  p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
  p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM,
  p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
  p_pass                     IN      NUMBER,
  p_copy_redo_flag           IN OUT NOCOPY  BOOLEAN
) is

  l_api_version_number CONSTANT number := 1.0;
  l_api_name           CONSTANT varchar2(30) := 'Create_Category_Usage';
  l_created_by         number;
  l_creation_date      date;
  l_last_update_date   date;
  l_last_update_login  number;
  l_last_updated_by    number;
  l_return_status      varchar2(1);

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

  savepoint start_create_category_usage;

  --** check to see if row already exists **
  if AK_REGION2_PVT.CATEGORY_USAGE_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_region_application_id => p_region_application_id,
            p_region_code => p_region_code,
            p_attribute_application_id => p_attribute_application_id,
            p_attribute_code => p_attribute_code,
            p_category_name => p_category_name) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
      FND_MESSAGE.SET_NAME('AK','AK_CATEGORY_USAGE_EXISTS');
      FND_MSG_PUB.Add;
    end if;
    raise FND_API.G_EXC_ERROR;
  end if;

  --** validate table columns passed in **
  if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
    if not AK_REGION2_PVT.VALIDATE_CATEGORY_USAGE (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_region_application_id => p_region_application_id,
            p_region_code => p_region_code,
            p_attribute_application_id => p_attribute_application_id,
            p_attribute_code => p_attribute_code,
            p_category_name => p_category_name,
	    p_category_id => p_category_id,
	    p_application_id => p_application_id,
	    p_show_all => p_show_all,
            p_caller => AK_ON_OBJECTS_PVT.G_CREATE,
			p_pass => p_pass
          ) then
      -- Do not raise an error if it's the first pass
	  if (p_pass = 1) then
	    p_copy_redo_flag := TRUE;
      else
        raise FND_API.G_EXC_ERROR;
      end if;
    end if;
  end if;

  if (p_created_by <> FND_API.G_MISS_NUM) then
    l_created_by := p_created_by;
  end if;

  if (p_creation_date <> FND_API.G_MISS_DATE) then
    l_creation_date := p_creation_date;
  end if;

  if (p_last_updated_by <> FND_API.G_MISS_NUM) then
    l_last_updated_by := p_last_updated_by;
  end if;

  if (p_last_update_date <> FND_API.G_MISS_DATE) then
    l_last_update_date := p_last_update_date;
  end if;

  if (p_last_update_login <> FND_API.G_MISS_NUM) then
    l_last_update_login := p_last_update_login;
  end if;

  -- Create record if no validation error was found
  --  NOTE - Calling IS_UPDATEABLE for backward compatibility
  --  old jlt files didn't have who columns and IS_UPDATEABLE
  --  calls SET_WHO which populates those columns, for later
  --  jlt files IS_UPDATEABLE will always return TRUE for CREATE

if AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
       p_loader_timestamp => p_loader_timestamp,
       p_created_by => l_created_by,
       p_creation_date => l_creation_date,
       p_last_updated_by => l_last_updated_by,
       p_db_last_updated_by => null,
       p_last_update_date => l_last_update_date,
       p_db_last_update_date => null,
       p_last_update_login => l_last_update_login,
       p_create_or_update => 'CREATE') then
     null;
  end if;

  insert into AK_CATEGORY_USAGES (
    REGION_APPLICATION_ID,
    REGION_CODE,
	ATTRIBUTE_APPLICATION_ID,
	ATTRIBUTE_CODE,
	CATEGORY_NAME,
	CATEGORY_ID,
	APPLICATION_ID,
	SHOW_ALL,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    p_region_application_id,
    p_region_code,
	p_attribute_application_id,
	p_attribute_code,
	p_category_name,
	p_category_id,
	p_application_id,
	p_show_all,
    l_creation_date,
    l_created_by,
    l_last_update_date,
    l_last_updated_by,
    l_last_update_login
  );

--  /** commit the insert **/
--  commit;

  if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
    FND_MESSAGE.SET_NAME('AK','AK_CATEGORY_USAGE_CREATED');
    FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||' ' ||
   					p_region_code||' '||to_char(p_attribute_application_id)||
   					' '||p_attribute_code||' '||
   					p_category_name);
    FND_MSG_PUB.Add;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);

EXCEPTION
  WHEN VALUE_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_CATEGORY_USAGE_VALUE_ERROR');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||' '||
   					p_region_code||' '||to_char(p_attribute_application_id)||
   					' '||p_attribute_code||' '||
   					p_category_name);
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
    rollback to start_create_category_usage;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
  WHEN FND_API.G_EXC_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_CATEGORY_USAGE_NOT_CREATED');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||' '||
   					p_region_code||' '||to_char(p_attribute_application_id)||
   					' '||p_attribute_code||' '||
   					p_category_name);
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
    rollback to start_create_category_usage;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    rollback to start_create_category_usage;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);

end CREATE_CATEGORY_USAGE;

--=======================================================
--  Procedure   UPDATE_CATEGORY_USAGE
--
--  Usage       Private API for updating category usage.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API updates a region lov relation using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Category usage columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will update the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
PROCEDURE UPDATE_CATEGORY_USAGE (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_region_application_id    IN      NUMBER := FND_API.G_MISS_NUM,
p_region_code              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_application_id IN      NUMBER := FND_API.G_MISS_NUM,
p_attribute_code           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_category_name         IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_category_id                  IN      NUMBER := FND_API.G_MISS_NUM,
p_application_id                IN      NUMBER := FND_API.G_MISS_NUM,
p_show_all                      IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_created_by			IN	NUMBER := FND_API.G_MISS_NUM,
p_creation_date		   IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM,
p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
p_pass                     IN      NUMBER,
p_copy_redo_flag           IN OUT NOCOPY  BOOLEAN
) is
cursor l_get_row_csr is
select *
from AK_CATEGORY_USAGES
where REGION_APPLICATION_ID = p_region_application_id
and   REGION_CODE = p_region_code
and   ATTRIBUTE_APPLICATION_ID = p_attribute_application_id
and   ATTRIBUTE_CODE = p_attribute_code
and   CATEGORY_NAME = p_category_name;
  l_api_version_number      CONSTANT number := 1.0;
  l_api_name                CONSTANT varchar2(30) := 'Update_Category_Usage';
  l_created_by              number;
  l_creation_date           date;
  l_category_usage_rec      AK_CATEGORY_USAGES%ROWTYPE;
  l_last_update_date        date;
  l_last_update_login       number;
  l_last_updated_by         number;
  l_return_status           varchar2(1);
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

  savepoint start_update_category_usage;

  --** retrieve ak_category_usage row if it exists **
  open l_get_row_csr;
  fetch l_get_row_csr into l_category_usage_rec;
  if (l_get_row_csr%notfound) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
      FND_MESSAGE.SET_NAME('AK','AK_CATEGORY_DOES_NOT_EXIST');
      FND_MESSAGE.SET_TOKEN('KEY', (to_char(p_region_application_id) ||' '||
		p_region_code ||' '|| to_char(p_attribute_application_id)||' '||
		p_attribute_code ||' '|| p_category_name ||' '||
		to_char(p_application_id)));
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Add;
    end if;
    --dbms_output.put_line(l_api_name || 'Error - Row does not exist');
    close l_get_row_csr;
    raise FND_API.G_EXC_ERROR;
  end if;
  close l_get_row_csr;

  --** validate table columns passed in **
  if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
    if not AK_REGION2_PVT.VALIDATE_CATEGORY_USAGE (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_region_application_id => p_region_application_id,
            p_region_code => p_region_code,
            p_attribute_application_id => p_attribute_application_id,
            p_attribute_code => p_attribute_code,
  	    p_category_name => p_category_name,
  	    p_category_id => p_category_id,
  	    p_application_id => p_application_id,
  	    p_show_all => p_show_all,
            p_caller => AK_ON_OBJECTS_PVT.G_UPDATE,
            p_pass => p_pass
      ) then
      -- Do not raise an error if it's the first pass
          if (p_pass = 1) then
            p_copy_redo_flag := TRUE;
      else
        raise FND_API.G_EXC_ERROR;
      end if;
    end if;
  end if;

  if (p_created_by <> FND_API.G_MISS_NUM) then
    l_created_by := p_created_by;
  end if;
  if (p_creation_date <> FND_API.G_MISS_DATE) then
    l_creation_date := p_creation_date;
  end if;
  if (p_last_updated_by <> FND_API.G_MISS_NUM) then
    l_last_updated_by := p_last_updated_by;
  end if;
  if (p_last_update_date <> FND_API.G_MISS_DATE) then
    l_last_update_date := p_last_update_date;
  end if;
  if (p_last_update_login <> FND_API.G_MISS_NUM) then
    l_last_update_login := p_last_update_login;
  end if;

  --** Load record to be updated to the database **

  if AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
       p_loader_timestamp => p_loader_timestamp,
       p_created_by => l_created_by,
       p_creation_date => l_creation_date,
       p_last_updated_by => l_last_updated_by,
       p_db_last_updated_by => l_category_usage_rec.last_updated_by,
       p_last_update_date => l_last_update_date,
       p_db_last_update_date => l_category_usage_rec.last_update_date,
       p_last_update_login => l_last_update_login,
       p_create_or_update => 'UPDATE') then

  update AK_CATEGORY_USAGES set
      SHOW_ALL = p_show_all,
      APPLICATION_ID = p_application_id,
      LAST_UPDATE_DATE = l_last_update_date,
      LAST_UPDATED_BY = l_last_updated_by,
      LAST_UPDATE_LOGIN = l_last_update_login
  where REGION_APPLICATION_ID = p_region_application_id
  and   REGION_CODE = p_region_code
  and   ATTRIBUTE_APPLICATION_ID = p_attribute_application_id
  and   ATTRIBUTE_CODE = p_attribute_code
  and   CATEGORY_NAME = p_category_name;
  if (sql%notfound) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_CATEGORY_UPDATE_FAILED');
      FND_MSG_PUB.Add;
    end if;
    raise FND_API.G_EXC_ERROR;
  end if;

--  /** commit the update **/
--  commit;

  if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
    FND_MESSAGE.SET_NAME('AK','AK_CATEGORY_UPDATED');
    FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
                                 ' ' || p_region_code);
    FND_MSG_PUB.Add;
  end if;

  end if;

   p_return_status := FND_API.G_RET_STS_SUCCESS;

  FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);

EXCEPTION
  WHEN VALUE_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_CATEGORY_VALUE_ERROR');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||' '||
		p_region_code||' '||to_char(p_attribute_application_id)||' '||
		p_attribute_code||' '|| p_category_name ||' '||
                to_char(p_application_id));
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
    rollback to start_update_category_usage;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    rollback to start_update_category_usage;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           'PK = '||to_char(p_region_application_id) ||' '||
			p_region_code||' '||to_char(p_attribute_application_id)||' '||
			p_attribute_code||' '|| p_category_name ||' '||
			to_char(p_application_id) );
    FND_MSG_PUB.Add;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
     FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);

end UPDATE_CATEGORY_USAGE;

end AK_REGION2_PVT;

/
