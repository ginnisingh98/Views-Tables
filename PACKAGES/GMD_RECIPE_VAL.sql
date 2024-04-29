--------------------------------------------------------
--  DDL for Package GMD_RECIPE_VAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_RECIPE_VAL" AUTHID CURRENT_USER AS
/* $Header: GMDRVALS.pls 120.0 2005/05/30 02:07:33 appldev noship $ */
/*
/* --  API name: GMD_RECIPE_VAL  */
/*--  Type:  Group (or public???) */
/*--  Function: Validate entities within a recipe */
/*--  Pre-reqs: none */
/*--  Common Parameters for procedures: */
/*--    IN:  p_api_version   IN NUMBER */
/*--         p_init_msg_list IN VARCHAR2  optional default = FND_API.G_FALSE */
/*--         p_commit        IN VARCHAR2  optional default = FND_API.G_FALSE */
/*--         p_validation_level IN NUMBER optional */
/*--                                      default = FND_API.G_VALID_LEVEL_FULL */
/*--         (specific parameters) */
/*--    OUT: x_return_status OUT VARCHAR2(1) */
/*--         x_msg_count     OUT NUMBER */
/*--         x_msg_data      OUT VARCHAR2(2000) */
/*--         x_tbl_qcspecs   OUT t_qcspec_rec_tbl  (columns from qc_spec_mst) */
/*--         x_return_code   OUT NUMBER   number of rows in x_tbl_qcspecs or */
/*--                                      sql error code */
/*--  */
/*--  Version:  1.0  */
/*--  recipe_exists           in: id, no, vers;  out: id  */
/*--  recipe_name             in: name, version, action_code; out: id */
/*--  recipe_for_update       in: recipe_id, last_update_date, asynch or form; */
/*--                              out: lock row */
/*--  recipe_description      in: description; out: success or failure */
/*--  recipe_orgn_code        in: orgn_code, user_id; out: plant_ind */
/*--  process_loss_for_update  in:  recipe_id, orgn_code; out: lock row */
/*--  recipe_cust_exists      in: recipe_id, customer_id, out: success or failure */
 /*    Sukarna Reddy dt 03/14/02. Bug 2099699. */
/*--  CHECK_ROUTING_VALIDITY :p_routing_id , p_recipe_status out: true or false */
/*-- */
/*--  Notes: */
/*--  End of comments ******************************************************* */


  TYPE t_recipe_cust_tbl IS TABLE OF gmd_recipe_customers%ROWTYPE
        INDEX BY BINARY_INTEGER;

  x_recipes_rec          gmd_recipes%ROWTYPE;

  empty_recipecust_tbl   t_recipe_cust_tbl;

  m_pkg_name      CONSTANT VARCHAR2 (30)  := 'GMD_VALIDITY_RULES_PVT';



PROCEDURE recipe_exists
              ( p_api_version      IN NUMBER,
                p_init_msg_list    IN VARCHAR2 := FND_API.G_FALSE,
                p_commit           IN VARCHAR2 := FND_API.G_FALSE,
                p_validation_level IN NUMBER   := FND_API.G_VALID_LEVEL_NONE,
                p_recipe_id        IN NUMBER,
                p_recipe_no        IN VARCHAR2,
                p_recipe_version   IN NUMBER,
                x_return_status    OUT NOCOPY  VARCHAR2,
                x_msg_count        OUT NOCOPY  NUMBER,
                x_msg_data         OUT NOCOPY  VARCHAR2,
                x_return_code      OUT NOCOPY  NUMBER,
                x_recipe_id        OUT NOCOPY  NUMBER);


PROCEDURE recipe_name
              ( p_api_version      IN NUMBER,
                p_init_msg_list    IN VARCHAR2 := FND_API.G_FALSE,
                p_commit           IN VARCHAR2 := FND_API.G_FALSE,
                p_validation_level IN NUMBER   := FND_API.G_VALID_LEVEL_NONE,
                p_recipe_no        IN VARCHAR2,
                p_recipe_version   IN NUMBER,
                p_action_code      IN VARCHAR2  := 'U',
                x_return_status    OUT NOCOPY  VARCHAR2,
                x_msg_count        OUT NOCOPY  NUMBER,
                x_msg_data         OUT NOCOPY  VARCHAR2,
                x_return_code      OUT NOCOPY  NUMBER,
                x_recipe_id        OUT NOCOPY  NUMBER);

PROCEDURE   recipe_for_update
              ( p_api_version      IN NUMBER,
                p_init_msg_list    IN VARCHAR2 := FND_API.G_FALSE,
                p_commit           IN VARCHAR2 := FND_API.G_FALSE,
                p_validation_level IN NUMBER   := FND_API.G_VALID_LEVEL_NONE,
                p_recipe_id        IN NUMBER,
                p_last_update_date IN DATE,
                p_form_or_asynch   IN VARCHAR2 := 'A',
                x_return_status    OUT NOCOPY  VARCHAR2,
                x_msg_count        OUT NOCOPY  NUMBER,
                x_msg_data         OUT NOCOPY  VARCHAR2,
                x_return_code      OUT NOCOPY  NUMBER);


PROCEDURE   recipe_description
              ( p_api_version      IN NUMBER,
                p_init_msg_list    IN VARCHAR2 := FND_API.G_FALSE,
                p_commit           IN VARCHAR2 := FND_API.G_FALSE,
                p_validation_level IN NUMBER   := FND_API.G_VALID_LEVEL_NONE,
                p_recipe_description IN VARCHAR2,
                x_return_status    OUT NOCOPY  VARCHAR2,
                x_msg_count        OUT NOCOPY  NUMBER,
                x_msg_data         OUT NOCOPY  VARCHAR2,
                x_return_code      OUT NOCOPY  NUMBER);


PROCEDURE   recipe_orgn_code
              ( p_api_version      IN NUMBER,
                p_init_msg_list    IN VARCHAR2 := FND_API.G_FALSE,
                p_commit           IN VARCHAR2 := FND_API.G_FALSE,
                p_validation_level IN NUMBER   := FND_API.G_VALID_LEVEL_NONE,
                g_orgn_id          IN NUMBER,
                g_user_id          IN NUMBER,
                p_required_ind     IN VARCHAR2 := 'N',
                x_return_status    OUT NOCOPY  VARCHAR2,
                x_msg_count        OUT NOCOPY  NUMBER,
                x_msg_data         OUT NOCOPY  VARCHAR2,
                x_return_code      OUT NOCOPY  NUMBER,
                x_plant_ind        OUT NOCOPY  NUMBER,
		x_lab_ind          OUT NOCOPY  NUMBER);

PROCEDURE   process_loss_for_update
              ( p_api_version      IN NUMBER,
                p_init_msg_list    IN VARCHAR2 := FND_API.G_FALSE,
                p_commit           IN VARCHAR2 := FND_API.G_FALSE,
                p_validation_level IN NUMBER   := FND_API.G_VALID_LEVEL_NONE,
                p_recipe_id        IN NUMBER,
                p_orgn_id          IN NUMBER,
                p_last_update_date IN DATE,
                p_form_or_asynch   IN VARCHAR2 := 'A',
                x_return_status    OUT NOCOPY  VARCHAR2,
                x_msg_count        OUT NOCOPY  NUMBER,
                x_msg_data         OUT NOCOPY  VARCHAR2,
                x_return_code      OUT NOCOPY  NUMBER);

PROCEDURE recipe_cust_exists
              ( p_api_version      IN NUMBER,
                p_init_msg_list    IN VARCHAR2 := FND_API.G_FALSE,
                p_commit           IN VARCHAR2 := FND_API.G_FALSE,
                p_validation_level IN NUMBER   := FND_API.G_VALID_LEVEL_NONE,
                p_recipe_id        IN NUMBER,
                p_customer_id      IN NUMBER,
                x_return_status    OUT NOCOPY  VARCHAR2,
                x_msg_count        OUT NOCOPY  NUMBER,
                x_msg_data         OUT NOCOPY  VARCHAR2,
                x_return_code      OUT NOCOPY  NUMBER);

FUNCTION check_routing_validity(p_routing_id     IN NUMBER,
                                p_recipe_status  IN VARCHAR2) RETURN BOOLEAN;



  /* Added by Shyam : new procedures for Validity Rules */
  PROCEDURE validate_start_date (P_disp_start_date  DATE,
                                 P_routing_start_date DATE,
                                 x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE validate_end_date (P_end_date  DATE,
                               P_routing_end_date DATE,
                               x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE effective_dates ( P_start_date DATE,
                              P_end_date DATE,
                              x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE std_qty(P_std_qty NUMBER,
                    P_min_qty NUMBER,
                    P_max_qty NUMBER,
                    x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE max_qty(P_min_qty NUMBER,
                    P_max_qty NUMBER,
                    x_return_status OUT NOCOPY VARCHAR2);

  -- this procedure calls gmi stored procedures and copies
  -- min and max in inv uom into block fields
  PROCEDURE calc_inv_qtys (P_inv_item_um VARCHAR2,
                           P_item_um VARCHAR2,
                           P_item_id NUMBER,
                           P_min_qty NUMBER,
                           P_max_qty NUMBER,
                           X_inv_min_qty OUT NOCOPY NUMBER,
                           X_inv_max_qty OUT NOCOPY NUMBER,
                           x_return_status OUT NOCOPY VARCHAR2) ;

  PROCEDURE calculate_process_loss( V_assign 	IN	NUMBER DEFAULT 1
                                   ,P_vr_id   IN  NUMBER
                                   ,X_TPL      OUT NOCOPY NUMBER
                                   ,X_PPL      OUT NOCOPY NUMBER
                                   ,x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE check_for_duplicate(pRecipe_id NUMBER
                               ,pitem_id NUMBER
                               ,pOrgn_id NUMBER DEFAULT NULL
                               ,pRecipe_Use NUMBER
                               ,pPreference NUMBER
                               ,pstd_qty NUMBER
                               ,pmin_qty NUMBER
                               ,pmax_qty NUMBER
                               ,pinv_max_qty NUMBER
                               ,pinv_min_qty NUMBER
                               ,pitem_um VARCHAR2
                               ,pValidity_Rule_Status  VARCHAR2
                               ,pstart_date DATE
                               ,pend_date DATE DEFAULT NULL
                               ,pPlanned_process_loss NUMBER DEFAULT NULL
                               ,x_return_status OUT NOCOPY VARCHAR2
                               );



END GMD_RECIPE_VAL;

 

/
