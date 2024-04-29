--------------------------------------------------------
--  DDL for Package Body AHL_OSP_ORDERS_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_OSP_ORDERS_CUHK" AS
/* $Header: AHLCOSPB.pls 120.0 2005/11/11 11:49:50 jeli noship $*/
G_PKG_NAME CONSTANT VARCHAR2(30) :='AHL_OSP_ORDERS_CUHK';
PROCEDURE process_osp_order_pre(
     p_osp_order_rec       IN  AHL_OSP_ORDERS_PVT.osp_order_rec_type,
    p_osp_order_lines_tbl IN  AHL_OSP_ORDERS_PVT.osp_order_lines_tbl_type,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2) IS
/*
CURSOR get_item_flag(c_inventory_item_id NUMBER, c_inventory_org_id NUMBER) IS
SELECT comms_nl_trackable_flag --hazardous_material_flag
  FROM mtl_system_items_kfv
 WHERE inventory_item_id = c_inventory_item_id
   AND organization_id = c_inventory_org_id;
  l_first_item_flag       VARCHAR2(1);
  l_temp_item_flag        VARCHAR2(1);
*/
  l_msg_count             NUMBER;
  l_api_name              VARCHAR2(30);
BEGIN
  --Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_api_name := 'PROCESS_OSP_ORDER_PRE';

  /* This section was commented out for the user to customize
  IF (p_osp_order_rec.operation_flag = 'C' AND p_osp_order_lines_tbl.COUNT > 0) THEN
    OPEN get_item_flag(p_osp_order_lines_tbl(1).inventory_item_id, p_osp_order_lines_tbl(1).inventory_org_id );
    FETCH get_item_flag INTO l_first_item_flag;
    IF get_item_flag%NOTFOUND THEN
      FND_MESSAGE.set_name('AHL', 'AHL_OSP_ORD_INV_ITEM');
      FND_MESSAGE.set_token('ITEM_ID', p_osp_order_lines_tbl(1).inventory_item_id);
      FND_MSG_PUB.add;
      CLOSE get_item_flag;
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      CLOSE get_item_flag;
    END IF;
    FOR i IN p_osp_order_lines_tbl.FIRST.. p_osp_order_lines_tbl.LAST LOOP
      OPEN get_item_flag(p_osp_order_lines_tbl(i).inventory_item_id, p_osp_order_lines_tbl(i).inventory_org_id );
      FETCH get_item_flag INTO l_temp_item_flag;
      IF get_item_flag%NOTFOUND THEN
        FND_MESSAGE.set_name('AHL', 'AHL_OSP_ORD_INV_ITEM');
        FND_MESSAGE.set_token('ITEM_ID', p_osp_order_lines_tbl(i).inventory_item_id);
        FND_MSG_PUB.ADD;
        CLOSE get_item_flag;
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        CLOSE get_item_flag;
      END IF;
      IF ((l_first_item_flag IS NULL AND l_temp_item_flag IS NOT NULL) OR
          (l_first_item_flag IS NOT NULL AND l_temp_item_flag IS NULL) OR
          (l_temp_item_flag <> l_first_item_flag)) THEN
        -- Throw an error about the mixed nature of items
        FND_MESSAGE.set_name('AHL', 'AHL_OSP_CANNOT_MIX_ITEMS');
        FND_MESSAGE.set_token('ITEM_ID', p_osp_order_lines_tbl(i).inventory_item_id);
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;
  END IF;
  */
  -- Get all the error messages from the previous steps (if any) and raise the appropriate Exception
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Count and Get messages (optional)
  FND_MSG_PUB.count_and_get(
    p_encoded  => FND_API.G_FALSE,
    p_count    => x_msg_count,
    p_data     => x_msg_data);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.add_exc_msg(
        p_pkg_name         => G_PKG_NAME,
        p_procedure_name   => l_api_name,
        p_error_text       => SUBSTRB(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
END process_osp_order_pre;

PROCEDURE process_osp_order_post(
    p_osp_order_rec       IN  AHL_OSP_ORDERS_PVT.osp_order_rec_type,
    p_osp_order_lines_tbl IN  AHL_OSP_ORDERS_PVT.osp_order_lines_tbl_type,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2) IS
  l_msg_count             NUMBER;
  l_api_name              VARCHAR2(30);
BEGIN
  --Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_api_name := 'PROCESS_OSP_ORDER_POST';

  --Users can add their own customization code here

  -- Get all the error messages from the previous steps (if any) and raise the appropriate Exception
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Count and Get messages (optional)
  FND_MSG_PUB.count_and_get(
    p_encoded  => FND_API.G_FALSE,
    p_count    => x_msg_count,
    p_data     => x_msg_data);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.add_exc_msg(
        p_pkg_name         => G_PKG_NAME,
        p_procedure_name   => l_api_name,
        p_error_text       => SUBSTRB(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
END process_osp_order_post;

END AHL_OSP_ORDERS_CUHK;

/
