--------------------------------------------------------
--  DDL for Package OE_OE_FOLDER_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_OE_FOLDER_EXT" AUTHID CURRENT_USER AS
/* $Header: OEXFEXTS.pls 120.1.12010000.1 2008/07/25 07:47:57 appldev ship $ */

TYPE Config_Buttons_Rec IS RECORD
(
  Action_Id NUMBER,
  OBJECT VARCHAR2(30),
  ACTION_NAME Varchar2(500),
  User_Entered_Prompt Varchar2(500),
  Default_Prompt Varchar2(500),
  Display_As_Button Varchar2(1),
  Access_Key      Varchar2(6), ---- Bug 5528134, increased the width to 6
  width  Number,
  Folder_Id  Varchar2(10)
);


TYPE Config_Buttons_Tbl IS TABLE OF Config_Buttons_Rec
    INDEX BY BINARY_INTEGER;

PROCEDURE Get_Customized_Buttons
            (
             p_folder_id        IN  Number
           , x_custom_buttons_tbl OUT NOCOPY /* file.sql.39 change */ Oe_Oe_Folder_Ext.Config_Buttons_Tbl
           , x_default_buttons_tbl OUT NOCOPY /* file.sql.39 change */ Oe_Oe_Folder_Ext.Config_Buttons_Tbl
            );
PROCEDURE Get_Buttons_List
            (
             p_folder_id        IN  Number
           , p_displayed_buttons IN Oe_Oe_Folder_Ext.Config_Buttons_Tbl
           , x_buttons_tbl OUT NOCOPY /* file.sql.39 change */ Oe_Oe_Folder_Ext.Config_Buttons_Tbl
            );
PROCEDURE Store_Custom_Buttons
            (
             p_folder_id        IN  Number
           , p_config_buttons_tbl IN Oe_Oe_Folder_Ext.Config_Buttons_Tbl
           , l_return_status     OUT NOCOPY /* file.sql.39 change */ Varchar2
           , x_custom_buttons_tbl OUT NOCOPY /* file.sql.39 change */ Oe_Oe_Folder_Ext.Config_Buttons_Tbl
           , x_default_buttons_tbl OUT NOCOPY /* file.sql.39 change */ Oe_Oe_Folder_Ext.Config_Buttons_Tbl
            );

PROCEDURE INSERT_FOLDER
                      (p_folder_extension_id IN Number,
                       p_object IN Varchar2,
                       p_user_id IN Number,
                       p_folder_id IN Number,
                       p_pricing_tab IN Varchar2 Default Null,
                       p_service_tab IN Varchar2 Default Null,
                       p_others_tab IN Varchar2 Default Null,
                       p_addresses_tab IN varchar2 Default Null,
                       p_returns_tab  IN Varchar2 Default Null,
                       p_shipping_tab IN Varchar2 Default Null,
                       p_headers_others_tab IN Varchar2 Default Null,
                       p_options_details IN Varchar2 Default Null,
                       p_services_details IN Varchar2 Default Null,
                       p_adjustment_details IN Varchar2 Default Null,
                       p_related_item_details IN Varchar2 Default Null,
                       p_pricing_ava_details IN Varchar2 Default Null,
                       p_default_line_region IN Varchar2 Default Null
                      );

PROCEDURE FOLDER_ACTIONS_INIT( x_others_flag OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                               x_pricing_flag OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                               x_addresses_flag OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                               x_services_flag  OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                               x_shipping_flag  OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                               x_returns_flag  OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                               x_header_others_flag OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                               x_options_details    OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                               x_services_details   OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                               x_adjustment_details OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                               x_related_item_details OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                               x_pricing_ava_details  OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                               x_default_line_region OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                               x_custom_buttons_tbl OUT NOCOPY /* file.sql.39 change */
                               Oe_Oe_Folder_Ext.Config_Buttons_Tbl,
                               x_default_buttons_tbl OUT NOCOPY /* file.sql.39 change */
                               Oe_Oe_Folder_Ext.Config_Buttons_Tbl,
                               p_order_folder_object IN Varchar DEFAULT 'OE_ORDERS_TELESALES',
			       p_line_folder_object IN Varchar DEFAULT 'OE_LINE_TELESALES'
                                );

PROCEDURE DELETE_FOLDER(p_folder_extension_id IN Number Default Null ,
                       p_folder_id IN Number
                     );

PROCEDURE Defer_Pricing(p_mode In Varchar2);
END Oe_Oe_Folder_Ext;


/
