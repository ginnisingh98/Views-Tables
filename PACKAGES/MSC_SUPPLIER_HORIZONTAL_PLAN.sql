--------------------------------------------------------
--  DDL for Package MSC_SUPPLIER_HORIZONTAL_PLAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_SUPPLIER_HORIZONTAL_PLAN" AUTHID CURRENT_USER AS
/*	$Header: MSCHSPLS.pls 120.1 2005/06/10 14:03:17 appldev  $ */

FUNCTION populate_horizontal_plan(
			p_item_list_id		IN NUMBER,
			p_org_id		IN NUMBER,
			p_inst_id		IN NUMBER,
			p_plan_id		IN NUMBER,
			p_bucket_type		IN NUMBER,
			p_cutoff_date		IN DATE,
			p_current_data		IN NUMBER DEFAULT 2) RETURN NUMBER;

PROCEDURE query_list(p_query_id IN NUMBER,
                p_plan_id IN NUMBER,
                p_item_list IN VARCHAR2,
                p_org_list IN VARCHAR2,
                p_supplier_list IN VARCHAR2,
                p_supplier_site_list IN VARCHAR2);

FUNCTION get_order_type_label (p_supplier_site_id NUMBER)
	RETURN VARCHAR2;

END msc_supplier_horizontal_plan;

 

/
