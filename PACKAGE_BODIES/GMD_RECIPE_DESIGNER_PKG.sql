--------------------------------------------------------
--  DDL for Package Body GMD_RECIPE_DESIGNER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_RECIPE_DESIGNER_PKG" AS
/* $Header: GMDRDMDB.pls 120.15.12010000.2 2008/11/12 18:44:56 rnalla ship $ */
/*============================================================================
 |                         Copyright (c) 2001 Oracle Corporation
 |                             Redwood Shores, California, USA
 |                                  All rights reserved
 =============================================================================
 |   FILENAME
 |      GMDRDMDB.pls
 |
 |   DESCRIPTION
 |      Package body containing the procedures used by the Recipe Designer
 |
 |
 |   NOTES
 |
 |   HISTORY
 |     03-JUL-2001 Eddie Oumerretane   Created.
 |     26-APR-2002 Eddie Oumerretane   BUG #2342591, added ROLLBACK in
 |                 Calculate_Step_Quantities after calculating charges.
 |     30-MAY-2002 Eddie Oumerretane   BUG #2396112, removed ROLLBACK in
 |                 Calculate_Step_Quantities after calculating charges.
 |     19-SEP-2002 Eddie Oumerretane. Enhancements related to implementation
 |                 of Rapid Recipe features.
 |     31-OCT-2003 Rajender Nalla. Bug 3157487 Added the gmd_formula_security_pkg.
 |                 insert_row, delete_row are added in create_recipe_header procedure
 |                 to add and delete the row with formula_id = -1.
 |     27-APR-2004 S.Sriram  Bug# 3408799
 |                 Added SET_DEFAULT_STATUS procedure for Default Status Build
 |     13-OCT-2004 Sriram.S  Recipe Security Bug# 3948203
 |                 Added a proc. to which checks if user has recipe orgn. access.
 |     15-OCT-2004 Thomas Daniel Bug# 3953359
 |                 Added code to set the default status appropriately in the copy
 |                 recipe procedure.
 |     22-Apr-2008 RLNAGARA Modified the proc Create_Recipe_Header for Fixed Process Loss ME
 =============================================================================
*/


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

  PROCEDURE Create_Text_Row ( p_text_code          IN  NUMBER,
                              p_lang_code          IN  VARCHAR2,
                              p_text               IN  VARCHAR2,
                              p_line_no            IN  NUMBER,
                              p_paragraph_code     IN  VARCHAR2,
                              p_sub_paracode       IN  NUMBER,
                              p_table_lnk          IN  VARCHAR2,
                              p_user_id            IN  NUMBER,
                              x_row_id             OUT NOCOPY VARCHAR2,
                              x_return_code        OUT NOCOPY VARCHAR2,
                              x_error_msg          OUT NOCOPY VARCHAR2) IS
    l_dummy NUMBER := 0;

  BEGIN

    x_return_code := 'S';
    x_error_msg   := '';


   IF (p_line_no = 1) THEN

     SELECT COUNT(*) INTO l_dummy
                     FROM fm_text_hdr WHERE text_code = p_text_code;

     IF SQL%NOTFOUND OR l_dummy = 0 THEN

       INSERT INTO fm_text_hdr ( text_code
                                ,last_update_date
                                ,last_updated_by
                                ,last_update_login
                                ,created_by
                                ,creation_date)
          VALUES (p_text_code,
                  sysdate,
                  p_user_id,
                  p_user_id,
                  p_user_id,
                  sysdate);
     END IF;

     INSERT INTO  fm_text_tbl_vl ( text_code
                                ,lang_code
                                ,paragraph_code
                                ,sub_paracode
                                ,line_no
                                ,text
                                ,last_update_date
                                ,last_updated_by
                                ,last_update_login
                                ,created_by
                                ,creation_date)
          VALUES (p_text_code,
                  p_lang_code,
                  p_paragraph_code,
                  p_sub_paracode,
                   -1,
                  p_table_lnk,
                  sysdate,
                  p_user_id,
                  p_user_id,
                  p_user_id,
                  sysdate);

   END IF;

   GMA_FM_TEXT_TBL_PKG.INSERT_ROW(
                            X_ROWID             => x_row_id,
                            X_TEXT_CODE         => p_text_code,
                            X_PARAGRAPH_CODE    => p_paragraph_code,
                            X_SUB_PARACODE      => p_sub_paracode,
                            X_LINE_NO           => p_line_no,
                            X_LANG_CODE         => p_lang_code,
                            X_TEXT              => p_text,
                            X_CREATION_DATE     => sysdate,
                            X_CREATED_BY        => p_user_id,
                            X_LAST_UPDATE_DATE  => sysdate,
                            X_LAST_UPDATED_BY   => p_user_id,
                            X_LAST_UPDATE_LOGIN => p_user_id);

    EXCEPTION
      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

  END Create_Text_Row;


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

  PROCEDURE Update_Text_Row ( p_text_code          IN  NUMBER,
                              p_lang_code          IN  VARCHAR2,
                              p_text               IN  VARCHAR2,
                              p_line_no            IN  NUMBER,
                              p_paragraph_code     IN  VARCHAR2,
                              p_sub_paracode       IN  NUMBER,
                              p_user_id            IN  NUMBER,
                              p_row_id             IN  VARCHAR2,
                              x_return_code        OUT NOCOPY VARCHAR2,
                              x_error_msg          OUT NOCOPY VARCHAR2) IS

  BEGIN

    x_return_code := 'S';
    x_error_msg   := '';

    GMA_FM_TEXT_TBL_PKG.UPDATE_ROW(
                             X_ROW_ID            => p_row_id,
                             X_TEXT_CODE         => p_text_code,
                             X_LANG_CODE         => p_lang_code,
                             X_PARAGRAPH_CODE    => p_paragraph_code,
                             X_SUB_PARACODE      => p_sub_paracode,
                             X_LINE_NO           => p_line_no,
                             X_TEXT              => p_text,
                             X_LAST_UPDATE_DATE  => sysdate,
                             X_LAST_UPDATED_BY   => p_user_id,
                             X_LAST_UPDATE_LOGIN => p_user_id);


    EXCEPTION
      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

  END Update_Text_Row;

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

  PROCEDURE Delete_Text_Row ( p_text_code          IN  NUMBER,
                              p_lang_code          IN  VARCHAR2,
                              p_paragraph_code     IN  VARCHAR2,
                              p_sub_paracode       IN  NUMBER,
                              p_line_no            IN  NUMBER,
                              p_row_id             IN  VARCHAR2,
                              x_return_code        OUT NOCOPY VARCHAR2,
                              x_error_msg          OUT NOCOPY VARCHAR2) IS

  BEGIN

    x_return_code := 'S';
    x_error_msg   := '';

    GMA_FM_TEXT_TBL_PKG.DELETE_ROW(
                             X_TEXT_CODE         => p_text_code,
                             X_LANG_CODE         => p_lang_code,
                             X_PARAGRAPH_CODE    => p_paragraph_code,
                             X_SUB_PARACODE      => p_sub_paracode,
                             X_LINE_NO           => p_line_no,
                             X_ROW_ID            => p_row_id);


    EXCEPTION
      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

  END Delete_Text_Row;

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
                                             x_error_msg          OUT NOCOPY  VARCHAR2) IS

     l_text_code NUMBER;

  BEGIN

     x_return_code := 'S';
     x_error_msg   := '';

     IF p_text_code <= 0 THEN
       l_text_code := NULL;
     ELSE
       l_text_code := p_text_code;
     END IF;

     UPDATE
       GMD_RECIPE_ROUTING_STEPS
     SET
          STEP_QTY          = p_step_qty,
          TEXT_CODE         = l_text_code,
          LAST_UPDATED_BY   = p_user_id,
          LAST_UPDATE_DATE  = p_last_update_date,
          LAST_UPDATE_LOGIN = p_user_id,
          MASS_QTY          = p_mass_qty,
          MASS_REF_UOM      = p_mass_uom,
          VOLUME_QTY        = p_vol_qty,
          VOLUME_REF_UOM    = p_vol_uom
     WHERE
          RECIPE_ID         = p_recipe_id      AND
          ROUTINGSTEP_ID    = p_routingstep_id AND
          LAST_UPDATE_DATE  = p_last_update_date_origin;


    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('FND', 'FND_RECORD_CHANGED_ERROR');
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

  END Update_Recipe_Routing_Step_Row;

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
 |     10-JUL-2001 Eddie Oumerretane   Created.
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
                                             x_error_msg          OUT NOCOPY  VARCHAR2) IS

  BEGIN

     x_return_code := 'S';
     x_error_msg   := '';

     INSERT INTO  gmd_recipe_routing_steps
          (RECIPE_ID
          ,ROUTINGSTEP_ID
          ,STEP_QTY
          ,CREATED_BY
          ,CREATION_DATE
          ,LAST_UPDATED_BY
          ,LAST_UPDATE_DATE
          ,LAST_UPDATE_LOGIN
          ,TEXT_CODE
          ,MASS_QTY
          ,MASS_REF_UOM
          ,VOLUME_QTY
          ,VOLUME_REF_UOM)
     VALUES
          (p_recipe_id,
           p_routingstep_id,
           p_step_qty,
           p_user_id,
           p_last_update_date,
           p_user_id,
           p_last_update_date,
           p_user_id,
           p_text_code,
           p_mass_qty,
           p_mass_uom,
           p_vol_qty,
           p_vol_uom);

    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        FND_MESSAGE.SET_NAME('FND', 'FND_RECORD_CHANGED_ERROR');
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

  END Create_Recipe_Routing_Step_Row;

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

  PROCEDURE Create_Step_Material_Link ( p_recipe_id         IN  NUMBER,
                                        p_formulaline_id    IN  NUMBER,
                                        p_routingstep_id    IN  NUMBER,
                                        p_text_code         IN  NUMBER,
                                        p_user_id           IN  NUMBER,
                                        p_last_update_date  IN  DATE,
                                        x_return_code       OUT NOCOPY VARCHAR2,
                                        x_error_msg         OUT NOCOPY VARCHAR2) IS


  BEGIN

    x_return_code := 'S';
    x_error_msg   := '';


    INSERT INTO gmd_recipe_step_materials (
                             recipe_id
                            ,formulaline_id
                            ,routingstep_id
                            ,text_code
                            ,creation_date
                            ,created_by
                            ,last_update_date
                            ,last_updated_by
                            ,last_update_login)
    VALUES ( p_recipe_id
            ,p_formulaline_id
            ,p_routingstep_id
            ,p_text_code
            ,p_last_update_date
            ,p_user_id
            ,p_last_update_date
            ,p_user_id
            ,p_user_id);


    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        FND_MESSAGE.SET_NAME('FND', 'FND_RECORD_CHANGED_ERROR');
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

  END Create_Step_Material_Link;


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
                                        x_error_msg                   OUT NOCOPY  VARCHAR2) IS

/*
  CURSOR Get_Step (c_recipe_id NUMBER, c_formulaline_id NUMBER, routingstep_id NUMBER) IS
   SELECT
     last_update_date
   FROM
     gmd_recipe_step_materials
   WHERE
     recipe_id      = c_recipe_id AND
     formulaline_id = c_formulaline_id AND
     routingstep_id = routingstep_id;
*/
---l_last_update_date DATE;

  BEGIN

    x_return_code := 'S';
    x_error_msg   := '';


    DELETE
       gmd_recipe_step_materials
    WHERE
       recipe_id        = p_recipe_id      AND
       formulaline_id   = p_formulaline_id AND
       routingstep_id   = p_routingstep_id AND
       last_update_date = p_last_update_date_origin;

---    OPEN Get_Step(p_recipe_id, p_formulaline_id, p_routingstep_id);
---    FETCH Get_Step INTO l_last_update_date;

---    IF Get_Step%FOUND THEN
---      CLOSE Get_Step;
---    END IF;

---    CLOSE Get_Step;


    IF SQL%NOTFOUND THEN
        FND_MESSAGE.SET_NAME('FND', 'FND_RECORD_CHANGED_ERROR');
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

  END Delete_Step_Material_Link;


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

  PROCEDURE Update_Step_Material_Link ( p_recipe_id                 IN  NUMBER,
                                        p_formulaline_id            IN  NUMBER,
                                        p_routingstep_id            IN  NUMBER,
                                        p_text_code                 IN  NUMBER,
                                        p_last_update_date          IN  DATE,
                                        p_last_update_date_origin   IN  DATE,
                                        p_user_id                   IN  NUMBER,
                                        x_return_code               OUT NOCOPY  VARCHAR2,
                                        x_error_msg                 OUT NOCOPY  VARCHAR2) IS

  BEGIN

    x_return_code := 'S';
    x_error_msg   := '';


    UPDATE
       gmd_recipe_step_materials
    SET
       text_code         = p_text_code,
       last_update_date  = p_last_update_date,
       last_updated_by   = p_user_id,
       last_update_login = p_user_id
    WHERE
       recipe_id        = p_recipe_id      AND
       formulaline_id   = p_formulaline_id AND
       routingstep_id   = p_routingstep_id AND
       last_update_date = p_last_update_date_origin;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('FND', 'FND_RECORD_CHANGED_ERROR');
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

  END Update_Step_Material_Link;


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

  PROCEDURE Calculate_Step_Quantities ( p_recipe_id     IN  NUMBER,
                                        p_user_id       IN  NUMBER,
                                        x_quantities    OUT NOCOPY VARCHAR2,
                                        x_return_code   OUT NOCOPY VARCHAR2,
                                        x_error_msg     OUT NOCOPY VARCHAR2) IS

   CURSOR Get_RoutingId IS
      SELECT routing_id, planned_process_loss, owner_organization_id
      FROM gmd_recipes_b
      WHERE recipe_id = p_recipe_id;

   l_routing_id        NUMBER(10) := 0;
   l_charge_tbl        GMD_COMMON_VAL.charge_tbl;

   l_step_tbl          GMD_AUTO_STEP_CALC.step_rec_tbl;
   l_msg_count         NUMBER(10);
   l_return_status     VARCHAR2(10);
   l_msg_stack         VARCHAR2(1000);
   l_message           VARCHAR2(2000);
   l_temp              NUMBER;

   l_routingstep_id    NUMBER := -1;
   l_found_charge      BOOLEAN;
   l_planned_process_loss       NUMBER;
   l_organization_id   NUMBER;

   STEP_QTY_ERROR      EXCEPTION;


   FUNCTION Get_Routing_StepId (p_step_no    NUMBER,
                                p_routing_id NUMBER) RETURN NUMBER IS

     CURSOR Get_RoutingStepId IS
       SELECT
         ROUTINGSTEP_ID,
         ROUTINGSTEP_NO
       FROM
         FM_ROUT_DTL
       WHERE
         routing_id = p_routing_id;

   BEGIN

     IF NOT G_ROUTINGSTEP_ID.EXISTS(1) THEN

      OPEN Get_RoutingStepId;

      FETCH
        Get_RoutingStepId
      BULK COLLECT INTO
        G_ROUTINGSTEP_ID,
        G_ROUTINGSTEP_NO;

      CLOSE Get_RoutingStepId;

     END IF;

     FOR i IN 1.. G_ROUTINGSTEP_ID.COUNT LOOP

       IF G_ROUTINGSTEP_NO(i) = p_step_no THEN
         l_routingstep_id := G_ROUTINGSTEP_ID(i);
         EXIT;
       END IF;

     END LOOP;

     RETURN l_routingstep_id;

   END Get_Routing_StepId;


   PROCEDURE Update_Step_Qty (p_routingstep_id NUMBER,
                              p_ind            NUMBER) IS

   BEGIN

     UPDATE
       GMD_RECIPE_ROUTING_STEPS
     SET
         STEP_QTY   =  l_step_tbl(p_ind).step_qty,
         MASS_QTY   =  l_step_tbl(p_ind).step_mass_qty,
         VOLUME_QTY =  l_step_tbl(p_ind).step_vol_qty
     WHERE
          RECIPE_ID         = p_recipe_id      AND
          ROUTINGSTEP_ID    = p_routingstep_id;


     IF SQL%NOTFOUND THEN

       INSERT INTO  gmd_recipe_routing_steps
          (RECIPE_ID
          ,ROUTINGSTEP_ID
          ,STEP_QTY
          ,CREATED_BY
          ,CREATION_DATE
          ,LAST_UPDATED_BY
          ,LAST_UPDATE_DATE
          ,LAST_UPDATE_LOGIN
          ,TEXT_CODE
          ,MASS_QTY
          ,MASS_REF_UOM
          ,VOLUME_QTY
          ,VOLUME_REF_UOM)
      VALUES
          (p_recipe_id,
           l_routingstep_id,
           l_step_tbl(p_ind).step_qty,
           p_user_id,
           SYSDATE,
           p_user_id,
           SYSDATE,
           p_user_id,
           0,
           l_step_tbl(p_ind).step_mass_qty,
           l_step_tbl(p_ind).step_mass_uom,
           l_step_tbl(p_ind).step_vol_qty,
           l_step_tbl(p_ind).step_vol_uom);

     END IF;

   END Update_Step_Qty;

  BEGIN

    x_return_code := 'S';
    x_error_msg   := '';

    /* Bug 3609776 - Thomas Daniel */
    /* Added process loss to the cursor */
    OPEN Get_RoutingId;
    FETCH Get_RoutingId INTO l_routing_id, l_planned_process_loss, l_organization_id;
    CLOSE Get_RoutingId;

    /* Bug 3609776 - Thomas Daniel */
    /* Added parameters ignore mass volume conv and process loss to the auto step calc call*/
    GMD_AUTO_STEP_CALC.calc_step_qty (
                              P_parent_id         => p_recipe_id,
                              P_step_tbl          => l_step_tbl,
                              P_msg_count         => l_msg_count,
                              P_msg_stack         => l_msg_stack,
                              P_return_status     => l_return_status,
                              p_ignore_mass_conv  => TRUE,
                              p_ignore_vol_conv   => TRUE,
                              p_process_loss      => l_planned_process_loss,
                              p_organization_id   => l_organization_id);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE STEP_QTY_ERROR;
    END IF;


    --- Update Step Quantities. This is necessary because the
    --- charge calculation engine, gets the step quantities from the database

    FOR i IN 1.. l_step_tbl.COUNT LOOP

      l_routingstep_id :=  Get_Routing_StepId(l_step_tbl(i).step_no, l_routing_id);
      Update_Step_Qty (l_routingstep_id, i);

    END LOOP;

    GMD_COMMON_VAL.Calculate_Charges(batch_id        => 0,
                                     recipe_id       => p_recipe_id,
                                     routing_id      => l_routing_id,
                                     VR_qty          => 0,
                                     Tolerance       => 0,
                                     orgn_id         => NULL,
                                     x_charge_tbl    => l_charge_tbl,
                                     x_return_status => l_return_status);

    IF l_step_tbl.COUNT > 0 THEN

      l_step_tbl(1).step_vol_qty  := NVL(l_step_tbl(1).step_vol_qty, -1);
      l_step_tbl(1).step_vol_uom  := NVL(l_step_tbl(1).step_vol_uom, ' ');
      l_step_tbl(1).step_mass_qty := NVL(l_step_tbl(1).step_mass_qty, -1);
      l_step_tbl(1).step_mass_uom := NVL(l_step_tbl(1).step_mass_uom, ' ');

      x_quantities := l_step_tbl.COUNT            || '//' ||
                      l_step_tbl(1).step_no       || '//' ||
                      l_step_tbl(1).step_qty      || '//' ||
                      l_step_tbl(1).step_mass_qty || '//' ||
                      l_step_tbl(1).step_mass_uom || '//' ||
                      l_step_tbl(1).step_vol_qty  || '//' ||
                      l_step_tbl(1).step_vol_uom;

      l_found_charge := FALSE;

      FOR i IN 1..l_charge_tbl.COUNT LOOP

       IF Get_Routing_StepId(l_step_tbl(1).step_no, l_routing_id) = l_charge_tbl(i).routingstep_id THEN

         IF l_charge_tbl(i).charge IS NULL THEN
          l_charge_tbl(i).charge := 1;
         END IF;

         IF l_charge_tbl(i).max_capacity IS NULL THEN
          l_charge_tbl(i).max_capacity := -1;
         END IF;

         IF l_charge_tbl(i).capacity_uom IS NULL THEN
          l_charge_tbl(i).capacity_uom := ' ';
         END IF;

         x_quantities := x_quantities                   || '//' ||
                         l_charge_tbl(i).charge         || '//' ||
                         l_charge_tbl(i).max_capacity   || '//' ||
                         l_charge_tbl(i).capacity_uom;

         l_found_charge := TRUE;

         EXIT;

       END IF;

     END LOOP;

     -- Should never occur .... but just in case !
     IF NOT l_found_charge THEN

       x_quantities := x_quantities || '//' ||
                       1            || '//' ||
                       -1           || '//' ||
                       '  ';

     END IF;

    END IF;

    FOR i IN 2.. l_step_tbl.COUNT LOOP

     l_step_tbl(i).step_vol_qty  := NVL(l_step_tbl(i).step_vol_qty, -1);
     l_step_tbl(i).step_vol_uom  := NVL(l_step_tbl(i).step_vol_uom, ' ');
     l_step_tbl(i).step_mass_qty := NVL(l_step_tbl(i).step_mass_qty, -1);
     l_step_tbl(i).step_mass_uom := NVL(l_step_tbl(i).step_mass_uom, ' ');

     x_quantities := x_quantities                || '//' ||
                     l_step_tbl(i).step_no       || '//' ||
                     l_step_tbl(i).step_qty      || '//' ||
                     l_step_tbl(i).step_mass_qty || '//' ||
                     l_step_tbl(i).step_mass_uom || '//' ||
                     l_step_tbl(i).step_vol_qty  || '//' ||
                     l_step_tbl(i).step_vol_uom;

     l_found_charge := FALSE;

     FOR j IN 1..l_charge_tbl.COUNT LOOP

       IF Get_Routing_StepId(l_step_tbl(i).step_no, l_routing_id) = l_charge_tbl(j).routingstep_id THEN

         IF l_charge_tbl(j).charge IS NULL THEN
          l_charge_tbl(j).charge := 1;
         END IF;

         IF l_charge_tbl(j).max_capacity IS NULL THEN
          l_charge_tbl(j).max_capacity := -1;
         END IF;

         IF l_charge_tbl(j).capacity_uom IS NULL THEN
          l_charge_tbl(j).capacity_uom := ' ';
         END IF;

         x_quantities := x_quantities                   || '//' ||
                         l_charge_tbl(j).charge         || '//' ||
                         l_charge_tbl(j).max_capacity   || '//' ||
                         l_charge_tbl(j).capacity_uom;

         l_found_charge := TRUE;

         EXIT;

       END IF;

     END LOOP;

     -- Should never occur .... but just in case !
     IF NOT l_found_charge THEN

       x_quantities := x_quantities || '//' ||
                       1            || '//' ||
                       -1           || '//' ||
                       '  ';

     END IF;

    END LOOP;

    l_charge_tbl.DELETE;


    EXCEPTION
      WHEN STEP_QTY_ERROR THEN
        x_return_code := 'F';
        FND_MSG_PUB.GET(p_msg_index        => 1,
                        p_data             => l_message,
                        p_encoded          => 'F',
                        p_msg_index_out    => l_temp);
        x_error_msg   := l_message;

      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

  END Calculate_Step_Quantities;

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
                                     x_error_msg       OUT NOCOPY VARCHAR2) IS

    l_charge_tbl        GMD_COMMON_VAL.charge_tbl;
    l_step_tbl          GMD_AUTO_STEP_CALC.step_rec_tbl;
    l_return_code       VARCHAR2(1);
    l_message           VARCHAR2(2000);
    l_temp              NUMBER;

  BEGIN

    x_return_code := 'S';
    x_error_msg   := '';

    l_step_tbl(1).step_id      := p_routingstep_id;
    l_step_tbl(1).step_qty     := p_step_qty;
    l_step_tbl(1).step_qty_uom := p_step_um;

    GMD_COMMON_VAL.Calculate_Step_Charges (p_recipe_id       => p_recipe_id
                                          ,p_tolerance       => 0
                                          ,p_orgn_id         => NULL
                                          ,p_step_tbl        => l_step_tbl
                                          ,x_charge_tbl      => l_charge_tbl
                                          ,x_return_status   => l_return_code);

    IF l_charge_tbl.EXISTS(1) THEN

      IF l_charge_tbl(1).charge IS NULL THEN
        l_charge_tbl(1).charge := 1;
      END IF;

      IF l_charge_tbl(1).max_capacity IS NULL THEN
        l_charge_tbl(1).max_capacity := -1;
      END IF;

      IF l_charge_tbl(1).capacity_uom IS NULL THEN
        l_charge_tbl(1).capacity_uom := ' ';
      END IF;

      x_charges_info :=  l_charge_tbl(1).charge       || '//' ||
                         l_charge_tbl(1).max_capacity || '//' ||
                         l_charge_tbl(1).capacity_uom;
    ELSE
      x_charges_info := '1' || '//' || '-1' || '//' || ' ';
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

  END Calculate_Step_Charges;


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

  PROCEDURE Get_Recipe_Mode ( p_recipe_id        IN  NUMBER,
                              x_recipe_mode      OUT NOCOPY VARCHAR2,
                              x_return_code      OUT NOCOPY VARCHAR2,
                              x_error_msg        OUT NOCOPY VARCHAR2) IS

    l_return_code       VARCHAR2(1);
    l_status            VARCHAR2(30);

  BEGIN

    x_return_code := 'S';
    x_error_msg   := '';
    x_recipe_mode := 'Q';

    IF GMD_COMMON_VAL.Update_Allowed(entity    => 'RECIPE',
                                     entity_id => p_recipe_id) AND
       GMD_API_GRP.check_Orgn_Access(entity    => 'RECIPE',
                                     entity_id => p_recipe_id) THEN
        x_recipe_mode := 'U';

    END IF;

  END Get_Recipe_Mode;

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
  PROCEDURE Calculate_Charges ( p_recipe_id        IN  NUMBER,
                                x_charges_info     OUT NOCOPY VARCHAR2,
                                x_return_code      OUT NOCOPY VARCHAR2,
                                x_error_msg        OUT NOCOPY VARCHAR2) IS

    CURSOR Get_RoutingId IS
      SELECT
       routing_id
      FROM
       gmd_recipes
      WHERE
       recipe_id = p_recipe_id;

    l_charge_tbl        GMD_COMMON_VAL.charge_tbl;
    l_return_code       VARCHAR2(1);
    l_routing_id        NUMBER(10) := 0;

  BEGIN

    x_return_code := 'S';

    x_error_msg   := '';

    OPEN Get_RoutingId;
    FETCH Get_RoutingId INTO l_routing_id;
    CLOSE Get_RoutingId;

    GMD_COMMON_VAL.Calculate_Charges(batch_id        => 0,
                                     recipe_id       => p_recipe_id,
                                     routing_id      => l_routing_id,
                                     VR_qty          => 0,
                                     Tolerance       => 0,
                                     orgn_id         => NULL,
                                     x_charge_tbl    => l_charge_tbl,
                                     x_return_status => x_return_code);

    IF l_charge_tbl.EXISTS(1) THEN

      IF l_charge_tbl.COUNT > 0 THEN

       IF l_charge_tbl(1).charge IS NULL THEN
         l_charge_tbl(1).charge := 1;
       END IF;

       IF l_charge_tbl(1).max_capacity IS NULL THEN
         l_charge_tbl(1).max_capacity := -1;
       END IF;

       IF l_charge_tbl(1).capacity_uom IS NULL THEN
         l_charge_tbl(1).capacity_uom := ' ';
       END IF;

       x_charges_info :=  l_charge_tbl(1).routingstep_id       || '//' ||
                          l_charge_tbl(1).charge               || '//' ||
                          l_charge_tbl(1).max_capacity         || '//' ||
                          l_charge_tbl(1).capacity_uom;


       FOR i IN 2.. l_charge_tbl.COUNT LOOP

         IF l_charge_tbl(i).charge IS NULL THEN
           l_charge_tbl(i).charge := 1;
         END IF;

         IF l_charge_tbl(i).max_capacity IS NULL THEN
           l_charge_tbl(i).max_capacity := -1;
         END IF;

         IF l_charge_tbl(i).capacity_uom IS NULL THEN
           l_charge_tbl(i).capacity_uom := ' ';
         END IF;

         x_charges_info := x_charges_info                       || '//' ||
                           l_charge_tbl(i).routingstep_id       || '//' ||
                           l_charge_tbl(i).charge               || '//' ||
                           l_charge_tbl(i).max_capacity         || '//' ||
                           l_charge_tbl(i).capacity_uom;
       END LOOP;

      END IF;

    END IF;

  END Calculate_Charges;

/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Update_Step_Quantities
 |
 |   DESCRIPTION
 |      Update step quantities table
 |
 |   INPUT PARAMETERS
 |     p_recipe_id                 NUMBER
 |     p_ruting_id                 NUMBER
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
  PROCEDURE Update_Step_Quantities ( p_recipe_id        IN  NUMBER,
                                     p_routing_id       IN  NUMBER,
                                     p_user_id          IN  NUMBER,
                                     p_last_update_date IN  DATE,
                                     x_return_code      OUT NOCOPY VARCHAR2,
                                     x_error_msg        OUT NOCOPY VARCHAR2) IS

     CURSOR Get_Step_Id (c_routing_id NUMBER, c_routingstep_no NUMBER) IS
       SELECT
          routingstep_id
       FROM
          fm_rout_dtl
       WHERE
          routing_id     = c_routing_id AND
          routingstep_no = c_routingstep_no;

    l_step_tbl          GMD_AUTO_STEP_CALC.step_rec_tbl;
    l_routingstep_id    NUMBER(10);
    l_msg_count         NUMBER(10);
    l_return_status     VARCHAR2(10);
    l_msg_stack         VARCHAR2(1000);
    l_message           VARCHAR2(100);
    l_temp              NUMBER;
    l_step_no           NUMBER(10);
    l_step_qty          NUMBER;
    l_mass_qty          NUMBER;
    l_vol_qty           NUMBER;
    l_mass_uom          VARCHAR2(4);
    l_vol_uom           VARCHAR2(4);

    STEP_QTY_ERROR              EXCEPTION;
    ROUTING_STEP_ID_NOT_FOUND   EXCEPTION;

  BEGIN

    x_return_code := 'S';
    x_error_msg   := '';

    GMD_AUTO_STEP_CALC.Check_Step_Qty_Calculatable (
                              P_parent_id         => p_recipe_id,
                              P_msg_count         => l_msg_count,
                              P_msg_stack         => l_msg_stack,
                              P_return_status     => l_return_status);

    IF (l_return_status <> 'S') THEN
      RAISE STEP_QTY_ERROR;
    END IF;

    GMD_AUTO_STEP_CALC.calc_step_qty (
                              P_parent_id         => p_recipe_id,
                              P_step_tbl          => l_step_tbl,
                              P_msg_count         => l_msg_count,
                              P_msg_stack         => l_msg_stack,
                              P_return_status     => l_return_status);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE STEP_QTY_ERROR;
    END IF;

    FOR i IN 1.. l_step_tbl.COUNT LOOP

       l_step_no   := l_step_tbl(i).step_no;
       l_step_qty  := l_step_tbl(i).step_qty;
       l_mass_qty  := l_step_tbl(i).step_mass_qty;
       l_mass_uom  := l_step_tbl(i).step_mass_uom;
       l_vol_qty   := l_step_tbl(i).step_vol_qty;
       l_vol_uom   := l_step_tbl(i).step_vol_uom;

       OPEN Get_Step_Id(p_routing_id, l_step_no);
       FETCH Get_Step_Id INTO l_routingstep_id;

       IF Get_Step_Id%NOTFOUND THEN
         CLOSE Get_Step_Id;
         RAISE ROUTING_STEP_ID_NOT_FOUND;
       END IF;

       CLOSE Get_Step_Id;

       UPDATE
         gmd_recipe_routing_steps
       SET
          STEP_QTY          = l_step_qty,
          LAST_UPDATED_BY   = p_user_id,
          LAST_UPDATE_DATE  = p_last_update_date,
          LAST_UPDATE_LOGIN = p_user_id,
          MASS_QTY          = l_mass_qty,
          MASS_REF_UOM      = l_mass_uom,
          VOLUME_QTY        = l_vol_qty,
          VOLUME_REF_UOM    = l_vol_uom
       WHERE
          RECIPE_ID         = p_recipe_id      AND
          ROUTINGSTEP_ID    = l_routingstep_id AND
          LAST_UPDATE_DATE  = p_last_update_date;

    END LOOP;


    EXCEPTION

      WHEN NO_DATA_FOUND THEN

       INSERT INTO  gmd_recipe_routing_steps
          (RECIPE_ID
          ,ROUTINGSTEP_ID
          ,STEP_QTY
          ,CREATED_BY
          ,CREATION_DATE
          ,LAST_UPDATED_BY
          ,LAST_UPDATE_DATE
          ,LAST_UPDATE_LOGIN
          ,TEXT_CODE
          ,MASS_QTY
          ,MASS_REF_UOM
          ,VOLUME_QTY
          ,VOLUME_REF_UOM)
      VALUES
          (p_recipe_id,
           l_routingstep_id,
           l_step_qty,
           p_user_id,
           p_last_update_date,
           p_user_id,
           p_last_update_date,
           p_user_id,
           0,
           l_mass_qty,
           l_mass_uom,
           l_vol_qty,
           l_vol_uom);


      WHEN STEP_QTY_ERROR THEN
        x_return_code := 'F';
        FND_MSG_PUB.GET(p_msg_index        => 1,
                        p_data             => l_message,
                        p_encoded          => 'F',
                        p_msg_index_out    => l_temp);
        FND_MESSAGE.SET_NAME('GMD', l_message);
        x_error_msg   := FND_MESSAGE.GET;

      WHEN ROUTING_STEP_ID_NOT_FOUND THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

      WHEN DUP_VAL_ON_INDEX THEN
        FND_MESSAGE.SET_NAME('FND', 'FND_RECORD_CHANGED_ERROR');
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

  END Update_Step_Quantities;
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

  PROCEDURE Delete_Recipe_Step_Quantities ( p_recipe_id    IN  NUMBER,
                                            x_return_code  OUT NOCOPY VARCHAR2,
                                            x_error_msg    OUT NOCOPY VARCHAR2) IS

  BEGIN

    x_return_code := 'S';
    x_error_msg   := '';


    DELETE FROM
     GMD_RECIPE_ROUTING_STEPS
    WHERE
     recipe_id = p_recipe_id;


  END Delete_Recipe_Step_Quantities;

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
  PROCEDURE Get_Routing_Step_Quantities ( p_recipe_id   IN  NUMBER,
                                          x_quantities  OUT NOCOPY VARCHAR2,
                                          x_return_code OUT NOCOPY VARCHAR2,
                                          x_error_msg   OUT NOCOPY VARCHAR2) IS

   CURSOR Get_RoutingId IS
      SELECT
       routing_id
      FROM
       gmd_recipes
      WHERE
       recipe_id = p_recipe_id;

   l_routing_id        NUMBER(10) := 0;
   l_charge_tbl        GMD_COMMON_VAL.charge_tbl;

   l_msg_count         NUMBER(10);
   l_return_status     VARCHAR2(10);
   l_msg_stack         VARCHAR2(1000);
   l_message           VARCHAR2(2000);
   l_temp              NUMBER;
   l_table             gmd_recipe_fetch_pub.recipe_step_tbl;
   l_status            VARCHAR2(30);
   l_msg_cnt           NUMBER;
   l_msg_dat           VARCHAR2(100);
   l_ret_code          NUMBER;

   l_found_charge      BOOLEAN;

  BEGIN

    x_return_code := 'S';
    x_error_msg   := '';

    OPEN Get_RoutingId;
    FETCH Get_RoutingId INTO l_routing_id;
    CLOSE Get_RoutingId;


    GMD_RECIPE_FETCH_PUB.Get_Recipe_Step_Details
                          (p_api_version      => 1.0,
                           p_init_msg_list    => 'F',
                           p_recipe_id        => p_recipe_id,
                           x_return_status    => l_status,
                           x_msg_count        => l_msg_cnt,
                           x_msg_data         => l_msg_dat,
                           x_return_code      => l_ret_code,
                           x_recipe_step_out  => l_table);


    GMD_COMMON_VAL.Calculate_Charges(batch_id        => 0,
                                     recipe_id       => p_recipe_id,
                                     routing_id      => l_routing_id,
                                     VR_qty          => 0,
                                     Tolerance       => 0,
                                     orgn_id         => NULL,
                                     x_charge_tbl    => l_charge_tbl,
                                     x_return_status => l_return_status);

    IF l_table.COUNT > 0 THEN

     x_quantities := l_table.COUNT                || '//' ||
                     l_table(1).routingstep_no    || '//' ||
                     l_table(1).step_qty          || '//' ||
                     l_table(1).step_qty          || '//' ||
                     l_table(1).process_qty_uom    || '//' ||
                     l_table(1).step_qty          || '//' ||
                     l_table(1).process_qty_uom;

     l_found_charge := FALSE;

     FOR i IN 1..l_charge_tbl.COUNT LOOP

       IF l_table(1).routingstep_id = l_charge_tbl(i).routingstep_id THEN

         l_charge_tbl(i).charge := NVL(l_charge_tbl(i).charge, 1);
         l_charge_tbl(i).max_capacity := NVL( l_charge_tbl(i).max_capacity, -1);
         l_charge_tbl(i).capacity_uom := NVL( l_charge_tbl(i).capacity_uom, ' ');

         x_quantities := x_quantities                   || '//' ||
                         l_charge_tbl(i).charge         || '//' ||
                         l_charge_tbl(i).max_capacity   || '//' ||
                         l_charge_tbl(i).capacity_uom;

         l_found_charge := TRUE;

         EXIT;

       END IF;

     END LOOP;

     -- Should never occur .... but just in case !
     IF NOT l_found_charge THEN

       x_quantities := x_quantities || '//' ||
                       1            || '//' ||
                       -1           || '//' ||
                       '  ';

     END IF;

    END IF;

    FOR i IN 2.. l_table.COUNT LOOP

     x_quantities := x_quantities                 || '//' ||
                     l_table(i).routingstep_no    || '//' ||
                     l_table(i).step_qty          || '//' ||
                     l_table(i).step_qty          || '//' ||
                     l_table(i).process_qty_uom    || '//' ||
                     l_table(i).step_qty          || '//' ||
                     l_table(i).process_qty_uom;

     l_found_charge := FALSE;

     FOR j IN 1..l_charge_tbl.COUNT LOOP

       IF l_table(i).routingstep_id = l_charge_tbl(j).routingstep_id THEN

         l_charge_tbl(j).charge := NVL(l_charge_tbl(j).charge, 1);
         l_charge_tbl(j).max_capacity := NVL( l_charge_tbl(j).max_capacity, -1);
         l_charge_tbl(j).capacity_uom := NVL( l_charge_tbl(j).capacity_uom, ' ');

         x_quantities := x_quantities                   || '//' ||
                         l_charge_tbl(j).charge         || '//' ||
                         l_charge_tbl(j).max_capacity   || '//' ||
                         l_charge_tbl(j).capacity_uom;

         l_found_charge := TRUE;

         EXIT;

       END IF;

     END LOOP;

     -- Should never occur .... but just in case !
     IF NOT l_found_charge THEN

       x_quantities := x_quantities || '//' ||
                       1            || '//' ||
                       -1           || '//' ||
                       '  ';

     END IF;

    END LOOP;


    EXCEPTION
      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;


  END Get_Routing_Step_Quantities;

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
                                        x_used_in_batches OUT NOCOPY VARCHAR2,
                                        x_return_code     OUT NOCOPY VARCHAR2,
                                        x_error_msg       OUT NOCOPY VARCHAR2) IS

  BEGIN

    x_return_code := 'S';
    x_error_msg   := '';

    x_used_in_batches   := 'N';

    --- Returns TRUE if this recipe is used in batches
    IF NOT GMD_STATUS_CODE.Check_Parent_Status('RECIPE', p_recipe_id) THEN
      x_used_in_batches   := 'Y';
    END IF;

  END Is_Recipe_Used_In_Batches;

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
 |      p_enhanced_pi_ind           IN    VARCHAR2
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
  PROCEDURE Update_Recipe_Header ( p_recipe_id               IN  NUMBER,
                                   p_recipe_description      IN  VARCHAR2,
                                   p_recipe_no               IN  VARCHAR2,
                                   p_recipe_version          IN  NUMBER,
                                   p_owner_organization_id   IN  NUMBER,
                                   p_creation_organization_id  IN  NUMBER,
                                   p_recipe_status           IN  VARCHAR2,
                                   p_delete_mark             IN  NUMBER,
                                   p_formula_id              IN  NUMBER,
                                   p_routing_id              IN  NUMBER,
                                   p_planned_process_loss    IN  NUMBER,
                                   p_text_code               IN  NUMBER,
                                   p_owner_id                IN  NUMBER,
                                   p_calculate_step_qty      IN  NUMBER,
                                   p_user_id                 IN  NUMBER,
                                   p_last_update_date        IN  DATE,
                                   p_last_update_date_origin IN  DATE,
                                   p_update_number_version   IN  VARCHAR2,
                                   x_return_code             OUT NOCOPY VARCHAR2,
                                   x_error_msg               OUT NOCOPY VARCHAR2,
                                   p_enhanced_pi_ind         IN  VARCHAR2,
                                   p_contiguous_ind          IN    NUMBER,
                                   p_recipe_type             IN    NUMBER) IS

     CURSOR Get_Recipe IS
       SELECT *
       FROM GMD_RECIPES
       WHERE
          recipe_id         = p_recipe_id      AND
          last_update_date  = p_last_update_date_origin;

     l_recipe_rec             GMD_RECIPES%ROWTYPE;
     l_recipe_tbl             GMD_RECIPE_HEADER.recipe_hdr;
     l_recipe_update_flex     GMD_RECIPE_HEADER.update_flex;

     l_return_status          VARCHAR2(2);
     l_msg_count              NUMBER(10);
     l_message_count          NUMBER;
     l_msg_data               VARCHAR2(2000);
     l_message                VARCHAR2(1000);
     l_dummy                  NUMBER;

     CURSOR Get_Old_Stp_Mat IS
      SELECT a.routingstep_id
      FROM   gmd_recipe_step_materials a, fm_rout_dtl b
      WHERE  a.recipe_id = p_recipe_id
      AND    a.routingstep_id = b.routingstep_id
      AND    b.routing_id = l_recipe_rec.routing_id;

     CURSOR Get_Old_Stp IS
      SELECT a.routingstep_id
      FROM   gmd_recipe_routing_steps a, fm_rout_dtl b
      WHERE  a.recipe_id = p_recipe_id
      AND    a.routingstep_id = b.routingstep_id
      AND    b.routing_id = l_recipe_rec.routing_id;

     RECORD_CHANGED_EXCEPTION EXCEPTION;
     UPDATE_RECIPE_EXCEPTION  EXCEPTION;

  BEGIN

    x_return_code := 'S';
    x_error_msg   := '';

    OPEN Get_Recipe;
    FETCH Get_Recipe INTO l_recipe_rec;

    IF Get_Recipe%NOTFOUND THEN
       CLOSE Get_Recipe;
       RAISE RECORD_CHANGED_EXCEPTION;
    END IF;

    CLOSE Get_Recipe;

    IF p_routing_id > 0 THEN
      l_recipe_tbl.ROUTING_ID := p_routing_id;
    ELSE
      l_recipe_tbl.ROUTING_ID := NULL;
      null;
    END IF;

    IF p_planned_process_loss >= 0 THEN
      l_recipe_tbl.PLANNED_PROCESS_LOSS := p_planned_process_loss;
    ELSE
      l_recipe_tbl.PLANNED_PROCESS_LOSS := NULL;
    END IF;

    IF p_text_code > 0 THEN
      l_recipe_tbl.TEXT_CODE := p_text_code;
    ELSE
      l_recipe_tbl.TEXT_CODE := NULL;
    END IF;

    l_recipe_tbl.PROJECT_ID              := l_recipe_rec.project_id;
    l_recipe_tbl.OWNER_LAB_TYPE          := l_recipe_rec.owner_lab_type;

    l_recipe_tbl.RECIPE_NO               := l_recipe_rec.recipe_no;
    l_recipe_tbl.RECIPE_VERSION          := l_recipe_rec.recipe_version;
    l_recipe_tbl.RECIPE_ID               := p_recipe_id;
    l_recipe_tbl.RECIPE_DESCRIPTION      := p_recipe_description;
    l_recipe_tbl.USER_ID                 := p_user_id;
    l_recipe_tbl.OWNER_ORGANIZATION_ID   := p_owner_organization_id;
    l_recipe_tbl.CREATION_ORGANIZATION_ID  := p_creation_organization_id;
    l_recipe_tbl.FORMULA_ID              := p_formula_id;
    l_recipe_tbl.RECIPE_STATUS           := p_recipe_status;
    l_recipe_tbl.DELETE_MARK             := p_delete_mark;
    l_recipe_tbl.LAST_UPDATED_BY         := p_user_id;
    l_recipe_tbl.LAST_UPDATE_DATE        := p_last_update_date;
    l_recipe_tbl.LAST_UPDATE_LOGIN       := p_user_id;
    l_recipe_tbl.OWNER_ID                := p_owner_id;
    l_recipe_tbl.CALCULATE_STEP_QUANTITY := p_calculate_step_qty;

    -- Added by Shyam for GMD-GMO integration
    l_recipe_tbl.enhanced_pi_ind         := p_enhanced_pi_ind;

    -- Include contiguous ind
    l_recipe_tbl.contiguous_ind         := p_contiguous_ind;

    l_recipe_tbl.recipe_type         := p_recipe_type;

    l_recipe_update_flex.ATTRIBUTE_CATEGORY := l_recipe_rec.attribute_category;
    l_recipe_update_flex.ATTRIBUTE1         := l_recipe_rec.attribute1;
    l_recipe_update_flex.ATTRIBUTE2         := l_recipe_rec.attribute2;
    l_recipe_update_flex.ATTRIBUTE3         := l_recipe_rec.attribute3;
    l_recipe_update_flex.ATTRIBUTE4         := l_recipe_rec.attribute4;
    l_recipe_update_flex.ATTRIBUTE5         := l_recipe_rec.attribute5;
    l_recipe_update_flex.ATTRIBUTE6         := l_recipe_rec.attribute6;
    l_recipe_update_flex.ATTRIBUTE7         := l_recipe_rec.attribute7;
    l_recipe_update_flex.ATTRIBUTE8         := l_recipe_rec.attribute8;
    l_recipe_update_flex.ATTRIBUTE9         := l_recipe_rec.attribute9;
    l_recipe_update_flex.ATTRIBUTE10        := l_recipe_rec.attribute10;
    l_recipe_update_flex.ATTRIBUTE11        := l_recipe_rec.attribute11;
    l_recipe_update_flex.ATTRIBUTE12        := l_recipe_rec.attribute12;
    l_recipe_update_flex.ATTRIBUTE13        := l_recipe_rec.attribute13;
    l_recipe_update_flex.ATTRIBUTE14        := l_recipe_rec.attribute14;
    l_recipe_update_flex.ATTRIBUTE15        := l_recipe_rec.attribute15;
    l_recipe_update_flex.ATTRIBUTE16        := l_recipe_rec.attribute16;
    l_recipe_update_flex.ATTRIBUTE17        := l_recipe_rec.attribute17;
    l_recipe_update_flex.ATTRIBUTE18        := l_recipe_rec.attribute18;
    l_recipe_update_flex.ATTRIBUTE19        := l_recipe_rec.attribute19;
    l_recipe_update_flex.ATTRIBUTE20        := l_recipe_rec.attribute20;
    l_recipe_update_flex.ATTRIBUTE21        := l_recipe_rec.attribute21;
    l_recipe_update_flex.ATTRIBUTE22        := l_recipe_rec.attribute22;
    l_recipe_update_flex.ATTRIBUTE23        := l_recipe_rec.attribute23;
    l_recipe_update_flex.ATTRIBUTE24        := l_recipe_rec.attribute24;
    l_recipe_update_flex.ATTRIBUTE25        := l_recipe_rec.attribute25;
    l_recipe_update_flex.ATTRIBUTE26        := l_recipe_rec.attribute26;
    l_recipe_update_flex.ATTRIBUTE27        := l_recipe_rec.attribute27;
    l_recipe_update_flex.ATTRIBUTE28        := l_recipe_rec.attribute28;
    l_recipe_update_flex.ATTRIBUTE29        := l_recipe_rec.attribute29;
    l_recipe_update_flex.ATTRIBUTE30        := l_recipe_rec.attribute30;

    GMD_RECIPE_HEADER_PVT.Update_Recipe_Header
                        ( p_recipe_header_rec => l_recipe_tbl
                         ,p_flex_header_rec   => l_recipe_update_flex
                         ,x_return_status     => l_return_status);


    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE UPDATE_RECIPE_EXCEPTION;
    END IF;

    --- If recipe number and/or version have changed, we need to update them. This
    --- happens when creating a new recipe, because a dummy recipe header is created in
    --- the database. User is then prompted to enter a valid recipe number/version prior
    --- to modifying the recipe header.

    IF p_update_number_version = 'Y' THEN

      IF l_recipe_rec.recipe_no      <> p_recipe_no OR
         l_recipe_rec.recipe_version <> p_recipe_version THEN

        UPDATE
          GMD_RECIPES_B
        SET
          recipe_no      = p_recipe_no,
          recipe_version = p_recipe_version
        WHERE
          recipe_id      = p_recipe_id;
          --4504794, this will defaults the PI instructions.
          GMD_PROCESS_INSTR_UTILS.COPY_PROCESS_INSTR(
                      p_entity_name   => 'RECIPE',
                      p_entity_id     => p_recipe_id,
                      x_return_status => l_return_status,
                      x_msg_count     => l_msg_count,
                      x_msg_data      => l_msg_data);
      END IF;
    END IF;

    --- The routing has changed, so we need to delete all records related to the
    --- old routing.
    IF (l_recipe_rec.routing_id <> p_routing_id) THEN

     --- Delete old rows in step material table
     FOR old_step_mat IN Get_Old_Stp_Mat LOOP

       DELETE gmd_recipe_step_materials
       WHERE recipe_id = p_recipe_id AND
             routingstep_id = old_step_mat.routingstep_id;

     END LOOP;

     --- Delete old rows in recipe step table
     FOR old_step IN Get_Old_Stp LOOP

       DELETE gmd_recipe_routing_steps
       WHERE recipe_id = p_recipe_id AND
             routingstep_id = old_step.routingstep_id;

     END LOOP;

    END IF;

    EXCEPTION
      WHEN UPDATE_RECIPE_EXCEPTION THEN
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

  END Update_Recipe_Header;


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
 |     22-Apr-2008 RLNAGARA Fixed Process Loss ME
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Create_Recipe_Header ( p_orgn_id       IN         NUMBER,
                                   x_recipe_id     OUT NOCOPY NUMBER,
                                   x_return_code   OUT NOCOPY VARCHAR2,
                                   x_error_msg     OUT NOCOPY VARCHAR2) IS

    l_user_id                NUMBER := fnd_global.user_id;
    -- FND_PROFILE.VALUE('USER_ID');
    l_login_id               NUMBER := fnd_global.login_id;
    --FND_PROFILE.VALUE('LOGIN_ID');

    CURSOR Cur_recipe_id IS
    SELECT gmd_recipe_id_s.NEXTVAL
    FROM   FND_DUAL;


    l_return_status           VARCHAR2(5);
    l_owner_orgn_code         VARCHAR2(4);
    l_timestamp               DATE;
    l_recipe_no               VARCHAR2(32);
    l_recipe_rec              GMD_RECIPES%ROWTYPE;
    INSERT_RECIPE_EXCEPTION   EXCEPTION;

    l_message_count          NUMBER;
    l_message_list           VARCHAR2(2000);
    l_message                VARCHAR2(1000);
    l_dummy                  NUMBER;
    l_rowid                  VARCHAR2(32);
    l_formula_security_id    NUMBER;

  BEGIN

    x_return_code := FND_API.G_RET_STS_SUCCESS;
    x_error_msg   := FND_MESSAGE.GET;

    OPEN Cur_recipe_id;
    FETCH Cur_recipe_id INTO x_recipe_id;
    CLOSE Cur_recipe_id;


    l_timestamp  := SYSDATE;
    --- Create a unique recipe number. This is used to initialize the recipe
    --- in the database. User will be prompted to enter a valid recipe number
    --- prior to saving.

    l_recipe_no := x_recipe_id || '#' ||
                  TO_CHAR(l_timestamp, 'YYYYMMDDHH24MISS');
    --Call to delete the row with formula_id -1 to fix the issue reported in 3157487
     -- Commented out temp
    /*
    DELETE FROM gmd_formula_security
    WHERE orgn_code = l_owner_orgn_code
    AND   formula_id = -1;
    --Call to insert the row with formula_id -1 to fix the issue reported in 3157487


    gmd_formula_security_pkg.insert_row (
                                        X_FORMULA_SECURITY_ID => l_formula_security_id,
                                        X_FORMULA_ID          => -1,
                                        X_ACCESS_TYPE_IND     => 'U',
                                        X_ORGN_CODE           => l_owner_orgn_code,
                                        X_USER_ID             => l_user_id,
                                        X_RESPONSIBILITY_ID   => NULL,
                                        X_OTHER_ORGN          => NULL,
                                        X_CREATION_DATE       => l_timestamp,
                                        X_CREATED_BY          => l_user_id,
                                        X_LAST_UPDATE_DATE    => l_timestamp,
                                        X_LAST_UPDATED_BY     => l_user_id,
                                        X_LAST_UPDATE_LOGIN   => l_login_id);
                                        */
-- KSHUKLA added the following
-- As per as bug 3843246
 delete from FM_FORM_MST_B where FORMULA_ID = -1;

 insert into
 FM_FORM_MST_B(FORMULA_ID,
               OWNER_ORGANIZATION_ID,
               DELETE_MARK,
               FORMULA_STATUS,
               OWNER_ID,
               FORMULA_NO,
               FORMULA_VERS,
               FORMULA_TYPE,
               INACTIVE_IND,
               SCALE_TYPE,
               FORMULA_DESC1,
               CREATION_DATE,
               CREATED_BY,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN)
       values (-1,
               p_orgn_id ,
               1,
               100,
               l_user_id,
               -1,
               -1,
               0,
               1,
               1,
               -1,
               l_timestamp,
               l_user_id,
               l_timestamp,
               l_user_id,
               l_login_id);
  -- End BUg 3843246

    GMD_RECIPES_MLS.Insert_Row(
                X_ROWID                 => l_rowid,
                X_RECIPE_ID             => x_recipe_id,
                X_RECIPE_NO             => l_recipe_no,
                X_RECIPE_VERSION        => 1,
                X_OWNER_ORGANIZATION_ID => p_orgn_id,
                X_CREATION_ORGANIZATION_ID => p_orgn_id,
                X_FORMULA_ID            => -1,
                X_ROUTING_ID            => NULL,
                X_PROJECT_ID            => NULL,
                X_RECIPE_STATUS         => '100',
                X_CALCULATE_STEP_QUANTITY => 0,
                X_PLANNED_PROCESS_LOSS  => NULL,
                X_RECIPE_DESCRIPTION    => 'New',
                X_OWNER_ID              => l_user_id,
                X_OWNER_LAB_TYPE        => NULL,
                --Additional 3 column added - Begin
                X_CONTIGUOUS_IND        => 0,
                -- By default this value is 'N'
                -- for gmd-gmo convergence
                X_ENHANCED_PI_IND       => 'N',
                X_RECIPE_TYPE           => 0,
                --Additional 3 column added- End
                X_ATTRIBUTE_CATEGORY    => NULL,
                X_ATTRIBUTE1            => NULL,
                X_ATTRIBUTE2            => NULL,
                X_ATTRIBUTE3            => NULL,
                X_ATTRIBUTE4            => NULL,
                X_ATTRIBUTE5            => NULL,
                X_ATTRIBUTE6            => NULL,
                X_ATTRIBUTE7            => NULL,
                X_ATTRIBUTE8            => NULL,
                X_ATTRIBUTE9            => NULL,
                X_ATTRIBUTE10           => NULL,
                X_ATTRIBUTE11           => NULL,
                X_ATTRIBUTE12           => NULL,
                X_ATTRIBUTE13           => NULL,
                X_ATTRIBUTE14           => NULL,
                X_ATTRIBUTE15           => NULL,
                X_ATTRIBUTE16           => NULL,
                X_ATTRIBUTE17           => NULL,
                X_ATTRIBUTE18           => NULL,
                X_ATTRIBUTE19           => NULL,
                X_ATTRIBUTE20           => NULL,
                X_ATTRIBUTE21           => NULL,
                X_ATTRIBUTE22           => NULL,
                X_ATTRIBUTE23           => NULL,
                X_ATTRIBUTE24           => NULL,
                X_ATTRIBUTE25           => NULL,
                X_ATTRIBUTE26           => NULL,
                X_ATTRIBUTE27           => NULL,
                X_ATTRIBUTE28           => NULL,
                X_ATTRIBUTE29           => NULL,
                X_ATTRIBUTE30           => NULL,
                X_DELETE_MARK           => 0,
                X_TEXT_CODE             => NULL,
                X_CREATION_DATE         => l_timestamp,
                X_CREATED_BY            => l_user_id,
                X_LAST_UPDATE_DATE      => l_timestamp,
                X_LAST_UPDATED_BY       => l_user_id,
                X_LAST_UPDATE_LOGIN     => l_login_id,
		X_FIXED_PROCESS_LOSS    => NULL, /*RLNAGARA 6811759*/
                X_FIXED_PROCESS_LOSS_UOM => NULL);

    EXCEPTION
      WHEN INSERT_RECIPE_EXCEPTION THEN
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

  END Create_Recipe_Header;


/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Add_Recipe_Customer
 |
 |   DESCRIPTION
 |      Add a new customer to the recipe
 |
 |   INPUT PARAMETERS
 |    p_recipe_id        NUMBER
 |    p_customer_id      NUMBER
 |    p_text_code        NUMBER
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
  PROCEDURE Add_Recipe_Customer (p_recipe_id         IN NUMBER,
                                 p_customer_id       IN NUMBER,
                                 p_text_code         IN NUMBER,
                                 p_org_id            IN NUMBER,    --new addition
                                 p_site_use_id       IN NUMBER,    --new addition
                                 p_last_update_date  IN DATE,
                                 x_return_code       OUT NOCOPY VARCHAR2,
                                 x_error_msg         OUT NOCOPY VARCHAR2) IS


    l_cust_tbl              GMD_RECIPE_DETAIL.recipe_detail_tbl;
    l_status                VARCHAR2(30);
    l_msg_cnt               NUMBER;
    l_msg_dat               VARCHAR2(30);
    l_message               VARCHAR2(1000);
    l_dummy                 NUMBER;
    l_login_id              NUMBER := FND_PROFILE.VALUE('LOGIN_ID');
    l_user_id               NUMBER := FND_PROFILE.VALUE('USER_ID');
    CREATE_CUST_EXCEPTION   EXCEPTION;

  BEGIN

    x_return_code := 'S';
    x_error_msg   := '';

    IF (p_text_code <= 0) THEN
      l_cust_tbl(1).text_code  := NULL;
    ELSE
      l_cust_tbl(1).text_code  := p_text_code;
    END IF;

    l_cust_tbl(1).user_id           := l_user_id;
    l_cust_tbl(1).recipe_id         := p_recipe_id;
    l_cust_tbl(1).customer_id       := p_customer_id;
    l_cust_tbl(1).org_id            := p_org_id;              --new addition
    l_cust_tbl(1).site_id           := p_site_use_id;         --new addition
    l_cust_tbl(1).creation_date     := p_last_update_date;
    l_cust_tbl(1).created_by        := l_user_id;
    l_cust_tbl(1).last_updated_by   := l_user_id;
    l_cust_tbl(1).last_update_login := l_login_id;
    l_cust_tbl(1).last_update_date  := p_last_update_date;

    GMD_RECIPE_DETAIL.Create_Recipe_Customers(p_api_version       => 1.0,
                                              p_init_msg_list     => 'T',
                                              p_commit            => 'F',
                                              p_called_from_forms => 'NO',
                                              x_return_status     => l_status,
                                              x_msg_count         => l_msg_cnt,
                                              x_msg_data          => l_msg_dat,
                                              p_recipe_detail_tbl => l_cust_tbl);


    IF (l_status <> 'S') THEN
      RAISE CREATE_CUST_EXCEPTION;
    END IF;

    EXCEPTION
      WHEN CREATE_CUST_EXCEPTION THEN
        FND_MSG_PUB.GET( p_msg_index     => 1,
                         p_data          => l_message,
                         p_encoded       => 'F',
                         p_msg_index_out => l_dummy);
        x_return_code := 'F';
        x_error_msg   := l_message;

      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('FND', 'FND_RECORD_CHANGED_ERROR');
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

  END Add_Recipe_Customer;

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
  PROCEDURE Delete_Recipe_Customer (p_recipe_id         IN NUMBER,
                                    p_customer_id       IN NUMBER,
                                    p_last_update_date  IN DATE,
                                    x_return_code       OUT NOCOPY VARCHAR2,
                                    x_error_msg         OUT NOCOPY VARCHAR2) IS

    l_status                VARCHAR2(30);

  BEGIN

    x_return_code := 'S';
    x_error_msg   := '';

    --- This statement should be replaced by an API when it is available ...

    DELETE
       gmd_recipe_customers
    WHERE
       recipe_id        = p_recipe_id   AND
       customer_id      = p_customer_id AND
       last_update_date = p_last_update_date;

    IF SQL%NOTFOUND THEN
        FND_MESSAGE.SET_NAME('FND', 'FND_RECORD_CHANGED_ERROR');
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

  End Delete_Recipe_Customer;


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
 |     30-OCT-2002 Eddie Oumerretane   Created.
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
                                 x_error_msg         OUT NOCOPY VARCHAR2) IS
    CURSOR Cur_loss_id IS
      SELECT gmd_recipe_process_loss_id_s.NEXTVAL
      FROM   SYS.DUAL;

    l_loss_tbl              GMD_RECIPE_DETAIL.recipe_dtl;
    l_status                VARCHAR2(30);
    l_msg_cnt               NUMBER;
    l_msg_dat               VARCHAR2(30);
    l_message               VARCHAR2(1000);
    l_dummy                 NUMBER;
    l_login_id              NUMBER := FND_PROFILE.VALUE('LOGIN_ID');
    l_user_id               NUMBER := FND_PROFILE.VALUE('USER_ID');
    CREATE_LOSS_EXCEPTION   EXCEPTION;

  BEGIN

    x_return_code := 'S';
    x_error_msg   := '';

    IF p_loss_id IS NULL THEN
      OPEN Cur_loss_id;
      FETCH Cur_loss_id INTO x_loss_id;
      CLOSE Cur_loss_id;
    ELSE
      x_loss_id := p_loss_id;
    END IF;

    IF (p_text_code <= 0) THEN
      l_loss_tbl.text_code  := NULL;
    ELSE
      l_loss_tbl.text_code  := p_text_code;
    END IF;

    l_loss_tbl.user_id                := l_user_id;
    l_loss_tbl.recipe_id              := p_recipe_id;
    l_loss_tbl.recipe_process_loss_id := x_loss_id;
    l_loss_tbl.organization_id          := p_orgn_id;
    l_loss_tbl.process_loss           := p_process_loss;
    l_loss_tbl.CONTIGUOUS_IND         :=p_contiguous_ind; --adding
    l_loss_tbl.creation_date          := p_last_update_date;
    l_loss_tbl.created_by             := l_user_id;
    l_loss_tbl.last_updated_by        := l_user_id;
    l_loss_tbl.last_update_login      := l_login_id;
    l_loss_tbl.last_update_date       := p_last_update_date;

    GMD_RECIPE_DETAIL_PVT.Create_Recipe_Process_Loss(
                                                 p_recipe_detail_rec => l_loss_tbl,
                                                 x_return_status     => l_status);


    IF (l_status <> 'S') THEN
      RAISE CREATE_LOSS_EXCEPTION;
    END IF;

    EXCEPTION
      WHEN CREATE_LOSS_EXCEPTION THEN
        FND_MSG_PUB.GET( p_msg_index     => 1,
                         p_data          => l_message,
                         p_encoded       => 'F',
                         p_msg_index_out => l_dummy);
        x_return_code := 'F';
        x_error_msg   := l_message;

      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('FND', 'FND_RECORD_CHANGED_ERROR');
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

  END Create_Process_Loss;

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
  PROCEDURE Add_Org_Process_Loss (p_recipe_id         IN NUMBER,
                                  p_orgn_id           IN NUMBER,
                                  p_process_loss      IN NUMBER,
                                  p_text_code         IN NUMBER,
                                  p_contiguous_ind    IN NUMBER,
                                  p_last_update_date  IN DATE,
                                  x_loss_id           OUT NOCOPY NUMBER,
                                  x_return_code       OUT NOCOPY VARCHAR2,
                                  x_error_msg         OUT NOCOPY VARCHAR2) IS
  BEGIN

     Create_Process_Loss (p_recipe_id         => p_recipe_id,
                          p_orgn_id           => p_orgn_id,
                          p_process_loss      => p_process_loss,
                          p_text_code         => p_text_code,
                          p_contiguous_ind    => p_contiguous_ind,
                          p_last_update_date  => p_last_update_date,
                          p_loss_id           => NULL,
                          x_loss_id           => x_loss_id,
                          x_return_code       => x_return_code,
                          x_error_msg         => x_error_msg);

  END Add_Org_Process_Loss;

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
                                     x_error_msg         OUT NOCOPY VARCHAR2) IS

    l_status                VARCHAR2(30);

  BEGIN

    x_return_code := 'S';
    x_error_msg   := '';

    --- This statement should be replaced by an API when it is available ...

    DELETE
       gmd_recipe_process_loss
    WHERE
       recipe_process_loss_id = p_loss_id AND
       last_update_date       = p_last_update_date;

    IF SQL%NOTFOUND THEN
        FND_MESSAGE.SET_NAME('FND', 'FND_RECORD_CHANGED_ERROR');
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

  END Delete_Org_Process_Loss;

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
 |    p_orgn_id          VARCHAR2
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
                                     p_orgn_id          IN NUMBER,
                                     p_process_loss      IN NUMBER,
                                     p_text_code         IN NUMBER,
                                     p_contiguous_ind    IN NUMBER,
                                     p_last_update_date  IN DATE,
                                     p_last_update_date_orig  IN DATE,
                                     x_return_code       OUT NOCOPY VARCHAR2,
                                     x_error_msg         OUT NOCOPY VARCHAR2) IS

    CURSOR Get_Loss IS
    SELECT 1
    FROM
      gmd_recipe_process_loss
    WHERE
       recipe_process_loss_id = p_recipe_loss_id AND
       last_update_date       = p_last_update_date_orig;

    l_loss_tbl              GMD_RECIPE_DETAIL.recipe_dtl;
    l_status                VARCHAR2(30);
    l_msg_cnt               NUMBER;
    l_msg_dat               VARCHAR2(30);
    l_message               VARCHAR2(1000);
    l_dummy                 NUMBER;
    l_login_id              NUMBER := FND_PROFILE.VALUE('LOGIN_ID');
    l_user_id               NUMBER := FND_PROFILE.VALUE('USER_ID');
    UPDATE_LOSS_EXCEPTION   EXCEPTION;

  BEGIN

    x_return_code := 'S';
    x_error_msg   := '';

    OPEN Get_Loss;
    FETCH Get_Loss INTO l_dummy;

    IF Get_Loss%NOTFOUND THEN
      CLOSE Get_Loss;
      RAISE NO_DATA_FOUND;
    END IF;

    CLOSE Get_Loss;

    IF (p_text_code <= 0) THEN
      l_loss_tbl.text_code  := NULL;
    ELSE
      l_loss_tbl.text_code  := p_text_code;
    END IF;

    l_loss_tbl.user_id                := l_user_id;
    l_loss_tbl.recipe_id              := p_recipe_id;
    l_loss_tbl.recipe_process_loss_id := p_recipe_loss_id;
    l_loss_tbl.organization_id        := p_orgn_id;
    l_loss_tbl.process_loss           := p_process_loss;
    l_loss_tbl.CONTIGUOUS_IND         := p_contiguous_ind; --adding

    l_loss_tbl.last_updated_by        := l_user_id;
    l_loss_tbl.last_update_login      := l_login_id;
    l_loss_tbl.last_update_date       := p_last_update_date;

    GMD_RECIPE_DETAIL_PVT.Update_Recipe_Process_Loss(
                                                 p_recipe_detail_rec => l_loss_tbl,
                                                 x_return_status     => l_status);


    IF (l_status <> 'S') THEN
      RAISE UPDATE_LOSS_EXCEPTION;
    END IF;

    EXCEPTION
      WHEN UPDATE_LOSS_EXCEPTION THEN
        FND_MSG_PUB.GET( p_msg_index     => 1,
                         p_data          => l_message,
                         p_encoded       => 'F',
                         p_msg_index_out => l_dummy);
        x_return_code := 'F';
        x_error_msg   := l_message;

      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('FND', 'FND_RECORD_CHANGED_ERROR');
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

  END Update_Org_Process_Loss;

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
                           x_error_msg              OUT NOCOPY VARCHAR2) IS

    CURSOR Get_Recipe IS
    SELECT *
    FROM
      gmd_recipes
    WHERE
       recipe_id         = p_recipe_id AND
       last_update_date  = p_last_update_date_orig;

    l_recipe_hdr            GMD_RECIPE_HEADER.recipe_hdr;
    l_recipe_flex           GMD_RECIPE_HEADER.update_flex;
    l_recipe_rec            GMD_RECIPES%ROWTYPE;

    l_status                VARCHAR2(30);
    l_msg_cnt               NUMBER;
    l_msg_dat               VARCHAR2(30);
    l_message               VARCHAR2(1000);
    l_dummy                 NUMBER;
    l_login_id              NUMBER := FND_PROFILE.VALUE('LOGIN_ID');
    l_user_id               NUMBER := FND_PROFILE.VALUE('USER_ID');
    DELETE_RECIPE_EXCEPTION EXCEPTION;

  BEGIN

    x_return_code := 'S';
    x_error_msg   := '';

    OPEN Get_Recipe;
    FETCH Get_Recipe INTO l_recipe_rec;

    IF Get_Recipe%NOTFOUND THEN
       CLOSE Get_Recipe;
       RAISE NO_DATA_FOUND;
    END IF;

    CLOSE Get_Recipe;


    l_recipe_hdr.ROUTING_ID              := l_recipe_rec.routing_id;
    l_recipe_hdr.PLANNED_PROCESS_LOSS    := l_recipe_rec.planned_process_loss;
    l_recipe_hdr.TEXT_CODE               := l_recipe_rec.text_code;
    l_recipe_hdr.PROJECT_ID              := l_recipe_rec.project_id;
    l_recipe_hdr.OWNER_LAB_TYPE          := l_recipe_rec.owner_lab_type;
    l_recipe_hdr.RECIPE_NO               := l_recipe_rec.recipe_no;
    l_recipe_hdr.RECIPE_VERSION          := l_recipe_rec.recipe_version;
    l_recipe_hdr.RECIPE_ID               := p_recipe_id;
    l_recipe_hdr.RECIPE_DESCRIPTION      := l_recipe_rec.recipe_description;
    l_recipe_hdr.USER_ID                 := l_user_id;
    l_recipe_hdr.OWNER_ORGANIZATION_ID   := l_recipe_rec.owner_organization_id;
    l_recipe_hdr.CREATION_ORGANIZATION_ID := l_recipe_rec.creation_organization_id;
    l_recipe_hdr.FORMULA_ID              := l_recipe_rec.formula_id;
    l_recipe_hdr.RECIPE_STATUS           := l_recipe_rec.recipe_status;
    l_recipe_hdr.DELETE_MARK             := 1;
    l_recipe_hdr.LAST_UPDATED_BY         := l_user_id;
    l_recipe_hdr.LAST_UPDATE_DATE        := SYSDATE;
    l_recipe_hdr.LAST_UPDATE_LOGIN       := l_login_id;
    l_recipe_hdr.OWNER_ID                := l_recipe_rec.owner_id;
    l_recipe_hdr.CALCULATE_STEP_QUANTITY := l_recipe_rec.calculate_step_quantity;

    l_recipe_flex.ATTRIBUTE_CATEGORY := l_recipe_rec.attribute_category;
    l_recipe_flex.ATTRIBUTE1         := l_recipe_rec.attribute1;
    l_recipe_flex.ATTRIBUTE2         := l_recipe_rec.attribute2;
    l_recipe_flex.ATTRIBUTE3         := l_recipe_rec.attribute3;
    l_recipe_flex.ATTRIBUTE4         := l_recipe_rec.attribute4;
    l_recipe_flex.ATTRIBUTE5         := l_recipe_rec.attribute5;
    l_recipe_flex.ATTRIBUTE6         := l_recipe_rec.attribute6;
    l_recipe_flex.ATTRIBUTE7         := l_recipe_rec.attribute7;
    l_recipe_flex.ATTRIBUTE8         := l_recipe_rec.attribute8;
    l_recipe_flex.ATTRIBUTE9         := l_recipe_rec.attribute9;
    l_recipe_flex.ATTRIBUTE10        := l_recipe_rec.attribute10;
    l_recipe_flex.ATTRIBUTE11        := l_recipe_rec.attribute11;
    l_recipe_flex.ATTRIBUTE12        := l_recipe_rec.attribute12;
    l_recipe_flex.ATTRIBUTE13        := l_recipe_rec.attribute13;
    l_recipe_flex.ATTRIBUTE14        := l_recipe_rec.attribute14;
    l_recipe_flex.ATTRIBUTE15        := l_recipe_rec.attribute15;
    l_recipe_flex.ATTRIBUTE16        := l_recipe_rec.attribute16;
    l_recipe_flex.ATTRIBUTE17        := l_recipe_rec.attribute17;
    l_recipe_flex.ATTRIBUTE18        := l_recipe_rec.attribute18;
    l_recipe_flex.ATTRIBUTE19        := l_recipe_rec.attribute19;
    l_recipe_flex.ATTRIBUTE20        := l_recipe_rec.attribute20;
    l_recipe_flex.ATTRIBUTE21        := l_recipe_rec.attribute21;
    l_recipe_flex.ATTRIBUTE22        := l_recipe_rec.attribute22;
    l_recipe_flex.ATTRIBUTE23        := l_recipe_rec.attribute23;
    l_recipe_flex.ATTRIBUTE24        := l_recipe_rec.attribute24;
    l_recipe_flex.ATTRIBUTE25        := l_recipe_rec.attribute25;
    l_recipe_flex.ATTRIBUTE26        := l_recipe_rec.attribute26;
    l_recipe_flex.ATTRIBUTE27        := l_recipe_rec.attribute27;
    l_recipe_flex.ATTRIBUTE28        := l_recipe_rec.attribute28;
    l_recipe_flex.ATTRIBUTE29        := l_recipe_rec.attribute29;

    GMD_RECIPE_HEADER_PVT.Delete_Recipe_Header
                                       ( p_recipe_header_rec  => l_recipe_hdr
                                        ,p_flex_header_rec    => l_recipe_flex
                                        ,x_return_status      => l_status);

    IF (l_status <> 'S') THEN
      RAISE DELETE_RECIPE_EXCEPTION;
    END IF;

    COMMIT;

    EXCEPTION
      WHEN DELETE_RECIPE_EXCEPTION THEN
        FND_MSG_PUB.GET( p_msg_index     => 1,
                         p_data          => l_message,
                         p_encoded       => 'F',
                         p_msg_index_out => l_dummy);
        x_return_code := 'F';
        x_error_msg   := l_message;

      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('FND', 'FND_RECORD_CHANGED_ERROR');
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

  END Delete_Recipe;

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
                             x_error_msg              OUT NOCOPY VARCHAR2) IS

    CURSOR Get_Recipe IS
    SELECT *
    FROM
      gmd_recipes
    WHERE
       recipe_id         = p_recipe_id AND
       last_update_date  = p_last_update_date_orig;

    l_recipe_hdr            GMD_RECIPE_HEADER.recipe_hdr;
    l_recipe_flex           GMD_RECIPE_HEADER.update_flex;
    l_recipe_rec            GMD_RECIPES%ROWTYPE;
    l_status                VARCHAR2(30);
    l_msg_cnt               NUMBER;
    l_msg_dat               VARCHAR2(30);
    l_message               VARCHAR2(1000);
    l_dummy                 NUMBER;
    l_login_id              NUMBER := FND_PROFILE.VALUE('LOGIN_ID');
    l_user_id               NUMBER := FND_PROFILE.VALUE('USER_ID');
    DELETE_RECIPE_EXCEPTION EXCEPTION;

  BEGIN

    x_return_code := 'S';
    x_error_msg   := '';

    OPEN Get_Recipe;
    FETCH Get_Recipe INTO l_recipe_rec;

    IF Get_Recipe%NOTFOUND THEN
       CLOSE Get_Recipe;
       RAISE NO_DATA_FOUND;
    END IF;

    CLOSE Get_Recipe;


    l_recipe_hdr.ROUTING_ID              := l_recipe_rec.routing_id;
    l_recipe_hdr.PLANNED_PROCESS_LOSS    := l_recipe_rec.planned_process_loss;
    l_recipe_hdr.TEXT_CODE               := l_recipe_rec.text_code;
    l_recipe_hdr.PROJECT_ID              := l_recipe_rec.project_id;
    l_recipe_hdr.OWNER_LAB_TYPE          := l_recipe_rec.owner_lab_type;
    l_recipe_hdr.RECIPE_NO               := l_recipe_rec.recipe_no;
    l_recipe_hdr.RECIPE_VERSION          := l_recipe_rec.recipe_version;
    l_recipe_hdr.RECIPE_ID               := p_recipe_id;
    l_recipe_hdr.RECIPE_DESCRIPTION      := l_recipe_rec.recipe_description;
    l_recipe_hdr.USER_ID                 := l_user_id;
    l_recipe_hdr.OWNER_ORGANIZATION_ID   := l_recipe_rec.owner_organization_id;
    l_recipe_hdr.CREATION_ORGANIZATION_ID := l_recipe_rec.creation_organization_id;
    l_recipe_hdr.FORMULA_ID              := l_recipe_rec.formula_id;
    l_recipe_hdr.RECIPE_STATUS           := l_recipe_rec.recipe_status;
    l_recipe_hdr.DELETE_MARK             := 0;
    l_recipe_hdr.LAST_UPDATED_BY         := l_user_id;
    l_recipe_hdr.LAST_UPDATE_DATE        := SYSDATE;
    l_recipe_hdr.LAST_UPDATE_LOGIN       := l_login_id;
    l_recipe_hdr.OWNER_ID                := l_recipe_rec.owner_id;
    l_recipe_hdr.CALCULATE_STEP_QUANTITY := l_recipe_rec.calculate_step_quantity;

    l_recipe_flex.ATTRIBUTE_CATEGORY := l_recipe_rec.attribute_category;
    l_recipe_flex.ATTRIBUTE1         := l_recipe_rec.attribute1;
    l_recipe_flex.ATTRIBUTE2         := l_recipe_rec.attribute2;
    l_recipe_flex.ATTRIBUTE3         := l_recipe_rec.attribute3;
    l_recipe_flex.ATTRIBUTE4         := l_recipe_rec.attribute4;
    l_recipe_flex.ATTRIBUTE5         := l_recipe_rec.attribute5;
    l_recipe_flex.ATTRIBUTE6         := l_recipe_rec.attribute6;
    l_recipe_flex.ATTRIBUTE7         := l_recipe_rec.attribute7;
    l_recipe_flex.ATTRIBUTE8         := l_recipe_rec.attribute8;
    l_recipe_flex.ATTRIBUTE9         := l_recipe_rec.attribute9;
    l_recipe_flex.ATTRIBUTE10        := l_recipe_rec.attribute10;
    l_recipe_flex.ATTRIBUTE11        := l_recipe_rec.attribute11;
    l_recipe_flex.ATTRIBUTE12        := l_recipe_rec.attribute12;
    l_recipe_flex.ATTRIBUTE13        := l_recipe_rec.attribute13;
    l_recipe_flex.ATTRIBUTE14        := l_recipe_rec.attribute14;
    l_recipe_flex.ATTRIBUTE15        := l_recipe_rec.attribute15;
    l_recipe_flex.ATTRIBUTE16        := l_recipe_rec.attribute16;
    l_recipe_flex.ATTRIBUTE17        := l_recipe_rec.attribute17;
    l_recipe_flex.ATTRIBUTE18        := l_recipe_rec.attribute18;
    l_recipe_flex.ATTRIBUTE19        := l_recipe_rec.attribute19;
    l_recipe_flex.ATTRIBUTE20        := l_recipe_rec.attribute20;
    l_recipe_flex.ATTRIBUTE21        := l_recipe_rec.attribute21;
    l_recipe_flex.ATTRIBUTE22        := l_recipe_rec.attribute22;
    l_recipe_flex.ATTRIBUTE23        := l_recipe_rec.attribute23;
    l_recipe_flex.ATTRIBUTE24        := l_recipe_rec.attribute24;
    l_recipe_flex.ATTRIBUTE25        := l_recipe_rec.attribute25;
    l_recipe_flex.ATTRIBUTE26        := l_recipe_rec.attribute26;
    l_recipe_flex.ATTRIBUTE27        := l_recipe_rec.attribute27;
    l_recipe_flex.ATTRIBUTE28        := l_recipe_rec.attribute28;
    l_recipe_flex.ATTRIBUTE29        := l_recipe_rec.attribute29;

    GMD_RECIPE_HEADER_PVT.Delete_Recipe_Header
                                       ( p_recipe_header_rec  => l_recipe_hdr
                                        ,p_flex_header_rec    => l_recipe_flex
                                        ,x_return_status      => l_status);

    IF (l_status <> 'S') THEN
      RAISE DELETE_RECIPE_EXCEPTION;
    END IF;

    COMMIT;

    EXCEPTION
      WHEN DELETE_RECIPE_EXCEPTION THEN
        FND_MSG_PUB.GET( p_msg_index     => 1,
                         p_data          => l_message,
                         p_encoded       => 'F',
                         p_msg_index_out => l_dummy);
        x_return_code := 'F';
        x_error_msg   := l_message;

      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('FND', 'FND_RECORD_CHANGED_ERROR');
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

  END Undelete_Recipe;


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
                                          x_error_msg        OUT NOCOPY VARCHAR2) IS

    l_return_status         VARCHAR2(2);
    l_msg_cnt               NUMBER;
    l_msg_dat               VARCHAR2(30);
    l_message               VARCHAR2(1000);
    l_dummy                 NUMBER;
    l_process_loss_rec      GMD_COMMON_VAL.process_loss_rec;
    l_recipe_theo_loss      GMD_PROCESS_LOSS.process_loss%TYPE;
    PR_LOSS_EXCEPTION       EXCEPTION;

  BEGIN

    x_error_msg        := '';
    x_return_code      := 'S';
    x_theoretical_loss := -1;

    l_process_loss_rec.formula_id := p_formula_id;
    l_process_loss_rec.routing_id := p_routing_Id;

    GMD_COMMON_VAL.Calculate_Process_Loss(process_loss       => l_process_loss_rec,
                                          Entity_type        => 'RECIPE',
                                          x_recipe_theo_loss => l_recipe_theo_loss,
                                          x_process_loss     => x_theoretical_loss,
                                          x_return_status    => l_return_status,
                                          x_msg_count        => l_msg_cnt,
                                          x_msg_data         => l_msg_dat);

    IF l_return_status <> 'S' THEN
      RAISE PR_LOSS_EXCEPTION;
    END IF;

    EXCEPTION
      WHEN PR_LOSS_EXCEPTION THEN
        FND_MSG_PUB.GET( p_msg_index     => 1,
                         p_data          => l_message,
                         p_encoded       => 'F',
                         p_msg_index_out => l_dummy);
        x_return_code := 'F';
        x_error_msg   := l_message;

      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'U';
        x_error_msg   := FND_MESSAGE.GET;

  END Get_Theoretical_Process_Loss;

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
                                         x_error_msg   OUT NOCOPY VARCHAR2) IS

    l_return_status        VARCHAR2(2);
    l_msg_cnt              NUMBER;
    l_msg_dat              VARCHAR2(2000);
    l_dummy                NUMBER;
    l_check                GMD_AUTO_STEP_CALC.calculatable_rec_type;
    l_ignore_mass_cv       BOOLEAN;
    l_ignore_vol_cv        BOOLEAN;
    CAL_QTY_EXCEPTION      EXCEPTION;

  BEGIN

    x_error_msg        := '';
    x_return_code      := 'S';

    l_check.parent_id := p_recipe_id;

    GMD_AUTO_STEP_CALC.check_step_qty_calculatable (
                                       p_check             => l_check,
                                       p_msg_count         => l_msg_cnt,
                                       p_msg_stack         => l_msg_dat,
                                       p_return_status     => l_return_status,
                                       p_ignore_mass_conv  => l_ignore_mass_cv,
                                       p_ignore_vol_conv   => l_ignore_vol_cv,
                                       P_organization_id   => Null);


    IF l_return_status <> 'S' THEN
      RAISE CAL_QTY_EXCEPTION;
    END IF;

    EXCEPTION
      WHEN CAL_QTY_EXCEPTION THEN
        FND_MSG_PUB.GET( p_msg_index     => 1,
                         p_data          => x_error_msg,
                         p_encoded       => 'F',
                         p_msg_index_out => l_dummy);
        x_return_code := 'F';

      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'U';
        x_error_msg   := FND_MESSAGE.GET;

  END Check_Step_Qty_Calculatable;


/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Copy_Recipe
 |
 |   DESCRIPTION
 |      Copy the given recipe, formula and routing
 |
 |   INPUT PARAMETERS
 |     p_copy_from_recipe_id   NUMBER
 |     p_recipe_no              VARCHAR2
 |     p_recipe_vers            NUMBER
 |     p_recipe_desc            VARCHAR2
 |     p_copy_from_formula_id  NUMBER
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
                           x_error_msg             OUT NOCOPY VARCHAR2) IS

    l_user_id                NUMBER := FND_PROFILE.VALUE('USER_ID');
    l_login_id               NUMBER := FND_PROFILE.VALUE('LOGIN_ID');

    CURSOR Cur_get_rcp_hdr IS
      SELECT *
      FROM   gmd_recipes
      WHERE  recipe_id = p_copy_from_recipe_id;

    CURSOR Cur_get_pp IS
      SELECT *
      FROM   gmd_recipe_process_parameters
      WHERE  recipe_id = p_copy_from_recipe_id;

    CURSOR Cur_get_vr IS
      SELECT *
      FROM   gmd_recipe_validity_rules
      WHERE  recipe_id = p_copy_from_recipe_id;

    CURSOR Cur_get_actv IS
      SELECT *
      FROM   gmd_recipe_orgn_activities
      WHERE  recipe_id = p_copy_from_recipe_id;

    CURSOR Cur_get_rsrc IS
      SELECT *
      FROM   gmd_recipe_orgn_resources
      WHERE  recipe_id  = p_copy_from_recipe_id;

     CURSOR Cur_get_rcp_stp IS
       SELECT *
       FROM   gmd_recipe_routing_steps
       WHERE  recipe_id = p_copy_from_recipe_id;

     CURSOR Cur_get_rcp_cust IS
       SELECT *
       FROM   gmd_recipe_customers
       WHERE  recipe_id = p_copy_from_recipe_id;

     CURSOR Cur_get_rcp_loss IS
       SELECT *
       FROM   gmd_recipe_process_loss
       WHERE  recipe_id = p_copy_from_recipe_id;

     CURSOR Cur_get_stp_mtl IS
       SELECT *
       FROM   gmd_recipe_step_materials
       WHERE  recipe_id = p_copy_from_recipe_id;

     CURSOR Cur_get_frm_hdr IS
       SELECT *
       FROM   fm_form_mst
       WHERE  formula_id = p_copy_from_formula_id;

     CURSOR Cur_get_frm_dtl IS
       SELECT *
       FROM   fm_matl_dtl
       WHERE  formula_id = p_copy_from_formula_id;

     CURSOR Cur_get_rtg_hdr IS
       SELECT *
       FROM   gmd_routings
       WHERE  routing_id = p_copy_from_routing_id;

     CURSOR Cur_get_rtg_dtl IS
       SELECT *
       FROM   fm_rout_dtl
       WHERE  routing_id = p_copy_from_routing_id;

     CURSOR Cur_get_step_dep IS
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

     CURSOR Cur_recipe_id IS
     SELECT gmd_recipe_id_s.NEXTVAL
     FROM   FND_DUAL;

     CURSOR Cur_loss_id IS
     SELECT gmd_recipe_process_loss_id_s.NEXTVAL
     FROM   FND_DUAL;

     CURSOR Cur_vr_id IS
     SELECT gmd_recipe_validity_id_s.NEXTVAL
     FROM   FND_DUAL;

     TYPE rcp_pp        IS TABLE OF Cur_get_pp%ROWTYPE       INDEX BY BINARY_INTEGER;
     TYPE rcp_vr        IS TABLE OF Cur_get_vr%ROWTYPE       INDEX BY BINARY_INTEGER;
     TYPE rcp_rsrc      IS TABLE OF Cur_get_rsrc%ROWTYPE     INDEX BY BINARY_INTEGER;
     TYPE rcp_actv      IS TABLE OF Cur_get_actv%ROWTYPE     INDEX BY BINARY_INTEGER;
     TYPE stp_mtl_tab   IS TABLE OF Cur_get_stp_mtl%ROWTYPE  INDEX BY BINARY_INTEGER;
     TYPE rcp_loss_tab  IS TABLE OF Cur_get_rcp_loss%ROWTYPE INDEX BY BINARY_INTEGER;
     TYPE rcp_cust_tab  IS TABLE OF Cur_get_rcp_cust%ROWTYPE INDEX BY BINARY_INTEGER;
     TYPE rcp_stp_tab   IS TABLE OF Cur_get_rcp_stp%ROWTYPE  INDEX BY BINARY_INTEGER;
     TYPE frm_dtl_tab   IS TABLE OF Cur_get_frm_dtl%ROWTYPE  INDEX BY BINARY_INTEGER;
     TYPE rtg_dtl_tab   IS TABLE OF Cur_get_rtg_dtl%ROWTYPE  INDEX BY BINARY_INTEGER;
     TYPE step_dep_tab  IS TABLE OF Cur_get_step_dep%ROWTYPE INDEX BY BINARY_INTEGER;
     TYPE text_tab      IS TABLE OF Get_Text%ROWTYPE         INDEX BY BINARY_INTEGER;

     l_rcp_hdr_rec              Cur_get_rcp_hdr%ROWTYPE;
     l_rcp_pp_tbl               rcp_pp;
     l_rcp_actv_tbl             rcp_actv;
     l_rcp_vr_tbl               rcp_vr;
     l_rcp_rsrc_tbl             rcp_rsrc;
     l_stp_mtl_tbl              stp_mtl_tab;
     l_rcp_stp_tbl              rcp_stp_tab;
     l_rcp_loss_tbl             rcp_loss_tab;
     l_rcp_cust_tbl             rcp_cust_tab;
     l_frm_hdr_rec              Cur_get_frm_hdr%ROWTYPE;
     l_frm_hdr_rec2             Cur_get_frm_hdr%ROWTYPE;
     l_frm_dtl_tbl              frm_dtl_tab;
     l_rtg_hdr_rec              Cur_get_rtg_hdr%ROWTYPE;
     l_rtg_hdr_rec2             Cur_get_rtg_hdr%ROWTYPE;
     l_rtg_dtl_tbl              rtg_dtl_tab;
     l_step_dep_tbl             step_dep_tab;
     l_rcp_actv_text_tbl        text_tab;
     l_rcp_vr_text_tbl          text_tab;
     l_rcp_rsrc_text_tbl        text_tab;
     l_rcp_stp_text_tbl         text_tab;
     l_stp_mtl_text_tbl         text_tab;
     l_rcp_loss_text_tbl        text_tab;
     l_rcp_cust_text_tbl        text_tab;
     l_rcp_hdr_text_tbl         text_tab;
     l_frm_dtl_text_tbl         text_tab;
     l_frm_hdr_text_tbl         text_tab;
     l_rtg_dtl_text_tbl         text_tab;
     l_rtg_hdr_text_tbl         text_tab;
     l_row                      NUMBER := 0;
     l_txt_ind                  NUMBER;
     l_rowid                    VARCHAR2(32);
     l_text_code                NUMBER(10);
     l_user_org                 VARCHAR2(4);
     l_error_msg                VARCHAR2(2000);
     l_return_code              VARCHAR2(2);
     l_message_count            NUMBER;
     l_message_list             VARCHAR2(2000);
     l_table_lnk                VARCHAR2(80);
     l_routingstep_id           NUMBER(15);
     l_formulaline_id           NUMBER(15);
     l_dummy                    NUMBER;
     l_formula_id               NUMBER;
     l_routing_id               NUMBER;
     l_loss_id                  NUMBER;
     l_vr_id                    NUMBER;
     l_copy_recipe              BOOLEAN;
     l_copy_formula             BOOLEAN;
     l_copy_routing             BOOLEAN;
     l_routing_update_allowed   BOOLEAN;
     l_new_routing              BOOLEAN;
     l_rtg_upd_tbl              GMD_ROUTINGS_PUB.update_tbl_type;
     l_recipe_tbl               GMD_RECIPE_HEADER.recipe_hdr;
     l_recipe_update_flex       GMD_RECIPE_HEADER.flex;
     COPY_RECIPE_EXCEPTION      EXCEPTION;
     COPY_ROUTING_EXCEPTION     EXCEPTION;
     COPY_FORMULA_EXCEPTION     EXCEPTION;
     COPY_FORM_DTL_EXCEPTION    EXCEPTION;
     GET_SURROGATE_EXCEPTION    EXCEPTION;
     COPY_HEADER_TEXT_EXCEPTION EXCEPTION;
     RECIPE_NOT_FOUND           EXCEPTION;
     FORMULA_NOT_FOUND          EXCEPTION;
     ROUTING_NOT_FOUND          EXCEPTION;
     PROCEDURE_EXCEPTION        EXCEPTION;

  BEGIN

    x_error_msg   := '';
    x_return_code := FND_API.G_RET_STS_SUCCESS;

    x_recipe_id  := -1;
    x_routing_id := -1;
    x_formula_id := -1;

    ---
    --- Load recipe header
    ---
    OPEN Cur_get_rcp_hdr;
    FETCH Cur_get_rcp_hdr INTO l_rcp_hdr_rec;
    CLOSE Cur_get_rcp_hdr;

    IF l_rcp_hdr_rec.recipe_id IS NULL THEN
      RAISE RECIPE_NOT_FOUND;
    ELSE
      IF l_rcp_hdr_rec.recipe_no      <> p_recipe_no OR
         l_rcp_hdr_rec.recipe_version <> p_recipe_vers THEN
        l_copy_recipe := TRUE;
      ELSE
        l_copy_recipe := FALSE;
      END IF;
    END IF;

    ---
    --- Load recipe header text
    ---
    IF (l_rcp_hdr_rec.text_code IS NOT NULL) THEN
      l_txt_ind := 0;

      FOR get_txt_rec IN Get_Text (l_rcp_hdr_rec.text_code) LOOP
        l_txt_ind := l_txt_ind + 1;
        l_rcp_hdr_text_tbl(l_txt_ind) := get_txt_rec;
      END LOOP;
    END IF;

    l_txt_ind := 0;
    l_row     := 0;

    ---
    --- Load recipe steps
    ---
    FOR get_rec IN Cur_get_rcp_stp LOOP

      l_row := l_row + 1;
      l_rcp_stp_tbl(l_row) := get_rec;

      IF (get_rec.text_code IS NOT NULL) THEN

        --- Load text for this step line
        FOR get_txt_rec IN Get_Text (get_rec.text_code) LOOP
          l_txt_ind := l_txt_ind + 1;
          l_rcp_stp_text_tbl(l_txt_ind) := get_txt_rec;
        END LOOP;

      END IF;

    END LOOP;

    l_txt_ind := 0;
    l_row     := 0;

    ---
    --- Load recipe customers
    ---
    FOR get_rec IN Cur_get_rcp_cust LOOP

      l_row := l_row + 1;
      l_rcp_cust_tbl(l_row) := get_rec;

      IF (get_rec.text_code IS NOT NULL) THEN

        --- Load text for this customer line
        FOR get_txt_rec IN Get_Text (get_rec.text_code) LOOP
          l_txt_ind := l_txt_ind + 1;
          l_rcp_cust_text_tbl(l_txt_ind) := get_txt_rec;
        END LOOP;

      END IF;

    END LOOP;

    l_txt_ind := 0;
    l_row     := 0;

    ---
    --- Load recipe process losses
    ---
    FOR get_rec IN Cur_get_rcp_loss LOOP

      l_row := l_row + 1;
      l_rcp_loss_tbl(l_row) := get_rec;

      IF (get_rec.text_code IS NOT NULL) THEN

        --- Load text for this process loss line
        FOR get_txt_rec IN Get_Text (get_rec.text_code) LOOP
          l_txt_ind := l_txt_ind + 1;
          l_rcp_loss_text_tbl(l_txt_ind) := get_txt_rec;
        END LOOP;

      END IF;

    END LOOP;

    l_txt_ind := 0;
    l_row     := 0;

    ---
    --- Load step/material associations
    ---
    FOR get_rec IN Cur_get_stp_mtl LOOP

      l_row := l_row + 1;
      l_stp_mtl_tbl(l_row) := get_rec;

      IF (get_rec.text_code IS NOT NULL) THEN

        --- Load text for this step/item line
        FOR get_txt_rec IN Get_Text (get_rec.text_code) LOOP
          l_txt_ind := l_txt_ind + 1;
          l_stp_mtl_text_tbl(l_txt_ind) := get_txt_rec;
        END LOOP;

      END IF;

    END LOOP;

    l_txt_ind := 0;
    l_row     := 0;

    ---
    --- Load validity rules
    ---
    FOR get_rec IN Cur_get_vr LOOP

      l_row := l_row + 1;
      l_rcp_vr_tbl(l_row) := get_rec;

      IF (get_rec.text_code IS NOT NULL) THEN

        --- Load text for this validity rule
        FOR get_txt_rec IN Get_Text (get_rec.text_code) LOOP
          l_txt_ind := l_txt_ind + 1;
          l_rcp_vr_text_tbl(l_txt_ind) := get_txt_rec;
        END LOOP;

      END IF;

    END LOOP;

    l_txt_ind := 0;
    l_row     := 0;

    ---
    --- Load organization specific resource information
    ---
    FOR get_rec IN Cur_get_rsrc LOOP

      l_row := l_row + 1;
      l_rcp_rsrc_tbl(l_row) := get_rec;

      IF (get_rec.text_code IS NOT NULL) THEN

        --- Load text for this resource
        FOR get_txt_rec IN Get_Text (get_rec.text_code) LOOP
          l_txt_ind := l_txt_ind + 1;
          l_rcp_rsrc_text_tbl(l_txt_ind) := get_txt_rec;
        END LOOP;

      END IF;

    END LOOP;

    l_txt_ind := 0;
    l_row     := 0;

    ---
    --- Load organization specific activity information
    ---
    FOR get_rec IN Cur_get_actv LOOP

      l_row := l_row + 1;
      l_rcp_actv_tbl(l_row) := get_rec;

      IF (get_rec.text_code IS NOT NULL) THEN

        --- Load text for this activity
        FOR get_txt_rec IN Get_Text (get_rec.text_code) LOOP
          l_txt_ind := l_txt_ind + 1;
          l_rcp_actv_text_tbl(l_txt_ind) := get_txt_rec;
        END LOOP;

      END IF;

    END LOOP;

    ---
    --- Load process parameters
    ---
    FOR get_rec IN Cur_get_pp LOOP

      l_row := l_row + 1;
      l_rcp_pp_tbl(l_row) := get_rec;

    END LOOP;

    ---
    --- Load formula header
    ---
    OPEN Cur_get_frm_hdr;
    FETCH Cur_get_frm_hdr INTO l_frm_hdr_rec;
    CLOSE Cur_get_frm_hdr;

    IF l_frm_hdr_rec.formula_id IS NULL THEN
      RAISE FORMULA_NOT_FOUND;
    ELSE
      IF l_frm_hdr_rec.formula_no   <> p_formula_no OR
         l_frm_hdr_rec.formula_vers <> p_formula_vers THEN
        l_copy_formula := TRUE;
      ELSE
        l_copy_formula := FALSE;
      END IF;
    END IF;

    ---
    --- Load formula header text
    ---
    IF (l_frm_hdr_rec.text_code IS NOT NULL) THEN
      l_txt_ind := 0;

      FOR get_txt_rec IN Get_Text (l_frm_hdr_rec.text_code) LOOP
        l_txt_ind := l_txt_ind + 1;
        l_frm_hdr_text_tbl(l_txt_ind) := get_txt_rec;
      END LOOP;
    END IF;

    l_txt_ind := 0;
    l_row     := 0;

    ---
    --- Load fromula details
    ---
    FOR get_rec IN Cur_get_frm_dtl LOOP

      l_row := l_row + 1;
      l_frm_dtl_tbl(l_row) := get_rec;

      IF (get_rec.text_code IS NOT NULL) THEN

        --- Load text for this item line
        FOR get_txt_rec IN Get_Text (get_rec.text_code) LOOP
          l_txt_ind := l_txt_ind + 1;
          l_frm_dtl_text_tbl(l_txt_ind) := get_txt_rec;
        END LOOP;

      END IF;

    END LOOP;

    --- Routing is not a mandatory component. So we need to make sure the
    --- current recipe is using a routing.
    IF l_rcp_hdr_rec.routing_id IS NOT NULL THEN
      ---
      --- Load routing header
      ---
      OPEN Cur_get_rtg_hdr;
      FETCH Cur_get_rtg_hdr INTO l_rtg_hdr_rec;
      CLOSE Cur_get_rtg_hdr;

      IF l_rtg_hdr_rec.routing_id IS NULL THEN
        RAISE ROUTING_NOT_FOUND;
      ELSE
        IF l_rtg_hdr_rec.routing_no   <> p_routing_no OR
           l_rtg_hdr_rec.routing_vers <> p_routing_vers THEN
          l_copy_routing := TRUE;
        ELSE
          l_copy_routing := FALSE;
        END IF;
      END IF;

      ---
      --- Load routing header text
      ---
      IF (l_rtg_hdr_rec.text_code IS NOT NULL) THEN
        l_txt_ind := 0;

        FOR get_txt_rec IN Get_Text (l_rtg_hdr_rec.text_code) LOOP
          l_txt_ind := l_txt_ind + 1;
          l_rtg_hdr_text_tbl(l_txt_ind) := get_txt_rec;
        END LOOP;
      END IF;

      l_txt_ind := 0;
      l_row     := 0;

      ---
      --- Load routing details
      ---
      FOR get_rec IN Cur_get_rtg_dtl LOOP

        l_row := l_row + 1;
        l_rtg_dtl_tbl(l_row) := get_rec;

        IF (get_rec.text_code IS NOT NULL) THEN

          --- Load text for this step
          FOR get_txt_rec IN Get_Text (get_rec.text_code) LOOP
            l_txt_ind := l_txt_ind + 1;
            l_rtg_dtl_text_tbl(l_txt_ind) := get_txt_rec;
          END LOOP;

        END IF;

      END LOOP;
      l_row := 0;

      ---
      --- Load routing step dependencies
      ---
      FOR get_dep IN Cur_get_step_dep LOOP
        l_row := l_row + 1;
        l_step_dep_tbl(l_row) := get_dep;
      END LOOP;

    END IF;

    ---
    --- Do not commit pending changes to the original recipe,formula
    --- and routing
    ---
    ROLLBACK;


    SAVEPOINT Copy_Recipe;

    ---
    --- Process formula
    ---
    IF l_rcp_hdr_rec.formula_id IS NOT NULL THEN

      IF l_copy_formula THEN
        x_formula_id := GMDSURG.get_surrogate('formula_id');
        IF (x_formula_id < 1) THEN
          RAISE GET_SURROGATE_EXCEPTION;
        END IF;
      ELSE
        x_formula_id := l_rcp_hdr_rec.formula_id;
      END IF;

      IF (l_frm_hdr_text_tbl.COUNT > 0) THEN

        IF l_copy_formula THEN
          OPEN  Get_Text_Code;
          FETCH Get_Text_Code INTO l_text_code;
          CLOSE Get_Text_Code;
        ELSE
          l_text_code := l_frm_hdr_rec.text_code;
          DELETE fm_text_tbl WHERE text_code = l_text_code;
        END IF;

        l_txt_ind := 0;

        FOR i IN 1..l_frm_hdr_text_tbl.COUNT LOOP

          l_txt_ind := l_txt_ind + 1;
          l_table_lnk := 'fm_form_mst' || '|' || x_formula_id;

          ---
          --- Create formula header text
          ---
          GMD_RECIPE_DESIGNER_PKG.Create_Text_Row
              (p_text_code      => l_text_code,
               p_lang_code      => l_frm_hdr_text_tbl(l_txt_ind).lang_code,
               p_text           => l_frm_hdr_text_tbl(l_txt_ind).text,
               p_line_no        => l_frm_hdr_text_tbl(l_txt_ind).line_no,
               p_paragraph_code => l_frm_hdr_text_tbl(l_txt_ind).paragraph_code,
               p_sub_paracode   => l_frm_hdr_text_tbl(l_txt_ind).sub_paracode,
               p_table_lnk      => l_table_lnk,
               p_user_id        => l_user_id,
               x_row_id         => l_rowid,
               x_return_code    => l_return_code,
               x_error_msg      => l_error_msg);

          IF (l_return_code <> 'S') THEN
            RAISE COPY_HEADER_TEXT_EXCEPTION;
          END IF;

        END LOOP;

      END IF;

      ---
      --- Create/update formula header record
      ---
      l_frm_hdr_rec.formula_id        := x_formula_id;
      l_frm_hdr_rec.formula_no        := p_formula_no;
      l_frm_hdr_rec.formula_vers      := p_formula_vers;
      l_frm_hdr_rec.formula_desc1     := p_formula_desc;
      l_frm_hdr_rec.text_code         := l_text_code;
      l_frm_hdr_rec.owner_id          := l_user_id;
      l_frm_hdr_rec.last_update_login := l_login_id;

      OPEN Cur_get_frm_hdr;
      FETCH Cur_get_frm_hdr INTO l_frm_hdr_rec2;

      IF l_copy_formula OR Cur_get_frm_hdr%NOTFOUND THEN

        l_frm_hdr_rec.delete_mark := 0;

        /*Bug 3953359 - Thomas Daniel */
        /*Added initializing of the formula status as New */
        l_frm_hdr_rec.formula_status    := 100;

        GMD_FORMULA_HEADER_PVT.Insert_FormulaHeader
             (  p_api_version        => 1.0
               ,p_init_msg_list      => FND_API.G_TRUE
               ,p_commit             => FND_API.G_FALSE
               ,x_return_status      => l_return_code
               ,x_msg_count          => l_message_count
               ,x_msg_data           => l_message_list
               ,p_formula_header_rec => l_frm_hdr_rec
             );

      ELSE

        GMD_FORMULA_HEADER_PVT.Update_FormulaHeader
                  (  p_api_version         => 1.0
                    ,p_init_msg_list      => FND_API.G_TRUE
                    ,p_commit             => FND_API.G_FALSE
                    ,x_return_status      => l_return_code
                    ,x_msg_count          => l_message_count
                    ,x_msg_data           => l_message_list
                    ,p_formula_header_rec => l_frm_hdr_rec
                   );

      END IF;

      CLOSE Cur_get_frm_hdr;

      IF l_return_code <> 'S' THEN
        RAISE COPY_FORMULA_EXCEPTION;
      END IF;

      ---
      --- Insert formula detail records
      ---
      l_txt_ind := 1;

      IF NOT l_copy_formula THEN
        DELETE fm_matl_dtl WHERE formula_id = x_formula_id;
      END IF;

      FOR i IN 1..l_frm_dtl_tbl.count LOOP
        l_text_code := NULL;
        IF l_copy_formula THEN
          l_formulaline_id := GMDSURG.get_surrogate('formulaline_id');
          ---
          --- Update the step/item asociation table with the new line id
          ---
          FOR j IN 1..l_stp_mtl_tbl.COUNT LOOP
            IF l_stp_mtl_tbl(j).formulaline_id =
               l_frm_dtl_tbl(i).formulaline_id THEN
       ---       l_frm_dtl_tbl(j).formulaline_id := l_formulaline_id;
               l_stp_mtl_tbl(j).formulaline_id := l_formulaline_id;
              EXIT;
            END IF;
          END LOOP;
        ELSE
          l_formulaline_id := l_frm_dtl_tbl(i).formulaline_id;
        END IF;

        IF (l_formulaline_id < 1) THEN
          RAISE GET_SURROGATE_EXCEPTION;
        END IF;

        IF (l_frm_dtl_tbl(i).text_code > 0) THEN

          IF l_copy_formula THEN
            OPEN  Get_Text_Code;
            FETCH Get_Text_Code INTO l_text_code;
            CLOSE Get_Text_Code;
          ELSE
            l_text_code := l_frm_dtl_tbl(i).text_code;
            DELETE fm_text_tbl WHERE text_code = l_text_code;
          END IF;

          l_table_lnk := 'fm_matl_dtl' || '|' || x_formula_id || '|' ||
                       l_formulaline_id;

          WHILE (l_txt_ind <= l_frm_dtl_text_tbl.COUNT AND
                 l_frm_dtl_text_tbl(l_txt_ind).text_code  =
                 l_frm_dtl_tbl(i).text_code) LOOP

            ---
            --- Create formula item text
            ---
            GMD_RECIPE_DESIGNER_PKG.Create_Text_Row
            (p_text_code      => l_text_code,
             p_lang_code      => l_frm_dtl_text_tbl(l_txt_ind).lang_code,
             p_text           => l_frm_dtl_text_tbl(l_txt_ind).text,
             p_line_no        => l_frm_dtl_text_tbl(l_txt_ind).line_no,
             p_paragraph_code => l_frm_dtl_text_tbl(l_txt_ind).paragraph_code,
             p_sub_paracode   => l_frm_dtl_text_tbl(l_txt_ind).sub_paracode,
             p_table_lnk      => l_table_lnk,
             p_user_id        => l_user_id,
             x_row_id         => l_rowid,
             x_return_code    => l_return_code,
             x_error_msg      => l_error_msg);

             IF (l_return_code <> 'S') THEN
               RAISE COPY_HEADER_TEXT_EXCEPTION;
             END IF;

             l_txt_ind := l_txt_ind + 1;

          END LOOP;

        END IF;

        ---
        --- Create formula item lines
        ---
        l_frm_dtl_tbl(i).formula_id     := x_formula_id;
        l_frm_dtl_tbl(i).formulaline_id := l_formulaline_id;
        l_frm_dtl_tbl(i).text_code      := l_text_code;
        GMD_FORMULA_DETAIL_PVT.Insert_FormulaDetail
                     (  p_api_version        => 1.0
                       ,p_init_msg_list      => FND_API.G_TRUE
                       ,p_commit             => FND_API.G_FALSE
                       ,x_return_status      => l_return_code
                       ,x_msg_count          => l_message_count
                       ,x_msg_data           => l_message_list
                       ,p_formula_detail_rec => l_frm_dtl_tbl(i)
                     );

        IF l_return_code <> 'S' THEN
          RAISE COPY_FORM_DTL_EXCEPTION;
        END IF;

      END LOOP;
    END IF;


    ---
    --- Process routing
    ---
    IF l_rcp_hdr_rec.routing_id IS NOT NULL THEN

      OPEN Cur_get_rtg_hdr;
      FETCH Cur_get_rtg_hdr INTO l_rtg_hdr_rec2;

      IF Cur_get_rtg_hdr%NOTFOUND THEN
        l_new_routing  := TRUE;
        l_routing_update_allowed := TRUE;
      ELSE
        l_new_routing := FALSE;
        l_routing_update_allowed := GMD_COMMON_VAL.UPDATE_ALLOWED(
                                        Entity => 'ROUTING',
                                        Entity_id => l_rcp_hdr_rec.routing_id);
      END IF;

      CLOSE Cur_get_rtg_hdr;

      x_routing_id := l_rcp_hdr_rec.routing_id;

      IF l_copy_routing OR l_routing_update_allowed THEN

        IF l_copy_routing THEN
          x_routing_id := GMDSURG.get_surrogate('routing_id');
          IF (x_routing_id < 1) THEN
            RAISE GET_SURROGATE_EXCEPTION;
          END IF;
        END IF;

        IF (l_rtg_hdr_text_tbl.COUNT > 0) THEN

          IF l_copy_routing THEN
            OPEN  Get_Text_Code;
            FETCH Get_Text_Code INTO l_text_code;
            CLOSE Get_Text_Code;
          ELSE
            l_text_code := l_rtg_hdr_rec.text_code;
            DELETE fm_text_tbl WHERE text_code = l_text_code;
          END IF;

          l_txt_ind := 0;

          FOR i IN 1..l_rtg_hdr_text_tbl.COUNT LOOP

            l_txt_ind := l_txt_ind + 1;
            l_table_lnk := 'gmd_routings' || '|' || x_routing_id;

            ---
            --- Create routing header text
            ---
            GMD_RECIPE_DESIGNER_PKG.Create_Text_Row
              (p_text_code      => l_text_code,
               p_lang_code      => l_rtg_hdr_text_tbl(l_txt_ind).lang_code,
               p_text           => l_rtg_hdr_text_tbl(l_txt_ind).text,
               p_line_no        => l_rtg_hdr_text_tbl(l_txt_ind).line_no,
               p_paragraph_code => l_rtg_hdr_text_tbl(l_txt_ind).paragraph_code,
               p_sub_paracode   => l_rtg_hdr_text_tbl(l_txt_ind).sub_paracode,
               p_table_lnk      => l_table_lnk,
               p_user_id        => l_user_id,
               x_row_id         => l_rowid,
               x_return_code    => l_return_code,
               x_error_msg      => l_error_msg);

            IF (l_return_code <> 'S') THEN
              RAISE COPY_HEADER_TEXT_EXCEPTION;
            END IF;

          END LOOP;

        END IF;

        ---
        --- Create routing header record
        ---
        l_rtg_hdr_rec.routing_id        := x_routing_id;
        l_rtg_hdr_rec.routing_no        := p_routing_no;
        l_rtg_hdr_rec.routing_vers      := p_routing_vers;
        l_rtg_hdr_rec.routing_desc      := p_routing_desc;
      --  l_rtg_hdr_rec.owner_organization_id   := p_orgn_id;
        l_rtg_hdr_rec.text_code         := l_text_code;
        l_rtg_hdr_rec.owner_id          := l_user_id;
        l_rtg_hdr_rec.last_update_login := l_login_id;


        IF l_copy_routing OR l_new_routing THEN

          /*Bug 3953359 - Thomas Daniel */
          /*Added initializing of the routing status as New */
          l_rtg_hdr_rec.routing_status  := 100;

          GMD_ROUTINGS_PVT.Insert_Routing ( p_routings      => l_rtg_hdr_rec
                                           ,x_message_count => l_message_count
                                           ,x_message_list  => l_message_list
                                           ,x_return_status => l_return_code);
          IF l_return_code <> 'S' THEN
            RAISE COPY_ROUTING_EXCEPTION;
          END IF;

        ELSE

          GMD_ROUTING_DESIGNER_PKG.Update_Routing_Header
              ( p_routing_id           => x_routing_id,
                p_routing_no           => p_routing_no,
                p_routing_vers         => p_routing_vers,
                p_routing_desc         => p_routing_desc,
                p_routing_class        => l_rtg_hdr_rec.routing_class,
                p_effective_start_date => l_rtg_hdr_rec.effective_start_date,
                p_effective_end_date   => l_rtg_hdr_rec.effective_end_date,
                p_routing_qty          => l_rtg_hdr_rec.routing_qty,
                p_routing_uom          => l_rtg_hdr_rec.routing_uom,
                p_process_loss         => l_rtg_hdr_rec.process_loss,
                p_owner_id             => l_rtg_hdr_rec.owner_id,
                p_owner_orgn_id        => l_rtg_hdr_rec.owner_organization_id,
                p_enforce_step_dep     => l_rtg_hdr_rec.enforce_step_dependency,
                p_last_update_date     => l_rtg_hdr_rec.last_update_date,
                p_user_id              =>  l_user_id,
                p_last_update_date_orig => l_rtg_hdr_rec.last_update_date,
                p_update_release_type   => 0,
                p_contiguous_ind       => l_rtg_hdr_rec.contiguous_ind,
                x_return_code           => l_return_code,
                x_error_msg             => x_error_msg);

          IF l_return_code <> 'S' THEN
            RAISE PROCEDURE_EXCEPTION;
          END IF;

        END IF;

        ---
        --- Insert routing detail records
        ---
        l_txt_ind := 1;

        IF NOT l_copy_routing THEN
          DELETE fm_rout_dep WHERE routing_id = x_routing_id;
          DELETE fm_rout_dtl WHERE routing_id = x_routing_id;
        END IF;

        FOR i IN 1..l_rtg_dtl_tbl.COUNT LOOP
          l_text_code := NULL;

          IF l_copy_routing THEN
            l_routingstep_id := GMDSURG.get_surrogate('routingstep_id');
            IF (l_routingstep_id < 1) THEN
              RAISE GET_SURROGATE_EXCEPTION;
            END IF;
            ---
            --- Update the step/item asociation table with the new step id
            ---
            FOR j IN 1..l_stp_mtl_tbl.COUNT LOOP
              IF l_stp_mtl_tbl(j).routingstep_id =
                 l_rtg_dtl_tbl(i).routingstep_id THEN
                l_stp_mtl_tbl(j).routingstep_id := l_routingstep_id;
              END IF;
            END LOOP;

            ---
            --- Update the recipe step table with the new step id
            ---
            FOR j IN 1..l_rcp_stp_tbl.COUNT LOOP
              IF l_rcp_stp_tbl(j).routingstep_id =
                 l_rtg_dtl_tbl(i).routingstep_id THEN
                l_rcp_stp_tbl(j).routingstep_id := l_routingstep_id;
                EXIT;
              END IF;
            END LOOP;

            ---
            --- Update the organization resource table with the new step id
            ---
            FOR j IN 1..l_rcp_rsrc_tbl.COUNT LOOP
              IF l_rcp_rsrc_tbl(j).routingstep_id =
                 l_rtg_dtl_tbl(i).routingstep_id THEN
                l_rcp_rsrc_tbl(j).routingstep_id := l_routingstep_id;
              END IF;
            END LOOP;

            ---
            --- Update the organization activity table with the new step id
            ---
            FOR j IN 1..l_rcp_actv_tbl.COUNT LOOP
              IF l_rcp_actv_tbl(j).routingstep_id =
                 l_rtg_dtl_tbl(i).routingstep_id THEN
                l_rcp_actv_tbl(j).routingstep_id := l_routingstep_id;
              END IF;
            END LOOP;

            ---
            --- Update the process parameter table with the new step id
            ---
            FOR j IN 1..l_rcp_pp_tbl.COUNT LOOP
              IF l_rcp_pp_tbl(j).routingstep_id =
                 l_rtg_dtl_tbl(i).routingstep_id THEN
                l_rcp_pp_tbl(j).routingstep_id := l_routingstep_id;
                EXIT;
              END IF;
            END LOOP;
          ELSE
            l_routingstep_id := l_rtg_dtl_tbl(i).routingstep_id;
          END IF;

          IF (l_rtg_dtl_tbl(i).text_code > 0) THEN

            IF l_copy_routing THEN
              OPEN  Get_Text_Code;
              FETCH Get_Text_Code INTO l_text_code;
              CLOSE Get_Text_Code;
            ELSE
              l_text_code := l_rtg_dtl_tbl(i).text_code;
              DELETE fm_text_tbl WHERE text_code = l_text_code;
            END IF;

            l_table_lnk := 'fm_rout_dtl' || '|' || x_routing_id || '|' ||
                         l_routingstep_id;

            WHILE (l_txt_ind <= l_rtg_dtl_text_tbl.COUNT AND
                   l_rtg_dtl_text_tbl(l_txt_ind).text_code  =
                   l_rtg_dtl_tbl(i).text_code) LOOP

              ---
              --- Create routing step text
              ---
              GMD_RECIPE_DESIGNER_PKG.Create_Text_Row
              (p_text_code      => l_text_code,
               p_lang_code      => l_rtg_dtl_text_tbl(l_txt_ind).lang_code,
               p_text           => l_rtg_dtl_text_tbl(l_txt_ind).text,
               p_line_no        => l_rtg_dtl_text_tbl(l_txt_ind).line_no,
               p_paragraph_code => l_rtg_dtl_text_tbl(l_txt_ind).paragraph_code,
               p_sub_paracode   => l_rtg_dtl_text_tbl(l_txt_ind).sub_paracode,
               p_table_lnk      => l_table_lnk,
               p_user_id        => l_user_id,
               x_row_id         => l_rowid,
               x_return_code    => l_return_code,
               x_error_msg      => l_error_msg);


               IF (l_return_code <> 'S') THEN
                 RAISE COPY_HEADER_TEXT_EXCEPTION;
               END IF;

               l_txt_ind := l_txt_ind + 1;

            END LOOP;

          END IF;

          ---
          --- Create routing step
          ---

          l_rtg_dtl_tbl(i).routingstep_id := l_routingstep_id;
          l_rtg_dtl_tbl(i).text_code      := l_text_code;

         GMD_ROUTING_STEPS_PVT.Insert_Routing_Steps
                 ( p_routing_id       => x_routing_id
                  ,p_routing_step_rec => l_rtg_dtl_tbl(i)
                  ,x_return_status    => l_return_code);

        END LOOP;
        ---
        --- Insert routing step dependencies records
        ---
        FOR i IN 1..l_step_dep_tbl.COUNT LOOP

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
        VALUES    (l_step_dep_tbl(i).ROUTINGSTEP_NO,
                 l_step_dep_tbl(i).DEP_ROUTINGSTEP_NO,
                 x_routing_id,
                 l_step_dep_tbl(i).DEP_TYPE,
                 l_step_dep_tbl(i).REWORK_CODE,
                 l_step_dep_tbl(i).STANDARD_DELAY,
                 l_step_dep_tbl(i).MINIMUM_DELAY,
                 l_step_dep_tbl(i).MAX_DELAY,
                 l_step_dep_tbl(i).TRANSFER_QTY,
                 l_step_dep_tbl(i).ROUTINGSTEP_NO_UOM,
                 l_step_dep_tbl(i).TEXT_CODE,
                 l_user_id,
                 l_user_id,
                 SYSDATE,
                 SYSDATE,
                 l_login_id,
                 l_step_dep_tbl(i).TRANSFER_PCT);
        END LOOP;

      END IF;

    END IF;

    ---
    --- Process recipe
    ---

    IF l_rcp_hdr_rec.recipe_id IS NOT NULL THEN

      IF l_copy_recipe THEN
        OPEN Cur_recipe_id;
        FETCH Cur_recipe_id INTO x_recipe_id;
        CLOSE Cur_recipe_id;
        IF (x_recipe_id < 1) THEN
          RAISE GET_SURROGATE_EXCEPTION;
        END IF;
      ELSE
        x_recipe_id := l_rcp_hdr_rec.recipe_id;
      END IF;

      IF (l_rcp_hdr_text_tbl.COUNT > 0) THEN

        IF l_copy_recipe THEN
          OPEN  Get_Text_Code;
          FETCH Get_Text_Code INTO l_text_code;
          CLOSE Get_Text_Code;
        ELSE
          l_text_code := l_rcp_hdr_rec.text_code;
          DELETE fm_text_tbl WHERE text_code = l_text_code;
        END IF;

        l_txt_ind := 0;

        FOR i IN 1..l_rcp_hdr_text_tbl.COUNT LOOP

          l_txt_ind := l_txt_ind + 1;
          l_table_lnk := 'gmd_recipes' || '|' || x_recipe_id;

          ---
          --- Create recipe header text
          ---
          GMD_RECIPE_DESIGNER_PKG.Create_Text_Row
              (p_text_code      => l_text_code,
               p_lang_code      => l_rcp_hdr_text_tbl(l_txt_ind).lang_code,
               p_text           => l_rcp_hdr_text_tbl(l_txt_ind).text,
               p_line_no        => l_rcp_hdr_text_tbl(l_txt_ind).line_no,
               p_paragraph_code => l_rcp_hdr_text_tbl(l_txt_ind).paragraph_code,
               p_sub_paracode   => l_rcp_hdr_text_tbl(l_txt_ind).sub_paracode,
               p_table_lnk      => l_table_lnk,
               p_user_id        => l_user_id,
               x_row_id         => l_rowid,
               x_return_code    => l_return_code,
               x_error_msg      => l_error_msg);

          IF (l_return_code <> 'S') THEN
            RAISE COPY_HEADER_TEXT_EXCEPTION;
          END IF;

        END LOOP;

      END IF;

      ---
      --- Create recipe header record
      ---

      IF NOT l_copy_recipe THEN
        DELETE gmd_recipes_b WHERE recipe_id = p_copy_from_recipe_id;
      END IF;

      IF x_routing_id <= 0 THEN
        l_recipe_tbl.ROUTING_ID := NULL;
      ELSE
        l_recipe_tbl.ROUTING_ID := x_routing_id;
      END IF;

      l_recipe_tbl.TEXT_CODE               := l_text_code;
      l_recipe_tbl.PROJECT_ID              := l_rcp_hdr_rec.project_id;
      l_recipe_tbl.OWNER_LAB_TYPE          := l_rcp_hdr_rec.owner_lab_type;
      l_recipe_tbl.RECIPE_NO               := p_recipe_no;
      l_recipe_tbl.RECIPE_VERSION          := p_recipe_vers;
      l_recipe_tbl.RECIPE_ID               := x_recipe_id;
      l_recipe_tbl.RECIPE_DESCRIPTION      := p_recipe_desc;
      l_recipe_tbl.USER_ID                 := l_user_id;
      l_recipe_tbl.OWNER_ORGANIZATION_ID   := l_rcp_hdr_rec.owner_organization_id;
      l_recipe_tbl.CREATION_ORGANIZATION_ID  := l_rcp_hdr_rec.creation_organization_id;
      l_recipe_tbl.FORMULA_ID              := x_formula_id;

      /*Bug 3953359 - Thomas Daniel */
      /*Added initializing of the routing status as New */
      l_recipe_tbl.RECIPE_STATUS           := 100;

      l_recipe_tbl.DELETE_MARK             := 0;
      l_recipe_tbl.CREATED_BY              := l_user_id;
      l_recipe_tbl.CREATION_DATE           := SYSDATE;
      l_recipe_tbl.LAST_UPDATED_BY         := l_user_id;
      l_recipe_tbl.LAST_UPDATE_DATE        := SYSDATE;
      l_recipe_tbl.LAST_UPDATE_LOGIN       := l_login_id;
      l_recipe_tbl.OWNER_ID                := l_user_id;
      l_recipe_tbl.CALCULATE_STEP_QUANTITY := l_rcp_hdr_rec.calculate_step_quantity;

      -- GMD-GMO changes
      l_recipe_tbl.ENHANCED_PI_IND := l_rcp_hdr_rec.enhanced_pi_ind;

      -- Include contitguous ind value
      l_recipe_tbl.CONTIGUOUS_IND := l_rcp_hdr_rec.contiguous_ind;

      l_recipe_tbl.recipe_type := l_rcp_hdr_rec.recipe_type;

      l_recipe_update_flex.ATTRIBUTE_CATEGORY := l_rcp_hdr_rec.attribute_category;
      l_recipe_update_flex.ATTRIBUTE1         := l_rcp_hdr_rec.attribute1;
      l_recipe_update_flex.ATTRIBUTE2         := l_rcp_hdr_rec.attribute2;
      l_recipe_update_flex.ATTRIBUTE3         := l_rcp_hdr_rec.attribute3;
      l_recipe_update_flex.ATTRIBUTE4         := l_rcp_hdr_rec.attribute4;
      l_recipe_update_flex.ATTRIBUTE5         := l_rcp_hdr_rec.attribute5;
      l_recipe_update_flex.ATTRIBUTE6         := l_rcp_hdr_rec.attribute6;
      l_recipe_update_flex.ATTRIBUTE7         := l_rcp_hdr_rec.attribute7;
      l_recipe_update_flex.ATTRIBUTE8         := l_rcp_hdr_rec.attribute8;
      l_recipe_update_flex.ATTRIBUTE9         := l_rcp_hdr_rec.attribute9;
      l_recipe_update_flex.ATTRIBUTE10        := l_rcp_hdr_rec.attribute10;
      l_recipe_update_flex.ATTRIBUTE11        := l_rcp_hdr_rec.attribute11;
      l_recipe_update_flex.ATTRIBUTE12        := l_rcp_hdr_rec.attribute12;
      l_recipe_update_flex.ATTRIBUTE13        := l_rcp_hdr_rec.attribute13;
      l_recipe_update_flex.ATTRIBUTE14        := l_rcp_hdr_rec.attribute14;
      l_recipe_update_flex.ATTRIBUTE15        := l_rcp_hdr_rec.attribute15;
      l_recipe_update_flex.ATTRIBUTE16        := l_rcp_hdr_rec.attribute16;
      l_recipe_update_flex.ATTRIBUTE17        := l_rcp_hdr_rec.attribute17;
      l_recipe_update_flex.ATTRIBUTE18        := l_rcp_hdr_rec.attribute18;
      l_recipe_update_flex.ATTRIBUTE19        := l_rcp_hdr_rec.attribute19;
      l_recipe_update_flex.ATTRIBUTE20        := l_rcp_hdr_rec.attribute20;
      l_recipe_update_flex.ATTRIBUTE21        := l_rcp_hdr_rec.attribute21;
      l_recipe_update_flex.ATTRIBUTE22        := l_rcp_hdr_rec.attribute22;
      l_recipe_update_flex.ATTRIBUTE23        := l_rcp_hdr_rec.attribute23;
      l_recipe_update_flex.ATTRIBUTE24        := l_rcp_hdr_rec.attribute24;
      l_recipe_update_flex.ATTRIBUTE25        := l_rcp_hdr_rec.attribute25;
      l_recipe_update_flex.ATTRIBUTE26        := l_rcp_hdr_rec.attribute26;
      l_recipe_update_flex.ATTRIBUTE27        := l_rcp_hdr_rec.attribute27;
      l_recipe_update_flex.ATTRIBUTE28        := l_rcp_hdr_rec.attribute28;
      l_recipe_update_flex.ATTRIBUTE29        := l_rcp_hdr_rec.attribute29;
      l_recipe_update_flex.ATTRIBUTE30        := l_rcp_hdr_rec.attribute30;

      GMD_RECIPE_HEADER_PVT.Create_Recipe_Header
                        ( p_recipe_header_rec   => l_recipe_tbl
                         ,p_recipe_hdr_flex_rec => l_recipe_update_flex
                         ,x_return_status       => l_return_code);

      IF l_return_code <> 'S' THEN
        RAISE COPY_RECIPE_EXCEPTION;
      END IF;

      ---
      --- Insert recipe step records
      ---
      l_txt_ind := 1;

      IF NOT l_copy_recipe THEN
        DELETE gmd_recipe_routing_steps WHERE recipe_id = p_copy_from_recipe_id;
      END IF;

      FOR i IN 1..l_rcp_stp_tbl.count LOOP

        IF (l_rcp_stp_tbl(i).text_code > 0) THEN

          IF l_copy_recipe THEN
            OPEN  Get_Text_Code;
            FETCH Get_Text_Code INTO l_text_code;
            CLOSE Get_Text_Code;
          ELSE
            l_text_code := l_rcp_stp_tbl(i).text_code;
            DELETE fm_text_tbl WHERE text_code = l_text_code;
          END IF;

          l_table_lnk := 'gmd_recipe_routing_steps' || '|' || x_recipe_id ||
                         '|' || l_rcp_stp_tbl(i).routingstep_id;

          WHILE (l_txt_ind <= l_rcp_stp_text_tbl.COUNT AND
                 l_rcp_stp_text_tbl(l_txt_ind).text_code  =
                 l_rcp_stp_tbl(i).text_code) LOOP

            ---
            --- Create recipe step text
            ---
            GMD_RECIPE_DESIGNER_PKG.Create_Text_Row
            (p_text_code      => l_text_code,
             p_lang_code      => l_rcp_stp_text_tbl(l_txt_ind).lang_code,
             p_text           => l_rcp_stp_text_tbl(l_txt_ind).text,
             p_line_no        => l_rcp_stp_text_tbl(l_txt_ind).line_no,
             p_paragraph_code => l_rcp_stp_text_tbl(l_txt_ind).paragraph_code,
             p_sub_paracode   => l_rcp_stp_text_tbl(l_txt_ind).sub_paracode,
             p_table_lnk      => l_table_lnk,
             p_user_id        => l_user_id,
             x_row_id         => l_rowid,
             x_return_code    => l_return_code,
             x_error_msg      => l_error_msg);

             IF (l_return_code <> 'S') THEN
               RAISE COPY_HEADER_TEXT_EXCEPTION;
             END IF;

             l_txt_ind := l_txt_ind + 1;

          END LOOP;

        END IF;

        ---
        --- Create recipe step lines
        ---
        l_rcp_stp_tbl(i).recipe_id := x_recipe_id;
        l_rcp_stp_tbl(i).text_code := l_text_code;

        INSERT INTO gmd_recipe_routing_steps
           (recipe_id,
            routingstep_id,
            step_qty,
            created_by,
            creation_date,
            last_update_date,
            last_update_login,
            text_code,
            last_updated_by,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15,
            attribute16,
            attribute17,
            attribute18,
            attribute19,
            attribute20,
            attribute21,
            attribute22,
            attribute23,
            attribute24,
            attribute25,
            attribute26,
            attribute27,
            attribute28,
            attribute29,
            attribute30,
            attribute_category,
            mass_std_uom,
            volume_std_uom,
            volume_qty, mass_qty)
        VALUES
            (x_recipe_id,
             l_rcp_stp_tbl(i).routingstep_id,
             l_rcp_stp_tbl(i).step_qty,
             l_user_id,
             SYSDATE,
             SYSDATE,
             l_login_id,
             l_rcp_stp_tbl(i).text_code,
             l_user_id,
             l_rcp_stp_tbl(i).attribute1,
             l_rcp_stp_tbl(i).attribute2,
             l_rcp_stp_tbl(i).attribute3,
             l_rcp_stp_tbl(i).attribute4,
             l_rcp_stp_tbl(i).attribute5,
             l_rcp_stp_tbl(i).attribute6,
             l_rcp_stp_tbl(i).attribute7,
             l_rcp_stp_tbl(i).attribute8,
             l_rcp_stp_tbl(i).attribute9,
             l_rcp_stp_tbl(i).attribute10,
             l_rcp_stp_tbl(i).attribute11,
             l_rcp_stp_tbl(i).attribute12,
             l_rcp_stp_tbl(i).attribute13,
             l_rcp_stp_tbl(i).attribute14,
             l_rcp_stp_tbl(i).attribute15,
             l_rcp_stp_tbl(i).attribute16,
             l_rcp_stp_tbl(i).attribute17,
             l_rcp_stp_tbl(i).attribute18,
             l_rcp_stp_tbl(i).attribute19,
             l_rcp_stp_tbl(i).attribute20,
             l_rcp_stp_tbl(i).attribute21,
             l_rcp_stp_tbl(i).attribute22,
             l_rcp_stp_tbl(i).attribute23,
             l_rcp_stp_tbl(i).attribute24,
             l_rcp_stp_tbl(i).attribute25,
             l_rcp_stp_tbl(i).attribute26,
             l_rcp_stp_tbl(i).attribute27,
             l_rcp_stp_tbl(i).attribute28,
             l_rcp_stp_tbl(i).attribute29,
             l_rcp_stp_tbl(i).attribute30,
             l_rcp_stp_tbl(i).attribute_category,
             l_rcp_stp_tbl(i).mass_std_uom,
             l_rcp_stp_tbl(i).volume_std_uom,
             l_rcp_stp_tbl(i).volume_qty,
             l_rcp_stp_tbl(i).mass_qty);

      END LOOP;

      ---
      --- Insert step/material associations
      ---
      l_txt_ind := 1;

      IF NOT l_copy_recipe THEN
        DELETE gmd_recipe_step_materials WHERE recipe_id = p_copy_from_recipe_id;
      END IF;

      FOR i IN 1..l_stp_mtl_tbl.count LOOP

        IF (l_stp_mtl_tbl(i).text_code > 0) THEN

          IF l_copy_recipe THEN
            OPEN  Get_Text_Code;
            FETCH Get_Text_Code INTO l_text_code;
            CLOSE Get_Text_Code;
          ELSE
            l_text_code := l_stp_mtl_tbl(i).text_code;
            DELETE fm_text_tbl WHERE text_code = l_text_code;
          END IF;

          l_table_lnk := 'gmd_recipe_step_materials' || '|' ||
                            l_stp_mtl_tbl(i).formulaline_id  ||
                         '|' || l_stp_mtl_tbl(i).routingstep_id;

          WHILE (l_txt_ind <= l_stp_mtl_text_tbl.COUNT AND
                 l_stp_mtl_text_tbl(l_txt_ind).text_code  =
                 l_stp_mtl_tbl(i).text_code) LOOP

            ---
            --- Create step/item association text
            ---
            GMD_RECIPE_DESIGNER_PKG.Create_Text_Row
            (p_text_code      => l_text_code,
             p_lang_code      => l_stp_mtl_text_tbl(l_txt_ind).lang_code,
             p_text           => l_stp_mtl_text_tbl(l_txt_ind).text,
             p_line_no        => l_stp_mtl_text_tbl(l_txt_ind).line_no,
             p_paragraph_code => l_stp_mtl_text_tbl(l_txt_ind).paragraph_code,
             p_sub_paracode   => l_stp_mtl_text_tbl(l_txt_ind).sub_paracode,
             p_table_lnk      => l_table_lnk,
             p_user_id        => l_user_id,
             x_row_id         => l_rowid,
             x_return_code    => l_return_code,
             x_error_msg      => l_error_msg);

             IF (l_return_code <> 'S') THEN
               RAISE COPY_HEADER_TEXT_EXCEPTION;
             END IF;

             l_txt_ind := l_txt_ind + 1;

          END LOOP;

        END IF;

        ---
        --- Create step/item association lines
        ---
        l_rcp_stp_tbl(i).recipe_id := x_recipe_id;
        l_rcp_stp_tbl(i).text_code := l_text_code;

        Create_Step_Material_Link (
                       p_recipe_id        => x_recipe_id,
                       p_formulaline_id   => l_stp_mtl_tbl(i).formulaline_id,
                       p_routingstep_id   => l_stp_mtl_tbl(i).routingstep_id,
                       p_text_code        => l_text_code,
                       p_user_id          => l_user_id,
                       p_last_update_date => SYSDATE,
                       x_return_code      => x_return_code,
                       x_error_msg        => x_error_msg);

        IF x_return_code <> 'S' THEN
          RAISE PROCEDURE_EXCEPTION;
        END IF;

      END LOOP;

      ---
      --- Insert customers
      ---
      l_txt_ind := 1;

      IF NOT l_copy_recipe THEN
        DELETE gmd_recipe_customers WHERE recipe_id = p_copy_from_recipe_id;
      END IF;

      FOR i IN 1..l_rcp_cust_tbl.count LOOP

        IF (l_rcp_cust_tbl(i).text_code > 0) THEN

          IF l_copy_recipe THEN
            OPEN  Get_Text_Code;
            FETCH Get_Text_Code INTO l_text_code;
            CLOSE Get_Text_Code;
          ELSE
            l_text_code := l_rcp_cust_tbl(i).text_code;
            DELETE fm_text_tbl WHERE text_code = l_text_code;
          END IF;

          l_table_lnk := 'gmd_recipe_customers' || '|' ||
                            x_recipe_id  ||
                         '|' || l_rcp_cust_tbl(i).customer_id;

          WHILE (l_txt_ind <= l_rcp_cust_text_tbl.COUNT AND
                 l_rcp_cust_text_tbl(l_txt_ind).text_code  =
                 l_rcp_cust_tbl(i).text_code) LOOP

            ---
            --- Create recipe customer text
            ---
            GMD_RECIPE_DESIGNER_PKG.Create_Text_Row
            (p_text_code      => l_text_code,
             p_lang_code      => l_rcp_cust_text_tbl(l_txt_ind).lang_code,
             p_text           => l_rcp_cust_text_tbl(l_txt_ind).text,
             p_line_no        => l_rcp_cust_text_tbl(l_txt_ind).line_no,
             p_paragraph_code => l_rcp_cust_text_tbl(l_txt_ind).paragraph_code,
             p_sub_paracode   => l_rcp_cust_text_tbl(l_txt_ind).sub_paracode,
             p_table_lnk      => l_table_lnk,
             p_user_id        => l_user_id,
             x_row_id         => l_rowid,
             x_return_code    => l_return_code,
             x_error_msg      => l_error_msg);

             IF (l_return_code <> 'S') THEN
               RAISE COPY_HEADER_TEXT_EXCEPTION;
             END IF;

             l_txt_ind := l_txt_ind + 1;

          END LOOP;

        END IF;

        ---
        --- Create customer line
        ---
        l_rcp_stp_tbl(i).recipe_id := x_recipe_id;
        l_rcp_stp_tbl(i).text_code := l_text_code;

        Add_Recipe_Customer (
                 p_recipe_id        => x_recipe_id,
                 p_customer_id      => l_rcp_cust_tbl(i).customer_id,
                 p_text_code        => l_text_code,
                 p_org_id           => l_rcp_cust_tbl(i).org_id,    --new addition
                 p_site_use_id      => l_rcp_cust_tbl(i).site_id,   --new addition
                 p_last_update_date => SYSDATE,
                 x_return_code      => x_return_code,
                 x_error_msg        => x_error_msg);

        IF x_return_code <> 'S' THEN
          RAISE PROCEDURE_EXCEPTION;
        END IF;

      END LOOP;

      ---
      --- Insert process losses
      ---
      l_txt_ind := 1;

      IF NOT l_copy_recipe THEN
        DELETE gmd_recipe_process_loss WHERE recipe_id = p_copy_from_recipe_id;
      END IF;

      FOR i IN 1..l_rcp_loss_tbl.count LOOP

        IF l_copy_recipe THEN
          OPEN Cur_loss_id;
          FETCH Cur_loss_id INTO l_loss_id;
          CLOSE Cur_loss_id;
        ELSE
          l_loss_id := l_rcp_loss_tbl(i).recipe_process_loss_id;
        END IF;

        IF (l_loss_id < 1) THEN
          RAISE GET_SURROGATE_EXCEPTION;
        END IF;

        IF (l_rcp_loss_tbl(i).text_code > 0) THEN

          IF l_copy_recipe THEN
            OPEN  Get_Text_Code;
            FETCH Get_Text_Code INTO l_text_code;
            CLOSE Get_Text_Code;
          ELSE
            l_text_code := l_rcp_loss_tbl(i).text_code;
            DELETE fm_text_tbl WHERE text_code = l_text_code;
          END IF;

          l_table_lnk := 'gmd_recipe_process_loss' || '|' ||
                            x_recipe_id  ||
                         '|' || l_loss_id;

          WHILE (l_txt_ind <= l_rcp_loss_text_tbl.COUNT AND
                 l_rcp_loss_text_tbl(l_txt_ind).text_code  =
                 l_rcp_loss_tbl(i).text_code) LOOP

            ---
            --- Create recipe loss text
            ---
            GMD_RECIPE_DESIGNER_PKG.Create_Text_Row
            (p_text_code      => l_text_code,
             p_lang_code      => l_rcp_loss_text_tbl(l_txt_ind).lang_code,
             p_text           => l_rcp_loss_text_tbl(l_txt_ind).text,
             p_line_no        => l_rcp_loss_text_tbl(l_txt_ind).line_no,
             p_paragraph_code => l_rcp_loss_text_tbl(l_txt_ind).paragraph_code,
             p_sub_paracode   => l_rcp_loss_text_tbl(l_txt_ind).sub_paracode,
             p_table_lnk      => l_table_lnk,
             p_user_id        => l_user_id,
             x_row_id         => l_rowid,
             x_return_code    => l_return_code,
             x_error_msg      => l_error_msg);

             IF (l_return_code <> 'S') THEN
               RAISE COPY_HEADER_TEXT_EXCEPTION;
             END IF;

             l_txt_ind := l_txt_ind + 1;

          END LOOP;

        END IF;

        ---
        --- Create process loss line
        ---
        Create_Process_Loss (p_recipe_id         => x_recipe_id,
                             p_orgn_id           => l_rcp_loss_tbl(i).organization_id,
                             p_process_loss      => l_rcp_loss_tbl(i).process_loss,
                             p_text_code         => l_text_code,
                             p_contiguous_ind    => l_rcp_loss_tbl(i).contiguous_ind , -- need checking
                             p_last_update_date  => SYSDATE,
                             p_loss_id           => l_loss_id,
                             x_loss_id           => l_dummy,
                             x_return_code       => x_return_code,
                             x_error_msg         => x_error_msg);

        IF x_return_code <> 'S' THEN
          RAISE PROCEDURE_EXCEPTION;
        END IF;

      END LOOP;

      l_txt_ind := 1;

      IF l_copy_recipe THEN

        ---
        --- Insert validity rules
        ---

        FOR i IN 1..l_rcp_vr_tbl.COUNT LOOP

          OPEN Cur_vr_id;
          FETCH Cur_vr_id INTO l_vr_id;
          CLOSE Cur_vr_id;

          IF (l_vr_id < 1) THEN
            RAISE GET_SURROGATE_EXCEPTION;
          END IF;

          IF (l_rcp_vr_tbl(i).text_code > 0) THEN

            OPEN  Get_Text_Code;
            FETCH Get_Text_Code INTO l_text_code;
            CLOSE Get_Text_Code;

            l_table_lnk := 'gmd_recipe_validity_rules' || '|' ||
                            x_recipe_id  ||
                         '|' || l_vr_id;

            WHILE (l_txt_ind <= l_rcp_vr_text_tbl.COUNT AND
                   l_rcp_vr_text_tbl(l_txt_ind).text_code  =
                   l_rcp_vr_tbl(i).text_code) LOOP

              ---
              --- Create validity rules text
              ---
              GMD_RECIPE_DESIGNER_PKG.Create_Text_Row
              (p_text_code      => l_text_code,
               p_lang_code      => l_rcp_vr_text_tbl(l_txt_ind).lang_code,
               p_text           => l_rcp_vr_text_tbl(l_txt_ind).text,
               p_line_no        => l_rcp_vr_text_tbl(l_txt_ind).line_no,
               p_paragraph_code => l_rcp_vr_text_tbl(l_txt_ind).paragraph_code,
               p_sub_paracode   => l_rcp_vr_text_tbl(l_txt_ind).sub_paracode,
               p_table_lnk      => l_table_lnk,
               p_user_id        => l_user_id,
               x_row_id         => l_rowid,
               x_return_code    => l_return_code,
               x_error_msg      => l_error_msg);

               IF (l_return_code <> 'S') THEN
                 RAISE COPY_HEADER_TEXT_EXCEPTION;
               END IF;

               l_txt_ind := l_txt_ind + 1;

            END LOOP;

          END IF;

          ---
          --- Create validity rules
          ---

          INSERT INTO gmd_recipe_validity_rules
                             ( recipe_validity_rule_id,
                               recipe_id,
                               organization_id,
                               inventory_item_id,
                               recipe_use,
                               preference,
                               start_date,
                               end_date,
                               min_qty,
                               max_qty,
                               std_qty,
                               detail_uom,
                               inv_min_qty,
                               inv_max_qty,
                               text_code,
                               attribute_category,
                               attribute1,
                               attribute2,
                               attribute3,
                               attribute4,
                               attribute5,
                               attribute6,
                               attribute7,
                               attribute8,
                               attribute9,
                               attribute10,
                               attribute11,
                               attribute12,
                               attribute13,
                               attribute14,
                               attribute15,
                               attribute16,
                               attribute17,
                               attribute18,
                               attribute19,
                               attribute20,
                               attribute21,
                               attribute22,
                               attribute23,
                               attribute24,
                               attribute25,
                               attribute26,
                               attribute27,
                               attribute28,
                               attribute29,
                               attribute30,
                               created_by,
                               creation_date,
                               last_updated_by,
                               last_update_date,
                               last_update_login,
                               delete_mark,
                               lab_type,
                               validity_rule_status)
          VALUES
                             ( l_vr_id,
                               x_recipe_id,
                               l_rcp_vr_tbl(i).organization_id,
                               l_rcp_vr_tbl(i).inventory_item_id,
                               l_rcp_vr_tbl(i).recipe_use,
                               l_rcp_vr_tbl(i).preference,
                               l_rcp_vr_tbl(i).start_date,
                               l_rcp_vr_tbl(i).end_date,
                               l_rcp_vr_tbl(i).min_qty,
                               l_rcp_vr_tbl(i).max_qty,
                               l_rcp_vr_tbl(i).std_qty,
                               l_rcp_vr_tbl(i).detail_uom,
                               l_rcp_vr_tbl(i).inv_min_qty,
                               l_rcp_vr_tbl(i).inv_max_qty,
                               l_text_code,
                               l_rcp_vr_tbl(i).attribute_category,
                               l_rcp_vr_tbl(i).attribute1,
                               l_rcp_vr_tbl(i).attribute2,
                               l_rcp_vr_tbl(i).attribute3,
                               l_rcp_vr_tbl(i).attribute4,
                               l_rcp_vr_tbl(i).attribute5,
                               l_rcp_vr_tbl(i).attribute6,
                               l_rcp_vr_tbl(i).attribute7,
                               l_rcp_vr_tbl(i).attribute8,
                               l_rcp_vr_tbl(i).attribute9,
                               l_rcp_vr_tbl(i).attribute10,
                               l_rcp_vr_tbl(i).attribute11,
                               l_rcp_vr_tbl(i).attribute12,
                               l_rcp_vr_tbl(i).attribute13,
                               l_rcp_vr_tbl(i).attribute14,
                               l_rcp_vr_tbl(i).attribute15,
                               l_rcp_vr_tbl(i).attribute16,
                               l_rcp_vr_tbl(i).attribute17,
                               l_rcp_vr_tbl(i).attribute18,
                               l_rcp_vr_tbl(i).attribute19,
                               l_rcp_vr_tbl(i).attribute20,
                               l_rcp_vr_tbl(i).attribute21,
                               l_rcp_vr_tbl(i).attribute22,
                               l_rcp_vr_tbl(i).attribute23,
                               l_rcp_vr_tbl(i).attribute24,
                               l_rcp_vr_tbl(i).attribute25,
                               l_rcp_vr_tbl(i).attribute26,
                               l_rcp_vr_tbl(i).attribute27,
                               l_rcp_vr_tbl(i).attribute28,
                               l_rcp_vr_tbl(i).attribute29,
                               l_rcp_vr_tbl(i).attribute30,
                               l_user_id,
                               SYSDATE,
                               l_user_id,
                               SYSDATE,
                               l_login_id,
                               l_rcp_vr_tbl(i).delete_mark,
                               l_rcp_vr_tbl(i).lab_type,
                               100);
        END LOOP;

      END IF;

      IF l_rcp_hdr_rec.routing_id IS NOT NULL THEN


        ---
        --- Insert organization specific resource information
        ---

        DELETE gmd_recipe_orgn_resources WHERE recipe_id = p_copy_from_recipe_id;

        FOR i IN 1..l_rcp_rsrc_tbl.COUNT LOOP

          IF (l_rcp_rsrc_tbl(i).text_code > 0) THEN

            OPEN  Get_Text_Code;
            FETCH Get_Text_Code INTO l_text_code;
            CLOSE Get_Text_Code;

            l_table_lnk := 'gmd_recipe_orgn_resources' || '|' ||
                            x_recipe_id  ||
                         '|' || l_rcp_rsrc_tbl(i).routingstep_id;

            WHILE (l_txt_ind <= l_rcp_rsrc_text_tbl.COUNT AND
                   l_rcp_rsrc_text_tbl(l_txt_ind).text_code  =
                   l_rcp_rsrc_tbl(i).text_code) LOOP

              ---
              --- Create resource text
              ---
              GMD_RECIPE_DESIGNER_PKG.Create_Text_Row
              (p_text_code      => l_text_code,
               p_lang_code      => l_rcp_rsrc_text_tbl(l_txt_ind).lang_code,
               p_text           => l_rcp_rsrc_text_tbl(l_txt_ind).text,
               p_line_no        => l_rcp_rsrc_text_tbl(l_txt_ind).line_no,
               p_paragraph_code => l_rcp_rsrc_text_tbl(l_txt_ind).paragraph_code,
               p_sub_paracode   => l_rcp_rsrc_text_tbl(l_txt_ind).sub_paracode,
               p_table_lnk      => l_table_lnk,
               p_user_id        => l_user_id,
               x_row_id         => l_rowid,
               x_return_code    => l_return_code,
               x_error_msg      => l_error_msg);

               IF (l_return_code <> 'S') THEN
                 RAISE COPY_HEADER_TEXT_EXCEPTION;
               END IF;

               l_txt_ind := l_txt_ind + 1;

            END LOOP;

          END IF;

          ---
          --- Create resource
          ---

          INSERT INTO gmd_recipe_orgn_resources
                             ( recipe_id,
                               organization_id,
                               routingstep_id,
                               oprn_line_id,
                               resources,
                               creation_date,
                               created_by,
                               last_updated_by,
                               last_update_date,
                               min_capacity,
                               max_capacity,
                               last_update_login,
                               text_code,
                               attribute1,
                               attribute2,
                               attribute3,
                               attribute4,
                               attribute5,
                               attribute6,
                               attribute7,
                               attribute8,
                               attribute9,
                               attribute10,
                               attribute11,
                               attribute12,
                               attribute13,
                               attribute14,
                               attribute15,
                               attribute16,
                               attribute17,
                               attribute18,
                               attribute19,
                               attribute20,
                               attribute21,
                               attribute22,
                               attribute23,
                               attribute24,
                               attribute25,
                               attribute26,
                               attribute27,
                               attribute28,
                               attribute29,
                               attribute30,
                               attribute_category,
                               process_parameter_5,
                               process_parameter_4,
                               process_parameter_3,
                               process_parameter_2,
                               process_parameter_1,
                               process_uom,
                               usage_um,
                               resource_usage,
                               process_qty)
          VALUES
                             ( x_recipe_id,
                               l_rcp_rsrc_tbl(i).organization_id,
                               l_rcp_rsrc_tbl(i).routingstep_id,
                               l_rcp_rsrc_tbl(i).oprn_line_id,
                               l_rcp_rsrc_tbl(i).resources,
                               SYSDATE,
                               l_user_id,
                               l_user_id,
                               SYSDATE,
                               l_rcp_rsrc_tbl(i).min_capacity,
                               l_rcp_rsrc_tbl(i).max_capacity,
                               l_login_id,
                               l_text_code,
                               l_rcp_rsrc_tbl(i).attribute1,
                               l_rcp_rsrc_tbl(i).attribute2,
                               l_rcp_rsrc_tbl(i).attribute3,
                               l_rcp_rsrc_tbl(i).attribute4,
                               l_rcp_rsrc_tbl(i).attribute5,
                               l_rcp_rsrc_tbl(i).attribute6,
                               l_rcp_rsrc_tbl(i).attribute7,
                               l_rcp_rsrc_tbl(i).attribute8,
                               l_rcp_rsrc_tbl(i).attribute9,
                               l_rcp_rsrc_tbl(i).attribute10,
                               l_rcp_rsrc_tbl(i).attribute11,
                               l_rcp_rsrc_tbl(i).attribute12,
                               l_rcp_rsrc_tbl(i).attribute13,
                               l_rcp_rsrc_tbl(i).attribute14,
                               l_rcp_rsrc_tbl(i).attribute15,
                               l_rcp_rsrc_tbl(i).attribute16,
                               l_rcp_rsrc_tbl(i).attribute17,
                               l_rcp_rsrc_tbl(i).attribute18,
                               l_rcp_rsrc_tbl(i).attribute19,
                               l_rcp_rsrc_tbl(i).attribute20,
                               l_rcp_rsrc_tbl(i).attribute21,
                               l_rcp_rsrc_tbl(i).attribute22,
                               l_rcp_rsrc_tbl(i).attribute23,
                               l_rcp_rsrc_tbl(i).attribute24,
                               l_rcp_rsrc_tbl(i).attribute25,
                               l_rcp_rsrc_tbl(i).attribute26,
                               l_rcp_rsrc_tbl(i).attribute27,
                               l_rcp_rsrc_tbl(i).attribute28,
                               l_rcp_rsrc_tbl(i).attribute29,
                               l_rcp_rsrc_tbl(i).attribute30,
                               l_rcp_rsrc_tbl(i).attribute_category,
                               l_rcp_rsrc_tbl(i).process_parameter_5,
                               l_rcp_rsrc_tbl(i).process_parameter_4,
                               l_rcp_rsrc_tbl(i).process_parameter_3,
                               l_rcp_rsrc_tbl(i).process_parameter_2,
                               l_rcp_rsrc_tbl(i).process_parameter_1,
                               l_rcp_rsrc_tbl(i).process_uom,
                               l_rcp_rsrc_tbl(i).usage_um,
                               l_rcp_rsrc_tbl(i).resource_usage,
                               l_rcp_rsrc_tbl(i).process_qty);

        END LOOP;

        ---
        --- Insert organization specific activity information
        ---

        DELETE gmd_recipe_orgn_activities
        WHERE recipe_id = p_copy_from_recipe_id;

        FOR i IN 1..l_rcp_actv_tbl.COUNT LOOP

          IF (l_rcp_actv_tbl(i).text_code > 0) THEN

            OPEN  Get_Text_Code;
            FETCH Get_Text_Code INTO l_text_code;
            CLOSE Get_Text_Code;

            l_table_lnk := 'gmd_recipe_orgn_activities' || '|' ||
                            x_recipe_id  ||
                         '|' || l_rcp_actv_tbl(i).oprn_line_id;

            WHILE (l_txt_ind <= l_rcp_actv_text_tbl.COUNT AND
                   l_rcp_actv_text_tbl(l_txt_ind).text_code  =
                   l_rcp_actv_tbl(i).text_code) LOOP

              ---
              --- Create resource text
              ---
              GMD_RECIPE_DESIGNER_PKG.Create_Text_Row
              (p_text_code      => l_text_code,
               p_lang_code      => l_rcp_actv_text_tbl(l_txt_ind).lang_code,
               p_text           => l_rcp_actv_text_tbl(l_txt_ind).text,
               p_line_no        => l_rcp_actv_text_tbl(l_txt_ind).line_no,
               p_paragraph_code => l_rcp_actv_text_tbl(l_txt_ind).paragraph_code,
               p_sub_paracode   => l_rcp_actv_text_tbl(l_txt_ind).sub_paracode,
               p_table_lnk      => l_table_lnk,
               p_user_id        => l_user_id,
               x_row_id         => l_rowid,
               x_return_code    => l_return_code,
               x_error_msg      => l_error_msg);

               IF (l_return_code <> 'S') THEN
                 RAISE COPY_HEADER_TEXT_EXCEPTION;
               END IF;

               l_txt_ind := l_txt_ind + 1;

            END LOOP;

          END IF;

          ---
          --- Create activity
          ---

          INSERT INTO gmd_recipe_orgn_activities
                             ( recipe_id,
                               routingstep_id,
                               oprn_line_id,
                               activity_factor,
                               orgn_code,
                               organization_id,
                               last_update_login,
                               text_code,
                               created_by,
                               creation_date,
                               last_updated_by,
                               last_update_date,
                               attribute1,
                               attribute2,
                               attribute3,
                               attribute4,
                               attribute5,
                               attribute6,
                               attribute7,
                               attribute8,
                               attribute9,
                               attribute10,
                               attribute11,
                               attribute12,
                               attribute13,
                               attribute14,
                               attribute15,
                               attribute16,
                               attribute17,
                               attribute18,
                               attribute19,
                               attribute20,
                               attribute21,
                               attribute22,
                               attribute23,
                               attribute24,
                               attribute25,
                               attribute26,
                               attribute27,
                               attribute28,
                               attribute29,
                               attribute30,
                               attribute_category)
          VALUES
                             ( x_recipe_id,
                               l_rcp_actv_tbl(i).routingstep_id,
                               l_rcp_actv_tbl(i).oprn_line_id,
                               l_rcp_actv_tbl(i).activity_factor,
                               l_rcp_rsrc_tbl(i).orgn_code,
                               l_rcp_rsrc_tbl(i).organization_id,
                               l_login_id,
                               l_text_code,
                               l_user_id,
                               SYSDATE,
                               l_user_id,
                               SYSDATE,
                               l_rcp_actv_tbl(i).attribute1,
                               l_rcp_actv_tbl(i).attribute2,
                               l_rcp_actv_tbl(i).attribute3,
                               l_rcp_actv_tbl(i).attribute4,
                               l_rcp_actv_tbl(i).attribute5,
                               l_rcp_actv_tbl(i).attribute6,
                               l_rcp_actv_tbl(i).attribute7,
                               l_rcp_actv_tbl(i).attribute8,
                               l_rcp_actv_tbl(i).attribute9,
                               l_rcp_actv_tbl(i).attribute10,
                               l_rcp_actv_tbl(i).attribute11,
                               l_rcp_actv_tbl(i).attribute12,
                               l_rcp_actv_tbl(i).attribute13,
                               l_rcp_actv_tbl(i).attribute14,
                               l_rcp_actv_tbl(i).attribute15,
                               l_rcp_actv_tbl(i).attribute16,
                               l_rcp_actv_tbl(i).attribute17,
                               l_rcp_actv_tbl(i).attribute18,
                               l_rcp_actv_tbl(i).attribute19,
                               l_rcp_actv_tbl(i).attribute20,
                               l_rcp_actv_tbl(i).attribute21,
                               l_rcp_actv_tbl(i).attribute22,
                               l_rcp_actv_tbl(i).attribute23,
                               l_rcp_actv_tbl(i).attribute24,
                               l_rcp_actv_tbl(i).attribute25,
                               l_rcp_actv_tbl(i).attribute26,
                               l_rcp_actv_tbl(i).attribute27,
                               l_rcp_actv_tbl(i).attribute28,
                               l_rcp_actv_tbl(i).attribute29,
                               l_rcp_actv_tbl(i).attribute30,
                               l_rcp_actv_tbl(i).attribute_category);
        END LOOP;

        ---
        --- Insert process parameter information
        ---

        DELETE gmd_recipe_process_parameters
        WHERE recipe_id = p_copy_from_recipe_id;

        FOR i IN 1..l_rcp_pp_tbl.COUNT LOOP

          ---
          --- Create process parameter
          ---

          INSERT INTO gmd_recipe_process_parameters
                    ( recipe_id,
                      organization_id,
                      routingstep_id,
                      oprn_line_id,
                      resources,
                      parameter_id,
                      target_value,
                      minimum_value,
                      maximum_value,
                      last_update_login,
                      created_by,
                      creation_date,
                      last_updated_by,
                      last_update_date)
          VALUES
                    ( x_recipe_id,
                      l_rcp_pp_tbl(i).organization_id,
                      l_rcp_pp_tbl(i).routingstep_id,
                      l_rcp_pp_tbl(i).oprn_line_id,
                      l_rcp_pp_tbl(i).resources,
                      l_rcp_pp_tbl(i).parameter_id,
                      l_rcp_pp_tbl(i).target_value,
                      l_rcp_pp_tbl(i).minimum_value,
                      l_rcp_pp_tbl(i).maximum_value,
                      l_login_id,
                      l_user_id,
                      SYSDATE,
                      l_user_id,
                      SYSDATE);
        END LOOP;

      END IF;

    END IF;

    IF p_commit = 'Y' THEN
      COMMIT;

      /*Bug 3953359 - Thomas Daniel */
      /*Added code to set the default status after copying the formula */
      IF l_copy_formula THEN
        GMD_RECIPE_DESIGNER_PKG.set_default_status (pEntity_name   => 'FORMULA'
                                                   ,pEntity_id      => X_formula_id
                                                    ,x_return_status => l_return_code
                                                    ,x_msg_count => l_message_count
                                                    ,x_msg_data  => l_message_list);
      END IF;
      IF l_copy_routing THEN
        GMD_RECIPE_DESIGNER_PKG.set_default_status (pEntity_name   => 'ROUTING'
                                                   ,pEntity_id      => X_routing_id
                                                    ,x_return_status => l_return_code
                                                    ,x_msg_count => l_message_count
                                                    ,x_msg_data  => l_message_list);
      END IF;
      IF l_copy_recipe THEN
        GMD_RECIPE_DESIGNER_PKG.set_default_status (pEntity_name   => 'RECIPE'
                                                    ,pEntity_id    => X_recipe_id
                                                    ,x_return_status => l_return_code
                                                    ,x_msg_count => l_message_count
                                                    ,x_msg_data  => l_message_list);
      END IF;
    END IF;

    EXCEPTION
      WHEN COPY_HEADER_TEXT_EXCEPTION THEN
        ROLLBACK TO Copy_Recipe;
        x_return_code := 'F';
        x_error_msg   := l_error_msg;

      WHEN PROCEDURE_EXCEPTION THEN
        ROLLBACK TO Copy_Recipe;
        x_return_code := 'F';

      WHEN COPY_RECIPE_EXCEPTION THEN
        ROLLBACK TO Copy_Recipe;
        FND_MSG_PUB.GET( p_msg_index     => 1,
                         p_data          => x_error_msg,
                         p_encoded       => 'F',
                         p_msg_index_out => l_dummy);
        x_return_code := 'F';

      WHEN COPY_ROUTING_EXCEPTION THEN
        ROLLBACK TO Copy_Recipe;
        FND_MSG_PUB.GET( p_msg_index     => 1,
                         p_data          => x_error_msg,
                         p_encoded       => 'F',
                         p_msg_index_out => l_dummy);
        x_return_code := 'F';

      WHEN COPY_FORMULA_EXCEPTION THEN
        ROLLBACK TO Copy_Recipe;
        FND_MSG_PUB.GET( p_msg_index     => 1,
                         p_data          => x_error_msg,
                         p_encoded       => 'F',
                         p_msg_index_out => l_dummy);
        x_return_code := 'F';

      WHEN COPY_FORM_DTL_EXCEPTION THEN
        ROLLBACK TO Copy_Recipe;
        FND_MSG_PUB.GET( p_msg_index     => 1,
                         p_data          => x_error_msg,
                         p_encoded       => 'F',
                         p_msg_index_out => l_dummy);
        x_return_code := 'F';

      WHEN RECIPE_NOT_FOUND THEN
        ROLLBACK TO Copy_Recipe;
        FND_MESSAGE.SET_NAME('GMD', 'GMD_RECIPE_NOT_FOUND');
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

      WHEN ROUTING_NOT_FOUND THEN
        ROLLBACK TO Copy_Recipe;
        FND_MESSAGE.SET_NAME('GMD', 'GMD_RECIPE_ROUTING_INVALID');
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

      WHEN FORMULA_NOT_FOUND THEN
        ROLLBACK TO Copy_Recipe;
        FND_MESSAGE.SET_NAME('GMD', 'GMD_FORMULA_NOT_FOUND');
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

      WHEN GET_SURROGATE_EXCEPTION THEN
        ROLLBACK TO Copy_Recipe;
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

      WHEN OTHERS THEN
        ROLLBACK TO Copy_Recipe;
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'U';
        x_error_msg   := FND_MESSAGE.GET;

  END Copy_Recipe;

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
                                  p_user_id            IN NUMBER,
                                  x_return_code        OUT NOCOPY VARCHAR2) IS

   CURSOR Cur_get_recp_orgn IS
     SELECT owner_organization_id
     FROM   gmd_recipes_b
     WHERE  recipe_id = p_recipe_id;

    l_orgn_id       NUMBER;
    l_return_status VARCHAR2(10);

  BEGIN
    OPEN Cur_get_recp_orgn;
    FETCH Cur_get_recp_orgn INTO l_orgn_id;
    CLOSE Cur_get_recp_orgn;

    IF (l_orgn_id IS NOT NULL) THEN
      IF (GMD_API_GRP.setup AND GMD_API_GRP.OrgnAccessible(l_orgn_id)) THEN
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

  END CHECK_RECP_ORGN_ACCESS;


 PROCEDURE Check_Recipe_Formula( p_recipe_id         IN         NUMBER,
                                 p_organization_id   IN   NUMBER,
                                 x_return_code   OUT NOCOPY VARCHAR2) IS

   CURSOR get_recipe_details (l_recipe_id NUMBER) IS
     SELECT formula_id, owner_organization_id
     FROM   gmd_recipes_b
     WHERE  recipe_id = l_recipe_id;

    l_orgn_id    NUMBER;
    l_formula_id NUMBER;
  BEGIN
    OPEN get_recipe_details(p_recipe_id);
    FETCH get_recipe_details INTO l_formula_id, l_orgn_id;
    IF (get_recipe_details%FOUND) THEN
      IF (p_organization_id IS NOT NULL) THEN
        l_orgn_id := p_organization_id;
      END IF;

      GMD_API_GRP.check_item_exists (p_formula_id       => l_formula_id,
                                   x_return_status      => x_return_code,
                                   p_organization_id    => l_orgn_id);
    ELSE
      x_return_code := 'S';
    END IF;
    CLOSE get_recipe_details;

  END Check_Recipe_Formula;

   /* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      set_default_status
 |
 |   DESCRIPTION
 |     Procedure to set the Default Status for a new Formula, Recipe and Routing
 |
 |
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
                              ,x_msg_data      OUT NOCOPY VARCHAR2 ) IS

   /* Local variable section */
   l_entity_status          gmd_api_grp.status_rec_type;
   l_owner_organization_id  fm_form_mst_b.owner_organization_id%TYPE;

   default_status_err    EXCEPTION;

   CURSOR get_formula_details(vFormula_id NUMBER) IS
     SELECT owner_organization_id
     FROM   fm_form_mst_b
     WHERE  formula_id = vFormula_id;

   CURSOR get_recipe_details(vRecipe_id NUMBER) IS
     SELECT owner_organization_id
     FROM   gmd_recipes_b
     WHERE  recipe_id = vRecipe_id;

   CURSOR get_routing_details(vRouting_id NUMBER) IS
     SELECT owner_organization_id
     FROM   gmd_routings_b
     WHERE  routing_id = vRouting_id;

 BEGIN
   SAVEPOINT default_status_sp;

   x_return_status := FND_API.g_ret_sts_success;

   IF (pEntity_name = 'FORMULA') THEN
     OPEN get_formula_details(pentity_id);
     FETCH get_formula_details INTO l_owner_organization_id;
     CLOSE get_formula_details;
   ELSIF (pEntity_name = 'RECIPE') THEN
     OPEN get_recipe_details(pentity_id);
     FETCH get_recipe_details INTO l_owner_organization_id;
     CLOSE get_recipe_details;
   ELSIF (pEntity_name = 'ROUTING') THEN
     OPEN get_routing_details(pentity_id);
     FETCH get_routing_details INTO l_owner_organization_id;
     CLOSE get_routing_details;
   END IF;

   -- Getting the default status for the owner orgn code
   -- or null orgn of recipe from parameters table
   gmd_api_grp.get_status_details (V_entity_type   => pEntity_name,
                                   V_orgn_id       => l_owner_organization_id,
                                   X_entity_status => l_entity_status);

   -- Check for any experimental items when formula status is apfgu.
   IF (pEntity_name = 'FORMULA') THEN
     IF (l_entity_status.status_type = 700) THEN
       IF (gmdfmval_pub.check_expr_items(pEntity_id)) THEN
         FND_MESSAGE.SET_NAME('GMD','GMD_EXPR_ITEMS_FOUND');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
     END IF; -- IF (X_status_type = 700) THEN

     --Check any inactive items in formula before changing the status
     IF (l_entity_status.status_type IN (400,700)) THEN
       IF (gmdfmval_pub.inactive_items(pEntity_id)) THEN
         FND_MESSAGE.SET_NAME('GMI','IC_ITEM_INACTIVE');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
     END IF; --l_entity_status.status_type IN (400,700)
   END IF;

   IF (l_entity_status.entity_status <> 100) THEN
     gmd_status_pub.modify_status ( p_api_version        => 1
                                  , p_init_msg_list      => TRUE
                                  , p_entity_name        => pEntity_name
                                  , p_entity_id          => pEntity_id
                                  , p_entity_no          => NULL
                                  , p_entity_version     => NULL
                                  , p_to_status          => l_entity_status.entity_status
                                  , p_ignore_flag        => FALSE
                                  , x_message_count      => x_msg_count
                                  , x_message_list       => x_msg_data
                                  , x_return_status      => x_return_status);

     IF x_return_status  NOT IN (FND_API.g_ret_sts_success,'P') THEN
       RAISE default_status_err;
     END IF; --x_return_status
   END IF; --l_entity_status.entity_status <> 100

  EXCEPTION
    WHEN default_status_err THEN
      ROLLBACK TO default_status_sp;
      FND_MSG_PUB.Count_And_Get (p_encoded => 'F',
                                 p_count   => x_msg_count,
                                 p_data    => x_msg_data   );
    WHEN OTHERS THEN
      ROLLBACK TO default_status_sp;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
                                p_count   => x_msg_count,
                                p_data    => x_msg_data   );
 END set_default_status;

END GMD_RECIPE_DESIGNER_PKG;

/
