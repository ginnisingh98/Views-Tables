--------------------------------------------------------
--  DDL for Package GMPPSRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMPPSRP" AUTHID CURRENT_USER as
/* $Header: GMPPSRPS.pls 120.1 2005/07/19 10:44:53 nsinghi noship $ */

/*
PROCEDURE gmp_print_mps
			 (	errbuf              OUT NOCOPY VARCHAR2,
 				retcode             OUT NOCOPY VARCHAR2,
 				V_schedule_id  	  IN NUMBER,
 				V_fplanning_class   IN VARCHAR2,
 				V_tplanning_class   IN VARCHAR2,
 				V_fwhse_code        IN VARCHAR2,
 				V_twhse_code        IN VARCHAR2,
  				V_fitem_no          IN VARCHAR2,
 				V_titem_no          IN VARCHAR2,
 				V_fBuyer_Plnr       IN VARCHAR2,
 				V_tBuyer_Plnr       IN VARCHAR2,
 				V_whse_security     IN VARCHAR2,
 				V_printer           IN VARCHAR2,
 				V_number_of_copies  IN NUMBER,
 				V_user_print_style  IN VARCHAR2,
				V_run_date          IN DATE,
				V_schedule          IN VARCHAR2  );
*/
PROCEDURE gmp_print_mps
			 (	errbuf              OUT NOCOPY VARCHAR2,
 				retcode             OUT NOCOPY VARCHAR2,
                                V_organization_id   IN NUMBER,
                                V_schedule          IN NUMBER,
-- 				V_schedule_id  	    IN NUMBER,
                                V_Category_Set      IN NUMBER,
                                V_Structure_Id      IN NUMBER,
--                                V_Category_set_id   IN NUMBER,
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

        PROCEDURE ps_generate_output(p_sequence_num IN NUMBER) ;

        PROCEDURE xml_transfer (errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2, p_sequence_num IN NUMBER) ;

END GMPPSRP;

 

/
