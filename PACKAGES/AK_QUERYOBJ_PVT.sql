--------------------------------------------------------
--  DDL for Package AK_QUERYOBJ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AK_QUERYOBJ_PVT" AUTHID CURRENT_USER as
/* $Header: akdvqrys.pls 120.2 2005/09/15 22:27:00 tshort ship $ */
G_PKG_NAME					VARCHAR2(30) := 'AK_QUERYOBJ_PVT';
G_QUERY_OBJECT_REDO_TBL		AK_QUERYOBJ_PUB.queryobj_tbl_type;
G_LINE_REDO_TBL				AK_QUERYOBJ_PUB.queryobj_lines_Tbl_Type;
G_QUERY_OBJECT_REDO_INDEX	NUMBER := 0;
G_LINE_REDO_INDEX			NUMBER := 0;

--=======================================================
--  Procedure   DOWNLOAD_QUERY_OBJECT
--
--  Usage       Private API for downloading query objects. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API will extract the query objects selected
--              by application ID or by key values from the
--              database to the output file.
--              If a query object is selected for writing to the loader
--              file, all its children records query_object_lines
--              that references this object will also be written.
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
--              p_queryobj_pk_tbl : IN optional
--                  If given, only queyr objects whose key values are
--                  included in this table will be written to the
--                  output file.
--
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure DOWNLOAD_QUERY_OBJECT (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_application_id           IN      NUMBER := FND_API.G_MISS_NUM,
p_queryobj_pk_tbl          IN      AK_QUERYOBJ_PUB.queryObj_PK_Tbl_Type
:= AK_QUERYOBJ_PUB.G_MISS_QUERYOBJ_PK_TBL,
p_nls_language             IN      VARCHAR2
);

--=======================================================
--  Procedure   CREATE_QUERY_OBJECT
--
--  Usage       Private API for creating query objects. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--=======================================================

PROCEDURE CREATE_QUERY_OBJECT(
p_validation_level		IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number	IN		NUMBER,
p_init_msg_tbl			IN      BOOLEAN := FALSE,
p_msg_count				OUT NOCOPY		NUMBER,
p_msg_data				OUT NOCOPY		VARCHAR2,
p_return_status			OUT NOCOPY		VARCHAR2,
p_query_code			IN		VARCHAR2,
p_application_id		IN		NUMBER,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM,
p_loader_timestamp      IN      DATE := FND_API.G_MISS_DATE,
p_pass					IN		NUMBER := 2
);

--=======================================================
--  Procedure   CREATE_QUERY_OBJECT_LINE
--
--  Usage       Private API for creating query objects. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--=======================================================

PROCEDURE CREATE_QUERY_OBJECT_LINE(
p_validation_level		IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number	IN		NUMBER,
p_init_msg_tbl			IN      BOOLEAN := FALSE,
p_msg_count				OUT NOCOPY		NUMBER,
p_msg_data				OUT NOCOPY		VARCHAR2,
p_return_status			OUT NOCOPY		VARCHAR2,
p_query_code			IN		VARCHAR2,
p_seq_num				IN		NUMBER,
p_query_line_type 		IN		VARCHAR2,
p_query_line			IN		VARCHAR2 := FND_API.G_MISS_CHAR,
p_linked_parameter		IN		VARCHAR2 := FND_API.G_MISS_CHAR,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM,
p_loader_timestamp      IN      DATE := FND_API.G_MISS_DATE,
p_pass					IN		NUMBER := 2
);

--=======================================================
--  Procedure   UPLOAD_QUERY_OBJECT
--
--  Usage       Private API for loading query objects from a
--              loader file to the database.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API reads the query object data (including query
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
procedure UPLOAD_QUERY_OBJECT (
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

END AK_QUERYOBJ_PVT;

 

/
