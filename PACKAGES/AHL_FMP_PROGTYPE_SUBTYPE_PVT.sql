--------------------------------------------------------
--  DDL for Package AHL_FMP_PROGTYPE_SUBTYPE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_FMP_PROGTYPE_SUBTYPE_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVFPTS.pls 115.6 2002/12/04 19:49:17 rtadikon noship $ */
TYPE prog_type_subtype_rec IS RECORD
(
PROG_TYPE_SUBTYPE_ID                    NUMBER,
OBJECT_VERSION_NUMBER                   NUMBER,
PROGRAM_TYPE_CODE                       VARCHAR2(30),
PROGRAM_TYPE                            VARCHAR2(80),
PROGRAM_SUBTYPE_CODE                    VARCHAR2(30),
PROGRAM_SUBTYPE                         VARCHAR2(80),
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
TYPE p_x_prog_type_subtype_tbl IS TABLE OF prog_type_subtype_rec INDEX BY BINARY_INTEGER;
Procedure PROCESS_PROG_TYPE_SUBTYPES
 (
 p_api_version                  IN  NUMBER     := 1.0,
 p_init_msg_list                IN  VARCHAR2,
 p_commit                       IN  VARCHAR2   := FND_API.G_FALSE,
 p_validation_level             IN  NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default                      IN  VARCHAR2   := FND_API.G_FALSE,
 p_module_type                  IN  VARCHAR2,
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_count                    OUT NOCOPY NUMBER,
 x_msg_data                     OUT NOCOPY VARCHAR2,
 p_x_prog_type_subtype_tabl     IN OUT  NOCOPY p_x_prog_type_subtype_tbl
 );
END  AHL_FMP_PROGTYPE_SUBTYPE_PVT;

 

/
