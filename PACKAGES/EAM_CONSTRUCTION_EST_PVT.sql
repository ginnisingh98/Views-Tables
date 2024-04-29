--------------------------------------------------------
--  DDL for Package EAM_CONSTRUCTION_EST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_CONSTRUCTION_EST_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVCESS.pls 120.0.12010000.3 2009/01/09 18:49:02 devijay noship $ */
-- Start of Comments
-- Package name     : EAM_CONSTRUCTION_EST_PVT
-- Purpose          : Privatre Package Specification for Construction estimate
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE EXPLODE_INITIAL_ESTIMATE(
      p_api_version            IN  NUMBER        := 1.0
    , p_init_msg_list          IN  VARCHAR2      := 'F'
    , p_commit                  IN  VARCHAR2
    , p_estimate_id             IN  NUMBER
    , x_ce_msg_tbl              OUT NOCOPY EAM_EST_DATASTRUCTURES_PUB.EAM_CE_MESSAGE_TBL
    , x_return_status           OUT NOCOPY VARCHAR2
    , x_msg_count              OUT NOCOPY NUMBER
    , x_msg_data               OUT NOCOPY VARCHAR2
    );

PROCEDURE EXPLODE_CE_ACTIVITIES(
      p_estimate_id             IN  NUMBER
    , p_eam_ce_wo_lines_tbl     IN  EAM_EST_DATASTRUCTURES_PUB.EAM_CE_WORK_ORDER_LINES_TBL
    , x_eam_ce_wo_lines_tbl     OUT NOCOPY EAM_EST_DATASTRUCTURES_PUB.EAM_CE_WORK_ORDER_LINES_TBL
    , x_ce_msg_tbl              OUT NOCOPY EAM_EST_DATASTRUCTURES_PUB.EAM_CE_MESSAGE_TBL
    , x_return_status           OUT NOCOPY VARCHAR2);

PROCEDURE EXPLODE_STD_OP(
    p_std_op_id              IN NUMBER
  , p_op_seq                 IN NUMBER
  , p_op_seq_desc            IN VARCHAR2
  , p_org_id                 IN NUMBER
  , p_estimate_id            IN NUMBER
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER
  , x_msg_data               OUT NOCOPY VARCHAR2
);

PROCEDURE POPULATE_CE_WORK_ORDER_LINES(
      p_estimate_id             IN  NUMBER
    , p_ce_associatin_rec       IN  EAM_EST_DATASTRUCTURES_PUB.EAM_ESTIMATE_ASSOCIATIONS_REC
    , p_eam_ce_wo_lines_tbl     IN  EAM_EST_DATASTRUCTURES_PUB.EAM_CE_WORK_ORDER_LINES_TBL
    , p_eam_op_tbl              IN  EAM_PROCESS_WO_PUB.eam_op_tbl_type
    , p_eam_op_network_tbl      IN  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
    , p_eam_res_tbl             IN  EAM_PROCESS_WO_PUB.eam_res_tbl_type
    , p_eam_res_inst_tbl        IN  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
    , p_eam_sub_res_tbl         IN  EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
    , p_eam_res_usage_tbl       IN  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
    , p_eam_mat_req_tbl         IN  EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
    , x_eam_ce_wo_lines_tbl     OUT NOCOPY EAM_EST_DATASTRUCTURES_PUB.EAM_CE_WORK_ORDER_LINES_TBL
    , x_return_status           OUT NOCOPY VARCHAR2);

PROCEDURE INSERT_PARENT_WO_LINE(
    p_api_version                 IN  NUMBER        := 1.0
  , p_init_msg_list               IN  VARCHAR2      := FND_API.G_FALSE
  , p_commit                 IN VARCHAR2
  , p_estimate_id            IN NUMBER
  , p_parent_wo_line_rec     IN EAM_EST_DATASTRUCTURES_PUB.EAM_CE_PARENT_WO_REC
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER
  , x_msg_data               OUT NOCOPY VARCHAR2
);

PROCEDURE DELETE_WO_LINE(
    p_api_version                 IN  NUMBER        := 1.0
  , p_init_msg_list               IN  VARCHAR2      := FND_API.G_FALSE
  , p_commit                        IN VARCHAR2
  , p_work_order_line_id            IN NUMBER
  , x_return_status                 OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER
  , x_msg_data               OUT NOCOPY VARCHAR2
);

PROCEDURE INSERT_ALL_WO_LINES(
    p_api_version                 IN  NUMBER        := 1.0
  , p_init_msg_list               IN  VARCHAR2      := FND_API.G_FALSE
  , p_commit                 IN VARCHAR2
  , p_estimate_id            IN NUMBER
  , p_eam_ce_wo_lines_tbl    IN EAM_EST_DATASTRUCTURES_PUB.EAM_CE_WORK_ORDER_LINES_TBL
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER
  , x_msg_data               OUT NOCOPY VARCHAR2
);

PROCEDURE COPY_EST_WORKBENCH(
    p_api_version            IN  NUMBER        := 1.0
  , p_init_msg_list          IN  VARCHAR2      := 'F'
  , p_commit                 IN  VARCHAR2
  , p_src_estimate_id        IN  NUMBER
  , p_org_id                 IN  NUMBER
  , p_cpy_estimate_id        OUT NOCOPY NUMBER
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER
  , x_msg_data               OUT NOCOPY VARCHAR2
);


TYPE CELINES_TABLE_TYPE IS TABLE OF EAM_CE_WORK_ORDER_LINES%ROWTYPE;

PROCEDURE CREATE_CU_WORKORDERS(
       p_api_version                 IN  NUMBER        := 1.0
      ,p_init_msg_list               IN  VARCHAR2      := FND_API.G_FALSE
      ,p_commit                      IN  VARCHAR2      := FND_API.G_FALSE
      ,p_estimate_id                 IN  NUMBER
      ,x_return_status               OUT NOCOPY   VARCHAR2
      ,x_msg_count                   OUT NOCOPY   NUMBER
      ,x_msg_data                    OUT NOCOPY   VARCHAR2
      ,p_organization_id             IN  NUMBER
      ,p_debug_filename              IN  VARCHAR2 := 'EAM_CU_DEBUG.log'
      ,p_debug_file_mode             IN  VARCHAR2 := 'w'
);

PROCEDURE POPULATE_WO(
           p_parent_wo         IN  NUMBER
        ,  p_init_msg_list     VARCHAR2 := FND_API.G_FALSE
        ,  p_ce_line_rec       IN  EAM_CE_WORK_ORDER_LINES%ROWTYPE
        ,  x_eam_wo_rec        IN  OUT NOCOPY EAM_PROCESS_WO_PUB.EAM_WO_REC_TYPE
        ,  x_return_status     OUT NOCOPY VARCHAR2
        ,  x_msg_count         OUT NOCOPY NUMBER
        ,  x_msg_data          OUT NOCOPY VARCHAR2
);

PROCEDURE POPULATE_OPERATION(
           p_ce_line_rec       IN  EAM_CE_WORK_ORDER_LINES%ROWTYPE
        ,  p_init_msg_list     VARCHAR2 := FND_API.G_FALSE
        ,  x_eam_op_rec        IN  OUT NOCOPY EAM_PROCESS_WO_PUB.EAM_OP_REC_TYPE
        ,  x_return_status     OUT NOCOPY VARCHAR2
        ,  x_msg_count         OUT NOCOPY NUMBER
        ,  x_msg_data          OUT NOCOPY VARCHAR2
);

PROCEDURE POPULATE_RESOURCE(
           p_ce_line_rec       IN  EAM_CE_WORK_ORDER_LINES%ROWTYPE
        ,  p_init_msg_list     VARCHAR2 := FND_API.G_FALSE
        ,  x_eam_res_rec       IN  OUT NOCOPY EAM_PROCESS_WO_PUB.EAM_RES_REC_TYPE
        ,  x_return_status     OUT NOCOPY VARCHAR2
        ,  x_msg_count         OUT NOCOPY NUMBER
        ,  x_msg_data          OUT NOCOPY VARCHAR2
);

PROCEDURE POPULATE_MATERIAL(
           p_ce_line_rec       IN  EAM_CE_WORK_ORDER_LINES%ROWTYPE
        ,  p_init_msg_list     VARCHAR2 := FND_API.G_FALSE
        ,  x_eam_mat_rec       IN  OUT NOCOPY EAM_PROCESS_WO_PUB.EAM_MAT_REQ_REC_TYPE
        ,  x_eam_direct_rec    IN  OUT NOCOPY EAM_PROCESS_WO_PUB.EAM_DIRECT_ITEMS_REC_TYPE
        ,  x_return_status     OUT NOCOPY VARCHAR2
        ,  x_msg_count         OUT NOCOPY  NUMBER
        ,  x_msg_data          OUT NOCOPY  VARCHAR2
);

FUNCTION INIT_EAM_OP_TBL_TYPE RETURN EAM_PROCESS_WO_PUB.eam_op_tbl_type;

FUNCTION INIT_EAM_OP_NTK_TBL_TYPE RETURN EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;

FUNCTION INIT_EAM_RES_TBL_TYPE RETURN EAM_PROCESS_WO_PUB.eam_res_tbl_type;

FUNCTION INIT_EAM_RES_INST_TBL_TYPE RETURN EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;

FUNCTION INIT_EAM_SUB_RES_TBL_TYPE RETURN EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;

FUNCTION INIT_EAM_RES_USG_TBL_TYPE RETURN EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;

FUNCTION INIT_EAM_MAT_REQ_TBL_TYPE RETURN EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;

PROCEDURE GET_CU_RECS(
          p_api_version       IN NUMBER,
          p_commit            IN VARCHAR2,
          p_init_msg_list     IN VARCHAR2,
          p_validation_level  IN NUMBER,
          p_org_id            IN NUMBER,
          px_cu_tbl           IN OUT NOCOPY EAM_EST_DATASTRUCTURES_PUB.EAM_CONSTRUCTION_UNITS_TBL,
          x_return_status     OUT NOCOPY VARCHAR2,
          x_msg_count         OUT NOCOPY NUMBER,
          x_msg_data          OUT NOCOPY VARCHAR2
);

PROCEDURE GET_CU_ACTIVITIES(
          p_api_version       IN NUMBER,
          p_commit            IN VARCHAR2,
          p_init_msg_list     IN VARCHAR2,
          p_validation_level  IN NUMBER,
          p_cu_id             IN NUMBER,
          x_activities_tbl    OUT NOCOPY EAM_EST_DATASTRUCTURES_PUB.EAM_ESTIMATE_ASSOCIATIONS_TBL,
          x_return_status     OUT NOCOPY VARCHAR2,
          x_msg_count         OUT NOCOPY NUMBER,
          x_msg_data          OUT NOCOPY VARCHAR2
);

PROCEDURE CREATE_ESTIMATE(
          p_api_version       IN NUMBER,
          p_commit            IN VARCHAR2,
          p_init_msg_list     IN VARCHAR2,
          p_validation_level  IN NUMBER,
          px_estimate_rec     IN OUT NOCOPY EAM_EST_DATASTRUCTURES_PUB.EAM_CONSTRUCTION_ESTIMATE_REC,
          x_return_status     OUT NOCOPY VARCHAR2,
          x_msg_count         OUT NOCOPY NUMBER,
          x_msg_data          OUT NOCOPY VARCHAR2
);

PROCEDURE UPDATE_ESTIMATE(
          p_api_version       IN NUMBER,
          p_commit            IN VARCHAR2,
          p_init_msg_list     IN VARCHAR2,
          p_validation_level  IN NUMBER,
          p_estimate_rec      IN EAM_EST_DATASTRUCTURES_PUB.EAM_CONSTRUCTION_ESTIMATE_REC,
          x_return_status     OUT NOCOPY VARCHAR2,
          x_msg_count         OUT NOCOPY NUMBER,
          x_msg_data          OUT NOCOPY VARCHAR2
);

PROCEDURE SET_ACTIVITIES_FOR_CE(
          p_api_version       IN NUMBER,
          p_commit            IN VARCHAR2,
          p_init_msg_list     IN VARCHAR2,
          p_validation_level  IN NUMBER,
          p_ce_id             IN NUMBER,
          px_activities_tbl   IN OUT NOCOPY EAM_EST_DATASTRUCTURES_PUB.EAM_ESTIMATE_ASSOCIATIONS_TBL,
          x_return_status     OUT NOCOPY VARCHAR2,
          x_msg_count         OUT NOCOPY NUMBER,
          x_msg_data          OUT NOCOPY VARCHAR2
);

PROCEDURE UPDATE_CE_WO_LNS_BY_GROUP_OPT(
          p_api_version       IN NUMBER,
          p_commit            IN VARCHAR2,
          p_init_msg_list     IN VARCHAR2,
          p_validation_level  IN NUMBER,
          p_ce_wo_defaults    IN EAM_EST_DATASTRUCTURES_PUB.EAM_CE_WO_DEFAULTS_REC,
          x_return_status     OUT NOCOPY VARCHAR2,
          x_msg_count         OUT NOCOPY NUMBER,
          x_msg_data          OUT NOCOPY VARCHAR2
);

End EAM_CONSTRUCTION_EST_PVT;

/
