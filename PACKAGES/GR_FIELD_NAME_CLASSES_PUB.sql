--------------------------------------------------------
--  DDL for Package GR_FIELD_NAME_CLASSES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_FIELD_NAME_CLASSES_PUB" AUTHID CURRENT_USER AS
/*  $Header: GRPIFNCS.pls 120.0.12010000.2 2009/06/19 16:16:25 plowe noship $*/
/*#
 * This interface is used to create, delete, and validate field names.
 * This package defines and implements the procedures required
 * to create, delete, and validate filed names.
 * @rep:scope public
 * @rep:product GR
 * @rep:lifecycle active
 * @rep:displayname GR Field Names Package
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY GR_FIELD_NAME_CLASSESS
 */



/*   Define Procedures And Functions :   */



TYPE gr_label_class_resp_rec_type IS RECORD
(
 responsibility_id NUMBER
,responsibility   VARCHAR2(100)
,display_sequence    NUMBER
,allow_create_update VARCHAR2(1)
);

TYPE gr_label_class_resp_tab_type IS TABLE OF gr_label_class_resp_rec_type INDEX BY BINARY_INTEGER;


PROCEDURE FIELD_NAME_CLASSES
( p_api_version          IN  NUMBER
, p_init_msg_list        IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_commit               IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_action               IN  VARCHAR2
, p_object               IN  VARCHAR2
, p_FIELD_NAME_CLASS     IN VARCHAR2
, p_form_block           IN VARCHAR2
, p_language             IN VARCHAR2
, p_source_language      IN VARCHAR2
, p_description          IN VARCHAR2
, p_label_class_resp_tab IN  GR_FIELD_NAME_CLASSES_PUB.gr_label_class_resp_tab_type
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
);

END GR_FIELD_NAME_CLASSES_PUB;


/
