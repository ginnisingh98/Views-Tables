--------------------------------------------------------
--  DDL for Package GMPMPACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMPMPACT" AUTHID CURRENT_USER AS
/* $Header: GMPMPACS.pls 120.1.12010000.2 2009/11/09 21:29:19 rpatangy ship $ */

PROCEDURE print_mps_activity
(errbuf             OUT NOCOPY VARCHAR2,
 retcode            OUT NOCOPY  VARCHAR2,
 V_organization_id   IN NUMBER,
 V_schedule          IN NUMBER,
-- V_schedule_id       IN NUMBER,
 V_Category_Set_id   IN NUMBER,
 V_Structure_Id      IN NUMBER,
 V_fcategory         IN VARCHAR2,
 V_tcategory         IN VARCHAR2,
 V_fbuyer            IN VARCHAR2,
 V_tbuyer            IN VARCHAR2,
 V_fplanner          IN VARCHAR2,
 V_tplanner          IN VARCHAR2,
 V_forg              IN VARCHAR2,
 V_torg              IN VARCHAR2,
 V_fitem             IN VARCHAR2,
 V_titem             IN VARCHAR2,
 V_ftrans_date       IN VARCHAR2,
 V_ttrans_date       IN VARCHAR2,
 /*V_ftrans_date       IN DATE,
 V_ttrans_date       IN DATE, */
 V_critical_indicator IN  NUMBER,
  V_template          IN VARCHAR2,
 V_template_locale   IN VARCHAR2
);

 PROCEDURE ps_generate_xml ;

 FUNCTION schedule (p_schedule_id NUMBER) RETURN VARCHAR2;

 FUNCTION category_set (p_category_set_id NUMBER) RETURN VARCHAR2;

 FUNCTION item_name (p_inventory_item_id NUMBER, p_organization_id NUMBER) RETURN VARCHAR2;

 FUNCTION organization_code (p_organization_id NUMBER) RETURN VARCHAR2;

 FUNCTION planner_code (p_inventory_item_id NUMBER, p_organization_id NUMBER) RETURN VARCHAR2;

 FUNCTION buyer_name (p_inventory_item_id NUMBER, p_organization_id NUMBER) RETURN VARCHAR2;

 FUNCTION onhand_qty (p_inventory_item_id NUMBER, p_organization_id NUMBER) RETURN NUMBER;

 FUNCTION unit_of_measure (p_inventory_item_id NUMBER, p_organization_id NUMBER) RETURN VARCHAR2;

 FUNCTION category (p_category_id NUMBER) RETURN VARCHAR2;

 PROCEDURE ps_generate_output(p_sequence_num IN NUMBER);

 PROCEDURE xml_transfer (errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2, p_sequence_num IN NUMBER) ;

 END GMPMPACT;

/
