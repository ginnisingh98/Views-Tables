--------------------------------------------------------
--  DDL for Package Body GMD_FORMULA_DESIGNER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_FORMULA_DESIGNER_PKG" AS
/* $Header: GMDFRDDB.pls 120.16.12000000.4 2007/05/02 10:49:04 kmotupal ship $ */
/*============================================================================
 |                         Copyright (c) 2002 Oracle Corporation
 |                             Redwood Shores, California, USA
 |                                  All rights reserved
 ============================================================================================
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
 |     02-APR-2003 Eddie Oumerretane  Bug 2883871 Call version 2 of
 |                       Update_FormulaDetail API.
 |     16-APR-2003 Eddie Oumerretane. Implemented call to
 |                       gmd_api_grp.Update_allowed_with_fmsec function in
 |                       order to get formula user access defined in
 |                       Formula Security.
 |     30-MAR-2004 kkillams
 |                       Modified Get_Formula_Mode procedure w.r.t. bug 3344335.
 |     27-APR-2004 Sriram.S Bug# 3408799
 |                       Added SET_DEFAULT_STATUS procedure for Default Status Build.
 |     23-JUN-2004 Sriram.S Bug# 3702561
 |                       Added validation to check for ingredient with zero qty in
 |                       Validate_Formula_Details procedure.
 |     23-JUN-2004 Sriram.S Bug# 3700829
 |                       Added procedure CHECK_USR_HAS_FSEC_RESP to check if user has formula
 |                       security responsibility (i-e) Product development security manager.
 |     29-SEP-2004 Sriram.S Bug# 3761032
 |                       Added validation to check for experimental items if formula status in
 |                       in (600,700).
 |     16-Dec-2005 TDaniel Bug#4771255
 |                       Added code to handle the return status of Q in insert_formula_detail
 |                       and update_formula_detail routines.
 |     27-Jan-2006 TDaniel Bug#4720080
 |                       Added code to pass back return code as "W" for validateCostAlloc.
 |      05-FEB-2007  Kapil M  Bug# 5716318
 |                       Changes for Auto-Product Qty Calculation ME. Added the new procedure
 |                       CALCULATE_TOTAL_PRODUCT_QTY and CHECK_AUTO_PRODUCT. Changed made to pass
 |                       the newly added fields.
 ==============================================================================================
*/

/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Get_Formula_Mode
 |
 |   DESCRIPTION
 |      Determine whether the user has access to this formula and in which
 |      mode (view or update/create mode).
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
 |     16-APR-2003 Eddie Oumerretane. Implemented call to
 |                       gmd_api_grp.Update_allowed_with_fmsec function in
 |                       order to get formula user access defined in
 |                       Formula Security.
 |     30-03-2004kkillamsCalling GMD_API_GRP.get_formula_access_type api to get the
 |                       formula access type w.r.t. bug 3344335.
 |     29-Jul-2005 Tdaniel Added organization_id for convergence changes.
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Get_Formula_Mode (p_formula_id               IN         NUMBER,
                              p_organization_id          IN         NUMBER,
                              x_formula_mode             OUT NOCOPY VARCHAR2,
                              x_create_allowed           OUT NOCOPY VARCHAR2,
                              x_return_code              OUT NOCOPY VARCHAR2,
                              x_error_msg                OUT NOCOPY VARCHAR2) IS

    l_return_code          VARCHAR2(1);
    l_status               VARCHAR2(30);

    --3344335
    l_formula_access       VARCHAR2(1);
    l_fm_orgn_id           fm_form_mst_b.owner_organization_id%TYPE;

    --Get's the organization code of the formula.
    CURSOR get_formula_orgn_code(vFormula_id NUMBER) IS
      SELECT owner_organization_id
      FROM   fm_form_mst_b
      WHERE  formula_id = vFormula_id;

  BEGIN

    x_return_code := 'S';
    x_error_msg   := '';

    --- Check user access to the given formula as defined in Formula Security
    IF NVL(p_formula_id, -1) <> -1 THEN
      OPEN  get_formula_orgn_code(p_formula_id);
      FETCH get_formula_orgn_code INTO l_fm_orgn_id;
      CLOSE get_formula_orgn_code;
    ELSE
      l_fm_orgn_id := p_organization_id;
    END IF;

    -- to be changed
    l_formula_access := 'U';
    l_formula_access :=GMD_API_GRP.get_formula_access_type(p_formula_id => p_formula_id,
                                                           p_owner_organization_id => l_fm_orgn_id);

    IF (l_formula_access ='U') THEN
      --- Assume that user can update current formula and create new ones
      x_formula_mode   := 'U';
      x_create_allowed := 'Y';
    ELSE
      x_formula_mode   := 'Q';
      x_create_allowed := 'N';
    END IF;

    --- If user has update access to the given formula based on Formula
    --- Security, check whether he/she can actually update the formula based on
    --- status, owning organization ...

    IF x_formula_mode = 'U' THEN

      IF GMD_COMMON_VAL.Update_Allowed(entity    => 'FORMULA',
                                     entity_id => p_formula_id) THEN
        x_formula_mode := 'U';
      ELSE
        x_formula_mode := 'Q';
      END IF;

    END IF;

  END Get_Formula_Mode;

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
                                        x_error_msg        OUT NOCOPY VARCHAR2) IS

  BEGIN

    x_return_code := 'S';
    x_error_msg   := '';

    x_used_in_recipes   := 'N';

    -- Return TRUE if this formula is used by one or more recipes
    IF NOT GMD_STATUS_CODE.Check_Parent_Status('FORMULA', p_formula_id) THEN
      x_used_in_recipes   := 'Y';
    END IF;

  END Is_Formula_Used_In_Recipes;

/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Update_Formula_Header
 |
 |   DESCRIPTION
 |      Update formula header
 |
 |   INPUT PARAMETERS
 |     p_formula_id              NUMBER
 |     p_formula_no              VARCHAR2
 |     p_formula_vers            NUMBER
 |     p_formula_desc            VARCHAR2
 |     p_formula_desc2           VARCHAR2
 |     p_formula_status          VARCHAR2
 |     p_formula_class           VARCHAR2
 |     p_owner_organization_id   NUMBER
 |     p_owner_id                NUMBER
 |     p_formula_type            NUMBER
 |     p_scale_type              NUMBER
 |     p_text_code               NUMBER
 |     p_last_update_date        DATE
 |     p_user_id                 NUMBER
 |     p_last_update_date_orig   DATE
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
                                    x_error_msg             OUT NOCOPY VARCHAR2) IS
    CURSOR Cur_get_formula IS
      SELECT *
      FROM   fm_form_mst
      WHERE  formula_id       = p_formula_id AND
             last_update_date = p_last_update_date_orig;

    UPDATE_FORMULA_EXCEPTION EXCEPTION;
    RECORD_CHANGED_EXCEPTION EXCEPTION;
    l_text_code              NUMBER(10);
    l_rec                    Cur_get_formula%ROWTYPE;
    l_return_status          VARCHAR2(2);
    l_message_count          NUMBER;
    l_msg_data               VARCHAR2(2000);
    l_message                VARCHAR2(1000);
    l_dummy	             NUMBER;
    l_update_table           GMD_FORMULA_PUB.formula_update_hdr_tbl_type;

  BEGIN

    x_error_msg   := '';
    x_return_code := FND_API.G_RET_STS_SUCCESS;


    OPEN Cur_get_formula;
    FETCH Cur_get_formula INTO l_rec;

    IF Cur_get_formula%NOTFOUND THEN
      CLOSE Cur_get_formula;
      RAISE RECORD_CHANGED_EXCEPTION;
    END IF;

    CLOSE Cur_get_formula;

    IF p_text_code <= 0 THEN
      l_text_code := NULL;
    ELSE
      l_text_code := p_text_code;
    END IF;

    l_update_table(1).fmcontrol_class    := l_rec.fmcontrol_class;
    l_update_table(1).inactive_ind       := l_rec.inactive_ind;
    l_update_table(1).total_input_qty    := l_rec.total_input_qty;
    l_update_table(1).total_output_qty   := l_rec.total_output_qty;
    l_update_table(1).yield_uom          := l_rec.yield_uom;
    l_update_table(1).formula_id         := p_formula_id;
    l_update_table(1).formula_no         := l_rec.formula_no;
    l_update_table(1).formula_vers       := l_rec.formula_vers;
    l_update_table(1).formula_desc1      := p_formula_desc;
    l_update_table(1).formula_desc2      := p_formula_desc2;
    l_update_table(1).formula_status     := p_formula_status;
    l_update_table(1).formula_class      := p_formula_class;
    -- l_update_table(1).orgn_code          := p_owner_organization;
    -- Commented the above line and added below for NPD Conv.
    l_update_table(1).owner_organization_id := p_owner_organization_id;
    -- l_rec.owner_organization_id;
    l_update_table(1).owner_id           := p_owner_id;
    l_update_table(1).user_id            := p_user_id;
    l_update_table(1).formula_type       := p_formula_type;
    l_update_table(1).scale_type_hdr     := p_scale_type;
    l_update_table(1).text_code_hdr      := l_text_code;
    l_update_table(1).last_update_date   := p_last_update_date;
    l_update_table(1).last_updated_by    := p_user_id;
    l_update_table(1).last_update_login  := p_user_id;

    l_update_table(1).delete_mark          := l_rec.delete_mark;
    l_update_table(1).created_by           := l_rec.created_by;
    l_update_table(1).creation_date        := l_rec.last_update_date;
    l_update_table(1).attribute1           := l_rec.attribute1;
    l_update_table(1).attribute2           := l_rec.attribute2;
    l_update_table(1).attribute3           := l_rec.attribute3;
    l_update_table(1).attribute4           := l_rec.attribute4;
    l_update_table(1).attribute5           := l_rec.attribute5;
    l_update_table(1).attribute6           := l_rec.attribute6;
    l_update_table(1).attribute7           := l_rec.attribute7;
    l_update_table(1).attribute8           := l_rec.attribute8;
    l_update_table(1).attribute9           := l_rec.attribute9;
    l_update_table(1).attribute10          := l_rec.attribute10;
    l_update_table(1).attribute11          := l_rec.attribute11;
    l_update_table(1).attribute12          := l_rec.attribute12;
    l_update_table(1).attribute13          := l_rec.attribute13;
    l_update_table(1).attribute14          := l_rec.attribute14;
    l_update_table(1).attribute15          := l_rec.attribute15;
    l_update_table(1).attribute16          := l_rec.attribute16;
    l_update_table(1).attribute17          := l_rec.attribute17;
    l_update_table(1).attribute18          := l_rec.attribute18;
    l_update_table(1).attribute19          := l_rec.attribute19;
    l_update_table(1).attribute20          := l_rec.attribute20;
    l_update_table(1).attribute21          := l_rec.attribute21;
    l_update_table(1).attribute22          := l_rec.attribute22;
    l_update_table(1).attribute23          := l_rec.attribute23;
    l_update_table(1).attribute24          := l_rec.attribute24;
    l_update_table(1).attribute25          := l_rec.attribute25;
    l_update_table(1).attribute26          := l_rec.attribute26;
    l_update_table(1).attribute27          := l_rec.attribute27;
    l_update_table(1).attribute28          := l_rec.attribute28;
    l_update_table(1).attribute29          := l_rec.attribute29;
    l_update_table(1).attribute30          := l_rec.attribute30;
    l_update_table(1).attribute_category   := l_rec.attribute_category;
    -- Kapil ME Auto-Prod
    l_update_table(1).auto_product_calc    := p_auto_product_calc;

    GMD_FORMULA_PUB.Update_FormulaHeader
                         ( p_api_version        => 2
                         , p_init_msg_list      => FND_API.G_TRUE
                         , p_commit             => FND_API.G_FALSE
                         , p_called_from_forms  => 'YES'
                         , x_return_status      => l_return_status
                         , x_msg_count          => l_message_count
                         , x_msg_data           => l_msg_data
                         , p_formula_header_tbl => l_update_table);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE UPDATE_FORMULA_EXCEPTION;
    END IF;

    --- If formula number and/or version have changed, we need to update them. This
    --- happens when creating a new formula, because a dummy formula header is created in
    --- the database. User is then prompted to enter a valid formula number/version prior
    --- to saving.

    IF l_rec.formula_no   <> p_formula_no OR
       l_rec.formula_vers <> p_formula_vers THEN

      UPDATE
        FM_FORM_MST_B
      SET
        formula_no   = p_formula_no,
        formula_vers = p_formula_vers
      WHERE
        formula_id   = p_formula_id;

    END IF;


    EXCEPTION
      WHEN UPDATE_FORMULA_EXCEPTION THEN
        FND_MSG_PUB.GET( p_msg_index     => 1,
                         p_data          => l_message,
                         p_encoded       => 'F',
                         p_msg_index_out => l_dummy);

        x_return_code := 'F';
        x_error_msg   := l_message;

     WHEN RECORD_CHANGED_EXCEPTION THEN
        FND_MESSAGE.SET_NAME('FND', 'FND_RECORD_CHANGED_ERROR');
        x_return_code := 'F';
        x_error_msg   := gmd_api_grp.get_message;

     WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := gmd_api_grp.get_message;

  END Update_Formula_Header;

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
                                   ,x_error_msg               OUT NOCOPY VARCHAR2) IS

    CURSOR Cur_get_formula IS
      SELECT formula_no,
             formula_vers , auto_product_calc    -- Kapil ME Auto-Prod
      FROM   fm_form_mst
      WHERE  formula_id       = p_formula_id;

    l_auto_product_calc VARCHAR2(1);

    l_text_code              NUMBER(10);
    l_return_status          VARCHAR2(2);
    l_message_count          NUMBER;
    l_message_list           VARCHAR2(2000);
    l_message                VARCHAR2(1000);
    l_dummy	             NUMBER;
    INSERT_DTL_EXCEPTION     EXCEPTION;
    RECORD_CHANGED_EXCEPTION EXCEPTION;
    l_formula_dtl_rec        GMD_FORMULA_DETAIL_PUB.formula_insert_dtl_tbl_type;

  BEGIN

    SAVEPOINT Add_Item;

    x_error_msg   := '';
    x_return_code := FND_API.G_RET_STS_SUCCESS;

    IF p_text_code <= 0 THEN
      l_text_code := NULL;
    ELSE
      l_text_code := p_text_code;
    END IF;

    l_formula_dtl_rec(1).record_type    := 'I';

    OPEN Cur_get_formula;
    FETCH Cur_get_formula INTO l_formula_dtl_rec(1).formula_no,
                               l_formula_dtl_rec(1).formula_vers,
                               l_auto_product_calc;

    IF Cur_get_formula%NOTFOUND THEN
      CLOSE Cur_get_formula;
      RAISE RECORD_CHANGED_EXCEPTION;
    END IF;

    CLOSE Cur_get_formula;

    IF p_tp_formula_id < 0 THEN
      l_formula_dtl_rec(1).tpformula_id := NULL;
    ELSE
      l_formula_dtl_rec(1).tpformula_id := p_tp_formula_id;
    END IF;

    IF p_iaformula_id < 0 THEN
      l_formula_dtl_rec(1).iaformula_id := NULL;
    ELSE
      l_formula_dtl_rec(1).iaformula_id := p_iaformula_id;
    END IF;

    IF p_rework_type < -1 THEN
      l_formula_dtl_rec(1).rework_type := NULL;
    ELSE
      l_formula_dtl_rec(1).rework_type := p_rework_type;
    END IF;

    -- Scaling attributes are relevant if Integer scale type selected
    IF p_scale_type = 2 THEN
      l_formula_dtl_rec(1).scale_multiple          := p_scale_multiple;
      l_formula_dtl_rec(1).scale_rounding_variance := p_scale_rounding_variance;
      l_formula_dtl_rec(1).rounding_direction      := p_rounding_direction;
      IF p_scale_uom = ' 'THEN
        l_formula_dtl_rec(1).scale_uom             := NULL;
      ELSE
        l_formula_dtl_rec(1).scale_uom             := p_scale_uom;
      END IF;
    ELSE
      l_formula_dtl_rec(1).scale_multiple          := NULL;
      l_formula_dtl_rec(1).scale_rounding_variance := NULL;
      l_formula_dtl_rec(1).rounding_direction      := NULL;
      l_formula_dtl_rec(1).scale_uom               := NULL;
    END IF;

    -- Kapil ME Auto-Prod
    -- Rework for Bug# 5903531 and 5903157
    IF (p_line_type = 1 AND p_scale_type = 1) AND l_auto_product_calc = 'Y'  THEN
        l_formula_dtl_rec(1).prod_percent := p_prod_percent;
    ELSE
        l_formula_dtl_rec(1).prod_percent := NULL;
    END IF;

    l_formula_dtl_rec(1).formula_id                := p_formula_id;
    l_formula_dtl_rec(1).item_no                   := p_item_no;
    l_formula_dtl_rec(1).revision                  := TRIM(p_revision);
    l_formula_dtl_rec(1).user_id                   := p_user_id;
    l_formula_dtl_rec(1).text_code_dtl             := l_text_code;
    l_formula_dtl_rec(1).formulaline_id            := p_formulaline_id;
    l_formula_dtl_rec(1).line_type                 := p_line_type;
    l_formula_dtl_rec(1).line_no                   := p_line_no;
    l_formula_dtl_rec(1).qty                       := p_qty;
    l_formula_dtl_rec(1).detail_uom                := p_item_um;  -- NPD Conv.
    l_formula_dtl_rec(1).release_type              := p_release_type;
    l_formula_dtl_rec(1).scrap_factor              := p_scrap_factor;
    l_formula_dtl_rec(1).scale_type_dtl            := p_scale_type;
    l_formula_dtl_rec(1).cost_alloc                := p_cost_alloc;
    l_formula_dtl_rec(1).phantom_type              := p_phantom_type;
    l_formula_dtl_rec(1).last_updated_by           := p_user_id;
    l_formula_dtl_rec(1).created_by                := p_user_id;
    l_formula_dtl_rec(1).last_update_date          := p_last_update_date;
    l_formula_dtl_rec(1).creation_date             := p_last_update_date;
    l_formula_dtl_rec(1).last_update_login         := p_user_id;
    l_formula_dtl_rec(1).contribute_step_qty_ind   := p_contribute_step_qty_ind;
    l_formula_dtl_rec(1).contribute_yield_ind      := p_contribute_yield_ind;

    IF p_by_product_type = ' ' OR p_line_type <> 2 THEN
      l_formula_dtl_rec(1).by_product_type         := NULL;
    ELSE
      l_formula_dtl_rec(1).by_product_type         := p_by_product_type;
    END IF;

    GMD_FORMULA_DETAIL_PUB.Insert_FormulaDetail
                      (   p_api_version            => 1.0
                        , p_init_msg_list          => FND_API.G_TRUE
                        , p_commit                 => FND_API.G_FALSE
                        , p_called_from_forms      => 'NO'
                        , x_return_status          => l_return_status
                        , x_msg_count              => l_message_count
                        , x_msg_data               => l_message_list
                        , p_formula_detail_tbl     => l_formula_dtl_rec);

    /*B4771255 Changed the return status checking to include the toq warning */
    IF (l_return_status NOT IN (FND_API.G_RET_STS_SUCCESS, 'Q')) THEN
      RAISE INSERT_DTL_EXCEPTION;
    END IF;

    EXCEPTION
      WHEN INSERT_DTL_EXCEPTION THEN
        ROLLBACK TO Add_Item;
        FND_MSG_PUB.GET( p_msg_index     => 1,
                         p_data          => l_message,
                         p_encoded       => 'F',
                         p_msg_index_out => l_dummy);

        x_return_code := 'F';
        x_error_msg   := l_message;

     WHEN RECORD_CHANGED_EXCEPTION THEN
        ROLLBACK TO Add_Item;
        FND_MESSAGE.SET_NAME('FND', 'FND_RECORD_CHANGED_ERROR');
        x_return_code := 'F';
        x_error_msg   := gmd_api_grp.get_message;

     WHEN OTHERS THEN
        ROLLBACK TO Add_Item;
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := gmd_api_grp.get_message;

  END Insert_Formula_Detail;

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
                                   ,p_prod_percent            IN NUMBER
                                   ,x_return_code             OUT NOCOPY VARCHAR2
                                   ,x_error_msg               OUT NOCOPY VARCHAR2) IS

    l_text_code              NUMBER(10);
    l_return_status          VARCHAR2(2);
    l_message_count          NUMBER;
    l_message_list           VARCHAR2(2000);
    l_message                VARCHAR2(1000);
    l_dummy	             NUMBER;
    l_qty                    NUMBER;
    l_formula_dtl_rec        GMD_FORMULA_DETAIL_PUB.formula_update_dtl_tbl_type;
    UPDATE_DTL_EXCEPTION     EXCEPTION;
    RECORD_CHANGED_EXCEPTION EXCEPTION;

    CURSOR Cur_get_formula IS
      SELECT formula_no,
             formula_vers, auto_product_calc    -- Kapil ME Auto-Prod
      FROM   fm_form_mst
      WHERE  formula_id       = p_formula_id;

    CURSOR Cur_get_line IS
       SELECT *
       FROM   fm_matl_dtl
       WHERE  formulaline_id   = p_formulaline_id AND
              last_update_date = p_last_update_date_orig;

    l_line_rec Cur_get_line%ROWTYPE;

      l_auto_product_calc VARCHAR2(1);

    FUNCTION Get_Scaled_Qty (p_line_no   NUMBER,
                             p_item_id   NUMBER,
                             p_line_type NUMBER) RETURN NUMBER IS

      l_scaled_qty NUMBER;

    BEGIN

      FOR i IN 1.. G_SCALE_REC.COUNT LOOP

       IF G_SCALE_REC(i).line_no   = p_line_no AND
          G_SCALE_REC(i).inventory_item_id   = p_item_id AND -- NPD Conv.
          G_SCALE_REC(i).line_type = p_line_type THEN
         l_scaled_qty := G_SCALE_REC(i).qty;
         G_SCALE_REC(i).line_no := -1;
         G_SCALE_REC(i).inventory_item_id := -1;  -- NPD Conv.
         EXIT;
       END IF;

      END LOOP;

      RETURN l_scaled_qty;

    END Get_Scaled_Qty;


  BEGIN

    x_error_msg   := '';
    x_return_code := FND_API.G_RET_STS_SUCCESS;

    IF p_last_update_date_orig IS NOT NULL THEN

      OPEN Cur_get_line;
      FETCH Cur_get_line INTO l_line_rec;

      IF Cur_get_line%NOTFOUND THEN
        CLOSE Cur_get_line;
        RAISE RECORD_CHANGED_EXCEPTION;
      END IF;
      CLOSE Cur_get_line;

    END IF;


    IF p_text_code <= 0 THEN
      l_text_code := NULL;
    ELSE
      l_text_code := p_text_code;
    END IF;

    l_formula_dtl_rec(1).record_type    := 'U';

    OPEN Cur_get_formula;
    FETCH Cur_get_formula INTO l_formula_dtl_rec(1).formula_no,
                               l_formula_dtl_rec(1).formula_vers,
                               l_auto_product_calc;

    IF Cur_get_formula%NOTFOUND THEN
      CLOSE Cur_get_formula;
      RAISE RECORD_CHANGED_EXCEPTION;
    END IF;

    CLOSE Cur_get_formula;

    --- G_SCALE_REC contains scaled qties after the user has performed a
    --- scale or a theoretical yield.
    IF G_SCALE_REC.COUNT > 0 THEN

      l_qty := Get_Scaled_Qty (p_line_no,
                               p_item_id,
                               p_line_type);
    ELSE
      l_qty := p_qty;
    END IF;

    IF p_tp_formula_id < 0 THEN
      l_formula_dtl_rec(1).tpformula_id := NULL;
    ELSE
      l_formula_dtl_rec(1).tpformula_id := p_tp_formula_id;
    END IF;

    IF P_iaformula_id < 0 THEN
      l_formula_dtl_rec(1).iaformula_id := NULL;
    ELSE
      l_formula_dtl_rec(1).iaformula_id := p_iaformula_id;
    END IF;

    -- Scaling attributes are relevant if Integer scale type selected
    IF p_scale_type = 2 THEN
      l_formula_dtl_rec(1).scale_multiple          := p_scale_multiple;
      l_formula_dtl_rec(1).scale_rounding_variance := p_scale_rounding_variance;
      l_formula_dtl_rec(1).rounding_direction      := p_rounding_direction;
      IF p_scale_uom = ' 'THEN
        l_formula_dtl_rec(1).scale_uom             := NULL;
      ELSE
        l_formula_dtl_rec(1).scale_uom             := p_scale_uom;
      END IF;
    ELSE
      l_formula_dtl_rec(1).scale_multiple          := NULL;
      l_formula_dtl_rec(1).scale_rounding_variance := NULL;
      l_formula_dtl_rec(1).rounding_direction      := NULL;
      l_formula_dtl_rec(1).scale_uom               := NULL;
    END IF;

    l_formula_dtl_rec(1).formula_id                := p_formula_id;
    l_formula_dtl_rec(1).item_no                   := p_item_no;
    l_formula_dtl_rec(1).revision                  := TRIM(p_revision);
    l_formula_dtl_rec(1).user_id                   := p_user_id;
    l_formula_dtl_rec(1).text_code_dtl             := l_text_code;
    l_formula_dtl_rec(1).formulaline_id            := p_formulaline_id;
    l_formula_dtl_rec(1).line_type                 := p_line_type;
    l_formula_dtl_rec(1).line_no                   := p_line_no;
    l_formula_dtl_rec(1).qty                       := l_qty;
    l_formula_dtl_rec(1).detail_uom                := p_item_um;  --NPD Conv.
    l_formula_dtl_rec(1).release_type              := p_release_type;
    l_formula_dtl_rec(1).scrap_factor              := p_scrap_factor;
    l_formula_dtl_rec(1).scale_type_dtl            := p_scale_type;
    l_formula_dtl_rec(1).cost_alloc                := p_cost_alloc;
    l_formula_dtl_rec(1).rework_type               := p_rework_type;
    l_formula_dtl_rec(1).phantom_type              := p_phantom_type;
    l_formula_dtl_rec(1).last_updated_by           := p_user_id;
    l_formula_dtl_rec(1).created_by                := p_user_id;
    l_formula_dtl_rec(1).last_update_date          := p_last_update_date;
    l_formula_dtl_rec(1).creation_date             := p_last_update_date;
    l_formula_dtl_rec(1).last_update_login         := p_user_id;
    l_formula_dtl_rec(1).contribute_step_qty_ind   := p_contribute_step_qty_ind;
    l_formula_dtl_rec(1).contribute_yield_ind      := p_contribute_yield_ind;

    IF p_by_product_type = ' ' OR p_line_type <> 2 THEN
      l_formula_dtl_rec(1).by_product_type         := NULL;
    ELSE
      l_formula_dtl_rec(1).by_product_type         := p_by_product_type;
    END IF;

    -- Kapil ME Auto-Prod :Bug# 5716318
    /* Validations for the the value passed from the Designer */
    IF (p_line_type = 1 AND p_scale_type = 1 ) AND l_auto_product_calc = 'Y' THEN
       l_formula_dtl_rec(1).prod_percent              := p_prod_percent;
    ELSE
       l_formula_dtl_rec(1).prod_percent              := NULL;
    END IF;

    /* If Auto-Product Qty calculation is set then, all Percentage value are made 0
       This is called when the user sets the parameter and enters the % value for a
       product. Then for other products, the % is made 0 so that later validation does
       not fail. */
    if l_auto_product_calc = 'Y' THEN
        update fm_matl_dtl
        set prod_percent = 0
        where formula_id = p_formula_id
        and formulaline_id <> p_formulaline_id
        and line_type = 1
        and scale_type <> 0
        and prod_percent IS NULL ;
    END if;


    --- p_called_from_forms parameter is set to 'Yes' so that the API does not
    --- perform validation on line number. This validation fails when
    --- resequencing item line numbers.
    GMD_FORMULA_DETAIL_PUB.Update_FormulaDetail
                      (   p_api_version            => 2
                        , p_init_msg_list          => FND_API.G_TRUE
                        , p_commit                 => FND_API.G_FALSE
                        , p_called_from_forms      => 'YES'
                        , x_return_status          => l_return_status
                        , x_msg_count              => l_message_count
                        , x_msg_data               => l_message_list
                        , p_formula_detail_tbl     => l_formula_dtl_rec);

    /*B4771255 Changed the return status checking to include the toq warning */
    IF (l_return_status NOT IN (FND_API.G_RET_STS_SUCCESS, 'Q')) THEN
       RAISE UPDATE_DTL_EXCEPTION;
    END IF;


    EXCEPTION
      WHEN UPDATE_DTL_EXCEPTION THEN
        FND_MSG_PUB.GET( p_msg_index     => 1,
                         p_data          => l_message,
                         p_encoded       => 'F',
                         p_msg_index_out => l_dummy);

        x_return_code := 'F';
        x_error_msg   := l_message;

     WHEN RECORD_CHANGED_EXCEPTION THEN
        FND_MESSAGE.SET_NAME('FND', 'FND_RECORD_CHANGED_ERROR');
        x_return_code := 'F';
        x_error_msg   := gmd_api_grp.get_message;

     WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := gmd_api_grp.get_message;

  END Update_Formula_Detail;

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
                                    x_error_msg             OUT NOCOPY VARCHAR2) IS

    l_return_status           VARCHAR2(5);
    l_timestamp               DATE;
    l_formula_no              VARCHAR2(32);
    l_fm_form_mst_rec         FM_FORM_MST%ROWTYPE;
    INSERT_FORMULA_EXCEPTION  EXCEPTION;
    GET_SURROGATE_EXCEPTION   EXCEPTION;

    l_message_count           NUMBER;
    l_msg_data                VARCHAR2(2000);
    l_message                 VARCHAR2(1000);
    l_dummy	              NUMBER;

  BEGIN

    x_return_code := FND_API.G_RET_STS_SUCCESS;
    x_error_msg   := '';

    x_formula_id := GMDSURG.get_surrogate('formula_id');
    IF (x_formula_id < 1) THEN
      RAISE GET_SURROGATE_EXCEPTION;
    END IF;

    IF p_text_code <= 0 THEN
      l_fm_form_mst_rec.text_code := NULL;
    ELSE
      l_fm_form_mst_rec.text_code := p_text_code;
    END IF;

    --- If formula number is not passed, then we need to create a dummy
    --- formula number. This can happen when the user just want to
    --- 'play' in the Designer and build a formula without entering header
    --- information. If the user decides to save the new formula, he
    --- will be prompted to enter header information and this will then
    --- be updated (including formula number and version - see
    --- Update_Formula_Header procedure).

    IF p_formula_no IS NULL THEN
      l_fm_form_mst_rec.formula_no   := x_formula_id || '#' ||
                                        TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS');
      l_fm_form_mst_rec.formula_vers := 1;
    ELSE
      l_fm_form_mst_rec.formula_no   := p_formula_no;
      l_fm_form_mst_rec.formula_vers := p_formula_vers;
    END IF;


    l_fm_form_mst_rec.formula_id           := x_formula_id;
    l_fm_form_mst_rec.formula_type         := p_formula_type;
    l_fm_form_mst_rec.scale_type           := p_scale_type;
    l_fm_form_mst_rec.formula_desc1        := p_formula_desc;
    l_fm_form_mst_rec.formula_desc2        := p_formula_desc2;
    l_fm_form_mst_rec.formula_class        := p_formula_class;
    l_fm_form_mst_rec.fmcontrol_class      := NULL;
    l_fm_form_mst_rec.in_use               := 0;
    l_fm_form_mst_rec.inactive_ind         := 0;
    l_fm_form_mst_rec.owner_organization_id   := p_owner_organization_id;
    l_fm_form_mst_rec.TOTAL_INPUT_QTY	   := 0;
    l_fm_form_mst_rec.TOTAL_OUTPUT_QTY	   := 0;
    l_fm_form_mst_rec.yield_uom	   := NULL;
    l_fm_form_mst_rec.FORMULA_STATUS       := '100';
    l_fm_form_mst_rec.OWNER_ID     	   := p_owner_id;
    l_fm_form_mst_rec.attribute1           := NULL;
    l_fm_form_mst_rec.attribute2           := NULL;
    l_fm_form_mst_rec.attribute3           := NULL;
    l_fm_form_mst_rec.attribute4           := NULL;
    l_fm_form_mst_rec.attribute5           := NULL;
    l_fm_form_mst_rec.attribute6           := NULL;
    l_fm_form_mst_rec.attribute7           := NULL;
    l_fm_form_mst_rec.attribute8           := NULL;
    l_fm_form_mst_rec.attribute9           := NULL;
    l_fm_form_mst_rec.attribute10          := NULL;
    l_fm_form_mst_rec.attribute11          := NULL;
    l_fm_form_mst_rec.attribute12          := NULL;
    l_fm_form_mst_rec.attribute13          := NULL;
    l_fm_form_mst_rec.attribute14          := NULL;
    l_fm_form_mst_rec.attribute15          := NULL;
    l_fm_form_mst_rec.attribute16          := NULL;
    l_fm_form_mst_rec.attribute17          := NULL;
    l_fm_form_mst_rec.attribute18          := NULL;
    l_fm_form_mst_rec.attribute19          := NULL;
    l_fm_form_mst_rec.attribute20          := NULL;
    l_fm_form_mst_rec.attribute21          := NULL;
    l_fm_form_mst_rec.attribute22          := NULL;
    l_fm_form_mst_rec.attribute23          := NULL;
    l_fm_form_mst_rec.attribute24          := NULL;
    l_fm_form_mst_rec.attribute25          := NULL;
    l_fm_form_mst_rec.attribute26          := NULL;
    l_fm_form_mst_rec.attribute27          := NULL;
    l_fm_form_mst_rec.attribute28          := NULL;
    l_fm_form_mst_rec.attribute29          := NULL;
    l_fm_form_mst_rec.attribute30          := NULL;
    l_fm_form_mst_rec.attribute_category   := NULL;
    l_fm_form_mst_rec.delete_mark          := 0;
    l_fm_form_mst_rec.created_by           := g_created_by;
    l_fm_form_mst_rec.creation_date        := p_last_update_date;
    l_fm_form_mst_rec.last_update_date     := p_last_update_date;
    l_fm_form_mst_rec.last_update_login    := g_login_id;
    l_fm_form_mst_rec.last_updated_by      := g_created_by;
    -- Kapil ME Auto-Prod
    l_fm_form_mst_rec.auto_product_calc    := p_auto_product_calc;


    GMD_FORMULA_HEADER_PVT.Insert_FormulaHeader
              ( p_api_version        => 1.0
              , p_init_msg_list      => FND_API.G_TRUE
              , p_commit             => FND_API.G_FALSE
              , x_return_status      => l_return_status
              , x_msg_count          => l_message_count
              , x_msg_data           => l_msg_data
              , p_formula_header_rec => l_fm_form_mst_rec
             );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE INSERT_FORMULA_EXCEPTION;
    END IF;

    EXCEPTION
      WHEN INSERT_FORMULA_EXCEPTION THEN
        FND_MSG_PUB.GET( p_msg_index     => 1,
                         p_data          => l_message,
                         p_encoded       => 'F',
                         p_msg_index_out => l_dummy);

        x_return_code := 'F';
        x_error_msg   := l_message;

      WHEN GET_SURROGATE_EXCEPTION THEN
        FND_MESSAGE.SET_NAME('GMD', 'FM_INVALID_FORMULA_ID');
        x_return_code := 'F';
        x_error_msg   := gmd_api_grp.get_message;

      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := gmd_api_grp.get_message;

  END Create_Formula_Header;


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
                                  x_error_msg          OUT NOCOPY VARCHAR2) IS

    CURSOR Cur_get_dtl IS
      SELECT formulaline_id
      FROM   fm_matl_dtl
      WHERE  formula_id         = p_formula_id      AND
             formulaline_id     = p_formulaline_id  AND
             last_update_date   = p_last_update_date;

    l_return_status       VARCHAR2(2);
    l_message_count       NUMBER;
    l_message_list        VARCHAR2(2000);
    l_message             VARCHAR2(1000);
    l_dummy	          NUMBER;
    l_formula_dtl_rec     GMD_FORMULA_DETAIL_PUB.formula_update_dtl_tbl_type;
    DELETE_LINE_EXCEPTION    EXCEPTION;
    RECORD_CHANGED_EXCEPTION EXCEPTION;

  BEGIN

    x_return_code := 'S';
    x_error_msg   := '';

    OPEN Cur_get_dtl;
    FETCH Cur_get_dtl INTO l_dummy;

    IF Cur_get_dtl%NOTFOUND THEN
      CLOSE Cur_get_dtl;
      RAISE RECORD_CHANGED_EXCEPTION;
    END IF;

    CLOSE Cur_get_dtl;

    l_formula_dtl_rec(1).record_type    := 'D';
    l_formula_dtl_rec(1).line_type      := p_line_type;
    l_formula_dtl_rec(1).formula_id     := p_formula_id;
    l_formula_dtl_rec(1).formulaline_id := p_formulaline_id;
    l_formula_dtl_rec(1).user_id        := G_CREATED_BY;

    GMD_FORMULA_DETAIL_PUB.Delete_FormulaDetail
                      (   p_api_version            => 1.1
                        , p_init_msg_list          => FND_API.G_TRUE
                        , p_commit                 => FND_API.G_FALSE
                        , p_called_from_forms      => 'NO'
                        , x_return_status          => l_return_status
                        , x_msg_count              => l_message_count
                        , x_msg_data               => l_message_list
                        , p_formula_detail_tbl     => l_formula_dtl_rec);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE DELETE_LINE_EXCEPTION;
    END IF;

    EXCEPTION
      WHEN DELETE_LINE_EXCEPTION THEN
        FND_MSG_PUB.GET( p_msg_index     => 1,
                         p_data          => l_message,
                         p_encoded       => 'F',
                         p_msg_index_out => l_dummy);

        x_return_code := 'F';
        x_error_msg   := l_message;
     WHEN RECORD_CHANGED_EXCEPTION THEN
        FND_MESSAGE.SET_NAME('FND', 'FND_RECORD_CHANGED_ERROR');
        x_return_code := 'F';
        x_error_msg   := gmd_api_grp.get_message;
     WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := gmd_api_grp.get_message;

  END Delete_Formula_Detail;

/* Api start of comments
 +============================================================================
 |   PROCEDURE NAME
 |      Del_Formula_Detail_With_No_Val
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
                                           x_error_msg        OUT NOCOPY VARCHAR2) IS

    CURSOR Cur_get_dtl IS
      SELECT formulaline_id
      FROM   fm_matl_dtl
      WHERE  formula_id         = p_formula_id      AND
             formulaline_id     = p_formulaline_id  AND
             last_update_date   = p_last_update_date;

    l_return_status       VARCHAR2(2);
    l_message_count       NUMBER;
    l_message_list        VARCHAR2(2000);
    l_message             VARCHAR2(1000);
    l_dummy	          NUMBER;
    l_formula_dtl_rec     GMD_FORMULA_DETAIL_PUB.formula_update_dtl_tbl_type;
    DELETE_LINE_EXCEPTION    EXCEPTION;
    RECORD_CHANGED_EXCEPTION EXCEPTION;

  BEGIN

    x_return_code := 'S';
    x_error_msg   := '';

    OPEN Cur_get_dtl;
    FETCH Cur_get_dtl INTO l_dummy;

    IF Cur_get_dtl%NOTFOUND THEN
      CLOSE Cur_get_dtl;
      RAISE RECORD_CHANGED_EXCEPTION;
    END IF;

    CLOSE Cur_get_dtl;

    DELETE FROM
      fm_matl_dtl
    WHERE
      formulaline_id = p_formulaline_id;

    EXCEPTION
     WHEN RECORD_CHANGED_EXCEPTION THEN
        FND_MESSAGE.SET_NAME('FND', 'FND_RECORD_CHANGED_ERROR');
        x_return_code := 'F';
        x_error_msg   := gmd_api_grp.get_message;
     WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := gmd_api_grp.get_message;

  END Del_Formula_Detail_With_No_Val;

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
  PROCEDURE Validate_Cost_Allocation(p_formula_id       IN  NUMBER,
                                     p_formulaline_id   IN  NUMBER,
                                     p_cost_alloc       IN  NUMBER,
                                     x_return_code      OUT NOCOPY VARCHAR2,
                                     x_error_msg        OUT NOCOPY VARCHAR2) IS

    l_cost_alloc	  NUMBER(5);
    COST_ALLOC_EXCEPTION  EXCEPTION;

    CURSOR Cur_cost_alloc IS
      SELECT SUM(cost_alloc)
      FROM   fm_matl_dtl
      WHERE  line_type = 1
      AND    formula_id = p_formula_id
      AND    formulaline_id <> p_formulaline_id;

  BEGIN

    x_return_code := 'S';
  --  x_error_msg   := '';

    OPEN Cur_cost_alloc;
    FETCH Cur_cost_alloc INTO l_cost_alloc;
    CLOSE Cur_cost_alloc;

    IF ((NVL(l_cost_alloc, 0) + p_cost_alloc) > 1) OR
       --bug 3336945, if formula line is then total cost should be equal to 1
       (p_formulaline_id = -1 AND l_cost_alloc <> 1) THEN
      RAISE COST_ALLOC_EXCEPTION;
    END IF;

    EXCEPTION
      WHEN COST_ALLOC_EXCEPTION THEN
        FND_MESSAGE.SET_NAME ('GMD','FM_SUM_ALLOC <> 1');
        x_return_code := 'W';
        x_error_msg   := gmd_api_grp.get_message;

     WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := gmd_api_grp.get_message;

  END Validate_Cost_Allocation;

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
                               x_error_msg       OUT NOCOPY VARCHAR2) IS

    l_qty                NUMBER;
    l_inv_uom   	 VARCHAR2(4);
    CONV_ITEM_EXCEPTION  EXCEPTION;
    ITEM_UM_EXCEPTION    EXCEPTION;

    CURSOR Get_Item_Uom   IS
      SELECT primary_uom_code
      FROM   mtl_system_items_b
      WHERE  inventory_item_id = p_item_id;

    CURSOR Cur_check_uom IS
      SELECT 1
      FROM   sys.dual
      WHERE EXISTS (SELECT 1
                    FROM mtl_units_of_measure
                    WHERE uom_code = p_item_uom);
    l_exists BINARY_INTEGER;

  BEGIN

    x_return_code := 'S';
    x_error_msg   := '';

    -- Validate Item UOM first
    OPEN Cur_check_uom;
    FETCH Cur_check_uom INTO l_exists;
    IF Cur_check_uom%NOTFOUND THEN
      CLOSE Cur_check_uom;
      RAISE ITEM_UM_EXCEPTION;
    END IF;
    CLOSE Cur_check_uom;

    OPEN Get_Item_Uom;
    FETCH Get_Item_Uom INTO l_inv_uom;
    CLOSE Get_Item_Uom;

    l_qty := INV_CONVERT.inv_um_convert(  item_id        => p_item_id
                                         ,precision      => 5
                                         ,from_quantity  => 1
                                         ,from_unit      => p_item_uom
                                         ,to_unit        => l_inv_uom
                                         ,from_name      => NULL
                                         ,to_name	 => NULL);

    IF (l_qty = -1) THEN
      FND_MESSAGE.set_name('GMI', 'IC_UOMCV_PACKAGE_ERR');
      RAISE CONV_ITEM_EXCEPTION;
    ELSIF (l_qty = -3) THEN
      FND_MESSAGE.set_name('GMI', 'IC_UOMCV_CURUMTYPE_ERR');
      RAISE CONV_ITEM_EXCEPTION;
    ELSIF (l_qty = -4) THEN
      FND_MESSAGE.set_name('GMI', 'IC_UOMCV_NEWUMTYPE_ERR');
      RAISE CONV_ITEM_EXCEPTION;
    ELSIF (l_qty = -5) THEN
      FND_MESSAGE.set_name('GMI', 'IC_UOMCV_INVUOMTYPE_ERR2');
      FND_MESSAGE.set_token('FROMUOM',p_item_uom);
      FND_MESSAGE.set_token('TOUOM',l_inv_uom);
      RAISE CONV_ITEM_EXCEPTION;
    ELSIF (l_qty = -6) THEN
      FND_MESSAGE.set_name('GMI', 'IC_UOMCV_INVUMTYPE_ERR');
      RAISE CONV_ITEM_EXCEPTION;
    ELSIF (l_qty = -7) THEN
      FND_MESSAGE.set_name('GMI', 'IC_UOMCV_CURFACTOR_ERR');
      RAISE CONV_ITEM_EXCEPTION;
    ELSIF (l_qty = -10) THEN
      FND_MESSAGE.set_name('GMI', 'IC_UOMCV_INVUOMTYPE_ERR2');
      FND_MESSAGE.set_token('FROMUOM',p_item_uom);
      FND_MESSAGE.set_token('TOUOM',l_inv_uom);
      RAISE CONV_ITEM_EXCEPTION;
    ELSIF (l_qty = -11) THEN
      FND_MESSAGE.set_name('GMI', 'IC_UOMCV_NOITEMID_ERR');
      RAISE CONV_ITEM_EXCEPTION;
    ELSIF (l_qty < -11) THEN
      FND_MESSAGE.set_name('GMI', 'IC_UOMCV_FATAL_ERR');
      RAISE CONV_ITEM_EXCEPTION;
    END IF;
  EXCEPTION
      WHEN ITEM_UM_EXCEPTION THEN
        FND_MESSAGE.SET_NAME('GMA','SY_INVALID_UM_CODE');
        x_return_code := 'F';
        x_error_msg   := gmd_api_grp.get_message;
      WHEN CONV_ITEM_EXCEPTION THEN
        x_return_code := 'F';
        x_error_msg   := gmd_api_grp.get_message;
     WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := gmd_api_grp.get_message;

  END Validate_Item_Uom;

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
  PROCEDURE Check_Item_Used_In_Recipe( p_formulaline_id  IN  NUMBER,
                                       x_nb_recipes      OUT NOCOPY   NUMBER,
                                       x_warning_message OUT NOCOPY   VARCHAR2,
                                       x_return_code     OUT NOCOPY   VARCHAR2,
                                       x_error_msg       OUT NOCOPY   VARCHAR2) IS

    l_calculatable_rec       GMD_AUTO_STEP_CALC.CALCULATABLE_REC_TYPE;
    l_recipe_tbl             GMD_AUTO_STEP_CALC.RECIPE_ID_TBL;
    l_check_step_mat         GMD_AUTO_STEP_CALC.CHECK_STEP_MAT_TYPE;
    l_return_status          VARCHAR2(2);
    l_message_count          NUMBER;
    l_msg_data               VARCHAR2(2000);
    l_message                VARCHAR2(1000);
    l_dummy	             NUMBER;
    CHECK_ITEM_EXCEPTION     EXCEPTION;

  BEGIN

    x_error_msg       := '';
    x_warning_message := '';
    x_return_code     := FND_API.G_RET_STS_SUCCESS;

    l_calculatable_rec.formulaline_id := p_formulaline_id;

    --  Count recipes where this formulaline exists in step/mat association,
    --    and where calculate_step_qty flag IS set (ASQC=Yes)
    --    and where delete_mark is NOT set
    --    and the recipe is NOT marked obsolete.
    GMD_AUTO_STEP_CALC.Check_Del_From_Step_Mat(p_check          => l_calculatable_rec,
                                               p_recipe_tbl     => l_recipe_tbl,
                                               p_check_step_mat => l_check_step_mat,
                                               p_msg_count      => l_message_count,
                                               p_msg_stack      => l_msg_data,
                                               p_return_status  => l_return_status);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE CHECK_ITEM_EXCEPTION;
    END IF;

    --- Store these variables for Cascade_Update_Recipes
    g_calculatable_rec := l_calculatable_rec;
    g_recipe_tbl       := l_recipe_tbl;
    g_check_step_mat   := l_check_step_mat;

    x_nb_recipes := 0;

    IF l_check_step_mat.asqc_recipes > 0 THEN
      x_nb_recipes := l_check_step_mat.asqc_recipes;
      FND_MESSAGE.SET_NAME('GMD', 'GMD_FORM_DEL_RECALC_AUTO_STEP');
      FND_MESSAGE.SET_TOKEN('RECIPE_NO', x_nb_recipes);
      x_warning_message := gmd_api_grp.get_message;
    ELSE
      -- Else Check if there are any rows in gmd_recipe_step_materials with this
      -- formulaline_id, regardless of ASQC flag
      IF l_check_step_mat.step_assoc_recipes > 0 THEN
        x_nb_recipes := l_check_step_mat.step_assoc_recipes;
        FND_MESSAGE.SET_NAME('GMD', 'GMD_FORM_DEL_REVIEW_STEP_QTY');
        FND_MESSAGE.SET_TOKEN('RECIPE_NO', x_nb_recipes);
        x_warning_message := gmd_api_grp.get_message;
      END IF;
    END IF;

    EXCEPTION
      WHEN CHECK_ITEM_EXCEPTION THEN
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
        x_error_msg   := gmd_api_grp.get_message;

  END Check_Item_Used_In_Recipe;



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
                                   x_error_msg    OUT NOCOPY VARCHAR2) IS

    l_calculatable_rec       GMD_AUTO_STEP_CALC.CALCULATABLE_REC_TYPE;
    l_recipe_tbl             GMD_AUTO_STEP_CALC.RECIPE_ID_TBL;
    l_check_step_mat         GMD_AUTO_STEP_CALC.CHECK_STEP_MAT_TYPE;
    l_return_status          VARCHAR2(2);
    l_message_count          NUMBER;
    l_msg_data               VARCHAR2(2000);
    l_message                VARCHAR2(1000);
    l_dummy	             NUMBER;
    l_date                   DATE;
    UPDATE_RECIPE_EXCEPTION  EXCEPTION;

  BEGIN

    x_error_msg       := '';
    x_return_code     := FND_API.G_RET_STS_SUCCESS;

    l_date                               := SYSDATE;
    g_calculatable_rec.created_by        := g_created_by;
    g_calculatable_rec.last_updated_by   := g_created_by;
    g_calculatable_rec.last_update_login := g_login_id;
    g_calculatable_rec.creation_date     := l_date;
    g_calculatable_rec.last_update_date  := l_date;

    GMD_AUTO_STEP_CALC.Cascade_Del_To_Step_Mat(p_check          => g_calculatable_rec,
                                               p_recipe_tbl     => g_recipe_tbl,
                                               p_check_step_mat => g_check_step_mat,
                                               p_msg_count      => l_message_count,
                                               p_msg_stack      => l_msg_data,
                                               p_return_status  => l_return_status,
                                               P_organization_id => null);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE UPDATE_RECIPE_EXCEPTION;
    END IF;

    EXCEPTION
      WHEN UPDATE_RECIPE_EXCEPTION THEN
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
        x_error_msg   := gmd_api_grp.get_message;

  END Cascade_Update_Recipes;

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
 |     p_scale_factor    NUMBER
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
                                        x_error_msg    OUT NOCOPY VARCHAR2) IS

    CURSOR Get_Materials IS
    SELECT
      line_no,
      line_type,
      inventory_item_id,  -- NPD Conv.
      qty,
      detail_uom,  -- NPD Conv.
      scale_type,
      contribute_yield_ind,
      scale_multiple,
      scale_rounding_variance,
      rounding_direction
    FROM
      fm_matl_dtl
    WHERE
      formula_id  = p_formula_id;

    l_scale_tab              GMD_COMMON_SCALE.scale_tab;
    l_return_status          VARCHAR2(2);
    l_message_count          NUMBER;
    l_msg_data               VARCHAR2(2000);
    l_message                VARCHAR2(1000);
    l_dummy	             NUMBER;
    THEORETICAL_YIELD_EXCEPTION  EXCEPTION;
    TYPE LineNoTab             IS TABLE OF FM_MATL_DTL.line_no%TYPE;
    TYPE LineTypeTab           IS TABLE OF FM_MATL_DTL.line_type%TYPE;
    TYPE ItemIdTab             IS TABLE OF FM_MATL_DTL.inventory_item_id%TYPE;  -- NPD Conv.
    TYPE QtyTab                IS TABLE OF FM_MATL_DTL.qty%TYPE;
    TYPE ItemUmTab             IS TABLE OF FM_MATL_DTL.detail_uom%TYPE;  -- NPD Conv.
    TYPE ScaleTypeTab          IS TABLE OF FM_MATL_DTL.scale_type%TYPE;
    TYPE ContributeYieldIndTab IS TABLE OF FM_MATL_DTL.contribute_yield_ind%TYPE;
    TYPE ScaleMultipleTab      IS TABLE OF FM_MATL_DTL.scale_multiple%TYPE;
    TYPE ScaleRoundingTab      IS TABLE OF FM_MATL_DTL.scale_rounding_variance%TYPE;
    TYPE RoundingDirectionTab  IS TABLE OF FM_MATL_DTL.rounding_direction%TYPE;

    l_line_no                  LineNoTab;
    l_line_type                LineTypeTab;
    l_inventory_item_id        ItemIdTab;  -- NPD Conv.
    l_qty                      QtyTab;
    l_detail_uom               ItemUmTab;  -- NPD Conv.
    l_scale_type               ScaleTypeTab;
    l_contribute_yield_ind     ContributeYieldIndTab;
    l_scale_multiple           ScaleMultipleTab;
    l_scale_rounding_variance  ScaleRoundingTab;
    l_rounding_direction       RoundingDirectionTab;

    -- NPD Conv.
    l_orgn_id NUMBER;

    CURSOR get_formula_owner_orgn_id(vformula_id NUMBER) IS
      SELECT owner_organization_id
      FROM fm_form_mst
      WHERE formula_id = vformula_id;

  BEGIN

    x_error_msg       := '';
    x_return_code     := FND_API.G_RET_STS_SUCCESS;

    OPEN Get_Materials;

    FETCH Get_Materials
     BULK COLLECT INTO
      l_line_no,
      l_line_type,
      l_inventory_item_id,
      l_qty,
      l_detail_uom,
      l_scale_type,
      l_contribute_yield_ind,
      l_scale_multiple,
      l_scale_rounding_variance,
      l_rounding_direction;

    CLOSE Get_Materials;

    IF l_line_no.COUNT > 0 THEN

      FOR i IN 1..l_line_no.COUNT LOOP
       l_scale_tab(i).line_no                := l_line_no(i);
       l_scale_tab(i).line_type              := l_line_type(i);
       l_scale_tab(i).inventory_item_id      := l_inventory_item_id(i);  -- NPD Conv.
       l_scale_tab(i).qty                    := l_qty(i);
       l_scale_tab(i).detail_uom             := l_detail_uom(i);  -- NPD Conv.
       l_scale_tab(i).scale_type             := l_scale_type(i);
       l_scale_tab(i).contribute_yield_ind   := l_contribute_yield_ind(i);
       l_scale_tab(i).scale_multiple         := l_scale_multiple(i);
       l_scale_tab(i).scale_rounding_variance := l_scale_rounding_variance(i);
       l_scale_tab(i).rounding_direction     := l_rounding_direction(i);
      END LOOP;

     -- NPD Conv.
     OPEN get_formula_owner_orgn_id(p_formula_id);
     FETCH get_formula_owner_orgn_id INTO l_orgn_id;
     CLOSE get_formula_owner_orgn_id;

      GMD_COMMON_SCALE.Theoretical_Yield ( p_scale_tab     => l_scale_tab
                                          ,p_orgn_id       => l_orgn_id
                                          ,p_scale_factor  => p_scale_factor
                                          ,x_scale_tab     => G_SCALE_REC
                                          ,x_return_status => l_return_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE THEORETICAL_YIELD_EXCEPTION;
      END IF;

    END IF;

    EXCEPTION
      WHEN THEORETICAL_YIELD_EXCEPTION THEN
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
        x_error_msg   := gmd_api_grp.get_message;

  END Calculate_Theoretical_yield;

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
                          x_error_msg    OUT NOCOPY VARCHAR2) IS

    CURSOR Get_Materials IS
    SELECT
      line_no,
      line_type,
      inventory_item_id, -- NPD Conv.
      qty,
      detail_uom, -- NPD Conv.
      scale_type,
      contribute_yield_ind,
      scale_multiple,
      scale_rounding_variance,
      rounding_direction
    FROM
      fm_matl_dtl
    WHERE
      formula_id  = p_formula_id;

    l_scale_tab              GMD_COMMON_SCALE.scale_tab;
    l_return_status          VARCHAR2(2);
    l_message_count          NUMBER;
    l_msg_data               VARCHAR2(2000);
    l_message                VARCHAR2(1000);
    l_dummy	             NUMBER;
    SCALE_EXCEPTION          EXCEPTION;
    TYPE LineNoTab             IS TABLE OF FM_MATL_DTL.line_no%TYPE;
    TYPE LineTypeTab           IS TABLE OF FM_MATL_DTL.line_type%TYPE;
    TYPE ItemIdTab             IS TABLE OF FM_MATL_DTL.inventory_item_id%TYPE;  --NPD Conv.
    TYPE QtyTab                IS TABLE OF FM_MATL_DTL.qty%TYPE;
    TYPE ItemUmTab             IS TABLE OF FM_MATL_DTL.detail_uom%TYPE;  --NPD Conv.
    TYPE ScaleTypeTab          IS TABLE OF FM_MATL_DTL.scale_type%TYPE;
    TYPE ContributeYieldIndTab IS TABLE OF FM_MATL_DTL.contribute_yield_ind%TYPE;
    TYPE ScaleMultipleTab      IS TABLE OF FM_MATL_DTL.scale_multiple%TYPE;
    TYPE ScaleRoundingTab      IS TABLE OF FM_MATL_DTL.scale_rounding_variance%TYPE;
    TYPE RoundingDirectionTab  IS TABLE OF FM_MATL_DTL.rounding_direction%TYPE;
    l_line_no                  LineNoTab;
    l_line_type                LineTypeTab;
    l_inventory_item_id        ItemIdTab;  --NPD Conv.
    l_qty                      QtyTab;
    l_detail_uom               ItemUmTab;  --NPD Conv.
    l_scale_type               ScaleTypeTab;
    l_contribute_yield_ind     ContributeYieldIndTab;
    l_scale_multiple           ScaleMultipleTab;
    l_scale_rounding_variance  ScaleRoundingTab;
    l_rounding_direction       RoundingDirectionTab;

  -- NPD Conv.
  l_orgn_id  NUMBER;

  CURSOR get_formula_owner_orgn_id(vformula_id NUMBER) IS
    SELECT owner_organization_id
    FROM fm_form_mst
    WHERE formula_id = vformula_id;

  BEGIN

    x_error_msg       := '';
    x_return_code     := FND_API.G_RET_STS_SUCCESS;

    OPEN Get_Materials;

    FETCH Get_Materials
     BULK COLLECT INTO
      l_line_no,
      l_line_type,
      l_inventory_item_id,  -- NPD Conv.
      l_qty,
      l_detail_uom,  -- NPD Conv.
      l_scale_type,
      l_contribute_yield_ind,
      l_scale_multiple,
      l_scale_rounding_variance,
      l_rounding_direction;

    CLOSE Get_Materials;

    IF l_line_no.COUNT > 0 THEN

      FOR i IN 1..l_line_no.COUNT LOOP

        l_scale_tab(i).line_no                := l_line_no(i);
        l_scale_tab(i).line_type              := l_line_type(i);
        l_scale_tab(i).inventory_item_id      := l_inventory_item_id(i);  -- NPD Conv.
        l_scale_tab(i).qty                    := l_qty(i);
        l_scale_tab(i).detail_uom             := l_detail_uom(i);  -- NPD Conv.
        l_scale_tab(i).scale_type             := l_scale_type(i);

        IF l_line_type(i) = -1 THEN
          l_scale_tab(i).contribute_yield_ind   := 'Y';

          IF (l_scale_type(i) > 1) THEN
	    l_scale_tab(i).scale_multiple          := l_scale_multiple(i);
	    l_scale_tab(i).scale_rounding_variance := l_scale_rounding_variance(i);
	    l_scale_tab(i).rounding_direction      := l_rounding_direction(i);
          END IF;
        ELSE
          l_scale_tab(i).contribute_yield_ind   := l_contribute_yield_ind(i);
        END IF;

      END LOOP;

      -- NPD Conv.
      OPEN get_formula_owner_orgn_id(p_formula_id);
      FETCH get_formula_owner_orgn_id INTO l_orgn_id;
      CLOSE get_formula_owner_orgn_id;

      GMD_COMMON_SCALE.Scale ( p_scale_tab     => l_scale_tab
                              ,p_orgn_id       => l_orgn_id  -- NPD Conv.
                              ,p_scale_factor  => p_scale_factor
  		              ,p_primaries     => p_primaries
                              ,x_scale_tab     => G_SCALE_REC
                              ,x_return_status => l_return_status);


      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE SCALE_EXCEPTION;
      END IF;
    END IF;

    EXCEPTION
      WHEN SCALE_EXCEPTION THEN
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
        x_error_msg   := gmd_api_grp.get_message;

  END Scale_Formula;


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
 |     23-JUN-2004 Sriram.S  Bug# 3702561
 |                 Added validation to check for ingredient with zero qty.
 |     29-SEP-2004 Sriram.S  Bug# 3761032
 |                 Added check for expr. items if formula status in (600,700).
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Validate_Formula_Details ( p_formula_id    IN  VARCHAR2,
                                       x_return_code   OUT NOCOPY VARCHAR2,
                                       x_error_msg     OUT NOCOPY VARCHAR2) IS
    CURSOR check_num_details(p_line_type NUMBER) IS
      SELECT 1
      FROM fm_matl_dtl
      WHERE formula_id = p_formula_id AND
            line_type  = p_line_type;

    -- Sriram.S  Bug# 3702561
    -- Added the below cursor to check for ingredients with zero qty.
    CURSOR check_for_zero_qty (l_line_type NUMBER) IS
      SELECT 1
      FROM fm_matl_dtl
      WHERE formula_id = p_formula_id AND
            qty        = 0 AND
            line_type  = l_line_type;

    l_orgn_id            NUMBER;
    l_return_status      VARCHAR2(10);
    l_msg_count          NUMBER;
    l_msg_index          NUMBER;
    l_msg_data           VARCHAR2(240);
    l_count              NUMBER;
    l_product_qty        NUMBER;
    l_ing_qty            NUMBER;
    l_uom                VARCHAR2(3);


    CURSOR get_orgn_id (l_formula_id NUMBER) IS
       SELECT owner_organization_id
       FROM  fm_form_mst_b
       WHERE formula_id = l_formula_id;

  BEGIN

    x_error_msg   := '';
    x_return_code := 'S';

    -- Check product
    OPEN check_num_details(1);
    FETCH check_num_details INTO l_count;
    IF check_num_details%NOTFOUND THEN
      FND_MESSAGE.SET_NAME('GMD', 'GMD_MUST_HAVE_PRODUCT');
      x_return_code := 'F';
    END IF;
    CLOSE check_num_details;

    IF x_return_code = 'S' THEN
      -- Check ingredient
      OPEN check_num_details(-1);
      FETCH check_num_details INTO l_count;
      IF check_num_details%NOTFOUND THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_MUST_HAVE_INGREDIENT');
        x_return_code := 'F';
      -- Sriram.S   Bug# 3702561  Check for ingr. with zero qty. based on profile.
      ELSIF (FND_PROFILE.VALUE('FM$ALLOW_ZERO_INGR_QTY')=0) THEN
        OPEN check_for_zero_qty(-1);
        FETCH check_for_zero_qty INTO l_count;
        IF check_for_zero_qty%FOUND THEN
           FND_MESSAGE.SET_NAME('GMD','GMD_ZERO_QTY');
           x_return_code := 'F';
        END IF;
        CLOSE check_for_zero_qty;
      END IF;
      CLOSE check_num_details;
    END IF;

       --Check for formula orgn - item list match
    IF x_return_code = 'S' THEN
       OPEN get_orgn_id(p_formula_id);
       FETCH get_orgn_id INTO l_orgn_id;
       CLOSE get_orgn_id;

       GMD_API_GRP.Check_Item_Exists(	p_formula_id          	=> p_formula_id,
                                      	x_return_status       	=> l_return_status,
                                      	p_organization_id   	=> l_orgn_id);

       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
       	 x_return_code := 'F';
       END IF;
    END IF;

    GMD_COMMON_VAL.calculate_total_qty(
                  formula_id       => p_formula_id,
                  x_product_qty    => l_product_qty ,
                  x_ingredient_qty => l_ing_qty ,
                  x_uom            => l_uom ,
                  x_return_status  => l_return_status ,
                  x_msg_count      => l_count ,
                  x_msg_data       => x_error_msg);
    IF l_return_status = 'Q' THEN
      X_return_code := 'W';
    END IF;

    IF x_return_code <> 'S' THEN
      x_error_msg   := gmd_api_grp.get_message;
    END IF;

    --Bug 3336945
    --Function to validate the total cost of Formula
    IF x_return_code = 'S' THEN
      Validate_Cost_Allocation(p_formula_id       => p_formula_id,
                               p_formulaline_id   => -1,
                               p_cost_alloc       => 0,
                               x_return_code      => x_return_code,
                               x_error_msg        => x_error_msg);
    END IF;

  EXCEPTION
     WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := gmd_api_grp.get_message;

  END Validate_Formula_Details;

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
                             x_error_msg     OUT NOCOPY VARCHAR2) IS
  BEGIN

    x_return_code := 'S';
    x_error_msg   := '';

    SAVEPOINT Start_Transaction;

    EXCEPTION
     WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := gmd_api_grp.get_message;

  END Set_Save_Point;

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
                                  x_error_msg     OUT NOCOPY VARCHAR2) IS
  BEGIN

    x_return_code := 'S';
    x_error_msg   := '';

    ROLLBACK TO Start_Transaction;

    EXCEPTION
     WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := gmd_api_grp.get_message;

  END Rollback_Save_Point;

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

  PROCEDURE check_usr_has_fsec_resp (x_return_code   OUT NOCOPY VARCHAR2,
                                   x_error_msg     OUT NOCOPY VARCHAR2) IS

  -- Cursor to check if user has formula security responsibility.
  CURSOR check_fsec_resp IS
       SELECT 1
       FROM FND_USER_RESP_GROUPS rg ,
            FND_RESPONSIBILITY   rs
       WHERE rg.user_id = fnd_global.user_id
       AND rg.responsibility_id  = rs.responsibility_id
       AND rs.responsibility_key = 'GMD_PD_SECURITY_MGR'
       AND SYSDATE BETWEEN rg.start_date  AND NVL(rg.end_date, SYSDATE)
       AND SYSDATE BETWEEN rs.start_date  AND NVL(rs.end_date, SYSDATE);

  l_count       NUMBER;

  BEGIN
        x_return_code := 'N';
        x_error_msg   := '';

        OPEN check_fsec_resp;
        FETCH check_fsec_resp INTO l_count;
        IF check_fsec_resp%FOUND THEN
           x_return_code := 'Y';
        END IF;
        CLOSE check_fsec_resp;

   EXCEPTION
        WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'N';
        x_error_msg   := gmd_api_grp.get_message;

  END check_usr_has_fsec_resp;

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
                                x_return_code        OUT NOCOPY VARCHAR2) IS

   CURSOR Cur_get_orgn IS
        SELECT owner_organization_id
        FROM   fm_form_mst_b
        WHERE  formula_id = p_formula_id;
--KSHUKLA changed the l_orgn_id data type from NUMBER(4) to Number
    l_orgn_id       NUMBER;

  BEGIN
    OPEN Cur_get_orgn;
    FETCH Cur_get_orgn INTO l_orgn_id;
    CLOSE Cur_get_orgn;

    IF (l_orgn_id IS NOT NULL) THEN
      IF (GMD_API_GRP.setup AND GMD_API_GRP.OrgnAccessible(l_orgn_id) ) THEN
        x_return_code := 'S';
      ELSE
        x_return_code := 'F';
      END IF;
    ELSE
      x_return_code := 'S';
    END IF;
  END Check_fm_orgn_access;

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
                               x_error_msg       OUT NOCOPY VARCHAR2) IS
    ITEM_REV_EXCEPTION    EXCEPTION;

    CURSOR Cur_check_revision IS
      SELECT 1
      FROM   sys.dual
      WHERE EXISTS (SELECT 1
                    FROM mtl_item_revisions
                    WHERE organization_id = p_organization_id
                    AND inventory_item_id = p_item_id
                    AND revision = p_item_revision);
    l_exists BINARY_INTEGER;

  BEGIN
    x_return_code := 'S';
    x_error_msg   := '';

    -- Validate Item Revision
    OPEN Cur_check_revision;
    FETCH Cur_check_revision INTO l_exists;
    IF Cur_check_revision%NOTFOUND THEN
      CLOSE Cur_check_revision;
      RAISE ITEM_REV_EXCEPTION;
    END IF;
    CLOSE Cur_check_revision;
  EXCEPTION
     WHEN ITEM_REV_EXCEPTION THEN
        FND_MESSAGE.SET_NAME('INV','INV_INT_REVEXP');
        x_return_code := 'F';
        x_error_msg   := gmd_api_grp.get_message;
    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        x_return_code := 'F';
        x_error_msg   := gmd_api_grp.get_message;
  END Validate_Item_Revision;


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
 |     14-JUN-2006 Kapil M         Bug# 5240756 Get the top message from the stack
 |
 +=============================================================================
 Api end of comments
*/
  PROCEDURE Check_Item_Exists (p_formula_id 		IN NUMBER,
                               p_organization_id 	IN NUMBER,
                               x_return_status 		OUT NOCOPY VARCHAR2,
                               x_error_msg              OUT NOCOPY VARCHAR2) IS
    l_msg_txt VARCHAR2(2000);
    l_msg_index PLS_INTEGER;
  BEGIN
    GMD_API_GRP.check_item_exists (p_formula_id => p_formula_id
                                  ,x_return_status => x_return_status
                                  ,p_organization_id => p_organization_id);
    IF x_return_status <> FND_API.g_ret_sts_success THEN
      FND_MSG_PUB.Get(p_msg_index => FND_MSG_PUB.count_msg,
                      p_data => X_error_msg,
                      p_encoded => FND_API.G_FALSE,
                      p_msg_index_out => l_msg_index);
    END IF;
  END Check_Item_Exists;

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
                                    x_error_msg         OUT NOCOPY VARCHAR2,
				    pRevision           IN VARCHAR2 DEFAULT NULL) IS
    l_msg_index PLS_INTEGER;
    BEGIN

        GMD_COMMON_VAL.CHECK_FORMULA_ITEM_ACCESS (pFormula_Id => pFormula_Id
                                                  ,pInventory_Item_ID => pInventory_Item_ID
                                                  ,x_return_status =>  x_return_status
                                                  ,pRevision => pRevision );
        IF x_return_status <> FND_API.g_ret_sts_success THEN
                FND_MSG_PUB.Get(p_msg_index => FND_MSG_PUB.count_msg,
                                p_data => X_error_msg,
                                p_encoded => FND_API.G_FALSE,
                                p_msg_index_out => l_msg_index);
        END IF;

    END CHECK_FORMULA_ITEM_ACCESS;

      -- Kapil ME Auto-prod :Bug# 5716318
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
 |     05-FEB-2007 Kapil M         Bug# 5716318 Created.
 |
 +=============================================================================
 Api end of comments
*/
PROCEDURE CHECK_AUTO_PRODUCT ( pOrgn_id IN NUMBER,
                              pAuto_calc OUT NOCOPY VARCHAR2,
                              x_return_status     OUT NOCOPY VARCHAR2,
                              x_error_msg         OUT NOCOPY VARCHAR2) IS

    BEGIN
        IF pOrgn_id IS NOT NULL THEN
              GMD_API_GRP.FETCH_PARM_VALUES (	P_orgn_id       => pOrgn_id,
		                              			P_parm_name     => 'GMD_AUTO_PROD_CALC'	,
                               					P_parm_value    => pAuto_calc		,
                            					X_return_status => x_return_status	);
        END IF ;
    END CHECK_AUTO_PRODUCT;

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
 |     05-FEB-2007 Kapil M         Bug# 5716318 Created.
 |
 +=============================================================================
 Api end of comments
*/

PROCEDURE CALCULATE_TOTAL_PRODUCT_QTY(  pFormula_id IN NUMBER,
                                        x_return_status     OUT NOCOPY VARCHAR2,
                                        x_msg_count         OUT NOCOPY NUMBER,
                                        x_msg_data          OUT NOCOPY VARCHAR2) IS

    BEGIN
        IF pFormula_id IS NOT NULL THEN
            GMD_COMMON_VAL.Calculate_Total_Product_Qty( p_formula_id    =>  pFormula_id,
                                x_return_status => x_return_status,
                                x_msg_count     =>  x_msg_count,
                                x_msg_data       =>  x_msg_data);
        END IF;
    END CALCULATE_TOTAL_PRODUCT_QTY;


END GMD_FORMULA_DESIGNER_PKG;

/
