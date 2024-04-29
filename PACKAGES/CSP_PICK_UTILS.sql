--------------------------------------------------------
--  DDL for Package CSP_PICK_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_PICK_UTILS" AUTHID CURRENT_USER AS
/* $Header: cspgtpus.pls 120.2.12010000.6 2012/09/08 19:06:13 hhaugeru ship $ */

    -- Start of comments
    --
    -- API name	: create_pick
    -- Type 	: Type of API (Eg. Public, simple entity)
    -- Purpose	: This API creates picklist headers and lines for spares.
    --            It calls the auto_detail API of Oracle Inventory which
    --            creates pick based on the picking rules
    --
    -- Modification History
    -- Date        Userid    Comments
    -- ---------   ------    ------------------------------------------
    -- 12/27/99    phegde    Created
    --
    -- Note :
    -- End of comments

   Gl_ORG_ID          NUMBER := FND_PROFILE.VALUE('ORG_ID');
   G_PRODUCT_ORGANIZATION NUMBER := FND_PROFILE.VALUE('ASO_PRODUCT_ORGANIZATION_ID');

   G_DELIVERY_NUMBER     VARCHAR2(30) ;
   G_WAYBILL             VARCHAR2(30) ;
   G_RECEIVED_QTY        NUMBER ;
   G_RECEIVED_QTY_UOM    VARCHAR2(30);
   G_STATUS_MEANING      VARCHAR2(240);
   G_RECEIVED_DATE       DATE;
   g_contact_name        varchar2(240);

   G_LAST_UPDATE_DATE       DATE;
   G_TASK_ASSIGNMENT_ID     NUMBER;
   G_RESOURCE_NAME          VARCHAR2(2000);
   G_SCHED_TRAVEL_DISTANCE  NUMBER;
   G_SCHED_TRAVEL_DURATION  NUMBER;
   G_ACTUAL_TRAVEL_DISTANCE NUMBER;
   G_ACTUAL_TRAVEL_DURATION NUMBER;
   G_MINUTES                VARCHAR2(30);
   G_RESOURCE_CODE          VARCHAR2(2000);

   PROCEDURE CSP_ASSIGN_GLOBAL_ORG_ID (P_ORG_ID NUMBER);
   function CSP_GLOBAL_ORG_ID return number;
   function CSP_PRODUCT_ORGANIZATION return number;

   PROCEDURE create_pick(  p_api_version_number     IN  NUMBER
                          ,x_return_status          OUT NOCOPY VARCHAR2
                          ,x_msg_count              OUT NOCOPY NUMBER
                          ,x_msg_data               OUT NOCOPY VARCHAR2
                          ,p_order_by               IN  NUMBER
                          ,p_org_id                 IN  NUMBER
                          ,p_move_order_header_id   IN  NUMBER
                          ,p_from_subinventory      IN  VARCHAR2
                          ,p_to_subinventory        IN  VARCHAR2
                          ,p_date_required          IN DATE
                          ,p_created_by             IN NUMBER
                          ,p_move_order_type        IN NUMBER := 3
                       );


    Procedure Confirm_Pick (
    -- Start of Comments
    -- Procedure    : Confirm_Pick
    -- Purpose      : This procedure inserts the record into the csp_picklist_serial_lots tables based on the
    --                msnt or the mtlt record associated with the picklist.
    --
    -- History      :
    --  UserID       Date          Comments
    --  -----------  --------      --------------------------
    --   klou       02/01/2000      Created.
    --
    -- NOTES:
    --
    --End of Comments
         P_Api_Version_Number           IN   NUMBER
        ,P_Init_Msg_List                IN   VARCHAR2     := FND_API.G_FALSE
        ,P_Commit                       IN   VARCHAR2     := FND_API.G_FALSE
        ,p_validation_level             IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
        ,p_picklist_header_id           IN   NUMBER
        ,p_organization_id              IN   NUMBER
        ,x_return_status                OUT NOCOPY  VARCHAR2
        ,x_msg_count                    OUT NOCOPY  NUMBER
        ,x_msg_data                     OUT NOCOPY  VARCHAR2
    );


    Procedure Save_Pick (
     P_Api_Version_Number           IN   NUMBER
    ,P_Init_Msg_List                IN   VARCHAR2     := FND_API.G_FALSE
    ,P_Commit                       IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level             IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
    ,p_picklist_header_id           IN   NUMBER
    ,p_organization_id              IN   NUMBER
    ,x_return_status                OUT NOCOPY  VARCHAR2
    ,x_msg_count                    OUT NOCOPY  NUMBER
    ,x_msg_data                     OUT NOCOPY  VARCHAR2
   );

   Procedure Update_Misc_MMTT (
       P_Api_Version_Number           IN   NUMBER
      ,P_Init_Msg_List                IN   VARCHAR2     := FND_API.G_FALSE
      ,P_Commit                       IN   VARCHAR2     := FND_API.G_FALSE
      ,p_validation_level             IN   NUMBER       := FND_API.G_VALID_LEVEL_NONE
      ,p_transaction_temp_id          IN   NUMBER
      ,p_organization_id              IN   NUMBER
      ,x_return_status                OUT NOCOPY  VARCHAR2
      ,x_msg_count                    OUT NOCOPY  NUMBER
      ,x_msg_data                     OUT NOCOPY  VARCHAR2
      );

	Procedure Issue_Savepoint(p_Savepoint Varchar2);
	Procedure Issue_Rollback(p_Savepoint Varchar2);
	Procedure Issue_Commit;
  	Function Calculate_Min_Max(p_Subinventory Varchar2,
					    p_Organization_Id Number,
					    p_Edq_factor Number,
					    p_Service_Level Number,
					    p_Item_Cost Number,
					    p_Awu Number,
					    p_Lead_time Number,
					    p_Standard_Deviation Number,
					    p_Safety_Stock_Flag Varchar2,
					    p_Asl_Flag	Varchar2) RETURN NUMBER ;

    Function get_min_quantity(p_Subinventory Varchar2,
					    p_Organization_Id Number,
					    p_Edq_factor Number,
					    p_Service_Level Number,
					    p_Item_Cost Number,
					    p_Awu Number,
					    p_Lead_time Number,
					    p_Standard_Deviation Number,
					    p_Safety_Stock_Flag Varchar2,
					    p_Asl_Flag Varchar2) RETURN NUMBER;

    Function get_max_quantity(p_Subinventory Varchar2,
					    p_Organization_Id Number,
					    p_Edq_factor Number,
					    p_Service_Level Number,
					    p_Item_Cost Number,
					    p_Awu Number,
					    p_Lead_time Number,
					    p_Standard_Deviation Number,
					    p_Safety_Stock_Flag Varchar2,
					    p_Asl_Flag Varchar2) RETURN NUMBER;

    Function Get_SAFETY_FACTOR(p_Subinventory Varchar2,
					    p_Organization_Id Number,
					    p_Edq_factor Number,
					    p_Service_Level Number,
					    p_Item_Cost Number,
					    p_Awu Number,
					    p_Lead_time Number,
					    p_Standard_Deviation Number,
					    p_Safety_Stock_Flag Varchar2,
					    p_Asl_Flag Varchar2) RETURN NUMBER;

    Function Get_SAFETY_STOCK(p_Subinventory Varchar2,
					    p_Organization_Id Number,
					    p_Edq_factor Number,
					    p_Service_Level Number,
					    p_Item_Cost Number,
					    p_Awu Number,
					    p_Lead_time Number,
					    p_Standard_Deviation Number,
					    p_Safety_Stock_Flag Varchar2,
					    p_Asl_Flag Varchar2) RETURN NUMBER;
	Function Get_Service_Level RETURN NUMBER;
	Function Get_Edq_Factor    RETURN NUMBER;
	Function Get_Asl_Flag      RETURN Varchar2;
	Function Get_Safety_Stock_Flag    RETURN Varchar2;
	Function get_rs_cust_sequence return number;

	-- returns an object name (uses the JTF_OBJECTS table and dynamic PL/SQL)
        FUNCTION get_object_name
  	( p_object_type_code in varchar2
        , p_object_id        in number
        ) return varchar2;

    -- returns constant from fnd_api package
    FUNCTION get_ret_sts_success return varchar2;

  	-- returns constant from fnd_api package
    FUNCTION get_ret_sts_error return varchar2;

    -- returns constant from fnd_api package
    FUNCTION get_ret_sts_unexp_error return varchar2;

    FUNCTION get_true return varchar2;

    FUNCTION get_false return varchar2;

    FUNCTION get_assignment(p_task_id NUMBER) return date;

    FUNCTION get_order_status(
        p_order_line_id     NUMBER,
        p_flow_status_code  VARCHAR2) return varchar2;

    FUNCTION get_attribute_value(p_attribute_name VARCHAR2) return VARCHAR2;
    FUNCTION get_received_qty RETURN NUMBER;
    FUNCTION get_adjusted_date(p_source_tz_id   NUMBER,
                               p_dest_tz_id     NUMBER,
                               p_source_day_time DATE) RETURN DATE;

    FUNCTION get_object_Type_meaning(p_object_type_code varchar2) return varchar2;
    FUNCTION get_contact_name RETURN varchar2;
    Function get_contact_info(p_incident_id NUMBER) return varchar2 ;
    FUNCTION get_line_status_meaning(p_line_id NUMBER,
                                     p_booked_flag VARCHAR2,
                                     p_flow_status_code VARCHAR2,
				     p_lookup_type VARCHAR2 DEFAULT 'LINE_FLOW_STATUS')  RETURN VARCHAR2;
END; -- Package spec

/
