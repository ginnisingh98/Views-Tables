--------------------------------------------------------
--  DDL for Package AHL_FMP_MR_REVISION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_FMP_MR_REVISION_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVMRRS.pls 115.4 2004/01/13 23:25:19 rtadikon noship $ */
PROCEDURE CREATE_MR_REVISION
 (
 p_api_version               IN                 NUMBER:=1.0,
 p_init_msg_list             IN                 VARCHAR2:=FND_API.G_FALSE,
 p_commit                    IN                 VARCHAR2:=FND_API.G_FALSE,
 p_validation_level          IN         NUMBER:=FND_API.G_VALID_LEVEL_FULL,
 p_default                   IN                 VARCHAR2:=FND_API.G_FALSE,
 p_module_type               IN         VARCHAR2,
 x_return_status                OUT NOCOPY     VARCHAR2,
 x_msg_count                    OUT NOCOPY     NUMBER,
 x_msg_data                     OUT NOCOPY     VARCHAR2,
 p_source_mr_header_id       IN         NUMBER,
 x_new_mr_header_id             OUT NOCOPY     NUMBER
 );


PROCEDURE INITIATE_MR_APPROVAL
 (
 p_api_version               IN                 NUMBER:=1.0,
 p_init_msg_list             IN                 VARCHAR2:=FND_API.G_FALSE,
 p_commit                    IN                 VARCHAR2:=FND_API.G_FALSE,
 p_validation_level          IN         NUMBER:=FND_API.G_VALID_LEVEL_FULL,
 p_default                   IN                 VARCHAR2:=FND_API.G_FALSE,
 p_module_type               IN         VARCHAR2,
 x_return_status                OUT NOCOPY     VARCHAR2,
 x_msg_count                    OUT NOCOPY     NUMBER,
 x_msg_data                     OUT NOCOPY     VARCHAR2,
 p_source_mr_header_id       IN         NUMBER,
 p_object_Version_number     IN         NUMBER,
 p_apprv_type		     IN         VARCHAR2:='COMPLETE'
 );

PROCEDURE COMPLETE_MR_REVISION
 (
 p_api_version               IN                 NUMBER:=1.0,
 p_init_msg_list             IN                 VARCHAR2:=FND_API.G_FALSE,
 p_commit                    IN                 VARCHAR2:=FND_API.G_FALSE,
 p_validation_level          IN         NUMBER:=FND_API.G_VALID_LEVEL_FULL,
 p_default                   IN         VARCHAR2   := FND_API.G_FALSE,
 p_module_type               IN         VARCHAR2,
 x_return_status                OUT NOCOPY     VARCHAR2,
 x_msg_count                    OUT NOCOPY     NUMBER,
 x_msg_data                     OUT NOCOPY     VARCHAR2,
 p_appr_status               IN         VARCHAR2,
 p_mr_header_id              IN         NUMBER,
 p_object_Version_number     IN         NUMBER
 );

PROCEDURE VALIDATE_MR_REVISION
 (
 p_api_version               IN                 NUMBER:=1.0,
 p_init_msg_list             IN                 VARCHAR2:=FND_API.G_FALSE,
 p_commit                    IN                 VARCHAR2:=FND_API.G_FALSE,
 p_validation_level          IN         NUMBER:=FND_API.G_VALID_LEVEL_FULL,
 p_default                   IN         VARCHAR2   := FND_API.G_FALSE,
 p_module_type               IN         VARCHAR2,
 x_return_status                OUT NOCOPY     VARCHAR2,
 x_msg_count                    OUT NOCOPY     NUMBER,
 x_msg_data                     OUT NOCOPY     VARCHAR2,
 p_source_mr_header_id       IN         NUMBER,
 p_object_version_number        IN      NUMBER
 );

END AHL_FMP_MR_REVISION_PVT;

 

/
