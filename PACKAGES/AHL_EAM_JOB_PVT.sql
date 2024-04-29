--------------------------------------------------------
--  DDL for Package AHL_EAM_JOB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_EAM_JOB_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVEAMS.pls 115.2 2003/09/23 22:35:02 shkalyan noship $ */

PROCEDURE map_ahl_eam_wo_rec
(
  p_workorder_rec  IN          AHL_PRD_WORKORDER_PVT.prd_workorder_rec,
  x_eam_wo_rec     OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_rec_type
);

PROCEDURE map_ahl_eam_wo_rel_rec
(
  p_workorder_rel_rec    IN         AHL_PRD_WORKORDER_PVT.prd_workorder_rel_rec,
  x_eam_wo_relations_rec OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_relations_rec_type
);

PROCEDURE map_ahl_eam_op_rec
(
  p_operation_rec  IN         AHL_PRD_OPERATIONS_PVT.prd_workoperation_rec,
  x_eam_op_rec     OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_rec_type
);

PROCEDURE map_ahl_eam_mat_rec
(
  p_material_req_rec IN         AHL_PP_MATERIALS_PVT.req_material_rec_type,
  x_eam_mat_req_rec  OUT NOCOPY EAM_PROCESS_WO_PUB.eam_mat_req_rec_type
);

PROCEDURE map_ahl_eam_res_rec
(
  p_resource_req_rec IN         AHL_PP_RESRC_REQUIRE_PVT.resrc_require_rec_type,
  x_eam_res_rec      OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_rec_type
);

PROCEDURE map_ahl_eam_res_inst_rec
(
  p_resource_assign_rec IN        AHL_PP_RESRC_ASSIGN_PVT.resrc_assign_rec_type,
  x_eam_res_inst_rec    OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_inst_rec_type
);

PROCEDURE update_job_operations
(
  p_api_version            IN   NUMBER     := 1.0,
  p_init_msg_list          IN   VARCHAR2   := FND_API.G_TRUE,
  p_commit                 IN   VARCHAR2   := FND_API.G_FALSE,
  p_validation_level       IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_default                IN   VARCHAR2   := FND_API.G_FALSE,
  p_module_type            IN   VARCHAR2   := NULL,
  x_return_status          OUT  NOCOPY  VARCHAR2,
  x_msg_count              OUT  NOCOPY  NUMBER,
  x_msg_data               OUT  NOCOPY  VARCHAR2,
  p_workorder_rec          IN   AHL_PRD_WORKORDER_PVT.prd_workorder_rec,
  p_operation_tbl          IN   AHL_PRD_OPERATIONS_PVT.prd_operation_tbl,
  p_material_req_tbl       IN   AHL_PP_MATERIALS_PVT.req_material_tbl_type,
  p_resource_req_tbl       IN   AHL_PP_RESRC_REQUIRE_PVT.resrc_require_tbl_type
);

PROCEDURE process_material_req
(
  p_api_version            IN   NUMBER     := 1.0,
  p_init_msg_list          IN   VARCHAR2   := FND_API.G_TRUE,
  p_commit                 IN   VARCHAR2   := FND_API.G_FALSE,
  p_validation_level       IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_default                IN   VARCHAR2   := FND_API.G_FALSE,
  p_module_type            IN   VARCHAR2   := NULL,
  x_return_status          OUT  NOCOPY  VARCHAR2,
  x_msg_count              OUT  NOCOPY  NUMBER,
  x_msg_data               OUT  NOCOPY  VARCHAR2,
  p_material_req_tbl       IN   AHL_PP_MATERIALS_PVT.req_material_tbl_type
);

PROCEDURE process_resource_req
(
  p_api_version            IN   NUMBER     := 1.0,
  p_init_msg_list          IN   VARCHAR2   := FND_API.G_TRUE,
  p_commit                 IN   VARCHAR2   := FND_API.G_FALSE,
  p_validation_level       IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_default                IN   VARCHAR2   := FND_API.G_FALSE,
  p_module_type            IN   VARCHAR2   := NULL,
  x_return_status          OUT  NOCOPY  VARCHAR2,
  x_msg_count              OUT  NOCOPY  NUMBER,
  x_msg_data               OUT  NOCOPY  VARCHAR2,
  p_resource_req_tbl       IN   AHL_PP_RESRC_REQUIRE_PVT.resrc_require_tbl_type
);

PROCEDURE process_resource_assign
(
  p_api_version            IN   NUMBER     := 1.0,
  p_init_msg_list          IN   VARCHAR2   := FND_API.G_TRUE,
  p_commit                 IN   VARCHAR2   := FND_API.G_FALSE,
  p_validation_level       IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_default                IN   VARCHAR2   := FND_API.G_FALSE,
  p_module_type            IN   VARCHAR2   := NULL,
  x_return_status          OUT  NOCOPY  VARCHAR2,
  x_msg_count              OUT  NOCOPY  NUMBER,
  x_msg_data               OUT  NOCOPY  VARCHAR2,
  p_resource_assign_tbl    IN   AHL_PP_RESRC_ASSIGN_PVT.resrc_assign_tbl_type
);

PROCEDURE create_eam_workorder
(
  p_api_version        IN   NUMBER     := 1.0,
  p_init_msg_list      IN   VARCHAR2   := FND_API.G_TRUE,
  p_commit             IN   VARCHAR2   := FND_API.G_FALSE,
  p_validation_level   IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_default            IN   VARCHAR2   := FND_API.G_FALSE,
  p_module_type        IN   VARCHAR2   := NULL,
  x_return_status      OUT  NOCOPY  VARCHAR2,
  x_msg_count          OUT  NOCOPY  NUMBER,
  x_msg_data           OUT  NOCOPY  VARCHAR2,
  p_x_workorder_rec    IN OUT NOCOPY AHL_PRD_WORKORDER_PVT.prd_workorder_rec,
  p_operation_tbl      IN   AHL_PRD_OPERATIONS_PVT.prd_operation_tbl,
  p_material_req_tbl   IN   AHL_PP_MATERIALS_PVT.req_material_tbl_type,
  p_resource_req_tbl   IN   AHL_PP_RESRC_REQUIRE_PVT.resrc_require_tbl_type
);

PROCEDURE process_eam_workorders
(
  p_api_version          IN   NUMBER     := 1.0,
  p_init_msg_list        IN   VARCHAR2   := FND_API.G_TRUE,
  p_commit               IN   VARCHAR2   := FND_API.G_FALSE,
  p_validation_level     IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_default              IN   VARCHAR2   := FND_API.G_FALSE,
  p_module_type          IN   VARCHAR2   := NULL,
  x_return_status        OUT  NOCOPY  VARCHAR2,
  x_msg_count            OUT  NOCOPY  NUMBER,
  x_msg_data             OUT  NOCOPY  VARCHAR2,
  p_x_eam_wo_tbl         IN OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_tbl_type,
  p_eam_wo_relations_tbl IN    EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type,
  p_eam_op_tbl           IN    EAM_PROCESS_WO_PUB.eam_op_tbl_type,
  p_eam_res_req_tbl      IN    EAM_PROCESS_WO_PUB.eam_res_tbl_type,
  p_eam_mat_req_tbl      IN    EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
);

END AHL_EAM_JOB_PVT;

 

/
