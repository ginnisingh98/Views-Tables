--------------------------------------------------------
--  DDL for Package Body WSH_SHIPMENT_REQUEST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_SHIPMENT_REQUEST_PKG" AS
/* $Header: WSHSRPKB.pls 120.0.12010000.7 2009/12/09 12:03:43 mvudugul noship $ */

   G_PKG_NAME      CONSTANT VARCHAR2(30) := 'WSH_SHIPMENT_REQUEST_PKG';
   g_interface_action_code  WSH_NEW_DEL_INTERFACE.INTERFACE_ACTION_CODE%TYPE;
   g_po_total_time          NUMBER := 0;
   g_sold_to_ref            VARCHAR2(50) := 'CUST-SOLD-TO-REF';
   g_ship_to_ref            VARCHAR2(50) := 'CUST-SHIP-TO-REF';
   g_invoice_to_ref         VARCHAR2(50) := 'CUST-INVOICE-TO-REF';
   g_deliver_to_ref         VARCHAR2(50) := 'CUST-DELIVER-TO-REF';
   g_ship_to_address_ref    VARCHAR2(50) := 'CUST-SHIP-TO-ADDRESS-REF';
   g_invoice_to_address_ref VARCHAR2(50) := 'CUST-INVOICE-ADDRESS-TO-REF';
   g_deliver_to_address_ref VARCHAR2(50) := 'CUST-DELIVER-TO-ADDRESS-REF';
   g_sold_to_contact_ref    VARCHAR2(50) := 'CUST-SOLD-TO-CONTACT-REF';
   g_ship_to_contact_ref    VARCHAR2(50) := 'CUST-SHIP-TO-CONTACT-REF';
   g_invoice_to_contact_ref VARCHAR2(50) := 'CUST-INVOICE-TO-CONTACT-REF';
   g_deliver_to_contact_ref VARCHAR2(50) := 'CUST-DELIVER-TO-CONTACT-REF';
   G_BINARY_LIMIT           NUMBER       := 2147483647; --LSP Project

--FORWARD Declaration
PROCEDURE Populate_OM_Common_Attr(
          p_om_header_rec     IN OM_Header_Rec_Type,
          p_del_interface_rec IN Del_Interface_Rec_Type,
          x_header_rec        IN OUT NOCOPY OE_ORDER_PUB.Header_Rec_Type,
          x_line_tbl          IN OUT NOCOPY OE_ORDER_PUB.Line_Tbl_Type,
          x_customer_info     OUT NOCOPY OE_ORDER_PUB.Customer_Info_Table_Type,
          x_return_status     OUT NOCOPY VARCHAR2 );

PROCEDURE Print_OE_Header_Record(
          p_header_rec         IN OE_ORDER_PUB.Header_Rec_Type,
          p_header_val_rec     IN OE_ORDER_PUB.Header_Val_Rec_Type,
          p_customer_info      IN OE_ORDER_PUB.Customer_Info_Table_Type,
          p_action_request_tbl IN OE_ORDER_PUB.Request_Tbl_Type );

PROCEDURE Print_OE_Line_Record(
          p_line_tbl       IN OE_ORDER_PUB.Line_Tbl_Type,
          p_line_val_tbl   IN OE_ORDER_PUB.Line_Val_Tbl_Type );

PROCEDURE Populate_Error_Records(
          p_interface_id             IN  NUMBER,
          p_interface_table_name     IN  VARCHAR2,
          x_interface_errors_rec_tab IN OUT NOCOPY WSH_INTERFACE_VALIDATIONS_PKG.interface_errors_rec_tab,
          x_return_status            OUT NOCOPY VARCHAR2 );
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Shipment_Request_Inbound
--
-- PARAMETERS:
--       errbuf                 => Message returned to Concurrent Manager
--       retcode                => Code (0, 1, 2) returned to Concurrent Manager
--       p_transaction_status   => Either AP, ER, NULL
--       p_deploy_mode          => Dummy for LSP(Enable or Disable Client)
--       p_client_code          => Client Code  -- Modified R12.1.1 LSP PROJECT
--       p_from_document_number => From Document Number
--       p_to_document_number   => To Document Number
--       p_from_creation_date   => From Creation Date
--       p_to_creation_date     => To Creation Date
--       p_transaction_id       => Transacation id to be processed
--       p_log_level            => Either 1(Debug), 0(No Debug)
-- COMMENT:
--       API will be invoked from Concurrent Manager whenever concurrent program
--       'Process Shipment Requests' is triggered.
--=============================================================================
--
PROCEDURE Shipment_Request_Inbound (
          errbuf                 OUT NOCOPY   VARCHAR2,
          retcode                OUT NOCOPY   NUMBER,
          p_transaction_status   IN  VARCHAR2,
          p_deploy_mode          IN  VARCHAR2,  -- Modified R12.1.1 LSP PROJECT
          p_client_code          IN  VARCHAR2,  -- Modified R12.1.1 LSP PROJECT
          p_from_document_number IN  NUMBER,
          p_to_document_number   IN  NUMBER,
          p_from_creation_date   IN  VARCHAR2,
          p_to_creation_date     IN  VARCHAR2,
          p_transaction_id       IN  NUMBER,
          p_log_level            IN  NUMBER )
IS
   l_completion_status          VARCHAR2(30);
   l_return_status              VARCHAR2(1);

   l_debug_on                 BOOLEAN;
   l_module_name CONSTANT     VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Shipment_Request_Inbound';
BEGIN
   --
   WSH_UTIL_CORE.Enable_Concurrent_Log_Print;
   WSH_UTIL_CORE.Set_Log_Level(p_log_level);
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      wsh_debug_sv.push(l_module_name);
      wsh_debug_sv.log(l_module_name, 'p_transaction_status', p_transaction_status);
      wsh_debug_sv.log(l_module_name, 'p_client_code', p_client_code);  -- Modified R12.1.1 LSP PROJECT
      wsh_debug_sv.log(l_module_name, 'p_from_document_number', p_from_document_number);
      wsh_debug_sv.log(l_module_name, 'p_to_document_number', p_to_document_number);
      wsh_debug_sv.log(l_module_name, 'p_from_creation_date', p_from_creation_date);
      wsh_debug_sv.log(l_module_name, 'p_to_creation_date', p_to_creation_date);
      wsh_debug_sv.log(l_module_name, 'p_transaction_id', p_transaction_id);
      wsh_debug_sv.log(l_module_name, 'p_log_level', p_log_level);
   END IF;
   --

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'Calling Process_Shipment_Request', WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --

   Process_Shipment_Request(
            p_commit_flag          => FND_API.G_TRUE,
            p_transaction_status   => p_transaction_status,
            p_client_code            => p_client_code,  -- Modified R12.1.1 LSP PROJECT
            p_from_document_number => p_from_document_number,
            p_to_document_number   => p_to_document_number,
            p_from_creation_date   => p_from_creation_date,
            p_to_creation_date     => p_to_creation_date,
            p_transaction_id       => p_transaction_id,
            x_return_status        => l_return_status );

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'Return Status of Process_Shipment_Request', l_return_status);
   END IF;
   --


   IF l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      l_completion_status := 'SUCCESS';
      errbuf := 'Process Shipment Requests Program has completed successfully';
      retcode := '0';
   ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
      l_completion_status := 'WARNING';
      errbuf := 'Process Shipment Requests Program has completed with warning';
      retcode := '1';
   ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
      l_completion_status := 'ERROR';
      errbuf := 'Process Shipment Requests Program has completed with error';
      retcode := '2';
   ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
      l_completion_status := 'UNEXPECTED ERROR';
      errbuf := 'Process Shipment Requests Program has completed with unexpected error';
      retcode := '2';
   END IF;

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_completion_status', l_completion_status);
      WSH_DEBUG_SV.log(l_module_name,'errbuf', errbuf);
      WSH_DEBUG_SV.log(l_module_name,'retcode', retcode);
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
EXCEPTION
   WHEN OTHERS THEN
      l_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      errbuf := 'Process Shipment Requests Program is completed with unexpected error - ' || SQLCODE;
      retcode := '2';
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Shipment_Request_Inbound;

--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Process_Shipment_Request
--
-- PARAMETERS:
--       p_commit_flag          => Either FND_API.G_TRUE, FND_API.G_FALSE
--       p_transaction_status   => Either AP, ER, NULL
--       p_client_code          => Client Code   -- Modified R12.1.1 LSP PROJECT
--       p_from_document_number => From Document Number
--       p_to_document_number   => To Document Number
--       p_from_creation_date   => From Creation Date
--       p_to_creation_date     => To Creation Date
--       p_transaction_id       => Transacation id to be processed
--       x_return_status        => Return Status of API (S,W,E,U)
-- COMMENT:
--       Based on input parameter values, eligble records for processing are
--       queried from WTH table. Calling Workflow API WF_ENGINE.handleError to
--       process further, if WTH row queried is triggered from Workflow.
--       Calling Overloaded API Process_Shipment_Request, if WTH row queried is
--       NOT triggered from Workflow.
--=============================================================================
--
PROCEDURE Process_Shipment_Request (
          p_commit_flag          IN  VARCHAR2,
          p_transaction_status   IN  VARCHAR2,
          p_client_code          IN  VARCHAR2,  -- Modified R12.1.1 LSP PROJECT
          p_from_document_number IN  NUMBER,
          p_to_document_number   IN  NUMBER,
          p_from_creation_date   IN  VARCHAR2,
          p_to_creation_date     IN  VARCHAR2,
          p_transaction_id       IN  NUMBER,
          x_return_status        OUT NOCOPY VARCHAR2 )
IS

   CURSOR C_Get_One_Transactions
   IS
      SELECT wth.Transaction_ID,
             wth.Document_Type,
             wth.Document_Direction,
             wth.Document_Number,
             wth.Orig_Document_Number,
             wth.Entity_Number,
             wth.Entity_Type,
             wth.Trading_Partner_ID,
             wth.Action_Type,
             wth.Transaction_Status,
             wth.ECX_Message_ID,
             wth.Event_Name,
             wth.Event_Key,
             wth.Item_Type,
             wth.Internal_Control_Number,
             wth.document_revision,
             wth.Attribute_Category,
             wth.Attribute1,
             wth.Attribute2,
             wth.Attribute3,
             wth.Attribute4,
             wth.Attribute5,
             wth.Attribute6,
             wth.Attribute7,
             wth.Attribute8,
             wth.Attribute9,
             wth.Attribute10,
             wth.Attribute11,
             wth.Attribute12,
             wth.Attribute13,
             wth.Attribute14,
             wth.Attribute15,
             NULL  -- LSP PROJECT : just added for dependency for client_id
   FROM   Wsh_Transactions_History wth,
          Wsh_New_Del_Interface wndi
   WHERE  wndi.interface_action_code = g_interface_action_code
   AND    wndi.delivery_interface_id = to_number(wth.entity_number)
   AND    wth.transaction_id = p_transaction_id
   AND    wth.transaction_status = nvl(p_transaction_status, wth.transaction_status);

   l_from_document_number       VARCHAR2(30);
   l_to_document_number         VARCHAR2(30);

   cursor c_get_status (v_trx_id NUMBER)
   is
      select transaction_status
      from   wsh_transactions_history
      where  transaction_id = v_trx_id;


   l_transaction_rec            WSH_TRANSACTIONS_HISTORY_PKG.Txns_History_Record_Type;
   l_trx_status                 wsh_transactions_history.transaction_status%TYPE;

   l_from_creation_date         DATE;
   l_to_creation_date           DATE;

   l_total                      NUMBER := 0;
   l_success                    NUMBER := 0;
   l_errors                     NUMBER := 0;
   v_cursorid                   INTEGER;
   v_ignore                     INTEGER;
   l_tmp_status                 VARCHAR2(1);
   l_standalone_mode            VARCHAR2(1);
   l_document_where             VARCHAR2(200);
   l_transaction_query          VARCHAR2(15000);
   l_client_code                VARCHAR2(10); -- Modified R12.1.1 LSP PROJECT
   --
   others                       EXCEPTION;

   l_debug_on                 BOOLEAN;
   l_module_name CONSTANT     VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Process_Shipment_Request1';
BEGIN
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      wsh_debug_sv.push(l_module_name);
      wsh_debug_sv.log(l_module_name, 'p_commit_flag', p_commit_flag);
      wsh_debug_sv.log(l_module_name, 'p_transaction_status', p_transaction_status);
      wsh_debug_sv.log(l_module_name, 'p_client_code', p_client_code);  -- Modified R12.1.1 LSP PROJECT
      wsh_debug_sv.log(l_module_name, 'p_from_document_number', p_from_document_number);
      wsh_debug_sv.log(l_module_name, 'p_to_document_number', p_to_document_number);
      wsh_debug_sv.log(l_module_name, 'p_from_creation_date', p_from_creation_date);
      wsh_debug_sv.log(l_module_name, 'p_to_creation_date', p_to_creation_date);
      wsh_debug_sv.log(l_module_name, 'p_transaction_id', p_transaction_id);
   END IF;
   --

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   --Check if instance is running in Standalone, if not exit out of the program
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'Calling WMS_DEPLOY.Wms_Deployment_Mode', WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   l_standalone_mode := WMS_DEPLOY.Wms_Deployment_Mode;

   IF l_standalone_mode = 'D' THEN
      g_interface_action_code := '94X_STANDALONE';
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Deployment Mode is : Distributed');
      END IF;
   ELSIF l_standalone_mode = 'L' THEN --  LSP PROJECT : Consider LSP mode also
      g_interface_action_code := '94X_STANDALONE';
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Deployment Mode is : LSP ');
      END IF;
   ELSE
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Deployment Mode is not LSP/Distributed');
      END IF;
      --
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   l_from_creation_date   := to_date(p_from_creation_date,'YYYY/MM/DD HH24:MI:SS');
   l_to_creation_date     := to_date(p_to_creation_date,'YYYY/MM/DD HH24:MI:SS');
   l_from_document_number := to_char(p_from_document_number);
   l_to_document_number   := to_char(p_to_document_number);

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_from_creation_date',l_from_creation_date);
      WSH_DEBUG_SV.log(l_module_name,'l_to_creation_date',l_to_creation_date);
      WSH_DEBUG_SV.log(l_module_name,'l_from_document_number',l_from_document_number);
      WSH_DEBUG_SV.log(l_module_name,'l_to_document_number',l_to_document_number);
   END IF;
   --

   IF p_transaction_id is not null THEN
      OPEN C_Get_One_Transactions;
   ELSE
      IF p_from_document_number is not null OR p_to_document_number is not null
      THEN
         l_document_where := 'TO_NUMBER(DECODE(RTRIM(TRANSLATE(wth1.document_number,''0123456789'', '' '')), NULL, wth1.document_number,-99999)) ';
      END IF;

      --SELECT Clause
      l_transaction_query := 'SELECT wth.Transaction_ID, ';
      l_transaction_query := l_transaction_query || 'wth.Document_Type, ';
      l_transaction_query := l_transaction_query || 'wth.Document_Direction, ';
      l_transaction_query := l_transaction_query || 'wth.Document_Number, ';
      l_transaction_query := l_transaction_query || 'wth.Orig_Document_Number, ';
      l_transaction_query := l_transaction_query || 'wth.Entity_Number, ';
      l_transaction_query := l_transaction_query || 'wth.Entity_Type, ';
      l_transaction_query := l_transaction_query || 'wth.Trading_Partner_ID, ';
      l_transaction_query := l_transaction_query || 'wth.Action_Type, ';
      l_transaction_query := l_transaction_query || 'wth.Transaction_Status, ';
      l_transaction_query := l_transaction_query || 'wth.ECX_Message_ID, ';
      l_transaction_query := l_transaction_query || 'wth.Event_Name, ';
      l_transaction_query := l_transaction_query || 'wth.Event_Key, ';
      l_transaction_query := l_transaction_query || 'wth.Item_Type, ';
      l_transaction_query := l_transaction_query || 'wth.Internal_Control_Number, ';
      l_transaction_query := l_transaction_query || 'wth.document_revision, ';
      l_transaction_query := l_transaction_query || 'wth.Attribute_Category, ';
      l_transaction_query := l_transaction_query || 'wth.Attribute1, ';
      l_transaction_query := l_transaction_query || 'wth.Attribute2, ';
      l_transaction_query := l_transaction_query || 'wth.Attribute3, ';
      l_transaction_query := l_transaction_query || 'wth.Attribute4, ';
      l_transaction_query := l_transaction_query || 'wth.Attribute5, ';
      l_transaction_query := l_transaction_query || 'wth.Attribute6, ';
      l_transaction_query := l_transaction_query || 'wth.Attribute7, ';
      l_transaction_query := l_transaction_query || 'wth.Attribute8, ';
      l_transaction_query := l_transaction_query || 'wth.Attribute9, ';
      l_transaction_query := l_transaction_query || 'wth.Attribute10, ';
      l_transaction_query := l_transaction_query || 'wth.Attribute11, ';
      l_transaction_query := l_transaction_query || 'wth.Attribute12, ';
      l_transaction_query := l_transaction_query || 'wth.Attribute13, ';
      l_transaction_query := l_transaction_query || 'wth.Attribute14, ';
      l_transaction_query := l_transaction_query || 'wth.Attribute15 ';

      --FROM Clause
      l_transaction_query := l_transaction_query || '   FROM   Wsh_Transactions_History wth, ';
      --l_transaction_query := l_transaction_query || '   FROM   Wsh_New_Del_Interface    wndi, ';
      l_transaction_query := l_transaction_query || '( SELECT max(wth1.document_revision) document_revision, ';
      l_transaction_query := l_transaction_query || '         to_char(max(to_number(entity_number))) entity_number, ';
      l_transaction_query := l_transaction_query || '         document_number, document_type, document_direction ';
      l_transaction_query := l_transaction_query || '  FROM   Wsh_Transactions_History wth1 ';

      l_transaction_query := l_transaction_query || '  WHERE  wth1.document_type = ''SR'' ';
      l_transaction_query := l_transaction_query || '  AND    wth1.document_direction = ''I'' ';

      IF p_from_document_number is not null and p_to_document_number is not null
      THEN
         l_transaction_query := l_transaction_query || '  AND    ' || l_document_where || ' between :x_from_document_number ';
         l_transaction_query := l_transaction_query || '  and :x_to_document_number ';
      ELSIF p_from_document_number is not null and p_to_document_number is null
      THEN
         l_transaction_query := l_transaction_query || '  AND    ' || l_document_where || ' >= :x_from_document_number ';
      ELSIF p_from_document_number is null and p_to_document_number is not null
      THEN
         -- Querying documents with greater than Zero since if document number contains characters it will be translated to -99999
         l_transaction_query := l_transaction_query || '  AND    ' || l_document_where || ' between 0 and :x_to_document_number ';
      END IF;

      IF p_transaction_status is not null
      THEN
         l_transaction_query := l_transaction_query || '  AND    wth1.transaction_status = :x_transaction_status ';
      ELSE
         l_transaction_query := l_transaction_query || '  AND    wth1.transaction_status in (''AP'', ''ER'') ';
      END IF;

      IF l_from_creation_date is not null and l_to_creation_date is not null
      THEN
         l_transaction_query := l_transaction_query || '  AND    wth1.creation_date between :x_from_creation_date ';
         l_transaction_query := l_transaction_query || '  and :x_to_creation_date ';
      ELSIF l_from_creation_date is not null and l_to_creation_date is null
      THEN
         l_transaction_query := l_transaction_query || '  AND    wth1.creation_date >= :x_from_creation_date ';
      ELSIF l_from_creation_date is null and l_to_creation_date is not null
      THEN
         l_transaction_query := l_transaction_query || '  AND    wth1.creation_date <= :x_to_creation_date ';
      END IF;

      l_transaction_query := l_transaction_query || '  group by document_number, document_type, document_direction ) MDR ';
      l_transaction_query := l_transaction_query || 'WHERE  wth.document_number = MDR.document_number ';
      l_transaction_query := l_transaction_query || 'AND    wth.entity_number = MDR.entity_number ';
      l_transaction_query := l_transaction_query || 'AND    wth.document_revision = MDR.document_revision ';
      l_transaction_query := l_transaction_query || 'AND    wth.document_type = ''SR'' ';
      l_transaction_query := l_transaction_query || 'AND    wth.document_direction = ''I'' ';
      l_transaction_query := l_transaction_query || 'AND    exists ';
      l_transaction_query := l_transaction_query || '     ( SELECT 1 from wsh_new_del_interface wndi ';
      l_transaction_query := l_transaction_query || 'WHERE  interface_action_code = ''' || g_interface_action_code || '''';
      -- Modified R12.1.1 LSP PROJECT* :Begin
      IF p_client_code is not null THEN
        l_transaction_query := l_transaction_query || '  AND wndi.client_code=:x_client_code  ';
      END IF;
      -- Modified R12.1.1 LSP PROJECT* : end
      l_transaction_query := l_transaction_query || 'AND    wndi.delivery_interface_id = wth.entity_number ) ';

      l_transaction_query := l_transaction_query || 'ORDER BY decode(wth.action_type, ''D'', 1, ''C'', 2, ''A'', 3, 4 ) ';


      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'Transaction Query', l_transaction_query);
      END IF;
      --

      v_cursorid := DBMS_SQL.Open_Cursor;
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'Opended cursor successfully', v_cursorid);
      END IF;
      --
      DBMS_SQL.Parse(v_cursorid, l_transaction_query, DBMS_SQL.v7 );

      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Parsed cursor successfully');
      END IF;
      --
      DBMS_SQL.Define_Column(v_cursorid, 1,  l_transaction_rec.Transaction_ID);
      DBMS_SQL.Define_Column(v_cursorid, 2,  l_transaction_rec.Document_Type, 30);
      DBMS_SQL.Define_Column(v_cursorid, 3,  l_transaction_rec.Document_Direction, 1);
      DBMS_SQL.Define_Column(v_cursorid, 4,  l_transaction_rec.Document_Number, 120);
      DBMS_SQL.Define_Column(v_cursorid, 5,  l_transaction_rec.Orig_Document_Number, 120);
      DBMS_SQL.Define_Column(v_cursorid, 6,  l_transaction_rec.Entity_Number, 30);
      DBMS_SQL.Define_Column(v_cursorid, 7,  l_transaction_rec.Entity_Type, 30);
      DBMS_SQL.Define_Column(v_cursorid, 8,  l_transaction_rec.Trading_Partner_ID);
      DBMS_SQL.Define_Column(v_cursorid, 9,  l_transaction_rec.Action_Type, 30);
      DBMS_SQL.Define_Column(v_cursorid, 10, l_transaction_rec.Transaction_Status, 2);
      DBMS_SQL.Define_Column_Raw(v_cursorid, 11, l_transaction_rec.ecx_message_id, 16);
      DBMS_SQL.Define_Column(v_cursorid, 12, l_transaction_rec.Event_Name, 240);
      DBMS_SQL.Define_Column(v_cursorid, 13, l_transaction_rec.Event_Key, 240);
      DBMS_SQL.Define_Column(v_cursorid, 14, l_transaction_rec.Item_Type, 8);
      DBMS_SQL.Define_Column(v_cursorid, 15, l_transaction_rec.Internal_Control_Number);
      DBMS_SQL.Define_Column(v_cursorid, 16, l_transaction_rec.document_revision);
      DBMS_SQL.Define_Column(v_cursorid, 17, l_transaction_rec.Attribute_Category, 150);
      DBMS_SQL.Define_Column(v_cursorid, 18, l_transaction_rec.Attribute1, 150);
      DBMS_SQL.Define_Column(v_cursorid, 19, l_transaction_rec.Attribute2, 150);
      DBMS_SQL.Define_Column(v_cursorid, 20, l_transaction_rec.Attribute3, 150);
      DBMS_SQL.Define_Column(v_cursorid, 21, l_transaction_rec.Attribute4, 150);
      DBMS_SQL.Define_Column(v_cursorid, 22, l_transaction_rec.Attribute5, 150);
      DBMS_SQL.Define_Column(v_cursorid, 23, l_transaction_rec.Attribute6, 150);
      DBMS_SQL.Define_Column(v_cursorid, 24, l_transaction_rec.Attribute7, 150);
      DBMS_SQL.Define_Column(v_cursorid, 25, l_transaction_rec.Attribute8, 150);
      DBMS_SQL.Define_Column(v_cursorid, 26, l_transaction_rec.Attribute9, 150);
      DBMS_SQL.Define_Column(v_cursorid, 27, l_transaction_rec.Attribute10, 150);
      DBMS_SQL.Define_Column(v_cursorid, 28, l_transaction_rec.Attribute11, 150);
      DBMS_SQL.Define_Column(v_cursorid, 29, l_transaction_rec.Attribute12, 150);
      DBMS_SQL.Define_Column(v_cursorid, 30, l_transaction_rec.Attribute13, 150);
      DBMS_SQL.Define_Column(v_cursorid, 31, l_transaction_rec.Attribute14, 150);
      DBMS_SQL.Define_Column(v_cursorid, 32, l_transaction_rec.Attribute15, 150);
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Defined Columns successfully');
      END IF;
      --

      --Start assigning BIND values
      IF p_from_document_number is not null and p_to_document_number is not null
      THEN
         DBMS_SQL.BIND_VARIABLE(v_cursorid,':x_from_document_number', p_from_document_number);
         DBMS_SQL.BIND_VARIABLE(v_cursorid,':x_to_document_number', p_to_document_number);
      ELSIF p_from_document_number is not null and p_to_document_number is null
      THEN
         DBMS_SQL.BIND_VARIABLE(v_cursorid,':x_from_document_number', p_from_document_number);
      ELSIF p_from_document_number is null and p_to_document_number is not null
      THEN
         DBMS_SQL.BIND_VARIABLE(v_cursorid,':x_to_document_number', p_to_document_number);
      END IF;

      IF p_transaction_status is not null
      THEN
         DBMS_SQL.BIND_VARIABLE(v_cursorid,':x_transaction_status', p_transaction_status);
      END IF;

      IF l_from_creation_date is not null and l_to_creation_date is not null
      THEN
         DBMS_SQL.BIND_VARIABLE(v_cursorid,':x_from_creation_date', l_from_creation_date);
         DBMS_SQL.BIND_VARIABLE(v_cursorid,':x_to_creation_date', l_to_creation_date);
      ELSIF l_from_creation_date is not null and l_to_creation_date is null
      THEN
         DBMS_SQL.BIND_VARIABLE(v_cursorid,':x_from_creation_date', l_from_creation_date);
      ELSIF l_from_creation_date is null and l_to_creation_date is not null
      THEN
         DBMS_SQL.BIND_VARIABLE(v_cursorid,':x_to_creation_date', l_to_creation_date);
      END IF;
      /*Modified R12.1.1 LSP PROJECT */
      IF p_client_code is not null
      THEN
        DBMS_SQL.BIND_VARIABLE(v_cursorid,':x_client_code', p_client_code); --Modified R12.1.1 LSP PROJECT
      END IF;
      /*Modified R12.1.1 LSP PROJECT */
      --End assigning BIND values
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Bind values successfully');
      END IF;
      --

      v_ignore := DBMS_SQL.Execute(v_cursorid);
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'Cursor executed successfully', v_ignore);
      END IF;
      --
   END IF;

   LOOP --{
      IF p_transaction_id is not null THEN
         FETCH C_Get_One_Transactions INTO l_transaction_rec;
         EXIT WHEN C_Get_One_Transactions%NOTFOUND;
      ELSE
         v_ignore := DBMS_SQL.Fetch_Rows(v_cursorid);
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'Fetched successfully', v_ignore);
         END IF;
         --
         IF v_ignore = 0 THEN
            EXIT;
         END IF;

         DBMS_SQL.Column_Value(v_cursorid, 1, l_transaction_rec.Transaction_ID);
         DBMS_SQL.Column_Value(v_cursorid, 2, l_transaction_rec.Document_Type);
         DBMS_SQL.Column_Value(v_cursorid, 3, l_transaction_rec.Document_Direction);
         DBMS_SQL.Column_Value(v_cursorid, 4, l_transaction_rec.Document_Number);
         DBMS_SQL.Column_Value(v_cursorid, 5, l_transaction_rec.Orig_Document_Number);
         DBMS_SQL.Column_Value(v_cursorid, 6, l_transaction_rec.Entity_Number);
         DBMS_SQL.Column_Value(v_cursorid, 7, l_transaction_rec.Entity_Type);
         DBMS_SQL.Column_Value(v_cursorid, 8, l_transaction_rec.Trading_Partner_ID);
         DBMS_SQL.Column_Value(v_cursorid, 9, l_transaction_rec.Action_Type);
         DBMS_SQL.Column_Value(v_cursorid, 10, l_transaction_rec.Transaction_Status);
         DBMS_SQL.Column_Value_Raw(v_cursorid, 11, l_transaction_rec.ecx_message_id);
         DBMS_SQL.Column_Value(v_cursorid, 12, l_transaction_rec.Event_Name);
         DBMS_SQL.Column_Value(v_cursorid, 13, l_transaction_rec.Event_Key);
         DBMS_SQL.Column_Value(v_cursorid, 14, l_transaction_rec.Item_Type);
         DBMS_SQL.Column_Value(v_cursorid, 15, l_transaction_rec.Internal_Control_Number);
         DBMS_SQL.Column_Value(v_cursorid, 16, l_transaction_rec.document_revision);
         DBMS_SQL.Column_Value(v_cursorid, 17, l_transaction_rec.Attribute_Category);
         DBMS_SQL.Column_Value(v_cursorid, 18, l_transaction_rec.Attribute1);
         DBMS_SQL.Column_Value(v_cursorid, 19, l_transaction_rec.Attribute2);
         DBMS_SQL.Column_Value(v_cursorid, 20, l_transaction_rec.Attribute3);
         DBMS_SQL.Column_Value(v_cursorid, 21, l_transaction_rec.Attribute4);
         DBMS_SQL.Column_Value(v_cursorid, 22, l_transaction_rec.Attribute5);
         DBMS_SQL.Column_Value(v_cursorid, 23, l_transaction_rec.Attribute6);
         DBMS_SQL.Column_Value(v_cursorid, 24, l_transaction_rec.Attribute7);
         DBMS_SQL.Column_Value(v_cursorid, 25, l_transaction_rec.Attribute8);
         DBMS_SQL.Column_Value(v_cursorid, 26, l_transaction_rec.Attribute9);
         DBMS_SQL.Column_Value(v_cursorid, 27, l_transaction_rec.Attribute10);
         DBMS_SQL.Column_Value(v_cursorid, 28, l_transaction_rec.Attribute11);
         DBMS_SQL.Column_Value(v_cursorid, 29, l_transaction_rec.Attribute12);
         DBMS_SQL.Column_Value(v_cursorid, 30, l_transaction_rec.Attribute13);
         DBMS_SQL.Column_Value(v_cursorid, 31, l_transaction_rec.Attribute14);
         DBMS_SQL.Column_Value(v_cursorid, 32, l_transaction_rec.Attribute15);
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Fetched from cursor successfully');
         END IF;
         --
      END IF;

      l_tmp_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      l_total := l_total + 1;

      IF l_transaction_rec.item_type is not null and
         l_transaction_rec.event_key is not null   --{
      THEN
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Calling wf_engine.handleError', WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --
         WF_ENGINE.handleError(
                  itemType => l_transaction_rec.item_type,
                  itemKey  => l_transaction_rec.event_key,
                  activity => 'WSH_STAND_PROCESS_WF:POPULATE_BASE_TABLES',
                  command  => 'RETRY',
                  result   => NULL );

         OPEN  c_get_status(l_transaction_rec.transaction_id);
         FETCH c_get_status INTO l_trx_status;
         CLOSE c_get_status;

         IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'l_trx_status', l_trx_status);
         END IF;

         IF l_trx_status <> 'SC' THEN
            l_tmp_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         END IF;
      ELSE
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Calling Process_Shipment_Request', WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --
         Process_Shipment_Request(
                  p_transaction_rec => l_transaction_rec,
                  p_commit_flag     => p_commit_flag,
                  x_return_status   => l_tmp_status );

         --
         IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'l_tmp_status', l_tmp_status);
         END IF;
         --
      END IF; --}

      -- API Process_Shipment_Request will return WARNING if its not able to lock tables.
      IF l_tmp_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         l_success := l_success + 1;
      ELSIF l_tmp_status = WSH_UTIL_CORE.G_RET_STS_ERROR
      THEN
         l_errors := l_errors + 1;
      ELSIF l_tmp_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
      THEN
         --
         IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'Unexpected error occurred in Process_Shipment_Request', l_tmp_status);
         END IF;
         --
         raise others;
      END IF;
   END LOOP; --}

   IF p_transaction_id is not null THEN
      IF C_Get_One_Transactions%ISOPEN THEN
         CLOSE C_Get_One_Transactions;
      END IF;
   ELSE
      IF DBMS_SQL.Is_Open(v_cursorid) THEN
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Closing cursor');
         END IF;
         --
         DBMS_SQL.Close_Cursor(v_cursorid);
         v_cursorid := null;
      END IF;
   END IF;

   IF (l_total = l_success) THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   ELSIF (l_total = l_errors) THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   ELSE
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
   END IF;

   -- To Print in Concurrent Request Output File
   IF FND_GLOBAL.Conc_Request_Id > 0 THEN
      FND_FILE.put_line(FND_FILE.output, 'Time taken by OE_ORDER_GRP.Process_Order API alone in secs => ' || g_po_total_time);
      FND_FILE.put_line(FND_FILE.output, '');
      FND_FILE.put_line(FND_FILE.output, 'Summary:-');
      FND_FILE.put_line(FND_FILE.output,'===================================');
      FND_FILE.put_line(FND_FILE.output, 'No. of Shipment Requests selected for processing   => ' || l_total);
      FND_FILE.put_line(FND_FILE.output, 'No. of Shipment Requests processed successfully    => ' || l_success);
      FND_FILE.put_line(FND_FILE.output, 'No. of Shipment Requests errored during processing => ' || l_errors);
   END IF;
   --

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'Return Status from Process_Shipment_Request1', x_return_status);
      WSH_DEBUG_SV.log(l_module_name, 'Time taken by OE_ORDER_GRP.Process_Order API alone', g_po_total_time);
      WSH_DEBUG_SV.logmsg(l_module_name,'');
      WSH_DEBUG_SV.logmsg(l_module_name,'Summary:-');
      WSH_DEBUG_SV.logmsg(l_module_name,'===================================');
      WSH_DEBUG_SV.log(l_module_name,'No. of Shipment Requests selected for processing  ', l_total);
      WSH_DEBUG_SV.log(l_module_name,'No. of Shipment Requests processed successfully   ', l_success);
      WSH_DEBUG_SV.log(l_module_name,'No. of Shipment Requests errored during processing', l_errors);
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      IF p_transaction_id is not null THEN
         IF C_Get_One_Transactions%ISOPEN THEN
            CLOSE C_Get_One_Transactions;
         END IF;
      ELSE
         IF DBMS_SQL.Is_Open(v_cursorid) THEN
            DBMS_SQL.Close_Cursor(v_cursorid);
            v_cursorid := null;
         END IF;
      END IF;
      --
      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         wsh_debug_sv.pop(l_module_name, 'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --

   WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      IF p_transaction_id is not null THEN
         IF C_Get_One_Transactions%ISOPEN THEN
            CLOSE C_Get_One_Transactions;
         END IF;
      ELSE
         IF DBMS_SQL.Is_Open(v_cursorid) THEN
            DBMS_SQL.Close_Cursor(v_cursorid);
            v_cursorid := null;
         END IF;
      END IF;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Process_Shipment_Request;
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Overloaded Process_Shipment_Request
--
-- PARAMETERS:
--       p_transaction_rec => Transaction History Record
--       p_commit_flag     => Either FND_API.G_TRUE, FND_API.G_FALSE
--       x_return_status   => Return Status of API (Either S,E,U)
-- COMMENT:
--       Calls APIs to validate data from Interface tables WNDI(Order Header)
--       and WDDI(Order Lines). Calls OM Process Order Group API
--       OE_ORDER_GRP.Process_Order to Create/Update/Cancel Sales Order.
--       Attributes related to shipping are validated, If PO group api returns
--       success.
--       If PO group api returns error then corresponding error messages are
--       logged in Wsh_Interface_Errors table.
--=============================================================================
--
PROCEDURE Process_Shipment_Request (
          p_transaction_rec      IN  WSH_TRANSACTIONS_HISTORY_PKG.Txns_History_Record_Type,
          p_commit_flag          IN  VARCHAR2,
          x_return_status        OUT NOCOPY VARCHAR2 )
IS

   CURSOR c_open_del_lines(c_line_id NUMBER)
   IS
   select 'x'
   from   oe_order_lines_all oel,
          wsh_delivery_details wdd
   where  oel.open_flag = 'Y'
   and    oel.shipped_quantity is null
   and    oel.line_id = c_line_id
   and    wdd.source_code = 'OE'
   and    wdd.source_line_id = oel.line_id
   and    wdd.released_status in ( 'N','R','S','Y','B','X' );
   --
   -- LSP PROJECT :
   CURSOR c_get_ordertype_org (c_cust_acct_id NUMBER, c_party_site_id NUMBER) IS
     SELECT  su.org_id,su.order_type_id
     FROM
       hz_party_sites ps,
       hz_cust_acct_sites_all ca,
	   hz_cust_site_uses_all su
     WHERE  ps.party_site_id = c_party_site_id
       AND  su.cust_acct_site_id = ca.cust_acct_site_id
       AND  ca.party_site_id = ps.party_site_id
       AND  ca.cust_account_id = c_cust_acct_id;

   l_order_type_id              NUMBER;
   l_payment_term_id            NUMBER;
   l_price_list_id              NUMBER;
   l_header_id                  NUMBER;
   l_line_id                    NUMBER;
   l_org_id                     NUMBER;
   l_msg_count                  NUMBER;
   l_entity_id                  NUMBER;
   l_order_source_id            NUMBER;
   l_source_document_type_id    NUMBER;
   l_source_document_id         NUMBER;
   l_source_document_line_id    NUMBER;
   l_constraint_id              NUMBER;
   l_process_activity           NUMBER;
   l_document_revision          NUMBER;
   l_document_number            NUMBER;
   l_entity_number              NUMBER;
   l_line_number                NUMBER;
   l_po_tot_time                NUMBER;

   l_return_status              VARCHAR2(1);
   l_tmp                        VARCHAR2(10);
   l_standalone_mode            VARCHAR2(1);
   l_currency_code              VARCHAR2(15); -- as per transactional_curr_code in OE_Order_PUB.Header_Rec_Type
   l_temp_currency_code         VARCHAR2(15);
   l_temp_status                VARCHAR2(15);
   l_error_msg                  VARCHAR2(4000);
   l_msg_data                   VARCHAR2(4000);
   l_header_doc_ref             VARCHAR2(50);
   l_line_doc_ref               VARCHAR2(50);
   l_entity_code                VARCHAR2(30);
   l_entity_ref                 VARCHAR2(50);
   l_orig_sys_document_ref      VARCHAR2(50);
   l_orig_sys_document_line_ref VARCHAR2(50);
   l_orig_sys_shipment_ref      VARCHAR2(50);
   l_change_sequence            VARCHAR2(50);
   l_attribute_code             VARCHAR2(30);
   l_notification_flag          VARCHAR2(1);
   l_type                       VARCHAR2(30);

   l_po_start_time              DATE;
   l_po_end_time                DATE;

   l_line_details_tbl           WSH_UTIl_CORE.Id_Tab_Type;
   l_details_marked             WSH_UTIL_CORE.Id_Tab_Type;
   l_txn_history_tbl            WSH_UTIL_CORE.Id_Tab_Type;
   l_upd_txn_history_tbl        WSH_UTIL_CORE.Id_Tab_Type;
   l_entity_number_tbl          WSH_UTIL_CORE.Id_Tab_Type;
   l_del_interface_error_tbl    WSH_UTIL_CORE.Id_Tab_Type;
   l_det_interface_error_tbl    WSH_UTIL_CORE.Id_Tab_Type;
   l_close_line_tbl             WSH_UTIL_CORE.Id_Tab_Type;
   l_delivery_interface_tbl     WSH_UTIL_CORE.Id_Tab_Type;
   l_detail_interface_tbl       WSH_UTIL_CORE.Id_Tab_Type;
   l_del_assgn_interface_tbl    WSH_UTIL_CORE.Id_Tab_Type;
   l_delivery_detail_tab        WSH_UTIL_CORE.Id_Tab_Type;
   l_transaction_rec            WSH_TRANSACTIONS_HISTORY_PKG.Txns_History_Record_Type;

   l_init_om_header_rec         OM_Header_Rec_Type;
   l_om_header_rec              OM_Header_Rec_Type;
   l_om_line_tbl_type           OM_Line_Tbl_Type;
   l_new_del_rec                Del_Interface_Rec_Type;
   l_details_interface_tab      Del_Details_Interface_Rec_Tab;

   l_action_request_tbl         OE_ORDER_PUB.Request_Tbl_Type;
   l_header_rec                 OE_ORDER_PUB.Header_Rec_Type;
   l_header_val_rec             OE_Order_PUB.Header_Val_Rec_Type;
   l_old_header_rec             OE_ORDER_PUB.Header_Rec_Type;
   l_Header_Payment_tbl         OE_ORDER_PUB.Header_Payment_Tbl_Type;
   l_line_tbl                   OE_ORDER_PUB.Line_Tbl_Type;
   l_line_val_tbl               OE_Order_PUB.Line_Val_Tbl_Type;
   l_old_line_tbl               OE_ORDER_PUB.Line_Tbl_Type;
   l_header_customer_info_tbl   OE_ORDER_PUB.Customer_Info_Table_Type;
   l_line_customer_info_tbl     OE_ORDER_PUB.Customer_Info_Table_Type;

   x_header_rec                 OE_ORDER_PUB.Header_Rec_Type;
   x_header_val_rec             OE_ORDER_PUB.Header_Val_Rec_Type;
   x_Header_Adj_tbl             OE_ORDER_PUB.Header_Adj_Tbl_Type;
   x_Header_Adj_val_tbl         OE_ORDER_PUB.Header_Adj_Val_Tbl_Type;
   x_Header_price_Att_tbl       OE_ORDER_PUB.Header_Price_Att_Tbl_Type;
   x_Header_Adj_Att_tbl         OE_ORDER_PUB.Header_Adj_Att_Tbl_Type;
   x_Header_Adj_Assoc_tbl       OE_ORDER_PUB.Header_Adj_Assoc_Tbl_Type;
   x_Header_Scredit_tbl         OE_ORDER_PUB.Header_Scredit_Tbl_Type;
   x_Header_Scredit_val_tbl     OE_ORDER_PUB.Header_Scredit_Val_Tbl_Type;
   x_Header_Payment_tbl         OE_ORDER_PUB.Header_Payment_Tbl_Type;
   x_Header_Payment_val_tbl     OE_ORDER_PUB.Header_Payment_Val_Tbl_Type;
   x_line_tbl                   OE_ORDER_PUB.Line_Tbl_Type;
   x_line_val_tbl               OE_ORDER_PUB.Line_Val_Tbl_Type;
   x_Line_Adj_tbl               OE_ORDER_PUB.Line_Adj_Tbl_Type;
   x_Line_Adj_val_tbl           OE_ORDER_PUB.Line_Adj_Val_Tbl_Type;
   x_Line_price_Att_tbl         OE_ORDER_PUB.Line_Price_Att_Tbl_Type;
   x_Line_Adj_Att_tbl           OE_ORDER_PUB.Line_Adj_Att_Tbl_Type;
   x_Line_Adj_Assoc_tbl         OE_ORDER_PUB.Line_Adj_Assoc_Tbl_Type;
   x_Line_Scredit_tbl           OE_ORDER_PUB.Line_Scredit_Tbl_Type;
   x_Line_Scredit_val_tbl       OE_ORDER_PUB.Line_Scredit_Val_Tbl_Type;
   x_Line_Payment_tbl           OE_ORDER_PUB.Line_Payment_Tbl_Type;
   x_Line_Payment_val_tbl       OE_ORDER_PUB.Line_Payment_Val_Tbl_Type;
   x_Lot_Serial_tbl             OE_ORDER_PUB.Lot_Serial_Tbl_Type;
   x_Lot_Serial_val_tbl         OE_ORDER_PUB.Lot_Serial_Val_Tbl_Type;
   x_action_request_tbl         OE_ORDER_PUB.Request_Tbl_Type;
   l_control_rec                OE_GLOBALS.Control_Rec_Type;

   l_lpn_in_sync_comm_rec       WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_in_rec_type;
   l_lpn_out_sync_comm_rec      WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_out_rec_type;

   interface_error_rec          WSH_INTERFACE_VALIDATIONS_PKG.interface_errors_rec_type;
   interface_error_tab          WSH_INTERFACE_VALIDATIONS_PKG.interface_errors_rec_tab;
   l_dummy                      WSH_UTIL_CORE.Id_Tab_Type;
   -- LSP PROJECT : begin
   l_modify_otm_flag            VARCHAR2(1);
   l_modify_oe_iface_flag       VARCHAR2(1);
   l_client_id                  NUMBER;
   l_client_name                VARCHAR2(200);
   l_client_params              inv_cache.ct_rec_type;
   l_gnore_for_planning         VARCHAR2(1);
   l_gc3_is_installed           VARCHAR2(1);

   -- LSP PROJECT : end
   i                             NUMBER;
   j                             NUMBER;


   RECORD_LOCKED                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RECORD_LOCKED, -54);

   l_debug_on                 BOOLEAN;
   l_module_name CONSTANT     VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Process_Shipment_Request2';
BEGIN
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      wsh_debug_sv.push(l_module_name);
      wsh_debug_sv.log(l_module_name, 'p_commit_flag', p_commit_flag);
      wsh_debug_sv.log(l_module_name, 'transaction_id', p_transaction_rec.transaction_id);
      wsh_debug_sv.log(l_module_name, 'transaction_status', p_transaction_rec.transaction_status);
   END IF;
   --

   l_tmp := null;

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   --
   IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name, 'Calling WMS_DEPLOY.Wms_Deployment_Mode', WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   l_standalone_mode := WMS_DEPLOY.Wms_Deployment_Mode;
   IF g_interface_action_code is null THEN
      IF l_standalone_mode = 'D' THEN
         g_interface_action_code := '94X_STANDALONE';
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Standalone WMS is installed');
         END IF;
      ELSIF l_standalone_mode = 'L' THEN --  LSP PROJECT : Consider LSP mode also
         g_interface_action_code := '94X_STANDALONE';
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Deployment Mode is : LSP ');
         END IF;
      ELSE
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Standalone WMS is not installed');
         END IF;
         --
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   l_transaction_rec := p_transaction_rec;
   l_temp_status    := 'VALID';

   --Initialize OM Header Record with default values
   l_om_header_rec := l_init_om_header_rec;

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, '**** Processing document ' || l_transaction_rec.document_number
                                      || ' with revision ' || l_transaction_rec.document_revision
                                      || ', action type ' || l_transaction_rec.action_type || ' ****' );
   END IF;
   --

   -- To Print in Concurrent Request Output File
   IF FND_GLOBAL.Conc_Request_Id > 0 THEN
      FND_FILE.put_line(FND_FILE.output, '**** Processing document ' || l_transaction_rec.document_number
                                      || ' with revision ' || l_transaction_rec.document_revision
                                      || ', action type ' || l_transaction_rec.action_type || ' ****' );
   END IF;
   --

   --Validating Document Number
   BEGIN
      l_document_number := to_number(l_transaction_rec.document_number);
      IF trunc(l_document_number) <> l_document_number THEN
         RAISE VALUE_ERROR;
      END IF;
   EXCEPTION
      WHEN VALUE_ERROR THEN
         l_temp_status := 'INVALID_HEADER';
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'VALUE_ERROR exception has occured for Document Number', WSH_DEBUG_SV.C_EXCEP_LEVEL);
         END IF;
         --
         FND_MESSAGE.Set_Name('WSH', 'WSH_STND_POSITIVE_INTEGER');
         FND_MESSAGE.Set_Token('ATTRIBUTE', 'DOCUMENT_NUMBER');
         WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_ERROR, l_module_name );
   END;

   --Validating Document Revision
   BEGIN
      l_document_revision := to_number(l_transaction_rec.document_revision);
      IF trunc(l_document_revision) <> l_document_revision THEN
         RAISE VALUE_ERROR;
      END IF;
   EXCEPTION
      WHEN VALUE_ERROR THEN
         l_temp_status := 'INVALID_HEADER';
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'VALUE_ERROR exception has occured for Document Revision', WSH_DEBUG_SV.C_EXCEP_LEVEL);
         END IF;
         --
         FND_MESSAGE.Set_Name('WSH', 'WSH_STND_POSITIVE_INTEGER');
         FND_MESSAGE.Set_Token('ATTRIBUTE', 'DOCUMENT_REVISION');
         WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_ERROR, l_module_name );
   END;

   BEGIN
      l_entity_number := to_number(l_transaction_rec.entity_number);
   EXCEPTION
      WHEN VALUE_ERROR THEN
         l_temp_status := 'INVALID_HEADER';
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'VALUE_ERROR exception has occured for Entity Number => '
                                          || l_transaction_rec.entity_number, WSH_DEBUG_SV.C_EXCEP_LEVEL);
         END IF;
   END;

   --Log error, if validation fails for Document Number/Document Revision/Entity Number
   IF l_temp_status = 'INVALID_HEADER' THEN
      goto loop_end;
   END IF;

   --Lock all transaction history before processing
   BEGIN
      --Lock all transaction history records
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Locking wsh_transactions_history Records');
      END IF;
      --

      SELECT transaction_id, entity_number
      BULK COLLECT INTO l_txn_history_tbl, l_entity_number_tbl
      FROM   wsh_transactions_history
      WHERE  transaction_status in ( 'IP', 'AP', 'ER' )
      AND    document_type = 'SR'
      AND    document_direction = 'I'
      AND    document_revision <= l_transaction_rec.document_revision
      AND    document_number = l_transaction_rec.document_number
      order by document_revision
      for update nowait;

      --Lock all delivery interface records
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Locked '||SQL%ROWCOUNT||' wsh_transactions_history Records');
         WSH_DEBUG_SV.logmsg(l_module_name, 'Locking wsh_new_del_interface Records');
      END IF;
      --

      SELECT wndi.delivery_interface_id
      BULK COLLECT INTO l_delivery_interface_tbl
      FROM   Wsh_New_Del_Interface wndi,
             Wsh_Transactions_History wth
      WHERE  wndi.interface_action_code = g_interface_action_code
      AND    wndi.delivery_interface_id = to_number(wth.entity_number)
      AND    wth.transaction_status in ( 'IP', 'AP', 'ER' )
      AND    wth.document_type = 'SR'
      AND    wth.document_direction = 'I'
      AND    wth.document_revision <= l_transaction_rec.document_revision
      AND    wth.document_number = l_transaction_rec.document_number
      for update of wndi.delivery_interface_id nowait;

      --Lock all delivery detail interface records
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Locked '||SQL%ROWCOUNT||' wsh_new_del_interface Records');
         WSH_DEBUG_SV.logmsg(l_module_name, 'Locking wsh_del_details_interface, wsh_del_assgn_interface Records');
      END IF;
      --

      SELECT wddi.delivery_detail_interface_id, wdai.del_assgn_interface_id
      BULK COLLECT INTO l_detail_interface_tbl, l_del_assgn_interface_tbl
      FROM   Wsh_Del_Details_Interface wddi,
             Wsh_Del_Assgn_Interface   wdai,
             Wsh_Transactions_History wth
      WHERE  wddi.interface_action_code = g_interface_action_code
      AND    wdai.interface_action_code = g_interface_action_code
      AND    wddi.delivery_detail_interface_id = wdai.delivery_detail_interface_id
      AND    wdai.delivery_interface_id = wth.entity_number
      AND    wth.transaction_status in ( 'IP', 'AP', 'ER' )
      AND    wth.document_type = 'SR'
      AND    wth.document_direction = 'I'
      AND    wth.document_revision <= l_transaction_rec.document_revision
      AND    wth.document_number = l_transaction_rec.document_number
      for update of wddi.delivery_detail_interface_id, wdai.del_assgn_interface_id nowait;

      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Locked '||SQL%ROWCOUNT||' wsh_del_details_interface, wsh_del_assgn_interface Records');
         WSH_DEBUG_SV.logmsg(l_module_name, 'Locking wsh_interface_errors Records (For Delivery Interface)');
      END IF;
      --

      SELECT wie.interface_error_id
      BULK COLLECT INTO l_del_interface_error_tbl
      FROM   wsh_interface_errors wie,
             wsh_transactions_history wth
      WHERE  wie.interface_table_name = 'WSH_NEW_DEL_INTERFACE'
      AND    wie.interface_action_code = g_interface_action_code
      AND    wth.transaction_status in ( 'IP', 'AP', 'ER' )
      AND    wth.document_type = 'SR'
      AND    wth.document_direction = 'I'
      AND    wth.document_revision <= l_transaction_rec.document_revision
      AND    wth.document_number = l_transaction_rec.document_number
      AND    wie.interface_id = to_number(wth.entity_number)
      FOR UPDATE NOWAIT;

      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Locked '||SQL%ROWCOUNT||' wsh_interface_errors Records (For Delivery Interface)');
         WSH_DEBUG_SV.logmsg(l_module_name, 'Locking wsh_interface_errors Records (For Detail Interface)');
      END IF;
      --

      SELECT wie.interface_error_id
      BULK COLLECT INTO l_det_interface_error_tbl
      FROM   wsh_interface_errors wie
      WHERE  interface_table_name = 'WSH_DEL_DETAILS_INTERFACE'
      AND    interface_action_code = g_interface_action_code
      AND    interface_id in
           ( select wddi.delivery_detail_interface_id
             FROM   Wsh_Del_Details_Interface wddi,
                    Wsh_Del_Assgn_Interface wdai,
                    wsh_transactions_history wth
             WHERE  wddi.interface_action_code = g_interface_action_code
             AND    wdai.interface_action_code = g_interface_action_code
             AND    wddi.delivery_detail_interface_id = wdai.delivery_detail_interface_id
             AND    wth.transaction_status in ( 'IP', 'AP', 'ER' )
             AND    wth.document_type = 'SR'
             AND    wth.document_direction = 'I'
             AND    wth.document_revision <= l_transaction_rec.document_revision
             AND    wth.document_number = l_transaction_rec.document_number
             AND    wdai.delivery_interface_id = to_number(wth.entity_number) )
      FOR UPDATE NOWAIT;

      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Locked '||SQL%ROWCOUNT||' wsh_interface_errors Records (For Detail Interface)');
      END IF;

   EXCEPTION
     WHEN RECORD_LOCKED THEN
       l_temp_status := 'NO_LOCK';
       --
       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'RECORD_LOCKED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
       END IF;
       --
       goto loop_end;
   END;

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'Calling Get_Standalone_Defaults', WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   Get_Standalone_Defaults (
                  p_delivery_interface_id  => l_entity_number,
                  x_delivery_interface_rec => l_new_del_rec,
                  x_return_status          => l_return_status );

   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Error occured in Get_Standalone_Defaults => ' || l_return_status, WSH_DEBUG_SV.C_ERR_LEVEL);
      END IF;
      --
      l_temp_status := 'INVALID_HEADER';
      goto loop_end;
   END IF;

   --
   -- LSP PROJECT : validate client code and get default parameter values for the client.
   IF l_debug_on THEN
       wsh_debug_sv.log(l_module_name, 'client_code', l_new_del_rec.client_code);
       wsh_debug_sv.log(l_module_name, 'l_standalone_mode', l_standalone_mode);
   END IF;
   l_client_id := NULL;
   IF l_standalone_mode = 'L' THEN
   --{ LSP check
     IF ( l_new_del_rec.client_code IS NOT NULL ) THEN
     --{ client validation
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WMS_DEPLOY.GET_CLIENT_DETAILS',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       wms_deploy.get_client_details(
           x_client_id     => l_client_id,
           x_client_name   => l_client_name,
           x_client_code   => l_new_del_rec.client_code,
           x_return_status => l_return_status);
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'ClientId:'||l_client_id||','||'ClientName:'||l_client_name||','||'Return status:'||l_return_status);
       END IF;
       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       --{
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Error occured in WMS_DEPLOY.GET_CLIENT_DETAILS');
           END IF;
           l_temp_status := 'INVALID_HEADER';
           FND_MESSAGE.Set_Name('WSH', 'WSH_OI_INVALID_ATTRIBUTE');
           FND_MESSAGE.SET_TOKEN('ATTRIBUTE','CLIENT_CODE');
           WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_ERROR, l_module_name );
           GOTO loop_end;
       --}
       END IF;
       -- Call client setup API to return all client default parameter values.
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'Calling INV_CACHE.GET_CLIENT_DEFAULT_PARAMETERS', WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       inv_cache.get_client_default_parameters (
           p_client_id             => l_client_id,
           x_client_parameters_rec => l_client_params,
           x_return_status         => l_return_status);
       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Error occured in get_client_default_parameters => ' || l_return_status, WSH_DEBUG_SV.C_ERR_LEVEL);
           END IF;
           l_temp_status := 'INVALID_HEADER';
           FND_MESSAGE.Set_Name('WSH', 'WSH_OI_INVALID_ATTRIBUTE');
           FND_MESSAGE.SET_TOKEN('ATTRIBUTE','CLIENT_DEFAULTS');
           WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_ERROR, l_module_name );
           GOTO loop_end;
       END IF;
       l_org_id        := NULL;
       l_order_type_id := NULL;
       -- get the order type id for the given OU Id.
       OPEN c_get_ordertype_org(l_client_id,l_client_params.client_rec.trading_partner_site_id);
       FETCH c_get_ordertype_org INTO l_org_id,l_order_type_id;
       CLOSE c_get_ordertype_org;
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Client order type => ' || l_order_type_id
                                     || ', Operating Unit => ' || l_org_id);
       END IF;
       --
       -- Populate Operating Unit ID value.
       l_new_del_rec.org_id := l_org_id;
       -- Get Order Type info from client parameters.
       IF ( l_new_del_rec.transaction_type_id IS NULL ) THEN
           l_new_del_rec.transaction_type_id := l_order_type_id;
       END IF;
     ELSE
       IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Error occured in get_client_default_parameters => ' || l_return_status, WSH_DEBUG_SV.C_ERR_LEVEL);
       END IF;
       l_temp_status := 'INVALID_HEADER';
       FND_MESSAGE.Set_Name('WSH', 'WSH_STND_ATTR_MANDATORY');
       FND_MESSAGE.Set_Token('ATTRIBUTE', 'CLIENT_CODE');
       WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_ERROR, l_module_name );
       GOTO loop_end;
     --} client validation.
     END IF;
   --} LSP check
   END IF;
   -- LSP PROJECT : End.
   --
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'Calling WSH_CUSTOM_PUB.Get_Standalone_WMS_Defaults', WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   WSH_CUSTOM_PUB.Get_Standalone_WMS_Defaults (
                  p_transaction_id   => l_transaction_rec.transaction_id,
                  x_order_type_id    => l_order_type_id,
                  x_price_list_id    => l_price_list_id,
                  x_payment_term_id  => l_payment_term_id,
                  x_currency_code    => l_currency_code );
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Custom: Order Type Id => ' || l_order_type_id
                                || ', Price List Id => ' || l_price_list_id
                                || ', Payment Term Id => ' || l_payment_term_id
                                || ', Operating Unit => ' || l_new_del_rec.org_id
                                || ', Currency Code => ' || l_currency_code );
   END IF;
   --

   l_order_type_id   := nvl(l_new_del_rec.transaction_type_id, l_order_type_id);
   l_price_list_id   := nvl(l_new_del_rec.price_list_id, l_price_list_id);
   l_currency_code   := nvl(l_new_del_rec.currency_code, l_currency_code);
   l_org_id          := l_new_del_rec.org_id;


   IF l_payment_term_id is null THEN
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Setting seeded value for payment term');
      END IF;
      --
      l_payment_term_id := 4; --Seeded value '30 NET'
   END IF;

   -- LSP PROJECT : price list name currency code can be NULL in case of LSP mode.
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Final Values for: Order Type Id => ' || l_order_type_id
                                || ', Price List Id => ' || l_price_list_id
                                || ', Payment Term Id => ' || l_payment_term_id
                                || ', Operating Unit => ' || l_org_id
                                || ', Currency Code => ' || l_currency_code );
   END IF;
   --

   IF ( l_order_type_id is null OR
        (l_price_list_id is null AND l_new_del_rec.client_code IS NULL) OR
         l_currency_code is null OR
         l_org_id is null )
   THEN
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Error: Some or all of Order Type/Price List/Org Id are not set');
      END IF;
      --
      l_temp_status := 'INVALID_HEADER';
      FND_MESSAGE.Set_Name('WSH', 'WSH_STND_ERROR');
      WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_ERROR, l_module_name );
      goto loop_end;
   END IF;

   --Validate Currency Code
   BEGIN
      SELECT distinct currency_code
      INTO   l_temp_currency_code
      FROM   Wsh_Del_Details_Interface wddi,
             Wsh_Del_Assgn_Interface wdai
      WHERE  wddi.interface_action_code = g_interface_action_code
      AND    wdai.interface_action_code = g_interface_action_code
      AND    wddi.currency_code is not null
      AND    wddi.delivery_detail_interface_id = wdai.delivery_detail_interface_id
      AND    wdai.delivery_interface_id = l_entity_number;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_temp_currency_code := l_currency_code;

      WHEN TOO_MANY_ROWS THEN
         l_temp_status := 'INVALID_HEADER';
         FND_MESSAGE.Set_Name('WSH', 'WSH_STND_CURRENCY_CODE');
         WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_ERROR, l_module_name );
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'Error: Shipment Request has lines with more than 1 Currency Code');
         END IF;
         --
         goto loop_end;
   END;

   IF l_currency_code <> l_temp_currency_code THEN
      l_temp_status := 'INVALID_HEADER';
      FND_MESSAGE.Set_Name('WSH', 'WSH_STND_CURRENCY_MISMATCH');
      FND_MESSAGE.Set_Token('CUR_CODE_HDR', l_currency_code);
      FND_MESSAGE.Set_Token('CUR_CODE_LINES', l_temp_currency_code);
      WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_ERROR, l_module_name );
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'Error: Shipment Request has lines with more than 1 Currency Code');
      END IF;
      --
      goto loop_end;
   END IF;

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'Currency Code', l_currency_code);
   END IF;
   --

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'Calling Check_Header_Exists', WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --

   Check_Header_Exists (
         p_order_number       => l_document_number,
         p_order_type_id      => l_order_type_id,
         x_om_header_rec_type => l_om_header_rec,
         x_return_status      => l_return_status);

   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Header Id=> ' || l_om_header_rec.header_id
                               || ', Header Version No=> ' || l_om_header_rec.version_number
                               || ', Transaction Version No=> '|| l_document_revision);
   END IF;
   --
   l_header_id := l_om_header_rec.header_id;

   IF l_header_id is not null THEN -- {

      IF l_transaction_rec.action_type = 'A' THEN
         FND_MESSAGE.Set_Name('WSH', 'WSH_STND_HEADER_EXISTS');
         FND_MESSAGE.Set_Token('DOCUMENT_NUMBER', l_document_number);
         WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_ERROR, l_module_name );
         l_temp_status := 'INVALID_HEADER';
         --
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'Error: Shipment Request already exist for same document number and revision');
         END IF;
         --
         goto loop_end;
      ELSIF  l_om_header_rec.open_flag = 'N' THEN
         FND_MESSAGE.Set_Name('WSH', 'WSH_STND_HEADER_CLOSED');
         FND_MESSAGE.Set_Token('DOCUMENT_NUMBER', l_document_number);
         WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_ERROR, l_module_name );
         l_temp_status := 'INVALID_HEADER';
         --
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'Error: Shipment Request is already closed');
         END IF;
         --
         goto loop_end;
      ELSIF  l_om_header_rec.version_number >= l_document_revision
      THEN
         FND_MESSAGE.Set_Name('WSH', 'WSH_STND_INVALID_REVISION');
         FND_MESSAGE.Set_Token('DOCUMENT_REVISION', l_document_revision);
         WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_ERROR, l_module_name );
         l_temp_status := 'INVALID_HEADER';
         --
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'Error: Shipment Request with higher revision is already processed');
         END IF;
         --
         goto loop_end;
      ELSE
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Calling Lock_SR_Lines to lock interface records', WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --
         Lock_SR_Lines(
              p_header_id             => l_header_id,
              p_delivery_interface_id => l_entity_number,
              p_interface_records     => 'Y',
              x_return_status         => l_return_status );

         IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS )
         THEN
            l_temp_status := 'NO_LOCK';
            goto loop_end;
         END IF;
      END IF;

   ELSIF l_header_id is null and l_transaction_rec.action_type = 'D'
   THEN
      --dont error out, update the transaction history to SC
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Order Header does not exists for this Shipment Request,'
                                       || ' so updating the Transaction history status to SC');
      END IF;
      --
      IF l_txn_history_tbl.count > 0 THEN
         FORALL i in l_txn_history_tbl.FIRST..l_txn_history_tbl.LAST
            UPDATE wsh_transactions_history
            SET    transaction_status     = 'SC',
                   program_application_id = FND_GLOBAL.Prog_Appl_Id,
                   program_id             = FND_GLOBAL.Conc_Program_Id,
                   request_id             = FND_GLOBAL.Conc_Request_Id,
                   program_update_date    = sysdate,
                   last_updated_by        = FND_GLOBAL.User_Id,
                   last_update_date       = sysdate,
                   last_update_login      = FND_GLOBAL.Login_Id
            WHERE  transaction_id = l_txn_history_tbl(i);

            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, sql%rowcount || ' row(s) updated in wsh_transactions_history');
            END IF;
            --
      END IF;

      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'Calling WSH_CUSTOM_PUB.Post_Process_Shipment_Request', WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      --Call Custom API
      WSH_CUSTOM_PUB.Post_Process_Shipment_Request(
                     p_transaction_id => l_transaction_rec.transaction_id,
                     x_return_status  => l_return_status );

      IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Error occured in WSH_CUSTOM_PUB.Post_Process_Shipment_Request', WSH_DEBUG_SV.C_ERR_LEVEL);
         END IF;
         --
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'Calling WSH_PROCESS_INTERFACED_PKG.Delete_Interface_Records', WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

      WSH_PROCESS_INTERFACED_PKG.Delete_Interface_Records (
         p_del_interface_id_tbl       => l_delivery_interface_tbl,
         p_del_det_interface_id_tbl   => l_detail_interface_tbl,
         p_del_assgn_interface_id_tbl => l_del_assgn_interface_tbl,
         p_del_error_interface_id_tbl => l_del_interface_error_tbl,
         p_det_error_interface_id_tbl => l_det_interface_error_tbl,
         x_return_status              => l_return_status);

      IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Error occured in Delete_Interface_Records => ' || l_return_status, WSH_DEBUG_SV.C_ERR_LEVEL);
         END IF;
         --
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      goto loop_end;
   END IF; --}

   IF l_transaction_rec.action_type in ( 'A', 'C' ) THEN
      -- Setting Org Id before calling Derive_Header_Rec so that APIs in OM
      -- Package OE_Value_To_Id does not fail.
      MO_GLOBAL.Set_Policy_Context('S', l_org_id);
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Calling Derive_Header_Rec', WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      Derive_Header_Rec(
             p_om_header_rec         => l_om_header_rec,
             x_del_interface_rec     => l_new_del_rec,
             x_return_status         => l_return_status );

      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Error occured in Derive_Header_Rec => ' || l_return_status, WSH_DEBUG_SV.C_ERR_LEVEL);
         END IF;
         --
         l_temp_status := 'INVALID_HEADER';
         goto loop_end;
      END IF;
   END IF;

   l_new_del_rec.document_revision := l_document_revision;
   l_new_del_rec.order_number      := l_document_number;
   l_new_del_rec.org_id            := l_org_id;
   l_om_header_rec.order_type_id   := l_order_type_id;
   l_om_header_rec.price_list_id   := l_price_list_id;
   l_om_header_rec.payment_term_id := l_payment_term_id;
   l_om_header_rec.org_id          := l_org_id;
   l_om_header_rec.currency_code   := l_currency_code;

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'Calling Populate_Header_Rec', WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   Populate_Header_Rec(
          p_action_type           => l_transaction_rec.action_type,
          p_om_header_rec         => l_om_header_rec,
          p_del_interface_rec     => l_new_del_rec,
          x_header_rec            => l_header_rec,
          x_return_status         => l_return_status );

   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Error occured in Populate_Header_Rec => ' || l_return_status, WSH_DEBUG_SV.C_ERR_LEVEL);
      END IF;
      --
      l_temp_status := 'INVALID_HEADER';
      goto loop_end;
   END IF;

   --If its new Shipment Request setting action_request_table to book sales order.
   IF nvl(l_header_rec.header_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN
      l_action_request_tbl(1).request_type    := OE_GLOBALS.G_BOOK_ORDER;
      l_action_request_tbl(1).entity_code     := OE_GLOBALS.G_ENTITY_HEADER;
   END IF;

   l_header_doc_ref := l_header_rec.orig_sys_document_ref;

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'Populated header record');
   END IF;
   --

   IF l_transaction_rec.action_type in ( 'A', 'C' )
   THEN -- { Action Add/Change
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Calling Derive_Line_Rec', WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      Derive_Line_Rec(
             p_header_id                 => l_header_id,
             p_del_interface_rec         => l_new_del_rec,
             x_om_line_tbl_type          => l_om_line_tbl_type,
             x_details_interface_rec_tab => l_details_interface_tab,
             x_interface_error_tab       => interface_error_tab,
             x_return_status             => l_return_status );

      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Error occured in Derive_Line_Rec => ' || l_return_status, WSH_DEBUG_SV.C_ERR_LEVEL);
         END IF;
         --
         l_temp_status := 'INVALID';
         goto loop_end;
      END IF;

      IF l_om_header_rec.header_attributes_changed THEN
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Header Attributes has changed');
            WSH_DEBUG_SV.logmsg(l_module_name, 'Calling Lock_SR_Lines to lock non-interface records', WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --
         Lock_SR_Lines(
            p_header_id             => l_header_id,
            p_delivery_interface_id => l_entity_number,
            p_interface_records     => 'N',
            x_return_status         => l_return_status );

         IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS )
         THEN
            l_temp_status := 'NO_LOCK';
            goto loop_end;
         END IF;
      END IF;

      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Calling Populate_Line_Records', WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      Populate_Line_Records(
             p_om_line_tbl_type          => l_om_line_tbl_type,
             p_details_interface_rec_tab => l_details_interface_tab,
             p_om_header_rec_type        => l_om_header_rec,
             p_delivery_interface_rec    => l_new_del_rec,
             x_line_tbl                  => l_line_tbl,
             x_line_details_tbl          => l_line_details_tbl,
             x_return_status             => l_return_status );

      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Error occured in Populate_Line_Records', WSH_DEBUG_SV.C_ERR_LEVEL);
         END IF;
         --
         l_temp_status := 'INVALID';
         goto loop_end;
      END IF;

      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Calling Populate_OM_Common_Attr', WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --

      Populate_OM_Common_Attr(
          p_om_header_rec     => l_om_header_rec,
          p_del_interface_rec => l_new_del_rec,
          x_header_rec        => l_header_rec,
          x_line_tbl          => l_line_tbl,
          x_customer_info     => l_header_customer_info_tbl,
          x_return_status     => l_return_status );

      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Error occurred in Populate_OM_Common_Attr', WSH_DEBUG_SV.C_ERR_LEVEL);
         END IF;
         --
         l_temp_status := 'INVALID';
         goto loop_end;
      END IF;

      IF l_om_header_rec.ship_to_changed or
         l_om_header_rec.invoice_to_changed or
         l_om_header_rec.deliver_to_changed or
         l_om_header_rec.ship_to_contact_changed or
         l_om_header_rec.invoice_to_contact_changed or
         l_om_header_rec.deliver_to_contact_changed
      THEN
         l_line_customer_info_tbl := l_header_customer_info_tbl;
      END IF;

      --Check if atleast one order line exists before calling Process Order API
      IF l_line_tbl.count = 0 THEN
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Error: No order lines to process for action Add/Change');
         END IF;
         --
         l_temp_status := 'INVALID_HEADER';
         FND_MESSAGE.Set_Name('WSH', 'WSH_STND_LINE_MISSING');
         WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_ERROR, l_module_name );
         goto loop_end;
      ELSE
         FOR i in l_line_tbl.first..l_line_tbl.last
         LOOP
            l_line_val_tbl(i) := OE_ORDER_PUB.G_MISS_LINE_VAL_REC;
         END LOOP;
      END IF;
   END IF; -- } Action Add/Change

   -- Setting controlled_operation and process_partial to TRUE, so that
   -- process order api can validate all the lines, even if validation
   -- fails for any one line.
   -- Process Order Public API does not accecpt l_control_rec parameter,
   -- so Shipping has to call Process Order Group API(which acceps p_control_rec parameter)
   l_control_rec.controlled_operation := TRUE;
   l_control_rec.process_partial      := TRUE;
   l_header_val_rec                   := OE_ORDER_PUB.G_MISS_HEADER_VAL_REC;

   l_line_doc_ref := 'SHIPMENT_REQUEST_LINE';

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'Calling MO_GLOBAL.Set_Policy_Context with org_id '||l_org_id);
   END IF;
   --
   MO_GLOBAL.init('ONT'); -- 1/2/2009 => Added this for integration testing after discussing with Srihari Mani
   MO_GLOBAL.Set_Policy_Context('S', l_org_id);

   --Setting value for G_MODE to 'STANDALONE', so that intermediate COMMIT does
   --not happen in WSH_MAP_LOCATION_REGION_PKG.Rule_Location
   WSH_MAP_LOCATION_REGION_PKG.G_MODE := 'STANDALONE';

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'Calling Print_OE_Header_Record', WSH_DEBUG_SV.C_PROC_LEVEL);
      Print_OE_Header_Record(
               p_header_rec         => l_header_rec,
               p_header_val_rec     => l_header_val_rec,
               p_customer_info      => l_header_customer_info_tbl,
               p_action_request_tbl => l_action_request_tbl);


      IF l_transaction_rec.action_type in ('A','C') THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Calling Print_OE_Line_Record', WSH_DEBUG_SV.C_PROC_LEVEL);
         Print_OE_Line_Record(
                  p_line_tbl     => l_line_tbl,
                  p_line_val_tbl => l_line_val_tbl );
      END IF;
   END IF;
   --

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'Calling OE_ORDER_GRP.Process_Order '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));
   END IF;
   --

   l_po_start_time := sysdate;

   -- Calling Group API instead of Public API after discussing with OM team
   OE_ORDER_GRP.Process_Order (
                p_api_version_number       => 1,
                p_init_msg_list            => FND_API.G_TRUE,
                p_return_values            => FND_API.G_TRUE,
                p_commit                   => FND_API.G_FALSE,
                x_return_status            => l_return_status,
                x_msg_count                => l_msg_count,
                x_msg_data                 => l_msg_data,
                p_action_request_tbl       => l_action_request_tbl,
                p_header_rec               => l_header_rec,
                p_header_val_rec           => l_header_val_rec,
                p_old_header_rec           => l_old_header_rec,
                p_Header_Payment_tbl       => l_Header_Payment_tbl,
                p_line_tbl                 => l_line_tbl,
                p_line_val_tbl             => l_line_val_tbl,
                p_old_line_tbl             => l_old_line_tbl,
                x_header_rec               => x_header_rec,
                x_header_val_rec           => x_header_val_rec,
                x_Header_Adj_tbl           => x_Header_Adj_tbl,
                x_Header_Adj_val_tbl       => x_Header_Adj_val_tbl,
                x_Header_price_Att_tbl     => x_Header_Price_Att_Tbl,
                x_Header_Adj_Att_tbl       => x_Header_Adj_Att_Tbl,
                x_Header_Adj_Assoc_tbl     => x_Header_Adj_Assoc_Tbl,
                x_Header_Scredit_tbl       => x_Header_Scredit_Tbl,
                x_Header_Scredit_val_tbl   => x_Header_Scredit_Val_Tbl,
                x_Header_Payment_tbl       => x_Header_Payment_tbl,
                x_Header_Payment_val_tbl   => x_Header_Payment_val_tbl,
                x_line_tbl                 => x_Line_Tbl,
                x_line_val_tbl             => x_Line_Val_Tbl,
                x_Line_Adj_tbl             => x_Line_Adj_Tbl,
                x_Line_Adj_val_tbl         => x_Line_Adj_Val_Tbl,
                x_Line_price_Att_tbl       => x_Line_Price_Att_Tbl,
                x_Line_Adj_Att_tbl         => x_Line_Adj_Att_Tbl,
                x_Line_Adj_Assoc_tbl       => x_Line_Adj_Assoc_Tbl,
                x_Line_Scredit_tbl         => x_Line_Scredit_Tbl,
                x_Line_Scredit_val_tbl     => x_Line_Scredit_Val_Tbl,
                x_Line_Payment_tbl         => x_Line_Payment_tbl,
                x_Line_Payment_val_tbl     => x_Line_Payment_val_tbl,
                x_Lot_Serial_tbl           => x_Lot_Serial_Tbl,
                x_Lot_Serial_val_tbl       => x_Lot_Serial_Val_Tbl,
                x_action_request_tbl       => x_action_request_tbl,
                p_header_customer_info_tbl => l_header_customer_info_tbl,
                p_line_customer_info_tbl   => l_line_customer_info_tbl,
                p_control_rec              => l_control_rec );

   --Setting value for G_MODE back to 'NORMAL'
   WSH_MAP_LOCATION_REGION_PKG.G_MODE := 'NORMAL';
   l_po_end_time := SYSDATE;
   l_po_tot_time := ( l_po_end_time - l_po_start_time ) * 24 * 60 * 60;
   g_po_total_time := g_po_total_time + l_po_tot_time;

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'Return Status after OE_ORDER_GRP.Process_Order => '
                           || l_return_status || ' : ' || to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));
      WSH_DEBUG_SV.log(l_module_name, 'Time taken by OE_ORDER_GRP.Process_Order in secs', l_po_tot_time);
   END IF;
   --

   IF x_action_request_tbl.count > 0 THEN
      FOR i in x_action_request_tbl.first..x_action_request_tbl.last
      LOOP
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Request Type: ' || x_action_request_tbl(i).request_type ||
                               ', Entity_code: ' || x_action_request_tbl(i).entity_code ||
                               ', Return_status: ' || x_action_request_tbl(i).return_status);
         END IF;
         --

         IF x_action_request_tbl(1).request_type = OE_GLOBALS.G_BOOK_ORDER and
            x_action_request_tbl(1).entity_code  = OE_GLOBALS.G_ENTITY_HEADER and
            x_action_request_tbl(i).return_status <> 'S'
         THEN
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'ACTION REQUEST "' || x_action_request_tbl(1).request_type
                          || '" HAS ERRORED IN PO API, SO SET THE OVERALL RETURN STATUS AS ERROR');
            END IF;
            --
            l_return_status := 'E';
         END IF;
      END LOOP;
   END IF;

   IF l_return_status = 'S' --{
   THEN
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'Sales order created/updated/cancelled ', x_header_rec.order_number );
         WSH_DEBUG_SV.log(l_module_name, 'Header Id', x_header_rec.header_id);
         WSH_DEBUG_SV.log(l_module_name, 'Line Table count', x_line_tbl.count);

         IF x_line_tbl.count > 0 THEN
            FOR i in x_line_tbl.first..x_line_tbl.last
            LOOP
               WSH_DEBUG_SV.logmsg(l_module_name, 'Line Id => ' || x_line_tbl(i).line_id ||
                                        ', Line Number =>  ' || x_line_tbl(i).line_number ||
                                        ', Flow Status Code => ' || x_line_tbl(i).flow_status_code);
            END LOOP;
         END IF;
         WSH_DEBUG_SV.log(l_module_name, 'l_details_interface_tab.count', l_details_interface_tab.count );
      END IF;
      --

      IF l_details_interface_tab.count > 0 THEN -- {
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Calling Validate_Interface_Details', WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --
         Validate_Interface_Details(
               p_details_interface_tab => l_details_interface_tab,
               x_interface_error_tab   => interface_error_tab,
               x_return_status         => l_return_status );

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Error occured in Validate_Interface_Details', WSH_DEBUG_SV.C_ERR_LEVEL);
            END IF;
            --
            l_temp_status := 'INVALID';
            goto loop_end;
         END IF;
         --
         -- LSP PROJECT : Needs to populate include for planning value for new shipment request and
         --          if the request is having client information.
         l_modify_otm_flag      := 'N';
         l_modify_oe_iface_flag := 'N';
         IF (l_transaction_rec.action_type = 'A' AND l_client_id IS NOT NULL ) THEN
         --{
             l_modify_oe_iface_flag := 'Y'; --Need to update oe_interfaced_flag value to 'X' (om interface is not required).
             --
             l_modify_otm_flag      := 'Y'; --Need to update ignore for planning value.
             l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED;
             IF l_gc3_is_installed IS NULL THEN
                 l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED;
             END IF;
	         IF l_debug_on THEN
	             wsh_debug_sv.log(l_module_name,'l_gc3_is_installed ',l_gc3_is_installed);
                 wsh_debug_sv.log(l_module_name,'otm_enabled ',l_client_params.client_rec.otm_enabled);
             END IF;
             -- needs to populate include for planning when Client is OTM enabled.
             IF l_client_params.client_rec.otm_enabled = 'Y' AND l_gc3_is_installed = 'Y' THEN
                 l_gnore_for_planning := 'N';
             ELSE
                 l_gnore_for_planning := 'Y';
             END IF;
         ELSE
             l_modify_otm_flag := 'N'; --Should not update ignore for planning value.
         --}
         END IF;
         IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'l_modify_otm_flag:'||l_modify_otm_flag||','||'l_gnore_for_planning:'||l_gnore_for_planning);
             WSH_DEBUG_SV.log(l_module_name,'l_modify_oe_iface_flag:'||l_modify_oe_iface_flag);
         END IF;
         -- LSP PROJECT end.
         --
         FOR i IN l_details_interface_tab.first..l_details_interface_tab.last
         LOOP
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Delivery_Detail_Interface_Id => ' || l_details_interface_tab(i).delivery_detail_interface_id
                                    || ', Line Id => ' || l_details_interface_tab(i).line_id );
            END IF;
            --

            -- Do not proceed further, if line is getting cancelled completely
            IF l_details_interface_tab(i).requested_quantity = 0 THEN
               --
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name, 'Line Number ' || l_details_interface_tab(i).line_number
                               || ' is cancelled, so not proceeding further......' );
               END IF;
               --
               goto end_loop;
            END IF;

            IF nvl(l_details_interface_tab(i).line_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM and
               x_line_tbl.count > 0
            THEN
               FOR j in x_line_tbl.first..x_line_tbl.last
               LOOP
                  IF x_line_tbl(j).line_number = l_details_interface_tab(i).line_number THEN
                     l_details_interface_tab(i).line_id := x_line_tbl(j).line_id;
                     EXIT;
                  END IF;
               END LOOP;

               --
               IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name, 'After loop, Details Interface Line Id', l_details_interface_tab(i).line_id );
               END IF;
               --
            END IF;
            --
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name, 'changed_flag', l_details_interface_tab(i).changed_flag );
               WSH_DEBUG_SV.log(l_module_name, 'schedule_date_changed', l_details_interface_tab(i).schedule_date_changed );
            END IF;
            --

            IF l_details_interface_tab(i).changed_flag = 'Y' THEN
               --Call WSH_DELIVERY_DETAILS_PKG.Update_Delivery_Details api instead of updating WDD directly.
               UPDATE wsh_delivery_details
               SET    reference_number            = l_details_interface_tab(i).source_header_number,
                      reference_line_number       = l_details_interface_tab(i).source_line_number,
                      reference_line_quantity     = l_details_interface_tab(i).src_requested_quantity,
                      reference_line_quantity_uom = l_details_interface_tab(i).src_requested_quantity_uom,
                      original_lot_number         = l_details_interface_tab(i).lot_number,
                      original_revision           = l_details_interface_tab(i).revision,
                      original_locator_id         = l_details_interface_tab(i).locator_id,
                      lot_number                  = l_details_interface_tab(i).lot_number,
                      revision                    = l_details_interface_tab(i).revision,
                      locator_id                  = l_details_interface_tab(i).locator_id,
                      earliest_pickup_date        = l_details_interface_tab(i).earliest_pickup_date,
                      latest_pickup_date          = l_details_interface_tab(i).latest_pickup_date,
                      earliest_dropoff_date       = l_details_interface_tab(i).earliest_dropoff_date,
                      latest_dropoff_date         = l_details_interface_tab(i).latest_dropoff_date,
                      -- LSP PROJECT
                      client_id                   = DECODE(l_transaction_rec.action_type,'A',l_client_id,client_id),
                      ignore_for_planning         = DECODE(l_modify_otm_flag,'Y',l_gnore_for_planning,ignore_for_planning),
                      oe_interfaced_flag          = DECODE(l_modify_oe_iface_flag,'Y','X',oe_interfaced_flag),
                      -- LSP PROJECT
                      last_update_date            = sysdate,
                      last_updated_by             = FND_GLOBAL.User_Id,
                      program_application_id      = FND_GLOBAL.Prog_Appl_Id,
                      program_id                  = FND_GLOBAL.Conc_Program_Id,
                      request_id                  = FND_GLOBAL.Conc_Request_Id,
                      program_update_date         = sysdate
               WHERE  source_code = 'OE'
               AND    source_line_id = l_details_interface_tab(i).line_id
               RETURNING delivery_detail_id BULK COLLECT INTO l_delivery_detail_tab;

               --
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name, sql%rowcount || ' row(s) updated for Line Id =>' || l_details_interface_tab(i).line_id);
               END IF;
               --
               -- Modified code while fixing bug 8452056.
               -- OM Process Order API will return Success even if shipping fails to
               -- create delivery details while Order Booking (or) Adding order line
               -- to existing booked order.
               -- So handling no-data-found after updating WDD table.
               -- For new order lines created, always WDD table will be updated.
               IF sql%rowcount = 0 THEN
                  --
                  IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name, 'Error: Delivery details not created for Line Id', l_details_interface_tab(i).line_id);
                  END IF;
                  --
                  l_temp_status := 'INVALID_HEADER';
                  FND_MESSAGE.Set_Name('WSH', 'WSH_STND_ERROR');
                  WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_ERROR, l_module_name );
                  goto loop_end;
               END IF;
            END IF;

            -- Schedule date change check
            IF l_details_interface_tab(i).schedule_date_changed = 'Y' THEN -- {
               IF l_delivery_detail_tab.count > 0
               THEN
                  FOR j in l_delivery_detail_tab.first..l_delivery_detail_tab.last
                  LOOP
                     l_details_marked(l_details_marked.count+1) := l_delivery_detail_tab(j);
                  END LOOP;
               END IF;
            END IF; -- }

            l_tmp := null;
            -- Check if no open delivery lines exists for open order line
            -- If yes then call API WSH_SHIP_CONFIRM_ACTIONS.Process_Lines_To_OM
            -- so that OM can progress the line further.
            OPEN  c_open_del_lines(l_details_interface_tab(i).line_id);
            FETCH c_open_del_lines into l_tmp;
            IF c_open_del_lines%NOTFOUND THEN
               l_close_line_tbl(l_close_line_tbl.count+1) := l_details_interface_tab(i).line_id;
            END IF;
            CLOSE c_open_del_lines;

            <<end_loop>>
               null;
         END LOOP;
      END IF; -- } Details Count > 0

      IF l_details_marked.count > 0 THEN -- {
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Calling WSH_TP_RELEASE.Calculate_cont_del_tpdates', WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --
         WSH_TP_RELEASE.Calculate_cont_del_tpdates(
                        p_entity        => 'DLVB',
                        p_entity_ids    => l_details_marked,
                        x_return_status => l_return_status);


         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Error occured in Calculate_cont_del_tpdates', WSH_DEBUG_SV.C_ERR_LEVEL);
            END IF;
            --
            l_temp_status := 'INVALID';
            goto loop_end;
         END IF;
      END IF; -- }

      IF l_close_line_tbl.count > 0 THEN -- {
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Calling WSH_SHIP_CONFIRM_ACTIONS.Process_Lines_To_OM', WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --

         WSH_SHIP_CONFIRM_ACTIONS.Process_Lines_To_OM(
             p_line_id_tab   => l_close_line_tbl,
             x_return_status => l_return_status );

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Error occured in WSH_Process_line_To_OM', WSH_DEBUG_SV.C_ERR_LEVEL);
            END IF;
            --
            l_temp_status := 'INVALID';
            goto loop_end;
         END IF;
      END IF; -- }

      -- Update only processing transaction history record, if its triggered through Workflow
      IF l_transaction_rec.item_type is not null and
         l_transaction_rec.event_key is not null
      THEN
         l_upd_txn_history_tbl(1) := l_transaction_rec.transaction_id;
      ELSE
         -- Update processing/existing transaction history record, if its not triggered through Workflow
         l_upd_txn_history_tbl := l_txn_history_tbl;
      END IF;

      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'Update transaction history table count', l_upd_txn_history_tbl.count);
      END IF;
      --

      IF l_upd_txn_history_tbl.count > 0 THEN
         -- Entity Type and Entity Number should be updated only for current
         -- processing transaction history record
         FORALL i in l_upd_txn_history_tbl.FIRST..l_upd_txn_history_tbl.LAST
            UPDATE wsh_transactions_history
            SET    transaction_status     = 'SC',
                   entity_type            = decode(transaction_id, l_transaction_rec.transaction_id, 'ORDER', entity_type),
                   entity_number          = decode(transaction_id, l_transaction_rec.transaction_id, x_header_rec.header_id, entity_number),
                   program_application_id = FND_GLOBAL.Prog_Appl_Id,
                   program_id             = FND_GLOBAL.Conc_Program_Id,
                   request_id             = FND_GLOBAL.Conc_Request_Id,
                   program_update_date    = sysdate,
                   last_updated_by        = FND_GLOBAL.User_Id,
                   last_update_date       = sysdate,
                   last_update_login      = FND_GLOBAL.Login_Id
            WHERE  transaction_id = l_upd_txn_history_tbl(i);

            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, sql%rowcount || ' row(s) updated in wsh_transactions_history');
            END IF;
            --
      END IF;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'Calling WSH_PROCESS_INTERFACED_PKG.Delete_Interface_Records', WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'Calling WSH_CUSTOM_PUB.Post_Process_Shipment_Request', WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      --Call Custom API
      WSH_CUSTOM_PUB.Post_Process_Shipment_Request(
                     p_transaction_id => l_transaction_rec.transaction_id,
                     x_return_status  => l_return_status );

      IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Error occured in WSH_CUSTOM_PUB.Post_Process_Shipment_Request', WSH_DEBUG_SV.C_ERR_LEVEL);
         END IF;
         --
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      WSH_PROCESS_INTERFACED_PKG.Delete_Interface_Records (
         p_del_interface_id_tbl       => l_delivery_interface_tbl,
         p_del_det_interface_id_tbl   => l_detail_interface_tbl,
         p_del_assgn_interface_id_tbl => l_del_assgn_interface_tbl,
         p_del_error_interface_id_tbl => l_del_interface_error_tbl,
         p_det_error_interface_id_tbl => l_det_interface_error_tbl,
         x_return_status              => l_return_status);

     IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'Error occured in Delete_Interface_Records', WSH_DEBUG_SV.C_ERR_LEVEL);
        END IF;
        --
        RAISE FND_API.G_EXC_ERROR;
     END IF;
   -- }
   ELSE --Error/Unexpected Error returned from Process Order api  {
      l_temp_status := 'INVALID';
      FOR i IN 1 .. oe_msg_pub.g_msg_tbl.COUNT LOOP
         l_error_msg := SUBSTRB( OE_MSG_PUB.Get (i, 'F'), 1, 4000 );

         OE_MSG_PUB.Get_Msg_Context(
                    p_msg_index                  => i,
                    x_entity_code                => l_entity_code,
                    x_entity_ref                 => l_entity_ref,
                    x_entity_id                  => l_entity_id,
                    x_header_id                  => l_header_id,
                    x_line_id                    => l_line_id,
                    x_order_source_id            => l_order_source_id,
                    x_orig_sys_document_ref      => l_orig_sys_document_ref,
                    x_orig_sys_line_ref          => l_orig_sys_document_line_ref,
                    x_orig_sys_shipment_ref      => l_orig_sys_shipment_ref,
                    x_change_sequence            => l_change_sequence,
                    x_source_document_type_id    => l_source_document_type_id,
                    x_source_document_id         => l_source_document_id,
                    x_source_document_line_id    => l_source_document_line_id,
                    x_constraint_id              => l_constraint_id,
                    x_attribute_code             => l_attribute_code,
                    x_process_activity           => l_process_activity,
                    x_notification_flag          => l_notification_flag,
                    x_type                       => l_type );



         IF ( l_orig_sys_document_ref is not null or l_orig_sys_document_line_ref is not null or l_orig_sys_shipment_ref is not null) then
         --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'x_entity_code    : ' ||  l_entity_code);
               WSH_DEBUG_SV.logmsg(l_module_name, 'x_entity_ref     : ' ||  l_entity_ref);
               WSH_DEBUG_SV.logmsg(l_module_name, 'x_entity_id      : ' ||  l_entity_id);
               WSH_DEBUG_SV.logmsg(l_module_name, 'x_header_id      : ' ||  l_header_id);
               WSH_DEBUG_SV.logmsg(l_module_name, 'x_line_id        : ' ||  l_line_id);
               WSH_DEBUG_SV.logmsg(l_module_name, 'x_orig_sys_document_ref : ' ||  l_orig_sys_document_ref);
               WSH_DEBUG_SV.logmsg(l_module_name, 'x_orig_sys_document_line_ref : ' ||  l_orig_sys_document_line_ref);
               WSH_DEBUG_SV.logmsg(l_module_name, 'x_orig_sys_shipment_ref : ' ||  l_orig_sys_shipment_ref);
               WSH_DEBUG_SV.logmsg(l_module_name, 'Error Message : ' ||  OE_MSG_PUB.Get (i, 'F') );
            END IF;
            --

            -- OM API returns 'Order has been booked.' even if validation fails.
            -- This is the expected behaviour as per doc bug 3725134
            IF ( l_orig_sys_document_ref = l_header_doc_ref and
                 l_entity_code = 'HEADER' )
            THEN
               --
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name, 'Populating error for delivery interface');
               END IF;
               --
               interface_error_rec.p_interface_table_name := 'WSH_NEW_DEL_INTERFACE';
               interface_error_rec.p_interface_id :=  l_entity_number;
            -- LSP PROJECT : For line level errors, l_line_details_tbl stores all dd iface ids.
            ELSIF (l_entity_code = 'LINE' AND l_line_details_tbl.exists(MOD(l_entity_id,G_BINARY_LIMIT)))
            THEN
               --
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name, 'Populating error for delivery detail interface');
               END IF;
               --
               interface_error_rec.p_interface_table_name := 'WSH_DEL_DETAILS_INTERFACE';
               interface_error_rec.p_interface_id   :=  l_line_details_tbl(MOD(l_entity_id,G_BINARY_LIMIT));
            ELSE
               interface_error_rec.p_interface_table_name := NULL;
            END IF;

            IF interface_error_rec.p_interface_table_name is not null THEN
               interface_error_rec.p_message_name   := 'WSH_UTIL_MESSAGE_E';
               interface_error_rec.p_token1         := 'MSG_TEXT';
               interface_error_rec.p_value1         := substr(l_error_msg,1,250);
               interface_error_tab(interface_error_tab.count+1) := interface_error_rec;
            END IF;
         END IF;
      END LOOP;
   END IF; --}

   <<loop_end>>
      IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
      THEN
      --{
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS', WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --
         WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
           (
             p_in_rec             => l_lpn_in_sync_comm_rec,
             x_return_status      => l_return_status,
             x_out_rec            => l_lpn_out_sync_comm_rec
           );
         --
         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
         END IF;
         --
         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'LPN Sync API WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS failed');
            END IF;
            --
            l_temp_status := 'INVALID';
         END IF;
      --}
      END IF;

      IF l_temp_status in ( 'INVALID', 'INVALID_HEADER' ) THEN --{
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         -- To Print in Concurrent Request Output File
         IF FND_GLOBAL.Conc_Request_Id > 0 THEN
            FND_FILE.put_line(FND_FILE.output, '  Process Shipment Request failed to process document number: ' || l_transaction_rec.document_number);
         END IF;
         --
         --Rollback the transaction
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Rolling Back the changes done for this transaction');
         END IF;
         ROLLBACK;

         -- If header level validation fails then retrive the error messages from Stack.
         IF l_temp_status = 'INVALID_HEADER' THEN
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Calling Populate_Error_Records', WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            Populate_Error_Records(
                 p_interface_id             => l_entity_number,
                 p_interface_table_name     => 'WSH_NEW_DEL_INTERFACE',
                 x_interface_errors_rec_tab => interface_error_tab,
                 x_return_status            => l_return_status );

            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
               --
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name, 'Populate_Error_Records returned unexpected error', WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
               END IF;
               --
            END IF;
         END IF;

         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'Querying wsh_interface_errors Records (For Delivery Interface)', l_entity_number);
         END IF;
         --

         --Flushing following arrays since it contains interface errors of Current/Existing document revisions
         l_del_interface_error_tbl.delete;
         l_det_interface_error_tbl.delete;

         --Querying interface errors of Current processing document revision - Start
         SELECT wie.interface_error_id
         BULK COLLECT INTO l_del_interface_error_tbl
         FROM   wsh_interface_errors wie
         WHERE  wie.interface_table_name = 'WSH_NEW_DEL_INTERFACE'
         AND    wie.interface_action_code = g_interface_action_code
         AND    wie.interface_id = l_entity_number;

         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Queried '||SQL%ROWCOUNT||' wsh_interface_errors Records (For Delivery Interface)');
            WSH_DEBUG_SV.log(l_module_name, 'Querying wsh_interface_errors Records (For Detail Interface)', l_entity_number);
         END IF;
         --

         SELECT wie.interface_error_id
         BULK COLLECT INTO l_det_interface_error_tbl
         FROM   wsh_interface_errors wie
         WHERE  interface_table_name = 'WSH_DEL_DETAILS_INTERFACE'
         AND    interface_action_code = g_interface_action_code
         AND    interface_id in
              ( select wddi.delivery_detail_interface_id
                FROM   Wsh_Del_Details_Interface wddi,
                       Wsh_Del_Assgn_Interface wdai
                WHERE  wddi.interface_action_code = g_interface_action_code
                AND    wdai.interface_action_code = g_interface_action_code
                AND    wddi.delivery_detail_interface_id = wdai.delivery_detail_interface_id
                AND    wdai.delivery_interface_id = l_entity_number );

         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Queried '||SQL%ROWCOUNT||' wsh_interface_errors Records (For Detail Interface)');
         END IF;
         --Querying interface errors of Current processing document revision - End

         --
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'Calling WSH_CUSTOM_PUB.Post_Process_Shipment_Request', WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --
         --Call Custom API
         WSH_CUSTOM_PUB.Post_Process_Shipment_Request(
                        p_transaction_id => l_transaction_rec.transaction_id,
                        x_return_status  => l_return_status );

         IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Error occured in WSH_CUSTOM_PUB.Post_Process_Shipment_Request', WSH_DEBUG_SV.C_ERR_LEVEL);
            END IF;
            --
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF (l_del_interface_error_tbl.COUNT > 0) OR (l_det_interface_error_tbl.COUNT > 0) THEN --{
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name, 'Calling WSH_PROCESS_INTERFACED_PKG.Delete_Interface_Records', WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

            WSH_PROCESS_INTERFACED_PKG.Delete_Interface_Records (
              p_del_interface_id_tbl       => l_dummy,
              p_del_det_interface_id_tbl   => l_dummy,
              p_del_assgn_interface_id_tbl => l_dummy,
              p_del_error_interface_id_tbl => l_del_interface_error_tbl,
              p_det_error_interface_id_tbl => l_det_interface_error_tbl,
              x_return_status              => l_return_status);

            IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
               --
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name, 'Error occured in Delete_Interface_Records', WSH_DEBUG_SV.C_ERR_LEVEL);
               END IF;
               --
               RAISE FND_API.G_EXC_ERROR;
            END IF;
         END IF; --}

         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'interface_error_tab.count', interface_error_tab.count);
         END IF;
         --
         IF interface_error_tab.count > 0 THEN
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Calling WSH_INTERFACE_VALIDATIONS_PKG.Log_Interface_Errors', WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_INTERFACE_VALIDATIONS_PKG.Log_Interface_Errors (
                p_interface_errors_rec_tab => interface_error_tab,
                p_interface_action_code    => g_interface_action_code,
                x_return_status            => l_return_status);

            IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
               --
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name, 'Error occured in Log_Interface_Errors', WSH_DEBUG_SV.C_ERR_LEVEL);
               END IF;
               --
               RAISE FND_API.G_EXC_ERROR;
            END IF;
         END IF;

         l_transaction_rec.transaction_status := 'ER';

         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Calling WSH_TRANSACTIONS_HISTORY_PKG.Create_Update_Txns_History', WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --
         WSH_TRANSACTIONS_HISTORY_PKG.Create_Update_Txns_History (
                  p_txns_history_rec => l_transaction_rec,
                  x_txns_id          => l_transaction_rec.transaction_id,
                  x_return_status    => l_return_status );

         --
         IF l_debug_on THEN
            wsh_debug_sv.log (l_module_name, 'Return status after Create_Update_Txns_History ', l_return_status);
         END IF;
         --
         IF ( l_return_status <> WSH_UTIL_CORE.g_ret_sts_success ) THEN
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Error occured in Create_Update_Txns_History', WSH_DEBUG_SV.C_ERR_LEVEL);
            END IF;
            --
            RAISE FND_API.G_EXC_ERROR;
         END IF;

      ELSIF (l_temp_status = 'NO_LOCK') THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
         --
         IF l_debug_on THEN
            wsh_debug_sv.logmsg(l_module_name, 'Unable to lock the records for Transaction '||l_transaction_rec.transaction_id||'. Skipping the Record');
         END IF;
         --
         ROLLBACK;
      END IF; --}
   -- End of <<loop_end>>

   -- COMMIT THE TRANSACTION
   IF p_commit_flag = FND_API.G_TRUE THEN
      --
      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'Commiting the changes done for this transaction');
      END IF;
      --
      COMMIT;
   END IF;

   --
   IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name, 'Return Status from Process_Shipment_Request2', x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
EXCEPTION
   when FND_API.G_EXC_ERROR then
      --Rollback the transaction
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Inside exception FND_API.G_EXC_ERROR, Rolling Back the changes done for this transaction');
      END IF;
      --
      ROLLBACK;
      --Setting value for G_MODE back to 'NORMAL'
      IF WSH_MAP_LOCATION_REGION_PKG.G_MODE <> 'NORMAL' THEN
         WSH_MAP_LOCATION_REGION_PKG.G_MODE := 'NORMAL';
      END IF;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

      IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
      THEN
      --{
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS', WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --
         WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
           (
             p_in_rec             => l_lpn_in_sync_comm_rec,
             x_return_status      => l_return_status,
             x_out_rec            => l_lpn_out_sync_comm_rec
           );
         --
         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
         END IF;
         --
         IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
            x_return_status := l_return_status;
         END IF;
      --}
      END IF;
      --
      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         wsh_debug_sv.pop(l_module_name, 'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --

   WHEN OTHERS THEN
      --Rollback the transaction
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Inside exception OTHERS, Rolling Back the changes done for this transaction');
      END IF;
      --
      ROLLBACK;
      --Setting value for G_MODE back to 'NORMAL'
      IF WSH_MAP_LOCATION_REGION_PKG.G_MODE <> 'NORMAL' THEN
         WSH_MAP_LOCATION_REGION_PKG.G_MODE := 'NORMAL';
      END IF;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

      IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
      THEN
      --{
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS', WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --
         WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
           (
             p_in_rec             => l_lpn_in_sync_comm_rec,
             x_return_status      => l_return_status,
             x_out_rec            => l_lpn_out_sync_comm_rec
           );
         --
         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
         END IF;
         --
      --}
      END IF;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Process_Shipment_Request;
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Get_Standalone_Defaults
--
-- PARAMETERS:
--       p_delivery_interface_id  => Delivery Interface Id
--       x_delivery_interface_rec => Delivery Interface Record
--       x_return_status          => Return Status of API (S,E,U)
-- COMMENT:
--       Queries WNDI details, validates organization and derives
--       operating unit for organization.
--=============================================================================
--
PROCEDURE Get_Standalone_Defaults (
          p_delivery_interface_id  IN         NUMBER,
          x_delivery_interface_rec OUT NOCOPY Del_Interface_Rec_Type,
          x_return_status          OUT NOCOPY VARCHAR2 )
IS
   CURSOR c_delivery_interface_rec
   IS
   SELECT delivery_interface_id,
          organization_code,
          organization_id,
          customer_id,
          customer_name,
          ship_to_customer_id,
          ship_to_customer_name,
          ship_to_address_id,
          ship_to_address1,
          ship_to_address2,
          ship_to_address3,
          ship_to_address4,
          ship_to_city,
          ship_to_state,
          ship_to_country,
          ship_to_postal_code,
          ship_to_contact_id,
          ship_to_contact_name,
          ship_to_contact_phone,
          invoice_to_customer_id,
          invoice_to_customer_name,
          invoice_to_address_id,
          invoice_to_address1,
          invoice_to_address2,
          invoice_to_address3,
          invoice_to_address4,
          invoice_to_city,
          invoice_to_state,
          invoice_to_country,
          invoice_to_postal_code,
          invoice_to_contact_id,
          invoice_to_contact_name,
          invoice_to_contact_phone,
          deliver_to_customer_id,
          deliver_to_customer_name,
          deliver_to_address_id,
          deliver_to_address1,
          deliver_to_address2,
          deliver_to_address3,
          deliver_to_address4,
          deliver_to_city,
          deliver_to_state,
          deliver_to_country,
          deliver_to_postal_code,
          deliver_to_contact_id,
          deliver_to_contact_name,
          deliver_to_contact_phone,
          transaction_type_id,
          price_list_id,
          null,
          currency_code,
          carrier_code,
          carrier_id,
          service_level,
          mode_of_transport,
          freight_terms_code,
          fob_code,
          null, -- Shipping Method Code
          null, -- Org Id
          null, -- Document Revision
          null,  -- Order Number
          client_code  -- LSP PROJECT : client_code
   FROM   Wsh_New_Del_Interface wndi
   WHERE  wndi.delivery_interface_id = p_delivery_interface_id;

   l_return_status      VARCHAR2(1);

   --
   l_debug_on BOOLEAN;
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Get_Standalone_Defaults';
   --
BEGIN
   --Debug Push
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name, 'p_delivery_interface_id', p_delivery_interface_id );
   END IF;
   --
   x_return_status := WSH_UTIl_CORE.G_RET_STS_SUCCESS;

   open  c_delivery_interface_rec;
   fetch c_delivery_interface_rec into x_delivery_interface_rec;
   IF c_delivery_interface_rec%NOTFOUND THEN
      --
      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'Delivery Interface Record Missing');
      END IF;
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_DEBUG_SV.pop(l_module_name);
      RETURN;
   END IF;
   close c_delivery_interface_rec;

   --
   IF l_debug_on THEN
      wsh_debug_sv.logmsg(l_module_name, 'Calling api Validate_Organization', WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --

   Validate_Organization(
            p_org_code        => x_delivery_interface_rec.organization_code,
            p_organization_id => x_delivery_interface_rec.organization_id,
            x_return_status   => l_return_status );

   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Error occured in Validate_Organization', WSH_DEBUG_SV.C_ERR_LEVEL);
      END IF;
      --
      x_return_status := l_return_status;
   ELSE
      --
      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'Calling api WSH_UTIL_CORE.Get_Operating_Unit', WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      x_delivery_interface_rec.org_id := WSH_UTIL_CORE.Get_Operating_Unit(x_delivery_interface_rec.organization_id);

      IF nvl(x_delivery_interface_rec.org_id, -1) = -1 THEN
         --
         IF l_debug_on THEN
            wsh_debug_sv.logmsg(l_module_name, 'Error: Invalid Operating Unit returned');
         END IF;
         --
         FND_MESSAGE.Set_Name('WSH', 'WSH_STND_OU_NOT_ASSIGNED');
         FND_MESSAGE.Set_Token('ORG_NAME', WSH_UTIL_CORE.Get_Org_Name(x_delivery_interface_rec.organization_id));
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         WSH_UTIL_CORE.Add_Message(x_return_status, l_module_name );
      END IF;
   END IF;

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'Return Status', x_return_status);
      WSH_DEBUG_SV.logmsg(l_module_name, 'order_type_id => ' || x_delivery_interface_rec.transaction_type_id ||
                                       ', price_list_id => ' || x_delivery_interface_rec.price_list_id ||
                                       ', organization_id => ' || x_delivery_interface_rec.organization_id ||
                                       ', org_id => ' || x_delivery_interface_rec.org_id ||
                                       ', currency_code => ' || x_delivery_interface_rec.currency_code );
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
EXCEPTION
WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.Default_Handler('WSH_SHIPMENT_REQUEST_PKG.Get_Standalone_Defaults');
      IF c_delivery_interface_rec%ISOPEN THEN
         close c_delivery_interface_rec;
      END IF;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Get_Standalone_Defaults;
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Check_Header_Exists
--
-- PARAMETERS:
--       p_order_number       => Order Number
--       p_order_type_id      => Order Type
--       x_om_header_rec_type => Standalone related order header attributes record
--       x_return_status      => Return Status of API (Either S,U)
-- COMMENT:
--       Queries standalone related order header attributes from table
--       Oe_Order_Headers_All based on Order Number and Order Type passed.
--=============================================================================
--
PROCEDURE Check_Header_Exists (
          p_order_number       IN         NUMBER,
          p_order_type_id      IN         NUMBER,
          x_om_header_rec_type OUT NOCOPY OM_Header_Rec_Type,
          x_return_status      OUT NOCOPY VARCHAR2 )
IS
   cursor c_order_info is
   select header_id,
          open_flag,
          order_type_id,
          version_number,
          sold_to_org_id,
          ship_to_org_id,
          invoice_to_org_id,
          deliver_to_org_id,
          sold_to_contact_id,
          ship_to_contact_id,
          invoice_to_contact_id,
          deliver_to_contact_id,
          ship_from_org_id,
          price_list_id,
          payment_term_id,
          shipping_method_code,
          freight_terms_code,
          fob_point_code
   from   oe_order_headers_all
   where  order_number = p_order_number
   and    order_type_id = p_order_type_id;

   --
   l_debug_on BOOLEAN;
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Check_Header_Exists';
   --
BEGIN
   --Debug Push
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name, 'p_order_number', p_order_number );
      WSH_DEBUG_SV.log(l_module_name, 'p_order_type_id', p_order_type_id );
   END IF;
   --

   x_return_status := WSH_UTIl_CORE.G_RET_STS_SUCCESS;

   open  c_order_info;
   fetch c_order_info into
            x_om_header_rec_type.header_id,
            x_om_header_rec_type.open_flag,
            x_om_header_rec_type.order_type_id,
            x_om_header_rec_type.version_number,
            x_om_header_rec_type.sold_to_org_id,
            x_om_header_rec_type.ship_to_org_id,
            x_om_header_rec_type.invoice_to_org_id,
            x_om_header_rec_type.deliver_to_org_id,
            x_om_header_rec_type.sold_to_contact_id,
            x_om_header_rec_type.ship_to_contact_id,
            x_om_header_rec_type.invoice_to_contact_id,
            x_om_header_rec_type.deliver_to_contact_id,
            x_om_header_rec_type.ship_from_org_id,
            x_om_header_rec_type.price_list_id,
            x_om_header_rec_type.payment_term_id,
            x_om_header_rec_type.shipping_method_code,
            x_om_header_rec_type.freight_terms_code,
            x_om_header_rec_type.fob_point_code;
   close c_order_info;

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'Return Status', x_return_status);
      WSH_DEBUG_SV.log(l_module_name, 'Header id', x_om_header_rec_type.header_id);
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
EXCEPTION
WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.Default_Handler('WSH_SHIPMENT_REQUEST_PKG.Check_Header_Exists');
      IF c_order_info%ISOPEN THEN
         close c_order_info;
      END IF;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Check_Header_Exists;
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Check_Line_Exists
--
-- PARAMETERS:
--       p_header_id        => Order Header Id
--       p_line_number      => Order Line Number
--       x_om_line_rec_type => Standalone related order line attributes record
--       x_return_status    => Return Status of API (Either S,U)
-- COMMENT:
--       Queries standalone related order lines attributes from table
--       Oe_Order_Lines_All based on Header Id and Line Number passed.
--=============================================================================
--
PROCEDURE Check_Line_Exists (
          p_header_id        IN         NUMBER,
          p_line_number      IN         NUMBER,
          x_om_line_rec_type OUT NOCOPY OM_Line_Rec_Type,
          x_return_status    OUT NOCOPY VARCHAR2 )
IS
   cursor c_line_info is
   select line_id,
          decode(open_flag,'N','N',decode(shipped_quantity,null,'Y','N')) open_flag,
          ordered_quantity,
          inventory_item_id,
          ordered_item_id,
          order_quantity_uom,
          ship_tolerance_above,
          ship_tolerance_below,
          request_date,
          schedule_ship_date,
          ship_set_id,
          shipping_instructions,
          packing_instructions,
          shipment_priority_code,
          cust_po_number,
          subinventory,
          unit_selling_price,
          rownum
   from   oe_order_lines_all
   where  line_number = p_line_number
   and    header_id = p_header_id;

   l_ship_set_id   NUMBER;

   --
   l_debug_on BOOLEAN;
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Check_Line_Exists';
   --
BEGIN
   --Debug Push
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name, 'p_header_id', p_header_id );
      WSH_DEBUG_SV.log(l_module_name, 'p_line_number', p_line_number );
   END IF;
   --

   x_return_status := WSH_UTIl_CORE.G_RET_STS_SUCCESS;

   FOR i in c_line_info
   LOOP
      IF i.rownum > 1 THEN
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'Error: More than one order line exists for same line number', p_line_number);
         END IF;
         --
         FND_MESSAGE.Set_Name('WSH', 'WSH_STND_ERROR');
         x_return_status := WSH_UTIl_CORE.G_RET_STS_ERROR;
         WSH_UTIL_CORE.Add_Message(x_return_status, l_module_name);
      END IF;

      -- Error out while entering into the loop second time.
      x_om_line_rec_type.line_id                := i.line_id;
      x_om_line_rec_type.open_flag              := i.open_flag;
      x_om_line_rec_type.ordered_quantity       := i.ordered_quantity;
      x_om_line_rec_type.inventory_item_id      := i.inventory_item_id;
      x_om_line_rec_type.ordered_item_id        := i.ordered_item_id;
      x_om_line_rec_type.order_quantity_uom     := i.order_quantity_uom;
      x_om_line_rec_type.ship_tolerance_above   := i.ship_tolerance_above;
      x_om_line_rec_type.ship_tolerance_below   := i.ship_tolerance_below;
      x_om_line_rec_type.request_date           := i.request_date;
      x_om_line_rec_type.schedule_ship_date     := i.schedule_ship_date;
      x_om_line_rec_type.shipping_instructions  := i.shipping_instructions;
      x_om_line_rec_type.packing_instructions   := i.packing_instructions;
      x_om_line_rec_type.shipment_priority_code := i.shipment_priority_code;
      x_om_line_rec_type.cust_po_number         := i.cust_po_number;
      x_om_line_rec_type.subinventory           := i.subinventory;
      x_om_line_rec_type.unit_selling_price     := i.unit_selling_price;
      l_ship_set_id                             := i.ship_set_id;

      IF l_ship_set_id is null THEN
         x_om_line_rec_type.ship_set_name          := null;
      ELSE
         BEGIN
            select set_name
            into   x_om_line_rec_type.ship_set_name
            from   oe_sets
            where  set_id = l_ship_set_id;
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
            x_om_line_rec_type.ship_set_name := null;
         END;
      END IF;
   END LOOP;

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'Return Status', x_return_status);
      WSH_DEBUG_SV.log(l_module_name, 'Line id', x_om_line_rec_type.line_id);
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
EXCEPTION
WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.Default_Handler('WSH_SHIPMENT_REQUEST_PKG.Check_Line_Exists');
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Check_Line_Exists;
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Lock_SR_Lines
--
-- PARAMETERS:
--       p_header_id             => Order Header Id
--       p_delivery_interface_id => Delivery Interface Id
--       p_interface_records     => Either Y or N
--       x_return_status         => Return Status of API (Either S,E,U)
-- COMMENT:
--       API to Lock records from OEH, OEL and WDD table.
--       Based on p_interface_records value,
--       Y : Lock records from OEL, WDD corresponding to records from WDDI
--           Interface Table
--       N : Lock records from OEL, WDD for lines which are not populated in
--           WDDI Interface Table
--=============================================================================
--
PROCEDURE Lock_SR_Lines (
          p_header_id             IN NUMBER,
          p_delivery_interface_id IN NUMBER,
          p_interface_records     IN VARCHAR2,
          x_return_status         OUT NOCOPY VARCHAR2 )
IS

   cursor c_lock_interface_lines
   is
      select oel.line_id
      from   oe_order_lines_all oel,
             wsh_del_details_interface wddi,
             wsh_del_assgn_interface   wdai
      where  oel.header_id   = p_header_id
      and    oel.line_number = wddi.line_number
      and    wddi.interface_action_code = g_interface_action_code
      and    wdai.interface_action_code = g_interface_action_code
      and    wddi.delivery_detail_interface_id = wdai.delivery_detail_interface_id
      and    wdai.delivery_interface_id = p_delivery_interface_id
      for update of oel.line_id nowait;

   cursor c_lock_non_interface_lines
   is
      select oel.line_id
      from   oe_order_lines_all oel
      where  oel.header_id   = p_header_id
      and    not exists
           ( select '1'
             from   wsh_del_details_interface wddi,
                    wsh_del_assgn_interface   wdai
             where  oel.line_number = wddi.line_number
             and    wddi.interface_action_code = g_interface_action_code
             and    wdai.interface_action_code = g_interface_action_code
             and    wddi.delivery_detail_interface_id = wdai.delivery_detail_interface_id
             and    wdai.delivery_interface_id = p_delivery_interface_id )
   for update of oel.line_id nowait;

   cursor c_lock_delivery_details( c_line_id NUMBER )
   is
      select delivery_detail_id
      from   wsh_delivery_details
      where  source_code = 'OE'
      and    source_line_id = c_line_id
      for update nowait;

   l_header_id          NUMBER;
   l_details_tab        WSH_UTIL_CORE.Id_Tab_Type;

   RECORD_LOCKED         EXCEPTION;
   PRAGMA EXCEPTION_INIT(RECORD_LOCKED, -54);

   --
   l_debug_on BOOLEAN;
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Lock_SR_Lines';
   --
BEGIN
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name, 'p_header_id', p_header_id );
      WSH_DEBUG_SV.log(l_module_name, 'p_delivery_interface_id', p_delivery_interface_id );
      WSH_DEBUG_SV.log(l_module_name, 'p_interface_records', p_interface_records );
   END IF;
   --

   x_return_status := WSH_UTIl_CORE.G_RET_STS_SUCCESS;

   IF p_interface_records = 'Y' THEN
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Obtaining lock on order headers');
      END IF;
      --
      select header_id
      into   l_header_id
      from   oe_order_headers_all
      where  header_id = p_header_id
      for update nowait;

      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Obtaining lock on order lines');
      END IF;
      --
      FOR l_line_rec in c_lock_interface_lines
      LOOP
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Obtaining lock on delivery details');
         END IF;
         --
         select delivery_detail_id
         bulk collect into l_details_tab
         from   wsh_delivery_details
         where  source_code = 'OE'
         and    source_line_id = l_line_rec.line_id
         for update nowait;
      END LOOP;
   ELSE
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Obtaining lock on non-interface order lines');
      END IF;
      --
      FOR l_line_rec in c_lock_non_interface_lines
      LOOP
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Obtaining lock on non-interface delivery details');
         END IF;
         --
         select delivery_detail_id
         bulk collect into l_details_tab
         from   wsh_delivery_details
         where  source_code = 'OE'
         and    source_line_id = l_line_rec.line_id
         for update nowait;
      END LOOP;
   END IF;

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'Return Status', x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
EXCEPTION
   WHEN RECORD_LOCKED THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('WSH','WSH_NO_LOCK');
        WSH_UTIL_CORE.add_message (x_return_status);
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'RECORD_LOCKED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:RECORD_LOCKED');
        END IF;
        --
   WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        WSH_UTIL_CORE.Default_Handler('WSH_SHIPMENT_REQUEST_PKG.Lock_SR_Lines');
        WSH_UTIL_CORE.add_message (x_return_status);
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --
END Lock_SR_Lines;
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Validate_Delivery_Line
--
-- PARAMETERS:
--       p_changed_attributes => Changed Attributes passed from OM
--       x_return_status      => Return Status of API (Either S,E,U)
-- COMMENT:
--       Only Requested Quantity can be updated during Shipment Request process
--       for Shipment lines if any delivery line is in a confirmed delivery or
--       has been shipped.
--=============================================================================
--
PROCEDURE Validate_Delivery_Line (
                   p_changed_attributes IN  WSH_INTERFACE.ChangedAttributeTabType,
                   x_return_status      OUT NOCOPY VARCHAR2 )
IS
   CURSOR c_delivery_line_info(c_line_id NUMBER)
   IS
   select wdd.*
   from   wsh_delivery_details     wdd,
          wsh_delivery_assignments wda,
          wsh_new_deliveries       wnd
   where  wnd.status_code in ( 'CL', 'IT', 'CO' )
   and    wnd.delivery_id = wda.delivery_id
   and    wda.delivery_detail_id = wdd.delivery_detail_id
   and    source_code = 'OE'
   and    released_status in ( 'C', 'Y' )
   and    wdd.source_line_id = c_line_id
   and    rownum = 1;

   --
   l_debug_on BOOLEAN;
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Validate_Delivery_Line';
   --
BEGIN
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
   END IF;
   --

   x_return_status := WSH_UTIl_CORE.G_RET_STS_SUCCESS;

   FOR i in p_changed_attributes.FIRST .. p_changed_attributes.LAST
   LOOP
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'source_line_id', p_changed_attributes(i).source_line_id );
      END IF;
      --
   FOR delivery_line_info in c_delivery_line_info(p_changed_attributes(i).source_line_id )
   LOOP
   /*
      -- Just for debugging
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'p_changed_attributes(i).shipping_instructions', p_changed_attributes(i).shipping_instructions );
         WSH_DEBUG_SV.log(l_module_name, 'delivery_line_info.shipping_instructions', delivery_line_info.shipping_instructions );
         WSH_DEBUG_SV.logmsg(l_module_name, 'arrival_set_id                 => ' || p_changed_attributes(i).arrival_set_id                || ' , => ' || delivery_line_info.arrival_set_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'ato_line_id                    => ' || p_changed_attributes(i).ato_line_id                   || ' , => ' || delivery_line_info.ato_line_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'attribute1                     => ' || p_changed_attributes(i).attribute1                    || ' , => ' || delivery_line_info.attribute1 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'attribute10                    => ' || p_changed_attributes(i).attribute10                   || ' , => ' || delivery_line_info.attribute10 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'attribute11                    => ' || p_changed_attributes(i).attribute11                   || ' , => ' || delivery_line_info.attribute11 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'attribute12                    => ' || p_changed_attributes(i).attribute12                   || ' , => ' || delivery_line_info.attribute12 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'attribute13                    => ' || p_changed_attributes(i).attribute13                   || ' , => ' || delivery_line_info.attribute13 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'attribute14                    => ' || p_changed_attributes(i).attribute14                   || ' , => ' || delivery_line_info.attribute14 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'attribute15                    => ' || p_changed_attributes(i).attribute15                   || ' , => ' || delivery_line_info.attribute15 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'attribute2                     => ' || p_changed_attributes(i).attribute2                    || ' , => ' || delivery_line_info.attribute2 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'attribute3                     => ' || p_changed_attributes(i).attribute3                    || ' , => ' || delivery_line_info.attribute3 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'attribute4                     => ' || p_changed_attributes(i).attribute4                    || ' , => ' || delivery_line_info.attribute4 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'attribute5                     => ' || p_changed_attributes(i).attribute5                    || ' , => ' || delivery_line_info.attribute5 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'attribute6                     => ' || p_changed_attributes(i).attribute6                    || ' , => ' || delivery_line_info.attribute6 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'attribute7                     => ' || p_changed_attributes(i).attribute7                    || ' , => ' || delivery_line_info.attribute7 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'attribute8                     => ' || p_changed_attributes(i).attribute8                    || ' , => ' || delivery_line_info.attribute8 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'attribute9                     => ' || p_changed_attributes(i).attribute9                    || ' , => ' || delivery_line_info.attribute9 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'attribute_category             => ' || p_changed_attributes(i).attribute_category            || ' , => ' || delivery_line_info.attribute_category );
         WSH_DEBUG_SV.logmsg(l_module_name, 'cancelled_quantity             => ' || p_changed_attributes(i).cancelled_quantity            || ' , => ' || delivery_line_info.cancelled_quantity );
         WSH_DEBUG_SV.logmsg(l_module_name, 'cancelled_quantity2            => ' || p_changed_attributes(i).cancelled_quantity2           || ' , => ' || delivery_line_info.cancelled_quantity2 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'carrier_id                     => ' || p_changed_attributes(i).carrier_id                    || ' , => ' || delivery_line_info.carrier_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'classification                 => ' || p_changed_attributes(i).classification                || ' , => ' || delivery_line_info.classification );
         WSH_DEBUG_SV.logmsg(l_module_name, 'commodity_code_cat_id          => ' || p_changed_attributes(i).commodity_code_cat_id         || ' , => ' || delivery_line_info.commodity_code_cat_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'container_flag                 => ' || p_changed_attributes(i).container_flag                || ' , => ' || delivery_line_info.container_flag );
         WSH_DEBUG_SV.logmsg(l_module_name, 'container_name                 => ' || p_changed_attributes(i).container_name                || ' , => ' || delivery_line_info.container_name );
         WSH_DEBUG_SV.logmsg(l_module_name, 'container_type_code            => ' || p_changed_attributes(i).container_type_code           || ' , => ' || delivery_line_info.container_type_code );
         WSH_DEBUG_SV.logmsg(l_module_name, 'country_of_origin              => ' || p_changed_attributes(i).country_of_origin             || ' , => ' || delivery_line_info.country_of_origin );
         WSH_DEBUG_SV.logmsg(l_module_name, 'currency_code                  => ' || p_changed_attributes(i).currency_code                 || ' , => ' || delivery_line_info.currency_code );
         WSH_DEBUG_SV.logmsg(l_module_name, 'cust_model_serial_number       => ' || p_changed_attributes(i).cust_model_serial_number      || ' , => ' || delivery_line_info.cust_model_serial_number );
         WSH_DEBUG_SV.logmsg(l_module_name, 'cust_po_number                 => ' || p_changed_attributes(i).cust_po_number                || ' , => ' || delivery_line_info.cust_po_number );
         WSH_DEBUG_SV.logmsg(l_module_name, 'customer_dock_code             => ' || p_changed_attributes(i).customer_dock_code            || ' , => ' || delivery_line_info.customer_dock_code );
         WSH_DEBUG_SV.logmsg(l_module_name, 'customer_id                    => ' || p_changed_attributes(i).customer_id                   || ' , => ' || delivery_line_info.customer_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'customer_item_id               => ' || p_changed_attributes(i).customer_item_id              || ' , => ' || delivery_line_info.customer_item_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'customer_job                   => ' || p_changed_attributes(i).customer_job                  || ' , => ' || delivery_line_info.customer_job );
         WSH_DEBUG_SV.logmsg(l_module_name, 'customer_prod_seq              => ' || p_changed_attributes(i).customer_prod_seq             || ' , => ' || delivery_line_info.customer_prod_seq );
         WSH_DEBUG_SV.logmsg(l_module_name, 'customer_production_line       => ' || p_changed_attributes(i).customer_production_line      || ' , => ' || delivery_line_info.customer_production_line );
         WSH_DEBUG_SV.logmsg(l_module_name, 'customer_requested_lot_flag    => ' || p_changed_attributes(i).customer_requested_lot_flag   || ' , => ' || delivery_line_info.customer_requested_lot_flag );
         WSH_DEBUG_SV.logmsg(l_module_name, 'cycle_count_quantity           => ' || p_changed_attributes(i).cycle_count_quantity          || ' , => ' || delivery_line_info.cycle_count_quantity );
         WSH_DEBUG_SV.logmsg(l_module_name, 'cycle_count_quantity2          => ' || p_changed_attributes(i).cycle_count_quantity2         || ' , => ' || delivery_line_info.cycle_count_quantity2 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'date_requested                 => ' || p_changed_attributes(i).date_requested                || ' , => ' || delivery_line_info.date_requested );
         WSH_DEBUG_SV.logmsg(l_module_name, 'date_scheduled                 => ' || p_changed_attributes(i).date_scheduled                || ' , => ' || delivery_line_info.date_scheduled );
         WSH_DEBUG_SV.logmsg(l_module_name, 'deliver_to_contact_id          => ' || p_changed_attributes(i).deliver_to_contact_id         || ' , => ' || delivery_line_info.deliver_to_contact_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'deliver_to_org_id              => ' || p_changed_attributes(i).deliver_to_org_id             || ' , => ' || delivery_line_info.deliver_to_site_use_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'delivered_quantity             => ' || p_changed_attributes(i).delivered_quantity            || ' , => ' || delivery_line_info.delivered_quantity );
         WSH_DEBUG_SV.logmsg(l_module_name, 'delivered_quantity2            => ' || p_changed_attributes(i).delivered_quantity2           || ' , => ' || delivery_line_info.delivered_quantity2 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'delivery_detail_id             => ' || p_changed_attributes(i).delivery_detail_id            || ' , => ' || delivery_line_info.delivery_detail_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'dep_plan_required_flag         => ' || p_changed_attributes(i).dep_plan_required_flag        || ' , => ' || delivery_line_info.dep_plan_required_flag );
         WSH_DEBUG_SV.logmsg(l_module_name, 'detail_container_item_id       => ' || p_changed_attributes(i).detail_container_item_id      || ' , => ' || delivery_line_info.detail_container_item_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'fill_percent                   => ' || p_changed_attributes(i).fill_percent                  || ' , => ' || delivery_line_info.fill_percent );
         WSH_DEBUG_SV.logmsg(l_module_name, 'fob_code                       => ' || p_changed_attributes(i).fob_code                      || ' , => ' || delivery_line_info.fob_code );
--         WSH_DEBUG_SV.logmsg(l_module_name, 'freight_carrier_code           => ' || p_changed_attributes(i).freight_carrier_code          || ' , => ' || delivery_line_info.freight_carrier_code );
         WSH_DEBUG_SV.logmsg(l_module_name, 'freight_class_cat_id           => ' || p_changed_attributes(i).freight_class_cat_id          || ' , => ' || delivery_line_info.freight_class_cat_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'freight_terms_code             => ' || p_changed_attributes(i).freight_terms_code            || ' , => ' || delivery_line_info.freight_terms_code );
         WSH_DEBUG_SV.logmsg(l_module_name, 'gross_weight                   => ' || p_changed_attributes(i).gross_weight                  || ' , => ' || delivery_line_info.gross_weight );
         WSH_DEBUG_SV.logmsg(l_module_name, 'hazard_class_id                => ' || p_changed_attributes(i).hazard_class_id               || ' , => ' || delivery_line_info.hazard_class_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'hold_code                      => ' || p_changed_attributes(i).hold_code                     || ' , => ' || delivery_line_info.hold_code );
         WSH_DEBUG_SV.logmsg(l_module_name, 'inspection_flag                => ' || p_changed_attributes(i).inspection_flag               || ' , => ' || delivery_line_info.inspection_flag );
         WSH_DEBUG_SV.logmsg(l_module_name, 'intmed_ship_to_contact_id      => ' || p_changed_attributes(i).intmed_ship_to_contact_id     || ' , => ' || delivery_line_info.intmed_ship_to_contact_id );
--         WSH_DEBUG_SV.logmsg(l_module_name, 'intmed_ship_to_org_id          => ' || p_changed_attributes(i).intmed_ship_to_org_id         || ' , => ' || delivery_line_info.intmed_ship_to_org_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'inv_interfaced_flag            => ' || p_changed_attributes(i).inv_interfaced_flag           || ' , => ' || delivery_line_info.inv_interfaced_flag );
         WSH_DEBUG_SV.logmsg(l_module_name, 'inventory_item_id              => ' || p_changed_attributes(i).inventory_item_id             || ' , => ' || delivery_line_info.inventory_item_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'item_description               => ' || p_changed_attributes(i).item_description              || ' , => ' || delivery_line_info.item_description );
--         WSH_DEBUG_SV.logmsg(l_module_name, 'item_type_code                 => ' || p_changed_attributes(i).item_type_code                || ' , => ' || delivery_line_info.item_type_code );
--         WSH_DEBUG_SV.logmsg(l_module_name, 'line_number                    => ' || p_changed_attributes(i).line_number                   || ' , => ' || delivery_line_info.line_number );
         WSH_DEBUG_SV.logmsg(l_module_name, 'load_seq_number                => ' || p_changed_attributes(i).load_seq_number               || ' , => ' || delivery_line_info.load_seq_number );
         WSH_DEBUG_SV.logmsg(l_module_name, 'locator_id                     => ' || p_changed_attributes(i).locator_id                    || ' , => ' || delivery_line_info.locator_id );
--         WSH_DEBUG_SV.logmsg(l_module_name, 'lot_id                         => ' || p_changed_attributes(i).lot_id                        || ' , => ' || delivery_line_info.lot_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'lot_number                     => ' || p_changed_attributes(i).lot_number                    || ' , => ' || delivery_line_info.lot_number );
         WSH_DEBUG_SV.logmsg(l_module_name, 'lpn_content_id                 => ' || p_changed_attributes(i).lpn_content_id                || ' , => ' || delivery_line_info.lpn_content_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'lpn_id                         => ' || p_changed_attributes(i).lpn_id                        || ' , => ' || delivery_line_info.lpn_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'master_container_item_id       => ' || p_changed_attributes(i).master_container_item_id      || ' , => ' || delivery_line_info.master_container_item_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'master_serial_number           => ' || p_changed_attributes(i).master_serial_number          || ' , => ' || delivery_line_info.master_serial_number );
         WSH_DEBUG_SV.logmsg(l_module_name, 'maximum_load_weight            => ' || p_changed_attributes(i).maximum_load_weight           || ' , => ' || delivery_line_info.maximum_load_weight );
         WSH_DEBUG_SV.logmsg(l_module_name, 'maximum_volume                 => ' || p_changed_attributes(i).maximum_volume                || ' , => ' || delivery_line_info.maximum_volume );
         WSH_DEBUG_SV.logmsg(l_module_name, 'minimum_fill_percent           => ' || p_changed_attributes(i).minimum_fill_percent          || ' , => ' || delivery_line_info.minimum_fill_percent );
         WSH_DEBUG_SV.logmsg(l_module_name, 'move_order_line_id             => ' || p_changed_attributes(i).move_order_line_id            || ' , => ' || delivery_line_info.move_order_line_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'movement_id                    => ' || p_changed_attributes(i).movement_id                   || ' , => ' || delivery_line_info.movement_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'mvt_stat_status                => ' || p_changed_attributes(i).mvt_stat_status               || ' , => ' || delivery_line_info.mvt_stat_status );
         WSH_DEBUG_SV.logmsg(l_module_name, 'net_weight                     => ' || p_changed_attributes(i).net_weight                    || ' , => ' || delivery_line_info.net_weight );
         WSH_DEBUG_SV.logmsg(l_module_name, 'oe_interfaced_flag             => ' || p_changed_attributes(i).oe_interfaced_flag            || ' , => ' || delivery_line_info.oe_interfaced_flag );
         WSH_DEBUG_SV.logmsg(l_module_name, 'order_quantity_uom             => ' || p_changed_attributes(i).order_quantity_uom            || ' , => ' || delivery_line_info.src_requested_quantity_uom );
         WSH_DEBUG_SV.logmsg(l_module_name, 'ordered_quantity               => ' || p_changed_attributes(i).ordered_quantity              || ' , => ' || delivery_line_info.src_requested_quantity );
         WSH_DEBUG_SV.logmsg(l_module_name, 'ordered_quantity2              => ' || p_changed_attributes(i).ordered_quantity2             || ' , => ' || delivery_line_info.src_requested_quantity2 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'ordered_quantity_uom2          => ' || p_changed_attributes(i).ordered_quantity_uom2         || ' , => ' || delivery_line_info.src_requested_quantity_uom2 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'org_id                         => ' || p_changed_attributes(i).org_id                        || ' , => ' || delivery_line_info.org_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'organization_id                => ' || p_changed_attributes(i).organization_id               || ' , => ' || delivery_line_info.organization_id );
--         WSH_DEBUG_SV.logmsg(l_module_name, 'original_source_line_id        => ' || p_changed_attributes(i).original_source_line_id       || ' , => ' || delivery_line_info.original_source_line_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'original_subinventory          => ' || p_changed_attributes(i).original_subinventory         || ' , => ' || delivery_line_info.original_subinventory );
         WSH_DEBUG_SV.logmsg(l_module_name, 'packing_instructions           => ' || p_changed_attributes(i).packing_instructions          || ' , => ' || delivery_line_info.packing_instructions );
--         WSH_DEBUG_SV.logmsg(l_module_name, 'pending_quantity               => ' || p_changed_attributes(i).pending_quantity              || ' , => ' || delivery_line_info.pending_quantity );
--         WSH_DEBUG_SV.logmsg(l_module_name, 'pending_quantity2              => ' || p_changed_attributes(i).pending_quantity2             || ' , => ' || delivery_line_info.pending_quantity2 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'pickable_flag                  => ' || p_changed_attributes(i).pickable_flag                 || ' , => ' || delivery_line_info.pickable_flag );
         WSH_DEBUG_SV.logmsg(l_module_name, 'picked_quantity                => ' || p_changed_attributes(i).picked_quantity               || ' , => ' || delivery_line_info.picked_quantity );
         WSH_DEBUG_SV.logmsg(l_module_name, 'picked_quantity2               => ' || p_changed_attributes(i).picked_quantity2              || ' , => ' || delivery_line_info.picked_quantity2 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'preferred_grade                => ' || p_changed_attributes(i).preferred_grade               || ' , => ' || delivery_line_info.preferred_grade );
         WSH_DEBUG_SV.logmsg(l_module_name, 'project_id                     => ' || p_changed_attributes(i).project_id                    || ' , => ' || delivery_line_info.project_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'quality_control_quantity       => ' || p_changed_attributes(i).quality_control_quantity      || ' , => ' || delivery_line_info.quality_control_quantity );
         WSH_DEBUG_SV.logmsg(l_module_name, 'quality_control_quantity2      => ' || p_changed_attributes(i).quality_control_quantity2     || ' , => ' || delivery_line_info.quality_control_quantity2 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'received_quantity              => ' || p_changed_attributes(i).received_quantity             || ' , => ' || delivery_line_info.received_quantity );
         WSH_DEBUG_SV.logmsg(l_module_name, 'received_quantity2             => ' || p_changed_attributes(i).received_quantity2            || ' , => ' || delivery_line_info.received_quantity2 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'released_status                => ' || p_changed_attributes(i).released_status               || ' , => ' || delivery_line_info.released_status );
         WSH_DEBUG_SV.logmsg(l_module_name, 'request_id                     => ' || p_changed_attributes(i).request_id                    || ' , => ' || delivery_line_info.request_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'revision                       => ' || p_changed_attributes(i).revision                      || ' , => ' || delivery_line_info.revision );
         WSH_DEBUG_SV.logmsg(l_module_name, 'seal_code                      => ' || p_changed_attributes(i).seal_code                     || ' , => ' || delivery_line_info.seal_code );
         WSH_DEBUG_SV.logmsg(l_module_name, 'serial_number                  => ' || p_changed_attributes(i).serial_number                 || ' , => ' || delivery_line_info.serial_number );
         --WSH_DEBUG_SV.logmsg(l_module_name, 'ship_from_org_id               => ' || p_changed_attributes(i).ship_from_org_id              || ' , => ' || delivery_line_info.ship_from_org_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'ship_model_complete_flag       => ' || p_changed_attributes(i).ship_model_complete_flag      || ' , => ' || delivery_line_info.ship_model_complete_flag );
         WSH_DEBUG_SV.logmsg(l_module_name, 'ship_set_id                    => ' || p_changed_attributes(i).ship_set_id                   || ' , => ' || delivery_line_info.ship_set_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'ship_to_contact_id             => ' || p_changed_attributes(i).ship_to_contact_id            || ' , => ' || delivery_line_info.ship_to_contact_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'ship_to_org_id                 => ' || p_changed_attributes(i).ship_to_org_id                || ' , => ' || delivery_line_info.ship_to_site_use_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'ship_to_site_use_id            => ' || p_changed_attributes(i).ship_to_site_use_id           || ' , => ' || delivery_line_info.ship_to_site_use_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'ship_tolerance_above           => ' || p_changed_attributes(i).ship_tolerance_above          || ' , => ' || delivery_line_info.ship_tolerance_above );
         WSH_DEBUG_SV.logmsg(l_module_name, 'ship_tolerance_below           => ' || p_changed_attributes(i).ship_tolerance_below          || ' , => ' || delivery_line_info.ship_tolerance_below );
         WSH_DEBUG_SV.logmsg(l_module_name, 'shipment_priority_code         => ' || p_changed_attributes(i).shipment_priority_code        || ' , => ' || delivery_line_info.shipment_priority_code );
         --WSH_DEBUG_SV.logmsg(l_module_name, 'shipped_flag                   => ' || p_changed_attributes(i).shipped_flag                  || ' , => ' || delivery_line_info.shipped_flag );
         WSH_DEBUG_SV.logmsg(l_module_name, 'shipped_quantity               => ' || p_changed_attributes(i).shipped_quantity              || ' , => ' || delivery_line_info.shipped_quantity );
         WSH_DEBUG_SV.logmsg(l_module_name, 'shipped_quantity2              => ' || p_changed_attributes(i).shipped_quantity2             || ' , => ' || delivery_line_info.shipped_quantity2 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'shipping_instructions          => ' || p_changed_attributes(i).shipping_instructions         || ' , => ' || delivery_line_info.shipping_instructions );
         --WSH_DEBUG_SV.logmsg(l_module_name, 'shipping_method_code           => ' || p_changed_attributes(i).shipping_method_code          || ' , => ' || delivery_line_info.shipping_method_code );
         WSH_DEBUG_SV.logmsg(l_module_name, 'sold_to_contact_id             => ' || p_changed_attributes(i).sold_to_contact_id            || ' , => ' || delivery_line_info.sold_to_contact_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'sold_to_org_id                 => ' || p_changed_attributes(i).sold_to_org_id                || ' , => ' || delivery_line_info.customer_id);
         WSH_DEBUG_SV.logmsg(l_module_name, 'source_code                    => ' || p_changed_attributes(i).source_code                   || ' , => ' || delivery_line_info.source_code );
         WSH_DEBUG_SV.logmsg(l_module_name, 'source_header_id               => ' || p_changed_attributes(i).source_header_id              || ' , => ' || delivery_line_info.source_header_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'source_header_number           => ' || p_changed_attributes(i).source_header_number          || ' , => ' || delivery_line_info.source_header_number );
         WSH_DEBUG_SV.logmsg(l_module_name, 'source_header_type_id          => ' || p_changed_attributes(i).source_header_type_id         || ' , => ' || delivery_line_info.source_header_type_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'source_header_type_name        => ' || p_changed_attributes(i).source_header_type_name       || ' , => ' || delivery_line_info.source_header_type_name );
         WSH_DEBUG_SV.logmsg(l_module_name, 'source_line_id                 => ' || p_changed_attributes(i).source_line_id                || ' , => ' || delivery_line_info.source_line_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'source_line_set_id             => ' || p_changed_attributes(i).source_line_set_id            || ' , => ' || delivery_line_info.source_line_set_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'split_from_delivery_detail_id  => ' || p_changed_attributes(i).split_from_delivery_detail_id || ' , => ' || delivery_line_info.split_from_delivery_detail_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'src_requested_quantity         => ' || p_changed_attributes(i).src_requested_quantity        || ' , => ' || delivery_line_info.src_requested_quantity );
         WSH_DEBUG_SV.logmsg(l_module_name, 'src_requested_quantity2        => ' || p_changed_attributes(i).src_requested_quantity2       || ' , => ' || delivery_line_info.src_requested_quantity2 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'src_requested_quantity_uom     => ' || p_changed_attributes(i).src_requested_quantity_uom    || ' , => ' || delivery_line_info.src_requested_quantity_uom );
         WSH_DEBUG_SV.logmsg(l_module_name, 'src_requested_quantity_uom2    => ' || p_changed_attributes(i).src_requested_quantity_uom2   || ' , => ' || delivery_line_info.src_requested_quantity_uom2 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'subinventory                   => ' || p_changed_attributes(i).subinventory                  || ' , => ' || delivery_line_info.subinventory );
         --WSH_DEBUG_SV.logmsg(l_module_name, 'sublot_number                  => ' || p_changed_attributes(i).sublot_number                 || ' , => ' || delivery_line_info.sublot_number );
         WSH_DEBUG_SV.logmsg(l_module_name, 'task_id                        => ' || p_changed_attributes(i).task_id                       || ' , => ' || delivery_line_info.task_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'to_serial_number               => ' || p_changed_attributes(i).to_serial_number              || ' , => ' || delivery_line_info.to_serial_number );
         WSH_DEBUG_SV.logmsg(l_module_name, 'top_model_line_id              => ' || p_changed_attributes(i).top_model_line_id             || ' , => ' || delivery_line_info.top_model_line_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'tp_attribute1                  => ' || p_changed_attributes(i).tp_attribute1                 || ' , => ' || delivery_line_info.tp_attribute1 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'tp_attribute10                 => ' || p_changed_attributes(i).tp_attribute10                || ' , => ' || delivery_line_info.tp_attribute10 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'tp_attribute11                 => ' || p_changed_attributes(i).tp_attribute11                || ' , => ' || delivery_line_info.tp_attribute11 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'tp_attribute12                 => ' || p_changed_attributes(i).tp_attribute12                || ' , => ' || delivery_line_info.tp_attribute12 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'tp_attribute13                 => ' || p_changed_attributes(i).tp_attribute13                || ' , => ' || delivery_line_info.tp_attribute13 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'tp_attribute14                 => ' || p_changed_attributes(i).tp_attribute14                || ' , => ' || delivery_line_info.tp_attribute14 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'tp_attribute15                 => ' || p_changed_attributes(i).tp_attribute15                || ' , => ' || delivery_line_info.tp_attribute15 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'tp_attribute2                  => ' || p_changed_attributes(i).tp_attribute2                 || ' , => ' || delivery_line_info.tp_attribute2 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'tp_attribute3                  => ' || p_changed_attributes(i).tp_attribute3                 || ' , => ' || delivery_line_info.tp_attribute3 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'tp_attribute4                  => ' || p_changed_attributes(i).tp_attribute4                 || ' , => ' || delivery_line_info.tp_attribute4 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'tp_attribute5                  => ' || p_changed_attributes(i).tp_attribute5                 || ' , => ' || delivery_line_info.tp_attribute5 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'tp_attribute6                  => ' || p_changed_attributes(i).tp_attribute6                 || ' , => ' || delivery_line_info.tp_attribute6 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'tp_attribute7                  => ' || p_changed_attributes(i).tp_attribute7                 || ' , => ' || delivery_line_info.tp_attribute7 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'tp_attribute8                  => ' || p_changed_attributes(i).tp_attribute8                 || ' , => ' || delivery_line_info.tp_attribute8 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'tp_attribute9                  => ' || p_changed_attributes(i).tp_attribute9                 || ' , => ' || delivery_line_info.tp_attribute9 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'tp_attribute_category          => ' || p_changed_attributes(i).tp_attribute_category         || ' , => ' || delivery_line_info.tp_attribute_category );
         WSH_DEBUG_SV.logmsg(l_module_name, 'tracking_number                => ' || p_changed_attributes(i).tracking_number               || ' , => ' || delivery_line_info.tracking_number );
         --WSH_DEBUG_SV.logmsg(l_module_name, 'trans_id                       => ' || p_changed_attributes(i).trans_id                      || ' , => ' || delivery_line_info.trans_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'transaction_temp_id            => ' || p_changed_attributes(i).transaction_temp_id           || ' , => ' || delivery_line_info.transaction_temp_id );
         --WSH_DEBUG_SV.logmsg(l_module_name, 'transfer_lpn_id                => ' || p_changed_attributes(i).transfer_lpn_id               || ' , => ' || delivery_line_info.transfer_lpn_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'unit_number                    => ' || p_changed_attributes(i).unit_number                   || ' , => ' || delivery_line_info.unit_number );
         WSH_DEBUG_SV.logmsg(l_module_name, 'unit_price                     => ' || p_changed_attributes(i).unit_price                    || ' , => ' || delivery_line_info.unit_price );
         WSH_DEBUG_SV.logmsg(l_module_name, 'volume                         => ' || p_changed_attributes(i).volume                        || ' , => ' || delivery_line_info.volume );
         WSH_DEBUG_SV.logmsg(l_module_name, 'volume_uom_code                => ' || p_changed_attributes(i).volume_uom_code               || ' , => ' || delivery_line_info.volume_uom_code );
         WSH_DEBUG_SV.logmsg(l_module_name, 'weight_uom_code                => ' || p_changed_attributes(i).weight_uom_code               || ' , => ' || delivery_line_info.weight_uom_code );
         --WSH_DEBUG_SV.logmsg(l_module_name, 'latest_acceptable_date         => ' || p_changed_attributes(i).latest_acceptable_date        || ' , => ' || delivery_line_info.latest_acceptable_date );
         --WSH_DEBUG_SV.logmsg(l_module_name, 'promise_date                   => ' || p_changed_attributes(i).promise_date                  || ' , => ' || delivery_line_info.promise_date );
         --WSH_DEBUG_SV.logmsg(l_module_name, 'schedule_arrival_date          => ' || p_changed_attributes(i).schedule_arrival_date         || ' , => ' || delivery_line_info.schedule_arrival_date );
         --WSH_DEBUG_SV.logmsg(l_module_name, 'earliest_acceptable_date       => ' || p_changed_attributes(i).earliest_acceptable_date      || ' , => ' || delivery_line_info.earliest_acceptable_date );
         --WSH_DEBUG_SV.logmsg(l_module_name, 'earliest_ship_date             => ' || p_changed_attributes(i).earliest_ship_date            || ' , => ' || delivery_line_info.earliest_ship_date );
         WSH_DEBUG_SV.logmsg(l_module_name, 'filled_volume                  => ' || p_changed_attributes(i).filled_volume                 || ' , => ' || delivery_line_info.filled_volume );
         WSH_DEBUG_SV.logmsg(l_module_name, 'Changed Subinventory           => ' || p_changed_attributes(i).subinventory                  || ' , => ' || delivery_line_info.original_subinventory );
      END IF;
      --
      */
      IF (
             ( ( nvl(p_changed_attributes(i).arrival_set_id, FND_API.G_MISS_NUM) = nvl(delivery_line_info.arrival_set_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).arrival_set_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).ato_line_id, FND_API.G_MISS_NUM) = nvl(delivery_line_info.ato_line_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).ato_line_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).attribute1, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.attribute1, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).attribute1 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).attribute10, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.attribute10, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).attribute10 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).attribute11, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.attribute11, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).attribute11 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).attribute12, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.attribute12, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).attribute12 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).attribute13, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.attribute13, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).attribute13 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).attribute14, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.attribute14, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).attribute14 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).attribute15, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.attribute15, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).attribute15 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).attribute2, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.attribute2, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).attribute2 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).attribute3, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.attribute3, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).attribute3 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).attribute4, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.attribute4, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).attribute4 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).attribute5, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.attribute5, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).attribute5 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).attribute6, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.attribute6, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).attribute6 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).attribute7, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.attribute7, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).attribute7 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).attribute8, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.attribute8, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).attribute8 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).attribute9, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.attribute9, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).attribute9 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).attribute_category, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.attribute_category, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).attribute_category = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).cancelled_quantity, FND_API.G_MISS_NUM) = nvl(delivery_line_info.cancelled_quantity, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).cancelled_quantity = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).cancelled_quantity2, FND_API.G_MISS_NUM) = nvl(delivery_line_info.cancelled_quantity2, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).cancelled_quantity2 = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).carrier_id, FND_API.G_MISS_NUM) = nvl(delivery_line_info.carrier_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).carrier_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).classification, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.classification, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).classification = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).commodity_code_cat_id, FND_API.G_MISS_NUM) = nvl(delivery_line_info.commodity_code_cat_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).commodity_code_cat_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).container_flag, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.container_flag, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).container_flag = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).container_name, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.container_name, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).container_name = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).container_type_code, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.container_type_code, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).container_type_code = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).country_of_origin, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.country_of_origin, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).country_of_origin = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).currency_code, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.currency_code, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).currency_code = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).cust_model_serial_number, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.cust_model_serial_number, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).cust_model_serial_number = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).cust_po_number, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.cust_po_number, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).cust_po_number = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).customer_dock_code, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.customer_dock_code, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).customer_dock_code = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).customer_id, FND_API.G_MISS_NUM) = nvl(delivery_line_info.customer_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).customer_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).customer_job, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.customer_job, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).customer_job = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).customer_prod_seq, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.customer_prod_seq, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).customer_prod_seq = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).customer_production_line, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.customer_production_line, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).customer_production_line = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).customer_requested_lot_flag, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.customer_requested_lot_flag, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).customer_requested_lot_flag = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).cycle_count_quantity, FND_API.G_MISS_NUM) = nvl(delivery_line_info.cycle_count_quantity, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).cycle_count_quantity = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).cycle_count_quantity2, FND_API.G_MISS_NUM) = nvl(delivery_line_info.cycle_count_quantity2, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).cycle_count_quantity2 = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).date_requested, FND_API.G_MISS_DATE) = nvl(delivery_line_info.date_requested, FND_API.G_MISS_DATE ) )
              or ( p_changed_attributes(i).date_requested = FND_API.G_MISS_DATE ) )
         and ( (  nvl(p_changed_attributes(i).date_scheduled, FND_API.G_MISS_DATE) = nvl(delivery_line_info.date_scheduled, FND_API.G_MISS_DATE ) )
              or ( p_changed_attributes(i).date_scheduled = FND_API.G_MISS_DATE ) )
         and ( (  nvl(p_changed_attributes(i).deliver_to_contact_id, FND_API.G_MISS_NUM) = nvl(delivery_line_info.deliver_to_contact_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).deliver_to_contact_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).deliver_to_org_id, FND_API.G_MISS_NUM) = nvl(delivery_line_info.deliver_to_site_use_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).deliver_to_org_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).delivered_quantity, FND_API.G_MISS_NUM) = nvl(delivery_line_info.delivered_quantity, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).delivered_quantity = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).delivered_quantity2, FND_API.G_MISS_NUM) = nvl(delivery_line_info.delivered_quantity2, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).delivered_quantity2 = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).delivery_detail_id, FND_API.G_MISS_NUM) = nvl(delivery_line_info.delivery_detail_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).delivery_detail_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).dep_plan_required_flag, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.dep_plan_required_flag, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).dep_plan_required_flag = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).detail_container_item_id, FND_API.G_MISS_NUM) = nvl(delivery_line_info.detail_container_item_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).detail_container_item_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).fill_percent, FND_API.G_MISS_NUM) = nvl(delivery_line_info.fill_percent, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).fill_percent = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).fob_code, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.fob_code, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).fob_code = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).freight_class_cat_id, FND_API.G_MISS_NUM) = nvl(delivery_line_info.freight_class_cat_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).freight_class_cat_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).freight_terms_code, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.freight_terms_code, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).freight_terms_code = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).gross_weight, FND_API.G_MISS_NUM) = nvl(delivery_line_info.gross_weight, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).gross_weight = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).hazard_class_id, FND_API.G_MISS_NUM) = nvl(delivery_line_info.hazard_class_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).hazard_class_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).hold_code, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.hold_code, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).hold_code = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).inspection_flag, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.inspection_flag, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).inspection_flag = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).intmed_ship_to_contact_id, FND_API.G_MISS_NUM) = nvl(delivery_line_info.intmed_ship_to_contact_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).intmed_ship_to_contact_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).inv_interfaced_flag, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.inv_interfaced_flag, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).inv_interfaced_flag = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).inventory_item_id, FND_API.G_MISS_NUM) = nvl(delivery_line_info.inventory_item_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).inventory_item_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).item_description, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.item_description, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).item_description = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).load_seq_number, FND_API.G_MISS_NUM) = nvl(delivery_line_info.load_seq_number, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).load_seq_number = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).locator_id, FND_API.G_MISS_NUM) = nvl(delivery_line_info.locator_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).locator_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).lot_number, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.lot_number, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).lot_number = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).lpn_content_id, FND_API.G_MISS_NUM) = nvl(delivery_line_info.lpn_content_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).lpn_content_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).lpn_id, FND_API.G_MISS_NUM) = nvl(delivery_line_info.lpn_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).lpn_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).master_container_item_id, FND_API.G_MISS_NUM) = nvl(delivery_line_info.master_container_item_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).master_container_item_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).master_serial_number, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.master_serial_number, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).master_serial_number = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).maximum_load_weight, FND_API.G_MISS_NUM) = nvl(delivery_line_info.maximum_load_weight, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).maximum_load_weight = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).maximum_volume, FND_API.G_MISS_NUM) = nvl(delivery_line_info.maximum_volume, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).maximum_volume = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).minimum_fill_percent, FND_API.G_MISS_NUM) = nvl(delivery_line_info.minimum_fill_percent, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).minimum_fill_percent = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).move_order_line_id, FND_API.G_MISS_NUM) = nvl(delivery_line_info.move_order_line_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).move_order_line_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).movement_id, FND_API.G_MISS_NUM) = nvl(delivery_line_info.movement_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).movement_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).mvt_stat_status, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.mvt_stat_status, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).mvt_stat_status = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).net_weight, FND_API.G_MISS_NUM) = nvl(delivery_line_info.net_weight, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).net_weight = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).oe_interfaced_flag, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.oe_interfaced_flag, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).oe_interfaced_flag = FND_API.G_MISS_CHAR ) )
      -- Only ordered quantity and uom is allowed to update even if line is partially shipped.
      /*
         and ( (  nvl(p_changed_attributes(i).order_quantity_uom, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.src_requested_quantity_uom, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).order_quantity_uom = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).ordered_quantity, FND_API.G_MISS_NUM) = nvl(delivery_line_info.src_requested_quantity, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).ordered_quantity = FND_API.G_MISS_NUM ) )
      */
         and ( (  nvl(p_changed_attributes(i).ordered_quantity2, FND_API.G_MISS_NUM) = nvl(delivery_line_info.src_requested_quantity2, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).ordered_quantity2 = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).ordered_quantity_uom2, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.src_requested_quantity_uom2, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).ordered_quantity_uom2 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).org_id, FND_API.G_MISS_NUM) = nvl(delivery_line_info.org_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).org_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).organization_id, FND_API.G_MISS_NUM) = nvl(delivery_line_info.organization_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).organization_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).subinventory, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.original_subinventory, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).subinventory = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).packing_instructions, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.packing_instructions, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).packing_instructions = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).pickable_flag, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.pickable_flag, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).pickable_flag = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).picked_quantity, FND_API.G_MISS_NUM) = nvl(delivery_line_info.picked_quantity, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).picked_quantity = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).picked_quantity2, FND_API.G_MISS_NUM) = nvl(delivery_line_info.picked_quantity2, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).picked_quantity2 = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).preferred_grade, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.preferred_grade, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).preferred_grade = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).project_id, FND_API.G_MISS_NUM) = nvl(delivery_line_info.project_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).project_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).quality_control_quantity, FND_API.G_MISS_NUM) = nvl(delivery_line_info.quality_control_quantity, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).quality_control_quantity = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).quality_control_quantity2, FND_API.G_MISS_NUM) = nvl(delivery_line_info.quality_control_quantity2, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).quality_control_quantity2 = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).received_quantity, FND_API.G_MISS_NUM) = nvl(delivery_line_info.received_quantity, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).received_quantity = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).received_quantity2, FND_API.G_MISS_NUM) = nvl(delivery_line_info.received_quantity2, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).received_quantity2 = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).released_status, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.released_status, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).released_status = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).request_id, FND_API.G_MISS_NUM) = nvl(delivery_line_info.request_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).request_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).revision, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.revision, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).revision = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).seal_code, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.seal_code, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).seal_code = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).serial_number, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.serial_number, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).serial_number = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).ship_model_complete_flag, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.ship_model_complete_flag, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).ship_model_complete_flag = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).ship_set_id, FND_API.G_MISS_NUM) = nvl(delivery_line_info.ship_set_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).ship_set_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).ship_to_contact_id, FND_API.G_MISS_NUM) = nvl(delivery_line_info.ship_to_contact_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).ship_to_contact_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).ship_to_org_id, FND_API.G_MISS_NUM) = nvl(delivery_line_info.ship_to_site_use_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).ship_to_org_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).ship_to_site_use_id, FND_API.G_MISS_NUM) = nvl(delivery_line_info.ship_to_site_use_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).ship_to_site_use_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).ship_tolerance_above, FND_API.G_MISS_NUM) = nvl(delivery_line_info.ship_tolerance_above, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).ship_tolerance_above = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).ship_tolerance_below, FND_API.G_MISS_NUM) = nvl(delivery_line_info.ship_tolerance_below, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).ship_tolerance_below = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).shipment_priority_code, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.shipment_priority_code, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).shipment_priority_code = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).shipped_quantity, FND_API.G_MISS_NUM) = nvl(delivery_line_info.shipped_quantity, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).shipped_quantity = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).shipped_quantity2, FND_API.G_MISS_NUM) = nvl(delivery_line_info.shipped_quantity2, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).shipped_quantity2 = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).shipping_instructions, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.shipping_instructions, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).shipping_instructions = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).sold_to_contact_id, FND_API.G_MISS_NUM) = nvl(delivery_line_info.sold_to_contact_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).sold_to_contact_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).sold_to_org_id, FND_API.G_MISS_NUM) = nvl(delivery_line_info.customer_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).sold_to_org_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).source_code, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.source_code, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).source_code = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).source_header_id, FND_API.G_MISS_NUM) = nvl(delivery_line_info.source_header_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).source_header_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).source_header_number, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.source_header_number, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).source_header_number = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).source_header_type_id, FND_API.G_MISS_NUM) = nvl(delivery_line_info.source_header_type_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).source_header_type_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).source_header_type_name, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.source_header_type_name, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).source_header_type_name = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).source_line_id, FND_API.G_MISS_NUM) = nvl(delivery_line_info.source_line_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).source_line_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).source_line_set_id, FND_API.G_MISS_NUM) = nvl(delivery_line_info.source_line_set_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).source_line_set_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).split_from_delivery_detail_id, FND_API.G_MISS_NUM) = nvl(delivery_line_info.split_from_delivery_detail_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).split_from_delivery_detail_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).src_requested_quantity, FND_API.G_MISS_NUM) = nvl(delivery_line_info.src_requested_quantity, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).src_requested_quantity = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).src_requested_quantity2, FND_API.G_MISS_NUM) = nvl(delivery_line_info.src_requested_quantity2, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).src_requested_quantity2 = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).src_requested_quantity_uom, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.src_requested_quantity_uom, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).src_requested_quantity_uom = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).src_requested_quantity_uom2, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.src_requested_quantity_uom2, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).src_requested_quantity_uom2 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).task_id, FND_API.G_MISS_NUM) = nvl(delivery_line_info.task_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).task_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).to_serial_number, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.to_serial_number, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).to_serial_number = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).top_model_line_id, FND_API.G_MISS_NUM) = nvl(delivery_line_info.top_model_line_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).top_model_line_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).tp_attribute1, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.tp_attribute1, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).tp_attribute1 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).tp_attribute10, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.tp_attribute10, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).tp_attribute10 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).tp_attribute11, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.tp_attribute11, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).tp_attribute11 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).tp_attribute12, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.tp_attribute12, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).tp_attribute12 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).tp_attribute13, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.tp_attribute13, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).tp_attribute13 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).tp_attribute14, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.tp_attribute14, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).tp_attribute14 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).tp_attribute15, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.tp_attribute15, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).tp_attribute15 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).tp_attribute2, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.tp_attribute2, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).tp_attribute2 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).tp_attribute3, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.tp_attribute3, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).tp_attribute3 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).tp_attribute4, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.tp_attribute4, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).tp_attribute4 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).tp_attribute5, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.tp_attribute5, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).tp_attribute5 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).tp_attribute6, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.tp_attribute6, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).tp_attribute6 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).tp_attribute7, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.tp_attribute7, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).tp_attribute7 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).tp_attribute8, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.tp_attribute8, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).tp_attribute8 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).tp_attribute9, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.tp_attribute9, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).tp_attribute9 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).tp_attribute_category, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.tp_attribute_category, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).tp_attribute_category = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).tracking_number, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.tracking_number, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).tracking_number = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).transaction_temp_id, FND_API.G_MISS_NUM) = nvl(delivery_line_info.transaction_temp_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).transaction_temp_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).unit_number, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.unit_number, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).unit_number = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).unit_price, FND_API.G_MISS_NUM) = nvl(delivery_line_info.unit_price, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).unit_price = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).volume, FND_API.G_MISS_NUM) = nvl(delivery_line_info.volume, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).volume = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).volume_uom_code, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.volume_uom_code, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).volume_uom_code = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).weight_uom_code, FND_API.G_MISS_CHAR) = nvl(delivery_line_info.weight_uom_code, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).weight_uom_code = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).filled_volume, FND_API.G_MISS_NUM) = nvl(delivery_line_info.filled_volume, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).filled_volume = FND_API.G_MISS_NUM ) )
          )
      THEN
         --Nothing has been changed
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'INSIDE VALIDATION SUCCESS' );
         END IF;
         --
         x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      ELSE
         --Raise Error
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Attributes does not match so returning error' );
         END IF;
         --
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      END IF;
   END LOOP;
   END LOOP;

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'Return Status',x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
EXCEPTION
   WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.Default_Handler('WSH_SHIPMENT_REQUEST_PKG.Validate_Delivery_Line');
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Validate_Delivery_Line;
--
--=============================================================================
-- PRIVATE PROCEDURE :
--       Print_OE_Header_Record
--
-- PARAMETERS:
--       p_header_rec         => Order Header record
--       p_header_val_rec     => Order Header value record
--       p_customer_info      => Customer Information
--       p_action_request_tbl => Action Type collection type
-- COMMENT:
--       API to print order header, customer, action request attributes, If
--       Shipping debug is enabled.
--=============================================================================
--
PROCEDURE Print_OE_Header_Record(
          p_header_rec         IN OE_ORDER_PUB.Header_Rec_Type,
          p_header_val_rec     IN OE_ORDER_PUB.Header_Val_Rec_Type,
          p_customer_info      IN OE_ORDER_PUB.Customer_Info_Table_Type,
          p_action_request_tbl IN OE_ORDER_PUB.Request_Tbl_Type )
IS
   --
   l_debug_on BOOLEAN;
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Print_OE_Header_Record';
   --
BEGIN
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.logmsg(l_module_name, '===============================================');
      WSH_DEBUG_SV.logmsg(l_module_name, '|          HEADER RECORD DETAILS              |');
      WSH_DEBUG_SV.logmsg(l_module_name, '===============================================');
      WSH_DEBUG_SV.log(l_module_name, 'p_header_rec.order_number',            p_header_rec.order_number            );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_rec.header_id',               p_header_rec.header_id               );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_rec.operation',               p_header_rec.operation               );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_rec.cancelled_flag',          p_header_rec.cancelled_flag          );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_rec.change_reason',           p_header_rec.change_reason           );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_rec.ship_from_org_id',        p_header_rec.ship_from_org_id        );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_rec.sold_to_org_id',          p_header_rec.sold_to_org_id          );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_rec.sold_to_contact_id',      p_header_rec.sold_to_contact_id      );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_rec.ship_to_org_id',          p_header_rec.ship_to_org_id          );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_rec.ship_to_contact_id',      p_header_rec.ship_to_contact_id      );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_rec.invoice_to_org_id',       p_header_rec.invoice_to_org_id       );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_rec.invoice_to_contact_id',   p_header_rec.invoice_to_contact_id   );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_rec.deliver_to_org_id',       p_header_rec.deliver_to_org_id       );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_rec.deliver_to_contact_id',   p_header_rec.deliver_to_contact_id   );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_rec.shipping_method_code',    p_header_rec.shipping_method_code    );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_rec.freight_terms_code',      p_header_rec.freight_terms_code      );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_rec.fob_point_code',          p_header_rec.fob_point_code          );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_rec.order_type_id',           p_header_rec.order_type_id           );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_rec.price_list_id',           p_header_rec.price_list_id           );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_rec.payment_term_id',         p_header_rec.payment_term_id         );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_rec.org_id',                  p_header_rec.org_id                  );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_rec.sold_from_org_id',        p_header_rec.sold_from_org_id        );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_rec.order_source_id',         p_header_rec.order_source_id         );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_rec.transactional_curr_code', p_header_rec.transactional_curr_code );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_rec.salesrep_id',             p_header_rec.salesrep_id             );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_rec.tax_exempt_flag',         p_header_rec.tax_exempt_flag         );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_rec.open_flag',               p_header_rec.open_flag               );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_rec.booked_flag',             p_header_rec.booked_flag             );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_rec.ordered_date',            p_header_rec.ordered_date            );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_rec.order_category_code',     p_header_rec.order_category_code     );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_rec.sold_to_customer_ref',    p_header_rec.sold_to_customer_ref    );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_rec.ship_to_customer_ref',    p_header_rec.ship_to_customer_ref    );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_rec.invoice_to_customer_ref', p_header_rec.invoice_to_customer_ref );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_rec.deliver_to_customer_ref', p_header_rec.deliver_to_customer_ref );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_rec.ship_to_address_ref',     p_header_rec.ship_to_address_ref     );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_rec.invoice_to_address_ref',  p_header_rec.invoice_to_address_ref  );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_rec.deliver_to_address_ref',  p_header_rec.deliver_to_address_ref  );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_rec.ship_to_contact_ref',     p_header_rec.ship_to_contact_ref     );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_rec.invoice_to_contact_ref',  p_header_rec.invoice_to_contact_ref  );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_rec.deliver_to_contact_ref',  p_header_rec.deliver_to_contact_ref  );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_rec.version_number',          p_header_rec.version_number          );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_rec.orig_sys_document_ref',   p_header_rec.orig_sys_document_ref   );

   /* Printing Val Record is Commented since values are not populated during Shipment Request Processing
      WSH_DEBUG_SV.logmsg(l_module_name, '===============================================');
      WSH_DEBUG_SV.logmsg(l_module_name, '|        HEADER VAL RECORD DETAILS             |');
      WSH_DEBUG_SV.logmsg(l_module_name, '===============================================');
      WSH_DEBUG_SV.log(l_module_name, 'p_header_val_rec.sold_to_org',         p_header_val_rec.sold_to_org         );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_val_rec.sold_to_address1',    p_header_val_rec.sold_to_address1    );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_val_rec.sold_to_address2',    p_header_val_rec.sold_to_address2    );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_val_rec.sold_to_address3',    p_header_val_rec.sold_to_address3    );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_val_rec.sold_to_address4',    p_header_val_rec.sold_to_address4    );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_val_rec.sold_to_city',        p_header_val_rec.sold_to_city        );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_val_rec.sold_to_state',       p_header_val_rec.sold_to_state       );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_val_rec.sold_to_country',     p_header_val_rec.sold_to_country     );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_val_rec.sold_to_zip',         p_header_val_rec.sold_to_zip         );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_val_rec.sold_to_contact',     p_header_val_rec.sold_to_contact     );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_val_rec.ship_to_org',         p_header_val_rec.ship_to_org         );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_val_rec.ship_to_address1',    p_header_val_rec.ship_to_address1    );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_val_rec.ship_to_address2',    p_header_val_rec.ship_to_address2    );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_val_rec.ship_to_address3',    p_header_val_rec.ship_to_address3    );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_val_rec.ship_to_address4',    p_header_val_rec.ship_to_address4    );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_val_rec.ship_to_city',        p_header_val_rec.ship_to_city        );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_val_rec.ship_to_state',       p_header_val_rec.ship_to_state       );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_val_rec.ship_to_country',     p_header_val_rec.ship_to_country     );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_val_rec.ship_to_zip',         p_header_val_rec.ship_to_zip         );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_val_rec.ship_to_contact',     p_header_val_rec.ship_to_contact     );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_val_rec.invoice_to_org',      p_header_val_rec.invoice_to_org      );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_val_rec.invoice_to_address1', p_header_val_rec.invoice_to_address1 );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_val_rec.invoice_to_address2', p_header_val_rec.invoice_to_address2 );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_val_rec.invoice_to_address3', p_header_val_rec.invoice_to_address3 );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_val_rec.invoice_to_address4', p_header_val_rec.invoice_to_address4 );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_val_rec.invoice_to_city',     p_header_val_rec.invoice_to_city     );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_val_rec.invoice_to_state',    p_header_val_rec.invoice_to_state    );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_val_rec.invoice_to_country',  p_header_val_rec.invoice_to_country  );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_val_rec.invoice_to_zip',      p_header_val_rec.invoice_to_zip      );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_val_rec.invoice_to_contact',  p_header_val_rec.invoice_to_contact  );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_val_rec.deliver_to_org',      p_header_val_rec.deliver_to_org      );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_val_rec.deliver_to_address1', p_header_val_rec.deliver_to_address1 );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_val_rec.deliver_to_address2', p_header_val_rec.deliver_to_address2 );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_val_rec.deliver_to_address3', p_header_val_rec.deliver_to_address3 );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_val_rec.deliver_to_address4', p_header_val_rec.deliver_to_address4 );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_val_rec.deliver_to_city',     p_header_val_rec.deliver_to_city     );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_val_rec.deliver_to_state',    p_header_val_rec.deliver_to_state    );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_val_rec.deliver_to_country',  p_header_val_rec.deliver_to_country  );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_val_rec.deliver_to_zip',      p_header_val_rec.deliver_to_zip      );
      WSH_DEBUG_SV.log(l_module_name, 'p_header_val_rec.deliver_to_contact',  p_header_val_rec.deliver_to_contact  );
   */

      IF p_customer_info.count > 0 THEN
         WSH_DEBUG_SV.logmsg(l_module_name, '===============================================');
         WSH_DEBUG_SV.logmsg(l_module_name, '|               ADDRESS DETAILS                |');
         WSH_DEBUG_SV.logmsg(l_module_name, '===============================================');
         FOR i in p_customer_info.first..p_customer_info.last
         LOOP
            WSH_DEBUG_SV.log(l_module_name, 'INDEX', i );
            WSH_DEBUG_SV.log(l_module_name, 'customer_info_ref',        p_customer_info(i).customer_info_ref        );
            WSH_DEBUG_SV.log(l_module_name, 'parent_customer_info_ref', p_customer_info(i).parent_customer_info_ref );
            WSH_DEBUG_SV.log(l_module_name, 'customer_type',            p_customer_info(i).customer_type            );
            WSH_DEBUG_SV.log(l_module_name, 'customer_info_type_code',  p_customer_info(i).customer_info_type_code  );

            IF p_customer_info(i).customer_info_ref = g_sold_to_ref or
               p_customer_info(i).customer_info_ref = g_ship_to_ref or
               p_customer_info(i).customer_info_ref = g_invoice_to_ref or
               p_customer_info(i).customer_info_ref = g_deliver_to_ref
            THEN
               WSH_DEBUG_SV.log(l_module_name, 'customer_id',           p_customer_info(i).customer_id        );
               WSH_DEBUG_SV.log(l_module_name, 'organization_name',     p_customer_info(i).organization_name  );
            END IF;

            IF p_customer_info(i).customer_info_ref = g_ship_to_address_ref or
               p_customer_info(i).customer_info_ref = g_invoice_to_address_ref or
               p_customer_info(i).customer_info_ref = g_deliver_to_address_ref
            THEN
               WSH_DEBUG_SV.log(l_module_name, 'site_use_id', p_customer_info(i).site_use_id );
               WSH_DEBUG_SV.log(l_module_name, 'site_number', p_customer_info(i).site_number );
               WSH_DEBUG_SV.log(l_module_name, 'address1',    p_customer_info(i).address1    );
               WSH_DEBUG_SV.log(l_module_name, 'address2',    p_customer_info(i).address2    );
               WSH_DEBUG_SV.log(l_module_name, 'address3',    p_customer_info(i).address3    );
               WSH_DEBUG_SV.log(l_module_name, 'address4',    p_customer_info(i).address4    );
               WSH_DEBUG_SV.log(l_module_name, 'city',        p_customer_info(i).city        );
               WSH_DEBUG_SV.log(l_module_name, 'state',       p_customer_info(i).state       );
               WSH_DEBUG_SV.log(l_module_name, 'postal_code', p_customer_info(i).postal_code );
               WSH_DEBUG_SV.log(l_module_name, 'country',     p_customer_info(i).country     );
               WSH_DEBUG_SV.log(l_module_name, 'location_number', p_customer_info(i).location_number );
            END IF;

            IF p_customer_info(i).customer_info_ref = g_sold_to_contact_ref or
               p_customer_info(i).customer_info_ref = g_ship_to_contact_ref or
               p_customer_info(i).customer_info_ref = g_invoice_to_contact_ref or
               p_customer_info(i).customer_info_ref = g_deliver_to_contact_ref
            THEN
               WSH_DEBUG_SV.log(l_module_name, 'contact_id',         p_customer_info(i).contact_id         );
               WSH_DEBUG_SV.log(l_module_name, 'contact_number',     p_customer_info(i).contact_number     );
               WSH_DEBUG_SV.log(l_module_name, 'person_first_name',  p_customer_info(i).person_first_name  );
               WSH_DEBUG_SV.log(l_module_name, 'person_middle_name', p_customer_info(i).person_middle_name );
               WSH_DEBUG_SV.log(l_module_name, 'person_last_name',   p_customer_info(i).person_last_name   );
               WSH_DEBUG_SV.log(l_module_name, 'person_name_suffix', p_customer_info(i).person_name_suffix );
               WSH_DEBUG_SV.log(l_module_name, 'person_title',       p_customer_info(i).person_title       );
               WSH_DEBUG_SV.log(l_module_name, 'email_address',      p_customer_info(i).email_address      );
               WSH_DEBUG_SV.log(l_module_name, 'phone_country_code', p_customer_info(i).phone_country_code );
               WSH_DEBUG_SV.log(l_module_name, 'phone_area_code',    p_customer_info(i).phone_area_code    );
               WSH_DEBUG_SV.log(l_module_name, 'phone_number',       p_customer_info(i).phone_number       );
               WSH_DEBUG_SV.log(l_module_name, 'phone_extension',    p_customer_info(i).phone_extension    );
            END IF;
         END LOOP;
      END IF;

      IF p_action_request_tbl.count > 0 THEN
         WSH_DEBUG_SV.logmsg(l_module_name, '===============================================');
         WSH_DEBUG_SV.logmsg(l_module_name, '|           ACTION REQUEST DETAILS             |');
         WSH_DEBUG_SV.logmsg(l_module_name, '===============================================');

         FOR i in p_action_request_tbl.first..p_action_request_tbl.last
         LOOP
            WSH_DEBUG_SV.log(l_module_name, 'p_action_request_tbl.request_type',  p_action_request_tbl(i).request_type  );
            WSH_DEBUG_SV.log(l_module_name, 'p_action_request_tbl.request_type',  p_action_request_tbl(i).entity_code  );
         END LOOP;
      END IF;
   END IF;
   --

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
EXCEPTION
   WHEN OTHERS THEN
         WSH_UTIL_CORE.Default_Handler('WSH_SHIPMENT_REQUEST_PKG.Print_OE_Header_Record');
         --
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
         --
END Print_OE_Header_Record;
--
--=============================================================================
-- PRIVATE PROCEDURE :
--       Print_OE_Line_Record
--
-- PARAMETERS:
--       p_line_tbl     => Order Line record
--       p_line_val_tbl => Order Line value record
-- COMMENT:
--       API to print order line attributes, If Shipping debug is enabled.
--=============================================================================
--
PROCEDURE Print_OE_Line_Record(
          p_line_tbl     IN OE_ORDER_PUB.Line_Tbl_Type,
          p_line_val_tbl IN OE_ORDER_PUB.Line_Val_Tbl_Type )
IS
   --
   l_debug_on BOOLEAN;
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Print_OE_Line_Record';
   --
BEGIN
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
   END IF;
   --

   IF ( p_line_tbl.count > 0 ) THEN
      FOR i in p_line_tbl.first..p_line_tbl.last
      LOOP
         WSH_DEBUG_SV.logmsg(l_module_name, '===============================================');
         WSH_DEBUG_SV.logmsg(l_module_name, '|          LINE RECORD DETAILS - ' || i || '           |');
         WSH_DEBUG_SV.logmsg(l_module_name, '===============================================');
         WSH_DEBUG_SV.log(l_module_name, 'line_id',                p_line_tbl(i).line_id                 );
         WSH_DEBUG_SV.log(l_module_name, 'operation',              p_line_tbl(i).operation               );
         WSH_DEBUG_SV.log(l_module_name, 'change_reason',          p_line_tbl(i).change_reason           );
         WSH_DEBUG_SV.log(l_module_name, 'line_number',            p_line_tbl(i).line_number             );
         WSH_DEBUG_SV.log(l_module_name, 'shipment_number',        p_line_tbl(i).shipment_number         );
         WSH_DEBUG_SV.log(l_module_name, 'ordered_quantity',       p_line_tbl(i).ordered_quantity        );
         WSH_DEBUG_SV.log(l_module_name, 'order_quantity_uom',     p_line_tbl(i).order_quantity_uom      );
         WSH_DEBUG_SV.log(l_module_name, 'ship_from_org_id',       p_line_tbl(i).ship_from_org_id        );
         WSH_DEBUG_SV.log(l_module_name, 'ordered_item',           p_line_tbl(i).ordered_item            );
         WSH_DEBUG_SV.log(l_module_name, 'inventory_item_id',      p_line_tbl(i).inventory_item_id       );
         WSH_DEBUG_SV.log(l_module_name, 'ordered_item_id',        p_line_tbl(i).ordered_item_id         );
         WSH_DEBUG_SV.log(l_module_name, 'ship_to_org_id',         p_line_tbl(i).ship_to_org_id          );
         WSH_DEBUG_SV.log(l_module_name, 'invoice_to_org_id',      p_line_tbl(i).invoice_to_org_id       );
         WSH_DEBUG_SV.log(l_module_name, 'deliver_to_org_id',      p_line_tbl(i).deliver_to_org_id       );
         WSH_DEBUG_SV.log(l_module_name, 'ship_to_contact_id',     p_line_tbl(i).ship_to_contact_id      );
         WSH_DEBUG_SV.log(l_module_name, 'invoice_to_contact_id',  p_line_tbl(i).invoice_to_contact_id   );
         WSH_DEBUG_SV.log(l_module_name, 'deliver_to_contact_id',  p_line_tbl(i).deliver_to_contact_id   );
         WSH_DEBUG_SV.log(l_module_name, 'shipping_method_code',   p_line_tbl(i).shipping_method_code    );
         WSH_DEBUG_SV.log(l_module_name, 'freight_terms_code',     p_line_tbl(i).freight_terms_code      );
         WSH_DEBUG_SV.log(l_module_name, 'fob_point_code',         p_line_tbl(i).fob_point_code          );
         WSH_DEBUG_SV.log(l_module_name, 'item_identifier_type',   p_line_tbl(i).item_identifier_type    );
         WSH_DEBUG_SV.log(l_module_name, 'ship_tolerance_above',   p_line_tbl(i).ship_tolerance_above    );
         WSH_DEBUG_SV.log(l_module_name, 'ship_tolerance_below',   p_line_tbl(i).ship_tolerance_below    );
         WSH_DEBUG_SV.log(l_module_name, 'request_date',           p_line_tbl(i).request_date            );
         WSH_DEBUG_SV.log(l_module_name, 'schedule_ship_date',     p_line_tbl(i).schedule_ship_date      );
         WSH_DEBUG_SV.log(l_module_name, 'ship_set',               p_line_tbl(i).ship_set                );
         WSH_DEBUG_SV.log(l_module_name, 'shipping_instructions',  p_line_tbl(i).shipping_instructions   );
         WSH_DEBUG_SV.log(l_module_name, 'packing_instructions',   p_line_tbl(i).packing_instructions    );
         WSH_DEBUG_SV.log(l_module_name, 'shipment_priority_code', p_line_tbl(i).shipment_priority_code  );
         WSH_DEBUG_SV.log(l_module_name, 'calculate_price_flag',   p_line_tbl(i).calculate_price_flag    );
         WSH_DEBUG_SV.log(l_module_name, 'cust_po_number',         p_line_tbl(i).cust_po_number          );
         WSH_DEBUG_SV.log(l_module_name, 'subinventory',           p_line_tbl(i).subinventory            );
         WSH_DEBUG_SV.log(l_module_name, 'unit_list_price',        p_line_tbl(i).unit_list_price         );
         WSH_DEBUG_SV.log(l_module_name, 'unit_selling_price',     p_line_tbl(i).unit_selling_price      );
         WSH_DEBUG_SV.log(l_module_name, 'sold_to_customer_ref',   p_line_tbl(i).sold_to_customer_ref    );
         WSH_DEBUG_SV.log(l_module_name, 'ship_to_customer_ref',   p_line_tbl(i).ship_to_customer_ref    );
         WSH_DEBUG_SV.log(l_module_name, 'invoice_to_customer_ref',p_line_tbl(i).invoice_to_customer_ref );
         WSH_DEBUG_SV.log(l_module_name, 'deliver_to_customer_ref',p_line_tbl(i).deliver_to_customer_ref );
         WSH_DEBUG_SV.log(l_module_name, 'ship_to_address_ref',    p_line_tbl(i).ship_to_address_ref     );
         WSH_DEBUG_SV.log(l_module_name, 'invoice_to_address_ref', p_line_tbl(i).invoice_to_address_ref  );
         WSH_DEBUG_SV.log(l_module_name, 'deliver_to_address_ref', p_line_tbl(i).deliver_to_address_ref  );
         WSH_DEBUG_SV.log(l_module_name, 'ship_to_contact_ref',    p_line_tbl(i).ship_to_contact_ref     );
         WSH_DEBUG_SV.log(l_module_name, 'invoice_to_contact_ref', p_line_tbl(i).invoice_to_contact_ref  );
         WSH_DEBUG_SV.log(l_module_name, 'deliver_to_contact_ref', p_line_tbl(i).deliver_to_contact_ref  );
         WSH_DEBUG_SV.log(l_module_name, 'orig_sys_document_ref',  p_line_tbl(i).orig_sys_document_ref   );
         WSH_DEBUG_SV.log(l_module_name, 'orig_sys_line_ref',      p_line_tbl(i).orig_sys_line_ref       );

      END LOOP;
   END IF;

   /* Printing Val Record is Commented since values are not populated during Shipment Request Processing
   IF ( p_line_val_tbl.count > 0 ) THEN
      FOR i in p_line_val_tbl.first..p_line_val_tbl.last
      LOOP
         WSH_DEBUG_SV.logmsg(l_module_name, '===============================================');
         WSH_DEBUG_SV.logmsg(l_module_name, '|          LINE VAL RECORD DETAILS - ' || i || '        |');
         WSH_DEBUG_SV.logmsg(l_module_name, '===============================================');
         WSH_DEBUG_SV.log(l_module_name, 'ship_to_org',         p_line_val_tbl(i).ship_to_org         );
         WSH_DEBUG_SV.log(l_module_name, 'ship_to_address1',    p_line_val_tbl(i).ship_to_address1    );
         WSH_DEBUG_SV.log(l_module_name, 'ship_to_address2',    p_line_val_tbl(i).ship_to_address2    );
         WSH_DEBUG_SV.log(l_module_name, 'ship_to_address3',    p_line_val_tbl(i).ship_to_address3    );
         WSH_DEBUG_SV.log(l_module_name, 'ship_to_address4',    p_line_val_tbl(i).ship_to_address4    );
         WSH_DEBUG_SV.log(l_module_name, 'ship_to_city',        p_line_val_tbl(i).ship_to_city        );
         WSH_DEBUG_SV.log(l_module_name, 'ship_to_state',       p_line_val_tbl(i).ship_to_state       );
         WSH_DEBUG_SV.log(l_module_name, 'ship_to_country',     p_line_val_tbl(i).ship_to_country     );
         WSH_DEBUG_SV.log(l_module_name, 'ship_to_zip',         p_line_val_tbl(i).ship_to_zip         );
         WSH_DEBUG_SV.log(l_module_name, 'ship_to_contact',     p_line_val_tbl(i).ship_to_contact     );
         WSH_DEBUG_SV.log(l_module_name, 'invoice_to_org',      p_line_val_tbl(i).invoice_to_org      );
         WSH_DEBUG_SV.log(l_module_name, 'invoice_to_address1', p_line_val_tbl(i).invoice_to_address1 );
         WSH_DEBUG_SV.log(l_module_name, 'invoice_to_address2', p_line_val_tbl(i).invoice_to_address2 );
         WSH_DEBUG_SV.log(l_module_name, 'invoice_to_address3', p_line_val_tbl(i).invoice_to_address3 );
         WSH_DEBUG_SV.log(l_module_name, 'invoice_to_address4', p_line_val_tbl(i).invoice_to_address4 );
         WSH_DEBUG_SV.log(l_module_name, 'invoice_to_city',     p_line_val_tbl(i).invoice_to_city     );
         WSH_DEBUG_SV.log(l_module_name, 'invoice_to_state',    p_line_val_tbl(i).invoice_to_state    );
         WSH_DEBUG_SV.log(l_module_name, 'invoice_to_country',  p_line_val_tbl(i).invoice_to_country  );
         WSH_DEBUG_SV.log(l_module_name, 'invoice_to_zip',      p_line_val_tbl(i).invoice_to_zip      );
         WSH_DEBUG_SV.log(l_module_name, 'invoice_to_contact',  p_line_val_tbl(i).invoice_to_contact  );
         WSH_DEBUG_SV.log(l_module_name, 'deliver_to_org',      p_line_val_tbl(i).deliver_to_org      );
         WSH_DEBUG_SV.log(l_module_name, 'deliver_to_address1', p_line_val_tbl(i).deliver_to_address1 );
         WSH_DEBUG_SV.log(l_module_name, 'deliver_to_address2', p_line_val_tbl(i).deliver_to_address2 );
         WSH_DEBUG_SV.log(l_module_name, 'deliver_to_address3', p_line_val_tbl(i).deliver_to_address3 );
         WSH_DEBUG_SV.log(l_module_name, 'deliver_to_address4', p_line_val_tbl(i).deliver_to_address4 );
         WSH_DEBUG_SV.log(l_module_name, 'deliver_to_city',     p_line_val_tbl(i).deliver_to_city     );
         WSH_DEBUG_SV.log(l_module_name, 'deliver_to_state',    p_line_val_tbl(i).deliver_to_state    );
         WSH_DEBUG_SV.log(l_module_name, 'deliver_to_country',  p_line_val_tbl(i).deliver_to_country  );
         WSH_DEBUG_SV.log(l_module_name, 'deliver_to_zip',      p_line_val_tbl(i).deliver_to_zip      );
         WSH_DEBUG_SV.log(l_module_name, 'deliver_to_contact',  p_line_val_tbl(i).deliver_to_contact  );
      END LOOP;
   END IF;
   */

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
EXCEPTION
   WHEN OTHERS THEN
         WSH_UTIL_CORE.Default_Handler('WSH_SHIPMENT_REQUEST_PKG.Print_OE_Line_Record');
         --
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
         --
END Print_OE_Line_Record;
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Check_Header_Attr_Changed
--
-- PARAMETERS:
--       p_del_interface_rec => Delivery Interface Record
--       p_om_header_rec     => Standalone related order header attributes record
--       x_return_status     => Return Status of API (Either S,E,U)
--
-- COMMENT:
--       API to check if following order header attributes are being changed
--       1) ShipTo Customer, Address, Contact
--       2) InvoiceTo Customer, Address, Contact
--       3) DeliverTo Customer, Address, Contact
--       4) Ship Method Code
--       5) Freight Terms
--       6) FOB Code
--=============================================================================
--
PROCEDURE Check_Header_Attr_Changed(
          p_del_interface_rec IN OUT NOCOPY Del_Interface_Rec_Type,
          p_om_header_rec     IN OUT NOCOPY OM_Header_Rec_Type,
          x_return_status     OUT NOCOPY VARCHAR2 )
IS
   l_sold_to                    NUMBER;
   l_ship_to                    NUMBER;
   l_invoice_to                 NUMBER;
   l_deliver_to                 NUMBER;
   l_ship_to_site               NUMBER;
   l_invoice_to_site            NUMBER;
   l_deliver_to_site            NUMBER;
   l_ship_to_contact            NUMBER;
   l_invoice_to_contact         NUMBER;
   l_deliver_to_contact         NUMBER;

   --
   l_debug_on BOOLEAN;
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Check_Header_Attr_Changed';
   --
BEGIN
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
   END IF;
   --

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   p_om_header_rec.header_attributes_changed := FALSE;

   IF p_del_interface_rec.organization_id <> p_om_header_rec.ship_from_org_id THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('WSH', 'WSH_STND_REJECT_ORG_CHANGE');
      WSH_UTIL_CORE.Add_Message(x_return_status, l_module_name );
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Error => Ship From Changed');
         WSH_DEBUG_SV.logmsg(l_module_name, 'Order Header Ship_From => ' || p_om_header_rec.ship_from_org_id
                                    || ', New Ship_From => ' || p_del_interface_rec.organization_id);
      END IF;
      --
   END IF;

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'Order Header Sold-To => ' || p_om_header_rec.sold_to_org_id
                                    || ', New Sold-To => ' || p_del_interface_rec.customer_id);
   END IF;
   --

   l_sold_to := p_del_interface_rec.customer_id;

   --Sold-To Cannot be changed, once order is booked
   IF ( p_del_interface_rec.customer_id is null and
        p_del_interface_rec.customer_name is not null )
   THEN
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Calling OE_Value_To_Id.Sold_To_Org', WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      l_sold_to := OE_Value_To_Id.Sold_To_Org(
                            p_sold_to_org     => p_del_interface_rec.customer_name,
                            p_customer_number => NULL );

      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'SoldTo Customer derived from Customer Name', l_sold_to );
      END IF;
      --

      IF nvl(l_sold_to, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN
         l_sold_to := null;
      ELSE
         p_del_interface_rec.customer_id := l_sold_to;
      END IF;
   END IF;

   IF ( nvl(l_sold_to, FND_API.G_MISS_NUM) <> p_om_header_rec.sold_to_org_id ) THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('WSH', 'WSH_STND_REJECT_SOLDTO_CHANGE');
      WSH_UTIL_CORE.Add_Message(x_return_status, l_module_name );
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Error => SoldTo customer changed');
      END IF;
      --
   END IF;

   IF x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'Return Status',x_return_status);
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
   END IF;

   -- Ship-To Customer
   IF ( p_del_interface_rec.ship_to_customer_id is null and
        p_del_interface_rec.ship_to_customer_name is not null )
   THEN
      --Check if ShipTo Customer is same as SoldTo
      IF ( p_del_interface_rec.ship_to_customer_name = p_del_interface_rec.customer_name )
      THEN
         p_del_interface_rec.ship_to_customer_id := p_del_interface_rec.customer_id;
      ELSE
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Calling OE_Value_To_Id.Sold_To_Org to derive Ship-To customer', WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --
         l_ship_to := OE_Value_To_Id.Sold_To_Org(
                               p_sold_to_org     => p_del_interface_rec.ship_to_customer_name,
                               p_customer_number => NULL );

         IF nvl(l_ship_to, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN
            p_om_header_rec.ship_to_changed := TRUE;
         ELSE
            p_del_interface_rec.ship_to_customer_id := l_ship_to;
         END IF;
      END IF;
   END IF;

   --Check if InvoiceTo Customer is same as SoldTo/ShipTo
   IF ( p_del_interface_rec.invoice_to_customer_id is null and
        p_del_interface_rec.invoice_to_customer_name = p_del_interface_rec.customer_name )
   THEN
      p_del_interface_rec.invoice_to_customer_id := p_del_interface_rec.customer_id;
   ELSIF ( p_del_interface_rec.invoice_to_customer_id is null and
           p_del_interface_rec.invoice_to_customer_name = p_del_interface_rec.ship_to_customer_name )
   THEN
      IF p_om_header_rec.ship_to_changed THEN
         p_om_header_rec.invoice_to_changed := TRUE;
      ELSE
         p_del_interface_rec.invoice_to_customer_id := p_del_interface_rec.ship_to_customer_id;
      END IF;
   END IF;

   -- Derive Invoice-To Customer
   IF ( p_del_interface_rec.invoice_to_customer_id is null and
        p_del_interface_rec.invoice_to_customer_name is not null and
        p_om_header_rec.invoice_to_changed = FALSE )
   THEN
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Calling OE_Value_To_Id.Sold_To_Org to derive Invoice-To customer', WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      l_invoice_to := OE_Value_To_Id.Sold_To_Org(
                            p_sold_to_org     => p_del_interface_rec.invoice_to_customer_name,
                            p_customer_number => NULL );

      IF nvl(l_invoice_to, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN
         p_om_header_rec.invoice_to_changed := TRUE;
      ELSE
         p_del_interface_rec.invoice_to_customer_id := l_invoice_to;
      END IF;
   END IF;

   --Check if DeliverTo Customer is same as SoldTo/ShipTo/InvoiceTo
   IF ( p_del_interface_rec.deliver_to_customer_id is null and
        p_del_interface_rec.deliver_to_customer_name is not null and
        p_del_interface_rec.deliver_to_customer_name = p_del_interface_rec.customer_name )
   THEN
      p_del_interface_rec.deliver_to_customer_id := p_del_interface_rec.customer_id;
   ELSIF ( p_del_interface_rec.deliver_to_customer_id is null and
           p_del_interface_rec.deliver_to_customer_name is not null and
           p_del_interface_rec.deliver_to_customer_name = p_del_interface_rec.ship_to_customer_name )
   THEN
      IF p_om_header_rec.ship_to_changed THEN
         p_om_header_rec.deliver_to_changed := TRUE;
      ELSE
         p_del_interface_rec.deliver_to_customer_id := p_del_interface_rec.ship_to_customer_id;
      END IF;
   ELSIF ( p_del_interface_rec.deliver_to_customer_id is null and
           p_del_interface_rec.deliver_to_customer_name is not null and
           p_del_interface_rec.deliver_to_customer_name = p_del_interface_rec.invoice_to_customer_name )
   THEN
      IF p_om_header_rec.invoice_to_changed THEN
         p_om_header_rec.deliver_to_changed := TRUE;
      ELSE
         p_del_interface_rec.deliver_to_customer_id := p_del_interface_rec.invoice_to_customer_id;
      END IF;
   END IF;

   -- Derive Deliver-To Customer
   IF ( p_del_interface_rec.deliver_to_customer_id is null and
        p_del_interface_rec.deliver_to_customer_name is not null and
        p_om_header_rec.deliver_to_changed = FALSE )
   THEN
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Calling OE_Value_To_Id.Sold_To_Org to derive Deliver-To customer', WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      l_deliver_to := OE_Value_To_Id.Sold_To_Org(
                            p_sold_to_org     => p_del_interface_rec.deliver_to_customer_name,
                            p_customer_number => NULL );

      IF nvl(l_deliver_to, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN
         p_om_header_rec.deliver_to_changed := TRUE;
      ELSE
         p_del_interface_rec.deliver_to_customer_id := l_deliver_to;
      END IF;
   END IF;

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'Customer Ids' );
      WSH_DEBUG_SV.logmsg(l_module_name, '==============');
      WSH_DEBUG_SV.log(l_module_name, 'Sold-To Customer Id', p_del_interface_rec.customer_id);
      WSH_DEBUG_SV.log(l_module_name, 'Ship-To Customer Id', p_del_interface_rec.ship_to_customer_id);
      WSH_DEBUG_SV.log(l_module_name, 'Invoice-To Customer Id', p_del_interface_rec.invoice_to_customer_id);
      WSH_DEBUG_SV.log(l_module_name, 'Deliver-To Customer Id', p_del_interface_rec.deliver_to_customer_id);
   END IF;
   --

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'Order Header ShipTo Site => ' || p_om_header_rec.ship_to_org_id
                                    || ', New ShipTo Site => ' || p_del_interface_rec.ship_to_address_id);
   END IF;
   --

   IF ( p_del_interface_rec.ship_to_address_id is null and
        p_del_interface_rec.ship_to_address1 is not null and
        p_om_header_rec.ship_to_changed = FALSE )
   THEN -- { Ship-To
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Calling OE_Value_To_Id.Ship_To_Org', WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      l_ship_to_site :=
            OE_Value_To_Id.Ship_To_Org(
                     p_ship_to_address1    => p_del_interface_rec.ship_to_address1,
                     p_ship_to_address2    => p_del_interface_rec.ship_to_address2,
                     p_ship_to_address3    => p_del_interface_rec.ship_to_address3,
                     p_ship_to_address4    => p_del_interface_rec.ship_to_address4,
                     p_ship_to_location    => NULL,
                     p_ship_to_org         => NULL,
                     p_sold_to_org_id      => p_del_interface_rec.ship_to_customer_id,
                     p_ship_to_city        => p_del_interface_rec.ship_to_city,
                     p_ship_to_state       => p_del_interface_rec.ship_to_state,
                     p_ship_to_postal_code => p_del_interface_rec.ship_to_postal_code,
                     p_ship_to_country     => p_del_interface_rec.ship_to_country,
                     p_ship_to_customer_id => p_del_interface_rec.ship_to_customer_id );

      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'ShipTo Site Use Id', l_ship_to_site);
      END IF;
      --
      IF ( nvl(l_ship_to_site, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM )
      THEN
         p_om_header_rec.ship_to_changed := TRUE;
      ELSIF ( l_ship_to_site <> nvl(p_om_header_rec.ship_to_org_id, FND_API.G_MISS_NUM) ) THEN
         p_del_interface_rec.ship_to_address_id := l_ship_to_site;
         p_om_header_rec.ship_to_changed := TRUE;
      ELSE
         p_del_interface_rec.ship_to_address_id := l_ship_to_site;
      END IF;
   ELSIF ( p_del_interface_rec.ship_to_customer_id is not null and
           p_del_interface_rec.ship_to_address_id is not null and
           p_del_interface_rec.ship_to_address_id <> nvl(p_om_header_rec.ship_to_org_id, FND_API.G_MISS_NUM) )
   THEN
      p_om_header_rec.ship_to_changed := TRUE;
   END IF; -- } Ship-To

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'Order Header InvoiceTo Site => ' || p_om_header_rec.Invoice_to_org_id
                                    || ', New InvoiceTo Site => ' || p_del_interface_rec.Invoice_to_address_id);
   END IF;
   --

   -- Derive InvoiceTo Address
   IF ( p_del_interface_rec.invoice_to_address_id is null and
        p_del_interface_rec.invoice_to_address1 is not null and
        p_om_header_rec.invoice_to_changed = FALSE )
   THEN -- { Invoice-To
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Calling OE_Value_To_Id.Invoice_To_Org', WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      l_invoice_to_site :=
            OE_Value_To_Id.Invoice_To_Org(
                     p_invoice_to_address1    => p_del_interface_rec.invoice_to_address1,
                     p_invoice_to_address2    => p_del_interface_rec.invoice_to_address2,
                     p_invoice_to_address3    => p_del_interface_rec.invoice_to_address3,
                     p_invoice_to_address4    => p_del_interface_rec.invoice_to_address4,
                     p_invoice_to_location    => NULL,
                     p_invoice_to_org         => NULL,
                     p_sold_to_org_id         => p_del_interface_rec.invoice_to_customer_id,
                     p_invoice_to_city        => p_del_interface_rec.invoice_to_city,
                     p_invoice_to_state       => p_del_interface_rec.invoice_to_state,
                     p_invoice_to_postal_code => p_del_interface_rec.invoice_to_postal_code,
                     p_invoice_to_country     => p_del_interface_rec.invoice_to_country,
                     p_invoice_to_customer_id => p_del_interface_rec.invoice_to_customer_id );

      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'InvoiceTo Site l_invoice_to_site', l_invoice_to_site);
      END IF;
      --

      IF ( nvl(l_invoice_to_site, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM )
      THEN
         p_om_header_rec.invoice_to_changed := TRUE;
      ELSIF ( l_invoice_to_site <> nvl(p_om_header_rec.invoice_to_org_id, FND_API.G_MISS_NUM) ) THEN
         p_del_interface_rec.invoice_to_address_id := l_invoice_to_site;
         p_om_header_rec.invoice_to_changed := TRUE;
      ELSE
         p_del_interface_rec.invoice_to_address_id := l_invoice_to_site;
      END IF;
   ELSIF ( p_del_interface_rec.invoice_to_customer_id is not null and
           p_del_interface_rec.invoice_to_address_id is not null and
           p_del_interface_rec.invoice_to_address_id <> nvl(p_om_header_rec.invoice_to_org_id, FND_API.G_MISS_NUM) )
   THEN
      p_om_header_rec.invoice_to_changed := TRUE;
   END IF; -- } Invoice-To

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'Order Header DeliverTo Site => ' || p_om_header_rec.Deliver_to_org_id
                                    || ', New DeliverTo Site => ' || p_del_interface_rec.Deliver_to_address_id);
   END IF;
   --

   -- Derive DeliverTo Address
   IF ( p_del_interface_rec.deliver_to_address_id is null and
        p_del_interface_rec.deliver_to_address1 is not null and
        p_om_header_rec.deliver_to_changed = FALSE )
   THEN -- { Deliver-To
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Calling OE_Value_To_Id.Deliver_To_Org', WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      l_deliver_to_site :=
            OE_Value_To_Id.Deliver_To_Org(
                     p_deliver_to_address1    => p_del_interface_rec.deliver_to_address1,
                     p_deliver_to_address2    => p_del_interface_rec.deliver_to_address2,
                     p_deliver_to_address3    => p_del_interface_rec.deliver_to_address3,
                     p_deliver_to_address4    => p_del_interface_rec.deliver_to_address4,
                     p_deliver_to_location    => NULL,
                     p_deliver_to_org         => NULL,
                     p_sold_to_org_id         => p_del_interface_rec.deliver_to_customer_id,
                     p_deliver_to_city        => p_del_interface_rec.deliver_to_city,
                     p_deliver_to_state       => p_del_interface_rec.deliver_to_state,
                     p_deliver_to_postal_code => p_del_interface_rec.deliver_to_postal_code,
                     p_deliver_to_country     => p_del_interface_rec.deliver_to_country,
                     p_deliver_to_customer_id => p_del_interface_rec.deliver_to_customer_id );

      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'DeliverTo Site l_deliver_to_site', l_deliver_to_site);
      END IF;
      --

      IF ( nvl(l_deliver_to_site, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM )
      THEN
         p_om_header_rec.deliver_to_changed := TRUE;
      ELSIF ( l_deliver_to_site <> nvl(p_om_header_rec.deliver_to_org_id, FND_API.G_MISS_NUM) ) THEN
         p_del_interface_rec.deliver_to_address_id := l_deliver_to_site;
         p_om_header_rec.deliver_to_changed := TRUE;
      ELSE
         p_del_interface_rec.deliver_to_address_id := l_deliver_to_site;
      END IF;
   ELSIF ( ( p_del_interface_rec.deliver_to_customer_id is not null and
             p_del_interface_rec.deliver_to_address_id is not null and
             p_del_interface_rec.deliver_to_address_id <> nvl(p_om_header_rec.deliver_to_org_id, FND_API.G_MISS_NUM) ) OR
           ( p_del_interface_rec.deliver_to_address_id is null and
             p_del_interface_rec.deliver_to_address1 is null and
             p_om_header_rec.deliver_to_org_id is not null ) )
   THEN
      p_om_header_rec.deliver_to_changed := TRUE;
   END IF; -- } Deliver-To

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'Site Use Ids' );
      WSH_DEBUG_SV.logmsg(l_module_name, '==============');
      WSH_DEBUG_SV.log(l_module_name, 'ShipTo Site Id', p_del_interface_rec.ship_to_address_id);
      WSH_DEBUG_SV.log(l_module_name, 'InvoiceTo Site Id', p_del_interface_rec.invoice_to_address_id);
      WSH_DEBUG_SV.log(l_module_name, 'DeliverTo Site Id', p_del_interface_rec.deliver_to_address_id);
   END IF;
   --

   -- Ship-To-Contact
   IF ( p_del_interface_rec.ship_to_contact_id is not null and
        p_del_interface_rec.ship_to_contact_id <> nvl(p_om_header_rec.ship_to_contact_id, FND_API.G_MISS_NUM) )
   THEN
      p_om_header_rec.ship_to_contact_changed := TRUE;
   ELSIF ( p_del_interface_rec.ship_to_contact_id is null and
           p_del_interface_rec.ship_to_contact_name is not null and
           p_del_interface_rec.ship_to_customer_id is null )
   THEN -- {
      p_om_header_rec.ship_to_contact_changed := TRUE;
   ELSIF ( p_del_interface_rec.ship_to_contact_id is null and
           p_del_interface_rec.ship_to_contact_name is not null )
   THEN -- {
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Calling OE_Value_To_Id.Sold_To_Contact Ship-To-Contact', WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      l_ship_to_contact :=
            OE_Value_To_Id.Sold_To_Contact (
                     p_sold_to_contact => p_del_interface_rec.ship_to_contact_name,
                     p_sold_to_org_id  => p_del_interface_rec.ship_to_customer_id );

      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'ShipTo Contact => ' || l_ship_to_contact ||
                              ', Order Header ShipTo Contact => ' || p_om_header_rec.ship_to_contact_id);
      END IF;
      --

      IF ( nvl(l_ship_to_contact, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM )
      THEN
         p_om_header_rec.ship_to_contact_changed := TRUE;
      ELSIF ( l_ship_to_contact <>
              nvl(p_om_header_rec.ship_to_contact_id, FND_API.G_MISS_NUM) )
      THEN
         p_del_interface_rec.ship_to_contact_id := l_ship_to_contact;
         p_om_header_rec.ship_to_contact_changed := TRUE;
      END IF;
   ELSIF ( p_del_interface_rec.ship_to_contact_id is null and
           p_del_interface_rec.ship_to_contact_name is null and
           p_om_header_rec.ship_to_contact_id is not null )
   THEN
      p_om_header_rec.ship_to_contact_changed := TRUE;
   END IF; -- } Ship-To-Contact

   --Check if InvoiceTo Contact is same as ShipTo's
   IF ( p_del_interface_rec.invoice_to_customer_id  = p_del_interface_rec.ship_to_customer_id and
        p_del_interface_rec.invoice_to_contact_name = p_del_interface_rec.ship_to_contact_name )
   THEN
      IF p_om_header_rec.ship_to_contact_changed THEN
         p_om_header_rec.invoice_to_contact_changed := TRUE;
      ELSE
         p_del_interface_rec.invoice_to_contact_id := p_del_interface_rec.ship_to_contact_id;
      END IF;
   END IF;

   -- Derive Invoice-To-Contact
   IF ( p_del_interface_rec.invoice_to_contact_id is not null and
        p_del_interface_rec.invoice_to_contact_id <> nvl(p_om_header_rec.invoice_to_contact_id, FND_API.G_MISS_NUM) )
   THEN
      p_om_header_rec.invoice_to_contact_changed := TRUE;
   ELSIF ( p_del_interface_rec.invoice_to_contact_id is null and
           p_del_interface_rec.invoice_to_contact_name is not null and
           p_del_interface_rec.invoice_to_customer_id is null )
   THEN
      p_om_header_rec.invoice_to_contact_changed := TRUE;
   ELSIF ( p_del_interface_rec.invoice_to_contact_id is null and
           p_del_interface_rec.invoice_to_contact_name is not null and
           p_om_header_rec.invoice_to_contact_changed = FALSE )
   THEN -- {
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Calling OE_Value_To_Id.Sold_To_Contact Invoice-To-Contact', WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      l_invoice_to_contact :=
            OE_Value_To_Id.Sold_To_Contact (
                     p_sold_to_contact => p_del_interface_rec.invoice_to_contact_name,
                     p_sold_to_org_id  => p_del_interface_rec.invoice_to_customer_id );

      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'InvoiceTo Contact => ' || l_invoice_to_contact ||
                              ', Order Header InvoiceTo Contact => ' || p_om_header_rec.invoice_to_contact_id);
      END IF;
      --

      IF ( nvl(l_invoice_to_contact, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM )
      THEN
         p_om_header_rec.invoice_to_contact_changed := TRUE;
      ELSIF ( l_invoice_to_contact <>
              nvl(p_om_header_rec.invoice_to_contact_id, FND_API.G_MISS_NUM) )
      THEN
         p_del_interface_rec.invoice_to_contact_id := l_invoice_to_contact;
         p_om_header_rec.invoice_to_contact_changed := TRUE;
      END IF;
   ELSIF ( p_del_interface_rec.invoice_to_contact_id is null and
           p_del_interface_rec.invoice_to_contact_name is null and
           p_om_header_rec.invoice_to_contact_id is not null )
   THEN
      p_om_header_rec.invoice_to_contact_changed := TRUE;
   END IF; -- } Invoice-To-Contact

   --Check if DeliverTo Contact is same as ShipTo's/InvoiceTo's
   IF ( p_del_interface_rec.deliver_to_customer_id  = p_del_interface_rec.ship_to_customer_id and
        p_del_interface_rec.deliver_to_contact_name = p_del_interface_rec.ship_to_contact_name )
   THEN
      IF p_om_header_rec.ship_to_contact_changed THEN
         p_om_header_rec.deliver_to_contact_changed := TRUE;
      ELSE
         p_del_interface_rec.deliver_to_contact_id := p_del_interface_rec.ship_to_contact_id;
      END IF;
   ELSIF ( p_del_interface_rec.deliver_to_customer_id  = p_del_interface_rec.invoice_to_customer_id and
           p_del_interface_rec.deliver_to_contact_name = p_del_interface_rec.invoice_to_contact_name )
   THEN
      IF p_om_header_rec.invoice_to_contact_changed THEN
         p_om_header_rec.deliver_to_contact_changed := TRUE;
      ELSE
         p_del_interface_rec.deliver_to_contact_id := p_del_interface_rec.invoice_to_contact_id;
      END IF;
   END IF;

   -- Deliver-To-Contact
   IF ( p_del_interface_rec.deliver_to_contact_id is not null and
        p_del_interface_rec.deliver_to_contact_id <> nvl(p_om_header_rec.deliver_to_contact_id, FND_API.G_MISS_NUM) )
   THEN
      p_om_header_rec.deliver_to_contact_changed := TRUE;
   ELSIF ( p_del_interface_rec.deliver_to_contact_id is null and
           p_del_interface_rec.deliver_to_contact_name is not null and
           p_del_interface_rec.deliver_to_customer_id is null )
   THEN
      p_om_header_rec.deliver_to_contact_changed := TRUE;
   ELSIF ( p_del_interface_rec.deliver_to_contact_id is null and
           p_del_interface_rec.deliver_to_contact_name is not null and
           p_om_header_rec.deliver_to_contact_changed = FALSE )
   THEN -- {
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Calling OE_Value_To_Id.Sold_To_Contact for Deliver-To-Contact', WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      l_deliver_to_contact :=
            OE_Value_To_Id.Sold_To_Contact (
                     p_sold_to_contact => p_del_interface_rec.deliver_to_contact_name,
                     p_sold_to_org_id  => p_del_interface_rec.deliver_to_customer_id );

      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'DeliverTo Contact => ' || l_deliver_to_contact ||
                              ', Order Header DeliverTo Contact => ' || p_om_header_rec.deliver_to_contact_id);
      END IF;
      --

      IF ( nvl(l_deliver_to_contact, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM )
      THEN
         p_om_header_rec.deliver_to_contact_changed := TRUE;
      ELSIF ( l_deliver_to_contact <>
              nvl(p_om_header_rec.deliver_to_contact_id, FND_API.G_MISS_NUM) )
      THEN
         p_del_interface_rec.deliver_to_contact_id := l_deliver_to_contact;
         p_om_header_rec.deliver_to_contact_changed := TRUE;
      END IF;
   ELSIF ( p_del_interface_rec.deliver_to_contact_id is null and
           p_del_interface_rec.deliver_to_contact_name is null and
           p_om_header_rec.deliver_to_contact_id is not null )
   THEN
      p_om_header_rec.deliver_to_contact_changed := TRUE;
   END IF; -- } Deliver-To-Contact

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'Contact Ids' );
      WSH_DEBUG_SV.logmsg(l_module_name, '============');
      WSH_DEBUG_SV.log(l_module_name, 'ShipTo Contact', p_del_interface_rec.ship_to_contact_id);
      WSH_DEBUG_SV.log(l_module_name, 'InvoiceTo Contact', p_del_interface_rec.invoice_to_contact_id);
      WSH_DEBUG_SV.log(l_module_name, 'DeliverTo Contact', p_del_interface_rec.deliver_to_contact_id);
   END IF;
   --

   IF ( nvl(p_om_header_rec.shipping_method_code, FND_API.G_MISS_CHAR ) <>
                nvl(p_del_interface_rec.ship_method_code, FND_API.G_MISS_CHAR) )
   THEN
      p_om_header_rec.shipping_method_changed := TRUE;
   END IF;

   IF ( nvl(p_del_interface_rec.freight_terms_code, FND_API.G_MISS_CHAR) <>
            nvl(p_om_header_rec.freight_terms_code, FND_API.G_MISS_CHAR) )
   THEN
      p_om_header_rec.freight_terms_changed := TRUE;
   END IF;

   IF ( nvl(p_del_interface_rec.fob_code, FND_API.G_MISS_CHAR) <>
            nvl(p_om_header_rec.fob_point_code, FND_API.G_MISS_CHAR) )
   THEN
      p_om_header_rec.fob_point_changed := TRUE;
   END IF;

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'Header Attributes Changed:');
      WSH_DEBUG_SV.logmsg(l_module_name, '===========================');
      IF p_om_header_rec.ship_to_changed THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'CHANGED: Order Header ShipTo Site => ' || p_om_header_rec.ship_to_org_id
                                    || ', New ShipTo Site => ' || p_del_interface_rec.ship_to_address_id
                                    || ', New ShipTo Address1 => ' || p_del_interface_rec.ship_to_address1 );
      END IF;

      IF p_om_header_rec.invoice_to_changed THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'CHANGED: Order Header InvoiceTo Site => ' || p_om_header_rec.invoice_to_org_id
                                       || ', New InvoiceTo Site => ' || p_del_interface_rec.invoice_to_address_id
                                       || ', New InvoiceTo Address1 => ' || p_del_interface_rec.invoice_to_address1 );
      END IF;

      IF p_om_header_rec.deliver_to_changed THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'CHANGED: Order Header DeliverTo Site => ' || p_om_header_rec.deliver_to_org_id
                                       || ', New DeliverTo Site => ' || p_del_interface_rec.deliver_to_address_id
                                       || ', New DeliverTo Address1 => ' || p_del_interface_rec.deliver_to_address1 );
      END IF;

      IF p_om_header_rec.ship_to_contact_changed THEN
         WSH_DEBUG_SV.logmsg(l_module_name,
                      'Changed: New ShipTo Contact => ' || p_del_interface_rec.ship_to_contact_id ||
                      ', New ShipTo Contact Name => ' || p_del_interface_rec.ship_to_contact_name ||
                      ', Order Header ShipTo Contact => ' || p_om_header_rec.ship_to_contact_id );
      END IF;

      IF p_om_header_rec.invoice_to_contact_changed THEN
         WSH_DEBUG_SV.logmsg(l_module_name,
                      'Changed: New InvoiceTo Contact => ' || p_del_interface_rec.invoice_to_contact_id ||
                      ', New InvoiceTo Contact Name => ' || p_del_interface_rec.invoice_to_contact_name ||
                      ', Order Header InvoiceTo Contact => ' || p_om_header_rec.invoice_to_contact_id );
      END IF;

      IF p_om_header_rec.deliver_to_contact_changed THEN
         WSH_DEBUG_SV.logmsg(l_module_name,
                      'Changed: DeliverTo Contact => ' || p_del_interface_rec.deliver_to_contact_id ||
                         ', New DeliverTo Contact Name => ' || p_del_interface_rec.deliver_to_contact_name ||
                      ', Order Header DeliverTo Contact => ' || p_om_header_rec.deliver_to_contact_id );
      END IF;

      IF p_om_header_rec.shipping_method_changed THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Changed: Order Header Ship_Method_Code => ' || p_om_header_rec.shipping_method_code
                                       || ', New Ship_Method_Code => ' || p_del_interface_rec.ship_method_code);
      END IF;

      IF p_om_header_rec.freight_terms_changed THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Changed: Order Header Freight_Terms => ' || p_om_header_rec.freight_terms_code
                                       || ', New Freight_Terms => ' || p_del_interface_rec.freight_terms_code);
      END IF;

      IF p_om_header_rec.fob_point_changed THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Changed: Order Header FOB_Code => ' || p_om_header_rec.fob_point_code
                                       || ', New FOB_Code => ' || p_del_interface_rec.fob_code);
      END IF;
      WSH_DEBUG_SV.logmsg(l_module_name, '===========================');
   END IF;
   --

   IF ( p_om_header_rec.ship_to_changed or
        p_om_header_rec.invoice_to_changed or
        p_om_header_rec.deliver_to_changed or
        p_om_header_rec.invoice_to_contact_changed or
        p_om_header_rec.deliver_to_contact_changed or
        p_om_header_rec.ship_to_contact_changed or
        p_om_header_rec.shipping_method_changed or
        p_om_header_rec.freight_terms_changed or
        p_om_header_rec.fob_point_changed )
   THEN
      p_om_header_rec.header_attributes_changed := TRUE;
   END IF;
   --

   IF l_debug_on THEN
      IF p_om_header_rec.header_attributes_changed THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'p_om_header_rec.header_attributes_changed is TRUE');
      ELSE
         WSH_DEBUG_SV.logmsg(l_module_name, 'p_om_header_rec.header_attributes_changed is FALSE');
      END IF;
      WSH_DEBUG_SV.log(l_module_name, 'Return Status',x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
EXCEPTION
   WHEN OTHERS THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         WSH_UTIL_CORE.Default_Handler('WSH_SHIPMENT_REQUEST_PKG.Check_Header_Attr_Changed');
         --
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
         --
END Check_Header_Attr_Changed;
--
--=============================================================================
-- PRIVATE PROCEDURE :
--       Populate_OM_Common_Attr
--
-- PARAMETERS:
--       p_om_header_rec     => Standalone related order header attributes record
--       p_del_interface_rec => Delivery Interface Record
--       x_header_rec        => Order Header Record
--       x_line_tbl          => Collection of Order Lines record
--       x_customer_info     => Customer Related information
--       x_return_status     => Return Status of API (Either S,E,U)
--
-- COMMENT:
--       API to populate attributes common to Order Headers and lines
--=============================================================================
--
PROCEDURE Populate_OM_Common_Attr(
          p_om_header_rec     IN OM_Header_Rec_Type,
          p_del_interface_rec IN Del_Interface_Rec_Type,
          x_header_rec        IN OUT NOCOPY OE_ORDER_PUB.Header_Rec_Type,
          x_line_tbl          IN OUT NOCOPY OE_ORDER_PUB.Line_Tbl_Type,
          x_customer_info     OUT NOCOPY OE_ORDER_PUB.Customer_Info_Table_Type,
          x_return_status     OUT NOCOPY VARCHAR2 )
IS

   l_index                      NUMBER;
   --
   l_debug_on BOOLEAN;
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Populate_OM_Common_Attr';
   --
BEGIN
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name, 'p_om_header_rec.header_id', p_om_header_rec.header_id);
      WSH_DEBUG_SV.log(l_module_name, 'x_line_tbl.count', x_line_tbl.count);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   -- Always pass  SOLD-TO CUSTOMER DETAILS
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'Adding Sold-To-Customer Information');
   END IF;
   --
   l_index := x_customer_info.count + 1;
   x_customer_info(l_index) := OE_ORDER_PUB.G_MISS_CUSTOMER_INFO_REC;
   x_header_rec.sold_to_customer_ref := g_sold_to_ref;

   x_customer_info(l_index).customer_info_ref := g_sold_to_ref;
   x_customer_info(l_index).customer_info_type_code := 'CUSTOMER';
   x_customer_info(l_index).customer_type := 'ORGANIZATION';

   IF p_del_interface_rec.customer_id is not null THEN
      x_customer_info(l_index).customer_id := p_del_interface_rec.customer_id;
   ELSE
      x_customer_info(l_index).organization_name := p_del_interface_rec.customer_name;
   END IF;

   --SHIP-TO CUSTOMER DETAILS
   IF ( p_om_header_rec.header_id is null or
          ( p_om_header_rec.header_id is not null and
            ( p_om_header_rec.ship_to_changed or
              ( p_om_header_rec.ship_to_contact_changed and
                ( p_del_interface_rec.ship_to_contact_id is not null or
                  p_del_interface_rec.ship_to_contact_name is not null ) ) ) )
        )
   THEN -- {
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Adding Ship-To-Customer Information');
      END IF;
      --
      l_index := x_customer_info.count + 1;
      x_customer_info(l_index) := OE_ORDER_PUB.G_MISS_CUSTOMER_INFO_REC;
      x_header_rec.ship_to_customer_ref := g_ship_to_ref;

      x_customer_info(l_index).customer_info_ref := g_ship_to_ref;
      x_customer_info(l_index).customer_info_type_code := 'CUSTOMER';
      x_customer_info(l_index).customer_type := 'ORGANIZATION';

      IF p_del_interface_rec.ship_to_customer_id is not null THEN
         x_customer_info(l_index).customer_id := p_del_interface_rec.ship_to_customer_id;
      ELSE
         x_customer_info(l_index).organization_name := p_del_interface_rec.ship_to_customer_name;
      END IF;
   END IF; -- }

   --INVOICE-TO CUSTOMER DETAILS
   IF ( p_om_header_rec.header_id is null or
          ( p_om_header_rec.header_id is not null and
            ( p_om_header_rec.invoice_to_changed or
              ( p_om_header_rec.invoice_to_contact_changed and
                ( p_del_interface_rec.invoice_to_contact_id is not null or
                  p_del_interface_rec.invoice_to_contact_name is not null ) ) ) )
        )
   THEN -- {
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Adding Invoice-To-Customer Information');
      END IF;
      --
      l_index := x_customer_info.count + 1;
      x_customer_info(l_index) := OE_ORDER_PUB.G_MISS_CUSTOMER_INFO_REC;
      x_header_rec.invoice_to_customer_ref := g_invoice_to_ref;

      x_customer_info(l_index).customer_info_ref := g_invoice_to_ref;
      x_customer_info(l_index).customer_info_type_code := 'CUSTOMER';
      x_customer_info(l_index).customer_type := 'ORGANIZATION';

      IF p_del_interface_rec.invoice_to_customer_id is not null THEN
         x_customer_info(l_index).customer_id := p_del_interface_rec.invoice_to_customer_id;
      ELSE
         x_customer_info(l_index).organization_name := p_del_interface_rec.invoice_to_customer_name;
      END IF;
   END IF; -- }

   --DELIVER-TO CUSTOMER DETAILS
   IF ( ( p_del_interface_rec.deliver_to_customer_id is not null or
          p_del_interface_rec.deliver_to_customer_name is not null ) and
        ( p_om_header_rec.header_id is null or
          ( p_om_header_rec.header_id is not null and
            ( p_om_header_rec.deliver_to_changed or
              ( p_om_header_rec.deliver_to_contact_changed and
                ( p_del_interface_rec.deliver_to_contact_id is not null or
                  p_del_interface_rec.deliver_to_contact_name is not null ) ) ) )
        ) )
   THEN -- {
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Adding Deliver-To-Customer Information');
      END IF;
      --
      l_index := x_customer_info.count + 1;
      x_customer_info(l_index) := OE_ORDER_PUB.G_MISS_CUSTOMER_INFO_REC;
      x_header_rec.deliver_to_customer_ref := g_deliver_to_ref;

      x_customer_info(l_index).customer_info_ref := g_deliver_to_ref;
      x_customer_info(l_index).customer_info_type_code := 'CUSTOMER';
      x_customer_info(l_index).customer_type := 'ORGANIZATION';

      IF p_del_interface_rec.deliver_to_customer_id is not null THEN
         x_customer_info(l_index).customer_id := p_del_interface_rec.deliver_to_customer_id;
      ELSE
         x_customer_info(l_index).organization_name := p_del_interface_rec.deliver_to_customer_name;
      END IF;
   END IF; -- }

   -- SHIP-TO ADDRESS DETAILS
   IF ( ( p_om_header_rec.header_id is null ) or
        ( p_om_header_rec.header_id is not null and
          p_om_header_rec.ship_to_changed ) )
   THEN -- {
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Adding Ship-To-Address Information');
      END IF;
      --
      l_index := x_customer_info.count + 1;
      x_customer_info(l_index) := OE_ORDER_PUB.G_MISS_CUSTOMER_INFO_REC;
      x_header_rec.ship_to_address_ref := g_ship_to_address_ref;

      x_customer_info(l_index).customer_info_type_code  := 'ADDRESS';
      x_customer_info(l_index).customer_info_ref        := g_ship_to_address_ref;
      x_customer_info(l_index).parent_customer_info_ref := g_ship_to_ref;

      IF p_del_interface_rec.ship_to_address_id is not null THEN
         x_customer_info(l_index).site_use_id := p_del_interface_rec.ship_to_address_id;
      ELSE
         x_customer_info(l_index).address1    := p_del_interface_rec.ship_to_address1;
         x_customer_info(l_index).address2    := p_del_interface_rec.ship_to_address2;
         x_customer_info(l_index).address3    := p_del_interface_rec.ship_to_address3;
         x_customer_info(l_index).address4    := p_del_interface_rec.ship_to_address4;
         x_customer_info(l_index).city        := p_del_interface_rec.ship_to_city;
         x_customer_info(l_index).state       := p_del_interface_rec.ship_to_state;
         x_customer_info(l_index).postal_code := p_del_interface_rec.ship_to_postal_code;
         x_customer_info(l_index).country     := p_del_interface_rec.ship_to_country;
      END IF;
   END IF; -- }

   -- INVOICE-TO ADDRESS DETAILS
   IF ( ( p_om_header_rec.header_id is null ) or
        ( p_om_header_rec.header_id is not null and
          p_om_header_rec.invoice_to_changed ) )
   THEN -- {
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Adding Invoice-To-Address Information');
      END IF;
      --
      l_index := x_customer_info.count + 1;
      x_customer_info(l_index) := OE_ORDER_PUB.G_MISS_CUSTOMER_INFO_REC;
      x_header_rec.invoice_to_address_ref := g_invoice_to_address_ref;

      x_customer_info(l_index).customer_info_type_code  := 'ADDRESS';
      x_customer_info(l_index).customer_info_ref        := g_invoice_to_address_ref;
      x_customer_info(l_index).parent_customer_info_ref := g_invoice_to_ref;

      IF p_del_interface_rec.invoice_to_address_id is not null THEN
         x_customer_info(l_index).site_use_id := p_del_interface_rec.invoice_to_address_id;
      ELSE
         x_customer_info(l_index).address1    := p_del_interface_rec.invoice_to_address1;
         x_customer_info(l_index).address2    := p_del_interface_rec.invoice_to_address2;
         x_customer_info(l_index).address3    := p_del_interface_rec.invoice_to_address3;
         x_customer_info(l_index).address4    := p_del_interface_rec.invoice_to_address4;
         x_customer_info(l_index).city        := p_del_interface_rec.invoice_to_city;
         x_customer_info(l_index).state       := p_del_interface_rec.invoice_to_state;
         x_customer_info(l_index).postal_code := p_del_interface_rec.invoice_to_postal_code;
         x_customer_info(l_index).country     := p_del_interface_rec.invoice_to_country;
      END IF;
   END IF; -- }

   -- DELIVER-TO ADDRESS DETAILS
   IF ( ( ( p_om_header_rec.header_id is null ) OR
          ( p_om_header_rec.header_id is not null and
            p_om_header_rec.deliver_to_changed )
        ) AND
        ( p_del_interface_rec.deliver_to_address_id is not null or
          p_del_interface_rec.deliver_to_address1 is not null ) )
   THEN -- {
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Adding Deliver-To-Address Information');
      END IF;
      --
      l_index := x_customer_info.count + 1;
      x_customer_info(l_index) := OE_ORDER_PUB.G_MISS_CUSTOMER_INFO_REC;
      x_header_rec.deliver_to_address_ref := g_deliver_to_address_ref;

      x_customer_info(l_index).customer_info_type_code  := 'ADDRESS';
      x_customer_info(l_index).customer_info_ref        := g_deliver_to_address_ref;
      x_customer_info(l_index).parent_customer_info_ref := g_deliver_to_ref;

      IF p_del_interface_rec.deliver_to_address_id is not null THEN
         x_customer_info(l_index).site_use_id := p_del_interface_rec.deliver_to_address_id;
      ELSE
         x_customer_info(l_index).address1    := p_del_interface_rec.deliver_to_address1;
         x_customer_info(l_index).address2    := p_del_interface_rec.deliver_to_address2;
         x_customer_info(l_index).address3    := p_del_interface_rec.deliver_to_address3;
         x_customer_info(l_index).address4    := p_del_interface_rec.deliver_to_address4;
         x_customer_info(l_index).city        := p_del_interface_rec.deliver_to_city;
         x_customer_info(l_index).state       := p_del_interface_rec.deliver_to_state;
         x_customer_info(l_index).postal_code := p_del_interface_rec.deliver_to_postal_code;
         x_customer_info(l_index).country     := p_del_interface_rec.deliver_to_country;
      END IF;
   ELSIF ( p_om_header_rec.deliver_to_changed and
           p_del_interface_rec.deliver_to_address_id is null and
           p_del_interface_rec.deliver_to_address1 is null )
   THEN
      x_header_rec.deliver_to_org_id := null;
   END IF; -- }

   -- SHIP-TO CONTACT DETAILS
   IF ( ( p_om_header_rec.header_id is null or
          ( p_om_header_rec.header_id is not null and
            p_om_header_rec.ship_to_contact_changed )
        ) and
        ( p_del_interface_rec.ship_to_contact_id is not null or
          p_del_interface_rec.ship_to_contact_name is not null )
      )
   THEN -- {
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Adding Ship-To Contact Information');
      END IF;
      --
      l_index := x_customer_info.count + 1;
      x_customer_info(l_index) := OE_ORDER_PUB.G_MISS_CUSTOMER_INFO_REC;
      x_header_rec.ship_to_contact_ref := g_ship_to_contact_ref;

      x_customer_info(l_index).customer_info_type_code  := 'CONTACT';
      x_customer_info(l_index).customer_info_ref        := g_ship_to_contact_ref;
      x_customer_info(l_index).parent_customer_info_ref := g_ship_to_ref;

      IF p_del_interface_rec.ship_to_contact_id is not null THEN
         x_customer_info(l_index).contact_id := p_del_interface_rec.ship_to_contact_id;
      ELSE
         x_customer_info(l_index).person_last_name := p_del_interface_rec.ship_to_contact_name;
      END IF;

      IF p_del_interface_rec.ship_to_contact_phone is not null THEN
         x_customer_info(l_index).phone_number := p_del_interface_rec.ship_to_contact_phone;
      END IF;
   ELSIF ( p_om_header_rec.ship_to_contact_changed and
           p_del_interface_rec.ship_to_contact_id is null and
           p_del_interface_rec.ship_to_contact_name is null )
   THEN
      x_header_rec.ship_to_contact_id := null;
   END IF; -- }

   -- INVOICE-TO CONTACT DETAILS
   IF ( ( p_om_header_rec.header_id is null or
          ( p_om_header_rec.header_id is not null and
            p_om_header_rec.invoice_to_contact_changed )
        ) and
        ( p_del_interface_rec.invoice_to_contact_id is not null or
          p_del_interface_rec.invoice_to_contact_name is not null )
      )
   THEN -- {
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Adding Invoice-To Contact Information');
      END IF;
      --
      l_index := x_customer_info.count + 1;
      x_customer_info(l_index) := OE_ORDER_PUB.G_MISS_CUSTOMER_INFO_REC;
      x_header_rec.invoice_to_contact_ref := g_invoice_to_contact_ref;

      x_customer_info(l_index).customer_info_type_code  := 'CONTACT';
      x_customer_info(l_index).customer_info_ref        := g_invoice_to_contact_ref;
      x_customer_info(l_index).parent_customer_info_ref := g_invoice_to_ref;

      IF p_del_interface_rec.invoice_to_contact_id is not null THEN
         x_customer_info(l_index).contact_id := p_del_interface_rec.invoice_to_contact_id;
      ELSE
         x_customer_info(l_index).person_last_name := p_del_interface_rec.invoice_to_contact_name;
      END IF;

      IF p_del_interface_rec.invoice_to_contact_phone is not null THEN
         x_customer_info(l_index).phone_number := p_del_interface_rec.invoice_to_contact_phone;
      END IF;
   ELSIF ( p_om_header_rec.invoice_to_contact_changed and
           p_del_interface_rec.invoice_to_contact_id is null and
           p_del_interface_rec.invoice_to_contact_name is null )
   THEN
      x_header_rec.invoice_to_contact_id := null;
   END IF; -- }

   -- DELIVER-TO CONTACT DETAILS
   IF ( ( p_om_header_rec.header_id is null or
          ( p_om_header_rec.header_id is not null and
            p_om_header_rec.deliver_to_contact_changed )
        ) and
        ( p_del_interface_rec.deliver_to_contact_id is not null or
          p_del_interface_rec.deliver_to_contact_name is not null )
      )
   THEN -- {
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Adding Deliver-To Contact Information');
      END IF;
      --
      l_index := x_customer_info.count + 1;
      x_customer_info(l_index) := OE_ORDER_PUB.G_MISS_CUSTOMER_INFO_REC;
      x_header_rec.deliver_to_contact_ref := g_deliver_to_contact_ref;

      x_customer_info(l_index).customer_info_type_code  := 'CONTACT';
      x_customer_info(l_index).customer_info_ref        := g_deliver_to_contact_ref;
      x_customer_info(l_index).parent_customer_info_ref := g_deliver_to_ref;

      IF p_del_interface_rec.deliver_to_contact_id is not null THEN
         x_customer_info(l_index).contact_id := p_del_interface_rec.deliver_to_contact_id;
      ELSE
         x_customer_info(l_index).person_last_name := p_del_interface_rec.deliver_to_contact_name;
      END IF;

      IF p_del_interface_rec.deliver_to_contact_phone is not null THEN
         x_customer_info(l_index).phone_number := p_del_interface_rec.deliver_to_contact_phone;
      END IF;
   ELSIF ( p_om_header_rec.deliver_to_contact_changed and
           p_del_interface_rec.deliver_to_contact_id is null and
           p_del_interface_rec.deliver_to_contact_name is null )
   THEN
      x_header_rec.deliver_to_contact_id := null;
   END IF; -- }

   x_header_rec.ship_from_org_id     := p_del_interface_rec.organization_id;

   IF p_om_header_rec.header_id is null or
      p_om_header_rec.shipping_method_changed
   THEN
      x_header_rec.shipping_method_code := p_del_interface_rec.ship_method_code;
   END IF;

   IF p_om_header_rec.header_id is null or
      p_om_header_rec.freight_terms_changed
   THEN
      x_header_rec.freight_terms_code     := p_del_interface_rec.freight_terms_code;
   END IF;

   IF p_om_header_rec.header_id is null or
      p_om_header_rec.fob_point_changed
   THEN
      x_header_rec.fob_point_code     := p_del_interface_rec.fob_code;
   END IF;

   IF p_om_header_rec.header_attributes_changed and
      x_line_tbl.count > 0
   THEN -- {
      FOR i in x_line_tbl.first..x_line_tbl.last
      LOOP
         IF x_line_tbl(i).operation = OE_GLOBALS.G_OPR_UPDATE THEN
            IF nvl(x_header_rec.sold_to_customer_ref, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
               x_line_tbl(i).sold_to_customer_ref := x_header_rec.sold_to_customer_ref;
            END IF;

            IF nvl(x_header_rec.ship_to_customer_ref, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
               x_line_tbl(i).ship_to_customer_ref := x_header_rec.ship_to_customer_ref;
            END IF;

            IF nvl(x_header_rec.invoice_to_customer_ref, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
               x_line_tbl(i).invoice_to_customer_ref := x_header_rec.invoice_to_customer_ref;
            END IF;

            IF nvl(x_header_rec.deliver_to_customer_ref, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
               x_line_tbl(i).deliver_to_customer_ref := x_header_rec.deliver_to_customer_ref;
            END IF;

            IF nvl(x_header_rec.ship_to_address_ref, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
               x_line_tbl(i).ship_to_address_ref := x_header_rec.ship_to_address_ref;
            END IF;

            IF nvl(x_header_rec.invoice_to_address_ref, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
               x_line_tbl(i).invoice_to_address_ref := x_header_rec.invoice_to_address_ref;
            END IF;

            IF nvl(x_header_rec.deliver_to_address_ref, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
               x_line_tbl(i).deliver_to_address_ref := x_header_rec.deliver_to_address_ref;
            END IF;

            IF nvl(x_header_rec.ship_to_contact_ref, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
               x_line_tbl(i).ship_to_contact_ref := x_header_rec.ship_to_contact_ref;
            END IF;

            IF nvl(x_header_rec.invoice_to_contact_ref, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
               x_line_tbl(i).invoice_to_contact_ref := x_header_rec.invoice_to_contact_ref;
            END IF;

            IF nvl(x_header_rec.deliver_to_contact_ref, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
               x_line_tbl(i).deliver_to_contact_ref := x_header_rec.deliver_to_contact_ref;
            END IF;

            IF p_om_header_rec.deliver_to_changed and
               x_header_rec.deliver_to_org_id is null
            THEN
               x_line_tbl(i).deliver_to_org_id := null;
            END IF;

            IF p_om_header_rec.ship_to_contact_changed and
               x_header_rec.ship_to_contact_id is null
            THEN
               x_line_tbl(i).ship_to_contact_id := null;
            END IF;

            IF p_om_header_rec.invoice_to_contact_changed and
               x_header_rec.invoice_to_contact_id is null
            THEN
               x_line_tbl(i).invoice_to_contact_id := null;
            END IF;

            IF p_om_header_rec.deliver_to_contact_changed and
               x_header_rec.deliver_to_contact_id is null
            THEN
               x_line_tbl(i).deliver_to_contact_id := null;
            END IF;

            IF p_om_header_rec.shipping_method_changed THEN
               x_line_tbl(i).shipping_method_code := x_header_rec.shipping_method_code;
            END IF;

            IF p_om_header_rec.freight_terms_changed THEN
               x_line_tbl(i).freight_terms_code := x_header_rec.freight_terms_code;
            END IF;

            IF p_om_header_rec.fob_point_changed THEN
               x_line_tbl(i).fob_point_code := x_header_rec.fob_point_code;
            END IF;
         END IF;
      END LOOP;
   END IF; -- }

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'x_customer_info count', x_customer_info.count);
      WSH_DEBUG_SV.log(l_module_name, 'Return Status', x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
EXCEPTION
   WHEN OTHERS THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         WSH_UTIL_CORE.Default_Handler('WSH_SHIPMENT_REQUEST_PKG.Populate_OM_Common_Attr');
         --
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
         --
END Populate_OM_Common_Attr;
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Populate_Header_Rec
--
-- PARAMETERS:
--       p_action_type       => Either D(Cancel),A(Add),C(Change or Update)
--       p_om_header_rec     => Standalone related order header attributes record
--       p_del_interface_rec => Delivery Interface Record
--       x_header_rec        => Order Header Record
--       x_return_status     => Return Status of API (Either S,E,U)
--
-- COMMENT:
--       API to populate Order Header attributes.
--       If order header already exists only the operation related attributes
--       are populated.
--=============================================================================
--
PROCEDURE Populate_Header_Rec(
          p_action_type           IN VARCHAR2,
          p_om_header_rec         IN OM_Header_Rec_Type,
          p_del_interface_rec     IN Del_Interface_Rec_Type,
          x_header_rec            OUT NOCOPY OE_ORDER_PUB.Header_Rec_Type,
          x_return_status         OUT NOCOPY VARCHAR2 )  IS


   CURSOR c_get_source_id( p_client_code IN VARCHAR2) IS
   SELECT order_source_id
   FROM   OE_ORDER_SOURCES
   WHERE  name = p_client_code;
   --
   l_header_id                  NUMBER;
   l_debug_on BOOLEAN;
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Populate_Header_Rec';
   --
BEGIN
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name, 'p_action_type', p_action_type);
      WSH_DEBUG_SV.log(l_module_name, 'p_om_header_rec.header_id', p_om_header_rec.header_id);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   l_header_id := p_om_header_rec.header_id;

   x_header_rec                        := OE_ORDER_PUB.G_MISS_HEADER_REC;
   x_header_rec.version_number         := p_del_interface_rec.document_revision;
   -- LSP PROJECT : Populate orig sys document ref as 'SHIPMENT_REQUEST:CLIENT CODE:ORDER NUMBER
   IF p_del_interface_rec.client_code IS NOT NULL THEN
       x_header_rec.orig_sys_document_ref  := 'SHIPMENT_REQUEST:'||p_del_interface_rec.client_code||':'||p_del_interface_rec.order_number;
   ELSE
       x_header_rec.orig_sys_document_ref  := 'SHIPMENT_REQUEST:' || p_del_interface_rec.order_number;
   END IF;

   IF p_action_type = 'D' -- { Action Type 'CANCEL'
   THEN
      x_header_rec.operation              := OE_GLOBALS.G_OPR_UPDATE;
      x_header_rec.header_id              := l_header_id;
      x_header_rec.change_reason          := 'Not provided';
      x_header_rec.cancelled_flag         := 'Y';
   ELSE
      --Populating header record

      IF l_header_id is NOT NULL THEN -- { Header Id not null
         x_header_rec.operation               := OE_GLOBALS.G_OPR_UPDATE;
         x_header_rec.header_id               := l_header_id;
         x_header_rec.order_type_id           := p_om_header_rec.order_type_id;
      ELSE -- Going to create new Sales Order
         x_header_rec.operation                  := OE_GLOBALS.G_OPR_CREATE;
         x_header_rec.order_number               := p_del_interface_rec.order_number;

         x_header_rec.order_type_id              := p_om_header_rec.order_type_id;
         x_header_rec.price_list_id              := p_om_header_rec.price_list_id;
         x_header_rec.payment_term_id            := p_om_header_rec.payment_term_id;
         x_header_rec.org_id                     := p_om_header_rec.org_id;
         x_header_rec.transactional_curr_code    := p_om_header_rec.currency_code;

         x_header_rec.sold_from_org_id           := p_om_header_rec.org_id;
         --
         -- LSP PROJECT: Populate order_source_id from oe_order_sources
         IF ( p_del_interface_rec.client_code IS NOT NULL ) THEN
         --{
             OPEN c_get_source_id(p_del_interface_rec.client_code);
             FETCH c_get_source_id INTO x_header_rec.order_source_id;
             CLOSE c_get_source_id;
             IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name, 'x_header_rec.order_source_id', x_header_rec.order_source_id);
             END IF;
             IF (x_header_rec.order_source_id IS NULL OR x_header_rec.order_source_id = FND_API.G_MISS_NUM ) THEN
             --{
                 FND_MESSAGE.Set_Name('WSH', 'WSH_OI_INVALID_ATTRIBUTE');
                 FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ORDER_SOURCE');
                 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                 WSH_UTIL_CORE.Add_Message(x_return_status, l_module_name );
                 IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name, 'Return Status',x_return_status);
                     WSH_DEBUG_SV.pop(l_module_name);
                 END IF;
             --}
             END IF;
         --}
         ELSE
         --{
             x_header_rec.order_source_id            := 0; /* Online */
         --}
         END IF;
         -- LSP PROJECT: end
         --
         x_header_rec.salesrep_id                := -3; -- Salesrep => No Sales Credit

         --Common parameters for Process Order API Header record
         x_header_rec.open_flag                  := 'Y';
         -- 2/16/2009 Check with klr commented after discussing with OM for bug 8253903 logged
         --x_header_rec.booked_flag                := 'Y';
         x_header_rec.ordered_date               := sysdate;
         x_header_rec.order_category_code        := 'ORDER';

      END IF; -- } Header Id not null
   END IF; -- }

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'Return Status',x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
EXCEPTION
   WHEN OTHERS THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         WSH_UTIL_CORE.Default_Handler('WSH_SHIPMENT_REQUEST_PKG.Populate_Header_Rec');
         --
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
         --
END Populate_Header_Rec;
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Derive_Header_Rec
--
-- PARAMETERS:
--       p_om_header_rec     => Standalone related order header attributes record
--       x_del_interface_rec => Delivery Interface Record
--       x_return_status     => Return Status of API (Either S,E,U)
--
-- COMMENT:
--       API to derive/validate standalone related order header attributes
--       populated in Wsh_New_Del_Interface table.
--=============================================================================
--
PROCEDURE Derive_Header_Rec(
          p_om_header_rec         IN OUT NOCOPY OM_Header_Rec_Type,
          x_del_interface_rec     IN OUT NOCOPY Del_Interface_Rec_Type,
          x_return_status         OUT NOCOPY VARCHAR2 )
IS

   l_return_status              VARCHAR2(1);
   l_temp_status                VARCHAR2(1);
   l_tmp                        VARCHAR2(1);
   l_carrier_code               WSH_CARRIERS.Freight_Code%TYPE;
   l_missing_attr               VARCHAR2(1000);
   l_carrier_id                 NUMBER;
   l_header_id                  NUMBER;
   l_call_attr_changed          BOOLEAN;

   --
   l_debug_on BOOLEAN;
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Derive_Header_Rec';
   --
BEGIN
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.logmsg(l_module_name, 'SoldTo Partner Name => ' || x_del_interface_rec.customer_name
                              || ', ' || 'ShipTo Partner Name => ' || x_del_interface_rec.ship_to_customer_name
                              || ', ' || 'InvoiceTo Partner Name => ' || x_del_interface_rec.ship_to_customer_name
                              || ', ' || 'ShipTo Partner Address1 => ' || x_del_interface_rec.ship_to_address1
                              || ', ' || 'InvoiceTo Partner Address1 => ' || x_del_interface_rec.invoice_to_address1 );
      WSH_DEBUG_SV.logmsg(l_module_name, 'Ids: SoldTo Partner => ' || x_del_interface_rec.customer_id
                              || ', ' || 'ShipTo Partner => ' || x_del_interface_rec.ship_to_customer_id
                              || ', ' || 'InvoiceTo Partner => ' || x_del_interface_rec.ship_to_customer_id
                              || ', ' || 'ShipTo Partner Address => ' || x_del_interface_rec.ship_to_address_id
                              || ', ' || 'InvoiceTo Partner Address => ' || x_del_interface_rec.invoice_to_address_id );
   END IF;
   --

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   l_temp_status   := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   l_missing_attr  := null;
   l_header_id     := p_om_header_rec.header_id;
   l_call_attr_changed := TRUE;

   IF x_del_interface_rec.ship_to_customer_id is null and
      x_del_interface_rec.ship_to_customer_name is null
   THEN
      IF l_missing_attr is null THEN
         l_missing_attr := 'SHIPTO_PARTNER';
      ELSE
         l_missing_attr := l_missing_attr || ', ' || 'SHIPTO_PARTNER';
      END IF;
      l_temp_status   := WSH_UTIL_CORE.G_RET_STS_ERROR;
   END IF;

   IF x_del_interface_rec.ship_to_address_id is null and
      x_del_interface_rec.ship_to_address1 is null
   THEN
      IF l_missing_attr is null THEN
         l_missing_attr := 'SHIPTO_PARTNER_ADDRESS';
      ELSE
         l_missing_attr := l_missing_attr || ', ' || 'SHIPTO_PARTNER_ADDRESS';
      END IF;
      l_temp_status   := WSH_UTIL_CORE.G_RET_STS_ERROR;
   END IF;

   IF x_del_interface_rec.customer_id is null and
      x_del_interface_rec.customer_name is null
   THEN
      x_del_interface_rec.customer_id   := x_del_interface_rec.ship_to_customer_id;
      x_del_interface_rec.customer_name := x_del_interface_rec.ship_to_customer_name;
   END IF;

   IF x_del_interface_rec.invoice_to_customer_id is null and
      x_del_interface_rec.invoice_to_customer_name is null
   THEN
      x_del_interface_rec.invoice_to_customer_id   := x_del_interface_rec.ship_to_customer_id;
      x_del_interface_rec.invoice_to_customer_name := x_del_interface_rec.ship_to_customer_name;
   END IF;

   IF x_del_interface_rec.invoice_to_address_id is null and
      x_del_interface_rec.invoice_to_address1 is null
   THEN
      x_del_interface_rec.invoice_to_address_id  := x_del_interface_rec.ship_to_address_id;
      x_del_interface_rec.invoice_to_address1    := x_del_interface_rec.ship_to_address1;
      x_del_interface_rec.invoice_to_address2    := x_del_interface_rec.ship_to_address2;
      x_del_interface_rec.invoice_to_address3    := x_del_interface_rec.ship_to_address3;
      x_del_interface_rec.invoice_to_address4    := x_del_interface_rec.ship_to_address4;
      x_del_interface_rec.invoice_to_city        := x_del_interface_rec.ship_to_city;
      x_del_interface_rec.invoice_to_state       := x_del_interface_rec.ship_to_state;
      x_del_interface_rec.invoice_to_country     := x_del_interface_rec.ship_to_country;
      x_del_interface_rec.invoice_to_postal_code := x_del_interface_rec.ship_to_postal_code;
   END IF;

   IF l_temp_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'Error: Missing Attributes', l_missing_attr);
      END IF;
      --
      FND_MESSAGE.Set_Name('WSH', 'WSH_STND_ATTR_MANDATORY');
      FND_MESSAGE.Set_Token('ATTRIBUTE', l_missing_attr);
      WSH_UTIL_CORE.Add_Message(l_temp_status, l_module_name);
      l_call_attr_changed := FALSE;
   END IF;

   -- DeliverTo Address cannot be populated if DeliverTo Partner is NULL
   IF x_del_interface_rec.deliver_to_customer_id is null and
      x_del_interface_rec.deliver_to_customer_name is null
   THEN
      IF x_del_interface_rec.deliver_to_address_id is not null or
         x_del_interface_rec.deliver_to_address1 is not null
      THEN
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Error: DeliverTo Partner Address is populated without DeliverTo Partner detail');
         END IF;
         --
         l_temp_status   := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FND_MESSAGE.Set_Name('WSH', 'WSH_STND_INVALID_DELIVER_INFO');
         FND_MESSAGE.Set_Token('ATTRIBUTE', 'DELIVERTO_PARTNER_ADDRESS');
         WSH_UTIL_CORE.Add_Message(l_temp_status, l_module_name);
         l_call_attr_changed := FALSE;
      END IF;
   END IF;

   -- DeliverTo Contact cannot be populated if DeliverTo Partner or Address is NULL
   IF ( x_del_interface_rec.deliver_to_customer_id is null and
        x_del_interface_rec.deliver_to_customer_name is null ) OR
      ( x_del_interface_rec.deliver_to_address_id is null and
        x_del_interface_rec.deliver_to_address1 is null )
   THEN
      IF x_del_interface_rec.deliver_to_contact_id is not null or
         x_del_interface_rec.deliver_to_contact_name is not null
      THEN
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Error: DeliverTo Partner Contact is populated without DeliverTo Partner detail');
         END IF;
         --
         l_temp_status   := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FND_MESSAGE.Set_Name('WSH', 'WSH_STND_INVALID_DELIVER_INFO');
         FND_MESSAGE.Set_Token('ATTRIBUTE', 'DELIVERTO_PARTNER_CONTACT');
         WSH_UTIL_CORE.Add_Message(l_temp_status, l_module_name);
         l_call_attr_changed := FALSE;
      END IF;
   END IF;

   -- Validate Carrier Id or Carrier Code
   IF l_debug_on THEN
      wsh_debug_sv.logmsg(l_module_name, 'Carrier Id: '||x_del_interface_rec.carrier_id||' Carrier Code: '||x_del_interface_rec.carrier_code);
   END IF;

   BEGIN
      IF x_del_interface_rec.carrier_id is not null
      THEN
         select freight_code
         into   l_carrier_code
         from   wsh_carriers
         where  carrier_id = x_del_interface_rec.carrier_id;
      ELSIF x_del_interface_rec.carrier_code is not null THEN
         select carrier_id
         into   x_del_interface_rec.carrier_id
         from   wsh_carriers
         where  freight_code = x_del_interface_rec.carrier_code;

         l_carrier_id   := x_del_interface_rec.carrier_id;
         l_carrier_code := x_del_interface_rec.carrier_code;
      END IF;

      IF ( x_del_interface_rec.carrier_id is not null and
           x_del_interface_rec.service_level is not null and
           x_del_interface_rec.mode_of_transport is not null )
      THEN
         --
         IF l_debug_on THEN
            wsh_debug_sv.logmsg(l_module_name, 'Calling api Validate_Ship_Method', WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --
         Validate_Ship_Method(
                  p_carrier_code      => l_carrier_code,
                  p_organization_id   => x_del_interface_rec.organization_id,
                  p_service_level     => x_del_interface_rec.service_level,
                  p_mode_of_transport => x_del_interface_rec.mode_of_transport,
                  x_ship_method_code  => x_del_interface_rec.ship_method_code,
                  x_return_status     => l_return_status );

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Error occured in Validate_Ship_Method', WSH_DEBUG_SV.C_ERR_LEVEL);
            END IF;
            --
            l_temp_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         END IF;
      ELSIF ( ( x_del_interface_rec.carrier_id is not null or
                x_del_interface_rec.service_level is not null or
                x_del_interface_rec.mode_of_transport is not null ) and
              ( x_del_interface_rec.carrier_id is null or
                x_del_interface_rec.service_level is null or
                x_del_interface_rec.mode_of_transport is null ) )
      THEN
         --
         IF l_debug_on THEN
            wsh_debug_sv.logmsg(l_module_name, 'Error: Ship Method information is incomplete');
         END IF;
         --
         l_temp_status   := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FND_MESSAGE.Set_Name('WSH', 'WSH_STND_INCOMPLETE_SM');
         WSH_UTIL_CORE.Add_Message(l_temp_status, l_module_name);
      END IF;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         FND_MESSAGE.Set_Name('WSH', 'WSH_CARRIER_NOT_FOUND');
         l_temp_status   := WSH_UTIL_CORE.G_RET_STS_ERROR;
         WSH_UTIL_CORE.Add_Message(l_temp_status, l_module_name);
         --
         IF l_debug_on THEN
            wsh_debug_sv.logmsg(l_module_name, 'Error: Carrier not found');
         END IF;
         --
   END;

   -- If Order Header already exists, then validate if Ship-From, Sold-To,
   -- Ship-To, Invoice-To, Deliver-To and Ship-Method remains the same,
   -- if not then validate it.
   IF l_header_id is not null and l_call_attr_changed THEN
      --
      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'Calling api Check_Header_Attr_Changed', WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      Check_Header_Attr_Changed(
            p_del_interface_rec => x_del_interface_rec,
            p_om_header_rec     => p_om_header_rec,
            x_return_status     => l_return_status );

      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Error occured in Check_Header_Attr_Changed', WSH_DEBUG_SV.C_ERR_LEVEL);
         END IF;
         --
         l_temp_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      ELSIF ( p_om_header_rec.header_attributes_changed )
      THEN
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Header Attributes Changed, Check if there exists any Shipped delivery lines');
         END IF;
         --

         BEGIN
            select 'x'
            into   l_tmp
            from   wsh_delivery_details     wdd,
                   wsh_delivery_assignments wda,
                   wsh_new_deliveries       wnd
            where  wnd.status_code in ( 'CO', 'IT', 'CL' )
            and    wnd.delivery_id = wda.delivery_id
            and    wda.delivery_detail_id = wdd.delivery_detail_id
            and    wdd.source_code = 'OE'
            and    released_status in ( 'Y', 'C' )
            and    wdd.source_header_id = l_header_id;

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               l_tmp := null;
         END;

         IF l_tmp is not null THEN
            l_missing_attr := null;
            l_temp_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

            IF p_om_header_rec.ship_to_changed THEN
               l_missing_attr := 'SHIPTO_PARTNER';
            END IF;

            IF p_om_header_rec.ship_to_contact_changed THEN
               IF l_missing_attr is null THEN
                  l_missing_attr := 'SHIPTO_PARTNER_CONTACT';
               ELSE
                  l_missing_attr := l_missing_attr || ', ' || 'SHIPTO_PARTNER_CONTACT';
               END IF;
            END IF;

            IF p_om_header_rec.invoice_to_changed THEN
               IF l_missing_attr is null THEN
                  l_missing_attr := 'INVOICETO_PARTNER';
               ELSE
                  l_missing_attr := l_missing_attr || ', ' || 'INVOICETO_PARTNER';
               END IF;
            END IF;

            IF p_om_header_rec.invoice_to_contact_changed THEN
               IF l_missing_attr is null THEN
                  l_missing_attr := 'INVOICETO_PARTNER_CONTACT';
               ELSE
                  l_missing_attr := l_missing_attr || ', ' || 'INVOICETO_PARTNER_CONTACT';
               END IF;
            END IF;

            IF p_om_header_rec.deliver_to_changed THEN
               IF l_missing_attr is null THEN
                  l_missing_attr := 'DELIVERTO_PARTNER';
               ELSE
                  l_missing_attr := l_missing_attr || ', ' || 'DELIVERTO_PARTNER';
               END IF;
            END IF;

            IF p_om_header_rec.deliver_to_contact_changed THEN
               IF l_missing_attr is null THEN
                  l_missing_attr := 'DELIVERTO_PARTNER_CONTACT';
               ELSE
                  l_missing_attr := l_missing_attr || ', ' || 'DELIVERTO_PARTNER_CONTACT';
               END IF;
            END IF;

            IF p_om_header_rec.freight_terms_changed THEN
               IF l_missing_attr is null THEN
                  l_missing_attr := 'FREIGHT_TERMS';
               ELSE
                  l_missing_attr := l_missing_attr || ', ' || 'FREIGHT_TERMS';
               END IF;
            END IF;

            IF p_om_header_rec.fob_point_changed THEN
               IF l_missing_attr is null THEN
                  l_missing_attr := 'FOB_CODE';
               ELSE
                  l_missing_attr := l_missing_attr || ', ' || 'FOB_CODE';
               END IF;
            END IF;

            IF p_om_header_rec.shipping_method_changed THEN
               IF l_missing_attr is null THEN
                  l_missing_attr := 'SHIP_METHOD';
               ELSE
                  l_missing_attr := l_missing_attr || ', ' || 'SHIP_METHOD';
               END IF;
            END IF;

            FND_MESSAGE.Set_Name('WSH', 'WSH_STND_REJECT_HEADER_CHANGE');
            FND_MESSAGE.Set_Token('HEADER_ATTR', l_missing_attr);
            WSH_UTIL_CORE.Add_Message(l_temp_status, l_module_name);
            --
            IF l_debug_on THEN
               wsh_debug_sv.logmsg(l_module_name, 'Error: Header attributes cannot be changed');
            END IF;
            --
         END IF;
      END IF;
   END IF;

   IF l_temp_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   END IF;

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'Return Status',x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
EXCEPTION
   WHEN OTHERS THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         WSH_UTIL_CORE.Default_Handler('WSH_SHIPMENT_REQUEST_PKG.Derive_Header_Rec');
         --
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
         --
END Derive_Header_Rec;
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Derive_Line_Rec
--
-- PARAMETERS:
--       p_header_id                 => Header Id
--       p_del_interface_rec         => Delivery Interface Record
--       x_om_line_tbl_type          => Table of standalone related order line attributes
--       x_details_interface_rec_tab => Table of Delivery Detail Interface Record
--       x_interface_error_tab       => Table of Interface error records
--       x_return_status             => Return Status of API (Either S,E,U)
--
-- COMMENT:
--       API to derive/validate standalone related order line attributes
--       populated in Wsh_Del_Details_Interface table.
--=============================================================================
--
PROCEDURE Derive_Line_Rec(
          p_header_id                 IN NUMBER,
          p_del_interface_rec         IN OUT NOCOPY Del_Interface_Rec_Type,
          x_om_line_tbl_type          OUT NOCOPY OM_Line_Tbl_Type,
          x_details_interface_rec_tab OUT NOCOPY Del_Details_Interface_Rec_Tab,
          x_interface_error_tab       OUT NOCOPY WSH_INTERFACE_VALIDATIONS_PKG.interface_errors_rec_tab,
          x_return_status             OUT NOCOPY VARCHAR2 )
IS
   CURSOR c_del_details_interface_rec
   IS
   SELECT wddi.delivery_detail_interface_id,
          wddi.lot_number,
          wddi.subinventory,
          wddi.revision,
          wddi.locator_id,
          wddi.locator_code,
          wddi.line_number,
          wddi.customer_item_number,
          wddi.customer_item_id,
          wddi.item_number,
          wddi.inventory_item_id,
          p_del_interface_rec.organization_id,
          wddi.item_description,
          wddi.requested_quantity,
          wddi.requested_quantity_uom,
          wddi.src_requested_quantity,
          wddi.src_requested_quantity_uom,
          wddi.currency_code,
          nvl(wddi.unit_selling_price, 0),
          wddi.ship_tolerance_above,
          wddi.ship_tolerance_below,
          wddi.date_requested,
          wddi.date_scheduled,
          wddi.earliest_pickup_date,
          wddi.latest_pickup_date,
          wddi.earliest_dropoff_date,
          wddi.latest_dropoff_date,
          wddi.ship_set_name,
          wddi.packing_instructions,
          wddi.shipping_instructions,
          wddi.shipment_priority_code,
          wddi.source_header_number,
          wddi.source_line_number,
          wddi.cust_po_number,
          null, -- Line Id
          'N',  -- Schedule Date Changed
          'N'   -- Changed Flag
   FROM   Wsh_Del_Details_Interface wddi,
          Wsh_Del_Assgn_Interface wdai,
          Wsh_New_Del_Interface wndi
   WHERE  wddi.interface_action_code = g_interface_action_code
   AND    wdai.interface_action_code = g_interface_action_code
   AND    wddi.delivery_detail_interface_id = wdai.delivery_detail_interface_id
   AND    wdai.delivery_interface_id = wndi.delivery_interface_id
   AND    wndi.delivery_interface_id = p_del_interface_rec.delivery_interface_id
   ORDER  BY wddi.line_number;

   l_temp_status                VARCHAR2(1);
   l_return_status              VARCHAR2(1);

   l_item_number                WSH_DEL_DETAILS_INTERFACE.Item_Number%TYPE;

   l_line_cnt                   NUMBER;
   l_customer_id                NUMBER;
   l_ship_to_org_id             NUMBER;
   l_address_id                 NUMBER;
   l_inventory_item_id          NUMBER;
   l_customer_item_id           NUMBER;

   --
   l_debug_on BOOLEAN;
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Derive_Line_Rec';
   --
BEGIN
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name, 'p_del_interface_rec.delivery_interface_id', p_del_interface_rec.delivery_interface_id);
      WSH_DEBUG_SV.log(l_module_name, 'p_header_id', p_header_id);
   END IF;
   --

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   open  c_del_details_interface_rec;
   fetch c_del_details_interface_rec BULK COLLECT INTO x_details_interface_rec_tab;
   close c_del_details_interface_rec;

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'x_details_interface_rec_tab.count', x_details_interface_rec_tab.count);
   END IF;
   --

   IF x_details_interface_rec_tab.count > 0 THEN
      l_line_cnt := 0;
      FOR i in x_details_interface_rec_tab.first..x_details_interface_rec_tab.last
      LOOP
         l_line_cnt := l_line_cnt + 1;
         l_temp_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Processing Line Number', x_details_interface_rec_tab(i).line_number);
         END IF;
         --

         IF (x_details_interface_rec_tab(i).line_number <= 0) OR
              (trunc(x_details_interface_rec_tab(i).line_number) <> x_details_interface_rec_tab(i).line_number) THEN
            FND_MESSAGE.Set_Name('WSH', 'WSH_STND_POSITIVE_INTEGER');
            FND_MESSAGE.Set_Token('ATTRIBUTE', 'LINE_NUMBER');
            l_temp_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            WSH_UTIL_CORE.Add_Message(l_temp_status, l_module_name );
            --
            IF l_debug_on THEN
               wsh_debug_sv.logmsg(l_module_name, 'Error: Line number should be positive integer');
            END IF;
            --
            goto loop_end;
         END IF;

         IF p_header_id is not null -- {
         THEN
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Calling Check_Line_Exists', WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            Check_Line_Exists (
                  p_header_id        => p_header_id,
                  p_line_number      => x_details_interface_rec_tab(i).line_number,
                  x_om_line_rec_type => x_om_line_tbl_type(i),
                  x_return_status    => l_return_status );

            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name, 'Return Status from Check_Line_Exists', l_return_status);
            END IF;
            --

            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
               --
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name, 'Error occured in Check_Line_Exists', WSH_DEBUG_SV.C_ERR_LEVEL);
               END IF;
               --
               l_temp_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
               goto loop_end;
            END IF;

            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Line Id => ' || x_om_line_tbl_type(i).line_id);
            END IF;
            --
            x_details_interface_rec_tab(i).line_id := x_om_line_tbl_type(i).line_id;

            IF (x_om_line_tbl_type(i).open_flag = 'N') THEN
               --
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name, 'Error: Line is already Closed');
               END IF;
               --
               FND_MESSAGE.Set_Name('WSH', 'WSH_STND_LINE_CLOSED');
               FND_MESSAGE.Set_Token('LINE_NUMBER', x_details_interface_rec_tab(i).line_number);
               l_temp_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
               WSH_UTIL_CORE.Add_Message(l_temp_status, l_module_name );
               goto loop_end;
            END IF;
         END IF; --}

         IF  ( x_details_interface_rec_tab(i).requested_quantity IS NULL )
         THEN
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Error: Requested Quantity is NULL');
            END IF;
            --
            FND_MESSAGE.Set_Name('WSH', 'WSH_STND_ATTR_MANDATORY');
            FND_MESSAGE.Set_Token('ATTRIBUTE', 'ORDERED_QUANTITY');
            l_temp_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            WSH_UTIL_CORE.Add_Message(l_temp_status, l_module_name );
         -- Bug 8452056: Check only if ordered quantity is negative.
         ELSIF ( x_details_interface_rec_tab(i).requested_quantity < 0 )
         THEN
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Error: Requested Quantity cannot be Negative');
            END IF;
            --
            FND_MESSAGE.Set_Name('WSH', 'WSH_UI_NEGATIVE_QTY');
            l_temp_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            WSH_UTIL_CORE.Add_Message(l_temp_status, l_module_name );
         END IF;

         IF  ( x_details_interface_rec_tab(i).requested_quantity_uom IS NULL )
         THEN
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Error: Requested Quantity UOM is NULL');
            END IF;
            --
            FND_MESSAGE.Set_Name('WSH', 'WSH_STND_ATTR_MANDATORY');
            FND_MESSAGE.Set_Token('ATTRIBUTE', 'ORDERED_QUANTITY_UOM');
            l_temp_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            WSH_UTIL_CORE.Add_Message(l_temp_status, l_module_name );
         END IF;

         IF  (x_details_interface_rec_tab(i).ship_tolerance_above IS NOT NULL) AND
               ((x_details_interface_rec_tab(i).ship_tolerance_above < 0) OR
                (trunc(x_details_interface_rec_tab(i).ship_tolerance_above) <> x_details_interface_rec_tab(i).ship_tolerance_above))
         THEN
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Error: Ship Tolerance Above('||x_details_interface_rec_tab(i).ship_tolerance_above||') Validation Failed');
            END IF;
            --
            FND_MESSAGE.Set_Name('WSH', 'WSH_STND_POSITIVE_INTEGER');
            FND_MESSAGE.Set_Token('ATTRIBUTE', 'SHIP_TOLERANCE_ABOVE');
            l_temp_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            WSH_UTIL_CORE.Add_Message(l_temp_status, l_module_name );
         END IF;

         IF  (x_details_interface_rec_tab(i).ship_tolerance_below IS NOT NULL) AND
               ((x_details_interface_rec_tab(i).ship_tolerance_below < 0) OR
                (trunc(x_details_interface_rec_tab(i).ship_tolerance_below) <> x_details_interface_rec_tab(i).ship_tolerance_below))
         THEN
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Error: Ship Tolerance Below('||x_details_interface_rec_tab(i).ship_tolerance_below||') Validation Failed');
            END IF;
            --
            FND_MESSAGE.Set_Name('WSH', 'WSH_STND_POSITIVE_INTEGER');
            FND_MESSAGE.Set_Token('ATTRIBUTE', 'SHIP_TOLERANCE_BELOW');
            l_temp_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            WSH_UTIL_CORE.Add_Message(l_temp_status, l_module_name );
         END IF;

         --Derive Inventory Item Id
         IF ( x_details_interface_rec_tab(i).inventory_item_id is null and -- {
              x_details_interface_rec_tab(i).item_number is null )
         THEN
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Error: Inventory Item information is missing');
            END IF;
            --
            FND_MESSAGE.Set_Name('WSH', 'WSH_REQUIRED_FIELD_NULL');
            FND_MESSAGE.Set_Token('FIELD_NAME', 'ITEM_NUMBER OR ITEM_ID');
            l_temp_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            WSH_UTIL_CORE.Add_Message(l_temp_status, l_module_name );
         ELSIF x_details_interface_rec_tab(i).inventory_item_id is null
         THEN
            l_item_number    := x_details_interface_rec_tab(i).item_number;
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Calling WSH_UTIL_VALIDATE.Validate_Item', WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_UTIL_VALIDATE.Validate_Item(
                     p_item_number       => l_item_number,
                     p_organization_id   => x_details_interface_rec_tab(i).organization_id,
                     x_inventory_item_id => l_inventory_item_id,
                     x_return_status     => l_return_status );

            x_details_interface_rec_tab(i).inventory_item_id := l_inventory_item_id;

            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN -- {
               --
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name, 'Error occured in Validate_Item', WSH_DEBUG_SV.C_ERR_LEVEL);
               END IF;
               --
               l_temp_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            END IF; --}
         END IF; -- } Inventory Item Validation

         -- Customer Item Id validation
         IF ( x_details_interface_rec_tab(i).inventory_item_id is not null and
              x_details_interface_rec_tab(i).customer_item_id is null and
              x_details_interface_rec_tab(i).customer_item_number is not null )
         THEN -- {
            l_ship_to_org_id := null;
            l_customer_id    := null;
            l_address_id     := null;

            l_customer_id := p_del_interface_rec.customer_id;
            -- Derive Customer Id, if its null
            IF l_customer_id is null THEN -- {
               --
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name, 'Calling OE_Value_To_Id.Sold_To_Org', WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               --
               l_customer_id := OE_Value_To_Id.Sold_To_Org(
                                     p_sold_to_org     => p_del_interface_rec.customer_name,
                                     p_customer_number => NULL );

               IF nvl(l_customer_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN
                  l_customer_id := null;
                  --Check with klr for Error Message
                  --
                  IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name, 'Customer does not exist. So, Customer item is invalid');
                  END IF;
                  --
                  l_temp_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
               END IF;
            END IF; -- }

            --Derive Ship-To-Org, if its null
            l_ship_to_org_id := p_del_interface_rec.ship_to_address_id;
            IF ( l_customer_id is not null and
                 l_ship_to_org_id is null and
                 p_del_interface_rec.ship_to_address1 is not null )
            THEN -- {
               --
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name, 'Calling OE_Value_To_Id.Ship_To_Org', WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               --
               l_ship_to_org_id :=
                     OE_Value_To_Id.Ship_To_Org(
                              p_ship_to_address1    => p_del_interface_rec.ship_to_address1,
                              p_ship_to_address2    => p_del_interface_rec.ship_to_address2,
                              p_ship_to_address3    => p_del_interface_rec.ship_to_address3,
                              p_ship_to_address4    => p_del_interface_rec.ship_to_address4,
                              p_ship_to_location    => NULL,
                              p_ship_to_org         => NULL,
                              p_sold_to_org_id      => l_customer_id, --p_del_interface_rec.customer_id,
                              p_ship_to_city        => p_del_interface_rec.ship_to_city,
                              p_ship_to_state       => p_del_interface_rec.ship_to_state,
                              p_ship_to_postal_code => p_del_interface_rec.ship_to_postal_code,
                              p_ship_to_country     => p_del_interface_rec.ship_to_country,
                              p_ship_to_customer_id => NULL );

               IF nvl(l_ship_to_org_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM
               THEN -- {
                  l_ship_to_org_id := null;
                  --
                  IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name, 'Invalid Ship-To Information');
                  END IF;
                  --
                  l_temp_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
               END IF; -- }
            END IF; -- }

            --Derive Ship-To-Cust Site Use
            IF l_ship_to_org_id is not null THEN -- {
               BEGIN
                  SELECT cust_acct_site_id
                  INTO   l_address_id
                  FROM   hz_cust_site_uses_all
                  WHERE  org_id = p_del_interface_rec.org_id
                  AND    site_use_id = l_ship_to_org_id;

                  p_del_interface_rec.ship_to_address_id := l_ship_to_org_id;
               EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  --
                  IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name, 'No-Data-Found Exception for Customer Account Site');
                  END IF;
                  --
               END;
            END IF; -- }

            IF l_customer_id is not null or
               l_address_id is not null
            THEN -- {
               --
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name, 'Calling WSH_UTIL_VALIDATE.Validate_Customer_Item', WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               --
               WSH_UTIL_VALIDATE.Validate_Customer_Item(
                      p_item_number      => x_details_interface_rec_tab(i).customer_item_number,
                      p_customer_id      => l_customer_id,
                      p_address_id       => l_address_id,
                      x_customer_item_id => l_customer_item_id,
                      x_return_status    => l_return_status );


               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN -- {
                  --
                  IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name, 'Error occured in Validate_Customer_Item', WSH_DEBUG_SV.C_ERR_LEVEL);
                  END IF;
                  --
                  l_temp_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
               ELSE
                  x_details_interface_rec_tab(i).customer_item_id := l_customer_item_id;
               END IF; --}

            END IF; --}
         END IF; -- }

         <<loop_end>>
         IF l_temp_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
            x_return_status := l_temp_status;
            Populate_Error_Records(
                 p_interface_id             => x_details_interface_rec_tab(i).delivery_detail_interface_id,
                 p_interface_table_name     => 'WSH_DEL_DETAILS_INTERFACE',
                 x_interface_errors_rec_tab => x_interface_error_tab,
                 x_return_status            => l_return_status );
         END IF;
      END LOOP;
   END IF;

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'x_om_line_tbl_type.count', x_om_line_tbl_type.count);
      WSH_DEBUG_SV.log(l_module_name, 'Return Status',x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --

EXCEPTION
   WHEN OTHERS THEN
         IF c_del_details_interface_rec%ISOPEN THEN
            close c_del_details_interface_rec;
         END IF;
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         WSH_UTIL_CORE.Default_Handler('WSH_SHIPMENT_REQUEST_PKG.Derive_Line_Rec');
         --
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
         --
END Derive_Line_Rec;
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Populate_Line_Records
--
-- PARAMETERS:
--       p_om_line_tbl_type          => Table of standalone related order line attributes
--       p_details_interface_rec_tab => Table of Delivery Detail Interface Record
--       p_om_header_rec_type        => Standalone Order Header attributes
--       p_delivery_interface_rec    => Delivery Interface Record
--       x_line_tbl                  => Table of Order Line attributes
--       x_line_details_tbl          => Table of Delivery Detail Interface Id
--       x_return_status             => Return Status of API (Either S,E,U)
--
-- COMMENT:
--       API to populate Order Line attributes.
--       If order line already exists only the changed attributes are populated.
--=============================================================================
--
PROCEDURE Populate_Line_Records(
          p_om_line_tbl_type          IN OM_Line_Tbl_Type,
          p_details_interface_rec_tab IN Del_Details_Interface_Rec_Tab,
          p_om_header_rec_type        IN OM_Header_Rec_Type,
          p_delivery_interface_rec    IN Del_Interface_Rec_Type,
          x_line_tbl                  OUT NOCOPY OE_ORDER_PUB.Line_Tbl_Type,
          x_line_details_tbl          OUT NOCOPY WSH_UTIL_CORE.Id_Tab_Type,
          x_return_status             OUT NOCOPY VARCHAR2 )
IS
   CURSOR c_non_interface_order_lines
   IS
   SELECT oel.line_id,
          oel.line_number
   FROM   oe_order_lines_all oel
   WHERE  header_id = p_om_header_rec_type.header_id
   AND    NOT EXISTS
        ( SELECT 'X'
          FROM   Wsh_Del_Details_Interface wddi,
                 Wsh_Del_Assgn_Interface wdai,
                 Wsh_New_Del_Interface wndi
          WHERE  wddi.line_number = oel.line_number
          AND    wddi.interface_action_code = g_interface_action_code
          AND    wdai.interface_action_code = g_interface_action_code
          AND    wddi.delivery_detail_interface_id = wdai.delivery_detail_interface_id
          AND    wdai.delivery_interface_id = wndi.delivery_interface_id
          AND    wndi.delivery_interface_id = p_delivery_interface_rec.delivery_interface_id );

   l_line_cnt                   NUMBER;
   l_line_id                    NUMBER;

   --
   l_debug_on BOOLEAN;
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Populate_Line_Records';
   --
BEGIN
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name, 'x_line_tbl.count', x_line_tbl.count);
      WSH_DEBUG_SV.log(l_module_name, 'p_om_header_rec_type.header_id', p_om_header_rec_type.header_id);
      WSH_DEBUG_SV.log(l_module_name, 'p_om_line_tbl_type.count', p_om_line_tbl_type.count);
      WSH_DEBUG_SV.log(l_module_name, 'p_details_interface_rec_tab.count', p_details_interface_rec_tab.count);
   END IF;
   --

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   l_line_cnt := x_line_tbl.count;

   IF p_details_interface_rec_tab.count > 0 THEN -- { Interface records
      FOR i in p_details_interface_rec_tab.first..p_details_interface_rec_tab.last
      LOOP
         -- Bug 8452056: Skip processing interface records with Zero requested quantity
         IF ( p_details_interface_rec_tab(i).line_id is null and
              p_details_interface_rec_tab(i).requested_quantity = 0 )
         THEN
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Warning: Ordered Quantity is Zero and order line does not exist, so skipping interface record with line number '
                                         || p_details_interface_rec_tab(i).line_number );
            END IF;
            --
            goto zero_req_quantity;
         END IF;

         l_line_cnt := l_line_cnt + 1;
         x_line_tbl(l_line_cnt)     := OE_ORDER_PUB.G_MISS_LINE_REC;

         l_line_id  := p_details_interface_rec_tab(i).line_id;

         -- LSP PROJECT commented out the following code.
         /*-- Used for Error logging when PO api errors out
         x_line_details_tbl(p_details_interface_rec_tab(i).line_number) := p_details_interface_rec_tab(i).delivery_detail_interface_id; */

         IF (l_line_id is not null) THEN  /* Line Update Mode */
            x_line_tbl(l_line_cnt).line_id    := l_line_id;
            x_line_tbl(l_line_cnt).operation  := OE_GLOBALS.G_OPR_UPDATE;
            x_line_tbl(l_line_cnt).calculate_price_flag := 'N';

            IF nvl(p_details_interface_rec_tab(i).requested_quantity, FND_API.G_MISS_NUM) <>
               nvl(p_om_line_tbl_type(i).ordered_quantity, FND_API.G_MISS_NUM)
            THEN
               x_line_tbl(l_line_cnt).ordered_quantity   := p_details_interface_rec_tab(i).requested_quantity;

               --If new ordered quantity is less then order lines ordered quantity then pass change reason code
               IF p_om_line_tbl_type(i).ordered_quantity > p_details_interface_rec_tab(i).requested_quantity THEN
                  x_line_tbl(l_line_cnt).change_reason := 'Not provided';
               END IF;
            END IF;

            IF nvl(p_details_interface_rec_tab(i).requested_quantity_uom, FND_API.G_MISS_CHAR) <>
               nvl(p_om_line_tbl_type(i).order_quantity_uom, FND_API.G_MISS_CHAR)
            THEN
               x_line_tbl(l_line_cnt).order_quantity_uom := p_details_interface_rec_tab(i).requested_quantity_uom;
            END IF;

            IF nvl(p_details_interface_rec_tab(i).ship_tolerance_above, FND_API.G_MISS_NUM) <>
               nvl(p_om_line_tbl_type(i).ship_tolerance_above, FND_API.G_MISS_NUM)
            THEN
               x_line_tbl(l_line_cnt).ship_tolerance_above := p_details_interface_rec_tab(i).ship_tolerance_above;
            END IF;

            IF nvl(p_details_interface_rec_tab(i).ship_tolerance_below, FND_API.G_MISS_NUM) <>
               nvl(p_om_line_tbl_type(i).ship_tolerance_below, FND_API.G_MISS_NUM)
            THEN
               x_line_tbl(l_line_cnt).ship_tolerance_below := p_details_interface_rec_tab(i).ship_tolerance_below;
            END IF;

            IF nvl(p_details_interface_rec_tab(i).shipping_instructions, FND_API.G_MISS_CHAR) <>
               nvl(p_om_line_tbl_type(i).shipping_instructions, FND_API.G_MISS_CHAR)
            THEN
               x_line_tbl(l_line_cnt).shipping_instructions := p_details_interface_rec_tab(i).shipping_instructions;
            END IF;

            IF nvl(p_details_interface_rec_tab(i).packing_instructions, FND_API.G_MISS_CHAR) <>
               nvl(p_om_line_tbl_type(i).packing_instructions, FND_API.G_MISS_CHAR)
            THEN
               x_line_tbl(l_line_cnt).packing_instructions := p_details_interface_rec_tab(i).packing_instructions;
            END IF;

            IF nvl(p_details_interface_rec_tab(i).ship_set_name, FND_API.G_MISS_CHAR) <>
               nvl(p_om_line_tbl_type(i).ship_set_name, FND_API.G_MISS_CHAR)
            THEN
               x_line_tbl(l_line_cnt).ship_set := p_details_interface_rec_tab(i).ship_set_name;
            END IF;

            --Leelaraj, If request date is not passed during updting then following error is thrown from PO API
            --A request date is required on the line to perform scheduling.
            IF p_details_interface_rec_tab(i).date_requested IS NULL
            THEN
               x_line_tbl(l_line_cnt).request_date := p_om_line_tbl_type(i).request_date;
            ELSIF p_details_interface_rec_tab(i).date_requested <>
                      nvl(p_om_line_tbl_type(i).request_date, FND_API.G_MISS_DATE)
            THEN
               x_line_tbl(l_line_cnt).request_date := p_details_interface_rec_tab(i).date_requested;
            END IF;

            IF p_details_interface_rec_tab(i).date_scheduled is null
            THEN
               x_line_tbl(l_line_cnt).schedule_ship_date := p_om_line_tbl_type(i).schedule_ship_date;
            ELSIF p_details_interface_rec_tab(i).date_scheduled <>
                         nvl(p_om_line_tbl_type(i).schedule_ship_date, FND_API.G_MISS_DATE)
            THEN
               x_line_tbl(l_line_cnt).schedule_ship_date := p_details_interface_rec_tab(i).date_scheduled;
            END IF;

            IF nvl(p_details_interface_rec_tab(i).shipment_priority_code, FND_API.G_MISS_CHAR) <>
               nvl(p_om_line_tbl_type(i).shipment_priority_code, FND_API.G_MISS_CHAR)
            THEN
               x_line_tbl(l_line_cnt).shipment_priority_code   := p_details_interface_rec_tab(i).shipment_priority_code;
            END IF;

            IF nvl(p_details_interface_rec_tab(i).cust_po_number, FND_API.G_MISS_CHAR) <>
               nvl(p_om_line_tbl_type(i).cust_po_number, FND_API.G_MISS_CHAR)
            THEN
               x_line_tbl(l_line_cnt).cust_po_number   := p_details_interface_rec_tab(i).cust_po_number;
            END IF;

            IF nvl(p_details_interface_rec_tab(i).subinventory, FND_API.G_MISS_CHAR) <>
               nvl(p_om_line_tbl_type(i).subinventory, FND_API.G_MISS_CHAR)
            THEN
               x_line_tbl(l_line_cnt).subinventory   := p_details_interface_rec_tab(i).subinventory;
            END IF;

            IF nvl(p_details_interface_rec_tab(i).unit_selling_price, FND_API.G_MISS_NUM) <>
               nvl(p_om_line_tbl_type(i).unit_selling_price, FND_API.G_MISS_NUM)
            THEN
               x_line_tbl(l_line_cnt).unit_selling_price   := p_details_interface_rec_tab(i).unit_selling_price;
            END IF;

            -- Inventory item cannot be changed on booked order line. OM PO api will error out
            -- if Item is being changed for booked order line.
            -- While fixing any bugs in future, shipping should error out wihtout calling OM api
            -- if Item is being changed on booked sales order line.
            IF nvl(p_details_interface_rec_tab(i).inventory_item_id, FND_API.G_MISS_NUM) <>
               nvl(p_om_line_tbl_type(i).inventory_item_id, FND_API.G_MISS_NUM)
            THEN
               x_line_tbl(l_line_cnt).inventory_item_id := p_details_interface_rec_tab(i).inventory_item_id;
            END IF;

            -- Do not pass NULL value to ordered_item_id, if customer_item_id derived from
            -- Interface table is NULL. If NULL value is passed then OM triggers re-pricing.
            -- Refer bug 7648864 for more details.
            IF p_details_interface_rec_tab(i).customer_item_id is not null and
               ( p_details_interface_rec_tab(i).customer_item_id <>
                 nvl(p_om_line_tbl_type(i).ordered_item_id, FND_API.G_MISS_NUM) )
            THEN
               x_line_tbl(l_line_cnt).ordered_item_id := p_details_interface_rec_tab(i).customer_item_id;
            END IF;

         ELSIF ( l_line_id is null ) THEN /* Line Create Mode */
            -- LSP PROJECT.
            SELECT oe_order_lines_S.NEXTVAL into l_line_id from dual;
            x_line_tbl(l_line_cnt).line_id    := l_line_id;
            -- LSP PROJECT : end
            x_line_tbl(l_line_cnt).operation              := OE_GLOBALS.G_OPR_CREATE;
            x_line_tbl(l_line_cnt).calculate_price_flag   := 'N';
            x_line_tbl(l_line_cnt).line_number            := p_details_interface_rec_tab(i).line_number;
            x_line_tbl(l_line_cnt).shipment_number        := 1;
            x_line_tbl(l_line_cnt).inventory_item_id      := p_details_interface_rec_tab(i).inventory_item_id;
            x_line_tbl(l_line_cnt).ordered_quantity       := p_details_interface_rec_tab(i).requested_quantity;
            x_line_tbl(l_line_cnt).order_quantity_uom     := p_details_interface_rec_tab(i).requested_quantity_uom;

            IF p_details_interface_rec_tab(i).customer_item_id is not null THEN
               x_line_tbl(l_line_cnt).ordered_item_id      := p_details_interface_rec_tab(i).customer_item_id;
               x_line_tbl(l_line_cnt).item_identifier_type := 'CUST';
            END IF;
            --USP and ULP is mandatory for booking sales order
            x_line_tbl(l_line_cnt).unit_selling_price     := nvl(p_details_interface_rec_tab(i).unit_selling_price, 0);
            x_line_tbl(l_line_cnt).unit_list_price        := x_line_tbl(l_line_cnt).unit_selling_price;
            x_line_tbl(l_line_cnt).ship_tolerance_above   := p_details_interface_rec_tab(i).ship_tolerance_above;
            x_line_tbl(l_line_cnt).ship_tolerance_below   := p_details_interface_rec_tab(i).ship_tolerance_below;
            x_line_tbl(l_line_cnt).request_date           := nvl(p_details_interface_rec_tab(i).date_requested, SYSDATE);
            x_line_tbl(l_line_cnt).schedule_ship_date     := p_details_interface_rec_tab(i).date_scheduled;
            x_line_tbl(l_line_cnt).packing_instructions   := p_details_interface_rec_tab(i).packing_instructions;
            x_line_tbl(l_line_cnt).shipping_instructions  := p_details_interface_rec_tab(i).shipping_instructions;
            x_line_tbl(l_line_cnt).shipment_priority_code := p_details_interface_rec_tab(i).shipment_priority_code;
            x_line_tbl(l_line_cnt).ship_set               := p_details_interface_rec_tab(i).ship_set_name;
            x_line_tbl(l_line_cnt).cust_po_number         := p_details_interface_rec_tab(i).cust_po_number;
            x_line_tbl(l_line_cnt).subinventory           := p_details_interface_rec_tab(i).subinventory;
            x_line_tbl(l_line_cnt).ship_from_org_id       := p_delivery_interface_rec.organization_id;
         END IF;
         -- LSP PROJECT: Begin
         x_line_tbl(l_line_cnt).orig_sys_document_ref   := p_details_interface_rec_tab(i).source_header_number;
         x_line_tbl(l_line_cnt).orig_sys_line_ref       := p_details_interface_rec_tab(i).source_line_number;
         --
         /* Used for Error logging when PO api errors out */
         x_line_details_tbl(MOD(l_line_id,G_BINARY_LIMIT)) := p_details_interface_rec_tab(i).delivery_detail_interface_id;
         -- LSP PROJECT: end

         <<zero_req_quantity>>
            null;
      END LOOP;
   END IF; -- } Interface records

   l_line_cnt := x_line_tbl.count;

   IF p_om_header_rec_type.header_attributes_changed
   THEN -- { Non-Interface Order Lines
      FOR l_non_interface_rec in c_non_interface_order_lines
      LOOP
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Non-Interface details, Line Id => ' || l_non_interface_rec.line_id
                                   || ', Line Number => ' || l_non_interface_rec.line_number );
         END IF;
         l_line_cnt := l_line_cnt + 1;
         x_line_tbl(l_line_cnt)                 := OE_ORDER_PUB.G_MISS_LINE_REC;
         x_line_tbl(l_line_cnt).operation       := OE_GLOBALS.G_OPR_UPDATE;
         x_line_tbl(l_line_cnt).line_id         := l_non_interface_rec.line_id;
         x_line_tbl(l_line_cnt).calculate_price_flag    := 'N';
         -- LSP PROJECT: commented the following after discussion with UMA.
         -- No need to change these values on the existing lines.
         /*x_line_tbl(l_line_cnt).orig_sys_document_ref   := 'SHIPMENT_REQUEST' || p_delivery_interface_rec.order_number;
         x_line_tbl(l_line_cnt).orig_sys_line_ref       := 'SHIPMENT_REQUEST_LINE' || l_non_interface_rec.line_number;*/
         -- LSP PROJECT: end
      END LOOP;
   END IF; -- } Non-Interface Order Lines

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'Return Status',x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
EXCEPTION
   WHEN OTHERS THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         WSH_UTIL_CORE.Default_Handler('WSH_SHIPMENT_REQUEST_PKG.Populate_Line_Records');
         --
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
         --
END Populate_Line_Records;
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Validate_Organization
--
-- PARAMETERS:
--       p_org_code        => Organization Code
--       p_organization_id => Organization Id
--       x_return_status   => Return Status of API (Either S,E,U)
--
-- COMMENT:
--       API to validate organization id/code passed. Organization should
--       be WMS enabled and NOT Process manufacturing enabled.
--=============================================================================
--
PROCEDURE Validate_Organization(
          p_org_code         IN VARCHAR2,
          p_organization_id  IN OUT NOCOPY NUMBER,
          x_return_status    OUT NOCOPY VARCHAR2 )
IS

   l_organization_code          VARCHAR2(3);
   l_return_status              VARCHAR2(1);
   --
   l_debug_on BOOLEAN;
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Validate_Organization';
   --
BEGIN
   --Debug Push
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name, 'p_organization_id', p_organization_id);
      WSH_DEBUG_SV.log(l_module_name, 'p_org_code', p_org_code);
   END IF;
   --

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   IF ( p_org_code is not null or p_organization_id is not null )
   THEN
      --Validate Organization Code from Interface table
      IF p_organization_id is not null THEN
         l_organization_code := null;
      ELSE
         l_organization_code := p_org_code;
      END IF;

      --
      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'Calling api WSH_UTIL_VALIDATE.Validate_Org', WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      WSH_UTIL_VALIDATE.Validate_Org (
                        p_org_id        => p_organization_id,
                        p_org_code      => l_organization_code,
                        x_return_status => l_return_status );

      --
      IF l_debug_on THEN
         wsh_debug_sv.log(l_module_name, 'Return Status', l_return_status);
         wsh_debug_sv.logmsg(l_module_name, 'Organization Id => ' || p_organization_id
                                     || ', Organization Code => ' || l_organization_code );
      END IF;
      --

      IF ( l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS )
      THEN
         --
         IF l_debug_on THEN
            wsh_debug_sv.logmsg(l_module_name, 'Calling api WSH_UTIL_VALIDATE.Validate_SR_Organization', WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --
         WSH_UTIL_VALIDATE.Validate_SR_Organization(
                           p_organization_id => p_organization_id,
                           x_return_status   => l_return_status );

         --
         IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name, 'Validate_SR_Organization Return Status', l_return_status);
         END IF;
         --

      END IF;

      IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
         x_return_status := l_return_status;
      END IF;
   ELSE
      --
      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'Error: Organization information is missing.');
      END IF;
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('WSH', 'WSH_REQUIRED_FIELD_NULL');
      FND_MESSAGE.Set_Token('FIELD_NAME', 'ORGANIZATION');
      WSH_UTIL_CORE.Add_Message(x_return_status, l_module_name );
   END IF;

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'Return Status',x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
EXCEPTION
WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.Default_Handler('WSH_SHIPMENT_REQUEST_PKG.Validate_Organization');
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Validate_Organization;
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Validate_Ship_Method
--
-- PARAMETERS:
--       p_carrier_code      => Freight Code
--       p_organization_id   => Organization id
--       p_service_level     => Service Level
--       p_mode_of_transport => Mode of Transport
--       x_ship_method_code  => Ship Method Code derived
--       x_return_status     => Return Status of API (Either S,E,U)
--
-- COMMENT:
--       API to validate lookups Service Level and Mode of Transaport. Derives
--       Ship Method code based on Carrier Id, Service Level, Mode of transport
--       and Organization passed.
--=============================================================================
--
PROCEDURE Validate_Ship_Method(
          p_carrier_code      IN  VARCHAR2,
          p_organization_id   IN  NUMBER,
          p_service_level     IN  VARCHAR2,
          p_mode_of_transport IN  VARCHAR2,
          x_ship_method_code  OUT NOCOPY VARCHAR2,
          x_return_status     OUT NOCOPY VARCHAR2 )
IS
   l_return_status              VARCHAR2(1);
   l_service_level              VARCHAR2(30);
   l_mode_of_transport          VARCHAR2(30);

   --
   l_debug_on BOOLEAN;
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Validate_Ship_Method';
   --
BEGIN
   --Debug Push
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name, 'p_carrier_code', p_carrier_code);
      WSH_DEBUG_SV.log(l_module_name, 'p_service_level', p_service_level);
      WSH_DEBUG_SV.log(l_module_name, 'p_mode_of_transport', p_mode_of_transport);
      WSH_DEBUG_SV.log(l_module_name, 'p_organization_id', p_organization_id);
   END IF;
   --

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   --
   IF l_debug_on THEN
      wsh_debug_sv.logmsg(l_module_name, 'Calling api WSH_UTIL_VALIDATE.Validate_Lookup', WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   l_service_level := p_service_level;

   WSH_UTIL_VALIDATE.Validate_Lookup(
            p_lookup_type   => 'WSH_SERVICE_LEVELS',
            p_lookup_code   => l_service_level,
            p_meaning       => null,
            x_return_status => l_return_status );

   IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
      --
      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'Error occured in Validate_Lookup(SL)', WSH_DEBUG_SV.C_ERR_LEVEL);
      END IF;
      --
      x_return_status := l_return_status;
   END IF;

   --
   IF l_debug_on THEN
      wsh_debug_sv.logmsg(l_module_name, 'Calling api WSH_UTIL_VALIDATE.Validate_Lookup', WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --

   l_mode_of_transport := p_mode_of_transport;

   WSH_UTIL_VALIDATE.Validate_Lookup(
            p_lookup_type   => 'WSH_MODE_OF_TRANSPORT',
            p_lookup_code   => l_mode_of_transport,
            p_meaning       => null,
            x_return_status => l_return_status );

   IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
      --
      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'Error occured in Validate_Lookup(MOT)', WSH_DEBUG_SV.C_ERR_LEVEL);
      END IF;
      --
      x_return_status := l_return_status;
   END IF;

   IF x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS and
      p_organization_id is not null
   THEN
      --
      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'Calling api WSH_UTIL_VALIDATE.Validate_Ship_Method', WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      WSH_UTIL_VALIDATE.Validate_Ship_Method(
               p_organization_id   => p_organization_id,
               p_carrier_code      => p_carrier_code,
               p_service_level     => p_service_level,
               p_mode_of_transport => p_mode_of_transport,
               x_ship_method_code  => x_ship_method_code,
               x_return_status     => l_return_status );

      IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
         --
         IF l_debug_on THEN
            wsh_debug_sv.logmsg(l_module_name, 'Error occured in Validate_Ship_Method', WSH_DEBUG_SV.C_ERR_LEVEL);
         END IF;
         --
         x_return_status := l_return_status;
      END IF;
   END IF;

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'Ship Method is '||x_ship_method_code);
      WSH_DEBUG_SV.log(l_module_name, 'Return Status',x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
EXCEPTION
WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.Default_Handler('WSH_SHIPMENT_REQUEST_PKG.Validate_Ship_Method');
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Validate_Ship_Method;
--
--=============================================================================
-- PRIVATE PROCEDURE :
--       Populate_Error_Records
--
-- PARAMETERS:
--       p_interface_id             => Interface Id (Delivery_Interface_Id or Delivery_Detail_Interface_Id)
--       p_interface_table_name     => Interface Table Name( WNDI or WDDI)
--       x_interface_errors_rec_tab => Table of Interface Error records
--       x_return_status            => Return Status of API (Either S,U)
--
-- COMMENT:
--       Populates error messages set in stack to x_interface_errors_rec_tab
--=============================================================================
--
PROCEDURE Populate_Error_Records(
          p_interface_id             IN  NUMBER,
          p_interface_table_name     IN  VARCHAR2,
          x_interface_errors_rec_tab IN OUT NOCOPY WSH_INTERFACE_VALIDATIONS_PKG.interface_errors_rec_tab,
          x_return_status            OUT NOCOPY VARCHAR2 )
IS
   l_error_count                NUMBER;
   l_msg_count                  NUMBER;

   --
   l_debug_on BOOLEAN;
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Populate_Error_Records';
   --
BEGIN
   --Debug Push
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name, 'p_interface_id', p_interface_id);
      WSH_DEBUG_SV.log(l_module_name, 'p_interface_table_name', p_interface_table_name);
      WSH_DEBUG_SV.log(l_module_name, 'x_interface_errors_rec_tab.count', x_interface_errors_rec_tab.count);
   END IF;
   --

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   l_error_count := x_interface_errors_rec_tab.count;
   l_msg_count   := FND_MSG_PUB.count_msg;
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'FND_MSG_PUB.count_msg', l_msg_count);
   END IF;
   --

   IF l_msg_count > 0 THEN
      FOR i in 1..l_msg_count
      LOOP
         l_error_count := l_error_count + 1;
         x_interface_errors_rec_tab(l_error_count).p_interface_table_name := p_interface_table_name;
         x_interface_errors_rec_tab(l_error_count).p_interface_id := p_interface_id;
         x_interface_errors_rec_tab(l_error_count).p_text := FND_MSG_PUB.Get(i, FND_API.G_FALSE);
      END LOOP;
   END IF;

   FND_MSG_PUB.initialize;

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'x_interface_errors_rec_tab.count', x_interface_errors_rec_tab.count);
      WSH_DEBUG_SV.log(l_module_name, 'Return Status',x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
EXCEPTION
WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.Default_Handler('WSH_SHIPMENT_REQUEST_PKG.Populate_Error_Records');
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Populate_Error_Records;
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Validate_Interface_Details
--
-- PARAMETERS:
--       p_details_interface_tab    => Table of Delivery Detail Interface record
--       x_interface_errors_rec_tab => Table of Interface Error records
--       x_return_status            => Return Status of API (Either S,E,U)
--
-- COMMENT:
--       API to validate Inventory attributes like revision, locator.
--       Inventory attributes cannot be changed if delivery line corresponding
--       to shipment line is picked or in a confirmed delivery or has been shipped.
--       Schedule dates cannot be changed if delivery line corresponding to
--       shipment line is in a confirmed delivery or has been shipped.
--=============================================================================
--
PROCEDURE Validate_Interface_Details(
          p_details_interface_tab IN OUT NOCOPY Del_Details_Interface_Rec_Tab,
          x_interface_error_tab   OUT NOCOPY WSH_INTERFACE_VALIDATIONS_PKG.interface_errors_rec_tab,
          x_return_status         OUT NOCOPY VARCHAR2 )
IS

   CURSOR c_delivery_details_info(c_line_id NUMBER)
   IS
   SELECT wdd.delivery_detail_id,
          wdd.original_subinventory,
          wdd.original_lot_number,
          wdd.original_revision,
          wdd.original_locator_id,
          wdd.organization_id,
          wdd.inventory_item_id,
          wdd.earliest_pickup_date,
          wdd.latest_pickup_date,
          wdd.earliest_dropoff_date,
          wdd.latest_dropoff_date,
          wdd.source_line_id,
          wdd.reference_number,
          wdd.reference_line_number,
          wdd.reference_line_quantity,
          wdd.reference_line_quantity_uom,
          wdd.rowid
   FROM   Wsh_Delivery_Details wdd
   WHERE  wdd.source_code = 'OE'
   AND    wdd.source_line_id = c_line_id
   AND    ROWNUM = 1;

   l_delivery_details_rec       c_delivery_details_info%rowtype;
   l_return_status              VARCHAR2(1);
   l_changed_flag               VARCHAR2(1);
   l_tmp                        VARCHAR2(1);
   l_temp_status                VARCHAR2(1);
   l_line_id                    NUMBER;
   l_inv_control_changed        BOOLEAN;
   l_inv_result                 BOOLEAN;

   --
   l_debug_on BOOLEAN;
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Validate_Interface_Details';
   --
BEGIN
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name, 'p_details_interface_tab.count', p_details_interface_tab.count);
   END IF;
   --

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   FOR i in p_details_interface_tab.first..p_details_interface_tab.last
   LOOP --{
      l_temp_status  := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      l_changed_flag := 'N';
      l_inv_control_changed := FALSE;
      l_line_id := p_details_interface_tab(i).line_id;
      p_details_interface_tab(i).schedule_date_changed := 'N';

      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'delivery_interface_id => ' || p_details_interface_tab(i).delivery_detail_interface_id
                                     || ', Line Id => ' || l_line_id );
      END IF;
      --

      -- No validation to be performed if line is cancelled
      IF p_details_interface_tab(i).requested_quantity = 0 THEN
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Line Number ' || p_details_interface_tab(i).line_number
                         || ' is cancelled, so skipping complete interface detail validation......' );
         END IF;
         --
         goto end_loop;
      END IF;

      IF l_line_id is null THEN --{
         l_changed_flag := 'Y';
         p_details_interface_tab(i).changed_flag := l_changed_flag;
         p_details_interface_tab(i).schedule_date_changed := 'Y';
      ELSE
         OPEN  c_delivery_details_info(l_line_id);
         FETCH c_delivery_details_info into l_delivery_details_rec;
         IF c_delivery_details_info%NOTFOUND THEN
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Error: For order line ' || l_line_id
                            || ', delivery detail does not exist in WDD table' );
            END IF;
            --
            l_temp_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            -- Modified Message Name while fixing bug 8452056.
            WSH_UTIL_CORE.Add_Message(l_temp_status, 'NO_DATA_FOUND');
            goto end_loop;
         END IF;
         CLOSE c_delivery_details_info;

         -- Schedule Date Changes
         IF (    ( nvl(p_details_interface_tab(i).earliest_pickup_date, FND_API.G_MISS_DATE ) <>
                   nvl(l_delivery_details_rec.earliest_pickup_date, FND_API.G_MISS_DATE ) )
              OR ( nvl(p_details_interface_tab(i).earliest_dropoff_date, FND_API.G_MISS_DATE ) <>
                   nvl(l_delivery_details_rec.earliest_dropoff_date, FND_API.G_MISS_DATE ) )
              OR ( nvl(p_details_interface_tab(i).latest_pickup_date, FND_API.G_MISS_DATE ) <>
                   nvl(l_delivery_details_rec.latest_pickup_date, FND_API.G_MISS_DATE ) )
              OR ( nvl(p_details_interface_tab(i).latest_dropoff_date, FND_API.G_MISS_DATE ) <>
                   nvl(l_delivery_details_rec.latest_dropoff_date, FND_API.G_MISS_DATE ) )
            )
         THEN
            l_changed_flag := 'Y';
            p_details_interface_tab(i).schedule_date_changed := 'Y';

            BEGIN
               select 'x'
               into   l_tmp
               from   wsh_delivery_details wdd
               where  source_code = 'OE'
               and    source_line_id = l_line_id
               and    released_status in ( 'Y', 'C' )
               and    exists
                    ( select 'y'
                      from   wsh_delivery_assignments wda,
                             wsh_new_deliveries       wnd
                      where  wnd.status_code in ( 'CO', 'IT', 'CL' )
                      and    wnd.delivery_id = wda.delivery_id
                      and    wda.delivery_detail_id = wdd.delivery_detail_id )
               and    rownum = 1;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
               l_tmp := null;
            END;

            IF l_tmp is not null THEN
               --
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name, 'Error: Schedule dates cannot be changed.');
               END IF;
               --
               l_temp_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
               FND_MESSAGE.Set_Name('WSH', 'WSH_STND_REJ_SCH_DATE_CHANGE');
               WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_ERROR, l_module_name );
               goto end_loop;
            END IF;
         END IF;

         -- Reference Information Changes.
         IF (
              (  nvl(p_details_interface_tab(i).source_line_number, FND_API.G_MISS_CHAR) <>
                 nvl(l_delivery_details_rec.reference_line_number, FND_API.G_MISS_CHAR) ) OR
              (  nvl(p_details_interface_tab(i).source_header_number, FND_API.G_MISS_CHAR) <>
                 nvl(l_delivery_details_rec.reference_number, FND_API.G_MISS_CHAR) ) OR
              (  nvl(p_details_interface_tab(i).src_requested_quantity, FND_API.G_MISS_NUM) <>
                 nvl(l_delivery_details_rec.reference_line_quantity, FND_API.G_MISS_NUM) ) OR
              (  nvl(p_details_interface_tab(i).src_requested_quantity_uom, FND_API.G_MISS_CHAR) <>
                 nvl(l_delivery_details_rec.reference_line_quantity_uom, FND_API.G_MISS_CHAR) )
            )
         THEN
            l_changed_flag := 'Y';
         END IF;
      END IF; --}

      -- Inventory Control Validation Starts
      IF p_details_interface_tab(i).locator_id is null and
         p_details_interface_tab(i).locator_code is not null
      THEN
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Calling WSH_UTIL_VALIDATE.Validate_Locator_Code', WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --
         WSH_UTIL_VALIDATE.Validate_Locator_Code(
                p_locator_code    => p_details_interface_tab(i).locator_code,
                p_organization_id => p_details_interface_tab(i).organization_id,
                x_locator_id      => p_details_interface_tab(i).locator_id,
                x_return_status   => l_return_status );

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS or
            p_details_interface_tab(i).locator_id is null
         THEN
            --
            IF l_debug_on THEN
               wsh_debug_sv.logmsg(l_module_name, 'Error occured in Validate_Locator_Code', WSH_DEBUG_SV.C_ERR_LEVEL);
            END IF;
            --
            l_temp_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            goto end_loop;
         END IF;
      END IF;

      IF ( (  l_line_id is not null ) AND
           (  nvl(p_details_interface_tab(i).revision, FND_API.G_MISS_CHAR) <>
              nvl(l_delivery_details_rec.original_revision, FND_API.G_MISS_CHAR) ) OR
           (  nvl(p_details_interface_tab(i).locator_id, FND_API.G_MISS_NUM) <>
              nvl(l_delivery_details_rec.original_locator_id, FND_API.G_MISS_NUM) ) OR
           (  nvl(p_details_interface_tab(i).lot_number, FND_API.G_MISS_CHAR) <>
              nvl(l_delivery_details_rec.original_lot_number, FND_API.G_MISS_CHAR) )
         )
      THEN
         l_changed_flag := 'Y';
         l_inv_control_changed := TRUE;

         BEGIN
            select 'x'
            into   l_tmp
            from   wsh_delivery_details
            where  source_code = 'OE'
            and    source_line_id = l_line_id
            and    released_status in ( 'S', 'Y', 'C' )
            and    rownum = 1;
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_tmp := null;
         END;

         IF l_tmp is not null THEN
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Error: Inventory attributes cannot be changed.');
            END IF;
            --
            l_temp_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            FND_MESSAGE.Set_Name('WSH', 'WSH_STND_REJ_INV_CTRL_CHANGE');
            WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_ERROR, l_module_name );
            goto end_loop;
         END IF;
      END IF;

      --Revision validation begins
      IF ( ( l_inv_control_changed and
             p_details_interface_tab(i).revision is not null ) OR
           ( l_line_id is null AND
             p_details_interface_tab(i).revision is not null ) )
      THEN
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Calling WSH_DELIVERY_DETAILS_INV.Validate_Revision', WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --

         WSH_DELIVERY_DETAILS_INV.Validate_Revision(
             p_revision          => p_details_interface_tab(i).revision,
             p_organization_id   => p_details_interface_tab(i).organization_id,
             p_inventory_item_id => p_details_interface_tab(i).inventory_item_id,
             x_return_status     => l_return_status,
             x_result            => l_inv_result );

         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name, 'Result after validate revision', l_inv_result);
             WSH_DEBUG_SV.log(l_module_name, 'Return status after validate revision', l_return_status);
         END IF;
         --

         IF NOT l_inv_result THEN
            l_temp_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            WSH_UTIL_CORE.Add_Message(l_temp_status, 'WSH_INVALID_REVISION');
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Error: Invalid Revision');
            END IF;
            --
         END IF;
      END IF;

      IF ( ( l_inv_control_changed and
             p_details_interface_tab(i).locator_id is not null ) OR
           ( l_line_id is null AND
             p_details_interface_tab(i).locator_id is not null ) )
      THEN
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Calling WSH_DELIVERY_DETAILS_INV.Validate_Locator', WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --

         WSH_DELIVERY_DETAILS_INV.Validate_Locator(
             p_locator_id        => p_details_interface_tab(i).locator_id,
             p_inventory_item_id => p_details_interface_tab(i).inventory_item_id,
             p_organization_id   => p_details_interface_tab(i).organization_id,
             p_subinventory      => p_details_interface_tab(i).subinventory,
             x_return_status     => l_return_status,
             x_result            => l_inv_result );

         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name, 'Result after validate locator', l_inv_result);
             WSH_DEBUG_SV.log(l_module_name, 'Return status after validate locator', l_return_status);
         END IF;
         --

         IF NOT l_inv_result THEN
            l_temp_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            WSH_UTIL_CORE.Add_Message(l_temp_status, 'WSH_INVALID_LOCATOR');
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Error: Invalid Locator');
            END IF;
            --
         END IF;
      END IF;

      /* 1/21/2009 : Validation for lot number removed as the material could
         be received in the lot before Pick Release

      IF ( ( l_inv_control_changed and
             p_details_interface_tab(i).lot_number is not null ) OR
           ( l_line_id is null AND
             p_details_interface_tab(i).lot_number is not null ) )
      THEN
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Calling WSH_DELIVERY_DETAILS_INV.Validate_Lot_Number', WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --

         WSH_DELIVERY_DETAILS_INV.Validate_Lot_Number(
             p_lot_number        => p_details_interface_tab(i).lot_number,
             p_organization_id   => p_details_interface_tab(i).organization_id,
             p_inventory_item_id => p_details_interface_tab(i).inventory_item_id,
             p_subinventory      => p_details_interface_tab(i).subinventory,
             p_revision          => p_details_interface_tab(i).revision,
             p_locator_id        => p_details_interface_tab(i).locator_id,
             x_return_status     => l_return_status,
             x_result            => l_inv_result );

         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name, 'Result after validate lot', l_inv_result);
             WSH_DEBUG_SV.log(l_module_name, 'Return status after validate lot', l_return_status);
         END IF;
         --

         IF NOT l_inv_result THEN
            l_temp_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            WSH_UTIL_CORE.Add_Message(l_temp_status, 'WSH_INVALID_LOT');
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Error: Invalid Lot Number');
            END IF;
            --
         END IF;
      END IF;
      */
      --Inventory Control validation ends

      p_details_interface_tab(i).changed_flag := l_changed_flag;

      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'changed_flag => ' || p_details_interface_tab(i).changed_flag ||
                          ', schedule_date_changed => ' || p_details_interface_tab(i).schedule_date_changed );
      END IF;
      --

      <<end_loop>>
         IF l_temp_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
            x_return_status := l_temp_status;

            Populate_Error_Records(
                 p_interface_id             => p_details_interface_tab(i).delivery_detail_interface_id,
                 p_interface_table_name     => 'WSH_DEL_DETAILS_INTERFACE',
                 x_interface_errors_rec_tab => x_interface_error_tab,
                 x_return_status            => l_return_status );
         END IF;
   END LOOP; --}

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'x_interface_error_tab.COUNT', x_interface_error_tab.COUNT);
      WSH_DEBUG_SV.log(l_module_name, 'Return Status',x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
EXCEPTION
   WHEN OTHERS THEN
         IF c_delivery_details_info%ISOPEN THEN
            CLOSE c_delivery_details_info;
         END IF;

         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         WSH_UTIL_CORE.Default_Handler('WSH_SHIPMENT_REQUEST_PKG.Validate_Interface_Details');
         --
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
         --
END Validate_Interface_Details;

END WSH_SHIPMENT_REQUEST_PKG;

/
