--------------------------------------------------------
--  DDL for Package Body AK_DELETE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AK_DELETE_GRP" as
/* $Header: akgdeldb.pls 120.2 2005/09/15 22:27:04 tshort noship $ */

procedure DELETE (
p_business_object  IN  VARCHAR2,
p_appl_short_name  IN  VARCHAR2,
p_primary_key      IN  VARCHAR2 := FND_API.G_MISS_CHAR,
p_return_status   OUT NOCOPY VARCHAR2,
p_delete_cascade   IN  VARCHAR2 := 'Y'
) is
cursor l_get_appl_id_csr (short_name_param varchar2) is
select application_id
from   fnd_application
where  application_short_name = short_name_param;
l_api_name          CONSTANT varchar2(30) := 'Delete';
l_appl_short_name   varchar2(30);
l_appl_id           NUMBER;
l_buffer_tbl        AK_ON_OBJECTS_PUB.Buffer_Tbl_Type;
l_by_object         varchar2(30);
l_index             number;
l_index2            number;
l_msg_count         number;
l_msg_data          varchar2(2000);
l_return_boolean    BOOLEAN;
l_return_status     VARCHAR2(1);
l_string_pos        number;
l_table_index       number;
l_dum               NUMBER;
l_object_pk         varchar2(30) := FND_API.G_MISS_CHAR;
l_flow_pk_tbl       AK_FLOW_PUB.Flow_PK_Tbl_Type;
l_region_pk_tbl     AK_REGION_PUB.Region_PK_Tbl_Type;
l_custom_pk_tbl     AK_CUSTOM_PUB.Custom_PK_Tbl_Type;
l_object_pk_tbl     AK_OBJECT_PUB.Object_PK_Tbl_Type;
l_sec_pk_tbl        AK_SECURITY_PUB.Resp_PK_Tbl_Type;
l_attr_pk_tbl       AK_ATTRIBUTE_PUB.Attribute_PK_Tbl_Type;
l_queryobj_pk_tbl   AK_QUERYOBJ_PUB.QueryObj_PK_Tbl_Type;

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
else
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_PRIMARY_KEY_INVALID');
FND_MESSAGE.SET_TOKEN('PRIMARY_KEY', p_primary_key);
FND_MSG_PUB.Add;
end if;
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
AK_ON_OBJECTS_PUB.G_LOAD_MODE := 'DELETE';

-- set G_WRITE_HEADER to indicate writing the header or not
--
--  open l_check_table_csr;
--  fetch l_check_table_csr into l_dum;
--  if l_check_table_csr%NOTFOUND then
--    G_WRITE_HEADER := TRUE;
--  else
--    G_WRITE_HEADER := FALSE;
--  end if;
--  close l_check_table_csr;

--
-- Load buffer table with log file heading info to be written
-- to the log file
--
l_index := 1;
l_buffer_tbl(l_index) := '**********';

l_index := l_index + 1;
FND_MESSAGE.SET_NAME('AK','AK_START_DELETE_SESSION');
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
if (upper(l_by_object) = 'REGION') then
AK_REGION_GRP.DELETE_REGION (
--    p_validation_level => FND_API.G_VALID_LEVEL_NONE,
p_api_version_number => 1.0,
p_init_msg_tbl => TRUE,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_region_application_id => l_appl_id,
p_region_code => upper(l_object_pk),
p_delete_cascade => p_delete_cascade
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
FND_MESSAGE.SET_NAME('AK','AK_END_DELETE_SESSION');
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
WHEN NO_DATA_FOUND THEN
p_return_status := FND_API.G_RET_STS_ERROR;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );

end DELETE;

end AK_DELETE_GRP;

/
