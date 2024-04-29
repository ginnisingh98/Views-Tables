--------------------------------------------------------
--  DDL for Package RRS_ATTR_PANE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RRS_ATTR_PANE" AUTHID CURRENT_USER AS
/* $Header: RRSGATPS.pls 120.0.12010000.6 2010/03/12 23:57:57 jijiao noship $ */


PROCEDURE Get_Primary_Attributes
(
	p_object_type		IN		VARCHAR2,
	p_object_id		IN		VARCHAR2,
	x_primary_attributes	OUT NOCOPY 	rrs_primary_attribute_rec,
	x_error_messages	OUT NOCOPY 	rrs_error_msg_tab
);

TYPE t_array_of_number IS TABLE OF NUMBER;
TYPE t_attribute_rec IS RECORD (attr_name	VARCHAR2(30),
				attr_display_name	VARCHAR2(80),
				display_code	VARCHAR2(10),		-- Bug Fix 9453429: Add display_code
				description	VARCHAR2(240),
				sequence	NUMBER);
TYPE t_attribute_tab IS TABLE OF t_attribute_rec;
TYPE t_page_entry_rec IS RECORD (attr_group_type	VARCHAR2(40),
				 attr_group_name	VARCHAR2(30),
				 sequence		NUMBER);
TYPE t_page_entry_tab IS TABLE OF t_page_entry_rec;

e_no_uda		EXCEPTION;
e_no_page_found		EXCEPTION;
e_no_page_entry_found	EXCEPTION;

PROCEDURE Get_Attribute_Page
(
	p_where_used		IN		VARCHAR2,
	p_object_type		IN		VARCHAR2,
	p_object_id		IN		NUMBER,
	p_object1		IN		VARCHAR2,
	p_classification_code1	IN		VARCHAR2,
	p_object2		IN		VARCHAR2,
	p_classification_code2	IN		VARCHAR2,
	x_primary_attributes	OUT NOCOPY	rrs_primary_attribute_rec,
	x_ag_page_tab		OUT NOCOPY	rrs_attr_group_page_tab,
	x_attr_group_tab	OUT NOCOPY	rrs_attribute_group_tab,
	x_attribute_tab		OUT NOCOPY	rrs_attribute_tab,
	x_error_messages	OUT NOCOPY	rrs_error_msg_tab
);

TYPE array_of_string	IS TABLE OF VARCHAR2(200);
TYPE attr_info_rec	IS RECORD (database_column 	EGO_ATTRS_V.DATABASE_COLUMN%TYPE,
				   data_type_code	EGO_ATTRS_V.DATA_TYPE_CODE%TYPE,
				   info_1		EGO_ATTRS_V.INFO_1%TYPE,
				   uom_class		EGO_ATTRS_V.UOM_CLASS%TYPE,
				   value_set_id		EGO_ATTRS_V.VALUE_SET_ID%TYPE,
				   validation_code	EGO_ATTRS_V.VALIDATION_CODE%TYPE,
				   display_code		EGO_ATTRS_V.DISPLAY_CODE%TYPE,
				   display_meaning	EGO_ATTRS_V.DISPLAY_MEANING%TYPE);

e_no_attribute_found	   EXCEPTION;
e_no_attr_group_found 	   EXCEPTION;
e_no_ext_row_found	   EXCEPTION;
e_no_uom_found		   EXCEPTION;
e_no_value_set_value_found EXCEPTION;
e_invalid_where_clause	   EXCEPTION;

PROCEDURE Get_Display_Value
(
	p_object_type		IN		VARCHAR2,
	p_object_id		IN		NUMBER,
	p_attr_group_type	IN		VARCHAR2,
	p_attr_group_name	IN		VARCHAR2,
	p_attr_name 		IN		VARCHAR2,
	p_ext_id		IN		NUMBER,
	x_display_value		OUT NOCOPY	VARCHAR2,
	x_display_type		OUT NOCOPY	VARCHAR2,
	x_dynamic_url		OUT NOCOPY	VARCHAR2,
	x_error_messages	OUT NOCOPY 	rrs_error_msg_tab
);

--Added for Bug Fix 6969229
Procedure Get_Display_Value
(
	p_object_type		IN		VARCHAR2,
	p_object_id		IN		NUMBER,
	p_attr_group_id		IN		NUMBER,
	p_ext_id		IN		NUMBER,
	p_column_name 		IN		VARCHAR2,
	x_display_value		OUT NOCOPY	VARCHAR2,
	x_msg_data		OUT NOCOPY 	VARCHAR2
);

PROCEDURE Record_Error
(
	p_error_message		IN		VARCHAR2,
	x_error_messages	OUT NOCOPY	rrs_error_msg_tab
);

--PROCEDURE TEST;

END RRS_ATTR_PANE;

/
