--------------------------------------------------------
--  DDL for Package FTE_COMP_CONSTRAINT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_COMP_CONSTRAINT_UTIL" AUTHID CURRENT_USER as
/* $Header: FTECCUTS.pls 115.2 2003/01/21 01:32:24 ttrichy noship $ */

--G_PKG_NAME CONSTANT VARCHAR2(30) := 'FTE_COMP_CONSTRAINT_UTIL';

-- Global Variables

FUNCTION get_object_name(
             --p_comp_class_id           IN NUMBER,
             p_object_type             IN      VARCHAR2,
             p_object_value_num        IN NUMBER DEFAULT NULL,
             p_object_parent_id        IN NUMBER DEFAULT NULL,
             p_object_value_char       IN VARCHAR2 DEFAULT NULL,
             x_fac_company_name        OUT NOCOPY      VARCHAR2,
             x_fac_company_type        OUT NOCOPY  VARCHAR2 ) RETURN VARCHAR2 ;

PROCEDURE get_facility_display(
             p_source_location_id      IN VARCHAR2,
             p_source_location_code    IN VARCHAR2,
             x_fac_sites               OUT NOCOPY      VARCHAR2,
             x_fac_company_type        OUT NOCOPY      VARCHAR2,
             x_fac_company_name        OUT NOCOPY      VARCHAR2,
             x_return_status           OUT NOCOPY      VARCHAR2,
	     x_msg_count               OUT NOCOPY      NUMBER,
	     x_msg_data                OUT NOCOPY      VARCHAR2 );

END FTE_COMP_CONSTRAINT_UTIL;


 

/
