--------------------------------------------------------
--  DDL for Package AHL_FMP_MR_ROUTE_SEQNCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_FMP_MR_ROUTE_SEQNCE_PVT" AUTHID CURRENT_USER AS
 /* $Header: AHLVMRSS.pls 120.0 2005/05/26 00:56:58 appldev noship $ */
TYPE MR_ROUTE_SEQ_REC IS RECORD
(
MR_ROUTE_SEQUENCE_ID                    NUMBER,
OBJECT_VERSION_NUMBER                   NUMBER,
MR_ROUTE_NUMBER				VARCHAR2(30),
MR_ROUTE_REVISION			NUMBER,
MR_ROUTE_ID                             NUMBER,
MR_HEADER_ID                            NUMBER,
MR_TITLE				VARCHAR2(80),
MR_VERSION_NUMBER			NUMBER,
ROUTE_NUMBER                            VARCHAR2(30),
ROUTE_REVISION_NUMBER			NUMBER,
RELATED_MR_ROUTE_ID                     NUMBER,
SEQUENCE_CODE                           VARCHAR2 (30),
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

TYPE MR_ROUTE_SEQ_TBL IS TABLE OF MR_ROUTE_SEQ_REC INDEX BY BINARY_INTEGER;

PROCEDURE PROCESS_MR_ROUTE_SEQ
 (
 p_api_version                  IN  	NUMBER     := 1.0,
 p_init_msg_list                IN  	VARCHAR2   := FND_API.G_FALSE,
 p_commit                       IN  	VARCHAR2   := FND_API.G_FALSE,
 p_validation_level             IN	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
 p_default                      IN  	VARCHAR2   := FND_API.G_FALSE,
 p_module_type                  IN  	VARCHAR2   := NULL,
 x_return_status               OUT NOCOPY             VARCHAR2,
 x_msg_count                   OUT NOCOPY             NUMBER,
 x_msg_data                    OUT NOCOPY             VARCHAR2,
 p_x_mr_route_seq_tbl           IN OUT NOCOPY 	MR_ROUTE_SEQ_TBL
 );

-- Procedure to check for correct route sequence w.r.t stage information for given mr_route...
-- Pass p_route_stage_upd = true for calling from AHL_FMP_MR_ROUTE_PVT, and false otherwise...
PROCEDURE VALIDATE_ROUTE_STAGE_SEQ
(
	p_mr_route_id in number,
	p_route_stage_upd in boolean
);

END  AHL_FMP_MR_ROUTE_SEQNCE_PVT;

 

/
