--------------------------------------------------------
--  DDL for Package Body CSF_DEBRIEF_CHARGES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_DEBRIEF_CHARGES" as
/*  $Header: csfdbchb.pls 120.0.12000000.5 2007/07/25 23:47:53 hhaugeru ship $ */
-- Start of Comments
-- Package name     : CSF_DEBRIEF_CHARGES
-- Purpose          : Wrapper for Charges
-- History          :
-- NOTE             :
-- End of Comments
-- Default number of records fetch per call


PROCEDURE CREATE_CHARGES (
P_ORIGINAL_SOURCE_ID	        IN   NUMBER,
P_ORIGINAL_SOURCE_CODE	        IN   VARCHAR2,
P_INCIDENT_ID		            IN   NUMBER,
P_BUSINESS_PROCESS_ID	        IN   NUMBER,
P_LINE_CATEGORY_CODE	        IN   VARCHAR2,
P_SOURCE_CODE                   IN   VARCHAR2,
P_SOURCE_ID                     IN   NUMBER,
P_INVENTORY_ITEM_ID	            IN	 NUMBER	  DEFAULT FND_API.G_MISS_NUM,
P_ITEM_REVISION                 IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
P_UNIT_OF_MEASURE_CODE          IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
P_QUANTITY                      IN   NUMBER	  DEFAULT FND_API.G_MISS_NUM,
P_TXN_BILLING_TYPE_ID           IN   NUMBER   DEFAULT FND_API.G_MISS_NUM,
P_TRANSACTION_TYPE_ID           IN   NUMBER   DEFAULT FND_API.G_MISS_NUM,
P_CUSTOMER_PRODUCT_ID	        IN	 NUMBER   DEFAULT FND_API.G_MISS_NUM,
P_INSTALLED_CP_RETURN_BY_DATE   IN   DATE     DEFAULT FND_API.G_MISS_DATE,
P_AFTER_WARRANTY_COST           IN   NUMBER   DEFAULT FND_API.G_MISS_NUM,
P_CURRENCY_CODE                 IN 	 VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
P_RETURN_REASON_CODE            IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
P_INVENTORY_ORG_ID              IN   VARCHAR2 DEFAULT FND_API.G_MISS_NUM,
P_SUBINVENTORY                  IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
P_SERIAL_NUMBER                 IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
P_FINAL_CHARGE_FLAG             IN   VARCHAR2,
P_LABOR_START_DATE              IN   DATE     DEFAULT FND_API.G_MISS_DATE,
P_LABOR_END_DATE                IN   DATE     DEFAULT FND_API.G_MISS_DATE,
X_Return_Status                 OUT NOCOPY  VARCHAR2,
X_Msg_Count                     OUT NOCOPY  NUMBER,
X_Msg_Data                      OUT NOCOPY  VARCHAR2
) as

l_Charges_Rec			Cs_service_billing_engine_pvt.SBE_Rec_Type;

l_object_version_number		NUMBER;
l_estimate_detail_id		NUMBER;
l_line_number			NUMBER;
l_price_list_id                 number := null;

cursor c_price_list is
select price_list_header_id
from   csd_repairs
where  repair_line_id = p_original_source_id;

begin
if p_original_source_code = 'DR' then
  open  c_price_list;
  fetch c_price_list into l_price_list_id;
  close c_price_list;
  l_charges_rec.price_list_id := l_price_list_id;
end if;

l_Charges_Rec.original_source_id            := p_original_source_id ;
l_Charges_Rec.original_source_code          := p_original_source_code ;
l_Charges_Rec.incident_id                   := p_incident_id ;
l_Charges_Rec.business_process_id           := p_business_process_id ;
l_Charges_Rec.line_category_code            := p_line_category_code ;
l_Charges_Rec.source_code                   := p_source_code;
l_Charges_Rec.source_id                     := p_source_id;
l_Charges_Rec.inventory_item_id             := p_inventory_item_id;
l_Charges_Rec.item_revision                 := p_item_revision;
l_charges_rec.unit_of_measure_code          := p_unit_of_measure_code;
l_charges_rec.quantity                      := p_quantity;
l_charges_rec.txn_billing_type_id           := p_txn_billing_type_id;
l_charges_rec.transaction_type_id           := p_transaction_type_id;
l_charges_rec.customer_product_id           := p_customer_product_id;
l_charges_rec.installed_cp_return_by_date   := p_installed_cp_return_by_date;
l_charges_rec.after_warranty_cost           := p_after_warranty_cost;
l_charges_rec.currency_code                 := p_currency_code;
l_charges_rec.return_reason_code            := p_return_reason_code;
l_charges_rec.serial_number                 := p_serial_number;
l_charges_rec.transaction_inventory_org_id  := null;
l_charges_rec.transaction_sub_inventory     := null;
l_charges_rec.labor_start_date_time         := p_labor_start_date;
l_charges_rec.labor_end_date_time           := p_labor_end_date;

Cs_service_billing_engine_pvt.Create_Charges(
   P_Api_Version_Number    =>1.0,
   P_Init_Msg_List         =>FND_API.G_FALSE,
   P_Commit                =>FND_API.G_FALSE,
   p_sbe_record            =>l_charges_rec,
   p_final_charge_flag     =>p_final_charge_flag,
   x_return_status         =>x_return_status,
   x_msg_count             =>x_msg_count,
   x_msg_data              =>x_msg_data
   );


end CREATE_CHARGES;


PROCEDURE UPDATE_LAB_RS_LOC(
p_debrief_header_id IN NUMBER,
p_debrief_line_id   IN NUMBER,
p_labor_start_date  IN DATE,
X_RETURN_STATUS	   OUT NOCOPY varchar2,
X_MSG_COUNT	   OUT NOCOPY number,
X_MSG_DATA         OUT NOCOPY VARCHAR2) as
z_resource_id           number;
z_location              mdsys.sdo_geometry;
z_object_version_number  NUMBER;
z_start_date            date;
Begin

 -- Calling the Update Resource Location API to Update Resource's Location



select  jta.resource_id,
                loc.geometry
into            z_resource_id,
                z_location
from            csf_debrief_lines     cdl,
                csf_debrief_headers csf,
                cs_transaction_types_vl  ctt,
                cs_txn_billing_types  ctbt,
                jtf_task_assignments jta,
                jtf_tasks_b    jtb,
                hz_party_sites p,
                hz_locations   loc
where   csf.debrief_header_id      =  p_debrief_header_id
and             debrief_line_id            =  p_debrief_line_id
and             jta.task_id                        =     jtb.task_id
and             jta.task_assignment_id     =   csf.task_assignment_id
and             jtb.address_id             =    p.party_site_id
and             p.location_id              =     loc.location_id
and             csf.debrief_header_id      =   cdl.debrief_header_id
and             ctt.transaction_type_id    =   ctbt.transaction_type_id
and             cdl.txn_Billing_Type_Id    =   ctbt.txn_billing_type_id
and             ctbt.billing_type          =   'L';


select  max(actual_start_date)
into            z_start_date
from            jtf_task_assignments
where   resource_id = z_resource_id;

IF p_labor_start_date > z_start_date then

   select       object_version_number
   into z_object_version_number
   from jtf_rs_resource_extns
   where        resource_id             =       z_resource_id;

/*
 -- jtf has removed the p_location column, and suggest
 --  to update the location directly
 jtf_rs_resource_pub.update_resource
    (P_API_VERSION      => 1,
   --  P_INIT_MSG_LIST    => fnd_api.g_false,
   --  P_COMMIT           => fnd_api.g_false,
     P_RESOURCE_ID      => z_resource_id,
     P_RESOURCE_NUMBER  => null,
     P_LOCATION                 => z_location,
     P_object_version_num =>  z_object_version_number,
     X_RETURN_STATUS      =>  x_return_status,
     X_MSG_COUNT          =>  x_msg_count,
     X_MSG_DATA           =>  x_msg_data);

*/
END IF;

EXCEPTION WHEN NO_DATA_FOUND THEN NULL;

END ;

PROCEDURE UPDATE_CHARGES (
SOURCE_CODE         IN   VARCHAR2,
SOURCE_ID           IN   NUMBER,
INVENTORY_ITEM_ID	IN	NUMBER	,
UNIT_OF_MEASURE_CODE IN  VARCHAR2	,
QUANTITY_REQUIRED    IN  NUMBER	,
TXN_BILLING_TYPE     IN  NUMBER    ,
OUT_X_Return_Status     OUT NOCOPY  VARCHAR2,
OUT_X_Msg_Count         OUT NOCOPY  NUMBER,
OUT_X_Msg_Data          OUT NOCOPY  VARCHAR2
) AS

Cursor c_estimate_detail(p_source_id NUMBER,p_source_code Varchar2) IS
  select estimate_detail_id
  FROM   cs_estimate_details
  WHERE  source_id = p_source_id
  AND    source_code = p_source_code;

l_Charges_Rec			CS_Charge_Details_PUB.Charges_Rec_Type;
l_object_version_number		NUMBER;
l_estimate_detail_id NUMBER;

BEGIN
Open c_estimate_detail(source_id,source_code);
Fetch c_estimate_detail INTO l_estimate_detail_id;
Close c_estimate_detail;
l_Charges_Rec.estimate_detail_id  := l_estimate_detail_id;
l_Charges_Rec.source_code := source_code;
l_Charges_Rec.source_id := source_id;
l_Charges_Rec.inventory_item_id_in := inventory_item_id;
l_charges_rec.unit_of_measure_code := unit_of_measure_code;
l_charges_rec.quantity_required := quantity_required;
l_charges_rec.txn_billing_type_id := txn_billing_type;

Cs_Charge_Details_Pub.Update_Charge_Details (
			p_API_VERSION	     => 1.0,
			p_INIT_MSG_LIST     => FND_API.G_TRUE,
			p_COMMIT            => FND_API.G_FALSE,
			p_VALIDATION_LEVEL	=> FND_API.G_VALID_LEVEL_FULL,
			X_Return_Status     => OUT_X_Return_status,
			X_Msg_Count         => OUT_X_Msg_Count,
			X_Object_Version_Number => l_object_version_number,
		     X_MSG_DATA          => OUT_X_MSG_DATA,
			p_resp_appl_id      => NULL,
               p_resp_id           => NULL,
			p_user_id           => NULL,
			p_login_id          => NULL,
               p_transaction_control => FND_API.G_TRUE,
               p_charges_rec        => l_charges_rec);
END UPDATE_CHARGES;

PROCEDURE DELETE_CHARGES (SOURCE_ID IN NUMBER,
					 SOURCE_CODE IN  VARCHAR2,
					 OUT_X_Return_status OUT NOCOPY VARCHAR2,
					 OUT_X_Msg_Count OUT NOCOPY NUMBER,
					 OUT_X_MSG_DATA OUT NOCOPY VARCHAR2 ) IS

Cursor c_estimate_detail(p_source_id NUMBER,p_source_code Varchar2) IS
  select estimate_detail_id
  FROM   cs_estimate_details
  WHERE  source_id = p_source_id
  AND    source_code = p_source_code;

l_estimate_detail_id NUMBER;
BEGIN
Open c_estimate_detail(source_id,source_code);
Fetch c_estimate_detail INTO l_estimate_detail_id;
Close c_estimate_detail;

Cs_Charge_Details_pub.Delete_Charge_Details (
			p_API_VERSION	     => 1.0,
			p_INIT_MSG_LIST     => FND_API.G_TRUE,
			p_COMMIT            => FND_API.G_FALSE,
			p_VALIDATION_LEVEL	=> FND_API.G_VALID_LEVEL_FULL,
			X_Return_Status     => OUT_X_Return_status,
			X_Msg_Count         => OUT_X_Msg_Count,
		     X_MSG_DATA          => OUT_X_MSG_DATA,
			p_TRANSACTION_CONTROL =>  FND_API.G_TRUE,
			p_ESTIMATE_DETAIL_ID => l_Estimate_Detail_ID);
END  DELETE_CHARGES;

end CSF_DEBRIEF_CHARGES;




/
