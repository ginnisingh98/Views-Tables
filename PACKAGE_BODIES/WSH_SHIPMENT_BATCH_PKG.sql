--------------------------------------------------------
--  DDL for Package Body WSH_SHIPMENT_BATCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_SHIPMENT_BATCH_PKG" AS
/* $Header: WSHSBPKB.pls 120.0.12010000.1 2010/02/25 17:10:47 sankarun noship $ */

   G_PKG_NAME      CONSTANT VARCHAR2(30) := 'WSH_SHIPMENT_BATCH_PKG';

--FORWARD Declaration

--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Create_Shipment_Batch
--
-- PARAMETERS:
--       errbuf                 => Message returned to Concurrent Manager
--       retcode                => Code (0, 1, 2) returned to Concurrent Manager
--       p_organization_id      => Orgnaization
--       p_customer_id          => Consignee/Customer
--       p_ship_to_location_id  => Ship To Location
--       p_transaction_type_id  => Sales Order Type
--       p_from_order_number    => From Order Number
--       p_to_order_number      => To Order Number
--       p_from_request_date    => From Request Date
--       p_to_request_date      => To Request Date
--       p_from_schedule_date   => From Schedule Date
--       p_to_schedule_date     => To Schedule Date
--       p_shipment_priority    => Shipment Priority
--       p_include_internal_so  => Incude Internal Sales Order
--       p_log_level            => Either 1(Debug), 0(No Debug)
--
-- COMMENT:
--       API will be invoked from Concurrent Manager whenever concurrent program
--       'Create Shipment Batches' is triggered.
--       Wrapper for 'Crete Shipment Batch' API
--=============================================================================
--
PROCEDURE Create_Shipment_Batch (
          errbuf                 OUT NOCOPY   VARCHAR2,
          retcode                OUT NOCOPY   NUMBER,
          p_organization_id      IN  NUMBER,
          p_customer_id          IN  NUMBER,
          p_ship_to_location_id  IN  NUMBER,
          p_transaction_type_id  IN  NUMBER,
          p_from_order_number    IN  VARCHAR2,
          p_to_order_number      IN  VARCHAR2,
          p_from_request_date    IN  VARCHAR2,
          p_to_request_date      IN  VARCHAR2,
          p_from_schedule_date   IN  VARCHAR2,
          p_to_schedule_date     IN  VARCHAR2,
          p_shipment_priority    IN  VARCHAR,
          p_include_internal_so  IN  VARCHAR,
          p_log_level            IN  NUMBER )
IS
   l_completion_status          VARCHAR2(30);
   l_return_status              VARCHAR2(1);

   l_debug_on                 BOOLEAN;
   l_module_name CONSTANT     VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Create_Shipment_Batch1';
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
      wsh_debug_sv.log(l_module_name, 'p_organization_id', p_organization_id);
      wsh_debug_sv.log(l_module_name, 'p_customer_id', p_customer_id);
      wsh_debug_sv.log(l_module_name, 'p_ship_to_location_id', p_ship_to_location_id);
      wsh_debug_sv.log(l_module_name, 'p_transaction_type_id', p_transaction_type_id);
      wsh_debug_sv.log(l_module_name, 'p_from_order_number', p_from_order_number);
      wsh_debug_sv.log(l_module_name, 'p_to_order_number', p_to_order_number);
      wsh_debug_sv.log(l_module_name, 'p_from_request_date', p_from_request_date);
      wsh_debug_sv.log(l_module_name, 'p_to_request_date', p_to_request_date);
      wsh_debug_sv.log(l_module_name, 'p_from_schedule_date', p_from_schedule_date);
      wsh_debug_sv.log(l_module_name, 'p_to_schedule_date', p_to_schedule_date);
      wsh_debug_sv.log(l_module_name, 'p_shipment_priority', p_shipment_priority);
      WSH_DEBUG_SV.log(l_module_name, 'p_include_internal_so', p_include_internal_so);
      wsh_debug_sv.log(l_module_name, 'p_log_level', p_log_level);
   END IF;
   --

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'Calling Create_Shipment_Batch', WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --

   Create_Shipment_Batch (
             p_organization_id      => p_organization_id,
             p_customer_id          => p_customer_id,
             p_ship_to_location_id  => p_ship_to_location_id,
             p_transaction_type_id  => p_transaction_type_id,
             p_from_order_number    => p_from_order_number,
             p_to_order_number      => p_to_order_number,
             p_from_request_date    => p_from_request_date,
             p_to_request_date      => p_to_request_date,
             p_from_schedule_date   => p_from_schedule_date,
             p_to_schedule_date     => p_to_schedule_date,
             p_shipment_priority    => p_shipment_priority,
             p_include_internal_so => p_include_internal_so,
             x_return_status        => l_return_status );

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'Return Status of Create_Shipment_Batch', l_return_status);
   END IF;
   --

   IF l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      l_completion_status := 'SUCCESS';
      errbuf := 'Create Shipment Batches Program has completed successfully';
      retcode := '0';
   ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
      l_completion_status := 'WARNING';
      errbuf := 'Create Shipment Batches Program has completed with warning';
      retcode := '1';
   ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
      l_completion_status := 'ERROR';
      errbuf := 'Create Shipment Batches Program has completed with error';
      retcode := '2';
   ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
      l_completion_status := 'UNEXPECTED ERROR';
      errbuf := 'Create Shipment Batches Program has completed with unexpected error';
      retcode := '2';
   END IF;

   IF l_return_status in ( WSH_UTIL_CORE.G_RET_STS_SUCCESS, WSH_UTIL_CORE.G_RET_STS_WARNING )
   THEN
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Commiting the transaction......');
      END IF;
      --
      COMMIT;
   ELSE
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Rolling back the transaction......');
      END IF;
      --
      ROLLBACK;
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
      errbuf := 'Create Shipment Batches Program is completed with unexpected error - ' || SQLCODE;
      retcode := '2';
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Create_Shipment_Batch;
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Create_Shipment_Batch
--
-- PARAMETERS:
--       p_organization_id      => Orgnaization
--       p_customer_id          => Consignee/Customer
--       p_ship_to_location_id  => Ship To Location
--       p_transaction_type_id  => Sales Order Type
--       p_from_order_number    => From Order Number
--       p_to_order_number      => To Order Number
--       p_from_request_date    => From Request Date
--       p_to_request_date      => To Request Date
--       p_from_schedule_date   => From Schedule Date
--       p_to_schedule_date     => To Schedule Date
--       p_shipment_priority    => Shipment Priority
--       p_include_internal_so  => Incude Internal Sales Order
--       x_return_status        => Return Status of API (S,W,E,U)
--
-- COMMENT:
--       Based on input parameter values, eligble records from WDD are fetced.
--       Records fetched are grouped into Shipment Batches based on grouping
--       criteria returned from WSH_CUSTOM_PUB.Shipment_Batch_Group_Criteria
--       Custom API. A record is inserted into Wsh_Shipment_Batches table for
--       each shipment Batch and corresponding batch name is stamped in WDD.
--
--       Mandatory grouping criteria for Shipment Batch is
--          a) Customer
--          b) Ship To Site
--          c) Organization
--          d) Org (Operating Unit)
--          e) Currency Code
--       Optional grouping criteria for Shipment Batch is
--          a) Invoice To Location
--          b) Deliver To Location
--          c) Ship To Contact
--          d) Invoice To Contact
--          e) Deliver To Contact
--          f) Ship Method
--          g) Freight Terms
--          h) FOB
--          i) Within/Across Orders
--=============================================================================
--
PROCEDURE Create_Shipment_Batch (
          p_organization_id      IN  NUMBER,
          p_customer_id          IN  NUMBER,
          p_ship_to_location_id  IN  NUMBER,
          p_transaction_type_id  IN  NUMBER,
          p_from_order_number    IN  VARCHAR2,
          p_to_order_number      IN  VARCHAR2,
          p_from_request_date    IN  VARCHAR2,
          p_to_request_date      IN  VARCHAR2,
          p_from_schedule_date   IN  VARCHAR2,
          p_to_schedule_date     IN  VARCHAR2,
          p_shipment_priority    IN  VARCHAR,
          p_include_internal_so  IN  VARCHAR,
          x_return_status        OUT NOCOPY VARCHAR2 )
IS

   l_total                      NUMBER := 0;
   l_success                    NUMBER := 0;
   l_errors                     NUMBER := 0;
   l_batch_id                   NUMBER;
   l_prev_group_id              NUMBER;
   l_cnt                        NUMBER;
   l_bulk_count                 NUMBER := 1000;
   l_line_number                NUMBER;
   l_dummy                      NUMBER;

   l_from_request_date          DATE;
   l_to_request_date            DATE;
   l_from_schedule_date         DATE;
   l_to_schedule_date           DATE;

   v_cursorid                   INTEGER;
   v_ignore                     INTEGER;

   l_dyn_query                  VARCHAR2(15000);
   l_order_query                VARCHAR2(1000);
   l_grp_query                  VARCHAR2(2000);
   l_dense_select               VARCHAR2(2000);
   l_wh_type                    VARCHAR2(30);
   l_return_status              VARCHAR2(1);
   l_grp_by_inv_site            VARCHAR2(1);
   l_grp_by_del_site            VARCHAR2(1);
   l_grp_by_ship_contact        VARCHAR2(1);
   l_grp_by_inv_contact         VARCHAR2(1);
   l_grp_by_del_contact         VARCHAR2(1);
   l_grp_by_ship_method         VARCHAR2(1);
   l_grp_by_freight_terms       VARCHAR2(1);
   l_grp_by_fob_code            VARCHAR2(1);
   l_grp_by_within_order        VARCHAR2(1);

   l_rowid_tbl                  DBMS_SQL.URowid_Table;
   l_del_detail_tbl             DBMS_SQL.Number_Table;
   l_src_line_id_tbl            DBMS_SQL.Number_Table;
   l_org_id_tbl                 DBMS_SQL.Number_Table;
   l_customer_id_tbl            DBMS_SQL.Number_Table;
   l_organization_id_tbl        DBMS_SQL.Number_Table;
   l_ship_from_loc_tbl          DBMS_SQL.Number_Table;
   l_ship_to_site_tbl           DBMS_SQL.Number_Table;
   l_invoice_to_site_tbl        DBMS_SQL.Number_Table;
   l_deliver_to_site_tbl        DBMS_SQL.Number_Table;
   l_ship_to_con_tbl            DBMS_SQL.Number_Table;
   l_invoice_to_con_tbl         DBMS_SQL.Number_Table;
   l_deliver_to_con_tbl         DBMS_SQL.Number_Table;
   l_curr_code_tbl              DBMS_SQL.Varchar2_Table;
   l_ship_method_tbl            DBMS_SQL.Varchar2_Table;
   l_freight_terms_tbl          DBMS_SQL.Varchar2_Table;
   l_fob_code_tbl               DBMS_SQL.Varchar2_Table;
   l_group_id_tbl               DBMS_SQL.Number_Table;

   l_shipment_batch_tbl         Shipment_Batch_Tbl;
   l_dd_batch_id_tbl            WSH_UTIL_CORE.Id_Tab_Type;
   l_dd_line_num_tbl            WSH_UTIL_CORE.Id_Tab_Type;
   l_wdd_update_flag            WSH_UTIL_CORE.Column_Tab_Type;
   l_batch_tbl                  WSH_UTIL_CORE.Id_Tab_Type;

   RECORD_LOCKED                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RECORD_LOCKED, -54);

   l_debug_on                 BOOLEAN;
   l_module_name CONSTANT     VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Create_Shipment_Batch';
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
      wsh_debug_sv.log(l_module_name, 'p_organization_id', p_organization_id);
      wsh_debug_sv.log(l_module_name, 'p_customer_id', p_customer_id);
      wsh_debug_sv.log(l_module_name, 'p_ship_to_location_id', p_ship_to_location_id);
      wsh_debug_sv.log(l_module_name, 'p_transaction_type_id', p_transaction_type_id);
      wsh_debug_sv.log(l_module_name, 'p_from_order_number', p_from_order_number);
      wsh_debug_sv.log(l_module_name, 'p_to_order_number', p_to_order_number);
      wsh_debug_sv.log(l_module_name, 'p_from_request_date', p_from_request_date);
      wsh_debug_sv.log(l_module_name, 'p_to_request_date', p_to_request_date);
      wsh_debug_sv.log(l_module_name, 'p_from_schedule_date', p_from_schedule_date);
      wsh_debug_sv.log(l_module_name, 'p_to_schedule_date', p_to_schedule_date);
      wsh_debug_sv.log(l_module_name, 'p_shipment_priority', p_shipment_priority);
      WSH_DEBUG_SV.log(l_module_name, 'p_include_internal_so', p_include_internal_so);
   END IF;
   --

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   /*
   --Check If organization is TW2 Enabled
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'Calling WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type', WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   l_wh_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type(
                             p_organization_id  => p_organization_id,
                             x_return_status    => l_return_status );
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'l_wh_type,l_return_status',l_wh_type||','||l_return_status);
   END IF;
   --

   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Error: WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type returned error');
      END IF;
      --
      x_return_status := l_return_status;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF nvl(l_wh_type, FND_API.G_MISS_CHAR) <> 'TW2' THEN
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Error: Organization is not TW2 Enabled');
      END IF;
      --
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   */

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'Calling WSH_CUSTOM_PUB.Shipment_Batch_Group_Criteria', WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   WSH_CUSTOM_PUB.Shipment_Batch_Group_Criteria(
              x_grp_by_invoice_to_site     => l_grp_by_inv_site,
              x_grp_by_deliver_to_site     => l_grp_by_del_site,
              x_grp_by_ship_to_contact     => l_grp_by_ship_contact,
              x_grp_by_invoice_to_contact  => l_grp_by_inv_contact,
              x_grp_by_deliver_to_contact  => l_grp_by_del_contact,
              x_grp_by_ship_method         => l_grp_by_ship_method,
              x_grp_by_freight_terms       => l_grp_by_freight_terms,
              x_grp_by_fob_code            => l_grp_by_fob_code,
              x_grp_by_within_order        => l_grp_by_within_order );

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_grp_by_invoice_to_site    ', l_grp_by_inv_site     );
      WSH_DEBUG_SV.log(l_module_name,'l_grp_by_deliver_to_site    ', l_grp_by_del_site     );
      WSH_DEBUG_SV.log(l_module_name,'l_grp_by_ship_to_contact    ', l_grp_by_ship_contact );
      WSH_DEBUG_SV.log(l_module_name,'l_grp_by_invoice_to_contact ', l_grp_by_inv_contact  );
      WSH_DEBUG_SV.log(l_module_name,'l_grp_by_deliver_to_contact ', l_grp_by_del_contact  );
      WSH_DEBUG_SV.log(l_module_name,'l_grp_by_ship_method        ', l_grp_by_ship_method  );
      WSH_DEBUG_SV.log(l_module_name,'l_grp_by_freight_terms      ', l_grp_by_freight_terms);
      WSH_DEBUG_SV.log(l_module_name,'l_grp_by_fob_code           ', l_grp_by_fob_code     );
      WSH_DEBUG_SV.log(l_module_name,'l_grp_by_within_order       ', l_grp_by_within_order );
   END IF;
   --

   l_from_request_date    := to_date(p_from_request_date,'YYYY/MM/DD HH24:MI:SS');
   l_to_request_date      := to_date(p_to_request_date,'YYYY/MM/DD HH24:MI:SS');
   l_from_schedule_date   := to_date(p_from_schedule_date,'YYYY/MM/DD HH24:MI:SS');
   l_to_schedule_date     := to_date(p_to_schedule_date,'YYYY/MM/DD HH24:MI:SS');

   l_order_query := ' select to_char(order_number) from oe_order_headers_all where order_number ';

   -- SELECT CLAUSE
   l_dyn_query := 'SELECT wdd.rowid, ';
   l_dyn_query := l_dyn_query || ' wdd.delivery_detail_id, ';
   l_dyn_query := l_dyn_query || ' wdd.source_line_id, ';
   l_dyn_query := l_dyn_query || ' wdd.org_id, ';
   l_dyn_query := l_dyn_query || ' wdd.currency_code, ';
   l_dyn_query := l_dyn_query || ' wdd.customer_id, ';
   l_dyn_query := l_dyn_query || ' wdd.organization_id, ';
   l_dyn_query := l_dyn_query || ' wdd.ship_from_location_id, ';
   l_dyn_query := l_dyn_query || ' wdd.ship_to_site_use_id, ';
   l_dyn_query := l_dyn_query || ' oel.invoice_to_org_id, ';
   l_dyn_query := l_dyn_query || ' wdd.deliver_to_site_use_id, ';
   l_dyn_query := l_dyn_query || ' wdd.ship_to_contact_id, ';
   l_dyn_query := l_dyn_query || ' oel.invoice_to_contact_id, ';
   l_dyn_query := l_dyn_query || ' wdd.deliver_to_contact_id, ';
   l_dyn_query := l_dyn_query || ' wdd.ship_method_code, ';
   l_dyn_query := l_dyn_query || ' wdd.freight_terms_code, ';
   l_dyn_query := l_dyn_query || ' wdd.fob_code, ';

   -- Mandatory Grouping Criteria
   l_grp_query := '   wdd.customer_id ';
   l_grp_query := l_grp_query || ' , wdd.organization_id ';
   l_grp_query := l_grp_query || ' , wdd.ship_to_site_use_id ';
   l_grp_query := l_grp_query || ' , wdd.org_id ';
   l_grp_query := l_grp_query || ' , wdd.currency_code ';

   IF nvl(l_grp_by_inv_site, 'Y') = 'Y' THEN
      l_grp_query := l_grp_query || ' , oel.invoice_to_org_id ';
   END IF;

   IF nvl(l_grp_by_del_site, 'Y') = 'Y' THEN
      l_grp_query := l_grp_query || ' , wdd.deliver_to_site_use_id ';
   END IF;

   IF nvl(l_grp_by_ship_contact, 'Y') = 'Y' THEN
      l_grp_query := l_grp_query || ' , wdd.ship_to_contact_id ';
   END IF;

   IF nvl(l_grp_by_inv_contact, 'Y') = 'Y' THEN
      l_grp_query := l_grp_query || ' , oel.invoice_to_contact_id ';
   END IF;

   IF nvl(l_grp_by_del_contact, 'Y') = 'Y' THEN
      l_grp_query := l_grp_query || ' , wdd.deliver_to_contact_id ';
   END IF;

   IF nvl(l_grp_by_ship_method, 'Y') = 'Y' THEN
      l_grp_query := l_grp_query || ' , wdd.ship_method_code ';
   END IF;

   IF nvl(l_grp_by_freight_terms, 'Y') = 'Y' THEN
      l_grp_query := l_grp_query || ' , wdd.freight_terms_code ';
   END IF;

   IF nvl(l_grp_by_fob_code, 'Y') = 'Y' THEN
      l_grp_query := l_grp_query || ' , wdd.fob_code ';
   END IF;

   IF nvl(l_grp_by_within_order, 'Y') = 'Y' THEN
      l_grp_query := l_grp_query || ' , wdd.source_header_id ';
   END IF;

   -- Generating Group Id Using Analytic Function
   l_dyn_query := l_dyn_query || ' DENSE_RANK() OVER (ORDER BY ';

   --Append Grouping Criteria to DENSE_RANK Analytic Function
   l_dyn_query := l_dyn_query || l_grp_query;
   l_dyn_query := l_dyn_query || ' ) Group_Id ';

   -- From Clause
   l_dyn_query := l_dyn_query || ' FROM Wsh_Delivery_Details     wdd, ';
   l_dyn_query := l_dyn_query || '      Wsh_Delivery_Assignments wda, ';
   l_dyn_query := l_dyn_query || '      Oe_Order_Lines_All       oel  ';

   -- Where Clause
   l_dyn_query := l_dyn_query || ' WHERE oel.line_id = wdd.source_line_id ';
   -- To make sure delivery details are not assigned to delivery
   l_dyn_query := l_dyn_query || ' AND   wda.delivery_id is null';
   l_dyn_query := l_dyn_query || ' AND   wda.delivery_detail_id = wdd.delivery_detail_id';
   l_dyn_query := l_dyn_query || ' AND   wdd.source_code = ''OE''';
   l_dyn_query := l_dyn_query || ' AND   wdd.released_status in ( ''R'', ''B'', ''X'' )';
   l_dyn_query := l_dyn_query || ' AND   wdd.shipment_batch_id is null';

   -- { Dynamic Where Clause Starts Here
   IF p_include_internal_so = 'Y' THEN
      l_dyn_query := l_dyn_query || ' AND wdd.line_direction in ( ''IO'', ''O'' ) ';
   ELSE
      l_dyn_query := l_dyn_query || ' AND wdd.line_direction in ( ''O'' ) ';
   END IF;

   IF p_organization_id is not null THEN
      l_dyn_query := l_dyn_query || ' AND wdd.organization_id = :x_organization_id ';
   END IF;

   IF p_customer_id is not null THEN
      l_dyn_query := l_dyn_query || ' AND wdd.customer_id = :x_customer_id ';
   END IF;

   IF p_ship_to_location_id is not null THEN
      l_dyn_query := l_dyn_query || ' AND wdd.ship_to_location_id = :x_ship_to_location_id ';
   END IF;

   IF p_transaction_type_id is not null THEN
      l_dyn_query := l_dyn_query || ' AND wdd.source_header_type_id = :x_transaction_type_id ';
   END IF;

   IF p_from_order_number is not null and p_to_order_number is not null
   THEN
      l_dyn_query := l_dyn_query || '  AND wdd.source_header_number in ( ' || l_order_query || ' between :x_from_order_number ';
      l_dyn_query := l_dyn_query || '           AND :x_to_order_number )';
   ELSIF p_from_order_number is not null and p_to_order_number is null
   THEN
      l_dyn_query := l_dyn_query || '  AND wdd.source_header_number in ( ' || l_order_query || ' >= :x_from_order_number ) ';
   ELSIF p_from_order_number is null and p_to_order_number is not null
   THEN
      l_dyn_query := l_dyn_query || '  AND wdd.source_header_number in ( ' || l_order_query || ' <= :x_to_order_number ) ';
   END IF;

   IF l_from_request_date is not null and l_to_request_date is not null
   THEN
      l_dyn_query := l_dyn_query || '  AND    wdd.date_requested between :x_from_request_date ';
      l_dyn_query := l_dyn_query || '         and :x_to_request_date ';
   ELSIF l_from_request_date is not null and l_to_request_date is null
   THEN
      l_dyn_query := l_dyn_query || '  AND    wdd.date_requested >= :x_from_request_date ';
   ELSIF l_from_request_date is null and l_to_request_date is not null
   THEN
      l_dyn_query := l_dyn_query || '  AND    wdd.date_requested <= :x_to_request_date ';
   END IF;

   IF l_from_schedule_date is not null and l_to_schedule_date is not null
   THEN
      l_dyn_query := l_dyn_query || '  AND    wdd.date_scheduled between :x_from_schedule_date ';
      l_dyn_query := l_dyn_query || '         and :x_to_schedule_date ';
   ELSIF l_from_schedule_date is not null and l_to_schedule_date is null
   THEN
      l_dyn_query := l_dyn_query || '  AND    wdd.date_scheduled >= :x_from_schedule_date ';
   ELSIF l_from_schedule_date is null and l_to_schedule_date is not null
   THEN
      l_dyn_query := l_dyn_query || '  AND    wdd.date_scheduled <= :x_to_schedule_date ';
   END IF;

   IF p_shipment_priority is not null THEN
      l_dyn_query := l_dyn_query || ' AND wdd.shipment_priority_code = :x_shipment_priority ';
   END IF;
   -- } Dynamic Where Clause Ends Here

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'Transaction Query', l_dyn_query);
   END IF;
   --

   v_cursorid := DBMS_SQL.Open_Cursor;
   DBMS_SQL.Parse(v_cursorid, l_dyn_query, DBMS_SQL.v7 );
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'Opened and Pasred cursor successfully', v_cursorid);
   END IF;
   --
   --Using Define_Array to fetch in BULK based on l_bulk_count.
   --Index of PL/SQL table will start from 1.
   DBMS_SQL.Define_Array(v_cursorid,  1, l_rowid_tbl           , l_bulk_count, 1);
   DBMS_SQL.Define_Array(v_cursorid,  2, l_del_detail_tbl      , l_bulk_count, 1);
   DBMS_SQL.Define_Array(v_cursorid,  3, l_src_line_id_tbl     , l_bulk_count, 1);
   DBMS_SQL.Define_Array(v_cursorid,  4, l_org_id_tbl          , l_bulk_count, 1);
   DBMS_SQL.Define_Array(v_cursorid,  5, l_curr_code_tbl       , l_bulk_count, 1);
   DBMS_SQL.Define_Array(v_cursorid,  6, l_customer_id_tbl     , l_bulk_count, 1);
   DBMS_SQL.Define_Array(v_cursorid,  7, l_organization_id_tbl , l_bulk_count, 1);
   DBMS_SQL.Define_Array(v_cursorid,  8, l_ship_from_loc_tbl   , l_bulk_count, 1);
   DBMS_SQL.Define_Array(v_cursorid,  9, l_ship_to_site_tbl    , l_bulk_count, 1);
   DBMS_SQL.Define_Array(v_cursorid, 10, l_invoice_to_site_tbl , l_bulk_count, 1);
   DBMS_SQL.Define_Array(v_cursorid, 11, l_deliver_to_site_tbl , l_bulk_count, 1);
   DBMS_SQL.Define_Array(v_cursorid, 12, l_ship_to_con_tbl     , l_bulk_count, 1);
   DBMS_SQL.Define_Array(v_cursorid, 13, l_invoice_to_con_tbl  , l_bulk_count, 1);
   DBMS_SQL.Define_Array(v_cursorid, 14, l_deliver_to_con_tbl  , l_bulk_count, 1);
   DBMS_SQL.Define_Array(v_cursorid, 15, l_ship_method_tbl     , l_bulk_count, 1);
   DBMS_SQL.Define_Array(v_cursorid, 16, l_freight_terms_tbl   , l_bulk_count, 1);
   DBMS_SQL.Define_Array(v_cursorid, 17, l_fob_code_tbl        , l_bulk_count, 1);
   DBMS_SQL.Define_Array(v_cursorid, 18, l_group_id_tbl        , l_bulk_count, 1);

   --Assigning Bind Values
   -- { Binding Starts Here
   IF p_organization_id is not null THEN
      DBMS_SQL.BIND_VARIABLE(v_cursorid, ':x_organization_id', p_organization_id);
   END IF;

   IF p_customer_id is not null THEN
      DBMS_SQL.BIND_VARIABLE(v_cursorid, ':x_customer_id', p_customer_id);
   END IF;

   IF p_ship_to_location_id is not null THEN
      DBMS_SQL.BIND_VARIABLE(v_cursorid, ':x_ship_to_location_id', p_ship_to_location_id);
   END IF;

   IF p_transaction_type_id is not null THEN
      DBMS_SQL.BIND_VARIABLE(v_cursorid, ':x_transaction_type_id', p_transaction_type_id);
   END IF;

   IF p_from_order_number is not null and p_to_order_number is not null
   THEN
      DBMS_SQL.BIND_VARIABLE(v_cursorid, ':x_from_order_number', p_from_order_number);
      DBMS_SQL.BIND_VARIABLE(v_cursorid, ':x_to_order_number', p_to_order_number);
   ELSIF p_from_order_number is not null and p_to_order_number is null
   THEN
      DBMS_SQL.BIND_VARIABLE(v_cursorid, ':x_from_order_number', p_from_order_number);
   ELSIF p_from_order_number is null and p_to_order_number is not null
   THEN
      DBMS_SQL.BIND_VARIABLE(v_cursorid, ':x_to_order_number', p_to_order_number);
   END IF;

   IF l_from_request_date is not null and l_to_request_date is not null
   THEN
      DBMS_SQL.BIND_VARIABLE(v_cursorid, ':x_from_request_date', l_from_request_date);
      DBMS_SQL.BIND_VARIABLE(v_cursorid, ':x_to_request_date', l_to_request_date);
   ELSIF l_from_request_date is not null and l_to_request_date is null
   THEN
      DBMS_SQL.BIND_VARIABLE(v_cursorid, ':x_from_request_date', l_from_request_date);
   ELSIF l_from_request_date is null and l_to_request_date is not null
   THEN
      DBMS_SQL.BIND_VARIABLE(v_cursorid, ':x_to_request_date', l_to_request_date);
   END IF;

   IF l_from_schedule_date is not null and l_to_schedule_date is not null
   THEN
      DBMS_SQL.BIND_VARIABLE(v_cursorid, ':x_from_schedule_date', l_from_schedule_date);
      DBMS_SQL.BIND_VARIABLE(v_cursorid, ':x_to_schedule_date', l_to_schedule_date);
   ELSIF l_from_schedule_date is not null and l_to_schedule_date is null
   THEN
      DBMS_SQL.BIND_VARIABLE(v_cursorid, ':x_from_schedule_date', l_from_schedule_date);
   ELSIF l_from_schedule_date is null and l_to_schedule_date is not null
   THEN
      DBMS_SQL.BIND_VARIABLE(v_cursorid, ':x_to_schedule_date', l_to_schedule_date);
   END IF;

   IF p_shipment_priority is not null THEN
      DBMS_SQL.BIND_VARIABLE(v_cursorid, ':x_shipment_priority', p_shipment_priority);
   END IF;
   -- } Binding End Here


   -- A current index into each array is maintained automatically. This index is initialized
   -- to 1 at EXECUTE and keeps getting updated every time a COLUMN_VALUE call
   -- is made. If you reexecute at any point, then the current index for each DEFINE is
   -- re-initialized to 1.
   v_ignore := DBMS_SQL.Execute(v_cursorid);

   l_prev_group_id := 0;
   l_line_number   := 0;
   --{ Loop for fetching records - Starts
   LOOP
      -- Each time when FETCH_ROWS is called, it fetches l_bulk_count(1000) rows and
      -- are kept in DBMS_SQL buffers. When the COLUMN_VALUE call is run, those rows
      -- move into the PL/SQL table specified (in this case l_rowid_tbl..l_group_id_tbl), at positions 1 to l_bulk_count(1000),
      -- as specified in the DEFINE statements.
      -- When the second batch is fetched in the loop, the rows go to positions 1001 to 2000; and so on.
      v_ignore := DBMS_SQL.Fetch_Rows(v_cursorid);
      IF v_ignore = 0 THEN
         EXIT;
      END IF;

      DBMS_SQL.Column_Value(v_cursorid,  1, l_rowid_tbl           );
      DBMS_SQL.Column_Value(v_cursorid,  2, l_del_detail_tbl      );
      DBMS_SQL.Column_Value(v_cursorid,  3, l_src_line_id_tbl     );
      DBMS_SQL.Column_Value(v_cursorid,  4, l_org_id_tbl          );
      DBMS_SQL.Column_Value(v_cursorid,  5, l_curr_code_tbl       );
      DBMS_SQL.Column_Value(v_cursorid,  6, l_customer_id_tbl     );
      DBMS_SQL.Column_Value(v_cursorid,  7, l_organization_id_tbl );
      DBMS_SQL.Column_Value(v_cursorid,  8, l_ship_from_loc_tbl   );
      DBMS_SQL.Column_Value(v_cursorid,  9, l_ship_to_site_tbl    );
      DBMS_SQL.Column_Value(v_cursorid, 10, l_invoice_to_site_tbl );
      DBMS_SQL.Column_Value(v_cursorid, 11, l_deliver_to_site_tbl );
      DBMS_SQL.Column_Value(v_cursorid, 12, l_ship_to_con_tbl     );
      DBMS_SQL.Column_Value(v_cursorid, 13, l_invoice_to_con_tbl  );
      DBMS_SQL.Column_Value(v_cursorid, 14, l_deliver_to_con_tbl  );
      DBMS_SQL.Column_Value(v_cursorid, 15, l_ship_method_tbl     );
      DBMS_SQL.Column_Value(v_cursorid, 16, l_freight_terms_tbl   );
      DBMS_SQL.Column_Value(v_cursorid, 17, l_fob_code_tbl        );
      DBMS_SQL.Column_Value(v_cursorid, 18, l_group_id_tbl        );

      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'Fetched successfully', v_ignore);
         WSH_DEBUG_SV.log(l_module_name, 'Group Id Table Count', l_group_id_tbl.count);
         WSH_DEBUG_SV.log(l_module_name, 'Group Id for first delivery detail# ' || l_del_detail_tbl(l_del_detail_tbl.first), l_group_id_tbl(l_group_id_tbl.first) );
      END IF;
      --

      --{ Loop through records fetched - Starts
      FOR i IN l_group_id_tbl.FIRST..l_group_id_tbl.LAST
      LOOP
         --{ Locking Delivery Detail Starts
         BEGIN
            select delivery_detail_id
            into   l_dummy
            from   wsh_delivery_details
            where  rowid = l_rowid_tbl(i)
            for update nowait;

            --Delivery Detail can be assigned to batch.
            l_wdd_update_flag(i) := 'Y';

         EXCEPTION
         WHEN RECORD_LOCKED THEN
            x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
            --Delivery Detail cannot be assigned to batch.
            l_wdd_update_flag(i)  := 'N';
            l_dd_line_num_tbl(i) := 0;
            l_dd_batch_id_tbl(i) := 0;
            FND_MESSAGE.Set_Name('WSH', 'WSH_DLVB_LOCK_FAILED');
            FND_MESSAGE.Set_Token('ENTITY_NAME', l_del_detail_tbl(i));
            WSH_UTIL_CORE.Add_Message(x_return_status, l_module_name );
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'Warning: Not able to obtain lock, so skipping delivery detail', l_del_detail_tbl(i) );
            END IF;
            --
            goto skip_record;
         END;
         --} Locking Delivery Detail Ends

         --{ Seperating Batches Starts Here
         IF l_group_id_tbl(i) <> l_prev_group_id
         THEN
            l_prev_group_id := l_group_id_tbl(i);
            l_line_number   := 0;

            l_cnt := l_shipment_batch_tbl.count + 1;
            l_shipment_batch_tbl(l_cnt).customer_id           := l_customer_id_tbl(i);
            l_shipment_batch_tbl(l_cnt).organization_id       := l_organization_id_tbl(i);
            l_shipment_batch_tbl(l_cnt).ship_from_location_id := l_ship_from_loc_tbl(i);
            l_shipment_batch_tbl(l_cnt).org_id                := l_org_id_tbl(i);
            l_shipment_batch_tbl(l_cnt).currency_code         := l_curr_code_tbl(i);
            l_shipment_batch_tbl(l_cnt).ship_to_site_use_id   := l_ship_to_site_tbl(i);
            l_shipment_batch_tbl(l_cnt).group_id              := l_group_id_tbl(i);

            IF nvl(l_grp_by_inv_site, 'Y') = 'Y' THEN
               l_shipment_batch_tbl(l_cnt).invoice_to_site_use_id := l_invoice_to_site_tbl(i);
            END IF;

            IF nvl(l_grp_by_del_site, 'Y') = 'Y' THEN
               l_shipment_batch_tbl(l_cnt).deliver_to_site_use_id := l_deliver_to_site_tbl(i);
            END IF;

            IF nvl(l_grp_by_ship_contact, 'Y') = 'Y' THEN
               l_shipment_batch_tbl(l_cnt).ship_to_contact_id := l_ship_to_con_tbl(i);
            END IF;
            IF nvl(l_grp_by_inv_contact, 'Y') = 'Y' THEN
               l_shipment_batch_tbl(l_cnt).invoice_to_contact_id := l_invoice_to_con_tbl(i);
            END IF;

            IF nvl(l_grp_by_del_contact, 'Y') = 'Y' THEN
               l_shipment_batch_tbl(l_cnt).deliver_to_contact_id := l_deliver_to_con_tbl(i);
            END IF;

            IF nvl(l_grp_by_ship_method, 'Y') = 'Y' THEN
               l_shipment_batch_tbl(l_cnt).ship_method_code := l_ship_method_tbl(i);
            END IF;

            IF nvl(l_grp_by_freight_terms, 'Y') = 'Y' THEN
               l_shipment_batch_tbl(l_cnt).freight_terms_code := l_freight_terms_tbl(i);
            END IF;

            IF nvl(l_grp_by_fob_code, 'Y') = 'Y' THEN
               l_shipment_batch_tbl(l_cnt).fob_code := l_fob_code_tbl(i);
            END IF;

            SELECT Wsh_Shipment_Batches_S.nextval
            INTO   l_batch_id
            FROM   DUAL;

            --Stores batch id of batches created.
            l_batch_tbl(l_batch_tbl.count+1) := l_batch_id;

            INSERT INTO Wsh_Shipment_Batches (
                        batch_id,
                        name,
                        org_id,
                        currency_code,
                        customer_id,
                        organization_id,
                        ship_from_location_id,
                        ship_to_site_use_id,
                        invoice_to_site_use_id,
                        deliver_to_site_use_id,
                        ship_to_contact_id,
                        invoice_to_contact_id,
                        deliver_to_contact_id,
                        ship_method_code,
                        freight_terms_code,
                        fob_code,
                        pending_request_flag,
                        creation_date,
                        created_by,
                        last_update_date,
                        last_updated_by,
                        last_update_login,
                        request_id,
                        program_application_id,
                        program_id,
                        program_update_date )
            VALUES (
                        l_batch_id,
                        to_char(l_batch_id),
                        l_shipment_batch_tbl(l_cnt).org_id,
                        l_shipment_batch_tbl(l_cnt).currency_code,
                        l_shipment_batch_tbl(l_cnt).customer_id,
                        l_shipment_batch_tbl(l_cnt).organization_id,
                        l_shipment_batch_tbl(l_cnt).ship_from_location_id,
                        l_shipment_batch_tbl(l_cnt).ship_to_site_use_id,
                        l_shipment_batch_tbl(l_cnt).invoice_to_site_use_id,
                        l_shipment_batch_tbl(l_cnt).deliver_to_site_use_id,
                        l_shipment_batch_tbl(l_cnt).ship_to_contact_id,
                        l_shipment_batch_tbl(l_cnt).invoice_to_contact_id,
                        l_shipment_batch_tbl(l_cnt).deliver_to_contact_id,
                        l_shipment_batch_tbl(l_cnt).ship_method_code,
                        l_shipment_batch_tbl(l_cnt).freight_terms_code,
                        l_shipment_batch_tbl(l_cnt).fob_code,
                        'Y',
                        SYSDATE,
                        FND_GLOBAL.user_id,
                        SYSDATE,
                        FND_GLOBAL.user_id,
                        FND_GLOBAL.Login_Id,
                        FND_GLOBAL.Conc_Request_Id,
                        FND_GLOBAL.Prog_Appl_Id,
                        FND_GLOBAL.Conc_Program_Id,
                        SYSDATE );
         END IF;
         --} Seperating Batches Ends Here

         l_dd_batch_id_tbl(i) := l_batch_id;
         l_line_number        := l_line_number + 1;
         l_dd_line_num_tbl(i) := l_line_number;

         <<skip_record>>
            null;
      END LOOP;
      --} Loop through records fetched - Ends

      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'Group Id for last delivery detail# ' || l_del_detail_tbl(l_del_detail_tbl.last), l_group_id_tbl(l_group_id_tbl.last) );
         WSH_DEBUG_SV.log(l_module_name, 'No. of lines fetched',   l_del_detail_tbl.count);
         WSH_DEBUG_SV.log(l_module_name, 'No. of batches created', l_shipment_batch_tbl.count);
      END IF;
      --

      FORALL i in l_rowid_tbl.first..l_rowid_tbl.last
         update wsh_delivery_details
         set    shipment_batch_id      = l_dd_batch_id_tbl(i),
                shipment_line_number   = l_dd_line_num_tbl(i),
                reference_line_id      = l_src_line_id_tbl(i),
                last_update_date       = SYSDATE,
                last_updated_by        = FND_GLOBAL.User_Id,
                last_update_login      = FND_GLOBAL.Login_Id,
                request_id             = FND_GLOBAL.Conc_Request_Id,
                program_application_id = FND_GLOBAL.Prog_Appl_Id,
                program_id             = FND_GLOBAL.Conc_Program_Id,
                program_update_date    = SYSDATE
         where  rowid = l_rowid_tbl(i)
         and    l_wdd_update_flag(i) = 'Y';

      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'No. of delivery details updated', sql%rowcount);
      END IF;
      --

      l_rowid_tbl.delete;
      l_del_detail_tbl.delete;
      l_src_line_id_tbl.delete;
      l_org_id_tbl.delete;
      l_customer_id_tbl.delete;
      l_organization_id_tbl.delete;
      l_ship_from_loc_tbl.delete;
      l_ship_to_site_tbl.delete;
      l_invoice_to_site_tbl.delete;
      l_deliver_to_site_tbl.delete;
      l_ship_to_con_tbl.delete;
      l_invoice_to_con_tbl.delete;
      l_deliver_to_con_tbl.delete;
      l_ship_method_tbl.delete;
      l_freight_terms_tbl.delete;
      l_fob_code_tbl.delete;
      l_group_id_tbl.delete;
      l_shipment_batch_tbl.delete;
      l_dd_line_num_tbl.delete;
      l_wdd_update_flag.delete;
      l_dd_batch_id_tbl.delete;

      IF v_ignore < l_bulk_count THEN
         EXIT;
      END IF;
   END LOOP;
   --} Loop for fetching records - Ends

   -- Closing Dynamic Cursor
   IF DBMS_SQL.Is_Open(v_cursorid) THEN
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Closing cursor');
      END IF;
      --
      DBMS_SQL.Close_Cursor(v_cursorid);
      v_cursorid := null;
   END IF;

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'Total No. of shipment batches created', l_batch_tbl.count);
      WSH_DEBUG_SV.logmsg(l_module_name, '----------------------------------------------');
   ELSIF nvl(FND_GLOBAL.Conc_Request_Id, 0) > 0 THEN
      FND_FILE.put_line(FND_FILE.LOG, 'Total No. of shipment batches created => ' || l_batch_tbl.count);
      FND_FILE.put_line(FND_FILE.LOG, '----------------------------------------------');
   END IF;
   --

   --
   IF l_debug_on OR
      nvl(FND_GLOBAL.Conc_Request_Id, 0) > 0
   THEN
      IF l_batch_tbl.count > 0 THEN
         FOR i in l_batch_tbl.first..l_batch_tbl.last
         LOOP
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, i || '. Shipment Batch Id => ' || l_batch_tbl(i));
            ELSIF nvl(FND_GLOBAL.Conc_Request_Id, 0) > 0 THEN
               FND_FILE.put_line(FND_FILE.LOG, i || '. Shipment Batch Id => ' || l_batch_tbl(i));
            END IF;
         END LOOP;
      END IF;
   END IF;
   --

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, '----------------------------------------------');
      WSH_DEBUG_SV.pop(l_module_name);
   ELSIF nvl(FND_GLOBAL.Conc_Request_Id, 0) > 0 THEN
      FND_FILE.put_line(FND_FILE.LOG, '----------------------------------------------');
   END IF;
   --

EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         wsh_debug_sv.pop(l_module_name, 'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --

   WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Create_Shipment_Batch;
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Cancel_Line
--
-- PARAMETERS:
--       p_document_number      => Shipment Batch Document Number
--       p_line_number          => Shipment Batch Line Number
--       p_cancel_quantity      => quantity to unassign from Shipment batch
--       x_return_status        => Return Status of API (S,E,U)
--
-- COMMENT:
--       Delivery line(s) corresponding to document number and document line
--       number will be unassigned from Shipment Batch till the cancel quantity
--       is met.
--
--=============================================================================
--
PROCEDURE Cancel_Line(
          p_document_number      IN  VARCHAR2,
          p_line_number          IN  VARCHAR2,
          p_cancel_quantity      IN  NUMBER,
          x_return_status        OUT NOCOPY    VARCHAR2 )
IS
   CURSOR c_del_details IS
      select src_requested_quantity,
             requested_quantity,
             delivery_detail_id
      from   wsh_delivery_details wdd,
             wsh_transactions_history wth,
             wsh_shipment_batches wsb
      where  source_code = 'OE'
      and    released_status in ( 'R', 'B', 'X' )
      and    wdd.shipment_batch_id = wsb.batch_id
      and    wsb.name = entity_number
      and    shipment_line_number = p_line_number
      and    entity_type = 'BATCH'
      and    document_direction = 'O'
      and    document_type = 'SR'
      and    document_number = p_document_number
      order  by requested_quantity desc
      for update nowait;

   l_new_detail_id          NUMBER;
   l_avlb_quantity          NUMBER := 0;
   l_pending_cancel_qty     NUMBER;
   l_cancel_quantity        NUMBER;
   l_cancel_quantity2       NUMBER;

   l_return_status          VARCHAR2(1);

   l_unassign_detail_tab    WSH_UTIL_CORE.Id_Tab_Type;

   RECORD_LOCKED                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RECORD_LOCKED, -54);

   --
   l_debug_on               BOOLEAN;
   l_module_name CONSTANT   VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Cancel_Line';
   --
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
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name, 'p_document_number', p_document_number);
      WSH_DEBUG_SV.log(l_module_name, 'p_line_number', p_line_number);
      WSH_DEBUG_SV.log(l_module_name, 'p_cancel_quantity', p_cancel_quantity);
   END IF;
   --
   x_return_status      := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   l_pending_cancel_qty := p_cancel_quantity;

   --{ Cursor Loops Ends
   FOR i in c_del_details
   LOOP
      l_avlb_quantity := l_avlb_quantity + i.requested_quantity;

      IF i.requested_quantity > l_pending_cancel_qty
      THEN
      --{ Requested Quantity Greater than Cancel Quantity - Starts
         l_cancel_quantity := l_pending_cancel_qty;
         l_pending_cancel_qty := 0;
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Calling WSH_DELIVERY_DETAILS_ACTIONS.Split_Delivery_Details', WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --

         WSH_DELIVERY_DETAILS_ACTIONS.Split_Delivery_Details (
                  p_from_detail_id   =>  i.delivery_detail_id,
                  p_req_quantity     =>  l_cancel_quantity    ,
                  x_new_detail_id    =>  l_new_detail_id     ,
                  x_return_status    =>  l_return_status     );

         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'Return Status of WSH_DELIVERY_DETAILS_ACTIONS.Split_Delivery_Details', l_return_status);
         END IF;
         --

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            x_return_status := l_return_status;
            RAISE FND_API.G_EXC_ERROR;
         ELSE
            l_unassign_detail_tab(l_unassign_detail_tab.count+1) := l_new_detail_id;
         END IF;
      --} Requested Quantity Greater than Cancel Quantity - Ends
      ELSE
         l_unassign_detail_tab(l_unassign_detail_tab.count+1) := i.delivery_detail_id;
         l_pending_cancel_qty := l_pending_cancel_qty - i.requested_quantity;
      END IF;

      EXIT WHEN l_pending_cancel_qty = 0;
   END LOOP;

   IF l_pending_cancel_qty > 0 THEN
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Cancel Quantity ' || p_cancel_quantity || ' is greater than open quantity ' || l_avlb_quantity);
      END IF;
      --
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'Unassign delivery detail count', l_unassign_detail_tab.count);
   END IF;
   --
   IF l_unassign_detail_tab.count > 0 THEN
      FORALL i in l_unassign_detail_tab.first..l_unassign_detail_tab.last
         update wsh_delivery_details
         set    shipment_batch_id      = null,
                shipment_line_number   = null,
                reference_line_id      = null,
                last_update_date       = SYSDATE,
                last_updated_by        = FND_GLOBAL.User_Id,
                last_update_login      = FND_GLOBAL.Login_Id,
                request_id             = FND_GLOBAL.Conc_Request_Id,
                program_application_id = FND_GLOBAL.Prog_Appl_Id,
                program_id             = FND_GLOBAL.Conc_Program_Id,
                program_update_date    = SYSDATE
         where  delivery_detail_id = l_unassign_detail_tab(i);

      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'No. of delivery details Unassigned from Shipment Batch', sql%rowcount);
      END IF;
      --
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
     --
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'RECORD_LOCKED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:RECORD_LOCKED');
     END IF;
     --

   WHEN FND_API.G_EXC_ERROR THEN
      IF x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      END IF;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Rolling back the transactions');
      END IF;
      --
      rollback;
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'Error occured while spliting line');
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
   WHEN others THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Rolling back the transactions');
      END IF;
      --
      rollback;
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
END Cancel_Line;

END WSH_SHIPMENT_BATCH_PKG;

/
