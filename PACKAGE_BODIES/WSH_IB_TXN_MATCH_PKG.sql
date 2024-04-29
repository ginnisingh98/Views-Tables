--------------------------------------------------------
--  DDL for Package Body WSH_IB_TXN_MATCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_IB_TXN_MATCH_PKG" as
/* $Header: WSHIBMAB.pls 120.2.12000000.2 2007/01/23 19:15:53 rvishnuv ship $ */
    --
    --
    C_PROCESS_FLAG          CONSTANT  VARCHAR2(1)   := 'Y';
    C_NOT_PROCESS_FLAG      CONSTANT  VARCHAR2(1)   := 'N';
    C_ERROR_FLAG            CONSTANT  VARCHAR2(1)   := 'E';
    C_POTENTIAL_MATCH_FLAG  CONSTANT  VARCHAR2(1)   := 'P';
    C_DATE_FORMAT_MASK      CONSTANT  VARCHAR2(50)  := 'MM/DD/YYYY HH24:MI:SS';
    C_SEPARATOR             CONSTANT  VARCHAR2(1)   := '-';
    --
    --
    e_notMatched                EXCEPTION;
    e_fatalError                EXCEPTION;
    --

--
-- Local structure to bulk fetch delivery lines.
-- Qualifying(matching) lines are transfered to l_matchedLineRecTbl
-- which in turn gets passed to ASN/Receipt/Correction integration
-- code.
--
TYPE line_recTbl_type
IS
RECORD
  (
    delivery_detail_id_tbl            WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
    requested_quantity_tbl            WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
    picked_quantity_tbl               WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
    shipped_quantity_tbl              WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
    received_quantity_tbl             WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
    returned_quantity_tbl             WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
    requested_quantity2_tbl           WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
    picked_quantity2_tbl              WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
    shipped_quantity2_tbl             WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
    received_quantity2_tbl            WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
    returned_quantity2_tbl            WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
    ship_from_location_id_tbl         WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
    earliest_dropoff_date_tbl         WSH_BULK_TYPES_GRP.date_Nested_Tab_Type   := WSH_BULK_TYPES_GRP.date_Nested_Tab_Type(),
    delivery_id_tbl                   WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
    rcv_shipment_line_id_tbl          WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
    requested_quantity_uom_tbl        WSH_BULK_TYPES_GRP.char3_Nested_Tab_Type  := WSH_BULK_TYPES_GRP.char3_Nested_Tab_Type(),
    requested_quantity_uom2_tbl       WSH_BULK_TYPES_GRP.char3_Nested_Tab_Type  := WSH_BULK_TYPES_GRP.char3_Nested_Tab_Type(),
    released_status_tbl               WSH_BULK_TYPES_GRP.char30_Nested_Tab_Type := WSH_BULK_TYPES_GRP.char30_Nested_Tab_Type(),
    src_requested_quantity_tbl        WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
    src_requested_quantity2_tbl       WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
    last_update_date_tbl              WSH_BULK_TYPES_GRP.date_Nested_Tab_Type := WSH_BULK_TYPES_GRP.date_Nested_Tab_Type()
  );


TYPE message_tbl_type
IS
TABLE OF VARCHAR2(2000)
INDEX BY BINARY_INTEGER;

/*****************
PROCEDURE appendLinkTblDates
            (
                p_linerec
                p_transactionType
                x_matchedLineRecTbl
                x_dlvytbl, x_dlvyexttbl,
                x_linktbl, x_linkexttbl
                p_start_index
                p_end_index
                p_txnUniqueSFLocnId
            )
IS
--{
   --
    l_num_warnings              NUMBER;
    l_num_errors                NUMBER;
    l_return_status             VARCHAR2(30);
    --
    l_linkRecString         VARCHAR2(500);
--}
BEGIN
--{
    wsh_util_core.get_cached_value
    (
      p_cache_tbl         => p_linkTbl,
      p_cache_ext_tbl     => p_linkExtTbl,
      p_key               => p_poShipmentLineId,
      p_value             => l_linkRecString,
      p_action            => 'GET',
      x_return_status     => l_return_status
    );
    --
    --
    wsh_util_core.api_post_call
      (
        p_return_status => l_return_status,
        x_num_warnings  => l_num_warnings,
        x_num_errors    => l_num_errors
      );
    --
    --
    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING
    THEN
        error
    END IF;
    --
    --
    l_linkRecString := l_linkRecString
                       || C_SEPARATOR
                       || TO_CHAR(p_min_date,C_DATE_FORMAT_MASK)
                       || C_SEPARATOR
                       || TO_CHAR(p_max_date,C_DATE_FORMAT_MASK);
    --
    --
    wsh_util_core.get_cached_value
    (
      p_cache_tbl         => p_linkTbl,
      p_cache_ext_tbl     => p_linkExtTbl,
      p_key               => p_poShipmentLineId,
      p_value             => l_linkRecString,
      p_action            => 'PUT',
      x_return_status     => l_return_status
    );
    --
    --
    wsh_util_core.api_post_call
      (
        p_return_status => l_return_status,
        x_num_warnings  => l_num_warnings,
        x_num_errors    => l_num_errors
      );

--}
EXCEPTION
--{
--}
END;
************/
--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_IB_TXN_MATCH_PKG';
--
--
--========================================================================
-- PROCEDURE : validateMandatoryInfo
--
-- PARAMETERS: p_transactionType Transaction Type
--             p_index           Index into x_line_rec
--             x_line_rec        ASN/Receipt Lines
--             x_return_status   Return status of the API
--
--
-- COMMENT   :  This procedure validates for mandatory fields for each record passed by
--              receiving transaction processor.
--
--              First, it validates PO related mandatory fields by
--                    calling WSH_BULK_PROCESS_PVT.validate_mandatory_info
--
--              Next, it validates receiving related fields as follows:
--                - For ASN/Cancel ASN, following fields are mandatory.
--                  - shipment_header_id
--                  - shipment_line_id
--                  - received_quantity
--                  - received_quantity_uom
--                  - shipment_num
--                  - shipped_date
--
--                - For other transactions, following fields are mandatory.
--                  - shipment_header_id
--                  - shipment_line_id
--                  - rcv_transaction_id
--                  - received_quantity
--                  - received_quantity_uom
--                  - receipt_num
--                  - expected_receipt_date
--
--========================================================================
--
PROCEDURE validateMandatoryInfo
            (
              p_transactionType           IN              VARCHAR2,
              p_index                     IN              NUMBER,
              x_line_rec                  IN OUT NOCOPY   OE_WSH_BULK_GRP.Line_rec_type,
              x_return_status             OUT     NOCOPY  VARCHAR2
            )
IS
--{
    l_num_warnings              NUMBER  := 0;
    l_num_errors                NUMBER  := 0;
    l_return_status             VARCHAR2(30);
    --
    l_fieldName                 VARCHAR2(100);
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATEMANDATORYINFO';
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
        --
        WSH_DEBUG_SV.log(l_module_name,'P_TRANSACTIONTYPE',P_TRANSACTIONTYPE);
        WSH_DEBUG_SV.log(l_module_name,'P_INDEX',P_INDEX);
    END IF;
    --
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_BULK_PROCESS_PVT.VALIDATE_MANDATORY_INFO',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    WSH_BULK_PROCESS_PVT.validate_mandatory_info
      (
        p_line_rec      => x_line_rec,
        p_index         => p_index,
        x_return_status => l_return_status
      );
    --
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    wsh_util_core.api_post_call
      (
        p_return_status => l_return_status,
        x_num_warnings  => l_num_warnings,
        x_num_errors    => l_num_errors
      );
    --
    --
    IF x_line_rec.shipment_header_id(p_index) IS NULL
    THEN
        l_fieldName := 'shipment_header_id' || '(' || p_index || ')';
    ELSIF x_line_rec.shipment_line_id(p_index) IS NULL
    THEN
        l_fieldName := 'shipment_line_id' || '(' || p_index || ')';
    ELSIF x_line_rec.rcv_transaction_id(p_index) IS NULL
    AND   p_transactionType NOT IN (WSH_INBOUND_TXN_HISTORY_PKG.C_ASN,WSH_INBOUND_TXN_HISTORY_PKG.C_CANCEL_ASN)
    THEN
        l_fieldName := 'rcv_transaction_id' || '(' || p_index || ')';
    ELSIF x_line_rec.received_quantity(p_index) IS NULL
    THEN
        l_fieldName := 'received_quantity' || '(' || p_index || ')';
    ELSIF x_line_rec.received_quantity_uom(p_index) IS NULL
    THEN
        l_fieldName := 'received_quantity_uom' || '(' || p_index || ')';
    ELSIF x_line_rec.shipment_num(p_index) IS NULL
    AND   p_transactionType IN (WSH_INBOUND_TXN_HISTORY_PKG.C_ASN,WSH_INBOUND_TXN_HISTORY_PKG.C_CANCEL_ASN)
    THEN
        l_fieldName := 'shipment_num' || '(' || p_index || ')';
    ELSIF x_line_rec.shipped_date(p_index) IS NULL
    AND   p_transactionType IN (WSH_INBOUND_TXN_HISTORY_PKG.C_ASN,WSH_INBOUND_TXN_HISTORY_PKG.C_CANCEL_ASN)
    THEN
        l_fieldName := 'shipped_date' || '(' || p_index || ')';
    ELSIF x_line_rec.receipt_num(p_index) IS NULL
    AND   p_transactionType NOT IN (WSH_INBOUND_TXN_HISTORY_PKG.C_ASN,WSH_INBOUND_TXN_HISTORY_PKG.C_CANCEL_ASN)
    THEN
        l_fieldName := 'receipt_num' || '(' || p_index || ')';
    ELSIF x_line_rec.expected_receipt_date(p_index) IS NULL
    AND   p_transactionType NOT IN (WSH_INBOUND_TXN_HISTORY_PKG.C_ASN,WSH_INBOUND_TXN_HISTORY_PKG.C_CANCEL_ASN)
    THEN
        l_fieldName := 'expected_receipt_date' || '(' || p_index || ')';
    END IF;
    --
    --
    IF l_fieldName IS NOT NULL
    THEN
    --{
        FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME',l_fieldName);
        wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
        RAISE FND_API.G_EXC_ERROR;
    --}
    END IF;
    --
    --
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
      wsh_util_core.default_handler('WSH_IB_TXN_MATCH_PKG.validateMandatoryInfo');
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
--}
END validateMandatoryInfo;
--
--
--
--========================================================================
-- PROCEDURE : retrieveMessages
--
-- PARAMETERS: p_startIndex      Start Index on FND Message Stack.
--             p_endIndex        End Index on FND Message Stack.
--             x_messageTbl      Table of messages(retrieved from stack)
--             x_return_status   Return status of the API
--
--
-- COMMENT   :  It retrieves messages from FND message stack between p_startIndex and p_endIndex.
--              This procedure is called in the event of matching algorithm failure before raising
--              business event. It extracts all messages (which inform the user reasons for failure)
--              which will be passed as business event parameter.
--========================================================================
--
--
PROCEDURE retrieveMessages
            (
              p_startIndex                IN              NUMBER,
              p_endIndex                  IN              NUMBER,
              x_messageTbl                OUT     NOCOPY  message_tbl_type,
              x_return_status             OUT     NOCOPY  VARCHAR2
            )
IS
--{
    l_num_warnings              NUMBER  := 0;
    l_num_errors                NUMBER  := 0;
    l_return_status             VARCHAR2(30);
    --
    l_index                     NUMBER;
    l_message                   VARCHAR2(2000);
    l_messageStr                VARCHAR2(2000);
    --
    l_messageLength             NUMBER;
    l_messageStrLength          NUMBER;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'RETRIEVEMESSAGES';
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
        --
        WSH_DEBUG_SV.log(l_module_name,'P_STARTINDEX',P_STARTINDEX);
        WSH_DEBUG_SV.log(l_module_name,'P_ENDINDEX',P_ENDINDEX);
    END IF;
    --
    l_messageStrLength := 0;
    --
    FOR l_index IN p_startIndex..p_endIndex
    LOOP
    --{
        l_message := FND_MSG_PUB.GET
                        (
                          p_msg_index   => l_index,
                          p_encoded     => 'F'
                        );
        --
        l_messageLength := LENGTHB(l_message);
        --
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_index',l_index);
            WSH_DEBUG_SV.log(l_module_name,'l_messageLength',l_messageLength);
            WSH_DEBUG_SV.log(l_module_name,'l_messageStrLength',l_messageStrLength);
        END IF;
        --
        IF l_messageStrLength = 0
        THEN
            l_messageStr := l_message;
        ELSIF l_messageLength + l_messageStrLength < 2000
        THEN
        --{
            l_messageStr := l_messageStr
                            || FND_GLOBAL.LOCAL_CHR(10)
                            || l_message;
        --}
        ELSE
        --{
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Adding l_messageStr to x_messageTbl',l_messageStr);
            END IF;
            --
            x_messageTbl(x_messageTbl.COUNT+1) := l_messageStr;
            --
            l_messageStr := l_message;
        --}
        END IF;
        --
        l_messageStrLength := LENGTHB(l_messageStr);
        --
        IF l_index = p_endIndex
        THEN
        --{
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Adding l_messageStr to x_messageTbl',l_messageStr);
            END IF;
            --
            x_messageTbl(x_messageTbl.COUNT+1) := l_messageStr;
        --}
        END IF;
    --}
    END LOOP;
    --
    --
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
      wsh_util_core.default_handler('WSH_IB_TXN_MATCH_PKG.retrieveMessages');
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
--}
END retrieveMessages;
--
--
--
--========================================================================
-- PROCEDURE : handleMatchFailure
--
-- PARAMETERS: p_transactionType Transaction Type
--             p_transactionMeaning Transaction Meaning
--             x_return_status   Return status of the API
--
--
-- COMMENT   :  This procedure is called when matching algorithm fails.
--              It performs following steps:
--
--              01. Update WSH_INBOUND_TXN_HISTORY status (Manual reconciliation required/Matchec,child pending)
--              02. Retrieve all messages from FND message stack
--              03. Raise business event with following parameters
--                   - TRANSACTION_TYPE
--                   - SHIPMENT_HEADER_ID
--                   - SHIPMENT_NUMBER
--                   - RECEIPT_NUMBER
--                   - SUMMARY_MESSAGE (indicating matching algorithm failed)
--                   - Upto 20 additional parameters DETAILED_MESSAGE_1..20 (detailed reasons for
--                     failure as retrieved from message stack)
--========================================================================
--
--
PROCEDURE handleMatchFailure
            (
              p_transactionType           IN          VARCHAR2,
              p_transactionMeaning        IN          VARCHAR2,
              p_ReceiptAgainstASN         IN          VARCHAR2,
              p_minFailedTransactionId    IN          NUMBER,
              p_minMatchedTransactionId   IN          NUMBER,
              p_maxRCVTransactionId       IN          NUMBER,
              p_headerTransactionId       IN          NUMBER,
              p_headerObjectVersionNumber IN          NUMBER,
              p_headerStatus              IN          VARCHAR2,
              p_messageStartIndex         IN          NUMBER,
              p_RCVShipmentHeaderId       IN          NUMBER,
              p_shipmentNumber            IN          VARCHAR2,
              p_receiptNumber             IN          VARCHAR2,
              x_return_status             OUT NOCOPY  VARCHAR2
            )
IS
--{
    l_num_warnings              NUMBER  := 0;
    l_num_errors                NUMBER  := 0;
    l_return_status             VARCHAR2(30);
    --
    l_headerObjectVersionNumber NUMBER;
    l_headerStatus              VARCHAR2(30);
    l_maxRCVTransactionId       NUMBER;
    --
    l_messageTbl                message_tbl_type;
    --
    l_index                     NUMBER;
    l_eventParameterList        WF_PARAMETER_LIST_T;
    l_eventKey                  NUMBER;
    --
    CURSOR eventKey_csr
    IS
      SELECT WSH_INBOUND_TXN_MATCH_KEY_S.NEXTVAL
      FROM   DUAL;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'HANDLEMATCHFAILURE';
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
        --
        WSH_DEBUG_SV.log(l_module_name,'P_TRANSACTIONTYPE',P_TRANSACTIONTYPE);
        WSH_DEBUG_SV.log(l_module_name,'P_TRANSACTIONMEANING',P_TRANSACTIONMEANING);
        WSH_DEBUG_SV.log(l_module_name,'P_RECEIPTAGAINSTASN',P_RECEIPTAGAINSTASN);
        WSH_DEBUG_SV.log(l_module_name,'P_MINFAILEDTRANSACTIONID',P_MINFAILEDTRANSACTIONID);
        WSH_DEBUG_SV.log(l_module_name,'P_MINMATCHEDTRANSACTIONID',P_MINMATCHEDTRANSACTIONID);
        WSH_DEBUG_SV.log(l_module_name,'P_MAXRCVTRANSACTIONID',P_MAXRCVTRANSACTIONID);
        WSH_DEBUG_SV.log(l_module_name,'P_HEADERTRANSACTIONID',P_HEADERTRANSACTIONID);
        WSH_DEBUG_SV.log(l_module_name,'P_HEADEROBJECTVERSIONNUMBER',P_HEADEROBJECTVERSIONNUMBER);
        WSH_DEBUG_SV.log(l_module_name,'P_HEADERSTATUS',P_HEADERSTATUS);
        WSH_DEBUG_SV.log(l_module_name,'P_MESSAGESTARTINDEX',P_MESSAGESTARTINDEX);
        WSH_DEBUG_SV.log(l_module_name,'P_RCVSHIPMENTHEADERID',P_RCVSHIPMENTHEADERID);
        WSH_DEBUG_SV.log(l_module_name,'P_SHIPMENTNUMBER',P_SHIPMENTNUMBER);
        WSH_DEBUG_SV.log(l_module_name,'P_RECEIPTNUMBER',P_RECEIPTNUMBER);
    END IF;
    --
    IF p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_ASN
    OR p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT
    THEN
    --{
        l_headerObjectVersionNumber := p_headerObjectVersionNumber;
        l_headerStatus              := p_headerStatus;
        l_maxRCVTransactionId       := p_maxRCVTransactionId;
    --}
    ELSE
    --{
        l_headerObjectVersionNumber := p_headerObjectVersionNumber;
        l_headerStatus              := p_headerStatus;
        l_maxRCVTransactionId       := p_maxRCVTransactionId;
        --
        --
        IF LEAST(p_minFailedTransactionId,p_minMatchedTransactionId) < NVL(l_maxRCVTransactionId,1E38)
        THEN
            l_headerObjectVersionNumber := NVL(l_headerObjectVersionNumber,0) + 1;
        END IF;
        --
        IF l_headerStatus = WSH_INBOUND_TXN_HISTORY_PKG.C_MATCHED
        THEN
            l_headerStatus := WSH_INBOUND_TXN_HISTORY_PKG.C_MATCHED_AND_CHILD_PENDING;
        END IF;
    --}
    END IF;
    --
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'UPDATE WSH_INBOUND_TXN_HISTORY');
        WSH_DEBUG_SV.log(l_module_name,'l_headerStatus',l_headerStatus);
        WSH_DEBUG_SV.log(l_module_name,'l_headerObjectVersionNumber',l_headerObjectVersionNumber);
        WSH_DEBUG_SV.log(l_module_name,'l_maxRCVTransactionId',l_maxRCVTransactionId);
    END IF;
    --
    --
    UPDATE WSH_INBOUND_TXN_HISTORY
    SET    STATUS                  = NVL(l_headerStatus,STATUS),
           OBJECT_VERSION_NUMBER   = NVL(l_headerObjectVersionNumber,OBJECT_VERSION_NUMBER),
           MAX_RCV_TRANSACTION_ID  = NVL(l_maxRCVTransactionId,MAX_RCV_TRANSACTION_ID),
           LAST_UPDATE_DATE        = SYSDATE,
           LAST_UPDATED_BY         = FND_GLOBAL.USER_ID,
           LAST_UPDATE_LOGIN       = FND_GLOBAL.LOGIN_ID
    WHERE  TRANSACTION_ID          = p_headerTransactionId;
    --
    IF SQL%ROWCOUNT = 0
    THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_IB_TXN_UPDATE_ERROR');
        FND_MESSAGE.SET_TOKEN('TRANSACTION_ID',p_headerTransactionId);
        wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    --
    --
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_IB_TXN_MATCH_PKG.RETRIEVEMESSAGES',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    WSH_IB_TXN_MATCH_PKG.retrieveMessages
      (
        p_startIndex     => p_messageStartIndex,
        p_endIndex       => FND_MSG_PUB.Count_Msg,
        x_messageTbl     => l_messageTbl,
        x_return_status  => l_return_status
      );
    --
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    wsh_util_core.api_post_call
      (
        p_return_status => l_return_status,
        x_num_warnings  => l_num_warnings,
        x_num_errors    => l_num_errors
      );
    --
    --
    OPEN eventKey_csr;
    FETCH eventKey_csr INTO l_eventKey;
    CLOSE eventKey_csr;
    --
    IF l_eventKey IS NULL
    THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_IB_EVENT_KEY_ERROR');
        wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    --
    --
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_eventKey',l_eventKey);
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_EVENT.ADDPARAMETERTOLIST-TRANSACTION_TYPE',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    WF_EVENT.AddParameterToList
      (
        p_name   => 'TRANSACTION_TYPE',
        p_value  => p_transactionType,
        p_parameterList => l_eventParameterList
      );
    --
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_EVENT.ADDPARAMETERTOLIST-SHIPMENT_HEADER_ID',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    WF_EVENT.AddParameterToList
      (
        p_name   => 'SHIPMENT_HEADER_ID',
        p_value  => p_RCVShipmentHeaderId,
        p_parameterList => l_eventParameterList
      );
    --
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_EVENT.ADDPARAMETERTOLIST-SHIPMENT_NUMBER',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    WF_EVENT.AddParameterToList
      (
        p_name   => 'SHIPMENT_NUMBER',
        p_value  => p_shipmentNumber,
        p_parameterList => l_eventParameterList
      );
    --
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_EVENT.ADDPARAMETERTOLIST-RECEIPT_NUMBER',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    WF_EVENT.AddParameterToList
      (
        p_name   => 'RECEIPT_NUMBER',
        p_value  => p_receiptNumber,
        p_parameterList => l_eventParameterList
      );
    --
    --
    FND_MESSAGE.SET_NAME('WSH','WSH_IB_MATCH_FAILURE');
    FND_MESSAGE.SET_TOKEN('TRANSACTION_TYPE', p_transactionMeaning);
    FND_MESSAGE.SET_TOKEN('RECEIPT_NUM', p_receiptNumber);
    FND_MESSAGE.SET_TOKEN('SHIPMENT_NUM', p_shipmentNumber);

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_EVENT.ADDPARAMETERTOLIST-SUMMARY_MESSAGE',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    WF_EVENT.AddParameterToList
      (
        p_name   => 'SUMMARY_MESSAGE',
        p_value  => FND_MESSAGE.GET,
        p_parameterList => l_eventParameterList
      );
    --
    --
    l_index := l_messageTbl.FIRST;
    --
    WHILE l_index IS NOT NULL
    AND   l_index <= 20
    LOOP
    --{
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_EVENT.ADDPARAMETERTOLIST-detailed_message_'||l_index,WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        WF_EVENT.AddParameterToList
          (
            p_name   => 'DETAILED_MESSAGE_' || TO_CHAR(l_index),
            p_value  => l_messageTbl(l_index),
            p_parameterList => l_eventParameterList
          );
        --
        l_index := l_messageTbl.NEXT(l_index);
    --}
    END LOOP;
    --
    --
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_EVENT.RAISE',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    WF_EVENT.RAISE
      (
        p_event_name    => 'oracle.apps.fte.inbound.shipment.matchfailure',
        p_event_key     => l_eventKey,
        p_parameters    => l_eventParameterList
      );
    --
    --
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
      wsh_util_core.default_handler('WSH_IB_TXN_MATCH_PKG.handleMatchFailure');
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
--}
END handleMatchFailure;
--
--
--
--========================================================================
-- PROCEDURE : getTransactionKey
--
-- PARAMETERS: p_transactionType Transaction Type
--             p_line_rec        ASN/Receipt Lines
--             x_return_status   Return status of the API
--
--
-- COMMENT   :  This procedure is used to derive key(PLL/RSL ID) and transaction sub-type
--              for each input record in p_line_rec. (Please refer to appendix2 in DLD)
--========================================================================
--
--
PROCEDURE getTransactionKey
            (
              p_transactionType           IN              VARCHAR2,
              p_ReceiptAgainstASN         IN              VARCHAR2,
              p_index                     IN              NUMBER,
              p_line_rec                  IN              OE_WSH_BULK_GRP.Line_rec_type,
              x_key                       OUT     NOCOPY  NUMBER,
              x_transactionSubType        OUT     NOCOPY  VARCHAR2,
              x_return_status             OUT     NOCOPY  VARCHAR2
            )
IS
--{
    l_num_warnings              NUMBER  := 0;
    l_num_errors                NUMBER  := 0;
    l_return_status             VARCHAR2(30);
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GETTRANSACTIONKEY';
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
        --
        WSH_DEBUG_SV.log(l_module_name,'P_TRANSACTIONTYPE',P_TRANSACTIONTYPE);
        WSH_DEBUG_SV.log(l_module_name,'P_RECEIPTAGAINSTASN',P_RECEIPTAGAINSTASN);
        WSH_DEBUG_SV.log(l_module_name,'P_INDEX',P_INDEX);
    END IF;
    --
    --
    x_transactionSubType := p_transactionType;
    --
    --
    IF    p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_ASN
    OR    p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_ADD
    THEN
        x_key     := p_line_rec.po_shipment_line_id(p_index);
    ELSIF p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT
    THEN
        IF p_ReceiptAgainstASN   = 'Y'
        THEN
            x_key := p_line_rec.shipment_line_id(p_index);
        ELSE
            x_key := p_line_rec.po_shipment_line_id(p_index);
        END IF;
    ELSIF p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_CORRECTION
    OR    p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_CORRECTION_POSITIVE
    OR    p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_CORRECTION_NEGATIVE
    OR    p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RTV
    OR    p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RTV_CORRECTION
    OR    p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RTV_CORRECTION_POSITIVE
    OR    p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RTV_CORRECTION_NEGATIVE
    THEN
        x_key     := p_line_rec.shipment_line_id(p_index);
        --
        --
        IF p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_CORRECTION
        THEN
            IF p_line_rec.received_quantity(p_index) > 0
            THEN
                x_transactionSubType := WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_CORRECTION_POSITIVE;
            ELSE
                x_transactionSubType := WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_CORRECTION_NEGATIVE;
            END IF;
        ELSIF p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RTV_CORRECTION
        THEN
            IF p_line_rec.received_quantity(p_index) > 0
            THEN
                x_transactionSubType := WSH_INBOUND_TXN_HISTORY_PKG.C_RTV_CORRECTION_POSITIVE;
            ELSE
                x_transactionSubType := WSH_INBOUND_TXN_HISTORY_PKG.C_RTV_CORRECTION_NEGATIVE;
            END IF;
        END IF;
    ELSE
    --{
        FND_MESSAGE.SET_NAME('WSH','WSH_IB_INVALID_TXN_TYPE');
        FND_MESSAGE.SET_TOKEN('TXN_TYPE',p_transactionType);
        wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
        RAISE FND_API.G_EXC_ERROR;
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
      wsh_util_core.default_handler('WSH_IB_TXN_MATCH_PKG.getTransactionKey');
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
--}
END getTransactionKey;
--
--========================================================================
-- PROCEDURE : addTransactionHistoryRecord
--
-- PARAMETERS: p_transactionType Transaction Type
--             p_line_rec        ASN/Receipt Lines
--             x_return_status   Return status of the API
--
--
-- COMMENT   :  This procedure add a transaction history record to the pl/sql
--              table specified by the parameter x_inboundTxnHistory_recTbl
--========================================================================
--
--
PROCEDURE addTransactionHistoryRecord
            (
              p_transactionType           IN              VARCHAR2,
              p_ReceiptAgainstASN         IN              VARCHAR2,
              p_index                     IN              NUMBER,
              p_line_rec                  IN              OE_WSH_BULK_GRP.Line_rec_type,
      	      p_ship_from_location_id     IN              NUMBER, -- IB-Phase-2
              x_inboundTxnHistory_recTbl  IN OUT  NOCOPY  WSH_INBOUND_TXN_HISTORY_PKG.inboundTxnHistory_recTbl_type,
              x_return_status             OUT     NOCOPY  VARCHAR2
            )
IS
--{
    l_count                     NUMBER  := 0;
    --
    l_num_warnings              NUMBER  := 0;
    l_num_errors                NUMBER  := 0;
    l_return_status             VARCHAR2(30);
    --
    l_txnHistoryRec             WSH_INBOUND_TXN_HISTORY_PKG.ib_txn_history_rec_type;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ADDTRANSACTIONHISTORYRECORD';
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
        --
        WSH_DEBUG_SV.log(l_module_name,'P_TRANSACTIONTYPE',P_TRANSACTIONTYPE);
        WSH_DEBUG_SV.log(l_module_name,'P_RECEIPTAGAINSTASN',P_RECEIPTAGAINSTASN);
        WSH_DEBUG_SV.log(l_module_name,'P_INDEX',P_INDEX);
    END IF;
    --
    l_count := x_inboundTxnHistory_recTbl.TRANSACTION_TYPE.COUNT + 1;
    --
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_count',l_count);
    END IF;
    --
    --
    x_inboundTxnHistory_recTbl.RECEIPT_NUMBER(l_count)      := p_line_rec.receipt_num(p_index);
    x_inboundTxnHistory_recTbl.SHIPMENT_NUMBER(l_count)     := p_line_rec.shipment_num(p_index);
    x_inboundTxnHistory_recTbl.TRANSACTION_TYPE(l_count)    := p_transactionType;
    x_inboundTxnHistory_recTbl.SHIPMENT_HEADER_ID(l_count)  := p_line_rec.shipment_header_id(p_index);
    x_inboundTxnHistory_recTbl.ORGANIZATION_ID(l_count)     := p_line_rec.organization_id(p_index);
    x_inboundTxnHistory_recTbl.SUPPLIER_ID(l_count)         := p_line_rec.vendor_id(p_index);
    x_inboundTxnHistory_recTbl.SHIPPED_DATE(l_count)        := p_line_rec.shipped_date(p_index);
    x_inboundTxnHistory_recTbl.RECEIPT_DATE(l_count)        := p_line_rec.expected_receipt_date(p_index);
    x_inboundTxnHistory_recTbl.CARRIER_ID(l_count)          := p_line_rec.rcv_carrier_id(p_index);
    x_inboundTxnHistory_recTbl.SHIP_FROM_LOCATION_ID(l_count):= p_ship_from_location_id; -- IB-Phase-2
    x_inboundTxnHistory_recTbl.REVISION_NUMBER(l_count)     := NULL;
    x_inboundTxnHistory_recTbl.MATCH_REVERTED_BY(l_count)   := NULL;
    x_inboundTxnHistory_recTbl.MATCHED_BY(l_count)          := NULL;
    --
    IF p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_ASN
    OR p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT
    THEN
        x_inboundTxnHistory_recTbl.STATUS(l_count)                  := WSH_INBOUND_TXN_HISTORY_PKG.C_PENDING;
        x_inboundTxnHistory_recTbl.MAX_RCV_TRANSACTION_ID(l_count)  := NULL;
        x_inboundTxnHistory_recTbl.SHIPMENT_LINE_ID(l_count)        := NULL;
    ELSE
        x_inboundTxnHistory_recTbl.STATUS(l_count)                  := WSH_INBOUND_TXN_HISTORY_PKG.C_PENDING; --_PARENT_MATCHING;
        x_inboundTxnHistory_recTbl.MAX_RCV_TRANSACTION_ID(l_count)  := p_line_rec.rcv_transaction_id(p_index);
        x_inboundTxnHistory_recTbl.SHIPMENT_LINE_ID(l_count)        := p_line_rec.shipment_line_id(p_index);
    END IF;
    --
    IF p_ReceiptAgainstASN = 'Y'
    THEN
        x_inboundTxnHistory_recTbl.PARENT_SHIPMENT_HEADER_ID(l_count) := p_line_rec.shipment_header_id(p_index);
    ELSE
        x_inboundTxnHistory_recTbl.PARENT_SHIPMENT_HEADER_ID(l_count) := NULL;
    END IF;
    --
    --
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
      wsh_util_core.default_handler('WSH_IB_TXN_MATCH_PKG.addTransactionHistoryRecord');
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
--}
END addTransactionHistoryRecord;
--
--
--========================================================================
-- PROCEDURE : insertTransactionHistory
--
-- PARAMETERS: p_transactionType Transaction Type
--             p_autonomous      Insert should be an Autonomous transaction or not.
--             p_line_rec        ASN/Receipt Lines
--             x_return_status   Return status of the API
--
--
-- COMMENT   :  Inserts a record into WSH_INBOUND_TXN_HISTORY.
--
--========================================================================
--
PROCEDURE insertTransactionHistory
            (
              p_transactionType       IN              VARCHAR2,
              p_ReceiptAgainstASN     IN              VARCHAR2,
              p_autonomous            IN              BOOLEAN,
              p_index                 IN              NUMBER,
              p_line_rec              IN              OE_WSH_BULK_GRP.Line_rec_type,
	      p_ship_from_location_id IN              NUMBER, -- IB-Phase-2
              x_transactionId         OUT     NOCOPY  NUMBER,
              x_return_status         OUT     NOCOPY  VARCHAR2
            )
IS
--{
    l_num_warnings              NUMBER  := 0;
    l_num_errors                NUMBER  := 0;
    l_return_status             VARCHAR2(30);
    --
    l_txnHistoryRec             WSH_INBOUND_TXN_HISTORY_PKG.ib_txn_history_rec_type;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'INSERTTRANSACTIONHISTORY';
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
        --
        WSH_DEBUG_SV.log(l_module_name,'P_TRANSACTIONTYPE',P_TRANSACTIONTYPE);
        WSH_DEBUG_SV.log(l_module_name,'P_RECEIPTAGAINSTASN',P_RECEIPTAGAINSTASN);
        WSH_DEBUG_SV.log(l_module_name,'P_AUTONOMOUS',P_AUTONOMOUS);
        WSH_DEBUG_SV.log(l_module_name,'P_INDEX',P_INDEX);
    END IF;
    --
    l_txnHistoryRec.RECEIPT_NUMBER      := p_line_rec.receipt_num(p_index);
    l_txnHistoryRec.SHIPMENT_NUMBER     := p_line_rec.shipment_num(p_index);
    l_txnHistoryRec.TRANSACTION_TYPE    := p_transactionType;
    l_txnHistoryRec.SHIPMENT_HEADER_ID  := p_line_rec.shipment_header_id(p_index);
    l_txnHistoryRec.ORGANIZATION_ID     := p_line_rec.organization_id(p_index);
    l_txnHistoryRec.SUPPLIER_ID         := p_line_rec.vendor_id(p_index);
    l_txnHistoryRec.SHIPPED_DATE        := p_line_rec.shipped_date(p_index);
    l_txnHistoryRec.RECEIPT_DATE        := p_line_rec.expected_receipt_date(p_index);
    l_txnHistoryRec.CARRIER_ID          := p_line_rec.rcv_carrier_id(p_index);
    l_txnHistoryRec.SHIP_FROM_LOCATION_ID := p_ship_from_location_id; -- IB-Phase-2
    --
    IF p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_ASN
    OR p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT
    THEN
        l_txnHistoryRec.STATUS                  := WSH_INBOUND_TXN_HISTORY_PKG.C_PENDING;
        --
        l_txnHistoryRec.MAX_RCV_TRANSACTION_ID  := GREATEST(
                                                             p_line_rec.rcv_transaction_id(p_index),
                                                             p_line_rec.rcv_transaction_id(p_line_rec.rcv_transaction_id.FIRST)
                                                           );
        l_txnHistoryRec.MAX_RCV_TRANSACTION_ID  := GREATEST(
                                                             l_txnHistoryRec.MAX_RCV_TRANSACTION_ID,
                                                             p_line_rec.rcv_transaction_id(p_line_rec.rcv_transaction_id.LAST)
                                                           );
    ELSE
        l_txnHistoryRec.STATUS                  := WSH_INBOUND_TXN_HISTORY_PKG.C_PENDING; --_PARENT_MATCHING;
        l_txnHistoryRec.MAX_RCV_TRANSACTION_ID  := p_line_rec.rcv_transaction_id(p_index);
        l_txnHistoryRec.SHIPMENT_LINE_ID        := p_line_rec.shipment_line_id(p_index);
    END IF;
    --
    IF p_ReceiptAgainstASN = 'Y'
    THEN
        l_txnHistoryRec.PARENT_SHIPMENT_HEADER_ID := p_line_rec.shipment_header_id(p_index);
    END IF;
    --
    --
    IF p_autonomous
    THEN
    --{
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_TXN_HISTORY_PKG.AUTONOMOUS_CREATE',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        WSH_INBOUND_TXN_HISTORY_PKG.autonomous_Create
          (
            p_txn_history_rec => l_txnHistoryRec,
            x_txn_id          => x_transactionId,
            x_return_status   => l_return_status
          );
    --}
    ELSE
    --{
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_TXN_HISTORY_PKG.CREATE_TXN_HISTORY',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        WSH_INBOUND_TXN_HISTORY_PKG.create_txn_history
          (
            p_txn_history_rec => l_txnHistoryRec,
            x_txn_id          => x_transactionId,
            x_return_status   => l_return_status
          );
    --}
    END IF;
    --
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    wsh_util_core.api_post_call
      (
        p_return_status => l_return_status,
        x_num_warnings  => l_num_warnings,
        x_num_errors    => l_num_errors
      );
    --
    --
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
      wsh_util_core.default_handler('WSH_IB_TXN_MATCH_PKG.insertTransactionHistory');
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
--}
END insertTransactionHistory;
--
--
--========================================================================
-- PROCEDURE : checkShipmentHistory
--
-- PARAMETERS: p_transactionType Transaction Type
--             p_line_rec        ASN/Receipt Lines
--             x_return_status   Return status of the API
--
--
-- COMMENT   :  Check shipment/receipt history.
--
--              For ASN/Receipt, check if same ASN/Receipt is being interfaced again
--                - If so, raise error
--                - If not, insert a record into WSH_INBOUND_TXN_HISTORY and lock it
--
--              For other transactions, obtain parent(ASN/Receipt) record from
--              WSH_INBOUND_TXN_HISTORY and lock it.
--========================================================================
--
PROCEDURE checkShipmentHistory
            (
              p_transactionType       IN              VARCHAR2,
              p_shipmentHeaderId      IN              NUMBER,
              p_ReceiptAgainstASN     IN              VARCHAR2,
              p_inboundTxnHistoryId   IN              NUMBER,
              p_line_rec              IN              OE_WSH_BULK_GRP.Line_rec_type,
	      p_ship_from_location_id IN              NUMBER, -- IB-Phase-2
              x_parentTxnHistoryRec   OUT     NOCOPY  WSH_INBOUND_TXN_HISTORY_PKG.ib_txn_history_rec_type,
              x_transactionId         OUT     NOCOPY  NUMBER,
              x_transactionGroup      OUT     NOCOPY  VARCHAR2,
              x_return_status         OUT     NOCOPY  VARCHAR2
            )
IS
--{
    l_num_warnings              NUMBER  := 0;
    l_num_errors                NUMBER  := 0;
    l_return_status             VARCHAR2(30);
    l_locked                    VARCHAR2(1);
    --
    l_txnHistoryRec             WSH_INBOUND_TXN_HISTORY_PKG.ib_txn_history_rec_type;
    l_parentTxnHistoryRec       WSH_INBOUND_TXN_HISTORY_PKG.ib_txn_history_rec_type;
    --
    l_parentShipmentHeaderId    NUMBER;
    l_parentTransactionType     VARCHAR2(30);
    l_on_noDataFound            VARCHAR2(30);
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECKSHIPMENTHISTORY';
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
        --
        WSH_DEBUG_SV.log(l_module_name,'P_TRANSACTIONTYPE',P_TRANSACTIONTYPE);
        WSH_DEBUG_SV.log(l_module_name,'P_SHIPMENTHEADERID',P_SHIPMENTHEADERID);
        WSH_DEBUG_SV.log(l_module_name,'P_RECEIPTAGAINSTASN',P_RECEIPTAGAINSTASN);
        WSH_DEBUG_SV.log(l_module_name,'p_inboundTxnHistoryId',p_inboundTxnHistoryId);
    END IF;
    --
    IF p_transactionType IN (
                              WSH_INBOUND_TXN_HISTORY_PKG.C_ASN,
                              WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT
                            )
    THEN
    --{
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_TXN_HISTORY_PKG.GET_TXN_HISTORY',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        -- Check if record already exists in WSH_INBOUND_TXN_HISTORY
        --
        WSH_INBOUND_TXN_HISTORY_PKG.get_txn_history
          (
            p_shipment_header_id    => p_shipmentHeaderId,
            p_transaction_type      => p_transactionType,
            x_txn_history_rec       => l_txnHistoryRec,
            x_return_status         => l_return_status
          );
        --
        --
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.api_post_call
          (
            p_return_status => l_return_status,
            x_num_warnings  => l_num_warnings,
            x_num_errors    => l_num_errors
          );
        --
        --
        IF l_txnHistoryRec.transaction_id IS NOT NULL
        THEN
        --{
            IF p_inboundTxnHistoryId IS NULL
            THEN
            --{
                -- Record already exists in WSH_INBOUND_TXN_HISTORY, raise error
                --
                IF p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_ASN
                THEN
                    FND_MESSAGE.SET_NAME('WSH','WSH_IB_DUP_ASN_ERROR');
                    FND_MESSAGE.SET_TOKEN('SHIPMENT_NUMBER',l_txnHistoryRec.SHIPMENT_NUMBER);
                ELSIF p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT
                THEN
                    FND_MESSAGE.SET_NAME('WSH','WSH_IB_DUP_RECPT_ERROR');
                    FND_MESSAGE.SET_TOKEN('RECEIPT_NUMBER',l_txnHistoryRec.RECEIPT_NUMBER);
                END IF;
                --
                wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
                RAISE FND_API.G_EXC_ERROR;
            --}
            ELSE
            --{
                x_transactionId := l_txnHistoryRec.transaction_id;
            --}
            END IF;
        --}
        --ELSIF l_txnHistoryRec.transaction_id IS NULL
        --THEN
        ELSE
        --{
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_IB_TXN_MATCH_PKG.INSERTTRANSACTIONHISTORY',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_IB_TXN_MATCH_PKG.insertTransactionHistory
              (
                p_transactionType       => p_transactionType,
                p_ReceiptAgainstASN     => p_ReceiptAgainstASN,
                p_autonomous            => TRUE,
                p_index                 => p_line_rec.shipment_line_id.FIRST,
                p_line_rec              => p_line_rec,
		p_ship_from_location_id => p_ship_from_location_id, -- IB-Phase-2
                x_transactionId         => x_transactionId,
                x_return_status         => l_return_status
              );
            --
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            wsh_util_core.api_post_call
              (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors
              );
            --
            --
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_TXN_HISTORY_PKG.LOCK_ASN_RECEIPT_HEADER',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_INBOUND_TXN_HISTORY_PKG.lock_asn_receipt_header
              (
                p_shipment_header_id  => p_shipmentHeaderId,
                p_transaction_type    => p_transactionType,
                p_on_error            => 'RETRY',
                p_on_noDataFound      => WSH_UTIL_CORE.G_RET_STS_ERROR,
                x_txn_history_rec     => l_txnHistoryRec,
                x_return_status       => l_return_status,
                x_locked              => l_locked
              );
            --
            --
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
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
    --}
    END IF;
    --
    --
    l_parentShipmentHeaderId  := NULL;
    l_parentTransactionType   := NULL;
    l_on_noDataFound          := WSH_UTIL_CORE.G_RET_STS_ERROR;
    --
    IF p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_ASN
    THEN
        x_transactionGroup := WSH_INBOUND_TXN_HISTORY_PKG.C_ASN;
    ELSIF p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_CANCEL_ASN
    THEN
    --{
        l_parentShipmentHeaderId  := p_shipmentHeaderId;
        l_parentTransactionType   := WSH_INBOUND_TXN_HISTORY_PKG.C_ASN;
        x_transactionGroup        := WSH_INBOUND_TXN_HISTORY_PKG.C_ASN;
        l_on_noDataFound          := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    --}
    ELSIF p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT
    THEN
    --{
        x_transactionGroup        := WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT;
        --
        IF p_ReceiptAgainstASN = 'Y'
        THEN
            l_parentShipmentHeaderId  := p_shipmentHeaderId;
            l_parentTransactionType   := WSH_INBOUND_TXN_HISTORY_PKG.C_ASN;
        END IF;
    --}
    ELSIF p_transactionType IN (
                                 WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_CORRECTION,
                                 WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_CORRECTION_POSITIVE,
                                 WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_CORRECTION_NEGATIVE,
                                 WSH_INBOUND_TXN_HISTORY_PKG.C_RTV               ,
                                 WSH_INBOUND_TXN_HISTORY_PKG.C_RTV_CORRECTION    ,
                                 WSH_INBOUND_TXN_HISTORY_PKG.C_RTV_CORRECTION_POSITIVE    ,
                                 WSH_INBOUND_TXN_HISTORY_PKG.C_RTV_CORRECTION_NEGATIVE    ,
                                 WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_ADD       ,
                                 WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_HEADER_UPD
                               )
    THEN
    --{
        x_transactionGroup        := WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT;
        l_parentShipmentHeaderId  := p_shipmentHeaderId;
        l_parentTransactionType   := WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT;
        --
        IF p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_HEADER_UPD
        THEN
            l_on_noDataFound      := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
        END IF;
    --}
    ELSE
    --{
        FND_MESSAGE.SET_NAME('WSH','WSH_IB_INVALID_TXN_TYPE');
        FND_MESSAGE.SET_TOKEN('TXN_TYPE',p_transactionType);
        wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
        RAISE FND_API.G_EXC_ERROR;
    --}
    END IF;
    --
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_parentShipmentHeaderId',l_parentShipmentHeaderId);
        WSH_DEBUG_SV.log(l_module_name,'l_parentTransactionType',l_parentTransactionType);
        WSH_DEBUG_SV.log(l_module_name,'l_on_noDataFound',l_on_noDataFound);
    END IF;
    --
    --
    IF l_parentShipmentHeaderId IS NOT NULL
    THEN
    --{
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_TXN_HISTORY_PKG.LOCK_ASN_RECEIPT_HEADER',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        WSH_INBOUND_TXN_HISTORY_PKG.lock_asn_receipt_header
          (
            p_shipment_header_id  => l_parentShipmentHeaderId,
            p_transaction_type    => l_parentTransactionType,
            p_on_error            => 'RETRY',
            p_on_noDataFound      => l_on_noDataFound,
            x_txn_history_rec     => l_parentTxnHistoryRec,
            x_return_status       => l_return_status,
            x_locked              => l_locked
          );
        --
        --
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
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
    x_parentTxnHistoryRec := l_parentTxnHistoryRec;
    --
    --
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
      wsh_util_core.default_handler('WSH_IB_TXN_MATCH_PKG.checkShipmentHistory');
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
--}
END checkShipmentHistory;
--
--
--========================================================================
-- PROCEDURE : processCancelASN
--
-- PARAMETERS: x_parentTxnHistoryRec  WSH_INBOUND_TXN_HISTORY record for ASN
--             x_return_status        Return status of the API
--
--
-- COMMENT   :  Processes Cancel ASN transaction. It is called by matchTransaction API
--              after locking the inbound transaction history record for ASN.
--
--              If ASN has already matched, call WSH_ASN_RECEIPT_PVT.Cancel_ASN to
--              perform ASN cancel operation (revert delivery/line/trip/stop status,
--              update shipped quantity to null etc.)
--
--              Update inbound transaction history record for ASN with Cancelled status.
--
--========================================================================
--
PROCEDURE processCancelASN
            (
              x_parentTxnHistoryRec   IN  OUT NOCOPY  WSH_INBOUND_TXN_HISTORY_PKG.ib_txn_history_rec_type,
              x_return_status         OUT     NOCOPY  VARCHAR2
            )
IS
--{
    l_num_warnings              NUMBER  := 0;
    l_num_errors                NUMBER  := 0;
    l_return_status             VARCHAR2(30);
    --
    l_action_prms               wsh_glbl_var_strct_grp.dd_action_parameters_rec_type;
    --
    l_transactionMeaning        VARCHAR2(80);
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PROCESSCANCELASN';
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
        WSH_DEBUG_SV.log(l_module_name,'x_parentTxnHistoryRec.transaction_id',x_parentTxnHistoryRec.transaction_id);
        WSH_DEBUG_SV.log(l_module_name,'x_parentTxnHistoryRec.status',x_parentTxnHistoryRec.status);
    END IF;
    --
    IF x_parentTxnHistoryRec.transaction_id IS NOT NULL
    THEN
    --{
        IF x_parentTxnHistoryRec.status = WSH_INBOUND_TXN_HISTORY_PKG.C_CANCELLED
        THEN
        --{
            FND_MESSAGE.SET_NAME('WSH','WSH_IB_DUP_CANCEL_ASN_ERROR');
            FND_MESSAGE.SET_TOKEN('SHIPMENT_NUMBER',x_parentTxnHistoryRec.SHIPMENT_NUMBER);
            wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
            RAISE FND_API.G_EXC_ERROR;
        --}
        END IF;
        --
        --
        IF    x_parentTxnHistoryRec.status = WSH_INBOUND_TXN_HISTORY_PKG.C_MATCHED
        THEN
        --{
            l_action_prms.action_code := WSH_INBOUND_TXN_HISTORY_PKG.C_CANCEL_ASN;
            --
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ASN_RECEIPT_PVT.CANCEL_ASN',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_ASN_RECEIPT_PVT.Cancel_ASN
              (
                p_header_id       =>  x_parentTxnHistoryRec.shipment_header_id,
                p_action_prms     =>  l_action_prms,
                x_return_status   =>  l_return_status
              );
            --
            --
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            wsh_util_core.api_post_call
              (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors
              );
        --}
        END IF;
        --
        --
        IF x_parentTxnHistoryRec.status = WSH_INBOUND_TXN_HISTORY_PKG.C_MATCHED
        OR x_parentTxnHistoryRec.status = WSH_INBOUND_TXN_HISTORY_PKG.C_PENDING
        THEN
        --{
            x_parentTxnHistoryRec.status := WSH_INBOUND_TXN_HISTORY_PKG.C_CANCELLED;
            --
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_TXN_HISTORY_PKG.UPDATE_TXN_HISTORY',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_INBOUND_TXN_HISTORY_PKG.update_txn_history
              (
                p_txn_history_rec    => x_parentTxnHistoryRec,
                x_return_status      => l_return_status
              );
            --
            --
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            wsh_util_core.api_post_call
              (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors
              );
        --}
        ELSE
        --{
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_TXN_HISTORY_PKG.GETTRANSACTIONTYPEMEANING',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_INBOUND_TXN_HISTORY_PKG.getTransactionTypeMeaning
              (
                p_transactionType     => WSH_INBOUND_TXN_HISTORY_PKG.C_ASN,
                x_transactionMeaning  => l_transactionMeaning,
                x_return_status       => l_return_status
              );
            --
            --
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            wsh_util_core.api_post_call
              (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors
              );
            --
            --
            FND_MESSAGE.SET_NAME('WSH','WSH_IB_TXN_INVALID_STATUS');
            FND_MESSAGE.SET_TOKEN('STATUS_CODE',x_parentTxnHistoryRec.status);
            FND_MESSAGE.SET_TOKEN('TRANSACTION_TYPE',l_transactionMeaning);
            FND_MESSAGE.SET_TOKEN('RECEIPT_NUM',x_parentTxnHistoryRec.RECEIPT_NUMBER);
            FND_MESSAGE.SET_TOKEN('SHIPMENT_NUM',x_parentTxnHistoryRec.SHIPMENT_NUMBER);
            wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
            RAISE FND_API.G_EXC_ERROR;
        --}
        END IF;
    --}
    END IF;
    --
    --
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
      wsh_util_core.default_handler('WSH_IB_TXN_MATCH_PKG.processCancelASN');
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
--}
END processCancelASN;

PROCEDURE processReceiptHeaderUpdate
            (
              x_parentTxnHistoryRec   IN  OUT NOCOPY  WSH_INBOUND_TXN_HISTORY_PKG.ib_txn_history_rec_type,
              x_return_status         OUT     NOCOPY  VARCHAR2
            )
IS
--{
    l_num_warnings              NUMBER  := 0;
    l_num_errors                NUMBER  := 0;
    l_return_status             VARCHAR2(30);
    --
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PROCESSRECEIPTHEADERUPDATE';
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
    END IF;
    --
    NULL;
    --
    --
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
      wsh_util_core.default_handler('WSH_IB_TXN_MATCH_PKG.processReceiptHeaderUpdate');
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
--}
END processReceiptHeaderUpdate;

PROCEDURE extendLineRecTbl
            (
              p_extendBy               IN             NUMBER,
              x_lineRecTbl             IN OUT NOCOPY  line_recTbl_type,
              x_return_status          OUT    NOCOPY  VARCHAR2
            )
IS
--{
    l_num_warnings              NUMBER  := 0;
    l_num_errors                NUMBER  := 0;
    l_return_status             VARCHAR2(30);
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'EXTENDLINERECTBL';
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
        --
        WSH_DEBUG_SV.log(l_module_name,'P_EXTENDBY',P_EXTENDBY);
    END IF;
    --
    x_lineRecTbl.delivery_detail_id_tbl.EXTEND(p_extendBy);
    x_lineRecTbl.requested_quantity_tbl.EXTEND(p_extendBy);
    x_lineRecTbl.picked_quantity_tbl.EXTEND(p_extendBy);
    x_lineRecTbl.shipped_quantity_tbl.EXTEND(p_extendBy);
    x_lineRecTbl.received_quantity_tbl.EXTEND(p_extendBy);
    x_lineRecTbl.returned_quantity_tbl.EXTEND(p_extendBy);
    x_lineRecTbl.requested_quantity2_tbl.EXTEND(p_extendBy);
    x_lineRecTbl.picked_quantity2_tbl.EXTEND(p_extendBy);
    x_lineRecTbl.shipped_quantity2_tbl.EXTEND(p_extendBy);
    x_lineRecTbl.received_quantity2_tbl.EXTEND(p_extendBy);
    x_lineRecTbl.returned_quantity2_tbl.EXTEND(p_extendBy);
    x_lineRecTbl.ship_from_location_id_tbl.EXTEND(p_extendBy);
    x_lineRecTbl.earliest_dropoff_date_tbl.EXTEND(p_extendBy);
    x_lineRecTbl.delivery_id_tbl.EXTEND(p_extendBy);
    x_lineRecTbl.rcv_shipment_line_id_tbl.EXTEND(p_extendBy);
    x_lineRecTbl.requested_quantity_uom_tbl.EXTEND(p_extendBy);
    x_lineRecTbl.requested_quantity_uom2_tbl.EXTEND(p_extendBy);
    x_lineRecTbl.released_status_tbl.EXTEND(p_extendBy);
    x_lineRecTbl.src_requested_quantity_tbl.EXTEND(p_extendBy);
    x_lineRecTbl.src_requested_quantity2_tbl.EXTEND(p_extendBy);
    x_lineRecTbl.last_update_date_tbl.EXTEND(p_extendBy);
    --
    --
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
      wsh_util_core.default_handler('WSH_IB_TXN_MATCH_PKG.extendLineRecTbl');
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
--}
END extendLineRecTbl;
--
-- add a new delivery line (Ordered qty.=0)
--
PROCEDURE addNewLine
            (
              p_lineDate                  IN          DATE,
              p_primaryUomCode            IN          VARCHAR2,
              p_secondaryUomCode          IN          VARCHAR2,
              x_lineRecTbl             IN OUT NOCOPY  line_recTbl_type,
              x_return_status             OUT NOCOPY  VARCHAR2
            )
IS
--{
    l_num_warnings              NUMBER  := 0;
    l_num_errors                NUMBER  := 0;
    l_return_status             VARCHAR2(30);
    l_index                     NUMBER := 1;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ADDNEWLINE';
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
        --
        WSH_DEBUG_SV.log(l_module_name,'P_LINEDATE',P_LINEDATE);
        WSH_DEBUG_SV.log(l_module_name,'P_PRIMARYUOMCODE',P_PRIMARYUOMCODE);
        WSH_DEBUG_SV.log(l_module_name,'P_SECONDARYUOMCODE',P_SECONDARYUOMCODE);
    END IF;
    --
    IF NOT x_lineRecTbl.released_status_tbl.EXISTS(l_index)
    THEN
    --{
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_IB_TXN_MATCH_PKG.EXTENDLINERECTBL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        WSH_IB_TXN_MATCH_PKG.extendLineRecTbl
          (
            p_extendBy        => 1,
            x_lineRecTbl      => x_lineRecTbl,
            x_return_status   => l_return_status
          );
        --
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.api_post_call
          (
            p_return_status => l_return_status,
            x_num_warnings  => l_num_warnings,
            x_num_errors    => l_num_errors
          );
    --}
    END IF;
    --
    x_lineRecTbl.delivery_detail_id_tbl(l_index)      := NULL;
    x_lineRectbl.requested_quantity_tbl(l_index)      := 0;
    x_lineRectbl.picked_quantity_tbl(l_index)         := NULL;
    x_lineRectbl.shipped_quantity_tbl(l_index)        := NULL;
    x_lineRectbl.received_quantity_tbl(l_index)       := NULL;
    x_lineRectbl.returned_quantity_tbl(l_index)       := NULL;
    x_lineRectbl.requested_quantity2_tbl(l_index)     := 0;
    x_lineRectbl.picked_quantity2_tbl(l_index)        := NULL;
    x_lineRectbl.shipped_quantity2_tbl(l_index)       := NULL;
    x_lineRectbl.received_quantity2_tbl(l_index)      := NULL;
    x_lineRectbl.returned_quantity2_tbl(l_index)      := NULL;
    x_lineRectbl.ship_from_location_id_tbl(l_index)   := WSH_UTIL_CORE.C_NULL_SF_LOCN_ID;
    x_lineRectbl.earliest_dropoff_date_tbl(l_index)   := p_lineDate;
    x_lineRectbl.delivery_id_tbl(l_index)             := NULL;
    x_lineRectbl.rcv_shipment_line_id_tbl(l_index)    := NULL;
    x_lineRectbl.requested_quantity_uom_tbl(l_index)  := p_primaryUomCode;
    x_lineRectbl.requested_quantity_uom2_tbl(l_index) := p_secondaryUomCode;
    x_lineRectbl.released_status_tbl(l_index)         := 'X';
    x_lineRectbl.src_requested_quantity_tbl(l_index)  := NULL;
    x_lineRectbl.src_requested_quantity2_tbl(l_index) := NULL;
    --
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
      wsh_util_core.default_handler('WSH_IB_TXN_MATCH_PKG.addNewLine');
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
--}
END addNewLine;
--
--
PROCEDURE extendMatchedLineRecTbl
            (
              p_extendBy               IN             NUMBER,
              x_matchedLineRecTbl      IN OUT NOCOPY  WSH_IB_UI_RECON_GRP.asn_rcv_del_det_rec_type,
              x_return_status          OUT    NOCOPY  VARCHAR2
            )
IS
--{
    l_num_warnings              NUMBER  := 0;
    l_num_errors                NUMBER  := 0;
    l_return_status             VARCHAR2(30);
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'EXTENDMATCHEDLINERECTBL';
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
        --
        WSH_DEBUG_SV.log(l_module_name,'P_EXTENDBY',P_EXTENDBY);
    END IF;
    --
    x_matchedLineRecTbl.del_detail_id_tab.EXTEND(p_extendBy);
    x_matchedLineRecTbl.parent_delivery_detail_id_tab.EXTEND(p_extendBy);
    --
    x_matchedLineRecTbl.requested_qty_tab.EXTEND(p_extendBy);
    x_matchedLineRecTbl.picked_qty_tab.EXTEND(p_extendBy);
    x_matchedLineRecTbl.shipped_qty_tab.EXTEND(p_extendBy);
    x_matchedLineRecTbl.received_qty_tab.EXTEND(p_extendBy);
    x_matchedLineRecTbl.returned_qty_tab.EXTEND(p_extendBy);
    --
    x_matchedLineRecTbl.requested_qty2_tab.EXTEND(p_extendBy);
    x_matchedLineRecTbl.picked_qty2_tab.EXTEND(p_extendBy);
    x_matchedLineRecTbl.shipped_qty2_tab.EXTEND(p_extendBy);
    x_matchedLineRecTbl.received_qty2_tab.EXTEND(p_extendBy);
    x_matchedLineRecTbl.returned_qty2_tab.EXTEND(p_extendBy);
    --
    x_matchedLineRecTbl.requested_qty_db_tab.EXTEND(p_extendBy);
    x_matchedLineRecTbl.picked_qty_db_tab.EXTEND(p_extendBy);
    x_matchedLineRecTbl.shipped_qty_db_tab.EXTEND(p_extendBy);
    x_matchedLineRecTbl.received_qty_db_tab.EXTEND(p_extendBy);
    x_matchedLineRecTbl.returned_qty_db_tab.EXTEND(p_extendBy);
    --
    x_matchedLineRecTbl.requested_qty2_db_tab.EXTEND(p_extendBy);
    x_matchedLineRecTbl.picked_qty2_db_tab.EXTEND(p_extendBy);
    x_matchedLineRecTbl.shipped_qty2_db_tab.EXTEND(p_extendBy);
    x_matchedLineRecTbl.received_qty2_db_tab.EXTEND(p_extendBy);
    x_matchedLineRecTbl.returned_qty2_db_tab.EXTEND(p_extendBy);
    --
    x_matchedLineRecTbl.line_date_tab.EXTEND(p_extendBy);
    x_matchedLineRecTbl.ship_from_location_id_tab.EXTEND(p_extendBy);
    x_matchedLineRecTbl.released_status_tab.EXTEND(p_extendBy);
    x_matchedLineRecTbl.requested_qty_uom_tab.EXTEND(p_extendBy);
    x_matchedLineRecTbl.requested_qty_uom2_tab.EXTEND(p_extendBy);
    --
    x_matchedLineRecTbl.po_header_id_tab.EXTEND(p_extendBy);
    x_matchedLineRecTbl.po_line_location_id_tab.EXTEND(p_extendBy);
    x_matchedLineRecTbl.po_line_id_tab.EXTEND(p_extendBy);
    x_matchedLineRecTbl.delivery_id_tab.EXTEND(p_extendBy);
    x_matchedLineRecTbl.trip_id_tab.EXTEND(p_extendBy);
    --
    x_matchedLineRecTbl.shipment_line_id_db_tab.EXTEND(p_extendBy);
    x_matchedLineRecTbl.shipment_line_id_tab.EXTEND(p_extendBy);
    x_matchedLineRecTbl.child_index_tab.EXTEND(p_extendBy);
    x_matchedLineRecTbl.shpmt_line_id_idx_tab.EXTEND(p_extendBy);
    --
    x_matchedLineRecTbl.process_corr_rtv_flag_tab.EXTEND(p_extendBy);
    x_matchedLineRecTbl.process_asn_rcv_flag_tab.EXTEND(p_extendBy);
    x_matchedLineRecTbl.match_flag_tab.EXTEND(p_extendBy);
    x_matchedLineRecTbl.last_update_date_tab.EXTEND(p_extendBy);
    x_matchedLineRecTbl.lineCount_tab.EXTEND(p_extendBy);
    --
    --
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
      wsh_util_core.default_handler('WSH_IB_TXN_MATCH_PKG.extendMatchedLineRecTbl');
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
--}
END extendMatchedLineRecTbl;
--
--
--
--========================================================================
-- PROCEDURE : copyMatchedLine
--
-- PARAMETERS: p_sourceindex      Source Line Index
--             p_destinationindex Destination Index
--             x_matchedLineRecTbl Table of matched delivery lines.
--             x_return_status   Return status of the API
--
--
-- COMMENT   :  Copies a line from p_sourceindex to p_destinationindex in x_matchedLineRecTbl
--
--========================================================================
--
--
PROCEDURE copyMatchedLine
            (
              p_sourceindex               IN          NUMBER,
              p_destinationindex          IN          NUMBER,
              x_matchedLineRecTbl      IN OUT NOCOPY  WSH_IB_UI_RECON_GRP.asn_rcv_del_det_rec_type,
              x_return_status             OUT NOCOPY  VARCHAR2
            )
IS
--{
    l_num_warnings              NUMBER  := 0;
    l_num_errors                NUMBER  := 0;
    l_return_status             VARCHAR2(30);
    --
    l_extendBy                  NUMBER;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'COPYMATCHEDLINE';
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
        --
        WSH_DEBUG_SV.log(l_module_name,'P_SOURCEINDEX',P_SOURCEINDEX);
        WSH_DEBUG_SV.log(l_module_name,'P_DESTINATIONINDEX',P_DESTINATIONINDEX);
        WSH_DEBUG_SV.log(l_module_name,'x_matchedLineRecTbl.match_flag_tab.COUNT',x_matchedLineRecTbl.match_flag_tab.COUNT);
    END IF;
    --
    IF NOT  x_matchedLineRecTbl.match_flag_tab.EXISTS(p_destinationIndex)
    THEN
    --{
        l_extendBy := p_destinationIndex - x_matchedLineRecTbl.match_flag_tab.COUNT;
        --
        IF l_extendBy > 0
        THEN
        --{
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_extendBy',l_extendBy);
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_IB_TXN_MATCH_PKG.EXTENDMATCHEDLINERECTBL',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_IB_TXN_MATCH_PKG.extendMatchedLineRecTbl
              (
                p_extendBy            => l_extendBy,
                x_matchedLineRecTbl   => x_matchedLineRecTbl,
                x_return_status       => l_return_status
              );
            --
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            wsh_util_core.api_post_call
              (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors
              );
        --}
        END IF;
    --}
    END IF;
    --
    --
    x_matchedLineRecTbl.del_detail_id_tab(p_destinationIndex)          :=  x_matchedLineRecTbl.del_detail_id_tab(p_sourceIndex);
    --                                                                     --
    x_matchedLineRecTbl.requested_qty_tab(p_destinationIndex)          :=  x_matchedLineRecTbl.requested_qty_tab(p_sourceIndex);
    x_matchedLineRecTbl.picked_qty_tab(p_destinationIndex)             :=  x_matchedLineRecTbl.picked_qty_tab(p_sourceIndex);
    x_matchedLineRecTbl.shipped_qty_tab(p_destinationIndex)            :=  x_matchedLineRecTbl.shipped_qty_tab(p_sourceIndex);
    x_matchedLineRecTbl.received_qty_tab(p_destinationIndex)           :=  x_matchedLineRecTbl.received_qty_tab(p_sourceIndex);
    x_matchedLineRecTbl.returned_qty_tab(p_destinationIndex)           :=  x_matchedLineRecTbl.returned_qty_tab(p_sourceIndex);
    --                                                                     --
    x_matchedLineRecTbl.requested_qty2_tab(p_destinationIndex)         :=  x_matchedLineRecTbl.requested_qty2_tab(p_sourceIndex);
    x_matchedLineRecTbl.picked_qty2_tab(p_destinationIndex)            :=  x_matchedLineRecTbl.picked_qty2_tab(p_sourceIndex);
    x_matchedLineRecTbl.shipped_qty2_tab(p_destinationIndex)           :=  x_matchedLineRecTbl.shipped_qty2_tab(p_sourceIndex);
    x_matchedLineRecTbl.received_qty2_tab(p_destinationIndex)          :=  x_matchedLineRecTbl.received_qty2_tab(p_sourceIndex);
    x_matchedLineRecTbl.returned_qty2_tab(p_destinationIndex)          :=  x_matchedLineRecTbl.returned_qty2_tab(p_sourceIndex);
    --                                                                     --
    x_matchedLineRecTbl.requested_qty_db_tab(p_destinationIndex)       :=  x_matchedLineRecTbl.requested_qty_db_tab(p_sourceIndex);
    x_matchedLineRecTbl.picked_qty_db_tab(p_destinationIndex)          :=  x_matchedLineRecTbl.picked_qty_db_tab(p_sourceIndex);
    x_matchedLineRecTbl.shipped_qty_db_tab(p_destinationIndex)         :=  x_matchedLineRecTbl.shipped_qty_db_tab(p_sourceIndex);
    x_matchedLineRecTbl.received_qty_db_tab(p_destinationIndex)        :=  x_matchedLineRecTbl.received_qty_db_tab(p_sourceIndex);
    x_matchedLineRecTbl.returned_qty_db_tab(p_destinationIndex)        :=  x_matchedLineRecTbl.returned_qty_db_tab(p_sourceIndex);
    --                                                                     --
    x_matchedLineRecTbl.requested_qty2_db_tab(p_destinationIndex)      :=  x_matchedLineRecTbl.requested_qty2_db_tab(p_sourceIndex);
    x_matchedLineRecTbl.picked_qty2_db_tab(p_destinationIndex)         :=  x_matchedLineRecTbl.picked_qty2_db_tab(p_sourceIndex);
    x_matchedLineRecTbl.shipped_qty2_db_tab(p_destinationIndex)        :=  x_matchedLineRecTbl.shipped_qty2_db_tab(p_sourceIndex);
    x_matchedLineRecTbl.received_qty2_db_tab(p_destinationIndex)       :=  x_matchedLineRecTbl.received_qty2_db_tab(p_sourceIndex);
    x_matchedLineRecTbl.returned_qty2_db_tab(p_destinationIndex)       :=  x_matchedLineRecTbl.returned_qty2_db_tab(p_sourceIndex);
    --                                                                     --
    x_matchedLineRecTbl.line_date_tab(p_destinationIndex)              :=  x_matchedLineRecTbl.line_date_tab(p_sourceIndex);
    x_matchedLineRecTbl.ship_from_location_id_tab(p_destinationIndex)  :=  x_matchedLineRecTbl.ship_from_location_id_tab(p_sourceIndex);
    x_matchedLineRecTbl.released_status_tab(p_destinationIndex)        :=  x_matchedLineRecTbl.released_status_tab(p_sourceIndex);
    x_matchedLineRecTbl.requested_qty_uom_tab(p_destinationIndex)      :=  x_matchedLineRecTbl.requested_qty_uom_tab(p_sourceIndex);
    x_matchedLineRecTbl.requested_qty_uom2_tab(p_destinationIndex)     :=  x_matchedLineRecTbl.requested_qty_uom2_tab(p_sourceIndex);
    --                                                                     --
    x_matchedLineRecTbl.po_header_id_tab(p_destinationIndex)           :=  x_matchedLineRecTbl.po_header_id_tab(p_sourceIndex);
    x_matchedLineRecTbl.po_line_location_id_tab(p_destinationIndex)    :=  x_matchedLineRecTbl.po_line_location_id_tab(p_sourceIndex);
    x_matchedLineRecTbl.po_line_id_tab(p_destinationIndex)             :=  x_matchedLineRecTbl.po_line_id_tab(p_sourceIndex);
    x_matchedLineRecTbl.delivery_id_tab(p_destinationIndex)            :=  x_matchedLineRecTbl.delivery_id_tab(p_sourceIndex);
    x_matchedLineRecTbl.trip_id_tab(p_destinationIndex)                :=  x_matchedLineRecTbl.trip_id_tab(p_sourceIndex);
    --                                                                     --
    x_matchedLineRecTbl.shipment_line_id_db_tab(p_destinationIndex)    :=  x_matchedLineRecTbl.shipment_line_id_db_tab(p_sourceIndex);
    x_matchedLineRecTbl.shipment_line_id_tab(p_destinationIndex)       :=  x_matchedLineRecTbl.shipment_line_id_tab(p_sourceIndex);
    x_matchedLineRecTbl.child_index_tab(p_destinationIndex)            :=  x_matchedLineRecTbl.child_index_tab(p_sourceIndex);
    x_matchedLineRecTbl.shpmt_line_id_idx_tab(p_destinationIndex)      :=  x_matchedLineRecTbl.shpmt_line_id_idx_tab(p_sourceIndex);
    --                                                                     --
    x_matchedLineRecTbl.process_corr_rtv_flag_tab(p_destinationIndex)  :=  x_matchedLineRecTbl.process_corr_rtv_flag_tab(p_sourceIndex);
    x_matchedLineRecTbl.process_asn_rcv_flag_tab(p_destinationIndex)   :=  x_matchedLineRecTbl.process_asn_rcv_flag_tab(p_sourceIndex);
    x_matchedLineRecTbl.match_flag_tab(p_destinationIndex)             :=  x_matchedLineRecTbl.match_flag_tab(p_sourceIndex);
    x_matchedLineRecTbl.last_update_date_tab(p_destinationIndex)       :=  x_matchedLineRecTbl.last_update_date_tab(p_sourceIndex);
    x_matchedLineRecTbl.lineCount_tab(p_destinationIndex)       :=  x_matchedLineRecTbl.lineCount_tab(p_sourceIndex);
    --
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
      wsh_util_core.default_handler('WSH_IB_TXN_MATCH_PKG.copyMatchedLine');
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
--}
END copyMatchedLine;


PROCEDURE addNewMatchedLine
            (
              p_line_rec                  IN          OE_WSH_BULK_GRP.Line_Rec_Type,
              p_sourceindex               IN          NUMBER,
              p_lineDate                  IN          DATE,
              p_shipFromLocationId        IN          NUMBER,
              p_primaryUomCode            IN          VARCHAR2,
              p_secondaryUomCode          IN          VARCHAR2,
              p_destinationindex          IN          NUMBER,
              x_matchedLineRecTbl      IN OUT NOCOPY  WSH_IB_UI_RECON_GRP.asn_rcv_del_det_rec_type,
              x_return_status             OUT NOCOPY  VARCHAR2
            )
IS
--{
    l_num_warnings              NUMBER  := 0;
    l_num_errors                NUMBER  := 0;
    l_return_status             VARCHAR2(30);
    --
    l_extendBy                  NUMBER;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ADDNEWMATCHEDLINE';
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
        --
        WSH_DEBUG_SV.log(l_module_name,'P_SOURCEINDEX',P_SOURCEINDEX);
        WSH_DEBUG_SV.log(l_module_name,'P_LINEDATE',P_LINEDATE);
        WSH_DEBUG_SV.log(l_module_name,'P_SHIPFROMLOCATIONID',P_SHIPFROMLOCATIONID);
        WSH_DEBUG_SV.log(l_module_name,'P_PRIMARYUOMCODE',P_PRIMARYUOMCODE);
        WSH_DEBUG_SV.log(l_module_name,'P_SECONDARYUOMCODE',P_SECONDARYUOMCODE);
        WSH_DEBUG_SV.log(l_module_name,'P_DESTINATIONINDEX',P_DESTINATIONINDEX);
        WSH_DEBUG_SV.log(l_module_name,'x_matchedLineRecTbl.match_flag_tab.COUNT',x_matchedLineRecTbl.match_flag_tab.COUNT);
    END IF;
    --
    IF NOT  x_matchedLineRecTbl.match_flag_tab.EXISTS(p_destinationIndex)
    THEN
    --{
        l_extendBy := p_destinationIndex - x_matchedLineRecTbl.match_flag_tab.COUNT;
        --
        IF l_extendBy > 0
        THEN
        --{
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_extendBy',l_extendBy);
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_IB_TXN_MATCH_PKG.EXTENDMATCHEDLINERECTBL',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_IB_TXN_MATCH_PKG.extendMatchedLineRecTbl
              (
                p_extendBy            => l_extendBy,
                x_matchedLineRecTbl   => x_matchedLineRecTbl,
                x_return_status       => l_return_status
              );
            --
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            wsh_util_core.api_post_call
              (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors
              );
        --}
        END IF;
    --}
    END IF;
    --
    x_matchedLineRecTbl.del_detail_id_tab(p_destinationIndex)          := NULL;
    --
    x_matchedLineRecTbl.requested_qty_tab(p_destinationIndex)          := 0;
    x_matchedLineRecTbl.picked_qty_tab(p_destinationIndex)             := NULL;
    x_matchedLineRecTbl.shipped_qty_tab(p_destinationIndex)            := NULL;
    x_matchedLineRecTbl.received_qty_tab(p_destinationIndex)           := NULL;
    x_matchedLineRecTbl.returned_qty_tab(p_destinationIndex)           := NULL;
    --
    x_matchedLineRecTbl.requested_qty2_tab(p_destinationIndex)         := 0;
    x_matchedLineRecTbl.picked_qty2_tab(p_destinationIndex)            := NULL;
    x_matchedLineRecTbl.shipped_qty2_tab(p_destinationIndex)           := NULL;
    x_matchedLineRecTbl.received_qty2_tab(p_destinationIndex)          := NULL;
    x_matchedLineRecTbl.returned_qty2_tab(p_destinationIndex)          := NULL;
    --
    x_matchedLineRecTbl.requested_qty_db_tab(p_destinationIndex)       := 0;
    x_matchedLineRecTbl.picked_qty_db_tab(p_destinationIndex)          := NULL;
    x_matchedLineRecTbl.shipped_qty_db_tab(p_destinationIndex)         := NULL;
    x_matchedLineRecTbl.received_qty_db_tab(p_destinationIndex)        := NULL;
    x_matchedLineRecTbl.returned_qty_db_tab(p_destinationIndex)        := NULL;
    --
    x_matchedLineRecTbl.requested_qty2_db_tab(p_destinationIndex)      := 0;
    x_matchedLineRecTbl.picked_qty2_db_tab(p_destinationIndex)         := NULL;
    x_matchedLineRecTbl.shipped_qty2_db_tab(p_destinationIndex)        := NULL;
    x_matchedLineRecTbl.received_qty2_db_tab(p_destinationIndex)       := NULL;
    x_matchedLineRecTbl.returned_qty2_db_tab(p_destinationIndex)       := NULL;
    --
    x_matchedLineRecTbl.line_date_tab(p_destinationIndex)              := p_lineDate;
    x_matchedLineRecTbl.ship_from_location_id_tab(p_destinationIndex)  := p_shipFromLocationId;
    x_matchedLineRecTbl.released_status_tab(p_destinationIndex)        := 'X';
    x_matchedLineRecTbl.requested_qty_uom_tab(p_destinationIndex)      := p_primaryUomCode;
    x_matchedLineRecTbl.requested_qty_uom2_tab(p_destinationIndex)     := p_secondaryUomCode;
    --
    x_matchedLineRecTbl.po_header_id_tab(p_destinationIndex)           := p_line_rec.header_id(p_sourceIndex);
    x_matchedLineRecTbl.po_line_location_id_tab(p_destinationIndex)    := p_line_rec.po_shipment_line_id(p_sourceIndex);
    x_matchedLineRecTbl.po_line_id_tab(p_destinationIndex)             := p_line_rec.line_id(p_sourceIndex);
    x_matchedLineRecTbl.delivery_id_tab(p_destinationIndex)            := NULL;
    x_matchedLineRecTbl.trip_id_tab(p_destinationIndex)                := NULL;
    --
    x_matchedLineRecTbl.shipment_line_id_db_tab(p_destinationIndex)    := NULL;
    x_matchedLineRecTbl.shipment_line_id_tab(p_destinationIndex)       := p_line_rec.shipment_line_id(p_sourceIndex);
    x_matchedLineRecTbl.child_index_tab(p_destinationIndex)            := NULL;
    x_matchedLineRecTbl.shpmt_line_id_idx_tab(p_destinationIndex)      := p_sourceIndex;
    --
    x_matchedLineRecTbl.process_corr_rtv_flag_tab(p_destinationIndex)  := C_NOT_PROCESS_FLAG;
    x_matchedLineRecTbl.process_asn_rcv_flag_tab(p_destinationIndex)   := C_NOT_PROCESS_FLAG;
    x_matchedLineRecTbl.match_flag_tab(p_destinationIndex)             := C_POTENTIAL_MATCH_FLAG;
    --
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
      wsh_util_core.default_handler('WSH_IB_TXN_MATCH_PKG.addNewMatchedLine');
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
--}
END addNewMatchedLine;
--
--
--========================================================================
-- PROCEDURE : splitLines
--
-- PARAMETERS: p_transactionType Transaction Type
--             p_line_rec        ASN/Receipt Lines
--             x_return_status   Return status of the API
--
--
-- COMMENT   :  Split or copy delivery lines corresponding to an ASN/Receipt line.
--              This is required as there can be multiple ASN/Receipt lines in a transaction
--              which corresponds to same PO shipment line.
--
--              For each delivery line, we check process_match_flag
--              If 'Y' (already processed), then we need to split the line
--              i.e. add a new line with requested quantity as REQ-SHP (ASN) or REQ-RCV(RECEIPT)
--              , inheriting other attributes from original line
--              If 'P' (not yet processed) then, we simply copy the line.
--
--========================================================================
--
--
PROCEDURE splitLines
            (
              p_txnUniqueSFLocnId       IN          NUMBER,
              p_transactionType         IN          VARCHAR2,
              p_transactionDate         IN          DATE,
              p_line_rec                IN          OE_WSH_BULK_GRP.Line_Rec_Type,
              p_line_rec_index          IN          NUMBER,
              x_matchedLineRecTbl    IN OUT NOCOPY  WSH_IB_UI_RECON_GRP.asn_rcv_del_det_rec_type,
              x_lineStartIndex       IN OUT NOCOPY  NUMBER,
              x_lineEndIndex         IN OUT NOCOPY  NUMBER,
              x_return_status           OUT NOCOPY  VARCHAR2
            )
IS
--{

    --
    l_num_warnings              NUMBER  := 0;
    l_num_errors                NUMBER  := 0;
    l_return_status             VARCHAR2(30);
    --
    l_lastRCVShipmentLineId     NUMBER          := NULL;
    l_lastDeliveryId            NUMBER          := NULL;
    l_lastDeliveryRecString     VARCHAR2(500)   := NULL;
    l_min_date                  DATE            := NULL;
    l_max_date                  DATE            := NULL;
    l_matchedCount              NUMBER          := 0;
    --
    l_start_index               NUMBER;
    l_end_index                 NUMBER;
    l_index                     NUMBER;
    l_RCVLineIndex              NUMBER;
    l_lineIndex                 NUMBER;
    l_lineEndIndex              NUMBER;
    --
    l_currentRCVShipmentLineId  NUMBER;
    l_deliveryId                NUMBER;
    l_DeliveryRecString         VARCHAR2(500);
    l_transactionDate           DATE;
    l_lineDate                  DATE;
    l_shipFromLocationId        NUMBER;
    l_carrierId                 NUMBER;
    l_transactionCarrierId      NUMBER;
    l_quantity                  NUMBER;
    l_quantity2                 NUMBER;
    l_parentDeliveryDetailId    NUMBER;
    --
    l_matchFlag                 VARCHAR2(10);
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SPLITLINES';
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
        --
        WSH_DEBUG_SV.log(l_module_name,'P_TXNUNIQUESFLOCNID',P_TXNUNIQUESFLOCNID);
        WSH_DEBUG_SV.log(l_module_name,'P_TRANSACTIONTYPE',P_TRANSACTIONTYPE);
        WSH_DEBUG_SV.log(l_module_name,'P_TRANSACTIONDATE',P_TRANSACTIONDATE);
        WSH_DEBUG_SV.log(l_module_name,'P_LINE_REC_INDEX',P_LINE_REC_INDEX);
        WSH_DEBUG_SV.log(l_module_name,'X_LINESTARTINDEX',X_LINESTARTINDEX);
        WSH_DEBUG_SV.log(l_module_name,'X_LINEENDINDEX',X_LINEENDINDEX);
    END IF;
    --
    l_lineIndex         := x_lineStartIndex;
    l_lineEndIndex      := x_lineEndIndex;
    --
    x_lineStartIndex  := NULL;
    x_lineEndIndex    := x_matchedLineRecTbl.match_flag_tab.COUNT;
    --
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_lineIndex',l_lineIndex);
        WSH_DEBUG_SV.log(l_module_name,'l_lineEndIndex',l_lineEndIndex);
        WSH_DEBUG_SV.log(l_module_name,'x_lineStartIndex',x_lineStartIndex);
        WSH_DEBUG_SV.log(l_module_name,'x_lineEndIndex',x_lineEndIndex);
    END IF;
    --
    --
    WHILE l_lineIndex IS NOT NULL
    AND   l_lineIndex <= l_lineEndIndex
    LOOP
    --{
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Processing record at l_lineIndex',l_lineIndex);
        END IF;
        --
        l_matchFlag := x_matchedLineRecTbl.match_flag_tab(l_lineIndex);
        --
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_matchFlag',l_matchFlag);
        END IF;
        --
        IF  l_matchFlag = C_PROCESS_FLAG
        THEN
        --{
            IF p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_ASN
            THEN
            --{
                l_quantity  := GREATEST
                                  (
                                    (
                                      NVL(x_matchedLineRecTbl.requested_qty_tab(l_lineIndex),0)
                                      - NVL(x_matchedLineRecTbl.shipped_qty_tab(l_lineIndex),0)
                                    ),
                                    0
                                  );
                --
                l_quantity2  := GREATEST
                                  (
                                    (
                                      NVL(x_matchedLineRecTbl.requested_qty2_tab(l_lineIndex),0)
                                      - NVL(x_matchedLineRecTbl.shipped_qty2_tab(l_lineIndex),0)
                                    ),
                                    0
                                  );
            --}
            ELSE
            --{
                l_quantity  := GREATEST
                                  (
                                    (
                                      NVL(x_matchedLineRecTbl.requested_qty_tab(l_lineIndex),0)
                                      - NVL(x_matchedLineRecTbl.received_qty_tab(l_lineIndex),0)
                                    ),
                                    0
                                  );
                --
                l_quantity2  := GREATEST
                                  (
                                    (
                                      NVL(x_matchedLineRecTbl.requested_qty2_tab(l_lineIndex),0)
                                      - NVL(x_matchedLineRecTbl.received_qty2_tab(l_lineIndex),0)
                                    ),
                                    0
                                  );
            --}
            END IF;
            --
            IF x_matchedLineRecTbl.parent_delivery_detail_id_tab(l_lineIndex) IS NULL
            THEN
                l_parentDeliveryDetailId := x_matchedLineRecTbl.del_detail_id_tab(l_lineIndex);
            ELSE
                l_parentDeliveryDetailId := x_matchedLineRecTbl.parent_delivery_detail_id_tab(l_lineIndex);
            END IF;
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'x_matchedLineRecTbl.parent_delivery_detail_id_tab(l_lineIndex)',x_matchedLineRecTbl.parent_delivery_detail_id_tab(l_lineIndex));
                WSH_DEBUG_SV.log(l_module_name,'x_matchedLineRecTbl.del_detail_id_tab(l_lineIndex)',x_matchedLineRecTbl.del_detail_id_tab(l_lineIndex));
                WSH_DEBUG_SV.log(l_module_name,'l_parentDeliveryDetailId',l_parentDeliveryDetailId);
                WSH_DEBUG_SV.log(l_module_name,'l_quantity',l_quantity);
                WSH_DEBUG_SV.log(l_module_name,'l_quantity2',l_quantity2);
            END IF;
            --
            --
            IF l_quantity > 0
            OR l_quantity2 > 0
            THEN
            --{
                x_lineEndIndex    := x_lineEndIndex + 1;
                x_lineStartIndex  := NVL(x_lineStartIndex,x_lineEndIndex);
                --
                --
                -- Debug Statements
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_IB_TXN_MATCH_PKG.ADDNEWMATCHEDLINE',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                WSH_IB_TXN_MATCH_PKG.addNewMatchedLine
                  (
                    p_line_rec            => p_line_rec,
                    p_sourceindex         => p_line_rec_index,
                    p_lineDate            => x_matchedLineRecTbl.line_date_tab(l_lineIndex),
                    p_shipFromLocationId  => x_matchedLineRecTbl.ship_from_location_id_tab(l_lineIndex),
                    p_primaryUomCode      => x_matchedLineRecTbl.requested_qty_uom_tab(l_lineIndex),
                    p_secondaryUomCode    => x_matchedLineRecTbl.requested_qty_uom2_tab(l_lineIndex),
                    p_destinationindex    => x_lineEndIndex,
                    x_matchedLineRecTbl   => x_matchedLineRecTbl,
                    x_return_status       => l_return_status
                  );
                --
                --
                --
                -- Debug Statements
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                wsh_util_core.api_post_call
                  (
                    p_return_status => l_return_status,
                    x_num_warnings  => l_num_warnings,
                    x_num_errors    => l_num_errors
                  );
                --
                --
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'Before Split-requested_qty_tab',x_matchedLineRecTbl.requested_qty_tab(l_lineIndex));
                    WSH_DEBUG_SV.log(l_module_name,'Before Split-requested_qty2_tab',x_matchedLineRecTbl.requested_qty2_tab(l_lineIndex) );
                END IF;
                --
                x_matchedLineRecTbl.requested_qty_tab(l_lineIndex)
                := NVL(x_matchedLineRecTbl.requested_qty_tab(l_lineIndex),0)
                   - l_quantity;
                --
                x_matchedLineRecTbl.requested_qty2_tab(l_lineIndex)
                := NVL(x_matchedLineRecTbl.requested_qty2_tab(l_lineIndex),0)
                   - l_quantity2;
                --
                --
                x_matchedLineRecTbl.child_index_tab(l_lineIndex) :=  x_lineEndIndex;
                --
                x_matchedLineRecTbl.requested_qty_tab(x_lineEndIndex)  := l_quantity;
                --
                x_matchedLineRecTbl.requested_qty2_tab(x_lineEndIndex) := l_quantity2;
                x_matchedLineRecTbl.delivery_id_tab(x_lineEndIndex)    := x_matchedLineRecTbl.delivery_id_tab(l_lineIndex);
                x_matchedLineRecTbl.parent_delivery_detail_id_tab(x_lineEndIndex)    := l_parentDeliveryDetailId ;
                --
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'After Split-requested_qty_tab',x_matchedLineRecTbl.requested_qty_tab(l_lineIndex));
                    WSH_DEBUG_SV.log(l_module_name,'After Split-requested_qty2_tab',x_matchedLineRecTbl.requested_qty2_tab(l_lineIndex) );
                    WSH_DEBUG_SV.log(l_module_name,'child_index',x_matchedLineRecTbl.child_index_tab(l_lineIndex));
                    WSH_DEBUG_SV.log(l_module_name,'New Line-requested_qty_tab',x_matchedLineRecTbl.requested_qty_tab(x_lineEndIndex));
                    WSH_DEBUG_SV.log(l_module_name,'New Line-requested_qty2_tab',x_matchedLineRecTbl.requested_qty2_tab(x_lineEndIndex));
                    WSH_DEBUG_SV.log(l_module_name,'New Line-delivery_id_tab',x_matchedLineRecTbl.delivery_id_tab(x_lineEndIndex));
                    WSH_DEBUG_SV.log(l_module_name,'New Line-parent wdd id tab',x_matchedLineRecTbl.parent_delivery_detail_id_tab(x_lineEndIndex));
                END IF;
                --
            --}
            END IF;
        --}
        ELSIF  l_matchFlag = C_POTENTIAL_MATCH_FLAG
        THEN
        --{
            x_lineEndIndex    := x_lineEndIndex + 1;
            x_lineStartIndex  := NVL(x_lineStartIndex,x_lineEndIndex);
            --
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_IB_TXN_MATCH_PKG.COPYMATCHEDLINE',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_IB_TXN_MATCH_PKG.copyMatchedLine
              (
                x_matchedLineRecTbl   => x_matchedLineRecTbl,
                p_sourceIndex         => l_lineIndex,
                p_destinationIndex    => x_lineEndIndex,
                x_return_status       => l_return_status
              );
            --
            --
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            wsh_util_core.api_post_call
              (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors
              );

        --}
        END IF;
        --
        l_lineIndex := x_matchedLineRecTbl.match_flag_tab.NEXT(l_lineIndex);
    --}
    END LOOP;
    --
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'x_lineStartIndex',x_lineStartIndex);
        WSH_DEBUG_SV.log(l_module_name,'x_lineEndIndex',x_lineEndIndex);
    END IF;
    --
    --
    IF x_lineStartIndex IS NULL
    THEN
    --{
        x_lineEndIndex    := x_lineEndIndex + 1;
        x_lineStartIndex  := NVL(x_lineStartIndex,x_lineEndIndex);
        --
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_IB_TXN_MATCH_PKG.ADDNEWMATCHEDLINE',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        WSH_IB_TXN_MATCH_PKG.addNewMatchedLine
          (
            p_line_rec            => p_line_rec,
            p_sourceindex         => p_line_rec_index,
            p_lineDate            => p_transactionDate,
            p_shipFromLocationId  => NVL(p_txnUniqueSFLocnId,x_matchedLineRecTbl.ship_from_location_id_tab(l_lineEndIndex)),
            p_primaryUomCode      => x_matchedLineRecTbl.requested_qty_uom_tab(l_lineEndIndex),
            p_secondaryUomCode    => x_matchedLineRecTbl.requested_qty_uom2_tab(l_lineIndex),
            p_destinationindex    => x_lineEndIndex,
            x_matchedLineRecTbl   => x_matchedLineRecTbl,
            x_return_status       => l_return_status
          );
        --
        --
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.api_post_call
          (
            p_return_status => l_return_status,
            x_num_warnings  => l_num_warnings,
            x_num_errors    => l_num_errors
          );
    --}
    END IF;
    --
    --
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
      wsh_util_core.default_handler('WSH_IB_TXN_MATCH_PKG.splitLines');
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
--}
END splitLines;

PROCEDURE applyDelta
            (
              p_transactionType         IN              VARCHAR2,
              p_ReceiptAgainstASN       IN              VARCHAR2,
              p_quantity                IN              NUMBER,
              p_quantity2               IN              NUMBER,
              p_index                   IN              NUMBER,
              x_matchedLineRecTbl       IN OUT NOCOPY   WSH_IB_UI_RECON_GRP.asn_rcv_del_det_rec_type,
              x_return_status           OUT    NOCOPY   VARCHAR2
            )
IS
--{
    l_num_warnings              NUMBER  := 0;
    l_num_errors                NUMBER  := 0;
    l_return_status             VARCHAR2(30);
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'applyDelta';
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
        --
        WSH_DEBUG_SV.log(l_module_name,'P_TRANSACTIONTYPE',P_TRANSACTIONTYPE);
        WSH_DEBUG_SV.log(l_module_name,'P_RECEIPTAGAINSTASN',P_RECEIPTAGAINSTASN);
        WSH_DEBUG_SV.log(l_module_name,'P_QUANTITY',P_QUANTITY);
        WSH_DEBUG_SV.log(l_module_name,'P_QUANTITY2',P_QUANTITY2);
        WSH_DEBUG_SV.log(l_module_name,'P_INDEX',P_INDEX);
        --
        WSH_DEBUG_SV.log(l_module_name,'Qty:REQ|PICK|SHP|RCV|RTV',
                                        x_matchedLineRecTbl.requested_qty_tab(p_index)
                                        || '|'
                                        || x_matchedLineRecTbl.picked_qty_tab(p_index)
                                        || '|'
                                        || x_matchedLineRecTbl.shipped_qty_tab(p_index)
                                        || '|'
                                        || x_matchedLineRecTbl.received_qty_tab(p_index)
                                        || '|'
                                        || x_matchedLineRecTbl.returned_qty_tab(p_index)
                        );
        WSH_DEBUG_SV.log(l_module_name,'Qty2:REQ|PICK|SHP|RCV|RTV',
                                        x_matchedLineRecTbl.requested_qty2_tab(p_index)
                                        || '|'
                                        || x_matchedLineRecTbl.picked_qty2_tab(p_index)
                                        || '|'
                                        || x_matchedLineRecTbl.shipped_qty2_tab(p_index)
                                        || '|'
                                        || x_matchedLineRecTbl.received_qty2_tab(p_index)
                                        || '|'
                                        || x_matchedLineRecTbl.returned_qty2_tab(p_index)
                        );
        WSH_DEBUG_SV.log(l_module_name,'Match Flag',x_matchedLineRecTbl.match_flag_tab(p_index) );
        WSH_DEBUG_SV.log(l_module_name,'Process ASN/RCV Flag',x_matchedLineRecTbl.process_asn_rcv_flag_tab(p_index) );
        WSH_DEBUG_SV.log(l_module_name,'Process Corr/RTV Flag',x_matchedLineRecTbl.process_corr_rtv_flag_tab(p_index) );
    END IF;
    --
    IF p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_ASN
    THEN
        x_matchedLineRecTbl.shipped_qty_tab(p_index)
        :=
        NVL(x_matchedLineRecTbl.shipped_qty_tab(p_index),0) + NVL(p_quantity,0);
        --
        x_matchedLineRecTbl.shipped_qty2_tab(p_index)
        :=
        NVL(x_matchedLineRecTbl.shipped_qty2_tab(p_index),0) + NVL(p_quantity2,0);
        --
        x_matchedLineRecTbl.process_asn_rcv_flag_tab(p_index)  := C_PROCESS_FLAG;
        x_matchedLineRecTbl.match_flag_tab(p_index)            := C_PROCESS_FLAG;
    ELSIF p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT
    THEN
        x_matchedLineRecTbl.received_qty_tab(p_index)
        :=
        NVL(x_matchedLineRecTbl.received_qty_tab(p_index),0) + NVL(p_quantity,0);
        --
        x_matchedLineRecTbl.received_qty2_tab(p_index)
        :=
        NVL(x_matchedLineRecTbl.received_qty2_tab(p_index),0) + NVL(p_quantity2,0);
        --
        x_matchedLineRecTbl.process_asn_rcv_flag_tab(p_index)  := C_PROCESS_FLAG;
        --
        IF p_ReceiptAgainstASN <> 'Y'
        THEN
            x_matchedLineRecTbl.match_flag_tab(p_index)            := C_PROCESS_FLAG;
        END IF;
    ELSIF p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_ADD
    THEN
        x_matchedLineRecTbl.received_qty_tab(p_index)
        :=
        NVL(x_matchedLineRecTbl.received_qty_tab(p_index),0) + NVL(p_quantity,0);
        --
        x_matchedLineRecTbl.received_qty2_tab(p_index)
        :=
        NVL(x_matchedLineRecTbl.received_qty2_tab(p_index),0) + NVL(p_quantity2,0);
        --
        x_matchedLineRecTbl.process_asn_rcv_flag_tab(p_index)  := C_PROCESS_FLAG;
        x_matchedLineRecTbl.match_flag_tab(p_index)            := C_PROCESS_FLAG;
    ELSIF p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_CORRECTION_POSITIVE
    THEN
        x_matchedLineRecTbl.received_qty_tab(p_index)
        := NVL(x_matchedLineRecTbl.received_qty_tab(p_index),0) + NVL(p_quantity,0);
        --
        x_matchedLineRecTbl.received_qty2_tab(p_index)
        := NVL(x_matchedLineRecTbl.received_qty2_tab(p_index),0) + NVL(p_quantity2,0);
        --
        x_matchedLineRecTbl.process_corr_rtv_flag_tab(p_index) := C_PROCESS_FLAG;
    ELSIF p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_CORRECTION_NEGATIVE
    THEN
        x_matchedLineRecTbl.received_qty_tab(p_index)
        := GREATEST(
                  NVL(x_matchedLineRecTbl.received_qty_tab(p_index),0) - NVL(p_quantity,0)
                  ,0
                  );
        --
        x_matchedLineRecTbl.received_qty2_tab(p_index)
        := GREATEST(
                  NVL(x_matchedLineRecTbl.received_qty2_tab(p_index),0) - NVL(p_quantity2,0)
                  ,0
                  );
        --
        x_matchedLineRecTbl.process_corr_rtv_flag_tab(p_index) := C_PROCESS_FLAG;
    ELSIF p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RTV
    OR    p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RTV_CORRECTION_POSITIVE
    THEN
        x_matchedLineRecTbl.returned_qty_tab(p_index)
        := NVL(x_matchedLineRecTbl.returned_qty_tab(p_index),0) + NVL(p_quantity,0);
        --
        x_matchedLineRecTbl.returned_qty2_tab(p_index)
        := NVL(x_matchedLineRecTbl.returned_qty2_tab(p_index),0) + NVL(p_quantity2,0);
        --
        x_matchedLineRecTbl.process_corr_rtv_flag_tab(p_index) := C_PROCESS_FLAG;
    ELSIF p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RTV_CORRECTION_NEGATIVE
    THEN
        x_matchedLineRecTbl.returned_qty_tab(p_index)
        := GREATEST(
                  NVL(x_matchedLineRecTbl.returned_qty_tab(p_index),0) - NVL(p_quantity,0)
                  ,0
                  );
        --
        x_matchedLineRecTbl.returned_qty2_tab(p_index)
        := GREATEST(
                  NVL(x_matchedLineRecTbl.returned_qty2_tab(p_index),0) - NVL(p_quantity2,0)
                  ,0
                  );
        --
        x_matchedLineRecTbl.process_corr_rtv_flag_tab(p_index) := C_PROCESS_FLAG;
    END IF;
    --
    --
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Result of Apply Qty');
        WSH_DEBUG_SV.log(l_module_name,'Qty:REQ|PICK|SHP|RCV|RTV',
                                        x_matchedLineRecTbl.requested_qty_tab(p_index)
                                        || '|'
                                        || x_matchedLineRecTbl.picked_qty_tab(p_index)
                                        || '|'
                                        || x_matchedLineRecTbl.shipped_qty_tab(p_index)
                                        || '|'
                                        || x_matchedLineRecTbl.received_qty_tab(p_index)
                                        || '|'
                                        || x_matchedLineRecTbl.returned_qty_tab(p_index)
                        );
        WSH_DEBUG_SV.log(l_module_name,'Qty2:REQ|PICK|SHP|RCV|RTV',
                                        x_matchedLineRecTbl.requested_qty2_tab(p_index)
                                        || '|'
                                        || x_matchedLineRecTbl.picked_qty2_tab(p_index)
                                        || '|'
                                        || x_matchedLineRecTbl.shipped_qty2_tab(p_index)
                                        || '|'
                                        || x_matchedLineRecTbl.received_qty2_tab(p_index)
                                        || '|'
                                        || x_matchedLineRecTbl.returned_qty2_tab(p_index)
                        );
        WSH_DEBUG_SV.log(l_module_name,'Process ASN/RCV Flag',x_matchedLineRecTbl.process_asn_rcv_flag_tab(p_index) );
        WSH_DEBUG_SV.log(l_module_name,'Process Corr/RTV Flag',x_matchedLineRecTbl.process_corr_rtv_flag_tab(p_index) );
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
      wsh_util_core.default_handler('WSH_IB_TXN_MATCH_PKG.applyDelta');
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
--}
END applyDelta;

PROCEDURE applyQuantity
            (
              p_transactionType         IN              VARCHAR2,
              p_ReceiptAgainstASN       IN              VARCHAR2,
              p_quantity                IN              NUMBER,
              p_quantity2               IN              NUMBER,
              p_index                   IN              NUMBER,
              x_matchedLineRecTbl       IN OUT NOCOPY   WSH_IB_UI_RECON_GRP.asn_rcv_del_det_rec_type,
              x_return_status           OUT    NOCOPY   VARCHAR2
            )
IS
--{
    l_num_warnings              NUMBER  := 0;
    l_num_errors                NUMBER  := 0;
    l_return_status             VARCHAR2(30);
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'APPLYQUANTITY';
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
        --
        WSH_DEBUG_SV.log(l_module_name,'P_TRANSACTIONTYPE',P_TRANSACTIONTYPE);
        WSH_DEBUG_SV.log(l_module_name,'P_RECEIPTAGAINSTASN',P_RECEIPTAGAINSTASN);
        WSH_DEBUG_SV.log(l_module_name,'P_QUANTITY',P_QUANTITY);
        WSH_DEBUG_SV.log(l_module_name,'P_QUANTITY2',P_QUANTITY2);
        WSH_DEBUG_SV.log(l_module_name,'P_INDEX',P_INDEX);
        --
        WSH_DEBUG_SV.log(l_module_name,'Qty:REQ|PICK|SHP|RCV|RTV',
                                        x_matchedLineRecTbl.requested_qty_tab(p_index)
                                        || '|'
                                        || x_matchedLineRecTbl.picked_qty_tab(p_index)
                                        || '|'
                                        || x_matchedLineRecTbl.shipped_qty_tab(p_index)
                                        || '|'
                                        || x_matchedLineRecTbl.received_qty_tab(p_index)
                                        || '|'
                                        || x_matchedLineRecTbl.returned_qty_tab(p_index)
                        );
        WSH_DEBUG_SV.log(l_module_name,'Qty2:REQ|PICK|SHP|RCV|RTV',
                                        x_matchedLineRecTbl.requested_qty2_tab(p_index)
                                        || '|'
                                        || x_matchedLineRecTbl.picked_qty2_tab(p_index)
                                        || '|'
                                        || x_matchedLineRecTbl.shipped_qty2_tab(p_index)
                                        || '|'
                                        || x_matchedLineRecTbl.received_qty2_tab(p_index)
                                        || '|'
                                        || x_matchedLineRecTbl.returned_qty2_tab(p_index)
                        );
        WSH_DEBUG_SV.log(l_module_name,'Match Flag',x_matchedLineRecTbl.match_flag_tab(p_index) );
        WSH_DEBUG_SV.log(l_module_name,'Process ASN/RCV Flag',x_matchedLineRecTbl.process_asn_rcv_flag_tab(p_index) );
        WSH_DEBUG_SV.log(l_module_name,'Process Corr/RTV Flag',x_matchedLineRecTbl.process_corr_rtv_flag_tab(p_index) );
    END IF;
    --
    IF p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_ASN
    THEN
        x_matchedLineRecTbl.shipped_qty_tab(p_index) := p_quantity;
        x_matchedLineRecTbl.shipped_qty2_tab(p_index) := p_quantity2;
        x_matchedLineRecTbl.process_asn_rcv_flag_tab(p_index)  := C_PROCESS_FLAG;
        x_matchedLineRecTbl.match_flag_tab(p_index)            := C_PROCESS_FLAG;
    ELSIF p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT
    THEN
        x_matchedLineRecTbl.received_qty_tab(p_index) := p_quantity;
        x_matchedLineRecTbl.received_qty2_tab(p_index) := p_quantity2;
        x_matchedLineRecTbl.process_asn_rcv_flag_tab(p_index)  := C_PROCESS_FLAG;
        --
        IF p_ReceiptAgainstASN <> 'Y'
        THEN
            x_matchedLineRecTbl.match_flag_tab(p_index)            := C_PROCESS_FLAG;
        END IF;
    ELSIF p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_ADD
    THEN
        x_matchedLineRecTbl.received_qty_tab(p_index) := p_quantity;
        x_matchedLineRecTbl.received_qty2_tab(p_index) := p_quantity2;
        x_matchedLineRecTbl.process_asn_rcv_flag_tab(p_index)  := C_PROCESS_FLAG;
        x_matchedLineRecTbl.match_flag_tab(p_index)            := C_PROCESS_FLAG;
    ELSIF p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_CORRECTION_POSITIVE
    THEN
        x_matchedLineRecTbl.received_qty_tab(p_index)
        := NVL(x_matchedLineRecTbl.received_qty_tab(p_index),0) + NVL(p_quantity,0);
        --
        x_matchedLineRecTbl.received_qty2_tab(p_index)
        := NVL(x_matchedLineRecTbl.received_qty2_tab(p_index),0) + NVL(p_quantity2,0);
        --
        x_matchedLineRecTbl.process_corr_rtv_flag_tab(p_index) := C_PROCESS_FLAG;
    ELSIF p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_CORRECTION_NEGATIVE
    THEN
        x_matchedLineRecTbl.received_qty_tab(p_index)
        := GREATEST(
                  NVL(x_matchedLineRecTbl.received_qty_tab(p_index),0) - NVL(p_quantity,0)
                  ,0
                  );
        --
        x_matchedLineRecTbl.received_qty2_tab(p_index)
        := GREATEST(
                  NVL(x_matchedLineRecTbl.received_qty2_tab(p_index),0) - NVL(p_quantity2,0)
                  ,0
                  );
        --
        x_matchedLineRecTbl.process_corr_rtv_flag_tab(p_index) := C_PROCESS_FLAG;
    ELSIF p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RTV
    OR    p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RTV_CORRECTION_POSITIVE
    THEN
        x_matchedLineRecTbl.returned_qty_tab(p_index)
        := NVL(x_matchedLineRecTbl.returned_qty_tab(p_index),0) + NVL(p_quantity,0);
        --
        x_matchedLineRecTbl.returned_qty2_tab(p_index)
        := NVL(x_matchedLineRecTbl.returned_qty2_tab(p_index),0) + NVL(p_quantity2,0);
        --
        x_matchedLineRecTbl.process_corr_rtv_flag_tab(p_index) := C_PROCESS_FLAG;
    ELSIF p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RTV_CORRECTION_NEGATIVE
    THEN
        x_matchedLineRecTbl.returned_qty_tab(p_index)
        := GREATEST(
                  NVL(x_matchedLineRecTbl.returned_qty_tab(p_index),0) - NVL(p_quantity,0)
                  ,0
                  );
        --
        x_matchedLineRecTbl.returned_qty2_tab(p_index)
        := GREATEST(
                  NVL(x_matchedLineRecTbl.returned_qty2_tab(p_index),0) - NVL(p_quantity2,0)
                  ,0
                  );
        --
        x_matchedLineRecTbl.process_corr_rtv_flag_tab(p_index) := C_PROCESS_FLAG;
    END IF;
    --
    --
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Result of Apply Qty');
        WSH_DEBUG_SV.log(l_module_name,'Qty:REQ|PICK|SHP|RCV|RTV',
                                        x_matchedLineRecTbl.requested_qty_tab(p_index)
                                        || '|'
                                        || x_matchedLineRecTbl.picked_qty_tab(p_index)
                                        || '|'
                                        || x_matchedLineRecTbl.shipped_qty_tab(p_index)
                                        || '|'
                                        || x_matchedLineRecTbl.received_qty_tab(p_index)
                                        || '|'
                                        || x_matchedLineRecTbl.returned_qty_tab(p_index)
                        );
        WSH_DEBUG_SV.log(l_module_name,'Qty2:REQ|PICK|SHP|RCV|RTV',
                                        x_matchedLineRecTbl.requested_qty2_tab(p_index)
                                        || '|'
                                        || x_matchedLineRecTbl.picked_qty2_tab(p_index)
                                        || '|'
                                        || x_matchedLineRecTbl.shipped_qty2_tab(p_index)
                                        || '|'
                                        || x_matchedLineRecTbl.received_qty2_tab(p_index)
                                        || '|'
                                        || x_matchedLineRecTbl.returned_qty2_tab(p_index)
                        );
        WSH_DEBUG_SV.log(l_module_name,'Process ASN/RCV Flag',x_matchedLineRecTbl.process_asn_rcv_flag_tab(p_index) );
        WSH_DEBUG_SV.log(l_module_name,'Process Corr/RTV Flag',x_matchedLineRecTbl.process_corr_rtv_flag_tab(p_index) );
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
      wsh_util_core.default_handler('WSH_IB_TXN_MATCH_PKG.applyQuantity');
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
--}
END applyQuantity;
--
--
--========================================================================
-- PROCEDURE : matchQuantity
--
-- PARAMETERS: p_transactionType Transaction Type
--             p_line_rec        ASN/Receipt Lines
--             x_return_status   Return status of the API
--
--
-- COMMENT   :  This prcedure  loops through all input ASN/Receipt lines
--              For each line,
--              - Check linkTable(x_linktbl) to get the status
--              - If marked as error, skip the input line
--              - If marked as processed, split the delivery lines
--              - If marked as not processed, navigate to matching delivery line
--                record in x_matchedLineRecTbl, using start and end indices obtained
--                from linkTable.
--              - Apply input line quantity to delivery line
--                  In general, quantity to be applied to delivery line is calculated as:
--                      - LEAST(input line qty, NVL(RCV,SHP,PICK,REQ)-RTV )
--                  except for Positive Receipt correction and Negative RTV correction
--                  - For positive receipt correction,entire input quantity is applied
--                    to first matched line.
--                  - For Negative RTV correction,calculation is:
--                      - LEAST(input line qty, RTV )
--              - While applying, input line against delivery lines, we process in the
--                increasing orders of line date (in x_matchedLineRecTbl).
--                - We first apply quantity onto lines with p_min_date, then
--                  with next higher date and so on until lines with p_max_date.
--========================================================================
--
--
PROCEDURE matchQuantity
            (
              p_line_rec                IN          OE_WSH_BULK_GRP.Line_Rec_Type,
              p_transactionType         IN          VARCHAR2,
              p_transactionMeaning      IN          VARCHAR2,
              p_ReceiptAgainstASN       IN          VARCHAR2,
              p_transactionDate         IN          DATE,
              p_txnUniqueSFLocnId       IN          NUMBER,
              p_start_index             IN          NUMBER,
              p_end_index               IN          NUMBER,
              p_min_date                IN          DATE,
              p_max_date                IN          DATE,
              x_matchedLineRecTbl    IN OUT NOCOPY  WSH_IB_UI_RECON_GRP.asn_rcv_del_det_rec_type,
              x_linktbl              IN OUT NOCOPY  WSH_UTIL_CORE.char500_tab_type,
              x_linkExttbl           IN OUT NOCOPY  WSH_UTIL_CORE.char500_tab_type,
              x_return_status           OUT NOCOPY  VARCHAR2
            )
IS
--{
    l_num_warnings              NUMBER  := 0;
    l_num_errors                NUMBER  := 0;
    l_return_status             VARCHAR2(30);
    --
    l_lastRCVShipmentLineId     NUMBER          := NULL;
    l_lastDeliveryId            NUMBER          := NULL;
    l_lastDeliveryRecString     VARCHAR2(500)   := NULL;
    l_min_date                  DATE            := NULL;
    l_max_date                  DATE            := NULL;
    l_matchedCount              NUMBER          := 0;
    l_transactionSubType        VARCHAR2(50);
    --
    l_start_index               NUMBER;
    l_end_index                 NUMBER;
    l_index                     NUMBER;
    l_RCVLineIndex              NUMBER;
    l_position1                 NUMBER;
    l_position2                 NUMBER;
    l_lineIndex                 NUMBER;
    l_lineStartIndex            NUMBER;
    l_lineEndIndex              NUMBER;
    l_lastMatchedLineIndex      NUMBER;
    --
    l_currentRCVShipmentLineId  NUMBER;
    l_deliveryId                NUMBER;
    l_DeliveryRecString         VARCHAR2(500);
    l_transactionDate           DATE;
    l_lineDate                  DATE;
    l_Date                      DATE;
    l_nextDate                  DATE;
    l_shipFromLocationId        NUMBER;
    l_carrierId                 NUMBER;
    l_transactionCarrierId      NUMBER;
    l_key                       NUMBER;
    l_linkRecString             VARCHAR2(500)   := NULL;
    --
    --
    l_totalTxnLineQty           NUMBER;
    l_totalTxnLineQty2          NUMBER;
    l_remainingQty              NUMBER;
    l_remainingQty2             NUMBER;
    l_lineQty                   NUMBER;
    l_lineQty2                  NUMBER;
    l_leftOverQuantity2         NUMBER;
    --
    --
    l_poHeaderNumber            VARCHAR2(150);
    l_poLineNumber              VARCHAR2(150);
    l_poShipmentLineNumber      NUMBER;
    l_poReleaseNumber           NUMBER;
    l_shipmentNumber            VARCHAR2(150);
    l_receiptNumber             VARCHAR2(150);
    --
    e_continue                  EXCEPTION;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'MATCHQUANTITY';
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
        --
        WSH_DEBUG_SV.log(l_module_name,'P_TRANSACTIONTYPE',P_TRANSACTIONTYPE);
        WSH_DEBUG_SV.log(l_module_name,'P_TRANSACTIONMEANING',P_TRANSACTIONMEANING);
        WSH_DEBUG_SV.log(l_module_name,'P_RECEIPTAGAINSTASN',P_RECEIPTAGAINSTASN);
        WSH_DEBUG_SV.log(l_module_name,'P_TRANSACTIONDATE',P_TRANSACTIONDATE);
        WSH_DEBUG_SV.log(l_module_name,'P_TXNUNIQUESFLOCNID',P_TXNUNIQUESFLOCNID);
        WSH_DEBUG_SV.log(l_module_name,'P_START_INDEX',P_START_INDEX);
        WSH_DEBUG_SV.log(l_module_name,'P_END_INDEX',P_END_INDEX);
        WSH_DEBUG_SV.log(l_module_name,'P_MIN_DATE',P_MIN_DATE);
        WSH_DEBUG_SV.log(l_module_name,'P_MAX_DATE',P_MAX_DATE);
    END IF;
    --
    l_index := p_line_rec.shipment_line_id.FIRST;
    --
    WHILE l_index IS NOT NULL
    LOOP
    --{
        --l_poShipmentLineId      := p_line_rec.po_shipment_line_id(l_index);
        --
        l_poHeaderNumber            := p_line_rec.source_header_number(l_index);
        l_poLineNumber              := p_line_rec.source_line_number(l_index);
        l_poShipmentLineNumber      := p_line_rec.po_shipment_line_number(l_index);
        l_poReleaseNumber           := p_line_rec.source_blanket_reference_num(l_index);
        l_shipmentNumber            := p_line_rec.shipment_num(l_index);
        l_receiptNumber             := p_line_rec.receipt_num(l_index);
        --
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_IB_TXN_MATCH_PKG.GETTRANSACTIONKEY',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        WSH_IB_TXN_MATCH_PKG.getTransactionKey
          (
            p_transactionType    => p_transactionType,
            p_ReceiptAgainstASN  => p_ReceiptAgainstASN,
            p_index              => l_index,
            p_line_rec           => p_line_rec,
            x_key                => l_key,
            x_transactionSubType => l_transactionSubType,
            x_return_status      => l_return_status
          );
        --
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
            WSH_DEBUG_SV.log(l_module_name,'l_key',l_key);
            WSH_DEBUG_SV.log(l_module_name,'l_transactionSubType',l_transactionSubType);
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.api_post_call
          (
            p_return_status => l_return_status,
            x_num_warnings  => l_num_warnings,
            x_num_errors    => l_num_errors
          );
        --
        --
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_CACHED_VALUE-x_linkTbl',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.get_cached_value
          (
            p_cache_tbl         => x_linkTbl,
            p_cache_ext_tbl     => x_linkExtTbl,
            p_key               => l_key,     --??--l_poShipmentLineId,
            p_value             => l_linkRecString,
            p_action            => 'GET',
            x_return_status     => l_return_status
          );
        --
        --
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
            WSH_DEBUG_SV.log(l_module_name,'l_linkRecString',l_linkRecString);
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.api_post_call
          (
            p_return_status => l_return_status,
            x_num_warnings  => l_num_warnings,
            x_num_errors    => l_num_errors
          );
        --
        --
        IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING
        THEN
            FND_MESSAGE.SET_NAME('WSH','WSH_IB_PO_WDD_LINK_ERROR');
            FND_MESSAGE.SET_TOKEN('KEY',l_key);
            wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
            RAISE FND_API.G_EXC_ERROR;
            --Should we raise some error insteaD?
            -- This may fail parent txn.....check again
        END IF;
        --
        l_position1         := INSTRB(l_linkRecString, C_SEPARATOR, 1,1) + 1;
        l_position2         := INSTRB(l_linkRecString, C_SEPARATOR, 1,2) + 1;
        l_lineStartIndex    := SUBSTRB(l_linkRecString, l_position1, l_position2 - l_position1 - 1);
        l_lineEndIndex      := SUBSTRB(l_linkRecString, l_position2);
        --
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_position1',l_position1);
            WSH_DEBUG_SV.log(l_module_name,'l_position2',l_position2);
            WSH_DEBUG_SV.log(l_module_name,'l_lineStartIndex',l_lineStartIndex);
            WSH_DEBUG_SV.log(l_module_name,'l_lineEndIndex',l_lineEndIndex);
        END IF;
        --
        --
        IF SUBSTRB(l_linkRecString,1,1) = C_PROCESS_FLAG
        THEN
        --{
            --??how abt r-asn
            --
            IF l_transactionSubType = WSH_INBOUND_TXN_HISTORY_PKG.C_ASN
            OR l_transactionSubType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_ADD
            OR (
                    l_transactionSubType    = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT
                AND p_ReceiptAgainstASN    <> 'Y'
               )
            THEN
            --{
                --
                -- Debug Statements
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_IB_TXN_MATCH_PKG.SPLITLINES',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                WSH_IB_TXN_MATCH_PKG.splitLines
                  (
                    p_txnUniqueSFLocnId   => p_txnUniqueSFLocnId,
                    p_transactionType     => p_transactionType,
                    p_transactionDate     => p_transactionDate,
                    p_line_rec            => p_line_rec,
                    p_line_rec_index      => l_index,
                    x_matchedLineRecTbl   => x_matchedLineRecTbl,
                    x_lineStartIndex      => l_lineStartIndex,
                    x_lineEndIndex        => l_lineEndIndex,
                    x_return_status       => l_return_status
                  );
                --
                --
                --
                -- Debug Statements
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                wsh_util_core.api_post_call
                  (
                    p_return_status => l_return_status,
                    x_num_warnings  => l_num_warnings,
                    x_num_errors    => l_num_errors
                  );
            --}
            END IF;
        --}
        END IF;
        --
        l_lineIndex         := l_lineStartIndex;
        --
        IF SUBSTRB(l_linkRecString,1,1) <> C_ERROR_FLAG
        THEN
        --{
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Item Id',p_line_rec.inventory_item_id(l_index));
            WSH_DEBUG_SV.log(l_module_name,'organization Id',p_line_rec.organization_id(l_index));
            WSH_DEBUG_SV.log(l_module_name,'Primary UOM',x_matchedLineRecTbl.requested_qty_uom_tab(l_lineIndex));
            WSH_DEBUG_SV.log(l_module_name,'Qty to Convert',p_line_rec.received_quantity(l_index));
            WSH_DEBUG_SV.log(l_module_name,'Qty UOM',p_line_rec.received_quantity_uom(l_index));
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_UTIL_PKG.CONVERT_QUANTITY',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        WSH_INBOUND_UTIL_PKG.convert_quantity
          (
            p_inv_item_id       => p_line_rec.inventory_item_id(l_index),
            p_organization_id   => p_line_rec.organization_id(l_index),
            p_primary_uom_code  => x_matchedLineRecTbl.requested_qty_uom_tab(l_lineIndex),
            p_quantity          => p_line_rec.received_quantity(l_index),
            p_qty_uom_code      => p_line_rec.received_quantity_uom(l_index),
            x_conv_qty          => l_totalTxnLineQty,
            x_return_status     => l_return_status
          );
        --
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
            WSH_DEBUG_SV.log(l_module_name,'Converted Qty',l_totalTxnLineQty);
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.api_post_call
          (
            p_return_status => l_return_status,
            x_num_warnings  => l_num_warnings,
            x_num_errors    => l_num_errors
          );
        --
        --
        l_totalTxnLineQty2  := NVL(p_line_rec.received_quantity2(l_index),0);
        --
        l_remainingQty      := ABS(l_totalTxnLineQty);
        l_remainingQty2     := ABS(l_totalTxnLineQty2);
        --
        l_date              := p_min_date;
        --l_lineIndex         := l_lineStartIndex;
        --
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_totalTxnLineQty2',p_line_rec.received_quantity2(l_index));
            WSH_DEBUG_SV.log(l_module_name,'l_remainingQty',l_remainingQty);
            WSH_DEBUG_SV.log(l_module_name,'l_remainingQty2',l_remainingQty2);
        END IF;
        --
        WHILE l_remainingQty  > 0
        AND   l_Date         <= p_max_date
        LOOP
        --{
            l_nextDate          := p_max_date;
            l_lineIndex         := l_lineStartIndex;
            --
            WHILE l_lineIndex IS NOT NULL
            AND   l_lineIndex <= l_lineEndIndex
            AND   ( l_remainingQty  > 0 OR l_leftOverQuantity2 > 0 )
            LOOP
            --{
                BEGIN
                --{
                    l_lineDate := x_matchedLineRecTbl.line_date_tab(l_lineIndex);
                    --
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name,'Line Date',x_matchedLineRecTbl.line_date_tab(l_lineIndex));
                        WSH_DEBUG_SV.log(l_module_name,'WDD ID',x_matchedLineRecTbl.del_detail_id_tab(l_lineIndex));
                        WSH_DEBUG_SV.log(l_module_name,'WND ID',x_matchedLineRecTbl.delivery_id_tab(l_lineIndex));
                        WSH_DEBUG_SV.log(l_module_name,'SF Locn ID',x_matchedLineRecTbl.ship_from_location_id_tab(l_lineIndex));
                        WSH_DEBUG_SV.log(l_module_name,'Match Flag',x_matchedLineRecTbl.match_flag_tab(l_lineIndex));
                        WSH_DEBUG_SV.log(l_module_name,'Qty:REQ|PICK|SHP|RCV|RTV',
                                                        x_matchedLineRecTbl.requested_qty_tab(l_lineIndex)
                                                        || '|'
                                                        || x_matchedLineRecTbl.picked_qty_tab(l_lineIndex)
                                                        || '|'
                                                        || x_matchedLineRecTbl.shipped_qty_tab(l_lineIndex)
                                                        || '|'
                                                        || x_matchedLineRecTbl.received_qty_tab(l_lineIndex)
                                                        || '|'
                                                        || x_matchedLineRecTbl.returned_qty_tab(l_lineIndex)
                                        );
                        WSH_DEBUG_SV.log(l_module_name,'Qty2:REQ|PICK|SHP|RCV|RTV',
                                                        x_matchedLineRecTbl.requested_qty2_tab(l_lineIndex)
                                                        || '|'
                                                        || x_matchedLineRecTbl.picked_qty2_tab(l_lineIndex)
                                                        || '|'
                                                        || x_matchedLineRecTbl.shipped_qty2_tab(l_lineIndex)
                                                        || '|'
                                                        || x_matchedLineRecTbl.received_qty2_tab(l_lineIndex)
                                                        || '|'
                                                        || x_matchedLineRecTbl.returned_qty2_tab(l_lineIndex)
                                        );
                    END IF;
                    --
                    IF  x_matchedLineRecTbl.match_flag_tab(l_lineIndex) = C_POTENTIAL_MATCH_FLAG
                    THEN
                    --{
                        IF l_transactionSubType = WSH_INBOUND_TXN_HISTORY_PKG.C_ASN
                        OR l_transactionSubType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_ADD
                        OR (
                                  l_transactionSubType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT
                             AND  p_receiptAgainstASN  <> 'Y'
                           )
                        THEN
                            IF l_debug_on THEN
                                 WSH_DEBUG_SV.logmsg(l_module_name,'Txn is ASN/Receipt-add/Direct Receipt');
                                                      END IF;
                                                      --
                            IF x_matchedLineRecTbl.ship_from_location_id_tab(l_lineIndex) <> p_txnUniqueSFLocnId
                            THEN
                            --{
                                IF l_debug_on THEN
                                     WSH_DEBUG_SV.logmsg(l_module_name,'Line SF <> Txn SF');
                                                          END IF;
                                IF x_matchedLineRecTbl.ship_from_location_id_tab(l_lineIndex) = WSH_UTIL_CORE.C_NULL_SF_LOCN_ID
                                THEN
                                    IF l_debug_on THEN
                                         WSH_DEBUG_SV.logmsg(l_module_name,'Line SF is -1');
                                                              END IF;
                                    x_matchedLineRecTbl.ship_from_location_id_tab(l_lineIndex) := p_txnUniqueSFLocnId;
                                ELSE
                                    RAISE e_continue;
                                END IF;
                            --}
                            END IF;
                        END IF;
                        --
                        IF l_transactionSubType = WSH_INBOUND_TXN_HISTORY_PKG.C_ASN
                        OR l_transactionSubType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_ADD
                        OR (
                                  l_transactionSubType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT
                             AND  p_receiptAgainstASN  <> 'Y'
                           )
                        THEN
                            IF l_lineDate <> l_date
                            THEN
                                RAISE e_continue;
                            END IF;
                        END IF;
                        --
                        --
                        IF l_leftOverQuantity2 > 0
                        THEN
                        --{
                            IF l_transactionSubType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_CORRECTION_NEGATIVE
                            THEN
                                x_matchedLineRecTbl.received_qty2_tab(l_lineIndex)
                                := NVL(x_matchedLineRecTbl.received_qty2_tab(l_lineIndex),0)
                                   + l_leftOverQuantity2;
                            ELSIF l_transactionSubType = WSH_INBOUND_TXN_HISTORY_PKG.C_RTV_CORRECTION_NEGATIVE
                            THEN
                                x_matchedLineRecTbl.returned_qty2_tab(l_lineIndex)
                                := NVL(x_matchedLineRecTbl.returned_qty2_tab(l_lineIndex),0)
                                   + l_leftOverQuantity2;
                            END IF;
                            --
                            x_matchedLineRecTbl.process_corr_rtv_flag_tab(l_lineIndex) := C_PROCESS_FLAG;
                            l_leftOverQuantity2 := 0;
                        --}
                        END IF;
                        --
                        l_lineQty   := NULL;
                        l_lineQty2  := NULL;
                        --
                        --
                        IF l_transactionSubType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_CORRECTION_POSITIVE
                        THEN
                        --{
                            l_lineQty := l_remainingQty;
                        --}
                        ELSIF l_transactionSubType = WSH_INBOUND_TXN_HISTORY_PKG.C_RTV_CORRECTION_NEGATIVE
                        THEN
                        --{
                            l_lineQty := LEAST(
                                                l_remainingQty,
                                                NVL(x_matchedLineRecTbl.returned_qty_tab(l_lineIndex),0)
                                              );
                        --}
                        ELSE
                        --{
                            l_lineQty := LEAST(
                                                l_remainingQty,
                                                NVL
                                                  (
                                                    x_matchedLineRecTbl.received_qty_tab(l_lineIndex),
                                                    NVL
                                                      (
                                                        x_matchedLineRecTbl.shipped_qty_tab(l_lineIndex),
                                                        NVL
                                                          (
                                                            x_matchedLineRecTbl.picked_qty_tab(l_lineIndex),
                                                            x_matchedLineRecTbl.requested_qty_tab(l_lineIndex)
                                                          )
                                                      )
                                                  )
                                                - NVL(x_matchedLineRecTbl.returned_qty_tab(l_lineIndex),0)
                                              );

                            --
                            -- For newly added line
                            --
                            IF l_transactionSubType     = WSH_INBOUND_TXN_HISTORY_PKG.C_ASN
                            OR l_transactionSubType     = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_ADD
                            OR (
                                      l_transactionSubType     = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT
                                 AND  p_receiptAgainstASN  <> 'Y'
                               )
                            THEN
                            --{
                                IF NVL(x_matchedLineRecTbl.requested_qty_tab(l_lineIndex),0) = 0
                                THEN

                                    l_lineQty := l_remainingQty;
                                END IF;
                            --}
                            END IF;
                        --}
                        END IF;
                        --
                        l_remainingQty  := l_remainingQty - l_lineQty;
                        --
                        --
                        IF l_remainingQty2 > 0
                        THEN
                        --{

                            IF l_transactionSubType     = WSH_INBOUND_TXN_HISTORY_PKG.C_ASN
                            OR l_transactionSubType     = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_ADD
                            OR (
                                      l_transactionSubType     = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT
                                 AND  p_receiptAgainstASN  <> 'Y'
                               )
                            THEN
                            --{
-- HW OPMCONV - Use C_MAX_DECIMAL_DIGITS_INV instead of C_MAX_DECIMAL_DIGITS_OPM
                                l_lineQty2 := ROUND
                                                    (
                                                      (
                                                        (l_lineQty * l_totalTxnLineQty2) / l_totalTxnLineQty
                                                      ),
                                                      WSH_UTIL_CORE.C_MAX_DECIMAL_DIGITS_INV
                                                    );
                            --}
                            ELSIF l_transactionSubType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_CORRECTION_POSITIVE
                            THEN
                            --{
                                l_lineQty2 := l_remainingQty2;
                            --}
                            ELSIF l_transactionSubType = WSH_INBOUND_TXN_HISTORY_PKG.C_RTV_CORRECTION_NEGATIVE
                            THEN
                            --{
                                l_lineQty2 := LEAST(
                                                    l_remainingQty2,
                                                    NVL(x_matchedLineRecTbl.returned_qty2_tab(l_lineIndex),0)
                                                  );
                            --}
                            ELSE
                            --{
                                l_lineQty2 := LEAST(
                                                    l_remainingQty2,

                                                    NVL
                                                      (
                                                        x_matchedLineRecTbl.received_qty2_tab(l_lineIndex),
                                                        NVL
                                                          (
                                                            x_matchedLineRecTbl.shipped_qty2_tab(l_lineIndex),
                                                            NVL
                                                              (
                                                                x_matchedLineRecTbl.picked_qty2_tab(l_lineIndex),
                                                                x_matchedLineRecTbl.requested_qty2_tab(l_lineIndex)
                                                              )
                                                          )
                                                      )
                                                    - NVL(x_matchedLineRecTbl.returned_qty2_tab(l_lineIndex),0)
                                                  );
                            --}
                            END IF;
                            --
                            l_remainingQty2 := l_remainingQty2 - l_lineQty2;
                        --}
                        END IF;
                        --
                        --
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.log(l_module_name,'l_lineQty',l_lineQty);
                            WSH_DEBUG_SV.log(l_module_name,'l_lineQty2',l_lineQty2);
                        END IF;
                        --
                        --
                        IF NVL(l_lineQty,0)  > 0 --  IS NOT NULL
                        OR NVL(l_lineQty2,0) > 0 -- IS NOT NULL
                        THEN
                        --{
                            --
                            -- Debug Statements
                            --
                            IF l_debug_on THEN
                                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_IB_TXN_MATCH_PKG.APPLYQUANTITY',WSH_DEBUG_SV.C_PROC_LEVEL);
                            END IF;
                            --
                            WSH_IB_TXN_MATCH_PKG.applyQuantity
                              (
                                p_transactionType    => l_transactionSubType,
                                p_ReceiptAgainstASN  => p_ReceiptAgainstASN,
                                p_quantity           => l_lineQty,
                                p_quantity2          => l_lineQty2,
                                p_index              => l_lineIndex,
                                x_matchedLineRecTbl  => x_matchedLineRecTbl,
                                x_return_status      => l_return_status
                              );
                            --
                            --
                            --
                            -- Debug Statements
                            --
                            IF l_debug_on THEN
                                WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
                            END IF;
                            --
                            wsh_util_core.api_post_call
                              (
                                p_return_status => l_return_status,
                                x_num_warnings  => l_num_warnings,
                                x_num_errors    => l_num_errors
                              );
                            --
                            --
                            IF x_matchedLineRecTbl.received_qty_tab(l_lineIndex) < 0
                            OR x_matchedLineRecTbl.shipped_qty_tab(l_lineIndex)  < 0
                            OR x_matchedLineRecTbl.received_qty_tab(l_lineIndex)
                               - x_matchedLineRecTbl.returned_qty_tab(l_lineIndex) < 0
                            OR x_matchedLineRecTbl.received_qty2_tab(l_lineIndex) < 0
                            OR x_matchedLineRecTbl.shipped_qty2_tab(l_lineIndex)  < 0
                            OR x_matchedLineRecTbl.received_qty2_tab(l_lineIndex)
                               - x_matchedLineRecTbl.returned_qty2_tab(l_lineIndex) < 0
                            THEN
                            --{
                                FND_MESSAGE.SET_NAME('WSH','WSH_IB_MATCH_LINE_FATAL_ERROR');
                                FND_MESSAGE.SET_TOKEN('TRANSACTION_TYPE',p_transactionMeaning); --p_action_prms.action_code);
                                FND_MESSAGE.SET_TOKEN('SHIPMENT_NUM',l_shipmentNumber);
                                FND_MESSAGE.SET_TOKEN('RECEIPT_NUM',l_receiptNumber);
                                FND_MESSAGE.SET_TOKEN('PO_HEADER_NUM',l_poHeaderNumber);
                                FND_MESSAGE.SET_TOKEN('PO_LINE_NUM',l_poLineNumber);
                                FND_MESSAGE.SET_TOKEN('PO_SHIPMENT_LINE_NUM',l_poShipmentLineNumber);
                                FND_MESSAGE.SET_TOKEN('PO_RELEASE_NUM',l_poReleaseNumber);
                                wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
                                --
                                RAISE FND_API.G_EXC_ERROR;
                            --}
                            END IF;
                            --
                            --
                            l_lastMatchedLineIndex := l_lineIndex;
                            --
                            --
                            IF l_transactionSubType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_CORRECTION_NEGATIVE
                            THEN
                            --{
                                l_leftOverQuantity2 := x_matchedLineRecTbl.received_qty2_tab(l_lineIndex)
                                                       - NVL(x_matchedLineRecTbl.returned_qty2_tab(l_lineIndex),0);
                                --
                                --
                                IF l_leftOverQuantity2 > 0
                                THEN
                                --{
                                    IF x_matchedLineRecTbl.received_qty_tab(l_lineIndex)
                                       - NVL(x_matchedLineRecTbl.returned_qty_tab(l_lineIndex),0)
                                       <> 0
                                    THEN
                                        l_leftOverQuantity2 := 0;
                                    ELSE
                                        x_matchedLineRecTbl.received_qty2_tab(l_lineIndex)
                                        := NVL(x_matchedLineRecTbl.returned_qty2_tab(l_lineIndex),0);
                                        --
                                        x_matchedLineRecTbl.process_corr_rtv_flag_tab(l_lineIndex) := C_PROCESS_FLAG;
                                    END IF;
                                --}
                                END IF;
                            --}
                            END IF;
                            --
                            --
                            IF l_transactionSubType = WSH_INBOUND_TXN_HISTORY_PKG.C_RTV_CORRECTION_NEGATIVE
                            THEN
                            --{
                                l_leftOverQuantity2 := NVL(x_matchedLineRecTbl.returned_qty2_tab(l_lineIndex),0);
                                --
                                --
                                IF l_leftOverQuantity2 > 0
                                THEN
                                --{
                                    IF NVL(x_matchedLineRecTbl.returned_qty_tab(l_lineIndex),0) <> 0
                                    THEN
                                        l_leftOverQuantity2 := 0;
                                    ELSE
                                        x_matchedLineRecTbl.returned_qty2_tab(l_lineIndex) := 0;
                                        --
                                        x_matchedLineRecTbl.process_corr_rtv_flag_tab(l_lineIndex) := C_PROCESS_FLAG;
                                    END IF;
                                --}
                                END IF;
                            --}
                            END IF;
                        --}
                        END IF;
                    --}
                    END IF;
                --}
                EXCEPTION
                --{
                    WHEN e_continue THEN
                        IF l_debug_on THEN
                           WSH_DEBUG_SV.logmsg(l_module_name,'WHEN e_continue ');
                                              END IF;
                --}
                END;
                --
                --
                IF l_lineDate > l_date
                THEN
                --{
                    l_nextDate := LEAST( l_lineDate, l_nextDate );
                --}
                END IF;
                --
                l_lineIndex := x_matchedLineRecTbl.match_flag_tab.NEXT(l_lineIndex);
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'End of inner loop');
                    WSH_DEBUG_SV.log(l_module_name,'l_lineIndex',l_lineIndex);
                    WSH_DEBUG_SV.log(l_module_name,'l_nextDate',l_nextDate);
                    WSH_DEBUG_SV.log(l_module_name,'l_remainingQty',l_remainingQty);
                    WSH_DEBUG_SV.log(l_module_name,'l_remainingQty2',l_remainingQty2);
                    WSH_DEBUG_SV.log(l_module_name,'l_leftOverQuantity2',l_leftOverQuantity2);
                END IF;
                --
            --}
            END LOOP;
            --
            EXIT WHEN l_date = p_max_date;
            --
            l_date := l_nextDate;
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'End of outer loop');
                WSH_DEBUG_SV.log(l_module_name,'l_date',l_date);
                WSH_DEBUG_SV.log(l_module_name,'l_remainingQty',l_remainingQty);
                --
                --
                IF   l_Date < p_max_date
                THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'l_date < p_max_date');
                ELSIF   l_Date = p_max_date
                THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'l_date = p_max_date');
                ELSIF   l_Date > p_max_date
                THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'l_date > p_max_date');
                ELSE
                    WSH_DEBUG_SV.logmsg(l_module_name,'l_date ??? p_max_date');
                END IF;
            END IF;
            --
        --}
        END LOOP;
        --
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Outside Outer loop');
            WSH_DEBUG_SV.log(l_module_name,'l_remainingQty',l_remainingQty);
            WSH_DEBUG_SV.log(l_module_name,'l_remainingQty2',l_remainingQty2);
            WSH_DEBUG_SV.log(l_module_name,'l_lastMatchedLineIndex',l_lastMatchedLineIndex);
        END IF;
        --
        --
        IF l_remainingQty > 0
        OR l_remainingQty2 > 0
        THEN
        --{
            IF l_lastMatchedLineIndex IS NOT NULL
            THEN
            --{
                --
                -- Debug Statements
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_IB_TXN_MATCH_PKG.APPLYQUANTITY',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                WSH_IB_TXN_MATCH_PKG.applyDelta
                  (
                    p_transactionType    => l_transactionSubType,
                    p_ReceiptAgainstASN  => p_ReceiptAgainstASN,
                    p_quantity           => l_remainingQty,
                    p_quantity2          => l_remainingQty2,
                    --p_quantity           => LEAST(l_remainingQty,0),
                    --p_quantity2          => LEAST(l_remainingQty2,0),
                    p_index              => l_lastMatchedLineIndex,
                    x_matchedLineRecTbl  => x_matchedLineRecTbl,
                    x_return_status      => l_return_status
                  );
                --
                --
                --
                -- Debug Statements
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                wsh_util_core.api_post_call
                  (
                    p_return_status => l_return_status,
                    x_num_warnings  => l_num_warnings,
                    x_num_errors    => l_num_errors
                  );
                --
                --
                IF x_matchedLineRecTbl.received_qty_tab(l_lastMatchedLineIndex) < 0
                OR x_matchedLineRecTbl.shipped_qty_tab(l_lastMatchedLineIndex)  < 0
                OR x_matchedLineRecTbl.received_qty_tab(l_lastMatchedLineIndex)
                   - x_matchedLineRecTbl.returned_qty_tab(l_lastMatchedLineIndex) < 0
                OR x_matchedLineRecTbl.received_qty2_tab(l_lastMatchedLineIndex) < 0
                OR x_matchedLineRecTbl.shipped_qty2_tab(l_lastMatchedLineIndex)  < 0
                OR x_matchedLineRecTbl.received_qty2_tab(l_lastMatchedLineIndex)
                   - x_matchedLineRecTbl.returned_qty2_tab(l_lastMatchedLineIndex) < 0
                THEN
                --{
                    FND_MESSAGE.SET_NAME('WSH','WSH_IB_MATCH_LINE_FATAL_ERROR');
                    FND_MESSAGE.SET_TOKEN('TRANSACTION_TYPE',p_transactionMeaning); --p_action_prms.action_code);
                    FND_MESSAGE.SET_TOKEN('SHIPMENT_NUM',l_shipmentNumber);
                    FND_MESSAGE.SET_TOKEN('RECEIPT_NUM',l_receiptNumber);
                    FND_MESSAGE.SET_TOKEN('PO_HEADER_NUM',l_poHeaderNumber);
                    FND_MESSAGE.SET_TOKEN('PO_LINE_NUM',l_poLineNumber);
                    FND_MESSAGE.SET_TOKEN('PO_SHIPMENT_LINE_NUM',l_poShipmentLineNumber);
                    FND_MESSAGE.SET_TOKEN('PO_RELEASE_NUM',l_poReleaseNumber);
                    wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
                    --
                    RAISE FND_API.G_EXC_ERROR;
                --}
                END IF;
            --}
            ELSE
                FND_MESSAGE.SET_NAME('WSH','WSH_IB_TXN_NO_MATCH_ERROR');
                FND_MESSAGE.SET_TOKEN('KEY',l_key);
                wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
                RAISE FND_API.G_EXC_ERROR;
            END IF;
        --}
        END IF;
        --
        --
        l_linkRecString :=  C_PROCESS_FLAG
                            || C_SEPARATOR
                            || l_lineStartIndex
                            || C_SEPARATOR
                            || l_lineEndIndex; --l_lineStartIndex;
        --
        --
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_CACHED_VALUE-x_linkTbl',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.get_cached_value
          (
            p_cache_tbl         => x_linkTbl,
            p_cache_ext_tbl     => x_linkExtTbl,
            p_key               => l_key, --??--l_poShipmentLineId,
            p_value             => l_linkRecString,
            p_action            => 'PUT',
            x_return_status     => l_return_status
          );
        --
        --
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.api_post_call
          (
            p_return_status => l_return_status,
            x_num_warnings  => l_num_warnings,
            x_num_errors    => l_num_errors
          );
        --}
        END IF;
        --
        --
        --
        l_index := p_line_rec.shipment_line_id.NEXT(l_index);
    --}
    END LOOP;
    --
    --
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
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
--}
EXCEPTION
--{
    --WHEN e_notMatched THEN
      --RAISE e_notMatched;
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
      wsh_util_core.default_handler('WSH_IB_TXN_MATCH_PKG.matchQuantity');
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
--}
END matchQuantity;


PROCEDURE matchLines
            (
              p_line_rec                IN          OE_WSH_BULK_GRP.Line_Rec_Type,
              p_transactionType         IN          VARCHAR2,
              p_transactionMeaning      IN          VARCHAR2,
              p_ReceiptAgainstASN       IN          VARCHAR2,
              p_transactionDate         IN          DATE,
              p_start_index             IN          NUMBER,
              p_end_index               IN          NUMBER,
              p_putMessages             IN          BOOLEAN,
              p_txnUniqueSFLocnId       IN          NUMBER,
              x_matchedLineRecTbl    IN OUT NOCOPY  WSH_IB_UI_RECON_GRP.asn_rcv_del_det_rec_type,
              x_dlvytbl              IN OUT NOCOPY  WSH_UTIL_CORE.char500_tab_type,
              x_dlvyExttbl           IN OUT NOCOPY  WSH_UTIL_CORE.char500_tab_type,
              x_min_date             IN OUT NOCOPY  DATE,
              x_max_date             IN OUT NOCOPY  DATE,
              x_return_status           OUT NOCOPY  VARCHAR2
            )
IS
--{
    CURSOR dlvy_leg_csr
            (
                p_deliveryId               IN  NUMBER,
                p_transactionType          IN  VARCHAR2
            )
    IS
        SELECT  'DROPOFF' leg_type,
                NVL(wts1.actual_departure_date,wts1.planned_departure_date) planned_departure_date,
                NVL(wts.actual_arrival_date,   wts.planned_arrival_date) planned_arrival_date,
                wt.carrier_id,
                NVL(wnd.ITINERARY_COMPLETE,'N') ITINERARY_COMPLETE
        FROM    wsh_delivery_legs           wdl,
                wsh_new_deliveries          wnd,
                wsh_trip_stops              wts,
                wsh_trip_stops              wts1,
                wsh_trips                   wt
        WHERE   wnd.delivery_id                     = p_deliveryId
        AND     wdl.delivery_id                     = wnd.delivery_id
        AND     wdl.drop_off_stop_id                = wts.stop_id
        AND     wts.stop_location_id                = wnd.ultimate_dropoff_location_id
        AND     wts.trip_id                         = wt.trip_id
        AND     wdl.pick_up_stop_id                 = wts1.stop_id
        UNION ALL
        SELECT  'PICKUP' leg_type,
                NVL(wts.actual_departure_date,wts.planned_departure_date) planned_departure_date,
                NVL(wts1.actual_arrival_Date, wts1.planned_arrival_date) planned_arrival_date,
                wt.carrier_id,
                NVL(wnd.ITINERARY_COMPLETE,'N') ITINERARY_COMPLETE
        FROM    wsh_delivery_legs           wdl,
                wsh_new_deliveries          wnd,
                wsh_trip_stops              wts,
                wsh_trip_stops              wts1,
                wsh_trips                   wt
        WHERE   wnd.delivery_id                     = p_deliveryId
        AND     wdl.delivery_id                     = wnd.delivery_id
        AND     wdl.pick_up_stop_id                 = wts.stop_id
        AND     wts.stop_location_id                = wnd.initial_pickup_location_id
        AND     wts.trip_id                         = wt.trip_id
        AND     wdl.drop_off_stop_id                = wts1.stop_id
        AND     p_transactionType                   = WSH_INBOUND_TXN_HISTORY_PKG.C_ASN
        ORDER BY 1 ASC;   --- order by leg_type--dropoff first then pickup
    --
    l_dlvy_leg_rec               dlvy_leg_csr%ROWTYPE;
    --
    --
    CURSOR dlvy_csr
            (
                p_deliveryId               IN  NUMBER
            )
    IS
        SELECT
                NVL(wnd.initial_pickup_date,wnd.earliest_pickup_date) initial_pickup_date,
                NVL(wnd.ultimate_dropoff_date,wnd.latest_Dropoff_date) ultimate_dropoff_date,
                wnd.carrier_id,
                NVL(wnd.ITINERARY_COMPLETE,'N') ITINERARY_COMPLETE,
                wdl.delivery_leg_id
        FROM    wsh_new_deliveries          wnd,
                wsh_delivery_legs           wdl
        WHERE   wnd.delivery_id                     = p_deliveryId
        AND     wnd.delivery_id                     = wdl.delivery_id (+);
    --
    l_dlvy_rec                  dlvy_csr%ROWTYPE;
    --
    --
    CURSOR carrier_csr
            (
                p_carrierId               IN  NUMBER
            )
    IS
        SELECT
                party_name
        FROM    hz_parties
        WHERE   party_id = p_carrierId;
    --
    --
    l_num_warnings              NUMBER  := 0;
    l_num_errors                NUMBER  := 0;
    l_return_status             VARCHAR2(30);
    --
    l_lastRCVShipmentLineId     NUMBER          := NULL;
    l_lastDeliveryId            NUMBER          := NULL;
    l_lastDeliveryRecString     VARCHAR2(500)   := NULL;
    l_min_date                  DATE            := NULL;
    l_max_date                  DATE            := NULL;
    l_matchedCount              NUMBER          := 0;
    --
    l_start_index               NUMBER;
    l_end_index                 NUMBER;
    l_index                     NUMBER;
    l_RCVLineIndex              NUMBER;
    --
    l_currentRCVShipmentLineId  NUMBER;
    l_deliveryId                NUMBER;
    l_DeliveryRecString         VARCHAR2(500);
    l_transactionDate           DATE;
    l_lineDate                  DATE;
    l_shipFromLocationId        NUMBER;
    l_carrierId                 NUMBER;
    l_transactionCarrierId      NUMBER;
    l_carrierName               VARCHAR2(500);
    l_deliveryItineraryComplete VARCHAR2(5);
    l_deliveryLegsExist         BOOLEAN;
    --
    --
    l_firstShipFromLocationId   NUMBER;
    l_shipmentNumber            VARCHAR2(50);
    l_receiptNumber             VARCHAR2(50);
    l_validFlag                 VARCHAR2(10);
    l_found                     BOOLEAN;
    --
    l_poHeaderNumber            VARCHAR2(150);
    l_poLineNumber              VARCHAR2(150);
    l_poShipmentLineNumber      NUMBER;
    l_poReleaseNumber           NUMBER;

    e_notMatchedCarrierDates    EXCEPTION;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'MATCHLINES';
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
        --
        WSH_DEBUG_SV.log(l_module_name,'P_TRANSACTIONTYPE',P_TRANSACTIONTYPE);
        WSH_DEBUG_SV.log(l_module_name,'P_TRANSACTIONMEANING',P_TRANSACTIONMEANING);
        WSH_DEBUG_SV.log(l_module_name,'P_RECEIPTAGAINSTASN',P_RECEIPTAGAINSTASN);
        WSH_DEBUG_SV.log(l_module_name,'P_TRANSACTIONDATE',P_TRANSACTIONDATE);
        WSH_DEBUG_SV.log(l_module_name,'P_START_INDEX',P_START_INDEX);
        WSH_DEBUG_SV.log(l_module_name,'P_END_INDEX',P_END_INDEX);
        WSH_DEBUG_SV.log(l_module_name,'P_PUTMESSAGES',P_PUTMESSAGES);
        WSH_DEBUG_SV.log(l_module_name,'P_TXNUNIQUESFLOCNID',P_TXNUNIQUESFLOCNID);
        WSH_DEBUG_SV.log(l_module_name,'X_MIN_DATE',X_MIN_DATE);
        WSH_DEBUG_SV.log(l_module_name,'X_MAX_DATE',X_MAX_DATE);
    END IF;
    --
    l_index                     := p_start_index;
    l_start_index               := p_start_index;
    l_firstShipFromLocationId   := x_matchedLineRecTbl.ship_from_location_id_tab(l_index);
    --
    --
    WHILE l_index IS NOT NULL
    AND   l_index <= p_end_index
    LOOP
    --{

        l_currentRCVShipmentLineId  := x_matchedLineRecTbl.shipment_line_id_tab(l_index);
        l_deliveryId                := x_matchedLineRecTbl.delivery_id_tab(l_index);
        l_deliveryRecString         := NULL;
        l_shipFromLocationId        := x_matchedLineRecTbl.ship_from_location_id_tab(l_index);
        --l_firstShipFromLocationId   := l_shipFromLocationId;
        --
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Matched Line Rec index',l_index);
            WSH_DEBUG_SV.log(l_module_name,'l_deliveryId',l_deliveryId);
            WSH_DEBUG_SV.log(l_module_name,'l_shipFromLocationId',l_shipFromLocationId);
            WSH_DEBUG_SV.log(l_module_name,'l_currentRCVShipmentLineId',l_currentRCVShipmentLineId);
            WSH_DEBUG_SV.log(l_module_name,'l_RCVLineIndex',x_matchedLineRecTbl.shpmt_line_id_idx_tab(l_index));
        END IF;
        --
        --
        l_RCVLineIndex              := x_matchedLineRecTbl.shpmt_line_id_idx_tab(l_index);
        l_transactionCarrierId      := p_line_rec.rcv_carrier_id(l_RCVLineIndex);
        l_shipmentNumber            := p_line_rec.shipment_num(l_RCVLineIndex);
        l_receiptNumber             := p_line_rec.receipt_num(l_RCVLineIndex);
        --
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_transactionCarrierId',l_transactionCarrierId);
            WSH_DEBUG_SV.log(l_module_name,'l_lastRCVShipmentLineId',l_lastRCVShipmentLineId);
        END IF;
        --
        --
        IF l_currentRCVShipmentLineId    <>  l_lastRCVShipmentLineId
        THEN
        --{
            IF l_matchedCount = 0
            THEN
            --{
                RAISE e_notMatchedCarrierDates;
            --}
            --ELSE
            --{
                --match_qtys
            --}
            END IF;
            --
            l_start_index             := l_index;
            l_firstShipFromLocationId := l_shipFromLocationId;
            --l_min_date              := NULL;
            --l_max_date              := NULL;
            l_matchedCount            := 0;
        --}
        END IF;
        --
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_start_index',l_start_index);
            WSH_DEBUG_SV.log(l_module_name,'l_firstShipFromLocationId',l_firstShipFromLocationId);
            WSH_DEBUG_SV.log(l_module_name,'l_lastDeliveryId',l_lastDeliveryId);
        END IF;
        --
        --
        IF  (
                 p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_ASN
              OR (
                      p_transactionType    = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT
                  AND p_ReceiptAgainstASN <> 'Y'
                 )
            )
        AND p_txnUniqueSFLocnId   = WSH_UTIL_CORE.C_NULL_SF_LOCN_ID
        AND l_shipFromLocationId <> WSH_UTIL_CORE.C_NULL_SF_LOCN_ID
        THEN
        --{
            IF p_putMessages
            THEN
                FND_MESSAGE.SET_NAME('WSH','WSH_IB_NOT_UNIQUE_SF_LOCN');
                FND_MESSAGE.SET_TOKEN('TRANSACTION_TYPE',p_transactionMeaning); --p_action_prms.action_code);
                FND_MESSAGE.SET_TOKEN('SHIPMENT_NUM',l_shipmentNumber);
                FND_MESSAGE.SET_TOKEN('RECEIPT_NUM',l_receiptNumber);
                wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
            END IF;
            --
            RAISE e_notMatched;
        --}
        END IF;
        --
        --
        IF l_shipFromLocationId         = p_txnUniqueSFLocnId
        OR (      l_shipFromLocationId  = WSH_UTIL_CORE.C_NULL_SF_LOCN_ID
             AND  l_shipFromLocationId  = l_firstShipFromLocationId
           )
        --OR ( l_shipFromLocationId = WSH_UTIL_CORE.C_NULL_SF_LOCN_ID AND l_index = l_start_index )
        /*
        OR (
                  p_transactionType     = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT
             AND  p_receiptAgainstASN   = 'Y'
           )
        */
        THEN
        --{
            IF l_deliveryId IS NULL
            THEN
            --{
                l_linedate := x_matchedLineRecTbl.line_date_tab(l_index);
                --l_latest_date   := x_matchedLineRecTbl.latest_date_tab(l_index);
                l_validFlag := 'Y';
            --}
            ELSE
            --{
                IF l_lastDeliveryId = l_deliveryId
                THEN
                    l_deliveryRecString := l_lastDeliveryRecString;
                ELSE
                --{
                    --
                    -- Debug Statements
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_CACHED_VALUE-x_dlvyTbl',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    wsh_util_core.get_cached_value
                        (
                            p_cache_tbl         => x_dlvyTbl,
                            p_cache_ext_tbl     => x_dlvyExtTbl,
                            p_key               => l_deliveryId,
                            p_value             => l_deliveryRecString,
                            p_action            => 'GET',
                            x_return_status     => l_return_status
                        );
                    --
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                    END IF;
                    --
                    --
                    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR
                    THEN
                        RAISE FND_API.G_EXC_ERROR;
                    ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
                    THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING
                    THEN
                        l_deliveryRecString := NULL;
                    END IF;
                --}
                END IF;
                --
                IF l_deliveryRecString IS NULL
                THEN
                --{
                    OPEN dlvy_leg_csr
                            (
                                p_deliveryId        => l_deliveryId,
                                p_transactionType   => p_transactionType
                            );
                    --
                    FETCH dlvy_leg_csr INTO l_dlvy_leg_rec;
                    --
                    IF dlvy_leg_csr%NOTFOUND
                    THEN
                    --{
                        OPEN dlvy_csr(p_deliveryId  => l_deliveryId);
                        --
                        FETCH dlvy_csr INTO l_dlvy_rec;
                        --
                        l_found := dlvy_csr%FOUND;
                        --
                        CLOSE dlvy_csr;
                        --
                        IF NOT(l_found)
                        THEN
                        --{
                            FND_MESSAGE.SET_NAME('WSH','WSH_DLVY_NOT_EXIST');
                            FND_MESSAGE.SET_TOKEN('DELIVERY_ID',l_deliveryId);
                            wsh_util_core.add_message(wsh_util_core.g_ret_sts_error,l_module_name);
                            RAISE FND_API.G_EXC_ERROR;
                        --}
                        END IF;
                        --
                        --
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.log(l_module_name,'l_dlvy_rec.initial_pickup_date',l_dlvy_rec.initial_pickup_date);
                            WSH_DEBUG_SV.log(l_module_name,'l_dlvy_rec.ultimate_dropoff_date',l_dlvy_rec.ultimate_dropoff_date);
                            WSH_DEBUG_SV.log(l_module_name,'l_dlvy_rec.carrier_id',l_dlvy_rec.carrier_id);
                        END IF;
                        --
                        --
                        IF p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_ASN
                        THEN
                            l_linedate := l_dlvy_rec.initial_pickup_date;
                        ELSE
                            l_linedate := l_dlvy_rec.ultimate_dropoff_date;
                        END IF;
                        --
                        l_carrierId                 := l_dlvy_rec.carrier_id;
                        l_deliveryItineraryComplete := l_dlvy_rec.ITINERARY_COMPLETE;
                        --
                        IF l_dlvy_rec.delivery_leg_id IS NULL
                        THEN
                          l_deliveryLegsExist := FALSE;
                        ELSE
                          l_deliveryLegsExist := TRUE;
                        END IF;
                    --}
                    ELSE
                    --{
                        --
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.log(l_module_name,'l_dlvy_leg_rec.planned_departure_date',l_dlvy_leg_rec.planned_departure_date);
                            WSH_DEBUG_SV.log(l_module_name,'l_dlvy_leg_rec.planned_arrival_date',l_dlvy_leg_rec.planned_arrival_date);
                            WSH_DEBUG_SV.log(l_module_name,'l_dlvy_leg_rec.carrier_id',l_dlvy_leg_rec.carrier_id);
                        END IF;
                        --
                        IF p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_ASN
                        THEN
                            l_linedate := l_dlvy_leg_rec.planned_departure_date;
                        ELSE
                            l_linedate := l_dlvy_leg_rec.planned_arrival_date;
                        END IF;
                        --
                        l_carrierId                 := l_dlvy_leg_rec.carrier_id;
                        l_deliveryItineraryComplete := l_dlvy_leg_rec.ITINERARY_COMPLETE;
                        l_deliveryLegsExist         := TRUE;
                    --}
                    END IF;
                    --
                    CLOSE dlvy_leg_csr;
                    --
                    l_validFlag     := 'Y';
                    --
		    --IB-phase-2 : removed condition on Date
                    IF ( l_carrierId <> l_transactionCarrierId AND nvl(x_matchedLineRecTbl.lineCount_tab(l_index),2) > 1 )
                    OR (
                         l_deliveryLegsExist AND l_deliveryItineraryComplete = 'N'
                       )
                    THEN
                    --{
                        IF p_transactionType     = WSH_INBOUND_TXN_HISTORY_PKG.C_ASN
                        OR p_transactionType     = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_ADD
                        OR (
                                  p_transactionType     = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT
                             AND  p_receiptAgainstASN  <> 'Y'
                           )
                        THEN
                            l_validFlag    := 'N';
                        END IF;
                    --}
                    END IF;
                    --
                    --
                    l_lineDate := NVL(l_lineDate,SYSDATE+2000);
                    --
                    --
                    l_deliveryRecString := l_validFlag
                                           || C_SEPARATOR
                                           || TO_CHAR(l_lineDate, C_DATE_FORMAT_MASK);
                    --
                    --
                    -- Debug Statements
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_CACHED_VALUE-x_dlvyTbl',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    wsh_util_core.get_cached_value
                        (
                            p_cache_tbl         => x_dlvyTbl,
                            p_cache_ext_tbl     => x_dlvyExtTbl,
                            p_key               => l_deliveryId,
                            p_value             => l_deliveryRecString,
                            p_action            => 'PUT',
                            x_return_status     => l_return_status
                        );
                    --
                    --
                    --
                    -- Debug Statements
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    wsh_util_core.api_post_call
                      (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                      );
                --}
                ELSE
                --{
                    l_validFlag     := SUBSTRB(l_deliveryRecString, 1,1);
                    l_lineDate      := TO_DATE( SUBSTRB(l_deliveryRecString, 3), C_DATE_FORMAT_MASK) ;
                --}
                END IF;
            --}
            END IF;
            --
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_deliveryRecString',l_deliveryRecString);
                WSH_DEBUG_SV.log(l_module_name,'l_validFlag',l_validFlag);
                WSH_DEBUG_SV.log(l_module_name,'l_lineDate',l_lineDate);
            END IF;
            --
            IF l_validFlag = 'Y'
            THEN
            --{
                x_matchedLineRecTbl.line_date_tab(l_index)  := l_lineDate;
                x_matchedLineRecTbl.match_flag_Tab(l_index) := C_POTENTIAL_MATCH_FLAG;
                --
                l_matchedCount                              := l_matchedCount + 1;
                --
                /*
                IF l_shipFromLocationId = WSH_UTIL_CORE.C_NULL_SF_LOCN_ID
                THEN
                    x_matchedLineRecTbl.ship_from_location_id_tab(l_index) := p_txnUniqueSFLocnId;
                END IF;
                */
                --
                x_min_date := LEAST    ( NVL(x_min_date,l_lineDate), l_lineDate );
                x_max_date := GREATEST ( NVL(x_max_date,l_lineDate), l_lineDate );
            --}
            END IF;
            --
            --
            l_lastDeliveryId        := l_deliveryId;
            l_lastDeliveryRecString := l_deliveryRecString;
            --l_lastRCVShipmentLineId := l_currentRCVShipmentLineId;
            l_end_index             := l_index;
        --}
        END IF;
        --
        --
        l_lastRCVShipmentLineId := l_currentRCVShipmentLineId;
        l_poHeaderNumber            := p_line_rec.source_header_number(l_RCVLineIndex);
        l_poLineNumber              := p_line_rec.source_line_number(l_RCVLineIndex);
        l_poShipmentLineNumber      := p_line_rec.po_shipment_line_number(l_RCVLineIndex);
        l_poReleaseNumber           := p_line_rec.source_blanket_reference_num(l_RCVLineIndex);
        --
        l_index                     := x_matchedLineRecTbl.del_detail_id_tab.NEXT(l_index);
    --}
    END LOOP;
    --
    IF l_matchedCount = 0
    THEN
    --{
        RAISE e_notMatchedCarrierDates;
    --}
    END IF;
    --
    --
    --
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'x_min_date',x_min_date);
        WSH_DEBUG_SV.log(l_module_name,'x_max_date',x_max_date);
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
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
--}
EXCEPTION
--{
    WHEN e_notMatched THEN
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'x_min_date',x_min_date);
            WSH_DEBUG_SV.log(l_module_name,'x_max_date',x_max_date);
            WSH_DEBUG_SV.logmsg(l_module_name,'E_NOTMATCHED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:E_NOTMATCHED');
        END IF;
        --
        RAISE e_notMatched;
    WHEN e_notMatchedCarrierDates THEN
    --{
        IF p_putMessages
        THEN
        --{
            l_carrierName := NULL;
            --
            OPEN carrier_csr(l_transactionCarrierId);
            FETCH carrier_csr INTO l_carrierName;
            CLOSE carrier_csr;
            --
            FND_MESSAGE.SET_NAME('WSH','WSH_IB_NOT_MATCH_DATES');
            FND_MESSAGE.SET_TOKEN('TXN_DATE',p_transactionDate);
            FND_MESSAGE.SET_TOKEN('CARRIER_NAME',l_carrierName);
            FND_MESSAGE.SET_TOKEN('TRANSACTION_TYPE',p_transactionMeaning); --p_action_prms.action_code);
            FND_MESSAGE.SET_TOKEN('SHIPMENT_NUM',l_shipmentNumber);
            FND_MESSAGE.SET_TOKEN('RECEIPT_NUM',l_receiptNumber);
            FND_MESSAGE.SET_TOKEN('PO_HEADER_NUM',l_poHeaderNumber);
            FND_MESSAGE.SET_TOKEN('PO_LINE_NUM',l_poLineNumber);
            FND_MESSAGE.SET_TOKEN('PO_SHIPMENT_LINE_NUM',l_poShipmentLineNumber);
            FND_MESSAGE.SET_TOKEN('PO_RELEASE_NUM',l_poReleaseNumber);
            wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
        --}
        END IF;
        --
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'x_min_date',x_min_date);
            WSH_DEBUG_SV.log(l_module_name,'x_max_date',x_max_date);
            WSH_DEBUG_SV.logmsg(l_module_name,'E_NOTMATCHEDCARRIERDATES exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:E_NOTMATCHEDCARRIERDATES');
        END IF;
        --
        RAISE e_notMatched;
    --}
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
      wsh_util_core.default_handler('WSH_IB_TXN_MATCH_PKG.matchLines');
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
--}
END matchLines;

--
--========================================================================
-- PROCEDURE : matchTransaction
--
-- PARAMETERS: p_action_prms     Standard actions parameter.
--             p_line_rec        ASN/Receipt Lines
--             x_return_status   Return status of the API
--
--
-- COMMENT   :  This procedure is the pre-processor for the Inbound ASN/Receiving transactions
--              integration. (Receiving transaction processor calls this API via Group API).
--
--              This procedure handles following transactions (indicated by transaction type)
--                'ASN'
--                'CANCEL_ASN'
--                'RECEIPT'
--                'RECEIPT_CORRECTION'
--                'RTV'
--                'RTV_CORRECTION'
--                'RECEIPT_ADD'
--                'RECEIPT_HEADER_UPD'
--
--              Its main purpose is to apply matching algorithm(Please refer to HLD for
--              description) i.e find unique ship-from location for the transaction
--              interfaced. Once found, it tries to match lines with respect to dates/carrier
--              and then applies transaction quantities onto delivery lines quantities
--              (shipped/received/returned). If successful, it calls ASN/Receipt/Correction
--              integration(processing) code. If unsuccessful, it raises a business event
--              which can be subscribed to take some action e.g. notify concerned user.
--========================================================================
--


PROCEDURE matchTransaction
            (
              p_action_prms      IN             WSH_BULK_TYPES_GRP.action_parameters_rectype,
              p_line_rec         IN  OUT NOCOPY OE_WSH_BULK_GRP.Line_rec_type,
              x_return_status    OUT     NOCOPY VARCHAR2
            )
IS
--{
    --
    -- This cursor tries to find delivery lines corresponding to each record in
    -- p_line_rec. (Please refer to appendix 2 of DLD for transaction-wise
    -- query conditions and order by clause )
    --
    CURSOR line_csr
            (
                p_source_header_id              IN  NUMBER,
                p_source_line_id                IN  NUMBER,
                p_po_shipment_line_id           IN  NUMBER,
                p_source_blanket_Reference_id   IN  NUMBER,
                p_released_status               IN  VARCHAR2,
                p_shipment_header_id            IN  NUMBER,
                p_ship_from_location_id         IN  NUMBER,
                p_rcvShipmentLineID             IN  NUMBER,
                p_transactionSubType            IN  VARCHAR2,
                p_orderByFlag                   IN  VARCHAR2
            )
    IS
        SELECT  wdd.delivery_detail_id,
                wdd.requested_quantity,
                wdd.picked_quantity,
                wdd.shipped_quantity,
                wdd.received_quantity,
                wdd.returned_quantity,
                wdd.requested_quantity2,
                wdd.picked_quantity2,
                wdd.shipped_quantity2,
                wdd.received_quantity2,
                wdd.returned_quantity2,
                wdd.ship_from_location_id,
                wdd.earliest_dropoff_date,
                wnd.delivery_id,
                wdd.rcv_shipment_line_id,
                wdd.requested_quantity_uom,
                wdd.requested_quantity_uom2,
                wdd.released_status,
                wdd.src_requested_quantity,
                wdd.src_requested_quantity2,
                wdd.last_update_date
        FROM    wsh_delivery_details        wdd,
                wsh_delivery_assignments_v    wda,
                wsh_new_deliveries          wnd
        WHERE   wdd.source_code                     = 'PO'
        AND     NVL(wdd.line_direction,'O')    NOT IN ('O','IO')
        AND     wdd.source_header_id                = p_source_header_id
        AND     wdd.source_line_id                  = p_source_line_id
        AND     wdd.po_shipment_line_id             = p_po_shipment_line_id
        AND     wdd.released_status                 = p_released_status
        AND     wdd.delivery_detail_id              = wda.delivery_detail_id
        AND     wda.delivery_id                     = wnd.delivery_id (+)
        AND     (
                  (
                        p_source_blanket_Reference_id   IS NULL
                    AND wdd.source_blanket_Reference_id IS NULL
                  )
                  OR
                  wdd.source_blanket_Reference_id   = p_source_blanket_Reference_id
                )
        /* bug 3181963
        AND     (
                  (
                        p_shipment_header_id        IS NULL
                    AND wnd.asn_shipment_header_id  IS NULL
                  )
                  OR
                  wnd.asn_shipment_header_id        = p_shipment_header_id
                )
        */
        AND     (
                  (
                        p_rcvShipmentLineID        IS NULL
                    AND wdd.rcv_Shipment_Line_ID  IS NULL
                  )
                  OR
                  wdd.rcv_Shipment_Line_ID        = p_rcvShipmentLineID
                )
        AND     (
                  (
                        p_transactionSubType = WSH_INBOUND_TXN_HISTORY_PKG.C_RTV_CORRECTION_NEGATIVE
                    AND returned_quantity > 0
                  )
                  OR
                  p_transactionSubType <> WSH_INBOUND_TXN_HISTORY_PKG.C_RTV_CORRECTION_NEGATIVE
                )
        AND     (
                  (
                        p_transactionSubType IN (
                                                  WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_CORRECTION_NEGATIVE,
                                                  WSH_INBOUND_TXN_HISTORY_PKG.C_RTV,
                                                  WSH_INBOUND_TXN_HISTORY_PKG.C_RTV_CORRECTION_POSITIVE
                                                )
                    AND (received_quantity - NVL(returned_quantity,0)) > 0
                  )
                  OR
                  p_transactionSubType NOT IN (
                                                WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_CORRECTION_NEGATIVE,
                                                WSH_INBOUND_TXN_HISTORY_PKG.C_RTV,
                                                WSH_INBOUND_TXN_HISTORY_PKG.C_RTV_CORRECTION_POSITIVE
                                              )
                )
         -- { IB-Phase-2
	 AND   ( p_ship_from_location_id IS NULL
                 OR
                 (  wdd.ship_from_location_id = p_ship_from_location_id
                      OR
                    wdd.ship_from_location_id = WSH_UTIL_CORE.C_NULL_SF_LOCN_ID
                 )
               )
	 -- } IB-Phase-2
        ORDER BY DECODE
                    (
                      wdd.ship_from_location_id,
                      p_ship_from_location_id,            -999,
                      WSH_UTIL_CORE.C_NULL_SF_LOCN_ID,    1E38,
                      wdd.ship_from_location_id
                    ),
                 DECODE
                    (
                      p_orderByFlag,
                      -1,
                      wnd.delivery_id,
                      -- -2,
                      -- wnd.delivery_id,
                      p_orderByFlag
                    ),
                 DECODE
                    (
                      p_orderByFlag,
                      -1,
                      NVL(picked_quantity,requested_quantity),
                      -2,
                      -1 * shipped_quantity,
                      -3,
                      -1 * NVL(returned_quantity,0),
                      -5,
                      NVL(returned_quantity,-1E38), --added nvl clause as NULLS LAST was commented
                      p_orderByFlag
                    ) DESC, -- NULLS LAST, -- commented nulls last due to pl/sql bug in 8.1.7.4
                 DECODE
                    (
                      p_orderByFlag,
                      -3,
                      (received_quantity - NVL(returned_quantity,0)),
                      -4,
                      (received_quantity - NVL(returned_quantity,0)),
                      -5,
                      (received_quantity - NVL(returned_quantity,0)),
                      p_orderByFlag
                    ) DESC; -- NULLS LAST;  -- commented nulls last due to pl/sql bug in 8.1.7.4
                 --wdd.earliest_dropoff_date,
                 --wnd.delivery_id;
    --???r-corr apply to diff of rcv-rtv
    --similarly rtv apply to diff of rcv-rtv. i.e. rcv >= rtv always
    --
    --
    -- Check if at least one delivery line exists corresponding to
    -- input PO shipment line
    --
    CURSOR po_line_csr
            (
                p_source_header_id              IN  NUMBER,
                p_source_line_id                IN  NUMBER,
                p_po_shipment_line_id           IN  NUMBER,
                p_source_blanket_Reference_id   IN  NUMBER
            )
    IS
        SELECT  requested_quantity_uom, requested_quantity_uom2,
                src_requested_quantity,src_requested_quantity2
        FROM    wsh_delivery_details        wdd
        WHERE   wdd.source_code                     = 'PO'
        AND     NVL(wdd.line_direction,'O')    NOT IN ('O','IO')
        AND     wdd.source_header_id                = p_source_header_id
        AND     wdd.source_line_id                  = p_source_line_id
        AND     wdd.po_shipment_line_id             = p_po_shipment_line_id
        AND     (
                  (
                        p_source_blanket_Reference_id   IS NULL
                    AND wdd.source_blanket_Reference_id IS NULL
                  )
                  OR
                  wdd.source_blanket_Reference_id   = p_source_blanket_Reference_id
                )
       --AND     rownum = 1;
       ORDER BY DECODE(released_status,'D',10,'X',1,'L','2','C',3,4) ASC;
    --
    --
    -- Find initial pickup location of deliveries matched against the receipt
    --
    CURSOR receipt_locn_csr
            (
                p_shipment_header_id            IN  NUMBER
            )
    IS
        SELECT  DISTINCT initial_pickup_location_id
        FROM    wsh_new_deliveries
        WHERE   rcv_shipment_header_id      = p_shipment_header_id;
    --
    --
    -- Check receipt line's matching status
    --
    CURSOR txn_line_status_csr
            (
                p_shipment_header_id            IN  NUMBER,
                p_shipment_line_id              IN  NUMBER
            )
    IS
        SELECT  1
        FROM    wsh_inbound_txn_history
        WHERE   shipment_header_id      = p_shipment_header_id
        AND     shipment_line_id        = p_shipment_line_id
        AND     status                  = WSH_INBOUND_TXN_HISTORY_PKG.C_PENDING;
    --
    --
    -- This cursor is not used
    --
    CURSOR rcv_line_csr
            (
                p_source_header_id              IN  NUMBER,
                p_source_line_id                IN  NUMBER,
                p_po_shipment_line_id           IN  NUMBER,
                p_source_blanket_Reference_id   IN  NUMBER,
                p_shipment_line_id              IN  NUMBER,
                p_transactionSubType            IN  VARCHAR2
            )
    IS
        SELECT  COUNT(DISTINCT ship_from_location_id)
        FROM    wsh_delivery_details        wdd
        WHERE   wdd.source_code                     = 'PO'
        AND     NVL(wdd.line_direction,'O')    NOT IN ('O','IO')
        AND     wdd.source_header_id                = p_source_header_id
        AND     wdd.source_line_id                  = p_source_line_id
        AND     wdd.po_shipment_line_id             = p_po_shipment_line_id
        AND     (
                  (
                        p_source_blanket_Reference_id   IS NULL
                    AND wdd.source_blanket_Reference_id IS NULL
                  )
                  OR
                  wdd.source_blanket_Reference_id   = p_source_blanket_Reference_id
                )
        AND     rcv_shipment_line_id                = p_shipment_line_id
        AND     (
                  (
                        p_transactionSubType = WSH_INBOUND_TXN_HISTORY_PKG.C_RTV_CORRECTION_NEGATIVE
                    AND returned_quantity > 0
                  )
                  OR
                  p_transactionSubType <> WSH_INBOUND_TXN_HISTORY_PKG.C_RTV_CORRECTION_NEGATIVE
                )
        AND     (
                  (
                        p_transactionSubType IN (
                                                  WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_CORRECTION_NEGATIVE,
                                                  WSH_INBOUND_TXN_HISTORY_PKG.C_RTV,
                                                  WSH_INBOUND_TXN_HISTORY_PKG.C_RTV_CORRECTION_POSITIVE
                                                )
                    AND (received_quantity - NVL(returned_quantity,0)) > 0
                  )
                  OR
                  p_transactionSubType NOT IN (
                                                WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_CORRECTION_NEGATIVE,
                                                WSH_INBOUND_TXN_HISTORY_PKG.C_RTV,
                                                WSH_INBOUND_TXN_HISTORY_PKG.C_RTV_CORRECTION_POSITIVE
                                              )
                );

    --
    --
    -- This cursor is not used
    --
    CURSOR rcv_line_check_csr
            (
                p_shipment_line_id              IN  NUMBER
            )
    IS
        SELECT  quantity_received
        FROM    rcv_shipment_lines
        WHERE   shipment_line_id        = p_shipment_line_id;
    --
    --
    --
    -- This cursor checks if there are shipped delivery lines corresponding to
    -- each record in
    -- p_line_rec.
    --
    CURSOR shipped_line_csr
            (
                p_source_header_id              IN  NUMBER,
                p_source_line_id                IN  NUMBER,
                p_po_shipment_line_id           IN  NUMBER,
                p_source_blanket_Reference_id   IN  NUMBER
            )
    IS
        SELECT  1
        FROM    wsh_delivery_details        wdd
        WHERE   wdd.source_code                     = 'PO'
        AND     NVL(wdd.line_direction,'O')    NOT IN ('O','IO')
        AND     wdd.source_header_id                = p_source_header_id
        AND     wdd.source_line_id                  = p_source_line_id
        AND     wdd.po_shipment_line_id             = p_po_shipment_line_id
        AND     wdd.released_status                 = 'C'
        AND     (
                  (
                        p_source_blanket_Reference_id   IS NULL
                    AND wdd.source_blanket_Reference_id IS NULL
                  )
                  OR
                  wdd.source_blanket_Reference_id   = p_source_blanket_Reference_id
                );
    --
    -- { IB-Phase-2
    CURSOR get_wsh_location_csr (p_hz_location_id NUMBER)
    IS
    SELECT wsh_location_id
    FROM wsh_locations
    WHERE source_location_id = p_hz_location_id
      AND location_source_code = 'HZ' ;
    -- } IB-Phase-2
    --
    l_num_warnings              NUMBER;
    l_num_errors                NUMBER;
    l_return_status             VARCHAR2(30);
    l_msg_data                  VARCHAR2(4000);
    l_msg_count                 NUMBER;
    --
    --
    l_index                       NUMBER;
    l_firstIndex                  NUMBER;
    l_lineCount                   NUMBER;
    l_messageStartIndex           NUMBER;
    l_start_Index                 NUMBER  := 0;
    l_end_Index                   NUMBER  := 0;
    --l_lastPOShipmentLineId        NUMBER;
    l_actionCode                  VARCHAR2(200);
    --
    --
    l_shipmentNumber            VARCHAR2(50);
    l_receiptNumber             VARCHAR2(50);
    l_poHeaderNumber            VARCHAR2(150);
    l_poLineNumber              VARCHAR2(150);
    l_poShipmentLineNumber      NUMBER;
    l_poReleaseNumber           NUMBER;
    l_RCVShipmentHeaderId       NUMBER;
    --
    --
    l_headerTransactionId       NUMBER;
    l_headerObjectVersionNumber NUMBER;
    l_headerStatus              VARCHAR2(30);
    --
    --
    l_released_status           VARCHAR2(30);
    l_shipmentHeaderId          NUMBER;
    l_rcvShipmentLineId         NUMBER;
    l_transactionDate           DATE;
    l_shipFromLocationId        NUMBER;
    l_orderByFlag               NUMBER;
    l_resetTxnUniqueSFLocn      BOOLEAN;
    --
    --
    l_transactionId             NUMBER;
    l_maxTransactionId          NUMBER;
    l_minTransactionId          NUMBER;
    l_minFailedTransactionId    NUMBER;
    l_minMatchedTransactionId   NUMBER;
    l_maxRCVTransactionId       NUMBER;
    l_key                       NUMBER;
    l_count                     NUMBER;
    --
    --
    --
    l_parentTransactionMatched  BOOLEAN;
    l_transactionMeaning        VARCHAR2(100);
    --
    --
    l_txnUniqueSFLocnFound        BOOLEAN;
    l_txnUniqueSFLocnId           NUMBER;
    l_txnUniqueSFLocnCode         VARCHAR2(100);
    --
    --
    l_lineUniqueSFLocnFound       BOOLEAN;
    l_lineUniqueSFLocnId          NUMBER;
    l_linePreviousSFLocnId        NUMBER;
    l_lineSFLocnId                NUMBER;
    l_poShipmentLineId            NUMBER;
    --
    --
    l_lineRecTbl                  line_recTbl_type;
    l_matchedLineRecTbl           WSH_IB_UI_RECON_GRP.asn_rcv_del_det_rec_type;
    --
    l_linkTbl                     WSH_UTIL_CORE.char500_tab_type;
    l_linkExtTbl                  WSH_UTIL_CORE.char500_tab_type;
    l_linkRecString               VARCHAR2(500);
    --
    l_dlvyTbl                     WSH_UTIL_CORE.char500_tab_type;
    l_dlvyExtTbl                  WSH_UTIL_CORE.char500_tab_type;
    --
    --
    l_FailedTxnHistory_recTbl     WSH_INBOUND_TXN_HISTORY_PKG.inboundTxnHistory_recTbl_type;
    l_MatchedTxnHistory_recTbl    WSH_INBOUND_TXN_HISTORY_PKG.inboundTxnHistory_recTbl_type;
    --
    --
    l_uniqueShipFromLocationIdTbl WSH_UTIL_CORE.id_tab_type;
    --
    --
    l_min_date                    DATE;
    l_max_date                    DATE;
    l_dummy_min_date              DATE;
    l_dummy_max_date              DATE;
    --
    --
    l_shipFromLocationIdTbl       WSH_UTIL_CORE.key_value_tab_type;
    l_shipFromLocationIdExtTbl    WSH_UTIL_CORE.key_value_tab_type;
    l_shipFromLocationIdLineCount NUMBER;
    --
    --
    l_parentTxnHistoryRec         WSH_INBOUND_TXN_HISTORY_PKG.ib_txn_history_rec_type;
    l_ReceiptAgainstASN           VARCHAR2(10);
    l_transactionGroup            VARCHAR2(50);
    l_transactionType             VARCHAR2(50);
    l_transactionSubType          VARCHAR2(50);
    --
    l_totalReceivedQuantity        NUMBER;
    l_receiptShipFromLocationCount NUMBER;
    l_receiptShipFromLocationId    NUMBER;
    l_dummy                        NUMBER;
    l_extendBy                     NUMBER;
    l_primaryUOMCode               VARCHAR2(10);
    l_secondaryUOMCode             VARCHAR2(10);
    l_src_requested_quantity       NUMBER;
    l_src_requested_quantity2      NUMBER;
    l_messageName                  VARCHAR2(50);
    l_caller                       VARCHAR2(200);
    l_shipped_lines                NUMBER;
    --
    --
    l_action_prms1                 wsh_glbl_var_strct_grp.dd_action_parameters_rec_type;
    l_action_prms2                 WSH_BULK_TYPES_GRP.action_parameters_rectype;
    l_rtv_corr_out_rec             WSH_RCV_CORR_RTV_TXN_PKG.corr_rtv_out_rec_type;
    l_po_cancel_rec                OE_WSH_BULK_GRP.line_rec_type;
    l_po_close_rec                 OE_WSH_BULK_GRP.line_rec_type;
    --
    --
    l_additional_line_info_rec    WSH_BULK_PROCESS_PVT.additional_line_info_rec_type;
    l_txnHistoryRec               WSH_INBOUND_TXN_HISTORY_PKG.ib_txn_history_rec_type;
    l_tab_count                   NUMBER;
    --
    l_trx_wsh_location_id            NUMBER; -- IB-Phase-2
    --
    e_endOfAPI                    EXCEPTION;
    e_lineNotMatched              EXCEPTION;
   --
   l_debug_on           BOOLEAN;
   --
   l_module_name     CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'MATCHTRANSACTION';
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
    END IF;
    --
    SAVEPOINT matchTransaction_sp;
    --
    --
    IF p_action_prms.action_code = 'MATCH'
    THEN
       l_transactionType := WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT;
    ELSIF p_action_prms.action_code = 'MATCH_ADD'
    THEN
       l_transactionType := WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_ADD;
    ELSE
       l_transactionType   := p_action_prms.action_code;
    END IF;
    --
    -- { IB-phase-2
    IF    p_action_prms.action_code = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT
       OR p_action_prms.action_code = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_ADD
       OR l_transactionType         = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT
       OR l_transactionType         = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_ADD
    THEN
      WSH_INBOUND_UTIL_PKG.G_ASN_RECEIPT_MATCH_TYPE := 'AUTO';
    ELSE
      WSH_INBOUND_UTIL_PKG.G_ASN_RECEIPT_MATCH_TYPE := 'MANUAL';
    END IF;
    -- } IB-phase-2
    --
    -- { IB-Phase-2
    IF p_action_prms.ship_from_location_id IS NOT null
    THEN
      OPEN get_wsh_location_csr(p_action_prms.ship_from_location_id);
      FETCH get_wsh_location_csr INTO l_trx_wsh_location_id;
      CLOSE get_wsh_location_csr;

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_trx_wsh_location_id',l_trx_wsh_location_id);
      END IF;

      IF l_trx_wsh_location_id IS NULL
      THEN
         FND_MESSAGE.SET_NAME('WSH','WSH_IB_INVALID_WSH_LOC');
         wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
         RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    -- } IB-Phase-2
    --
    l_index             := p_line_rec.shipment_line_id.FIRST;
    l_firstIndex        := l_index;
    l_messageStartIndex := NVL(FND_MSG_PUB.COUNT_MSG,0) + 1;
    --
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'p_action_prms.action_code',p_action_prms.action_code);
        WSH_DEBUG_SV.log(l_module_name,'l_transactionType',l_transactionType);
        WSH_DEBUG_SV.log(l_module_name,'p_action_prms.ib_txn_history_id',p_action_prms.ib_txn_history_id);
        WSH_DEBUG_SV.log(l_module_name,'Total Input Records',p_line_rec.shipment_line_id.COUNT);
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_IB_TXN_MATCH_PKG.VALIDATEMANDATORYINFO',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    -- Validate mandatory fields required to be passed by Receiving Module
    --
    WSH_IB_TXN_MATCH_PKG.validateMandatoryInfo
      (
        p_transactionType  => l_transactionType,
        p_index            => l_index,
        x_line_rec         => p_line_rec,
        x_return_status    => l_return_status
      );
    --
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    wsh_util_core.api_post_call
      (
        p_return_status => l_return_status,
        x_num_warnings  => l_num_warnings,
        x_num_errors    => l_num_errors
      );
    --
    --
    l_shipmentNumber      := p_line_rec.shipment_num(l_index);
    l_receiptNumber       := p_line_rec.receipt_num(l_index);
    --l_receiptNumber     := p_line_rec.receipt_num(l_index);
    l_RCVShipmentHeaderId := p_line_rec.shipment_header_id(l_index);
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_BULK_PROCESS_PVT.Extend_tables',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    WSH_BULK_PROCESS_PVT.Extend_tables
      (
        p_line_rec                    => p_line_rec,
        p_action_prms                 => p_action_prms,
        x_table_count                 => l_tab_count,
        x_additional_line_info_rec    => l_additional_line_info_rec,
        x_return_status               => l_return_status
      );
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    wsh_util_core.api_post_call
      (
        p_return_status => l_return_status,
        x_num_warnings  => l_num_warnings,
        x_num_errors    => l_num_errors
      );
    --
    --
    IF p_line_rec.asn_type(l_index) IN ('ASN','ASBN')
    THEN
        l_ReceiptAgainstASN := 'Y';  -- Receipt against ASN
    ELSE
        l_ReceiptAgainstASN := 'N';  -- Direct Receipt
    END IF;
    --
    --
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_shipmentNumber',l_shipmentNumber);
        WSH_DEBUG_SV.log(l_module_name,'l_receiptNumber',l_receiptNumber);
        WSH_DEBUG_SV.log(l_module_name,'l_RCVShipmentHeaderId',l_RCVShipmentHeaderId);
        WSH_DEBUG_SV.log(l_module_name,'l_messageStartIndex',l_messageStartIndex);
        WSH_DEBUG_SV.log(l_module_name,'l_ReceiptAgainstASN',l_ReceiptAgainstASN);
        WSH_DEBUG_SV.log(l_module_name,'RCV TXN ID at FIRST',p_line_rec.rcv_transaction_id(p_line_rec.rcv_transaction_id.FIRST));
        WSH_DEBUG_SV.log(l_module_name,'RCV TXN ID at LAST',p_line_rec.rcv_transaction_id(p_line_rec.rcv_transaction_id.LAST));
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_TXN_HISTORY_PKG.GETTRANSACTIONTYPEMEANING',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    --
    --
    IF l_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_ADD
    THEN
    --{
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_TXN_HISTORY_PKG.GET_TXN_HISTORY',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        -- Check if record already exists in WSH_INBOUND_TXN_HISTORY
        --
        WSH_INBOUND_TXN_HISTORY_PKG.get_txn_history
          (
            p_shipment_header_id    => p_line_rec.shipment_header_id(l_index),
            p_transaction_type      => WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT,
            x_txn_history_rec       => l_txnHistoryRec,
            x_return_status         => l_return_status
          );
        --
        --
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.api_post_call
          (
            p_return_status => l_return_status,
            x_num_warnings  => l_num_warnings,
            x_num_errors    => l_num_errors
          );
        --
        IF l_txnHistoryRec.transaction_id IS NULL
        THEN
            l_transactionType := WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT;
        END IF;
    --}
    END IF;
    --
    --
    WSH_INBOUND_TXN_HISTORY_PKG.getTransactionTypeMeaning
      (
        p_transactionType     => l_transactionType,
        x_transactionMeaning  => l_transactionMeaning,
        x_return_status       => l_return_status
      );
    --
    --
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
        WSH_DEBUG_SV.log(l_module_name,'l_transactionType-Final',l_transactionType);
        WSH_DEBUG_SV.log(l_module_name,'l_transactionMeaning',l_transactionMeaning);
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    wsh_util_core.api_post_call
      (
        p_return_status => l_return_status,
        x_num_warnings  => l_num_warnings,
        x_num_errors    => l_num_errors
      );
    --
    --
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_IB_TXN_MATCH_PKG.CHECKSHIPMENTHISTORY',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    -- Check Shipment History
    -- In case of ASN/Receipt, check if same transaction is not being interfaced again.
    -- In case of child transactions, find out its parent transaction (and its status)
    --
    WSH_IB_TXN_MATCH_PKG.checkShipmentHistory
      (
        p_transactionType       =>  l_transactionType,
        p_shipmentHeaderId      =>  p_line_rec.shipment_header_id(l_index),
        p_ReceiptAgainstASN     =>  l_ReceiptAgainstASN,
        p_inboundTxnHistoryId   =>  p_action_prms.ib_txn_history_id,
        p_line_rec              =>  p_line_rec,
	p_ship_from_location_id =>  l_trx_wsh_location_id, -- IB-Phase-2
        x_parentTxnHistoryRec   =>  l_parentTxnHistoryRec,
        x_transactionId         =>  l_transactionId,
        x_transactionGroup      =>  l_transactionGroup,
        x_return_status         =>  l_return_status
      );
    --
    --
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    wsh_util_core.api_post_call
      (
        p_return_status => l_return_status,
        x_num_warnings  => l_num_warnings,
        x_num_errors    => l_num_errors
      );
    --
    --
    IF l_transactionType IN (
                              WSH_INBOUND_TXN_HISTORY_PKG.C_ASN,
                              WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT
                            )
    THEN
        l_headerTransactionId       := l_transactionId;
        l_headerObjectVersionNumber := 1;
        l_headerStatus              := WSH_INBOUND_TXN_HISTORY_PKG.C_PENDING;
    ELSE
        l_headerTransactionId       := l_parentTxnHistoryRec.transaction_id;
        l_headerObjectVersionNumber := l_parentTxnHistoryRec.object_version_number;
        l_headerStatus              := l_parentTxnHistoryRec.status;
    END IF;
    --
    IF NVL(l_parentTxnHistoryRec.status,'MATCHED') LIKE 'MATCHED%'
    THEN
        l_parentTransactionMatched := TRUE;
    ELSE
        l_parentTransactionMatched := FALSE;
    END IF;
    --
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_headerTransactionId',l_headerTransactionId);
        WSH_DEBUG_SV.log(l_module_name,'l_headerObjectVersionNumber',l_headerObjectVersionNumber);
        WSH_DEBUG_SV.log(l_module_name,'l_headerStatus',l_headerStatus);
        WSH_DEBUG_SV.log(l_module_name,'l_parentTransactionMatched',l_parentTransactionMatched);
    END IF;
    --
    --
    IF l_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_CANCEL_ASN
    THEN
    --{
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_IB_TXN_MATCH_PKG.PROCESSCANCELASN',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        WSH_IB_TXN_MATCH_PKG.processCancelASN
          (
            x_parentTxnHistoryRec   =>  l_parentTxnHistoryRec,
            x_return_status         =>  l_return_status
          );
        --
        --
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.api_post_call
          (
            p_return_status => l_return_status,
            x_num_warnings  => l_num_warnings,
            x_num_errors    => l_num_errors
          );
        --
        RAISE e_endOfAPI;
    --}
    ELSIF l_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_HEADER_UPD
    THEN
    --{
        IF l_parentTxnHistoryRec.transaction_id IS NULL
        THEN
        --{
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_IB_TXN_MATCH_PKG.INSERTTRANSACTIONHISTORY',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            -- Insert record into WSH_INBOUND_TXN_HISTORY for the receipt
            -- It is possible that during earlier receipt interface processing
            -- some fatal error was encountered and transaction was lost
            -- So, now insert it and keep it pending
            --
            WSH_IB_TXN_MATCH_PKG.insertTransactionHistory
              (
                p_transactionType       => WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT,
                p_ReceiptAgainstASN     => l_ReceiptAgainstASN,
                p_autonomous            => TRUE,
                p_index                 => p_line_rec.shipment_line_id.FIRST,
                p_line_rec              => p_line_rec,
		p_ship_from_location_id => l_trx_wsh_location_id, -- IB-Phase-2
                x_transactionId         => l_transactionId,
                x_return_status         => l_return_status
              );
            --
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            wsh_util_core.api_post_call
              (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors
              );
            --
            --
            l_transactionType     := WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT;
            l_headerTransactionId := l_transactionId;
            --
            --
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_TXN_HISTORY_PKG.GETTRANSACTIONTYPEMEANING',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_INBOUND_TXN_HISTORY_PKG.getTransactionTypeMeaning
              (
                p_transactionType     => l_transactionType,
                x_transactionMeaning  => l_transactionMeaning,
                x_return_status       => l_return_status
              );
            --
            --
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            wsh_util_core.api_post_call
              (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors
              );
            --
            --
            RAISE e_notMatched;
        --}
        ELSE
        --{
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'UPDATE WSH_INBOUND_TXN_HISTORY-R-HDR-UPD');
                WSH_DEBUG_SV.log(l_module_name,'l_RCVShipmentHeaderId',l_RCVShipmentHeaderId);
            END IF;
            --
            --
            UPDATE WSH_INBOUND_TXN_HISTORY
            SET    OBJECT_VERSION_NUMBER   = NVL(OBJECT_VERSION_NUMBER,0) + 1,
                   SHIPMENT_NUMBER         = l_shipmentNumber,
                   RECEIPT_NUMBER          = l_receiptNumber,
                   LAST_UPDATE_DATE        = SYSDATE,
                   LAST_UPDATED_BY         = FND_GLOBAL.USER_ID,
                   LAST_UPDATE_LOGIN       = FND_GLOBAL.LOGIN_ID
            WHERE  SHIPMENT_HEADER_ID      = l_RCVShipmentHeaderId
            AND    TRANSACTION_TYPE   NOT IN ('ROUTING_RESPONSE','ROUTING_REQUEST');
            --
            IF SQL%ROWCOUNT = 0
            THEN
                FND_MESSAGE.SET_NAME('WSH','WSH_IB_TXN_HDR_UPD_ERROR');
                FND_MESSAGE.SET_TOKEN('SHIPMENT_HEADER_ID',l_RCVShipmentHeaderId);
                wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
                RAISE FND_API.G_EXC_ERROR;
            END IF;
            --
            --
            IF l_parentTransactionMatched
            THEN
                NULL;
                --TODO LATER
            END IF;
        --}
        END IF;
        --
        RAISE e_endOfAPI;
    --}
    ELSIF l_transactionType     = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT
    AND   l_ReceiptAgainstASN   = 'Y'
    AND   NOT(l_parentTransactionMatched)
    THEN
    --{
        --
        -- Cannot match receipt until parent ASN is matched
        --
        FND_MESSAGE.SET_NAME('WSH','WSH_IB_PENDING_ASN_MATCH');
        FND_MESSAGE.SET_TOKEN('SHIPMENT_NUM',l_shipmentNumber);
        FND_MESSAGE.SET_TOKEN('RECEIPT_NUM',l_receiptNumber);
        wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
        --
        RAISE e_notMatched;
    --}
    END IF;
    /*
    if rcv-c,rtv,rtv-c,rcv-a
      check if rsl is pending
      if so set rsl_pend=true
    */
    --
    -- { IB-Phase-2
    -- ASN / Receipt has ShipFromLocation at Header Level.
    IF l_trx_wsh_location_id IS NOT NULL
    THEN
       l_txnUniqueSFLocnFound     := TRUE;
       l_txnUniqueSFLocnId        := l_trx_wsh_location_id;
    ELSE
       l_txnUniqueSFLocnFound     := FALSE;
       l_txnUniqueSFLocnId        := NULL;
    END IF;
    -- } IB-Phase-2
    l_maxTransactionId         := -1;
    l_minTransactionId         := 1E38;
    l_minFailedTransactionId   := 1E38;--- tbe set in line fail excep
    l_minMatchedTransactionId  := 1E38;
    --l_lastMatchedTransactionId := NULL; ??----to be set at end of loop
    --
    -- Loop through each input line
    --
    WHILE l_index IS NOT NULL
    LOOP
    --{
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Processing p_line_rec at l_index',l_index);
        END IF;
        --
        --
        IF l_index <> l_firstIndex
        THEN
        --{
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_IB_TXN_MATCH_PKG.VALIDATEMANDATORYINFO',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_IB_TXN_MATCH_PKG.validateMandatoryInfo
              (
                p_transactionType  => l_transactionType,
                p_index            => l_index,
                x_line_rec         => p_line_rec,
                x_return_status    => l_return_status
              );
            --
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            wsh_util_core.api_post_call
              (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors
              );
        --}
        END IF;
        --
        --
        l_poShipmentLineId      := p_line_rec.po_shipment_line_id(l_index);
        l_key                   := NULL;
        --
        l_poHeaderNumber        := p_line_rec.source_header_number(l_index);
        l_poLineNumber          := p_line_rec.source_line_number(l_index);
        l_poShipmentLineNumber  := p_line_rec.po_shipment_line_number(l_index);
        l_poReleaseNumber       := p_line_rec.source_blanket_reference_num(l_index);
        l_transactionId         := p_line_rec.rcv_transaction_id(l_index);
        --
        l_maxTransactionId      := GREATEST(  l_maxTransactionId, l_transactionId);
        l_minTransactionId      := LEAST(     l_minTransactionId, l_transactionId);
        --
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_poShipmentLineId',l_poShipmentLineId);
            WSH_DEBUG_SV.log(l_module_name,'l_transactionId',l_transactionId);
            WSH_DEBUG_SV.log(l_module_name,'MIN TxnID, Max TxnID',l_minTransactionId ||',' ||l_maxTransactionId);
            WSH_DEBUG_SV.log(l_module_name,'PO Ref.Numbers:HDR|REL|LINE|PSL',
                                            l_poHeaderNumber
                                            || '|'
                                            || l_poReleaseNumber
                                            || '|'
                                            || l_poLineNumber
                                            || '|'
                                            || l_poShipmentLineNumber
                            );
            WSH_DEBUG_SV.log(l_module_name,'PO Ref.IDs:HDR|REL|LINE|PSL',
                                            p_line_rec.header_id(l_index)
                                            || '|'
                                            || p_line_rec.source_blanket_reference_id(l_index)
                                            || '|'
                                            || p_line_rec.line_id(l_index)
                                            || '|'
                                            || p_line_rec.po_shipment_line_id(l_index)
                            );

            WSH_DEBUG_SV.log(l_module_name,'p_line_rec.shipment_header_id',p_line_rec.shipment_header_id(l_index));
            WSH_DEBUG_SV.log(l_module_name,'p_line_rec.shipment_line_id',p_line_rec.shipment_line_id(l_index));
        END IF;
        --
        --
        BEGIN
        --{
            /*
            IF  l_transactionType     = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_ADD
            AND l_ReceiptAgainstASN   = 'Y'
            THEN
            --{
                OPEN rcv_line_check_csr( p_line_rec.shipment_line_id(l_index) );
                --
                FETCH rcv_line_check_csr INTO l_totalReceivedQuantity;
                --
                IF rcv_line_check_csr%NOTFOUND
                THEN
                --{
                    FND_MESSAGE.SET_NAME('WSH','WSH_IB_RSL_NOT_FOUND');
                    FND_MESSAGE.SET_TOKEN('RCV_SHIPMENT_LINE_ID',p_line_rec.shipment_line_id(l_index));
                    wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
                    RAISE FND_API.G_EXC_ERROR;
                --}
                END IF;
                --
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'l_totalReceivedQuantity',l_totalReceivedQuantity);
                    WSH_DEBUG_SV.log(l_module_name,'p_line_rec.received_quantity',p_line_rec.received_quantity(l_index));
                END IF;
                --
                --
                IF l_totalReceivedQuantity <> p_line_rec.received_quantity(l_index)
                THEN
                --{
                    l_transactionType := WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_CORRECTION;
                    --
                    --
                    --
                    -- Debug Statements
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_TXN_HISTORY_PKG.GETTRANSACTIONTYPEMEANING',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    WSH_INBOUND_TXN_HISTORY_PKG.getTransactionTypeMeaning
                      (
                        p_transactionType     => l_transactionType,
                        x_transactionMeaning  => l_transactionMeaning,
                        x_return_status       => l_return_status
                      );
                    --
                    --
                    --
                    -- Debug Statements
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    wsh_util_core.api_post_call
                      (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                      );
                --}
                END IF;
            --}
            END IF;
            */
            --
            --
            /*
            IF l_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_CORRECTION
            THEN
                IF p_line_rec.received_quantity(l_index) > 0
                THEN
                    l_transactionSubType := WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_CORRECTION_POSITIVE;
                ELSE
                    l_transactionSubType := WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_CORRECTION_NEGATIVE;
                END IF;
            ELSIF l_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RTV_CORRECTION
            THEN
                IF p_line_rec.received_quantity(l_index) > 0
                THEN
                    l_transactionSubType := WSH_INBOUND_TXN_HISTORY_PKG.C_RTV_CORRECTION_POSITIVE;
                ELSE
                    l_transactionSubType := WSH_INBOUND_TXN_HISTORY_PKG.C_RTV_CORRECTION_NEGATIVE;
                END IF;
            ELSE
                l_transactionSubType := l_transactionType;
            END IF;
            */
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_transactionType',l_transactionType);
                --WSH_DEBUG_SV.log(l_module_name,'l_transactionSubType',l_transactionSubType);
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_IB_TXN_MATCH_PKG.GETTRANSACTIONKEY',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            -- Key for each input line can be PLL/RSL ID
            --
            WSH_IB_TXN_MATCH_PKG.getTransactionKey
              (
                p_transactionType    => l_transactionType,
                p_ReceiptAgainstASN  => l_ReceiptAgainstASN,
                p_index              => l_index,
                p_line_rec           => p_line_rec,
                x_key                => l_key,
                x_transactionSubType => l_transactionSubType,
                x_return_status      => l_return_status
              );
            --
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                WSH_DEBUG_SV.log(l_module_name,'l_key',l_key);
                WSH_DEBUG_SV.log(l_module_name,'l_transactionSubType',l_transactionSubType);
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            wsh_util_core.api_post_call
              (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors
              );
            --
            --
            IF NOT(l_parentTransactionMatched)
            THEN
            --{
                --
                -- Cannot match child transaction until parent(receipt) transaction has matched
                --
                l_messageName := 'WSH_IB_PEND_PARENT_TXN_MATCH';
                RAISE e_lineNotMatched;
            --}
            END IF;
            --
            --
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_CACHED_VALUE-l_linkTbl',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            -- Check if key is already processed in the current call(execution)
            --
            wsh_util_core.get_cached_value
              (
                p_cache_tbl         => l_linkTbl,
                p_cache_ext_tbl     => l_linkExtTbl,
                p_key               => l_key,     --l_poShipmentLineId,
                p_value             => l_linkRecString,
                p_action            => 'GET',
                x_return_status     => l_return_status
              );
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
            END IF;
            --
            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR
            THEN
                RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
            THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING
            THEN
            --{
                -- Since  key is not already processed in the current call(execution),
                -- let's set the query conditions(depending on transaction type)
                -- to obtain corresponding lines from delivery details
                -- which can be further evaluated for matching
                --
                IF l_transactionType       = WSH_INBOUND_TXN_HISTORY_PKG.C_ASN
                THEN
                --{
                    l_released_status       := 'X';
                    l_shipmentHeaderId      := NULL;
                    l_rcvShipmentLineId     := NULL;
                    --l_key                   := l_poShipmentLineId;
                    l_transactionDate       := p_line_rec.shipped_date(l_index);
                    l_shipFromLocationId    := l_trx_wsh_location_id; -- IB-Phase-2  NULL;
                    l_orderByFlag           := -1;
                    l_resetTxnUniqueSFLocn  := FALSE;
                --}
                ELSIF l_transactionType      = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT
                THEN
                --{
                    IF l_ReceiptAgainstASN   = 'Y'
                    THEN
                        l_released_status       := 'C';
                        l_shipmentHeaderId      := l_parentTxnHistoryRec.shipment_header_id;
                        l_rcvShipmentLineId     := p_line_rec.shipment_line_id(l_index);
                        --l_key                   := l_rcvShipmentLineId;
                        l_orderByFlag           := -2;
       		        --IB-PHASE-2
                        IF l_trx_wsh_location_id IS NULL
       	                THEN
                          l_resetTxnUniqueSFLocn  := TRUE;
                        ELSE
                          l_resetTxnUniqueSFLocn  := FALSE;
		        END IF;
                        --IB-PHASE-2
                        --
                        --
                        --l_txnUniqueSFLocnFound  := TRUE;
                        --l_txnUniqueSFLocnId     := WSH_UTIL_CORE.C_NULL_SF_LOCN_ID;
                    ELSE
                        l_released_status       := 'X';
                        l_shipmentHeaderId      := NULL;
                        l_rcvShipmentLineId     := NULL;
                        --l_key                   := l_poShipmentLineId;
                        l_orderByFlag           := -1;
                        l_resetTxnUniqueSFLocn  := FALSE;
                    END IF;
                    --
                    l_transactionDate       := p_line_rec.expected_receipt_date(l_index);
                    l_shipFromLocationId    := l_trx_wsh_location_id; -- IB-Phase-2 NULL;
                --}
                ELSIF l_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_ADD
                THEN
                --{
                    IF l_receiptShipFromLocationCount IS NULL
                    THEN
                    --{
                        l_receiptShipFromLocationCount := 0;
                        --
                        -- For add to receipt case,
                        -- find out if receipt matched against with all
                        -- deliveries having same ship-from location
                        -- or deliveries with different ship-from location
                        --
                        -- If receipt matched against only one ship-from
                        -- location, then that is the unique ship-from
                        -- location for add-to-receipt transaction as well
                        -- and we need to find delivery lines with that particular
                        -- ship-from location
                        --
                        FOR receipt_locn_rec IN receipt_locn_csr (p_line_rec.shipment_header_id(l_index))
                        LOOP
                        --{
                            l_receiptShipFromLocationCount := l_receiptShipFromLocationCount + 1;
                            l_receiptShipFromLocationId    := receipt_locn_rec.initial_pickup_location_id;
                        --}
                        END LOOP;
                    --}
                    END IF;
                    --
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name,'l_receiptShipFromLocationId',l_receiptShipFromLocationId);
                    END IF;
                    --
                    --
                    IF l_receiptShipFromLocationCount = 0
                    THEN
                    --{
                        l_messageName := 'WSH_IB_PARENT_MATCH_NOT_FOUND';
                        RAISE e_lineNotMatched;---- exit of api as we should not continue for another line
                    --}
                    END IF;
                    --
                    --
                    l_released_status       := 'X';
                    l_transactionDate       := p_line_rec.expected_receipt_date(l_index);
                    l_shipmentHeaderId      := NULL;
                    l_rcvShipmentLineId     := NULL;
                    --l_key                   := l_poShipmentLineId;
                    l_orderByFlag           := -1;
                    l_shipFromLocationId    := l_trx_wsh_location_id; -- IB-Phase-2 NULL;
       		    --IB-PHASE-2
                    IF l_trx_wsh_location_id IS NULL
       	            THEN
                      l_resetTxnUniqueSFLocn  := TRUE;
                    ELSE
                      l_resetTxnUniqueSFLocn  := FALSE;
		    END IF;
                    --IB-PHASE-2
                    --
                    IF l_receiptShipFromLocationCount = 1
                    THEN
                    --{
                        l_txnUniqueSFLocnFound  := TRUE;
			-- { IB-Phase-2
                        IF l_trx_wsh_location_id IS NULL
                        THEN
                           l_txnUniqueSFLocnId     := l_receiptShipFromLocationId;
                        END IF;
			-- } IB-Phase-2
                        --l_shipFromLocationId    := l_receiptShipFromLocationId;
                        l_resetTxnUniqueSFLocn  := FALSE;
                    --}
                    END IF;
                    --
                    /*
                    IF l_receiptShipFromLocationCount = 1
                    THEN
                    --{
                        l_released_status       := 'X';
                        l_transactionDate       := p_line_rec.expected_receipt_date(l_index);
                        l_shipmentHeaderId      := NULL;
                        l_rcvShipmentLineId     := NULL;
                        l_key                   := l_poShipmentLineId;
                        l_txnUniqueSFLocnFound  := TRUE;
                        l_txnUniqueSFLocnId     := l_receiptShipFromLocationId;
                        l_shipFromLocationId    := l_receiptShipFromLocationId;
                    --}
                    ELSIF l_receiptShipFromLocationCount > 1
                    THEN
                    --{
                        FND_MESSAGE.SET_NAME('WSH','WSH_IB_PARENT_MULTI_SF_MATCH');
                        FND_MESSAGE.SET_TOKEN('TRANSACTION_TYPE',p_action_prms.action_code);
                        FND_MESSAGE.SET_TOKEN('SHIPMENT_NUM',l_shipmentNumber);
                        FND_MESSAGE.SET_TOKEN('RECEIPT_NUM',l_receiptNumber);
                        wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
                        --
                        RAISE e_lineNotMatched;
                    --}
                    END IF;
                    */
                --}
                ELSIF l_transactionType IN (
                                             WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_CORRECTION,
                                             WSH_INBOUND_TXN_HISTORY_PKG.C_RTV               ,
                                             WSH_INBOUND_TXN_HISTORY_PKG.C_RTV_CORRECTION
                                           )
                THEN
                --{
                    l_released_status       := 'L';
                    l_transactionDate       := p_line_rec.expected_receipt_date(l_index);
                    l_shipmentHeaderId      := NULL;
                    l_rcvShipmentLineId     := p_line_rec.shipment_line_id(l_index);
                    --l_key                   := l_rcvShipmentLineId;
                    --IB-PHASE-2
                    IF l_trx_wsh_location_id IS NULL
       	            THEN
                      l_resetTxnUniqueSFLocn  := TRUE;
                    ELSE
                      l_resetTxnUniqueSFLocn  := FALSE;
	            END IF;
                    --IB-PHASE-2
                    l_shipFromLocationId    := l_trx_wsh_location_id; -- IB-Phase-2 NULL;
                    --
                    IF l_transactionSubType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_CORRECTION_POSITIVE
                    OR l_transactionSubType = WSH_INBOUND_TXN_HISTORY_PKG.C_RTV_CORRECTION_NEGATIVE
                    THEN
                        l_orderByFlag       := -3;
                    ELSIF l_transactionSubType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_CORRECTION_NEGATIVE
                    THEN
                        l_orderByFlag       := -4;
                    ELSE
                        l_orderByFlag       := -5;
                    END IF;
                    --
                    --
                    l_dummy := 0;
                    --
                    -- Check if parent receipt line is pending matching
                    --
                    OPEN txn_line_status_csr
                            (
                              p_shipment_header_id  => p_line_rec.shipment_header_id(l_index),
                              p_shipment_line_id    => l_rcvShipmentLineId
                            );
                    FETCH txn_line_status_csr INTO l_dummy;
                    CLOSE txn_line_status_csr;
                    --
                    IF l_dummy = 1
                    THEN
                    --{
                        -- Cannot match child transaction until parent receipt
                        -- line has matched
                        --
                        l_messageName := 'WSH_IB_PEND_PARENT_LINE_MATCH';
                        RAISE e_lineNotMatched;
                    --}
                    END IF;
                    --
                    --
                    /*
                    l_dummy := 0;
                    --
                    OPEN rcv_line_csr
                            (
                              p_source_header_id              => p_line_rec.header_id(l_index),
                              p_source_line_id                => p_line_rec.line_id(l_index),
                              p_po_shipment_line_id           => p_line_rec.po_shipment_line_id(l_index),
                              p_source_blanket_Reference_id   => p_line_rec.source_blanket_reference_id(l_index),
                              p_shipment_line_id              => l_rcvShipmentLineId,
                              p_transactionSubType            => l_transactionSubType
                            );
                    FETCH rcv_line_csr INTO l_dummy;
                    CLOSE rcv_line_csr;
                    --
                    IF l_dummy > 1
                    THEN
                    --{
                        l_messageName := 'WSH_IB_PARNT_LIN_MULT_SF_MATCH';

                        RAISE e_lineNotMatched;
                    --}
                    ELSIF l_dummy = 0
                    THEN
                        RAISE e_lineFatalError;
                    END IF;
                    */
                --}
                END IF;
                --
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'l_released_status',l_released_status);
                    WSH_DEBUG_SV.log(l_module_name,'l_shipmentHeaderId',l_shipmentHeaderId);
                    WSH_DEBUG_SV.log(l_module_name,'l_shipFromLocationId',l_shipFromLocationId);
                    WSH_DEBUG_SV.log(l_module_name,'l_rcvShipmentLineId',l_rcvShipmentLineId);
                    WSH_DEBUG_SV.log(l_module_name,'l_orderByFlag',l_orderByFlag);
                    WSH_DEBUG_SV.log(l_module_name,'l_resetTxnUniqueSFLocn',l_resetTxnUniqueSFLocn);
                    WSH_DEBUG_SV.log(l_module_name,'l_txnUniqueSFLocnFound',l_txnUniqueSFLocnFound);
                    WSH_DEBUG_SV.log(l_module_name,'l_txnUniqueSFLocnId',l_txnUniqueSFLocnId);
                END IF;
                --
                --
                IF p_action_prms.action_code IN ( 'MATCH','MATCH_ADD')
                THEN
                --{
                    l_shipped_lines := 0;
                    --
                    OPEN shipped_line_csr
                            (
                              p_source_header_id              => p_line_rec.header_id(l_index),
                              p_source_line_id                => p_line_rec.line_id(l_index),
                              p_po_shipment_line_id           => p_line_rec.po_shipment_line_id(l_index),
                              p_source_blanket_Reference_id   => p_line_rec.source_blanket_reference_id(l_index)
                            );
                    --
                    FETCH shipped_line_csr INTO l_shipped_lines;
                    CLOSE shipped_line_csr;
                    --
                    IF l_shipped_lines > 0
                    THEN
                    --{
                        IF p_action_prms.action_code = 'MATCH_ADD'
                        THEN
                        --{
                            l_messageName := 'WSH_IB_NOT_MATCH_SHP_LINES';
                            RAISE e_lineNotMatched;
                        --}
                        ELSE
                        --{
                            FND_MESSAGE.SET_NAME('WSH','WSH_IB_NOT_MATCH_SHP_LINES');
                            --
                            FND_MESSAGE.SET_TOKEN('TRANSACTION_TYPE',l_transactionMeaning); --p_action_prms.action_code);
                            FND_MESSAGE.SET_TOKEN('SHIPMENT_NUM',l_shipmentNumber);
                            FND_MESSAGE.SET_TOKEN('RECEIPT_NUM',l_receiptNumber);
                            --
                            FND_MESSAGE.SET_TOKEN('PO_HEADER_NUM',l_poHeaderNumber);
                            FND_MESSAGE.SET_TOKEN('PO_LINE_NUM',l_poLineNumber);
                            FND_MESSAGE.SET_TOKEN('PO_SHIPMENT_LINE_NUM',l_poShipmentLineNumber);
                            FND_MESSAGE.SET_TOKEN('PO_RELEASE_NUM',l_poReleaseNumber);
                            --
                            wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
                            --
                            RAISE e_NotMatched;
                        --}
                        END IF;
                    --}
                    END IF;
                --}
                END IF;
                --
                --
                -- Fetch delivery lines corresponding to input ASN/Receipt lines
                --
                OPEN line_csr
                        (
                          p_source_header_id              => p_line_rec.header_id(l_index),
                          p_source_line_id                => p_line_rec.line_id(l_index),
                          p_po_shipment_line_id           => p_line_rec.po_shipment_line_id(l_index),
                          p_source_blanket_Reference_id   => p_line_rec.source_blanket_reference_id(l_index),
                          p_released_status               => l_released_status,
                          p_shipment_header_id            => l_shipmentHeaderId,
                          p_ship_from_location_id         => l_shipFromLocationId,
                          p_rcvShipmentLineID             => l_rcvShipmentLineId,
                          p_transactionSubType            => l_transactionSubType,
                          p_orderByFlag                   => l_orderByFlag
                        );
                --
                FETCH line_csr BULK COLLECT
                INTO --l_lineRecTbl; -- replaced due to 8.1.7.4 pl/sql bug
                     l_lineRecTbl.delivery_detail_id_tbl,
                     l_lineRecTbl.requested_quantity_tbl,
                     l_lineRecTbl.picked_quantity_tbl,
                     l_lineRecTbl.shipped_quantity_tbl,
                     l_lineRecTbl.received_quantity_tbl,
                     l_lineRecTbl.returned_quantity_tbl,
                     l_lineRecTbl.requested_quantity2_tbl,
                     l_lineRecTbl.picked_quantity2_tbl,
                     l_lineRecTbl.shipped_quantity2_tbl,
                     l_lineRecTbl.received_quantity2_tbl,
                     l_lineRecTbl.returned_quantity2_tbl,
                     l_lineRecTbl.ship_from_location_id_tbl,
                     l_lineRecTbl.earliest_dropoff_date_tbl,
                     l_lineRecTbl.delivery_id_tbl,
                     l_lineRecTbl.rcv_shipment_line_id_tbl,
                     l_lineRecTbl.requested_quantity_uom_tbl,
                     l_lineRecTbl.requested_quantity_uom2_tbl,
                     l_lineRecTbl.released_status_tbl,
                     l_lineRecTbl.src_requested_quantity_tbl,
                     l_lineRecTbl.src_requested_quantity2_tbl,
                     l_lineRecTbl.last_update_date_tbl;
                --
                l_lineCount := line_csr%ROWCOUNT;
                --
                CLOSE line_csr;
                --
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'l_lineCount',l_lineCount);
                END IF;
                --
                IF l_lineCount = 0
                THEN
                --{
                    -- No eligible delivery lines found corresponding to input ASN/Receipt line
                    -- Check if there is at least one line corresponding
                    -- to PO shipment line
                    -- If yes, it may be case of over-receipt and let's
                    -- create a new line with ordered qty. of 0.
                    -- If not, this may be an error
                    --
                    IF l_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_ASN
                    OR l_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_ADD
                    OR (
                            l_transactionType    = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT
                        AND l_ReceiptAgainstASN <> 'Y'
                       )
                    THEN
                    --{
                        OPEN po_line_csr
                                (
                                  p_source_header_id              => p_line_rec.header_id(l_index),
                                  p_source_line_id                => p_line_rec.line_id(l_index),
                                  p_po_shipment_line_id           => p_line_rec.po_shipment_line_id(l_index),
                                  p_source_blanket_Reference_id   => p_line_rec.source_blanket_reference_id(l_index)
                                );
                        --
                        FETCH po_line_csr INTO l_primaryUOMCode, l_secondaryUOMCode,
                                               l_src_requested_quantity, l_src_requested_quantity2;
                        --
                        l_lineCount := po_line_csr%ROWCOUNT;
                        --
                        CLOSE po_line_csr;
                        --
                        IF l_lineCount = 1
                        THEN
                        --{
                            --
                            -- Debug Statements
                            --
                            IF l_debug_on THEN
                                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_IB_TXN_MATCH_PKG.ADDNEWLINE',WSH_DEBUG_SV.C_PROC_LEVEL);
                            END IF;
                            --
                            WSH_IB_TXN_MATCH_PKG.addNewLine
                              (
                                p_lineDate            => l_transactionDate,
                                p_primaryUomCode      => l_primaryUOMCode,
                                p_secondaryUOMCode    => l_secondaryUOMCode,
                                x_lineRecTbl          => l_lineRecTbl,
                                x_return_status       => l_return_status
                              );
                            --
                            --
                            --
                            -- Debug Statements
                            --
                            IF l_debug_on THEN
                                WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
                            END IF;
                            --
                            wsh_util_core.api_post_call
                              (
                                p_return_status => l_return_status,
                                x_num_warnings  => l_num_warnings,
                                x_num_errors    => l_num_errors
                              );
                        --}
                        END IF;
                    --}
                    END IF;
                    --
                    --
                    IF l_lineCount = 0
                    THEN
                    --{
                        /*
                        IF l_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_ASN
                        OR l_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_ADD
                        OR (
                                l_transactionType    = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT
                            AND l_ReceiptAgainstASN <> 'Y'
                           )
                        THEN
                        --{
                        */
                        --
                        IF l_transactionSubType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_CORRECTION_POSITIVE
                        THEN
                        --{
                            l_messageName := 'WSH_IB_INVALID_PO_LINE_ERROR';
                            RAISE e_lineNotMatched;
                        --}
                        ELSE
                        --{
                            FND_MESSAGE.SET_NAME('WSH','WSH_IB_INVALID_PO_LINE_ERROR');
                            FND_MESSAGE.SET_TOKEN('TRANSACTION_TYPE',l_transactionMeaning);
                            FND_MESSAGE.SET_TOKEN('SHIPMENT_NUM',l_shipmentNumber);
                            FND_MESSAGE.SET_TOKEN('RECEIPT_NUM',l_receiptNumber);
                            FND_MESSAGE.SET_TOKEN('PO_HEADER_NUM',l_poHeaderNumber);
                            FND_MESSAGE.SET_TOKEN('PO_LINE_NUM',l_poLineNumber);
                            FND_MESSAGE.SET_TOKEN('PO_SHIPMENT_LINE_NUM',l_poShipmentLineNumber);
                            FND_MESSAGE.SET_TOKEN('PO_RELEASE_NUM',l_poReleaseNumber);
                            wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
                            RAISE FND_API.G_EXC_ERROR;
                        --}
                        END IF;
                        --
                        /*
                        --}
                        ELSIF l_transactionType    = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT
                        AND   l_ReceiptAgainstASN  = 'Y'
                        THEN
                        --{
                        --}
                        ELSE
                        --{
                            message
                            RAISE e_lineFatalError;
                        --}
                        END IF;
                        */
                    --}
                    END IF;
                --}
                ELSE
                --{
                    l_src_requested_quantity  := l_lineRecTbl.src_requested_quantity_tbl(1);
                    l_src_requested_quantity2 := l_lineRecTbl.src_requested_quantity2_tbl(1);
                --}
                END IF;
                --
                --
                IF  l_transactionType                        = WSH_INBOUND_TXN_HISTORY_PKG.C_ASN
                AND p_line_rec.received_quantity2(l_index)  IS NULL
                AND l_src_requested_quantity2               IS NOT NULL
                THEN
                --{
                    -- Calculate secondary shipped qty. for OPM cases (ASN does not support OPM)
                    --
-- HW OPMCONV - Use C_MAX_DECIMAL_DIGITS_INV instead of C_MAX_DECIMAL_DIGITS_OPM
                    p_line_rec.received_quantity2(l_index)
                    := ROUND
                        (
                          l_src_requested_quantity2 * p_line_rec.received_quantity(l_index)
                          / l_src_requested_quantity,
                          WSH_UTIL_CORE.C_MAX_DECIMAL_DIGITS_INV
                        );
                --}
                END IF;
                --
                --
                l_linePreviousSFLocnId      := -2;
                l_lineUniqueSFLocnFound     := TRUE;
                l_lineUniqueSFLocnId        := NULL;
                l_start_Index               := l_end_Index + 1;
                --
                -- Loop through delivery lines fetched
                --
                -- Main purpose is to find unique ship-from location
                -- i.e. if all delivery lines have same ship-from location
                --
                -- We set l_lineUniqueSFLocnId to first line's  ship-from location
                -- Thereafter, whenever current line's ship-from location is not
                -- equal to l_lineUniqueSFLocnId, it implies delivery lines do not have
                -- unique ship-from location.
                --
                FOR i in 1..l_lineCount
                LOOP
                --{
                    l_lineSFLocnId          := l_lineRecTbl.ship_from_location_id_tbl(i);
                    l_lineUniqueSFLocnId    := NVL(l_lineUniqueSFLocnId, l_lineSFLocnId);
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name,'i',i);
                        WSH_DEBUG_SV.log(l_module_name,'l_lineSFLocnId',l_lineSFLocnId);
                        WSH_DEBUG_SV.log(l_module_name,'l_lineUniqueSFLocnId',l_lineUniqueSFLocnId);
                        WSH_DEBUG_SV.log(l_module_name,'l_linePreviousSFLocnId',l_linePreviousSFLocnId);
                    END IF;
                    --
                    --
                    IF  l_lineSFLocnId <> l_lineUniqueSFLocnId
                    THEN
                    --{
                        -- Line's ship-from location is different from unique ship-from
                        -- location found so far
                        -- As long as, line's ship-from location is not null, it implies
                        -- a change and hence we conclude that delivery lines have different ship-from
                        -- locations. This is applicable for ASN/Receipt
                        -- (Refer to appendix1 in DLD for examples)
                        --
                        -- For child transactions(indicated by l_resetTxnUniqueSFLocn=TRUE), even when
                        -- line's ship-from location is null,it is a change.
                        --
                        --
                        IF l_lineSFLocnId <> WSH_UTIL_CORE.C_NULL_SF_LOCN_ID
                        THEN
                            l_lineUniqueSFLocnFound := FALSE;
                        ELSE
                            --IF  (l_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_ADD
                            --AND l_receiptShipFromLocationCount > 1)
                            --or other child txns
                            -- replaced by following
                            IF l_resetTxnUniqueSFLocn
                            THEN
                                l_lineUniqueSFLocnFound := FALSE;
                            END IF;
                        END IF;
                    --}
                    END IF;
                    --
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name,'l_lineUniqueSFLocnFound',l_lineUniqueSFLocnFound);
                    END IF;
                    --
                    --
                    IF  NOT(l_lineUniqueSFLocnFound)
                    --AND l_transactionType              = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_ADD
                    --AND l_receiptShipFromLocationCount > 1
                    AND l_resetTxnUniqueSFLocn
                    --AND l_transactionType              <> WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT
                    THEN
                        -- Since delivery lines have different ship-from locations
                        -- cannot match the input child transaction
                        -- Raise line-level "not matched" exception
                        -- to mark current receipt line as match failure
                        --
                        IF l_transactionType              = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_ADD
                        THEN
                            l_messageName := 'WSH_IB_PARENT_MULTI_SF_MATCH';
                        ELSE
                            l_messageName := 'WSH_IB_PARNT_LIN_MULT_SF_MATCH';
                        END IF;
                        --
                        IF  l_ReceiptAgainstASN  = 'Y'
                        AND l_transactionType      = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT
                        THEN
                        --{
                            FND_MESSAGE.SET_NAME('WSH',l_messageName);
                            --
                            FND_MESSAGE.SET_TOKEN('TRANSACTION_TYPE',l_transactionMeaning); --p_action_prms.action_code);
                            FND_MESSAGE.SET_TOKEN('SHIPMENT_NUM',l_shipmentNumber);
                            FND_MESSAGE.SET_TOKEN('RECEIPT_NUM',l_receiptNumber);
                            --
                            FND_MESSAGE.SET_TOKEN('PO_HEADER_NUM',l_poHeaderNumber);
                            FND_MESSAGE.SET_TOKEN('PO_LINE_NUM',l_poLineNumber);
                            FND_MESSAGE.SET_TOKEN('PO_SHIPMENT_LINE_NUM',l_poShipmentLineNumber);
                            FND_MESSAGE.SET_TOKEN('PO_RELEASE_NUM',l_poReleaseNumber);
                            --
                            wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
                            --
                            RAISE e_NotMatched;
                        --}
                        ELSE
                            RAISE e_lineNotMatched;
                        END IF;
                    END IF;
                    --
                    --
                    IF  (
                             l_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_ASN
                          OR (
                                  l_transactionType    = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT
                              AND l_ReceiptAgainstASN <> 'Y'
                             )
                        )
                    --AND ( i = 1 OR l_lineSFLocnId <> l_lineUniqueSFLocnId )
                    -- replaced with the following line
                    AND ( l_lineSFLocnId <> l_linePreviousSFLocnId )
                    AND l_lineSFLocnId <> WSH_UTIL_CORE.C_NULL_SF_LOCN_ID
                    THEN
                    --{
                        --
                        -- Debug Statements
                        --
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_CACHED_VALUE-l_shipFromLocationIdTbl',WSH_DEBUG_SV.C_PROC_LEVEL);
                        END IF;
                        --
                        wsh_util_core.get_cached_value
                          (
                            p_cache_tbl         => l_shipFromLocationIdTbl,
                            p_cache_ext_tbl     => l_shipFromLocationIdExtTbl,
                            p_key               => l_lineSFLocnId,
                            p_value             => l_shipFromLocationIdLineCount,
                            p_action            => 'GET',
                            x_return_status     => l_return_status
                          );
                        --
                        IF l_debug_on THEN
                             WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                        END IF;
                        --
                        --
                        IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR
                        THEN
                            RAISE FND_API.G_EXC_ERROR;
                        ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
                        THEN
                            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                        ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING
                        THEN
                            l_shipFromLocationIdLineCount := 1;
                        ELSE
                            l_shipFromLocationIdLineCount := NVL(l_shipFromLocationIdLineCount,0) + 1;
                        END IF;
                        --
                        --
                        --
                        -- Debug Statements
                        --
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_CACHED_VALUE-l_shipFromLocationIdTbl',WSH_DEBUG_SV.C_PROC_LEVEL);
                        END IF;
                        --
                        wsh_util_core.get_cached_value
                          (
                            p_cache_tbl         => l_shipFromLocationIdTbl,
                            p_cache_ext_tbl     => l_shipFromLocationIdExtTbl,
                            p_key               => l_lineSFLocnId,
                            p_value             => l_shipFromLocationIdLineCount,
                            p_action            => 'PUT',
                            x_return_status     => l_return_status
                          );
                        --
                        --
                        --
                        -- Debug Statements
                        --
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
                        END IF;
                        --
                        wsh_util_core.api_post_call
                          (
                            p_return_status => l_return_status,
                            x_num_warnings  => l_num_warnings,
                            x_num_errors    => l_num_errors
                          );
                    --}
                    END IF;
                    --
                    l_linePreviousSFLocnId := l_lineSFLocnId ;
                    --
                    IF l_debug_on  THEN
                        WSH_DEBUG_SV.log(l_module_name,'LineRecTbl-WDD ID',l_lineRecTbl.delivery_detail_id_tbl(i));
                        WSH_DEBUG_SV.log(l_module_name,'LineRecTbl-WND ID',l_lineRecTbl.delivery_id_tbl(i));
                    END IF;
                    --
                    IF NOT(l_txnUniqueSFLocnFound)
                    OR l_txnUniqueSFLocnId       = WSH_UTIL_CORE.C_NULL_SF_LOCN_ID
                    OR l_lineSFLocnId            = l_txnUniqueSFLocnId
                    OR (    l_lineSFLocnId       = WSH_UTIL_CORE.C_NULL_SF_LOCN_ID
                        AND l_lineUniqueSFLocnId = WSH_UTIL_CORE.C_NULL_SF_LOCN_ID
                       )
                    THEN
                    --{
                        l_end_Index                := l_end_Index + 1;
                        --
                        --
                        IF NOT l_matchedLineRecTbl.match_flag_tab.EXISTS(l_end_Index)
                        THEN
                        --{
                            l_extendBy := l_end_Index - l_matchedLineRecTbl.match_flag_tab.COUNT;
                            --
                            --
                            IF l_debug_on THEN
                                WSH_DEBUG_SV.log(l_module_name,'l_end_Index',l_end_Index);
                                WSH_DEBUG_SV.log(l_module_name,'l_matchedLineRecTbl.match_flag_tab.COUNT',l_matchedLineRecTbl.match_flag_tab.COUNT);
                            END IF;
                            --
                            IF l_extendBy > 0
                            THEN
                            --{
                                --
                                -- Debug Statements
                                --
                                IF l_debug_on THEN
                                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_IB_TXN_MATCH_PKG.EXTENDMATCHEDLINERECTBL',WSH_DEBUG_SV.C_PROC_LEVEL);
                                END IF;
                                --
                                WSH_IB_TXN_MATCH_PKG.extendMatchedLineRecTbl
                                  (
                                    p_extendBy            => l_extendBy,
                                    x_matchedLineRecTbl   => l_matchedLineRecTbl,
                                    x_return_status       => l_return_status
                                  );
                                --
                                --
                                -- Debug Statements
                                --
                                IF l_debug_on THEN
                                    WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
                                END IF;
                                --
                                wsh_util_core.api_post_call
                                  (
                                    p_return_status => l_return_status,
                                    x_num_warnings  => l_num_warnings,
                                    x_num_errors    => l_num_errors
                                  );
                            --}
                            END IF;
                        --}
                        END IF;
                        --
                        --
                        l_matchedLineRecTbl.del_detail_id_tab(l_end_index)          := l_lineRecTbl.delivery_detail_id_tbl(i);
                        --
                        l_matchedLineRecTbl.requested_qty_tab(l_end_index)          := l_lineRecTbl.requested_quantity_tbl(i);
                        l_matchedLineRecTbl.picked_qty_tab(l_end_index)             := l_lineRecTbl.picked_quantity_tbl(i);
                        l_matchedLineRecTbl.shipped_qty_tab(l_end_index)            := l_lineRecTbl.shipped_quantity_tbl(i);
                        l_matchedLineRecTbl.received_qty_tab(l_end_index)           := l_lineRecTbl.received_quantity_tbl(i);
                        l_matchedLineRecTbl.returned_qty_tab(l_end_index)           := l_lineRecTbl.returned_quantity_tbl(i);
                        --
                        l_matchedLineRecTbl.requested_qty2_tab(l_end_index)         := l_lineRecTbl.requested_quantity2_tbl(i);
                        l_matchedLineRecTbl.picked_qty2_tab(l_end_index)            := l_lineRecTbl.picked_quantity2_tbl(i);
                        l_matchedLineRecTbl.shipped_qty2_tab(l_end_index)           := l_lineRecTbl.shipped_quantity2_tbl(i);
                        l_matchedLineRecTbl.received_qty2_tab(l_end_index)          := l_lineRecTbl.received_quantity2_tbl(i);
                        l_matchedLineRecTbl.returned_qty2_tab(l_end_index)          := l_lineRecTbl.returned_quantity2_tbl(i);
                        --
                        l_matchedLineRecTbl.requested_qty_db_tab(l_end_index)       := l_lineRecTbl.requested_quantity_tbl(i);
                        l_matchedLineRecTbl.picked_qty_db_tab(l_end_index)          := l_lineRecTbl.picked_quantity_tbl(i);
                        l_matchedLineRecTbl.shipped_qty_db_tab(l_end_index)         := l_lineRecTbl.shipped_quantity_tbl(i);
                        l_matchedLineRecTbl.received_qty_db_tab(l_end_index)        := l_lineRecTbl.received_quantity_tbl(i);
                        l_matchedLineRecTbl.returned_qty_db_tab(l_end_index)        := l_lineRecTbl.returned_quantity_tbl(i);
                        --
                        l_matchedLineRecTbl.requested_qty2_db_tab(l_end_index)      := l_lineRecTbl.requested_quantity2_tbl(i);
                        l_matchedLineRecTbl.picked_qty2_db_tab(l_end_index)         := l_lineRecTbl.picked_quantity2_tbl(i);
                        l_matchedLineRecTbl.shipped_qty2_db_tab(l_end_index)        := l_lineRecTbl.shipped_quantity2_tbl(i);
                        l_matchedLineRecTbl.received_qty2_db_tab(l_end_index)       := l_lineRecTbl.received_quantity2_tbl(i);
                        l_matchedLineRecTbl.returned_qty2_db_tab(l_end_index)       := l_lineRecTbl.returned_quantity2_tbl(i);
                        --
                        l_matchedLineRecTbl.line_date_tab(l_end_index)              := l_lineRecTbl.earliest_dropoff_date_tbl(i);
                        l_matchedLineRecTbl.ship_from_location_id_tab(l_end_index)  := l_lineRecTbl.ship_from_location_id_tbl(i);
                        l_matchedLineRecTbl.released_status_tab(l_end_index)        := l_lineRecTbl.released_status_tbl(i);
                        l_matchedLineRecTbl.requested_qty_uom_tab(l_end_index)      := l_lineRecTbl.requested_quantity_uom_tbl(i);
                        l_matchedLineRecTbl.requested_qty_uom2_tab(l_end_index)     := l_lineRecTbl.requested_quantity_uom2_tbl(i);
                        --
                        l_matchedLineRecTbl.po_header_id_tab(l_end_index)           := p_line_rec.header_id(l_index);
                        l_matchedLineRecTbl.po_line_location_id_tab(l_end_index)    := l_poShipmentLineId;
                        l_matchedLineRecTbl.po_line_id_tab(l_end_index)             := p_line_rec.line_id(l_index);
                        l_matchedLineRecTbl.delivery_id_tab(l_end_index)            := l_lineRecTbl.delivery_id_tbl(i);
                        l_matchedLineRecTbl.trip_id_tab(l_end_index)                := NULL;
                        --
                        l_matchedLineRecTbl.shipment_line_id_db_tab(l_end_index)    := l_lineRecTbl.rcv_shipment_line_id_tbl(i);
                        l_matchedLineRecTbl.shipment_line_id_tab(l_end_index)       := p_line_rec.shipment_line_id(l_index);
                        l_matchedLineRecTbl.child_index_tab(l_end_index)            := NULL;
                        l_matchedLineRecTbl.shpmt_line_id_idx_tab(l_end_index)      := l_index;
                        --
                        l_matchedLineRecTbl.process_corr_rtv_flag_tab(l_end_index)  := C_NOT_PROCESS_FLAG;
                        l_matchedLineRecTbl.process_asn_rcv_flag_tab(l_end_index)   := C_NOT_PROCESS_FLAG;
                        l_matchedLineRecTbl.match_flag_tab(l_end_index)             := C_NOT_PROCESS_FLAG;
                        l_matchedLineRecTbl.last_update_date_tab(l_end_index)       := l_lineRecTbl.last_update_date_tbl(i);
                        l_matchedLineRecTbl.lineCount_tab(l_end_index)              := l_lineCount;
                        --
                        --

                        IF l_debug_on THEN
                           WSH_DEBUG_SV.log(l_module_name,'Qty:REQ|PICK|SHP|RCV|RTV',
                                                           l_matchedLineRecTbl.requested_qty_tab(l_end_index)
                                                           || '|'
                                                           || l_matchedLineRecTbl.picked_qty_tab(l_end_index)
                                                           || '|'
                                                           || l_matchedLineRecTbl.shipped_qty_tab(l_end_index)
                                                           || '|'
                                                           || l_matchedLineRecTbl.received_qty_tab(l_end_index)
                                                           || '|'
                                                           || l_matchedLineRecTbl.returned_qty_tab(l_end_index)
                                           );
                           WSH_DEBUG_SV.log(l_module_name,'Qty2:REQ|PICK|SHP|RCV|RTV',
                                                           l_matchedLineRecTbl.requested_qty2_tab(l_end_index)
                                                           || '|'
                                                           || l_matchedLineRecTbl.picked_qty2_tab(l_end_index)
                                                           || '|'
                                                           || l_matchedLineRecTbl.shipped_qty2_tab(l_end_index)
                                                           || '|'
                                                           || l_matchedLineRecTbl.received_qty2_tab(l_end_index)
                                                           || '|'
                                                           || l_matchedLineRecTbl.returned_qty2_tab(l_end_index)
                                           );
                           WSH_DEBUG_SV.log(l_module_name,'LineDate|SFLocn|UOM|UOM2|RelSt',
                                                           l_matchedLineRecTbl.line_date_tab(l_end_index)
                                                           || '|'
                                                           || l_matchedLineRecTbl.ship_from_location_id_tab(l_end_index)
                                                           || '|'
                                                           || l_matchedLineRecTbl.requested_qty_uom_tab(l_end_index)
                                                           || '|'
                                                           || l_matchedLineRecTbl.requested_qty_uom2_tab(l_end_index)
                                                           || '|'
                                                           || l_matchedLineRecTbl.released_status_tab(l_end_index)
                                           );
                           WSH_DEBUG_SV.log(l_module_name,'SrcId:Hdr|Line|PLL|RCVSl-DB|RCV-SL-Input',
                                                           l_matchedLineRecTbl.po_header_id_tab(l_end_index)
                                                           || '|'
                                                           || l_matchedLineRecTbl.po_line_id_tab(l_end_index)
                                                           || '|'
                                                           || l_matchedLineRecTbl.po_line_location_id_tab(l_end_index)
                                                           || '|'
                                                           || l_matchedLineRecTbl.shipment_line_id_db_tab(l_end_index)
                                                           || '|'
                                                           || l_matchedLineRecTbl.shipment_line_id_tab(l_end_index)
                                           );
                           WSH_DEBUG_SV.log(l_module_name,'last_update_date', l_matchedLineRecTbl.last_update_date_tab(l_end_index));
                           WSH_DEBUG_SV.log(l_module_name,'lineCount tab', l_matchedLineRecTbl.lineCount_tab(l_end_index));
                        END IF;
                    --}
                    END IF;
                    --
                    --EXIT WHEN l_lineSFLocnId = WSH_UTIL_CORE.C_NULL_SF_LOCN_ID;
                    --
                    --
                    IF  l_transactionType              = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_ADD
                    AND l_receiptShipFromLocationCount = 1
                    AND l_txnUniqueSFLocnId           <> WSH_UTIL_CORE.C_NULL_SF_LOCN_ID
                    THEN
                        l_lineUniqueSFLocnId    := NULL;
                    END IF;
                --}
                END LOOP;
                --
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'l_start_index',l_start_index);
                    WSH_DEBUG_SV.log(l_module_name,'l_end_index',l_end_index);
                    WSH_DEBUG_SV.log(l_module_name,'l_lineUniqueSFLocnFound',l_lineUniqueSFLocnFound);
                    WSH_DEBUG_SV.log(l_module_name,'l_lineUniqueSFLocnId',l_lineUniqueSFLocnId);
                    WSH_DEBUG_SV.log(l_module_name,'l_txnUniqueSFLocnId',l_txnUniqueSFLocnId);
                    WSH_DEBUG_SV.log(l_module_name,'l_txnUniqueSFLocnFound',l_txnUniqueSFLocnFound);
                END IF;
                --
                --
                IF l_end_index    >= l_start_index
                AND l_start_index >  0
                THEN
                --{
                    l_linkRecString     :=  C_NOT_PROCESS_FLAG
                                            || C_SEPARATOR
                                            || l_start_index
                                            || C_SEPARATOR
                                            || l_end_index;
                    --
                    --
                    --
                    -- Debug Statements
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_CACHED_VALUE-l_linkTbl',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    wsh_util_core.get_cached_value
                      (
                        p_cache_tbl         => l_linkTbl,
                        p_cache_ext_tbl     => l_linkExtTbl,
                        p_key               => l_key,   --l_poShipmentLineId,
                        p_value             => l_linkRecString,
                        p_action            => 'PUT',
                        x_return_status     => l_return_status
                      );
                    --
                    --
                    --
                    -- Debug Statements
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    wsh_util_core.api_post_call
                      (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                      );
                --}
                END IF;
                --
                --
                IF  l_lineUniqueSFLocnFound
                THEN
                --{
                    IF  l_transactionType               = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_ADD
                    AND l_receiptShipFromLocationCount  = 1
                    AND l_lineUniqueSFLocnId           <> WSH_UTIL_CORE.C_NULL_SF_LOCN_ID
                    AND l_lineUniqueSFLocnId           <> l_txnUniqueSFLocnId
                    THEN
                        l_messageName := 'WSH_IB_NOT_MATCH_NULL_SF_LOCN';
                        RAISE e_lineNotMatched;
                    END IF;
                    --
                    --
                    IF NOT(l_txnUniqueSFLocnFound)
                    OR l_txnUniqueSFLocnId   = WSH_UTIL_CORE.C_NULL_SF_LOCN_ID
                    THEN
                    --{
                        l_txnUniqueSFLocnFound  := TRUE;
                        -- { IB-Phase-2
			IF l_trx_wsh_location_id IS  NULL
                        THEN
                           l_txnUniqueSFLocnId     := l_lineUniqueSFLocnId;
                        END IF;
			-- } IB-Phase-2
                        --
                        IF  l_txnUniqueSFLocnId  <> WSH_UTIL_CORE.C_NULL_SF_LOCN_ID
                        THEN
                        --{
                            IF NOT(l_resetTxnUniqueSFLocn)
                            THEN
                                l_start_index := l_matchedLineRecTbl.match_flag_tab.FIRST;
                            END IF;
                            --
                            --
                            -- Debug Statements
                            --
                            IF l_debug_on THEN
                                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_LOCATION_DESCRIPTION',WSH_DEBUG_SV.C_PROC_LEVEL);
                            END IF;
                            --
                            l_txnUniqueSFLocnCode := SUBSTRB
                                                      (
                                                        WSH_UTIL_CORE.get_location_description
                                                          (
                                                            l_txnUniqueSFLocnId,
                                                            'NEW UI CODE'
                                                          ),
                                                        1,
                                                        60
                                                      );
                        --}
                        END IF;
                    --}
                    ELSIF l_lineUniqueSFLocnId <> WSH_UTIL_CORE.C_NULL_SF_LOCN_ID
                    AND   l_lineUniqueSFLocnId <> l_txnUniqueSFLocnId
                    THEN
                    --{
                        FND_MESSAGE.SET_NAME('WSH','WSH_IB_NOT_UNIQUE_SF_LOCN');
                        FND_MESSAGE.SET_TOKEN('TRANSACTION_TYPE',l_transactionMeaning); --p_action_prms.action_code);
                        FND_MESSAGE.SET_TOKEN('SHIPMENT_NUM',l_shipmentNumber);
                        FND_MESSAGE.SET_TOKEN('RECEIPT_NUM',l_receiptNumber);
                        wsh_util_core.add_message(wsh_util_core.g_ret_sts_error,l_module_name);
                        RAISE e_notMatched;
                    --}
                    END IF;
                --}
                END IF;
                --
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'l_txnUniqueSFLocnFound',l_txnUniqueSFLocnFound);
                    WSH_DEBUG_SV.log(l_module_name,'l_txnUniqueSFLocnId',l_txnUniqueSFLocnId);
                    WSH_DEBUG_SV.log(l_module_name,'l_txnUniqueSFLocnCode',l_txnUniqueSFLocnCode);
                END IF;
                --
                --
                IF  l_txnUniqueSFLocnFound
                --AND l_txnUniqueSFLocnId  <> WSH_UTIL_CORE.C_NULL_SF_LOCN_ID
                THEN
                --{
                    IF  l_transactionType     = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_ADD
                    OR  l_resetTxnUniqueSFLocn
                    OR  l_txnUniqueSFLocnId  <> WSH_UTIL_CORE.C_NULL_SF_LOCN_ID
                    THEN
                    --{
                        IF l_end_index >= l_start_index
                        THEN
                        --{

                            BEGIN
                            --{
                                --
                                -- Debug Statements
                                --
                                IF l_debug_on THEN
                                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_IB_TXN_MATCH_PKG.MATCHLINES',WSH_DEBUG_SV.C_PROC_LEVEL);
                                END IF;
                                --
                                WSH_IB_TXN_MATCH_PKG.matchLines
                                  (
                                    p_line_rec              => p_line_rec,
                                    p_transactionType       => l_transactionSubType ,
                                    p_transactionMeaning    => l_transactionMeaning,
                                    p_ReceiptAgainstASN     => l_ReceiptAgainstASN,
                                    p_transactionDate       => l_transactionDate,
                                    p_start_index           => l_start_index,
                                    p_end_index             => l_end_index,
                                    p_putMessages           => TRUE,
                                    p_txnUniqueSFLocnId     => l_txnUniqueSFLocnId,
                                    x_matchedLineRecTbl     => l_matchedLineRecTbl,
                                    x_dlvytbl               => l_dlvytbl,
                                    x_dlvyExttbl            => l_dlvyExttbl,
                                    x_min_date              => l_min_date,
                                    x_max_date              => l_max_date,
                                    x_return_status         => l_return_status
                                  );
                                --
                                --
                                --
                                -- Debug Statements
                                --
                                IF l_debug_on THEN
                                    WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
                                END IF;
                                --
                                wsh_util_core.api_post_call
                                  (
                                    p_return_status => l_return_status,
                                    x_num_warnings  => l_num_warnings,
                                    x_num_errors    => l_num_errors
                                  );
                            --}
                            EXCEPTION
                            --{
                                WHEN e_notMatched THEN
                                --{
                                    IF  l_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_ADD
                                    THEN
                                        l_messageName := NULL;
                                        RAISE e_lineNotMatched;
                                    ELSE
                                        RAISE e_notMatched;
                                    END IF;
                                --}
                            --}
                            END;
                        --}
                        ELSE
                        --{
                            IF  l_transactionType     = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_ADD
                            THEN
                                l_messageName := 'WSH_IB_NOT_MATCH_SF_LOCN';
                                RAISE e_lineNotMatched;
                            ELSE
                            --{
                                FND_MESSAGE.SET_NAME('WSH','WSH_IB_NOT_MATCH_SF_LOCN');
                                FND_MESSAGE.SET_TOKEN('TRANSACTION_TYPE',l_transactionMeaning); --p_action_prms.action_code);
                                FND_MESSAGE.SET_TOKEN('SHIPMENT_NUM',l_shipmentNumber);
                                FND_MESSAGE.SET_TOKEN('RECEIPT_NUM',l_receiptNumber);
                                FND_MESSAGE.SET_TOKEN('SHIP_FROM_LOCATION',l_txnUniqueSFLocnCode);
                                FND_MESSAGE.SET_TOKEN('PO_HEADER_NUM',l_poHeaderNumber);
                                FND_MESSAGE.SET_TOKEN('PO_LINE_NUM',l_poLineNumber);
                                FND_MESSAGE.SET_TOKEN('PO_SHIPMENT_LINE_NUM',l_poShipmentLineNumber);
                                FND_MESSAGE.SET_TOKEN('PO_RELEASE_NUM',l_poReleaseNumber);
                                wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
                                --
                                RAISE e_notMatched;
                            --}
                            END IF;
                        --}
                        END IF;
                    --}
                    END IF;
                --}
                END IF;
            --}
            ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS
            THEN
            --{
                IF l_transactionType     = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_ADD
                AND SUBSTRB(l_linkRecString,1,1) = C_ERROR_FLAG
                THEN
                --{
                    l_messageName := NULL;
                    RAISE e_lineNotMatched;
                --}
                END IF;
                --Use link rec string, get the flag. if error then, l_messagename=null and raise e_linenot matched
            --}
            END IF;
            --
            --
            l_minMatchedTransactionId := LEAST(l_minMatchedTransactionId, l_transactionId);
            --
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_minMatchedTransactionId',l_minMatchedTransactionId);
            END IF;
            --
            --
            IF  l_transactionType <> WSH_INBOUND_TXN_HISTORY_PKG.C_ASN
            AND l_transactionType <> WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT
            THEN
            --{
                --
                -- Debug Statements
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_IB_TXN_MATCH_PKG.ADDTRANSACTIONHISTORYRECORD',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                WSH_IB_TXN_MATCH_PKG.addTransactionHistoryRecord
                  (
                    p_transactionType            =>  l_transactionSubType,
                    p_ReceiptAgainstASN          =>  l_ReceiptAgainstASN,
                    p_index                      =>  l_index,
                    p_line_rec                   =>  p_line_rec,
		    p_ship_from_location_id      =>  l_trx_wsh_location_id, -- IB-Phase-2
                    x_inboundTxnHistory_recTbl   =>  l_MatchedTxnHistory_recTbl,
                    x_return_status              =>  l_return_status
                  );
                --
                --
                --
                -- Debug Statements
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                wsh_util_core.api_post_call
                  (
                    p_return_status => l_return_status,
                    x_num_warnings  => l_num_warnings,
                    x_num_errors    => l_num_errors
                  );
            --}
            END IF;
        --}
        EXCEPTION
        --{
            WHEN e_lineNotMatched THEN
            --{
                --ROLLBACK TO matchTransaction_sp;--???no
                --
                IF l_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_ASN
                OR l_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT
                THEN
                --{
                    RAISE e_notMatched;
                --}
                ELSE
                --{
                    l_minFailedTransactionId := LEAST(l_minFailedTransactionId, l_transactionId);
                    --
                    --
                    -- Debug Statements
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name,'l_minFailedTransactionId',l_minFailedTransactionId);
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_IB_TXN_MATCH_PKG.ADDTRANSACTIONHISTORYRECORD',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    WSH_IB_TXN_MATCH_PKG.addTransactionHistoryRecord
                      (
                        p_transactionType            =>  l_transactionSubType,
                        p_ReceiptAgainstASN          =>  l_ReceiptAgainstASN,
                        p_index                      =>  l_index,
                        p_line_rec                   =>  p_line_rec,
   		        p_ship_from_location_id      =>  l_trx_wsh_location_id, ---- IB-Phase-2
                        x_inboundTxnHistory_recTbl   =>  l_FailedTxnHistory_recTbl,
                        x_return_status              =>  l_return_status
                      );
                    --
                    --
                    --
                    -- Debug Statements
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    wsh_util_core.api_post_call
                      (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                      );
                    --
                    --
                    IF l_key IS NOT NULL
                    THEN
                    --{
                        l_linkRecString     :=  C_ERROR_FLAG
                                                || C_SEPARATOR
                                                || l_start_index
                                                || C_SEPARATOR
                                                || l_end_index;
                        --
                        --
                        --
                        -- Debug Statements
                        --
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_CACHED_VALUE-l_linkTbl',WSH_DEBUG_SV.C_PROC_LEVEL);
                        END IF;
                        --
                        wsh_util_core.get_cached_value
                          (
                            p_cache_tbl         => l_linkTbl,
                            p_cache_ext_tbl     => l_linkExtTbl,
                            p_key               => l_key,   --l_poShipmentLineId,
                            p_value             => l_linkRecString,
                            p_action            => 'PUT',
                            x_return_status     => l_return_status
                          );
                        --
                        --
                        --
                        -- Debug Statements
                        --
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
                        END IF;
                        --
                        wsh_util_core.api_post_call
                          (
                            p_return_status => l_return_status,
                            x_num_warnings  => l_num_warnings,
                            x_num_errors    => l_num_errors
                          );
                    --}
                    END IF;
                    --
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name,'l_messageName',l_messageName);
                    END IF;
                    --
                    --
                    IF l_messageName IS NOT NULL
                    THEN
                    --{
                        --FND_MESSAGE.SET_NAME('WSH','WSH_IB_MATCH_LINE_FATAL_ERROR');
                        FND_MESSAGE.SET_NAME('WSH',l_messageName);
                        --
                        FND_MESSAGE.SET_TOKEN('TRANSACTION_TYPE',l_transactionMeaning); --p_action_prms.action_code);
                        FND_MESSAGE.SET_TOKEN('SHIPMENT_NUM',l_shipmentNumber);
                        FND_MESSAGE.SET_TOKEN('RECEIPT_NUM',l_receiptNumber);
                        --
                        IF l_messageName IN (
                                              'WSH_IB_PEND_PARENT_TXN_MATCH',
                                              'WSH_IB_PEND_PARENT_LINE_MATCH',
                                              'WSH_IB_PARNT_LIN_MULT_SF_MATCH',
                                              'WSH_IB_PARENT_MULTI_SF_MATCH',
                                              'WSH_IB_NOT_MATCH_NULL_SF_LOCN',
                                              'WSH_IB_NOT_MATCH_SF_LOCN',
                                              'WSH_IB_INVALID_PO_LINE_ERROR',
                                              'WSH_IB_NOT_MATCH_SHP_LINES'
                                            )
                        THEN
                        --{
                            FND_MESSAGE.SET_TOKEN('PO_HEADER_NUM',l_poHeaderNumber);
                            FND_MESSAGE.SET_TOKEN('PO_LINE_NUM',l_poLineNumber);
                            FND_MESSAGE.SET_TOKEN('PO_SHIPMENT_LINE_NUM',l_poShipmentLineNumber);
                            FND_MESSAGE.SET_TOKEN('PO_RELEASE_NUM',l_poReleaseNumber);
                        --}
                        END IF;
                        --
                        --
                        IF l_messageName = 'WSH_IB_NOT_MATCH_SF_LOCN'
                        THEN
                            FND_MESSAGE.SET_TOKEN('SHIP_FROM_LOCATION',l_txnUniqueSFLocnCode);
                        END IF;
                        --
                        --
                        wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
                        --x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                    --}
                    END IF;
                --}
                END IF;
            --}
        --}
        END;
        --
        --
        IF l_resetTxnUniqueSFLocn
        THEN
        --{
            l_txnUniqueSFLocnFound := FALSE;
            l_txnUniqueSFLocnId    := NULL;
            l_txnUniqueSFLocnCode  := NULL;
        --}
        END IF;
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'End of outer loop');
            WSH_DEBUG_SV.log(l_module_name,'l_txnUniqueSFLocnFound',l_txnUniqueSFLocnFound);
            WSH_DEBUG_SV.log(l_module_name,'l_txnUniqueSFLocnId',l_txnUniqueSFLocnId);
            WSH_DEBUG_SV.log(l_module_name,'l_txnUniqueSFLocnCode',l_txnUniqueSFLocnCode);
        END IF;
        --
        l_index := p_line_rec.shipment_line_id.NEXT(l_index);
    --}
    END LOOP;
    --
    --
    l_maxRCVTransactionId := l_maxTransactionId;
    --
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_maxRCVTransactionId',l_maxRCVTransactionId);
    END IF;
    --
    --
    IF  (
             l_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_ASN
          OR (
                  l_transactionType    = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT
              AND l_ReceiptAgainstASN <> 'Y'
             )
        )
    THEN
    --{
        IF NOT(l_txnUniqueSFLocnFound)
        OR l_txnUniqueSFLocnId   = WSH_UTIL_CORE.C_NULL_SF_LOCN_ID
        THEN
        --{
            l_count := l_linkTbl.COUNT + l_linkExtTbl.COUNT;
            --
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Link Table Total Count',l_count);
            END IF;
            --
            IF l_shipFromLocationIdTbl.COUNT > 0
            OR l_shipFromLocationIdExtTbl.COUNT > 0
            THEN
                l_min_date  := NULL;
                l_max_date  := NULL;
            END IF;
            --
            --
            l_index := l_shipFromLocationIdTbl.FIRST;
            --
            WHILE l_index IS NOT NULL
            LOOP
            --{
                BEGIN
                --{
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name,'SF Locn Id, Count',
                                                        l_shipFromLocationIdTbl(l_index).key
                                                        || ','
                                                        || l_shipFromLocationIdTbl(l_index).value
                                        );
                    END IF;
                    --
                    --
                    IF l_shipFromLocationIdTbl(l_index).value = l_count
                    OR l_txnUniqueSFLocnId   = WSH_UTIL_CORE.C_NULL_SF_LOCN_ID
                    THEN
                    --{
                        l_dummy_min_date  := NULL;
                        l_dummy_max_date  := NULL;
                        --
                        --
                        -- Debug Statements
                        --
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_IB_TXN_MATCH_PKG.MATCHLINES',WSH_DEBUG_SV.C_PROC_LEVEL);
                        END IF;
                        --
                        WSH_IB_TXN_MATCH_PKG.matchLines
                          (
                            p_line_rec              => p_line_rec,
                            p_transactionType       => l_transactionSubType ,
                            p_transactionMeaning    => l_transactionMeaning,
                            p_ReceiptAgainstASN     => l_ReceiptAgainstASN,
                            p_transactionDate       => l_transactionDate,
                            p_start_index           => l_matchedLineRecTbl.match_flag_tab.FIRST,
                            p_end_index             => l_matchedLineRecTbl.match_flag_tab.LAST,
                            p_putMessages           => FALSE,
                            p_txnUniqueSFLocnId     => l_shipFromLocationIdTbl(l_index).key,
                            x_matchedLineRecTbl     => l_matchedLineRecTbl,
                            x_dlvytbl               => l_dlvytbl,
                            x_dlvyExttbl            => l_dlvyExttbl,
                            x_min_date              => l_dummy_min_date,
                            x_max_date              => l_dummy_max_date,
                            x_return_status         => l_return_status
                          );
                        --
                        --
                        --
                        -- Debug Statements
                        --
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
                        END IF;
                        --
                        wsh_util_core.api_post_call
                          (
                            p_return_status => l_return_status,
                            x_num_warnings  => l_num_warnings,
                            x_num_errors    => l_num_errors
                          );
                        --
                        --
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,'Adding to l_uniqueShipFromLocationIdTbl');
                        END IF;
                        --
                        --
                        l_uniqueShipFromLocationIdTbl(l_uniqueShipFromLocationIdTbl.COUNT+1)
                        := l_shipFromLocationIdTbl(l_index).key;
                        --
                        --
                        l_min_date  := NVL(l_min_date,l_dummy_min_date);
                        l_max_date  := NVL(l_max_date,l_dummy_max_date);
                        --
                        --
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.log(l_module_name,'l_min_date',l_min_date);
                            WSH_DEBUG_SV.log(l_module_name,'l_max_date',l_max_date);
                        END IF;
                        --
                        --
                    --}
                    END IF;
                --}
                EXCEPTION
                    WHEN e_notMatched THEN
                      NULL;
                END;
                --
                l_index := l_shipFromLocationIdTbl.NEXT(l_index);
            --}
            END LOOP;
            --
            --
            l_index := l_shipFromLocationIdExtTbl.FIRST;
            --
            WHILE l_index IS NOT NULL
            LOOP
            --{
                BEGIN
                --{

                    IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name,'SF Locn Id, Count',
                                                        l_shipFromLocationIdExtTbl(l_index).key
                                                        || ','
                                                        || l_shipFromLocationIdExtTbl(l_index).value
                                        );
                    END IF;
                    --
                    --
                    IF l_shipFromLocationIdExtTbl(l_index).value = l_count
                    OR l_txnUniqueSFLocnId   = WSH_UTIL_CORE.C_NULL_SF_LOCN_ID
                    THEN
                    --{
                        l_dummy_min_date  := NULL;
                        l_dummy_max_date  := NULL;
                        --
                        --
                        -- Debug Statements
                        --
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_IB_TXN_MATCH_PKG.MATCHLINES',WSH_DEBUG_SV.C_PROC_LEVEL);
                        END IF;
                        --
                        WSH_IB_TXN_MATCH_PKG.matchLines
                          (
                            p_line_rec              => p_line_rec,
                            p_transactionType       => l_transactionSubType ,
                            p_transactionMeaning    => l_transactionMeaning,
                            p_ReceiptAgainstASN     => l_ReceiptAgainstASN,
                            p_transactionDate       => l_transactionDate,
                            p_start_index           => l_matchedLineRecTbl.match_flag_tab.FIRST,
                            p_end_index             => l_matchedLineRecTbl.match_flag_tab.LAST,
                            p_putMessages           => FALSE,
                            p_txnUniqueSFLocnId     => l_shipFromLocationIdExtTbl(l_index).key,
                            x_matchedLineRecTbl     => l_matchedLineRecTbl,
                            x_dlvytbl               => l_dlvytbl,
                            x_dlvyExttbl            => l_dlvyExttbl,
                            x_min_date              => l_dummy_min_date,
                            x_max_date              => l_dummy_max_date,
                            x_return_status         => l_return_status
                          );
                        --
                        --
                        --
                        -- Debug Statements
                        --
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
                        END IF;
                        --
                        wsh_util_core.api_post_call
                          (
                            p_return_status => l_return_status,
                            x_num_warnings  => l_num_warnings,
                            x_num_errors    => l_num_errors
                          );
                        --
                        --
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,'Adding to l_uniqueShipFromLocationIdTbl');
                        END IF;
                        --
                        --
                        l_uniqueShipFromLocationIdTbl(l_uniqueShipFromLocationIdTbl.COUNT+1)
                        := l_shipFromLocationIdExtTbl(l_index).key;
                        --
                        --
                        l_min_date  := NVL(l_min_date,l_dummy_min_date);
                        l_max_date  := NVL(l_max_date,l_dummy_max_date);
                        --
                        --
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.log(l_module_name,'l_min_date',l_min_date);
                            WSH_DEBUG_SV.log(l_module_name,'l_max_date',l_max_date);
                        END IF;
                        --
                        --
                    --}
                    END IF;
                --}
                EXCEPTION
                    WHEN e_notMatched THEN
                      NULL;
                END;
                --
                l_index := l_shipFromLocationIdExtTbl.NEXT(l_index);
            --}
            END LOOP;
            --
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_uniqueShipFromLocationIdTbl.COUNT',l_uniqueShipFromLocationIdTbl.COUNT);
            END IF;
            --
            --
            IF l_uniqueShipFromLocationIdTbl.COUNT = 1
            THEN
            --{
	        -- { IB-Phase-2
                IF l_trx_wsh_location_id IS NULL
                THEN --
                   l_txnUniqueSFLocnId     := l_uniqueShipFromLocationIdTbl(l_uniqueShipFromLocationIdTbl.FIRST);
                END IF;
                l_txnUniqueSFLocnFound  := TRUE;
		-- } IB-Phase-2
            --}
            ELSIF NOT(l_txnUniqueSFLocnFound)
            THEN
            --{
                FND_MESSAGE.SET_NAME('WSH','WSH_IB_NOT_UNIQUE_SF_LOCN');
                FND_MESSAGE.SET_TOKEN('TRANSACTION_TYPE',l_transactionMeaning); --p_action_prms.action_code);
                FND_MESSAGE.SET_TOKEN('SHIPMENT_NUM',l_shipmentNumber);
                FND_MESSAGE.SET_TOKEN('RECEIPT_NUM',l_receiptNumber);
                wsh_util_core.add_message(wsh_util_core.g_ret_sts_error,l_module_name);
                RAISE e_notMatched;
            --}
            END IF;
        --}
        END IF;
        --
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_txnUniqueSFLocnFound',l_txnUniqueSFLocnFound);
            WSH_DEBUG_SV.log(l_module_name,'l_txnUniqueSFLocnId',l_txnUniqueSFLocnId);
        END IF;
        --
        --
        IF  l_txnUniqueSFLocnFound
        AND l_txnUniqueSFLocnId   = WSH_UTIL_CORE.C_NULL_SF_LOCN_ID
        THEN
        --{
            l_min_date  := NULL;
            l_max_date  := NULL;
            --
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_IB_TXN_MATCH_PKG.MATCHLINES',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_IB_TXN_MATCH_PKG.matchLines
              (
                p_line_rec              => p_line_rec,
                p_transactionType       => l_transactionSubType ,
                p_transactionMeaning    => l_transactionMeaning,
                p_ReceiptAgainstASN     => l_ReceiptAgainstASN,
                p_transactionDate       => l_transactionDate,
                p_start_index           => l_matchedLineRecTbl.match_flag_tab.FIRST,
                p_end_index             => l_matchedLineRecTbl.match_flag_tab.LAST,
                p_putMessages           => TRUE,
                p_txnUniqueSFLocnId     => l_txnUniqueSFLocnId,
                x_matchedLineRecTbl     => l_matchedLineRecTbl,
                x_dlvytbl               => l_dlvytbl,
                x_dlvyExttbl            => l_dlvyExttbl,
                x_min_date              => l_min_date,
                x_max_date              => l_max_date,
                x_return_status         => l_return_status
              );
            --
            --
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            wsh_util_core.api_post_call
              (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors
              );
        --}
        END IF;
        --
        --
        IF NOT(l_txnUniqueSFLocnFound)
        THEN
        --{
            FND_MESSAGE.SET_NAME('WSH','WSH_IB_NOT_UNIQUE_SF_LOCN');
            FND_MESSAGE.SET_TOKEN('TRANSACTION_TYPE',l_transactionMeaning); --p_action_prms.action_code);
            FND_MESSAGE.SET_TOKEN('SHIPMENT_NUM',l_shipmentNumber);
            FND_MESSAGE.SET_TOKEN('RECEIPT_NUM',l_receiptNumber);
            wsh_util_core.add_message(wsh_util_core.g_ret_sts_error,l_module_name);
            RAISE e_notMatched;
        --}
        END IF;
    --}
    END IF;
    --
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_FailedTxnHistory_recTbl.shipment_header_id.COUNT',l_FailedTxnHistory_recTbl.shipment_header_id.COUNT);
        WSH_DEBUG_SV.log(l_module_name,'l_MatchedTxnHistory_recTbl.shipment_header_id.COUNT',l_MatchedTxnHistory_recTbl.shipment_header_id.COUNT);
    END IF;
    --
    IF  l_FailedTxnHistory_recTbl.shipment_header_id.COUNT > 0
    AND l_transactionType <> WSH_INBOUND_TXN_HISTORY_PKG.C_ASN
    AND l_transactionType <> WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT
    THEN
    --{
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_TXN_HISTORY_PKG.autonomous_Create_bulk',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        WSH_INBOUND_TXN_HISTORY_PKG.autonomous_Create_bulk
          (
            x_inboundTxnHistory_recTbl => l_FailedTxnHistory_recTbl,
            x_return_status            => l_return_status
          );
        --
        --
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.api_post_call
          (
            p_return_status => l_return_status,
            x_num_warnings  => l_num_warnings,
            x_num_errors    => l_num_errors
          );
    --}
    END IF;
    --
    --
    IF  l_MatchedTxnHistory_recTbl.shipment_header_id.COUNT = 0
    AND l_transactionType <> WSH_INBOUND_TXN_HISTORY_PKG.C_ASN
    AND l_transactionType <> WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT
    THEN
        RAISE e_notMatched;
    END IF;
    --
    --
    BEGIN
    --{
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_IB_TXN_MATCH_PKG.MATCHQUANTITY',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        WSH_IB_TXN_MATCH_PKG.matchQuantity
          (
            p_line_rec           => p_line_rec,
            p_transactionType    => l_transactionType, --l_transactionSubType ,
            p_transactionMeaning => l_transactionMeaning,
            p_ReceiptAgainstASN  => l_ReceiptAgainstASN,
            p_transactionDate    => l_transactionDate,
            p_txnUniqueSFLocnId  => l_txnUniqueSFLocnId,
            p_start_index        => p_line_rec.line_id.FIRST,
            p_end_index          => p_line_rec.line_id.LAST,
            p_min_date           => l_min_date,
            p_max_date           => l_max_date,
            x_matchedLineRecTbl  => l_matchedLineRecTbl,
            x_linktbl            => l_linktbl,
            x_linkExttbl         => l_linkExttbl,
            x_return_status      => l_return_status
          );
        --
        --
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.api_post_call
          (
            p_return_status => l_return_status,
            x_num_warnings  => l_num_warnings,
            x_num_errors    => l_num_errors
          );
        --
        l_actionCode := l_transactionType; --l_transactionSubType;
        --
        IF l_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_ADD
        THEN
            l_actionCode := WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT;
        END IF;
        --
        l_matchedLineRecTbl.transaction_type       := l_actionCode;
        l_matchedLineRecTbl.shipment_header_id     := l_RCVShipmentHeaderId;
        l_matchedLineRecTbl.max_transaction_id     := l_maxRCVTransactionId;
        l_matchedLineRecTbl.object_version_number  := l_headerObjectVersionNumber;
        --
        l_caller                    := 'WSH_IB_MATCH';
        l_action_prms1.action_code  := l_actionCode;
        l_action_prms1.caller       := l_caller;
        l_action_prms2.action_code  := l_actionCode;
        l_action_prms2.caller       := l_caller;
        --
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_caller',l_caller);
            WSH_DEBUG_SV.log(l_module_name,'l_actionCode',l_actionCode);
        END IF;
        --
        --
        IF l_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_ASN
        OR l_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT
        OR l_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_ADD
        THEN
        --{
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ASN_RECEIPT_PVT.PROCESS_MATCHED_TXNS',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_ASN_RECEIPT_PVT.Process_Matched_Txns
              (
                p_dd_rec              => l_matchedLineRecTbl,
                p_line_rec            => p_line_rec,
                p_action_prms         => l_action_prms1,
                p_shipment_header_id  => l_RCVShipmentHeaderId,
                p_max_txn_id          => l_maxRCVTransactionId,
                x_po_cancel_rec       => l_po_cancel_rec,
                x_po_close_rec        => l_po_close_rec,
                x_return_status       => l_return_status
              );
            --
            --
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            wsh_util_core.api_post_call
              (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors
              );
            --
            --
            IF l_transactionType <> WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_ADD
            THEN
                l_headerStatus := WSH_INBOUND_TXN_HISTORY_PKG.C_MATCHED;
            END IF;
        --}
        ELSE
        --{
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_RCV_CORR_RTV_TXN_PKG.PROCESS_CORRECTIONS_AND_RTV',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_RCV_CORR_RTV_TXN_PKG.process_corrections_and_rtv
              (
                p_rtv_corr_in_rec     => p_line_rec,
                p_matched_detail_rec  => l_matchedLineRecTbl,
                p_action_prms         => l_action_prms2,
                p_rtv_corr_out_rec    => l_rtv_corr_out_rec,
                x_po_cancel_rec       => l_po_cancel_rec,
                x_po_close_rec        => l_po_close_rec,
                x_msg_data            => l_msg_data,
                x_msg_count           => l_msg_count,
                x_return_status       => l_return_status
              );
            --
            --
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            wsh_util_core.api_post_call
              (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors,
                p_msg_data      => l_msg_data
              );
        --}
        END IF;
        --
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'UPDATE WSH_INBOUND_TXN_HISTORY');
            WSH_DEBUG_SV.log(l_module_name,'l_headerStatus',l_headerStatus);
            WSH_DEBUG_SV.log(l_module_name,'l_maxRCVTransactionId',l_maxRCVTransactionId);
            WSH_DEBUG_SV.log(l_module_name,'l_headerTransactionId',l_headerTransactionId);
        END IF;
        --
        --
        UPDATE WSH_INBOUND_TXN_HISTORY
        SET    STATUS                  = l_headerStatus,
               OBJECT_VERSION_NUMBER   = NVL(OBJECT_VERSION_NUMBER,0) + 1,
               MAX_RCV_TRANSACTION_ID  = l_maxRCVTransactionId,
               SHIPMENT_NUMBER         = l_shipmentNumber,
               RECEIPT_NUMBER          = l_receiptNumber,
               LAST_UPDATE_DATE        = SYSDATE,
               LAST_UPDATED_BY         = FND_GLOBAL.USER_ID,
               LAST_UPDATE_LOGIN       = FND_GLOBAL.LOGIN_ID
        WHERE  TRANSACTION_ID          = l_headerTransactionId;
        --
        IF SQL%ROWCOUNT = 0
        THEN
            FND_MESSAGE.SET_NAME('WSH','WSH_IB_TXN_UPDATE_ERROR');
            FND_MESSAGE.SET_TOKEN('TRANSACTION_ID',l_headerTransactionId);
            wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        --
        --
        IF  l_transactionType   = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT
        AND l_receiptAgainstASN = 'Y'
        THEN
        --{
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'UPDATE WSH_INBOUND_TXN_HISTORY-ASN');
                WSH_DEBUG_SV.log(l_module_name,'l_parentTxnHistoryRec.transaction_id',l_parentTxnHistoryRec.transaction_id);
            END IF;
            --
            --
            UPDATE WSH_INBOUND_TXN_HISTORY
            SET    OBJECT_VERSION_NUMBER   = NVL(OBJECT_VERSION_NUMBER,0) + 1,
                   SHIPMENT_NUMBER         = l_shipmentNumber,
                   RECEIPT_NUMBER          = l_receiptNumber,
                   LAST_UPDATE_DATE        = SYSDATE,
                   LAST_UPDATED_BY         = FND_GLOBAL.USER_ID,
                   LAST_UPDATE_LOGIN       = FND_GLOBAL.LOGIN_ID
            WHERE  TRANSACTION_ID          = l_parentTxnHistoryRec.transaction_id;
            --
            IF SQL%ROWCOUNT = 0
            THEN
                FND_MESSAGE.SET_NAME('WSH','WSH_IB_TXN_UPDATE_ERROR');
                FND_MESSAGE.SET_TOKEN('TRANSACTION_ID',l_parentTxnHistoryRec.transaction_id);
                wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
                RAISE FND_API.G_EXC_ERROR;
            END IF;
        --}
        END IF;
        --
        --
        IF (
               l_po_cancel_rec.line_id.COUNT > 0
            OR l_po_close_rec.line_id.COUNT > 0
           )
        AND p_action_prms.ib_txn_history_id IS NULL
        THEN
        --{
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ASN_RECEIPT_PVT.cancel_close_pending_txns',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
           WSH_ASN_RECEIPT_PVT.cancel_close_pending_txns
              (
                p_po_cancel_rec       => l_po_cancel_rec,
                p_po_close_rec        => l_po_close_rec,
                x_return_status       => l_return_status
              );
           --
           --
           IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           --
           wsh_util_core.api_post_call
              (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors
              );
        --}
        END IF;
        --
        --
        /* Code moved outside this nested block
        --
        IF  l_FailedTxnHistory_recTbl.shipment_header_id.COUNT > 0
        AND l_transactionType <> WSH_INBOUND_TXN_HISTORY_PKG.C_ASN
        AND l_transactionType <> WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT
        THEN
            l_minMatchedTransactionId := 1E38;
            RAISE e_notMatched;
        ELSE
            RAISE e_endOfAPI;
        END IF;
        --
        */
    --}
    EXCEPTION
    --{
        WHEN FND_API.G_EXC_ERROR
        OR   FND_API.G_EXC_UNEXPECTED_ERROR
        OR   e_NotMatched
        THEN
        --{
            IF  l_MatchedTxnHistory_recTbl.shipment_header_id.COUNT > 0
            AND l_transactionType <> WSH_INBOUND_TXN_HISTORY_PKG.C_ASN
            AND l_transactionType <> WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT
            THEN
            --{
                --
                -- Debug Statements
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_TXN_HISTORY_PKG.autonomous_Create_bulk',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                WSH_INBOUND_TXN_HISTORY_PKG.autonomous_Create_bulk
                  (
                    x_inboundTxnHistory_recTbl => l_MatchedTxnHistory_recTbl,
                    x_return_status            => l_return_status
                  );
                --
                --
                --
                -- Debug Statements
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                wsh_util_core.api_post_call
                  (
                    p_return_status => l_return_status,
                    x_num_warnings  => l_num_warnings,
                    x_num_errors    => l_num_errors
                  );
            --}
            END IF;
            --
            --
            RAISE e_notMatched;
        --}
    --}
    END;
    --
    IF  l_FailedTxnHistory_recTbl.shipment_header_id.COUNT > 0
    AND l_transactionType <> WSH_INBOUND_TXN_HISTORY_PKG.C_ASN
    AND l_transactionType <> WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT
    THEN
        l_minMatchedTransactionId := 1E38;
        RAISE e_notMatched;
    ELSE
        RAISE e_endOfAPI;
    END IF;
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
   END IF;
--}
EXCEPTION
--{
    WHEN e_endOfAPI THEN
    --{
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
    --}
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'E_ENDOFAPI exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:E_ENDOFAPI');
    END IF;
    --
    WHEN e_notMatched THEN
    --{
        IF  l_MatchedTxnHistory_recTbl.shipment_header_id.COUNT = 0
        THEN
            ROLLBACK TO matchTransaction_sp;
        END IF;
        --
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_IB_TXN_MATCH_PKG.HANDLEMATCHFAILURE',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        WSH_IB_TXN_MATCH_PKG.handleMatchFailure
            (
              p_transactionType            => l_transactionType, --l_transactionSubType,
              p_transactionMeaning         => l_transactionMeaning,
              p_ReceiptAgainstASN          => l_ReceiptAgainstASN,
              p_minFailedTransactionId     => l_minFailedTransactionId,
              p_minMatchedTransactionId    => l_minMatchedTransactionId,
              p_maxRCVTransactionId        => l_maxRCVTransactionId,
              p_headerTransactionId        => l_headerTransactionId,
              p_headerObjectVersionNumber  => l_headerObjectVersionNumber,
              p_headerStatus               => l_headerStatus,
              p_messageStartIndex          => l_messageStartIndex,
              p_RCVShipmentHeaderId        => l_RCVShipmentHeaderId,
              p_shipmentNumber             => l_shipmentNumber,
              p_receiptNumber              => l_receiptNumber,
              x_return_status              => l_return_status
            );
        --
        x_return_status := l_return_status;
    --}
    /*---We do not need this

    WHEN e_fatalError THEN
      ROLLBACK TO matchTransaction_sp;
      --
      FND_MESSAGE.SET_NAME('WSH','WSH_IB_MATCH_FATAL_ERROR');
      FND_MESSAGE.SET_TOKEN('TRANSACTION_CODE',p_action_prms.action_code);
      FND_MESSAGE.SET_TOKEN('SHIPMENT_NUM',l_shipmentNumber);
      FND_MESSAGE.SET_TOKEN('RECEIPT_NUM',l_receiptNumber);
      wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    */
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
        WSH_DEBUG_SV.logmsg(l_module_name,'E_NOTMATCHED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:E_NOTMATCHED');
    END IF;
    --
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO matchTransaction_sp;
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
      ROLLBACK TO matchTransaction_sp;
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
      --ROLLBACK TO matchTransaction_sp;
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
      ROLLBACK TO matchTransaction_sp;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_IB_TXN_MATCH_PKG.matchTransaction');
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
--}
END matchTransaction;

PROCEDURE processPriorReceipts
            (
              p_shipmentHeaderId    IN            NUMBER,
              p_transactionType     IN            VARCHAR2,
              p_MAtransactionType   IN            VARCHAR2,
              p_inboundTxnHistoryId IN            NUMBER,
              p_maxRcvTxnId         IN            NUMBER,
              p_poHeaderId          IN            NUMBER,
	      p_hzShipFromLocationId IN           NUMBER, -- IB-Phase-2
              x_return_status       OUT   NOCOPY  VARCHAR2
            )
IS
--{
   l_shpmt_lines_out_rec WSH_IB_SHPMT_LINE_REC_TYPE;
   l_line_rec            OE_WSH_BULK_GRP.Line_rec_type;
   l_action_prms         WSH_BULK_TYPES_GRP.action_parameters_rectype;
   l_rslId_cache_tbl     WSH_UTIL_CORE.key_value_tab_type;
   l_rslId_cache_ext_tbl WSH_UTIL_CORE.key_value_tab_type;
   --
   l_poHeaderId          NUMBER;
   l_poShipmentLineId    NUMBER;
   l_rcvShipmentLineId   NUMBER;
   l_max_rcv_txn_id      NUMBER;
   l_index               NUMBER;
   l_lineRecIndex        NUMBER;
   l_processRTVFlag      BOOLEAN := FALSE;
   --
   l_return_status      VARCHAR2(1);
   l_num_errors         NUMBER := 0;
   l_num_warnings       NUMBER := 0;
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(32767);
   --
   l_debug_on           BOOLEAN;
   --
   l_module_name     CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PROCESSPRIORRECEIPTS';
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
        WSH_DEBUG_SV.log(l_module_name,'p_shipmentHeaderId',p_shipmentHeaderId);
        WSH_DEBUG_SV.log(l_module_name,'p_transactionType',p_transactionType);
        WSH_DEBUG_SV.log(l_module_name,'p_MAtransactionType',p_MAtransactionType);
        WSH_DEBUG_SV.log(l_module_name,'p_inboundTxnHistoryId',p_inboundTxnHistoryId);
        WSH_DEBUG_SV.log(l_module_name,'p_maxRcvTxnId',p_maxRcvTxnId);
        WSH_DEBUG_SV.log(l_module_name,'p_poHeaderId',p_poHeaderId);
    END IF;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_IB_UI_RECON_GRP.get_shipment_lines',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    WSH_IB_UI_RECON_GRP.get_shipment_lines
      (
        p_api_version_number    => 1.0  ,
        p_init_msg_list         => FND_API.G_FALSE       ,
        p_commit                => FND_API.G_FALSE              ,
        p_shipment_header_id    => p_shipmentHeaderId  ,
        p_transaction_type      => p_transactionType    ,
        p_view_only_flag        => 'Y'      ,
        x_shpmt_lines_out_rec   => l_shpmt_lines_out_rec ,
        x_max_rcv_txn_id        => l_max_rcv_txn_id      ,
        x_msg_count             => l_msg_count           ,
        x_msg_data              => l_msg_data            ,
        x_return_status         => l_return_status
      );
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    wsh_util_core.api_post_call
      (
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors,
        p_msg_data         => l_msg_data
      );
    --
    --
    l_index := l_shpmt_lines_out_rec.shipment_line_id_tab.FIRST;
    --
    WHILE l_index IS NOT NULL
    LOOP
    --{
        IF l_debug_on
        THEN
            WSH_DEBUG_SV.log(l_module_name,'l_index',l_index);
        END IF;
        --
        --
        l_poShipmentLineId      := l_shpmt_lines_out_rec.po_line_location_id_tab(l_index);
        l_poHeaderId            := l_shpmt_lines_out_rec.po_header_id_tab(l_index);
        l_rcvShipmentLineId     := l_shpmt_lines_out_rec.shipment_line_id_tab(l_index);
        --
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_poShipmentLineId',l_poShipmentLineId);
            WSH_DEBUG_SV.log(l_module_name,'l_poHeaderId',l_poHeaderId);
            WSH_DEBUG_SV.log(l_module_name,'l_rcvShipmentLineId',l_rcvShipmentLineId);
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_UTIL_PKG.get_po_rcv_attributess',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        --
        IF l_poHeaderId = p_poHeaderId
        THEN
        --{
        WSH_INBOUND_UTIL_PKG.get_po_rcv_attributes
          (
            p_po_line_location_id   => l_poShipmentLineId,
            p_rcv_shipment_line_id  => l_rcvShipmentLineId,
            x_line_rec              => l_line_rec,
            x_return_status         => l_return_status
          );
        --
        --
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
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
        l_lineRecIndex := l_line_rec.shipment_line_id.LAST;
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_lineRecIndex',l_lineRecIndex);
        END IF;
        --
        --
        l_line_rec.received_quantity_uom.EXTEND;
        l_line_rec.received_quantity2_uom.EXTEND;
        l_line_rec.rcv_transaction_id.EXTEND;
        --
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.get_cached_value-l_rslId_cache_tbl',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        WSH_UTIL_CORE.get_cached_value
          (
            p_cache_tbl       => l_rslId_cache_tbl,
            p_cache_ext_tbl   => l_rslId_cache_ext_tbl,
            p_action          => 'PUT',
            p_key             => l_index,
            p_value           => l_lineRecIndex,
            x_return_status   => l_return_status
          );
        --
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
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
        IF p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_ASN
        THEN
        --{
            l_line_rec.received_quantity(l_lineRecIndex)      := l_shpmt_lines_out_rec.primary_qty_shipped_tab(l_index);
            l_line_rec.received_quantity_uom(l_lineRecIndex)  := l_shpmt_lines_out_rec.primary_uom_code_tab(l_index);
            l_line_rec.received_quantity2(l_lineRecIndex)     := l_shpmt_lines_out_rec.secondary_qty_shipped_tab(l_index);
            l_line_rec.received_quantity2_uom(l_lineRecIndex) := l_shpmt_lines_out_rec.secondary_uom_code_tab(l_index);
            l_line_rec.rcv_transaction_id(l_lineRecIndex)     := l_shpmt_lines_out_rec.max_txn_id_tab(l_index);
        --}
        ELSE --IF p_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT
        --{
            l_line_rec.received_quantity(l_lineRecIndex)      := l_shpmt_lines_out_rec.primary_qty_received_tab(l_index);
            l_line_rec.received_quantity_uom(l_lineRecIndex)  := l_shpmt_lines_out_rec.primary_uom_code_tab(l_index);
            l_line_rec.received_quantity2(l_lineRecIndex)     := l_shpmt_lines_out_rec.secondary_qty_received_tab(l_index);
            l_line_rec.received_quantity2_uom(l_lineRecIndex) := l_shpmt_lines_out_rec.secondary_uom_code_tab(l_index);
            l_line_rec.rcv_transaction_id(l_lineRecIndex)     := NVL(l_shpmt_lines_out_rec.max_txn_id_tab(l_index),p_maxRcvTxnId);
            --
            IF  NOT(l_processRTVFlag)
            AND l_shpmt_lines_out_rec.primary_qty_returned_tab(l_index) > 0
            THEN
            --{
                l_processRTVFlag := TRUE;
            --}
            END IF;
        --}
        END IF;
        --}
        END IF;
        --
        l_index := l_shpmt_lines_out_rec.shipment_line_id_tab.NEXT(l_index);
    --}
    END LOOP;
    --
    --
    l_action_prms.action_code       := p_MAtransactionType;
    l_action_prms.caller            := 'WSH_IB_PO_INTG_PRIOR_RECEIPT';
    l_action_prms.ib_txn_history_id := p_inboundTxnHistoryId;
    l_action_prms.ship_from_location_id := p_hzShipFromLocationId; --IB-Phase-2
    --
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_processRTVFlag',l_processRTVFlag);
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_IB_TXN_MATCH_PKG.matchTransaction',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    WSH_IB_TXN_MATCH_PKG.matchTransaction
      (
        p_action_prms     => l_action_prms,
        p_line_rec        => l_line_rec,
        x_return_status   => l_return_status
      );
    --
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
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
    IF l_processRTVFlag
    THEN
    --{
        IF l_debug_on
        THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Processing RTV');
        END IF;
        --
        l_index := l_shpmt_lines_out_rec.shipment_line_id_tab.FIRST;
        --
        WHILE l_index IS NOT NULL
        LOOP
        --{
            l_poHeaderId            := l_shpmt_lines_out_rec.po_header_id_tab(l_index);
												--
												--
            IF l_debug_on
            THEN
                WSH_DEBUG_SV.log(l_module_name,'l_index',l_index);
                WSH_DEBUG_SV.log(l_module_name,'l_poHeaderId',l_poHeaderId);
            END IF;
            --
            --
            IF l_poHeaderId = p_poHeaderId
            THEN
            --{
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.get_cached_value-l_rslId_cache_tbl',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_UTIL_CORE.get_cached_value
              (
                p_cache_tbl       => l_rslId_cache_tbl,
                p_cache_ext_tbl   => l_rslId_cache_ext_tbl,
                p_action          => 'GET',
                p_key             => l_index,
                p_value           => l_lineRecIndex,
                x_return_status   => l_return_status
              );
            --
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
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
            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING
            THEN
               IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Entry not found in l_rslId_cache');
               END IF;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
            --
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_lineRecIndex',l_lineRecIndex);
            END IF;
            --
            --
            l_line_rec.received_quantity_uom(l_lineRecIndex)  := l_shpmt_lines_out_rec.primary_uom_code_tab(l_index);
            l_line_rec.received_quantity2_uom(l_lineRecIndex) := l_shpmt_lines_out_rec.secondary_uom_code_tab(l_index);
            l_line_rec.rcv_transaction_id(l_lineRecIndex)     := NVL(l_shpmt_lines_out_rec.max_txn_id_tab(l_index),p_maxRcvTxnId);
            --
            IF l_shpmt_lines_out_rec.primary_qty_returned_tab(l_index) > 0
            THEN
                l_line_rec.received_quantity(l_lineRecIndex)      := l_shpmt_lines_out_rec.primary_qty_returned_tab(l_index);
                l_line_rec.received_quantity2(l_lineRecIndex)     := l_shpmt_lines_out_rec.secondary_qty_returned_tab(l_index);
            ELSE
                l_line_rec.received_quantity(l_lineRecIndex)      := 0;
                l_line_rec.received_quantity2(l_lineRecIndex)     := 0;
            END IF;
            --
            --}
            END IF;
												--
            l_index := l_shpmt_lines_out_rec.shipment_line_id_tab.NEXT(l_index);
        --}
        END LOOP;
        --
        --
        l_action_prms.action_code       := WSH_INBOUND_TXN_HISTORY_PKG.C_RTV;
        l_action_prms.ib_txn_history_id := p_inboundTxnHistoryId;
        l_action_prms.caller            := 'WSH_IB_PO_INTG_PRIOR_RECEIPT';
	l_action_prms.ship_from_location_id := p_hzShipFromLocationId; --IB-Phase-2
        --
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_IB_TXN_MATCH_PKG.matchTransaction',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        WSH_IB_TXN_MATCH_PKG.matchTransaction
          (
            p_action_prms     => l_action_prms,
            p_line_rec        => l_line_rec,
            x_return_status   => l_return_status
          );
        --
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
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
    -- Debug Statements
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
--}
EXCEPTION
--{
    WHEN FND_API.G_EXC_ERROR THEN
      --ROLLBACK TO matchTransaction_sp;
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
      --ROLLBACK TO matchTransaction_sp;
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
      --ROLLBACK TO matchTransaction_sp;
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
      --ROLLBACK TO matchTransaction_sp;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_IB_TXN_MATCH_PKG.processPriorReceipts');
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
--}
END processPriorReceipts;

PROCEDURE handlePriorReceipts
            (
              p_action_prms      IN             WSH_BULK_TYPES_GRP.action_parameters_rectype,
              x_line_rec         IN  OUT NOCOPY OE_WSH_BULK_GRP.Line_rec_type,
              x_return_status    OUT     NOCOPY VARCHAR2
            )
IS
--{
   -- bug 5639624
   -- Added po_release_id condition to the cursor
   CURSOR rcv_headers_csr (p_po_header_id NUMBER, p_po_release_id NUMBER)
   IS
      SELECT  rsl.shipment_header_id,
              WSH_INBOUND_TXN_HISTORY_PKG.C_ASN txn_type,
              sum(nvl(DECODE(rsh.asn_type,'ASN',quantity_shipped,'ASBN',quantity_shipped,0),0)) shp_rcv_qty,
              1 max_rcv_txn_id
      FROM    rcv_shipment_lines rsl, rcv_shipment_headers rsh
      WHERE   po_header_id = p_po_header_id
      AND     po_release_id = nvl(p_po_release_id,po_release_id) -- bug 5639624
      AND     rsl.shipment_header_id = rsh.shipment_header_id
      GROUP BY rsl.shipment_header_id
      UNION ALL
      SELECT  shipment_header_id,
              WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT txn_type,
              sum(nvl(quantity,0)) shp_rcv_qty,
              max(transaction_id) max_rcv_txn_id
      FROM    rcv_transactions
      WHERE   po_header_id     = p_po_header_id
      AND     po_release_id = nvl(p_po_release_id,po_release_id) -- bug 5639624
      AND     transaction_type IN ( 'RECEIVE','MATCH')
      GROUP BY shipment_header_id
      ORDER BY 1;
   --
   --
   CURSOR rcv_txns_csr (p_po_header_id NUMBER, p_rcv_header_id NUMBER, p_po_release_id NUMBER)
   IS
      SELECT  1
      FROM    rcv_transactions
      WHERE   po_header_id       = p_po_header_id
      AND     po_release_id = nvl(p_po_release_id,po_release_id) -- bug 5639624
      AND     shipment_header_id = p_rcv_header_id
      AND     transaction_type   = 'MATCH'
      AND     rownum             = 1;
   --
   --
   CURSOR rcv_header_csr (p_rcv_header_id NUMBER)
   IS
     select   rsh.SHIPMENT_NUM,
              rsh.RECEIPT_NUM,
              rsh.CARRIER_ID,
              rsh.EXPECTED_RECEIPT_DATE,
              rsh.SHIPPED_DATE,
              rsh.VENDOR_ID,
              rsh.ORGANIZATION_ID,
              rsh.asn_type,
	      wloc.wsh_location_id -- IB-Phase-2
      FROM    rcv_fte_headers_v rsh,
              wsh_locations    wloc
      WHERE   rsh.shipment_header_id        = p_rcv_header_id
      AND     rsh.ship_from_location_id     = wloc.source_location_id(+);  -- IB-Phase-2
   --
   rcv_header_rec rcv_header_csr%ROWTYPE;
   --
   --
   CURSOR asn_csr (p_rcv_header_id NUMBER)
   IS
     select   1
      FROM    rcv_shipment_lines rsl
      WHERE   rsl.shipment_header_id        = p_rcv_header_id
      AND     rsl.shipment_line_status_code = 'CANCELLED'
      AND     rownum                        = 1;
   --
   --IB-Phase-2
   CURSOR get_hz_location_csr(p_rcv_header_id NUMBER)
   IS
     select  rsh.ship_from_location_id
     FROM    rcv_shipment_headers rsh
     WHERE   rsh.shipment_header_id        = p_rcv_header_id;
   --
   l_hzShipFromLocationId  NUMBER; --IB-Phase-2
   l_po_header_id       NUMBER;
   l_po_release_id       NUMBER; -- bug 5639624
   l_locked             VARCHAR2(10);
   l_TransactionType    VARCHAR2(30);
   l_transactionId      NUMBER;
   l_txnHistoryRec      WSH_INBOUND_TXN_HISTORY_PKG.ib_txn_history_rec_type;
   l_asnHistoryRec      WSH_INBOUND_TXN_HISTORY_PKG.ib_txn_history_rec_type;
   --
   --
   l_po_cancel_rec      OE_WSH_BULK_GRP.line_rec_type;
   l_po_close_rec       OE_WSH_BULK_GRP.line_rec_type;
   l_index              NUMBER;
   l_processedTxns      BOOLEAN := FALSE;
   --
   l_return_status      VARCHAR2(1);
   l_num_errors         NUMBER := 0;
   l_num_warnings       NUMBER := 0;
   --
   l_debug_on           BOOLEAN;
   --
   l_module_name     CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'HANDLEPRIORRECEIPTS';
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
    END IF;
    --
    l_po_header_id := x_line_rec.header_id(x_line_rec.header_id.FIRST);
    l_po_release_id := x_line_rec.header_id(x_line_rec.source_blanket_reference_id.FIRST);
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_po_header_id',l_po_header_id);
    END IF;
    --
    --
    -- Check if any receiving transactions
    --
    FOR rcv_headers_rec IN rcv_headers_csr
                            ( p_po_header_id => l_po_header_id,
                              p_po_release_id => l_po_release_id )
    LOOP
    --{
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'rcv_headers_rec.shipment_header_id',rcv_headers_rec.shipment_header_id);
            WSH_DEBUG_SV.log(l_module_name,'rcv_headers_rec.shp_rcv_qty',rcv_headers_rec.shp_rcv_qty);
            WSH_DEBUG_SV.log(l_module_name,'rcv_headers_rec.txn_type',rcv_headers_rec.txn_type);
            WSH_DEBUG_SV.log(l_module_name,'rcv_headers_rec.max_rcv_txn_id',rcv_headers_rec.max_rcv_txn_id);
        END IF;
        --
        --
        IF  (
              (
                  rcv_headers_rec.txn_type = WSH_INBOUND_TXN_HISTORY_PKG.C_ASN
                  AND rcv_headers_rec.shp_rcv_qty > 0
              )
              OR
              rcv_headers_rec.txn_type = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT
            )
        THEN
        --{
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_TXN_HISTORY_PKG.GET_TXN_HISTORY',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            l_transactionType                     := rcv_headers_rec.txn_type;
            l_txnHistoryRec.transaction_id        := NULL;
            l_txnHistoryRec.status                := NULL;
            l_txnHistoryRec.object_version_number := NULL;
            --
            -- Check if record already exists in WSH_INBOUND_TXN_HISTORY
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_TXN_HISTORY_PKG.LOCK_ASN_RECEIPT_HEADER',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_INBOUND_TXN_HISTORY_PKG.lock_asn_receipt_header
              (
                p_shipment_header_id  => rcv_headers_rec.shipment_header_id,
                p_transaction_type    => rcv_headers_rec.txn_type,
                p_on_error            => 'RETRY',
                p_on_noDataFound      => WSH_UTIL_CORE.G_RET_STS_SUCCESS,
                x_txn_history_rec     => l_txnHistoryRec,
                x_return_status       => l_return_status,
                x_locked              => l_locked
              );
            --
            --
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
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
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_txnHistoryRec.transaction_id',l_txnHistoryRec.transaction_id);
                WSH_DEBUG_SV.log(l_module_name,'l_txnHistoryRec.status',l_txnHistoryRec.status);
                WSH_DEBUG_SV.log(l_module_name,'l_txnHistoryRec.object_version_number',l_txnHistoryRec.object_version_number);
            END IF;
            --
            --
            IF  l_txnHistoryRec.transaction_id IS NULL
            THEN
            --{
                OPEN rcv_header_csr(p_rcv_header_id => rcv_headers_rec.shipment_header_id);
                FETCH rcv_header_csr INTO rcv_header_rec;
                CLOSE rcv_header_csr;
                --
                --
                l_asnHistoryRec.RECEIPT_NUMBER          := rcv_header_rec.receipt_num;
                l_asnHistoryRec.SHIPMENT_NUMBER         := rcv_header_rec.shipment_num;
                l_asnHistoryRec.TRANSACTION_TYPE        := l_transactionType;
                l_asnHistoryRec.SHIPMENT_HEADER_ID      := rcv_headers_rec.shipment_header_id;
                l_asnHistoryRec.ORGANIZATION_ID         := rcv_header_rec.ORGANIZATION_ID;
                l_asnHistoryRec.SUPPLIER_ID             := rcv_header_rec.VENDOR_ID;
                l_asnHistoryRec.SHIPPED_DATE            := rcv_header_rec.SHIPPED_DATE;
                l_asnHistoryRec.RECEIPT_DATE            := rcv_header_rec.EXPECTED_RECEIPT_DATE;
                l_asnHistoryRec.CARRIER_ID              := rcv_header_rec.CARRIER_ID;
                l_asnHistoryRec.STATUS                  := WSH_INBOUND_TXN_HISTORY_PKG.C_PENDING;
                l_asnHistoryRec.SHIP_FROM_LOCATION_ID   := rcv_header_rec.wsh_location_id; -- IB-Phase-2
                l_asnHistoryRec.MAX_RCV_TRANSACTION_ID  := NULL;
                l_asnHistoryRec.parent_shipment_header_id := NULL;
                --
                IF l_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT
                THEN
                --{
                    l_asnHistoryRec.MAX_RCV_TRANSACTION_ID := rcv_headers_rec.max_rcv_txn_id;
                    --
                    IF rcv_header_rec.asn_type IN ('ASN','ASBN')
                    THEN
                       l_asnHistoryRec.parent_shipment_header_id := rcv_headers_rec.shipment_header_id;
                    END IF;
                --}
                END IF;
                --
                --
                IF l_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_ASN
                THEN
                --{
                    FOR asn_rec IN asn_csr(p_rcv_header_id => rcv_headers_rec.shipment_header_id)
                    LOOP
                    --{
                        l_txnHistoryRec.STATUS                  := WSH_INBOUND_TXN_HISTORY_PKG.C_CANCELLED;
                    --}
                    END LOOP;
                --}
                END IF;
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'l_asnHistoryRec.SHIPMENT_HEADER_ID',l_asnHistoryRec.SHIPMENT_HEADER_ID);
                    WSH_DEBUG_SV.log(l_module_name,'l_asnHistoryRec.status',l_asnHistoryRec.status);
                    WSH_DEBUG_SV.log(l_module_name,'l_txnHistoryRec.status',l_txnHistoryRec.status);
                END IF;
                --
                --
                IF l_asnHistoryRec.SHIPMENT_HEADER_ID = rcv_headers_rec.shipment_header_id
                THEN
                --{
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_TXN_HISTORY_PKG.CREATE_TXN_HISTORY',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    WSH_INBOUND_TXN_HISTORY_PKG.create_txn_history
                      (
                        p_txn_history_rec => l_asnHistoryRec,
                        x_txn_id          => l_transactionId,
                        x_return_status   => l_return_status
                      );
                    --
                    -- Debug Statements
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                        WSH_DEBUG_SV.log(l_module_name,'l_transactionId',l_transactionId);
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    wsh_util_core.api_post_call
                      (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                      );
                                        --
                                        --
                    l_txnHistoryRec.transaction_id        := l_transactionId;
                --}
                END IF;
            --}
            END IF;
            --
            --
            IF l_txnHistoryRec.status IN (
                                           WSH_INBOUND_TXN_HISTORY_PKG.C_MATCHED,
                                           WSH_INBOUND_TXN_HISTORY_PKG.C_MATCHED_AND_CHILD_PENDING
                                         )
            OR l_txnHistoryRec.status IS NULL
            THEN
            --{
                IF  l_transactionType = WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT
                THEN
                --{
                    --IF l_txnHistoryRec.transaction_id IS NOT NULL
                    IF l_txnHistoryRec.status IS NOT NULL
                    THEN
                        l_transactionType := WSH_INBOUND_TXN_HISTORY_PKG.C_RECEIPT_ADD;
                    END IF;
                    --
                    --
                    FOR rcv_txns_rec IN rcv_txns_csr
                                          (
                                            p_po_header_id  => l_po_header_id,
                                            p_rcv_header_id => rcv_headers_rec.shipment_header_id,
                                            p_po_release_id => l_po_release_id
                                          )
                    LOOP
                    --{
                        IF l_txnHistoryRec.transaction_id IS NULL
                        THEN
                            l_transactionType := 'MATCH';
                        ELSE
                            l_transactionType := 'MATCH_ADD';
                        END IF;
                    --}
                    END LOOP;
                --}
                END IF;
                --
                --IF  l_txnHistoryRec.transaction_id IS NULL
                --OR  l_objectVersionNumber = l_txnHistoryRec.object_version_number
                --THEN
                --{
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_IB_TXN_MATCH_PKG.processPriorReceipts',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    l_processedTxns := TRUE;
                    --
		    --IB-Phase-2
                    OPEN  get_hz_location_csr(rcv_headers_rec.shipment_header_id);
                    FETCH get_hz_location_csr INTO  l_hzShipFromLocationId;
		    CLOSE get_hz_location_csr;
                    --

                    WSH_IB_TXN_MATCH_PKG.processPriorReceipts
                      (
                        p_shipmentHeaderId     => rcv_headers_rec.shipment_header_id  ,
                        p_transactionType      => rcv_headers_rec.txn_type,
                        p_MAtransactionType    => l_transactionType,
                        p_inboundTxnHistoryId  => l_txnHistoryRec.transaction_id,
                        p_maxRcvTxnId          => rcv_headers_rec.max_rcv_txn_id,
                        p_poHeaderId           => l_po_header_id,
			p_hzShipFromLocationId => l_hzShipFromLocationId, --IB-Phase-2
                        x_return_status        => l_return_status
                      );
                    --
                    -- Debug Statements
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
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
                --END IF;
            --}
            ELSIF l_txnHistoryRec.transaction_id IS NOT NULL
            THEN
            --{
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'UPDATE WSH_INBOUND_TXN_HISTORY-PENDING');
                    WSH_DEBUG_SV.log(l_module_name,'l_txnHistoryRec.transaction_id',l_txnHistoryRec.transaction_id);
                END IF;
                --
                --
                UPDATE WSH_INBOUND_TXN_HISTORY
                SET    OBJECT_VERSION_NUMBER   = NVL(OBJECT_VERSION_NUMBER,0) + 1,
                       LAST_UPDATE_DATE        = SYSDATE,
                       LAST_UPDATED_BY         = FND_GLOBAL.USER_ID,
                       LAST_UPDATE_LOGIN       = FND_GLOBAL.LOGIN_ID
                WHERE  TRANSACTION_ID          = l_txnHistoryRec.transaction_id;
                --
                IF SQL%ROWCOUNT = 0
                THEN
                    FND_MESSAGE.SET_NAME('WSH','WSH_IB_TXN_UPDATE_ERROR');
                    FND_MESSAGE.SET_TOKEN('TRANSACTION_ID',l_txnHistoryRec.transaction_id);
                    wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
                    RAISE FND_API.G_EXC_ERROR;
                END IF;
            --}
            END IF;
        --}
        END IF;
    --}
    END LOOP;
    --
    --
    l_index := x_line_rec.header_id.FIRST;
    --
    --
    WHILE l_index IS NOT NULL
    AND l_processedTxns
    LOOP
    --{
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Processing x_line_rec:l_index',l_index);
            WSH_DEBUG_SV.log(l_module_name,'x_line_rec.closed_flag(l_index)',x_line_rec.closed_flag(l_index));
            WSH_DEBUG_SV.log(l_module_name,'x_line_rec.closed_code(l_index)',x_line_rec.closed_code(l_index));
            WSH_DEBUG_SV.log(l_module_name,'x_line_rec.cancelled_flag(l_index)',x_line_rec.cancelled_flag(l_index));
        END IF;
        --
        -- If PO has done a cancel/close operation on a particular record, and due to
        -- the fact that the corresponding transaction was in pending status, it could not
        -- be updated at that point of time, for such records, once the matching has been done,
        -- the recrods need to be updated to the status of the corresponding po record.

        /* For cancelled recrods also the closed code is populated as CLOSED.
           So instead of populating the cancel rec, the close rec is getting populated
           and the open lines are getting closed instead of cancelled.Putting additional
           check on the cancelled_flag to avoid this.*/
        --
        IF  NVL(x_line_rec.closed_code(l_index), 'N') IN ('CLOSED', 'CLOSED FOR RECEIVING', 'FINALLY CLOSED')
        AND NVL(x_line_rec.cancelled_flag(l_index), 'N')  <> 'Y'
        THEN
        --{
           l_po_close_rec.header_id.EXTEND;
           l_po_close_rec.line_id.EXTEND;
           l_po_close_rec.po_shipment_line_id.EXTEND;
           l_po_close_rec.source_blanket_reference_id.EXTEND;
           --
           l_po_close_rec.header_id(l_po_close_rec.header_id.COUNT)                   := x_line_rec.header_id(l_index);
           l_po_close_rec.line_id(l_po_close_rec.header_id.COUNT )                    := x_line_rec.line_id(l_index);
           l_po_close_rec.po_shipment_line_id(l_po_close_rec.header_id.COUNT)         := x_line_rec.po_shipment_line_id(l_index);
           l_po_close_rec.source_blanket_reference_id(l_po_close_rec.header_id.COUNT) := x_line_rec.source_blanket_reference_id(l_index);
        ELSIF NVL(x_line_rec.cancelled_flag(l_index), 'N') = 'Y'
        THEN
        --{
           l_po_cancel_rec.header_id.EXTEND;
           l_po_cancel_rec.line_id.EXTEND;
           l_po_cancel_rec.po_shipment_line_id.EXTEND;
           l_po_cancel_rec.source_blanket_reference_id.EXTEND;
           --
           l_po_cancel_rec.header_id(l_po_cancel_rec.header_id.COUNT)                   := x_line_rec.header_id(l_index);
           l_po_cancel_rec.line_id(l_po_cancel_rec.header_id.COUNT )                    := x_line_rec.line_id(l_index);
           l_po_cancel_rec.po_shipment_line_id(l_po_cancel_rec.header_id.COUNT )        := x_line_rec.po_shipment_line_id(l_index);
           l_po_cancel_rec.source_blanket_reference_id(l_po_cancel_rec.header_id.COUNT) := x_line_rec.source_blanket_reference_id(l_index);
        --}
        END IF;
        --
        l_index := x_line_rec.header_id.NEXT(l_index);
    --}
    END LOOP;
    --
    --
    --
    --
    IF l_po_cancel_rec.line_id.COUNT > 0
    OR l_po_close_rec.line_id.COUNT > 0
    THEN
    --{
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ASN_RECEIPT_PVT.cancel_close_pending_txns',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
       WSH_ASN_RECEIPT_PVT.cancel_close_pending_txns
          (
            p_po_cancel_rec       => l_po_cancel_rec,
            p_po_close_rec        => l_po_close_rec,
            x_return_status       => l_return_status
          );
       --
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       --
       wsh_util_core.api_post_call
          (
            p_return_status => l_return_status,
            x_num_warnings  => l_num_warnings,
            x_num_errors    => l_num_errors
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
    -- Debug Statements
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
--}
EXCEPTION
--{
    WHEN FND_API.G_EXC_ERROR THEN
      --ROLLBACK TO matchTransaction_sp;
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
      --ROLLBACK TO matchTransaction_sp;
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
      --ROLLBACK TO matchTransaction_sp;
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
      --ROLLBACK TO matchTransaction_sp;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_IB_TXN_MATCH_PKG.handlePriorReceipts');
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
--}
END handlePriorReceipts;



END WSH_IB_TXN_MATCH_PKG;

/
