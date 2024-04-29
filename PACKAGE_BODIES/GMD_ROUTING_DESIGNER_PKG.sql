--------------------------------------------------------
--  DDL for Package Body GMD_ROUTING_DESIGNER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_ROUTING_DESIGNER_PKG" AS
/* $Header: GMDRSDDB.pls 120.9 2006/08/17 12:42:57 kmotupal noship $ */
/*============================================================================
 |                         Copyright (c) 2001 Oracle Corporation
 |                             Redwood Shores, California, USA
 |                                  All rights reserved
 =============================================================================
 |   FILENAME
 |      GMDRSDDB.pls
 |
 |   DESCRIPTION
 |      Package body containing the procedures used by the Routing Designer
 |      to create/update/delete routing step dependencies.
 |
 |
 |   NOTES
 |
 |   HISTORY
 |     12-APR-2001 Eddie Oumerretane   Created.
 |     24-APR-2002 Eddie Oumerretane   Calculate transfer quantity prior to
 |                 updating the database.
 |     14-JUN-2002 Eddie Oumerretane   Added a procedure to update routing
 |                 header.
 |     01-JUL-2002 Eddie Oumerretane. Implemented various enhancements for
 |                 the Rapid Recipe Project.
 |     27-APR-2004 S.Sriram  Bug# 3408799
 |                 Added SET_DEFAULT_STATUS procedure for Default Status Build
 |     23-SEP-2004 S.Sriram  Routing Security build
 |                 Added CHECK_ROUT_ORGN_ACCESS procedure for Rout. Security Build
 |     29-Dec-2005 TDaniel Bug# 4603035
 |                 Added code for contiguous_ind and enforce_step_dep.
 =============================================================================
*/


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
                                     x_error_msg          OUT NOCOPY VARCHAR2) IS

    l_return_status           VARCHAR2(2);
    l_message_count           NUMBER;
    l_message_list            VARCHAR2(2000);
    l_message                 VARCHAR2(1000);
    l_dummy	              NUMBER;
    DELETE_STEP_DEP_EXCEPTION EXCEPTION;
    RECORD_CHANGED_EXCEPTION  EXCEPTION;

    CURSOR Cur_Get_Step_Dep IS
      SELECT *
      FROM   fm_rout_dep
      WHERE
        routingstep_no     = p_routingstep_no     AND
        dep_routingstep_no = p_dep_routingstep_no AND
        routing_id         = p_routing_id         AND
        last_update_date   = p_last_update_date;

    l_rec                    Cur_Get_Step_Dep%ROWTYPE;

  BEGIN

    x_return_code := 'S';
    x_error_msg   := '';


    OPEN Cur_Get_STep_Dep;
    FETCH Cur_Get_Step_Dep INTO l_rec;

    IF Cur_Get_Step_Dep%NOTFOUND THEN
      CLOSE Cur_Get_Step_Dep;
      RAISE RECORD_CHANGED_EXCEPTION;
    END IF;

    CLOSE Cur_Get_Step_Dep;

    GMD_ROUTING_STEPS_PUB.delete_step_dependencies
                 ( p_api_version        => 1
                 , p_init_msg_list      => TRUE
                 , p_commit             => FALSE
                 , p_routingstep_no     => p_routingstep_no
                 , p_dep_routingstep_no => p_dep_routingstep_no
                 , p_routing_id         => p_routing_id
                 , p_routing_no         => NULL
                 , p_routing_vers       => NULL
                 , x_message_count      => l_message_count
                 , x_message_list       => l_message_list
                 , x_return_status      => l_return_status);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE DELETE_STEP_DEP_EXCEPTION;
    END IF;

    EXCEPTION
      WHEN DELETE_STEP_DEP_EXCEPTION THEN
        FND_MSG_PUB.GET( p_msg_index     => 1,
                         p_data          => l_message,
                         p_encoded       => 'F',
                         p_msg_index_out => l_dummy);

        x_return_code := 'F';
        x_error_msg   := l_message;

     WHEN RECORD_CHANGED_EXCEPTION THEN
        FND_MESSAGE.SET_NAME('FND', 'FND_RECORD_CHANGED_ERROR');
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;
     WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

  END Delete_Step_Dependency;


/* Api start of comments
 +============================================================================
 |   FUNCTION NAME
 |      Calculate_Transfer_Quantity
 |
 |   DESCRIPTION
 |      Calculate transfer qty given the transfer pct for the given routing step
 |
 |   INPUT PARAMETERS
 |     p_routing_id          NUMBER
 |     p_routingstep_no      NUMBER
 |     p_transfer_pct        NUMBER
 |
 |   RETUEN VALUE
 |     x_transfer_qty        NUMBER
 |
 |   HISTORY
 |     24-APR-2002 Eddie Oumerretane   Created.
 |
 +=============================================================================
 Api end of comments
*/

 FUNCTION Calculate_Transfer_Qty (p_routing_id     NUMBER,
                                  p_routingstep_no NUMBER,
                                  p_transfer_pct   NUMBER) RETURN NUMBER IS

   l_transfer_qty NUMBER;

 BEGIN

   SELECT
     nvl(step_qty, 0) * p_transfer_pct / 100 INTO l_transfer_qty
   FROM
     fm_rout_dtl
   WHERE
     routing_id     = p_routing_id AND
     routingstep_no = p_routingstep_no;


   IF SQL%FOUND THEN
     RETURN l_transfer_qty;
   ELSE
     RETURN 0;
   END IF;

 END Calculate_Transfer_Qty;

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
 |     p_transfer_um         VARCHAR2
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
                                     x_error_msg          OUT NOCOPY VARCHAR2) IS

    l_transfer_qty            NUMBER;
    l_return_status           VARCHAR2(2);
    l_message_count           NUMBER;
    l_message_list            VARCHAR2(2000);
    l_message                 VARCHAR2(1000);
    l_dummy	              NUMBER;
    INSERT_STEP_DEP_EXCEPTION EXCEPTION;
    l_routings_step_dep_tbl   GMD_ROUTINGS_PUB.gmd_routings_step_dep_tab;

  BEGIN

    x_return_code := 'S';
    x_error_msg   := '';

    l_transfer_qty := Calculate_Transfer_Qty (p_routing_id,
                                              p_dep_routingstep_no,
                                              p_transfer_pct);

    l_routings_step_dep_tbl(1).ROUTINGSTEP_NO      := p_routingstep_no;
    l_routings_step_dep_tbl(1).DEP_ROUTINGSTEP_NO  := p_dep_routingstep_no;
    l_routings_step_dep_tbl(1).ROUTING_ID          := p_routing_id;
    l_routings_step_dep_tbl(1).DEP_TYPE            := p_dep_type;
    l_routings_step_dep_tbl(1).REWORK_CODE         := p_rework_code;
    l_routings_step_dep_tbl(1).STANDARD_DELAY      := p_standard_delay;
    l_routings_step_dep_tbl(1).MINIMUM_DELAY       := p_minimum_delay;
    l_routings_step_dep_tbl(1).MAX_DELAY           := p_max_delay;
    l_routings_step_dep_tbl(1).TRANSFER_QTY        := l_transfer_qty;
    l_routings_step_dep_tbl(1).ROUTINGSTEP_NO_UOM  := p_item_um;
    l_routings_step_dep_tbl(1).TEXT_CODE           := NULL;
    l_routings_step_dep_tbl(1).LAST_UPDATED_BY     := p_user_id;
    l_routings_step_dep_tbl(1).CREATED_BY          := p_user_id;
    l_routings_step_dep_tbl(1).LAST_UPDATE_DATE    := p_last_update_date;
    l_routings_step_dep_tbl(1).CREATION_DATE       := p_last_update_date;
    l_routings_step_dep_tbl(1).LAST_UPDATE_LOGIN   := p_user_id;
    l_routings_step_dep_tbl(1).TRANSFER_PCT        := p_transfer_pct;

    GMD_ROUTING_STEPS_PUB.insert_step_dependencies
                        (
                          p_api_version            => 1
                        , p_init_msg_list          => TRUE
                        , p_commit                 => FALSE
                        , p_routing_id             => p_routing_id
                        , p_routing_no             => NULL
                        , p_routing_vers           => NULL
                        , p_routingstep_id         => NULL
                        , p_routingstep_no         => p_routingstep_no
                        , p_routings_step_dep_tbl  => l_routings_step_dep_tbl
                        , x_message_count          => l_message_count
                        , x_message_list           => l_message_list
                        , x_return_status          => l_return_status);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE INSERT_STEP_DEP_EXCEPTION;
    END IF;

    EXCEPTION
      WHEN INSERT_STEP_DEP_EXCEPTION THEN
        FND_MSG_PUB.GET( p_msg_index     => 1,
                         p_data          => l_message,
                         p_encoded       => 'F',
                         p_msg_index_out => l_dummy);

        x_return_code := 'F';
        x_error_msg   := l_message;
     WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

  END Create_Step_Dependency;


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
                                     x_error_msg                 OUT NOCOPY VARCHAR2) IS


    l_transfer_qty NUMBER;
    l_return_status           VARCHAR2(2);
    l_message_count           NUMBER;
    l_message_list            VARCHAR2(2000);
    l_message                 VARCHAR2(1000);
    l_dummy	              NUMBER;
    UPDATE_STEP_DEP_EXCEPTION EXCEPTION;
    RECORD_CHANGED_EXCEPTION  EXCEPTION;
    l_update_table            GMD_ROUTINGS_PUB.update_tbl_type;

    CURSOR Cur_Get_Step_Dep IS
      SELECT *
      FROM   fm_rout_dep
      WHERE
        routingstep_no     = p_routingstep_no     AND
        dep_routingstep_no = p_dep_routingstep_no AND
        routing_id         = p_routing_id         AND
        last_update_date   = p_last_update_date_origin;

    l_rec                    Cur_Get_Step_Dep%ROWTYPE;

  BEGIN

    x_return_code := 'S';
    x_error_msg   := '';

    OPEN Cur_Get_STep_Dep;
    FETCH Cur_Get_Step_Dep INTO l_rec;

    IF Cur_Get_Step_Dep%NOTFOUND THEN
      CLOSE Cur_Get_Step_Dep;
      RAISE RECORD_CHANGED_EXCEPTION;
    END IF;

    CLOSE Cur_Get_Step_Dep;

    l_transfer_qty := Calculate_Transfer_Qty (p_routing_id,
                                              p_dep_routingstep_no,
                                              p_transfer_pct);

    l_update_table(1).p_col_to_update := 'DEP_TYPE';
    l_update_table(1).p_value         := p_dep_type;
    l_update_table(2).p_col_to_update := 'REWORK_CODE';
    l_update_table(2).p_value         := p_rework_code;
    l_update_table(3).p_col_to_update := 'STANDARD_DELAY';
    l_update_table(3).p_value         := p_standard_delay;
    l_update_table(4).p_col_to_update := 'MINIMUM_DELAY';
    l_update_table(4).p_value         := p_minimum_delay;
    l_update_table(5).p_col_to_update := 'MAX_DELAY';
    l_update_table(5).p_value         := p_max_delay;
    l_update_table(6).p_col_to_update := 'TRANSFER_QTY';
    l_update_table(6).p_value         := l_transfer_qty;
    l_update_table(7).p_col_to_update := 'LAST_UPDATED_BY';
    l_update_table(7).p_value         := p_user_id;
    l_update_table(8).p_col_to_update := 'CREATED_BY';
    l_update_table(8).p_value         := p_user_id;
    l_update_table(9).p_col_to_update := 'LAST_UPDATE_DATE';
    l_update_table(9).p_value         := fnd_date.date_to_canonical(p_last_update_date);
    l_update_table(10).p_col_to_update := 'LAST_UPDATE_LOGIN';
    l_update_table(10).p_value         := p_user_id;
    l_update_table(11).p_col_to_update := 'TRANSFER_PCT';
    l_update_table(11).p_value         := p_transfer_pct;

    GMD_ROUTING_STEPS_PUB.update_step_dependencies
                         ( p_api_version        => 1
                         , p_init_msg_list      => TRUE
                         , p_commit             => FALSE
                         , p_routingstep_no     => p_routingstep_no
                         , p_routingstep_id     => NULL
                         , p_dep_routingstep_no => p_dep_routingstep_no
                         , p_routing_id         => p_routing_id
                         , p_routing_no         => NULL
                         , p_routing_vers       => NULL
                         , p_update_table       => l_update_table
                         , x_message_count      => l_message_count
                         , x_message_list       => l_message_list
                         , x_return_status      => l_return_status);


    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE UPDATE_STEP_DEP_EXCEPTION;
    END IF;

    EXCEPTION
      WHEN UPDATE_STEP_DEP_EXCEPTION THEN
        FND_MSG_PUB.GET( p_msg_index     => 1,
                         p_data          => l_message,
                         p_encoded       => 'F',
                         p_msg_index_out => l_dummy);

        x_return_code := 'F';
        x_error_msg   := l_message;
     WHEN RECORD_CHANGED_EXCEPTION THEN
        FND_MESSAGE.SET_NAME('FND', 'FND_RECORD_CHANGED_ERROR');
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;
     WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

  END Update_Step_Dependency;

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
                              x_routing_mode              OUT NOCOPY   VARCHAR2,
                              x_return_code               OUT NOCOPY   VARCHAR2,
                              x_error_msg                 OUT NOCOPY   VARCHAR2) IS

    l_return_code       VARCHAR2(1);
    l_status            VARCHAR2(30);

  BEGIN

    x_return_code := 'S';
    x_error_msg   := '';

    IF GMD_COMMON_VAL.Update_Allowed(entity    => 'ROUTING',
                                     entity_id => p_routing_id) THEN
      x_routing_mode := 'U';
    ELSE
      x_routing_mode := 'Q';

    END IF;

  END Get_Routing_Mode;

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
  PROCEDURE Is_Routing_Used_In_Recipes (p_routing_id      IN  NUMBER,
                                        x_used_in_recipes OUT NOCOPY VARCHAR2,
                                        x_return_code     OUT NOCOPY VARCHAR2,
                                        x_error_msg       OUT NOCOPY VARCHAR2) IS

  BEGIN

    x_return_code := 'S';
    x_error_msg   := '';

    x_used_in_recipes   := 'N';

    -- Return TRUE if this routing is used by one or more recipes
    IF NOT GMD_STATUS_CODE.Check_Parent_Status('ROUTING', p_routing_id) THEN
      x_used_in_recipes   := 'Y';
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

  END Is_Routing_Used_In_Recipes;

/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Update_Routing_Header
 |
 |   DESCRIPTION
 |      Update routing header
 |
 |   INPUT PARAMETERS
 |     p_routing_id            IN  NUMBER,
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
 |     p_owner_orgn_id         IN  NUMBER
 |     p_enforce_step_dep      IN  NUMBER
 |     p_last_update_date      IN  DATE
 |     p_user_id               IN  NUMBER
 |     p_last_update_date_orig IN  DATE
 |     p_update_release_type   IN  NUMBER
 |
 |   OUTPUT PARAMETERS
 |     x_return_code VARCHAR2(1)
 |     x_error_msg   VARCHAR2(100)
 |
 |   HISTORY
 |     13-JUN-2002 Eddie Oumerretane   Created.
 |     20-APR-2004 kkillams Bug 3545196,Replaced TO_CHAR function with
 |                          FND_DATE.DATE_TO_CANONICAL function while converting
 |                          Routing Effective Start and End dates.
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
                                    x_error_msg             OUT NOCOPY VARCHAR2) IS
    CURSOR Cur_get_routing IS
      SELECT *
      FROM   gmd_routings
      WHERE  routing_id       = p_routing_id AND
             last_update_date = p_last_update_date_orig;

    UPDATE_ROUTING_EXCEPTION EXCEPTION;
    RECORD_CHANGED_EXCEPTION EXCEPTION;
    l_rec                    Cur_get_routing%ROWTYPE;
    l_enforce_step_dep       NUMBER;
    l_update_table           GMD_ROUTINGS_PUB.update_tbl_type;
    l_return_status          VARCHAR2(2);
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);
    l_message_count          NUMBER;
    l_message_list           VARCHAR2(2000);
    l_message                VARCHAR2(1000);
    l_dummy	             NUMBER;

  BEGIN

    x_error_msg   := '';
    x_return_code := FND_API.G_RET_STS_SUCCESS;


    OPEN Cur_get_routing;
    FETCH Cur_get_routing INTO l_rec;

    IF Cur_get_routing%NOTFOUND THEN
      CLOSE Cur_get_routing;
      RAISE RECORD_CHANGED_EXCEPTION;
    END IF;

    CLOSE Cur_get_routing;


    l_update_table(1).p_col_to_update := 'routing_id';
    l_update_table(1).p_value         := p_routing_id;

    l_update_table(2).p_col_to_update := 'owner_organization_id';
    l_update_table(2).p_value         := p_owner_orgn_id;

    l_update_table(3).p_col_to_update := 'routing_no';
    l_update_table(3).p_value         := p_routing_no;

    l_update_table(4).p_col_to_update := 'routing_vers';
    l_update_table(4).p_value         := p_routing_vers;

    l_update_table(5).p_col_to_update := 'routing_class';
    l_update_table(5).p_value         := p_routing_class;

    l_update_table(6).p_col_to_update := 'routing_qty';
    l_update_table(6).p_value         := p_routing_qty;

    l_update_table(7).p_col_to_update := 'routing_uom';
    l_update_table(7).p_value         := p_routing_uom;

    l_update_table(8).p_col_to_update := 'enforce_step_dependency';
    l_update_table(8).p_value         := p_enforce_step_dep;

    l_update_table(9).p_col_to_update := 'CONTIGUOUS_IND';
    l_update_table(9).p_value         := NVL(p_contiguous_ind, 0);

    l_update_table(10).p_col_to_update := 'effective_start_date';
    l_update_table(10).p_value         := FND_DATE.DATE_TO_CANONICAL(p_effective_start_date); -- Bug 3545196

    l_update_table(11).p_col_to_update := 'effective_end_date';
    l_update_table(11).p_value         := FND_DATE.DATE_TO_CANONICAL(p_effective_end_date); --Bug 3545196

    l_update_table(12).p_col_to_update := 'owner_id';
    l_update_table(12).p_value         := p_owner_id;

    l_update_table(13).p_col_to_update := 'process_loss';
    l_update_table(13).p_value         := p_process_loss;

    l_update_table(14).p_col_to_update := 'routing_desc';
    l_update_table(14).p_value         := p_routing_desc;

    l_update_table(15).p_col_to_update := 'last_update_date';
    l_update_table(15).p_value         := FND_DATE.DATE_TO_CANONICAL(p_last_update_date);

    l_update_table(16).p_col_to_update := 'last_updated_by';
    l_update_table(16).p_value         := p_user_id;

    l_update_table(17).p_col_to_update := 'last_update_login';
    l_update_table(17).p_value         := p_user_id;


    GMD_ROUTINGS_PUB.update_routing
                         ( p_api_version     => 1
                         , p_init_msg_list   => TRUE
                         , p_commit          => FALSE
                         , p_routing_id      => p_routing_id
                         , p_routing_no      => NULL
                         , p_routing_vers    => NULL
                         , p_update_table    => l_update_table
                         , x_message_count   => l_message_count
                         , x_message_list    => l_message_list
                         , x_return_status   => l_return_status);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE UPDATE_ROUTING_EXCEPTION;
    END IF;

    --- If routing number and/or version have changed, we need to update them. This
    --- happens when creating a new routing, because a dummy routing header is created in
    --- the database. User is then prompted to enter a valid routing number/version prior
    --- to saving.

    IF l_rec.routing_no   <> p_routing_no OR
       l_rec.routing_vers <> p_routing_vers THEN

      UPDATE
        GMD_ROUTINGS_B
      SET
        routing_no   = p_routing_no,
        routing_vers = p_routing_vers
      WHERE
        routing_id       = p_routing_id AND
        last_update_date = p_last_update_date;

          --4504794, this will defaults the PI instructions.
          GMD_PROCESS_INSTR_UTILS.COPY_PROCESS_INSTR(
                      p_entity_name   => 'ROUTING',
                      p_entity_id     => p_routing_id,
                      x_return_status => l_return_status,
                      x_msg_count     => l_msg_count,
                      x_msg_data      => l_msg_data);
      IF SQL%NOTFOUND THEN
        RAISE RECORD_CHANGED_EXCEPTION;
      END IF;

    END IF;


    -- Set step release type to Manual if Enforce Step Dependency flag is
    -- turned on. This is done here only if steps have not been loaded into
    -- the Designer. Otherwise, the Designer is responsible for updating the
    -- steps.

    IF (p_update_release_type = 1 AND
        p_enforce_step_dep    = 1) THEN

        UPDATE fm_rout_dtl
        SET steprelease_type  = 1,
            last_update_date  = p_last_update_date,
            last_updated_by   = p_user_id,
            last_update_login = p_user_id
        WHERE
          routing_id = p_routing_id;

    END IF;


    EXCEPTION
      WHEN UPDATE_ROUTING_EXCEPTION THEN
        FND_MSG_PUB.GET( p_msg_index     => 1,
                         p_data          => l_message,
                         p_encoded       => 'F',
                         p_msg_index_out => l_dummy);

        x_return_code := 'F';
        x_error_msg   := l_message;
     WHEN RECORD_CHANGED_EXCEPTION THEN
        FND_MESSAGE.SET_NAME('FND', 'FND_RECORD_CHANGED_ERROR');
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;
     WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

  END Update_Routing_Header;

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
                                    x_version_control    OUT NOCOPY   VARCHAR2,
                                    x_return_code        OUT NOCOPY   VARCHAR2,
                                    x_error_msg          OUT NOCOPY   VARCHAR2) IS

  BEGIN

    x_return_code := 'S';
    x_error_msg   := '';

    x_version_control := gmd_common_val.version_control_state(p_entity_type,
                                                              p_entity_id);

  END Check_Version_Control;

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
                             x_access               OUT NOCOPY VARCHAR2) IS

  BEGIN

    IF FND_FUNCTION.TEST(p_function_name) THEN
     x_access := 'Y';
    ELSE
     x_access := 'N';
    END IF;

  END Check_Function;

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
                                    x_error_msg         OUT NOCOPY VARCHAR2) IS

    l_text_code             NUMBER(10);
    l_routing_step_rec      fm_rout_dtl%ROWTYPE;
    l_return_status         VARCHAR2(2);
    l_message_count         NUMBER;
    l_message_list          VARCHAR2(2000);
    l_message               VARCHAR2(1000);
    l_dummy	            NUMBER;
    INSERT_STEP_EXCEPTION   EXCEPTION;
    l_routings_step_dep_tbl GMD_ROUTINGS_PUB.gmd_routings_step_dep_tab;

  BEGIN

    x_error_msg   := '';
    x_return_code := FND_API.G_RET_STS_SUCCESS;

    IF p_text_code <= 0 THEN
      l_text_code := NULL;
    ELSE
      l_text_code := p_text_code;
    END IF;

    l_routing_step_rec.routing_id         := p_routing_id;
    l_routing_step_rec.routingstep_no     := p_routingstep_no;
    l_routing_step_rec.routingstep_id     := p_routingstep_id;
    l_routing_step_rec.oprn_id            := p_oprn_id;
    l_routing_step_rec.step_qty           := p_step_qty;
    l_routing_step_rec.steprelease_type   := p_release_type;
    l_routing_step_rec.text_code          := l_text_code;
    l_routing_step_rec.x_coordinate       := p_coordx;
    l_routing_step_rec.y_coordinate       := p_coordy;
    l_routing_step_rec.last_updated_by    := p_user_id;
    l_routing_step_rec.created_by         := p_user_id;
    l_routing_step_rec.last_update_date   := p_last_update_date;
    l_routing_step_rec.creation_date      := p_last_update_date;
    l_routing_step_rec.last_update_login  := p_user_id;

    GMD_ROUTING_STEPS_PUB.insert_routing_steps (
                          p_api_version            => 1
                        , p_init_msg_list          => TRUE
                        , p_commit                 => FALSE
                        , p_routing_id             => p_routing_id
                        , p_routing_no             => NULL
                        , p_routing_vers           => NULL
                        , p_routing_step_rec       => l_routing_step_rec
                        , p_routings_step_dep_tbl  => l_routings_step_dep_tbl
                        , x_message_count          => l_message_count
                        , x_message_list           => l_message_list
                        , x_return_status          => l_return_status);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE INSERT_STEP_EXCEPTION;
    END IF;

    EXCEPTION
      WHEN INSERT_STEP_EXCEPTION THEN
        FND_MSG_PUB.GET( p_msg_index     => 1,
                         p_data          => l_message,
                         p_encoded       => 'F',
                         p_msg_index_out => l_dummy);

        x_return_code := 'F';
        x_error_msg   := l_message;
     WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

  END Insert_Routing_Step;

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
                                    x_error_msg             OUT NOCOPY VARCHAR2) IS

    l_text_code              NUMBER(10);
    l_return_status          VARCHAR2(2);
    l_message_count          NUMBER;
    l_message_list           VARCHAR2(2000);
    l_message                VARCHAR2(1000);
    l_dummy	             NUMBER;
    l_update_table           GMD_ROUTINGS_PUB.update_tbl_type;
    UPDATE_STEP_EXCEPTION    EXCEPTION;
    RECORD_CHANGED_EXCEPTION EXCEPTION;

    CURSOR Cur_get_step IS
       SELECT *
       FROM   fm_rout_dtl
       WHERE  routingstep_id   = p_routingstep_id AND
              last_update_date = p_last_update_date_orig;

    l_step_rec Cur_get_step%ROWTYPE;

  BEGIN

    x_error_msg   := '';
    x_return_code := FND_API.G_RET_STS_SUCCESS;


    IF p_text_code <= 0 THEN
      l_text_code := NULL;
    ELSE
      l_text_code := p_text_code;
    END IF;

    OPEN Cur_get_step;
    FETCH Cur_get_step INTO l_step_rec;

    IF Cur_get_step%NOTFOUND THEN
      CLOSE Cur_get_step;
      RAISE RECORD_CHANGED_EXCEPTION;
    END IF;

    CLOSE Cur_get_step;

    l_update_table(1).p_col_to_update := 'step_qty';
    l_update_table(1).p_value         := p_step_qty;
    l_update_table(2).p_col_to_update := 'steprelease_type';
    l_update_table(2).p_value         := p_release_type;
    l_update_table(3).p_col_to_update := 'text_code';
    l_update_table(3).p_value         := l_text_code;
    l_update_table(4).p_col_to_update := 'x_coordinate';
    l_update_table(4).p_value         := p_coordx;
    l_update_table(5).p_col_to_update := 'y_coordinate';
    l_update_table(5).p_value         := p_coordy;
    l_update_table(6).p_col_to_update := 'last_updated_by';
    l_update_table(6).p_value         := p_user_id;
    l_update_table(7).p_col_to_update := 'last_update_date';
    l_update_table(7).p_value         := fnd_date.date_to_canonical(p_last_update_date);
    l_update_table(8).p_col_to_update := 'last_update_login';
    l_update_table(8).p_value         := p_user_id;

    GMD_ROUTING_STEPS_PUB.update_routing_steps
                    ( p_api_version       => 1
                    , p_init_msg_list     => TRUE
                    , p_commit            => FALSE
                    , p_routingstep_id    => p_routingstep_id
                    , p_routingstep_no    => NULL
                    , p_routing_id        => l_step_rec.routing_id
                    , p_routing_no        => NULL
                    , p_routing_vers      => NULL
                    , p_update_table      => l_update_table
                    , x_message_count     => l_message_count
                    , x_message_list      => l_message_list
                    , x_return_status     => l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE UPDATE_STEP_EXCEPTION;
    END IF;

    EXCEPTION
      WHEN UPDATE_STEP_EXCEPTION THEN
        FND_MSG_PUB.GET( p_msg_index     => 1,
                         p_data          => l_message,
                         p_encoded       => 'F',
                         p_msg_index_out => l_dummy);

        x_return_code := 'F';
        x_error_msg   := l_message;

     WHEN RECORD_CHANGED_EXCEPTION THEN
        FND_MESSAGE.SET_NAME('FND', 'FND_RECORD_CHANGED_ERROR');
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

     WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

  END Update_Routing_Step;

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
 |     p_owner_orgn_id         IN  NUMBER
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
                                    x_error_msg             OUT NOCOPY VARCHAR2) IS


    CURSOR Cur_routing_id IS
    SELECT gem5_routing_id_s.NEXTVAL
    FROM   FND_DUAL;

    l_return_status           VARCHAR2(5);
    l_owner_orgn_id           VARCHAR2(4);
    l_timestamp               DATE;
    l_routing_no              VARCHAR2(32);
    l_enforce_step_dependency NUMBER;
    l_routing_rec             GMD_ROUTINGS%ROWTYPE;
    INSERT_ROUTING_EXCEPTION  EXCEPTION;

    l_message_count          NUMBER;
    l_message_list           VARCHAR2(2000);
    l_message                VARCHAR2(1000);
    l_dummy	             NUMBER;

  BEGIN

    x_return_code := FND_API.G_RET_STS_SUCCESS;
    x_error_msg   := FND_MESSAGE.GET;
    OPEN Cur_routing_id;
    FETCH Cur_routing_id INTO x_routing_id;
    CLOSE Cur_routing_id;

    IF p_enforce_step_dep IS NULL THEN
      l_enforce_step_dependency := FND_PROFILE.VALUE('GMD_ENFORCE_STEP_DEPENDENCY');
    ELSE
      l_enforce_step_dependency := p_enforce_step_dep;
    END IF;

    IF (l_enforce_step_dependency IS NULL) THEN
      l_enforce_step_dependency := 0;
    END IF;

    IF p_routing_no IS NOT NULL THEN
      l_routing_rec.routing_no             := p_routing_no;
      l_routing_rec.routing_vers           := p_routing_vers;
      l_routing_rec.routing_desc           := p_routing_desc;
    ELSE
      l_timestamp  := SYSDATE;
      --- Create a unique routing number. This is used to initialize the routing
      --- in the database. User will be prompted to enter a valid routing number
      --- prior to saving.

      l_routing_no := x_routing_id || '#' ||
                  TO_CHAR(l_timestamp, 'YYYYMMDDHH24MISS');
      l_routing_rec.routing_no             := l_routing_no;
      l_routing_rec.routing_vers           := 1;
      l_routing_rec.routing_desc           := 'New';
    END IF;

    l_routing_rec.routing_id               := x_routing_id;
    l_routing_rec.owner_organization_id    := p_owner_orgn_id;
    l_routing_rec.routing_class            := p_routing_class;
    l_routing_rec.routing_qty              := p_routing_qty;
    l_routing_rec.routing_uom                 := p_routing_uom;
    l_routing_rec.delete_mark              := 0;
    l_routing_rec.text_code                := NULL;
    l_routing_rec.inactive_ind             := 0;
    l_routing_rec.enforce_step_dependency  := l_enforce_step_dependency;
    l_routing_rec.contiguous_ind           := NVL(p_contiguous_ind, 0);
    l_routing_rec.in_use                   := 0;
    l_routing_rec.attribute1               := '';
    l_routing_rec.attribute2               := '';
    l_routing_rec.attribute3               := '';
    l_routing_rec.attribute4               := '';
    l_routing_rec.attribute5               := '';
    l_routing_rec.attribute6               := '';
    l_routing_rec.attribute7               := '';
    l_routing_rec.attribute8               := '';
    l_routing_rec.attribute9               := '';
    l_routing_rec.attribute10              := '';
    l_routing_rec.attribute11              := '';
    l_routing_rec.attribute12              := '';
    l_routing_rec.attribute13              := '';
    l_routing_rec.attribute14              := '';
    l_routing_rec.attribute15              := '';
    l_routing_rec.attribute16              := '';
    l_routing_rec.attribute17              := '';
    l_routing_rec.attribute18              := '';
    l_routing_rec.attribute19              := '';
    l_routing_rec.attribute20              := '';
    l_routing_rec.attribute21              := '';
    l_routing_rec.attribute22              := '';
    l_routing_rec.attribute23              := '';
    l_routing_rec.attribute24              := '';
    l_routing_rec.attribute25              := '';
    l_routing_rec.attribute26              := '';
    l_routing_rec.attribute27              := '';
    l_routing_rec.attribute28              := '';
    l_routing_rec.attribute29              := '';
    l_routing_rec.attribute30              := '';
    l_routing_rec.attribute_category       := '';
    l_routing_rec.effective_start_date     := p_effective_start_date;
    l_routing_rec.effective_end_date       := p_effective_end_date;
    l_routing_rec.owner_id                 := p_owner_id;
    l_routing_rec.project_id               := NULL;
    l_routing_rec.process_loss             := -1;
    l_routing_rec.routing_status           := '100';
    l_routing_rec.creation_date            := p_last_update_date;
    l_routing_rec.created_by               := p_user_id;
    l_routing_rec.last_update_date         := p_last_update_date;
    l_routing_rec.last_updated_by          := p_user_id;
    l_routing_rec.last_update_login        := p_user_id;

    GMD_ROUTINGS_PVT.insert_routing ( p_routings         => l_routing_rec
                                     , x_message_count   => l_message_count
                                     , x_message_list    => l_message_list
                                     , x_return_status   => l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE INSERT_ROUTING_EXCEPTION;
    END IF;

    EXCEPTION
      WHEN INSERT_ROUTING_EXCEPTION THEN
        FND_MSG_PUB.GET( p_msg_index     => 1,
                         p_data          => l_message,
                         p_encoded       => 'F',
                         p_msg_index_out => l_dummy);

        x_return_code := 'F';
        x_error_msg   := l_message;

      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

  END Create_Routing_Header;


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
                                       x_error_msg       OUT NOCOPY VARCHAR2) IS
    l_status    VARCHAR2(2);
    l_message   VARCHAR2(1000);
    l_dummy	NUMBER;

  BEGIN

    ---FND_GLOBAL.APPS_INITIALIZE(3713,52854, 552);

    gmdrtval_pub.generate_step_dependencies (p_routing_id,
                                             p_dependency_type,
                                             l_status);
    x_return_code := 'S';

    IF l_status <> 'S' THEN

      FND_MSG_PUB.GET( p_msg_index     => 1,
                       p_data          => l_message,
                       p_encoded       => 'F',
                       p_msg_index_out => l_dummy);

      x_return_code := 'F';
      x_error_msg   := l_message;

    END IF;

  END Generate_Step_Dependencies;


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
                                  x_error_msg          OUT NOCOPY VARCHAR2) IS

    l_return_status       VARCHAR2(2);
    l_message_count       NUMBER;
    l_message_list        VARCHAR2(2000);
    l_message             VARCHAR2(1000);
    l_dummy	          NUMBER;

    DELETE_STEP_EXCEPTION    EXCEPTION;
    RECORD_CHANGED_EXCEPTION EXCEPTION;

  BEGIN

    x_return_code := 'S';
    x_error_msg   := '';

    SELECT
      routingstep_id INTO l_dummy
    FROM
      fm_rout_dtl
    WHERE
     routing_id         = p_routing_id         AND
     routingstep_id     = p_routingstep_id     AND
     last_update_date   = p_last_update_date;

    IF SQL%NOTFOUND THEN
      RAISE RECORD_CHANGED_EXCEPTION;
    END IF;

    GMD_ROUTING_STEPS_PUB.delete_routing_step
                           ( p_api_version       => 1
                           , p_init_msg_list     => TRUE
                           , p_commit            => FALSE
                           , p_routingstep_id    => p_routingstep_id
                           , p_routingstep_no    => NULL
                           , p_routing_id        => p_routing_id
                           , p_routing_no        => NULL
                           , p_routing_vers      => NULL
                           , x_message_count     => l_message_count
                           , x_message_list      => l_message_list
                           , x_return_status     => l_return_status);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE DELETE_STEP_EXCEPTION;
    END IF;

    EXCEPTION
      WHEN DELETE_STEP_EXCEPTION THEN
        FND_MSG_PUB.GET( p_msg_index     => 1,
                         p_data          => l_message,
                         p_encoded       => 'F',
                         p_msg_index_out => l_dummy);

        x_return_code := 'F';
        x_error_msg   := l_message;

     WHEN RECORD_CHANGED_EXCEPTION THEN
        FND_MESSAGE.SET_NAME('FND', 'FND_RECORD_CHANGED_ERROR');
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;
     WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;
  END Delete_Routing_Step;

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
 |     p_routing_vers           NUMBER
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
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Copy_Routing ( p_copy_from_routing_id  IN  NUMBER,
                           p_routing_no            IN  VARCHAR2,
                           p_routing_vers          IN  NUMBER,
                           p_routing_desc          IN  VARCHAR2,
                           x_routing_id            OUT NOCOPY NUMBER,
                           x_return_code           OUT NOCOPY VARCHAR2,
                           x_error_msg             OUT NOCOPY VARCHAR2) IS

     CURSOR Cur_routing_id IS
       SELECT gem5_routing_id_s.NEXTVAL
       FROM   FND_DUAL;

     CURSOR Cur_get_hdr IS
       SELECT *
       FROM   gmd_routings
       WHERE  routing_id = p_copy_from_routing_id;

     CURSOR Cur_get_dtl IS
       SELECT *
       FROM   fm_rout_dtl
       WHERE  routing_id = p_copy_from_routing_id;

     CURSOR Cur_get_dep IS
       SELECT *
       FROM   fm_rout_dep
       WHERE  routing_id = p_copy_from_routing_id;

     CURSOR Get_Text (p_text_code NUMBER) IS
      SELECT *
      FROM fm_text_tbl
      WHERE text_code = p_text_code AND
            line_no <> -1;

     CURSOR Get_text_code IS
      SELECT gem5_text_code_s.NEXTVAL
      FROM   sys.dual;

     CURSOR Get_RoutingStepId IS
      SELECT gem5_routingstep_id_s.NEXTVAL
      FROM   sys.dual;

     TYPE detail_tab    IS TABLE OF Cur_get_dtl%ROWTYPE INDEX BY BINARY_INTEGER;
     TYPE dep_tab       IS TABLE OF Cur_get_dep%ROWTYPE INDEX BY BINARY_INTEGER;
     TYPE text_tab      IS TABLE OF Get_Text%ROWTYPE    INDEX BY BINARY_INTEGER;

     X_hdr_rec                  Cur_get_hdr%ROWTYPE;
     X_dtl_tbl                  detail_tab;
     X_dep_tbl                  dep_tab;
     l_dtl_text_tbl             text_tab;
     l_hdr_text_tbl             text_tab;
     l_row                      NUMBER := 0;
     l_txt_ind                  NUMBER;
     l_rowid	                VARCHAR2(32);
     l_text_code                NUMBER(10);
     l_error_msg                VARCHAR2(2000);
     l_return_code              VARCHAR2(2);
     l_table_lnk                VARCHAR2(80);
     l_routingstep_id           NUMBER(10);
     COPY_HEADER_TEXT_EXCEPTION EXCEPTION;

  BEGIN

    x_error_msg   := '';
    x_return_code := FND_API.G_RET_STS_SUCCESS;

    -- Load routing header
    OPEN Cur_get_hdr;
    FETCH Cur_get_hdr INTO X_hdr_rec;
    CLOSE Cur_get_hdr;

    -- Load routing header text

    IF (x_hdr_rec.text_code IS NOT NULL) THEN

      l_txt_ind := 0;

      FOR get_txt_rec IN Get_Text (x_hdr_rec.text_code) LOOP
        l_txt_ind := l_txt_ind + 1;
        l_hdr_text_tbl(l_txt_ind) := get_txt_rec;
      END LOOP;

    END IF;

    l_txt_ind := 0;

    -- Load routing details
    FOR get_rec IN Cur_get_dtl LOOP

      l_row := l_row + 1;
      X_dtl_tbl(l_row) := get_rec;

      IF (get_rec.text_code IS NOT NULL) THEN

        -- Load text for this step
        FOR get_txt_rec IN Get_Text (get_rec.text_code) LOOP
          l_txt_ind := l_txt_ind + 1;
          l_dtl_text_tbl(l_txt_ind) := get_txt_rec;
        END LOOP;

      END IF;

    END LOOP;

    l_row := 0;

    -- Load routing step dependencies
    FOR get_dep IN Cur_get_dep LOOP
      l_row := l_row + 1;
      X_dep_tbl(l_row) := get_dep;
    END LOOP;

    -- Do not commit pending changes to the original routing
    ROLLBACK;

    OPEN Cur_routing_id;
    FETCH Cur_routing_id INTO x_routing_id;
    CLOSE Cur_routing_id;

    l_text_code := NULL;

    IF (l_hdr_text_tbl.COUNT > 0) THEN

      OPEN  Get_Text_Code;
      FETCH Get_Text_Code INTO l_text_code;
      CLOSE Get_Text_Code;

      l_txt_ind := 0;

      FOR i IN 1..l_hdr_text_tbl.COUNT LOOP

        l_txt_ind := l_txt_ind + 1;
        l_table_lnk := 'gmd_routings' || '|' || x_routing_id;

        -- Create routing header text
        GMD_RECIPE_DESIGNER_PKG.Create_Text_Row
                        (p_text_code      => l_text_code,
                         p_lang_code      => l_hdr_text_tbl(l_txt_ind).lang_code,
                         p_text           => l_hdr_text_tbl(l_txt_ind).text,
                         p_line_no        => l_hdr_text_tbl(l_txt_ind).line_no,
                         p_paragraph_code => l_hdr_text_tbl(l_txt_ind).paragraph_code,
                         p_sub_paracode   => l_hdr_text_tbl(l_txt_ind).sub_paracode,
                         p_table_lnk      => l_table_lnk,
                         p_user_id        => g_created_by,
                         x_row_id         => l_rowid,
                         x_return_code    => l_return_code,
                         x_error_msg      => l_error_msg);

        IF (l_return_code <> 'S') THEN
          RAISE COPY_HEADER_TEXT_EXCEPTION;
        END IF;

      END LOOP;

    END IF;

    -- Insert routing header record

    GMD_ROUTINGS_PKG.INSERT_ROW(
    X_ROWID => l_rowid,
    X_ROUTING_ID => x_routing_id,
    X_OWNER_ORGANIZATION_ID => X_HDR_rec.owner_organization_id,
    X_ROUTING_NO => p_routing_no,
    X_ROUTING_VERS => p_routing_vers,
    X_ROUTING_CLASS => X_HDR_rec.ROUTING_CLASS,
    X_ROUTING_QTY => X_HDR_rec.ROUTING_QTY,
    X_ROUTING_UOM => X_HDR_rec.routing_uom,
    X_DELETE_MARK => 0,
    X_TEXT_CODE => l_text_code,
    X_INACTIVE_IND => 0,
    X_ENFORCE_STEP_DEPENDENCY => X_HDR_rec.ENFORCE_STEP_DEPENDENCY,
    X_CONTIGUOUS_IND => null,
    X_IN_USE => 0,
    X_ATTRIBUTE1 => X_HDR_rec.ATTRIBUTE1,
    X_ATTRIBUTE2 => X_HDR_rec.ATTRIBUTE2,
    X_ATTRIBUTE3 => X_HDR_rec.ATTRIBUTE3,
    X_ATTRIBUTE4 => X_HDR_rec.ATTRIBUTE4,
    X_ATTRIBUTE5 => X_HDR_rec.ATTRIBUTE5,
    X_ATTRIBUTE6 => X_HDR_rec.ATTRIBUTE6,
    X_ATTRIBUTE7 => X_HDR_rec.ATTRIBUTE7,
    X_ATTRIBUTE8 => X_HDR_rec.ATTRIBUTE8,
    X_ATTRIBUTE9 => X_HDR_rec.ATTRIBUTE9,
    X_ATTRIBUTE10 => X_HDR_rec.ATTRIBUTE10,
    X_ATTRIBUTE11 => X_HDR_rec.ATTRIBUTE11,
    X_ATTRIBUTE12 => X_HDR_rec.ATTRIBUTE12,
    X_ATTRIBUTE13 => X_HDR_rec.ATTRIBUTE13,
    X_ATTRIBUTE14 => X_HDR_rec.ATTRIBUTE14,
    X_ATTRIBUTE15 => X_HDR_rec.ATTRIBUTE15,
    X_ATTRIBUTE16 => X_HDR_rec.ATTRIBUTE16,
    X_ATTRIBUTE17 => X_HDR_rec.ATTRIBUTE17,
    X_ATTRIBUTE18 => X_HDR_rec.ATTRIBUTE18,
    X_ATTRIBUTE19 => X_HDR_rec.ATTRIBUTE19,
    X_ATTRIBUTE20 => X_HDR_rec.ATTRIBUTE20,
    X_ATTRIBUTE21 => X_HDR_rec.ATTRIBUTE21,
    X_ATTRIBUTE22 => X_HDR_rec.ATTRIBUTE22,
    X_ATTRIBUTE23 => X_HDR_rec.ATTRIBUTE23,
    X_ATTRIBUTE24 => X_HDR_rec.ATTRIBUTE24,
    X_ATTRIBUTE25 => X_HDR_rec.ATTRIBUTE25,
    X_ATTRIBUTE26 => X_HDR_rec.ATTRIBUTE26,
    X_ATTRIBUTE27 => X_HDR_rec.ATTRIBUTE27,
    X_ATTRIBUTE28 => X_HDR_rec.ATTRIBUTE28,
    X_ATTRIBUTE29 => X_HDR_rec.ATTRIBUTE29,
    X_ATTRIBUTE30 => X_HDR_rec.ATTRIBUTE30,
    X_ATTRIBUTE_CATEGORY => X_HDR_rec.ATTRIBUTE_CATEGORY,
    X_EFFECTIVE_START_DATE => X_HDR_rec.EFFECTIVE_START_DATE,
    X_EFFECTIVE_END_DATE => X_HDR_rec.EFFECTIVE_END_DATE,
    X_OWNER_ID => G_created_by,
    X_PROJECT_ID => X_HDR_rec.PROJECT_ID,
    X_PROCESS_LOSS => X_HDR_rec.PROCESS_LOSS,
    X_ROUTING_STATUS => 100,
    X_ROUTING_DESC => p_routing_desc,
    X_CREATION_DATE => SYSDATE,
    X_CREATED_BY => G_created_by,
    X_LAST_UPDATE_DATE => SYSDATE,
    X_LAST_UPDATED_BY => G_created_by,
    X_LAST_UPDATE_LOGIN => G_login_id);


    -- Insert routing detail records
    l_txt_ind := 1;

    FOR i IN 1..X_dtl_tbl.count LOOP

      l_text_code := NULL;
      OPEN  Get_RoutingStepId;
      FETCH Get_RoutingStepId INTO l_routingstep_id;
      CLOSE Get_RoutingStepId;

      IF (x_dtl_tbl(i).text_code > 0) THEN

        OPEN  Get_Text_Code;
        FETCH Get_Text_Code INTO l_text_code;
        CLOSE Get_Text_Code;

        l_table_lnk := 'fm_rout_dtl' || '|' || x_routing_id || '|' || l_routingstep_id;

        WHILE (l_txt_ind <= l_dtl_text_tbl.COUNT AND
               l_dtl_text_tbl(l_txt_ind).text_code  = x_dtl_tbl(i).text_code) LOOP

          -- Create routing step text
          GMD_RECIPE_DESIGNER_PKG.Create_Text_Row
                        (p_text_code      => l_text_code,
                         p_lang_code      => l_dtl_text_tbl(l_txt_ind).lang_code,
                         p_text           => l_dtl_text_tbl(l_txt_ind).text,
                         p_line_no        => l_dtl_text_tbl(l_txt_ind).line_no,
                         p_paragraph_code => l_dtl_text_tbl(l_txt_ind).paragraph_code,
                         p_sub_paracode   => l_dtl_text_tbl(l_txt_ind).sub_paracode,
                         p_table_lnk      => l_table_lnk,
                         p_user_id        => g_created_by,
                         x_row_id         => l_rowid,
                         x_return_code    => l_return_code,
                         x_error_msg      => l_error_msg);


          IF (l_return_code <> 'S') THEN
            RAISE COPY_HEADER_TEXT_EXCEPTION;
          END IF;

          l_txt_ind := l_txt_ind + 1;

        END LOOP;

      END IF;


      INSERT INTO fm_rout_dtl
               (routing_id, routingstep_no, routingstep_id, oprn_id,
                step_qty, steprelease_type,
                text_code, creation_date, created_by, last_update_login,
                last_update_date,
                last_updated_by, attribute1, attribute2, attribute3,
                attribute4, attribute5,
                attribute6, attribute7, attribute8, attribute9, attribute10,
                attribute11, attribute12, attribute13, attribute14, attribute15,
                attribute16, attribute17, attribute18, attribute19, attribute20,
                attribute21, attribute22, attribute23, attribute24, attribute25,
                attribute26, attribute27, attribute28, attribute29, attribute30,
                attribute_category, x_coordinate, y_coordinate)
      VALUES    (x_routing_id, X_dtl_tbl(i).routingstep_no,
                 l_routingstep_id,
                 X_dtl_tbl(i).oprn_id,
                 X_dtl_tbl(i).step_qty, X_dtl_tbl(i).steprelease_type,
                 l_text_code, SYSDATE, G_created_by,
                 G_login_id, SYSDATE, G_created_by,
                 X_dtl_tbl(i).attribute1, X_dtl_tbl(i).attribute2,
                 X_dtl_tbl(i).attribute3,
                 X_dtl_tbl(i).attribute4, X_dtl_tbl(i).attribute5,
                 X_dtl_tbl(i).attribute6,
                 X_dtl_tbl(i).attribute7, X_dtl_tbl(i).attribute8,
                 X_dtl_tbl(i).attribute9,
                 X_dtl_tbl(i).attribute10,
                 X_dtl_tbl(i).attribute11, X_dtl_tbl(i).attribute12,
                 X_dtl_tbl(i).attribute13,
                 X_dtl_tbl(i).attribute14, X_dtl_tbl(i).attribute15,
                 X_dtl_tbl(i).attribute16,
                 X_dtl_tbl(i).attribute17, X_dtl_tbl(i).attribute18,
                 X_dtl_tbl(i).attribute19,
                 X_dtl_tbl(i).attribute20, X_dtl_tbl(i).attribute21,
                 X_dtl_tbl(i).attribute22,
                 X_dtl_tbl(i).attribute23, X_dtl_tbl(i).attribute24,
                 X_dtl_tbl(i).attribute25, X_dtl_tbl(i).attribute26,
                 X_dtl_tbl(i).attribute27,
                 X_dtl_tbl(i).attribute28, X_dtl_tbl(i).attribute29,
                 X_dtl_tbl(i).attribute30,
                 X_dtl_tbl(i).attribute_category,
                 X_dtl_tbl(i).x_coordinate,
                 X_dtl_tbl(i).y_coordinate);
    END LOOP;

    -- Insert routing step dependencies records

    FOR i IN 1..X_dep_tbl.count LOOP

      INSERT INTO fm_rout_dep
                (ROUTINGSTEP_NO,
                 DEP_ROUTINGSTEP_NO,
                 ROUTING_ID,
                 DEP_TYPE,
                 REWORK_CODE,
                 STANDARD_DELAY,
                 MINIMUM_DELAY,
                 MAX_DELAY,
                 TRANSFER_QTY,
                 ROUTINGSTEP_NO_UOM,
                 TEXT_CODE,
                 LAST_UPDATED_BY,
                 CREATED_BY,
                 LAST_UPDATE_DATE,
                 CREATION_DATE,
                 LAST_UPDATE_LOGIN,
                 TRANSFER_PCT)
      VALUES    (X_dep_tbl(i).ROUTINGSTEP_NO,
                 X_dep_tbl(i).DEP_ROUTINGSTEP_NO,
                 x_routing_id,
                 X_dep_tbl(i).DEP_TYPE,
                 X_dep_tbl(i).REWORK_CODE,
                 X_dep_tbl(i).STANDARD_DELAY,
                 X_dep_tbl(i).MINIMUM_DELAY,
                 X_dep_tbl(i).MAX_DELAY,
                 X_dep_tbl(i).TRANSFER_QTY,
                 X_dep_tbl(i).ROUTINGSTEP_NO_UOM,
                 X_dep_tbl(i).TEXT_CODE,
                 G_created_by,
                 G_created_by,
                 SYSDATE,
                 SYSDATE,
                 G_login_id,
                 X_dep_tbl(i).TRANSFER_PCT);

    END LOOP;

    COMMIT;

    EXCEPTION
      WHEN COPY_HEADER_TEXT_EXCEPTION THEN
        x_return_code := 'F';
        x_error_msg   := l_error_msg;

      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

  END Copy_Routing;

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
                                 x_error_msg     OUT NOCOPY VARCHAR2) IS

    l_return BOOLEAN;

  BEGIN

    x_error_msg   := '';

    l_return := FND_PROFILE.Save_User(p_profile_name,
                                      p_profile_value);

    IF l_return THEN
      x_return_code := 'S';
    ELSE
      x_return_code := 'F';
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

  END Save_Profile_Value;

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
                                x_error_msg     OUT NOCOPY VARCHAR2) IS

  BEGIN

    x_error_msg   := '';
    x_return_code := 'S';

    x_profile_value := FND_PROFILE.VALUE(p_profile_name);


    IF x_profile_value IS NULL THEN
      x_return_code := 'F';
      x_error_msg   := 'Profile option ' || p_profile_name || ' not found.';
    ELSE
      x_return_code := 'S';
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

  END Get_Profile_Value;




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
                                       x_error_msg     OUT NOCOPY VARCHAR2) IS

    l_return_status      VARCHAR2(10);
    l_msg_count          NUMBER;
    l_msg_index          NUMBER;
    l_msg_data           VARCHAR2(240);

  BEGIN

    x_error_msg   := '';
    x_return_code := 'S';

    GMDRTVAL_PUB.Validate_Routing_Details(prouting_id     => p_routing_id,
                                          x_msg_count     => l_msg_count,
                                          x_msg_stack     => l_msg_data,
                                          x_return_status => l_return_status);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      FND_MSG_PUB.GET(p_msg_index        => 1,
                      p_data             => x_error_msg,
                      p_encoded          => 'F',
                      p_msg_index_out    => l_msg_index);
     x_return_code := 'F';
    END IF;


    EXCEPTION
      WHEN OTHERS THEN
        FND_MSG_PUB.GET(p_msg_index        => 1,
                        p_data             => x_error_msg,
                        p_encoded          => 'F',
                        p_msg_index_out    => l_msg_index);
        x_return_code := 'F';

  END Validate_Routing_Details;

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
                                        x_error_msg     OUT NOCOPY VARCHAR2) IS

    l_return_status      VARCHAR2(10);
    l_msg_count          NUMBER;
    l_msg_index          NUMBER;
    l_msg_data           VARCHAR2(240);

    UNEXPECTED_ERROR     EXCEPTION;
  BEGIN

    x_error_msg   := '';
    x_return_code := 'S';
    x_update_vr   := 'N';

    GMDRTVAL_PUB.Validate_Routing_VR_Dates(prouting_id     => p_routing_id,
                                           x_msg_count     => l_msg_count,
                                           x_msg_stack     => l_msg_data,
                                           x_return_status => l_return_status);

    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN

      FND_MSG_PUB.GET(p_msg_index        => 1,
                      p_data             => x_error_msg,
                      p_encoded          => 'F',
                      p_msg_index_out    => l_msg_index);

     x_update_vr   := 'Y';
    ELSE
     RAISE UNEXPECTED_ERROR;
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        FND_MSG_PUB.GET(p_msg_index        => 1,
                        p_data             => x_error_msg,
                        p_encoded          => 'F',
                        p_msg_index_out    => l_msg_index);
        x_return_code := 'F';
        x_update_vr   := 'F';

  END Validate_Routing_VR_Dates;

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
                                      x_error_msg     OUT NOCOPY VARCHAR2) IS

    l_return_status      VARCHAR2(10);
    l_msg_count          NUMBER;
    l_msg_index          NUMBER;
    l_msg_data           VARCHAR2(240);

    UNEXPECTED_ERROR     EXCEPTION;

  BEGIN

    x_error_msg   := '';
    x_return_code := 'S';

    GMDRTVAL_PUB.Update_VR_With_RT_Dates (prouting_id     => p_routing_id,
                                          x_msg_count     => l_msg_count,
                                          x_msg_stack     => l_msg_data,
                                          x_return_status => l_return_status);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE UNEXPECTED_ERROR;
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        FND_MSG_PUB.GET(p_msg_index        => 1,
                        p_data             => x_error_msg,
                        p_encoded          => 'F',
                        p_msg_index_out    => l_msg_index);
        x_return_code := 'F';

  END Update_VR_With_RT_Dates;


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
                                          x_error_msg        OUT NOCOPY VARCHAR2) IS

   -- Bug# 5206623 Kapil M
   -- Changed the cursor to fetch records from new R12 tables
    CURSOR Cur_uom_type (p_um_code VARCHAR2) IS
     SELECT UOM_CLASS
     FROM mtl_units_of_measure
     WHERE UOM_CODE =p_um_code;

    CURSOR Cur_Rtg_Class_Um IS
     SELECT ROUTING_CLASS_UOM
     FROM   gmd_routing_class
     WHERE  routing_class = p_routing_class;

    l_routing_class_um      VARCHAR2(4);
    l_routing_class_um_type VARCHAR2(10);
    l_routing_um_type       VARCHAR2(10);
    l_new_qty               NUMBER;
    UOM_TYPE_ERROR          EXCEPTION;

  BEGIN

    x_error_msg        := '';
    x_return_code      := 'S';
    x_theoretical_loss := -1;

    OPEN Cur_Rtg_Class_Um;
    FETCH Cur_Rtg_Class_Um INTO l_routing_class_um;
    CLOSE Cur_Rtg_Class_Um;


    IF (p_routing_class    IS NOT NULL AND
        l_routing_class_um IS NOT NULL AND
        p_routing_qty      IS NOT NULL AND
        p_routing_um       IS NOT NULL) THEN

      OPEN Cur_uom_type (l_routing_class_um);
      FETCH Cur_uom_type INTO l_routing_class_um_type;
      CLOSE Cur_uom_type;

      OPEN Cur_uom_type (p_routing_um);
      FETCH Cur_uom_type INTO l_routing_um_type;
      CLOSE Cur_uom_type;

      IF (l_routing_um_type = l_routing_class_um_type) THEN
        l_new_qty := INV_CONVERT.inv_um_convert(  item_id         => 0
                                                  ,precision      => 5
                                                  ,from_quantity  => p_routing_qty
                                                  ,from_unit      => p_routing_um
                                                  ,to_unit        => l_routing_class_um
                                                  ,from_name      => NULL
                                                ,to_name	  => NULL);
        /*GMICUOM.icuomcv(0,
                        0,
                        p_routing_qty,
                        p_routing_um,
                        l_routing_class_um,
                        l_new_qty);
         */

        x_theoretical_loss :=
         GMDRTVAL_PUB.Get_Theoretical_Process_Loss(p_routing_class,
                                                   l_new_qty);
      ELSE
        RAISE UOM_TYPE_ERROR;
      END IF;

    END IF;

    EXCEPTION
      WHEN UOM_TYPE_ERROR THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_RTG_CLS_VS_RTG_UM_TYPE');
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

  END Get_Theoretical_Process_Loss;


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
                             x_error_msg             OUT NOCOPY VARCHAR2) IS

    CURSOR Cur_get_routing IS
      SELECT *
      FROM   gmd_routings
      WHERE  routing_id       = p_routing_id AND
             last_update_date = p_last_update_date_orig;

    DELETE_ROUTING_EXCEPTION EXCEPTION;
    RECORD_CHANGED_EXCEPTION EXCEPTION;
    l_rec                    Cur_get_routing%ROWTYPE;
    l_return_status          VARCHAR2(2);
    l_message_count          NUMBER;
    l_message_list           VARCHAR2(2000);
    l_message                VARCHAR2(1000);
    l_dummy	             NUMBER;

  BEGIN

    x_error_msg   := '';
    x_return_code := FND_API.G_RET_STS_SUCCESS;


    OPEN Cur_get_routing;
    FETCH Cur_get_routing INTO l_rec;

    IF Cur_get_routing%NOTFOUND THEN
      CLOSE Cur_get_routing;
      RAISE RECORD_CHANGED_EXCEPTION;
    END IF;

    CLOSE Cur_get_routing;

    GMD_ROUTINGS_PUB.delete_routing
                         ( p_api_version     => 1
                         , p_init_msg_list   => TRUE
                         , p_commit          => TRUE
                         , p_routing_id      => p_routing_id
                         , p_routing_no      => NULL
                         , p_routing_vers    => NULL
                         , x_message_count   => l_message_count
                         , x_message_list    => l_message_list
                         , x_return_status   => l_return_status);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE DELETE_ROUTING_EXCEPTION;
    END IF;

    ---  This should be removed when the API does the commit
    COMMIT;

    EXCEPTION
      WHEN DELETE_ROUTING_EXCEPTION THEN
        FND_MSG_PUB.GET( p_msg_index     => 1,
                         p_data          => l_message,
                         p_encoded       => 'F',
                         p_msg_index_out => l_dummy);

        x_return_code := 'F';
        x_error_msg   := l_message;
     WHEN RECORD_CHANGED_EXCEPTION THEN
        FND_MESSAGE.SET_NAME('FND', 'FND_RECORD_CHANGED_ERROR');
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

     WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;


  END Delete_Routing;

/* Api start of comments
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
                               x_error_msg             OUT NOCOPY VARCHAR2) IS

    CURSOR Cur_get_routing IS
      SELECT *
      FROM   gmd_routings
      WHERE  routing_id       = p_routing_id AND
             last_update_date = p_last_update_date_orig;

    UNDELETE_ROUTING_EXCEPTION EXCEPTION;
    RECORD_CHANGED_EXCEPTION   EXCEPTION;
    l_rec                      Cur_get_routing%ROWTYPE;
    l_return_status            VARCHAR2(2);
    l_message_count            NUMBER;
    l_message_list             VARCHAR2(2000);
    l_message                  VARCHAR2(1000);
    l_dummy	               NUMBER;

  BEGIN

    x_error_msg   := '';
    x_return_code := FND_API.G_RET_STS_SUCCESS;

    OPEN Cur_get_routing;
    FETCH Cur_get_routing INTO l_rec;

    IF Cur_get_routing%NOTFOUND THEN
      CLOSE Cur_get_routing;
      RAISE RECORD_CHANGED_EXCEPTION;
    END IF;
    CLOSE Cur_get_routing;

    GMD_ROUTINGS_PUB.undelete_routing
                         ( p_api_version     => 1
                         , p_init_msg_list   => TRUE
                         , p_commit          => TRUE
                         , p_routing_id      => p_routing_id
                         , p_routing_no      => NULL
                         , p_routing_vers    => NULL
                         , x_message_count   => l_message_count
                         , x_message_list    => l_message_list
                         , x_return_status   => l_return_status);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE UNDELETE_ROUTING_EXCEPTION;
    END IF;

    ---  This should be removed when the API does the commit
    COMMIT;

    EXCEPTION
      WHEN UNDELETE_ROUTING_EXCEPTION THEN
        FND_MSG_PUB.GET( p_msg_index     => 1,
                         p_data          => l_message,
                         p_encoded       => 'F',
                         p_msg_index_out => l_dummy);

        x_return_code := 'F';
        x_error_msg   := l_message;
     WHEN RECORD_CHANGED_EXCEPTION THEN
        FND_MESSAGE.SET_NAME('FND', 'FND_RECORD_CHANGED_ERROR');
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

     WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;


  END Undelete_Routing;

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
 |      23-SEP-2004  S.Sriram  Created for Routing Security Build
 |
 +=============================================================================
 Api end of comments
 */
 PROCEDURE CHECK_ROUT_ORGN_ACCESS(p_routing_id         IN  NUMBER,
                                  x_return_code        OUT NOCOPY VARCHAR2) IS

   CURSOR Cur_get_rout_orgn IS
        SELECT owner_organization_id
        FROM   gmd_routings_b
        WHERE  routing_id = p_routing_id;

    l_orgn_id       NUMBER;
    l_return_status VARCHAR2(10);

  BEGIN

    OPEN Cur_get_rout_orgn;
    FETCH Cur_get_rout_orgn INTO l_orgn_id;
    CLOSE Cur_get_rout_orgn;


    IF (l_orgn_id IS NOT NULL) THEN
      IF (GMD_API_GRP.setup AND GMD_API_GRP.OrgnAccessible(l_orgn_id) ) THEN
        x_return_code := 'S';
      ELSE
        x_return_code := 'F';
      END IF;
    ELSE
      x_return_code := 'S';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
         x_return_code := FND_API.G_RET_STS_UNEXP_ERROR;

  END CHECK_ROUT_ORGN_ACCESS;


   /* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Get_Label_name
 |
 |   DESCRIPTION
 |      Get the value of the given profile option
 |
 |   INPUT PARAMETERS
 |     p_message_name   VARCHAR2(100)
 |   OUTPUT PARAMETERS
 |     x_message_text   VARCHAR2(240)
 |
 |   HISTORY
 |     18-JUL-2005 Shyam S   Created.
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Get_label_name (p_message_name  IN VARCHAR2
                           ,x_message_text  OUT NOCOPY VARCHAR2) IS

  BEGIN
    FND_MESSAGE.SET_NAME('GMD', p_message_name);
    x_message_text   := FND_MESSAGE.GET;
  END Get_label_name;



END GMD_ROUTING_DESIGNER_PKG;

/
