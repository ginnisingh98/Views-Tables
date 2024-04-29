--------------------------------------------------------
--  DDL for Package Body AK_CUSTOM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AK_CUSTOM_PVT" as
/* $Header: akdvcreb.pls 120.5 2006/04/14 13:52:05 tshort noship $ */

--=======================================================
--  Procedure   DOWNLOAD_CUSTOM
--
--  Usage       Private API for downloading customizations. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API will extract the customizations selected
--              by application ID or by key values from the
--              database to the output file.
--              If a region is selected for writing to the loader
--              file, all its children records (including region items)
--              will also be written.
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
--              p_get_object_flag : IN required
--                  Call DOWNLOAD_OBJECT API to extract objects that
--                  are referenced by the regions that will be extracted
--                  by this API if this parameter is 'Y'.
--
--              One of the following parameters must be provided:
--
--              p_application_id : IN optional
--                  If given, all attributes for this application ID
--                  will be written to the output file.
--                  p_application_id will be ignored if a table is
--                  given in p_custom_pk_tbl.
--              p_custom_pk_tbl : IN optional
--                  If given, only regions whose key values are
--                  included in this table will be written to the
--                  output file.
--
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure DOWNLOAD_CUSTOM (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_application_id           IN      NUMBER := FND_API.G_MISS_NUM,
  p_custom_pk_tbl            IN      AK_CUSTOM_PUB.Custom_PK_Tbl_Type           				     := AK_CUSTOM_PUB.G_MISS_CUSTOM_PK_TBL,
  p_nls_language             IN      VARCHAR2,
  p_get_object_flag          IN      VARCHAR2,
  p_level		     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_levelpk		     IN      VARCHAR2 := FND_API.G_MISS_CHAR
) is
  cursor l_get_custom_list_csr (application_id number, p_region_code varchar2) is
    select ac.customization_application_id, ac.customization_code,
	   ac.region_application_id, ac.region_code
    from   AK_CUSTOMIZATIONS ac, AK_REGIONS ar
    where  ac.REGION_APPLICATION_ID = application_id
    and    ac.REGION_CODE = p_region_code
    and     ac.region_application_id = ar.region_application_id
    and     ac.region_code = ar.region_code;
  cursor l_get_custom_resp_list_csr (application_id number, p_region_code varchar2, levelpk number) is
    select ac.customization_application_id, ac.customization_code,
           ac.region_application_id, ac.region_code
    from   AK_CUSTOMIZATIONS ac, AK_REGIONS ar
    where  ac.REGION_APPLICATION_ID = application_id
    and    ac.REGION_CODE = p_region_code
    and     ac.region_application_id = ar.region_application_id
    and     ac.region_code = ar.region_code
    and     ac.responsibility_id = levelpk;
  cursor l_get_custom_resp_list2_csr (application_id number, p_region_code varchar2) is
    select ac.customization_application_id, ac.customization_code,
           ac.region_application_id, ac.region_code
    from   AK_CUSTOMIZATIONS ac, AK_REGIONS ar
    where  ac.REGION_APPLICATION_ID = application_id
    and    ac.REGION_CODE = p_region_code
    and     ac.region_application_id = ar.region_application_id
    and     ac.region_code = ar.region_code
    and     ac.responsibility_id is not null;
  cursor l_get_custom_org_list_csr (application_id number, p_region_code varchar2, levelpk number) is
    select ac.customization_application_id, ac.customization_code,
           ac.region_application_id, ac.region_code
    from   AK_CUSTOMIZATIONS ac, AK_REGIONS ar
    where  ac.REGION_APPLICATION_ID = application_id
    and    ac.REGION_CODE = p_region_code
    and     ac.region_application_id = ar.region_application_id
    and     ac.region_code = ar.region_code
    and     ac.org_id = levelpk;
  cursor l_get_custom_org_list2_csr (application_id number, p_region_code varchar2) is
    select ac.customization_application_id, ac.customization_code,
           ac.region_application_id, ac.region_code
    from   AK_CUSTOMIZATIONS ac, AK_REGIONS ar
    where  ac.REGION_APPLICATION_ID = application_id
    and    ac.REGION_CODE = p_region_code
    and     ac.region_application_id = ar.region_application_id
    and     ac.region_code = ar.region_code
    and     ac.org_id is not null;
  cursor l_get_custom_site_list_csr (application_id number, p_region_code varchar2, levelpk number) is
    select ac.customization_application_id, ac.customization_code,
           ac.region_application_id, ac.region_code
    from   AK_CUSTOMIZATIONS ac, AK_REGIONS ar
    where  ac.REGION_APPLICATION_ID = application_id
    and    ac.REGION_CODE = p_region_code
    and     ac.region_application_id = ar.region_application_id
    and     ac.region_code = ar.region_code
    and     ac.site_id = levelpk;
  cursor l_get_custom_site_list2_csr (application_id number, p_region_code varchar2) is
    select ac.customization_application_id, ac.customization_code,
           ac.region_application_id, ac.region_code
    from   AK_CUSTOMIZATIONS ac, AK_REGIONS ar
    where  ac.REGION_APPLICATION_ID = application_id
    and    ac.REGION_CODE = p_region_code
    and     ac.region_application_id = ar.region_application_id
    and     ac.region_code = ar.region_code
    and     ac.site_id is not null;
  cursor l_get_custom_fun_list_csr (application_id number, p_region_code varchar2, levelpk varchar2) is
    select ac.customization_application_id, ac.customization_code,
           ac.region_application_id, ac.region_code
    from   AK_CUSTOMIZATIONS ac, AK_REGIONS ar
    where  ac.REGION_APPLICATION_ID = application_id
    and    ac.REGION_CODE = p_region_code
    and     ac.region_application_id = ar.region_application_id
    and     ac.region_code = ar.region_code
    and     ac.function_name = levelpk;
  cursor l_get_custom_fun_list2_csr (application_id number, p_region_code varchar2) is
    select ac.customization_application_id, ac.customization_code,
           ac.region_application_id, ac.region_code
    from   AK_CUSTOMIZATIONS ac, AK_REGIONS ar
    where  ac.REGION_APPLICATION_ID = application_id
    and    ac.REGION_CODE = p_region_code
    and     ac.region_application_id = ar.region_application_id
    and     ac.region_code = ar.region_code
    and     ac.function_name is not null;
  cursor l_get_custom_local_list_csr (application_id number, p_region_code varchar2, levelpk varchar2) is
    select ac.customization_application_id, ac.customization_code,
           ac.region_application_id, ac.region_code
    from   AK_CUSTOMIZATIONS ac, AK_REGIONS ar
    where  ac.REGION_APPLICATION_ID = application_id
    and    ac.REGION_CODE = p_region_code
    and     ac.region_application_id = ar.region_application_id
    and     ac.region_code = ar.region_code
    and     ac.localization_code = levelpk;
  cursor l_get_custom_local_list2_csr (application_id number, p_region_code varchar2) is
    select ac.customization_application_id, ac.customization_code,
           ac.region_application_id, ac.region_code
    from   AK_CUSTOMIZATIONS ac, AK_REGIONS ar
    where  ac.REGION_APPLICATION_ID = application_id
    and    ac.REGION_CODE = p_region_code
    and     ac.region_application_id = ar.region_application_id
    and     ac.region_code = ar.region_code
    and     ac.localization_code is not null;
  cursor l_get_region_list_csr (region_appl_id_param number,
                                region_code_param varchar2) is
    select region_application_id, region_code
    from  AK_REGIONS
    where region_application_id = region_appl_id_param
    and   region_code = region_code_param;
  cursor l_get_region_code_csr (application_id number) is
    select region_application_id, region_code
    from   AK_REGIONS
    where  region_application_id = application_id;
  cursor l_get_org_id(levelpk varchar2) is
    select organization_id
    from   MTL_PARAMETERS
    where  organization_code = levelpk;
  cursor l_get_org_id2 is
    select 'X'
    from   ak_customizations
    where  org_id is not null
    and    rownum = 1;
  cursor l_get_resp_id(levelpk varchar2) is
    select responsibility_id
    from   FND_RESPONSIBILITY
    where  responsibility_key = levelpk;
  cursor l_get_resp_id2 is
    select 'X'
    from   ak_customizations
    where  responsibility_id is not null
    and    rownum = 1;
  cursor l_get_fun_name(levelpk varchar2) is
    select function_name
    from   fnd_form_functions
    where  function_name = levelpk;
  cursor l_get_fun_name2 is
    select 'X'
    from   ak_customizations
    where  function_name is not null
    and    rownum = 1;
  cursor l_get_local_code(levelpk varchar2) is
    select territory_code
    from   fnd_territories
    where  territory_code = levelpk;
  cursor l_get_local_code2 is
    select 'X'
    from   ak_customizations
    where  localization_code is not null
    and    rownum = 1;
  l_api_version_number CONSTANT number := 1.0;
  l_api_name           CONSTANT varchar2(30) := 'Download_Custom';
  l_region_pk_tbl      AK_REGION_PUB.Region_PK_Tbl_Type;
  l_custom_pk_tbl      AK_CUSTOM_PUB.Custom_PK_Tbl_Type;
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(2000);
  l_index              NUMBER;
  l_return_status      varchar2(1);
  l_level_id_pk	       NUMBER;
  l_resp_id_pk	       NUMBER;
  l_org_id_pk	       NUMBER;
  l_level_pk	       VARCHAR2(30);
  l_fun_pk	       VARCHAR2(30);
begin

  IF NOT FND_API.Compatible_API_Call (
    l_api_version_number, p_api_version_number, l_api_name,
    G_PKG_NAME) then
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return;
  END IF;

  if (p_level = 'RESPONSIBILITY' and p_levelpk is not null and
	p_levelpk <> FND_API.G_MISS_CHAR) then
      open l_get_resp_id(p_levelpk);
      fetch l_get_resp_id into l_resp_id_pk;
      if (l_get_resp_id%notfound) then
        close l_get_resp_id;
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
           FND_MESSAGE.SET_NAME('AK','AK_RESP_IS_NOT_VALID');
	   FND_MESSAGE.SET_TOKEN('KEY',p_levelpk);
           FND_MSG_PUB.Add;
        end if;
        RAISE FND_API.G_EXC_ERROR;
      end if;
      close l_get_resp_id;
  elsif (p_level = 'RESPONSIBILITY' and (p_levelpk is null or
        p_levelpk = FND_API.G_MISS_CHAR)) then
      open l_get_resp_id2;
      fetch l_get_resp_id2 into l_level_id_pk;
      if (l_get_resp_id2%notfound) then
        close l_get_resp_id2;
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
           FND_MESSAGE.SET_NAME('AK','AK_RESP_IS_NOT_VALID');
           FND_MESSAGE.SET_TOKEN('KEY',p_levelpk);
           FND_MSG_PUB.Add;
        end if;
        RAISE FND_API.G_EXC_ERROR;
      end if;
      close l_get_resp_id2;
  elsif (p_level = 'ORGANIZATION' and p_levelpk is not null and
        p_levelpk <> FND_API.G_MISS_CHAR) then
      open l_get_org_id(p_levelpk);
      fetch l_get_org_id into l_org_id_pk;
      if (l_get_org_id%notfound) then
        close l_get_org_id;
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
           FND_MESSAGE.SET_NAME('AK','AK_ORG_IS_NOT_VALID');
           FND_MESSAGE.SET_TOKEN('KEY',p_levelpk);
           FND_MSG_PUB.Add;
        end if;
        RAISE FND_API.G_EXC_ERROR;
      end if;
      close l_get_org_id;
  elsif (p_level = 'ORGANIZATION' and (p_levelpk is null or
        p_levelpk = FND_API.G_MISS_CHAR)) then
      open l_get_org_id2;
      fetch l_get_org_id2 into l_level_id_pk;
      if (l_get_org_id2%notfound) then
        close l_get_org_id2;
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
           FND_MESSAGE.SET_NAME('AK','AK_ORG_IS_NOT_VALID');
           FND_MESSAGE.SET_TOKEN('KEY',p_levelpk);
           FND_MSG_PUB.Add;
        end if;
        RAISE FND_API.G_EXC_ERROR;
      end if;
      close l_get_org_id2;
    elsif (p_level = 'FUNCTION' and p_levelpk is not null and
        p_levelpk <> FND_API.G_MISS_CHAR) then
      open l_get_fun_name(p_levelpk);
      fetch l_get_fun_name into l_fun_pk;
      if (l_get_fun_name%notfound) then
        close l_get_fun_name;
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
           FND_MESSAGE.SET_NAME('AK','AK_FUN_IS_NOT_VALID');
           FND_MESSAGE.SET_TOKEN('KEY',p_levelpk);
           FND_MSG_PUB.Add;
        end if;
        RAISE FND_API.G_EXC_ERROR;
      end if;
      close l_get_fun_name;
    elsif (p_level = 'FUNCTION' and (p_levelpk is null or
        p_levelpk = FND_API.G_MISS_CHAR)) then
      open l_get_fun_name2;
      fetch l_get_fun_name2 into l_level_id_pk;
      if (l_get_fun_name2%notfound) then
        close l_get_fun_name2;
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
           FND_MESSAGE.SET_NAME('AK','AK_FUN_IS_NOT_VALID');
           FND_MESSAGE.SET_TOKEN('KEY',p_levelpk);
           FND_MSG_PUB.Add;
        end if;
        RAISE FND_API.G_EXC_ERROR;
      end if;
      close l_get_fun_name2;
  end if;
  -- Check that one of the following selection criteria is given:
  -- - p_application_id alone, or
  -- - a list of region_application_id and region_code in p_object_PK_tbl
  if (p_application_id = FND_API.G_MISS_NUM) then
    if (p_custom_PK_tbl.count = 0) then
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.SET_NAME('AK','AK_NO_SELECTION');
        FND_MSG_PUB.Add;
      end if;
      raise FND_API.G_EXC_ERROR;
    end if;
  else
    if (p_custom_PK_tbl.count > 0) then
      -- both application ID and a list of regions to be extracted are
      -- given, issue a warning that we will ignore the application ID
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.SET_NAME('AK','AK_APPL_ID_IGNORED');
        FND_MSG_PUB.Add;
      end if;
    end if;
  end if;

  -- If selecting by application ID, first load a custom primary key tabl
  -- with the primary key of all customizations for the given application ID.
  -- If selecting by a list of customizations, simply copy the custom
  -- primary key table with the parameter
  if (p_custom_PK_tbl.count > 0) then
    l_custom_pk_tbl := p_custom_pk_tbl;
  else
    l_index := 1;
    open l_get_region_code_csr(p_application_id);
    loop
      fetch l_get_region_code_csr into
        l_custom_pk_tbl(l_index).region_appl_id,
        l_custom_pk_tbl(l_index).region_code;
	if (l_get_region_code_csr%notfound and l_index = 1) then
           close l_get_region_code_csr;
           if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
               FND_MESSAGE.SET_NAME('AK','AK_REGION_DOES_NOT_EXIST');
               FND_MSG_PUB.Add;
           end if;
           raise FND_API.G_EXC_ERROR;
	end if;
        exit when l_get_region_code_csr%notfound;
        l_index := l_index + 1;
      end loop;
      close l_get_region_code_csr;
  end if;

  l_index := l_custom_pk_tbl.FIRST;

  while (l_index is not null) loop
      --
      -- Add the region referenced by this customization to the region list
      --
      for l_region_rec in l_get_region_list_csr (
                 l_custom_pk_tbl(l_index).region_appl_id,
		 l_custom_pk_tbl(l_index).region_code) LOOP
      AK_REGION_PVT.INSERT_REGION_PK_TABLE (
              p_return_status => l_return_status,
              p_region_application_id =>									l_region_rec.region_application_id,
	      p_region_code => l_region_rec.region_code,
              p_region_pk_tbl => l_region_pk_tbl);
      end loop;
    l_index := l_custom_pk_tbl.NEXT(l_index);
  end loop;

  l_index := l_region_pk_tbl.LAST;

--  if (AK_DOWNLOAD_GRP.G_DOWNLOAD_REG = 'Y') then
  if (l_region_pk_tbl.count > 0) then
    AK_REGION_PVT.DOWNLOAD_REGION (
       p_validation_level => p_validation_level,
       p_api_version_number => 1.0,
       p_return_status => l_return_status,
       p_application_id => p_application_id,
       p_region_pk_tbl => l_region_pk_tbl,
       p_nls_language => p_nls_language,
       p_get_object_flag => 'Y'
    );

      if (l_return_status = FND_API.G_RET_STS_ERROR) or
         (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
        -- dbms_output.put_line(l_api_name || ' Error downloading regions');
        raise FND_API.G_EXC_ERROR;
      end if;
  end if;
--  end if;

  l_custom_pk_tbl.DELETE;
  l_index := l_region_pk_tbl.FIRST;

  while (l_index is not null) loop
      --
      -- Add the customizations referenced by this region to the custom list
      --
    if (p_level is null or p_level = FND_API.G_MISS_CHAR) then
      for l_custom_rec in l_get_custom_list_csr (
		l_region_pk_tbl(l_index).region_appl_id,
		l_region_pk_tbl(l_index).region_code) LOOP
        AK_CUSTOM_PVT.INSERT_CUSTOM_PK_TABLE(
           p_return_status => l_return_status,
           p_region_application_id => l_custom_rec.region_application_id,
           p_region_code => l_custom_rec.region_code,
	   p_custom_appl_id => l_custom_rec.customization_application_id,
	   p_custom_code => l_custom_rec.customization_code,
           p_custom_pk_tbl => l_custom_pk_tbl);
      end loop;
    elsif (p_level = 'RESPONSIBILITY' and l_resp_id_pk is not null) then
      for l_custom_rec in l_get_custom_resp_list_csr (
                l_region_pk_tbl(l_index).region_appl_id,
                l_region_pk_tbl(l_index).region_code,
		l_resp_id_pk) LOOP
        AK_CUSTOM_PVT.INSERT_CUSTOM_PK_TABLE(
           p_return_status => l_return_status,
           p_region_application_id => l_custom_rec.region_application_id,
           p_region_code => l_custom_rec.region_code,
           p_custom_appl_id => l_custom_rec.customization_application_id,
           p_custom_code => l_custom_rec.customization_code,
           p_custom_pk_tbl => l_custom_pk_tbl);
      end loop;
    elsif (p_level = 'RESPONSIBILITY' and l_resp_id_pk is null) then
      for l_custom_rec in l_get_custom_resp_list2_csr (
                l_region_pk_tbl(l_index).region_appl_id,
                l_region_pk_tbl(l_index).region_code) LOOP
        AK_CUSTOM_PVT.INSERT_CUSTOM_PK_TABLE(
           p_return_status => l_return_status,
           p_region_application_id => l_custom_rec.region_application_id,
           p_region_code => l_custom_rec.region_code,
           p_custom_appl_id => l_custom_rec.customization_application_id,
           p_custom_code => l_custom_rec.customization_code,
           p_custom_pk_tbl => l_custom_pk_tbl);
      end loop;
    elsif (p_level = 'ORGANIZATION' and l_org_id_pk is not null) then
      for l_custom_rec in l_get_custom_org_list_csr (
                l_region_pk_tbl(l_index).region_appl_id,
                l_region_pk_tbl(l_index).region_code,
		l_org_id_pk) LOOP
        AK_CUSTOM_PVT.INSERT_CUSTOM_PK_TABLE(
           p_return_status => l_return_status,
           p_region_application_id => l_custom_rec.region_application_id,
           p_region_code => l_custom_rec.region_code,
           p_custom_appl_id => l_custom_rec.customization_application_id,
           p_custom_code => l_custom_rec.customization_code,
           p_custom_pk_tbl => l_custom_pk_tbl);
      end loop;
    elsif (p_level = 'ORGANIZATION' and l_org_id_pk is null) then
      for l_custom_rec in l_get_custom_org_list2_csr (
                l_region_pk_tbl(l_index).region_appl_id,
                l_region_pk_tbl(l_index).region_code) LOOP
        AK_CUSTOM_PVT.INSERT_CUSTOM_PK_TABLE(
           p_return_status => l_return_status,
           p_region_application_id => l_custom_rec.region_application_id,
           p_region_code => l_custom_rec.region_code,
           p_custom_appl_id => l_custom_rec.customization_application_id,
           p_custom_code => l_custom_rec.customization_code,
           p_custom_pk_tbl => l_custom_pk_tbl);
      end loop;
    elsif (p_level = 'FUNCTION' and l_fun_pk is not null) then
      for l_custom_rec in l_get_custom_fun_list_csr (
                l_region_pk_tbl(l_index).region_appl_id,
                l_region_pk_tbl(l_index).region_code,
		l_fun_pk) LOOP
        AK_CUSTOM_PVT.INSERT_CUSTOM_PK_TABLE(
           p_return_status => l_return_status,
           p_region_application_id => l_custom_rec.region_application_id,
           p_region_code => l_custom_rec.region_code,
           p_custom_appl_id => l_custom_rec.customization_application_id,
           p_custom_code => l_custom_rec.customization_code,
           p_custom_pk_tbl => l_custom_pk_tbl);
      end loop;
    elsif (p_level = 'FUNCTION' and l_fun_pk is null) then
      for l_custom_rec in l_get_custom_fun_list2_csr (
                l_region_pk_tbl(l_index).region_appl_id,
                l_region_pk_tbl(l_index).region_code) LOOP
        AK_CUSTOM_PVT.INSERT_CUSTOM_PK_TABLE(
           p_return_status => l_return_status,
           p_region_application_id => l_custom_rec.region_application_id,
           p_region_code => l_custom_rec.region_code,
           p_custom_appl_id => l_custom_rec.customization_application_id,
           p_custom_code => l_custom_rec.customization_code,
           p_custom_pk_tbl => l_custom_pk_tbl);
      end loop;
    elsif (p_level = 'SITE' and p_levelpk is not null and
        p_levelpk <> FND_API.G_MISS_CHAR) then
      for l_custom_rec in l_get_custom_site_list_csr (
                l_region_pk_tbl(l_index).region_appl_id,
                l_region_pk_tbl(l_index).region_code,
		p_levelpk) LOOP
        AK_CUSTOM_PVT.INSERT_CUSTOM_PK_TABLE(
           p_return_status => l_return_status,
           p_region_application_id => l_custom_rec.region_application_id,
           p_region_code => l_custom_rec.region_code,
           p_custom_appl_id => l_custom_rec.customization_application_id,
           p_custom_code => l_custom_rec.customization_code,
           p_custom_pk_tbl => l_custom_pk_tbl);
      end loop;
    elsif (p_level = 'SITE' and (p_levelpk is null or
        p_levelpk = FND_API.G_MISS_CHAR)) then
      for l_custom_rec in l_get_custom_site_list2_csr (
                l_region_pk_tbl(l_index).region_appl_id,
                l_region_pk_tbl(l_index).region_code) LOOP
        AK_CUSTOM_PVT.INSERT_CUSTOM_PK_TABLE(
           p_return_status => l_return_status,
           p_region_application_id => l_custom_rec.region_application_id,
           p_region_code => l_custom_rec.region_code,
           p_custom_appl_id => l_custom_rec.customization_application_id,
           p_custom_code => l_custom_rec.customization_code,
           p_custom_pk_tbl => l_custom_pk_tbl);
      end loop;
    elsif (p_level = 'LOCALIZATION' and p_levelpk is not null and
        p_levelpk <> FND_API.G_MISS_CHAR) then
      for l_custom_rec in l_get_custom_local_list_csr (
                l_region_pk_tbl(l_index).region_appl_id,
                l_region_pk_tbl(l_index).region_code,
		p_levelpk) LOOP
        AK_CUSTOM_PVT.INSERT_CUSTOM_PK_TABLE(
           p_return_status => l_return_status,
           p_region_application_id => l_custom_rec.region_application_id,
           p_region_code => l_custom_rec.region_code,
           p_custom_appl_id => l_custom_rec.customization_application_id,
           p_custom_code => l_custom_rec.customization_code,
           p_custom_pk_tbl => l_custom_pk_tbl);
      end loop;
    elsif (p_level = 'LOCALIZATION' and (p_levelpk is null or
        p_levelpk = FND_API.G_MISS_CHAR)) then
      for l_custom_rec in l_get_custom_local_list2_csr (
                l_region_pk_tbl(l_index).region_appl_id,
                l_region_pk_tbl(l_index).region_code) LOOP
        AK_CUSTOM_PVT.INSERT_CUSTOM_PK_TABLE(
           p_return_status => l_return_status,
           p_region_application_id => l_custom_rec.region_application_id,
           p_region_code => l_custom_rec.region_code,
           p_custom_appl_id => l_custom_rec.customization_application_id,
           p_custom_code => l_custom_rec.customization_code,
           p_custom_pk_tbl => l_custom_pk_tbl);
      end loop;
    end if;

    -- Ready to download the next region in the list
    l_index := l_region_pk_tbl.NEXT(l_index);
  end loop;

  -- Write details for each selected customization, including its criteria, to
  -- a buffer to be passed back to the calling procedure.
  l_index := l_custom_pk_tbl.FIRST;
  if (l_custom_pk_tbl.LAST > 0) then
  while (l_index is not null) loop
    --
    -- Write custom information from the database
    --
--dbms_output.put_line('writing custom #'||to_char(l_index) || ':' ||
--                      l_custom_pk_tbl(l_index).region_code);

    if ( (l_custom_pk_tbl(l_index).region_appl_id <> FND_API.G_MISS_NUM) and
        (l_custom_pk_tbl(l_index).region_appl_id is not null) and
        (l_custom_pk_tbl(l_index).region_code <> FND_API.G_MISS_CHAR) and
        (l_custom_pk_tbl(l_index).region_code is not null) ) then
      WRITE_CUSTOM_TO_BUFFER(
        p_validation_level => p_validation_level,
        p_return_status => l_return_status,
      p_region_application_id => l_custom_pk_tbl(l_index).region_appl_id,
      p_region_code => l_custom_pk_tbl(l_index).region_code,
      p_custom_application_id => l_custom_pk_tbl(l_index).custom_appl_id,
      p_custom_code => l_custom_pk_tbl(l_index).custom_code,
        p_nls_language => p_nls_language
      );
    end if;

    if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
      (l_return_status = FND_API.G_RET_STS_ERROR) then
      RAISE FND_API.G_EXC_ERROR;
    end if;

    -- Ready to download the next customization in the list
    l_index := l_custom_pk_tbl.NEXT(l_index);
  end loop;

--  else
--    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
--        FND_MESSAGE.SET_NAME('AK','AK_CUST_FOR_REG_DOES_NOT_EXIST');
--        FND_MSG_PUB.Add;
--    end if;
--    raise FND_API.G_EXC_ERROR;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN VALUE_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_CUSTOM_PK_VALUE_ERROR');
      FND_MSG_PUB.Add;
    end if;
    --dbms_output.put_line('Value error occurred - check your custom list.');
    p_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    --dbms_output.put_line(SUBSTR(SQLERRM,1,240));
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;
end DOWNLOAD_CUSTOM;

--=======================================================
--  Procedure   INSERT_CUSTOM_PK_TABLE
--
--  Usage       Private API for inserting the given region's
--              primary key value into the given object
--              table.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API inserts the given region's primary
--              key value into a given region table
--              (of type Object_PK_Tbl_Type) only if the
--              primary key does not already exist in the table.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_region_application_id : IN required
--              p_region_code : IN required
--                  Key value of the region to be inserted to the
--                  table.
--              p_custom_pk_tbl : IN OUT
--                  Custom Region table to be updated.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure INSERT_CUSTOM_PK_TABLE (
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_region_application_id    IN      NUMBER,
  p_region_code              IN      VARCHAR2,
  p_custom_appl_id	     IN	     NUMBER,
  p_custom_code		     IN      VARCHAR2,
  p_custom_pk_tbl            IN OUT NOCOPY  AK_CUSTOM_PUB.Custom_PK_Tbl_Type
) is
  cursor l_get_custom_list_csr (application_id number, application_code varchar2, custom_appl_id number, custom_code varchar2) is
    select ac.customization_application_id, ac.customization_code,
           ac.region_application_id, ac.region_code
    from   AK_CUSTOMIZATIONS ac, AK_REGIONS ar
    where  ac.REGION_APPLICATION_ID = application_id
    and    ac.region_code = application_code
    and	   ac.customization_application_id = custom_appl_id
    and    ac.customization_code = custom_code
    and     ac.region_application_id = ar.region_application_id
    and     ac.region_code = ar.region_code;

  l_api_version_number CONSTANT number := 1.0;
  l_api_name           CONSTANT varchar2(30) := 'Insert_Custom_PK_Table';
  l_index         NUMBER;
begin
  --
  -- if table is empty, just insert the region primary key into it
  --
  if (p_custom_pk_tbl.count = 0) then
--dbms_output.put_line('Inserted region: ' || p_region_code ||
--                     ' into element #1');
    open l_get_custom_list_csr(p_region_application_id, p_region_code, p_custom_appl_id, p_custom_code);
    loop
      fetch l_get_custom_list_csr into
        p_custom_pk_tbl(1).custom_appl_id,
        p_custom_pk_tbl(1).custom_code,
        p_custom_pk_tbl(1).region_appl_id,
        p_custom_pk_tbl(1).region_code;
      exit when l_get_custom_list_csr%notfound;
    end loop;
    close l_get_custom_list_csr;
    return;
  end if;

  --
  -- otherwise, insert the region to the end of the table if it is
  -- not already in the table. If it is already in the table, return
  -- without changing the table.
  --
  for l_custom_rec in l_get_custom_list_csr(p_region_application_id, p_region_code, p_custom_appl_id, p_custom_code) loop
  for l_index in p_custom_pk_tbl.FIRST .. p_custom_pk_tbl.LAST loop
    if (p_custom_pk_tbl.exists(l_index)) then
      if (p_custom_pk_tbl(l_index).region_appl_id = l_custom_rec.region_application_id)
         and
         (p_custom_pk_tbl(l_index).region_code = l_custom_rec.region_code)
 	 and
	 (p_custom_pk_tbl(l_index).custom_appl_id = l_custom_rec.customization_application_id)
	 and
	 (p_custom_pk_tbl(l_index).custom_code = l_custom_rec.customization_code) then
          return;
        end if;
      end if;
    end loop;

--dbms_output.put_line('Inserted region: ' || p_region_code ||
--                     ' into element #' || to_char(p_region_pk_tbl.LAST + 1));
  l_index := p_custom_pk_tbl.LAST + 1;
  p_custom_pk_tbl(l_index).region_appl_id := l_custom_rec.region_application_id;
  p_custom_pk_tbl(l_index).region_code := l_custom_rec.region_code;
  p_custom_pk_tbl(l_index).custom_appl_id := l_custom_rec.customization_application_id;
  p_custom_pk_tbl(l_index).custom_code := l_custom_rec.customization_code;
  end loop;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;
end INSERT_CUSTOM_PK_TABLE;

--=======================================================
--  Procedure   WRITE_CUSTOM_TO_BUFFER (local procedure)
--
--  Usage       Local procedure for writing the given customization
--              and all its children records to the output file.
--              Not designed to be called from outside this package.
--
--  Desc        This procedure first retreives and writes the given
--              customization to the loader file. Then it calls other local
--              procedure to write all its region items to the same output
--              file.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters
--              p_region_application_id : IN required
--              p_region_code : IN required
--                  Key value of the Region to be extracted to the loader
--                  file.
--              p_nls_language : IN required
--                  The NLS langauge that should be used when
--                  extracting data from the TL table
--=======================================================
procedure WRITE_CUSTOM_TO_BUFFER (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_region_application_id    IN      NUMBER,
  p_region_code              IN      VARCHAR2,
  p_custom_application_id    IN      NUMBER,
  p_custom_code              IN      VARCHAR2,
  p_nls_language             IN      VARCHAR2
) is
  cursor l_get_custom_csr is
    select *
    from  AK_CUSTOMIZATIONS
    where REGION_APPLICATION_ID = p_region_application_id
    and   REGION_CODE = p_region_code
    and   CUSTOMIZATION_APPLICATION_ID = p_custom_application_id
    and   CUSTOMIZATION_CODE = p_custom_code;
  cursor l_get_custom_tl_csr is
    select *
    from  AK_CUSTOMIZATIONS_TL
    where REGION_APPLICATION_ID = p_region_application_id
    and   REGION_CODE = p_region_code
    and   CUSTOMIZATION_APPLICATION_ID = p_custom_application_id
    and   CUSTOMIZATION_CODE = p_custom_code
    and   LANGUAGE = p_nls_language;
  l_api_name           CONSTANT varchar2(30) := 'Write_Custom_to_buffer';
  l_databuffer_tbl     AK_ON_OBJECTS_PUB.Buffer_Tbl_Type;
  l_index              NUMBER;
  l_custom_rec        AK_CUSTOMIZATIONS%ROWTYPE;
  l_custom_tl_rec     AK_CUSTOMIZATIONS_TL%ROWTYPE;
  l_return_status      varchar2(1);
begin
  -- Retrieve customization information from the database

  open l_get_custom_csr;
  fetch l_get_custom_csr into l_custom_rec;
  if (l_get_custom_csr%notfound) then
    close l_get_custom_csr;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
      FND_MESSAGE.SET_NAME('AK','AK_CUSTOM_DOES_NOT_EXIST');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||' '||
                                p_region_code ||' '||
                                to_char(p_custom_application_id) ||' '||
                                p_custom_code);
      FND_MSG_PUB.Add;
    end if;
    -- dbms_output.put_line('Cannot find customization '||p_custom_code);
    RAISE FND_API.G_EXC_ERROR;
  end if;
  close l_get_custom_csr;

  -- Retrieve custom TL information from the database

  open l_get_custom_tl_csr;
  fetch l_get_custom_tl_csr into l_custom_tl_rec;
  if (l_get_custom_tl_csr%notfound) then
    close l_get_custom_tl_csr;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
      FND_MESSAGE.SET_NAME('AK','AK_CUSTOM_TL_DOES_NOT_EXIST');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||' '||
                                p_region_code ||' '||
                                to_char(p_custom_application_id) ||' '||
                                p_custom_code);
      FND_MSG_PUB.Add;
    end if;
    --dbms_output.put_line('Cannot find custom TL '||p_custom_code);
    RAISE FND_API.G_EXC_ERROR;
  end if;
  close l_get_custom_tl_csr;

   -- Customization must be validated before it is written to the file
  if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
    if not AK_CUSTOM_PVT.VALIDATE_CUSTOM (
    p_validation_level => p_validation_level,
    p_api_version_number => 1.0,
    p_return_status => l_return_status,
    p_region_application_id => l_custom_rec.region_application_id,
    p_region_code => l_custom_rec.region_code,
    p_custom_application_id => l_custom_rec.customization_application_id,
    p_custom_code => l_custom_rec.customization_code,
    p_verticalization_id => l_custom_rec.verticalization_id,
    p_localization_code => l_custom_rec.localization_code,
    p_org_id => l_custom_rec.org_id,
    p_site_id => l_custom_rec.site_id,
    p_responsibility_id => l_custom_rec.responsibility_id,
    p_web_user_id => l_custom_rec.web_user_id,
    p_default_custom_flag => l_custom_rec.default_customization_flag,
    p_customization_level_id => l_custom_rec.customization_level_id,
    p_developer_mode => l_custom_rec.developer_mode,
    p_reference_path => l_custom_rec.reference_path,
    p_function_name => l_custom_rec.function_name,
    p_start_date_active => l_custom_rec.start_date_active,
    p_end_date_active => l_custom_rec.end_date_active,
    p_name => l_custom_tl_rec.name,
    p_description => l_custom_tl_rec.description,
    p_caller => AK_ON_OBJECTS_PVT.G_DOWNLOAD
    )
    then
    --  dbms_output.put_line('Custom ' || p_custom_code
    --  || ' not downloaded due to validation error');
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
        FND_MESSAGE.SET_NAME('AK','AK_CUSTOM_NOT_DOWNLOADED');
        FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||' '||
                                   p_region_code ||' '||
				   to_char(p_custom_application_id) ||' '||
				   p_custom_code);
        FND_MSG_PUB.Add;
      end if;
      raise FND_API.G_EXC_ERROR;
    end if; /* if AK_CUSTOM_PVT.VALIDATE_CUSTOM */
  end if; /* if p_validation_level */

  -- Write customization into buffer
  l_index := 1;

  l_databuffer_tbl(l_index) := 'BEGIN CUSTOMIZATION "' ||
    nvl(to_char(p_custom_application_id), '') || '" "' ||
    AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(p_custom_code) || '" "'||
    nvl(to_char(p_region_application_id), '') || '" "' ||
    AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(p_region_code) || '"';
  if ((l_custom_rec.verticalization_id IS NOT NULL) and
     (l_custom_rec.verticalization_id <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  VERTICALIZATION_ID = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_custom_rec.verticalization_id) || '"';
  end if;
  if ((l_custom_rec.localization_code IS NOT NULL) and
     (l_custom_rec.localization_code <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  LOCALIZATION_CODE = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_custom_rec.localization_code) || '"';
  end if;
  if ((l_custom_rec.org_id IS NOT NULL) and
     (l_custom_rec.org_id <> FND_API.G_MISS_NUM)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  ORG_ID = "' ||
      nvl(to_char(l_custom_rec.org_id), '') || '"';
  end if;
  if ((l_custom_rec.site_id IS NOT NULL) and
     (l_custom_rec.site_id <> FND_API.G_MISS_NUM)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  SITE_ID = "' ||
      nvl(to_char(l_custom_rec.site_id), '') || '"';
  end if;
  if ((l_custom_rec.responsibility_id IS NOT NULL) and
     (l_custom_rec.responsibility_id <> FND_API.G_MISS_NUM)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  RESPONSIBILITY_ID = "' ||
      nvl(to_char(l_custom_rec.responsibility_id), '') || '"';
  end if;
  if ((l_custom_rec.web_user_id IS NOT NULL) and
     (l_custom_rec.web_user_id <> FND_API.G_MISS_NUM)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  WEB_USER_ID = "' ||
      nvl(to_char(l_custom_rec.web_user_id), '') || '"';
  end if;
  if ((l_custom_rec.default_customization_flag IS NOT NULL) and
     (l_custom_rec.default_customization_flag <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  CUSTOMIZATION_FLAG = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_custom_rec.default_customization_flag) || '"';
  end if;
  if ((l_custom_rec.customization_level_id IS NOT NULL) and
     (l_custom_rec.customization_level_id <> FND_API.G_MISS_NUM)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  CUSTOMIZATION_LEVEL_ID = "' ||
      nvl(to_char(l_custom_rec.customization_level_id), '') || '"';
  end if;
  if ((l_custom_rec.developer_mode IS NOT NULL) and
     (l_custom_rec.developer_mode <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  DEVELOPER_MODE = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_custom_rec.developer_mode) || '"';
  end if;
  if ((l_custom_rec.reference_path IS NOT NULL) and
     (l_custom_rec.reference_path <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  REFERENCE_PATH = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_custom_rec.reference_path) || '"';
  end if;
  if ((l_custom_rec.function_name IS NOT NULL) and
     (l_custom_rec.function_name <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  FUNCTION_NAME = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_custom_rec.function_name) || '"';
  end if;
  if ((l_custom_rec.start_date_active IS NOT NULL) and
     (l_custom_rec.start_date_active <> FND_API.G_MISS_DATE)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  START_DATE_ACTIVE = "' ||
                 to_char(l_custom_rec.start_date_active,
                         AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
  end if;
  if ((l_custom_rec.end_date_active IS NOT NULL) and
     (l_custom_rec.end_date_active <> FND_API.G_MISS_DATE)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  END_DATE_ACTIVE = "' ||
                 to_char(l_custom_rec.end_date_active,
                         AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
  end if;
  -- - Write out who columns
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  CREATED_BY = "' ||
                nvl(to_char(l_custom_rec.created_by),'') || '"';
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  CREATION_DATE = "' ||
                to_char(l_custom_rec.creation_date,
                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
    l_index := l_index + 1;
-- CHANGED TO OWNER FOR R12
--    l_databuffer_tbl(l_index) := '  LAST_UPDATED_BY = "' ||
--                nvl(to_char(l_custom_rec.last_updated_by),'') || '"';A
    l_databuffer_tbl(l_index) := '  OWNER = "' ||
                FND_LOAD_UTIL.OWNER_NAME(l_custom_rec.last_updated_by) || '"';
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  LAST_UPDATE_DATE = "' ||
                to_char(l_custom_rec.last_update_date,
                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  LAST_UPDATE_LOGIN = "' ||
                nvl(to_char(l_custom_rec.last_update_login),'') || '"';

  -- translation columns
  --
  if ((l_custom_tl_rec.name IS NOT NULL) and
     (l_custom_tl_rec.name <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  NAME = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_custom_tl_rec.name) || '"';
  end if;
  if ((l_custom_tl_rec.description  IS NOT NULL) and
     (l_custom_tl_rec.description <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  DESCRIPTION = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_custom_tl_rec.description) || '"';
  end if;

  -- - Write the custom data to the specified file
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

  l_databuffer_tbl.delete;

  WRITE_CUST_REGION_TO_BUFFER (
    p_validation_level => p_validation_level,
    p_return_status => l_return_status,
    p_custom_application_id => l_custom_rec.customization_application_id,
    p_custom_code => l_custom_rec.customization_code,
    p_region_application_id => l_custom_rec.region_application_id,
    p_region_code => l_custom_rec.region_code,
    p_nls_language => p_nls_language
  );
  --
  -- Download aborts if validation fails in WRITE_CUST_REGION_TO_BUFFER
  --
  if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
     (l_return_status = FND_API.G_RET_STS_ERROR) then
    RAISE FND_API.G_EXC_ERROR;
  end if;

  WRITE_CUST_REG_ITEM_TO_BUFFER (
    p_validation_level => p_validation_level,
    p_return_status => l_return_status,
    p_custom_application_id => l_custom_rec.customization_application_id,
    p_custom_code => l_custom_rec.customization_code,
    p_region_application_id => l_custom_rec.region_application_id,
    p_region_code => l_custom_rec.region_code,
    p_nls_language => p_nls_language
  );
  --
  -- Download aborts if validation fails in WRITE_CUST_REG_ITEM_TO_BUFFER
  --
  if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
     (l_return_status = FND_API.G_RET_STS_ERROR) then
    RAISE FND_API.G_EXC_ERROR;
  end if;

  WRITE_CRITERIA_TO_BUFFER (
    p_validation_level => p_validation_level,
    p_return_status => l_return_status,
    p_custom_application_id => l_custom_rec.customization_application_id,
    p_custom_code => l_custom_rec.customization_code,
    p_region_application_id => l_custom_rec.region_application_id,
    p_region_code => l_custom_rec.region_code,
    p_nls_language => p_nls_language
  );
  --
  -- Download aborts if validation fails in WRITE_CRITERIA_TO_BUFFER
  --
  if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
     (l_return_status = FND_API.G_RET_STS_ERROR) then
    RAISE FND_API.G_EXC_ERROR;
  end if;

  l_index := 1;
  l_databuffer_tbl(l_index) := 'END CUSTOMIZATION';
  l_index := l_index + 1;
  l_databuffer_tbl(l_index) := ' ';

  -- - Write the 'END CUSTOMIZATION' to the specified file
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
      FND_MESSAGE.SET_NAME('AK','AK_CUSTOM_VALUE_ERROR');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
                                   ' ' || p_region_code || ' ' ||
				to_char(p_custom_application_id) ||
				   ' ' || p_custom_code);
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_CUSTOM_NOT_DOWNLOADED');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
                                   ' ' || p_region_code || ' ' ||
				   to_char(p_custom_application_id) ||
					' ' || p_custom_code);
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;
end WRITE_CUSTOM_TO_BUFFER;

--=======================================================
--  Procedure   WRITE_CUST_REGION_TO_BUFFER (local procedure)
--
--  Usage       Local procedure for writing the given customization
--		region to the output file.
--              Not designed to be called from outside this package.
--
--  Desc        This procedure first retreives and writes the given
--              customization regions to the loader file. Then it calls other
--		local procedure to write all its region items to the same
--              output file.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters
--              p_region_application_id : IN required
--              p_region_code : IN required
--                  Key value of the Region to be extracted to the loader
--                  file.
--              p_nls_language : IN required
--                  The NLS langauge that should be used when
--                  extracting data from the TL table
--=======================================================
procedure WRITE_CUST_REGION_TO_BUFFER (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_region_application_id    IN      NUMBER,
  p_region_code              IN      VARCHAR2,
  p_custom_application_id    IN      NUMBER,
  p_custom_code              IN      VARCHAR2,
  p_nls_language             IN      VARCHAR2
) is
  cursor l_get_cust_region_csr is
    select *
    from  AK_CUSTOM_REGIONS
    where REGION_APPLICATION_ID = p_region_application_id
    and   REGION_CODE = p_region_code
    and   CUSTOMIZATION_APPLICATION_ID = p_custom_application_id
    and   CUSTOMIZATION_CODE = p_custom_code;
  cursor l_get_cust_region_tl_csr(property_name_param varchar2) is
    select *
    from  AK_CUSTOM_REGIONS_TL
    where REGION_APPLICATION_ID = p_region_application_id
    and   REGION_CODE = p_region_code
    and   CUSTOMIZATION_APPLICATION_ID = p_custom_application_id
    and   CUSTOMIZATION_CODE = p_custom_code
    and   PROPERTY_NAME = property_name_param
    and   LANGUAGE = p_nls_language;
  l_api_name           CONSTANT varchar2(30) := 'Write_Cust_Region_to_buffer';
  l_databuffer_tbl     AK_ON_OBJECTS_PUB.Buffer_Tbl_Type;
  l_index              NUMBER;
  l_cust_region_rec    AK_CUSTOM_REGIONS%ROWTYPE;
  l_cust_region_tl_rec AK_CUSTOM_REGIONS_TL%ROWTYPE;
  l_return_status      varchar2(1);
  l_validation_level   NUMBER := FND_API.G_VALID_LEVEL_NONE;
begin
  -- Retrieve customization region information from the database

  open l_get_cust_region_csr;
  loop
    fetch l_get_cust_region_csr into l_cust_region_rec;
    exit when l_get_cust_region_csr%notfound;
    open l_get_cust_region_tl_csr(l_cust_region_rec.property_name);
    fetch l_get_cust_region_tl_csr into l_cust_region_tl_rec;
    if (l_get_cust_region_tl_csr%notfound) then
       if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
          FND_MESSAGE.SET_NAME('AK','AK_CUST_REG_TL_DOES_NOT_EXIST');
          FND_MESSAGE.SET_TOKEN('KEY', to_char(l_cust_region_rec.region_application_id) ||' '|| l_cust_region_rec.region_code ||' '|| to_char(l_cust_region_rec.customization_application_id) ||' '|| l_cust_region_rec.customization_code);
          FND_MSG_PUB.Add;
       end if;
    -- dbms_output.put_line('Cannot find customization '||p_custom_code);
       close l_get_cust_region_tl_csr;
       close l_get_cust_region_csr;
       RAISE FND_API.G_EXC_ERROR;
else
    -- write this customized region if it is validated
    if (p_validation_level <> FND_API.G_VALID_LEVEL_NONE) and
       not AK_CUSTOM_PVT.VALIDATE_CUST_REGION (
    	p_validation_level => p_validation_level,
    	p_api_version_number => 1.0,
    	p_return_status => l_return_status,
    	p_region_application_id => l_cust_region_rec.region_application_id,
    	p_region_code => l_cust_region_rec.region_code,
    	p_custom_application_id => l_cust_region_rec.customization_application_id,
    	p_custom_code => l_cust_region_rec.customization_code,
    	p_property_name => l_cust_region_rec.property_name,
    	p_property_varchar2_value => l_cust_region_rec.property_varchar2_value,
    	p_property_number_value => l_cust_region_rec.property_number_value,
    	p_criteria_join_condition => l_cust_region_rec.criteria_join_condition,
    	p_property_varchar2_value_tl => l_cust_region_tl_rec.property_varchar2_value,
    	p_caller => AK_ON_OBJECTS_PVT.G_DOWNLOAD) then
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
        close l_get_cust_region_tl_csr;
        close l_get_cust_region_csr;
        FND_MESSAGE.SET_NAME('AK','AK_CUST_REGION_NOT_DOWNLOADED');
        FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||' '||
                                   p_region_code ||' '||
                                   to_char(p_custom_application_id) ||' '||
                                   p_custom_code);
        FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
    end if; /* if AK_CUSTOM_PVT.VALIDATE_CUST_REGION */


  else
  l_index := 1;
  l_databuffer_tbl(l_index) := ' ';
  l_index := l_index + 1;
  l_databuffer_tbl(l_index) := '  BEGIN CUSTOM_REGION '|| '"' ||
    AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_cust_region_rec.property_name) || '"';
  if ((l_cust_region_rec.property_varchar2_value IS NOT NULL) and
     (l_cust_region_rec.property_varchar2_value <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '    PROPERTY_VARCHAR2_VALUE = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_cust_region_rec.property_varchar2_value) || '"';
  end if;
  if ((l_cust_region_rec.property_number_value IS NOT NULL) and
     (l_cust_region_rec.property_number_value <> FND_API.G_MISS_NUM)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '    PROPERTY_NUMBER_VALUE = "' ||
      nvl(to_char(l_cust_region_rec.property_number_value), '') || '"';
  end if;
  if ((l_cust_region_rec.criteria_join_condition IS NOT NULL) and
     (l_cust_region_rec.criteria_join_condition <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '    CRITERIA_JOIN_CONDITION = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_cust_region_rec.criteria_join_condition) || '"';
  end if;
  -- - Write out who columns
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  CREATED_BY = "' ||
                nvl(to_char(l_cust_region_rec.created_by),'') || '"';
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  CREATION_DATE = "' ||
                to_char(l_cust_region_rec.creation_date,
                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
    l_index := l_index + 1;
-- CHANGED TO OWNER FOR R12
--    l_databuffer_tbl(l_index) := '  LAST_UPDATED_BY = "' ||
--                nvl(to_char(l_cust_region_rec.last_updated_by),'') || '"';
    l_databuffer_tbl(l_index) := '  OWNER = "' ||
                FND_LOAD_UTIL.OWNER_NAME(l_cust_region_rec.last_updated_by) || '"';
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  LAST_UPDATE_DATE = "' ||
                to_char(l_cust_region_rec.last_update_date,
                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  LAST_UPDATE_LOGIN = "' ||
                nvl(to_char(l_cust_region_rec.last_update_login),'') || '"';
  -- translation columns
  --
  if ((l_cust_region_tl_rec.property_varchar2_value IS NOT NULL) and
     (l_cust_region_tl_rec.property_varchar2_value <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '    PROPERTY_VARCHAR2_VALUE_TL = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_cust_region_tl_rec.property_varchar2_value) || '"';
  end if;

      -- finish up customized regions
      l_index := l_index + 1;
      l_databuffer_tbl(l_index) := '  END CUSTOM_REGION';
--      l_index := l_index + 1;
--      l_databuffer_tbl(l_index) := ' ';

  -- - Write the custom region data to the specified file
  AK_ON_OBJECTS_PVT.WRITE_FILE (
    p_return_status => l_return_status,
    p_buffer_tbl => l_databuffer_tbl,
    p_write_mode => AK_ON_OBJECTS_PUB.G_APPEND
  );
  -- If API call returns with an error status...
  if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
     (l_return_status = FND_API.G_RET_STS_ERROR) then
    close l_get_cust_region_tl_csr;
    close l_get_cust_region_csr;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  l_databuffer_tbl.delete;
      end if; -- validation OK

    end if; -- if TL record found
    close l_get_cust_region_tl_csr;

  end loop;
  close l_get_cust_region_csr;

  p_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
  WHEN VALUE_ERROR THEN
     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_CUST_REGION_VALUE_ERROR');
        FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
                         ' ' || p_region_code ||
                         ' ' || to_char(p_custom_application_id) ||
			 ' ' || p_custom_code || ' ' ||
			 ' ' || l_cust_region_rec.property_name);
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
end WRITE_CUST_REGION_TO_BUFFER;

--=======================================================
--  Procedure   WRITE_CUST_REG_ITEM_TO_BUFFER (local procedure)
--
--  Usage       Local procedure for writing the given customization
--              region item to the output file.
--              Not designed to be called from outside this package.
--
--  Desc        This procedure first retreives and writes the given
--              customization regions to the loader file. Then it calls other
--              local procedure to write all its region items to the same
--              output file.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters
--              p_region_application_id : IN required
--              p_region_code : IN required
--                  Key value of the Region to be extracted to the loader
--                  file.
--              p_nls_language : IN required
--                  The NLS langauge that should be used when
--                  extracting data from the TL table
--=======================================================
procedure WRITE_CUST_REG_ITEM_TO_BUFFER (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_region_application_id    IN      NUMBER,
  p_region_code              IN      VARCHAR2,
  p_custom_application_id    IN      NUMBER,
  p_custom_code              IN      VARCHAR2,
  p_nls_language             IN      VARCHAR2
) is
  cursor l_get_cust_region_item_csr is
    select *
    from  AK_CUSTOM_REGION_ITEMS
    where REGION_APPLICATION_ID = p_region_application_id
    and   REGION_CODE = p_region_code
    and   CUSTOMIZATION_APPLICATION_ID = p_custom_application_id
    and   CUSTOMIZATION_CODE = p_custom_code;
  cursor l_get_cust_region_item_tl_csr(param_attr_appl_id number,
				param_attr_code varchar2,
				param_property_name varchar2) is
    select *
    from  AK_CUSTOM_REGION_ITEMS_TL
    where REGION_APPLICATION_ID = p_region_application_id
    and   REGION_CODE = p_region_code
    and   CUSTOMIZATION_APPLICATION_ID = p_custom_application_id
    and   CUSTOMIZATION_CODE = p_custom_code
    and   ATTRIBUTE_APPLICATION_ID = param_attr_appl_id
    and   ATTRIBUTE_CODE = param_attr_code
    and   PROPERTY_NAME = param_property_name
    and   LANGUAGE = p_nls_language;
  l_api_name           CONSTANT varchar2(30) := 'Write_Cust_Reg_Item_to_buffer';
  l_databuffer_tbl     AK_ON_OBJECTS_PUB.Buffer_Tbl_Type;
  l_index              NUMBER;
  l_cust_region_item_rec	AK_CUSTOM_REGION_ITEMS%ROWTYPE;
  l_cust_region_item_tl_rec 	AK_CUSTOM_REGION_ITEMS_TL%ROWTYPE;
  l_return_status      varchar2(1);
begin
  -- Retrieve customization region item information from the database

  open l_get_cust_region_item_csr;
  loop
    fetch l_get_cust_region_item_csr into l_cust_region_item_rec;
    exit when l_get_cust_region_item_csr%notfound;
    open l_get_cust_region_item_tl_csr(l_cust_region_item_rec.attribute_application_id, l_cust_region_item_rec.attribute_code,
	 		l_cust_region_item_rec.property_name);
    fetch l_get_cust_region_item_tl_csr into l_cust_region_item_tl_rec;
    if (l_get_cust_region_item_tl_csr%notfound) then
       if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
          FND_MESSAGE.SET_NAME('AK','AK_CUST_ITEM_TL_DOES_NOT_EXIST');
          FND_MESSAGE.SET_TOKEN('KEY', to_char(l_cust_region_item_rec.region_application_id) ||' '|| l_cust_region_item_rec.region_code
		||' '|| to_char(l_cust_region_item_rec.customization_application_id) ||' '|| l_cust_region_item_rec.customization_code
		||' '|| l_cust_region_item_rec.property_name);
          FND_MSG_PUB.Add;
       end if;
    -- dbms_output.put_line('Cannot find customization '||p_custom_code);
       close l_get_cust_region_item_tl_csr;
       close l_get_cust_region_item_csr;
       RAISE FND_API.G_EXC_ERROR;
else
    -- write this customized region item if it is validated
    if (p_validation_level <> FND_API.G_VALID_LEVEL_NONE) and
       not AK_CUSTOM_PVT.VALIDATE_CUST_REGION_ITEM (
        p_validation_level => p_validation_level,
        p_api_version_number => 1.0,
        p_return_status => l_return_status,
        p_region_application_id => l_cust_region_item_rec.region_application_id,
        p_region_code => l_cust_region_item_rec.region_code,
        p_custom_application_id => l_cust_region_item_rec.customization_application_id,
        p_custom_code => l_cust_region_item_rec.customization_code,
	p_attr_appl_id => l_cust_region_item_rec.attribute_application_id,
	p_attr_code => l_cust_region_item_rec.attribute_code,
	p_property_name => l_cust_region_item_rec.property_name,
	p_property_varchar2_value => l_cust_region_item_rec.property_varchar2_value,
	p_property_number_value => l_cust_region_item_rec.property_number_value,
	p_property_date_value => to_char(l_cust_region_item_rec.property_date_value),
        p_property_varchar2_value_tl => l_cust_region_item_rec.property_varchar2_value,
        p_caller => AK_ON_OBJECTS_PVT.G_DOWNLOAD) then
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
	close l_get_cust_region_item_tl_csr;
	close l_get_cust_region_item_csr;
        FND_MESSAGE.SET_NAME('AK','AK_CUSTOM_ITEM_NOT_DOWNLOADED');
        FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||' '||
                                   p_region_code ||' '||
                                   to_char(p_custom_application_id) ||' '||
                                   p_custom_code);
        FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
    end if; /* if AK_CUSTOM_PVT.VALIDATE_CUST_REGION_ITEM */

  else
  l_index := 1;
  l_databuffer_tbl(l_index) := ' ';
  l_index := l_index + 1;
  l_databuffer_tbl(l_index) := '  BEGIN CUSTOM_REGION_ITEM "'||
    l_cust_region_item_rec.attribute_application_id || '" "' ||
    AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_cust_region_item_rec.attribute_code) || '" "' ||
    AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_cust_region_item_rec.property_name) || '"';
  if ((l_cust_region_item_rec.property_varchar2_value IS NOT NULL) and
     (l_cust_region_item_rec.property_varchar2_value <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '    PROPERTY_VARCHAR2_VALUE = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_cust_region_item_rec.property_varchar2_value) || '"';
  end if;
  if ((l_cust_region_item_rec.property_number_value IS NOT NULL) and
     (l_cust_region_item_rec.property_number_value <> FND_API.G_MISS_NUM)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '    PROPERTY_NUMBER_VALUE = "' ||
      nvl(to_char(l_cust_region_item_rec.property_number_value), '') || '"';
  end if;
  if ((l_cust_region_item_rec.property_date_value IS NOT NULL) and
     (l_cust_region_item_rec.property_date_value <> FND_API.G_MISS_DATE)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '    PROPERTY_DATE_VALUE = "' ||
                 to_char(l_cust_region_item_rec.property_date_value,
                         AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
  end if;
  -- - Write out who columns
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  CREATED_BY = "' ||
                nvl(to_char(l_cust_region_item_rec.created_by),'') || '"';
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  CREATION_DATE = "' ||
                to_char(l_cust_region_item_rec.creation_date,
                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
    l_index := l_index + 1;
-- CHANGED TO OWNER FOR R12
--    l_databuffer_tbl(l_index) := '  LAST_UPDATED_BY = "' ||
--                nvl(to_char(l_cust_region_item_rec.last_updated_by),'') || '"';
    l_databuffer_tbl(l_index) := '  OWNER = "' ||
                FND_LOAD_UTIL.OWNER_NAME(l_cust_region_item_rec.last_updated_by) || '"';
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  LAST_UPDATE_DATE = "' ||
                to_char(l_cust_region_item_rec.last_update_date,
                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  LAST_UPDATE_LOGIN = "' ||
                nvl(to_char(l_cust_region_item_rec.last_update_login),'') || '"';

  -- translation columns
  --
  if ((l_cust_region_item_tl_rec.property_varchar2_value IS NOT NULL) and
     (l_cust_region_item_tl_rec.property_varchar2_value <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '    PROPERTY_VARCHAR2_VALUE_TL = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_cust_region_item_tl_rec.property_varchar2_value) || '"';
  end if;

      -- finish up customized region items
      l_index := l_index + 1;
      l_databuffer_tbl(l_index) := '  END CUSTOM_REGION_ITEM';
--      l_index := l_index + 1;
--      l_databuffer_tbl(l_index) := ' ';

  -- - Write the custom region item data to the specified file
  AK_ON_OBJECTS_PVT.WRITE_FILE (
    p_return_status => l_return_status,
    p_buffer_tbl => l_databuffer_tbl,
    p_write_mode => AK_ON_OBJECTS_PUB.G_APPEND
  );
  -- If API call returns with an error status...
  if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
     (l_return_status = FND_API.G_RET_STS_ERROR) then
    close l_get_cust_region_item_tl_csr;
    close l_get_cust_region_item_csr;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  l_databuffer_tbl.delete;
      end if; -- validation OK

    end if; -- if TL record found
    close l_get_cust_region_item_tl_csr;

  end loop;
  close l_get_cust_region_item_csr;

  p_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
  WHEN VALUE_ERROR THEN
     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_CUSTOM_ITEM_VALUE_ERROR');
        FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
                         ' ' || p_region_code ||
                         ' ' || to_char(p_custom_application_id) ||
                         ' ' || p_custom_code || ' ' ||
                         ' ' || l_cust_region_item_rec.property_name);
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
end WRITE_CUST_REG_ITEM_TO_BUFFER;

--=======================================================
--  Procedure   WRITE_CRITERIA_TO_BUFFER (local procedure)
--
--  Usage       Local procedure for writing the given customization
--              criteria to the output file.
--              Not designed to be called from outside this package.
--
--  Desc        This procedure first retreives and writes the given
--              customization regions to the loader file. Then it calls other
--              local procedure to write all its region items to the same
--              output file.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters
--              p_region_application_id : IN required
--              p_region_code : IN required
--                  Key value of the Region to be extracted to the loader
--                  file.
--              p_nls_language : IN required
--                  The NLS langauge that should be used when
--                  extracting data from the TL table
--=======================================================
procedure WRITE_CRITERIA_TO_BUFFER (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_region_application_id    IN      NUMBER,
  p_region_code              IN      VARCHAR2,
  p_custom_application_id    IN      NUMBER,
  p_custom_code              IN      VARCHAR2,
  p_nls_language             IN      VARCHAR2
) is
  cursor l_get_criteria_csr is
    select *
    from  AK_CRITERIA
    where REGION_APPLICATION_ID = p_region_application_id
    and   REGION_CODE = p_region_code
    and   CUSTOMIZATION_APPLICATION_ID = p_custom_application_id
    and   CUSTOMIZATION_CODE = p_custom_code;
  l_api_name           CONSTANT varchar2(30) := 'Write_Criteria_to_buffer';
  l_databuffer_tbl     AK_ON_OBJECTS_PUB.Buffer_Tbl_Type;
  l_index              NUMBER;
  l_criteria_rec       AK_CRITERIA%ROWTYPE;
  l_return_status      varchar2(1);
begin
  -- Retrieve customization criteria information from the database

  open l_get_criteria_csr;
  loop
    fetch l_get_criteria_csr into l_criteria_rec;
    exit when l_get_criteria_csr%notfound;
    if (p_validation_level <> FND_API.G_VALID_LEVEL_NONE) and
       not AK_CUSTOM_PVT.VALIDATE_CRITERIA (
        p_validation_level => p_validation_level,
        p_api_version_number => 1.0,
        p_return_status => l_return_status,
        p_region_application_id => l_criteria_rec.region_application_id,
        p_region_code => l_criteria_rec.region_code,
        p_custom_application_id => l_criteria_rec.customization_application_id,
        p_custom_code => l_criteria_rec.customization_code,
        p_attr_appl_id => l_criteria_rec.attribute_application_id,
        p_attr_code => l_criteria_rec.attribute_code,
        p_sequence_number => l_criteria_rec.sequence_number,
	p_operation => l_criteria_rec.operation,
	p_value_varchar2 => l_criteria_rec.value_varchar2,
	p_value_number => l_criteria_rec.value_number,
	p_value_date => to_char(l_criteria_rec.value_date),
        p_start_date_active => l_criteria_rec.start_date_active,
        p_end_date_active => l_criteria_rec.end_date_active,
        p_caller => AK_ON_OBJECTS_PVT.G_DOWNLOAD) then
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
        close l_get_criteria_csr;
        FND_MESSAGE.SET_NAME('AK','AK_CRITERIA_NOT_DOWNLOADED');
        FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||' '||
                                   p_region_code ||' '||
                                   to_char(p_custom_application_id) ||' '||
                                   p_custom_code);
        FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
    end if; /* if AK_CUSTOM_PVT.VALIDATE_CRITERIA */

  else
  l_index := 1;
  l_databuffer_tbl(l_index) := ' ';
  l_index := l_index + 1;
  l_databuffer_tbl(l_index) := '  BEGIN CRITERIA "'||
    l_criteria_rec.attribute_application_id || '" "' ||
    AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_criteria_rec.attribute_code) || '" ' ||
    l_criteria_rec.sequence_number;
  l_index := l_index + 1;
  l_databuffer_tbl(l_index) := '    OPERATION = "'||
        AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_criteria_rec.operation) || '"';
  if ((l_criteria_rec.value_varchar2 IS NOT NULL) and
     (l_criteria_rec.value_varchar2 <> FND_API.G_MISS_CHAR)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '    VALUE_VARCHAR2 = "' ||
      AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_criteria_rec.value_varchar2) || '"';
  end if;
  if ((l_criteria_rec.value_number  IS NOT NULL) and
     (l_criteria_rec.value_number <> FND_API.G_MISS_NUM)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '    VALUE_NUMBER = "' ||
      nvl(to_char(l_criteria_rec.value_number), '') || '"';
  end if;
  if ((l_criteria_rec.value_date IS NOT NULL) and
     (l_criteria_rec.value_date <> FND_API.G_MISS_DATE)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '    VALUE_DATE = "' ||
                 to_char(l_criteria_rec.value_date,
                         AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
  end if;
  if ((l_criteria_rec.start_date_active IS NOT NULL) and
     (l_criteria_rec.start_date_Active <> FND_API.G_MISS_DATE)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '    START_DATE_ACTIVE = "' ||
                 to_char(l_criteria_rec.start_date_active,
                         AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
  end if;
  if ((l_criteria_rec.end_date_active IS NOT NULL) and
     (l_criteria_rec.end_date_Active <> FND_API.G_MISS_DATE)) then
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '    END_DATE_ACTIVE = "' ||
                 to_char(l_criteria_rec.end_date_active,
                         AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
  end if;
  -- - Write out who columns
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  CREATED_BY = "' ||
                nvl(to_char(l_criteria_rec.created_by),'') || '"';
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  CREATION_DATE = "' ||
                to_char(l_criteria_rec.creation_date,
                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
    l_index := l_index + 1;
-- CHANGED TO OWNER FOR R12
--    l_databuffer_tbl(l_index) := '  LAST_UPDATED_BY = "' ||
--                nvl(to_char(l_criteria_rec.last_updated_by),'') || '"';
    l_databuffer_tbl(l_index) := '  OWNER = "' ||
                FND_LOAD_UTIL.OWNER_NAME(l_criteria_rec.last_updated_by) || '"';
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  LAST_UPDATE_DATE = "' ||
                to_char(l_criteria_rec.last_update_date,
                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  LAST_UPDATE_LOGIN = "' ||
                nvl(to_char(l_criteria_rec.last_update_login),'') || '"';



      -- finish up customized criteria
      l_index := l_index + 1;
      l_databuffer_tbl(l_index) := '  END CRITERIA';
--      l_index := l_index + 1;
--      l_databuffer_tbl(l_index) := ' ';

  -- - Write the custom criteria to the specified file
  AK_ON_OBJECTS_PVT.WRITE_FILE (
    p_return_status => l_return_status,
    p_buffer_tbl => l_databuffer_tbl,
    p_write_mode => AK_ON_OBJECTS_PUB.G_APPEND
  );
  -- If API call returns with an error status...
  if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
     (l_return_status = FND_API.G_RET_STS_ERROR) then
    close l_get_criteria_csr;
    RAISE FND_API.G_EXC_ERROR;
  end if;

      end if; -- validation OK

  end loop;
  close l_get_criteria_csr;

  p_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
  WHEN VALUE_ERROR THEN
     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_CRITERIA_VALUE_ERROR');
        FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
                         ' ' || p_region_code ||
                         ' ' || to_char(p_custom_application_id) ||
                         ' ' || p_custom_code || ' ' ||
                         ' ' || to_char(l_criteria_rec.sequence_number));
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
end WRITE_CRITERIA_TO_BUFFER;

--=======================================================
--  Function    VALIDATE_CUSTOM
--
--  Usage       Private API for validating a customization. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Perform validation on a region record.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              In addition, this function returns TRUE if all
--              validation tests are passed, or FALSE otherwise.
--  Parameters  Customization columns
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
function VALIDATE_CUSTOM (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_region_application_id    IN      NUMBER := FND_API.G_MISS_NUM,
  p_region_code              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_custom_application_id    IN      NUMBER := FND_API.G_MISS_NUM,
  p_custom_code              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_verticalization_id       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_localization_code        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_org_id		     IN      NUMBER := FND_API.G_MISS_NUM,
  p_site_id       	     IN      NUMBER := FND_API.G_MISS_NUM,
  p_responsibility_id	     IN      NUMBER := FND_API.G_MISS_NUM,
  p_web_user_id		     IN      NUMBER := FND_API.G_MISS_NUM,
  p_default_custom_flag	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_customization_level_id   IN      NUMBER := FND_API.G_MISS_NUM,
  p_developer_mode	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_reference_path	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_function_name	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_start_date_active	     IN      DATE := FND_API.G_MISS_DATE,
  p_end_date_active	     IN      DATE := FND_API.G_MISS_DATE,
  p_name		     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_description 	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_caller                   IN      VARCHAR2,
  p_pass                     IN      NUMBER := 2
) return BOOLEAN is
  l_api_version_number CONSTANT number := 1.0;
  l_api_name           CONSTANT varchar2(30) := 'Validate_Custom';
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

  if ((p_custom_application_id is null) or
      (p_custom_application_id = FND_API.G_MISS_NUM)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'CUSTOMIZATION_APPLICATION_ID');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_custom_code is null) or
      (p_custom_code = FND_API.G_MISS_CHAR)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'CUSTOMIZATION_CODE');
      FND_MSG_PUB.Add;
    end if;
  end if;

  --** check that required columns are not null and, unless calling  **
  --** from UPDATE procedure, the columns are not missing            **
  if ((p_customization_level_id is null) or
      (p_customization_level_id = FND_API.G_MISS_NUM and
       p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'CUSTOMIZATION_LEVEL_ID');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_start_date_active is null) or
      (p_start_date_active = FND_API.G_MISS_DATE and
       p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'START_DATE_ACTIVE');
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
  -- - Region application ID and Region Code
  if (NOT AK_REGION_PVT.REGION_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
	    p_region_application_id => p_region_application_id,
	    p_region_code => p_region_code)) then
     l_error := TRUE;
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
        FND_MESSAGE.SET_NAME('AK','AK_INVALID_REGION_REFERENCE');
        FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) || ' ' ||
					p_region_code);
        FND_MSG_PUB.Add;
      end if;
      --dbms_output.put_line(l_api_name || ' Invalid region');
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

end VALIDATE_CUSTOM;

--=======================================================
--  Function    VALIDATE_CUST_REGION
--
--  Usage       Private API for validating a custom region. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Perform validation on a custom region record.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              In addition, this function returns TRUE if all
--              validation tests are passed, or FALSE otherwise.
--  Parameters  Region graph columns
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
function VALIDATE_CUST_REGION (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_region_application_id    IN      NUMBER,
  p_region_code              IN      VARCHAR2,
  p_custom_application_id    IN      NUMBER,
  p_custom_code		     IN      VARCHAR2,
  p_property_name	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_property_varchar2_value  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_property_number_value    IN      NUMBER := FND_API.G_MISS_NUM,
  p_criteria_join_condition  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_property_varchar2_value_tl  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_caller                   IN      VARCHAR2,
  p_pass                     IN      NUMBER := 2
) return BOOLEAN is
  cursor l_check_custom_csr is
    select  1
    from    AK_CUSTOMIZATIONS
    where   region_application_id = p_region_application_id
    and     region_code = p_region_code
    and     customization_application_id = p_custom_application_id
    and     customization_code = p_custom_code;

  l_api_version_number      CONSTANT number := 1.0;
  l_api_name                CONSTANT varchar2(30) := 'Validate_Cust_Region';
  l_dummy                   NUMBER;
  l_error                   BOOLEAN;
  l_return_status           VARCHAR2(1);
  l_validation_level        NUMBER := FND_API.G_VALID_LEVEL_NONE;

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

  if ((p_custom_application_id is null) or
      (p_custom_application_id = FND_API.G_MISS_NUM)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'CUSTOM_APPLICATION_ID');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_custom_code is null) or
      (p_custom_code = FND_API.G_MISS_CHAR)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'CUSTOM_CODE');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_property_name is null) or
      (p_property_name = FND_API.G_MISS_CHAR)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'PROPERTY_NAME');
      FND_MSG_PUB.Add;
    end if;
  end if;

  -- - Check that the parent region exists
  open l_check_custom_csr;
  fetch l_check_custom_csr into l_dummy;
  if (l_check_custom_csr%notfound) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2
) then
      FND_MESSAGE.SET_NAME('AK','AK_INVALID_CUSTOM_REFERENCE');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
                           ' ' || p_region_code );
      FND_MSG_PUB.Add;
    end if;
    --dbms_output.put_line('Parent region does not exist!');
  end if;
  close l_check_custom_csr;

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

end VALIDATE_CUST_REGION;

--=======================================================
--  Function    VALIDATE_CUST_REGION_ITEM
--
--  Usage       Private API for validating a custom region item. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Perform validation on a custom region item record.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              In addition, this function returns TRUE if all
--              validation tests are passed, or FALSE otherwise.
--  Parameters  Custom region item columns
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
function VALIDATE_CUST_REGION_ITEM (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_region_application_id    IN      NUMBER,
  p_region_code              IN      VARCHAR2,
  p_custom_application_id    IN      NUMBER,
  p_custom_code              IN      VARCHAR2,
  p_attr_appl_id	     IN      NUMBER := FND_API.G_MISS_NUM,
  p_attr_code		     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_property_name	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_property_varchar2_value  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_property_number_value    IN      NUMBER := FND_API.G_MISS_NUM,
  p_property_date_value      IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_property_varchar2_value_tl  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_caller                   IN      VARCHAR2,
  p_pass                     IN      NUMBER := 2
) return BOOLEAN is
  cursor l_check_custom_csr is
    select  1
    from    AK_CUSTOMIZATIONS
    where   region_application_id = p_region_application_id
    and     region_code = p_region_code
    and     customization_application_id = p_custom_application_id
    and     customization_code = p_custom_code;

  l_api_version_number      CONSTANT number := 1.0;
  l_api_name                CONSTANT varchar2(30) := 'Validate_Cust_Region_Item';
  l_dummy                   NUMBER;
  l_error                   BOOLEAN;
  l_return_status           VARCHAR2(1);
  l_validation_level        NUMBER := FND_API.G_VALID_LEVEL_NONE;

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

  if ((p_custom_application_id is null) or
      (p_custom_application_id = FND_API.G_MISS_NUM)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'CUSTOM_APPLICATION_ID');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_custom_code is null) or
      (p_custom_code = FND_API.G_MISS_CHAR)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'CUSTOM_CODE');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_property_name is null) or
      (p_property_name = FND_API.G_MISS_CHAR)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'PROPERTY_NAME');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_attr_appl_id is null) or
      (p_attr_appl_id = FND_API.G_MISS_NUM)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'ATTRIBUTE_APPLICATION_ID');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_attr_code is null) or
      (p_attr_code = FND_API.G_MISS_CHAR)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'ATTRIBUTE_CODE');
      FND_MSG_PUB.Add;
    end if;
  end if;

  -- - Check that the parent region exists
  open l_check_custom_csr;
  fetch l_check_custom_csr into l_dummy;
  if (l_check_custom_csr%notfound) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_INVALID_CUSTOM_REFERENCE');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
                           ' ' || p_region_code );
      FND_MSG_PUB.Add;
    end if;
    --dbms_output.put_line('Parent region does not exist!');
  end if;
  close l_check_custom_csr;

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

end VALIDATE_CUST_REGION_ITEM;

--=======================================================
--  Function    VALIDATE_CRITERIA
--
--  Usage       Private API for validating a custom criteria. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Perform validation on a custom criteria record.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              In addition, this function returns TRUE if all
--              validation tests are passed, or FALSE otherwise.
--  Parameters  Criteria columns
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
function VALIDATE_CRITERIA (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_region_application_id    IN      NUMBER,
  p_region_code              IN      VARCHAR2,
  p_custom_application_id    IN      NUMBER,
  p_custom_code              IN      VARCHAR2,
  p_attr_appl_id	     IN      NUMBER := FND_API.G_MISS_NUM,
  p_attr_code		     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_sequence_number	     IN      NUMBER := FND_API.G_MISS_NUM,
  p_operation		     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_value_varchar2	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_value_number	     IN      NUMBER := FND_API.G_MISS_NUM,
  p_value_date		     IN      DATE := FND_API.G_MISS_DATE,
  p_start_date_active	     IN      DATE := FND_API.G_MISS_DATE,
  p_end_date_active	     IN      DATE := FND_API.G_MISS_DATE,
  p_caller                   IN      VARCHAR2,
  p_pass                     IN      NUMBER := 2
) return BOOLEAN is
  cursor l_check_custom_csr is
    select  1
    from    AK_CUSTOMIZATIONS
    where   region_application_id = p_region_application_id
    and     region_code = p_region_code
    and     customization_application_id = p_custom_application_id
    and     customization_code = p_custom_code;

  l_api_version_number      CONSTANT number := 1.0;
  l_api_name                CONSTANT varchar2(30) := 'Validate_Criteria';
  l_dummy                   NUMBER;
  l_error                   BOOLEAN;
  l_return_status           VARCHAR2(1);
  l_validation_level        NUMBER := FND_API.G_VALID_LEVEL_NONE;

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

  if ((p_custom_application_id is null) or
      (p_custom_application_id = FND_API.G_MISS_NUM)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'CUSTOM_APPLICATION_ID');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_custom_code is null) or
      (p_custom_code = FND_API.G_MISS_CHAR)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'CUSTOM_CODE');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_attr_appl_id is null) or
      (p_attr_appl_id = FND_API.G_MISS_NUM)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'ATTRIBUTE_APPLICATION_ID');
      FND_MSG_PUB.Add;
    end if;
  end if;

  if ((p_attr_code is null) or
      (p_attr_code  = FND_API.G_MISS_CHAR)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'ATTRIBUTE_CODE');
      FND_MSG_PUB.Add;
    end if;
  end if;

  --** check that required columns are not null and, unless calling  **
  --** from UPDATE procedure, the columns are not missing            **

  if ((p_start_date_active is null) or
      (p_start_date_active = FND_API.G_MISS_DATE and
       p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'START_DATE_ACTIVE');
      FND_MSG_PUB.Add;
    end if;
  end if;

  -- - Check that the parent region exists
  open l_check_custom_csr;
  fetch l_check_custom_csr into l_dummy;
  if (l_check_custom_csr%notfound) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_INVALID_CUSTOM_REFERENCE');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
                           ' ' || p_region_code );
      FND_MSG_PUB.Add;
    end if;
    --dbms_output.put_line('Parent region does not exist!');
  end if;
  close l_check_custom_csr;

  --** check that required columns are not null and, unless calling  **
  --** from UPDATE procedure, the columns are not missing            **

  if ((p_operation is null) or
      (p_operation = FND_API.G_MISS_CHAR and
       p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE)) then
    l_error := TRUE;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
      FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'OPERATION');
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

end VALIDATE_CRITERIA;

--=======================================================
--  Procedure   CREATE_CUSTOM
--
--  Usage       Private API for creating a region graph. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Creates a region graph using the given info.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region Item columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will create the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure CREATE_CUSTOM (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_init_msg_tbl             IN      BOOLEAN := FALSE,
  p_msg_count                OUT NOCOPY     NUMBER,
  p_msg_data                 OUT NOCOPY     VARCHAR2,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_custom_appl_id           IN      NUMBER,
  p_custom_code              IN      VARCHAR2,
  p_region_appl_id           IN      NUMBER,
  p_region_code              IN      VARCHAR2,
  p_verticalization_id       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_localization_code        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_org_id                   IN      NUMBER := FND_API.G_MISS_NUM,
  p_site_id                  IN      NUMBER := FND_API.G_MISS_NUM,
  p_responsibility_id        IN      NUMBER := FND_API.G_MISS_NUM,
  p_web_user_id              IN      NUMBER := FND_API.G_MISS_NUM,
  p_default_customization_flag  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_customization_level_id   IN      NUMBER := FND_API.G_MISS_NUM,
  p_developer_mode	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_reference_path           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_function_name	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_start_date_active	     IN      DATE := FND_API.G_MISS_DATE,
  p_end_date_active	     IN      DATE := FND_API.G_MISS_DATE,
  p_name                     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_description              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_created_by               IN      NUMBER := FND_API.G_MISS_NUM,
  p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
  p_last_updated_by          IN      NUMBER := FND_API.G_MISS_NUM,
  p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
  p_last_update_login        IN      NUMBER := FND_API.G_MISS_NUM,
  p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
  p_pass                     IN      NUMBER,
  p_copy_redo_flag           IN OUT NOCOPY  BOOLEAN
) is
  l_api_version_number      CONSTANT number := 1.0;
  l_api_name                CONSTANT varchar2(30) := 'Create_Custom';
  l_created_by                  NUMBER;
  l_creation_date               DATE;
  l_last_update_date            DATE;
  l_last_update_login           NUMBER;
  l_last_updated_by             NUMBER;
  l_description		        VARCHAR2(2000);
  l_name		        VARCHAR2(80);
  l_end_date_active		DATE;
  l_start_date_active		DATE;
  l_reference_path		VARCHAR2(100);
  l_function_name		VARCHAR2(30);
  l_customization_level_id	NUMBER;
  l_developer_mode		VARCHAR2(1);
  l_default_customization_flag	VARCHAR2(1);
  l_web_user_id			NUMBER;
  l_responsibility_id		NUMBER;
  l_site_id			NUMBER;
  l_org_id			NUMBER;
  l_localization_code		VARCHAR2(150);
  l_verticalization_id		VARCHAR2(150);
  l_return_status               VARCHAR2(1);
  l_lang                        VARCHAR2(30);
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

  savepoint start_create_custom;

  --** check to see if row already exists **
  if AK_CUSTOM_PVT.CUSTOM_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_custom_appl_id => p_custom_appl_id,
            p_custom_code => p_custom_code,
            p_region_application_id => p_region_appl_id,
            p_region_code => p_region_code) then
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
        FND_MESSAGE.SET_NAME('AK','AK_CUSTOM_EXISTS');
        FND_MSG_PUB.Add;
      end if;
      --dbms_output.put_line(l_api_name || 'Error - row already exists');
      raise FND_API.G_EXC_ERROR;
  end if;

  --** validate table columns passed in **
  if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
    if not VALIDATE_CUSTOM (
    p_validation_level => p_validation_level,
    p_api_version_number => p_api_version_number,
    p_return_status => p_return_status,
    p_region_application_id => p_region_appl_id,
    p_region_code => p_region_code,
    p_custom_application_id => p_custom_appl_id,
    p_custom_code => p_custom_code,
    p_verticalization_id => p_verticalization_id,
    p_localization_code => p_localization_code,
    p_org_id => p_org_id,
    p_site_id => p_site_id,
    p_responsibility_id => p_responsibility_id,
    p_web_user_id => p_web_user_id,
    p_default_custom_flag => p_default_customization_flag,
    p_customization_level_id => p_customization_level_id,
    p_developer_mode => p_developer_mode,
    p_reference_path => p_reference_path,
    p_function_name => p_function_name,
    p_start_date_active => p_start_date_active,
    p_end_date_active => p_end_date_active,
    p_name => p_name,
    p_description => p_description,
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

  --** Load non-required columns if their values are given **
  if (p_verticalization_id <> FND_API.G_MISS_CHAR) then
    l_verticalization_id := p_verticalization_id;
  end if;

  if (p_localization_code <> FND_API.G_MISS_CHAR) then
    l_localization_code := p_localization_code;
  end if;

  if (p_org_id <> FND_API.G_MISS_NUM) then
    l_org_id := p_org_id;
  end if;

  if (p_site_id <> FND_API.G_MISS_NUM) then
    l_site_id := p_site_id;
  end if;

  if (p_responsibility_id <> FND_API.G_MISS_NUM) then
    l_responsibility_id := p_responsibility_id;
  end if;

  if (p_web_user_id <> FND_API.G_MISS_NUM) then
    l_web_user_id := p_web_user_id;
  end if;

  if (p_default_customization_flag <> FND_API.G_MISS_CHAR) then
    l_default_customization_flag := p_default_customization_flag;
  end if;

  if (p_end_date_active <> FND_API.G_MISS_DATE) then
    l_end_date_active := p_end_date_active;
  end if;

  if (p_reference_path <> FND_API.G_MISS_CHAR) then
    l_reference_path := p_reference_path;
  end if;

  if (p_function_name <> FND_API.G_MISS_CHAR) then
    l_function_name := p_function_name;
  end if;

  if (p_description <> FND_API.G_MISS_CHAR) then
    l_description := p_description;
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

  select userenv('LANG') into l_lang
  from dual;

  insert into AK_CUSTOMIZATIONS (
    CUSTOMIZATION_APPLICATION_ID,
    CUSTOMIZATION_CODE,
    REGION_APPLICATION_ID,
    REGION_CODE,
    VERTICALIZATION_ID,
    LOCALIZATION_CODE,
    ORG_ID,
    SITE_ID,
    RESPONSIBILITY_ID,
    WEB_USER_ID,
    DEFAULT_CUSTOMIZATION_FLAG,
    CUSTOMIZATION_LEVEL_ID,
    DEVELOPER_MODE,
    REFERENCE_PATH,
    FUNCTION_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE
  ) values (
    p_custom_appl_id,
    p_custom_code,
    p_region_appl_id,
    p_region_code,
    l_verticalization_id,
    l_localization_code,
    l_org_id,
    l_site_id,
    l_responsibility_id,
    l_web_user_id,
    l_default_customization_flag,
    p_customization_level_id,
    p_developer_mode,
    l_reference_path,
    l_function_name,
    l_created_by,
    l_creation_date,
    l_last_update_date,
    l_last_updated_by,
    l_last_update_login,
    p_start_date_active,
    l_end_date_active);

  --** row should exists before inserting rows for other languages **
    if NOT AK_CUSTOM_PVT.CUSTOM_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_custom_appl_id => p_custom_appl_id,
            p_custom_code => p_custom_code,
            p_region_application_id => p_region_appl_id,
            p_region_code => p_region_code) then

      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
        FND_MESSAGE.SET_NAME('AK','AK_INSERT_CUSTOM_FAILED');
        FND_MSG_PUB.Add;
      end if;
      --dbms_output.put_line(l_api_name || 'Error - row already exists');
      raise FND_API.G_EXC_ERROR;
    end if;

  insert into AK_CUSTOMIZATIONS_TL (
    CUSTOMIZATION_APPLICATION_ID,
    CUSTOMIZATION_CODE,
    REGION_APPLICATION_ID,
    REGION_CODE,
    NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN
  ) select
    p_custom_appl_id,
    p_custom_code,
    p_region_appl_id,
    p_region_code,
    p_name,
    l_description,
    L.LANGUAGE_CODE,
    decode(L.LANGUAGE_CODE, l_lang, L.LANGUAGE_CODE, l_lang),
    l_created_by,
    l_creation_date,
    l_last_updated_by,
    l_last_update_date,
    l_last_update_login
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AK_CUSTOMIZATIONS_TL T
    where T.CUSTOMIZATION_APPLICATION_ID = p_custom_appl_id
    and T.CUSTOMIZATION_CODE = p_custom_code
    and T.REGION_APPLICATION_ID = p_region_appl_id
    and T.REGION_CODE = p_region_code
    and T.LANGUAGE = L.LANGUAGE_CODE);

--  /** commit the insert **/
  commit;

  if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
    FND_MESSAGE.SET_NAME('AK','AK_CUSTOM_CREATED');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'AK_LC_CUSTOM',TRUE);
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_custom_appl_id) ||
				' ' || p_custom_code || ' ' || 							to_char(p_region_appl_id) || ' ' ||						p_region_code || ' ' || p_name);
    FND_MSG_PUB.Add;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);

EXCEPTION
  WHEN VALUE_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_CUSTOM_VALUE_ERROR');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_custom_appl_id) ||
                                   ' ' || p_custom_code || ' ' ||
                                   to_char(p_region_appl_id) || ' ' ||
                                   p_region_code ||
                                   ' ' || p_name);
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
    rollback to start_create_custom;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
  WHEN FND_API.G_EXC_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_CUSTOM_NOT_CREATED');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_custom_appl_id) ||
                                   ' ' || p_custom_code || ' ' ||
                                   to_char(p_region_appl_id) || ' ' ||
                                   p_region_code ||
                                   ' ' || p_name);
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
    rollback to start_create_custom;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    rollback to start_create_custom;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
end CREATE_CUSTOM;

--=======================================================
--  Procedure   CREATE_CUST_REGION
--
--  Usage       Private API for creating a region graph. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Creates a region graph using the given info.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region Item columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will create the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure CREATE_CUST_REGION (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_init_msg_tbl             IN      BOOLEAN := FALSE,
  p_msg_count                OUT NOCOPY     NUMBER,
  p_msg_data                 OUT NOCOPY     VARCHAR2,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_custom_appl_id           IN      NUMBER,
  p_custom_code              IN      VARCHAR2,
  p_region_appl_id           IN      NUMBER,
  p_region_code              IN      VARCHAR2,
  p_property_name	     IN      VARCHAR2,
  p_property_varchar2_value  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_property_number_value    IN      NUMBER := FND_API.G_MISS_NUM,
  p_criteria_join_condition    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_property_varchar2_value_tl  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_created_by               IN      NUMBER := FND_API.G_MISS_NUM,
  p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
  p_last_updated_by          IN      NUMBER := FND_API.G_MISS_NUM,
  p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
  p_last_update_login        IN      NUMBER := FND_API.G_MISS_NUM,
  p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
  p_pass                     IN      NUMBER,
  p_copy_redo_flag           IN OUT NOCOPY  BOOLEAN
) is
  l_api_version_number      CONSTANT number := 1.0;
  l_api_name                CONSTANT varchar2(30) := 'Create_Cust_Region';
  l_created_by                  NUMBER;
  l_creation_date               DATE;
  l_last_update_date            DATE;
  l_last_update_login           NUMBER;
  l_last_updated_by             NUMBER;
  l_property_varchar2_value     VARCHAR2(2000);
  l_criteria_join_condition     VARCHAR2(3);
  l_property_number_value       NUMBER;
  l_property_varchar2_value_tl     VARCHAR2(2000);
  l_return_status               VARCHAR2(1);
  l_lang                        VARCHAR2(30);
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

  savepoint start_create_cust_region;

  --** check to see if row already exists **
  if AK_CUSTOM_PVT.CUST_REGION_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_custom_appl_id => p_custom_appl_id,
            p_custom_code => p_custom_code,
            p_region_application_id => p_region_appl_id,
            p_region_code => p_region_code,
            p_property_name => p_property_name) then
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
        FND_MESSAGE.SET_NAME('AK','AK_CUST_REGION_EXISTS');
        FND_MSG_PUB.Add;
      end if;
      --dbms_output.put_line(l_api_name || 'Error - row already exists');
      raise FND_API.G_EXC_ERROR;
  end if;

  --** validate table columns passed in **
  if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
    if not VALIDATE_CUST_REGION (
    p_validation_level => p_validation_level,
    p_api_version_number => p_api_version_number,
    p_return_status => p_return_status,
    p_region_application_id => p_region_appl_id,
    p_region_code => p_region_code,
    p_custom_application_id => p_custom_appl_id,
    p_custom_code => p_custom_code,
    p_property_name => p_property_name,
    p_property_varchar2_value => p_property_varchar2_value,
    p_property_number_value => p_property_number_value,
    p_criteria_join_condition => p_criteria_join_condition,
    p_property_varchar2_value_tl => p_property_varchar2_value,
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

  --** Load non-required columns if their values are given **
  if (p_property_varchar2_value <> FND_API.G_MISS_CHAR) then
    l_property_varchar2_value := p_property_varchar2_value;
  end if;

  if (p_property_number_value <> FND_API.G_MISS_NUM) then
    l_property_number_value := p_property_number_value;
  end if;

  if (p_criteria_join_condition <> FND_API.G_MISS_CHAR) then
    l_criteria_join_condition := p_criteria_join_condition;
  end if;

  if (p_property_varchar2_value_tl <> FND_API.G_MISS_CHAR) then
    l_property_varchar2_value_tl := p_property_varchar2_value_tl;
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

  select userenv('LANG') into l_lang
  from dual;

  insert into AK_CUSTOM_REGIONS (
    CUSTOMIZATION_APPLICATION_ID,
    CUSTOMIZATION_CODE,
    REGION_APPLICATION_ID,
    REGION_CODE,
    PROPERTY_NAME,
    PROPERTY_VARCHAR2_VALUE,
    PROPERTY_NUMBER_VALUE,
    CRITERIA_JOIN_CONDITION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN
  ) values (
    p_custom_appl_id,
    p_custom_code,
    p_region_appl_id,
    p_region_code,
    p_property_name,
    l_property_varchar2_value,
    l_property_number_value,
    l_criteria_join_condition,
    l_created_by,
    l_creation_date,
    l_last_updated_by,
    l_last_update_date,
    l_last_update_login);

  --** row should exists before inserting rows for other languages **
    if NOT AK_CUSTOM_PVT.CUST_REGION_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_custom_appl_id => p_custom_appl_id,
            p_custom_code => p_custom_code,
            p_region_application_id => p_region_appl_id,
            p_region_code => p_region_code,
            p_property_name => p_property_name) then

      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
        FND_MESSAGE.SET_NAME('AK','AK_INSERT_CUST_REGION_FAILED');
        FND_MSG_PUB.Add;
      end if;
      --dbms_output.put_line(l_api_name || 'Error - row already exists');
      raise FND_API.G_EXC_ERROR;
    end if;

  insert into AK_CUSTOM_REGIONS_TL (
    CUSTOMIZATION_APPLICATION_ID,
    CUSTOMIZATION_CODE,
    REGION_APPLICATION_ID,
    REGION_CODE,
    PROPERTY_NAME,
    PROPERTY_VARCHAR2_VALUE,
    LANGUAGE,
    SOURCE_LANG,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN
  ) select
    p_custom_appl_id,
    p_custom_code,
    p_region_appl_id,
    p_region_code,
    p_property_name,
    l_property_varchar2_value,
    L.LANGUAGE_CODE,
    decode(L.LANGUAGE_CODE, l_lang, L.LANGUAGE_CODE, l_lang),
    l.created_by,
    l_creation_date,
    l_last_updated_by,
    l_last_update_date,
    l_last_update_login
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AK_CUSTOM_REGIONS_TL T
    where T.CUSTOMIZATION_APPLICATION_ID = p_custom_appl_id
    and T.CUSTOMIZATION_CODE = p_custom_code
    and T.REGION_APPLICATION_ID = p_region_appl_id
    and T.REGION_CODE = p_region_code
    and T.PROPERTY_NAME = p_property_name
    and T.LANGUAGE = L.LANGUAGE_CODE);

--  /** commit the insert **/
  commit;

  if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
    FND_MESSAGE.SET_NAME('AK','AK_CUST_REGION_CREATED');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'AK_LC_CUST_REGION',TRUE);
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_custom_appl_id) ||
                                   ' ' || p_custom_code || ' ' ||
                                   to_char(p_region_appl_id) || ' ' ||
                                   p_region_code ||
                                   ' ' || p_property_name);
    FND_MSG_PUB.Add;
  end if;
  p_return_status := FND_API.G_RET_STS_SUCCESS;

  FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);

EXCEPTION
  WHEN VALUE_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_CUST_REGION_VALUE_ERROR');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_custom_appl_id) ||
                                   ' ' || p_custom_code || ' ' ||
                                   to_char(p_region_appl_id) || ' ' ||
                                   p_region_code ||
                                   ' ' || p_property_name);
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
    rollback to start_create_cust_region;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
  WHEN FND_API.G_EXC_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_CUST_REGION_NOT_CREATED');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_custom_appl_id) ||
                                   ' ' || p_custom_code || ' ' ||
                                   to_char(p_region_appl_id) || ' ' ||
                                   p_region_code ||
                                   ' ' || p_property_name);
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
    rollback to start_create_cust_region;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    rollback to start_create_cust_region;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
end CREATE_CUST_REGION;

--=======================================================
--  Procedure   CREATE_CUST_REG_ITEM
--
--  Usage       Private API for creating a region graph. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Creates a region graph using the given info.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region Item columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will create the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure CREATE_CUST_REG_ITEM (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_init_msg_tbl             IN      BOOLEAN := FALSE,
  p_msg_count                OUT NOCOPY     NUMBER,
  p_msg_data                 OUT NOCOPY     VARCHAR2,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_custom_appl_id           IN      NUMBER,
  p_custom_code              IN      VARCHAR2,
  p_region_appl_id           IN      NUMBER,
  p_region_code              IN      VARCHAR2,
  p_attr_appl_id	     IN      NUMBER,
  p_attr_code		     IN      VARCHAR2,
  p_property_name	     IN      VARCHAR2,
  p_property_varchar2_value  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_property_number_value    IN      NUMBER := FND_API.G_MISS_NUM,
  p_property_date_value      IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_property_varchar2_value_tl  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_created_by               IN      NUMBER := FND_API.G_MISS_NUM,
  p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
  p_last_updated_by          IN      NUMBER := FND_API.G_MISS_NUM,
  p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
  p_last_update_login        IN      NUMBER := FND_API.G_MISS_NUM,
  p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
  p_pass                     IN      NUMBER,
  p_copy_redo_flag           IN OUT NOCOPY  BOOLEAN
) is
  l_api_version_number      CONSTANT number := 1.0;
  l_api_name                CONSTANT varchar2(30) := 'Create_Cust_Reg_Item';
  l_created_by                  NUMBER;
  l_creation_date               DATE;
  l_last_update_date            DATE;
  l_last_update_login           NUMBER;
  l_last_updated_by             NUMBER;
  l_property_varchar2_value     VARCHAR2(4000);
  l_property_date_value		DATE;
  l_property_number_value       NUMBER;
  l_property_varchar2_value_tl     VARCHAR2(4000);
  l_return_status               VARCHAR2(1);
  l_lang                        VARCHAR2(30);
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

  savepoint start_create_cust_reg_item;

  --** check to see if row already exists **
  if AK_CUSTOM_PVT.CUST_REG_ITEM_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_custom_appl_id => p_custom_appl_id,
            p_custom_code => p_custom_code,
            p_region_application_id => p_region_appl_id,
            p_region_code => p_region_code,
	    p_attribute_appl_id => p_attr_appl_id,
            p_attribute_code => p_attr_code,
            p_property_name => p_property_name) then
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
        FND_MESSAGE.SET_NAME('AK','AK_CUST_REG_ITEM_EXISTS');
        FND_MSG_PUB.Add;
      end if;
      --dbms_output.put_line(l_api_name || 'Error - row already exists');
      raise FND_API.G_EXC_ERROR;
  end if;

  --** validate table columns passed in **
  if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
    if not VALIDATE_CUST_REGION_ITEM (
    p_validation_level => p_validation_level,
    p_api_version_number => p_api_version_number,
    p_return_status => p_return_status,
    p_region_application_id => p_region_appl_id,
    p_region_code => p_region_code,
    p_custom_application_id => p_custom_appl_id,
    p_custom_code => p_custom_code,
    p_attr_appl_id => p_attr_appl_id,
    p_attr_code => p_attr_code,
    p_property_name => p_property_name,
    p_property_varchar2_value => p_property_varchar2_value,
    p_property_number_value => p_property_number_value,
    p_property_date_value => p_property_date_value,
        p_property_varchar2_value_tl => p_property_varchar2_value_tl,
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

  --** Load non-required columns if their values are given **
  if (p_property_varchar2_value <> FND_API.G_MISS_CHAR) then
    l_property_varchar2_value := p_property_varchar2_value;
  end if;

  if (p_property_number_value <> FND_API.G_MISS_NUM) then
    l_property_number_value := p_property_number_value;
  end if;

  if (p_property_date_value <> FND_API.G_MISS_CHAR) then
    l_property_date_value := p_property_date_value;
  end if;

    if (p_property_varchar2_value_tl <> FND_API.G_MISS_CHAR) then
    l_property_varchar2_value_tl := p_property_varchar2_value_tl;
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

  select userenv('LANG') into l_lang
  from dual;

  insert into AK_CUSTOM_REGION_ITEMS (
    CUSTOMIZATION_APPLICATION_ID,
    CUSTOMIZATION_CODE,
    REGION_APPLICATION_ID,
    REGION_CODE,
    ATTRIBUTE_APPLICATION_ID,
    ATTRIBUTE_CODE,
    PROPERTY_NAME,
    PROPERTY_VARCHAR2_VALUE,
    PROPERTY_NUMBER_VALUE,
    PROPERTY_DATE_VALUE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN
  ) values (
    p_custom_appl_id,
    p_custom_code,
    p_region_appl_id,
    p_region_code,
    p_attr_appl_id,
    p_attr_code,
    p_property_name,
    l_property_varchar2_value,
    l_property_number_value,
    l_property_date_value,
    l_created_by,
    l_creation_date,
    l_last_updated_by,
    l_last_update_date,
    l_last_update_login);

  --** row should exists before inserting rows for other languages **
    if NOT AK_CUSTOM_PVT.CUST_REG_ITEM_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_custom_appl_id => p_custom_appl_id,
            p_custom_code => p_custom_code,
            p_region_application_id => p_region_appl_id,
            p_region_code => p_region_code,
	    p_attribute_appl_id => p_attr_appl_id,
	    p_attribute_code => p_attr_code,
            p_property_name => p_property_name) then

      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
        FND_MESSAGE.SET_NAME('AK','AK_INSERT_CUST_REG_ITEM_FAILED');
        FND_MSG_PUB.Add;
      end if;
      --dbms_output.put_line(l_api_name || 'Error - row already exists');
      raise FND_API.G_EXC_ERROR;
    end if;

  insert into AK_CUSTOM_REGION_ITEMS_TL (
    CUSTOMIZATION_APPLICATION_ID,
    CUSTOMIZATION_CODE,
    REGION_APPLICATION_ID,
    REGION_CODE,
    ATTRIBUTE_APPLICATION_ID,
    ATTRIBUTE_CODE,
    PROPERTY_NAME,
    PROPERTY_VARCHAR2_VALUE,
    LANGUAGE,
    SOURCE_LANG,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN
  ) select
    p_custom_appl_id,
    p_custom_code,
    p_region_appl_id,
    p_region_code,
    p_attr_appl_id,
    p_attr_code,
    p_property_name,
    l_property_varchar2_value_tl,
    L.LANGUAGE_CODE,
    decode(L.LANGUAGE_CODE, l_lang, L.LANGUAGE_CODE, l_lang),
    l.created_by,
    l_creation_date,
    l_last_updated_by,
    l_last_update_date,
    l_last_update_login
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AK_CUSTOM_REGION_ITEMS_TL T
    where T.CUSTOMIZATION_APPLICATION_ID = p_custom_appl_id
    and T.CUSTOMIZATION_CODE = p_custom_code
    and T.REGION_APPLICATION_ID = p_region_appl_id
    and T.REGION_CODE = p_region_code
    and T.ATTRIBUTE_APPLICATION_ID = p_attr_appl_id
    and T.ATTRIBUTE_CODE = p_attr_code
    and T.PROPERTY_NAME = p_property_name
    and T.LANGUAGE = L.LANGUAGE_CODE);

--  /** commit the insert **/
  commit;

  if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
    FND_MESSAGE.SET_NAME('AK','AK_CUST_REG_ITEM_CREATED');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'AK_LC_CUST_REG_ITEM',TRUE);
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_custom_appl_id) ||
                                   ' ' || p_custom_code || ' ' ||
                                   to_char(p_region_appl_id) || ' ' ||
                                   p_region_code || ' ' ||
				   to_char(p_attr_appl_id) || ' ' ||
				   p_attr_code || ' ' || p_property_name);
    FND_MSG_PUB.Add;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);

EXCEPTION
  WHEN VALUE_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_CUST_REG_ITEM_VALUE_ERROR');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_custom_appl_id) ||
                                   ' ' || p_custom_code || ' ' ||
                                   to_char(p_region_appl_id) || ' ' ||
                                   p_region_code || ' ' ||
                                   to_char(p_attr_appl_id) || ' ' ||
                                   p_attr_code || ' ' || p_property_name);
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
    rollback to start_create_cust_reg_item;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
  WHEN FND_API.G_EXC_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_CUST_REG_ITEM_NOT_CREATED');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_custom_appl_id) ||
                                   ' ' || p_custom_code || ' ' ||
                                   to_char(p_region_appl_id) || ' ' ||
                                   p_region_code || ' ' ||
                                   to_char(p_attr_appl_id) || ' ' ||
                                   p_attr_code || ' ' || p_property_name);
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
    rollback to start_create_cust_reg_item;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    rollback to start_create_cust_reg_item;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
end CREATE_CUST_REG_ITEM;

--=======================================================
--  Procedure   CREATE_CRITERIA
--
--  Usage       Private API for creating a region graph. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Creates a region graph using the given info.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region Item columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will create the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure CREATE_CRITERIA (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_init_msg_tbl             IN      BOOLEAN := FALSE,
  p_msg_count                OUT NOCOPY     NUMBER,
  p_msg_data                 OUT NOCOPY     VARCHAR2,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_custom_appl_id           IN      NUMBER,
  p_custom_code              IN      VARCHAR2,
  p_region_appl_id           IN      NUMBER,
  p_region_code              IN      VARCHAR2,
  p_attr_appl_id             IN      NUMBER,
  p_attr_code                IN      VARCHAR2,
  p_sequence_number	     IN      NUMBER,
  p_operation		     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_value_varchar2	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_value_number	     IN      NUMBER := FND_API.G_MISS_NUM,
  p_value_date		     IN      DATE := FND_API.G_MISS_DATE,
  p_start_date_active	     IN      DATE := FND_API.G_MISS_DATE,
  p_end_date_active	     IN      DATE := FND_API.G_MISS_DATE,
  p_created_by               IN      NUMBER := FND_API.G_MISS_NUM,
  p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
  p_last_updated_by          IN      NUMBER := FND_API.G_MISS_NUM,
  p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
  p_last_update_login        IN      NUMBER := FND_API.G_MISS_NUM,
  p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
  p_pass                     IN      NUMBER,
  p_copy_redo_flag           IN OUT NOCOPY  BOOLEAN
) is
  l_api_version_number      CONSTANT number := 1.0;
  l_api_name                CONSTANT varchar2(30) := 'Create_Criteria';
  l_created_by                  NUMBER;
  l_creation_date               DATE;
  l_last_update_date            DATE;
  l_last_update_login           NUMBER;
  l_last_updated_by             NUMBER;
  l_value_varchar2		VARCHAR2(240);
  l_value_number		NUMBER;
  l_value_date			DATE;
  l_start_date_active 	        DATE;
  l_end_date_active	        DATE;
  l_return_status               VARCHAR2(1);
  l_lang                        VARCHAR2(30);
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

  savepoint start_create_criteria;

  --** check to see if row already exists **
  if AK_CUSTOM_PVT.CRITERIA_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_custom_appl_id => p_custom_appl_id,
            p_custom_code => p_custom_code,
            p_region_application_id => p_region_appl_id,
            p_region_code => p_region_code,
            p_attribute_appl_id => p_attr_appl_id,
            p_attribute_code => p_attr_code,
	    p_sequence_number => p_sequence_number) then
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
        FND_MESSAGE.SET_NAME('AK','AK_CRITERIA_EXISTS');
        FND_MSG_PUB.Add;
      end if;
      --dbms_output.put_line(l_api_name || 'Error - row already exists');
      raise FND_API.G_EXC_ERROR;
  end if;

  --** validate table columns passed in **
  if (p_validation_level <> FND_API.G_VALID_LEVEL_NONE) then
    if not VALIDATE_CRITERIA (
    p_validation_level => p_validation_level,
    p_api_version_number => p_api_version_number,
    p_return_status => p_return_status,
    p_region_application_id => p_region_appl_id,
    p_region_code => p_region_code,
    p_custom_application_id => p_custom_appl_id,
    p_custom_code => p_custom_code,
    p_attr_appl_id => p_attr_appl_id,
    p_attr_code => p_attr_code,
    p_sequence_number => p_sequence_number,
    p_operation => p_operation,
    p_value_varchar2 => p_value_varchar2,
    p_value_number => p_value_number,
    p_value_date => p_value_date,
    p_start_date_active => p_start_date_active,
    p_end_date_active => p_end_date_active,
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

  --** Load non-required columns if their values are given **
  if (p_value_varchar2 <> FND_API.G_MISS_CHAR) then
    l_value_varchar2 := p_value_varchar2;
  end if;

  if (p_value_number <> FND_API.G_MISS_NUM) then
    l_value_number := p_value_number;
  end if;

  if (p_value_date <> FND_API.G_MISS_DATE) then
    l_value_date := p_value_date;
  end if;

  if (p_end_date_active <> FND_API.G_MISS_DATE) then
    l_end_date_active := p_end_date_active;
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

  select userenv('LANG') into l_lang
  from dual;

  insert into AK_CRITERIA (
    CUSTOMIZATION_APPLICATION_ID,
    CUSTOMIZATION_CODE,
    REGION_APPLICATION_ID,
    REGION_CODE,
    ATTRIBUTE_APPLICATION_ID,
    ATTRIBUTE_CODE,
    SEQUENCE_NUMBER,
    OPERATION,
    VALUE_VARCHAR2,
    VALUE_NUMBER,
    VALUE_DATE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE
  ) values (
    p_custom_appl_id,
    p_custom_code,
    p_region_appl_id,
    p_region_code,
    p_attr_appl_id,
    p_attr_code,
    p_sequence_number,
    p_operation,
    l_value_varchar2,
    l_value_number,
    l_value_date,
    l_created_by,
    l_creation_date,
    l_last_updated_by,
    l_last_update_date,
    l_last_update_login,
    p_start_date_active,
    l_end_date_active);

--  /** commit the insert **/
  commit;

  if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
    FND_MESSAGE.SET_NAME('AK','AK_CRITERIA_CREATED');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'AK_LC_CRITERIA',TRUE);
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_custom_appl_id) ||
                                   ' ' || p_custom_code || ' ' ||
                                   to_char(p_region_appl_id) || ' ' ||
                                   p_region_code || ' ' ||
                                   to_char(p_attr_appl_id) || ' ' ||
                                   p_attr_code || ' ' || p_sequence_number);
    FND_MSG_PUB.Add;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);

EXCEPTION
  WHEN VALUE_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_CRITERIA_VALUE_ERROR');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_custom_appl_id) ||
                                   ' ' || p_custom_code || ' ' ||
                                   to_char(p_region_appl_id) || ' ' ||
                                   p_region_code || ' ' ||
                                   to_char(p_attr_appl_id) || ' ' ||
                                   p_attr_code || ' ' || p_sequence_number);
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
    rollback to start_create_criteria;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
  WHEN FND_API.G_EXC_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_CRITERIA_NOT_CREATED');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_custom_appl_id) ||
                                   ' ' || p_custom_code || ' ' ||
                                   to_char(p_region_appl_id) || ' ' ||
                                   p_region_code || ' ' ||
                                   to_char(p_attr_appl_id) || ' ' ||
                                   p_attr_code || ' ' || p_sequence_number);
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
    rollback to start_create_criteria;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    rollback to start_create_criteria;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
end CREATE_CRITERIA;

--=======================================================
--  Function    CUSTOM_EXISTS
--
--  Usage       Private API for checking for the existence of
--              a region graph with the given key values. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API check to see if a region graph record
--              exists with the given key values.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              This function will return TRUE if such an object
--              attribute exists, or FALSE otherwise.
--  Parameters  Region Graph key columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
function CUSTOM_EXISTS (
  p_api_version_number       IN      NUMBER,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_custom_appl_id	     IN      NUMBER,
  p_custom_code 	     IN      VARCHAR2,
  p_region_application_id    IN      NUMBER,
  p_region_code              IN      VARCHAR2
) return BOOLEAN is
  cursor l_check_csr is
    select 1
    from  AK_CUSTOMIZATIONS
    where region_application_id = p_region_application_id
    and   region_code = p_region_code
    and   customization_application_id = p_custom_appl_id
    and   customization_code = p_custom_code;
  l_api_version_number CONSTANT number := 1.0;
  l_api_name           CONSTANT varchar2(30) := 'Custom_Exists';
  l_dummy              number;
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

end CUSTOM_EXISTS;

--=======================================================
--  Function    CUST_REGION_EXISTS
--
--  Usage       Private API for checking for the existence of
--              a region graph with the given key values. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API check to see if a region graph record
--              exists with the given key values.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              This function will return TRUE if such an object
--              attribute exists, or FALSE otherwise.
--  Parameters  Region Graph key columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
function CUST_REGION_EXISTS (
  p_api_version_number       IN      NUMBER,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_custom_appl_id           IN      NUMBER,
  p_custom_code              IN      VARCHAR2,
  p_region_application_id    IN      NUMBER,
  p_region_code              IN      VARCHAR2,
  p_property_name	     IN      VARCHAR2
) return BOOLEAN is
  cursor l_check_csr is
    select 1
    from  AK_CUSTOM_REGIONS
    where region_application_id = p_region_application_id
    and   region_code = p_region_code
    and   customization_application_id = p_custom_appl_id
    and   customization_code = p_custom_code
    and   property_name = p_property_name;
  l_api_version_number CONSTANT number := 1.0;
  l_api_name           CONSTANT varchar2(30) := 'Cust_Region_Exists';
  l_dummy              number;
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

end CUST_REGION_EXISTS;

--=======================================================
--  Function    CUST_REG_ITEM_EXISTS
--
--  Usage       Private API for checking for the existence of
--              a region graph with the given key values. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API check to see if a region graph record
--              exists with the given key values.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              This function will return TRUE if such an object
--              attribute exists, or FALSE otherwise.
--  Parameters  Region Graph key columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
function CUST_REG_ITEM_EXISTS (
  p_api_version_number       IN      NUMBER,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_custom_appl_id           IN      NUMBER,
  p_custom_code              IN      VARCHAR2,
  p_region_application_id    IN      NUMBER,
  p_region_code              IN      VARCHAR2,
  p_attribute_appl_id	     IN      NUMBER,
  p_attribute_code	     IN      VARCHAR2,
  p_property_name            IN      VARCHAR2
) return BOOLEAN is
  cursor l_check_csr is
    select 1
    from  AK_CUSTOM_REGION_ITEMS
    where region_application_id = p_region_application_id
    and   region_code = p_region_code
    and   customization_application_id = p_custom_appl_id
    and   customization_code = p_custom_code
    and   attribute_application_id = p_attribute_appl_id
    and   attribute_code = p_attribute_code
    and   property_name = p_property_name;
  l_api_version_number CONSTANT number := 1.0;
  l_api_name           CONSTANT varchar2(30) := 'Cust_Reg_Item_Exists';
  l_dummy              number;
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

end CUST_REG_ITEM_EXISTS;

--=======================================================
--  Function    CRITERIA_EXISTS
--
--  Usage       Private API for checking for the existence of
--              a region graph with the given key values. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API check to see if a region graph record
--              exists with the given key values.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              This function will return TRUE if such an object
--              attribute exists, or FALSE otherwise.
--  Parameters  Region Graph key columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
function CRITERIA_EXISTS (
  p_api_version_number       IN      NUMBER,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_custom_appl_id           IN      NUMBER,
  p_custom_code              IN      VARCHAR2,
  p_region_application_id    IN      NUMBER,
  p_region_code              IN      VARCHAR2,
  p_attribute_appl_id	     IN      NUMBER,
  p_attribute_code	     IN      VARCHAR2,
  p_sequence_number	     IN      NUMBER
) return BOOLEAN is
  cursor l_check_csr is
    select 1
    from  AK_CRITERIA
    where region_application_id = p_region_application_id
    and   region_code = p_region_code
    and   customization_application_id = p_custom_appl_id
    and   customization_code = p_custom_code
    and   attribute_application_id = p_attribute_appl_id
    and   attribute_code = p_attribute_code
    and   sequence_number = p_sequence_number;
  l_api_version_number CONSTANT number := 1.0;
  l_api_name           CONSTANT varchar2(30) := 'Criteria_Exists';
  l_dummy              number;
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

end CRITERIA_EXISTS;

--=======================================================
--  Procedure   UPDATE_CUSTOM
--
--  Usage       Private API for updating a region graph.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API updates a region graph using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region Graph columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will update the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure UPDATE_CUSTOM (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_init_msg_tbl             IN      BOOLEAN := FALSE,
  p_msg_count                OUT NOCOPY     NUMBER,
  p_msg_data                 OUT NOCOPY     VARCHAR2,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_custom_appl_id 	     IN      NUMBER,
  p_custom_code		     IN      VARCHAR2,
  p_region_application_id    IN      NUMBER,
  p_region_code              IN      VARCHAR2,
  p_verticalization_id	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_localization_code	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_org_id		     IN      NUMBER := FND_API.G_MISS_NUM,
  p_site_id		     IN      NUMBER := FND_API.G_MISS_NUM,
  p_responsibility_id	     IN      NUMBER := FND_API.G_MISS_NUM,
  p_web_user_id		     IN      NUMBER := FND_API.G_MISS_NUM,
  p_default_customization_flag   IN  VARCHAR2 := FND_API.G_MISS_CHAR,
  p_customization_level_id   IN      NUMBER := FND_API.G_MISS_NUM,
  p_developer_mode	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_reference_path	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_function_name 	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_start_date_active	     IN      DATE := FND_API.G_MISS_DATE,
  p_end_date_active	     IN      DATE := FND_API.G_MISS_DATE,
  p_name		     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_description		     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_created_by		     IN      NUMBER := FND_API.G_MISS_NUM,
  p_creation_date	     IN      DATE := FND_API.G_MISS_DATE,
  p_last_updated_by	     IN      NUMBER := FND_API.G_MISS_NUM,
  p_last_update_date	     IN      DATE := FND_API.G_MISS_DATE,
  p_last_update_login	     IN      NUMBER := FND_API.G_MISS_NUM,
  p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
  p_pass                     IN      NUMBER,
  p_copy_redo_flag           IN OUT NOCOPY  BOOLEAN
) is
  cursor l_get_row_csr is
    select *
    from  AK_CUSTOMIZATIONS
    where CUSTOMIZATION_APPLICATION_ID = p_custom_appl_id
    and   CUSTOMIZATION_CODE = p_custom_code
    and   REGION_APPLICATION_ID = p_region_application_id
    and   REGION_CODE = p_region_code
    for update of VERTICALIZATION_ID;
  cursor l_get_tl_row_csr (lang_parm varchar2) is
    select *
    from  AK_CUSTOMIZATIONS_TL
    where CUSTOMIZATION_APPLICATION_ID = p_custom_appl_id
    and   CUSTOMIZATION_CODE = p_custom_code
    and   REGION_APPLICATION_ID = p_region_application_id
    and   REGION_CODE = p_region_code
    and   LANGUAGE = lang_parm
    for update of name;
  l_api_version_number     CONSTANT number := 1.0;
  l_api_name               CONSTANT varchar2(30) := 'Update_Custom';
  l_created_by             number;
  l_creation_date          date;
  l_custom_rec		   ak_customizations%ROWTYPE;
  l_custom_tl_rec	   ak_customizations_tl%ROWTYPE;
  l_error                  boolean;
  l_lang                   varchar2(30);
  l_last_update_date       date;
  l_last_update_login      number;
  l_last_updated_by        number;
  l_return_status          varchar2(1);
  l_submit                                      varchar2(1) := 'N';
  l_encrypt                                     varchar2(1) := 'N';
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

  savepoint start_update_custom;

  select userenv('LANG') into l_lang
  from dual;

  --** retrieve ak_customizations row if it exists **
  open l_get_row_csr;
  fetch l_get_row_csr into l_custom_rec;
  if (l_get_row_csr%notfound) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
      FND_MESSAGE.SET_NAME('AK','AK_CUSTOM_DOES_NOT_EXIST');
      FND_MSG_PUB.Add;
    end if;
    --dbms_output.put_line(l_api_name || 'Error - Row does not exist');
    close l_get_row_csr;
    raise FND_API.G_EXC_ERROR;
  end if;
  close l_get_row_csr;

  --** retrieve ak_customizations_tl row if it exists **
  open l_get_tl_row_csr(l_lang);
  fetch l_get_tl_row_csr into l_custom_tl_rec;
  if (l_get_tl_row_csr%notfound) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
      FND_MESSAGE.SET_NAME('AK','AK_CUSTOM_NOT_EXIST');
      FND_MSG_PUB.Add;
    end if;
    -- dbms_output.put_line(l_api_name || 'Error - TL Row does not exist');
    close l_get_tl_row_csr;
    raise FND_API.G_EXC_ERROR;
  end if;
  close l_get_tl_row_csr;

  --
  -- validate table columns passed in
  --
  if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
    if not VALIDATE_CUSTOM (
	    p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_region_application_id => p_region_application_id,
            p_region_code => p_region_code,
	    p_custom_application_id => p_custom_appl_id,
	    p_custom_code => p_custom_code,
       	    p_verticalization_id => p_verticalization_id,
            p_localization_code => p_localization_code,
    	    p_org_id => p_org_id,
	    p_site_id => p_site_id,
	    p_responsibility_id => p_responsibility_id,
	    p_web_user_id => p_web_user_id,
	    p_default_custom_flag => p_default_customization_flag,
	    p_customization_level_id => p_customization_level_id,
	    p_developer_mode => p_developer_mode,
	    p_reference_path => p_reference_path,
	    p_function_name => p_function_name,
	    p_start_date_active => p_start_date_active,
	    p_end_date_active => p_end_date_active,
	    p_name => p_name,
	    p_description => p_description,
            p_caller => AK_ON_OBJECTS_PVT.G_UPDATE,
                        p_pass => p_pass
          ) then
      --dbms_output.put_line(l_api_name || ' validation failed');
      -- Do not raise an error if it's the first pass
          if (p_pass = 1) then
            p_copy_redo_flag := TRUE;
      else
        raise FND_API.G_EXC_ERROR;
      end if;
    end if;
  end if;

  --** Load record to be updated to the database **
  --** - first load nullable columns **

  if (p_verticalization_id <> FND_API.G_MISS_CHAR) or
     (p_verticalization_id is null) then
    l_custom_rec.verticalization_id := p_verticalization_id;
  end if;

  if (p_localization_code <> FND_API.G_MISS_CHAR) or
     (p_localization_code is null) then
    l_custom_rec.localization_code := p_localization_code;
  end if;

  if (p_org_id <> FND_API.G_MISS_NUM) or
     (p_org_id is null) then
    l_custom_rec.org_id := p_org_id;
  end if;

  if (p_site_id <> FND_API.G_MISS_NUM) or
     (p_site_id is null) then
    l_custom_rec.site_id := p_site_id;
  end if;

  if (p_responsibility_id <> FND_API.G_MISS_NUM) or
     (p_responsibility_id is null) then
    l_custom_rec.responsibility_id := p_responsibility_id;
  end if;

  if (p_web_user_id  <> FND_API.G_MISS_NUM) or
     (p_web_user_id is null) then
    l_custom_rec.web_user_id := p_web_user_id;
  end if;

  if (p_default_customization_flag <> FND_API.G_MISS_CHAR) or
     (p_default_customization_flag is null) then
    l_custom_rec.default_customization_flag := p_default_customization_flag;
  end if;

  if (p_end_date_active <> FND_API.G_MISS_DATE) or
     (p_end_date_active is null) then
    l_custom_rec.end_date_active := p_end_date_active;
  end if;

  if (p_description <> FND_API.G_MISS_CHAR) or
     (p_description is null) then
    l_custom_tl_rec.description := p_description;
  end if;

  if (p_developer_mode <> FND_API.G_MISS_CHAR) or
     (p_developer_mode is null) then
    l_custom_rec.developer_mode := p_developer_mode;
  end if;

  --** - next, load non-null columns **

  if (p_customization_level_id <> FND_API.G_MISS_NUM) then
    l_custom_rec.customization_level_id := p_customization_level_id;
  end if;

  if (p_start_date_Active <> FND_API.G_MISS_DATE) then
    l_custom_rec.start_date_Active := p_start_date_Active;
  end if;

  if (p_name <> FND_API.G_MISS_CHAR) then
    l_custom_tl_rec.name := p_name;
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

-- THIS UPDATES NO MATTER WHAT - CALLING IS_UPDATEABLE BECAUSE STILL
-- NECESSARY FOR PRE-12 CODE
  if AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
       p_loader_timestamp => p_loader_timestamp,
       p_created_by => l_created_by,
       p_creation_date => l_creation_date,
       p_last_updated_by => l_last_updated_by,
       p_db_last_updated_by => l_custom_rec.last_updated_by,
       p_last_update_date => l_last_update_date,
       p_db_last_update_date => l_custom_rec.last_update_date,
       p_last_update_login => l_last_update_login,
       p_create_or_update => 'UPDATE') then
     null;
  end if;

  -- added deletes for bug 2394151
  delete AK_CUSTOM_REGIONS
  where REGION_APPLICATION_ID = p_region_application_id
  and   REGION_CODE = p_region_code
  and   CUSTOMIZATION_APPLICATION_ID = p_custom_appl_id
  and   CUSTOMIZATION_CODE = p_custom_code;

  delete AK_CUSTOM_REGION_ITEMS
  where REGION_APPLICATION_ID = p_region_application_id
  and   REGION_CODE = p_region_code
  and   CUSTOMIZATION_APPLICATION_ID = p_custom_appl_id
  and   CUSTOMIZATION_CODE = p_custom_code;

  update AK_CUSTOMIZATIONS set
	VERTICALIZATION_ID = l_custom_rec.verticalization_id,
	LOCALIZATION_CODE = l_custom_rec.localization_code,
	ORG_ID = l_custom_rec.org_id,
	SITE_ID = l_custom_rec.site_id,
	RESPONSIBILITY_ID = l_custom_rec.responsibility_id,
	WEB_USER_ID = l_custom_rec.web_user_id,
	DEFAULT_CUSTOMIZATION_FLAG = l_custom_rec.default_customization_flag,
	CUSTOMIZATION_LEVEL_ID = l_custom_rec.customization_level_id,
	DEVELOPER_MODE = l_custom_rec.developer_mode,
        START_DATE_ACTIVE = l_custom_Rec.start_date_active,
        END_DATE_ACTIVE = l_custom_rec.end_date_active,
        LAST_UPDATE_DATE = l_last_update_date,
        LAST_UPDATED_BY = l_last_updated_by,
        LAST_UPDATE_LOGIN = l_last_update_login
  where REGION_APPLICATION_ID = p_region_application_id
  and   REGION_CODE = p_region_code
  and   CUSTOMIZATION_APPLICATION_ID = p_custom_appl_id
  and   CUSTOMIZATION_CODE = p_custom_code;
  if (sql%notfound) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_CUSTOM_UPDATE_FAILED');
      FND_MSG_PUB.Add;
    end if;
    -- dbms_output.put_line(l_api_name || 'Row does not exist during update');
    raise FND_API.G_EXC_ERROR;
  end if;

  delete AK_CUSTOM_REGIONS_TL
  where REGION_APPLICATION_ID = p_region_application_id
  and   REGION_CODE = p_region_code
  and   CUSTOMIZATION_APPLICATION_ID = p_custom_appl_id
  and   CUSTOMIZATION_CODE = p_custom_code;

  delete AK_CUSTOM_REGION_ITEMS_TL
  where REGION_APPLICATION_ID = p_region_application_id
  and   REGION_CODE = p_region_code
  and   CUSTOMIZATION_APPLICATION_ID = p_custom_appl_id
  and   CUSTOMIZATION_CODE = p_custom_code;

  update AK_CUSTOMIZATIONS_TL set
	NAME = l_custom_tl_rec.name,
	DESCRIPTION = l_custom_tl_rec.description,
      LAST_UPDATED_BY = l_last_updated_by,
      LAST_UPDATE_DATE = l_last_update_date,
      LAST_UPDATE_LOGIN = l_last_update_login,
          SOURCE_LANG = l_lang
  where REGION_APPLICATION_ID = p_region_application_id
  and   REGION_CODE = p_region_code
  and   CUSTOMIZATION_APPLICATION_ID = p_custom_appl_id
  and   CUSTOMIZATION_CODE = p_custom_code
  and   l_lang in (LANGUAGE, SOURCE_LANG);
  if (sql%notfound) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_CUSTOM_UPDATE_FAILED');
      FND_MSG_PUB.Add;
    end if;
    --dbms_output.put_line(l_api_name || 'TL Row does not exist during update');
    raise FND_API.G_EXC_ERROR;
  end if;

--  /** commit the update **/
--  commit;

  if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
    FND_MESSAGE.SET_NAME('AK','AK_CUSTOM_UPDATED');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
                                   ' ' || p_region_code ||
                                   ' ' || to_char(p_custom_appl_id) ||
				   ' ' || p_custom_code );
    FND_MSG_PUB.Add;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);

EXCEPTION
  WHEN VALUE_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_CUSTOM_VALUE_ERROR');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
                                   ' ' || p_region_code ||
                                   ' ' ||  to_char(p_custom_appl_id) ||
                                   ' ' || p_custom_code );
    FND_MSG_PUB.Add;
  end if;
    rollback to start_update_custom;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
  WHEN FND_API.G_EXC_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_CUSTOM_NOT_UPDATED');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
                                   ' ' || p_region_code ||
                                   ' ' || to_char(p_custom_appl_id) ||
                                   ' ' || p_custom_code );
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
    rollback to start_update_custom;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
end UPDATE_CUSTOM;

--=======================================================
--  Procedure   UPDATE_CUST_REGION
--
--  Usage       Private API for updating a region graph.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API updates a region graph using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region Graph columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will update the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure UPDATE_CUST_REGION (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_init_msg_tbl             IN      BOOLEAN := FALSE,
  p_msg_count                OUT NOCOPY     NUMBER,
  p_msg_data                 OUT NOCOPY     VARCHAR2,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_custom_appl_id           IN      NUMBER,
  p_custom_code              IN      VARCHAR2,
  p_region_application_id    IN      NUMBER,
  p_region_code              IN      VARCHAR2,
  p_property_name	     IN      VARCHAR2,
  p_property_varchar2_value  IN	     VARCHAR2 := FND_API.G_MISS_CHAR,
  p_property_number_value    IN      NUMBER := FND_API.G_MISS_NUM,
  p_criteria_join_condition  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_property_varchar2_value_tl  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_created_by			IN      NUMBER := FND_API.G_MISS_NUM,
  p_creation_date		IN      DATE := FND_API.G_MISS_DATE,
  p_last_updated_by		IN      NUMBER := FND_API.G_MISS_NUM,
  p_last_update_date		IN      DATE := FND_API.G_MISS_DATE,
  p_last_update_login		IN      NUMBER := FND_API.G_MISS_NUM,
  p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
  p_pass                     IN      NUMBER,
  p_copy_redo_flag           IN OUT NOCOPY  BOOLEAN
) is
  cursor l_get_row_csr is
    select *
    from  AK_CUSTOM_REGIONS
    where CUSTOMIZATION_APPLICATION_ID = p_custom_appl_id
    and   CUSTOMIZATION_CODE = p_custom_code
    and   REGION_APPLICATION_ID = p_region_application_id
    and   REGION_CODE = p_region_code
    and   PROPERTY_NAME = p_property_name
    for update of PROPERTY_VARCHAR2_VALUE;
  cursor l_get_tl_row_csr (lang_parm varchar2) is
    select *
    from  AK_CUSTOM_REGIONS_TL
    where CUSTOMIZATION_APPLICATION_ID = p_custom_appl_id
    and   CUSTOMIZATION_CODE = p_custom_code
    and   REGION_APPLICATION_ID = p_region_application_id
    and   REGION_CODE = p_region_code
    and   PROPERTY_NAME = p_property_name
    and   LANGUAGE = lang_parm
    for update of PROPERTY_VARCHAR2_VALUE;
  l_api_version_number     CONSTANT number := 1.0;
  l_api_name               CONSTANT varchar2(30) := 'Update_Custom';
  l_created_by             number;
  l_creation_date          date;
  l_cust_region_rec	   ak_custom_regions%ROWTYPE;
  l_cust_region_tl_rec	   ak_custom_regions_tl%ROWTYPE;
  l_error                  boolean;
  l_lang                   varchar2(30);
  l_last_update_date       date;
  l_last_update_login      number;
  l_last_updated_by        number;
  l_return_status          varchar2(1);
  l_submit                                      varchar2(1) := 'N';
  l_encrypt                                     varchar2(1) := 'N';
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

  savepoint start_update_cust_region;

  select userenv('LANG') into l_lang
  from dual;

  --** retrieve ak_custom_regions row if it exists **
  open l_get_row_csr;
  fetch l_get_row_csr into l_cust_region_rec;
  if (l_get_row_csr%notfound) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
      FND_MESSAGE.SET_NAME('AK','AK_CUST_REGION_DOES_NOT_EXIST');
      FND_MSG_PUB.Add;
    end if;
    --dbms_output.put_line(l_api_name || 'Error - Row does not exist');
    close l_get_row_csr;
    raise FND_API.G_EXC_ERROR;
  end if;
  close l_get_row_csr;

  --** retrieve ak_custom_regions_tl row if it exists **
  open l_get_tl_row_csr(l_lang);
  fetch l_get_tl_row_csr into l_cust_region_tl_rec;
  if (l_get_tl_row_csr%notfound) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
      FND_MESSAGE.SET_NAME('AK','AK_CUST_REGION_NOT_EXIST');
      FND_MSG_PUB.Add;
    end if;
    -- dbms_output.put_line(l_api_name || 'Error - TL Row does not exist');
    close l_get_tl_row_csr;
    raise FND_API.G_EXC_ERROR;
  end if;
  close l_get_tl_row_csr;

  --
  -- validate table columns passed in
  --
  if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
    if not VALIDATE_CUST_REGION (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_region_application_id => p_region_application_id,
            p_region_code => p_region_code,
            p_custom_application_id => p_custom_appl_id,
            p_custom_code => p_custom_code,
	    p_property_name => p_property_name,
	    p_property_varchar2_value => p_property_varchar2_value,
	    p_property_number_value => p_property_number_value,
	    p_criteria_join_condition => p_criteria_join_condition,
	    p_property_varchar2_value_tl => p_property_varchar2_value_tl,
            p_caller => AK_ON_OBJECTS_PVT.G_UPDATE,
                        p_pass => p_pass
          ) then
      --dbms_output.put_line(l_api_name || ' validation failed');
      -- Do not raise an error if it's the first pass
          if (p_pass = 1) then
            p_copy_redo_flag := TRUE;
      else
        raise FND_API.G_EXC_ERROR;
      end if;
    end if;
  end if;

  --** Load record to be updated to the database **
  --** - first load nullable columns **

  if (p_property_varchar2_value <> FND_API.G_MISS_CHAR) or
     (p_property_varchar2_value is null) then
   l_cust_region_rec.property_varchar2_value := p_property_varchar2_value;
  end if;

  if (p_property_number_value <> FND_API.G_MISS_NUM) or
     (p_property_number_value is null) then
   l_cust_region_rec.property_number_value := p_property_number_value;
  end if;

  if (p_criteria_join_condition <> FND_API.G_MISS_CHAR) or
     (p_criteria_join_condition is null) then
   l_cust_region_rec.criteria_join_condition := p_criteria_join_condition;
  end if;

  if (p_property_varchar2_value_tl <> FND_API.G_MISS_CHAR) or
     (p_property_varchar2_value_tl is null) then
   l_cust_region_tl_rec.property_varchar2_value := p_property_varchar2_value;
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

  --** - next, load non-null columns **

-- THIS UPDATES NO MATTER WHAT - CALLING IS_UPDATEABLE BECAUSE STILL
-- NECESSARY FOR PRE-12 CODE
  if AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
       p_loader_timestamp => p_loader_timestamp,
       p_created_by => l_created_by,
       p_creation_date => l_creation_date,
       p_last_updated_by => l_last_updated_by,
       p_db_last_updated_by => l_cust_region_rec.last_updated_by,
       p_last_update_date => l_last_update_date,
       p_db_last_update_date => l_cust_region_rec.last_update_date,
       p_last_update_login => l_last_update_login,
       p_create_or_update => 'UPDATE') then
     null;
  end if;

  update AK_CUSTOM_REGIONS set
	PROPERTY_VARCHAR2_VALUE = l_cust_region_rec.property_varchar2_value,
	PROPERTY_NUMBER_VALUE = l_cust_region_rec.property_number_value,
 	CRITERIA_JOIN_CONDITION = l_cust_region_rec.criteria_join_condition,
        LAST_UPDATE_DATE = l_last_update_date,
        LAST_UPDATED_BY = l_last_updated_by,
        LAST_UPDATE_LOGIN = l_last_update_login
  where REGION_APPLICATION_ID = p_region_application_id
  and   REGION_CODE = p_region_code
  and   CUSTOMIZATION_APPLICATION_ID = p_custom_appl_id
  and   CUSTOMIZATION_CODE = p_custom_code
  and   PROPERTY_NAME = p_property_name;
  if (sql%notfound) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_CUST_REGION_UPDATE_FAILED');
      FND_MSG_PUB.Add;
    end if;
    -- dbms_output.put_line(l_api_name || 'Row does not exist during update');
    raise FND_API.G_EXC_ERROR;
  end if;

  update AK_CUSTOM_REGIONS_TL set
	PROPERTY_VARCHAR2_VALUE = l_cust_region_tl_rec.property_varchar2_value,
        LAST_UPDATE_DATE = l_last_update_date,
        LAST_UPDATED_BY = l_last_updated_by,
        LAST_UPDATE_LOGIN = l_last_update_login,
          SOURCE_LANG = l_lang
  where REGION_APPLICATION_ID = p_region_application_id
  and   REGION_CODE = p_region_code
  and   CUSTOMIZATION_APPLICATION_ID = p_custom_appl_id
  and   CUSTOMIZATION_CODE = p_custom_code
  and   PROPERTY_NAME = p_property_name
  and   l_lang in (LANGUAGE, SOURCE_LANG);
  if (sql%notfound) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_CUST_REGION_UPDATE_FAILED');
      FND_MSG_PUB.Add;
    end if;
    --dbms_output.put_line(l_api_name || 'TL Row does not exist during update');
    raise FND_API.G_EXC_ERROR;
  end if;

--  /** commit the update **/
--  commit;

  if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
    FND_MESSAGE.SET_NAME('AK','AK_CUST_REGION_UPDATED');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
                                   ' ' || p_region_code ||
                                   ' ' || to_char(p_custom_appl_id) ||
                                   ' ' || p_custom_code || ' ' ||
				   p_property_name);
    FND_MSG_PUB.Add;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);

EXCEPTION
  WHEN VALUE_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_CUST_REGION_VALUE_ERROR');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
                                   ' ' || p_region_code ||
                                   ' ' ||  to_char(p_custom_appl_id) ||
                                   ' ' || p_custom_code || ' ' ||
                                   p_property_name);
    FND_MSG_PUB.Add;
  end if;
    rollback to start_update_cust_region;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
  WHEN FND_API.G_EXC_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_CUST_REGION_NOT_UPDATED');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
                                   ' ' || p_region_code ||
                                   ' ' || to_char(p_custom_appl_id) ||
                                   ' ' || p_custom_code || ' ' ||
                                   p_property_name);
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
    rollback to start_update_cust_region;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
end UPDATE_CUST_REGION;

--=======================================================
--  Procedure   UPDATE_CUST_REG_ITEM
--
--  Usage       Private API for updating a region graph.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API updates a region graph using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region Graph columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will update the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure UPDATE_CUST_REG_ITEM (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_init_msg_tbl             IN      BOOLEAN := FALSE,
  p_msg_count                OUT NOCOPY     NUMBER,
  p_msg_data                 OUT NOCOPY     VARCHAR2,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_custom_appl_id           IN      NUMBER,
  p_custom_code              IN      VARCHAR2,
  p_region_application_id    IN      NUMBER,
  p_region_code              IN      VARCHAR2,
  p_attribute_appl_id	     IN      NUMBER,
  p_attribute_code	     IN      VARCHAR2,
  p_property_name            IN      VARCHAR2,
  p_property_varchar2_value  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_property_number_value    IN      NUMBER := FND_API.G_MISS_NUM,
  p_property_date_value      IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_property_varchar2_value_tl  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_created_by               IN      NUMBER := FND_API.G_MISS_NUM,
  p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
  p_last_updated_by          IN      NUMBER := FND_API.G_MISS_NUM,
  p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
  p_last_update_login        IN      NUMBER := FND_API.G_MISS_NUM,
  p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
  p_pass                     IN      NUMBER,
  p_copy_redo_flag           IN OUT NOCOPY  BOOLEAN
) is
  cursor l_get_row_csr is
    select *
    from  AK_CUSTOM_REGION_ITEMS
    where CUSTOMIZATION_APPLICATION_ID = p_custom_appl_id
    and   CUSTOMIZATION_CODE = p_custom_code
    and   REGION_APPLICATION_ID = p_region_application_id
    and   REGION_CODE = p_region_code
    and   ATTRIBUTE_APPLICATION_ID = p_attribute_appl_id
    and   ATTRIBUTE_CODE = p_attribute_code
    and   PROPERTY_NAME = p_property_name
    for update of PROPERTY_VARCHAR2_VALUE;
  cursor l_get_tl_row_csr (lang_parm varchar2) is
    select *
    from  AK_CUSTOM_REGION_ITEMS_TL
    where CUSTOMIZATION_APPLICATION_ID = p_custom_appl_id
    and   CUSTOMIZATION_CODE = p_custom_code
    and   REGION_APPLICATION_ID = p_region_application_id
    and   REGION_CODE = p_region_code
    and   ATTRIBUTE_APPLICATION_ID = p_attribute_appl_id
    and   ATTRIBUTE_CODE = p_attribute_code
    and   PROPERTY_NAME = p_property_name
    and   LANGUAGE = lang_parm
    for update of PROPERTY_VARCHAR2_VALUE;
  l_api_version_number     CONSTANT number := 1.0;
  l_api_name               CONSTANT varchar2(30) := 'Update_Cust_Reg_Item';
  l_created_by             number;
  l_creation_date          date;
  l_cust_reg_item_rec      ak_custom_region_items%ROWTYPE;
  l_cust_reg_item_tl_rec   ak_custom_region_items_tl%ROWTYPE;
  l_error                  boolean;
  l_lang                   varchar2(30);
  l_last_update_date       date;
  l_last_update_login      number;
  l_last_updated_by        number;
  l_return_status          varchar2(1);
  l_submit                                      varchar2(1) := 'N';
  l_encrypt                                     varchar2(1) := 'N';
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

  savepoint start_update_cust_reg_item;

  select userenv('LANG') into l_lang
  from dual;

  --** retrieve ak_custom_region_items row if it exists **
  open l_get_row_csr;
  fetch l_get_row_csr into l_cust_reg_item_rec;
  if (l_get_row_csr%notfound) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
      FND_MESSAGE.SET_NAME('AK','AK_CUSTOM_ITEM_DOES_NOT_EXIST');
      FND_MSG_PUB.Add;
    end if;
    --dbms_output.put_line(l_api_name || 'Error - Row does not exist');
    close l_get_row_csr;
    raise FND_API.G_EXC_ERROR;
  end if;
  close l_get_row_csr;

  --** retrieve ak_custom_region_items_tl row if it exists **
  open l_get_tl_row_csr(l_lang);
  fetch l_get_tl_row_csr into l_cust_reg_item_tl_rec;
  if (l_get_tl_row_csr%notfound) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
      FND_MESSAGE.SET_NAME('AK','AK_CUSTOM_ITEM_DOES_NOT_EXIST');
      FND_MSG_PUB.Add;
    end if;
    -- dbms_output.put_line(l_api_name || 'Error - TL Row does not exist');
    close l_get_tl_row_csr;
    raise FND_API.G_EXC_ERROR;
  end if;
  close l_get_tl_row_csr;

  --
  -- validate table columns passed in
  --
  if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
    if not VALIDATE_CUST_REGION_ITEM (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_region_application_id => p_region_application_id,
            p_region_code => p_region_code,
            p_custom_application_id => p_custom_appl_id,
            p_custom_code => p_custom_code,
	    p_attr_appl_id => p_attribute_appl_id,
  	    p_attr_code => p_attribute_code,
   	    p_property_name => p_property_name,
            p_property_varchar2_value => p_property_varchar2_value,
            p_property_number_value => p_property_number_value,
	    p_property_date_value => p_property_date_value,
            p_property_varchar2_value_tl => p_property_varchar2_value_tl,
            p_caller => AK_ON_OBJECTS_PVT.G_UPDATE,
                        p_pass => p_pass
          ) then
      --dbms_output.put_line(l_api_name || ' validation failed');
      -- Do not raise an error if it's the first pass
          if (p_pass = 1) then
            p_copy_redo_flag := TRUE;
      else
        raise FND_API.G_EXC_ERROR;
      end if;
    end if;
  end if;

  --** Load record to be updated to the database **
  --** - first load nullable columns **

  if (p_property_varchar2_value <> FND_API.G_MISS_CHAR) or
     (p_property_varchar2_value is null) then
   l_cust_reg_item_rec.property_varchar2_value := p_property_varchar2_value;
  end if;

  if (p_property_number_value <> FND_API.G_MISS_NUM) or
     (p_property_number_value is null) then
   l_cust_reg_item_rec.property_number_value := p_property_number_value;
  end if;

  if (p_property_date_value <> FND_API.G_MISS_NUM) or
     (p_property_date_value is null) then
   l_cust_reg_item_rec.property_date_value := p_property_date_value;
  end if;

  if (p_property_varchar2_value_tl <> FND_API.G_MISS_CHAR) or
     (p_property_varchar2_value_tl is null) then
   l_cust_reg_item_tl_rec.property_varchar2_value := p_property_varchar2_value_tl;
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

  --** - next, load non-null columns **

-- THIS UPDATES NO MATTER WHAT - CALLING IS_UPDATEABLE BECAUSE STILL
-- NECESSARY FOR PRE-12 CODE
  if AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
       p_loader_timestamp => p_loader_timestamp,
       p_created_by => l_created_by,
       p_creation_date => l_creation_date,
       p_last_updated_by => l_last_updated_by,
       p_db_last_updated_by => l_cust_reg_item_rec.last_updated_by,
       p_last_update_date => l_last_update_date,
       p_db_last_update_date => l_cust_reg_item_rec.last_update_date,
       p_last_update_login => l_last_update_login,
       p_create_or_update => 'UPDATE') then
     null;
  end if;

  update AK_CUSTOM_REGION_ITEMS set
        PROPERTY_VARCHAR2_VALUE = l_cust_reg_item_rec.property_varchar2_value,
        PROPERTY_NUMBER_VALUE = l_cust_reg_item_rec.property_number_value,
        PROPERTY_DATE_VALUE = l_cust_reg_item_rec.property_date_value,
        LAST_UPDATE_DATE = l_last_update_date,
        LAST_UPDATED_BY = l_last_updated_by,
        LAST_UPDATE_LOGIN = l_last_update_login
  where REGION_APPLICATION_ID = p_region_application_id
  and   REGION_CODE = p_region_code
  and   CUSTOMIZATION_APPLICATION_ID = p_custom_appl_id
  and   CUSTOMIZATION_CODE = p_custom_code
  and   ATTRIBUTE_APPLICATION_ID = p_attribute_appl_id
  and   ATTRIBUTE_CODE = p_attribute_code
  and   PROPERTY_NAME = p_property_name;
  if (sql%notfound) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_CUSTOM_ITEM_UPDATE_FAILED');
      FND_MSG_PUB.Add;
    end if;
    -- dbms_output.put_line(l_api_name || 'Row does not exist during update');
    raise FND_API.G_EXC_ERROR;
  end if;

  update AK_CUSTOM_REGION_ITEMS_TL set
        PROPERTY_VARCHAR2_VALUE = l_cust_reg_item_tl_rec.property_varchar2_value,
        LAST_UPDATE_DATE = l_last_update_date,
        LAST_UPDATED_BY = l_last_updated_by,
        LAST_UPDATE_LOGIN = l_last_update_login,
          SOURCE_LANG = l_lang
  where REGION_APPLICATION_ID = p_region_application_id
  and   REGION_CODE = p_region_code
  and   CUSTOMIZATION_APPLICATION_ID = p_custom_appl_id
  and   CUSTOMIZATION_CODE = p_custom_code
  and   ATTRIBUTE_APPLICATION_ID = p_attribute_appl_id
  and   ATTRIBUTE_CODE = p_attribute_code
  and   PROPERTY_NAME = p_property_name
  and   l_lang in (LANGUAGE, SOURCE_LANG);
  if (sql%notfound) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_CUSTOM_ITEM_UPDATE_FAILED');
      FND_MSG_PUB.Add;
    end if;
    --dbms_output.put_line(l_api_name || 'TL Row does not exist during update');
    raise FND_API.G_EXC_ERROR;
  end if;

--  /** commit the update **/
--  commit;

  if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
    FND_MESSAGE.SET_NAME('AK','AK_CUSTOM_ITEM_UPDATED');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
                                   ' ' || p_region_code ||
                                   ' ' || to_char(p_custom_appl_id) ||
                                   ' ' || p_custom_code || ' ' ||
                                   p_property_name);
    FND_MSG_PUB.Add;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);

EXCEPTION
  WHEN VALUE_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_CUSTOM_ITEM_VALUE_ERROR');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
                                   ' ' || p_region_code ||
                                   ' ' ||  to_char(p_custom_appl_id) ||
                                   ' ' || p_custom_code || ' ' ||
                                   p_property_name);
    FND_MSG_PUB.Add;
  end if;
    rollback to start_update_cust_reg_item;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
  WHEN FND_API.G_EXC_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_CUSTOM_ITEM_NOT_UPDATED');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
                                   ' ' || p_region_code ||
                                   ' ' || to_char(p_custom_appl_id) ||
                                   ' ' || p_custom_code || ' ' ||
                                   p_property_name);
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
    rollback to start_update_cust_reg_item;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
end UPDATE_CUST_REG_ITEM;

--=======================================================
--  Procedure   UPDATE_CRITERIA
--
--  Usage       Private API for updating a region graph.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API updates a region graph using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region Graph columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will update the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure UPDATE_CRITERIA (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_init_msg_tbl             IN      BOOLEAN := FALSE,
  p_msg_count                OUT NOCOPY     NUMBER,
  p_msg_data                 OUT NOCOPY     VARCHAR2,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_custom_appl_id           IN      NUMBER,
  p_custom_code              IN      VARCHAR2,
  p_region_application_id    IN      NUMBER,
  p_region_code              IN      VARCHAR2,
  p_attribute_appl_id        IN      NUMBER,
  p_attribute_code           IN      VARCHAR2,
  p_sequence_number	     IN      NUMBER,
  p_operation		     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_value_varchar2	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_value_number	     IN      NUMBER := FND_API.G_MISS_NUM,
  p_value_date 		     IN      DATE := FND_API.G_MISS_DATE,
  p_start_date_active        IN      DATE := FND_API.G_MISS_DATE,
  p_end_date_active	     IN      DATE := FND_API.G_MISS_DATE,
  p_created_by               IN      NUMBER := FND_API.G_MISS_NUM,
  p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
  p_last_updated_by          IN      NUMBER := FND_API.G_MISS_NUM,
  p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
  p_last_update_login        IN      NUMBER := FND_API.G_MISS_NUM,
  p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
  p_pass                     IN      NUMBER,
  p_copy_redo_flag           IN OUT NOCOPY  BOOLEAN
) is
  cursor l_get_row_csr is
    select *
    from  AK_CRITERIA
    where CUSTOMIZATION_APPLICATION_ID = p_custom_appl_id
    and   CUSTOMIZATION_CODE = p_custom_code
    and   REGION_APPLICATION_ID = p_region_application_id
    and   REGION_CODE = p_region_code
    and   ATTRIBUTE_APPLICATION_ID = p_attribute_appl_id
    and   ATTRIBUTE_CODE = p_attribute_code
    and   SEQUENCE_NUMBER = p_sequence_number
    for update of OPERATION;
  l_api_version_number     CONSTANT number := 1.0;
  l_api_name               CONSTANT varchar2(30) := 'Update_Criteria';
  l_created_by             number;
  l_creation_date          date;
  l_criteria_rec	   ak_criteria%ROWTYPE;
  l_error                  boolean;
  l_last_update_date       date;
  l_last_update_login      number;
  l_last_updated_by        number;
  l_return_status          varchar2(1);
  l_submit                                      varchar2(1) := 'N';
  l_encrypt                                     varchar2(1) := 'N';
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

  savepoint start_update_criteria;

  --** retrieve ak_criteria row if it exists **
  open l_get_row_csr;
  fetch l_get_row_csr into l_criteria_rec;
  if (l_get_row_csr%notfound) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
      FND_MESSAGE.SET_NAME('AK','AK_CRITERIA_DOES_NOT_EXIST');
      FND_MSG_PUB.Add;
    end if;
    --dbms_output.put_line(l_api_name || 'Error - Row does not exist');
    close l_get_row_csr;
    raise FND_API.G_EXC_ERROR;
  end if;
  close l_get_row_csr;

  --
  -- validate table columns passed in
  --
  if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
    if not VALIDATE_CRITERIA (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_region_application_id => p_region_application_id,
            p_region_code => p_region_code,
            p_custom_application_id => p_custom_appl_id,
            p_custom_code => p_custom_code,
            p_attr_appl_id => p_attribute_appl_id,
            p_attr_code => p_attribute_code,
	    p_sequence_number => p_sequence_number,
	    p_operation => p_operation,
	    p_value_varchar2 => p_value_varchar2,
	    p_value_number => p_value_number,
	    p_value_date => p_value_date,
	    p_start_date_Active => p_start_date_active,
	    p_end_date_active => p_end_date_active,
	                p_caller => AK_ON_OBJECTS_PVT.G_UPDATE,
                        p_pass => p_pass
          ) then
      --dbms_output.put_line(l_api_name || ' validation failed');
      -- Do not raise an error if it's the first pass
          if (p_pass = 1) then
            p_copy_redo_flag := TRUE;
      else
        raise FND_API.G_EXC_ERROR;
      end if;
    end if;
  end if;

  --** Load record to be updated to the database **
  --** - first load nullable columns **

  if (p_value_varchar2 <> FND_API.G_MISS_CHAR) or
     (p_value_varchar2 is null) then
   l_criteria_rec.value_varchar2 := p_value_varchar2;
  end if;

  if (p_value_number <> FND_API.G_MISS_NUM) or
     (p_value_number is null) then
   l_criteria_rec.value_number := p_value_number;
  end if;

  if (p_value_date <> FND_API.G_MISS_DATE) or
     (p_value_date is null) then
   l_criteria_rec.value_date := p_value_date;
  end if;

  if (p_end_date_active <> FND_API.G_MISS_DATE) or
     (p_end_date_active is null) then
   l_criteria_rec.end_date_active := p_end_date_active;
  end if;

  --** - next, load non-null columns **

  if (p_operation <> FND_API.G_MISS_CHAR) then
    l_criteria_rec.operation := p_operation;
  end if;

  if (p_start_date_active <> FND_API.G_MISS_DATE) then
    l_criteria_rec.start_date_active := p_start_date_active;
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

-- THIS UPDATES NO MATTER WHAT - CALLING IS_UPDATEABLE BECAUSE STILL
-- NECESSARY FOR PRE-12 CODE
  if AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
       p_loader_timestamp => p_loader_timestamp,
       p_created_by => l_created_by,
       p_creation_date => l_creation_date,
       p_last_updated_by => l_last_updated_by,
       p_db_last_updated_by => l_criteria_rec.last_updated_by,
       p_last_update_date => l_last_update_date,
       p_db_last_update_date => l_criteria_rec.last_update_date,
       p_last_update_login => l_last_update_login,
       p_create_or_update => 'UPDATE') then
     null;
  end if;

  update AK_CRITERIA set
	OPERATION = l_criteria_rec.operation,
	VALUE_VARCHAR2 = l_criteria_rec.value_varchar2,
	VALUE_NUMBER = l_criteria_rec.value_number,
        VALUE_DATE = l_criteria_rec.value_date,
	START_DATE_ACTIVE = l_criteria_rec.start_date_active,
  	END_DATE_ACTIVE = l_criteria_rec.end_date_active,
        LAST_UPDATE_DATE = l_last_update_date,
        LAST_UPDATED_BY = l_last_updated_by,
        LAST_UPDATE_LOGIN = l_last_update_login
  where REGION_APPLICATION_ID = p_region_application_id
  and   REGION_CODE = p_region_code
  and   CUSTOMIZATION_APPLICATION_ID = p_custom_appl_id
  and   CUSTOMIZATION_CODE = p_custom_code
  and   ATTRIBUTE_APPLICATION_ID = p_attribute_appl_id
  and   ATTRIBUTE_CODE = p_attribute_code
  and   SEQUENCE_NUMBER = p_sequence_number;
  if (sql%notfound) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_CRITERIA_UPDATE_FAILED');
      FND_MSG_PUB.Add;
    end if;
    -- dbms_output.put_line(l_api_name || 'Row does not exist during update');
    raise FND_API.G_EXC_ERROR;
  end if;

--  /** commit the update **/
--  commit;

  if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
    FND_MESSAGE.SET_NAME('AK','AK_CRITERIA_UPDATED');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
                                   ' ' || p_region_code ||
                                   ' ' || to_char(p_custom_appl_id) ||
                                   ' ' || p_custom_code || ' ' ||
                                   to_char(p_sequence_number));
    FND_MSG_PUB.Add;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);

EXCEPTION
  WHEN VALUE_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_CRITERIA_VALUE_ERROR');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
                                   ' ' || p_region_code ||
                                   ' ' ||  to_char(p_custom_appl_id) ||
                                   ' ' || p_custom_code || ' ' ||
                                   to_char(p_sequence_number));
    FND_MSG_PUB.Add;
  end if;
    rollback to start_update_criteria;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
  WHEN FND_API.G_EXC_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_CRITERIA_NOT_UPDATED');
      FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
                                   ' ' || p_region_code ||
                                   ' ' || to_char(p_custom_appl_id) ||
                                   ' ' || p_custom_code || ' ' ||
                                   to_char(p_sequence_number));
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
    rollback to start_update_criteria;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
end UPDATE_CRITERIA;

end AK_CUSTOM_PVT;

/
