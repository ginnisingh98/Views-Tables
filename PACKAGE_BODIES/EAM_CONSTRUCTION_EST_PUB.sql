--------------------------------------------------------
--  DDL for Package Body EAM_CONSTRUCTION_EST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_CONSTRUCTION_EST_PUB" AS
/* $Header: EAMPCESB.pls 120.0.12010000.5 2009/01/03 00:03:31 devijay noship $ */
-- Start of Comments
-- Package name     : EAM_CONSTRUCTION_EST_PUB
-- Purpose          : Spec of package EAM_CONSTRUCTION_EST_PUB
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME  CONSTANT VARCHAR2(30) := 'EAM_CONSTRUCTION_EST_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'EAMPCESB.pls';

PROCEDURE EXPLODE_INITIAL_ESTIMATE(
      p_api_version            IN  NUMBER        := 1.0
    , p_init_msg_list          IN  VARCHAR2      := 'F'
    , p_commit                  IN  VARCHAR2
    , p_estimate_id             IN  NUMBER
    , x_ce_msg_tbl              OUT NOCOPY EAM_EST_DATASTRUCTURES_PUB.EAM_CE_MESSAGE_TBL
    , x_return_status           OUT NOCOPY VARCHAR2
    , x_msg_count              OUT NOCOPY NUMBER
    , x_msg_data               OUT NOCOPY VARCHAR2)
IS
BEGIN
  EAM_CONSTRUCTION_EST_PVT.EXPLODE_INITIAL_ESTIMATE(
      p_api_version            => p_api_version,
      p_init_msg_list          => p_init_msg_list,
      p_commit                 => p_commit,
      p_estimate_id            => p_estimate_id,
      x_ce_msg_tbl             => x_ce_msg_tbl,
      x_return_status          => x_return_status,
      x_msg_count              => x_msg_count,
      x_msg_data               => x_msg_data
    );
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'E';
END EXPLODE_INITIAL_ESTIMATE;

PROCEDURE INSERT_PARENT_WO_LINE(
  p_api_version                 IN  NUMBER        := 1.0
  , p_init_msg_list               IN  VARCHAR2      := FND_API.G_FALSE
  , p_commit                 IN VARCHAR2
  , p_estimate_id            IN NUMBER
  , p_parent_wo_line_rec     IN EAM_EST_DATASTRUCTURES_PUB.EAM_CE_PARENT_WO_REC
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER
  , x_msg_data               OUT NOCOPY VARCHAR2
)
IS
BEGIN
  EAM_CONSTRUCTION_EST_PVT.INSERT_PARENT_WO_LINE(
      p_api_version          =>     p_api_version
    , p_init_msg_list        =>     p_init_msg_list
    , p_commit               =>     p_commit
    , p_estimate_id          =>     p_estimate_id
    , p_parent_wo_line_rec   =>     p_parent_wo_line_rec
    , x_return_status        =>     x_return_status
    , x_msg_count            =>     x_msg_count
    , x_msg_data             =>     x_msg_data  );
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'E';
END INSERT_PARENT_WO_LINE;

PROCEDURE DELETE_WO_LINE(
    p_api_version                 IN  NUMBER        := 1.0
  , p_init_msg_list               IN  VARCHAR2      := FND_API.G_FALSE
  , p_commit                        IN VARCHAR2
  , p_work_order_line_id            IN NUMBER
  , x_return_status                 OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER
  , x_msg_data               OUT NOCOPY VARCHAR2
)
IS
BEGIN
  EAM_CONSTRUCTION_EST_PVT.DELETE_WO_LINE(
      p_api_version          =>  p_api_version
    , p_init_msg_list      =>  p_init_msg_list
    , p_commit             =>  p_commit
    , p_work_order_line_id =>  p_work_order_line_id
    , x_return_status      =>  x_return_status
    , x_msg_count          =>  x_msg_count
    , x_msg_data           =>  x_msg_data );
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'E';
END DELETE_WO_LINE;

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
)
IS
  CURSOR GET_WOKRODER_NAME (p_wip_entityid IN NUMBER) IS
    SELECT WIP_ENTITY_NAME
      FROM WIP_ENTITIES
      WHERE WIP_ENTITY_ID = p_wip_entityid;

  CURSOR EST_WORKORDERS IS
  SELECT DISTINCT ESTIMATE_WORK_ORDER_ID
   FROM EAM_CE_WORK_ORDER_LINES
    WHERE ESTIMATE_ID = p_estimate_id
    AND ORGANIZATION_ID = p_organization_id;

   l_wip_name_rec    GET_WOKRODER_NAME%ROWTYPE;
   l_est_wo_rec    EST_WORKORDERS%ROWTYPE;

BEGIN
    -- Call private CREATE_CU_WORKORDERS to create work orders
    EAM_CONSTRUCTION_EST_PVT.CREATE_CU_WORKORDERS(
    p_api_version      	=> p_api_version
    ,p_init_msg_list   	=> p_init_msg_list
    ,p_commit          	=> p_commit
    ,p_estimate_id     	=> p_estimate_id
    ,x_return_status   	=> x_return_status
    ,x_msg_count       	=> x_msg_count
    ,x_msg_data        	=> x_msg_data
    ,p_organization_id 	=> p_organization_id
    ,p_debug_filename  	=> p_debug_filename
    ,p_debug_file_mode 	=> p_debug_file_mode);

     IF nvl(x_return_status,'S') <> 'S' THEN
      -- Log error, but continue processing
      x_return_status := 'E';
      RAISE FND_API.G_EXC_ERROR;
     END IF; -- nvl(l_return_status,'S') <> 'S'

     -- Now that work orders are created, need to handle condition
     -- where work order number was not provided, but assigned
     -- automaticially by the work order API
     FOR l_est_wo_rec IN EST_WORKORDERS
     LOOP
      IF NVL(l_est_wo_rec.ESTIMATE_WORK_ORDER_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
        -- Find the wip entity name for the estimate work order id
          OPEN GET_WOKRODER_NAME(l_est_wo_rec.ESTIMATE_WORK_ORDER_ID);
          FETCH GET_WOKRODER_NAME INTO l_wip_name_rec;
          CLOSE GET_WOKRODER_NAME;

          -- Update EAM_CE_WORK_ORDER_LINES with the wip entity name
          UPDATE EAM_CE_WORK_ORDER_LINES SET WORK_ORDER_NUMBER = l_wip_name_rec.WIP_ENTITY_NAME
             WHERE ESTIMATE_ID = p_estimate_id
             AND ORGANIZATION_ID = p_organization_id
             AND ESTIMATE_WORK_ORDER_ID = l_est_wo_rec.ESTIMATE_WORK_ORDER_ID;

      END IF; -- NVL(l_est_wo_rec.ESTIMATE_WORK_ORDER_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM
     END LOOP; -- FOR l_est_wo_rec IN EST_WORKORDERS

     IF NVL(p_commit,'F') = 'T' THEN
      COMMIT;
     END IF;

     x_return_status := 'S';
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := 'E';
  WHEN OTHERS THEN
    x_return_status := 'E';
END CREATE_CU_WORKORDERS;

PROCEDURE INSERT_ALL_WO_LINES(
   p_api_version                 IN  NUMBER        := 1.0
  , p_init_msg_list               IN  VARCHAR2      := FND_API.G_FALSE
  , p_commit                 IN VARCHAR2
  , p_estimate_id            IN NUMBER
  , p_eam_ce_wo_lines_tbl    IN EAM_EST_DATASTRUCTURES_PUB.EAM_CE_WORK_ORDER_LINES_TBL
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER
  , x_msg_data               OUT NOCOPY VARCHAR2)
IS
BEGIN
  EAM_CONSTRUCTION_EST_PVT.INSERT_ALL_WO_LINES(
      p_api_version            =>  p_api_version
    , p_init_msg_list        =>  p_init_msg_list
    , p_commit               =>  p_commit
    , p_estimate_id          =>  p_estimate_id
    , p_eam_ce_wo_lines_tbl  =>  p_eam_ce_wo_lines_tbl
    , x_return_status        =>  x_return_status
    , x_msg_count            =>  x_msg_count
    , x_msg_data             =>  x_msg_data);
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'E';
END INSERT_ALL_WO_LINES;

PROCEDURE GET_CU_RECS(
          p_api_version       IN  NUMBER,
          p_commit            IN  VARCHAR2,
          p_init_msg_list     IN  VARCHAR2,
          p_validation_level  IN  NUMBER,
          p_org_id            IN  NUMBER,
          px_cu_tbl           IN  OUT NOCOPY EAM_EST_DATASTRUCTURES_PUB.EAM_CONSTRUCTION_UNITS_TBL,
          x_return_status     OUT NOCOPY VARCHAR2,
          x_msg_count         OUT NOCOPY NUMBER,
          x_msg_data          OUT NOCOPY VARCHAR2)
IS
BEGIN
  EAM_CONSTRUCTION_EST_PVT.GET_CU_RECS(
      p_api_version       => p_api_version,
      p_commit            => p_commit,
      p_init_msg_list     => p_init_msg_list,
      p_validation_level  => p_validation_level,
      p_org_id            => p_org_id,
      px_cu_tbl           => px_cu_tbl,
      x_return_status     => x_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data);
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'E';
END GET_CU_RECS;

PROCEDURE GET_CU_ACTIVITIES(
          p_api_version       IN  NUMBER,
          p_commit            IN  VARCHAR2,
          p_init_msg_list     IN  VARCHAR2,
          p_validation_level  IN  NUMBER,
          p_cu_id             IN  NUMBER,
          x_activities_tbl    OUT NOCOPY EAM_EST_DATASTRUCTURES_PUB.EAM_ESTIMATE_ASSOCIATIONS_TBL,
          x_return_status     OUT NOCOPY VARCHAR2,
          x_msg_count         OUT NOCOPY NUMBER,
          x_msg_data          OUT NOCOPY VARCHAR2)
IS
BEGIN
  EAM_CONSTRUCTION_EST_PVT.GET_CU_ACTIVITIES(
      p_api_version       => p_api_version,
      p_commit            => p_commit,
      p_init_msg_list     => p_init_msg_list,
      p_validation_level  => p_validation_level,
      p_cu_id             => p_cu_id,
      x_activities_tbl    => x_activities_tbl,
      x_return_status     => x_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data);
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'E';
END GET_CU_ACTIVITIES;

PROCEDURE CREATE_ESTIMATE(
          p_api_version       IN  NUMBER,
          p_commit            IN  VARCHAR2,
          p_init_msg_list     IN  VARCHAR2,
          p_validation_level  IN  NUMBER,
          px_estimate_rec     IN  OUT NOCOPY EAM_EST_DATASTRUCTURES_PUB.EAM_CONSTRUCTION_ESTIMATE_REC,
          x_return_status     OUT NOCOPY VARCHAR2,
          x_msg_count         OUT NOCOPY NUMBER,
          x_msg_data          OUT NOCOPY VARCHAR2)
IS
BEGIN
  EAM_CONSTRUCTION_EST_PVT.CREATE_ESTIMATE(
      p_api_version       => p_api_version,
      p_commit            => p_commit,
      p_init_msg_list     => p_init_msg_list,
      p_validation_level  => p_validation_level,
      px_estimate_rec     => px_estimate_rec,
      x_return_status     => x_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data);
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'E';
END CREATE_ESTIMATE;

PROCEDURE UPDATE_ESTIMATE(
          p_api_version       IN  NUMBER,
          p_commit            IN  VARCHAR2,
          p_init_msg_list     IN  VARCHAR2,
          p_validation_level  IN  NUMBER,
          p_estimate_rec      IN  EAM_EST_DATASTRUCTURES_PUB.EAM_CONSTRUCTION_ESTIMATE_REC,
          x_return_status     OUT NOCOPY VARCHAR2,
          x_msg_count         OUT NOCOPY NUMBER,
          x_msg_data          OUT NOCOPY VARCHAR2)
IS
BEGIN
  EAM_CONSTRUCTION_EST_PVT.UPDATE_ESTIMATE(
      p_api_version       => p_api_version,
      p_commit            => p_commit,
      p_init_msg_list     => p_init_msg_list,
      p_validation_level  => p_validation_level,
      p_estimate_rec      => p_estimate_rec,
      x_return_status     => x_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data);
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'E';
END UPDATE_ESTIMATE;

PROCEDURE SET_ACTIVITIES_FOR_CE(
          p_api_version       IN  NUMBER,
          p_commit            IN  VARCHAR2,
          p_init_msg_list     IN  VARCHAR2,
          p_validation_level  IN  NUMBER,
          p_ce_id             IN  NUMBER,
          px_activities_tbl   IN  OUT NOCOPY EAM_EST_DATASTRUCTURES_PUB.EAM_ESTIMATE_ASSOCIATIONS_TBL,
          x_return_status     OUT NOCOPY VARCHAR2,
          x_msg_count         OUT NOCOPY NUMBER,
          x_msg_data          OUT NOCOPY VARCHAR2)
IS
BEGIN
  EAM_CONSTRUCTION_EST_PVT.SET_ACTIVITIES_FOR_CE(
      p_api_version       => p_api_version,
      p_commit            => p_commit,
      p_init_msg_list     => p_init_msg_list,
      p_validation_level  => p_validation_level,
      p_ce_id             => p_ce_id,
      px_activities_tbl   => px_activities_tbl,
      x_return_status     => x_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data);
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'E';
END SET_ACTIVITIES_FOR_CE;

PROCEDURE UPDATE_CE_WO_LNS_BY_GROUP_OPT(
          p_api_version       IN  NUMBER,
          p_commit            IN  VARCHAR2,
          p_init_msg_list     IN  VARCHAR2,
          p_validation_level  IN  NUMBER,
          p_ce_wo_defaults    IN  EAM_EST_DATASTRUCTURES_PUB.EAM_CE_WO_DEFAULTS_REC,
          x_return_status     OUT NOCOPY VARCHAR2,
          x_msg_count         OUT NOCOPY NUMBER,
          x_msg_data          OUT NOCOPY VARCHAR2)
IS
BEGIN
  EAM_CONSTRUCTION_EST_PVT.UPDATE_CE_WO_LNS_BY_GROUP_OPT(
      p_api_version       => p_api_version,
      p_commit            => p_commit,
      p_init_msg_list     => p_init_msg_list,
      p_validation_level  => p_validation_level,
      p_ce_wo_defaults    => p_ce_wo_defaults,
      x_return_status     => x_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data);
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'E';
END UPDATE_CE_WO_LNS_BY_GROUP_OPT;

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
)
IS
BEGIN
  EAM_CONSTRUCTION_EST_PVT.COPY_EST_WORKBENCH(
    p_api_version          => p_api_version
  , p_init_msg_list        => p_init_msg_list
  , p_commit               => p_commit
  , p_src_estimate_id      => p_src_estimate_id
  , p_org_id               => p_org_id
  , p_cpy_estimate_id      => p_cpy_estimate_id
  , x_return_status        => x_return_status
  , x_msg_count            => x_msg_count
  , x_msg_data             => x_msg_data
);
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'E';
END COPY_EST_WORKBENCH;


End EAM_CONSTRUCTION_EST_PUB;

/
