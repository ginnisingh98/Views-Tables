--------------------------------------------------------
--  DDL for Package CSC_RESPONSE_CENTER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_RESPONSE_CENTER_PKG" AUTHID CURRENT_USER AS
/* $Header: CSCCCRCS.pls 120.3.12010000.3 2010/03/15 10:37:18 spamujul ship $ */

   FUNCTION G_MISS_NUM RETURN NUMBER;
   FUNCTION G_MISS_CHAR RETURN VARCHAR2;
   FUNCTION G_MISS_DATE RETURN DATE;
   FUNCTION G_VALID_LEVEL(p_level varchar2) RETURN NUMBER;
   FUNCTION G_BOOLEAN(p_flag varchar2) RETURN VARCHAR2;
   FUNCTION GET_ERROR_CONSTANT(err_msg VARCHAR2) RETURN VARCHAR2;

   --end of commenting out V1 references

   -- Define record type which will be used to transfer data between Contact Center form and
   -- Service Request form

   TYPE CC_SR_INT IS RECORD (
   party_id                  NUMBER,
   party_number              VARCHAR2(30),
   party_relationship_id     NUMBER,
   relation                  VARCHAR2(30),
   object_id                 NUMBER,
   obj_party_type            VARCHAR2(30),
   obj_company_name          VARCHAR2(255),
   obj_group_name            VARCHAR2(255),
   obj_group_type            VARCHAR2(30),
   obj_first_name            VARCHAR2(150),
   obj_middle_name           VARCHAR2(60),
   obj_last_name             VARCHAR2(150),
   obj_title                 VARCHAR2(60),
   subject_id                NUMBER,
   sub_party_type            VARCHAR2(30),
   sub_first_name            VARCHAR2(150),
   sub_middle_name           VARCHAR2(60),
   sub_last_name             VARCHAR2(150),
   sub_title                 VARCHAR2(60),
   location_id               NUMBER,
   type                      VARCHAR2(60),
   address                   VARCHAR2(963),
   address1                  VARCHAR2(240),
   address2                  VARCHAR2(240),
   address3                  VARCHAR2(240),
   address4                  VARCHAR2(240),
   city                      VARCHAR2(60),
   state                     VARCHAR2(60),
   province                  VARCHAR2(60),
   postal_code               VARCHAR2(60),
   county                    VARCHAR2(60),
   country                   VARCHAR2(60),
   cust_account_org_id       NUMBER,
   cust_account_id           NUMBER,
   account_number            VARCHAR2(30),
   contact_point_id          NUMBER,
   country_code              VARCHAR2(10),
   area_code                 VARCHAR2(10),
   extension                 VARCHAR2(20),
   phone_number              VARCHAR2(40),
   contact_point_type        VARCHAR2(30),
   phone_line_type           VARCHAR2(30),
   email_contact_point_id    NUMBER,
   email_address             VARCHAR2(2000),
   ins_upd_flag              VARCHAR2(1),
   dir_flag                  VARCHAR2(2),
   default_tab               VARCHAR2(100),
   rel_last_update_date      DATE,
   obj_last_update_date      DATE,
   sub_last_update_date      DATE,
   loc_last_update_date      DATE,
   acct_last_update_date     DATE,
   phone_last_update_date    DATE,
   email_last_update_date    DATE,
   incident_id               NUMBER,
   incident_number           VARCHAR2(64),
   interaction_id            NUMBER);

   -- Initialization function for the record type
   FUNCTION INIT_CC_SR_INT RETURN CC_SR_INT;

   G_MISS_CC_SR_INT		CC_SR_INT;

   -- wh_update_date is addded in the record. This is used as last update date in
   -- Update address proc. Fix for bug #1567159

   TYPE address_rec_type IS RECORD(
	location_id                   NUMBER         := FND_API.G_MISS_NUM,
        address1                      VARCHAR2(240)  := FND_API.G_MISS_CHAR,
        address2                      VARCHAR2(240)  := FND_API.G_MISS_CHAR,
        address3                      VARCHAR2(240)  := FND_API.G_MISS_CHAR,
        address4                      VARCHAR2(240)  := FND_API.G_MISS_CHAR,
	address_lines_phonetic        VARCHAR2(560)  := FND_API.G_MISS_CHAR,
        city                          VARCHAR2(60)   := FND_API.G_MISS_CHAR,
        state                         VARCHAR2(60)   := FND_API.G_MISS_CHAR,
        postal_code                   VARCHAR2(60)   := FND_API.G_MISS_CHAR,
        province                      VARCHAR2(60)   := FND_API.G_MISS_CHAR,
        county                        VARCHAR2(60)   := FND_API.G_MISS_CHAR,
        country                       VARCHAR2(60)   := FND_API.G_MISS_CHAR,
        language                      VARCHAR2(4)    := FND_API.G_MISS_CHAR,
        street                        VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        house_number                  VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        apartment_number              VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        building                      VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        position                      VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        po_box_number                 VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        address_key                   VARCHAR2(500)  := FND_API.G_MISS_CHAR,
        apartment_flag                VARCHAR2(1)    := FND_API.G_MISS_CHAR,
        street_suffix                 VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        secondary_suffix_element      VARCHAR2(240)  := FND_API.G_MISS_CHAR,
        rural_route_type              VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        rural_route_number            VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        street_number                 VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        floor                         VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        suite                         VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        room                          VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        postal_plus4_code             VARCHAR2(10)   := FND_API.G_MISS_CHAR,
        time_zone                     VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        post_office                   VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        delivery_point_code           VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        location_directions           VARCHAR2(640)  := FND_API.G_MISS_CHAR,
        address_error_code            VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        clli_code                     VARCHAR2(60)   := FND_API.G_MISS_CHAR,
        dodaac                        VARCHAR2(6)    := FND_API.G_MISS_CHAR,
        trailing_directory_code       VARCHAR2(60)   := FND_API.G_MISS_CHAR,
        life_cycle_status             VARCHAR2(30)   := FND_API.G_MISS_CHAR,
        short_description             VARCHAR2(240)  := FND_API.G_MISS_CHAR,
        description                   VARCHAR2(2000) := FND_API.G_MISS_CHAR,
        sales_tax_geocode             VARCHAR2(30)   := FND_API.G_MISS_CHAR,
        sales_tax_inside_city_limits  VARCHAR2(30)   := FND_API.G_MISS_CHAR,
        timezone_id                   NUMBER         := FND_API.G_MISS_NUM,
	address_effective_date        DATE           := FND_API.G_MISS_DATE,
	address_expiration_date       DATE           := FND_API.G_MISS_DATE,
	address_style                 VARCHAR2(30)   := FND_API.G_MISS_CHAR,
        wh_update_date                DATE           := FND_API.G_MISS_DATE);

   FUNCTION GET_ADDRESS_REC_TYPE RETURN CSC_RESPONSE_CENTER_PKG.ADDRESS_REC_TYPE;


   -- Buffer to store data for successful transfer from Contact Center to SR and vice versa
   CC_SR_BUFFER 		CC_SR_INT := G_MISS_CC_SR_INT;

   -- To populate data into CC-SR buffer
   PROCEDURE Put_in_CC_SR_Buffer (
      p_cc_sr_int_rec   IN   CC_SR_INT);

   -- To retrieve data from CC-SR buffer
   PROCEDURE Get_from_CC_SR_Buffer (
      x_cc_sr_int_rec   OUT  NOCOPY  CC_SR_INT);

   -- To initialise CC-SR buffer
   PROCEDURE Init_CC_SR_Buffer;

   -- Wrapper for HZ procedure : phone_format for phone number globalization
   FUNCTION phone_format_Wrap(	p_phone_country_code IN VARCHAR2,
                                p_phone_area_code    IN VARCHAR2,
                                p_phone_number       IN VARCHAR2)
   RETURN varchar2;

   -- Here are objects relation to New Search window
   TYPE AccountRecType IS RECORD (
      party_id              NUMBER,
      Account_Name          VARCHAR2(240),
      Account_Number        VARCHAR2(30),
      Cust_Account_id       NUMBER,
      object_version_number NUMBER);

   TYPE PhoneRecType IS RECORD (
      Party_id               NUMBER,
      Full_Phone	     VARCHAR2(60),
      Phone_country_code     VARCHAR2(10),
      Phone_Area_Code	     VARCHAR2(10),
      Phone_number           VARCHAR2(40),
      Phone_line_Type        VARCHAR2(80),
      Phone_Line_Code        VARCHAR2(30),
      Phone_id               NUMBER,
      Phone_Extension	     VARCHAR2(20),
      object_version_number  NUMBER);

   TYPE AccountRecTabType IS TABLE OF AccountRecType INDEX BY BINARY_INTEGER;
   TYPE PhoneRecTabType   IS TABLE OF PhoneRecType INDEX BY BINARY_INTEGER;
   TYPE SiteIDRecTabType  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;   -- added for NCR ER# 8606060 by mpathani

   PROCEDURE get_account_details(x_account_rec IN OUT NOCOPY AccountRecTabType);
   PROCEDURE get_phone_details(x_phone_rec IN OUT NOCOPY PhoneRecTabType);

   -- added get_sitephone_details for NCR ER# 8606060 by mpathani
   PROCEDURE get_sitephone_details(p_site_id   IN SiteIDRecTabType,
                                   x_phone_rec IN OUT NOCOPY PhoneRecTabType);

   PROCEDURE start_media_item( p_resp_appl_id in number,
                               p_resp_id      in number,
                               p_user_id      in number,
                               p_login_id     in number,
                               x_return_status out nocopy  varchar2,
                               x_msg_count     out nocopy  number,
                               x_msg_data      out nocopy  varchar2,
                               x_media_id      out nocopy  number
			       ,x_outbound_dnis in varchar2 DEFAULT NULL  -- added by spamujul for 9370084
	  		       ,x_outbound_ani in varchar2 DEFAULT NULL -- added by spamujul for 9370084
			       );


END CSC_RESPONSE_CENTER_PKG;

/
