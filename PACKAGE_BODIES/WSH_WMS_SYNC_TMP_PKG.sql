--------------------------------------------------------
--  DDL for Package Body WSH_WMS_SYNC_TMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_WMS_SYNC_TMP_PKG" AS
/* $Header: WSHWSYTB.pls 120.1 2005/11/15 13:42:31 bsadri noship $ */


  --
  --
  --
  --
  --
  G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_WMS_SYNC_TMP_PKG';
  --
  PROCEDURE MERGE
  (
    p_sync_tmp_rec      IN          wsh_glbl_var_strct_grp.sync_tmp_rec_type,
    x_return_status     OUT NOCOPY  VARCHAR2
  )
  IS
  --{
      --
      l_debug_on BOOLEAN;
      --
      l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'MERGE';
      --
      cursor l_sync_tmp_rec_csr (p_del_det_id IN NUMBER,
                                 p_opn_type IN VARCHAR2,
                                 l_hw_date  IN DATE) is
      select 'X'
      from   wsh_wms_sync_tmp
      WHERE  delivery_detail_id = p_del_det_id
      AND    operation_type= p_opn_type
      AND    creation_date = l_hw_date;

      l_rec_exists VARCHAR2(10);
  --}
  BEGIN
  --{
      --
      l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
      --
      IF l_debug_on IS NULL
      THEN
          l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
      END IF;
      --
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.push(l_module_name);
          WSH_DEBUG_SV.log(l_module_name,  'Delivery Detail Id', p_sync_tmp_rec.delivery_detail_id);
          WSH_DEBUG_SV.log(l_module_name,  'Delivery Id', p_sync_tmp_rec.delivery_id);
          WSH_DEBUG_SV.log(l_module_name,  'Parent Delivery Detail Id', p_sync_tmp_rec.parent_delivery_detail_id);
          WSH_DEBUG_SV.log(l_module_name,  'Operation Type', p_sync_tmp_rec.operation_type);
          WSH_DEBUG_SV.log(l_module_name,  'WSH_WMS_LPN_GRP.G_HW_TIME_STAMP', WSH_WMS_LPN_GRP.G_HW_TIME_STAMP);

      END IF;
      --
      SAVEPOINT WSH_WMS_SYNC_TMP_PKG_MERGE;
      --
      x_return_status := wsh_util_core.g_ret_sts_success;

      IF (WSH_WMS_LPN_GRP.G_HW_TIME_STAMP IS NULL) THEN
        WSH_WMS_LPN_GRP.G_HW_TIME_STAMP := sysdate;
      END IF;
      --
      IF (p_sync_tmp_rec.operation_type IN ('UPDATE', 'PRIOR')) THEN
      --{
          --
          /*
          MERGE INTO WSH_WMS_SYNC_TMP T
          USING (SELECT delivery_detail_id
                 FROM   WSH_WMS_SYNC_TMP
                 WHERE  delivery_detail_id = p_sync_tmp_rec.delivery_detail_id
                 AND    operation_type= p_sync_tmp_rec.operation_type
                 AND    creation_date > WSH_WMS_LPN_GRP.G_HW_TIME_STAMP) S
          ON (T.delivery_detail_id = S.delivery_detail_id)
          WHEN MATCHED THEN
          UPDATE
          SET T.temp_col = null
          WHEN NOT MATCHED THEN
          INSERT (T.delivery_detail_id,
                  T.parent_delivery_detail_id,
                  T.delivery_id,
                  T.operation_type,
                  T.creation_date)
          VALUES (p_sync_tmp_rec.delivery_detail_id,
                  p_sync_tmp_rec.parent_delivery_detail_id,
                  p_sync_tmp_rec.delivery_id,
                  p_sync_tmp_rec.operation_type,
                  sysdate);
          */
          -- The above stmt does not work.  Therefore, using the following logic.
          open l_sync_tmp_rec_csr(p_sync_tmp_rec.delivery_detail_id,
                                  p_sync_tmp_rec.operation_type,
                                  WSH_WMS_LPN_GRP.G_HW_TIME_STAMP);
          fetch l_sync_tmp_rec_csr into l_rec_exists;
          close l_sync_tmp_rec_csr;

          IF (l_rec_exists is null) THEN
            insert into WSH_WMS_SYNC_TMP
                   (delivery_detail_id,
                    parent_delivery_detail_id,
                    delivery_id,
                    operation_type,
                    creation_date,
                    call_level)
            values (p_sync_tmp_rec.delivery_detail_id,
                    p_sync_tmp_rec.parent_delivery_detail_id,
                    p_sync_tmp_rec.delivery_id,
                    p_sync_tmp_rec.operation_type,
                    WSH_WMS_LPN_GRP.G_HW_TIME_STAMP,
                    p_sync_tmp_rec.call_level);

            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,  'INSERTED '||SQL%ROWCOUNT||' RECORDS IN WSH_WMS_SYNC_TMP'  );
            END IF;
          END IF;
          --
          --
      --}
      ELSE
      --{
          --
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,  'Invalid Operation Type', p_sync_tmp_rec.operation_type);
          END IF;
          x_return_status := wsh_util_core.g_ret_sts_error;
          --
      --}
      END IF;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
  --}
  EXCEPTION
  --{
      --
      WHEN OTHERS THEN
        ROLLBACK TO WSH_WMS_SYNC_TMP_PKG_MERGE;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
        wsh_util_core.default_handler('WSH_WMS_SYNC_TMP_PKG.MERGE',l_module_name);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
  --}
  END MERGE;
  --
  --
  PROCEDURE MERGE_BULK
  (
    p_sync_tmp_recTbl   IN          wsh_glbl_var_strct_grp.sync_tmp_recTbl_type,
    x_return_status     OUT NOCOPY  VARCHAR2,
    p_operation_type    IN          VARCHAR2
  )
  IS
  --{
      l_operation_type WSH_WMS_SYNC_TMP.OPERATION_TYPE%TYPE;
      l_first NUMBER;
      l_last  NUMBER;

      l_sync_tmp_recTbl wsh_glbl_var_strct_grp.sync_tmp_recTbl_type;
      l_tbl_cnt NUMBER;
      l_del_tbl_cnt NUMBER;
      l_call_tbl_cnt NUMBER;
      --
      cursor l_sync_tmp_rec_csr (p_del_det_id IN NUMBER,
                                 p_opn_type IN VARCHAR2,
                                 l_hw_date  IN DATE) is
      select 'X'
      from   wsh_wms_sync_tmp
      WHERE  delivery_detail_id = p_del_det_id
      AND    operation_type= p_opn_type
      AND    creation_date = l_hw_date;

      l_rec_exists VARCHAR2(10);
      --
      l_debug_on BOOLEAN;
      --
      l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'MERGE_BULK';
      --
  --}
  BEGIN
  --{
      --
      l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
      --
      IF l_debug_on IS NULL
      THEN
          l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
      END IF;
      --
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.push(l_module_name);
          WSH_DEBUG_SV.log(l_module_name,  'Input operation type', p_operation_type);
          WSH_DEBUG_SV.log(l_module_name,  'Count of Input Table ', p_sync_tmp_recTbl.delivery_detail_id_tbl.count);
          WSH_DEBUG_SV.log(l_module_name,  'WSH_WMS_LPN_GRP.G_HW_TIME_STAMP', WSH_WMS_LPN_GRP.G_HW_TIME_STAMP);
      END IF;
      --
      SAVEPOINT WSH_WMS_SYNC_TMP_PKG_MRG_BULK;
      --
      x_return_status := wsh_util_core.g_ret_sts_success;
      l_first := p_sync_tmp_recTbl.delivery_detail_id_tbl.first;
      l_last := p_sync_tmp_recTbl.delivery_detail_id_tbl.last;
      l_operation_type := nvl(p_operation_type,p_sync_tmp_recTbl.operation_type_tbl(l_first));
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,  'operation type', l_operation_type);
      END IF;

      IF (WSH_WMS_LPN_GRP.G_HW_TIME_STAMP IS NULL) THEN
        WSH_WMS_LPN_GRP.G_HW_TIME_STAMP := sysdate;
      END IF;
      /*
      IF (l_operation_type = 'UPDATE') THEN
      --{
          FORALL i in l_first..l_last
          MERGE into WSH_WMS_SYNC_TMP T
          USING ( SELECT delivery_detail_id
               FROM   WSH_WMS_SYNC_TMP
               WHERE  delivery_detail_id = p_sync_tmp_recTbl.delivery_detail_id_tbl(i)
               AND    operation_type= p_sync_tmp_recTbl.operation_type_tbl(i)
               AND    creation_date > WSH_WMS_LPN_GRP.G_HW_TIME_STAMP) S
          on (T.delivery_detail_id = S.delivery_detail_id)
          WHEN MATCHED THEN
          UPDATE
          SET T.temp_col = null
          WHEN NOT MATCHED THEN
          INSERT (T.delivery_detail_id,
                  T.parent_delivery_detail_id,
                  T.delivery_id,
                  T.operation_type,
                  T.creation_date)
          VALUES (p_sync_tmp_recTbl.delivery_detail_id_tbl(i),
                  NULL,
                  NULL,
                  l_operation_type,
                  sysdate);
          --
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,  'MERGED '||SQL%ROWCOUNT||' RECORDS IN WSH_WMS_SYNC_TMP - 1'  );
          END IF;
          --
      --}
      ELSIF (l_operation_type = 'PRIOR') THEN
      --{
          FORALL i in l_first..l_last
          MERGE into WSH_WMS_SYNC_TMP T
          USING ( SELECT delivery_detail_id
               FROM   WSH_WMS_SYNC_TMP
               WHERE  delivery_detail_id = p_sync_tmp_recTbl.delivery_detail_id_tbl(i)
               AND    operation_type= p_sync_tmp_recTbl.operation_type_tbl(i)
               AND    creation_date > WSH_WMS_LPN_GRP.G_HW_TIME_STAMP) S
          on (T.delivery_detail_id = S.delivery_detail_id)
          WHEN MATCHED THEN
          UPDATE
          SET T.temp_col = null
          WHEN NOT MATCHED THEN
          INSERT (T.delivery_detail_id,
                  T.parent_delivery_detail_id,
                  T.delivery_id,
                  T.operation_type,
                  T.creation_date)
          VALUES (p_sync_tmp_recTbl.delivery_detail_id_tbl(i),
                  p_sync_tmp_recTbl.parent_detail_id_tbl(i),
                  p_sync_tmp_recTbl.delivery_id_tbl(i),
                  l_operation_type,
                  sysdate);
          --
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,  'MERGED '||SQL%ROWCOUNT||' RECORDS IN WSH_WMS_SYNC_TMP - 2'  );
          END IF;
          --
      --}
      ELSE
      --{
          --
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,  'Invalid Operation Type', l_operation_type);
          END IF;
          x_return_status := wsh_util_core.g_ret_sts_error;
          --
      --}
      END IF;
      */
      --
      l_tbl_cnt := 1;
      l_del_tbl_cnt := p_sync_tmp_recTbl.delivery_id_tbl.count;
      --
      l_call_tbl_cnt := p_sync_tmp_recTbl.call_level.COUNT;

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,  'l_del_tbl_cnt', l_del_tbl_cnt);
        WSH_DEBUG_SV.log(l_module_name,  'l_call_tbl_cnt', l_call_tbl_cnt);
      END IF;
      --

      FOR i in l_first..l_last LOOP
      --{
          -- The above stmt does not work.  Therefore, using the following logic.
          open l_sync_tmp_rec_csr(p_sync_tmp_recTbl.delivery_detail_id_tbl(i),
                                  l_operation_type,
                                  WSH_WMS_LPN_GRP.G_HW_TIME_STAMP);
          fetch l_sync_tmp_rec_csr into l_rec_exists;
          close l_sync_tmp_rec_csr;

          IF (l_rec_exists is null) THEN
            --
            l_sync_tmp_recTbl.delivery_detail_id_tbl(l_tbl_cnt) := p_sync_tmp_recTbl.delivery_detail_id_tbl(i);
            IF l_call_tbl_cnt = 0 THEN
               l_sync_tmp_recTbl.call_level(l_tbl_cnt) := NULL;
            ELSE
               l_sync_tmp_recTbl.call_level(l_tbl_cnt) := p_sync_tmp_recTbl.call_level(i);
            END IF;

            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,  'call_level', l_sync_tmp_recTbl.call_level(l_tbl_cnt));
            END IF;

            IF (l_del_tbl_cnt >0) THEN
              l_sync_tmp_recTbl.delivery_id_tbl(l_tbl_cnt) := p_sync_tmp_recTbl.delivery_id_tbl(i);
              l_sync_tmp_recTbl.parent_detail_id_tbl(l_tbl_cnt) := p_sync_tmp_recTbl.parent_detail_id_tbl(i);

            END IF;
            l_tbl_cnt := l_tbl_cnt + 1;
            --
          ELSE
            --
            l_rec_exists := NULL;
            --
          END IF;
      --}
      END LOOP;

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,  'count of l_sync_tmp_recTbl is ',l_sync_tmp_recTbl.delivery_detail_id_tbl.count);
      END IF;
      IF (l_sync_tmp_recTbl.delivery_detail_id_tbl.count > 0) THEN
      --{
          IF (l_operation_type = 'PRIOR') THEN
            --
            FORALL i in l_sync_tmp_recTbl.delivery_detail_id_tbl.first..l_sync_tmp_recTbl.delivery_detail_id_tbl.last
            insert into WSH_WMS_SYNC_TMP
                   (delivery_detail_id,
                    parent_delivery_detail_id,
                    delivery_id,
                    operation_type,
                    creation_date)
            VALUES (l_sync_tmp_recTbl.delivery_detail_id_tbl(i),
                    l_sync_tmp_recTbl.parent_detail_id_tbl(i),
                    l_sync_tmp_recTbl.delivery_id_tbl(i),
                    l_operation_type,
                    WSH_WMS_LPN_GRP.G_HW_TIME_STAMP);
            --
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,  'INSERTED '||SQL%ROWCOUNT||' RECORDS IN WSH_WMS_SYNC_TMP - 1'  );
            END IF;
            --
          ELSIF (l_operation_type = 'UPDATE') THEN
            --
            FORALL i in l_sync_tmp_recTbl.delivery_detail_id_tbl.first..l_sync_tmp_recTbl.delivery_detail_id_tbl.last
            insert into WSH_WMS_SYNC_TMP
                   (delivery_detail_id,
                    parent_delivery_detail_id,
                    delivery_id,
                    operation_type,
                    creation_date,
                    call_level)
            VALUES (l_sync_tmp_recTbl.delivery_detail_id_tbl(i),
                    NULL,
                    NULL,
                    l_operation_type,
                    WSH_WMS_LPN_GRP.G_HW_TIME_STAMP,
                    l_sync_tmp_recTbl.call_level(i));
            --
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,  'INSERTED '||SQL%ROWCOUNT||' RECORDS IN WSH_WMS_SYNC_TMP - 1'  );
            END IF;
            --
          ELSE
            --
            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,  'Invalid Operation Type', l_operation_type);
            END IF;
            x_return_status := wsh_util_core.g_ret_sts_error;
            --
          END IF;
      --}
      END IF;
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
  --}
  --
  EXCEPTION
  --{
      --
      WHEN OTHERS THEN
      --
      ROLLBACK TO WSH_WMS_SYNC_TMP_PKG_MRG_BULK;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
        wsh_util_core.default_handler('WSH_WMS_SYNC_TMP_PKG.MERGE',l_module_name);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
  --}
  END MERGE_BULK;

  --

END WSH_WMS_SYNC_TMP_PKG;

/
