--------------------------------------------------------
--  DDL for Package WMS_PARAMETER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_PARAMETER_PVT" AUTHID CURRENT_USER AS
/* $Header: WMSVPPPS.pls 120.1 2008/01/15 08:47:09 kkesavar ship $ */
--
-- File        : WMSVPPPS.pls
-- Content     : WMS_Parameter_PVT package specification
-- Description : WMS parameters private APIs
--               This package contains two types of functions:
--               1. functions related to flexfield
--               2. functions related to various quantity functions
--
-- Notes       :
-- Modified    : 02/08/99 mzeckzer created
--               11/08/99 bitang moved to wms and added comment
--
-- Global Type and Constant Definition
--
-- Local copy of fnd globals to prevent pragma violations of api functions
-- to be used within 'select', 'where' and 'order by' clauses of dynamic
-- SQL build by wms rules engine
--
g_miss_num  CONSTANT NUMBER      := fnd_api.g_miss_num;
g_miss_char CONSTANT VARCHAR2(1) := fnd_api.g_miss_char;
g_miss_date CONSTANT DATE        := fnd_api.g_miss_date;


-- Following global variables are use to cache the locator_id and and the qty_onhand to improve
-- the performance of the getItemonhand function() used in the rules defination query

TYPE g_itemOnhand_tab is table of Number index by binary_integer;
g_bulkCollect_Locator 	g_itemOnhand_tab;
g_bulkCollect_quantity 	g_itemOnhand_tab;
g_locator_item_quantity g_itemOnhand_tab;

-- Adding a global variable to cache the useage of new rule. These variable are initilized
-- after the rule is executed

g_GetItemOnhq_IsRuleCached VARCHAR2(1):= 'N';
g_GetProjAttr_IsRuleCached VARCHAR2(1):= 'N';

--
-- API name    : ClearCache
-- Type        : Private
-- Function    : Clears the global cache used in the parameters file.
--               This will be called from the WMS_RULE_PVT package.
PROCEDURE ClearCache;

--
-- Functions Related To Flexfield
--
-- API name    : IfFlexThenAvailable
-- Type        : Private
-- Function    : Returns 'N' if actual parameter is a key or descriptive
--               flexfield segment and not configured yet, returns 'Y' in
--               any other case.
--               ( Needed for all forms base views and LOV's regarding
--               parameters like rules, restrictions and sort criteria )
--
-- Input Parameters  :
--   See the definition of corresponding column in WMS_PARAMETERS for
--   update-to-date information about the following input parameters.
--
--   p_db_object_ref_type_code:
--     1 - single referenced ; 2 - multiple referenced
--   p_parameter_type_code:
--     1 - column ; 2 - expression
--   p_flexfield_usage_code:
--     'K' - key flexfield; 'D' - descriptive flexfield ;
--     null - not used in flexfield
--   p_flexfield_application_id:
--     id of the application in which the flexfield is defined
--   p_flexfield_name:
--     code of the key flexfield or name of the descriptive flexfield
--   p_column_name:
--     column name if the parameter is based on a table/view column
--
-- Notes       : works for global segments only, not for context segments
--
FUNCTION IfFlexThenAvailable
  ( p_db_object_ref_type_code  IN NUMBER   DEFAULT g_miss_num
   ,p_parameter_type_code      IN NUMBER   DEFAULT g_miss_num
   ,p_flexfield_usage_code     IN VARCHAR2 DEFAULT g_miss_char
   ,p_flexfield_application_id IN NUMBER   DEFAULT g_miss_num
   ,p_flexfield_name           IN VARCHAR2 DEFAULT g_miss_char
   ,p_column_name              IN VARCHAR2 DEFAULT g_miss_char
   ) RETURN VARCHAR2;
--
-- API name    : GetFlexDataTypeCode
-- Type        : Private
-- Function    : Returns user-defined segment data type if actual parameter is
--               a key or descriptive flexfield segment and configured,
--               returns original data type in any other case.
--               ( Needed for all forms base views and LOV's regarding
--               parameters like rules, restrictions and sort criteria )
-- Input Parameters  :
--   p_data_type_code:
--     data type of the flexfield segment
--     1 - number ; 2 - character; 3 - date ; null - not given
--
--   See the comment in function IfFlexThenAvailable for the
--   meaning of the following input parameters.
--
--   p_db_object_ref_type_code
--   p_parameter_type_code
--   p_flexfield_usage_code
--   p_flexfield_application_id
--   p_flexfield_name
--   p_column_name
--
-- Notes       : works for global segments only, not for context segments
FUNCTION GetFlexDataTypeCode
  ( p_data_type_code           IN NUMBER   DEFAULT g_miss_num
   ,p_db_object_ref_type_code  IN NUMBER   DEFAULT g_miss_num
   ,p_parameter_type_code      IN NUMBER   DEFAULT g_miss_num
   ,p_flexfield_usage_code     IN VARCHAR2 DEFAULT g_miss_char
   ,p_flexfield_application_id IN NUMBER   DEFAULT g_miss_num
   ,p_flexfield_name           IN VARCHAR2 DEFAULT g_miss_char
   ,p_column_name              IN VARCHAR2 DEFAULT g_miss_char
    ) RETURN NUMBER;
--
-- API name    : GetFlexName
-- Type        : Private
-- Function    : Returns user-defined segment name if actual parameter is
--               a key or descriptive flexfield segment and configured,
--               returns original name in any other case.
--               ( Needed for all forms base views and LOV's regarding
--               parameters like rules, restrictions and sort criteria )
--
-- Input Parameters  :
--   p_name:
--     name of the flexfield segment
--
--   See the comment in function IfFlexThenAvailable for the
--   meaning of the following input parameters.
--
--   p_db_object_ref_type_code
--   p_parameter_type_code
--   p_flexfield_usage_code
--   p_flexfield_application_id
--   p_flexfield_name
--   p_column_name
--
-- Notes       : works for global segments only, not for context segments
--
FUNCTION GetFlexName
  ( p_name                     IN VARCHAR2 DEFAULT g_miss_char
   ,p_db_object_ref_type_code  IN NUMBER   DEFAULT g_miss_num
   ,p_parameter_type_code      IN NUMBER   DEFAULT g_miss_num
   ,p_flexfield_usage_code     IN VARCHAR2 DEFAULT g_miss_char
   ,p_flexfield_application_id IN NUMBER   DEFAULT g_miss_num
   ,p_flexfield_name           IN VARCHAR2 DEFAULT g_miss_char
   ,p_column_name              IN VARCHAR2 DEFAULT g_miss_char
   ) RETURN VARCHAR2;
--
-- API name    : GetFlexDescription
-- Type        : Private
-- Function    : Returns user-defined segment description if actual parameter
--               is a key or descriptive flexfield segment and configured,
--               returns original description in any other case.
--               ( Needed for all forms base views and LOV's regarding
--               parameters like rules, restrictions and sort criteria )
--
-- Input Parameters:
--   p_description:
--     description of the flexfield segment
--   p_db_object_ref_type_code
--   p_parameter_type_code
--   p_flexfield_usage_code
--   p_flexfield_application_id
--   p_flexfield_name
--   p_column_name
--
-- Notes       : works for global segments only, not for context segments
FUNCTION GetFlexDescription
  ( p_description              IN VARCHAR2 DEFAULT g_miss_char
   ,p_db_object_ref_type_code  IN NUMBER   DEFAULT g_miss_num
   ,p_parameter_type_code      IN NUMBER   DEFAULT g_miss_num
   ,p_flexfield_usage_code     IN VARCHAR2 DEFAULT g_miss_char
   ,p_flexfield_application_id IN NUMBER   DEFAULT g_miss_num
   ,p_flexfield_name           IN VARCHAR2 DEFAULT g_miss_char
   ,p_column_name              IN VARCHAR2 DEFAULT g_miss_char
   ) RETURN VARCHAR2;
--
--
-- Functions related to quantity functions
--
-- API name    : RoundUp
-- Type        : Private
-- Function    : Returns quantity, rounded up according actual and base units
--               of measure and the conversion defined between them.
--               ( Used for capacity and on-hand calculation parameters )
FUNCTION RoundUp
  ( p_quantity          IN NUMBER   DEFAULT g_miss_num
   ,p_transaction_uom   IN VARCHAR2 DEFAULT g_miss_char
   ,p_inventory_item_id IN NUMBER   DEFAULT g_miss_num
   ,p_base_uom          IN VARCHAR2 DEFAULT g_miss_char
   ) RETURN NUMBER;
--
-- API name    : RoundDown
-- Type        : Private
-- Function    : Returns quantity, rounded down according actual and base
--               units of measure and the conversion defined between them.
--               ( Used for capacity and on-hand calculation parameters )
FUNCTION RoundDown
  ( p_quantity          IN NUMBER   DEFAULT g_miss_num
   ,p_transaction_uom   IN VARCHAR2 DEFAULT g_miss_char
   ,p_inventory_item_id IN NUMBER   DEFAULT g_miss_num
   ,p_base_uom          IN VARCHAR2 DEFAULT g_miss_char
   ) RETURN NUMBER;
--
-- API name    : GetTotalUnitCapacity
-- Type        : Private
-- Function    : Returns total unit capacity of a location regardless any unit
--               of measure.
--               ( Used for capacity calculation parameters )
-- Notes       : Since there are several situations, where unit capacity can
--               not be calculated, the following definitions are made:
--               - in case of subinventories w/o locators, capacity is
--                 infinite
--               - in case of missing setup data at the locator, capacity is
--                 infinite
FUNCTION GetTotalUnitCapacity
  ( p_organization_id   IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id        IN NUMBER   DEFAULT g_miss_num
   ) RETURN NUMBER;
--
-- API name    : GetOccupiedUnitCapacity
-- Type        : Private
-- Function    : Returns occupied unit capacity of a location regardless any
--               unit of measure.
--               ( Used for capacity calculation parameters )
FUNCTION GetOccupiedUnitCapacity
  ( p_organization_id    IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code  IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id         IN NUMBER   DEFAULT g_miss_num
   ) RETURN NUMBER;
--
-- API name    : GetAvailableUnitCapacity
-- Type        : Private
-- Function    : Returns available unit capacity of a location considering
--               on-hand stock regardless any unit of measure.
--               ( Used for capacity calculation parameters )
-- Notes       : Since there are several situations, where unit capacity can
--               not be calculated, the following definitions are made:
--               - in case of subinventories w/o locators, capacity is
--                 infinite
--               - in case of missing setup data at the locator, capacity is
--                 infinite
FUNCTION GetAvailableUnitCapacity
  ( p_organization_id     IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code   IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id          IN NUMBER   DEFAULT g_miss_num
   ) RETURN NUMBER;
--
-- API name    : GetRemainingUnitCapacity
-- Type        : Private
-- Function    : Returns remaining unit capacity of a location, assuming the
--               actual receipt would have been performed already, regardless
--               any unit of measure.
--               ( Used for capacity calculation parameters )
-- Notes       : Since there are several situations, where unit capacity can
--               not be calculated, the following definitions are made:
--               - in case of subinventories w/o locators, capacity is
--                 infinite
--               - in case of missing setup data at the locator, capacity is
--                 infinite
FUNCTION GetRemainingUnitCapacity
  ( p_organization_id       IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code     IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id            IN NUMBER   DEFAULT g_miss_num
   ,p_transaction_quantity  IN NUMBER   DEFAULT g_miss_num
   ) RETURN NUMBER;
--
-- API name    : GetTotalVolumeCapacity
-- Type        : Private
-- Function    : Returns total volume or weight capacity of a location
--               measured in transaction UOM of the actual item.
--               Meaning: The function determines, how many items, measured in
--                        transaction UOM, will fit into the location
--                        according to their volume or weight.
--               ( Used for capacity calculation parameters )
-- Notes       : Since there are several situations, where volume or weight
--               capacity can not be calculated, the following definitions are
--               made:
--               - in case of subinventories w/o locators, capacity is
--                 infinite
--               - in case of missing setup data at the locator, capacity is
--                 infinite
--               - in case of missing setup data at the item, capacity is
--                 infinite ( meaning: item then has no volume or weight )
FUNCTION GetTotalVolumeCapacity
  ( p_organization_id     IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code   IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id          IN NUMBER   DEFAULT g_miss_num
   ,p_inventory_item_id   IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume         IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume_uom_code IN VARCHAR2 DEFAULT g_miss_char
   ,p_primary_uom         IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_uom     IN VARCHAR2 DEFAULT g_miss_char
   ,p_base_uom            IN VARCHAR2 DEFAULT g_miss_char
   ) RETURN NUMBER;
--
-- API name    : GetTotalWeightCapacity
-- Type        : Private
-- Function    : Returns total weight capacity of a location
--               measured in transaction UOM of the actual item.
--               Meaning: The function determines, how many items, measured in
--                        transaction UOM, will fit into the location
--                        according to their volume or weight.
--               ( Used for capacity calculation parameters )
-- Notes       : Since there are several situations, where weight
--               capacity can not be calculated, the following definitions are
--               made:
--               - in case of subinventories w/o locators, capacity is
--                 infinite
--               - in case of missing setup data at the locator, capacity is
--                 infinite
--               - in case of missing setup data at the item, capacity is
--                 infinite ( meaning: item then has no volume or weight )
FUNCTION GetTotalWeightCapacity
  ( p_organization_id     IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code   IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id          IN NUMBER   DEFAULT g_miss_num
   ,p_inventory_item_id    IN NUMBER   DEFAULT g_miss_num
   ,p_unit_weight          IN NUMBER   DEFAULT g_miss_num
   ,p_unit_weight_uom_code IN VARCHAR2 DEFAULT g_miss_char
   ,p_primary_uom          IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_uom      IN VARCHAR2 DEFAULT g_miss_char
   ,p_base_uom             IN VARCHAR2 DEFAULT g_miss_char
   ) RETURN NUMBER;
--
-- API name    : GetOccupiedVolumeCapacity
-- Type        : Private
-- Function    : Returns occupied volume capacity of a location measured in
--               transaction UOM of the actual item.
--               Meaning: The function determines, how many items, measured in
--                        transaction UOM, virtually occupy the location
--                        already according to their volume.
--               ( Used for capacity calculation parameters )
-- Notes       : Since there are several situations, where volume capacity can
--               not be calculated, the following definitions are made:
--               - in case of missing setup data at the item, occupied
--                 capacity is zero ( meaning: item then has no volume )
FUNCTION GetOccupiedVolumeCapacity
  ( p_organization_id      IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code    IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id           IN NUMBER   DEFAULT g_miss_num
   ,p_inventory_item_id    IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume          IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume_uom_code IN VARCHAR2 DEFAULT g_miss_char
   ,p_primary_uom          IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_uom      IN VARCHAR2 DEFAULT g_miss_char
   ,p_base_uom             IN VARCHAR2 DEFAULT g_miss_char
   ) RETURN NUMBER;
--
-- API name    : GetOccupiedWeightCapacity
-- Type        : Private
-- Function    : Returns occupied weight capacity of a location measured in
--               transaction UOM of the actual item.
--               Meaning: The function determines, how many items, measured in
--                        transaction UOM, virtually occupy the location
--                        already according to their weight.
--               ( Used for capacity calculation parameters )
-- Notes       : Since there are several situations, where weight capacity can
--               not be calculated, the following definitions are made:
--               - in case of missing setup data at the item, occupied
--                 capacity is zero ( meaning: item then has no weight )
FUNCTION GetOccupiedWeightCapacity
  ( p_organization_id      IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code    IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id           IN NUMBER   DEFAULT g_miss_num
   ,p_inventory_item_id    IN NUMBER   DEFAULT g_miss_num
   ,p_unit_weight          IN NUMBER   DEFAULT g_miss_num
   ,p_unit_weight_uom_code IN VARCHAR2 DEFAULT g_miss_char
   ,p_primary_uom          IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_uom      IN VARCHAR2 DEFAULT g_miss_char
   ,p_base_uom             IN VARCHAR2 DEFAULT g_miss_char
   ) RETURN NUMBER;
--
-- API name    : GetAvailableVolumeCapacity
-- Type        : Private
-- Function    : Returns available volume capacity of a location measured in
--               transaction UOM of the actual item.
--               Meaning: The function determines, how many items, measured in
--                        transaction UOM, will fit into the location
--                        according to their volume considering the capacity
--                        already occupied by on-hand stock.
--               ( Used for capacity calculation parameters )
-- Notes       : Since there are several situations, where volume capacity can
--               not be calculated, the following definitions are made:
--               - in case of subinventories w/o locators, capacity is
--                 infinite
--               - in case of missing setup data at the locator, capacity is
--                 infinite
--               - in case of missing setup data at the item, capacity is
--                 infinite ( meaning: item then has no volume )
FUNCTION GetAvailableVolumeCapacity
  ( p_organization_id          IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code        IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id               IN NUMBER   DEFAULT g_miss_num
   ,p_inventory_item_id        IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume              IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume_uom_code     IN VARCHAR2 DEFAULT g_miss_char
   ,p_primary_uom              IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_uom          IN VARCHAR2 DEFAULT g_miss_char
   ,p_base_uom                 IN VARCHAR2 DEFAULT g_miss_char
   ) RETURN NUMBER;
--
-- API name    : GetAvailableWeightCapacity
-- Type        : Private
-- Function    : Returns available weight capacity of a location measured in
--               transaction UOM of the actual item.
--               Meaning: The function determines, how many items, measured in
--                        transaction UOM, will fit into the location
--                        according to their weight considering the capacity
--                        already occupied by on-hand stock.
--               ( Used for capacity calculation parameters )
-- Notes       : Since there are several situations, where weight capacity can
--               not be calculated, the following definitions are made:
--               - in case of subinventories w/o locators, capacity is
--                 infinite
--               - in case of missing setup data at the locator, capacity is
--                 infinite
--               - in case of missing setup data at the item, capacity is
--                 infinite ( meaning: item then has no weight )
FUNCTION GetAvailableWeightCapacity
  ( p_organization_id          IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code        IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id               IN NUMBER   DEFAULT g_miss_num
   ,p_inventory_item_id        IN NUMBER   DEFAULT g_miss_num
   ,p_unit_weight              IN NUMBER   DEFAULT g_miss_num
   ,p_unit_weight_uom_code     IN VARCHAR2 DEFAULT g_miss_char
   ,p_primary_uom              IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_uom          IN VARCHAR2 DEFAULT g_miss_char
   ,p_base_uom                 IN VARCHAR2 DEFAULT g_miss_char
   ) RETURN NUMBER;
--
-- API name    : GetRemainingVolumeCapacity
-- Type        : Private
-- Function    : Returns remaining available volume capacity of a location
--               measured in transaction UOM of the actual item.
--               Meaning: The function determines, how many items, measured in
--                        transaction UOM, will fit into the location
--                        according to their volume considering the capacity
--                        already occupied by on-hand stock and assuming the
--                        actual receipt would have been performed already.
--               ( Used for capacity calculation parameters )
-- Notes       : Since there are several situations, where volume capacity can
--               not be calculated, the following definitions are made:
--               - in case of subinventories w/o locators, capacity is
--                 infinite
--               - in case of missing setup data at the locator, capacity is
--                 infinite
--               - in case of missing setup data at the item, capacity is
--                 infinite ( meaning: item then has no volume )
FUNCTION GetRemainingVolumeCapacity
  ( p_organization_id          IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code        IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id               IN NUMBER   DEFAULT g_miss_num
   ,p_inventory_item_id        IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume              IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume_uom_code     IN VARCHAR2 DEFAULT g_miss_char
   ,p_primary_uom              IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_uom          IN VARCHAR2 DEFAULT g_miss_char
   ,p_base_uom                 IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_quantity     IN NUMBER   DEFAULT g_miss_num
   ) RETURN NUMBER;
--
-- API name    : GetRemainingWeightCapacity
-- Type        : Private
-- Function    : Returns remaining available weight capacity of a location
--               measured in transaction UOM of the actual item.
--               Meaning: The function determines, how many items, measured in
--                        transaction UOM, will fit into the location
--                        according to their weight considering the capacity
--                        already occupied by on-hand stock and assuming the
--                        actual receipt would have been performed already.
--               ( Used for capacity calculation parameters )
-- Notes       : Since there are several situations, where weight capacity can
--               not be calculated, the following definitions are made:
--               - in case of subinventories w/o locators, capacity is
--                 infinite
--               - in case of missing setup data at the locator, capacity is
--                 infinite
--               - in case of missing setup data at the item, capacity is
--                 infinite ( meaning: item then has no weight )
FUNCTION GetRemainingWeightCapacity
  ( p_organization_id        IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code      IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id             IN NUMBER   DEFAULT g_miss_num
   ,p_inventory_item_id      IN NUMBER   DEFAULT g_miss_num
   ,p_unit_weight            IN NUMBER   DEFAULT g_miss_num
   ,p_unit_weight_uom_code   IN VARCHAR2 DEFAULT g_miss_char
   ,p_primary_uom            IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_uom        IN VARCHAR2 DEFAULT g_miss_char
   ,p_base_uom               IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_quantity   IN NUMBER   DEFAULT g_miss_num
   ) RETURN NUMBER;
--
-- API name    : GetMinimumTotalVWCapacity
-- Type        : Private
-- Function    : Returns the minimum of total volume and total weight capacity
--               of a location measured in transaction UOM of the actual item.
--               ( Used for capacity calculation parameters )
-- Notes       : refer to notes regarding the corresponding separate volume
--               and weight capacity functions.
--
FUNCTION GetMinimumTotalVWCapacity
  ( p_organization_id       IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code     IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id            IN NUMBER   DEFAULT g_miss_num
   ,p_inventory_item_id     IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume           IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume_uom_code  IN VARCHAR2 DEFAULT g_miss_char
   ,p_unit_weight           IN NUMBER   DEFAULT g_miss_num
   ,p_unit_weight_uom_code  IN VARCHAR2 DEFAULT g_miss_char
   ,p_primary_uom           IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_uom       IN VARCHAR2 DEFAULT g_miss_char
   ,p_base_uom              IN VARCHAR2 DEFAULT g_miss_char
   ) RETURN NUMBER;

--
-- API name    : GetMinimumTotalVWCapacity {OverLoaded}
-- Type        : Private
-- Function    : Returns the minimum of total volume and total weight capacity
--               of a location measured in transaction UOM of the actual item.
--               ( Used for capacity calculation parameters )
-- Notes       : refer to notes regarding the corresponding separate volume
--               and weight capacity functions.
--
FUNCTION GetMinimumTotalVWCapacity
  ( p_organization_id       IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code     IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id            IN NUMBER   DEFAULT g_miss_num
   ,p_inventory_item_id     IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume           IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume_uom_code  IN VARCHAR2 DEFAULT g_miss_char
   ,p_unit_weight           IN NUMBER   DEFAULT g_miss_num
   ,p_unit_weight_uom_code  IN VARCHAR2 DEFAULT g_miss_char
   ,p_primary_uom           IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_uom       IN VARCHAR2 DEFAULT g_miss_char
   ,p_base_uom              IN VARCHAR2 DEFAULT g_miss_char
   ,p_location_maximum_units IN NUMBER
   ,p_location_current_units IN NUMBER
   ,p_location_suggested_units IN NUMBER
   ,p_location_available_units IN NUMBER
   ,p_weight_uom_code       IN VARCHAR2
   ,p_max_weight            IN NUMBER
   ,p_current_weight        IN NUMBER
   ,p_suggested_weight      IN NUMBER
   ,p_available_weight      IN NUMBER
   ,p_volume_uom_code       IN VARCHAR2
   ,p_max_cubic_area        IN NUMBER
   ,p_current_cubic_area    IN NUMBER
   ,p_suggested_cubic_area  IN NUMBER
   ,p_available_cubic_area  IN NUMBER
   ) RETURN NUMBER;



--
-- API name    : GetMaximumOccupiedVWCapacity
-- Type        : Private
-- Function    : Returns the maximum of occupied volume and occupied weight
--               capacity of a location measured in transaction UOM of the
--               actual item.
--               ( Used for capacity calculation parameters )
-- Notes       : refer to notes regarding the corresponding separate volume
--               and weight capacity functions.
FUNCTION GetMaximumOccupiedVWCapacity
  ( p_organization_id       IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code     IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id            IN NUMBER   DEFAULT g_miss_num
   ,p_inventory_item_id     IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume           IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume_uom_code  IN VARCHAR2 DEFAULT g_miss_char
   ,p_unit_weight           IN NUMBER   DEFAULT g_miss_num
   ,p_unit_weight_uom_code  IN VARCHAR2 DEFAULT g_miss_char
   ,p_primary_uom           IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_uom       IN VARCHAR2 DEFAULT g_miss_char
   ,p_base_uom              IN VARCHAR2 DEFAULT g_miss_char
   ) RETURN NUMBER;


--
-- API name    : GetMaximumOccupiedVWCapacity {OverLoaded}
-- Type        : Private
-- Function    : Returns the maximum of occupied volume and occupied weight
--               capacity of a location measured in transaction UOM of the
--               actual item.
--               ( Used for capacity calculation parameters )
-- Notes       : refer to notes regarding the corresponding separate volume
--               and weight capacity functions.
FUNCTION GetMaximumOccupiedVWCapacity
  ( p_organization_id       IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code     IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id            IN NUMBER   DEFAULT g_miss_num
   ,p_inventory_item_id     IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume           IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume_uom_code  IN VARCHAR2 DEFAULT g_miss_char
   ,p_unit_weight           IN NUMBER   DEFAULT g_miss_num
   ,p_unit_weight_uom_code  IN VARCHAR2 DEFAULT g_miss_char
   ,p_primary_uom           IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_uom       IN VARCHAR2 DEFAULT g_miss_char
   ,p_base_uom              IN VARCHAR2 DEFAULT g_miss_char
   ,p_location_maximum_units IN NUMBER
   ,p_location_current_units IN NUMBER
   ,p_location_suggested_units IN NUMBER
   ,p_location_available_units IN NUMBER
   ,p_weight_uom_code       IN VARCHAR2
   ,p_max_weight            IN NUMBER
   ,p_current_weight        IN NUMBER
   ,p_suggested_weight      IN NUMBER
   ,p_available_weight      IN NUMBER
   ,p_volume_uom_code       IN VARCHAR2
   ,p_max_cubic_area        IN NUMBER
   ,p_current_cubic_area    IN NUMBER
   ,p_suggested_cubic_area  IN NUMBER
   ,p_available_cubic_area  IN NUMBER
   ) RETURN NUMBER;

--
-- API name    : GetMinimumAvailableVWCapacity
-- Type        : Private
-- Function    : Returns the minimum of available volume and available weight
--               capacity of a location measured in transaction UOM of the
--               actual item.
--               ( Used for capacity calculation parameters )
-- Notes       : refer to notes regarding the corresponding separate volume
--               and weight capacity functions.
FUNCTION GetMinimumAvailableVWCapacity
  ( p_organization_id       IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code     IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id            IN NUMBER   DEFAULT g_miss_num
   ,p_inventory_item_id     IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume           IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume_uom_code  IN VARCHAR2 DEFAULT g_miss_char
   ,p_unit_weight           IN NUMBER   DEFAULT g_miss_num
   ,p_unit_weight_uom_code  IN VARCHAR2 DEFAULT g_miss_char
   ,p_primary_uom           IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_uom       IN VARCHAR2 DEFAULT g_miss_char
   ,p_base_uom              IN VARCHAR2 DEFAULT g_miss_char
   ) RETURN NUMBER;

--
-- API name    : GetMinimumAvailableVWCapacity {OverLoaded}
-- Type        : Private
-- Function    : Returns the minimum of available volume and available weight
--               capacity of a location measured in transaction UOM of the
--               actual item.
--               ( Used for capacity calculation parameters )
-- Notes       : refer to notes regarding the corresponding separate volume
--               and weight capacity functions.
FUNCTION GetMinimumAvailableVWCapacity
  ( p_organization_id       IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code     IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id            IN NUMBER   DEFAULT g_miss_num
   ,p_inventory_item_id     IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume           IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume_uom_code  IN VARCHAR2 DEFAULT g_miss_char
   ,p_unit_weight           IN NUMBER   DEFAULT g_miss_num
   ,p_unit_weight_uom_code  IN VARCHAR2 DEFAULT g_miss_char
   ,p_primary_uom           IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_uom       IN VARCHAR2 DEFAULT g_miss_char
   ,p_base_uom              IN VARCHAR2 DEFAULT g_miss_char
   ,p_location_maximum_units IN NUMBER
   ,p_location_current_units IN NUMBER
   ,p_location_suggested_units IN NUMBER
   ,p_location_available_units IN NUMBER
   ,p_weight_uom_code       IN VARCHAR2
   ,p_max_weight            IN NUMBER
   ,p_current_weight        IN NUMBER
   ,p_suggested_weight      IN NUMBER
   ,p_available_weight      IN NUMBER
   ,p_volume_uom_code       IN VARCHAR2
   ,p_max_cubic_area        IN NUMBER
   ,p_current_cubic_area    IN NUMBER
   ,p_suggested_cubic_area  IN NUMBER
   ,p_available_cubic_area  IN NUMBER
   ) RETURN NUMBER;



--
-- API name    : GetMinimumRemainingVWCapacity
-- Type        : Private
-- Function    : Returns the minimum of remaining available volume and
--               remaining available weight capacity of a location measured in
--               transaction UOM of the actual item.
--               ( Used for capacity calculation parameters )
-- Notes       : refer to notes regarding the corresponding separate volume
--               and weight capacity functions.
FUNCTION GetMinimumRemainingVWCapacity
  ( p_organization_id       IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code     IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id            IN NUMBER   DEFAULT g_miss_num
   ,p_inventory_item_id     IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume           IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume_uom_code  IN VARCHAR2 DEFAULT g_miss_char
   ,p_unit_weight           IN NUMBER   DEFAULT g_miss_num
   ,p_unit_weight_uom_code  IN VARCHAR2 DEFAULT g_miss_char
   ,p_primary_uom           IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_uom       IN VARCHAR2 DEFAULT g_miss_char
   ,p_base_uom              IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_quantity  IN NUMBER   DEFAULT g_miss_num
  ) RETURN NUMBER;

--
-- API name    : GetMinimumRemainingVWCapacity {OverLoaded}
-- Type        : Private
-- Function    : Returns the minimum of remaining available volume and
--               remaining available weight capacity of a location measured in
--               transaction UOM of the actual item.
--               ( Used for capacity calculation parameters )
-- Notes       : refer to notes regarding the corresponding separate volume
--               and weight capacity functions.
FUNCTION GetMinimumRemainingVWCapacity
  ( p_organization_id       IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code     IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id            IN NUMBER   DEFAULT g_miss_num
   ,p_inventory_item_id     IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume           IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume_uom_code  IN VARCHAR2 DEFAULT g_miss_char
   ,p_unit_weight           IN NUMBER   DEFAULT g_miss_num
   ,p_unit_weight_uom_code  IN VARCHAR2 DEFAULT g_miss_char
   ,p_primary_uom           IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_uom       IN VARCHAR2 DEFAULT g_miss_char
   ,p_base_uom              IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_quantity  IN NUMBER   DEFAULT g_miss_num
   ,p_location_maximum_units IN NUMBER
   ,p_location_current_units IN NUMBER
   ,p_location_suggested_units IN NUMBER
   ,p_location_available_units IN NUMBER
   ,p_weight_uom_code       IN VARCHAR2
   ,p_max_weight            IN NUMBER
   ,p_current_weight        IN NUMBER
   ,p_suggested_weight      IN NUMBER
   ,p_available_weight      IN NUMBER
   ,p_volume_uom_code       IN VARCHAR2
   ,p_max_cubic_area        IN NUMBER
   ,p_current_cubic_area    IN NUMBER
   ,p_suggested_cubic_area  IN NUMBER
   ,p_available_cubic_area  IN NUMBER
  ) RETURN NUMBER;

--
-- API name    : GetMinimumTotalUVWCapacity
-- Type        : Private
-- Function    : Returns the minimum of total unit, total volume and total
--               weight capacity of a location measured in transaction UOM of
--               the actual item.
--               ( Used for capacity calculation parameters )
-- Notes       : refer to notes regarding the corresponding separate unit,
--               volume and weight capacity functions.
FUNCTION GetMinimumTotalUVWCapacity
  ( p_organization_id      IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code    IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id           IN NUMBER   DEFAULT g_miss_num
   ,p_inventory_item_id    IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume          IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume_uom_code IN VARCHAR2 DEFAULT g_miss_char
   ,p_unit_weight          IN NUMBER   DEFAULT g_miss_num
   ,p_unit_weight_uom_code IN VARCHAR2 DEFAULT g_miss_char
   ,p_primary_uom          IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_uom      IN VARCHAR2 DEFAULT g_miss_char
   ,p_base_uom             IN VARCHAR2 DEFAULT g_miss_char
  ) RETURN NUMBER;
--
-- API name    : GetMinimumTotalUVWCapacity {OverLoaded}
-- Type        : Private
-- Function    : Returns the minimum of total unit, total volume and total
--               weight capacity of a location measured in transaction UOM of
--               the actual item.
--               ( Used for capacity calculation parameters )
-- Notes       : refer to notes regarding the corresponding separate unit,
--               volume and weight capacity functions.
FUNCTION GetMinimumTotalUVWCapacity
  ( p_organization_id      IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code    IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id           IN NUMBER   DEFAULT g_miss_num
   ,p_inventory_item_id    IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume          IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume_uom_code IN VARCHAR2 DEFAULT g_miss_char
   ,p_unit_weight          IN NUMBER   DEFAULT g_miss_num
   ,p_unit_weight_uom_code IN VARCHAR2 DEFAULT g_miss_char
   ,p_primary_uom          IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_uom      IN VARCHAR2 DEFAULT g_miss_char
   ,p_base_uom             IN VARCHAR2 DEFAULT g_miss_char
   ,p_location_maximum_units IN NUMBER
   ,p_location_current_units IN NUMBER
   ,p_location_suggested_units IN NUMBER
   ,p_location_available_units IN NUMBER
   ,p_weight_uom_code       IN VARCHAR2
   ,p_max_weight            IN NUMBER
   ,p_current_weight        IN NUMBER
   ,p_suggested_weight      IN NUMBER
   ,p_available_weight      IN NUMBER
   ,p_volume_uom_code       IN VARCHAR2
   ,p_max_cubic_area        IN NUMBER
   ,p_current_cubic_area    IN NUMBER
   ,p_suggested_cubic_area  IN NUMBER
   ,p_available_cubic_area  IN NUMBER
  ) RETURN NUMBER;

--
-- API name    : GetMaximumOccupiedUVWCapacity
-- Type        : Private
-- Function    : Returns the maximum of occupied unit, occupied volume and
--               occupied weight capacity of a location measured in
--               transaction UOM of the actual item.
--               ( Used for capacity calculation parameters )
-- Notes       : refer to notes regarding the corresponding separate unit,
--               volume and weight capacity functions.
FUNCTION GetMaximumOccupiedUVWCapacity
  ( p_organization_id      IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code    IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id           IN NUMBER   DEFAULT g_miss_num
   ,p_inventory_item_id    IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume          IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume_uom_code IN VARCHAR2 DEFAULT g_miss_char
   ,p_unit_weight          IN NUMBER   DEFAULT g_miss_num
   ,p_unit_weight_uom_code IN VARCHAR2 DEFAULT g_miss_char
   ,p_primary_uom          IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_uom      IN VARCHAR2 DEFAULT g_miss_char
   ,p_base_uom             IN VARCHAR2 DEFAULT g_miss_char
   ) RETURN NUMBER;
--
-- API name    : GetMaximumOccupiedUVWCapacity {OverLoaded}
-- Type        : Private
-- Function    : Returns the maximum of occupied unit, occupied volume and
--               occupied weight capacity of a location measured in
--               transaction UOM of the actual item.
--               ( Used for capacity calculation parameters )
-- Notes       : refer to notes regarding the corresponding separate unit,
--               volume and weight capacity functions.
FUNCTION GetMaximumOccupiedUVWCapacity
  ( p_organization_id      IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code    IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id           IN NUMBER   DEFAULT g_miss_num
   ,p_inventory_item_id    IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume          IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume_uom_code IN VARCHAR2 DEFAULT g_miss_char
   ,p_unit_weight          IN NUMBER   DEFAULT g_miss_num
   ,p_unit_weight_uom_code IN VARCHAR2 DEFAULT g_miss_char
   ,p_primary_uom          IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_uom      IN VARCHAR2 DEFAULT g_miss_char
   ,p_base_uom             IN VARCHAR2 DEFAULT g_miss_char
   ,p_location_maximum_units IN NUMBER
   ,p_location_current_units IN NUMBER
   ,p_location_suggested_units IN NUMBER
   ,p_location_available_units IN NUMBER
   ,p_weight_uom_code       IN VARCHAR2
   ,p_max_weight            IN NUMBER
   ,p_current_weight        IN NUMBER
   ,p_suggested_weight      IN NUMBER
   ,p_available_weight      IN NUMBER
   ,p_volume_uom_code       IN VARCHAR2
   ,p_max_cubic_area        IN NUMBER
   ,p_current_cubic_area    IN NUMBER
   ,p_suggested_cubic_area  IN NUMBER
   ,p_available_cubic_area  IN NUMBER
   ) RETURN NUMBER;
--
-- API name    : GetMinimumAvailableUVWCapacity
-- Type        : Private
-- Function    : Returns the minimum of available unit, available volume and
--               available weight capacity of a location measured in
--               transaction UOM of the actual item.
--               ( Used for capacity calculation parameters )
-- Notes       : refer to notes regarding the corresponding separate unit,
--               volume and weight capacity functions.
FUNCTION GetMinimumAvailableUVWCapacity
  ( p_organization_id      IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code    IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id           IN NUMBER   DEFAULT g_miss_num
   ,p_inventory_item_id    IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume          IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume_uom_code IN VARCHAR2 DEFAULT g_miss_char
   ,p_unit_weight          IN NUMBER   DEFAULT g_miss_num
   ,p_unit_weight_uom_code IN VARCHAR2 DEFAULT g_miss_char
   ,p_primary_uom          IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_uom      IN VARCHAR2 DEFAULT g_miss_char
   ,p_base_uom             IN VARCHAR2 DEFAULT g_miss_char
  ) RETURN NUMBER;
--
-- API name    : GetMinimumAvailableUVWCapacity {OverLoaded}
-- Type        : Private
-- Function    : Returns the minimum of available unit, available volume and
--               available weight capacity of a location measured in
--               transaction UOM of the actual item.
--               ( Used for capacity calculation parameters )
-- Notes       : refer to notes regarding the corresponding separate unit,
--               volume and weight capacity functions.
FUNCTION GetMinimumAvailableUVWCapacity
  ( p_organization_id      IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code    IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id           IN NUMBER   DEFAULT g_miss_num
   ,p_inventory_item_id    IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume          IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume_uom_code IN VARCHAR2 DEFAULT g_miss_char
   ,p_unit_weight          IN NUMBER   DEFAULT g_miss_num
   ,p_unit_weight_uom_code IN VARCHAR2 DEFAULT g_miss_char
   ,p_primary_uom          IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_uom      IN VARCHAR2 DEFAULT g_miss_char
   ,p_base_uom             IN VARCHAR2 DEFAULT g_miss_char
   ,p_location_maximum_units IN NUMBER
   ,p_location_current_units IN NUMBER
   ,p_location_suggested_units IN NUMBER
   ,p_location_available_units IN NUMBER
   ,p_weight_uom_code       IN VARCHAR2
   ,p_max_weight            IN NUMBER
   ,p_current_weight        IN NUMBER
   ,p_suggested_weight      IN NUMBER
   ,p_available_weight      IN NUMBER
   ,p_volume_uom_code       IN VARCHAR2
   ,p_max_cubic_area        IN NUMBER
   ,p_current_cubic_area    IN NUMBER
   ,p_suggested_cubic_area  IN NUMBER
   ,p_available_cubic_area  IN NUMBER
  ) RETURN NUMBER;

--
-- API name    : GetMinimumRemainingUVWCapacity
-- Type        : Private
-- Function    : Returns the minimum of remaining available unit, remaining
--               available volume and remaining available weight capacity of
--               a location measured in transaction UOM of the actual item.
--               ( Used for capacity calculation parameters )
-- Notes       : refer to notes regarding the corresponding separate unit,
--               volume and weight capacity functions.
FUNCTION GetMinimumRemainingUVWCapacity
  ( p_organization_id         IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code       IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id              IN NUMBER   DEFAULT g_miss_num
   ,p_inventory_item_id       IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume             IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume_uom_code    IN VARCHAR2 DEFAULT g_miss_char
   ,p_unit_weight             IN NUMBER   DEFAULT g_miss_num
   ,p_unit_weight_uom_code    IN VARCHAR2 DEFAULT g_miss_char
   ,p_primary_uom             IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_uom         IN VARCHAR2 DEFAULT g_miss_char
   ,p_base_uom                IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_quantity    IN NUMBER   DEFAULT g_miss_num
  ) RETURN NUMBER;

--
-- API name    : GetMinimumRemainingUVWCapacity {OverLoaded}
-- Type        : Private
-- Function    : Returns the minimum of remaining available unit, remaining
--               available volume and remaining available weight capacity of
--               a location measured in transaction UOM of the actual item.
--               ( Used for capacity calculation parameters )
-- Notes       : refer to notes regarding the corresponding separate unit,
--               volume and weight capacity functions.
FUNCTION GetMinimumRemainingUVWCapacity
  ( p_organization_id         IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code       IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id              IN NUMBER   DEFAULT g_miss_num
   ,p_inventory_item_id       IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume             IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume_uom_code    IN VARCHAR2 DEFAULT g_miss_char
   ,p_unit_weight             IN NUMBER   DEFAULT g_miss_num
   ,p_unit_weight_uom_code    IN VARCHAR2 DEFAULT g_miss_char
   ,p_primary_uom             IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_uom         IN VARCHAR2 DEFAULT g_miss_char
   ,p_base_uom                IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_quantity    IN NUMBER   DEFAULT g_miss_num
   ,p_location_maximum_units IN NUMBER
   ,p_location_current_units IN NUMBER
   ,p_location_suggested_units IN NUMBER
   ,p_location_available_units IN NUMBER
   ,p_weight_uom_code       IN VARCHAR2
   ,p_max_weight            IN NUMBER
   ,p_current_weight        IN NUMBER
   ,p_suggested_weight      IN NUMBER
   ,p_available_weight      IN NUMBER
   ,p_volume_uom_code       IN VARCHAR2
   ,p_max_cubic_area        IN NUMBER
   ,p_current_cubic_area    IN NUMBER
   ,p_suggested_cubic_area  IN NUMBER
   ,p_available_cubic_area  IN NUMBER
  ) RETURN NUMBER;

-- API name    : GetItemOnHand
-- Type        : Private
-- Function    : Returns on hand stock of a given inventory item
--		 in the transaction UOM.
--               ( Used for capacity calculation parameters )
FUNCTION GetItemOnHand
  ( p_organization_id     IN NUMBER   DEFAULT g_miss_num
   ,p_inventory_item_id   IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code   IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id          IN NUMBER   DEFAULT g_miss_num
   ,p_primary_uom         IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_uom     IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_inventory_item_id IN NUMBER DEFAULT NULL
   ,p_location_current_units IN NUMBER DEFAULT NULL
   ) RETURN NUMBER;

-- API name    : GetTotalOnHand
-- Type        : Private
-- Function    : Returns on hand stock of a given locator
--		 (all items) in the transaction UOM
--               ( Used for capacity calculation parameters )
FUNCTION GetTotalOnHand
  ( p_organization_id     IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code   IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id          IN NUMBER   DEFAULT g_miss_num
   ,p_transaction_uom     IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_inventory_item_id IN NUMBER DEFAULT NULL
   ,p_location_current_units IN NUMBER DEFAULT NULL
   ,p_empty_flag	  IN VARCHAR2 DEFAULT NULL
   ) RETURN NUMBER;

-- API name    : IsItemInLocator
-- Type        : Private
-- Function    : Returns 'Y' if the given item resides in the given
-- 		 locator, 'N' otherwise
FUNCTION IsItemInLocator
 ( p_organization_id	IN NUMBER
  ,p_inventory_item_id  IN NUMBER
  ,p_subinventory_code  IN VARCHAR2
  ,p_locator_id 	IN NUMBER
 ) RETURN VARCHAR2;

-- API name    : GetOuterLpnQuantityRevLot
-- Type        : Private
-- Function    : Returns quantity of the given item, revision, and lot
--               in the outermost LPN containing the given LPN
FUNCTION GetOuterLpnQuantityRevLot
 ( p_lpn_id 		IN NUMBER
  ,p_inventory_item_id 	IN NUMBER
  ,p_revision		IN VARCHAR2
  ,p_lot_number		IN VARCHAR2
) RETURN NUMBER;

-- API name    : GetOuterLpnQuantity
-- Type        : Private
-- Function    : Returns quantity of the given item
--               in the outermost LPN containing the given LPN
FUNCTION GetOuterLpnQuantity
 ( p_lpn_id             IN NUMBER
  ,p_inventory_item_id  IN NUMBER
) RETURN NUMBER;

-- API name    : GetOuterLpnNumOtherItems
-- Type        : Private
-- Function    : Returns number of items - 1
--               in the outermost LPN containing the given LPN
FUNCTION GetOuterLpnNumOtherItems
 ( p_lpn_id             IN NUMBER
) RETURN NUMBER;

-- API name    : GetOuterLpnNumOtherRevs
-- Type        : Private
-- Function    : Returns number of revisions of this item - 1
--               in the outermost LPN containing the given LPN
FUNCTION GetOuterLpnNumOtherRevs
 ( p_lpn_id             IN NUMBER
  ,p_inventory_item_id  IN NUMBER
) RETURN NUMBER;

-- API name    : GetOuterLpnNumOtherRevs
-- Type        : Private
-- Function    : Returns number of lots of this item - 1
--               in the outermost LPN containing the given LPN
FUNCTION GetOuterLpnNumOtherLots
 ( p_lpn_id             IN NUMBER
  ,p_inventory_item_id  IN NUMBER
) RETURN NUMBER;


-- API name    : GetLpnQuantityRevLot
-- Type        : Private
-- Function    : Returns quantity of the given item, revision, and lot
--               in the given LPN
FUNCTION GetLpnQuantityRevLot
 ( p_lpn_id 		IN NUMBER
  ,p_inventory_item_id 	IN NUMBER
  ,p_revision		IN VARCHAR2
  ,p_lot_number		IN VARCHAR2
) RETURN NUMBER;

-- API name    : GetLpnQuantity
-- Type        : Private
-- Function    : Returns quantity of the given item
--               in the given LPN
FUNCTION GetLpnQuantity
 ( p_lpn_id             IN NUMBER
  ,p_inventory_item_id  IN NUMBER
) RETURN NUMBER;

-- API name    : GetLpnNumOtherItems
-- Type        : Private
-- Function    : Returns number of items - 1
--               in the the given LPN
FUNCTION GetLpnNumOtherItems
 ( p_lpn_id             IN NUMBER
) RETURN NUMBER;

-- API name    : GetLpnNumOtherRevs
-- Type        : Private
-- Function    : Returns number of revisions of this item - 1
--               in the given LPN
FUNCTION GetLpnNumOtherRevs
 ( p_lpn_id             IN NUMBER
  ,p_inventory_item_id  IN NUMBER
) RETURN NUMBER;

-- API name    : GetLpnNumOtherLots
-- Type        : Private
-- Function    : Returns number of lots of this item - 1
--               in the the given LPN
FUNCTION GetLpnNumOtherLots
 ( p_lpn_id             IN NUMBER
  ,p_inventory_item_id  IN NUMBER
) RETURN NUMBER;

-- API name    : GetLpnNumNestedLevels
-- Type        : Private
-- Function    : Returns number of LPNs between this LPN and the outermost
--		 LPN containing this LPN
FUNCTION GetLpnNumNestedLevels
 ( p_lpn_id             IN NUMBER
) RETURN NUMBER;


--==============================================================
-- API name    : GetPOHeaderLineID
-- Type        : Private
-- Function    : Returns PO Header ID or Line ID based on Move Order Line
--               Reference and Reference ID and header or line flag.
--               ( Used for join condition in seed data  )
FUNCTION GetPOHeaderLineID
  ( p_transaction_source_type_id  IN NUMBER
   ,p_reference                   IN VARCHAR2   DEFAULT g_miss_char
   ,p_reference_id                IN NUMBER     DEFAULT g_miss_num
   ,p_header_flag                 IN VARCHAR2   DEFAULT 'N'
   ,p_line_flag                   IN VARCHAR2   DEFAULT 'N'
   ) RETURN NUMBER;

-- API name    : GetProxPickOrder
-- Type        : Private
-- Function    : Returns the minimum distance between this locator
--               and the nearest locator containing the item,
--               as calculated using locator picking order
--               ( Used for building rules)
FUNCTION GetProxPickOrder(
   p_organization_id	IN NUMBER,
   p_inventory_item_id  IN NUMBER,
   p_subinventory_code  IN VARCHAR2,
   p_locator_id 	IN NUMBER
   ) RETURN NUMBER;

-- API name    : GetProxCoordinates
-- Type        : Private
-- Function    : Returns the minimum distance between this locator
--               and the nearest locator containing the item,
--               as calculated using xyz coordinates
--               ( Used for building rules)
FUNCTION GetProxCoordinates(
   p_organization_id	IN NUMBER,
   p_inventory_item_id  IN NUMBER,
   p_subinventory_code  IN VARCHAR2,
   p_locator_id 	IN NUMBER
   ) RETURN NUMBER;

-- API name    : GetNumOtherItems
-- Type        : Private
-- Function    : Returns the number of items within the locator
--               other than the item passed in as a parameter
--               ( Used for building rules)
FUNCTION GetNumOtherItems(
   p_organization_id	IN NUMBER,
   p_inventory_item_id  IN NUMBER,
   p_subinventory_code  IN VARCHAR2,
   p_locator_id 	IN NUMBER,
   p_locator_inventory_item_id IN NUMBER DEFAULT NULL
   ) RETURN NUMBER;

-- API name    : GetNumOtherLots
-- Type        : Private
-- Function    : Returns the number of lots for the given item
--               within the locator other than the given lot
--               ( Used for building rules)
FUNCTION GetNumOtherLots(
   p_organization_id	IN NUMBER,
   p_inventory_item_id  IN NUMBER,
   p_subinventory_code  IN VARCHAR2,
   p_locator_id 	IN NUMBER,
   p_lot_number 	IN VARCHAR2
   ) RETURN NUMBER;

-- API name    : GetNumOtherRevisions
-- Type        : Private
-- Function    : Returns the number of revisions for the given item
--               within the locator other than the given revision
--               ( Used for building rules)
FUNCTION GetNumOtherRevisions(
   p_organization_id	IN NUMBER,
   p_inventory_item_id  IN NUMBER,
   p_subinventory_code  IN VARCHAR2,
   p_locator_id 	IN NUMBER,
   p_revision   	IN VARCHAR2
   ) RETURN NUMBER;

-- API name    : GetNumEmptyLocators
-- Type        : Private
-- Function    : Returns the number of empty locators in the given
--               subinventory and organization.
--               ( Used for building rules)
FUNCTION GetNumEmptyLocators(
         p_organization_id      IN      NUMBER
        ,p_subinventory_code    IN      VARCHAR2
) RETURN NUMBER;

--
--==============================================================
-- API name    : GetSOHeaderLineID
-- Type        : Private
-- Function    : Returns Sale Order Header ID or Line ID based
--               on Move Order Line reference and Reference ID
--               and header or line flag.
--               ( Used for join condition in seed data  )

FUNCTION GetSOHeaderLineID
  ( p_line_id                     IN NUMBER
   ,p_transaction_source_type_id IN NUMBER      DEFAULT g_miss_num
   ,p_reference                   IN VARCHAR2   DEFAULT g_miss_char
   ,p_reference_id                IN NUMBER     DEFAULT g_miss_num
   ,p_header_flag                 IN VARCHAR2   DEFAULT 'N'
   ,p_line_flag                   IN VARCHAR2   DEFAULT 'N'
   ) RETURN NUMBER;

FUNCTION  CART_LPN_CONTAINS_ENTIRE_DEL
  (p_lpn_id IN NUMBER,
   p_delivery_id IN NUMBER,
   p_business_flow_code IN NUMBER)
  return VARCHAR2;

FUNCTION GetEarliestReceiptDate
  ( p_org_id                     IN NUMBER
    ,p_item_id                   IN NUMBER
    ,p_sub                       IN VARCHAR2
    ,p_loc_id                    IN NUMBER       DEFAULT NULL
    ,p_lot                       IN VARCHAR2     DEFAULT NULL
    ,p_rev                       IN VARCHAR2     DEFAULT NULL
   ) RETURN Date;

FUNCTION IS_WIP_TRANSACTION
  (p_transaction_temp_id IN NUMBER)
  RETURN VARCHAR2;

FUNCTION IS_WIP_MOVE_ORDER(p_header_id IN NUMBER)
  RETURN VARCHAR2;

/*LPN Status Project*/
FUNCTION GET_MATERIAL_STATUS(
           	p_status_id                IN NUMBER DEFAULT NULL)
           RETURN VARCHAR2;
/*LPN Status Project*/

FUNCTION GET_PROJECT_ATTRIBUTE(
         P_ATTRIBUTE_TYPE             IN VARCHAR2 DEFAULT g_miss_char,
         P_INVENTORY_ORGANIZATION_ID  IN NUMBER   DEFAULT g_miss_num,
         P_PROJECT_ID                 IN NUMBER   DEFAULT g_miss_num)
      RETURN VARCHAR2;

END wms_parameter_pvt;

/
