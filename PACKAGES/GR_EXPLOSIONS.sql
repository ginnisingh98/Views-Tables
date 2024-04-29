--------------------------------------------------------
--  DDL for Package GR_EXPLOSIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_EXPLOSIONS" AUTHID CURRENT_USER AS
/*$Header: GRPXPLNS.pls 120.1 2005/07/08 12:22:45 methomas noship $*/

/*
**		PL/SQL table defined for global use with the package procedures
**		to record the lower level formulas that need to be exploded.
*/

TYPE explosion_list IS RECORD
   (organization_id NUMBER,
    inventory_item_id   NUMBER,
	parent_formula	NUMBER,
	current_formula	NUMBER,
	quantity		NUMBER,
/*
** M.Thomas 05-Feb-2002 Bug 1323951 Added the following to the PL/SQL Table
*/
           weight_pct           NUMBER);

/*
** M.Thomas 05-Feb-2002 Bug 1323951 End of the changes to the PL/SQL Table
*/

TYPE t_explosion_list IS TABLE OF explosion_list
      INDEX BY BINARY_INTEGER;

/*
**		PL/SQL table defined for global use with the package procedures
**		to record the missing ingredients while exploding the formula.
*/
TYPE t_missing_ing_list IS TABLE OF gr_item_general.item_code%TYPE
      INDEX BY BINARY_INTEGER;

/*
**	Datastructures
*/
L_EXPLOSION_LIST        GR_EXPLOSIONS.t_explosion_list;
L_MISSING_ING_LIST      GR_EXPLOSIONS.t_missing_ing_list;

/* M. Grosser 19-Feb-2002  BUG 1323951 - Added for ingredient list for toxicity calculation  */
L_INGREDIENT_LIST       GR_EXPLOSIONS.t_explosion_list;


/*	Alphanumeric Global Variables */

G_PKG_NAME			CONSTANT VARCHAR2(255) := 'GR_EXPLOSIONS';
G_CURRENT_DATE		DATE := sysdate;

/*	Numeric Global Variables */

/* 11 Dec 2001 Mercy Thomas        Bug 2145449 -- Added value to the Global variable G_USER_ID */
G_USER_ID			NUMBER := FND_GLOBAL.USER_ID;

/* M. Grosser 19-Feb-2002  BUG 1323951 - Added for ingredient list for toxicity calculation  */
G_MAX_INGRED NUMBER := 0;

/* MGROSSER */
G_FORMULA_NO         VARCHAR2(32);
G_FORMULA_VERS       NUMBER;
G_RECIPE_NO          VARCHAR2(32);
G_RECIPE_VERS        NUMBER;

   PROCEDURE OPM_410_MSDS_Formula
				(p_commit IN VARCHAR2,
				 p_init_msg_list IN VARCHAR2,
				 p_validation_level IN NUMBER,
				 p_api_version IN NUMBER,
				 p_organization_id NUMBER,
                 p_inventory_item_id IN NUMBER,
				 p_session_id IN NUMBER,
				 x_return_status OUT NOCOPY VARCHAR2,
				 x_msg_count OUT NOCOPY NUMBER,
				 x_msg_data OUT NOCOPY VARCHAR2);
   PROCEDURE OPM_410_Lab_Formula
				(p_commit IN VARCHAR2,
				 p_init_msg_list IN VARCHAR2,
				 p_validation_level IN NUMBER,
				 p_api_version IN NUMBER,
				 p_organization_id NUMBER,
                 p_inventory_item_id IN NUMBER,
				 p_session_id IN NUMBER,
				 x_return_status OUT NOCOPY VARCHAR2,
				 x_msg_count OUT NOCOPY NUMBER,
				 x_msg_data OUT NOCOPY VARCHAR2);
   PROCEDURE OPM_11i_MSDS_Formula
				(p_commit IN VARCHAR2,
				 p_init_msg_list IN VARCHAR2,
				 p_validation_level IN NUMBER,
				 p_api_version IN NUMBER,
	             p_organization_id NUMBER,
                 p_inventory_item_id IN NUMBER,
				 p_session_id IN NUMBER,
				 x_return_status OUT NOCOPY VARCHAR2,
				 x_msg_count OUT NOCOPY NUMBER,
				 x_msg_data OUT NOCOPY VARCHAR2);
   PROCEDURE OPM_11i_Lab_Formula
				(p_commit IN VARCHAR2,
				 p_init_msg_list IN VARCHAR2,
				 p_validation_level IN NUMBER,
				 p_api_version IN NUMBER,
		         p_organization_id NUMBER,
                 p_inventory_item_id IN NUMBER,
				 p_session_id IN NUMBER,
				 x_return_status OUT NOCOPY VARCHAR2,
				 x_msg_count OUT NOCOPY NUMBER,
				 x_msg_data OUT NOCOPY VARCHAR2);
   PROCEDURE Handle_Error_Messages
				(p_called_by_form IN VARCHAR2,
				 p_message_code IN VARCHAR2,
				 p_token_name IN VARCHAR2,
				 p_token_value IN VARCHAR2,
				 x_msg_count IN OUT NOCOPY NUMBER,
				 x_msg_data IN OUT NOCOPY VARCHAR2,
				 x_return_status OUT NOCOPY VARCHAR2);

/*
**	routine for checking circular reference
*/
  FUNCTION check_circular_reference(p_organization_id IN NUMBER,
                 p_inventory_item_id IN NUMBER,
				     p_parent_formula NUMBER,
				     p_max_record NUMBER) RETURN BOOLEAN;
/*
**	Procedure for Inserting/Updating transactions
*/
  PROCEDURE process_concentrations
				(p_organization_id IN NUMBER,
                                 p_inventory_item_id IN NUMBER,
				 p_explosion_item_id IN NUMBER,
				 p_source_item_id IN NUMBER,
				 p_item_percent	IN NUMBER,
				 p_current_record IN NUMBER,
				 p_item_um	IN VARCHAR2,
				 x_msg_count IN OUT NOCOPY NUMBER,
				 x_msg_data IN OUT NOCOPY VARCHAR2,
				 x_return_status OUT NOCOPY VARCHAR2);

/*
** M.Thomas 05-Feb-2002 Bug 1323951 Added the following Procedure to build the list of the exploded components
**                                  and return it in table form
*/


    PROCEDURE build_explosion_list
	 				(p_commit IN VARCHAR2,
					 p_init_msg_list IN VARCHAR2,
					 p_validation_level IN NUMBER,
					 p_api_version IN NUMBER,
				     p_organization_id NUMBER,
                     p_inventory_item_id IN NUMBER,
					 p_session_id IN NUMBER,
                     x_explosion_list OUT NOCOPY GR_EXPLOSIONS.t_explosion_list,
					 x_return_status OUT NOCOPY VARCHAR2,
					 x_msg_count OUT NOCOPY NUMBER,
					 x_msg_data OUT NOCOPY VARCHAR2);

/*
** M.Thomas 05-Feb-2002 Bug 1323951 End of the changes to the Procedure to build the list of the exploded components
*/


  /* M. Grosser 19-Feb-2002  BUG 1323951 - Added for ingredient list for toxicity calculation  */
  PROCEDURE add_to_ingredient_list (p_organization_id   IN NUMBER,
                                    p_inventory_item_id IN NUMBER,
                                    p_conc_percent      IN NUMBER,
                                    p_wt_percent        IN NUMBER );


   /* Melanie Grosser 20-May-2003  BUG 2932007 - Document Management Phase I
                                   Added new procedure OPM_MSDS_Formula_With_IDS
                                   to return formula_no, formula_vers, recipe_no, recipe_vers
   */
   PROCEDURE OPM_MSDS_Formula_With_IDS
				(p_commit IN VARCHAR2,
				 p_init_msg_list IN VARCHAR2,
				 p_validation_level IN NUMBER,
				 p_api_version IN NUMBER,
				 p_organization_id NUMBER,
                 p_inventory_item_id IN NUMBER,
				 p_session_id IN NUMBER,
				 x_formula_no OUT NOCOPY VARCHAR2,
				 x_formula_vers OUT NOCOPY NUMBER,
				 x_recipe_no OUT NOCOPY VARCHAR2,
				 x_recipe_vers OUT NOCOPY NUMBER,
				 x_return_status OUT NOCOPY VARCHAR2,
				 x_msg_count OUT NOCOPY NUMBER,
				 x_msg_data OUT NOCOPY VARCHAR2);
END GR_EXPLOSIONS;

 

/
