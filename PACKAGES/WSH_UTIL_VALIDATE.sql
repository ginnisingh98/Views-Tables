--------------------------------------------------------
--  DDL for Package WSH_UTIL_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_UTIL_VALIDATE" AUTHID CURRENT_USER as
/* $Header: WSHUTVLS.pls 120.2.12010000.4 2010/04/22 12:13:59 selsubra ship $ */




TYPE cont_def_info_rec_type IS RECORD(
   master_container_item_id   NUMBER,
   detail_container_item_id   NUMBER,
   key                        NUMBER
);
TYPE ignore_plan_rec_type IS RECORD(
   organization_id   NUMBER,
   carrier_id        NUMBER,
   ship_method_code  VARCHAR2(30),
   ignore_for_planning  VARCHAR2(1)
);

TYPE cont_def_info_tab_type is table of cont_def_info_rec_type
                   INDEX BY BINARY_INTEGER;

TYPE ignore_plan_tab_type is table of ignore_plan_rec_type
                   INDEX BY BINARY_INTEGER;


  TYPE item_info_rec_type IS RECORD(
     organization_id  NUMBER,
     inventory_item_id NUMBER,
     primary_uom_code VARCHAR2(3),
     description      VARCHAR2(240),
     hazard_class_id  NUMBER,
     weight_uom_code  VARCHAR2(3),
     unit_weight      NUMBER,
     volume_uom_code  VARCHAR2(3),
     unit_volume      NUMBER

  );
  TYPE item_info_tab_type IS TABLE OF item_info_rec_type
                                           INDEX BY BINARY_INTEGER;

--bms
C_HASH_BASE CONSTANT NUMBER := 1;
C_HASH_SIZE CONSTANT NUMBER := 33554432 ; --power(2, 25)
C_IDX_LIMT NUMBER := 2147483648;

--===================
-- PROCEDURES
--===================
--========================================================================
-- PROCEDURE : Validate_Org
--
-- COMMENT   : Validates Organization_id and Organization_code against view
--             org_organization_definitions. If both values are
--             specified then only Org_Id is used
--========================================================================

  PROCEDURE Validate_Org
        (p_org_id          IN OUT NOCOPY  NUMBER,
         p_org_code        IN     VARCHAR2,
         x_return_status   OUT NOCOPY     VARCHAR2);

--========================================================================
-- PROCEDURE : Validate_Location
--
-- COMMENT   : Validates Location_id and Location_code against view
--             hr_locations. If both values are specified then only
--             Location_id is used
--
-- HISTORY   : Bug# 1924574 changes for hr_locations (8/15/01), Defaulting
--             p_location_code to NULL
--========================================================================

  PROCEDURE Validate_Location
        (p_location_id      IN OUT NOCOPY  NUMBER,
         p_location_code    IN     VARCHAR2 DEFAULT NULL,
         x_return_status    OUT NOCOPY     VARCHAR2,
         p_isWshLocation    IN  BOOLEAN DEFAULT FALSE,
         p_caller           IN  VARCHAR2 DEFAULT NULL);

--========================================================================
-- PROCEDURE : Validate_Lookup
--
-- COMMENT   : Validates Lookup_code and Meaning against view fnd_lookups.
--             If both values are specified then only Lookup_code is used
--========================================================================

  PROCEDURE Validate_Lookup
        (p_lookup_type                  IN     VARCHAR2,
         p_lookup_code                  IN OUT NOCOPY  VARCHAR2,
         p_meaning                      IN     VARCHAR2,
         x_return_status                OUT NOCOPY     VARCHAR2);

--========================================================================
-- PROCEDURE : Validate_Customer
--
-- COMMENT   : Validates Customer_id/Customer_number against
--             hz_cust_accounts. If both values are specified then only
--             Customer_Id is used
--========================================================================

  PROCEDURE Validate_Customer
        (p_customer_id     IN OUT NOCOPY  NUMBER,
         p_customer_number IN     VARCHAR2,
         x_return_status   OUT NOCOPY     VARCHAR2);

--========================================================================
--========================================================================
-- PROCEDURE : Validate_Contact
--
-- COMMENT   : Validates Contact_id against view
--             hz_cust_accounts. If both values are specified then only
--             Customer_Id is used
--========================================================================

  PROCEDURE Validate_Contact
        (p_contact_id     IN OUT NOCOPY  NUMBER,
         x_return_status   OUT NOCOPY     VARCHAR2);

--========================================================================
-- PROCEDURE : Validate_Quantity
-- PROCEDURE : Validate_Quantity
--
-- COMMENT   : Validates if quantity is non-negative and an integer.
--========================================================================

  PROCEDURE Validate_Quantity
        (p_quantity        IN  NUMBER ,
         x_return_status   OUT NOCOPY  VARCHAR2 );

--========================================================================
-- PROCEDURE : Validate_Negative
--
-- COMMENT   : Validates if value is non-negative
--========================================================================
/*
  PROCEDURE Validate_Negative
        (p_value           IN  NUMBER,
         x_return_status   OUT NOCOPY  VARCHAR2);
*/


--procedure added for Bug # 3266333
--========================================================================
-- PROCEDURE : Validate_Negative
--
-- COMMENT   : Validates if value is non-negative and shows a message
--             along with the attribute/field name which has a negative value.
--========================================================================

PROCEDURE Validate_Negative
	(p_value         IN     NUMBER,
	 p_field_name    IN     VARCHAR2 DEFAULT NULL,
         x_return_status OUT NOCOPY  VARCHAR2);



--========================================================================
-- PROCEDURE : Validate_Currency
--
-- COMMENT   : Validates Currency_code and Currency_Name against
--             table fnd_currencies_vl. If both values are specified then
--             only Currency_code is used. p_amount if specified is
--             checked for correct precision
--             If p_otm_enabled is 'Y', rounds p_amount using FND precision
--             for the input currency
--========================================================================

  PROCEDURE Validate_Currency
        (p_currency_code                IN OUT NOCOPY  VARCHAR2,
         p_currency_name                IN     VARCHAR2,
         p_amount                       IN     NUMBER,
         p_otm_enabled                  IN  VARCHAR2 DEFAULT NULL, -- OTM R12
         x_return_status                OUT NOCOPY   VARCHAR2,
         x_adjusted_amount              OUT NOCOPY   NUMBER); -- OTM R12

--========================================================================
-- PROCEDURE : Validate_Uom
--
-- COMMENT   : Validates UOM_Code and UOM Description against table
--             mtl_units_of_measure. If both values are specified then
--             only UOM_Code is used. Type and Organization are required
--             p_type = 'WEIGHT', 'VOLUME'
--========================================================================

  PROCEDURE  Validate_Uom
        (p_type                         IN      VARCHAR2,
         p_organization_id              IN      NUMBER,
         p_uom_code                     IN  OUT NOCOPY  VARCHAR2,
         p_uom_desc                     IN      VARCHAR2,
         x_return_status                OUT NOCOPY      VARCHAR2);

--========================================================================
-- PROCEDURE : Validate_User
--
-- COMMENT   : Validates User_id and User_name against table fnd_user
--             If both values are specified then only User_id is used
--========================================================================

  PROCEDURE  Validate_User
        (p_user_id                      IN OUT NOCOPY  NUMBER,
         p_user_name                    IN VARCHAR2,
         x_return_status                OUT NOCOPY  VARCHAR2);

--========================================================================
-- PROCEDURE : Validate_Ship_Method
--
-- COMMENT   : Validates Ship_Method_Code/Name against view fnd_lookup_values_vl.
--             If both are specified then only Ship_Method_Code is used.
--========================================================================

  PROCEDURE Validate_Ship_Method
        (p_ship_method_code     IN OUT NOCOPY VARCHAR2,
         p_ship_method_name     IN OUT NOCOPY VARCHAR2,
         x_return_status        OUT    NOCOPY VARCHAR2);

--========================================================================
-- PROCEDURE : Validate_Freight_Terms
--
-- COMMENT   : Validates Freight_Terms_Code by calling the
--             Validate_Lookup_Code procedure.
--========================================================================

  PROCEDURE Validate_Freight_Terms
        (p_freight_terms_code IN OUT NOCOPY  VARCHAR2 ,
         p_freight_terms_name IN     VARCHAR2,
         x_return_status      OUT NOCOPY     VARCHAR2 );

--========================================================================
-- PROCEDURE : Validate_FOB
--
-- COMMENT   : Validates FOB_Code by calling Validate_Lookup_Code
--========================================================================

  PROCEDURE Validate_FOB
        (p_fob_code      IN OUT NOCOPY  VARCHAR2 ,
         p_fob_name      IN     VARCHAR2 ,
         x_return_status OUT NOCOPY     VARCHAR2 );

--========================================================================
-- PROCEDURE : Validate_Flexfields
--
-- COMMENT   : Validates Flexfield id and concatenated segments
--   Logic used :
--	  if id is not null
--        validate id
--     else
--       if id is null
-- 	       begin
--            get delimeter
--            concatenate segments
--            validate concatenated segments
--          exception
--            handle exception
--          end
--          if item is not null
--             validate item
--          end if;
--        end if;
--     end if;
--========================================================================

  PROCEDURE Validate_Flexfields(
			p_id                IN OUT NOCOPY  NUMBER,
			p_concat_segs       IN 	VARCHAR2,
			p_app_short_name    IN   VARCHAR2,
			p_key_flx_code      IN   VARCHAR2,
   		     p_struct_number 	IN   NUMBER,
			p_org_id            IN   NUMBER,
			p_seg_array         IN   FND_FLEX_EXT.SegmentArray,
			p_val_or_ids        IN   VARCHAR2,
               p_wh_clause         IN   VARCHAR2 DEFAULT NULL,
               x_flag              OUT NOCOPY  BOOLEAN);

--========================================================================
-- PROCEDURE : Validate_Item
--
-- COMMENT   : Validates Inventory_Item_id/Concatenated name/Segment array
--             using FND APIs. Item id takes precedence over the other validations.
--========================================================================

   PROCEDURE Validate_Item(
	  p_inventory_item_id IN OUT NOCOPY  NUMBER,
	  p_inventory_item    IN     VARCHAR2,
       p_organization_id   IN     NUMBER,
	  p_seg_array         IN     FND_FLEX_EXT.SegmentArray,
       x_return_status     OUT NOCOPY  VARCHAR2,
          p_item_type      IN VARCHAR2 DEFAULT 'STD_ITEM');

-- LINE SPECIFIC VALIDATIONS BELOW --

--========================================================================
-- PROCEDURE : Validate_Boolean
--
-- COMMENT   : Validates data type of boolean
--========================================================================
PROCEDURE Validate_Boolean(
	p_flag       		IN     VARCHAR2,
	x_return_status  		OUT NOCOPY  VARCHAR2
);

--========================================================================
-- PROCEDURE : Validate_Released_Status
--
-- COMMENT   : Validates released_status
--========================================================================
PROCEDURE Validate_Released_Status(
	p_released_status IN     VARCHAR2,
	x_return_status  		OUT NOCOPY  VARCHAR2
);

-- CONTAINER SPECIFIC VALIDATIONS BELOW --

-- DELIVERY SPECIFIC VALIDATIONS BELOW --

--========================================================================
-- PROCEDURE : Validate_Delivery_Name
--
-- COMMENT   : Validates Delivery_id/Delivery_Name against table
--             wsh_new_deliveries. If both values are specified then only
--             delivery_id is used
--========================================================================

  PROCEDURE Validate_Delivery_Name
        (p_delivery_id    IN OUT NOCOPY  NUMBER ,
         p_delivery_name  IN     VARCHAR2 ,
         x_return_status  OUT NOCOPY     VARCHAR2 );

--========================================================================
-- PROCEDURE : Validate_Report_Set
--
-- COMMENT   : Validates Report_set_id/Report_set name against table
--             wsh_report_sets. If both values are specified then only
--             report_set_id is used
--========================================================================

  PROCEDURE Validate_Report_Set
        (p_report_set_id    IN OUT NOCOPY  NUMBER ,
         p_report_set_name  IN     VARCHAR2 ,
         x_return_status    OUT NOCOPY     VARCHAR2 );

--========================================================================
-- PROCEDURE : Validate_Loading_Order
--
-- COMMENT   : Validates Loading_Order_Flag/Loading_order_desc by
--             calling Validate_lookup_code. If both values are
--             specified then only Loading_order_desc is used
--========================================================================

  PROCEDURE Validate_Loading_Order
        (p_loading_order_flag IN OUT NOCOPY  VARCHAR2 ,
         p_loading_order_desc IN     VARCHAR2 ,
         x_return_status      OUT NOCOPY     VARCHAR2 );

-- STOP SPECIFIC VALIDATIONS BELOW --

--========================================================================
-- PROCEDURE : Validate_Stop_Name
--
-- COMMENT   : Validates Stop_id OR
--             Trip_id+Stop_Location_id+Planned_Departure_date against table
--             wsh_trips. If both validations are possible then only
--             stop_id is validated
--========================================================================

  PROCEDURE Validate_Stop_Name
        (p_stop_id        IN OUT NOCOPY  NUMBER ,
         p_trip_id        IN     NUMBER ,
	    p_stop_location_id IN   NUMBER ,
	    p_planned_dep_date IN   DATE,
         x_return_status  OUT NOCOPY     VARCHAR2 );

-- TRIP SPECIFIC VALIDATIONS BELOW --

--========================================================================
-- PROCEDURE : Validate_Trip_Name
--
-- COMMENT   : Validates Trip_id/Trip_Name against table
--             wsh_trips. If both values are specified then only
--             trip_id is used
--========================================================================

  PROCEDURE Validate_Trip_Name
        (p_trip_id        IN OUT NOCOPY  NUMBER ,
         p_trip_name      IN     VARCHAR2 ,
         x_return_status  OUT NOCOPY     VARCHAR2 );

--========================================================================
-- PROCEDURE : Validate_Trip_MultiStops
-- 4106444 -skattama
-- COMMENT   : Validates for Trip_id if mode is other then
--             'TRUCK', the number of stops should not be more
--             than 2.
--========================================================================

  PROCEDURE Validate_Trip_MultiStops
        (p_trip_id        IN  NUMBER ,
         p_mode_of_transport  IN     VARCHAR2 ,
         x_return_status  OUT NOCOPY     VARCHAR2 );

--========================================================================
-- PROCEDURE : Validate_Order_uom
--
-- COMMENT   : Validates ordered quantity uom view mtl_item_uoms_view.
--             Based on inventory_item_id and organization_id
--========================================================================
PROCEDURE Validate_Order_uom(
	p_organization_id  IN     NUMBER,
	p_inventory_item_id IN    NUMBER,
	p_unit_of_measure  IN 	 VARCHAR2,
	x_uom_code         IN OUT NOCOPY  VARCHAR2,
	x_return_status       OUT NOCOPY  VARCHAR2);

--========================================================================
-- FUNCTION : Check_Wms_Org
--
-- COMMENT   : Check if the Organization is WMS enabled.
--             If Yes, Return 'Y'. Otherwise 'N'
--========================================================================

  FUNCTION Check_Wms_Org
		(p_organization_id        IN  NUMBER) RETURN VARCHAR2 ;

--Harmonizing Project I --heali
PROCEDURE validate_from_to_dates (
	p_from_date 	IN DATE,
	p_to_date 	IN DATE,
	x_return_status OUT NOCOPY  VARCHAR2);

PROCEDURE Validate_Trip_status (
	p_trip_id	IN NUMBER,
        p_action        IN VARCHAR2,
	x_return_status	OUT NOCOPY  VARCHAR2);
--Harmonizing Project I --heali

-- I Harmonization: rvishnuv *******

--========================================================================
-- PROCEDURE : Validate_Carrier
--
-- COMMENT   : Check if the Carrier is a valid carrier or not.
--========================================================================
PROCEDURE Validate_Carrier(
            p_carrier_name  IN VARCHAR2,
            x_carrier_id    IN OUT NOCOPY NUMBER,
            x_return_status OUT NOCOPY VARCHAR2);

--========================================================================
-- PROCEDURE : Validate_Freight_Carrier
--
-- COMMENT   : This API checks if the inputs ship method, carrier, and service level
--             are valid values.
--             Also if ship method is a valid input, then, based on the organization,
--             it derives the carrier, service level and mode of transport.
--             Also, if the ship method is null and if all the remaining three
--             components are defined, then based on the organization, it derives
--             the ship method.
--
--             p_entity_type can have values of 'TRIP' or 'DLVY'.
--             p_entity_id should contain either trip_id or delivery_id
--             depending on the p_entity_type.
--========================================================================
PROCEDURE Validate_Freight_Carrier(
            p_ship_method_name     IN OUT NOCOPY VARCHAR2,
            x_ship_method_code     IN OUT NOCOPY VARCHAR2,
            p_carrier_name         IN     VARCHAR2,
            x_carrier_id           IN OUT NOCOPY NUMBER,
            x_service_level        IN OUT NOCOPY VARCHAR2,
            x_mode_of_transport    IN OUT NOCOPY VARCHAR2,
            p_entity_type          IN     VARCHAR2,
            p_entity_id            IN     NUMBER,
            p_organization_id      IN     NUMBER DEFAULT NULL,
            x_return_status        OUT    NOCOPY VARCHAR2,
            p_caller               IN     VARCHAR2 DEFAULT 'WSH_PUB');
-- I Harmonization: rvishnuv *******

    -- ---------------------------------------------------------------------
    -- Procedure:	Find_Item_Type
    --
    -- Parameters:
    --
    -- Description:  This procedure gives the item type (either container_item or vehicle_item) for the given
    --                 inventory item id and organization id.
    -- Created:   Harmonization Project. Patchset I. kvenkate
    -- -----------------------------------------------------------------------
PROCEDURE Find_Item_Type(
          p_inventory_item_id  IN  NUMBER,
          p_organization_id    IN  NUMBER,
          x_item_type          OUT NOCOPY VARCHAR2,
          x_return_status      OUT NOCOPY VARCHAR2);
-- I Harmonization: kvenkate ***

  FUNCTION Get_Org_Type (
             p_organization_id   IN   NUMBER,
             p_event_key         IN   VARCHAR2 DEFAULT NULL,
             p_delivery_id       IN   NUMBER DEFAULT NULL,
             p_delivery_detail_id IN  NUMBER DEFAULT NULL,
             p_msg_display        IN  VARCHAR2 DEFAULT 'Y',
             x_return_status     OUT NOCOPY   VARCHAR2
            ) RETURN VARCHAR2;



--========================================================================
-- PROCEDURE : get_item_info
--
-- PARAMETERS: p_organization_id       Item's Organization Id
--             p_inventory_item_id     Inventory Item Id
--             x_Item_info_rec         stores the item information
--             x_return_status         return status
-- COMMENT   : This API manages a cache, which contains item information
--             The information on the cached is retrieved based on the
--             organization id and inventory id.  If this information does not
--             exist in the cache, it will be queried and added to it.
--             If there is a collision in the cache, then the new information
--             will be retrieved and will replace the old ones
--========================================================================

  PROCEDURE get_item_info (
                                 p_organization_id IN NUMBER,
                                 p_inventory_item_id IN NUMBER,
                                 x_Item_info_rec OUT NOCOPY
                                                          item_info_rec_type,
                                 x_return_status OUT NOCOPY VARCHAR2);


--========================================================================
-- PROCEDURE : Default_container
--
-- PARAMETERS: p_item_id                  Item's Organization Id
--             x_master_container_item_id default value for master container
--             x_detail_container_item_id default value for detail container
--             x_return_status         return status
-- COMMENT   : This API calculates the default value for the fields
--             detail_container_item_id and master_container_item_id.  It then
--             caches these values for future calls.
--========================================================================

  PROCEDURE Default_container (
                                 p_item_id IN NUMBER,
                                 x_master_container_item_id OUT NOCOPY NUMBER,
                                 x_detail_container_item_id OUT NOCOPY NUMBER,
                                 x_return_status OUT NOCOPY VARCHAR2);

--========================================================================
-- PROCEDURE : Calc_ignore_for_planning
--
-- PARAMETERS: p_organization_id
--             p_carrier_id
--             p_ship_method_code
--             p_tp_installed
--             x_return_status         return status
--             p_otm_installed         optional parameter to pass shipping
--                                     parameter OTM_INSTALLED
--             p_client_id             clientId value. Consider OTM enabled value on Client.
--
-- COMMENT   : This procedure calulates the value for the field
--             ignore_for_planning_flag
--========================================================================

  PROCEDURE Calc_ignore_for_planning(
                        p_organization_id IN NUMBER,
                        p_carrier_id   IN  NUMBER,
                        p_ship_method_code    IN  VARCHAR2,
                        p_tp_installed        IN  VARCHAR2,
                        p_caller              IN  VARCHAR2,
                        x_ignore_for_planning OUT NOCOPY VARCHAR2,
                        x_return_status OUT NOCOPY VARCHAR2,
                        p_otm_installed       IN VARCHAR2 DEFAULT NULL, --OTM R12 Org-Specific
                        p_client_id           IN NUMBER DEFAULT NULL);  -- LSP PROJECT

--=============================================================================
--      API name        : validate_fob
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_fob             NUMBER
--      OUT             : x_return_status   VARCHAR2
--==============================================================================
PROCEDURE validate_fob(
           p_fob                IN        VARCHAR2,
           x_return_status      OUT     NOCOPY  VARCHAR2);

--=============================================================================
 --      API name        : validate_freight_terms
 --      Type            : Private.
 --      Function        :
 --      Pre-reqs        : None.
 --      Parameters      :
 --      IN              : p_freight_terms_code NUMBER
 --      OUT             : x_return_status      VARCHAR2
 --=============================================================================
 PROCEDURE validate_freight_terms(
           p_freight_terms_code  IN       VARCHAR2,
           x_return_status       OUT    NOCOPY   VARCHAR2);


PROCEDURE validate_supplier_location
            (
               p_vendor_id      IN           NUMBER,
               p_party_id       IN           NUMBER,
               p_location_id    IN           NUMBER,
               x_return_status  OUT NOCOPY   VARCHAR2
            ) ;

--============================================================================
-- START Bug # 3266659:  PICK RELEASE BATCH PUBLIC API
--=============================================================================


--========================================================================
-- PROCEDURE : Validate_Pick_Group_Rule_Name
--
-- COMMENT   : Validates Pick_Grouping_Rule_Id/Pick_Grouping_Rule_Name against table
--             wsh_pick_grouping_rules. If both values are specified then only
--             Pick_Grouping_Rule_Id is used
--========================================================================

  PROCEDURE Validate_Pick_Group_Rule_Name
        (p_pick_grouping_rule_id      IN   OUT NOCOPY NUMBER,
         p_pick_grouping_rule_name    IN              VARCHAR2,
         x_return_status              OUT  NOCOPY     VARCHAR2);



--========================================================================
-- PROCEDURE : Validate_Pick_Seq_Rule_Name
--
-- COMMENT   : Validates Pick_Sequence_Rule_Id/Pick_Sequence_Rule_Name against table
--             wsh_pick_sequence_rules. If both values are specified then only
--             Pick_Sequence_Rule_Id is used
--========================================================================

  PROCEDURE  Validate_Pick_Seq_Rule_Name
        (p_Pick_Sequence_Rule_Id      IN OUT NOCOPY  NUMBER,
         p_Pick_Sequence_Rule_Name    IN             VARCHAR2,
         x_return_status              OUT NOCOPY     VARCHAR2 );


--========================================================================
-- PROCEDURE : Validate_Ship_Con_Rule_Name
--
-- COMMENT   : Validates Ship_Confirm_Rule_Id/Ship_Confirm_Rule_Name against table
--             wsh_ship_confirm_rules. If both values are specified then only
--             Ship_Confirm_Rule_Id is used
--========================================================================

  PROCEDURE  Validate_Ship_Con_Rule_Name
        (p_ship_confirm_rule_id      IN OUT NOCOPY  NUMBER ,
         p_ship_confirm_rule_name    IN             VARCHAR2,
         x_return_status             OUT NOCOPY     VARCHAR2 );


--========================================================================
-- PROCEDURE : Validate_Picking_Batch_Name
--
-- COMMENT   : Validates picking_Batch_Id/Picking_Batch_Name against table
--             wsh_picking_Batches. If both values are specified then only
--             picking_Batch_Id is used
--========================================================================

  PROCEDURE  Validate_Picking_Batch_Name
        (p_picking_Batch_id      IN OUT NOCOPY NUMBER ,
         p_picking_Batch_name    IN            VARCHAR2 ,
         x_return_status         OUT NOCOPY    VARCHAR2 );

-- END Bug #3266659

-- Bug#3880569: Adding a new procedure Validate_Active_SM
--========================================================================
-- PROCEDURE : Validate_Active_SM
--
-- COMMENT   : Validates Active Ship_Method_Code/Name against wsh_carrier_services.
--             If both values are specified then only Ship_Method_Code is used
--========================================================================

  PROCEDURE Validate_Active_SM
        (p_ship_method_code     IN OUT NOCOPY VARCHAR2,
         p_ship_method_name     IN OUT NOCOPY VARCHAR2,
         x_return_status        OUT    NOCOPY VARCHAR2);



/*======================================================================
PROCEDURE : ValidateActualDepartureDate

COMMENT : This is just a wrapper around the function
          WSH_UITL_CORE.ValidateActualDepartureDate

          This procedure calls a similar function in WSH_UTIL_CORE
          and logs an error message if the actual departure date is
          not valid.

HISTORY : rlanka    03/08/2005    Created
=======================================================================*/
PROCEDURE ValidateActualDepartureDate
        (p_ship_confirm_rule_id IN NUMBER,
         p_actual_departure_date IN DATE,
         x_return_status OUT NOCOPY VARCHAR2);

-- Standalone Project - Start
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Validate_SR_Organization
--
-- PARAMETERS:
--       p_organization_id => Organization Id
--       x_return_status   => Return Status of API (Either S,E,U)
--
-- COMMENT:
--       API to validate whether Organization is WMS enabled and NOT Process
--       manufacturing enabled.
-- HISTORY :
--       ueshanka    19/Nov/2008    Created
--=============================================================================
--
PROCEDURE Validate_SR_Organization(
          p_organization_id  IN NUMBER,
          x_return_status    OUT NOCOPY VARCHAR2);
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Validate_Locator_Code
--
-- PARAMETERS:
--       p_locator_code    => Locator Code
--       p_organization_id => Organization Id
--       x_locator_id      => Locator Id
--       x_return_status   => Return Status of API (Either S,E,U)
--
-- COMMENT:
--       API to derive Locator Id based on Locator Code and Organization passed
-- HISTORY :
--       ueshanka    19/Nov/2008    Created
--=============================================================================
--
PROCEDURE Validate_Locator_Code(
          p_locator_code     IN VARCHAR2,
          p_organization_id  IN NUMBER,
          x_locator_id       OUT NOCOPY NUMBER,
          x_return_status    OUT NOCOPY VARCHAR2);
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Validate_Item
--
-- PARAMETERS:
--       p_item_number       => Inventory Item Name
--       p_organization_id   => Organization Id
--       x_inventory_item_id => Inventory Item Id
--       x_return_status     => Return Status of API (Either S,E,U)
--
-- COMMENT:
--       API to derive Inventory Item Id based on Item Number and Organization
--       passed
-- HISTORY :
--       ueshanka    19/Nov/2008    Created
--=============================================================================
--
PROCEDURE Validate_Item(
          p_item_number       IN VARCHAR2,
          p_organization_id   IN NUMBER,
          x_inventory_item_id OUT NOCOPY NUMBER,
          x_return_status     OUT NOCOPY VARCHAR2);
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Validate_Customer_Item
--
-- PARAMETERS:
--       p_item_number       => Inventory Item Name
--       p_customer_id       => SoldTo Customer Id
--       p_address_id        => ShipTo Customer Address Id
--       x_customer_item_id  => Customer Item Id
--       x_return_status     => Return Status of API (Either S,E,U)
--
-- COMMENT:
--       API to derive Customer Item Id based on Item Number, Customer Id and
--       Customer Address Id passed.
-- HISTORY :
--       ueshanka    19/Nov/2008    Created
--=============================================================================
--
PROCEDURE Validate_Customer_Item(
          p_item_number      IN VARCHAR2,
          p_customer_id      IN NUMBER,
          p_address_id       IN VARCHAR2,
          x_customer_item_id OUT NOCOPY NUMBER,
          x_return_status    OUT NOCOPY VARCHAR2);
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Validate_Ship_Method
--
-- PARAMETERS:
--       p_organization_id   => Organization Id
--       p_carrier_code      => Carrier Code
--       p_service_level     => Service Level
--       p_mode_of_transport => Mode of Transport
--       x_ship_method_code  => Ship Method Code
--       x_return_status     => Return Status of API (Either S,E,U)
--
-- COMMENT:
--       API to derive Ship Method Code based on Carrier, Service Level, Mode
--       of Transport and Organization passed.
-- HISTORY :
--       ueshanka    19/Nov/2008    Created
--=============================================================================
--
PROCEDURE Validate_Ship_Method(
          p_organization_id   IN NUMBER,
          p_carrier_code      IN VARCHAR2,
          p_service_level     IN VARCHAR2,
          p_mode_of_transport IN VARCHAR2,
          x_ship_method_code  OUT NOCOPY VARCHAR2,
          x_return_status     OUT NOCOPY VARCHAR2);

-- Standalone Project - End
--

--========================================================================
-- PROCEDURE : Validate_Freight_Code        Private
--
-- PARAMETERS: p_freight_code          Freight Code
--             x_carrier_id            In / Out Carrier id
--             x_return_status         return status
--
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This procedure is used to validate carrier_id and freight_code
--========================================================================
PROCEDURE Validate_Freight_Code(
            p_freight_code  IN VARCHAR2,
            x_carrier_id    IN OUT NOCOPY NUMBER,
            x_return_status OUT NOCOPY VARCHAR2);

END WSH_UTIL_VALIDATE;

/
