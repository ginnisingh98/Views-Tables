--------------------------------------------------------
--  DDL for Package Body WSH_FREIGHT_COSTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_FREIGHT_COSTS_PVT" AS
/* $Header: WSHFCTHB.pls 120.2 2007/12/17 06:52:21 brana noship $ */
-- Package internal global variables
g_Return_Status         VARCHAR2(1);

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_FREIGHT_COSTS_PVT';
--

PROCEDURE Create_Freight_Cost(
  p_freight_cost_info          IN     Freight_Cost_Rec_Type
, x_rowid                         OUT NOCOPY  VARCHAR2
, x_freight_cost_id               OUT NOCOPY  NUMBER
, x_return_status                 OUT NOCOPY  VARCHAR2
)
IS
CURSOR C_Next_Freight_Cost_Id
IS
SELECT wsh_freight_costs_s.nextval
FROM sys.dual;


CURSOR c_new_row_id
IS
SELECT rowid
FROM wsh_freight_costs
WHERE freight_cost_id = x_freight_cost_id;


create_failure         EXCEPTION;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_FREIGHT_COST';
--
BEGIN
  --
  -- Debug Statements
  --
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
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  x_freight_cost_id := p_freight_cost_info.freight_cost_id;
  IF (x_freight_cost_id IS NULL) THEN
    LOOP
      OPEN C_Next_Freight_Cost_Id;
      FETCH C_Next_Freight_Cost_Id INTO x_freight_cost_id;
      CLOSE C_Next_Freight_Cost_Id;

      IF (x_freight_cost_id IS NOT NULL) THEN
        x_rowid := NULL;
        OPEN c_new_row_id;
        FETCH c_new_row_id INTO x_rowid;
        CLOSE c_new_row_id;

        IF (x_rowid IS NULL) THEN
          EXIT;
        END IF;
      ELSE
        EXIT;
      END IF;
    END LOOP;
  END IF;

  INSERT INTO wsh_freight_costs(
    freight_cost_id,
    freight_cost_type_id,
    unit_amount,
/* H Integration: datamodel changes wrudge uncommented 4 columns*/
    calculation_method,
    uom,
    quantity,
    total_amount,
    currency_code,
    conversion_date,
    conversion_rate,
    conversion_type_code,
    trip_id,
    stop_id,
    delivery_id,
    delivery_leg_id,
    delivery_detail_id,
    attribute_category,
    attribute1,
    attribute2,
    attribute3,
    attribute4,
    attribute5,
    attribute6,
    attribute7,
    attribute8,
    attribute9,
    attribute10,
    attribute11,
    attribute12,
    attribute13,
    attribute14,
    attribute15,
    creation_date,
    created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
    program_application_id,
    program_id,
    program_update_date,
    request_id,
/* H Integration: datamodel changes wrudge */
        pricing_list_header_id,
        pricing_list_line_id,
        applied_to_charge_id,
        charge_unit_value,
        charge_source_code,
        line_type_code,
        estimated_flag,
        commodity_category_id,
/* R12 new attributes */
        billable_quantity,
        billable_uom,
        billable_basis
    ) VALUES (
    x_freight_cost_id,
    p_freight_cost_info.freight_cost_type_id,
    p_freight_cost_info.unit_amount,
/* H Integration: datamodel changes wrudge uncommented 4 columns*/
    p_freight_cost_info.calculation_method,
    p_freight_cost_info.uom,
    p_freight_cost_info.quantity,
    p_freight_cost_info.total_amount,
    p_freight_cost_info.currency_code,
    p_freight_cost_info.conversion_date,
    p_freight_cost_info.conversion_rate,
    p_freight_cost_info.conversion_type_code,
    p_freight_cost_info.trip_id,
    p_freight_cost_info.stop_id,
    p_freight_cost_info.delivery_id,
    p_freight_cost_info.delivery_leg_id,
    p_freight_cost_info.delivery_detail_id,
    p_freight_cost_info.attribute_category,
    p_freight_cost_info.attribute1,
    p_freight_cost_info.attribute2,
    p_freight_cost_info.attribute3,
    p_freight_cost_info.attribute4,
    p_freight_cost_info.attribute5,
    p_freight_cost_info.attribute6,
    p_freight_cost_info.attribute7,
    p_freight_cost_info.attribute8,
    p_freight_cost_info.attribute9,
    p_freight_cost_info.attribute10,
    p_freight_cost_info.attribute11,
    p_freight_cost_info.attribute12,
    p_freight_cost_info.attribute13,
    p_freight_cost_info.attribute14,
    p_freight_cost_info.attribute15,
    p_freight_cost_info.creation_date,
    p_freight_cost_info.created_by,
    p_freight_cost_info.last_update_date,
    p_freight_cost_info.last_updated_by,
    p_freight_cost_info.last_update_login,
    p_freight_cost_info.program_application_id,
    p_freight_cost_info.program_id,
    p_freight_cost_info.program_update_date,
    p_freight_cost_info.request_id,
/* H Integration: datamodel changes wrudge */
    p_freight_cost_info.pricing_list_header_id,
    p_freight_cost_info.pricing_list_line_id,
    p_freight_cost_info.applied_to_charge_id,
    p_freight_cost_info.charge_unit_value,
    p_freight_cost_info.charge_source_code,
    p_freight_cost_info.line_type_code,
    p_freight_cost_info.estimated_flag,
    p_freight_cost_info.commodity_category_id,
/* R12 new attributes */
    p_freight_cost_info.billable_quantity,
    p_freight_cost_info.billable_uom,
    p_freight_cost_info.billable_basis
  ) RETURNING rowid INTO x_rowid;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
   EXCEPTION
    WHEN create_failure THEN
      wsh_util_core.default_handler('WSH_FREIGHT_COSTS_PVT.CREATE_FREIGHT_COST');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'CREATE_FAILURE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:CREATE_FAILURE');
END IF;
--
END Create_Freight_Cost;

PROCEDURE Update_Freight_Cost(
  p_rowid                      IN     VARCHAR2
, p_freight_cost_info         IN     Freight_Cost_Rec_Type
, x_return_status                 OUT NOCOPY  VARCHAR2
)
IS

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_FREIGHT_COST';
--
BEGIN

   --
   -- Debug Statements
   --
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
       WSH_DEBUG_SV.log(l_module_name,'P_ROWID',P_ROWID);
           WSH_DEBUG_SV.log(l_module_name,'freight_cost_id       ',p_freight_cost_info.freight_cost_id);
     WSH_DEBUG_SV.log(l_module_name,'freight_cost_type_id      ',p_freight_cost_info.freight_cost_type_id);
     WSH_DEBUG_SV.log(l_module_name,'unit_amount               ',p_freight_cost_info.unit_amount);
     WSH_DEBUG_SV.log(l_module_name,'calculation_method        ',p_freight_cost_info.calculation_method);
     WSH_DEBUG_SV.log(l_module_name,'uom                       ',p_freight_cost_info.uom);
     WSH_DEBUG_SV.log(l_module_name,'quantity                  ',p_freight_cost_info.quantity);
     WSH_DEBUG_SV.log(l_module_name,'total_amount              ',p_freight_cost_info.total_amount);
     WSH_DEBUG_SV.log(l_module_name,'currency_code             ',p_freight_cost_info.currency_code);
     WSH_DEBUG_SV.log(l_module_name,'conversion_date           ',p_freight_cost_info.conversion_date);
     WSH_DEBUG_SV.log(l_module_name,'conversion_rate           ',p_freight_cost_info.conversion_rate);
     WSH_DEBUG_SV.log(l_module_name,'conversion_type_code      ',p_freight_cost_info.conversion_type_code);
     WSH_DEBUG_SV.log(l_module_name,'trip_id                   ',p_freight_cost_info.trip_id);
     WSH_DEBUG_SV.log(l_module_name,'stop_id                   ',p_freight_cost_info.stop_id);
     WSH_DEBUG_SV.log(l_module_name,'delivery_id               ',p_freight_cost_info.delivery_id);
     WSH_DEBUG_SV.log(l_module_name,'delivery_leg_id           ',p_freight_cost_info.delivery_leg_id);
     WSH_DEBUG_SV.log(l_module_name,'delivery_detail_id        ',p_freight_cost_info.delivery_detail_id);
     WSH_DEBUG_SV.log(l_module_name,'attribute_category        ',p_freight_cost_info.attribute_category);
     WSH_DEBUG_SV.log(l_module_name,'attribute1                ',p_freight_cost_info.attribute1);
     WSH_DEBUG_SV.log(l_module_name,'attribute2                ',p_freight_cost_info.attribute2);
     WSH_DEBUG_SV.log(l_module_name,'attribute3                ',p_freight_cost_info.attribute3);
     WSH_DEBUG_SV.log(l_module_name,'attribute4                ',p_freight_cost_info.attribute4);
     WSH_DEBUG_SV.log(l_module_name,'attribute5                ',p_freight_cost_info.attribute5);
     WSH_DEBUG_SV.log(l_module_name,'attribute6                ',p_freight_cost_info.attribute6);
     WSH_DEBUG_SV.log(l_module_name,'attribute7                ',p_freight_cost_info.attribute7);
     WSH_DEBUG_SV.log(l_module_name,'attribute8                ',p_freight_cost_info.attribute8);
     WSH_DEBUG_SV.log(l_module_name,'attribute9                ',p_freight_cost_info.attribute9);
     WSH_DEBUG_SV.log(l_module_name,'attribute10               ',p_freight_cost_info.attribute10);
     WSH_DEBUG_SV.log(l_module_name,'attribute11               ',p_freight_cost_info.attribute11);
     WSH_DEBUG_SV.log(l_module_name,'attribute12               ',p_freight_cost_info.attribute12);
     WSH_DEBUG_SV.log(l_module_name,'attribute13               ',p_freight_cost_info.attribute13);
     WSH_DEBUG_SV.log(l_module_name,'attribute14               ',p_freight_cost_info.attribute14);
     WSH_DEBUG_SV.log(l_module_name,'attribute15               ',p_freight_cost_info.attribute15);
     WSH_DEBUG_SV.log(l_module_name,'creation_date             ',p_freight_cost_info.creation_date);
     WSH_DEBUG_SV.log(l_module_name,'created_by                ',p_freight_cost_info.created_by);
     WSH_DEBUG_SV.log(l_module_name,'last_update_date          ',p_freight_cost_info.last_update_date);
     WSH_DEBUG_SV.log(l_module_name,'last_updated_by           ',p_freight_cost_info.last_updated_by);
     WSH_DEBUG_SV.log(l_module_name,'last_update_login         ',p_freight_cost_info.last_update_login);
     WSH_DEBUG_SV.log(l_module_name,'program_application_id    ',p_freight_cost_info.program_application_id);
     WSH_DEBUG_SV.log(l_module_name,'program_id                ',p_freight_cost_info.program_id);
     WSH_DEBUG_SV.log(l_module_name,'program_update_date       ',p_freight_cost_info.program_update_date);
     WSH_DEBUG_SV.log(l_module_name,'request_id                ',p_freight_cost_info.request_id);
     WSH_DEBUG_SV.log(l_module_name,'pricing_list_header_id    ',p_freight_cost_info.pricing_list_header_id);
     WSH_DEBUG_SV.log(l_module_name,'pricing_list_line_id      ',p_freight_cost_info.pricing_list_line_id);
     WSH_DEBUG_SV.log(l_module_name,'applied_to_charge_id      ',p_freight_cost_info.applied_to_charge_id);
           WSH_DEBUG_SV.log(l_module_name,'charge_unit_value         ',p_freight_cost_info.charge_unit_value);
           WSH_DEBUG_SV.log(l_module_name,'charge_source_code        ',p_freight_cost_info.charge_source_code);
           WSH_DEBUG_SV.log(l_module_name,'line_type_code            ',p_freight_cost_info.line_type_code);
           WSH_DEBUG_SV.log(l_module_name,'estimated_flag            ',p_freight_cost_info.estimated_flag);
           WSH_DEBUG_SV.log(l_module_name,'estimated_flag            ',p_freight_cost_info.estimated_flag);
           WSH_DEBUG_SV.log(l_module_name,'commodity_category_id        ',p_freight_cost_info.commodity_category_id);
           WSH_DEBUG_SV.log(l_module_name,'billable_quantity',p_freight_cost_info.billable_quantity);
           WSH_DEBUG_SV.log(l_module_name,'billable_uom',p_freight_cost_info.billable_uom);
           WSH_DEBUG_SV.log(l_module_name,'billable_basis',p_freight_cost_info.billable_basis);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  UPDATE wsh_freight_costs
   SET
      freight_cost_id       = p_freight_cost_info.freight_cost_id,
     freight_cost_type_id      = p_freight_cost_info.freight_cost_type_id,
     unit_amount               = p_freight_cost_info.unit_amount,
/* H Integration: datamodel changes wrudge  uncommented 4 columns*/
     calculation_method        = p_freight_cost_info.calculation_method,
     uom                       = p_freight_cost_info.uom,
     quantity                  = p_freight_cost_info.quantity,
     total_amount              = p_freight_cost_info.total_amount,
     currency_code             = p_freight_cost_info.currency_code,
     conversion_date           = p_freight_cost_info.conversion_date,
     conversion_rate           = p_freight_cost_info.conversion_rate,
     conversion_type_code      = p_freight_cost_info.conversion_type_code,
     trip_id                   = p_freight_cost_info.trip_id,
     stop_id                   = p_freight_cost_info.stop_id,
     delivery_id               = p_freight_cost_info.delivery_id,
     delivery_leg_id           = p_freight_cost_info.delivery_leg_id,
     delivery_detail_id        = p_freight_cost_info.delivery_detail_id,
     attribute_category        = p_freight_cost_info.attribute_category,
     attribute1                = p_freight_cost_info.attribute1,
     attribute2                = p_freight_cost_info.attribute2,
     attribute3                = p_freight_cost_info.attribute3,
     attribute4                = p_freight_cost_info.attribute4,
     attribute5                = p_freight_cost_info.attribute5,
     attribute6                = p_freight_cost_info.attribute6,
     attribute7                = p_freight_cost_info.attribute7,
     attribute8                = p_freight_cost_info.attribute8,
     attribute9                = p_freight_cost_info.attribute9,
     attribute10               = p_freight_cost_info.attribute10,
     attribute11               = p_freight_cost_info.attribute11,
     attribute12               = p_freight_cost_info.attribute12,
     attribute13               = p_freight_cost_info.attribute13,
     attribute14               = p_freight_cost_info.attribute14,
     attribute15               = p_freight_cost_info.attribute15,
     last_update_date          = p_freight_cost_info.last_update_date,
     last_updated_by           = p_freight_cost_info.last_updated_by,
     last_update_login         = p_freight_cost_info.last_update_login,
     program_application_id    = p_freight_cost_info.program_application_id,
     program_id                = p_freight_cost_info.program_id,
     program_update_date       = p_freight_cost_info.program_update_date,
     request_id                = p_freight_cost_info.request_id,
/* H Integration: datamodel changes wrudge */
     pricing_list_header_id    = p_freight_cost_info.pricing_list_header_id,
     pricing_list_line_id      = p_freight_cost_info.pricing_list_line_id,
     applied_to_charge_id      = p_freight_cost_info.applied_to_charge_id,
           charge_unit_value         = p_freight_cost_info.charge_unit_value,
           charge_source_code        = p_freight_cost_info.charge_source_code,
           line_type_code            = p_freight_cost_info.line_type_code,
           estimated_flag            = p_freight_cost_info.estimated_flag,
           commodity_category_id            = p_freight_cost_info.commodity_category_id,
/* R12 new attributes */
     billable_quantity = p_freight_cost_info.billable_quantity,
     billable_uom      = p_freight_cost_info.billable_uom,
     billable_basis    = p_freight_cost_info.billable_basis
   WHERE freight_cost_id = p_freight_cost_info.freight_cost_id;

  IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
  WHEN OTHERS THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
     wsh_util_core.default_handler ('WSH_FREIGHT_COSTS_PVT.Update_Freight_Cost');
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                                             SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;
END Update_Freight_Cost;

PROCEDURE Lock_Freight_Cost(
  p_rowid                      IN     VARCHAR2
, p_freight_cost_info          IN     Freight_Cost_Rec_Type
)
IS

CURSOR lock_row IS
SELECT
    freight_cost_id,
    freight_cost_type_id,
    unit_amount,
/* H Integration: datamodel changes wrudge uncommented 4 columns*/
    calculation_method,
    uom,
    quantity,
    total_amount,
    currency_code,
    conversion_date,
    conversion_rate,
    conversion_type_code,
    trip_id,
    stop_id,
    delivery_id,
    delivery_leg_id,
    delivery_detail_id,
    attribute_category,
    attribute1,
    attribute2,
    attribute3,
    attribute4,
    attribute5,
    attribute6,
    attribute7,
    attribute8,
    attribute9,
    attribute10,
    attribute11,
    attribute12,
    attribute13,
    attribute14,
    attribute15,
    creation_date,
    created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
    program_application_id,
    program_id,
    program_update_date,
    request_id,
/* H Integration: datamodel changes wrudge */
        pricing_list_header_id,
        pricing_list_line_id,
        applied_to_charge_id,
        charge_unit_value,
        charge_source_code,
        line_type_code,
        estimated_flag,
        commodity_category_id,
/* R12 new attributes */
        billable_quantity,
        billable_uom,
        billable_basis
FROM wsh_freight_costs
WHERE rowid = p_rowid
FOR UPDATE OF freight_cost_id NOWAIT;

Recinfo lock_row%ROWTYPE;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_FREIGHT_COST';
--
BEGIN

   --
   -- Debug Statements
   --
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
       WSH_DEBUG_SV.log(l_module_name,'P_ROWID',P_ROWID);
   END IF;
   --
   OPEN lock_row;
   FETCH lock_row INTO Recinfo;

  IF (lock_row%NOTFOUND) THEN
     CLOSE lock_row;
           FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
    IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'FORM_RECORD_DELETED Error has occured',WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FORM_RECORD_DELETED');
          END IF;
     app_exception.raise_exception;
  END IF;

  CLOSE lock_row;
  IF (     (Recinfo.freight_cost_id = p_freight_cost_info.freight_cost_id)
     AND   (Recinfo.freight_cost_type_id = p_freight_cost_info.freight_cost_type_id)
/* H Integration: datamodel changes wrudge column is nullable */
     AND   (   (Recinfo.unit_amount = p_freight_cost_info.unit_amount)
                  or (Recinfo.unit_amount is null
                      and p_freight_cost_info.unit_amount is null))
/* H Integration: datamodel changes wrudge  enabled 4 nullable columns */
     AND   (   (Recinfo.calculation_method = p_freight_cost_info.calculation_method)
                  or (Recinfo.calculation_method is null
                      and p_freight_cost_info.calculation_method is null))
     AND   (   (Recinfo.uom = p_freight_cost_info.uom)
                  or (Recinfo.uom is null
                      and p_freight_cost_info.uom is null))
     AND   (   (Recinfo.quantity = p_freight_cost_info.quantity)
                  or (Recinfo.quantity is null
                      and p_freight_cost_info.quantity is null))
     AND   (   (Recinfo.total_amount = p_freight_cost_info.total_amount)
                  or (Recinfo.total_amount is null
                      and p_freight_cost_info.total_amount is null))
/* H Integration: datamodel changes wrudge  collumn is nullable*/
     AND   (   (Recinfo.currency_code = p_freight_cost_info.currency_code)
                  or (Recinfo.currency_code is null
                      and p_freight_cost_info.currency_code is null))
     AND   (  (Recinfo.conversion_date = p_freight_cost_info.conversion_date)
       OR ( (p_freight_cost_info.conversion_date IS NULL)
          AND (Recinfo.conversion_date IS NULL)))
     AND   (  (Recinfo.conversion_rate = p_freight_cost_info.conversion_rate)
       OR    (  (p_freight_cost_info.conversion_rate IS NULL)
          AND   (Recinfo.conversion_rate IS NULL)))
     AND   (  (Recinfo.conversion_type_code = p_freight_cost_info.conversion_type_code)
       OR    (  (p_freight_cost_info.conversion_type_code IS NULL)
          AND   (Recinfo.conversion_type_code IS NULL)))
     AND   (  (Recinfo.trip_id = p_freight_cost_info.trip_id)
       OR    (  (p_freight_cost_info.trip_id IS NULL)
          AND   (Recinfo.trip_id IS NULL)))

     AND   (  (Recinfo.stop_id = p_freight_cost_info.stop_id)
       OR    (  (p_freight_cost_info.stop_id IS NULL)
          AND   (Recinfo.stop_id IS NULL)))
     AND   (  (Recinfo.delivery_id = p_freight_cost_info.delivery_id)
       OR    (  (p_freight_cost_info.delivery_id IS NULL)
          AND   (Recinfo.delivery_id IS NULL)))
     AND   (  (Recinfo.delivery_leg_id = p_freight_cost_info.delivery_leg_id)
       OR    (  (p_freight_cost_info.delivery_leg_id IS NULL)
          AND   (Recinfo.delivery_leg_id IS NULL)))
     AND   (  (Recinfo.delivery_detail_id = p_freight_cost_info.delivery_detail_id)
       OR    (  (p_freight_cost_info.delivery_detail_id IS NULL)
          AND   (Recinfo.delivery_detail_id IS NULL)))
     AND   (  (Recinfo.attribute1 = p_freight_cost_info.attribute1)
       OR    (  (p_freight_cost_info.attribute1 IS NULL)
          AND   (Recinfo.attribute1 IS NULL)))
     AND   (  (Recinfo.attribute2 = p_freight_cost_info.attribute2)
       OR    (  (p_freight_cost_info.attribute2 IS NULL)
          AND   (Recinfo.attribute2 IS NULL)))
     AND   (  (Recinfo.attribute3 = p_freight_cost_info.attribute3)
       OR    (  (p_freight_cost_info.attribute3 IS NULL)
          AND   (Recinfo.attribute3 IS NULL)))
     AND   (  (Recinfo.attribute4 = p_freight_cost_info.attribute4)
       OR    (  (p_freight_cost_info.attribute4 IS NULL)
          AND   (Recinfo.attribute4 IS NULL)))
     AND   (  (Recinfo.attribute5 = p_freight_cost_info.attribute5)
       OR    (  (p_freight_cost_info.attribute5 IS NULL)
          AND   (Recinfo.attribute5 IS NULL)))
     AND   (  (Recinfo.attribute6 = p_freight_cost_info.attribute6)
       OR    (  (p_freight_cost_info.attribute6 IS NULL)
          AND   (Recinfo.attribute6 IS NULL)))
     AND   (  (Recinfo.attribute7 = p_freight_cost_info.attribute7)
       OR    (  (p_freight_cost_info.attribute7 IS NULL)
          AND   (Recinfo.attribute7 IS NULL)))
     AND   (  (Recinfo.attribute8 = p_freight_cost_info.attribute8)
       OR    (  (p_freight_cost_info.attribute8 IS NULL)
          AND   (Recinfo.attribute8 IS NULL)))
     AND   (  (Recinfo.attribute9 = p_freight_cost_info.attribute9)
        OR    (  (p_freight_cost_info.attribute9 IS NULL)
          AND   (Recinfo.attribute9 IS NULL)))
     AND   (  (Recinfo.attribute10 = p_freight_cost_info.attribute10)
       OR    (  (p_freight_cost_info.attribute10 IS NULL)
          AND   (Recinfo.attribute10 IS NULL)))
     AND   (  (Recinfo.attribute11 = p_freight_cost_info.attribute11)
       OR    (  (p_freight_cost_info.attribute11 IS NULL)
          AND   (Recinfo.attribute11 IS NULL)))
     AND   (  (Recinfo.attribute12 = p_freight_cost_info.attribute12)
       OR    (  (p_freight_cost_info.attribute12 IS NULL)
          AND   (Recinfo.attribute12 IS NULL)))
     AND   (  (Recinfo.attribute13 = p_freight_cost_info.attribute13)
       OR    (  (p_freight_cost_info.attribute13 IS NULL)
          AND   (Recinfo.attribute13 IS NULL)))
     AND   (  (Recinfo.attribute14 = p_freight_cost_info.attribute14)
       OR    (  (p_freight_cost_info.attribute14 IS NULL)
          AND   (Recinfo.attribute14 IS NULL)))
     AND   (  (Recinfo.attribute15 = p_freight_cost_info.attribute15)
       OR    (  (p_freight_cost_info.attribute15 IS NULL)
          AND   (Recinfo.attribute15 IS NULL)))
     AND   (Recinfo.creation_date = p_freight_cost_info.creation_date)
     AND   (Recinfo.created_by = p_freight_cost_info.created_by)
     AND   (Recinfo.last_update_date = p_freight_cost_info.last_update_date)
     AND   (Recinfo.last_update_login = p_freight_cost_info.last_update_login)
/* H Integration: datamodel changes wrudge */
           AND   (  (Recinfo.pricing_list_header_id = p_freight_cost_info.pricing_list_header_id)
                  or (Recinfo.pricing_list_header_id is NULL
                      and p_freight_cost_info.pricing_list_header_id is NULL))
           AND   (  (Recinfo.pricing_list_line_id = p_freight_cost_info.pricing_list_line_id)
                  or (Recinfo.pricing_list_line_id is NULL
                      and p_freight_cost_info.pricing_list_line_id is NULL))
           AND   (  (Recinfo.applied_to_charge_id = p_freight_cost_info.applied_to_charge_id)
                  or (Recinfo.applied_to_charge_id is NULL
                      and p_freight_cost_info.applied_to_charge_id is NULL))
           AND   (  (Recinfo.charge_unit_value = p_freight_cost_info.charge_unit_value)
                  or (Recinfo.charge_unit_value is NULL
                      and p_freight_cost_info.charge_unit_value is NULL))
           AND   (  (Recinfo.charge_source_code = p_freight_cost_info.charge_source_code)
                  or (Recinfo.charge_source_code is NULL
                      and p_freight_cost_info.charge_source_code is NULL))
           AND   (  (Recinfo.line_type_code = p_freight_cost_info.line_type_code)
                  or (Recinfo.line_type_code is NULL
                      and p_freight_cost_info.line_type_code is NULL))
           AND   (  (Recinfo.estimated_flag = p_freight_cost_info.estimated_flag)
                  or (Recinfo.estimated_flag is NULL
                      and p_freight_cost_info.estimated_flag is NULL))
           AND   (  (Recinfo.commodity_category_id = p_freight_cost_info.commodity_category_id)
                  or (Recinfo.commodity_category_id is NULL
                      and p_freight_cost_info.commodity_category_id is NULL))
/* R12 new attributes */
           AND   (  (Recinfo.billable_quantity = p_freight_cost_info.billable_quantity)
                  or (Recinfo.billable_quantity is NULL
                      and p_freight_cost_info.billable_quantity is NULL))
           AND   (  (Recinfo.billable_uom = p_freight_cost_info.billable_uom)
                  or (Recinfo.billable_uom is NULL
                      and p_freight_cost_info.billable_uom is NULL))
           AND   (  (Recinfo.billable_basis = p_freight_cost_info.billable_basis)
                  or (Recinfo.billable_basis is NULL
                      and p_freight_cost_info.billable_basis is NULL))
     ) THEN
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
     RETURN;
  ELSE
     FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'FORM_RECORD_DELETED Error has occured',WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FORM_RECORD_CHANGED');
          END IF;
     app_exception.raise_exception;
  END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
   WHEN others THEN

      -- Is this necessary?  Does PL/SQL automatically close a
      -- cursor when it goes out of scope?

      if (lock_row%ISOPEN) then
   close lock_row;
      end if;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
      raise;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
END Lock_Freight_Cost;

PROCEDURE Delete_Freight_Cost(
  p_rowid                                   IN     VARCHAR2
, p_freight_cost_id                         IN     NUMBER
, x_return_status                     OUT NOCOPY  VARCHAR2
)
IS
CURSOR C_Get_Freight_cost_id
IS
SELECT freight_cost_id
FROM wsh_freight_costs
WHERE rowid = p_rowid;

l_freight_cost_id                   NUMBER;
others                                       EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELETE_FREIGHT_COST';
--
BEGIN
   --
   -- Debug Statements
   --
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
       WSH_DEBUG_SV.log(l_module_name,'P_ROWID',P_ROWID);
       WSH_DEBUG_SV.log(l_module_name,'P_FREIGHT_COST_ID',P_FREIGHT_COST_ID);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   l_freight_cost_id := p_freight_cost_id;

  IF (p_rowid IS NOT NULL) THEN
    OPEN C_Get_freight_cost_id;
    FETCH C_get_freight_cost_id INTO l_freight_cost_id;
    CLOSE C_Get_Freight_cost_id;
   END IF;

   IF (l_freight_cost_id IS NOT NULL) THEN
    DELETE FROM wsh_freight_costs
    WHERE freight_cost_id = p_freight_cost_id;
  ELSE
    RAISE others;
   END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
   EXCEPTION
    WHEN others THEN
      wsh_util_core.default_handler('WSH_FREIGHT_COSTS_PVT.DELETE_FREIGHT_COST');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Delete_Freight_Cost;


PROCEDURE Split_Freight_Cost(
  p_from_freight_cost_id                  IN   NUMBER
, x_new_freight_cost_id                     OUT NOCOPY     NUMBER
, p_new_delivery_detail_id              IN    NUMBER
, p_requested_quantity                  IN    NUMBER
, p_split_requested_quantity              IN    NUMBER
, x_return_status                           OUT NOCOPY  VARCHAR2
) IS



CURSOR c_freight_cost ( c_freight_cost_id NUMBER ) IS
-- Changed for Bug# 3330869
-- SELECT *
SELECT
  FREIGHT_COST_TYPE_ID,
  UNIT_AMOUNT,
  CURRENCY_CODE,
  CALCULATION_METHOD,
  UOM,
  QUANTITY,
  CONVERSION_DATE,
  CONVERSION_RATE,
  CONVERSION_TYPE_CODE,
  TRIP_ID,
  STOP_ID,
  DELIVERY_ID,
  DELIVERY_LEG_ID,
  ATTRIBUTE_CATEGORY,
  ATTRIBUTE1,
  ATTRIBUTE2,
  ATTRIBUTE3,
  ATTRIBUTE4,
  ATTRIBUTE5,
  ATTRIBUTE6,
  ATTRIBUTE7,
  ATTRIBUTE8,
  ATTRIBUTE9,
  ATTRIBUTE10,
  ATTRIBUTE11,
  ATTRIBUTE12,
  ATTRIBUTE13,
  ATTRIBUTE14,
  ATTRIBUTE15,
  CREATED_BY,
  LAST_UPDATED_BY,
  LAST_UPDATE_LOGIN,
  PROGRAM_APPLICATION_ID,
  PROGRAM_ID,
  PROGRAM_UPDATE_DATE,
  REQUEST_ID,
  PRICING_LIST_HEADER_ID,
  PRICING_LIST_LINE_ID,
  APPLIED_TO_CHARGE_ID,
  CHARGE_UNIT_VALUE,
  CHARGE_SOURCE_CODE,
  LINE_TYPE_CODE,
  ESTIMATED_FLAG,
  COMMODITY_CATEGORY_ID
FROM WSH_FREIGHT_COSTS
WHERE FREIGHT_COST_ID = c_freight_cost_id FOR UPDATE;

l_from_freight_cost_rec     c_freight_cost%ROWTYPE;
l_new_freight_cost_rec    Freight_Cost_Rec_Type;
l_new_unit_amount       NUMBER := 0;
l_round_unit_amount     NUMBER := 0;
l_remained_unit_amount    NUMBER := 0;
l_rowid             VARCHAR2(30) := NULL;
l_return_status       VARCHAR2(1) := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
l_freight_cost_id       NUMBER := 0;

WSH_FC_NOT_FOUND        EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SPLIT_FREIGHT_COST';
--
BEGIN

--
-- Debug Statements
--
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
    WSH_DEBUG_SV.log(l_module_name,'P_FROM_FREIGHT_COST_ID',P_FROM_FREIGHT_COST_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_NEW_DELIVERY_DETAIL_ID',P_NEW_DELIVERY_DETAIL_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_REQUESTED_QUANTITY',P_REQUESTED_QUANTITY);
    WSH_DEBUG_SV.log(l_module_name,'P_SPLIT_REQUESTED_QUANTITY',P_SPLIT_REQUESTED_QUANTITY);
END IF;
--
x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;



OPEN c_freight_cost( p_from_freight_cost_id);
FETCH c_freight_cost INTO l_from_freight_cost_rec;
IF c_freight_cost%NOTFOUND THEN
  RAISE WSH_FC_NOT_FOUND;
END IF;

SELECT wsh_freight_costs_s.nextval INTO l_freight_cost_id FROM sys.dual;

l_new_freight_cost_rec.FREIGHT_COST_ID := l_freight_cost_id;
l_new_freight_cost_rec.FREIGHT_COST_TYPE_ID := l_from_freight_cost_rec.FREIGHT_COST_TYPE_ID ;
l_new_unit_amount := l_from_freight_cost_rec.UNIT_AMOUNT *
              p_split_requested_quantity / p_requested_quantity;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_FC_INTERFACE_PKG.ROUND_COST_AMOUNT',WSH_DEBUG_SV.C_PROC_LEVEL);
END IF;
--
WSH_FC_INTERFACE_PKG.Round_Cost_Amount(l_new_unit_amount, l_from_freight_cost_rec.CURRENCY_CODE, l_round_unit_amount, l_return_status);
-- round the unit_amount
l_remained_unit_amount := l_from_freight_cost_rec.UNIT_AMOUNT - l_round_unit_amount;

l_new_freight_cost_rec.UNIT_AMOUNT := l_round_unit_amount ;
l_new_freight_cost_rec.CALCULATION_METHOD := l_from_freight_cost_rec.CALCULATION_METHOD ;
l_new_freight_cost_rec.UOM := l_from_freight_cost_rec.UOM ;
l_new_freight_cost_rec.QUANTITY := l_from_freight_cost_rec.QUANTITY ;
l_new_freight_cost_rec.TOTAL_AMOUNT := l_round_unit_amount;
l_new_freight_cost_rec.CURRENCY_CODE := l_from_freight_cost_rec.CURRENCY_CODE ;
l_new_freight_cost_rec.CONVERSION_DATE := l_from_freight_cost_rec.CONVERSION_DATE ;
l_new_freight_cost_rec.CONVERSION_RATE := l_from_freight_cost_rec.CONVERSION_RATE ;
l_new_freight_cost_rec.CONVERSION_TYPE_CODE := l_from_freight_cost_rec.CONVERSION_TYPE_CODE ;
l_new_freight_cost_rec.TRIP_ID := l_from_freight_cost_rec.TRIP_ID ;
l_new_freight_cost_rec.STOP_ID := l_from_freight_cost_rec.STOP_ID ;
l_new_freight_cost_rec.DELIVERY_ID := l_from_freight_cost_rec.DELIVERY_ID ;
l_new_freight_cost_rec.DELIVERY_LEG_ID := l_from_freight_cost_rec.DELIVERY_LEG_ID ;
l_new_freight_cost_rec.DELIVERY_DETAIL_ID := p_new_delivery_detail_id ;
l_new_freight_cost_rec.ATTRIBUTE_CATEGORY := l_from_freight_cost_rec.ATTRIBUTE_CATEGORY ;
l_new_freight_cost_rec.ATTRIBUTE1 := l_from_freight_cost_rec.ATTRIBUTE1 ;
l_new_freight_cost_rec.ATTRIBUTE2 := l_from_freight_cost_rec.ATTRIBUTE2 ;
l_new_freight_cost_rec.ATTRIBUTE3 := l_from_freight_cost_rec.ATTRIBUTE3 ;
l_new_freight_cost_rec.ATTRIBUTE4 := l_from_freight_cost_rec.ATTRIBUTE4 ;
l_new_freight_cost_rec.ATTRIBUTE5 := l_from_freight_cost_rec.ATTRIBUTE5 ;
l_new_freight_cost_rec.ATTRIBUTE6 := l_from_freight_cost_rec.ATTRIBUTE6 ;
l_new_freight_cost_rec.ATTRIBUTE7 := l_from_freight_cost_rec.ATTRIBUTE7 ;
l_new_freight_cost_rec.ATTRIBUTE8 := l_from_freight_cost_rec.ATTRIBUTE8 ;
l_new_freight_cost_rec.ATTRIBUTE9 := l_from_freight_cost_rec.ATTRIBUTE9 ;
l_new_freight_cost_rec.ATTRIBUTE10 := l_from_freight_cost_rec.ATTRIBUTE10 ;
l_new_freight_cost_rec.ATTRIBUTE11 := l_from_freight_cost_rec.ATTRIBUTE11 ;
l_new_freight_cost_rec.ATTRIBUTE12 := l_from_freight_cost_rec.ATTRIBUTE12 ;
l_new_freight_cost_rec.ATTRIBUTE13 := l_from_freight_cost_rec.ATTRIBUTE13 ;
l_new_freight_cost_rec.ATTRIBUTE14 := l_from_freight_cost_rec.ATTRIBUTE14 ;
l_new_freight_cost_rec.ATTRIBUTE15 := l_from_freight_cost_rec.ATTRIBUTE15 ;
l_new_freight_cost_rec.CREATION_DATE := sysdate;
l_new_freight_cost_rec.CREATED_BY := l_from_freight_cost_rec.CREATED_BY ;
l_new_freight_cost_rec.LAST_UPDATE_DATE := sysdate;
l_new_freight_cost_rec.LAST_UPDATED_BY := l_from_freight_cost_rec.LAST_UPDATED_BY ;
l_new_freight_cost_rec.LAST_UPDATE_LOGIN := l_from_freight_cost_rec.LAST_UPDATE_LOGIN ;
l_new_freight_cost_rec.PROGRAM_APPLICATION_ID := l_from_freight_cost_rec.PROGRAM_APPLICATION_ID ;
l_new_freight_cost_rec.PROGRAM_ID := l_from_freight_cost_rec.PROGRAM_ID ;
l_new_freight_cost_rec.PROGRAM_UPDATE_DATE := l_from_freight_cost_rec.PROGRAM_UPDATE_DATE ;
l_new_freight_cost_rec.REQUEST_ID := l_from_freight_cost_rec.REQUEST_ID ;
/* H Integration: datamodel changes wrudge  */
l_new_freight_cost_rec.PRICING_LIST_HEADER_ID := l_from_freight_cost_rec.pricing_list_header_id ;
l_new_freight_cost_rec.PRICING_LIST_LINE_ID   := l_from_freight_cost_rec.pricing_list_line_id ;
l_new_freight_cost_rec.APPLIED_TO_CHARGE_ID   := l_from_freight_cost_rec.applied_to_charge_id ;
/* H Integration:  Open issue:  how does FTE want freight cost record split? */
l_new_freight_cost_rec.CHARGE_UNIT_VALUE      := l_from_freight_cost_rec.charge_unit_value ;
l_new_freight_cost_rec.CHARGE_SOURCE_CODE     := l_from_freight_cost_rec.charge_source_code ;
l_new_freight_cost_rec.LINE_TYPE_CODE         := l_from_freight_cost_rec.line_type_code ;
l_new_freight_cost_rec.ESTIMATED_FLAG         := l_from_freight_cost_rec.estimated_flag ;
l_new_freight_cost_rec.commodity_category_id         := l_from_freight_cost_rec.commodity_category_id ;
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Create_Freight_Cost',WSH_DEBUG_SV.C_PROC_LEVEL);
END IF;
Create_Freight_Cost(
  p_freight_cost_info  => l_new_freight_cost_rec
, x_rowid              => l_rowid
, x_freight_cost_id    => l_freight_cost_id
, x_return_status      => l_return_status
);

IF l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
  UPDATE WSH_FREIGHT_COSTS
  SET UNIT_AMOUNT = l_remained_unit_amount
  WHERE CURRENT OF c_freight_cost;
ELSE
  x_return_status := l_return_status;
END IF;

CLOSE c_freight_cost;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION

WHEN WSH_FC_NOT_FOUND THEN
  wsh_util_core.default_handler('WSH_FREIGHT_COSTS_PVT.SPLIT_FREIGHT_COST');
  x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_FC_NOT_FOUND exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_FC_NOT_FOUND');
END IF;
--
END Split_Freight_Cost;

--This procedure needs to be removed as this is no longer used - post I.
--Waiting for STF changes before removing this.
--Replaced by another procedure with same name
PROCEDURE Get_Total_Freight_Cost(
  p_entity_level    IN VARCHAR2,
  p_entity_id       IN NUMBER,
  p_currency_code   IN VARCHAR2,
  x_total_amount    OUT  NOCOPY NUMBER ,
  x_return_status   OUT  NOCOPY VARCHAR2) IS

l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Get_Total_Freight_Cost';


Cursor freight_cost_at_delivery(c_delivery_id number) IS
SELECT unit_amount,
       currency_code,
       NVL(conversion_type_code, 'Corporate'),
       NVL(conversion_date, SYSDATE),
       conversion_rate
FROM wsh_freight_costs
WHERE delivery_id = c_delivery_id AND
      NVL(charge_source_code, 'MANUAL') IN ('PRICING_ENGINE','MANUAL') AND
      NVL(line_type_code, 'CHARGE') IN ('CHARGE', 'PRICE') AND
      freight_cost_type_id <> -1 AND
      unit_amount IS NOT NULL;

Cursor freight_cost_in_delivery(c_delivery_id number) IS
SELECT a.unit_amount,
       a.currency_code,
       NVL(conversion_type_code, 'Corporate'),
       NVL(conversion_date, SYSDATE),
       conversion_rate
FROM wsh_freight_costs a
WHERE a.delivery_detail_id in (
     SELECT c.delivery_detail_id
     FROM wsh_delivery_assignments_v b,
          wsh_delivery_details c
     WHERE b.delivery_id = c_delivery_id AND
           c.delivery_detail_id = b.delivery_detail_id AND
           c.released_status <> 'D' ) AND
     NVL(a.charge_source_code, 'MANUAL' ) = 'MANUAL' AND
     NVL(a.line_type_code, 'CHARGE') = 'CHARGE' AND
     a.freight_cost_type_id <> -1 AND
     a.unit_amount is NOT NULL;

l_freight_cost             NUMBER := 0;
l_currency_code            VARCHAR2(15) := NULL;
l_conversion_type_code     VARCHAR2(15) := NULL;
l_conversion_date          DATE;
l_conversion_rate          NUMBER;
l_total_amount             NUMBER := 0;
l_return_status            VARCHAR2(10) := NULL;
l_converted_amount         NUMBER := 0;
l_msg_data                 VARCHAR2(2000);
convert_amount_error       EXCEPTION;

BEGIN
  --
  -- Debug Statements
  --
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
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  x_total_amount := NULL;

  IF  p_entity_level  = 'Delivery' THEN
    OPEN freight_cost_at_delivery(p_entity_id);
    LOOP
      FETCH freight_cost_at_delivery INTO l_freight_cost,
                                          l_currency_code,
                                          l_conversion_type_code,
                                          l_conversion_date,
                                          l_conversion_rate;

      EXIT WHEN freight_cost_at_delivery%NOTFOUND ;
      Convert_Amount (
        p_from_currency     => l_currency_code,
        p_to_currency       => p_currency_code,
        p_conversion_date   => l_conversion_date,
        p_conversion_rate   => l_conversion_rate,
        p_conversion_type   => l_conversion_type_code,
        p_amount            => l_freight_cost,
        x_converted_amount  => l_converted_amount,
        x_return_status     => l_return_status) ;

      IF l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        l_total_amount := l_total_amount + NVL(l_converted_amount,0);
      ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
        l_total_amount := l_total_amount + NVL(l_converted_amount,0);
        IF x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        END IF;
      ELSE
        raise convert_amount_error;
      END IF;


    END LOOP;
    CLOSE freight_cost_at_delivery;

    OPEN freight_cost_in_delivery(p_entity_id);
    LOOP
      FETCH freight_cost_in_delivery INTO l_freight_cost,
                                          l_currency_code,
                                          l_conversion_type_code,
                                          l_conversion_date,
                                          l_conversion_rate;

      EXIT WHEN freight_cost_in_delivery%NOTFOUND ;
      Convert_Amount (
        p_from_currency     => l_currency_code,
        p_to_currency       => p_currency_code,
        p_conversion_date   => l_conversion_date,
        p_conversion_rate   => l_conversion_rate,
        p_conversion_type   => l_conversion_type_code,
        p_amount            => l_freight_cost,
        x_converted_amount  => l_converted_amount,
        x_return_status     => l_return_status) ;

      IF l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        l_total_amount := l_total_amount + NVL(l_converted_amount, 0);
      ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
        l_total_amount := l_total_amount + NVL(l_converted_amount,0);
        IF x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        END IF;
      ELSE
        raise convert_amount_error;
      END IF;
    END LOOP;

    CLOSE freight_cost_in_delivery;

    x_total_amount := l_total_amount;

  END IF;
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
   EXCEPTION

     WHEN convert_amount_error THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

       x_total_amount := NULL;
       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Get_Total_Freight_Cost exception has occured. No user rate specified.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:Get_Total_Freight_Cost FILURE');
       END IF;

     WHEN OTHERS THEN

        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

        x_total_amount := NULL;
        WSH_UTIL_CORE.Default_Handler('WSH_FREIGHT_COSTS_PVT.Get_Total_Freight_Cost');

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                                                SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;


END Get_Total_Freight_Cost;


--TL Rating
PROCEDURE Get_Detail_Freight_Cost(
  p_in_ids       IN wsh_util_core.id_tab_type,
  p_currency_code   IN VARCHAR2,
  x_detail_amount    OUT  NOCOPY NUMBER ,
  x_return_status   OUT  NOCOPY VARCHAR2) IS

l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Get_Detail_Freight_Cost';

Cursor freight_cost_at_detail(c_det_id NUMBER) IS
SELECT a.unit_amount,
       a.currency_code,
       NVL(conversion_type_code, 'Corporate'),
       NVL(conversion_date, SYSDATE),
       conversion_rate
FROM wsh_freight_costs a, wsh_delivery_details wdd
WHERE wdd.delivery_detail_id=c_det_id AND
      wdd.released_status <> 'D'  AND
     a.delivery_detail_id = wdd.delivery_detail_id AND
     NVL(a.charge_source_code, 'MANUAL') IN ('PRICING_ENGINE','MANUAL') AND
     NVL(a.line_type_code, 'CHARGE') IN ('CHARGE', 'PRICE') AND
     a.freight_cost_type_id <> -1 AND
     a.unit_amount > 0 ;

l_freight_cost             NUMBER:=0;
l_currency_code            VARCHAR2(15) := NULL;
l_conversion_type_code     VARCHAR2(15) := NULL;
l_conversion_date          DATE;
l_conversion_rate          NUMBER;
l_total_amount             NUMBER := 0;
l_return_status            VARCHAR2(10) := NULL;
l_converted_amount         NUMBER := 0;
l_msg_data                 VARCHAR2(2000);
convert_amount_error       EXCEPTION;
l_index NUMBER;
BEGIN
  --
  -- Debug Statements
  --
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
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  x_detail_amount := NULL;
  l_index:=p_in_ids.FIRST;
  WHILE l_index is not null LOOP
    OPEN freight_cost_at_detail(p_in_ids(l_index));
    LOOP
      FETCH freight_cost_at_detail INTO l_freight_cost,
                                          l_currency_code,
                                          l_conversion_type_code,
                                          l_conversion_date,
                                          l_conversion_rate;

      EXIT WHEN freight_cost_at_detail%NOTFOUND ;
      Convert_Amount (
        p_from_currency     => l_currency_code,
        p_to_currency       => p_currency_code,
        p_conversion_date   => l_conversion_date,
        p_conversion_rate   => l_conversion_rate,
        p_conversion_type   => l_conversion_type_code,
        p_amount            => l_freight_cost,
        x_converted_amount  => l_converted_amount,
        x_return_status     => l_return_status) ;

      IF l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        l_total_amount := l_total_amount + NVL(l_converted_amount,0);
      ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
        l_total_amount := l_total_amount + NVL(l_converted_amount,0);
        IF x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        END IF;
      ELSE
        raise convert_amount_error;
      END IF;
    END LOOP;
    CLOSE freight_cost_at_detail;

    l_index:=p_in_ids.next(l_index);
  END LOOP;

  x_detail_amount := l_total_amount;

  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'amounts detail: '||l_total_amount);
  END IF;

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
   EXCEPTION

     WHEN convert_amount_error THEN
       CLOSE freight_cost_at_detail;
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       x_detail_amount := NULL;
       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Get_Detail_Freight_Cost exception has occured. No user rate specified.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:Get_Detail_Freight_Cost FILURE');
       END IF;

     WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        x_detail_amount := NULL;
        WSH_UTIL_CORE.Default_Handler('WSH_FREIGHT_COSTS_PVT.Get_detail_Freight_Cost');
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;

END Get_Detail_Freight_Cost;

PROCEDURE Get_LPN_Freight_Cost(
  p_in_ids       IN wsh_util_core.id_tab_type,
  p_currency_code   IN VARCHAR2,
  x_main_lpn_amount OUT NOCOPY NUMBER, --to be used only if calling entity is LPN
  x_lpn_amount OUT NOCOPY NUMBER,
  x_detail_amount    OUT  NOCOPY NUMBER ,
  x_return_status   OUT  NOCOPY VARCHAR2) IS

l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Get_LPN_Freight_Cost';

CURSOR c_getchildren (p_detailid NUMBER) IS
SELECT     delivery_detail_id
FROM       wsh_delivery_assignments_v wda
WHERE      LEVEL                   <= 10
START WITH delivery_detail_id       = p_detailid
CONNECT BY PRIOR delivery_detail_id = parent_delivery_detail_id;

CURSOR c_iscontainer(p_detailid NUMBER) IS
select 'Y'
from wsh_delivery_details
where delivery_detail_id=p_detailid
and container_flag='Y';

l_dd_ids wsh_util_core.id_tab_type;
l_cont_ids wsh_util_core.id_tab_type;

l_freight_cost             NUMBER := 0;
l_currency_code            VARCHAR2(15) := NULL;
l_conversion_type_code     VARCHAR2(15) := NULL;
l_conversion_date          DATE;
l_conversion_rate          NUMBER;
l_total_amount             NUMBER := 0;
l_return_status            VARCHAR2(10) := NULL;
l_converted_amount         NUMBER := 0;
l_msg_data                 VARCHAR2(2000);
convert_amount_error       EXCEPTION;
details_freight_error       EXCEPTION;

l_detail_amount_temp NUMBER;
l_detail_amount NUMBER;
l_main_lpn_amount NUMBER;
l_lpn_amount NUMBER;

l_index NUMBER;
l_dummy VARCHAR2(1);
BEGIN
  --
  -- Debug Statements
  --
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
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  x_lpn_amount := NULL;
  x_detail_amount:=null;

  --get containers and loose items and call them separately

  l_index:=p_in_ids.FIRST;
  WHILE l_index is not null LOOP
    --get all children, check if they're containers
    FOR cur IN c_getchildren(p_in_ids(l_index)) LOOP
      OPEN c_iscontainer(cur.delivery_detail_id);
      FETCH c_iscontainer into l_dummy;
      IF c_iscontainer%NOTFOUND THEN
            l_dd_ids(l_dd_ids.COUNT+1):=cur.delivery_detail_id;
      ELSE
            l_cont_ids(l_cont_ids.COUNT+1):=cur.delivery_detail_id;
      END IF;
      CLOSE c_iscontainer;
    END LOOP;

    l_index:=p_in_ids.next(l_index);
  END LOOP;

  IF l_dd_ids is not null and l_dd_ids.COUNT>0 THEN
     get_detail_freight_cost(
       p_in_ids         => l_dd_ids,
       p_currency_code  => p_currency_code,
       x_detail_amount  => l_detail_amount ,
       x_return_status  => l_return_status);
      IF l_return_status NOT IN (WSH_UTIL_CORE.G_RET_STS_SUCCESS,WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
        raise details_freight_error;
      ELSIF l_return_status=WSH_UTIL_CORE.G_RET_STS_WARNING THEN
        x_return_status:=l_return_status;
      END IF;
  END IF;

  IF l_cont_ids is not null and l_cont_ids.COUNT>0 THEN
     get_detail_freight_cost(
       p_in_ids         => l_cont_ids,
       p_currency_code  => p_currency_code,
       x_detail_amount  => l_lpn_amount,
       x_return_status  => l_return_status);
      IF l_return_status NOT IN (WSH_UTIL_CORE.G_RET_STS_SUCCESS,WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
        raise details_freight_error;
      ELSIF l_return_status=WSH_UTIL_CORE.G_RET_STS_WARNING THEN
        x_return_status:=l_return_status;
      END IF;
  END IF;

  IF p_in_ids is not null and p_in_ids.COUNT>0 THEN
     get_detail_freight_cost(
       p_in_ids         => p_in_ids,
       p_currency_code  => p_currency_code,
       x_detail_amount  => l_main_lpn_amount,
       x_return_status  => l_return_status);
      IF l_return_status NOT IN (WSH_UTIL_CORE.G_RET_STS_SUCCESS,WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
        raise details_freight_error;
      ELSIF l_return_status=WSH_UTIL_CORE.G_RET_STS_WARNING THEN
        x_return_status:=l_return_status;
      END IF;
  END IF;

  x_main_lpn_amount:=l_main_lpn_amount;
  x_detail_amount := l_detail_amount;
  x_lpn_amount := l_lpn_amount;

  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'amounts main lpn, other lpn, detail: '||l_main_lpn_amount||', '||l_lpn_amount||', '||l_detail_amount);
  END IF;

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
   EXCEPTION
     WHEN details_freight_error THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       x_main_lpn_amount := NULL;
       x_lpn_amount := NULL;
       x_detail_amount := NULL;
       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Get_LPN_Freight_Cost exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:Get_LPN_Freight_Cost FILURE');
       END IF;
     WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        x_main_lpn_amount := NULL;
        x_lpn_amount := NULL;
        x_detail_amount := NULL;
        WSH_UTIL_CORE.Default_Handler('WSH_FREIGHT_COSTS_PVT.Get_LPN_Freight_Cost');
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;

END Get_LPN_Freight_Cost;


PROCEDURE Get_Delivery_Freight_Cost(
  p_in_ids       IN wsh_util_core.id_tab_type,
  p_currency_code   IN VARCHAR2,
  x_delivery_amount OUT NOCOPY NUMBER,
  x_lpn_amount OUT NOCOPY NUMBER,
  x_detail_amount    OUT  NOCOPY NUMBER ,
  x_return_status   OUT  NOCOPY VARCHAR2) IS

l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Get_Delivery_Freight_Cost';


Cursor freight_cost_at_delivery(c_delivery_id number) IS
SELECT unit_amount,
       currency_code,
       NVL(conversion_type_code, 'Corporate'),
       NVL(conversion_date, SYSDATE),
       conversion_rate
FROM wsh_freight_costs
WHERE delivery_id = c_delivery_id AND
      NVL(charge_source_code, 'MANUAL') IN ('PRICING_ENGINE','MANUAL') AND
      NVL(line_type_code, 'CHARGE') IN ('CHARGE', 'PRICE') AND
      freight_cost_type_id <> -1 AND
      unit_amount > 0 AND
      delivery_detail_id is null;

l_dd_ids wsh_util_core.id_tab_type;
l_cont_ids wsh_util_core.id_tab_type;


l_freight_cost             NUMBER := 0;
l_currency_code            VARCHAR2(15) := NULL;
l_conversion_type_code     VARCHAR2(15) := NULL;
l_conversion_date          DATE;
l_conversion_rate          NUMBER;
l_total_amount             NUMBER := 0;
l_return_status            VARCHAR2(10) := NULL;
l_converted_amount         NUMBER := 0;
l_msg_data                 VARCHAR2(2000);
convert_amount_error       EXCEPTION;
details_freight_error       EXCEPTION;

l_detail_amount_temp NUMBER;
l_detail_amount NUMBER;
l_lpn_amount NUMBER;
l_main_lpn_amount NUMBER;
l_index NUMBER;
-- bugfix 6692716 replaced bind variable l_container_flag_yes or no by 'Y' and 'N'
--l_container_flag_yes	varchar2(1) ;  -- BugFix3788678
--l_container_flag_no	varchar2(1) ;  -- BugFix3788678

cursor c_get_contindel(p_delid NUMBER) is
select wdd.delivery_detail_id
from wsh_delivery_assignments_v wda, wsh_delivery_details wdd
where wda.delivery_detail_id=wdd.delivery_detail_id
and wdd.container_flag= 'Y'
and wda.delivery_id=p_delid
and wda.parent_delivery_detail_id is null;

cursor c_get_ddindel(p_delid NUMBER) is
select wdd.delivery_detail_id
from wsh_delivery_assignments_v wda, wsh_delivery_details wdd
where wda.delivery_detail_id=wdd.delivery_detail_id
and wdd.container_flag=  'N'
and wda.delivery_id=p_delid
and wda.parent_delivery_detail_id is null;

BEGIN
  --
  -- Debug Statements
  --
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
  END IF;
  --
  --bugfix 6692716
  --l_container_flag_yes := 'Y';  -- BugFix3788678
  --l_container_flag_no := 'N';  -- BugFix3788678

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  x_delivery_amount := NULL;

  l_index:=p_in_ids.FIRST;
  WHILE l_index is not null LOOP
    OPEN freight_cost_at_delivery(p_in_ids(l_index));
    LOOP
      FETCH freight_cost_at_delivery INTO l_freight_cost,
                                          l_currency_code,
                                          l_conversion_type_code,
                                          l_conversion_date,
                                          l_conversion_rate;

      EXIT WHEN freight_cost_at_delivery%NOTFOUND ;
      Convert_Amount (
        p_from_currency     => l_currency_code,
        p_to_currency       => p_currency_code,
        p_conversion_date   => l_conversion_date,
        p_conversion_rate   => l_conversion_rate,
        p_conversion_type   => l_conversion_type_code,
        p_amount            => l_freight_cost,
        x_converted_amount  => l_converted_amount,
        x_return_status     => l_return_status) ;

      IF l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        l_total_amount := l_total_amount + NVL(l_converted_amount,0);
      ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
        l_total_amount := l_total_amount + NVL(l_converted_amount,0);
        IF x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        END IF;
      ELSE
        raise convert_amount_error;
      END IF;
    END LOOP;
    CLOSE freight_cost_at_delivery;

    --get containers and loose items and call them separately
    FOR cur IN c_get_contindel(p_in_ids(l_index)) LOOP
      l_cont_ids(l_cont_ids.COUNT+1):=cur.delivery_detail_id;
    END LOOP;

    FOR cur IN c_get_ddindel(p_in_ids(l_index)) LOOP
      l_dd_ids(l_dd_ids.COUNT+1):=cur.delivery_detail_id;
    END LOOP;

    l_index:=p_in_ids.next(l_index);
  END LOOP;

  IF l_dd_ids is not null and l_dd_ids.COUNT>0 THEN
     get_detail_freight_cost(
       p_in_ids         => l_dd_ids,
       p_currency_code  => p_currency_code,
       x_detail_amount  => l_detail_amount ,
       x_return_status  => l_return_status);
      IF l_return_status NOT IN (WSH_UTIL_CORE.G_RET_STS_SUCCESS,WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
        raise details_freight_error;
      ELSIF l_return_status=WSH_UTIL_CORE.G_RET_STS_WARNING THEN
        x_return_status:=l_return_status;
      END IF;
  END IF;

  IF l_cont_ids is not null and l_cont_ids.COUNT>0 THEN
     get_lpn_freight_cost(
       p_in_ids         => l_cont_ids,
       p_currency_code  => p_currency_code,
       x_detail_amount  => l_detail_amount_temp ,
       x_main_lpn_amount     => l_main_lpn_amount,
       x_lpn_amount     => l_lpn_amount,
       x_return_status  => l_return_status);
      IF l_return_status NOT IN (WSH_UTIL_CORE.G_RET_STS_SUCCESS,WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
        raise details_freight_error;
      ELSIF l_return_status=WSH_UTIL_CORE.G_RET_STS_WARNING THEN
        x_return_status:=l_return_status;
      END IF;
  END IF;

  l_detail_amount:=nvl(l_detail_amount,0)+nvl(l_detail_amount_temp,0);

  x_delivery_amount := l_total_amount;
  x_detail_amount := l_detail_amount;
  x_lpn_amount := l_lpn_amount;

  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'amounts del, lpn, detail: '||l_total_amount||', '||l_lpn_amount||', '||l_detail_amount);
  END IF;

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
   EXCEPTION
     WHEN details_freight_error THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       x_delivery_amount := NULL;
       x_lpn_amount := NULL;
       x_detail_amount := NULL;
       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Get_Delivery_Freight_Cost exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:Get_Delivery_Freight_Cost FILURE');
       END IF;
     WHEN convert_amount_error THEN
       CLOSE freight_cost_at_delivery;
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       x_delivery_amount := NULL;
       x_lpn_amount := NULL;
       x_detail_amount := NULL;
       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Get_Delivery_Freight_Cost exception has occured. No user rate specified.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:Get_Delivery_Freight_Cost FILURE');
       END IF;

     WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        x_delivery_amount := NULL;
       x_lpn_amount := NULL;
       x_detail_amount := NULL;
        WSH_UTIL_CORE.Default_Handler('WSH_FREIGHT_COSTS_PVT.Get_delivery_Freight_Cost');
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;

END Get_Delivery_Freight_Cost;

PROCEDURE Get_Stop_Freight_Cost(
  p_in_ids       IN wsh_util_core.id_tab_type,
  p_currency_code   IN VARCHAR2,
  x_stop_amount    OUT  NOCOPY NUMBER ,
  x_return_status   OUT  NOCOPY VARCHAR2) IS

l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Get_Stop_Freight_Cost';

Cursor freight_cost_at_stop(c_stop_id number) IS
SELECT freight_cost_id,
       unit_amount,
       currency_code,
       NVL(conversion_type_code, 'Corporate'),
       NVL(conversion_date, SYSDATE),
       conversion_rate
FROM wsh_freight_costs
WHERE stop_id = c_stop_id AND
      NVL(charge_source_code, 'MANUAL') IN ('PRICING_ENGINE','MANUAL') AND
      NVL(line_type_code, 'CHARGE') IN ('CHARGE', 'PRICE') AND
      freight_cost_type_id <> -1 AND
      unit_amount > 0
union
SELECT wfc.freight_cost_id,
       wfc.unit_amount,
       wfc.currency_code,
       NVL(wfc.conversion_type_code, 'Corporate'),
       NVL(wfc.conversion_date, SYSDATE),
       wfc.conversion_rate
FROM wsh_freight_costs wfc, wsh_freight_cost_types wfct
WHERE wfc.stop_id = c_stop_id AND
      NVL(wfc.charge_source_code, 'MANUAL') = 'PRICING_ENGINE' AND
      NVL(wfc.line_type_code, 'CHARGE') ='SUMMARY' AND
      wfc.freight_cost_type_id <> -1 AND
      wfc.unit_amount > 0 AND
      wfct.FREIGHT_COST_TYPE_ID = wfc.FREIGHT_COST_TYPE_ID  AND
      NOT (wfct.name='SUMMARY' and wfct.freight_cost_type_code='FTESUMMARY')
;

l_freight_cost             NUMBER:=0;
l_currency_code            VARCHAR2(15) := NULL;
l_conversion_type_code     VARCHAR2(15) := NULL;
l_conversion_date          DATE;
l_conversion_rate          NUMBER;
l_total_amount             NUMBER := 0;
l_return_status            VARCHAR2(10) := NULL;
l_converted_amount         NUMBER := 0;
l_msg_data                 VARCHAR2(2000);
l_freight_cost_id          NUMBER;

convert_amount_error       EXCEPTION;
l_index NUMBER;
BEGIN
  --
  -- Debug Statements
  --
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
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  x_stop_amount := NULL;
  l_index:=p_in_ids.FIRST;
  WHILE l_index is not null LOOP
    OPEN freight_cost_at_stop(p_in_ids(l_index));
    LOOP
      FETCH freight_cost_at_stop INTO     l_freight_cost_id,
                                          l_freight_cost,
                                          l_currency_code,
                                          l_conversion_type_code,
                                          l_conversion_date,
                                          l_conversion_rate;

      EXIT WHEN freight_cost_at_stop%NOTFOUND ;
      Convert_Amount (
        p_from_currency     => l_currency_code,
        p_to_currency       => p_currency_code,
        p_conversion_date   => l_conversion_date,
        p_conversion_rate   => l_conversion_rate,
        p_conversion_type   => l_conversion_type_code,
        p_amount            => l_freight_cost,
        x_converted_amount  => l_converted_amount,
        x_return_status     => l_return_status) ;

      IF l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        l_total_amount := l_total_amount + NVL(l_converted_amount,0);
      ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
        l_total_amount := l_total_amount + NVL(l_converted_amount,0);
        IF x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        END IF;
      ELSE
        raise convert_amount_error;
      END IF;


    END LOOP;
    CLOSE freight_cost_at_stop;

    l_index:=p_in_ids.next(l_index);
  END LOOP;

  x_stop_amount := l_total_amount;

  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'amounts  stop : '||l_total_amount);
  END IF;

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
   EXCEPTION

     WHEN convert_amount_error THEN
       CLOSE freight_cost_at_stop;
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       x_stop_amount := NULL;
       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Get_stop_Freight_Cost exception has occured. No user rate specified.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:Get_stop_Freight_Cost FILURE');
       END IF;

     WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        x_stop_amount := NULL;
        WSH_UTIL_CORE.Default_Handler('WSH_FREIGHT_COSTS_PVT.Get_stop_Freight_Cost');
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;

END Get_Stop_Freight_Cost;

PROCEDURE Get_Trip_Freight_Cost(
  p_in_ids       IN wsh_util_core.id_tab_type,
  p_currency_code   IN VARCHAR2,
  x_trip_amount OUT NOCOPY NUMBER,
  x_stop_amount OUT NOCOPY NUMBER,
  x_delivery_amount OUT NOCOPY NUMBER,
  x_lpn_amount OUT NOCOPY NUMBER,
  x_detail_amount    OUT  NOCOPY NUMBER ,
  x_return_status   OUT  NOCOPY VARCHAR2) IS

l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Get_Trip_Freight_Cost';

cursor c_get_stops(p_tripid NUMBER) is
select stop_id
from wsh_trip_stops
where trip_id=p_tripid;

cursor c_get_dels(p_tripid NUMBER) is
select delivery_id
from wsh_delivery_legs wdl, wsh_trip_stops wts
where wdl.pick_up_stop_id=wts.stop_id
and wts.trip_id=p_tripid;

Cursor freight_cost_at_trip(c_trip_id number) IS
SELECT freight_cost_id,
       unit_amount,
       currency_code,
       NVL(conversion_type_code, 'Corporate'),
       NVL(conversion_date, SYSDATE),
       conversion_rate
FROM wsh_freight_costs
WHERE trip_id = c_trip_id AND
      NVL(charge_source_code, 'MANUAL') IN ('PRICING_ENGINE','MANUAL') AND
      NVL(line_type_code, 'CHARGE') IN ('CHARGE', 'PRICE') AND
      freight_cost_type_id <> -1 AND
      unit_amount > 0
union
SELECT wfc.freight_cost_id,
       wfc.unit_amount,
       wfc.currency_code,
       NVL(wfc.conversion_type_code, 'Corporate'),
       NVL(wfc.conversion_date, SYSDATE),
       wfc.conversion_rate
FROM wsh_freight_costs wfc, wsh_freight_cost_types wfct
WHERE wfc.trip_id = c_trip_id AND
      NVL(wfc.charge_source_code, 'MANUAL') = 'PRICING_ENGINE' AND
      NVL(wfc.line_type_code, 'CHARGE') ='SUMMARY' AND
      wfc.freight_cost_type_id <> -1 AND
      wfc.unit_amount > 0 AND
      wfct.FREIGHT_COST_TYPE_ID = wfc.FREIGHT_COST_TYPE_ID  AND
      NOT (wfct.name='SUMMARY' and wfct.freight_cost_type_code='FTESUMMARY');
l_stop_ids wsh_util_core.id_tab_type;
l_del_ids wsh_util_core.id_tab_type;


l_freight_cost             NUMBER := 0;
l_currency_code            VARCHAR2(15) := NULL;
l_conversion_type_code     VARCHAR2(15) := NULL;
l_conversion_date          DATE;
l_conversion_rate          NUMBER;
l_total_amount             NUMBER := 0;
l_return_status            VARCHAR2(10) := NULL;
l_converted_amount         NUMBER := 0;
l_msg_data                 VARCHAR2(2000);
l_freight_cost_id          NUMBER;
convert_amount_error       EXCEPTION;
details_freight_error       EXCEPTION;

l_detail_amount_temp NUMBER;
l_detail_amount NUMBER;
l_lpn_amount NUMBER;
l_stop_amount NUMBER;
l_delivery_amount NUMBER;
l_index NUMBER;

BEGIN
  --
  -- Debug Statements
  --
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
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  x_trip_amount := NULL;
  x_stop_amount := NULL;
  x_delivery_amount := NULL;
  x_lpn_amount := NULL;
  x_detail_amount := NULL;

  l_index:=p_in_ids.FIRST;
  WHILE l_index is not null LOOP
    OPEN freight_cost_at_trip(p_in_ids(l_index));
    LOOP
      FETCH freight_cost_at_trip INTO     l_freight_cost_id,
                                          l_freight_cost,
                                          l_currency_code,
                                          l_conversion_type_code,
                                          l_conversion_date,
                                          l_conversion_rate;

      EXIT WHEN freight_cost_at_trip%NOTFOUND ;
      Convert_Amount (
        p_from_currency     => l_currency_code,
        p_to_currency       => p_currency_code,
        p_conversion_date   => l_conversion_date,
        p_conversion_rate   => l_conversion_rate,
        p_conversion_type   => l_conversion_type_code,
        p_amount            => l_freight_cost,
        x_converted_amount  => l_converted_amount,
        x_return_status     => l_return_status) ;

      IF l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        l_total_amount := l_total_amount + NVL(l_converted_amount,0);
      ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
        l_total_amount := l_total_amount + NVL(l_converted_amount,0);
        IF x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        END IF;
      ELSE
        raise convert_amount_error;
      END IF;
    END LOOP;
    CLOSE freight_cost_at_trip;

    --get stops and deliveries and call them separately
    FOR cur IN c_get_stops(p_in_ids(l_index)) LOOP
      l_stop_ids(l_stop_ids.COUNT+1):=cur.stop_id;
    END LOOP;

    FOR cur IN c_get_dels(p_in_ids(l_index)) LOOP
      l_del_ids(l_del_ids.COUNT+1):=cur.delivery_id;
    END LOOP;

    l_index:=p_in_ids.next(l_index);
  END LOOP;

  IF l_stop_ids is not null and l_stop_ids.COUNT>0 THEN
     get_stop_freight_cost(
       p_in_ids         => l_stop_ids,
       p_currency_code  => p_currency_code,
       x_stop_amount  => l_stop_amount ,
       x_return_status  => l_return_status);
      IF l_return_status NOT IN (WSH_UTIL_CORE.G_RET_STS_SUCCESS,WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
        raise details_freight_error;
      ELSIF l_return_status=WSH_UTIL_CORE.G_RET_STS_WARNING THEN
        x_return_status:=l_return_status;
      END IF;
  END IF;

  IF l_del_ids is not null and l_del_ids.COUNT>0 THEN
     get_delivery_freight_cost(
       p_in_ids         => l_del_ids,
       p_currency_code  => p_currency_code,
       x_detail_amount  => l_detail_amount ,
       x_lpn_amount     => l_lpn_amount,
       x_delivery_amount=> l_delivery_amount,
       x_return_status  => l_return_status);
      IF l_return_status NOT IN (WSH_UTIL_CORE.G_RET_STS_SUCCESS,WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
        raise details_freight_error;
      ELSIF l_return_status=WSH_UTIL_CORE.G_RET_STS_WARNING THEN
        x_return_status:=l_return_status;
      END IF;
  END IF;

  x_delivery_amount := l_delivery_amount;
  x_trip_amount:=l_total_amount;
  x_stop_amount:=l_stop_amount;
  x_detail_amount := l_detail_amount;
  x_lpn_amount := l_lpn_amount;

  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'amounts trip, stop, del, lpn, detail: '||l_total_amount||', '||l_stop_amount||', '||l_delivery_amount||', '||l_lpn_amount||', '||l_detail_amount);
  END IF;

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
   EXCEPTION
     WHEN details_freight_error THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        x_trip_amount := NULL;
       x_delivery_amount := NULL;
       x_stop_amount := NULL;
       x_lpn_amount := NULL;
       x_detail_amount := NULL;
       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Get_Trip_Freight_Cost exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:Get_Trip_Freight_Cost FILURE');
       END IF;
     WHEN convert_amount_error THEN
       CLOSE freight_cost_at_trip;
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        x_trip_amount := NULL;
       x_stop_amount := NULL;
       x_delivery_amount := NULL;
       x_lpn_amount := NULL;
       x_detail_amount := NULL;
       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Get_Trip_Freight_Cost exception has occured. No user rate specified.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:Get_Trip_Freight_Cost FILURE');
       END IF;

     WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        x_trip_amount := NULL;
       x_stop_amount := NULL;
        x_delivery_amount := NULL;
       x_lpn_amount := NULL;
       x_detail_amount := NULL;
        WSH_UTIL_CORE.Default_Handler('WSH_FREIGHT_COSTS_PVT.Get_Trip_Freight_Cost');
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;

END Get_Trip_Freight_Cost;


--TL Rating spec changes
--changed to get the costs at the entity level plus the costs in any level below
--for example trip would return all the stops, deliveries, lpn's and detail cost
--lpn would return the lpn and the detail costs etc.

PROCEDURE Get_Total_Freight_Cost(
  p_entity_level    IN VARCHAR2,
  p_entity_id       IN NUMBER,
  p_currency_code   IN VARCHAR2,
  x_detail_amount    OUT  NOCOPY NUMBER ,
  x_lpn_amount    OUT  NOCOPY NUMBER ,
  x_main_lpn_amount    OUT  NOCOPY NUMBER, --to be used only for LPN
  x_delivery_amount    OUT  NOCOPY NUMBER ,
  x_stop_amount    OUT  NOCOPY NUMBER ,
  x_trip_amount    OUT  NOCOPY NUMBER ,
  x_return_status   OUT  NOCOPY VARCHAR2) IS

l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Get_Total_Freight_Cost';

l_trip_amount             NUMBER;
l_stop_amount             NUMBER;
l_delivery_amount             NUMBER;
l_main_lpn_amount             NUMBER;
l_lpn_amount             NUMBER;
l_detail_amount             NUMBER;
l_in_ids wsh_util_core.id_tab_type;

l_return_status            VARCHAR2(10) := NULL;
l_msg_data                 VARCHAR2(2000);
total_freight_error       EXCEPTION;
l_c_delivery               CONSTANT VARCHAR2(30):= 'DELIVERY';
l_c_stop                   CONSTANT VARCHAR2(30):= 'STOP';
l_c_trip                   CONSTANT VARCHAR2(30):= 'TRIP';
l_c_container              CONSTANT VARCHAR2(30):= 'CONTAINER';
l_c_line                   CONSTANT VARCHAR2(30):= 'LINE';

BEGIN
  --
  -- Debug Statements
  --
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
      WSH_DEBUG_SV.log(l_module_name,'Entity, entity_id : '||p_entity_level||p_entity_id);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  l_in_ids(1):=p_entity_id;

  IF  p_entity_level  = l_c_delivery THEN
     Get_Delivery_Freight_Cost(
       p_in_ids         => l_in_ids,
       p_currency_code  => p_currency_code,
       x_delivery_amount => l_delivery_amount,
       x_lpn_amount     => l_lpn_amount,
       x_detail_amount  => l_detail_amount,
       x_return_status  => l_return_status);
  ELSIF  p_entity_level  = l_c_stop THEN
     Get_Stop_Freight_Cost(
       p_in_ids         => l_in_ids,
       p_currency_code  => p_currency_code,
       x_stop_amount     => l_stop_amount,
       x_return_status  => l_return_status);
  ELSIF  p_entity_level  = l_c_trip THEN
     Get_Trip_Freight_Cost(
       p_in_ids         => l_in_ids,
       p_currency_code  => p_currency_code,
       x_trip_amount     => l_trip_amount,
       x_stop_amount     => l_stop_amount,
       x_delivery_amount => l_delivery_amount,
       x_lpn_amount     => l_lpn_amount,
       x_detail_amount  => l_detail_amount,
       x_return_status  => l_return_status);
  ELSIF  p_entity_level  = l_c_line THEN
     Get_Detail_Freight_Cost(
       p_in_ids         => l_in_ids,
       p_currency_code  => p_currency_code,
       x_detail_amount  => l_detail_amount,
       x_return_status  => l_return_status);
  ELSIF  p_entity_level  = l_c_container THEN
     Get_LPN_Freight_Cost(
       p_in_ids         => l_in_ids,
       p_currency_code  => p_currency_code,
       x_main_lpn_amount     => l_main_lpn_amount,
       x_lpn_amount     => l_lpn_amount,
       x_detail_amount  => l_detail_amount,
       x_return_status  => l_return_status);
  END IF;

  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'amounts trip, stop, del, main lpn, lpn, detail: '||l_trip_amount||', '||l_stop_amount||', '||l_delivery_amount||', '||l_main_lpn_amount||', '||l_lpn_amount||', '||l_detail_amount);
  END IF;

      IF l_return_status NOT IN (WSH_UTIL_CORE.G_RET_STS_SUCCESS,WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
        raise total_freight_error;
      ELSIF l_return_status=WSH_UTIL_CORE.G_RET_STS_WARNING THEN
        x_return_status:=l_return_status;
      END IF;

       x_trip_amount := l_trip_amount;
       x_stop_amount := l_stop_amount;
       x_delivery_amount := l_delivery_amount;
       x_main_lpn_amount := l_main_lpn_amount;
       x_lpn_amount := l_lpn_amount;
       x_detail_amount := l_detail_amount;

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
   EXCEPTION

     WHEN total_freight_error THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       x_trip_amount := NULL;
       x_stop_amount := NULL;
       x_delivery_amount := NULL;
       x_lpn_amount := NULL;
       x_detail_amount := NULL;
       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Get_Total_Freight_Cost exception has occured. No user rate specified.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:Get_Total_Freight_Cost FILURE');
       END IF;

     WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
       x_trip_amount := NULL;
       x_stop_amount := NULL;
       x_delivery_amount := NULL;
       x_lpn_amount := NULL;
       x_detail_amount := NULL;
        WSH_UTIL_CORE.Default_Handler('WSH_FREIGHT_COSTS_PVT.Get_Total_Freight_Cost');

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                                                SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;


END Get_Total_Freight_Cost;
--TL Rating

PROCEDURE Get_Summary_Freight_Cost(
  p_entity_level      IN VARCHAR2,
  p_entity_id         IN NUMBER,
  p_currency_code     IN VARCHAR2,
  x_total_amount      OUT NOCOPY NUMBER,
  x_reprice_required  OUT NOCOPY VARCHAR2,
  x_return_status     OUT NOCOPY VARCHAR2) IS
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Get_Summary_Freight_Cost';



Cursor freight_cost_in_delivery(c_delivery_id number) IS
SELECT a.unit_amount,
       a.currency_code,
       NVL(conversion_type_code, 'Corporate'),
       NVL(conversion_date, SYSDATE),
       conversion_rate
FROM wsh_freight_costs a
WHERE a.delivery_detail_id in (
     SELECT c.delivery_detail_id
     FROM wsh_delivery_assignments_v b,
          wsh_delivery_details c
     WHERE b.delivery_id = c_delivery_id AND
           c.delivery_detail_id = b.delivery_detail_id AND
           c.released_status <> 'D')   AND
     NVL(a.charge_source_code, 'MANUAL' ) in('MANUAL', 'PRICING_ENGINE') AND
     NVL(a.line_type_code, 'CHARGE') in ('CHARGE', 'PRICE') AND
     a.freight_cost_type_id <> -1 AND
     a.unit_amount is NOT NULL;



Cursor need_reprice(c_delivery_id NUMBER) IS
SELECT 1
FROM wsh_delivery_legs wshlg, wsh_delivery_assignments_v wshda,
     wsh_new_deliveries wshnd
WHERE wshlg.delivery_id = c_delivery_id AND
      wshlg.reprice_required = 'Y' AND
      wshnd.delivery_id = wshlg.delivery_id and
      wshda.delivery_id = wshnd.delivery_id and
      wshda.delivery_detail_id is not null and
      rownum = 1;


l_freight_cost             NUMBER := 0;
l_currency_code            VARCHAR2(15) := NULL;
l_conversion_type_code     VARCHAR2(15) := NULL;
l_conversion_date          DATE;
l_conversion_rate          NUMBER;
l_total_amount             NUMBER := 0;
l_return_status            VARCHAR2(10) := NULL;
l_converted_amount         NUMBER := 0;
l_msg_data                 VARCHAR2(2000);
convert_amount_error       EXCEPTION;

l_need_reprice             NUMBER;

BEGIN
  --
  -- Debug Statements
  --
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
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  x_total_amount := 0;
  x_reprice_required := 'N';

  IF  p_entity_level  = 'Delivery' THEN

    OPEN need_reprice(p_entity_id);
    FETCH need_reprice into l_need_reprice;
    IF need_reprice%NOTFOUND THEN
       x_reprice_required := 'N';
    ELSE
       x_reprice_required := 'Y';
    END IF;
    CLOSE need_reprice;

    OPEN freight_cost_in_delivery(p_entity_id);
    LOOP
      FETCH freight_cost_in_delivery INTO l_freight_cost,
                                          l_currency_code,
                                          l_conversion_type_code,
                                          l_conversion_date,
                                          l_conversion_rate;

      EXIT WHEN freight_cost_in_delivery%NOTFOUND ;
      Convert_Amount (
        p_from_currency     => l_currency_code,
        p_to_currency       => p_currency_code,
        p_conversion_date   => l_conversion_date,
        p_conversion_rate   => l_conversion_rate,
        p_conversion_type   => l_conversion_type_code,
        p_amount            => l_freight_cost,
        x_converted_amount  => l_converted_amount,
        x_return_status     => l_return_status) ;

      IF l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        l_total_amount := l_total_amount + NVL(l_converted_amount, 0);
      ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
        l_total_amount := l_total_amount + NVL(l_converted_amount,0);
        IF x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        END IF;
      ELSE
        raise convert_amount_error;
      END IF;
    END LOOP;

    CLOSE freight_cost_in_delivery;

    x_total_amount := l_total_amount;

  END IF;
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
   EXCEPTION

     WHEN convert_amount_error THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Get_Summary_Freight_Cost exception has occured. No user rate specified.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:Get_Summary_Freight_Cost FILURE');
       END IF;

     WHEN OTHERS THEN

        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        WSH_UTIL_CORE.Default_Handler('WSH_FREIGHT_COSTS_PVT.Get_Summary_Freight_Cost');

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                                                SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;


END Get_Summary_Freight_Cost;



PROCEDURE Convert_Amount (
  p_from_currency     IN VARCHAR2,
  p_to_currency       IN VARCHAR2,
  p_conversion_date   IN DATE,
  p_conversion_rate   IN NUMBER,
  p_conversion_type   IN VARCHAR2,
  p_amount            IN NUMBER ,
  x_converted_amount  OUT NOCOPY NUMBER,
  x_return_status     OUT NOCOPY VARCHAR2)

IS

 l_max_roll_days      NUMBER := 300;
 l_denominator        NUMBER := 0;
 l_numerator          NUMBER := 0;
 l_rate               NUMBER := 0;
 l_rate_exists        VARCHAR2(10)  := NULL;

 l_debug_on           BOOLEAN;

 l_module_name        CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Convert_Amount';
 WSH_CONVERT_ERROR    EXCEPTION ;
 WSH_INVALID_CURRENCY EXCEPTION;
 WSH_NO_RATE          EXCEPTION;
BEGIN

  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  IF p_amount = 0 THEN
     x_converted_amount := 0;
  ELSIF  p_from_currency = p_to_currency THEN
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'From currency is same as to currency ',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    x_converted_amount := p_amount;

  ELSE

    --
    IF (GL_CURRENCY_API.Is_Fixed_Rate(p_from_currency, p_to_currency, p_conversion_date) = 'Y') THEN
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'Convert' ||p_from_currency||' to '||p_to_currency ||' using fixed rate' );
       END IF;

       BEGIN
          x_converted_amount := GL_CURRENCY_API.convert_amount(p_from_currency, p_to_currency, p_conversion_date, p_conversion_type, p_amount);
       EXCEPTION
          WHEN GL_CURRENCY_API.no_rate THEN
             IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Failed in GL_CURRENCY_API.Convert_Amount( ) no rate ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
             END IF;
             RAISE WSH_NO_RATE;

          WHEN GL_CURRENCY_API.invalid_currency THEN
             IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Failed in GL_CURRENCY_API.Convert_Amount( ) invalid currency',WSH_DEBUG_SV.C_EXCEP_LEVEL);
             END IF;
             RAISE WSH_INVALID_CURRENCY;

          WHEN others THEN
             IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Failed in GL_CURRENCY_API.Convert_Amount( )',WSH_DEBUG_SV.C_EXCEP_LEVEL);
             END IF;
             RAISE WSH_CONVERT_ERROR;
       END;

    ELSIF (p_conversion_type = 'User') THEN
       IF (p_conversion_rate IS NOT NULL) THEN
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name, 'Convert amount using user specified rate: ' || to_char(p_conversion_rate) , WSH_DEBUG_SV.C_EXCEP_LEVEL);
          END IF;
          --
          IF p_conversion_rate IS NULL THEN
             IF l_debug_on THEN
	        WSH_DEBUG_SV.logmsg(l_module_name, 'Conversion Rate is NULL',WSH_DEBUG_SV.C_EXCEP_LEVEL );
             END IF;
             RAISE WSH_NO_RATE;

          END IF;
          x_converted_amount := p_amount * p_conversion_rate;
       ELSE
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name, 'Conversion_type is user but no conversion_rate specified, convert_amount failed' );
          END IF;

          RAISE WSH_CONVERT_ERROR;
       END IF;
    ELSE

       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit GL_CURRENCY_API.RATE_EXISTS',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       --
       l_rate_exists := GL_CURRENCY_API.Rate_Exists(
          x_from_currency   => p_from_currency,
          x_to_currency     => p_to_currency,
          x_conversion_date => p_conversion_date,
          x_conversion_type => p_conversion_type
          );
       IF (l_rate_exists = 'Y') THEN
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name, 'Convert amount using floating rate decided by conversion date' || to_char( p_conversion_date) );
          END IF;
          BEGIN
             x_converted_amount := GL_CURRENCY_API.convert_amount(p_from_currency, p_to_currency, p_conversion_date, p_conversion_type, p_amount);
          EXCEPTION
          WHEN GL_CURRENCY_API.no_rate THEN
             IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Failed in GL_CURRENCY_API.Convert_Amount( ) no rate ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
             END IF;
             RAISE WSH_NO_RATE;

          WHEN GL_CURRENCY_API.invalid_currency THEN
             IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Failed in GL_CURRENCY_API.Convert_Amount( ) invalid currency',WSH_DEBUG_SV.C_EXCEP_LEVEL);
             END IF;
             RAISE WSH_INVALID_CURRENCY;

          WHEN others THEN
             IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Failed in GL_CURRENCY_API.Convert_Amount( )',WSH_DEBUG_SV.C_EXCEP_LEVEL);
             END IF;
             RAISE WSH_CONVERT_ERROR;
          END;
       ELSE
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name, 'No rate exists , convert to closest amount , conversion date:'|| to_char ( p_conversion_date ) );
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit GL_CURRENCY_API.CONVERT_CLOSEST_AMOUNT',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          BEGIN
             GL_CURRENCY_API.convert_closest_amount(
                x_from_currency   => p_from_currency,
                x_to_currency     => p_to_currency,
                x_conversion_date => p_conversion_date,
                x_conversion_type => p_conversion_type,
                x_user_rate       => p_conversion_rate,
                x_amount          => p_amount,
                x_max_roll_days   => l_max_roll_days,
                x_converted_amount=> x_converted_amount,
                x_denominator     => l_denominator,
                x_numerator       => l_numerator,
                x_rate            => l_rate);

             IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Converted amount from GL_CURRENCY_API.CONVERT_CLOSEST_AMOUNT is: '|| to_char(x_converted_amount),WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;
          EXCEPTION
          WHEN GL_CURRENCY_API.no_rate THEN
             IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Failed in GL_CURRENCY_API.Convert_Closest_Amount( ) no rate ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
             END IF;
             RAISE WSH_NO_RATE;

          WHEN GL_CURRENCY_API.invalid_currency THEN
             IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Failed in GL_CURRENCY_API.Convert_Closest_Amount( ) invalid currency',WSH_DEBUG_SV.C_EXCEP_LEVEL);
             END IF;
             RAISE WSH_INVALID_CURRENCY;

          WHEN others THEN
             IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Failed in GL_CURRENCY_API.Convert_Closest_Amount( )',WSH_DEBUG_SV.C_EXCEP_LEVEL);
             END IF;
             RAISE WSH_CONVERT_ERROR;
          END;
       END IF;
    END IF;

  END IF;

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --


EXCEPTION

WHEN WSH_NO_RATE THEN
  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  x_converted_amount := NULL;
  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Convert_Amount exception has occured. No convertion rate specified.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  FND_MESSAGE.Set_Name('WSH', 'WSH_FC_NO_RATE');
  FND_MESSAGE.Set_Token('FROM_CURRENCY', p_from_currency);
  FND_MESSAGE.Set_Token('TO_CURRENCY', p_to_currency);
  WSH_UTIL_CORE.Add_Message(x_return_status);

WHEN WSH_INVALID_CURRENCY THEN
  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  x_converted_amount := NULL;
  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Convert_Amount exception has occured. Invalid currency.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  FND_MESSAGE.Set_Name('WSH', 'WSH_FC_INVALID_CURRENCY');
  WSH_UTIL_CORE.Add_Message(x_return_status);

WHEN WSH_CONVERT_ERROR THEN
  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  x_converted_amount := NULL;
  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Convert_Amount exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  FND_MESSAGE.Set_Name('WSH', 'WSH_FC_NO_RATE');
  FND_MESSAGE.Set_Token('FROM_CURRENCY', p_from_currency);
  FND_MESSAGE.Set_Token('TO_CURRENCY', p_to_currency);
  WSH_UTIL_CORE.Add_Message(x_return_status);

WHEN others THEN
  x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
  x_converted_amount := NULL;
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
         SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
  END IF;
  WSH_UTIL_CORE.Default_Handler('WSH_FREIGHT_COSTS_PVT.Convert_Amount');

END Convert_Amount;



-- --------------------------------
-- PROCEDURE Remove_FTE_Freight_Costs
-- --------------------------------
PROCEDURE Remove_FTE_Freight_Costs(
   p_delivery_details_tab IN WSH_UTIL_CORE.Id_Tab_Type,
   x_return_status        OUT NOCOPY  VARCHAR2 ) IS

CURSOR lock_freight_costs(c_delivery_detail_id NUMBER) IS
   SELECT freight_cost_id
   FROM   wsh_freight_costs
   WHERE  delivery_detail_id = c_delivery_detail_id AND
          charge_source_code = 'PRICING_ENGINE'
   FOR UPDATE NOWAIT;

CURSOR get_freight_costs (c_delivery_detail_id NUMBER) IS
   SELECT 1
   FROM   wsh_freight_costs
   WHERE  delivery_detail_id = c_delivery_detail_id AND
          charge_source_code = 'PRICING_ENGINE' AND
          rownum = 1;


l_freight_cost_id    NUMBER;
l_freight_costs_exist    NUMBER;
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'REMOVE_FC_FREIGHT_COSTS';
--
BEGIN
   SAVEPOINT befor_delete;
   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
     l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
   END IF;

   FOR i in p_delivery_details_tab.FIRST .. p_delivery_details_tab.LAST
   LOOP
      IF l_debug_on THEN
	      WSH_DEBUG_SV.log(l_module_name,'Removing FTE Freight Costs for Delivery Detail: '|| p_delivery_details_tab(i));
      END IF;

      OPEN get_freight_costs(p_delivery_details_tab(i));
      FETCH get_freight_costs into l_freight_costs_exist ;
      IF get_freight_costs%NOTFOUND THEN
          NULL;
      ELSE
         OPEN lock_freight_costs(p_delivery_details_tab(i));
	 LOOP
            FETCH lock_freight_costs INTO l_freight_cost_id;
	    EXIT WHEN lock_freight_costs%NOTFOUND;
            DELETE wsh_freight_costs WHERE freight_cost_id = l_freight_cost_id;
	    IF l_debug_on THEN
	       WSH_DEBUG_SV.log(l_module_name,'Removed FTE Freight Costs ID: '|| l_freight_cost_id);
	    END IF;
	 END LOOP;
	 CLOSE lock_freight_costs;
      END IF;
      CLOSE get_freight_costs;
   END LOOP;
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
EXCEPTION

WHEN OTHERS THEN

   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
   wsh_util_core.default_handler('WSH_FREIGHT_COSTS_PVT.Remove_FTE_Freight_Costs',l_module_name);
   ROLLBACK TO before_delete;
   --
   IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Cannot lock the fright cost records '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
   END IF;


END Remove_FTE_Freight_Costs;

/*************************************************************/
PROCEDURE Get_Trip_Manual_Freight_Cost(
  p_trip_id         IN NUMBER,
  p_currency_code   IN VARCHAR2,
  x_trip_amount     OUT NOCOPY  NUMBER,
  x_return_status   OUT  NOCOPY VARCHAR2) IS

l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Get_Trip_Manual_Freight_Cost';

Cursor freight_cost_at_trip(c_trip_id number) IS
SELECT freight_cost_id,
       unit_amount,
       currency_code,
       NVL(conversion_type_code, 'Corporate'),
       NVL(conversion_date, SYSDATE),
       conversion_rate
FROM wsh_freight_costs
WHERE trip_id = c_trip_id AND
      NVL(charge_source_code, 'MANUAL') = 'MANUAL' AND
      NVL(line_type_code, 'CHARGE') IN ('CHARGE', 'PRICE') AND
      freight_cost_type_id <> -1 AND
      unit_amount > 0;


l_freight_cost             NUMBER := 0;
l_currency_code            VARCHAR2(15) := NULL;
l_conversion_type_code     VARCHAR2(15) := NULL;
l_conversion_date          DATE;
l_conversion_rate          NUMBER;
l_total_amount             NUMBER := 0;
l_return_status            VARCHAR2(10) := NULL;
l_converted_amount         NUMBER := 0;
l_msg_data                 VARCHAR2(2000);
l_freight_cost_id          NUMBER;
convert_amount_error       EXCEPTION;


BEGIN
  --
  -- Debug Statements
  --
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
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  x_trip_amount := NULL;

    OPEN freight_cost_at_trip(p_trip_id);
    LOOP
    --{
      FETCH freight_cost_at_trip INTO     l_freight_cost_id,
                                          l_freight_cost,
                                          l_currency_code,
                                          l_conversion_type_code,
                                          l_conversion_date,
                                          l_conversion_rate;

      EXIT WHEN freight_cost_at_trip%NOTFOUND ;
      Convert_Amount (
        p_from_currency     => l_currency_code,
        p_to_currency       => p_currency_code,
        p_conversion_date   => l_conversion_date,
        p_conversion_rate   => l_conversion_rate,
        p_conversion_type   => l_conversion_type_code,
        p_amount            => l_freight_cost,
        x_converted_amount  => l_converted_amount,
        x_return_status     => l_return_status) ;

      IF l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        l_total_amount := l_total_amount + NVL(l_converted_amount,0);
      ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
        l_total_amount := l_total_amount + NVL(l_converted_amount,0);
        IF x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        END IF;
      ELSE
        raise convert_amount_error;
      END IF;
    --}
    END LOOP;
    CLOSE freight_cost_at_trip;

  x_trip_amount:=l_total_amount;

  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Manual freight cost at trip : '||l_total_amount);
  END IF;
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
   EXCEPTION
     WHEN convert_amount_error THEN
       CLOSE freight_cost_at_trip;
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        x_trip_amount := NULL;
       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Get_Trip_Manual_Freight_Cost exception has occured. No user rate specified.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:Get_Trip_Freight_Cost FAILURE');
       END IF;

     WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        x_trip_amount := NULL;
        WSH_UTIL_CORE.Default_Handler('WSH_FREIGHT_COSTS_PVT.Get_Trip_Freight_Cost');
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;

END Get_Trip_Manual_Freight_Cost;

/************************************************************************/

END WSH_FREIGHT_COSTS_PVT;

/
