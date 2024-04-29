--------------------------------------------------------
--  DDL for Package AK_AMPARAM_REGISTRY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AK_AMPARAM_REGISTRY_PVT" AUTHID CURRENT_USER as
/* $Header: akdvaprs.pls 120.2 2005/09/15 22:26:44 tshort noship $ */
G_PKG_NAME					VARCHAR2(30) := 'AK_AMPARAM_REGISTRY_PVT';

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
);

--=======================================================
--  Procedure   CREATE_AMPARAM_REGISTRY
--
--  Usage       Private API for creating amparam_registry objects. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--  Desc        Calls the private API to creates a amparam_registry object
--              using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
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
);

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
p_pass					IN		NUMBER := 2);

--=======================================================
--  Procedure   UPLOAD_AMPARAM_REGISTRY
--
--  Usage       Private API for loading amparam_registry objects from a
--              loader file to the database.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API reads the amparam_registry data
--              stored in the loader file currently being
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
p_pass                     IN      NUMBER := 1
);

END AK_AMPARAM_REGISTRY_PVT;

 

/
