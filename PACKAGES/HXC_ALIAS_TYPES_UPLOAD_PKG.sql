--------------------------------------------------------
--  DDL for Package HXC_ALIAS_TYPES_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_ALIAS_TYPES_UPLOAD_PKG" AUTHID CURRENT_USER AS
/* $Header: hxcaltload.pkh 115.0 2002/08/21 08:33:56 vkonda noship $ */
PROCEDURE load_alias_type_row (
        p_alias_type                IN VARCHAR2
	, p_reference_object        IN VARCHAR2
	, p_owner		    IN VARCHAR2
	, p_custom_mode	     	    IN VARCHAR2 );

PROCEDURE load_alias_comp_row (
        p_component_name            IN VARCHAR2
	, p_component_type 	    IN VARCHAR2
	, p_mapping_component_name  IN VARCHAR2
	, p_alias_type              IN VARCHAR2
	, p_reference_object        IN VARCHAR2
	, p_owner		    IN VARCHAR2
	, p_custom_mode	     	    IN VARCHAR2 );
END hxc_alias_types_upload_pkg;

 

/
