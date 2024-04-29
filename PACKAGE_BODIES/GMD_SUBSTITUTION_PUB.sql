--------------------------------------------------------
--  DDL for Package Body GMD_SUBSTITUTION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_SUBSTITUTION_PUB" AS
/* $Header: GMDPSUBB.pls 120.0.12000000.1 2007/01/31 16:16:43 appldev noship $ */

  -- Common cursors used
  CURSOR get_substitution_id(vSubstitution_name    VARCHAR2
                            ,vSubstitution_version NUMBER) IS
    SELECT substitution_id
    FROM   gmd_item_substitution_hdr_b
    WHERE  substitution_name    = vSubstitution_name
    AND    substitution_version = vSubstitution_version;

  CURSOR validate_formula_item(vFormula_id      NUMBER,
                               vOriginal_item_id NUMBER) IS
    SELECT 1
    FROM   fm_matl_dtl
    WHERE  formula_id = vformula_id
    AND    inventory_item_id    = vOriginal_item_id
    AND    line_type  = -1
    AND    rownum = 1;

  CURSOR validate_formula(vFormula_id NUMBER) IS
    SELECT 1
    FROM   fm_form_mst_b
    WHERE  formula_id     = vformula_id
    AND    delete_mark    = 0
    AND    formula_status <> 1000;

  CURSOR get_formula_no_vers(vFormula_id NUMBER) IS
    SELECT  formula_no, Formula_vers
    FRom    fm_form_mst_b
    WHERE   FORMULA_id = vFormula_id;

  Cursor get_item_info(vItem_id NUMBER) IS
    SELECT concatenated_segments, primary_uom_code
    FROM   mtl_system_items_kfv
    WHERE  inventory_item_id = vItem_id;


  /* =============================================================== */
  /* Procedure:                                                      */
  /*   is_update_allowed                                             */
  /*                                                                 */
  /* DESCRIPTION: Private function                                   */
  /*                                                                 */
  /*                                                                 */
  /* History :                                                       */
  /* Raju   09-OCT-06   Initial implementation                      */
  /* =============================================================== */

  FUNCTION is_update_allowed(p_substitution_id  IN NUMBER)
  RETURN BOOLEAN IS
    CURSOR get_subs_info(vSubstitution_id NUMBER) IS
      SELECT  substitution_status
      FROM    gmd_item_substitution_hdr_b
      WHERE   substitution_id = p_substitution_id;

    l_status_code       GMD_STATUS.Status_Code%TYPE;
    l_delete_mark       NUMBER  := 0;
  BEGIN
    OPEN  get_subs_info(p_substitution_id);
    FETCH get_subs_info INTO l_status_code;
    CLOSE get_subs_info;

    IF ((l_status_code between 200 and 299) OR
        (l_status_code >= 800) OR
        (l_status_code between 500 and 599)) THEN
      FND_MESSAGE.SET_NAME('GMD','GMD_SUBS_CANNOT_UPD');
      FND_MSG_PUB.ADD;
      Return FALSE;
    END IF;

    Return TRUE;
  END is_update_allowed;


  /* =============================================================== */
  /* Procedure:                                                      */
  /*   Create_substitution                                           */
  /*                                                                 */
  /* DESCRIPTION:                                                    */
  /*                                                                 */
  /*                                                                 */
  /* History :                                                       */
  /* Raju   09-OCT-06   Initial implementation                      */
  /*                                                                 */
  /* Description                                                     */
  /* Creates substitution header, details and formulas associated    */
  /* to the item substitution                                        */
  /*                                                                 */
  /* =============================================================== */
  PROCEDURE Create_substitution
  (
    p_api_version               IN  NUMBER
  , p_init_msg_list             IN  VARCHAR2
  , p_commit                    IN  VARCHAR2
  , p_substitution_hdr_rec      IN  gmd_substitution_hdr_rec_type
  , p_substitution_dtl_rec      IN  gmd_substitution_dtl_rec_type
  , p_formula_substitution_tbl  IN  gmd_formula_substitution_tab
  , x_message_count             OUT NOCOPY  NUMBER
  , x_message_list              OUT NOCOPY  VARCHAR2
  , x_return_status             OUT NOCOPY  VARCHAR2
  ) IS

    Cursor get_item_info1(vItem_id NUMBER) IS
      SELECT inventory_item_id, primary_uom_code
      FROM   mtl_system_items_kfv
      WHERE  inventory_item_id = vItem_id;

    Cursor get_item_info2(vItem_no VARCHAR2) IS
      SELECT inventory_item_id, primary_uom_code
      FROM   mtl_system_items_kfv
      WHERE  concatenated_segments = vItem_no;

    Cursor get_item_orgn(vOrgn_id NUMBER) IS
      SELECT organization_code
      FROM   org_organization_definitions
      WHERE  organization_id = vOrgn_id;

    CURSOR check_for_date_overlap(vSubstitution_id   NUMBER
                                 ,vOriginal_item_id  NUMBER
                                 ,vPreference        NUMBER
                                 ,vStart_date        DATE
                                 ,vEnd_date          DATE) IS
      SELECT 1
      FROM  gmd_item_substitution_hdr_b
      WHERE substitution_id            <> vSubstitution_id
      AND   original_inventory_item_id = vOriginal_item_id
      AND   preference                 = vPreference
      AND   vStart_date                >= start_date
      AND   substitution_status        < 1000
      AND   (end_date IS NULL OR vEnd_date <= end_date);

    CURSOR Cur_check_item(v_organization_id IN NUMBER DEFAULT NULL,
                          v_inventory_item_id IN NUMBER DEFAULT NULL) IS
      SELECT INVENTORY_ITEM_ID
      FROM   mtl_system_items_b
      WHERE  inventory_item_id = v_inventory_item_id
      AND    organization_id = v_organization_id
      AND    recipe_enabled_flag = 'Y';

    -- local variables
    l_item_id                       NUMBER;
    l_original_prim_item_um         VARCHAR2(3);
    l_substitute_prim_item_um       VARCHAR2(3);
    l_dummy                         NUMBER := 0;
    l_ret			    NUMBER := NULL;
    l_organization_code		    VARCHAR2(3);
    l_api_name             CONSTANT VARCHAR2(30) := 'Create_substitution';

    l_substitution_id               NUMBER;
    l_substitution_line_id          NUMBER;
    l_formula_substitution_id       NUMBER;

    -- get a record type
    l_substitution_hdr_rec          gmd_substitution_hdr_rec_type;
    l_substitution_dtl_rec          gmd_substitution_dtl_rec_type;
    l_formula_substitution_rec      gmd_fmsubstitution_rec_type;
    l_formula_substitution_tbl      gmd_formula_substitution_tab;

    -- Exception declaration
    substitution_creation_failure   EXCEPTION;
    invalid_version                 EXCEPTION;
    setup_failure                   EXCEPTION;
  BEGIN
    SAVEPOINT substitution_api;

    -- Set the return status to success initially
    x_return_status        := FND_API.G_RET_STS_SUCCESS;
    -- Assigning local record types for manipulation of data values
    l_substitution_hdr_rec := p_substitution_hdr_rec;
    l_substitution_dtl_rec := p_substitution_dtl_rec;

    /* Initialize message list and count if needed */
    IF (p_init_msg_list = FND_API.g_true) THEN
      fnd_msg_pub.initialize;
    END IF;

    /* Intialize the setup fields */
    IF NOT gmd_api_grp.setup_done THEN
      gmd_api_grp.setup_done := gmd_api_grp.setup;
    END IF;
    IF NOT gmd_api_grp.setup_done THEN
      RAISE setup_failure;
    END IF;

    /* Make sure we are call compatible */
    IF NOT FND_API.compatible_api_call ( 1.0
                                        ,p_api_version
                                        ,'Create_substitution'
                                        ,gmd_substitution_pub.m_pkg_name) THEN
      RAISE invalid_version;
    END IF;

    /* Required fields at header level */
    -- substitution_name and Substitution_version
    IF l_substitution_hdr_rec.substitution_name IS NULL THEN
      FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
      FND_MESSAGE.SET_TOKEN ('MISSING', 'SUBSTITUTION_NAME');
      FND_MSG_PUB.ADD;
      RAISE substitution_creation_failure;
    END IF;

    IF l_substitution_hdr_rec.substitution_version IS NULL THEN
      FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
      FND_MESSAGE.SET_TOKEN ('MISSING', 'SUBSTITUTION_VERSION');
      FND_MSG_PUB.ADD;
      RAISE substitution_creation_failure;
    ELSIF (l_substitution_hdr_rec.substitution_version < 0 ) THEN
      FND_MESSAGE.SET_NAME ('GMD', 'GMD_NEGATIVE_FIELDS');
      FND_MESSAGE.SET_TOKEN ('FIELD', 'SUBSTITUTION_VERSION');
      FND_MSG_PUB.ADD;
      RAISE substitution_creation_failure;
    END IF;

    -- get the substitution_id from sequence
    select  gmd_item_substitution_hdr_s.nextval
      into  l_substitution_id
     from   dual;

    -- substitution_description
    IF l_substitution_hdr_rec.substitution_description IS NULL THEN
      FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
      FND_MESSAGE.SET_TOKEN ('MISSING', 'SUBSTITUTION_DESCRIPTION');
      FND_MSG_PUB.ADD;
      RAISE substitution_creation_failure;
    END IF;

    -- original_item_id
    IF ((l_substitution_hdr_rec.original_inventory_item_id IS NULL) AND
        (l_substitution_hdr_rec.original_item_no IS NULL)) THEN
      FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
      FND_MESSAGE.SET_TOKEN ('MISSING', 'ORIGINAL_ITEM_ID');
      FND_MSG_PUB.ADD;
      RAISE substitution_creation_failure;
    ELSIF (l_substitution_hdr_rec.original_inventory_item_id IS NULL) THEN
      OPEN get_item_info2(l_substitution_hdr_rec.original_item_no);
      FETCH get_item_info2
      INTO l_substitution_hdr_rec.original_inventory_item_id,
           l_original_prim_item_um;
      CLOSE get_item_info2;
    ELSIF (l_substitution_hdr_rec.original_item_no IS NULL) THEN
      OPEN get_item_info1(l_substitution_hdr_rec.original_inventory_item_id);
      FETCH get_item_info1
      INTO l_substitution_hdr_rec.original_item_no,
           l_original_prim_item_um;
      CLOSE get_item_info1;
    END IF;
    IF (l_original_prim_item_um IS NULL) THEN
      FND_MESSAGE.SET_NAME ('GMD', 'GMD_INVALID_ORIGINAL_ITEM');
      FND_MESSAGE.SET_TOKEN('ORIGINAL_ITEM_NO', l_substitution_hdr_rec.original_item_no);
      FND_MSG_PUB.ADD;
      RAISE substitution_creation_failure;
    END IF;

    -- original_qty
    IF l_substitution_hdr_rec.original_qty IS NULL THEN
      FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
      FND_MESSAGE.SET_TOKEN ('MISSING', 'ORIGINAL_QTY');
      FND_MSG_PUB.ADD;
      RAISE substitution_creation_failure;
    ELSIF (l_substitution_hdr_rec.original_qty < 0 ) THEN
      FND_MESSAGE.SET_NAME ('GMD', 'GMD_NEGATIVE_FIELDS');
      FND_MESSAGE.SET_TOKEN ('FIELD', 'ORIGINAL_QTY');
      FND_MSG_PUB.ADD;
      RAISE substitution_creation_failure;
    END IF;

    -- preference
    IF l_substitution_hdr_rec.preference IS NULL THEN
      FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
      FND_MESSAGE.SET_TOKEN ('MISSING', 'PREFERENCE');
      FND_MSG_PUB.ADD;
      RAISE substitution_creation_failure;
    ELSIF (l_substitution_hdr_rec.preference < 0 ) THEN
      FND_MESSAGE.SET_NAME ('GMD', 'GMD_NEGATIVE_FIELDS');
      FND_MESSAGE.SET_TOKEN ('FIELD', 'PREFERENCE');
      FND_MSG_PUB.ADD;
      RAISE substitution_creation_failure;
    END IF;

    -- replacement_uom_type -- Default it to value = 1 (original Item uom)
    IF l_substitution_hdr_rec.replacement_uom_type IS NULL THEN
      l_substitution_hdr_rec.replacement_uom_type := 1;
    ELSIF (l_substitution_hdr_rec.replacement_uom_type < 0) THEN
      FND_MESSAGE.SET_NAME ('GMD', 'GMD_NEGATIVE_FIELDS');
      FND_MESSAGE.SET_TOKEN ('FIELD', 'REPLACEMENT_UOM_TYPE');
      FND_MSG_PUB.ADD;
      RAISE substitution_creation_failure;
    ELSIF (l_substitution_hdr_rec.replacement_uom_type > 2) THEN
      FND_MESSAGE.SET_NAME ('GMD', 'GMD_INV_REPLACEMENT_TYPE');
      FND_MSG_PUB.ADD;
      RAISE substitution_creation_failure;
    END IF;

    --Check that organization id is not null if raise an error message
    IF (l_substitution_hdr_rec.owner_organization_id IS NULL) THEN
      FND_MESSAGE.SET_NAME('GMD', 'GMD_MISSING_ORGANIZATION_ID');
      FND_MSG_PUB.Add;
      RAISE substitution_creation_failure;
    ELSE
      --Check the organization id passed is process enabled if not raise an error message
      IF NOT (gmd_api_grp.check_orgn_status(l_substitution_hdr_rec.owner_organization_id)) THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_INVALID_ORGANIZATION_ID');
        FND_MESSAGE.SET_TOKEN('ORGN_ID', l_substitution_hdr_rec.owner_organization_id);
        FND_MSG_PUB.Add;
        RAISE substitution_creation_failure;
      END IF;
      OPEN get_item_orgn(l_substitution_hdr_rec.owner_organization_id);
      FETCH get_item_orgn INTO l_organization_code;
      CLOSE get_item_orgn;
    END IF;

    -- Set the standard who columns
    l_substitution_hdr_rec.creation_date      := sysdate;
    l_substitution_hdr_rec.created_by         := gmd_api_grp.user_id;
    l_substitution_hdr_rec.last_update_date   := sysdate;
    l_substitution_hdr_rec.last_updated_by    := gmd_api_grp.user_id;
    l_substitution_hdr_rec.last_update_login  := gmd_api_grp.login_id;

    /* Business Rules at header level */
    -- Validation 1
    -- Check if the substitution exists
    -- substitution_name and Substitution_version should be unique
    OPEN  get_substitution_id (l_substitution_hdr_rec.substitution_name
                              ,l_substitution_hdr_rec.substitution_version);
    FETCH get_substitution_id INTO l_dummy;
    CLOSE get_substitution_id;

    IF (l_dummy > 0) THEN
      FND_MESSAGE.SET_NAME('GMD', 'GMD_ITSUB_UNIQUE_SUBS_VER');
      FND_MESSAGE.SET_TOKEN('SUBSNAM',l_substitution_hdr_rec.substitution_name);
      FND_MESSAGE.SET_TOKEN('VERNAME',l_substitution_hdr_rec.substitution_version);
      FND_MSG_PUB.ADD;
      RAISE substitution_creation_failure;
    END IF;

    -- Validation 2
    -- Combination of item, date range and preference would be considered for
    -- uniquess of a list.
    OPEN  check_for_date_overlap( l_substitution_id
                                 ,l_substitution_hdr_rec.Original_inventory_item_id
                                 ,l_substitution_hdr_rec.Preference
                                 ,l_substitution_hdr_rec.Start_date
                                 ,l_substitution_hdr_rec.End_date);
    FETCH check_for_date_overlap INTO l_dummy;
    CLOSE check_for_date_overlap;

    IF (l_dummy > 0) THEN
      FND_MESSAGE.SET_NAME('GMD','GMD_ITSUB_DATE_PRE_OVERLAP');
      FND_MSG_PUB.ADD;
      RAISE substitution_creation_failure;
    END IF;

    -- Validation 3
    -- Start date should be less than End date
    IF l_substitution_hdr_rec.end_date IS NOT NULL  THEN
      /* End date must be greater than start date, otherwise give error */
      IF l_substitution_hdr_rec.end_date < l_substitution_hdr_rec.start_date THEN
        FND_MESSAGE.SET_NAME('GMD', 'QC_MIN_MAX_DATE');
        FND_MSG_PUB.ADD;
        RAISE substitution_creation_failure;
      END IF;
    END IF;

    -- Validation 4
    -- Check the Organization Access to the responsibility
    IF NOT (GMD_API_GRP.orgnaccessible (l_substitution_hdr_rec.owner_organization_id)) THEN
      RAISE substitution_creation_failure;
    END IF;

    --Validation 5
    -- Check that organization has the access to item passed in the header.
    OPEN Cur_check_item(l_substitution_hdr_rec.owner_organization_id,
    			l_substitution_hdr_rec.Original_inventory_item_id);
    FETCH Cur_check_item INTO l_ret;
    IF L_RET IS NULL THEN
      FND_MESSAGE.SET_NAME('GMD', 'GMD_ITEM_ORG_NOT_FOUND');
      FND_MESSAGE.SET_TOKEN('ORGN',l_organization_code);
      FND_MESSAGE.SET_TOKEN('ITEM',l_substitution_hdr_rec.original_item_no);
      FND_MSG_PUB.ADD;
      CLOSE cur_check_item;
      RAISE substitution_creation_failure;
    END IF;
    CLOSE cur_check_item;

    -- Call the item substitution header Pvt API
    GMD_SUBSTITUTION_PVT.Create_substitution_header
    ( p_substitution_id      => l_substitution_id
    , p_substitution_hdr_rec => l_substitution_hdr_rec
    , x_message_count        => x_message_count
    , x_message_list         => x_message_list
    , x_return_status        => x_return_status
    );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE substitution_creation_failure;
    END IF;

    /* Required fields at detail level */
    -- set the primary key
    select  gmd_item_substitution_dtl_s.nextval
      into  l_substitution_line_id
      from  dual;

    -- substitute item_id
    IF ((l_substitution_dtl_rec.inventory_item_id IS NULL) AND
        (l_substitution_dtl_rec.item_no IS NULL)) THEN
      FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
      FND_MESSAGE.SET_TOKEN ('MISSING', 'SUBSTITUTE_ITEM_ID');
      FND_MSG_PUB.ADD;
      RAISE substitution_creation_failure;
    ELSIF (l_substitution_dtl_rec.inventory_item_id IS NULL) THEN
      OPEN get_item_info2(l_substitution_dtl_rec.item_no);
      FETCH get_item_info2
      INTO l_substitution_dtl_rec.inventory_item_id,
           l_substitute_prim_item_um;
      CLOSE get_item_info2;
    ELSIF (l_substitution_dtl_rec.item_no IS NULL) THEN
      OPEN get_item_info1(l_substitution_dtl_rec.inventory_item_id);
      FETCH get_item_info1
      INTO l_substitution_dtl_rec.item_no,
           l_substitute_prim_item_um;
      CLOSE get_item_info1;
    END IF;

    IF (l_substitute_prim_item_um IS NULL) THEN
      FND_MESSAGE.SET_NAME ('GMD', 'GMD_INVALID_SUBSTITUTE_ITEM');
      FND_MESSAGE.SET_TOKEN('SUBSTITUTE_ITEM_NO',l_substitution_dtl_rec.item_no);
      FND_MSG_PUB.ADD;
      RAISE substitution_creation_failure;
    END IF;

    -- unit_qty
    IF l_substitution_dtl_rec.unit_qty IS NULL THEN
      FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
      FND_MESSAGE.SET_TOKEN ('MISSING', 'UNIT_QTY');
      FND_MSG_PUB.ADD;
      RAISE substitution_creation_failure;
    ELSIF (l_substitution_dtl_rec.unit_qty < 0 ) THEN
      FND_MESSAGE.SET_NAME ('GMD', 'GMD_NEGATIVE_FIELDS');
      FND_MESSAGE.SET_TOKEN ('FIELD', 'UNIT_QTY');
      FND_MSG_PUB.ADD;
      RAISE substitution_creation_failure;
    END IF;

    -- item_uom
    IF l_substitution_dtl_rec.detail_uom IS NULL THEN
      l_substitution_dtl_rec.detail_uom := l_substitute_prim_item_um;
    ELSE
      IF (NOT(gma_valid_grp.validate_um(l_substitution_dtl_rec.detail_uom))) THEN
        FND_MESSAGE.SET_NAME('GMA', 'SY_INVALID_UM_CODE');
        FND_MSG_PUB.ADD;
        RAISE substitution_creation_failure;
      END IF;
    END IF;

    -- Set the standard who columns
    l_substitution_dtl_rec.creation_date      := sysdate;
    l_substitution_dtl_rec.created_by         := gmd_api_grp.user_id;
    l_substitution_dtl_rec.last_update_date   := sysdate;
    l_substitution_dtl_rec.last_updated_by    := gmd_api_grp.user_id;
    l_substitution_dtl_rec.last_update_login  := gmd_api_grp.login_id;

    /* Business Rules at Detail level */
    -- Validation 1

    -- Detail item uom validation
    l_dummy := INV_CONVERT.inv_um_convert (item_id        => l_substitution_dtl_rec.inventory_item_id
                                          ,precision      => 5
                                          ,from_quantity  => 100
                                          ,from_unit      => l_substitution_dtl_rec.detail_uom
                                          ,to_unit        => l_substitute_prim_item_um
                                          ,from_name      => NULL
                                          ,to_name        => NULL);
    IF l_dummy < 0 THEN
        FND_MESSAGE.SET_NAME('GMD','FM_SCALE_BAD_ITEM_UOM');
        FND_MESSAGE.SET_TOKEN('FROM_UOM', l_substitution_dtl_rec.detail_uom);
        FND_MESSAGE.SET_TOKEN('TO_UOM', l_substitute_prim_item_um);
        FND_MESSAGE.SET_TOKEN('ITEM_NO', l_substitution_dtl_rec.item_no);
        FND_MSG_PUB.ADD;
      RAISE substitution_creation_failure;
    END IF;

    IF (l_substitution_hdr_rec.replacement_uom_type = 2) THEN
      l_dummy :=
        INV_CONVERT.inv_um_convert (item_id        => l_substitution_dtl_rec.inventory_item_id
                                   ,precision      => 5
                                   ,from_quantity  => 100
                                   ,from_unit      => l_substitution_dtl_rec.detail_uom
                                   ,to_unit        => l_original_prim_item_um
                                   ,from_name      => NULL
                                   ,to_name        => NULL);
      IF l_dummy < 0 THEN
        FND_MESSAGE.SET_NAME('GMD','FM_SCALE_BAD_ITEM_UOM');
        FND_MESSAGE.SET_TOKEN('FROM_UOM', l_substitution_dtl_rec.detail_uom);
        FND_MESSAGE.SET_TOKEN('TO_UOM', l_original_prim_item_um);
        FND_MESSAGE.SET_TOKEN('ITEM_NO', l_substitution_dtl_rec.item_no);
        FND_MSG_PUB.ADD;
        RAISE substitution_creation_failure;
      END IF;
    END IF;
    -- reset l_dummy
    l_dummy := 0;

    -- Check that organization has the access to item passed in the detail.
    OPEN Cur_check_item(l_substitution_hdr_rec.owner_organization_id,
    			l_substitution_dtl_rec.inventory_item_id);
    FETCH Cur_check_item INTO l_ret;
    IF L_RET IS NULL THEN
      FND_MESSAGE.SET_NAME('GMD', 'GMD_ITEM_ORG_NOT_FOUND');
      FND_MESSAGE.SET_TOKEN('ORGN',l_organization_code);
      FND_MESSAGE.SET_TOKEN('ITEM',l_substitution_dtl_rec.item_no);
      FND_MSG_PUB.ADD;
      CLOSE cur_check_item;
      RAISE substitution_creation_failure;
    END IF;
    CLOSE cur_check_item;

    -- call the item substitution dtl pvt API
    GMD_SUBSTITUTION_PVT.Create_substitution_detail
    ( p_substitution_line_id => l_substitution_line_id
    , p_substitution_id      => l_substitution_id
    , p_substitution_dtl_rec => l_substitution_dtl_rec
    , x_message_count        => x_message_count
    , x_message_list         => x_message_list
    , x_return_status        => x_return_status
    );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE substitution_creation_failure;
    END IF;

    FOR i in 1 .. p_formula_substitution_tbl.count  LOOP
      -- each row to a local record for manipulation of data
      l_formula_substitution_rec := p_formula_substitution_tbl(i);

      -- formula_id or formula_no/formule_vers combination
      IF (l_formula_substitution_rec.formula_id IS NULL) AND
         (l_formula_substitution_rec.formula_no IS NULL OR
          l_formula_substitution_rec.formula_vers IS NULL) THEN
        FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
        FND_MESSAGE.SET_TOKEN ('MISSING', 'FORMULA_ID');
        FND_MSG_PUB.ADD;
        RAISE substitution_creation_failure;
      ELSIF (l_formula_substitution_rec.formula_id IS NULL) THEN
        -- Get the formula id
        GMDFMVAL_PUB.get_formula_id
                    (pformula_no  => l_formula_substitution_rec.formula_no
                    ,pversion     => l_formula_substitution_rec.formula_vers
                    ,xvalue       => l_formula_substitution_rec.formula_id
                    ,xreturn_code => l_dummy);
        IF (l_dummy < 0) THEN
          FND_MESSAGE.SET_NAME ('GMD', 'QC_INVALID_FORMULA');
          FND_MSG_PUB.ADD;
          RAISE substitution_creation_failure;
        END IF;
      ELSE
        -- get formula no and version
        OPEN get_formula_no_vers(l_formula_substitution_rec.formula_id);
        FETCH get_formula_no_vers INTO l_formula_substitution_rec.formula_no,
                                       l_formula_substitution_rec.formula_vers;
        CLOSE get_formula_no_vers;
      END IF;

      -- This formula should remain active (not deleted) and not obsoleted
      OPEN  validate_formula(l_formula_substitution_rec.formula_id);
      FETCH validate_formula INTO l_dummy;
      CLOSE validate_formula;

      IF (l_dummy <> 1) THEN
        FND_MESSAGE.SET_NAME ('GMD', 'GMD_INACTIVE_FMSUB');
        FND_MESSAGE.SET_TOKEN('FORMULA_VERSION',l_formula_substitution_rec.formula_vers);
        FND_MESSAGE.SET_TOKEN('FORMULA_NO',l_formula_substitution_rec.formula_no);
        FND_MSG_PUB.ADD;
        RAISE substitution_creation_failure;
      END IF;
      -- reset l_dummy
      l_dummy := 0;

      /* Business Rules at formula substitution association level */
      -- Validation 1
      -- There formula the substitution is associated to should have the
      -- original item as its ingredient.
      OPEN  validate_formula_item(l_formula_substitution_rec.formula_id
                                 ,l_substitution_hdr_rec.original_inventory_item_id);
      FETCH validate_formula_item INTO l_dummy;
      CLOSE validate_formula_item;

      IF (l_dummy <> 1) THEN
        FND_MESSAGE.SET_NAME ('GMD', 'GMD_FMSUB_INGR_MISSING');
        FND_MESSAGE.SET_TOKEN('FORMULA_VERSION',l_formula_substitution_rec.formula_vers);
        FND_MESSAGE.SET_TOKEN('FORMULA_NO',l_formula_substitution_rec.formula_no);
        FND_MSG_PUB.ADD;
        RAISE substitution_creation_failure;
      END IF;
      -- reset l_dummy
      l_dummy := 0;

      -- Set the standard who columns
      l_formula_substitution_rec.creation_date      := sysdate;
      l_formula_substitution_rec.created_by         := gmd_api_grp.user_id;
      l_formula_substitution_rec.last_update_date   := sysdate;
      l_formula_substitution_rec.last_updated_by    := gmd_api_grp.user_id;
      l_formula_substitution_rec.last_update_login  := gmd_api_grp.login_id;

      l_formula_substitution_tbl(i) := l_formula_substitution_rec;
    END LOOP;

    -- Call the insert formula subtitution association Pvt API
    GMD_SUBSTITUTION_PVT.Create_formula_association
    ( p_substitution_id          => l_substitution_id
    , p_formula_substitution_tbl => l_formula_substitution_tbl
    , x_message_count            => x_message_count
    , x_message_list             => x_message_list
    , x_return_status            => x_return_status
    );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE substitution_creation_failure;
    END IF;


    IF (p_commit = FND_API.g_true) THEN
      Commit;
    END IF;
  EXCEPTION
    WHEN substitution_creation_failure OR invalid_version OR setup_failure THEN
      x_return_status := FND_API.g_ret_sts_error;
      fnd_msg_pub.count_and_get (
         p_count => x_message_count
        ,p_encoded => FND_API.g_false
        ,p_data => x_message_list);
      ROLLBACK TO SAVEPOINT substitution_api;
    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      fnd_msg_pub.add_exc_msg (gmd_substitution_pub.m_pkg_name, l_api_name);
      fnd_msg_pub.count_and_get (
         p_count => x_message_count
        ,p_encoded => FND_API.g_false
        ,p_data => x_message_list);
      ROLLBACK TO SAVEPOINT substitution_api;
  END Create_substitution;

  /* =============================================================== */
  /* Procedure:                                                      */
  /*   Create_formula_association                                    */
  /*                                                                 */
  /* DESCRIPTION:                                                    */
  /*                                                                 */
  /*                                                                 */
  /* History :                                                       */
  /*  Rajender Nalla    09-OCT-06   Initial implementation.          */
  /* =============================================================== */
  PROCEDURE Create_formula_association
  ( p_api_version               IN  NUMBER
  , p_init_msg_list             IN  VARCHAR2
  , p_commit                    IN  VARCHAR2
  , p_substitution_id           IN  NUMBER    Default NULL
  , p_substitution_name         IN  VARCHAR2  Default NULL
  , p_substitution_version      IN  NUMBER    Default NULL
  , p_formula_substitution_tbl  IN  gmd_formula_substitution_tab
  , x_message_count             OUT NOCOPY  NUMBER
  , x_message_list              OUT NOCOPY  VARCHAR2
  , x_return_status             OUT NOCOPY  VARCHAR2
  ) IS
    -- Cursor definition
    CURSOR validate_formula_substitution(vSubstitution_id NUMBER
                                        ,vFormula_id      NUMBER) IS
      Select 1
      From   gmd_formula_substitution
      Where  formula_id      = vformula_id
      AND    substitution_id = vSubstitution_id;

    -- local variable
    l_dummy  NUMBER := 0;
    l_formula_substitution_rec     gmd_fmsubstitution_rec_type;
    l_api_name    CONSTANT VARCHAR2(30) := 'Create_formula_association';

    l_substitution_id              NUMBER;
    l_formula_substitution_tbl     gmd_formula_substitution_tab;

    -- Exception declaration
    substitution_creation_failure  EXCEPTION;
    invalid_version                EXCEPTION;
    setup_failure                  EXCEPTION;

    -- internal function
    FUNCTION get_original_item_id(vSubstitution_id NUMBER)
        RETURN NUMBER IS
      l_item_id NUMBER := 0;
    BEGIN
      SELECT original_inventory_item_id INTO l_item_id
      FROM   gmd_item_substitution_hdr_b
      Where  substitution_id = vSubstitution_id;

      RETURN l_item_id;
    END get_original_item_id;
  BEGIN
    SAVEPOINT substitution_api;

    /* Set the return status to success initially */
    x_return_status  := FND_API.G_RET_STS_SUCCESS;

    /* Initialize message list and count if needed */
    IF (p_init_msg_list = FND_API.G_True) THEN
       fnd_msg_pub.initialize;
    END IF;

    /* Intialize the setup fields */
    IF NOT gmd_api_grp.setup_done THEN
      gmd_api_grp.setup_done := gmd_api_grp.setup;
    END IF;
    IF NOT gmd_api_grp.setup_done THEN
      RAISE setup_failure;
    END IF;

    /* Make sure we are call compatible */
    IF NOT FND_API.compatible_api_call ( 1.0
                                        ,p_api_version
                                        ,'Create_formula_association'
                                        ,gmd_substitution_pub.m_pkg_name) THEN
      RAISE invalid_version;
    END IF;

    -- Substitution id or (substitution_name and Substitution_version)
    IF ((p_substitution_id IS NULL) AND
        (p_substitution_name IS NULL OR
         p_substitution_version IS NULL)) THEN
      FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
      FND_MESSAGE.SET_TOKEN ('MISSING', 'SUBSTITUTION_ID');
      FND_MSG_PUB.ADD;
      RAISE substitution_creation_failure;
    ELSIF (p_substitution_id IS NULL) THEN
      -- Get the subsitution id
      OPEN get_substitution_id(p_substitution_name
                              ,p_substitution_version);
      FETCH get_substitution_id INTO l_substitution_id;
      IF (get_substitution_id%NOTFOUND) THEN
        CLOSE get_substitution_id;
        FND_MESSAGE.SET_NAME ('GMD', 'GMD_INVALID_SUBSTITUTION');
        FND_MSG_PUB.ADD;
        RAISE substitution_creation_failure;
      END IF;
      CLOSE get_substitution_id;
    ELSE
      l_substitution_id := p_substitution_id;
    END IF;

    -- prevent updates or modification of pending obsolete status
    IF NOT is_update_allowed(l_substitution_id) THEN
      RAISE substitution_creation_failure;
    END IF;

    FOR i in 1 .. p_formula_substitution_tbl.count   LOOP
      -- Assign each table row to temp local record
      l_formula_substitution_rec  := p_formula_substitution_tbl(i);

      -- formula_id or (formula_no and formula_version combination
      IF ((l_formula_substitution_rec.formula_id IS NULL) AND
          (l_formula_substitution_rec.formula_no IS NULL OR
           l_formula_substitution_rec.formula_vers IS NULL)) THEN
        FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
        FND_MESSAGE.SET_TOKEN ('MISSING', 'FORMULA_ID');
        FND_MSG_PUB.ADD;
        RAISE substitution_creation_failure;
      ELSIF (l_formula_substitution_rec.formula_id IS NULL) THEN
        -- Get the formula id
        GMDFMVAL_PUB.get_formula_id
                    (pformula_no  => l_formula_substitution_rec.formula_no
                    ,pversion     => l_formula_substitution_rec.formula_vers
                    ,xvalue       => l_formula_substitution_rec.formula_id
                    ,xreturn_code => l_dummy);
        IF (l_dummy < 0) THEN
          FND_MESSAGE.SET_NAME ('GMD', 'QC_INVALID_FORMULA');
          FND_MSG_PUB.ADD;
          RAISE substitution_creation_failure;
        END IF;
        -- reset
        l_dummy := 0;
      ELSE
        -- get formula no and version
        OPEN get_formula_no_vers(l_formula_substitution_rec.formula_id);
        FETCH get_formula_no_vers INTO l_formula_substitution_rec.formula_no,
                                       l_formula_substitution_rec.formula_vers;
          IF (get_formula_no_vers%NOTFOUND) THEN
            CLOSE get_formula_no_vers;
            FND_MESSAGE.SET_NAME ('GMD', 'QC_INVALID_FORMULA');
            FND_MSG_PUB.ADD;
            RAISE substitution_creation_failure;
          END IF;
        CLOSE get_formula_no_vers;
      END IF;

      /* Business Rules at formula substitution association level */
      -- Validation 1
      -- The formula the substitution is associated to should have the
      -- original item as its ingredient.
      OPEN  validate_formula_item(
              l_formula_substitution_rec.formula_id,
              get_original_item_id(l_substitution_id)
                                 );
      FETCH validate_formula_item INTO l_dummy;
      CLOSE validate_formula_item;

      IF (l_dummy <> 1) THEN
        FND_MESSAGE.SET_NAME ('GMD', 'GMD_FMSUB_INGR_MISSING');
        FND_MESSAGE.SET_TOKEN('FORMULA_VERSION',l_formula_substitution_rec.formula_vers);
        FND_MESSAGE.SET_TOKEN('FORMULA_NO',l_formula_substitution_rec.formula_no);
        FND_MSG_PUB.ADD;
        RAISE substitution_creation_failure;
      END IF;
      -- reset l_dummy
      l_dummy := 0;

      -- This formula should remain active (not deleted) and not obsoleted
      OPEN  validate_formula(l_formula_substitution_rec.formula_id);
      FETCH validate_formula INTO l_dummy;
      CLOSE validate_formula;

      IF (l_dummy <> 1) THEN
        FND_MESSAGE.SET_NAME ('GMD', 'GMD_INACTIVE_FMSUB');
        FND_MESSAGE.SET_TOKEN('FORMULA_VERSION',l_formula_substitution_rec.formula_vers);
        FND_MESSAGE.SET_TOKEN('FORMULA_NO',l_formula_substitution_rec.formula_no);
        FND_MSG_PUB.ADD;
        RAISE substitution_creation_failure;
      END IF;
      -- reset l_dummy
      l_dummy := 0;

      -- Validation 2
      -- If the formula has been already associated - error out.
      OPEN  validate_formula_substitution(l_substitution_id
                                         ,l_formula_substitution_rec.formula_id);
      FETCH validate_formula_substitution INTO l_dummy;
      CLOSE validate_formula_substitution;

      IF (l_dummy = 1) THEN
        FND_MESSAGE.SET_NAME ('GMD', 'GMD_FMSUB_ASSN_EXISTS');
        FND_MESSAGE.SET_TOKEN('FORMULA_VERSION',l_formula_substitution_rec.formula_vers);
        FND_MESSAGE.SET_TOKEN('FORMULA_NO',l_formula_substitution_rec.formula_no);
        FND_MSG_PUB.ADD;
        RAISE substitution_creation_failure;
      END IF;

      -- reset l_dummy
      l_dummy := 0;

      -- Set the standard who columns
      l_formula_substitution_rec.creation_date      := sysdate;
      l_formula_substitution_rec.created_by         := gmd_api_grp.user_id;
      l_formula_substitution_rec.last_update_date   := sysdate;
      l_formula_substitution_rec.last_updated_by    := gmd_api_grp.user_id;
      l_formula_substitution_rec.last_update_login  := gmd_api_grp.login_id;

      l_formula_substitution_tbl(i) := l_formula_substitution_rec;
    END LOOP;

    -- Call the insert formula subtitution association Pvt API
    GMD_SUBSTITUTION_PVT.Create_formula_association
    ( p_substitution_id          => l_substitution_id
    , p_formula_substitution_tbl => l_formula_substitution_tbl
    , x_message_count            => x_message_count
    , x_message_list             => x_message_list
    , x_return_status            => x_return_status
    );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE substitution_creation_failure;
    END IF;

    IF (p_commit = FND_API.g_true) THEN
      Commit;
    END IF;

  EXCEPTION
    WHEN substitution_creation_failure OR invalid_version OR setup_failure THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_msg_pub.count_and_get (
         p_count => x_message_count
        ,p_encoded => FND_API.g_false
        ,p_data => x_message_list);
      ROLLBACK TO SAVEPOINT substitution_api;
    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      fnd_msg_pub.add_exc_msg (gmd_substitution_pub.m_pkg_name, l_api_name);
      fnd_msg_pub.count_and_get (
         p_count => x_message_count
        ,p_encoded => FND_API.g_false
        ,p_data => x_message_list);
      ROLLBACK TO SAVEPOINT substitution_api;
  END Create_formula_association;

  /* =============================================================== */
  /* Procedure:                                                      */
  /*   Update_substitution_header                                    */
  /*                                                                 */
  /* DESCRIPTION:                                                    */
  /*                                                                 */
  /*                                                                 */
  /* History :                                                       */
  /*  Rajender Nalla    09-OCT-06   Initial implementation.          */
  /* =============================================================== */
  PROCEDURE Update_substitution_header
  ( p_api_version          IN          NUMBER
  , p_init_msg_list        IN          VARCHAR2
  , p_commit               IN          VARCHAR2
  , p_substitution_id      IN          NUMBER    Default NULL
  , p_substitution_name    IN          VARCHAR2  Default NULL
  , p_substitution_version IN          NUMBER    Default NULL
  , p_update_table         IN          update_tbl_type
  , x_message_count        OUT NOCOPY  NUMBER
  , x_message_list         OUT NOCOPY  VARCHAR2
  , x_return_status        OUT NOCOPY  VARCHAR2
  ) IS

    -- Cursor definition
    CURSOR get_old_substitution_rec(vSubstitution_id NUMBER) IS
      Select *
      From   gmd_item_substitution_hdr
      Where  substitution_id = vSubstitution_id;

    -- local variables
    l_substitution_id      NUMBER;
    l_owner_orgn_id        NUMBER;
    l_api_name    CONSTANT VARCHAR2(30) := 'Update_substitution_header';

    -- get a record type
    l_substitution_hdr_rec          gmd_item_substitution_hdr%ROWTYPE;

    -- Exception declaration
    substitution_update_failure     EXCEPTION;
    invalid_version                 EXCEPTION;
    setup_failure                   EXCEPTION;
  BEGIN
    SAVEPOINT substitution_api;

    /* Set the return status to success initially */
    x_return_status  := FND_API.G_RET_STS_SUCCESS;

    /* Initialize message list and count if needed */
    IF (p_init_msg_list = FND_API.G_true) THEN
       fnd_msg_pub.initialize;
    END IF;

    /* Intialize the setup fields */
    IF NOT gmd_api_grp.setup_done THEN
      gmd_api_grp.setup_done := gmd_api_grp.setup;
    END IF;
    IF NOT gmd_api_grp.setup_done THEN
      RAISE setup_failure;
    END IF;

    /* Make sure we are call compatible */
    IF NOT FND_API.compatible_api_call ( 1.0
                                        ,p_api_version
                                        ,'Update_substitution_header'
                                        ,gmd_substitution_pub.m_pkg_name) THEN
      RAISE invalid_version;
    END IF;

    /* Required fields at header level */
    -- Substitution id or (substitution_name and Substitution_version)
    IF (p_substitution_id IS NULL) THEN
      IF (p_substitution_name IS NULL) OR (p_substitution_version IS NULL) THEN
        -- Raise a exception
        FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
        FND_MESSAGE.SET_TOKEN ('MISSING', 'SUBSTITUTION_ID');
        FND_MSG_PUB.ADD;
        RAISE substitution_update_failure;
      ELSE
        OPEN  get_substitution_id(p_substitution_name, p_substitution_version);
        FETCH get_substitution_id INTO l_substitution_id;
          IF (get_substitution_id%NOTFOUND) THEN
            CLOSE get_substitution_id;
            FND_MESSAGE.SET_NAME ('GMD', 'GMD_INVALID_SUBSTITUTION');
            FND_MSG_PUB.ADD;
            RAISE substitution_update_failure;
          END IF;
        CLOSE get_substitution_id;
      END IF;
    ELSE
      l_substitution_id := p_substitution_id;
    END IF;

    -- prevent updates or modification of pending obsolete status
    IF NOT is_update_allowed(l_substitution_id) THEN
      RAISE substitution_update_failure;
    END IF;

    -- Retrieve the old susbtitution record
    OPEN  get_old_substitution_rec(l_substitution_id);
    FETCH get_old_substitution_rec INTO l_substitution_hdr_rec;
      IF (get_old_substitution_rec%NOTFOUND) THEN
        CLOSE get_old_substitution_rec;
        FND_MESSAGE.SET_NAME ('GMD', 'GMD_INVALID_SUBSTITUTION');
        FND_MSG_PUB.ADD;
        RAISE substitution_update_failure;
      END IF;
    CLOSE get_old_substitution_rec;

    /* Business Rules at header level */
    FOR i in 1 .. p_update_table.count LOOP
      -- Start date should be less than End date
      -- Convert the date from canonical format
      IF (Upper(p_update_table(i).p_col_to_update) = 'START_DATE') THEN
      	l_substitution_hdr_rec.start_date :=
      	               FND_DATE.canonical_to_date(p_update_table(i).p_value);
        IF (l_substitution_hdr_rec.end_date IS NOT NULL)  THEN
          IF (l_substitution_hdr_rec.end_date < l_substitution_hdr_rec.start_date) THEN
            FND_MESSAGE.SET_NAME('GMD', 'QC_MIN_MAX_DATE');
            FND_MSG_PUB.ADD;
            RAISE substitution_update_failure;
          END IF;
        END IF;
      ELSIF (Upper(p_update_table(i).p_col_to_update) = 'SUBSTITUTION_DESCRIPTION') THEN
        l_substitution_hdr_rec.substitution_description := p_update_table(i).p_value;
      ELSIF (Upper(p_update_table(i).p_col_to_update) = 'PREFERENCE') THEN
        IF (p_update_table(i).p_value < 0 ) THEN
          FND_MESSAGE.SET_NAME ('GMD', 'GMD_NEGATIVE_FIELDS');
          FND_MESSAGE.SET_TOKEN ('FIELD', 'PREFERENCE');
          FND_MSG_PUB.ADD;
          RAISE substitution_update_failure;
        END IF;
        l_substitution_hdr_rec.preference := p_update_table(i).p_value;
      ELSIF (Upper(p_update_table(i).p_col_to_update) = 'END_DATE') THEN
      	l_substitution_hdr_rec.end_date :=
      	               FND_DATE.canonical_to_date(p_update_table(i).p_value);
        IF (p_update_table(i).p_value IS NOT NULL)  THEN
          IF (l_substitution_hdr_rec.start_date > l_substitution_hdr_rec.end_date) THEN
            FND_MESSAGE.SET_NAME('GMD', 'QC_MIN_MAX_DATE');
            FND_MSG_PUB.ADD;
            RAISE substitution_update_failure;
          END IF;
        END IF;
      ELSIF (Upper(p_update_table(i).p_col_to_update) = 'ORIGINAL_QTY') THEN
        IF  (p_update_table(i).p_value < 0) THEN
          FND_MESSAGE.SET_NAME ('GMD', 'GMD_NEGATIVE_FIELDS');
          FND_MESSAGE.SET_TOKEN ('FIELD', 'ORIGINAL_QTY');
          FND_MSG_PUB.ADD;
          RAISE substitution_update_failure;
        END IF;
        l_substitution_hdr_rec.original_qty := p_update_table(i).p_value;
      ELSIF (Upper(p_update_table(i).p_col_to_update) = 'REPLACEMENT_UOM_TYPE') THEN
        -- replacement_uom_type -- Default it to value = 1 (original Item uom)
        IF  (p_update_table(i).p_value < 0) THEN
          FND_MESSAGE.SET_NAME ('GMD', 'GMD_NEGATIVE_FIELDS');
          FND_MESSAGE.SET_TOKEN ('FIELD', 'REPLACEMENT_UOM_TYPE');
          FND_MSG_PUB.ADD;
          RAISE substitution_update_failure;
        ELSIF (p_update_table(i).p_value > 2) THEN
          FND_MESSAGE.SET_NAME ('GMD', 'GMD_INV_REPLACEMENT_TYPE');
          FND_MSG_PUB.ADD;
          RAISE substitution_update_failure;
        END IF;
        l_substitution_hdr_rec.replacement_uom_type := p_update_table(i).p_value;
      -- Cannot change the orginal item in substitution.
      -- cannot change its original item uom
      -- Status cannot be changed - need to use Change Status API
      ELSIF (Upper(p_update_table(i).p_col_to_update) IN
                                   ('ORIGINAL_UOM'
                                   ,'OWNER_ORGANIZATION_ID'
                                   ,'ORIGINAL_INVENTORY_ITEM_ID')) THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_INVALID_COL_UPDATES');
        FND_MESSAGE.SET_TOKEN('NAME',p_update_table(i).p_col_to_update);
        FND_MSG_PUB.ADD;
        RAISE substitution_update_failure;
      ELSIF (Upper(p_update_table(i).p_col_to_update) =
                                   ('SUBSTITUTION_STATUS')) THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_NOT_USE_API_UPD_STATUS');
        FND_MSG_PUB.ADD;
        RAISE substitution_update_failure;
      ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE1') THEN
          l_substitution_hdr_rec.ATTRIBUTE1 := p_update_table(i).p_value;
      ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE2') THEN
          l_substitution_hdr_rec.ATTRIBUTE2 := p_update_table(i).p_value;
      ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE3') THEN
          l_substitution_hdr_rec.ATTRIBUTE3 := p_update_table(i).p_value;
      ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE4') THEN
          l_substitution_hdr_rec.ATTRIBUTE4 := p_update_table(i).p_value;
      ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE5') THEN
          l_substitution_hdr_rec.ATTRIBUTE5 := p_update_table(i).p_value;
      ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE6') THEN
          l_substitution_hdr_rec.ATTRIBUTE6 := p_update_table(i).p_value;
      ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE7') THEN
          l_substitution_hdr_rec.ATTRIBUTE7 := p_update_table(i).p_value;
      ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE8') THEN
          l_substitution_hdr_rec.ATTRIBUTE8 := p_update_table(i).p_value;
      ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE9') THEN
          l_substitution_hdr_rec.ATTRIBUTE9 := p_update_table(i).p_value;
      ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE10') THEN
          l_substitution_hdr_rec.ATTRIBUTE10 := p_update_table(i).p_value;
      ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE11') THEN
          l_substitution_hdr_rec.ATTRIBUTE11 := p_update_table(i).p_value;
      ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE12') THEN
          l_substitution_hdr_rec.ATTRIBUTE12 := p_update_table(i).p_value;
      ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE13') THEN
          l_substitution_hdr_rec.ATTRIBUTE13 := p_update_table(i).p_value;
      ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE14') THEN
          l_substitution_hdr_rec.ATTRIBUTE14 := p_update_table(i).p_value;
      ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE15') THEN
          l_substitution_hdr_rec.ATTRIBUTE15 := p_update_table(i).p_value;
      ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE16') THEN
          l_substitution_hdr_rec.ATTRIBUTE16 := p_update_table(i).p_value;
      ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE17') THEN
          l_substitution_hdr_rec.ATTRIBUTE17 := p_update_table(i).p_value;
      ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE18') THEN
          l_substitution_hdr_rec.ATTRIBUTE18 := p_update_table(i).p_value;
      ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE19') THEN
          l_substitution_hdr_rec.ATTRIBUTE19 := p_update_table(i).p_value;
      ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE20') THEN
          l_substitution_hdr_rec.ATTRIBUTE20 := p_update_table(i).p_value;
      ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE21') THEN
          l_substitution_hdr_rec.ATTRIBUTE21 := p_update_table(i).p_value;
      ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE22') THEN
          l_substitution_hdr_rec.ATTRIBUTE22 := p_update_table(i).p_value;
      ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE23') THEN
          l_substitution_hdr_rec.ATTRIBUTE23 := p_update_table(i).p_value;
      ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE24') THEN
          l_substitution_hdr_rec.ATTRIBUTE24 := p_update_table(i).p_value;
      ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE25') THEN
          l_substitution_hdr_rec.ATTRIBUTE25 := p_update_table(i).p_value;
      ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE26') THEN
          l_substitution_hdr_rec.ATTRIBUTE26 := p_update_table(i).p_value;
      ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE27') THEN
          l_substitution_hdr_rec.ATTRIBUTE27 := p_update_table(i).p_value;
      ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE28') THEN
          l_substitution_hdr_rec.ATTRIBUTE28 := p_update_table(i).p_value;
      ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE29') THEN
          l_substitution_hdr_rec.ATTRIBUTE29 := p_update_table(i).p_value;
      ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE30') THEN
          l_substitution_hdr_rec.ATTRIBUTE30 := p_update_table(i).p_value;
      ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE_CATEGORY') THEN
          l_substitution_hdr_rec.ATTRIBUTE_CATEGORY := p_update_table(i).p_value;
      ELSE
        FND_MESSAGE.SET_NAME('GMD', 'GMD_INVALID_UPDCOL_NAME');
        FND_MESSAGE.SET_TOKEN('NAME', p_update_table(i).p_col_to_update);
        FND_MSG_PUB.ADD;
        RAISE substitution_update_failure;
      END IF;

      -- Assign values
      l_substitution_hdr_rec.last_update_date  := SYSDATE;
      l_substitution_hdr_rec.last_updated_by   := gmd_api_grp.user_id;
      l_substitution_hdr_rec.last_update_login := gmd_api_grp.login_id;
    END LOOP;

    --Call the Pvt Substitution header API
    GMD_SUBSTITUTION_PVT.Update_substitution_header
    ( p_substitution_hdr_rec => l_substitution_hdr_rec
    , x_message_count        => x_message_count
    , x_message_list         => x_message_list
    , x_return_status        => x_return_status
    );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE substitution_update_failure;
    END IF;

    IF (p_commit = FND_API.g_true) THEN
      Commit;
    END IF;

  EXCEPTION
    WHEN substitution_update_failure OR invalid_version OR setup_failure THEN
         fnd_msg_pub.count_and_get (
            p_count => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data => x_message_list);
         x_return_status := FND_API.G_RET_STS_ERROR;
         ROLLBACK TO SAVEPOINT substitution_api;
    WHEN OTHERS THEN
         x_return_status := FND_API.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (gmd_substitution_pub.m_pkg_name, l_api_name);
         fnd_msg_pub.count_and_get (
            p_count => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data => x_message_list);
         ROLLBACK TO SAVEPOINT substitution_api;
  END Update_substitution_header;


  /* =============================================================== */
  /* Procedure:                                                      */
  /*   Update_substitution_detail                                    */
  /*                                                                 */
  /* DESCRIPTION:                                                    */
  /*                                                                 */
  /*                                                                 */
  /* History :                                                       */
  /* Rajender Nalla    09-OCT-06   Initial implementation.                     */
  /* =============================================================== */
  PROCEDURE Update_substitution_detail
  ( p_api_version            IN          NUMBER
  , p_init_msg_list          IN          VARCHAR2
  , p_commit                 IN          VARCHAR2
  , p_substitution_line_id   IN          NUMBER           Default NULL
  , p_substitution_id        IN          NUMBER           Default NULL
  , p_substitution_name      IN          VARCHAR2         Default NULL
  , p_substitution_version   IN          NUMBER           Default NULL
  , p_update_table           IN          update_tbl_type
  , x_message_count          OUT NOCOPY  NUMBER
  , x_message_list           OUT NOCOPY  VARCHAR2
  , x_return_status          OUT NOCOPY  VARCHAR2
  ) IS
    CURSOR get_subsdtl_rec_using_line_id(vSubstitution_line_id NUMBER) IS
      Select *
      From   gmd_item_substitution_dtl
      Where  substitution_line_id = vSubstitution_line_id;

    CURSOR get_subsdtl_rec_using_hdr_id(vSubstitution_id NUMBER) IS
      Select *
      From   gmd_item_substitution_dtl
      Where  substitution_id = vSubstitution_id;

    CURSOR get_substitution_hdr_dtl(vSubstitution_id NUMBER) IS
      Select original_inventory_item_id, replacement_uom_type
      From   gmd_item_substitution_hdr_b
      Where  substitution_id = vSubstitution_id;


    -- local variables
    l_substitution_id               NUMBER;
    l_substitution_line_id          NUMBER;
    l_api_name           CONSTANT   VARCHAR2(30) := 'Update_substitution_detail';
    l_original_prim_item_um         VARCHAR2(3);
    l_substitute_prim_item_um       VARCHAR2(3);
    l_original_item_id              NUMBER;
    l_original_item_no              VARCHAR2(1000);
    l_substitute_item_no            VARCHAR2(1000);
    l_replacement_uom_type          NUMBER;
    l_dummy                         NUMBER := 0;

    l_substitution_dtl_rec          gmd_item_substitution_dtl%ROWTYPE;

    -- Exception declaration
    substitution_update_failure     EXCEPTION;
    invalid_version                 EXCEPTION;
    setup_failure                   EXCEPTION;
  BEGIN
    SAVEPOINT substitution_api;

    /* Set the return status to success initially */
    x_return_status  := FND_API.G_RET_STS_SUCCESS;

    /* Initialize message list and count if needed */
    IF (p_init_msg_list = FND_API.G_True) THEN
       fnd_msg_pub.initialize;
    END IF;

    /* Intialize the setup fields */
    IF NOT gmd_api_grp.setup_done THEN
      gmd_api_grp.setup_done := gmd_api_grp.setup;
    END IF;
    IF NOT gmd_api_grp.setup_done THEN
      RAISE setup_failure;
    END IF;

    /* Make sure we are call compatible */
    IF NOT FND_API.compatible_api_call ( 1.0
                                        ,p_api_version
                                        ,'Update_substitution_header'
                                        ,gmd_substitution_pub.m_pkg_name) THEN
      RAISE invalid_version;
    END IF;

    /* Required fields at detail level */
    -- Substitution id or (substitution_name and Substitution_version)
    IF (p_substitution_line_id IS NULL) THEN
      -- get the substitution_id
      -- since master detail is one - to - one
      -- substitution id can be used to derive unique substitution line
      -- Substitution id or (substitution_name and Substitution_version)
      IF (p_substitution_id IS NULL) THEN
        IF (p_substitution_name IS NULL) OR (p_substitution_version IS NULL) THEN
          -- Raise a exception
          FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
          FND_MESSAGE.SET_TOKEN ('MISSING', 'SUBSTITUTION_ID');
          FND_MSG_PUB.ADD;
          RAISE substitution_update_failure;
        ELSE
          OPEN  get_substitution_id(p_substitution_name, p_substitution_version);
          FETCH get_substitution_id INTO l_substitution_id;
            IF (get_substitution_id%NOTFOUND) THEN
              CLOSE get_substitution_id;
              -- raise no record found exception
              FND_MESSAGE.SET_NAME ('GMD', 'GMD_INVALID_SUBSTITUTION');
              FND_MSG_PUB.ADD;
              RAISE substitution_update_failure;
            END IF;
          CLOSE get_substitution_id;
        END IF;
      ELSE
        l_substitution_id := p_substitution_id;
      END IF;
    ELSE
      l_substitution_line_id := p_substitution_line_id;
    END IF;

    IF (l_substitution_line_id IS NOT NULL) THEN
      OPEN  get_subsdtl_rec_using_line_id(l_substitution_line_id);
      FETCH get_subsdtl_rec_using_line_id INTO l_substitution_dtl_rec;
      CLOSE get_subsdtl_rec_using_line_id;
    ELSIF (l_substitution_id IS NOT NULL) THEN
      OPEN  get_subsdtl_rec_using_hdr_id(l_substitution_id);
      FETCH get_subsdtl_rec_using_hdr_id INTO l_substitution_dtl_rec;
      CLOSE get_subsdtl_rec_using_hdr_id;
    ELSE
      -- raise no record found exception
      FND_MESSAGE.SET_NAME ('GMD', 'GMD_INVALID_SUBSTITUTION');
      FND_MSG_PUB.ADD;
      RAISE substitution_update_failure;
    END IF;

    -- prevent updates or modification of pending obsolete status
    IF NOT is_update_allowed(l_substitution_dtl_rec.substitution_id) THEN
      RAISE substitution_update_failure;
    END IF;

    FOR i in 1 .. p_update_table.count LOOP
      -- If substitute item uom is being changed - check if it is convertible
      -- to the original item uom.
      IF UPPER(p_update_table(i).p_col_to_update) = 'DETAIL_UOM' THEN
        IF p_update_table(i).p_value IS NOT NULL THEN
          IF (NOT(gma_valid_grp.validate_um(p_update_table(i).p_value))) THEN
            FND_MESSAGE.SET_NAME('GMA', 'SY_INVALID_UM_CODE');
            FND_MSG_PUB.ADD;
            RAISE substitution_update_failure;
          END IF;
        END IF;

        -- Detail item uom validation
        --Get the original item id
        OPEN  get_substitution_hdr_dtl(l_substitution_dtl_rec.substitution_id);
        FETCH get_substitution_hdr_dtl INTO l_original_item_id, l_replacement_uom_type;
        CLOSE get_substitution_hdr_dtl;

        -- Get the original items primary uom
        OPEN  get_item_info(l_original_item_id);
        FETCH get_item_info INTO l_original_item_no, l_original_prim_item_um;
        CLOSE get_item_info;

        -- get the substitute items primary uom and item no
        OPEN  get_item_info(l_substitution_dtl_rec.inventory_item_id);
        FETCH get_item_info INTO l_substitute_item_no, l_substitute_prim_item_um;
        CLOSE get_item_info;

        l_dummy := INV_CONVERT.inv_um_convert (item_id        => l_substitution_dtl_rec.inventory_item_id
                                              ,precision      => 5
                                              ,from_quantity  => 100
                                              ,from_unit      => p_update_table(i).p_value
                                              ,to_unit        => l_substitute_prim_item_um
                                              ,from_name      => NULL
                                              ,to_name        => NULL);
        IF l_dummy < 0 THEN
          FND_MESSAGE.SET_NAME('GMD','FM_SCALE_BAD_ITEM_UOM');
          FND_MESSAGE.SET_TOKEN('FROM_UOM', p_update_table(i).p_value);
          FND_MESSAGE.SET_TOKEN('TO_UOM', l_substitute_prim_item_um);
          FND_MESSAGE.SET_TOKEN('ITEM_NO', l_substitute_item_no);
          FND_MSG_PUB.ADD;
          RAISE substitution_update_failure;
        END IF;
        -- reset l_dummy
        l_dummy := 0;

        IF (l_replacement_uom_type = 2) THEN
          l_dummy :=
            INV_CONVERT.inv_um_convert (item_id        => l_substitution_dtl_rec.inventory_item_id
                                       ,precision      => 5
                                       ,from_quantity  => 100
                                       ,from_unit      => p_update_table(i).p_value
                                       ,to_unit        => l_original_prim_item_um
                                       ,from_name      => NULL
                                       ,to_name        => NULL);
        IF l_dummy < 0 THEN
          FND_MESSAGE.SET_NAME('GMD','FM_SCALE_BAD_ITEM_UOM');
          FND_MESSAGE.SET_TOKEN('FROM_UOM', p_update_table(i).p_value);
          FND_MESSAGE.SET_TOKEN('TO_UOM', l_original_prim_item_um);
          FND_MESSAGE.SET_TOKEN('ITEM_NO', l_substitute_item_no);
          FND_MSG_PUB.ADD;
          RAISE substitution_update_failure;
        END IF;
      END IF;
        -- reset l_dummy
        l_dummy := 0;

        l_substitution_dtl_rec.detail_uom := p_update_table(i).p_value;

      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'UNIT_QTY' THEN
        IF p_update_table(i).p_value IS NULL THEN
          FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
          FND_MESSAGE.SET_TOKEN ('MISSING', 'UNIT_QTY');
          FND_MSG_PUB.ADD;
          RAISE substitution_update_failure;
        ELSIF (p_update_table(i).p_value < 0 ) THEN
          FND_MESSAGE.SET_NAME ('GMD', 'GMD_NEGATIVE_FIELDS');
          FND_MESSAGE.SET_TOKEN ('FIELD', 'UNIT_QTY');
          FND_MSG_PUB.ADD;
          RAISE substitution_update_failure;
        END IF;
        l_substitution_dtl_rec.unit_qty := p_update_table(i).p_value;
      -- Cannot change the Substitute item for the list
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'INVENTORY_ITEM_ID' THEN
        -- raise exception
        FND_MESSAGE.SET_NAME('GMD', 'GMD_INVALID_COL_UPDATES');
        FND_MESSAGE.SET_TOKEN('NAME',p_update_table(i).p_col_to_update);
        FND_MSG_PUB.ADD;
        RAISE substitution_update_failure;
      ELSE
        FND_MESSAGE.SET_NAME('GMD', 'GMD_INVALID_UPDCOL_NAME');
        FND_MESSAGE.SET_TOKEN('NAME', p_update_table(i).p_col_to_update);
        FND_MSG_PUB.ADD;
        RAISE substitution_update_failure;
      END IF;

      -- Assign values
      l_substitution_dtl_rec.last_update_date  := SYSDATE;
      l_substitution_dtl_rec.last_updated_by   := gmd_api_grp.user_id;
      l_substitution_dtl_rec.last_update_login := gmd_api_grp.login_id;
    END LOOP;

    -- call the pvt API
    GMD_SUBSTITUTION_PVT.Update_substitution_detail
    ( p_substitution_dtl_rec  => l_substitution_dtl_rec
    , x_message_count         => x_message_count
    , x_message_list          => x_message_list
    , x_return_status         => x_return_status
    );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE substitution_update_failure;
    END IF;

    IF (p_commit = FND_API.g_true) THEN
      Commit;
    END IF;
  EXCEPTION
    WHEN substitution_update_failure OR invalid_version OR setup_failure THEN
         fnd_msg_pub.count_and_get (
            p_count => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data => x_message_list);
         x_return_status := FND_API.G_RET_STS_ERROR;
         ROLLBACK TO SAVEPOINT substitution_api;
    WHEN OTHERS THEN
         x_return_status := FND_API.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (gmd_substitution_pub.m_pkg_name, l_api_name);
         fnd_msg_pub.count_and_get (
            p_count => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data => x_message_list);
         ROLLBACK TO SAVEPOINT substitution_api;
  END Update_substitution_detail;

  /* =============================================================== */
  /* Procedure:                                                      */
  /*   Delete_formula_association                                    */
  /*                                                                 */
  /* DESCRIPTION:                                                    */
  /*                                                                 */
  /*                                                                 */
  /* History :                                                       */
  /* Rajender Nalla    09-OCT-06   Initial implementation.                     */
  /* =============================================================== */
  PROCEDURE Delete_formula_association
  ( p_api_version              IN          NUMBER
  , p_init_msg_list            IN          VARCHAR2
  , p_commit                   IN          VARCHAR2
  , p_formula_substitution_id  IN          NUMBER    Default NULL
  , p_substitution_id          IN          NUMBER    Default NULL
  , p_substitution_name        IN          VARCHAR2  Default NULL
  , p_substitution_version     IN          NUMBER    Default NULL
  , p_formula_id               IN          NUMBER    Default NULL
  , p_formula_no               IN          VARCHAR2  Default NULL
  , p_formula_vers             IN          NUMBER    Default NULL
  , x_message_count            OUT NOCOPY  NUMBER
  , x_message_list             OUT NOCOPY  VARCHAR2
  , x_return_status            OUT NOCOPY  VARCHAR2
  ) IS

    CURSOR get_formula_substitution_id(vSubstitution_id    NUMBER
                                      ,vformula_id         NUMBER) IS
      SELECT formula_substitution_id
      FROM   gmd_formula_substitution
      WHERE  substitution_id  = vSubstitution_id
      AND    formula_id       = vformula_id;

    CURSOR get_formula_subs_info(vformula_Substitution_id    NUMBER) IS
      SELECT substitution_id
      FROM   gmd_formula_substitution
      WHERE  formula_substitution_id  = vformula_Substitution_id;

    l_formula_substitution_id  NUMBER;
    l_substitution_id          NUMBER;
    l_formula_id               NUMBER;
    l_dummy                    NUMBER := 0;
    l_api_name    CONSTANT VARCHAR2(30) := 'Delete_formula_association';

   -- Exception declaration
    substitution_delete_failure     EXCEPTION;
    invalid_version                 EXCEPTION;
    setup_failure                   EXCEPTION;
  BEGIN
    SAVEPOINT substitution_api;

    /* Set the return status to success initially */
    x_return_status  := FND_API.G_RET_STS_SUCCESS;

    /* Initialize message list and count if needed */
    IF (p_init_msg_list = FND_API.G_True) THEN
       fnd_msg_pub.initialize;
    END IF;

    /* Intialize the setup fields */
    IF NOT gmd_api_grp.setup_done THEN
      gmd_api_grp.setup_done := gmd_api_grp.setup;
    END IF;
    IF NOT gmd_api_grp.setup_done THEN
      RAISE setup_failure;
    END IF;

    /* Make sure we are call compatible */
    IF NOT FND_API.compatible_api_call ( 1.0
                                        ,p_api_version
                                        ,'Delete_formula_association'
                                        ,gmd_substitution_pub.m_pkg_name) THEN
      RAISE invalid_version;
    END IF;

    /* Required fields */
    -- Substitution id or (substitution_name and Substitution_version)
    -- p_formula_substitution_id
    IF (p_formula_substitution_id IS NULL) THEN
      -- Substitution id or (substitution_name and Substitution_version)
      IF ((p_substitution_id IS NULL) AND
          (p_substitution_name IS NULL OR
           p_substitution_version IS NULL)) THEN
        FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
        FND_MESSAGE.SET_TOKEN ('MISSING', 'SUBSTITUTION_ID');
        FND_MSG_PUB.ADD;
        RAISE substitution_delete_failure;
      ELSIF (p_substitution_id IS NULL) THEN
        -- Get the subsitution id
        OPEN get_substitution_id(p_substitution_name
                                ,p_substitution_version);
        FETCH get_substitution_id INTO l_substitution_id;
        IF (get_substitution_id%NOTFOUND) THEN
          CLOSE get_substitution_id;
          FND_MESSAGE.SET_NAME ('GMD', 'GMD_INVALID_SUBSTITUTION');
          FND_MSG_PUB.ADD;
          RAISE substitution_delete_failure;
        END IF;
        CLOSE get_substitution_id;
      ELSE
        l_substitution_id := p_substitution_id;
      END IF;

      -- formula_id or (formula_no and formula_version combination
      IF ((p_formula_id IS NULL) AND
          (p_formula_no IS NULL OR p_formula_vers IS NULL)) THEN
        FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
        FND_MESSAGE.SET_TOKEN ('MISSING', 'FORMULA_ID');
        FND_MSG_PUB.ADD;
        RAISE substitution_delete_failure;
      ELSIF (p_formula_id IS NULL) THEN
        -- Get the formula id
        GMDFMVAL_PUB.get_formula_id
                    (pformula_no  => p_formula_no
                    ,pversion     => p_formula_vers
                    ,xvalue       => l_formula_id
                    ,xreturn_code => l_dummy);
        IF (l_dummy < 0) THEN
          FND_MESSAGE.SET_NAME ('GMD', 'QC_INVALID_FORMULA');
          FND_MSG_PUB.ADD;
          RAISE substitution_delete_failure;
        END IF;
      ELSE
        l_formula_id := p_formula_id;
      END IF;

      -- Get the formula substitution id
      OPEN  get_formula_substitution_id(l_substitution_id, l_formula_id);
      FETCH get_formula_substitution_id INTO l_formula_substitution_id;
        IF (get_formula_substitution_id%NOTFOUND) THEN
          CLOSE get_formula_substitution_id;
          FND_MESSAGE.SET_NAME ('GMD', 'GMD_FMSUB_ASSN_MISSING');
          FND_MESSAGE.SET_TOKEN('FORMULA_VERSION',p_formula_vers);
          FND_MESSAGE.SET_TOKEN('FORMULA_NO',p_formula_no);
          FND_MSG_PUB.ADD;
          RAISE substitution_delete_failure;
        END IF;
      CLOSE get_formula_substitution_id;
    ELSE
      OPEN get_formula_subs_info(p_formula_Substitution_id);
      FETCH get_formula_subs_info INTO l_substitution_id;
      CLOSE get_formula_subs_info;

      IF (l_substitution_id IS NULL) THEN
        FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
        FND_MESSAGE.SET_TOKEN ('MISSING', 'FORMULA_SUBSTITUTION_ID');
        FND_MSG_PUB.ADD;
        RAISE substitution_delete_failure;
      ELSE
        l_formula_substitution_id := p_formula_Substitution_id;
      END IF;
    END IF;

    -- prevent updates or modification of pending obsolete status
    IF NOT is_update_allowed(l_substitution_id) THEN
      RAISE substitution_delete_failure;
    END IF;

    -- Call the pvt API
    GMD_SUBSTITUTION_PVT.Delete_formula_association
    ( p_formula_substitution_id  => l_formula_substitution_id
    , x_message_count            => x_message_count
    , x_message_list             => x_message_list
    , x_return_status            => x_return_status
    );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE substitution_delete_failure;
    END IF;

    IF (p_commit = FND_API.g_true) THEN
      Commit;
    END IF;

  EXCEPTION
    WHEN substitution_delete_failure OR invalid_version OR setup_failure THEN
         fnd_msg_pub.count_and_get (
            p_count => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data => x_message_list);
         x_return_status := FND_API.G_RET_STS_ERROR;
         ROLLBACK TO SAVEPOINT substitution_api;
    WHEN OTHERS THEN
         x_return_status := FND_API.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (gmd_substitution_pub.m_pkg_name, l_api_name);
         fnd_msg_pub.count_and_get (
            p_count => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data => x_message_list);
         ROLLBACK TO SAVEPOINT substitution_api;
  END Delete_formula_association;

END GMD_SUBSTITUTION_PUB;

/
