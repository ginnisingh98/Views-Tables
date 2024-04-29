--------------------------------------------------------
--  DDL for Package AK_ON_OBJECTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AK_ON_OBJECTS_PVT" AUTHID CURRENT_USER as
/* $Header: akdvons.pls 120.3 2005/09/15 22:18:29 tshort ship $ */

-- Global constants holding the package and file names to be used by
-- messaging routines in the case of an unexpected error.

G_PKG_NAME      CONSTANT    VARCHAR2(30) := 'AK_ON_OBJECTS_PVT';

-- Constants for use across different AK private APIs
G_MAX_FILE_LINE_LEN    CONSTANT NUMBER := 80;
G_CREATE        CONSTANT    VARCHAR2(1) := 'C';
G_DOWNLOAD      CONSTANT    VARCHAR2(1) := 'D';
G_UPDATE        CONSTANT    VARCHAR2(1) := 'U';

G_ATTRIBUTE     CONSTANT    VARCHAR2(10) := 'ATTRIBUTE';
G_FLOW          CONSTANT    VARCHAR2(10) := 'FLOW';
G_OBJECT        CONSTANT    VARCHAR2(10) := 'OBJECT';
G_REGION        CONSTANT    VARCHAR2(10) := 'REGION';
G_CUSTOM_REGION CONSTANT    VARCHAR2(15) := 'CUSTOM_REGION';
G_SECURITY      CONSTANT    VARCHAR2(10) := 'SECURITY';
G_QUERYOBJ	CONSTANT    VARCHAR2(10) := 'QUERYOBJ';
G_AMPARAM_REGISTRY	CONSTANT	VARCHAR2(20) := 'AMPARAM_REGISTRY';

-- PL/SQL tables for log file in upload and download
G_LOG_BUFFER_TBL			AK_ON_OBJECTS_PUB.Buffer_Tbl_Type;

-- Write mode of output file
G_WRITE_MODE	VARCHAR2(1);

-- Index for AK_LOADER_TEMP
G_TBL_INDEX     NUMBER;

-- Total number of records in AK_LOADER_TEMP for upload
G_UPL_TABLE_NUM	NUMBER;

-- Current session id
G_SESSION_ID  NUMBER;

--Procedures for use by AK private APIs internal use

--==============================================
--  Procedure   APPEND_BUFFER_TABLES
--
--  Usage       Private procedure for appending one buffer table to the
--              end of another buffer table.
--              This procedure is intended to be called only by other APIs
--              that are owned by the Core Modules Team (AK)
--
--  Desc        Appends all elements in the from_table to the end of the
--              to_table. Both tables must be of type Buffer_Table_Type.
--
--  Results     The procedure returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_from_table : IN required
--                  The from buffer table containing elements to be
--                  appended to the end of the to buffer table.
--              p_to_table : IN OUT
--                  The target buffer table which will have the elements
--                  in the from table appended to it.
--==============================================
procedure APPEND_BUFFER_TABLES (
p_return_status            OUT NOCOPY     VARCHAR2,
p_from_table               IN      AK_ON_OBJECTS_PUB.Buffer_Tbl_Type,
p_to_table                 IN OUT NOCOPY  AK_ON_OBJECTS_PUB.Buffer_Tbl_Type
);


--==============================================
--  Procedure   DOWNLOAD_HEADER
--
--  Usage       Private procedure for writing standard header information
--              to a loader file.
--              This procedure is intended to be called only by other APIs
--              that are owned by the Core Modules Team (AK)
--
--  Desc        This procedure writes all the standard header information
--              including the DEFINE section to the loader file.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_nls_language : IN optional
--                  The NLS language of the database. If this is omitted,
--                  the default NLS language defined in the database
--                  will be used.
--              p_application_id : IN optional
--                  The application ID to be used to extract data from
--                  the database. If p_application_id is omitted, then
--                  either p_application_short_name must be given, or
--                  p_table_size must be greater than 0.
--              p_application_short_name : IN optional
--                  The application short name to be used to extract data
--                  from the database. If p_application_short_name is
--                  not provided, then either p_application_id must be
--                  given, or p_table_size must be greater than 0.
--                  p_application_short_name will be ignored if
--                  p_application_id is given.
--              p_table_size : IN required
--                  The size of the PL/SQL table containing the list of
--                  flows, objects, regions, or attributes to be extracted
--                  from the database. If p_table_size is 0, then either
--                  p_application_id or p_application_short_name must
--                  be provided.
--              p_download_by_object : IN required
--                  Must be one of the following literal defined in
--                  AK_ON_OBJECTS_PVT package:
--                    G_ATTRIBUTE - Caller is DOWNLOAD_ATTRIBUTE API
--                    G_OBJECT    - Caller is DOWNLOAD_OBJECT API
--                    G_REGION    - Caller is DOWNLOAD_REGION API
--                    G_FLOW      - Caller is DOWNLOAD_FLOW API
--                  This parameter is used to determine which portions
--                  of the DEFINE section should be written to the file.
--              p_nls_language_out : OUT
--                  This parameter will be loaded with p_nls_language if
--                  one is given, or with the default NLS language in the
--                  database if p_nls_language is not provided.
--              p_application_id_out : OUT
--                  This parameter will be loaded with p_application_id if
--                  one is given, or with the application ID of the
--                  p_application_short_name parameter if no application ID
--                  is provided. If both p_application_short_name and
--                  p_application_id are not given, the p_application_id_out
--                  will be null.
--==============================================
procedure DOWNLOAD_HEADER (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_nls_language             IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_application_id           IN      NUMBER := FND_API.G_MISS_NUM,
p_application_short_name   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_table_size               IN      NUMBER,
p_download_by_object       IN      VARCHAR2,
p_nls_language_out         OUT NOCOPY     VARCHAR2,
p_application_id_out       OUT NOCOPY     NUMBER
);

--=======================================================
--  Procedure   GET_TOKEN
--
--  Usage       Private procedure for returning the first token from
--              the given input string.
--              This function is intended to be called only by other APIs
--              that are owned by the Core Modules Team (AK)
--
--  Desc        This procedure parses the input string and returns the first
--              token in the string. It then removes that token from the
--              input string.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error (including parse error, such as empty input string)
--                  * Success
--              The procedure returns the first token in the input string
--              in the p_token parameter. It also removes the token from
--              the input string.
--  Parameters  p_in_buf : IN OUT
--                  The input string to be parsed. The procedure would
--                  remove the first token from this string before
--                  passing it back to the calling API.
--              p_token : OUT
--                  The first token parsed in the input string, with
--                  all the escaped characters in the token already
--                  replaced with their original characters.
--=======================================================
procedure GET_TOKEN (
p_return_status            OUT NOCOPY     VARCHAR2,
p_in_buf                   IN OUT NOCOPY  VARCHAR2,
p_token                    OUT NOCOPY     VARCHAR2
);

--=======================================================
--  Procedure   READ_LINE
--
--  Usage       Private procedure for reading the next line from a file.
--              This function is intended to be called only by other APIs
--              that are owned by the Core Modules Team (AK)
--
--  Desc        This procedure reads the next logical line from a flat file
--              whose file handle is given as the p_file_handle parameter.
--              This means that the file to be read must already be opened.
--              A logical line may contain many physical lines in the
--              file, each except the last physical line has  a trailing
--              character indicating that the line is to be continued.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              The procedure returns the data read from the file into
--              the p_buffer parameter. It also return the number of physical
--              lines read when reading the next logical line through the
--              p_lines_read parameter. If the end-of-file is reached, the
--              p_eof_flag will be loaded with 'Y'.
--  Parameters  p_file_handle : IN required
--                  The file handle of the file to be read.
--              p_buffer : OUT
--                  The buffer where the logical line read from the file
--                  will be loaded.
--              p_lines_read : OUT
--                  The number of lines read from the file when reading
--                  the current logical line
--              p_eof_flag : OUT
--                  This flag will be loaded with 'Y' if the procedure
--                  has encountered the end-of-file while trying to read
--                  the next line from the file.
--  Notes       This procedure will NOT close the file after the last
--              line is read - the caller must close the file by calling
--              the CLOSE_FILE API.
--=======================================================
PROCEDURE READ_LINE (
p_return_status           OUT NOCOPY     VARCHAR2,
p_index                   IN OUT NOCOPY  Number,
p_buffer                  OUT NOCOPY     AK_ON_OBJECTS_PUB.Buffer_Type,
p_lines_read              OUT NOCOPY     number,
p_eof_flag                OUT NOCOPY     VARCHAR2,
p_upl_loader_cur			IN OUT NOCOPY  AK_ON_OBJECTS_PUB.LoaderCurTyp
);


--==============================================
--  Function   REPLACE_SPECIAL_CHARS
--
--  Usage       Private function for replacing all special characters
--              with escaped characters.
--              This function is intended to be called only by other APIs
--              that are owned by the Core Modules Team (AK)
--
--  Desc        Replaces all special characters in the input string
--              with the corresponding escaped characters, for instance,
--              the 'tab' character will be replaced by 't'.
--
--  Results     The procedure returns a string which is the result of
--              replacing all special characters with their corresponding
--              escaped characters.
--  Parameters  p_buffer : IN required
--                  The input string with special characters.
--==============================================
function REPLACE_SPECIAL_CHAR (
p_buffer                   IN      VARCHAR2
) return VARCHAR2;

--=======================================================
--  Procedure   SET_WHO
--
--  Usage       Private procedure for setting the who columns values.
--              This function is intended to be called only by other APIs
--              that are owned by the Core Modules Team (AK)
--
--  Desc        This procedure returns to the caller the values of the
--              who columns for updating or creating a record. It returns
--              a different set of values depending on whether the update
--              is initiated by a user or by the loader.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_loader_timestamp : IN optional
--                  The timestamp to be used when the record are to be
--                  updated or created by the loader. It should not
--                  contain any value (ie, G_MISS_DATE) if the record
--                  is not being updated or created by the loader.
--              p_created_by : OUT
--                  It contains the value to be used for the CREATED_BY
--                  who column. This value should be ignored by the
--                  caller if the caller is only updating a record.
--              p_creation_date : OUT
--                  It contains the value to be used for the CREATION_DATE
--                  who column. This value should be ignored by the
--                  caller if the caller is only updating a record.
--              p_last_updated_by : OUT
--                  It contains the value to be used for the LAST_UPDATED_BY
--                  who column.
--              p_last_update_date : OUT
--                  It contains the value to be used for the LAST_UPDATE_DATE
--                  who column.
--              p_last_update_login : OUT
--                  It contains the value to be used for the
--                  LAST_UPDATE_LOGIN who column.
--=======================================================
procedure SET_WHO (
p_return_status            OUT NOCOPY     VARCHAR2,
p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
p_created_by               OUT NOCOPY     NUMBER,
p_creation_date            OUT NOCOPY     DATE,
p_last_updated_by          OUT NOCOPY     NUMBER,
p_last_update_date         OUT NOCOPY     DATE,
p_last_update_login        OUT NOCOPY     NUMBER
);

function IS_UPDATEABLE (
  p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
  p_created_by               IN OUT NOCOPY     NUMBER,
  p_creation_date            IN OUT NOCOPY     DATE,
  p_last_updated_by          IN OUT NOCOPY     NUMBER,
  p_db_last_updated_by       IN         NUMBER,
  p_last_update_date         IN OUT NOCOPY     DATE,
  p_db_last_update_date      IN         DATE,
  p_last_update_login        IN OUT NOCOPY     NUMBER,
  p_create_or_update   	     IN         VARCHAR2
) return BOOLEAN;

--==============================================
--  Procedure   UPLOAD
--
--  Usage       Private API for loading flows, objects, regions,
--              and attributes from a loader file to the database.
--              This procedure is intended to be called only by other APIs
--              that are owned by the Core Modules Team (AK)
--
--  Desc        This API parses the header information and the DEFINE
--              section, and calls the appropriate private API to read
--              in all flow, object, region, and attribute data
--              (including all the tables in these business objects)
--              from the loader file, and update them to the database.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters
--==============================================
procedure UPLOAD (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2
);

--=======================================================
--  Function    VALID_APPLICATION_ID
--
--  Usage       Private function for validating an application ID. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This function checks to see if the given application ID is
--              a valid application ID in the FND_APPLICATION table.
--
--  Results     This  function returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_application_id : IN required
--                  The application ID that needs to be checked against
--                  the FND_APPLICATION table.
--              This function will return TRUE if the application ID
--              exists in the FND_APPLICATION table, or FALSE otherwise.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
function VALID_APPLICATION_ID (
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_application_id           IN      NUMBER
) return BOOLEAN;

--=======================================================
--  Function    VALID_LOOKUP_CODE
--
--  Usage       Private function for validating a lookup code. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This function checks to see if the given lookup type and
--              lookup code exists in the AK_LOOKUP_CODES table.
--
--  Results     This  function returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_lookup_type : IN required
--                  The type of the lookup code to be verified
--              p_lookup_code : IN required
--                  The lookup code to be verified against AK_LOOKUP_CODES
--              This function will return TRUE if the lookup type and
--              lookup code exists in the AK_LOOKUP_CODES table, or
--              FALSE otherwise.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
function VALID_LOOKUP_CODE (
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_lookup_type              IN      VARCHAR2,
p_lookup_code              IN      VARCHAR2
) return BOOLEAN;

--=======================================================
--  Function    VALID_YES_NO
--
--  Usage       Private function for validating a Y/N column. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This function checks to see if the given value is
--              either 'Y' or 'N'. It is used for checking for valid
--              data in columns that accepts only 'Y' or 'N' as valid
--              values.
--
--  Results     This  function returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_value : IN required
--                  The value to be checked
--              This function will return TRUE if the value is either
--              'Y' or 'N', or FALSE otherwise.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
function VALID_YES_NO (
p_value                   IN      VARCHAR2
) return BOOLEAN;

--=======================================================
--  Procedure   WRITE_FILE
--
--  Usage       Private procedure for writing the contents in a PL/SQL
--              table to a file.
--              This function is intended to be called only by other APIs
--              that are owned by the Core Modules Team (AK)
--
--  Desc        This procedure writes the contents in the PL/SQL table passed
--              into the specified file. The file could be overwritten
--              or appended depending on the value of the parameter
--              p_write_mode.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters
--              p_buffer_tbl : IN required
--                  The PL/SQL table of type Buffer_Tbl_Type whose
--                  content is to be written to a file.
--              p_write_mode : IN optional
--                  It must be G_APPEND or G_OVERWRITE if a value
--                  is given. It tells this procedure whether to
--                  write the PL/SQL table contents to the end of the
--                  file (default), or to overwrite the file with the
--                  contents in the PL/SQL table.
--=======================================================
procedure WRITE_FILE (
p_return_status            OUT NOCOPY     VARCHAR2,
p_buffer_tbl               IN      AK_ON_OBJECTS_PUB.Buffer_Tbl_Type,
p_write_mode               IN      VARCHAR2 := AK_ON_OBJECTS_PUB.G_APPEND
);

--=======================================================
--  Procedure   WRITE_LOG_FILE
--
--  Usage       Private procedure for writing the contents in a PL/SQL
--              table to a file.
--              This function is intended to be called only by other APIs
--              that are owned by the Core Modules Team (AK)
--
--  Desc        This procedure writes the contents in the PL/SQL table passed
--              into the specified file. The file could be overwritten
--              or appended depending on the value of the parameter
--              p_write_mode.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameter
--              p_buffer_tbl : IN required
--                  The PL/SQL table of type Buffer_Tbl_Type whose
--                  content is to be written to a file.
--              p_write_mode : IN optional
--                  It must be G_APPEND or G_OVERWRITE if a value
--                  is given. It tells this procedure whether to
--                  write the PL/SQL table contents to the end of the
--                  file (default), or to overwrite the file with the
--                  contents in the PL/SQL table.
--=======================================================
procedure WRITE_LOG_FILE (
p_return_status            OUT NOCOPY     VARCHAR2,
p_buffer_tbl               IN      AK_ON_OBJECTS_PUB.Buffer_Tbl_Type,
p_write_mode               IN      VARCHAR2 := AK_ON_OBJECTS_PUB.G_APPEND
);

procedure WRITE_TO_TABLE (
p_buffer	IN	VARCHAR2
);

end AK_ON_OBJECTS_PVT;

 

/
