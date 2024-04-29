--------------------------------------------------------
--  DDL for Package AHL_FMP_MR_VISIT_TYPES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_FMP_MR_VISIT_TYPES_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVMRVS.pls 120.0 2005/05/25 23:58:37 appldev noship $ */
TYPE MR_VISIT_TYPE_REC_TYPE IS RECORD
(
MR_VISIT_TYPE_ID                        NUMBER,         -- Unique id for the table
OBJECT_VERSION_NUMBER                   NUMBER,         -- Used for handling concurrent users transacting
MR_HEADER_ID                            NUMBER,         -- Fkey for AHL_MR_HEADERS_B.MR_HEADER_ID
MR_VISIT_TYPE_CODE                      VARCHAR2(30),   -- LOOKUP_CODE from fnd_lookup_values_vl for LOOKUP_TYPE='AHL_LTP_SERVICE_TYPE LOOKUP_TYPE'
MR_VISIT_TYPE                           VARCHAR2(80),   -- Meaning for the code
ATTRIBUTE_CATEGORY                      VARCHAR2(30),
ATTRIBUTE1                              VARCHAR2(150),  -- Customizable descriptive flexfield columns 1-15
ATTRIBUTE2                              VARCHAR2(150),
ATTRIBUTE3                              VARCHAR2(150),
ATTRIBUTE4                              VARCHAR2(150),
ATTRIBUTE5                              VARCHAR2(150),
ATTRIBUTE6                              VARCHAR2(150),
ATTRIBUTE7                              VARCHAR2(150),
ATTRIBUTE8                              VARCHAR2(150),
ATTRIBUTE9                              VARCHAR2(150),
ATTRIBUTE10                             VARCHAR2(150),
ATTRIBUTE11                             VARCHAR2(150),
ATTRIBUTE12                             VARCHAR2(150),
ATTRIBUTE13                             VARCHAR2(150),
ATTRIBUTE14                             VARCHAR2(150),
ATTRIBUTE15                             VARCHAR2(150),
LAST_UPDATE_DATE                        DATE,
LAST_UPDATED_BY                         NUMBER(15),
CREATION_DATE                           DATE,
CREATED_BY                              NUMBER(15),     -- Default application transacting user
LAST_UPDATE_LOGIN                       NUMBER(15),     -- Last updated application transacting user
DML_OPERATION                           VARCHAR2(1)     -- DML operation 'C'/'U'/'D' for Create/Update/Delete dml operations
);

TYPE MR_VISIT_TYPE_TBL_TYPE IS TABLE OF MR_VISIT_TYPE_REC_TYPE INDEX BY BINARY_INTEGER;

PROCEDURE PROCESS_MR_VISIT_TYPES
 (
 p_api_version IN NUMBER,
 p_init_msg_list                IN  		VARCHAR2   := FND_API.G_FALSE,
 p_commit                       IN  		VARCHAR2   := FND_API.G_FALSE,
 p_validation_level             IN  		NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default                      IN  		VARCHAR2   := FND_API.G_FALSE,
 p_module_type                  IN              VARCHAR2,
 x_return_status                OUT NOCOPY      VARCHAR2,
 x_msg_count                    OUT NOCOPY      NUMBER,
 x_msg_data                     OUT NOCOPY      VARCHAR2,
 p_x_mr_visit_type_tbl          IN OUT NOCOPY   MR_VISIT_TYPE_TBL_TYPE
 );
END  AHL_FMP_MR_VISIT_TYPES_PVT;

 

/
