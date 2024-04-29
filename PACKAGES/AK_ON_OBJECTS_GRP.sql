--------------------------------------------------------
--  DDL for Package AK_ON_OBJECTS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AK_ON_OBJECTS_GRP" AUTHID CURRENT_USER as
/* $Header: akdgons.pls 120.2 2005/09/15 22:26:38 tshort ship $ */

-- Global constants holding the package and file names to be used by
-- messaging routines in the case of an unexpected error.

G_PKG_NAME      CONSTANT    VARCHAR2(30) := 'AK_ON_OBJECTS_GRP';

--
-- Procedure specs
--
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
  p_msg_count                OUT NOCOPY    NUMBER,
  p_msg_data                 OUT NOCOPY    VARCHAR2,
  p_return_status            OUT NOCOPY    VARCHAR2
);

end AK_ON_OBJECTS_GRP;

 

/
