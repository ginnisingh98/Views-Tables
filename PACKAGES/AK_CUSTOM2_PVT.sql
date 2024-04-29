--------------------------------------------------------
--  DDL for Package AK_CUSTOM2_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AK_CUSTOM2_PVT" AUTHID CURRENT_USER as
/* $Header: akdvcr2s.pls 120.2 2005/09/15 22:26:47 tshort noship $ */

-- Global constants holding the package and file names to be used by
-- messaging routines in the case of an unexpected error.

G_PKG_NAME      CONSTANT    VARCHAR2(30) := 'AK_CUSTOM2_PVT';

-- PL/SQL table for holding records that need to be processed
-- the second time in UPLOAD
G_CUSTOM_REDO_TBL           AK_CUSTOM_PUB.Custom_Tbl_Type;
G_CUST_REGION_REDO_TBL             AK_CUSTOM_PUB.Cust_Region_Tbl_Type;
G_CUST_REG_ITEM_REDO_TBL         AK_CUSTOM_PUB.Cust_Reg_Item_Tbl_Type;
G_CRITERIA_REDO_TBL                AK_CUSTOM_PUB.Criteria_Tbl_Type;
--
-- Pointer to redo tables
G_CUSTOM_REDO_INDEX         NUMBER := 0;
G_CUST_REGION_REDO_INDEX           NUMBER := 0;
G_CUST_REG_ITEM_REDO_INDEX       NUMBER := 0;
G_CRITERIA_REDO_INDEX              NUMBER := 0;

--=======================================================
--  Procedure   UPLOAD_CUSTOM
--
--  Usage       Private API for loading customizations from a
--              loader file to the database.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API reads the customization data (including region
--              items) stored in the loader file currently being
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
procedure UPLOAD_CUSTOM (
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

--=======================================================
--  Procedure   UPLOAD_CUSTOM_SECOND
--
--  Usage       Private API for loading customizations that were
--              failed during its first pass
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API reads the customization data from PL/SQL table
--              that was prepared during 1st pass, then processes
--              the data, and loads them to the database. The tables
--              are updated with the timestamp passed. This API
--              will process the file until the EOF is reached,
--              a parse error is encountered, or when data for
--              a different business object is read from the file.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_validation_level : IN required
--                  validation level
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure UPLOAD_CUSTOM_SECOND (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_return_status            OUT NOCOPY     VARCHAR2,
p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
p_pass                     IN      NUMBER := 2
);

end AK_CUSTOM2_PVT;

 

/
