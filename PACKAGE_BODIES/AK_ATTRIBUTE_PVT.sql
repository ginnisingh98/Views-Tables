--------------------------------------------------------
--  DDL for Package Body AK_ATTRIBUTE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AK_ATTRIBUTE_PVT" as
/* $Header: akdvatrb.pls 120.5 2006/11/30 23:21:34 tshort ship $ */

--=======================================================
--  Function    VALIDATE_ATTRIBUTE
--
--  Usage       Private API for validating an attribute. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Perform validation on an attribute record.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              In addition, this function returns TRUE if all
--              validation tests are passed, or FALSE otherwise.
--  Parameters  Attribute columns
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
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
function VALIDATE_ATTRIBUTE (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_attribute_application_id IN      NUMBER := FND_API.G_MISS_NUM,
  p_attribute_code           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute_label_length   IN      NUMBER := FND_API.G_MISS_NUM,
  p_attribute_value_length   IN      NUMBER := FND_API.G_MISS_NUM,
  p_bold                     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_italic                   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_vertical_alignment       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_horizontal_alignment     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_data_type                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_upper_case_flag          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_default_value_varchar2   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_default_value_number     IN      NUMBER := FND_API.G_MISS_NUM,
  p_default_value_date       IN      DATE := FND_API.G_MISS_DATE,
  p_lov_region_application_id IN     NUMBER := FND_API.G_MISS_NUM,
  p_lov_region_code          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_name                     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute_label_long     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute_label_short    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_description              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_caller                   IN      VARCHAR2,
  p_pass                     IN      NUMBER := 2
) return BOOLEAN is
  l_api_version_number CONSTANT number := 1.0;
  l_api_name           CONSTANT varchar2(30) := 'Validate_Attribute';
  l_error              BOOLEAN;
  l_return_status      VARCHAR2(1);
begin
  IF NOT FND_API.Compatible_API_Call (
    l_api_version_number, p_api_version_number, l_api_name,
    G_PKG_NAME) then
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return FALSE;
  END IF;

  l_error := FALSE;
  --
  -- if validation level is none, no validation is necessary
  --
  if (p_validation_level = FND_API.G_VALID_LEVEL_NONE) then
    p_return_status := FND_API.G_RET_STS_SUCCESS;
    return TRUE;
  end if;

  --
  -- check that key columns are not null and not missing
  --
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

  /*** check that required columns are not null and, unless calling  ***/
  /*** from UPDATE procedure, the columns are not missing            ***/
  if ((p_bold is null) or
      (p_bold = FND_API.G_MISS_CHAR and
       p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'BOLD');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_italic is null) or
      (p_italic = FND_API.G_MISS_CHAR and
       p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'ITALIC');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_vertical_alignment is null) or
      (p_vertical_alignment = FND_API.G_MISS_CHAR and
       p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE))
  then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'VERTICAL_ALIGNMENT');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_horizontal_alignment is null) or
      (p_horizontal_alignment = FND_API.G_MISS_CHAR and
       p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE))
  then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'HORIZONTAL_ALIGNMENT');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_data_type is null) or
      (p_data_type = FND_API.G_MISS_CHAR and
       p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'DATA_TYPE');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_name is null) or
      (p_name = FND_API.G_MISS_CHAR and
       p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'NAME');
      FND_MSG_PUB.Add;
    end if;
  end if;

  --*** Validate columns ***

  -- - application ID
  if (p_attribute_application_id <> FND_API.G_MISS_NUM) then
    if (NOT AK_ON_OBJECTS_PVT.VALID_APPLICATION_ID (
                p_api_version_number => 1.0,
                p_return_status => l_return_status,
                p_application_id => p_attribute_application_id)
       ) then
      l_error := TRUE;
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
        FND_MESSAGE.SET_NAME('AK','AK_INVALID_COLUMN_VALUE');
        FND_MESSAGE.SET_TOKEN('COLUMN','ATTRIBUTE_APPLICATION_ID');
        FND_MSG_PUB.Add;
      end if;
    end if;
  end if;

  -- - data type
  if (p_data_type <> FND_API.G_MISS_CHAR) then
    if (NOT AK_ON_OBJECTS_PVT.VALID_LOOKUP_CODE (
                p_api_version_number => 1.0,
                p_return_status => l_return_status,
                p_lookup_type => 'DATA_TYPE',
                p_lookup_code => p_data_type) ) then
      l_error := TRUE;
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
        FND_MESSAGE.SET_NAME('AK','AK_INVALID_COLUMN_VALUE');
        FND_MESSAGE.SET_TOKEN('COLUMN','DATA_TYPE');
        FND_MSG_PUB.Add;
      end if;
    end if;
  end if;

  -- - bold
  if (p_bold <> FND_API.G_MISS_CHAR) then
    if (NOT AK_ON_OBJECTS_PVT.VALID_YES_NO(p_bold)) then
      l_error := TRUE;
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
        FND_MESSAGE.SET_NAME('AK','AK_VALUE_NOT_YES_NO');
        FND_MESSAGE.SET_TOKEN('COLUMN','BOLD');
        FND_MSG_PUB.Add;
      end if;
    end if;
  end if;

  -- - upper_case_flag
  if (p_upper_case_flag <> FND_API.G_MISS_CHAR) then
    if (NOT AK_ON_OBJECTS_PVT.VALID_YES_NO(p_upper_case_flag)) then
      l_error := TRUE;
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
        FND_MESSAGE.SET_NAME('AK','AK_VALUE_NOT_YES_NO');
        FND_MESSAGE.SET_TOKEN('COLUMN','UPPER_CASE_FLAG');
        FND_MSG_PUB.Add;
      end if;
    end if;
  end if;

  -- - italic
  if (p_italic <> FND_API.G_MISS_CHAR) then
    if (NOT AK_ON_OBJECTS_PVT.VALID_YES_NO(p_italic)) then
      l_error := TRUE;
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
        FND_MESSAGE.SET_NAME('AK','AK_VALUE_NOT_YES_NO');
        FND_MESSAGE.SET_TOKEN('COLUMN','ITALIC');
        FND_MSG_PUB.Add;
      end if;
    end if;
  end if;

  -- - vertical alignment
  if (p_vertical_alignment <> FND_API.G_MISS_CHAR) then
    if (NOT AK_ON_OBJECTS_PVT.VALID_LOOKUP_CODE (
                p_api_version_number => 1.0,
                p_return_status => l_return_status,
                p_lookup_type => 'VERTICAL_ALIGNMENT',
                p_lookup_code => p_vertical_alignment)) then
      l_error := TRUE;
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
        FND_MESSAGE.SET_NAME('AK','AK_INVALID_COLUMN_VALUE');
        FND_MESSAGE.SET_TOKEN('COLUMN','VERTICAL_ALIGNMENT');
        FND_MSG_PUB.Add;
      end if;
    end if;
  end if;

  /* - horizontal alignment */
  if (p_horizontal_alignment <> FND_API.G_MISS_CHAR) then
    if (NOT AK_ON_OBJECTS_PVT.VALID_LOOKUP_CODE (
                p_api_version_number => 1.0,
                p_return_status => l_return_status,
                p_lookup_type => 'HORIZONTAL_ALIGNMENT',
                p_lookup_code => p_horizontal_alignment)) then
      l_error := TRUE;
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
        FND_MESSAGE.SET_NAME('AK','AK_INVALID_COLUMN_VALUE');
        FND_MESSAGE.SET_TOKEN('COLUMN','HORIZONTAL_ALIGNMENT');
        FND_MSG_PUB.Add;
      end if;
      -- dbms_output.put_line('Invalid Horizontal Alignment value');
    end if;
  end if;

  -- - lov_region_application_id and lov_region_code
  if ( (p_lov_region_application_id <> FND_API.G_MISS_NUM) and
       (p_lov_region_application_id is not null) ) or
     ( (p_lov_region_code <> FND_API.G_MISS_CHAR) and
       (p_lov_region_code is not null) )then
    if (NOT AK_REGION_PVT.REGION_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_region_application_id => p_lov_region_application_id,
            p_region_code => p_lov_region_code)) then
        l_error := TRUE;
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
          FND_MESSAGE.SET_NAME('AK','AK_LOV_REG_DOES_NOT_EXIST');
          FND_MESSAGE.SET_TOKEN('KEY',to_char(p_lov_region_application_id)||' '||p_lov_region_code);
          FND_MSG_PUB.Add;
        end if;
    end if;
  end if;

  /* return true if no error, false otherwise */
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

end VALIDATE_ATTRIBUTE;

--=======================================================
--  Function    ATTRIBUTE_EXISTS
--
--  Usage       Private API for checking for the existence of
--              an attribute with the given key values. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API check to see if an attribute record
--              exists with the given key values.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              This function will return TRUE if such an attribute
--              exists, or FALSE otherwise.
--  Parameters  Attribute key columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
function ATTRIBUTE_EXISTS (
  p_api_version_number       IN      NUMBER,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_attribute_application_id IN      NUMBER,
  p_attribute_code           IN      VARCHAR2
) return BOOLEAN is
  cursor l_check_csr is
    select 1
    from  AK_ATTRIBUTES
    where attribute_application_id = p_attribute_application_id
    and   attribute_code = p_attribute_code;
  l_api_version_number      CONSTANT number := 1.0;
  l_api_name                CONSTANT varchar2(30) := 'Attribute_Exists';
  l_dummy number;
begin
  IF NOT FND_API.Compatible_API_Call (
    l_api_version_number, p_api_version_number, l_api_name,
    G_PKG_NAME) then
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return FALSE;
  END IF;

  open l_check_csr;
  fetch l_check_csr into l_dummy;
  if (l_check_csr%notfound) then
    close l_check_csr;
    p_return_status := FND_API.G_RET_STS_SUCCESS;
    return FALSE;
  else
    close l_check_csr;
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

end ATTRIBUTE_EXISTS;

--========================================================
--  Procedure   CREATE_ATTRIBUTE
--
--  Usage       Private API for creating an attribute. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Creates an attribute using the given info. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Attribute columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will create the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--				p_temp_redo_tbl: IN required
--                  For saving records temporarily to see if it
--                  fails in first pass of upload. If it does,
--                  then the record is saved for second pass
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure CREATE_ATTRIBUTE (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_init_msg_tbl             IN      BOOLEAN := FALSE,
  p_msg_count                OUT NOCOPY     NUMBER,
  p_msg_data                 OUT NOCOPY     VARCHAR2,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_attribute_application_id IN      NUMBER,
  p_attribute_code           IN      VARCHAR2,
  p_attribute_label_length   IN      NUMBER := FND_API.G_MISS_NUM,
  p_attribute_value_length   IN      NUMBER := FND_API.G_MISS_NUM,
  p_bold                     IN      VARCHAR2,
  p_italic                   IN      VARCHAR2,
  p_vertical_alignment       IN      VARCHAR2,
  p_horizontal_alignment     IN      VARCHAR2,
  p_data_type                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_upper_case_flag          IN      VARCHAR2,
  p_default_value_varchar2   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_default_value_number     IN      NUMBER := FND_API.G_MISS_NUM,
  p_default_value_date       IN      DATE := FND_API.G_MISS_DATE,
  p_lov_region_application_id IN     NUMBER := FND_API.G_MISS_NUM,
  p_lov_region_code          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_item_style				 IN		 VARCHAR2,
  p_display_height			 IN		 NUMBER := FND_API.G_MISS_NUM,
  p_css_class_name			 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
  p_poplist_viewobject		 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
  p_poplist_display_attr	 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
  p_poplist_value_attr		 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
  p_css_label_class_name	 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
  p_precision			IN              NUMBER := FND_API.G_MISS_NUM,
  p_expansion			IN		NUMBER := FND_API.G_MISS_NUM,
  p_als_max_length		IN		NUMBER := FND_API.G_MISS_NUM,
  p_attribute_category       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute1               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute2               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute3               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute4               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute5               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute6               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute7               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute8               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute9               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute10              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute11              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute12              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute13              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute14              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute15              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_name                     IN      VARCHAR2,
  p_attribute_label_long     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute_label_short    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_description              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_created_by		     IN	     NUMBER := FND_API.G_MISS_NUM,
  p_creation_date	     IN      DATE := FND_API.G_MISS_DATE,
  p_last_updated_by	     IN      NUMBER := FND_API.G_MISS_NUM,
  p_last_update_date	     IN      DATE := FND_API.G_MISS_DATE,
  p_last_update_login	     IN      NUMBER := FND_API.G_MISS_NUM,
  p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
  p_pass                     IN      NUMBER,
  p_copy_redo_flag           IN OUT NOCOPY  BOOLEAN
) is
  l_api_version_number     CONSTANT number := 1.0;
  l_api_name               CONSTANT varchar2(30) := 'Create_Attribute';
  l_attribute_label_length NUMBER := null;
  l_attribute_label_long   VARCHAR2(80);
  l_attribute_label_short  VARCHAR2(40);
  l_attribute_value_length NUMBER := null;
  l_created_by             number;
  l_creation_date          date;
  l_description            VARCHAR2(2000) := null;
  l_default_value_varchar2 VARCHAR2(240) := null;
  l_default_value_number   number;
  l_default_value_date     date;
  l_attribute_category     VARCHAR2(30);
  l_attribute1             VARCHAR2(150);
  l_attribute2             VARCHAR2(150);
  l_attribute3             VARCHAR2(150);
  l_attribute4             VARCHAR2(150);
  l_attribute5             VARCHAR2(150);
  l_attribute6             VARCHAR2(150);
  l_attribute7             VARCHAR2(150);
  l_attribute8             VARCHAR2(150);
  l_attribute9             VARCHAR2(150);
  l_attribute10            VARCHAR2(150);
  l_attribute11            VARCHAR2(150);
  l_attribute12            VARCHAR2(150);
  l_attribute13            VARCHAR2(150);
  l_attribute14            VARCHAR2(150);
  l_attribute15            VARCHAR2(150);
  l_lang                   varchar2(30);
  l_last_update_date       date;
  l_last_update_login      number;
  l_last_updated_by        number;
  l_lov_region_application_id number;
  l_lov_region_code        VARCHAR2(15);
  l_return_status          varchar2(1);
  l_upper_case_flag        VARCHAR2(1) := null;
  l_item_style				VARCHAR2(30) := 'TEXT';
  l_display_height			number := null;
  l_css_class_name	 		VARCHAR2(80) := NULL;
  l_css_label_class_name	VARCHAR2(80) := NULL;
  l_precision			number := null;
  l_expansion			number := null;
  l_als_max_length		number := null;
  l_poplist_viewobject		VARCHAR2(240) := null;
  l_poplist_display_attr	VARCHAR2(80) := NULL;
  l_poplist_value_attr		VARCHAR2(80) := NULL;

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

  savepoint start_create_attribute;

/* TSHORT - 5665840 - new logic to avoid unique constraint error */
/* now if we hit that error the exception handling calls update_attribute */
/* --
  -- check to see if row already exists
  --
  if AK_ATTRIBUTE_PVT.ATTRIBUTE_EXISTS (
         p_api_version_number => 1.0,
         p_return_status => l_return_status,
         p_attribute_application_id => p_attribute_application_id,
         p_attribute_code => p_attribute_code) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_ATTRIBUTE_EXISTS');
      FND_MSG_PUB.Add;
    end if;
    raise FND_API.G_EXC_ERROR;
  end if; */

  --** create with blank lov region application id, and lov region code
  --** if calling from the loader **
  --   (this is because no region records have been loaded
  --    at the time when the loader is creating attributes)
  --
  if (p_loader_timestamp <> FND_API.G_MISS_DATE) then
    l_lov_region_application_id := null;
    l_lov_region_code := null;
  else
    if (p_lov_region_application_id <> FND_API.G_MISS_NUM) then
      l_lov_region_application_id := p_lov_region_application_id;
    end if;
    if (p_lov_region_code <> FND_API.G_MISS_CHAR) then
      l_lov_region_code := p_lov_region_code;
    end if;
  end if;

  --
  --  validate table columns passed in
  --
  if (p_validation_level <> FND_API.G_VALID_LEVEL_NONE) then
    --
    -- If this API is called from the upload_attribute API,
    -- we will create an attribute with a null lov region if
    -- the lov region passed is invalid.
    --
    if (p_loader_timestamp <> FND_API.G_MISS_DATE) and
       (p_lov_region_code is not null) and
       (p_lov_region_code <> FND_API.G_MISS_CHAR) then
       if NOT AK_REGION_PVT.REGION_EXISTS (
           p_api_version_number => 1.0,
           p_return_status => l_return_status,
           p_region_application_id => p_lov_region_application_id,
           p_region_code => p_lov_region_code) then
         l_lov_region_application_id := null;
         l_lov_region_code := null;
       end if;
    end if;
    --
    -- Validate all columns passed in
    --
    if NOT VALIDATE_ATTRIBUTE(
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_attribute_application_id => p_attribute_application_id,
            p_attribute_code => p_attribute_code,
            p_attribute_label_length => p_attribute_label_length,
            p_attribute_value_length => p_attribute_value_length,
            p_bold => p_bold,
            p_italic => p_italic,
            p_vertical_alignment => p_vertical_alignment,
            p_horizontal_alignment => p_horizontal_alignment,
            p_data_type => p_data_type,
            p_upper_case_flag => p_upper_case_flag,
            p_default_value_varchar2 => p_default_value_varchar2,
            p_default_value_number => p_default_value_number,
            p_default_value_date => p_default_value_date,
            p_lov_region_application_id => l_lov_region_application_id,
            p_lov_region_code => l_lov_region_code,
            p_name => p_name,
            p_attribute_label_long => p_attribute_label_long,
            p_attribute_label_short => p_attribute_label_short,
            p_description => p_description,
            p_caller => AK_ON_OBJECTS_PVT.G_CREATE,
			p_pass => p_pass
          ) then
      -- Do not raise an error if it's the first pass, continue to
	  -- insert the record
      if (p_pass = 1) then
        p_copy_redo_flag := TRUE;
      else
        raise FND_API.G_EXC_ERROR;
	  end if; -- /* if p_pass */
    end if; --/* if VALIDATE_ATTRIBUTE */
  end if; --/* if p_validation_level */

  --
  -- Load non-required columns if their values are given
  -- (do not load lov_region_application_id and lov_region_code
  --  again since they have already been loaded earlier)
  --
  if (p_attribute_label_length <> FND_API.G_MISS_NUM) then
    l_attribute_label_length := p_attribute_label_length;
  end if;

  if (p_attribute_value_length <> FND_API.G_MISS_NUM) then
    l_attribute_value_length := p_attribute_value_length;
  end if;

  if (p_upper_case_flag <> FND_API.G_MISS_CHAR) then
    l_upper_case_flag := p_upper_case_flag;
  end if;

  if (p_default_value_varchar2 <> FND_API.G_MISS_CHAR) then
    l_default_value_varchar2 := p_default_value_varchar2;
  end if;

  if (p_default_value_number <> FND_API.G_MISS_NUM) then
    l_default_value_number := p_default_value_number;
  end if;

  if (p_default_value_date <> FND_API.G_MISS_DATE) then
    l_default_value_date := p_default_value_date;
  end if;

  -- Load non-required JSP columns
  if (p_item_style <> FND_API.G_MISS_CHAR and p_item_style is not null) then
    l_item_style := p_item_style;
  end if;

  if (p_display_height <> FND_API.G_MISS_NUM) then
    l_display_height := p_display_height;
  end if;

  if (p_css_class_name <> FND_API.G_MISS_CHAR) then
    l_css_class_name := p_css_class_name;
  end if;

  if (p_poplist_viewobject <> FND_API.G_MISS_CHAR) then
    l_poplist_viewobject := p_poplist_viewobject;
  end if;

  if (p_poplist_display_attr <> FND_API.G_MISS_CHAR) then
    l_poplist_display_attr := p_poplist_display_attr;
  end if;

  if (p_poplist_value_attr <> FND_API.G_MISS_CHAR) then
    l_poplist_value_attr := p_poplist_value_attr;
  end if;

  if (p_css_label_class_name <> FND_API.G_MISS_CHAR) then
	l_css_label_class_name := p_css_label_class_name;
  end if;

  if (p_precision <> FND_API.G_MISS_NUM) then
    l_precision := p_precision;
  end if;

  if (p_expansion <> FND_API.G_MISS_NUM) then
    l_expansion := p_expansion;
  end if;

  if (p_als_max_length <> FND_API.G_MISS_NUM) then
    l_als_max_length := p_als_max_length;
  end if;

  -- flex columns
  if (p_attribute_category <> FND_API.G_MISS_CHAR) then
    l_attribute_category := p_attribute_category;
  end if;

  if (p_attribute1 <> FND_API.G_MISS_CHAR) then
    l_attribute1 := p_attribute1;
  end if;

  if (p_attribute2 <> FND_API.G_MISS_CHAR) then
    l_attribute2 := p_attribute2;
  end if;

  if (p_attribute3 <> FND_API.G_MISS_CHAR) then
    l_attribute3 := p_attribute3;
  end if;

  if (p_attribute4 <> FND_API.G_MISS_CHAR) then
    l_attribute4 := p_attribute4;
  end if;

  if (p_attribute5 <> FND_API.G_MISS_CHAR) then
    l_attribute5 := p_attribute5;
  end if;

  if (p_attribute6 <> FND_API.G_MISS_CHAR) then
    l_attribute6 := p_attribute6;
  end if;

  if (p_attribute7 <> FND_API.G_MISS_CHAR) then
    l_attribute7:= p_attribute7;
  end if;

  if (p_attribute8 <> FND_API.G_MISS_CHAR) then
    l_attribute8 := p_attribute8;
  end if;

  if (p_attribute9 <> FND_API.G_MISS_CHAR) then
    l_attribute9 := p_attribute9;
  end if;

  if (p_attribute10 <> FND_API.G_MISS_CHAR) then
    l_attribute10 := p_attribute10;
  end if;

  if (p_attribute11 <> FND_API.G_MISS_CHAR) then
    l_attribute11 := p_attribute11;
  end if;

  if (p_attribute12 <> FND_API.G_MISS_CHAR) then
    l_attribute12 := p_attribute12;
  end if;

  if (p_attribute13 <> FND_API.G_MISS_CHAR) then
    l_attribute13 := p_attribute13;
  end if;

  if (p_attribute14 <> FND_API.G_MISS_CHAR) then
    l_attribute14 := p_attribute14;
  end if;

  if (p_attribute15 <> FND_API.G_MISS_CHAR) then
    l_attribute15 := p_attribute15;
  end if;

  if (p_description <> FND_API.G_MISS_CHAR) then
    l_description := p_description;
  end if;

  if (p_attribute_label_long <> FND_API.G_MISS_CHAR) then
    l_attribute_label_long := p_attribute_label_long;
  end if;

  if (p_attribute_label_short <> FND_API.G_MISS_CHAR) then
    l_attribute_label_short := p_attribute_label_short;
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

  --
  --  Create record if no validation error was found
  --
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

  -- Gets userenv('LANG') which is the system's current language code

  select userenv('LANG') into l_lang
  from dual;

  insert into AK_ATTRIBUTES (
    ATTRIBUTE_APPLICATION_ID,
    ATTRIBUTE_CODE,
    ATTRIBUTE_LABEL_LENGTH,
    ATTRIBUTE_VALUE_LENGTH,
    BOLD,
    ITALIC,
    VERTICAL_ALIGNMENT,
    HORIZONTAL_ALIGNMENT,
    DATA_TYPE,
    UPPER_CASE_FLAG,
    DEFAULT_VALUE_VARCHAR2,
    DEFAULT_VALUE_NUMBER,
    DEFAULT_VALUE_DATE,
    LOV_REGION_APPLICATION_ID,
    LOV_REGION_CODE,
	ITEM_STYLE,
	DISPLAY_HEIGHT,
	CSS_CLASS_NAME,
	POPLIST_VIEWOBJECT,
	POPLIST_DISPLAY_ATTRIBUTE,
	POPLIST_VALUE_ATTRIBUTE,
	CSS_LABEL_CLASS_NAME,
	PRECISION,
 	EXPANSION,
	ALS_MAX_LENGTH,
	ATTRIBUTE_CATEGORY,
	ATTRIBUTE1,
	ATTRIBUTE2,
	ATTRIBUTE3,
	ATTRIBUTE4,
	ATTRIBUTE5,
	ATTRIBUTE6,
	ATTRIBUTE7,
	ATTRIBUTE8,
	ATTRIBUTE9,
	ATTRIBUTE10,
	ATTRIBUTE11,
	ATTRIBUTE12,
	ATTRIBUTE13,
	ATTRIBUTE14,
	ATTRIBUTE15,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    p_attribute_application_id,
    p_attribute_code,
    l_attribute_label_length,
    l_attribute_value_length,
    p_bold,
    p_italic,
    p_vertical_alignment,
    p_horizontal_alignment,
    p_data_type,
    l_upper_case_flag,
    l_default_value_varchar2,
    l_default_value_number,
    l_default_value_date,
    l_lov_region_application_id,
    l_lov_region_code,
	l_item_style,
	l_display_height,
	l_css_class_name,
	l_poplist_viewobject,
	l_poplist_display_attr,
	l_poplist_value_attr,
	l_css_label_class_name,
  	l_precision,
	l_expansion,
	l_als_max_length,
    l_attribute_category,
	l_attribute1,
	l_attribute2,
	l_attribute3,
	l_attribute4,
	l_attribute5,
	l_attribute6,
	l_attribute7,
	l_attribute8,
	l_attribute9,
	l_attribute10,
	l_attribute11,
	l_attribute12,
	l_attribute13,
	l_attribute14,
	l_attribute15,
    l_creation_date,
    l_created_by,
    l_last_update_date,
    l_last_updated_by,
    l_last_update_login
  );

  --
  -- row should exists before inserting rows for other languages
  --
  if NOT AK_ATTRIBUTE_PVT.ATTRIBUTE_EXISTS (
         p_api_version_number => 1.0,
         p_return_status => l_return_status,
         p_attribute_application_id => p_attribute_application_id,
         p_attribute_code => p_attribute_code) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_INSERT_ATTRIBUTE_FAILED');
      FND_MESSAGE.SET_TOKEN('OBJECT','AK_LC_ATTRIBUTE',TRUE);
      FND_MSG_PUB.Add;
    end if;
    raise FND_API.G_EXC_ERROR;
  end if;

  insert into AK_ATTRIBUTES_TL (
    ATTRIBUTE_APPLICATION_ID,
    ATTRIBUTE_CODE,
    LANGUAGE,
    NAME,
    ATTRIBUTE_LABEL_LONG,
    ATTRIBUTE_LABEL_SHORT,
    DESCRIPTION,
    SOURCE_LANG,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN
  ) select
    p_attribute_application_id,
    p_attribute_code,
    L.LANGUAGE_CODE,
    p_name,
    l_attribute_label_long,
    l_attribute_label_short,
    l_description,
    l_lang,
    l_created_by,
    l_creation_date,
    l_last_updated_by,
    l_last_update_date,
    l_last_update_login
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AK_ATTRIBUTES_TL T
    where T.ATTRIBUTE_APPLICATION_ID = p_attribute_application_id
    and T.ATTRIBUTE_CODE = p_attribute_code
    and T.LANGUAGE = L.LANGUAGE_CODE);

--  /** commit the insert **/
  commit;

  if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
    FND_MESSAGE.SET_NAME('AK','AK_ATTRIBUTE_CREATED');
    FND_MESSAGE.SET_TOKEN('KEY',to_char(p_attribute_application_id) ||
                                ' ' || p_attribute_code);
    FND_MSG_PUB.Add;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  FND_MSG_PUB.Count_And_Get (
	p_count => p_msg_count,
	p_data => p_msg_data);


EXCEPTION
  WHEN VALUE_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_ATTRIBUTE_VALUE_ERROR');
      FND_MESSAGE.SET_TOKEN('KEY',to_char(p_attribute_application_id) ||
                                  ' ' || p_attribute_code);
      FND_MESSAGE.SET_NAME('AK','AK_ATTRIBUTE_NOT_CREATED');
      FND_MESSAGE.SET_TOKEN('KEY',to_char(p_attribute_application_id) ||
                                  ' ' || p_attribute_code);
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
    rollback to start_create_attribute;
    FND_MSG_PUB.Count_And_Get (
	p_count => p_msg_count,
	p_data => p_msg_data);
  WHEN FND_API.G_EXC_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_ATTRIBUTE_NOT_CREATED');
      FND_MESSAGE.SET_TOKEN('KEY',to_char(p_attribute_application_id) ||
                                  ' ' || p_attribute_code);
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
    rollback to start_create_attribute;
    FND_MSG_PUB.Count_And_Get (
	p_count => p_msg_count,
	p_data => p_msg_data);
  WHEN OTHERS THEN
    if (SQLCODE = -1) then
	rollback to start_create_attribute;
        AK_ATTRIBUTE_PVT.UPDATE_ATTRIBUTE (
           p_validation_level => p_validation_level,
           p_api_version_number => 1.0,
           p_msg_count => p_msg_count,
           p_msg_data => p_msg_data,
           p_return_status => p_return_status,
           p_attribute_application_id => p_attribute_application_id,
           p_attribute_code => p_attribute_code,
           p_attribute_label_length => p_attribute_label_length,
           p_attribute_value_length => p_attribute_value_length,
           p_bold => p_bold,
           p_italic => p_italic,
           p_vertical_alignment => p_vertical_alignment,
           p_horizontal_alignment => p_horizontal_alignment,
           p_data_type => p_data_type,
           p_precision => p_precision,
           p_upper_case_flag => p_upper_case_flag,
           p_default_value_varchar2 => p_default_value_varchar2,
           p_default_value_number => p_default_value_number,
           p_default_value_date => p_default_value_date,
           p_lov_region_application_id => p_lov_region_application_id,
           p_lov_region_code => p_lov_region_code,
           p_item_style => p_item_style,
           p_display_height => p_display_height,
           p_css_class_name => p_css_class_name,
           p_poplist_viewobject => p_poplist_viewobject,
           p_poplist_display_attr => p_poplist_display_attr,
           p_poplist_value_attr => p_poplist_value_attr,
           p_css_label_class_name => p_css_label_class_name,
           p_attribute_category => p_attribute_category,
           p_expansion => p_expansion,
           p_als_max_length => p_als_max_length,
           p_attribute1 => p_attribute1,
           p_attribute2 => p_attribute2,
           p_attribute3 => p_attribute3,
           p_attribute4 => p_attribute4,
           p_attribute5 => p_attribute5,
           p_attribute6 => p_attribute6,
           p_attribute7 => p_attribute7,
           p_attribute8 => p_attribute8,
           p_attribute9 => p_attribute9,
           p_attribute10 => p_attribute10,
           p_attribute11 => p_attribute11,
           p_attribute12 => p_attribute12,
           p_attribute13 => p_attribute13,
           p_attribute14 => p_attribute14,
           p_attribute15 => p_attribute15,
           p_created_by => p_created_by,
           p_creation_date => p_creation_date,
           p_last_updated_by => p_last_updated_by,
           p_last_update_date => p_last_update_date,
           p_last_update_login => p_last_update_login,
           p_name => p_name,
           p_attribute_label_long => p_attribute_label_long,
           p_attribute_label_short =>p_attribute_label_short,
           p_description => p_description,
           p_loader_timestamp => p_loader_timestamp,
           p_pass => p_pass,
           p_copy_redo_flag => p_copy_redo_flag
           );
    else
       p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       rollback to start_create_attribute;
       FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
       FND_MSG_PUB.Count_And_Get (
	  p_count => p_msg_count,
	  p_data => p_msg_data);
    end if;
end CREATE_ATTRIBUTE;

--=======================================================
--  Procedure   DELETE_ATTRIBUTE
--
--  Usage       Private API for deleting an attribute. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Deletes an attribute with the given key value.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_attribute_application_id : IN required
--              p_attribute_code : IN required
--                  Key value of the attribute to be deleted.
--              p_delete_cascade : IN required
--                  If p_delete_cascade flag is 'Y', also delete all
--                  rows in other tables that references this attribute.
--                  Otherwise, this attribute will not be deleted if there
--                  are any other rows referencing it.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure DELETE_ATTRIBUTE (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_init_msg_tbl             IN      BOOLEAN := FALSE,
  p_msg_count                OUT NOCOPY     NUMBER,
  p_msg_data                 OUT NOCOPY     VARCHAR2,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_attribute_application_id IN      NUMBER,
  p_attribute_code           IN      VARCHAR2,
  p_delete_cascade           IN      VARCHAR2
) is
  cursor l_get_obj_attr_csr is
    select DATABASE_OBJECT_NAME
    from  AK_OBJECT_ATTRIBUTES
    where ATTRIBUTE_APPLICATION_ID = p_attribute_application_id
    and   ATTRIBUTE_CODE = p_attribute_code;
  cursor l_get_region_item_csr is
    select REGION_APPLICATION_ID, REGION_CODE
    from  AK_REGION_ITEMS
    where ATTRIBUTE_APPLICATION_ID = p_attribute_application_id
    and   ATTRIBUTE_CODE = p_attribute_code
    and   OBJECT_ATTRIBUTE_FLAG = 'N';
  l_api_version_number    CONSTANT number := 1.0;
  l_api_name              CONSTANT varchar2(30) := 'Delete_Attribute';
  l_database_object_name  VARCHAR2(30);
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);
  l_region_application_id NUMBER;
  l_region_code           VARCHAR2(30);
  l_return_status         varchar2(1);
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

  savepoint start_delete_attribute;

  --
  -- error if attribute to be deleted does not exists
  --
  if NOT AK_ATTRIBUTE_PVT.ATTRIBUTE_EXISTS (
           p_api_version_number => 1.0,
           p_return_status => l_return_status,
           p_attribute_application_id => p_attribute_application_id,
           p_attribute_code => p_attribute_code) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
      FND_MESSAGE.SET_NAME('AK','AK_ATTRIBUTE_DOES_NOT_EXIST');
      FND_MSG_PUB.Add;
    end if;
    raise FND_API.G_EXC_ERROR;
  end if;

  if (p_delete_cascade = 'N') then
    --
    -- If we are not deleting any referencing records, we cannot
    -- delete the attribute if it is being referenced in any of
    -- following tables.
    --
    -- AK_OBJECT_ATTRIBUTES
    --
    open l_get_obj_attr_csr;
    fetch l_get_obj_attr_csr into l_database_object_name;
    if l_get_obj_attr_csr%found then
      close l_get_obj_attr_csr;
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
        FND_MESSAGE.SET_NAME('AK','AK_CANNOT_DEL_REF_ATTR_OA');
        FND_MSG_PUB.Add;
      end if;
      raise FND_API.G_EXC_ERROR;
    end if;
    close l_get_obj_attr_csr;
    --
    -- AK_REGION_ITEMS
    --
    open l_get_region_item_csr;
    fetch l_get_region_item_csr into l_region_application_id, l_region_code;
    if l_get_region_item_csr%found then
      close l_get_region_item_csr;
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
        FND_MESSAGE.SET_NAME('AK','AK_CANNOT_DEL_REF_ATTR_RI');
        FND_MSG_PUB.Add;
      end if;
      raise FND_API.G_EXC_ERROR;
    end if;
    close l_get_region_item_csr;

  else
    --
    -- Otherwise, delete all referencing rows in other tables
    --
    -- AK_OBJECT_ATTRIBUTES
    --
    open l_get_obj_attr_csr;
    loop
      fetch l_get_obj_attr_csr into l_database_object_name;
      exit when l_get_obj_attr_csr%notfound;
      AK_OBJECT_PVT.DELETE_ATTRIBUTE(
        p_validation_level => p_validation_level,
        p_api_version_number => 1.0,
        p_msg_count => l_msg_count,
        p_msg_data => l_msg_data,
        p_return_status => l_return_status,
	p_database_object_name => l_database_object_name,
        p_attribute_application_id => p_attribute_application_id,
        p_attribute_code => p_attribute_code,
        p_delete_cascade => p_delete_cascade
      );
      if (l_return_status = FND_API.G_RET_STS_ERROR) or
         (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
        close l_get_obj_attr_csr;
        raise FND_API.G_EXC_ERROR;
      end if;
    end loop;
    close l_get_obj_attr_csr;
    --
    -- AK_REGION_ITEMS
    --
    open l_get_region_item_csr;
    loop
      fetch l_get_region_item_csr into l_region_application_id, l_region_code;
      exit when l_get_region_item_csr%notfound;
      AK_REGION_PVT.DELETE_ITEM (
        p_validation_level => p_validation_level,
        p_api_version_number => 1.0,
        p_msg_count => l_msg_count,
        p_msg_data => l_msg_data,
        p_return_status => l_return_status,
        p_region_application_id => l_region_application_id,
        p_region_code => l_region_code,
        p_attribute_application_id => p_attribute_application_id,
        p_attribute_code => p_attribute_code,
        p_delete_cascade => p_delete_cascade
      );
      if (l_return_status = FND_API.G_RET_STS_ERROR) or
         (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
        close l_get_region_item_csr;
        raise FND_API.G_EXC_ERROR;
      end if;
    end loop;
    close l_get_region_item_csr;

  end if;

  --
  -- delete attribute once we checked that there are no references
  -- to this attribute, or all references have been deleted.
  --
  delete from ak_attributes
  where  attribute_application_id = p_attribute_application_id
  and    attribute_code = p_attribute_code;

  if (sql%notfound) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
      FND_MESSAGE.SET_NAME('AK','AK_ATTRIBUTE_DOES_NOT_EXIST');
      FND_MSG_PUB.Add;
    end if;
    raise FND_API.G_EXC_ERROR;
  end if;

  delete from ak_attributes_tl
  where  attribute_application_id = p_attribute_application_id
  and    attribute_code = p_attribute_code;

  if (sql%notfound) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
      FND_MESSAGE.SET_NAME('AK','AK_ATTRIBUTE_DOES_NOT_EXIST');
      FND_MSG_PUB.Add;
    end if;
    raise FND_API.G_EXC_ERROR;
  end if;

  --
  -- Load success message
  --
  if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) then
    FND_MESSAGE.SET_NAME('AK','AK_ATTRIBUTE_DELETED');
    FND_MESSAGE.SET_TOKEN('KEY', to_char(p_attribute_application_id) ||
                                 ' ' || p_attribute_code);
    FND_MSG_PUB.Add;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  FND_MSG_PUB.Count_And_Get (
	p_count => p_msg_count,
	p_data => p_msg_data);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
      FND_MESSAGE.SET_NAME('AK','AK_ATTRIBUTE_NOT_DELETED');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_attribute_application_id) ||
                                 ' ' || p_attribute_code);
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
    rollback to start_delete_attribute;
    FND_MSG_PUB.Count_And_Get (
	p_count => p_msg_count,
	p_data => p_msg_data);
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    rollback to start_delete_attribute;
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Count_And_Get (
	p_count => p_msg_count,
	p_data => p_msg_data);
end DELETE_ATTRIBUTE;

--=======================================================
--  Procedure   WRITE_TO_BUFFER (local procedure)
--
--  Usage       Local procedure for writing one attribute to
--              the output file. Not designed to be called
--              from outside this package.
--
--  Desc        Appends the single attribute passed in through the
--              parameters to the specified output file. The
--              output will be in loader file format.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Attribute record and its TL record.
--=======================================================
procedure WRITE_TO_BUFFER (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_attributes_rec           IN      ak_attributes%ROWTYPE,
  p_attributes_tl_rec        IN      ak_attributes_tl%ROWTYPE
) is
  l_api_name           CONSTANT varchar2(30) := 'Write_to_buffer';
  l_databuffer_tbl     AK_ON_OBJECTS_PUB.Buffer_Tbl_Type;
  l_index              NUMBER;
  l_lov_object         VARCHAR2(30);
  l_return_status      varchar2(1);
begin
  --
  -- Attribute must be validated before it is written to the file
  --
  if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
    if not VALIDATE_ATTRIBUTE (
	p_validation_level => p_validation_level,
	p_api_version_number => 1.0,
	p_return_status => l_return_status,
	p_attribute_application_id =>
                                p_attributes_rec.attribute_application_id,
	p_attribute_code => p_attributes_rec.attribute_code,
	p_attribute_label_length => p_attributes_rec.attribute_label_length,
	p_attribute_value_length => p_attributes_rec.attribute_value_length,
	p_bold => p_attributes_rec.bold,
	p_italic => p_attributes_rec.italic,
	p_vertical_alignment => p_attributes_rec.vertical_alignment,
	p_horizontal_alignment => p_attributes_rec.horizontal_alignment,
	p_data_type => p_attributes_rec.data_type,
	p_upper_case_flag => p_attributes_rec.upper_case_flag,
        p_default_value_varchar2 => p_attributes_rec.default_value_varchar2,
        p_default_value_number => p_attributes_rec.default_value_number,
        p_default_value_date => p_attributes_rec.default_value_date,
        p_lov_region_application_id =>
                                p_attributes_rec.lov_region_application_id,
        p_lov_region_code => p_attributes_rec.lov_region_code,
	p_name => p_attributes_tl_rec.name,
	p_attribute_label_long => p_attributes_tl_rec.attribute_label_long,
	p_attribute_label_short => p_attributes_tl_rec.attribute_label_short,
	p_description => p_attributes_tl_rec.description,
 	p_caller => AK_ON_OBJECTS_PVT.G_DOWNLOAD)
    then
      -- dbms_output.put_line('Attribute ' || p_attributes_rec.attribute_code
      --			|| ' not downloaded due to validation error');
      raise FND_API.G_EXC_ERROR;
    end if;
  end if;

  --
  -- Write attribute and its TL record into buffer
  --
  l_databuffer_tbl.DELETE;
  l_index := 1;

  l_databuffer_tbl(l_index) := 'BEGIN ATTRIBUTE "' ||
		p_attributes_rec.attribute_application_id || '" "' ||
		AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(p_attributes_rec.attribute_code) || '"';
  --
  -- only write out columns that is not null
  --
  if ((p_attributes_rec.attribute_label_length IS NOT NULL) and
     (p_attributes_rec.attribute_label_length <> FND_API.G_MISS_NUM)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  ATTRIBUTE_LABEL_LENGTH = "' ||
    		nvl(to_char(p_attributes_rec.attribute_label_length),'') || '"';
  end if;
  if ((p_attributes_rec.attribute_value_length IS NOT NULL) and
     (p_attributes_rec.attribute_value_length <> FND_API.G_MISS_NUM)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  ATTRIBUTE_VALUE_LENGTH = "' ||
    		nvl(to_char(p_attributes_rec.attribute_value_length),'') || '"';
  end if;
  if ((p_attributes_rec.bold IS NOT NULL) and
     (p_attributes_rec.bold <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  BOLD = "' ||
    		AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(p_attributes_rec.bold) || '"';
  end if;
  if ((p_attributes_rec.italic IS NOT NULL) and
     (p_attributes_rec.italic <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  ITALIC = "' ||
    		AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(p_attributes_rec.italic) || '"';
  end if;
  if ((p_attributes_rec.vertical_alignment IS NOT NULL) and
     (p_attributes_rec.vertical_alignment <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  VERTICAL_ALIGNMENT = "' ||
    		AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(p_attributes_rec.vertical_alignment)
    		 || '"';
  end if;
  if ((p_attributes_rec.horizontal_alignment IS NOT NULL) and
     (p_attributes_rec.horizontal_alignment <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  HORIZONTAL_ALIGNMENT = "' ||
    AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(p_attributes_rec.horizontal_alignment)
    		 || '"';
  end if;
  if ((p_attributes_rec.data_type IS NOT NULL) and
     (p_attributes_rec.data_type <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  DATA_TYPE = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(p_attributes_rec.data_type) || '"';
  end if;
  if ((p_attributes_rec.upper_case_flag IS NOT NULL) and
     (p_attributes_rec.upper_case_flag <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  UPPER_CASE_FLAG = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(p_attributes_rec.upper_case_flag)
      || '"';
  end if;
  if ((p_attributes_rec.default_value_varchar2 IS NOT NULL) and
     (p_attributes_rec.default_value_varchar2 <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  DEFAULT_VALUE_VARCHAR2 = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                 p_attributes_rec.default_value_varchar2) || '"';
  end if;
  if ((p_attributes_rec.default_value_number IS NOT NULL) and
     (p_attributes_rec.default_value_number <> FND_API.G_MISS_NUM)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  DEFAULT_VALUE_NUMBER = "' ||
    		nvl(to_char(p_attributes_rec.default_value_number),'') || '"';
  end if;
  if ((p_attributes_rec.default_value_date IS NOT NULL) and
     (p_attributes_rec.default_value_date <> FND_API.G_MISS_DATE)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  DEFAULT_VALUE_DATE = "' ||
    		to_char(p_attributes_rec.default_value_date,
                              AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
  end if;
  if ((p_attributes_rec.lov_region_application_id IS NOT NULL) and
     (p_attributes_rec.lov_region_application_id <> FND_API.G_MISS_NUM) and
     (p_attributes_rec.lov_region_code IS NOT NULL) and
     (p_attributes_rec.lov_region_code <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  LOV_REGION = "' ||
    		nvl(to_char(p_attributes_rec.lov_region_application_id),'')||'" "'||
          AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(p_attributes_rec.lov_region_code) ||
          '"';
  end if;
  -- new columns for JSP renderer
  if ((p_attributes_rec.item_style IS NOT NULL) and
     (p_attributes_rec.item_style <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  ITEM_STYLE = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                 p_attributes_rec.item_style) || '"';
  end if;
  if ((p_attributes_rec.display_height IS NOT NULL) and
     (p_attributes_rec.display_height <> FND_API.G_MISS_NUM)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  DISPLAY_HEIGHT = "' ||
    		nvl(to_char(p_attributes_rec.display_height),'') || '"';
  end if;
  if ((p_attributes_rec.css_class_name IS NOT NULL) and
     (p_attributes_rec.css_class_name <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  CSS_CLASS_NAME = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                 p_attributes_rec.css_class_name) || '"';
  end if;
  if ((p_attributes_rec.poplist_viewobject IS NOT NULL) and
     (p_attributes_rec.poplist_viewobject <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  POPLIST_VIEWOBJECT = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                 p_attributes_rec.poplist_viewobject) || '"';
  end if;
  if ((p_attributes_rec.poplist_display_attribute IS NOT NULL) and
     (p_attributes_rec.poplist_display_attribute <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  POPLIST_DISPLAY_ATTRIBUTE = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                 p_attributes_rec.poplist_display_attribute) || '"';
  end if;
  if ((p_attributes_rec.poplist_value_attribute IS NOT NULL) and
     (p_attributes_rec.poplist_value_attribute <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  POPLIST_VALUE_ATTRIBUTE = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                 p_attributes_rec.poplist_value_attribute) || '"';
  end if;
  if ((p_attributes_rec.css_label_class_name IS NOT NULL ) and
     (p_attributes_rec.css_label_class_name <> FND_API.G_MISS_CHAR)) then
	 l_index := l_index + 1;
	 l_databuffer_tbl(l_index) := '  CSS_LABEL_CLASS_NAME = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                 p_attributes_rec.css_label_class_name) || '"';
  end if;
  if ((p_attributes_rec.precision IS NOT NULL ) and
     (p_attributes_rec.precision <> FND_API.G_MISS_NUM)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  PRECISION = "' ||
                nvl(to_char(p_attributes_rec.precision),'') || '"';
  end if;
  if ((p_attributes_rec.expansion IS NOT NULL ) and
     (p_attributes_rec.expansion <> FND_API.G_MISS_NUM)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  EXPANSION = "' ||
                nvl(to_char(p_attributes_rec.expansion),'') || '"';
  end if;
  if ((p_attributes_rec.als_max_length IS NOT NULL ) and
     (p_attributes_rec.als_max_length <> FND_API.G_MISS_NUM)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  ALS_MAX_LENGTH = "' ||
                nvl(to_char(p_attributes_rec.als_max_length),'') || '"';
  end if;


  -- Flex Fields
  --
  if ((p_attributes_rec.attribute_category IS NOT NULL) and
     (p_attributes_rec.attribute_category <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  ATTRIBUTE_CATEGORY = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                 p_attributes_rec.attribute_category) || '"';
  end if;
  if ((p_attributes_rec.attribute1 IS NOT NULL) and
     (p_attributes_rec.attribute1 <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  ATTRIBUTE1 = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                 p_attributes_rec.attribute1) || '"';
  end if;
  if ((p_attributes_rec.attribute2 IS NOT NULL) and
     (p_attributes_rec.attribute2 <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  ATTRIBUTE2 = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                 p_attributes_rec.attribute2) || '"';
  end if;
  if ((p_attributes_rec.attribute3 IS NOT NULL) and
     (p_attributes_rec.attribute3 <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  ATTRIBUTE3 = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                 p_attributes_rec.attribute3) || '"';
  end if;
  if ((p_attributes_rec.attribute4 IS NOT NULL) and
     (p_attributes_rec.attribute4 <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  ATTRIBUTE4 = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                 p_attributes_rec.attribute4) || '"';
  end if;
  if ((p_attributes_rec.attribute5 IS NOT NULL) and
     (p_attributes_rec.attribute5 <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  ATTRIBUTE5 = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                 p_attributes_rec.attribute5) || '"';
  end if;
  if ((p_attributes_rec.attribute6 IS NOT NULL) and
     (p_attributes_rec.attribute6 <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  ATTRIBUTE6 = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                 p_attributes_rec.attribute6) || '"';
  end if;
  if ((p_attributes_rec.attribute7 IS NOT NULL) and
     (p_attributes_rec.attribute7 <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  ATTRIBUTE7 = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                 p_attributes_rec.attribute7) || '"';
  end if;
  if ((p_attributes_rec.attribute8 IS NOT NULL) and
     (p_attributes_rec.attribute8 <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  ATTRIBUTE8 = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                 p_attributes_rec.attribute8) || '"';
  end if;
  if ((p_attributes_rec.attribute9 IS NOT NULL) and
     (p_attributes_rec.attribute9 <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  ATTRIBUTE9 = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                 p_attributes_rec.attribute9) || '"';
  end if;
  if ((p_attributes_rec.attribute10 IS NOT NULL) and
     (p_attributes_rec.attribute10 <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  ATTRIBUTE10 = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                 p_attributes_rec.attribute10) || '"';
  end if;
  if ((p_attributes_rec.attribute11 IS NOT NULL) and
     (p_attributes_rec.attribute11 <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  ATTRIBUTE11 = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                 p_attributes_rec.attribute11) || '"';
  end if;
  if ((p_attributes_rec.attribute12 IS NOT NULL) and
     (p_attributes_rec.attribute12 <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  ATTRIBUTE12 = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                 p_attributes_rec.attribute12) || '"';
  end if;
  if ((p_attributes_rec.attribute13 IS NOT NULL) and
     (p_attributes_rec.attribute13 <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  ATTRIBUTE13 = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                 p_attributes_rec.attribute13) || '"';
  end if;
  if ((p_attributes_rec.attribute14 IS NOT NULL) and
     (p_attributes_rec.attribute14 <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  ATTRIBUTE14 = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                 p_attributes_rec.attribute14) || '"';
  end if;
  if ((p_attributes_rec.attribute15 IS NOT NULL) and
     (p_attributes_rec.attribute15 <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  ATTRIBUTE15 = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
                 p_attributes_rec.attribute15) || '"';
  end if;
  -- - Write out who columns
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  CREATED_BY = "' ||
                nvl(to_char(p_attributes_rec.created_by),'') || '"';
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  CREATION_DATE = "' ||
                to_char(p_attributes_rec.creation_date,
                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
    l_index := l_index + 1;
  --  CHANGED TO OWNER FOR R12
  --  l_databuffer_tbl(l_index) := '  LAST_UPDATED_BY = "' ||
  --              nvl(to_char(p_attributes_rec.last_updated_by),'') || '"';
    l_databuffer_tbl(l_index) := '  OWNER = "' ||
           FND_LOAD_UTIL.OWNER_NAME(p_attributes_rec.last_updated_by) || '"';
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  LAST_UPDATE_DATE = "' ||
                to_char(p_attributes_rec.last_update_date,
                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  LAST_UPDATE_LOGIN = "' ||
                nvl(to_char(p_attributes_rec.last_update_login),'') || '"';
  -- translation columns
  --
  if ((p_attributes_tl_rec.name IS NOT NULL) and
     (p_attributes_tl_rec.name <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  NAME = "' ||
    		AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(p_attributes_tl_rec.name) || '"';
  end if;
  if ((p_attributes_tl_rec.attribute_label_long IS NOT NULL) and
     (p_attributes_tl_rec.attribute_label_long <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  ATTRIBUTE_LABEL_LONG = "' ||
    		AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(p_attributes_tl_rec.attribute_label_long)
    		 || '"';
  end if;
  if ((p_attributes_tl_rec.attribute_label_short IS NOT NULL) and
     (p_attributes_tl_rec.attribute_label_short <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  ATTRIBUTE_LABEL_SHORT = "' ||
    		AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(p_attributes_tl_rec.attribute_label_short)
    		 || '"';
  end if;
  if ((p_attributes_tl_rec.description IS NOT NULL) and
     (p_attributes_tl_rec.description <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  DESCRIPTION = "' ||
    		AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(p_attributes_tl_rec.description) || '"';
  end if;

  l_index := l_index + 1;
  l_databuffer_tbl(l_index) := 'END ATTRIBUTE';
  l_index := l_index + 1;
  l_databuffer_tbl(l_index) := ' ';

  --
  -- - Write attribute data out to the specified file
  --
  AK_ON_OBJECTS_PVT.WRITE_FILE (
    p_return_status => l_return_status,
    p_buffer_tbl => l_databuffer_tbl,
    p_write_mode => AK_ON_OBJECTS_PUB.G_APPEND
  );

  --
  -- If API call returns with an error status...
  --
  if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
     (l_return_status = FND_API.G_RET_STS_ERROR) then
    RAISE FND_API.G_EXC_ERROR;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN VALUE_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_ATTRIBUTE_VALUE_ERROR');
      FND_MESSAGE.SET_TOKEN('KEY',
        to_char(p_attributes_rec.attribute_application_id) ||
        ' ' || p_attributes_rec.attribute_code);
      FND_MSG_PUB.Add;
      FND_MESSAGE.SET_NAME('AK','AK_ATTRIBUTE_NOT_DOWNLOADED');
      FND_MESSAGE.SET_TOKEN('KEY',
        to_char(p_attributes_rec.attribute_application_id) ||
        ' ' || p_attributes_rec.attribute_code);
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
      FND_MESSAGE.SET_NAME('AK','AK_ATTRIBUTE_NOT_DOWNLOADED');
      FND_MESSAGE.SET_TOKEN('KEY',
        to_char(p_attributes_rec.attribute_application_id) ||
        ' ' || p_attributes_rec.attribute_code);
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
--  Procedure   DOWNLOAD_ATTRIBUTE
--
--  Usage       Private API for downloading attributes. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API will extract the attributes selected
--              by application ID or by key values from the
--              database to the output file.
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
--                  given in p_attribute_pk_tbl.
--              p_attribute_pk_tbl : IN optional
--                  If given, only attributes whose key values are
--                  included in this table will be written to the
--                  output file.
--
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure DOWNLOAD_ATTRIBUTE (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_application_id           IN      NUMBER := FND_API.G_MISS_NUM,
  p_attribute_pk_tbl         IN      AK_ATTRIBUTE_PUB.Attribute_PK_Tbl_Type
                                   := AK_ATTRIBUTE_PUB.G_MISS_ATTRIBUTE_PK_TBL,
  p_nls_language             IN      VARCHAR2
) is
  cursor l_get_attribute_1_csr (appl_id_parm number) is
    select *
    from AK_ATTRIBUTES
    where ATTRIBUTE_APPLICATION_ID = appl_id_parm;
  cursor l_get_attribute_2_csr (appl_id_parm number,
				attr_code_parm varchar2) is
    select *
    from AK_ATTRIBUTES
    where ATTRIBUTE_APPLICATION_ID = appl_id_parm
    and   ATTRIBUTE_CODE = attr_code_parm;
  cursor l_get_attribute_2p_csr (appl_id_parm number,
                                attr_code_parm varchar2) is
    select *
    from AK_ATTRIBUTES
    where ATTRIBUTE_APPLICATION_ID = appl_id_parm
    and   ATTRIBUTE_CODE like attr_code_parm;
  cursor l_get_tl_csr (appl_id_parm number,
			attr_code_parm varchar2,
			lang_parm varchar2) is
    select *
    from AK_ATTRIBUTES_TL
    where ATTRIBUTE_APPLICATION_ID = appl_id_parm
    and   ATTRIBUTE_CODE = attr_code_parm
    and   LANGUAGE = lang_parm;
  cursor l_get_tlp_csr (appl_id_parm number,
                        attr_code_parm varchar2,
                        lang_parm varchar2) is
    select *
    from AK_ATTRIBUTES_TL
    where ATTRIBUTE_APPLICATION_ID = appl_id_parm
    and   ATTRIBUTE_CODE like attr_code_parm
    and   LANGUAGE = lang_parm;
  cursor l_percent_check (attr_code_parm varchar2) is
    select instr(attr_code_parm,'%')
    from dual;

  l_api_version_number CONSTANT number := 1.0;
  l_api_name           CONSTANT varchar2(30) := 'Download';
  l_attribute_found    BOOLEAN;
  i number;
  l_attribute_appl_id  NUMBER;
  l_attributes_rec     ak_attributes%ROWTYPE;
  l_attributes_tl_rec  ak_attributes_tl%ROWTYPE;
  l_return_status      varchar2(1);
  l_select_by_appl_id  BOOLEAN;
  l_percent		NUMBER;
begin
  IF NOT FND_API.Compatible_API_Call (
    l_api_version_number, p_api_version_number, l_api_name,
    G_PKG_NAME) then
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return;
  END IF;

  --
  -- Check that one of the following selection criteria is given:
  -- - p_application_id alone, or
  -- - attribute_application_id and attribute_code pairs in
  --   p_attribute_pk_tbl, or
  -- - both p_application_id and p_attribute_pk_tbl if any
  --   p_attribute_application_id is missing in p_attribute_pk_tbl
  --
  if (p_application_id = FND_API.G_MISS_NUM) then
    if (p_attribute_pk_tbl.count = 0) then
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.SET_NAME('AK','AK_NO_SELECTION');
        FND_MSG_PUB.Add;
      end if;
      raise FND_API.G_EXC_ERROR;
    else
      --
      -- since no application ID is passed in thru p_application_id,
      -- none of the attribute_application_id or attribute_code
      -- in table can be null
      --

      for i in p_attribute_pk_tbl.FIRST .. p_attribute_pk_tbl.LAST LOOP
        if (p_attribute_pk_tbl.exists(i)) then
          if (p_attribute_pk_tbl(i).attribute_appl_id = FND_API.G_MISS_NUM) or
             (p_attribute_pk_tbl(i).attribute_code = FND_API.G_MISS_CHAR)
          then
            if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.SET_NAME('AK','AK_INVALID_LIST');
              FND_MESSAGE.SET_TOKEN('ELEMENT_NUM',to_char(i));
              FND_MSG_PUB.Add;
            end if;
            raise FND_API.G_EXC_ERROR;
          end if; /* if attribute_appl_id is null */
        end if; /* if exists */
      end LOOP;

    end if;
  end if;

  --
  -- selection is by application ID if the attribute list table is empty
  --
  if (p_attribute_pk_tbl.count = 0) then
    l_select_by_appl_id := TRUE;
  else
    l_select_by_appl_id := FALSE;
  end if;

  --
  -- Retrieve attributes from AK_ATTRIBUTES that fits the selection
  -- criteria, one at a time, and write it the buffer table
  --
  if (l_select_by_appl_id) then
    --
    -- download by application ID
    --
    open l_get_attribute_1_csr(p_application_id);

    loop
      fetch l_get_attribute_1_csr into l_attributes_rec;
      exit when l_get_attribute_1_csr%notfound;
      open l_get_tl_csr (l_attributes_rec.attribute_application_id,
			 l_attributes_rec.attribute_code,
                         p_nls_language);
      fetch l_get_tl_csr into l_attributes_tl_rec;
      exit when l_get_tl_csr%notfound;
      close l_get_tl_csr;

      WRITE_TO_BUFFER(
		p_validation_level => p_validation_level,
		p_return_status => l_return_status,
		p_attributes_rec => l_attributes_rec,
		p_attributes_tl_rec => l_attributes_tl_rec
	  );
	  --
	  -- abort Download if validation has been failed
	  --
	  if (l_return_status = FND_API.G_RET_STS_ERROR) then
	    raise FND_API.G_EXC_ERROR;
	  end if;
    end loop;
    close l_get_attribute_1_csr;

    if l_get_tl_csr%isopen then
      close l_get_tl_csr;
    end if;
  else
    --
    -- download by list of attributes
    --
    for i in p_attribute_pk_tbl.FIRST .. p_attribute_pk_tbl.LAST LOOP
      if (p_attribute_pk_tbl.exists(i)) then
        --
        -- default application ID to p_application_id if not given
        --
        if (p_attribute_pk_tbl(i).attribute_appl_id = FND_API.G_MISS_NUM) then
          l_attribute_appl_id := p_application_id;
        else
          l_attribute_appl_id := p_attribute_pk_tbl(i).attribute_appl_id;
        end if;

        --
        -- Retrieve attribute and its TL entry from the database
        --
        l_attribute_found := TRUE;
	open l_percent_check(p_attribute_pk_tbl(i).attribute_code);
	fetch l_percent_check into l_percent;
	if l_percent <> 0 then
	   open l_get_attribute_2p_csr(l_attribute_appl_id,
                                   p_attribute_pk_tbl(i).attribute_code);
           loop
             fetch l_get_attribute_2p_csr into l_attributes_rec;
             exit when l_get_attribute_2p_csr%notfound;
             open l_get_tlp_csr (l_attributes_rec.attribute_application_id,
                         l_attributes_rec.attribute_code,
                         p_nls_language);
             fetch l_get_tlp_csr into l_attributes_tl_rec;
             exit when l_get_tlp_csr%notfound;
             close l_get_tlp_csr;

             WRITE_TO_BUFFER(
                p_validation_level => p_validation_level,
                p_return_status => l_return_status,
                p_attributes_rec => l_attributes_rec,
                p_attributes_tl_rec => l_attributes_tl_rec
             );
             --
             -- abort Download if validation has been failed
             --
             if (l_return_status = FND_API.G_RET_STS_ERROR) then
                raise FND_API.G_EXC_ERROR;
             end if;
           end loop;
           close l_get_attribute_2p_csr;
        else
           open l_get_attribute_2_csr(l_attribute_appl_id,
				   p_attribute_pk_tbl(i).attribute_code);
           fetch l_get_attribute_2_csr into l_attributes_rec;
           if (l_get_attribute_2_csr%notfound) then
             if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
               FND_MESSAGE.SET_NAME('AK','AK_ATTRIBUTE_DOES_NOT_EXIST');
               FND_MSG_PUB.Add;
               FND_MESSAGE.SET_NAME('AK','AK_ATTR_NOT_DOWNLOADED');
               FND_MESSAGE.SET_TOKEN('KEY', to_char(l_attribute_appl_id) ||
                                  ' ' || p_attribute_pk_tbl(i).attribute_code);
               FND_MSG_PUB.Add;
             end if;
             l_attribute_found := FALSE;
           else
             open l_get_tl_csr (l_attributes_rec.attribute_application_id,
             	             l_attributes_rec.attribute_code,
                             p_nls_language);
             fetch l_get_tl_csr into l_attributes_tl_rec;
             if ( l_get_tl_csr%notfound) then
               if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
                 FND_MESSAGE.SET_NAME('AK','AK_ATTRIBUTE_DOES_NOT_EXIST');
                 FND_MSG_PUB.Add;
               end if;
               l_attribute_found := FALSE;
             end if;
             close l_get_tl_csr;
           end if;
           close l_get_attribute_2_csr;

           --
           -- write attribute and its TL entry to buffer
           --
           if l_attribute_found then
             WRITE_TO_BUFFER(
		p_validation_level => p_validation_level,
		p_return_status => l_return_status,
		p_attributes_rec => l_attributes_rec,
		p_attributes_tl_rec => l_attributes_tl_rec
	      );
    	      --
	      -- abort Download if validation has been failed
	      --
	      if (l_return_status = FND_API.G_RET_STS_ERROR) then
	        raise FND_API.G_EXC_ERROR;
	      end if;
          end if; /* if l_attribute_found */
	end if; /* if l_percent */
	close l_percent_check;
      end if; /* if exists(i) */
    end loop;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
end DOWNLOAD_ATTRIBUTE;

--=======================================================
--  Procedure   UPLOAD_ATTRIBUTE
--
--  Usage       Private API for loading attributes from a
--              loader file to the database.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API reads the attribute data stored in
--              the loader file currently being processed, parses
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
procedure UPLOAD_ATTRIBUTE (
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
  l_api_name                 CONSTANT varchar2(30) := 'Upload_Attribute';
  l_attribute_rec            ak_attributes%ROWTYPE;
  l_attribute_tl_rec         AK_ATTRIBUTE_PUB.Attribute_Tl_Rec_Type;
  l_buffer                   AK_ON_OBJECTS_PUB.Buffer_Type;
  l_column  	             varchar2(30);
  l_dummy                    NUMBER;
  l_empty_attribute_rec      ak_attributes%ROWTYPE;
  l_empty_attribute_tl_rec   AK_ATTRIBUTE_PUB.Attribute_Tl_Rec_Type;
  l_eof_flag                 VARCHAR2(1);
  l_line_num                 NUMBER;
  l_lines_read               NUMBER;
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(2000);
  l_more_attr                BOOLEAN := TRUE;
  l_return_status            varchar2(1);
  l_saved_token              AK_ON_OBJECTS_PUB.Buffer_type;
  l_state                    NUMBER;       /* parse state */
  l_token                    AK_ON_OBJECTS_PUB.Buffer_Type;
  l_value_count              NUMBER;  /* # of values read for current column */
  l_copy_redo_flag           BOOLEAN := FALSE;
  l_user_id1				 NUMBER;
  l_user_id2				 NUMBER;
  l_update1                  DATE;
  l_update2		     DATE;
begin
  IF NOT FND_API.Compatible_API_Call (
    l_api_version_number, p_api_version_number, l_api_name,
    G_PKG_NAME) then
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return;
  END IF;

   --dbms_output.put_line('Started attribute upload: ' ||
   --                           to_char(sysdate, 'MON-DD HH24:MI:SS'));

--  SAVEPOINT Start_Upload;

  --
  -- Retrieve the first non-blank, non-comment line
  --
  l_state := 0;
  l_eof_flag := 'N';
  --
  -- if calling from ak_on_objects.upload (ie, loader timestamp is given),
  -- the tokens 'BEGIN ATTRIBUTE' has already been parsed. Set initial
  -- buffer to 'BEGIN ATTRIBUTE' before reading the next line from the
  -- file. Otherwise, set initial buffer to null.
  --
  if (p_loader_timestamp <> FND_API.G_MISS_DATE) then
    l_buffer := 'BEGIN ATTRIBUTE ' || p_buffer;
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
      --dbms_output.put_line('READ_LINE gets l_buffer = '||l_buffer);

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

  --
  -- Read tokens from file, one at a time
  --
  while (l_eof_flag = 'N') and (l_buffer is not null)
        and (l_more_attr) loop

    AK_ON_OBJECTS_PVT.GET_TOKEN(
      p_return_status => l_return_status,
      p_in_buf => l_buffer,
      p_token => l_token
    );

--dbms_output.put_line(' State:' || l_state || 'Token:' || l_token);
--                              to_char(sysdate, 'MON-DD HH24:MI:SS'));

    if (l_return_status = FND_API.G_RET_STS_ERROR) or
       (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        -- dbms_output.put_line('State '||l_state||' Token '||l_token|| 'l_buffer '||l_buffer);
        FND_MESSAGE.SET_NAME('AK','AK_GET_TOKEN_ERROR');
        FND_MSG_PUB.Add;
      end if;
      -- dbms_output.put_line('Error parsing buffer');
      raise FND_API.G_EXC_ERROR;
    end if;

    if (l_state = 0) then
      if (l_token = 'BEGIN') then
        --== Clear out previous column data  ==--
        l_attribute_rec := l_empty_attribute_rec;
        l_attribute_tl_rec := l_empty_attribute_tl_rec;
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
      if (l_token = 'ATTRIBUTE') then
        l_state := 2;
      else
        -- Found the beginning of a non-attribute object,
        -- rebuild last line and pass it back to the caller
        -- (ak_on_objects_pvt.upload).
        p_buffer_out := 'BEGIN ' || l_token || ' ' || l_buffer;
        l_more_attr := FALSE;
      end if;
    elsif (l_state = 2) then
      if (l_token is not null) then
        l_attribute_rec.attribute_application_id := to_number(l_token);
        l_state := 3;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED','ATTRIBUTE_APPLICATION_ID');
          FND_MSG_PUB.Add;
        end if;
        -- dbms_output.put_line('Expecting attribute application ID');
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 3) then
      if (l_token is not null) then
        l_attribute_rec.attribute_code := l_token;
        l_value_count := null;
        l_state := 10;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED','ATTRIBUTE_CODE');
          FND_MSG_PUB.Add;
        end if;
        --dbms_output.put_line('Expecting attribute code');
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 10) then
      if (l_token = 'END') then
        l_state := 19;
      elsif (l_token = 'ATTRIBUTE_LABEL_LENGTH') or
	    (l_token = 'ATTRIBUTE_VALUE_LENGTH') or
            (l_token = 'BOLD') or
            (l_token = 'ITALIC') or
            (l_token = 'VERTICAL_ALIGNMENT') or
            (l_token = 'HORIZONTAL_ALIGNMENT') or
            (l_token = 'DATA_TYPE') or
            (l_token = 'UPPER_CASE_FLAG') or
            (l_token = 'DEFAULT_VALUE_VARCHAR2') or
            (l_token = 'DEFAULT_VALUE_NUMBER') or
            (l_token = 'DEFAULT_VALUE_DATE') or
            (l_token = 'LOV_REGION') or
            (l_token = 'ITEM_STYLE') or
            (l_token = 'DISPLAY_HEIGHT') or
            (l_token = 'CSS_CLASS_NAME') or
            (l_token = 'POPLIST_VIEWOBJECT') or
            (l_token = 'POPLIST_DISPLAY_ATTRIBUTE') or
            (l_token = 'POPLIST_VALUE_ATTRIBUTE') or
			(l_token = 'CSS_LABEL_CLASS_NAME') or
			(l_token = 'PRECISION') or
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
            (l_token = 'NAME') or
            (l_token = 'DESCRIPTION') then
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
            FND_MESSAGE.SET_TOKEN('EXPECTED','ATTRIBUTE');
            FND_MSG_PUB.Add;
          end if;
--        dbms_output.put_line('Expecting attribute field or END');
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
      if (l_column = 'ATTRIBUTE_LABEL_LENGTH') then
         l_attribute_rec.attribute_label_length := to_number(l_token);
         l_state := 10;
      elsif (l_column = 'ATTRIBUTE_VALUE_LENGTH') then
         l_attribute_rec.attribute_value_length := to_number(l_token);
         l_state := 10;
      elsif (l_column = 'BOLD') then
         l_attribute_rec.bold := l_token;
         l_state := 10;
      elsif (l_column = 'ITALIC')then
         l_attribute_rec.italic := l_token;
         l_state := 10;
      elsif (l_column = 'VERTICAL_ALIGNMENT') then
         l_attribute_rec.vertical_alignment := l_token;
         l_state := 10;
      elsif (l_column = 'HORIZONTAL_ALIGNMENT') then
         l_attribute_rec.horizontal_alignment := l_token;
         l_state := 10;
      elsif (l_column = 'DATA_TYPE') then
         l_attribute_rec.data_type := l_token;
         l_state := 10;
      elsif (l_column = 'UPPER_CASE_FLAG') then
         l_attribute_rec.upper_case_flag := l_token;
         l_state := 10;
      elsif (l_column = 'DEFAULT_VALUE_VARCHAR2') then
         l_attribute_rec.default_value_varchar2 := l_token;
         l_state := 10;
      elsif (l_column = 'DEFAULT_VALUE_NUMBER') then
         l_attribute_rec.default_value_number := to_number(l_token);
         l_state := 10;
      elsif (l_column = 'DEFAULT_VALUE_DATE') then
         l_attribute_rec.default_value_date := to_date(l_token,
                                               AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
         l_state := 10;
      elsif (l_column = 'LOV_REGION') then
         l_attribute_rec.lov_region_application_id := to_number(l_token);
		 l_state := 14;
      elsif (l_column = 'ITEM_STYLE') then
         l_attribute_rec.item_style := l_token;
         l_state := 10;
      elsif (l_column = 'DISPLAY_HEIGHT') then
         l_attribute_rec.display_height := to_number(l_token);
         l_state := 10;
      elsif (l_column = 'CSS_CLASS_NAME') then
         l_attribute_rec.css_class_name := l_token;
         l_state := 10;
      elsif (l_column = 'POPLIST_VIEWOBJECT') then
         l_attribute_rec.poplist_viewobject := l_token;
         l_state := 10;
      elsif (l_column = 'POPLIST_DISPLAY_ATTRIBUTE') then
         l_attribute_rec.poplist_display_attribute := l_token;
         l_state := 10;
      elsif (l_column = 'POPLIST_VALUE_ATTRIBUTE') then
         l_attribute_rec.poplist_value_attribute := l_token;
         l_state := 10;
      elsif (l_column = 'CSS_LABEL_CLASS_NAME') then
         l_attribute_rec.css_label_class_name := l_token;
         l_state := 10;
      elsif (l_column = 'PRECISION') then
         l_attribute_rec.precision := l_token;
         l_state := 10;
      elsif (l_column = 'EXPANSION') then
         l_attribute_rec.expansion := to_number(l_token);
         l_state := 10;
      elsif (l_column = 'ALS_MAX_LENGTH') then
         l_attribute_rec.als_max_length := to_number(l_token);
         l_state := 10;
      elsif (l_column = 'ATTRIBUTE_CATEGORY') then
         l_attribute_rec.attribute_category := l_token;
         l_state := 10;
      elsif (l_column = 'ATTRIBUTE1') then
         l_attribute_rec.attribute1 := l_token;
         l_state := 10;
      elsif (l_column = 'ATTRIBUTE2') then
         l_attribute_rec.attribute2 := l_token;
         l_state := 10;
      elsif (l_column = 'ATTRIBUTE3') then
         l_attribute_rec.attribute3 := l_token;
         l_state := 10;
      elsif (l_column = 'ATTRIBUTE4') then
         l_attribute_rec.attribute4 := l_token;
         l_state := 10;
      elsif (l_column = 'ATTRIBUTE5') then
         l_attribute_rec.attribute5 := l_token;
         l_state := 10;
      elsif (l_column = 'ATTRIBUTE6') then
         l_attribute_rec.attribute6 := l_token;
         l_state := 10;
      elsif (l_column = 'ATTRIBUTE7') then
         l_attribute_rec.attribute7 := l_token;
         l_state := 10;
      elsif (l_column = 'ATTRIBUTE8') then
         l_attribute_rec.attribute8 := l_token;
         l_state := 10;
      elsif (l_column = 'ATTRIBUTE9') then
         l_attribute_rec.attribute9 := l_token;
         l_state := 10;
      elsif (l_column = 'ATTRIBUTE10') then
         l_attribute_rec.attribute10 := l_token;
         l_state := 10;
      elsif (l_column = 'ATTRIBUTE11') then
         l_attribute_rec.attribute11 := l_token;
         l_state := 10;
      elsif (l_column = 'ATTRIBUTE12') then
         l_attribute_rec.attribute12 := l_token;
         l_state := 10;
      elsif (l_column = 'ATTRIBUTE13') then
         l_attribute_rec.attribute13 := l_token;
         l_state := 10;
      elsif (l_column = 'ATTRIBUTE14') then
         l_attribute_rec.attribute14 := l_token;
         l_state := 10;
      elsif (l_column = 'ATTRIBUTE15') then
         l_attribute_rec.attribute15 := l_token;
         l_state := 10;
      elsif (l_column = 'CREATED_BY') then
	 l_attribute_rec.created_by := to_number(l_token);
	 l_state := 10;
      elsif (l_column = 'CREATION_DATE') then
         l_attribute_rec.creation_date := to_date(l_token,
					AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
         l_state := 10;
      elsif (l_column = 'LAST_UPDATED_BY') then
	 l_attribute_rec.last_updated_by := to_number(l_token);
	 l_state := 10;
      elsif (l_column = 'OWNER') then
         l_attribute_rec.last_updated_by := FND_LOAD_UTIL.OWNER_ID(l_token);
         l_state := 10;
      elsif (l_column = 'LAST_UPDATE_DATE') then
	 l_attribute_rec.last_update_date := to_date(l_token,
					AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
         l_state := 10;
      elsif (l_column = 'LAST_UPDATE_LOGIN') then
	 l_attribute_rec.last_update_login := to_number(l_token);
	 l_state := 10;
      elsif (l_column = 'ATTRIBUTE_LABEL_SHORT') then
         l_attribute_tl_rec.attribute_label_short := l_token;
         l_state := 10;
      elsif (l_column = 'ATTRIBUTE_LABEL_LONG') then
         l_attribute_tl_rec.attribute_label_long := l_token;
         l_state := 10;
      elsif (l_column = 'NAME') then
         l_attribute_tl_rec.name := l_token;
         l_state := 10;
      elsif (l_column = 'DESCRIPTION') then
         l_attribute_tl_rec.description := l_token;
         l_state := 10;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED',l_column);
          FND_MSG_PUB.Add;
        end if;
        --dbms_output.put_line('Expecting ' || l_column || ' value');
        raise FND_API.G_EXC_ERROR;
      end if;
	elsif (l_state = 14) then
	  if (l_column = 'LOV_REGION') then
         l_attribute_rec.lov_region_code := l_token;
         l_state := 10;
	  else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED',l_column);
          FND_MSG_PUB.Add;
        end if;
        --dbms_output.put_line('Expecting ' || l_column || ' value');
        raise FND_API.G_EXC_ERROR;
	  end if;
    elsif (l_state = 19) then
      if (l_token = 'ATTRIBUTE') then
        if AK_ATTRIBUTE_PVT.ATTRIBUTE_EXISTS (
          p_api_version_number => 1.0,
          p_return_status => l_return_status,
          p_attribute_application_id=>
                     l_attribute_rec.attribute_application_id,
          p_attribute_code => l_attribute_rec.attribute_code) then
		--
		-- do not update customized data
		  if (AK_UPLOAD_GRP.G_NO_CUSTOM_UPDATE) then
			select aa.last_updated_by, aat.last_updated_by,
                               aa.last_update_date, aat.last_update_date
                        into l_user_id1, l_user_id2, l_update1, l_update2
			from ak_attributes aa, ak_attributes_tl aat
			where aa.attribute_code = l_attribute_rec.attribute_code
			and aa.attribute_application_id = l_attribute_rec.attribute_application_id
			and aa.attribute_code = aat.attribute_code
			and aa.attribute_application_id = aat.attribute_application_id
			and aat.language = userenv('LANG');

			/*if (( l_user_id1 = 1  or l_user_id1 = 2) and
				(l_user_id2 = 1  or l_user_id2 = 2)) then*/
		if (AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
		      p_loader_timestamp => p_loader_timestamp,
       	       	      p_created_by => l_attribute_rec.created_by,
                      p_creation_date => l_attribute_rec.creation_date,
                      p_last_updated_by => l_attribute_rec.last_updated_by,
                      p_db_last_updated_by => l_user_id1,
                      p_last_update_date => l_attribute_rec.last_update_date,
                      p_db_last_update_date => l_update1,
                      p_last_update_login => l_attribute_rec.last_update_login,
                      p_create_or_update => 'UPDATE') and

                   AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
                      p_loader_timestamp => p_loader_timestamp,
                      p_created_by => l_attribute_rec.created_by,
                      p_creation_date => l_attribute_rec.creation_date,
                      p_last_updated_by => l_attribute_rec.last_updated_by,
                      p_db_last_updated_by => l_user_id2,
                      p_last_update_date => l_attribute_rec.last_update_date,
                      p_db_last_update_date => l_update2,
                      p_last_update_login => l_attribute_rec.last_update_login,
                      p_create_or_update => 'UPDATE')) then

	            AK_ATTRIBUTE_PVT.UPDATE_ATTRIBUTE (
	              p_validation_level => p_validation_level,
		          p_api_version_number => 1.0,
	              p_msg_count => l_msg_count,
	              p_msg_data => l_msg_data,
	              p_return_status => l_return_status,
		          p_attribute_application_id =>
	                               l_attribute_rec.attribute_application_id,
	              p_attribute_code => l_attribute_rec.attribute_code,
		          p_attribute_label_length => l_attribute_rec.attribute_label_length,
		          p_attribute_value_length => l_attribute_rec.attribute_value_length,
		          p_bold => l_attribute_rec.bold,
		          p_italic => l_attribute_rec.italic,
		          p_vertical_alignment => l_attribute_rec.vertical_alignment,
		          p_horizontal_alignment => l_attribute_rec.horizontal_alignment,
		          p_data_type => l_attribute_rec.data_type,
			  p_precision => l_attribute_rec.precision,
		          p_upper_case_flag => l_attribute_rec.upper_case_flag,
	              p_default_value_varchar2 => l_attribute_rec.default_value_varchar2,
	              p_default_value_number => l_attribute_rec.default_value_number,
	              p_default_value_date => l_attribute_rec.default_value_date,
	              p_lov_region_application_id =>
	                                    l_attribute_rec.lov_region_application_id,
	              p_lov_region_code => l_attribute_rec.lov_region_code,
				  p_item_style => l_attribute_rec.item_style,
		p_display_height => l_attribute_rec.display_height,
		p_css_class_name => l_attribute_rec.css_class_name,
		p_poplist_viewobject => l_attribute_rec.poplist_viewobject,
		p_poplist_display_attr => l_attribute_rec.poplist_display_attribute,
		p_poplist_value_attr => l_attribute_rec.poplist_value_attribute,
		p_css_label_class_name => l_attribute_rec.css_label_class_name,
	              p_attribute_category => l_attribute_rec.attribute_category,
		p_expansion => l_attribute_rec.expansion,
		p_als_max_length => l_attribute_rec.als_max_length,
				  p_attribute1 => l_attribute_rec.attribute1,
				  p_attribute2 => l_attribute_rec.attribute2,
				  p_attribute3 => l_attribute_rec.attribute3,
				  p_attribute4 => l_attribute_rec.attribute4,
				  p_attribute5 => l_attribute_rec.attribute5,
				  p_attribute6 => l_attribute_rec.attribute6,
				  p_attribute7 => l_attribute_rec.attribute7,
				  p_attribute8 => l_attribute_rec.attribute8,
				  p_attribute9 => l_attribute_rec.attribute9,
				  p_attribute10 => l_attribute_rec.attribute10,
				  p_attribute11 => l_attribute_rec.attribute11,
				  p_attribute12 => l_attribute_rec.attribute12,
				  p_attribute13 => l_attribute_rec.attribute13,
				  p_attribute14 => l_attribute_rec.attribute14,
				  p_attribute15 => l_attribute_rec.attribute15,
				  p_created_by => l_attribute_rec.created_by,
				  p_creation_date => l_attribute_rec.creation_date,
				  p_last_updated_by => l_attribute_rec.last_updated_by,
				  p_last_update_date => l_attribute_rec.last_update_date,
				  p_last_update_login => l_attribute_rec.last_update_login,

		          p_name => l_attribute_tl_rec.name,
	              p_attribute_label_long => l_attribute_tl_rec.attribute_label_long,
		          p_attribute_label_short =>l_attribute_tl_rec.attribute_label_short,
		          p_description => l_attribute_tl_rec.description,
		          p_loader_timestamp => p_loader_timestamp,
			      p_pass => p_pass,
	              p_copy_redo_flag => l_copy_redo_flag
	              );
			end if; /* l_user_id */
		  -- update all records --
		  --
		  -- Update record only if Update mode is set to true
		  --
		  elsif (AK_UPLOAD_GRP.G_UPDATE_MODE) then
	            AK_ATTRIBUTE_PVT.UPDATE_ATTRIBUTE (
	              p_validation_level => p_validation_level,
		          p_api_version_number => 1.0,
	              p_msg_count => l_msg_count,
	              p_msg_data => l_msg_data,
	              p_return_status => l_return_status,
		          p_attribute_application_id =>
	                               l_attribute_rec.attribute_application_id,
	              p_attribute_code => l_attribute_rec.attribute_code,
		          p_attribute_label_length => l_attribute_rec.attribute_label_length,
		          p_attribute_value_length => l_attribute_rec.attribute_value_length,
		          p_bold => l_attribute_rec.bold,
		          p_italic => l_attribute_rec.italic,
		          p_vertical_alignment => l_attribute_rec.vertical_alignment,
		          p_horizontal_alignment => l_attribute_rec.horizontal_alignment,
		          p_data_type => l_attribute_rec.data_type,
			  p_precision => l_attribute_rec.precision,
		          p_upper_case_flag => l_attribute_rec.upper_case_flag,
	              p_default_value_varchar2 => l_attribute_rec.default_value_varchar2,
	              p_default_value_number => l_attribute_rec.default_value_number,
	              p_default_value_date => l_attribute_rec.default_value_date,
	              p_lov_region_application_id =>
	                                    l_attribute_rec.lov_region_application_id,
	              p_lov_region_code => l_attribute_rec.lov_region_code,
				  p_item_style => l_attribute_rec.item_style,
                p_display_height => l_attribute_rec.display_height,
                p_css_class_name => l_attribute_rec.css_class_name,
                p_poplist_viewobject => l_attribute_rec.poplist_viewobject,
                p_poplist_display_attr => l_attribute_rec.poplist_display_attribute,
                p_poplist_value_attr => l_attribute_rec.poplist_value_attribute,
                p_css_label_class_name => l_attribute_rec.css_label_class_name,
		p_expansion => l_attribute_rec.expansion,
		p_als_max_length => l_attribute_rec.als_max_length,
	              p_attribute_category => l_attribute_rec.attribute_category,
				  p_attribute1 => l_attribute_rec.attribute1,
				  p_attribute2 => l_attribute_rec.attribute2,
				  p_attribute3 => l_attribute_rec.attribute3,
				  p_attribute4 => l_attribute_rec.attribute4,
				  p_attribute5 => l_attribute_rec.attribute5,
				  p_attribute6 => l_attribute_rec.attribute6,
				  p_attribute7 => l_attribute_rec.attribute7,
				  p_attribute8 => l_attribute_rec.attribute8,
				  p_attribute9 => l_attribute_rec.attribute9,
				  p_attribute10 => l_attribute_rec.attribute10,
				  p_attribute11 => l_attribute_rec.attribute11,
				  p_attribute12 => l_attribute_rec.attribute12,
				  p_attribute13 => l_attribute_rec.attribute13,
				  p_attribute14 => l_attribute_rec.attribute14,
				  p_attribute15 => l_attribute_rec.attribute15,
				  p_created_by => l_attribute_rec.created_by,
				  p_creation_date => l_attribute_rec.creation_date,
				  p_last_updated_by => l_attribute_rec.last_updated_by,
				  p_last_update_date => l_attribute_rec.last_update_date,
			          p_last_update_login => l_attribute_rec.last_update_login,
		          p_name => l_attribute_tl_rec.name,
	              p_attribute_label_long => l_attribute_tl_rec.attribute_label_long,
		          p_attribute_label_short =>l_attribute_tl_rec.attribute_label_short,
		          p_description => l_attribute_tl_rec.description,
		          p_loader_timestamp => p_loader_timestamp,
			      p_pass => p_pass,
	              p_copy_redo_flag => l_copy_redo_flag
	              );
		  end if; -- /* if G_UPDATE_MODE G_NC_UPDATE_MODE*/
        else
          AK_ATTRIBUTE_PVT.CREATE_ATTRIBUTE (
	    p_validation_level => p_validation_level,
	    p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
	    p_attribute_application_id =>
                               l_attribute_rec.attribute_application_id,
	    p_attribute_code => l_attribute_rec.attribute_code,
	    p_attribute_label_length => l_attribute_rec.attribute_label_length,
	    p_attribute_value_length => l_attribute_rec.attribute_value_length,
	    p_bold => l_attribute_rec.bold,
	    p_italic => l_attribute_rec.italic,
	    p_vertical_alignment => l_attribute_rec.vertical_alignment,
	    p_horizontal_alignment => l_attribute_rec.horizontal_alignment,
	    p_data_type => l_attribute_rec.data_type,
	    p_precision => l_attribute_rec.precision,
	    p_upper_case_flag => l_attribute_rec.upper_case_flag,
            p_default_value_varchar2 => l_attribute_rec.default_value_varchar2,
            p_default_value_number => l_attribute_rec.default_value_number,
            p_default_value_date => l_attribute_rec.default_value_date,
            p_lov_region_application_id =>
                                    l_attribute_rec.lov_region_application_id,
            p_lov_region_code => l_attribute_rec.lov_region_code,
			p_item_style => l_attribute_rec.item_style,
		p_display_height => l_attribute_rec.display_height,
		p_css_class_name => l_attribute_rec.css_class_name,
		p_poplist_viewobject => l_attribute_rec.poplist_viewobject,
		p_poplist_display_attr => l_attribute_rec.poplist_display_attribute,
		p_poplist_value_attr => l_attribute_rec.poplist_value_attribute,
		p_css_label_class_name => l_attribute_rec.css_label_class_name,
			p_expansion => l_attribute_rec.expansion,
			p_als_max_length => l_attribute_rec.als_max_length,
            p_attribute_category => l_attribute_rec.attribute_category,
			p_attribute1 => l_attribute_rec.attribute1,
			p_attribute2 => l_attribute_rec.attribute2,
			p_attribute3 => l_attribute_rec.attribute3,
			p_attribute4 => l_attribute_rec.attribute4,
			p_attribute5 => l_attribute_rec.attribute5,
			p_attribute6 => l_attribute_rec.attribute6,
			p_attribute7 => l_attribute_rec.attribute7,
			p_attribute8 => l_attribute_rec.attribute8,
			p_attribute9 => l_attribute_rec.attribute9,
			p_attribute10 => l_attribute_rec.attribute10,
			p_attribute11 => l_attribute_rec.attribute11,
			p_attribute12 => l_attribute_rec.attribute12,
			p_attribute13 => l_attribute_rec.attribute13,
			p_attribute14 => l_attribute_rec.attribute14,
			p_attribute15 => l_attribute_rec.attribute15,
			p_created_by => l_attribute_rec.created_by,
			p_creation_date => l_attribute_rec.creation_date,
			p_last_updated_by => l_attribute_rec.last_updated_by,
			p_last_update_date => l_attribute_rec.last_update_date,
			p_last_update_login => l_attribute_rec.last_update_login,
	    p_name => l_attribute_tl_rec.name,
            p_attribute_label_long => l_attribute_tl_rec.attribute_label_long,
	    p_attribute_label_short =>l_attribute_tl_rec.attribute_label_short,
	    p_description => l_attribute_tl_rec.description,
	    p_loader_timestamp => p_loader_timestamp,
		p_pass => p_pass,
        p_copy_redo_flag => l_copy_redo_flag
          );
        end if; -- /* if ATTRIBUTE_EXISTS */
        --
        -- If API call returns with an error status, upload aborts
        if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
        (l_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        end if; -- /* if l_return_status */
		--
		-- if validation fails, then this record should go to second pass
		if (l_copy_redo_flag) then
		  G_ATTRIBUTE_REDO_INDEX := G_ATTRIBUTE_REDO_INDEX + 1;
		  G_ATTRIBUTE_REDO_TBL(G_ATTRIBUTE_REDO_INDEX) := l_attribute_rec;
		  G_ATTRIBUTE_TL_REDO_TBL(G_ATTRIBUTE_REDO_INDEX) := l_attribute_tl_rec;
		  l_copy_redo_flag := FALSE;
		end if; --/* if l_copy_redo_flag */
        l_state := 0;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED','ATTRIBUTE');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
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

  end LOOP;

  -- If the loops end in a state other then at the end of an attribute
  -- (state 0) or when the beginning of another business object was
  -- detected, then the file must have ended prematurely, which is an error
  --
  if (l_state <> 0) and (l_more_attr) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
      FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
      FND_MESSAGE.SET_TOKEN('TOKEN','END OF FILE');
      FND_MESSAGE.SET_TOKEN('EXPECTED',null);
      FND_MSG_PUB.Add;
    end if;
    --dbms_output.put_line('Unexpected END OF FILE: state is ' ||
    --		to_char(l_state));
    raise FND_API.G_EXC_ERROR;
  end if;

  --
  -- Load line number of the last file line processed
  --
  p_line_num_out := l_line_num;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- dbms_output.put_line('Leaving attribute upload: ' ||
  --                            to_char(sysdate, 'MON-DD HH24:MI:SS'));

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
  WHEN VALUE_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('AK','AK_ATTRIBUTE_VALUE_ERROR');
    FND_MESSAGE.SET_TOKEN('KEY',to_char(l_attribute_rec.attribute_application_id) ||
                                ' ' || l_attribute_rec.attribute_code);
    FND_MSG_PUB.Add;
	FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240)||': '||l_column||'='||l_token );
	FND_MSG_PUB.Add;
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;
end UPLOAD_ATTRIBUTE;

--=======================================================
--  Procedure   INSERT_ATTRIBUTE_PK_TABLE
--
--  Usage       Private API for inserting the given attribute's
--              primary key value into the given attribute
--              table.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API inserts the given attribute primary
--              key value into a given attribute table
--              (of type Attribute_PK_Tbl_Type) only if the
--              primary key does not already exist in the table.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_attribute_application_id : IN required
--                  Application ID of the attribute to be inserted to the
--                  table.
--              p_attribute_code : IN required
--                  Application code of the attribute to be inserted to the
--                  table.
--              p_attribute_pk_tbl : IN OUT
--                  Attribute table to be updated.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure INSERT_ATTRIBUTE_PK_TABLE (
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_attribute_application_id IN      NUMBER,
  p_attribute_code           IN      VARCHAR2,
  p_attribute_pk_tbl         IN OUT NOCOPY  AK_ATTRIBUTE_PUB.Attribute_PK_Tbl_Type
) is
  l_api_version_number CONSTANT number := 1.0;
  l_api_name           CONSTANT varchar2(30) := 'Insert_Attribute_PK_Table';
  l_index         NUMBER;
begin
  --
  -- if table is empty, just insert the attribute primary key into it
  --
  if (p_attribute_pk_tbl.count = 0) then
    p_attribute_pk_tbl(1).attribute_appl_id := p_attribute_application_id;
    p_attribute_pk_tbl(1).attribute_code := p_attribute_code;
    return;
  end if;

  --
  -- otherwise, insert the attribute to the end of the table if it is
  -- not already in the table. If it is already in the table, return
  -- without changing the table.
  --
  for l_index in p_attribute_pk_tbl.FIRST .. p_attribute_pk_tbl.LAST loop
    if (p_attribute_pk_tbl.exists(l_index)) then
      if (p_attribute_pk_tbl(l_index).attribute_appl_id = p_attribute_application_id)
         and
         (p_attribute_pk_tbl(l_index).attribute_code = p_attribute_code) then
        return;
      end if;
    end if;
  end loop;

  l_index := p_attribute_pk_tbl.LAST + 1;
  p_attribute_pk_tbl(l_index).attribute_appl_id := p_attribute_application_id;
  p_attribute_pk_tbl(l_index).attribute_code := p_attribute_code;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;
end INSERT_ATTRIBUTE_PK_TABLE;

--=======================================================
--  Procedure   UPDATE_ATTRIBUTE
--
--  Usage       Private API for updating an attribute.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API updates an attribute using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Attribute columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will update the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--				p_temp_redo_tbl: IN required
--                  For saving records temporarily to see if it
--                  fails in first pass of upload. If it does,
--                  then the record is saved for second pass
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure UPDATE_ATTRIBUTE (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_init_msg_tbl             IN      BOOLEAN := FALSE,
  p_msg_count                OUT NOCOPY     NUMBER,
  p_msg_data                 OUT NOCOPY     VARCHAR2,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_attribute_application_id IN      NUMBER,
  p_attribute_code           IN      VARCHAR2,
  p_attribute_label_length   IN      NUMBER := FND_API.G_MISS_NUM,
  p_attribute_value_length   IN      NUMBER := FND_API.G_MISS_NUM,
  p_bold                     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_italic                   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_vertical_alignment       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_horizontal_alignment     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_data_type                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_upper_case_flag          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_default_value_varchar2   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_default_value_number     IN      NUMBER := FND_API.G_MISS_NUM,
  p_default_value_date       IN      DATE := FND_API.G_MISS_DATE,
  p_lov_region_application_id IN     NUMBER := FND_API.G_MISS_NUM,
  p_lov_region_code          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_item_style				 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
  p_display_height			 IN		 NUMBER := FND_API.G_MISS_NUM,
  p_css_class_name 			 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
  p_poplist_viewobject		 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
  p_poplist_display_attr	 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
  p_poplist_value_attr		 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
  p_css_label_class_name	 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
  p_precision			IN              NUMBER := FND_API.G_MISS_NUM,
  p_expansion			IN		NUMBER := FND_API.G_MISS_NUM,
  p_als_max_length		IN		NUMBER := FND_API.G_MISS_NUM,
  p_attribute_category       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute1               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute2               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute3               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute4               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute5               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute6               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute7               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute8               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute9               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute10              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute11              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute12              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute13              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute14              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute15              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_name                     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute_label_long     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute_label_short    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_description              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
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
    from  AK_ATTRIBUTES
    where ATTRIBUTE_APPLICATION_ID = p_attribute_application_id
    and   ATTRIBUTE_CODE = p_attribute_code
    for update of ATTRIBUTE_APPLICATION_ID;
  cursor l_get_tl_row_csr (lang_parm varchar2) is
    select *
    from  AK_ATTRIBUTES_TL
    where ATTRIBUTE_APPLICATION_ID = p_attribute_application_id
    and   ATTRIBUTE_CODE = p_attribute_code
    and   LANGUAGE = lang_parm
    for update of ATTRIBUTE_APPLICATION_ID;
  cursor l_check_navigation_csr is
    select 1
    from  AK_OBJECT_ATTRIBUTE_NAVIGATION
    where ATTRIBUTE_APPLICATION_ID = p_attribute_application_id
    and   ATTRIBUTE_CODE = p_attribute_code;
  cursor l_check_attr_value_csr is
    select 1
    from  AK_INST_ATTRIBUTE_VALUES
    where ATTRIBUTE_APPLICATION_ID = p_attribute_application_id
    and   ATTRIBUTE_CODE = p_attribute_code;
  cursor l_check_page_region_item_csr is
    select 1
    from   AK_FLOW_PAGE_REGION_ITEMS ri
    where ri.to_url_attribute_appl_id = p_attribute_application_id
    and   ri.to_url_attribute_code = p_attribute_code;
  l_api_version_number CONSTANT number := 1.0;
  l_api_name           CONSTANT varchar2(30) := 'Update_Attribute';
  l_attributes_rec     ak_attributes%ROWTYPE;
  l_attributes_tl_rec  ak_attributes_tl%ROWTYPE;
  l_created_by         number;
  l_creation_date      date;
  l_dummy              number;
  l_error              boolean;
  l_lang               varchar2(30);
  l_last_update_date   date;
  l_last_update_login  number;
  l_last_updated_by    number;
  l_return_status      varchar2(1);
  l_item_style			varchar2(30) := 'TEXT';
  l_file_version	number;
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

  savepoint start_update_attribute;

  select userenv('LANG') into l_lang
  from dual;

  --
  -- retrieve ak_attributes row if it exists
  --
  open l_get_row_csr;
  fetch l_get_row_csr into l_attributes_rec;
  if (l_get_row_csr%notfound) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
      FND_MESSAGE.SET_NAME('AK','AK_ATTRIBUTE_DOES_NOT_EXIST');
      FND_MSG_PUB.Add;
    end if;
    close l_get_row_csr;
    raise FND_API.G_EXC_ERROR;
  end if;
  close l_get_row_csr;

  --
  -- retrieve ak_attributes_tl row if it exists
  --
  open l_get_tl_row_csr(l_lang);
  fetch l_get_tl_row_csr into l_attributes_tl_rec;
  if (l_get_tl_row_csr%notfound) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
      FND_MESSAGE.SET_NAME('AK','AK_ATTRIBUTE_DOES_NOT_EXIST');
      FND_MSG_PUB.Add;
    end if;
    -- dbms_output.put_line('Error - TL Row does not exist');
    close l_get_tl_row_csr;
    raise FND_API.G_EXC_ERROR;
  end if;
  close l_get_tl_row_csr;

  --
  --  validate table columns passed in
  --
  if (p_validation_level <> FND_API.G_VALID_LEVEL_NONE) then
    if not VALIDATE_ATTRIBUTE (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_attribute_application_id => p_attribute_application_id,
            p_attribute_code => p_attribute_code,
            p_attribute_label_length => p_attribute_label_length,
            p_attribute_value_length =>  p_attribute_value_length,
            p_bold => p_bold,
            p_italic => p_italic,
            p_vertical_alignment => p_vertical_alignment,
            p_horizontal_alignment => p_horizontal_alignment,
            p_data_type => p_data_type,
            p_upper_case_flag => p_upper_case_flag,
            p_default_value_varchar2 => p_default_value_varchar2,
            p_default_value_number => p_default_value_number,
            p_default_value_date => p_default_value_date,
            p_lov_region_application_id => p_lov_region_application_id,
            p_lov_region_code => p_lov_region_code,
            p_name => p_name,
            p_attribute_label_long => p_attribute_label_long,
            p_attribute_label_short => p_attribute_label_short,
            p_description => p_description,
            p_caller => AK_ON_OBJECTS_PVT.G_UPDATE,
			p_pass => p_pass
          ) then
      if (p_pass = 1) then
        p_copy_redo_flag := TRUE;
      else
        raise FND_API.G_EXC_ERROR;
      end if; --/* if p_pass */
    end if;
  end if;

  --** Additional validation logic for update **

  -- - Cannot change data_type if there are attribute navigation,
  --   attribute value, or page region item data for this attribute

  if ((p_data_type is not null) and (p_data_type <>  FND_API.G_MISS_CHAR) and
     (p_data_type <> l_attributes_rec.data_type)) then

    if (l_attributes_rec.data_type = 'URL') then
      /* see if any 'To URL attribute' in ak_flow_page_region_items */
      /* are using this URL-type object attribute */
      open l_check_page_region_item_csr;
      fetch l_check_page_region_item_csr into l_dummy;
      if (l_check_page_region_item_csr%found) then
        close l_check_page_region_item_csr;
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_CHANGE_DATA_TYPE');
          FND_MESSAGE.SET_TOKEN('FORM','AK_PAGE_REGION_LINKS', TRUE);
          FND_MSG_PUB.Add;
        end if;
        -- dbms_output.put_line(l_api_name || ' Cannot change data type');
        raise FND_API.G_EXC_ERROR;
      end if;
      close l_check_page_region_item_csr;
    else
      /* see if there are any attribute navigation for this non-URL type */
      /* object attribute */
      open l_check_navigation_csr;
      fetch l_check_navigation_csr into l_dummy;
      if (l_check_navigation_csr%found) then
        close l_check_navigation_csr;
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_CHANGE_DATA_TYPE');
          FND_MESSAGE.SET_TOKEN('FORM','AK_ATTRIBUTE_NAVIGATION', TRUE);
          FND_MSG_PUB.Add;
        end if;
        -- dbms_output.put_line(l_api_name || ' Cannot change data type');
        raise FND_API.G_EXC_ERROR;
      end if;
      close l_check_navigation_csr;

      /* see if there are any attribute values for this non-URL type */
      /* object attribute */
      open l_check_attr_value_csr;
      fetch l_check_attr_value_csr into l_dummy;
      if (l_check_attr_value_csr%found) then
        close l_check_attr_value_csr;
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_CHANGE_DATA_TYPE');
          FND_MESSAGE.SET_TOKEN('FORM','AK_ATTRIBUTE_VALUE', TRUE);
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
      close l_check_attr_value_csr;
    end if;
  end if;

  --
  -- Load record to be updated to the database
  -- - first load nullable columns
  --
  if (p_upper_case_flag <> FND_API.G_MISS_CHAR) or
     (p_upper_case_flag is null) then
    l_attributes_rec.upper_case_flag := p_upper_case_flag;
  end if;
  if (p_default_value_varchar2 <> FND_API.G_MISS_CHAR) or
     (p_default_value_varchar2 is null) then
    l_attributes_rec.default_value_varchar2 := p_default_value_varchar2;
  end if;
  if (p_default_value_number <> FND_API.G_MISS_NUM) or
     (p_default_value_number is null) then
    l_attributes_rec.default_value_number := p_default_value_number;
  end if;
  if (p_default_value_date <> FND_API.G_MISS_DATE) or
     (p_default_value_date is null) then
    l_attributes_rec.default_value_date := p_default_value_date;
  end if;
  if (p_lov_region_application_id <> FND_API.G_MISS_NUM) or
     (p_lov_region_application_id is null) then
    l_attributes_rec.lov_region_application_id := p_lov_region_application_id;
  end if;
  if (p_lov_region_code <> FND_API.G_MISS_CHAR) or
     (p_lov_region_code is null) then
    l_attributes_rec.lov_region_code := p_lov_region_code;
  end if;
  -- JSP new columns
  if (p_item_style <> FND_API.G_MISS_CHAR) and
     (p_item_style is not null) then
    l_attributes_rec.item_style := p_item_style;
  else
	l_attributes_rec.item_style := l_item_style;
  end if;
  if (p_display_height <> FND_API.G_MISS_NUM) or
     (p_display_height is null) then
    l_attributes_rec.display_height := p_display_height;
  end if;
  if (p_css_class_name <> FND_API.G_MISS_CHAR) or
     (p_css_class_name is null) then
    l_attributes_rec.css_class_name := p_css_class_name;
  end if;
  if (p_poplist_viewobject <> FND_API.G_MISS_CHAR) or
     (p_poplist_viewobject is null) then
    l_attributes_rec.poplist_viewobject := p_poplist_viewobject;
  end if;
  if (p_poplist_display_attr <> FND_API.G_MISS_CHAR) or
     (p_poplist_display_attr is null) then
    l_attributes_rec.poplist_display_attribute := p_poplist_display_attr;
  end if;
  if (p_poplist_value_attr <> FND_API.G_MISS_CHAR) or
     (p_poplist_value_attr is null) then
    l_attributes_rec.poplist_value_attribute := p_poplist_value_attr;
  end if;
  if (p_css_label_class_name <> FND_API.G_MISS_CHAR) or
     (p_css_label_class_name is null) then
    l_attributes_rec.css_label_class_name := p_css_label_class_name;
  end if;
  if (p_precision <> FND_API.G_MISS_NUM) or
     (p_precision is null) then
    l_attributes_rec.precision := p_precision;
  end if;
  if (p_expansion <> FND_API.G_MISS_NUM) or
     (p_expansion is null) then
    l_attributes_rec.expansion := p_expansion;
  end if;
  if (p_als_max_length <> FND_API.G_MISS_NUM) or
     (p_als_max_length is null) then
    l_attributes_rec.als_max_length := p_als_max_length;
  end if;

  if (p_attribute_category <> FND_API.G_MISS_CHAR) or
     (p_attribute_category is null) then
    l_attributes_rec.attribute_category := p_attribute_category;
  end if;
  if (p_attribute1 <> FND_API.G_MISS_CHAR) or
     (p_attribute1 is null) then
    l_attributes_rec.attribute1 := p_attribute1;
  end if;
  if (p_attribute2 <> FND_API.G_MISS_CHAR) or
     (p_attribute2 is null) then
    l_attributes_rec.attribute2 := p_attribute2;
  end if;
  if (p_attribute3 <> FND_API.G_MISS_CHAR) or
     (p_attribute3 is null) then
    l_attributes_rec.attribute3 := p_attribute3;
  end if;
  if (p_attribute4 <> FND_API.G_MISS_CHAR) or
     (p_attribute4 is null) then
    l_attributes_rec.attribute4 := p_attribute4;
  end if;
  if (p_attribute5 <> FND_API.G_MISS_CHAR) or
     (p_attribute5 is null) then
    l_attributes_rec.attribute5 := p_attribute5;
  end if;
  if (p_attribute6 <> FND_API.G_MISS_CHAR) or
     (p_attribute6 is null) then
    l_attributes_rec.attribute6 := p_attribute6;
  end if;
  if (p_attribute7 <> FND_API.G_MISS_CHAR) or
     (p_attribute7 is null) then
    l_attributes_rec.attribute7 := p_attribute7;
  end if;
  if (p_attribute8 <> FND_API.G_MISS_CHAR) or
     (p_attribute8 is null) then
    l_attributes_rec.attribute8 := p_attribute8;
  end if;
  if (p_attribute9 <> FND_API.G_MISS_CHAR) or
     (p_attribute9 is null) then
    l_attributes_rec.attribute9 := p_attribute9;
  end if;
  if (p_attribute10 <> FND_API.G_MISS_CHAR) or
     (p_attribute10 is null) then
    l_attributes_rec.attribute10 := p_attribute10;
  end if;
  if (p_attribute11 <> FND_API.G_MISS_CHAR) or
     (p_attribute11 is null) then
    l_attributes_rec.attribute11 := p_attribute11;
  end if;
  if (p_attribute12 <> FND_API.G_MISS_CHAR) or
     (p_attribute12 is null) then
    l_attributes_rec.attribute12 := p_attribute12;
  end if;
  if (p_attribute13 <> FND_API.G_MISS_CHAR) or
     (p_attribute13 is null) then
    l_attributes_rec.attribute13 := p_attribute13;
  end if;
  if (p_attribute14 <> FND_API.G_MISS_CHAR) or
     (p_attribute14 is null) then
    l_attributes_rec.attribute14 := p_attribute14;
  end if;
  if (p_attribute15 <> FND_API.G_MISS_CHAR) or
     (p_attribute15 is null) then
    l_attributes_rec.attribute15 := p_attribute15;
  end if;
  if (p_attribute_label_length <> FND_API.G_MISS_NUM) or
     (p_attribute_label_length is null) then
    l_attributes_rec.attribute_label_length := p_attribute_label_length;
  end if;
  if (p_attribute_value_length <> FND_API.G_MISS_NUM) or
     (p_attribute_value_length is null) then
    l_attributes_rec.attribute_value_length := p_attribute_value_length;
  end if;
  if (p_attribute_label_long <> FND_API.G_MISS_CHAR) or
     (p_attribute_label_long is null) then
    l_attributes_tl_rec.attribute_label_long := p_attribute_label_long;
  end if;
  if (p_attribute_label_short <> FND_API.G_MISS_CHAR) or
     (p_attribute_label_short is null) then
    l_attributes_tl_rec.attribute_label_short := p_attribute_label_short;
  end if;
  if (p_description <> FND_API.G_MISS_CHAR) or
     (p_description is null) then
    l_attributes_tl_rec.description := p_description;
  end if;

  --
  -- - next, load non-null columns
  --
  if (p_bold <> FND_API.G_MISS_CHAR) then
    l_attributes_rec.bold := p_bold;
  end if;
  if (p_italic <> FND_API.G_MISS_CHAR) then
    l_attributes_rec.italic := p_italic;
  end if;
  if (p_vertical_alignment <> FND_API.G_MISS_CHAR) then
    l_attributes_rec.vertical_alignment := p_vertical_alignment;
  end if;
  if (p_horizontal_alignment <> FND_API.G_MISS_CHAR) then
    l_attributes_rec.horizontal_alignment := p_horizontal_alignment;
  end if;
  if (p_data_type <> FND_API.G_MISS_CHAR) then
    l_attributes_rec.data_type := p_data_type;
  end if;
  if (p_name <> FND_API.G_MISS_CHAR) then
    l_attributes_tl_rec.name := p_name;
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

  if AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
       p_loader_timestamp => p_loader_timestamp,
       p_created_by => l_created_by,
       p_creation_date => l_creation_date,
       p_last_updated_by => l_last_updated_by,
       p_db_last_updated_by => l_attributes_rec.last_updated_by,
       p_last_update_date => l_last_update_date,
       p_db_last_update_date => l_attributes_rec.last_update_date,
       p_last_update_login => l_last_update_login,
       p_create_or_update => 'UPDATE') then

  update AK_ATTRIBUTES set
      ATTRIBUTE_LABEL_LENGTH = l_attributes_rec.attribute_label_length,
      ATTRIBUTE_VALUE_LENGTH = l_attributes_rec.attribute_value_length,
      BOLD = l_attributes_rec.bold,
      ITALIC = l_attributes_rec.italic,
      VERTICAL_ALIGNMENT = l_attributes_rec.vertical_alignment,
      HORIZONTAL_ALIGNMENT = l_attributes_rec.horizontal_alignment,
      DATA_TYPE = l_attributes_rec.data_type,
      UPPER_CASE_FLAG = l_attributes_rec.upper_case_flag,
      DEFAULT_VALUE_VARCHAR2 = l_attributes_rec.default_value_varchar2,
      DEFAULT_VALUE_NUMBER = l_attributes_rec.default_value_number,
      DEFAULT_VALUE_DATE = l_attributes_rec.default_value_date,
      LOV_REGION_APPLICATION_ID = l_attributes_rec.lov_region_application_id,
      LOV_REGION_CODE = l_attributes_rec.lov_region_code,
      ITEM_STYLE = l_attributes_rec.item_style,
      DISPLAY_HEIGHT = l_attributes_rec.display_height,
      CSS_CLASS_NAME = l_attributes_rec.css_class_name,
      POPLIST_VIEWOBJECT = l_attributes_rec.poplist_viewobject,
      POPLIST_DISPLAY_ATTRIBUTE = l_attributes_rec.poplist_display_attribute,
      POPLIST_VALUE_ATTRIBUTE = l_attributes_rec.poplist_value_attribute,
	  CSS_LABEL_CLASS_NAME = l_attributes_rec.css_label_class_name,
	  PRECISION = l_attributes_rec.precision,
	  EXPANSION = l_attributes_rec.expansion,
	  ALS_MAX_LENGTH = l_attributes_rec.als_max_length,
	  ATTRIBUTE_CATEGORY = l_attributes_rec.attribute_category,
	  ATTRIBUTE1 = l_attributes_rec.attribute1,
	  ATTRIBUTE2 = l_attributes_rec.attribute2,
	  ATTRIBUTE3 = l_attributes_rec.attribute3,
	  ATTRIBUTE4 = l_attributes_rec.attribute4,
	  ATTRIBUTE5 = l_attributes_rec.attribute5,
	  ATTRIBUTE6 = l_attributes_rec.attribute6,
	  ATTRIBUTE7 = l_attributes_rec.attribute7,
	  ATTRIBUTE8 = l_attributes_rec.attribute8,
	  ATTRIBUTE9 = l_attributes_rec.attribute9,
	  ATTRIBUTE10 = l_attributes_rec.attribute10,
	  ATTRIBUTE11 = l_attributes_rec.attribute11,
	  ATTRIBUTE12 = l_attributes_rec.attribute12,
	  ATTRIBUTE13 = l_attributes_rec.attribute13,
	  ATTRIBUTE14 = l_attributes_rec.attribute14,
	  ATTRIBUTE15 = l_attributes_rec.attribute15,
      LAST_UPDATE_DATE = l_last_update_date,
      LAST_UPDATED_BY = l_last_updated_by,
      LAST_UPDATE_LOGIN = l_last_update_login
  where attribute_application_id = p_attribute_application_id
  and   attribute_code = p_attribute_code;
  if (sql%notfound) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_ATTRIBUTE_UPDATE_FAILED');
      FND_MSG_PUB.Add;
    end if;
    raise FND_API.G_EXC_ERROR;
  end if;

  update AK_ATTRIBUTES_TL set
      NAME = l_attributes_tl_rec.name,
      ATTRIBUTE_LABEL_LONG = l_attributes_tl_rec.attribute_label_long,
      ATTRIBUTE_LABEL_SHORT = l_attributes_tl_rec.attribute_label_short,
      DESCRIPTION = l_attributes_tl_rec.description,
      LAST_UPDATED_BY = l_last_updated_by,
      LAST_UPDATE_DATE = l_last_update_date,
      LAST_UPDATE_LOGIN = l_last_update_login,
	  SOURCE_LANG = l_lang
  where attribute_application_id = p_attribute_application_id
  and   attribute_code = p_attribute_code
  and   l_lang in (LANGUAGE, SOURCE_LANG);
  if (sql%notfound) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_ATTRIBUTE_UPDATE_FAILED');
      FND_MSG_PUB.Add;
    end if;
    -- dbms_output.put_line('TL Row does not exist during update');
    raise FND_API.G_EXC_ERROR;
  end if;

--  /** commit the update **/
  commit;

  if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
    FND_MESSAGE.SET_NAME('AK','AK_ATTRIBUTE_UPDATED');
    FND_MESSAGE.SET_TOKEN('KEY',to_char(p_attribute_application_id) ||
                                ' ' || p_attribute_code);
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
      FND_MESSAGE.SET_NAME('AK','AK_ATTRIBUTE_VALUE_ERROR');
      FND_MESSAGE.SET_TOKEN('KEY',to_char(p_attribute_application_id) ||
                                  ' ' || p_attribute_code);
      FND_MSG_PUB.Add;
      FND_MESSAGE.SET_NAME('AK','AK_ATTRIBUTE_NOT_UPDATED');
      FND_MESSAGE.SET_TOKEN('KEY',to_char(p_attribute_application_id) ||
                                ' ' || p_attribute_code);
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
    rollback to start_update_attribute;
    FND_MSG_PUB.Count_And_Get (
	p_count => p_msg_count,
	p_data => p_msg_data);
  WHEN FND_API.G_EXC_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_ATTRIBUTE_NOT_UPDATED');
      FND_MESSAGE.SET_TOKEN('KEY',to_char(p_attribute_application_id) ||
                                ' ' || p_attribute_code);
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
    rollback to start_update_attribute;
    FND_MSG_PUB.Count_And_Get (
	p_count => p_msg_count,
	p_data => p_msg_data);
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    rollback to start_update_attribute;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Count_And_Get (
	p_count => p_msg_count,
	p_data => p_msg_data);
end UPDATE_ATTRIBUTE;

--=======================================================
--  Procedure   UPLOAD_ATTRIBUTE_SECOND
--
--  Usage       Private API for loading attributes that were
--              failed during its first pass
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API reads the attribute data from PL/SQL table
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
procedure UPLOAD_ATTRIBUTE_SECOND (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
  p_pass                     IN      NUMBER := 2
) is
  l_api_name                 CONSTANT varchar2(30) := 'Upload_Attribute_Second';
  l_rec_index                NUMBER;
  l_return_status            VARCHAR2(1);
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(240);
  l_copy_redo_flag           BOOLEAN;
begin
  if (G_ATTRIBUTE_REDO_TBL.count > 0) then
    for l_rec_index in G_ATTRIBUTE_REDO_TBL.FIRST .. G_ATTRIBUTE_REDO_TBL.LAST loop
      if (G_ATTRIBUTE_REDO_TBL.exists(l_rec_index)) then
        if AK_ATTRIBUTE_PVT.ATTRIBUTE_EXISTS (
          p_api_version_number => 1.0,
          p_return_status => l_return_status,
          p_attribute_application_id=>
                     G_ATTRIBUTE_REDO_TBL(l_rec_index).attribute_application_id,
          p_attribute_code => G_ATTRIBUTE_REDO_TBL(l_rec_index).attribute_code) then
            AK_ATTRIBUTE_PVT.UPDATE_ATTRIBUTE (
              p_validation_level => p_validation_level,
	          p_api_version_number => 1.0,
              p_msg_count => l_msg_count,
              p_msg_data => l_msg_data,
              p_return_status => l_return_status,
	          p_attribute_application_id =>
                               G_ATTRIBUTE_REDO_TBL(l_rec_index).attribute_application_id,
              p_attribute_code => G_ATTRIBUTE_REDO_TBL(l_rec_index).attribute_code,
	          p_attribute_label_length => G_ATTRIBUTE_REDO_TBL(l_rec_index).attribute_label_length,
	          p_attribute_value_length => G_ATTRIBUTE_REDO_TBL(l_rec_index).attribute_value_length,
	          p_bold => G_ATTRIBUTE_REDO_TBL(l_rec_index).bold,
	          p_italic => G_ATTRIBUTE_REDO_TBL(l_rec_index).italic,
	          p_vertical_alignment => G_ATTRIBUTE_REDO_TBL(l_rec_index).vertical_alignment,
	          p_horizontal_alignment => G_ATTRIBUTE_REDO_TBL(l_rec_index).horizontal_alignment,
	          p_data_type => G_ATTRIBUTE_REDO_TBL(l_rec_index).data_type,
	          p_upper_case_flag => G_ATTRIBUTE_REDO_TBL(l_rec_index).upper_case_flag,
              p_default_value_varchar2 => G_ATTRIBUTE_REDO_TBL(l_rec_index).default_value_varchar2,
              p_default_value_number => G_ATTRIBUTE_REDO_TBL(l_rec_index).default_value_number,
              p_default_value_date => G_ATTRIBUTE_REDO_TBL(l_rec_index).default_value_date,
              p_lov_region_application_id =>
                                    G_ATTRIBUTE_REDO_TBL(l_rec_index).lov_region_application_id,
              p_lov_region_code => G_ATTRIBUTE_REDO_TBL(l_rec_index).lov_region_code,
              p_item_style => G_ATTRIBUTE_REDO_TBL(l_rec_index).item_style,
              p_display_height => G_ATTRIBUTE_REDO_TBL(l_rec_index).display_height,
              p_css_class_name => G_ATTRIBUTE_REDO_TBL(l_rec_index).css_class_name,
              p_poplist_viewobject => G_ATTRIBUTE_REDO_TBL(l_rec_index).poplist_viewobject,
              p_poplist_display_attr => G_ATTRIBUTE_REDO_TBL(l_rec_index).poplist_display_attribute,
              p_poplist_value_attr => G_ATTRIBUTE_REDO_TBL(l_rec_index).poplist_value_attribute,
              p_css_label_class_name => G_ATTRIBUTE_REDO_TBL(l_rec_index).css_label_class_name,
	      p_precision => G_ATTRIBUTE_REDO_TBL(l_rec_index).precision,
	      p_expansion => G_ATTRIBUTE_REDO_TBL(l_rec_index).expansion,
	      p_als_max_length => G_ATTRIBUTE_REDO_TBL(l_rec_index).als_max_length,
              p_attribute_category => G_ATTRIBUTE_REDO_TBL(l_rec_index).attribute_category,
			  p_attribute1 => G_ATTRIBUTE_REDO_TBL(l_rec_index).attribute1,
			  p_attribute2 => G_ATTRIBUTE_REDO_TBL(l_rec_index).attribute2,
			  p_attribute3 => G_ATTRIBUTE_REDO_TBL(l_rec_index).attribute3,
			  p_attribute4 => G_ATTRIBUTE_REDO_TBL(l_rec_index).attribute4,
			  p_attribute5 => G_ATTRIBUTE_REDO_TBL(l_rec_index).attribute5,
			  p_attribute6 => G_ATTRIBUTE_REDO_TBL(l_rec_index).attribute6,
			  p_attribute7 => G_ATTRIBUTE_REDO_TBL(l_rec_index).attribute7,
			  p_attribute8 => G_ATTRIBUTE_REDO_TBL(l_rec_index).attribute8,
			  p_attribute9 => G_ATTRIBUTE_REDO_TBL(l_rec_index).attribute9,
			  p_attribute10 => G_ATTRIBUTE_REDO_TBL(l_rec_index).attribute10,
			  p_attribute11 => G_ATTRIBUTE_REDO_TBL(l_rec_index).attribute11,
			  p_attribute12 => G_ATTRIBUTE_REDO_TBL(l_rec_index).attribute12,
			  p_attribute13 => G_ATTRIBUTE_REDO_TBL(l_rec_index).attribute13,
			  p_attribute14 => G_ATTRIBUTE_REDO_TBL(l_rec_index).attribute14,
			  p_attribute15 => G_ATTRIBUTE_REDO_TBL(l_rec_index).attribute15,
	          p_name => G_ATTRIBUTE_TL_REDO_TBL(l_rec_index).name,
              p_attribute_label_long => G_ATTRIBUTE_TL_REDO_TBL(l_rec_index).attribute_label_long,
	          p_attribute_label_short => G_ATTRIBUTE_TL_REDO_TBL(l_rec_index).attribute_label_short,
	          p_description => G_ATTRIBUTE_TL_REDO_TBL(l_rec_index).description,
		p_created_by => G_ATTRIBUTE_REDO_TBL(l_rec_index).created_by,
		p_creation_date => G_ATTRIBUTE_REDO_TBL(l_rec_index).creation_date,
		p_last_updated_by => G_ATTRIBUTE_REDO_TBL(l_rec_index).last_updated_by,
		p_last_update_date => G_ATTRIBUTE_REDO_TBL(l_rec_index).last_update_date,
		p_last_update_login => G_ATTRIBUTE_REDO_TBL(l_rec_index).last_update_login,
	          p_loader_timestamp => p_loader_timestamp,
		      p_pass => p_pass,
              p_copy_redo_flag => l_copy_redo_flag
              );
        else
          AK_ATTRIBUTE_PVT.CREATE_ATTRIBUTE (
	        p_validation_level => p_validation_level,
	        p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
	        p_attribute_application_id =>
                                   G_ATTRIBUTE_REDO_TBL(l_rec_index).attribute_application_id,
	        p_attribute_code => G_ATTRIBUTE_REDO_TBL(l_rec_index).attribute_code,
	        p_attribute_label_length => G_ATTRIBUTE_REDO_TBL(l_rec_index).attribute_label_length,
	        p_attribute_value_length => G_ATTRIBUTE_REDO_TBL(l_rec_index).attribute_value_length,
	        p_bold => G_ATTRIBUTE_REDO_TBL(l_rec_index).bold,
	        p_italic => G_ATTRIBUTE_REDO_TBL(l_rec_index).italic,
	        p_vertical_alignment => G_ATTRIBUTE_REDO_TBL(l_rec_index).vertical_alignment,
	        p_horizontal_alignment => G_ATTRIBUTE_REDO_TBL(l_rec_index).horizontal_alignment,
	        p_data_type => G_ATTRIBUTE_REDO_TBL(l_rec_index).data_type,
	        p_upper_case_flag => G_ATTRIBUTE_REDO_TBL(l_rec_index).upper_case_flag,
            p_default_value_varchar2 => G_ATTRIBUTE_REDO_TBL(l_rec_index).default_value_varchar2,
            p_default_value_number => G_ATTRIBUTE_REDO_TBL(l_rec_index).default_value_number,
            p_default_value_date => G_ATTRIBUTE_REDO_TBL(l_rec_index).default_value_date,
            p_lov_region_application_id =>
                                    G_ATTRIBUTE_REDO_TBL(l_rec_index).lov_region_application_id,
            p_lov_region_code => G_ATTRIBUTE_REDO_TBL(l_rec_index).lov_region_code,
			p_item_style => G_ATTRIBUTE_REDO_TBL(l_rec_index).item_style,
			p_display_height => G_ATTRIBUTE_REDO_TBL(l_rec_index).display_height,
			p_css_class_name => G_ATTRIBUTE_REDO_TBL(l_rec_index).css_class_name,
			p_poplist_viewobject => G_ATTRIBUTE_REDO_TBL(l_rec_index).poplist_viewobject,
			p_poplist_display_attr => G_ATTRIBUTE_REDO_TBL(l_rec_index).poplist_display_attribute,
			p_poplist_value_attr => G_ATTRIBUTE_REDO_TBL(l_rec_index).poplist_value_attribute,
			p_css_label_class_name => G_ATTRIBUTE_REDO_TBL(l_rec_index).css_label_class_name,
			p_precision => G_ATTRIBUTE_REDO_TBL(l_rec_index).precision,
			p_expansion => G_ATTRIBUTE_REDO_TBL(l_rec_index).expansion,
			p_als_max_length => G_ATTRIBUTE_REDO_TBL(l_rec_index).als_max_length,
			p_attribute1 => G_ATTRIBUTE_REDO_TBL(l_rec_index).attribute1,
			p_attribute2 => G_ATTRIBUTE_REDO_TBL(l_rec_index).attribute2,
			p_attribute3 => G_ATTRIBUTE_REDO_TBL(l_rec_index).attribute3,
			p_attribute4 => G_ATTRIBUTE_REDO_TBL(l_rec_index).attribute4,
			p_attribute5 => G_ATTRIBUTE_REDO_TBL(l_rec_index).attribute5,
			p_attribute6 => G_ATTRIBUTE_REDO_TBL(l_rec_index).attribute6,
			p_attribute7 => G_ATTRIBUTE_REDO_TBL(l_rec_index).attribute7,
			p_attribute8 => G_ATTRIBUTE_REDO_TBL(l_rec_index).attribute8,
			p_attribute9 => G_ATTRIBUTE_REDO_TBL(l_rec_index).attribute9,
			p_attribute10 => G_ATTRIBUTE_REDO_TBL(l_rec_index).attribute10,
			p_attribute11 => G_ATTRIBUTE_REDO_TBL(l_rec_index).attribute11,
			p_attribute12 => G_ATTRIBUTE_REDO_TBL(l_rec_index).attribute12,
			p_attribute13 => G_ATTRIBUTE_REDO_TBL(l_rec_index).attribute13,
			p_attribute14 => G_ATTRIBUTE_REDO_TBL(l_rec_index).attribute14,
			p_attribute15 => G_ATTRIBUTE_REDO_TBL(l_rec_index).attribute15,
	        p_name => G_ATTRIBUTE_TL_REDO_TBL(l_rec_index).name,
            p_attribute_label_long => G_ATTRIBUTE_TL_REDO_TBL(l_rec_index).attribute_label_long,
	        p_attribute_label_short =>G_ATTRIBUTE_TL_REDO_TBL(l_rec_index).attribute_label_short,
	        p_description => G_ATTRIBUTE_TL_REDO_TBL(l_rec_index).description,
		p_created_by => G_ATTRIBUTE_REDO_TBL(l_rec_index).created_by,
		p_creation_date => G_ATTRIBUTE_REDO_TBL(l_rec_index).creation_date,
		p_last_updated_by => G_ATTRIBUTE_REDO_TBL(l_rec_index).last_updated_by,
		p_last_update_date => G_ATTRIBUTE_REDO_TBL(l_rec_index).last_update_date,
		p_last_update_login => G_ATTRIBUTE_REDO_TBL(l_rec_index).last_update_login,
	        p_loader_timestamp => p_loader_timestamp,
		    p_pass => p_pass,
            p_copy_redo_flag => l_copy_redo_flag
          );
        end if; -- /* if ATTRIBUTE_EXISTS */
        --
        -- If API call returns with an error status, upload aborts
        if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
        (l_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        end if; -- /* if l_return_status */
	  end if; -- /* if G_ATTRIBUTE_REDO_TBL.exists */
    end loop; --/* for loop */
  end if; -- /* if G_ATTRIBUTE_REDO_TBL.count */

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

end UPLOAD_ATTRIBUTE_SECOND;

end AK_Attribute_pvt;

/
