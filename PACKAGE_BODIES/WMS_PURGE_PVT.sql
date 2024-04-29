--------------------------------------------------------
--  DDL for Package Body WMS_PURGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_PURGE_PVT" AS
/* $Header: WMSPURGB.pls 120.9 2006/08/10 11:27:09 bradha ship $*/

-- Global constant holding the package name
g_pkg_name    CONSTANT VARCHAR2(30)  := 'WMS_PURGE_PVT';
g_pkg_version CONSTANT VARCHAR2(100) := '$Header: WMSPURGB.pls 120.9 2006/08/10 11:27:09 bradha ship $';


DEVICE  CONSTANT NUMBER :=1;
LPN     CONSTANT NUMBER :=2;
TASK    CONSTANT NUMBER :=3;
LABEL   CONSTANT NUMBER :=4;
EPC     CONSTANT NUMBER :=5;

PROCEDURE Check_Purge_LPNs (
  p_api_version     IN         NUMBER
, p_init_msg_list   IN         VARCHAR2 := fnd_api.g_false
, p_commit          IN         VARCHAR2 := fnd_api.g_false
, x_return_status   OUT NOCOPY VARCHAR2
, x_msg_count       OUT NOCOPY NUMBER
, x_msg_data        OUT NOCOPY VARCHAR2
, p_caller          IN         VARCHAR2
, p_lock_flag       IN         VARCHAR2
, p_lpn_id_table    IN OUT NOCOPY WMS_DATA_TYPE_DEFINITIONS_PUB.NumberTableType
) IS
l_api_name    CONSTANT VARCHAR2(30)  := 'Check_Purge_LPNs';
l_api_version CONSTANT NUMBER        := 1.0;
l_debug                NUMBER        := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_progress             VARCHAR2(500) := 'Entered API';

l_valid_lpns  WMS_DATA_TYPE_DEFINITIONS_PUB.NumberTableType;

BEGIN
  IF (l_debug = 1) THEN
    inv_trx_util_pub.trace(l_api_name || ' Entered ' || g_pkg_version, l_api_name, 4);
    inv_trx_util_pub.trace('ver='||p_api_version||' initmsg='||p_init_msg_list||' commit='||p_commit||' caller='||p_caller||' tabfst='||p_lpn_id_table.first||' tablst='||p_lpn_id_table.last, l_api_name, 4);
  END IF;

  -- Standard Start of API savepoint
  SAVEPOINT Check_Purge_LPN_PVT;

  -- Standard call to check for call compatibility.
  IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
    fnd_message.set_name('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
    fnd_msg_pub.ADD;
    RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF fnd_api.to_boolean(p_init_msg_list) THEN
    fnd_msg_pub.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := fnd_api.g_ret_sts_success;

  l_progress := 'Bulk insert LPNs into temp table for validation';
  FORALL i IN p_lpn_id_table.first .. p_lpn_id_table.last
  INSERT INTO WMS_TXN_CONTEXT_TEMP ( line_id, txn_source_name )
  VALUES ( p_lpn_id_table(i), 'WMS_LPN_PURGE' );

  l_progress := 'Filter out LPNs not valid for purge';
  SELECT lpn_id BULK COLLECT
  INTO   l_valid_lpns
  FROM   WMS_LICENSE_PLATE_NUMBERS wlpn, WMS_TXN_CONTEXT_TEMP wtct
  WHERE  wtct.txn_source_name = 'WMS_LPN_PURGE'
  AND    wlpn.lpn_id = wtct.line_id
  AND    wlpn.lpn_context IN (4, 5)
  AND    NOT EXISTS ( SELECT 1 FROM MTL_TRANSACTIONS_INTERFACE
                      WHERE  lpn_id = wlpn.lpn_id
                      OR     content_lpn_id = wlpn.lpn_id
                      OR     transfer_lpn_id = wlpn.lpn_id )
  AND    NOT EXISTS ( SELECT 1 FROM MTL_MATERIAL_TRANSACTIONS_TEMP
                      WHERE  lpn_id = wlpn.lpn_id
                      OR     content_lpn_id = wlpn.lpn_id
                      OR     transfer_lpn_id = wlpn.lpn_id )
  AND    NOT EXISTS ( SELECT 1 FROM MTL_CYCLE_COUNT_ENTRIES
                      WHERE  wlpn.lpn_context = 5
                      AND    parent_lpn_id = wlpn.lpn_id
                      AND    entry_status_code = 2 )
  AND    NOT EXISTS ( SELECT 1 FROM MTL_ONHAND_QUANTITIES_DETAIL
                      WHERE  lpn_id = wlpn.lpn_id )
  AND    NOT EXISTS ( SELECT 1 FROM WMS_LICENSE_PLATE_NUMBERS
                      WHERE  outermost_lpn_id = wlpn.outermost_lpn_id
                      AND    lpn_context <> wlpn.lpn_context)
  FOR UPDATE;

  l_progress := 'Remove records from wms_txn_context_temp';
  DELETE FROM WMS_TXN_CONTEXT_TEMP
  WHERE  txn_source_name = 'WMS_LPN_PURGE';

  --bug 5150284 if any LPNs did not pass validation, add message to stack
  IF ( p_lpn_id_table.count > l_valid_lpns.count ) THEN
    fnd_message.set_name('WMS', 'WMS_LPN_INELIGIBLE_FOR_PURGE');
    fnd_msg_pub.ADD;
  END IF;

  l_progress := 'Replace LPNS in rec with only valid lpn_ids';
  p_lpn_id_table := l_valid_lpns;

  IF (l_debug = 1) THEN
    inv_trx_util_pub.trace(l_api_name || ' Exit tblcnt='||p_lpn_id_table.last, l_api_name, 4);
  END IF;

  IF ( p_lock_flag <> 'Y' ) THEN
    -- Undo select for update
    ROLLBACK TO Check_Purge_LPN_PVT;
  END IF;

  -- Standard call to get message count and data
  fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    IF (l_debug = 1) THEN
      inv_trx_util_pub.trace(l_api_name ||' Error progress='||l_progress||' SQL error: '|| SQLERRM(SQLCODE), l_api_name, 1);
    END IF;
    ROLLBACK TO Check_Purge_LPN_PVT;
END Check_Purge_LPNs;

PROCEDURE Purge_LPNs (
  p_api_version     IN         NUMBER
, p_init_msg_list   IN         VARCHAR2 := fnd_api.g_false
, p_commit          IN         VARCHAR2 := fnd_api.g_false
, x_return_status   OUT NOCOPY VARCHAR2
, x_msg_count       OUT NOCOPY NUMBER
, x_msg_data        OUT NOCOPY VARCHAR2
, p_caller          IN         VARCHAR2
, p_lpn_id_table    IN         WMS_DATA_TYPE_DEFINITIONS_PUB.NumberTableType
, p_purge_count     IN OUT NOCOPY WMS_DATA_TYPE_DEFINITIONS_PUB.NumberTableType
) IS
l_api_name    CONSTANT VARCHAR2(30)  := 'Purge_LPNs';
l_api_version CONSTANT NUMBER        := 1.0;
l_debug                NUMBER        := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_progress             VARCHAR2(500) := 'Entered API';

BEGIN
  IF (l_debug = 1) THEN
    inv_trx_util_pub.trace(l_api_name || ' Entered ' || g_pkg_version, l_api_name, 4);
    inv_trx_util_pub.trace('ver='||p_api_version||' initmsg='||p_init_msg_list||' commit='||p_commit||' caller='||p_caller||' tabfst='||p_lpn_id_table.first||' tablst='||p_lpn_id_table.last, l_api_name, 4);
  END IF;

  -- Standard Start of API savepoint
  SAVEPOINT PURGE_LPNS_PVT;

  -- Standard call to check for call compatibility.
  IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
    fnd_message.set_name('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
    fnd_msg_pub.ADD;
    RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF fnd_api.to_boolean(p_init_msg_list) THEN
    fnd_msg_pub.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := fnd_api.g_ret_sts_success;

  l_progress := 'Delete from packaging history of all content packages';
  FORALL i IN p_lpn_id_table.first..p_lpn_id_table.last
  DELETE FROM WMS_PACKAGING_HIST
  WHERE  rowid in ( SELECT rowid FROM WMS_PACKAGING_HIST
                    START   WITH parent_lpn_id = p_lpn_id_table(i)
                    CONNECT BY parent_package_id = PRIOR package_id );

  IF ( p_purge_count.exists(1) ) THEN
    p_purge_count(1) := NVL(p_purge_count(1), 0) + SQL%ROWCOUNT;
  ELSE
    p_purge_count(1) := SQL%ROWCOUNT;
  END IF;

  l_progress := 'Delete all history records for that LPN';
  FORALL i IN p_lpn_id_table.first..p_lpn_id_table.last
  DELETE FROM WMS_LPN_HISTORIES
  WHERE  parent_lpn_id = p_lpn_id_table(i)
  OR     lpn_id = p_lpn_id_table(i);

  IF ( p_purge_count.exists(2) ) THEN
    p_purge_count(2) := NVL(p_purge_count(2), 0) + SQL%ROWCOUNT;
  ELSE
    p_purge_count(2) := SQL%ROWCOUNT;
  END IF;

  l_progress := 'Delete all contents for that LPN';
  FORALL i IN p_lpn_id_table.first..p_lpn_id_table.last
  DELETE FROM WMS_LPN_CONTENTS
  WHERE  parent_lpn_id = p_lpn_id_table(i);

  IF ( p_purge_count.exists(3) ) THEN
    p_purge_count(3) := NVL(p_purge_count(3), 0) + SQL%ROWCOUNT;
  ELSE
    p_purge_count(3) := SQL%ROWCOUNT;
  END IF;

  l_progress := 'Delete the LPN itself';
  FORALL i IN p_lpn_id_table.first..p_lpn_id_table.last
  DELETE FROM WMS_LICENSE_PLATE_NUMBERS
  WHERE  lpn_id = p_lpn_id_table(i);

  IF ( p_purge_count.exists(4) ) THEN
    p_purge_count(4) := NVL(p_purge_count(4), 0) + SQL%ROWCOUNT;
  ELSE
    p_purge_count(4) := SQL%ROWCOUNT;
  END IF;

  l_progress := 'Delete the LPN-EPC cross reference';
  FORALL i IN p_lpn_id_table.first..p_lpn_id_table.last
  DELETE FROM WMS_EPC
    WHERE  lpn_id = p_lpn_id_table(i)
    AND cross_ref_type = 1;

  IF ( p_purge_count.exists(5) ) THEN
    p_purge_count(5) := NVL(p_purge_count(5), 0) + SQL%ROWCOUNT;
  ELSE
    p_purge_count(5) := SQL%ROWCOUNT;
  END IF;



EXCEPTION
  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    IF (l_debug = 1) THEN
      inv_trx_util_pub.trace(l_api_name ||' Error progress='||l_progress||' SQL error: '|| SQLERRM(SQLCODE), l_api_name, 1);
    END IF;
    ROLLBACK TO PURGE_LPNS_PVT;
END Purge_LPNs;

PROCEDURE Purge_WMS (
  x_errbuf     OUT NOCOPY VARCHAR2
, x_retcode    OUT NOCOPY NUMBER
, p_purge_date IN         VARCHAR2
, p_orgid      IN         NUMBER
, p_purge_name IN         VARCHAR2
, p_purge_age  IN         NUMBER
, p_purge_type IN         NUMBER
) IS
l_api_name CONSTANT VARCHAR2(30) := 'Purge_WMS';
l_debug             NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_ret               BOOLEAN;
l_date              DATE;

p_level      CONSTANT NUMBER       := 9;
p_module     CONSTANT VARCHAR2(25) := 'WMS_PURGE_PVT.PURGE_WMS';
p_message    VARCHAR2(2000);

l_return_status VARCHAR2(50);
x_msg_count      NUMBER;
x_msg_data       VARCHAR2(2000);

l_max_batch_size  CONSTANT NUMBER := 1000;
l_purge_count     WMS_DATA_TYPE_DEFINITIONS_PUB.NumberTableType;
l_tmp_purge_count WMS_DATA_TYPE_DEFINITIONS_PUB.NumberTableType;
l_lpn_tbl         WMS_DATA_TYPE_DEFINITIONS_PUB.NumberTableType;
l_wsh_lpn_rec     WSH_GLBL_VAR_STRCT_GRP.purgeInOutRecType;

CURSOR LPNS_FOR_PURGE IS
  SELECT lpn_id
  FROM   WMS_LICENSE_PLATE_NUMBERS wlpn
  WHERE  organization_id = p_orgid
  AND    lpn_context IN (4, 5)
  AND    last_update_date < l_date;

BEGIN
  -- Org Id AND (purge date OR purge age) are required for purging.
  IF ((p_purge_date IS NOT NULL OR p_purge_age is not null) AND p_orgid IS NOT NULL) THEN
    IF ( p_purge_age IS NOT NULL AND p_purge_date IS NULL ) THEN
       l_date := sysdate -p_purge_age;
    ELSIF ( p_purge_age IS NULL AND p_purge_date IS NOT NULL ) THEN
       l_date := FND_DATE.canonical_to_date(p_purge_date);
    ELSIF ( p_purge_age IS NOT NULL AND p_purge_date IS NOT NULL ) THEN
       l_date := least(FND_DATE.canonical_to_date(p_purge_date),trunc(sysdate)-p_purge_age);
    END IF;

    FND_MSG_PUB.DELETE_msg;
    IF ( p_purge_type = DEVICE OR p_purge_type IS NULL ) THEN

      delete from wms_device_requests_hist
      where creation_date < l_date and organization_id = p_orgid;
      FND_MESSAGE.SET_NAME('INV','INV_TOTAL_ROWS');
      FND_MESSAGE.SET_TOKEN('ROWS',SQL%ROWCOUNT);
      FND_MESSAGE.SET_TOKEN('TABLE','WMS_DEVICE_REQUESTS_HIST');
      FND_MSG_PUB.ADD;
    END IF;  --Added bug#4415994
    IF ( p_purge_type = LPN OR p_purge_type IS NULL ) THEN
      -- initialize table delete count variables
      l_purge_count(1) := 0; -- WMS_PACKAGING_HIST
      l_purge_count(2) := 0; -- WMS_LPN_HISTORIES
      l_purge_count(3) := 0; -- WMS_LPN_CONTENTS
      l_purge_count(4) := 0; -- WMS_LICENSE_PLATE_NUMBERS
      l_purge_count(5) := 0; -- WMS_EPC

      OPEN LPNS_FOR_PURGE;

      -- Since we limit the number of LPNs to be purged at once, need to loop
      -- until the cursor no longer retrieves any records
      LOOP
        l_lpn_tbl.delete;
        FETCH LPNS_FOR_PURGE BULK COLLECT
        INTO  l_lpn_tbl
        LIMIT l_max_batch_size;

        IF ( l_debug = 1 ) THEN
          inv_trx_util_pub.trace('Fecthed LPNs based on date and context first='||l_lpn_tbl.first||' last='||l_lpn_tbl.last, l_api_name, 4);
        END IF;

        -- If no more LPNs to purge, exit loop, otherwise if there were LPNs deleted
        -- in the previous iteration, commit those
        IF ( NOT l_lpn_tbl.exists(1) ) THEN
          EXIT;
        ELSIF ( l_purge_count(4) > 0 ) THEN
          COMMIT;
        END IF;

        Check_Purge_LPNs (
          p_api_version   => 1.0
        , p_init_msg_list => fnd_api.g_false
        , p_commit        => fnd_api.g_false
        , x_return_status => l_return_status
        , x_msg_count     => x_msg_count
        , x_msg_data      => x_msg_data
        , p_caller        => 'Purge_WMS'
        , p_lock_flag     => 'Y'
        , p_lpn_id_table  => l_lpn_tbl );

        IF ( l_return_status <> fnd_api.g_ret_sts_success ) THEN
          FND_MESSAGE.SET_NAME('INV','INV_API_PURGE_ERROR');
          FND_MESSAGE.SET_TOKEN('API', 'Check_Purge_LPNs');
          FND_MSG_PUB.ADD;
          EXIT;
        ELSIF ( l_debug = 1 ) THEN
          inv_trx_util_pub.trace('WMS validation done first='||l_lpn_tbl.first||' last='||l_lpn_tbl.last, l_api_name, 4);
        END IF;

        IF ( l_lpn_tbl.exists(1) AND NVL(l_lpn_tbl.last, 0) > 0 ) THEN
          -- Call shipping to check if ther LPNs are elegible for purge
          l_wsh_lpn_rec.lpn_ids.delete;

          FOR i IN l_lpn_tbl.first .. l_lpn_tbl.last LOOP
            l_wsh_lpn_rec.lpn_ids(i) := l_lpn_tbl(i);
          END LOOP;

          WSH_WMS_LPN_GRP.Check_purge (
            p_api_version_number => 1.0
          , p_init_msg_list      => fnd_api.g_false
          , p_commit             => fnd_api.g_false
          , x_return_status      => l_return_status
          , x_msg_count          => x_msg_count
          , x_msg_data           => x_msg_data
          , p_lpn_rec            => l_wsh_lpn_rec );

          IF ( l_return_status <> fnd_api.g_ret_sts_success ) THEN
            FND_MESSAGE.SET_NAME('INV','INV_API_PURGE_ERROR');
            FND_MESSAGE.SET_TOKEN('API', 'WSH_WMS_LPN_GRP.Check_purge');
            FND_MSG_PUB.ADD;
            EXIT;
          ELSIF ( l_debug = 1 ) THEN
            inv_trx_util_pub.trace('WSH validation done first='||l_wsh_lpn_rec.lpn_ids.first||' last='||l_wsh_lpn_rec.lpn_ids.last, l_api_name, 4);
          END IF;

          -- Put WSH approved lpn id list back in to lpn_rec type
          l_lpn_tbl.delete;

          IF ( l_wsh_lpn_rec.lpn_ids.exists(1) AND NVL(l_wsh_lpn_rec.lpn_ids.last, 0) > 0 ) THEN
            FOR i IN l_wsh_lpn_rec.lpn_ids.first .. l_wsh_lpn_rec.lpn_ids.last LOOP
              l_lpn_tbl(i) := l_wsh_lpn_rec.lpn_ids(i);
            END LOOP;
          END IF;
        END IF;

        IF ( l_lpn_tbl.exists(1) AND NVL(l_lpn_tbl.last, 0) > 0 ) THEN
          --Store the purge count in case or partial purge failure during delete
          l_tmp_purge_count := l_purge_count;

          Purge_LPNs (
            p_api_version   => 1.0
          , p_init_msg_list => fnd_api.g_false
          , p_commit        => fnd_api.g_false
          , x_return_status => l_return_status
          , x_msg_count     => x_msg_count
          , x_msg_data      => x_msg_data
          , p_caller        => 'Purge_WMS'
          , p_lpn_id_table  => l_lpn_tbl
          , p_purge_count   => l_purge_count );

          IF ( l_return_status <> fnd_api.g_ret_sts_success ) THEN
            l_purge_count := l_tmp_purge_count;
            FND_MESSAGE.SET_NAME('INV','INV_API_PURGE_ERROR');
            FND_MESSAGE.SET_TOKEN('API', 'Purge_LPNs');
            FND_MSG_PUB.ADD;
            EXIT;
          END IF;
        END IF;
      END LOOP;

      CLOSE LPNS_FOR_PURGE;

      FND_MESSAGE.SET_NAME('INV','INV_TOTAL_ROWS');
      FND_MESSAGE.SET_TOKEN('ROWS', l_purge_count(1));
      FND_MESSAGE.SET_TOKEN('TABLE','WMS_PACKAGING_HIST');
      FND_MSG_PUB.ADD;

      FND_MESSAGE.SET_NAME('INV','INV_TOTAL_ROWS');
      FND_MESSAGE.SET_TOKEN('ROWS', l_purge_count(2));
      FND_MESSAGE.SET_TOKEN('TABLE','WMS_LPN_HISTORIES');
      FND_MSG_PUB.ADD;

      FND_MESSAGE.SET_NAME('INV','INV_TOTAL_ROWS');
      FND_MESSAGE.SET_TOKEN('ROWS', l_purge_count(3));
      FND_MESSAGE.SET_TOKEN('TABLE','WMS_LPN_CONTENTS');
      FND_MSG_PUB.ADD;

      FND_MESSAGE.SET_NAME('INV','INV_TOTAL_ROWS');
      FND_MESSAGE.SET_TOKEN('ROWS', l_purge_count(4));
      FND_MESSAGE.SET_TOKEN('TABLE','WMS_LICENSE_PLATE_NUMBERS');
      FND_MSG_PUB.ADD;

       FND_MESSAGE.SET_NAME('INV','INV_TOTAL_ROWS');
      FND_MESSAGE.SET_TOKEN('ROWS', l_purge_count(5));
      FND_MESSAGE.SET_TOKEN('TABLE','WMS_EPC');
      FND_MSG_PUB.ADD;

    END IF; --Added bug#4415994
    IF ( p_purge_type = TASK OR p_purge_type IS NULL ) THEN

      delete from wms_dispatched_tasks_history
      where last_update_date < l_date and organization_id = p_orgid ;
      FND_MESSAGE.SET_NAME('INV','INV_TOTAL_ROWS');
      FND_MESSAGE.SET_TOKEN('ROWS',SQL%ROWCOUNT);
      FND_MESSAGE.SET_TOKEN('TABLE','WMS_DISPATCHED_TASKS_HISTORY');
      FND_MSG_PUB.ADD;

      delete from wms_exceptions
      where creation_date < l_date and organization_id = p_orgid ;
      FND_MESSAGE.SET_NAME('INV','INV_TOTAL_ROWS');
      FND_MESSAGE.SET_TOKEN('ROWS',SQL%ROWCOUNT);
      FND_MESSAGE.SET_TOKEN('TABLE','WMS_EXCEPTIONS');
      FND_MSG_PUB.ADD;
    END IF; --Added bug#4415994
    IF ( p_purge_type = LABEL OR p_purge_type IS NULL ) THEN

      delete WMS_LABEL_REQUESTS_HIST
      where  creation_date < l_date and organization_id = p_orgid;
      FND_MESSAGE.SET_NAME('INV','INV_TOTAL_ROWS');
      FND_MESSAGE.SET_TOKEN('ROWS',SQL%ROWCOUNT);
      FND_MESSAGE.SET_TOKEN('TABLE','WMS_LABEL_REQUESTS_HIST');
      FND_MSG_PUB.ADD;

    END IF;

    IF ( p_purge_type = EPC OR p_purge_type IS NULL ) THEN

       delete wms_epc we
	 where  creation_date < sysdate --No organization is here
	 AND  EXISTS ( SELECT 1 FROM wms_license_plate_numbers wlpn
		       WHERE wlpn.lpn_id  = we.lpn_id
		       AND   we.cross_ref_type = 1  --LPN-EPC
		       AND   wlpn.lpn_context = 4 )
	 OR EXISTS ( SELECT 1 FROM  mtl_serial_numbers msn
		     WHERE msn.inventory_item_id = we.inventory_item_id
		     AND   msn.serial_number = we.serial_number
		     AND   we.cross_ref_type = 2 --Serial-EPC
		     AND   msn.current_status = 4 ); --Issue out of store

       FND_MESSAGE.SET_NAME('INV','INV_TOTAL_ROWS');
       FND_MESSAGE.SET_TOKEN('ROWS',SQL%ROWCOUNT);
       FND_MESSAGE.SET_TOKEN('TABLE','WMS_EPC');
       FND_MSG_PUB.ADD;

    END IF;


    INSERT INTO mtl_purge_header (
      purge_id
    , last_update_date
    , last_updated_by
    , last_update_login
    , creation_date
    , created_by
    , purge_date
    , archive_flag
    , purge_name
    , organization_id )
    VALUES (
      mtl_material_transactions_s.NEXTVAL
    , SYSDATE
    , FND_GLOBAL.user_id
    , fnd_global.user_id
    , SYSDATE
    , FND_GLOBAL.user_id
    , l_date
    , NULL
    , p_purge_name
    , p_orgid );

    FND_MSG_PUB.COUNT_AND_GET (
      p_count => x_msg_count
    , p_data  => x_msg_data );

    FOR i in 1..x_msg_count LOOP
      p_message := fnd_msg_pub.get(i,'F');
      IF (l_debug = 1) THEN
         INV_TRX_UTIL_PUB.TRACE (
           p_mesg  => p_message
         , p_mod   => p_module
         , p_level => p_level );
      END IF;
    END LOOP;

    fnd_msg_pub.delete_msg;

    COMMIT;

    l_ret     := fnd_concurrent.set_completion_status('NORMAL', 'WMS_PURGE_SUCCESS');
    x_retcode := 0;
  ELSE
    l_ret     := fnd_concurrent.set_completion_status('ERROR', 'WMS_MISS_REQ_PARAMETER');
    x_retcode := 2;
    x_errbuf  := 'ERROR';
  END IF;
END Purge_WMS;

END WMS_PURGE_PVT;

/
