--------------------------------------------------------
--  DDL for Package EAM_CONSTRUCTION_EST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_CONSTRUCTION_EST_PUB" AUTHID CURRENT_USER AS
/* $Header: EAMPCESS.pls 120.0.12010000.3 2008/12/09 21:08:56 devijay noship $ */
-- Start of Comments
-- Package name     : EAM_CONSTRUCTION_EST_PUB
-- Purpose          : Spec of package EAM_CONSTRUCTION_EST_PUB
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
    , x_msg_data               OUT NOCOPY VARCHAR2);

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

PROCEDURE CREATE_CU_WORKORDERS(
  p_api_version                  IN  NUMBER        := 1.0
  ,p_init_msg_list               IN  VARCHAR2      := FND_API.G_FALSE
  ,p_commit                      IN  VARCHAR2      := FND_API.G_FALSE
  ,p_estimate_id                 IN  NUMBER
  ,x_return_status               OUT NOCOPY VARCHAR2
  ,x_msg_count                   OUT NOCOPY NUMBER
  ,x_msg_data                    OUT NOCOPY VARCHAR2
  ,p_organization_id             IN  NUMBER
  ,p_debug_filename              IN  VARCHAR2      := 'EAM_CU_DEBUG.log'
  ,p_debug_file_mode             IN  VARCHAR2      := 'w'
);

PROCEDURE GET_CU_RECS(
          p_api_version       IN  NUMBER,
          p_commit            IN  VARCHAR2,
          p_init_msg_list     IN  VARCHAR2,
          p_validation_level  IN  NUMBER,
          p_org_id            IN  NUMBER,
          px_cu_tbl           IN  OUT NOCOPY EAM_EST_DATASTRUCTURES_PUB.EAM_CONSTRUCTION_UNITS_TBL,
          x_return_status     OUT NOCOPY VARCHAR2,
          x_msg_count         OUT NOCOPY NUMBER,
          x_msg_data          OUT NOCOPY VARCHAR2
);

PROCEDURE GET_CU_ACTIVITIES(
          p_api_version       IN  NUMBER,
          p_commit            IN  VARCHAR2,
          p_init_msg_list     IN  VARCHAR2,
          p_validation_level  IN  NUMBER,
          p_cu_id             IN  NUMBER,
          x_activities_tbl    OUT NOCOPY EAM_EST_DATASTRUCTURES_PUB.EAM_ESTIMATE_ASSOCIATIONS_TBL,
          x_return_status     OUT NOCOPY VARCHAR2,
          x_msg_count         OUT NOCOPY NUMBER,
          x_msg_data          OUT NOCOPY VARCHAR2
);

PROCEDURE CREATE_ESTIMATE(
          p_api_version       IN  NUMBER,
          p_commit            IN  VARCHAR2,
          p_init_msg_list     IN  VARCHAR2,
          p_validation_level  IN  NUMBER,
          px_estimate_rec     IN  OUT NOCOPY EAM_EST_DATASTRUCTURES_PUB.EAM_CONSTRUCTION_ESTIMATE_REC,
          x_return_status     OUT NOCOPY VARCHAR2,
          x_msg_count         OUT NOCOPY NUMBER,
          x_msg_data          OUT NOCOPY VARCHAR2
);

PROCEDURE UPDATE_ESTIMATE(
          p_api_version       IN  NUMBER,
          p_commit            IN  VARCHAR2,
          p_init_msg_list     IN  VARCHAR2,
          p_validation_level  IN  NUMBER,
          p_estimate_rec      IN  EAM_EST_DATASTRUCTURES_PUB.EAM_CONSTRUCTION_ESTIMATE_REC,
          x_return_status     OUT NOCOPY VARCHAR2,
          x_msg_count         OUT NOCOPY NUMBER,
          x_msg_data          OUT NOCOPY VARCHAR2
);

PROCEDURE SET_ACTIVITIES_FOR_CE(
          p_api_version       IN  NUMBER,
          p_commit            IN  VARCHAR2,
          p_init_msg_list     IN  VARCHAR2,
          p_validation_level  IN  NUMBER,
          p_ce_id             IN  NUMBER,
          px_activities_tbl   IN  OUT NOCOPY EAM_EST_DATASTRUCTURES_PUB.EAM_ESTIMATE_ASSOCIATIONS_TBL,
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

PROCEDURE COPY_EST_WORKBENCH(
    p_api_version            IN    NUMBER        := 1.0
  , p_init_msg_list          IN    VARCHAR2      := 'F'
  , p_commit                 IN VARCHAR2
  , p_src_estimate_id            IN NUMBER
  , p_org_id                 IN NUMBER
  , p_cpy_estimate_id        OUT NOCOPY NUMBER
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_count                   OUT NOCOPY   NUMBER
  , x_msg_data                    OUT NOCOPY   VARCHAR2
);

End EAM_CONSTRUCTION_EST_PUB;

/
