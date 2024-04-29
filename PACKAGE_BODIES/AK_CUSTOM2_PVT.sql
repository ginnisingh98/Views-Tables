--------------------------------------------------------
--  DDL for Package Body AK_CUSTOM2_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AK_CUSTOM2_PVT" as
/* $Header: akdvcr2b.pls 120.3 2005/09/15 22:18:26 tshort noship $ */

--=======================================================
--  Procedure   UPLOAD_CUSTOM
--
--  Usage       Private API for loading customizations from a
--              loader file to the database.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API reads the custom data (including region
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
procedure UPLOAD_CUSTOM (
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
  l_api_version_number       CONSTANT number := 1.0;
  l_api_name                 CONSTANT varchar2(30) := 'Upload_Custom';
  l_buffer                   AK_ON_OBJECTS_PUB.Buffer_Type;
  l_column                   varchar2(30);
  l_dummy                    NUMBER;
  l_eof_flag                 VARCHAR2(1);
  l_custom_index	     NUMBER := 0;
  l_index                    NUMBER;
  l_line_num                 NUMBER;
  l_lines_read               NUMBER;
  l_more_custom              BOOLEAN := TRUE;
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(2000);
  l_return_status            varchar2(1);
  l_saved_token              AK_ON_OBJECTS_PUB.Buffer_Type;
  l_state                    NUMBER;
  l_token                    AK_ON_OBJECTS_PUB.Buffer_Type;
  l_value_count              NUMBER;
  l_copy_redo_flag           BOOLEAN := FALSE;
  l_user_id1                             NUMBER;
  l_user_id2                             NUMBER;
  l_update1				DATE;
  l_update2				DATE;
  l_custom_rec		     AK_CUSTOM_PUB.Custom_Rec_Type;
  l_custom_tbl		     AK_CUSTOM_PUB.Custom_Tbl_Type;
  l_cust_region_index	     NUMBER := 0;
  l_cust_region_rec	     AK_CUSTOM_PUB.Cust_Region_Rec_Type;
  l_cust_region_tbl	     AK_CUSTOM_PUB.Cust_Region_Tbl_Type;
  l_cust_reg_item_index	     NUMBER := 0;
  l_cust_reg_item_rec	     AK_CUSTOM_PUB.Cust_Reg_Item_Rec_Type;
  l_cust_reg_item_tbl	     AK_CUSTOM_PUB.Cust_Reg_Item_Tbl_Type;
  l_criteria_index	     NUMBER := 0;
  l_criteria_rec	     AK_CRITERIA%ROWTYPE;
  l_empty_criteria_rec	     AK_CRITERIA%ROWTYPE;
  l_criteria_tbl	     AK_CUSTOM_PUB.Criteria_Tbl_Type;
  l_error_key_info			  VARCHAR2(500); -- for debug purpose: see EXCEPTION stack

begin
  --dbms_output.put_line('Started region upload: ' ||
  --                            to_char(sysdate, 'MON-DD HH24:MI:SS'));

  IF NOT FND_API.Compatible_API_Call (
    l_api_version_number, p_api_version_number, l_api_name,
    G_PKG_NAME) then
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return;
  END IF;

  SAVEPOINT Start_Upload;

  -- Retrieve the first non-blank, non-comment line
  l_state := 0;
  l_eof_flag := 'N';
  --
  -- if calling from ak_on_objects.upload (ie, loader timestamp is given),
  -- the tokens 'BEGIN CUSTOM' has already been parsed. Set initial
  -- buffer to 'BEGIN CUSTOM' before reading the next line from the
  -- file. Otherwise, set initial buffer to null.
  --
  if (p_loader_timestamp <> FND_API.G_MISS_DATE) then
    l_buffer := 'BEGIN CUSTOMIZATION ' || p_buffer;
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
        and (l_more_custom) loop

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
    -- CUSTOM (tates 0 - 19)
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
      if (l_token = 'CUSTOMIZATION') then
        --== Clear out previous column data  ==--
    l_custom_rec := AK_CUSTOM_PUB.G_MISS_CUSTOM_REC;
       l_state := 2;
      else
        -- Found the beginning of a non-custom object,
        -- rebuild last line and pass it back to the caller
        -- (ak_on_objects_pvt.upload).
        p_buffer_out := 'BEGIN ' || l_token || ' ' || l_buffer;
        l_more_custom := FALSE;
      end if;
    elsif (l_state = 2) then
      if (l_token is not null) then
        l_custom_rec.customization_appl_id := to_number(l_token);
        l_state := 3;
      else
        --dbms_output.put_line('Expecting custom region application ID');
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 3) then
      if (l_token is not null) then
        l_custom_rec.customization_code := l_token;
        l_state := 4;
      else
        --dbms_output.put_line('Expecting customization code');
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 4) then
      if (l_token is not null) then
        l_custom_rec.region_appl_id := l_token;
        l_state := 5;
      else
        --dbms_output.put_line('Expecting region application ID');
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 5) then
      if (l_token is not null) then
        l_custom_rec.region_code := l_token;
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
      elsif (l_token = 'VERTICALIZATION_ID') or
		(l_token = 'LOCALIZATION_CODE') or
		(l_token = 'ORG_ID') or
		(l_token = 'SITE_ID') or
		(l_token = 'RESPONSIBILITY_ID') or
		(l_token = 'WEB_USER_ID') or
		(l_token = 'CUSTOMIZATION_FLAG') or
		(l_token = 'CUSTOMIZATION_LEVEL_ID') or
		(l_token = 'DEVELOPER_MODE') or
		(l_token = 'REFERENCE_PATH') or
   	        (l_token = 'FUNCTION_NAME') or
		(l_token = 'START_DATE_ACTIVE') or
		(l_token = 'END_DATE_ACTIVE') or
		(l_token = 'NAME') or
		(l_token = 'DESCRIPTION') or
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
            FND_MESSAGE.SET_TOKEN('EXPECTED','CUSTOM');
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
      if (l_column = 'VERTICALIZATION_ID') then
	l_custom_rec.verticalization_id := l_token;
      elsif (l_column = 'LOCALIZATION_CODE') then
	l_custom_rec.localization_code := l_token;
      elsif (l_column = 'ORG_ID') then
	l_custom_rec.org_id := l_token;
      elsif (l_column = 'SITE_ID') then
	l_custom_rec.site_id := l_token;
      elsif (l_column = 'RESPONSIBILITY_ID') then
	l_custom_rec.responsibility_id := l_token;
      elsif (l_column = 'WEB_USER_ID') then
	l_custom_rec.web_user_id := l_token;
      elsif (l_column = 'CUSTOMIZATION_FLAG') then
	l_custom_rec.default_customization_flag := l_token;
      elsif (l_column = 'CUSTOMIZATION_LEVEL_ID') then
	l_custom_rec.customization_level_id := l_token;
      elsif (l_column = 'DEVELOPER_MODE') then
	l_custom_rec.developer_mode := l_token;
      elsif (l_column = 'REFERENCE_PATH') then
	l_custom_rec.reference_path := l_token;
      elsif (l_column = 'FUNCTION_NAME') then
	l_custom_rec.function_name := l_token;
      elsif (l_column = 'START_DATE_ACTIVE') then
        l_custom_rec.start_date_active := to_date(l_token,
                                          AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
      elsif (l_column = 'END_DATE_ACTIVE') then
        l_custom_rec.end_date_active := to_date(l_token,
                                          AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
      elsif (l_column = 'NAME') then
	l_custom_rec.name := l_token;
      elsif (l_column = 'DESCRIPTION') then
	l_custom_rec.description := l_token;
      elsif (l_column = 'CREATED_BY') then
         l_custom_rec.created_by := to_number(l_token);
      elsif (l_column = 'CREATION_DATE') then
         l_custom_rec.creation_date := to_date(l_token,
                                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
      elsif (l_column = 'LAST_UPDATED_BY') then
         l_custom_rec.last_updated_by := to_number(l_token);
      elsif (l_column = 'OWNER') then
         l_custom_rec.last_updated_by := FND_LOAD_UTIL.OWNER_ID(l_token);
      elsif (l_column = 'LAST_UPDATE_DATE') then
         l_custom_rec.last_update_date := to_date(l_token,
                                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
      elsif (l_column = 'LAST_UPDATE_LOGIN') then
         l_custom_rec.last_update_login := to_number(l_token);
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
      if (l_token = 'CUSTOM_REGION') then
        --== Clear out previous region item column data  ==--
        --   and load region key values into record        --
                l_cust_region_rec := AK_CUSTOM_PUB.G_MISS_CUST_REGION_REC;
        l_cust_region_rec.customization_appl_id := l_custom_rec.customization_appl_id;
	l_cust_region_rec.customization_code := l_custom_rec.customization_code;
	l_cust_region_rec.region_appl_id := l_custom_rec.region_appl_id;
	l_cust_region_rec.region_code := l_custom_rec.region_code;
        l_state := 20;
          elsif ( l_token = 'CUSTOM_REGION_ITEM') then
            -- clear out previous custom region item column data --
       --   and load customization key values into record  --
	l_cust_reg_item_rec := AK_CUSTOM_PUB.G_MISS_CUST_REG_ITEM_REC;
	l_cust_reg_item_rec.customization_appl_id := l_custom_rec.customization_appl_id;
	l_cust_reg_item_rec.customization_code := l_custom_rec.customization_code;
        l_cust_reg_item_rec.region_appl_id := l_custom_rec.region_appl_id;
        l_cust_reg_item_rec.region_code := l_custom_rec.region_code;
	l_state := 100;
          elsif ( l_token = 'CRITERIA') then
            -- clear out previous custom criteria column data --
       --   and load customization key values into record  --
	l_criteria_rec := l_empty_criteria_rec;
	l_criteria_rec.customization_application_id := l_custom_rec.customization_appl_id;
	l_criteria_rec.customization_code := l_custom_rec.customization_code;
	l_criteria_rec.region_application_id := l_custom_rec.region_appl_id;
	l_criteria_rec.region_code := l_custom_rec.region_code;
	l_state := 200;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'CUSTOM_REGION, CUSTOM_REGION_ITEM, CRITERIA');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 19) then
      if (l_token = 'CUSTOMIZATION') then
        l_state := 0;
        l_custom_index := l_custom_index + 1;
 	l_custom_tbl(l_custom_index) := l_custom_rec;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'CUSTOMIZATION');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;

    --
    -- CUSTOM_REGION (States 20 - 39)
    --
    elsif (l_state = 20) then
      if (l_token is not null) then
        l_cust_region_rec.property_name := l_token;
	l_value_count := null;
        l_state := 30;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'PROPERTY_NAME');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 30) then
      if (l_token = 'END') then
        l_state := 39;
      elsif (l_token = 'PROPERTY_VARCHAR2_VALUE') or
		(l_token = 'PROPERTY_NUMBER_VALUE') or
		(l_token = 'CRITERIA_JOIN_CONDITION') or
		(l_token = 'PROPERTY_VARCHAR2_VALUE_TL') or
            (l_token = 'CREATED_BY') or
            (l_token = 'CREATION_DATE') or
            (l_token = 'LAST_UPDATED_BY') or
            (l_token = 'OWNER') or
            (l_token = 'LAST_UPDATE_DATE') or
            (l_token = 'LAST_UPDATE_LOGIN') then
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
            FND_MESSAGE.SET_TOKEN('EXPECTED','CUSTOM_REGION');
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
      if (l_column = 'PROPERTY_VARCHAR2_VALUE') then
	l_cust_region_rec.PROPERTY_VARCHAR2_VALUE := l_token;
	l_state := 30;
      elsif (l_column = 'PROPERTY_NUMBER_VALUE') then
	l_cust_region_rec.PROPERTY_NUMBER_VALUE := to_number(l_token);
	l_state := 30;
      elsif (l_column = 'CRITERIA_JOIN_CONDITION') then
	l_cust_region_rec.CRITERIA_JOIN_CONDITION := l_token;
	l_state := 30;
      elsif (l_column = 'PROPERTY_VARCHAR2_VALUE_TL') then
	l_cust_region_rec.PROPERTY_VARCHAR2_VALUE_TL := l_token;
	l_state := 30;
      elsif (l_column = 'CREATED_BY') then
         l_cust_region_rec.created_by := to_number(l_token);
	 l_state := 30;
      elsif (l_column = 'CREATION_DATE') then
         l_cust_region_rec.creation_date := to_date(l_token,
                                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
	 l_state := 30;
      elsif (l_column = 'LAST_UPDATED_BY') then
         l_cust_region_rec.last_updated_by := to_number(l_token);
	 l_state := 30;
      elsif (l_column = 'OWNER') then
         l_cust_region_rec.last_updated_by := FND_LOAD_UTIL.OWNER_ID(l_token);
         l_state := 30;
      elsif (l_column = 'LAST_UPDATE_DATE') then
         l_cust_region_rec.last_update_date := to_date(l_token,
                                       AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
	 l_state := 30;
      elsif (l_column = 'LAST_UPDATE_LOGIN') then
         l_cust_region_rec.last_update_login := to_number(l_token);
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
    elsif (l_state = 39) then
      if (l_token = 'CUSTOM_REGION') then
        l_value_count := null;
        l_state := 10;
        l_cust_region_index := l_cust_region_index + 1;
	l_cust_region_tbl(l_cust_region_index) := l_cust_region_rec;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'CUSTOM_REGION');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;

    --
    -- CUSTOM_REGION_ITEM (states 100 - 139)
    --
    elsif (l_state = 100) then
      if (l_token is not null) then
        l_cust_reg_item_rec.attr_appl_id := to_number(l_token);
	l_state := 101;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'ATTRIBUTE_APPL_ID');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 101) then
      if (l_token is not null) then
        l_cust_reg_item_rec.attr_code := l_token;
        l_state := 102;
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
    elsif (l_state = 102) then
      if (l_token is not null) then
        l_cust_reg_item_rec.property_name := l_token;
	l_value_count := null;
	l_state := 130;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'PROPERTY_NAME');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 130) then
      if (l_token = 'END') then
        l_state := 139;
          elsif ( l_token = 'PROPERTY_VARCHAR2_VALUE') or
		( l_token = 'PROPERTY_NUMBER_VALUE') or
		( l_token = 'PROPERTY_DATE_VALUE') or
		( l_token = 'PROPERTY_VARCHAR2_VALUE_TL') or
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
            FND_MESSAGE.SET_TOKEN('EXPECTED','CUSTOM_REGION_ITEM');
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
      if (l_column = 'PROPERTY_VARCHAR2_VALUE') then
	l_cust_reg_item_rec.PROPERTY_VARCHAR2_VALUE := l_token;
	l_state := 130;
      elsif (l_column = 'PROPERTY_NUMBER_VALUE') then
	l_cust_reg_item_rec.PROPERTY_NUMBER_VALUE := to_number(l_token);
	l_state := 130;
      elsif (l_column = 'PROPERTY_DATE_VALUE') then
	l_cust_reg_item_rec.PROPERTY_DATE_VALUE := to_date(l_token,
                                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
	l_state := 130;
      elsif (l_column = 'PROPERTY_VARCHAR2_VALUE_TL') then
	l_cust_reg_item_rec.PROPERTY_VARCHAR2_VALUE_TL := l_token;
	l_state := 130;
      elsif (l_column = 'CREATED_BY') then
         l_cust_reg_item_rec.created_by := to_number(l_token);
	l_state := 130;
      elsif (l_column = 'CREATION_DATE') then
         l_cust_reg_item_rec.creation_date := to_date(l_token,
                                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
	l_state := 130;
      elsif (l_column = 'LAST_UPDATED_BY') then
         l_cust_reg_item_rec.last_updated_by := to_number(l_token);
	l_state := 130;
      elsif (l_column = 'OWNER') then
         l_cust_reg_item_rec.last_updated_by := FND_LOAD_UTIL.OWNER_ID(l_token);
        l_state := 130;
      elsif (l_column = 'LAST_UPDATE_DATE') then
         l_cust_reg_item_rec.last_update_date := to_date(l_token,
                                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
	l_state := 130;
      elsif (l_column = 'LAST_UPDATE_LOGIN') then
         l_cust_reg_item_rec.last_update_login := to_number(l_token);
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
      if (l_token = 'CUSTOM_REGION_ITEM') then
        l_value_count := null;
        l_state := 10;
	l_cust_reg_item_index := l_cust_reg_item_index + 1;
	l_cust_reg_item_tbl(l_cust_reg_item_index) := l_cust_reg_item_rec;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'CUSTOM_REGION_ITEM');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;

    --
    -- CRITERIA (states 200 - 239)
    --
    elsif (l_state = 200) then
      if (l_token is not null) then
        l_criteria_rec.attribute_application_id := to_number(l_token);
        l_state := 201;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'ATTRIBUTE_APPL_ID');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 201) then
      if (l_token is not null) then
        l_criteria_rec.attribute_code := l_token;
	l_state := 202;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'ATTRIBUTE_CODE');
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 202) then
      if (l_token is not null) then
        l_criteria_rec.sequence_number := to_number(l_token);
        l_value_count := null;
        l_state := 230;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'SEQUENCE_NUMBER');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 230) then
      if (l_token = 'END') then
        l_state := 239;
          elsif ( l_token = 'OPERATION' ) or
		( l_token = 'VALUE_VARCHAR2' ) or
		( l_token = 'VALUE_NUMBER' ) or
		( l_token = 'VALUE_DATE' ) or
		( l_token = 'START_DATE_ACTIVE') or
		( l_token = 'END_DATE_ACTIVE') or
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
            FND_MESSAGE.SET_TOKEN('EXPECTED','CRITERIA');
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
      if (l_column = 'OPERATION') then
	l_criteria_rec.OPERATION := l_token;
	l_state := 230;
      elsif (l_column = 'VALUE_VARCHAR2') then
	l_criteria_rec.VALUE_VARCHAR2 := l_token;
	l_state := 230;
      elsif (l_column = 'VALUE_NUMBER') then
	l_criteria_rec.VALUE_NUMBER := to_number(l_token);
	l_state := 230;
      elsif (l_column = 'VALUE_DATE') then
	l_criteria_rec.VALUE_DATE := to_date(l_token,
                                           AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
	l_state := 230;
      elsif (l_column = 'START_DATE_ACTIVE') then
        l_criteria_rec.START_DATE_ACTIVE := to_date(l_token,
                                           AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
        l_state := 230;
      elsif (l_column = 'END_DATE_ACTIVE') then
        l_criteria_rec.END_DATE_ACTIVE := to_date(l_token,
                                           AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
        l_state := 230;
      elsif (l_column = 'CREATED_BY') then
         l_criteria_rec.created_by := to_number(l_token);
	l_state := 230;
      elsif (l_column = 'CREATION_DATE') then
         l_criteria_rec.creation_date := to_date(l_token,
                                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
        l_state := 230;
      elsif (l_column = 'LAST_UPDATED_BY') then
         l_criteria_rec.last_updated_by := to_number(l_token);
        l_state := 230;
      elsif (l_column = 'OWNER') then
         l_criteria_rec.last_updated_by := FND_LOAD_UTIL.OWNER_ID(l_token);
        l_state := 230;
      elsif (l_column = 'LAST_UPDATE_DATE') then
         l_criteria_rec.last_update_date := to_date(l_token,
                                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
        l_state := 230;
      elsif (l_column = 'LAST_UPDATE_LOGIN') then
         l_criteria_rec.last_update_login := to_number(l_token);
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
      if (l_token = 'CRITERIA') then
        l_value_count := null;
        l_state := 10;
        l_criteria_index := l_criteria_index + 1;
	l_criteria_tbl(l_criteria_index) := l_criteria_rec;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'CRITERIA');
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
  if (l_state <> 0) and (l_more_custom) then
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
  if (l_custom_tbl.count > 0) then
    for l_index in l_custom_tbl.FIRST .. l_custom_tbl.LAST loop
      if (l_custom_tbl.exists(l_index)) then
        if AK_CUSTOM_PVT.CUSTOM_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
	    p_custom_appl_id => l_custom_tbl(l_index).customization_appl_id,
	    p_custom_code => l_custom_tbl(l_index).customization_code,
            p_region_application_id =>	                                                                 l_custom_tbl(l_index).region_appl_id,
	    p_region_code => l_custom_tbl(l_index).region_code) then
          --
          -- Update Regions only if G_UPDATE_MODE is TRUE
          --
          if (AK_UPLOAD_GRP.G_UPDATE_MODE) then
            AK_CUSTOM_PVT.UPDATE_CUSTOM (
              p_validation_level => p_validation_level,
              p_api_version_number => 1.0,
              p_msg_count => l_msg_count,
              p_msg_data => l_msg_data,
              p_return_status => l_return_status,
            p_custom_appl_id => l_custom_tbl(l_index).customization_appl_id,
            p_custom_code => l_custom_tbl(l_index).customization_code,
            p_region_application_id => l_custom_tbl(l_index).region_appl_id,
            p_region_code => l_custom_tbl(l_index).region_code,
 	    p_verticalization_id => l_custom_tbl(l_index).verticalization_id,
	    p_localization_code => l_custom_tbl(l_index).localization_code,
	    p_org_id => l_custom_tbl(l_index).org_id,
	    p_site_id => l_custom_tbl(l_index).site_id,
	    p_responsibility_id => l_custom_tbl(l_index).responsibility_id,
	    p_web_user_id => l_custom_tbl(l_index).web_user_id,
	    p_default_customization_flag => l_custom_tbl(l_index).default_customization_flag,
	    p_customization_level_id => l_custom_tbl(l_index).customization_level_id,
	    p_developer_mode => l_custom_tbl(l_index).developer_mode,
	    p_reference_path => l_custom_tbl(l_index).reference_path,
	    p_function_name => l_custom_tbl(l_index).function_name,
	    p_start_date_Active => l_custom_tbl(l_index).start_date_Active,
	    p_end_date_active => l_custom_tbl(l_index).end_date_active,
	    p_name => l_custom_tbl(l_index).name,
	    p_description => l_custom_Tbl(l_index).description,
 	    p_created_by => l_custom_tbl(l_index).created_by,
	    p_creation_date => l_custom_tbl(l_index).creation_date,
	    p_last_updated_by => l_custom_tbl(l_index).last_updated_by,
	    p_last_update_date => l_custom_tbl(l_index).last_update_date,
	    p_last_update_login => l_custom_tbl(l_index).last_update_login,
              p_loader_timestamp => p_loader_timestamp,
                      p_pass => p_pass,
              p_copy_redo_flag => l_copy_redo_flag
            );
                  elsif (AK_UPLOAD_GRP.G_NO_CUSTOM_UPDATE) then
                        -- do not update customized data
						l_error_key_info := 'CUSTOMIZATION CAPPLID='||to_char(l_custom_tbl(l_index).customization_appl_id)||
						' CCODE='||l_custom_tbl(l_index).customization_code||' RAPPLID='||
						to_char(l_custom_tbl(l_index).region_appl_id)||' RCODE='||
						l_custom_tbl(l_index).region_code;
			select ac.last_updated_by, act.last_updated_by,
			ac.last_update_date, act.last_update_date
			into l_user_id1, l_user_id2, l_update1, l_update2
			from ak_customizations ac, ak_customizations_tl act
			where ac.customization_application_id = l_custom_tbl(l_index).customization_appl_id
			and ac.customization_code = l_custom_tbl(l_index).customization_code
			and ac.region_application_id = l_custom_tbl(l_index).region_appl_id
			and ac.region_code = l_custom_tbl(l_index).region_code
			and ac.customization_application_id = act.customization_application_id
			and ac.customization_code = act.customization_code
			and ac.region_application_id = act.region_application_id
			and ac.region_code = act.region_code
			and act.language = userenv('LANG');
                        /*if (( l_user_id1 = 1 or l_user_id1 = 2) and
				(l_user_id2 = 1 or l_user_id2 = 2)) then*/
                if (AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
                      p_loader_timestamp => p_loader_timestamp,
                      p_created_by => l_custom_tbl(l_index).created_by,
                      p_creation_date => l_custom_tbl(l_index).creation_date,
                      p_last_updated_by => l_custom_tbl(l_index).last_updated_by,
                      p_db_last_updated_by => l_user_id1,
                      p_last_update_date => l_custom_tbl(l_index).last_update_date,
                      p_db_last_update_date => l_update1,
                      p_last_update_login => l_custom_tbl(l_index).last_update_login,
                      p_create_or_update => 'UPDATE') and

                   AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
                      p_loader_timestamp => p_loader_timestamp,
                      p_created_by => l_custom_tbl(l_index).created_by,
                      p_creation_date => l_custom_tbl(l_index).creation_date,
                      p_last_updated_by => l_custom_tbl(l_index).last_updated_by,
                      p_db_last_updated_by => l_user_id2,
                      p_last_update_date => l_custom_tbl(l_index).last_update_date,
                      p_db_last_update_date => l_update2,
                      p_last_update_login => l_custom_tbl(l_index).last_update_login,
                      p_create_or_update => 'UPDATE')) then

                    AK_CUSTOM_PVT.UPDATE_CUSTOM (
                      p_validation_level => p_validation_level,
                      p_api_version_number => 1.0,
                      p_msg_count => l_msg_count,
                      p_msg_data => l_msg_data,
                      p_return_status => l_return_status,
		      p_custom_appl_id => l_custom_tbl(l_index).customization_appl_id,
		      p_custom_code => l_custom_tbl(l_index).customization_code,
		      p_region_application_id => l_custom_tbl(l_index).region_appl_id,
		      p_region_code => l_custom_tbl(l_index).region_code,
		      p_verticalization_id => l_custom_tbl(l_index).verticalization_id,
		      p_localization_code => l_custom_tbl(l_index).localization_code,
		      p_org_id => l_custom_tbl(l_index).org_id,
		      p_site_id => l_custom_tbl(l_index).site_id,
		      p_responsibility_id => l_custom_tbl(l_index).responsibility_id,
	 	      p_web_user_id => l_custom_tbl(l_index).web_user_id,
	 	      p_default_customization_flag => l_custom_tbl(l_index).default_customization_flag,
		      p_customization_level_id => l_custom_tbl(l_index).customization_level_id,
		      p_developer_mode => l_custom_tbl(l_index).developer_mode,
		      p_reference_path => l_custom_tbl(l_index).reference_path,
		      p_function_name => l_custom_tbl(l_index).function_name,
		      p_start_date_active => l_custom_tbl(l_index).start_date_Active,
		      p_end_date_active => l_custom_tbl(l_index).end_date_active,
		      p_name => l_custom_tbl(l_index).name,
		      p_description => l_custom_tbl(l_index).description,
		      p_created_by => l_custom_tbl(l_index).created_by,
		      p_creation_date => l_custom_tbl(l_index).creation_date,
		      p_last_updated_by	=> l_custom_tbl(l_index).last_updated_by,
		      p_last_update_date => l_custom_tbl(l_index).last_update_date,
		      p_last_update_login => l_custom_tbl(l_index).last_update_login,
                      p_loader_timestamp => p_loader_timestamp,
                              p_pass => p_pass,
                      p_copy_redo_flag => l_copy_redo_flag
                    );
                        end if; -- /* if ( l_user_id1 = 1 and l_user_id1 = 1 ) */
          end if; -- /* if G_UPDATE_MODE G_NC_UPDATE_MODE*/
        else
          AK_CUSTOM_PVT.CREATE_CUSTOM (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
	    p_custom_appl_id => l_custom_tbl(l_index).customization_appl_id,
	    p_custom_code => l_custom_tbl(l_index).customization_code,
	    p_region_appl_id => l_custom_tbl(l_index).region_appl_id,
                      p_region_code => l_custom_tbl(l_index).region_code,
	    p_verticalization_id => l_custom_tbl(l_index).verticalization_id,
	    p_localization_code => l_custom_tbl(l_index).localization_code,
                      p_org_id => l_custom_tbl(l_index).org_id,
                      p_site_id => l_custom_tbl(l_index).site_id,
	    p_responsibility_id => l_custom_tbl(l_index).responsibility_id,
                      p_web_user_id => l_custom_tbl(l_index).web_user_id,
	    p_default_customization_flag => l_custom_tbl(l_index).default_customization_flag,
	    p_customization_level_id => l_custom_tbl(l_index).customization_level_id,
	    p_developer_mode => l_custom_tbl(l_index).developer_mode,
	    p_reference_path => l_custom_tbl(l_index).reference_path,
	    p_function_name => l_custom_tbl(l_index).function_name,
	    p_start_date_active => l_custom_tbl(l_index).start_date_active,
	    p_end_date_active => l_custom_tbl(l_index).end_date_active,
                      p_name => l_custom_tbl(l_index).name,
                      p_description => l_custom_tbl(l_index).description,
		p_created_by => l_custom_tbl(l_index).created_by,
		p_creation_date => l_custom_tbl(l_index).creation_date,
		p_last_updated_by => l_custom_tbl(l_index).last_updated_by,
		p_last_update_date => l_custom_tbl(l_index).last_update_date,
		p_last_update_login => l_custom_tbl(l_index).last_update_login,
                      p_loader_timestamp => p_loader_timestamp,
                              p_pass => p_pass,
                      p_copy_redo_flag => l_copy_redo_flag
                    );
        end if; -- /* if CUSTOM_EXISTS */
        --
        -- If API call returns with an error status, upload aborts
        if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
        (l_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        end if; -- /* if l_return_status */
                --
                -- if validation fails, then this record should go to second pass
                if (l_copy_redo_flag) then
                  G_CUSTOM_REDO_INDEX := G_CUSTOM_REDO_INDEX + 1;
                  G_CUSTOM_REDO_TBL(G_CUSTOM_REDO_INDEX) := l_custom_tbl(l_index);
                  l_copy_redo_flag := FALSE;
                end if; --/* if l_copy_redo_flag */
      end if;
    end loop;
  end if;

  --
  -- create or update all custom_regions to the database
  --
  if (l_cust_region_tbl.count > 0) then
    for l_index in l_cust_region_tbl.FIRST .. l_cust_region_tbl.LAST loop
      if (l_cust_region_tbl.exists(l_index)) then
        if AK_CUSTOM_PVT.CUST_REGION_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_custom_appl_id => l_cust_region_tbl(l_index).customization_appl_id,
            p_custom_code => l_cust_region_tbl(l_index).customization_code,
            p_region_application_id =>
                         l_cust_region_tbl(l_index).region_appl_id,
            p_region_code => l_cust_region_tbl(l_index).region_code,
	    p_property_name => l_cust_region_tbl(l_index).property_name) then
          --
          -- Update Regions only if G_UPDATE_MODE is TRUE
          --
          if (AK_UPLOAD_GRP.G_UPDATE_MODE) then
            AK_CUSTOM_PVT.UPDATE_CUST_REGION (
              p_validation_level => p_validation_level,
              p_api_version_number => 1.0,
              p_msg_count => l_msg_count,
              p_msg_data => l_msg_data,
              p_return_status => l_return_status,
            p_custom_appl_id => l_cust_region_tbl(l_index).customization_appl_id,
            p_custom_code => l_cust_region_tbl(l_index).customization_code,
            p_region_application_id => l_cust_region_tbl(l_index).region_appl_id,
            p_region_code => l_cust_region_tbl(l_index).region_code,
	    p_property_name => l_cust_region_tbl(l_index).property_name,
	    p_property_varchar2_value => l_cust_region_tbl(l_index).property_varchar2_value,
	    p_property_number_value => l_cust_region_tbl(l_index).property_number_value,
	    p_criteria_join_condition => l_cust_region_tbl(l_index).criteria_join_condition,
	    p_property_varchar2_value_tl => l_cust_region_tbl(l_index).property_varchar2_value_tl,
	    p_created_by => l_cust_region_tbl(l_index).created_by,
	    p_creation_date => l_cust_region_tbl(l_index).creation_date,
	    p_last_updated_by => l_cust_region_tbl(l_index).last_updated_by,
	    p_last_update_date => l_cust_region_tbl(l_index).last_update_date,
	    p_last_update_login => l_cust_region_tbl(l_index).last_update_login,
              p_loader_timestamp => p_loader_timestamp,
                      p_pass => p_pass,
              p_copy_redo_flag => l_copy_redo_flag
            );
                  elsif (AK_UPLOAD_GRP.G_NO_CUSTOM_UPDATE) then
                        -- do not update customized data
						l_error_key_info := 'CUST REG CAPPLID='||to_char(l_cust_region_tbl(l_index).customization_appl_id)||
						' CCODE='||l_cust_region_tbl(l_index).customization_code||' RAPPLID='||
						to_char(l_cust_region_tbl(l_index).region_appl_id)||' RCODE='||
						l_cust_region_tbl(l_index).region_code||' PNAME='||
						l_cust_region_tbl(l_index).property_name;

                        select ac.last_updated_by, act.last_updated_by,
			ac.last_update_date, act.last_update_date
			into l_user_id1, l_user_id2, l_update1, l_update2
                        from ak_custom_regions ac, ak_custom_regions_tl act
                        where ac.customization_application_id = l_cust_region_tbl(l_index).customization_appl_id
			and ac.customization_code = l_cust_region_tbl(l_index).customization_code
			and ac.region_application_id = l_cust_region_tbl(l_index).region_appl_id
			and ac.region_code = l_cust_region_tbl(l_index).region_code
			and ac.property_name = l_cust_region_tbl(l_index).property_name
			and ac.customization_application_id = act.customization_application_id
                        and ac.customization_code = act.customization_code
                        and ac.region_application_id = act.region_application_id
                        and ac.region_code = act.region_code
						and ac.property_name = act.property_name
                        and act.language = userenv('LANG');
                        /*if (( l_user_id1 = 1 or l_user_id1 = 2)
				and (l_user_id2 = 1 or l_user_id2 = 2)) then*/
                if (AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
                      p_loader_timestamp => p_loader_timestamp,
                      p_created_by => l_cust_region_tbl(l_index).created_by,
                      p_creation_date => l_cust_region_tbl(l_index).creation_date,
                      p_last_updated_by => l_cust_region_tbl(l_index).last_updated_by,
                      p_db_last_updated_by => l_user_id1,
                      p_last_update_date => l_cust_region_tbl(l_index).last_update_date,
                      p_db_last_update_date => l_update1,
                      p_last_update_login => l_cust_region_tbl(l_index).last_update_login,
                      p_create_or_update => 'UPDATE') and

                   AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
                      p_loader_timestamp => p_loader_timestamp,
                      p_created_by => l_cust_region_tbl(l_index).created_by,
                      p_creation_date => l_cust_region_tbl(l_index).creation_date,
                      p_last_updated_by => l_cust_region_tbl(l_index).last_updated_by,
                      p_db_last_updated_by => l_user_id2,
                      p_last_update_date => l_cust_region_tbl(l_index).last_update_date,
                      p_db_last_update_date => l_update2,
                      p_last_update_login => l_cust_region_tbl(l_index).last_update_login,
                      p_create_or_update => 'UPDATE')) then

                    AK_CUSTOM_PVT.UPDATE_CUST_REGION (
                      p_validation_level => p_validation_level,
                      p_api_version_number => 1.0,
                      p_msg_count => l_msg_count,
                      p_msg_data => l_msg_data,
                      p_return_status => l_return_status,
                      p_custom_appl_id => l_cust_region_tbl(l_index).customization_appl_id,
		      p_custom_code => l_cust_region_tbl(l_index).customization_code,
		      p_region_application_id => l_cust_region_tbl(l_index).region_appl_id,
                      p_region_code => l_cust_region_tbl(l_index).region_code,
		      p_property_name => l_cust_region_tbl(l_index).property_name,
		      p_property_varchar2_value => l_cust_region_tbl(l_index).property_varchar2_value,
		      p_property_number_value => l_cust_region_tbl(l_index).property_number_value,
		      p_criteria_join_condition => l_cust_region_tbl(l_index).criteria_join_condition,
		      p_property_varchar2_value_tl => l_cust_region_tbl(l_index).property_varchar2_value_tl,
		      p_created_by => l_cust_region_tbl(l_index).created_by,
		      p_creation_date => l_cust_region_tbl(l_index).creation_date,
		      p_last_updated_by => l_cust_region_tbl(l_index).last_updated_by,
		      p_last_update_date => l_cust_region_tbl(l_index).last_update_date,
		      p_last_update_login => l_cust_region_tbl(l_index).last_update_login,
		                            p_loader_timestamp => p_loader_timestamp,
                              p_pass => p_pass,
                      p_copy_redo_flag => l_copy_redo_flag
                    );
                        end if; -- /* if ( l_user_id1 = 1 and l_user_id2 = 1 ) */
          end if; -- /* if G_UPDATE_MODE G_NC_UPDATE_MODE*/
        else
          AK_CUSTOM_PVT.CREATE_CUST_REGION (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
            p_custom_appl_id => l_cust_region_tbl(l_index).customization_appl_id,
            p_custom_code => l_cust_region_tbl(l_index).customization_code,
            p_region_appl_id => l_cust_region_tbl(l_index).region_appl_id,
            p_region_code => l_cust_region_tbl(l_index).region_code,
            p_property_name => l_cust_region_tbl(l_index).property_name,
            p_property_varchar2_value => l_cust_region_tbl(l_index).property_varchar2_value,
            p_property_number_value => l_cust_region_tbl(l_index).property_number_value,
            p_criteria_join_condition => l_cust_region_tbl(l_index).criteria_join_condition,
            p_property_varchar2_value_tl => l_cust_region_tbl(l_index).property_varchar2_value_tl,
	 	p_created_by => l_cust_region_tbl(l_index).created_by,
		p_creation_date => l_cust_region_tbl(l_index).creation_date,
		p_last_updated_by => l_cust_region_tbl(l_index).last_updated_by,
		p_last_update_date => l_cust_region_tbl(l_index).last_update_date,
		p_last_update_login => l_cust_region_tbl(l_index).last_update_login,
            p_loader_timestamp => p_loader_timestamp,
            p_pass => p_pass,
            p_copy_redo_flag => l_copy_redo_flag
                    );
        end if; -- /* if CUST_REGION_EXISTS */
        --
        -- If API call returns with an error status, upload aborts
        if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
        (l_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        end if; -- /* if l_return_status */
                --
                -- if validation fails, then this record should go to second pas
                if (l_copy_redo_flag) then
                  G_CUST_REGION_REDO_INDEX := G_CUST_REGION_REDO_INDEX + 1;
                  G_CUST_REGION_REDO_TBL(G_CUST_REGION_REDO_INDEX) := l_cust_region_tbl(l_index);
                  l_copy_redo_flag := FALSE;
                end if; --/* if l_copy_redo_flag */
      end if;
    end loop;
  end if;

  --
  -- create or update all custom_region_items to the database
  --
  if (l_cust_reg_item_tbl.count > 0) then
    for l_index in l_cust_reg_item_tbl.FIRST .. l_cust_reg_item_tbl.LAST loop
      if (l_cust_reg_item_tbl.exists(l_index)) then
        if AK_CUSTOM_PVT.CUST_REG_ITEM_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_custom_appl_id => l_cust_reg_item_tbl(l_index).customization_appl_id,
            p_custom_code => l_cust_reg_item_tbl(l_index).customization_code,
            p_region_application_id => l_cust_reg_item_tbl(l_index).region_appl_id,
            p_region_code => l_cust_reg_item_tbl(l_index).region_code,
	    p_attribute_appl_id => l_cust_reg_item_tbl(l_index).attr_appl_id,
	    p_attribute_code => l_cust_reg_item_tbl(l_index).attr_code,
            p_property_name => l_cust_reg_item_tbl(l_index).property_name) then
          --
          -- Update Regions only if G_UPDATE_MODE is TRUE
          --
          if (AK_UPLOAD_GRP.G_UPDATE_MODE) then
            AK_CUSTOM_PVT.UPDATE_CUST_REG_ITEM (
              p_validation_level => p_validation_level,
              p_api_version_number => 1.0,
              p_msg_count => l_msg_count,
              p_msg_data => l_msg_data,
              p_return_status => l_return_status,
            p_custom_appl_id => l_cust_reg_item_tbl(l_index).customization_appl_id,
            p_custom_code => l_cust_reg_item_tbl(l_index).customization_code,
            p_region_application_id => l_cust_reg_item_tbl(l_index).region_appl_id,
            p_region_code => l_cust_reg_item_tbl(l_index).region_code,
	    p_attribute_appl_id => l_cust_reg_item_tbl(l_index).attr_appl_id,
	    p_attribute_code => l_cust_reg_item_tbl(l_index).attr_code,
            p_property_name => l_cust_reg_item_tbl(l_index).property_name,
            p_property_varchar2_value => l_cust_reg_item_tbl(l_index).property_varchar2_value,
            p_property_number_value => l_cust_reg_item_tbl(l_index).property_number_value,
            p_property_date_value => l_cust_reg_item_tbl(l_index).property_date_value,
            p_property_varchar2_value_tl => l_cust_reg_item_tbl(l_index).property_varchar2_value_tl,
	    p_created_by => l_cust_reg_item_tbl(l_index).created_by,
	    p_creation_date => l_cust_reg_item_tbl(l_index).creation_date,
	    p_last_updated_by => l_cust_reg_item_tbl(l_index).last_updated_by,
	    p_last_update_date => l_cust_reg_item_tbl(l_index).last_update_date,
	    p_last_update_login => l_cust_reg_item_tbl(l_index).last_update_login,
              p_loader_timestamp => p_loader_timestamp,
                      p_pass => p_pass,
              p_copy_redo_flag => l_copy_redo_flag
            );
                  elsif (AK_UPLOAD_GRP.G_NO_CUSTOM_UPDATE) then
						l_error_key_info := 'CUST REG ITEM CAPPLID='||to_char(l_cust_reg_item_tbl(l_index).customization_appl_id)||
						' CCODE='||l_cust_reg_item_tbl(l_index).customization_code||' RAPPLID='||
						to_char(l_cust_reg_item_tbl(l_index).region_appl_id)||' RCODE='||
						l_cust_reg_item_tbl(l_index).region_code||' AAPPLID='||
						to_char(l_cust_reg_item_tbl(l_index).attr_appl_id)||' ACODE='||
						l_cust_reg_item_tbl(l_index).attr_code||' PNAME='||
						l_cust_reg_item_tbl(l_index).property_name;

                        -- do not update customized data
                        select ac.last_updated_by, act.last_updated_by,
			ac.last_update_date, act.last_update_date
			into l_user_id1, l_user_id2, l_update1, l_update2
                        from ak_custom_region_items ac, ak_custom_region_items_tl act
                        where ac.customization_application_id = l_cust_reg_item_tbl(l_index).customization_appl_id
                        and ac.customization_code = l_cust_reg_item_tbl(l_index).customization_code
                        and ac.region_application_id = l_cust_reg_item_tbl(l_index).region_appl_id
                        and ac.region_code = l_cust_reg_item_tbl(l_index).region_code
                        and ac.property_name = l_cust_reg_item_tbl(l_index).property_name
			and ac.attribute_application_id = l_cust_reg_item_tbl(l_index).attr_appl_id
			and ac.attribute_code = l_cust_reg_item_tbl(l_index).attr_code
                        and ac.customization_application_id = act.customization_application_id
                        and ac.customization_code = act.customization_code
                        and ac.region_application_id = act.region_application_id
                        and ac.region_code = act.region_code
			and ac.property_name = act.property_name
			and ac.attribute_application_id = act.attribute_application_id
			and ac.attribute_code = act.attribute_code
                        and act.language = userenv('LANG');
                        /*if (( l_user_id1 = 1 or l_user_id1 = 2) and
				(l_user_id2 = 1 or l_user_id2 = 2 )) then*/
                if (AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
                      p_loader_timestamp => p_loader_timestamp,
                      p_created_by => l_cust_reg_item_tbl(l_index).created_by,
                      p_creation_date => l_cust_reg_item_tbl(l_index).creation_date,
                      p_last_updated_by => l_cust_reg_item_tbl(l_index).last_updated_by,
                      p_db_last_updated_by => l_user_id1,
                      p_last_update_date => l_cust_reg_item_tbl(l_index).last_update_date,
                      p_db_last_update_date => l_update1,
                      p_last_update_login => l_cust_reg_item_tbl(l_index).last_update_login,
                      p_create_or_update => 'UPDATE') and

                   AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
                      p_loader_timestamp => p_loader_timestamp,
                      p_created_by => l_cust_reg_item_tbl(l_index).created_by,
                      p_creation_date => l_cust_reg_item_tbl(l_index).creation_date,
                      p_last_updated_by => l_cust_reg_item_tbl(l_index).last_updated_by,
                      p_db_last_updated_by => l_user_id2,
                      p_last_update_date => l_cust_reg_item_tbl(l_index).last_update_date,
                      p_db_last_update_date => l_update2,
                      p_last_update_login => l_cust_reg_item_tbl(l_index).last_update_login,
                      p_create_or_update => 'UPDATE')) then

                    AK_CUSTOM_PVT.UPDATE_CUST_REG_ITEM (
                      p_validation_level => p_validation_level,
                      p_api_version_number => 1.0,
                      p_msg_count => l_msg_count,
                      p_msg_data => l_msg_data,
                      p_return_status => l_return_status,
                      p_custom_appl_id => l_cust_reg_item_tbl(l_index).customization_appl_id,
                      p_custom_code => l_cust_reg_item_tbl(l_index).customization_code,
                      p_region_application_id => l_cust_reg_item_tbl(l_index).region_appl_id,
                      p_region_code => l_cust_reg_item_tbl(l_index).region_code,
		      p_attribute_appl_id => l_cust_reg_item_tbl(l_index).attr_appl_id,
		      p_attribute_code => l_cust_reg_item_tbl(l_index).attr_code,
                      p_property_name => l_cust_reg_item_tbl(l_index).property_name,
                      p_property_varchar2_value => l_cust_reg_item_tbl(l_index).property_varchar2_value,
                      p_property_number_value => l_cust_reg_item_tbl(l_index).property_number_value,
		      p_property_date_value => l_cust_reg_item_tbl(l_index).property_date_value,
                      p_property_varchar2_value_tl => l_cust_reg_item_tbl(l_index).property_varchar2_value_tl,
		      p_created_by => l_cust_reg_item_tbl(l_index).created_by,
		      p_creation_date => l_cust_reg_item_tbl(l_index).creation_date,
		      p_last_updated_by => l_cust_reg_item_tbl(l_index).last_updated_by,
		      p_last_update_date => l_cust_reg_item_tbl(l_index).last_update_date,
	  	      p_last_update_login => l_cust_reg_item_tbl(l_index).last_update_login,
                      p_loader_timestamp => p_loader_timestamp,
                              p_pass => p_pass,
                      p_copy_redo_flag => l_copy_redo_flag
                    );
                        end if; -- /* if ( l_user_id1 = 1 and l_user_id2 = 1 ) */
          end if; -- /* if G_UPDATE_MODE G_NC_UPDATE_MODE*/
        else
          AK_CUSTOM_PVT.CREATE_CUST_REG_ITEM (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
            p_custom_appl_id => l_cust_reg_item_tbl(l_index).customization_appl_id,
            p_custom_code => l_cust_reg_item_tbl(l_index).customization_code,
            p_region_appl_id => l_cust_reg_item_tbl(l_index).region_appl_id,
            p_region_code => l_cust_reg_item_tbl(l_index).region_code,
	    p_attr_appl_id => l_cust_reg_item_tbl(l_index).attr_appl_id,
	    p_attr_code => l_cust_reg_item_tbl(l_index).attr_code,
            p_property_name => l_cust_reg_item_tbl(l_index).property_name,
            p_property_varchar2_value => l_cust_reg_item_tbl(l_index).property_varchar2_value,
            p_property_number_value => l_cust_reg_item_tbl(l_index).property_number_value,
            p_property_date_value => l_cust_reg_item_tbl(l_index).property_date_value,
            p_property_varchar2_value_tl => l_cust_reg_item_tbl(l_index).property_varchar2_value_tl,
	p_created_by => l_cust_reg_item_tbl(l_index).created_by,
	p_creation_date => l_cust_reg_item_tbl(l_index).creation_date,
	p_last_updated_by => l_cust_reg_item_tbl(l_index).last_updated_by,
	p_last_update_date => l_cust_reg_item_tbl(l_index).last_update_date,
	p_last_update_login => l_cust_reg_item_tbl(l_index).last_update_login,
            p_loader_timestamp => p_loader_timestamp,
            p_pass => p_pass,
            p_copy_redo_flag => l_copy_redo_flag
                    );
        end if; -- /* if CUST_REGION_EXISTS */
        --
        -- If API call returns with an error status, upload aborts
        if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
        (l_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        end if; -- /* if l_return_status */
                --
                -- if validation fails, then this record should go to second pas
                if (l_copy_redo_flag) then
                  G_CUST_REG_ITEM_REDO_INDEX := G_CUST_REG_ITEM_REDO_INDEX + 1;
                  G_CUST_REG_ITEM_REDO_TBL(G_CUST_REG_ITEM_REDO_INDEX) := l_cust_reg_item_tbl(l_index);
                  l_copy_redo_flag := FALSE;
                end if; --/* if l_copy_redo_flag */
      end if;
    end loop;
  end if;

  --
  -- create or update all custom_criteria to the database
  --
  if (l_criteria_tbl.count > 0) then
    for l_index in l_criteria_tbl.FIRST .. l_criteria_tbl.LAST loop
      if (l_criteria_tbl.exists(l_index)) then
        if AK_CUSTOM_PVT.CRITERIA_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_custom_appl_id => l_criteria_tbl(l_index).customization_application_id,
            p_custom_code => l_criteria_tbl(l_index).customization_code,
            p_region_application_id => l_criteria_tbl(l_index).region_application_id,
            p_region_code => l_criteria_tbl(l_index).region_code,
            p_attribute_appl_id => l_criteria_tbl(l_index).attribute_application_id,
            p_attribute_code => l_criteria_tbl(l_index).attribute_code,
            p_sequence_number => l_criteria_tbl(l_index).sequence_number) then
          --
          -- Update Regions only if G_UPDATE_MODE is TRUE
          --
          if (AK_UPLOAD_GRP.G_UPDATE_MODE) then
            AK_CUSTOM_PVT.UPDATE_CRITERIA (
              p_validation_level => p_validation_level,
              p_api_version_number => 1.0,
              p_msg_count => l_msg_count,
              p_msg_data => l_msg_data,
              p_return_status => l_return_status,
            p_custom_appl_id => l_criteria_tbl(l_index).customization_application_id,
            p_custom_code => l_criteria_tbl(l_index).customization_code,
            p_region_application_id => l_criteria_tbl(l_index).region_application_id,
            p_region_code => l_criteria_tbl(l_index).region_code,
            p_attribute_appl_id => l_criteria_tbl(l_index).attribute_application_id,
            p_attribute_code => l_criteria_tbl(l_index).attribute_code,
            p_sequence_number => l_criteria_tbl(l_index).sequence_number,
	    p_operation => l_criteria_tbl(l_index).operation,
            p_value_varchar2 => l_criteria_tbl(l_index).value_varchar2,
            p_value_number => l_criteria_tbl(l_index).value_number,
            p_value_date => l_criteria_tbl(l_index).value_date,
	    p_start_date_active => l_criteria_tbl(l_index).start_date_active,
	    p_end_date_active => l_criteria_tbl(l_index).end_date_active,
	    p_created_by => l_criteria_tbl(l_index).created_by,
	    p_creation_date => l_criteria_tbl(l_index).creation_date,
	    p_last_updated_by => l_criteria_tbl(l_index).last_updated_by,
	    p_last_update_date => l_criteria_tbl(l_index).last_update_date,
	    p_last_update_login => l_criteria_tbl(l_index).last_update_login,
                          p_loader_timestamp => p_loader_timestamp,
                      p_pass => p_pass,
              p_copy_redo_flag => l_copy_redo_flag
            );
                  elsif (AK_UPLOAD_GRP.G_NO_CUSTOM_UPDATE) then
						l_error_key_info := 'CRITERIA CAPPLID='||to_char(l_criteria_tbl(l_index).customization_application_id)||
						' CCODE='||l_criteria_tbl(l_index).customization_code||' RAPPLID='||
						to_char(l_criteria_tbl(l_index).region_application_id)||' RCODE='||
						l_criteria_tbl(l_index).region_code||' AAPPLID='||
						to_char(l_criteria_tbl(l_index).attribute_application_id)||' ACODE='||
						l_criteria_tbl(l_index).attribute_code;

                        -- do not update customized data
                        select last_updated_by, last_update_date into
                        l_user_id1, l_update1
                        from ak_criteria ac
                        where ac.customization_application_id = l_criteria_tbl(l_index).customization_application_id
                        and ac.customization_code = l_criteria_tbl(l_index).customization_code
                        and ac.region_application_id = l_criteria_tbl(l_index).region_application_id
                        and ac.region_code = l_criteria_tbl(l_index).region_code
                        and ac.sequence_number = l_criteria_tbl(l_index).sequence_number
                        and ac.attribute_application_id = l_criteria_tbl(l_index).attribute_application_id
                        and ac.attribute_code = l_criteria_tbl(l_index).attribute_code;
                        /*if ( l_user_id1 = 1 or l_user_id1 = 2 ) then*/
                if AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
                      p_loader_timestamp => p_loader_timestamp,
                      p_created_by => l_criteria_tbl(l_index).created_by,
                      p_creation_date => l_criteria_tbl(l_index).creation_date,
                      p_last_updated_by => l_criteria_tbl(l_index).last_updated_by,
                      p_db_last_updated_by => l_user_id1,
                      p_last_update_date => l_criteria_tbl(l_index).last_update_date,
                      p_db_last_update_date => l_update1,
                      p_last_update_login => l_criteria_tbl(l_index).last_update_login,
                      p_create_or_update => 'UPDATE') then

                    AK_CUSTOM_PVT.UPDATE_CRITERIA (
                      p_validation_level => p_validation_level,
                      p_api_version_number => 1.0,
                      p_msg_count => l_msg_count,
                      p_msg_data => l_msg_data,
                      p_return_status => l_return_status,
                      p_custom_appl_id => l_criteria_tbl(l_index).customization_application_id,
                      p_custom_code => l_criteria_tbl(l_index).customization_code,
                      p_region_application_id => l_criteria_tbl(l_index).region_application_id,
                      p_region_code => l_criteria_tbl(l_index).region_code,
                      p_attribute_appl_id => l_criteria_tbl(l_index).attribute_application_id,
                      p_attribute_code => l_criteria_tbl(l_index).attribute_code,
                      p_sequence_number => l_criteria_tbl(l_index).sequence_number,
		      p_operation => l_criteria_tbl(l_index).operation,
                      p_value_varchar2 => l_criteria_tbl(l_index).value_varchar2,
                      p_value_number => l_criteria_tbl(l_index).value_number,
                      p_value_date => l_criteria_tbl(l_index).value_date,
	 	      p_start_date_active  => l_criteria_tbl(l_index).start_date_active,
		      p_end_date_active => l_criteria_tbl(l_index).end_date_active,
		      p_created_by => l_criteria_tbl(l_index).created_by,
		      p_creation_date => l_criteria_tbl(l_index).creation_date,
		      p_last_updated_by => l_criteria_tbl(l_index).last_updated_by,
		      p_last_update_date => l_criteria_tbl(l_index).last_update_date,
		      p_last_update_login => l_criteria_tbl(l_index).last_update_login,
                      p_loader_timestamp => p_loader_timestamp,
                              p_pass => p_pass,
                      p_copy_redo_flag => l_copy_redo_flag
                    );
                        end if; -- /* if ( l_user_id1 = 1 and l_user_id2 = 1 ) */
          end if; -- /* if G_UPDATE_MODE G_NC_UPDATE_MODE*/
        else
          AK_CUSTOM_PVT.CREATE_CRITERIA (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
            p_custom_appl_id => l_criteria_tbl(l_index).customization_application_id,
            p_custom_code => l_criteria_tbl(l_index).customization_code,
            p_region_appl_id => l_criteria_tbl(l_index).region_application_id,
            p_region_code => l_criteria_tbl(l_index).region_code,
            p_attr_appl_id => l_criteria_tbl(l_index).attribute_application_id,
            p_attr_code => l_criteria_tbl(l_index).attribute_code,
            p_sequence_number => l_criteria_tbl(l_index).sequence_number,
	    p_operation => l_criteria_tbl(l_index).operation,
            p_value_varchar2 => l_criteria_tbl(l_index).value_varchar2,
            p_value_number => l_criteria_tbl(l_index).value_number,
            p_value_date => l_criteria_tbl(l_index).value_date,
	    p_start_date_active => l_criteria_tbl(l_index).start_date_active,
	    p_end_date_active => l_criteria_tbl(l_index).end_date_active,
	p_created_by => l_criteria_tbl(l_index).created_by,
	p_creation_date => l_criteria_tbl(l_index).creation_date,
	p_last_updated_by => l_criteria_tbl(l_index).last_updated_by,
	p_last_update_date => l_criteria_tbl(l_index).last_update_date,
	p_last_update_login => l_criteria_tbl(l_index).last_update_login,
            p_loader_timestamp => p_loader_timestamp,
            p_pass => p_pass,
            p_copy_redo_flag => l_copy_redo_flag
                    );
        end if; -- /* if CUST_REGION_EXISTS */
        --
        -- If API call returns with an error status, upload aborts
        if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
        (l_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        end if; -- /* if l_return_status */
                --
                -- if validation fails, then this record should go to second pas
                if (l_copy_redo_flag) then
                  G_CRITERIA_REDO_INDEX := G_CRITERIA_REDO_INDEX + 1;
                  G_CRITERIA_REDO_TBL(G_CRITERIA_REDO_INDEX) := l_criteria_tbl(l_index);
                  l_copy_redo_flag := FALSE;
                end if; --/* if l_copy_redo_flag */
      end if;
    end loop;
  end if;

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
    rollback to Start_Upload;
  WHEN VALUE_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('AK','AK_CUSTOM_VALUE_ERROR');
    FND_MESSAGE.SET_TOKEN('KEY',to_char(l_custom_rec.region_appl_id)||' '||
                                                l_custom_rec.region_code);
    FND_MSG_PUB.Add;
        FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240)||': '||l_column||'='||l_token );
        FND_MSG_PUB.Add;
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    rollback to Start_Upload;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;
    FND_MESSAGE.SET_NAME('AK','AK_CUSTOM_VALUE_ERROR');
    FND_MESSAGE.SET_TOKEN('KEY', l_error_key_info);
    FND_MSG_PUB.Add;
end UPLOAD_CUSTOM;

--=======================================================
--  Procedure   UPLOAD_CUSTOM_SECOND
--
--  Usage       Private API for loading customizations that were
--              failed during its first pass
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API reads the custom data from PL/SQL table
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
procedure UPLOAD_CUSTOM_SECOND (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
  p_pass                     IN      NUMBER := 2
) is
  l_api_name                 CONSTANT varchar2(30) := 'Upload_Custom_Second';
  l_rec_index                NUMBER;
  l_return_status            VARCHAR2(1);
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(240);
  l_copy_redo_flag           BOOLEAN;
  l_user_id1                             NUMBER;
  l_user_id2                             NUMBER;
  l_update1				 DATE;
  l_update2				 DATE;
begin
  --
  -- create or update all customizations to the database
  --
  if (G_CUSTOM_REDO_INDEX > 0) then
    for l_index in G_CUSTOM_REDO_TBL.FIRST .. G_CUSTOM_REDO_TBL.LAST loop
      if (G_CUSTOM_REDO_TBL.exists(l_index)) then
        if AK_CUSTOM_PVT.CUSTOM_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_custom_appl_id => G_CUSTOM_REDO_TBL(l_index).customization_appl_id,
            p_custom_code => G_CUSTOM_REDO_TBL(l_index).customization_code,
            p_region_application_id =>
                         G_CUSTOM_REDO_TBL(l_index).region_appl_id,
            p_region_code => G_CUSTOM_REDO_TBL(l_index).region_code) then
            AK_CUSTOM_PVT.UPDATE_CUSTOM (
              p_validation_level => p_validation_level,
              p_api_version_number => 1.0,
              p_msg_count => l_msg_count,
              p_msg_data => l_msg_data,
              p_return_status => l_return_status,
            p_custom_appl_id => G_CUSTOM_REDO_TBL(l_index).customization_appl_id,
            p_custom_code => G_CUSTOM_REDO_TBL(l_index).customization_code,
            p_region_application_id => G_CUSTOM_REDO_TBL(l_index).region_appl_id,
            p_region_code => G_CUSTOM_REDO_TBL(l_index).region_code,
            p_verticalization_id => G_CUSTOM_REDO_TBL(l_index).verticalization_id,
            p_localization_code => G_CUSTOM_REDO_TBL(l_index).localization_code,
            p_org_id => G_CUSTOM_REDO_TBL(l_index).org_id,
            p_site_id => G_CUSTOM_REDO_TBL(l_index).site_id,
            p_responsibility_id => G_CUSTOM_REDO_TBL(l_index).responsibility_id,
            p_web_user_id => G_CUSTOM_REDO_TBL(l_index).web_user_id,
            p_default_customization_flag => G_CUSTOM_REDO_TBL(l_index).default_customization_flag,
            p_customization_level_id => G_CUSTOM_REDO_TBL(l_index).customization_level_id,
	    p_developer_mode => G_CUSTOM_REDO_TBL(l_index).developer_mode,
            p_reference_path => G_CUSTOM_REDO_TBL(l_index).reference_path,
	    p_function_name => G_CUSTOM_REDO_TBL(l_index).function_name,
	    p_start_date_active => G_CUSTOM_REDO_TBL(l_index).start_date_active,
	    p_end_date_active => G_CUSTOM_REDO_TBL(l_index).end_date_active,
            p_name => G_CUSTOM_REDO_TBL(l_index).name,
            p_description => G_CUSTOM_REDO_TBL(l_index).description,
	    p_created_by => G_CUSTOM_REDO_TBL(l_index).created_by,
	    p_creation_date => G_CUSTOM_REDO_TBL(l_index).creation_date,
	    p_last_updated_by => G_CUSTOM_REDO_TBL(l_index).last_updated_by,
	    p_last_update_date => G_CUSTOM_REDO_TBL(l_index).last_update_date,
	    p_last_update_login => G_CUSTOM_REDO_TBL(l_index).last_update_login,
              p_loader_timestamp => p_loader_timestamp,
                      p_pass => p_pass,
              p_copy_redo_flag => l_copy_redo_flag
            );
        else
          AK_CUSTOM_PVT.CREATE_CUSTOM (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
            p_custom_appl_id => G_CUSTOM_REDO_TBL(l_index).customization_appl_id,
            p_custom_code => G_CUSTOM_REDO_TBL(l_index).customization_code,
            p_region_appl_id => G_CUSTOM_REDO_TBL(l_index).region_appl_id,
                      p_region_code => G_CUSTOM_REDO_TBL(l_index).region_code,
            p_verticalization_id => G_CUSTOM_REDO_TBL(l_index).verticalization_id,
            p_localization_code => G_CUSTOM_REDO_TBL(l_index).localization_code,
                      p_org_id => G_CUSTOM_REDO_TBL(l_index).org_id,
                      p_site_id => G_CUSTOM_REDO_TBL(l_index).site_id,
            p_responsibility_id => G_CUSTOM_REDO_TBL(l_index).responsibility_id,
                      p_web_user_id => G_CUSTOM_REDO_TBL(l_index).web_user_id,
            p_default_customization_flag => G_CUSTOM_REDO_TBL(l_index).default_customization_flag,
            p_customization_level_id => G_CUSTOM_REDO_TBL(l_index).customization_level_id,
	    p_developer_mode => G_CUSTOM_REDO_TBL(l_index).developer_mode,
            p_reference_path => G_CUSTOM_REDO_TBL(l_index).reference_path,
	    p_function_name => G_CUSTOM_REDO_TBL(l_index).function_name,
	    p_start_date_active => G_CUSTOM_REDO_TBL(l_index).start_date_active,
	    p_end_date_active => G_CUSTOM_REDO_TBL(l_index).end_date_active,
                      p_name => G_CUSTOM_REDO_TBL(l_index).name,
                      p_description => G_CUSTOM_REDO_TBL(l_index).description,
	p_created_by => G_CUSTOM_REDO_TBL(l_index).created_by,
	p_creation_date => G_CUSTOM_REDO_TBL(l_index).creation_date,
	p_last_updated_by => G_CUSTOM_REDO_TBL(l_index).lasT_updated_by,
	p_last_update_date => G_CUSTOM_REDO_TBL(l_index).last_update_date,
	p_last_update_login => G_CUSTOM_REDO_TBL(l_index).last_update_login,
                      p_loader_timestamp => p_loader_timestamp,
                              p_pass => p_pass,
                      p_copy_redo_flag => l_copy_redo_flag
                    );
        end if; -- /* if CUSTOM_EXISTS */
        --
        -- If API call returns with an error status, upload aborts
        if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
        (l_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        end if; -- /* if l_return_status */
      end if; -- /* if G_CUSTOM_REDO_TBL.exists(l_index) */
    end loop;
  end if; -- /* if G_CUSTOM_REDO_INDEX > 0 */

  --
  -- create or update all custom_regions to the database
  --
  if (G_CUST_REGION_REDO_INDEX > 0) then
    for l_index in G_CUST_REGION_REDO_TBL.FIRST .. G_CUST_REGION_REDO_TBL.LAST loop
      if (G_CUST_REGION_REDO_TBL.exists(l_index)) then
        if AK_CUSTOM_PVT.CUST_REGION_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_custom_appl_id => G_CUST_REGION_REDO_TBL(l_index).customization_appl_id,
            p_custom_code => G_CUST_REGION_REDO_TBL(l_index).customization_code,
            p_region_application_id =>
                         G_CUST_REGION_REDO_TBL(l_index).region_appl_id,
            p_region_code => G_CUST_REGION_REDO_TBL(l_index).region_code,
            p_property_name => G_CUST_REGION_REDO_TBL(l_index).property_name) then
          --
          -- Update Custom Regions only if G_UPDATE_MODE is TRUE
          --
          if (AK_UPLOAD_GRP.G_UPDATE_MODE) then
            AK_CUSTOM_PVT.UPDATE_CUST_REGION (
              p_validation_level => p_validation_level,
              p_api_version_number => 1.0,
              p_msg_count => l_msg_count,
              p_msg_data => l_msg_data,
              p_return_status => l_return_status,
            p_custom_appl_id => G_CUST_REGION_REDO_TBL(l_index).customization_appl_id,
            p_custom_code => G_CUST_REGION_REDO_TBL(l_index).customization_code,
            p_region_application_id => G_CUST_REGION_REDO_TBL(l_index).region_appl_id,
            p_region_code => G_CUST_REGION_REDO_TBL(l_index).region_code,
            p_property_name => G_CUST_REGION_REDO_TBL(l_index).property_name,
            p_property_varchar2_value => G_CUST_REGION_REDO_TBL(l_index).property_varchar2_value,
            p_property_number_value => G_CUST_REGION_REDO_TBL(l_index).property_number_value,
            p_criteria_join_condition => G_CUST_REGION_REDO_TBL(l_index).criteria_join_condition,
            p_property_varchar2_value_tl => G_CUST_REGION_REDO_TBL(l_index).property_varchar2_value_tl,
	    p_created_by => G_CUST_REGION_REDO_TBL(l_index).created_by,
	    p_creation_date => G_CUST_REGION_REDO_TBL(l_index).creation_date,
	    p_last_updated_by => G_CUST_REGION_REDO_TBL(l_index).last_updated_by,
	    p_last_update_date => G_CUST_REGION_REDO_TBL(l_index).last_update_date,
	    p_last_update_login => G_CUST_REGION_REDO_TBL(l_index).last_update_login,
              p_loader_timestamp => p_loader_timestamp,
                      p_pass => p_pass,
              p_copy_redo_flag => l_copy_redo_flag
            );
                  elsif (AK_UPLOAD_GRP.G_NO_CUSTOM_UPDATE) then
                        -- do not update customized data
                        select ac.last_updated_by, act.last_updated_by,
			ac.last_update_date, act.last_update_date
			into l_user_id1, l_user_id2, l_update1, l_update2
                        from ak_custom_regions ac, ak_custom_regions_tl act
                        where ac.customization_application_id = G_CUST_REGION_REDO_TBL(l_index).customization_appl_id
                        and ac.customization_code = G_CUST_REGION_REDO_TBL(l_index).customization_code
                        and ac.region_application_id = G_CUST_REGION_REDO_TBL(l_index).region_appl_id
                        and ac.region_code = G_CUST_REGION_REDO_TBL(l_index).region_code
                        and ac.property_name = G_CUST_REGION_REDO_TBL(l_index).property_name
                        and ac.customization_application_id = act.customization_application_id
                        and ac.customization_code = act.customization_code
                        and ac.region_application_id = act.region_application_id
                        and ac.region_code = act.region_code
                        and act.language = userenv('LANG');
                        /*if (( l_user_id1 = 1 or l_user_id1 = 2 ) and
				( l_user_id2 = 1 or l_user_id2 = 2 )) then*/
                if (AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
                      p_loader_timestamp => p_loader_timestamp,
                      p_created_by => G_CUST_REGION_REDO_TBL(l_index).created_by,
                      p_creation_date => G_CUST_REGION_REDO_TBL(l_index).creation_date,
                      p_last_updated_by => G_CUST_REGION_REDO_TBL(l_index).last_updated_by,
                      p_db_last_updated_by => l_user_id1,
                      p_last_update_date => G_CUST_REGION_REDO_TBL(l_index).last_update_date,
                      p_db_last_update_date => l_update1,
                      p_last_update_login => G_CUST_REGION_REDO_TBL(l_index).last_update_login,
                      p_create_or_update => 'UPDATE') and

                   AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
                      p_loader_timestamp => p_loader_timestamp,
                      p_created_by => G_CUST_REGION_REDO_TBL(l_index).created_by,
                      p_creation_date => G_CUST_REGION_REDO_TBL(l_index).creation_date,
                      p_last_updated_by => G_CUST_REGION_REDO_TBL(l_index).last_updated_by,
                      p_db_last_updated_by => l_user_id2,
                      p_last_update_date => G_CUST_REGION_REDO_TBL(l_index).last_update_date,
                      p_db_last_update_date => l_update2,
                      p_last_update_login => G_CUST_REGION_REDO_TBL(l_index).last_update_login,
                      p_create_or_update => 'UPDATE')) then

                    AK_CUSTOM_PVT.UPDATE_CUST_REGION (
                      p_validation_level => p_validation_level,
                      p_api_version_number => 1.0,
                      p_msg_count => l_msg_count,
                      p_msg_data => l_msg_data,
                      p_return_status => l_return_status,
                      p_custom_appl_id => G_CUST_REGION_REDO_TBL(l_index).customization_appl_id,
                      p_custom_code => G_CUST_REGION_REDO_TBL(l_index).customization_code,
                      p_region_application_id => G_CUST_REGION_REDO_TBL(l_index).region_appl_id,
                      p_region_code => G_CUST_REGION_REDO_TBL(l_index).region_code,
                      p_property_name => G_CUST_REGION_REDO_TBL(l_index).property_name,
                      p_property_varchar2_value => G_CUST_REGION_REDO_TBL(l_index).property_varchar2_value,
                      p_property_number_value => G_CUST_REGION_REDO_TBL(l_index).property_number_value,
                      p_criteria_join_condition => G_CUST_REGION_REDO_TBL(l_index).criteria_join_condition,
                      p_property_varchar2_value_tl => G_CUST_REGION_REDO_TBL(l_index).property_varchar2_value_tl,
		      p_created_by => G_CUST_REGION_REDO_TBL(l_index).created_by,
		      p_creation_date => G_CUST_REGION_REDO_TBL(l_index).creation_date,
		      p_last_updated_by => G_CUST_REGION_REDO_TBL(l_index).last_updated_by,
		      p_last_update_date => G_CUST_REGION_REDO_TBL(l_index).last_update_date,
	 	      p_last_update_login => G_CUST_REGION_REDO_TBL(l_index).last_update_login,
                                            p_loader_timestamp => p_loader_timestamp,
                              p_pass => p_pass,
                      p_copy_redo_flag => l_copy_redo_flag
                    );
                        end if; -- /* if ( l_user_id1 = 1 and l_user_id2 = 1 ) */
          end if; -- /* if G_UPDATE_MODE G_NC_UPDATE_MODE*/
        else
          AK_CUSTOM_PVT.CREATE_CUST_REGION (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
            p_custom_appl_id => G_CUST_REGION_REDO_TBL(l_index).customization_appl_id,
            p_custom_code => G_CUST_REGION_REDO_TBL(l_index).customization_code,
            p_region_appl_id => G_CUST_REGION_REDO_TBL(l_index).region_appl_id,
            p_region_code => G_CUST_REGION_REDO_TBL(l_index).region_code,
            p_property_name => G_CUST_REGION_REDO_TBL(l_index).property_name,
            p_property_varchar2_value => G_CUST_REGION_REDO_TBL(l_index).property_varchar2_value,
            p_property_number_value => G_CUST_REGION_REDO_TBL(l_index).property_number_value,
            p_criteria_join_condition => G_CUST_REGION_REDO_TBL(l_index).criteria_join_condition,
            p_property_varchar2_value_tl => G_CUST_REGION_REDO_TBL(l_index).property_varchar2_value_tl,
	p_created_by => G_CUST_REGION_REDO_TBL(l_index).created_by,
	p_creation_date => G_CUST_REGION_REDO_TBL(l_index).creation_date,
	p_last_updated_by => G_CUST_REGION_REDO_TBL(l_index).last_updated_by,
	p_last_update_date => G_CUST_REGION_REDO_TBL(l_index).last_update_date,
	p_last_update_login => G_CUST_REGION_REDO_TBL(l_index).last_update_login,
            p_loader_timestamp => p_loader_timestamp,
            p_pass => p_pass,
            p_copy_redo_flag => l_copy_redo_flag
                    );
        end if; -- /* if CUST_REGION_EXISTS */
        --
        -- If API call returns with an error status, upload aborts
        if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
        (l_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        end if; -- /* if l_return_status */
      end if; -- /* if G_CUST_REGION_REDO_TBL.exists */
    end loop;
  end if;
  --
  -- create or update all custom_region_items to the database
  --
  if (G_CUST_REG_ITEM_REDO_INDEX > 0) then
    for l_index in G_CUST_REG_ITEM_REDO_TBL.FIRST .. G_CUST_REG_ITEM_REDO_TBL.LAST
 loop
      if (G_CUST_REG_ITEM_REDO_TBL.exists(l_index)) then
        if AK_CUSTOM_PVT.CUST_REG_ITEM_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_custom_appl_id => G_CUST_REG_ITEM_REDO_TBL(l_index).customization_appl_id,
            p_custom_code => G_CUST_REG_ITEM_REDO_TBL(l_index).customization_code,
            p_region_application_id => G_CUST_REG_ITEM_REDO_TBL(l_index).region_appl_id,
            p_region_code => G_CUST_REG_ITEM_REDO_TBL(l_index).region_code,
            p_attribute_appl_id => G_CUST_REG_ITEM_REDO_TBL(l_index).attr_appl_id,
            p_attribute_code => G_CUST_REG_ITEM_REDO_TBL(l_index).attr_code,
            p_property_name => G_CUST_REG_ITEM_REDO_TBL(l_index).property_name)
 then
            AK_CUSTOM_PVT.UPDATE_CUST_REG_ITEM (
              p_validation_level => p_validation_level,
              p_api_version_number => 1.0,
              p_msg_count => l_msg_count,
              p_msg_data => l_msg_data,
              p_return_status => l_return_status,
            p_custom_appl_id => G_CUST_REG_ITEM_REDO_TBL(l_index).customization_appl_id,
            p_custom_code => G_CUST_REG_ITEM_REDO_TBL(l_index).customization_code,
            p_region_application_id => G_CUST_REG_ITEM_REDO_TBL(l_index).region_appl_id,
            p_region_code => G_CUST_REG_ITEM_REDO_TBL(l_index).region_code,
            p_attribute_appl_id => G_CUST_REG_ITEM_REDO_TBL(l_index).attr_appl_id,
            p_attribute_code => G_CUST_REG_ITEM_REDO_TBL(l_index).attr_code,
            p_property_name => G_CUST_REG_ITEM_REDO_TBL(l_index).property_name,
            p_property_varchar2_value => G_CUST_REG_ITEM_REDO_TBL(l_index).property_varchar2_value,
            p_property_number_value => G_CUST_REG_ITEM_REDO_TBL(l_index).property_number_value,
            p_property_date_value => G_CUST_REG_ITEM_REDO_TBL(l_index).property_date_value,
            p_property_varchar2_value_tl => G_CUST_REG_ITEM_REDO_TBL(l_index).property_varchar2_value_tl,
	    p_created_by => G_CUST_REG_ITEM_REDO_TBL(l_index).created_by,
	    p_creation_date => G_CUST_REG_ITEM_REDO_TBL(l_index).creation_date,
	    p_last_updated_by => G_CUST_REG_ITEM_REDO_TBL(l_index).last_updated_by,
	    p_last_update_date => G_CUST_REG_ITEM_REDO_TBL(l_index).last_update_date,
	    p_last_update_login => G_CUST_REG_ITEM_REDO_TBL(l_index).last_update_login,
              p_loader_timestamp => p_loader_timestamp,
                      p_pass => p_pass,
              p_copy_redo_flag => l_copy_redo_flag
            );
        else
          AK_CUSTOM_PVT.CREATE_CUST_REG_ITEM (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
            p_custom_appl_id => G_CUST_REG_ITEM_REDO_TBL(l_index).customization_appl_id,
            p_custom_code => G_CUST_REG_ITEM_REDO_TBL(l_index).customization_code,
            p_region_appl_id => G_CUST_REG_ITEM_REDO_TBL(l_index).region_appl_id,
            p_region_code => G_CUST_REG_ITEM_REDO_TBL(l_index).region_code,
            p_attr_appl_id => G_CUST_REG_ITEM_REDO_TBL(l_index).attr_appl_id,
            p_attr_code => G_CUST_REG_ITEM_REDO_TBL(l_index).attr_code,
            p_property_name => G_CUST_REG_ITEM_REDO_TBL(l_index).property_name,
            p_property_varchar2_value => G_CUST_REG_ITEM_REDO_TBL(l_index).property_varchar2_value,
            p_property_number_value => G_CUST_REG_ITEM_REDO_TBL(l_index).property_number_value,
            p_property_date_value => G_CUST_REG_ITEM_REDO_TBL(l_index).property_date_value,
            p_property_varchar2_value_tl => G_CUST_REG_ITEM_REDO_TBL(l_index).property_varchar2_value_tl,
	p_created_by => G_CUST_REG_ITEM_REDO_TBL(l_index).created_by,
	p_creation_date => G_CUST_REG_ITEM_REDO_TBL(l_index).creation_date,
	p_last_updated_by => G_CUST_REG_ITEM_REDO_TBL(l_index).last_updateD_by,
	p_last_update_date => G_CUST_REG_ITEM_REDO_TBL(l_index).last_update_date,
	p_last_update_login => G_CUST_REG_ITEM_REDO_TBL(l_index).last_update_login,
            p_loader_timestamp => p_loader_timestamp,
            p_pass => p_pass,
            p_copy_redo_flag => l_copy_redo_flag
                    );
        end if; -- /* if CUST_REGION_EXISTS */
        --
        -- If API call returns with an error status, upload aborts
        if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
        (l_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        end if; -- /* if l_return_status */
      end if; -- /* if G_CUST_REG_ITEM_REDO_TBL.exists(l_index) */
    end loop;
  end if; -- /* if G_CUST_REG_ITEM_REDO_INDEX > 0 */

  --
  -- create or update all custom_criteria to the database
  --
  if (G_CRITERIA_REDO_INDEX > 0) then
    for l_index in G_CRITERIA_REDO_TBL.FIRST .. G_CRITERIA_REDO_TBL.LAST
 loop
      if (G_CRITERIA_REDO_TBL.exists(l_index)) then
        if AK_CUSTOM_PVT.CRITERIA_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_custom_appl_id => G_CRITERIA_REDO_TBL(l_index).customization_application_id,
            p_custom_code => G_CRITERIA_REDO_TBL(l_index).customization_code,
            p_region_application_id => G_CRITERIA_REDO_TBL(l_index).region_application_id,
            p_region_code => G_CRITERIA_REDO_TBL(l_index).region_code,
            p_attribute_appl_id => G_CRITERIA_REDO_TBL(l_index).attribute_application_id,
            p_attribute_code => G_CRITERIA_REDO_TBL(l_index).attribute_code,
            p_sequence_number => G_CRITERIA_REDO_TBL(l_index).sequence_number) then
            AK_CUSTOM_PVT.UPDATE_CRITERIA (
              p_validation_level => p_validation_level,
              p_api_version_number => 1.0,
              p_msg_count => l_msg_count,
              p_msg_data => l_msg_data,
              p_return_status => l_return_status,
            p_custom_appl_id => G_CRITERIA_REDO_TBL(l_index).customization_application_id,
            p_custom_code => G_CRITERIA_REDO_TBL(l_index).customization_code,
            p_region_application_id => G_CRITERIA_REDO_TBL(l_index).region_application_id,
            p_region_code => G_CRITERIA_REDO_TBL(l_index).region_code,
            p_attribute_appl_id => G_CRITERIA_REDO_TBL(l_index).attribute_application_id,
            p_attribute_code => G_CRITERIA_REDO_TBL(l_index).attribute_code,
            p_sequence_number => G_CRITERIA_REDO_TBL(l_index).sequence_number,
            p_operation => G_CRITERIA_REDO_TBL(l_index).operation,
            p_value_varchar2 => G_CRITERIA_REDO_TBL(l_index).value_varchar2,
            p_value_number => G_CRITERIA_REDO_TBL(l_index).value_number,
            p_value_date => G_CRITERIA_REDO_TBL(l_index).value_date,
	    p_start_date_active  => G_CRITERIA_REDO_TBL(l_index).start_date_active,
	    p_end_date_active => G_CRITERIA_REDO_TBL(l_index).end_date_active,
	    p_created_by => G_CRITERIA_REDO_TBL(l_index).created_by,
	    p_creation_date => G_CRITERIA_REDO_TBL(l_index).creation_date,
	    p_last_updated_by => G_CRITERIA_REDO_TBL(l_index).last_updated_by,
	    p_last_update_date => G_CRITERIA_REDO_TBL(l_index).last_update_date,
	    p_last_update_login => G_CRITERIA_REDO_TBL(l_index).last_update_login,
                          p_loader_timestamp => p_loader_timestamp,
                      p_pass => p_pass,
              p_copy_redo_flag => l_copy_redo_flag
            );
        else
          AK_CUSTOM_PVT.CREATE_CRITERIA (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
            p_custom_appl_id => G_CRITERIA_REDO_TBL(l_index).customization_application_id,
            p_custom_code => G_CRITERIA_REDO_TBL(l_index).customization_code,
            p_region_appl_id => G_CRITERIA_REDO_TBL(l_index).region_application_id,
            p_region_code => G_CRITERIA_REDO_TBL(l_index).region_code,
            p_attr_appl_id => G_CRITERIA_REDO_TBL(l_index).attribute_application_id,
            p_attr_code => G_CRITERIA_REDO_TBL(l_index).attribute_code,
            p_sequence_number => G_CRITERIA_REDO_TBL(l_index).sequence_number,
            p_operation => G_CRITERIA_REDO_TBL(l_index).operation,
            p_value_varchar2 => G_CRITERIA_REDO_TBL(l_index).value_varchar2,
            p_value_number => G_CRITERIA_REDO_TBL(l_index).value_number,
            p_value_date => G_CRITERIA_REDO_TBL(l_index).value_date,
	    p_start_date_active  => G_CRITERIA_REDO_TBL(l_index).start_date_active,
	    p_end_date_active => G_CRITERIA_REDO_TBL(l_index).end_date_active,
	p_created_by => G_CRITERIA_REDO_TBL(l_index).created_by,
	p_creation_date => G_CRITERIA_REDO_TBL(l_index).creation_date,
	p_last_updated_by => G_CRITERIA_REDO_TBL(l_index).last_updated_by,
	p_last_update_date => G_CRITERIA_REDO_TBL(l_index).last_update_date,
	p_last_update_login => G_CRITERIA_REDO_TBL(l_index).last_update_login,
            p_loader_timestamp => p_loader_timestamp,
            p_pass => p_pass,
            p_copy_redo_flag => l_copy_redo_flag
                    );
        end if; -- /* if CUST_REGION_EXISTS */
        --
        -- If API call returns with an error status, upload aborts
        if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
        (l_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        end if; -- /* if l_return_status */
      end if; -- /* if G_CRITERIA_REDO_TBL.exists(l_index) */
    end loop;
  end if; -- /* if G_CRITERIA_REDO_INDEX > 0 */

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

end UPLOAD_CUSTOM_SECOND;

end AK_CUSTOM2_PVT;

/
