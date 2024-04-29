--------------------------------------------------------
--  DDL for Package Body CSD_PROCESS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_PROCESS_UTIL" as
/* $Header: csdvutlb.pls 120.33.12010000.10 2010/04/30 21:33:36 nnadig ship $ */

G_PKG_NAME    CONSTANT VARCHAR2(30) := 'CSD_PROCESS_UTIL';
G_FILE_NAME   CONSTANT VARCHAR2(12) := 'csdvutlb.pls';
g_debug NUMBER := csd_gen_utility_pvt.g_debug_level;
-- bug#7355526, nnadig.
-- cache for maintaining the inventory parameters for negative inventory.
type negative_inventory is table of NUMBER index by pls_integer;
type override_negative_qty is table of number index by pls_integer;
g_negative_inventory negative_inventory;
g_override_negative_qty override_negative_qty;
-- end bug#7355526, nnadig.


/*
-- bug fix for 4108369, Begin
FUNCTION Get_Sr_add_to_order (
	 p_repair_line_Id IN NUMBER,
	 p_action_type IN VARCHAR2
    ) RETURN NUMBER;
-- bug fix for 4108369, End
*/
PROCEDURE Check_Reqd_Param (
  p_param_value	    IN	NUMBER,
  p_param_name		IN	VARCHAR2,
  p_api_name		IN	VARCHAR2
  )
IS

BEGIN

  IF (NVL(p_param_value,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM) THEN
    FND_MESSAGE.SET_NAME('CSD','CSD_API_MISSING_PARAM');
    FND_MESSAGE.SET_TOKEN('API_NAME',p_api_name);
    FND_MESSAGE.SET_TOKEN('MISSING_PARAM',p_param_name);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

END Check_Reqd_Param;

PROCEDURE Check_Reqd_Param (
  p_param_value	    IN	VARCHAR2,
  p_param_name		IN	VARCHAR2,
  p_api_name		IN	VARCHAR2
  )
IS

BEGIN

  IF (NVL(p_param_value,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR) THEN
    FND_MESSAGE.SET_NAME('CSD','CSD_API_MISSING_PARAM');
    FND_MESSAGE.SET_TOKEN('API_NAME',p_api_name);
    FND_MESSAGE.SET_TOKEN('MISSING_PARAM',p_param_name);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

END Check_Reqd_Param;

PROCEDURE Check_Reqd_Param (
  p_param_value	    IN	DATE,
  p_param_name		IN	VARCHAR2,
  p_api_name		IN	VARCHAR2
  )
IS

BEGIN

  IF (NVL(p_param_value,FND_API.G_MISS_DATE) = FND_API.G_MISS_DATE) THEN
    FND_MESSAGE.SET_NAME('CSD','CSD_API_MISSING_PARAM');
    FND_MESSAGE.SET_TOKEN('API_NAME',p_api_name);
    FND_MESSAGE.SET_TOKEN('MISSING_PARAM',p_param_name);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

END Check_Reqd_Param;

FUNCTION Get_No_Chg_Flag
( p_txn_billing_type_id   IN	NUMBER
 ) RETURN VARCHAR2
 IS
   l_no_chg_flag varchar2(1);
BEGIN
  Begin
    Select Nvl(ctt.no_charge_flag,'N')
    into l_no_chg_flag
    from cs_txn_billing_types ctbt,
	    cs_transaction_types ctt
    where ctbt.transaction_type_id = ctt.transaction_type_id
    and   ctbt.txn_billing_type_id = p_txn_billing_type_id;
    Return l_no_chg_flag;
  Exception
    When No_data_found then
      FND_MESSAGE.SET_NAME('CSD','CSD_API_INV_TXN_BILL_TYPE_ID');
      FND_MESSAGE.SET_TOKEN('TXN_BILLING_TYPE_ID',p_txn_billing_type_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    When Others then
      FND_MESSAGE.SET_NAME('CSD','CSD_API_INV_TXN_BILL_TYPE_ID');
      FND_MESSAGE.SET_TOKEN('TXN_BILLING_TYPE_ID',p_txn_billing_type_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
  End;
END Get_No_Chg_Flag;


FUNCTION Validate_action
(
  p_action        IN	VARCHAR2,
  p_api_name	  IN	VARCHAR2
 ) RETURN BOOLEAN
IS

BEGIN

  IF (p_api_name = 'PROCESS_CHARGE_LINES') THEN
   IF (p_action not in ('CREATE','UPDATE','DELETE')) THEN
    FND_MESSAGE.SET_NAME('CSD','CSD_API_INV_ACTION');
    FND_MESSAGE.SET_TOKEN('API_NAME',p_api_name);
    FND_MESSAGE.SET_TOKEN('ACTION',p_action);
    FND_MSG_PUB.Add;
    RETURN FALSE;
   ELSE
    RETURN TRUE;
   END IF;

  ELSIF  (p_api_name = 'PROCESS_SALES_ORDER') THEN
   IF (p_action not in ('CREATE','BOOK','PICK-RELEASE','SHIP')) THEN
    FND_MESSAGE.SET_NAME('CSD','CSD_API_INV_ACTION');
    FND_MESSAGE.SET_TOKEN('API_NAME',p_api_name);
    FND_MESSAGE.SET_TOKEN('ACTION',p_action);
    FND_MSG_PUB.Add;
    RETURN FALSE;
   ELSE
    RETURN TRUE;
   END IF;

  END IF;

END Validate_action;

FUNCTION Validate_incident_id
(
  p_incident_id	  IN	NUMBER
 ) RETURN BOOLEAN
 IS

l_dummy   VARCHAR2(1);

BEGIN

 select 'X'
 into l_dummy
 from cs_incidents_all_b
 where incident_id = p_incident_id;
 -- swai: bug 7273784 - start_date_active and end_date_active
 -- are obsoleted by service team
 -- and   sysdate between nvl(start_date_active,sysdate)
 -- and nvl(end_date_active, sysdate);

 RETURN TRUE;
EXCEPTION
When NO_DATA_FOUND then
    FND_MESSAGE.SET_NAME('CSD','CSD_API_INV_SR_ID');
    FND_MESSAGE.SET_TOKEN('INCIDENT_ID',p_incident_id);
    FND_MSG_PUB.Add;
    RETURN FALSE;
END Validate_incident_id;

FUNCTION Validate_repair_type_id
(
  p_repair_type_id	  IN	NUMBER
 ) RETURN BOOLEAN
 IS

l_dummy   VARCHAR2(1);

BEGIN

 select 'X'
 into l_dummy
 from csd_repair_types_vl
 where repair_type_id = p_repair_type_id
 and   sysdate between nvl(start_date_active,sysdate)
 and nvl(end_date_active, sysdate);

 RETURN TRUE;
EXCEPTION
When NO_DATA_FOUND then
    FND_MESSAGE.SET_NAME('CSD','CSD_API_REPAIR_TYPE_ID');
    FND_MESSAGE.SET_TOKEN('REPAIR_TYPE_ID',p_repair_type_id);
    FND_MSG_PUB.Add;
    RETURN FALSE;
END Validate_repair_type_id;

FUNCTION Validate_wip_entity_id
(
  p_wip_entity_id	  IN	NUMBER
 ) RETURN BOOLEAN
 IS

l_dummy   VARCHAR2(1);

BEGIN

 select 'X'
 into l_dummy
 from wip_discrete_jobs
 where wip_entity_id = p_wip_entity_id;

 RETURN TRUE;
EXCEPTION
When NO_DATA_FOUND then
    FND_MESSAGE.SET_NAME('CSD','CSD_API_WIP_ENTITY_ID');
    FND_MESSAGE.SET_TOKEN('WIP_ENTITY_ID',p_wip_entity_id);
    FND_MSG_PUB.Add;
    RETURN FALSE;
END Validate_wip_entity_id;

FUNCTION Validate_repair_group_id
(
  p_repair_group_id	  IN	NUMBER
 ) RETURN BOOLEAN
 IS

l_dummy   VARCHAR2(1);

BEGIN

 select 'X'
 into l_dummy
 from csd_repair_order_groups
 where repair_group_id = p_repair_group_id;

 RETURN TRUE;
EXCEPTION
When NO_DATA_FOUND then
    FND_MESSAGE.SET_NAME('CSD','CSD_API_REPAIR_GROUP_ID');
    FND_MESSAGE.SET_TOKEN('REPAIR_GROUP_ID',p_repair_group_id);
    FND_MSG_PUB.Add;
    RETURN FALSE;
END Validate_repair_group_id;

FUNCTION Validate_ro_job_date
(
  p_date  IN  DATE
 ) RETURN BOOLEAN
 IS

l_dummy   VARCHAR2(1);

BEGIN

 select 'x'
 into l_dummy
 from  bom_calendar_dates
 where calendar_date = p_date;

 RETURN TRUE;
EXCEPTION
When NO_DATA_FOUND then
    FND_MESSAGE.SET_NAME('CSD','CSD_API_NOT_BOM_DATE');
    FND_MESSAGE.SET_TOKEN('DATE',p_date);
    FND_MSG_PUB.Add;
    RETURN FALSE;
When TOO_MANY_ROWS then
    RETURN TRUE;
END Validate_ro_job_date;

FUNCTION Validate_Inventory_item_id
(
  p_inventory_item_id	  IN	NUMBER
 ) RETURN BOOLEAN
 IS

l_dummy   VARCHAR2(1);
l_org_id  NUMBER;

BEGIN

 l_org_id := cs_std.get_item_valdn_orgzn_id;

 select 'X'
 into l_dummy
 from  mtl_system_items
 where inventory_item_id = p_inventory_item_id
 and   organization_id   = l_org_id
 and   sysdate between nvl(start_date_active,sysdate)
 and nvl(end_date_active, sysdate);

 RETURN TRUE;
EXCEPTION
When NO_DATA_FOUND then
    FND_MESSAGE.SET_NAME('CSD','CSD_API_INV_ITEM_ID');
    FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID',p_inventory_item_id);
    FND_MSG_PUB.Add;
    RETURN FALSE;
END Validate_inventory_item_id;

FUNCTION Validate_Unit_of_measure
(
  p_unit_of_measure	  IN	VARCHAR2
 ) RETURN BOOLEAN
 IS

l_dummy   VARCHAR2(1);

BEGIN


 select 'X'
 into l_dummy
 from  mtl_units_of_measure_vl
 where uom_code = p_unit_of_measure
 and   sysdate between nvl(creation_date,sysdate)
 and nvl(disable_date, sysdate);

 RETURN TRUE;
EXCEPTION
When NO_DATA_FOUND then
    FND_MESSAGE.SET_NAME('CSD','CSD_API_UOM');
    FND_MESSAGE.SET_TOKEN('UNIT_OF_MEASURE',p_unit_of_measure);
    FND_MSG_PUB.Add;
END Validate_Unit_of_measure;


PROCEDURE Convert_Est_to_Chg_rec
(
  p_estimate_line_rec  IN	CSD_REPAIR_ESTIMATE_PVT.REPAIR_ESTIMATE_LINE_REC,
  x_charges_rec        OUT NOCOPY	CS_CHARGE_DETAILS_PUB.CHARGES_REC_TYPE,
  x_return_status      OUT NOCOPY	VARCHAR2
 ) IS

BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS;


 x_charges_rec.estimate_detail_id          := p_estimate_line_rec.estimate_detail_id;
 x_charges_rec.incident_id                 := p_estimate_line_rec.incident_id;
 x_charges_rec.original_source_id          := p_estimate_line_rec.repair_line_id;
 x_charges_rec.original_source_code        := 'DR' ;
 x_charges_rec.source_id                   := p_estimate_line_rec.repair_line_id;
 x_charges_rec.source_code                 := 'DR' ;
 x_charges_rec.LINE_TYPE_ID                := p_estimate_line_rec.LINE_TYPE_ID;
 x_charges_rec.txn_billing_type_id         := p_estimate_line_rec.txn_billing_type_id;
 x_charges_rec.business_process_id         := p_estimate_line_rec.business_process_id;
 x_charges_rec.inventory_item_id_in        := p_estimate_line_rec.inventory_item_id;
 x_charges_rec.price_list_id               := p_estimate_line_rec.price_list_id;
 x_charges_rec.currency_code               := p_estimate_line_rec.currency_code;
 x_charges_rec.quantity_required           := p_estimate_line_rec.estimate_quantity;
 x_charges_rec.unit_of_measure_code        := p_estimate_line_rec.unit_of_measure_code;
 x_charges_rec.customer_product_id         := p_estimate_line_rec.customer_product_id;
 x_charges_rec.reference_number            := p_estimate_line_rec.reference_number;
 x_charges_rec.interface_to_oe_flag        := p_estimate_line_rec.interface_to_om_flag;
 x_charges_rec.no_charge_flag              := p_estimate_line_rec.no_charge_flag;
 x_charges_rec.add_to_order_flag           := p_estimate_line_rec.add_to_order_flag;
 x_charges_rec.rollup_flag                 := FND_API.G_MISS_CHAR;
 x_charges_rec.LINE_CATEGORY_CODE          := p_estimate_line_rec.LINE_CATEGORY_CODE;
 x_charges_rec.RETURN_REASON_CODE          := p_estimate_line_rec.RETURN_REASON;
 x_charges_rec.contract_id                 := p_estimate_line_rec.contract_id;
 --R12 contracts changes
 x_charges_rec.contract_line_id            := p_estimate_line_rec.contract_line_id;
 x_charges_rec.coverage_id                 := p_estimate_line_rec.coverage_id;
 x_charges_rec.coverage_txn_group_id       := p_estimate_line_rec.coverage_txn_group_id;
 x_charges_rec.coverage_bill_rate_id       := p_estimate_line_rec.coverage_bill_rate_id;
 x_charges_rec.invoice_to_org_id           := p_estimate_line_rec.invoice_to_org_id;
 x_charges_rec.ship_to_org_id              := p_estimate_line_rec.ship_to_org_id;
 x_charges_rec.item_revision			      := p_estimate_line_rec.item_revision;
 x_charges_rec.after_warranty_cost         := p_estimate_line_rec.after_warranty_cost;
 x_charges_rec.serial_number               := p_estimate_line_rec.serial_number;
 x_charges_rec.original_source_number      := p_estimate_line_rec.original_source_number;
 x_charges_rec.purchase_order_num          := p_estimate_line_rec.purchase_order_num;
 x_charges_rec.source_number               := p_estimate_line_rec.source_number;
 x_charges_rec.inventory_item_id_out       := FND_API.G_MISS_NUM;
 x_charges_rec.serial_number_out           := p_estimate_line_rec.serial_number;
 x_charges_rec.order_header_id             := p_estimate_line_rec.order_header_id;
 x_charges_rec.order_line_id               := p_estimate_line_rec.order_line_id;
 x_charges_rec.original_system_reference   := p_estimate_line_rec.original_system_reference;
 x_charges_rec.selling_price               := p_estimate_line_rec.selling_price;
 x_charges_rec.EXCEPTION_COVERAGE_USED     := FND_API.G_MISS_CHAR;
 --x_charges_rec.organization_id             := FND_API.G_MISS_NUM;
 --x_charges_rec.customer_id                 := FND_API.G_MISS_NUM;
 -- travi new
 -- EST_TAX_AMOUNT was giving error
 -- x_charges_rec.EST_TAX_AMOUNT              := FND_API.G_MISS_NUM;
 x_charges_rec.charge_line_type            := p_estimate_line_rec.charge_line_type;
 x_charges_rec.apply_contract_discount     := p_estimate_line_rec.apply_contract_discount;
 x_charges_rec.coverage_id                 := p_estimate_line_rec.coverage_id;
 x_charges_rec.coverage_txn_group_id       := p_estimate_line_rec.coverage_txn_group_id;
 x_charges_rec.transaction_type_id         := p_estimate_line_rec.transaction_type_id;
 -- swai bug fix 3099740
 -- add contract discount amount to pass to charges
 x_charges_rec.contract_discount_amount    := p_estimate_line_rec.contract_discount_amount;
 -- end swai bug fix 3099740

 x_charges_rec.pricing_context             := p_estimate_line_rec.pricing_context;
 x_charges_rec.pricing_attribute1          := p_estimate_line_rec.pricing_attribute1;
 x_charges_rec.pricing_attribute2          := p_estimate_line_rec.pricing_attribute2;
 x_charges_rec.pricing_attribute3          := p_estimate_line_rec.pricing_attribute3;
 x_charges_rec.pricing_attribute4          := p_estimate_line_rec.pricing_attribute4;
 x_charges_rec.pricing_attribute5          := p_estimate_line_rec.pricing_attribute5;
 x_charges_rec.pricing_attribute6          := p_estimate_line_rec.pricing_attribute6;
 x_charges_rec.pricing_attribute7          := p_estimate_line_rec.pricing_attribute7;
 x_charges_rec.pricing_attribute8          := p_estimate_line_rec.pricing_attribute8;
 x_charges_rec.pricing_attribute9          := p_estimate_line_rec.pricing_attribute9;
 x_charges_rec.pricing_attribute10         := p_estimate_line_rec.pricing_attribute10;
 x_charges_rec.pricing_attribute11         := p_estimate_line_rec.pricing_attribute11;
 x_charges_rec.pricing_attribute12         := p_estimate_line_rec.pricing_attribute12;
 x_charges_rec.pricing_attribute13         := p_estimate_line_rec.pricing_attribute13;
 x_charges_rec.pricing_attribute14         := p_estimate_line_rec.pricing_attribute14;
 x_charges_rec.pricing_attribute15         := p_estimate_line_rec.pricing_attribute15;
 x_charges_rec.pricing_attribute16         := p_estimate_line_rec.pricing_attribute16;
 x_charges_rec.pricing_attribute17         := p_estimate_line_rec.pricing_attribute17;
 x_charges_rec.pricing_attribute18         := p_estimate_line_rec.pricing_attribute18;
 x_charges_rec.pricing_attribute19         := p_estimate_line_rec.pricing_attribute19;
 x_charges_rec.pricing_attribute20         := p_estimate_line_rec.pricing_attribute20;
 x_charges_rec.pricing_attribute21         := p_estimate_line_rec.pricing_attribute21;
 x_charges_rec.pricing_attribute22          := p_estimate_line_rec.pricing_attribute22;
 x_charges_rec.pricing_attribute23          := p_estimate_line_rec.pricing_attribute23;
 x_charges_rec.pricing_attribute24          := p_estimate_line_rec.pricing_attribute24;
 x_charges_rec.pricing_attribute25          := p_estimate_line_rec.pricing_attribute25;
 x_charges_rec.pricing_attribute26          := p_estimate_line_rec.pricing_attribute26;
 x_charges_rec.pricing_attribute27          := p_estimate_line_rec.pricing_attribute27;
 x_charges_rec.pricing_attribute28          := p_estimate_line_rec.pricing_attribute28;
 x_charges_rec.pricing_attribute29          := p_estimate_line_rec.pricing_attribute29;
 x_charges_rec.pricing_attribute30          := p_estimate_line_rec.pricing_attribute30;
 x_charges_rec.pricing_attribute31          := p_estimate_line_rec.pricing_attribute31;
 x_charges_rec.pricing_attribute32          := p_estimate_line_rec.pricing_attribute32;
 x_charges_rec.pricing_attribute33          := p_estimate_line_rec.pricing_attribute33;
 x_charges_rec.pricing_attribute34          := p_estimate_line_rec.pricing_attribute34;
 x_charges_rec.pricing_attribute35          := p_estimate_line_rec.pricing_attribute35;
 x_charges_rec.pricing_attribute36          := p_estimate_line_rec.pricing_attribute36;
 x_charges_rec.pricing_attribute37          := p_estimate_line_rec.pricing_attribute37;
 x_charges_rec.pricing_attribute38          := p_estimate_line_rec.pricing_attribute38;
 x_charges_rec.pricing_attribute39          := p_estimate_line_rec.pricing_attribute39;
 x_charges_rec.pricing_attribute40          := p_estimate_line_rec.pricing_attribute40;
 x_charges_rec.pricing_attribute41          := p_estimate_line_rec.pricing_attribute41;
 x_charges_rec.pricing_attribute42          := p_estimate_line_rec.pricing_attribute42;
 x_charges_rec.pricing_attribute43          := p_estimate_line_rec.pricing_attribute43;
 x_charges_rec.pricing_attribute44          := p_estimate_line_rec.pricing_attribute44;
 x_charges_rec.pricing_attribute45          := p_estimate_line_rec.pricing_attribute45;
 x_charges_rec.pricing_attribute46          := p_estimate_line_rec.pricing_attribute46;
 x_charges_rec.pricing_attribute47          := p_estimate_line_rec.pricing_attribute47;
 x_charges_rec.pricing_attribute48          := p_estimate_line_rec.pricing_attribute48;
 x_charges_rec.pricing_attribute49          := p_estimate_line_rec.pricing_attribute49;
 x_charges_rec.pricing_attribute50          := p_estimate_line_rec.pricing_attribute50;
 x_charges_rec.pricing_attribute51          := p_estimate_line_rec.pricing_attribute51;
 x_charges_rec.pricing_attribute52          := p_estimate_line_rec.pricing_attribute52;
 x_charges_rec.pricing_attribute53          := p_estimate_line_rec.pricing_attribute53;
 x_charges_rec.pricing_attribute54          := p_estimate_line_rec.pricing_attribute54;
 x_charges_rec.pricing_attribute55          := p_estimate_line_rec.pricing_attribute55;
 x_charges_rec.pricing_attribute56          := p_estimate_line_rec.pricing_attribute56;
 x_charges_rec.pricing_attribute57          := p_estimate_line_rec.pricing_attribute57;
 x_charges_rec.pricing_attribute58          := p_estimate_line_rec.pricing_attribute58;
 x_charges_rec.pricing_attribute59          := p_estimate_line_rec.pricing_attribute59;
 x_charges_rec.pricing_attribute60          := p_estimate_line_rec.pricing_attribute60;
 x_charges_rec.pricing_attribute61          := p_estimate_line_rec.pricing_attribute61;
 x_charges_rec.pricing_attribute62          := p_estimate_line_rec.pricing_attribute62;
 x_charges_rec.pricing_attribute63          := p_estimate_line_rec.pricing_attribute63;
 x_charges_rec.pricing_attribute64          := p_estimate_line_rec.pricing_attribute64;
 x_charges_rec.pricing_attribute65          := p_estimate_line_rec.pricing_attribute65;
 x_charges_rec.pricing_attribute66          := p_estimate_line_rec.pricing_attribute66;
 x_charges_rec.pricing_attribute67          := p_estimate_line_rec.pricing_attribute67;
 x_charges_rec.pricing_attribute68          := p_estimate_line_rec.pricing_attribute68;
 x_charges_rec.pricing_attribute69          := p_estimate_line_rec.pricing_attribute69;
 x_charges_rec.pricing_attribute70          := p_estimate_line_rec.pricing_attribute70;
 x_charges_rec.pricing_attribute71          := p_estimate_line_rec.pricing_attribute71;
 x_charges_rec.pricing_attribute72          := p_estimate_line_rec.pricing_attribute72;
 x_charges_rec.pricing_attribute73          := p_estimate_line_rec.pricing_attribute73;
 x_charges_rec.pricing_attribute74          := p_estimate_line_rec.pricing_attribute74;
 x_charges_rec.pricing_attribute75          := p_estimate_line_rec.pricing_attribute75;
 x_charges_rec.pricing_attribute76          := p_estimate_line_rec.pricing_attribute76;
 x_charges_rec.pricing_attribute77          := p_estimate_line_rec.pricing_attribute77;
 x_charges_rec.pricing_attribute78          := p_estimate_line_rec.pricing_attribute78;
 x_charges_rec.pricing_attribute79          := p_estimate_line_rec.pricing_attribute79;
 x_charges_rec.pricing_attribute80          := p_estimate_line_rec.pricing_attribute80;
 x_charges_rec.pricing_attribute81          := p_estimate_line_rec.pricing_attribute81;
 x_charges_rec.pricing_attribute82          := p_estimate_line_rec.pricing_attribute82;
 x_charges_rec.pricing_attribute83          := p_estimate_line_rec.pricing_attribute83;
 x_charges_rec.pricing_attribute84          := p_estimate_line_rec.pricing_attribute84;
 x_charges_rec.pricing_attribute85          := p_estimate_line_rec.pricing_attribute85;
 x_charges_rec.pricing_attribute86          := p_estimate_line_rec.pricing_attribute86;
 x_charges_rec.pricing_attribute87          := p_estimate_line_rec.pricing_attribute87;
 x_charges_rec.pricing_attribute88          := p_estimate_line_rec.pricing_attribute88;
 x_charges_rec.pricing_attribute89          := p_estimate_line_rec.pricing_attribute89;
 x_charges_rec.pricing_attribute90          := p_estimate_line_rec.pricing_attribute90;
 x_charges_rec.pricing_attribute91          := p_estimate_line_rec.pricing_attribute91;
 x_charges_rec.pricing_attribute92          := p_estimate_line_rec.pricing_attribute92;
 x_charges_rec.pricing_attribute93          := p_estimate_line_rec.pricing_attribute93;
 x_charges_rec.pricing_attribute94          := p_estimate_line_rec.pricing_attribute94;
 x_charges_rec.pricing_attribute95          := p_estimate_line_rec.pricing_attribute95;
 x_charges_rec.pricing_attribute96          := p_estimate_line_rec.pricing_attribute96;
 x_charges_rec.pricing_attribute97          := p_estimate_line_rec.pricing_attribute97;
 x_charges_rec.pricing_attribute98          := p_estimate_line_rec.pricing_attribute98;
 x_charges_rec.pricing_attribute99          := p_estimate_line_rec.pricing_attribute99;
 x_charges_rec.pricing_attribute100         := p_estimate_line_rec.pricing_attribute100;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.G_RET_STS_ERROR ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END Convert_Est_to_Chg_rec;

PROCEDURE get_incident_id
(
  p_repair_line_id     IN	NUMBER,
  x_incident_id        OUT NOCOPY	NUMBER,
  x_return_status      OUT NOCOPY	VARCHAR2
) IS

BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS ;

select
  incident_id
into x_incident_id
from csd_repairs
where repair_line_id = p_repair_line_id
 and  ((date_closed is null) OR (date_closed > sysdate));
EXCEPTION
 WHEN NO_DATA_FOUND THEN
    x_return_status :=  FND_API.G_RET_STS_ERROR ;
    FND_MESSAGE.SET_NAME('CSD','CSD_API_INV_REP_LINE_ID');
    FND_MESSAGE.SET_TOKEN('REPAIR_LINE_ID',p_repair_line_id);
    FND_MSG_PUB.Add;
 WHEN OTHERS THEN
    x_return_status :=  FND_API.G_RET_STS_ERROR ;
    FND_MESSAGE.SET_NAME('CSD','CSD_API_INV_REP_LINE_ID');
    FND_MESSAGE.SET_TOKEN('REPAIR_LINE_ID',p_repair_line_id);
    FND_MSG_PUB.Add;
END get_incident_id;


-- ***************************************************************************************
-- Fixed for bug#5190905
--
-- Procedure name: csd_get_txn_billing_type
-- description :   Ideally, the RT setup should capture SACs 'RMA'/'Ship' only (not SAC-BT) and select
--                 billing type based on the item attribute at the time of default prod txn creation.
--                 This API return the correct txn_billing_type_id based on Item billing type and service
--                 activity (Transaction_type_id).
--                 If transaction_type_id is not passed to this API then it derive the transaction_type_id
--                 using parameter p_txn_billing_type_id and then it derive the correct txn_billing_type_id
--                 for transaction.
-- Called from   : WVI trigger of rcv_ship.TRANSACTION_TYPE and CSD_PROCESS_UTIL.build_prodtxn_tbl_int
-- Input Parm    : p_api_version         NUMBER      Api Version number
--                 p_init_msg_list       VARCHAR2    Initializes message stack if fnd_api.g_true,
--                                                   default value is fnd_api.g_false
--		   p_incident_id         NUMBER      incident id of service request
--                 p_inventory_item_id   NUMBER
--                 p_transaction_type_id NUMBER
--                 p_txn_billing_type_id NUMBER      txn_billing_type_id (Service activity billing type SAC-BT)
--                                                   selected by user in RO type setup form. This can be pre/post
--                                                   repair RMA service activity or pre/post SHIP repair Service activity
-- Output Parm   :
--                 x_txn_billing_type_id NUMBER      New Txn_billing_type_Id based on transaction
--                                                   type and billing type of Item
--                 x_return_status       VARCHAR2    Return status after the call. The status can be
--                                                   fnd_api.g_ret_sts_success (success)
--                                                   fnd_api.g_ret_sts_error (error)
--                                                   fnd_api.g_ret_sts_unexp_error (unexpected)
--                 x_msg_count           NUMBER      Number of messages in the message stack
--                 x_msg_data            VARCHAR2    Message text if x_msg_count >= 1
-- **************************************************************************************

Procedure csd_get_txn_billing_type (
              p_api_version                 IN   NUMBER,
              p_init_msg_list               IN   VARCHAR2,
              p_incident_id                 IN   NUMBER,
              p_inventory_item_id           IN   NUMBER,
              P_transaction_type_id         IN   NUMBER,
              p_txn_billing_type_id         IN   NUMBER,
              x_txn_billing_type_id     OUT NOCOPY NUMBER,
              x_return_status           OUT NOCOPY VARCHAR2 ,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2
              )
Is
  l_api_name                    CONSTANT VARCHAR2(30) := 'CSD_GET_TXN_BILLING_TYPE';
  l_api_version                 CONSTANT NUMBER := 1.0;
  l_transaction_type_id         number;
  l_txn_billing_type_id         number;
  l_org_id                      NUMBER;
  l_billing_type                VARCHAR2(30);
  l_operating_unit              NUMBER;
  l_profile                     varchar2(1);

cursor valid_txn_billing_type is
     select tbt.txn_billing_type_id
     from cs_transaction_types_b tt,
          cs_txn_billing_types tbt,
          cs_billing_type_categories cbtc,
          cs_txn_billing_oetxn_all tb,
          oe_transaction_types_vl oeh,
          oe_transaction_types_vl oel
     where
         tt.transaction_type_id = l_transaction_type_id
     and nvl(tt.depot_repair_flag,'N')='Y'
     and tt.transaction_type_id=tbt.transaction_type_id
     and tbt.billing_type = l_billing_type
     and tbt.txn_billing_type_id=tb.txn_billing_type_id
	and  tb.org_id = l_operating_unit  /*Operating unit */
     and tb.order_type_id=oeh.transaction_type_id
     and tb.line_type_id=oel.transaction_type_id
     and sysdate between nvl(cbtc.start_date_active, sysdate) and nvl(cbtc.end_date_active,sysdate)
     and (sysdate) between nvl(tt.start_date_active,(sysdate)) and nvl(tt.end_date_active,(sysdate))
     and cbtc.billing_type = tbt.billing_type
     and nvl(cbtc.billing_category, '-999') ='M';

begin
    csd_gen_utility_pvt.add('At the Begin in ');

    csd_gen_utility_pvt.dump_api_info ( p_pkg_name  => G_PKG_NAME,
                                        p_api_name  => l_api_name );

    csd_gen_utility_pvt.add('P_incident_id         ='||P_incident_id);
    csd_gen_utility_pvt.add('p_inventory_item_id   ='||p_inventory_item_id );
    csd_gen_utility_pvt.add('P_transaction_type_id ='||P_transaction_type_id);
    csd_gen_utility_pvt.add('p_txn_billing_type_id ='||p_txn_billing_type_id);

    /*Initialize message list if p_init_msg_list is set to TRUE.*/
    IF FND_API.to_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;

    /*Initialize API return status to success*/
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_org_id := cs_std.get_item_valdn_orgzn_id;

    /*Derive the operating unit */
    IF csd_process_util.is_multiorg_enabled THEN
       CS_MultiOrg_Pub.Get_OrgId(
	      P_API_VERSION    => 1.0,
		 P_INIT_MSG_LIST  => 'F',
		 P_COMMIT         => 'F',
		 P_VALIDATION_LEVEL => 100,
		 P_INCIDENT_ID    => P_incident_id,
		 X_RETURN_STATUS  => x_return_status,
		 X_MSG_COUNT      => x_msg_count,
		 X_MSG_DATA       => x_msg_data,
		 X_ORG_ID         => l_operating_unit,
		 X_PROFILE        => l_profile);
	  IF (x_return_status <> CSD_PROCESS_UTIL.G_RET_STS_SUCCESS) THEN
	     csd_gen_utility_pvt.ADD('Error in Deriving the Operating Unit ');
	  END IF;
    ELSE
      Fnd_Profile.Get('ORG_ID',l_operating_unit);
    END IF;

    csd_gen_utility_pvt.add('l_operating_unit  ='||l_operating_unit);

    begin
     select MATERIAL_BILLABLE_FLAG
     into   l_billing_type
     from  mtl_system_items_B
     where inventory_item_id = p_inventory_item_id
     and   organization_id   = l_org_id
     and   sysdate between nvl(start_date_active,sysdate)
     and nvl(end_date_active, sysdate);
    EXCEPTION
    When NO_DATA_FOUND then
        FND_MESSAGE.SET_NAME('CSD','CSD_API_INV_ITEM_ID');
        FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID',p_inventory_item_id);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    End;

    csd_gen_utility_pvt.add('Item billing type is     ='||l_billing_type);


   l_transaction_type_id:= P_transaction_type_id;

   If l_transaction_type_id IS NULL then /*Derive Txn type id only if it is null */

     /*Derive Service activity from SAC-BT combination*/
     begin
     select tbt.transaction_type_id
     into   l_transaction_type_id
     from   cs_txn_billing_types tbt
     where txn_billing_type_id = p_txn_billing_type_id;
/* Fixed for bug#5662028
     and  (sysdate) between nvl(tbt.start_date_active,(sysdate))
                            and nvl(tbt.end_date_active,(sysdate));
*/
     exception
      When No_data_found then
        csd_gen_utility_pvt.add('No record found for p_txn_billing_type_id='||p_txn_billing_type_id);
        FND_MESSAGE.SET_NAME('CSD','CSD_API_INV_TXN_BILL_TYPE_ID');
        FND_MESSAGE.SET_TOKEN('TXN_BILLING_TYPE_ID',p_txn_billing_type_id);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      When Others then
        FND_MESSAGE.SET_NAME('CSD','CSD_API_INV_TXN_BILL_TYPE_ID');
        FND_MESSAGE.SET_TOKEN('TXN_BILLING_TYPE_ID',p_txn_billing_type_id);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
     end;
    END IF; /*end if l_transaction_type_id */

  open valid_txn_billing_type;
  Fetch valid_txn_billing_type
  into  l_txn_billing_type_id;

  IF valid_txn_billing_type%isopen then
    CLOSE valid_txn_billing_type;
  END IF;

  If l_txn_billing_type_id is not null then
     x_txn_billing_type_id:= l_txn_billing_type_id;
  else
     FND_MESSAGE.SET_NAME('CSD','CSD_INV_SERVICE_BILLING_TYPE');
     FND_MSG_PUB.Add;
     RAISE FND_API.G_EXC_ERROR;
  end if;

Exception
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                 p_data   =>  x_msg_data);
   when others then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                 p_data   =>  x_msg_data);
end csd_get_txn_billing_type;



/**********************
This proc is changed to be an internal proc with more params.
The private api build_prod_txn_tbl is changed to call this.
*****************************************/
PROCEDURE build_prodtxn_tbl_int
( p_repair_line_id     IN	NUMBER,
  p_quantity           IN   NUMBER,
  p_Serial_number      IN   VARCHAR2,
  p_instance_id        IN   NUMBER,
  p_create_thirdpty_line IN VARCHAR2 := fnd_api.g_false,
  x_prod_txn_tbl       OUT NOCOPY	csd_process_pvt.product_txn_tbl,
  x_return_status      OUT NOCOPY	VARCHAR2
 ) IS
-- bug fix for 4108369, Begin
  l_sr_add_to_order_flag  VARCHAR2(10);
  l_add_rma_to_id       NUMBER;
  l_add_ship_to_id      NUMBER;
-- bug fix for 4108369, End
 l_repair_type_ref          VARCHAR2(3) := '';
 l_auto_process_rma         VARCHAR2(1) := '';
 l_inv_item_id              NUMBER  := NULL;
 l_inv_revision             VARCHAR2(3)  := '';
 l_contract_id              NUMBER  := NULL;
 -- R12 contract changes
 -- fix made because of charges API problem. earlier contract_line was
 -- accepted in contract_id column, now charges api expects contract_id
 -- in contract_id, contract_line_id in contract_line_id columns
 l_contract_line_id              NUMBER  := NULL;

 l_unit_of_measure          VARCHAR2(30) := '';
 l_price_list_id            NUMBER  := NULL;
 l_price_list               VARCHAR2(30) := '';
 l_return_reason            VARCHAR2(30) := '';
 l_org_id                   NUMBER  := NULL;
 l_incident_id              NUMBER  := NULL;
 l_inv_org_id	            NUMBER := NULL;
 l_revision                 VARCHAR2(30) := '';
 l_bus_process_id           NUMBER  := NULL;
 l_price_list_header_id     NUMBER  := NULL;
 l_cps_txn_billing_type_id  NUMBER := NULL;
 l_cpr_txn_billing_type_id  NUMBER := NULL;
 l_ls_txn_billing_type_id   NUMBER := NULL;
 l_lr_txn_billing_type_id   NUMBER := NULL;
 l_ib_flag                  VARCHAR2(1);
 l_serial_num_control_code  NUMBER;
 C_Replacement              Varchar2(30):= 'REPLACEMENT' ;
 l_po_number                VARCHAR2(50);  -- swai bug fix 4535829
 l_interface_to_om_flag     VARCHAR2(1) :='';
 l_book_sales_order_flag    VARCHAR2(1) :='';

 l_third_rma_txn_b_type_id   NUMBER := NULL;
 l_third_ship_txn_b_type_id   NUMBER := NULL;
 l_third_party_flag          VARCHAR2(1) :='';
 l_index         NUMBER := 1;


 l_project_id               NUMBER := null;
 l_task_id                  NUMBER := null;
 l_unit_number              VARCHAR2(30) :='';

--Get Pricing variables
 /* bug#3875036 */
 l_selling_price		NUMBER := FND_API.G_MISS_NUM;
 l_account_id			NUMBER := null;
 l_currency_code        varchar(15);
 l_return_status        VARCHAR2(1);
 l_msg_count            NUMBER;
 l_msg_data             VARCHAR2(2000);
 l_pricing_rec			csd_process_util.pricing_attr_rec := csd_process_util.ui_pricing_attr_rec;
 l_enable_advanced_pricing	VARCHAR2(1);


 /*Bug#5190905 added below variables*/
 l_txn_billing_type_id      number:=NULL;
 x_msg_count                number;
 x_msg_data                 VARCHAR2(2000);
 /*Bug#5190905 end*/

 l_src_return_reqd           varchar2(1);  /*Fixed for FP bug#5408047*/
 l_non_src_return_reqd       varchar2(1);  /*Fixed for FP bug#5408047*/
 l_return_days               number;       /*Fixed for FP bug#5408047*/

 /*Fixed for FP bug#5408047*/
   cursor c2(p_txn_billing_type_id NUMBER) is
   select src_return_reqd
         ,non_src_return_reqd
   from csi_ib_txn_types a,
        cs_txn_billing_types b
   where a.cs_transaction_type_id = b.transaction_type_id
   and  b.txn_billing_type_id = p_txn_billing_type_id;

  CURSOR repair_line_dtls(p_rep_line_id IN NUMBER) IS
  SELECT
    crt.repair_type_ref,
    cr.auto_process_rma,
    crt.interface_to_om_flag,
    crt.book_sales_order_flag,
    cr.inventory_item_id,
    cr.item_revision,
    cr.contract_line_id,
    cr.unit_of_measure,
    crt.cps_txn_billing_type_id ,
    crt.cpr_txn_billing_type_id ,
    crt.ls_txn_billing_type_id  ,
    crt.lr_txn_billing_type_id  ,
    cr.price_list_header_id    ,
    crt.business_process_id,
    cr.incident_id,
    cr.default_po_num,   -- swai bug fix 4535829
    cr.inventory_org_id, -- inv_org_change Vijay, 3/20/06
    cr.project_id,
    cr.task_id,
    cr.unit_number,
    crt.third_rma_txn_billing_type_id,
    crt.third_ship_txn_billing_type_id,
    crt.third_party_flag
  FROM csd_repairs cr,
       csd_repair_types_vl crt
  where cr.repair_type_id = crt.repair_type_id
  and   cr.repair_line_id = p_rep_line_id;

  CURSOR get_revision(p_inv_item_id IN NUMBER,
                      p_org_id      IN NUMBER) IS
  SELECT
    revision
  FROM mtl_item_revisions
  where inventory_item_id  = p_inv_item_id
  and  organization_id    = p_org_id;

  -- Fix for bug#3549430
  CURSOR get_item_attributes(p_inv_item_id IN NUMBER,
                             p_org_id      IN NUMBER) IS
  Select
    serial_number_control_code,
    comms_nl_trackable_flag
  from mtl_system_items_kfv
  where inventory_item_id = p_inv_item_id
  and organization_id     = p_org_id;

  --picking_rule_changes for R12
  l_picking_rule_id  NUMBER;


  --R12 contracts changes
  cursor cur_contract_det(p_contract_line_id NUMBER) is
  select chr_id from okc_k_lines_b
  where id = p_contract_line_id;

  -- swai: bug 6936769
  CURSOR c_primary_account_address(p_party_id NUMBER, p_account_id NUMBER, p_org_id NUMBER, p_site_use_type VARCHAR2)
  IS
    select distinct
           hp.party_site_id
      from hz_party_sites_v hp,
           hz_parties hz,
           hz_cust_acct_sites_all hca,
           hz_cust_site_uses_all hcsu
     where hcsu.site_use_code = p_site_use_type
      and  hp.status = 'A'
      and  hcsu.status = 'A'
      and  hp.party_id = hz.party_id
      and  hp.party_id = p_party_id
      and  hca.party_site_id = hp.party_site_id
      and  hca.cust_account_id = p_account_id
      and  hcsu.cust_acct_site_id = hca.cust_acct_site_id
      and  hca.org_id = p_org_id
      and  hcsu.primary_flag = 'Y'
      and rownum = 1;

  --Bug fix 5494219 Begin
  l_sub_inv MTL_SECONDARY_INVENTORIES.SECONDARY_INVENTORY_NAME%type ;
  --Bug fix 5494219 End


  --default rule
  l_rule_input_rec CSD_RULES_ENGINE_PVT.CSD_RULE_INPUT_REC_TYPE;
  l_attr_type VARCHAR2(25);
  l_attr_code VARCHAR2(25);
  l_default_val_num  NUMBER;
  l_default_val_char VARCHAR2(240);
  l_default_rule_id  NUMBER;    -- swai: 12.1.1 ER 7233924


BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Initialize the table
  x_prod_txn_tbl.delete;

  IF (g_debug > 0 ) THEN
    csd_gen_utility_pvt.add('At the Begin in build_prod_txn_tbl');
  END IF;

  IF (g_debug > 0 ) THEN
    csd_gen_utility_pvt.add('p_repair_line_id ='||p_repair_line_id);
  END IF;


  IF NVL(p_repair_line_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN

    OPEN  repair_line_dtls(p_repair_line_id);

    FETCH repair_line_dtls INTO
       l_repair_type_ref,
       l_auto_process_rma,
       l_interface_to_om_flag,
       l_book_sales_order_flag,
       l_inv_item_id,
       l_inv_revision,
       --l_contract_id,
       -- R12 contract changes
       l_contract_line_id,
       l_unit_of_measure,
       l_cps_txn_billing_type_id,
       l_cpr_txn_billing_type_id,
       l_ls_txn_billing_type_id,
       l_lr_txn_billing_type_id,
       l_price_list_header_id,
       l_bus_process_id,
       l_incident_id,
       l_po_number,  -- swai bug fix 4535829
	    l_inv_org_id, -- inv_org_change vijay, 3/20/06
       l_project_id,
       l_task_id,
       l_unit_number,
       l_third_rma_txn_b_type_id,
       l_third_ship_txn_b_type_id,
       l_third_party_flag;


    IF repair_line_dtls%notfound then
      FND_MESSAGE.SET_NAME('CSD','CSD_API_INV_REP_LINE_ID');
      FND_MESSAGE.SET_TOKEN('REPAIR_LINE_ID',p_repair_line_id);
      FND_MSG_PUB.ADD;
      IF (g_debug > 0 ) THEN
        csd_gen_utility_pvt.ADD('repair line Id does not exist');
      END IF;

      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF repair_line_dtls%isopen then
      CLOSE repair_line_dtls;
    END IF;


  END IF;

  -- R12 contract changes
  IF(l_contract_line_id is not null) then

  	open cur_contract_det(l_contract_line_id);
	fetch cur_contract_det
	into
	l_contract_id;

     IF cur_contract_det%notfound then
      FND_MESSAGE.SET_NAME('CSD','CSD_API_INV_REP_LINE_ID');
      FND_MESSAGE.SET_TOKEN('REPAIR_LINE_ID',p_repair_line_id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF cur_contract_det%isopen then
      CLOSE cur_contract_det;
    END IF;
  END IF;


  IF (g_debug > 0 ) THEN
    csd_gen_utility_pvt.add('l_repair_type_ref ='||l_repair_type_ref);
  END IF;

  IF (g_debug > 0 ) THEN
    csd_gen_utility_pvt.add('l_auto_process_rma='||l_auto_process_rma);
  END IF;


  -- Get the price_list
  l_price_list_id := NVL(l_price_list_header_id,FND_PROFILE.value('CS_CHARGE_DEFAULT_PRICE_LIST'));

  -- Get the return reason
  l_return_reason := FND_PROFILE.value('CSD_DEF_RMA_RETURN_REASON');

  IF (g_debug > 0 ) THEN
    csd_gen_utility_pvt.add('l_price list_id        ='||l_price_list_id);
  END IF;

  IF (g_debug > 0 ) THEN
    csd_gen_utility_pvt.add('l_return_reason        ='||l_return_reason);
  END IF;

  IF (g_debug > 0 ) THEN
    csd_gen_utility_pvt.add('l_cps_txn_billing_type_id='||l_cps_txn_billing_type_id  );
  END IF;

  IF (g_debug > 0 ) THEN
    csd_gen_utility_pvt.add('l_cpr_txn_billing_type_id='||l_cpr_txn_billing_type_id );
  END IF;

  IF (g_debug > 0 ) THEN
    csd_gen_utility_pvt.add('l_ls_txn_billing_type_id ='||l_ls_txn_billing_type_id );
  END IF;

  IF (g_debug > 0 ) THEN
    csd_gen_utility_pvt.add('l_lr_txn_billing_type_id ='||l_lr_txn_billing_type_id );
  END IF;


  /*Bug#5190905
  added code to derive the correct service activity billing type based on
  service activity and item billing type.
  */
  If l_cpr_txn_billing_type_id is not null then
    l_txn_billing_type_id:=null;
    csd_get_txn_billing_type (
              p_api_version            => 1.0,
              p_init_msg_list          => 'F',
              p_incident_id            => l_incident_id,
              p_inventory_item_id      => l_inv_item_id,
              P_transaction_type_id    => NULL,
              p_txn_billing_type_id    => l_cpr_txn_billing_type_id,
              x_txn_billing_type_id    => l_txn_billing_type_id,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data
              );
          If (x_return_status = FND_API.G_RET_STS_SUCCESS ) then
            l_cpr_txn_billing_type_id :=l_txn_billing_type_id;
          else
            RAISE FND_API.G_EXC_ERROR;
         end if;
  end if;

  If l_cps_txn_billing_type_id is not null then
    l_txn_billing_type_id:=null;
    csd_get_txn_billing_type (
              p_api_version            => 1.0,
              p_init_msg_list          => 'F',
              p_incident_id            => l_incident_id,
              p_inventory_item_id      => l_inv_item_id,
              P_transaction_type_id    => NULL,
              p_txn_billing_type_id    => l_cps_txn_billing_type_id,
              x_txn_billing_type_id    => l_txn_billing_type_id,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data
              );
          If (x_return_status = FND_API.G_RET_STS_SUCCESS ) then
            l_cps_txn_billing_type_id :=l_txn_billing_type_id;
          else
            RAISE FND_API.G_EXC_ERROR;
         end if;
  end if;

  If l_ls_txn_billing_type_id is not null then
    l_txn_billing_type_id:=null;
    csd_get_txn_billing_type (
              p_api_version            => 1.0,
              p_init_msg_list          => 'F',
              p_incident_id            => l_incident_id,
              p_inventory_item_id      => l_inv_item_id,
              P_transaction_type_id    => NULL,
              p_txn_billing_type_id    => l_ls_txn_billing_type_id,
              x_txn_billing_type_id    => l_txn_billing_type_id,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data
              );
          If (x_return_status = FND_API.G_RET_STS_SUCCESS ) then
            l_ls_txn_billing_type_id :=l_txn_billing_type_id;
          else
            RAISE FND_API.G_EXC_ERROR;
         end if;
  end if;

  If l_lr_txn_billing_type_id is not null then
    l_txn_billing_type_id:=null;
    csd_get_txn_billing_type (
              p_api_version            => 1.0,
              p_init_msg_list          => 'F',
              p_incident_id            => l_incident_id,
              p_inventory_item_id      => l_inv_item_id,
              P_transaction_type_id    => NULL,
              p_txn_billing_type_id    => l_lr_txn_billing_type_id,
              x_txn_billing_type_id    => l_txn_billing_type_id,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data
              );
          If (x_return_status = FND_API.G_RET_STS_SUCCESS ) then
            l_lr_txn_billing_type_id :=l_txn_billing_type_id;
          else
            RAISE FND_API.G_EXC_ERROR;
         end if;
  end if;


    IF (NVL(l_third_party_flag, 'N') = 'Y' or (p_create_thirdpty_line = 'T')) THEN

          If l_third_rma_txn_b_type_id is not null then
            l_txn_billing_type_id:=null;
            csd_get_txn_billing_type (
                      p_api_version            => 1.0,
                      p_init_msg_list          => 'F',
                      p_incident_id            => l_incident_id,
                      p_inventory_item_id      => l_inv_item_id,
                      P_transaction_type_id    => NULL,
                      p_txn_billing_type_id    => l_third_rma_txn_b_type_id,
                      x_txn_billing_type_id    => l_txn_billing_type_id,
                      x_return_status          => x_return_status,
                      x_msg_count              => x_msg_count,
                      x_msg_data               => x_msg_data
                      );
                  If (x_return_status = FND_API.G_RET_STS_SUCCESS ) then
                    l_third_rma_txn_b_type_id :=l_txn_billing_type_id;
                  else
                    RAISE FND_API.G_EXC_ERROR;
                 end if;
          end if;


          If l_third_ship_txn_b_type_id is not null then
            l_txn_billing_type_id:=null;
            csd_get_txn_billing_type (
                      p_api_version            => 1.0,
                      p_init_msg_list          => 'F',
                      p_incident_id            => l_incident_id,
                      p_inventory_item_id      => l_inv_item_id,
                      P_transaction_type_id    => NULL,
                      p_txn_billing_type_id    => l_third_ship_txn_b_type_id,
                      x_txn_billing_type_id    => l_txn_billing_type_id,
                      x_return_status          => x_return_status,
                      x_msg_count              => x_msg_count,
                      x_msg_data               => x_msg_data
                      );
                  If (x_return_status = FND_API.G_RET_STS_SUCCESS ) then
                    l_third_ship_txn_b_type_id :=l_txn_billing_type_id;
                  else
                    RAISE FND_API.G_EXC_ERROR;
                 end if;
          end if;
    end if;

  IF (g_debug > 0 ) THEN
    csd_gen_utility_pvt.add('After calling csd_get_txn_billing_type ');
    csd_gen_utility_pvt.add('l_cps_txn_billing_type_id='||l_cps_txn_billing_type_id  );
    csd_gen_utility_pvt.add('l_cpr_txn_billing_type_id='||l_cpr_txn_billing_type_id );
    csd_gen_utility_pvt.add('l_ls_txn_billing_type_id ='||l_ls_txn_billing_type_id );
    csd_gen_utility_pvt.add('l_lr_txn_billing_type_id ='||l_lr_txn_billing_type_id );
  END IF;


  l_org_id := csd_process_util.get_org_id(l_incident_id);
  -- Inv_org Change, Vijay , 20/3/2006
  -- taken from the repair_order record.
  --l_inv_org_id := csd_process_util.get_inv_org_id;

  IF (g_debug > 0 ) THEN

    csd_gen_utility_pvt.add('l_incident_id   ='||l_incident_id);
    csd_gen_utility_pvt.add('l_org_id        ='||l_org_id);
    csd_gen_utility_pvt.add('l_inv_org_id    ='||l_inv_org_id);

  END IF;

  l_revision := l_inv_revision;

  -- Fix for bug# 3549430
  OPEN  get_item_attributes(l_inv_item_id,l_inv_org_id);

  FETCH get_item_attributes INTO
    l_serial_num_control_code,
    l_ib_flag;

  IF get_item_attributes%isopen then
    CLOSE get_item_attributes;
  END IF;


-- bug fix for 4108369, Begin
  l_sr_add_to_order_flag := fnd_profile.value('CSD_ADD_TO_SO_WITHIN_SR');
  l_sr_add_to_order_flag := nvl(l_sr_Add_to_order_flag, 'N');

  if(l_sr_add_to_order_flag = 'Y') THEN
  	l_add_rma_to_id := get_sr_add_to_order(p_repair_line_Id, 'RMA');
  	l_add_ship_to_id := get_sr_add_to_order(p_repair_line_Id, 'SHIP');
  END IF;
-- bug fix for 4108369, End

  l_return_days := nvl(FND_PROFILE.value('CSD_PRODUCT_RETURN_DAYS'),0); /*Fixed for FP bug#5408047*/
  --Bug fix 5494219 Begin
     l_sub_inv := FND_PROFILE.value('CSD_DEF_RMA_SUBINV');
  --Bug fix 5494219 End


/* bug#3875036 --begin here--*/

  l_enable_advanced_pricing	:= FND_PROFILE.VALUE('CSD_ENABLE_ADVANCED_PRICING');
  l_enable_advanced_pricing := nvl(l_enable_advanced_pricing, 'N');
  IF(l_enable_advanced_pricing ='Y') THEN
	  l_account_id := CSD_CHARGE_LINE_UTIL.Get_SR_AccountId(p_repair_line_id);
	  l_currency_code := GET_PL_CURRENCY_CODE(l_price_list_id);
	  get_charge_selling_price(
						  p_inventory_item_id    => l_inv_item_id,
						  p_price_list_header_id => l_price_list_id,
						  p_unit_of_measure_code => l_unit_of_measure,
						  p_currency_code        => l_currency_code,
						  p_quantity_required    => p_quantity,
						  p_account_id			 => l_account_id,
						  p_org_id				 => l_org_id,
						  p_pricing_rec          => l_pricing_rec,
						  x_selling_price        => l_selling_price,
						  x_return_status        => l_return_status,
						  x_msg_count            => l_msg_count,
						  x_msg_data             => l_msg_data);

  END IF;

/* bug#3875036 --end here--*/

  --defaulting rule value
  l_attr_type := 'CSD_DEF_ENTITY_ATTR_RO';
  l_rule_input_rec.REPAIR_LINE_ID := p_repair_line_Id;


  IF l_repair_type_ref = 'R' and (p_create_thirdpty_line = 'F') THEN
    -- in 11.5.10 we have place holder for non source item attributes
    -- like non_source_serial_number non_source_instance_id etc
    -- Shipping customer product txn line

    l_index := 1;
    if (l_cps_txn_billing_type_id is not null) then

        x_prod_txn_tbl(l_index).po_number                   := l_po_number;  -- swai bug fix 4535829
        x_prod_txn_tbl(l_index).product_transaction_id      := FND_API.G_MISS_NUM;
        x_prod_txn_tbl(l_index).repair_line_id              := p_repair_line_id  ;
        x_prod_txn_tbl(l_index).estimate_detail_id          := FND_API.G_MISS_NUM;
        x_prod_txn_tbl(l_index).action_type                 := 'SHIP'            ;

        --bug#3875036 bug 8694111
	  IF((l_enable_advanced_pricing ='Y') and (x_prod_txn_tbl(l_index).no_charge_flag ='N')) THEN
            x_prod_txn_tbl(l_index).after_warranty_cost     := l_selling_price;
	  End if;

        --x_prod_txn_tbl(l_index).action_code               := 'CUST_PROD'       ;
        -- In 11.5.10 we have defined a new action code replacement : saupadhy : 3431371
        x_prod_txn_tbl(l_index).action_code                 := c_Replacement  ;
        x_prod_txn_tbl(l_index).line_category_code          := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).organization_id             := l_org_id          ;
        x_prod_txn_tbl(l_index).txn_billing_type_id         := l_cps_txn_billing_type_id;
        x_prod_txn_tbl(l_index).business_process_id         := l_bus_process_id;
        x_prod_txn_tbl(l_index).order_number                := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).status                      := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).inventory_item_id           := l_inv_item_id     ;
        x_prod_txn_tbl(l_index).unit_of_measure_code        := l_unit_of_measure ;
        x_prod_txn_tbl(l_index).quantity                    := p_quantity        ;
     -- x_prod_txn_tbl(l_index).serial_number               := FND_API.G_MISS_CHAR;--l_serial_number   ; 11.5.9
        if ( l_ib_flag = 'Y' ) then
          x_prod_txn_tbl(l_index).non_source_serial_number    := p_serial_number   ; -- 11.5.10
        else
          x_prod_txn_tbl(l_index).non_source_serial_number    := FND_API.G_MISS_CHAR   ; -- 11.5.10
        end if;
        x_prod_txn_tbl(l_index).lot_number                  := FND_API.G_MISS_CHAR;
     -- x_prod_txn_tbl(l_index).instance_id                 := l_instance_id; -- 11.5.9
        x_prod_txn_tbl(l_index).non_source_instance_id      := p_instance_id; -- 11.5.10
        x_prod_txn_tbl(l_index).source_serial_number        := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).source_instance_id          := FND_API.G_MISS_NUM;
        x_prod_txn_tbl(l_index).price_list_id               := l_price_list_id  ;
        x_prod_txn_tbl(l_index).contract_id               := l_contract_id    ;
     -- R12 contract changes
        x_prod_txn_tbl(l_index).contract_line_id            := l_contract_line_id    ;
--        x_prod_txn_tbl(l_index).sub_inventory               := FND_API.G_MISS_CHAR;

		l_attr_code := 'SHIP_FROM_SUBINV';
        l_default_val_char := null;
        CSD_RULES_ENGINE_PVT.GET_DEFAULT_VALUE_FROM_RULE (
          p_api_version_number    => 1.0,
          p_init_msg_list         => FND_API.G_TRUE,
          p_commit                => FND_API.G_TRUE,
          p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
          p_entity_attribute_type => l_attr_type,
          p_entity_attribute_code => l_attr_code,
          p_rule_input_rec        => l_rule_input_rec,
          x_default_value         => l_default_val_char,
          x_rule_id               => l_default_rule_id,   -- swai: 12.1.1 ER 7233924
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data
        );
        if (l_default_val_char is not null) then
            x_prod_txn_tbl(l_index).sub_inventory  := l_default_val_char;
        else
            x_prod_txn_tbl(l_index).sub_inventory  := FND_API.G_MISS_CHAR;
        end if;


        x_prod_txn_tbl(l_index).no_charge_flag              := csd_process_util.get_no_chg_flag(l_cps_txn_billing_type_id);
        x_prod_txn_tbl(l_index).release_sales_order_flag    := 'N'               ;
        x_prod_txn_tbl(l_index).ship_sales_order_flag       := 'N'               ;


        IF NVL(l_interface_to_om_flag, 'N') = 'Y' THEN
          x_prod_txn_tbl(l_index).process_txn_flag           := 'Y';
          if NVL(l_book_sales_order_flag, 'N') = 'Y' THEN
             x_prod_txn_tbl(l_index).interface_to_om_flag    := 'Y';
             x_prod_txn_tbl(l_index).book_sales_order_flag   := 'Y';
          else
             x_prod_txn_tbl(l_index).interface_to_om_flag    := 'Y';
             x_prod_txn_tbl(l_index).book_sales_order_flag   := 'N';
          end if;

  	      if(l_add_ship_to_id is null) THEN
	         x_prod_txn_tbl(l_index).new_order_flag := 'Y';
	      ELSE
		     x_prod_txn_tbl(l_index).new_order_flag := 'N';
		     x_prod_txn_tbl(l_index).add_to_order_flag := 'Y';
		     x_prod_txn_tbl(l_index).add_to_order_id := l_add_ship_to_id;
	      END IF;
        Else
           x_prod_txn_tbl(l_index).process_txn_flag            := 'N'               ;
           x_prod_txn_tbl(l_index).interface_to_om_flag        := 'N'               ;
           x_prod_txn_tbl(l_index).book_sales_order_flag       := 'N'               ;
        End if;

        x_prod_txn_tbl(l_index).return_reason               := FND_API.G_MISS_CHAR;
        -- x_prod_txn_tbl(l_index).return_by_date           := FND_API.G_MISS_DATE;
        /* Fixed for FP bug#5408047
           For SHIP line if either of 'source return is required'
           or 'non-source return required' is checked then only default
           the return by date. This date will be passed to charges in
           Installed_cp_return_by_date or in New_cp_return_by_date
           based on source or non-source setup in procedure Convert_to_Chg_rec
        */
        l_src_return_reqd     :='N';
        l_non_src_return_reqd :='N';
        open c2( l_cps_txn_billing_type_id );
        fetch c2 into l_src_return_reqd,l_non_src_return_reqd ;
        If (c2%ISOPEN) then
         Close c2;
        end if;

        If l_src_return_reqd ='Y' or l_non_src_return_reqd ='Y' then
           x_prod_txn_tbl(l_index).return_by_date              := sysdate+l_return_days;
        else
           x_prod_txn_tbl(l_index).return_by_date              := NULL;
        end if;

        x_prod_txn_tbl(l_index).revision                    := l_revision       ;
        x_prod_txn_tbl(l_index).last_update_date            := sysdate          ;
        x_prod_txn_tbl(l_index).creation_date               := sysdate          ;
        x_prod_txn_tbl(l_index).last_updated_by             := FND_GLOBAL.USER_ID;
        x_prod_txn_tbl(l_index).created_by                  := FND_GLOBAL.USER_ID;
        x_prod_txn_tbl(l_index).last_update_login           := FND_GLOBAL.USER_ID;
        x_prod_txn_tbl(l_index).attribute1                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute2                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute3                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute4                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute5                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute6                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute7                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute8                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute9                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute10                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute11                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute12                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute13                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute14                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute15                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).context                     := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).prod_txn_status             := 'ENTERED';
        x_prod_txn_tbl(l_index).prod_txn_code               := 'PRE';
        x_prod_txn_tbl(l_index).project_id                  := l_project_id;
        x_prod_txn_tbl(l_index).task_id                     := l_task_id;
        x_prod_txn_tbl(l_index).unit_number                 := l_unit_number;

        -- picking rule changes for R12
        Fnd_Profile.Get('CSD_DEF_PICK_RELEASE_RULE',l_picking_rule_id);
        x_prod_txn_tbl(l_index).picking_rule_id  := l_picking_rule_id;
        --------------------------------

		l_attr_code := 'SHIP_FROM_ORG';
        l_default_val_num := null;
        CSD_RULES_ENGINE_PVT.GET_DEFAULT_VALUE_FROM_RULE (
          p_api_version_number    => 1.0,
          p_init_msg_list         => FND_API.G_TRUE,
          p_commit                => FND_API.G_TRUE,
          p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
          p_entity_attribute_type => l_attr_type,
          p_entity_attribute_code => l_attr_code,
          p_rule_input_rec        => l_rule_input_rec,
          x_default_value         => l_default_val_num,
          x_rule_id               => l_default_rule_id,   -- swai: 12.1.1 ER 7233924
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data
        );
        if (l_default_val_num is not null) then
            x_prod_txn_tbl(l_index).inventory_org_id  := l_default_val_num;
        else
            -- Inv_org Change, Vijay , 20/3/2006
            x_prod_txn_tbl(l_index).inventory_org_id  := l_inv_org_id;
        end if;

        ---------------------------------------

        l_index := l_index + 1;

    end if;

  ELSIF l_repair_type_ref in ('RR','WR','E' ) and (p_create_thirdpty_line = 'F') THEN

    l_index := 1;

    if (l_cpr_txn_billing_type_id is not null) then

        -- receive customer product txn line
        x_prod_txn_tbl(l_index).product_transaction_id      := FND_API.G_MISS_NUM;
        x_prod_txn_tbl(l_index).repair_line_id              := p_repair_line_id  ;
        x_prod_txn_tbl(l_index).estimate_detail_id          := FND_API.G_MISS_NUM;
        x_prod_txn_tbl(l_index).line_category_code          := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).txn_billing_type_id         := l_cpr_txn_billing_type_id;
        x_prod_txn_tbl(l_index).po_number                   := l_po_number;  -- swai bug fix 4535829
       IF l_repair_type_ref = 'E' THEN
	    -- saupady prefers this to be CUST_PROD instead of EXCHANGE
         x_prod_txn_tbl(l_index).action_code                 := 'EXCHANGE' ;
       ELSE
         x_prod_txn_tbl(l_index).action_code                 := 'CUST_PROD';
       END IF;

       IF l_repair_type_ref = 'WR' THEN
         x_prod_txn_tbl(l_index).action_type                 := 'WALK_IN_RECEIPT' ;
       ELSE
         x_prod_txn_tbl(l_index).action_type                 := 'RMA'             ;
       END IF;

        --bug#3875036 Bug 8694111
	 IF((l_enable_advanced_pricing ='Y') and (x_prod_txn_tbl(l_index).no_charge_flag ='N')) THEN
            x_prod_txn_tbl(l_index).after_warranty_cost	     := -l_selling_price;
	 End If;

        -- x_prod_txn_tbl(l_index).serial_number            := l_serial_number   ;
        -- x_prod_txn_tbl(l_index).instance_id              := l_instance_id     ;
        x_prod_txn_tbl(l_index).source_serial_number        := p_serial_number   ;
        x_prod_txn_tbl(l_index).source_instance_id          := p_instance_id     ;
        x_prod_txn_tbl(l_index).non_source_serial_number    := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).non_source_instance_id      := FND_API.G_MISS_NUM;
        x_prod_txn_tbl(l_index).organization_id             := l_org_id          ;
        x_prod_txn_tbl(l_index).business_process_id         := l_bus_process_id ;
        x_prod_txn_tbl(l_index).order_number                := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).status                      := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).inventory_item_id           := l_inv_item_id     ;
        x_prod_txn_tbl(l_index).unit_of_measure_code        := l_unit_of_measure ;
        x_prod_txn_tbl(l_index).quantity                    := p_quantity        ;
        x_prod_txn_tbl(l_index).lot_number                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).price_list_id               := l_price_list_id   ;
        x_prod_txn_tbl(l_index).contract_id                 := l_contract_id     ;
     -- R12 contract changes
        x_prod_txn_tbl(l_index).contract_line_id            := l_contract_line_id    ;
        x_prod_txn_tbl(l_index).sub_inventory               := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).no_charge_flag              := csd_process_util.get_no_chg_flag(l_cpr_txn_billing_type_id) ;
        x_prod_txn_tbl(l_index).release_sales_order_flag    := 'N' ;
        x_prod_txn_tbl(l_index).ship_sales_order_flag       := 'N' ;

        -- auto process the RMA for the customer
        -- product txn line only
        -- Following line commented by vkjain to fix 3353445
        -- It adds support of 'Auto Enter and Book' RMA.
        -- IF x_prod_txn_tbl(l_index).action_code = 'CUST_PROD' and
        IF NVL(l_auto_process_rma, 'N') = 'Y' THEN
           x_prod_txn_tbl(l_index).process_txn_flag            := 'Y' ;
           x_prod_txn_tbl(l_index).interface_to_om_flag        := 'Y' ;
           x_prod_txn_tbl(l_index).book_sales_order_flag       := 'Y' ;
           -- bug fix for 4108369, Begin
           if(l_add_rma_to_id is null) THEN
             x_prod_txn_tbl(l_index).new_order_flag := 'Y';
           ELSE
             x_prod_txn_tbl(l_index).new_order_flag := 'N';
             x_prod_txn_tbl(l_index).add_to_order_flag := 'Y';
             x_prod_txn_tbl(l_index).add_to_order_id := l_add_rma_to_id;
           END IF;
           -- bug fix for 4108369, End
        ELSE
           x_prod_txn_tbl(l_index).process_txn_flag            := 'N' ;
           x_prod_txn_tbl(l_index).interface_to_om_flag        := 'N' ;
           x_prod_txn_tbl(l_index).book_sales_order_flag       := 'N' ;
        END IF;

        x_prod_txn_tbl(l_index).return_reason               := l_return_reason  ;
        -- x_prod_txn_tbl(l_index).return_by_date           := sysdate          ;
        /* Fixed for FP bug#5408047
          For RMA line if source return is required then only
          default the return by date. This date will be passed to
          charges in Installed_cp_return_by_date.
        */
        l_src_return_reqd      :='N';
        l_non_src_return_reqd  :='N';
        open c2( l_cpr_txn_billing_type_id );
        fetch c2 into l_src_return_reqd,l_non_src_return_reqd ;
        If (c2%ISOPEN) then
          Close c2;
        END IF;
        If l_src_return_reqd ='Y' then
          x_prod_txn_tbl(l_index).return_by_date              := sysdate+l_return_days;
        ELSE
           x_prod_txn_tbl(l_index).return_by_date              := NULL          ;
        END IF;

        x_prod_txn_tbl(l_index).revision                    := l_revision       ;
        x_prod_txn_tbl(l_index).last_update_date            := sysdate          ;
        x_prod_txn_tbl(l_index).creation_date               := sysdate          ;
        x_prod_txn_tbl(l_index).last_updated_by             := FND_GLOBAL.USER_ID;
        x_prod_txn_tbl(l_index).created_by                  := FND_GLOBAL.USER_ID;
        x_prod_txn_tbl(l_index).last_update_login           := FND_GLOBAL.USER_ID;
        x_prod_txn_tbl(l_index).attribute1                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute2                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute3                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute4                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute5                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute6                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute7                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute8                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute9                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute10                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute11                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute12                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute13                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute14                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute15                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).context                     := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).prod_txn_status             := 'ENTERED';
        x_prod_txn_tbl(l_index).prod_txn_code               := 'PRE';
        x_prod_txn_tbl(l_index).project_id                  := l_project_id;
        x_prod_txn_tbl(l_index).task_id                     := l_task_id;
        x_prod_txn_tbl(l_index).unit_number                 := l_unit_number;


		l_attr_code := 'RMA_RCV_ORG';
        l_default_val_num := null;
        CSD_RULES_ENGINE_PVT.GET_DEFAULT_VALUE_FROM_RULE (
          p_api_version_number    => 1.0,
          p_init_msg_list         => FND_API.G_TRUE,
          p_commit                => FND_API.G_TRUE,
          p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
          p_entity_attribute_type => l_attr_type,
          p_entity_attribute_code => l_attr_code,
          p_rule_input_rec        => l_rule_input_rec,
          x_default_value         => l_default_val_num,
          x_rule_id               => l_default_rule_id, -- swai: 12.1.1 ER 7233924
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data
        );
        if (l_default_val_num is not null) then
            x_prod_txn_tbl(l_index).inventory_org_id  := l_default_val_num;
        else
            -- Inv_org Change, Vijay , 20/3/2006
            x_prod_txn_tbl(l_index).inventory_org_id  := l_inv_org_id;
        end if;

 		l_attr_code := 'RMA_RCV_SUBINV';
        l_default_val_char := null;
        CSD_RULES_ENGINE_PVT.GET_DEFAULT_VALUE_FROM_RULE (
          p_api_version_number    => 1.0,
          p_init_msg_list         => FND_API.G_TRUE,
          p_commit                => FND_API.G_TRUE,
          p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
          p_entity_attribute_type => l_attr_type,
          p_entity_attribute_code => l_attr_code,
          p_rule_input_rec        => l_rule_input_rec,
          x_default_value         => l_default_val_char,
          x_rule_id               => l_default_rule_id, -- swai: 12.1.1 ER 7233924
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data
        );
        if (l_default_val_char is not null) then
            x_prod_txn_tbl(l_index).sub_inventory  := l_default_val_char;
        else
            x_prod_txn_tbl(l_index).sub_inventory  := l_sub_inv;
        end if;

        l_index := l_index + 1;
    end if;

    if (l_cps_txn_billing_type_id is not null) then
        -- Shipping customer product txn line
        x_prod_txn_tbl(l_index).product_transaction_id      := FND_API.G_MISS_NUM;
        x_prod_txn_tbl(l_index).repair_line_id              := p_repair_line_id  ;
        x_prod_txn_tbl(l_index).estimate_detail_id          := FND_API.G_MISS_NUM;
        x_prod_txn_tbl(l_index).line_category_code          := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).txn_billing_type_id         := l_cps_txn_billing_type_id;
        x_prod_txn_tbl(l_index).po_number                   := l_po_number; -- swai bug fix 4535829

       IF l_repair_type_ref = 'E' THEN
         x_prod_txn_tbl(l_index).action_code                := 'EXCHANGE' ;
         x_prod_txn_tbl(l_index).non_source_instance_id     := p_instance_id;
         if ( l_ib_flag = 'Y' ) then
           x_prod_txn_tbl(l_index).non_source_serial_number   := p_serial_number;
         else
           x_prod_txn_tbl(l_index).non_source_serial_number   := FND_API.G_MISS_CHAR;
         end if;
         x_prod_txn_tbl(l_index).source_instance_id         := FND_API.G_MISS_NUM;
         x_prod_txn_tbl(l_index).source_serial_number       := FND_API.G_MISS_CHAR;
       ELSE
         x_prod_txn_tbl(l_index).action_code                := 'CUST_PROD';
         x_prod_txn_tbl(l_index).non_source_instance_id     := FND_API.G_MISS_NUM;
         x_prod_txn_tbl(l_index).non_source_serial_number   := FND_API.G_MISS_CHAR;

         -- Fix for bug# 3549430
         if (l_serial_num_control_code = 1 and l_ib_flag = 'Y') then
           x_prod_txn_tbl(l_index).source_instance_id         := FND_API.G_MISS_NUM;
           x_prod_txn_tbl(l_index).source_serial_number       := FND_API.G_MISS_CHAR;
         else
           x_prod_txn_tbl(l_index).source_instance_id         := p_instance_id;
           x_prod_txn_tbl(l_index).source_serial_number       := p_serial_number;
         end if;
       END IF;

       IF l_repair_type_ref = 'WR' THEN
        x_prod_txn_tbl(l_index).action_type                 := 'WALK_IN_ISSUE'  ;
       ELSE
        x_prod_txn_tbl(l_index).action_type                 := 'SHIP'           ;
       END IF;

    --bug#3875036 Bug 8694111
	IF((l_enable_advanced_pricing ='Y') and (x_prod_txn_tbl(l_index).no_charge_flag ='N')) THEN
           x_prod_txn_tbl(l_index).after_warranty_cost      := l_selling_price;
	End if;

        x_prod_txn_tbl(l_index).organization_id             := l_org_id          ;
        x_prod_txn_tbl(l_index).business_process_id         := l_bus_process_id ;
        x_prod_txn_tbl(l_index).order_number                := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).status                      := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).inventory_item_id           := l_inv_item_id     ;
        x_prod_txn_tbl(l_index).unit_of_measure_code        := l_unit_of_measure ;
        x_prod_txn_tbl(l_index).quantity                    := p_quantity        ;
        x_prod_txn_tbl(l_index).lot_number                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).price_list_id               := l_price_list_id   ;
     -- R12 contract changes
        x_prod_txn_tbl(l_index).contract_line_id            := l_contract_line_id    ;
        x_prod_txn_tbl(l_index).contract_id                 := l_contract_id     ;
--        x_prod_txn_tbl(l_index).sub_inventory               := FND_API.G_MISS_CHAR;
		l_attr_code := 'SHIP_FROM_SUBINV';
        l_default_val_char := null;
        CSD_RULES_ENGINE_PVT.GET_DEFAULT_VALUE_FROM_RULE (
          p_api_version_number    => 1.0,
          p_init_msg_list         => FND_API.G_TRUE,
          p_commit                => FND_API.G_TRUE,
          p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
          p_entity_attribute_type => l_attr_type,
          p_entity_attribute_code => l_attr_code,
          p_rule_input_rec        => l_rule_input_rec,
          x_default_value         => l_default_val_char,
          x_rule_id               => l_default_rule_id, -- swai: 12.1.1 ER 7233924
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data
        );
        if (l_default_val_char is not null) then
            x_prod_txn_tbl(l_index).sub_inventory  := l_default_val_char;
        else
            x_prod_txn_tbl(l_index).sub_inventory  := FND_API.G_MISS_CHAR;
        end if;

        x_prod_txn_tbl(l_index).no_charge_flag              := csd_process_util.get_no_chg_flag(l_cps_txn_billing_type_id);
        x_prod_txn_tbl(l_index).release_sales_order_flag    := 'N'               ;
        x_prod_txn_tbl(l_index).ship_sales_order_flag       := 'N'               ;


        IF NVL(l_interface_to_om_flag, 'N') = 'Y' THEN
          x_prod_txn_tbl(l_index).process_txn_flag           := 'Y';
          if NVL(l_book_sales_order_flag, 'N') = 'Y' THEN
             x_prod_txn_tbl(l_index).interface_to_om_flag    := 'Y';
             x_prod_txn_tbl(l_index).book_sales_order_flag   := 'Y';
          else
             x_prod_txn_tbl(l_index).interface_to_om_flag    := 'Y';
             x_prod_txn_tbl(l_index).book_sales_order_flag   := 'N';
          end if;

  	      if(l_add_ship_to_id is null) THEN
	         x_prod_txn_tbl(l_index).new_order_flag := 'Y';
	      ELSE
		     x_prod_txn_tbl(l_index).new_order_flag := 'N';
		     x_prod_txn_tbl(l_index).add_to_order_flag := 'Y';
		     x_prod_txn_tbl(l_index).add_to_order_id := l_add_ship_to_id;
	      END IF;
        Else
           x_prod_txn_tbl(l_index).process_txn_flag            := 'N'               ;
           x_prod_txn_tbl(l_index).interface_to_om_flag        := 'N'               ;
           x_prod_txn_tbl(l_index).book_sales_order_flag       := 'N'               ;
        End if;

        x_prod_txn_tbl(l_index).return_reason               := FND_API.G_MISS_CHAR;
        -- x_prod_txn_tbl(l_index).return_by_date           := FND_API.G_MISS_DATE;
        /* Fixed for FP bug#5408047
           For SHIP line if either of 'source return is required'
           or 'non-source return required' is checked then only default
           the return by date. This date will be passed to charges in
           Installed_cp_return_by_date or in New_cp_return_by_date
           based on source or non-source setup in procedure Convert_to_Chg_rec
         */
        l_src_return_reqd:='N';
        l_non_src_return_reqd:='N';
        open c2( l_cps_txn_billing_type_id );
        fetch c2 into l_src_return_reqd,l_non_src_return_reqd ;
        If (c2%ISOPEN) then
          Close c2;
        END IF;

        If l_src_return_reqd ='Y' or l_non_src_return_reqd ='Y' then
          x_prod_txn_tbl(l_index).return_by_date              := sysdate+l_return_days;
        ELSE
          x_prod_txn_tbl(l_index).return_by_date              := NULL;
        END IF;
        x_prod_txn_tbl(l_index).revision                    := l_revision       ;
        x_prod_txn_tbl(l_index).last_update_date            := sysdate          ;
        x_prod_txn_tbl(l_index).creation_date               := sysdate          ;
        x_prod_txn_tbl(l_index).last_updated_by             := FND_GLOBAL.USER_ID;
        x_prod_txn_tbl(l_index).created_by                  := FND_GLOBAL.USER_ID;
        x_prod_txn_tbl(l_index).last_update_login           := FND_GLOBAL.USER_ID;
        x_prod_txn_tbl(l_index).attribute1                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute2                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute3                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute4                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute5                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute6                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute7                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute8                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute9                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute10                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute11                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute12                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute13                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute14                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute15                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).context                     := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).prod_txn_status             := 'ENTERED';
        x_prod_txn_tbl(l_index).prod_txn_code               := 'POST';
        x_prod_txn_tbl(l_index).project_id                  := l_project_id;
        x_prod_txn_tbl(l_index).task_id                     := l_task_id;
        x_prod_txn_tbl(l_index).unit_number                 := l_unit_number;

        -- picking rule changes for R12
        Fnd_Profile.Get('CSD_DEF_PICK_RELEASE_RULE',l_picking_rule_id);
        x_prod_txn_tbl(l_index).picking_rule_id  := l_picking_rule_id;
        --------------------------------

		l_attr_code := 'SHIP_FROM_ORG';
        l_default_val_num := null;
        CSD_RULES_ENGINE_PVT.GET_DEFAULT_VALUE_FROM_RULE (
          p_api_version_number    => 1.0,
          p_init_msg_list         => FND_API.G_TRUE,
          p_commit                => FND_API.G_TRUE,
          p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
          p_entity_attribute_type => l_attr_type,
          p_entity_attribute_code => l_attr_code,
          p_rule_input_rec        => l_rule_input_rec,
          x_default_value         => l_default_val_num,
          x_rule_id               => l_default_rule_id, -- swai: 12.1.1 ER 7233924
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data
        );
        if (l_default_val_num is not null) then
            x_prod_txn_tbl(l_index).inventory_org_id  := l_default_val_num;
        else
            -- Inv_org Change, Vijay , 20/3/2006
            x_prod_txn_tbl(l_index).inventory_org_id  := l_inv_org_id;
        end if;


        l_index := l_index + 1;

    end if;


  ELSIF (l_repair_type_ref = 'AL') and (p_create_thirdpty_line = 'F') THEN
    l_index := 1;

    if (l_ls_txn_billing_type_id is not null) then

         -- Ship loaner product txn line
        x_prod_txn_tbl(l_index).product_transaction_id      := FND_API.G_MISS_NUM;
        x_prod_txn_tbl(l_index).repair_line_id              := p_repair_line_id  ;
        x_prod_txn_tbl(l_index).estimate_detail_id          := FND_API.G_MISS_NUM;
        x_prod_txn_tbl(l_index).line_category_code          := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).action_code                 := 'LOANER'          ;
        x_prod_txn_tbl(l_index).txn_billing_type_id         := l_ls_txn_billing_type_id;
        x_prod_txn_tbl(l_index).action_type                 := 'SHIP'             ;

        --bug#3875036 Bug 8694111
	IF((l_enable_advanced_pricing ='Y')and (x_prod_txn_tbl(l_index).no_charge_flag ='N')) THEN
          x_prod_txn_tbl(l_index).after_warranty_cost	    := l_selling_price;
	End If;

        x_prod_txn_tbl(l_index).source_serial_number        := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).non_source_serial_number    := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).organization_id             := l_org_id          ;
        x_prod_txn_tbl(l_index).business_process_id         := l_bus_process_id ;
        x_prod_txn_tbl(l_index).order_number                := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).status                      := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).inventory_item_id           := l_inv_item_id     ;
        x_prod_txn_tbl(l_index).unit_of_measure_code        := l_unit_of_measure ;
        x_prod_txn_tbl(l_index).quantity                    := p_quantity        ;
        x_prod_txn_tbl(l_index).lot_number                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).source_instance_id          := FND_API.G_MISS_NUM;
        x_prod_txn_tbl(l_index).non_source_instance_id      := FND_API.G_MISS_NUM;
        x_prod_txn_tbl(l_index).price_list_id               := l_price_list_id   ;
     -- R12 contract changes
        x_prod_txn_tbl(l_index).contract_line_id            := l_contract_line_id    ;
        x_prod_txn_tbl(l_index).contract_id                 := l_contract_id     ;
--        x_prod_txn_tbl(l_index).sub_inventory               := FND_API.G_MISS_CHAR;
		l_attr_code := 'SHIP_FROM_SUBINV';
        l_default_val_char := null;
        CSD_RULES_ENGINE_PVT.GET_DEFAULT_VALUE_FROM_RULE (
          p_api_version_number    => 1.0,
          p_init_msg_list         => FND_API.G_TRUE,
          p_commit                => FND_API.G_TRUE,
          p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
          p_entity_attribute_type => l_attr_type,
          p_entity_attribute_code => l_attr_code,
          p_rule_input_rec        => l_rule_input_rec,
          x_default_value         => l_default_val_char,
          x_rule_id               => l_default_rule_id, -- swai: 12.1.1 ER 7233924
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data
        );
        if (l_default_val_char is not null) then
            x_prod_txn_tbl(l_index).sub_inventory  := l_default_val_char;
        else
            x_prod_txn_tbl(l_index).sub_inventory  := FND_API.G_MISS_CHAR;
        end if;

        x_prod_txn_tbl(l_index).no_charge_flag              := csd_process_util.get_no_chg_flag(l_ls_txn_billing_type_id ) ;
        x_prod_txn_tbl(l_index).release_sales_order_flag    := 'N' ;
        x_prod_txn_tbl(l_index).ship_sales_order_flag       := 'N' ;

        IF NVL(l_interface_to_om_flag, 'N') = 'Y' THEN
          x_prod_txn_tbl(l_index).process_txn_flag           := 'Y';
          if NVL(l_book_sales_order_flag, 'N') = 'Y' THEN
             x_prod_txn_tbl(l_index).interface_to_om_flag    := 'Y';
             x_prod_txn_tbl(l_index).book_sales_order_flag   := 'Y';
          else
             x_prod_txn_tbl(l_index).interface_to_om_flag    := 'Y';
             x_prod_txn_tbl(l_index).book_sales_order_flag   := 'N';
          end if;

  	      if(l_add_ship_to_id is null) THEN
	         x_prod_txn_tbl(l_index).new_order_flag := 'Y';
	      ELSE
		     x_prod_txn_tbl(l_index).new_order_flag := 'N';
		     x_prod_txn_tbl(l_index).add_to_order_flag := 'Y';
		     x_prod_txn_tbl(l_index).add_to_order_id := l_add_ship_to_id;
	      END IF;

        Else
           x_prod_txn_tbl(l_index).process_txn_flag            := 'N'               ;
           x_prod_txn_tbl(l_index).interface_to_om_flag        := 'N'               ;
           x_prod_txn_tbl(l_index).book_sales_order_flag       := 'N'               ;
        End if;

        x_prod_txn_tbl(l_index).return_reason               := FND_API.G_MISS_CHAR;
        -- x_prod_txn_tbl(l_index).return_by_date           := FND_API.G_MISS_DATE;
        /* Fixed for FP bug#5408047
           For SHIP line if either of 'source return is required'
           or 'non-source return required' is checked then only default
           the return by date. This date will be passed to charges in
           Installed_cp_return_by_date or in New_cp_return_by_date
           based on source or non-source setup in procedure Convert_to_Chg_rec
         */
        l_src_return_reqd     :='N';
        l_non_src_return_reqd :='N';
        open c2( l_ls_txn_billing_type_id );
        fetch c2 into l_src_return_reqd,l_non_src_return_reqd ;
        If (c2%ISOPEN) then
          Close c2;
        END IF;
        If l_src_return_reqd ='Y' or l_non_src_return_reqd ='Y' then
          x_prod_txn_tbl(l_index).return_by_date            := sysdate+l_return_days;
        else
          x_prod_txn_tbl(l_index).return_by_date            := NULL;
        END IF;
        x_prod_txn_tbl(l_index).revision                    := l_revision       ;
        x_prod_txn_tbl(l_index).last_update_date            := sysdate          ;
        x_prod_txn_tbl(l_index).creation_date               := sysdate          ;
        x_prod_txn_tbl(l_index).last_updated_by             := FND_GLOBAL.USER_ID;
        x_prod_txn_tbl(l_index).created_by                  := FND_GLOBAL.USER_ID;
        x_prod_txn_tbl(l_index).last_update_login           := FND_GLOBAL.USER_ID;
        x_prod_txn_tbl(l_index).attribute1                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute2                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute3                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute4                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute5                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute6                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute7                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute8                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute9                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute10                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute11                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute12                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute13                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute14                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute15                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).context                     := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).prod_txn_status             := 'ENTERED';
        x_prod_txn_tbl(l_index).prod_txn_code               := 'PRE';
        x_prod_txn_tbl(l_index).po_number                   := l_po_number; -- swai bug fix 4535829
        x_prod_txn_tbl(l_index).project_id                  := l_project_id;
        x_prod_txn_tbl(l_index).task_id                     := l_task_id;
        x_prod_txn_tbl(l_index).unit_number                 := l_unit_number;

        -- picking rule changes for R12
        Fnd_Profile.Get('CSD_DEF_PICK_RELEASE_RULE',l_picking_rule_id);
        x_prod_txn_tbl(l_index).picking_rule_id  := l_picking_rule_id;
        --------------------------------

		l_attr_code := 'SHIP_FROM_ORG';
        l_default_val_num := null;
        CSD_RULES_ENGINE_PVT.GET_DEFAULT_VALUE_FROM_RULE (
          p_api_version_number    => 1.0,
          p_init_msg_list         => FND_API.G_TRUE,
          p_commit                => FND_API.G_TRUE,
          p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
          p_entity_attribute_type => l_attr_type,
          p_entity_attribute_code => l_attr_code,
          p_rule_input_rec        => l_rule_input_rec,
          x_default_value         => l_default_val_num,
          x_rule_id               => l_default_rule_id, -- swai: 12.1.1 ER 7233924
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data
        );
        if (l_default_val_num is not null) then
            x_prod_txn_tbl(l_index).inventory_org_id  := l_default_val_num;
        else
            -- Inv_org Change, Vijay , 20/3/2006
            x_prod_txn_tbl(l_index).inventory_org_id  := l_inv_org_id;
        end if;


        ---------------------------------------
        l_index := l_index + 1;

    end if;

    if (l_lr_txn_billing_type_id is not null) then
        -- Receive Loaner product txn line
        x_prod_txn_tbl(l_index).product_transaction_id      := FND_API.G_MISS_NUM;
        x_prod_txn_tbl(l_index).repair_line_id              := p_repair_line_id  ;
        x_prod_txn_tbl(l_index).estimate_detail_id          := FND_API.G_MISS_NUM;
        x_prod_txn_tbl(l_index).line_category_code          := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).action_code                 := 'LOANER'       ;
        x_prod_txn_tbl(l_index).txn_billing_type_id         := l_lr_txn_billing_type_id;
        x_prod_txn_tbl(l_index).action_type                 := 'RMA'            ;

        --bug#3875036 Bug 8694111
	IF((l_enable_advanced_pricing ='Y')and (x_prod_txn_tbl(l_index).no_charge_flag ='N')) THEN
   	  x_prod_txn_tbl(l_index).after_warranty_cost	    := -l_selling_price;
	End if;

        x_prod_txn_tbl(l_index).po_number                   := l_po_number;  -- swai bug fix 4535829
        -- Fix for bug#3704155
        --x_prod_txn_tbl(l_index).source_serial_number        := p_serial_number;
        x_prod_txn_tbl(l_index).source_serial_number        := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).non_source_serial_number    := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).organization_id             := l_org_id          ;
        x_prod_txn_tbl(l_index).business_process_id         := l_bus_process_id ;
        x_prod_txn_tbl(l_index).order_number                := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).status                      := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).inventory_item_id           := l_inv_item_id     ;
        x_prod_txn_tbl(l_index).unit_of_measure_code        := l_unit_of_measure ;
        x_prod_txn_tbl(l_index).quantity                    := p_quantity        ;
        x_prod_txn_tbl(l_index).lot_number                  := FND_API.G_MISS_CHAR;
        -- Fix for bug#3704155
        --x_prod_txn_tbl(l_index).source_instance_id          := p_instance_id     ;
        x_prod_txn_tbl(l_index).source_instance_id          := FND_API.G_MISS_NUM;
        x_prod_txn_tbl(l_index).non_source_instance_id      := FND_API.G_MISS_NUM;
        x_prod_txn_tbl(l_index).price_list_id               := l_price_list_id   ;
     -- R12 contract changes
        x_prod_txn_tbl(l_index).contract_line_id            := l_contract_line_id    ;
        x_prod_txn_tbl(l_index).contract_id                 := l_contract_id     ;
        x_prod_txn_tbl(l_index).sub_inventory               := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).no_charge_flag              := csd_process_util.get_no_chg_flag(l_lr_txn_billing_type_id) ;
        x_prod_txn_tbl(l_index).interface_to_om_flag        := 'N'               ;
        x_prod_txn_tbl(l_index).book_sales_order_flag       := 'N'               ;
        x_prod_txn_tbl(l_index).release_sales_order_flag    := 'N'               ;
        x_prod_txn_tbl(l_index).ship_sales_order_flag       := 'N'               ;
        x_prod_txn_tbl(l_index).process_txn_flag            := 'N'               ;
        IF NVL(l_auto_process_rma, 'N') = 'Y' THEN
            x_prod_txn_tbl(l_index).process_txn_flag            := 'Y'           ;
            x_prod_txn_tbl(l_index).interface_to_om_flag        := 'Y'           ;
            x_prod_txn_tbl(l_index).book_sales_order_flag       := 'Y'           ;
         -- bug fix for 4108369, Begin
            if(l_add_rma_to_id is null) THEN
        	    x_prod_txn_tbl(l_index).new_order_flag := 'Y';
            ELSE
        	    x_prod_txn_tbl(l_index).new_order_flag := 'N';
        	    x_prod_txn_tbl(l_index).add_to_order_flag := 'Y';
        	    x_prod_txn_tbl(l_index).add_to_order_id := l_add_rma_to_id;
            END IF;
         -- bug fix for 4108369, End
        END IF;

        x_prod_txn_tbl(l_index).return_reason               := l_return_reason  ;
        -- x_prod_txn_tbl(l_index).return_by_date           := sysdate          ;
        /* Fixed for FP bug#5408047
           For RMA line if source return is required then only
           default the return by date. This date will be passed to
           charges in Installed_cp_return_by_date.
        */
        l_src_return_reqd     :='N';
        l_non_src_return_reqd :='N';
        open c2( l_lr_txn_billing_type_id );
        fetch c2 into l_src_return_reqd,l_non_src_return_reqd ;
        If (c2%ISOPEN) then
           Close c2;
        END IF;
        If l_src_return_reqd ='Y' then
           x_prod_txn_tbl(l_index).return_by_date              := sysdate+l_return_days;
        ELSE
           x_prod_txn_tbl(l_index).return_by_date              := NULL          ;
        END IF;

        x_prod_txn_tbl(l_index).revision                    := l_revision       ;
        x_prod_txn_tbl(l_index).last_update_date            := sysdate          ;
        x_prod_txn_tbl(l_index).creation_date               := sysdate          ;
        x_prod_txn_tbl(l_index).last_updated_by             := FND_GLOBAL.USER_ID;
        x_prod_txn_tbl(l_index).created_by                  := FND_GLOBAL.USER_ID;
        x_prod_txn_tbl(l_index).last_update_login           := FND_GLOBAL.USER_ID;
        x_prod_txn_tbl(l_index).attribute1                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute2                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute3                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute4                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute5                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute6                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute7                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute8                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute9                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute10                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute11                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute12                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute13                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute14                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute15                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).context                     := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).prod_txn_status             := 'ENTERED';
        x_prod_txn_tbl(l_index).prod_txn_code               := 'POST';
        x_prod_txn_tbl(l_index).project_id                  := l_project_id;
        x_prod_txn_tbl(l_index).task_id                     := l_task_id;
        x_prod_txn_tbl(l_index).unit_number                 := l_unit_number;

		l_attr_code := 'RMA_RCV_ORG';
        l_default_val_num := null;
        CSD_RULES_ENGINE_PVT.GET_DEFAULT_VALUE_FROM_RULE (
          p_api_version_number    => 1.0,
          p_init_msg_list         => FND_API.G_TRUE,
          p_commit                => FND_API.G_TRUE,
          p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
          p_entity_attribute_type => l_attr_type,
          p_entity_attribute_code => l_attr_code,
          p_rule_input_rec        => l_rule_input_rec,
          x_default_value         => l_default_val_num,
          x_rule_id               => l_default_rule_id, -- swai: 12.1.1 ER 7233924
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data
        );
        if (l_default_val_num is not null) then
            x_prod_txn_tbl(l_index).inventory_org_id  := l_default_val_num;
        else
            -- Inv_org Change, Vijay , 20/3/2006
            x_prod_txn_tbl(l_index).inventory_org_id  := l_inv_org_id;
        end if;


        ---------------------------------------
        --Bug fix 5494219 Begin
		l_attr_code := 'RMA_RCV_SUBINV';
        l_default_val_char := null;
        CSD_RULES_ENGINE_PVT.GET_DEFAULT_VALUE_FROM_RULE (
          p_api_version_number    => 1.0,
          p_init_msg_list         => FND_API.G_TRUE,
          p_commit                => FND_API.G_TRUE,
          p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
          p_entity_attribute_type => l_attr_type,
          p_entity_attribute_code => l_attr_code,
          p_rule_input_rec        => l_rule_input_rec,
          x_default_value         => l_default_val_char,
          x_rule_id               => l_default_rule_id, -- swai: 12.1.1 ER 7233924
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data
        );
        if (l_default_val_char is not null) then
            x_prod_txn_tbl(l_index).sub_inventory  := l_default_val_char;
        else
            x_prod_txn_tbl(l_index).sub_inventory  := l_sub_inv;
        end if;

        l_index := l_index + 1;

    end if;

  ELSIF ( l_repair_type_ref = 'AE' ) and (p_create_thirdpty_line = 'F')  THEN

    l_index := 1;

    if (l_cps_txn_billing_type_id is not null) then

         -- Ship Customer product txn line
        x_prod_txn_tbl(l_index).product_transaction_id      := FND_API.G_MISS_NUM;
        x_prod_txn_tbl(l_index).repair_line_id              := p_repair_line_id  ;
        x_prod_txn_tbl(l_index).estimate_detail_id          := FND_API.G_MISS_NUM;
        x_prod_txn_tbl(l_index).line_category_code          := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).action_code                 := 'EXCHANGE'        ;
        x_prod_txn_tbl(l_index).txn_billing_type_id         := l_cps_txn_billing_type_id;
        x_prod_txn_tbl(l_index).action_type                 := 'SHIP'             ;

        --bug#3875036 Bug 8694111
        IF((l_enable_advanced_pricing ='Y')and (x_prod_txn_tbl(l_index).no_charge_flag ='N')) THEN
          x_prod_txn_tbl(l_index).after_warranty_cost	    := l_selling_price;
	End if;

        x_prod_txn_tbl(l_index).source_serial_number        := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).po_number                   := l_po_number; -- swai bug fix 4535829
        if ( l_ib_flag = 'Y' ) then
          x_prod_txn_tbl(l_index).non_source_serial_number    := p_serial_number ;
        else
          x_prod_txn_tbl(l_index).non_source_serial_number    := FND_API.G_MISS_CHAR;
        end if;
        x_prod_txn_tbl(l_index).organization_id             := l_org_id          ;
        x_prod_txn_tbl(l_index).business_process_id         := l_bus_process_id ;
        x_prod_txn_tbl(l_index).order_number                := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).status                      := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).inventory_item_id           := l_inv_item_id     ;
        x_prod_txn_tbl(l_index).unit_of_measure_code        := l_unit_of_measure ;
        x_prod_txn_tbl(l_index).quantity                    := p_quantity        ;
        x_prod_txn_tbl(l_index).lot_number                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).source_instance_id          := FND_API.G_MISS_NUM;
        x_prod_txn_tbl(l_index).non_source_instance_id      := p_instance_id     ;
        x_prod_txn_tbl(l_index).price_list_id               := l_price_list_id   ;
     -- R12 contract changes
        x_prod_txn_tbl(l_index).contract_line_id            := l_contract_line_id    ;
        x_prod_txn_tbl(l_index).contract_id                 := l_contract_id     ;
--        x_prod_txn_tbl(l_index).sub_inventory               := FND_API.G_MISS_CHAR;
		l_attr_code := 'SHIP_FROM_SUBINV';
        l_default_val_char := null;
        CSD_RULES_ENGINE_PVT.GET_DEFAULT_VALUE_FROM_RULE (
          p_api_version_number    => 1.0,
          p_init_msg_list         => FND_API.G_TRUE,
          p_commit                => FND_API.G_TRUE,
          p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
          p_entity_attribute_type => l_attr_type,
          p_entity_attribute_code => l_attr_code,
          p_rule_input_rec        => l_rule_input_rec,
          x_default_value         => l_default_val_char,
          x_rule_id               => l_default_rule_id, -- swai: 12.1.1 ER 7233924
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data
        );
        if (l_default_val_char is not null) then
            x_prod_txn_tbl(l_index).sub_inventory  := l_default_val_char;
        else
            x_prod_txn_tbl(l_index).sub_inventory  := FND_API.G_MISS_CHAR;
        end if;

        x_prod_txn_tbl(l_index).no_charge_flag              := csd_process_util.get_no_chg_flag(l_cps_txn_billing_type_id) ;
        x_prod_txn_tbl(l_index).release_sales_order_flag    := 'N' ;
        x_prod_txn_tbl(l_index).ship_sales_order_flag       := 'N' ;

        IF NVL(l_interface_to_om_flag, 'N') = 'Y' THEN
          x_prod_txn_tbl(l_index).process_txn_flag           := 'Y';
          if NVL(l_book_sales_order_flag, 'N') = 'Y' THEN
             x_prod_txn_tbl(l_index).interface_to_om_flag    := 'Y';
             x_prod_txn_tbl(l_index).book_sales_order_flag   := 'Y';
          else
             x_prod_txn_tbl(l_index).interface_to_om_flag    := 'Y';
             x_prod_txn_tbl(l_index).book_sales_order_flag   := 'N';
          end if;

  	      if(l_add_ship_to_id is null) THEN
	         x_prod_txn_tbl(l_index).new_order_flag := 'Y';
	      ELSE
		     x_prod_txn_tbl(l_index).new_order_flag := 'N';
		     x_prod_txn_tbl(l_index).add_to_order_flag := 'Y';
		     x_prod_txn_tbl(l_index).add_to_order_id := l_add_ship_to_id;
	      END IF;

        Else
           x_prod_txn_tbl(l_index).process_txn_flag            := 'N'               ;
           x_prod_txn_tbl(l_index).interface_to_om_flag        := 'N'               ;
           x_prod_txn_tbl(l_index).book_sales_order_flag       := 'N'               ;
        End if;

        x_prod_txn_tbl(l_index).return_reason               := FND_API.G_MISS_CHAR;
        -- x_prod_txn_tbl(l_index).return_by_date           := FND_API.G_MISS_DATE;
       /* Fixed for FP bug#5408047
          For SHIP line if either of 'source return is required'
          or 'non-source return required' is checked then only default
          the return by date. This date will be passed to charges in
          Installed_cp_return_by_date or in New_cp_return_by_date
          based on source or non-source setup in procedure Convert_to_Chg_rec
        */
        l_src_return_reqd     :='N';
        l_non_src_return_reqd :='N';
        open c2( l_cps_txn_billing_type_id );
        fetch c2 into l_src_return_reqd,l_non_src_return_reqd ;
        If (c2%ISOPEN) then
          Close c2;
        END IF;
        If l_src_return_reqd ='Y' or l_non_src_return_reqd ='Y' then
          x_prod_txn_tbl(l_index).return_by_date              := sysdate+l_return_days;
        else
          x_prod_txn_tbl(l_index).return_by_date              := NULL;
        END IF;

        x_prod_txn_tbl(l_index).revision                    := l_revision       ;
        x_prod_txn_tbl(l_index).last_update_date            := sysdate          ;
        x_prod_txn_tbl(l_index).creation_date               := sysdate          ;
        x_prod_txn_tbl(l_index).last_updated_by             := FND_GLOBAL.USER_ID;
        x_prod_txn_tbl(l_index).created_by                  := FND_GLOBAL.USER_ID;
        x_prod_txn_tbl(l_index).last_update_login           := FND_GLOBAL.USER_ID;
        x_prod_txn_tbl(l_index).attribute1                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute2                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute3                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute4                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute5                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute6                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute7                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute8                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute9                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute10                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute11                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute12                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute13                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute14                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute15                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).context                     := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).prod_txn_status             := 'ENTERED';
        x_prod_txn_tbl(l_index).prod_txn_code               := 'PRE';
        x_prod_txn_tbl(l_index).project_id                  := l_project_id;
        x_prod_txn_tbl(l_index).task_id                     := l_task_id;
        x_prod_txn_tbl(l_index).unit_number                 := l_unit_number;

        -- picking rule changes for R12
        Fnd_Profile.Get('CSD_DEF_PICK_RELEASE_RULE',l_picking_rule_id);
        x_prod_txn_tbl(l_index).picking_rule_id  := l_picking_rule_id;
        --------------------------------

		l_attr_code := 'SHIP_FROM_ORG';
        l_default_val_num := null;
        CSD_RULES_ENGINE_PVT.GET_DEFAULT_VALUE_FROM_RULE (
          p_api_version_number    => 1.0,
          p_init_msg_list         => FND_API.G_TRUE,
          p_commit                => FND_API.G_TRUE,
          p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
          p_entity_attribute_type => l_attr_type,
          p_entity_attribute_code => l_attr_code,
          p_rule_input_rec        => l_rule_input_rec,
          x_default_value         => l_default_val_num,
          x_rule_id               => l_default_rule_id, -- swai: 12.1.1 ER 7233924
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data
        );
        if (l_default_val_num is not null) then
            x_prod_txn_tbl(l_index).inventory_org_id  := l_default_val_num;
        else
            -- Inv_org Change, Vijay , 20/3/2006
            x_prod_txn_tbl(l_index).inventory_org_id  := l_inv_org_id;
        end if;


        l_index := l_index + 1;

    end if;

    if (l_cpr_txn_billing_type_id is not null) then

        -- Receive Loaner product txn line
        x_prod_txn_tbl(l_index).product_transaction_id      := FND_API.G_MISS_NUM;
        x_prod_txn_tbl(l_index).repair_line_id              := p_repair_line_id  ;
        x_prod_txn_tbl(l_index).estimate_detail_id          := FND_API.G_MISS_NUM;
        x_prod_txn_tbl(l_index).line_category_code          := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).action_code                 := 'EXCHANGE'       ;
        x_prod_txn_tbl(l_index).txn_billing_type_id         := l_cpr_txn_billing_type_id;
        x_prod_txn_tbl(l_index).action_type                 := 'RMA'            ;

        --bug#3875036 Bug 8694111
	IF((l_enable_advanced_pricing ='Y')and (x_prod_txn_tbl(l_index).no_charge_flag ='N')) THEN
           x_prod_txn_tbl(l_index).after_warranty_cost      := -l_selling_price;
	End If;


        x_prod_txn_tbl(l_index).source_serial_number        := p_serial_number  ;
        x_prod_txn_tbl(l_index).non_source_serial_number    := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).organization_id             := l_org_id          ;
        x_prod_txn_tbl(l_index).business_process_id         := l_bus_process_id ;
        x_prod_txn_tbl(l_index).order_number                := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).status                      := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).inventory_item_id           := l_inv_item_id     ;
        x_prod_txn_tbl(l_index).unit_of_measure_code        := l_unit_of_measure ;
        x_prod_txn_tbl(l_index).quantity                    := p_quantity        ;
        x_prod_txn_tbl(l_index).lot_number                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).source_instance_id          := p_instance_id     ;
        x_prod_txn_tbl(l_index).non_source_instance_id      := FND_API.G_MISS_NUM;
        x_prod_txn_tbl(l_index).price_list_id               := l_price_list_id   ;
     -- R12 contract changes
        x_prod_txn_tbl(l_index).contract_line_id            := l_contract_line_id    ;
        x_prod_txn_tbl(l_index).contract_id                 := l_contract_id     ;
        x_prod_txn_tbl(l_index).sub_inventory               := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).no_charge_flag              := csd_process_util.get_no_chg_flag(l_cpr_txn_billing_type_id);
        x_prod_txn_tbl(l_index).interface_to_om_flag        := 'N'               ;
        x_prod_txn_tbl(l_index).book_sales_order_flag       := 'N'               ;
        x_prod_txn_tbl(l_index).release_sales_order_flag    := 'N'               ;
        x_prod_txn_tbl(l_index).ship_sales_order_flag       := 'N'               ;
        x_prod_txn_tbl(l_index).process_txn_flag            := 'N'               ;
        x_prod_txn_tbl(l_index).po_number                   := l_po_number; -- swai bug fix 4535829
        IF NVL(l_auto_process_rma, 'N') = 'Y' THEN
            x_prod_txn_tbl(l_index).process_txn_flag            := 'Y'           ;
            x_prod_txn_tbl(l_index).interface_to_om_flag        := 'Y'           ;
            x_prod_txn_tbl(l_index).book_sales_order_flag       := 'Y'           ;
         -- bug fix for 4108369, Begin
           if(l_add_rma_to_id is null) THEN
             x_prod_txn_tbl(l_index).new_order_flag := 'Y';
           ELSE
             x_prod_txn_tbl(l_index).new_order_flag := 'N';
             x_prod_txn_tbl(l_index).add_to_order_flag := 'Y';
             x_prod_txn_tbl(l_index).add_to_order_id := l_add_rma_to_id;
           END IF;
        -- bug fix for 4108369, End
        END IF;

        x_prod_txn_tbl(l_index).return_reason               := l_return_reason  ;
        -- x_prod_txn_tbl(l_index).return_by_date           := sysdate          ;
        /* Fixed for FP bug#5408047
           For RMA line if source return is required then only
           default the return by date. This date will be passed to
           charges in Installed_cp_return_by_date.
         */
        l_src_return_reqd     :='N';
        l_non_src_return_reqd :='N';
        open c2( l_cpr_txn_billing_type_id );
        fetch c2 into l_src_return_reqd,l_non_src_return_reqd ;
        If (c2%ISOPEN) then
           Close c2;
        END IF;
        If l_src_return_reqd ='Y' then
           x_prod_txn_tbl(l_index).return_by_date              := sysdate+l_return_days;
        else
            x_prod_txn_tbl(l_index).return_by_date              := NULL          ;
        end if;
        x_prod_txn_tbl(l_index).revision                    := l_revision       ;
        x_prod_txn_tbl(l_index).last_update_date            := sysdate          ;
        x_prod_txn_tbl(l_index).creation_date               := sysdate          ;
        x_prod_txn_tbl(l_index).last_updated_by             := FND_GLOBAL.USER_ID;
        x_prod_txn_tbl(l_index).created_by                  := FND_GLOBAL.USER_ID;
        x_prod_txn_tbl(l_index).last_update_login           := FND_GLOBAL.USER_ID;
        x_prod_txn_tbl(l_index).attribute1                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute2                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute3                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute4                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute5                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute6                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute7                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute8                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute9                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute10                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute11                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute12                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute13                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute14                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute15                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).context                     := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).prod_txn_status             := 'ENTERED';
        x_prod_txn_tbl(l_index).prod_txn_code               := 'POST';
        x_prod_txn_tbl(l_index).project_id                  := l_project_id;
        x_prod_txn_tbl(l_index).task_id                     := l_task_id;
        x_prod_txn_tbl(l_index).unit_number                 := l_unit_number;

		l_attr_code := 'RMA_RCV_ORG';
        l_default_val_num := null;
        CSD_RULES_ENGINE_PVT.GET_DEFAULT_VALUE_FROM_RULE (
          p_api_version_number    => 1.0,
          p_init_msg_list         => FND_API.G_TRUE,
          p_commit                => FND_API.G_TRUE,
          p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
          p_entity_attribute_type => l_attr_type,
          p_entity_attribute_code => l_attr_code,
          p_rule_input_rec        => l_rule_input_rec,
          x_default_value         => l_default_val_num,
          x_rule_id               => l_default_rule_id, -- swai: 12.1.1 ER 7233924
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data
        );
        if (l_default_val_num is not null) then
            x_prod_txn_tbl(l_index).inventory_org_id  := l_default_val_num;
        else
            -- Inv_org Change, Vijay , 20/3/2006
            x_prod_txn_tbl(l_index).inventory_org_id  := l_inv_org_id;
        end if;


        ---------------------------------------
        --Bug fix 5494219 Begin
		l_attr_code := 'RMA_RCV_SUBINV';
        l_default_val_char := null;
        CSD_RULES_ENGINE_PVT.GET_DEFAULT_VALUE_FROM_RULE (
          p_api_version_number    => 1.0,
          p_init_msg_list         => FND_API.G_TRUE,
          p_commit                => FND_API.G_TRUE,
          p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
          p_entity_attribute_type => l_attr_type,
          p_entity_attribute_code => l_attr_code,
          p_rule_input_rec        => l_rule_input_rec,
          x_default_value         => l_default_val_char,
          x_rule_id               => l_default_rule_id, -- swai: 12.1.1 ER 7233924
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data
        );
        if (l_default_val_char is not null) then
            x_prod_txn_tbl(l_index).sub_inventory  := l_default_val_char;
        else
            x_prod_txn_tbl(l_index).sub_inventory  := l_sub_inv;
        end if;


        l_index := l_index + 1;

    end if;

  ELSIF l_repair_type_ref in ('ARR','WRL') and (p_create_thirdpty_line = 'F') THEN
    l_index := 1;

    if (l_ls_txn_billing_type_id is not null) then
        -- Shipping loaner product txn line
        x_prod_txn_tbl(l_index).product_transaction_id      := FND_API.G_MISS_NUM;
        x_prod_txn_tbl(l_index).repair_line_id              := p_repair_line_id  ;
        x_prod_txn_tbl(l_index).estimate_detail_id          := FND_API.G_MISS_NUM;
        x_prod_txn_tbl(l_index).action_code                 := 'LOANER'          ;
        x_prod_txn_tbl(l_index).line_category_code          := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).txn_billing_type_id         := l_ls_txn_billing_type_id;
        x_prod_txn_tbl(l_index).po_number                   := l_po_number; -- swai bug fix 4535829

       IF l_repair_type_ref = 'WRL' THEN
         x_prod_txn_tbl(l_index).action_type                 := 'WALK_IN_ISSUE'   ;
       ELSE
         x_prod_txn_tbl(l_index).action_type                 := 'SHIP'            ;
       END IF;

        --bug#3875036 Bug 8694111
	IF((l_enable_advanced_pricing ='Y') and (x_prod_txn_tbl(l_index).no_charge_flag ='N')) THEN
           x_prod_txn_tbl(l_index).after_warranty_cost	     := l_selling_price;
        End if;


        x_prod_txn_tbl(l_index).organization_id             := l_org_id          ;
        x_prod_txn_tbl(l_index).business_process_id         := l_bus_process_id ;
        x_prod_txn_tbl(l_index).order_number                := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).status                      := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).inventory_item_id           := l_inv_item_id     ;
        x_prod_txn_tbl(l_index).unit_of_measure_code        := l_unit_of_measure ;
        x_prod_txn_tbl(l_index).quantity                    := p_quantity        ;
        x_prod_txn_tbl(l_index).source_serial_number        := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).non_source_serial_number    := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).lot_number                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).source_instance_id          := FND_API.G_MISS_NUM;
        x_prod_txn_tbl(l_index).non_source_instance_id      := FND_API.G_MISS_NUM;
        x_prod_txn_tbl(l_index).price_list_id               := l_price_list_id  ;
     -- R12 contract changes
        x_prod_txn_tbl(l_index).contract_line_id            := l_contract_line_id    ;
        x_prod_txn_tbl(l_index).contract_id                 := l_contract_id    ;
--        x_prod_txn_tbl(l_index).sub_inventory               := FND_API.G_MISS_CHAR;
		l_attr_code := 'SHIP_FROM_SUBINV';
        l_default_val_char := null;
        CSD_RULES_ENGINE_PVT.GET_DEFAULT_VALUE_FROM_RULE (
          p_api_version_number    => 1.0,
          p_init_msg_list         => FND_API.G_TRUE,
          p_commit                => FND_API.G_TRUE,
          p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
          p_entity_attribute_type => l_attr_type,
          p_entity_attribute_code => l_attr_code,
          p_rule_input_rec        => l_rule_input_rec,
          x_default_value         => l_default_val_char,
          x_rule_id               => l_default_rule_id, -- swai: 12.1.1 ER 7233924
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data
        );
        if (l_default_val_char is not null) then
            x_prod_txn_tbl(l_index).sub_inventory  := l_default_val_char;
        else
            x_prod_txn_tbl(l_index).sub_inventory  := FND_API.G_MISS_CHAR;
        end if;

        x_prod_txn_tbl(l_index).no_charge_flag              := csd_process_util.get_no_chg_flag(l_ls_txn_billing_type_id);
        x_prod_txn_tbl(l_index).release_sales_order_flag    := 'N'               ;
        x_prod_txn_tbl(l_index).ship_sales_order_flag       := 'N'               ;

        IF NVL(l_interface_to_om_flag, 'N') = 'Y' and l_repair_type_ref = 'ARR' THEN
          x_prod_txn_tbl(l_index).process_txn_flag           := 'Y';
          if NVL(l_book_sales_order_flag, 'N') = 'Y' THEN
             x_prod_txn_tbl(l_index).interface_to_om_flag    := 'Y';
             x_prod_txn_tbl(l_index).book_sales_order_flag   := 'Y';
          else
             x_prod_txn_tbl(l_index).interface_to_om_flag    := 'Y';
             x_prod_txn_tbl(l_index).book_sales_order_flag   := 'N';
          end if;

  	      if(l_add_ship_to_id is null) THEN
	         x_prod_txn_tbl(l_index).new_order_flag := 'Y';
	      ELSE
		     x_prod_txn_tbl(l_index).new_order_flag := 'N';
		     x_prod_txn_tbl(l_index).add_to_order_flag := 'Y';
		     x_prod_txn_tbl(l_index).add_to_order_id := l_add_ship_to_id;
	      END IF;

        Else
           x_prod_txn_tbl(l_index).process_txn_flag            := 'N'               ;
           x_prod_txn_tbl(l_index).interface_to_om_flag        := 'N'               ;
           x_prod_txn_tbl(l_index).book_sales_order_flag       := 'N'               ;
        End if;

        x_prod_txn_tbl(l_index).return_reason               := FND_API.G_MISS_CHAR;
        -- x_prod_txn_tbl(l_index).return_by_date           := FND_API.G_MISS_DATE;
        /* Fixed for FP bug#5408047
           For SHIP line if either of 'source return is required'
           or 'non-source return required' is checked then only default
           the return by date. This date will be passed to charges in
           Installed_cp_return_by_date or in New_cp_return_by_date
           based on source or non-source setup in procedure Convert_to_Chg_rec
        */
        l_src_return_reqd     :='N';
        l_non_src_return_reqd :='N';
        open c2( l_ls_txn_billing_type_id );
        fetch c2 into l_src_return_reqd,l_non_src_return_reqd ;
        If (c2%ISOPEN) then
           Close c2;
        END IF;
        If l_src_return_reqd ='Y' or l_non_src_return_reqd ='Y' then
          x_prod_txn_tbl(l_index).return_by_date              := sysdate+l_return_days;
        else
          x_prod_txn_tbl(l_index).return_by_date              := NULL;
        end if;

        x_prod_txn_tbl(l_index).revision                    := l_revision       ;
        x_prod_txn_tbl(l_index).last_update_date            := sysdate          ;
        x_prod_txn_tbl(l_index).creation_date               := sysdate          ;
        x_prod_txn_tbl(l_index).last_updated_by             := FND_GLOBAL.USER_ID;
        x_prod_txn_tbl(l_index).created_by                  := FND_GLOBAL.USER_ID;
        x_prod_txn_tbl(l_index).last_update_login           := FND_GLOBAL.USER_ID;
        x_prod_txn_tbl(l_index).attribute1                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute2                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute3                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute4                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute5                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute6                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute7                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute8                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute9                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute10                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute11                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute12                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute13                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute14                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute15                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).context                     := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).prod_txn_status             := 'ENTERED';
        x_prod_txn_tbl(l_index).prod_txn_code               := 'PRE';
        x_prod_txn_tbl(l_index).project_id                  := l_project_id;
        x_prod_txn_tbl(l_index).task_id                     := l_task_id;
        x_prod_txn_tbl(l_index).unit_number                 := l_unit_number;


        -- picking rule changes for R12
        Fnd_Profile.Get('CSD_DEF_PICK_RELEASE_RULE',l_picking_rule_id);
        x_prod_txn_tbl(l_index).picking_rule_id  := l_picking_rule_id;
        --------------------------------

		l_attr_code := 'SHIP_FROM_ORG';
        l_default_val_num := null;
        CSD_RULES_ENGINE_PVT.GET_DEFAULT_VALUE_FROM_RULE (
          p_api_version_number    => 1.0,
          p_init_msg_list         => FND_API.G_TRUE,
          p_commit                => FND_API.G_TRUE,
          p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
          p_entity_attribute_type => l_attr_type,
          p_entity_attribute_code => l_attr_code,
          p_rule_input_rec        => l_rule_input_rec,
          x_default_value         => l_default_val_num,
          x_rule_id               => l_default_rule_id, -- swai: 12.1.1 ER 7233924
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data
        );
        if (l_default_val_num is not null) then
            x_prod_txn_tbl(l_index).inventory_org_id  := l_default_val_num;
        else
            -- Inv_org Change, Vijay , 20/3/2006
            x_prod_txn_tbl(l_index).inventory_org_id  := l_inv_org_id;
        end if;

        l_index := l_index + 1;
    end if;

    if (l_cpr_txn_billing_type_id is not null) then

        -- Receive customer product txn line
        x_prod_txn_tbl(l_index).product_transaction_id      := FND_API.G_MISS_NUM;
        x_prod_txn_tbl(l_index).repair_line_id              := p_repair_line_id  ;
        x_prod_txn_tbl(l_index).estimate_detail_id          := FND_API.G_MISS_NUM;
        x_prod_txn_tbl(l_index).action_code                 := 'CUST_PROD'        ;
        x_prod_txn_tbl(l_index).line_category_code          := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).txn_billing_type_id         := l_cpr_txn_billing_type_id;
        x_prod_txn_tbl(l_index).po_number                   := l_po_number;  -- swai bug fix 4535829

       IF l_repair_type_ref = 'WRL' THEN
         x_prod_txn_tbl(l_index).action_type                 := 'WALK_IN_RECEIPT' ;
       ELSE
         x_prod_txn_tbl(l_index).action_type                 := 'RMA'             ;
       END IF;

        --bug#3875036 Bug 8694111
	IF((l_enable_advanced_pricing ='Y')and (x_prod_txn_tbl(l_index).no_charge_flag ='N')) THEN
           x_prod_txn_tbl(l_index).after_warranty_cost	     := -l_selling_price;
        End if;

        x_prod_txn_tbl(l_index).organization_id             := l_org_id          ;
        x_prod_txn_tbl(l_index).business_process_id         := l_bus_process_id  ;
        x_prod_txn_tbl(l_index).order_number                := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).status                      := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).inventory_item_id           := l_inv_item_id     ;
        x_prod_txn_tbl(l_index).unit_of_measure_code        := l_unit_of_measure ;
        x_prod_txn_tbl(l_index).quantity                    := p_quantity        ;
        x_prod_txn_tbl(l_index).source_serial_number        := p_serial_number;
        x_prod_txn_tbl(l_index).non_source_serial_number    := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).lot_number                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).source_instance_id          := p_instance_id     ;
        x_prod_txn_tbl(l_index).non_source_instance_id      := FND_API.G_MISS_NUM;
        x_prod_txn_tbl(l_index).price_list_id               := l_price_list_id   ;
     -- R12 contract changes
        x_prod_txn_tbl(l_index).contract_line_id            := l_contract_line_id    ;
        x_prod_txn_tbl(l_index).contract_id                 := l_contract_id     ;
        x_prod_txn_tbl(l_index).sub_inventory               := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).no_charge_flag              := csd_process_util.get_no_chg_flag(l_cpr_txn_billing_type_id);
        x_prod_txn_tbl(l_index).release_sales_order_flag    := 'N'               ;
        x_prod_txn_tbl(l_index).ship_sales_order_flag       := 'N'               ;

        IF NVL(l_auto_process_rma, 'N') = 'Y' THEN
           x_prod_txn_tbl(l_index).process_txn_flag            := 'Y' ;
           x_prod_txn_tbl(l_index).interface_to_om_flag        := 'Y' ;
           x_prod_txn_tbl(l_index).book_sales_order_flag       := 'Y' ;
    -- bug fix for 4108369, Begin
           if(l_add_rma_to_id is null) THEN
             x_prod_txn_tbl(l_index).new_order_flag := 'Y';
           ELSE
             x_prod_txn_tbl(l_index).new_order_flag := 'N';
             x_prod_txn_tbl(l_index).add_to_order_flag := 'Y';
             x_prod_txn_tbl(l_index).add_to_order_id := l_add_rma_to_id;
           END IF;
    -- bug fix for 4108369, End
        ELSE
           x_prod_txn_tbl(l_index).process_txn_flag            := 'N' ;
           x_prod_txn_tbl(l_index).interface_to_om_flag        := 'N' ;
           x_prod_txn_tbl(l_index).book_sales_order_flag       := 'N' ;
        END IF;

        x_prod_txn_tbl(l_index).return_reason               := l_return_reason  ;
        -- x_prod_txn_tbl(l_index).return_by_date           := sysdate          ;
        /* Fixed for FP bug#5408047
           For RMA line if source return is required then only
           default the return by date. This date will be passed to
           charges in Installed_cp_return_by_date.
        */
        l_src_return_reqd     :='N';
        l_non_src_return_reqd :='N';
        open c2( l_cpr_txn_billing_type_id );
        fetch c2 into l_src_return_reqd,l_non_src_return_reqd ;
        If (c2%ISOPEN) then
           Close c2;
        END IF;
        If l_src_return_reqd ='Y' then
           x_prod_txn_tbl(l_index).return_by_date              := sysdate+l_return_days;
        else
           x_prod_txn_tbl(l_index).return_by_date              := NULL         ;
        end IF;

        x_prod_txn_tbl(l_index).revision                    := l_revision       ;
        x_prod_txn_tbl(l_index).last_update_date            := sysdate          ;
        x_prod_txn_tbl(l_index).creation_date               := sysdate          ;
        x_prod_txn_tbl(l_index).last_updated_by             := FND_GLOBAL.USER_ID;
        x_prod_txn_tbl(l_index).created_by                  := FND_GLOBAL.USER_ID;
        x_prod_txn_tbl(l_index).last_update_login           := FND_GLOBAL.USER_ID;
        x_prod_txn_tbl(l_index).attribute1                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute2                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute3                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute4                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute5                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute6                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute7                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute8                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute9                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute10                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute11                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute12                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute13                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute14                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute15                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).context                     := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).prod_txn_status             := 'ENTERED';
        x_prod_txn_tbl(l_index).prod_txn_code               := 'PRE';
        x_prod_txn_tbl(l_index).project_id                  := l_project_id;
        x_prod_txn_tbl(l_index).task_id                     := l_task_id;
        x_prod_txn_tbl(l_index).unit_number                 := l_unit_number;

		l_attr_code := 'RMA_RCV_ORG';
        l_default_val_num := null;
        CSD_RULES_ENGINE_PVT.GET_DEFAULT_VALUE_FROM_RULE (
          p_api_version_number    => 1.0,
          p_init_msg_list         => FND_API.G_TRUE,
          p_commit                => FND_API.G_TRUE,
          p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
          p_entity_attribute_type => l_attr_type,
          p_entity_attribute_code => l_attr_code,
          p_rule_input_rec        => l_rule_input_rec,
          x_default_value         => l_default_val_num,
          x_rule_id               => l_default_rule_id, -- swai: 12.1.1 ER 7233924
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data
        );
        if (l_default_val_num is not null) then
            x_prod_txn_tbl(l_index).inventory_org_id  := l_default_val_num;
        else
            -- Inv_org Change, Vijay , 20/3/2006
            x_prod_txn_tbl(l_index).inventory_org_id  := l_inv_org_id;
        end if;

        ---------------------------------------
        --Bug fix 5494219 Begin
  		l_attr_code := 'RMA_RCV_SUBINV';
        l_default_val_char := null;
        CSD_RULES_ENGINE_PVT.GET_DEFAULT_VALUE_FROM_RULE (
          p_api_version_number    => 1.0,
          p_init_msg_list         => FND_API.G_TRUE,
          p_commit                => FND_API.G_TRUE,
          p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
          p_entity_attribute_type => l_attr_type,
          p_entity_attribute_code => l_attr_code,
          p_rule_input_rec        => l_rule_input_rec,
          x_default_value         => l_default_val_char,
          x_rule_id               => l_default_rule_id, -- swai: 12.1.1 ER 7233924
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data
        );
        if (l_default_val_char is not null) then
            x_prod_txn_tbl(l_index).sub_inventory  := l_default_val_char;
        else
            x_prod_txn_tbl(l_index).sub_inventory  := l_sub_inv;
        end if;

        l_index := l_index + 1;

    end if;


    if (l_cps_txn_billing_type_id is not null) then

        -- ship customer product txn line
        x_prod_txn_tbl(l_index).product_transaction_id      := FND_API.G_MISS_NUM;
        x_prod_txn_tbl(l_index).repair_line_id              := p_repair_line_id  ;
        x_prod_txn_tbl(l_index).estimate_detail_id          := FND_API.G_MISS_NUM;
        x_prod_txn_tbl(l_index).action_code                 := 'CUST_PROD'       ;
        x_prod_txn_tbl(l_index).line_category_code          := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).txn_billing_type_id         := l_cps_txn_billing_type_id;
        x_prod_txn_tbl(l_index).po_number                   := l_po_number; -- swai bug fix 4535829

       IF l_repair_type_ref = 'WRL' THEN
        x_prod_txn_tbl(l_index).action_type                 := 'WALK_IN_ISSUE' ;
       ELSE
        x_prod_txn_tbl(l_index).action_type                 := 'SHIP'             ;
       END IF;

        --bug#3875036 Bug 8694111
	IF((l_enable_advanced_pricing ='Y') and (x_prod_txn_tbl(l_index).no_charge_flag ='N')) THEN
           x_prod_txn_tbl(l_index).after_warranty_cost	    := l_selling_price;
        End if;

        x_prod_txn_tbl(l_index).organization_id             := l_org_id          ;
        x_prod_txn_tbl(l_index).business_process_id         := l_bus_process_id;
        x_prod_txn_tbl(l_index).order_number                := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).status                      := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).inventory_item_id           := l_inv_item_id     ;
        x_prod_txn_tbl(l_index).unit_of_measure_code        := l_unit_of_measure ;
        x_prod_txn_tbl(l_index).quantity                    := p_quantity        ;
        -- x_prod_txn_tbl(l_index).source_serial_number        := p_serial_number ;
        x_prod_txn_tbl(l_index).non_source_serial_number    := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).lot_number                  := FND_API.G_MISS_CHAR;

        -- Fix for bug# 3549430
        if (l_serial_num_control_code = 1 and l_ib_flag = 'Y') then
          x_prod_txn_tbl(l_index).source_instance_id         := FND_API.G_MISS_NUM;
          x_prod_txn_tbl(l_index).source_serial_number       := FND_API.G_MISS_CHAR;
        else
          x_prod_txn_tbl(l_index).source_instance_id         := p_instance_id;
          x_prod_txn_tbl(l_index).source_serial_number       := p_serial_number;
        end if;

        -- x_prod_txn_tbl(l_index).source_instance_id          := p_instance_id ;
        x_prod_txn_tbl(l_index).non_source_instance_id      := FND_API.G_MISS_NUM;
        x_prod_txn_tbl(l_index).price_list_id               := l_price_list_id   ;
     -- R12 contract changes
        x_prod_txn_tbl(l_index).contract_line_id            := l_contract_line_id    ;
        x_prod_txn_tbl(l_index).contract_id                 := l_contract_id     ;
--        x_prod_txn_tbl(l_index).sub_inventory               := FND_API.G_MISS_CHAR;
		l_attr_code := 'SHIP_FROM_SUBINV';
        l_default_val_char := null;
        CSD_RULES_ENGINE_PVT.GET_DEFAULT_VALUE_FROM_RULE (
          p_api_version_number    => 1.0,
          p_init_msg_list         => FND_API.G_TRUE,
          p_commit                => FND_API.G_TRUE,
          p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
          p_entity_attribute_type => l_attr_type,
          p_entity_attribute_code => l_attr_code,
          p_rule_input_rec        => l_rule_input_rec,
          x_default_value         => l_default_val_char,
          x_rule_id               => l_default_rule_id, -- swai: 12.1.1 ER 7233924
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data
        );
        if (l_default_val_char is not null) then
            x_prod_txn_tbl(l_index).sub_inventory  := l_default_val_char;
        else
            x_prod_txn_tbl(l_index).sub_inventory  := FND_API.G_MISS_CHAR;
        end if;

        x_prod_txn_tbl(l_index).no_charge_flag              := csd_process_util.get_no_chg_flag(l_cps_txn_billing_type_id) ;
        x_prod_txn_tbl(l_index).interface_to_om_flag        := 'N'               ;
        x_prod_txn_tbl(l_index).book_sales_order_flag       := 'N'               ;
        x_prod_txn_tbl(l_index).release_sales_order_flag    := 'N'               ;
        x_prod_txn_tbl(l_index).ship_sales_order_flag       := 'N'               ;
        x_prod_txn_tbl(l_index).process_txn_flag            := 'N'               ;
        x_prod_txn_tbl(l_index).return_reason               := FND_API.G_MISS_CHAR;
        -- x_prod_txn_tbl(l_index).return_by_date           := FND_API.G_MISS_DATE;
        /* Fixed for FP bug#5408047
           For SHIP line if either of 'source return is required'
           or 'non-source return required' is checked then only default
           the return by date. This date will be passed to charges in
           Installed_cp_return_by_date or in New_cp_return_by_date
           based on source or non-source setup in procedure Convert_to_Chg_rec
         */
        l_src_return_reqd     :='N';
        l_non_src_return_reqd :='N';
        open c2( l_cps_txn_billing_type_id );
        fetch c2 into l_src_return_reqd,l_non_src_return_reqd ;
        If (c2%ISOPEN) then
          Close c2;
        END IF;
        If l_src_return_reqd ='Y' or l_non_src_return_reqd ='Y' then
          x_prod_txn_tbl(l_index).return_by_date              := sysdate+l_return_days;
        else
          x_prod_txn_tbl(l_index).return_by_date              := NULL;
        end if;

        x_prod_txn_tbl(l_index).revision                    := l_revision       ;
        x_prod_txn_tbl(l_index).last_update_date            := sysdate          ;
        x_prod_txn_tbl(l_index).creation_date               := sysdate          ;
        x_prod_txn_tbl(l_index).last_updated_by             := FND_GLOBAL.USER_ID;
        x_prod_txn_tbl(l_index).created_by                  := FND_GLOBAL.USER_ID;
        x_prod_txn_tbl(l_index).last_update_login           := FND_GLOBAL.USER_ID;
        x_prod_txn_tbl(l_index).attribute1                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute2                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute3                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute4                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute5                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute6                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute7                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute8                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute9                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute10                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute11                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute12                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute13                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute14                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute15                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).context                     := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).prod_txn_status             := 'ENTERED';
        x_prod_txn_tbl(l_index).prod_txn_code               := 'POST';
        x_prod_txn_tbl(l_index).project_id                  := l_project_id;
        x_prod_txn_tbl(l_index).task_id                     := l_task_id;
        x_prod_txn_tbl(l_index).unit_number                 := l_unit_number;

        -- picking rule changes for R12
        Fnd_Profile.Get('CSD_DEF_PICK_RELEASE_RULE',l_picking_rule_id);
        x_prod_txn_tbl(l_index).picking_rule_id  := l_picking_rule_id;
        --------------------------------

		l_attr_code := 'SHIP_FROM_ORG';
        l_default_val_num := null;
        CSD_RULES_ENGINE_PVT.GET_DEFAULT_VALUE_FROM_RULE (
          p_api_version_number    => 1.0,
          p_init_msg_list         => FND_API.G_TRUE,
          p_commit                => FND_API.G_TRUE,
          p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
          p_entity_attribute_type => l_attr_type,
          p_entity_attribute_code => l_attr_code,
          p_rule_input_rec        => l_rule_input_rec,
          x_default_value         => l_default_val_num,
          x_rule_id               => l_default_rule_id, -- swai: 12.1.1 ER 7233924
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data
        );
        if (l_default_val_num is not null) then
            x_prod_txn_tbl(l_index).inventory_org_id  := l_default_val_num;
        else
            -- Inv_org Change, Vijay , 20/3/2006
            x_prod_txn_tbl(l_index).inventory_org_id  := l_inv_org_id;
        end if;

        l_index := l_index + 1;

    end if;

    if (l_lr_txn_billing_type_id is not null) then

        -- Receive loaner product txn line
        x_prod_txn_tbl(l_index).product_transaction_id      := FND_API.G_MISS_NUM;
        x_prod_txn_tbl(l_index).repair_line_id              := p_repair_line_id  ;
        x_prod_txn_tbl(l_index).estimate_detail_id          := FND_API.G_MISS_NUM;
        x_prod_txn_tbl(l_index).action_code                 := 'LOANER'          ;
        x_prod_txn_tbl(l_index).line_category_code          := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).txn_billing_type_id         := l_lr_txn_billing_type_id;
        x_prod_txn_tbl(l_index).po_number                   := l_po_number; -- swai bug fix 4535829
       IF l_repair_type_ref = 'WRL' THEN
        x_prod_txn_tbl(l_index).action_type                 := 'WALK_IN_RECEIPT'   ;
       ELSE
        x_prod_txn_tbl(l_index).action_type                 := 'RMA'            ;
       END IF;

        --bug#3875036 Bug 8694111
        IF((l_enable_advanced_pricing ='Y')and (x_prod_txn_tbl(l_index).no_charge_flag ='N')) THEN
           x_prod_txn_tbl(l_index).after_warranty_cost	    := -l_selling_price;
        End if;


        x_prod_txn_tbl(l_index).organization_id             := l_org_id          ;
        x_prod_txn_tbl(l_index).business_process_id         := l_bus_process_id ;
        x_prod_txn_tbl(l_index).order_number                := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).status                      := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).inventory_item_id           := l_inv_item_id    ;
        x_prod_txn_tbl(l_index).unit_of_measure_code        := l_unit_of_measure ;
        x_prod_txn_tbl(l_index).quantity                    := p_quantity       ;
        -- Fix for bug#3704155
        --x_prod_txn_tbl(l_index).source_serial_number        := p_serial_number;
        x_prod_txn_tbl(l_index).source_serial_number        := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).non_source_serial_number    := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).lot_number                  := FND_API.G_MISS_CHAR;
        -- Fix for bug#3704155
        --x_prod_txn_tbl(l_index).source_instance_id          := p_instance_id    ;
        x_prod_txn_tbl(l_index).source_instance_id          := FND_API.G_MISS_NUM;
        x_prod_txn_tbl(l_index).non_source_instance_id      := FND_API.G_MISS_NUM;
        x_prod_txn_tbl(l_index).price_list_id               := l_price_list_id  ;
     -- R12 contract changes
        x_prod_txn_tbl(l_index).contract_line_id            := l_contract_line_id    ;
        x_prod_txn_tbl(l_index).contract_id                 := l_contract_id    ;
        x_prod_txn_tbl(l_index).sub_inventory               := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).no_charge_flag              := csd_process_util.get_no_chg_flag(l_lr_txn_billing_type_id);
        x_prod_txn_tbl(l_index).interface_to_om_flag        := 'N'               ;
        x_prod_txn_tbl(l_index).book_sales_order_flag       := 'N'               ;
        x_prod_txn_tbl(l_index).release_sales_order_flag    := 'N'               ;
        x_prod_txn_tbl(l_index).ship_sales_order_flag       := 'N'               ;
        x_prod_txn_tbl(l_index).process_txn_flag            := 'N'               ;
        x_prod_txn_tbl(l_index).return_reason               := l_return_reason;
        -- x_prod_txn_tbl(l_index).return_by_date           := sysdate          ;
        /* Fixed for FP bug#5408047
           For RMA line if source return is required then only
           default the return by date. This date will be passed to
           charges in Installed_cp_return_by_date.
         */
        l_src_return_reqd     :='N';
        l_non_src_return_reqd :='N';
        open c2( l_lr_txn_billing_type_id );
        fetch c2 into l_src_return_reqd,l_non_src_return_reqd ;
        If (c2%ISOPEN) then
          Close c2;
        END IF;
        If l_src_return_reqd ='Y' then
          x_prod_txn_tbl(l_index).return_by_date              := sysdate+l_return_days;
        else
          x_prod_txn_tbl(l_index).return_by_date              := NULL         ;
        end if;

        x_prod_txn_tbl(l_index).revision                    := l_revision       ;
        x_prod_txn_tbl(l_index).last_update_date            := sysdate          ;
        x_prod_txn_tbl(l_index).creation_date               := sysdate          ;
        x_prod_txn_tbl(l_index).last_updated_by             := FND_GLOBAL.USER_ID;
        x_prod_txn_tbl(l_index).created_by                  := FND_GLOBAL.USER_ID;
        x_prod_txn_tbl(l_index).last_update_login           := FND_GLOBAL.USER_ID;
        x_prod_txn_tbl(l_index).attribute1                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute2                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute3                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute4                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute5                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute6                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute7                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute8                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute9                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute10                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute11                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute12                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute13                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute14                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute15                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).context                     := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).prod_txn_status             := 'ENTERED';
        x_prod_txn_tbl(l_index).prod_txn_code               := 'POST';
        x_prod_txn_tbl(l_index).project_id                  := l_project_id;
        x_prod_txn_tbl(l_index).task_id                     := l_task_id;
        x_prod_txn_tbl(l_index).unit_number                 := l_unit_number;

		l_attr_code := 'RMA_RCV_ORG';
        l_default_val_num := null;
        CSD_RULES_ENGINE_PVT.GET_DEFAULT_VALUE_FROM_RULE (
          p_api_version_number    => 1.0,
          p_init_msg_list         => FND_API.G_TRUE,
          p_commit                => FND_API.G_TRUE,
          p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
          p_entity_attribute_type => l_attr_type,
          p_entity_attribute_code => l_attr_code,
          p_rule_input_rec        => l_rule_input_rec,
          x_default_value         => l_default_val_num,
          x_rule_id               => l_default_rule_id, -- swai: 12.1.1 ER 7233924
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data
        );
        if (l_default_val_num is not null) then
            x_prod_txn_tbl(l_index).inventory_org_id  := l_default_val_num;
        else
            -- Inv_org Change, Vijay , 20/3/2006
            x_prod_txn_tbl(l_index).inventory_org_id  := l_inv_org_id;
        end if;

        ---------------------------------------
        --Bug fix 5494219 Begin
  		l_attr_code := 'RMA_RCV_SUBINV';
        l_default_val_char := null;
        CSD_RULES_ENGINE_PVT.GET_DEFAULT_VALUE_FROM_RULE (
          p_api_version_number    => 1.0,
          p_init_msg_list         => FND_API.G_TRUE,
          p_commit                => FND_API.G_TRUE,
          p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
          p_entity_attribute_type => l_attr_type,
          p_entity_attribute_code => l_attr_code,
          p_rule_input_rec        => l_rule_input_rec,
          x_default_value         => l_default_val_char,
          x_rule_id               => l_default_rule_id, -- swai: 12.1.1 ER 7233924
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data
        );
        if (l_default_val_char is not null) then
            x_prod_txn_tbl(l_index).sub_inventory  := l_default_val_char;
        else
            x_prod_txn_tbl(l_index).sub_inventory  := l_sub_inv;
        end if;

        l_index := l_index + 1;

    end if;

  END IF;


  IF NVL(l_third_party_flag, 'N') = 'Y' or (p_create_thirdpty_line = 'T') THEN

    if (l_third_ship_txn_b_type_id is not null) then

        -- Shipping customer product txn line
        x_prod_txn_tbl(l_index).product_transaction_id      := FND_API.G_MISS_NUM;
        x_prod_txn_tbl(l_index).repair_line_id              := p_repair_line_id  ;
        x_prod_txn_tbl(l_index).estimate_detail_id          := FND_API.G_MISS_NUM;
        x_prod_txn_tbl(l_index).line_category_code          := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).txn_billing_type_id         := l_third_ship_txn_b_type_id;
        x_prod_txn_tbl(l_index).po_number                   := l_po_number; -- swai bug fix 4535829

        x_prod_txn_tbl(l_index).action_code                := 'CUST_PROD';
        x_prod_txn_tbl(l_index).non_source_instance_id     := FND_API.G_MISS_NUM;
        x_prod_txn_tbl(l_index).non_source_serial_number   := FND_API.G_MISS_CHAR;

        -- Fix for bug# 3549430
        if (l_serial_num_control_code = 1 and l_ib_flag = 'Y') then
            x_prod_txn_tbl(l_index).source_instance_id         := FND_API.G_MISS_NUM;
            x_prod_txn_tbl(l_index).source_serial_number       := FND_API.G_MISS_CHAR;
        else
            x_prod_txn_tbl(l_index).source_instance_id         := p_instance_id;
            x_prod_txn_tbl(l_index).source_serial_number       := p_serial_number;
        end if;

        x_prod_txn_tbl(l_index).action_type                 := 'SHIP_THIRD_PTY'           ;

        --bug#3875036 bug 8694111
	IF((l_enable_advanced_pricing ='Y') and (x_prod_txn_tbl(l_index).no_charge_flag ='N')) THEN
          x_prod_txn_tbl(l_index).after_warranty_cost	    := l_selling_price;
	End if;

        x_prod_txn_tbl(l_index).organization_id             := l_org_id          ;
        x_prod_txn_tbl(l_index).business_process_id         := l_bus_process_id ;
        x_prod_txn_tbl(l_index).order_number                := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).status                      := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).inventory_item_id           := l_inv_item_id     ;
        x_prod_txn_tbl(l_index).unit_of_measure_code        := l_unit_of_measure ;
        x_prod_txn_tbl(l_index).quantity                    := p_quantity        ;
        x_prod_txn_tbl(l_index).lot_number                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).price_list_id               := l_price_list_id   ;
     -- R12 contract changes
        x_prod_txn_tbl(l_index).contract_line_id            := l_contract_line_id    ;
        x_prod_txn_tbl(l_index).contract_id                 := l_contract_id     ;
--        x_prod_txn_tbl(l_index).sub_inventory               := FND_API.G_MISS_CHAR;
		l_attr_code := 'SHIP_FROM_SUBINV';
        l_default_val_char := null;
        CSD_RULES_ENGINE_PVT.GET_DEFAULT_VALUE_FROM_RULE (
          p_api_version_number    => 1.0,
          p_init_msg_list         => FND_API.G_TRUE,
          p_commit                => FND_API.G_TRUE,
          p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
          p_entity_attribute_type => l_attr_type,
          p_entity_attribute_code => l_attr_code,
          p_rule_input_rec        => l_rule_input_rec,
          x_default_value         => l_default_val_char,
          x_rule_id               => l_default_rule_id, -- swai: 12.1.1 ER 7233924
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data
        );
        if (l_default_val_char is not null) then
            x_prod_txn_tbl(l_index).sub_inventory  := l_default_val_char;
        else
            x_prod_txn_tbl(l_index).sub_inventory  := FND_API.G_MISS_CHAR;
        end if;

        x_prod_txn_tbl(l_index).no_charge_flag              := csd_process_util.get_no_chg_flag(l_third_ship_txn_b_type_id);
        x_prod_txn_tbl(l_index).release_sales_order_flag    := 'N'               ;
        x_prod_txn_tbl(l_index).ship_sales_order_flag       := 'N'               ;


        IF NVL(l_interface_to_om_flag, 'N') = 'Y' THEN
          x_prod_txn_tbl(l_index).process_txn_flag           := 'Y';
          if NVL(l_book_sales_order_flag, 'N') = 'Y' THEN
             x_prod_txn_tbl(l_index).interface_to_om_flag    := 'Y';
             x_prod_txn_tbl(l_index).book_sales_order_flag   := 'Y';
          else
             x_prod_txn_tbl(l_index).interface_to_om_flag    := 'Y';
             x_prod_txn_tbl(l_index).book_sales_order_flag   := 'N';
          end if;

  	      if(l_add_ship_to_id is null) THEN
	         x_prod_txn_tbl(l_index).new_order_flag := 'Y';
	      ELSE
		     x_prod_txn_tbl(l_index).new_order_flag := 'N';
		     x_prod_txn_tbl(l_index).add_to_order_flag := 'Y';
		     x_prod_txn_tbl(l_index).add_to_order_id := l_add_ship_to_id;
	      END IF;
        Else
           x_prod_txn_tbl(l_index).process_txn_flag            := 'N'               ;
           x_prod_txn_tbl(l_index).interface_to_om_flag        := 'N'               ;
           x_prod_txn_tbl(l_index).book_sales_order_flag       := 'N'               ;
        End if;

        x_prod_txn_tbl(l_index).return_reason               := FND_API.G_MISS_CHAR;
        -- x_prod_txn_tbl(l_index).return_by_date           := FND_API.G_MISS_DATE;
        /* Fixed for FP bug#5408047
           For SHIP line if either of 'source return is required'
           or 'non-source return required' is checked then only default
           the return by date. This date will be passed to charges in
           Installed_cp_return_by_date or in New_cp_return_by_date
           based on source or non-source setup in procedure Convert_to_Chg_rec
         */
        l_src_return_reqd:='N';
        l_non_src_return_reqd:='N';
        open c2( l_third_ship_txn_b_type_id );
        fetch c2 into l_src_return_reqd,l_non_src_return_reqd ;
        If (c2%ISOPEN) then
          Close c2;
        END IF;

        If l_src_return_reqd ='Y' or l_non_src_return_reqd ='Y' then
          x_prod_txn_tbl(l_index).return_by_date              := sysdate+l_return_days;
        ELSE
          x_prod_txn_tbl(l_index).return_by_date              := NULL;
        END IF;
        x_prod_txn_tbl(l_index).revision                    := l_revision       ;
        x_prod_txn_tbl(l_index).last_update_date            := sysdate          ;
        x_prod_txn_tbl(l_index).creation_date               := sysdate          ;
        x_prod_txn_tbl(l_index).last_updated_by             := FND_GLOBAL.USER_ID;
        x_prod_txn_tbl(l_index).created_by                  := FND_GLOBAL.USER_ID;
        x_prod_txn_tbl(l_index).last_update_login           := FND_GLOBAL.USER_ID;
        x_prod_txn_tbl(l_index).attribute1                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute2                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute3                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute4                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute5                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute6                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute7                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute8                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute9                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute10                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute11                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute12                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute13                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute14                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute15                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).context                     := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).prod_txn_status             := 'ENTERED';
        x_prod_txn_tbl(l_index).prod_txn_code               := 'POST';
        x_prod_txn_tbl(l_index).project_id                  := l_project_id;
        x_prod_txn_tbl(l_index).task_id                     := l_task_id;
        x_prod_txn_tbl(l_index).unit_number                 := l_unit_number;

        -- picking rule changes for R12
        Fnd_Profile.Get('CSD_DEF_PICK_RELEASE_RULE',l_picking_rule_id);
        x_prod_txn_tbl(l_index).picking_rule_id  := l_picking_rule_id;
        --------------------------------

		l_attr_code := 'SHIP_FROM_ORG';
        l_default_val_num := null;
        CSD_RULES_ENGINE_PVT.GET_DEFAULT_VALUE_FROM_RULE (
          p_api_version_number    => 1.0,
          p_init_msg_list         => FND_API.G_TRUE,
          p_commit                => FND_API.G_TRUE,
          p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
          p_entity_attribute_type => l_attr_type,
          p_entity_attribute_code => l_attr_code,
          p_rule_input_rec        => l_rule_input_rec,
          x_default_value         => l_default_val_num,
          x_rule_id               => l_default_rule_id, -- swai: 12.1.1 ER 7233924
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data
        );
        if (l_default_val_num is not null) then
            x_prod_txn_tbl(l_index).inventory_org_id  := l_default_val_num;
        else
            -- Inv_org Change, Vijay , 20/3/2006
            x_prod_txn_tbl(l_index).inventory_org_id  := l_inv_org_id;
        end if;


		l_attr_code := 'VENDOR_ACCOUNT';
        l_default_val_num := null;
        CSD_RULES_ENGINE_PVT.GET_DEFAULT_VALUE_FROM_RULE (
          p_api_version_number    => 1.0,
          p_init_msg_list         => FND_API.G_TRUE,
          p_commit                => FND_API.G_TRUE,
          p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
          p_entity_attribute_type => l_attr_type,
          p_entity_attribute_code => l_attr_code,
          p_rule_input_rec        => l_rule_input_rec,
          x_default_value         => l_default_val_num,
          x_rule_id               => l_default_rule_id, -- swai: 12.1.1 ER 7233924
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data
        );
        if (l_default_val_num is not null) then
            x_prod_txn_tbl(l_index).bill_to_account_id  := l_default_val_num;
            select party_id
            into x_prod_txn_tbl(l_index).bill_to_party_id
            from hz_cust_accounts
            where cust_account_id = l_default_val_num;

            -- swai: bug 6936769
            -- default account primary bill-to
            OPEN c_primary_account_address (x_prod_txn_tbl(l_index).bill_to_party_id,
                            x_prod_txn_tbl(l_index).bill_to_account_id,
                            x_prod_txn_tbl(l_index).organization_id,
                            'BILL_TO');
            FETCH c_primary_account_address INTO x_prod_txn_tbl(l_index).invoice_to_org_id;
            IF c_primary_account_address%ISOPEN THEN
                CLOSE c_primary_account_address;
            END IF;

            -- default account primary ship-to
            OPEN c_primary_account_address (x_prod_txn_tbl(l_index).bill_to_party_id,
                            x_prod_txn_tbl(l_index).bill_to_account_id,
                            x_prod_txn_tbl(l_index).organization_id,
                            'SHIP_TO');
            FETCH c_primary_account_address INTO x_prod_txn_tbl(l_index).ship_to_org_id;
            IF c_primary_account_address%ISOPEN THEN
                CLOSE c_primary_account_address;
            END IF;
            -- end swai: bug 6936769
        end if;

        ---------------------------------------
        l_index:= l_index + 1;
    end if;

    if (l_third_rma_txn_b_type_id is not null) then

        -- receive customer product txn line
        x_prod_txn_tbl(l_index).product_transaction_id      := FND_API.G_MISS_NUM;
        x_prod_txn_tbl(l_index).repair_line_id              := p_repair_line_id  ;
        x_prod_txn_tbl(l_index).estimate_detail_id          := FND_API.G_MISS_NUM;
        x_prod_txn_tbl(l_index).line_category_code          := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).txn_billing_type_id         := l_third_rma_txn_b_type_id;
        x_prod_txn_tbl(l_index).po_number                   := l_po_number;  -- swai bug fix 4535829

         x_prod_txn_tbl(l_index).action_code                 := 'CUST_PROD';
         x_prod_txn_tbl(l_index).action_type                 := 'RMA_THIRD_PTY'             ;

        --bug#3875036 Bug 8694111
	IF((l_enable_advanced_pricing ='Y') and (x_prod_txn_tbl(l_index).no_charge_flag ='N')) THEN
          x_prod_txn_tbl(l_index).after_warranty_cost	     := -l_selling_price;
	End If;

        -- x_prod_txn_tbl(l_index).serial_number            := l_serial_number   ;
        -- x_prod_txn_tbl(l_index).instance_id              := l_instance_id     ;
        x_prod_txn_tbl(l_index).source_serial_number        := p_serial_number   ;
        x_prod_txn_tbl(l_index).source_instance_id          := p_instance_id     ;
        x_prod_txn_tbl(l_index).non_source_serial_number    := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).non_source_instance_id      := FND_API.G_MISS_NUM;
        x_prod_txn_tbl(l_index).organization_id             := l_org_id          ;
        x_prod_txn_tbl(l_index).business_process_id         := l_bus_process_id ;
        x_prod_txn_tbl(l_index).order_number                := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).status                      := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).inventory_item_id           := l_inv_item_id     ;
        x_prod_txn_tbl(l_index).unit_of_measure_code        := l_unit_of_measure ;
        x_prod_txn_tbl(l_index).quantity                    := p_quantity        ;
        x_prod_txn_tbl(l_index).lot_number                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).price_list_id               := l_price_list_id   ;
        x_prod_txn_tbl(l_index).contract_id                 := l_contract_id     ;
     -- R12 contract changes
        x_prod_txn_tbl(l_index).contract_line_id            := l_contract_line_id    ;
        x_prod_txn_tbl(l_index).sub_inventory               := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).no_charge_flag              := csd_process_util.get_no_chg_flag(l_third_rma_txn_b_type_id) ;
        x_prod_txn_tbl(l_index).release_sales_order_flag    := 'N' ;
        x_prod_txn_tbl(l_index).ship_sales_order_flag       := 'N' ;

        -- auto process the RMA for the customer
        -- product txn line only
        -- Following line commented by vkjain to fix 3353445
        -- It adds support of 'Auto Enter and Book' RMA.
        -- IF x_prod_txn_tbl(l_index).action_code = 'CUST_PROD' and
        IF NVL(l_auto_process_rma, 'N') = 'Y' THEN
           x_prod_txn_tbl(l_index).process_txn_flag            := 'Y' ;
           x_prod_txn_tbl(l_index).interface_to_om_flag        := 'Y' ;
           x_prod_txn_tbl(l_index).book_sales_order_flag       := 'Y' ;
           -- bug fix for 4108369, Begin
           if(l_add_rma_to_id is null) THEN
             x_prod_txn_tbl(l_index).new_order_flag := 'Y';
           ELSE
             x_prod_txn_tbl(l_index).new_order_flag := 'N';
             x_prod_txn_tbl(l_index).add_to_order_flag := 'Y';
             x_prod_txn_tbl(l_index).add_to_order_id := l_add_rma_to_id;
           END IF;
           -- bug fix for 4108369, End
        ELSE
           x_prod_txn_tbl(l_index).process_txn_flag            := 'N' ;
           x_prod_txn_tbl(l_index).interface_to_om_flag        := 'N' ;
           x_prod_txn_tbl(l_index).book_sales_order_flag       := 'N' ;
        END IF;

        x_prod_txn_tbl(l_index).return_reason               := l_return_reason  ;
        -- x_prod_txn_tbl(l_index).return_by_date           := sysdate          ;
        /* Fixed for FP bug#5408047
          For RMA line if source return is required then only
          default the return by date. This date will be passed to
          charges in Installed_cp_return_by_date.
        */
        l_src_return_reqd      :='N';
        l_non_src_return_reqd  :='N';
        open c2( l_third_rma_txn_b_type_id );
        fetch c2 into l_src_return_reqd,l_non_src_return_reqd ;
        If (c2%ISOPEN) then
          Close c2;
        END IF;
        If l_src_return_reqd ='Y' then
          x_prod_txn_tbl(l_index).return_by_date              := sysdate+l_return_days;
        ELSE
           x_prod_txn_tbl(l_index).return_by_date              := NULL          ;
        END IF;

        x_prod_txn_tbl(l_index).revision                    := l_revision       ;
        x_prod_txn_tbl(l_index).last_update_date            := sysdate          ;
        x_prod_txn_tbl(l_index).creation_date               := sysdate          ;
        x_prod_txn_tbl(l_index).last_updated_by             := FND_GLOBAL.USER_ID;
        x_prod_txn_tbl(l_index).created_by                  := FND_GLOBAL.USER_ID;
        x_prod_txn_tbl(l_index).last_update_login           := FND_GLOBAL.USER_ID;
        x_prod_txn_tbl(l_index).attribute1                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute2                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute3                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute4                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute5                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute6                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute7                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute8                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute9                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute10                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute11                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute12                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute13                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute14                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).attribute15                 := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).context                     := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(l_index).prod_txn_status             := 'ENTERED';
        x_prod_txn_tbl(l_index).prod_txn_code               := 'PRE';
        x_prod_txn_tbl(l_index).project_id                  := l_project_id;
        x_prod_txn_tbl(l_index).task_id                     := l_task_id;
        x_prod_txn_tbl(l_index).unit_number                 := l_unit_number;

		l_attr_code := 'RMA_RCV_ORG';
        l_default_val_num := null;
        CSD_RULES_ENGINE_PVT.GET_DEFAULT_VALUE_FROM_RULE (
          p_api_version_number    => 1.0,
          p_init_msg_list         => FND_API.G_TRUE,
          p_commit                => FND_API.G_TRUE,
          p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
          p_entity_attribute_type => l_attr_type,
          p_entity_attribute_code => l_attr_code,
          p_rule_input_rec        => l_rule_input_rec,
          x_default_value         => l_default_val_num,
          x_rule_id               => l_default_rule_id, -- swai: 12.1.1 ER 7233924
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data
        );
        if (l_default_val_num is not null) then
            x_prod_txn_tbl(l_index).inventory_org_id  := l_default_val_num;
        else
            -- Inv_org Change, Vijay , 20/3/2006
            x_prod_txn_tbl(l_index).inventory_org_id  := l_inv_org_id;
        end if;

        ---------------------------------------
        --Bug fix 5494219 Begin
		l_attr_code := 'RMA_RCV_SUBINV';
        l_default_val_char := null;
        CSD_RULES_ENGINE_PVT.GET_DEFAULT_VALUE_FROM_RULE (
          p_api_version_number    => 1.0,
          p_init_msg_list         => FND_API.G_TRUE,
          p_commit                => FND_API.G_TRUE,
          p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
          p_entity_attribute_type => l_attr_type,
          p_entity_attribute_code => l_attr_code,
          p_rule_input_rec        => l_rule_input_rec,
          x_default_value         => l_default_val_char,
          x_rule_id               => l_default_rule_id, -- swai: 12.1.1 ER 7233924
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data
        );
        if (l_default_val_char is not null) then
            x_prod_txn_tbl(l_index).sub_inventory  := l_default_val_char;
        else
            x_prod_txn_tbl(l_index).sub_inventory  := l_sub_inv;
        end if;


		l_attr_code := 'VENDOR_ACCOUNT';
        l_default_val_num := null;
        CSD_RULES_ENGINE_PVT.GET_DEFAULT_VALUE_FROM_RULE (
          p_api_version_number    => 1.0,
          p_init_msg_list         => FND_API.G_TRUE,
          p_commit                => FND_API.G_TRUE,
          p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
          p_entity_attribute_type => l_attr_type,
          p_entity_attribute_code => l_attr_code,
          p_rule_input_rec        => l_rule_input_rec,
          x_default_value         => l_default_val_num,
          x_rule_id               => l_default_rule_id, -- swai: 12.1.1 ER 7233924
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data
        );
        if (l_default_val_num is not null) then
            x_prod_txn_tbl(l_index).bill_to_account_id  := l_default_val_num;
            select party_id
            into x_prod_txn_tbl(l_index).bill_to_party_id
            from hz_cust_accounts
            where cust_account_id = l_default_val_num;

            -- swai: bug 6936769
            -- default account primary bill-to
            OPEN c_primary_account_address (x_prod_txn_tbl(l_index).bill_to_party_id,
                            x_prod_txn_tbl(l_index).bill_to_account_id,
                            x_prod_txn_tbl(l_index).organization_id,
                            'BILL_TO');
            FETCH c_primary_account_address INTO x_prod_txn_tbl(l_index).invoice_to_org_id;
            IF c_primary_account_address%ISOPEN THEN
                CLOSE c_primary_account_address;
            END IF;

            -- default account primary ship-to
            OPEN c_primary_account_address (x_prod_txn_tbl(l_index).bill_to_party_id,
                            x_prod_txn_tbl(l_index).bill_to_account_id,
                            x_prod_txn_tbl(l_index).organization_id,
                            'SHIP_TO');
            FETCH c_primary_account_address INTO x_prod_txn_tbl(l_index).ship_to_org_id;
            IF c_primary_account_address%ISOPEN THEN
                CLOSE c_primary_account_address;
            END IF;
            -- end swai: bug 6936769
        end if;

    end if;

  end if;  --end l_third_party_flag


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.G_RET_STS_ERROR ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END build_prodtxn_tbl_int;

/**************************************
This procedure calls the internal api to build the product txn table.
***************************************/
PROCEDURE build_prod_txn_tbl
( p_repair_line_id     IN	NUMBER,
  p_create_thirdpty_line IN VARCHAR2 := fnd_api.g_false,
  x_prod_txn_tbl       OUT NOCOPY	csd_process_pvt.product_txn_tbl,
  x_return_status      OUT NOCOPY	VARCHAR2
 ) IS
  CURSOR cur_Srl_num_Dtls (p_rep_line_id IN NUMBER) IS
  SELECT
    quantity,
    customer_product_id,
    serial_number
  FROM csd_repairs
  where repair_line_id = p_rep_line_id;
 BEGIN

      FOR l_srl_num_rec in  cur_srl_num_dtls(p_Repair_line_id) LOOP
          build_prodtxn_tbl_int(p_Repair_line_id => p_repair_line_id,
                                p_quantity       => l_Srl_num_rec.quantity,
                                p_serial_number  => l_Srl_num_rec.serial_number,
                                p_instance_id    => l_srl_num_rec.customer_product_id,
								p_create_thirdpty_line => p_create_thirdpty_line,
                                x_prod_txn_tbl   => x_prod_txn_tbl,
                                x_return_status  => x_return_status);
      END LOOP;


 END build_prod_txn_tbl;



FUNCTION validate_rep_line_id
( p_repair_line_id  IN	NUMBER
 ) RETURN BOOLEAN

 IS

l_dummy VARCHAR2(1);

BEGIN

 select 'X'
 into l_dummy
 from csd_repairs
 where repair_line_id = p_repair_line_id;
--bug#6681781, this is not valid validation for repair line id, don't need the last condition
-- and   ((date_closed is null) or (trunc(date_closed) >= trunc(sysdate)));

 RETURN TRUE;

EXCEPTION
When NO_DATA_FOUND then
    FND_MESSAGE.SET_NAME('CSD','CSD_API_INV_REP_LINE_ID');
    FND_MESSAGE.SET_TOKEN('REPAIR_LINE_ID',p_repair_line_id);
    FND_MSG_PUB.Add;
    RETURN FALSE;
END Validate_rep_line_id;

FUNCTION validate_estimate_id
( p_estimate_id  IN	NUMBER
 ) RETURN BOOLEAN

 IS

l_dummy VARCHAR2(1);

BEGIN

 select 'X'
 into l_dummy
 from csd_repair_estimate
 where repair_estimate_id = p_estimate_id;

 RETURN TRUE;

EXCEPTION
When NO_DATA_FOUND then
    FND_MESSAGE.SET_NAME('CSD','CSD_INV_ESTIMATE_ID');
    FND_MESSAGE.SET_TOKEN('REPAIR_ESTIMATE_ID',p_estimate_id);
    FND_MSG_PUB.Add;
    RETURN FALSE;
END Validate_estimate_id;

FUNCTION validate_estimate_line_id
( p_estimate_line_id  IN	NUMBER
 ) RETURN BOOLEAN

 IS

l_dummy VARCHAR2(1);

BEGIN

 select 'X'
 into l_dummy
 from csd_repair_estimate_lines
 where repair_estimate_line_id = p_estimate_line_id;

 RETURN TRUE;

EXCEPTION
When NO_DATA_FOUND then
    FND_MESSAGE.SET_NAME('CSD','CSD_INV_ESTIMATE_ID');
    FND_MESSAGE.SET_TOKEN('REPAIR_ESTIMATE_LINE_ID',p_estimate_line_id);
    FND_MSG_PUB.Add;
    RETURN FALSE;
END Validate_estimate_line_id;

FUNCTION Validate_action_type
( p_action_type     IN VARCHAR2
 ) RETURN BOOLEAN
 IS
  l_dummy VARCHAR2(1);
BEGIN
 select 'X'
 into l_dummy
 from  fnd_lookups
 where lookup_type = 'CSD_PROD_ACTION_TYPE'
  and  lookup_code = p_action_type;
 RETURN TRUE;
EXCEPTION
When NO_DATA_FOUND then
    FND_MESSAGE.SET_NAME('CSD','CSD_API_INV_ACTION_TYPE');
    FND_MESSAGE.SET_TOKEN('ACTION_TYPE',p_action_type);
    FND_MSG_PUB.Add;
    RETURN FALSE;
END Validate_action_type;


FUNCTION Validate_action_code
( p_action_code     IN VARCHAR2
 ) RETURN BOOLEAN
 IS
 l_dummy VARCHAR2(1);
BEGIN
 select 'X'
 into l_dummy
 from  fnd_lookups
 where lookup_type = 'CSD_PRODUCT_ACTION_CODE'
  and  lookup_code = p_action_code;
 RETURN TRUE;
EXCEPTION
When NO_DATA_FOUND then
    FND_MESSAGE.SET_NAME('CSD','CSD_API_INV_ACTION_CODE');
    FND_MESSAGE.SET_TOKEN('ACTION_CODE',p_action_code);
    FND_MSG_PUB.Add;
    RETURN FALSE;
END Validate_action_code;

--Sangita changes - shirkol
FUNCTION get_inv_org_id RETURN NUMBER
 IS
   l_inv_org_id   NUMBER;
   BEGIN

	l_inv_org_id := cs_std.get_item_valdn_orgzn_id;

	  RETURN l_inv_org_id;

	  END;

--sangita Chanegs shirkol
/*

FUNCTION get_org_id
( p_repair_line_id  IN	NUMBER
 ) RETURN NUMBER
 IS
  l_org_id NUMBER;
BEGIN

 select b.org_id
 into l_org_id
 from csd_repairs a,
      cs_incidents_all_b b
 where a.incident_id    = b.incident_id
  and  a.repair_line_id = p_repair_line_id;

 RETURN l_org_id;
EXCEPTION
When NO_DATA_FOUND then
    FND_MESSAGE.SET_NAME('CSD','CSD_API_INV_REP_LINE_ID');
    FND_MESSAGE.SET_TOKEN('REPAIR_LINE_ID',p_repair_line_id);
    FND_MSG_PUB.Add;
    RETURN -1;
END get_org_id;
*/

--sangita chanegs shirkol
FUNCTION get_org_id
( p_incident_id  IN NUMBER
 ) RETURN NUMBER
  IS

   l_org_id         NUMBER;
    l_return_status  VARCHAR2(1);
	l_msg_count      NUMBER;
	 l_msg_data       VARCHAR2(2000);
	  l_profile        VARCHAR2(3);

	  BEGIN

	   IF Is_MultiOrg_Enabled THEN

		 CS_MultiOrg_Pub.Get_OrgId(  -- swai change to use pub instead of pvt
			 p_api_version   => 1.0, -- swai change to version 1.0
			 p_init_msg_list => 'F',
             p_commit           => FND_API.G_FALSE,  -- swai added
             p_validation_level => null,             -- swai added
			 x_return_status => l_return_status,
 			 x_msg_count     => l_msg_count,
			 x_msg_data      => l_msg_data,
             p_incident_id   => p_incident_id,
			 x_org_id        => l_org_id,
			 x_profile       => l_profile);

			if( l_return_status <> csd_process_util.g_ret_sts_success) then
				csd_gen_utility_pvt.add('Error in deriving the Org id ');
		   end if;

			 ELSE
			 ------------------------------------------------------
			  -- If not Multiorg derive org from MO operating Unit
			------------------------------------------------------

				  FND_PROFILE.Get('ORG_ID', l_org_id);

			   END IF;
			 RETURN l_org_id;

			 EXCEPTION
			   When NO_DATA_FOUND then

				 FND_MESSAGE.SET_NAME('CSD','CSD_INVALID_INCIDENT_ID');
				 FND_MSG_PUB.Add;
	    			RETURN -1;
 END get_org_id;


FUNCTION get_estimate
(
  p_repair_line_id IN	NUMBER,
  p_code           IN    VARCHAR2
 ) RETURN NUMBER

 IS

  l_amount NUMBER := 0;

BEGIN

IF p_code = 'M' then

Select
     sum(ced.after_warranty_cost)
into l_amount
from csd_repair_estimate cre,
	csd_repair_estimate_lines crel,
	cs_estimate_details ced,
	cs_txn_billing_types ctbt
where cre.repair_estimate_id = crel.repair_estimate_id
  and crel.estimate_detail_id = ced.estimate_detail_id
  and ced.txn_billing_type_id = ctbt.txn_billing_type_id
  and cre.repair_line_id     = p_repair_line_id
  and ctbt.billing_type      = 'M';

ELSIF p_code = 'L' then

Select
     sum(ced.after_warranty_cost)
into l_amount
from csd_repair_estimate cre,
	csd_repair_estimate_lines crel,
	cs_estimate_details ced,
	cs_txn_billing_types ctbt
where cre.repair_estimate_id = crel.repair_estimate_id
  and crel.estimate_detail_id = ced.estimate_detail_id
  and ced.txn_billing_type_id = ctbt.txn_billing_type_id
  and cre.repair_line_id     = p_repair_line_id
  and ctbt.billing_type      = 'L';

ELSIF p_code = 'E' then

Select
     sum(ced.after_warranty_cost)
into l_amount
from csd_repair_estimate cre,
	csd_repair_estimate_lines crel,
	cs_estimate_details ced,
	cs_txn_billing_types ctbt
where cre.repair_estimate_id = crel.repair_estimate_id
  and crel.estimate_detail_id = ced.estimate_detail_id
  and ced.txn_billing_type_id = ctbt.txn_billing_type_id
  and cre.repair_line_id     = p_repair_line_id
  and ctbt.billing_type      = 'E';

ELSIF p_code = 'T' then

Select
     sum(ced.after_warranty_cost)
into l_amount
from csd_repair_estimate cre,
	csd_repair_estimate_lines crel,
	cs_estimate_details ced
where cre.repair_estimate_id = crel.repair_estimate_id
  and crel.estimate_detail_id = ced.estimate_detail_id
  and cre.repair_line_id     = p_repair_line_id ;

END IF;

 RETURN l_amount;

EXCEPTION
 When NO_DATA_FOUND then
    RETURN l_amount;
END get_estimate;

FUNCTION get_bus_process
(
  p_repair_line_id IN	NUMBER
 ) RETURN NUMBER

 IS
  l_bus_process_id NUMBER := null;

BEGIN

-- Forward port bug# 2756313
/* select b.business_process_id
 into l_bus_process_id
 from cs_incidents_all_b a,
      cs_incident_types_b b
 where a.incident_type_id = b.incident_type_id
  and  a.incident_id      = p_incident_id;
*/

 select t.business_process_id
 into l_bus_process_id
 from csd_repairs r,
      csd_repair_types_b t
 where r.repair_line_id = p_repair_line_id
 and   r.repair_type_id = t.repair_type_id;

 IF l_bus_process_id is null then
    raise no_data_found ;
 else
  RETURN l_bus_process_id;
 END IF;

EXCEPTION
When NO_DATA_FOUND then
    FND_MESSAGE.SET_NAME('CSD','CSD_API_INV_BUS_PROCESS');
    FND_MESSAGE.SET_TOKEN('REPAIR_LINE_ID',p_repair_line_id);
    FND_MSG_PUB.Add;
    RETURN -1;
END get_bus_process;

PROCEDURE Convert_to_Chg_rec
(
  p_prod_txn_rec       IN	CSD_PROCESS_PVT.PRODUCT_TXN_REC,
  x_charges_rec        OUT NOCOPY	CS_CHARGE_DETAILS_PUB.CHARGES_REC_TYPE,
  x_return_status      OUT NOCOPY	VARCHAR2
) IS

  /*Fixed for FP bug#5408047*/
  cursor c2(p_txn_billing_type_id NUMBER) is
  select SRC_RETURN_REQD
        ,NON_SRC_RETURN_REQD
  from csi_ib_txn_types a,
       cs_txn_billing_types b
  where a.cs_transaction_type_id = b.transaction_type_id
  and  b.txn_billing_type_id = p_txn_billing_type_id;

  l_src_return_reqd           varchar2(1);  /*Fixed for FP bug#5408047*/
  l_non_src_return_reqd       varchar2(1);  /*Fixed for FP bug#5408047*/

BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS;

 x_charges_rec.estimate_detail_id          := p_prod_txn_rec.estimate_detail_id;
 x_charges_rec.incident_id                 := p_prod_txn_rec.incident_id;
 x_charges_rec.original_source_id          := p_prod_txn_rec.repair_line_id;
 x_charges_rec.original_source_code        := 'DR' ;
 x_charges_rec.source_id                   := p_prod_txn_rec.repair_line_id;
 x_charges_rec.source_code                 := 'DR' ;
 x_charges_rec.line_type_id                := p_prod_txn_rec.line_type_id;
 x_charges_rec.txn_billing_type_id         := p_prod_txn_rec.txn_billing_type_id;
 x_charges_rec.business_process_id         := p_prod_txn_rec.business_process_id;
 x_charges_rec.inventory_item_id_in        := p_prod_txn_rec.inventory_item_id;
 x_charges_rec.price_list_id               := p_prod_txn_rec.price_list_id;
 x_charges_rec.currency_code               := p_prod_txn_rec.currency_code;
 x_charges_rec.quantity_required           := p_prod_txn_rec.quantity;
 x_charges_rec.unit_of_measure_code        := p_prod_txn_rec.unit_of_measure_code;
 -- swai: 12.0.2 3rd party logistics
 -- instance and reference number should be set to the source id for
 -- RMA and RMA_THIRD_PTY only.  SHIP_THIRD_PTY will be handled like SHIP,
 -- but non-source will always be blank for SHIP_THIRD_PTY.
 If p_prod_txn_rec.action_type in ('SHIP','WALK_IN_ISSUE', 'SHIP_THIRD_PTY') Then
    x_charges_rec.customer_product_id := p_prod_txn_rec.non_source_instance_id;
    x_charges_rec.reference_number    := p_prod_txn_rec.non_source_instance_number;
 elsif p_prod_txn_rec.action_type in ('RMA','RMA_THIRD_PTY') Then
    x_charges_rec.customer_product_id := p_prod_txn_rec.source_instance_id;
    x_charges_rec.reference_number   := p_prod_txn_rec.source_instance_number;
 end if;
 x_charges_rec.interface_to_oe_flag        := p_prod_txn_rec.interface_to_om_flag;
 x_charges_rec.no_charge_flag              := p_prod_txn_rec.no_charge_flag;
 x_charges_rec.after_warranty_cost         := p_prod_txn_rec.after_warranty_cost;
 x_charges_rec.add_to_order_flag           := p_prod_txn_rec.add_to_order_flag;
 x_charges_rec.rollup_flag                 := 'N';
 x_charges_rec.line_category_code          := p_prod_txn_rec.line_category_code;

 /*Fixed for FP bug#5408047
   assign the return by date value to appropriate field
 */
 l_src_return_reqd     :='N';
 l_non_src_return_reqd :='N';
 open c2( p_prod_txn_rec.txn_billing_type_id );
 fetch c2 into l_src_return_reqd,l_non_src_return_reqd ;
 If (c2%ISOPEN) then
   Close c2;
 End if;

 -- Modified for the bug 3523019
 If p_prod_txn_rec.line_category_code = 'RETURN' THEN
    x_charges_rec.installed_cp_return_by_date := p_prod_txn_rec.return_by_date;
 Else

   /*Fixed for FP bug#5408047
     assign the return by date value to appropriate field
   */
   If l_SRC_RETURN_REQD ='Y' then
     x_charges_rec.new_cp_return_by_date :=  p_prod_txn_rec.return_by_date;
   END IF;

   If l_NON_SRC_RETURN_REQD ='Y' then
     x_charges_rec.installed_cp_return_by_date := p_prod_txn_rec.return_by_date;
   END IF;

   If l_SRC_RETURN_REQD ='N' and l_NON_SRC_RETURN_REQD= 'N' then
     IF  p_prod_txn_rec.non_source_instance_id is not null then
       x_charges_rec.installed_cp_return_by_date := p_prod_txn_rec.return_by_date;
     ELSE
       x_charges_rec.new_cp_return_by_date :=  p_prod_txn_rec.return_by_date;
     END IF;
   END IF;

 End If;

 x_charges_rec.return_reason_code          := p_prod_txn_rec.return_reason;
 x_charges_rec.contract_id                 := p_prod_txn_rec.contract_id;
 --R12 contracts changes..
 x_charges_rec.contract_line_id            := p_prod_txn_rec.contract_line_id;
 x_charges_rec.invoice_to_org_id           := p_prod_txn_rec.invoice_to_org_id;
 x_charges_rec.ship_to_org_id              := p_prod_txn_rec.ship_to_org_id;
 x_charges_rec.item_revision			   := p_prod_txn_rec.revision;
 x_charges_rec.serial_number               := p_prod_txn_rec.source_serial_number;
 x_charges_rec.original_source_number      := to_char(p_prod_txn_rec.repair_line_id);
 x_charges_rec.source_number               := to_char(p_prod_txn_rec.repair_line_id);
 x_charges_rec.purchase_order_num          := p_prod_txn_rec.po_number;
 x_charges_rec.inventory_item_id_out       := FND_API.G_MISS_NUM;
 x_charges_rec.serial_number_out           := FND_API.G_MISS_CHAR;
 x_charges_rec.order_header_id             := p_prod_txn_rec.order_header_id;
 x_charges_rec.order_line_id               := FND_API.G_MISS_NUM;
 x_charges_rec.original_system_reference   := FND_API.G_MISS_CHAR;
 x_charges_rec.selling_price               := FND_API.G_MISS_NUM;
 x_charges_rec.transaction_type_id         := p_prod_txn_rec.transaction_type_id;
 --x_charges_rec.organization_id             := FND_API.G_MISS_NUM;
 --x_to_charges_rec.customer_id              := FND_API.G_MISS_NUM;
 -- Inv_org Change, Vijay , 20/3/2006
 x_charges_rec.transaction_inventory_org         := p_prod_txn_rec.inventory_org_id;

 -- swai: bug 5931926 - 3rd party logistics for 12.0.2
 x_charges_rec.bill_to_party_id            := p_prod_txn_rec.bill_to_party_id;
 x_charges_rec.bill_to_account_id          := p_prod_txn_rec.bill_to_account_id;
 x_charges_rec.ship_to_party_id            := p_prod_txn_rec.ship_to_party_id;
 x_charges_rec.ship_to_account_id          := p_prod_txn_rec.ship_to_account_id;

 -- bug#8416835, FP of bug#8288715 subhat.
 -- the ship to contact id and bill to contact id is not passed to OM when these
 -- values are captured on SR.
 if p_prod_txn_rec.action_type <> 'SHIP_THIRD_PTY' and
     p_prod_txn_rec.action_type <> 'RMA_THIRD_PTY' then
      begin
          select decode(bill_to_site_id, p_prod_txn_rec.invoice_to_org_id,bill_to_contact_id),
                  decode(ship_to_site_id,p_prod_txn_rec.ship_to_org_id,ship_to_contact_id)
          into
               x_charges_rec.bill_to_contact_id,
               x_charges_rec.ship_to_contact_id
          from   cs_incidents_all_b
          where  incident_id = decode(p_prod_txn_rec.incident_id,FND_API.G_MISS_NUM,
                                   (select incident_id from csd_repairs where repair_line_id = p_prod_txn_rec.repair_line_id),
                                   p_prod_txn_rec.incident_id );
      exception
          when no_data_found then
               null;
      end;
  end if;
  -- end bug#8416835, subhat.


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.G_RET_STS_ERROR ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END Convert_to_Chg_rec;

PROCEDURE get_line_type
( p_txn_billing_type_id IN	NUMBER,
  p_org_id              IN  NUMBER,
  x_line_type_id        OUT NOCOPY	NUMBER,
  x_line_category_code  OUT NOCOPY VARCHAR2,
  x_return_status       OUT NOCOPY	VARCHAR2
 ) IS

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

select b.line_type_id,
       c.line_order_category_code
 into  x_line_type_id,
       x_line_category_code
from cs_txn_billing_types a,
     CS_TXN_BILLING_OETXN_ALL b,
     cs_transaction_types_vl c
where a.txn_billing_type_id = b.txn_billing_type_id
 and  a.transaction_type_id = c.transaction_type_id
 and  a.txn_billing_type_id = p_txn_billing_type_id
 and  b.org_id              = p_org_id;

EXCEPTION
When NO_DATA_FOUND then
    FND_MESSAGE.SET_NAME('CSD','CSD_API_INV_TXN_BILL_TYPE_ID');
    FND_MESSAGE.SET_TOKEN('TXN_BILLING_TYPE_ID',p_txn_billing_type_id);
    FND_MSG_PUB.Add;
    x_return_status := FND_API.G_RET_STS_ERROR ;
When OTHERS then
    FND_MESSAGE.SET_NAME('CSD','CSD_API_INV_TXN_BILL_TYPE_ID');
    FND_MESSAGE.SET_TOKEN('TXN_BILLING_TYPE_ID',p_txn_billing_type_id);
    FND_MSG_PUB.Add;
    x_return_status := FND_API.G_RET_STS_ERROR ;
END get_line_type;


FUNCTION Get_group_rejected_quantity
(
  p_repair_group_id IN Number
 ) RETURN NUMBER
IS

l_rejected_quantity  Number := 0;

BEGIN

  Select count(*)
  into l_rejected_quantity
  from csd_repairs
  where upper(approval_status) = 'R'
  and repair_group_id = p_repair_group_id;

  RETURN l_rejected_quantity;

EXCEPTION
WHEN OTHERS THEN
 null;
END Get_group_rejected_quantity;

FUNCTION Validate_prod_txn_id
(
  p_prod_txn_id	  IN	NUMBER
 ) RETURN BOOLEAN
 IS

l_dummy   VARCHAR2(1);

BEGIN

 select 'X'
 into l_dummy
 from csd_product_transactions
 where product_transaction_id = p_prod_txn_id;
RETURN TRUE;
EXCEPTION
When NO_DATA_FOUND then
    FND_MESSAGE.SET_NAME('CSD','CSD_INV_PROD_TXN_ID');
    FND_MESSAGE.SET_TOKEN('PRODUCT_TXN_ID',p_prod_txn_id);
    FND_MSG_PUB.Add;
    RETURN FALSE;
END Validate_prod_txn_id;

PROCEDURE Validate_wip_task
( p_prod_txn_id    IN	NUMBER,
  x_return_status  OUT NOCOPY	VARCHAR2
 )IS

l_repair_mode     varchar2(30) := '';
l_repair_type_id  number := null;
l_repair_line_id  number := null;
l_qty_completed   number := null;
l_prod_txn_qty    number := null;
l_dummy           varchar2(1) := '';
l_count           number;

CURSOR cur_repln_dtls IS
SELECT
  a.repair_mode,
  a.repair_type_id,
  b.repair_line_id,
  c.quantity_required
FROM csd_repairs a,
     csd_product_transactions b,
     cs_estimate_details c
where a.repair_line_id = b.repair_line_id
 and  b.estimate_detail_id = c.estimate_detail_id
 and  b.product_transaction_id = p_prod_txn_id;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NVL(p_prod_txn_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN

    IF cur_repln_dtls%isopen then
      CLOSE cur_repln_dtls;
    END IF;
/**********
    OPEN  cur_repln_dtls;
    FETCH cur_repln_dtls INTO l_repair_mode,
                                l_repair_type_id,
                                l_repair_line_id,
                                l_prod_txn_qty;
    IF cur_repln_dtls%notfound then
*********/
	BEGIN
	SELECT a.repair_mode,
	       a.repair_type_id,
  		   b.repair_line_id,
           c.quantity_required
	INTO l_repair_mode,
	     l_repair_type_id,
		 l_repair_line_id,
		 l_prod_txn_qty
	FROM csd_repairs a,
     csd_product_transactions b,
     cs_estimate_details c
    where a.repair_line_id = b.repair_line_id
       and  b.estimate_detail_id = c.estimate_detail_id
       and  b.product_transaction_id = p_prod_txn_id ;

	 EXCEPTION
	   WHEN NO_DATA_FOUND THEN
	      FND_MESSAGE.SET_NAME('CSD','CSD_API_INV2_PROD_TXN_ID');
	      FND_MESSAGE.SET_TOKEN('PRODUCT_TXN_ID',p_prod_txn_id);
	      FND_MSG_PUB.ADD;
	      RAISE FND_API.G_EXC_ERROR;
	END;
/*
    END IF;
*/

    IF cur_repln_dtls%isopen then
      CLOSE cur_repln_dtls;
    END IF;

  END IF;

IF (g_debug > 0 ) THEN
  csd_gen_utility_pvt.add('l_repair_line_id ='||l_repair_line_id);
END IF;

IF (g_debug > 0 ) THEN
  csd_gen_utility_pvt.add('l_repair_mode ='||l_repair_mode);
END IF;


   IF l_repair_mode = 'WIP' then

    BEGIN
     select sum(quantity_completed)
      into  l_qty_completed
      from csd_repair_job_xref
     where repair_line_id = l_repair_line_id;
    EXCEPTION
    WHEN OTHERS THEN
      RAISE FND_API.G_EXC_ERROR;
IF (g_debug > 0 ) THEN
      csd_gen_utility_pvt.add('repair line Id not found');
END IF;

    END;

IF (g_debug > 0 ) THEN
   csd_gen_utility_pvt.add('l_qty_completed ='||l_qty_completed);
END IF;

IF (g_debug > 0 ) THEN
   csd_gen_utility_pvt.add('l_prod_txn_qty  ='||l_prod_txn_qty);
END IF;

    /************* travi comment on 030703 for Bug # 2830828 **************
    If nvl(l_qty_completed,0) < l_prod_txn_qty then
      FND_MESSAGE.SET_NAME('CSD','CSD_API_PROCESS_NOT_ALLOWED');
      FND_MESSAGE.SET_TOKEN('QTY_COMPLETED',l_qty_completed);
      FND_MSG_PUB.ADD;
      IF (g_debug > 0 ) THEN
            csd_gen_utility_pvt.ADD('Prod txn qty is more than qty completed :'||l_qty_completed);
      END IF;

      RAISE FND_API.G_EXC_ERROR;
    end if;
    **********************************************************************/

  ELSIF l_repair_mode = 'TASK' then

      Select count(*)
       into l_count
      from jtf_tasks_vl
      where source_object_type_code = 'DR'
       and  source_object_id = l_repair_line_id
       and  task_status_id not in (7,8,9,11);

IF (g_debug > 0 ) THEN
     csd_gen_utility_pvt.ADD('l_count= '||l_count);
END IF;

    IF l_count > 0 then
      FND_MESSAGE.SET_NAME('CSD','CSD_API_TASK_NOT_COMPLETE');
      FND_MESSAGE.SET_TOKEN('REPAIR_LINE_ID',l_repair_line_id);
      FND_MSG_PUB.ADD;

      IF (g_debug > 0 ) THEN
        csd_gen_utility_pvt.ADD('One or more of the tasks for repair line : '||l_repair_line_id||' :is not completed');
      END IF;
    End If;

  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.G_RET_STS_ERROR ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END Validate_wip_task;


PROCEDURE Validate_quantity
(
  p_action_type	   IN	VARCHAR2,
  p_repair_line_id IN   VARCHAR2,
  p_prod_txn_qty   IN   NUMBER,
  x_return_status  OUT NOCOPY	VARCHAR2
 ) IS

CURSOR qty_by_type  IS
SELECT
  abs(sum(b.quantity_required))
FROM csd_product_transactions a,
     cs_estimate_details b
where a.estimate_detail_id = b.estimate_detail_id
 and  a.action_code    = 'CUST_PROD'
 and a.prod_txn_status <> 'CANCELLED'
 and  a.action_type    = p_action_type
 and  a.repair_line_id = p_repair_line_id;

CURSOR repair_qty IS
SELECT
      quantity
FROM  csd_repairs
WHERE repair_line_id = p_repair_line_id;

l_qty_by_type NUMBER := NULL;
l_repair_qty  NUMBER := NULL;
l_prod_txn_qty NUMBER := NULL;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN qty_by_type ;
  FETCH qty_by_type into l_qty_by_type;
  CLOSE qty_by_type;

  OPEN repair_qty;
  FETCH repair_qty into l_repair_qty;
  CLOSE repair_qty;

  IF NVL(p_prod_txn_qty,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN
     l_prod_txn_qty := NULL;
  Else
     l_prod_txn_qty := p_prod_txn_qty;
  END IF;

IF (g_debug > 0 ) THEN
  csd_gen_utility_pvt.add('l_qty_by_type  ='||l_qty_by_type);
END IF;

IF (g_debug > 0 ) THEN
  csd_gen_utility_pvt.add('l_prod_txn_qty ='||l_prod_txn_qty);
END IF;

IF (g_debug > 0 ) THEN
  csd_gen_utility_pvt.add('l_repair_qty   ='||l_repair_qty);
END IF;


  IF (NVL(l_qty_by_type,0) + NVL(l_prod_txn_qty,0)) > NVL(l_repair_qty,0) THEN
      FND_MESSAGE.SET_NAME('CSD','CSD_API_INV_QUANTITY');
      FND_MESSAGE.SET_TOKEN('REPAIR_LINE_ID',p_repair_line_id);
      FND_MSG_PUB.ADD;
IF (g_debug > 0 ) THEN
      csd_gen_utility_pvt.ADD('Prod txn qty is more than qty in repair Line :'||p_repair_line_id);
END IF;

      RAISE FND_API.G_EXC_ERROR;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.G_RET_STS_ERROR ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END Validate_quantity;


FUNCTION Is_item_serialized
(
  p_inv_item_id	  IN	NUMBER
 ) RETURN BOOLEAN
 IS

 l_serial_code   NUMBER := null;
BEGIN

 select serial_number_control_code
 into l_serial_code
 from mtl_system_items
 where inventory_item_id = p_inv_item_id
 and   organization_id   = cs_std.get_item_valdn_orgzn_id;

 IF l_serial_code = 1 then
   RETURN FALSE;
 Else
   RETURN TRUE;
 End if;
EXCEPTION
When NO_DATA_FOUND then
    FND_MESSAGE.SET_NAME('CSD','CSD_API_INV_ITEM_ID');
    FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID',p_inv_item_id);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
END Is_item_serialized;

FUNCTION g_miss_num RETURN number
IS
BEGIN
  RETURN fnd_api.g_miss_num;
END g_miss_num;

FUNCTION g_miss_char RETURN varchar2
IS
BEGIN
  RETURN fnd_api.g_miss_char ;
END g_miss_char;

FUNCTION g_miss_date RETURN date
IS
BEGIN
  RETURN fnd_api.g_miss_date ;
END g_miss_date ;

FUNCTION g_valid_level(p_level varchar2) RETURN number
IS
BEGIN
  IF p_level = 'NONE' then
    RETURN fnd_api.g_valid_level_none;
  ELSIF p_level = 'FULL' then
    RETURN fnd_api.g_valid_level_full;
  ELSE
    fnd_msg_pub.add_exc_msg(
      p_pkg_name       => G_PKG_NAME ,
      p_procedure_name => 'G_VALID_LEVEL',
      p_error_text     => 'Unrecognized Value: '||p_level);

    RAISE fnd_api.g_exc_unexpected_error;
  END IF;
END g_valid_level ;

FUNCTION g_boolean(p_FLAG varchar2) RETURN varchar2
IS
BEGIN
  if p_flag = 'TRUE' then
    return FND_API.G_TRUE ;
  elsif p_flag = 'FALSE' then
    return FND_API.G_FALSE ;
  else
    fnd_msg_pub.add_exc_msg(
      p_pkg_name       => G_PKG_NAME,
      p_procedure_name => 'G_BOOLEAN',
      p_error_text     => 'Unrecognized Value: '||p_flag);
    RAISE fnd_api.g_exc_unexpected_error;
  END if;
END g_boolean;

FUNCTION get_error_constant(err_msg varchar2) RETURN varchar2
IS
BEGIN

  IF err_msg = 'G_RET_STS_ERROR' THEN
     RETURN fnd_api.g_ret_sts_error;
  ELSIF err_msg = 'G_RET_STS_UNEXP_ERROR' THEN
     RETURN fnd_api.g_ret_sts_unexp_error;
  ELSIF err_msg = 'G_RET_STS_SUCCESS' THEN
     RETURN fnd_api.g_ret_sts_success;
  END IF;

END get_error_constant;

FUNCTION ui_prod_txn_rec RETURN csd_process_pvt.product_txn_rec
IS
  l_prod_txn_rec csd_process_pvt.product_txn_rec;
BEGIN
  RETURN l_prod_txn_rec;
END ui_prod_txn_rec;

FUNCTION sr_rec RETURN csd_process_pvt.service_request_rec
IS
  l_sr_rec csd_process_pvt.service_request_rec;
BEGIN
  RETURN l_sr_rec;
END sr_rec;

FUNCTION repair_order_rec RETURN csd_repairs_pub.repln_rec_type
IS
  l_ro_rec csd_repairs_pub.repln_rec_type;
BEGIN
  RETURN l_ro_rec;
END repair_order_rec;

FUNCTION ui_estimate_rec RETURN csd_repair_estimate_pvt.repair_estimate_rec
IS
  l_est_rec csd_repair_estimate_pvt.repair_estimate_rec;
BEGIN
  RETURN l_est_rec;
END ui_estimate_rec ;

FUNCTION ui_job_parameter_rec RETURN csd_group_job_pvt.job_parameter_rec
IS
  l_job_param_rec csd_group_job_pvt.job_parameter_rec;
BEGIN
  RETURN l_job_param_rec;
END ui_job_parameter_rec ;


FUNCTION ui_estimate_line_rec RETURN csd_repair_estimate_pvt.repair_estimate_line_rec
IS
  l_est_line_rec csd_repair_estimate_pvt.repair_estimate_line_rec;
BEGIN
  RETURN l_est_line_rec;
END ui_estimate_line_rec ;

FUNCTION ui_pricing_attr_rec RETURN csd_process_util.pricing_attr_rec
IS
  l_pric_att_rec csd_process_util.pricing_attr_rec ;
BEGIN
  RETURN l_pric_att_rec;
END ui_pricing_attr_rec ;


FUNCTION ui_instance_rec RETURN csi_datastructures_pub.instance_rec
IS
  l_inst_rec csi_datastructures_pub.instance_rec;
BEGIN
  RETURN l_inst_rec;
END ui_instance_rec ;

FUNCTION ui_party_tbl RETURN csi_datastructures_pub.party_tbl
IS
  l_pty_tbl csi_datastructures_pub.party_tbl;
BEGIN
  RETURN l_pty_tbl;
END ui_party_tbl ;

FUNCTION ui_party_account_tbl RETURN csi_datastructures_pub.party_account_tbl
IS
  l_pty_acct_tbl csi_datastructures_pub.party_account_tbl;
BEGIN
  RETURN l_pty_acct_tbl;
END ui_party_account_tbl ;

FUNCTION ui_organization_units_tbl RETURN csi_datastructures_pub.organization_units_tbl
IS
  l_org_tbl csi_datastructures_pub.organization_units_tbl;
BEGIN
  RETURN l_org_tbl;
END ui_organization_units_tbl ;

FUNCTION ui_extend_attrib_values_tbl RETURN csi_datastructures_pub.extend_attrib_values_tbl
IS
  l_eav_tbl csi_datastructures_pub.extend_attrib_values_tbl;
BEGIN
  RETURN l_eav_tbl;
END ui_extend_attrib_values_tbl ;

FUNCTION ui_pricing_attribs_tbl RETURN csi_datastructures_pub.pricing_attribs_tbl
IS
  l_pric_att_tbl csi_datastructures_pub.pricing_attribs_tbl;
BEGIN
  RETURN l_pric_att_tbl;
END ui_pricing_attribs_tbl ;

FUNCTION ui_instance_asset_tbl RETURN csi_datastructures_pub.instance_asset_tbl
IS
  l_ins_ass_tbl csi_datastructures_pub.instance_asset_tbl;
BEGIN
  RETURN l_ins_ass_tbl;
END ui_instance_asset_tbl ;

FUNCTION ui_transaction_rec RETURN csi_datastructures_pub.transaction_rec
IS
  l_txn_rec csi_datastructures_pub.transaction_rec;
BEGIN
  RETURN l_txn_rec;
END ui_transaction_rec ;

FUNCTION ui_actual_lines_rec RETURN CSD_REPAIR_ACTUAL_LINES_PVT.CSD_ACTUAL_LINES_REC_TYPE
IS
  l_act_lines_rec CSD_REPAIR_ACTUAL_LINES_PVT.CSD_ACTUAL_LINES_REC_TYPE;
  BEGIN
    RETURN l_act_lines_rec;
END ui_actual_lines_rec;


FUNCTION ui_charge_lines_rec RETURN CS_CHARGE_DETAILS_PUB.CHARGES_REC_TYPE
IS
  l_charge_lines_rec CS_CHARGE_DETAILS_PUB.CHARGES_REC_TYPE;
BEGIN
    RETURN l_charge_lines_rec;
END ui_charge_lines_rec;


FUNCTION ui_actuals_rec RETURN CSD_REPAIR_ACTUALS_PVT.CSD_REPAIR_ACTUALS_REC_TYPE
IS
  l_actuals_rec CSD_REPAIR_ACTUALS_PVT.CSD_REPAIR_ACTUALS_REC_TYPE;
BEGIN
    RETURN l_actuals_rec;
END ui_actuals_rec;

----------- travi changes----------

PROCEDURE COMMIT_ROLLBACK(
	    COM_ROLL       IN   VARCHAR2 := 'ROLL')
IS
BEGIN
   if ( COM_ROLL = 'COMMIT' ) then
	 commit;
   else
	 rollback;
   end if;
END;

FUNCTION G_RET_STS_SUCCESS RETURN VARCHAR2 IS
BEGIN
   RETURN FND_API.G_RET_STS_SUCCESS ;
END G_RET_STS_SUCCESS ;


FUNCTION G_RET_STS_ERROR RETURN VARCHAR2 IS
BEGIN
   RETURN FND_API.G_RET_STS_ERROR ;
END G_RET_STS_ERROR ;


FUNCTION G_RET_STS_UNEXP_ERROR RETURN VARCHAR2 IS
BEGIN
   RETURN FND_API.G_RET_STS_UNEXP_ERROR ;
END G_RET_STS_UNEXP_ERROR ;


FUNCTION G_VALID_LEVEL_NONE RETURN NUMBER IS
BEGIN
   RETURN FND_API.G_VALID_LEVEL_NONE ;
END;


FUNCTION G_VALID_LEVEL_FULL RETURN NUMBER IS
BEGIN
   RETURN FND_API.G_VALID_LEVEL_FULL ;
END;


FUNCTION G_VALID_LEVEL_INT RETURN NUMBER IS
BEGIN
   RETURN CS_INTERACTION_PVT.G_VALID_LEVEL_INT ;
END;


FUNCTION G_TRUE RETURN VARCHAR2 IS
BEGIN
   return FND_API.G_TRUE ;
END;


FUNCTION G_FALSE RETURN VARCHAR2 IS
BEGIN
   return FND_API.G_FALSE ;
END;


FUNCTION get_res_name (p_object_type_code IN VARCHAR2,
                       p_object_id        IN NUMBER)
      RETURN VARCHAR2
   IS

	 l_object_type_code Varchar2(30);
	 l_code             Varchar2(30);

      CURSOR c_references(l_object_type_code varchar2)
      IS
         SELECT select_id, select_name, from_table, where_clause
           FROM jtf_objects_b
          WHERE object_code = l_object_type_code;

      l_id_column      jtf_objects_b.select_id%TYPE;
      l_name_column    jtf_objects_b.select_name%TYPE;
      l_from_clause    jtf_objects_b.from_table%TYPE;
      l_where_clause   jtf_objects_b.where_clause%TYPE;
      l_object_code    jtf_tasks_b.source_object_type_code%TYPE
               := p_object_type_code;
      l_object_name    jtf_tasks_b.source_object_name%TYPE;
      l_object_id      jtf_tasks_b.source_object_id%TYPE
               := p_object_id;
      is_null          BOOLEAN                                  :=
FALSE;
      is_not_null      BOOLEAN                                  :=
FALSE;
      sql_stmt         VARCHAR2(2000);
   BEGIN

	 -- travi for returning a resourse name even if object_type_code it does not have RS_
	 if (p_object_type_code is not null) then

		select substr(p_object_type_code,1,3)
            into l_code
		  from sys.dual;

          if(l_code = 'RS_') then
		   l_object_type_code := p_object_type_code;
IF (g_debug > 0 ) THEN
		   csd_gen_utility_pvt.add('p_object_type_code  ='||p_object_type_code);
END IF;

          else
		   l_object_type_code := 'RS_'||p_object_type_code;
IF (g_debug > 0 ) THEN
		   csd_gen_utility_pvt.add('In else p_object_type_code  ='||p_object_type_code);
END IF;

		end if;
      end if;


      OPEN c_references(l_object_type_code);
      FETCH c_references INTO l_id_column,
                              l_name_column,
                              l_from_clause,
                              l_where_clause;

      IF c_references%NOTFOUND
      THEN
IF (g_debug > 0 ) THEN
		csd_gen_utility_pvt.add('No data found for l_object_type_code  ='||l_object_type_code);
END IF;

          -- NULL;
      END IF;

      SELECT DECODE (l_where_clause, NULL, '  ', l_where_clause || ' AND
')
        INTO
             l_where_clause
        FROM dual;
      sql_stmt := ' SELECT ' ||
                  l_name_column ||
                  ' from ' ||
                  l_from_clause ||
                  '  where ' ||
                  l_where_clause ||
                  l_id_column ||
                  ' = :object_id ';
      EXECUTE IMMEDIATE sql_stmt
         INTO l_object_name
         USING p_object_id;
      RETURN l_object_name;

   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         RETURN NULL;
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
      WHEN OTHERS
      THEN
         RETURN NULL;
END get_res_name;

--------gilam changes---------
-- bug 3044659--
/*----------------------------------------------------------------*/
/* procedure name: GET_RO_DEFAULT_CURR_PL                         */
/* description  : Gets the price list from contract (default      */
/*                contract if null), if not, default price list   */
/*                from profile option.                            */
/*                                                                */
/* p_api_version                Standard IN param                 */
/* p_init_msg_list              Standard IN param                 */
/* p_incident_id                Service Request ID                */
/* p_repair_type_id             Repair Type ID                    */
/* p_ro_contract_line_id        RO Contract Line ID               */
/* x_contract_pl_id    		Contract Price List		  */
/* x_profile_pl_id		Profile Option Price List         */
/* x_currency_code              RO Currency                       */
/* x_return_status              Standard OUT param                */
/* x_msg_count                  Standard OUT param                */
/* x_msg_data                   Standard OUT param                */
/*                                                                */
/*----------------------------------------------------------------*/
PROCEDURE GET_RO_DEFAULT_CURR_PL
(
  p_api_version        		IN  NUMBER,
  p_init_msg_list      		IN  VARCHAR2,
  p_incident_id 	    	IN  NUMBER,
  p_repair_type_id	    	IN  NUMBER,
  p_ro_contract_line_id    	IN  NUMBER,
  x_contract_pl_id    		OUT NOCOPY NUMBER,
  x_profile_pl_id    		OUT NOCOPY NUMBER,
  x_currency_code	        OUT NOCOPY VARCHAR2,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2
)

IS
  l_api_name                	CONSTANT VARCHAR2(30) := 'GET_RO_DEFAULT_CURR_PL';
  l_api_version	            	CONSTANT NUMBER := 1.0;

  l_bus_process_id 		NUMBER := NULL;

  -- gilam: bug 3512619 - commented out sr contract and added flags for checking contract and its bp price list
  --l_sr_contract_line_id	NUMBER := NULL;
  l_use_contract_bp_pl		BOOLEAN;
  --

  l_contract_line_id		NUMBER := NULL;
  l_billing_pl_id		NUMBER := NULL;
  l_profile_pl_id		NUMBER := fnd_profile.value('CSD_DEFAULT_PRICE_LIST');
  l_use_pl			BOOLEAN;
  l_date			DATE := sysdate;
  l_pl_out_tbl			OKS_CON_COVERAGE_PUB.pricing_tbl_type;
  i				NUMBER := 1;

  -- gilam: bug 3479944 - get price list from repair type
  CURSOR c_rt_pl_id(p_repair_type_id number) IS
        SELECT price_list_header_id
          FROM csd_repair_types_b
         WHERE repair_type_id = p_repair_type_id;
  -- gilam: bug 3479944

BEGIN

  --debug msg
  IF (g_debug > 0 ) THEN
    csd_gen_utility_pvt.ADD ('GET_RO_DEFAULT_CURR_PL Begins');
  END IF;

  -- Standard Start of API savepoint
  SAVEPOINT GET_RO_DEFAULT_CURR_PL;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Begin API Body
  --

  IF (g_debug > 0 ) THEN
    csd_gen_utility_pvt.dump_api_info ( p_pkg_name  => G_PKG_NAME,
    				      p_api_name  => l_api_name );
  END IF;

  --debug msg
  IF (g_debug > 0 ) THEN
     csd_gen_utility_pvt.ADD ('Check required parameters and validate them');
  END IF;

  -- Check the required parameters
  CSD_PROCESS_UTIL.Check_Reqd_Param
  ( p_param_value	=> p_repair_type_id,
    p_param_name	=> 'REPAIR_TYPE_ID',
    p_api_name	  	=> l_api_name);

  -- Validate the repair type ID
  IF NOT( CSD_PROCESS_UTIL.Validate_repair_type_id ( p_repair_type_id  => p_repair_type_id )) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Validate the incident ID
  IF (p_incident_id IS NOT NULL) THEN
    IF NOT( CSD_PROCESS_UTIL.Validate_incident_id ( p_incident_id  => p_incident_id )) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  --debug msg
  IF (g_debug > 0 ) THEN
     csd_gen_utility_pvt.ADD ('Check required parameters and validation complete');
  END IF;


  --debug msg
  IF (g_debug > 0 ) THEN
     csd_gen_utility_pvt.ADD ('Get business process');
  END IF;

  BEGIN

     SELECT business_process_id
     INTO l_bus_process_id
     FROM csd_repair_types_b
     WHERE repair_type_id = p_repair_type_id;

  EXCEPTION

     WHEN others THEN
       FND_MESSAGE.SET_NAME('CSD','CSD_API_RO_CURR_AND_PL');
       FND_MESSAGE.SET_TOKEN('REPAIR_TYPE_ID', p_repair_type_id);
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;

  END;

  /* gilam: bug 3512619 - logic changed, no longer checking for sr contract
  -- If sr is passed, get sr contract
  -- If there is a sr contract, get price list from sr contract and derive currency
  -- If there is no sr contract, look at ro
  -- If ro contract is passed in, get price list from ro contract and derive currency
  -- If contract does not have price list, get default price list set in profile option and derive currency
  -- If user did not set default price list, null will be returned

  --debug msg
  IF (g_debug > 0 ) THEN
     csd_gen_utility_pvt.ADD ('Get SR contract');
  END IF;

  -- Incident ID is passed in, get SR contract
  IF (p_incident_id IS NOT NULL) THEN


   BEGIN

    -- get SR contract using incident id
    SELECT contract_service_id
    INTO l_sr_contract_line_id
    FROM cs_incidents
    WHERE incident_id = p_incident_id;

   EXCEPTION

    WHEN no_data_found THEN
      FND_MESSAGE.SET_NAME('CSD','CSD_API_RO_CURR_AND_PL');
      FND_MESSAGE.SET_TOKEN('INCIDENT_ID',p_incident_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;

    WHEN too_many_rows THEN
      FND_MESSAGE.SET_NAME('CSD','CSD_API_RO_CURR_AND_PL');
      FND_MESSAGE.SET_TOKEN('INCIDENT_ID',p_incident_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;

     WHEN others THEN
      FND_MESSAGE.SET_NAME('CSD','CSD_API_RO_CURR_AND_PL');
      FND_MESSAGE.SET_TOKEN('INCIDENT_ID',p_incident_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;

   END;

  END IF;

   -- RO contract is same as that of SR
   IF ((l_sr_contract_line_id IS NOT NULL) and (p_ro_contract_line_id IS NOT NULL)
   and (l_sr_contract_line_id = p_ro_contract_line_id)) THEN

     l_contract_line_id := l_sr_contract_line_id;

   -- RO contract is different from that of SR
   ELSIF ((l_sr_contract_line_id IS NOT NULL) and (p_ro_contract_line_id IS NOT NULL)
   and (l_sr_contract_line_id <> p_ro_contract_line_id)) THEN

     l_contract_line_id := p_ro_contract_line_id;

   -- SR has contract, but RO does not
   ELSIF ((l_sr_contract_line_id IS NOT NULL) and (p_ro_contract_line_id IS NULL)) THEN

     l_contract_line_id := l_sr_contract_line_id;

   -- SR does not have a contract, but RO does
   ELSIF ((l_sr_contract_line_id IS NULL) and (p_ro_contract_line_id IS NOT NULL)) THEN

     l_contract_line_id := p_ro_contract_line_id;

   END IF;

   IF ((l_sr_contract_line_id IS NOT NULL) or (p_ro_contract_line_id IS NOT NULL)) THEN
   */

   -- gilam: bug 3512619 - changed IF condition, added no data found error handling, and changed PL derivation
   -- If ro contract is passed in, get bp price list from contract and derive currency
   -- If contract does not have bp price list, get contract price list and derive currency (only if
   -- if the profile CSD PL Derivation Exclude Contract Header set to 'No' -- see bug#7140580.
   -- If the profile CSD PL Derivation Exclude Contract Header set to 'Yes', it will not get
   -- the default price list from the Contract header.
   -- If there is no price list on the contract or if there is an error, get default price list set in profile option and derive currency
   -- gilam: bug 3479944 - added repair type price list default option
   -- If user did not set default price list, get repair type price list and derive currency
   -- If repair type price list is not set, null will be returned

   IF (p_ro_contract_line_id IS NOT NULL) THEN

    --debug msg
    IF (g_debug > 0 ) THEN
      csd_gen_utility_pvt.ADD ('Call OKS_Con_Coverage_PUB.Get_BP_PriceList API: ro contract ='|| p_ro_contract_line_id);
    END IF;

    BEGIN

      -- Call OKS_Con_Coverage_PUB.Get_BP_PriceList API
      OKS_CON_COVERAGE_PUB.GET_BP_PRICELIST
      (
    	p_api_version       	=> l_api_version,
	p_init_msg_list     	=> 'T',
    	p_contract_line_id  	=> p_ro_contract_line_id,
        p_business_process_id   => l_bus_process_id,
        p_request_date		=> l_date,
        x_return_status 	=> x_return_status,
        x_msg_count     	=> x_msg_count,
        x_msg_data      	=> x_msg_data,
        x_pricing_tbl		=> l_pl_out_tbl
      );

      --debug msg
      IF (g_debug > 0 ) THEN
        csd_gen_utility_pvt.ADD ('Call OKS API to get price list: return status ='|| x_return_status);
        csd_gen_utility_pvt.ADD ('l_pl_out_tbl(i).bp_price_list_id: '|| l_pl_out_tbl(i).bp_price_list_id);
      END IF;

    EXCEPTION

      WHEN no_data_found THEN

        l_use_contract_bp_pl := FALSE;

    END;

    IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN

      -- only 1 row should be returned
      IF (l_pl_out_tbl.COUNT = 1) THEN

        -- contract has bp price list
        IF (l_pl_out_tbl(i).bp_price_list_id IS NOT NULL) THEN

            l_use_contract_bp_pl := TRUE;

        -- contract does not have bp price list
        ELSE

            l_use_contract_bp_pl := FALSE;

            IF (l_pl_out_tbl(i).contract_price_list_id IS NOT NULL) THEN

               l_billing_pl_id := l_pl_out_tbl(i).contract_price_list_id;

            END IF;

        END IF;

      ELSE

        -- contract does not have any price list or has errors, set flag to false
        l_use_contract_bp_pl := FALSE;

      END IF;

    ELSIF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

      -- contract has errors, set flag to false
      l_use_contract_bp_pl := FALSE;

    END IF;

   /* gilam - bug 3512619 - no need to check for SR contract
   -- both SR and RO do not have a contract
   --sangigup 3361671
   -- ELSIF ((p_incident_id IS NULL) and (p_ro_contract_line_id IS NULL)) THEN
   ELSIF ((l_sr_contract_line_id is null ) and (p_ro_contract_line_id IS NULL)) THEN
   --sangigup 3361671
   */

  -- no contract has passed in
  ELSE

     l_use_contract_bp_pl := FALSE;

  END IF;

  -- 1) if contract business process price list should be used
  IF (l_use_contract_bp_pl) THEN

      x_contract_pl_id := l_pl_out_tbl(i).bp_price_list_id;
      x_currency_code := CSD_CHARGE_LINE_UTIL.Get_PLCurrCode(x_contract_pl_id);
      x_profile_pl_id := NULL;

  ELSE


      -- 2) else if contract price list exists
        --bug#7140580 if the profile CSD PL_Derivation Exclude Contract Header
        --set to 'Yes', then we will not get the default price list from
        --the contract header.
          --bug#7140580
      IF (l_billing_pl_id IS NOT NULL) and ((nvl(FND_PROFILE.VALUE('CSD_PL_DR_EXCLUDE_CONTRACT_H'), 'N')) = 'N') then

        x_contract_pl_id := l_billing_pl_id;
        x_currency_code := CSD_CHARGE_LINE_UTIL.Get_PLCurrCode(x_contract_pl_id);
        x_profile_pl_id := NULL;

      -- 3) else get price list from profile option
      ELSE

        x_contract_pl_id := null;

        -- if profile option is set
        IF (l_profile_pl_id IS NOT NULL) THEN

          x_profile_pl_id := l_profile_pl_id;
          x_currency_code := CSD_CHARGE_LINE_UTIL.Get_PLCurrCode(l_profile_pl_id);

        -- gilam: bug 3479944 - added repair type price list default option
        -- 4) else get repair type price list
        ELSE

          open c_rt_pl_id(p_repair_type_id);
          fetch c_rt_pl_id into l_profile_pl_id;

            -- if repair type price list is set
            IF(c_rt_pl_id%FOUND) THEN

               x_profile_pl_id := l_profile_pl_id;
               x_currency_code := CSD_CHARGE_LINE_UTIL.Get_PLCurrCode(l_profile_pl_id);

            -- 5) else return nothing
            ELSE

               x_profile_pl_id := NULL;
               x_currency_code := NULL;

            END IF;

            close c_rt_pl_id;

        -- gilam; end bug 3479944
        END IF;

      END IF;

   END IF;

 -- gilam: end bug 3512619

 --debug msg
 IF (g_debug > 0 ) THEN
   csd_gen_utility_pvt.ADD ('GET_RO_DEFAULT_CURR_PL Ends');
 END IF;

 -- API body ends here

 EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO GET_RO_DEFAULT_CURR_PL;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                p_data   =>  x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO GET_RO_DEFAULT_CURR_PL;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                p_data   =>  x_msg_data );

   WHEN OTHERS THEN
     ROLLBACK TO GET_RO_DEFAULT_CURR_PL;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,
                                l_api_name  );
     END IF;
     FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                p_data   =>  x_msg_data );


END GET_RO_DEFAULT_CURR_PL;
----------gilam changes------


----------travi changes------

--bug#3875036

PROCEDURE GET_CHARGE_SELLING_PRICE
              (p_inventory_item_id    in  NUMBER,
			p_price_list_header_id in  NUMBER,
			p_unit_of_measure_code in  VARCHAR2,
			p_currency_code        in  VARCHAR2,
			p_quantity_required    in  NUMBER,
			p_account_id		   in  NUMBER DEFAULT null,			--bug#3875036
			p_org_id               in  NUMBER, -- added for R12
                  p_pricing_rec          in  CSD_PROCESS_UTIL.PRICING_ATTR_REC,
			x_selling_price        OUT NOCOPY NUMBER,
			x_return_status        OUT NOCOPY VARCHAR2,
                  x_msg_count            OUT NOCOPY NUMBER,
                  x_msg_data             OUT NOCOPY VARCHAR2)
IS

BEGIN

-- old  x_return_status := 'S';
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

--bug#3875036
  IF(FND_PROFILE.VALUE('CSD_ENABLE_ADVANCED_PRICING')='N') THEN

	  Cs_Pricing_Item_Pkg.Call_Pricing_Item
		   (p_inventory_item_id     => p_inventory_item_id,
		  p_price_list_id         => p_price_list_header_id,
		  p_uom_code              => p_unit_of_measure_code,
		  p_currency_code         => p_currency_code,
		  p_quantity              => p_quantity_required,
		  p_org_id	            => p_org_id, -- Aded for R12
			-- Pricing attributes
		  p_pricing_context       => p_pricing_rec.pricing_context,
		  p_pricing_attribute1    => p_pricing_rec.pricing_attribute1,
		  p_pricing_attribute2    => p_pricing_rec.pricing_attribute2,
		  p_pricing_attribute3    => p_pricing_rec.pricing_attribute3,
		  p_pricing_attribute4    => p_pricing_rec.pricing_attribute4,
		  p_pricing_attribute5    => p_pricing_rec.pricing_attribute5,
		  p_pricing_attribute6    => p_pricing_rec.pricing_attribute6,
		  p_pricing_attribute7    => p_pricing_rec.pricing_attribute7,
		  p_pricing_attribute8    => p_pricing_rec.pricing_attribute8,
		  p_pricing_attribute9    => p_pricing_rec.pricing_attribute9,
		  p_pricing_attribute10   => p_pricing_rec.pricing_attribute10,
		  p_pricing_attribute11   => p_pricing_rec.pricing_attribute11,
		  p_pricing_attribute12   => p_pricing_rec.pricing_attribute12,
		  p_pricing_attribute13   => p_pricing_rec.pricing_attribute13,
		  p_pricing_attribute14   => p_pricing_rec.pricing_attribute14,
		  p_pricing_attribute15   => p_pricing_rec.pricing_attribute15,
		  p_pricing_attribute16   => p_pricing_rec.pricing_attribute16,
		  p_pricing_attribute17   => p_pricing_rec.pricing_attribute17,
		  p_pricing_attribute18   => p_pricing_rec.pricing_attribute18,
		  p_pricing_attribute19   => p_pricing_rec.pricing_attribute19,
		  p_pricing_attribute20   => p_pricing_rec.pricing_attribute20,
		  p_pricing_attribute21   => p_pricing_rec.pricing_attribute21,
		  p_pricing_attribute22   => p_pricing_rec.pricing_attribute22,
		  p_pricing_attribute23   => p_pricing_rec.pricing_attribute23,
		  p_pricing_attribute24   => p_pricing_rec.pricing_attribute24,
		  p_pricing_attribute25   => p_pricing_rec.pricing_attribute25,
		  p_pricing_attribute26   => p_pricing_rec.pricing_attribute26,
		  p_pricing_attribute27   => p_pricing_rec.pricing_attribute27,
		  p_pricing_attribute28   => p_pricing_rec.pricing_attribute28,
		  p_pricing_attribute29   => p_pricing_rec.pricing_attribute29,
		  p_pricing_attribute30   => p_pricing_rec.pricing_attribute30,
		  p_pricing_attribute31   => p_pricing_rec.pricing_attribute31,
		  p_pricing_attribute32   => p_pricing_rec.pricing_attribute32,
		  p_pricing_attribute33   => p_pricing_rec.pricing_attribute33,
		  p_pricing_attribute34   => p_pricing_rec.pricing_attribute34,
		  p_pricing_attribute35   => p_pricing_rec.pricing_attribute35,
		  p_pricing_attribute36   => p_pricing_rec.pricing_attribute36,
		  p_pricing_attribute37   => p_pricing_rec.pricing_attribute37,
		  p_pricing_attribute38   => p_pricing_rec.pricing_attribute38,
		  p_pricing_attribute39   => p_pricing_rec.pricing_attribute39,
		  p_pricing_attribute40   => p_pricing_rec.pricing_attribute40,
		  p_pricing_attribute41   => p_pricing_rec.pricing_attribute41,
		  p_pricing_attribute42   => p_pricing_rec.pricing_attribute42,
		  p_pricing_attribute43   => p_pricing_rec.pricing_attribute43,
		  p_pricing_attribute44   => p_pricing_rec.pricing_attribute44,
		  p_pricing_attribute45   => p_pricing_rec.pricing_attribute45,
		  p_pricing_attribute46   => p_pricing_rec.pricing_attribute46,
		  p_pricing_attribute47   => p_pricing_rec.pricing_attribute47,
		  p_pricing_attribute48   => p_pricing_rec.pricing_attribute48,
		  p_pricing_attribute49   => p_pricing_rec.pricing_attribute49,
		  p_pricing_attribute50   => p_pricing_rec.pricing_attribute50,
		  p_pricing_attribute51   => p_pricing_rec.pricing_attribute51,
		  p_pricing_attribute52   => p_pricing_rec.pricing_attribute52,
		  p_pricing_attribute53   => p_pricing_rec.pricing_attribute53,
		  p_pricing_attribute54   => p_pricing_rec.pricing_attribute54,
		  p_pricing_attribute55   => p_pricing_rec.pricing_attribute55,
		  p_pricing_attribute56   => p_pricing_rec.pricing_attribute56,
		  p_pricing_attribute57   => p_pricing_rec.pricing_attribute57,
		  p_pricing_attribute58   => p_pricing_rec.pricing_attribute58,
		  p_pricing_attribute59   => p_pricing_rec.pricing_attribute59,
		  p_pricing_attribute60   => p_pricing_rec.pricing_attribute60,
		  p_pricing_attribute61   => p_pricing_rec.pricing_attribute61,
		  p_pricing_attribute62   => p_pricing_rec.pricing_attribute62,
		  p_pricing_attribute63   => p_pricing_rec.pricing_attribute63,
		  p_pricing_attribute64   => p_pricing_rec.pricing_attribute64,
		  p_pricing_attribute65   => p_pricing_rec.pricing_attribute65,
		  p_pricing_attribute66   => p_pricing_rec.pricing_attribute66,
		  p_pricing_attribute67   => p_pricing_rec.pricing_attribute67,
		  p_pricing_attribute68   => p_pricing_rec.pricing_attribute68,
		  p_pricing_attribute69   => p_pricing_rec.pricing_attribute69,
		  p_pricing_attribute70   => p_pricing_rec.pricing_attribute70,
		  p_pricing_attribute71   => p_pricing_rec.pricing_attribute71,
		  p_pricing_attribute72   => p_pricing_rec.pricing_attribute72,
		  p_pricing_attribute73   => p_pricing_rec.pricing_attribute73,
		  p_pricing_attribute74   => p_pricing_rec.pricing_attribute74,
		  p_pricing_attribute75   => p_pricing_rec.pricing_attribute75,
		  p_pricing_attribute76   => p_pricing_rec.pricing_attribute76,
		  p_pricing_attribute77   => p_pricing_rec.pricing_attribute77,
		  p_pricing_attribute78   => p_pricing_rec.pricing_attribute78,
		  p_pricing_attribute79   => p_pricing_rec.pricing_attribute79,
		  p_pricing_attribute80   => p_pricing_rec.pricing_attribute80,
		  p_pricing_attribute81   => p_pricing_rec.pricing_attribute81,
		  p_pricing_attribute82   => p_pricing_rec.pricing_attribute82,
		  p_pricing_attribute83   => p_pricing_rec.pricing_attribute83,
		  p_pricing_attribute84   => p_pricing_rec.pricing_attribute84,
		  p_pricing_attribute85   => p_pricing_rec.pricing_attribute85,
		  p_pricing_attribute86   => p_pricing_rec.pricing_attribute86,
		  p_pricing_attribute87   => p_pricing_rec.pricing_attribute87,
		  p_pricing_attribute88   => p_pricing_rec.pricing_attribute88,
		  p_pricing_attribute89   => p_pricing_rec.pricing_attribute89,
		  p_pricing_attribute90   => p_pricing_rec.pricing_attribute90,
		  p_pricing_attribute91   => p_pricing_rec.pricing_attribute91,
		  p_pricing_attribute92   => p_pricing_rec.pricing_attribute92,
		  p_pricing_attribute93   => p_pricing_rec.pricing_attribute93,
		  p_pricing_attribute94   => p_pricing_rec.pricing_attribute94,
		  p_pricing_attribute95   => p_pricing_rec.pricing_attribute95,
		  p_pricing_attribute96   => p_pricing_rec.pricing_attribute96,
		  p_pricing_attribute97   => p_pricing_rec.pricing_attribute97,
		  p_pricing_attribute98   => p_pricing_rec.pricing_attribute98,
		  p_pricing_attribute99   => p_pricing_rec.pricing_attribute99,
		  p_pricing_attribute100  => p_pricing_rec.pricing_attribute100,
		  x_list_price            => x_selling_price,
			x_return_status         => x_return_status,
			x_msg_count             => x_msg_count,
			x_msg_data              => x_msg_data);

		   IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
			   IF (g_debug > 0 ) THEN
				   csd_gen_utility_pvt.ADD('Cs_Pricing_Item_Pkg.Call_Pricing_Item failed');
			   END IF;
			   -- Shiv Ragunathan, 2/26/04, While fixing FP bug 3449351, noticed
			 -- that this exception gets raised and is not handled in the API,
			 -- Since the error status is being returned, no need to raise the
			 -- exception, hence commenting it out
			   -- RAISE FND_API.G_EXC_ERROR;
		   END IF;

		ELSE
	/* bug#3875036 */
			PRICE_REQUEST(
				p_inventory_item_id		=>	p_inventory_item_id,
				p_price_list_header_id	=>	p_price_list_header_id,
				p_unit_of_measure_code	=>	p_unit_of_measure_code,
				p_currency_code			=>	p_currency_code,
				p_quantity_required		=>	p_quantity_required,
				p_account_id			=>	p_account_id,
				p_pricing_rec			=>	p_pricing_rec,
				x_selling_price			=>	x_selling_price,
				x_return_status			=>	x_return_status,
				x_msg_count				=>	x_msg_count,
				x_msg_data				=>	x_msg_data);

				IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
				   IF (g_debug > 0 ) THEN
					   csd_gen_utility_pvt.ADD('CSD_PROCESS_UTIL.PRICE_REQUEST failed');
				   END IF;
				END IF;

		END IF;


      -- Standard call to get message count and IF count is  get message info.
      FND_MSG_PUB.Count_And_Get
           (p_count  =>  x_msg_count,
            p_data   =>  x_msg_data );

END GET_CHARGE_SELLING_PRICE;

/* bug#3875036 */
PROCEDURE PRICE_REQUEST
           (p_inventory_item_id    in  NUMBER,
			p_price_list_header_id in  NUMBER,
			p_unit_of_measure_code in  VARCHAR2,
			p_currency_code        in  VARCHAR2,
			p_quantity_required    in  NUMBER,
			p_account_id		   in  NUMBER DEFAULT null,
            p_pricing_rec          in  CSD_PROCESS_UTIL.PRICING_ATTR_REC,
			x_selling_price        OUT NOCOPY NUMBER,
			x_return_status        OUT NOCOPY VARCHAR2,
            x_msg_count            OUT NOCOPY NUMBER,
            x_msg_data             OUT NOCOPY VARCHAR2)
IS
 p_line_tbl                  QP_PREQ_GRP.LINE_TBL_TYPE;
 p_qual_tbl                  QP_PREQ_GRP.QUAL_TBL_TYPE;
 p_line_attr_tbl             QP_PREQ_GRP.LINE_ATTR_TBL_TYPE;
 p_LINE_DETAIL_tbl           QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
 p_LINE_DETAIL_qual_tbl      QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE;
 p_LINE_DETAIL_attr_tbl      QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE;
 p_related_lines_tbl         QP_PREQ_GRP.RELATED_LINES_TBL_TYPE;
 p_control_rec               QP_PREQ_GRP.CONTROL_RECORD_TYPE;
 x_line_tbl                  QP_PREQ_GRP.LINE_TBL_TYPE;
 x_line_qual                 QP_PREQ_GRP.QUAL_TBL_TYPE;
 x_line_attr_tbl             QP_PREQ_GRP.LINE_ATTR_TBL_TYPE;
 x_line_detail_tbl           QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
 x_line_detail_qual_tbl      QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE;
 x_line_detail_attr_tbl      QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE;
 x_related_lines_tbl         QP_PREQ_GRP.RELATED_LINES_TBL_TYPE;
-- x_return_status             VARCHAR2(240);
 x_return_status_text        VARCHAR2(240);
 qual_rec                    QP_PREQ_GRP.QUAL_REC_TYPE;
 line_attr_rec               QP_PREQ_GRP.LINE_ATTR_REC_TYPE;
 line_rec                    QP_PREQ_GRP.LINE_REC_TYPE;
 rltd_rec                    QP_PREQ_GRP.RELATED_LINES_REC_TYPE;


 I BINARY_INTEGER;
 l_version VARCHAR2(240);


 l_Price_attr_tbl  			ASO_QUOTE_PUB.Price_Attributes_Tbl_Type := ASO_QUOTE_PUB.G_Miss_Price_Attributes_Tbl;

BEGIN

-- The statments below help the user in turning debug on
-- The user needs to set the oe_debug_pub.G_DIR value.
-- This value can be found by executing the following statement
--     select value
--     from   v$parameter
--     where name like 'utl_file_dir%';
-- This might return multiple values , and any one of the values can be taken
-- Make sure that the value of the directory specified , actually exists

	-- Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

--dbms_output.put_line ('Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

--oe_debug_pub.SetDebugLevel(10);
	oe_debug_pub.Initialize;
--oe_debug_pub.debug_on;

-- Passing Information to the Pricing Engine


  -- Initialize the values of the Pricing line table. Since we are passing
   -- one line at a time from the form we hard the line_index to 1
   l_price_attr_tbl(1).flex_title           :=  'QP_ATTR_DEFNS_PRICING';
   l_Price_Attr_tbl(1).pricing_context	    :=	p_pricing_rec.pricing_context;
   l_Price_Attr_tbl(1).pricing_attribute1	:=	p_pricing_rec.pricing_attribute1;
   l_Price_Attr_tbl(1).pricing_attribute2	:=	p_pricing_rec.pricing_attribute2;
   l_Price_Attr_tbl(1).pricing_attribute3	:=	p_pricing_rec.pricing_attribute3;
   l_Price_Attr_tbl(1).pricing_attribute4	:=	p_pricing_rec.pricing_attribute4;
   l_Price_Attr_tbl(1).pricing_attribute5	:=	p_pricing_rec.pricing_attribute5;
   l_Price_Attr_tbl(1).pricing_attribute6	:=	p_pricing_rec.pricing_attribute6;
   l_Price_Attr_tbl(1).pricing_attribute7	:=	p_pricing_rec.pricing_attribute7;
   l_Price_Attr_tbl(1).pricing_attribute8	:=	p_pricing_rec.pricing_attribute8;
   l_Price_Attr_tbl(1).pricing_attribute9	:=	p_pricing_rec.pricing_attribute9;
   l_Price_Attr_tbl(1).pricing_attribute10	:=	p_pricing_rec.pricing_attribute10;
   l_Price_Attr_tbl(1).pricing_attribute11	:=	p_pricing_rec.pricing_attribute11;
   l_Price_Attr_tbl(1).pricing_attribute12	:=	p_pricing_rec.pricing_attribute12;
   l_Price_Attr_tbl(1).pricing_attribute13	:=	p_pricing_rec.pricing_attribute13;
   l_Price_Attr_tbl(1).pricing_attribute14	:=	p_pricing_rec.pricing_attribute14;
   l_Price_Attr_tbl(1).pricing_attribute15	:=	p_pricing_rec.pricing_attribute15;
   l_Price_Attr_tbl(1).pricing_attribute16	:=	p_pricing_rec.pricing_attribute16;
   l_Price_Attr_tbl(1).pricing_attribute17  :=	p_pricing_rec.pricing_attribute17;
   l_Price_Attr_tbl(1).pricing_attribute18	:=	p_pricing_rec.pricing_attribute18;
   l_Price_Attr_tbl(1).pricing_attribute19	:=	p_pricing_rec.pricing_attribute19;
   l_Price_Attr_tbl(1).pricing_attribute20	:=	p_pricing_rec.pricing_attribute20;
   l_Price_Attr_tbl(1).pricing_attribute21	:=	p_pricing_rec.pricing_attribute21;
   l_Price_Attr_tbl(1).pricing_attribute22	:=	p_pricing_rec.pricing_attribute22;
   l_Price_Attr_tbl(1).pricing_attribute23	:=	p_pricing_rec.pricing_attribute23;
   l_Price_Attr_tbl(1).pricing_attribute24	:=	p_pricing_rec.pricing_attribute24;
   l_Price_Attr_tbl(1).pricing_attribute25	:=	p_pricing_rec.pricing_attribute25;
   l_Price_Attr_tbl(1).pricing_attribute26	:=	p_pricing_rec.pricing_attribute26;
   l_Price_Attr_tbl(1).pricing_attribute27	:=	p_pricing_rec.pricing_attribute27;
   l_Price_Attr_tbl(1).pricing_attribute28	:=	p_pricing_rec.pricing_attribute28;
   l_Price_Attr_tbl(1).pricing_attribute29	:=	p_pricing_rec.pricing_attribute29;
   l_Price_Attr_tbl(1).pricing_attribute30	:=	p_pricing_rec.pricing_attribute30;
   l_Price_Attr_tbl(1).pricing_attribute31	:=	p_pricing_rec.pricing_attribute31;
   l_Price_Attr_tbl(1).pricing_attribute32	:=	p_pricing_rec.pricing_attribute32;
   l_Price_Attr_tbl(1).pricing_attribute33	:=	p_pricing_rec.pricing_attribute33;
   l_Price_Attr_tbl(1).pricing_attribute34	:=	p_pricing_rec.pricing_attribute34;
   l_Price_Attr_tbl(1).pricing_attribute35  :=	p_pricing_rec.pricing_attribute35;
   l_Price_Attr_tbl(1).pricing_attribute36	:=	p_pricing_rec.pricing_attribute36;
   l_Price_Attr_tbl(1).pricing_attribute37	:=	p_pricing_rec.pricing_attribute37;
   l_Price_Attr_tbl(1).pricing_attribute38	:=	p_pricing_rec.pricing_attribute38;
   l_Price_Attr_tbl(1).pricing_attribute39	:=	p_pricing_rec.pricing_attribute39;
   l_Price_Attr_tbl(1).pricing_attribute40	:=	p_pricing_rec.pricing_attribute40;
   l_Price_Attr_tbl(1).pricing_attribute41	:=	p_pricing_rec.pricing_attribute41;
   l_Price_Attr_tbl(1).pricing_attribute42	:=	p_pricing_rec.pricing_attribute42;
   l_Price_Attr_tbl(1).pricing_attribute43	:=	p_pricing_rec.pricing_attribute43;
   l_Price_Attr_tbl(1).pricing_attribute44	:=	p_pricing_rec.pricing_attribute44;
   l_Price_Attr_tbl(1).pricing_attribute45	:=	p_pricing_rec.pricing_attribute45;
   l_Price_Attr_tbl(1).pricing_attribute46	:=	p_pricing_rec.pricing_attribute46;
   l_Price_Attr_tbl(1).pricing_attribute47	:=	p_pricing_rec.pricing_attribute47;
   l_Price_Attr_tbl(1).pricing_attribute48	:=	p_pricing_rec.pricing_attribute48;
   l_Price_Attr_tbl(1).pricing_attribute49	:=	p_pricing_rec.pricing_attribute49;
   l_Price_Attr_tbl(1).pricing_attribute50	:=	p_pricing_rec.pricing_attribute50;
   l_Price_Attr_tbl(1).pricing_attribute51	:=	p_pricing_rec.pricing_attribute51;
   l_Price_Attr_tbl(1).pricing_attribute52	:=	p_pricing_rec.pricing_attribute52;
   l_Price_Attr_tbl(1).pricing_attribute53  :=	p_pricing_rec.pricing_attribute53;
   l_Price_Attr_tbl(1).pricing_attribute54	:=	p_pricing_rec.pricing_attribute54;
   l_Price_Attr_tbl(1).pricing_attribute55	:=	p_pricing_rec.pricing_attribute55;
   l_Price_Attr_tbl(1).pricing_attribute56	:=	p_pricing_rec.pricing_attribute56;
   l_Price_Attr_tbl(1).pricing_attribute57	:=	p_pricing_rec.pricing_attribute57;
   l_Price_Attr_tbl(1).pricing_attribute58	:=	p_pricing_rec.pricing_attribute58;
   l_Price_Attr_tbl(1).pricing_attribute59	:=	p_pricing_rec.pricing_attribute59;
   l_Price_Attr_tbl(1).pricing_attribute60	:=	p_pricing_rec.pricing_attribute60;
   l_Price_Attr_tbl(1).pricing_attribute61	:=	p_pricing_rec.pricing_attribute61;
   l_Price_Attr_tbl(1).pricing_attribute62	:=	p_pricing_rec.pricing_attribute62;
   l_Price_Attr_tbl(1).pricing_attribute63	:=	p_pricing_rec.pricing_attribute63;
   l_Price_Attr_tbl(1).pricing_attribute64	:=	p_pricing_rec.pricing_attribute64;
   l_Price_Attr_tbl(1).pricing_attribute65	:=	p_pricing_rec.pricing_attribute65;
   l_Price_Attr_tbl(1).pricing_attribute66	:=	p_pricing_rec.pricing_attribute66;
   l_Price_Attr_tbl(1).pricing_attribute67	:=	p_pricing_rec.pricing_attribute67;
   l_Price_Attr_tbl(1).pricing_attribute68	:=	p_pricing_rec.pricing_attribute68;
   l_Price_Attr_tbl(1).pricing_attribute69	:=	p_pricing_rec.pricing_attribute69;
   l_Price_Attr_tbl(1).pricing_attribute70	:=	p_pricing_rec.pricing_attribute70;
   l_Price_Attr_tbl(1).pricing_attribute71  :=	p_pricing_rec.pricing_attribute71;
   l_Price_Attr_tbl(1).pricing_attribute72	:=	p_pricing_rec.pricing_attribute72;
   l_Price_Attr_tbl(1).pricing_attribute73	:=	p_pricing_rec.pricing_attribute73;
   l_Price_Attr_tbl(1).pricing_attribute74	:=	p_pricing_rec.pricing_attribute74;
   l_Price_Attr_tbl(1).pricing_attribute75	:=	p_pricing_rec.pricing_attribute75;
   l_Price_Attr_tbl(1).pricing_attribute76	:=	p_pricing_rec.pricing_attribute76;
   l_Price_Attr_tbl(1).pricing_attribute77	:=	p_pricing_rec.pricing_attribute77;
   l_Price_Attr_tbl(1).pricing_attribute78	:=	p_pricing_rec.pricing_attribute78;
   l_Price_Attr_tbl(1).pricing_attribute79	:=	p_pricing_rec.pricing_attribute79;
   l_Price_Attr_tbl(1).pricing_attribute80	:=	p_pricing_rec.pricing_attribute80;
   l_Price_Attr_tbl(1).pricing_attribute81	:=	p_pricing_rec.pricing_attribute81;
   l_Price_Attr_tbl(1).pricing_attribute82	:=	p_pricing_rec.pricing_attribute82;
   l_Price_Attr_tbl(1).pricing_attribute83	:=	p_pricing_rec.pricing_attribute83;
   l_Price_Attr_tbl(1).pricing_attribute84  :=	p_pricing_rec.pricing_attribute84;
   l_Price_Attr_tbl(1).pricing_attribute85	:=	p_pricing_rec.pricing_attribute85;
   l_Price_Attr_tbl(1).pricing_attribute86	:=	p_pricing_rec.pricing_attribute86;
   l_Price_Attr_tbl(1).pricing_attribute87	:=	p_pricing_rec.pricing_attribute87;
   l_Price_Attr_tbl(1).pricing_attribute88	:=	p_pricing_rec.pricing_attribute88;
   l_Price_Attr_tbl(1).pricing_attribute89	:=	p_pricing_rec.pricing_attribute89;
   l_Price_Attr_tbl(1).pricing_attribute90	:=	p_pricing_rec.pricing_attribute90;
   l_Price_Attr_tbl(1).pricing_attribute91	:=	p_pricing_rec.pricing_attribute91;
   l_Price_Attr_tbl(1).pricing_attribute92	:=	p_pricing_rec.pricing_attribute92;
   l_Price_Attr_tbl(1).pricing_attribute93	:=	p_pricing_rec.pricing_attribute93;
   l_Price_Attr_tbl(1).pricing_attribute94	:=	p_pricing_rec.pricing_attribute94;
   l_Price_Attr_tbl(1).pricing_attribute95	:=	p_pricing_rec.pricing_attribute95;
   l_Price_Attr_tbl(1).pricing_attribute96	:=	p_pricing_rec.pricing_attribute96;
   l_Price_Attr_tbl(1).pricing_attribute97	:=	p_pricing_rec.pricing_attribute97;
   l_Price_Attr_tbl(1).pricing_attribute98	:=	p_pricing_rec.pricing_attribute98;
   l_Price_Attr_tbl(1).pricing_attribute99	:=	p_pricing_rec.pricing_attribute99;
   l_Price_Attr_tbl(1).pricing_attribute100 :=	p_pricing_rec.pricing_attribute100;


   ASO_PRICING_CALLBACK_PVT.Append_asked_for(
	 p_line_index         => 1,
	 p_pricing_attr_tbl   => l_Price_Attr_tbl,
	 px_Req_line_attr_tbl => p_line_attr_tbl,
	 px_Req_qual_tbl      => p_qual_tbl);


-- Setting up the control record variables
-- Please refer documentation for explanation of each of these settings

	p_control_rec.pricing_event := 'LINE';
	p_control_rec.calculate_flag := 'Y';
	p_control_rec.simulation_flag := 'N';

-- Request Line (Order Line) Information
	--line_rec.request_type_code :='ONT';
	line_rec.request_type_code :='ASO';
	line_rec.line_Index :='1';									-- Request Line Index
	line_rec.line_type_code := 'LINE';							-- LINE or ORDER(Summary Line)
	line_rec.pricing_effective_date := sysdate;					-- Pricing as of what date ?
	line_rec.active_date_first := sysdate;						-- Can be Ordered Date or Ship Date
	line_rec.active_date_second := sysdate;						-- Can be Ordered Date or Ship Date
	line_rec.active_date_first_type := 'NO TYPE';				-- ORD/SHIP
	line_rec.active_date_second_type :='NO TYPE';				-- ORD/SHIP
	line_rec.line_quantity := p_quantity_required;				-- Ordered Quantity
	line_rec.line_uom_code := p_unit_of_measure_code;           -- Ordered UOM Code
	line_rec.currency_code := p_currency_code;		            -- Currency Code
	line_rec.price_flag := 'Y';									-- Price Flag can have 'Y' , 'N'(No pricing) , 'P'(Phase)
	p_line_tbl(1) := line_rec;

-- If u need to get the price for multiple order lines , please fill the above information for each line
-- and add to the p_line_tbl

-- Pricing Attributes Passed In
-- Please refer documentation for explanation of each of these settings
	line_attr_rec.LINE_INDEX := 1; -- Attributes for the above line. Attributes are attached with the line index
	line_attr_rec.PRICING_CONTEXT :='ITEM';
	line_attr_rec.PRICING_ATTRIBUTE :='PRICING_ATTRIBUTE1';
	line_attr_rec.PRICING_ATTR_VALUE_FROM  := p_inventory_item_id;	--Inventory Item Id
	line_attr_rec.VALIDATED_FLAG :='N';
	p_line_attr_tbl(1):= line_attr_rec;

-- If u need to add multiple attributes , please fill the above information for each attribute
-- and add to the p_line_attr_tbl
-- Make sure that u are adding the attribute to the right line index

-- Qualifiers Passed In
-- Please refer documentation for explanation of each of these settings

	qual_rec.LINE_INDEX := 1; -- Attributes for the above line. Attributes are attached with the line index
	qual_rec.QUALIFIER_CONTEXT :='MODLIST';
	qual_rec.QUALIFIER_ATTRIBUTE :='QUALIFIER_ATTRIBUTE4';
	qual_rec.QUALIFIER_ATTR_VALUE_FROM :=p_price_list_header_id; -- Price List Id  1000
	qual_rec.COMPARISON_OPERATOR_CODE := '=';
	qual_rec.VALIDATED_FLAG :='Y';
	p_qual_tbl(1):= qual_rec;

	qual_rec.LINE_INDEX := 1;
	qual_rec.QUALIFIER_CONTEXT :='CUSTOMER';
	qual_rec.QUALIFIER_ATTRIBUTE :='QUALIFIER_ATTRIBUTE2';
	qual_rec.QUALIFIER_ATTR_VALUE_FROM := p_account_id;
	qual_rec.COMPARISON_OPERATOR_CODE := '=';
	qual_rec.VALIDATED_FLAG :='N';
	p_qual_tbl(1+1):= qual_rec;


-- This statement prints out the version of the QP_PREQ_PUB API(QPXPPREB.pls).Information only
l_version :=  QP_PREQ_GRP.GET_VERSION;
--DBMS_OUTPUT.PUT_LINE('Testing version '||l_version);


-- Actual Call to the Pricing Engine
	QP_PREQ_PUB.PRICE_REQUEST
	   (p_line_tbl				=>	p_line_tbl,
		p_qual_tbl				=>	p_qual_tbl,
		p_line_attr_tbl			=>	p_line_attr_tbl,
		p_line_detail_tbl		=>	p_line_detail_tbl,
		p_line_detail_qual_tbl	=>	p_line_detail_qual_tbl,
		p_line_detail_attr_tbl	=>	p_line_detail_attr_tbl,
		p_related_lines_tbl		=>	p_related_lines_tbl,
		p_control_rec			=>	p_control_rec,
		x_line_tbl				=>	x_line_tbl,
		x_line_qual				=>	x_line_qual,
		x_line_attr_tbl			=>	x_line_attr_tbl,
		x_line_detail_tbl		=>	x_line_detail_tbl,
		x_line_detail_qual_tbl	=>	x_line_detail_qual_tbl,
		x_line_detail_attr_tbl	=>	x_line_detail_attr_tbl,
		x_related_lines_tbl		=>	x_related_lines_tbl,
		x_return_status			=>	x_return_status,
		x_return_status_text	=>	x_return_status_text);

-- Interpreting Information From the Pricing Engine . Output statements commented. Please uncomment for debugging

-- Return Status Information ..
--DBMS_OUTPUT.PUT_LINE('Return Status text '||  x_return_status_text);
--DBMS_OUTPUT.PUT_LINE('Return Status  '||  x_return_status);
--DBMS_OUTPUT.PUT_LINE('+---------Information Returned to Caller---------------------+ ');
--DBMS_OUTPUT.PUT_LINE('-------------Request Line Information-------------------');

	I := x_line_tbl.FIRST;
	IF I IS NOT NULL THEN
	--  DBMS_OUTPUT.PUT_LINE('Line Index: '||x_line_tbl(I).line_index);
	--  DBMS_OUTPUT.PUT_LINE('Unit_price: '||x_line_tbl(I).unit_price);
	--  DBMS_OUTPUT.PUT_LINE('Percent price: '||x_line_tbl(I).percent_price);
	--  DBMS_OUTPUT.PUT_LINE('Adjusted Unit Price: '||x_line_tbl(I).adjusted_unit_price);
	--  DBMS_OUTPUT.PUT_LINE('Pricing status code: '||x_line_tbl(I).status_code);
	--  DBMS_OUTPUT.PUT_LINE('Pricing status text: '||x_line_tbl(I).status_text);
		x_selling_price :=  x_line_tbl(I).adjusted_unit_price;
	--  EXIT WHEN I = x_line_tbl.LAST;
	--  I := x_line_tbl.NEXT(I);
	END IF;

	IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	   IF (g_debug > 0 ) THEN
		   csd_gen_utility_pvt.ADD('QP_PREQ_PUB.PRICE_REQUEST failed');
	   END IF;
	END IF;

END PRICE_REQUEST;


FUNCTION Is_MultiOrg_Enabled RETURN BOOLEAN IS

  l_multiorg_enabled varchar2(1);

BEGIN

  Select multi_org_flag
  into l_multiorg_enabled
  from FND_PRODUCT_GROUPS;

  IF l_multiorg_enabled = 'Y' THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN FALSE;
END Is_MultiOrg_Enabled;



--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name    : Get_GLCurrencyCode
--   Type        :  Private Function
--   Pre-Req     :  None
--   Function    :  Returns CURRENCY CODE for the org id passed. If no currency
--                  code exists for the org, returns null.
--   Return Type : Varchar2
--
--   End of Comments
--


   FUNCTION Get_GLCurrencyCode (
	 p_org_id IN NUMBER
    ) RETURN VARCHAR2
    IS
      l_currency_code VARCHAR2(15);

    BEGIN
	  SELECT gl.currency_code
	  INTO l_currency_code
	  FROM gl_sets_of_books gl, hr_operating_units hr
	  WHERE hr.set_of_books_id = gl.set_of_books_id
	  AND hr.organization_id= p_org_id;

	  return l_currency_code;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
  FND_MESSAGE.SET_NAME('CSD','CSD_MISSING_CURR_CODE');
--  FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID',p_inv_item_id);
  FND_MSG_PUB.Add;
  RAISE FND_API.G_EXC_ERROR;
  RETURN NULL;

  WHEN TOO_MANY_ROWS THEN
  FND_MESSAGE.SET_NAME('CSD','CSD_MISSING_CURR_CODE');
  FND_MSG_PUB.Add;
  RAISE FND_API.G_EXC_ERROR;
  RETURN NULL;

  WHEN OTHERS THEN
	 RETURN NULL;

   END Get_GLCurrencyCode;


/* bug#3875036 */
FUNCTION GET_PL_CURRENCY_CODE(p_price_list_id   IN   NUMBER) RETURN VARCHAR2
 IS

   l_pl_curr_code 	VARCHAR2(15) := NULL;

BEGIN

  SELECT currency_code
  INTO l_pl_curr_code
  FROM qp_list_headers_b
  WHERE list_header_id = p_price_list_id;

    return l_pl_curr_code;

exception
    when no_data_found then
        return null;
    when others then
        return null;
END GET_PL_CURRENCY_CODE;


-- bug fix for 4108369, begin
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name    : get_sr_add_to_order
--   Type        :  Private Function
--   Pre-Req     :  None
--   Function    :  Returns existing order for the SR.
--   Return Type : Varchar2
--
--   End of Comments
--

   FUNCTION Get_Sr_add_to_order (
	 p_repair_line_Id IN NUMBER,
	 p_action_type IN VARCHAR2
    ) RETURN NUMBER
    IS
    l_add_to_order_id NUMBER;
    BEGIN

      -- swai: bug 5931926 -  3rd party logistics for 12.0.2
      -- when getting the highest order number for add to order,
      -- ensure that the order number is for the appropriate account
      -- since there may be 3rd party orders for the RO
      If(p_Action_type = 'RMA') then
        begin
          Select max(ced.order_header_id)
          into  l_add_to_order_id
          from  csd_repairs dr,
                cs_estimate_details ced,
                oe_order_headers_all ooh,
                oe_order_types_v oot,
                cs_incidents_all_b sr               -- swai: bug 5931926
          where dr.repair_line_id = p_repair_line_id
          and  ced.incident_id = dr.incident_id
          and  ced.order_header_id is not null
          and  ooh.open_flag = 'Y'
          and  nvl(ooh.cancelled_flag,'N') = 'N'
          and  ooh.header_id = ced.order_header_id
          and  ooh.transactional_curr_code = dr.currency_code
          and  (ooh.cust_po_number = nvl(dr.default_po_num,ooh.cust_po_number)
               or ooh.cust_po_number is null)
          and  oot.order_type_id = ooh.order_type_id
          and  oot.order_category_code in ('MIXED','RETURN')
          and  ced.interface_to_oe_flag = 'Y'
          and  ooh.sold_to_org_id = sr.account_id  -- swai: bug 5931926
          and  sr.incident_id = dr.incident_id;    -- swai: bug 5931926

        exception
        when no_data_found then
          l_add_to_order_id := null;
        end;

    -- swai: bug fix 6078829
    -- DOES NOT ADD TO SAME ORDER WITHIN SERVICE REQUEST AND REPAIR ORDER.
    -- Now that we allow auto-book of ship lines, uncommented SHIP code
    -- and updated query.
    ELSIF ( p_action_type = 'SHIP') THEN

        begin

          Select max(ced.order_header_id)
          into  l_add_to_order_id
          from  csd_repairs dr,
                cs_estimate_details ced,
                oe_order_headers_all ooh,
                oe_order_types_v oot,
                cs_incidents_all_b sr               -- swai: bug 5931926
          where dr.repair_line_id = p_repair_line_id
          and  ced.incident_id = dr.incident_id
          and  ced.order_header_id is not null
          and  ooh.open_flag = 'Y'
          and  nvl(ooh.cancelled_flag,'N') = 'N'
          and  ooh.header_id = ced.order_header_id
          and  ooh.transactional_curr_code = dr.currency_code
          and  (ooh.cust_po_number = nvl(dr.default_po_num,ooh.cust_po_number)
               or ooh.cust_po_number is null)
          and  oot.order_type_id = ooh.order_type_id
          and  oot.order_category_code in ('MIXED','ORDER')
          and  ced.interface_to_oe_flag = 'Y'
          and  ooh.sold_to_org_id = sr.account_id  -- swai: bug 5931926
          and  sr.incident_id = dr.incident_id;    -- swai: bug 5931926
        exception
        when no_data_found then
          l_add_to_order_id := null;
        end;

    END IF;

	  return l_add_to_order_id;

   END Get_sr_add_to_order;

-- bug fix for 4108369, End


--bug#7355526, nnadig changes
-- New function to validate the subinventory on the ship line.
-- The function will see if negative inventory is allowed, if yes, then
-- it will check for the availability of item/serial number in the inventory.

FUNCTION validate_subinventory_ship
   (
      p_org_id            IN NUMBER,
      p_sub_inv           IN VARCHAR2,
      p_inventory_item_id IN NUMBER,
      p_serial_number     IN VARCHAR2 )
   RETURN BOOLEAN
IS
   l_negative_inv_allowed  NUMBER;
   l_override_negative_qty NUMBER;
   l_exists                VARCHAR2(3) := 'Y';
   l_current_runtime_level NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   l_proc_level            NUMBER := FND_LOG.LEVEL_PROCEDURE;
   lc_mod_name             VARCHAR2(240) := 'csd.plsql.csd_process_util.validate_subinventory_ship';

BEGIN
  IF ( l_proc_level >= l_current_runtime_level ) then
     FND_LOG.STRING(l_proc_level,lc_mod_name||'begin',
                        'Entering validate_subinventory_ship');
     FND_LOG.STRING(l_proc_level,lc_mod_name||'parameters',
                      p_org_id||'-'||p_sub_inv||'-'||p_inventory_item_id||'-'||p_serial_number);

  END IF;
-- check for the inventory parameters in cache first.
   if g_negative_inventory.exists(p_org_id) then
      l_negative_inv_allowed  := g_negative_inventory(p_org_id);
   end if;
   if g_override_negative_qty.exists(p_org_id) then
      l_override_negative_qty := g_override_negative_qty(p_org_id);
   end if;
-- if its not found in cache, then find out these values and add it to
-- cache.
   IF l_negative_inv_allowed IS NULL THEN
      BEGIN
         SELECT negative_inv_receipt_code
         INTO l_negative_inv_allowed
         FROM mtl_parameters
         WHERE organization_id = p_org_id;

      EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RAISE;
      END;
      g_negative_inventory(p_org_id) := l_negative_inv_allowed;
   END IF;
   IF l_override_negative_qty IS NULL THEN
      l_override_negative_qty := fnd_profile.value('INV_OVERRIDE_NEG_FOR_BACKFLUSH');
      g_override_negative_qty(p_org_id) := l_override_negative_qty ;
   END IF;
-- if negative inventory is not allowed and the subinv is specified in the
-- product transaction, validate if the item is available in the subinv.
-- if subinv is null then default subinv is used as in shipping parameters.
   IF l_negative_inv_allowed = 2 AND l_override_negative_qty = 2 AND
      p_sub_inv IS NOT NULL THEN
      -- check if the item(serial_number) exist in the subinventory.
      -- if the item is serial controlled, then check for the availability of serial number.
      IF p_serial_number IS NULL OR p_serial_number = FND_API.G_MISS_CHAR THEN
         BEGIN
            SELECT 'Y'
            INTO l_exists
            FROM mtl_onhand_quantities_detail
            WHERE subinventory_code = p_sub_inv
            AND inventory_item_id   = p_inventory_item_id
            AND organization_id     = p_org_id
            AND rownum = 1;

         EXCEPTION
         WHEN no_data_found THEN
            l_exists := 'N';
         END;
      ELSE
         BEGIN
            SELECT 'Y'
            INTO l_exists
            FROM mtl_serial_numbers
            WHERE inventory_item_id       = p_inventory_item_id
            AND serial_number             = p_serial_number
            AND current_subinventory_code = p_sub_inv
            AND current_organization_id   = p_org_id;

         EXCEPTION
         WHEN no_data_found THEN
            l_exists := 'N';
         END;
      END IF;
   END IF;
   IF l_exists = 'Y' THEN
      RETURN true;
   ELSE
      RETURN false;
   END IF;
END validate_subinventory_ship;


-- bug#7355526, nnadig
-- new function to validate the order, order line for OM holds.
-- Parameters.
-- @p_action_type in Type of line (RMA OR SHIP)
-- @p_order_header_id in order header id for the line.
-- @p_order_line_id  in order line id for the line default is null.-- @x_entity_on_hold out Tells entity on hold H = header L = line.

FUNCTION validate_order_for_holds
              ( p_action_type     IN VARCHAR2,
                p_order_header_id IN NUMBER,
                p_order_line_id   IN NUMBER DEFAULT NULL)
                --x_entity_on_hold  OUT NOCOPY VARCHAR2 )
      RETURN BOOLEAN
IS
l_order_hold VARCHAR2(3) := 'N';
l_mod_name    VARCHAR2(2000) := 'csd.plsql.csd_process_pvt.update_product_txn';
l_statement_level  NUMBER := Fnd_Log.LEVEL_STATEMENT;
begin

  if p_action_type = 'RMA' then
-- if action type is RMA, then if the order header is on hold, booking
-- cannot happen, and hence autoreceiving will fail.
   BEGIN
      SELECT 'Y'
      INTO l_order_hold
      FROM    oe_order_headers_all oh
      WHERE   oh.header_id = p_order_header_id
      AND NVL(oh.booked_flag,'N') = 'N'
      AND  EXISTS
        (
                SELECT 'x'
                FROM    oe_order_holds_all oeh ,
                        oe_hold_sources_all ohs,
                        oe_hold_definitions od
                WHERE   oeh.header_id      = oh.header_id
                    AND NVL(oeh.released_flag,'N') <> 'Y'
                    AND oeh.line_id IS NULL
                    AND oeh.hold_source_id = ohs.hold_source_id
                    AND ohs.hold_id        = od.hold_id
                    AND od.activity_name IS NULL
        );
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
            NULL;
    END;

-- if order header or order line is on hold, shipping will fail.
elsif p_action_type = 'SHIP' then
begin
      SELECT holdexists
      INTO l_order_hold
      FROM (
      SELECT 'Y' holdexists
      FROM    oe_order_headers_all oh
      WHERE   oh.header_id = p_order_header_id
      AND  EXISTS
        (
                SELECT 'x'
                FROM    oe_order_holds_all oeh ,
                        oe_hold_sources_all ohs,
                        oe_hold_definitions od
                WHERE   oeh.header_id      = oh.header_id
                    AND NVL(oeh.released_flag,'N') <> 'Y'
                    AND oeh.line_id IS NULL
                    AND oeh.hold_source_id = ohs.hold_source_id
                    AND ohs.hold_id        = od.hold_id
                    AND od.activity_name IS NULL
        )

 union all

      SELECT 'Y' holdexists
      FROM    oe_order_headers_all oh
      WHERE   oh.header_id = p_order_header_id
      AND  EXISTS
        (
                SELECT 'x'
                FROM    oe_order_holds_all oeh ,
                        oe_hold_sources_all ohs,
                        oe_hold_definitions od
                WHERE   oeh.header_id      = oh.header_id
                    AND NVL(oeh.released_flag,'N') <> 'Y'
                    AND oeh.line_id = p_order_line_id
                    AND oeh.hold_source_id = ohs.hold_source_id
                    AND ohs.hold_id        = od.hold_id
                    AND od.activity_name IS NULL
        ) ) where rownum = 1;
 exception
  when no_data_found then
    null;
 end;

 end if;

if l_order_hold = 'Y' then
      return true;
else
      return false;
end if;

end validate_order_for_holds;
-- end bug#7355526, nnadig

END CSD_PROCESS_UTIL;

/
