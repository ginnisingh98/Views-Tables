--------------------------------------------------------
--  DDL for Package AK_AMPARAM_REGISTRY_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AK_AMPARAM_REGISTRY_GRP" AUTHID CURRENT_USER as
/* $Header: akdgaprs.pls 120.2 2005/09/15 22:26:30 tshort noship $ */

-- Global constants holding the package and file names to be used by
-- messaging routines in the case of an unexpected error.

G_PKG_NAME      CONSTANT    VARCHAR2(30) := 'AK_AMPARAM_REGISTRY_GRP';
--
-- Procedure specs
--
--=======================================================
--  Procedure   CREATE_AMPARAM_REGISTRY
--
--  Usage       Group API for creating a amparam_registry object
--
--  Desc        Calls the private API to creates a amparam_registry object
--              using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  amparam_registry object columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure CREATE_AMPARAM_REGISTRY (
p_validation_level			IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number			IN      NUMBER,
p_init_msg_tbl				IN      BOOLEAN := FALSE,
p_msg_count					OUT NOCOPY     NUMBER,
p_msg_data					OUT NOCOPY     VARCHAR2,
p_return_status				OUT NOCOPY     VARCHAR2,
p_applicationmodule_defn_name	IN      VARCHAR2,
p_param_name			IN	VARCHAR2,
p_param_value			IN	VARCHAR2,
p_application_id				IN      NUMBER
);


--========================================================
--  Procedure   DOWNLOAD_AMPARAM_REGISTRY
--
--  Usage       Group API for downloading amparam_registry objects
--
--  Desc        This API first write out standard loader
--              file header for attributes to a flat file.
--              Then it calls the private API to extract the
--              amparam_registry records selected by application ID or by
--              key values from the database to the output file.
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
--              One of the following three parameters must be given:
--
--              p_application_id : IN optional
--                  If given, all query objects for this application ID
--                  will be written to the output file.
--              p_application_short_name : IN optional
--                  If given, all query objects for this application short
--                  name will be written to the output file.
--                  Application short name will be ignored if an
--                  application ID is given.
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
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_nls_language             IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_application_id           IN      NUMBER := FND_API.G_MISS_NUM,
p_application_short_name   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_amparamreg_pk_tbl        IN      AK_AMPARAM_REGISTRY_PUB.AmParamReg_Pk_Tbl_Type :=
AK_AMPARAM_REGISTRY_PUB.G_MISS_AMPARAMREG_PK_TBL
);

end AK_AMPARAM_REGISTRY_GRP;

 

/
