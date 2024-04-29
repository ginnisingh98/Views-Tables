--------------------------------------------------------
--  DDL for Package IBE_M_AUTOPLACEMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_M_AUTOPLACEMENT_PVT" AUTHID CURRENT_USER AS
/* $Header: IBEVMAPS.pls 120.0.12010000.1 2008/07/28 11:38:34 appldev ship $ */

g_pkg_name   CONSTANT VARCHAR2(30):='IBE_M_AUTOPLACEMENT_PVT';
g_api_version CONSTANT NUMBER := 1.0;

TYPE PRODUCT_REC_TYPE IS RECORD (
  PRODUCT_NUMBER VARCHAR2(40),
  PRODUCT_NAME VARCHAR2(240), -- Description
  ACTION VARCHAR2(10),
  SECTION_CODE VARCHAR2(240),
  SECTION_NAME VARCHAR2(120));

TYPE PRODUCT_TBL_TYPE IS TABLE OF PRODUCT_REC_TYPE INDEX BY
  BINARY_INTEGER;

FUNCTION checkSection(p_section_id IN NUMBER) RETURN VARCHAR2;

FUNCTION check_section(p_section_id IN NUMBER,
  p_master_mini_site_id IN NUMBER) RETURN VARCHAR2;


PROCEDURE prod_autoplacement(
	    p_placement_mode IN VARCHAR2 default NULL,
	    p_assignment_mode IN VARCHAR2 default NULL,
	    p_target_section IN NUMBER default NULL,
	    p_include_subsection IN VARCHAR2 default NULL,
	    p_product_name IN VARCHAR2 default NULL,
	    p_product_number VARCHAR2 default NULL,
	    p_publish_flag VARCHAR2 default NULL,
	    p_start_date IN DATE default NULL,
	    p_end_date IN DATE default NULL,
	    x_return_status OUT NOCOPY VARCHAR2,
	    x_msg_count OUT NOCOPY NUMBER,
	    x_msg_data OUT NOCOPY VARCHAR2);


PROCEDURE autoPlacement(errbuf OUT NOCOPY VARCHAR2,
				    retcode OUT NOCOPY VARCHAR2,
				    p_placement_mode IN VARCHAR2 default NULL,
				    p_assignment_mode IN VARCHAR2 default NULL,
				    p_target_section IN VARCHAR2 default NULL,
				    p_include_subsection IN VARCHAR2 default NULL,
				    p_product_name IN VARCHAR2 default NULL,
				    p_product_number IN VARCHAR2 default NULL,
				    p_publish_flag IN VARCHAR2 default NULL,
				    p_start_date IN VARCHAR2 default NULL,
				    p_end_date IN VARCHAR2 default NULL,
				    p_debug_flag IN VARCHAR2 default 'Y');

END IBE_M_AUTOPLACEMENT_PVT;

/
