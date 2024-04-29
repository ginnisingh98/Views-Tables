--------------------------------------------------------
--  DDL for Package Body WSH_SHIPMENT_ADVICE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_SHIPMENT_ADVICE_PKG" AS
/* $Header: WSHSAPKB.pls 120.0.12010000.1 2010/02/25 17:06:18 sankarun noship $ */

   G_PKG_NAME      CONSTANT VARCHAR2(30) := 'WSH_SHIPMENT_ADVICE_PKG';
   g_interface_action_code  WSH_NEW_DEL_INTERFACE.INTERFACE_ACTION_CODE%TYPE := '94X_INBOUND';

--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Shipment_Advice_Inbound
--
-- PARAMETERS:
--       errbuf                 => Message returned to Concurrent Manager
--       retcode                => Code (0, 1, 2) returned to Concurrent Manager
--       p_transaction_status   => Either AP, ER, NULL
--       p_from_document_number => From Document Number
--       p_to_document_number   => To Document Number
--       p_from_creation_date   => From Creation Date
--       p_to_creation_date     => To Creation Date
--       p_transaction_id       => Transacation id to be processed
--       p_log_level            => Either 1(Debug), 0(No Debug)
-- COMMENT:
--       API will be invoked from Concurrent Manager whenever concurrent program
--       'Process Shipment Advices' is triggered.
--=============================================================================
--
PROCEDURE Shipment_Advice_Inbound (
          errbuf                 OUT NOCOPY   VARCHAR2,
          retcode                OUT NOCOPY   NUMBER,
          p_transaction_status   IN  VARCHAR2,
          p_from_document_number IN  VARCHAR2,
          p_to_document_number   IN  VARCHAR2,
          p_from_creation_date   IN  VARCHAR2,
          p_to_creation_date     IN  VARCHAR2,
          p_transaction_id       IN  NUMBER,
          p_log_level            IN  NUMBER )
IS
   l_completion_status          VARCHAR2(30);
   l_return_status              VARCHAR2(1);

   l_debug_on                 BOOLEAN;
   l_module_name CONSTANT     VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Shipment_Advice_Inbound';
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
      WSH_DEBUG_SV.logmsg(l_module_name, 'Calling Process_Shipment_Advice', WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --

   Process_Shipment_Advice(
            p_commit_flag          => FND_API.G_TRUE,
            p_transaction_status   => p_transaction_status,
            p_from_document_number => p_from_document_number,
            p_to_document_number   => p_to_document_number,
            p_from_creation_date   => p_from_creation_date,
            p_to_creation_date     => p_to_creation_date,
            p_transaction_id       => p_transaction_id,
            x_return_status        => l_return_status );

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'Return Status of Process_Shipment_Advice', l_return_status);
   END IF;
   --


   IF l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      l_completion_status := 'SUCCESS';
      errbuf := 'Process Shipment Advices Program has completed successfully';
      retcode := '0';
   ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
      l_completion_status := 'WARNING';
      errbuf := 'Process Shipment Advices Program has completed with warning';
      retcode := '1';
   ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
      l_completion_status := 'ERROR';
      errbuf := 'Process Shipment Advices Program has completed with error';
      retcode := '2';
   ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
      l_completion_status := 'UNEXPECTED ERROR';
      errbuf := 'Process Shipment Advices Program has completed with unexpected error';
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
      errbuf := 'Process Shipment Advices Program is completed with unexpected error - ' || SQLCODE;
      retcode := '2';
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Shipment_Advice_Inbound;
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Process_Shipment_Advice
--
-- PARAMETERS:
--       p_commit_flag          => Either FND_API.G_TRUE, FND_API.G_FALSE
--       p_transaction_status   => Either AP, ER, NULL
--	     p_from_document_number => From Document Number
--       p_to_document_number   => To Document Number
--       p_from_creation_date   => From Creation Date
--       p_to_creation_date     => To Creation Date
--       p_transaction_id       => Transacation id to be processed
--       x_return_status        => Return Status of API (S,W,E,U)
-- COMMENT:
--       Based on input parameter values, eligble records for processing are
--       queried from WTH table.
--       Calling API WSH_PROCESS_INTERFACED_PKG.Process_Inbound to process the
--       eligible records queried from WTH table.
--=============================================================================
PROCEDURE Process_Shipment_Advice (
          p_commit_flag          IN  VARCHAR2,
          p_transaction_status   IN  VARCHAR2,
          p_from_document_number IN  VARCHAR2,
          p_to_document_number   IN  VARCHAR2,
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
	     null
   FROM   Wsh_Transactions_History wth,
          Wsh_New_Del_Interface wndi
   WHERE  wndi.interface_action_code = g_interface_action_code
   AND    wndi.delivery_interface_id = to_number(wth.entity_number)
   AND    wth.transaction_id = p_transaction_id
   AND    wth.transaction_status = nvl(p_transaction_status, wth.transaction_status);

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
   l_tpw_install                VARCHAR2(30);
   l_transaction_query          VARCHAR2(15000);

   l_debug_on                 BOOLEAN;
   l_module_name CONSTANT     VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Process_Shipment_Advice';
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
      wsh_debug_sv.log(l_module_name, 'p_from_document_number', p_from_document_number);
      wsh_debug_sv.log(l_module_name, 'p_to_document_number', p_to_document_number);
      wsh_debug_sv.log(l_module_name, 'p_from_creation_date', p_from_creation_date);
      wsh_debug_sv.log(l_module_name, 'p_to_creation_date', p_to_creation_date);
      wsh_debug_sv.log(l_module_name, 'p_transaction_id', p_transaction_id);
   END IF;
   --

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   l_tpw_install := FND_PROFILE.Value('WSH_SR_SOURCE');
   IF nvl(l_tpw_install, FND_API.G_MISS_CHAR) <> 'B' THEN
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Error: Profile option "WSH: Distributed Source Entity" value is not set to B(Batch)', l_tpw_install);
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      --
   END IF;

   l_from_creation_date   := to_date(p_from_creation_date,'YYYY/MM/DD HH24:MI:SS');
   l_to_creation_date     := to_date(p_to_creation_date,'YYYY/MM/DD HH24:MI:SS');

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_from_creation_date',l_from_creation_date);
      WSH_DEBUG_SV.log(l_module_name,'l_to_creation_date',l_to_creation_date);
   END IF;
   --

   IF p_transaction_id is not null THEN
      OPEN C_Get_One_Transactions;
   ELSE
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
      l_transaction_query := l_transaction_query || '  FROM   Wsh_Transactions_History wth, ';
      l_transaction_query := l_transaction_query || '         Wsh_New_Del_Interface    wndi ';
      l_transaction_query := l_transaction_query || '  WHERE  wth.document_type = ''SA'' ';
      l_transaction_query := l_transaction_query || '  AND    wth.document_direction = ''I'' ';

      IF p_from_document_number is not null and p_to_document_number is not null
      THEN
         l_transaction_query := l_transaction_query || '  AND    wth.document_number between :x_from_document_number ';
         l_transaction_query := l_transaction_query || '  and :x_to_document_number ';
      ELSIF p_from_document_number is not null and p_to_document_number is null
      THEN
         l_transaction_query := l_transaction_query || '  AND    wth.document_number >= :x_from_document_number ';
      ELSIF p_from_document_number is null and p_to_document_number is not null
      THEN
         l_transaction_query := l_transaction_query || '  AND    wth.document_number <= :x_from_document_number ';
      END IF;

      IF p_transaction_status is not null
      THEN
         l_transaction_query := l_transaction_query || '  AND    wth.transaction_status = :x_transaction_status ';
      ELSE
         l_transaction_query := l_transaction_query || '  AND    wth.transaction_status in (''AP'', ''ER'') ';
      END IF;

      IF l_from_creation_date is not null and l_to_creation_date is not null
      THEN
         l_transaction_query := l_transaction_query || '  AND    wth.creation_date between :x_from_creation_date ';
         l_transaction_query := l_transaction_query || '  and :x_to_creation_date ';
      ELSIF l_from_creation_date is not null and l_to_creation_date is null
      THEN
         l_transaction_query := l_transaction_query || '  AND    wth.creation_date >= :x_from_creation_date ';
      ELSIF l_from_creation_date is null and l_to_creation_date is not null
      THEN
         l_transaction_query := l_transaction_query || '  AND    wth.creation_date <= :x_to_creation_date ';
      END IF;

      l_transaction_query := l_transaction_query || ' AND   wndi.interface_action_code = ''' || g_interface_action_code || '''';
      l_transaction_query := l_transaction_query || ' AND   wndi.delivery_interface_id = to_number(wth.entity_number) ';
      l_transaction_query := l_transaction_query || ' ORDER BY wth.transaction_id ';

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
      DBMS_SQL.Define_Column(v_cursorid, 16, l_transaction_rec.Attribute_Category, 150);
      DBMS_SQL.Define_Column(v_cursorid, 17, l_transaction_rec.Attribute1, 150);
      DBMS_SQL.Define_Column(v_cursorid, 18, l_transaction_rec.Attribute2, 150);
      DBMS_SQL.Define_Column(v_cursorid, 19, l_transaction_rec.Attribute3, 150);
      DBMS_SQL.Define_Column(v_cursorid, 20, l_transaction_rec.Attribute4, 150);
      DBMS_SQL.Define_Column(v_cursorid, 21, l_transaction_rec.Attribute5, 150);
      DBMS_SQL.Define_Column(v_cursorid, 22, l_transaction_rec.Attribute6, 150);
      DBMS_SQL.Define_Column(v_cursorid, 23, l_transaction_rec.Attribute7, 150);
      DBMS_SQL.Define_Column(v_cursorid, 24, l_transaction_rec.Attribute8, 150);
      DBMS_SQL.Define_Column(v_cursorid, 25, l_transaction_rec.Attribute9, 150);
      DBMS_SQL.Define_Column(v_cursorid, 26, l_transaction_rec.Attribute10, 150);
      DBMS_SQL.Define_Column(v_cursorid, 27, l_transaction_rec.Attribute11, 150);
      DBMS_SQL.Define_Column(v_cursorid, 28, l_transaction_rec.Attribute12, 150);
      DBMS_SQL.Define_Column(v_cursorid, 29, l_transaction_rec.Attribute13, 150);
      DBMS_SQL.Define_Column(v_cursorid, 30, l_transaction_rec.Attribute14, 150);
      DBMS_SQL.Define_Column(v_cursorid, 31, l_transaction_rec.Attribute15, 150);
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
         DBMS_SQL.Column_Value(v_cursorid, 16, l_transaction_rec.Attribute_Category);
         DBMS_SQL.Column_Value(v_cursorid, 17, l_transaction_rec.Attribute1);
         DBMS_SQL.Column_Value(v_cursorid, 18, l_transaction_rec.Attribute2);
         DBMS_SQL.Column_Value(v_cursorid, 19, l_transaction_rec.Attribute3);
         DBMS_SQL.Column_Value(v_cursorid, 20, l_transaction_rec.Attribute4);
         DBMS_SQL.Column_Value(v_cursorid, 21, l_transaction_rec.Attribute5);
         DBMS_SQL.Column_Value(v_cursorid, 22, l_transaction_rec.Attribute6);
         DBMS_SQL.Column_Value(v_cursorid, 23, l_transaction_rec.Attribute7);
         DBMS_SQL.Column_Value(v_cursorid, 24, l_transaction_rec.Attribute8);
         DBMS_SQL.Column_Value(v_cursorid, 25, l_transaction_rec.Attribute9);
         DBMS_SQL.Column_Value(v_cursorid, 26, l_transaction_rec.Attribute10);
         DBMS_SQL.Column_Value(v_cursorid, 27, l_transaction_rec.Attribute11);
         DBMS_SQL.Column_Value(v_cursorid, 28, l_transaction_rec.Attribute12);
         DBMS_SQL.Column_Value(v_cursorid, 29, l_transaction_rec.Attribute13);
         DBMS_SQL.Column_Value(v_cursorid, 30, l_transaction_rec.Attribute14);
         DBMS_SQL.Column_Value(v_cursorid, 31, l_transaction_rec.Attribute15);
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Fetched from cursor successfully');
         END IF;
         --
      END IF;

      l_tmp_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      l_total := l_total + 1;

      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Calling WSH_PROCESS_INTERFACED_PKG.Process_Inbound', WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      WSH_PROCESS_INTERFACED_PKG.Process_Inbound(
               l_trns_history_rec => l_transaction_rec,
               x_return_status    => l_tmp_status );

      --
      IF l_debug_on THEN
         wsh_debug_sv.log(l_module_name,'Return status from WSH_PROCESS_INTERFACED_PKG.Process_Inbound', l_tmp_status);
      END IF;
      --

      -- API Process_Shipment_Advice will return WARNING if its not able to lock tables.
      IF l_tmp_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         l_success := l_success + 1;
      ELSIF l_tmp_status = WSH_UTIL_CORE.G_RET_STS_ERROR
      THEN
         l_errors := l_errors + 1;
      ELSIF l_tmp_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
      THEN
         --
         IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'Unexpected error occurred in Process_Shipment_Advice', l_tmp_status);
         END IF;
         --
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
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

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'Return Status from Process_Shipment_Advice', x_return_status);
      WSH_DEBUG_SV.logmsg(l_module_name,'');
      WSH_DEBUG_SV.logmsg(l_module_name,'Summary:-');
      WSH_DEBUG_SV.logmsg(l_module_name,'===================================');
      WSH_DEBUG_SV.log(l_module_name,'No. of Shipment Advices selected for processing  ', l_total);
      WSH_DEBUG_SV.log(l_module_name,'No. of Shipment Advices processed successfully   ', l_success);
      WSH_DEBUG_SV.log(l_module_name,'No. of Shipment Advices errored during processing', l_errors);
      WSH_DEBUG_SV.pop(l_module_name);
   -- To Print in Concurrent Request Output File
   ELSIF FND_GLOBAL.Conc_Request_Id > 0 THEN
      FND_FILE.put_line(FND_FILE.output, 'Summary:-');
      FND_FILE.put_line(FND_FILE.output,'===================================');
      FND_FILE.put_line(FND_FILE.output, 'No. of Shipment Advices selected for processing   => ' || l_total);
      FND_FILE.put_line(FND_FILE.output, 'No. of Shipment Advices processed successfully    => ' || l_success);
      FND_FILE.put_line(FND_FILE.output, 'No. of Shipment Advices errored during processing => ' || l_errors);
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

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
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
         wsh_debug_sv.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         wsh_debug_sv.pop(l_module_name, 'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
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
END Process_Shipment_Advice;

END WSH_SHIPMENT_ADVICE_PKG;

/
