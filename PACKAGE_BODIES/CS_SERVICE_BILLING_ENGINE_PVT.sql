--------------------------------------------------------
--  DDL for Package Body CS_SERVICE_BILLING_ENGINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SERVICE_BILLING_ENGINE_PVT" AS
/* $Header: csxvsbeb.pls 120.10.12010000.2 2008/10/06 05:51:40 sshilpam ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30):= 'CS_Service_Billing_Engine_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csxvsbeb.pls';
--g_debug VARCHAR2(1) := NVL(fnd_profile.value('APPS_DEBUG'), 'N');
--g_debug number := ASO_DEBUG_PUB.G_DEBUG_LEVEL;


-------------------------------------------------------------------------
-- Get the inventory item's primary unit of measurement.

Procedure Get_Primary_UOM(
   p_inventory_item_id      IN NUMBER,
   x_unit_of_measure_code   OUT NOCOPY varchar2)
IS

Cursor uom_csr(p_inventory_item_id number) IS
   Select primary_uom_code
   from mtl_system_items_kfv
   where inventory_item_id = p_inventory_item_id
   and   organization_id = cs_std.get_item_valdn_orgzn_id;

BEGIN
   OPEN uom_csr(p_inventory_item_id);
   FETCH uom_csr INTO x_unit_of_measure_code;
   CLOSE uom_csr;
END Get_Primary_UOM;


Procedure Consolidate_Labor_Coverages(
   p_lbr_in_tbl   IN oks_con_coverage_pub.bill_rate_tbl_type,
   x_lbr_out_tbl  OUT NOCOPY oks_con_coverage_pub.bill_rate_tbl_type)
IS

i   number;
j   number;
l_lbr_tmp_rec oks_con_coverage_pub.bill_rate_rec_type;

BEGIN
   j := 0;
   FOR i IN 1..p_lbr_in_tbl.count LOOP
   IF p_lbr_in_tbl(i).labor_item_id is not null THEN
      IF l_lbr_tmp_rec.start_datetime is not null THEN
         j := j + 1;
         x_lbr_out_tbl(j).start_datetime := l_lbr_tmp_rec.start_datetime;
         x_lbr_out_tbl(j).end_datetime := l_lbr_tmp_rec.end_datetime;
         x_lbr_out_tbl(j).labor_item_id := l_lbr_tmp_rec.labor_item_id;
         x_lbr_out_tbl(j).labor_item_org_id := l_lbr_tmp_rec.labor_item_org_id;
         x_lbr_out_tbl(j).bill_rate_code := l_lbr_tmp_rec.bill_rate_code;
         x_lbr_out_tbl(j).flat_rate := l_lbr_tmp_rec.flat_rate;
         x_lbr_out_tbl(j).flat_rate_uom_code := l_lbr_tmp_rec.flat_rate_uom_code;
         x_lbr_out_tbl(j).percent_over_listprice := l_lbr_tmp_rec.percent_over_listprice;

         l_lbr_tmp_rec.start_datetime := null;
         l_lbr_tmp_rec.end_datetime := null;
         l_lbr_tmp_rec.labor_item_id := null;
         l_lbr_tmp_rec.labor_item_org_id := null;
         l_lbr_tmp_rec.bill_rate_code := null;
         l_lbr_tmp_rec.flat_rate := null;
         l_lbr_tmp_rec.flat_rate_uom_code := null;
         l_lbr_tmp_rec.percent_over_listprice := null;
      END IF;

      j := j + 1;
      x_lbr_out_tbl(j).start_datetime := p_lbr_in_tbl(i).start_datetime;
      x_lbr_out_tbl(j).end_datetime := p_lbr_in_tbl(i).end_datetime;
      x_lbr_out_tbl(j).labor_item_id := p_lbr_in_tbl(i).labor_item_id;
      x_lbr_out_tbl(j).labor_item_org_id := p_lbr_in_tbl(i).labor_item_org_id;
      x_lbr_out_tbl(j).bill_rate_code := p_lbr_in_tbl(i).bill_rate_code;
      x_lbr_out_tbl(j).flat_rate := p_lbr_in_tbl(i).flat_rate;
      x_lbr_out_tbl(j).flat_rate_uom_code := p_lbr_in_tbl(i).flat_rate_uom_code;
      x_lbr_out_tbl(j).percent_over_listprice := p_lbr_in_tbl(i).percent_over_listprice;
   ELSE
      IF l_lbr_tmp_rec.start_datetime is null THEN
         l_lbr_tmp_rec.start_datetime := p_lbr_in_tbl(i).start_datetime;
         l_lbr_tmp_rec.end_datetime := p_lbr_in_tbl(i).end_datetime;
         l_lbr_tmp_rec.labor_item_id := p_lbr_in_tbl(i).labor_item_id;
         l_lbr_tmp_rec.labor_item_org_id := p_lbr_in_tbl(i).labor_item_org_id;
         l_lbr_tmp_rec.bill_rate_code := p_lbr_in_tbl(i).bill_rate_code;
         l_lbr_tmp_rec.flat_rate := p_lbr_in_tbl(i).flat_rate;
         l_lbr_tmp_rec.flat_rate_uom_code := p_lbr_in_tbl(i).flat_rate_uom_code;
         l_lbr_tmp_rec.percent_over_listprice := p_lbr_in_tbl(i).percent_over_listprice;
      ELSE
         l_lbr_tmp_rec.end_datetime := p_lbr_in_tbl(i).end_datetime;
      END IF;
   END IF;

END LOOP;

IF l_lbr_tmp_rec.start_datetime is not null THEN
   j := j + 1;
   x_lbr_out_tbl(j).start_datetime := l_lbr_tmp_rec.start_datetime;
   x_lbr_out_tbl(j).end_datetime := l_lbr_tmp_rec.end_datetime;
   x_lbr_out_tbl(j).labor_item_id := l_lbr_tmp_rec.labor_item_id;
   x_lbr_out_tbl(j).labor_item_org_id := l_lbr_tmp_rec.labor_item_org_id;
   x_lbr_out_tbl(j).bill_rate_code := l_lbr_tmp_rec.bill_rate_code;
   x_lbr_out_tbl(j).flat_rate := l_lbr_tmp_rec.flat_rate;
   x_lbr_out_tbl(j).flat_rate_uom_code := l_lbr_tmp_rec.flat_rate_uom_code;
   x_lbr_out_tbl(j).percent_over_listprice := l_lbr_tmp_rec.percent_over_listprice;
END IF;
/*
-- print original records
for i in 1..p_lbr_in_tbl.count loop
   d--DBMS_OUTPUT.PUT_LINE('p_lbr_in_tbl('||i||').start_datetime='|| TO_CHAR(p_lbr_in_tbl(i).start_datetime, 'DD-MON-YYYY HH24:MI:SS'));
   d--DBMS_OUTPUT.PUT_LINE('p_lbr_in_tbl('||i||').end_datetime='|| TO_CHAR(p_lbr_in_tbl(i).end_datetime, 'DD-MON-YYYY HH24:MI:SS'));
   d--DBMS_OUTPUT.PUT_LINE('p_lbr_in_tbl('||i||').labor_item_id='|| p_lbr_in_tbl(i).labor_item_id);
end loop;

-- print out final result
for i in 1..x_lbr_out_tbl.count loop
   d--DBMS_OUTPUT.PUT_LINE('x_lbr_out_tbl('||i||').start_datetime='|| TO_CHAR(x_lbr_out_tbl(i).start_datetime, 'DD-MON-YYYY HH24:MI:SS'));
   d--DBMS_OUTPUT.PUT_LINE('x_lbr_out_tbl('||i||').end_datetime='|| TO_CHAR(x_lbr_out_tbl(i).end_datetime, 'DD-MON-YYYY HH24:MI:SS'));
   d--DBMS_OUTPUT.PUT_LINE('x_lbr_out_tbl('||i||').labor_item_id='|| x_lbr_out_tbl(i).labor_item_id);
end loop;
*/
END Consolidate_Labor_Coverages;


-------------------------------------------------------------------------
-- Procedure: create_charges
-- Purpose  : This create_charges api can be evoked from:
--            - Service Debrief
--              Generate either in progress charges or final charges for a service debrief line.
--              Service Debrief should pass in p_sbe_record, p_commit set to false, and p_final_charge_flag
--              set to TRUE or FALSE based on the task assignment status.
--              When the task assignment status is permanently closed, the Service Debrief should update
--              inventory, IB, and call the Billing Engine with p_final_charge_flag set to TRUE so the
--              final charges will be generated.
--              If the task assignment status is not permanently closed, the Service Debrief should
--              just call the Billing Engine with p_final_charge_flag set to FALSE so in progress charges
--              will be generated.
--              p_commit set to FALSE is because SD can roll back all changes in case of failure occurs
--              so it can roll back.
--

PROCEDURE Create_Charges(
   P_Api_Version_Number    IN NUMBER,
   P_Init_Msg_List         IN VARCHAR2 := FND_API.G_FALSE,
   P_Commit                IN VARCHAR2 := FND_API.G_FALSE,
   p_sbe_record            IN SBE_Rec_Type,
   p_final_charge_flag     IN VARCHAR2,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2)
IS

   l_api_name           CONSTANT VARCHAR2(30) := 'Create_Charges';
   l_api_version_number CONSTANT NUMBER   := 1.0;
   l_api_name_full      CONSTANT VARCHAR2(61)   :=  G_PKG_NAME || '.' || l_api_name ;
   l_log_module         CONSTANT VARCHAR2(255)  := 'cs.plsql.' || l_api_name_full || '.';

   EXCP_USER_DEFINED    EXCEPTION;

   l_charges_rec        cs_charge_details_pub.charges_rec_type;
   x_tm_coverage_tbl    cs_tm_labor_schedule_pvt.tm_coverage_tbl_type;
   l_input_br_rec       oks_con_coverage_pub.input_br_rec;
   l_labor_sch_tbl      oks_con_coverage_pub.labor_sch_tbl_type;
   l_con_lbr_coverage_tbl   oks_con_coverage_pub.bill_rate_tbl_type;
   x_con_lbr_coverage_tbl   oks_con_coverage_pub.bill_rate_tbl_type;

   i                    number;
   j                    number;
   l_duration           number;
   l_base_uom           varchar2(3);
   l_primary_uom        Varchar2(3);
   l_incident_date      date;
   l_creation_date      date;
   l_customer_id        number;
   l_account_id         number;
   l_customer_product_id    number;
   l_contract_id        number;
   l_contract_service_id   number;
   --l_coverage_id        number;  --commented for R12 by mviswana
   --l_coverage_txn_group_id  number; --commented for R12 by mviswana
   l_po_number          varchar2(50);
   l_activity_start_date_time  date;
   l_activity_end_date_time    date;
   l_inventory_item_id  number;
   x_object_version_number  number;
   x_estimate_detail_id number;
   x_line_number        number;
   l_holiday_flag       varchar2(1);
   l_add_one_minute     varchar2(1);
-- fix for bug#4120101
--
   l_resource_id        number;
   l_task_id            number;
   l_labor_start_date_time  date;
   l_labor_end_date_time    date;
   lx_timezone_id       number;
   lx_timezone_name  varchar2(50);
   lx_labor_start_date_time  date;
   lx_labor_end_date_time    date;
--
--
-- Added for bug:5136865
   l_rate_code     VARCHAR2(40);
   l_rate_amount   NUMBER;
   l_rate_percent  NUMBER;
   l_rate_uom      VARCHAR2(30);
   k               NUMBER := 0;





   CURSOR incident_csr(p_incident_id number) IS
      SELECT incident_date, creation_date, customer_id, account_id, customer_product_id, contract_id, contract_service_id
        FROM cs_incidents_all_b
       WHERE incident_id = p_incident_id;

   /* CURSOR base_uom_csr IS
      SELECT uom_code
        FROM mtl_uom_conversions
       WHERE uom_class = 'Time' and conversion_rate = 1; */

 -- Bug 7229344
   Cursor billing_category IS
      Select cbtc.billing_category
        From mtl_system_items_kfv kfv, cs_billing_type_categories cbtc
       Where kfv.inventory_item_id = p_sbe_record.inventory_item_id
         and kfv.material_billable_flag = cbtc.billing_type
         and organization_id = cs_std.get_item_valdn_orgzn_id;

   Cursor txn_billing_type_csr(p_transaction_type_id number,p_billing_category varchar2) IS
      Select ctbt.txn_billing_type_id
        from cs_txn_billing_types ctbt, cs_billing_type_categories cbtc
       where ctbt.transaction_type_id = p_transaction_type_id
         and ctbt.billing_type = cbtc.billing_type
         and cbtc.billing_category = p_billing_category;
/*
   Cursor txn_billing_type_csr(p_transaction_type_id number) IS
      /*Select txn_billing_type_id
       from cs_txn_billing_types
       -where transaction_type_id = p_transaction_type_id
         and billing_type = 'L';
      Select ctbt.txn_billing_type_id
        from cs_txn_billing_types ctbt, cs_billing_type_categories cbtc
       where ctbt.transaction_type_id = p_transaction_type_id
         and ctbt.billing_type = cbtc.billing_type
         and cbtc.billing_category = 'L';
*/
--End Bug 7229344
    -- Added for ER 4120077, vkjain.
    -- Depot task debrief lines will use RO contract (NOT SR contract).
    CURSOR ro_contract_csr(p_repair_line_id number) IS
       SELECT  ro.contract_line_id
       FROM     csd_repairs ro
       WHERE ro.repair_line_id = p_repair_line_id;

     -- Added fix for bug#4120101
     CURSOR  get_task_resource(p_debrief_line_id number) IS
         SELECT  j.resource_id,j.task_id
         FROM    csf_debrief_headers h,
                 csf_debrief_lines l,
                 jtf_task_assignments_v  j,
                 jtf_tasks_b jt
        WHERE    l.debrief_line_id  = p_debrief_line_id
          AND    h.debrief_header_id = l.debrief_header_id
          AND    h.task_assignment_id = j.task_assignment_id
          AND    j.task_id = jt.task_id
          AND    jt.source_object_type_code  = 'SR';



   -- Added fix for bug:5136865
   Cursor get_rate_type(p_contract_line_id  NUMBER,
                        p_txn_billing_type_id  NUMBER,
                        p_business_process_id  NUMBER) IS
     SELECT br.rate_code,
            br.rate_uom,
            br.rate_amount,
            br.rate_percent
     FROM   oks_ent_txn_groups_v txn,
            oks_ent_bill_rates_v br,
            oks_ent_bill_types_v bt
    WHERE   bt.txn_group_id = txn.txn_group_id
     AND   br.billing_type_id = bt.contract_billing_type_id
     AND   bt.billing_type_id = p_txn_billing_type_id
     AND   txn.business_process_id = p_business_process_id
     AND   txn.contract_line_id = p_contract_line_id;

     -- bugfix#5443461
     Cursor get_billing_category(p_txn_billing_type_id NUMBER) IS
     SELECT bc.billing_category
     FROM   cs_billing_type_categories bc,
            cs_txn_billing_types bt
     WHERE  bt.billing_type = bc.billing_type
     AND    bt.txn_billing_type_id = p_txn_billing_type_id;

     l_billing_category VARCHAR2(30);
     l_bill_category VARCHAR2(30);


	--Added for 12.1 Service Costing
     Cursor get_sac_cost_flag(p_transaction_type_id NUMBER) IS
	select nvl(create_cost_flag ,'N'),
	       nvl(create_charge_flag,'Y')
	from  cs_transaction_types_b
	where transaction_type_id = p_transaction_type_id;


	   l_create_cost_detail VARCHAR2(1);
	   x_cost_id		NUMBER;
	   l_cost_flag		VARCHAR2(1);
	   l_charge_flag	VARCHAR2(1);


BEGIN
   SAVEPOINT Create_Charges;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                      	               p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(p_init_msg_list)
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

----------------------- FND Logging -----------------------------------
  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || 'start'
    , 'Inside ' || L_API_NAME_FULL || ', called with parameters below:'
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'P_Api_Version_Number:' || P_Api_Version_Number
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_init_msg_list:' || p_init_msg_list
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_commit:' || p_commit
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'incident_id                  	:' || p_sbe_record.incident_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'business_process_id          	:' || p_sbe_record.business_process_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'transaction_type_id          	:' || p_sbe_record.transaction_type_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'txn_billing_type_id          	:' || p_sbe_record.txn_billing_type_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'line_category_code           	:' || p_sbe_record.line_category_code
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'contract_id                  	:' || p_sbe_record.contract_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'contract_line_id             	:' || p_sbe_record.contract_line_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'price_list_id                	:' || p_sbe_record.price_list_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'currency_code                	:' || p_sbe_record.currency_code
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'service_date                 	:' || p_sbe_record.service_date
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'labor_start_date_time        	:' || p_sbe_record.labor_start_date_time
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'labor_end_date_time          	:' || p_sbe_record.labor_end_date_time
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'inventory_item_id            	:' || p_sbe_record.inventory_item_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'serial_number                	:' || p_sbe_record.serial_number
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'item_revision                	:' || p_sbe_record.item_revision
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'unit_of_measure_code         	:' || p_sbe_record.unit_of_measure_code
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'quantity                     	:' || p_sbe_record.quantity
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'after_warranty_cost          	:' || p_sbe_record.after_warranty_cost
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'return_reason_code           	:' || p_sbe_record.return_reason_code
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'installed_cp_return_by_date  	:' || p_sbe_record.installed_cp_return_by_date
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'customer_product_id          	:' || p_sbe_record.customer_product_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'transaction_inventory_org_id 	:' || p_sbe_record.transaction_inventory_org_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'transaction_sub_inventory    	:' || p_sbe_record.transaction_sub_inventory
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'original_source_id           	:' || p_sbe_record.original_source_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'original_source_code         	:' || p_sbe_record.original_source_code
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'source_id                    	:' || p_sbe_record.source_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'source_code                  	:' || p_sbe_record.source_code
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_final_charge_flag:' || p_final_charge_flag
    );
  END IF;

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    ( FND_LOG.level_statement
    , L_LOG_MODULE, '----- Private API: ' || g_pkg_name || '.' || l_api_name || ' starts at ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SSSSS')
    );
    FND_LOG.String
    ( FND_LOG.level_statement
    , L_LOG_MODULE, 'p_sbe_record.incident_id = ' || p_sbe_record.incident_id
    );
    FND_LOG.String
    ( FND_LOG.level_statement
    , L_LOG_MODULE, 'p_sbe_record.business_process_id = ' || p_sbe_record.business_process_id
    );
    FND_LOG.String
    ( FND_LOG.level_statement
    , L_LOG_MODULE, 'p_sbe_record.transaction_type_id = ' || p_sbe_record.transaction_type_id
    );
    FND_LOG.String
    ( FND_LOG.level_statement
    , L_LOG_MODULE, 'p_sbe_record.txn_billing_type_id = ' || p_sbe_record.txn_billing_type_id
    );
    FND_LOG.String
    ( FND_LOG.level_statement
    , L_LOG_MODULE, 'p_sbe_record.line_category_code = ' || p_sbe_record.line_category_code
    );
    FND_LOG.String
    ( FND_LOG.level_statement
    , L_LOG_MODULE, 'p_sbe_record.contract_id = ' || p_sbe_record.contract_id
    );
    FND_LOG.String
    ( FND_LOG.level_statement
    , L_LOG_MODULE, 'p_sbe_record.price_list_id = ' || p_sbe_record.price_list_id
    );
    FND_LOG.String
    ( FND_LOG.level_statement
    , L_LOG_MODULE, 'p_sbe_record.currency_code = ' || p_sbe_record.currency_code
    );
    FND_LOG.String
    ( FND_LOG.level_statement
    , L_LOG_MODULE, 'p_sbe_record.service_date = ' || p_sbe_record.service_date
    );
    FND_LOG.String
    ( FND_LOG.level_statement
    , L_LOG_MODULE, 'p_sbe_record.labor_start_date_time = ' || TO_CHAR(p_sbe_record.labor_start_date_time, 'DD-MON-YYYY HH24:MI:SS')
    );
    FND_LOG.String
    ( FND_LOG.level_statement
    , L_LOG_MODULE, 'p_sbe_record.labor_end_date_time = ' || TO_CHAR(p_sbe_record.labor_end_date_time, 'DD-MON-YYYY HH24:MI:SS')
    );
    FND_LOG.String
    ( FND_LOG.level_statement
    , L_LOG_MODULE, 'p_sbe_record.inventory_item_id = ' || p_sbe_record.inventory_item_id
    );
    FND_LOG.String
    ( FND_LOG.level_statement
    , L_LOG_MODULE, 'p_sbe_record.quantity = ' || p_sbe_record.quantity
    );
    FND_LOG.String
    ( FND_LOG.level_statement
    , L_LOG_MODULE, 'p_sbe_record.original_source_code = ' || p_sbe_record.original_source_code || '   original_source_id = ' || p_sbe_record.original_source_id
    );
    FND_LOG.String
    ( FND_LOG.level_statement
    , L_LOG_MODULE, 'p_sbe_record.source_code = ' || p_sbe_record.source_code || '   source_id = ' || p_sbe_record.source_id
    );
    FND_LOG.String
    ( FND_LOG.level_statement
    , L_LOG_MODULE, 'p_final_charge_flag = ' || p_final_charge_flag
    );
   END IF;

   --DBMS_OUTPUT.PUT_LINE('----- Private API: ' || g_pkg_name || '.' || l_api_name || ' starts at ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SSSSS'));
   --DBMS_OUTPUT.PUT_LINE('p_sbe_record.incident_id = ' || p_sbe_record.incident_id);
   --DBMS_OUTPUT.PUT_LINE('p_sbe_record.business_process_id = ' || p_sbe_record.business_process_id);
   --DBMS_OUTPUT.PUT_LINE('p_sbe_record.transaction_type_id = ' || p_sbe_record.transaction_type_id);
   --DBMS_OUTPUT.PUT_LINE('p_sbe_record.txn_billing_type_id = ' || p_sbe_record.txn_billing_type_id);
   --DBMS_OUTPUT.PUT_LINE('p_sbe_record.line_category_code = ' || p_sbe_record.line_category_code);
   --DBMS_OUTPUT.PUT_LINE('p_sbe_record.contract_id = ' || p_sbe_record.contract_id);
   --DBMS_OUTPUT.PUT_LINE('p_sbe_record.contract_line_id = ' || p_sbe_record.contract_line_id);
   --DBMS_OUTPUT.PUT_LINE('p_sbe_record.price_list_id = ' || p_sbe_record.price_list_id);
   --DBMS_OUTPUT.PUT_LINE('p_sbe_record.currency_code = ' || p_sbe_record.currency_code);
   --DBMS_OUTPUT.PUT_LINE('p_sbe_record.service_date = ' || p_sbe_record.service_date);
   --DBMS_OUTPUT.PUT_LINE('p_sbe_record.labor_start_date_time = ' || TO_CHAR(p_sbe_record.labor_start_date_time, 'DD-MON-YYYY HH24:MI:SS'));
   --DBMS_OUTPUT.PUT_LINE('p_sbe_record.labor_end_date_time = ' || TO_CHAR(p_sbe_record.labor_end_date_time, 'DD-MON-YYYY HH24:MI:SS'));
   --DBMS_OUTPUT.PUT_LINE('p_sbe_record.inventory_item_id = ' || p_sbe_record.inventory_item_id);
   --DBMS_OUTPUT.PUT_LINE('p_sbe_record.quantity = ' || p_sbe_record.quantity);
   --DBMS_OUTPUT.PUT_LINE('p_sbe_record.original_source_code = ' || p_sbe_record.original_source_code || '   original_source_id = ' || p_sbe_record.original_source_id);
   --DBMS_OUTPUT.PUT_LINE('p_sbe_record.source_code = ' || p_sbe_record.source_code || '   source_id = ' || p_sbe_record.source_id);
   --DBMS_OUTPUT.PUT_LINE('p_final_charge_flag = ' || p_final_charge_flag);

   /* Take out this feature per enhancement 2878467
   -- Exclude DR debriefs to prevent double billing.
   IF p_sbe_record.original_source_code = 'DR' THEN
      return;
   END IF;
   */

   -- Retrieve service request incident date, customer id, account id, customer product id, and contract.
   OPEN incident_csr(p_sbe_record.incident_id);
   FETCH incident_csr into l_incident_date, l_creation_date, l_customer_id, l_account_id, l_customer_product_id, l_contract_id, l_contract_service_id;
   IF incident_csr%NOTFOUND THEN
      CLOSE incident_csr;
      FND_MESSAGE.SET_NAME('CS', 'CS_INCIDENT_NOT_FOUND');
      FND_MESSAGE.SET_TOKEN('INCIDENT_ID', p_sbe_record.incident_id);
      FND_MSG_PUB.ADD;
      RAISE EXCP_USER_DEFINED;
   END IF;
   CLOSE incident_csr;

   -- Added for ER 4120077, vkjain.
   -- Depot task debrief lines will use RO contract (NOT SR contract).
   IF( p_sbe_record.original_source_code = 'DR') THEN
      -- For Depot originated debrief lines we will only use
      -- RO contract, even if SR contract exists.
      -- If there is no RO contract then no contract is applied, even
      -- if SR contract exists.
      l_contract_service_id := NULL;

      -- Get the RO contract, if one exists.
      OPEN ro_contract_csr(p_sbe_record.original_source_id);
      FETCH ro_contract_csr into l_contract_service_id;
      IF ro_contract_csr%ISOPEN THEN
         CLOSE ro_contract_csr;
      END IF;
   END IF;

   l_contract_id := null;
   --l_coverage_id := null;  --commented for R12 by mviswana
   --l_coverage_txn_group_id := null; --commented for R12 by mviswana

   -- Get contract coverage.
   IF l_contract_service_id IS NOT NULL THEN

      cs_charge_details_pvt.get_contract(
         p_api_name               => l_api_name,
         p_contract_SR_ID         => l_contract_service_id,
         p_incident_date          => l_incident_date,
         p_creation_date          => l_creation_date,
         p_customer_id            => l_customer_id,
         p_cust_account_id        => l_account_id,
         p_cust_product_id        => l_customer_product_id,
         p_business_process_id    => p_sbe_record.business_process_id,
         x_contract_id            => l_contract_id,
         --x_coverage_id            => l_coverage_id, --commented for R12 by mviswana
         --x_coverage_txn_group_id  => l_coverage_txn_group_id, --commented for R12 by mviswana
         x_po_number              => l_po_number,
         x_return_status          => x_return_status,
         x_msg_count              => x_msg_count,
         x_msg_data               => x_msg_data);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         FND_MESSAGE.SET_NAME('CS', 'CS_CHG_GET_CONTRACT_API_ERROR');
         FND_MESSAGE.SET_TOKEN('TEXT', x_msg_data);
         FND_MSG_PUB.ADD;
         RAISE EXCP_USER_DEFINED;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('x_contract_id => l_contract_id = ' || l_contract_id);
      ----DBMS_OUTPUT.PUT_LINE('x_coverage_id => l_coverage_id = ' || l_coverage_id);
      ----DBMS_OUTPUT.PUT_LINE('x_coverage_txn_group_id => l_coverage_txn_group_id = ' || l_coverage_txn_group_id);

   END IF;
   l_charges_rec.contract_line_id := l_contract_service_id;
   l_charges_rec.rate_type_code := NULL;    --MAYA Need To determine the value of this
   l_charges_rec.contract_id := l_contract_id;
   l_charges_rec.coverage_id := null;
   l_charges_rec.coverage_txn_group_id := null;
   l_charges_rec.purchase_order_num := l_po_number;
   l_charges_rec.price_list_id := p_sbe_record.price_list_id;
   l_charges_rec.original_source_id := p_sbe_record.original_source_id;
   l_charges_rec.original_source_code := p_sbe_record.original_source_code;
   l_charges_rec.source_id := p_sbe_record.source_id;
   l_charges_rec.source_code := p_sbe_record.source_code;
   l_charges_rec.transaction_type_id := p_sbe_record.transaction_type_id;
   l_charges_rec.txn_billing_type_id := p_sbe_record.txn_billing_type_id;
   l_charges_rec.incident_id := p_sbe_record.incident_id;
   l_charges_rec.business_process_id := p_sbe_record.business_process_id;
   l_charges_rec.currency_code := p_sbe_record.currency_code;
   l_charges_rec.item_revision := p_sbe_record.item_revision;
   l_charges_rec.customer_product_id := p_sbe_record.customer_product_id;
   l_charges_rec.installed_cp_return_by_date := p_sbe_record.installed_cp_return_by_date;
   l_charges_rec.apply_contract_discount := 'Y';  -- Always automatically apply contract discount.
   l_charges_rec.interface_to_oe_flag := FND_API.G_MISS_CHAR;
   l_charges_rec.rollup_flag := 'N';
   l_charges_rec.add_to_order_flag := 'N';
   l_charges_rec.no_charge_flag := FND_API.G_MISS_CHAR;
   l_charges_rec.generated_by_bca_engine := 'Y';
   l_charges_rec.line_category_code := p_sbe_record.line_category_code;
   l_charges_rec.return_reason_code := p_sbe_record.return_reason_code;
   l_charges_rec.serial_number := p_sbe_record.serial_number;
   l_charges_rec.transaction_inventory_org := p_sbe_record.transaction_inventory_org_id;
   l_charges_rec.transaction_sub_inventory := p_sbe_record.transaction_sub_inventory;


  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    ( FND_LOG.level_statement
    , L_LOG_MODULE, 'l_charges_rec.contract_id = ' || l_charges_rec.contract_id
    );
    FND_LOG.String
    ( FND_LOG.level_statement
    , L_LOG_MODULE, 'l_charges_rec.coverage_id = ' || l_charges_rec.coverage_id
    );
    FND_LOG.String
    ( FND_LOG.level_statement
    , L_LOG_MODULE, 'l_charges_rec.coverage_txn_group_id = ' || l_charges_rec.coverage_txn_group_id
    );
  END IF;
   --DBMS_OUTPUT.PUT_LINE('l_charges_rec.contract_id = ' || l_charges_rec.contract_id);
   --DBMS_OUTPUT.PUT_LINE('l_charges_rec.coverage_id = ' || l_charges_rec.coverage_id);
   --DBMS_OUTPUT.PUT_LINE('l_charges_rec.coverage_txn_group_id = ' || l_charges_rec.coverage_txn_group_id);

   -- If p_final_charge_flag = 'Y', create actual charge line,
   -- otherwise, create in progress charge line.
   IF p_final_charge_flag = 'Y' THEN
      l_charges_rec.charge_line_type := 'ACTUAL';
   ELSE
      l_charges_rec.charge_line_type := 'IN_PROGRESS';
   END IF;

	--Added For 12.1 Service Costing
	OPEN  get_sac_cost_flag(p_sbe_record.transaction_type_id);
        FETCH get_sac_cost_flag
        INTO  l_cost_flag,l_charge_flag;
        CLOSE get_sac_cost_flag;



   -- If inventory_item_id is null (labor for sure), get the labor coverages and billing rates
   -- based on the Contracts Labor Coverages and Time Material Labor Schedules.
IF p_sbe_record.inventory_item_id IS NULL THEN

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    ( FND_LOG.level_statement
    , L_LOG_MODULE, '--- p_sbe_record.inventory_item_id is null.'
    );
  END IF;

      --DBMS_OUTPUT.PUT_LINE('--- p_sbe_record.inventory_item_id is null.');

      -- Validate if the start datetime and end datetime are passed in and are not the same.
      IF p_sbe_record.labor_start_date_time IS NULL OR
         p_sbe_record.labor_end_date_time IS NULL OR
         TO_CHAR(p_sbe_record.labor_start_date_time, 'DD-MON-YYYY HH24:MI:SS') = TO_CHAR(p_sbe_record.labor_end_date_time, 'DD-MON-YYYY HH24:MI:SS') THEN
         FND_MESSAGE.SET_NAME('CS', 'CS_CHG_LBR_DATETIME_REQD');
         FND_MESSAGE.SET_TOKEN('LABOR_START_DATETIME', TO_CHAR(p_sbe_record.labor_start_date_time, 'DD-MON-YYYY HH24:MI:SS'));
         FND_MESSAGE.SET_TOKEN('LABOR_END_DATETIME', TO_CHAR(p_sbe_record.labor_end_date_time, 'DD-MON-YYYY HH24:MI:SS'));
         FND_MSG_PUB.ADD;
         RAISE EXCP_USER_DEFINED;
      END IF;

      -- Convert labor start datetime and end datetime using the new timezone routine
      -- fix for bug#4120101
      -- IF fnd_profile.value ('ENABLE_TIMEZONE_CONVERSIONS') = 'Y'  THEN

                OPEN get_task_resource(l_charges_rec.source_id);
                FETCH get_task_resource
                INTO  l_resource_id,
                      l_task_id;
                CLOSE get_task_resource;

          --DBMS_OUTPUT.PUT_LINE('Resource_Id' || l_resource_id);
          --DBMS_OUTPUT.PUT_LINE('Task_Id' || l_task_id);


                 CS_TZ_GET_DETAILS_PVT.Customer_Preferred_Time_Zone(
                        P_INCIDENT_ID  => l_charges_rec.incident_id,
                        P_TASK_ID      => l_task_id,
                        P_RESOURCE_ID  => l_resource_id,
                        P_INCIDENT_LOCATION_ID => NULL,
			P_incident_location_type => NULL,
                        P_CONTACT_PARTY_ID     => NULL,
                        P_CUSTOMER_ID          => NULL,
                        X_TIMEZONE_ID          => lx_timezone_id,
                        X_TIMEZONE_NAME        => lx_timezone_name);

          --DBMS_OUTPUT.PUT_LINE('Timezone_Id' || lx_timezone_id);
          --DBMS_OUTPUT.PUT_LINE('Timezone_name' || lx_timezone_name);

        IF  p_sbe_record.labor_start_date_time  IS NOT NULL AND
            lx_timezone_id IS NOT NULL THEN

                HZ_TIMEZONE_PUB.Get_time(
                        p_api_version     => 1.0,
                        p_init_msg_list   => 'T',
                        p_source_tz_id    => fnd_profile.value('SERVER_TIMEZONE_ID'),
                        p_dest_tz_id      => lx_timezone_id,
                        p_source_day_time => p_sbe_record.labor_start_date_time,
                        x_dest_day_time   => lx_labor_start_date_time,
                        x_return_status   => x_return_status,
                        x_msg_count       => x_msg_count,
                        x_msg_data        => x_msg_data);
  --DBMS_OUTPUT.PUT_LINE('Labor_start_date' || lx_labor_start_date_time);


                   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   FND_MESSAGE.SET_NAME('CS', 'HZ_TIMEZONE_PUB_API_ERR');
                   FND_MSG_PUB.ADD;
                   RAISE EXCP_USER_DEFINED;
                   END IF;
       END IF;

        IF  p_sbe_record.labor_end_date_time IS NOT NULL AND
               lx_timezone_id IS NOT NULL THEN

                HZ_TIMEZONE_PUB.Get_time(
                        p_api_version     => 1.0,
                        p_init_msg_list   => 'T',
                        p_source_tz_id    => fnd_profile.value('SERVER_TIMEZONE_ID'),
                        p_dest_tz_id      => lx_timezone_id,
                        p_source_day_time => p_sbe_record.labor_end_date_time,
                        x_dest_day_time   => lx_labor_end_date_time,
                        x_return_status   => x_return_status,
                        x_msg_count       => x_msg_count,
                        x_msg_data        => x_msg_data);


     --DBMS_OUTPUT.PUT_LINE('Labor_end_date' || lx_labor_end_date_time);

                   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   FND_MESSAGE.SET_NAME('CS', 'HZ_TIMEZONE_PUB_API_ERR');
                   FND_MSG_PUB.ADD;
                   RAISE EXCP_USER_DEFINED;
                   END IF;


        END IF;

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    ( FND_LOG.level_statement
    , L_LOG_MODULE, 'l_resource_id' || l_resource_id
    );
    FND_LOG.String
    ( FND_LOG.level_statement
    , L_LOG_MODULE, 'l_task_id' || l_task_id
    );
    FND_LOG.String
    ( FND_LOG.level_statement
    , L_LOG_MODULE, 'lx_timezone_id' || lx_timezone_id
    );
    FND_LOG.String
    ( FND_LOG.level_statement
    , L_LOG_MODULE, 'lx_timezone_name' || lx_timezone_name
    );
    FND_LOG.String
    ( FND_LOG.level_statement
    , L_LOG_MODULE, 'lx_labor_start_date_time' || lx_labor_start_date_time
    );
    FND_LOG.String
    ( FND_LOG.level_statement
    , L_LOG_MODULE, 'lx_labor_end_date_time' || lx_labor_end_date_time
    );
  END IF;
-- END IF; -- timezone profile
 -- End of fix for bug#4120101

-- Retrieve the time base unit of measurement code (HR).  It will be used to ververt labor duration.
      /* OPEN base_uom_csr;
      FETCH base_uom_csr into l_base_uom;
      IF base_uom_csr%NOTFOUND THEN
         CLOSE base_uom_csr;
      END IF;
      CLOSE base_uom_csr; */
      l_base_uom := fnd_profile.value('CSF_UOM_HOURS');

  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'The Value of profile CSF_UOM_HOURS :' || l_base_uom
    );
  END IF;
  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    ( FND_LOG.level_statement
    , L_LOG_MODULE, 'l_base_uom = ' || l_base_uom
    );
  END IF;
      --DBMS_OUTPUT.PUT_LINE('l_base_uom = ' || l_base_uom);

      -- Get transaction billing type for service debrief labor activity that without labor inventory item specified.
      IF l_charges_rec.transaction_type_id IS NOT NULL THEN
         OPEN txn_billing_type_csr(l_charges_rec.transaction_type_id,'L');
         FETCH txn_billing_type_csr into l_charges_rec.txn_billing_type_id;
         IF txn_billing_type_csr%NOTFOUND THEN
            CLOSE txn_billing_type_csr;
            FND_MESSAGE.SET_NAME('CS', 'CS_CHG_TXN_BILLING_TYPE_ERROR');
            FND_MESSAGE.SET_TOKEN('TRANSACTION_TYPE_ID', l_charges_rec.transaction_type_id);
            FND_MSG_PUB.ADD;
            RAISE EXCP_USER_DEFINED;
         END IF;
         CLOSE txn_billing_type_csr;
      ELSE
         FND_MESSAGE.SET_NAME('CS', 'CS_CHG_TXN_BILLING_TYPE_ERROR');
         FND_MESSAGE.SET_TOKEN('TRANSACTION_TYPE_ID', l_charges_rec.transaction_type_id);
         FND_MSG_PUB.ADD;
         RAISE EXCP_USER_DEFINED;
      END IF;

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    ( FND_LOG.level_statement
    , L_LOG_MODULE, 'l_charges_rec.txn_billing_type_id = ' || l_charges_rec.txn_billing_type_id
    );
  END IF;

      --DBMS_OUTPUT.PUT_LINE('l_charges_rec.txn_billing_type_id = ' || l_charges_rec.txn_billing_type_id);

      -- Assign values to l_input_br_rec.
      --l_input_br_rec.contract_line_id := l_charges_rec.coverage_id;  --commented for R12 by mviswana
      l_input_br_rec.contract_line_id := l_contract_service_id;
      l_input_br_rec.business_process_id := l_charges_rec.business_process_id;
      l_input_br_rec.txn_billing_type_id := l_charges_rec.txn_billing_type_id;
      l_input_br_rec.request_date := l_incident_date;

      --DBMS_OUTPUT.PUT_LINE('l_input_br_rec.contract_line_id'||l_input_br_rec.contract_line_id);
      --DBMS_OUTPUT.PUT_LINE('l_input_br_rec.business_process_id'||l_input_br_rec.business_process_id);
      --DBMS_OUTPUT.PUT_LINE('l_input_br_rec.txn_billing_type_id'||l_input_br_rec.txn_billing_type_id);
      --DBMS_OUTPUT.PUT_LINE('l_input_br_rec.request_date'||l_input_br_rec.request_date);

      -- Break up the labor activity into different days if it is across days.

      -- fix for bug#4120101
      l_activity_start_date_time := lx_labor_start_date_time;
      l_activity_end_date_time := lx_labor_end_date_time;
      l_labor_start_date_time := lx_labor_start_date_time;
      l_labor_end_date_time := lx_labor_end_date_time;

      -- Break up the labor activity into different days if it is across days.
      -- l_activity_start_date_time := p_sbe_record.labor_start_date_time;
      -- l_activity_end_date_time := p_sbe_record.labor_end_date_time;

      --Fixed Issue for Labor Items in a Timezone environment
      --Bug # 4120101

      WHILE (trunc(l_activity_start_date_time) <= trunc(l_labor_end_date_time)) AND
         TO_CHAR(l_activity_start_date_time, 'DD-MON-YYYY HH24:MI:SS') <> TO_CHAR(l_labor_end_date_time, 'DD-MON-YYYY HH24:MI:SS') LOOP

         IF (trunc(l_labor_end_date_time) > trunc(l_activity_start_date_time)) THEN
            l_activity_end_date_time := trunc(l_activity_start_date_time) + 1 - 1/(24*60);
            l_add_one_minute := 'Y';
         ELSE
            l_activity_end_date_time := l_labor_end_date_time;
            l_add_one_minute := 'N';
         END IF;

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    ( FND_LOG.level_statement
    , L_LOG_MODULE, '-- Process break up date => ' || TO_CHAR(l_activity_start_date_time, 'DD-MON-YYYY HH24:MI:SS')  || ' ~ ' || TO_CHAR(l_activity_end_date_time, 'DD-MON-YYYY HH24:MI:SS')
    );
  END IF;
	 --DBMS_OUTPUT.PUT_LINE('-- Process break up date => ' || TO_CHAR(l_activity_start_date_time, 'DD-MON-YYYY HH24:MI:SS') || ' ~ ' || TO_CHAR(l_activity_end_date_time, 'DD-MON-YYYY HH24:MI:SS'));
         --DBMS_OUTPUT.PUT_LINE('l_contract_id is '||l_contract_id);

    -- Fixed the issue to resolve Bug # 5024792

    IF l_contract_service_id IS NOT NULL THEN  -- If contract exists.

	  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
	  THEN
	    FND_LOG.String
	    ( FND_LOG.level_statement
	    , L_LOG_MODULE, '-- Contract exists.'
	    );
	  END IF;
	    --DBMS_OUTPUT.PUT_LINE('-- Contract exists.');

            -- Determine if the labor activity date is a holiday or not.
            -- Calender team provided API will be used in the near future.
            l_holiday_flag := 'N';

            -- Assign values to l_labor_sch_rec_type.
            l_labor_sch_tbl(1).start_datetime := l_activity_start_date_time;
            l_labor_sch_tbl(1).end_datetime := l_activity_end_date_time;
            l_labor_sch_tbl(1).holiday_flag := l_holiday_flag;

            --DBMS_OUTPUT.PUT_LINE('l_labor_sch_tbl(1).start_datetime'||l_labor_sch_tbl(1).start_datetime);
            --DBMS_OUTPUT.PUT_LINE('l_labor_sch_tbl(1).end_datetime'||l_labor_sch_tbl(1).end_datetime);
            --DBMS_OUTPUT.PUT_LINE('l_labor_sch_tbl(1).holiday_flag'||l_labor_sch_tbl(1).holiday_flag);

            -- Get Contract labor coverage billing data.
            oks_con_coverage_pub.get_bill_rates(
               p_api_version => p_api_version_number,
               p_init_msg_list => FND_API.G_FALSE,
               p_input_br_rec => l_input_br_rec,
               p_labor_sch_tbl => l_labor_sch_tbl,
               x_return_status => x_return_status,
               x_msg_count => x_msg_count,
               x_msg_data => x_msg_data,
               x_bill_rate_tbl => l_con_lbr_coverage_tbl);

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               FND_MESSAGE.SET_NAME('CS', 'CS_CHG_CON_LBR_COVERAGE_API_ER');
               FND_MESSAGE.SET_TOKEN('TEXT', x_msg_data);
               FND_MSG_PUB.ADD;
               RAISE EXCP_USER_DEFINED;
            END IF;

            -- Consolidate contracts labor coverage time segments
            Consolidate_Labor_Coverages(
               p_lbr_in_tbl => l_con_lbr_coverage_tbl,
               x_lbr_out_tbl => x_con_lbr_coverage_tbl);

	  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
	  THEN
	    FND_LOG.String
	    ( FND_LOG.level_statement
	    , L_LOG_MODULE, 'x_con_lbr_coverage_tbl.count =' || x_con_lbr_coverage_tbl.count
	    );
	  END IF;
	    --DBMS_OUTPUT.PUT_LINE('x_con_lbr_coverage_tbl.count = ' || x_con_lbr_coverage_tbl.count);

            -- For record returned that is covered by the contract, create charge line.
            -- For record that is not covered by the contract, get TM labor activity billing data,
            -- then create charge line.
	        FOR i in 1..x_con_lbr_coverage_tbl.count LOOP

               -- If covered by contract.
               IF x_con_lbr_coverage_tbl(i).labor_item_id IS NOT NULL OR
                  x_con_lbr_coverage_tbl(i).flat_rate IS NOT NULL THEN

		  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
		  THEN
		    FND_LOG.String
		    ( FND_LOG.level_statement
		    , L_LOG_MODULE, '-- Covered by Contract Labor Coverage.'
		    );
		  END IF;
		  --DBMS_OUTPUT.PUT_LINE('-- Covered by Contract Labor Coverage.');

                  l_charges_rec.inventory_item_id_in := x_con_lbr_coverage_tbl(i).labor_item_id;
                  l_charges_rec.activity_start_time := x_con_lbr_coverage_tbl(i).start_datetime;
                  --l_charges_rec.activity_end_time := x_con_lbr_coverage_tbl(i).end_datetime;

                  -- add one minute back for last minute coverage of a day
                  IF to_char(x_con_lbr_coverage_tbl(i).end_datetime, 'HH24:MI') = '23:59' AND
                     l_add_one_minute = 'Y' THEN
                     l_charges_rec.activity_end_time := x_con_lbr_coverage_tbl(i).end_datetime + (1 / (24 * 60));
                  ELSE
                     l_charges_rec.activity_end_time := x_con_lbr_coverage_tbl(i).end_datetime;
                  END IF;

                  -- Calculate labor quantity in base labor unit of measurement (HR).
       	          l_duration := (l_charges_rec.activity_end_time
                                - l_charges_rec.activity_start_time) * 24;

                  -- Convert labor quantity to labor item primary UOM or contract specified UOM.
                  IF x_con_lbr_coverage_tbl(i).flat_rate_uom_code IS NOT NULL THEN
                     l_primary_uom := x_con_lbr_coverage_tbl(i).flat_rate_uom_code;
                  ELSE
                     get_primary_uom(l_charges_rec.inventory_item_id_in, l_primary_uom);
                  END IF;
                  l_charges_rec.unit_of_measure_code := l_primary_uom;
       	          l_charges_rec.quantity_required := inv_convert.inv_um_convert(
                     Null, 2, l_duration, l_base_uom, l_primary_uom, NULL, NULL);

                  IF x_con_lbr_coverage_tbl(i).flat_rate IS NOT NULL THEN
                     l_charges_rec.list_price := x_con_lbr_coverage_tbl(i).flat_rate;
                  ELSE
                     l_charges_rec.list_price := NULL;
                  END IF;

                  IF x_con_lbr_coverage_tbl(i).percent_over_listprice IS NOT NULL THEN
                     l_charges_rec.con_pct_over_list_price := x_con_lbr_coverage_tbl(i).percent_over_listprice;
                  ELSE
                     l_charges_rec.con_pct_over_list_price := NULL;
                  END IF;


                  --Code Added for Bug # 5136865
                  IF x_con_lbr_coverage_tbl(i).bill_rate_code IS NOT NULL THEN
                    l_charges_rec.rate_type_code := x_con_lbr_coverage_tbl(i).bill_rate_code;
                  ELSE
                    l_charges_rec.rate_type_code := NULL;
                  END IF;


		  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
		  THEN
		    FND_LOG.String
		    ( FND_LOG.level_statement
		    , L_LOG_MODULE, 'x_con_lbr_coverage_tbl('||i||').start_datetime = ' || TO_CHAR(x_con_lbr_coverage_tbl(i).start_datetime, 'DD-MON-YYYY HH24:MI:SS')
		    );
		    FND_LOG.String
		    ( FND_LOG.level_statement
		    , L_LOG_MODULE, 'x_con_lbr_coverage_tbl('||i||').end_datetime = ' || TO_CHAR(x_con_lbr_coverage_tbl(i).end_datetime, 'DD-MON-YYYY HH24:MI:SS')
		    );
		    FND_LOG.String
		    ( FND_LOG.level_statement
		    , L_LOG_MODULE, 'x_con_lbr_coverage_tbl('||i||').labor_item_id = ' || x_con_lbr_coverage_tbl(i).labor_item_id
		    );
		    FND_LOG.String
		    ( FND_LOG.level_statement
		    , L_LOG_MODULE, 'x_con_lbr_coverage_tbl('||i||').flat_rate = ' || x_con_lbr_coverage_tbl(i).flat_rate
		    );
		    FND_LOG.String
		    ( FND_LOG.level_statement
		    , L_LOG_MODULE, 'x_con_lbr_coverage_tbl('||i||').flat_rate_uom_code = ' || x_con_lbr_coverage_tbl(i).flat_rate_uom_code
		    );
		    FND_LOG.String
		    ( FND_LOG.level_statement
		    , L_LOG_MODULE, 'x_con_lbr_coverage_tbl('||i||').percent_over_listprice = ' || x_con_lbr_coverage_tbl(i).percent_over_listprice
		    );
		    FND_LOG.String
		    ( FND_LOG.level_statement
		    , L_LOG_MODULE, 'l_charges_rec.unit_of_measure_code = ' || l_charges_rec.unit_of_measure_code
		    );
		    FND_LOG.String
		    ( FND_LOG.level_statement
		    , L_LOG_MODULE, 'l_charges_rec.quantity_required = ' || l_charges_rec.quantity_required
		    );
		    FND_LOG.String
		    ( FND_LOG.level_statement
		    , L_LOG_MODULE, 'l_charges_rec.list_price  = ' || l_charges_rec.list_price
		    );
		    FND_LOG.String
		    ( FND_LOG.level_statement
		    , L_LOG_MODULE, 'l_charges_rec.con_pct_over_list_price = ' || l_charges_rec.con_pct_over_list_price
		    );
		  END IF;
		  --DBMS_OUTPUT.PUT_LINE('x_con_lbr_coverage_tbl('||i||').start_datetime = ' || TO_CHAR(x_con_lbr_coverage_tbl(i).start_datetime, 'DD-MON-YYYY HH24:MI:SS'));
                  --DBMS_OUTPUT.PUT_LINE('x_con_lbr_coverage_tbl('||i||').end_datetime = ' || TO_CHAR(x_con_lbr_coverage_tbl(i).end_datetime, 'DD-MON-YYYY HH24:MI:SS'));
                  --DBMS_OUTPUT.PUT_LINE('x_con_lbr_coverage_tbl('||i||').labor_item_id = ' || x_con_lbr_coverage_tbl(i).labor_item_id);
                  --DBMS_OUTPUT.PUT_LINE('x_con_lbr_coverage_tbl('||i||').flat_rate = ' || x_con_lbr_coverage_tbl(i).flat_rate);
                  --DBMS_OUTPUT.PUT_LINE('x_con_lbr_coverage_tbl('||i||').flat_rate_uom_code = ' || x_con_lbr_coverage_tbl(i).flat_rate_uom_code);
                  --DBMS_OUTPUT.PUT_LINE('x_con_lbr_coverage_tbl('||i||').percent_over_listprice = ' || x_con_lbr_coverage_tbl(i).percent_over_listprice);
                  --DBMS_OUTPUT.PUT_LINE('l_charges_rec.unit_of_measure_code = ' || l_charges_rec.unit_of_measure_code);
                  --DBMS_OUTPUT.PUT_LINE('l_charges_rec.quantity_required = ' || l_charges_rec.quantity_required);
                  --DBMS_OUTPUT.PUT_LINE('l_charges_rec.list_price = ' || l_charges_rec.list_price);
                  --DBMS_OUTPUT.PUT_LINE('l_charges_rec.con_pct_over_list_price = ' || l_charges_rec.con_pct_over_list_price);


		if l_cost_flag ='Y' and l_charge_flag ='Y' then
		l_create_cost_detail := 'Y';
		else
		l_create_cost_detail :='N';
		end if;

                  -- Create charge line.
                  cs_charge_details_pub.Create_Charge_Details(
                     p_api_version => p_api_version_number,
                     p_init_msg_list => FND_API.G_FALSE,
                     p_commit => p_commit,
                     p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                     x_return_status => x_return_status,
                     x_msg_count => x_msg_count,
                     x_object_version_number => x_object_version_number,
                     x_msg_data => x_msg_data,
                     x_estimate_detail_id => x_estimate_detail_id,
                     x_line_number => x_line_number,
                     p_Charges_Rec => l_charges_rec,
		     p_create_cost_detail =>l_create_cost_detail, --Added for Service Costing
		     x_cost_id =>x_cost_id);
                  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     FND_MESSAGE.SET_NAME('CS', 'CS_CHG_CHARGE_DETAILS_API_ERR');
                     FND_MSG_PUB.ADD;
                     RAISE EXCP_USER_DEFINED;
                  END IF;

               ELSE  -- Not covered by contract.

		  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
		  THEN
		    FND_LOG.String
		    ( FND_LOG.level_statement
		    , L_LOG_MODULE, '-- Not covered by Contract Labor Coverage.  Calling TM Labor Coverage...'
		    );
		    FND_LOG.String
		    ( FND_LOG.level_statement
		    , L_LOG_MODULE, 'x_con_lbr_coverage_tbl('||i||').start_datetime = ' || TO_CHAR(x_con_lbr_coverage_tbl(i).start_datetime, 'DD-MON-YYYY HH24:MI:SS')
		    );
		    FND_LOG.String
		    ( FND_LOG.level_statement
		    , L_LOG_MODULE, 'x_con_lbr_coverage_tbl('||i||').end_datetime = ' || TO_CHAR(x_con_lbr_coverage_tbl(i).end_datetime, 'DD-MON-YYYY HH24:MI:SS')
		    );
		  END IF;
		  --DBMS_OUTPUT.PUT_LINE('-- Not covered by Contract Labor Coverage.  Calling TM Labor Coverage...');
                  --DBMS_OUTPUT.PUT_LINE('x_con_lbr_coverage_tbl('||i||').start_datetime = ' || TO_CHAR(x_con_lbr_coverage_tbl(i).start_datetime, 'DD-MON-YYYY HH24:MI:SS'));
                  --DBMS_OUTPUT.PUT_LINE('x_con_lbr_coverage_tbl('||i||').end_datetime = ' || TO_CHAR(x_con_lbr_coverage_tbl(i).end_datetime, 'DD-MON-YYYY HH24:MI:SS'));

                  -- Get labor activity billing data for those not covered by contract.
                  cs_tm_labor_schedule_pvt.get_labor_coverages(
                     p_business_process_id => p_sbe_record.business_process_id,
                     p_activity_start_date_time => x_con_lbr_coverage_tbl(i).start_datetime,
                     p_activity_end_date_time => x_con_lbr_coverage_tbl(i).end_datetime,
                     x_labor_coverage_tbl => x_tm_coverage_tbl,
                     x_return_status => x_return_status,
                     x_msg_count => x_msg_count,
                     x_msg_data => x_msg_data,
                     p_api_version => p_api_version_number,
                     p_init_msg_list => FND_API.G_FALSE);

                  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     FND_MESSAGE.SET_NAME('CS', 'CS_CHG_TM_LBR_SCHEDULE_API_ERR');
                     FND_MESSAGE.SET_TOKEN('TEXT', x_msg_data);
                     FND_MSG_PUB.ADD;
                     RAISE EXCP_USER_DEFINED;
                  END IF;

		  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
		  THEN
		    FND_LOG.String
		    ( FND_LOG.level_statement
		    , L_LOG_MODULE, 'x_tm_coverage_tbl.count = ' || x_tm_coverage_tbl.count
		    );
		  END IF;
		  --DBMS_OUTPUT.PUT_LINE('x_tm_coverage_tbl.count = ' || x_tm_coverage_tbl.count);

                  -- Calling Charges API to create labor charge lines.
	              FOR j in 1..x_tm_coverage_tbl.count LOOP

                     l_charges_rec.inventory_item_id_in := x_tm_coverage_tbl(j).inventory_item_id;
                     l_charges_rec.activity_start_time := x_tm_coverage_tbl(j).labor_start_date_time;

                     -- add one minute back for last minute coverage of a day
                     --IF to_char(x_tm_coverage_tbl(j).labor_end_date_time, 'HH24:MI') = '23:59' then
                     IF to_char(x_tm_coverage_tbl(j).labor_end_date_time, 'HH24:MI') = '23:59' AND
                        l_add_one_minute = 'Y' THEN
                        l_charges_rec.activity_end_time := x_tm_coverage_tbl(j).labor_end_date_time + (1 / (24 * 60));
                     ELSE
                        l_charges_rec.activity_end_time := x_tm_coverage_tbl(j).labor_end_date_time;
                     END IF;

                     -- Calculate labor quantity.
       	             l_duration := (l_charges_rec.activity_end_time
                                   - l_charges_rec.activity_start_time) * 24;

                     get_primary_uom(l_charges_rec.inventory_item_id_in, l_primary_uom);
                     l_charges_rec.unit_of_measure_code := l_primary_uom;
       	             l_charges_rec.quantity_required := inv_convert.inv_um_convert(
                        Null, 2, l_duration, l_base_uom, l_primary_uom, NULL, NULL);
                     l_charges_rec.list_price := NULL;
                     l_charges_rec.con_pct_over_list_price := NULL;

	  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
	  THEN
	    FND_LOG.String
	    ( FND_LOG.level_statement
	    , L_LOG_MODULE, '- TM Labor Coverage.'
	    );
	    FND_LOG.String
	    ( FND_LOG.level_statement
	    , L_LOG_MODULE, 'x_tm_coverage_tbl('||j||').inventory_item_id = ' || x_tm_coverage_tbl('||j||').inventory_item_id
	    );
	    FND_LOG.String
	    ( FND_LOG.level_statement
	    , L_LOG_MODULE, 'x_tm_coverage_tbl('||j||').labor_start_date_time = ' || TO_CHAR(x_tm_coverage_tbl(j).labor_start_date_time, 'DD-MON-YYYY HH24:MI:SS')
	    );
	    FND_LOG.String
	    ( FND_LOG.level_statement
	    , L_LOG_MODULE, 'x_tm_coverage_tbl('||j||').labor_end_date_time = ' || TO_CHAR(x_tm_coverage_tbl(j).labor_end_date_time, 'DD-MON-YYYY HH24:MI:SS')
	    );
	    FND_LOG.String
	    ( FND_LOG.level_statement
	    , L_LOG_MODULE, 'l_charges_rec.activity_end_time = ' || TO_CHAR(l_charges_rec.activity_end_time, 'DD-MON-YYYY HH24:MI:SS')
	    );
	    FND_LOG.String
	    ( FND_LOG.level_statement
	    , L_LOG_MODULE, 'l_charges_rec.unit_of_measure_code = ' || l_charges_rec.unit_of_measure_code
	    );
	    FND_LOG.String
	    ( FND_LOG.level_statement
	    , L_LOG_MODULE, 'l_charges_rec.quantity_required = ' || l_charges_rec.quantity_required
	    );
	    FND_LOG.String
	    ( FND_LOG.level_statement
	    , L_LOG_MODULE, 'l_charges_rec.list_price  = ' || l_charges_rec.list_price
	    );
	    FND_LOG.String
	    ( FND_LOG.level_statement
	    , L_LOG_MODULE, 'l_charges_rec.con_pct_over_list_price = ' || l_charges_rec.con_pct_over_list_price
	    );
	  END IF;
		     --DBMS_OUTPUT.PUT_LINE('- TM Labor Coverage.');
                     --DBMS_OUTPUT.PUT_LINE('x_tm_coverage_tbl('||j||').inventory_item_id = ' || x_tm_coverage_tbl(j).inventory_item_id);
                     --DBMS_OUTPUT.PUT_LINE('x_tm_coverage_tbl('||j||').labor_start_date_time = ' || TO_CHAR(x_tm_coverage_tbl(j).labor_start_date_time, 'DD-MON-YYYY HH24:MI:SS'));
                     --DBMS_OUTPUT.PUT_LINE('x_tm_coverage_tbl('||j||').labor_end_date_time = ' || TO_CHAR(x_tm_coverage_tbl(j).labor_end_date_time, 'DD-MON-YYYY HH24:MI:SS'));
                     --DBMS_OUTPUT.PUT_LINE('l_charges_rec.activity_end_time = ' || TO_CHAR(l_charges_rec.activity_end_time, 'DD-MON-YYYY HH24:MI:SS'));
                     --DBMS_OUTPUT.PUT_LINE('l_charges_rec.unit_of_measure_code = ' || l_charges_rec.unit_of_measure_code);
                     --DBMS_OUTPUT.PUT_LINE('l_charges_rec.quantity_required = ' || l_charges_rec.quantity_required);
                     --DBMS_OUTPUT.PUT_LINE('l_charges_rec.list_price = ' || l_charges_rec.list_price);
                     --DBMS_OUTPUT.PUT_LINE('l_charges_rec.con_pct_over_list_price = ' || l_charges_rec.con_pct_over_list_price);

	if l_cost_flag ='Y' and l_charge_flag ='Y' then
	    l_create_cost_detail := 'Y';
	else
	     l_create_cost_detail :='N';
	end if;

                     -- Create charge line.
                     cs_charge_details_pub.Create_Charge_Details(
                        p_api_version => p_api_version_number,
                        p_init_msg_list => FND_API.G_FALSE,
                        p_commit => p_commit,
                        p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                        x_return_status => x_return_status,
                        x_msg_count => x_msg_count,
                        x_object_version_number => x_object_version_number,
                        x_msg_data => x_msg_data,
                        x_estimate_detail_id => x_estimate_detail_id,
                        x_line_number => x_line_number,
                        p_Charges_Rec => l_charges_rec,
			p_create_cost_detail =>l_create_cost_detail, --Added for Service Costing
			x_cost_id =>x_cost_id);
                     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        FND_MESSAGE.SET_NAME('CS', 'CS_CHG_CHARGE_DETAILS_API_ERR');
                        FND_MSG_PUB.ADD;
                        RAISE EXCP_USER_DEFINED;
                     END IF;

                  END LOOP;

               END IF;

            END LOOP;

         ELSE  -- No contract.

	  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
	  THEN
	    FND_LOG.String
	    ( FND_LOG.level_statement, L_LOG_MODULE, '-- No contract.  Calling TM Labor Coverage...'
	    );
	  END IF;
	    --DBMS_OUTPUT.PUT_LINE('-- No contract.  Calling TM Labor Coverage...');

            -- Get TM labor schedule for those not covered by contract.
            cs_tm_labor_schedule_pvt.get_labor_coverages(
               p_business_process_id => p_sbe_record.business_process_id,
               p_activity_start_date_time => l_activity_start_date_time,
               p_activity_end_date_time => l_activity_end_date_time,
               x_labor_coverage_tbl => x_tm_coverage_tbl,
               x_return_status => x_return_status,
               x_msg_count => x_msg_count,
               x_msg_data => x_msg_data,
               p_api_version => p_api_version_number,
               p_init_msg_list => FND_API.G_FALSE);

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               FND_MESSAGE.SET_NAME('CS', 'CS_CHG_TM_LBR_SCHEDULE_API_ERR');
               FND_MESSAGE.SET_TOKEN('TEXT', x_msg_data);
               FND_MSG_PUB.ADD;
               RAISE EXCP_USER_DEFINED;
            END IF;

	  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
	  THEN
	    FND_LOG.String
	    ( FND_LOG.level_statement, L_LOG_MODULE || 'x_tm_coverage_tbl.count = '
	    , x_tm_coverage_tbl.count
	    );
	  END IF;
	    --DBMS_OUTPUT.PUT_LINE('x_tm_coverage_tbl.count = ' || x_tm_coverage_tbl.count);

            -- Calling Charges API to create labor charge lines.
	        FOR j in 1..x_tm_coverage_tbl.count LOOP

               l_charges_rec.inventory_item_id_in := x_tm_coverage_tbl(j).inventory_item_id;
               l_charges_rec.activity_start_time := x_tm_coverage_tbl(j).labor_start_date_time;

               -- add one minute back for last minute coverage of a day
               --IF to_char(x_tm_coverage_tbl(j).labor_end_date_time, 'HH24:MI') = '23:59' then
               IF to_char(x_tm_coverage_tbl(j).labor_end_date_time, 'HH24:MI') = '23:59' AND
                  l_add_one_minute = 'Y' THEN
                  l_charges_rec.activity_end_time := x_tm_coverage_tbl(j).labor_end_date_time + (1 / (24 * 60));
               ELSE
                  l_charges_rec.activity_end_time := x_tm_coverage_tbl(j).labor_end_date_time;
               END IF;

               -- Calculate labor quantity.
       	       l_duration := (l_charges_rec.activity_end_time
                             - l_charges_rec.activity_start_time) * 24;

               get_primary_uom(l_charges_rec.inventory_item_id_in, l_primary_uom);
               l_charges_rec.unit_of_measure_code := l_primary_uom;
       	       l_charges_rec.quantity_required := inv_convert.inv_um_convert(
                  Null, 2, l_duration, l_base_uom, l_primary_uom, NULL, NULL);
               l_charges_rec.list_price := NULL;
               l_charges_rec.con_pct_over_list_price := NULL;

	  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
	  THEN
	    FND_LOG.String
	    ( FND_LOG.level_statement
	    , L_LOG_MODULE, 'x_tm_coverage_tbl('||j||').inventory_item_id = ' || x_tm_coverage_tbl('||j||').inventory_item_id
	    );
	    FND_LOG.String
	    ( FND_LOG.level_statement
	    , L_LOG_MODULE, 'x_tm_coverage_tbl('||j||').labor_start_date_time = ' || TO_CHAR(x_tm_coverage_tbl(j).labor_start_date_time, 'DD-MON-YYYY HH24:MI:SS')
	    );
	    FND_LOG.String
	    ( FND_LOG.level_statement
	    , L_LOG_MODULE, 'x_tm_coverage_tbl('||j||').labor_end_date_time = ' || TO_CHAR(x_tm_coverage_tbl(j).labor_end_date_time, 'DD-MON-YYYY HH24:MI:SS')
	    );
	    FND_LOG.String
	    ( FND_LOG.level_statement
	    , L_LOG_MODULE, 'l_charges_rec.activity_end_time = ' ||TO_CHAR(l_charges_rec.activity_end_time, 'DD-MON-YYYY HH24:MI:SS')
	    );
	    FND_LOG.String
	    ( FND_LOG.level_statement
	    , L_LOG_MODULE, 'l_charges_rec.unit_of_measure_code = ' || l_charges_rec.unit_of_measure_code
	    );
	    FND_LOG.String
	    ( FND_LOG.level_statement
	    , L_LOG_MODULE, 'l_charges_rec.quantity_required = ' || l_charges_rec.quantity_required
	    );
	    FND_LOG.String
	    ( FND_LOG.level_statement
	    , L_LOG_MODULE, 'l_charges_rec.list_price  = ' || l_charges_rec.list_price
	    );
	    FND_LOG.String
	    ( FND_LOG.level_statement
	    , L_LOG_MODULE, 'l_charges_rec.con_pct_over_list_price = ' || l_charges_rec.con_pct_over_list_price
	    );
	  END IF;
	       --DBMS_OUTPUT.PUT_LINE('x_tm_coverage_tbl('||j||').inventory_item_id = ' || x_tm_coverage_tbl(j).inventory_item_id);
               --DBMS_OUTPUT.PUT_LINE('x_tm_coverage_tbl('||j||').labor_start_date_time = ' || TO_CHAR(x_tm_coverage_tbl(j).labor_start_date_time, 'DD-MON-YYYY HH24:MI:SS'));
               --DBMS_OUTPUT.PUT_LINE('x_tm_coverage_tbl('||j||').labor_end_date_time = ' || TO_CHAR(x_tm_coverage_tbl(j).labor_end_date_time, 'DD-MON-YYYY HH24:MI:SS'));
               --DBMS_OUTPUT.PUT_LINE('l_charges_rec.activity_end_time = ' || TO_CHAR(l_charges_rec.activity_end_time, 'DD-MON-YYYY HH24:MI:SS'));
               --DBMS_OUTPUT.PUT_LINE('l_charges_rec.unit_of_measure_code = ' || l_charges_rec.unit_of_measure_code);
               --DBMS_OUTPUT.PUT_LINE('l_charges_rec.quantity_required = ' || l_charges_rec.quantity_required);
               --DBMS_OUTPUT.PUT_LINE('l_charges_rec.list_price = ' || l_charges_rec.list_price);
               --DBMS_OUTPUT.PUT_LINE('l_charges_rec.con_pct_over_list_price = ' || l_charges_rec.con_pct_over_list_price);


	if l_cost_flag ='Y' and l_charge_flag ='Y' then
	    l_create_cost_detail := 'Y';
	else
	     l_create_cost_detail :='N';
	end if;

               -- Create charge line.
               cs_charge_details_pub.Create_Charge_Details(
                  p_api_version => p_api_version_number,
                  p_init_msg_list => FND_API.G_FALSE,
                  p_commit => p_commit,
                  p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                  x_return_status => x_return_status,
                  x_msg_count => x_msg_count,
                  x_object_version_number => x_object_version_number,
                  x_msg_data => x_msg_data,
                  x_estimate_detail_id => x_estimate_detail_id,
                  x_line_number => x_line_number,
                  p_Charges_Rec => l_charges_rec,
		  p_create_cost_detail =>l_create_cost_detail, --Added for Service Costing
		  x_cost_id =>x_cost_id);

		 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  FND_MESSAGE.SET_NAME('CS', 'CS_CHG_CHARGE_DETAILS_API_ERR');
                  FND_MSG_PUB.ADD;
                  RAISE EXCP_USER_DEFINED;
               END IF;

            END LOOP;

         END IF;

         l_activity_start_date_time := trunc(l_activity_start_date_time) + 1;

      END LOOP;

ELSE -- Inventory item is specified.

      -- bugfix#5443461
      OPEN get_billing_category(p_sbe_record.txn_billing_type_id);
      FETCH get_billing_category
      INTO  l_billing_category;
      CLOSE get_billing_category;

       -- Bug 7229344
      OPEN billing_category;
      FETCH billing_category into l_bill_category;
      CLOSE billing_category;
      -- End bug 7229344


  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , '--- p_sbe_record.inventory_item_id is not null.'
    );
  END IF;
      -- DBMS_OUTPUT.PUT_LINE('--- p_sbe_record.inventory_item_id is not null.');

      --dbms_output.put_line('--- Checking for Single Rate Type.');
      --Added for SIMPLEX Enhancement for Defaulting Rate Type
      --Check to see if there is a single rate defined for the inventory item
      --Bug # 5136865

      -- Get transaction billing type for service debrief labor activity that without labor inventory item specified.
      --
      IF l_charges_rec.transaction_type_id IS NOT NULL THEN
         OPEN txn_billing_type_csr(l_charges_rec.transaction_type_id,l_bill_category); -- Bug 7229344
         FETCH txn_billing_type_csr into l_charges_rec.txn_billing_type_id;
         CLOSE txn_billing_type_csr;
      END IF;

      --dbms_output.put_line('l_charges_rec.txn_billing_type_id'||l_charges_rec.txn_billing_type_id);
      --dbms_output.put_line('l_charges_rec.txn_billing_type_id'||l_charges_rec.txn_billing_type_id);
      --dbms_output.put_line('l_charges_rec.coverage_txn_group_id'||l_charges_rec.coverage_txn_group_id);

      IF l_charges_rec.txn_billing_type_id IS NOT NULL AND
         l_charges_rec.business_process_id IS NOT NULL THEN
         FOR v_get_rate_type in get_rate_type( l_charges_rec.contract_line_id,
                                               l_charges_rec.txn_billing_type_id,
                                               l_charges_rec.business_process_id)
         LOOP
           --dbms_output.put_line('In the loop');
           k := k + 1;
           l_charges_rec.rate_type_code := v_get_rate_type.rate_code;
           l_rate_amount := v_get_rate_type.rate_amount;
           l_rate_percent := v_get_rate_type.rate_percent;
           l_rate_uom := v_get_rate_type.rate_uom;
           IF k > 1 THEN
             EXIT;
           END IF;
         END LOOP;

         ----dbms_output.put_line('k ='||k);
         IF k > 1 THEN
           l_charges_rec.rate_type_code := NULL ;
           l_rate_amount := NULL;
           l_rate_percent := NULL;
           l_rate_uom := NULL;
         ELSE
           IF l_rate_uom <> p_sbe_record.unit_of_measure_code THEN
             -- reset the rate fields from contract
             -- no rate will be defaulted from contract
             l_charges_rec.rate_type_code := NULL ;
             l_rate_amount := NULL;
             l_rate_percent := NULL;
             l_rate_uom := NULL;
           END IF;
         END IF;
      ELSE
         --txn_billing_type_id IS NULL and
         --business_process_id IS NULL
         l_charges_rec.rate_type_code := NULL ;
      END IF;


      l_charges_rec.inventory_item_id_in := p_sbe_record.inventory_item_id;
      l_charges_rec.quantity_required := p_sbe_record.quantity;
      l_charges_rec.unit_of_measure_code := p_sbe_record.unit_of_measure_code;
      -- l_charges_rec.list_price := p_sbe_record.after_warranty_cost;
      -- l_charges_rec.con_pct_over_list_price := NULL;
      -- l_charges_rec.after_warranty_cost := p_sbe_record.after_warranty_cost;


    --check if flat rate is vailable
    -- Fix for the bug:5136865
      IF l_rate_amount IS NOT NULL THEN
        l_charges_rec.list_price := l_rate_amount;
      ELSE
        l_charges_rec.list_price := NULL;
      END IF;

      -- check if %over list price is vailable
      IF l_rate_percent IS NOT NULL THEN
        l_charges_rec.con_pct_over_list_price := l_rate_percent;
      ELSE
        l_charges_rec.con_pct_over_list_price := NULL;
      END IF;

      -- If both not avaible then then assign after warranty cost to list price.
      IF l_rate_amount IS NULL AND
         l_rate_percent IS NULL THEN
         l_charges_rec.list_price := p_sbe_record.after_warranty_cost;
         l_charges_rec.con_pct_over_list_price := NULL;
      END IF;

      -- If expense line is passed by debrief with after_warranty_cost. Part of bugfix#5443461
      -- Bug 7257903, use l_bill_category instead of l_billing_category
      IF l_bill_category = 'E' AND
         p_sbe_record.after_warranty_cost IS NOT NULL THEN
           l_charges_rec.after_warranty_cost := p_sbe_record.after_warranty_cost;
      END IF;

      -- Create charge line.
      cs_charge_details_pub.Create_Charge_Details(
         p_api_version => p_api_version_number,
         p_init_msg_list => FND_API.G_FALSE,
         p_commit => p_commit,
         p_validation_level => FND_API.G_VALID_LEVEL_FULL,
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_object_version_number => x_object_version_number,
         x_msg_data => x_msg_data,
         x_estimate_detail_id => x_estimate_detail_id,
         x_line_number => x_line_number,
         p_Charges_Rec => l_charges_rec,
	  p_create_cost_detail =>'N',
	  x_cost_id =>x_cost_id);

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            FND_MESSAGE.SET_NAME('CS', 'CS_CHG_CHARGE_DETAILS_API_ERR');
            FND_MSG_PUB.ADD;
            RAISE EXCP_USER_DEFINED;
         END IF;

END IF;     -- inventory_item_id check

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE, '----- Private API:' || g_pkg_name || '.' || l_api_name || ' ends at ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SSSSS')
    );
  END IF;
   --DBMS_OUTPUT.PUT_LINE('----- Private API: ' || g_pkg_name || '.' || l_api_name || ' ends at ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SSSSS'));
   --DBMS_OUTPUT.PUT_LINE('Return status = ' || x_return_status);

   -- Commit if p_commit is true.
   IF FND_API.to_Boolean(p_commit) THEN
      COMMIT;
   END IF;

   -- Exception Block
   EXCEPTION
      WHEN EXCP_USER_DEFINED THEN
         Rollback to Create_Charges;
         x_return_status := FND_API.G_RET_STS_ERROR;
         fnd_msg_pub.count_and_get(
            p_count   => x_msg_count
           ,p_data    => x_msg_data);
      WHEN FND_API.G_EXC_ERROR THEN
         JTF_PLSQL_API.HANDLE_EXCEPTIONS(
            P_API_NAME => L_API_NAME
           ,P_PKG_NAME => G_PKG_NAME
           ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
           ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
           ,X_MSG_COUNT    => x_MSG_COUNT
           ,X_MSG_DATA     => x_MSG_DATA
           ,X_RETURN_STATUS => x_RETURN_STATUS);
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         JTF_PLSQL_API.HANDLE_EXCEPTIONS(
            P_API_NAME => L_API_NAME
           ,P_PKG_NAME => G_PKG_NAME
           ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
           ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
           ,X_MSG_COUNT    => x_MSG_COUNT
           ,X_MSG_DATA     => x_MSG_DATA
           ,X_RETURN_STATUS => x_RETURN_STATUS);
      WHEN OTHERS THEN
         Rollback to Create_Charges;
         FND_MESSAGE.SET_NAME('CS', 'CS_CHG_UNEXPECTED_EXEC_ERRORS');
         FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name);
         FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm);
         FND_MSG_PUB.ADD;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data  => x_msg_data);
         x_return_status := FND_API.G_RET_STS_ERROR;

END Create_Charges;


-------------------------------------------------------------------------
-- Delete all Billing Engine generated in progress charges for the service request (p_incident_id) passed in.

PROCEDURE Delete_In_Progress_Charges(
   P_Api_Version_Number    IN NUMBER,
   P_Init_Msg_List         IN VARCHAR2 := FND_API.G_FALSE,
   P_Commit                IN VARCHAR2 := FND_API.G_FALSE,
   p_incident_id           IN NUMBER,
   p_debrief_header_id     IN NUMBER := NULL,  -- Enhancement 2983340
   p_debrief_line_id       IN NUMBER := NULL,  -- To make the API backward compatible
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2)
IS

   l_api_name              CONSTANT VARCHAR2(30) := 'Delete_In_Progress_Charges';
   l_api_version_number    CONSTANT NUMBER   := 1.0;
   l_api_name_full         CONSTANT VARCHAR2(61)  :=  G_PKG_NAME || '.' || l_api_name ;
   l_log_module            CONSTANT VARCHAR2(255) := 'cs.plsql.' || l_api_name_full || '.';

   EXCP_USER_DEFINED       EXCEPTION;

   l_estimate_detail_id    NUMBER;

   -- Enhancement 2983340 CURSOR in_progress_charges_csr(p_incident_id number) IS
   CURSOR in_progress_charges_csr(p_incident_id number, p_debrief_header_id number) IS -- Enhancement 2983340
      SELECT estimate_detail_id
        FROM cs_estimate_details
       WHERE incident_id = p_incident_id
         and source_code = 'SD' -- Enhancement 2983340
         and source_id in (select debrief_line_id from csf_debrief_lines where debrief_header_id = nvl(p_debrief_header_id, debrief_header_id))  -- Enhancement 2983340
         -- Fix bug 3137168 and generated_by_bca_engine_flag = 'Y'
         and charge_line_type = 'IN_PROGRESS';

   --Added to Fix Bug # 3539583
   CURSOR in_progress_charge_csr(p_incident_id number, p_debrief_line_id number) IS -- Enhancement 2983340
      SELECT estimate_detail_id
        FROM cs_estimate_details
       WHERE incident_id = p_incident_id
         and source_code = 'SD' -- Enhancement 2983340
         and source_id in (select debrief_line_id from csf_debrief_lines where debrief_line_id = nvl(p_debrief_line_id, debrief_line_id))  -- Enhancement 2983340
         and charge_line_type = 'IN_PROGRESS';


BEGIN
   SAVEPOINT Delete_In_Progress_Charges;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                      	               p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(p_init_msg_list)
   THEN
      FND_MSG_PUB.initialize;
   END IF;

----------------------- FND Logging -----------------------------------
  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || 'start'
    , 'Inside ' || L_API_NAME_FULL || ', called with parameters below:'
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'P_Api_Version_Number:' || P_Api_Version_Number
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_init_msg_list:' || p_init_msg_list
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_commit:' || p_commit
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_incident_id:' || p_incident_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_debrief_header_id:' || p_debrief_header_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_debrief_line_id:' || p_debrief_line_id
    );
  END IF;

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , '----- Private API:'
    || g_pkg_name || '.' || l_api_name || ' starts at ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS')
    );
  END IF;
   --DBMS_OUTPUT.PUT_LINE('----- Private API: ' || g_pkg_name || '.' || l_api_name || ' starts at ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
   --DBMS_OUTPUT.PUT_LINE('p_incident_id = ' || p_incident_id);

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --Added to Fix Bug # 3539583
   IF p_debrief_line_id IS NOT NULL THEN

     OPEN in_progress_charge_csr(p_incident_id, p_debrief_line_id);
     FETCH in_progress_charge_csr into l_estimate_detail_id;
     CLOSE in_progress_charge_csr;

     IF l_estimate_detail_id IS NOT NULL THEN

       cs_charge_details_pub.Delete_Charge_Details(
                            p_api_version        => p_api_version_number,
                            p_init_msg_list      => FND_API.G_FALSE,
                            p_commit             => p_commit,
                            x_return_status      => x_return_status,
                            x_msg_count          => x_msg_count,
                            x_msg_data           => x_msg_data,
                            p_estimate_detail_id => l_estimate_detail_id,
			     p_delete_cost_detail =>'N');

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          CLOSE in_progress_charges_csr;
          FND_MESSAGE.SET_NAME('CS', 'CS_CHG_DLT_IN_PROGRESS_CHRG_ER');
          FND_MESSAGE.SET_TOKEN('TEXT', x_msg_data);
          FND_MSG_PUB.ADD;
          RAISE EXCP_USER_DEFINED;
        END IF;

     END IF;

   ELSE
     -- p_debrief_line_id is null
     -- delete all in progress charges for a service request
     -- Enhancement 2983340 OPEN in_progress_charges_csr(p_incident_id);
     OPEN in_progress_charges_csr(p_incident_id, p_debrief_header_id); -- Enhancement 2983340
     LOOP
        FETCH in_progress_charges_csr into l_estimate_detail_id;
        EXIT WHEN in_progress_charges_csr%NOTFOUND;

	  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
	  THEN
	    FND_LOG.String
	    ( FND_LOG.level_statement, L_LOG_MODULE || 'Delete l_estimate_detail_id = '
	    , l_estimate_detail_id
	    );
	  END IF;
	--DBMS_OUTPUT.PUT_LINE('Delete l_estimate_detail_id = ' || l_estimate_detail_id);

        cs_charge_details_pub.Delete_Charge_Details(
          p_api_version => p_api_version_number,
          p_init_msg_list => FND_API.G_FALSE,
          p_commit => p_commit,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_estimate_detail_id => l_estimate_detail_id,
	   p_delete_cost_detail =>'N');

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          CLOSE in_progress_charges_csr;
          FND_MESSAGE.SET_NAME('CS', 'CS_CHG_DLT_IN_PROGRESS_CHRG_ER');
          FND_MESSAGE.SET_TOKEN('TEXT', x_msg_data);
          FND_MSG_PUB.ADD;
          RAISE EXCP_USER_DEFINED;
        END IF;

     END LOOP;
     CLOSE in_progress_charges_csr;
   END IF;

     -- Commit if p_commit is TRUE.
     IF FND_API.to_Boolean(p_commit) THEN
       COMMIT;
     END IF;

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE || 'Private API:'
    , g_pkg_name || '.' || l_api_name || ' ends at ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS')
    );
  END IF;
   --DBMS_OUTPUT.PUT_LINE('Private API: ' || g_pkg_name || '.' || l_api_name || ' ends at ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
   --DBMS_OUTPUT.PUT_LINE('Return status = ' || x_return_status);

   -- Exception Block
   EXCEPTION
      WHEN EXCP_USER_DEFINED THEN
         Rollback to Delete_In_Progress_Charges;
         x_return_status := FND_API.G_RET_STS_ERROR;
         fnd_msg_pub.count_and_get(
            p_count   => x_msg_count
           ,p_data    => x_msg_data);
      WHEN FND_API.G_EXC_ERROR THEN
         JTF_PLSQL_API.HANDLE_EXCEPTIONS(
            P_API_NAME => L_API_NAME
           ,P_PKG_NAME => G_PKG_NAME
           ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
           ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
           ,X_MSG_COUNT    => x_MSG_COUNT
           ,X_MSG_DATA     => x_MSG_DATA
           ,X_RETURN_STATUS => x_RETURN_STATUS);
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         JTF_PLSQL_API.HANDLE_EXCEPTIONS(
            P_API_NAME => L_API_NAME
           ,P_PKG_NAME => G_PKG_NAME
           ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
           ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
           ,X_MSG_COUNT    => x_MSG_COUNT
           ,X_MSG_DATA     => x_MSG_DATA
           ,X_RETURN_STATUS => x_RETURN_STATUS);
      WHEN OTHERS THEN
         Rollback to Delete_In_Progress_Charges;
         FND_MESSAGE.SET_NAME('CS', 'CS_CHG_UNEXPECTED_EXEC_ERRORS');
         FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name);
         FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm);
         FND_MSG_PUB.ADD;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data  => x_msg_data);
         x_return_status := FND_API.G_RET_STS_ERROR;

END Delete_In_Progress_Charges;

End CS_Service_Billing_Engine_PVT;


/
