--------------------------------------------------------
--  DDL for Package Body AHL_OSP_SERV_ITEM_RELS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_OSP_SERV_ITEM_RELS_PVT" AS
/* $Header: AHLVOSRB.pls 120.6 2006/07/26 06:21:27 mpothuku noship $ */

  G_PKG_NAME            CONSTANT  VARCHAR2(30) := 'AHL_OSP_SERV_ITEM_RELS_PVT';
  G_APP_NAME            CONSTANT  VARCHAR2(3)  := 'AHL';


/*#
 * This package Contains Record type and private procedures to process Service Item relationship with Inv Item.
 * @rep:scope public
 * @rep:product AHL
 * @rep:displayname Process OSP Inv Itm Service Itm Relations
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY AHL_OSP_ORDER
 */


------------------------
-- Declare Procedures --
------------------------

-- Start of Comments --
--  Procedure name    : PROCESS_SERV_ITM_RELS
--  Type              : Public
--  Function          : For creating/updating relationship between Inv Item and Service Item.
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Default  1.0
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_TRUE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--  Standard OUT Parameters :
--      x_return_status                 OUT NOCOPY     VARCHAR2             Required
--      x_msg_count                     OUT NOCOPY     NUMBER               Required
--      x_msg_data                      OUT NOCOPY     VARCHAR2             Required
--
--  Process Order Parameters:
--       p_x_Inv_serv_item_rec          IN OUT NOCOPY  Inv_Serv_Item_Rels_Rec_Type    Required
--         All parameters for Inv Item Service Item relationship
--
--
--  Version :
--               Initial Version   1.0
--
--  End of Comments.
/*#
 * This procedure is used to process a Shipment order related to an OSP Order.
 * @param p_api_version API Version Number
 * @param p_init_msg_list Initialize the message stack, default value FND_API.G_TRUE
 * @param p_commit to decide whether to commit the transaction or not, default value FND_API.G_FALSE
 * @param p_validation_level validation level, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_module_type Module type of the caller
 * @param p_x_header_rec Contains the attributes of the Shipment header, of type AHL_OSP_SHIPMENT_PUB.Ship_Header_Rec_Type
 * @param x_return_status return status
 * @param x_msg_count return message count
 * @param x_msg_data return message data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Process Inv Item Service Item Relations
 */
PROCEDURE PROCESS_SERV_ITM_RELS (
    p_api_version           IN        NUMBER    := 1.0,
    p_init_msg_list         IN        VARCHAR2  := FND_API.G_TRUE,
    p_commit                IN        VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN        NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_module_type           IN        VARCHAR2  := NULL,
    p_x_Inv_serv_item_rec   IN OUT NOCOPY   AHL_OSP_SERV_ITEM_RELS_PVT.Inv_Serv_Item_Rels_Rec_Type,
    x_return_status         OUT NOCOPY           VARCHAR2,
    x_msg_count             OUT NOCOPY           NUMBER,
    x_msg_data              OUT NOCOPY           VARCHAR2)
 IS
   l_api_name       CONSTANT VARCHAR2(30)  := 'process_serv_itm_rels';
   l_api_version    CONSTANT NUMBER        := 1.0;
   L_DEBUG_KEY      CONSTANT VARCHAR2(150) := 'ahl.plsql.ahl_osp_serv_item_rels_pvt.process_serv_itm_rels';


   CURSOR get_Item_info_csr(p_org_name VARCHAR,
                            p_item_name VARCHAR,
                            p_item_flag VARCHAR)
    IS
    /*
    SELECT
    inventory_item_id      ,
    inventory_org_id
    FROM ahl_mtl_items_ou_v
    WHERE organization_name = p_org_name
      AND concatenated_segments = p_item_name
      AND inventory_item_flag = p_item_flag
      AND NVL(start_date_active, sysdate) <= sysdate
      AND NVL(end_date_active, sysdate + 1) > sysdate
      AND DECODE(p_item_flag,'N',purchasing_enabled_flag,'Y') = 'Y'
      AND DECODE(p_item_flag,'N',NVL(outside_operation_flag, 'N'),'N') = 'N';
     */
     --Changed by mpothuku for fixing the Performance Bug# 4919315

   SELECT
    mtl.inventory_item_id,
    mtl.organization_id inventory_org_id
    FROM mtl_system_items_kfv mtl, inv_organization_info_v org, hr_all_organization_units hou
    WHERE hou.name = p_org_name
      AND mtl.concatenated_segments = p_item_name
      AND mtl.organization_id = org.organization_id
      AND hou.organization_id = org.organization_id
      AND NVL (org.operating_unit, mo_global.get_current_org_id ()) = mo_global.get_current_org_id()
      AND mtl.inventory_item_flag = p_item_flag
      AND NVL(mtl.start_date_active, sysdate) <= sysdate
      AND NVL(mtl.end_date_active, sysdate + 1) > sysdate
      AND DECODE(p_item_flag,'N',mtl.purchasing_enabled_flag,'Y') = 'Y'
      AND DECODE(p_item_flag,'N',NVL(mtl.outside_operation_flag, 'N'),'N') = 'N';

   CURSOR get_Item_info_id_csr(p_org_id VARCHAR,
                                p_item_id VARCHAR,
                                p_item_flag VARCHAR)
    IS
    /*
    SELECT
    inventory_item_id      ,
    inventory_org_id
    FROM ahl_mtl_items_ou_v
    WHERE inventory_org_id = p_org_id
      AND inventory_item_id = p_item_id
      AND inventory_item_flag = p_item_flag
      AND NVL(start_date_active, sysdate) <= sysdate
      AND NVL(end_date_active, sysdate + 1) > sysdate
      AND DECODE(p_item_flag,'N',purchasing_enabled_flag,'Y') = 'Y'
      AND DECODE(p_item_flag,'N',NVL(outside_operation_flag, 'N'),'N') = 'N';
    */
    --Changed by mpothuku for fixing the Performance Bug# 4919315
   SELECT
    mtl.inventory_item_id,
    mtl.organization_id inventory_org_id
    FROM mtl_system_items_b mtl, inv_organization_info_v org
    WHERE mtl.organization_id = p_org_id
      AND mtl.inventory_item_id = p_item_id
      AND mtl.organization_id = org.organization_id
      AND NVL (org.operating_unit, mo_global.get_current_org_id ()) = mo_global.get_current_org_id()
      AND mtl.inventory_item_flag = p_item_flag
      AND NVL(mtl.start_date_active, sysdate) <= sysdate
      AND NVL(mtl.end_date_active, sysdate + 1) > sysdate
      AND DECODE(p_item_flag,'N',mtl.purchasing_enabled_flag,'Y') = 'Y'
      AND DECODE(p_item_flag,'N',NVL(mtl.outside_operation_flag, 'N'),'N') = 'N';

    CURSOR Item_Ser_rel_det_csr(p_ser_item_rel_id NUMBER)
    IS
    SELECT
    inv_service_item_rel_id        ,
    object_version_number          ,
    inv_item_id                    ,
    inv_org_id                     ,
    service_item_id                ,
    rank                           ,
    active_start_date              ,
    active_end_date
   FROM  ahl_inv_service_item_rels
   WHERE inv_service_item_rel_id = p_ser_item_rel_id
   FOR UPDATE;


CURSOR Item_Ser_rel_exists_csr(P_inv_org_id NUMBER,p_inv_item_id NUMBER,p_service_item_id NUMBER)
       IS
       SELECT 'X'
      FROM  ahl_inv_service_item_rels
      WHERE inv_org_id = p_inv_org_id
      AND   inv_item_id = p_inv_item_id
      AND service_item_id = p_service_item_id;


CURSOR Item_rank_exists_csr(P_inv_org_id NUMBER,p_inv_item_id NUMBER,p_rank NUMBER,p_serv_rel_id NUMBER)
       IS
       SELECT 'X'
      FROM  ahl_inv_service_item_rels
      WHERE inv_org_id = p_inv_org_id
      AND   inv_item_id = p_inv_item_id
      AND   rank = p_rank
      AND   INV_SERVICE_ITEM_REL_ID <> NVL(p_serv_rel_id,-99);

CURSOR org_item_rank_exists_csr(p_inv_item_id NUMBER, p_service_item_id NUMBER,  p_rank NUMBER) IS
       SELECT
       isirv.inv_org_id,
       isirv.inv_org_name,
       isirv.inv_item_number,
       isirv.service_item_number,
       isirv.rank
       /* Removed the OU filtering here, as the view ahl_inv_service_item_rels_v itself is OU filtered with the Bug
       fix 5350882, mpothuku 26-Jul-06 */
       FROM  ahl_inv_service_item_rels_v isirv,
       	     mtl_system_items_b mtl
       /*
       inv_organization_info_v org
       */
       WHERE isirv.inv_item_id = p_inv_item_id
       AND   isirv.service_item_id <> p_service_item_id
       /*
       If p_service_item_id is not assigned to the Org thats being considered
       there is no need to throw the validation, the creation simply escapes it anyway if the
       service item does not belong to the Org thats being considered
       */
       AND   mtl.inventory_item_id = p_service_item_id
       AND   mtl.organization_id = isirv.inv_org_id
       AND   isirv.rank = p_rank;
       /* Fix for the Bug# 5167378 by mpothuku on 17-Apr-06 */
       /*
       AND NVL(org.operating_unit, mo_global.get_current_org_id())= mo_global.get_current_org_id();
       */

   l_Item_Ser_rel_det Item_Ser_rel_det_csr%ROWTYPE;
   l_org_item_rank_exists_csr org_item_rank_exists_csr%ROWTYPE;
   l_dummy VARCHAR(1);
   l_count NUMBER;

 BEGIN



   -- Standard start of API savepoint
   SAVEPOINT process_serv_items_pvt;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                      G_PKG_NAME) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE
   IF FND_API.To_Boolean(p_init_msg_list) THEN
     FND_MSG_PUB.Initialize;
   END IF;

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
   END IF;

   IF p_x_Inv_serv_item_rec.operation_flag IS NULL THEN
       FND_MESSAGE.set_name('AHL', 'AHL_OSP_OPER_FLAG_NULL');
       FND_MSG_PUB.ADD;
       IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED, L_DEBUG_KEY, FALSE);
       END IF;
    RAISE Fnd_Api.g_exc_error;
   END IF;

   IF p_x_Inv_serv_item_rec.operation_flag = 'C' THEN

   IF (p_x_Inv_serv_item_rec.inv_org_id IS NULL OR
      p_x_Inv_serv_item_rec.inv_org_id = FND_API.G_MISS_NUM) AND
      (p_x_Inv_serv_item_rec.inv_org_name IS NULL OR
      p_x_Inv_serv_item_rec.inv_org_name = FND_API.G_MISS_CHAR) THEN
       FND_MESSAGE.set_name('AHL', 'AHL_OSP_ORG_NAME_NULL');
       FND_MSG_PUB.ADD;
       IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED, L_DEBUG_KEY, FALSE);
       END IF;
   END IF;

   IF (p_x_Inv_serv_item_rec.inv_item_id IS NULL OR
      p_x_Inv_serv_item_rec.inv_item_id = FND_API.G_MISS_NUM) AND
      (p_x_Inv_serv_item_rec.inv_item_name IS NULL OR
      p_x_Inv_serv_item_rec.inv_item_name = FND_API.G_MISS_CHAR) THEN
       FND_MESSAGE.set_name('AHL', 'AHL_OSP_INV_ITEM_NULL');
       FND_MSG_PUB.ADD;
       IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED, L_DEBUG_KEY, FALSE);
       END IF;
   END IF;

   IF (p_x_Inv_serv_item_rec.service_item_id IS NULL OR
      p_x_Inv_serv_item_rec.service_item_id = FND_API.G_MISS_NUM) AND
      (p_x_Inv_serv_item_rec.service_item_name IS NULL OR
      p_x_Inv_serv_item_rec.service_item_name = FND_API.G_MISS_CHAR) THEN
       FND_MESSAGE.set_name('AHL', 'AHL_OSP_SER_ITEM_NULL');
       FND_MSG_PUB.ADD;
       IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED, L_DEBUG_KEY, FALSE);
       END IF;
   END IF;

    IF p_x_Inv_serv_item_rec.inv_org_name IS NOT NULL
       AND p_x_Inv_serv_item_rec.inv_item_name IS NOT NULL THEN

        OPEN get_Item_info_csr(p_x_Inv_serv_item_rec.inv_org_name,
                       p_x_Inv_serv_item_rec.inv_item_name,'Y');
        FETCH get_Item_info_csr INTO p_x_Inv_serv_item_rec.inv_item_id,
                         p_x_Inv_serv_item_rec.inv_org_id;
        IF get_Item_info_csr%NOTFOUND THEN
           FND_MESSAGE.set_name('AHL', 'AHL_OSP_INVALID_INV_ITEM');
           FND_MSG_PUB.ADD;
           IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED, L_DEBUG_KEY, FALSE);
           END IF;
           CLOSE get_Item_info_csr;
           RAISE Fnd_Api.g_exc_error;
        END IF;
        CLOSE  get_Item_info_csr;
     ELSE
        OPEN get_Item_info_id_csr(p_x_Inv_serv_item_rec.inv_org_id,
                       p_x_Inv_serv_item_rec.inv_item_id,'Y');
        FETCH get_Item_info_id_csr INTO p_x_Inv_serv_item_rec.inv_item_id,
                         p_x_Inv_serv_item_rec.inv_org_id;
        IF get_Item_info_id_csr%NOTFOUND THEN
           FND_MESSAGE.set_name('AHL', 'AHL_OSP_INVALID_INV_ITEM');
           FND_MSG_PUB.ADD;
           IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED, L_DEBUG_KEY, FALSE);
           END IF;
           CLOSE get_Item_info_id_csr;
           RAISE Fnd_Api.g_exc_error;
        END IF;
        CLOSE  get_Item_info_id_csr;

     END IF;

     IF TRUNC(p_x_Inv_serv_item_rec.active_start_date) < TRUNC(SYSDATE) THEN
        FND_MESSAGE.set_name('AHL', 'AHL_VENDOR_START_DATE_PAST');
        FND_MSG_PUB.ADD;
        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED, L_DEBUG_KEY, FALSE);
        END IF;
     END IF;

    IF p_x_Inv_serv_item_rec.service_item_name IS NOT NULL
       AND p_x_Inv_serv_item_rec.inv_item_name IS NOT NULL THEN

        OPEN get_Item_info_csr(p_x_Inv_serv_item_rec.inv_org_name,
                       p_x_Inv_serv_item_rec.service_item_name,'N');
        FETCH get_Item_info_csr INTO p_x_Inv_serv_item_rec.service_item_id,
                         p_x_Inv_serv_item_rec.inv_org_id;
        IF get_Item_info_csr%NOTFOUND THEN
           FND_MESSAGE.set_name('AHL', 'AHL_OSP_INVALID_SERV_ITEM');
           FND_MSG_PUB.ADD;
           IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED, L_DEBUG_KEY, FALSE);
           END IF;
           CLOSE get_Item_info_csr;
           RAISE Fnd_Api.g_exc_error;
        END IF;
        CLOSE  get_Item_info_csr;
     ELSE
        OPEN get_Item_info_id_csr(p_x_Inv_serv_item_rec.inv_org_id,
                       p_x_Inv_serv_item_rec.service_item_id,'N');
        FETCH get_Item_info_id_csr INTO p_x_Inv_serv_item_rec.service_item_id,
                         p_x_Inv_serv_item_rec.inv_org_id;
        IF get_Item_info_id_csr%NOTFOUND THEN
           FND_MESSAGE.set_name('AHL', 'AHL_OSP_INVALID_SERV_ITEM');
           FND_MSG_PUB.ADD;
           IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED, L_DEBUG_KEY, FALSE);
           END IF;
           CLOSE get_Item_info_id_csr;
           RAISE Fnd_Api.g_exc_error;
        END IF;
        CLOSE  get_Item_info_id_csr;

     END IF;


    OPEN Item_Ser_rel_exists_csr(p_x_Inv_serv_item_rec.inv_org_id,
                                 p_x_Inv_serv_item_rec.inv_item_id,
                                 p_x_Inv_serv_item_rec.service_item_id);
    FETCH Item_Ser_rel_exists_csr INTO l_dummy;
    IF Item_Ser_rel_exists_csr%FOUND THEN
       FND_MESSAGE.set_name('AHL', 'AHL_OSP_RELATION_EXISTS');
       FND_MSG_PUB.ADD;
       IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED, L_DEBUG_KEY, FALSE);
       END IF;
       CLOSE Item_Ser_rel_exists_csr;
       RAISE Fnd_Api.g_exc_error;
    END IF;
    CLOSE  Item_Ser_rel_exists_csr;


 END IF; --  Operations flag = C



   IF p_x_Inv_serv_item_rec.operation_flag  <> 'D' THEN

    IF (p_x_Inv_serv_item_rec.rank IS NULL OR
       p_x_Inv_serv_item_rec.rank = FND_API.G_MISS_NUM) THEN
        FND_MESSAGE.set_name('AHL', 'AHL_OSP_RANK_NULL');
        FND_MSG_PUB.ADD;
        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED, L_DEBUG_KEY, FALSE);
        END IF;
     RAISE Fnd_Api.g_exc_error;
    ELSIF  ( p_x_Inv_serv_item_rec.rank < 1 OR
             FLOOR(p_x_Inv_serv_item_rec.rank) <> p_x_Inv_serv_item_rec.rank) THEN
        FND_MESSAGE.set_name('AHL', 'AHL_OSP_RANK_INVALID_NUM');
        FND_MSG_PUB.ADD;
        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED, L_DEBUG_KEY, FALSE);
        END IF;
     RAISE Fnd_Api.g_exc_error;
   END IF;


    IF (p_x_Inv_serv_item_rec.active_start_date IS NULL OR
       p_x_Inv_serv_item_rec.active_start_date = FND_API.G_MISS_DATE) THEN
        FND_MESSAGE.set_name('AHL', 'AHL_OSP_START_DATE_NULL');
        FND_MSG_PUB.ADD;
        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED, L_DEBUG_KEY, FALSE);
        END IF;
    ELSIF p_x_Inv_serv_item_rec.active_start_date > NVL(p_x_Inv_serv_item_rec.active_end_date,
                                                        p_x_Inv_serv_item_rec.active_start_date) THEN
        FND_MESSAGE.set_name('AHL', 'AHL_OSP_START_DATE_GT');
        FND_MSG_PUB.ADD;
        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED, L_DEBUG_KEY, FALSE);
        END IF;
    END IF;

     IF p_x_Inv_serv_item_rec.operation_flag = 'C' THEN

        OPEN Item_rank_exists_csr(p_x_Inv_serv_item_rec.inv_org_id,
                                     p_x_Inv_serv_item_rec.inv_item_id,
                                     p_x_Inv_serv_item_rec.rank,
                                     NULL);
     ELSE
        OPEN Item_rank_exists_csr(p_x_Inv_serv_item_rec.inv_org_id,
                                     p_x_Inv_serv_item_rec.inv_item_id,
                                     p_x_Inv_serv_item_rec.rank,
                                     p_x_Inv_serv_item_rec.inv_ser_item_rel_id);
     END IF;
        FETCH Item_rank_exists_csr INTO l_dummy;
        IF Item_rank_exists_csr%FOUND THEN
           FND_MESSAGE.set_name('AHL', 'AHL_OSP_RANK_DUP');
           FND_MSG_PUB.ADD;
           IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED, L_DEBUG_KEY, FALSE);
           END IF;
           CLOSE Item_rank_exists_csr;
           RAISE Fnd_Api.g_exc_error;
        END IF;
        CLOSE  Item_rank_exists_csr;


   END IF;--  Operations flag <> D


   IF p_x_Inv_serv_item_rec.operation_flag IN ('D','U') THEN

      IF p_x_Inv_serv_item_rec.inv_ser_item_rel_id IS NULL THEN
        FND_MESSAGE.set_name('AHL', 'AHL_OSP_REL_ID_NULL');
        FND_MSG_PUB.ADD;
        RAISE Fnd_Api.g_exc_error;
      END IF;

      OPEN Item_Ser_rel_det_csr(p_x_Inv_serv_item_rec.inv_ser_item_rel_id);
      FETCH Item_Ser_rel_det_csr INTO l_Item_Ser_rel_det;
      IF Item_Ser_rel_det_csr%NOTFOUND THEN
        FND_MESSAGE.set_name('AHL', 'AHL_OSP_REL_NOTFOUND');
        FND_MSG_PUB.ADD;
        CLOSE Item_Ser_rel_det_csr;
        RAISE Fnd_Api.g_exc_error;
      END IF;
      CLOSE Item_Ser_rel_det_csr;

      IF NVL(l_Item_Ser_rel_det.object_version_number,-9) <> p_x_Inv_serv_item_rec.obj_ver_num THEN
        FND_MESSAGE.set_name('AHL', 'AHL_COM_RECORD_MODIFIED');
        FND_MSG_PUB.ADD;
        RAISE Fnd_Api.g_exc_error;
      END IF;

   END IF;

    -- Check Error Message stack.
  x_msg_count := FND_MSG_PUB.count_msg;
  IF x_msg_count > 0 THEN
     RAISE  FND_API.G_EXC_ERROR;
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'p_x_Inv_serv_item_rec.operation_flag: ' || p_x_Inv_serv_item_rec.operation_flag  );
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'p_x_Inv_serv_item_rec.for_all_org_flag: ' || p_x_Inv_serv_item_rec.for_all_org_flag  );
  END IF;

  IF p_x_Inv_serv_item_rec.operation_flag = 'C' THEN
     IF p_x_Inv_serv_item_rec.for_all_org_flag = 'Y' THEN

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Inserting Relationships across Multiple Orgs');
        END IF;
         /* Commented by mpothuku on 25-jul-2005 to create the relationships in the Orgs where the relationship is
            not already defined. The relationship if already existing is left intact.
         */
         /*
          DELETE FROM AHL_INV_SERVICE_ITEM_RELS
          WHERE INV_ITEM_ID = p_x_Inv_serv_item_rec.inv_item_id
            AND SERVICE_ITEM_ID = p_x_Inv_serv_item_rec.service_item_id;
         */

        --Validation to check if there already exists a service item with the same Rank for the given inventory
        --item in any of the orgs in which the relationship is being created.
        l_count := 0;
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Before Validation for Org, Inventory, Rank Check');
        END IF;

        OPEN org_item_rank_exists_csr(p_x_Inv_serv_item_rec.inv_item_id, p_x_Inv_serv_item_rec.service_item_id, p_x_Inv_serv_item_rec.rank);
        LOOP
        FETCH org_item_rank_exists_csr INTO l_org_item_rank_exists_csr;
            EXIT WHEN org_item_rank_exists_csr%NOTFOUND;
            FND_MESSAGE.set_name('AHL', 'AHL_OSP_INV_RANK_EXISTS');
            FND_MESSAGE.set_token('INV_ORG_NAME', l_org_item_rank_exists_csr.inv_org_name);
            FND_MESSAGE.set_token('INV_ITEM_NUMBER', l_org_item_rank_exists_csr.inv_item_number);
            FND_MESSAGE.set_token('SVC_ITEM_NUMBER', l_org_item_rank_exists_csr.service_item_number);
            FND_MESSAGE.set_token('RANK', l_org_item_rank_exists_csr.rank);
            FND_MSG_PUB.ADD;
            l_count := l_count + 1;
        END LOOP;
        CLOSE org_item_rank_exists_csr;

        IF(l_count > 0) THEN
            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Validation for Org, Inventory, Rank Check failed');
            END IF;
            RAISE Fnd_Api.g_exc_error;
        END IF;

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Validation for Org, Inventory, Rank Check sucessful');
        END IF;


         INSERT INTO AHL_INV_SERVICE_ITEM_RELS
         (INV_SERVICE_ITEM_REL_ID,
        OBJECT_VERSION_NUMBER,
        LAST_UPDATE_DATE     ,
        LAST_UPDATED_BY      ,
        CREATION_DATE        ,
        CREATED_BY           ,
        LAST_UPDATE_LOGIN    ,
        INV_ITEM_ID          ,
        INV_ORG_ID           ,
        SERVICE_ITEM_ID      ,
        RANK                 ,
        ACTIVE_START_DATE    ,
        ACTIVE_END_DATE      ,
        SECURITY_GROUP_ID    ,
        ATTRIBUTE_CATEGORY   ,
        ATTRIBUTE1           ,
        ATTRIBUTE2           ,
        ATTRIBUTE3           ,
        ATTRIBUTE4           ,
        ATTRIBUTE5           ,
        ATTRIBUTE6           ,
        ATTRIBUTE7           ,
        ATTRIBUTE8           ,
        ATTRIBUTE9           ,
        ATTRIBUTE10          ,
        ATTRIBUTE11          ,
        ATTRIBUTE12          ,
        ATTRIBUTE13          ,
        ATTRIBUTE14          ,
        ATTRIBUTE15          )
           SELECT  AHL_INV_SERVICE_ITEM_RELS_S.NEXTVAL,
            1,
            sysdate,
            Fnd_Global.USER_ID,
            sysdate,
            Fnd_Global.USER_ID,
            Fnd_Global.LOGIN_ID,
            Inv.INVENTORY_ITEM_ID,
            Inv.ORGANIZATION_ID,
            Serv.INVENTORY_ITEM_ID,
            p_x_Inv_serv_item_rec.rank,
            p_x_Inv_serv_item_rec.active_start_date,
            p_x_Inv_serv_item_rec.active_end_date,
            NULL    ,
            NULL   ,
            NULL           ,
            NULL           ,
            NULL           ,
            NULL           ,
            NULL           ,
            NULL           ,
            NULL           ,
            NULL           ,
            NULL           ,
            NULL          ,
            NULL          ,
            NULL          ,
            NULL          ,
            NULL          ,
            NULL
           FROM mtl_system_items_kfv Inv,
            mtl_system_items_kfv Serv,
            --Modified by mpothuku on 17-Jan-05 to fix the performance Bug 4919315
            inv_organization_info_v org
           WHERE Inv.ORGANIZATION_ID = Serv.ORGANIZATION_ID
           AND   org.organization_id = Inv.ORGANIZATION_ID
           AND   Inv.inventory_item_flag = 'Y'
           AND   Serv.inventory_item_flag = 'N'
           AND   Inv.inventory_item_id = p_x_Inv_serv_item_rec.inv_item_id
           AND   Serv.inventory_item_id = p_x_Inv_serv_item_rec.service_item_id
           -- mpothuku start
           AND   org.organization_id not in
           (select INV_ORG_ID from  AHL_INV_SERVICE_ITEM_RELS
           where inv_item_id = p_x_Inv_serv_item_rec.inv_item_id
           AND   service_item_id = p_x_Inv_serv_item_rec.service_item_id)
           -- mpothuku end
           AND NVL(org.operating_unit, mo_global.get_current_org_id()) =
               mo_global.get_current_org_id();

        ELSE

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Inserting Relationship in Single Org');
        END IF;

         INSERT INTO AHL_INV_SERVICE_ITEM_RELS
         (INV_SERVICE_ITEM_REL_ID,
        OBJECT_VERSION_NUMBER,
        LAST_UPDATE_DATE     ,
        LAST_UPDATED_BY      ,
        CREATION_DATE        ,
        CREATED_BY           ,
        LAST_UPDATE_LOGIN    ,
        INV_ITEM_ID          ,
        INV_ORG_ID           ,
        SERVICE_ITEM_ID      ,
        RANK                 ,
        ACTIVE_START_DATE    ,
        ACTIVE_END_DATE      ,
        SECURITY_GROUP_ID    ,
        ATTRIBUTE_CATEGORY   ,
        ATTRIBUTE1           ,
        ATTRIBUTE2           ,
        ATTRIBUTE3           ,
        ATTRIBUTE4           ,
        ATTRIBUTE5           ,
        ATTRIBUTE6           ,
        ATTRIBUTE7           ,
        ATTRIBUTE8           ,
        ATTRIBUTE9           ,
        ATTRIBUTE10          ,
        ATTRIBUTE11          ,
        ATTRIBUTE12          ,
        ATTRIBUTE13          ,
        ATTRIBUTE14          ,
        ATTRIBUTE15          )
        VALUES
        (AHL_INV_SERVICE_ITEM_RELS_S.NEXTVAL,
         1,
         sysdate,
         Fnd_Global.USER_ID,
         sysdate,
         Fnd_Global.USER_ID,
         Fnd_Global.LOGIN_ID,
         p_x_Inv_serv_item_rec.inv_item_id,
         p_x_Inv_serv_item_rec.inv_org_id,
         p_x_Inv_serv_item_rec.service_item_id,
         p_x_Inv_serv_item_rec.rank,
         p_x_Inv_serv_item_rec.active_start_date,
         p_x_Inv_serv_item_rec.active_end_date,
        NULL    ,
        NULL   ,
        NULL           ,
        NULL           ,
        NULL           ,
        NULL           ,
        NULL           ,
        NULL           ,
        NULL           ,
        NULL           ,
        NULL           ,
        NULL          ,
        NULL          ,
        NULL          ,
        NULL          ,
        NULL          ,
        NULL          ) RETURN INV_SERVICE_ITEM_REL_ID INTO p_x_Inv_serv_item_rec.inv_ser_item_rel_id;

       END IF; -- for all org

    ELSIF p_x_Inv_serv_item_rec.operation_flag = 'U' THEN

          --Validate that end_date is not in past during updation of the record
          --Added by mpothuku on 25-Aug-05 to fix the bug #4552227
          IF TRUNC(p_x_Inv_serv_item_rec.active_end_date) < TRUNC(SYSDATE) THEN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
              fnd_log.string(fnd_log.level_statement, L_DEBUG_KEY, 'End Date is in Past');
            END IF;
            FND_MESSAGE.set_name('AHL', 'AHL_VENDOR_CER_END_DATE_PAST');
            FND_MSG_PUB.ADD;
            RAISE Fnd_Api.g_exc_error;
          END IF;
          -- mpothuku End

          UPDATE ahl_inv_service_item_rels
             SET active_start_date = p_x_inv_serv_item_rec.active_start_date,
                 active_end_date = p_x_inv_serv_item_rec.active_end_date,
                 rank = p_x_inv_serv_item_rec.rank,
                 object_version_number = object_version_number +1
           WHERE inv_service_item_rel_id = p_x_Inv_serv_item_rec.inv_ser_item_rel_id
             AND object_version_number = l_Item_Ser_rel_det.object_version_number;

       IF SQL%ROWCOUNT = 0 THEN
        FND_MESSAGE.set_name('AHL', 'AHL_COM_RECORD_MODIFIED');
        FND_MSG_PUB.ADD;
        RAISE Fnd_Api.g_exc_error;
       END IF;


    ELSIF p_x_Inv_serv_item_rec.operation_flag = 'D' THEN

         DELETE FROM ahl_inv_service_item_rels
         WHERE inv_service_item_rel_id = p_x_Inv_serv_item_rec.inv_ser_item_rel_id
             AND object_version_number = l_Item_Ser_rel_det.object_version_number;

           IF SQL%ROWCOUNT = 0 THEN
        FND_MESSAGE.set_name('AHL', 'AHL_COM_RECORD_MODIFIED');
        FND_MSG_PUB.ADD;
        RAISE Fnd_Api.g_exc_error;
       END IF;

         DELETE FROM ahl_item_vendor_rels
         WHERE inv_service_item_rel_id = p_x_Inv_serv_item_rec.inv_ser_item_rel_id;


    END IF; -- operation flag C


  -- Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'About to commit work');
    END IF;
    COMMIT WORK;
  END IF;


  -- Standard call to get message count and if count is 1, get message
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false);
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   Rollback to process_serv_items_pvt;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Rollback to process_serv_items_pvt;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Rollback to process_serv_items_pvt;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => l_api_name,
                               p_error_text     => SQLERRM);

    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                                p_encoded => fnd_api.g_false);

 END PROCESS_SERV_ITM_RELS;




End AHL_OSP_SERV_ITEM_RELS_PVT;

/
