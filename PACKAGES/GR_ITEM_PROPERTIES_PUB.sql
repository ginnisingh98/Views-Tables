--------------------------------------------------------
--  DDL for Package GR_ITEM_PROPERTIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_ITEM_PROPERTIES_PUB" AUTHID CURRENT_USER AS
/*  $Header: GRPIITPS.pls 120.3.12010000.2 2009/06/19 16:21:30 plowe noship $*/
/*#
 * This interface is used to create, delete, and update item property values.
 * This package defines and implements the procedures required
 * to create, delete, and update item properties.
 * @rep:scope public
 * @rep:product GR
 * @rep:lifecycle active
 * @rep:displayname GR Item Properties Package
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY GR_ITEM_PROPERTIES
 */

/*   Define Procedures And Functions :   */

 /*#
 * Create, delete, and update item property values
 * This is a PL/SQL procedure to create, delete, and update item properties.
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_commit Flag to check for commit
 * @param p_item_properties_tab is table of input records of type gr_item_properties_rec_type listed below
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of msg's on message stack
 * @param x_msg_data Actual message data on message stack
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create, delete, and update item properties procedure
 * @rep:compatibility S  */



TYPE gr_item_properties_rec_type IS RECORD
(
 action     VARCHAR2(1)
,organization VARCHAR2(3)
,organization_id NUMBER
,item VARCHAR2(40)
,inventory_item_id NUMBER
,field_name_code VARCHAR2(5)
,property_id varchar2(6)
,numeric_value  NUMBER(15,9)  -- 8208515   increased decimal precision from 6 to 9.
,alpha_value VARCHAR2(240)
,phrase_code VARCHAR2(15)
,date_value date
,language_code VARCHAR2(4)
);

TYPE gr_item_properties_tab_type IS TABLE OF gr_item_properties_rec_type INDEX BY BINARY_INTEGER;


PROCEDURE ITEM_PROPERTIES
( p_api_version          IN  NUMBER
, p_init_msg_list        IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_commit               IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_item_properties_tab IN  GR_ITEM_PROPERTIES_PUB.gr_item_properties_tab_type
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
);

END GR_ITEM_PROPERTIES_PUB;


/
