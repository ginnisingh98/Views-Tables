--------------------------------------------------------
--  DDL for Package Body AHL_RSV_RESERVATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_RSV_RESERVATIONS_PVT" AS
/* $Header: AHLVRSVB.pls 120.16.12010000.2 2008/11/13 14:28:46 skpathak ship $ */
------------------------------------
-- Common constants and variables --
------------------------------------
l_log_current_level     NUMBER      := fnd_log.g_current_runtime_level;
l_log_statement         NUMBER      := fnd_log.level_statement;
l_log_procedure         NUMBER      := fnd_log.level_procedure;
l_log_error             NUMBER      := fnd_log.level_error;
l_log_unexpected        NUMBER      := fnd_log.level_unexpected;

-- Helper procedure added by skpathak on 12-NOV-2008 for bug 7241925
-- Gets the reservation (if any) that matches the scheduled_material_id+serial_number
-- If p_match_serial is 'Y', also checks if the serial is already included in the reservation
PROCEDURE GET_MATCHING_RESERVATION(p_scheduled_material_id IN NUMBER,
                                   p_serial_number         IN VARCHAR2,
                                   p_match_serial          IN VARCHAR2 DEFAULT 'N',
                                   x_reservation_id        OUT NOCOPY NUMBER,
                                   x_reservation_quantity  OUT NOCOPY NUMBER);


PROCEDURE INITIALIZE_CREATE_REC(
      p_schedule_material_id           IN             NUMBER,
      p_serial_number                  IN             VARCHAR2,
      x_rsv_rec                        OUT   NOCOPY   inv_reservation_global.mtl_reservation_rec_type,
      x_return_status         OUT      NOCOPY   VARCHAR2
      );

   ------------------------------------------------------------------------------------------------------------------
-- Start of Comments --
--  Procedure name      : CREATE_RESERVATION
--  Type                : Private
--  Function            : Reserves the serial numbers in the p_serial_number_tbl
--  Pre-reqs            :
--  Standard IN  Parameters :
--      p_api_version      IN       NUMBER         Required
--      p_init_msg_list    IN       VARCHAR2       Default FND_API.G_FALSE
--      p_commit           IN       VARCHAR2       Default FND_API.G_FALSE
--      p_validation_level IN       NUMBER         Default FND_API.G_VALID_LEVEL_FULL
--      p_module_type      IN       VARCHAR2       Default NULL
--  Standard OUT Parameters :
--      x_return_status    OUT      VARCHAR2       Required
--      x_msg_count        OUT      NUMBER         Required
--      x_msg_data         OUT      VARCHAR2       Required

--
--  CREATE_RESERVATION Parameters:
--       p_scheduled_material_id : The Schedule Material Id
--       p_serial_number_tbl     : The table of Serial Numbers to be reserved
--  End of Comments.
   ------------------------------------------------------------------------------------------------------------------
PROCEDURE CREATE_RESERVATION(
      p_api_version           IN                NUMBER,
      p_init_msg_list         IN                VARCHAR2,
      p_commit                IN                VARCHAR2,
      p_validation_level      IN                NUMBER,
      p_module_type           IN                VARCHAR2,
      x_return_status         OUT      NOCOPY   VARCHAR2,
      x_msg_count             OUT      NOCOPY   NUMBER,
      x_msg_data              OUT      NOCOPY   VARCHAR2,
      p_scheduled_material_id IN                NUMBER,
      p_serial_number_tbl     IN                serial_number_tbl_type
)
IS
   -- Declare local variables
   l_api_name      CONSTANT      VARCHAR2(30)      := 'create_reservation';
   l_api_version   CONSTANT      NUMBER            := 1.0;
   l_init_msg_list               VARCHAR2(1)       := 'F';
   l_return_status               VARCHAR2(1);
   l_msg_count                   NUMBER;
   l_msg_data                    VARCHAR2(2000);
   l_debug_module  CONSTANT      VARCHAR2(100)     := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

   l_sn_number NUMBER := 0;   -- Number of serial numbers to be reserved


   CURSOR get_mtl_req_dtls_csr (c_scheduled_material_id IN NUMBER) IS
      SELECT   asmt.organization_id, asmt.requested_date, asmt.uom,
               nvl(asmt.requested_quantity,0) requested_quantity, asmt.inventory_item_id,
               asmt.object_version_number, nvl(asmt.reserved_quantity,0) reserved_quantity,
               nvl(asmt.completed_quantity,0) completed_quantity
      FROM     ahl_material_requirements_v asmt
      WHERE    asmt.schedule_material_id = c_scheduled_material_id;

   l_mtl_req_dtls_rec   get_mtl_req_dtls_csr%ROWTYPE;

   l_create_rsv_rec     inv_reservation_global.mtl_reservation_rec_type;
   l_serial_number_tbl  inv_reservation_global.serial_number_tbl_type;

   -- To fetch the instance details when you have the inventory item id, serial number and the organization id
   -- inventory item id is from the Ahl Schedule Materials table
   -- organization id from the Ahl Schedule Materials table
   CURSOR get_instance_dtls_csr (c_inventory_itme_id  IN NUMBER,
                                 c_serial_number      IN VARCHAR2,
                                 c_organization_id    IN NUMBER)
   IS
      SELECT   csi.instance_id,
               msn.serial_number,
               csi.inv_subinventory_name subinventory_code
      FROM     csi_item_instances csi,
               mtl_serial_numbers msn
      WHERE    trunc(sysdate) >= trunc(nvl(CSI.active_start_date,sysdate))
      AND      trunc(sysdate) < trunc(nvl(CSI.active_end_date,sysdate+1))
      AND      msn.current_status = 3 -- inventory
      AND      msn.reservation_id is null
      AND      (msn.group_mark_id is null or msn.group_mark_id = -1)
      AND      csi.inventory_item_id = c_inventory_itme_id
      AND      csi.serial_number = c_serial_number
      AND      csi.last_vld_organization_id = c_organization_id
      AND      csi.inventory_item_id = msn.inventory_item_id
      AND      csi.serial_number = msn.serial_number;

   l_instance_details_rec  get_instance_dtls_csr%ROWTYPE;

-- Cursor get_reservation_csr removed by skpathak on 12-NOV-2008 for bug 7241925
-- in favor of call to the new helper procedure GET_MATCHING_RESERVATION
/**
   CURSOR get_reservation_csr (c_scheduled_material_id IN NUMBER, c_subinventory_code IN VARCHAR2)
   IS
      SELECT   mrsv.reservation_id, mrsv.primary_reservation_quantity
      FROM     mtl_reservations mrsv,ahl_schedule_materials asmt
      WHERE    mrsv.demand_source_line_detail = c_scheduled_material_id
      AND      external_source_code = 'AHL'
      AND      subinventory_code = c_subinventory_code
      AND      mrsv.demand_source_line_detail = asmt.scheduled_material_id
      AND      mrsv.organization_id = asmt.organization_id
      AND      mrsv.requirement_date = asmt.requested_date
      AND      mrsv.inventory_item_id = asmt.inventory_item_id;
**/

   l_reservation_id     NUMBER;
   l_reserved_quantity  NUMBER;


   l_x_serial_number_tbl   inv_reservation_global.serial_number_tbl_type;
   l_x_quantity_reserved   NUMBER;
   l_x_reservation_id      NUMBER;

   -- for updating the reservations
   l_from_rsv_rec             inv_reservation_global.mtl_reservation_rec_type;
   l_to_rsv_rec               inv_reservation_global.mtl_reservation_rec_type;
   l_to_serial_number_tbl     inv_reservation_global.serial_number_tbl_type;

BEGIN
   -- Standard start of API savepoint
   SAVEPOINT CREATE_RESERVATION_PVT;
   -- Initialize return status to success before any code logic/validation
   x_return_status:= FND_API.G_RET_STS_SUCCESS;


   -- Standard call to check for call compatibility
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version, p_api_version, l_api_name, G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   -- Initialize message list if p_init_msg_list = FND_API.G_TRUE
   IF FND_API.TO_BOOLEAN(p_init_msg_list)
   THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;

   -- Log API entry point
   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string
      (
         fnd_log.level_procedure,
         'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
         'At the start of PL SQL procedure '
      );
   END IF;


   -- Validate to make sure that the Serial Number table is not empty
   l_sn_number := p_serial_number_tbl.COUNT;
   IF l_sn_number = 0 THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_RSV_SNQTY_GTR_ZRO' );
      FND_MSG_PUB.add;
      -- log the error
      IF (l_log_error >= l_log_current_level) THEN
         fnd_log.string
         (
            fnd_log.level_error,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
            'Number of Serial Numbers to be reserved equal to ZERO'
         );
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF; -- l_sn_number = 0

   -- Get the Material Requirements details
   OPEN get_mtl_req_dtls_csr(p_scheduled_material_id);
   FETCH get_mtl_req_dtls_csr INTO l_mtl_req_dtls_rec;
   IF get_mtl_req_dtls_csr%NOTFOUND THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_RSV_INVLD_MAT_REQ' );
      FND_MSG_PUB.add;
      -- log the error
      IF (l_log_error >= l_log_current_level) THEN
         fnd_log.string
         (
            fnd_log.level_error,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
            'get_mtl_req_dtls_csr, did not fetch any records'
         );
      END IF;
      CLOSE get_mtl_req_dtls_csr;
      RAISE FND_API.G_EXC_ERROR;
   END IF; -- Material Requirement details not found
   CLOSE get_mtl_req_dtls_csr;


   -- Validate whether the sum of serial numbers to reserve + already issued + reserved quantities
   -- is not more than the initially requested quantity
   IF l_sn_number + l_mtl_req_dtls_rec.completed_quantity +
      l_mtl_req_dtls_rec.reserved_quantity > l_mtl_req_dtls_rec.requested_quantity  THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_RSV_QTY_EXCDS_REQSTD' );
      FND_MSG_PUB.add;
      -- log the error
      IF (l_log_error >= l_log_current_level) THEN
         fnd_log.string
         (
            fnd_log.level_error,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
            'Number of serial numbers + Completed Qty + Reserved Qty is more than Requested Qty  '
         );
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF; -- sum of number of serial nos to be reserved ,completed qty  and reserved qty is more than requested qty

   -- For all the serial numbers that need to be reserved
   FOR i IN p_serial_number_tbl.FIRST..p_serial_number_tbl.LAST
   LOOP
      -- Initialize the record to be send to the WMS package
      Initialize_create_rec(  p_scheduled_material_id, -- the schedule material id
                              p_serial_number_tbl(i).serial_number, -- the serial number
                              l_create_rsv_rec, -- record to be passed ti the WMS packages
                              l_return_status);  -- return status
      -- get the instance id,serial number and the subinventory code
      OPEN get_instance_dtls_csr( l_mtl_req_dtls_rec.inventory_item_id,
                                  p_serial_number_tbl(i).serial_number,
                                  l_mtl_req_dtls_rec.organization_id);
      FETCH get_instance_dtls_csr INTO l_instance_details_rec;
      IF get_instance_dtls_csr%NOTFOUND THEN
         FND_MESSAGE.set_name( 'AHL', 'AHL_RSV_INVLD_SL_NUM' );
         FND_MESSAGE.Set_Token('SERIALNUMBER',p_serial_number_tbl(i).serial_number);
         FND_MSG_PUB.add;
         -- log the error
         IF (l_log_error >= l_log_current_level) THEN
            fnd_log.string
            (
               fnd_log.level_error,
               'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
               'get_instance_dtls_csr, did not fetch any records'
            );
         END IF;
         CLOSE get_instance_dtls_csr;
         RAISE FND_API.G_EXC_ERROR;
      END IF;  -- get_instance_dtls_csr%NOTFOUND
      CLOSE get_instance_dtls_csr;

     l_reservation_id     := null;
     l_reserved_quantity  := null;

      -- Get the reservation id and the quantity already reserved
      -- Changed by skpathak on 12-NOV-2008 for bug 7241925
      -- Can update a reservation to add one more serial only if all of these match:
      -- Org, Item, Subinventory, Locator, Revision, Lot and LPN
      /**
      OPEN get_reservation_csr(p_scheduled_material_id,l_instance_details_rec.subinventory_code) ;
      FETCH get_reservation_csr INTO l_reservation_id,l_x_quantity_reserved;
      CLOSE get_reservation_csr;
      **/
      GET_MATCHING_RESERVATION(p_scheduled_material_id => p_scheduled_material_id,
                               p_serial_number         => p_serial_number_tbl(i).serial_number,
                               p_match_serial          => 'N',
                               x_reservation_id        => l_reservation_id,
                               x_reservation_quantity  => l_x_quantity_reserved);

      IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string(fnd_log.level_statement, l_debug_module,
                         'GET_MATCHING_RESERVATION returned l_reservation_id = ' || l_reservation_id ||
                         ', l_x_quantity_reserved = ' || l_x_quantity_reserved);
      END IF;
      -- End Changes by skpathak on 12-NOV-2008 for bug 7241925

      -- Call WMS API to create reservation if none has been created for this material requirement
      -- in a particular subinventory, otherwise
      -- update the current reservation by adding more serial number.

      IF l_reservation_id  IS NULL THEN
         -- populate p_rsv_rec
         l_create_rsv_rec.primary_reservation_quantity := 1;
         l_create_rsv_rec.subinventory_code := l_instance_details_rec.subinventory_code;
         l_serial_number_tbl(1).serial_number := p_serial_number_tbl(i).serial_number;
         -- Added by jaramana on June 29, 2005
         l_serial_number_tbl(1).inventory_item_id := l_mtl_req_dtls_rec.inventory_item_id;

         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string
            (
               fnd_log.level_statement,
               'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
               'Calling WMS api:inv_reservation_pub.create_reservation'
            );
         END IF;

         inv_reservation_pub.create_reservation
            (
               p_api_version_number    => l_api_version,
               p_init_msg_lst       => l_init_msg_list,
               x_return_status      => l_return_status,
               x_msg_count          => l_msg_count,
               x_msg_data           => l_msg_data,
               p_rsv_rec            => l_create_rsv_rec,
               p_serial_number      => l_serial_number_tbl,
               x_serial_number      => l_x_serial_number_tbl,
               x_quantity_reserved  => l_x_quantity_reserved,
               x_reservation_id     => l_x_reservation_id
            );
      ELSE -- l_reservation_id  IS NOT NULL
         -- populate p_original_rsv_rec
         l_from_rsv_rec.reservation_id := l_reservation_id;
         -- populate p_rsv_rec
         l_to_rsv_rec.reservation_id   := l_reservation_id;
         l_to_rsv_rec.primary_reservation_quantity := l_x_quantity_reserved +1;
         l_to_serial_number_tbl(1).serial_number := p_serial_number_tbl(i).serial_number;
         l_to_serial_number_tbl(1).inventory_item_id := l_mtl_req_dtls_rec.inventory_item_id;

         -- initialize the table
         l_serial_number_tbl.DELETE;

         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string
            (
               fnd_log.level_statement,
               'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
               'Calling WMS api:inv_reservation_pub.update_reservation'
            );
         END IF;
         inv_reservation_pub.update_reservation
            (
               p_api_version_number       => l_api_version,
               p_init_msg_lst             => l_init_msg_list,
               x_return_status            => l_return_status,
               x_msg_count                => l_msg_count,
               x_msg_data                 => l_msg_data,
               p_original_rsv_rec         => l_from_rsv_rec,
               p_to_rsv_rec               => l_to_rsv_rec,
               p_original_serial_number   => l_serial_number_tbl,
               p_to_serial_number         => l_to_serial_number_tbl
             );
      END IF; -- IF l_reservation_id  IS NULL

      -- Check the error status
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
         -- log the error
         IF (l_log_error >= l_log_current_level) THEN
            fnd_log.string
            (
               fnd_log.level_error,
               'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
               'Call to WMS returned Unexpected Error'
            );
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
         -- log the error
         IF (l_log_error >= l_log_current_level) THEN
            fnd_log.string
            (
               fnd_log.level_error,
               'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
               'Call to WMS returned Expected Error'
            );
         END IF;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END LOOP; -- FOR i IN p_serial_number_tbl.FIRST..p_serial_number_tbl.LAST

   -- Check Error Message stack.
   x_msg_count := FND_MSG_PUB.count_msg;
   IF x_msg_count > 0
   THEN
      -- log the error
      IF (l_log_error >= l_log_current_level) THEN
         fnd_log.string
         (
            fnd_log.level_error,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
            'Call to WMS returned Errors in x_msg_count'
         );
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Commit if p_commit = FND_API.G_TRUE
   IF FND_API.TO_BOOLEAN(p_commit)
   THEN
      COMMIT WORK;
      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string
         (
            fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
            'Committed'
         );
      END IF;
   END IF;

   -- Standard call to get message count and if count is 1, get message info
   FND_MSG_PUB.count_and_get
   (
      p_count  => x_msg_count,
      p_data   => x_msg_data,
      p_encoded   => FND_API.G_FALSE
   );

   -- Log API exit point
   IF (l_log_procedure >= l_log_current_level)THEN
      fnd_log.string
         (
            fnd_log.level_procedure,
            l_debug_module||'.end',
            'At the end of PLSQL procedure'
         );
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO CREATE_RESERVATION_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get
      (
         p_count  => x_msg_count,
         p_data   => x_msg_data,
         p_encoded   => FND_API.G_FALSE
      );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CREATE_RESERVATION_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get
      (
         p_count  => x_msg_count,
         p_data   => x_msg_data,
         p_encoded   => FND_API.G_FALSE
      );

   WHEN OTHERS THEN
      ROLLBACK TO CREATE_RESERVATION_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.add_exc_msg
         (
            p_pkg_name     => G_PKG_NAME,
            p_procedure_name  => 'create_reservation',
            p_error_text      => SUBSTR(SQLERRM,1,240)
         );
      END IF;
      FND_MSG_PUB.count_and_get
      (
         p_count  => x_msg_count,
         p_data   => x_msg_data,
         p_encoded   => FND_API.G_FALSE
      );
END CREATE_RESERVATION;

------------------------------------------------------------------------------------------------------------------
-- Declare Procedure --
------------------------------------------------------------------------------------------------------------------
   -- Start of Comments --
   --  Procedure name      : UPDATE_RESERVATION
   --  Type                : Private
   --  Function            : Updates reservation for serial numbers in the p_serial_number_tbl
   --  Pre-reqs            :
   --  Standard IN  Parameters :
   --      p_api_version      IN       NUMBER         Required
   --      p_init_msg_list    IN       VARCHAR2       Default FND_API.G_FALSE
   --      p_commit           IN       VARCHAR2       Default FND_API.G_FALSE
   --      p_validation_level IN       NUMBER         Default FND_API.G_VALID_LEVEL_FULL
   --      p_module_type      IN       VARCHAR2       Default NULL
   --  Standard OUT Parameters :
   --      x_return_status    OUT      VARCHAR2       Required
   --      x_msg_count        OUT      NUMBER         Required
   --      x_msg_data         OUT      VARCHAR2       Required

   --
   --  CREATE_RESERVATION Parameters:
   --       p_scheduled_material_id : The Schedule Material Id
   --       p_serial_number_tbl     : The table of Serial Numbers to be reserved
   --  End of Comments.
------------------------------------------------------------------------------------------------------------------
PROCEDURE UPDATE_RESERVATION(
      p_api_version           IN                NUMBER,
      p_init_msg_list         IN                VARCHAR2,
      p_commit                IN                VARCHAR2,
      p_validation_level      IN                NUMBER,
      p_module_type           IN                VARCHAR2,
      x_return_status         OUT      NOCOPY   VARCHAR2,
      x_msg_count             OUT      NOCOPY   NUMBER,
      x_msg_data              OUT      NOCOPY   VARCHAR2,
      p_scheduled_material_id IN                NUMBER  ,
      p_requested_date        IN                DATE)
IS
   -- Declare local variables
   l_api_name           CONSTANT    VARCHAR2(30)    := 'update_reservation';
   l_debug_module       CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

   l_api_version   CONSTANT      NUMBER         := 1.0;
   l_init_msg_list               VARCHAR2(1)    := 'F';
   l_return_status               VARCHAR2(1);
   l_msg_count                   NUMBER;
   l_msg_data                    VARCHAR2(2000);


   l_requested_date        DATE;
   l_reservation_id        NUMBER;
   l_x_quantity_reserved   NUMBER := NULL;
   l_from_rsv_rec             inv_reservation_global.mtl_reservation_rec_type;
   l_to_rsv_rec               inv_reservation_global.mtl_reservation_rec_type;
   l_x_serial_number_tbl      inv_reservation_global.serial_number_tbl_type;
   l_to_serial_number_tbl     inv_reservation_global.serial_number_tbl_type;
   l_from_serial_number_tbl     inv_reservation_global.serial_number_tbl_type;

   -- Variables to check the log level according to the coding standards
   l_dbg_level          NUMBER      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   l_proc_level         NUMBER      := FND_LOG.LEVEL_PROCEDURE;


   -- Declare cursors
   CURSOR get_mtl_req_dtls_csr (c_scheduled_material_id IN NUMBER)
   IS
      SELECT   asmt.requested_date
      FROM     ahl_schedule_materials asmt
      WHERE    asmt.scheduled_material_id = c_scheduled_material_id;

   CURSOR get_reservation_csr (c_scheduled_material_id IN NUMBER)
   IS
      SELECT   reservation_id
      FROM     mtl_reservations mrsv,ahl_schedule_materials asmt
      WHERE    mrsv.demand_source_line_detail = c_scheduled_material_id
      AND      mrsv.demand_source_line_detail = asmt.scheduled_material_id
      AND      mrsv.organization_id = asmt.organization_id
      AND      mrsv.requirement_date = asmt.requested_date
      AND      mrsv.inventory_item_id = asmt.inventory_item_id
      AND      mrsv.external_source_code = 'AHL';

BEGIN
   -- Standard start of API savepoint
   SAVEPOINT UPDATE_RESERVATION_PVT;

   -- Initialize return status to success before any code logic/validation
   x_return_status:= FND_API.G_RET_STS_SUCCESS;

   -- Standard call to check for call compatibility
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version, p_api_version, l_api_name, G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list = FND_API.G_TRUE
   IF FND_API.TO_BOOLEAN(p_init_msg_list)
   THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;

   -- Log API entry point
   IF (l_log_procedure >= l_log_current_level)THEN
      fnd_log.string
      (
         fnd_log.level_procedure,
         'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
         'At the start of PL SQL procedure '
      );
   END IF;


   -- Validate the schedule material id
   IF p_scheduled_material_id IS NULL THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_RSV_INVLD_MAT_REQ' );
      FND_MSG_PUB.add;
      -- log the error
      IF (l_log_error >= l_log_current_level) THEN
         fnd_log.string
         (
            fnd_log.level_error,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
            'schedule material id is null'
         );
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF; -- IF p_scheduled_material_id IS NULL

   -- Validate the schedule material id
   OPEN  get_mtl_req_dtls_csr(p_scheduled_material_id);
   FETCH get_mtl_req_dtls_csr INTO l_requested_date;
   IF get_mtl_req_dtls_csr%NOTFOUND THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_RSV_INVLD_MAT_REQ' );
      FND_MSG_PUB.add;
      -- log the error
      IF (l_log_error >= l_log_current_level) THEN
         fnd_log.string
         (
            fnd_log.level_error,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
            'Invalid Material Requirement ID'
         );
      END IF;
      CLOSE get_mtl_req_dtls_csr;
      RAISE FND_API.G_EXC_ERROR;
   END IF; -- IF get_mtl_req_dtls_csr%NOTFOUND
   CLOSE get_mtl_req_dtls_csr;

   -- if the requested date is null, throw error
   IF p_requested_date IS NULL THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_RSV_INVLD_REQ_DATE' );
      FND_MSG_PUB.add;
      -- log the error
      IF (l_log_error >= l_log_current_level) THEN
         fnd_log.string
         (
            fnd_log.level_error,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
            'Requested Date is null'
         );
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF; --IF p_requested_date IS NULL

   -- if the dates are the same, no need to do anything
   IF p_requested_date = l_requested_date THEN
      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string
         (
            fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
            'No change in dates, returning to caller'
         );
      END IF;
      RETURN;
   END IF; --IF p_requested_date = l_requested_date

   -- get all the reservations for this scheduled material id
   OPEN get_reservation_csr(p_scheduled_material_id);
   LOOP
      FETCH get_reservation_csr INTO l_reservation_id;
      EXIT WHEN get_reservation_csr%NOTFOUND;

      l_from_rsv_rec.reservation_id := l_reservation_id;
      l_to_rsv_rec.reservation_id := l_reservation_id;
      l_to_rsv_rec.requirement_date:= p_requested_date;

      /*
         l_to_serial_number_tbl(1).serial_number := p_serial_number_tbl(i).serial_number;
         l_to_serial_number_tbl(1).inventory_item_id := l_mtl_req_dtls_rec.inventory_item;
      */
         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string
            (
               fnd_log.level_statement,
               'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
               'Calling WMS api:inv_reservation_pub.update_reservation'
            );
         END IF;
      -- Call WMS Update reservation API
      inv_reservation_pub.update_reservation
         (
            p_api_version_number       => l_api_version,
            p_init_msg_lst             => l_init_msg_list,
            x_return_status            => l_return_status,
            x_msg_count                => l_msg_count,
            x_msg_data                 => l_msg_data,
            p_original_rsv_rec         => l_from_rsv_rec,
            p_to_rsv_rec               => l_to_rsv_rec,
            p_original_serial_number   => l_from_serial_number_tbl,
            p_to_serial_number         => l_to_serial_number_tbl
         );

      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
         -- log the error
         IF (l_log_error >= l_log_current_level) THEN
            fnd_log.string
            (
               fnd_log.level_error,
               'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
               'Call to WMS returned Unexpected Error'
            );
         END IF;
         CLOSE get_reservation_csr;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
         -- log the error
         IF (l_log_error >= l_log_current_level) THEN
            fnd_log.string
            (
               fnd_log.level_error,
               'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
               'Call to WMS returned Expected Error'
            );
         END IF;
         CLOSE get_reservation_csr;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END LOOP; -- All the reservations for this material requiement id

   -- Check Error Message stack.
   x_msg_count := FND_MSG_PUB.count_msg;
   IF x_msg_count > 0
   THEN
      -- log the error
      IF (l_log_error >= l_log_current_level) THEN
         fnd_log.string
         (
            fnd_log.level_error,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
            'Call to WMS returned Errors in x_msg_count'
         );
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Commit if p_commit = FND_API.G_TRUE
   IF FND_API.TO_BOOLEAN(p_commit)
   THEN
      COMMIT WORK;
      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string
         (
            fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
            'Committed'
         );
      END IF;
   END IF;

   -- Standard call to get message count and if count is 1, get message info
   FND_MSG_PUB.count_and_get
   (
      p_count  => x_msg_count,
      p_data   => x_msg_data,
      p_encoded   => FND_API.G_FALSE
   );

   -- Log API exit point
   IF (l_log_procedure >= l_log_current_level)THEN
      fnd_log.string
         (
            fnd_log.level_procedure,
            l_debug_module||'.end',
            'At the end of PLSQL procedure'
         );
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO UPDATE_RESERVATION_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get
      (
         p_count  => x_msg_count,
         p_data   => x_msg_data,
         p_encoded   => FND_API.G_FALSE
      );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO UPDATE_RESERVATION_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get
      (
         p_count  => x_msg_count,
         p_data   => x_msg_data,
         p_encoded   => FND_API.G_FALSE
      );

   WHEN OTHERS THEN
      ROLLBACK TO UPDATE_RESERVATION_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.add_exc_msg
         (
            p_pkg_name     => G_PKG_NAME,
            p_procedure_name  => 'update_reservation',
            p_error_text      => SUBSTR(SQLERRM,1,240)
         );
      END IF;
      FND_MSG_PUB.count_and_get
      (
         p_count  => x_msg_count,
         p_data   => x_msg_data,
         p_encoded   => FND_API.G_FALSE
      );
END UPDATE_RESERVATION;

---------------------------------------------------------------------------------------------------------------------
-- Declare Procedures --
---------------------------------------------------------------------------------------------------------------------
   -- Start of Comments --
   --  Procedure name      : DELETE_RESERVATION
   --  Type                : Private
   --  Function            : API to delete all the reservation made for a requirement
   --  Pre-reqs            :
   --  Standard IN  Parameters :
   --      p_api_version      IN       NUMBER         Required
   --      p_init_msg_list    IN       VARCHAR2       Default FND_API.G_FALSE
   --      p_commit           IN       VARCHAR2       Default FND_API.G_FALSE
   --      p_validation_level IN       NUMBER         Default FND_API.G_VALID_LEVEL_FULL
   --      p_module_type      IN       VARCHAR2       Default NULL
   --  Standard OUT Parameters :
   --      x_return_status    OUT      VARCHAR2       Required
   --      x_msg_count        OUT      NUMBER         Required
   --      x_msg_data         OUT      VARCHAR2       Required

   --
   --  DELETE_RESERVATION Parameters:
   --       p_scheduled_material_id : The Schedule Material Id
   --       p_sub_inventory_code    : If not null then only reservations from this subinventory will be deleted, if null all                                  the reservations will be deleted.
   --  End of Comments.
---------------------------------------------------------------------------------------------------------------------
PROCEDURE DELETE_RESERVATION(
      p_api_version           IN                NUMBER      := 1.0,
      p_init_msg_list         IN                VARCHAR2    := FND_API.G_FALSE,
      p_commit                IN                VARCHAR2    := FND_API.G_FALSE,
      p_validation_level      IN                NUMBER      := FND_API.G_VALID_LEVEL_FULL,
      p_module_type           IN                VARCHAR2,
      x_return_status         OUT      NOCOPY   VARCHAR2,
      x_msg_count             OUT      NOCOPY   NUMBER,
      x_msg_data              OUT      NOCOPY   VARCHAR2,
      p_scheduled_material_id IN                NUMBER  ,
      p_sub_inventory_code    IN                VARCHAR2    := NULL,
      p_serial_number         IN                VARCHAR2    := NULL
   )
IS

   -- Declare local variables
   l_api_name      CONSTANT    VARCHAR2(30)    := 'delete_reservation';
   l_debug_module  CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

   l_api_version   CONSTANT      NUMBER         := 1.0;
   l_init_msg_list               VARCHAR2(1)    := 'F';
   l_return_status               VARCHAR2(1);
   l_msg_count                   NUMBER;
   l_msg_data                    VARCHAR2(2000);


   l_rsv_rec                  inv_reservation_global.mtl_reservation_rec_type;
   l_serial_number_tbl        inv_reservation_global.serial_number_tbl_type;
   l_total_relieved_qty       NUMBER :=0;

   l_ret_value                NUMBER;
   l_reservation_id           NUMBER;

   -- Variables to check the log level according to the coding standards
   l_dbg_level          NUMBER      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   l_proc_level         NUMBER      := FND_LOG.LEVEL_PROCEDURE;

   l_temp               NUMBER;


   -- Declare cursors
   /*CURSOR get_mtl_req_dtls_csr (c_scheduled_material_id IN NUMBER)
   IS
      SELECT   1
      FROM     ahl_schedule_materials asmt
      WHERE    asmt.scheduled_material_id = c_scheduled_material_id;
   */

-- AnRaj: Added a join with ahl_schedule_materials and further where conditions to remove the FTS
-- on mtl_reservations
   CURSOR get_reservation_csr (c_scheduled_material_id IN NUMBER, c_subinventory_code IN VARCHAR2)
   IS
      SELECT   reservation_id
      FROM     mtl_reservations mrsv,ahl_schedule_materials asmt
      WHERE    mrsv.demand_source_line_detail = c_scheduled_material_id
      AND      mrsv.external_source_code = 'AHL'
      AND      (c_subinventory_code IS NULL OR mrsv.subinventory_code = c_subinventory_code)
      AND      mrsv.demand_source_line_detail = asmt.scheduled_material_id
      AND      mrsv.organization_id = asmt.organization_id
      AND      mrsv.requirement_date = asmt.requested_date
      AND      mrsv.inventory_item_id = asmt.inventory_item_id;
BEGIN
   -- Standard start of API savepoint
   SAVEPOINT DELETE_RESERVATION_PVT;

   -- Initialize return status to success before any code logic/validation
   x_return_status:= FND_API.G_RET_STS_SUCCESS;

   -- Standard call to check for call compatibility
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version, p_api_version, l_api_name, G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list = FND_API.G_TRUE
   IF FND_API.TO_BOOLEAN(p_init_msg_list)
   THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;

   -- Log API entry point
   IF (l_log_procedure >= l_log_current_level)THEN
      fnd_log.string
      (
         fnd_log.level_procedure,
         'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
         'At the start of PL SQL procedure '
      );
   END IF;

   -- Validate the schedule material id and p_sub_inventory_code
   IF p_scheduled_material_id IS NULL THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_RSV_INVLD_MAT_REQ' );
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- log the p_scheduled_material_id and the p_sub_inventory_code
   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string
      (
         fnd_log.level_statement,
         'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
         'p_scheduled_material_id' || p_scheduled_material_id
      );
      fnd_log.string
      (
         fnd_log.level_statement,
         'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
         'p_sub_inventory_code' || p_sub_inventory_code
      );
   END IF;

   -- validate whehther the scheduled material id is valid
   BEGIN
      SELECT 1
      INTO l_temp
      FROM ahl_schedule_materials
      WHERE scheduled_material_id = p_scheduled_material_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         FND_MESSAGE.Set_Name('AHL','AHL_RSV_INVLD_MAT_REQ');
         FND_MSG_PUB.ADD;
         -- log the error
         IF (l_log_error >= l_log_current_level) THEN
            fnd_log.string
            (
               fnd_log.level_error,
               'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
               'Invalid Material Requirement ID'
            );
         END IF;
         RAISE FND_API.G_EXC_ERROR;
   END;

   -- Begin Changes by skpathak on 12-NOV-2008 for bug 7241925
   IF (p_serial_number IS NOT NULL) THEN
     -- Delete based on the serial number
     GET_MATCHING_RESERVATION(p_scheduled_material_id => p_scheduled_material_id,
                              p_serial_number         => p_serial_number,
                              p_match_serial          => 'Y',  -- Match reservation with serial
                              x_reservation_id        => l_reservation_id,
                              x_reservation_quantity  => l_temp);

     IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(fnd_log.level_statement, l_debug_module,
                        'GET_MATCHING_RESERVATION returned l_reservation_id = ' || l_reservation_id);
     END IF;

     IF (l_reservation_id IS NOT NULL) THEN
       IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(fnd_log.level_statement, l_debug_module,
                        'About to Call inv_reservation_pub.delete_reservation with l_reservation_id: ' || l_reservation_id);
       END IF;

       -- Assign the reservation id to be deleted
       l_rsv_rec.reservation_id := l_reservation_id;
       -- Call the WMS api
       inv_reservation_pub.delete_reservation
         (
            p_api_version_number => l_api_version,
            p_init_msg_lst       => l_init_msg_list,
            x_return_status      => l_return_status,
            x_msg_count          => l_msg_count,
            x_msg_data           => l_msg_data,
            p_rsv_rec            => l_rsv_rec,
            p_serial_number      => l_serial_number_tbl
         );
       IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(fnd_log.level_statement, l_debug_module,
            'Returned from inv_reservation_pub.delete_reservation, l_return_status: ' || l_return_status);
       END IF;
       -- Check whether the return status is success, if not raise exception
       IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
         -- log the error
         IF (l_log_error >= l_log_current_level) THEN
           fnd_log.string(fnd_log.level_error, l_debug_module,
                           'inv_reservation_pub.delete_reservation returned FND_API.G_RET_STS_UNEXP_ERROR');
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
         -- log the error
         IF (l_log_error >= l_log_current_level) THEN
           fnd_log.string(fnd_log.level_error, l_debug_module,
                           'inv_reservation_pub.delete_reservation returned FND_API.G_RET_STS_ERROR');
         END IF;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
     END IF;  -- l_reservation_id IS NOT NULL
   ELSE
     -- Delete Based on p_scheduled_material_id and p_sub_inventory_code
     OPEN get_reservation_csr(p_scheduled_material_id,p_sub_inventory_code);
     LOOP
       -- For each of the reservation id associated with this material requirement call the Delete api
       FETCH get_reservation_csr INTO l_reservation_id;
       EXIT WHEN get_reservation_csr%NOTFOUND;
       -- logging
       IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string
         (
            fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
            'Going to Call inv_reservation_pub.delete_reservation l_reservation_id :' || l_reservation_id
         );
       END IF;

       -- Assign the reservation id to be deleted
       l_rsv_rec.reservation_id := l_reservation_id;
       -- Call the WMS api
       inv_reservation_pub.delete_reservation
         (
            p_api_version_number => l_api_version,
            p_init_msg_lst       => l_init_msg_list,
            x_return_status      => l_return_status,
            x_msg_count          => l_msg_count,
            x_msg_data           => l_msg_data,
            p_rsv_rec            => l_rsv_rec,
            p_serial_number      => l_serial_number_tbl
         );
       IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string
         (
            fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
            'After call inv_reservation_pub.delete_reservation,l_return_status :' || l_return_status
         );
       END IF;
       -- Check whether the return status is success, if not raise exception
       IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
         -- log the error
         IF (l_log_error >= l_log_current_level) THEN
            fnd_log.string
            (
               fnd_log.level_error,
               'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
               'inv_reservation_pub.delete_reservation returned FND_API.G_RET_STS_UNEXP_ERROR'
            );
         END IF;
         CLOSE get_reservation_csr;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
         -- log the error
         IF (l_log_error >= l_log_current_level) THEN
            fnd_log.string
            (
               fnd_log.level_error,
               'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
               'inv_reservation_pub.delete_reservation returned FND_API.G_RET_STS_ERROR'
            );
         END IF;
         CLOSE get_reservation_csr;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
     END LOOP; -- All the reservations for this material req id, sub inventory pair
   END IF;

   -- Log API exit point
   IF (l_log_procedure >= l_log_current_level)THEN
      fnd_log.string
         (
            fnd_log.level_procedure,
            l_debug_module||'.end',
            'At the end of PLSQL procedure'
         );
   END IF;

   -- Check Error Message stack.
   x_msg_count := FND_MSG_PUB.count_msg;
   IF x_msg_count > 0
   THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Commit if p_commit = FND_API.G_TRUE
   IF FND_API.TO_BOOLEAN(p_commit)
   THEN
      COMMIT WORK;
      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string
         (
            fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
            'delete reservation COMMITTED'
         );
      END IF;
   END IF;

   -- Standard call to get message count and if count is 1, get message info
   FND_MSG_PUB.count_and_get
   (
      p_count  => x_msg_count,
      p_data   => x_msg_data,
      p_encoded   => FND_API.G_FALSE
   );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO DELETE_RESERVATION_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get
      (
         p_count  => x_msg_count,
         p_data   => x_msg_data,
         p_encoded   => FND_API.G_FALSE
      );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO DELETE_RESERVATION_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get
      (
         p_count  => x_msg_count,
         p_data   => x_msg_data,
         p_encoded   => FND_API.G_FALSE
      );

   WHEN OTHERS THEN
      ROLLBACK TO DELETE_RESERVATION_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.add_exc_msg
         (
            p_pkg_name     => G_PKG_NAME,
            p_procedure_name  => 'delete_reservation',
            p_error_text      => SUBSTR(SQLERRM,1,240)
         );
      END IF;
      FND_MSG_PUB.count_and_get
      (
         p_count  => x_msg_count,
         p_data   => x_msg_data,
         p_encoded   => FND_API.G_FALSE
      );
END DELETE_RESERVATION;

---------------------------------------------------------------------------------------------------------------------
   -- Declare Procedures --
---------------------------------------------------------------------------------------------------------------------
   -- Start of Comments --
   --  Procedure name      : RELIEVE_RESERVATION
   --  Type                : Private
   --  Function            : API to delete the reservation made for a particular serial number
   --  Pre-reqs            :
   --  Standard IN  Parameters :
   --      p_api_version      IN       NUMBER         Required
   --      p_init_msg_list    IN       VARCHAR2       Default FND_API.G_FALSE
   --      p_commit           IN       VARCHAR2       Default FND_API.G_FALSE
   --      p_validation_level IN       NUMBER         Default FND_API.G_VALID_LEVEL_FULL
   --      p_module_type      IN       VARCHAR2       Default NULL
   --  Standard OUT Parameters :
   --      x_return_status    OUT      VARCHAR2       Required
   --      x_msg_count        OUT      NUMBER         Required
   --      x_msg_data         OUT      VARCHAR2       Required

   --
   --  RELIEVE_RESERVATION Parameters:
   --       p_scheduled_material_id : The Schedule Material Id
   --       p_serial_number         : The Serial number whose reservation has to be deleted
   --  End of Comments.
---------------------------------------------------------------------------------------------------------------------
PROCEDURE RELIEVE_RESERVATION(
      p_api_version           IN                NUMBER      := 1.0,
      p_init_msg_list         IN                VARCHAR2    := FND_API.G_FALSE,
      p_commit                IN                VARCHAR2    := FND_API.G_FALSE,
      p_validation_level      IN                NUMBER      := FND_API.G_VALID_LEVEL_FULL,
      p_module_type           IN                VARCHAR2,
      x_return_status         OUT      NOCOPY   VARCHAR2,
      x_msg_count             OUT      NOCOPY   NUMBER,
      x_msg_data              OUT      NOCOPY   VARCHAR2,
      p_scheduled_material_id IN                NUMBER  ,
      p_serial_number         IN                VARCHAR2)
IS
      -- Declare local variables
   l_api_name      CONSTANT    VARCHAR2(30)    := 'relieve_reservation';
   l_debug_module  CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

   l_api_version   CONSTANT      NUMBER         := 1.0;
   l_init_msg_list               VARCHAR2(1)    := 'F';
   l_return_status               VARCHAR2(1);
   l_msg_count                   NUMBER;
   l_msg_data                    VARCHAR2(2000);
   l_commit                      VARCHAR2(1)    := 'F';

   l_rsv_rec                     inv_reservation_global.mtl_reservation_rec_type;
   l_serial_number_tbl           inv_reservation_global.serial_number_tbl_type;
   l_reservation_id              NUMBER;
   l_reserved_quantity        NUMBER;
   l_x_primary_relieved_quantity NUMBER;
   l_x_primary_remain_quantity   NUMBER;

   -- Variables to check the log level according to the coding standards
   l_dbg_level          NUMBER      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   l_proc_level         NUMBER      := FND_LOG.LEVEL_PROCEDURE;

   -- Declare Cursors
   CURSOR get_mtl_req_dtls_csr (c_scheduled_material_id IN NUMBER)
   IS
      SELECT   asmt.organization_id,
               asmt.requested_date,
               asmt.uom,
               asmt.requested_quantity,
               asmt.inventory_item_id,
               asmt.object_version_number
      FROM     ahl_schedule_materials asmt,
               ahl_visit_tasks_b avtl
      WHERE    asmt.status = 'ACTIVE'
      AND      asmt.requested_quantity <>0
      AND      asmt.scheduled_material_id = c_scheduled_material_id
      AND      asmt.visit_task_id = avtl.visit_task_id
      AND      (  avtl.status_code='PLANNING'
                  OR
                  (  avtl.status_code='RELEASED'
                     AND
                     EXISTS ( SELECT   awo.visit_task_id
                              FROM     ahl_workorders awo
                              WHERE    avtl.visit_task_id = awo.visit_task_id
                              AND      (awo.status_code = '1' OR awo.status_code='3') -- 1:Unreleased,3:Released
                           )
                  )
               );
   l_get_mtl_req_dtls_rec  get_mtl_req_dtls_csr%ROWTYPE;

-- Cursor get_reservation_csr removed by skpathak on 12-NOV-2008 for bug 7241925
-- in favor of call to the new helper procedure GET_MATCHING_RESERVATION
/**
   CURSOR get_reservation_csr (c_scheduled_material_id IN NUMBER, c_SUBINVENTORY_CODE IN VARCHAR2)
   IS
      SELECT   reservation_id, primary_reservation_quantity
      FROM     mtl_reservations mrsv,ahl_schedule_materials asmt
      WHERE    mrsv.demand_source_line_detail = c_scheduled_material_id
      AND      mrsv.external_source_code = 'AHL'
      AND      mrsv.SUBINVENTORY_CODE = c_SUBINVENTORY_CODE
      AND      mrsv.demand_source_line_detail = asmt.scheduled_material_id
      AND      mrsv.organization_id = asmt.organization_id
      AND      mrsv.requirement_date = asmt.requested_date
      AND      mrsv.inventory_item_id = asmt.inventory_item_id;
**/
   CURSOR   get_instance_dtls_csr (c_inventory_itme_id IN NUMBER, c_serial_number IN VARCHAR2, c_organization_id IN NUMBER)
   IS
      SELECT   csi.instance_id, msn.serial_number,csi.inv_subinventory_name subinventory_code
      FROM     csi_item_instances csi,mtl_serial_numbers msn
      WHERE    csi.inventory_item_id = c_inventory_itme_id
      AND      csi.serial_number = c_serial_number
      AND      csi.last_vld_organization_id = c_organization_id
      AND      csi.inventory_item_id = msn.inventory_item_id;

   l_get_instance_dtls_rec    get_instance_dtls_csr%ROWTYPE;

BEGIN
   -- Standard start of API savepoint
   SAVEPOINT RELIEVE_RESERVATION_PVT;

   -- Initialize return status to success before any code logic/validation
   x_return_status:= FND_API.G_RET_STS_SUCCESS;

   -- Standard call to check for call compatibility
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version, p_api_version, l_api_name, G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list = FND_API.G_TRUE
   IF FND_API.TO_BOOLEAN(p_init_msg_list)
   THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;

   -- Log API entry point
   IF (l_log_procedure >= l_log_current_level)THEN
      fnd_log.string
      (
         fnd_log.level_procedure,
         'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
         'At the start of PL SQL procedure '
      );
   END IF;

      -- Validate the schedule material id
   IF p_scheduled_material_id IS NULL THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_RSV_INVLD_MAT_REQ' );
      FND_MSG_PUB.add;
      -- log the error
      IF (l_log_error >= l_log_current_level) THEN
         fnd_log.string
         (
            fnd_log.level_error,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
            'AHL_RSV_INVLD_MAT_REQ: FND_API.G_EXC_ERROR'
         );
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF; -- IF p_scheduled_material_id IS NULL

   -- Get the Material Requirements details
   OPEN get_mtl_req_dtls_csr(p_scheduled_material_id);
   FETCH get_mtl_req_dtls_csr INTO l_get_mtl_req_dtls_rec;
   -- If the details are not found then raise exception
   IF get_mtl_req_dtls_csr%NOTFOUND THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_RSV_INVLD_MAT_REQ' );
      FND_MSG_PUB.add;
      CLOSE get_mtl_req_dtls_csr;
      RAISE FND_API.G_EXC_ERROR;
   END IF; -- IF get_mtl_req_dtls_csr%NOTFOUND
   CLOSE get_mtl_req_dtls_csr;

   -- Validate the Serial Number
   IF p_serial_number IS NULL THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_RSV_INVLD_SL_NUM' );
      FND_MSG_PUB.add;
         IF (l_log_error>= l_log_current_level)THEN
            fnd_log.string
            (
               fnd_log.level_error,
               'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
               'p_serial_number is null'
            );
         END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF; -- IF p_serial_number IS NULL

   -- Get the details of the item instance
   OPEN get_instance_dtls_csr(l_get_mtl_req_dtls_rec.inventory_item_id,p_serial_number,l_get_mtl_req_dtls_rec.organization_id);
   FETCH get_instance_dtls_csr INTO l_get_instance_dtls_rec;
   IF get_instance_dtls_csr%NOTFOUND THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_RSV_INVLD_SL_NUM' );
      FND_MSG_PUB.add;
      CLOSE get_instance_dtls_csr;
      RAISE FND_API.G_EXC_ERROR;
   END IF; -- IF get_instance_dtls_csr%NOTFOUND
   CLOSE get_instance_dtls_csr;

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(fnd_log.level_statement,'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
                     'Serial Number to be Deleted:' || p_serial_number );
      fnd_log.string(fnd_log.level_statement,'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
                     'l_get_mtl_req_dtls_rec.inventory_item_id:' ||l_get_mtl_req_dtls_rec.inventory_item_id );
      fnd_log.string(fnd_log.level_statement,'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
                     'l_get_mtl_req_dtls_rec.organization_id:' || l_get_mtl_req_dtls_rec.organization_id );
      fnd_log.string(fnd_log.level_statement,'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
                     'p_scheduled_material_id:' || p_scheduled_material_id );
   END IF;



   -- Get the reservation details, that is id and the reserved quantity
   -- Changed by skpathak on 12-NOV-2008 for bug 7241925
/**
   OPEN get_reservation_csr(p_scheduled_material_id,l_get_instance_dtls_rec.subinventory_code);
   FETCH get_reservation_csr INTO l_reservation_id,l_reserved_quantity;
   -- If no reservations are found , then exit as nothing needs to be done
   IF get_reservation_csr%NOTFOUND THEN
      CLOSE get_reservation_csr;
      RETURN;
   END IF; --  IF get_reservation_csr%NOTFOUND
   CLOSE get_reservation_csr;
**/
   GET_MATCHING_RESERVATION(p_scheduled_material_id => p_scheduled_material_id,
                            p_serial_number         => p_serial_number,
                            p_match_serial          => 'Y',                -- Match reservation by serial
                            x_reservation_id        => l_reservation_id,
                            x_reservation_quantity  => l_reserved_quantity);

   IF (l_log_statement >= l_log_current_level) THEN
     fnd_log.string(fnd_log.level_statement, l_debug_module,
                      'GET_MATCHING_RESERVATION returned l_reservation_id = ' || l_reservation_id ||
                      ', l_reserved_quantity = ' || l_reserved_quantity);
   END IF;
   -- End Changes by skpathak on 12-NOV-2008 for bug 7241925

   -- If there is only one reserved item then DELETE_RESERVATION api has to be invoked
   IF l_reserved_quantity = 1 THEN
         delete_reservation(
                  p_api_version              =>    l_api_version,
                  p_init_msg_list            =>    l_init_msg_list,
                  p_commit                   =>    l_commit,
                  p_validation_level         =>    FND_API.G_VALID_LEVEL_FULL, -- the validation level
                  p_module_type              =>    p_module_type,
                  x_return_status            =>    l_return_status,
                  x_msg_count                =>    l_msg_count,
                  x_msg_data                 =>    l_msg_data,
                  p_scheduled_material_id    =>    p_scheduled_material_id,
-- Begin Changes by skpathak on 12-NOV-2008 for bug 7241925
/**
                  p_sub_inventory_code       =>    l_get_instance_dtls_rec.subinventory_code
**/
                  p_sub_inventory_code       =>    null,
                  p_serial_number            =>    p_serial_number
-- End Changes by skpathak on 12-NOV-2008 for bug 7241925
               );
   ELSIF l_reserved_quantity > 1 THEN

         -- Initialize the record to be send to the WMS package
         /*Initialize_create_rec(  p_scheduled_material_id, -- the schedule material id
                                 p_serial_number, -- the serial number
                                 l_rsv_rec, -- record to be passed ti the WMS packages
                                 l_return_status);  -- return status
         */
      -- If there are more than one item reserved, then RELIEVE_RESERVATION has to be called
         l_rsv_rec.reservation_id := l_reservation_id;
         l_serial_number_tbl(1).serial_number := p_serial_number;
         l_serial_number_tbl(1).inventory_item_id := l_get_mtl_req_dtls_rec.inventory_item_id;

         inv_reservation_pub.relieve_reservation(
                  p_api_version_number          => l_api_version,
                  p_init_msg_lst                => l_init_msg_list,
                  x_return_status               => l_return_status,
                  x_msg_count                   => l_msg_count,
                  x_msg_data                    => l_msg_data,
                  p_rsv_rec                     => l_rsv_rec,
                  p_primary_relieved_quantity   => 1,
                  p_relieve_all                 => fnd_api.g_false,
                  p_original_serial_number      => l_serial_number_tbl,
                  x_primary_relieved_quantity   => l_x_primary_relieved_quantity,
                  x_primary_remain_quantity     => l_x_primary_remain_quantity
               );
   END IF; -- IF l_reserved_quantity = 1

   -- Check for the returned status from these APIs
   IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      IF (l_log_error >= l_log_current_level) THEN
         fnd_log.string
         (
            fnd_log.level_error,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
            'After Relieve/Delete FND_API.G_EXC_UNEXPECTED_ERROR'
         );
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
     IF (l_log_error >= l_log_current_level) THEN
         fnd_log.string
         (
            fnd_log.level_error,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
            'After Relieve/Delete FND_API.G_EXC_ERROR'
         );
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Log API exit point
   IF (l_log_procedure >= l_log_current_level)THEN
      fnd_log.string
         (
            fnd_log.level_procedure,
            l_debug_module||'.end',
            'At the end of PLSQL procedure'
         );
   END IF;

   -- Check Error Message stack.
   x_msg_count := FND_MSG_PUB.count_msg;
   IF x_msg_count > 0
   THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Commit if p_commit = FND_API.G_TRUE
   IF FND_API.TO_BOOLEAN(p_commit)
   THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info
   FND_MSG_PUB.count_and_get
   (
      p_count  => x_msg_count,
      p_data   => x_msg_data,
      p_encoded   => FND_API.G_FALSE
   );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO RELIEVE_RESERVATION_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get
      (
         p_count  => x_msg_count,
         p_data   => x_msg_data,
         p_encoded   => FND_API.G_FALSE
      );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO RELIEVE_RESERVATION_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get
      (
         p_count  => x_msg_count,
         p_data   => x_msg_data,
         p_encoded   => FND_API.G_FALSE
      );

   WHEN OTHERS THEN
      ROLLBACK TO RELIEVE_RESERVATION_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.add_exc_msg
         (
            p_pkg_name     => G_PKG_NAME,
            p_procedure_name  => 'relieve_reservation',
            p_error_text      => SUBSTR(SQLERRM,1,240)
         );
      END IF;
      FND_MSG_PUB.count_and_get
      (
         p_count  => x_msg_count,
         p_data   => x_msg_data,
         p_encoded   => FND_API.G_FALSE
      );
END RELIEVE_RESERVATION;

---------------------------------------------------------------------------------------------------------------------
   -- Declare Procedures --
---------------------------------------------------------------------------------------------------------------------
   -- Start of Comments --
   --  Procedure name      : TRANSFER_RESERVATION
   --  Type                : Private
   --  Function            : API to change the demand source type, called when pushed to production
   --  Pre-reqs            :
   --  Standard IN  Parameters :
   --      p_api_version      IN       NUMBER         Required
   --      p_init_msg_list    IN       VARCHAR2       Default FND_API.G_FALSE
   --      p_commit           IN       VARCHAR2       Default FND_API.G_FALSE
   --      p_validation_level IN       NUMBER         Default FND_API.G_VALID_LEVEL_FULL
   --      p_module_type      IN       VARCHAR2       Default NULL
   --  Standard OUT Parameters :
   --      x_return_status    OUT      VARCHAR2       Required
   --      x_msg_count        OUT      NUMBER         Required
   --      x_msg_data         OUT      VARCHAR2       Required

   --
   --  TRANSFER_RESERVATION Parameters:
   --       p_visit_id              : The id of the visit for which the reservations need to be transferred.
   --  End of Comments.
---------------------------------------------------------------------------------------------------------------------
PROCEDURE TRANSFER_RESERVATION(
      p_api_version           IN                NUMBER      := 1.0,
      p_init_msg_list         IN                VARCHAR2    := FND_API.G_FALSE,
      p_commit                IN                VARCHAR2    := FND_API.G_FALSE,
      p_validation_level      IN                NUMBER      := FND_API.G_VALID_LEVEL_FULL,
      p_module_type           IN                VARCHAR2,
      x_return_status         OUT      NOCOPY   VARCHAR2,
      x_msg_count             OUT      NOCOPY   NUMBER,
      x_msg_data              OUT      NOCOPY   VARCHAR2,
      p_visit_id              IN                NUMBER)
IS
   -- Declare local variables
   l_api_name      CONSTANT      VARCHAR2(30)   := 'transfer_reservation';

   l_api_version   CONSTANT      NUMBER         := 1.0;
   l_init_msg_list               VARCHAR2(1)    := 'F';
   l_return_status               VARCHAR2(1);
   l_msg_count                   NUMBER;
   l_msg_data                    VARCHAR2(2000);

   l_debug_module  CONSTANT      VARCHAR2(100)     := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

   l_reservation_id              NUMBER;
   l_wip_entity_id               NUMBER;
   l_from_rsv_rec                inv_reservation_global.mtl_reservation_rec_type;
   l_to_rsv_rec                  inv_reservation_global.mtl_reservation_rec_type;
   l_from_serial_number_tbl      inv_reservation_global.serial_number_tbl_type;
   l_to_serial_number_tbl        inv_reservation_global.serial_number_tbl_type;
   l_x_to_reservation_id         NUMBER;

   -- Variables to check the log level according to the coding standards
   l_dbg_level          NUMBER      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   l_proc_level         NUMBER      := FND_LOG.LEVEL_PROCEDURE;

   -- Declare Cursors and local record types
   CURSOR get_mtl_req_dtls_csr (c_visit_id IN NUMBER)
   IS
      SELECT   mat.visit_task_id, mat.scheduled_material_id, mat.workorder_operation_id, mat.operation_sequence
      FROM     ahl_schedule_materials mat,
               ahl_visit_tasks_b vt
      WHERE    mat.status = 'ACTIVE'
      AND      mat.requested_quantity <>0
      AND      vt.status_code = 'PLANNING'
      AND      vt.visit_task_id = mat.visit_task_id
      AND      vt.visit_id = c_visit_ID;
   l_get_mtl_req_dtls_rec  get_mtl_req_dtls_csr%ROWTYPE;

   -- AnRaj: Added a join with ahl_schedule_materials and further where conditions to remove the FTS
   CURSOR get_reservation_csr (c_scheduled_material_id IN NUMBER)
   IS
      SELECT   reservation_id
      FROM     mtl_reservations mrsv,ahl_schedule_materials asmt
      WHERE    demand_source_line_detail = c_scheduled_material_id
      AND      external_source_code = 'AHL'
      AND      mrsv.demand_source_line_detail = asmt.scheduled_material_id
      AND      mrsv.organization_id = asmt.organization_id
      AND      mrsv.requirement_date = asmt.requested_date
      AND      mrsv.inventory_item_id = asmt.inventory_item_id;

   CURSOR get_wip_dtls_csr (c_visit_task_ID IN NUMBER)
   IS
      SELECT   aw.wip_entity_id
      FROM     ahl_workorders aw
      WHERE    aw.status_code in ('1','3') -- 1:Unreleased,3:Released
      AND      aw.visit_task_id  = c_visit_task_id;

BEGIN
   -- Standard start of API savepoint
   SAVEPOINT TRANSFER_RESERVATION_PVT;

   -- Initialize return status to success before any code logic/validation
   x_return_status:= FND_API.G_RET_STS_SUCCESS;

   -- Standard call to check for call compatibility
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version, p_api_version, l_api_name, G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list = FND_API.G_TRUE
   IF FND_API.TO_BOOLEAN(p_init_msg_list)
   THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;

   -- Log API entry point
   IF (l_log_procedure >= l_log_current_level)THEN
      fnd_log.string
      (
         fnd_log.level_procedure,
         'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
         'At the start of PL SQL procedure '
      );
   END IF;


   -- Get all the material requirements for this visit
   OPEN get_mtl_req_dtls_csr(p_visit_id);
   LOOP
      -- For each material requirement
      FETCH get_mtl_req_dtls_csr INTO  l_get_mtl_req_dtls_rec;
      EXIT  WHEN  get_mtl_req_dtls_csr%NOTFOUND;
      -- Get the all the reservations made for this material requirement
      OPEN  get_reservation_csr(l_get_mtl_req_dtls_rec.scheduled_material_id);
      LOOP
         -- For each reservation id
         FETCH get_reservation_csr  INTO  l_reservation_id;
         EXIT  WHEN  get_reservation_csr%NOTFOUND;
         l_from_rsv_rec.reservation_id := l_reservation_id;
         -- Get the WIP entity ID
         OPEN get_wip_dtls_csr(l_get_mtl_req_dtls_rec.visit_task_id);
         FETCH get_wip_dtls_csr INTO l_wip_entity_id;
         CLOSE get_wip_dtls_csr;

         l_to_rsv_rec.demand_source_type_id        := inv_reservation_global.g_source_type_wip;
         l_to_rsv_rec.demand_source_header_id      := l_wip_entity_id;
         l_to_rsv_rec.demand_source_line_id        := l_get_mtl_req_dtls_rec.operation_sequence;

         l_to_rsv_rec.demand_source_line_detail    := l_get_mtl_req_dtls_rec.scheduled_material_id;
         l_from_rsv_rec.demand_source_line_detail  := l_get_mtl_req_dtls_rec.scheduled_material_id;

         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string
            (
               fnd_log.level_statement,'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
               'Before Calling inv_reservation_pub.transfer_reservation'
            );
            fnd_log.string
            (
               fnd_log.level_statement,'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
               'l_to_rsv_rec.demand_source_type_id' || l_to_rsv_rec.demand_source_type_id
            );
            fnd_log.string
            (
               fnd_log.level_statement,'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
               'l_to_rsv_rec.demand_source_header_id' || l_to_rsv_rec.demand_source_header_id
            );
            fnd_log.string
            (
               fnd_log.level_statement,'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
               'l_to_rsv_rec.demand_source_line_detail' || l_to_rsv_rec.demand_source_line_detail
            );
            fnd_log.string
            (
               fnd_log.level_statement,'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
               'l_from_rsv_rec.reservation_id' || l_from_rsv_rec.reservation_id
            );
            fnd_log.string
            (
               fnd_log.level_statement,'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
               'l_to_serial_number_tbl.COUNT' || l_to_serial_number_tbl.COUNT
            );

         END IF;

         -- Call the WMS Transfer Reservaion API
         inv_reservation_pub.transfer_reservation
         (
                  p_api_version_number    => l_api_version,
                  p_init_msg_lst          => l_init_msg_list,
                  x_return_status         => l_return_status,
                  x_msg_count             => l_msg_count,
                  x_msg_data              => l_msg_data,
                  p_is_transfer_supply    => fnd_api.g_false,
                  p_original_rsv_rec      => l_from_rsv_rec,
                  p_to_rsv_rec            => l_to_rsv_rec,
                  p_original_serial_number=> l_from_serial_number_tbl,
                  p_to_serial_number      => l_to_serial_number_tbl,
                  x_to_reservation_id     => l_x_to_reservation_id
         );

            -- Check for the returned status from these APIs
            IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
               CLOSE get_reservation_csr;
               CLOSE get_mtl_req_dtls_csr;
               IF (l_log_error >= l_log_current_level) THEN
                  fnd_log.string
                  (
                     fnd_log.level_error,
                     'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
                     'inv_reservation_pub.transfer_reservation returned FND_API.G_EXC_ERROR'
                  );
               END IF;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
               CLOSE get_reservation_csr;
               CLOSE get_mtl_req_dtls_csr;
               IF (l_log_error >= l_log_current_level) THEN
                  fnd_log.string
                  (
                     fnd_log.level_error,
                     'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
                     'inv_reservation_pub.transfer_reservation returned FND_API.G_RET_STS_ERROR'
                  );
               END IF;
               RAISE FND_API.G_EXC_ERROR;
            END IF;
      END LOOP ; -- get_reservation_csr,for all the reservations for this material req
      CLOSE get_reservation_csr;
   END LOOP; --get_mtl_req_dtls_csr, for all the mat reqs of this visit
   CLOSE get_mtl_req_dtls_csr;

   -- Log API exit point
   IF (l_log_procedure >= l_log_current_level)THEN
      fnd_log.string
         (
            fnd_log.level_procedure,
            l_debug_module||'.end',
            'At the end of PLSQL procedure'
         );
   END IF;

   -- Check Error Message stack.
   x_msg_count := FND_MSG_PUB.count_msg;
   IF x_msg_count > 0
   THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Commit if p_commit = FND_API.G_TRUE
   IF FND_API.TO_BOOLEAN(p_commit)
   THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info
   FND_MSG_PUB.count_and_get
   (
      p_count  => x_msg_count,
      p_data   => x_msg_data,
      p_encoded   => FND_API.G_FALSE
   );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO TRANSFER_RESERVATION_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get
      (
         p_count  => x_msg_count,
         p_data   => x_msg_data,
         p_encoded   => FND_API.G_FALSE
      );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO TRANSFER_RESERVATION_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get
      (
         p_count  => x_msg_count,
         p_data   => x_msg_data,
         p_encoded   => FND_API.G_FALSE
      );

   WHEN OTHERS THEN
      ROLLBACK TO TRANSFER_RESERVATION_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.add_exc_msg
         (
            p_pkg_name     => G_PKG_NAME,
            p_procedure_name  => 'relieve_reservation',
            p_error_text      => SUBSTR(SQLERRM,1,240)
         );
      END IF;
      FND_MSG_PUB.count_and_get
      (
         p_count  => x_msg_count,
         p_data   => x_msg_data,
         p_encoded   => FND_API.G_FALSE
      );
END TRANSFER_RESERVATION;


---------------------------------------------------------------------------------------------------------------------
   -- Declare Procedures --
---------------------------------------------------------------------------------------------------------------------
   -- Start of Comments --
   --  Procedure name      : UPDATE_VISIT_RESERVATIONS
   --  Type                : Private
   --  Function            : API to update all the reservations for s particular visit
   --  Pre-reqs            :
   --  Standard IN  Parameters :
   --  Standard OUT Parameters :
   --      x_return_status    OUT      VARCHAR2       Required
   --
   --  UPDATE_VISIT_RESERVATIONS Parameters:
   --       p_visit_id              : The id of the visit for which the reservations need to be transferred.
   --       This method is invoked from AHL_LTP_REQST_MATRL_PVT.MODIFY_VISIT_RESERVATIONS
   --             After a task is deleted, to reschedule the reservations as task times might have changed
   --  End of Comments.
---------------------------------------------------------------------------------------------------------------------
PROCEDURE UPDATE_VISIT_RESERVATIONS(
      x_return_status         OUT      NOCOPY   VARCHAR2,
      p_visit_id              IN                NUMBER)
IS
   -- Declare local variables
   l_api_name      CONSTANT      VARCHAR2(30)   := 'update_visit_reservations';
   l_debug_module  CONSTANT      VARCHAR2(100)     := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;
   l_api_version   CONSTANT      NUMBER         := 1.0;
   l_init_msg_list               VARCHAR2(1)    := 'F';
   l_return_status               VARCHAR2(1);
   l_msg_count                   NUMBER;
   l_msg_data                    VARCHAR2(2000);

   l_from_rsv_rec                inv_reservation_global.mtl_reservation_rec_type;
   l_to_rsv_rec                  inv_reservation_global.mtl_reservation_rec_type;
   l_from_serial_number_tbl      inv_reservation_global.serial_number_tbl_type;
   l_to_serial_number_tbl        inv_reservation_global.serial_number_tbl_type;
   l_x_serial_number_tbl         inv_reservation_global.serial_number_tbl_type;
   l_x_quantity_reserved         NUMBER;

   -- Declare cursors and record variables
   -- Get the all the reservation related information using the schedule material id
   CURSOR get_upd_rsv_csr (c_visit_id IN NUMBER)
   IS
      SELECT   mrsv.reservation_id, mrsv.demand_source_header_id, mrsv.demand_source_line_id, mrsv.inventory_item_id,mrsv.organization_id
      FROM     ahl_schedule_materials asmt,
               ahl_visit_tasks_b vt,
               mtl_reservations mrsv
      WHERE    vt.status_code = 'PLANNING'
      AND      vt.visit_task_id = asmt.visit_task_id
      AND      vt.visit_id = c_visit_id
      AND      mrsv.external_source_code = 'AHL'
      AND      mrsv.demand_source_line_detail = asmt.scheduled_material_id
      AND      mrsv.organization_id = asmt.organization_id
      AND      mrsv.requirement_date = asmt.requested_date
      AND      mrsv.inventory_item_id = asmt.inventory_item_id;
   l_get_upd_rsv_rec    get_upd_rsv_csr%ROWTYPE;

   -- get the material requiremnt id and the date
   CURSOR get_mtl_req_id_csr (c_visit_task_id IN NUMBER, c_rt_oper_material_id IN NUMBER, c_inventory_item_id IN NUMBER)
   IS
      SELECT   scheduled_material_id, requested_date
      FROM     ahl_schedule_materials
      WHERE    visit_task_id = c_visit_task_id
      AND      rt_oper_material_id = c_rt_oper_material_id
      AND      inventory_item_id = c_inventory_item_id
      AND      status = 'ACTIVE';
   l_get_mtl_req_id_rec    get_mtl_req_id_csr%ROWTYPE;

   -- For getting the Serial numbers
   TYPE serial_num_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
   serial_num_tbl   serial_num_type;

   -- local variables
   l_reservation_id     NUMBER;
   l_inventory_item_id  NUMBER;
   l_temp_id               NUMBER;

BEGIN
   -- Standard start of API savepoint
   SAVEPOINT UPDATE_VISIT_RESERVATIONS_PVT;

   -- Initialize return status to success before any code logic/validation
   x_return_status:= FND_API.G_RET_STS_SUCCESS;

   -- Log API entry point
   IF (l_log_procedure >= l_log_current_level)THEN
      fnd_log.string
      (
         fnd_log.level_procedure,
         'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
         'At the start of PL SQL procedure '
      );
   END IF;

   -- Get all the material requirements with reservations Created
   -- for this visit, there can be any number of material requirements
   OPEN get_upd_rsv_csr (p_visit_id);
   LOOP
      FETCH  get_upd_rsv_csr INTO l_get_upd_rsv_rec;
      EXIT WHEN get_upd_rsv_csr%NOTFOUND;
      -- Find out the new material requirements for this reservation

      l_reservation_id := l_get_upd_rsv_rec.reservation_id;
      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string
         (
            fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
            'Reservation ID to be updated:' || l_reservation_id
         );
      END IF;

      l_inventory_item_id := l_get_upd_rsv_rec.inventory_item_id;
      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string
         (
            fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
            'Inventory Item ID: ' || l_inventory_item_id
         );
      END IF;
      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string
         (
            fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
            'demand_source_header_id: ' || l_get_upd_rsv_rec.demand_source_header_id
         );
      END IF;
      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string
         (
            fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
            'demand_source_line_id: ' || l_get_upd_rsv_rec.demand_source_line_id
         );
      END IF;

      -- For each material requirement id, get the schedule material id and the requested date
      OPEN  get_mtl_req_id_csr(l_get_upd_rsv_rec.demand_source_header_id,l_get_upd_rsv_rec.demand_source_line_id,l_get_upd_rsv_rec.inventory_item_id);
         FETCH get_mtl_req_id_csr INTO l_get_mtl_req_id_rec;
         IF get_mtl_req_id_csr%NOTFOUND THEN
            FND_MESSAGE.set_name( 'AHL', 'AHL_RSV_UPD_VST_RSV_FAIL' );
            FND_MSG_PUB.add;
            -- log the error
            IF (l_log_error  >= l_log_current_level) THEN
               fnd_log.string
               (
                  fnd_log.level_error,
                  'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
                  'No record found in ahl schedule materials for get_mtl_req_id_csr'
               );
            END IF;
            CLOSE get_upd_rsv_csr;
            CLOSE get_mtl_req_id_csr;
            RAISE FND_API.G_EXC_ERROR;
         END IF; -- IF get_mtl_req_id_csr%NOTFOUND
      CLOSE get_mtl_req_id_csr;

      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string
         (
            fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
            'l_get_mtl_req_id_rec.scheduled_material_id: ' || l_get_mtl_req_id_rec.scheduled_material_id
         );
      END IF;

      -- Get all the Serial Numbers reserved for this material req
      BEGIN
         SELECT   serial_number
         BULK COLLECT INTO serial_num_tbl
         FROM     mtl_serial_numbers
         WHERE    reservation_id = l_reservation_id
         AND      INVENTORY_ITEM_ID = l_get_upd_rsv_rec.inventory_item_id
         AND      CURRENT_ORGANIZATION_ID = l_get_upd_rsv_rec.organization_id;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            -- log the error
            IF (l_log_statement >= l_log_current_level) THEN
               fnd_log.string
               (
                  fnd_log.level_statement,
                  'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
                  'No Serial Numbers reseved for Reservation ID:' || l_reservation_id
               );
            END IF;
      END;

      IF serial_num_tbl.count > 0 THEN
      -- Initialize the record to be send to the WMS package
         Initialize_create_rec(  l_get_mtl_req_id_rec.scheduled_material_id, -- the schedule material id
                                 serial_num_tbl(1), -- the serial number
                                 l_to_rsv_rec, -- record to be passed to the WMS packages
                                 l_return_status);  -- return status

         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string
            (
               fnd_log.level_statement,
               'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
               'Organizzation ID is: ' || l_to_rsv_rec.organization_id
            );
         END IF;

         l_to_rsv_rec.primary_reservation_quantity := serial_num_tbl.count;
         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string
            (
               fnd_log.level_statement,
               'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
               'Number of Serial Numbers to be updated: ' || l_to_rsv_rec.primary_reservation_quantity
            );
         END IF;
         -- commented out, as serial numbers  as not required to be passed as we are updating only the date
        /* FOR I in serial_num_tbl.first..serial_num_tbl.last
         LOOP
            l_to_serial_number_tbl(I).serial_number := serial_num_tbl(I);
            l_to_serial_number_tbl(I).inventory_item_id := l_inventory_item_id;
         END LOOP;*/
      END IF;

      -- update reservation with new material requirement and requested date
      l_from_rsv_rec.reservation_id    := l_get_upd_rsv_rec.reservation_id;
      l_to_rsv_rec.reservation_id      := l_get_upd_rsv_rec.reservation_id;
      l_to_rsv_rec.requirement_date    := l_get_mtl_req_id_rec.requested_date;
      l_to_rsv_rec.demand_source_line_detail := l_get_mtl_req_id_rec.scheduled_material_id;

      -- Call WMS Update reservation API
      inv_reservation_pub.update_reservation
            (
               p_api_version_number       => l_api_version,
               p_init_msg_lst             => l_init_msg_list,
               x_return_status            => l_return_status,
               x_msg_count                => l_msg_count,
               x_msg_data                 => l_msg_data,
               p_original_rsv_rec         => l_from_rsv_rec,
               p_to_rsv_rec               => l_to_rsv_rec,
               p_original_serial_number   => l_from_serial_number_tbl,
               p_to_serial_number         => l_to_serial_number_tbl--,
            );

      -- Check for the returned status from these APIs
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
         --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         -- log the error
         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string
            (
               fnd_log.level_statement,
               'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
               'inv_reservation_pub.update_reservation returned UNEXPECTED ERROR'
            );
         END IF;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
         --RAISE FND_API.G_EXC_ERROR;
         x_return_status := FND_API.G_RET_STS_ERROR;
         -- log the error
         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string
            (
               fnd_log.level_statement,
               'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
               'inv_reservation_pub.update_reservation returned EXPECTED ERROR'
            );
         END IF;
      END IF;
   END LOOP;
   CLOSE get_upd_rsv_csr;

   -- Log API exit point
   IF (l_log_procedure >= l_log_current_level)THEN
      fnd_log.string
         (
            fnd_log.level_procedure,
            l_debug_module||'.end',
            'At the end of PLSQL procedure'
         );
   END IF;
END UPDATE_VISIT_RESERVATIONS;

---------------------------------------------------------------------------------------------------------------------
   -- Declare Procedures --
---------------------------------------------------------------------------------------------------------------------
   -- Start of Comments --
   --  Procedure name      : DELETE_VISIT_RESERVATIONS
   --  Type                : Private
   --  Function            : API to delete all the reservations for s particular visit
   --  Pre-reqs            :
   --  Standard IN  Parameters :
   --  Standard OUT Parameters :
   --      x_return_status    OUT      VARCHAR2       Required
   --
   --  DELETE_VISIT_RESERVATIONS Parameters:
   --       p_visit_id              : The visit id for which the reservations need to be deleted
   --  This procedure is called in AHL_LTP_REQST_MATRL_PVT.Unschedule_Visit_Materials
   --  When a task is deleted, to remove the reservations related to that task.
   --  End of Comments.
---------------------------------------------------------------------------------------------------------------------
PROCEDURE DELETE_VISIT_RESERVATIONS(
      x_return_status         OUT      NOCOPY   VARCHAR2,
      p_visit_id              IN                NUMBER)
IS
   -- Declare local variables
   l_api_name      CONSTANT      VARCHAR2(30)   := 'delete_visit_reservations';
   l_debug_module  CONSTANT      VARCHAR2(100)     := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;
   l_api_version   CONSTANT      NUMBER         := 1.0;
   l_init_msg_list               VARCHAR2(1)    := 'F';
   l_return_status               VARCHAR2(1);
   l_msg_count                   NUMBER;
   l_msg_data                    VARCHAR2(2000);

   l_from_rsv_rec                inv_reservation_global.mtl_reservation_rec_type;
   l_rsv_rec                  inv_reservation_global.mtl_reservation_rec_type;
   l_to_rsv_rec                  inv_reservation_global.mtl_reservation_rec_type;
   l_from_serial_number_tbl      inv_reservation_global.serial_number_tbl_type;
   l_to_serial_number_tbl        inv_reservation_global.serial_number_tbl_type;
   l_x_serial_number_tbl         inv_reservation_global.serial_number_tbl_type;
   l_serial_number_tbl           inv_reservation_global.serial_number_tbl_type;
   l_x_quantity_reserved         NUMBER;

   -- Variables to check the log level according to the coding standards
   l_dbg_level          NUMBER      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   l_proc_level         NUMBER      := FND_LOG.LEVEL_PROCEDURE;

   l_reservation_id     NUMBER:= null;

   --Declare Cursors
   --
   CURSOR get_del_rsv_csr (c_visit_id IN NUMBER)
   IS
      SELECT   mrsv.reservation_id
      FROM     ahl_schedule_materials asmt,
               ahl_visit_tasks_b avt,
               mtl_reservations mrsv
      WHERE    avt.status_code in ( 'PLANNING','DELETED')
      AND      avt.visit_task_id = asmt.visit_task_id
      AND      avt.visit_id = c_visit_ID
      AND      avt.visit_id = asmt.visit_id
      AND      mrsv.external_source_code = 'AHL'
      AND      mrsv.demand_source_line_detail = asmt.scheduled_material_id
      AND      mrsv.organization_id = asmt.organization_id
      AND      mrsv.requirement_date = asmt.requested_date
      AND      mrsv.inventory_item_id = asmt.inventory_item_id;

BEGIN
   -- Standard start of API savepoint
   SAVEPOINT DELETE_VISIT_RESERVATIONS_PVT;

   -- Initialize return status to success before any code logic/validation
   x_return_status:= FND_API.G_RET_STS_SUCCESS;

   -- Initialize message list if p_init_msg_list = FND_API.G_TRUE
/* IF FND_API.TO_BOOLEAN(p_init_msg_list)
   THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;
*/

   -- Log API entry point
   IF (l_log_procedure >= l_log_current_level)THEN
      fnd_log.string
      (
         fnd_log.level_procedure,
         'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
         'At the start of PL SQL procedure '
      );
   END IF;


   OPEN get_del_rsv_csr (p_visit_id);
   LOOP
      FETCH get_del_rsv_csr  INTO l_reservation_id;
      EXIT WHEN get_del_rsv_csr%NOTFOUND;
      l_rsv_rec.reservation_id := l_reservation_id;
      -- Call WMS delete reservation API
         inv_reservation_pub.delete_reservation
         (
                  p_api_version_number => l_api_version,
                  p_init_msg_lst       => l_init_msg_list,
                  x_return_status      => l_return_status,
                  x_msg_count          => l_msg_count,
                  x_msg_data           => l_msg_data,
                  p_rsv_rec            => l_rsv_rec,
                  p_serial_number      => l_serial_number_tbl
         );
      -- Check for the returned status from these APIs
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
         --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
         --RAISE FND_API.G_EXC_ERROR;
         x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
   END LOOP;
   CLOSE get_del_rsv_csr;

   -- Log API exit point
   IF (l_log_procedure >= l_log_current_level)THEN
      fnd_log.string
         (
            fnd_log.level_procedure,
            l_debug_module||'.end',
            'At the end of PLSQL procedure'
         );
   END IF;
END DELETE_VISIT_RESERVATIONS;


---------------------------------------------------------------------------------------------------------------------
   -- Declare Procedures --
---------------------------------------------------------------------------------------------------------------------
   -- Start of Comments --
   --  Procedure name      : INITIALIZE_CREATE_REC
   --  Type                : Private
   --  Function            : To initializa the record that is to be passed into WMS api
   --  Pre-reqs            :
   --  Standard IN  Parameters :
   --  Standard OUT Parameters :
   --  INITIALIZE_CREATE_REC Parameters:
   --       p_rsv_rec               :
   --       p_schedule_material_id  :
   --       x_rsv_rec               :
   --  End of Comments.
---------------------------------------------------------------------------------------------------------------------
PROCEDURE INITIALIZE_CREATE_REC(
      p_schedule_material_id           IN             NUMBER,
      p_serial_number                  IN             VARCHAR2,
      x_rsv_rec                        OUT   NOCOPY   inv_reservation_global.mtl_reservation_rec_type,
      x_return_status                  OUT   NOCOPY   VARCHAR2
      )
IS

   -- Declare local variables
   l_api_name      CONSTANT      VARCHAR2(30)   := 'initialize_create_rec';
   l_debug_module  CONSTANT      VARCHAR2(100)     := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;
   -- Variables to check the log level according to the coding standards
   l_dbg_level          NUMBER      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   l_proc_level         NUMBER      := FND_LOG.LEVEL_PROCEDURE;

   -- Declare cursors
   -- Cursor to get the Material Requirement Details
   CURSOR get_mtl_req_dtls_csr (c_scheduled_material_id IN NUMBER)
   IS
      SELECT   mat.scheduled_material_id , mat.organization_id,
               mat.requested_date, mat.uom, mat.inventory_item_id,
               mat. workorder_operation_id, vt.status_code task_status_code,
               vt.visit_task_number, v.visit_number, mat.operation_sequence,
               mat.visit_task_id, mat.rt_oper_material_id
      FROM     ahl_schedule_materials mat,
               ahl_visits_b v,
               ahl_visit_tasks_b vt
      WHERE    vt.visit_task_id = mat.visit_task_id
      AND      vt.visit_id = v.visit_id
      AND      mat.scheduled_material_id = c_scheduled_material_id;
   l_get_mtl_req_dtls_rec  get_mtl_req_dtls_csr%ROWTYPE;

   -- Cursor to get the WIP details
   CURSOR get_wip_dtls_csr (c_visit_task_ID IN NUMBER)
   IS
      SELECT   aw.wip_entity_id
      FROM     ahl_workorders aw
      WHERE    aw.status_code in ('1','3') -- 1:Unreleased,3:Released
      AND      aw.visit_task_id = c_visit_task_id;
   l_get_wip_dtls_rec   get_wip_dtls_csr%ROWTYPE;

   -- Cursor to get the subinventory and the locator information
   -- AnRaj modified by selecting 2 more fiels, bug#4756288
   CURSOR get_subinv_locator(c_serial_number IN VARCHAR2,c_inventory_item_id IN NUMBER)
   IS
      SELECT   inv_subinventory_name,inv_locator_id,inventory_revision,lot_number
      FROM     csi_item_instances
      WHERE    serial_number = c_serial_number
      AND      inventory_item_id = c_inventory_item_id;

   l_subinventory_name  csi_item_instances.inv_subinventory_name%TYPE;
   l_inv_locator_id     NUMBER;
   -- AnRaj added 2 more variable, bug#4756288
   l_revision           csi_item_instances.inventory_revision%TYPE;
   l_lot_number         csi_item_instances.serial_number%TYPE;

BEGIN

   -- Log API exit point
   IF (l_log_procedure >= l_log_current_level)THEN
      fnd_log.string
         (
            fnd_log.level_procedure,
            l_debug_module||'.start',
            'At the start of PLSQL procedure'
         );
   END IF;

   -- Get the material requirement details


   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string
      (
         fnd_log.level_statement,
         'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
         'p_schedule_material_id in get_mtl_req_dtls_csr is:' || p_schedule_material_id
      );
   END IF;

   OPEN  get_mtl_req_dtls_csr (p_schedule_material_id);
   FETCH get_mtl_req_dtls_csr INTO l_get_mtl_req_dtls_rec;
   CLOSE get_mtl_req_dtls_csr;

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string
      (
         fnd_log.level_statement,
         'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
         'Fetched Value of l_get_mtl_req_dtls_rec.organization_id is:' || l_get_mtl_req_dtls_rec.organization_id
      );
   END IF;



   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string
      (
         fnd_log.level_statement,
         'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
         'p_serial_number in get_subinv_locator is: ' || p_serial_number
      );
   END IF;
   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string
      (
         fnd_log.level_statement,
         'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
         'l_get_mtl_req_dtls_rec.inventory_item_id in get_subinv_locator is ' || l_get_mtl_req_dtls_rec.inventory_item_id
      );
   END IF;
   -- Get the subinventory  name and the locator id
   OPEN  get_subinv_locator(p_serial_number,l_get_mtl_req_dtls_rec.inventory_item_id);
   FETCH get_subinv_locator INTO l_subinventory_name,l_inv_locator_id,l_revision,l_lot_number;
   CLOSE get_subinv_locator;

   x_rsv_rec.reservation_id               := NULL;
   x_rsv_rec.requirement_date             := l_get_mtl_req_dtls_rec.requested_date;
   x_rsv_rec.organization_id              := l_get_mtl_req_dtls_rec.organization_id;
   x_rsv_rec.inventory_item_id            := l_get_mtl_req_dtls_rec.inventory_item_id;
   x_rsv_rec.demand_source_name           := 'CMRO'||'.'|| l_get_mtl_req_dtls_rec.visit_number ||'.'||l_get_mtl_req_dtls_rec.visit_task_number;
   x_rsv_rec.demand_source_line_detail    := l_get_mtl_req_dtls_rec.scheduled_material_id;
   x_rsv_rec.primary_uom_code             := l_get_mtl_req_dtls_rec.uom;
   x_rsv_rec.primary_uom_id               := NULL;
   x_rsv_rec.reservation_uom_code         := NULL;
   x_rsv_rec.reservation_uom_id           := NULL;
   x_rsv_rec.reservation_quantity         := NULL;
   x_rsv_rec.primary_reservation_quantity := NULL;
   x_rsv_rec.autodetail_group_id          := NULL;
   x_rsv_rec.external_source_code         := 'AHL';
   x_rsv_rec.external_source_line_id      := NULL;
   x_rsv_rec.supply_source_type_id        := inv_reservation_global.g_source_type_inv;
   x_rsv_rec.supply_source_header_id      := NULL;
   x_rsv_rec.supply_source_line_id        := NULL;
   x_rsv_rec.supply_source_name           := NULL;
   x_rsv_rec.supply_source_line_detail    := NULL;
   x_rsv_rec.revision                     := l_revision;
   x_rsv_rec.subinventory_code            := l_subinventory_name;
   x_rsv_rec.subinventory_id              := NULL;

   -- AnRaj modified, bug#4756288
   x_rsv_rec.locator_id                   := l_inv_locator_id;
   x_rsv_rec.lot_number                   := l_lot_number;
   -- end bug#4756288

   x_rsv_rec.lot_number_id                := NULL;
   x_rsv_rec.pick_slip_number             := NULL;
   x_rsv_rec.lpn_id                       := NULL;
   -- Added later
   x_rsv_rec.ship_ready_flag              := NULL;
   x_rsv_rec.demand_source_delivery       := NULL;

   x_rsv_rec.attribute_category           := NULL;
   x_rsv_rec.attribute1                   := NULL;
   x_rsv_rec.attribute2                   := NULL;
   x_rsv_rec.attribute3                   := NULL;
   x_rsv_rec.attribute4                   := NULL;
   x_rsv_rec.attribute5                   := NULL;
   x_rsv_rec.attribute6                   := NULL;
   x_rsv_rec.attribute7                   := NULL;
   x_rsv_rec.attribute8                   := NULL;
   x_rsv_rec.attribute9                   := NULL;
   x_rsv_rec.attribute10                  := NULL;
   x_rsv_rec.attribute11                  := NULL;
   x_rsv_rec.attribute12                  := NULL;
   x_rsv_rec.attribute13                  := NULL;
   x_rsv_rec.attribute14                  := NULL;
   x_rsv_rec.attribute15                  := NULL;

   IF l_get_mtl_req_dtls_rec.task_status_code = 'RELEASED' THEN
      -- If the task is in 'released' then get the WIP entity id for demand_source_header_id
      OPEN get_wip_dtls_csr (l_get_mtl_req_dtls_rec.visit_task_id);
      FETCH get_wip_dtls_csr INTO l_get_wip_dtls_rec;
      CLOSE get_wip_dtls_csr;
      x_rsv_rec.demand_source_type_id        := inv_reservation_global.g_source_type_wip;
      x_rsv_rec.demand_source_header_id      := l_get_wip_dtls_rec.wip_entity_id;
      x_rsv_rec.demand_source_line_id        := l_get_mtl_req_dtls_rec.operation_sequence;
   ELSIF l_get_mtl_req_dtls_rec.task_status_code = 'PLANNING' THEN
      -- If the task is in 'planning' then get the WIP entity id for demand_source_header_id
      x_rsv_rec.demand_source_type_id        := inv_reservation_global.g_source_type_inv;
      x_rsv_rec.demand_source_header_id      := l_get_mtl_req_dtls_rec.Visit_Task_ID;
      x_rsv_rec.demand_source_line_id        := l_get_mtl_req_dtls_rec.rt_oper_material_id;
   ELSE
      FND_MESSAGE.set_name( 'AHL', 'AHL_RSV_ONLY_PLN_SPF_TSK' );
      FND_MSG_PUB.ADD;
      --RAISE FND_API.G_EXC_ERROR;
      x_return_status := FND_API.G_RET_STS_ERROR;
   END IF; -- l_get_mtl_req_dtls_rec.task_status_code = 'RELEASED'

   -- Log API exit point
   IF (l_log_procedure >= l_log_current_level)THEN
      fnd_log.string
         (
            fnd_log.level_procedure,
            l_debug_module||'.end',
            'At the end of PLSQL procedure'
         );
   END IF;
END INITIALIZE_CREATE_REC;


---------------------------------------------------------------------------------------------------------------------
   -- Declare Procedures --
---------------------------------------------------------------------------------------------------------------------
   -- Start of Comments --
   --  Procedure name      : TRANSFER_RESERVATION_MATRL_REQR
   --  Type                : Private
   --  Function            : API to transfer the reservations from one material requirement to another
   --  Pre-reqs            :
   --  Standard IN  Parameters :
   --      p_api_version      IN       NUMBER         Required
   --      p_init_msg_list    IN       VARCHAR2       Default FND_API.G_FALSE
   --      p_commit           IN       VARCHAR2       Default FND_API.G_FALSE
   --      p_validation_level IN       NUMBER         Default FND_API.G_VALID_LEVEL_FULL
   --      p_module_type      IN       VARCHAR2       Default NULL
   --  Standard OUT Parameters :
   --      x_return_status    OUT      VARCHAR2       Required
   --      x_msg_count        OUT      NUMBER         Required
   --      x_msg_data         OUT      VARCHAR2       Required

   --
   --  TRANSFER_RESERVATION Parameters:
   --       p_visit_id              : The id of the visit for which the reservations need to be transferred.
   --       p_visit_task_id         : The of the Visit task
   --       p_from_mat_req_id       : The material requirement id of the from record
   --       p_to_mat_req_id         : The material requirement id of the to record

   --  End of Comments.
---------------------------------------------------------------------------------------------------------------------
PROCEDURE TRNSFR_RSRV_FOR_MATRL_REQR(
      p_api_version           IN                NUMBER      := 1.0,
      p_init_msg_list         IN                VARCHAR2    := FND_API.G_FALSE,
      p_commit                IN                VARCHAR2    := FND_API.G_FALSE,
      p_validation_level      IN                NUMBER      := FND_API.G_VALID_LEVEL_FULL,
      p_module_type           IN                VARCHAR2,
      x_return_status         OUT      NOCOPY   VARCHAR2,
      x_msg_count             OUT      NOCOPY   NUMBER,
      x_msg_data              OUT      NOCOPY   VARCHAR2,
      p_visit_task_id         IN                NUMBER,
      p_from_mat_req_id       IN                NUMBER,
      p_to_mat_req_id         IN                NUMBER
      )
IS
   -- Declare local variables
   l_api_name      CONSTANT      VARCHAR2(30)   := 'TRNSFR_RSRV_FOR_MATRL_REQR';

   l_api_version   CONSTANT      NUMBER         := 1.0;
   l_init_msg_list               VARCHAR2(1)    := 'F';
   l_return_status               VARCHAR2(1);
   l_msg_count                   NUMBER;
   l_msg_data                    VARCHAR2(2000);

   l_debug_module  CONSTANT      VARCHAR2(100)     := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

   l_reservation_id              NUMBER;
   l_wip_entity_id               NUMBER;
   l_from_rsv_rec                inv_reservation_global.mtl_reservation_rec_type;
   l_to_rsv_rec                  inv_reservation_global.mtl_reservation_rec_type;
   l_from_serial_number_tbl      inv_reservation_global.serial_number_tbl_type;
   l_to_serial_number_tbl        inv_reservation_global.serial_number_tbl_type;
   l_x_to_reservation_id         NUMBER;

   -- Variables to check the log level according to the coding standards
   l_dbg_level          NUMBER      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   l_proc_level         NUMBER      := FND_LOG.LEVEL_PROCEDURE;

BEGIN
   -- Standard start of API savepoint
   SAVEPOINT TRNSFR_RSRV_FOR_MATRL_REQR_PVT;

   -- Initialize return status to success before any code logic/validation
   x_return_status:= FND_API.G_RET_STS_SUCCESS;

   -- Standard call to check for call compatibility
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version, p_api_version, l_api_name, G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list = FND_API.G_TRUE
   IF FND_API.TO_BOOLEAN(p_init_msg_list)
   THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;

   -- Log API entry point
   IF (l_log_procedure >= l_log_current_level)THEN
      fnd_log.string
      (
         fnd_log.level_procedure,
         'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
         'At the start of PL SQL procedure '
      );
   END IF;

   l_from_rsv_rec.demand_source_line_detail  := p_from_mat_req_id;
   l_to_rsv_rec.demand_source_type_id        := inv_reservation_global.g_source_type_inv;
   l_to_rsv_rec.demand_source_header_id      := p_visit_task_id;
   l_to_rsv_rec.demand_source_line_detail    := p_to_mat_req_id;

   IF (l_log_statement >= l_log_current_level)THEN
      fnd_log.string
      (fnd_log.level_statement,'ahl.plsql.'||g_pkg_name||'.'||l_api_name,'Calling inv_reservation_pub.transfer_reservation');
   END IF;

   inv_reservation_pub.transfer_reservation
         (
                  p_api_version_number    => l_api_version,
                  p_init_msg_lst          => l_init_msg_list,
                  x_return_status         => l_return_status,
                  x_msg_count             => l_msg_count,
                  x_msg_data              => l_msg_data,
                  p_is_transfer_supply    => fnd_api.g_false,
                  p_original_rsv_rec      => l_from_rsv_rec,
                  p_to_rsv_rec            => l_to_rsv_rec,
                  p_original_serial_number=> l_from_serial_number_tbl,
                  p_to_serial_number      => l_to_serial_number_tbl,
                  x_to_reservation_id     => l_x_to_reservation_id
         );

   -- Check for the returned status from these APIs
   IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      IF (l_log_error >= l_log_current_level) THEN
         fnd_log.string
         (
            fnd_log.level_error,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
            'inv_reservation_pub.transfer_reservation returned FND_API.G_EXC_ERROR'
         );
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      IF (l_log_error >= l_log_current_level) THEN
         fnd_log.string
           (
               fnd_log.level_error,
               'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
               'inv_reservation_pub.transfer_reservation returned FND_API.G_RET_STS_ERROR'
            );
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Log API exit point
   IF (l_log_procedure >= l_log_current_level)THEN
      fnd_log.string
         (
            fnd_log.level_procedure,
            l_debug_module||'.end',
            'At the end of PLSQL procedure'
         );
   END IF;

   -- Check Error Message stack.
   x_msg_count := FND_MSG_PUB.count_msg;
   IF x_msg_count > 0
   THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Commit if p_commit = FND_API.G_TRUE
   IF FND_API.TO_BOOLEAN(p_commit)
   THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info
   FND_MSG_PUB.count_and_get
   (
      p_count  => x_msg_count,
      p_data   => x_msg_data,
      p_encoded   => FND_API.G_FALSE
   );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO TRNSFR_RSRV_FOR_MATRL_REQR_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get
      (
         p_count  => x_msg_count,
         p_data   => x_msg_data,
         p_encoded   => FND_API.G_FALSE
      );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO TRNSFR_RSRV_FOR_MATRL_REQR_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get
      (
         p_count  => x_msg_count,
         p_data   => x_msg_data,
         p_encoded   => FND_API.G_FALSE
      );

   WHEN OTHERS THEN
      ROLLBACK TO TRNSFR_RSRV_FOR_MATRL_REQR_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.add_exc_msg
         (
            p_pkg_name     => G_PKG_NAME,
            p_procedure_name  => 'TRANSFER_RESERVATION_MATRL_REQR_PVT',
            p_error_text      => SUBSTR(SQLERRM,1,240)
         );
      END IF;
      FND_MSG_PUB.count_and_get
      (
         p_count  => x_msg_count,
         p_data   => x_msg_data,
         p_encoded   => FND_API.G_FALSE
      );
END TRNSFR_RSRV_FOR_MATRL_REQR;

-- Helper procedure added by skpathak on 12-NOV-2008 for bug 7241925
-- Gets the reservation (if any) that matches the scheduled_material_id+serial_number
-- If p_match_serial is 'Y', also checks if the serial is already included in the reservation

PROCEDURE GET_MATCHING_RESERVATION(p_scheduled_material_id IN NUMBER,
                                   p_serial_number         IN VARCHAR2,
                                   p_match_serial          IN VARCHAR2 DEFAULT 'N',
                                   x_reservation_id        OUT NOCOPY NUMBER,
                                   x_reservation_quantity  OUT NOCOPY NUMBER) IS
   -- Declare local variables
   l_api_name      CONSTANT      VARCHAR2(30)   := 'GET_MATCHING_RESERVATION';
   l_debug_module  CONSTANT      VARCHAR2(100)  := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

   CURSOR get_reservation_csr IS
      SELECT mrsv.reservation_id, mrsv.primary_reservation_quantity
        FROM mtl_reservations mrsv, ahl_schedule_materials asmt, mtl_serial_numbers msn
       WHERE mrsv.demand_source_line_detail = p_scheduled_material_id
         AND mrsv.external_source_code = 'AHL'
         AND msn.serial_number = p_serial_number
         AND mrsv.organization_id = msn.current_organization_id
         AND mrsv.inventory_item_id = msn.inventory_item_id
         AND NVL(mrsv.subinventory_code, '@@@') = NVL(msn.current_subinventory_code, '@@@')
         AND NVL(mrsv.locator_id, -99) = NVL(msn.current_locator_id, -99)
         AND NVL(mrsv.revision, '@@@') = NVL(msn.revision, '@@@')
         AND NVL(mrsv.lot_number, '@@@') = NVL(msn.lot_number, '@@@')
         AND NVL(mrsv.lpn_id, -99) = NVL(msn.lpn_id, -99)
         AND ((p_match_serial = 'N') OR (mrsv.reservation_id = msn.reservation_id))
         AND mrsv.demand_source_line_detail = asmt.scheduled_material_id
         AND mrsv.organization_id = asmt.organization_id
         AND mrsv.requirement_date = asmt.requested_date
         AND mrsv.inventory_item_id = asmt.inventory_item_id;
BEGIN

  -- Log API exit point
  IF (l_log_procedure >= l_log_current_level) THEN
    fnd_log.string(fnd_log.level_procedure, l_debug_module||'.start',
                   'At the start of PLSQL procedure, p_scheduled_material_id = ' || p_scheduled_material_id ||
                   ', p_serial_number = ' || p_serial_number);
  END IF;

  OPEN get_reservation_csr;
  FETCH get_reservation_csr INTO x_reservation_id, x_reservation_quantity;
  CLOSE get_reservation_csr;

  -- Log API exit point
  IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(fnd_log.level_procedure, l_debug_module||'.end',
                     'At the end of PLSQL procedure, x_reservation_id = ' || x_reservation_id ||
                     ', x_reservation_quantity = ' || x_reservation_quantity);
  END IF;
END GET_MATCHING_RESERVATION;

END AHL_RSV_RESERVATIONS_PVT;

/
