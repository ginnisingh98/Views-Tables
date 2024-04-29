--------------------------------------------------------
--  DDL for Package RRS_SITE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RRS_SITE_UTILS" AUTHID CURRENT_USER AS
/* $Header: RRSUTILS.pls 120.8.12010000.7 2010/02/01 20:00:23 jijiao ship $ */

FUNCTION GET_LOCATION_ADDRESS
	(
		p_site_id IN NUMBER
	) RETURN VARCHAR2;

FUNCTION GET_SITE_DISPLAY_NAME
	(
		p_site_id IN NUMBER
	) RETURN VARCHAR2;

FUNCTION GET_USER_ATTR_VAL
	(
		p_attr_grp_type IN VARCHAR2,
		p_attr_grp_name IN VARCHAR2,
		p_attr_name IN VARCHAR2,
		p_object_name IN VARCHAR2,
		p_pk_col_val IN VARCHAR2
	)RETURN VARCHAR2;

PROCEDURE INSERT_TEMP_FOR_MAP
	(
		x_theme_id OUT NOCOPY NUMBER,
		p_session_id IN VARCHAR2,
		p_context_flag IN VARCHAR2,
		p_site_ids IN RRS_NUMBER_TBL_TYPE DEFAULT NULL,
		p_tag_code IN NUMBER DEFAULT NULL,
		p_x_coord IN NUMBER DEFAULT NULL,
		p_y_coord IN NUMBER DEFAULT NULL
	);

PROCEDURE CLEAR_TEMP_FOR_MAP
	(
		p_session_id IN VARCHAR2,
        	p_delete_theme IN VARCHAR2
	);

FUNCTION GET_LOCATION_NAME
	(
		p_site_id IN NUMBER
	) RETURN VARCHAR2;

FUNCTION GET_PROPERTY_NAME
        (
                p_location_id IN NUMBER
        ) RETURN VARCHAR2 ;

FUNCTION GET_UOM_COLUMN_PROMPT
	(
		p_uom_class IN VARCHAR2
	)RETURN VARCHAR2;



FUNCTION get_ordinate
	(geom IN MDSYS.SDO_GEOMETRY,
	 indx IN NUMBER
	) RETURN NUMBER;

FUNCTION get_address
	(p_loc_id IN NUMBER
	) RETURN VARCHAR2;

PROCEDURE Update_geometry_for_locations
 (p_loc_id IN NUMBER,
  p_lat IN NUMBER,
  p_long IN NUMBER,
  p_status IN VARCHAR2,
  p_geo_source IN VARCHAR2 DEFAULT 'RRS_GOOGLE',
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data  OUT NOCOPY VARCHAR2
 ) ;

/* Added for bugfix 8800595 */
PROCEDURE get_geometry_for_location
 (p_loc_id IN NUMBER,
  x_geo_source OUT NOCOPY VARCHAR2,
	x_null_flag OUT NOCOPY VARCHAR2,
  x_latitude OUT NOCOPY NUMBER,
  x_longitude OUT NOCOPY NUMBER,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data  OUT NOCOPY VARCHAR2
 ) ;

/* Added for bugfix 8903725 */
PROCEDURE set_geometry_src_for_location
 (p_loc_id IN NUMBER,
  x_geo_source_was_null OUT NOCOPY VARCHAR2,
  x_geo_source_set_value OUT NOCOPY VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data  OUT NOCOPY VARCHAR2
 ) ;

PROCEDURE default_site_numbers
 (p_result_format_usage_id IN NUMBER,
  p_site_number_col_name VARCHAR2,
  p_site_name_col_name VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_data  OUT NOCOPY VARCHAR2
 ) ;

Procedure Add_Favorite_objects(P_OBJECT_TYPE IN VARCHAR2,
                               P_OBJECT_ID   IN VARCHAR2,
                               P_OBJECT_NAME IN VARCHAR2,
                               P_USER_ID     IN NUMBER,
                               X_RET_STATUS  OUT NOCOPY VARCHAR2);

Procedure isAGAndClsAssocDeletable
(
	p_application_id	IN 		NUMBER,
	p_classification_code	IN 		VARCHAR2,
	p_attr_group_type	IN 		VARCHAR2,
	p_attr_group_name	IN 		VARCHAR2,
	x_is_ag_deletable	OUT NOCOPY 	VARCHAR2
);

END RRS_SITE_UTILS;


/
