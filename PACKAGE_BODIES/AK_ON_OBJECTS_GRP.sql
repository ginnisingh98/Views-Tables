--------------------------------------------------------
--  DDL for Package Body AK_ON_OBJECTS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AK_ON_OBJECTS_GRP" as
/* $Header: akdgonb.pls 120.2 2005/09/15 22:26:37 tshort ship $ */

--=======================================================
--  Procedure   UPLOAD
--
--  Usage       Group API for loading flows, objects, regions,
--              and attributes from a loader file to the database.
--              This API should be used for uploading all AK loader
--              files to a database.
--
--  Desc        This API calls the corresponding private API to read
--              the all flow, object, region, and attribute data
--              (including all the tables in these business objects)
--              from the loader file, and update them to the database.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure UPLOAD (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Upload';
l_return_status  varchar2(1);
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

-- Initialize the message table if requested.

if p_init_msg_tbl then
FND_MSG_PUB.initialize;
end if;

--  savepoint Start_upload;

--
-- Call private API to process the upload request
--
AK_ON_OBJECTS_PVT.UPLOAD (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status
);

if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
--    rollback to Start_upload;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--    rollback to Start_upload;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;

end UPLOAD;

end AK_ON_OBJECTS_GRP;

/
