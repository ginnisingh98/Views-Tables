--------------------------------------------------------
--  DDL for Package GMD_SEARCH_REPLACE_VERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_SEARCH_REPLACE_VERS" AUTHID CURRENT_USER AS
/* $Header: GMDSREPS.pls 120.2.12010000.1 2008/07/24 10:00:15 appldev ship $ */

P_created_by        NUMBER := FND_PROFILE.VALUE('USER_ID');
P_login_id          NUMBER := FND_PROFILE.VALUE('LOGIN_ID');

PROCEDURE create_new_routing(p_routing_id IN  NUMBER,
                             p_effective_start_date IN VARCHAR2,
                             p_effective_end_date IN VARCHAR2,
                             p_inactive_ind IN NUMBER,
                             p_owner IN NUMBER,
                             p_old_operation IN NUMBER,
                             p_new_operation IN NUMBER,
                             p_routing_class IN VARCHAR2,
                             x_routing_id OUT NOCOPY NUMBER);

PROCEDURE create_new_operation(p_oprn_id IN  NUMBER,
                               p_old_activity IN VARCHAR2,
                               p_activity IN VARCHAR2,
                               p_effective_start_date IN VARCHAR2,
                               p_effective_end_date IN VARCHAR2,
                               p_operation_class IN VARCHAR2,
                               p_inactive_ind IN NUMBER,
                               p_old_resource IN VARCHAR2,
                               p_resource IN VARCHAR2,
                               x_oprn_id OUT NOCOPY NUMBER);

PROCEDURE create_new_recipe(p_recipe_id IN  NUMBER,
                            p_routing_id IN NUMBER,
                            p_formula_id IN NUMBER,
                            powner_id  IN NUMBER,
                            powner_orgn_code IN VARCHAR2,
			    p_Organization_id IN NUMBER,
			    p_recipe_type IN NUMBER,
                            x_recipe_id OUT NOCOPY NUMBER);

PROCEDURE create_new_formula(p_formula_id IN  NUMBER,
                             p_formula_class IN VARCHAR2,
                             p_inactive_ind IN NUMBER,
                             p_new_ingredient IN NUMBER,
                             p_old_ingredient IN NUMBER,
			     p_old_ingr_revision IN VARCHAR2,
			     p_new_ingr_revision IN VARCHAR2,
                             p_owner_id IN NUMBER,
                             x_formula_id OUT NOCOPY NUMBER,
                             x_scale_factor NUMBER DEFAULT NULL,
                             pCreate_Recipe  IN  NUMBER DEFAULT 0);

END gmd_search_replace_vers;

/
