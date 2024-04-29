--------------------------------------------------------
--  DDL for Package WSH_CARRIERS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_CARRIERS_GRP" AUTHID CURRENT_USER as
/* $Header: WSHCAGPS.pls 120.0 2005/05/26 18:02:13 appldev noship $ */
--===================
-- PUBLIC VARS
--===================

  TYPE Carrier_Rec_Type IS RECORD (
   CARRIER_ID                      WSH_CARRIERS.CARRIER_ID%TYPE,
   FREIGHT_CODE                    WSH_CARRIERS.FREIGHT_CODE%TYPE,
   SCAC_CODE                       WSH_CARRIERS.SCAC_CODE%TYPE  DEFAULT NULL,
   MANIFESTING_ENABLED_FLAG        WSH_CARRIERS.MANIFESTING_ENABLED_FLAG%TYPE   DEFAULT NULL,
   CURRENCY_CODE                   WSH_CARRIERS.CURRENCY_CODE%TYPE  DEFAULT NULL,
   ATTRIBUTE_CATEGORY              WSH_CARRIERS.ATTRIBUTE_CATEGORY%TYPE DEFAULT NULL,
   ATTRIBUTE1                      WSH_CARRIERS.ATTRIBUTE1%TYPE DEFAULT NULL,
   ATTRIBUTE2                      WSH_CARRIERS.ATTRIBUTE2%TYPE DEFAULT NULL,
   ATTRIBUTE3                      WSH_CARRIERS.ATTRIBUTE3%TYPE DEFAULT NULL,
   ATTRIBUTE4                      WSH_CARRIERS.ATTRIBUTE4%TYPE DEFAULT NULL,
   ATTRIBUTE5                      WSH_CARRIERS.ATTRIBUTE5%TYPE DEFAULT NULL,
   ATTRIBUTE6                      WSH_CARRIERS.ATTRIBUTE6%TYPE DEFAULT NULL,
   ATTRIBUTE7                      WSH_CARRIERS.ATTRIBUTE7%TYPE DEFAULT NULL,
   ATTRIBUTE8                      WSH_CARRIERS.ATTRIBUTE8%TYPE DEFAULT NULL,
   ATTRIBUTE9                      WSH_CARRIERS.ATTRIBUTE9%TYPE DEFAULT NULL,
   ATTRIBUTE10                     WSH_CARRIERS.ATTRIBUTE10%TYPE DEFAULT NULL,
   ATTRIBUTE11                     WSH_CARRIERS.ATTRIBUTE11%TYPE DEFAULT NULL,
   ATTRIBUTE12                     WSH_CARRIERS.ATTRIBUTE12%TYPE DEFAULT NULL,
   ATTRIBUTE13                     WSH_CARRIERS.ATTRIBUTE13%TYPE DEFAULT NULL,
   ATTRIBUTE14                     WSH_CARRIERS.ATTRIBUTE14%TYPE DEFAULT NULL,
   ATTRIBUTE15                     WSH_CARRIERS.ATTRIBUTE15%TYPE DEFAULT NULL,
   CREATION_DATE                   WSH_CARRIERS.CREATION_DATE%TYPE ,
   CREATED_BY                      WSH_CARRIERS.CREATED_BY%TYPE ,
   LAST_UPDATE_DATE                WSH_CARRIERS.LAST_UPDATE_DATE%TYPE ,
   LAST_UPDATED_BY                 WSH_CARRIERS.LAST_UPDATED_BY%TYPE ,
   -- Pack J
   CARRIER_NAME                   HZ_PARTIES.PARTY_NAME%TYPE DEFAULT NULL,
   MAX_NUM_STOPS_PERMITTED        WSH_CARRIERS.MAX_NUM_STOPS_PERMITTED%TYPE  DEFAULT NULL,
   MAX_TOTAL_DISTANCE             WSH_CARRIERS.MAX_TOTAL_DISTANCE%TYPE       DEFAULT NULL,
   MAX_TOTAL_TIME                 WSH_CARRIERS.MAX_TOTAL_TIME%TYPE           DEFAULT NULL,
   ALLOW_INTERSPERSE_LOAD         WSH_CARRIERS.ALLOW_INTERSPERSE_LOAD%TYPE   DEFAULT NULL,
   MAX_LAYOVER_TIME               WSH_CARRIERS.MAX_LAYOVER_TIME%TYPE         DEFAULT NULL,
   MIN_LAYOVER_TIME               WSH_CARRIERS.MIN_LAYOVER_TIME%TYPE         DEFAULT NULL,
   MAX_TOTAL_DISTANCE_IN_24HR     WSH_CARRIERS.MAX_TOTAL_DISTANCE_IN_24HR%TYPE       DEFAULT NULL,
   MAX_DRIVING_TIME_IN_24HR       WSH_CARRIERS.MAX_DRIVING_TIME_IN_24HR%TYPE         DEFAULT NULL,
   MAX_DUTY_TIME_IN_24HR          WSH_CARRIERS.MAX_DUTY_TIME_IN_24HR%TYPE            DEFAULT NULL,
   ALLOW_CONTINUOUS_MOVE          WSH_CARRIERS.ALLOW_CONTINUOUS_MOVE%TYPE    DEFAULT NULL,
   MAX_CM_DISTANCE                WSH_CARRIERS.MAX_CM_DISTANCE%TYPE          DEFAULT NULL,
   MAX_CM_TIME                    WSH_CARRIERS.MAX_CM_TIME%TYPE		     DEFAULT NULL,
   MAX_CM_DH_DISTANCE             WSH_CARRIERS.MAX_CM_DH_DISTANCE%TYPE       DEFAULT NULL,
   MAX_CM_DH_TIME                 WSH_CARRIERS.MAX_CM_DH_TIME%TYPE           DEFAULT NULL,
   MAX_SIZE_WIDTH                 WSH_CARRIERS.MAX_SIZE_WIDTH%TYPE           DEFAULT NULL,
   MAX_SIZE_HEIGHT                WSH_CARRIERS.MAX_SIZE_LENGTH%TYPE          DEFAULT NULL,
   MAX_SIZE_LENGTH                WSH_CARRIERS.MAX_SIZE_LENGTH%TYPE          DEFAULT NULL,
   MIN_SIZE_WIDTH                 WSH_CARRIERS.MIN_SIZE_WIDTH%TYPE           DEFAULT NULL,
   MIN_SIZE_HEIGHT                WSH_CARRIERS.MIN_SIZE_HEIGHT%TYPE          DEFAULT NULL,
   MIN_SIZE_LENGTH                WSH_CARRIERS.MIN_SIZE_LENGTH%TYPE          DEFAULT NULL,
   TIME_UOM                       WSH_CARRIERS.TIME_UOM%TYPE		     DEFAULT NULL,
   DIMENSION_UOM                  WSH_CARRIERS.DIMENSION_UOM%TYPE	     DEFAULT NULL,
   DISTANCE_UOM                   WSH_CARRIERS.DISTANCE_UOM%TYPE	     DEFAULT NULL,
   MAX_OUT_OF_ROUTE               WSH_CARRIERS.MAX_OUT_OF_ROUTE%TYPE         DEFAULT NULL,
   CM_FREE_DH_MILEAGE             WSH_CARRIERS.CM_FREE_DH_MILEAGE%TYPE       DEFAULT NULL,
   MIN_CM_DISTANCE                WSH_CARRIERS.MIN_CM_DISTANCE%TYPE          DEFAULT NULL,
   CM_FIRST_LOAD_DISCOUNT         WSH_CARRIERS.CM_FIRST_LOAD_DISCOUNT%TYPE   DEFAULT NULL,
   MIN_CM_TIME                    WSH_CARRIERS.MIN_CM_TIME%TYPE		     DEFAULT NULL,
   UNIT_RATE_BASIS                WSH_CARRIERS.UNIT_RATE_BASIS%TYPE	     DEFAULT NULL,
   WEIGHT_UOM                     WSH_CARRIERS.WEIGHT_UOM%TYPE		     DEFAULT NULL,
   VOLUME_UOM                     WSH_CARRIERS.VOLUME_UOM%TYPE		     DEFAULT NULL,
   GENERIC_FLAG                   WSH_CARRIERS.GENERIC_FLAG%TYPE	     DEFAULT NULL,
   FREIGHT_BILL_AUTO_APPROVAL     WSH_CARRIERS.FREIGHT_BILL_AUTO_APPROVAL%TYPE	     DEFAULT NULL,
   FREIGHT_AUDIT_LINE_LEVEL       WSH_CARRIERS.FREIGHT_AUDIT_LINE_LEVEL%TYPE	     DEFAULT NULL,
   SUPPLIER_ID                    WSH_CARRIERS.SUPPLIER_ID%TYPE		     DEFAULT NULL,
   SUPPLIER_SITE_ID               WSH_CARRIERS.SUPPLIER_SITE_ID%TYPE         DEFAULT NULL,
   CM_RATE_VARIANT                WSH_CARRIERS.CM_RATE_VARIANT%TYPE	     DEFAULT NULL,
   DISTANCE_CALCULATION_METHOD    WSH_CARRIERS.DISTANCE_CALCULATION_METHOD%TYPE      DEFAULT NULL,
   ORIGIN_DSTN_SURCHARGE_LEVEL    WSH_CARRIERS.ORIGIN_DSTN_SURCHARGE_LEVEL%TYPE      DEFAULT NULL,
   -- R12 Code Changes
   DIM_DIMENSIONAL_FACTOR	  WSH_CARRIERS.DIM_DIMENSIONAL_FACTOR%TYPE	     DEFAULT NULL,
   DIM_WEIGHT_UOM		  WSH_CARRIERS.DIM_WEIGHT_UOM%TYPE	      DEFAULT NULL,
   DIM_VOLUME_UOM		  WSH_CARRIERS.DIM_VOLUME_UOM%TYPE	      DEFAULT NULL,
   DIM_DIMENSION_UOM		  WSH_CARRIERS.DIM_DIMENSION_UOM%TYPE	      DEFAULT NULL,
   DIM_MIN_PACK_VOL		  WSH_CARRIERS.DIM_MIN_PACK_VOL%TYPE	      DEFAULT NULL
-- R12 Code Changes
   );


  TYPE Carrier_Service_Rec_Type IS RECORD (
   CARRIER_SERVICE_ID              WSH_CARRIER_SERVICES.CARRIER_SERVICE_ID%TYPE,
   CARRIER_ID                      WSH_CARRIER_SERVICES.CARRIER_ID%TYPE ,
   SERVICE_LEVEL                   WSH_CARRIER_SERVICES.SERVICE_LEVEL%TYPE ,
   MODE_OF_TRANSPORT               WSH_CARRIER_SERVICES.MODE_OF_TRANSPORT%TYPE ,
   SL_TIME_UOM                     WSH_CARRIER_SERVICES.SL_TIME_UOM%TYPE	DEFAULT NULL,
   MIN_SL_TIME                     WSH_CARRIER_SERVICES.MIN_SL_TIME%TYPE	DEFAULT NULL,
   MAX_SL_TIME                     WSH_CARRIER_SERVICES.MAX_SL_TIME%TYPE	DEFAULT NULL,
   ENABLED_FLAG                    WSH_CARRIER_SERVICES.ENABLED_FLAG%TYPE	DEFAULT NULL,
   WEB_ENABLED                     WSH_CARRIER_SERVICES.WEB_ENABLED%TYPE	DEFAULT NULL,
   SHIP_METHOD_MEANING             WSH_CARRIER_SERVICES.SHIP_METHOD_MEANING%TYPE,
   ATTRIBUTE_CATEGORY              WSH_CARRIER_SERVICES.ATTRIBUTE_CATEGORY%TYPE  DEFAULT NULL ,
   ATTRIBUTE1                      WSH_CARRIER_SERVICES.ATTRIBUTE1%TYPE          DEFAULT NULL,
   ATTRIBUTE2                      WSH_CARRIER_SERVICES.ATTRIBUTE2%TYPE		 DEFAULT NULL,
   ATTRIBUTE3                      WSH_CARRIER_SERVICES.ATTRIBUTE3%TYPE		 DEFAULT NULL,
   ATTRIBUTE4                      WSH_CARRIER_SERVICES.ATTRIBUTE4%TYPE		 DEFAULT NULL,
   ATTRIBUTE5                      WSH_CARRIER_SERVICES.ATTRIBUTE5%TYPE		 DEFAULT NULL,
   ATTRIBUTE6                      WSH_CARRIER_SERVICES.ATTRIBUTE6%TYPE		 DEFAULT NULL,
   ATTRIBUTE7                      WSH_CARRIER_SERVICES.ATTRIBUTE7%TYPE		 DEFAULT NULL,
   ATTRIBUTE8                      WSH_CARRIER_SERVICES.ATTRIBUTE8%TYPE		 DEFAULT NULL,
   ATTRIBUTE9                      WSH_CARRIER_SERVICES.ATTRIBUTE9%TYPE		 DEFAULT NULL,
   ATTRIBUTE10                     WSH_CARRIER_SERVICES.ATTRIBUTE10%TYPE	 DEFAULT NULL,
   ATTRIBUTE11                     WSH_CARRIER_SERVICES.ATTRIBUTE11%TYPE	 DEFAULT NULL,
   ATTRIBUTE12                     WSH_CARRIER_SERVICES.ATTRIBUTE12%TYPE	 DEFAULT NULL,
   ATTRIBUTE13                     WSH_CARRIER_SERVICES.ATTRIBUTE13%TYPE	 DEFAULT NULL,
   ATTRIBUTE14                     WSH_CARRIER_SERVICES.ATTRIBUTE14%TYPE	 DEFAULT NULL,
   ATTRIBUTE15                     WSH_CARRIER_SERVICES.ATTRIBUTE15%TYPE	 DEFAULT NULL,
   CREATION_DATE                   WSH_CARRIER_SERVICES.CREATION_DATE%TYPE,
   CREATED_BY                      WSH_CARRIER_SERVICES.CREATED_BY%TYPE ,
   LAST_UPDATE_DATE                WSH_CARRIER_SERVICES.LAST_UPDATE_DATE%TYPE,
   LAST_UPDATED_BY                 WSH_CARRIER_SERVICES.LAST_UPDATED_BY%TYPE ,
   -- Pack J
   MAX_NUM_STOPS_PERMITTED         WSH_CARRIER_SERVICES.MAX_NUM_STOPS_PERMITTED%TYPE  DEFAULT NULL,
   MAX_TOTAL_DISTANCE              WSH_CARRIER_SERVICES.MAX_TOTAL_DISTANCE%TYPE       DEFAULT NULL,
   MAX_TOTAL_TIME                  WSH_CARRIER_SERVICES.MAX_TOTAL_TIME%TYPE           DEFAULT NULL,
   ALLOW_INTERSPERSE_LOAD          WSH_CARRIER_SERVICES.ALLOW_INTERSPERSE_LOAD%TYPE   DEFAULT NULL,
   MAX_LAYOVER_TIME                WSH_CARRIER_SERVICES.MAX_LAYOVER_TIME%TYPE         DEFAULT NULL,
   MIN_LAYOVER_TIME                WSH_CARRIER_SERVICES.MIN_LAYOVER_TIME%TYPE         DEFAULT NULL,
   MAX_TOTAL_DISTANCE_IN_24HR      WSH_CARRIER_SERVICES.MAX_TOTAL_DISTANCE_IN_24HR%TYPE    DEFAULT NULL,
   MAX_DRIVING_TIME_IN_24HR        WSH_CARRIER_SERVICES.MAX_DRIVING_TIME_IN_24HR%TYPE      DEFAULT NULL,
   MAX_DUTY_TIME_IN_24HR           WSH_CARRIER_SERVICES.MAX_DUTY_TIME_IN_24HR%TYPE         DEFAULT NULL,
   ALLOW_CONTINUOUS_MOVE           WSH_CARRIER_SERVICES.ALLOW_CONTINUOUS_MOVE%TYPE	   DEFAULT NULL,
   MAX_CM_DISTANCE                 WSH_CARRIER_SERVICES.MAX_CM_DISTANCE%TYPE	           DEFAULT NULL,
   MAX_CM_TIME                     WSH_CARRIER_SERVICES.MAX_CM_TIME%TYPE	           DEFAULT NULL,
   MAX_CM_DH_DISTANCE              WSH_CARRIER_SERVICES.MAX_CM_DH_DISTANCE%TYPE		   DEFAULT NULL,
   MAX_CM_DH_TIME                  WSH_CARRIER_SERVICES.MAX_CM_DH_TIME%TYPE	           DEFAULT NULL,
   MAX_SIZE_WIDTH                  WSH_CARRIER_SERVICES.MAX_SIZE_WIDTH%TYPE	           DEFAULT NULL,
   MAX_SIZE_HEIGHT                 WSH_CARRIER_SERVICES.MAX_SIZE_HEIGHT%TYPE	           DEFAULT NULL,
   MAX_SIZE_LENGTH                 WSH_CARRIER_SERVICES.MAX_SIZE_LENGTH%TYPE		   DEFAULT NULL,
   MIN_SIZE_WIDTH                  WSH_CARRIER_SERVICES.MIN_SIZE_WIDTH%TYPE	           DEFAULT NULL,
   MIN_SIZE_HEIGHT                 WSH_CARRIER_SERVICES.MIN_SIZE_HEIGHT%TYPE	           DEFAULT NULL,
   MIN_SIZE_LENGTH                 WSH_CARRIER_SERVICES.MIN_SIZE_LENGTH%TYPE	           DEFAULT NULL,
   MAX_OUT_OF_ROUTE                WSH_CARRIER_SERVICES.MAX_OUT_OF_ROUTE%TYPE	           DEFAULT NULL,
   CM_FREE_DH_MILEAGE              WSH_CARRIER_SERVICES.CM_FREE_DH_MILEAGE%TYPE	           DEFAULT NULL,
   MIN_CM_DISTANCE                 WSH_CARRIER_SERVICES.MIN_CM_DISTANCE%TYPE	           DEFAULT NULL,
   CM_FIRST_LOAD_DISCOUNT          WSH_CARRIER_SERVICES.CM_FIRST_LOAD_DISCOUNT%TYPE	   DEFAULT NULL,
   MIN_CM_TIME                     WSH_CARRIER_SERVICES.MIN_CM_TIME%TYPE	           DEFAULT NULL,
   UNIT_RATE_BASIS                 WSH_CARRIER_SERVICES.UNIT_RATE_BASIS%TYPE		   DEFAULT NULL,
   CM_RATE_VARIANT                 WSH_CARRIER_SERVICES.CM_RATE_VARIANT%TYPE		   DEFAULT NULL,
   DISTANCE_CALCULATION_METHOD     WSH_CARRIER_SERVICES.DISTANCE_CALCULATION_METHOD%TYPE   DEFAULT NULL,
   ORIGIN_DSTN_SURCHARGE_LEVEL     WSH_CARRIER_SERVICES.ORIGIN_DSTN_SURCHARGE_LEVEL%TYPE   DEFAULT NULL,
   -- R12 Code Changes
   DIM_DIMENSIONAL_FACTOR          WSH_CARRIER_SERVICES.DIM_DIMENSIONAL_FACTOR%TYPE	   DEFAULT NULL,
   DIM_WEIGHT_UOM                  WSH_CARRIER_SERVICES.DIM_WEIGHT_UOM%TYPE		   DEFAULT NULL,
   DIM_VOLUME_UOM                  WSH_CARRIER_SERVICES.DIM_VOLUME_UOM%TYPE		   DEFAULT NULL,
   DIM_DIMENSION_UOM     	   WSH_CARRIER_SERVICES.DIM_DIMENSION_UOM%TYPE		   DEFAULT NULL,
   DIM_MIN_PACK_VOL  		   WSH_CARRIER_SERVICES.DIM_MIN_PACK_VOL%TYPE		   DEFAULT NULL,
   DEFAULT_VEHICLE_TYPE_ID         WSH_CARRIER_SERVICES.DEFAULT_VEHICLE_TYPE_ID%TYPE	   DEFAULT NULL
 -- R12 Code Changes
 );

  TYPE Org_Carrier_Service_Rec_Type IS RECORD (
   ORG_CARRIER_SERVICE_ID          NUMBER(38) ,
   CARRIER_SERVICE_ID              NUMBER(38) ,
   ORGANIZATION_ID                 NUMBER(38) ,
   ENABLED_FLAG                    VARCHAR2(1)   DEFAULT NULL,
   ATTRIBUTE_CATEGORY              VARCHAR2(150) DEFAULT NULL,
   ATTRIBUTE1                      VARCHAR2(150) DEFAULT NULL,
   ATTRIBUTE2                      VARCHAR2(150) DEFAULT NULL,
   ATTRIBUTE3                      VARCHAR2(150) DEFAULT NULL,
   ATTRIBUTE4                      VARCHAR2(150) DEFAULT NULL,
   ATTRIBUTE5                      VARCHAR2(150) DEFAULT NULL,
   ATTRIBUTE6                      VARCHAR2(150) DEFAULT NULL,
   ATTRIBUTE7                      VARCHAR2(150) DEFAULT NULL,
   ATTRIBUTE8                      VARCHAR2(150) DEFAULT NULL,
   ATTRIBUTE9                      VARCHAR2(150) DEFAULT NULL,
   ATTRIBUTE10                     VARCHAR2(150) DEFAULT NULL,
   ATTRIBUTE11                     VARCHAR2(150) DEFAULT NULL,
   ATTRIBUTE12                     VARCHAR2(150) DEFAULT NULL,
   ATTRIBUTE13                     VARCHAR2(150) DEFAULT NULL,
   ATTRIBUTE14                     VARCHAR2(150) DEFAULT NULL,
   ATTRIBUTE15                     VARCHAR2(150) DEFAULT NULL,
   CREATION_DATE                   DATE ,
   CREATED_BY                      NUMBER(38) ,
   LAST_UPDATE_DATE                DATE,
   LAST_UPDATED_BY                 NUMBER(38),
   DISTRIBUTION_ACCOUNT            NUMBER        DEFAULT NULL -- BugFix#3296461
  );

 TYPE Carrier_Info_Dff_Type IS RECORD (
    ATTRIBUTE_CATEGORY             VARCHAR2(150) DEFAULT NULL
  , ATTRIBUTE1                     VARCHAR2(150) DEFAULT NULL
  , ATTRIBUTE2                     VARCHAR2(150) DEFAULT NULL
  , ATTRIBUTE3                     VARCHAR2(150) DEFAULT NULL
  , ATTRIBUTE4                     VARCHAR2(150) DEFAULT NULL
  , ATTRIBUTE5                     VARCHAR2(150) DEFAULT NULL
  , ATTRIBUTE6                     VARCHAR2(150) DEFAULT NULL
  , ATTRIBUTE7                     VARCHAR2(150) DEFAULT NULL
  , ATTRIBUTE8                     VARCHAR2(150) DEFAULT NULL
  , ATTRIBUTE9                     VARCHAR2(150) DEFAULT NULL
  , ATTRIBUTE10                    VARCHAR2(150) DEFAULT NULL
  , ATTRIBUTE11                    VARCHAR2(150) DEFAULT NULL
  , ATTRIBUTE12                    VARCHAR2(150) DEFAULT NULL
  , ATTRIBUTE13                    VARCHAR2(150) DEFAULT NULL
  , ATTRIBUTE14                    VARCHAR2(150) DEFAULT NULL
  , ATTRIBUTE15                    VARCHAR2(150) DEFAULT NULL
  , Creation_Date                  DATE
  , Created_By                     NUMBER
  , Last_Update_Date               DATE
  , Last_Updated_By                NUMBER
  , Last_Update_Login              NUMBER
);


TYPE Ship_Method_Dff_Type IS RECORD (
    ATTRIBUTE_CATEGORY             VARCHAR2(150) DEFAULT NULL
  , ATTRIBUTE1                     VARCHAR2(150) DEFAULT NULL
  , ATTRIBUTE2                     VARCHAR2(150) DEFAULT NULL
  , ATTRIBUTE3                     VARCHAR2(150) DEFAULT NULL
  , ATTRIBUTE4                     VARCHAR2(150) DEFAULT NULL
  , ATTRIBUTE5                     VARCHAR2(150) DEFAULT NULL
  , ATTRIBUTE6                     VARCHAR2(150) DEFAULT NULL
  , ATTRIBUTE7                     VARCHAR2(150) DEFAULT NULL
  , ATTRIBUTE8                     VARCHAR2(150) DEFAULT NULL
  , ATTRIBUTE9                     VARCHAR2(150) DEFAULT NULL
  , ATTRIBUTE10                    VARCHAR2(150) DEFAULT NULL
  , ATTRIBUTE11                    VARCHAR2(150) DEFAULT NULL
  , ATTRIBUTE12                    VARCHAR2(150) DEFAULT NULL
  , ATTRIBUTE13                    VARCHAR2(150) DEFAULT NULL
  , ATTRIBUTE14                    VARCHAR2(150) DEFAULT NULL
  , ATTRIBUTE15                    VARCHAR2(150) DEFAULT NULL
  , Creation_Date                  DATE
  , Created_By                     NUMBER
  , Last_Update_Date               DATE
  , Last_Updated_By                NUMBER
  , Last_Update_Login              NUMBER
);
  TYPE Carrier_Out_Rec_Type is RECORD (
    carrier_id   NUMBER,
    rowid         VARCHAR2(4000));

  TYPE Carrier_Ser_Out_Rec_Type is RECORD (
    carrier_service_id   NUMBER,
    ship_method_code     VARCHAR2(30),
    rowid         VARCHAR2(4000));

  TYPE Org_Carrier_Ser_Out_Rec_Type is RECORD (
    carrier_service_id   NUMBER,
    org_carrier_service_id   NUMBER,
    rowid         VARCHAR2(4000));

  TYPE Org_Carrier_Ser_Out_Tab_Type IS Table of Org_Carrier_Ser_Out_Rec_Type INDEX BY BINARY_INTEGER;

  TYPE Carrier_Service_InOut_Rec_Type is RECORD (
    carrier_id               wsh_carriers.carrier_id%type,
    freight_code             wsh_carriers.freight_code%type,
    scac_code                wsh_carriers.scac_code%type,
    manifesting_enabled_flag wsh_carriers.manifesting_enabled_flag%type,
    currency_code            wsh_carriers.currency_code%type,
    generic_flag             wsh_carriers.generic_flag%type,
    carrier_service_id       wsh_carrier_services.carrier_service_id%type,
    service_level            wsh_carrier_services.service_level%type,
    mode_of_transport        wsh_carrier_services.mode_of_transport%type,
    ship_method_code         wsh_carrier_services.ship_method_code%type);

--===================
-- PROCEDURES
--===================

  --========================================================================
  -- PROCEDURE : Create_Update_Carrier
  --
  --
  -- PARAMETERS: p_api_version           known api version error buffer
  --             p_init_msg_list         FND_API.G_TRUE to reset list
  --             x_return_status         return status
  --             x_msg_count             number of messages in the list
  --             x_msg_data              text of messages
  --             p_action_code           action_code ( CREATE,UPDATE and CREATE_UPDATE )
  --             p_rec_attr_tab          Table of attributes for the carrier entity
  --             p_carrier_name          carrier Name
        --             p_status                status
  --             x_car_out_rec_tab       Table of carrier_id
  -- VERSION   : current version         1.0
  --             initial version         1.0
  -- COMMENT   : Creates or updates a record in wsh_carriers
  --========================================================================
  PROCEDURE Create_Update_Carrier
      ( p_api_version_number     IN   NUMBER,
        p_init_msg_list          IN   VARCHAR2,
        p_commit                 IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_action_code            IN   VARCHAR2,
        p_rec_attr_tab           IN   Carrier_Rec_Type,
        p_carrier_name           IN   VARCHAR2,
        p_status                 IN   VARCHAR2,
        x_car_out_rec_tab        OUT NOCOPY Carrier_Out_Rec_Type,
        x_return_status          OUT NOCOPY VARCHAR2,
        x_msg_count              OUT NOCOPY NUMBER,
        x_msg_data               OUT NOCOPY VARCHAR2);


  --========================================================================
  -- PROCEDURE : Create_Update_Service
  --
  --
  -- PARAMETERS: p_api_version           known api version error buffer
  --             p_init_msg_list         FND_API.G_TRUE to reset list
  --             x_return_status         return status
  --             x_msg_count             number of messages in the list
  --             x_msg_data              text of messages
  --             p_action_code           action_code ( CREATE,UPDATE and CREATE_UPDATE )
  --             p_rec_attr_tab          Table of attributes for the carrier service entity
  --             x_car_ser_out_rec_tab   Table of carrier_service_id, and ship_method_code.
  -- VERSION   : current version         1.0
  --             initial version         1.0
  -- COMMENT   : Creates or updates a record in wsh_carrier_services and fnd_lookups
  --========================================================================
  PROCEDURE Create_Update_Carrier_Service
      ( p_api_version_number     IN   NUMBER,
        p_init_msg_list          IN   VARCHAR2,
        p_commit                 IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_action_code            IN   VARCHAR2,
        p_rec_attr_tab           IN   Carrier_Service_Rec_Type,
        x_car_ser_out_rec_tab    OUT  NOCOPY Carrier_Ser_Out_Rec_Type,
        x_return_status          OUT  NOCOPY VARCHAR2,
        x_msg_count              OUT  NOCOPY NUMBER,
        x_msg_data               OUT  NOCOPY VARCHAR2);

  --========================================================================
  -- PROCEDURE : Assign_Org_Carrier_Service
  --
  --
  -- PARAMETERS: p_api_version           known api version error buffer
  --             p_init_msg_list         FND_API.G_TRUE to reset list
  --             x_return_status         return status
  --             x_msg_count             number of messages in the list
  --             x_msg_data              text of messages
  --             p_action_code           action_code (ASSIGN)
  --             p_rec_attr_tab          Table of attributes for the organization carrier service entity
  --             p_rec_car_dff_tab       Carrier Info DFF details
  --             p_shp_methods_dff       Ship Method Info DFF details
  --             x_orgcar_ser_out_rec_tab   Table of orgcarrier_service_id and ship_method_code.
  -- VERSION   : current version         1.0
  --             initial version         1.0
  -- COMMENT   : Creates or updates a record in wsh_org_carrier_services,org_freight_tl,wsh_carrier_ship_methods
  --========================================================================
  PROCEDURE Assign_Org_Carrier_Service
      ( p_api_version_number     IN   NUMBER,
        p_init_msg_list          IN   VARCHAR2,
        p_commit                 IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_action_code            IN   VARCHAR2,
        p_rec_org_car_ser_tab    IN   Org_Carrier_Service_Rec_Type,
        p_rec_car_dff_tab        IN   Carrier_Info_Dff_Type,
        p_shp_methods_dff        IN   Ship_Method_Dff_Type,
        x_orgcar_ser_out_rec_tab OUT  NOCOPY Org_Carrier_Ser_Out_Rec_Type,
        x_return_status          OUT  NOCOPY VARCHAR2,
        x_msg_count              OUT  NOCOPY NUMBER,
        x_msg_data               OUT  NOCOPY VARCHAR2);

--========================================================================
  -- PROCEDURE : Assign_Org_Carrier
  --
  --
  -- PARAMETERS: p_api_version           known api version error buffer
  --             p_init_msg_list         FND_API.G_TRUE to reset list
  --             x_return_status         return status
  --             x_msg_count             number of messages in the list
  --             x_msg_data              text of messages
  --             p_action_code           action_code (ASSIGN)
  --             p_rec_attr_tab          Table of attributes for the organization carrier service entity
  --             x_orgcar_ser_out_tab   Table of orgcarrier_service_id and ship_method_code.
  -- VERSION   : current version         1.0
  --             initial version         1.0
  -- COMMENT   : The Organization is assigned to all present carrier services the carrier at that poing of time
  --            Creates or updates a record in wsh_org_carrier_services,org_freight_tl,wsh_carrier_ship_methods
  --========================================================================
PROCEDURE Assign_Org_Carrier
      ( p_api_version_number     IN   NUMBER,
        p_init_msg_list          IN   VARCHAR2,
        p_commit                 IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_action_code            IN   VARCHAR2,
        p_carrier_id             IN   NUMBER,
        p_organization_id        IN   NUMBER,
        x_orgcar_ser_out_tab     OUT  NOCOPY Org_Carrier_Ser_Out_Tab_Type,
        x_return_status          OUT  NOCOPY VARCHAR2,
        x_msg_count              OUT  NOCOPY NUMBER,
        x_msg_data               OUT  NOCOPY VARCHAR2);

  PROCEDURE Generate_Ship_Method
  (
        service_level_code  IN  VARCHAR2,
        freight_code        IN  VARCHAR2,
        mode_of_trans_code  IN  VARCHAR2,
        ship_method_meaning IN  VARCHAR2 DEFAULT NULL,
        x_ship_method_code  OUT NOCOPY VARCHAR2
  );

  PROCEDURE Get_Meanings
  (
    sl_time_uom         IN  VARCHAR2,
    service_level_code  IN  VARCHAR2,
    mode_of_trans_code  IN  VARCHAR2,
    x_service_level     OUT NOCOPY VARCHAR2,
    x_mode_of_transport OUT NOCOPY VARCHAR2,
    x_sl_time_uom_desc  OUT NOCOPY VARCHAR2
  );

  PROCEDURE Get_Carrier_Name
  (
    p_carrier_id    IN  NUMBER,
    x_carrier_name  OUT NOCOPY VARCHAR2,
    x_freight_code  OUT NOCOPY VARCHAR2
  );

  --========================================================================
  -- PROCEDURE : get_carrier_service_mode
  --
  --========================================================================
  PROCEDURE get_carrier_service_mode
  (
    p_carrier_service_inout_rec  IN  OUT NOCOPY Carrier_Service_InOut_Rec_Type,
    x_return_status              OUT NOCOPY VARCHAR2
  );

END WSH_CARRIERS_GRP;

 

/
