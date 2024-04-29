--------------------------------------------------------
--  DDL for Package GMD_ROUTING_DESIGNER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_ROUTING_DESIGNER_PKG" AUTHID CURRENT_USER AS
/* $Header: GMDRSDDS.pls 120.4 2006/08/08 11:31:50 kmotupal noship $ */
/*====================================================================================
 |                         Copyright (c) 2001 Oracle Corporation
 |                             Redwood Shores, California, USA
 |                                  All rights reserved
 =====================================================================================
 |   FILENAME
 |      GMDRSDDS.pls
 |
 |   DESCRIPTION
 |      Package spec containing the procedures used by the Routing Designer
 |      to create/update/delete routing step dependencies.
 |
 |
 |   NOTES
 |
 |   HISTORY
 |     12-APR-2001 Eddie Oumerretane   Created.
 |     27-APR-2004 S.Sriram  Bug# 3408799
 |                 Added SET_DEFAULT_STATUS procedure for Default Status Build
 |     23-SEP-2004 S.Sriram  Routing Security build
 |                 Added CHECK_ROUT_ORGN_ACCESS procedure for Rout. Security Build
 |     29-Dec-2005 TDaniel Bug# 4603035
 |                 Added code for contiguous_ind and enforce_step_dep.
 =======================================================================================
*/

G_CREATED_BY        NUMBER := FND_PROFILE.VALUE('USER_ID');
G_LOGIN_ID          NUMBER := FND_PROFILE.VALUE('LOGIN_ID');
G_USER_ORG          VARCHAR2(4);

/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Delete_Step_Dependency
 |
 |   DESCRIPTION
 |      Delete a specific step depdendency.
 |
 |   INPUT PARAMETERS
 |     p_routing_id         NUMBER
 |     p_dep_routingstep_no NUMBER
 |     p_routingstep_no     NUMBER
 |     p_last_update_date   DATE
 |
 |   OUTPUT PARAMETERS
 |     x_return_code VARCHAR2(1)
 |     x_error_msg   VARCHAR2(100)
 |
 |   HISTORY
 |     12-APR-2001 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/

  PROCEDURE Delete_Step_Dependency ( p_routing_id         IN  NUMBER,
                                     p_dep_routingstep_no IN  NUMBER,
                                     p_routingstep_no     IN  NUMBER,
                                     p_last_update_date   IN  DATE,
                                     x_return_code        OUT NOCOPY VARCHAR2,
                                     x_error_msg          OUT NOCOPY VARCHAR2);

/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Create_Step_Dependency
 |
 |   DESCRIPTION
 |      Create an entry in FM_ROUT_DEP representing a dependency between two
 |      routing steps.
 |
 |   INPUT PARAMETERS
 |     p_dep_routingstep_no  NUMBER
 |     p_routing_id          NUMBER
 |     p_dep_type            NUMBER
 |     p_rework_code         VARCHAR2
 |     p_standard_delay      NUMBER
 |     p_minimum_delay       NUMBER
 |     p_max_delay           NUMBER
 |     p_transfer_qty        NUMBER
 |     p_titem_um            VARCHAR2
 |     p_user_id             NUMBER
 |     p_transfer_pct        NUMBER
 |
 |   OUTPUT PARAMETERS
 |     x_return_code VARCHAR2(1)
 |     x_error_msg   VARCHAR2(100)
 |
 |   HISTORY
 |     12-APR-2001 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/

  PROCEDURE Create_Step_Dependency ( p_routingstep_no     IN  NUMBER,
                                     p_dep_routingstep_no IN  NUMBER,
                                     p_routing_id         IN  NUMBER,
                                     p_dep_type           IN  NUMBER,
                                     p_rework_code        IN  VARCHAR2,
                                     p_standard_delay     IN  NUMBER,
                                     p_minimum_delay      IN  NUMBER,
                                     p_max_delay          IN  NUMBER,
                                     p_transfer_qty       IN  NUMBER,
                                     p_item_um            IN  VARCHAR2,
                                     p_user_id            IN  NUMBER,
                                     p_transfer_pct       IN  NUMBER,
                                     p_last_update_date   IN  DATE,
                                     x_return_code        OUT NOCOPY VARCHAR2,
                                     x_error_msg          OUT NOCOPY VARCHAR2);


/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Update_Step_Dependency
 |
 |   DESCRIPTION
 |      Update an entry in FM_ROUT_DEP representing a dependency between two
 |      routing steps.
 |
 |   INPUT PARAMETERS
 |     p_routing_id  NUMBER
 |
 |   OUTPUT PARAMETERS
 |     x_return_code VARCHAR2(1)
 |     x_error_msg   VARCHAR2(100)
 |
 |   HISTORY
 |     12-APR-2001 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/

  PROCEDURE Update_Step_Dependency ( p_routingstep_no            IN  NUMBER,
                                     p_dep_routingstep_no        IN  NUMBER,
                                     p_routing_id                IN  NUMBER,
                                     p_dep_type                  IN  NUMBER,
                                     p_rework_code               IN  VARCHAR2,
                                     p_standard_delay            IN  NUMBER,
                                     p_minimum_delay             IN  NUMBER,
                                     p_max_delay                 IN  NUMBER,
                                     p_transfer_qty              IN  NUMBER,
                                     p_user_id                   IN  NUMBER,
                                     p_transfer_pct              IN  NUMBER,
                                     p_last_update_date          IN  DATE,
                                     p_last_update_date_origin   IN  DATE,
                                     x_return_code               OUT NOCOPY VARCHAR2,
                                     x_error_msg                 OUT NOCOPY VARCHAR2);


/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Update_Operation_Step
 |
 |   DESCRIPTION
 |      Update a particular operation step
 |
 |   INPUT PARAMETERS
 |     p_routing_id     NUMBER
 |     p_routingstep_id NUMBER
 |     p_coord_x        NUMBER
 |     p_coord_y        NUMBER
 |     p_user_id        NUMBER
 |     p_last_update_date DATE
 |     p_last_update_date_origin DATE
 |
 |   OUTPUT PARAMETERS
 |     x_return_code VARCHAR2(1)
 |     x_error_msg   VARCHAR2(100)
 |
 |   HISTORY
 |     12-APR-2001 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/

/*
  PROCEDURE Update_Operation_Step ( p_routing_id              IN  NUMBER,
                                    p_routingstep_id          IN  NUMBER,
                                    p_coord_x                 IN  NUMBER,
                                    p_coord_y                 IN  NUMBER,
                                    p_user_id                 IN  NUMBER,
                                    p_last_update_date        IN  DATE,
                                    p_last_update_date_origin IN  DATE,
                                    x_return_code             OUT NOCOPY VARCHAR2,
                                    x_error_msg               OUT NOCOPY VARCHAR2);

*/

/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Get_Routing_Mode
 |
 |   DESCRIPTION
 |      Determine whether this routing is in update or query mode
 |
 |   INPUT PARAMETERS
 |     p_routing_id                 NUMBER
 |
 |   OUTPUT PARAMETERS
 |     x_routing_mode  VARCHAR2
 |     x_return_code  VARCHAR2
 |     x_error_msg    VARCHAR2
 |
 |   HISTORY
 |     15-OCT-2001 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/

  PROCEDURE Get_Routing_Mode ( p_routing_id               IN  NUMBER,
                              x_routing_mode              OUT NOCOPY VARCHAR2,
                              x_return_code               OUT NOCOPY VARCHAR2,
                              x_error_msg                 OUT NOCOPY VARCHAR2);


/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Is_Routing_Used_In_Recipes
 |
 |   DESCRIPTION
 |      Determine whether the routing is used in one or more recipes.
 |
 |   INPUT PARAMETERS
 |     p_routing_id          NUMBER
 |
 |   OUTPUT PARAMETERS
 |     x_used_in_recipes    VARCHAR2(1)
 |     x_return_code        VARCHAR2(1)
 |     x_error_msg          VARCHAR2(100)
 |
 |   HISTORY
 |     22-NOV-2001 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Is_Routing_Used_In_Recipes ( p_routing_id      IN    NUMBER,
                                        x_used_in_recipes  OUT NOCOPY VARCHAR2,
                                        x_return_code      OUT NOCOPY  VARCHAR2,
                                        x_error_msg        OUT NOCOPY  VARCHAR2);

/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Update_Routing_Header
 |
 |   DESCRIPTION
 |      Update routing header
 |
 |   INPUT PARAMETERS
 |     p_routing_id            IN  NUMBER
 |     p_routing_no            IN  VARCHAR2
 |     p_routing_vers          IN  NUMBER
 |     p_routing_desc          IN  VARCHAR2
 |     p_routing_class         IN  VARCHAR2
 |     p_effective_start_date  IN  DATE
 |     p_effective_end_date    IN  DATE
 |     p_routing_qty           IN  NUMBER
 |     p_routing_uom           IN  VARCHAR2
 |     p_process_loss          IN  NUMBER
 |     p_owner_id              IN  NUMBER
 |     p_owner_orgn_code       IN  VARCHAR2
 |     p_enforce_step_dep      IN  NUMBER
 |     p_last_update_date      IN  DATE
 |     p_user_id               IN  NUMBER
 |     p_update_release_type   IN  NUMBER
 |
 |   OUTPUT PARAMETERS
 |     x_return_code VARCHAR2(1)
 |     x_error_msg   VARCHAR2(100)
 |
 |   HISTORY
 |     13-JUN-2002 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Update_Routing_Header ( p_routing_id            IN  NUMBER,
                                    p_routing_no            IN  VARCHAR2,
                                    p_routing_vers          IN  NUMBER,
                                    p_routing_desc          IN  VARCHAR2,
                                    p_routing_class         IN  VARCHAR2,
                                    p_effective_start_date  IN  DATE,
                                    p_effective_end_date    IN  DATE,
                                    p_routing_qty           IN  NUMBER,
                                    p_routing_uom           IN  VARCHAR2,
                                    p_process_loss          IN  NUMBER,
                                    p_owner_id              IN  NUMBER,
                                    p_owner_orgn_id         IN  NUMBER,
                                    p_enforce_step_dep      IN  NUMBER,
                                    p_contiguous_ind        IN  NUMBER,
                                    p_last_update_date      IN  DATE,
                                    p_user_id               IN  NUMBER,
                                    p_last_update_date_orig IN  DATE,
                                    p_update_release_type   IN  NUMBER,
                                    x_return_code           OUT NOCOPY VARCHAR2,
                                    x_error_msg             OUT NOCOPY VARCHAR2);


/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Check_Version_Control
 |
 |   DESCRIPTION
 |      Determine whether version control is enabled.
 |
 |   INPUT PARAMETERS
 |     p_entity_type        VARCHAR2
 |     p_entity_id          NUMBER
 |
 |   OUTPUT PARAMETERS
 |     x_version_control    VARCHAR2(1)
 |     x_return_code        VARCHAR2(1)
 |     x_error_msg          VARCHAR2(100)
 |
 |   HISTORY
 |     24-JUN-2002 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Check_Version_Control ( p_entity_type        IN  VARCHAR2,
                                    p_entity_id          IN  NUMBER,
                                    x_version_control    OUT NOCOPY VARCHAR2,
                                    x_return_code        OUT NOCOPY VARCHAR2,
                                    x_error_msg          OUT NOCOPY VARCHAR2);

/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Check_Function
 |
 |   DESCRIPTION
 |      Determine whether user has access to the given function.
 |
 |   INPUT PARAMETERS
 |     p_function_name      VARCHAR2
 |
 |   OUTPUT PARAMETERS
 |     x_access             VARCHAR2(1)
 |
 |   HISTORY
 |     25-JUN-2002 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Check_Function ( p_function_name        IN  VARCHAR2,
                             x_access               OUT NOCOPY VARCHAR2);

/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Create_Routing_Step
 |
 |   DESCRIPTION
 |      Create routing step
 |
 |   INPUT PARAMETERS
 |     p_routing_id        IN  NUMBER
 |     p_routingstep_no    IN  NUMBER
 |     p_routingstep_id    IN  NUMBER
 |     p_oprn_id           IN  NUMBER
 |     p_step_qty          IN  NUMBER
 |     p_release_type      IN  NUMBER
 |     p_text_code         IN  NUMBER
 |     p_coordx            IN  NUMBER
 |     p_coordy            IN  NUMBER
 |     p_last_update_date  IN  DATE
 |     p_user_id           IN  NUMBER
 |
 |   OUTPUT PARAMETERS
 |     x_return_code VARCHAR2(1)
 |     x_error_msg   VARCHAR2(100)
 |
 |   HISTORY
 |     02-JUL-2002 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Insert_Routing_Step   ( p_routing_id        IN  NUMBER,
                                    p_routingstep_no    IN  NUMBER,
                                    p_routingstep_id    IN  NUMBER,
                                    p_oprn_id           IN  NUMBER,
                                    p_step_qty          IN  NUMBER,
                                    p_release_type      IN  NUMBER,
                                    p_text_code         IN  NUMBER,
                                    p_last_update_date  IN  DATE,
                                    p_user_id           IN  NUMBER,
                                    p_coordx            IN  NUMBER,
                                    p_coordy            IN  NUMBER,
                                    x_return_code       OUT NOCOPY VARCHAR2,
                                    x_error_msg         OUT NOCOPY VARCHAR2);
/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Update_Routing_Step
 |
 |   DESCRIPTION
 |      Update routing step
 |
 |   INPUT PARAMETERS
 |     p_routingstep_id        IN  NUMBER
 |     p_release_type          IN  NUMBER
 |     p_step_qty              IN  NUMBER
 |     p_text_code             IN  NUMBER
 |     p_last_update_date      IN  DATE
 |     p_user_id               IN  NUMBER
 |     p_last_update_date_orig IN  DATE
 |
 |   OUTPUT PARAMETERS
 |     x_return_code VARCHAR2(1)
 |     x_error_msg   VARCHAR2(100)
 |
 |   HISTORY
 |     02-JUL-2002 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Update_Routing_Step   ( p_routingstep_id        IN  NUMBER,
                                    p_release_type          IN  NUMBER,
                                    p_step_qty              IN  NUMBER,
                                    p_text_code             IN  NUMBER,
                                    p_coordx                IN  NUMBER,
                                    p_coordy                IN  NUMBER,
                                    p_last_update_date      IN  DATE,
                                    p_user_id               IN  NUMBER,
                                    p_last_update_date_orig IN  DATE,
                                    x_return_code           OUT NOCOPY VARCHAR2,
                                    x_error_msg             OUT NOCOPY VARCHAR2);


/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Create_Routing_Header
 |
 |   DESCRIPTION
 |      Create routing header
 |
 |   INPUT PARAMETERS
 |     p_routing_no            IN  VARCHAR2
 |     p_routing_vers          IN  NUMBER,
 |     p_routing_desc          IN  VARCHAR2
 |     p_routing_class         IN  VARCHAR2
 |     p_effective_start_date  IN  DATE
 |     p_effective_end_date    IN  DATE
 |     p_routing_qty           IN  NUMBER
 |     p_routing_uom           IN  VARCHAR2
 |     p_process_loss          IN  NUMBER
 |     p_owner_id              IN  NUMBER
 |     p_owner_orgn_code       IN  VARCHAR2
 |     p_enforce_step_dep      IN  NUMBER
 |     p_last_update_date      IN  DATE
 |     p_user_id               IN  NUMBER
 |
 |   OUTPUT PARAMETERS
 |     x_routing_id  NUMBER
 |     x_return_code VARCHAR2(1)
 |     x_error_msg   VARCHAR2(100)
 |
 |   HISTORY
 |     06-JUL-2002 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Create_Routing_Header ( p_routing_no            IN  VARCHAR2,
                                    p_routing_vers          IN  NUMBER,
                                    p_routing_desc          IN  VARCHAR2,
                                    p_routing_class         IN  VARCHAR2,
                                    p_effective_start_date  IN  DATE,
                                    p_effective_end_date    IN  DATE,
                                    p_routing_qty           IN  NUMBER,
                                    p_routing_uom           IN  VARCHAR2,
                                    p_process_loss          IN  NUMBER,
                                    p_owner_id              IN  NUMBER,
                                    p_owner_orgn_id         IN  NUMBER,
                                    p_enforce_step_dep      IN  NUMBER,
                                    p_contiguous_ind        IN  NUMBER,
                                    p_last_update_date      IN  DATE,
                                    p_user_id               IN  NUMBER,
                                    x_routing_id            OUT NOCOPY NUMBER,
                                    x_return_code           OUT NOCOPY VARCHAR2,
                                    x_error_msg             OUT NOCOPY VARCHAR2);
/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Generate_Step_Dependencies
 |
 |   DESCRIPTION
 |      Generate sequential step dependencies
 |
 |   INPUT PARAMETERS
 |     p_routing_id            IN  NUMBER
 |     p_dependency_type       IN  NUMBER
 |
 |   OUTPUT PARAMETERS
 |     x_return_code VARCHAR2(1)
 |     x_error_msg   VARCHAR2(100)
 |
 |   HISTORY
 |     09-JUL-2002 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Generate_Step_Dependencies(p_routing_id      IN NUMBER,
                                       p_dependency_type IN NUMBER,
                                       x_return_code     OUT NOCOPY VARCHAR2,
                                       x_error_msg       OUT NOCOPY VARCHAR2);


/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Delete_Routing_Step
 |
 |   DESCRIPTION
 |      Delete a step
 |
 |   INPUT PARAMETERS
 |     p_routing_id         NUMBER
 |     p_routingstep_id     NUMBER
 |     p_last_update_date   DATE
 |
 |   OUTPUT PARAMETERS
 |     x_return_code VARCHAR2(1)
 |     x_error_msg   VARCHAR2(100)
 |
 |   HISTORY
 |     16-JUL-2002 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/

  PROCEDURE Delete_Routing_Step ( p_routing_id         IN  NUMBER,
                                  p_routingstep_id     IN  NUMBER,
                                  p_last_update_date   IN  DATE,
                                  x_return_code        OUT NOCOPY VARCHAR2,
                                  x_error_msg          OUT NOCOPY VARCHAR2);


/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Copy_Routing
 |
 |   DESCRIPTION
 |      Copy the given routing
 |
 |   INPUT PARAMETERS
 |     p_copy_from_routing_id   NUMBER
 |     p_routing_no             VARCHAR2
 |     p_routing_vers           VARCHAR2
 |     p_routing_desc           VARCHAR2
 |
 |   OUTPUT PARAMETERS
 |     x_routing_id  NUMBER
 |     x_return_code VARCHAR2(1)
 |     x_error_msg   VARCHAR2(100)
 |
 |   HISTORY
 |     18-JUL-2002 Eddie Oumerretane   Created.
 |     08-AUG-2006 Removed orgn_id for bug# 5206623
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Copy_Routing ( p_copy_from_routing_id  IN  NUMBER,
                           p_routing_no            IN  VARCHAR2,
                           p_routing_vers          IN  NUMBER,
                           p_routing_desc          IN  VARCHAR2,
                           x_routing_id            OUT NOCOPY NUMBER,
                           x_return_code           OUT NOCOPY VARCHAR2,
                           x_error_msg             OUT NOCOPY VARCHAR2);

/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Save_Profile_Value
 |
 |   DESCRIPTION
 |      Save the given profile option
 |
 |   INPUT PARAMETERS
 |     p_profile_name          VARCHAR2
 |     p_profile_value         VARCHAR2
 |
 |   OUTPUT PARAMETERS
 |     x_return_code VARCHAR2(1)
 |     x_error_msg   VARCHAR2(100)
 |
 |   HISTORY
 |     18-JUL-2002 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Save_Profile_Value ( p_profile_name  IN  VARCHAR2,
                                 p_profile_value IN  VARCHAR2,
                                 x_return_code   OUT NOCOPY VARCHAR2,
                                 x_error_msg     OUT NOCOPY VARCHAR2);

/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Get_Profile_Value
 |
 |   DESCRIPTION
 |      Get the value of the given profile option
 |
 |   INPUT PARAMETERS
 |     p_profile_name          VARCHAR2
 |
 |   OUTPUT PARAMETERS
 |     x_profile_value  VARCHAR2
 |     x_return_code    VARCHAR2(1)
 |     x_error_msg      VARCHAR2(100)
 |
 |   HISTORY
 |     18-JUL-2002 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Get_Profile_Value ( p_profile_name  IN  VARCHAR2,
                                x_profile_value OUT NOCOPY VARCHAR2,
                                x_return_code   OUT NOCOPY VARCHAR2,
                                x_error_msg     OUT NOCOPY VARCHAR2);

/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Validate_Routing_Details
 |
 |   DESCRIPTION
 |      Validate routing details
 |
 |   INPUT PARAMETERS
 |     p_routing_id     NUMBER
 |
 |   OUTPUT PARAMETERS
 |     x_return_code    VARCHAR2(1)
 |     x_error_msg      VARCHAR2(100)
 |
 |   HISTORY
 |     24-JUL-2002 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Validate_Routing_Details ( p_routing_id    IN  VARCHAR2,
                                       x_return_code   OUT NOCOPY VARCHAR2,
                                       x_error_msg     OUT NOCOPY VARCHAR2);

/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Validate_Routing_VR_Dates
 |
 |   DESCRIPTION
 |      Verify that the routing effective dates falls within all recipe validity
 |      rules that are using the routing.
 |
 |   INPUT PARAMETERS
 |     p_routing_id     NUMBER
 |
 |   OUTPUT PARAMETERS
 |     x_update_vr      VARCHAR2(1)
 |     x_return_code    VARCHAR2(1)
 |     x_error_msg      VARCHAR2(100)
 |
 |   HISTORY
 |     24-JUL-2002 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Validate_Routing_VR_Dates ( p_routing_id    IN  VARCHAR2,
                                        x_update_vr     OUT NOCOPY VARCHAR2,
                                        x_return_code   OUT NOCOPY VARCHAR2,
                                        x_error_msg     OUT NOCOPY VARCHAR2);

/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Update_VR_With_RT_Dates
 |
 |   DESCRIPTION
 |      Update validity rules with routing from/to dates
 |
 |   INPUT PARAMETERS
 |     p_routing_id     NUMBER
 |
 |   OUTPUT PARAMETERS
 |     x_return_code    VARCHAR2(1)
 |     x_error_msg      VARCHAR2(100)
 |
 |   HISTORY
 |     24-JUL-2002 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Update_VR_With_RT_Dates ( p_routing_id    IN  VARCHAR2,
                                      x_return_code   OUT NOCOPY VARCHAR2,
                                      x_error_msg     OUT NOCOPY VARCHAR2);


/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Get_Theoretical_Process_Loss
 |
 |   DESCRIPTION
 |      Retrieve theoretical process loss
 |
 |   INPUT PARAMETERS
 |     p_routing_qty    NUMBER
 |     p_routing_um     VARCHAR2
 |     p_routing_class  VARCHAR2
 |
 |   OUTPUT PARAMETERS
 |     x_theoretical_loss VARCHAR2(1)
 |     x_return_code      VARCHAR2(1)
 |     x_error_msg        VARCHAR2(100)
 |
 |   HISTORY
 |     02-AUG-2002 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Get_Theoretical_Process_Loss (p_routing_qty      IN NUMBER,
                                          p_routing_um       IN VARCHAR2,
                                          p_routing_class    IN VARCHAR2,
                                          x_theoretical_loss OUT NOCOPY NUMBER,
                                          x_return_code      OUT NOCOPY VARCHAR2,
                                          x_error_msg        OUT NOCOPY VARCHAR2);

/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Delete_Routing
 |
 |   DESCRIPTION
 |      Delete routing header
 |
 |   INPUT PARAMETERS
 |     p_routing_id            IN  NUMBER
 |     p_last_update_date_orig IN  DATE
 |
 |   OUTPUT PARAMETERS
 |     x_return_code VARCHAR2(1)
 |     x_error_msg   VARCHAR2(100)
 |
 |   HISTORY
 |     14-AUG-2002 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Delete_Routing ( p_routing_id            IN  NUMBER,
                             p_last_update_date_orig IN  DATE,
                             x_return_code           OUT NOCOPY VARCHAR2,
                             x_error_msg             OUT NOCOPY VARCHAR2);

/*
 +============================================================================
 |   PROCEDURE NAME
 |      Undelete_Routing
 |
 |   DESCRIPTION
 |      Unelete routing header
 |
 |   INPUT PARAMETERS
 |     p_routing_id            IN  NUMBER
 |     p_last_update_date_orig IN  DATE
 |
 |   OUTPUT PARAMETERS
 |     x_return_code VARCHAR2(1)
 |     x_error_msg   VARCHAR2(100)
 |
 |   HISTORY
 |     14-AUG-2002 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Undelete_Routing ( p_routing_id            IN  NUMBER,
                               p_last_update_date_orig IN  DATE,
                               x_return_code           OUT NOCOPY VARCHAR2,
                               x_error_msg             OUT NOCOPY VARCHAR2);



 /* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      CHECK_ROUT_ORGN_ACCESS
 |
 |   DESCRIPTION
 |      Procedure to chk if user has accesss to the Rout Orgn.
 |
 |   INPUT PARAMETERS
 |      p_routing_id      NUMBER
 |
 |   OUTPUT PARAMETERS
 |      x_return_code   VARCHAR2
 |
 |   HISTORY
 |      23-SEP-2004  S.Sriram  Created for Routing Security Build (Bug# 3408799)
 |
 +=============================================================================
 Api end of comments
 */

 PROCEDURE CHECK_ROUT_ORGN_ACCESS(p_routing_id         IN  NUMBER,
                                  x_return_code        OUT NOCOPY VARCHAR2);


 PROCEDURE Get_label_name (p_message_name  IN VARCHAR2
                           ,x_message_text  OUT NOCOPY VARCHAR2);

 END GMD_ROUTING_DESIGNER_PKG;

 

/
