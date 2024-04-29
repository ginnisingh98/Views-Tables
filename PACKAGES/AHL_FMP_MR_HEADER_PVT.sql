--------------------------------------------------------
--  DDL for Package AHL_FMP_MR_HEADER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_FMP_MR_HEADER_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVMRHS.pls 120.0.12010000.2 2008/12/29 00:29:35 sracha ship $ */

TYPE mr_header_rec IS RECORD
(
MR_HEADER_ID                            NUMBER,
OBJECT_VERSION_NUMBER                   NUMBER,
LAST_UPDATE_DATE                        DATE,
LAST_UPDATED_BY                         NUMBER(15),
CREATION_DATE                           DATE,
CREATED_BY                              NUMBER(15),
LAST_UPDATE_LOGIN                       NUMBER(15),
TITLE                                   VARCHAR2(80),
REVISION                                VARCHAR2(30),
VERSION_NUMBER                          NUMBER,
CATEGORY_CODE                           VARCHAR2(30),
CATEGORY                                VARCHAR2(80),
PROGRAM_TYPE_CODE                       VARCHAR2(30),
PROGRAM_TYPE                            VARCHAR2(80),
PROGRAM_SUBTYPE_CODE                    VARCHAR2(30),
PROGRAM_SUBTYPE                         VARCHAR2(80),
SERVICE_TYPE_CODE                       VARCHAR2(3),
SERVICE_TYPE                            VARCHAR2(80),
MR_STATUS_CODE                          VARCHAR2(30),
MR_STATUS                               VARCHAR2(80),
IMPLEMENT_STATUS_CODE                   VARCHAR2(30),
IMPLEMENT_STATUS                        VARCHAR2(80),
EFFECTIVE_FROM                          DATE,
EFFECTIVE_TO                            DATE,
REPETITIVE_FLAG                         VARCHAR2(1),
REPETITIVE                              VARCHAR2(80),
SHOW_REPETITIVE_CODE                    VARCHAR2(4),
SHOW_REPETITIVE                         VARCHAR2(80),
WHICHEVER_FIRST_CODE                    VARCHAR2(5),
WHICHEVER_FIRST                         VARCHAR2(80),
COPY_ACCOMPLISHMENT_FLAG                VARCHAR2(1),
COPY_ACCOMPLISHMENT                     VARCHAR2(80),
PRECEDING_MR_HEADER_ID                  NUMBER,
PRECEDING_MR_TITLE                      VARCHAR2(80),
PRECEDING_MR_REVISION                   VARCHAR2(30),
DESCRIPTION                             VARCHAR2(2000),
COMMENTS                                VARCHAR2(2000),
SUPERUSER_ROLE                          VARCHAR2(1),
SERVICE_REQUEST_TEMPLATE_ID             NUMBER,
TYPE_CODE                               VARCHAR2(30),
TYPE_CODE_MEANING                       VARCHAR2(80),
DOWN_TIME                               NUMBER,
UOM_CODE                                VARCHAR2(30),
UOM_MEANING                             VARCHAR2(80),
BILLING_ITEM                            VARCHAR2(40),
BILLING_ITEM_ID                         NUMBER,
QA_INSPECTION_TYPE                    	VARCHAR2(150),
QA_INSPECTION_TYPE_CODE                 VARCHAR2(150),
SPACE_CATEGORY                        	VARCHAR2(80),
SPACE_CATEGORY_CODE                     VARCHAR2(30),
AUTO_SIGNOFF_FLAG                       VARCHAR2(30),
COPY_INIT_ACCOMPL_FLAG                  VARCHAR2(1),
COPY_DEFERRALS_FLAG                     VARCHAR2(1),
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
DML_OPERATION                           VARCHAR2(1)
);

PROCEDURE CREATE_MR_HEADER
 (
 p_api_version               IN         	NUMBER:=1.0,
 p_init_msg_list             IN         	VARCHAR2:=FND_API.G_FALSE,
 p_commit                    IN         	VARCHAR2:=FND_API.G_FALSE,
 p_validation_level          IN 	NUMBER:=FND_API.G_VALID_LEVEL_FULL,
 p_default                   IN         	VARCHAR2:=FND_API.G_FALSE,
 p_module_type               IN         	VARCHAR2:=NULL,
 x_return_status                OUT NOCOPY             VARCHAR2,
 x_msg_count                    OUT NOCOPY             NUMBER,
 x_msg_data                     OUT NOCOPY             VARCHAR2,
 p_x_mr_header_rec           IN OUT  NOCOPY   	MR_HEADER_REC
 );

PROCEDURE UPDATE_MR_HEADER
 (
 p_api_version               IN         	NUMBER:=1.0,
 p_init_msg_list             IN         	VARCHAR2:=FND_API.G_FALSE,
 p_commit                    IN         	VARCHAR2:=FND_API.G_FALSE,
 p_validation_level          IN 	NUMBER:=FND_API.G_VALID_LEVEL_FULL,
 p_default                   IN         	VARCHAR2:=FND_API.G_FALSE,
 p_module_type               IN         	VARCHAR2:=NULL,
 x_return_status                OUT NOCOPY             VARCHAR2,
 x_msg_count                    OUT NOCOPY             NUMBER,
 x_msg_data                     OUT NOCOPY             VARCHAR2,
 p_x_mr_header_rec           IN OUT  NOCOPY   	MR_HEADER_REC
 );
PROCEDURE DELETE_MR_HEADER
 (
 p_api_version               IN         	NUMBER:=1.0,
 p_init_msg_list             IN         	VARCHAR2:=FND_API.G_FALSE,
 p_commit                    IN         	VARCHAR2:=FND_API.G_FALSE,
 p_validation_level          IN 	NUMBER:=FND_API.G_VALID_LEVEL_FULL,
 p_default                   IN         	VARCHAR2:=FND_API.G_FALSE,
 p_module_type               IN         	VARCHAR2:=NULL,
 x_return_status                OUT NOCOPY             VARCHAR2,
 x_msg_count                    OUT NOCOPY             NUMBER,
 x_msg_data                     OUT NOCOPY             VARCHAR2,
 p_mr_header_id              IN 		NUMBER,
 p_OBJECT_VERSION_NUMBER     IN 		NUMBER
 );
END AHL_FMP_MR_HEADER_PVT;


/
