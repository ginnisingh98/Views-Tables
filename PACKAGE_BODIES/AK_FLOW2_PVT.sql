--------------------------------------------------------
--  DDL for Package Body AK_FLOW2_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AK_FLOW2_PVT" as
/* $Header: akdvfl2b.pls 120.3 2005/09/15 22:18:27 tshort ship $ */


--=======================================================
--  Procedure   WRITE_ITEMS_TO_BUFFER (local procedure)
--
--  Usage       Local procedure for writing all flow page region
--              item records for the given flow page region to
--              the output file. Not designed to be called
--              from outside this package.
--
--  Desc        This procedure retrieves all Flow Page Region Item
--              records for the given Flow Page Region from the
--              database, and writes them to the output file
--              in loader file format.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters
--              p_flow_application_id : IN required
--              p_flow_code : IN required
--              p_page_application_id : IN required
--              p_page_code : IN required
--              p_region_application_id : IN required
--              p_region_code : IN required
--                  Key value of the Flow Page Region record
--                  whose Flow Page Region Item records are to be
--                  extracted to the loader file.
--=======================================================
procedure WRITE_ITEMS_TO_BUFFER (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_flow_application_id      IN      NUMBER,
  p_flow_code                IN      VARCHAR2,
  p_page_application_id      IN      NUMBER,
  p_page_code                IN      VARCHAR2,
  p_region_application_id    IN      NUMBER,
  p_region_code              IN      VARCHAR2
) is
  cursor l_get_items_csr is
    select *
    from   AK_FLOW_PAGE_REGION_ITEMS
    where  FLOW_APPLICATION_ID = p_flow_application_id
    and    FLOW_CODE = p_flow_code
    and    PAGE_APPLICATION_ID = p_page_application_id
    and    PAGE_CODE = p_page_code
    and    REGION_APPLICATION_ID = p_region_application_id
    and    REGION_CODE = p_region_code;
  l_api_name           CONSTANT varchar2(30) := 'Write_Items_to_buffer';
  l_databuffer_tbl     AK_ON_OBJECTS_PUB.Buffer_Tbl_Type;
  l_index              NUMBER;
  l_items_rec          AK_FLOW_PAGE_REGION_ITEMS%ROWTYPE;
  l_return_status      varchar2(1);
begin
  -- Find out where the next buffer entry to be written to
  l_index := 1;

  -- Retrieve flow page region items information from the database

  open l_get_items_csr;
  loop
    fetch l_get_items_csr into l_items_rec;
    exit when l_get_items_csr%notfound;
    -- write this flow page region item if it is validated
    if (p_validation_level <> FND_API.G_VALID_LEVEL_NONE) and
          not AK_FLOW3_PVT.VALIDATE_PAGE_REGION_ITEM (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_flow_application_id => p_flow_application_id,
            p_flow_code => p_flow_code,
            p_page_application_id => p_page_application_id,
            p_page_code => p_page_code,
            p_region_application_id => p_region_application_id,
            p_region_code => p_region_code,
            p_attribute_application_id => l_items_rec.attribute_application_id,
            p_attribute_code => l_items_rec.attribute_code,
            p_to_page_appl_id => l_items_rec.to_page_appl_id,
            p_to_page_code => l_items_rec.to_page_code,
            p_to_url_attribute_appl_id => l_items_rec.to_url_attribute_appl_id,
            p_to_url_attribute_code => l_items_rec.to_url_attribute_code,
            p_caller => AK_ON_OBJECTS_PVT.G_DOWNLOAD)
    then
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
          FND_MESSAGE.SET_NAME('AK','AK_PG_REG_ITEM_NOT_DOWNLOADED');
          FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
                   ' ' || p_flow_code ||
                   ' ' || to_char(p_page_application_id) ||
                   ' ' || p_page_code ||
                   ' ' || to_char(p_region_application_id) ||
                   ' ' || p_region_code ||
                   ' ' || to_char(l_items_rec.attribute_application_id) ||
                   ' ' || l_items_rec.attribute_code );
          FND_MSG_PUB.Add;
	  close l_get_items_csr;
		  raise FND_API.G_EXC_ERROR;
        end if;
    else
      l_databuffer_tbl(l_index) := ' ';
      l_index := l_index + 1;
      l_databuffer_tbl(l_index) := '      BEGIN FLOW_PAGE_REGION_ITEM "' ||
        nvl(to_char(l_items_rec.attribute_application_id),'') || '" "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_items_rec.attribute_code)
            || '"';
      if ((l_items_rec.to_page_appl_id IS NOT NULL) and
         (l_items_rec.to_page_appl_id <> FND_API.G_MISS_NUM) and
         (l_items_rec.to_page_code IS NOT NULL) and
         (l_items_rec.to_page_code <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '        TO_PAGE = "' ||
          nvl(to_char(l_items_rec.to_page_appl_id),'')||'" "'||
            AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_items_rec.to_page_code)
              || '"';
      end if;
      if (l_items_rec.to_url_attribute_appl_id IS NOT NULL) and
         (l_items_rec.to_url_attribute_appl_id <> FND_API.G_MISS_NUM) and
         (l_items_rec.to_url_attribute_code IS NOT NULL) and
         (l_items_rec.to_url_attribute_code <> FND_API.G_MISS_CHAR) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '        TO_URL_ATTRIBUTE = "' ||
           nvl(to_char(l_items_rec.to_url_attribute_appl_id),'')||'" "'||
             AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
               l_items_rec.to_url_attribute_code)|| '"';
      end if;
      -- Flex Fields
      --
      if ((l_items_rec.attribute_category IS NOT NULL) and
         (l_items_rec.attribute_category <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '        ATTRIBUTE_CATEGORY = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_items_rec.attribute_category) || '"';
      end if;
      if ((l_items_rec.attribute1 IS NOT NULL) and
         (l_items_rec.attribute1 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '        ATTRIBUTE1 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_items_rec.attribute1) || '"';
      end if;
      if ((l_items_rec.attribute2 IS NOT NULL) and
         (l_items_rec.attribute2 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '        ATTRIBUTE2 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_items_rec.attribute2) || '"';
      end if;
      if ((l_items_rec.attribute3 IS NOT NULL) and
         (l_items_rec.attribute3 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '        ATTRIBUTE3 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_items_rec.attribute3) || '"';
      end if;
      if ((l_items_rec.attribute4 IS NOT NULL) and
         (l_items_rec.attribute4 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '        ATTRIBUTE4 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_items_rec.attribute4) || '"';
      end if;
      if ((l_items_rec.attribute5 IS NOT NULL) and
         (l_items_rec.attribute5 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '        ATTRIBUTE5 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_items_rec.attribute5) || '"';
      end if;
      if ((l_items_rec.attribute6 IS NOT NULL) and
         (l_items_rec.attribute6 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '        ATTRIBUTE6 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_items_rec.attribute6) || '"';
      end if;
      if ((l_items_rec.attribute7 IS NOT NULL) and
         (l_items_rec.attribute7 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '        ATTRIBUTE7 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_items_rec.attribute7) || '"';
      end if;
      if ((l_items_rec.attribute8 IS NOT NULL) and
         (l_items_rec.attribute8 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '        ATTRIBUTE8 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_items_rec.attribute8) || '"';
      end if;
      if ((l_items_rec.attribute9 IS NOT NULL) and
         (l_items_rec.attribute9 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '        ATTRIBUTE9 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_items_rec.attribute9) || '"';
      end if;
      if ((l_items_rec.attribute10 IS NOT NULL) and
         (l_items_rec.attribute10 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '        ATTRIBUTE10 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_items_rec.attribute10) || '"';
      end if;
      if ((l_items_rec.attribute11 IS NOT NULL) and
         (l_items_rec.attribute11 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '        ATTRIBUTE11 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_items_rec.attribute11) || '"';
      end if;
      if ((l_items_rec.attribute12 IS NOT NULL) and
         (l_items_rec.attribute12 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '        ATTRIBUTE12 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_items_rec.attribute12) || '"';
      end if;
      if ((l_items_rec.attribute13 IS NOT NULL) and
         (l_items_rec.attribute13 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '        ATTRIBUTE13 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_items_rec.attribute13) || '"';
      end if;
      if ((l_items_rec.attribute14 IS NOT NULL) and
         (l_items_rec.attribute14 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '        ATTRIBUTE14 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_items_rec.attribute14) || '"';
      end if;
      if ((l_items_rec.attribute15 IS NOT NULL) and
         (l_items_rec.attribute15 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '        ATTRIBUTE15 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_items_rec.attribute15) || '"';
      end if;
  -- - Write out who columns
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '        CREATED_BY = "' ||
                nvl(to_char(l_items_rec.created_by),'') || '"';
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '        CREATION_DATE = "' ||
                to_char(l_items_rec.creation_date,
                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
    l_index := l_index + 1;
--  CHANGED TO OWNER FOR R12
--    l_databuffer_tbl(l_index) := '        LAST_UPDATED_BY = "' ||
--                nvl(to_char(l_items_rec.last_updated_by),'') || '"';
    l_databuffer_tbl(l_index) := '        OWNER = "' ||
                FND_LOAD_UTIL.OWNER_NAME(l_items_rec.last_updated_by) || '"';
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '        LAST_UPDATE_DATE = "' ||
                to_char(l_items_rec.last_update_date,
                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '        LAST_UPDATE_LOGIN = "' ||
                nvl(to_char(l_items_rec.last_update_login),'') || '"';


      -- finish up flow page region item
      l_index := l_index + 1;
      l_databuffer_tbl(l_index) := '      END FLOW_PAGE_REGION_ITEM';
      l_index := l_index + 1;
      l_databuffer_tbl(l_index) := ' ';
    end if; -- validation OK

  end loop;

  close l_get_items_csr;

  -- - Write page region item data out to the specified file
  --   don't call write_file if there is no data to be written
  if (l_databuffer_tbl.count > 0) then
    AK_ON_OBJECTS_PVT.WRITE_FILE (
      p_return_status => l_return_status,
      p_buffer_tbl => l_databuffer_tbl,
      p_write_mode => AK_ON_OBJECTS_PUB.G_APPEND
    );
    -- If API call returns with an error status...
    if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
       (l_return_status = FND_API.G_RET_STS_ERROR) then
      RAISE FND_API.G_EXC_ERROR;
    end if;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN VALUE_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_PG_REG_ITEM_VALUE_ERROR');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
                   ' ' || p_flow_code ||
                   ' ' || to_char(p_page_application_id) ||
                   ' ' || p_page_code ||
                   ' ' || to_char(p_region_application_id) ||
                   ' ' || p_region_code ||
                   ' ' || to_char(l_items_rec.attribute_application_id) ||
                   ' ' || l_items_rec.attribute_code );
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;
end WRITE_ITEMS_TO_BUFFER;

--=======================================================
--  Procedure   WRITE_REGIONS_TO_BUFFER (local procedure)
--
--  Usage       Local procedure for writing all flow page
--              region records for the given flow page to
--              the output file. Not designed to be called
--              from outside this package.
--
--  Desc        This procedure retrieves all Flow Page Region
--              records for the given Flow Page, as well as
--              all Flow Page Region Item records for these
--              Flow Page Regions and the intrapage Flow Region
--              Relation connecting the flow page region and its
--              parent region, from the database and writes them
--              to the output file in loader file format.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters
--              p_flow_application_id : IN required
--              p_flow_code : IN required
--              p_page_application_id : IN required
--              p_page_code : IN required
--                  Key value of the Flow Page record
--                  whose Flow Page Region records are to be
--                  extracted to the loader file.
--=======================================================
procedure WRITE_REGIONS_TO_BUFFER (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_flow_application_id      IN      NUMBER,
  p_flow_code                IN      VARCHAR2,
  p_page_application_id      IN      NUMBER,
  p_page_code                IN      VARCHAR2
) is
  cursor l_get_regions_csr is
    select *
    from   AK_FLOW_PAGE_REGIONS
    where  FLOW_APPLICATION_ID = p_flow_application_id
    and    FLOW_CODE = p_flow_code
    and    PAGE_APPLICATION_ID = p_page_application_id
    and    PAGE_CODE = p_page_code;
  cursor l_get_relation_csr (parent_region_appl_id_param number,
                             parent_region_code_param varchar2,
                             region_appl_id_param number,
                             region_code_param varchar2) is
    select foreign_key_name
    from   AK_FLOW_REGION_RELATIONS
    where  FLOW_APPLICATION_ID = p_flow_application_id
    and    FLOW_CODE = p_flow_code
    and    FROM_PAGE_APPL_ID = p_page_application_id
    and    FROM_PAGE_CODE = p_page_code
    and    FROM_REGION_APPL_ID = parent_region_appl_id_param
    and    FROM_REGION_CODE = parent_region_code_param
    and    TO_PAGE_APPL_ID = p_page_application_id
    and    TO_PAGE_CODE = p_page_code
    and    TO_REGION_APPL_ID = region_appl_id_param
    and    TO_REGION_CODE = region_code_param;
  l_api_name           CONSTANT varchar2(30) := 'Write_Region_to_buffer';
  l_databuffer_tbl     AK_ON_OBJECTS_PUB.Buffer_Tbl_Type;
  l_foreign_key_name   VARCHAR2(30);
  l_index              NUMBER;
  l_regions_rec        AK_FLOW_PAGE_REGIONS%ROWTYPE;
  l_return_status      varchar2(1);
begin
  -- Find out where the next buffer entry to be written to
  l_index := 1;

  -- Retrieve flow page regions information from the database

  open l_get_regions_csr;
  loop
    fetch l_get_regions_csr into l_regions_rec;
    exit when l_get_regions_csr%notfound;
    --
    -- get foreign key name from the intrapage relation if there is
    -- a parent region
    --
    if (l_regions_rec.parent_region_application_id is not null) or
       (l_regions_rec.parent_region_code is not null) then
      open l_get_relation_csr (l_regions_rec.parent_region_application_id,
                               l_regions_rec.parent_region_code,
                               l_regions_rec.region_application_id,
                               l_regions_rec.region_code);
      fetch l_get_relation_csr into l_foreign_key_name;
      close l_get_relation_csr;
    else
      l_foreign_key_name := null;
    end if;

    -- write this flow page region if it is validated
    if (p_validation_level <> FND_API.G_VALID_LEVEL_NONE) and
          not AK_FLOW3_PVT.VALIDATE_PAGE_REGION (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_flow_application_id => p_flow_application_id,
            p_flow_code => p_flow_code,
            p_page_application_id => p_page_application_id,
            p_page_code => p_page_code,
            p_region_application_id => l_regions_rec.region_application_id,
            p_region_code => l_regions_rec.region_code,
            p_display_sequence => l_regions_rec.display_sequence,
            p_region_style => l_regions_rec.region_style,
            p_num_columns => l_regions_rec.num_columns,
            p_icx_custom_call => l_regions_rec.icx_custom_call,
            p_parent_region_application_id =>
                         l_regions_rec.parent_region_application_id,
            p_parent_region_code => l_regions_rec.parent_region_code,
            p_foreign_key_name => l_foreign_key_name,
            p_caller => AK_ON_OBJECTS_PVT.G_DOWNLOAD)
    then
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
          FND_MESSAGE.SET_NAME('AK','AK_PG_REGION_NOT_DOWNLOADED');
          FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
                   ' ' || p_flow_code ||
                   ' ' || to_char(p_page_application_id) ||
                   ' ' || p_page_code ||
                   ' ' || to_char(l_regions_rec.region_application_id) ||
                   ' ' || l_regions_rec.region_code );
          FND_MSG_PUB.Add;
	  close l_get_regions_csr;
		  raise FND_API.G_EXC_ERROR;
        end if;
    else
      l_databuffer_tbl(l_index) := ' ';
      l_index := l_index + 1;
      l_databuffer_tbl(l_index) := '    BEGIN FLOW_PAGE_REGION "' ||
        nvl(to_char(l_regions_rec.region_application_id),'') || '" "' ||
        AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_regions_rec.region_code)
        || '"';
      l_index := l_index + 1;
      l_databuffer_tbl(l_index) := '      DISPLAY_SEQUENCE = "' ||
               nvl(to_char(l_regions_rec.display_sequence),'') || '"';
      l_index := l_index + 1;
      l_databuffer_tbl(l_index) := '      REGION_STYLE = "' ||
        AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_regions_rec.region_style)
         || '"';
      if (l_regions_rec.num_columns IS NOT NULL) and
         (l_regions_rec.num_columns <> FND_API.G_MISS_NUM) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '      NUM_COLUMNS = "' ||
                 nvl(to_char(l_regions_rec.num_columns),'') || '"';
      end if;
      if (l_regions_rec.icx_custom_call IS NOT NULL) and
         (l_regions_rec.icx_custom_call <> FND_API.G_MISS_CHAR) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '      ICX_CUSTOM_CALL = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_regions_rec.icx_custom_call)          ||'"';
      end if;
      if (l_regions_rec.parent_region_application_id IS NOT NULL) and
         (l_regions_rec.parent_region_application_id <> FND_API.G_MISS_NUM) and
         (l_regions_rec.parent_region_code IS NOT NULL) and
         (l_regions_rec.parent_region_code <> FND_API.G_MISS_CHAR) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '      PARENT_REGION = "' ||
          nvl(to_char(l_regions_rec.parent_region_application_id),'')||'" "'||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_regions_rec.parent_region_code)
          ||'"';
      end if;
      if (l_foreign_key_name IS NOT NULL) and
         (l_foreign_key_name <> FND_API.G_MISS_CHAR) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '      FOREIGN_KEY_NAME = "' ||
         AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_foreign_key_name)
         ||'"';
      end if;
      -- Flex Fields
      --
      if ((l_regions_rec.attribute_category IS NOT NULL) and
         (l_regions_rec.attribute_category <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '      ATTRIBUTE_CATEGORY = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_regions_rec.attribute_category) || '"';
      end if;
      if ((l_regions_rec.attribute1 IS NOT NULL) and
         (l_regions_rec.attribute1 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '      ATTRIBUTE1 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_regions_rec.attribute1) || '"';
      end if;
      if ((l_regions_rec.attribute2 IS NOT NULL) and
         (l_regions_rec.attribute2 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '      ATTRIBUTE2 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_regions_rec.attribute2) || '"';
      end if;
      if ((l_regions_rec.attribute3 IS NOT NULL) and
         (l_regions_rec.attribute3 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '      ATTRIBUTE3 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_regions_rec.attribute3) || '"';
      end if;
      if ((l_regions_rec.attribute4 IS NOT NULL) and
         (l_regions_rec.attribute4 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '      ATTRIBUTE4 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_regions_rec.attribute4) || '"';
      end if;
      if ((l_regions_rec.attribute5 IS NOT NULL) and
         (l_regions_rec.attribute5 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '      ATTRIBUTE5 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_regions_rec.attribute5) || '"';
      end if;
      if ((l_regions_rec.attribute6 IS NOT NULL) and
         (l_regions_rec.attribute6 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '      ATTRIBUTE6 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_regions_rec.attribute6) || '"';
      end if;
      if ((l_regions_rec.attribute7 IS NOT NULL) and
         (l_regions_rec.attribute7 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '      ATTRIBUTE7 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_regions_rec.attribute7) || '"';
      end if;
      if ((l_regions_rec.attribute8 IS NOT NULL) and
         (l_regions_rec.attribute8 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '      ATTRIBUTE8 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_regions_rec.attribute8) || '"';
      end if;
      if ((l_regions_rec.attribute9 IS NOT NULL) and
         (l_regions_rec.attribute9 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '      ATTRIBUTE9 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_regions_rec.attribute9) || '"';
      end if;
      if ((l_regions_rec.attribute10 IS NOT NULL) and
         (l_regions_rec.attribute10 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '      ATTRIBUTE10 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_regions_rec.attribute10) || '"';
      end if;
      if ((l_regions_rec.attribute11 IS NOT NULL) and
         (l_regions_rec.attribute11 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '      ATTRIBUTE11 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_regions_rec.attribute11) || '"';
      end if;
      if ((l_regions_rec.attribute12 IS NOT NULL) and
         (l_regions_rec.attribute12 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '      ATTRIBUTE12 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_regions_rec.attribute12) || '"';
      end if;
      if ((l_regions_rec.attribute13 IS NOT NULL) and
         (l_regions_rec.attribute13 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '      ATTRIBUTE13 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_regions_rec.attribute13) || '"';
      end if;
      if ((l_regions_rec.attribute14 IS NOT NULL) and
         (l_regions_rec.attribute14 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '      ATTRIBUTE14 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_regions_rec.attribute14) || '"';
      end if;
      if ((l_regions_rec.attribute15 IS NOT NULL) and
         (l_regions_rec.attribute15 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '      ATTRIBUTE15 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_regions_rec.attribute15) || '"';
      end if;
  -- - Write out who columns
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '      CREATED_BY = "' ||
                nvl(to_char(l_regions_rec.created_by),'') || '"';
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '      CREATION_DATE = "' ||
                to_char(l_regions_rec.creation_date,
                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
    l_index := l_index + 1;
-- CHANGED TO OWNER FOR R12
--    l_databuffer_tbl(l_index) := '      LAST_UPDATED_BY = "' ||
--                nvl(to_char(l_regions_rec.last_updated_by),'') || '"';
    l_databuffer_tbl(l_index) := '      OWNER = "' ||
                FND_LOAD_UTIL.OWNER_NAME(l_regions_rec.last_updated_by) ||'"';
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '      LAST_UPDATE_DATE = "' ||
                to_char(l_regions_rec.last_update_date,
                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '      LAST_UPDATE_LOGIN = "' ||
                nvl(to_char(l_regions_rec.last_update_login),'') || '"';


      -- - Write flow page region data out to the specified file
      AK_ON_OBJECTS_PVT.WRITE_FILE (
        p_return_status => l_return_status,
        p_buffer_tbl => l_databuffer_tbl,
        p_write_mode => AK_ON_OBJECTS_PUB.G_APPEND
      );
      -- If API call returns with an error status...
      if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
         (l_return_status = FND_API.G_RET_STS_ERROR) then
	close l_get_regions_csr;
        RAISE FND_API.G_EXC_ERROR;
      end if;

      l_databuffer_tbl.delete;

      -- Load region items (AK_FLOW_PAGE_REGION_ITEMS)
      WRITE_ITEMS_TO_BUFFER (
        p_validation_level => p_validation_level,
        p_return_status => l_return_status,
        p_flow_application_id => p_flow_application_id,
        p_flow_code => p_flow_code,
        p_page_application_id => p_page_application_id,
        p_page_code => p_page_code,
        p_region_application_id => l_regions_rec.region_application_id,
        p_region_code => l_regions_rec.region_code
      );

      -- Download should abort if validation fails
	  --
      if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
        (l_return_status = FND_API.G_RET_STS_ERROR) then
       close l_get_regions_csr;
       RAISE FND_API.G_EXC_ERROR;
      end if;

      -- finish up flow page region
      l_index := 1;
      l_databuffer_tbl(l_index) := '    END FLOW_PAGE_REGION';
      l_index := l_index + 1;
      l_databuffer_tbl(l_index) := ' ';
    end if; -- validation OK

    -- - Finish up writing object data out to the specified file
    AK_ON_OBJECTS_PVT.WRITE_FILE (
      p_return_status => l_return_status,
      p_buffer_tbl => l_databuffer_tbl,
      p_write_mode => AK_ON_OBJECTS_PUB.G_APPEND
    );
    -- If API call returns with an error status...
    if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
       (l_return_status = FND_API.G_RET_STS_ERROR) then
      close l_get_regions_csr;
      RAISE FND_API.G_EXC_ERROR;
    end if;

    l_databuffer_tbl.delete;

  end loop;
  close l_get_regions_csr;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN VALUE_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_PG_REGION_VALUE_ERROR');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
                   ' ' || p_flow_code ||
                   ' ' || to_char(p_page_application_id) ||
                   ' ' || p_page_code ||
                   ' ' || to_char(l_regions_rec.region_application_id) ||
                   ' ' || l_regions_rec.region_code );
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;
end WRITE_REGIONS_TO_BUFFER;

--=======================================================
--  Procedure   WRITE_PAGES_TO_BUFFER (local procedure)
--
--  Usage       Local procedure for writing all flow page
--              records for the given flow to the output file.
--              Not designed to be called from outside this package.
--
--  Desc        This procedure retrieves all Flow Page
--              records for the given Flow, as well as all the
--              all Flow Page Region and Flow Page Region Item
--              records for these Flow Pages, from the database and
--              writes them to the output file in loader file format.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters
--              p_flow_application_id : IN required
--              p_flow_code : IN required
--                  Key value of the Flow record whose Flow Page
--                  Region records are to be extracted to the loader file.
--              p_nls_language : IN required
--                  The NLS langauge that should be used when
--                  extracting data from the TL table
--=======================================================
procedure WRITE_PAGES_TO_BUFFER (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_flow_application_id      IN      NUMBER,
  p_flow_code                IN      VARCHAR2,
  p_nls_language             IN      VARCHAR2
) is
  cursor l_get_pages_csr is
    select *
    from   AK_FLOW_PAGES
    where  FLOW_APPLICATION_ID = p_flow_application_id
    and    FLOW_CODE = p_flow_code;
  cursor l_get_page_tl_csr (page_appl_id_param number,
                            page_code_param varchar2) is
    select *
    from   AK_FLOW_PAGES_TL
    where  FLOW_APPLICATION_ID = p_flow_application_id
    and    FLOW_CODE = p_flow_code
    and    PAGE_APPLICATION_ID = page_appl_id_param
    and    PAGE_CODE = page_code_param
    and    LANGUAGE = p_nls_language;
  l_api_name           CONSTANT varchar2(30) := 'Write_Pages_to_buffer';
  l_databuffer_tbl     AK_ON_OBJECTS_PUB.Buffer_Tbl_Type;
  l_index              NUMBER;
  l_pages_rec          AK_FLOW_PAGES%ROWTYPE;
  l_pages_tl_rec       AK_FLOW_PAGES_TL%ROWTYPE;
  l_return_status      varchar2(1);
begin
  -- Find out where the next buffer entry to be written to
  l_index := 1;

  -- Retrieve flow pages and its TL information from the database

  open l_get_pages_csr;
  loop
    fetch l_get_pages_csr into l_pages_rec;
    exit when l_get_pages_csr%notfound;
--dbms_output.put_line('flow page is ' || to_char(p_flow_application_id) || ' '
--                         || p_flow_code || ' ' ||
--                         to_char(l_pages_rec.page_application_id)
--                                || ' ' || l_pages_rec.page_code);

    open l_get_page_tl_csr(l_pages_rec.page_application_id,
                           l_pages_rec.page_code);
    fetch l_get_page_tl_csr into l_pages_tl_rec;
    if l_get_page_tl_csr%found then

    -- write this flow page if it is validated
      if (p_validation_level <> FND_API.G_VALID_LEVEL_NONE) and
          not AK_FLOW3_PVT.VALIDATE_PAGE (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_flow_application_id => p_flow_application_id,
            p_flow_code => p_flow_code,
            p_page_application_id => l_pages_rec.page_application_id,
            p_page_code => l_pages_rec.page_code,
            p_primary_region_appl_id => l_pages_rec.primary_region_appl_id,
            p_primary_region_code => l_pages_rec.primary_region_code,
            p_name => l_pages_tl_rec.name,
            p_description => l_pages_tl_rec.description,
            p_caller => AK_ON_OBJECTS_PVT.G_DOWNLOAD)
      then
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
          FND_MESSAGE.SET_NAME('AK','AK_FLOW_PAGE_NOT_DOWNLOADED');
          FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
                   ' ' || p_flow_code ||
                   ' ' || to_char(l_pages_rec.page_application_id) ||
                   ' ' || l_pages_rec.page_code );
          FND_MSG_PUB.Add;
        end if;
	close l_get_page_tl_csr;
	close l_get_pages_csr;
        RAISE FND_API.G_EXC_ERROR;
      else
        l_databuffer_tbl(l_index) := ' ';
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '  BEGIN FLOW_PAGE "' ||
          nvl(to_char(l_pages_rec.page_application_id),'') || '" "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_pages_rec.page_code)
          || '"';
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '    PRIMARY_REGION = "' ||
          nvl(to_char(l_pages_rec.primary_region_appl_id),'')||'" "'||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                                l_pages_rec.primary_region_code) ||'"';
      -- Flex Fields
      --
      if ((l_pages_rec.attribute_category IS NOT NULL) and
         (l_pages_rec.attribute_category <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '    ATTRIBUTE_CATEGORY = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_pages_rec.attribute_category) || '"';
      end if;
      if ((l_pages_rec.attribute1 IS NOT NULL) and
         (l_pages_rec.attribute1 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '    ATTRIBUTE1 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_pages_rec.attribute1) || '"';
      end if;
      if ((l_pages_rec.attribute2 IS NOT NULL) and
         (l_pages_rec.attribute2 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '    ATTRIBUTE2 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_pages_rec.attribute2) || '"';
      end if;
      if ((l_pages_rec.attribute3 IS NOT NULL) and
         (l_pages_rec.attribute3 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '    ATTRIBUTE3 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_pages_rec.attribute3) || '"';
      end if;
      if ((l_pages_rec.attribute4 IS NOT NULL) and
         (l_pages_rec.attribute4 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '    ATTRIBUTE4 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_pages_rec.attribute4) || '"';
      end if;
      if ((l_pages_rec.attribute5 IS NOT NULL) and
         (l_pages_rec.attribute5 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '    ATTRIBUTE5 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_pages_rec.attribute5) || '"';
      end if;
      if ((l_pages_rec.attribute6 IS NOT NULL) and
         (l_pages_rec.attribute6 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '    ATTRIBUTE6 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_pages_rec.attribute6) || '"';
      end if;
      if ((l_pages_rec.attribute7 IS NOT NULL) and
         (l_pages_rec.attribute7 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '    ATTRIBUTE7 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_pages_rec.attribute7) || '"';
      end if;
      if ((l_pages_rec.attribute8 IS NOT NULL) and
         (l_pages_rec.attribute8 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '    ATTRIBUTE8 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_pages_rec.attribute8) || '"';
      end if;
      if ((l_pages_rec.attribute9 IS NOT NULL) and
         (l_pages_rec.attribute9 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '    ATTRIBUTE9 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_pages_rec.attribute9) || '"';
      end if;
      if ((l_pages_rec.attribute10 IS NOT NULL) and
         (l_pages_rec.attribute10 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '    ATTRIBUTE10 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_pages_rec.attribute10) || '"';
      end if;
      if ((l_pages_rec.attribute11 IS NOT NULL) and
         (l_pages_rec.attribute11 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '    ATTRIBUTE11 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_pages_rec.attribute11) || '"';
      end if;
      if ((l_pages_rec.attribute12 IS NOT NULL) and
         (l_pages_rec.attribute12 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '    ATTRIBUTE12 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_pages_rec.attribute12) || '"';
      end if;
      if ((l_pages_rec.attribute13 IS NOT NULL) and
         (l_pages_rec.attribute13 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '    ATTRIBUTE13 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_pages_rec.attribute13) || '"';
      end if;
      if ((l_pages_rec.attribute14 IS NOT NULL) and
         (l_pages_rec.attribute14 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '    ATTRIBUTE14 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_pages_rec.attribute14) || '"';
      end if;
      if ((l_pages_rec.attribute15 IS NOT NULL) and
         (l_pages_rec.attribute15 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '    ATTRIBUTE15 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_pages_rec.attribute15) || '"';
      end if;
  -- - Write out who columns
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '    CREATED_BY = "' ||
                nvl(to_char(l_pages_rec.created_by),'') || '"';
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '    CREATION_DATE = "' ||
                to_char(l_pages_rec.creation_date,
                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
    l_index := l_index + 1;
-- CHANGED TO OWNER FOR R12
--    l_databuffer_tbl(l_index) := '    LAST_UPDATED_BY = "' ||
--                nvl(to_char(l_pages_rec.last_updated_by),'') || '"';
    l_databuffer_tbl(l_index) := '    OWNER = "' ||
                FND_LOAD_UTIL.OWNER_NAME(l_pages_rec.last_updated_by) || '"';
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '    LAST_UPDATE_DATE = "' ||
                to_char(l_pages_rec.last_update_date,
                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '    LAST_UPDATE_LOGIN = "' ||
                nvl(to_char(l_pages_rec.last_update_login),'') || '"';

        if ((l_pages_tl_rec.name IS NOT NULL) and
           (l_pages_tl_rec.name <> FND_API.G_MISS_CHAR)) then
          l_index := l_index + 1;
          l_databuffer_tbl(l_index) := '    NAME = "' ||
            AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_pages_tl_rec.name) || '"';
        end if;
        if ((l_pages_tl_rec.description IS NOT NULL) and
           (l_pages_tl_rec.description <> FND_API.G_MISS_CHAR)) then
          l_index := l_index + 1;
          l_databuffer_tbl(l_index) := '    DESCRIPTION = "' ||
            AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_pages_tl_rec.description)
            || '"';
        end if;

        -- - Write flow page data out to the specified file
        AK_ON_OBJECTS_PVT.WRITE_FILE (
          p_return_status => l_return_status,
          p_buffer_tbl => l_databuffer_tbl,
          p_write_mode => AK_ON_OBJECTS_PUB.G_APPEND
        );
        -- If API call returns with an error status...
        if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
           (l_return_status = FND_API.G_RET_STS_ERROR) then
	  close l_get_page_tl_csr;
	  close l_get_pages_csr;
          RAISE FND_API.G_EXC_ERROR;
        end if;

        l_databuffer_tbl.delete;

        -- Load Page regions (AK_FLOW_PAGE_REGIONS) and their page region
        -- item (AK_FLOW_PAGE_REGION_ITEMS)
        WRITE_REGIONS_TO_BUFFER (
          p_validation_level => p_validation_level,
          p_return_status => l_return_status,
          p_flow_application_id => p_flow_application_id,
          p_flow_code => p_flow_code,
          p_page_application_id => l_pages_rec.page_application_id,
          p_page_code => l_pages_rec.page_code
        );
        --
        -- Download aborts if validation fails in WRITE_REGIONS_TO_BUFFER
	    --
        if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
          (l_return_status = FND_API.G_RET_STS_ERROR) then
	  close l_get_page_tl_csr;
	  close l_get_pages_csr;
          RAISE FND_API.G_EXC_ERROR;
        end if;

        -- finish up flow page
        l_index := 1;
        l_databuffer_tbl(l_index) := '  END FLOW_PAGE';
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := ' ';
      end if; -- validation OK --

      -- - Finish up writing flow page data out to the specified file
      AK_ON_OBJECTS_PVT.WRITE_FILE (
        p_return_status => l_return_status,
        p_buffer_tbl => l_databuffer_tbl,
        p_write_mode => AK_ON_OBJECTS_PUB.G_APPEND
      );
      -- If API call returns with an error status...
      if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
         (l_return_status = FND_API.G_RET_STS_ERROR) then
	close l_get_page_tl_csr;
	close l_get_pages_csr;
        RAISE FND_API.G_EXC_ERROR;
      end if;

      l_databuffer_tbl.delete;

    end if;  -- if TL record found --
    close l_get_page_tl_csr;
  end loop;
  close l_get_pages_csr;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN VALUE_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_FLOW_PAGE_VALUE_ERROR');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
                   ' ' || p_flow_code ||
                   ' ' || to_char(l_pages_rec.page_application_id) ||
                   ' ' || l_pages_rec.page_code );
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;
end WRITE_PAGES_TO_BUFFER;

--=======================================================
--  Procedure   WRITE_RELATIONS_TO_BUFFER (local procedure)
--
--  Usage       Local procedure for writing all interpage flow region
--              relation records for the given flow to the output file.
--              Not designed to be called from outside this package.
--
--  Desc        This procedure retrieves all interpage Flow Region Relation
--              records for the given Flow from the database and
--              writes them to the output file in loader file format.
--              Note: All intrapage region relations will be written along
--              with flow page regions information.
--
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters
--              p_flow_application_id : IN required
--              p_flow_code : IN required
--                  Key value of the Flow record whose Flow Region
--                  Relation records are to be extracted to the loader file.
--=======================================================
procedure WRITE_RELATIONS_TO_BUFFER (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_flow_application_id      IN      NUMBER,
  p_flow_code                IN      VARCHAR2
) is
  cursor l_get_relations_csr is
    select *
    from   AK_FLOW_REGION_RELATIONS
    where  FLOW_APPLICATION_ID = p_flow_application_id
    and    FLOW_CODE = p_flow_code
    and    ( (FROM_PAGE_APPL_ID <> TO_PAGE_APPL_ID) or
             (FROM_PAGE_CODE <> TO_PAGE_CODE) );
  l_api_name           CONSTANT varchar2(30) := 'Write_Relations_to_buffer';
  l_databuffer_tbl     AK_ON_OBJECTS_PUB.Buffer_Tbl_Type;
  l_index              NUMBER;
  l_relations_rec      AK_FLOW_REGION_RELATIONS%ROWTYPE;
  l_return_status      varchar2(1);
begin
  -- Find out where the next buffer entry to be written to
  l_index := 1;

  -- Retrieve region relations information from the database

  open l_get_relations_csr;
  loop
    fetch l_get_relations_csr into l_relations_rec;
    exit when l_get_relations_csr%notfound;
    -- write this flow region relation if it is validated
    if (p_validation_level <> FND_API.G_VALID_LEVEL_NONE) and
          not AK_FLOW3_PVT.VALIDATE_REGION_RELATION (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_flow_application_id => p_flow_application_id,
            p_flow_code => p_flow_code,
            p_foreign_key_name => l_relations_rec.foreign_key_name,
            p_from_page_appl_id => l_relations_rec.from_page_appl_id,
            p_from_page_code => l_relations_rec.from_page_code,
            p_from_region_appl_id => l_relations_rec.from_region_appl_id,
            p_from_region_code => l_relations_rec.from_region_code,
            p_to_page_appl_id => l_relations_rec.to_page_appl_id,
            p_to_page_code => l_relations_rec.to_page_code,
            p_to_region_appl_id => l_relations_rec.to_region_appl_id,
            p_to_region_code => l_relations_rec.to_region_code,
            p_application_id => l_relations_rec.application_id,
            p_caller => AK_ON_OBJECTS_PVT.G_DOWNLOAD)
    then
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
          FND_MESSAGE.SET_NAME('AK','AK_RELATION_NOT_DOWNLOADED');
          FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
                          ' ' || p_flow_code ||
                          ' ' || l_relations_rec.foreign_key_name ||
                          ' ' || to_char(l_relations_rec.from_page_appl_id) ||
                          ' ' || l_relations_rec.from_page_code ||
                          ' ' || to_char(l_relations_rec.from_region_appl_id)||
                          ' ' || l_relations_rec.from_region_code ||
                          ' ' || to_char(l_relations_rec.to_page_appl_id) ||
                          ' ' || l_relations_rec.to_page_code ||
                          ' ' || to_char(l_relations_rec.to_region_appl_id) ||
                          ' ' || l_relations_rec.to_region_code);
         FND_MSG_PUB.Add;
        end if;
	close l_get_relations_csr;
        RAISE FND_API.G_EXC_ERROR;
    else
      l_databuffer_tbl(l_index) := ' ';
      l_index := l_index + 1;
      l_databuffer_tbl(l_index) := '  BEGIN FLOW_REGION_RELATION "' ||
       AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_relations_rec.foreign_key_name)
       || '" "' ||
       nvl(to_char(l_relations_rec.from_page_appl_id),'') || '" "' ||
       AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_relations_rec.from_page_code)
        || '" "' ||
       nvl(to_char(l_relations_rec.from_region_appl_id),'') || '" "' ||
       AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_relations_rec.from_region_code)
        || '" "' ||
       nvl(to_char(l_relations_rec.to_page_appl_id),'') || '" "' ||
       AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_relations_rec.to_page_code)
        || '" "' ||
       nvl(to_char(l_relations_rec.to_region_appl_id),'') || '" "' ||
       AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_relations_rec.to_region_code)
        || '"';
      l_index := l_index + 1;
      l_databuffer_tbl(l_index) := '    APPLICATION_ID = "' ||
        nvl(to_char(l_relations_rec.application_id),'') || '"';
      -- Flex Fields
      --
      if ((l_relations_rec.attribute_category IS NOT NULL) and
         (l_relations_rec.attribute_category <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '    ATTRIBUTE_CATEGORY = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_relations_rec.attribute_category) || '"';
      end if;
      if ((l_relations_rec.attribute1 IS NOT NULL) and
         (l_relations_rec.attribute1 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '    ATTRIBUTE1 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_relations_rec.attribute1) || '"';
      end if;
      if ((l_relations_rec.attribute2 IS NOT NULL) and
         (l_relations_rec.attribute2 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '    ATTRIBUTE2 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_relations_rec.attribute2) || '"';
      end if;
      if ((l_relations_rec.attribute3 IS NOT NULL) and
         (l_relations_rec.attribute3 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '    ATTRIBUTE3 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_relations_rec.attribute3) || '"';
      end if;
      if ((l_relations_rec.attribute4 IS NOT NULL) and
         (l_relations_rec.attribute4 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '    ATTRIBUTE4 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_relations_rec.attribute4) || '"';
      end if;
      if ((l_relations_rec.attribute5 IS NOT NULL) and
         (l_relations_rec.attribute5 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '    ATTRIBUTE5 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_relations_rec.attribute5) || '"';
      end if;
      if ((l_relations_rec.attribute6 IS NOT NULL) and
         (l_relations_rec.attribute6 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '    ATTRIBUTE6 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_relations_rec.attribute6) || '"';
      end if;
      if ((l_relations_rec.attribute7 IS NOT NULL) and
         (l_relations_rec.attribute7 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '    ATTRIBUTE7 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_relations_rec.attribute7) || '"';
      end if;
      if ((l_relations_rec.attribute8 IS NOT NULL) and
         (l_relations_rec.attribute8 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '    ATTRIBUTE8 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_relations_rec.attribute8) || '"';
      end if;
      if ((l_relations_rec.attribute9 IS NOT NULL) and
         (l_relations_rec.attribute9 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '    ATTRIBUTE9 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_relations_rec.attribute9) || '"';
      end if;
      if ((l_relations_rec.attribute10 IS NOT NULL) and
         (l_relations_rec.attribute10 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '    ATTRIBUTE10 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_relations_rec.attribute10) || '"';
      end if;
      if ((l_relations_rec.attribute11 IS NOT NULL) and
         (l_relations_rec.attribute11 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '    ATTRIBUTE11 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_relations_rec.attribute11) || '"';
      end if;
      if ((l_relations_rec.attribute12 IS NOT NULL) and
         (l_relations_rec.attribute12 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '    ATTRIBUTE12 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_relations_rec.attribute12) || '"';
      end if;
      if ((l_relations_rec.attribute13 IS NOT NULL) and
         (l_relations_rec.attribute13 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '    ATTRIBUTE13 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_relations_rec.attribute13) || '"';
      end if;
      if ((l_relations_rec.attribute14 IS NOT NULL) and
         (l_relations_rec.attribute14 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '    ATTRIBUTE14 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_relations_rec.attribute14) || '"';
      end if;
      if ((l_relations_rec.attribute15 IS NOT NULL) and
         (l_relations_rec.attribute15 <> FND_API.G_MISS_CHAR)) then
        l_index := l_index + 1;
        l_databuffer_tbl(l_index) := '    ATTRIBUTE15 = "' ||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                     l_relations_rec.attribute15) || '"';
      end if;
  -- - Write out who columns
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '    CREATED_BY = "' ||
                nvl(to_char(l_relations_rec.created_by),'') || '"';
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '    CREATION_DATE = "' ||
                to_char(l_relations_rec.creation_date,
                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
    l_index := l_index + 1;
-- CHANGED TO OWNER FOR R12
--    l_databuffer_tbl(l_index) := '    LAST_UPDATED_BY = "' ||
--                nvl(to_char(l_relations_rec.last_updated_by),'') || '"';
    l_databuffer_tbl(l_index) := '    OWNER = "' ||
                FND_LOAD_UTIL.OWNER_NAME(l_relations_rec.last_updated_by) || '"';
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '    LAST_UPDATE_DATE = "' ||
                to_char(l_relations_rec.last_update_date,
                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '    LAST_UPDATE_LOGIN = "' ||
                nvl(to_char(l_relations_rec.last_update_login),'') || '"';


      -- finish up flow region relations
      l_index := l_index + 1;
      l_databuffer_tbl(l_index) := '  END FLOW_REGION_RELATION';
      l_index := l_index + 1;
      l_databuffer_tbl(l_index) := ' ';
    end if; -- validation OK --

  end loop;

  -- - Write relation data out to the specified file
  --   don't call write_file if there is no data to be written
  if (l_databuffer_tbl.count > 0) then
    AK_ON_OBJECTS_PVT.WRITE_FILE (
      p_return_status => l_return_status,
      p_buffer_tbl => l_databuffer_tbl,
      p_write_mode => AK_ON_OBJECTS_PUB.G_APPEND
    );
    -- If API call returns with an error status...
    if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
       (l_return_status = FND_API.G_RET_STS_ERROR) then
      close l_get_relations_csr;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  end if;

  close l_get_relations_csr;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN VALUE_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_RELATION_VALUE_ERROR');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
                          ' ' || p_flow_code ||
                          ' ' || l_relations_rec.foreign_key_name ||
                          ' ' || to_char(l_relations_rec.from_page_appl_id) ||
                          ' ' || l_relations_rec.from_page_code ||
                          ' ' || to_char(l_relations_rec.from_region_appl_id)||
                          ' ' || l_relations_rec.from_region_code ||
                          ' ' || to_char(l_relations_rec.to_page_appl_id) ||
                          ' ' || l_relations_rec.to_page_code ||
                          ' ' || to_char(l_relations_rec.to_region_appl_id) ||
                          ' ' || l_relations_rec.to_region_code);
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;
end WRITE_RELATIONS_TO_BUFFER;

--=======================================================
--  Procedure   WRITE_TO_BUFFER (local procedure)
--
--  Usage       Local procedure for writing the given flow
--              and all its children records to the output file.
--              Not designed to be called from outside this package.
--
--  Desc        This procedure first retrieves and writes the given
--              flow to the loader file. Then it calls other local
--              procedures to write all its flow pages, flow page
--              regions, flow page region items, and flow region
--              relations to the same output file.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters
--              p_database_object_name : IN required
--                  Key value of the Object to be extracted to the loader
--                  file.
--              p_nls_language : IN required
--                  The NLS langauge that should be used when
--                  extracting data from the TL table
--=======================================================
procedure WRITE_TO_BUFFER (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_flow_application_id      IN      NUMBER,
  p_flow_code                IN      VARCHAR2,
  p_nls_language             IN      VARCHAR2
) is
  cursor l_get_flow_csr is
    select *
    from  AK_FLOWS
    where flow_application_id = p_flow_application_id
    and   flow_code = p_flow_code;
  cursor l_get_flow_tl_csr is
    select *
    from  AK_FLOWS_TL
    where flow_application_id = p_flow_application_id
    and   flow_code = p_flow_code
    and   LANGUAGE = p_nls_language;
  l_api_name           CONSTANT varchar2(30) := 'Write_to_buffer';
  l_databuffer_tbl     AK_ON_OBJECTS_PUB.Buffer_Tbl_Type;
  l_index              NUMBER;
  l_flows_rec          AK_FLOWS%ROWTYPE;
  l_flows_tl_rec       AK_FLOWS_TL%ROWTYPE;
  l_return_status      varchar2(1);
begin
  -- Retrieve flow information from the database

  open l_get_flow_csr;
  fetch l_get_flow_csr into l_flows_rec;
  if (l_get_flow_csr%notfound) then
    close l_get_flow_csr;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
      FND_MESSAGE.SET_NAME('AK','AK_FLOW_DOES_NOT_EXIST');
      FND_MSG_PUB.Add;
    end if;
    RAISE FND_API.G_EXC_ERROR;
  end if;
  close l_get_flow_csr;

  open l_get_flow_tl_csr;
  fetch l_get_flow_tl_csr into l_flows_tl_rec;
  if (l_get_flow_tl_csr%notfound) then
    close l_get_flow_tl_csr;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
      FND_MESSAGE.SET_NAME('AK','AK_FLOW_DOES_NOT_EXIST');
      FND_MSG_PUB.Add;
    end if;
    RAISE FND_API.G_EXC_ERROR;
  end if;
  close l_get_flow_tl_csr;

  -- Flow must be validated before it is written to the file
  if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
    if not AK_FLOW3_PVT.VALIDATE_FLOW (
	p_validation_level => p_validation_level,
	p_api_version_number => 1.0,
	p_return_status => l_return_status,
        p_flow_application_id => l_flows_rec.flow_application_id,
        p_flow_code => l_flows_rec.flow_code,
        p_primary_page_appl_id => l_flows_rec.primary_page_appl_id,
        p_primary_page_code => l_flows_rec.primary_page_code,
        p_name => l_flows_tl_rec.name,
        p_description => l_flows_tl_rec.description,
 	p_caller => AK_ON_OBJECTS_PVT.G_DOWNLOAD)
    then
      raise FND_API.G_EXC_ERROR;
    end if;
  end if;

  -- Write flow into buffer
  l_index := 1;

  l_databuffer_tbl(l_index) := 'BEGIN FLOW "' ||
     nvl(to_char(l_flows_rec.flow_application_id),'') || '" "' ||
     AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_flows_rec.flow_code) || '"';
  l_index := l_index + 1;
  l_databuffer_tbl(l_index) := '  PRIMARY_PAGE = "' ||
    nvl(to_char(l_flows_rec.primary_page_appl_id),'')||'" "'||
    AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_flows_rec.primary_page_code)||'"';
  -- Flex Fields
  --
  if ((l_flows_rec.attribute_category IS NOT NULL) and
     (l_flows_rec.attribute_category <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  ATTRIBUTE_CATEGORY = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                 l_flows_rec.attribute_category) || '"';
  end if;
  if ((l_flows_rec.attribute1 IS NOT NULL) and
     (l_flows_rec.attribute1 <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  ATTRIBUTE1 = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                 l_flows_rec.attribute1) || '"';
  end if;
  if ((l_flows_rec.attribute2 IS NOT NULL) and
     (l_flows_rec.attribute2 <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  ATTRIBUTE2 = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                 l_flows_rec.attribute2) || '"';
  end if;
  if ((l_flows_rec.attribute3 IS NOT NULL) and
     (l_flows_rec.attribute3 <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  ATTRIBUTE3 = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                 l_flows_rec.attribute3) || '"';
  end if;
  if ((l_flows_rec.attribute4 IS NOT NULL) and
     (l_flows_rec.attribute4 <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  ATTRIBUTE4 = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                 l_flows_rec.attribute4) || '"';
  end if;
  if ((l_flows_rec.attribute5 IS NOT NULL) and
     (l_flows_rec.attribute5 <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  ATTRIBUTE5 = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                 l_flows_rec.attribute5) || '"';
  end if;
  if ((l_flows_rec.attribute6 IS NOT NULL) and
     (l_flows_rec.attribute6 <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  ATTRIBUTE6 = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                 l_flows_rec.attribute6) || '"';
  end if;
  if ((l_flows_rec.attribute7 IS NOT NULL) and
     (l_flows_rec.attribute7 <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  ATTRIBUTE7 = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                 l_flows_rec.attribute7) || '"';
  end if;
  if ((l_flows_rec.attribute8 IS NOT NULL) and
     (l_flows_rec.attribute8 <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  ATTRIBUTE8 = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                 l_flows_rec.attribute8) || '"';
  end if;
  if ((l_flows_rec.attribute9 IS NOT NULL) and
     (l_flows_rec.attribute9 <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  ATTRIBUTE9 = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                 l_flows_rec.attribute9) || '"';
  end if;
  if ((l_flows_rec.attribute10 IS NOT NULL) and
     (l_flows_rec.attribute10 <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  ATTRIBUTE10 = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                 l_flows_rec.attribute10) || '"';
  end if;
  if ((l_flows_rec.attribute11 IS NOT NULL) and
     (l_flows_rec.attribute11 <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  ATTRIBUTE11 = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                 l_flows_rec.attribute11) || '"';
  end if;
  if ((l_flows_rec.attribute12 IS NOT NULL) and
     (l_flows_rec.attribute12 <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  ATTRIBUTE12 = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                 l_flows_rec.attribute12) || '"';
  end if;
  if ((l_flows_rec.attribute13 IS NOT NULL) and
     (l_flows_rec.attribute13 <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  ATTRIBUTE13 = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                 l_flows_rec.attribute13) || '"';
  end if;
  if ((l_flows_rec.attribute14 IS NOT NULL) and
     (l_flows_rec.attribute14 <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  ATTRIBUTE14 = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                 l_flows_rec.attribute14) || '"';
  end if;
  if ((l_flows_rec.attribute15 IS NOT NULL) and
     (l_flows_rec.attribute15 <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  ATTRIBUTE15 = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                 l_flows_rec.attribute15) || '"';
  end if;
  -- - Write out who columns
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  CREATED_BY = "' ||
                nvl(to_char(l_flows_rec.created_by),'') || '"';
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  CREATION_DATE = "' ||
                to_char(l_flows_rec.creation_date,
                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
    l_index := l_index + 1;
-- CHANGED TO OWNER FOR R12
--    l_databuffer_tbl(l_index) := '  LAST_UPDATED_BY = "' ||
--                nvl(to_char(l_flows_rec.last_updated_by),'') || '"';
    l_databuffer_tbl(l_index) := '  OWNER = "' ||
                FND_LOAD_UTIL.OWNER_NAME(l_flows_rec.last_updated_by) || '"';
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  LAST_UPDATE_DATE = "' ||
                to_char(l_flows_rec.last_update_date,
                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  LAST_UPDATE_LOGIN = "' ||
                nvl(to_char(l_flows_rec.last_update_login),'') || '"';

  -- translation columns
  --
  if (l_flows_tl_rec.name IS NOT NULL) and
     (l_flows_tl_rec.name <> FND_API.G_MISS_CHAR) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  NAME = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_flows_tl_rec.name) || '"';
  end if;
  if ((l_flows_tl_rec.description IS NOT NULL) and
     (l_flows_tl_rec.description <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  DESCRIPTION = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_flows_tl_rec.description) || '"';
  end if;

  -- - Write flow data out to the specified file
  AK_ON_OBJECTS_PVT.WRITE_FILE (
    p_return_status => l_return_status,
    p_buffer_tbl => l_databuffer_tbl,
    p_write_mode => AK_ON_OBJECTS_PUB.G_APPEND
  );
--  dbms_output.put_line('after write file');
  -- If API call returns with an error status...
  if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
     (l_return_status = FND_API.G_RET_STS_ERROR) then
    RAISE FND_API.G_EXC_ERROR;
  end if;

  l_databuffer_tbl.delete;

  WRITE_PAGES_TO_BUFFER (
    p_validation_level => p_validation_level,
    p_return_status => l_return_status,
    p_flow_application_id => p_flow_application_id,
    p_flow_code => p_flow_code,
    p_nls_language => p_nls_language
  );
  if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
     (l_return_status = FND_API.G_RET_STS_ERROR) then
    RAISE FND_API.G_EXC_ERROR;
  end if;

  WRITE_RELATIONS_TO_BUFFER (
    p_validation_level => p_validation_level,
    p_return_status => l_return_status,
    p_flow_application_id => p_flow_application_id,
    p_flow_code => p_flow_code
  );
  if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
     (l_return_status = FND_API.G_RET_STS_ERROR) then
    RAISE FND_API.G_EXC_ERROR;
  end if;

  l_index := 1;
  l_databuffer_tbl(l_index) := 'END FLOW';
  l_index := l_index + 1;
  l_databuffer_tbl(l_index) := ' ';

  -- - Finish up writing flow data out to the specified file
  AK_ON_OBJECTS_PVT.WRITE_FILE (
    p_return_status => l_return_status,
    p_buffer_tbl => l_databuffer_tbl,
    p_write_mode => AK_ON_OBJECTS_PUB.G_APPEND
  );
  -- If API call returns with an error status...
  if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
     (l_return_status = FND_API.G_RET_STS_ERROR) then
    RAISE FND_API.G_EXC_ERROR;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN VALUE_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_FLOW_VALUE_ERROR');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
                          ' ' || p_flow_code);
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_FLOW_NOT_DOWNLOADED');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
                          ' ' || p_flow_code);
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;
end WRITE_TO_BUFFER;

--=======================================================
--  Procedure   DOWNLOAD_FLOW
--
--  Usage       Private API for downloading flows. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API will extract the flows selected
--              by application ID or by key values from the
--              database to the output file.
--              If a flow is selected for writing to the loader
--              file, all its children records (including flow pages,
--              flow page regions, flow page region items, and flow
--              region relations) will also be written.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters
--              p_nls_language : IN optional
--                  NLS language for database. If none if given,
--                  the current NLS language will be used.
--
--              One of the following parameters must be provided:
--
--              p_application_id : IN optional
--                  If given, all attributes for this application ID
--                  will be written to the output file.
--                  p_application_id will be ignored if a table is
--                  given in p_flow_pk_tbl.
--              p_flow_pk_tbl : IN optional
--                  If given, only flows whose key values are
--                  included in this table will be written to the
--                  output file.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure DOWNLOAD_FLOW (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_application_id           IN      NUMBER := FND_API.G_MISS_NUM,
  p_flow_pk_tbl              IN      AK_FLOW_PUB.Flow_PK_Tbl_Type
                                     := AK_FLOW_PUB.G_MISS_FLOW_PK_TBL,
  p_nls_language             IN      VARCHAR2
) is
  cursor l_get_flow_list_csr (appl_id_parm number) is
    select flow_application_id, flow_code
    from   AK_FLOWS
    where  FLOW_APPLICATION_ID = appl_id_parm;
  cursor l_get_regions_csr (flow_appl_id_param number,
                            flow_code_param varchar2) is
    select distinct REGION_APPLICATION_ID, REGION_CODE
    from   AK_FLOW_PAGE_REGIONS
    where  flow_application_id = flow_appl_id_param
    and    flow_code = flow_code_param;
  l_api_version_number CONSTANT number := 1.0;
  l_api_name           CONSTANT varchar2(30) := 'Download_Flow';
  l_index              NUMBER;
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(2000);
  l_flow_pk_tbl        AK_FLOW_PUB.Flow_PK_Tbl_Type;
  l_region_appl_id     NUMBER(15);
  l_region_code        VARCHAR2(30);
  l_region_pk_tbl      AK_REGION_PUB.Region_PK_Tbl_Type;
  l_return_status      varchar2(1);
begin
  IF NOT FND_API.Compatible_API_Call (
    l_api_version_number, p_api_version_number, l_api_name,
    G_PKG_NAME) then
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return;
  END IF;


  -- Check that one of the following selection criteria is given:
  -- - p_application_id alone, or
  -- - flow codes in p_flow_PK_tbl
  if (p_application_id = FND_API.G_MISS_NUM) or (p_application_id is null) then
    if (p_flow_PK_tbl.count = 0) then
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.SET_NAME('AK','AK_NO_SELECTION');
        FND_MSG_PUB.Add;
      end if;
      raise FND_API.G_EXC_ERROR;
    end if;
  else
    if (p_flow_PK_tbl.count > 0) then
      -- both application ID and a list of flows to be extracted are
      -- given, issue a warning that we will ignore the application ID
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.SET_NAME('AK','AK_APPL_ID_IGNORED');
        FND_MSG_PUB.Add;
      end if;
    end if;
  end if;

  -- If selecting by application ID, first load a flow primary key table
  -- with the primary key of all flows for the given application ID.
  -- If selecting by a list of flows, simply copy the flow primary key
  -- table with the parameter
  if (p_flow_PK_tbl.count > 0) then
    l_flow_pk_tbl := p_flow_pk_tbl;
  else
    l_index := 1;
    open l_get_flow_list_csr(p_application_id);
    loop
      fetch l_get_flow_list_csr into l_flow_pk_tbl(l_index).flow_appl_id,
                                     l_flow_pk_tbl(l_index).flow_code;
      exit when l_get_flow_list_csr%notfound;
      l_index := l_index + 1;
    end loop;
    close l_get_flow_list_csr;
  end if;

  -- Build list of regions that are need by the flows to be extracted
  -- from the database.
  --
  l_index := l_flow_pk_tbl.FIRST;

  while (l_index is not null) loop
    --
    -- Build list of regions that are referenced by this flow, and
    -- add them to the region list.
    --
    open l_get_regions_csr (
                 l_flow_pk_tbl(l_index).flow_appl_id,
                 l_flow_pk_tbl(l_index).flow_code);
    loop
      fetch l_get_regions_csr into l_region_appl_id, l_region_code;
      exit when (l_get_regions_csr%notfound);
        AK_REGION_PVT.INSERT_REGION_PK_TABLE (
              p_return_status => l_return_status,
              p_region_application_id => l_region_appl_id,
              p_region_code => l_region_code,
              p_region_pk_tbl => l_region_pk_tbl);
    end loop;
    close l_get_regions_csr;

    -- Ready to download the next flow in the list
    l_index := l_flow_pk_tbl.NEXT(l_index);
  end loop;

  -- Download region information for regions that were based on any
  -- of the extracted flows.

  if (l_region_pk_tbl.count > 0) then
    AK_REGION_PVT.DOWNLOAD_REGION (
      p_validation_level => p_validation_level,
      p_api_version_number => 1.0,
      p_return_status => l_return_status,
      p_region_pk_tbl => l_region_pk_tbl,
      p_nls_language => p_nls_language,
      p_get_object_flag => 'Y'    -- Need to get objects for regions
    );
  end if;

  if (l_return_status = FND_API.G_RET_STS_ERROR) or
    (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
	raise FND_API.G_EXC_ERROR;
  end if;


  -- Write details for each selected flow, including its flow pages,
  -- page regions, page region links, and region relations to a
  -- buffer to be passed back to the calling procedure.
  --
  l_index := l_flow_pk_tbl.FIRST;
  while (l_index is not null) loop
    -- Write flow information from the database
    if ( (l_flow_pk_tbl(l_index).flow_appl_id is not null) and
	(l_flow_pk_tbl(l_index).flow_code is not null) ) then
      WRITE_TO_BUFFER(
        p_validation_level => p_validation_level,
        p_return_status => l_return_status,
        p_flow_application_id => l_flow_pk_tbl(l_index).flow_appl_id,
	p_flow_code => l_flow_pk_tbl(l_index).flow_code,
        p_nls_language => p_nls_language
      );
    end if;
    -- Ready to download the next flow in the list
    l_index := l_flow_pk_tbl.NEXT(l_index);
  end loop;

--dbms_output.put_line('returning from ak_flow_pvt.download_flow: ' ||
--                        to_char(sysdate, 'MON-DD HH24:MI:SS'));

--  p_buffer_tbl := l_region_buf_tbl;
    if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
       (l_return_status = FND_API.G_RET_STS_ERROR) then
      RAISE FND_API.G_EXC_ERROR;
    end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN VALUE_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_FLOW_PK_VALUE_ERROR');
      FND_MESSAGE.SET_TOKEN('KEY', null);
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
end DOWNLOAD_FLOW;

--=======================================================
--  Procedure   UPLOAD_FLOW
--
--  Usage       Private API for loading flows from a
--              loader file to the database.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API reads the flow data (including flow pages,
--              flow page regions, flow page region items, and
--              flow region relations) stored in the loader file
--              currently being processed, parses the data, and
--              loads them to the database. The tables
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
procedure UPLOAD_FLOW (
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
  l_api_name                 CONSTANT varchar2(30) := 'Upload_Object';
  l_buffer                   AK_ON_OBJECTS_PUB.Buffer_Type;
  l_column  	             varchar2(30);
  l_dummy                    NUMBER;
  l_eof_flag                 VARCHAR2(1);
  l_flow_index               NUMBER := 0;
  l_flow_rec                 AK_FLOW_PUB.Flow_Rec_Type;
  l_flow_tbl                 AK_FLOW_PUB.Flow_Tbl_Type;
  l_index                    NUMBER;
  l_item_index               NUMBER := 0;
  l_item_rec                 AK_FLOW_PUB.Page_Region_Item_Rec_Type;
  l_item_tbl                 AK_FLOW_PUB.Page_Region_Item_Tbl_Type;
  l_line_num                 NUMBER;
  l_lines_read               NUMBER;
  l_more_flow                BOOLEAN := TRUE;
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(2000);
  l_page_index               NUMBER := 0;
  l_page_rec                 AK_FLOW_PUB.Page_Rec_Type;
  l_page_tbl                 AK_FLOW_PUB.Page_Tbl_Type;
  l_region_index             NUMBER := 0;
  l_region_rec               AK_FLOW_PUB.Page_Region_Rec_Type;
  l_region_tbl               AK_FLOW_PUB.Page_Region_Tbl_Type;
  l_relation_index           NUMBER := 0;
  l_relation_rec             AK_FLOW_PUB.Region_Relation_Rec_Type;
  l_relation_tbl             AK_FLOW_PUB.Region_Relation_Tbl_Type;
  l_saved_token              AK_ON_OBJECTS_PUB.Buffer_Type;
  l_state                    NUMBER;
  l_return_status            varchar2(1);
  l_token                    AK_ON_OBJECTS_PUB.Buffer_Type;
  l_value_count              NUMBER;  -- # of values read for current column
  l_copy_redo_flag           BOOLEAN := FALSE;
  l_user_id1				 NUMBER;
  l_user_id2				 NUMBER;
  l_update1				 DATE;
  l_update2				 DATE;
  l_temp_key_code			 VARCHAR2(30);
  l_temp_key_appl_id		 NUMBER;
begin
  -- dbms_output.put_line('Started flow upload:'  ||
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
  -- the tokens 'BEGIN FLOW' has already been parsed. Set initial
  -- buffer to 'BEGIN FLOW' before reading the next line from the
  -- file. Otherwise, set initial buffer to null.
  --
  if (p_loader_timestamp <> FND_API.G_MISS_DATE) then
    l_buffer := 'BEGIN FLOW ' || p_buffer;
  else
    l_buffer := null;
  end if;

  if (p_line_num = FND_API.G_MISS_NUM) then
    l_line_num := 0;
  else
    l_line_num := p_line_num;
  end if;

  while (l_buffer is null and l_eof_flag = 'N' and p_index <= AK_ON_OBJECTS_PVT.G_UPL_TABLE_NUM) loop
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
        and (l_more_flow) loop

    AK_ON_OBJECTS_PVT.GET_TOKEN(
      p_return_status => l_return_status,
      p_in_buf => l_buffer,
      p_token => l_token
    );
--
--  dbms_output.put_line(' State:' || l_state || ' Token:' || l_token ||
--                     ' value_count:' || nvl(to_char(l_value_count),'null') );

    if (l_return_status = FND_API.G_RET_STS_ERROR) or
       (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.SET_NAME('AK','AK_GET_TOKEN_ERROR');
        FND_MSG_PUB.Add;
      end if;
      -- dbms_output.put_line(l_api_name || 'Error parsing buffer');
      raise FND_API.G_EXC_ERROR;
    end if;

    --****     Flow processing (states 0 - 19)     ****
    if (l_state = 0) then
      if (l_token = 'BEGIN') then
        --== Clear out previous column data  ==--
	l_flow_rec := AK_FLOW_PUB.G_MISS_FLOW_REC;
        l_state := 1;
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
    elsif (l_state = 1) then
      if (l_token = 'FLOW') then
        l_state := 2;
      else
        -- Found the beginning of a non-flow object,
        -- rebuild last line and pass it back to the caller
        -- (ak_on_objects_pvt.upload).
        p_buffer_out := 'BEGIN ' || l_token || ' ' || l_buffer;
        l_more_flow := FALSE;
      end if;
    elsif (l_state = 2) then
      if (l_token is not null) then
        l_flow_rec.flow_application_id := to_number(l_token);
        l_state := 3;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED','FLOW_APPLICATION_ID');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 3) then
      if (l_token is not null) then
        l_flow_rec.flow_code := l_token;
        l_value_count := null;
        l_state := 10;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED','FLOW_CODE');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 10) then
      if (l_token = 'BEGIN') then
        l_state := 13;
      elsif (l_token = 'END') then
        l_state := 19;
      elsif (l_token = 'NAME') or
	    (l_token = 'DESCRIPTION') or
            (l_token = 'PRIMARY_PAGE') or
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
            FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
            FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
            if (l_value_count is null) then
              FND_MESSAGE.SET_TOKEN('TOKEN', l_token);
            else
              FND_MESSAGE.SET_TOKEN('TOKEN',l_saved_token);
            end if;
            FND_MESSAGE.SET_TOKEN('EXPECTED','flow field name, BEGIN, END');
            FND_MSG_PUB.Add;
          end if;
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
      if (l_column = 'NAME') then
         l_flow_rec.name := l_token;
         l_state := 10;
      elsif (l_column = 'DESCRIPTION') then
         l_flow_rec.description := l_token;
         l_state := 10;
      elsif (l_column = 'PRIMARY_PAGE') then
         l_flow_rec.primary_page_appl_id := to_number(l_token);
         l_state := 14;
      elsif (l_column = 'ATTRIBUTE_CATEGORY') then
         l_flow_rec.attribute_category := l_token;
         l_state := 10;
      elsif (l_column = 'ATTRIBUTE1') then
         l_flow_rec.attribute1 := l_token;
         l_state := 10;
      elsif (l_column = 'ATTRIBUTE2') then
         l_flow_rec.attribute2 := l_token;
         l_state := 10;
      elsif (l_column = 'ATTRIBUTE3') then
         l_flow_rec.attribute3 := l_token;
         l_state := 10;
      elsif (l_column = 'ATTRIBUTE4') then
         l_flow_rec.attribute4 := l_token;
         l_state := 10;
      elsif (l_column = 'ATTRIBUTE5') then
         l_flow_rec.attribute5 := l_token;
         l_state := 10;
      elsif (l_column = 'ATTRIBUTE6') then
         l_flow_rec.attribute6 := l_token;
         l_state := 10;
      elsif (l_column = 'ATTRIBUTE7') then
         l_flow_rec.attribute7 := l_token;
         l_state := 10;
      elsif (l_column = 'ATTRIBUTE8') then
         l_flow_rec.attribute8 := l_token;
         l_state := 10;
      elsif (l_column = 'ATTRIBUTE9') then
         l_flow_rec.attribute9 := l_token;
         l_state := 10;
      elsif (l_column = 'ATTRIBUTE10') then
         l_flow_rec.attribute10 := l_token;
         l_state := 10;
      elsif (l_column = 'ATTRIBUTE11') then
         l_flow_rec.attribute11 := l_token;
         l_state := 10;
      elsif (l_column = 'ATTRIBUTE12') then
         l_flow_rec.attribute12 := l_token;
         l_state := 10;
      elsif (l_column = 'ATTRIBUTE13') then
         l_flow_rec.attribute13 := l_token;
         l_state := 10;
      elsif (l_column = 'ATTRIBUTE14') then
         l_flow_rec.attribute14 := l_token;
         l_state := 10;
      elsif (l_column = 'ATTRIBUTE15') then
         l_flow_rec.attribute15 := l_token;
         l_state := 10;
      elsif (l_column = 'CREATED_BY') then
         l_flow_rec.created_by := to_number(l_token);
         l_state := 10;
      elsif (l_column = 'CREATION_DATE') then
         l_flow_rec.creation_date := to_date(l_token,
                                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
         l_state := 10;
      elsif (l_column = 'LAST_UPDATED_BY') then
         l_flow_rec.last_updated_by := to_number(l_token);
         l_state := 10;
      elsif (l_column = 'OWNER') then
 	 l_flow_rec.last_updated_by := FND_LOAD_UTIL.OWNER_ID(l_token);
         l_state := 10;
      elsif (l_column = 'LAST_UPDATE_DATE') then
         l_flow_rec.last_update_date := to_date(l_token,
                                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
         l_state := 10;
      elsif (l_column = 'LAST_UPDATE_LOGIN') then
         l_flow_rec.last_update_login := to_number(l_token);
         l_state := 10;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', l_column);
          FND_MSG_PUB.Add;
        end if;
        --dbms_output.put_line('Expecting ' || l_column || ' value');
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 13) then
      if (l_token = 'FLOW_PAGE') then
        l_state := 20;
      elsif (l_token = 'FLOW_REGION_RELATION') then
        l_state := 40;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED','FLOW_PAGE / FLOW_REGION_RELATION');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
	elsif (l_state = 14) then
	  if (l_column = 'PRIMARY_PAGE') then
         l_flow_rec.primary_page_code := l_token;
         l_state := 10;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', l_column);
          FND_MSG_PUB.Add;
        end if;
        --dbms_output.put_line('Expecting ' || l_column || ' value');
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 19) then
      if (l_token = 'FLOW') then
        l_state := 0;
        l_flow_index := l_flow_index + 1;
        l_flow_tbl(l_flow_index) := l_flow_rec;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'FLOW');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;

    --****     FLOW_PAGE processing (states 20 - 39)     ****
    elsif (l_state = 20) then
      if (l_token is not null) then
        --== Clear out previous data  ==--
	l_page_rec := AK_FLOW_PUB.G_MISS_PAGE_REC;
        l_page_rec.page_application_id := to_number(l_token);
        l_state := 21;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'PAGE_APPLICATION_ID');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 21) then
      if (l_token is not null) then
        l_page_rec.page_code := l_token;
        l_value_count := null;
        l_state := 30;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'PAGE_CODE');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 30) then
      if (l_token = 'BEGIN') then
        l_state := 33;
      elsif (l_token = 'END') then
        l_state := 39;
      elsif (l_token = 'NAME') or
            (l_token = 'DESCRIPTION') or
            (l_token = 'PRIMARY_REGION') or
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
                        (l_token = 'LAST_UPDATE_LOGIN') then
        l_column := l_token;
        l_state := 31;
      else
        --
        -- error if not expecting attribute values added by the translation
        -- team or if we have read in more than a certain number of values
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
            FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_BEFIELD');
            FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
            if (l_value_count is null) then
              FND_MESSAGE.SET_TOKEN('TOKEN', l_token);
            else
              FND_MESSAGE.SET_TOKEN('TOKEN',l_saved_token);
            end if;
            FND_MESSAGE.SET_TOKEN('EXPECTED','FLOW_PAGE ');
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
      if (l_column = 'NAME') then
         l_page_rec.name := l_token;
         l_state := 30;
      elsif (l_column = 'DESCRIPTION') then
         l_page_rec.description := l_token;
         l_state := 30;
      elsif (l_column = 'PRIMARY_REGION') then
         l_page_rec.primary_region_appl_id := to_number(l_token);
		 l_state := 34;
      elsif (l_column = 'ATTRIBUTE_CATEGORY') then
         l_page_rec.attribute_category := l_token;
         l_state := 30;
      elsif (l_column = 'ATTRIBUTE1') then
         l_page_rec.attribute1 := l_token;
         l_state := 30;
      elsif (l_column = 'ATTRIBUTE2') then
         l_page_rec.attribute2 := l_token;
         l_state := 30;
      elsif (l_column = 'ATTRIBUTE3') then
         l_page_rec.attribute3 := l_token;
         l_state := 30;
      elsif (l_column = 'ATTRIBUTE4') then
         l_page_rec.attribute4 := l_token;
         l_state := 30;
      elsif (l_column = 'ATTRIBUTE5') then
         l_page_rec.attribute5 := l_token;
         l_state := 30;
      elsif (l_column = 'ATTRIBUTE6') then
         l_page_rec.attribute6 := l_token;
         l_state := 30;
      elsif (l_column = 'ATTRIBUTE7') then
         l_page_rec.attribute7 := l_token;
         l_state := 30;
      elsif (l_column = 'ATTRIBUTE8') then
         l_page_rec.attribute8 := l_token;
         l_state := 30;
      elsif (l_column = 'ATTRIBUTE9') then
         l_page_rec.attribute9 := l_token;
         l_state := 30;
      elsif (l_column = 'ATTRIBUTE10') then
         l_page_rec.attribute10 := l_token;
         l_state := 30;
      elsif (l_column = 'ATTRIBUTE11') then
         l_page_rec.attribute11 := l_token;
         l_state := 30;
      elsif (l_column = 'ATTRIBUTE12') then
         l_page_rec.attribute12 := l_token;
         l_state := 30;
      elsif (l_column = 'ATTRIBUTE13') then
         l_page_rec.attribute13 := l_token;
         l_state := 30;
      elsif (l_column = 'ATTRIBUTE14') then
         l_page_rec.attribute14 := l_token;
         l_state := 30;
      elsif (l_column = 'ATTRIBUTE15') then
         l_page_rec.attribute15 := l_token;
         l_state := 30;
      elsif (l_column = 'CREATED_BY') then
         l_page_rec.created_by := to_number(l_token);
         l_state := 30;
      elsif (l_column = 'CREATION_DATE') then
         l_page_rec.creation_date := to_date(l_token,
                                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
         l_state := 30;
      elsif (l_column = 'LAST_UPDATED_BY') then
         l_page_rec.last_updated_by := to_number(l_token);
         l_state := 30;
      elsif (l_column = 'OWNER') then
         l_page_rec.last_updated_by := FND_LOAD_UTIL.OWNER_ID(l_token);
         l_state := 30;
      elsif (l_column = 'LAST_UPDATE_DATE') then
         l_page_rec.last_update_date := to_date(l_token,
                                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
         l_state := 30;
      elsif (l_column = 'LAST_UPDATE_LOGIN') then
         l_page_rec.last_update_login := to_number(l_token);
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
    elsif (l_state = 33) then
      if (l_token = 'FLOW_PAGE_REGION') then
        l_state := 100;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('EXPECTED','FLOW_PAGE_REGION');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
	elsif (l_state = 34) then
      if (l_column = 'PRIMARY_REGION') then
        l_page_rec.primary_region_code := l_token;
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
      if (l_token = 'FLOW_PAGE') then
        l_value_count := null;
        l_state := 10;
        l_page_rec.flow_application_id := l_flow_rec.flow_application_id;
        l_page_rec.flow_code := l_flow_rec.flow_code;
        l_page_index := l_page_index + 1;
        l_page_tbl(l_page_index) := l_page_rec;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'FLOW_PAGE');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;

    --****     FLOW_REGION_RELATION processing (states 40 - 59)     ****
    elsif (l_state = 40) then
      if (l_token is not null) then
        --== Clear out previous data  ==--
	l_relation_rec := AK_FLOW_PUB.G_MISS_REGION_RELATION_REC;
        l_relation_rec.foreign_key_name := l_token;
        l_state := 41;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'FOREIGN_KEY_NAME');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 41) then
      if (l_token is not null) then
        l_relation_rec.from_page_appl_id := to_number(l_token);
        l_state := 42;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'FROM_PAGE_APPL_ID');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 42) then
      if (l_token is not null) then
        l_relation_rec.from_page_code := l_token;
        l_state := 43;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'FROM_PAGE_CODE');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 43) then
      if (l_token is not null) then
        l_relation_rec.from_region_appl_id := to_number(l_token);
        l_state := 44;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'FROM_REGION_APPL_ID');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 44) then
      if (l_token is not null) then
        l_relation_rec.from_region_code := l_token;
        l_state := 45;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'FROM_REGION_CODE');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 45) then
      if (l_token is not null) then
        l_relation_rec.to_page_appl_id := to_number(l_token);
        l_state := 46;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'TO_PAGE_APPL_ID');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 46) then
      if (l_token is not null) then
        l_relation_rec.to_page_code := l_token;
        l_state := 47;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'TO_PAGE_CODE');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 47) then
      if (l_token is not null) then
        l_relation_rec.to_region_appl_id := to_number(l_token);
        l_state := 48;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'TO_REGION_APPL_ID');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 48) then
      if (l_token is not null) then
        l_relation_rec.to_region_code := l_token;
        l_state := 50;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'TO_REGION_CODE');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 50) then
      if (l_token = 'END') then
        l_state := 59;
      elsif (l_token = 'APPLICATION_ID') or
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
            (l_token = 'LAST_UPDATE_LOGIN') then
        l_column := l_token;
        l_state := 51;
      else
        --
        -- error if not expecting attribute values added by the translation
        -- team or if we have read in more than a certain number of values
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
            FND_MESSAGE.SET_TOKEN('EXPECTED','FLOW_REGION_RELATION');
            FND_MSG_PUB.Add;
          end if;
        raise FND_API.G_EXC_ERROR;
        end if;
      end if;
    elsif (l_state = 51) then
      if (l_token = '=') then
        l_state := 52;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('EXPECTED', '=');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 52) then
      l_value_count := 1;
      if (l_column = 'APPLICATION_ID') then
         l_relation_rec.application_id := to_number(l_token);
      elsif (l_column = 'ATTRIBUTE_CATEGORY') then
         l_relation_rec.attribute_category := l_token;
      elsif (l_column = 'ATTRIBUTE1') then
         l_relation_rec.attribute1 := l_token;
      elsif (l_column = 'ATTRIBUTE2') then
         l_relation_rec.attribute2 := l_token;
      elsif (l_column = 'ATTRIBUTE3') then
         l_relation_rec.attribute3 := l_token;
      elsif (l_column = 'ATTRIBUTE4') then
         l_relation_rec.attribute4 := l_token;
      elsif (l_column = 'ATTRIBUTE5') then
         l_relation_rec.attribute5 := l_token;
      elsif (l_column = 'ATTRIBUTE6') then
         l_relation_rec.attribute6 := l_token;
      elsif (l_column = 'ATTRIBUTE7') then
         l_relation_rec.attribute7 := l_token;
      elsif (l_column = 'ATTRIBUTE8') then
         l_relation_rec.attribute8 := l_token;
      elsif (l_column = 'ATTRIBUTE9') then
         l_relation_rec.attribute9 := l_token;
      elsif (l_column = 'ATTRIBUTE10') then
         l_relation_rec.attribute10 := l_token;
      elsif (l_column = 'ATTRIBUTE11') then
         l_relation_rec.attribute11 := l_token;
      elsif (l_column = 'ATTRIBUTE12') then
         l_relation_rec.attribute12 := l_token;
      elsif (l_column = 'ATTRIBUTE13') then
         l_relation_rec.attribute13 := l_token;
      elsif (l_column = 'ATTRIBUTE14') then
         l_relation_rec.attribute14 := l_token;
      elsif (l_column = 'ATTRIBUTE15') then
         l_relation_rec.attribute15 := l_token;
      elsif (l_column = 'CREATED_BY') then
         l_relation_rec.created_by := to_number(l_token);
      elsif (l_column = 'CREATION_DATE') then
         l_relation_rec.creation_date := to_date(l_token,
                                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
      elsif (l_column = 'LAST_UPDATED_BY') then
         l_relation_rec.last_updated_by := to_number(l_token);
      elsif (l_column = 'OWNER') then
         l_relation_rec.last_updated_by := FND_LOAD_UTIL.OWNER_ID(l_token);
      elsif (l_column = 'LAST_UPDATE_DATE') then
         l_relation_rec.last_update_date := to_date(l_token,
                                       AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
      elsif (l_column = 'LAST_UPDATE_LOGIN') then
         l_relation_rec.last_update_login := to_number(l_token);
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
      l_state := 50;
    elsif (l_state = 59) then
      if (l_token = 'FLOW_REGION_RELATION') then
        l_value_count := null;
        l_state := 10;
        l_relation_rec.flow_application_id := l_flow_rec.flow_application_id;
        l_relation_rec.flow_code := l_flow_rec.flow_code;
        l_relation_index := l_relation_index + 1;
        l_relation_tbl(l_relation_index) := l_relation_rec;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'FLOW_REGION_RELATION');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;

    --****     FLOW_PAGE_REGION processing (states 100 - 119)     ****
    elsif (l_state = 100) then
      if (l_token is not null) then
        --== Clear out previous data  ==--
        l_region_rec := AK_FLOW_PUB.G_MISS_PAGE_REGION_REC;
        l_region_rec.region_application_id := to_number(l_token);
        l_state := 101;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'REGION_APPLICATION_ID');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 101) then
      if (l_token is not null) then
        l_region_rec.region_code := l_token;
        l_state := 110;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'REGION_CODE');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 110) then
      if (l_token = 'END') then
        l_state := 119;
      elsif (l_token = 'BEGIN')then
        l_state := 113;
      elsif (l_token = 'DISPLAY_SEQUENCE') or
            (l_token = 'REGION_STYLE') or
            (l_token = 'NUM_COLUMNS') or
            (l_token = 'ICX_CUSTOM_CALL') or
            (l_token = 'PARENT_REGION') or
            (l_token = 'FOREIGN_KEY_NAME') or
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
                        (l_token = 'LAST_UPDATE_LOGIN') then
        l_column := l_token;
        l_state := 111;
      else
        --
        -- error if not expecting attribute values added by the translation
        -- team or if we have read in more than a certain number of values
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
            FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_BEFIELD');
            FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
            if (l_value_count is null) then
              FND_MESSAGE.SET_TOKEN('TOKEN', l_token);
            else
              FND_MESSAGE.SET_TOKEN('TOKEN',l_saved_token);
            end if;
            FND_MESSAGE.SET_TOKEN('EXPECTED','FLOW_PAGE_REGION');
            FND_MSG_PUB.Add;
          end if;
        raise FND_API.G_EXC_ERROR;
        end if;
      end if;
    elsif (l_state = 111) then
      if (l_token = '=') then
        l_state := 112;
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
    elsif (l_state = 112) then
      l_value_count := 1;
      if (l_column = 'DISPLAY_SEQUENCE') then
         l_region_rec.display_sequence := to_number(l_token);
         l_state := 110;
      elsif (l_column = 'REGION_STYLE') then
         l_region_rec.region_style := l_token;
         l_state := 110;
      elsif (l_column = 'NUM_COLUMNS') then
         l_region_rec.num_columns := to_number(l_token);
         l_state := 110;
      elsif (l_column = 'ICX_CUSTOM_CALL') then
         l_region_rec.icx_custom_call := l_token;
         l_state := 110;
      elsif (l_column = 'PARENT_REGION') then
         l_region_rec.parent_region_appl_id := to_number(l_token);
		 l_state := 114;
      elsif (l_column = 'FOREIGN_KEY_NAME') then
         l_region_rec.foreign_key_name := l_token;
         l_state := 110;
      elsif (l_column = 'ATTRIBUTE_CATEGORY') then
         l_region_rec.attribute_category := l_token;
         l_state := 110;
      elsif (l_column = 'ATTRIBUTE1') then
         l_region_rec.attribute1 := l_token;
         l_state := 110;
      elsif (l_column = 'ATTRIBUTE2') then
         l_region_rec.attribute2 := l_token;
         l_state := 110;
      elsif (l_column = 'ATTRIBUTE3') then
         l_region_rec.attribute3 := l_token;
         l_state := 110;
      elsif (l_column = 'ATTRIBUTE4') then
         l_region_rec.attribute4 := l_token;
         l_state := 110;
      elsif (l_column = 'ATTRIBUTE5') then
         l_region_rec.attribute5 := l_token;
         l_state := 110;
      elsif (l_column = 'ATTRIBUTE6') then
         l_region_rec.attribute6 := l_token;
         l_state := 110;
      elsif (l_column = 'ATTRIBUTE7') then
         l_region_rec.attribute7 := l_token;
         l_state := 110;
      elsif (l_column = 'ATTRIBUTE8') then
         l_region_rec.attribute8 := l_token;
         l_state := 110;
      elsif (l_column = 'ATTRIBUTE9') then
         l_region_rec.attribute9 := l_token;
         l_state := 110;
      elsif (l_column = 'ATTRIBUTE10') then
         l_region_rec.attribute10 := l_token;
         l_state := 110;
      elsif (l_column = 'ATTRIBUTE11') then
         l_region_rec.attribute11 := l_token;
         l_state := 110;
      elsif (l_column = 'ATTRIBUTE12') then
         l_region_rec.attribute12 := l_token;
         l_state := 110;
      elsif (l_column = 'ATTRIBUTE13') then
         l_region_rec.attribute13 := l_token;
         l_state := 110;
      elsif (l_column = 'ATTRIBUTE14') then
         l_region_rec.attribute14 := l_token;
         l_state := 110;
      elsif (l_column = 'ATTRIBUTE15') then
         l_region_rec.attribute15 := l_token;
         l_state := 110;
      elsif (l_column = 'CREATED_BY') then
         l_region_rec.created_by := to_number(l_token);
         l_state := 110;
      elsif (l_column = 'CREATION_DATE') then
         l_region_rec.creation_date := to_date(l_token,
                                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
         l_state := 110;
      elsif (l_column = 'LAST_UPDATED_BY') then
         l_region_rec.last_updated_by := to_number(l_token);
         l_state := 110;
      elsif (l_column = 'OWNER') then
         l_region_rec.last_updated_by := FND_LOAD_UTIL.OWNER_ID(l_token);
         l_state := 110;
      elsif (l_column = 'LAST_UPDATE_DATE') then
         l_region_rec.last_update_date := to_date(l_token,
                                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
         l_state := 110;
      elsif (l_column = 'LAST_UPDATE_LOGIN') then
         l_region_rec.last_update_login := to_number(l_token);
         l_state := 110;
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
    elsif (l_state = 113) then
      if (l_token = 'FLOW_PAGE_REGION_ITEM') then
        l_state := 200;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED','FLOW_PAGE_REGION_ITEM');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 114) then
      if (l_column = 'PARENT_REGION') then
         l_region_rec.parent_region_code := l_token;
         l_state := 110;
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
    elsif (l_state = 119) then
      if (l_token = 'FLOW_PAGE_REGION') then
        l_value_count := null;
        l_state := 30;
        l_region_rec.flow_application_id := l_flow_rec.flow_application_id;
        l_region_rec.flow_code := l_flow_rec.flow_code;
        l_region_rec.page_application_id := l_page_rec.page_application_id;
        l_region_rec.page_code := l_page_rec.page_code;
        l_region_index := l_region_index + 1;
        l_region_tbl(l_region_index) := l_region_rec;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'FLOW_PAGE_REGION');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;

    --****     FLOW_PAGE_REGION_ITEM processing (states 200 - 219)     ****
    elsif (l_state = 200) then
      if (l_token is not null) then
        --== Clear out previous data  ==--
        l_item_rec := AK_FLOW_PUB.G_MISS_PAGE_REGION_ITEM_REC;
        l_item_rec.attribute_application_id := to_number(l_token);
        l_state := 201;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'ATTRIBUTE_APPLICATION_ID');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 201) then
      if (l_token is not null) then
        l_item_rec.attribute_code := l_token;
        l_value_count := null;
        l_state := 210;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'ATTRIBUTE_CODE');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 210) then
      if (l_token = 'END') then
        l_state := 219;
      elsif (l_token = 'TO_PAGE') or
            (l_token = 'TO_URL_ATTRIBUTE') or
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
            (l_token = 'LAST_UPDATE_LOGIN') then
        l_column := l_token;
        l_state := 211;
      else
        --
        -- error if not expecting attribute values added by the translation
        -- team or if we have read in more than a certain number of values
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
            FND_MESSAGE.SET_TOKEN('EXPECTED','FLOW_PAGE_REGION_ITEM');
            FND_MSG_PUB.Add;
          end if;
        raise FND_API.G_EXC_ERROR;
        end if;
      end if;
    elsif (l_state = 211) then
      if (l_token = '=') then
        l_state := 212;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', '=');
          FND_MSG_PUB.Add;
        end if;
        --dbms_output.put_line('Expecting =');
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 212) then
      l_value_count := 1;
      if (l_column = 'TO_PAGE') then
         l_item_rec.to_page_appl_id := to_number(l_token);
         l_state := 214;
      elsif (l_column = 'TO_URL_ATTRIBUTE') then
         l_item_rec.to_url_attribute_appl_id := to_number(l_token);
         l_state := 214;
      elsif (l_column = 'ATTRIBUTE_CATEGORY') then
         l_item_rec.attribute_category := l_token;
         l_state := 210;
      elsif (l_column = 'ATTRIBUTE1') then
         l_item_rec.attribute1 := l_token;
         l_state := 210;
      elsif (l_column = 'ATTRIBUTE2') then
         l_item_rec.attribute2 := l_token;
         l_state := 210;
      elsif (l_column = 'ATTRIBUTE3') then
         l_item_rec.attribute3 := l_token;
         l_state := 210;
      elsif (l_column = 'ATTRIBUTE4') then
         l_item_rec.attribute4 := l_token;
         l_state := 210;
      elsif (l_column = 'ATTRIBUTE5') then
         l_item_rec.attribute5 := l_token;
         l_state := 210;
      elsif (l_column = 'ATTRIBUTE6') then
         l_item_rec.attribute6 := l_token;
         l_state := 210;
      elsif (l_column = 'ATTRIBUTE7') then
         l_item_rec.attribute7 := l_token;
         l_state := 210;
      elsif (l_column = 'ATTRIBUTE8') then
         l_item_rec.attribute8 := l_token;
         l_state := 210;
      elsif (l_column = 'ATTRIBUTE9') then
         l_item_rec.attribute9 := l_token;
         l_state := 210;
      elsif (l_column = 'ATTRIBUTE10') then
         l_item_rec.attribute10 := l_token;
         l_state := 210;
      elsif (l_column = 'ATTRIBUTE11') then
         l_item_rec.attribute11 := l_token;
         l_state := 210;
      elsif (l_column = 'ATTRIBUTE12') then
         l_item_rec.attribute12 := l_token;
         l_state := 210;
      elsif (l_column = 'ATTRIBUTE13') then
         l_item_rec.attribute13 := l_token;
         l_state := 210;
      elsif (l_column = 'ATTRIBUTE14') then
         l_item_rec.attribute14 := l_token;
         l_state := 210;
      elsif (l_column = 'ATTRIBUTE15') then
         l_item_rec.attribute15 := l_token;
         l_state := 210;
      elsif (l_column = 'CREATED_BY') then
         l_item_rec.created_by := to_number(l_token);
         l_state := 210;
      elsif (l_column = 'CREATION_DATE') then
         l_item_rec.creation_date := to_date(l_token,
                                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
         l_state := 210;
      elsif (l_column = 'LAST_UPDATED_BY') then
         l_item_rec.last_updated_by := to_number(l_token);
         l_state := 210;
      elsif (l_column = 'OWNER') then
         l_item_rec.last_updated_by := FND_LOAD_UTIL.OWNER_ID(l_token);
         l_state := 210;
      elsif (l_column = 'LAST_UPDATE_DATE') then
         l_item_rec.last_update_date := to_date(l_token,
                                       AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
         l_state := 210;
      elsif (l_column = 'LAST_UPDATE_LOGIN') then
         l_item_rec.last_update_login := to_number(l_token);
         l_state := 210;
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
    elsif (l_state = 214) then
      if (l_column = 'TO_PAGE') then
         l_item_rec.to_page_code := l_token;
      elsif (l_column = 'TO_URL_ATTRIBUTE') then
         l_item_rec.to_url_attribute_code := l_token;
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
      l_state := 210;
    elsif (l_state = 219) then
      if (l_token = 'FLOW_PAGE_REGION_ITEM') then
        l_value_count := null;
        l_state := 110;
        l_item_rec.flow_application_id := l_flow_rec.flow_application_id;
        l_item_rec.flow_code := l_flow_rec.flow_code;
        l_item_rec.page_application_id := l_page_rec.page_application_id;
        l_item_rec.page_code := l_page_rec.page_code;
        l_item_rec.region_application_id := l_region_rec.region_application_id;
        l_item_rec.region_code := l_region_rec.region_code;
        l_item_index := l_item_index + 1;
        l_item_tbl(l_item_index) := l_item_rec;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'FLOW_PAGE_REGION_ITEM');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;

    end if; -- if l_state = ...

    -- Get rid of leading white spaces, so that buffer would become
    -- null if the only thing in it are white spaces
    l_buffer := LTRIM(l_buffer);

    --
    -- Get the next non-blank, non-comment line if current line is
    -- fully parsed
    --
    while (l_buffer is null and l_eof_flag = 'N' and p_index <= AK_ON_OBJECTS_PVT.G_UPL_TABLE_NUM) loop
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

  end LOOP; --** finish parsing the input file **

-- dbms_output.put_line('finished parsing flows: ' ||
--                        to_char(sysdate, 'MON-DD HH24:MI:SS'));

  -- If the loops end in a state other then at the end of an object
  -- (state 0) or when the beginning of another business object was
  -- detected, then the file must have ended prematurely, which is an error
  if (l_state <> 0) and (l_more_flow) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_UNEXPECTED_EOF_ERROR');
      FND_MSG_PUB.Add;
    end if;
    raise FND_API.G_EXC_ERROR;
  end if;

  -- Create new flows to the database
  --
  -- - Create flows that are not already in the database. Since it is
  --   very likely that there are no pages for these new flows,
  --   these flows will be created without specifying their primary pages.
  --   Later in this procedure, they will be updated with the appropriate
  --   primary pages once all the flow pages are loaded.
  --
  --   Existing flows will also be updated with new data at that time.
  --
  if (l_flow_tbl.count > 0) then
    for l_index in l_flow_tbl.FIRST .. l_flow_tbl.LAST loop
      if (l_flow_tbl.exists(l_index)) then
        if NOT AK_FLOW_PVT.FLOW_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_flow_application_id =>
                        l_flow_tbl(l_index).flow_application_id,
            p_flow_code => l_flow_tbl(l_index).flow_code) then
          AK_FLOW_PVT.CREATE_FLOW (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
            p_flow_application_id =>
                        l_flow_tbl(l_index).flow_application_id,
            p_flow_code => l_flow_tbl(l_index).flow_code,
            p_attribute_category => l_flow_tbl(l_index).attribute_category,
			p_attribute1 => l_flow_tbl(l_index).attribute1,
			p_attribute2 => l_flow_tbl(l_index).attribute2,
			p_attribute3 => l_flow_tbl(l_index).attribute3,
			p_attribute4 => l_flow_tbl(l_index).attribute4,
			p_attribute5 => l_flow_tbl(l_index).attribute5,
			p_attribute6 => l_flow_tbl(l_index).attribute6,
			p_attribute7 => l_flow_tbl(l_index).attribute7,
			p_attribute8 => l_flow_tbl(l_index).attribute8,
			p_attribute9 => l_flow_tbl(l_index).attribute9,
			p_attribute10 => l_flow_tbl(l_index).attribute10,
			p_attribute11 => l_flow_tbl(l_index).attribute11,
			p_attribute12 => l_flow_tbl(l_index).attribute12,
			p_attribute13 => l_flow_tbl(l_index).attribute13,
			p_attribute14 => l_flow_tbl(l_index).attribute14,
			p_attribute15 => l_flow_tbl(l_index).attribute15,
            p_name => l_flow_tbl(l_index).name,
            p_description => l_flow_tbl(l_index).description,
	p_created_by => l_flow_tbl(l_index).created_by,
        p_creation_date => l_flow_tbl(l_index).creation_date,
        p_last_updated_by => l_flow_tbl(l_index).last_updated_by,
        p_last_update_date => l_flow_tbl(l_index).last_update_date,
        p_last_update_login => l_flow_tbl(l_index).last_update_login,
            p_loader_timestamp => p_loader_timestamp,
  		    p_pass => p_pass,
            p_copy_redo_flag => l_copy_redo_flag
          );

            -- If API call returns with an error status...
            if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
            (l_return_status = FND_API.G_RET_STS_ERROR) then
              RAISE FND_API.G_EXC_ERROR;
            end if;
        end if; -- /* if AK_FLOW_PVT.FLOW_EXISTS */
      end if;
    end loop;
  end if;

  -- Create new flow pages to the database
  --
  -- - Create flow pages that are not already in the database. Since it is
  --   very likely that there are no page regions for these new flows,
  --   these flow pages will be created without specifying any  primary
  --   page regions.
  --   Later in this procedure, they will be updated with the appropriate
  --   primary regions once all the flow page regions are loaded.
  --
  --   Existing flow pages will also be updated with new data at that time.
  --
  if (l_page_tbl.count > 0) then
    for l_index in l_page_tbl.FIRST .. l_page_tbl.LAST loop
      if (l_page_tbl.exists(l_index)) then
        if NOT AK_FLOW_PVT.PAGE_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_flow_application_id =>
                        l_page_tbl(l_index).flow_application_id,
            p_flow_code => l_page_tbl(l_index).flow_code,
            p_page_application_id =>
                        l_page_tbl(l_index).page_application_id,
            p_page_code => l_page_tbl(l_index).page_code) then
          AK_FLOW_PVT.CREATE_PAGE (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
            p_flow_application_id =>
                        l_page_tbl(l_index).flow_application_id,
            p_flow_code => l_page_tbl(l_index).flow_code,
            p_page_application_id =>
                        l_page_tbl(l_index).page_application_id,
            p_page_code => l_page_tbl(l_index).page_code,
            p_attribute_category => l_page_tbl(l_index).attribute_category,
			p_attribute1 => l_page_tbl(l_index).attribute1,
			p_attribute2 => l_page_tbl(l_index).attribute2,
			p_attribute3 => l_page_tbl(l_index).attribute3,
			p_attribute4 => l_page_tbl(l_index).attribute4,
			p_attribute5 => l_page_tbl(l_index).attribute5,
			p_attribute6 => l_page_tbl(l_index).attribute6,
			p_attribute7 => l_page_tbl(l_index).attribute7,
			p_attribute8 => l_page_tbl(l_index).attribute8,
			p_attribute9 => l_page_tbl(l_index).attribute9,
			p_attribute10 => l_page_tbl(l_index).attribute10,
			p_attribute11 => l_page_tbl(l_index).attribute11,
			p_attribute12 => l_page_tbl(l_index).attribute12,
			p_attribute13 => l_page_tbl(l_index).attribute13,
			p_attribute14 => l_page_tbl(l_index).attribute14,
			p_attribute15 => l_page_tbl(l_index).attribute15,
            p_name => l_page_tbl(l_index).name,
            p_description => l_page_tbl(l_index).description,
        p_created_by => l_page_tbl(l_index).created_by,
        p_creation_date => l_page_tbl(l_index).creation_date,
        p_last_updated_by => l_page_tbl(l_index).last_updated_by,
        p_last_update_date => l_page_tbl(l_index).last_update_date,
        p_last_update_login => l_page_tbl(l_index).last_update_login,
            p_loader_timestamp => p_loader_timestamp,
  		    p_pass => p_pass,
            p_copy_redo_flag => l_copy_redo_flag
          );

            -- If API call returns with an error status..., abort upload
            if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
            (l_return_status = FND_API.G_RET_STS_ERROR) then
              RAISE FND_API.G_EXC_ERROR;
            end if;
        end if; -- /* if PAGE_EXISTS */
      end if;
    end loop;
  end if;

  -- Update primary page columns for new flows, and update all columns
  -- for existing flows.
  --
  --   Now that all flow pages have been loaded into the database,
  --   we can load the primary page columns for all new flows that
  --   has a primary page. Existing flows are also updated with new
  --   data in the loader file at this time.
  --
  if (l_flow_tbl.count > 0) then
    for l_index in l_flow_tbl.FIRST .. l_flow_tbl.LAST loop
      if (l_flow_tbl.exists(l_index)) then
		-- update all records
		if ( AK_UPLOAD_GRP.G_UPDATE_MODE ) then
         AK_FLOW_PVT.UPDATE_FLOW (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
            p_flow_application_id =>
                        l_flow_tbl(l_index).flow_application_id,
            p_flow_code => l_flow_tbl(l_index).flow_code,
            p_name => l_flow_tbl(l_index).name,
            p_description => l_flow_tbl(l_index).description,
            p_primary_page_appl_id => l_flow_tbl(l_index).primary_page_appl_id,
            p_primary_page_code => l_flow_tbl(l_index).primary_page_code,
            p_attribute_category => l_flow_tbl(l_index).attribute_category,
			p_attribute1 => l_flow_tbl(l_index).attribute1,
			p_attribute2 => l_flow_tbl(l_index).attribute2,
			p_attribute3 => l_flow_tbl(l_index).attribute3,
			p_attribute4 => l_flow_tbl(l_index).attribute4,
			p_attribute5 => l_flow_tbl(l_index).attribute5,
			p_attribute6 => l_flow_tbl(l_index).attribute6,
			p_attribute7 => l_flow_tbl(l_index).attribute7,
			p_attribute8 => l_flow_tbl(l_index).attribute8,
			p_attribute9 => l_flow_tbl(l_index).attribute9,
			p_attribute10 => l_flow_tbl(l_index).attribute10,
			p_attribute11 => l_flow_tbl(l_index).attribute11,
			p_attribute12 => l_flow_tbl(l_index).attribute12,
			p_attribute13 => l_flow_tbl(l_index).attribute13,
			p_attribute14 => l_flow_tbl(l_index).attribute14,
			p_attribute15 => l_flow_tbl(l_index).attribute15,
        p_created_by  => l_flow_tbl(l_index).created_by,
        p_creation_date  => l_flow_tbl(l_index).creation_date,
        p_last_updated_by  => l_flow_tbl(l_index).last_updated_by,
        p_last_update_date  => l_flow_tbl(l_index).last_update_date,
        p_last_update_login  => l_flow_tbl(l_index).last_update_login,
            p_loader_timestamp => p_loader_timestamp,
  		    p_pass => p_pass,
            p_copy_redo_flag => l_copy_redo_flag
          );
		-- update flow records if primary page has been changed or
		-- update non-customized data
		elsif ( AK_UPLOAD_GRP.G_NO_CUSTOM_UPDATE AND (NOT AK_UPLOAD_GRP.G_UPDATE_MODE) ) then
		  select af.primary_page_code, af.primary_page_appl_id, af.last_updated_by,
		  aft.last_updated_by,
		  af.last_update_date, aft.last_update_date
		  into l_temp_key_code, l_temp_key_appl_id, l_user_id1, l_user_id2, l_update1, l_update2
		  from ak_flows af, ak_flows_tl aft
		  where af.flow_code = l_flow_tbl(l_index).flow_code
		  and af.flow_application_id = l_flow_tbl(l_index).flow_application_id
		  and af.flow_code = aft.flow_code
		  and af.flow_application_id = aft.flow_application_id
		  and aft.language = userenv('LANG');
		  /*if ( ( ( l_user_id1 = 1 or l_user_id1 = 2 ) and
			( l_user_id2 = 1 or l_user_id2 = 2 )) */
                if ((AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
                      p_loader_timestamp => p_loader_timestamp,
                      p_created_by => l_flow_tbl(l_index).created_by,
                      p_creation_date => l_flow_tbl(l_index).creation_date,
                      p_last_updated_by => l_flow_tbl(l_index).last_updated_by,
                      p_db_last_updated_by => l_user_id1,
                      p_last_update_date => l_flow_tbl(l_index).last_update_date,
                      p_db_last_update_date => l_update1,
                      p_last_update_login => l_flow_tbl(l_index).last_update_login,
                      p_create_or_update => 'UPDATE') and

                   AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
                      p_loader_timestamp => p_loader_timestamp,
                      p_created_by => l_flow_tbl(l_index).created_by,
                      p_creation_date => l_flow_tbl(l_index).creation_date,
                      p_last_updated_by => l_flow_tbl(l_index).last_updated_by,
                      p_db_last_updated_by => l_user_id2,
                      p_last_update_date => l_flow_tbl(l_index).last_update_date,
                      p_db_last_update_date => l_update2,
                      p_last_update_login => l_flow_tbl(l_index).last_update_login,
                      p_create_or_update => 'UPDATE'))
or
			( l_temp_key_code <> l_flow_tbl(l_index).primary_page_code and
			  l_temp_key_appl_id <> l_flow_tbl(l_index).primary_page_appl_id ) ) then
	         AK_FLOW_PVT.UPDATE_FLOW (
	            p_validation_level => p_validation_level,
	            p_api_version_number => 1.0,
	            p_msg_count => l_msg_count,
	            p_msg_data => l_msg_data,
	            p_return_status => l_return_status,
	            p_flow_application_id =>
	                        l_flow_tbl(l_index).flow_application_id,
	            p_flow_code => l_flow_tbl(l_index).flow_code,
	            p_name => l_flow_tbl(l_index).name,
	            p_description => l_flow_tbl(l_index).description,
	            p_primary_page_appl_id => l_flow_tbl(l_index).primary_page_appl_id,
	            p_primary_page_code => l_flow_tbl(l_index).primary_page_code,
	            p_attribute_category => l_flow_tbl(l_index).attribute_category,
				p_attribute1 => l_flow_tbl(l_index).attribute1,
				p_attribute2 => l_flow_tbl(l_index).attribute2,
				p_attribute3 => l_flow_tbl(l_index).attribute3,
				p_attribute4 => l_flow_tbl(l_index).attribute4,
				p_attribute5 => l_flow_tbl(l_index).attribute5,
				p_attribute6 => l_flow_tbl(l_index).attribute6,
				p_attribute7 => l_flow_tbl(l_index).attribute7,
				p_attribute8 => l_flow_tbl(l_index).attribute8,
				p_attribute9 => l_flow_tbl(l_index).attribute9,
				p_attribute10 => l_flow_tbl(l_index).attribute10,
				p_attribute11 => l_flow_tbl(l_index).attribute11,
				p_attribute12 => l_flow_tbl(l_index).attribute12,
				p_attribute13 => l_flow_tbl(l_index).attribute13,
				p_attribute14 => l_flow_tbl(l_index).attribute14,
				p_attribute15 => l_flow_tbl(l_index).attribute15,
        p_created_by  => l_flow_tbl(l_index).created_by,
        p_creation_date  => l_flow_tbl(l_index).creation_date,
        p_last_updated_by  => l_flow_tbl(l_index).last_updated_by,
        p_last_update_date  => l_flow_tbl(l_index).last_update_date,
        p_last_update_login  => l_flow_tbl(l_index).last_update_login,
	            p_loader_timestamp => p_loader_timestamp,
	  		    p_pass => p_pass,
	            p_copy_redo_flag => l_copy_redo_flag
	          );
		  end if; -- /* if l_user_id1 */
		end if; -- /* if G_UPDATE_MODE */
          if (l_copy_redo_flag) then
            G_FLOW_REDO_INDEX := G_FLOW_REDO_INDEX + 1;
            G_FLOW_REDO_TBL(G_FLOW_REDO_INDEX) := l_flow_tbl(l_index);
            l_copy_redo_flag := FALSE;
          end if; /* if l_copy_redo_flag */
      end if; /* if l_flow_tbl.exists(l_index) exists */
    end loop;
  end if;

  -- Insert or update all page regions to the database
  --
  --   Since not all page regions exists in the database, we are
  --   creating new page regions with parent regions set to null.
  --   Update to certain page regions with a parent region will
  --   fail due to the same reason.
  --   Later in this procedure, they will be updated with the appropriate
  --   parent regions once all the page regions are loaded.
  --
  if (l_region_tbl.count > 0) then
    for l_index in l_region_tbl.FIRST .. l_region_tbl.LAST loop
      if (l_region_tbl.exists(l_index)) then
        if AK_FLOW_PVT.PAGE_REGION_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_flow_application_id =>
                        l_region_tbl(l_index).flow_application_id,
            p_flow_code => l_region_tbl(l_index).flow_code,
            p_page_application_id =>
                        l_region_tbl(l_index).page_application_id,
            p_page_code => l_region_tbl(l_index).page_code,
            p_region_application_id =>
                        l_region_tbl(l_index).region_application_id,
            p_region_code => l_region_tbl(l_index).region_code) then
          --
          -- Update Page Region only if Update Mode is TRUE
		  --
          if (AK_UPLOAD_GRP.G_UPDATE_MODE) then
            AK_FLOW_PVT.UPDATE_PAGE_REGION (
              p_validation_level => p_validation_level,
              p_api_version_number => 1.0,
              p_msg_count => l_msg_count,
              p_msg_data => l_msg_data,
              p_return_status => l_return_status,
              p_flow_application_id =>
                          l_region_tbl(l_index).flow_application_id,
              p_flow_code => l_region_tbl(l_index).flow_code,
              p_page_application_id =>
                          l_region_tbl(l_index).page_application_id,
              p_page_code => l_region_tbl(l_index).page_code,
              p_region_application_id =>
                          l_region_tbl(l_index).region_application_id,
              p_region_code => l_region_tbl(l_index).region_code,
              p_display_sequence => l_region_tbl(l_index).display_sequence,
              p_region_style => l_region_tbl(l_index).region_style,
              p_num_columns => l_region_tbl(l_index).num_columns,
              p_icx_custom_call => l_region_tbl(l_index).icx_custom_call,
              p_parent_region_application_id =>
                          l_region_tbl(l_index).parent_region_appl_id,
              p_parent_region_code => l_region_tbl(l_index).parent_region_code,
              p_foreign_key_name => l_region_tbl(l_index).foreign_key_name,
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
        p_created_by  => l_region_tbl(l_index).created_by,
        p_creation_date  => l_region_tbl(l_index).creation_date,
        p_last_updated_by  => l_region_tbl(l_index).last_updated_by,
        p_last_update_date  => l_region_tbl(l_index).last_update_date,
        p_last_update_login  => l_region_tbl(l_index).last_update_login,
              p_loader_timestamp => p_loader_timestamp,
  		      p_pass => p_pass,
              p_copy_redo_flag => l_copy_redo_flag
            );
		  elsif ( AK_UPLOAD_GRP.G_NO_CUSTOM_UPDATE ) then
			select last_updated_by, last_update_date
			into l_user_id1, l_update1
			from ak_flow_page_regions
			where flow_code = l_region_tbl(l_index).flow_code
			and flow_application_id = l_region_tbl(l_index).flow_application_id
			and page_code = l_region_tbl(l_index).page_code
			and page_application_id = l_region_tbl(l_index).page_application_id
			and region_code = l_region_tbl(l_index).region_code
			and region_application_id = l_region_tbl(l_index).region_application_id;
			/*if ( l_user_id1 = 1 or l_user_id1 = 2 ) then*/

                if AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
                      p_loader_timestamp => p_loader_timestamp,
                      p_created_by => l_region_tbl(l_index).created_by,
                      p_creation_date => l_region_tbl(l_index).creation_date,
                      p_last_updated_by => l_region_tbl(l_index).last_updated_by,
                      p_db_last_updated_by => l_user_id1,
                      p_last_update_date => l_region_tbl(l_index).last_update_date,
                      p_db_last_update_date => l_update1,
                      p_last_update_login => l_region_tbl(l_index).last_update_login,
                      p_create_or_update => 'UPDATE') then

	            AK_FLOW_PVT.UPDATE_PAGE_REGION (
	              p_validation_level => p_validation_level,
	              p_api_version_number => 1.0,
	              p_msg_count => l_msg_count,
	              p_msg_data => l_msg_data,
	              p_return_status => l_return_status,
	              p_flow_application_id =>
	                          l_region_tbl(l_index).flow_application_id,
	              p_flow_code => l_region_tbl(l_index).flow_code,
	              p_page_application_id =>
	                          l_region_tbl(l_index).page_application_id,
	              p_page_code => l_region_tbl(l_index).page_code,
	              p_region_application_id =>
	                          l_region_tbl(l_index).region_application_id,
	              p_region_code => l_region_tbl(l_index).region_code,
	              p_display_sequence => l_region_tbl(l_index).display_sequence,
	              p_region_style => l_region_tbl(l_index).region_style,
	              p_num_columns => l_region_tbl(l_index).num_columns,
	              p_icx_custom_call => l_region_tbl(l_index).icx_custom_call,
	              p_parent_region_application_id =>
	                          l_region_tbl(l_index).parent_region_appl_id,
	              p_parent_region_code => l_region_tbl(l_index).parent_region_code,
	              p_foreign_key_name => l_region_tbl(l_index).foreign_key_name,
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
        p_created_by  => l_region_tbl(l_index).created_by,
        p_creation_date  => l_region_tbl(l_index).creation_date,
        p_last_updated_by  => l_region_tbl(l_index).last_updated_by,
        p_last_update_date  => l_region_tbl(l_index).last_update_date,
        p_last_update_login  => l_region_tbl(l_index).last_update_login,
	              p_loader_timestamp => p_loader_timestamp,
	  		      p_pass => p_pass,
	              p_copy_redo_flag => l_copy_redo_flag
	            );
			end if; -- /* if l_user_id1 = 1 */
          end if; -- /* if G_UPDATE_MODE G_NO_CUSTOM_UPDATE */
        else
          AK_FLOW_PVT.CREATE_PAGE_REGION (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
            p_flow_application_id =>
                        l_region_tbl(l_index).flow_application_id,
            p_flow_code => l_region_tbl(l_index).flow_code,
            p_page_application_id =>
                        l_region_tbl(l_index).page_application_id,
            p_page_code => l_region_tbl(l_index).page_code,
            p_region_application_id =>
                        l_region_tbl(l_index).region_application_id,
            p_region_code => l_region_tbl(l_index).region_code,
            p_display_sequence => l_region_tbl(l_index).display_sequence,
            p_region_style => l_region_tbl(l_index).region_style,
            p_num_columns => l_region_tbl(l_index).num_columns,
            p_icx_custom_call => l_region_tbl(l_index).icx_custom_call,
            p_parent_region_application_id => null,
            p_parent_region_code => null,
            p_foreign_key_name => null,
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
        p_created_by => l_region_tbl(l_index).created_by,
        p_creation_date => l_region_tbl(l_index).creation_date,
        p_last_updated_by => l_region_tbl(l_index).last_updated_by,
        p_last_update_date => l_region_tbl(l_index).last_update_date,
        p_last_update_login => l_region_tbl(l_index).last_update_login,
            p_loader_timestamp => p_loader_timestamp,
  		    p_pass => p_pass,
            p_copy_redo_flag => l_copy_redo_flag
          );
        end if;	-- /* if PAGE_REGION_EXISTS */
		--
        -- If API call returns with an error status, upload aborts
        if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
        (l_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        end if; -- /* if l_return_status */
        if (l_copy_redo_flag) then
          G_PAGE_REGION_REDO_INDEX := G_PAGE_REGION_REDO_INDEX + 1;
          G_PAGE_REGION_REDO_TBL(G_PAGE_REGION_REDO_INDEX) := l_region_tbl(l_index);
          l_copy_redo_flag := FALSE;
        end if; /* if l_copy_redo_flag */

      end if; -- /* if l_region_tbl.exists */
    end loop;
  end if;

  -- Update parent region columns for page regions
  --
  --   Now that all page regions have been loaded into the database,
  --   we can load the parent region columns for all page regions that
  --   has a parent region.
  --
  --   Intrapage region relations are created in UPDATE_PAGE_REGION when
  --   a parent region is specified.
  --
  if (l_region_tbl.count > 0) then
    for l_index in l_region_tbl.FIRST .. l_region_tbl.LAST loop
      if (l_region_tbl.exists(l_index)) then
        if ( (l_region_tbl(l_index).parent_region_appl_id is not null) or
             (l_region_tbl(l_index).parent_region_code is not null) ) then
         AK_FLOW_PVT.UPDATE_PAGE_REGION (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
            p_flow_application_id =>
                        l_region_tbl(l_index).flow_application_id,
            p_flow_code => l_region_tbl(l_index).flow_code,
            p_page_application_id =>
                        l_region_tbl(l_index).page_application_id,
            p_page_code => l_region_tbl(l_index).page_code,
            p_region_application_id =>
                        l_region_tbl(l_index).region_application_id,
            p_region_code => l_region_tbl(l_index).region_code,
            p_parent_region_application_id =>
                        l_region_tbl(l_index).parent_region_appl_id,
            p_parent_region_code => l_region_tbl(l_index).parent_region_code,
            p_foreign_key_name => l_region_tbl(l_index).foreign_key_name,
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
        p_created_by  => l_region_tbl(l_index).created_by,
        p_creation_date  => l_region_tbl(l_index).creation_date,
        p_last_updated_by  => l_region_tbl(l_index).last_updated_by,
        p_last_update_date  => l_region_tbl(l_index).last_update_date,
        p_last_update_login  => l_region_tbl(l_index).last_update_login,
            p_loader_timestamp => p_loader_timestamp,
  		    p_pass => p_pass,
            p_copy_redo_flag => l_copy_redo_flag
          );
        -- If API call returns with an error status, upload aborts
        if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
        (l_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        end if; -- /* if l_return_status */
          if (l_copy_redo_flag) then
            G_PAGE_REGION_REDO_INDEX := G_PAGE_REGION_REDO_INDEX + 1;
            G_PAGE_REGION_REDO_TBL(G_PAGE_REGION_REDO_INDEX) := l_region_tbl(l_index);
            l_copy_redo_flag := FALSE;
          end if; /* if l_copy_redo_flag */
        end if; /* if parent_region is not null */
      end if; /* if l_region_tbl(l_index) exists */
    end loop;
  end if;

  -- Update primary region columns for new flow pages, and update all columns
  -- for existing flow pages.
  --
  --   Now that all flow page regions have been loaded into the database,
  --   we can load the primary region columns for all new flow pages that
  --   has a primary region. Existing flow pages are also updated with new
  --   data in the loader file at this time.
  --
  if (l_page_tbl.count > 0) then
    for l_index in l_page_tbl.FIRST .. l_page_tbl.LAST loop
      if (l_page_tbl.exists(l_index)) then
		-- update all records
		if ( AK_UPLOAD_GRP.G_UPDATE_MODE ) then
         AK_FLOW_PVT.UPDATE_PAGE (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
            p_flow_application_id =>
                        l_page_tbl(l_index).flow_application_id,
            p_flow_code => l_page_tbl(l_index).flow_code,
            p_page_application_id =>
                        l_page_tbl(l_index).page_application_id,
            p_page_code => l_page_tbl(l_index).page_code,
            p_primary_region_appl_id =>
                        l_page_tbl(l_index).primary_region_appl_id,
            p_primary_region_code => l_page_tbl(l_index).primary_region_code,
            p_attribute_category => l_page_tbl(l_index).attribute_category,
			p_attribute1 => l_page_tbl(l_index).attribute1,
			p_attribute2 => l_page_tbl(l_index).attribute2,
			p_attribute3 => l_page_tbl(l_index).attribute3,
			p_attribute4 => l_page_tbl(l_index).attribute4,
			p_attribute5 => l_page_tbl(l_index).attribute5,
			p_attribute6 => l_page_tbl(l_index).attribute6,
			p_attribute7 => l_page_tbl(l_index).attribute7,
			p_attribute8 => l_page_tbl(l_index).attribute8,
			p_attribute9 => l_page_tbl(l_index).attribute9,
			p_attribute10 => l_page_tbl(l_index).attribute10,
			p_attribute11 => l_page_tbl(l_index).attribute11,
			p_attribute12 => l_page_tbl(l_index).attribute12,
			p_attribute13 => l_page_tbl(l_index).attribute13,
			p_attribute14 => l_page_tbl(l_index).attribute14,
			p_attribute15 => l_page_tbl(l_index).attribute15,
        p_created_by  => l_page_tbl(l_index).created_by,
        p_creation_date  => l_page_tbl(l_index).creation_date,
        p_last_updated_by  => l_page_tbl(l_index).last_updated_by,
        p_last_update_date  => l_page_tbl(l_index).last_update_date,
        p_last_update_login  => l_page_tbl(l_index).last_update_login,
            p_name => l_page_tbl(l_index).name,
            p_description => l_page_tbl(l_index).description,
            p_loader_timestamp => p_loader_timestamp,
  		    p_pass => p_pass,
            p_copy_redo_flag => l_copy_redo_flag
          );
		elsif ( AK_UPLOAD_GRP.G_NO_CUSTOM_UPDATE or (NOT AK_UPLOAD_GRP.G_UPDATE_MODE) ) then
		  select afp.primary_region_code, afp.primary_region_appl_id, afp.last_updated_by,
		  afpt.last_updated_by,
		  afp.last_update_date, afpt.last_update_date
		  into l_temp_key_code, l_temp_key_appl_id,
		  l_user_id1 , l_user_id2, l_update1, l_update2
		  from ak_flow_pages afp, ak_flow_pages_tl afpt
		  where afp.flow_code = l_page_tbl(l_index).flow_code
		  and afp.flow_application_id = l_page_tbl(l_index).flow_application_id
		  and afp.page_code = l_page_tbl(l_index).page_code
		  and afp.page_application_id = l_page_tbl(l_index).page_application_id
		  and afp.flow_code = afpt.flow_code
		  and afp.flow_application_id = afpt.flow_application_id
		  and afp.page_code = afpt.page_code
		  and afp.page_application_id = afpt.page_application_id
		  and afpt.language = userenv('LANG');
		  /*if ( ( ( l_user_id1 = 1 or l_user_id1 = 2) and
			(l_user_id2 = 1 or l_user_id2 = 2)) */
                if ((AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
                      p_loader_timestamp => p_loader_timestamp,
                      p_created_by => l_page_tbl(l_index).created_by,
                      p_creation_date => l_page_tbl(l_index).creation_date,
                      p_last_updated_by => l_page_tbl(l_index).last_updated_by,
                      p_db_last_updated_by => l_user_id1,
                      p_last_update_date => l_page_tbl(l_index).last_update_date,
                      p_db_last_update_date => l_update1,
                      p_last_update_login => l_page_tbl(l_index).last_update_login,
                      p_create_or_update => 'UPDATE') and

		    AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
                      p_loader_timestamp => p_loader_timestamp,
                      p_created_by => l_page_tbl(l_index).created_by,
                      p_creation_date => l_page_tbl(l_index).creation_date,
                      p_last_updated_by => l_page_tbl(l_index).last_updated_by,
                      p_db_last_updated_by => l_user_id2,
                      p_last_update_date => l_page_tbl(l_index).last_update_date,
                      p_db_last_update_date => l_update2,
                      p_last_update_login => l_page_tbl(l_index).last_update_login,
                      p_create_or_update => 'UPDATE'))
or
		  	( l_temp_key_appl_id <> l_page_tbl(l_index).primary_region_appl_id and
			  l_temp_key_code <> l_page_tbl(l_index).primary_region_code ) ) then
	         AK_FLOW_PVT.UPDATE_PAGE (
	            p_validation_level => p_validation_level,
	            p_api_version_number => 1.0,
	            p_msg_count => l_msg_count,
	            p_msg_data => l_msg_data,
	            p_return_status => l_return_status,
	            p_flow_application_id =>
	                        l_page_tbl(l_index).flow_application_id,
	            p_flow_code => l_page_tbl(l_index).flow_code,
	            p_page_application_id =>
	                        l_page_tbl(l_index).page_application_id,
	            p_page_code => l_page_tbl(l_index).page_code,
	            p_primary_region_appl_id =>
	                        l_page_tbl(l_index).primary_region_appl_id,
	            p_primary_region_code => l_page_tbl(l_index).primary_region_code,
	            p_attribute_category => l_page_tbl(l_index).attribute_category,
				p_attribute1 => l_page_tbl(l_index).attribute1,
				p_attribute2 => l_page_tbl(l_index).attribute2,
				p_attribute3 => l_page_tbl(l_index).attribute3,
				p_attribute4 => l_page_tbl(l_index).attribute4,
				p_attribute5 => l_page_tbl(l_index).attribute5,
				p_attribute6 => l_page_tbl(l_index).attribute6,
				p_attribute7 => l_page_tbl(l_index).attribute7,
				p_attribute8 => l_page_tbl(l_index).attribute8,
				p_attribute9 => l_page_tbl(l_index).attribute9,
				p_attribute10 => l_page_tbl(l_index).attribute10,
				p_attribute11 => l_page_tbl(l_index).attribute11,
				p_attribute12 => l_page_tbl(l_index).attribute12,
				p_attribute13 => l_page_tbl(l_index).attribute13,
				p_attribute14 => l_page_tbl(l_index).attribute14,
				p_attribute15 => l_page_tbl(l_index).attribute15,
	            p_name => l_page_tbl(l_index).name,
	            p_description => l_page_tbl(l_index).description,
        p_created_by  => l_page_tbl(l_index).created_by,
        p_creation_date  => l_page_tbl(l_index).creation_date,
        p_last_updated_by  => l_page_tbl(l_index).last_updated_by,
        p_last_update_date  => l_page_tbl(l_index).last_update_date,
        p_last_update_login  => l_page_tbl(l_index).last_update_login,
	            p_loader_timestamp => p_loader_timestamp,
	  		    p_pass => p_pass,
	            p_copy_redo_flag => l_copy_redo_flag
	          );
		  end if; -- /* if l_user_id1 */
		end if; -- /* if G_UPDATE_MODE */
        -- If API call returns with an error status, upload aborts
        if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
        (l_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        end if; -- /* if l_return_status */
        if (l_copy_redo_flag) then
          G_PAGE_REDO_INDEX := G_PAGE_REDO_INDEX + 1;
          G_PAGE_REDO_TBL(G_PAGE_REDO_INDEX) := l_page_tbl(l_index);
          l_copy_redo_flag := FALSE;
        end if; /* if l_copy_redo_flag */
      end if; /* if l_page_tbl(l_index) exists */
    end loop;
  end if;

  -- Insert or update all interpage region relations to the database
  --
  --   Create or update interpage region relations to the database.
  --   All intrapage region relations were created while loading
  --   flow page regions.
  --
  if (l_relation_tbl.count > 0) then
    for l_index in l_relation_tbl.FIRST .. l_relation_tbl.LAST loop
      if (l_relation_tbl.exists(l_index)) then
        if AK_FLOW_PVT.REGION_RELATION_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_flow_application_id =>
                        l_relation_tbl(l_index).flow_application_id,
            p_flow_code => l_relation_tbl(l_index).flow_code,
            p_foreign_key_name => l_relation_tbl(l_index).foreign_key_name,
            p_from_page_appl_id => l_relation_tbl(l_index).from_page_appl_id,
            p_from_page_code => l_relation_tbl(l_index).from_page_code,
            p_from_region_appl_id =>
                        l_relation_tbl(l_index).from_region_appl_id,
            p_from_region_code => l_relation_tbl(l_index).from_region_code,
            p_to_page_appl_id => l_relation_tbl(l_index).to_page_appl_id,
            p_to_page_code => l_relation_tbl(l_index).to_page_code,
            p_to_region_appl_id =>
                        l_relation_tbl(l_index).to_region_appl_id,
            p_to_region_code => l_relation_tbl(l_index).to_region_code) then
          --
		  -- Update Flow Page Region Relation only if G_UPDATE_MODE is TRUE
		  --
		  if (AK_UPLOAD_GRP.G_UPDATE_MODE) then
            AK_FLOW_PVT.UPDATE_REGION_RELATION (
              p_validation_level => p_validation_level,
              p_api_version_number => 1.0,
              p_msg_count => l_msg_count,
              p_msg_data => l_msg_data,
              p_return_status => l_return_status,
              p_flow_application_id =>
                          l_relation_tbl(l_index).flow_application_id,
              p_flow_code => l_relation_tbl(l_index).flow_code,
              p_foreign_key_name => l_relation_tbl(l_index).foreign_key_name,
              p_from_page_appl_id => l_relation_tbl(l_index).from_page_appl_id,
              p_from_page_code => l_relation_tbl(l_index).from_page_code,
              p_from_region_appl_id =>
                          l_relation_tbl(l_index).from_region_appl_id,
              p_from_region_code => l_relation_tbl(l_index).from_region_code,
              p_to_page_appl_id => l_relation_tbl(l_index).to_page_appl_id,
              p_to_page_code => l_relation_tbl(l_index).to_page_code,
              p_to_region_appl_id =>
                          l_relation_tbl(l_index).to_region_appl_id,
              p_to_region_code => l_relation_tbl(l_index).to_region_code,
              p_application_id => l_relation_tbl(l_index).application_id,
              p_attribute_category => l_relation_tbl(l_index).attribute_category,
			  p_attribute1 => l_relation_tbl(l_index).attribute1,
			  p_attribute2 => l_relation_tbl(l_index).attribute2,
			  p_attribute3 => l_relation_tbl(l_index).attribute3,
			  p_attribute4 => l_relation_tbl(l_index).attribute4,
			  p_attribute5 => l_relation_tbl(l_index).attribute5,
			  p_attribute6 => l_relation_tbl(l_index).attribute6,
			  p_attribute7 => l_relation_tbl(l_index).attribute7,
			  p_attribute8 => l_relation_tbl(l_index).attribute8,
			  p_attribute9 => l_relation_tbl(l_index).attribute9,
			  p_attribute10 => l_relation_tbl(l_index).attribute10,
			  p_attribute11 => l_relation_tbl(l_index).attribute11,
			  p_attribute12 => l_relation_tbl(l_index).attribute12,
			  p_attribute13 => l_relation_tbl(l_index).attribute13,
			  p_attribute14 => l_relation_tbl(l_index).attribute14,
			  p_attribute15 => l_relation_tbl(l_index).attribute15,
        p_created_by  => l_relation_tbl(l_index).created_by,
        p_creation_date  => l_relation_tbl(l_index).creation_date,
        p_last_updated_by  => l_relation_tbl(l_index).last_updated_by,
        p_last_update_date  => l_relation_tbl(l_index).last_update_date,
        p_last_update_login  => l_relation_tbl(l_index).last_update_login,
              p_loader_timestamp => p_loader_timestamp,
  		      p_pass => p_pass,
              p_copy_redo_flag => l_copy_redo_flag
            );
		  elsif ( AK_UPLOAD_GRP.G_NO_CUSTOM_UPDATE ) then
		    select last_updated_by, last_update_date
			into l_user_id1, l_update1
			from ak_flow_region_relations
			where flow_code = l_relation_tbl(l_index).flow_code
			and flow_application_id = l_relation_tbl(l_index).flow_application_id
			and foreign_key_name = l_relation_tbl(l_index).foreign_key_name
			and from_page_code = l_relation_tbl(l_index).from_page_code
			and from_page_appl_id = l_relation_tbl(l_index).from_page_appl_id
			and from_region_code = l_relation_tbl(l_index).from_region_code
			and from_region_appl_id = l_relation_tbl(l_index).from_region_appl_id
			and to_page_code = l_relation_tbl(l_index).to_page_code
			and to_page_appl_id = l_relation_tbl(l_index).to_page_appl_id
			and to_region_code = l_relation_tbl(l_index).to_region_code
			and to_region_appl_id = l_relation_tbl(l_index).to_region_appl_id;

			/*if ( l_user_id1 = 1 or l_user_id1 = 2) then*/
                if AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
                      p_loader_timestamp => p_loader_timestamp,
                      p_created_by => l_relation_tbl(l_index).created_by,
                      p_creation_date => l_relation_tbl(l_index).creation_date,
                      p_last_updated_by => l_relation_tbl(l_index).last_updated_by,
                      p_db_last_updated_by => l_user_id1,
                      p_last_update_date => l_relation_tbl(l_index).last_update_date,
                      p_db_last_update_date => l_update1,
                      p_last_update_login => l_relation_tbl(l_index).last_update_login,
                      p_create_or_update => 'UPDATE') then

	            AK_FLOW_PVT.UPDATE_REGION_RELATION (
	              p_validation_level => p_validation_level,
	              p_api_version_number => 1.0,
	              p_msg_count => l_msg_count,
	              p_msg_data => l_msg_data,
	              p_return_status => l_return_status,
	              p_flow_application_id =>
	                          l_relation_tbl(l_index).flow_application_id,
	              p_flow_code => l_relation_tbl(l_index).flow_code,
	              p_foreign_key_name => l_relation_tbl(l_index).foreign_key_name,
	              p_from_page_appl_id => l_relation_tbl(l_index).from_page_appl_id,
	              p_from_page_code => l_relation_tbl(l_index).from_page_code,
	              p_from_region_appl_id =>
	                          l_relation_tbl(l_index).from_region_appl_id,
	              p_from_region_code => l_relation_tbl(l_index).from_region_code,
	              p_to_page_appl_id => l_relation_tbl(l_index).to_page_appl_id,
	              p_to_page_code => l_relation_tbl(l_index).to_page_code,
	              p_to_region_appl_id =>
	                          l_relation_tbl(l_index).to_region_appl_id,
	              p_to_region_code => l_relation_tbl(l_index).to_region_code,
	              p_application_id => l_relation_tbl(l_index).application_id,
	              p_attribute_category => l_relation_tbl(l_index).attribute_category,
				  p_attribute1 => l_relation_tbl(l_index).attribute1,
				  p_attribute2 => l_relation_tbl(l_index).attribute2,
				  p_attribute3 => l_relation_tbl(l_index).attribute3,
				  p_attribute4 => l_relation_tbl(l_index).attribute4,
				  p_attribute5 => l_relation_tbl(l_index).attribute5,
				  p_attribute6 => l_relation_tbl(l_index).attribute6,
				  p_attribute7 => l_relation_tbl(l_index).attribute7,
				  p_attribute8 => l_relation_tbl(l_index).attribute8,
				  p_attribute9 => l_relation_tbl(l_index).attribute9,
				  p_attribute10 => l_relation_tbl(l_index).attribute10,
				  p_attribute11 => l_relation_tbl(l_index).attribute11,
				  p_attribute12 => l_relation_tbl(l_index).attribute12,
				  p_attribute13 => l_relation_tbl(l_index).attribute13,
				  p_attribute14 => l_relation_tbl(l_index).attribute14,
				  p_attribute15 => l_relation_tbl(l_index).attribute15,
        p_created_by  => l_relation_tbl(l_index).created_by,
        p_creation_date  => l_relation_tbl(l_index).creation_date,
        p_last_updated_by  => l_relation_tbl(l_index).last_updated_by,
        p_last_update_date  => l_relation_tbl(l_index).last_update_date,
        p_last_update_login  => l_relation_tbl(l_index).last_update_login,
	              p_loader_timestamp => p_loader_timestamp,
	  		      p_pass => p_pass,
	              p_copy_redo_flag => l_copy_redo_flag
	            );
			end if; -- /* if l_user_id1 = 1 */
          end if; -- /* if G_UPDATE_MODE G_NO_CUSTOM_UPDATE */
        else
          AK_FLOW_PVT.CREATE_REGION_RELATION (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
            p_flow_application_id =>
                        l_relation_tbl(l_index).flow_application_id,
            p_flow_code => l_relation_tbl(l_index).flow_code,
            p_foreign_key_name => l_relation_tbl(l_index).foreign_key_name,
            p_from_page_appl_id => l_relation_tbl(l_index).from_page_appl_id,
            p_from_page_code => l_relation_tbl(l_index).from_page_code,
            p_from_region_appl_id =>
                        l_relation_tbl(l_index).from_region_appl_id,
            p_from_region_code => l_relation_tbl(l_index).from_region_code,
            p_to_page_appl_id => l_relation_tbl(l_index).to_page_appl_id,
            p_to_page_code => l_relation_tbl(l_index).to_page_code,
            p_to_region_appl_id =>
                        l_relation_tbl(l_index).to_region_appl_id,
            p_to_region_code => l_relation_tbl(l_index).to_region_code,
            p_application_id => l_relation_tbl(l_index).application_id,
            p_attribute_category => l_relation_tbl(l_index).attribute_category,
			p_attribute1 => l_relation_tbl(l_index).attribute1,
			p_attribute2 => l_relation_tbl(l_index).attribute2,
			p_attribute3 => l_relation_tbl(l_index).attribute3,
			p_attribute4 => l_relation_tbl(l_index).attribute4,
			p_attribute5 => l_relation_tbl(l_index).attribute5,
			p_attribute6 => l_relation_tbl(l_index).attribute6,
			p_attribute7 => l_relation_tbl(l_index).attribute7,
			p_attribute8 => l_relation_tbl(l_index).attribute8,
			p_attribute9 => l_relation_tbl(l_index).attribute9,
			p_attribute10 => l_relation_tbl(l_index).attribute10,
			p_attribute11 => l_relation_tbl(l_index).attribute11,
			p_attribute12 => l_relation_tbl(l_index).attribute12,
			p_attribute13 => l_relation_tbl(l_index).attribute13,
			p_attribute14 => l_relation_tbl(l_index).attribute14,
			p_attribute15 => l_relation_tbl(l_index).attribute15,
        p_created_by => l_relation_tbl(l_index).created_by,
        p_creation_date => l_relation_tbl(l_index).creation_date,
        p_last_updated_by => l_relation_tbl(l_index).last_updated_by,
        p_last_update_date => l_relation_tbl(l_index).last_update_date,
        p_last_update_login => l_relation_tbl(l_index).last_update_login,
            p_loader_timestamp => p_loader_timestamp,
  		    p_pass => p_pass,
            p_copy_redo_flag => l_copy_redo_flag
          );
        end if; -- /* if REGION_RELATION_EXISTS */
		--
        -- If API call returns with an error status, upload aborts
        if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
        (l_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        end if; -- /* if l_return_status */
        if (l_copy_redo_flag) then
          G_REGION_RELATION_REDO_INDEX := G_REGION_RELATION_REDO_INDEX + 1;
          G_REGION_RELATION_REDO_TBL(G_REGION_RELATION_REDO_INDEX) := l_relation_tbl(l_index);
          l_copy_redo_flag := FALSE;
        end if; /* if l_copy_redo_flag */
      end if;
    end loop;
  end if;

  -- Insert or update all page region items to the database
  --
  --   Create or update page region items to the database. This step
  --   must be done after all region relations have been loaded, since
  --   page region items (or links) depends on region relations.
  --
  if (l_item_tbl.count > 0) then
    for l_index in l_item_tbl.FIRST .. l_item_tbl.LAST loop
      if (l_item_tbl.exists(l_index)) then
        if AK_FLOW_PVT.PAGE_REGION_ITEM_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_flow_application_id =>
                        l_item_tbl(l_index).flow_application_id,
            p_flow_code => l_item_tbl(l_index).flow_code,
            p_page_application_id =>
                        l_item_tbl(l_index).page_application_id,
            p_page_code => l_item_tbl(l_index).page_code,
            p_region_application_id =>
                        l_item_tbl(l_index).region_application_id,
            p_region_code => l_item_tbl(l_index).region_code,
            p_attribute_application_id =>
                        l_item_tbl(l_index).attribute_application_id,
            p_attribute_code => l_item_tbl(l_index).attribute_code) then
          --
		  -- Update Flow Page Region Item only if G_UPDATE_MODE is TRUE
		  --
		  if (AK_UPLOAD_GRP.G_UPDATE_MODE) then
            AK_FLOW_PVT.UPDATE_PAGE_REGION_ITEM (
               p_validation_level => p_validation_level,
               p_api_version_number => 1.0,
               p_msg_count => l_msg_count,
               p_msg_data => l_msg_data,
               p_return_status => l_return_status,
               p_flow_application_id =>
                           l_item_tbl(l_index).flow_application_id,
               p_flow_code => l_item_tbl(l_index).flow_code,
               p_page_application_id =>
                           l_item_tbl(l_index).page_application_id,
               p_page_code => l_item_tbl(l_index).page_code,
               p_region_application_id =>
                           l_item_tbl(l_index).region_application_id,
               p_region_code => l_item_tbl(l_index).region_code,
               p_attribute_application_id =>
                           l_item_tbl(l_index).attribute_application_id,
               p_attribute_code => l_item_tbl(l_index).attribute_code,
               p_to_page_appl_id => l_item_tbl(l_index).to_page_appl_id,
               p_to_page_code => l_item_tbl(l_index).to_page_code,
               p_to_url_attribute_appl_id =>
                           l_item_tbl(l_index).to_url_attribute_appl_id,
               p_to_url_attribute_code =>
                           l_item_tbl(l_index).to_url_attribute_code,
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
        p_created_by  => l_item_tbl(l_index).created_by,
        p_creation_date  => l_item_tbl(l_index).creation_date,
        p_last_updated_by  => l_item_tbl(l_index).last_updated_by,
        p_last_update_date  => l_item_tbl(l_index).last_update_date,
        p_last_update_login  => l_item_tbl(l_index).last_update_login,
               p_loader_timestamp => p_loader_timestamp,
               p_pass => p_pass,
               p_copy_redo_flag => l_copy_redo_flag
             );
		  elsif ( AK_UPLOAD_GRP.G_NO_CUSTOM_UPDATE ) then
		    select last_updated_by, last_update_date
			into l_user_id1, l_update1
			from ak_flow_page_region_items
			where flow_code = l_item_tbl(l_index).flow_code
			and flow_application_id = l_item_tbl(l_index).flow_application_id
			and page_code = l_item_tbl(l_index).page_code
			and page_application_id = l_item_tbl(l_index).page_application_id
			and region_code = l_item_tbl(l_index).region_code
			and region_application_id = l_item_tbl(l_index).region_application_id
			and attribute_code = l_item_tbl(l_index).attribute_code
			and attribute_application_id = l_item_tbl(l_index).attribute_application_id;
			/*if ( l_user_id1 = 1 or l_user_id1 = 2) then*/
                if AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
                      p_loader_timestamp => p_loader_timestamp,
                      p_created_by => l_item_tbl(l_index).created_by,
                      p_creation_date => l_item_tbl(l_index).creation_date,
                      p_last_updated_by => l_item_tbl(l_index).last_updated_by,
                      p_db_last_updated_by => l_user_id1,
                      p_last_update_date => l_item_tbl(l_index).last_update_date,
                      p_db_last_update_date => l_update1,
                      p_last_update_login => l_item_tbl(l_index).last_update_login,
                      p_create_or_update => 'UPDATE') then

	            AK_FLOW_PVT.UPDATE_PAGE_REGION_ITEM (
	               p_validation_level => p_validation_level,
	               p_api_version_number => 1.0,
	               p_msg_count => l_msg_count,
	               p_msg_data => l_msg_data,
	               p_return_status => l_return_status,
	               p_flow_application_id =>
	                           l_item_tbl(l_index).flow_application_id,
	               p_flow_code => l_item_tbl(l_index).flow_code,
	               p_page_application_id =>
	                           l_item_tbl(l_index).page_application_id,
	               p_page_code => l_item_tbl(l_index).page_code,
	               p_region_application_id =>
	                           l_item_tbl(l_index).region_application_id,
	               p_region_code => l_item_tbl(l_index).region_code,
	               p_attribute_application_id =>
	                           l_item_tbl(l_index).attribute_application_id,
	               p_attribute_code => l_item_tbl(l_index).attribute_code,
	               p_to_page_appl_id => l_item_tbl(l_index).to_page_appl_id,
	               p_to_page_code => l_item_tbl(l_index).to_page_code,
	               p_to_url_attribute_appl_id =>
	                           l_item_tbl(l_index).to_url_attribute_appl_id,
	               p_to_url_attribute_code =>
	                           l_item_tbl(l_index).to_url_attribute_code,
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
        p_created_by  => l_item_tbl(l_index).created_by,
        p_creation_date  => l_item_tbl(l_index).creation_date,
        p_last_updated_by  => l_item_tbl(l_index).last_updated_by,
        p_last_update_date  => l_item_tbl(l_index).last_update_date,
        p_last_update_login  => l_item_tbl(l_index).last_update_login,
	               p_loader_timestamp => p_loader_timestamp,
	               p_pass => p_pass,
	               p_copy_redo_flag => l_copy_redo_flag
	             );
			end if; -- /* if l_user_id1 = 1 */
		  end if; -- /* if G_UPDATE_MODE G_NO_CUSTOM_UPDATE */
        else
          AK_FLOW_PVT.CREATE_PAGE_REGION_ITEM (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
            p_flow_application_id =>
                        l_item_tbl(l_index).flow_application_id,
            p_flow_code => l_item_tbl(l_index).flow_code,
            p_page_application_id =>
                        l_item_tbl(l_index).page_application_id,
            p_page_code => l_item_tbl(l_index).page_code,
            p_region_application_id =>
                        l_item_tbl(l_index).region_application_id,
            p_region_code => l_item_tbl(l_index).region_code,
            p_attribute_application_id =>
                        l_item_tbl(l_index).attribute_application_id,
            p_attribute_code => l_item_tbl(l_index).attribute_code,
            p_to_page_appl_id => l_item_tbl(l_index).to_page_appl_id,
            p_to_page_code => l_item_tbl(l_index).to_page_code,
            p_to_url_attribute_appl_id =>
                        l_item_tbl(l_index).to_url_attribute_appl_id,
            p_to_url_attribute_code =>
                        l_item_tbl(l_index).to_url_attribute_code,
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
        p_created_by => l_item_tbl(l_index).created_by,
        p_creation_date => l_item_tbl(l_index).creation_date,
        p_last_updated_by => l_item_tbl(l_index).last_updated_by,
        p_last_update_date => l_item_tbl(l_index).last_update_date,
        p_last_update_login => l_item_tbl(l_index).last_update_login,
            p_loader_timestamp => p_loader_timestamp,
  		    p_pass => p_pass,
            p_copy_redo_flag => l_copy_redo_flag
          );
        end if; -- /* if PAGE_REGION_ITEM_EXISTS */
		--
        -- If API call returns with an error status, upload aborts
        if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
        (l_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        end if; -- /* if l_return_status */
      end if;
    end loop;
  end if;

  --
  -- Load line number of the last file line processed
  --
  p_line_num_out := l_line_num;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- dbms_output.put_line('Leaving flow upload:'  ||
  --                            to_char(sysdate, 'MON-DD HH24:MI:SS'));

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
  WHEN VALUE_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('AK','AK_FLOW_VALUE_ERROR');
    FND_MESSAGE.SET_TOKEN('KEY',to_char(l_flow_rec.flow_application_id)||' '||
    						l_flow_rec.flow_code);
    FND_MSG_PUB.Add;
	FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240)||': '||l_column||'='||l_token );
	FND_MSG_PUB.Add;
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;
end UPLOAD_FLOW;

--=======================================================
--  Procedure   UPLOAD_FLOW_SECOND
--
--  Usage       Private API for loading flows that were
--              failed during its first pass
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API reads the flow data from PL/SQL table
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
procedure UPLOAD_FLOW_SECOND (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
  p_pass                     IN      NUMBER := 2
) is
  l_api_name                 CONSTANT varchar2(30) := 'Upload_Object_Second';
  l_rec_index                NUMBER;
  l_return_status            VARCHAR2(1);
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(240);
  l_copy_redo_flag           BOOLEAN := FALSE;
begin
  -- Create new flows to the database
  --
  -- - Create flows that are not already in the database. Since it is
  --   very likely that there are no pages for these new flows,
  --   these flows will be created without specifying their primary pages.
  --   Later in this procedure, they will be updated with the appropriate
  --   primary pages once all the flow pages are loaded.
  --
  --   Existing flows will also be updated with new data at that time.
  --
  if (G_FLOW_REDO_INDEX > 0) then

  -- dbms_output.put_line('number of redo flows: '||to_char(G_FLOW_REDO_INDEX));

    for l_index in G_FLOW_REDO_TBL.FIRST .. G_FLOW_REDO_TBL.LAST loop
      if (G_FLOW_REDO_TBL.exists(l_index)) then
        if NOT AK_FLOW_PVT.FLOW_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_flow_application_id =>
                        G_FLOW_REDO_TBL(l_index).flow_application_id,
            p_flow_code => G_FLOW_REDO_TBL(l_index).flow_code) then
          AK_FLOW_PVT.CREATE_FLOW (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
            p_flow_application_id =>
                        G_FLOW_REDO_TBL(l_index).flow_application_id,
            p_flow_code => G_FLOW_REDO_TBL(l_index).flow_code,
            p_name => G_FLOW_REDO_TBL(l_index).name,
            p_description => G_FLOW_REDO_TBL(l_index).description,
        p_created_by => G_FLOW_REDO_TBL(l_index).created_by,
        p_creation_date => G_FLOW_REDO_TBL(l_index).creation_date,
        p_last_updated_by => G_FLOW_REDO_TBL(l_index).last_updated_by,
        p_last_update_date => G_FLOW_REDO_TBL(l_index).last_update_date,
        p_last_update_login => G_FLOW_REDO_TBL(l_index).last_update_login,
            p_loader_timestamp => p_loader_timestamp,
  		    p_pass => p_pass,
            p_copy_redo_flag => l_copy_redo_flag
          );

            -- If API call returns with an error status...
            if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
            (l_return_status = FND_API.G_RET_STS_ERROR) then
              RAISE FND_API.G_EXC_ERROR;
            end if;
        end if; -- /* if AK_FLOW_PVT.FLOW_EXISTS */
      end if;
    end loop;
  end if;

  -- Create new flow pages to the database
  --
  -- - Create flow pages that are not already in the database. Since it is
  --   very likely that there are no page regions for these new flows,
  --   these flow pages will be created without specifying any  primary
  --   page regions.
  --   Later in this procedure, they will be updated with the appropriate
  --   primary regions once all the flow page regions are loaded.
  --
  --   Existing flow pages will also be updated with new data at that time.
  --
  if (G_PAGE_REDO_INDEX > 0) then
  -- dbms_output.put_line('number of redo pages: '||to_char(G_PAGE_REDO_INDEX));
    for l_index in G_PAGE_REDO_TBL.FIRST .. G_PAGE_REDO_TBL.LAST loop
      if (G_PAGE_REDO_TBL.exists(l_index)) then
        if NOT AK_FLOW_PVT.PAGE_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_flow_application_id =>
                        G_PAGE_REDO_TBL(l_index).flow_application_id,
            p_flow_code => G_PAGE_REDO_TBL(l_index).flow_code,
            p_page_application_id =>
                        G_PAGE_REDO_TBL(l_index).page_application_id,
            p_page_code => G_PAGE_REDO_TBL(l_index).page_code) then
          AK_FLOW_PVT.CREATE_PAGE (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
            p_flow_application_id =>
                        G_PAGE_REDO_TBL(l_index).flow_application_id,
            p_flow_code => G_PAGE_REDO_TBL(l_index).flow_code,
            p_page_application_id =>
                        G_PAGE_REDO_TBL(l_index).page_application_id,
            p_page_code => G_PAGE_REDO_TBL(l_index).page_code,
            p_attribute_category => G_PAGE_REDO_TBL(l_index).attribute_category,
			p_attribute1 => G_PAGE_REDO_TBL(l_index).attribute1,
			p_attribute2 => G_PAGE_REDO_TBL(l_index).attribute2,
			p_attribute3 => G_PAGE_REDO_TBL(l_index).attribute3,
			p_attribute4 => G_PAGE_REDO_TBL(l_index).attribute4,
			p_attribute5 => G_PAGE_REDO_TBL(l_index).attribute5,
			p_attribute6 => G_PAGE_REDO_TBL(l_index).attribute6,
			p_attribute7 => G_PAGE_REDO_TBL(l_index).attribute7,
			p_attribute8 => G_PAGE_REDO_TBL(l_index).attribute8,
			p_attribute9 => G_PAGE_REDO_TBL(l_index).attribute9,
			p_attribute10 => G_PAGE_REDO_TBL(l_index).attribute10,
			p_attribute11 => G_PAGE_REDO_TBL(l_index).attribute11,
			p_attribute12 => G_PAGE_REDO_TBL(l_index).attribute12,
			p_attribute13 => G_PAGE_REDO_TBL(l_index).attribute13,
			p_attribute14 => G_PAGE_REDO_TBL(l_index).attribute14,
			p_attribute15 => G_PAGE_REDO_TBL(l_index).attribute15,
            p_name => G_PAGE_REDO_TBL(l_index).name,
            p_description => G_PAGE_REDO_TBL(l_index).description,
        p_created_by => G_PAGE_REDO_TBL(l_index).created_by,
        p_creation_date => G_PAGE_REDO_TBL(l_index).creation_date,
        p_last_updated_by => G_PAGE_REDO_TBL(l_index).last_updated_by,
        p_last_update_date => G_PAGE_REDO_TBL(l_index).last_update_date,
        p_last_update_login => G_PAGE_REDO_TBL(l_index).last_update_login,
            p_loader_timestamp => p_loader_timestamp,
  		    p_pass => p_pass,
            p_copy_redo_flag => l_copy_redo_flag
          );

            -- If API call returns with an error status..., abort upload
            if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
            (l_return_status = FND_API.G_RET_STS_ERROR) then
              RAISE FND_API.G_EXC_ERROR;
            end if;
        end if; -- /* if PAGE_EXISTS */
      end if;
    end loop;
  end if;

  -- Update primary page columns for new flows, and update all columns
  -- for existing flows.
  --
  --   Now that all flow pages have been loaded into the database,
  --   we can load the primary page columns for all new flows that
  --   has a primary page. Existing flows are also updated with new
  --   data in the loader file at this time.
  --
  if (G_FLOW_REDO_TBL.count > 0) then
    for l_index in G_FLOW_REDO_TBL.FIRST .. G_FLOW_REDO_TBL.LAST loop
      if (G_FLOW_REDO_TBL.exists(l_index)) then
         AK_FLOW_PVT.UPDATE_FLOW (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
            p_flow_application_id =>
                        G_FLOW_REDO_TBL(l_index).flow_application_id,
            p_flow_code => G_FLOW_REDO_TBL(l_index).flow_code,
            p_name => G_FLOW_REDO_TBL(l_index).name,
            p_description => G_FLOW_REDO_TBL(l_index).description,
            p_primary_page_appl_id => G_FLOW_REDO_TBL(l_index).primary_page_appl_id,
            p_primary_page_code => G_FLOW_REDO_TBL(l_index).primary_page_code,
            p_attribute_category => G_FLOW_REDO_TBL(l_index).attribute_category,
			p_attribute1 => G_FLOW_REDO_TBL(l_index).attribute1,
			p_attribute2 => G_FLOW_REDO_TBL(l_index).attribute2,
			p_attribute3 => G_FLOW_REDO_TBL(l_index).attribute3,
			p_attribute4 => G_FLOW_REDO_TBL(l_index).attribute4,
			p_attribute5 => G_FLOW_REDO_TBL(l_index).attribute5,
			p_attribute6 => G_FLOW_REDO_TBL(l_index).attribute6,
			p_attribute7 => G_FLOW_REDO_TBL(l_index).attribute7,
			p_attribute8 => G_FLOW_REDO_TBL(l_index).attribute8,
			p_attribute9 => G_FLOW_REDO_TBL(l_index).attribute9,
			p_attribute10 => G_FLOW_REDO_TBL(l_index).attribute10,
			p_attribute11 => G_FLOW_REDO_TBL(l_index).attribute11,
			p_attribute12 => G_FLOW_REDO_TBL(l_index).attribute12,
			p_attribute13 => G_FLOW_REDO_TBL(l_index).attribute13,
			p_attribute14 => G_FLOW_REDO_TBL(l_index).attribute14,
			p_attribute15 => G_FLOW_REDO_TBL(l_index).attribute15,
        p_created_by  => G_FLOW_REDO_TBL(l_index).created_by,
        p_creation_date  => G_FLOW_REDO_TBL(l_index).creation_date,
        p_last_updated_by  => G_FLOW_REDO_TBL(l_index).last_updated_by,
        p_last_update_date  => G_FLOW_REDO_TBL(l_index).last_update_date,
        p_last_update_login  => G_FLOW_REDO_TBL(l_index).last_update_login,
            p_loader_timestamp => p_loader_timestamp,
  		    p_pass => p_pass,
            p_copy_redo_flag => l_copy_redo_flag
          );
      end if;
    end loop;
  end if;

  -- Insert or update all page regions to the database
  --
  --   Since not all page regions exists in the database, we are
  --   creating new page regions with parent regions set to null.
  --   Update to certain page regions with a parent region will
  --   fail due to the same reason.
  --   Later in this procedure, they will be updated with the appropriate
  --   parent regions once all the page regions are loaded.
  --
  if (G_PAGE_REGION_REDO_INDEX > 0) then
  -- dbms_output.put_line('number of redo page regions: '||to_char(G_PAGE_REGION_REDO_INDEX));
    for l_index in G_PAGE_REGION_REDO_TBL.FIRST .. G_PAGE_REGION_REDO_TBL.LAST loop
      if (G_PAGE_REGION_REDO_TBL.exists(l_index)) then
        if AK_FLOW_PVT.PAGE_REGION_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_flow_application_id =>
                        G_PAGE_REGION_REDO_TBL(l_index).flow_application_id,
            p_flow_code => G_PAGE_REGION_REDO_TBL(l_index).flow_code,
            p_page_application_id =>
                        G_PAGE_REGION_REDO_TBL(l_index).page_application_id,
            p_page_code => G_PAGE_REGION_REDO_TBL(l_index).page_code,
            p_region_application_id =>
                        G_PAGE_REGION_REDO_TBL(l_index).region_application_id,
            p_region_code => G_PAGE_REGION_REDO_TBL(l_index).region_code) then
          AK_FLOW_PVT.UPDATE_PAGE_REGION (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
            p_flow_application_id =>
                        G_PAGE_REGION_REDO_TBL(l_index).flow_application_id,
            p_flow_code => G_PAGE_REGION_REDO_TBL(l_index).flow_code,
            p_page_application_id =>
                        G_PAGE_REGION_REDO_TBL(l_index).page_application_id,
            p_page_code => G_PAGE_REGION_REDO_TBL(l_index).page_code,
            p_region_application_id =>
                        G_PAGE_REGION_REDO_TBL(l_index).region_application_id,
            p_region_code => G_PAGE_REGION_REDO_TBL(l_index).region_code,
            p_display_sequence => G_PAGE_REGION_REDO_TBL(l_index).display_sequence,
            p_region_style => G_PAGE_REGION_REDO_TBL(l_index).region_style,
            p_num_columns => G_PAGE_REGION_REDO_TBL(l_index).num_columns,
            p_icx_custom_call => G_PAGE_REGION_REDO_TBL(l_index).icx_custom_call,
            p_parent_region_application_id =>
                        G_PAGE_REGION_REDO_TBL(l_index).parent_region_appl_id,
            p_parent_region_code => G_PAGE_REGION_REDO_TBL(l_index).parent_region_code,
            p_foreign_key_name => G_PAGE_REGION_REDO_TBL(l_index).foreign_key_name,
            p_attribute_category => G_PAGE_REGION_REDO_TBL(l_index).attribute_category,
			p_attribute1 => G_PAGE_REGION_REDO_TBL(l_index).attribute1,
			p_attribute2 => G_PAGE_REGION_REDO_TBL(l_index).attribute2,
			p_attribute3 => G_PAGE_REGION_REDO_TBL(l_index).attribute3,
			p_attribute4 => G_PAGE_REGION_REDO_TBL(l_index).attribute4,
			p_attribute5 => G_PAGE_REGION_REDO_TBL(l_index).attribute5,
			p_attribute6 => G_PAGE_REGION_REDO_TBL(l_index).attribute6,
			p_attribute7 => G_PAGE_REGION_REDO_TBL(l_index).attribute7,
			p_attribute8 => G_PAGE_REGION_REDO_TBL(l_index).attribute8,
			p_attribute9 => G_PAGE_REGION_REDO_TBL(l_index).attribute9,
			p_attribute10 => G_PAGE_REGION_REDO_TBL(l_index).attribute10,
			p_attribute11 => G_PAGE_REGION_REDO_TBL(l_index).attribute11,
			p_attribute12 => G_PAGE_REGION_REDO_TBL(l_index).attribute12,
			p_attribute13 => G_PAGE_REGION_REDO_TBL(l_index).attribute13,
			p_attribute14 => G_PAGE_REGION_REDO_TBL(l_index).attribute14,
			p_attribute15 => G_PAGE_REGION_REDO_TBL(l_index).attribute15,
                p_created_by => G_PAGE_REGION_REDO_TBL(l_index).created_by,
                p_creation_date => G_PAGE_REGION_REDO_TBL(l_index).creation_date,
                p_last_updated_by => G_PAGE_REGION_REDO_TBL(l_index).last_updated_by,
                p_last_update_date => G_PAGE_REGION_REDO_TBL(l_index).last_update_date,
                p_last_update_login => G_PAGE_REGION_REDO_TBL(l_index).last_update_login,
            p_loader_timestamp => p_loader_timestamp,
  		    p_pass => p_pass,
            p_copy_redo_flag => l_copy_redo_flag
          );
        else
          AK_FLOW_PVT.CREATE_PAGE_REGION (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
            p_flow_application_id =>
                        G_PAGE_REGION_REDO_TBL(l_index).flow_application_id,
            p_flow_code => G_PAGE_REGION_REDO_TBL(l_index).flow_code,
            p_page_application_id =>
                        G_PAGE_REGION_REDO_TBL(l_index).page_application_id,
            p_page_code => G_PAGE_REGION_REDO_TBL(l_index).page_code,
            p_region_application_id =>
                        G_PAGE_REGION_REDO_TBL(l_index).region_application_id,
            p_region_code => G_PAGE_REGION_REDO_TBL(l_index).region_code,
            p_display_sequence => G_PAGE_REGION_REDO_TBL(l_index).display_sequence,
            p_region_style => G_PAGE_REGION_REDO_TBL(l_index).region_style,
            p_num_columns => G_PAGE_REGION_REDO_TBL(l_index).num_columns,
            p_icx_custom_call => G_PAGE_REGION_REDO_TBL(l_index).icx_custom_call,
            p_parent_region_application_id => null,
            p_parent_region_code => null,
            p_foreign_key_name => null,
            p_attribute_category => G_PAGE_REGION_REDO_TBL(l_index).attribute_category,
			p_attribute1 => G_PAGE_REGION_REDO_TBL(l_index).attribute1,
			p_attribute2 => G_PAGE_REGION_REDO_TBL(l_index).attribute2,
			p_attribute3 => G_PAGE_REGION_REDO_TBL(l_index).attribute3,
			p_attribute4 => G_PAGE_REGION_REDO_TBL(l_index).attribute4,
			p_attribute5 => G_PAGE_REGION_REDO_TBL(l_index).attribute5,
			p_attribute6 => G_PAGE_REGION_REDO_TBL(l_index).attribute6,
			p_attribute7 => G_PAGE_REGION_REDO_TBL(l_index).attribute7,
			p_attribute8 => G_PAGE_REGION_REDO_TBL(l_index).attribute8,
			p_attribute9 => G_PAGE_REGION_REDO_TBL(l_index).attribute9,
			p_attribute10 => G_PAGE_REGION_REDO_TBL(l_index).attribute10,
			p_attribute11 => G_PAGE_REGION_REDO_TBL(l_index).attribute11,
			p_attribute12 => G_PAGE_REGION_REDO_TBL(l_index).attribute12,
			p_attribute13 => G_PAGE_REGION_REDO_TBL(l_index).attribute13,
			p_attribute14 => G_PAGE_REGION_REDO_TBL(l_index).attribute14,
			p_attribute15 => G_PAGE_REGION_REDO_TBL(l_index).attribute15,
        p_created_by => G_PAGE_REGION_REDO_TBL(l_index).created_by,
        p_creation_date => G_PAGE_REGION_REDO_TBL(l_index).creation_date,
        p_last_updated_by => G_PAGE_REGION_REDO_TBL(l_index).last_updated_by,
        p_last_update_date => G_PAGE_REGION_REDO_TBL(l_index).last_update_date,
        p_last_update_login => G_PAGE_REGION_REDO_TBL(l_index).last_update_login,
            p_loader_timestamp => p_loader_timestamp,
  		    p_pass => p_pass,
            p_copy_redo_flag => l_copy_redo_flag
          );
        end if;	-- /* if PAGE_REGION_EXISTS */
		--
        -- If API call returns with an error status, upload aborts
        if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
        (l_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        end if; -- /* if l_return_status */
      end if; -- /* if G_PAGE_REGION_REDO_TBL.exists */
    end loop;
  end if;

  -- Update parent region columns for page regions
  --
  --   Now that all page regions have been loaded into the database,
  --   we can load the parent region columns for all page regions that
  --   has a parent region.
  --
  --   Intrapage region relations are created in UPDATE_PAGE_REGION when
  --   a parent region is specified.
  --
  if (G_PAGE_REGION_REDO_INDEX > 0) then
    for l_index in G_PAGE_REGION_REDO_TBL.FIRST .. G_PAGE_REGION_REDO_TBL.LAST loop
      if (G_PAGE_REGION_REDO_TBL.exists(l_index)) then
        if ( (G_PAGE_REGION_REDO_TBL(l_index).parent_region_appl_id is not null) or
             (G_PAGE_REGION_REDO_TBL(l_index).parent_region_code is not null) ) then
         AK_FLOW_PVT.UPDATE_PAGE_REGION (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
            p_flow_application_id =>
                        G_PAGE_REGION_REDO_TBL(l_index).flow_application_id,
            p_flow_code => G_PAGE_REGION_REDO_TBL(l_index).flow_code,
            p_page_application_id =>
                        G_PAGE_REGION_REDO_TBL(l_index).page_application_id,
            p_page_code => G_PAGE_REGION_REDO_TBL(l_index).page_code,
            p_region_application_id =>
                        G_PAGE_REGION_REDO_TBL(l_index).region_application_id,
            p_region_code => G_PAGE_REGION_REDO_TBL(l_index).region_code,
            p_parent_region_application_id =>
                        G_PAGE_REGION_REDO_TBL(l_index).parent_region_appl_id,
            p_parent_region_code => G_PAGE_REGION_REDO_TBL(l_index).parent_region_code,
            p_attribute_category => G_PAGE_REGION_REDO_TBL(l_index).attribute_category,
			p_attribute1 => G_PAGE_REGION_REDO_TBL(l_index).attribute1,
			p_attribute2 => G_PAGE_REGION_REDO_TBL(l_index).attribute2,
			p_attribute3 => G_PAGE_REGION_REDO_TBL(l_index).attribute3,
			p_attribute4 => G_PAGE_REGION_REDO_TBL(l_index).attribute4,
			p_attribute5 => G_PAGE_REGION_REDO_TBL(l_index).attribute5,
			p_attribute6 => G_PAGE_REGION_REDO_TBL(l_index).attribute6,
			p_attribute7 => G_PAGE_REGION_REDO_TBL(l_index).attribute7,
			p_attribute8 => G_PAGE_REGION_REDO_TBL(l_index).attribute8,
			p_attribute9 => G_PAGE_REGION_REDO_TBL(l_index).attribute9,
			p_attribute10 => G_PAGE_REGION_REDO_TBL(l_index).attribute10,
			p_attribute11 => G_PAGE_REGION_REDO_TBL(l_index).attribute11,
			p_attribute12 => G_PAGE_REGION_REDO_TBL(l_index).attribute12,
			p_attribute13 => G_PAGE_REGION_REDO_TBL(l_index).attribute13,
			p_attribute14 => G_PAGE_REGION_REDO_TBL(l_index).attribute14,
			p_attribute15 => G_PAGE_REGION_REDO_TBL(l_index).attribute15,
            p_foreign_key_name => G_PAGE_REGION_REDO_TBL(l_index).foreign_key_name,
                p_created_by => G_PAGE_REGION_REDO_TBL(l_index).created_by,
                p_creation_date => G_PAGE_REGION_REDO_TBL(l_index).creation_date,
                p_last_updated_by => G_PAGE_REGION_REDO_TBL(l_index).last_updated_by,
                p_last_update_date => G_PAGE_REGION_REDO_TBL(l_index).last_update_date,
                p_last_update_login => G_PAGE_REGION_REDO_TBL(l_index).last_update_login,
            p_loader_timestamp => p_loader_timestamp,
  		    p_pass => p_pass,
            p_copy_redo_flag => l_copy_redo_flag
          );
        end if;
      end if;
    end loop;
  end if;

  -- Update primary region columns for new flow pages, and update all columns
  -- for existing flow pages.
  --
  --   Now that all flow page regions have been loaded into the database,
  --   we can load the primary region columns for all new flow pages that
  --   has a primary region. Existing flow pages are also updated with new
  --   data in the loader file at this time.
  --
  if (G_PAGE_REDO_TBL.count > 0) then
    for l_index in G_PAGE_REDO_TBL.FIRST .. G_PAGE_REDO_TBL.LAST loop
      if (G_PAGE_REDO_TBL.exists(l_index)) then
         AK_FLOW_PVT.UPDATE_PAGE (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
            p_flow_application_id =>
                        G_PAGE_REDO_TBL(l_index).flow_application_id,
            p_flow_code => G_PAGE_REDO_TBL(l_index).flow_code,
            p_page_application_id =>
                        G_PAGE_REDO_TBL(l_index).page_application_id,
            p_page_code => G_PAGE_REDO_TBL(l_index).page_code,
            p_name => G_PAGE_REDO_TBL(l_index).name,
            p_description => G_PAGE_REDO_TBL(l_index).description,
            p_primary_region_appl_id =>
                        G_PAGE_REDO_TBL(l_index).primary_region_appl_id,
            p_primary_region_code => G_PAGE_REDO_TBL(l_index).primary_region_code,
            p_attribute_category => G_PAGE_REDO_TBL(l_index).attribute_category,
			p_attribute1 => G_PAGE_REDO_TBL(l_index).attribute1,
			p_attribute2 => G_PAGE_REDO_TBL(l_index).attribute2,
			p_attribute3 => G_PAGE_REDO_TBL(l_index).attribute3,
			p_attribute4 => G_PAGE_REDO_TBL(l_index).attribute4,
			p_attribute5 => G_PAGE_REDO_TBL(l_index).attribute5,
			p_attribute6 => G_PAGE_REDO_TBL(l_index).attribute6,
			p_attribute7 => G_PAGE_REDO_TBL(l_index).attribute7,
			p_attribute8 => G_PAGE_REDO_TBL(l_index).attribute8,
			p_attribute9 => G_PAGE_REDO_TBL(l_index).attribute9,
			p_attribute10 => G_PAGE_REDO_TBL(l_index).attribute10,
			p_attribute11 => G_PAGE_REDO_TBL(l_index).attribute11,
			p_attribute12 => G_PAGE_REDO_TBL(l_index).attribute12,
			p_attribute13 => G_PAGE_REDO_TBL(l_index).attribute13,
			p_attribute14 => G_PAGE_REDO_TBL(l_index).attribute14,
			p_attribute15 => G_PAGE_REDO_TBL(l_index).attribute15,
                p_created_by => G_PAGE_REDO_TBL(l_index).created_by,
                p_creation_date => G_PAGE_REDO_TBL(l_index).creation_date,
                p_last_updated_by => G_PAGE_REDO_TBL(l_index).last_updated_by,
                p_last_update_date => G_PAGE_REDO_TBL(l_index).last_update_date,
                p_last_update_login => G_PAGE_REDO_TBL(l_index).last_update_login,
            p_loader_timestamp => p_loader_timestamp,
  		    p_pass => p_pass,
            p_copy_redo_flag => l_copy_redo_flag
          );
      end if;
    end loop;
  end if;

  -- Insert or update all interpage region relations to the database
  --
  --   Create or update interpage region relations to the database.
  --   All intrapage region relations were created while loading
  --   flow page regions.
  --
  if (G_REGION_RELATION_REDO_INDEX > 0) then
    for l_index in G_REGION_RELATION_REDO_TBL.FIRST .. G_REGION_RELATION_REDO_TBL.LAST loop
      if (G_REGION_RELATION_REDO_TBL.exists(l_index)) then
        if AK_FLOW_PVT.REGION_RELATION_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_flow_application_id =>
                        G_REGION_RELATION_REDO_TBL(l_index).flow_application_id,
            p_flow_code => G_REGION_RELATION_REDO_TBL(l_index).flow_code,
            p_foreign_key_name => G_REGION_RELATION_REDO_TBL(l_index).foreign_key_name,
            p_from_page_appl_id => G_REGION_RELATION_REDO_TBL(l_index).from_page_appl_id,
            p_from_page_code => G_REGION_RELATION_REDO_TBL(l_index).from_page_code,
            p_from_region_appl_id =>
                        G_REGION_RELATION_REDO_TBL(l_index).from_region_appl_id,
            p_from_region_code => G_REGION_RELATION_REDO_TBL(l_index).from_region_code,
            p_to_page_appl_id => G_REGION_RELATION_REDO_TBL(l_index).to_page_appl_id,
            p_to_page_code => G_REGION_RELATION_REDO_TBL(l_index).to_page_code,
            p_to_region_appl_id =>
                        G_REGION_RELATION_REDO_TBL(l_index).to_region_appl_id,
            p_to_region_code => G_REGION_RELATION_REDO_TBL(l_index).to_region_code) then
          AK_FLOW_PVT.UPDATE_REGION_RELATION (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
            p_flow_application_id =>
                        G_REGION_RELATION_REDO_TBL(l_index).flow_application_id,
            p_flow_code => G_REGION_RELATION_REDO_TBL(l_index).flow_code,
            p_foreign_key_name => G_REGION_RELATION_REDO_TBL(l_index).foreign_key_name,
            p_from_page_appl_id => G_REGION_RELATION_REDO_TBL(l_index).from_page_appl_id,
            p_from_page_code => G_REGION_RELATION_REDO_TBL(l_index).from_page_code,
            p_from_region_appl_id =>
                        G_REGION_RELATION_REDO_TBL(l_index).from_region_appl_id,
            p_from_region_code => G_REGION_RELATION_REDO_TBL(l_index).from_region_code,
            p_to_page_appl_id => G_REGION_RELATION_REDO_TBL(l_index).to_page_appl_id,
            p_to_page_code => G_REGION_RELATION_REDO_TBL(l_index).to_page_code,
            p_to_region_appl_id =>
                        G_REGION_RELATION_REDO_TBL(l_index).to_region_appl_id,
            p_to_region_code => G_REGION_RELATION_REDO_TBL(l_index).to_region_code,
            p_application_id => G_REGION_RELATION_REDO_TBL(l_index).application_id,
            p_attribute_category => G_REGION_RELATION_REDO_TBL(l_index).attribute_category,
			p_attribute1 => G_REGION_RELATION_REDO_TBL(l_index).attribute1,
			p_attribute2 => G_REGION_RELATION_REDO_TBL(l_index).attribute2,
			p_attribute3 => G_REGION_RELATION_REDO_TBL(l_index).attribute3,
			p_attribute4 => G_REGION_RELATION_REDO_TBL(l_index).attribute4,
			p_attribute5 => G_REGION_RELATION_REDO_TBL(l_index).attribute5,
			p_attribute6 => G_REGION_RELATION_REDO_TBL(l_index).attribute6,
			p_attribute7 => G_REGION_RELATION_REDO_TBL(l_index).attribute7,
			p_attribute8 => G_REGION_RELATION_REDO_TBL(l_index).attribute8,
			p_attribute9 => G_REGION_RELATION_REDO_TBL(l_index).attribute9,
			p_attribute10 => G_REGION_RELATION_REDO_TBL(l_index).attribute10,
			p_attribute11 => G_REGION_RELATION_REDO_TBL(l_index).attribute11,
			p_attribute12 => G_REGION_RELATION_REDO_TBL(l_index).attribute12,
			p_attribute13 => G_REGION_RELATION_REDO_TBL(l_index).attribute13,
			p_attribute14 => G_REGION_RELATION_REDO_TBL(l_index).attribute14,
			p_attribute15 => G_REGION_RELATION_REDO_TBL(l_index).attribute15,
                p_created_by => G_REGION_RELATION_REDO_TBL(l_index).created_by,
                p_creation_date => G_REGION_RELATION_REDO_TBL(l_index).creation_date,
                p_last_updated_by => G_REGION_RELATION_REDO_TBL(l_index).last_updated_by,
                p_last_update_date => G_REGION_RELATION_REDO_TBL(l_index).last_update_date,
                p_last_update_login => G_REGION_RELATION_REDO_TBL(l_index).last_update_login,
            p_loader_timestamp => p_loader_timestamp,
  		    p_pass => p_pass,
            p_copy_redo_flag => l_copy_redo_flag
          );
        else
          AK_FLOW_PVT.CREATE_REGION_RELATION (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
            p_flow_application_id =>
                        G_REGION_RELATION_REDO_TBL(l_index).flow_application_id,
            p_flow_code => G_REGION_RELATION_REDO_TBL(l_index).flow_code,
            p_foreign_key_name => G_REGION_RELATION_REDO_TBL(l_index).foreign_key_name,
            p_from_page_appl_id => G_REGION_RELATION_REDO_TBL(l_index).from_page_appl_id,
            p_from_page_code => G_REGION_RELATION_REDO_TBL(l_index).from_page_code,
            p_from_region_appl_id =>
                        G_REGION_RELATION_REDO_TBL(l_index).from_region_appl_id,
            p_from_region_code => G_REGION_RELATION_REDO_TBL(l_index).from_region_code,
            p_to_page_appl_id => G_REGION_RELATION_REDO_TBL(l_index).to_page_appl_id,
            p_to_page_code => G_REGION_RELATION_REDO_TBL(l_index).to_page_code,
            p_to_region_appl_id =>
                        G_REGION_RELATION_REDO_TBL(l_index).to_region_appl_id,
            p_to_region_code => G_REGION_RELATION_REDO_TBL(l_index).to_region_code,
            p_application_id => G_REGION_RELATION_REDO_TBL(l_index).application_id,
            p_attribute_category => G_REGION_RELATION_REDO_TBL(l_index).attribute_category,
			p_attribute1 => G_REGION_RELATION_REDO_TBL(l_index).attribute1,
			p_attribute2 => G_REGION_RELATION_REDO_TBL(l_index).attribute2,
			p_attribute3 => G_REGION_RELATION_REDO_TBL(l_index).attribute3,
			p_attribute4 => G_REGION_RELATION_REDO_TBL(l_index).attribute4,
			p_attribute5 => G_REGION_RELATION_REDO_TBL(l_index).attribute5,
			p_attribute6 => G_REGION_RELATION_REDO_TBL(l_index).attribute6,
			p_attribute7 => G_REGION_RELATION_REDO_TBL(l_index).attribute7,
			p_attribute8 => G_REGION_RELATION_REDO_TBL(l_index).attribute8,
			p_attribute9 => G_REGION_RELATION_REDO_TBL(l_index).attribute9,
			p_attribute10 => G_REGION_RELATION_REDO_TBL(l_index).attribute10,
			p_attribute11 => G_REGION_RELATION_REDO_TBL(l_index).attribute11,
			p_attribute12 => G_REGION_RELATION_REDO_TBL(l_index).attribute12,
			p_attribute13 => G_REGION_RELATION_REDO_TBL(l_index).attribute13,
			p_attribute14 => G_REGION_RELATION_REDO_TBL(l_index).attribute14,
			p_attribute15 => G_REGION_RELATION_REDO_TBL(l_index).attribute15,
        p_created_by => G_REGION_RELATION_REDO_TBL(l_index).created_by,
        p_creation_date => G_REGION_RELATION_REDO_TBL(l_index).creation_date,
        p_last_updated_by => G_REGION_RELATION_REDO_TBL(l_index).last_updated_by,
        p_last_update_date => G_REGION_RELATION_REDO_TBL(l_index).last_update_date,
        p_last_update_login => G_REGION_RELATION_REDO_TBL(l_index).last_update_login,
            p_loader_timestamp => p_loader_timestamp,
  		    p_pass => p_pass,
            p_copy_redo_flag => l_copy_redo_flag
          );
        end if; -- /* if REGION_RELATION_EXISTS */
		--
        -- If API call returns with an error status, upload aborts
        if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
        (l_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        end if; -- /* if l_return_status */
      end if;
    end loop;
  end if;

  -- Insert or update all page region items to the database
  --
  --   Create or update page region items to the database. This step
  --   must be done after all region relations have been loaded, since
  --   page region items (or links) depends on region relations.
  --
  if (G_PAGE_REGION_ITEM_REDO_INDEX > 0) then
    for l_index in G_PAGE_REGION_ITEM_REDO_TBL.FIRST .. G_PAGE_REGION_ITEM_REDO_TBL.LAST loop
      if (G_PAGE_REGION_ITEM_REDO_TBL.exists(l_index)) then
        if AK_FLOW_PVT.PAGE_REGION_ITEM_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_flow_application_id =>
                        G_PAGE_REGION_ITEM_REDO_TBL(l_index).flow_application_id,
            p_flow_code => G_PAGE_REGION_ITEM_REDO_TBL(l_index).flow_code,
            p_page_application_id =>
                        G_PAGE_REGION_ITEM_REDO_TBL(l_index).page_application_id,
            p_page_code => G_PAGE_REGION_ITEM_REDO_TBL(l_index).page_code,
            p_region_application_id =>
                        G_PAGE_REGION_ITEM_REDO_TBL(l_index).region_application_id,
            p_region_code => G_PAGE_REGION_ITEM_REDO_TBL(l_index).region_code,
            p_attribute_application_id =>
                        G_PAGE_REGION_ITEM_REDO_TBL(l_index).attribute_application_id,
            p_attribute_code => G_PAGE_REGION_ITEM_REDO_TBL(l_index).attribute_code) then
          AK_FLOW_PVT.UPDATE_PAGE_REGION_ITEM (
             p_validation_level => p_validation_level,
             p_api_version_number => 1.0,
             p_msg_count => l_msg_count,
             p_msg_data => l_msg_data,
             p_return_status => l_return_status,
             p_flow_application_id =>
                         G_PAGE_REGION_ITEM_REDO_TBL(l_index).flow_application_id,
             p_flow_code => G_PAGE_REGION_ITEM_REDO_TBL(l_index).flow_code,
             p_page_application_id =>
                         G_PAGE_REGION_ITEM_REDO_TBL(l_index).page_application_id,
             p_page_code => G_PAGE_REGION_ITEM_REDO_TBL(l_index).page_code,
             p_region_application_id =>
                         G_PAGE_REGION_ITEM_REDO_TBL(l_index).region_application_id,
             p_region_code => G_PAGE_REGION_ITEM_REDO_TBL(l_index).region_code,
             p_attribute_application_id =>
                         G_PAGE_REGION_ITEM_REDO_TBL(l_index).attribute_application_id,
             p_attribute_code => G_PAGE_REGION_ITEM_REDO_TBL(l_index).attribute_code,
             p_to_page_appl_id => G_PAGE_REGION_ITEM_REDO_TBL(l_index).to_page_appl_id,
             p_to_page_code => G_PAGE_REGION_ITEM_REDO_TBL(l_index).to_page_code,
             p_to_url_attribute_appl_id =>
                         G_PAGE_REGION_ITEM_REDO_TBL(l_index).to_url_attribute_appl_id,
             p_to_url_attribute_code =>
                         G_PAGE_REGION_ITEM_REDO_TBL(l_index).to_url_attribute_code,
             p_attribute_category => G_PAGE_REGION_ITEM_REDO_TBL(l_index).attribute_category,
			 p_attribute1 => G_PAGE_REGION_ITEM_REDO_TBL(l_index).attribute1,
			 p_attribute2 => G_PAGE_REGION_ITEM_REDO_TBL(l_index).attribute2,
			 p_attribute3 => G_PAGE_REGION_ITEM_REDO_TBL(l_index).attribute3,
			 p_attribute4 => G_PAGE_REGION_ITEM_REDO_TBL(l_index).attribute4,
			 p_attribute5 => G_PAGE_REGION_ITEM_REDO_TBL(l_index).attribute5,
			 p_attribute6 => G_PAGE_REGION_ITEM_REDO_TBL(l_index).attribute6,
			 p_attribute7 => G_PAGE_REGION_ITEM_REDO_TBL(l_index).attribute7,
			 p_attribute8 => G_PAGE_REGION_ITEM_REDO_TBL(l_index).attribute8,
			 p_attribute9 => G_PAGE_REGION_ITEM_REDO_TBL(l_index).attribute9,
			 p_attribute10 => G_PAGE_REGION_ITEM_REDO_TBL(l_index).attribute10,
			 p_attribute11 => G_PAGE_REGION_ITEM_REDO_TBL(l_index).attribute11,
			 p_attribute12 => G_PAGE_REGION_ITEM_REDO_TBL(l_index).attribute12,
			 p_attribute13 => G_PAGE_REGION_ITEM_REDO_TBL(l_index).attribute13,
			 p_attribute14 => G_PAGE_REGION_ITEM_REDO_TBL(l_index).attribute14,
			 p_attribute15 => G_PAGE_REGION_ITEM_REDO_TBL(l_index).attribute15,
                p_created_by => G_PAGE_REGION_ITEM_REDO_TBL(l_index).created_by,
                p_creation_date => G_PAGE_REGION_ITEM_REDO_TBL(l_index).creation_date,
                p_last_updated_by => G_PAGE_REGION_ITEM_REDO_TBL(l_index).last_updated_by,
                p_last_update_date => G_PAGE_REGION_ITEM_REDO_TBL(l_index).last_update_date,
                p_last_update_login => G_PAGE_REGION_ITEM_REDO_TBL(l_index).last_update_login,
             p_loader_timestamp => p_loader_timestamp,
             p_pass => p_pass,
             p_copy_redo_flag => l_copy_redo_flag
           );
        else
          AK_FLOW_PVT.CREATE_PAGE_REGION_ITEM (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
            p_flow_application_id =>
                        G_PAGE_REGION_ITEM_REDO_TBL(l_index).flow_application_id,
            p_flow_code => G_PAGE_REGION_ITEM_REDO_TBL(l_index).flow_code,
            p_page_application_id =>
                        G_PAGE_REGION_ITEM_REDO_TBL(l_index).page_application_id,
            p_page_code => G_PAGE_REGION_ITEM_REDO_TBL(l_index).page_code,
            p_region_application_id =>
                        G_PAGE_REGION_ITEM_REDO_TBL(l_index).region_application_id,
            p_region_code => G_PAGE_REGION_ITEM_REDO_TBL(l_index).region_code,
            p_attribute_application_id =>
                        G_PAGE_REGION_ITEM_REDO_TBL(l_index).attribute_application_id,
            p_attribute_code => G_PAGE_REGION_ITEM_REDO_TBL(l_index).attribute_code,
            p_to_page_appl_id => G_PAGE_REGION_ITEM_REDO_TBL(l_index).to_page_appl_id,
            p_to_page_code => G_PAGE_REGION_ITEM_REDO_TBL(l_index).to_page_code,
            p_to_url_attribute_appl_id =>
                        G_PAGE_REGION_ITEM_REDO_TBL(l_index).to_url_attribute_appl_id,
            p_to_url_attribute_code =>
                        G_PAGE_REGION_ITEM_REDO_TBL(l_index).to_url_attribute_code,
            p_attribute_category => G_PAGE_REGION_ITEM_REDO_TBL(l_index).attribute_category,
			p_attribute1 => G_PAGE_REGION_ITEM_REDO_TBL(l_index).attribute1,
			p_attribute2 => G_PAGE_REGION_ITEM_REDO_TBL(l_index).attribute2,
			p_attribute3 => G_PAGE_REGION_ITEM_REDO_TBL(l_index).attribute3,
			p_attribute4 => G_PAGE_REGION_ITEM_REDO_TBL(l_index).attribute4,
			p_attribute5 => G_PAGE_REGION_ITEM_REDO_TBL(l_index).attribute5,
			p_attribute6 => G_PAGE_REGION_ITEM_REDO_TBL(l_index).attribute6,
			p_attribute7 => G_PAGE_REGION_ITEM_REDO_TBL(l_index).attribute7,
			p_attribute8 => G_PAGE_REGION_ITEM_REDO_TBL(l_index).attribute8,
			p_attribute9 => G_PAGE_REGION_ITEM_REDO_TBL(l_index).attribute9,
			p_attribute10 => G_PAGE_REGION_ITEM_REDO_TBL(l_index).attribute10,
			p_attribute11 => G_PAGE_REGION_ITEM_REDO_TBL(l_index).attribute11,
			p_attribute12 => G_PAGE_REGION_ITEM_REDO_TBL(l_index).attribute12,
			p_attribute13 => G_PAGE_REGION_ITEM_REDO_TBL(l_index).attribute13,
			p_attribute14 => G_PAGE_REGION_ITEM_REDO_TBL(l_index).attribute14,
			p_attribute15 => G_PAGE_REGION_ITEM_REDO_TBL(l_index).attribute15,
        p_created_by => G_PAGE_REGION_ITEM_REDO_TBL(l_index).created_by,
        p_creation_date => G_PAGE_REGION_ITEM_REDO_TBL(l_index).creation_date,
        p_last_updated_by => G_PAGE_REGION_ITEM_REDO_TBL(l_index).last_updated_by,
        p_last_update_date => G_PAGE_REGION_ITEM_REDO_TBL(l_index).last_update_date,
        p_last_update_login => G_PAGE_REGION_ITEM_REDO_TBL(l_index).last_update_login,
            p_loader_timestamp => p_loader_timestamp,
  		    p_pass => p_pass,
            p_copy_redo_flag => l_copy_redo_flag
          );
        end if; -- /* if PAGE_REGION_ITEM_EXISTS */
		--
        -- If API call returns with an error status, upload aborts
        if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
        (l_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        end if; -- /* if l_return_status */
      end if;
    end loop;
  end if;

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

end UPLOAD_FLOW_SECOND;

end AK_FLOW2_PVT;

/
