--------------------------------------------------------
--  DDL for Package AHL_FMP_MR_ACTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_FMP_MR_ACTION_PVT" AUTHID CURRENT_USER AS
 /* $Header: AHLVMRAS.pls 115.3 2002/12/04 19:51:06 rtadikon noship $ */
TYPE MR_ACTION_REC IS RECORD
(
MR_ACTION_ID                            NUMBER,
OBJECT_VERSION_NUMBER                   NUMBER,
MR_HEADER_ID                            NUMBER,
MR_ACTION_CODE                          VARCHAR2(30),
MR_ACTION                               VARCHAR2(80),
PLAN_ID                                 NUMBER,
PLAN                                    VARCHAR2(80),
DESCRIPTION                             VARCHAR2(2000),
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
LAST_UPDATED_BY                         NUMBER(15),
CREATION_DATE                           DATE,
CREATED_BY                              NUMBER(15),
LAST_UPDATE_LOGIN                       NUMBER(15),
DML_OPERATION                           VARCHAR2(1)
);

TYPE MR_ACTION_TBL IS TABLE OF MR_ACTION_REC INDEX BY BINARY_INTEGER;

PROCEDURE PROCESS_MR_ACTION
 (
 p_api_version                  IN  		NUMBER     := 1.0,
 p_init_msg_list                IN  		VARCHAR2   := FND_API.G_TRUE,
 p_commit                       IN  		VARCHAR2   := FND_API.G_FALSE,
 p_validation_level             IN  		NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default                      IN  		VARCHAR2   := FND_API.G_FALSE,
 p_module_type                  IN  		VARCHAR2   := NULL,
 x_return_status                OUT NOCOPY             VARCHAR2,
 x_msg_count                    OUT NOCOPY             NUMBER,
 x_msg_data                     OUT NOCOPY             VARCHAR2,
 p_x_mr_action_tbl          	IN OUT NOCOPY 	MR_ACTION_TBL
 );
END  AHL_FMP_MR_ACTION_PVT;

 

/
