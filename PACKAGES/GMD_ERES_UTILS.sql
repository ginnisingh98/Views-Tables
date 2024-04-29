--------------------------------------------------------
--  DDL for Package GMD_ERES_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_ERES_UTILS" AUTHID CURRENT_USER as
/* $Header: GMDERESS.pls 120.7.12000000.2 2007/02/13 12:16:25 kmotupal ship $ */

PROCEDURE get_operation_no(P_oprn_id IN NUMBER, P_oprn_no OUT NOCOPY VARCHAR2);

PROCEDURE get_operation_vers(P_oprn_id IN NUMBER,P_oprn_vers OUT NOCOPY NUMBER);

PROCEDURE get_formula_no(P_formula_id IN NUMBER, P_formula_no OUT NOCOPY VARCHAR2);

PROCEDURE get_formula_vers(P_formula_id IN NUMBER,P_formula_vers OUT NOCOPY NUMBER);

PROCEDURE get_formula_desc(P_formula_id IN NUMBER, P_formula_desc OUT NOCOPY VARCHAR2);

PROCEDURE get_recipe_no(P_recipe_id IN NUMBER, P_recipe_no OUT NOCOPY VARCHAR2);

PROCEDURE get_recipe_version(P_recipe_id IN NUMBER,P_recipe_version OUT NOCOPY NUMBER);

PROCEDURE get_routing_no(P_routing_id IN NUMBER, P_routing_no OUT NOCOPY VARCHAR2);

PROCEDURE get_routing_vers(P_routing_id IN NUMBER,P_routing_vers OUT NOCOPY NUMBER);

PROCEDURE get_line_type_desc (P_formulaline_id IN NUMBER, P_line_type_desc OUT NOCOPY VARCHAR2);

PROCEDURE get_status_meaning(P_status_code IN NUMBER, P_meaning OUT NOCOPY VARCHAR2);

PROCEDURE get_process_qty_um(P_oprn_id IN NUMBER,P_prc_qty_um OUT NOCOPY VARCHAR2);

PROCEDURE get_activity_desc(p_activity IN VARCHAR2, p_activity_desc OUT NOCOPY VARCHAR2);

PROCEDURE get_resource_desc(p_resource IN VARCHAR2, p_resource_desc OUT NOCOPY VARCHAR2);

PROCEDURE get_proc_param_desc(p_parameter_id IN NUMBER, x_parameter_desc OUT NOCOPY VARCHAR2);

PROCEDURE get_proc_param_units(p_parameter_id IN NUMBER, x_units OUT NOCOPY VARCHAR2);

PROCEDURE set_formula_status(p_formula_id IN NUMBER,
                             p_from_status IN VARCHAR2,
                             p_to_status IN VARCHAR2,
                             p_signature_status IN VARCHAR2 DEFAULT NULL);

PROCEDURE set_operation_status(p_oprn_id IN NUMBER,
                               p_from_status IN VARCHAR2,
                               p_to_status IN VARCHAR2,
                               p_signature_status IN VARCHAR2 DEFAULT NULL);

PROCEDURE set_routing_status(p_routing_id IN NUMBER,
                             p_from_status IN VARCHAR2,
                             p_to_status IN VARCHAR2,
                             p_signature_status IN VARCHAR2 DEFAULT NULL);

PROCEDURE set_recipe_status(p_recipe_id IN NUMBER,
                            p_from_status IN VARCHAR2,
                            p_to_status IN VARCHAR2,
                            p_signature_status IN VARCHAR2 DEFAULT NULL,
                            p_create_validity IN NUMBER DEFAULT 0);

PROCEDURE set_validity_status(p_validity_rule_id IN NUMBER,
                              p_from_status IN VARCHAR2,
                              p_to_status IN VARCHAR2,
                              p_signature_status IN VARCHAR2 DEFAULT NULL);

PROCEDURE set_auto_recipe_status(p_formula_id       IN NUMBER,
                                 p_orgn_id          IN NUMBER,
                                 p_from_status      IN VARCHAR2,
                                 p_to_status        IN VARCHAR2,
                                 p_signature_status IN VARCHAR2 DEFAULT NULL);

 -- Bug number 4479101
PROCEDURE set_substitution_status (p_substitution_id  IN NUMBER
                                  ,p_from_status      IN VARCHAR2
                                  ,p_to_status        IN VARCHAR2
                                  ,p_signature_status IN VARCHAR2 DEFAULT NULL);

PROCEDURE set_formulation_spec_status(p_formulation_spec_id IN NUMBER,
                                      p_from_status IN VARCHAR2,
                                      p_to_status IN VARCHAR2,
                                      p_signature_status IN VARCHAR2);


FUNCTION check_recipe_validity_eres (p_recipe_id IN NUMBER,
                                    p_to_status IN VARCHAR2)
RETURN BOOLEAN;

FUNCTION esig_required (p_event IN VARCHAR2,
                        p_event_key IN VARCHAR2,
                        p_to_status IN VARCHAR2)
RETURN BOOLEAN;

PROCEDURE update_formula_status   ( p_formula_id        IN         VARCHAR2,
                                    p_from_status       IN        VARCHAR2,
                                    p_to_status                IN        VARCHAR2,
                                    p_pending_status        IN        VARCHAR2,
                                    p_rework_status        IN        VARCHAR2,
                                    p_object_name        IN        VARCHAR2,
                                    p_object_version        IN        NUMBER,
                                    p_called_from_form  IN        VARCHAR2 DEFAULT 'F',
                                    x_return_status        OUT NOCOPY VARCHAR2);

PROCEDURE update_operation_status(  p_oprn_id           IN         VARCHAR2,
                                    p_from_status       IN        VARCHAR2,
                                    p_to_status                IN        VARCHAR2,
                                    p_pending_status        IN        VARCHAR2,
                                    p_rework_status        IN        VARCHAR2,
                                    p_object_name        IN        VARCHAR2,
                                    p_object_version        IN        NUMBER,
                                    p_called_from_form  IN        VARCHAR2 DEFAULT 'F',
                                    x_return_status        OUT NOCOPY VARCHAR2);

PROCEDURE update_routing_status (   p_routing_id        IN         VARCHAR2,
                                    p_from_status       IN        VARCHAR2,
                                    p_to_status                IN        VARCHAR2,
                                    p_pending_status        IN        VARCHAR2,
                                    p_rework_status        IN        VARCHAR2,
                                    p_object_name        IN        VARCHAR2,
                                    p_object_version        IN        NUMBER,
                                    p_called_from_form  IN        VARCHAR2 DEFAULT 'F',
                                    x_return_status        OUT NOCOPY VARCHAR2);

PROCEDURE update_recipe_status  (   p_recipe_id         IN         VARCHAR2,
                                    p_from_status       IN        VARCHAR2,
                                    p_to_status                IN        VARCHAR2,
                                    p_pending_status        IN        VARCHAR2,
                                    p_rework_status        IN        VARCHAR2,
                                    p_object_name        IN        VARCHAR2,
                                    p_object_version        IN        NUMBER,
                                    p_called_from_form  IN        VARCHAR2 DEFAULT 'F',
                                    x_return_status        OUT NOCOPY VARCHAR2);

PROCEDURE update_validity_rule_status ( p_validity_rule_id IN   VARCHAR2,
                                        p_from_status      IN        VARCHAR2,
                                        p_to_status           IN        VARCHAR2,
                                        p_pending_status   IN        VARCHAR2,
                                        p_rework_status           IN        VARCHAR2,
                                        p_called_from_form IN        VARCHAR2 DEFAULT 'F',
                                        x_return_status           OUT NOCOPY VARCHAR2);
-- Bug 5394532
PROCEDURE update_substitution_status (p_substitution_id IN NUMBER,
                                      p_from_status        IN        VARCHAR2,
                                      p_to_status             IN        VARCHAR2,
                                      p_pending_status     IN        VARCHAR2,
                                      p_rework_status             IN        VARCHAR2,
                                      p_called_from_form   IN        VARCHAR2 DEFAULT 'F',
                                      x_return_status             OUT NOCOPY VARCHAR2);

/*Thomas Daniel - The raise event procedure has been moved to GMD_EDR_STANDARD */
/*PROCEDURE raise_event (p_event_name      in varchar2,
                       p_event_key        in varchar2,
                       p_parameter_name1  in varchar2  default NULL,
                       p_parameter_value1 in varchar2  default NULL,
                       p_parameter_name2  in varchar2  default NULL,
                       p_parameter_value2 in varchar2  default NULL,
                       p_parameter_name3  in varchar2  default NULL,
                       p_parameter_value3 in varchar2  default NULL,
                       p_parameter_name4  in varchar2  default NULL,
                       p_parameter_value4 in varchar2  default NULL,
                       p_parameter_name5  in varchar2  default NULL,
                       p_parameter_value5 in varchar2  default NULL,
                       p_parameter_name6  in varchar2  default NULL,
                       p_parameter_value6 in varchar2  default NULL,
                       p_parameter_name7  in varchar2  default NULL,
                       p_parameter_value7 in varchar2  default NULL,
                       p_parameter_name8  in varchar2  default NULL,
                       p_parameter_value8 in varchar2  default NULL,
                       p_parameter_name9  in varchar2  default NULL,
                       p_parameter_value9 in varchar2  default NULL,
                       p_parameter_name10  in varchar2 default NULL,
                       p_parameter_value10 in varchar2 default NULL);*/

PROCEDURE get_recipe_details (
		P_formula_id      	IN  	   NUMBER,
                P_recipe_no        	OUT NOCOPY VARCHAR2,
                P_recipe_vers        	OUT NOCOPY NUMBER,
                P_recipe_desc        	OUT NOCOPY VARCHAR2,
                P_recipe_status        	OUT NOCOPY VARCHAR2,
                P_recipe_type           OUT NOCOPY NUMBER );

PROCEDURE get_validity_details (
		P_formula_id            IN         NUMBER,
 		p_orgn_id              	OUT NOCOPY NUMBER, -- Krishna NPD Conv
                P_item_id               OUT NOCOPY NUMBER,
                --p_revision              OUT NOCOPY NUMBER, -- Krishna NPD Conv --commented for bug #5218333
                p_revision              OUT NOCOPY VARCHAR2,
                P_item_um               OUT NOCOPY VARCHAR2,
                P_min_qty               OUT NOCOPY NUMBER,
                P_max_qty               OUT NOCOPY NUMBER,
                P_std_qty               OUT NOCOPY NUMBER,
                P_inv_min_qty           OUT NOCOPY NUMBER,
                P_inv_max_qty           OUT NOCOPY NUMBER,
                P_min_eff_date          OUT NOCOPY DATE,
                P_max_eff_date          OUT NOCOPY DATE,
                P_recipe_use            OUT NOCOPY VARCHAR2,
                P_preference            OUT NOCOPY NUMBER,
                P_validity_rule_status  OUT NOCOPY VARCHAR2 );

--Krishna 10-Feb-2005 NPD Convergence,
--Created procedures GET_ORGANIZATION_CODE,GET_ITEM_NO_DESC and GET_LOOKUP_VALUE   for to migrate GMI procedure calls to GMD_ERES_UTILS package.
PROCEDURE get_organization_code
( p_orgn_id   IN NUMBER,
  p_orgn_code OUT NOCOPY VARCHAR2);

PROCEDURE get_item_no_desc
( pitem_id          IN NUMBER,
  porgn_id          IN NUMBER,
  pitem_no          OUT NOCOPY VARCHAR2,
  pitem_desc        OUT NOCOPY VARCHAR2 );

PROCEDURE get_lookup_value (
 plookup_type       IN VARCHAR2,
 plookup_code       IN VARCHAR2,
 pmeaning           OUT NOCOPY VARCHAR2);

PROCEDURE get_tech_parm_name(P_tech_parm_id IN NUMBER, P_tech_parm_name OUT NOCOPY VARCHAR2,
                             P_unit_code OUT NOCOPY VARCHAR2);

PROCEDURE get_category_name(P_category_id IN NUMBER, P_category_name OUT NOCOPY VARCHAR2);

PROCEDURE get_category_set_name(P_category_set_id IN NUMBER, P_category_set_name OUT NOCOPY VARCHAR2);

PROCEDURE get_formula_line_no(P_formulaline_id IN NUMBER,P_formulaline_no OUT NOCOPY NUMBER);

-- Kapil LCF-GMO ME Bug# 5456888
-- To get Routing details
PROCEDURE get_routing_details_eres (
	        P_doc_id      	        IN  	 VARCHAR2,
                P_routing_no        	OUT NOCOPY VARCHAR2,
                P_routing_vers        	OUT NOCOPY NUMBER,
                P_routing_desc        	OUT NOCOPY VARCHAR2,
                P_routing_status        OUT NOCOPY VARCHAR2,
                P_enhancd_PI_ind            OUT NOCOPY VARCHAR2  );

-- Kapil ME Auto-Prod : Bug# 5716318
PROCEDURE get_yes_no_value (
                 plookup_code       IN VARCHAR2,
                 pmeaning           OUT NOCOPY VARCHAR2);
end GMD_ERES_UTILS;

 

/
