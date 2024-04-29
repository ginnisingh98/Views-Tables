--------------------------------------------------------
--  DDL for Package GMD_RECIPE_DESIGNER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_RECIPE_DESIGNER_PKG" AUTHID CURRENT_USER AS
/* $Header: GMDRDMDS.pls 120.8.12010000.1 2008/07/24 09:59:09 appldev ship $ */
/*============================================================================
 |                         Copyright (c) 2001 Oracle Corporation
 |                             Redwood Shores, California, USA
 |                                  All rights reserved
 =============================================================================
 |   FILENAME
 |      GMDRDMDS.pls
 |
 |   DESCRIPTION
 |      Package specification containing the procedures used by the Recipe Designer
 |
 |
 |   NOTES
 |
 |   HISTORY
 |     03-JUL-2001 Eddie Oumerretane   Created.
 |     27-APR-2004 S.Sriram  Bug# 3408799
 |                 Added SET_DEFAULT_STATUS procedure for Default Status Build
 |     13-OCT-2004 Sriram.S  Recipe Security Bug# 3948203
 |                 Added a proc. to which checks if user has recipe orgn. access.
 =============================================================================
*/

  TYPE RoutingStepIdType IS TABLE OF fm_rout_dtl.ROUTINGSTEP_ID%TYPE;
  TYPE RoutingStepNoType IS TABLE OF fm_rout_dtl.ROUTINGSTEP_NO%TYPE;

  G_ROUTINGSTEP_ID RoutingStepIdType;
  G_ROUTINGSTEP_NO RoutingStepNoType;

/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Create_Text_Row
 |
 |   DESCRIPTION
 |      Create a row in FM_TEXT_TBL
 |
 |   INPUT PARAMETERS
 |     p_text_code          NUMBER
 |     p_lang_code          VARCHAR2
 |     p_text               VARCHAR2
 |     p_line_no            NUMBER
 |     p_paragraph_code     VARCHAR2
 |     p_sub_paracode       NUMBER
 |     p_table_lnk          VARCHAR2
 |     p_user_id            NUMBER
 |
 |   OUTPUT PARAMETERS
 |     x_return_code VARCHAR2(1)
 |     x_error_msg   VARCHAR2(100)
 |
 |   HISTORY
 |     03-JUL-2001 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/

  PROCEDURE Create_Text_Row ( p_text_code          IN    NUMBER,
                              p_lang_code          IN    VARCHAR2,
                              p_text               IN    VARCHAR2,
                              p_line_no            IN    NUMBER,
                              p_paragraph_code     IN    VARCHAR2,
                              p_sub_paracode       IN    NUMBER,
                              p_table_lnk          IN    VARCHAR2,
                              p_user_id            IN    NUMBER,
                              x_row_id             OUT NOCOPY  VARCHAR2,
                              x_return_code        OUT NOCOPY  VARCHAR2,
                              x_error_msg          OUT NOCOPY  VARCHAR2);



/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Update_Text_Row
 |
 |   DESCRIPTION
 |      Update a row in FM_TEXT_TBL
 |
 |   INPUT PARAMETERS
 |     p_text_code          NUMBER
 |     p_lang_code          VARCHAR2
 |     p_text               VARCHAR2
 |     p_line_no            NUMBER
 |     p_paragraph_code     VARCHAR2
 |     p_sub_paracode       NUMBER
 |     p_table_lnk          VARCHAR2
 |     p_user_id            NUMBER
 |
 |   OUTPUT PARAMETERS
 |     x_return_code VARCHAR2(1)
 |     x_error_msg   VARCHAR2(100)
 |
 |   HISTORY
 |     13-JUL-2001 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/


  PROCEDURE Update_Text_Row ( p_text_code          IN    NUMBER,
                              p_lang_code          IN    VARCHAR2,
                              p_text               IN    VARCHAR2,
                              p_line_no            IN    NUMBER,
                              p_paragraph_code     IN    VARCHAR2,
                              p_sub_paracode       IN    NUMBER,
                              p_user_id            IN    NUMBER,
                              p_row_id             IN    VARCHAR2,
                              x_return_code        OUT NOCOPY  VARCHAR2,
                              x_error_msg          OUT NOCOPY  VARCHAR2);


/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Delete_Text_Row
 |
 |   DESCRIPTION
 |      Delete a row in FM_TEXT_TBL
 |
 |   INPUT PARAMETERS
 |     p_text_code          NUMBER
 |     p_lang_code          VARCHAR2
 |     p_paragraph_code     VARCHAR2
 |     p_sub_paracode       NUMBER
 |     p_line_no            NUMBER
 |     p_row_id             VARCHAR2
 |
 |   OUTPUT PARAMETERS
 |     x_return_code VARCHAR2(1)
 |     x_error_msg   VARCHAR2(100)
 |
 |   HISTORY
 |     13-JUL-2001 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/

  PROCEDURE Delete_Text_Row ( p_text_code          IN    NUMBER,
                              p_lang_code          IN    VARCHAR2,
                              p_paragraph_code     IN    VARCHAR2,
                              p_sub_paracode       IN    NUMBER,
                              p_line_no            IN    NUMBER,
                              p_row_id             IN    VARCHAR2,
                              x_return_code        OUT NOCOPY  VARCHAR2,
                              x_error_msg          OUT NOCOPY  VARCHAR2);


/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Update_Recipe_Routing_step_Row
 |
 |   DESCRIPTION
 |      Update a row in GMD_RECIPE_ROUTING_STEPS
 |
 |   INPUT PARAMETERS
 |     p_recipe_id                 NUMBER
 |     p_routingstep_id            NUMBER
 |     p_text_code                 NUMBER
 |     p_last_update_date          DATE
 |     p_last_update_date_origin   DATE
 |     p_user_id                   NUMBER
 |     p_step_qty                  NUMBER
 |     p_mass_qty                  NUMBER
 |     p_vol_qty                   NUMBER
 |     p_mass_uom                  VARCHAR2
 |     p_vol_uom                   VARCHAR2
 |
 |   OUTPUT PARAMETERS
 |     x_return_code VARCHAR2(1)
 |     x_error_msg   VARCHAR2(100)
 |
 |   HISTORY
 |     03-JUL-2001 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/

  PROCEDURE Update_Recipe_Routing_Step_Row ( p_recipe_id                 IN    NUMBER,
                                             p_routingstep_id            IN    NUMBER,
                                             p_text_code                 IN    NUMBER,
                                             p_last_update_date          IN    DATE,
                                             p_last_update_date_origin   IN    DATE,
                                             p_user_id                   IN    NUMBER,
                                             p_step_qty                  IN    NUMBER,
                                             p_mass_qty                  IN    NUMBER,
                                             p_vol_qty                   IN    NUMBER,
                                             p_mass_uom                  IN    VARCHAR2,
                                             p_vol_uom                   IN    VARCHAR2,
                                             x_return_code               OUT NOCOPY  VARCHAR2,
                                             x_error_msg          OUT NOCOPY  VARCHAR2);

/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Create_Recipe_Routing_step_Row
 |
 |   DESCRIPTION
 |      Create a row in GMD_RECIPE_ROUTING_STEPS
 |
 |   INPUT PARAMETERS
 |     p_recipe_id                 NUMBER
 |     p_routingstep_id            NUMBER
 |     p_text_code                 NUMBER
 |     p_last_update_date          DATE
 |     p_user_id                   NUMBER
 |     p_step_qty                  NUMBER
 |     p_mass_qty                  NUMBER
 |     p_vol_qty                   NUMBER
 |     p_mass_uom                  VARCHAR2
 |     p_vol_uom                   VARCHAR2
 |
 |   OUTPUT PARAMETERS
 |     x_return_code VARCHAR2(1)
 |     x_error_msg   VARCHAR2(100)
 |
 |   HISTORY
 |     03-JUL-2001 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/

  PROCEDURE Create_Recipe_Routing_Step_Row ( p_recipe_id                 IN    NUMBER,
                                             p_routingstep_id            IN    NUMBER,
                                             p_text_code                 IN    NUMBER,
                                             p_last_update_date          IN    DATE,
                                             p_user_id                   IN    NUMBER,
                                             p_step_qty                  IN    NUMBER,
                                             p_mass_qty                  IN    NUMBER,
                                             p_vol_qty                   IN    NUMBER,
                                             p_mass_uom                  IN    VARCHAR2,
                                             p_vol_uom                   IN    VARCHAR2,
                                             x_return_code               OUT NOCOPY  VARCHAR2,
                                             x_error_msg          OUT NOCOPY  VARCHAR2);

/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Create_Step_Material_Link
 |
 |   DESCRIPTION
 |      Create a row in GMD_RECIPE_STEP_MATERIALS
 |
 |   INPUT PARAMETERS
 |     p_recipe_id          NUMBER
 |     p_formulaline_id     NUMBER
 |     p_routingstep_id     NUMBER
 |     p_text_code          NUMBER
 |     p_user_id            NUMBER
 |     p_last_update_date   DATE
 |
 |   OUTPUT PARAMETERS
 |     x_return_code VARCHAR2(1)
 |     x_error_msg   VARCHAR2(100)
 |
 |   HISTORY
 |     04-JUL-2001 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/

  PROCEDURE Create_Step_Material_Link ( p_recipe_id          IN    NUMBER,
                                        p_formulaline_id     IN    NUMBER,
                                        p_routingstep_id     IN    NUMBER,
                                        p_text_code          IN    NUMBER,
                                        p_user_id            IN    NUMBER,
                                        p_last_update_date   IN    DATE,
                                        x_return_code        OUT NOCOPY  VARCHAR2,
                                        x_error_msg          OUT NOCOPY  VARCHAR2);

/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Delete_Step_Material_Link
 |
 |   DESCRIPTION
 |      Delete a row in GMD_RECIPE_STEP_MATERIALS
 |
 |   INPUT PARAMETERS
 |     p_recipe_id                 NUMBER
 |     p_formulaline_id            NUMBER
 |     p_routingstep_id            NUMBER
 |     p_last_update_date_origin   DATE
 |     p_user_id                   NUMBER
 |
 |   OUTPUT PARAMETERS
 |     x_return_code VARCHAR2(1)
 |     x_error_msg   VARCHAR2(100)
 |
 |   HISTORY
 |     04-JUL-2001 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/

  PROCEDURE Delete_Step_Material_Link ( p_recipe_id                   IN    NUMBER,
                                        p_formulaline_id              IN    NUMBER,
                                        p_routingstep_id              IN    NUMBER,
                                        p_last_update_date_origin     IN    DATE,
                                        p_user_id                     IN    NUMBER,
                                        x_return_code                 OUT NOCOPY  VARCHAR2,
                                        x_error_msg                   OUT NOCOPY  VARCHAR2);

/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Update_Step_Material_Link
 |
 |   DESCRIPTION
 |      Update a row in GMD_RECIPE_STEP_MATERIALS
 |
 |   INPUT PARAMETERS
 |     p_recipe_id                 NUMBER
 |     p_formulaline_id            NUMBER
 |     p_routingstep_id            NUMBER
 |     p_text_code                 NUMBER
 |     p_last_update_date          DATE
 |     p_last_update_date_origin   DATE
 |     p_user_id                   NUMBER
 |
 |   OUTPUT PARAMETERS
 |     x_return_code VARCHAR2(1)
 |     x_error_msg   VARCHAR2(100)
 |
 |   HISTORY
 |     04-JUL-2001 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/

  PROCEDURE Update_Step_Material_Link ( p_recipe_id                 IN    NUMBER,
                                        p_formulaline_id            IN    NUMBER,
                                        p_routingstep_id            IN    NUMBER,
                                        p_text_code                 IN    NUMBER,
                                        p_last_update_date          IN    DATE,
                                        p_last_update_date_origin   IN    DATE,
                                        p_user_id                   IN    NUMBER,
                                        x_return_code               OUT NOCOPY  VARCHAR2,
                                        x_error_msg                 OUT NOCOPY  VARCHAR2);


/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Calculate_Step_Quantities
 |
 |   DESCRIPTION
 |      Calculate step quantities
 |
 |   INPUT PARAMETERS
 |     p_recipe_id                 NUMBER
 |
 |   OUTPUT PARAMETERS
 |     x_quantities  VARCHAR2
 |     x_return_code VARCHAR2
 |     x_error_msg   VARCHAR2
 |
 |   HISTORY
 |     09-JUL-2001 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/

  PROCEDURE Calculate_Step_Quantities ( p_recipe_id                 IN    NUMBER,
                                        p_user_id                   IN    NUMBER,
                                        x_quantities                OUT NOCOPY  VARCHAR2,
                                        x_return_code               OUT NOCOPY  VARCHAR2,
                                        x_error_msg                 OUT NOCOPY  VARCHAR2);


/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Calculate_Step_Charges
 |
 |   DESCRIPTION
 |      Calculate Charges for the given operation step
 |
 |   INPUT PARAMETERS
 |     p_recipe_id                 NUMBER
 |     p_routiingstep_id           NUMBER
 |     p_step_qty                  NUMBER
 |     p_step_um                   VARCHAR2
 |
 |   OUTPUT PARAMETERS
 |     x_charges_info VARCHAR2
 |     x_return_code  VARCHAR2
 |     x_error_msg    VARCHAR2
 |
 |   HISTORY
 |     29-AUG-2001 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/

  PROCEDURE Calculate_Step_Charges ( p_recipe_id       IN  NUMBER,
                                     p_routingstep_id  IN  NUMBER,
                                     p_step_qty        IN  NUMBER,
                                     p_step_um         IN  VARCHAR2,
                                     x_charges_info    OUT NOCOPY VARCHAR2,
                                     x_return_code     OUT NOCOPY VARCHAR2,
                                     x_error_msg       OUT NOCOPY VARCHAR2);
/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Calculate_Charges
 |
 |   DESCRIPTION
 |      Calculate Charges
 |
 |   INPUT PARAMETERS
 |     p_recipe_id                 NUMBER
 |
 |   OUTPUT PARAMETERS
 |     x_charges_info VARCHAR2
 |     x_return_code  VARCHAR2
 |     x_error_msg    VARCHAR2
 |
 |   HISTORY
 |     28-AUG-2001 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/

  PROCEDURE Calculate_Charges ( p_recipe_id                 IN    NUMBER,
                                x_charges_info              OUT NOCOPY  VARCHAR2,
                                x_return_code               OUT NOCOPY  VARCHAR2,
                                x_error_msg                 OUT NOCOPY  VARCHAR2);

/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Get_Recipe_Mode
 |
 |   DESCRIPTION
 |      Determine whether this recipe is in update or query mode
 |
 |   INPUT PARAMETERS
 |     p_recipe_id                 NUMBER
 |
 |   OUTPUT PARAMETERS
 |     x_recipe_mode  VARCHAR2
 |     x_return_code  VARCHAR2
 |     x_error_msg    VARCHAR2
 |
 |   HISTORY
 |     15-OCT-2001 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/

  PROCEDURE Get_Recipe_Mode ( p_recipe_id                 IN    NUMBER,
                              x_recipe_mode               OUT NOCOPY  VARCHAR2,
                              x_return_code               OUT NOCOPY  VARCHAR2,
                              x_error_msg                 OUT NOCOPY  VARCHAR2);

/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Update_Step_Quantities
 |
 |   DESCRIPTION
 |      Update step quantities s table
 |
 |   INPUT PARAMETERS
 |     p_recipe_id                 NUMBER
 |     p_routing_id                NUMBER
 |     p_user_id                   NUMBER
 |     p_text_code                 NUMBER
 |     p_last_update_date          DATE
 |
 |   OUTPUT PARAMETERS
 |     x_return_code VARCHAR2
 |     x_error_msg   VARCHAR2
 |
 |   HISTORY
 |     10-JUL-2001 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/
/*
  PROCEDURE Update_Step_Quantities ( p_recipe_id                 IN    NUMBER,
                                     p_routing_id                IN    NUMBER,
                                     p_user_id                   IN    NUMBER,
                                     p_last_update_date          IN    DATE,
                                     x_return_code               OUT NOCOPY  VARCHAR2,
                                     x_error_msg                 OUT NOCOPY  VARCHAR2);
*/


/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Delete_Recipe_Step_Quantities
 |
 |   DESCRIPTION
 |      Delete all rows in GMD_RECIPE_ROUTING_STEPS
 |
 |   INPUT PARAMETERS
 |     p_recipe_id          NUMBER
 |
 |   OUTPUT PARAMETERS
 |     x_return_code VARCHAR2(1)
 |     x_error_msg   VARCHAR2(100)
 |
 |   HISTORY
 |     31-OCT-2001 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/

  PROCEDURE Delete_Recipe_Step_Quantities ( p_recipe_id          IN    NUMBER,
                                            x_return_code        OUT NOCOPY  VARCHAR2,
                                            x_error_msg          OUT NOCOPY  VARCHAR2);


/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Get_Routing_Step_Quantities
 |
 |   DESCRIPTION
 |      Get step quantities from the routing of the given recipe
 |
 |   INPUT PARAMETERS
 |     p_recipe_id                 NUMBER
 |
 |   OUTPUT PARAMETERS
 |     x_quantities  VARCHAR2
 |     x_return_code VARCHAR2
 |     x_error_msg   VARCHAR2
 |
 |   HISTORY
 |     30-OCT-2001 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/

  PROCEDURE Get_Routing_Step_Quantities ( p_recipe_id                 IN    NUMBER,
                                          x_quantities                OUT NOCOPY  VARCHAR2,
                                          x_return_code               OUT NOCOPY  VARCHAR2,
                                          x_error_msg                 OUT NOCOPY  VARCHAR2);


/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Is_Recipe_Used_In_Batches
 |
 |   DESCRIPTION
 |      Determine whether the recipe is used in open batches.
 |
 |   INPUT PARAMETERS
 |     p_recipe_id          NUMBER
 |
 |   OUTPUT PARAMETERS
 |     x_used_in_batches    VARCHAR2(1)
 |     x_return_code        VARCHAR2(1)
 |     x_error_msg          VARCHAR2(100)
 |
 |   HISTORY
 |     05-NOV-2001 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/

  PROCEDURE Is_Recipe_Used_In_Batches ( p_recipe_id       IN  NUMBER,
                                        x_used_in_batches OUT NOCOPY  VARCHAR2,
                                        x_return_code     OUT NOCOPY  VARCHAR2,
                                        x_error_msg       OUT NOCOPY  VARCHAR2);



/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Update_Recipe_Header
 |
 |   DESCRIPTION
 |      Update a row in GMD_RECIPES
 |
 |   INPUT PARAMETERS
 |      p_recipe_id                 IN    NUMBER
 |      p_recipe_description        IN    VARCHAR2
 |      p_recipe_no                 IN    VARCHAR2
 |      p_recipe_version            IN    NUMBER
 |      p_recipe_status             IN    VARCHAR2
 |      p_delete_mark               IN    NUMBER
 |      p_formula_id                IN    NUMBER
 |      p_routing_id                IN    NUMBER
 |      p_planned_process_loss      IN    NUMBER
 |      p_text_code                 IN    NUMBER
 |      p_owner_id                  IN    NUMBER
 |      p_calculate_step_qty        IN    NUMBER
 |      p_user_id                   IN    NUMBER
 |      p_last_update_date          IN    DATE
 |      p_last_update_date_origin   IN    DATE
 |      p_update_number_version     IN    VARCHAR2
 |
 |   OUTPUT PARAMETERS
 |     x_return_code VARCHAR2(1)
 |     x_error_msg   VARCHAR2(100)
 |
 |   HISTORY
 |     05-MAR-2002 Eddie Oumerretane   Created.
 |     19-SEP-2002 Eddie Oumerretane   Modified interface and implemented call
 |                 to the Update_Recipe_Header API.
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Update_Recipe_Header ( p_recipe_id                 IN    NUMBER,
                                   p_recipe_description        IN    VARCHAR2,
                                   p_recipe_no                 IN    VARCHAR2,
                                   p_recipe_version            IN    NUMBER,
                                   p_owner_organization_id     IN    NUMBER,
                                   p_creation_organization_id  IN    NUMBER,
                                   p_recipe_status             IN    VARCHAR2,
                                   p_delete_mark               IN    NUMBER,
                                   p_formula_id                IN    NUMBER,
                                   p_routing_id                IN    NUMBER,
                                   p_planned_process_loss      IN    NUMBER,
                                   p_text_code                 IN    NUMBER,
                                   p_owner_id                  IN    NUMBER,
                                   p_calculate_step_qty        IN    NUMBER,
                                   p_user_id                   IN    NUMBER,
                                   p_last_update_date          IN    DATE,
                                   p_last_update_date_origin   IN    DATE,
                                   p_update_number_version     IN    VARCHAR2,
                                   x_return_code               OUT NOCOPY  VARCHAR2,
                                   x_error_msg                 OUT NOCOPY  VARCHAR2,
                                   p_enhanced_pi_ind           IN    VARCHAR2,
                                   p_contiguous_ind            IN    NUMBER,
                                   p_recipe_type               IN    NUMBER);


/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Create_Recipe_Header
 |
 |   DESCRIPTION
 |      Create recipe header
 |
 |   INPUT PARAMETERS
 |
 |   OUTPUT PARAMETERS
 |     x_recipe_id   NUMBER
 |     x_return_code VARCHAR2(1)
 |     x_error_msg   VARCHAR2(100)
 |
 |   HISTORY
 |     08-OCT-2002 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Create_Recipe_Header ( p_orgn_id               IN  NUMBER,
                                   x_recipe_id             OUT NOCOPY NUMBER,
                                   x_return_code           OUT NOCOPY VARCHAR2,
                                   x_error_msg             OUT NOCOPY VARCHAR2);

/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Add_Recipe_Customer
 |
 |   DESCRIPTION
 |      Add a new customer to the recipe
 |
 |   INPUT PARAMETERS
 |
 |   OUTPUT PARAMETERS
 |     x_return_code VARCHAR2(1)
 |     x_error_msg   VARCHAR2(100)
 |
 |   HISTORY
 |     15-OCT-2002 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Add_Recipe_Customer (p_recipe_id         IN  NUMBER,
                                 p_customer_id       IN  NUMBER,
                                 p_text_code         IN  NUMBER,
                                 p_org_id            IN NUMBER,    --Modified for Bug # 5454787
                                 p_site_use_id       IN NUMBER,    --Modified for Bug # 5454787
                                 p_last_update_date  IN  DATE,
                                 x_return_code       OUT NOCOPY VARCHAR2,
                                 x_error_msg         OUT NOCOPY VARCHAR2);

/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Delete_Recipe_Customer
 |
 |   DESCRIPTION
 |      Delete customer from the recipe
 |
 |   INPUT PARAMETERS
 |    p_recipe_id        NUMBER
 |    p_customer_id      NUMBER
 |    p_last_update_date DATE
 |
 |   OUTPUT PARAMETERS
 |     x_return_code VARCHAR2(1)
 |     x_error_msg   VARCHAR2(100)
 |
 |   HISTORY
 |     15-OCT-2002 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Delete_Recipe_Customer (p_recipe_id         IN  NUMBER,
                                    p_customer_id       IN  NUMBER,
                                    p_last_update_date  IN  DATE,
                                    x_return_code       OUT NOCOPY VARCHAR2,
                                    x_error_msg         OUT NOCOPY VARCHAR2);

/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Add_Org_Process_Loss
 |
 |   DESCRIPTION
 |      Add a new organization specific process loss to the recipe
 |
 |   INPUT PARAMETERS
 |    p_recipe_id        NUMBER
 |    p_orgn_code        VARCHAR2
 |    p_process_loss     NUMBER
 |    p_text_code        NUMBER
 |    p_last_update_date DATE
 |
 |   OUTPUT PARAMETERS
 |     x_loss_id     NUMBER
 |     x_return_code VARCHAR2(1)
 |     x_error_msg   VARCHAR2(100)
 |
 |   HISTORY
 |     15-OCT-2002 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Add_Org_Process_Loss (p_recipe_id         IN NUMBER,
                                  p_orgn_id           IN NUMBER,
                                  p_process_loss      IN NUMBER,
                                  p_text_code         IN NUMBER,
                                  p_contiguous_ind    IN NUMBER,
                                  p_last_update_date  IN DATE,
                                  x_loss_id           OUT NOCOPY NUMBER,
                                  x_return_code       OUT NOCOPY VARCHAR2,
                                  x_error_msg         OUT NOCOPY VARCHAR2);
/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Create_Process_Loss
 |
 |   DESCRIPTION
 |      Add a new organization specific process loss to the recipe
 |
 |   INPUT PARAMETERS
 |    p_recipe_id        NUMBER
 |    p_orgn_code        VARCHAR2
 |    p_process_loss     NUMBER
 |    p_text_code        NUMBER
 |    p_last_update_date DATE
 |    p_loss_id          NUMBER
 |
 |   OUTPUT PARAMETERS
 |     x_loss_id     NUMBER
 |     x_return_code VARCHAR2(1)
 |     x_error_msg   VARCHAR2(100)
 |
 |   HISTORY
 |     10-DEC-2002 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Create_Process_Loss (p_recipe_id         IN NUMBER,
                                 p_orgn_id           IN NUMBER,
                                 p_process_loss      IN NUMBER,
                                 p_text_code         IN NUMBER,
                                 p_contiguous_ind    IN NUMBER,
                                 p_last_update_date  IN DATE,
                                 p_loss_id           IN NUMBER,
                                 x_loss_id           OUT NOCOPY NUMBER,
                                 x_return_code       OUT NOCOPY VARCHAR2,
                                 x_error_msg         OUT NOCOPY VARCHAR2);
/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Delete_Org_Process_Loss
 |
 |   DESCRIPTION
 |      Delete organization specific process loss from the recipe
 |
 |   INPUT PARAMETERS
 |    p_loss_id          NUMBER
 |    p_last_update_date DATE
 |
 |   OUTPUT PARAMETERS
 |     x_return_code VARCHAR2(1)
 |     x_error_msg   VARCHAR2(100)
 |
 |   HISTORY
 |     30-OCT-2002 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Delete_Org_Process_Loss (p_loss_id           IN NUMBER,
                                     p_last_update_date  IN DATE,
                                     x_return_code       OUT NOCOPY VARCHAR2,
                                     x_error_msg         OUT NOCOPY VARCHAR2);

/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Update_Org_Process_Loss
 |
 |   DESCRIPTION
 |      Update an organization specific process loss
 |
 |   INPUT PARAMETERS
 |    p_recipe_id        NUMBER
 |    p_recipe_loss_id   NUMBER
 |    p_orgn_code        VARCHAR2
 |    p_process_loss     NUMBER
 |    p_text_code        NUMBER
 |    p_last_update_date DATE
 |    p_last_update_date_orig DATE
 |
 |   OUTPUT PARAMETERS
 |     x_return_code VARCHAR2(1)
 |     x_error_msg   VARCHAR2(100)
 |
 |   HISTORY
 |     09-OCT-2002 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Update_Org_Process_Loss (p_recipe_id         IN NUMBER,
                                     p_recipe_loss_id    IN NUMBER,
                                     p_orgn_id          IN  NUMBER,
                                     p_process_loss      IN NUMBER,
                                     p_text_code         IN NUMBER,
                                     p_contiguous_ind    IN NUMBER,
                                     p_last_update_date  IN DATE,
                                     p_last_update_date_orig  IN DATE,
                                     x_return_code       OUT NOCOPY VARCHAR2,
                                     x_error_msg         OUT NOCOPY VARCHAR2);


/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Delete_Recipe
 |
 |   DESCRIPTION
 |      Mark for purge the given recipe
 |
 |   INPUT PARAMETERS
 |    p_recipe_id        NUMBER
 |    p_last_update_date_orig DATE
 |
 |   OUTPUT PARAMETERS
 |     x_return_code VARCHAR2(1)
 |     x_error_msg   VARCHAR2(100)
 |
 |   HISTORY
 |     13-NOV-2002 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Delete_Recipe (p_recipe_id              IN NUMBER,
                           p_last_update_date_orig  IN DATE,
                           x_return_code            OUT NOCOPY VARCHAR2,
                           x_error_msg              OUT NOCOPY VARCHAR2);


/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Undele_Recipe
 |
 |   DESCRIPTION
 |      Undelete the the given recipe
 |
 |   INPUT PARAMETERS
 |    p_recipe_id        NUMBER
 |    p_last_update_date_orig DATE
 |
 |   OUTPUT PARAMETERS
 |     x_return_code VARCHAR2(1)
 |     x_error_msg   VARCHAR2(100)
 |
 |   HISTORY
 |     13-NOV-2002 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Undelete_Recipe (p_recipe_id              IN NUMBER,
                             p_last_update_date_orig  IN DATE,
                             x_return_code            OUT NOCOPY VARCHAR2,
                             x_error_msg              OUT NOCOPY VARCHAR2);


/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Get_Theoretical_Process_Loss
 |
 |   DESCRIPTION
 |      Retrieve theoretical process loss
 |
 |   INPUT PARAMETERS
 |     p_routing_id     NUMBER
 |     p_formula_id     NUMBER
 |
 |   OUTPUT PARAMETERS
 |     x_theoretical_loss VARCHAR2(1)
 |     x_return_code      VARCHAR2(1)
 |     x_error_msg        VARCHAR2(100)
 |
 |   HISTORY
 |     21-NOV-2002 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Get_Theoretical_Process_Loss (p_routing_id       IN NUMBER,
                                          p_formula_id       IN NUMBER,
                                          x_theoretical_loss OUT NOCOPY NUMBER,
                                          x_return_code      OUT NOCOPY VARCHAR2,
                                          x_error_msg        OUT NOCOPY VARCHAR2);


/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Check_Step_Quantity_Calculatable
 |
 |   DESCRIPTION
 |      Check whether step quantities can be calculated.
 |
 |   INPUT PARAMETERS
 |     p_recipe_id     NUMBER
 |
 |   OUTPUT PARAMETERS
 |     x_return_code      VARCHAR2(1)
 |     x_error_msg        VARCHAR2(100)
 |
 |   HISTORY
 |     03-DEC-2002 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Check_Step_Qty_Calculatable (p_recipe_id   IN NUMBER,
                                         x_return_code OUT NOCOPY VARCHAR2,
                                         x_error_msg   OUT NOCOPY VARCHAR2);

/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Copy_Recipe
 |
 |   DESCRIPTION
 |      Copy the given recipe, formula and routing
 |
 |   INPUT PARAMETERS
 |     p_copy_from_recipe_id    NUMBER
 |     p_recipe_no              VARCHAR2
 |     p_recipe_vers            NUMBER
 |     p_recipe_desc            VARCHAR2
 |     p_copy_from_formula_id   NUMBER
 |     p_formula_no             VARCHAR2
 |     p_formula_vers           NUMBER
 |     p_formula_desc           VARCHAR2
 |     p_copy_from_routing_id   NUMBER
 |     p_routing_no             VARCHAR2
 |     p_routing_vers           NUMBER
 |     p_routing_desc           VARCHAR2
 |     p_commit                 VARCHAR2
 |
 |   OUTPUT PARAMETERS
 |     x_recipe_id   NUMBER
 |     x_formula_id  NUMBER
 |     x_routing_id  NUMBER
 |     x_return_code VARCHAR2(1)
 |     x_error_msg   VARCHAR2(100)
 |
 |   HISTORY
 |     10-DEC-2002 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Copy_Recipe  ( p_copy_from_recipe_id   IN  NUMBER,
                           p_recipe_no             IN  VARCHAR2,
                           p_recipe_vers           IN  NUMBER,
                           p_recipe_desc           IN  VARCHAR2,
                           p_copy_from_formula_id  IN  NUMBER,
                           p_formula_no            IN  VARCHAR2,
                           p_formula_vers          IN  NUMBER,
                           p_formula_desc          IN  VARCHAR2,
                           p_copy_from_routing_id  IN  NUMBER,
                           p_routing_no            IN  VARCHAR2,
                           p_routing_vers          IN  NUMBER,
                           p_routing_desc          IN  VARCHAR2,
                           p_commit                IN  VARCHAR2,
                           x_recipe_id             OUT NOCOPY NUMBER,
                           x_formula_id            OUT NOCOPY NUMBER,
                           x_routing_id            OUT NOCOPY NUMBER,
                           x_return_code           OUT NOCOPY VARCHAR2,
                           x_error_msg             OUT NOCOPY VARCHAR2);

 /* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      SET_DEFAULT_STATUS
 |
 |   DESCRIPTION
 |      Procedure to set the Default Status for a new Recipe
 |
 |   INPUT PARAMETERS
 |      Recipe_id       NUMBER
 |
 |   OUTPUT PARAMETERS
 |      x_return_code   VARCHAR2
 |      x_msg_count     NUMBER
 |      x_msg_data      VARCHAR2
 |
 |   HISTORY
 |      27-APR-2004  S.Sriram  Created for Default Status Build (Bug# 3408799)
 |
 +=============================================================================
 Api end of comments
*/
PROCEDURE set_default_status (pEntity_name     IN  VARCHAR2
                              ,pEntity_id      IN  NUMBER
                              ,x_return_status OUT NOCOPY VARCHAR2
                              ,x_msg_count     OUT NOCOPY NUMBER
                              ,x_msg_data      OUT NOCOPY VARCHAR2 );


/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      CHECK_RECP_ORGN_ACCESS
 |
 |   DESCRIPTION
 |      Procedure to chk if user has accesss to the Recp Orgn.
 |
 |   INPUT PARAMETERS
 |      p_recipe_id      NUMBER
 |      p_user_id        NUMBER
 |
 |   OUTPUT PARAMETERS
 |      x_return_code   VARCHAR2
 |
 |   HISTORY
 |      13-OCT-2004  S.Sriram  Created for Recipe Security (Bug# 3948203)
 |
 +=============================================================================
 Api end of comments
 */

 PROCEDURE CHECK_RECP_ORGN_ACCESS(p_recipe_id         IN  NUMBER,
                                  p_user_id           IN  NUMBER,
                                  x_return_code       OUT NOCOPY VARCHAR2);



 PROCEDURE Check_Recipe_Formula (p_recipe_id         IN   NUMBER,
                                 p_organization_id   IN   NUMBER,
                                 x_return_code       OUT NOCOPY VARCHAR2);



END GMD_RECIPE_DESIGNER_PKG;

/
