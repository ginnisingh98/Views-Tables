--------------------------------------------------------
--  DDL for Package Body AK_AMPARAM_REGISTRY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AK_AMPARAM_REGISTRY_PVT" as
/* $Header: akdvaprb.pls 120.3 2005/09/15 22:49:22 tshort noship $ */

--=======================================================
--  Procedure   WRITE_TO_BUFFER (local procedure)
--
--  Usage       Local procedure for writing the given amparam_registry
--              and all its children records to the output file.
--              Not designed to be called from outside this package.
--
--  Desc        This procedure first retrieves and writes the given
--              object to the loader file. Then it calls other local
--              procedures to write all its object attributes and
--              foriegn and unique key definitions to the same output
--              file.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters
--              p_query_code : IN required
--                  Key value of the Object to be extracted to the loader
--                  file.
--              p_nls_language : IN required
--                  The NLS langauge that should be used when
--                  extracting data from the TL table
--=======================================================
procedure WRITE_TO_BUFFER (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_return_status            OUT NOCOPY     VARCHAR2,
p_applicationmodule_defn_name	 IN      VARCHAR2,
p_nls_language             IN      VARCHAR2
) is
cursor l_get_ap_registry_csr (param_query_code in varchar2) is
select *
from AK_AM_PARAMETER_REGISTRY
where APPLICATIONMODULE_DEFN_NAME = param_query_code
order by APPLICATIONMODULE_DEFN_NAME;

l_api_name           CONSTANT varchar2(30) := 'Write_to_buffer';
l_databuffer_tbl     AK_ON_OBJECTS_PUB.Buffer_Tbl_Type;
l_index              NUMBER;
l_ap_registry_rec    ak_am_parameter_registry%ROWTYPE;
l_return_status      varchar2(1);

begin
-- Retrieve object information from the database

open l_get_ap_registry_csr(p_applicationmodule_defn_name);
loop
fetch l_get_ap_registry_csr into l_ap_registry_rec;
exit when l_get_ap_registry_csr%notfound;

-- query Object line must be validated before it is written to the file
/* nothing to validate yet
if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
if not AK_AMPARAM_REGISTRY_PVT.VALIDATE_AP_REGISTRY (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_APPLICATIONMODULE_DEFN_NAME => l_ap_registry_rec.APPLICATIONMODULE_DEFN_NAME,
p_application_id => l_ap_registry_rec.application_id
)
then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_AP_REGISTRY_NOT_DOWNLOADED');
FND_MESSAGE.SET_TOKEN('KEY', p_APPLICATIONMODULE_DEFN_NAME);
FND_MSG_PUB.Add;
end if;
close l_get_ap_registry_csr;
raise FND_API.G_EXC_ERROR;
end if;
end if;
*/
-- Write object into buffer
l_index := 1;

l_databuffer_tbl(l_index) := 'BEGIN AMPARAM_REGISTRY "'||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_ap_registry_rec.APPLICATIONMODULE_DEFN_NAME)||'" "'||AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_ap_registry_rec.param_name)||'" "'||AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_ap_registry_rec.param_source)||'"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  APPLICATION_ID = ' ||
nvl(to_char(l_ap_registry_rec.application_id),'""');
l_index := l_index + 1;
l_databuffer_tbl(l_index) := 'END AMPARAM_REGISTRY ';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := ' ';

-- - Write object data out to the specified file
AK_ON_OBJECTS_PVT.WRITE_FILE (
p_return_status => l_return_status,
p_buffer_tbl => l_databuffer_tbl,
p_write_mode => AK_ON_OBJECTS_PUB.G_APPEND
);
-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
close l_get_ap_registry_csr;
RAISE FND_API.G_EXC_ERROR;
end if;

l_databuffer_tbl.delete;

if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
close l_get_ap_registry_csr;
RAISE FND_API.G_EXC_ERROR;
end if;

-- - Finish up writing object data out to the specified file
AK_ON_OBJECTS_PVT.WRITE_FILE (
p_return_status => l_return_status,
p_buffer_tbl => l_databuffer_tbl,
p_write_mode => AK_ON_OBJECTS_PUB.G_APPEND
);

-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
close l_get_ap_registry_csr;
RAISE FND_API.G_EXC_ERROR;
end if;
end loop;
close l_get_ap_registry_csr;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN VALUE_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_AP_REGISTRY_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY', p_APPLICATIONMODULE_DEFN_NAME);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_AP_REGISTRY_NOT_DOWNLOADED');
FND_MESSAGE.SET_TOKEN('KEY', p_APPLICATIONMODULE_DEFN_NAME);
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
--  Procedure   DOWNLOAD_AMPARAM_REGISTRY
--
--  Usage       Private API for downloading amparam_registry objects. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API will extract the amparam_registry objects selected
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
--                  given in p_object_pk_tbl.
--              p_amparamreg_pk_tbl : IN optional
--                  If given, only amparam_registry objects whose key values are
--                  included in this table will be written to the
--                  output file.
--
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure DOWNLOAD_AMPARAM_REGISTRY (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_application_id           IN      NUMBER := FND_API.G_MISS_NUM,
p_amparamreg_pk_tbl        IN      AK_AMPARAM_REGISTRY_PUB.AmParamReg_Pk_Tbl_Type :=
AK_AMPARAM_REGISTRY_PUB.G_MISS_AMPARAMREG_PK_TBL,
p_nls_language             IN      VARCHAR2
) is
cursor l_get_ap_registry_list_csr (appl_id_parm in number) is
select APPLICATIONMODULE_DEFN_NAME
from ak_am_parameter_registry
where APPLICATION_ID = appl_id_parm;
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Download_AP_Registry';
l_application_id     NUMBER;
l_query_code         VARCHAR2(30);
l_index              NUMBER;
l_last_orig_index    NUMBER;
l_msg_count          NUMBER;
l_msg_data           VARCHAR2(2000);
l_amparamreg_pk_tbl  AK_AMPARAM_REGISTRY_PUB.amparamreg_Pk_Tbl_Type;
l_return_status      varchar2(1);
begin
IF NOT FND_API.Compatible_API_Call (
l_api_version_number, p_api_version_number, l_api_name,
G_PKG_NAME) then
-- dbms_output.put_line('API error in AK_OBJECTS2_PVT');
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
return;
END IF;

-- Check that one of the following selection criteria is given:
-- - p_application_id alone, or
-- - query codes in p_queryobj_PK_tbl

if (p_application_id = FND_API.G_MISS_NUM) or (p_application_id is null) then
if (p_amparamreg_pk_tbl.count = 0) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_NO_SELECTION');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;
else
if (p_amparamreg_pk_tbl.count > 0) then
-- both application ID and a list of objects to be extracted are
-- given, issue a warning that we will ignore the application ID
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_APPL_ID_IGNORED');
FND_MSG_PUB.Add;
end if;
end if;
end if;

-- If selecting by application ID, first load a query object primary key table
-- with the query codes of all query objects for the given application ID.
-- If selecting by a list of query objects, simply copy the query object unique key
-- table with the parameter
if (p_amparamreg_pk_tbl.count > 0) then
l_amparamreg_pk_tbl := p_amparamreg_pk_tbl;
else
l_index := 1;
open l_get_ap_registry_list_csr(p_application_id);
loop
fetch l_get_ap_registry_list_csr into l_amparamreg_pk_tbl(l_index);
exit when l_get_ap_registry_list_csr%notfound;
l_index := l_index + 1;
end loop;
close l_get_ap_registry_list_csr;
end if;

-- Put index pointing to the first record of the query objects primary key table
l_index := l_amparamreg_pk_tbl.FIRST;

-- Write details for each selected query object, including its query
-- object lines to a buffer to be passed back to the calling procedure.
--

while (l_index is not null) loop
-- Write object information from the database

--dbms_output.put_line('writing object #'||to_char(l_index) || ':' ||
--                      l_queryobj_pk_tbl(l_index).query_code);

WRITE_TO_BUFFER(
p_validation_level => p_validation_level,
p_return_status => l_return_status,
p_applicationmodule_defn_name => l_amparamreg_pk_tbl(l_index).APPLICATIONMODULE_DEFN_NAME,
p_nls_language => p_nls_language
);
-- Download aborts if any of the validation fails
--
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
--	  dbms_output.put_line('error throwing from WRITE_TO_BUFFER');
RAISE FND_API.G_EXC_ERROR;
end if;

-- Ready to download the next object in the list
l_index := l_amparamreg_pk_tbl.NEXT(l_index);

end loop;

p_return_status := FND_API.G_RET_STS_SUCCESS;

-- dbms_output.put_line('returning from ak_object_pvt.download_query_object: ' ||
--                        to_char(sysdate, 'MON-DD HH24:MI:SS'));

EXCEPTION
WHEN VALUE_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_APREG_PK_VALUE_ERROR');
FND_MSG_PUB.Add;
end if;
-- dbms_output.put_line('Value error occurred in download- check your object list.');
p_return_status := FND_API.G_RET_STS_ERROR;
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
end DOWNLOAD_AMPARAM_REGISTRY;


--=======================================================
--  Procedure   VALIDATE_AP_REGISTRY (local procedure)
--  not being used yet
--=======================================================

FUNCTION VALIDATE_AP_REGISTRY (
p_validation_level			IN	NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number		IN	NUMBER,
p_return_status				OUT NOCOPY	VARCHAR2,
p_APPLICATIONMODULE_DEFN_NAME	IN	VARCHAR2,
p_application_id			IN	NUMBER,
p_pass						IN	NUMBER := 2
) RETURN BOOLEAN IS

l_error			boolean;
l_return_status varchar2(1);
l_api_name		CONSTANT	varchar2(30) := 'VALIDATE_AP_REGISTRY';

BEGIN
if ( not (AK_ON_OBJECTS_PVT.VALID_APPLICATION_ID(
p_api_version_number,
l_return_status,
p_application_id) ) ) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_COLUMN_VALUE');
FND_MESSAGE.SET_TOKEN('COLUMN','APPLICATION_ID');
FND_MSG_PUB.Add;
end if;
end if;
p_return_status := FND_API.G_RET_STS_SUCCESS;
return (not l_error);

EXCEPTION
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;

END VALIDATE_AP_REGISTRY;

--=======================================================
--  Function   AMPARAM_REGISTRY_EXISTS
--
--  Usage       Private API for checking existence of amparam_registry. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--=======================================================

FUNCTION AMPARAM_REGISTRY_EXISTS (
p_api_version_number	in	number,
p_return_status			out NOCOPY	varchar2,
p_applicationmodule_defn_name	IN      VARCHAR2,
p_param_name			IN		VARCHAR2,
p_param_value			IN		VARCHAR2,
p_application_id		in	number
) RETURN BOOLEAN IS
CURSOR l_chk_amparam_exists_csr (appmodule_defn_name_param in varchar2,
param_name_param in varchar2, param_value_param in varchar2) is
select 1
from ak_am_parameter_registry
where APPLICATIONMODULE_DEFN_NAME = appmodule_defn_name_param
and PARAM_NAME = param_name_param
and param_source = param_value_param;
l_dummy			number;
l_api_name		constant	varchar2(30) := 'AMPARAM_REGISTRY_EXISTS';
l_api_version_number      CONSTANT number := 1.0;
BEGIN
IF NOT FND_API.Compatible_API_Call (
l_api_version_number, p_api_version_number, l_api_name,
G_PKG_NAME) then
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
return FALSE;
END IF;

open l_chk_amparam_exists_csr(p_APPLICATIONMODULE_DEFN_NAME, p_param_name, p_param_value);
fetch l_chk_amparam_exists_csr into l_dummy;
if (l_chk_amparam_exists_csr%notfound) then
close l_chk_amparam_exists_csr;
p_return_status := FND_API.G_RET_STS_SUCCESS;
return FALSE;
else
close l_chk_amparam_exists_csr;
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
END AMPARAM_REGISTRY_EXISTS;


--=======================================================
--  Procedure   CREATE_AMPARAM_REGISTRY
--
--  Usage       Private API for creating amparam_registry objects. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Creates a region using the given info.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Query Object columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will create the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--=======================================================

PROCEDURE CREATE_AMPARAM_REGISTRY(
p_validation_level		IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number	IN		NUMBER,
p_init_msg_tbl			IN      BOOLEAN := FALSE,
p_msg_count				OUT NOCOPY		NUMBER,
p_msg_data				OUT NOCOPY		VARCHAR2,
p_return_status			OUT NOCOPY		VARCHAR2,
p_applicationmodule_defn_name	IN      VARCHAR2,
p_param_name			IN		VARCHAR2,
p_param_value			IN		VARCHAR2,
p_application_id		IN		NUMBER,
p_loader_timestamp      IN      DATE := FND_API.G_MISS_DATE,
p_pass					IN		NUMBER := 2
) IS
l_api_version_number	CONSTANT number := 1.0;
l_api_name				constant	varchar2(30) := 'CREATE_AMPARAM_REGISTRY';
l_return_status			varchar2(1);
l_created_by              number;
l_creation_date           date;
l_last_update_date        date;
l_last_update_login       number;
l_last_updated_by         number;
BEGIN
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

savepoint start_create_amparam;

--** check to see if row already exists **
if AK_AMPARAM_REGISTRY_PVT.AMPARAM_REGISTRY_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_applicationmodule_defn_name => p_applicationmodule_defn_name,
p_param_name => p_param_name,
p_param_value => p_param_value,
p_application_id => p_application_id) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_AMPARAM_REGISTRY_EXISTS');
FND_MSG_PUB.Add;
end if;
-- dbms_output.put_line(G_PKG_NAME || 'Error - Row already exists');
raise FND_API.G_EXC_ERROR;
end if;

-- Create record if no validation error was found
/*
-- Set WHO columns
AK_ON_OBJECTS_PVT.SET_WHO (
p_return_status => l_return_status,
p_loader_timestamp => p_loader_timestamp,
p_created_by => l_created_by,
p_creation_date => l_creation_date,
p_last_updated_by => l_last_updated_by,
p_last_update_date => l_last_update_date,
p_last_update_login => l_last_update_login);
*/

insert into AK_AM_PARAMETER_REGISTRY (
APPLICATIONMODULE_DEFN_NAME,
PARAM_NAME,
PARAM_SOURCE,
APPLICATION_ID
) values (
p_applicationmodule_defn_name,
p_param_name,
p_param_value,
p_application_id);

if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
FND_MESSAGE.SET_NAME('AK','AK_AMPARAM_REGISTRY_CREATED');
FND_MESSAGE.SET_TOKEN('KEY', p_applicationmodule_defn_name);
FND_MSG_PUB.Add;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

EXCEPTION
WHEN VALUE_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_AMPARAM_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY', p_applicationmodule_defn_name);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_amparam;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_AMPARAM_NOT_CREATED');
FND_MESSAGE.SET_TOKEN('KEY', p_applicationmodule_defn_name);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_amparam;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_create_amparam;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

END CREATE_AMPARAM_REGISTRY;

--=======================================================
--  Procedure   UPDATE_AMPARAM_REGISTRY
--
--  Usage       Private API for updating amparam_registry objects. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Updates a amparam_registry using the given info.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Query Object columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will create the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--=======================================================

PROCEDURE UPDATE_AMPARAM_REGISTRY(
p_validation_level		IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number	IN		NUMBER,
p_init_msg_tbl			IN      BOOLEAN := FALSE,
p_msg_count				OUT NOCOPY		NUMBER,
p_msg_data				OUT NOCOPY		VARCHAR2,
p_return_status			OUT NOCOPY		VARCHAR2,
p_applicationmodule_defn_name	IN      VARCHAR2,
p_param_name			IN		VARCHAR2,
p_param_value			IN		VARCHAR2,
p_application_id		IN		NUMBER,
p_loader_timestamp      IN      DATE := FND_API.G_MISS_DATE,
p_pass					IN		NUMBER := 2
) IS
cursor l_get_amparam_registry_csr is
select *
from  AK_AM_PARAMETER_REGISTRY
where APPLICATIONMODULE_DEFN_NAME = p_applicationmodule_defn_name
for update of APPLICATION_ID;

l_api_version_number      CONSTANT number := 1.0;
l_api_name                CONSTANT varchar2(30) := 'Update_AmPara_Registry';
l_amparam_reg_rec            AK_AM_PARAMETER_REGISTRY%ROWTYPE;
l_created_by              number;
l_creation_date           date;
l_last_update_date        date;
l_last_update_login       number;
l_last_updated_by         number;
l_return_status           varchar2(1);
BEGIN
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

savepoint start_update_amparam;

--** retrieve ak_regions row if it exists **
open l_get_amparam_registry_csr;
fetch l_get_amparam_registry_csr into l_amparam_reg_rec;
if (l_get_amparam_registry_csr%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_QUERYOBJ_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
--dbms_output.put_line(l_api_name || 'Error - Row does not exist');
close l_get_amparam_registry_csr;
raise FND_API.G_EXC_ERROR;
end if;
close l_get_amparam_registry_csr;

if ( NOT AK_ON_OBJECTS_PVT.VALID_APPLICATION_ID (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_application_id => p_application_id) ) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_COLUMN_VALUE');
FND_MESSAGE.SET_TOKEN('COLUMN','APPLICATION_ID');
FND_MSG_PUB.Add;
raise FND_API.G_EXC_ERROR;
end if;

l_amparam_reg_rec.application_id := p_application_id;

-- Set WHO columns
/*
AK_ON_OBJECTS_PVT.SET_WHO (
p_return_status => l_return_status,
p_loader_timestamp => p_loader_timestamp,
p_created_by => l_created_by,
p_creation_date => l_creation_date,
p_last_updated_by => l_last_updated_by,
p_last_update_date => l_last_update_date,
p_last_update_login => l_last_update_login);
*/

update AK_AM_PARAMETER_REGISTRY set
application_id = l_amparam_reg_rec.application_id
where applicationmodule_defn_name = p_applicationmodule_defn_name
and param_name = p_param_name
and param_source = p_param_value;

if (sql%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_QUERYOBJ_UPDATE_FAILED');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
FND_MESSAGE.SET_NAME('AK','AK_AMPARAM_REG_UPDATED');
FND_MESSAGE.SET_TOKEN('KEY', p_applicationmodule_defn_name);
FND_MSG_PUB.Add;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

EXCEPTION
WHEN VALUE_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_AMPARAM_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY', p_applicationmodule_defn_name);
FND_MSG_PUB.Add;
end if;
rollback to start_update_amparam;
p_return_status := FND_API.G_RET_STS_ERROR;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_AMPARAM_REG_NOT_UPDATED');
FND_MESSAGE.SET_TOKEN('KEY', p_applicationmodule_defn_name);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_update_amparam;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_update_amparam;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

END UPDATE_AMPARAM_REGISTRY;

--=======================================================
--  Procedure   UPLOAD_AMPARAM_REGISTRY
--
--  Usage       Private API for loading amparam_registry objects from a
--              loader file to the database.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API reads the amparam_registry data
--              object lines) stored in the loader file currently being
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
procedure UPLOAD_AMPARAM_REGISTRY (
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
p_pass                     IN      NUMBER := 1 -- we don't need 2 passes for query objects, changed from 2 to 1 to match spec for 9i
) is
l_api_version_number       CONSTANT number := 1.0;
l_api_name                 CONSTANT varchar2(30) := 'Upload_AmParam_Registry';
l_buffer                   AK_ON_OBJECTS_PUB.Buffer_Type;
l_column                   varchar2(30);
l_dummy                    NUMBER;
l_eof_flag                 VARCHAR2(1);
l_index                    NUMBER;
l_line_num                 NUMBER;
l_lines_read               NUMBER;
l_more_apregistry		 BOOLEAN := TRUE;
l_msg_count                NUMBER;
l_msg_data                 VARCHAR2(2000);
l_amparam_index             NUMBER := 0;
l_amparam_rec              ak_am_parameter_registry%ROWTYPE;
l_empty_amparam_rec        ak_am_parameter_registry%ROWTYPE;
l_amparam_tbl              AK_AMPARAM_REGISTRY_PUB.amparamreg_Tbl_Type;
l_return_status            varchar2(1);
l_saved_token              AK_ON_OBJECTS_PUB.Buffer_Type;
l_state                    NUMBER;
l_token                    AK_ON_OBJECTS_PUB.Buffer_Type;
l_value_count              NUMBER;
l_copy_redo_flag           BOOLEAN := FALSE;
l_user_id1				 NUMBER;
l_user_id2				 NUMBER;
begin

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
-- the tokens 'BEGIN AMPARAM_REGISTRY' has already been parsed. Set initial
-- buffer to 'BEGIN AMPARAM_REGISTRY' before reading the next line from the
-- file. Otherwise, set initial buffer to null.
--
if (p_loader_timestamp <> FND_API.G_MISS_DATE) then
l_buffer := 'BEGIN AMPARAM_REGISTRY ' || p_buffer;
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
and (l_more_apregistry) loop

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
-- AM_PARAM_REGISTRY (states 0 - 19)
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
if (l_token = 'AMPARAM_REGISTRY') then
--== Clear out previous column data  ==--
l_amparam_rec := AK_AMPARAM_REGISTRY_PUB.G_MISS_AMPARAMREG_REC;
l_state := 2;
else
-- Found the beginning of a non-region object,
-- rebuild last line and pass it back to the caller
-- (ak_on_objects_pvt.upload).
p_buffer_out := 'BEGIN ' || l_token || ' ' || l_buffer;
l_more_apregistry := FALSE;
end if;
elsif (l_state = 2) then
if (l_token is not null) then
l_amparam_rec.applicationmodule_defn_name := l_token;
l_state := 3;
else
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
FND_MESSAGE.SET_TOKEN('EXPECTED','APPLICATIONMODULE_DEFN_NAME');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;
elsif (l_state = 3) then
if (l_token is not null) then
l_amparam_rec.param_name := l_token;
l_state := 4;
else
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
FND_MESSAGE.SET_TOKEN('EXPECTED','PARAM_NAME');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;
elsif ( l_state = 4) then
if (l_token is not null) then
l_amparam_rec.param_source := l_token;
l_state := 10;
l_value_count := null;
else
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
FND_MESSAGE.SET_TOKEN('EXPECTED','PARAM_VALUE');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;
elsif (l_state = 10) then
if (l_token = 'END') then
l_state := 19;
elsif (l_token = 'APPLICATION_ID') then
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
FND_MESSAGE.SET_TOKEN('TOKEN', l_token||'(debug: l_buffer = '||l_buffer||' l_state = '||to_char(l_state)||')');
else
FND_MESSAGE.SET_TOKEN('TOKEN',l_saved_token);
end if;
FND_MESSAGE.SET_TOKEN('EXPECTED','AMPARAM_REGISTRY');
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
if (l_column = 'APPLICATION_ID') then
l_amparam_rec.application_id := to_number(l_token);
l_state := 10;
else
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
FND_MESSAGE.SET_TOKEN('TOKEN',l_token||' (debug: l_buffer = '||l_buffer||' l_state = '||to_char(l_state)||')');
FND_MESSAGE.SET_TOKEN('EXPECTED', l_column);
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;
elsif (l_state = 19) then
if (l_token = 'AMPARAM_REGISTRY') then
if AK_AMPARAM_REGISTRY_PVT.AMPARAM_REGISTRY_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_applicationmodule_defn_name	=> l_amparam_rec.applicationmodule_defn_name,
p_param_name => l_amparam_rec.param_name,
p_param_value	=> l_amparam_rec.param_source,
p_application_id => l_amparam_rec.application_id) then
if ( AK_UPLOAD_GRP.G_UPDATE_MODE ) then
AK_AMPARAM_REGISTRY_PVT.UPDATE_AMPARAM_REGISTRY(
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_applicationmodule_defn_name	=> l_amparam_rec.applicationmodule_defn_name,
p_param_name => l_amparam_rec.param_name,
p_param_value	=> l_amparam_rec.param_source,
p_application_id => l_amparam_rec.application_id,
p_loader_timestamp => p_loader_timestamp,
p_pass => p_pass);
end if;
else
AK_AMPARAM_REGISTRY_PVT.CREATE_AMPARAM_REGISTRY(
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_applicationmodule_defn_name	=> l_amparam_rec.applicationmodule_defn_name,
p_param_name => l_amparam_rec.param_name,
p_param_value	=> l_amparam_rec.param_source,
p_application_id => l_amparam_rec.application_id,
p_loader_timestamp => p_loader_timestamp,
p_pass => p_pass);

end if;
--
-- If API call returns with an error status, upload aborts
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if; -- /* if l_return_status */
l_state := 0;
else
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
FND_MESSAGE.SET_TOKEN('TOKEN',l_token||' (debug: l_buffer = '||l_buffer||' l_state = '||to_char(l_state)||')');
FND_MESSAGE.SET_TOKEN('EXPECTED', 'AMPARAM_REGISTRY');
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
if (l_state <> 0) and (l_more_apregistry) then
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
-- Load line number of the last file line processed
--
p_line_num_out := l_line_num;

p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to Start_Upload;
WHEN VALUE_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
FND_MESSAGE.SET_NAME('AK','AK_REGION_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY',l_amparam_rec.applicationmodule_defn_name);
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
end UPLOAD_AMPARAM_REGISTRY;

end AK_AMPARAM_REGISTRY_PVT;

/
