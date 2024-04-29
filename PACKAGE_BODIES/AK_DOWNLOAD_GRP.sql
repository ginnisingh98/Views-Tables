--------------------------------------------------------
--  DDL for Package Body AK_DOWNLOAD_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AK_DOWNLOAD_GRP" as
/* $Header: akgdlodb.pls 120.3 2006/01/25 15:32:15 tshort ship $ */

procedure DOWNLOAD (
  p_business_object  IN  VARCHAR2,
  p_appl_short_name  IN  VARCHAR2,
  p_primary_key      IN  VARCHAR2 := FND_API.G_MISS_CHAR,
  p_return_status   OUT NOCOPY VARCHAR2,
  p_level	     IN  VARCHAR2 := FND_API.G_MISS_CHAR,
  p_levelpk	     IN  VARCHAR2 := FND_API.G_MISS_CHAR,
  p_download_attr    IN  VARCHAR2 := 'Y',
  p_download_reg     IN  VARCHAR2 := 'Y'
) is
  cursor l_get_appl_id_csr (short_name_param varchar2) is
  select application_id
  from   fnd_application_vl
  where  application_short_name = short_name_param;
  cursor l_check_table_csr (session_id_param number) is
    select tbl_index
	from ak_loader_temp
	where tbl_index = 1
	and session_id = session_id_param;
  cursor l_get_custom_list_csr(appl_id_param number, custom_code_param varchar2) is
   select ac.customization_application_id, ac.customization_code,
          ac.region_application_id, ac.region_code
   from   AK_CUSTOMIZATIONS ac, AK_REGIONS ar
   where  ac.region_application_id = appl_id_param
   and    ac.region_code like custom_code_param
   and    ac.region_application_id = ar.region_application_id
   and    ac.region_code = ar.region_code;
  cursor l_get_custom_resp_list_csr(appl_id_param number, custom_code_param varchar2, levelpk number) is
   select ac.customization_application_id, ac.customization_code,
          ac.region_application_id, ac.region_code
   from   AK_CUSTOMIZATIONS ac, AK_REGIONS ar
   where  ac.region_application_id = appl_id_param
   and    ac.region_code like custom_code_param
   and    ac.region_application_id = ar.region_application_id
   and    ac.region_code = ar.region_code
   and    ac.responsibility_id = levelpk;
  cursor l_get_custom_resp_list2_csr(appl_id_param number, custom_code_param varchar2) is
   select ac.customization_application_id, ac.customization_code,
          ac.region_application_id, ac.region_code
   from   AK_CUSTOMIZATIONS ac, AK_REGIONS ar
   where  ac.region_application_id = appl_id_param
   and    ac.region_code like custom_code_param
   and    ac.region_application_id = ar.region_application_id
   and    ac.region_code = ar.region_code
   and    ac.responsibility_id is not null;
  cursor l_get_custom_org_list_csr(appl_id_param number, custom_code_param varchar2, levelpk number) is
   select ac.customization_application_id, ac.customization_code,
          ac.region_application_id, ac.region_code
   from   AK_CUSTOMIZATIONS ac, AK_REGIONS ar
   where  ac.region_application_id = appl_id_param
   and    ac.region_code like custom_code_param
   and    ac.region_application_id = ar.region_application_id
   and    ac.region_code = ar.region_code
   and    ac.org_id = levelpk;
  cursor l_get_custom_org_list2_csr(appl_id_param number, custom_code_param varchar2) is
   select ac.customization_application_id, ac.customization_code,
          ac.region_application_id, ac.region_code
   from   AK_CUSTOMIZATIONS ac, AK_REGIONS ar
   where  ac.region_application_id = appl_id_param
   and    ac.region_code like custom_code_param
   and    ac.region_application_id = ar.region_application_id
   and    ac.region_code = ar.region_code
   and    ac.org_id is not null;
  cursor l_get_custom_fun_list_csr(appl_id_param number, custom_code_param varchar2, levelpk varchar2) is
   select ac.customization_application_id, ac.customization_code,
          ac.region_application_id, ac.region_code
   from   AK_CUSTOMIZATIONS ac, AK_REGIONS ar
   where  ac.region_application_id = appl_id_param
   and    ac.region_code like custom_code_param
   and    ac.region_application_id = ar.region_application_id
   and    ac.region_code = ar.region_code
   and    ac.function_name = levelpk;
  cursor l_get_custom_fun_list2_csr(appl_id_param number, custom_code_param varchar2) is
   select ac.customization_application_id, ac.customization_code,
          ac.region_application_id, ac.region_code
   from   AK_CUSTOMIZATIONS ac, AK_REGIONS ar
   where  ac.region_application_id = appl_id_param
   and    ac.region_code like custom_code_param
   and    ac.region_application_id = ar.region_application_id
   and    ac.region_code = ar.region_code
   and    ac.function_name is not null;
  cursor l_get_custom_local_list_csr(appl_id_param number, custom_code_param varchar2, levelpk varchar2) is
   select ac.customization_application_id, ac.customization_code,
          ac.region_application_id, ac.region_code
   from   AK_CUSTOMIZATIONS ac, AK_REGIONS ar
   where  ac.region_application_id = appl_id_param
   and    ac.region_code like custom_code_param
   and    ac.region_application_id = ar.region_application_id
   and    ac.region_code = ar.region_code
   and    ac.localization_code = levelpk;
  cursor l_get_custom_local_list2_csr(appl_id_param number, custom_code_param varchar2) is
   select ac.customization_application_id, ac.customization_code,
          ac.region_application_id, ac.region_code
   from   AK_CUSTOMIZATIONS ac, AK_REGIONS ar
   where  ac.region_application_id = appl_id_param
   and    ac.region_code like custom_code_param
   and    ac.region_application_id = ar.region_application_id
   and    ac.region_code = ar.region_code
   and    ac.localization_code is not null;
  cursor l_get_custom_site_list_csr(appl_id_param number, custom_code_param varchar2, levelpk number) is
   select ac.customization_application_id, ac.customization_code,
          ac.region_application_id, ac.region_code
   from   AK_CUSTOMIZATIONS ac, AK_REGIONS ar
   where  ac.region_application_id = appl_id_param
   and    ac.region_code like custom_code_param
   and    ac.region_application_id = ar.region_application_id
   and    ac.region_code = ar.region_code
   and    ac.site_id = levelpk;
  cursor l_get_custom_site_list2_csr(appl_id_param number, custom_code_param varchar2) is
   select ac.customization_application_id, ac.customization_code,
          ac.region_application_id, ac.region_code
   from   AK_CUSTOMIZATIONS ac, AK_REGIONS ar
   where  ac.region_application_id = appl_id_param
   and    ac.region_code like custom_code_param
   and    ac.region_application_id = ar.region_application_id
   and    ac.region_code = ar.region_code
   and    ac.site_id is not null;
  cursor l_get_org_id(levelpk varchar2) is
    select organization_id
    from   MTL_PARAMETERS
    where  organization_code = levelpk;
  cursor l_get_resp_id(levelpk varchar2) is
    select responsibility_id
    from   FND_RESPONSIBILITY
    where  responsibility_key = levelpk;
  cursor l_check_percent(objectpk varchar2) is
    select instr(objectpk,'%')
    from dual;
  cursor l_get_like_region_csr (appl_id_param number, region_code_param varchar2) is
   select region_application_id, region_code
   from ak_regions
   where region_application_id = appl_id_param
   and region_code like region_code_param;
   cursor l_get_like_flow_csr (appl_id_param number, flow_code_param varchar2) is
   select flow_application_id, flow_code
   from ak_flows
   where flow_application_id = appl_id_param
   and flow_code like flow_code_param;
  cursor l_get_like_object_csr (database_obj_param varchar2) is
   select database_object_name
   from ak_objects
   where database_object_name like database_obj_param;

  l_api_name          CONSTANT varchar2(30) := 'Download';
  l_appl_short_name   varchar2(30);
  l_appl_id           NUMBER;
  l_buffer_tbl        AK_ON_OBJECTS_PUB.Buffer_Tbl_Type;
  l_by_object         varchar2(30);
  l_index             number := 0;
  l_index2	      number;
  l_msg_count         number;
  l_msg_data          varchar2(2000);
  l_return_boolean    BOOLEAN;
  l_return_status     VARCHAR2(1);
  l_string_pos        number;
  l_table_index       number;
  l_dum               NUMBER;
  l_object_pk         varchar2(240) := FND_API.G_MISS_CHAR;
  l_flow_pk_tbl       AK_FLOW_PUB.Flow_PK_Tbl_Type;
  l_region_pk_tbl     AK_REGION_PUB.Region_PK_Tbl_Type;
  l_custom_pk_tbl     AK_CUSTOM_PUB.Custom_PK_Tbl_Type;
  l_object_pk_tbl     AK_OBJECT_PUB.Object_PK_Tbl_Type;
  l_sec_pk_tbl        AK_SECURITY_PUB.Resp_PK_Tbl_Type;
  l_attr_pk_tbl       AK_ATTRIBUTE_PUB.Attribute_PK_Tbl_Type;
  l_queryobj_pk_tbl   AK_QUERYOBJ_PUB.QueryObj_PK_Tbl_Type;
  l_amparamreg_pk_tbl	AK_AMPARAM_REGISTRY_PUB.AmParamReg_Pk_Tbl_Type;
  l_session_id        NUMBER;
  l_level_pk	      VARCHAR2(30);
  l_level_id_pk	      NUMBER;
  l_percent		NUMBER;

begin
  --
  -- Get object to be downloaded from argument
  --
  l_by_object := p_business_object;
  --
  -- Get application short name from argument
  --
  l_appl_short_name := upper(p_appl_short_name);

  --
  -- Get Primary key for the object
  --
  if (p_primary_key is not null and p_primary_key <> FND_API.G_MISS_CHAR) then
    l_object_pk := p_primary_key;
  end if;

  --
  -- Set what error messages are to be displayed
  --
--FND_MSG_PUB.G_MSG_LEVEL_THRESHOLD := FND_MSG_PUB.G_MSG_LVL_SUCCESS;
  FND_MSG_PUB.G_MSG_LEVEL_THRESHOLD := FND_MSG_PUB.G_MSG_LVL_ERROR;

  -- Get application id from application short name
  --
  open l_get_appl_id_csr(l_appl_short_name);
  fetch l_get_appl_id_csr into l_appl_id;
    if (l_get_appl_id_csr%notfound) then
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.SET_NAME('AK','AK_APPL_SHORT_NAME_INVALID');
        FND_MESSAGE.SET_TOKEN('APPL_SHORT_NAME', l_appl_short_name);
        FND_MSG_PUB.Add;
      end if;
      close l_get_appl_id_csr;
      raise FND_API.G_EXC_ERROR;
    end if;
  close l_get_appl_id_csr;

  -- set Loading mode
  AK_ON_OBJECTS_PUB.G_LOAD_MODE := 'DOWNLOAD';

  /** retreive the sessio id **/
  select sid into l_session_id
  from v$session
  where AUDSID = userenv('SESSIONID');

  AK_ON_OBJECTS_PVT.G_SESSION_ID := l_session_id;

  -- set G_WRITE_HEADER to indicate writing the header or not
  --
  open l_check_table_csr(l_session_id);
  fetch l_check_table_csr into l_dum;
  if l_check_table_csr%NOTFOUND then
    G_WRITE_HEADER := TRUE;
  else
    G_WRITE_HEADER := FALSE;
  end if;
  close l_check_table_csr;

  if p_download_attr = 'Y' then
 	G_DOWNLOAD_ATTR := 'Y';
  else
	G_DOWNLOAD_ATTR := 'N';
  end if;

  if p_download_reg = 'Y' then
	G_DOWNLOAD_REG := 'Y';
  else
	G_DOWNLOAD_REG := 'N';
  end if;
  --
  -- Load buffer table with log file heading info to be written
  -- to the log file
  --
  l_index := 1;
  l_buffer_tbl(l_index) := '**********';

  l_index := l_index + 1;
  FND_MESSAGE.SET_NAME('AK','AK_START_DOWNLOAD_SESSION');
  l_buffer_tbl(l_index) := FND_MESSAGE.GET;
  l_index := l_index + 1;
  l_buffer_tbl(l_index) := to_char(sysdate, 'DY MON DD YYYY HH24:MI:SS');
  l_index := l_index + 1;
  l_buffer_tbl(l_index) := '**********';
  l_index := l_index + 1;
  l_buffer_tbl(l_index) := ' ';

  --dbms_output.put_line('Begin ' || l_by_object || ' at:' ||
  --                     to_char(sysdate, 'MON-DD HH24:MI:SS'));
  --
  -- Write heading info to a log file
  --
  AK_ON_OBJECTS_PVT.WRITE_LOG_FILE (
    p_return_status => l_return_status,
    p_buffer_tbl => l_buffer_tbl,
    p_write_mode => AK_ON_OBJECTS_PUB.G_OVERWRITE
  );

  --
  -- Clean up buffer table for use by other messages later
  --
--  l_buffer_tbl.delete;

  -- Initialize loader table index
  if (G_WRITE_HEADER) then
    AK_ON_OBJECTS_PVT.G_TBL_INDEX := 0;
  end if;

  --
  -- Download data from database
  --
if (upper(l_by_object) = 'FLOW') then
  if (l_object_pk is not null and l_object_pk <> FND_API.G_MISS_CHAR) then
    open l_check_percent(l_object_pk);
    fetch l_check_percent into l_percent;
    if l_percent <> 0 then
     l_index := 1;
     open l_get_like_flow_csr(l_appl_id, l_object_pk);
     loop
       fetch l_get_like_flow_csr into
         l_flow_pk_tbl(l_index).flow_appl_id,
         l_flow_pk_tbl(l_index).flow_code;
         if (l_get_like_flow_csr%notfound and l_index = 1) then
               l_flow_pk_tbl(1).flow_appl_id := l_appl_id;
               l_flow_pk_tbl(1).flow_code := l_object_pk;
         end if;
       l_index := l_index + 1;
       exit when l_get_like_flow_csr%notfound;
     end loop;
     close l_get_like_flow_csr;
    else
     l_flow_pk_tbl(1).flow_appl_id := l_appl_id;
     l_flow_pk_tbl(1).flow_code := l_object_pk;
  end if;
    close l_check_percent;
  end if;
  AK_FLOW_GRP.DOWNLOAD_FLOW (
--p_validation_level => FND_API.G_VALID_LEVEL_NONE,
    p_api_version_number => 1.0,
    p_init_msg_tbl => TRUE,
    p_msg_count => l_msg_count,
    p_msg_data => l_msg_data,
    p_return_status => l_return_status,
    p_application_id => l_appl_id,
    p_application_short_name => upper(l_appl_short_name),
	p_flow_pk_tbl => l_flow_pk_tbl
  );

elsif (upper(l_by_object) = 'REGION') then
  if (l_object_pk is not null and l_object_pk <> FND_API.G_MISS_CHAR) then
    open l_check_percent(l_object_pk);
    fetch l_check_percent into l_percent;
    if l_percent <> 0 then
     l_index := 1;
     open l_get_like_region_csr(l_appl_id, l_object_pk);
     loop
       fetch l_get_like_region_csr into
         l_region_pk_tbl(l_index).region_appl_id,
         l_region_pk_tbl(l_index).region_code;
         if (l_get_like_region_csr%notfound and l_index = 1) then
               l_region_pk_tbl(1).region_appl_id := l_appl_id;
               l_region_pk_tbl(1).region_code := l_object_pk;
         end if;
       l_index := l_index + 1;
       exit when l_get_like_region_csr%notfound;
     end loop;
     close l_get_like_region_csr;
    else
     l_region_pk_tbl(1).region_appl_id := l_appl_id;
     l_region_pk_tbl(1).region_code := l_object_pk;
    end if;
    close l_check_percent;
  end if;
  AK_REGION_GRP.DOWNLOAD_REGION (
--    p_validation_level => FND_API.G_VALID_LEVEL_NONE,
    p_api_version_number => 1.0,
    p_init_msg_tbl => TRUE,
    p_msg_count => l_msg_count,
    p_msg_data => l_msg_data,
    p_return_status => l_return_status,
    p_application_id => l_appl_id,
    p_application_short_name => upper(l_appl_short_name),
	p_region_pk_tbl => l_region_pk_tbl
  );

elsif (upper(l_by_object) = 'CUSTOM_REGION') then
  if (l_object_pk is not null and l_object_pk <> FND_API.G_MISS_CHAR) then
    l_index := 1;
    if (p_level is null or p_level = FND_API.G_MISS_CHAR) then
      open l_get_custom_list_csr(l_appl_id, l_object_pk);
      loop
        fetch l_get_custom_list_csr into
          l_custom_pk_tbl(l_index).custom_appl_id,
          l_custom_pk_tbl(l_index).custom_code,
          l_custom_pk_tbl(l_index).region_appl_id,
          l_custom_pk_tbl(l_index).region_code;
          if (l_get_custom_list_csr%notfound and l_index = 1) then
              l_custom_pk_tbl(1).region_appl_id := l_appl_id;
	      l_custom_pk_tbl(1).region_code := l_object_pk;
          end if;
        l_index := l_index + 1;
        exit when l_get_custom_list_csr%notfound;
      end loop;
      close l_get_custom_list_csr;
    elsif (p_level = 'RESPONSIBILITY')  then
      if (p_levelpk is not null and p_levelpk <> FND_API.G_MISS_CHAR) then
      open l_get_resp_id(p_levelpk);
      fetch l_get_resp_id into l_level_id_pk;
      if (l_get_resp_id%notfound) then
	l_level_id_pk := null;
--        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
--           FND_MESSAGE.SET_NAME('AK','AK_RESP_IS_NOT_VALID');
--           FND_MSG_PUB.Add;
--        end if;
--        RAISE FND_API.G_EXC_ERROR;
      end if;
      close l_get_resp_id;
      open l_get_custom_resp_list_csr(l_appl_id, l_object_pk, l_level_id_pk);
      loop
        fetch l_get_custom_resp_list_csr into
          l_custom_pk_tbl(l_index).custom_appl_id,
          l_custom_pk_tbl(l_index).custom_code,
          l_custom_pk_tbl(l_index).region_appl_id,
          l_custom_pk_tbl(l_index).region_code;
          if (l_get_custom_resp_list_csr%notfound and l_index = 1) then
              l_custom_pk_tbl(1).region_appl_id := l_appl_id;
              l_custom_pk_tbl(1).region_code := l_object_pk;
          end if;
        l_index := l_index + 1;
        exit when l_get_custom_resp_list_csr%notfound;
      end loop;
      close l_get_custom_resp_list_csr;
      else
      open l_get_custom_resp_list2_csr(l_appl_id, l_object_pk);
      loop
        fetch l_get_custom_resp_list2_csr into
          l_custom_pk_tbl(l_index).custom_appl_id,
          l_custom_pk_tbl(l_index).custom_code,
          l_custom_pk_tbl(l_index).region_appl_id,
          l_custom_pk_tbl(l_index).region_code;
          if (l_get_custom_resp_list2_csr%notfound and l_index = 1) then
              l_custom_pk_tbl(1).region_appl_id := l_appl_id;
              l_custom_pk_tbl(1).region_code := l_object_pk;
          end if;
        l_index := l_index + 1;
        exit when l_get_custom_resp_list2_csr%notfound;
      end loop;
      close l_get_custom_resp_list2_csr;
      end if;
    elsif (p_level = 'ORGANIZATION') then
      if (p_levelpk is not null and p_levelpk <> FND_API.G_MISS_CHAR) then
      open l_get_org_id(p_levelpk);
      fetch l_get_org_id into l_level_id_pk;
      if (l_get_org_id%notfound) then
        l_level_id_pk := null;
--        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
--           FND_MESSAGE.SET_NAME('AK','AK_ORG_IS_NOT_VALID');
--           FND_MSG_PUB.Add;
--        end if;
--        RAISE FND_API.G_EXC_ERROR;
      end if;
      close l_get_org_id;
      open l_get_custom_org_list_csr(l_appl_id, l_object_pk, l_level_id_pk);
      loop
        fetch l_get_custom_org_list_csr into
          l_custom_pk_tbl(l_index).custom_appl_id,
          l_custom_pk_tbl(l_index).custom_code,
          l_custom_pk_tbl(l_index).region_appl_id,
          l_custom_pk_tbl(l_index).region_code;
          if (l_get_custom_org_list_csr%notfound and l_index = 1) then
              l_custom_pk_tbl(1).region_appl_id := l_appl_id;
              l_custom_pk_tbl(1).region_code := l_object_pk;
          end if;
        l_index := l_index + 1;
        exit when l_get_custom_org_list_csr%notfound;
      end loop;
      close l_get_custom_org_list_csr;
      else
      open l_get_custom_org_list2_csr(l_appl_id, l_object_pk);
      loop
        fetch l_get_custom_org_list2_csr into
          l_custom_pk_tbl(l_index).custom_appl_id,
          l_custom_pk_tbl(l_index).custom_code,
          l_custom_pk_tbl(l_index).region_appl_id,
          l_custom_pk_tbl(l_index).region_code;
          if (l_get_custom_org_list2_csr%notfound and l_index = 1) then
              l_custom_pk_tbl(1).region_appl_id := l_appl_id;
              l_custom_pk_tbl(1).region_code := l_object_pk;
          end if;
        l_index := l_index + 1;
        exit when l_get_custom_org_list2_csr%notfound;
      end loop;
      close l_get_custom_org_list2_csr;
      end if;
    elsif (p_level = 'FUNCTION') then
      if (p_levelpk is not null and p_levelpk <> FND_API.G_MISS_CHAR) then
      open l_get_custom_fun_list_csr(l_appl_id, l_object_pk, p_levelpk);
      loop
        fetch l_get_custom_fun_list_csr into
          l_custom_pk_tbl(l_index).custom_appl_id,
          l_custom_pk_tbl(l_index).custom_code,
          l_custom_pk_tbl(l_index).region_appl_id,
          l_custom_pk_tbl(l_index).region_code;
          if (l_get_custom_fun_list_csr%notfound and l_index = 1) then
              l_custom_pk_tbl(1).region_appl_id := l_appl_id;
              l_custom_pk_tbl(1).region_code := l_object_pk;
          end if;
        l_index := l_index + 1;
        exit when l_get_custom_fun_list_csr%notfound;
      end loop;
      close l_get_custom_fun_list_csr;
      else
      open l_get_custom_fun_list2_csr(l_appl_id, l_object_pk);
      loop
        fetch l_get_custom_fun_list2_csr into
          l_custom_pk_tbl(l_index).custom_appl_id,
          l_custom_pk_tbl(l_index).custom_code,
          l_custom_pk_tbl(l_index).region_appl_id,
          l_custom_pk_tbl(l_index).region_code;
          if (l_get_custom_fun_list2_csr%notfound and l_index = 1) then
              l_custom_pk_tbl(1).region_appl_id := l_appl_id;
              l_custom_pk_tbl(1).region_code := l_object_pk;
          end if;
        l_index := l_index + 1;
        exit when l_get_custom_fun_list2_csr%notfound;
      end loop;
      close l_get_custom_fun_list2_csr;
      end if;
    elsif (p_level = 'LOCALIZATION') then
      if (p_levelpk is not null and p_levelpk <> FND_API.G_MISS_CHAR) then
      open l_get_custom_local_list_csr(l_appl_id, l_object_pk, p_levelpk);
      loop
        fetch l_get_custom_local_list_csr into
          l_custom_pk_tbl(l_index).custom_appl_id,
          l_custom_pk_tbl(l_index).custom_code,
          l_custom_pk_tbl(l_index).region_appl_id,
          l_custom_pk_tbl(l_index).region_code;
          if (l_get_custom_local_list_csr%notfound and l_index = 1) then
              l_custom_pk_tbl(1).region_appl_id := l_appl_id;
              l_custom_pk_tbl(1).region_code := l_object_pk;
          end if;
        l_index := l_index + 1;
        exit when l_get_custom_local_list_csr%notfound;
      end loop;
      close l_get_custom_local_list_csr;
      else
      open l_get_custom_local_list2_csr(l_appl_id, l_object_pk);
      loop
        fetch l_get_custom_local_list2_csr into
          l_custom_pk_tbl(l_index).custom_appl_id,
          l_custom_pk_tbl(l_index).custom_code,
          l_custom_pk_tbl(l_index).region_appl_id,
          l_custom_pk_tbl(l_index).region_code;
          if (l_get_custom_local_list2_csr%notfound and l_index = 1) then
              l_custom_pk_tbl(1).region_appl_id := l_appl_id;
              l_custom_pk_tbl(1).region_code := l_object_pk;
          end if;
        l_index := l_index + 1;
        exit when l_get_custom_local_list2_csr%notfound;
      end loop;
      close l_get_custom_local_list2_csr;
      end if;
    elsif (p_level = 'SITE') then
      if (p_levelpk is not null and p_levelpk <> FND_API.G_MISS_CHAR) then
      open l_get_custom_site_list_csr(l_appl_id, l_object_pk, p_levelpk);
      loop
        fetch l_get_custom_site_list_csr into
          l_custom_pk_tbl(l_index).custom_appl_id,
          l_custom_pk_tbl(l_index).custom_code,
          l_custom_pk_tbl(l_index).region_appl_id,
          l_custom_pk_tbl(l_index).region_code;
          if (l_get_custom_site_list_csr%notfound and l_index = 1) then
              l_custom_pk_tbl(1).region_appl_id := l_appl_id;
              l_custom_pk_tbl(1).region_code := l_object_pk;
          end if;
        l_index := l_index + 1;
        exit when l_get_custom_site_list_csr%notfound;
      end loop;
      close l_get_custom_site_list_csr;
      else
      open l_get_custom_site_list2_csr(l_appl_id, l_object_pk);
      loop
        fetch l_get_custom_site_list2_csr into
          l_custom_pk_tbl(l_index).custom_appl_id,
          l_custom_pk_tbl(l_index).custom_code,
          l_custom_pk_tbl(l_index).region_appl_id,
          l_custom_pk_tbl(l_index).region_code;
          if (l_get_custom_site_list2_csr%notfound and l_index = 1) then
              l_custom_pk_tbl(1).region_appl_id := l_appl_id;
              l_custom_pk_tbl(1).region_code := l_object_pk;
          end if;
        l_index := l_index + 1;
        exit when l_get_custom_site_list2_csr%notfound;
      end loop;
      close l_get_custom_site_list2_csr;
      end if;
    end if;
  end if;
  if (l_index > 1) then
  AK_CUSTOM_GRP.DOWNLOAD_CUSTOM (
--    p_validation_level => FND_API.G_VALID_LEVEL_NONE,
    p_api_version_number => 1.0,
    p_init_msg_tbl => TRUE,
    p_msg_count => l_msg_count,
    p_msg_data => l_msg_data,
    p_return_status => l_return_status,
    p_application_id => l_appl_id,
    p_application_short_name => upper(l_appl_short_name),
        p_custom_pk_tbl => l_custom_pk_tbl,
    p_level => p_level,
    p_levelpk => p_levelpk
  );
  end if;

elsif (upper(l_by_object) = 'OBJECT') then
  if (l_object_pk is not null and l_object_pk <> FND_API.G_MISS_CHAR) then
    open l_check_percent(l_object_pk);
    fetch l_check_percent into l_percent;
    if l_percent <> 0 then
     l_index := 1;
     open l_get_like_object_csr(l_object_pk);
     loop
       fetch l_get_like_object_csr into
         l_object_pk_tbl(l_index);
         if (l_get_like_object_csr%notfound and l_index = 1) then
               l_object_pk_tbl(1) := l_object_pk;
         end if;
       l_index := l_index + 1;
       exit when l_get_like_object_csr%notfound;
     end loop;
     close l_get_like_object_csr;
    else
     l_object_pk_tbl(1) := l_object_pk;
    end if;
    close l_check_percent;
  end if;

  AK_OBJECT_GRP.DOWNLOAD_OBJECT (
--    p_validation_level => FND_API.G_VALID_LEVEL_NONE,
    p_api_version_number => 1.0,
    p_init_msg_tbl => TRUE,
    p_msg_count => l_msg_count,
    p_msg_data => l_msg_data,
    p_return_status => l_return_status,
    p_application_id => l_appl_id,
    p_application_short_name => upper(l_appl_short_name),
	p_object_pk_tbl => l_object_pk_tbl
  );

-- percent code didn't work here, it's in akdvatrb.pls
elsif (upper(l_by_object) = 'ATTRIBUTE') then
  if (l_object_pk is not null and l_object_pk <> FND_API.G_MISS_CHAR) then
     l_attr_pk_tbl(1).attribute_appl_id := l_appl_id;
     l_attr_pk_tbl(1).attribute_code := l_object_pk;
  end if;

  AK_ATTRIBUTE_GRP.DOWNLOAD_ATTRIBUTE (
--    p_validation_level => FND_API.G_VALID_LEVEL_NONE,
    p_api_version_number => 1.0,
    p_init_msg_tbl => TRUE,
    p_msg_count => l_msg_count,
    p_msg_data => l_msg_data,
    p_return_status => l_return_status,
    p_application_id => l_appl_id,
    p_application_short_name => upper(l_appl_short_name),
	p_attribute_pk_tbl => l_attr_pk_tbl
  );

elsif (upper(l_by_object) = 'SECURITY') then
  if (l_object_pk is not null and l_object_pk <> FND_API.G_MISS_CHAR) then
    l_sec_pk_tbl(1).responsibility_id := to_number(l_object_pk);
    l_sec_pk_tbl(1).responsibility_appl_id := l_appl_id;
  end if;
  AK_SECURITY_GRP.DOWNLOAD_RESP (
--    p_validation_level => FND_API.G_VALID_LEVEL_NONE,
    p_api_version_number => 1.0,
    p_init_msg_tbl => TRUE,
    p_msg_count => l_msg_count,
    p_msg_data => l_msg_data,
    p_return_status => l_return_status,
    p_application_id => l_appl_id,
    p_application_short_name => upper(l_appl_short_name),
	p_excluded_pk_tbl => l_sec_pk_tbl,
	p_resp_pk_tbl => l_sec_pk_tbl
  );

elsif (upper(l_by_object) = 'QUERYOBJ') then
  if (l_object_pk is not null and l_object_pk <> FND_API.G_MISS_CHAR) then
    l_queryobj_pk_tbl(1).query_code := l_object_pk;
  end if;
  AK_QUERYOBJ_GRP.DOWNLOAD_QUERY_OBJECT (
    p_api_version_number => 1.0,
    p_init_msg_tbl => TRUE,
    p_msg_count => l_msg_count,
    p_msg_data => l_msg_data,
    p_return_status => l_return_status,
    p_application_id => l_appl_id,
    p_application_short_name => upper(l_appl_short_name),
	p_queryobj_pk_tbl => l_queryobj_pk_tbl
  );

elsif (upper(l_by_object) = 'AMPARAM_REGISTRY') then
  if (l_object_pk is not null and l_object_pk <> FND_API.G_MISS_CHAR) then
    l_amparamreg_pk_tbl(1).applicationmodule_defn_name := l_object_pk;
  end if;
  AK_AMPARAM_REGISTRY_GRP.DOWNLOAD_AMPARAM_REGISTRY (
    p_api_version_number => 1.0,
    p_init_msg_tbl => TRUE,
    p_msg_count => l_msg_count,
    p_msg_data => l_msg_data,
    p_return_status => l_return_status,
    p_application_id => l_appl_id,
    p_application_short_name => upper(l_appl_short_name),
	p_amparamreg_pk_tbl => l_amparamreg_pk_tbl
  );

else
  --dbms_output.put_line(upper(l_by_object) ||
  --     ' is invalid - it must be FLOW, REGION, OBJECT, ATTRIBUTE or SECURITY');
  FND_MESSAGE.SET_NAME('AK','AK_INVALID_BUSINESS_OBJECT');
  FND_MESSAGE.SET_TOKEN('INVALID',l_by_object);
  FND_MSG_PUB.Add;
end if;

  p_return_status := l_return_status;
  --dbms_output.put_line('Finish downloading at:' ||
  --                     to_char(sysdate, 'MON-DD HH24:MI:SS'));

  --dbms_output.put_line('Return status is: ' || l_return_status);
  --dbms_output.put_line('Return message: ' || l_msg_data);

  if FND_MSG_PUB.Count_Msg > 0 then
    FND_MSG_PUB.Reset;
    --dbms_output.put_line('Messages: ');
    for i in 1 .. FND_MSG_PUB.Count_Msg loop
      l_buffer_tbl(i + l_index) := FND_MSG_PUB.GET(p_encoded=>FND_API.G_FALSE);
    end loop;
    FND_MSG_PUB.Initialize;
  end if;

  --
  -- Add ending to log file
  --
  l_index := nvl(l_buffer_tbl.last,0) + 1;
  l_buffer_tbl(l_index) := '**********';
  l_index := l_index + 1;
  l_buffer_tbl(l_index) := to_char(sysdate, 'DY MON DD YYYY HH24:MI:SS');
  l_index := l_index + 1;
  l_buffer_tbl(l_index) := 'Finished processing application: '||l_appl_short_name;
  if (p_primary_key is not null and p_primary_key <> FND_API.G_MISS_CHAR) then
    l_index := l_index + 1;
	l_buffer_tbl(l_index) := 'Primary key: '||p_primary_key;
  end if;
  l_index := l_index + 1;
  FND_MESSAGE.SET_NAME('AK','AK_END_DOWNLOAD_SESSION');
  l_buffer_tbl(l_index) := FND_MESSAGE.GET;

  --
  -- Write all messages and ending to a log file
  --

  AK_ON_OBJECTS_PVT.WRITE_LOG_FILE (
    p_return_status => l_return_status,
    p_buffer_tbl => l_buffer_tbl,
    p_write_mode => AK_ON_OBJECTS_PUB.G_APPEND
  );

  --if (l_return_status = FND_API.G_RET_STS_SUCCESS) then
  --  dbms_output.put_line('Log file has been printed out to screen');
  --else
  --  dbms_output.put_line('Failed to write log file to Global PL/SQL table');
  --end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240)||' exec error' );
  WHEN NO_DATA_FOUND THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240)||' no data found' );
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
  if FND_MSG_PUB.Count_Msg > 0 then
    FND_MSG_PUB.Reset;
    --dbms_output.put_line('Messages: ');
    for i in 1 .. FND_MSG_PUB.Count_Msg loop
      l_buffer_tbl(i + l_index) := FND_MSG_PUB.GET(p_encoded=>FND_API.G_FALSE);
    end loop;
    FND_MSG_PUB.Initialize;
  end if;

  --
  -- Add ending to log file
  --
  l_index := nvl(l_buffer_tbl.last,0) + 1;
  l_buffer_tbl(l_index) := '**********';
  l_index := l_index + 1;
  l_buffer_tbl(l_index) := to_char(sysdate, 'DY MON DD YYYY HH24:MI:SS');
  l_index := l_index + 1;
  l_buffer_tbl(l_index) := 'Finished processing application: '||l_appl_short_name;
  if (p_primary_key is not null and p_primary_key <> FND_API.G_MISS_CHAR) then
    l_index := l_index + 1;
        l_buffer_tbl(l_index) := 'Primary key: '||p_primary_key;
  end if;
  l_index := l_index + 1;
  FND_MESSAGE.SET_NAME('AK','AK_END_DOWNLOAD_SESSION');
  l_buffer_tbl(l_index) := FND_MESSAGE.GET;
  --
  -- Write all messages and ending to a log file
  --

  AK_ON_OBJECTS_PVT.WRITE_LOG_FILE (
    p_return_status => l_return_status,
    p_buffer_tbl => l_buffer_tbl,
    p_write_mode => AK_ON_OBJECTS_PUB.G_APPEND
  );

end DOWNLOAD;

end AK_DOWNLOAD_GRP;

/
