--------------------------------------------------------
--  DDL for Package Body WSH_PR_CREATE_DELIVERIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_PR_CREATE_DELIVERIES" AS
/* $Header: WSHPRDLB.pls 115.4 99/07/16 08:19:53 porting ship $ */

--
-- Package
--   	WSH_PR_CREATE_DELIVERIES
--
-- Purpose
--

  --
  -- PACKAGE CONSTANTS
  --

        SUCCESS                 CONSTANT  BINARY_INTEGER := 0;
        FAILURE                 CONSTANT  BINARY_INTEGER := -1;

  --
  -- PACKAGE VARIABLES
  --
	initialized		BOOLEAN := FALSE;
	current_line		BINARY_INTEGER := 1;
	user_id 		BINARY_INTEGER;
  	login_id		BINARY_INTEGER;

  --
  -- Name
  --   FUNCTION Init
  --
  -- Purpose
  --   Initializes the package
  --
  -- Return Values
  --  -1 => Failure
  --   0 => Success
  --

  FUNCTION Init
  RETURN BINARY_INTEGER IS
  BEGIN

	IF initialized = TRUE THEN
	  WSH_UTIL.Write_Log('Package already initialized for session');
          RETURN SUCCESS;
        END IF;

	delivery_table.delete;
	current_line := 1;
	user_id := WSH_PR_PICKING_SESSION.user_id;
	login_id := WSH_PR_PICKING_SESSION.login_id;
	initialized := TRUE;

	RETURN SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      WSH_UTIL.Default_Handler('WSH_PR_CREATE_DELIVERIES.Init');
      RETURN FAILURE;

  END Init;

  --
  -- Name
  --   FUNCTION Get_Delivery
  --
  -- Purpose
  --   Gets the delivery_id to be used in autocreate deliveries when
  --   inserting picking line details
  --
  -- Arguments
  --   p_header_id		=> order header id
  --   p_ship_to_site_use_id	=> ship to site use id (ultimate ship to)
  --   p_ship_method_code	=> ship method (freight carrier)
  --
  -- Return Values
  --  -1 => Failure
  --   others => delivery_id
  --

  FUNCTION Get_Delivery(
	p_header_id		IN		BINARY_INTEGER,
	p_ship_to_site_use_id	IN		BINARY_INTEGER,
	p_ship_method_code	IN		VARCHAR2,
	p_organization_id	IN		BINARY_INTEGER
  )
  RETURN BINARY_INTEGER IS

  CURSOR get_delivery_info(x_header_id IN BINARY_INTEGER) IS
  SELECT NVL(CUSTOMER_ID,-1),
	 NVL(FOB_CODE, 'XX'),
	 NVL(FREIGHT_TERMS_CODE, 'XX'),
	 CURRENCY_CODE
  FROM   SO_HEADERS_ALL
  WHERE  HEADER_ID = x_header_id;


  CURSOR get_vol_weight_uom(x_uom_class IN VARCHAR2 ) IS
  SELECT UOM_CODE
  FROM   MTL_UNITS_OF_MEASURE
  WHERE  BASE_UOM_FLAG = 'Y'
  AND    UOM_CLASS = x_uom_class ;

  v_ship_to_site_use_id 	BINARY_INTEGER;
  v_ship_method_code		VARCHAR2(30);
  v_customer_id			BINARY_INTEGER;
  v_fob_code			VARCHAR2(30);
  v_freight_terms_code  	VARCHAR2(30);
  v_currency_code		VARCHAR2(15);
  v_delivery_name		VARCHAR2(15);
  v_delivery_id			BINARY_INTEGER := -1;
  v_header_id                   BINARY_INTEGER;
  v_rowid			VARCHAR2(20);
  v_delivery_report_set_id	NUMBER;
  v_volume_uom_code		VARCHAR2(3);
  v_volume_uom_class		VARCHAR2(10);
  v_weight_uom_code		VARCHAR2(3);
  v_weight_uom_class		VARCHAR2(10);

  i				BINARY_INTEGER;

  BEGIN

    -- Fetch all delivery parameters
    OPEN  get_delivery_info(p_header_id);
    FETCH get_delivery_info
    INTO  v_customer_id,
	  v_fob_code,
	  v_freight_terms_code,
	  v_currency_code;

    IF get_delivery_info%NOTFOUND THEN
      WSH_UTIL.Write_Log('Error: Cannot find order header');
      RETURN FAILURE;
    END IF;

    IF WSH_PR_PICKING_OBJECTS.g_use_autocreate_del_orders = 'Y' THEN
      v_header_id := p_header_id;
    ELSE
      v_header_id := -1;
    END IF;

    IF p_ship_to_site_use_id IS NULL THEN
      v_ship_to_site_use_id := -1;
    ELSE
      v_ship_to_site_use_id := p_ship_to_site_use_id;
    END IF;

    IF p_ship_method_code IS NULL THEN
      v_ship_method_code := -1;
    ELSE
      v_ship_method_code := p_ship_method_code;
    END IF;

    -- Search table for this combination
    FOR i IN 1..current_line-1 LOOP
      IF ((delivery_table(i).header_id = v_header_id) AND
          (delivery_table(i).ship_to_site_use_id = v_ship_to_site_use_id) AND
	  (delivery_table(i).ship_method_code = v_ship_method_code) AND
          (delivery_table(i).customer_id = v_customer_id) AND
          (delivery_table(i).fob_code = v_fob_code) AND
          (delivery_table(i).freight_terms_code = v_freight_terms_code) AND
	  (delivery_table(i).currency_code = v_currency_code)) THEN
	v_delivery_id := delivery_table(i).delivery_id;
	WSH_UTIL.Write_Log('Found delivery_id ' || to_char(v_delivery_id) ||
                           ' in table');
      END IF;

      -- If found, return the associated delivery_id
      IF v_delivery_id > 0 THEN
        RETURN v_delivery_id;
      END IF;

    END LOOP;

    -- Must create a new delivery
    IF v_delivery_id = -1 THEN
      WSH_UTIL.Write_Log('Will create a new delivery id');
      WSH_UTIL.Write_Log('Calling WSH_DELIVERIES_PKG.Insert_Row');

      v_rowid := NULL;
      v_delivery_id := NULL;
      v_delivery_name := NULL;
      v_volume_uom_code := NULL ;
      v_weight_uom_code := NULL ;

      -- For new delivery we must default document set from WSH_PARAMETERS.
      -- Bug 778917
      wsh_parameters_pvt.get_param_value_num(p_organization_id,
                                             'DELIVERY_REPORT_SET_ID',
                                             v_delivery_report_set_id);
      -- For new delivery we must default Volume/Weight UOM from WSH_PARAMETERS.
      -- Bug 804131

      wsh_parameters_pvt.get_param_value(p_organization_id,
                                         'VOLUME_UOM_CLASS',
                                          v_volume_uom_class);
      WSH_UTIL.Write_Log('volume_uom_class = ' || v_volume_uom_class);

      wsh_parameters_pvt.get_param_value(p_organization_id,
                                         'WEIGHT_UOM_CLASS',
                                          v_weight_uom_class);
      WSH_UTIL.Write_Log('weight_uom_class = ' || v_weight_uom_class);

      OPEN  get_vol_weight_uom(v_volume_uom_class);
      FETCH get_vol_weight_uom
      INTO  v_volume_uom_code ;
      IF get_delivery_info%NOTFOUND THEN
         WSH_UTIL.Write_Log('Warning: Cannot find UOM code for Volume. Using NULL ....');
      END IF;
      CLOSE get_vol_weight_uom ;

      OPEN  get_vol_weight_uom(v_weight_uom_class);
      FETCH get_vol_weight_uom
      INTO  v_weight_uom_code ;
      IF get_delivery_info%NOTFOUND THEN
         WSH_UTIL.Write_Log('Warning: Cannot find UOM code for Weight. Using NULL ....');
      END IF;
      CLOSE get_vol_weight_uom ;


      WSH_UTIL.Write_Log('org_id = ' || to_char(p_organization_id));
      WSH_UTIL.Write_Log('cust_id = ' || to_char(v_customer_id));
      WSH_UTIL.Write_Log('ship_to = ' || to_char(v_ship_to_site_use_id));
      WSH_UTIL.Write_Log('user_id = ' || to_char(user_id));
      WSH_UTIL.Write_Log('login_id = ' || to_char(login_id));
      WSH_UTIL.Write_Log('volume_uom_code = ' || v_volume_uom_code);
      WSH_UTIL.Write_Log('weight_uom_code = ' || v_weight_uom_code);

      WSH_DELIVERIES_PKG1.Insert_Row(
		X_Rowid                   => v_rowid,
		X_Organization_Id         => p_organization_id,
        	X_Delivery_Id             => v_delivery_id,
        	X_Name                    => v_delivery_name,
        	X_Source_Code             => 'S',
        	X_Planned_Departure_Id    => '',
		X_Actual_Departure_Id     => '',
		X_Status_Code             => 'OP',
		X_Loading_Order_Flag      => NULL,
		X_Date_Closed             => NULL,
		X_Report_Set_Id           => v_delivery_report_set_id,
		X_Sequence_Number         => NULL,
		X_Customer_Id             => v_customer_id,
		X_Ultimate_Ship_To_Id     => p_ship_to_site_use_id,
		X_Intermediate_Ship_To_Id => NULL,
		X_Pooled_Ship_To_Id       => NULL,
		X_Waybill                 => NULL,
		X_Gross_Weight            => NULL,
		X_Weight_Uom_Code         => v_weight_uom_code,
		X_Volume                  => NULL,
		X_Volume_Uom_Code         => v_volume_uom_code,
		X_Picked_By_Id            => NULL,
		X_Packed_By_Id            => NULL,
		X_Expected_Arrival_Date   => NULL,
		X_Asn_Date_Sent           => NULL,
		X_Asn_Seq_Number          => NULL,
		X_Freight_Carrier_Code    => p_ship_method_code,
		X_Freight_Terms_Code      => v_freight_terms_code,
		X_Currency_Code           => v_currency_code,
		X_Fob_Code                => v_fob_code,
		X_Attribute_Category      => NULL,
		X_Attribute1              => NULL,
		X_Attribute2              => NULL,
		X_Attribute3              => NULL,
		X_Attribute4              => NULL,
		X_Attribute5              => NULL,
		X_Attribute6              => NULL,
		X_Attribute7              => NULL,
		X_Attribute8              => NULL,
		X_Attribute9              => NULL,
		X_Attribute10             => NULL,
		X_Attribute11             => NULL,
		X_Attribute12             => NULL,
		X_Attribute13             => NULL,
		X_Attribute14             => NULL,
		X_Attribute15             => NULL,
		X_Creation_Date           => SYSDATE,
		X_Created_By              => user_id,
		X_Last_Update_Date        => SYSDATE,
		X_Last_Updated_By         => user_id,
		X_Last_Update_Login       => login_id
      );

      WSH_UTIL.Write_Log('New delivery is ' || v_delivery_name);

      -- Inserting row in delivery_table
      delivery_table(current_line).header_id := v_header_id;
      delivery_table(current_line).ship_to_site_use_id := v_ship_to_site_use_id;
      delivery_table(current_line).ship_method_code := v_ship_method_code;
      delivery_table(current_line).customer_id := v_customer_id;
      delivery_table(current_line).fob_code := v_fob_code;
      delivery_table(current_line).freight_terms_code := v_freight_terms_code;
      delivery_table(current_line).currency_code := v_currency_code;
      delivery_table(current_line).delivery_id := v_delivery_id;
      current_line := current_line + 1;

    END IF;

    RETURN v_delivery_id;

  EXCEPTION
    WHEN OTHERS THEN
      WSH_UTIL.Default_Handler('WSH_PR_CREATE_DELIVERIES.Get_Delivery');
      RETURN FAILURE;

  END Get_Delivery;


END WSH_PR_CREATE_DELIVERIES;

/
