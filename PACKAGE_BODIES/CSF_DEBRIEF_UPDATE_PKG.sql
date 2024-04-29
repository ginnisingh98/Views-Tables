--------------------------------------------------------
--  DDL for Package Body CSF_DEBRIEF_UPDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_DEBRIEF_UPDATE_PKG" as
/* $Header: csfuppdb.pls 120.11.12010000.6 2010/03/02 18:23:16 hhaugeru ship $ */

-- Start of Comments
-- Package name     : CSF_DEBRIEF_UPDATE_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSF_DEBRIEF_UPDATE_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csfuppdb.pls';
G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
G_UPDATE          NUMBER := 1;
G_CREATE          NUMBER := 2;

RECORD_LOCK_EXCEPTION EXCEPTION ;
PRAGMA EXCEPTION_INIT(RECORD_LOCK_EXCEPTION,-00054);

PROCEDURE Record_Lock
(p_debrief_line_id  IN Number,
x_return_status     OUT NOCOPY  VARCHAR2
) is
  l_charge_upload_status            Varchar2(50);
  l_ib_update_status                Varchar2(50);
  l_spare_update_status             Varchar2(50);
Begin
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    select charge_upload_status,ib_update_status,spare_update_status
    into   l_charge_upload_status,l_ib_update_status,l_spare_update_status
    from   csf_debrief_lines
    where  debrief_line_id = p_debrief_line_id
    for update nowait;
Exception
    WHEN RECORD_LOCK_EXCEPTION THEN
         x_return_status := FND_API.G_RET_STS_ERROR ;
    When OTHERS then
         x_return_status := FND_API.G_RET_STS_ERROR ;
End;

PROCEDURE main
(
    errbuf                  OUT NOCOPY VARCHAR2,
    retcode                 OUT NOCOPY NUMBER,
    p_api_version           IN  NUMBER,
    p_debrief_header_id	    IN  NUMBER DEFAULT null,
    p_incident_id           IN  NUMBER DEFAULT null
) IS

  l_api_name            CONSTANT    VARCHAR2(30)   := 'main';
  l_api_version         CONSTANT    NUMBER         := 1.0;
  l_transaction_type_id             Number;
  l_debrief_line_id                 number          ;
  l_debrief_header_id               number          ;
  l_original_source_id              number          ;
  l_original_source_code            varchar2(10):= 'SR';
  l_incident_id                     number          ;
  l_business_process_id             number          ;
  l_line_category_code              varchar2(10)    ;
  l_return_status                   varchar2(1)     ;
  l_msg_count                       number          ;
  l_msg_data                        varchar2(2000)  ;
  l_rec_status                      varchar2(10)    ;
  l_charges_interface_status        varchar2(20)    := null;
  l_ib_interface_status             varchar2(20)    := null;
  l_inv_interface_status            varchar2(20)    := null;
  l_interface_status_meaning        varchar2(20)    ;
  l_inventory_item_id               number          ;
  l_currency_code                   varchar2(30)    ;
  l_uom_code                        varchar2(3)     ;
  l_quantity                        number      := 0;
  l_customer_id                     number          ;
  l_txn_billing_type                number          ;
  l_installed_cp_return_by_date     DATE            ;
  l_after_warranty_cost             Number       := 0;
  counter 	                        Number          ;
  l_time_diff 	                    Number          ;
  l_profile_hours  	                Varchar2(20)    ;
  l_return_reason_code              Varchar2(30) := null;
  l_qty                             Number          ; --to_number(name_in('csf_debrief_labor_lines.quantity'));
  l_revision                        varchar2(3)     ;
  l_source_type_code                Varchar2(10)    ;
  l_repair_line_id                  Number          ;
  l_service_date                    Date            ;
  l_date_type                       varchar2(30) := fnd_profile.value('CSF_DEBRIEF_TRANSACTION_DATE');
  l_txn_billing_type_id             Number          ;
  l_inv_transaction_type_id         Number          ;
  l_organization_id                 Number          ;
  l_issuing_inventory_org_id        Number          ;
  l_receiving_inventory_org_id      Number          ;
  l_subinventory_code               Varchar2(50)    ;
  l_issuing_sub_inventory_code      Varchar2(50)    ;
  l_receiving_sub_inventory_code    Varchar2(50)    ;
  l_locator_id                      Number          ;
  l_issuing_locator_id              Number          ;
  l_receiving_locator_id            Number          ;
  l_parent_product_id               Number          ;
  l_item_serial_number              Varchar2(30)    ;
  l_item_lotnumber                  Varchar2(120)    ;
  l_labor_start_date                Date            ;
  l_labor_end_date                  Date            ;
  l_expense_amount                  Number          ;
  l_charge_upload_status            Varchar2(50) := null   ;
  l_ib_update_status                Varchar2(50)    ;
  l_spare_update_status             Varchar2(50)    ;
  l_instance_id                     Number          ;
  l_removed_product_id              Number          ;
  l_billing_type                    Varchar2(3)     ;
  l_debrief_number                  Varchar2(50)    ;
  l_inv_transaction_header_id       Number          ;
  l_inv_transaction_id              Number          ;
  l_mesg                            Varchar2(2000)  ;
  l_msg_dummy                       Number          ;
  l_transaction_type_id_csi         Number          ;
  l_txn_sub_type_id                 Number          ;
  l_inv_master_organization_id      Number  :=fnd_api.g_miss_num;
  l_customer_account_id             Number          ;
  l_party_id                        Number          ;
  l_install_site_use_id             Number          ;
  l_ship_site_use_id                Number          ;
  l_in_out_flag                     Varchar2(10)    ;
  l_party_site_id                   Number          ;
  l_new_instance_id                 Number          ;
  l_message                         Varchar2(1000)  ;
  l1                                Number          ;
  l_trackable                       Varchar2(1)     ;
  l_processed_flag                  Varchar2(50)    ;
  l_charges_instance_id             Number          ;
  l_task_assignment_id              Number          ;
  l_cancelled_flag                  Varchar2(1)     ;
  l_rejected_flag                   Varchar2(1)     ;
  l_completed_flag                  Varchar2(1)     ;
  l_closed_flag                     Varchar2(1)     ;
  l_cleanup_done                    Boolean         := FALSE;
  l_position                        Number;
  l_instance_status                 Varchar(30)  :=NULL; --added for bug 3192060
  l_instance_status_id              Number :=9.99E125 ;--fnd_api.g_miss_num --added for bug3192060
  l_header_id			    Number; -- added for 3264030
  l_record_lock			    Varchar2(1) := 'N'; -- added for bug 3142094
  l_conc_result			    Boolean;
  e_no_header_id                    Exception;
  l_item_operational_status_code         Varchar2(30);
  l_create_charge_flag              varchar2(1);
  l_create_cost_flag                varchar2(1);
  l_Cost_Rec         cs_cost_details_pub.Cost_Rec_Type ;
  l_object_version   number;
  l_cost_id          number;
  l_estimate_detail_id              number := null;

  cursor c_charge_id(p_debrief_line_id number) is
         select estimate_detail_id
         from   cs_estimate_details
         where  source_code = 'SD'
         and    source_id = p_debrief_line_id;

  cursor c_lines (p_debrief_header_id Number) is
         select cdl.debrief_line_id,
                cdl.service_date,
                --cdl.txn_billing_type_id,
                cdl.transaction_type_id,
                cdl.inventory_item_id,
                cdl.issuing_inventory_org_id,
                cdl.receiving_inventory_org_id,
                cdl.issuing_sub_inventory_code,
                cdl.receiving_sub_inventory_code,
                cdl.issuing_locator_id,
                cdl.receiving_locator_id,
                cdl.parent_product_id,
                cdl.removed_product_id,
                cdl.item_serial_number,
                cdl.item_revision,
                cdl.item_lotnumber,
                cdl.uom_code,
                cdl.quantity,
                cdl.labor_start_date,
                cdl.labor_end_date,
                cdl.expense_amount,
                cdl.currency_code,
                cdl.charge_upload_status,
                cdl.ib_update_status,
                cdl.spare_update_status,
                cdl.business_process_id,
                cdl.return_reason_code,
                cdl.instance_id,
		cdl.status_of_received_part, --added for bug 3192060
                cdl.item_operational_status_code
         from   csf_debrief_lines cdl
         where cdl.debrief_header_id = p_debrief_header_id
	 and   nvl(cdl.quantity,-1) <> 0 ;

   cursor c_header (p_header_id  Number) is
 	SELECT cdh.debrief_header_id,
       		jtb.source_object_type_code source_type_code,
       		ciab.incident_id ,
       		to_number(null) repair_line_id,
       		ciab.customer_id,
       		ciab.account_id customer_account_id,
       		cdh.debrief_number ,
       		jta.task_assignment_id,
       		jtsb.cancelled_flag,
       		jtsb.rejected_flag,
       		jtsb.completed_flag,
       		jtsb.closed_flag
	from
       		JTF_TASK_STATUSES_B jtsb,
       		CSF_DEBRIEF_HEADERS cdh,
       		JTF_TASKS_B jtb,
       		JTF_TASK_ASSIGNMENTS jta,
       		cs_incidents_all_b ciab
	WHERE  cdh.task_assignment_id = jta.task_assignment_id
	and    jta.task_id = jtb.task_id
	and    nvl(jtb.deleted_flag,'N') <> 'Y'
	and    jta.assignment_status_id = jtsb.task_status_id
	and    jta.assignee_role = 'ASSIGNEE'
	and    jtb.source_object_type_code = 'SR'
	and    ciab.incident_id = jtb.source_object_id
	and    cdh.debrief_header_id = p_header_id   -- changed for the bug 3648213
	union all
	SELECT cdh.debrief_header_id,
       		jtb.source_object_type_code,
       		cr.incident_id,
       		cr.repair_line_id,
       		jtb.customer_id ,
       		jtb.cust_account_id, -- replaced -1 with jtb.cust_account_id for bug 3343984
       		cdh.debrief_number ,
       		jta.task_assignment_id,
       		jtsb.cancelled_flag,
       		jtsb.rejected_flag,
       		jtsb.completed_flag,
       		jtsb.closed_flag
	from
       		JTF_TASK_STATUSES_B jtsb,
       		CSF_DEBRIEF_HEADERS cdh,
       		JTF_TASKS_B jtb,
       		JTF_TASK_ASSIGNMENTS jta,
       		csd_repairs cr
	WHERE  cdh.task_assignment_id = jta.task_assignment_id
	and    jta.task_id = jtb.task_id
	and    nvl(jtb.deleted_flag,'N') <> 'Y'
	and    jta.assignment_status_id = jtsb.task_status_id
	and    jta.assignee_role = 'ASSIGNEE'
	and    jtb.source_object_type_code = 'DR'
	and    jtb.source_object_id=cr.repair_line_id
	and    cdh.debrief_header_id = p_header_id ;   -- changed for the bug 3648213

   cursor c_header_inc (p_incident_id  Number) is    -- added for the bug 3648213
 	SELECT cdh.debrief_header_id,
       		jtb.source_object_type_code source_type_code,
       		ciab.incident_id ,
       		to_number(null) repair_line_id,
       		ciab.customer_id,
       		ciab.account_id customer_account_id,
       		cdh.debrief_number ,
       		jta.task_assignment_id,
       		jtsb.cancelled_flag,
       		jtsb.rejected_flag,
       		jtsb.completed_flag,
       		jtsb.closed_flag
	from
       		JTF_TASK_STATUSES_B jtsb,
       		CSF_DEBRIEF_HEADERS cdh,
       		JTF_TASKS_B jtb,
       		JTF_TASK_ASSIGNMENTS jta,
       		cs_incidents_all_b ciab
	WHERE  cdh.task_assignment_id = jta.task_assignment_id
	and    jta.task_id = jtb.task_id
	and    nvl(jtb.deleted_flag,'N') <> 'Y'
	and    jta.assignment_status_id = jtsb.task_status_id
	and    jta.assignee_role = 'ASSIGNEE'
	and    jtb.source_object_type_code = 'SR'
	and    ciab.incident_id = jtb.source_object_id
	and    ciab.incident_id = p_incident_id
	and    cdh.debrief_header_id = nvl(p_debrief_header_id,cdh.debrief_header_id)
	union all
	SELECT cdh.debrief_header_id,
       		jtb.source_object_type_code,
       		cr.incident_id,
       		cr.repair_line_id,
       		jtb.customer_id ,
       		jtb.cust_account_id, -- replaced -1 with jtb.cust_account_id for bug 3343984
       		cdh.debrief_number ,
       		jta.task_assignment_id,
       		jtsb.cancelled_flag,
       		jtsb.rejected_flag,
       		jtsb.completed_flag,
       		jtsb.closed_flag
	from
       		JTF_TASK_STATUSES_B jtsb,
       		CSF_DEBRIEF_HEADERS cdh,
       		JTF_TASKS_B jtb,
       		JTF_TASK_ASSIGNMENTS jta,
       		csd_repairs cr
	WHERE  cdh.task_assignment_id = jta.task_assignment_id
	and    jta.task_id = jtb.task_id
	and    nvl(jtb.deleted_flag,'N') <> 'Y'
	and    jta.assignment_status_id = jtsb.task_status_id
	and    jta.assignee_role = 'ASSIGNEE'
	and    jtb.source_object_type_code = 'DR'
	and    jtb.source_object_id=cr.repair_line_id
	and    cr.incident_id = p_incident_id
	and    cdh.debrief_header_id = nvl(p_debrief_header_id,cdh.debrief_header_id);

-- changed above cursor for the bug 3264030

      Cursor c_headers is
             Select debrief_header_id
             From   csf_debrief_headers
             Where processed_flag is null or processed_flag <> 'COMPLETED';

/*   cursor c_header is
         select cdtv.debrief_header_id,
                cdtv.source_type_code,
                cdtv.incident_id,
                cdtv.repair_line_id,
                cdtv.customer_id,
                cdtv.customer_account_id,
                cdtv.debrief_number,
                cdtv.task_assignment_id,
                jtsv.cancelled_flag,
                jtsv.rejected_flag,
                jtsv.completed_flag,
                jtsv.closed_flag
         from   csf_debrief_tasks_v cdtv,
                jtf_task_assignments jta,
                jtf_task_statuses_vl jtsv
         where cdtv.debrief_header_id   = nvl(p_debrief_header_id, cdtv.debrief_header_id)
         and   cdtv.task_assignment_id  = jta.task_assignment_id
         and   jta.assignment_status_id = jtsv.task_status_id
         and   cdtv.incident_id = nvl(p_incident_id, cdtv.incident_id); */

   /*cursor c_trans (p_txn_billing_type_id number) is
         select cttv.line_order_category_code,
                cttv.transaction_type_id     ,
                ctbt.billing_type,
                ctst.sub_type_id  ,
                ctst.transaction_type_id   transaction_type_id_csi
           from cs_transaction_types_vl cttv,
                cs_txn_billing_types    ctbt,
                csi_txn_sub_types       ctst,
                csi_txn_types           ctt
         where  cttv.transaction_type_id     = ctbt.transaction_type_id
            and ctbt.txn_billing_type_id = p_txn_billing_type_id
            and ctst.cs_transaction_type_id = cttv.transaction_type_id
            and ctt.source_application_id=513
            and ctt.transaction_type_id = ctst.transaction_type_id;*/
--hehxx added create_cost and create_charge flags
    cursor c_cost_charge_flags (p_transaction_type_id number) is
    select create_cost_flag,
           create_charge_flag
    from   cs_transaction_types
    where  transaction_type_id = p_transaction_type_id;

    cursor c_trans (p_transaction_type_id number,
                    p_inventory_item_id   number,
                    p_inventory_org_id    number) is
         select cttv.line_order_category_code,
                ctbt.txn_billing_type_id     ,
                cbtc.billing_category billing_type,
                ctst.sub_type_id  ,
                ctst.transaction_type_id   transaction_type_id_csi
           from cs_transaction_types_vl cttv,
                cs_txn_billing_types    ctbt,
                csi_txn_sub_types       ctst,
                csi_txn_types           ctt,
                mtl_system_items_b_kfv  msibk,
                cs_billing_type_categories cbtc
         where  cttv.transaction_type_id     = p_transaction_type_id
            and cttv.transaction_type_id     = ctbt.transaction_type_id
            and ctbt.billing_type            = msibk.material_billable_flag
            and msibk.material_billable_flag = cbtc.billing_type
            and msibk.inventory_item_id      = p_inventory_item_id
            and msibk.organization_id        = p_inventory_org_id
            and ctst.cs_transaction_type_id(+)  = cttv.transaction_type_id
            and ctt.source_application_id(+)    = 513
            and ctt.transaction_type_id(+)      = ctst.transaction_type_id;

    Cursor c_internal_party_id  Is
           select internal_party_id
           from csi_install_parameters;

    cursor c_site (p_incident_id number) Is
        select install_site_use_id,
               ship_to_site_use_id
        from   cs_incidents_all
        where  incident_id = p_incident_id;

   cursor c_party_site_id (p_install_site_id number) Is
        select party_site_id
        from hz_party_site_uses
        where party_site_use_id = p_install_site_id;

   cursor c_trackable (p_inventory_item_id Number, p_organization_id Number) is  -- changed for bug 3897985
        select comms_nl_trackable_flag
        from   mtl_system_items
        where  inventory_item_id = p_inventory_item_id
        and    organization_id = p_organization_id;

   Cursor c_status_meaning(p_code Varchar2) Is
  	      select  meaning
  	      from fnd_lookups
  	      where lookup_type = 'CSF_INTERFACE_STATUS'
	      and   lookup_code = p_code;

-----------------------------------BEGIN-----------------------------------------------------------

Begin

retcode := 0;
savepoint   main;

if p_debrief_header_id is null and
   p_incident_id is null and
   p_api_version = 2.0 then
  raise e_no_header_id;
end if;

if p_debrief_header_id is not null and  p_incident_id is null then
  open c_header(p_debrief_header_id);
elsif p_incident_id is not null then
 open c_header_inc(p_incident_id);
else
  open c_headers;
end if;

loop

l_processed_flag := 'COMPLETED';
l_cleanup_done := FALSE; -- moved inside loop for bug 3549864

if p_debrief_header_id is not null and p_incident_id is null then
fetch c_header into l_debrief_header_id,
                    l_source_type_code,
                    l_incident_id,
                    l_repair_line_id,
                    l_customer_id,
                    l_customer_account_id,
                    l_debrief_number,
                    l_task_assignment_id,
                    l_cancelled_flag    ,
                    l_rejected_flag     ,
                    l_completed_flag    ,
                    l_closed_flag       ;

 exit when c_header%notfound;
elsif p_incident_id is not null then     -- Changed for bug 3648213
fetch c_header_inc into l_debrief_header_id,
                    l_source_type_code,
                    l_incident_id,
                    l_repair_line_id,
                    l_customer_id,
                    l_customer_account_id,
                    l_debrief_number,
                    l_task_assignment_id,
                    l_cancelled_flag    ,
                    l_rejected_flag     ,
                    l_completed_flag    ,
                    l_closed_flag       ;

 exit when c_header_inc%notfound;
else
                    l_debrief_header_id := Null ;
                    l_source_type_code := Null ;
                    l_incident_id := Null ;
                    l_repair_line_id := Null ;
                    l_customer_id := Null ;
                    l_customer_account_id := Null ;
                    l_debrief_number := Null ;
                    l_task_assignment_id := Null ;
                    l_cancelled_flag := Null ;
                    l_rejected_flag  := Null ;
                    l_completed_flag  := Null ;
                    l_closed_flag   := Null ;
fetch c_headers into l_header_id ;
exit when c_headers%notfound;
open c_header(l_header_id) ;
fetch c_header into l_debrief_header_id,
                    l_source_type_code,
                    l_incident_id,
                    l_repair_line_id,
                    l_customer_id,
                    l_customer_account_id,
                    l_debrief_number,
                    l_task_assignment_id,
                    l_cancelled_flag    ,
                    l_rejected_flag     ,
                    l_completed_flag    ,
                    l_closed_flag       ;
close c_header;
end if;

 relieve_reservations ( l_task_assignment_id ,
                        l_return_status,
                        l_msg_data    ,
                        l_msg_count );
 -------------------------------------------------------------------
 --start cleanup in progress charge lines for the service request--
 ------------------------------------------------------------------
 If not l_cleanup_done Then
  Cs_service_billing_engine_pvt.Delete_In_Progress_Charges(
   P_Api_Version_Number    => 1.0,
   P_Init_Msg_List         => FND_API.G_FALSE,
   P_Commit                => FND_API.G_FALSE,
   p_incident_id           => l_incident_id,
   p_debrief_header_id	   => l_debrief_header_id, -- added for bug 3549864
   x_return_status         => l_return_status,
   x_msg_count             => l_msg_count,
   x_msg_data              => l_msg_data);

   commit;
   l_cleanup_done := TRUE;
  End If; --cleanup
 ----------------------------------------------------------------
 --end cleanup in progress charge lines for the service request--
 ----------------------------------------------------------------


l_msg_data := null;

if l_source_type_code ='SR' Then
   l_original_source_id  := l_incident_id;
   l_original_source_code := 'SR';
end if;
if l_source_type_code ='DR' Then
   l_original_source_id  := l_repair_line_id;
   l_original_source_code := 'DR';
end if;


open c_lines (l_debrief_header_id);
loop
savepoint before_fetch;

  l_after_warranty_cost := null;

fetch c_lines into l_debrief_line_id,
                  l_service_date,
                  l_transaction_type_id,
                  l_inventory_item_id,
                  l_issuing_inventory_org_id,
                  l_receiving_inventory_org_id,
                  l_issuing_sub_inventory_code,
                  l_receiving_sub_inventory_code,
                  l_issuing_locator_id,
                  l_receiving_locator_id,
                  l_parent_product_id,
                  l_removed_product_id,
                  l_item_serial_number,
                  l_revision,
                  l_item_lotnumber,
                  l_uom_code,
                  l_quantity,
                  l_labor_start_date,
                  l_labor_end_date,
                  l_expense_amount,
                  l_currency_code,
                  l_charge_upload_status,
                  l_ib_update_status,
                  l_spare_update_status,
                  l_business_process_id,
                  l_return_reason_code,
                  l_instance_id,
		  l_instance_status, --added for bug 3192060
                  l_item_operational_status_code;

exit when c_lines%notfound;
--added the following for bug3142094
l_return_status := null;
l_record_lock := 'N';

Record_Lock(l_debrief_line_id, l_return_status) ;

If  l_return_status = FND_API.G_RET_STS_ERROR THEN
  rollback to before_fetch;
  l_processed_flag := 'COMPLETED W/ERRORS';
  l_record_lock := 'Y';
  exit ;
end if;

--added the following for bug3246952

l_return_status            := null;
l_charges_interface_status := null;
l_ib_interface_status      := null;
l_inv_interface_status     := null;
l_msg_data                 := null;
l_charges_instance_id      := fnd_api.g_miss_num;
l_organization_id         := nvl(l_receiving_inventory_org_id, nvl(l_issuing_inventory_org_id,cs_std.get_item_valdn_orgzn_id));


--we use c_trans cursor only when we have item number
--hehxx
open  c_cost_charge_flags(l_transaction_type_id);
fetch c_cost_charge_flags into l_create_cost_flag, l_create_charge_flag;
close c_cost_charge_flags;

if (l_inventory_item_id is not null
    and l_inventory_item_id <> fnd_api.g_miss_num) Then

    open  c_trans (l_transaction_type_id, l_inventory_item_id, l_organization_id);
    fetch c_trans into l_line_category_code,
                   l_txn_billing_type_id,
                   l_billing_type,
                   l_txn_sub_type_id    ,
                   l_transaction_type_id_csi;
    close c_trans;
  else --this is for labor lines without item number
 -- l_line_category_code      := 'ORDER'; Commented for bug 7208532
    l_line_category_code      := null;
    l_txn_billing_type_id     := null;
    l_billing_type            := null;
    l_txn_sub_type_id         := null;
    l_transaction_type_id_csi := null;
    -- added for bug 3456295
    l_subinventory_code       := null;
    l_organization_id         := null;
end if;



 If   (l_billing_type = 'M') Then
 ----
    l_installed_cp_return_by_date := sysdate;
    l_party_id := l_customer_id;

    if  (l_line_category_code = 'RETURN') then --FS Recovery
               l_inv_transaction_type_id := 94; --RECEIVING
               l_subinventory_code   := l_receiving_sub_inventory_code;
               l_locator_id          := l_receiving_locator_id;
               l_organization_id     := l_receiving_inventory_org_id;
               l_in_out_flag:='IN';

               open c_internal_party_id;
               fetch c_internal_party_id into l_party_id;
               close c_internal_party_id;

               l_charges_instance_id := l_instance_id;

       else    --FS Usage
               l_inv_transaction_type_id := 93; --ISSUING
               l_subinventory_code   := l_issuing_sub_inventory_code;
               l_locator_id          := l_issuing_locator_id;
               l_organization_id     := l_issuing_inventory_org_id;
               l_in_out_flag:='OUT';

               open  c_site(l_incident_id);
               fetch c_site into l_install_site_use_id, l_ship_site_use_id;
               close c_site;

               If l_install_site_use_id is not null Then l_party_site_id := l_install_site_use_id;
                     Else
                            open c_party_site_id (l_ship_site_use_id);
                            fetch c_party_site_id into l_party_site_id;
                            close c_party_site_id;
               End If;
               l_charges_instance_id := null;

    end if;

    open  c_trackable (l_inventory_item_id, l_organization_id); -- changed for bug 3897985
    fetch c_trackable into l_trackable;
    close c_trackable ;

 Elsif (l_billing_type = 'E') Then
    l_installed_cp_return_by_date := NULL;

    if l_expense_amount is null
       then l_after_warranty_cost := null;
    end if;
    if l_quantity is null
       then l_after_warranty_cost := l_expense_amount;
            l_quantity :=1;
    end if;
    -- added for bug 3456295
    l_subinventory_code   := null;
    l_organization_id     := null;

	-- do not pass NULL in case of l_line_category_code = 'RETURN'
	-- bug # 6851448
	if  (l_line_category_code <> 'RETURN') then
		l_return_reason_code  := null;
	end if;

 Elsif (l_billing_type = 'L') Then
       l_installed_cp_return_by_date := NULL;
       if l_quantity is null Then
       	l_time_diff := to_date(l_labor_end_date,'dd-mm-rrrr hh24:mi:ss')
                      - to_date(l_labor_start_date,'dd-mm-rrrr hh24:mi:ss');

       	l_time_diff := l_time_diff * 24;
       	l_profile_hours := fnd_profile.value('CSF_UOM_HOURS');
       	l_quantity := inv_convert.inv_um_convert
                     (Null,
                      2,
                      l_time_diff,
		              l_profile_hours,
                      l_uom_code,
                      NULL,NULL);

       End If;
    -- added for bug 3456295
       l_subinventory_code   := null;
       l_organization_id     := null;

		-- do not pass NULL in case of l_line_category_code = 'RETURN'
		-- bug # 6851448
		if  (l_line_category_code <> 'RETURN') then
			l_return_reason_code  := null;
		end if;

 end if; --billing_type='M'

-------------------------------------------------------
--decide if we generate final or in progress charges---
-------------------------------------------------------
if (l_cancelled_flag ='Y' or l_rejected_flag='Y'
    or l_completed_flag='Y' or l_closed_flag='Y')
 Then
 -- we have to generate final charges


 ------------------------------------------------------------------------------------------------------
                                      --  UPDATE CHARGES   --
   -------------------------------------------------------------------------------------------------------
 if nvl(l_charge_upload_status, ' ') <> 'SUCCEEDED' and l_create_charge_flag = 'Y' Then

  csf_debrief_charges.create_charges(
      p_original_source_id            => l_original_source_id    ,
      p_original_source_code          => l_original_source_code  ,
      p_incident_id                   => l_incident_id           ,
      p_business_process_id           => l_business_process_id   ,
      p_line_category_code            => l_line_category_code    ,
      p_source_code                   => 'SD'                    ,
      p_source_id                     => l_debrief_line_id       ,
      p_inventory_item_id             => l_inventory_item_id     ,
      p_item_revision                 => l_revision              ,
      p_unit_of_measure_code          => l_uom_code              ,
      p_quantity                      => l_quantity              ,
      p_txn_billing_type_id           => l_txn_billing_type_id   ,
      p_transaction_type_id           => l_transaction_type_id   ,
      p_customer_product_id           => l_charges_instance_id   ,
      p_installed_cp_return_by_date   => l_installed_cp_return_by_date,
      p_after_warranty_cost           => l_after_warranty_cost   ,
      p_currency_code                 => l_currency_code         ,
      p_return_reason_code            => l_return_reason_code    ,
      p_inventory_org_id              => l_organization_id       ,
      p_subinventory                  => l_subinventory_code     ,
      p_serial_number                 => l_item_serial_number    ,
      p_final_charge_flag             => 'Y'                     ,
      p_labor_start_date              => l_labor_start_date      ,
      p_labor_end_date                => l_labor_end_date        ,
      x_return_status                 => l_return_status         ,
      x_msg_count                     => l_msg_count             ,
      x_msg_data                      => l_msg_data              );

    if l_RETURN_STATUS = 'S' then -- success
           l_msg_data := null;  -- added for bug 3863950
           l_charges_interface_status := 'SUCCEEDED';
     elsif l_RETURN_STATUS ='E' or l_RETURN_STATUS = 'U' then      --Expected Error
          retcode := 1;

          l_processed_flag := 'COMPLETED W/ERRORS';
           if l_msg_count > 0 then
                 FOR counter IN REVERSE 1..l_msg_count
                  LOOP
                     fnd_msg_pub.get(counter,FND_API.G_FALSE,l_msg_data,l1);
                     FND_FILE.put_line(FND_FILE.log,l_msg_data);
                  end loop;
           end if;
           l_charges_interface_status := 'FAILED';

    end if;
   --dbms_output.put_line('l_return_status='||l_return_status);
   --dbms_output.put_line('l_msg_data='||l_msg_data);
   --dbms_output.put_line('l_charges_interface_status='||l_charges_interface_status);


  --------------------------------------------------------------------------
  -- START UPDATE CHARGES UPLOAD STATUS COLUMN  ----------------------------
  --------------------------------------------------------------------------

  if l_charges_interface_status = 'FAILED' then
    rollback to before_fetch;

    if l_charges_interface_status <> 'FAILED' then
      l_charges_interface_status := fnd_api.g_miss_char;
    end if;
    csf_debrief_lines_pkg.update_row(
      p_debrief_line_id => l_debrief_line_id,
      p_error_text => substr(l_msg_data,1,2000),
      p_charge_upload_status => l_charges_interface_status,
      p_last_updated_by => fnd_global.user_id,
      p_last_update_date => sysdate,
      p_last_update_login => fnd_global.login_id);
  else

    if l_charges_interface_status = 'SUCCEEDED' Then  --it means we tried to update Charges and it was succ

      csf_debrief_lines_pkg.update_row(
        p_debrief_line_id => l_debrief_line_id,
        p_error_text => null,
        p_charge_upload_status => l_charges_interface_status,
        p_last_updated_by => fnd_global.user_id,
        p_last_update_date => sysdate,
        p_last_update_login => fnd_global.login_id);
    end if;
  end if;
 --------------------------------------------------------------------------
  -- END UPDATE CHARGES UPLOAD STATUS COLUMN ----------------------------
  -------------------------------------------------------------------------

  end if; --charge_upload_status

  -------------------------------------------------------------------------
  --END UPDATE CHARGE------------------------------------------------------
  -------------------------------------------------------------------------

 If   (l_billing_type = 'M') Then

  if nvl(l_ib_update_status,' ') <> 'SUCCEEDED' and l_trackable ='Y'
     and (l_charges_interface_status = 'SUCCEEDED' or l_charge_upload_status ='SUCCEEDED' ) --continue only if charges was suc.
   Then
   ------------------------------------------------------------------------------------------------------
                                      --  UPDATE INSTALL BASE   --
   -------------------------------------------------------------------------------------------------------

    --dbms_output.put_line('in IB');
l_instance_status_id :=to_number(l_instance_status); --added  for bug 3192060
    csf_ib.update_install_base(
    p_api_version            => 1.0,
    p_init_msg_list          => null,
    p_commit                 => null,
    p_validation_level       => null,
    x_return_status          => l_return_status,
    x_msg_count              => l_msg_count,
    x_msg_data               => l_msg_data,
    x_new_instance_id        => l_new_instance_id, --
    p_in_out_flag            => l_in_out_flag,  --
    p_transaction_type_id    => l_transaction_type_id_csi,
    p_txn_sub_type_id        => l_txn_sub_type_id,
    p_instance_id            => l_instance_id,
    p_inventory_item_id      => l_inventory_item_id,
    p_inv_organization_id    => l_organization_id,
    p_inv_subinventory_name  => l_subinventory_code,
    p_inv_locator_id         => l_locator_id,
    p_quantity               => l_quantity,
    p_inv_master_organization_id => l_inv_master_organization_id,
    p_mfg_serial_number_flag => 'N',
    p_serial_number          => l_item_serial_number,
    p_lot_number             => l_item_lotnumber,
    p_revision               => l_revision,
    p_unit_of_measure        => l_uom_code,
    p_party_id               => l_party_id,
    p_party_account_id       => l_customer_account_id,
    p_party_site_id          => l_party_site_id,
    p_parent_instance_id     => l_parent_product_id,
 p_instance_status_id     => l_instance_status_id,  --added for bug 3192060
 p_item_operational_status_code => l_item_operational_status_code);



     if l_RETURN_STATUS = 'S' then -- success --3
           l_msg_data := null;    -- added for bug 3863950
           l_ib_interface_status := 'SUCCEEDED';
      elsif l_RETURN_STATUS ='E' or l_RETURN_STATUS = 'U' then      --Expected Error --2
          retcode := 1;
          l_processed_flag := 'COMPLETED W/ERRORS';
           if l_msg_count > 0 then  --1
                 FOR counter IN REVERSE 1..l_msg_count
                  LOOP
                     fnd_msg_pub.get(counter,FND_API.G_FALSE,l_msg_data,l1);
                     FND_FILE.put_line(FND_FILE.log,l_msg_data);
                  end loop;
           end if; --1
           l_ib_interface_status := 'FAILED';
           --dbms_output.put_line('l_ib_interface_status='||l_ib_interface_status);
     end if; --3



   end if; --4

  if l_ib_interface_status = 'FAILED' or l_charges_interface_status = 'FAILED' then
    rollback to before_fetch;

    if l_charges_interface_status <> 'FAILED' then
      l_charges_interface_status := fnd_api.g_miss_char;
    end if;
    if l_ib_interface_status <> 'FAILED' then
      l_ib_interface_status := fnd_api.g_miss_char;
    end if;
    csf_debrief_lines_pkg.update_row(
      p_debrief_line_id => l_debrief_line_id,
      p_error_text => substr(l_msg_data,1,2000),
      p_charge_upload_status => l_charges_interface_status,
      p_ib_update_status => l_ib_interface_status,
      p_last_updated_by => fnd_global.user_id,
      p_last_update_date => sysdate,
      p_last_update_login => fnd_global.login_id);
  else
    if nvl(l_ib_update_status,' ') <> 'SUCCEEDED' and l_billing_type='M' and l_trackable='Y'
       and (l_charges_interface_status= 'SUCCEEDED' or l_charge_upload_status='SUCCEEDED') --we tried to update IB for this line
      Then

      if l_line_category_code <> 'RETURN' then
        l_instance_id := l_new_instance_id;
      end if;
      csf_debrief_lines_pkg.update_row(
        p_debrief_line_id => l_debrief_line_id,
        p_error_text => null,
        p_instance_id => l_instance_id,
        p_ib_update_status => l_ib_interface_status,
        p_last_updated_by => fnd_global.user_id,
        p_last_update_date => sysdate,
        p_last_update_login => fnd_global.login_id);
    end if;
  end if;

    ------------------------------------------------------------------------------------------------------
                                      --  UPDATE INVENTORY   --
   -------------------------------------------------------------------------------------------------------
  if nvl(l_spare_update_status,' ') <> 'SUCCEEDED'
   and (l_charges_interface_status = 'SUCCEEDED' or l_charge_upload_status ='SUCCEEDED' )
   and ( (l_ib_interface_status = 'SUCCEEDED'  and l_trackable='Y')
          or (l_ib_update_status = 'SUCCEEDED' and l_trackable ='Y')
          or l_trackable ='N' or l_trackable is null )
      --ib_interface status must be = with Suceesed only when I tried to update Ib for this record
     Then

      --dbms_output.put_line('in update inv');
      /*
     dbms_output.put_line('p_transaction_type_id    =' ||l_transaction_type_id_csi);
     dbms_output.put_line('p_txn_sub_type_id        =' ||l_txn_sub_type_id);
     dbms_output.put_line('p_instance_id            =' ||l_instance_id);
     dbms_output.put_line('p_inventory_item_id      =' ||l_inventory_item_id);
     dbms_output.put_line('p_inv_organization_id    =' ||l_organization_id);
     dbms_output.put_line('p_inv_subinventory_name  =' ||l_subinventory_code);
     dbms_output.put_line('p_quantity               =' ||l_quantity);
     dbms_output.put_line('p_inv_master_organization_id =' ||l_inv_master_organization_id);
     dbms_output.put_line('p_mfg_serial_number_flag =' );
     dbms_output.put_line('p_serial_number          =' ||l_item_serial_number);
     dbms_output.put_line('p_lot_number             =' ||l_item_lotnumber);
     dbms_output.put_line('p_unit_of_measure        =' ||l_uom_code);
     dbms_output.put_line('p_party_id               =' ||l_party_id);
     dbms_output.put_line('p_party_account_id       =' ||l_customer_account_id);
     dbms_output.put_line('p_party_site_id          =' ||l_party_site_id);
     dbms_output.put_line('p_parent_instance_id     =' ||l_parent_product_id) ;*/

    l_return_status := fnd_api.g_ret_sts_success;
    IF jtf_usr_hks.Ok_To_Execute('CSF_DEBRIEF_UPDATE_PKG','TRANSACT_MATERIAL','B','C') THEN
      csf_debrief_update_pkg.g_debrief_line_id := l_debrief_line_id;
      csf_debrief_update_pkg.g_account_id := null;
      csf_debrief_pub.call_internal_hook('CSF_DEBRIEF_UPDATE_PKG','TRANSACT_MATERIAL','B',l_return_status);
    end if;
    if l_return_status = fnd_api.g_ret_sts_success then
      if l_date_type = 'Y' then
        l_service_date := sysdate;
      end if;
    CSP_TRANSACTIONS_PUB.TRANSACT_MATERIAL(
   p_api_version            => l_api_version,
   x_return_status          => l_RETURN_STATUS,
   x_msg_count              => l_MSG_COUNT,
   x_msg_data               => l_MSG_DATA,
   p_init_msg_list          => FND_API.G_TRUE,
   p_commit                 => FND_API.G_FALSE,
   p_inventory_item_id      => l_inventory_item_id,
   p_organization_id        => l_organization_id,
   p_subinventory_code      => l_subinventory_code,
   p_locator_id             => l_locator_id,
   p_serial_number          => l_item_serial_number,
   p_quantity               => l_quantity,
   p_uom                    => l_uom_code,
   p_revision               => l_revision,
   p_lot_number             => l_item_lotnumber,
   p_transfer_to_subinventory => null,
   p_transfer_to_locator    => null,
   p_transfer_to_organization => null,
   p_source_id              => null,
   p_source_line_id         => null,
   p_transaction_type_id    => l_inv_transaction_type_id,
   p_account_id             => csf_debrief_update_pkg.g_account_id,
   px_transaction_header_id => l_inv_transaction_header_id,
   px_transaction_id        => l_inv_transaction_id,
   p_transaction_source_id  => l_debrief_header_id,
   p_trx_source_line_id     => l_debrief_line_id,
   p_transaction_source_name => l_debrief_number,
   p_transaction_date              => l_service_date );
   end if;
     if l_RETURN_STATUS = 'S' then -- success
           l_inv_interface_status := 'SUCCEEDED';
           l_msg_data := null;
      elsif l_RETURN_STATUS ='E' or l_RETURN_STATUS = 'U' then      --Expected Error
          retcode := 1;
          l_processed_flag := 'COMPLETED W/ERRORS';
           if l_msg_count > 0 then
                 FOR counter IN REVERSE 1..l_msg_count
                 LOOP
                     fnd_msg_pub.get(counter,FND_API.G_FALSE,l_msg_data,l1);
                     l_position := instr(l_msg_data, 'ERROR_EXPLANATION');
                     l_msg_data := substr(l_msg_data, l_position);
                     FND_FILE.put_line(FND_FILE.log,l_msg_data);
                  end loop;
           end if;
           l_inv_interface_status := 'FAILED';
           --dbms_output.put_line('l_inv_interface_status='||l_inv_interface_status);
           --dbms_output.put_line('l_msg_data='||l_msg_data);
    end if;
  end if; --spares update status
 end if; --billing_type='M'

-- COSTING
  if (l_inventory_item_id is null and l_create_cost_flag = 'Y'
     and l_create_charge_flag = 'N'
     and nvl(l_charge_upload_status,' ') <> 'SUCCEEDED') or
     (l_inventory_item_id is not null and l_create_cost_flag = 'Y'
     and nvl(l_charge_upload_status,' ') <> 'SUCCEEDED') Then
    l_estimate_detail_id := null;

    if l_create_charge_flag = 'Y' then
      open  c_charge_id(l_debrief_line_id);
      fetch c_charge_id into l_estimate_detail_id;
      close c_charge_id;
    end if;

    l_cost_rec.incident_id          := l_incident_id;
    l_cost_rec.transaction_type_id  := l_transaction_type_id;
    l_cost_rec.txn_billing_type_id  := l_txn_billing_type_id;
    l_cost_rec.inventory_item_id    := l_inventory_item_id;
    l_cost_rec.quantity             := l_quantity;
    l_cost_rec.unit_of_measure_code := l_uom_code;
    l_cost_rec.currency_code        := l_currency_code;
    l_cost_rec.source_id            := l_debrief_line_id;
    l_cost_rec.source_code          := 'SD';
    l_cost_rec.estimate_detail_id   := l_estimate_detail_id;
    --l_cost_rec.org_id := 204;
    l_cost_rec.inventory_org_id     := l_organization_id;
    l_cost_rec.transaction_date     := sysdate;
    l_cost_rec.extended_cost        := l_expense_amount;

    cs_cost_details_pub.create_cost_details(
      p_api_version              => 1.0,
      x_return_status            => l_return_status,
      x_msg_count                => l_msg_count,
      x_object_version_number    => l_object_version,
      x_msg_data                 => l_msg_data,
      x_cost_id                  => l_cost_id,
      p_Cost_Rec                 => l_cost_rec);
    if l_RETURN_STATUS = 'S' then -- success
      l_charges_interface_status := 'SUCCEEDED';
      l_msg_data := null;
      csf_debrief_lines_pkg.update_row(
        p_debrief_line_id => l_debrief_line_id,
        p_error_text => substr(l_msg_data,1,2000),
        p_charge_upload_status => l_charges_interface_status,
        p_last_updated_by => fnd_global.user_id,
        p_last_update_date => sysdate,
        p_last_update_login => fnd_global.login_id);
    elsif l_RETURN_STATUS ='E' or l_RETURN_STATUS = 'U' then    --Expected Error
      retcode := 1;
      l_processed_flag := 'COMPLETED W/ERRORS';
      if l_msg_count > 0 then
        FOR counter IN REVERSE 1..l_msg_count LOOP
          fnd_msg_pub.get(counter,FND_API.G_FALSE,l_msg_data,l1);
          l_position := instr(l_msg_data, 'ERROR_EXPLANATION');
          l_msg_data := substr(l_msg_data, l_position);
          FND_FILE.put_line(FND_FILE.log,l_msg_data);
        end loop;
      end if;
      l_inv_interface_status := 'FAILED';
    end if;
  end if;

-------- Added for bug 3608969

    if l_ib_interface_status = 'FAILED' or l_charges_interface_status = 'FAILED' or
	l_inv_interface_status = 'FAILED' then
    rollback;
    if l_charges_interface_status <> 'FAILED' then
      l_charges_interface_status := fnd_api.g_miss_char;
    end if;
    if l_ib_interface_status <> 'FAILED' then
      l_ib_interface_status := fnd_api.g_miss_char;
    end if;
    if l_inv_interface_status <> 'FAILED' then
      l_inv_interface_status := fnd_api.g_miss_char;
    end if;
    csf_debrief_lines_pkg.update_row(
      p_debrief_line_id => l_debrief_line_id,
      p_error_text => substr(l_msg_data,1,2000),
      p_charge_upload_status => l_charges_interface_status,
      p_ib_update_status => l_ib_interface_status,
      p_spare_update_status => l_inv_interface_status,
      p_last_updated_by => fnd_global.user_id,
      p_last_update_date => sysdate,
      p_last_update_login => fnd_global.login_id);

  else
    if nvl(l_spare_update_status,' ') <> 'SUCCEEDED' and l_billing_type='M'
	   and (l_charges_interface_status= 'SUCCEEDED' or l_charge_upload_status='SUCCEEDED')
	   and ( (l_ib_interface_status = 'SUCCEEDED'  and l_trackable='Y')
		  or (l_ib_update_status = 'SUCCEEDED' and l_trackable ='Y')
		  or l_trackable ='N' or l_trackable is null ) then
	  --we tried to update inventory
      csf_debrief_lines_pkg.update_row(
        p_debrief_line_id => l_debrief_line_id,
        p_error_text => null,
        p_spare_update_status => l_inv_interface_status,
        p_last_updated_by => fnd_global.user_id,
        p_last_update_date => sysdate,
        p_last_update_login => fnd_global.login_id);

     end if;
   end if;

else --- assignment status is not completed => we have to generate in progress charges

l_processed_flag := 'UNPROCESSED';

    ------------------------------------------------------------------------
    --GENERATING IN PROGRESS CHARGE LINES ----
    -------------------------------------------------------------------------
 if nvl(l_charge_upload_status, ' ') <> 'SUCCEEDED' and l_create_charge_flag = 'Y' Then -- added for bug 3538214

  csf_debrief_charges.create_charges(
      p_original_source_id            => l_original_source_id    ,
      p_original_source_code          => l_original_source_code  ,
      p_incident_id                   => l_incident_id           ,
      p_business_process_id           => l_business_process_id   ,
      p_line_category_code            => l_line_category_code    ,
      p_source_code                   => 'SD'                    ,
      p_source_id                     => l_debrief_line_id       ,
      p_inventory_item_id             => l_inventory_item_id     ,
      p_item_revision                 => l_revision              ,
      p_unit_of_measure_code          => l_uom_code              ,
      p_quantity                      => l_quantity              ,
      p_txn_billing_type_id           => l_txn_billing_type_id   ,
      p_customer_product_id           => l_charges_instance_id   ,
      p_installed_cp_return_by_date   => l_installed_cp_return_by_date,
      p_after_warranty_cost           => l_after_warranty_cost   ,
      p_currency_code                 => l_currency_code         ,
      p_return_reason_code            => l_return_reason_code    ,
      p_inventory_org_id              => l_organization_id       ,
      p_serial_number                 => l_item_serial_number    ,
      p_final_charge_flag             => 'N'                   ,
      p_labor_start_date              => l_labor_start_date      ,
      p_labor_end_date                => l_labor_end_date        ,
      p_transaction_type_id           => l_transaction_type_id,
      x_return_status                 => l_return_status         ,
      x_msg_count                     => l_msg_count             ,
      x_msg_data                      => l_msg_data              );


      if l_RETURN_STATUS ='E' or l_RETURN_STATUS = 'U' then      --Expected Error
        retcode := 1;

        if l_msg_count > 0 then
          FOR counter IN REVERSE 1..l_msg_count LOOP
            fnd_msg_pub.get(counter,FND_API.G_FALSE,l_msg_data,l1);
            FND_FILE.put_line(FND_FILE.log,l_msg_data);
          end loop;
        end if;
      else
        l_msg_data := null;
      end if;

      csf_debrief_lines_pkg.update_row(
        p_debrief_line_id => l_debrief_line_id,
        p_error_text => substr(l_msg_data,1,2000));

  end if; -- end of charges status check

end if;--end of deciding if we have to generate in progress or final charges

 end loop;
 close c_lines;

   update csf_debrief_headers
    set processed_flag = nvl(l_processed_flag,'UNPROCESSED')
    where debrief_header_id = l_debrief_header_id;
   commit;

 If l_return_status = FND_API.G_RET_STS_ERROR and l_record_lock = 'Y' THEN
    FND_MESSAGE.Set_Name('CSF','CSF_DEBRIEF_CONC_PROG_RECLOCK');
    FND_MESSAGE.Set_Token('DEBRIEF_NUMBER',l_debrief_number);
    FND_MSG_PUB.ADD;
    l_msg_data := FND_MSG_PUB.Get(p_msg_index => fnd_msg_pub.G_LAST,
                                  p_encoded  => FND_API.G_FALSE);
    fnd_file.put_line(fnd_file.log, l_msg_data);
    l_conc_result := fnd_concurrent.set_completion_status('WARNING','Warning');
    exit;
 end if;
end loop;

if p_debrief_header_id is not null and p_incident_id is null then
  close c_header;
elsif  p_incident_id is not null then  -- Changed for bug 3648213
  close c_header_inc;
else
  close c_headers;
end if;

exception
    when e_no_header_id then
      fnd_message.set_name('CSF', 'CSF_DEBRIEF_MISSING_HEADER_ID');
      fnd_msg_pub.add;
      fnd_msg_pub.get(1,FND_API.G_FALSE,l_msg_data,l1);
      FND_FILE.put_line(FND_FILE.log,l_msg_data);
      retcode := 2;
      errbuf := l_msg_data;

    when others then
      retcode := 2;
      errbuf := sqlerrm;
      l_message := errbuf;
      FND_FILE.put_line(FND_FILE.log,l_message);

end;

------------------------------------------------------------------------------------------------------------------
PROCEDURE Form_Call
-----------------------------------------------------------------------------------------------------------------
(
    p_api_version           IN  NUMBER,
    p_debrief_header_id       IN  NUMBER
) is
l_request_id       Number ;
Begin

l_request_id := fnd_request.submit_request('CSF',
                                                'CSFUPDATE',
                                                'CSF:Update Debrief Lines',
                                                 null,
                                                FALSE,
                                                2.0,
                                                p_debrief_header_id);

End;

---------------------------------------------------------------------------------------------------
procedure relieve_reservations(p_task_assignment_id IN NUMBER,
----------------------------------------------------------------------------------------------------
                               x_return_status      OUT NOCOPY varchar2,
                               x_msg_data           OUT NOCOPY varchar2,
                               x_msg_count          OUT NOCOPY varchar2) IS
cursor reservations
IS
Select crld.source_id,crld.req_line_detail_id,crh.requirement_header_id
from   csp_requirement_headers crh,
       csp_requirement_lines crl,
       csp_req_line_details crld
where  crh.task_assignment_id = p_task_assignment_id
and    crl.requirement_header_id = crh.requirement_header_id
and    crld.requirement_line_id = crl.requirement_line_id
and    crld.source_type = 'RES';

l_reservation_rec inv_reservation_global.mtl_reservation_rec_type;
l_serial_number   inv_reservation_global.serial_number_tbl_type;
l_relieved_quantity        NUMBER;
l_remaining_quantity       NUMBER;
l_req_line_detail_id 	   NUMBER;
l_requirement_header_id	   number := null;
l_req_header_id   	   number := null;
BEGIN

        OPEN reservations;
        LOOP
         FETCH reservations INTO l_reservation_rec.reservation_id,l_req_line_detail_id,l_req_header_id;
         EXIT WHEN reservations % NOTFOUND;
         l_requirement_header_id := l_req_header_id;
         l_relieved_quantity := null;
         inv_reservation_pub.relieve_reservation
                                        (
                                         p_api_version_number    => 1.0
                                        ,p_init_msg_lst          =>
fnd_api.g_false
                                        ,x_return_status         =>
x_return_status
                                        ,x_msg_count             =>
x_msg_count
                                        ,x_msg_data              =>
x_msg_data
                                        ,p_rsv_rec               =>
l_reservation_rec
                                        ,p_primary_relieved_quantity =>
l_relieved_quantity
                                        ,p_relieve_all           =>
fnd_api.g_true
                                        ,p_original_serial_number =>
l_serial_number
                                        ,p_validation_flag       =>
fnd_api.g_true
                                        ,x_primary_relieved_quantity  =>
l_relieved_quantity
                                        ,x_primary_remain_quantity  =>
l_remaining_quantity
                                        );
            If  x_return_status <>  FND_API.G_RET_STS_SUCCESS then
                exit;
            end if;
	     IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
		 CSP_REQ_LINE_DETAILS_PKG.Delete_Row(l_req_line_detail_id);
	     END IF;
         END LOOP;
        CLOSE reservations;
        if l_requirement_header_id is not null then
          csp_requirement_headers_pkg.update_row(
            p_requirement_header_id => l_requirement_header_id,
            p_open_requirement => 'N');
        end if;
END relieve_reservations;

PROCEDURE web_Call
(
    p_api_version           IN  NUMBER,
    p_task_assignment_id       IN  NUMBER
) is
cursor get_debrief_header is
select debrief_header_id
from csf_debrief_headers
where task_assignment_id = p_task_assignment_id;

l_debrief_header_id NUMBER;
 l_request_id NUMBER;

begin
         for gdh In get_debrief_header LOOP
            l_debrief_header_id := gdh.debrief_header_id;
            --
            update csf_debrief_headers
            set processed_flag = 'PENDING'
            where debrief_header_id = l_debrief_header_id;
            --
        END LOOP;
        IF  l_debrief_header_id IS NOT NULL THEN
            l_request_id := fnd_request.submit_request('CSF',
                                                'CSFUPDATE',
                                                'CSF:Update Debrief Lines',
                                                 null,
                                                FALSE,
                                                1.0,
                                                l_debrief_header_id);

        END IF;
end web_Call;

PROCEDURE DEBRIEF_STATUS_CHECK  (
            p_incident_id          in         number,
            p_api_version          in         number,
            p_validation_level     in         number,
            x_debrief_status       out nocopy debrief_status_tbl_type,
            x_return_status        out nocopy varchar2,
            x_msg_count            out nocopy number,
            x_msg_data             out nocopy varchar2) IS

  l_processed_flag                 csf_debrief_headers.processed_flag%type;
  l_task_number                    jtf_tasks_b.task_number%type;
  l_debrief_status_rec             debrief_status_rec_type;
  l_debrief_status_tbl             debrief_status_tbl_type;

  cursor get_debrief_status is
  select jtb.task_id,
         jtb.task_number,
         cdh.debrief_header_id,
         cdh.debrief_number,
         decode(processed_flag,'PENDING','P','E') debrief_status
  from   csf_debrief_headers cdh,
         jtf_task_assignments jta,
         jtf_tasks_b jtb
  where  processed_flag in ('PENDING','COMPLETED W/ERRORS')
  and    jta.task_assignment_id = cdh.task_assignment_id
  and    jtb.task_id = jta.task_id
  and    jtb.source_object_type_code = 'SR'
  and    jtb.source_object_id = p_incident_id
  union all
  select jtb.task_id,
         jtb.task_number,
         cdh.debrief_header_id,
         cdh.debrief_number,
         decode(processed_flag,'PENDING','P','E') debrief_status
  from   csd_repairs cr,
         jtf_tasks_b jtb,
         jtf_task_assignments jta,
         csf_debrief_headers cdh
  where  jtb.source_object_id = cr.repair_line_id
  and    jtb.source_object_type_code = 'DR'
  and    jta.task_id = jtb.task_id
  and    cdh.task_assignment_id = jta.task_assignment_id
  and    cdh.processed_flag in ('PENDING','COMPLETED W/ERRORS')
  and    cr.incident_id = p_incident_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  for cr in get_debrief_status loop
    l_debrief_status_tbl(get_debrief_status%rowcount) := cr;
    if p_validation_level = 0 and get_debrief_status%rowcount = 1 then
      exit;
    end if;
  end loop;
  if l_debrief_status_tbl.count > 0 then
    x_debrief_status := l_debrief_status_tbl;
    x_return_status := fnd_api.g_ret_sts_error;
  end if;
  exception when others then
    fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
    fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
    fnd_msg_pub.add;
    x_return_status := fnd_api.g_ret_sts_unexp_error;
END DEBRIEF_STATUS_CHECK ;

End Csf_Debrief_Update_pkg;


/
