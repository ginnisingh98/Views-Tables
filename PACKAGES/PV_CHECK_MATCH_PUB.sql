--------------------------------------------------------
--  DDL for Package PV_CHECK_MATCH_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_CHECK_MATCH_PUB" AUTHID CURRENT_USER AS
/* $Header: pvxvcmps.pls 120.1 2005/12/20 04:39:31 rdsharma noship $ */

   g_pkg_name                  CONSTANT VARCHAR2(30) := 'PV_CHECK_MATCH_PUB';

   -- ---------------------------------------------------------
   -- Attribute ID's
   -- ---------------------------------------------------------
   g_a_FUE                                 CONSTANT NUMBER := 1;
   g_a_Customer_Name                       CONSTANT NUMBER := 500;
   g_a_Customer_Address_Specified          CONSTANT NUMBER := 501;
   g_a_Customer_Annual_Revenue             CONSTANT NUMBER := 502;
   g_a_Primary_Contact_Specified           CONSTANT NUMBER := 503;
   g_a_Contact_Role                        CONSTANT NUMBER := 504;
   g_a_Purchase_Timeframe                  CONSTANT NUMBER := 505;
   g_a_Budget_Status                       CONSTANT NUMBER := 506;
   g_a_Lead_Score                          CONSTANT NUMBER := 507;
   g_a_Lead_Status                         CONSTANT NUMBER := 508;
   g_a_Total_Budget                        CONSTANT NUMBER := 509;
   g_a_Product_Interest                    CONSTANT NUMBER := 510;
   g_a_Purchase_Quantity_Product           CONSTANT NUMBER := 511;
   g_a_Purchase_Amount_Product             CONSTANT NUMBER := 512;
   g_a_Response_Channel                    CONSTANT NUMBER := 513;
   g_a_Project_                            CONSTANT NUMBER := 514;
   g_a_Country_                            CONSTANT NUMBER := 4;
   g_a_Campaign_                           CONSTANT NUMBER := 16;
   g_a_Qualify_Flag                        CONSTANT NUMBER := 517;
   g_a_Lead_Rating                         CONSTANT NUMBER := 518;
   g_a_Sales_Channel                       CONSTANT NUMBER := 519;
   g_a_Creation_Date                       CONSTANT NUMBER := 520;
   g_a_PSS                                 CONSTANT NUMBER := 9;
   g_a_Total_Pur_Amt_Product               CONSTANT NUMBER := 522;
   g_a_Total_Pur_Amt_Solutions             CONSTANT NUMBER := 523;
   g_a_Purchase_Qty_Solutions              CONSTANT NUMBER := 524;
   g_a_Purchase_Amount_Solutions           CONSTANT NUMBER := 525;
   g_a_State_                              CONSTANT NUMBER := 20;
   g_a_Opportunity_Status                  CONSTANT NUMBER := 600;
   g_a_Sales_Stage                         CONSTANT NUMBER := 601;
   g_a_Close_Date                          CONSTANT NUMBER := 602;
   g_a_Offer_                              CONSTANT NUMBER := 603;
   g_a_Win_Probability                     CONSTANT NUMBER := 604;
   g_a_Sales_Methodology                   CONSTANT NUMBER := 605;
   g_a_Customer_Account_Type               CONSTANT NUMBER := 606;
   g_a_Routing_Status                      CONSTANT NUMBER := 607;
   g_a_Customer_Category                   CONSTANT NUMBER := 608;
   --g_a_Additional_Channel_Offer            CONSTANT NUMBER := 9;
   g_a_Classification_                     CONSTANT NUMBER := 610;
   g_a_Functional_Expertise                CONSTANT NUMBER := 700;
   g_a_Partner_Type                        CONSTANT NUMBER := 3;
   g_a_Industry_                           CONSTANT NUMBER := 5;
   g_a_Geographic_Coverage                 CONSTANT NUMBER := 8;
   g_a_Partnership_Activity                CONSTANT NUMBER := 10;
   g_a_Partner_Name                        CONSTANT NUMBER := 11;
   g_a_Capacity_Rating                     CONSTANT NUMBER := 18;
   g_a_Partner_Level                       CONSTANT NUMBER := 19;
   g_a_Partner_Enrollment_Date             CONSTANT NUMBER := 708;
   g_a_Total_Vendor_Assigned_Opp           CONSTANT NUMBER := 709;
   g_a_Total_PT_Created                    CONSTANT NUMBER := 710;
   g_a_VAD_relationship_exists             CONSTANT NUMBER := 711;

   g_a_Area_Code                           CONSTANT NUMBER := 532;
   g_a_County                              CONSTANT NUMBER := 533;
   g_a_Province                            CONSTANT NUMBER := 534;
   g_a_City                                CONSTANT NUMBER := 535;
   g_a_Postal_Code                         CONSTANT NUMBER := 536;
   g_a_Primary_Email_Specified             CONSTANT NUMBER := 537;
   g_a_customer_name                       CONSTANT NUMBER := 565;
   g_a_email_address                       CONSTANT NUMBER := 582;
   g_a_email_domain                        CONSTANT NUMBER := 568;
   g_a_primary_contact_name                CONSTANT NUMBER := 566;
   g_a_primary_contact_job_title           CONSTANT NUMBER := 567;
   g_a_all                                 CONSTANT NUMBER := 571;
   g_a_lead_note_type                      CONSTANT NUMBER := 572;
   g_a_created_within                      CONSTANT NUMBER := 573;
   g_a_interaction_score                   CONSTANT NUMBER := 574;
   g_a_Campaign_Setup_Type                 CONSTANT NUMBER := 575;
   g_a_business_event_type                 CONSTANT NUMBER := 801;


/*
   g_FUE_attr_id               CONSTANT NUMBER := 510;
   --g_FUE_attr_id               CONSTANT NUMBER := 1;
   g_purchase_amount_attr_id   CONSTANT NUMBER := 512;
   g_purchase_quantity_attr_id CONSTANT NUMBER := 511;
   g_pss_attr_id               CONSTANT NUMBER := 521;
   g_pss_amount_attr_id        CONSTANT NUMBER := 525;
   g_pss_quantity_attr_id      CONSTANT NUMBER := 524;
*/
   -- ---------------------------------------------------------
   -- This is a dummy attribute ID, which is not a real
   -- attribute in the seeded database.
   -- ---------------------------------------------------------
   g_dummy_attr_id             CONSTANT NUMBER := 0;

   -- ---------------------------------------------------------
   -- Currency Conversion Status Flag. Currency_Conversion will
   -- return this number if there is anything wrong during the
   -- conversion.
   -- ---------------------------------------------------------
   g_currency_conversion_error CONSTANT NUMBER := FND_API.G_MISS_NUM;

   -- ---------------------------------------------------------
   -- Operators
   -- ---------------------------------------------------------
   g_equal                     CONSTANT VARCHAR2(30) := 'EQUALS';
   g_not_equal                 CONSTANT VARCHAR2(30) := 'NOT_EQUALS';
   g_greater_than              CONSTANT VARCHAR2(30) := 'GREATER_THAN';
   g_greater_than_equal        CONSTANT VARCHAR2(30) := 'GREATER_THAN_OR_EQUALS';
   g_less_than                 CONSTANT VARCHAR2(30) := 'LESS_THAN';
   g_less_than_equal           CONSTANT VARCHAR2(30) := 'LESS_THAN_OR_EQUALS';
   g_is_null                   CONSTANT VARCHAR2(30) := 'IS_NULL';
   g_is_not_null               CONSTANT VARCHAR2(30) := 'IS_NOT_NULL';
   g_between                   CONSTANT VARCHAR2(30) := 'BETWEEN';
   g_begins_with               CONSTANT VARCHAR2(30) := 'BEGINS_WITH';
   g_ends_with                 CONSTANT VARCHAR2(30) := 'ENDS_WITH';
   g_contains                  CONSTANT VARCHAR2(30) := 'CONTAINS';
   g_not_contains              CONSTANT VARCHAR2(30) := 'NOT_CONTAINS';


   -- -----------------------------------------------------------------
   -- Used in currency_conversion.
   --
   -- g_period_set_name = FND_PROFILE.Value('AS_FORECAST_CALENDAR')
   -- g_period_type     = FND_PROFILE.Value('AS_DEFAULT_PERIOD_TYPE');
   -- -----------------------------------------------------------------
   g_period_set_name           VARCHAR2(100);
   g_period_type               VARCHAR2(100);
   g_display_message           BOOLEAN := TRUE;


   -- ---------------------------------------------------------
   -- This delimiter is used to separate tokens within an
   -- attribute value for attributes with multiple tokens like
   -- currency and purchase amount attributes.
   --
   -- For example,
   --    1000000:::USD:::20020103145608
   -- ---------------------------------------------------------
   g_token_delimiter    CONSTANT VARCHAR2(3) := ':::';


   TYPE r_entity_attr_value IS RECORD (
      attribute_value    VARCHAR2(4000),
      return_type    VARCHAR2(30)
   );

   TYPE t_entity_attr_value IS TABLE OF r_entity_attr_value
      INDEX BY BINARY_INTEGER;

   TYPE r_input_filter IS RECORD (
      attribute_id       NUMBER,
      attribute_value    VARCHAR2(4000)
   );

   TYPE t_input_filter IS TABLE OF r_input_filter
      INDEX BY BINARY_INTEGER;



   PROCEDURE Get_Entity_Attr_Values (
      p_api_version_number   IN      NUMBER,
      p_init_msg_list        IN      VARCHAR2 := FND_API.G_FALSE,
      p_commit               IN      VARCHAR2 := FND_API.G_FALSE,
      p_validation_level     IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
      p_attribute_id         IN      NUMBER,
      p_entity               IN      VARCHAR2,
      p_entity_id            IN      NUMBER,
      p_delimiter            IN      VARCHAR2,
      p_expand_attr_flag     IN      VARCHAR2 := 'Y',
      x_entity_attr_value    IN OUT  NOCOPY t_entity_attr_value,
      x_return_status        OUT     NOCOPY VARCHAR2,
      x_msg_count            OUT     NOCOPY NUMBER,
      x_msg_data             OUT     NOCOPY VARCHAR2
   );

   FUNCTION Check_Match (
      p_attribute_id         IN      NUMBER,
      p_entity_attr_value    IN      VARCHAR2,
      p_rule_attr_value      IN      VARCHAR2,
      p_rule_to_attr_value   IN      VARCHAR2,
      p_operator             IN      VARCHAR2,
      p_input_filter         IN      t_input_filter,
      p_delimiter            IN      VARCHAR2,
      p_return_type          IN      VARCHAR2,
      p_rule_currency_code   IN      VARCHAR2
   )
   RETURN BOOLEAN;

   -- ------------------------------------------------------------------
   -- Expose this to public.
   -- ------------------------------------------------------------------
   FUNCTION Check_Match (
      p_attribute_id         IN      NUMBER,
      p_entity               IN      VARCHAR2,
      p_entity_id            IN      NUMBER,
      p_rule_attr_value      IN      VARCHAR2,
      p_rule_to_attr_value   IN      VARCHAR2,
      p_operator             IN      VARCHAR2,
      p_input_filter         IN      t_input_filter,
      p_delimiter            IN      VARCHAR2,
      p_rule_currency_code   IN      VARCHAR2,
      x_entity_attr_value    IN OUT  NOCOPY t_entity_attr_value
   )
   RETURN BOOLEAN;


   PROCEDURE Retrieve_Input_Filter (
      p_api_version_number   IN      NUMBER,
      p_init_msg_list        IN      VARCHAR2 := FND_API.G_FALSE,
      p_commit               IN      VARCHAR2 := FND_API.G_FALSE,
      p_validation_level     IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
      p_process_rule_id      IN      NUMBER,
      p_delimiter            IN      VARCHAR2 := '+++',
      x_input_filter         IN OUT  NOCOPY t_input_filter,
      x_return_status        OUT     NOCOPY VARCHAR2,
      x_msg_count            OUT     NOCOPY NUMBER,
      x_msg_data             OUT     NOCOPY VARCHAR2
   );

   -- -----------------------------------------------------------------------------------
   -- Currency_Conversion
   --
   -- p_entity_attr_value comes in the form of 3 tokens of
   -- <currency_amount>:::<currency_code>:::<currency_conversion_date>
   --
   -- where <currency_conversion_date> has the following date format:
   --
   -- yyyymmddhh24miss
   --
   -- e.g.
   -- 100000:::USD:::20020103145100
   -- -----------------------------------------------------------------------------------
   FUNCTION Currency_Conversion(
      p_entity_attr_value  IN VARCHAR2,
      p_rule_currency_code IN VARCHAR2,
      p_no_exception_flag        IN VARCHAR2 := 'N'

   )
   RETURN NUMBER;


   -- -----------------------------------------------------------------------------------
   -- Currency_Conversion
   --
   -- This function does not take 3 tokens as the one above. This assumes that the token
   -- string has already been parsed into p_amount, p_currency_code, and
   -- p_currency_conversion_date.
   -- -----------------------------------------------------------------------------------
   FUNCTION Currency_Conversion(
      p_amount                   IN NUMBER,
      p_currency_code            IN VARCHAR2,
      p_currency_conversion_date IN DATE := SYSDATE,
      p_rule_currency_code       IN VARCHAR2,
      p_no_exception_flag        IN VARCHAR2 := 'N'
   )
   RETURN NUMBER;


   -- -----------------------------------------------------------------------------------
   -- Currency_Conversion
   -- -----------------------------------------------------------------------------------
   FUNCTION Currency_Conversion(
      p_entity_attr_value  IN VARCHAR2
   )
   RETURN NUMBER;


   -- -----------------------------------------------------------------------------------
   -- Given a string that contains attribute values separated by p_delimiter, retrieve
   -- the n th (p_index) token in the string.
   -- e.g.
   -- p_attr_value_string = '+++abc+++def+++'; p_delimiter = '+++'; p_index = 2.
   -- This function will return 'def'.
   -- If p_index is out of bound, return g_out_of_bound.
   --
   -- There are 2 types (p_input_type) of p_attr_value_string:
   -- (1) +++abc+++def+++                ==> 'STD TOKEN'
   -- (2) 1000000:::USD:::20011225164500 ==> 'In Token'
   --
   -- When the p_input_type is 'In Token', we will pad p_attr_value_string with
   -- p_delimiter like the following:
   -- :::1000000:::USD:::20011225164500:::
   -- -----------------------------------------------------------------------------------
   FUNCTION Retrieve_Token(
      p_delimiter           VARCHAR2,
      p_attr_value_string   VARCHAR2,
      p_input_type          VARCHAR2,
      p_index               NUMBER
   )
   RETURN VARCHAR2;

   -- -----------------------------------------------------------------------------------
   -- Given a string, p_string, search for the number of tokens separated by the
   -- delimiter, p_delimiter.
   --
   -- e.g.
   --   p_string = '+++abc+++def+++ghi+++'
   --   p_delimiter = '+++'
   --   The function will return 3 because there are 3 tokens in the string.
   -- -----------------------------------------------------------------------------------
   FUNCTION Get_Num_Of_Tokens (
      p_delimiter       VARCHAR2,
      p_string          VARCHAR2
   )
   RETURN NUMBER;


-- -----------------------------------------------------------------------------------
   -- For given a Partner_Id, Attribute_id, it returns value for currency related attribute
   --
   -- -----------------------------------------------------------------------------------
   FUNCTION get_attr_curr(
                p_partner_id IN NUMBER ,
                p_attribute_id IN NUMBER)
   RETURN VARCHAR2;

   -- -----------------------------------------------------------------------------------
   -- For given a Partner_Id, Attribute_id, it returns value for count related attribute
   --
   -- -----------------------------------------------------------------------------------
   FUNCTION get_attr_cnt(
                p_partner_id IN NUMBER ,
                p_attribute_id IN NUMBER)
   RETURN NUMBER;


   -- -----------------------------------------------------------------------------------
   -- For given a Partner_Id, Attribute_id, it returns value for rate related attribute
   --
   -- -----------------------------------------------------------------------------------
   FUNCTION get_attr_rate(
                p_partner_id IN NUMBER ,
                p_attribute_id IN NUMBER)
   RETURN NUMBER;

   -- -----------------------------------------------------------------------------------
   -- For a given ATTRIBUTE_ID, and ATTR_CODE_ID it returns description of the attribute
   -- code_id. E.g. It's mainly used for Partner_Level attribute only.
   --
   -- -----------------------------------------------------------------------------------
   FUNCTION get_partner_level_desc(
                p_attribute_id IN NUMBER,
		p_attr_code_id IN NUMBER
		)
   RETURN VARCHAR2;

   -- -----------------------------------------------------------------------------------
   -- For a given a ATTRIBUTE_ID, and ATTR_CODE, it returns description of the attribute
   -- code. E.g. It's mainly used for all attributes other than Partner_Level code.
   --
   -- -----------------------------------------------------------------------------------
   FUNCTION get_attr_code_desc(
                p_attribute_id IN NUMBER,
		p_attr_code    IN VARCHAR2
		)
   RETURN VARCHAR2;

END pv_check_match_pub;

 

/
