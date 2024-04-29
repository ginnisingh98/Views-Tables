--------------------------------------------------------
--  DDL for Package Body WSH_INBOUND_TXN_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_INBOUND_TXN_HISTORY_PKG" as
/* $Header: WSHIBTXB.pls 120.0 2005/05/26 18:03:27 appldev noship $ */


  --
  G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_INBOUND_TXN_HISTORY_PKG';
  --
--===================
-- PROCEDURES
--===================

  PROCEDURE create_txn_history_bulk
              (
                x_inboundTxnHistory_recTbl  IN OUT NOCOPY  inboundTxnHistory_recTbl_type,
                x_return_status             OUT NOCOPY  VARCHAR2
              )
  IS
  --{
    l_param_name VARCHAR2(150);
    l_index      NUMBER;
    l_inputCount     NUMBER;
    l_resultCount     NUMBER;
  --}
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_TXN_HISTORY_BULK';
  --
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
    l_inputCount := x_inboundTxnHistory_recTbl.transaction_type.COUNT;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        WSH_DEBUG_SV.log(l_module_name,'l_inputCount',l_inputCount);
    END IF;
    --
    x_return_status := wsh_util_core.g_ret_sts_success;
    --
    --
    l_index := x_inboundTxnHistory_recTbl.transaction_type.FIRST;
    --
    WHILE l_index IS NOT NULL
    LOOP
    --{
        IF (x_inboundTxnHistory_recTbl.transaction_type(l_index) is null) THEN
          l_param_name := 'x_inboundTxnHistory_recTbl.transaction_type' || '(' || l_index || ')';
        ELSIF x_inboundTxnHistory_recTbl.transaction_type(l_index) <> 'ROUTING_REQUEST'
        AND x_inboundTxnHistory_recTbl.shipment_header_id(l_index) IS NULL  THEN
          l_param_name := 'x_inboundTxnHistory_recTbl.shipment_header_id' || '(' || l_index || ')';
        ELSIF x_inboundTxnHistory_recTbl.status(l_index) IS NULL  THEN
          l_param_name := 'x_inboundTxnHistory_recTbl.status' || '(' || l_index || ')';
        ELSIF x_inboundTxnHistory_recTbl.transaction_type(l_index) IN ('ASN', 'CANCEL_ASN') THEN
          IF x_inboundTxnHistory_recTbl.shipment_number(l_index) IS NULL THEN
            l_param_name := 'x_inboundTxnHistory_recTbl.shipment_number' || '(' || l_index || ')';
          END IF;
        ELSIF x_inboundTxnHistory_recTbl.transaction_type(l_index) IN (
                                                      'RECEIPT',
                                                      'RECEIPT_CORRECTION', 'RECEIPT_CORRECTION_POSITIVE','RECEIPT_CORRECTION_NEGATIVE',
                                                      'RTV' ,
                                                      'RTV_CORRECTION','RTV_CORRECTION_POSITIVE','RTV_CORRECTION_NEGATIVE'
                                                    )
        THEN
          IF x_inboundTxnHistory_recTbl.receipt_number(l_index) IS NULL THEN
            l_param_name := 'x_inboundTxnHistory_recTbl.receipt_number' || '(' || l_index || ')';
          END IF;
        END IF;

        IF l_param_name is not null THEN
          FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
          FND_MESSAGE.SET_TOKEN('FIELD_NAME',l_param_name);
          x_return_status := wsh_util_core.g_ret_sts_error;
          wsh_util_core.add_message(x_return_status,l_module_name);
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        --
        --
        l_index := x_inboundTxnHistory_recTbl.transaction_type.NEXT(l_index);
    --}
    END LOOP;
    --select wsh_inbound_txn_history_s.nextval into l_txn_id from dual;
    --l_txn_id := wsh_inbound_txn_history_s.nextval;

    FORALL i IN x_inboundTxnHistory_recTbl.transaction_type.FIRST..x_inboundTxnHistory_recTbl.transaction_type.LAST
    insert into wsh_inbound_txn_history
        (TRANSACTION_ID,
         RECEIPT_NUMBER,
         REVISION_NUMBER,
         SHIPMENT_NUMBER,
         TRANSACTION_TYPE,
         SHIPMENT_HEADER_ID,
         PARENT_SHIPMENT_HEADER_ID,
         ORGANIZATION_ID,
         SUPPLIER_ID,
         SHIPPED_DATE,
         RECEIPT_DATE,
         STATUS,
         MAX_RCV_TRANSACTION_ID,
         CARRIER_ID,
         MATCH_REVERTED_BY,
         MATCHED_BY,
         SHIPMENT_LINE_ID,
         OBJECT_VERSION_NUMBER,
	 SHIP_FROM_LOCATION_ID,-- IB-Phase-2
         LAST_UPDATE_DATE,
   LAST_UPDATED_BY,
   CREATION_DATE,
   CREATED_BY,
         LAST_UPDATE_LOGIN)
    values(wsh_inbound_txn_history_s.nextval,
         x_inboundTxnHistory_recTbl.RECEIPT_NUMBER(i),
         x_inboundTxnHistory_recTbl.REVISION_NUMBER(i),
         x_inboundTxnHistory_recTbl.SHIPMENT_NUMBER(i),
         x_inboundTxnHistory_recTbl.TRANSACTION_TYPE(i),
         x_inboundTxnHistory_recTbl.SHIPMENT_HEADER_ID(i),
         x_inboundTxnHistory_recTbl.PARENT_SHIPMENT_HEADER_ID(i),
         x_inboundTxnHistory_recTbl.ORGANIZATION_ID(i),
         x_inboundTxnHistory_recTbl.SUPPLIER_ID(i),
         x_inboundTxnHistory_recTbl.SHIPPED_DATE(i),
         x_inboundTxnHistory_recTbl.RECEIPT_DATE(i),
         x_inboundTxnHistory_recTbl.STATUS(i),
         x_inboundTxnHistory_recTbl.MAX_RCV_TRANSACTION_ID(i),
         x_inboundTxnHistory_recTbl.CARRIER_ID(i),
         x_inboundTxnHistory_recTbl.MATCH_REVERTED_BY(i),
         x_inboundTxnHistory_recTbl.MATCHED_BY(i),
         x_inboundTxnHistory_recTbl.SHIPMENT_LINE_ID(i),
         1,
	 x_inboundTxnHistory_recTbl.SHIP_FROM_LOCATION_ID(i),-- IB-Phase-2
         SYSDATE,
         FND_GLOBAL.USER_ID,
         SYSDATE,
         FND_GLOBAL.USER_ID,
         FND_GLOBAL.LOGIN_ID)
         RETURNING transaction_id BULK COLLECT INTO x_inboundTxnHistory_recTbl.TRANSACTION_ID;
     --
     --
     l_resultCount := SQL%ROWCOUNT;
     --
     IF l_resultCount <> l_inputCount
     THEN
     --{
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'l_resultCount',l_resultCount);
          END IF;
          --
          FND_MESSAGE.SET_NAME('WSH','WSH_IB_TXN_BULK_INSERT_ERROR');
          wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
          RAISE FND_API.G_EXC_ERROR;
     --}
     END IF;
  --}
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  EXCEPTION
  --{
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      --
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_INBOUND_TXN_HISTORY_PKG.create_txn_history_bulk');
  --}
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
  END IF;
  --
  END create_txn_history_bulk;


  PROCEDURE autonomous_Create_bulk
	    (
                x_inboundTxnHistory_recTbl  IN OUT NOCOPY  inboundTxnHistory_recTbl_type,
                x_return_status             OUT NOCOPY  VARCHAR2
            )
  IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  --{
      l_num_warnings  NUMBER := 0;
      l_num_errors    NUMBER := 0;
      l_return_status VARCHAR2(30);
  --}
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'AUTONOMOUS_CREATE_bulk';
  --
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
    END IF;
    --
    x_return_status := wsh_util_core.g_ret_sts_success;
    --
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit create_txn_history_bulk',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    create_txn_history_bulk
      (
        x_inboundTxnHistory_recTbl => x_inboundTxnHistory_recTbl,
        x_return_status            => l_return_status
      );
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
    END IF;
    --
    wsh_util_core.api_post_call
      (
        p_return_status => l_return_status,
        x_num_warnings  => l_num_warnings,
        x_num_errors    => l_num_errors
      );
    --
    COMMIT;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,
                            'Number of Errors='||l_num_errors||',Number of Warnings='||l_num_warnings);
    END IF;
    --
    IF l_num_errors > 0
    THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    ELSIF l_num_warnings > 0
    THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    ELSE
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    END IF;
    --
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
  --}
  EXCEPTION
  --{
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      COMMIT;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      --
    WHEN OTHERS THEN
      ROLLBACK;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_INBOUND_TXN_HISTORY_PKG.AUTONOMOUS_CREATE_bulk');
  --}
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
  END IF;
  --
  END autonomous_Create_bulk;

--========================================================================
-- PROCEDURE : Create_Txn_History     This procedure is used to create
--                                    a record in the wsh_inbound_txn_history
--                                    table
--
-- PARAMETERS: p_txn_history_rec       This is of type ib_txn_history_rec_type.
--             x_txn_id                Transacion Id returned by the API
--                                     after inserting a record into
--                                     wsh_inbound_txn_history.
--             x_return_status         return status of the API.

-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This procedure is used to create a record in the
--             wsh_inbound_txn_history table.
--             The following are the valid transaction types -
--             ASN, RECEIPT, RECEIPT_ADD, RECEIPT_CORRECTION_NEGATIVE,
--             RECEIPT_CORRECTION_POSITIVE, ROUTING_REQUEST,
--             ROUTING_RESPONSE, RTV, RECEIPT_CORRECTION, RTV_CORRECTION,
--             CANCEL_ASN, RTV_CORRECTION_POSITIVE,RTV_CORRECTION_NEGATIVE,
--             RECEIPT_HEADER_UPD.
--========================================================================
  PROCEDURE create_txn_history (
              p_txn_history_rec IN ib_txn_history_rec_type,
              x_txn_id                OUT NOCOPY NUMBER,
              x_return_status      OUT NOCOPY VARCHAR2
            )
  IS
  --{
    l_param_name VARCHAR2(32767);
    l_txn_id     NUMBER;
  --}
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_TXN_HISTORY';
  --
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
    END IF;
    --
    x_return_status := wsh_util_core.g_ret_sts_success;

    -- This to verify all the mandatory input parameters for each transaction
    -- type.
    IF (p_txn_history_rec.transaction_type is null) THEN
      l_param_name := 'p_txn_history_rec.transaction_type';
    ELSIF p_txn_history_rec.transaction_type <> 'ROUTING_REQUEST'
    AND p_txn_history_rec.shipment_header_id IS NULL  THEN
      l_param_name := 'p_txn_history_rec.shipment_header_id';
    ELSIF p_txn_history_rec.status IS NULL  THEN
      l_param_name := 'p_txn_history_rec.status';
    ELSIF p_txn_history_rec.transaction_type IN ('ASN', 'CANCEL_ASN') THEN
      IF p_txn_history_rec.shipment_number IS NULL THEN
        l_param_name := 'p_txn_history_rec.shipment_number';
      END IF;
    ELSIF p_txn_history_rec.transaction_type IN (
                                                  'RECEIPT',
                                                  'RECEIPT_CORRECTION', 'RECEIPT_CORRECTION_POSITIVE','RECEIPT_CORRECTION_NEGATIVE',
                                                  'RTV' ,
                                                  'RTV_CORRECTION','RTV_CORRECTION_POSITIVE','RTV_CORRECTION_NEGATIVE'
                                                )
    THEN
      IF p_txn_history_rec.receipt_number IS NULL THEN
        l_param_name := 'p_txn_history_rec.receipt_number';
      END IF;
    END IF;

    IF l_param_name is not null THEN
      FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
      FND_MESSAGE.SET_TOKEN('FIELD_NAME',l_param_name);
      x_return_status := wsh_util_core.g_ret_sts_error;
      wsh_util_core.add_message(x_return_status,l_module_name);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --select wsh_inbound_txn_history_s.nextval into l_txn_id from dual;
    --l_txn_id := wsh_inbound_txn_history_s.nextval;

    insert into wsh_inbound_txn_history
        (TRANSACTION_ID,
         RECEIPT_NUMBER,
         REVISION_NUMBER,
         SHIPMENT_NUMBER,
         TRANSACTION_TYPE,
         SHIPMENT_HEADER_ID,
         PARENT_SHIPMENT_HEADER_ID,
         ORGANIZATION_ID,
         SUPPLIER_ID,
         SHIPPED_DATE,
         RECEIPT_DATE,
         STATUS,
         MAX_RCV_TRANSACTION_ID,
         CARRIER_ID,
         MATCH_REVERTED_BY,
         MATCHED_BY,
         SHIPMENT_LINE_ID,
         OBJECT_VERSION_NUMBER,
	 SHIP_FROM_LOCATION_ID, -- IB-Phase-2
         LAST_UPDATE_DATE,
	 LAST_UPDATED_BY,
	 CREATION_DATE,
	 CREATED_BY,
         LAST_UPDATE_LOGIN)
    values(wsh_inbound_txn_history_s.nextval,
         p_txn_history_rec.RECEIPT_NUMBER,
         p_txn_history_rec.REVISION_NUMBER,
         p_txn_history_rec.SHIPMENT_NUMBER,
         p_txn_history_rec.TRANSACTION_TYPE,
         p_txn_history_rec.SHIPMENT_HEADER_ID,
         p_txn_history_rec.PARENT_SHIPMENT_HEADER_ID,
         p_txn_history_rec.ORGANIZATION_ID,
         p_txn_history_rec.SUPPLIER_ID,
         p_txn_history_rec.SHIPPED_DATE,
         p_txn_history_rec.RECEIPT_DATE,
         p_txn_history_rec.STATUS,
         p_txn_history_rec.MAX_RCV_TRANSACTION_ID,
         p_txn_history_rec.CARRIER_ID,
         p_txn_history_rec.MATCH_REVERTED_BY,
         p_txn_history_rec.MATCHED_BY,
         p_txn_history_rec.SHIPMENT_LINE_ID,
         1,
	 p_txn_history_rec.SHIP_FROM_LOCATION_ID, -- IB-Phase-2
         SYSDATE,
	 FND_GLOBAL.USER_ID,
	 SYSDATE,
	 FND_GLOBAL.USER_ID,
         FND_GLOBAL.LOGIN_ID)
         RETURNING transaction_id into x_txn_id;
  --}
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  EXCEPTION
  --{
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      --
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_INBOUND_TXN_HISTORY_PKG.CREATE_TXN_HISTORY');
  --}
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
  END IF;
  --
  END create_txn_history;

  PROCEDURE autonomous_Create (
              p_txn_history_rec IN ib_txn_history_rec_type,
              x_txn_id                OUT NOCOPY NUMBER,
              x_return_status      OUT NOCOPY VARCHAR2
            )
  IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  --{
      l_num_warnings  NUMBER := 0;
      l_num_errors    NUMBER := 0;
      l_return_status VARCHAR2(30);
  --}
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'AUTONOMOUS_CREATE';
  --
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
    END IF;
    --
    x_return_status := wsh_util_core.g_ret_sts_success;
    --
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit create_txn_history',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    create_txn_history
      (
        p_txn_history_rec => p_txn_history_rec,
        x_txn_id          => x_txn_id,
        x_return_status   => l_return_status
      );
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
    END IF;
    --
    wsh_util_core.api_post_call
      (
        p_return_status => l_return_status,
        x_num_warnings  => l_num_warnings,
        x_num_errors    => l_num_errors
      );
    --
    COMMIT;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,
                            'Number of Errors='||l_num_errors||',Number of Warnings='||l_num_warnings);
    END IF;
    --
    IF l_num_errors > 0
    THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    ELSIF l_num_warnings > 0
    THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    ELSE
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    END IF;
    --
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
  --}
  EXCEPTION
  --{
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      COMMIT;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      --
    WHEN OTHERS THEN
      ROLLBACK;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_INBOUND_TXN_HISTORY_PKG.AUTONOMOUS_CREATE');
  --}
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
  END IF;
  --
  END autonomous_Create;

--========================================================================
-- PROCEDURE : Update_Txn_History     This procedure is used to update
--                                    a record in the wsh_inbound_txn_history
--                                    table
--
-- PARAMETERS: p_txn_history_rec       This is of type ib_txn_history_rec_type.
--             x_return_status         return status of the API.

-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This procedure is used to a update a record (all the attributes)
--             in the wsh_inbound_txn_history table.
--========================================================================
  PROCEDURE update_txn_history (
              p_txn_history_rec IN ib_txn_history_rec_type,
              x_return_status      OUT NOCOPY VARCHAR2
            )
  IS
  --{
  --}
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_TXN_HISTORY';
  --
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
    END IF;
    --
    x_return_status := wsh_util_core.g_ret_sts_success;
    update wsh_inbound_txn_history
    set  RECEIPT_NUMBER               = DECODE
                                          (
                                            p_txn_history_rec.RECEIPT_NUMBER,
                                            FND_API.G_MISS_CHAR,NULL,
                                            NULL,RECEIPT_NUMBER,
                                            p_txn_history_rec.RECEIPT_NUMBER),
         REVISION_NUMBER              = DECODE
                                          (
                                            p_txn_history_rec.REVISION_NUMBER,
                                            FND_API.G_MISS_CHAR,NULL,
                                            NULL,REVISION_NUMBER,
                                            p_txn_history_rec.REVISION_NUMBER),
         SHIPMENT_NUMBER              = DECODE
                                          (
                                            p_txn_history_rec.SHIPMENT_NUMBER,
                                            FND_API.G_MISS_CHAR,NULL,
                                            NULL,SHIPMENT_NUMBER,
                                            p_txn_history_rec.SHIPMENT_NUMBER),
         TRANSACTION_TYPE             = DECODE
                                          (
                                            p_txn_history_rec.TRANSACTION_TYPE,
                                            FND_API.G_MISS_CHAR,NULL,
                                            NULL,TRANSACTION_TYPE,
                                            p_txn_history_rec.TRANSACTION_TYPE),
         SHIPMENT_HEADER_ID           = DECODE
                                          (
                                            p_txn_history_rec.SHIPMENT_HEADER_ID,
                                            FND_API.G_MISS_NUM,NULL,
                                            NULL,SHIPMENT_HEADER_ID,
                                            p_txn_history_rec.SHIPMENT_HEADER_ID),
         PARENT_SHIPMENT_HEADER_ID    = DECODE
                                          (
                                            p_txn_history_rec.PARENT_SHIPMENT_HEADER_ID,
                                            FND_API.G_MISS_NUM,NULL,
                                            NULL,PARENT_SHIPMENT_HEADER_ID,
                                            p_txn_history_rec.PARENT_SHIPMENT_HEADER_ID),
         ORGANIZATION_ID              = DECODE
                                          (
                                            p_txn_history_rec.ORGANIZATION_ID,
                                            FND_API.G_MISS_NUM,NULL,
                                            NULL,ORGANIZATION_ID,
                                            p_txn_history_rec.ORGANIZATION_ID),
         SUPPLIER_ID                  = DECODE
                                          (
                                            p_txn_history_rec.SUPPLIER_ID,
                                            FND_API.G_MISS_NUM,NULL,
                                            NULL,SUPPLIER_ID,
                                            p_txn_history_rec.SUPPLIER_ID),
         SHIPPED_DATE                 = DECODE
                                          (
                                            p_txn_history_rec.SHIPPED_DATE,
                                            FND_API.G_MISS_DATE,NULL,
                                            NULL,SHIPPED_DATE,
                                            p_txn_history_rec.SHIPPED_DATE),
         RECEIPT_DATE                 = DECODE
                                          (
                                            p_txn_history_rec.RECEIPT_DATE,
                                            FND_API.G_MISS_DATE,NULL,
                                            NULL,RECEIPT_DATE,
                                            p_txn_history_rec.RECEIPT_DATE),
         STATUS                       = DECODE
                                          (
                                            p_txn_history_rec.STATUS,
                                            FND_API.G_MISS_CHAR,NULL,
                                            NULL,STATUS,
                                            p_txn_history_rec.STATUS),
         MAX_RCV_TRANSACTION_ID       = DECODE
                                          (
                                            p_txn_history_rec.MAX_RCV_TRANSACTION_ID,
                                            FND_API.G_MISS_NUM,NULL,
                                            NULL,MAX_RCV_TRANSACTION_ID,
                                            p_txn_history_rec.MAX_RCV_TRANSACTION_ID),
         CARRIER_ID                   = DECODE
                                          (
                                            p_txn_history_rec.CARRIER_ID,
                                            FND_API.G_MISS_NUM,NULL,
                                            NULL,CARRIER_ID,
                                            p_txn_history_rec.CARRIER_ID),
         MATCH_REVERTED_BY            = DECODE
                                          (
                                            p_txn_history_rec.MATCH_REVERTED_BY,
                                            FND_API.G_MISS_NUM,NULL,
                                            NULL,MATCH_REVERTED_BY,
                                            p_txn_history_rec.MATCH_REVERTED_BY),
         MATCHED_BY                   = DECODE
                                          (
                                            p_txn_history_rec.MATCHED_BY,
                                            FND_API.G_MISS_NUM,NULL,
                                            NULL,MATCHED_BY,
                                            p_txn_history_rec.MATCHED_BY),
         SHIPMENT_LINE_ID             = DECODE
                                          (
                                            p_txn_history_rec.SHIPMENT_LINE_ID,
                                            FND_API.G_MISS_NUM,NULL,
                                            NULL,SHIPMENT_LINE_ID,
                                            p_txn_history_rec.SHIPMENT_LINE_ID),
         OBJECT_VERSION_NUMBER        = OBJECT_VERSION_NUMBER + 1,
	 -- { IB-Phase-2
	 SHIP_FROM_LOCATION_ID        = DECODE
                                          (
                                            p_txn_history_rec.SHIP_FROM_LOCATION_ID,
                                            FND_API.G_MISS_NUM,NULL,
                                            NULL,SHIP_FROM_LOCATION_ID,
                                            p_txn_history_rec.SHIP_FROM_LOCATION_ID),
         -- } IB-Phase-2
         LAST_UPDATE_DATE             = SYSDATE,
         LAST_UPDATED_BY              = FND_GLOBAL.USER_ID,
         LAST_UPDATE_LOGIN            = FND_GLOBAL.LOGIN_ID
    where TRANSACTION_ID              = p_txn_history_rec.transaction_id;
  --}
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  EXCEPTION
  --{
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      --
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_INBOUND_TXN_HISTORY_PKG.UPDATE_TXN_HISTORY');
  --}
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
  END IF;
  --
  END update_txn_history;

--========================================================================
-- PROCEDURE : Delete_Txn_History     This procedure is used to delete
--                                    a record in the wsh_inbound_txn_history
--                                    table
--
-- PARAMETERS: p_transaction_id        This is unique identifier of a record
--                                     in wsh_inbound_txn_history.
--             x_return_status         return status of the API.
--
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This procedure is used to delete a record in the
--             wsh_inbound_txn_history table.
--========================================================================
  PROCEDURE delete_txn_history (
              p_transaction_id  IN NUMBER,
              x_return_status      OUT NOCOPY VARCHAR2
            )
  IS
  --{
  --}
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELETE_TXN_HISTORY';
  --
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
        --
        WSH_DEBUG_SV.log(l_module_name,'P_TRANSACTION_ID',P_TRANSACTION_ID);
    END IF;
    --
    x_return_status := wsh_util_core.g_ret_sts_success;
    delete from wsh_inbound_txn_history
    where transaction_id = p_transaction_id;
  --}
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  EXCEPTION
  --{
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      --
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_INBOUND_TXN_HISTORY_PKG.DELETE_TXN_HISTORY');
  --}
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
  END IF;
  --
  END delete_txn_history;

--========================================================================
-- PROCEDURE : Get_Txn_History        This procedure is used to get the record
--                                    from wsh_inbound_txn_history based on the
--                                    inputs shipment_header_id
--                                    ,transaction_type and transaction_id.
--
-- PARAMETERS: p_transaction_id        This is unique identifier of a record
--                                     in wsh_inbound_txn_history.
--             p_shipment_header_id    Shipment_Header_id of the transaction.
--             p_transaction_type      Type of Transaction.
--             x_txn_history_rec       This is of type ib_txn_history_rec_type.
--             x_return_status         return status of the API.

-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This procedure is used to a get the record from
--             wsh_inbound_txn_history based on the inputs
--             shipment_header_id, transaction_type, and transaction_id.
--========================================================================
  PROCEDURE get_txn_history (
              p_transaction_id  IN NUMBER DEFAULT NULL,
              p_shipment_header_id IN NUMBER DEFAULT NULL,
              p_transaction_type IN VARCHAR2 DEFAULT NULL,
              x_txn_history_rec  OUT NOCOPY ib_txn_history_rec_type,
              x_return_status      OUT NOCOPY VARCHAR2
            )
  IS
  --{
  -- This cursor is used to get all the attributes of
  -- wsh_inbound_txn_history based on the input parameters.
  cursor l_txn_history_csr is
  select TRANSACTION_ID,
         RECEIPT_NUMBER,
         REVISION_NUMBER,
         SHIPMENT_NUMBER,
         TRANSACTION_TYPE,
         SHIPMENT_HEADER_ID,
         PARENT_SHIPMENT_HEADER_ID,
         ORGANIZATION_ID,
         SUPPLIER_ID,
         SHIPPED_DATE,
         RECEIPT_DATE,
         STATUS,
         MAX_RCV_TRANSACTION_ID,
         CARRIER_ID,
         MATCH_REVERTED_BY,
         MATCHED_BY,
         SHIPMENT_LINE_ID,
         OBJECT_VERSION_NUMBER,
	 SHIP_FROM_LOCATION_ID -- IB-Phase-2
    from wsh_inbound_txn_history
    where transaction_id = p_transaction_id
    or (p_transaction_id is null
        AND shipment_header_id = p_shipment_header_id
        AND transaction_type = p_transaction_type);
  --}
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_TXN_HISTORY';
  --
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
        --
        WSH_DEBUG_SV.log(l_module_name,'P_TRANSACTION_ID',P_TRANSACTION_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_SHIPMENT_HEADER_ID',P_SHIPMENT_HEADER_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_TRANSACTION_TYPE',P_TRANSACTION_TYPE);
    END IF;
    --
    x_return_status := wsh_util_core.g_ret_sts_success;
    IF (p_transaction_id IS NULL AND (p_shipment_header_id IS NULL or p_transaction_type is NULL) ) THEN
    --{
      RAISE FND_API.G_EXC_ERROR;
    --}
    END IF;
    open  l_txn_history_csr;
    fetch l_txn_history_csr into x_txn_history_rec;
    close l_txn_history_csr;
  --}
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  EXCEPTION
  --{
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      --
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_INBOUND_TXN_HISTORY_PKG.GET_TXN_HISTORY');
  --}
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
  END IF;
  --
  END get_txn_history;
  --
  --
--========================================================================
-- PROCEDURE : Post_Process           This procedure is used to update the
--                                    status column of the record in
--                                    wsh_inbound_txn_history based on the
--                                    inputs
--
-- PARAMETERS: p_shipment_header_id    Shipment_Header_id of the transaction.
--             p_max_rcv_txn_id        Maximum rcv_transaction_id stored in
--                                     wsh_inbound_txn_history.
--             p_txn_status            New Status of the transaction.
--             p_txn_type              Type of Transaction.
--             x_txn_history_rec       This is of type ib_txn_history_rec_type.
--             x_return_status         return status of the API.

-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This procedure is not being used any more.
--========================================================================
  PROCEDURE post_process (
    p_shipment_header_id IN NUMBER,
    p_max_rcv_txn_id IN NUMBER,
    p_txn_status IN VARCHAR2,
    p_txn_type IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2
  )
  IS
  --{
    l_txn_id_tab wsh_util_core.id_tab_type;
    cursor l_txn_history_csr(p_shipment_header_id NUMBER) is
    select transaction_id
    from   wsh_inbound_txn_history
    where  transaction_type not in ('RECEIPT', 'ASN')
    and    shipment_header_id = p_shipment_header_id;

   l_txn_history_rec ib_txn_history_rec_type;
   l_return_status VARCHAR2(1);
   l_num_warnings  NUMBER;
   l_num_errors    NUMBER;
  --}
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'POST_PROCESS';
  --
  BEGIN
  --{
  /*
    IF p_txn_type IS NULL THEN
    --{
      IF p_txn_status = 'MATCHED' THEN
      --{
        open l_txn_history_csr(p_shipment_header_id);
        fetch l_txn_history_csr bulk collect into l_txn_id_tab;
        IF l_txn_id_tab.count > 0 THEN
        --{

          FORALL i in l_txn_id_tab.first..l_txn_id_tab.last
            delete from wsh_inbound_txn_history
            where transaction_id = l_txn_id_tab(i);

          get_txn_history (
	    p_shipment_header_id => p_shipment_header_id,
	    p_transaction_type   => p_txn_type,
	    x_txn_history_rec    => l_txn_history_rec,
	    x_return_status      => l_return_status);

	  wsh_util_core.api_post_call(
	    p_return_status    => l_return_status,
	    x_num_warnings     => l_num_warnings,
	    x_num_errors       => l_num_errors);

	  l_txn_history_rec.status := 'MATCHED';
	  l_txn_history_rec.max_rcv_transaction_id := p_max_rcv_txn_id;

	  update_txn_history (
	    p_txn_history_rec    => l_txn_history_rec,
	    x_return_status      => l_return_status);

	  wsh_util_core.api_post_call(
	    p_return_status    => l_return_status,
	    x_num_warnings     => l_num_warnings,
	    x_num_errors       => l_num_errors);

	--}
	END IF;
      --}
      END IF;
    --}
    ELSIF p_txn_type IN ('ASN', 'RECEIPT') THEN
    --{
          get_txn_history (
	    p_shipment_header_id => p_shipment_header_id,
	    p_transaction_type   => p_txn_type,
	    x_txn_history_rec    => l_txn_history_rec,
	    x_return_status      => l_return_status);

	  wsh_util_core.api_post_call(
	    p_return_status    => l_return_status,
	    x_num_warnings     => l_num_warnings,
	    x_num_errors       => l_num_errors);

	  l_txn_history_rec.status := p_txn_status;

	  update_txn_history (
	    p_txn_history_rec    => l_txn_history_rec,
	    x_return_status      => l_return_status);

	  wsh_util_core.api_post_call(
	    p_return_status    => l_return_status,
	    x_num_warnings     => l_num_warnings,
	    x_num_errors       => l_num_errors);
    --}
    END IF;
  --}
  */
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
      --
      WSH_DEBUG_SV.log(l_module_name,'P_SHIPMENT_HEADER_ID',P_SHIPMENT_HEADER_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_MAX_RCV_TXN_ID',P_MAX_RCV_TXN_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_TXN_STATUS',P_TXN_STATUS);
      WSH_DEBUG_SV.log(l_module_name,'P_TXN_TYPE',P_TXN_TYPE);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  EXCEPTION
  --{
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      --
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_INBOUND_TXN_HISTORY_PKG.POST_PROCESS');
  --}
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
  END IF;
  --
  END post_process;


  PROCEDURE post_process
    (
      p_shipment_header_id IN NUMBER,
      p_max_rcv_txn_id    IN NUMBER,
      p_action_code        IN VARCHAR2,   -- MATCHED/CANCEL/REVERT
      p_txn_type           IN VARCHAR2,   -- ASN/RECEIPT
      p_object_version_number IN NUMBER,
      x_return_status      OUT NOCOPY VARCHAR2
    )
  IS
  --{

    cursor txn_csr (p_shipment_header_id NUMBER) is
    select 1
    from   wsh_inbound_txn_history
    where  transaction_type not in ('RECEIPT', 'ASN')
    and    shipment_header_id = p_shipment_header_id;

   l_txn_history_rec ib_txn_history_rec_type;
   l_Receipttxn_history_rec ib_txn_history_rec_type;
   l_return_status VARCHAR2(1);
   l_locked        VARCHAR2(1);
   l_status_code        VARCHAR2(30);
   l_num_warnings  NUMBER := 0;
   l_num_errors    NUMBER := 0;
   l_max_txn_id    NUMBER;
   l_txn_id    NUMBER;
   l_dummy         NUMBER := 0;
  --}
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'POST_PROCESS';
  --
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
          --
          WSH_DEBUG_SV.log(l_module_name,'P_SHIPMENT_HEADER_ID',P_SHIPMENT_HEADER_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_MAX_RCV_TXN_ID',P_MAX_RCV_TXN_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_ACTION_CODE',P_ACTION_CODE);
          WSH_DEBUG_SV.log(l_module_name,'P_TXN_TYPE',P_TXN_TYPE);
          WSH_DEBUG_SV.log(l_module_name,'P_OBJECT_VERSION_NUMBER',P_OBJECT_VERSION_NUMBER);
      END IF;
      --
      x_return_status := wsh_util_core.g_ret_sts_success;
      --
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit lock_asn_receipt_header',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      lock_asn_receipt_header
        (
          p_shipment_header_id  => p_shipment_header_id,
          p_transaction_type    => p_txn_type,
          p_on_error            => 'RETRY', --'RETURN',
          p_on_noDataFound      => WSH_UTIL_CORE.G_RET_STS_ERROR,
          x_txn_history_rec     => l_txn_history_rec,
          x_return_status       => l_return_status,
          x_locked              => l_locked
        );
      --
      --
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
          WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
      END IF;
      --
      wsh_util_core.api_post_call
        (
          p_return_status    => l_return_status,
          x_num_warnings     => l_num_warnings,
          x_num_errors       => l_num_errors
        );
      --
      --
      IF  p_txn_type = 'ASN'
      AND p_action_code = 'REVERT'
      THEN
      --{
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit lock_asn_receipt_header for receipt-asn',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          lock_asn_receipt_header
            (
              p_shipment_header_id  => p_shipment_header_id,
              p_transaction_type    => 'RECEIPT',
              p_on_error            => 'RETRY', --'RETURN',
              p_on_noDataFound      => WSH_UTIL_CORE.G_RET_STS_SUCCESS,
              x_txn_history_rec     => l_Receipttxn_history_rec,
              x_return_status       => l_return_status,
              x_locked              => l_locked
            );
          --
          --
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
              WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
          END IF;
          --
          wsh_util_core.api_post_call
            (
              p_return_status    => l_return_status,
              x_num_warnings     => l_num_warnings,
              x_num_errors       => l_num_errors
            );
          --
          --
          IF l_Receipttxn_history_rec.status LIKE 'MATCHED%'
          THEN
          --{
              FND_MESSAGE.SET_NAME('WSH','WSH_ASN_REVERT_ERROR');
              FND_MESSAGE.SET_TOKEN('SHIPMENT_NUMBER',l_txn_history_rec.shipment_number);
              wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
              RAISE FND_API.G_EXC_ERROR;
          --}
          END IF;
      --}
      END IF;
      --
      --
      /*
      IF l_locked = 'N'
      THEN
      --{
          FND_MESSAGE.SET_NAME('WSH','WSH_IB_TXN_LOCK_ERROR');
          wsh_util_core.add_message(x_return_status,l_module_name);
          RAISE FND_API.G_EXC_ERROR;
      --}
      END IF;
      */
      --
      --
      IF l_txn_history_rec.object_version_number > p_object_version_number
      THEN
      --{
          FND_MESSAGE.SET_NAME('WSH','WSH_IB_TXN_CHANGE_ERROR');
          wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
          RAISE FND_API.G_EXC_ERROR;
      --}
      END IF;
      --
      --
      --
      --
      IF p_action_code = 'MATCHED'
      THEN
        l_txn_id  := p_max_rcv_txn_id;
      ELSIF p_action_code = 'REVERT'
      THEN
        l_txn_id  := 1E38;
      ELSE
        l_txn_id  := 0;
      END IF;
      --
      IF l_txn_id > 0
      THEN
      --{
          DELETE wsh_inbound_txn_history
          WHERE  transaction_type not in (C_ASN, C_RECEIPT)
          AND    shipment_header_id = p_shipment_header_id
          AND    max_rcv_transaction_id <= l_txn_id;
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'Number of Records deleted from transaction history',SQL%ROWCOUNT);
          END IF;
          --
      --}
      END IF;
      --
      --
      IF p_action_code = 'REVERT'
      THEN
        l_txn_history_rec.status            := C_PENDING;
        l_txn_history_rec.MATCH_REVERTED_BY := FND_GLOBAL.USER_ID;
      ELSIF p_action_code = 'CANCEL'
      THEN
          IF p_txn_type = C_ASN
          THEN
            l_txn_history_rec.status := C_CANCELLED;
          ELSE
            l_txn_history_rec.status := C_PENDING;
          END IF;
      ELSE
      --{
          OPEN txn_csr (p_shipment_header_id);
          FETCH txn_csr INTO l_dummy;
          CLOSE txn_csr;
          --
          IF l_dummy = 1
          THEN
            l_txn_history_rec.status := C_MATCHED_AND_CHILD_PENDING;
          ELSE
            l_txn_history_rec.status := C_MATCHED;
          END IF;
          --
          l_txn_history_rec.MATCHED_BY := FND_GLOBAL.USER_ID;
      --}
      END IF;
      --
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'l_txn_history_rec.status',l_txn_history_rec.status);
          WSH_DEBUG_SV.log(l_module_name,'l_txn_history_rec.MATCH_REVERTED_BY',l_txn_history_rec.MATCH_REVERTED_BY);
          WSH_DEBUG_SV.log(l_module_name,'l_txn_history_rec.MATCHED_BY',l_txn_history_rec.MATCHED_BY);
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit update_txn_history',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      update_txn_history
        (
          p_txn_history_rec    => l_txn_history_rec,
          x_return_status      => l_return_status
        );
      --
      --
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      wsh_util_core.api_post_call
        (
          p_return_status    => l_return_status,
          x_num_warnings     => l_num_warnings,
          x_num_errors       => l_num_errors
        );
      --
      --
      IF  p_txn_type = 'ASN'
      AND p_action_code = 'REVERT'
      AND l_Receipttxn_history_rec.transaction_id IS NOT NULL
      THEN
      --{
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit update_txn_history:receipt-asn',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          update_txn_history
            (
              p_txn_history_rec    => l_Receipttxn_history_rec,
              x_return_status      => l_return_status
            );
          --
          --
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          wsh_util_core.api_post_call
            (
              p_return_status    => l_return_status,
              x_num_warnings     => l_num_warnings,
              x_num_errors       => l_num_errors
            );
      --}
      END IF;
      --
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,
                              'Number of Errors='||l_num_errors||',Number of Warnings='||l_num_warnings);
      END IF;
      --
      IF l_num_errors > 0
      THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      ELSIF l_num_warnings > 0
      THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      ELSE
          x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      END IF;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
  --}
  EXCEPTION
  --{
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      --
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_INBOUND_TXN_HISTORY_PKG.POST_PROCESS',l_module_name);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
  --
  --}
  END post_process;


  PROCEDURE lock_asn_receipt_header
              (
                p_shipment_header_id IN NUMBER DEFAULT NULL,
                p_transaction_type   IN VARCHAR2 DEFAULT NULL,
                p_on_error           IN VARCHAR2 DEFAULT 'RETURN', -- 'RETRY'
                p_on_noDataFound     IN VARCHAR2 DEFAULT WSH_UTIL_CORE.G_RET_STS_ERROR, --WSH_UTIL_CORE.G_RET_STS_SUCCESS
                x_txn_history_rec    OUT NOCOPY ib_txn_history_rec_type,
                x_return_status      OUT NOCOPY VARCHAR2,
                x_locked             OUT NOCOPY VARCHAR2 -- Y/N
              )
  IS
  --{
      CURSOR txn_csr is
      SELECT TRANSACTION_ID,
             RECEIPT_NUMBER,
             REVISION_NUMBER,
             SHIPMENT_NUMBER,
             TRANSACTION_TYPE,
             SHIPMENT_HEADER_ID,
             PARENT_SHIPMENT_HEADER_ID,
             ORGANIZATION_ID,
             SUPPLIER_ID,
             SHIPPED_DATE,
             RECEIPT_DATE,
             STATUS,
             MAX_RCV_TRANSACTION_ID,
             CARRIER_ID,
             MATCH_REVERTED_BY,
             MATCHED_BY,
             SHIPMENT_LINE_ID,
             OBJECT_VERSION_NUMBER,
	     SHIP_FROM_LOCATION_ID -- IB-Phase-2
        FROM  wsh_inbound_txn_history
        WHERE shipment_header_id = p_shipment_header_id
        AND   transaction_type   = p_transaction_type
        FOR UPDATE OF STATUS NOWAIT;

      l_param_name        VARCHAR2(200);
      l_found             BOOLEAN;
      --
      record_locked exception;
      PRAGMA EXCEPTION_INIT(record_locked, -54);

  --}
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_ASN_RECEIPT_HEADER';
  --
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
          --
          WSH_DEBUG_SV.log(l_module_name,'P_SHIPMENT_HEADER_ID',P_SHIPMENT_HEADER_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_TRANSACTION_TYPE',P_TRANSACTION_TYPE);
          WSH_DEBUG_SV.log(l_module_name,'P_ON_ERROR',P_ON_ERROR);
          WSH_DEBUG_SV.log(l_module_name,'p_on_noDataFound',p_on_noDataFound);
      END IF;
      --
      x_return_status := wsh_util_core.g_ret_sts_success;
      x_locked        := 'N';
      --
      IF p_shipment_header_id IS NULL
      THEN
        l_param_name := 'p_shipment_header_id';
      ELSIF p_transaction_type IS NULL
      THEN
        l_param_name := 'p_transaction_type';
      END IF;
      --
      IF l_param_name is not null
      THEN
          FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
          FND_MESSAGE.SET_TOKEN('FIELD_NAME',l_param_name);
          wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      --
      --
      IF p_transaction_type NOT IN ( C_ASN, C_RECEIPT )
      THEN
      --{
          FND_MESSAGE.SET_NAME('WSH','WSH_PUB_INVALID_PARAMETER');
          FND_MESSAGE.SET_TOKEN('FIELD_NAME','p_transaction_type');
          wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
          RAISE FND_API.G_EXC_ERROR;
      --}
      END IF;
      --
      --
      IF p_on_error NOT IN ( 'RETURN', 'RETRY' )
      THEN
      --{
          FND_MESSAGE.SET_NAME('WSH','WSH_PUB_INVALID_PARAMETER');
          FND_MESSAGE.SET_TOKEN('FIELD_NAME','p_on_error');
          wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
          RAISE FND_API.G_EXC_ERROR;
      --}
      END IF;
      --
      --
      IF p_on_noDataFound NOT IN ( WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_SUCCESS )
      THEN
      --{
          FND_MESSAGE.SET_NAME('WSH','WSH_PUB_INVALID_PARAMETER');
          FND_MESSAGE.SET_TOKEN('FIELD_NAME','p_on_noDataFound');
          wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
          RAISE FND_API.G_EXC_ERROR;
      --}
      END IF;
      --
      --
      LOOP
      --{
          BEGIN
          --{
              OPEN  txn_csr;
              FETCH txn_csr INTO x_txn_history_rec;
              --
              l_found  := txn_csr%FOUND;
              --
              CLOSE txn_csr;
              --
              IF l_found
              THEN
                  x_locked := 'Y';
              ELSIF p_on_noDataFound = WSH_UTIL_CORE.G_RET_STS_ERROR
              THEN
                  FND_MESSAGE.SET_NAME('WSH','WSH_IB_TXN_NOT_FOUND');
                  FND_MESSAGE.SET_TOKEN('TXN_TYPE',p_transaction_type);
                  FND_MESSAGE.SET_TOKEN('SHIPMENT_HEADER_ID',p_shipment_header_id);
                  wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
                  RAISE FND_API.G_EXC_ERROR;
              END IF;
              --
              EXIT;
          --}
          EXCEPTION
          --{
              WHEN RECORD_LOCKED THEN
                IF txn_csr%ISOPEN
                THEN
                  CLOSE txn_csr;
                END IF;
                --
                IF p_on_error = 'RETURN'
                THEN
                  EXIT;
                END IF;
          --}
          END;
      --}
      END LOOP;
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
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      --
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_INBOUND_TXN_HISTORY_PKG.lock_asn_receipt_header',l_module_name);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
  --}
  END lock_asn_receipt_header;

    PROCEDURE lock_n_roll
                (
                  p_transaction_id IN NUMBER DEFAULT NULL,
                  x_return_status      OUT NOCOPY VARCHAR2,
                  x_locked             OUT NOCOPY VARCHAR2 -- Y/N
                )
    IS
    --{
        CURSOR txn_csr is
        SELECT 1
          FROM  wsh_inbound_txn_history
          WHERE transaction_id = p_transaction_id
          FOR UPDATE OF STATUS NOWAIT;

        l_param_name        VARCHAR2(200);
        l_found             BOOLEAN;
        l_dummy             NUMBER;
        --
        record_locked exception;
        PRAGMA EXCEPTION_INIT(record_locked, -54);

    --}
    --
    l_debug_on BOOLEAN;
    --
    l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'lock_n_roll';
    --
    BEGIN
    --{
        --
        SAVEPOINT lock_n_roll_sp;
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
            --
            WSH_DEBUG_SV.log(l_module_name,'p_transaction_id',p_transaction_id);
        END IF;
        --
        x_return_status := wsh_util_core.g_ret_sts_success;
        x_locked        := 'N';
        --
        IF p_transaction_id IS NULL
        THEN
          l_param_name := 'p_shipment_header_id';
        END IF;
        --
        IF l_param_name is not null
        THEN
            FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
            FND_MESSAGE.SET_TOKEN('FIELD_NAME',l_param_name);
            wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        --
        --
        OPEN  txn_csr;
        FETCH txn_csr INTO l_dummy;
        --
        l_found  := txn_csr%FOUND;
        --
        CLOSE txn_csr;
        --
        IF l_found
        THEN
            x_locked := 'Y';
        ELSE
            FND_MESSAGE.SET_NAME('WSH','WSH_IB_TXN_UPDATE_ERROR');
            FND_MESSAGE.SET_TOKEN('TRANSACTION_ID',p_transaction_id);
            wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        --
        -- Debug Statements
        --
        ROLLBACK TO SAVEPOINT lock_n_roll_sp;
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
    --}
    EXCEPTION
    --{
      WHEN RECORD_LOCKED THEN
        ROLLBACK TO SAVEPOINT lock_n_roll_sp;
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'RECORD_LOCKED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
        END IF;
        --
      WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO SAVEPOINT lock_n_roll_sp;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
        END IF;
        --
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO SAVEPOINT lock_n_roll_sp;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
        END IF;
        --
      WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
        ROLLBACK TO SAVEPOINT lock_n_roll_sp;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
        END IF;
        --
      WHEN OTHERS THEN
        ROLLBACK TO SAVEPOINT lock_n_roll_sp;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
        wsh_util_core.default_handler('WSH_INBOUND_TXN_HISTORY_PKG.lock_n_roll',l_module_name);
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --
    --}
  END lock_n_roll;


  PROCEDURE getTransactionTypeMeaning
              (
                p_transactionType    IN VARCHAR2,
                x_transactionMeaning OUT NOCOPY VARCHAR2,
                x_return_status      OUT NOCOPY VARCHAR2
              )
  IS
  --{
      CURSOR lookup_csr (p_lookupCode IN VARCHAR2,p_lookupType IN VARCHAR2)
      IS
      SELECT  meaning,
              description
      FROM    FND_LOOKUP_VALUES_VL
      WHERE   lookup_code = p_lookupCode
      AND     lookup_type = p_lookupType;

      l_lookup_rec        lookup_csr%ROWTYPE;
      --
      l_debug_on BOOLEAN;
      --
      l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'getTransactionTypeMeaning';
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
      IF l_debug_on THEN
          WSH_DEBUG_SV.push(l_module_name);
          --
          WSH_DEBUG_SV.log(l_module_name,'p_transactionType',p_transactionType);
      END IF;
      --
      x_return_status := wsh_util_core.g_ret_sts_success;
      --
      OPEN  lookup_csr
              (
                p_lookupCode => p_transactionType,
                p_lookupType => 'WSH_IB_TXN_TYPE'
              );
      FETCH lookup_csr INTO l_lookup_rec;
      CLOSE lookup_csr;
      --
      x_transactionMeaning := l_lookup_rec.meaning;
      --
      IF l_lookup_rec.meaning IS NULL
      THEN
          FND_MESSAGE.SET_NAME('WSH','WSH_IB_INVALID_TXN_TYPE');
          FND_MESSAGE.SET_TOKEN('TXN_TYPE',p_transactionType);
          wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      --
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
  --}
  EXCEPTION
  --{
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      --
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_INBOUND_TXN_HISTORY_PKG.getTransactionTypeMeaning',l_module_name);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
  --}
  END getTransactionTypeMeaning;

END WSH_INBOUND_TXN_HISTORY_PKG;

/
