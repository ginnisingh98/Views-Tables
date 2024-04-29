--------------------------------------------------------
--  DDL for Package GMD_VERSION_CONTROL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_VERSION_CONTROL" AUTHID CURRENT_USER AS
/* $Header: GMDVCTLS.pls 120.1.12010000.1 2008/07/24 10:01:29 appldev ship $ */

P_created_by        NUMBER := FND_PROFILE.VALUE('USER_ID');
P_login_id          NUMBER := FND_PROFILE.VALUE('LOGIN_ID');

PROCEDURE create_routing(p_routing_id IN  NUMBER, x_routing_id OUT NOCOPY NUMBER);
PROCEDURE create_operation(p_oprn_id IN  NUMBER, x_oprn_id OUT NOCOPY NUMBER);
PROCEDURE create_recipe(p_recipe_id IN  NUMBER, x_recipe_id OUT NOCOPY NUMBER);
PROCEDURE create_formula(p_formula_id IN  NUMBER, x_formula_id OUT NOCOPY NUMBER);
PROCEDURE create_substitution(p_substitution_id IN  NUMBER, x_substitution_id OUT NOCOPY NUMBER); -- Bug number 4252212
--BEGIN BUG#3258592
PROCEDURE populate_temp_text(p_text_code number,flag number);
TYPE edit_text_tab IS TABLE OF fm_text_tbl_tl%ROWTYPE INDEX BY BINARY_INTEGER;
edit_text_tbl edit_text_tab;
--END BUG#3258592

END gmd_version_control;

/
