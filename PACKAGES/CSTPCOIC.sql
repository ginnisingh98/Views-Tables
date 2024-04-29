--------------------------------------------------------
--  DDL for Package CSTPCOIC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPCOIC" AUTHID CURRENT_USER AS
/* $Header: CSTPCOIS.pls 115.5 2002/11/09 00:42:34 awwang ship $ */

FUNCTION copy_to_interface(
	copy_option		IN NUMBER,
	from_org_id 		IN NUMBER,
	to_org_id 		IN NUMBER,
	from_cst_type_id 	IN NUMBER,
	to_cst_type_id 		IN NUMBER,
	range_option 		IN NUMBER,
	spec_item_id            IN NUMBER,
        spec_cat_set_id         IN NUMBER,
        spec_cat_id             IN NUMBER,
        grp_id                  IN NUMBER,
        conv_type		IN VARCHAR2,
        l_last_updated_by       IN NUMBER,
	error_msg 		OUT NOCOPY VARCHAR2
) RETURN INTEGER;


END CSTPCOIC;

 

/
