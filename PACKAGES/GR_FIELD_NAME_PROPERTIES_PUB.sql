--------------------------------------------------------
--  DDL for Package GR_FIELD_NAME_PROPERTIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_FIELD_NAME_PROPERTIES_PUB" AUTHID CURRENT_USER AS
/*  $Header: GRPIFNPS.pls 120.1.12010000.2 2009/06/19 21:59:29 plowe noship $*/
/*#
 * This interface is used to create, delete, and validate field name properties.
 * This package defines and implements the procedures required
 * to create, delete, and validate filed names.
 * @rep:scope public
 * @rep:product GR
 * @rep:lifecycle active
 * @rep:displayname GR Field Name Properties Package
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY GR_PROPERTIES
 */




TYPE gr_label_prop_values_rec_type IS RECORD
(
 display_order    NUMBER
,value            VARCHAR2(30)
,value_description VARCHAR2(240)
);

TYPE gr_label_prop_values_tab_type IS TABLE OF gr_label_prop_values_rec_type INDEX BY BINARY_INTEGER;


PROCEDURE FIELD_NAME_PROPERTIES
( p_api_version          IN  NUMBER
, p_init_msg_list        IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_commit               IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_action               IN  VARCHAR2
, p_object               IN  VARCHAR2
, p_property_id          IN VARCHAR2
, p_property_type_indicator IN VARCHAR2
, p_length               IN NUMBER
, p_precision            IN NUMBER
, p_range_min            IN NUMBER
, p_range_max            IN NUMBER
, p_language             IN VARCHAR2
, p_source_language      IN VARCHAR2
, p_description          IN VARCHAR2
, p_label_prop_values_tab IN  GR_FIELD_NAME_PROPERTIES_PUB.gr_label_prop_values_tab_type
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
);

END GR_FIELD_NAME_PROPERTIES_PUB;


/
