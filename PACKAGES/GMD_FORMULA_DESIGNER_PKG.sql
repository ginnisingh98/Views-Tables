--------------------------------------------------------
--  DDL for Package GMD_FORMULA_DESIGNER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_FORMULA_DESIGNER_PKG" AUTHID CURRENT_USER AS
/* $Header: GMDFRDDS.pls 120.7.12000000.2 2007/02/09 12:50:55 kmotupal ship $ */
/*==========================================================================================
 |                         Copyright (c) 2002 Oracle Corporation
 |                             Redwood Shores, California, USA
 |                                  All rights reserved
 ===========================================================================================
 |   FILENAME
 |      GMDFRDDB.pls
 |
 |   DESCRIPTION
 |      Package body containing the procedures used by the Formula Designer
 |
 |   NOTES
 |
 |   HISTORY
 |     05-SEP-2002 Eddie Oumerretane   Created.
 |     27-APR-2004 S.Sriram
 |                 Added SET_DEFAULT_STATUS procedure for Default Status Build (Bug# 3408799)
 |     23-JUN-2004 S.Sriram  Bug# 3700829
 |                 Added procedure CHECK_USR_HAS_FSEC_RESP to check if user has formula
 |                 security responsibility (i-e) Product development security manager.
 |     29-Jul-2005 Tdaniel Added organization_id for convergence changes.
 =============================================================================================
*/
G_CREATED_BY        NUMBER := FND_PROFILE.VALUE('USER_ID');
G_LOGIN_ID          NUMBER := FND_PROFILE.VALUE('LOGIN_ID');
G_USER_ORG          VARCHAR2(4);
G_CALCULATABLE_REC  GMD_AUTO_STEP_CALC.CALCULATABLE_REC_TYPE;
G_RECIPE_TBL        GMD_AUTO_STEP_CALC.RECIPE_ID_TBL;
G_CHECK_STEP_MAT    GMD_AUTO_STEP_CALC.CHECK_STEP_MAT_TYPE;
G_SCALE_REC         GMD_COMMON_SCALE.scale_tab;

/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Get_Formula_Mode
 |
 |   DESCRIPTION
 |      Determine whether the user has access to this formula and in which
 |      mode (view or update mode).
 |
 |   INPUT PARAMETERS
 |     p_formula_id    NUMBER
 |
 |   OUTPUT PARAMETERS
 |     x_formula_mode   VARCHAR2
 |     x_create_allowed VARCHAR2
 |     x_return_code    VARCHAR2
 |     x_error_msg      VARCHAR2
 |
 |   HISTORY
 |     05-SEP-2002 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/
PROCEDURE Get_Formula_Mode (p_formula_id               IN         NUMBER,
                            p_organization_id          IN         NUMBER,
                            x_formula_mode             OUT NOCOPY VARCHAR2,
                            x_create_allowed           OUT NOCOPY VARCHAR2,
                            x_return_code              OUT NOCOPY VARCHAR2,
                            x_error_msg                OUT NOCOPY VARCHAR2);
/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Is_Formula_Used_In_Recipes
 |
 |   DESCRIPTION
 |      Determine whether the formula is used in one or more recipes.
 |
 |   INPUT PARAMETERS
 |     p_formula_id          NUMBER
 |
 |   OUTPUT PARAMETERS
 |     x_used_in_recipes    VARCHAR2(1)
 |     x_return_code        VARCHAR2(1)
 |     x_error_msg          VARCHAR2(100)
 |
 |   HISTORY
 |     05-SEP-2002 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Is_Formula_Used_In_Recipes (p_formula_id       IN  NUMBER,
                                        x_used_in_recipes  OUT NOCOPY VARCHAR2,
                                        x_return_code      OUT NOCOPY VARCHAR2,
                                        x_error_msg        OUT NOCOPY VARCHAR2);

/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Update_Formula_Header
 |
 |   DESCRIPTION
 |      Update formula header
 |
 |   INPUT PARAMETERS
 |     p_formula_id            IN  NUMBER,
 |     p_formula_no            IN  VARCHAR2
 |     p_formula_vers          IN  NUMBER,
 |     p_formula_desc          IN  VARCHAR2
 |     p_formula_class         IN  VARCHAR2
 |     p_last_update_date      IN  DATE
 |     p_user_id               IN  NUMBER
 |     p_last_update_date_orig IN  DATE
 |     p_update_release_type   IN  NUMBER
 |     p_auto_product_calc       VARCHAR2
 |
 |   OUTPUT PARAMETERS
 |     x_return_code VARCHAR2(1)
 |     x_error_msg   VARCHAR2(100)
 |
 |   HISTORY
 |     05-SEP-2002 Eddie Oumerretane   Created.
 |     05-FEB-2007 Kapil M. Bug# 5716318. Auto-Product Qty ME
 |                          Added the new column auto_product_calc
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Update_Formula_Header ( p_formula_id            IN  NUMBER,
                                    p_formula_no            IN  VARCHAR2,
                                    p_formula_vers          IN  NUMBER,
                                    p_formula_desc          IN  VARCHAR2,
                                    p_formula_desc2         IN  VARCHAR2,
                                    p_formula_status        IN  VARCHAR2,
                                    p_formula_class         IN  VARCHAR2,
                                    p_owner_organization_id IN  NUMBER,
                                    p_owner_id              IN  NUMBER,
                                    p_formula_type          IN  NUMBER,
                                    p_scale_type            IN  NUMBER,
                                    p_text_code             IN  NUMBER,
                                    p_last_update_date      IN  DATE,
                                    p_user_id               IN  NUMBER,
                                    p_last_update_date_orig IN  DATE,
                                    p_auto_product_calc     IN  VARCHAR2,
                                    x_return_code           OUT NOCOPY VARCHAR2,
                                    x_error_msg             OUT NOCOPY VARCHAR2) ;

/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Insert_Formula_Detail
 |
 |   DESCRIPTION
 |      Create a formula line
 |
 |   INPUT PARAMETERS
 |     p_formula_id              IN  NUMBER
 |     p_formulaline_id          IN  NUMBER
 |     p_line_type               IN  NUMBER
 |     p_line_no                 IN  NUMBER
 |     p_item_id                 IN  NUMBER
 |     p_item_no                 IN  VARCHAR2
 |     p_qty                     IN  NUMBER
 |     p_item_um                 IN  VARCHAR2
 |     p_release_type            IN  NUMBER
 |     p_scrap_factor            IN  NUMBER
 |     p_scale_type              IN  NUMBER
 |     p_cost_alloc              IN  NUMBER
 |     p_phantom_type            IN  NUMBER
 |     p_rework_type             IN  NUMBER
 |     p_text_code               IN  NUMBER
 |     p_tp_formula_id           IN  NUMBER
 |     p_iaformula_id            IN  NUMBER
 |     p_scale_uom               IN  VARCHAR2
 |     p_contribute_step_qty_ind IN  VARCHAR2
 |     p_contribute_yield_ind    IN  VARCHAR2
 |     p_scale_multiple          IN  NUMBER
 |     p_scale_rounding_variance IN  NUMBER
 |     p_rounding_direction      IN  NUMBER
 |     p_by_product_type         IN  VARCHAR2
 |     p_text_code               IN  NUMBER
 |     p_last_update_date        IN  DATE
 |     p_user_id                 IN  NUMBER
 |     p_prod_percent            IN  NUMBER
 |
 |   OUTPUT PARAMETERS
 |     x_return_code VARCHAR2(1)
 |     x_error_msg   VARCHAR2(100)
 |
 |   HISTORY
 |     05-SEP-2002 Eddie Oumerretane   Created.
 |     05-FEB-2007 Kapil M. Bug# 5716318. Auto-Product Qty ME
 |                          Added the new column prod_percent
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Insert_Formula_Detail ( p_formula_id              IN  NUMBER
                                   ,p_formulaline_id          IN  NUMBER
                                   ,p_line_type               IN  NUMBER
                                   ,p_line_no                 IN  NUMBER
                                   ,p_item_id                 IN  NUMBER
                                   ,p_item_no                 IN  VARCHAR2
                                   ,p_revision                IN  VARCHAR2
                                   ,p_qty                     IN  NUMBER
                                   ,p_item_um                 IN  VARCHAR2
                                   ,p_release_type            IN  NUMBER
                                   ,p_scrap_factor            IN  NUMBER
                                   ,p_scale_type              IN  NUMBER
                                   ,p_cost_alloc              IN  NUMBER
                                   ,p_phantom_type            IN  NUMBER
                                   ,p_rework_type             IN  NUMBER
                                   ,p_text_code               IN  NUMBER
                                   ,p_tp_formula_id           IN  NUMBER
                                   ,p_iaformula_id            IN  NUMBER
                                   ,p_scale_uom               IN  VARCHAR2
                                   ,p_contribute_step_qty_ind IN  VARCHAR2
                                   ,p_contribute_yield_ind    IN  VARCHAR2
                                   ,p_scale_multiple          IN  NUMBER
                                   ,p_scale_rounding_variance IN  NUMBER
                                   ,p_rounding_direction      IN  NUMBER
                                   ,p_by_product_type         IN  VARCHAR2
                                   ,p_last_update_date        IN  DATE
                                   ,p_user_id                 IN  NUMBER
                                   ,p_prod_percent            IN NUMBER
                                   ,x_return_code             OUT NOCOPY VARCHAR2
                                   ,x_error_msg               OUT NOCOPY VARCHAR2);

/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Update_Formula_Detail
 |
 |   DESCRIPTION
 |      Update formula detail line
 |
 |   INPUT PARAMETERS
 |     p_formula_id              IN  NUMBER
 |     p_formulaline_id          IN  NUMBER
 |     p_line_type               IN  NUMBER
 |     p_line_no                 IN  NUMBER
 |     p_item_id                 IN  NUMBER
 |     p_item_no                 IN  VARCHAR2
 |     p_qty                     IN  NUMBER
 |     p_item_um                 IN  VARCHAR2
 |     p_release_type            IN  NUMBER
 |     p_scrap_factor            IN  NUMBER
 |     p_scale_type              IN  NUMBER
 |     p_cost_alloc              IN  NUMBER
 |     p_phantom_type            IN  NUMBER
 |     p_rework_type             IN  NUMBER
 |     p_text_code               IN  NUMBER
 |     p_tp_formula_id           IN  NUMBER
 |     p_iaformula_id            IN  NUMBER
 |     p_scale_uom               IN  VARCHAR2
 |     p_contribute_step_qty_ind IN  VARCHAR2
 |     p_contribute_yield_ind    IN  VARCHAR2
 |     p_scale_multiple          IN  NUMBER
 |     p_scale_rounding_variance IN  NUMBER
 |     p_rounding_direction      IN  NUMBER
 |     p_by_product_type         IN  VARCHAR2
 |     p_text_code               IN  NUMBER
 |     p_last_update_date        IN  DATE
 |     p_user_id                 IN  NUMBER
 |     p_text_code               IN  NUMBER
 |     p_last_update_date        IN  DATE
 |     p_user_id                 IN  NUMBER
 |     p_last_update_date_orig   IN  DATE
 |     p_prod_percent            IN  NUMBER
 |
 |   OUTPUT PARAMETERS
 |     x_return_code VARCHAR2(1)
 |     x_error_msg   VARCHAR2(100)
 |
 |   HISTORY
 |     05-SEP-2002 Eddie Oumerretane   Created.
 |     05-FEB-2007 Kapil M. Bug# 5716318. Auto-Product Qty ME
 |                          Added the new column prod_percent
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Update_Formula_Detail ( p_formula_id              IN  NUMBER
                                   ,p_formulaline_id          IN  NUMBER
                                   ,p_line_type               IN  NUMBER
                                   ,p_line_no                 IN  NUMBER
                                   ,p_item_id                 IN  NUMBER
                                   ,p_item_no                 IN  VARCHAR2
                                   ,p_revision                IN  VARCHAR2
                                   ,p_qty                     IN  NUMBER
                                   ,p_item_um                 IN  VARCHAR2
                                   ,p_release_type            IN  NUMBER
                                   ,p_scrap_factor            IN  NUMBER
                                   ,p_scale_type              IN  NUMBER
                                   ,p_cost_alloc              IN  NUMBER
                                   ,p_phantom_type            IN  NUMBER
                                   ,p_rework_type             IN  NUMBER
                                   ,p_text_code               IN  NUMBER
                                   ,p_tp_formula_id           IN  NUMBER
                                   ,p_iaformula_id            IN  NUMBER
                                   ,p_scale_uom               IN  VARCHAR2
                                   ,p_contribute_step_qty_ind IN  VARCHAR2
                                   ,p_contribute_yield_ind    IN  VARCHAR2
                                   ,p_scale_multiple          IN  NUMBER
                                   ,p_scale_rounding_variance IN  NUMBER
                                   ,p_rounding_direction      IN  NUMBER
                                   ,p_by_product_type         IN  VARCHAR2
                                   ,p_last_update_date        IN  DATE
                                   ,p_user_id                 IN  NUMBER
                                   ,p_last_update_date_orig   IN  DATE
                                   ,p_prod_percent            IN  NUMBER
                                   ,x_return_code             OUT NOCOPY VARCHAR2
                                   ,x_error_msg               OUT NOCOPY VARCHAR2);

/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Create_formula_Header
 |
 |   DESCRIPTION
 |      Create formula header
 |
 |   INPUT PARAMETERS
 |     p_user_id               IN  NUMBER
 |
 |   OUTPUT PARAMETERS
 |     x_formula_id  NUMBER
 |     x_return_code VARCHAR2(1)
 |     x_error_msg   VARCHAR2(100)
 |
 |   HISTORY
 |     05-SEP-2002 Eddie Oumerretane   Created.
 |     05-FEB-2007 Kapil M. Bug# 5716318. Auto-Product Qty ME
 |                          Added the new column auto_product_calc
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Create_Formula_Header ( p_formula_no            IN  VARCHAR2,
                                    p_formula_vers          IN  NUMBER,
                                    p_formula_desc          IN  VARCHAR2,
                                    p_formula_desc2         IN  VARCHAR2,
                                    p_formula_class         IN  VARCHAR2,
                                    p_owner_organization_id IN  NUMBER,
                                    p_owner_id              IN  NUMBER,
                                    p_formula_type          IN  NUMBER,
                                    p_scale_type            IN  NUMBER,
                                    p_text_code             IN  NUMBER,
                                    p_last_update_date      IN  DATE,
                                    p_auto_product_calc     IN  VARCHAR2,
                                    x_formula_id            OUT NOCOPY NUMBER,
                                    x_return_code           OUT NOCOPY VARCHAR2,
                                    x_error_msg             OUT NOCOPY VARCHAR2);

/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Delete_Formula_Detail
 |
 |   DESCRIPTION
 |      Delete a formula line
 |
 |   INPUT PARAMETERS
 |     p_formula_id         NUMBER
 |     p_formulaline_id     NUMBER
 |     p_line_type          NUMBER
 |     p_last_update_date   DATE
 |
 |   OUTPUT PARAMETERS
 |     x_return_code VARCHAR2(1)
 |     x_error_msg   VARCHAR2(100)
 |
 |   HISTORY
 |     05-SEP-2002 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Delete_Formula_Detail(p_formula_id         IN  NUMBER,
                                  p_formulaline_id     IN  NUMBER,
                                  p_line_type          IN  NUMBER,
                                  p_last_update_date   IN  DATE,
                                  x_return_code        OUT NOCOPY VARCHAR2,
                                  x_error_msg          OUT NOCOPY VARCHAR2);


/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Delete_Formula_Detail_With_No_Val
 |
 |   DESCRIPTION
 |      Delete a formula line without performing any validations
 |
 |   INPUT PARAMETERS
 |     p_formula_id         NUMBER
 |     p_formulaline_id     NUMBER
 |     p_line_type          NUMBER
 |     p_last_update_date   DATE
 |
 |   OUTPUT PARAMETERS
 |     x_return_code VARCHAR2(1)
 |     x_error_msg   VARCHAR2(100)
 |
 |   HISTORY
 |     26-SEP-2002 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Del_Formula_Detail_With_No_Val(p_formula_id       IN  NUMBER,
                                           p_formulaline_id   IN  NUMBER,
                                           p_line_type        IN  NUMBER,
                                           p_last_update_date IN  DATE,
                                           x_return_code      OUT NOCOPY VARCHAR2,
                                           x_error_msg        OUT NOCOPY VARCHAR2);

/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Validate_Cost_Allocation
 |
 |   DESCRIPTION
 |      Make sure cost allocation is <= 1
 |
 |   INPUT PARAMETERS
 |     p_formula_id         NUMBER
 |     p_formulaline_id     NUMBER
 |     p_cost_alloc         NUMBER
 |
 |   OUTPUT PARAMETERS
 |     x_return_code VARCHAR2(1)
 |     x_error_msg   VARCHAR2(100)
 |
 |   HISTORY
 |     09-SEP-2002 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Validate_Cost_Allocation(p_formula_id         IN  NUMBER,
                                     p_formulaline_id     IN  NUMBER,
                                     p_cost_alloc         IN  NUMBER,
                                     x_return_code        OUT NOCOPY VARCHAR2,
                                     x_error_msg          OUT NOCOPY VARCHAR2);

/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Validate_Item_Uom
 |
 |   DESCRIPTION
 |      Make sure uom is convertible to item inventory uom
 |
 |   INPUT PARAMETERS
 |     p_item_id            NUMBER
 |     p_item_um            VARCHAR
 |
 |   OUTPUT PARAMETERS
 |     x_return_code VARCHAR2(1)
 |     x_error_msg   VARCHAR2(100)
 |
 |   HISTORY
 |     09-SEP-2002 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Validate_Item_Uom (p_item_id         IN  NUMBER,
                               p_item_uom        IN  VARCHAR2,
                               x_return_code     OUT NOCOPY VARCHAR2,
                               x_error_msg       OUT NOCOPY VARCHAR2);


/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Check_Item_Used_In_Recipe
 |
 |   DESCRIPTION
 |      Check whether the given item is used in recipes
 |
 |   INPUT PARAMETERS
 |     p_formulaline_id     NUMBER
 |
 |   OUTPUT PARAMETERS
 |     x_return_code     VARCHAR2
 |     x_warning_message VARCHAR2
 |     x_error_msg       VARCHAR2
 |
 |   HISTORY
 |     20-SEP-2002 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Check_Item_Used_In_Recipe( p_formulaline_id   IN  NUMBER,
                                       x_nb_recipes       OUT NOCOPY   NUMBER,
                                       x_warning_message  OUT NOCOPY   VARCHAR2,
                                       x_return_code      OUT NOCOPY   VARCHAR2,
                                       x_error_msg        OUT NOCOPY   VARCHAR2);
/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Cascade_Update_Recipes
 |
 |   DESCRIPTION
 |      Update all recipes impacted by the deletion of an item in the formula
 |      or a step in the routing. Check_Item_Used_In_Recipe must be called
 |      prior to invoking this procedure.
 |
 |   INPUT PARAMETERS
 |
 |   OUTPUT PARAMETERS
 |     x_return_code     VARCHAR2
 |     x_warning_message VARCHAR2
 |     x_error_msg       VARCHAR2
 |
 |   HISTORY
 |     20-SEP-2002 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Cascade_Update_Recipes(x_return_code  OUT NOCOPY VARCHAR2,
                                   x_error_msg    OUT NOCOPY   VARCHAR2);

/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Calculate_Theoretical_Yield
 |
 |   DESCRIPTION
 |      Calculate theoretical yield.
 |
 |   INPUT PARAMETERS
 |     p_formula_id      NUMBER
 |
 |   OUTPUT PARAMETERS
 |     x_return_code     VARCHAR2
 |     x_error_msg       VARCHAR2
 |
 |   HISTORY
 |     24-OCT-2002 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Calculate_Theoretical_yield(p_formula_id   IN  NUMBER,
                                        p_scale_factor IN  NUMBER,
                                        x_return_code  OUT NOCOPY VARCHAR2,
                                        x_error_msg    OUT NOCOPY VARCHAR2);

/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Scale_Formula
 |
 |   DESCRIPTION
 |      Scale the formula.
 |
 |   INPUT PARAMETERS
 |     p_formula_id      NUMBER
 |     p_scale_factor    NUMBER
 |     p_primaries       VARCHAR2
 |
 |   OUTPUT PARAMETERS
 |     x_return_code     VARCHAR2
 |     x_error_msg       VARCHAR2
 |
 |   HISTORY
 |     29-OCT-2002 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Scale_Formula(p_formula_id   IN  NUMBER,
                          p_scale_factor IN  NUMBER,
                          p_primaries    IN  VARCHAR2,
                          x_return_code  OUT NOCOPY VARCHAR2,
                          x_error_msg    OUT NOCOPY VARCHAR2);

/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Validate_Formula_Details
 |
 |   DESCRIPTION
 |      Validate formula details
 |
 |   INPUT PARAMETERS
 |     p_formula_id     NUMBER
 |
 |   OUTPUT PARAMETERS
 |     x_return_code    VARCHAR2(1)
 |     x_error_msg      VARCHAR2(100)
 |
 |   HISTORY
 |     18-NOV-2002 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Validate_Formula_Details ( p_formula_id    IN  VARCHAR2,
                                       x_return_code   OUT NOCOPY VARCHAR2,
                                       x_error_msg     OUT NOCOPY VARCHAR2);


/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Set_Save_Point
 |
 |   DESCRIPTION
 |      Establish a SAVEPOINT. This is used to provide the ability to
 |      rollback a logical transaction performed by the Designer.
 |
 |   INPUT PARAMETERS
 |     None
 |
 |   OUTPUT PARAMETERS
 |     x_return_code   VARCHAR2
 |     x_error_msg     VARCHAR2
 |
 |   HISTORY
 |     03-DEC-2002 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Set_Save_Point ( x_return_code   OUT NOCOPY VARCHAR2,
                             x_error_msg     OUT NOCOPY VARCHAR2);

/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Rollback_Save_Point
 |
 |   DESCRIPTION
 |      Rollback up to the save point established after a call to
 |      Set_Save_Point.
 |
 |   INPUT PARAMETERS
 |     None
 |
 |   OUTPUT PARAMETERS
 |     x_return_code   VARCHAR2
 |     x_error_msg     VARCHAR2
 |
 |   HISTORY
 |     03-DEC-2002 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Rollback_Save_Point ( x_return_code   OUT NOCOPY VARCHAR2,
                                  x_error_msg     OUT NOCOPY VARCHAR2);




/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      CHECK_USR_HAS_FSEC_RESP
 |
 |   DESCRIPTION
 |      Procedure to check if user has formula security responsibility.
 |      (i-e) Product Development Security manager.
 |
 |   INPUT PARAMETERS
 |        None
 |
 |   OUTPUT PARAMETERS
 |      x_return_code   VARCHAR2
 |      x_error_msg     VARCHAR2
 |
 |   HISTORY
 |      23-JUN-2004  S.Sriram  Created for Bug# 3700829
 |
 +=============================================================================
 Api end of comments
*/
 PROCEDURE CHECK_USR_HAS_FSEC_RESP (x_return_code       OUT NOCOPY VARCHAR2,
                                   x_error_msg         OUT NOCOPY VARCHAR2);


 /* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Check_fm_orgn_access
 |
 |   DESCRIPTION
 |      Procedure to check if user with appropriate responsibility
 |      has accesss to the Formula based on its owning organization
 |
 |   INPUT PARAMETERS
 |      p_formula_id      NUMBER
 |
 |   OUTPUT PARAMETERS
 |      x_return_code   VARCHAR2
 |
 |   HISTORY
 |      23-Aug-2005  Shyam  Initial implementation
 |
 +=============================================================================
 Api end of comments
 */
 PROCEDURE Check_fm_orgn_access(p_formula_id         IN  NUMBER,
                                x_return_code        OUT NOCOPY VARCHAR2);


/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Validate_Item_Revision
 |
 |   DESCRIPTION
 |      Make sure the item revision is valid
 |
 |   INPUT PARAMETERS
 |     p_organization_id    NUMBER
 |     p_item_id            NUMBER
 |     p_item_revision      VARCHAR
 |
 |   OUTPUT PARAMETERS
 |     x_return_code VARCHAR2(1)
 |     x_error_msg   VARCHAR2(100)
 |
 |   HISTORY
 |     01-JAN-2006 Thomas Daniel   Created.
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Validate_Item_Revision (p_organization_id IN NUMBER,
                               p_item_id         IN  NUMBER,
                               p_item_revision   IN  VARCHAR2,
                               x_return_code     OUT NOCOPY VARCHAR2,
                               x_error_msg       OUT NOCOPY VARCHAR2);

/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      check_item_exists
 |
 |   DESCRIPTION
 |      Make sure the items in the formula exists under the organization
 |
 |   INPUT PARAMETERS
 |     p_formula_id         NUMBER
 |     p_organization_id    NUMBER
 |
 |   OUTPUT PARAMETERS
 |     x_return_status VARCHAR2(1)
 |
 |   HISTORY
 |     27-JAN-2006 Thomas Daniel   Created.
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Check_Item_Exists (p_formula_id 		IN NUMBER,
                               p_organization_id 	IN NUMBER,
                               x_return_status          OUT NOCOPY VARCHAR2,
                               x_error_msg              OUT NOCOPY VARCHAR2);

 /* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      CHECK_FORMULA_ITEM_ACCESS
 |
 |   DESCRIPTION
 |      Checks If the Item is accessible to the formula
 |
 |   INPUT PARAMETERS
 |     p_formula_id         NUMBER
 |     p_organization_id    NUMBER
 |     prevision            VARCHAR2
 |
 |   OUTPUT PARAMETERS
 |     x_return_status VARCHAR2(1)
 |     x_error_msg     VARCHAR2
 |
 |   HISTORY
 |     04-AUG-2006    KapilM   Created.
 |
 +=============================================================================
 Api end of comments
 */
PROCEDURE CHECK_FORMULA_ITEM_ACCESS(pFormula_id         IN NUMBER,
                                    pInventory_Item_ID  IN NUMBER,
                                    x_return_status     OUT NOCOPY VARCHAR2,
                                    x_error_msg         OUT NOCOPY VARCHAR2 ,
				    pRevision           IN VARCHAR2 DEFAULT NULL);

  -- Kapil ME Auto-prod
  -- Added the following procedure for Auto-Product Qty Calculation ME
/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      CHECK_AUTO_PRODUCT
 |
 |   DESCRIPTION
 |      Checks whether Automatic Product QTy Calculation parameter is set at Organization level.
 |
 |   INPUT PARAMETERS
 |     pOrgn_id    NUMBER
 |
 |   OUTPUT PARAMETERS
 |    pAuto_calc       VARCHAR2
 |    x_return_status  VARCHAR2
 |    x_error_msg      VARCHAR2
 |
 |   HISTORY
 |     14-JUN-2006 Kapil M         Bug# 5716318 Created.
 |
 +=============================================================================
 Api end of comments
*/

PROCEDURE CHECK_AUTO_PRODUCT( pOrgn_id IN NUMBER,
                              pAuto_calc OUT NOCOPY VARCHAR2,
                              x_return_status     OUT NOCOPY VARCHAR2,
                              x_error_msg         OUT NOCOPY VARCHAR2);

/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      CALCULATE_TOTAL_PRODUCT_QTY
 |
 |   DESCRIPTION
 |      Procedure to calculate Product Qty autmatically.
 |
 |   INPUT PARAMETERS
 |     pFormula_id    NUMBER
 |
 |   OUTPUT PARAMETERS
 |    x_msg_data       VARCHAR2
 |    x_return_status  VARCHAR2
 |    x_msg_count      NUMBER
 |
 |   HISTORY
 |     14-JUN-2006 Kapil M         Bug# 5716318 Created.
 |
 +=============================================================================
 Api end of comments
*/

PROCEDURE CALCULATE_TOTAL_PRODUCT_QTY(  pFormula_id IN NUMBER,
                                        x_return_status     OUT NOCOPY VARCHAR2,
                                        x_msg_count         OUT NOCOPY NUMBER,
                                        x_msg_data          OUT NOCOPY VARCHAR2);
  -- Kapil ME Auto-prod
END GMD_FORMULA_DESIGNER_PKG;

 

/
