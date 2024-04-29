--------------------------------------------------------
--  DDL for Package GMF_CBOM_REP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_CBOM_REP_PKG" AUTHID CURRENT_USER AS
/* $Header: GMFIBOMS.pls 120.2 2007/12/17 10:22:49 pmarada noship $ */

       p_where_clause  VARCHAR2(2000);
FUNCTION BeforeReportTrigger RETURN BOOLEAN ;

FUNCTION Get_Quantity (
 p_invy_item_id        IN NUMBER,
 p_prod_invy_item_id   IN NUMBER,
 p_prod_ingr_ind       IN VARCHAR2,  -- values 'P', 'I', or 'B'
 p_organization_id     IN NUMBER ,
 p_cost_type_id        IN NUMBER ,
 p_period_id           IN NUMBER
) RETURN VARCHAR2 ;

FUNCTION get_le_name(p_le_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_currency(p_le_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_cost_type(p_ct_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_OrderBy (p_sort_by IN NUMBER) RETURN VARCHAR2;

FUNCTION get_Period_Id(p_legal_entity_id IN NUMBER, p_calendar_code IN VARCHAR2, p_period_code IN VARCHAR2, p_cost_type_id IN NUMBER) RETURN NUMBER ;

FUNCTION get_item_name(v_item_id IN NUMBER) RETURN VARCHAR2 ;

FUNCTION get_category_name(v_cat_id IN NUMBER) RETURN VARCHAR2 ;

FUNCTION get_Category (p_from_cat IN VARCHAR2,p_to_cat IN VARCHAR2) RETURN VARCHAR2 ;

END gmf_cbom_rep_pkg;

/
