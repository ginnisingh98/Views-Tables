--------------------------------------------------------
--  DDL for Package AHL_FMP_MR_RELATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_FMP_MR_RELATION_PVT" AUTHID CURRENT_USER AS
 /* $Header: AHLVMRLS.pls 120.0 2005/05/26 01:00:01 appldev noship $ */
TYPE MR_RELATION_REC IS RECORD
(
MR_RELATIONSHIP_ID                      NUMBER,
OBJECT_VERSION_NUMBER                   NUMBER,
RELATIONSHIP_CODE                       VARCHAR2(30),
MR_HEADER_ID                            NUMBER,
MR_TITLE				VARCHAR2(80),
MR_REVISION				VARCHAR2(30),
MR_VERSION_NUMBER			NUMBER,
MR_STATUS_CODE                          VARCHAR2(30),
RELATED_MR_HEADER_ID                    NUMBER,
RELATED_MR_TITLE                        VARCHAR2(80),
RELATED_MR_REVISION                     VARCHAR2(30),
RELATED_MR_STATUS_CODE                  VARCHAR2(30),
ATTRIBUTE_CATEGORY                      VARCHAR2(30),
ATTRIBUTE1                              VARCHAR2(150),
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
LAST_UPDATED_BY                         NUMBER,
CREATION_DATE                           DATE,
CREATED_BY                              NUMBER,
LAST_UPDATE_LOGIN                       NUMBER,
DML_OPERATION                           VARCHAR2(1)
);

TYPE MR_RELATION_TBL IS TABLE OF MR_RELATION_REC INDEX BY BINARY_INTEGER;

PROCEDURE PROCESS_MR_RELATION
 (
 p_api_version                  IN  		NUMBER   := 1.0,
 p_init_msg_list                IN  		VARCHAR2 := FND_API.G_FALSE,
 p_commit                       IN  		VARCHAR2 := FND_API.G_FALSE,
 p_validation_level             IN  		NUMBER:= FND_API.G_VALID_LEVEL_FULL,
 p_default                      IN  		VARCHAR2:= FND_API.G_FALSE,
 p_module_type                  IN  		VARCHAR2 := NULL,
 x_return_status                OUT NOCOPY             VARCHAR2,
 x_msg_count                    OUT NOCOPY             NUMBER,
 x_msg_data                     OUT NOCOPY             VARCHAR2,
 p_x_mr_relation_tbl            IN OUT  NOCOPY 	MR_RELATION_TBL
 );
END  AHL_FMP_MR_RELATION_PVT;

 

/
