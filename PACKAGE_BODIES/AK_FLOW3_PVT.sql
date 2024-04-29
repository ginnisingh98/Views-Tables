--------------------------------------------------------
--  DDL for Package Body AK_FLOW3_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AK_FLOW3_PVT" as
/* $Header: akdvfl3b.pls 120.3 2005/09/15 22:49:53 tshort ship $ */

--
-- global constants
--
-- These values are used as the page and region codes to
-- indicate that there is no primary page or region assigned.
-- These values should be consistent to the ones used in Forms.
--
G_NO_PRIMARY_PAGE_CODE     CONSTANT    VARCHAR2(30) := '-1';
G_NO_PRIMARY_REGION_CODE   CONSTANT    VARCHAR2(30) := '-1';

--=======================================================
--  Function    VALIDATE_FLOW
--
--  Usage       Private API for validating a flow. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Perform validation on a flow record.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              In addition, this function returns TRUE if all
--              validation tests are passed, or FALSE otherwise.
--  Parameters  Flow columns
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
function VALIDATE_FLOW (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_return_status            OUT NOCOPY    VARCHAR2,
  p_flow_application_id      IN      NUMBER := FND_API.G_MISS_NUM,
  p_flow_code                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_primary_page_appl_id     IN      NUMBER := FND_API.G_MISS_NUM,
  p_primary_page_code        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_name                     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_description              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_caller                   IN      VARCHAR2,
  p_pass                     IN      NUMBER := 2
) return BOOLEAN is
  cursor l_check_no_page_csr is
  select 1
  from   AK_FLOW_PAGES
  where  flow_application_id = p_flow_application_id
  and    flow_code = p_flow_code;
  l_api_version_number      CONSTANT number := 1.0;
  l_api_name                CONSTANT varchar2(30) := 'Validate_Flow';
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
  if ((p_flow_application_id is null) or
      (p_flow_application_id = FND_API.G_MISS_NUM)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'FLOW_APPLICATION_ID');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_flow_code is null) or
      (p_flow_code = FND_API.G_MISS_CHAR)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'FLOW_CODE');
      FND_MSG_PUB.Add;
    end if;
  end if;

  --** check that required columns are not null and, unless calling  **
  --** from UPDATE procedure, the columns are not missing            **
  if ((p_primary_page_appl_id is null) or
      (p_primary_page_appl_id = FND_API.G_MISS_NUM and
       p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'PRIMARY_PAGE_APPL_ID');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_primary_page_code is null) or
      (p_primary_page_code = FND_API.G_MISS_CHAR and
       p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'PRIMARY_PAGE_CODE');
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


  -- === Validate columns ===
  --
  --  primary_page_appl_id and primary_page_code
  --
  --   Check that the primary page exists, or if the primary page code
  --   is G_NO_PRIMARY_PAGE_CODE (as in the case when a flow is created
  --   and before any pages have been added for that flow),
  --   check that no pages exist for the flow.
  --
  if (p_primary_page_appl_id <> FND_API.G_MISS_NUM) and
     (p_primary_page_code <> FND_API.G_MISS_CHAR) then
    if (p_primary_page_code = G_NO_PRIMARY_PAGE_CODE) then
      open l_check_no_page_csr;
      fetch l_check_no_page_csr into l_dummy;
      if (l_check_no_page_csr%found) then
       l_error := TRUE;
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
          FND_MESSAGE.SET_NAME('AK','NO_FLOW_DEFAULT_PAGE');
          FND_MSG_PUB.Add;
        end if;
      end if; /* if l_check_no_page_found */
      close l_check_no_page_csr;
    else
      -- do not check references if inserting records
      --
      if NOT AK_FLOW_PVT.PAGE_EXISTS (
          p_api_version_number => 1.0,
          p_return_status => l_return_status,
          p_flow_application_id => p_flow_application_id,
          p_flow_code => p_flow_code,
          p_page_application_id => p_primary_page_appl_id,
          p_page_code => p_primary_page_code) then
        l_error := TRUE;
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
          FND_MESSAGE.SET_NAME('AK','AK_INVALID_FLOW_PG_REFERENCE');
          FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
                         ' ' || p_flow_code ||
                         ' ' || to_char(p_primary_page_appl_id) ||
                         ' ' || p_primary_page_code);
          FND_MSG_PUB.Add;
        end if;
      end if; /* if PAGE_EXISTS */
    end if; -- /* if p_primary_page_code */
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
end VALIDATE_FLOW;

--=======================================================
--  Function    VALIDATE_PAGE
--
--  Usage       Private API for validating a flow page. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Perform validation on a flow page record.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              In addition, this function returns TRUE if all
--              validation tests are passed, or FALSE otherwise.
--  Parameters  Flow Page columns
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
function VALIDATE_PAGE (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_return_status            OUT NOCOPY    VARCHAR2,
  p_flow_application_id      IN      NUMBER := FND_API.G_MISS_NUM,
  p_flow_code                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_page_application_id      IN      NUMBER := FND_API.G_MISS_NUM,
  p_page_code                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_primary_region_appl_id   IN      NUMBER := FND_API.G_MISS_NUM,
  p_primary_region_code      IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_name                     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_description              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_caller                   IN      VARCHAR2,
  p_pass                     IN      NUMBER := 2
) return BOOLEAN is
  cursor l_check_no_region_csr is
  select 1
  from   AK_FLOW_PAGE_REGIONS
  where  flow_application_id = p_flow_application_id
  and    flow_code = p_flow_code
  and    page_application_id = p_page_application_id
  and    page_code = p_page_code;
  l_api_version_number CONSTANT number := 1.0;
  l_api_name           CONSTANT varchar2(30) := 'Validate_Page';
  l_dummy              NUMBER;
  l_error              BOOLEAN;
  l_return_status      varchar2(1);
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
  if ((p_flow_application_id is null) or
      (p_flow_application_id = FND_API.G_MISS_NUM)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'FLOW_APPLICATION_ID');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_flow_code is null) or
      (p_flow_code = FND_API.G_MISS_CHAR)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'FLOW_CODE');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_page_application_id is null) or
      (p_page_application_id = FND_API.G_MISS_NUM)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'PAGE_APPLICATION_ID');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_page_code is null) or
      (p_page_code = FND_API.G_MISS_CHAR)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'PAGE_CODE');
      FND_MSG_PUB.Add;
    end if;
  end if;

  --
  -- Check that the parent flow exists
  --
  if (NOT AK_FLOW_PVT.FLOW_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_flow_application_id => p_flow_application_id,
            p_flow_code => p_flow_code) ) then
      l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_INVALID_FLOW_REFERENCE');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
                           ' ' || p_flow_code );
      FND_MSG_PUB.Add;
    end if;
    --dbms_output.put_line('Parent flow does not exist!');
  end if;

  --** check that required columns are not null and, unless calling  **
  --** from UPDATE procedure, the columns are not missing            **
  if ((p_primary_region_appl_id is null) or
      (p_primary_region_appl_id = FND_API.G_MISS_NUM and
       p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'PRIMARY_REGION_APPL_ID');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_primary_region_code is null) or
      (p_primary_region_code = FND_API.G_MISS_CHAR and
       p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'PRIMARY_REGION_CODE');
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

  --** Validate columns **
  --
  --  primary_region_appl_id and primary_region_code
  --
  --   Check that the primary region exists, or if the primary region code
  --   is G_NO_PRIMARY_REGION_CODE (as in the case when a page is created
  --   and before any regions have been added for that flow),
  --   check that no regions exist for the flow page.
  --
  if (p_primary_region_appl_id <> FND_API.G_MISS_NUM) and
     (p_primary_region_code <> FND_API.G_MISS_CHAR) then
    if (p_primary_region_code = G_NO_PRIMARY_REGION_CODE) then
      open l_check_no_region_csr;
      fetch l_check_no_region_csr into l_dummy;
      if (l_check_no_region_csr%found) then
        l_error := TRUE;
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
          FND_MESSAGE.SET_NAME('AK','NO_PAGE_ROOT_REGION');
          FND_MSG_PUB.Add;
        end if;
      end if; /* if l_check_no_region_csr%found */
      close l_check_no_region_csr;
    else
      if NOT AK_FLOW_PVT.PAGE_REGION_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_flow_application_id => p_flow_application_id,
            p_flow_code => p_flow_code,
            p_page_application_id => p_page_application_id,
            p_page_code => p_page_code,
            p_region_application_id => p_primary_region_appl_id,
            p_region_code => p_primary_region_code) then
        l_error := TRUE;
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
          FND_MESSAGE.SET_NAME('AK','AK_INVALID_PG_REGION_REFERENCE');
          FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
                         ' ' || p_flow_code ||
                         ' ' || to_char(p_page_application_id) ||
                         ' ' || p_page_code ||
                         ' ' || to_char(p_primary_region_appl_id) ||
                         ' ' || p_primary_region_code);
          FND_MSG_PUB.Add;
        end if;
      end if; /* if PAGE_REGION_EXISTS */
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

end VALIDATE_PAGE;

--=======================================================
--  Function    VALIDATE_PAGE_REGION
--
--  Usage       Private API for validating a flow page region. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Perform validation on a flow page region record.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              In addition, this function returns TRUE if all
--              validation tests are passed, or FALSE otherwise.
--  Parameters  Flow Page Region columns
--              p_foreign_key_name : IN optional
--                  The foreign key name used in the flow region
--                  relation record connecting this flow page region
--                  and its parent region, if there is one.
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
function VALIDATE_PAGE_REGION (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_return_status            OUT NOCOPY    VARCHAR2,
  p_flow_application_id      IN      NUMBER := FND_API.G_MISS_NUM,
  p_flow_code                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_page_application_id      IN      NUMBER := FND_API.G_MISS_NUM,
  p_page_code                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_region_application_id    IN      NUMBER := FND_API.G_MISS_NUM,
  p_region_code              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_display_sequence         IN      NUMBER := FND_API.G_MISS_NUM,
  p_region_style             IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_num_columns              IN      NUMBER := FND_API.G_MISS_NUM,
  p_icx_custom_call          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_parent_region_application_id IN  NUMBER := FND_API.G_MISS_NUM,
  p_parent_region_code       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_foreign_key_name         IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_set_primary_region       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_caller                   IN      VARCHAR2,
  p_pass                     IN      NUMBER := 2
) return BOOLEAN is
  cursor l_check_seq_csr is
    select 1
    from   AK_FLOW_PAGE_REGIONS
    where  flow_application_id = p_flow_application_id
    and    flow_code = p_flow_code
    and    page_application_id = p_page_application_id
    and    page_code = p_page_code
    and    display_sequence = p_display_sequence
    and    ( (region_application_id <> p_region_application_id) or
             (region_code <> p_region_code) );
  cursor l_get_primary_region_csr is
    select primary_region_appl_id, primary_region_code
    from   AK_FLOW_PAGES
    where  flow_application_id = p_flow_application_id
    and    flow_code = p_flow_code
    and    page_application_id = p_page_application_id
    and    page_code = p_page_code;
  l_api_version_number     CONSTANT number := 1.0;
  l_api_name               CONSTANT varchar2(30) := 'Validate_Page_Region';
  l_dummy                  NUMBER;
  l_error                  BOOLEAN;
  l_primary_region_appl_id NUMBER;
  l_primary_region_code    VARCHAR2(30);
  l_return_status          varchar2(1);
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
  if ((p_flow_application_id is null) or
      (p_flow_application_id = FND_API.G_MISS_NUM)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'FLOW_APPLICATION_ID');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_flow_code is null) or
      (p_flow_code = FND_API.G_MISS_CHAR)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'FLOW_CODE');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_page_application_id is null) or
      (p_page_application_id = FND_API.G_MISS_NUM)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'PAGE_APPLICATION_ID');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_page_code is null) or
      (p_page_code = FND_API.G_MISS_CHAR)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'PAGE_CODE');
      FND_MSG_PUB.Add;
    end if;
  end if;

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

  --
  -- Check that the parent flow page exists
  --
  if (NOT AK_FLOW_PVT.PAGE_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_flow_application_id => p_flow_application_id,
            p_flow_code => p_flow_code,
            p_page_application_id => p_page_application_id,
            p_page_code => p_page_code) ) then
      l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_INVALID_FLOW_PG_REFERENCE');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
                           ' ' || p_flow_code ||
                           ' ' || to_char(p_page_application_id) ||
                           ' ' || p_page_code);
      FND_MSG_PUB.Add;
    end if;
  end if;

  --
  -- Check that the region exists in AK_REGIONS
  --
  if (NOT AK_REGION_PVT.REGION_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_region_application_id => p_region_application_id,
            p_region_code => p_region_code) ) then
      l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_INVALID_REGION_REFERENCE');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
                           ' ' || p_region_code);
      FND_MSG_PUB.Add;
    end if;
  end if;

  --
  --** check that required columns are not null and, unless calling  **
  --** from UPDATE procedure, the columns are not missing            **
  --
  if (p_region_style is null) or
     ((p_region_style = FND_API.G_MISS_CHAR) and
      (p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'REGION_STYLE');
      FND_MSG_PUB.Add;
    end if;
  end if;

  --** Validate columns **
  -- - Region style
  if (p_region_style <> FND_API.G_MISS_CHAR) then
    if (NOT AK_ON_OBJECTS_PVT.VALID_LOOKUP_CODE (
                p_api_version_number => 1.0,
                p_return_status => l_return_status,
                p_lookup_type => 'REGION_STYLE',
                p_lookup_code => p_region_style)) then
      l_error := TRUE;
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
        FND_MESSAGE.SET_NAME('AK','AK_INVALID_COLUMN_VALUE');
        FND_MESSAGE.SET_TOKEN('COLUMN','REGION_STYLE');
        FND_MSG_PUB.Add;
      end if;
      --dbms_output.put_line(l_api_name || ' Invalid region style');
    end if;
  end if;

  --
  --  - Display sequence (must be unique within page)
  --
  if (p_display_sequence <> FND_API.G_MISS_NUM) and
     (p_display_sequence is not null) then
    open l_check_seq_csr;
    fetch l_check_seq_csr into l_dummy;
    if (l_check_seq_csr%found) then
      l_error := TRUE;
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
        FND_MESSAGE.SET_NAME('AK','AK_UNIQUE_DISPLAY_SEQUENCE');
        FND_MSG_PUB.Add;
      end if;
    end if;
    close l_check_seq_csr;
  end if;

  --
  --  - Checks for parent_region_application_id and parent_region_code
  --    (do not perform check if both parms are missing or null)
  --
  if ( ( (p_parent_region_application_id <> FND_API.G_MISS_NUM) and
         (p_parent_region_application_id is not null) )
        or
       ( (p_parent_region_code <> FND_API.G_MISS_CHAR) and
         (p_parent_region_code is not null) )  )then
    -- dbms_output.put_line('parent region in validate_page_region = '||to_char(p_parent_region_application_id)
	--                     ||' '||p_parent_region_code);
    --
    -- 1. the current region must not be the primary region for the page
    --
    open l_get_primary_region_csr;
    fetch l_get_primary_region_csr into l_primary_region_appl_id,
                                        l_primary_region_code;
    if (l_get_primary_region_csr%found) then
      if ( (l_primary_region_appl_id = p_region_application_id) and
           (l_primary_region_code = p_region_code) ) or
         (p_set_primary_region = 'Y') then
        l_error := TRUE;
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
          FND_MESSAGE.SET_NAME('AK','AK_PARENT_REGION_DISALLOWED');
          FND_MSG_PUB.Add;
        end if;
      end if;
    end if;
    close l_get_primary_region_csr;
    --
    -- 2. the parent region must not be the same region as the current
    --    region
    --
    if (p_parent_region_application_id = p_region_application_id) and
       (p_parent_region_code = p_region_code) then
      l_error := TRUE;
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
        FND_MESSAGE.SET_NAME('AK','EC_DISTINCT_REGIONS');
        FND_MSG_PUB.Add;
      end if;
    end if;

    --
    -- 3. the parent region must exist
    --
    if NOT AK_FLOW_PVT.PAGE_REGION_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_flow_application_id => p_flow_application_id,
            p_flow_code => p_flow_code,
            p_page_application_id => p_page_application_id,
            p_page_code => p_page_code,
            p_region_application_id => p_parent_region_application_id,
            p_region_code => p_parent_region_code) then
        l_error := TRUE;
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
          FND_MESSAGE.SET_NAME('AK','AK_INVALID_PG_REGION_REFERENCE');
          FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
                         ' ' || p_flow_code ||
                         ' ' || to_char(p_page_application_id) ||
                         ' ' || p_page_code ||
                         ' ' || to_char(p_parent_region_application_id) ||
                         ' ' || p_parent_region_code);
          FND_MSG_PUB.Add;
        end if;
    end if; /* if PAGE_REGION_EXISTS */
    --
    -- 4. if the foreign key name is missing (or null), and the
    --    current action is to create a new page region, check
    --    that an intrapage relation connecting the current region and
    --    its parent region exists.
    --
    --    if the current action is to download a page region, the
    --    foreign key name cannot be missing.
    --
    if ( (p_foreign_key_name = FND_API.G_MISS_CHAR) or
         (p_foreign_key_name is null) ) then
		 -- dbms_output.put_line('p_foreign_key_name is null: '||p_flow_code||' '||p_page_code||' '||
		 --                     p_parent_region_code);
       if (p_caller <> AK_ON_OBJECTS_PVT.G_DOWNLOAD) then
	     -- dbms_output.put_line('p_caller = '||p_caller||' p_pass = '||to_char(p_pass));
          if NOT AK_FLOW_PVT.REGION_RELATION_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_flow_application_id => p_flow_application_id,
            p_flow_code => p_flow_code,
            p_foreign_key_name => p_foreign_key_name,
            p_from_page_appl_id => p_page_application_id,
            p_from_page_code => p_page_code,
            p_from_region_appl_id => p_parent_region_application_id,
            p_from_region_code => p_parent_region_code,
            p_to_page_appl_id => p_page_application_id,
            p_to_page_code => p_page_code,
            p_to_region_appl_id => p_region_application_id,
            p_to_region_code => p_region_code) then
            l_error := TRUE;
            if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
              FND_MESSAGE.SET_NAME('AK','AK_NO_INTRAPAGE_RELATION');
              FND_MSG_PUB.Add;
              FND_MESSAGE.SET_NAME('AK','AK_INVALID_RELATION_REFERENCE');
              FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
                         ' ' || p_flow_code ||
					   ' ' || p_foreign_key_name ||
                         ' ' || to_char(p_page_application_id) ||
                         ' ' || p_page_code ||
                         ' ' || to_char(p_parent_region_application_id) ||
                         ' ' || p_parent_region_code ||
                         ' ' || p_region_code);
              FND_MSG_PUB.Add;
            end if;
          end if;  /* if not region_relation_exists */
       elsif (p_caller = AK_ON_OBJECTS_PVT.G_DOWNLOAD) then
		l_error := TRUE;
          if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
            FND_MESSAGE.SET_NAME('AK','AK_NO_INTRAPAGE_RELATION');
            FND_MSG_PUB.Add;
            FND_MESSAGE.SET_NAME('AK','AK_INVALID_RELATION_REFERENCE');
            FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
                         ' ' || p_flow_code ||
					   ' ' || p_foreign_key_name ||
                         ' ' || to_char(p_page_application_id) ||
                         ' ' || p_page_code ||
                         ' ' || to_char(p_parent_region_application_id) ||
                         ' ' || p_parent_region_code ||
                         ' ' || p_region_code);
            FND_MSG_PUB.Add;
          end if;
       end if; /* if caller is create */
    end if; /* if p_foreign_key_name is null or missing */
  end if; /* p_parent_region_application_id */
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

end VALIDATE_PAGE_REGION;

--=======================================================
--  Function    VALIDATE_PAGE_REGION_ITEM
--
--  Usage       Private API for validating a flow page region item.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Perform validation on a flow page region item record.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              In addition, this function returns TRUE if all
--              validation tests are passed, or FALSE otherwise.
--  Parameters  Flow Page Region Item columns
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
function VALIDATE_PAGE_REGION_ITEM (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_return_status            OUT NOCOPY    VARCHAR2,
  p_flow_application_id      IN      NUMBER := FND_API.G_MISS_NUM,
  p_flow_code                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_page_application_id      IN      NUMBER := FND_API.G_MISS_NUM,
  p_page_code                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_region_application_id    IN      NUMBER := FND_API.G_MISS_NUM,
  p_region_code              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute_application_id IN      NUMBER := FND_API.G_MISS_NUM,
  p_attribute_code           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_to_page_appl_id          IN      NUMBER := FND_API.G_MISS_NUM,
  p_to_page_code             IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_to_url_attribute_appl_id IN      NUMBER := FND_API.G_MISS_NUM,
  p_to_url_attribute_code    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_caller                   IN      VARCHAR2,
  p_pass                     IN      NUMBER := 2
) return BOOLEAN is
  cursor l_check_to_url_csr is
    select 1
    from   AK_ATTRIBUTES
    where  attribute_application_id = p_to_url_attribute_appl_id
    and    attribute_code = p_to_url_attribute_code
    and    upper(data_type) = 'URL';
  cursor l_check_to_page_csr is
    select 1
    from   AK_FLOW_REGION_RELATIONS
    where  flow_application_id = p_flow_application_id
    and    flow_code = p_flow_code
    and    from_page_appl_id = p_page_application_id
    and    from_page_code = p_page_code
    and    from_region_appl_id = p_region_application_id
    and    from_region_code = p_region_code
    and    to_page_appl_id = p_to_page_appl_id
    and    to_page_code = p_to_page_code;
  l_api_version_number   CONSTANT number := 1.0;
  l_api_name             CONSTANT varchar2(30) := 'Validate_Page_Region_Item';
  l_database_object_name VARCHAR2(30);
  l_dummy                NUMBER;
  l_error                BOOLEAN;
  l_return_status        varchar2(1);
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
  if ((p_flow_application_id is null) or
      (p_flow_application_id = FND_API.G_MISS_NUM)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'FLOW_APPLICATION_ID');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_flow_code is null) or
      (p_flow_code = FND_API.G_MISS_CHAR)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'FLOW_CODE');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_page_application_id is null) or
      (p_page_application_id = FND_API.G_MISS_NUM)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'PAGE_APPLICATION_ID');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_page_code is null) or
      (p_page_code = FND_API.G_MISS_CHAR)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'PAGE_CODE');
      FND_MSG_PUB.Add;
    end if;
  end if;

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

  --
  -- Check that the parent flow page region exists
  --
  if (NOT AK_FLOW_PVT.PAGE_REGION_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_flow_application_id => p_flow_application_id,
            p_flow_code => p_flow_code,
            p_page_application_id => p_page_application_id,
            p_page_code => p_page_code,
            p_region_application_id => p_region_application_id,
            p_region_code => p_region_code) ) then
      l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_INVALID_PG_REGION_REFERENCE');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
                           ' ' || p_flow_code ||
                           ' ' || to_char(p_page_application_id) ||
                           ' ' || p_page_code ||
                           ' ' || to_char(p_region_application_id) ||
                           ' ' || p_region_code);
      FND_MSG_PUB.Add;
    end if;
  end if;

  --
  -- Check that the region item exists in AK_REGION_ITEMS
  --
  if (NOT AK_REGION_PVT.ITEM_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_region_application_id => p_region_application_id,
            p_region_code => p_region_code,
            p_attribute_application_id => p_attribute_application_id,
            p_attribute_code => p_attribute_code) ) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_INVALID_REG_ITEM_REFERENCE');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
                           ' ' || p_region_code ||
                           ' ' || to_char(p_attribute_application_id) ||
                           ' ' || p_attribute_code);
      FND_MSG_PUB.Add;
    end if;
  end if;

  --
  --** check that required columns are not null and, unless calling  **
  --** from UPDATE procedure, the columns are not missing            **
  --
  -- - if to_page_appl_id is given, to_page_code must also be given, and
  --   vice versa.
  --
  if (p_to_page_appl_id is not null) and
     (p_to_page_appl_id <> FND_API.G_MISS_NUM) and
     ((p_to_page_code is null) or (p_to_page_code = FND_API.G_MISS_CHAR)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'TO_PAGE_CODE');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if (p_to_page_code is not null) and
     (p_to_page_code <> FND_API.G_MISS_CHAR) and
     ((p_to_page_appl_id is null) or
      (p_to_page_appl_id = FND_API.G_MISS_NUM)) then
   l_error := TRUE;
   if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'TO_PAGE_APPL_ID');
      FND_MSG_PUB.Add;
    end if;
  end if;

  --
  -- - if to_url_attribute_appl_id is given, to_url_attribute_code must
  --   also be given, and vice versa.
  --
  if (p_to_url_attribute_appl_id is not null) and
     (p_to_url_attribute_appl_id <> FND_API.G_MISS_NUM) and
     ((p_to_url_attribute_code is null) or
      (p_to_url_attribute_code = FND_API.G_MISS_CHAR)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'TO_URL_ATTRIBUTE_CODE');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if (p_to_url_attribute_code is not null) and
     (p_to_url_attribute_code <> FND_API.G_MISS_CHAR) and
     ((p_to_url_attribute_appl_id is null) or
      (p_to_url_attribute_appl_id = FND_API.G_MISS_NUM)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'TO_URL_ATTRIBUTE_APPL_ID');
      FND_MSG_PUB.Add;
    end if;
  end if;

  --
  -- - either to_page or to_url_attribute must be specified,
  --   unless calling from update.
  --
  if  ( (p_to_page_code is null) or
        (p_to_page_code = FND_API.G_MISS_CHAR) ) and
      ( (p_to_url_attribute_code is null) or
        (p_to_url_attribute_code = FND_API.G_MISS_CHAR) ) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_NO_LINK_SELECTED');
      FND_MSG_PUB.Add;
    end if;
  end if;

  --
  -- - cannot specify both to_page and to_url_attribute
  --
  if  ( (p_to_page_code is not null) and
        (p_to_page_code <> FND_API.G_MISS_CHAR) ) and
      ( (p_to_url_attribute_code is not null) and
        (p_to_url_attribute_code <> FND_API.G_MISS_CHAR) ) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_TWO_LINK_SELECTED');
      FND_MSG_PUB.Add;
    end if;
  end if;

  --
  --** Validate columns **
  --
  --  to_page_appl_id and to_page_code
  --
  if not ( ( (p_to_page_appl_id = FND_API.G_MISS_NUM) or
             (p_to_page_appl_id is null) )
            or
           ( (p_to_page_code = FND_API.G_MISS_CHAR) or
             (p_to_page_code is null) ) ) then
    --
    -- 1. The target page must exist
    --
    if (NOT AK_FLOW_PVT.PAGE_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_flow_application_id => p_flow_application_id,
            p_flow_code => p_flow_code,
            p_page_application_id => p_to_page_appl_id,
            p_page_code => p_to_page_code) ) then
      l_error := TRUE;
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
        FND_MESSAGE.SET_NAME('AK','AK_NO_REGION_RELATION');
        FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
                           ' ' || p_flow_code ||
                           ' ' || to_char(p_to_page_appl_id) ||
                           ' ' || p_to_page_code);
        FND_MSG_PUB.Add;
      end if;
    end if; /* if PAGE_EXISTS */
    --
    -- 2. There must be a region relation linking this region and the
    --    target page
    --
    open l_check_to_page_csr;
    fetch l_check_to_page_csr into l_dummy;
    if (l_check_to_page_csr%notfound) then
      l_error := TRUE;
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
        FND_MESSAGE.SET_NAME('AK','AK_INVALID_TO_PAGE_REFERENCE');
        FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
                           ' ' || p_flow_code ||
                           ' ' || to_char(p_to_page_appl_id) ||
                           ' ' || p_to_page_code);
        FND_MSG_PUB.Add;
      end if;
    end if; /* if l_check_to_page */
    close l_check_to_page_csr;

  end if; /* if to_page_appl_id and to_page_attribute_code */

  --
  -- to_url_attribute_appl_id and to_url_attribute_code
  --
  -- - To URL attribute must be a 'URL' type attribute
  --
  if (p_to_url_attribute_appl_id <> FND_API.G_MISS_NUM and
      p_to_url_attribute_appl_id is not null) OR
     (p_to_url_attribute_code <> FND_API.G_MISS_CHAR and
      p_to_url_attribute_code is not null) then
    open l_check_to_url_csr;
    fetch l_check_to_url_csr into l_dummy;
    if (l_check_to_url_csr%notfound) then
      l_error := TRUE;
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
        FND_MESSAGE.SET_NAME('AK','AK_INVALID_TO_URL_ATTRIBUTE');
        FND_MESSAGE.SET_TOKEN('KEY',  to_char(p_to_url_attribute_appl_id) ||
                           ' ' || p_to_url_attribute_code);
        FND_MSG_PUB.Add;
      end if;
    end if;
    close l_check_to_url_csr;
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

end VALIDATE_PAGE_REGION_ITEM;

--=======================================================
--  Function    VALIDATE_REGION_RELATION
--
--  Usage       Private API for validating a flow region relation.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Perform validation on a flow region relation record.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              In addition, this function returns TRUE if all
--              validation tests are passed, or FALSE otherwise.
--  Parameters  Flow Region Relation columns
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
function VALIDATE_REGION_RELATION (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_return_status            OUT NOCOPY    VARCHAR2,
  p_flow_application_id      IN      NUMBER := FND_API.G_MISS_NUM,
  p_flow_code                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_foreign_key_name         IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_from_page_appl_id        IN      NUMBER := FND_API.G_MISS_NUM,
  p_from_page_code           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_from_region_appl_id      IN      NUMBER := FND_API.G_MISS_NUM,
  p_from_region_code         IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_to_page_appl_id          IN      NUMBER := FND_API.G_MISS_NUM,
  p_to_page_code             IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_to_region_appl_id        IN      NUMBER := FND_API.G_MISS_NUM,
  p_to_region_code           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_application_id           IN      NUMBER := FND_API.G_MISS_NUM,
  p_caller                   IN      VARCHAR2,
  p_pass                     IN      NUMBER := 2
) return BOOLEAN is
  cursor l_check_fk_connect_csr is
  select 1
  from   ak_foreign_keys fk, ak_unique_keys uk,
         ak_regions ar1, ak_regions ar2
  where  fk.database_object_name = ar1.database_object_name
  and    fk.unique_key_name = uk.unique_key_name
  and    uk.database_object_name = ar2.database_object_name
  and    ar1.region_application_id = p_from_region_appl_id
  and    ar1.region_code = p_from_region_code
  and    ar2.region_application_id = p_to_region_appl_id
  and    ar2.region_code = p_to_region_code
  and    fk.foreign_key_name = p_foreign_key_name
  UNION
  select 1
  from   ak_foreign_keys fk, ak_unique_keys uk,
         ak_regions ar1, ak_regions ar2
  where  fk.database_object_name = ar2.database_object_name
  and    fk.unique_key_name = uk.unique_key_name
  and    uk.database_object_name = ar1.database_object_name
  and    ar1.region_application_id = p_from_region_appl_id
  and    ar1.region_code = p_from_region_code
  and    ar2.region_application_id = p_to_region_appl_id
  and    ar2.region_code = p_to_region_code
  and    fk.foreign_key_name = p_foreign_key_name;
  l_api_version_number CONSTANT number := 1.0;
  l_api_name           CONSTANT varchar2(30) := 'Validate_Region_Relation';
  l_dummy              NUMBER;
  l_error              BOOLEAN;
  l_return_status      varchar2(1);
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
  if ((p_flow_application_id is null) or
      (p_flow_application_id = FND_API.G_MISS_NUM)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'FLOW_APPLICATION_ID');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_flow_code is null) or
      (p_flow_code = FND_API.G_MISS_CHAR)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'FLOW_CODE');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_foreign_key_name is null) or
      (p_foreign_key_name = FND_API.G_MISS_CHAR)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'FOREIGN_KEY_NAME');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_from_page_appl_id is null) or
      (p_from_page_appl_id = FND_API.G_MISS_NUM)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'FROM_PAGE_APPL_ID');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_from_page_code is null) or
      (p_from_page_code = FND_API.G_MISS_CHAR)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'FROM_PAGE_CODE');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_from_region_appl_id is null) or
      (p_from_region_appl_id = FND_API.G_MISS_NUM)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'FROM_REGION_APPL_ID');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_from_region_code is null) or
      (p_from_region_code = FND_API.G_MISS_CHAR)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'FROM_REGION_CODE');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_to_page_appl_id is null) or
      (p_to_page_appl_id = FND_API.G_MISS_NUM)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'TO_PAGE_APPL_ID');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_to_page_code is null) or
      (p_to_page_code = FND_API.G_MISS_CHAR)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'TO_PAGE_CODE');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_to_region_appl_id is null) or
      (p_to_region_appl_id = FND_API.G_MISS_NUM)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'TO_REGION_APPL_ID');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_to_region_code is null) or
      (p_to_region_code = FND_API.G_MISS_CHAR)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'TO_REGION_CODE');
      FND_MSG_PUB.Add;
    end if;
  end if;

  --
  -- Check that the parent flow exists
  --
  if (NOT AK_FLOW_PVT.FLOW_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_flow_application_id => p_flow_application_id,
            p_flow_code => p_flow_code) ) then
      l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_INVALID_FLOW_REFERENCE');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
                           ' ' || p_flow_code);
      FND_MSG_PUB.Add;
    end if;
  end if;

  --
  -- Check that the foreign key exists
  --
  if (NOT AK_KEY_PVT.FOREIGN_KEY_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_foreign_key_name => p_foreign_key_name) ) then
      l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_INVALID_FK_REFERENCE');
      FND_MESSAGE.SET_TOKEN('KEY', p_foreign_key_name);
      FND_MSG_PUB.Add;
    end if;
  end if;

  --
  -- Check that the from page region exists
  --
  if NOT AK_FLOW_PVT.PAGE_REGION_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_flow_application_id => p_flow_application_id,
            p_flow_code => p_flow_code,
            p_page_application_id => p_from_page_appl_id,
            p_page_code => p_from_page_code,
            p_region_application_id => p_from_region_appl_id,
            p_region_code => p_from_region_code) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_INVALID_PG_REGION_REFERENCE');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
                           ' ' || p_flow_code ||
                           ' ' || to_char(p_from_page_appl_id) ||
                           ' ' || p_from_page_code ||
                           ' ' || to_char(p_from_region_appl_id) ||
                           ' ' || p_from_region_code);
      FND_MSG_PUB.Add;
    end if;
  end if;

  --
  -- Check that the to page region exists
  --
  if NOT AK_FLOW_PVT.PAGE_REGION_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_flow_application_id => p_flow_application_id,
            p_flow_code => p_flow_code,
            p_page_application_id => p_to_page_appl_id,
            p_page_code => p_to_page_code,
            p_region_application_id => p_to_region_appl_id,
            p_region_code => p_to_region_code) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_INVALID_PG_REGION_REFERENCE');
      FND_MESSAGE.SET_TOKEN('REF_OBJECT','AK_FLOW_PAGE_REGION', TRUE);
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
                           ' ' || p_flow_code ||
                           ' ' || to_char(p_to_page_appl_id) ||
                           ' ' || p_to_page_code ||
                           ' ' || to_char(p_to_region_appl_id) ||
                           ' ' || p_to_region_code);
      FND_MSG_PUB.Add;
    end if;
  end if;

  --
  --** check that required columns are not null and, unless calling  **
  --** from UPDATE procedure, the columns are not missing            **
  --
  if (p_application_id is null) or
     ((p_application_id = FND_API.G_MISS_NUM) and
      (p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'APPLICATION_ID');
      FND_MSG_PUB.Add;
    end if;
  end if;

  --
  --  Validate columns
  --
  --  - application ID
  --
  if (p_application_id <> FND_API.G_MISS_NUM) then
    if (NOT AK_ON_OBJECTS_PVT.VALID_APPLICATION_ID (
                p_api_version_number => 1.0,
                p_return_status => l_return_status,
                p_application_id => p_application_id)
       ) then
      l_error := TRUE;
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
        FND_MESSAGE.SET_NAME('AK','AK_INVALID_COLUMN_VALUE');
        FND_MESSAGE.SET_TOKEN('COLUMN','APPLICATION_ID');
        FND_MSG_PUB.Add;
      end if;
    end if;
  end if;

  --
  --  - from page region must be different than target page region
  --
  if (p_from_page_appl_id = p_to_page_appl_id) and
     (p_from_page_code = p_to_page_code) and
     (p_from_region_appl_id = p_to_region_appl_id) and
     (p_from_region_code = p_to_region_code) then
      l_error := TRUE;
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
        FND_MESSAGE.SET_NAME('AK','AK_INVALID_TARGET_REGION');
        FND_MSG_PUB.Add;
      end if;
  end if;

  --
  -- - foreign key name must provide connection between  the
  --   from page region and the to page region
  --
  open l_check_fk_connect_csr;
  fetch l_check_fk_connect_csr into l_dummy;
  if (l_check_fk_connect_csr%notfound) then
     l_error := TRUE;
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
        FND_MESSAGE.SET_NAME('AK','AK_INVALID_FOREIGN_KEY');
        FND_MSG_PUB.Add;
      end if;
  end if;
  close l_check_fk_connect_csr;

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

end VALIDATE_REGION_RELATION;

end AK_FLOW3_PVT;

/
