--------------------------------------------------------
--  DDL for Package AHL_RM_APPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_RM_APPROVAL_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVROAS.pls 120.0.12010000.2 2008/11/23 14:26:35 bachandr ship $ */
PROCEDURE INITIATE_OPER_APPROVAL
 (
 p_api_version               IN         NUMBER:=  1.0,
 p_init_msg_list             IN         VARCHAR2,
 p_commit                    IN         VARCHAR2,
 p_validation_level          IN         NUMBER,
 p_default                   IN         VARCHAR2   := FND_API.G_FALSE,
 p_module_type               IN         VARCHAR2,
 x_return_status                OUT NOCOPY     VARCHAR2,
 x_msg_count                    OUT NOCOPY     NUMBER,
 x_msg_data                     OUT NOCOPY     VARCHAR2,
 p_source_operation_id       IN         NUMBER,
 p_object_Version_number     IN         NUMBER,
 p_apprvl_type               IN         VARCHAR2);


PROCEDURE INITIATE_ROUTE_APPROVAL
 (
 p_api_version               IN         NUMBER:=  1.0,
 p_init_msg_list             IN         VARCHAR2,
 p_commit                    IN         VARCHAR2,
 p_validation_level          IN         NUMBER,
 p_default                   IN         VARCHAR2   := FND_API.G_FALSE,
 p_module_type               IN         VARCHAR2,
 x_return_status                OUT NOCOPY     VARCHAR2,
 x_msg_count                    OUT NOCOPY     NUMBER,
 x_msg_data                     OUT NOCOPY     VARCHAR2,
 p_source_route_id           IN         NUMBER,
 p_object_Version_number     IN         NUMBER,
 p_apprvl_type               IN         VARCHAR2);

PROCEDURE COMPLETE_ROUTE_REVISION
 (
 p_api_version               IN         NUMBER:=  1.0,
 p_init_msg_list             IN         VARCHAR2,
 p_commit                    IN         VARCHAR2,
 p_validation_level          IN         NUMBER,
 p_default                   IN         VARCHAR2   := FND_API.G_FALSE,
 p_module_type               IN         VARCHAR2,
 x_return_status                OUT NOCOPY     VARCHAR2,
 x_msg_count                    OUT NOCOPY     NUMBER,
 x_msg_data                     OUT NOCOPY     VARCHAR2,
 p_appr_status               IN         VARCHAR2,
 p_route_id                  IN         NUMBER,
 p_object_version_number     IN         NUMBER,
 p_approver_note             IN         VARCHAR2   := null
 );

PROCEDURE COMPLETE_OPER_REVISION
 (
 p_api_version               IN         NUMBER:=  1.0,
 p_init_msg_list             IN         VARCHAR2,
 p_commit                    IN         VARCHAR2,
 p_validation_level          IN         NUMBER,
 p_default                   IN         VARCHAR2   := FND_API.G_FALSE,
 p_module_type               IN         VARCHAR2,
 x_return_status                OUT NOCOPY     VARCHAR2,
 x_msg_count                    OUT NOCOPY     NUMBER,
 x_msg_data                     OUT NOCOPY     VARCHAR2,
 p_appr_status               IN         VARCHAR2,
 p_operation_id              IN         NUMBER,
 p_object_Version_number     IN         NUMBER,
 p_approver_note             IN         VARCHAR2   := null
 );

END AHL_RM_APPROVAL_PVT;

/
