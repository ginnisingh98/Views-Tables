--------------------------------------------------------
--  DDL for Package Body INV_ITEM_CATEGORY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_ITEM_CATEGORY_PUB" AS
/* $Header: INVPCATB.pls 120.9.12010000.3 2009/06/02 02:50:23 geguo ship $ */


G_PKG_NAME      CONSTANT VARCHAR2(30):= 'INV_ITEM_CATEGORY_PUB';
G_INVENTORY_APP_ID CONSTANT NUMBER := 401;
G_INVENTORY_APP_SHORT_NAME CONSTANT VARCHAR2(3) := 'INV';
G_CAT_FLEX_CODE CONSTANT VARCHAR2(4) := 'MCAT';

-- Used by the Preprocess_Category_Rec procedure
G_INSERT CONSTANT NUMBER := 1;
G_UPDATE CONSTANT NUMBER := 2;

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
-- For debugging purposes.
   PROCEDURE mdebug(msg IN varchar2)
    IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    BEGIN
--      dbms_output.put_line(msg);
--      FND_FILE.PUT_LINE(FND_FILE.LOG, msg);
    null;
--     inv_debug(msg);
   END mdebug;

  ----------------------------------------------------------------------------
  -- validate_category_set_id
  -- Bug: 3093555
  -- Supporting method to validate category_set_id
  ----------------------------------------------------------------------------
  FUNCTION validate_category_set_id
                  (p_category_set_id   IN  NUMBER
                  ,x_hierarchy_enabled OUT NOCOPY VARCHAR2)
    RETURN BOOLEAN IS
    -- Start OF comments
    -- API name    : validate_category_set_id
    -- TYPE        : Private
    -- Called From : Create_Valid_Category
    -- Pre-reqs    : None
    -- FUNCTION    : Validates whether the category_set_id passed
    --               returns TRUE if the category_set_id is valid
    --               returns FALSE if the category_set_id is invalid
    --               returns the hierarchy through the out parameter
    --
    -- END OF comments
  l_hierarchy_enabled  mtl_category_sets_b.hierarchy_enabled%TYPE := NULL;
  BEGIN
    IF p_category_set_id IS NULL THEN
      RETURN FALSE;
    END IF;
    SELECT hierarchy_enabled INTO l_hierarchy_enabled
    FROM mtl_category_sets_b
    WHERE category_set_id = p_category_set_id;
    IF (SQL%FOUND) THEN
      x_hierarchy_enabled := l_hierarchy_enabled;
    END IF;
    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      x_hierarchy_enabled := NULL;
      RETURN FALSE;
  END validate_category_set_id;

  ----------------------------------------------------------------------------
  -- validate_category_id
  -- Bug: 3093555
  -- Supporting method to validate category_id
  ----------------------------------------------------------------------------
  FUNCTION validate_category_id (p_category_id       IN NUMBER
                                ,p_category_set_id   IN NUMBER)
    RETURN BOOLEAN IS
    -- Start OF comments
    -- API name    : validate_category_id
    -- TYPE        : Private
    -- Called From : Create_Valid_Category, Update_valid_category
    -- Pre-reqs    : None
    -- FUNCTION    : Validates whether the category_id passed
    --               returns TRUE if the category_id is valid
    --               returns FALSE if the category_id is invalid
    --
    -- END OF comments

  CURSOR c_validate_category_id (cp_category_id  IN NUMBER
                                ,cp_cat_set_id   IN NUMBER) IS
  SELECT cat.category_id
  FROM   mtl_categories_b cat, mtl_category_sets_b cat_set
  WHERE  cat_set.category_set_id = cp_cat_set_id
    AND  cat_set.structure_id = cat.structure_id
    AND  cat.category_id  = cp_category_id
    AND  ((cat.enabled_flag = 'Y'
    -- do not display today's records
          AND  TRUNC(NVL(cat.disable_date,SYSDATE+1)) > TRUNC(SYSDATE)
          )
          OR NVL(g_eni_upgarde_flag,'N') = 'Y' --Added for ENI 11.5.10 Upgrade
         )
     ;

  l_category_id mtl_categories_b.category_id%TYPE;

  BEGIN
    OPEN c_validate_category_id (cp_category_id => p_category_id
                                ,cp_cat_set_id  => p_category_set_id);
    FETCH c_validate_category_id INTO l_category_id;
    IF c_validate_category_id%FOUND THEN
      CLOSE c_validate_category_id;
      RETURN TRUE;
    ELSE
      CLOSE c_validate_category_id;
      RETURN FALSE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_validate_category_id%ISOPEN THEN
        CLOSE c_validate_category_id;
      END IF;
      RETURN FALSE;
  END validate_category_id;

  ----------------------------------------------------------------------------
  -- valid_category_set_record
  -- Bug: 3093555
  -- Supporting method to validate record in mtl_category_set_valid_cats
  ----------------------------------------------------------------------------
  FUNCTION valid_category_set_record (p_category_set_id  IN  NUMBER
                                     ,p_category_id       IN NUMBER)
    RETURN BOOLEAN IS
    -- Start OF comments
    -- API name    : valid_category_set_record
    -- TYPE        : Private
    -- Called From : Delete_Valid_Category, Update_valid_category
    -- Pre-reqs    : None
    -- FUNCTION    : Validates whether the record exists in
    --                  mtl_category_set_valid_cats
    --               returns TRUE if record exists
    --               returns FALSE if record does not exist
    --
    -- END OF comments
  l_category_id mtl_categories_b.category_id%TYPE;

  BEGIN
    SELECT category_id
    INTO l_category_id
    FROM mtl_category_set_valid_cats
    WHERE category_id = p_category_id
      AND category_set_id = p_category_set_id;
    IF (SQL%FOUND) THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END valid_category_set_record;

  ----------------------------------------------------------------------------
  -- get_category_set_type
  -- Bug: 5219692
  -- Supporting method to validate record in mtl_category_set_valid_cats
  -- Function is similar to valid_category_set_record
  -- Returns FALSE if the row does not exist
  ----------------------------------------------------------------------------
  FUNCTION get_category_set_type (p_category_set_id  IN  NUMBER
                                 ,p_category_id      IN  NUMBER
                                 ,x_hrchy_enabled    OUT NOCOPY VARCHAR2)
    RETURN BOOLEAN IS
    -- Start OF comments
    -- FUNCTION    : Validates whether the record exists in
    --                  mtl_category_set_valid_cats
    --               returns TRUE if record exists
    --               returns FALSE if record does not exist
    --               Also populates the out variable with
    --               value of column hierarchy_enabled
    --
    -- END OF comments
  l_category_id       mtl_categories_b.category_id%TYPE;

  BEGIN
    SELECT csv.category_id, cs.hierarchy_enabled
    INTO l_category_id, x_hrchy_enabled
    FROM mtl_category_set_valid_cats csv
        ,mtl_category_sets_b         cs
    WHERE csv.category_id     = p_category_id
      AND csv.category_set_id = p_category_set_id
      AND cs.category_set_id  = csv.category_set_id;
    IF (SQL%FOUND) THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END get_category_set_type;


  ----------------------------------------------------------------------------
  -- validate_parent_category_id
  -- Bug: 3093555
  -- Supporting method to validate parent_category_id
  ----------------------------------------------------------------------------
  FUNCTION validate_category_set_params
        (p_validation_type    IN  NUMBER
        ,p_category_set_id    IN  NUMBER
        ,p_category_id        IN  NUMBER
        ,p_parent_category_id IN  NUMBER
        ,p_calling_api        IN  VARCHAR2
        )
    RETURN BOOLEAN IS
    -- Start OF comments
    -- API name    : validate_category_set_params
    -- TYPE        : Private
    -- Called From : Create_Valid_Category, Update_valid_category
    -- Pre-reqs    : None
    -- FUNCTION    : Validates whether the passed parameters are valid
    --               returns TRUE if all the parameters are valid
    --               returns FALSE if any of the parameters are invalid
    --
    -- END OF comments
  l_api_name           VARCHAR2(30) := 'Validate Params';
  l_count              NUMBER;
  l_valid              BOOLEAN := TRUE;
  l_def_category_id    mtl_category_sets_b.default_category_id%TYPE;
  l_debug              NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  l_hierarchy_enabled  mtl_category_sets_b.hierarchy_enabled%TYPE := NULL;
  l_loop_may_occur     BOOLEAN := FALSE;
  l_category_id        mtl_categories_b.category_id%TYPE;

  CURSOR c_check_loops (cp_parent_category_id IN NUMBER
                       ,cp_category_set_id    IN NUMBER) IS
  SELECT category_id
  FROM  mtl_category_set_valid_cats
  WHERE category_set_id = cp_category_set_id
  CONNECT BY prior category_id = parent_category_id
  START WITH parent_category_id = cp_parent_category_id;

  CURSOR c_get_default_category_id (cp_category_set_id  IN  NUMBER
                                   ,cp_category_id      IN  NUMBER) IS
  SELECT default_category_id
  FROM  mtl_category_sets_b cat_sets
  WHERE cat_sets.category_set_id = cp_category_set_id
    AND cat_sets.default_category_id = cp_category_id;

  CURSOR c_check_item_assocs  (cp_category_set_id  IN  NUMBER
                              ,cp_category_id      IN  NUMBER) IS
  SELECT category_id
  FROM mtl_item_categories
  WHERE category_id = cp_category_id
    AND category_set_id = cp_category_set_id
    AND rownum = 1;

  BEGIN
    IF l_debug = 1 THEN
      mdebug('Validate Params: Tracing...1 ');
    END IF;
    --
    -- all params must be present
    --
    IF (p_category_set_id  IS NULL OR  p_category_id IS NULL) THEN
      IF l_debug = 1 THEN
        mdebug('Validate Params: Missing reqd parameter');
      END IF;
      l_valid := FALSE;
      fnd_message.set_name('INV','INV_MISSING_REQUIRED_PARAMETER');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_EXC_ERROR;
    END IF;
    IF l_debug = 1 THEN
      mdebug('Validate Params: Required params passed. ');
    END IF;
    --
    -- the category_id and parent category id must not be same
    --
    IF (p_category_id = p_parent_category_id) THEN
      l_valid := FALSE;
      IF l_debug = 1 THEN
        mdebug('Validate Params: Same Parent and Category Set Id');
      END IF;
      fnd_message.set_name('INV','INV_SAME_CATEGORY_SETS');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_EXC_ERROR;
    END IF;
    IF l_debug = 1 THEN
      mdebug('Validate Params: Parent and Child category ids are diff');
    END IF;
    IF p_validation_type = G_INSERT THEN
      IF l_debug = 1 THEN
        mdebug('Validate Params: check for Insert ');
      END IF;
      --
      -- check whether the category_id is valid
      --
      IF NOT validate_category_id
                 (p_category_id => p_category_id
                 ,p_category_set_id => p_category_set_id) THEN
        l_valid := FALSE;
        IF l_debug = 1 THEN
          mdebug('Validate Params: Invalid Category Id');
        END IF;
        fnd_message.set_name('INV','INV_INVALID_PARAMETER');
        fnd_message.set_token('PARAM_NAME', 'CATEGORY_ID');
        fnd_message.set_token('PROGRAM_NAME', G_PKG_NAME||'.'||p_calling_api);
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_EXC_ERROR;
      END IF;
      IF l_debug = 1 THEN
        mdebug('Validate Params: Category Id is valid for insert');
      END IF;
    ELSIF p_validation_type = G_UPDATE THEN
      IF l_debug = 1 THEN
        mdebug('Validate Params: check for Update ');
      END IF;
      --
      -- The record must exist in mtl_category_set_valid_cats
      --
      IF NOT valid_category_set_record (p_category_set_id => p_category_set_id
                                       ,p_category_id     => p_category_id) THEN

        l_valid := FALSE;
        IF l_debug = 1 THEN
          mdebug('Validate Params: Record not available for update');
        END IF;
        fnd_message.set_name('INV','INV_CATEGORY_UNAVAIL_UPDATE');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_EXC_ERROR;
      END IF;
      IF l_debug = 1 THEN
        mdebug('Validate Params: Record exists in mtl_category_set_valid_cats ');
      END IF;
      --
      -- The new parent category should not create any hierarchical loops
      -- to be validated for Update only
      -- the new parent, should not be amongst the
      -- children of the current category id
      l_loop_may_occur := FALSE;
      FOR cr in c_check_loops
                (cp_parent_category_id => p_category_id
                ,cp_category_set_id    => p_category_set_id) LOOP
        IF cr.category_id = p_parent_category_id THEN
          l_loop_may_occur := TRUE;
          EXIT;
        END IF;
      END LOOP;
      IF l_loop_may_occur THEN
        l_valid := FALSE;
        IF l_debug = 1 THEN
          mdebug('Validate Params: You might create loops!! ');
        END IF;
        fnd_message.set_name('INV','INV_CATEGORY_LOOPS_ERR');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_EXC_ERROR;
      END IF;
      IF l_debug = 1 THEN
        mdebug('Validate Params: No loops after updation ');
      END IF;
    END IF;
    --
    -- check whether the passed category set id is valid
    --
    IF validate_category_set_id
                   (p_category_set_id   => p_category_set_id
                   ,x_hierarchy_enabled => l_hierarchy_enabled) THEN
      -- category_set_id is valid, check for hierarchy enabled
      IF (NVL(l_hierarchy_enabled, 'N') = 'Y') THEN
        -- category is hierarchy enabled.
        IF p_parent_category_id IS NULL THEN
          -- not mandatory to pass.
          l_valid := TRUE;
          IF l_debug = 1 THEN
            mdebug('Validate Params: User wishes to create a leaf node ');
          END IF;
--          fnd_message.set_name('INV','INV_MISSING_PARENT_CAT');
--          fnd_msg_pub.ADD;
--          RAISE fnd_api.g_EXC_ERROR;
        ELSE
          --
          -- check whether the parent category id is valid
          --
          IF NOT validate_category_id
                 (p_category_id => p_parent_category_id
                 ,p_category_set_id => p_category_set_id) THEN
            l_valid := FALSE;
            IF l_debug = 1 THEN
              mdebug('Validate Params: Invalid Parent Category Id');
            END IF;
            fnd_message.set_name('INV','INV_INVALID_PARAMETER');
            fnd_message.set_token('PARAM_NAME', 'PARENT_CATEGORY_ID');
            fnd_message.set_token('PROGRAM_NAME',
                                   G_PKG_NAME||'.'||p_calling_api);
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_EXC_ERROR;
          END IF;
          IF l_debug = 1 THEN
            mdebug('Validate Params: Parent category id is valid in mtl_categories_b ');
          END IF;
          --
          -- the parent category cannot be the default category
          --
          OPEN c_get_default_category_id (cp_category_set_id => p_category_set_id
                                         ,cp_category_id => p_parent_category_id);
          FETCH c_get_default_category_id INTO l_def_category_id;
          IF c_get_default_category_id%NOTFOUND THEN
            l_def_category_id := NULL;
          END IF;
          CLOSE c_get_default_category_id;
          IF l_def_category_id IS NULL THEN
            IF l_debug = 1 THEN
              mdebug('Validate Params: Parent category id is NOT default cat ');
            END IF;
            -- the parent category id is not the default category
            -- check for any items associations to the prospective parent category id
            OPEN c_check_item_assocs (cp_category_set_id  => p_category_set_id
                                     ,cp_category_id      => p_parent_category_id);
            FETCH c_check_item_assocs INTO l_category_id;
            IF c_check_item_assocs%NOTFOUND THEN
              l_category_id := NULL;
            END IF;
            CLOSE c_check_item_assocs;
            IF l_category_id IS NULL THEN
              -- no items associated
              -- perfect to be associated as parent category
              IF l_debug = 1 THEN
                mdebug('Validate Params: Parent category id is valid ');
              END IF;
              l_valid := TRUE;
            ELSE
              -- child node (items associated). we cannot make this parent
              l_valid := FALSE;
              IF l_debug = 1 THEN
                mdebug('Validate Params: Items attached, cannot be parent ');
              END IF;
              fnd_message.set_name('INV','INV_INVALID_PARAMETER');
              fnd_message.set_token('PARAM_NAME', 'PARENT_CATEGORY_ID');
              fnd_message.set_token('PROGRAM_NAME',
                      G_PKG_NAME||'.'||p_calling_api);
              fnd_msg_pub.ADD;
            END IF; -- l_count = 0
          ELSE
            -- the passed parent is the default category id
            l_valid := FALSE;
            IF l_debug = 1 THEN
              mdebug('Validate Params: Cannot take parent as default category id ');
            END IF;
            fnd_message.set_name('INV','INV_DEFAULT_CATEGORY_ADD_ERR');
            fnd_msg_pub.ADD;
          END IF; -- l_coount = 0
        END IF; -- p_parent_category_id IS NULL
      ELSE
        -- category hierarchy is disabled
        IF p_parent_category_id IS NOT NULL THEN
          -- parent category_id should not be passed
          l_valid := FALSE;
          IF l_debug = 1 THEN
            mdebug('Validate Params: Do not pass Parent Category Id ');
          END IF;
          fnd_message.set_name('INV','INV_UNWANTED_PARENT_CAT');
          fnd_msg_pub.ADD;
        ELSE
          -- parent category_id should be NULL
          IF l_debug = 1 THEN
            mdebug('Validate Params: Parent category id is null for hierarchy disabled ');
          END IF;
          l_valid := TRUE;
        END IF;
      END IF; -- hierarchy enabled.
    ELSE
      l_valid := FALSE;
      IF l_debug = 1 THEN
        mdebug('Validate Params: Invalid Category Set Id');
      END IF;
      fnd_message.set_name('INV','INV_INVALID_PARAMETER');
      fnd_message.set_token('PARAM_NAME', 'CATEGORY_SET_ID');
      fnd_message.set_token('PROGRAM_NAME', G_PKG_NAME||'.'||p_calling_api);
      fnd_msg_pub.ADD;
    END IF;
    IF l_debug = 1 THEN
      mdebug('Validate Params: Returning without exceptions');
    END IF;
    RETURN  l_valid;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_check_loops%ISOPEN THEN
        CLOSE c_check_loops;
      END IF;
      IF c_get_default_category_id%ISOPEN THEN
        CLOSE c_get_default_category_id;
      END IF;
      IF c_check_item_assocs%ISOPEN THEN
        CLOSE c_check_item_assocs;
      END IF;
      IF l_debug = 1 THEN
        mdebug('Validate Params: Exception Raised');
      END IF;
      RETURN FALSE;
  END validate_category_set_params;

   -- Environment setting.
   -- Call this procedure internally to Test the proper updation of
   -- Created_By, Last_Updated_By, Last_Update_Login etc., columns
/*
   PROCEDURE Apps_Initialize
    IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    BEGIN
        -- To set the APPS Environment context through PL/SQL.
       fnd_global.apps_initialize(1068, 20634, 401);
       IF (l_debug = 1) THEN
          mdebug('User ID :'||to_char(FND_GLOBAL.user_id));
          mdebug('User NAME :'||FND_GLOBAL.user_name);
          mdebug('Login ID :'||to_char(FND_GLOBAL.login_id));
          mdebug('Prog Appl ID :'||to_char(FND_GLOBAL.prog_appl_id));
          mdebug('Application Name :'||FND_GLOBAL.application_name);
          mdebug('Language :'||FND_GLOBAL.current_language);
          mdebug('And many more...');
       END IF;
   END Apps_Initialize;
     */


   FUNCTION  To_Boolchar
      (
         p_bool        IN   BOOLEAN
      )
      RETURN  VARCHAR2
      IS
        l_api_name  CONSTANT  VARCHAR2(30)  :=  'To_Boolchar' ;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
      BEGIN

        IF ( p_bool = TRUE ) THEN
           RETURN fnd_api.g_TRUE ;
        ELSIF ( p_bool = FALSE ) THEN
           RETURN fnd_api.g_FALSE ;
        ELSE
           NULL;
        END IF;

   END To_Boolchar;


  --  To check for invalid values in the record according to the operation is
  --  INSERT or UPDATE, and report Errors appropriately.
  --  Preprocess_Category_Rec
  ----------------------------------------------------------------------------
  PROCEDURE Preprocess_Category_Rec
  (
    p_operation        IN   NUMBER,
    p_category_rec     IN   INV_ITEM_CATEGORY_PUB.CATEGORY_REC_TYPE,
    x_category_rec     OUT  NOCOPY INV_ITEM_CATEGORY_PUB.CATEGORY_REC_TYPE

   ) IS

  l_category_rec INV_ITEM_CATEGORY_PUB.CATEGORY_REC_TYPE;
  l_flexstr_exists   VARCHAR2(1);

  CURSOR get_structure_id(p_structure_code VARCHAR) IS
        SELECT id_flex_num
        FROM fnd_id_flex_structures
        WHERE application_id = G_INVENTORY_APP_ID
        AND id_flex_code = G_CAT_FLEX_CODE
        AND id_flex_structure_code = p_structure_code
        AND enabled_flag = 'Y';

  CURSOR get_category_structure_id(p_category_id NUMBER) IS
        SELECT structure_id
        FROM mtl_categories_b
        WHERE category_id = p_category_id;

  CURSOR validate_structure_id(p_structure_id VARCHAR) IS
        SELECT 'x'
        FROM fnd_id_flex_structures
        WHERE application_id = G_INVENTORY_APP_ID
        AND id_flex_code = G_CAT_FLEX_CODE
        AND id_flex_num = p_structure_id
        AND enabled_flag = 'Y';

  CURSOR category_rec_cursor(p_category_id NUMBER) IS
    SELECT
        --category_id,
        --structure_id,
        description,
        attribute_category,
        summary_flag,
        enabled_flag,
        start_date_active,
        end_date_active,
        disable_date,
        web_status,--Bug: 2430879
        supplier_enabled_flag,--Bug: 2645153
        segment1,
        segment2,
        segment3,
        segment4,
        segment5,
        segment6,
        segment7,
        segment8,
        segment9,
        segment10,
        segment11,
        segment12,
        segment13,
        segment14,
        segment15,
        segment16,
        segment17,
        segment18,
        segment19,
        segment20,
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
        attribute15
        --last_update_date,
        --last_updated_by,
        --creation_date,
        --created_by,
        --last_update_login
        FROM mtl_categories_vl
        WHERE category_id = p_category_id;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_product_str_id  NUMBER;  -- Bug 5474569
  BEGIN
        x_category_rec.category_id       := p_category_rec.category_id;
        x_category_rec.structure_id      := p_category_rec.structure_id;
        x_category_rec.structure_code    := p_category_rec.structure_code;
        x_category_rec.attribute_category:= p_category_rec.attribute_category;
        x_category_rec.description       := p_category_rec.description;
        x_category_rec.summary_flag      := p_category_rec.summary_flag;
        x_category_rec.enabled_flag      := p_category_rec.enabled_flag;
        x_category_rec.start_date_active := p_category_rec.start_date_active;
        x_category_rec.end_date_active   := p_category_rec.end_date_active;
        x_category_rec.disable_date      := p_category_rec.disable_date;
        x_category_rec.web_status        := p_category_rec.web_status;  --Bug: 2430879
        x_category_rec.supplier_enabled_flag := p_category_rec.supplier_enabled_flag;  --Bug: 2645153

        x_category_rec.segment1  := p_category_rec.segment1 ;
        x_category_rec.segment2  := p_category_rec.segment2 ;
        x_category_rec.segment3  := p_category_rec.segment3 ;
        x_category_rec.segment4  := p_category_rec.segment4 ;
        x_category_rec.segment5  := p_category_rec.segment5 ;
        x_category_rec.segment6  := p_category_rec.segment6 ;
        x_category_rec.segment7  := p_category_rec.segment7 ;
        x_category_rec.segment8  := p_category_rec.segment8 ;
        x_category_rec.segment9  := p_category_rec.segment9 ;
        x_category_rec.segment10 := p_category_rec.segment10;
        x_category_rec.segment11 := p_category_rec.segment11;
        x_category_rec.segment12 := p_category_rec.segment12;
        x_category_rec.segment13 := p_category_rec.segment13;
        x_category_rec.segment14 := p_category_rec.segment14;
        x_category_rec.segment15 := p_category_rec.segment15;
        x_category_rec.segment16 := p_category_rec.segment16;
        x_category_rec.segment17 := p_category_rec.segment17;
        x_category_rec.segment18 := p_category_rec.segment18;
        x_category_rec.segment19 := p_category_rec.segment19;
        x_category_rec.segment20 := p_category_rec.segment20;

        x_category_rec.attribute1  := p_category_rec.attribute1 ;
        x_category_rec.attribute2  := p_category_rec.attribute2 ;
        x_category_rec.attribute3  := p_category_rec.attribute3 ;
        x_category_rec.attribute4  := p_category_rec.attribute4 ;
        x_category_rec.attribute5  := p_category_rec.attribute5 ;
        x_category_rec.attribute6  := p_category_rec.attribute6 ;
        x_category_rec.attribute7  := p_category_rec.attribute7 ;
        x_category_rec.attribute8  := p_category_rec.attribute8 ;
        x_category_rec.attribute9  := p_category_rec.attribute9 ;
        x_category_rec.attribute10 := p_category_rec.attribute10;
        x_category_rec.attribute11 := p_category_rec.attribute11;
        x_category_rec.attribute12 := p_category_rec.attribute12;
        x_category_rec.attribute13 := p_category_rec.attribute13;
        x_category_rec.attribute14 := p_category_rec.attribute14;
        x_category_rec.attribute15 := p_category_rec.attribute15;

       /* Bug 5474569 Start Get structure_id of PRODUCT_CATEGORIES*/
        OPEN get_structure_id('PRODUCT_CATEGORIES');
        FETCH get_structure_id INTO l_product_str_id;

        IF (get_structure_id%NOTFOUND) THEN
             fnd_message.set_name('INV','FLEX-NO MAIN KEY FLEX DEF');
             fnd_message.set_token('ROUTINE', 'Preprocess_Category_Rec');
             fnd_msg_pub.ADD;
             IF (l_debug = 1) THEN
   		mdebug('ERR: No Product Categories structure');
		END IF;
                CLOSE  get_structure_id;
                RAISE fnd_api.g_EXC_UNEXPECTED_ERROR;
	     END IF;
        CLOSE  get_structure_id;
        /* Bug 5474569 End  */

        IF (p_operation = G_INSERT) THEN

/* The following code is not needed.
           IF  (x_category_rec.category_id = g_MISS_NUM OR
               x_category_rec.category_id IS NOT NULL) THEN
                 x_category_rec.category_id := NULL;
                 IF (l_debug = 1) THEN
                 mdebug('Ignoring the Category Id value for Insert');
                 END IF;
           END IF;
*/
           IF x_category_rec.description = g_MISS_CHAR THEN
              x_category_rec.description := NULL;
           END IF;

           IF (x_category_rec.structure_id = g_MISS_NUM OR
               x_category_rec.structure_id IS NULL) AND
              ( x_category_rec.structure_code = g_MISS_CHAR OR
               x_category_rec.structure_code IS NULL) THEN
                fnd_message.set_name('INV','INV_FLEX_STRUCTURE_REQ');
                fnd_msg_pub.ADD;
                IF (l_debug = 1) THEN
                mdebug('Flex Structure Information needed');
                END IF;
                RAISE fnd_api.g_EXC_UNEXPECTED_ERROR;
           END IF;

           IF (x_category_rec.structure_id = g_MISS_NUM OR
               x_category_rec.structure_id IS NULL) AND
              (x_category_rec.structure_code <> g_MISS_CHAR AND
                x_category_rec.structure_code IS NOT NULL) THEN
             OPEN get_structure_id(x_category_rec.structure_code);
             FETCH get_structure_id INTO x_category_rec.structure_id;
                IF (l_debug = 1) THEN
                mdebug('Flex Structure: '||To_char(x_category_rec.structure_id));
                END IF;

             IF (get_structure_id%NOTFOUND) THEN
                fnd_message.set_name('INV','FLEX-NO MAIN KEY FLEX DEF');
                fnd_message.set_token('ROUTINE', 'Preprocess_Category_Rec');
                fnd_msg_pub.ADD;
                IF (l_debug = 1) THEN
                mdebug('ERR: Invalid Flex Structure information provided');
                END IF;
                CLOSE  get_structure_id;
                RAISE fnd_api.g_EXC_UNEXPECTED_ERROR;
             END IF;
             CLOSE  get_structure_id;
           END IF;

           IF (x_category_rec.structure_id <> g_MISS_NUM AND
               x_category_rec.structure_id IS NOT NULL) THEN
             OPEN validate_structure_id(x_category_rec.structure_id);
             FETCH validate_structure_id INTO l_flexstr_exists;
             IF (validate_structure_id%NOTFOUND) THEN
                fnd_message.set_name('INV','FLEX-NO MAIN KEY FLEX DEF');
                fnd_message.set_token('ROUTINE', 'Preprocess_Category_Rec');
                fnd_msg_pub.ADD;
                IF (l_debug = 1) THEN
                mdebug('Invalid Flex Structure information provided');
                END IF;
                CLOSE  validate_structure_id;
                RAISE fnd_api.g_EXC_UNEXPECTED_ERROR;
             END IF;
             CLOSE  validate_structure_id;
           END IF;
--Bug: 2645153
           Validate_iProcurements_flags(x_category_rec);

           /* Bug 5474569 Start */
	     if (l_product_str_id <> x_category_rec.structure_id and
	         nvl(x_category_rec.summary_flag, 'N' ) = 'Y' ) then
                  fnd_message.set_name('INV','INV_CAT_SUM_FLAG_ERR');
                  fnd_msg_pub.ADD;
		  RAISE fnd_api.g_EXC_UNEXPECTED_ERROR;
	     end if;
           /* Bug 5474569 End */

           IF x_category_rec.attribute_category = g_MISS_CHAR THEN
              x_category_rec.attribute_category := NULL;
           END IF;

           IF x_category_rec.summary_flag = g_MISS_CHAR THEN
              x_category_rec.summary_flag := g_NO;
           END IF;

           IF x_category_rec.enabled_flag = g_MISS_CHAR THEN
              x_category_rec.enabled_flag := g_YES;
           END IF;

           IF x_category_rec.start_date_active = g_MISS_DATE THEN
              x_category_rec.start_date_active := NULL;
           END IF;

           IF x_category_rec.end_date_active = g_MISS_DATE THEN
              x_category_rec.end_date_active := NULL;
           END IF;

           IF x_category_rec.disable_date = g_MISS_DATE THEN
              x_category_rec.disable_date := NULL;
           END IF;
--Bug: 2430879 added if condition
/**
           IF x_category_rec.web_status = g_MISS_CHAR THEN
              x_category_rec.web_status := g_NO;
           END IF;
**/

           IF x_category_rec.segment1 = g_MISS_CHAR THEN
              x_category_rec.segment1 := NULL;
           END IF;

           IF x_category_rec.segment2 = g_MISS_CHAR THEN
              x_category_rec.segment2 := NULL;
           END IF;

           IF x_category_rec.segment3 = g_MISS_CHAR THEN
              x_category_rec.segment3 := NULL;
           END IF;

           IF x_category_rec.segment4 = g_MISS_CHAR THEN
              x_category_rec.segment4 := NULL;
           END IF;

           IF x_category_rec.segment5 = g_MISS_CHAR THEN
              x_category_rec.segment5 := NULL;
           END IF;

           IF x_category_rec.segment6 = g_MISS_CHAR THEN
              x_category_rec.segment6 := NULL;
           END IF;

           IF x_category_rec.segment7 = g_MISS_CHAR THEN
              x_category_rec.segment7 := NULL;
           END IF;

           IF x_category_rec.segment8 = g_MISS_CHAR THEN
              x_category_rec.segment8 := NULL;
           END IF;

           IF x_category_rec.segment9 = g_MISS_CHAR THEN
              x_category_rec.segment9 := NULL;
           END IF;

           IF x_category_rec.segment10 = g_MISS_CHAR THEN
              x_category_rec.segment10 := NULL;
           END IF;

           IF x_category_rec.segment11 = g_MISS_CHAR THEN
              x_category_rec.segment11 := NULL;
           END IF;

           IF x_category_rec.segment12 = g_MISS_CHAR THEN
              x_category_rec.segment12 := NULL;
           END IF;

           IF x_category_rec.segment13 = g_MISS_CHAR THEN
              x_category_rec.segment13 := NULL;
           END IF;

           IF x_category_rec.segment14 = g_MISS_CHAR THEN
              x_category_rec.segment14 := NULL;
           END IF;

           IF x_category_rec.segment15 = g_MISS_CHAR THEN
              x_category_rec.segment15 := NULL;
           END IF;

           IF x_category_rec.segment16 = g_MISS_CHAR THEN
              x_category_rec.segment16 := NULL;
           END IF;

           IF x_category_rec.segment17 = g_MISS_CHAR THEN
              x_category_rec.segment17 := NULL;
           END IF;

           IF x_category_rec.segment18 = g_MISS_CHAR THEN
              x_category_rec.segment18 := NULL;
           END IF;

           IF x_category_rec.segment19 = g_MISS_CHAR THEN
              x_category_rec.segment19 := NULL;
           END IF;

           IF x_category_rec.segment20 = g_MISS_CHAR THEN
              x_category_rec.segment20 := NULL;
           END IF;

           IF x_category_rec.attribute1 = g_MISS_CHAR THEN
              x_category_rec.attribute1 := NULL;
           END IF;

           IF x_category_rec.attribute2 = g_MISS_CHAR THEN
              x_category_rec.attribute2 := NULL;
           END IF;

           IF x_category_rec.attribute3 = g_MISS_CHAR THEN
              x_category_rec.attribute3 := NULL;
           END IF;

           IF x_category_rec.attribute4 = g_MISS_CHAR THEN
              x_category_rec.attribute4 := NULL;
           END IF;

           IF x_category_rec.attribute5 = g_MISS_CHAR THEN
              x_category_rec.attribute5 := NULL;
           END IF;

           IF x_category_rec.attribute6 = g_MISS_CHAR THEN
              x_category_rec.attribute6 := NULL;
           END IF;

           IF x_category_rec.attribute7 = g_MISS_CHAR THEN
              x_category_rec.attribute7 := NULL;
           END IF;

           IF x_category_rec.attribute8 = g_MISS_CHAR THEN
              x_category_rec.attribute8 := NULL;
           END IF;

           IF x_category_rec.attribute9 = g_MISS_CHAR THEN
              x_category_rec.attribute9 := NULL;
           END IF;

           IF x_category_rec.attribute10 = g_MISS_CHAR THEN
              x_category_rec.attribute10 := NULL;
           END IF;

           IF x_category_rec.attribute11 = g_MISS_CHAR THEN
              x_category_rec.attribute11 := NULL;
           END IF;

           IF x_category_rec.attribute12 = g_MISS_CHAR THEN
              x_category_rec.attribute12 := NULL;
           END IF;

           IF x_category_rec.attribute13 = g_MISS_CHAR THEN
              x_category_rec.attribute13 := NULL;
           END IF;

           IF x_category_rec.attribute14 = g_MISS_CHAR THEN
              x_category_rec.attribute14 := NULL;
           END IF;

           IF x_category_rec.attribute15 = g_MISS_CHAR THEN
              x_category_rec.attribute15 := NULL;
           END IF;

        END IF;  --IF (p_operation = G_INSERT) THEN

        -- Update operation.
        IF (p_operation = G_UPDATE) THEN

           IF (x_category_rec.category_id = g_MISS_NUM OR
               x_category_rec.category_id IS NULL) THEN
                 fnd_message.set_name('INV','INV_NO_CATEGORY');
                 fnd_msg_pub.ADD;
                 IF (l_debug = 1) THEN
                 mdebug('Category Id needed for Update');
                 END IF;
                RAISE fnd_api.g_EXC_UNEXPECTED_ERROR;
           END IF;

           IF (x_category_rec.structure_id = g_MISS_NUM OR
               x_category_rec.structure_id IS NULL) AND
              ( x_category_rec.structure_code = g_MISS_CHAR OR
               x_category_rec.structure_code IS NULL) THEN
             OPEN get_category_structure_id(x_category_rec.category_id);
             FETCH get_category_structure_id INTO x_category_rec.structure_id;
             IF (get_category_structure_id%NOTFOUND) THEN
                fnd_message.set_name('INV','FLEX-NO MAIN KEY FLEX DEF');
                fnd_message.set_token('ROUTINE', 'Preprocess_Category_Rec');
                fnd_msg_pub.ADD;
                IF (l_debug = 1) THEN
                mdebug('Invalid Flex Structure information provided');
                END IF;
                CLOSE  get_category_structure_id;
                RAISE fnd_api.g_EXC_UNEXPECTED_ERROR;
             END IF;
             CLOSE  get_category_structure_id;
/*
                fnd_message.set_name('INV','INV_FLEX_STRUCTURE_REQ');
                fnd_msg_pub.ADD;
                IF (l_debug = 1) THEN
                mdebug('Flex Structure Information needed');
                END IF;
                RAISE fnd_api.g_EXC_UNEXPECTED_ERROR;
*/
           END IF;

           IF (x_category_rec.structure_id = g_MISS_NUM OR
               x_category_rec.structure_id IS NULL) AND
              (x_category_rec.structure_code <> g_MISS_CHAR OR
                x_category_rec.structure_code IS NOT NULL) THEN
             OPEN get_structure_id(x_category_rec.structure_code);
             FETCH get_structure_id INTO x_category_rec.structure_id;
             IF (get_structure_id%NOTFOUND) THEN
                fnd_message.set_name('INV','FLEX-NO MAIN KEY FLEX DEF');
                fnd_message.set_token('ROUTINE', 'Preprocess_Category_Rec');
                fnd_msg_pub.ADD;
                IF (l_debug = 1) THEN
                mdebug('Invalid Flex Structure information provided');
                END IF;
                RAISE fnd_api.g_EXC_UNEXPECTED_ERROR;
             END IF;
             CLOSE  get_structure_id;
           END IF;

--Bug: 2645153
           Validate_iProcurements_flags(x_category_rec);

           /* Bug 5474569 Start */
	     if (l_product_str_id <> x_category_rec.structure_id and
	         nvl(x_category_rec.summary_flag, 'N' ) = 'Y' ) then
                  fnd_message.set_name('INV','INV_CAT_SUM_FLAG_ERR');
                  fnd_msg_pub.ADD;
                  RAISE fnd_api.g_EXC_UNEXPECTED_ERROR;
	     end if;
           /* Bug 5474569 End */

           /* Before further processing we get the info. from Database */
             OPEN category_rec_cursor(x_category_rec.category_id);
             FETCH category_rec_cursor INTO
                l_category_rec.description,
                l_category_rec.attribute_category,
                l_category_rec.summary_flag,
                l_category_rec.enabled_flag,
                l_category_rec.start_date_active,
                l_category_rec.end_date_active,
                l_category_rec.disable_date,
                l_category_rec.web_status,--Bug: 2430879 5134913
                l_category_rec.supplier_enabled_flag,--Bug: 2645153 5134913
                l_category_rec.segment1,
                l_category_rec.segment2,
                l_category_rec.segment3,
                l_category_rec.segment4,
                l_category_rec.segment5,
                l_category_rec.segment6,
                l_category_rec.segment7,
                l_category_rec.segment8,
                l_category_rec.segment9,
                l_category_rec.segment10,
                l_category_rec.segment11,
                l_category_rec.segment12,
                l_category_rec.segment13,
                l_category_rec.segment14,
                l_category_rec.segment15,
                l_category_rec.segment16,
                l_category_rec.segment17,
                l_category_rec.segment18,
                l_category_rec.segment19,
                l_category_rec.segment20,
                l_category_rec.attribute1,
                l_category_rec.attribute2,
                l_category_rec.attribute3,
                l_category_rec.attribute4,
                l_category_rec.attribute5,
                l_category_rec.attribute6,
                l_category_rec.attribute7,
                l_category_rec.attribute8,
                l_category_rec.attribute9,
                l_category_rec.attribute10,
                l_category_rec.attribute11,
                l_category_rec.attribute12,
                l_category_rec.attribute13,
                l_category_rec.attribute14,
                l_category_rec.attribute15;

             IF (category_rec_cursor%NOTFOUND) THEN
                fnd_message.set_name('INV','INV_VALID_CAT');
                fnd_msg_pub.ADD;
                IF (l_debug = 1) THEN
                mdebug('Invalid Category Id provided');
                END IF;
                CLOSE category_rec_cursor;
                RAISE fnd_api.g_EXC_UNEXPECTED_ERROR;
             END IF;
             CLOSE category_rec_cursor;

           IF x_category_rec.description = g_MISS_CHAR THEN
              x_category_rec.description := l_category_rec.description;
           END IF;

           IF x_category_rec.attribute_category = g_MISS_CHAR THEN
              x_category_rec.attribute_category := l_category_rec.attribute_category;
           END IF;

           IF x_category_rec.summary_flag = g_MISS_CHAR THEN
              x_category_rec.summary_flag := l_category_rec.summary_flag;
           END IF;

           IF x_category_rec.enabled_flag = g_MISS_CHAR THEN
              x_category_rec.enabled_flag := l_category_rec.enabled_flag;
           END IF;

           IF x_category_rec.start_date_active = g_MISS_DATE THEN
              x_category_rec.start_date_active := l_category_rec.start_date_active;
           END IF;

           IF x_category_rec.end_date_active = g_MISS_DATE THEN
              x_category_rec.end_date_active := l_category_rec.end_date_active;
           END IF;

           IF x_category_rec.disable_date = g_MISS_DATE THEN
              x_category_rec.disable_date := l_category_rec.disable_date;
           END IF;
/*Bug: 4494727 Commenting out the following IF condition
--Bug: 2430879 Added If condition
           IF x_category_rec.web_status = g_MISS_CHAR THEN
              x_category_rec.web_status := l_category_rec.web_status;
           END IF;
--Bug: 2645153 Added If condition
*/
           IF x_category_rec.supplier_enabled_flag = g_MISS_CHAR THEN
              x_category_rec.supplier_enabled_flag := l_category_rec.supplier_enabled_flag;
           END IF;

           IF x_category_rec.segment1 = g_MISS_CHAR THEN
              x_category_rec.segment1 := l_category_rec.segment1;
           END IF;

           IF x_category_rec.segment2 = g_MISS_CHAR THEN
              x_category_rec.segment2 := l_category_rec.segment2;
           END IF;

           IF x_category_rec.segment3 = g_MISS_CHAR THEN
              x_category_rec.segment3 := l_category_rec.segment3;
           END IF;

           IF x_category_rec.segment4 = g_MISS_CHAR THEN
              x_category_rec.segment4 := l_category_rec.segment4;
           END IF;

           IF x_category_rec.segment5 = g_MISS_CHAR THEN
              x_category_rec.segment5 := l_category_rec.segment5;
           END IF;

           IF x_category_rec.segment6 = g_MISS_CHAR THEN
              x_category_rec.segment6 := l_category_rec.segment6;
           END IF;

           IF x_category_rec.segment7 = g_MISS_CHAR THEN
              x_category_rec.segment7 := l_category_rec.segment7;
           END IF;

           IF x_category_rec.segment8 = g_MISS_CHAR THEN
              x_category_rec.segment8 := l_category_rec.segment8;
           END IF;

           IF x_category_rec.segment9 = g_MISS_CHAR THEN
              x_category_rec.segment9 := l_category_rec.segment9;
           END IF;

           IF x_category_rec.segment10 = g_MISS_CHAR THEN
              x_category_rec.segment10 := l_category_rec.segment10;
           END IF;

           IF x_category_rec.segment11 = g_MISS_CHAR THEN
              x_category_rec.segment11 := l_category_rec.segment11;
           END IF;

           IF x_category_rec.segment12 = g_MISS_CHAR THEN
              x_category_rec.segment12 := l_category_rec.segment12;
           END IF;

           IF x_category_rec.segment13 = g_MISS_CHAR THEN
              x_category_rec.segment13 := l_category_rec.segment13;
           END IF;

           IF x_category_rec.segment14 = g_MISS_CHAR THEN
              x_category_rec.segment14 := l_category_rec.segment14;
           END IF;

           IF x_category_rec.segment15 = g_MISS_CHAR THEN
              x_category_rec.segment15 := l_category_rec.segment15;
           END IF;

           IF x_category_rec.segment16 = g_MISS_CHAR THEN
              x_category_rec.segment16 := l_category_rec.segment16;
           END IF;

           IF x_category_rec.segment17 = g_MISS_CHAR THEN
              x_category_rec.segment17 := l_category_rec.segment17;
           END IF;

           IF x_category_rec.segment18 = g_MISS_CHAR THEN
              x_category_rec.segment18 := l_category_rec.segment18;
           END IF;

           IF x_category_rec.segment19 = g_MISS_CHAR THEN
              x_category_rec.segment19 := l_category_rec.segment19;
           END IF;

           IF x_category_rec.segment20 = g_MISS_CHAR THEN
              x_category_rec.segment20 := l_category_rec.segment20;
           END IF;

           IF x_category_rec.attribute1 = g_MISS_CHAR THEN
              x_category_rec.attribute1 := l_category_rec.attribute1;
           END IF;

           IF x_category_rec.attribute2 = g_MISS_CHAR THEN
              x_category_rec.attribute2 := l_category_rec.attribute2;
           END IF;

           IF x_category_rec.attribute3 = g_MISS_CHAR THEN
              x_category_rec.attribute3 := l_category_rec.attribute3;
           END IF;

           IF x_category_rec.attribute4 = g_MISS_CHAR THEN
              x_category_rec.attribute4 := l_category_rec.attribute4;
           END IF;

           IF x_category_rec.attribute5 = g_MISS_CHAR THEN
              x_category_rec.attribute5 := l_category_rec.attribute5;
           END IF;

           IF x_category_rec.attribute6 = g_MISS_CHAR THEN
              x_category_rec.attribute6 := l_category_rec.attribute6;
           END IF;

           IF x_category_rec.attribute7 = g_MISS_CHAR THEN
              x_category_rec.attribute7 := l_category_rec.attribute7;
           END IF;

           IF x_category_rec.attribute8 = g_MISS_CHAR THEN
              x_category_rec.attribute8 := l_category_rec.attribute8;
           END IF;

           IF x_category_rec.attribute9 = g_MISS_CHAR THEN
              x_category_rec.attribute9 := l_category_rec.attribute9;
           END IF;

           IF x_category_rec.attribute10 = g_MISS_CHAR THEN
              x_category_rec.attribute10 := l_category_rec.attribute10;
           END IF;

           IF x_category_rec.attribute11 = g_MISS_CHAR THEN
              x_category_rec.attribute11 := l_category_rec.attribute11;
           END IF;

           IF x_category_rec.attribute12 = g_MISS_CHAR THEN
              x_category_rec.attribute12 := l_category_rec.attribute12;
           END IF;

           IF x_category_rec.attribute13 = g_MISS_CHAR THEN
              x_category_rec.attribute13 := l_category_rec.attribute13;
           END IF;

           IF x_category_rec.attribute14 = g_MISS_CHAR THEN
              x_category_rec.attribute14 := l_category_rec.attribute14;
           END IF;

           IF x_category_rec.attribute15 = g_MISS_CHAR THEN
              x_category_rec.attribute15 := l_category_rec.attribute15;
           END IF;

        END IF;  --IF (p_operation = G_UPDATE) THEN


  END Preprocess_Category_Rec;

  PROCEDURE ValueSet_Validate
  (
   p_structure_id        IN   NUMBER,
   p_concat_segs         IN   VARCHAR2
   ) IS
     l_success BOOLEAN;
     l_trim_str VARCHAR2(2000) ;
     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

  BEGIN
    l_success  :=   fnd_flex_keyval.validate_segs(
                 operation  => 'CHECK_SEGMENTS',
                 appl_short_name => G_INVENTORY_APP_SHORT_NAME,
                 key_flex_code => G_CAT_FLEX_CODE,
                 structure_number => p_structure_id,
                 concat_segments => p_concat_segs
                 );
--Bug: 2445444 modified If condition
        IF (l_success OR
            ( NOT l_success AND
             (INSTR(FND_FLEX_KEYVAL.error_message,'has been disabled.')> 0 OR
              INSTR(FND_FLEX_KEYVAL.error_message,'has expired.')> 0 OR
              INSTR(FND_FLEX_KEYVAL.error_message,'This combination is disabled')>0))) THEN
       NULL;
    ELSE
       l_trim_str := FND_FLEX_KEYVAL.error_message;
       fnd_message.set_name('FND','FLEX-SSV EXCEPTION');
       fnd_message.set_token('MSG', 'Value set validation error in ValueSet_Validate()');
       fnd_msg_pub.ADD;
       IF (l_debug = 1) THEN
          mdebug('ValueSet Validation Error : '||l_trim_str);
       END IF;

       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END ValueSet_Validate;

   ----------------------------------------------------------------------------
  PROCEDURE Flex_Validate
  (
   p_operation        IN   NUMBER,
   p_category_rec     IN  INV_ITEM_CATEGORY_PUB.CATEGORY_REC_TYPE
   ) IS
     l_category_id NUMBER;
     l_structure_id NUMBER;
     l_success BOOLEAN;
     l_concat_segs VARCHAR2(2000) ;
     l_n_segments NUMBER ;
     l_segment_array FND_FLEX_EXT.SegmentArray;
     l_delim VARCHAR2(10);
     l_indx        NUMBER;

     CURSOR segment_count(p_structure_id NUMBER) IS
        SELECT count(segment_num)
        FROM fnd_id_flex_segments
        WHERE application_id = G_INVENTORY_APP_ID
        AND id_flex_code = G_CAT_FLEX_CODE
        AND id_flex_num = p_structure_id
        AND (enabled_flag = 'Y' OR NVL(g_eni_upgarde_flag,'N') = 'Y');-- Added for 11.5.10 ENI Upgrade

     --Bug: 3893482
     CURSOR c_get_segments(cp_flex_num NUMBER) IS
        SELECT application_column_name,rownum
        FROM   fnd_id_flex_segments
        WHERE  application_id = 401
          AND  id_flex_code   = 'MCAT'
          AND  id_flex_num    = cp_flex_num
          AND  enabled_flag   = 'Y'
        ORDER BY segment_num ASC;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
        l_structure_id := p_category_rec.structure_id;

        OPEN segment_count(l_structure_id);
        FETCH segment_count INTO l_n_segments;
        IF (segment_count%NOTFOUND) THEN
           IF (l_debug = 1) THEN
              mdebug('The Number of segments not found');
           END IF;
        END IF;
        CLOSE segment_count;
        IF (l_debug = 1) THEN
        mdebug('Tracing....4');
        END IF;


        l_delim  := fnd_flex_ext.get_delimiter(G_INVENTORY_APP_SHORT_NAME,
                                               G_CAT_FLEX_CODE,
                                               l_structure_id);
        IF l_delim is NULL then
           fnd_message.set_name('OFA','FA_BUDGET_NO_SEG_DELIM');
           fnd_msg_pub.ADD;
           IF (l_debug = 1) THEN
           mdebug('Delimiter is NULL...Error');
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        --Start: 3893482
        l_indx := 1;
        FOR c_segments in c_get_segments(l_structure_id) LOOP
          IF c_segments.application_column_name = 'SEGMENT1' THEN
             l_segment_array(l_indx):= p_category_rec.segment1;
          ELSIF c_segments.application_column_name = 'SEGMENT2' THEN
             l_segment_array(l_indx):= p_category_rec.segment2;
          ELSIF c_segments.application_column_name = 'SEGMENT3' THEN
             l_segment_array(l_indx):= p_category_rec.segment3;
          ELSIF c_segments.application_column_name = 'SEGMENT4' THEN
             l_segment_array(l_indx):= p_category_rec.segment4;
          ELSIF c_segments.application_column_name = 'SEGMENT5' THEN
             l_segment_array(l_indx):= p_category_rec.segment5;
          ELSIF c_segments.application_column_name = 'SEGMENT6' THEN
             l_segment_array(l_indx):= p_category_rec.segment6;
          ELSIF c_segments.application_column_name = 'SEGMENT7' THEN
             l_segment_array(l_indx):= p_category_rec.segment7;
          ELSIF c_segments.application_column_name = 'SEGMENT8' THEN
             l_segment_array(l_indx):= p_category_rec.segment8;
          ELSIF c_segments.application_column_name = 'SEGMENT9' THEN
             l_segment_array(l_indx):= p_category_rec.segment9;
          ELSIF c_segments.application_column_name = 'SEGMENT10' THEN
             l_segment_array(l_indx):= p_category_rec.segment10;
          ELSIF c_segments.application_column_name = 'SEGMENT11' THEN
             l_segment_array(l_indx):= p_category_rec.segment11;
          ELSIF c_segments.application_column_name = 'SEGMENT12' THEN
             l_segment_array(l_indx):= p_category_rec.segment12;
          ELSIF c_segments.application_column_name = 'SEGMENT13' THEN
             l_segment_array(l_indx):= p_category_rec.segment13;
          ELSIF c_segments.application_column_name = 'SEGMENT14' THEN
             l_segment_array(l_indx):= p_category_rec.segment14;
          ELSIF c_segments.application_column_name = 'SEGMENT15' THEN
             l_segment_array(l_indx):= p_category_rec.segment15;
          ELSIF c_segments.application_column_name = 'SEGMENT16' THEN
             l_segment_array(l_indx):= p_category_rec.segment16;
          ELSIF c_segments.application_column_name = 'SEGMENT17' THEN
             l_segment_array(l_indx):= p_category_rec.segment17;
          ELSIF c_segments.application_column_name = 'SEGMENT18' THEN
             l_segment_array(l_indx):= p_category_rec.segment18;
          ELSIF c_segments.application_column_name = 'SEGMENT19' THEN
             l_segment_array(l_indx):= p_category_rec.segment19;
          ELSIF c_segments.application_column_name = 'SEGMENT20' THEN
             l_segment_array(l_indx):= p_category_rec.segment20;
          END IF;
          l_indx := l_indx+1;
        END LOOP;
        --End: 3893482

        /*
        l_segment_array(1) := p_category_rec.segment1 ;
        l_segment_array(2) := p_category_rec.segment2 ;
        l_segment_array(3) := p_category_rec.segment3 ;
        l_segment_array(4) := p_category_rec.segment4 ;
        l_segment_array(5) := p_category_rec.segment5 ;
        l_segment_array(6) := p_category_rec.segment6 ;
        l_segment_array(7) := p_category_rec.segment7 ;
        l_segment_array(8) := p_category_rec.segment8 ;
        l_segment_array(9) := p_category_rec.segment9 ;
        l_segment_array(10):= p_category_rec.segment10;
        l_segment_array(11):= p_category_rec.segment11;
        l_segment_array(12):= p_category_rec.segment12;
        l_segment_array(13):= p_category_rec.segment13;
        l_segment_array(14):= p_category_rec.segment14;
        l_segment_array(15):= p_category_rec.segment15;
        l_segment_array(16):= p_category_rec.segment16;
        l_segment_array(17):= p_category_rec.segment17;
        l_segment_array(18):= p_category_rec.segment18;
        l_segment_array(19):= p_category_rec.segment19;
        l_segment_array(20):= p_category_rec.segment20;
        */

        IF (l_debug = 1) THEN
        mdebug('Tracing....5');
        END IF;


        l_concat_segs :=fnd_flex_ext.concatenate_segments(l_n_segments,
                                                          l_segment_array,
                                                          l_delim);

        IF (l_debug = 1) THEN
        mdebug('Delim       : '||l_delim);
        mdebug('Flex code   : '||G_CAT_FLEX_CODE);
        mdebug('struct#     : '||l_structure_id);
        mdebug('# of segs   : '||to_char(l_n_segments));
        mdebug('Concat segs : '||l_concat_segs);
        END IF;

        l_success  :=   fnd_flex_keyval.validate_segs(
                                operation  => 'FIND_COMBINATION',
                                appl_short_name => G_INVENTORY_APP_SHORT_NAME,
                                key_flex_code => G_CAT_FLEX_CODE,
                                structure_number => l_structure_id,
                                concat_segments => l_concat_segs
                                );
--Bug: 2445444 modified If condition
        IF (l_success OR
            ( NOT l_success AND
             (INSTR(FND_FLEX_KEYVAL.error_message,'has been disabled.')> 0 OR
              INSTR(FND_FLEX_KEYVAL.error_message,'has expired.')> 0 OR
              INSTR(FND_FLEX_KEYVAL.error_message,'This combination is disabled')> 0
             )
           AND (p_operation = G_UPDATE))) THEN
           IF (p_operation = G_INSERT) THEN

               fnd_message.set_name('INV','INV_NEW_ENT');
               fnd_message.set_token('TOKEN', 'Category Segment Combination');
               fnd_msg_pub.ADD;
               IF (l_debug = 1) THEN
               mdebug('CCID already exists => '|| To_char(FND_FLEX_KEYVAL.combination_id));
               END IF;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

           ELSIF (p_operation = G_UPDATE) THEN
              IF (FND_FLEX_KEYVAL.combination_id <>
                                   p_category_rec.category_id) THEN
                fnd_message.set_name('INV','INV_NEW_ENT');
                fnd_message.set_token('TOKEN', 'Category segment combination. Specified Combination used by another Category.');
                fnd_msg_pub.ADD;
                IF (l_debug = 1) THEN
                   mdebug( 'Code combination already used for another category');
                END IF;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSE
                 ValueSet_Validate(l_structure_id, l_concat_segs);
                 IF (l_debug = 1) THEN
                 mdebug('Updating CCID/Category_Id  => '|| To_char(FND_FLEX_KEYVAL.combination_id));
                 END IF;
              END IF;
           ELSE -- neither insert nor update
              NULL;
           END IF;
       ELSE -- (l_success = FALSE)
           IF (p_operation = G_INSERT) THEN
               ValueSet_Validate(l_structure_id, l_concat_segs);
               IF (l_debug = 1) THEN
               mdebug('Combination new. Creating Category....');
               END IF;

              /* -------------------------------------------------------
               The COMBINATION need not be created using this.
               Calling procedure will take care of inserting record.
               Since the COMBINATION_ID is Category_Id, just verifying if the
               comb. exists through fnd_flex_keyval.validate_segs(FIND_COMB..)
               call and inserting directly in database through Table Handler
               would be enough. The folllowing could be used as alternative.

               l_success  :=   fnd_flex_keyval.validate_segs(
                               operation  => 'CREATE_COMBINATION',
                               appl_short_name => G_INVENTORY_APP_SHORT_NAME,
                               key_flex_code => G_CAT_FLEX_CODE,
                               structure_number => l_structure_id,
                               concat_segments => l_concat_segs
                               );
               IF (l_debug = 1) THEN
               mdebug('The CCID : '||To_char(FND_FLEX_KEYVAL.combination_id));
               mdebug('Error : '||FND_FLEX_KEYVAL.error_message);
               END IF;
               --------------------------------------------------------- */

           ELSIF (p_operation = G_UPDATE) THEN
              fnd_message.set_name('INV','INV_VALID_CAT');
              fnd_msg_pub.ADD;
              IF (l_debug = 1) THEN
              mdebug('Trying to update a non-existant ROW');
              END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

           ELSE -- neither insert nor update
              NULL;
           END IF;
      END IF;

          --mdebug('Error : '||FND_FLEX_KEYVAL.error_message);
  END Flex_Validate;

  -- 1. Create_Category
  ----------------------------------------------------------------------------
  PROCEDURE Create_Category
  (
    p_api_version      IN   NUMBER ,
    p_init_msg_list    IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit           IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status    OUT  NOCOPY VARCHAR2 ,
    x_errorcode        OUT  NOCOPY NUMBER,
    x_msg_count        OUT  NOCOPY NUMBER ,
    x_msg_data         OUT  NOCOPY VARCHAR2 ,
    p_category_rec     IN  INV_ITEM_CATEGORY_PUB.CATEGORY_REC_TYPE,
    x_category_id      OUT   NOCOPY NUMBER
  )
  IS
    -- Start OF comments
    -- API name  : Create_Category
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Create a category.
    --
    -- Version: Current Version 0.1
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments

     l_api_name              CONSTANT VARCHAR2(30)      := 'Create_Category';
     -- On addition of any Required parameters the major version needs
     -- to change i.e. for eg. 1.X to 2.X.
     -- On addition of any Optional parameters the minor version needs
     -- to change i.e. for eg. X.6 to X.7.

     l_api_version           CONSTANT NUMBER    := 1.0;
     l_row_count             NUMBER;

     -- General variables
     l_category_rec     INV_ITEM_CATEGORY_PUB.category_rec_type;
     l_category_id NUMBER;
     l_success BOOLEAN; --boolean for descr. flex valiation
     l_row_id VARCHAR2(20);
     l_sys_date DATE := Sysdate;

     CURSOR new_category_id IS
        SELECT mtl_categories_s.nextval
        FROM dual;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT       Create_Category_PUB;

        -- Check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (l_api_version,
                                            p_api_version,
                                            l_api_name,
                                            G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- Initialize API message list if necessary.
        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;

        IF (l_debug = 1) THEN
        mdebug('Tracing....1');
        END IF;

        -- To set the APPS Environment context through PL/SQL.
        -- Apps_Initialize();

        -- To process the Input record for any invalid values provided.
        Preprocess_Category_Rec(G_INSERT, p_category_rec, l_category_rec) ;
        Flex_Validate(G_INSERT, l_category_rec);

        -- Category_Id is always created from sequence.
        OPEN new_category_id;
        FETCH new_category_id INTO l_category_id;
        IF (new_category_id%NOTFOUND) THEN
           IF (l_debug = 1) THEN
              mdebug('Dubious error with the MTL_CATEGORIES_S sequence');
           END IF;
        END IF;
        CLOSE new_category_id;

        /* Need for Descriptive Flex validation

        l_attribute_category := l_category_rec.attribute_category;
        l_attribute1  := l_category_rec.attribute1 ;
        l_attribute2  := l_category_rec.attribute2 ;
        l_attribute3  := l_category_rec.attribute3 ;
        l_attribute4  := l_category_rec.attribute4 ;
        l_attribute5  := l_category_rec.attribute5 ;
        l_attribute6  := l_category_rec.attribute6 ;
        l_attribute7  := l_category_rec.attribute7 ;
        l_attribute8  := l_category_rec.attribute8 ;
        l_attribute9  := l_category_rec.attribute9 ;
        l_attribute10 := l_category_rec.attribute10;
        l_attribute11 := l_category_rec.attribute11;
        l_attribute12 := l_category_rec.attribute12;
        l_attribute13 := l_category_rec.attribute13;
        l_attribute14 := l_category_rec.attribute14;
        l_attribute15 := l_category_rec.attribute15;
         */

          --Final call for insertion.
            MTL_CATEGORIES_PKG.Insert_Row(
              X_ROWID                =>   l_row_id,   -- OUT variable
              X_CATEGORY_ID          =>   l_category_id, -- gen from seq.
              X_DESCRIPTION          =>   l_category_rec.description,
              X_STRUCTURE_ID         =>   l_category_rec.structure_id,
              X_DISABLE_DATE         =>   l_category_rec.disable_date,
              X_WEB_STATUS           =>   l_category_rec.web_status,--Bug: 2430879
              X_SUPPLIER_ENABLED_FLAG =>  l_category_rec.supplier_enabled_flag,--Bug: 2645153
              X_SEGMENT1             =>   l_category_rec.segment1 ,
              X_SEGMENT2             =>   l_category_rec.segment2 ,
              X_SEGMENT3             =>   l_category_rec.segment3 ,
              X_SEGMENT4             =>   l_category_rec.segment4 ,
              X_SEGMENT5             =>   l_category_rec.segment5 ,
              X_SEGMENT6             =>   l_category_rec.segment6 ,
              X_SEGMENT7             =>   l_category_rec.segment7 ,
              X_SEGMENT8             =>   l_category_rec.segment8 ,
              X_SEGMENT9             =>   l_category_rec.segment9 ,
              X_SEGMENT10            =>   l_category_rec.segment10 ,
              X_SEGMENT11            =>   l_category_rec.segment11 ,
              X_SEGMENT12            =>   l_category_rec.segment12 ,
              X_SEGMENT13            =>   l_category_rec.segment13 ,
              X_SEGMENT14            =>   l_category_rec.segment14 ,
              X_SEGMENT15            =>   l_category_rec.segment15 ,
              X_SEGMENT16            =>   l_category_rec.segment16 ,
              X_SEGMENT17            =>   l_category_rec.segment17 ,
              X_SEGMENT18            =>   l_category_rec.segment18 ,
              X_SEGMENT19            =>   l_category_rec.segment19 ,
              X_SEGMENT20            =>   l_category_rec.segment20 ,
              X_SUMMARY_FLAG         =>   l_category_rec.summary_flag,
              X_ENABLED_FLAG         =>   l_category_rec.enabled_flag,
              X_START_DATE_ACTIVE    =>   l_category_rec.start_date_active,
              X_END_DATE_ACTIVE      =>   l_category_rec.end_date_active,
              X_ATTRIBUTE_CATEGORY   =>   l_category_rec.attribute_category,
              X_ATTRIBUTE1           =>   l_category_rec.attribute1 ,
              X_ATTRIBUTE2           =>   l_category_rec.attribute2 ,
              X_ATTRIBUTE3           =>   l_category_rec.attribute3 ,
              X_ATTRIBUTE4           =>   l_category_rec.attribute4 ,
              X_ATTRIBUTE5           =>   l_category_rec.attribute5 ,
              X_ATTRIBUTE6           =>   l_category_rec.attribute6 ,
              X_ATTRIBUTE7           =>   l_category_rec.attribute7 ,
              X_ATTRIBUTE8           =>   l_category_rec.attribute8 ,
              X_ATTRIBUTE9           =>   l_category_rec.attribute9 ,
              X_ATTRIBUTE10          =>   l_category_rec.attribute10,
              X_ATTRIBUTE11          =>   l_category_rec.attribute11,
              X_ATTRIBUTE12          =>   l_category_rec.attribute12,
              X_ATTRIBUTE13          =>   l_category_rec.attribute13,
              X_ATTRIBUTE14          =>   l_category_rec.attribute14,
              X_ATTRIBUTE15          =>   l_category_rec.attribute15,
              X_LAST_UPDATE_DATE     =>   l_sys_date,
              X_LAST_UPDATED_BY      =>   fnd_global.user_id,
              X_CREATION_DATE        =>   l_sys_date,
              X_CREATED_BY           =>   fnd_global.user_id,
              X_LAST_UPDATE_LOGIN    =>   fnd_global.login_id
              );

              IF (l_debug = 1) THEN
              mdebug('Created New CCID/Category_ID : '|| l_category_id);
              END IF;
              -- assigning the created value to the return OUT value
              x_category_id := l_category_id;

          IF (l_debug = 1) THEN
          mdebug('Tracing....10');
          END IF;

        -- Standard check of p_commit.
        IF FND_API.To_Boolean( p_commit ) THEN
                COMMIT WORK;
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;
        -- Standard call to get message count and if count is 1,
        -- get message info.
        -- The client will directly display the x_msg_data (which is already
        -- translated) if the x_msg_count = 1;
        -- Else i.e if  x_msg_count > 1, client will call the FND_MSG_PUB.Get
        -- Server-side procedure to access the messages, and consolidate them
        -- and display (or) to display one message after another.
        IF (l_debug = 1) THEN
        mdebug('Tracing....11');
        END IF;
        FND_MSG_PUB.Count_And_Get
                (       p_count        =>      x_msg_count,
                        p_data         =>      x_msg_data
                );
    EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
         IF (l_debug = 1) THEN
            mdebug('Ending : Returning ERROR');
         END IF;
                ROLLBACK TO Create_Category_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get
                (       p_count        =>      x_msg_count,
                        p_data         =>      x_msg_data
                );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO Create_Category_PUB;
       IF (l_debug = 1) THEN
          mdebug('Ending : Returning UNEXPECTED ERROR');
       END IF;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count        =>      x_msg_count,
                        p_data         =>      x_msg_data
                );
        WHEN OTHERS THEN
                ROLLBACK TO Create_Category_PUB;
       IF (l_debug = 1) THEN
          mdebug('Ending : Returning UNEXPECTED ERROR');
       END IF;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                        FND_MSG_PUB.Add_Exc_Msg
                        (       G_PKG_NAME          ,
                                l_api_name
                        );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (       p_count        =>      x_msg_count,
                        p_data         =>      x_msg_data
                );

  END Create_Category;
  ----------------------------------------------------------------------------


  -- 2. Update_Category
  ----------------------------------------------------------------------------
  PROCEDURE Update_Category
  (
    p_api_version      IN   NUMBER ,
    p_init_msg_list    IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit           IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status    OUT  NOCOPY VARCHAR2 ,
    x_errorcode        OUT  NOCOPY NUMBER,
    x_msg_count        OUT  NOCOPY NUMBER ,
    x_msg_data         OUT  NOCOPY VARCHAR2 ,
    p_category_rec     IN   INV_ITEM_CATEGORY_PUB.CATEGORY_REC_TYPE
  )
    IS

    -- Start OF comments
    -- API name  : Update_Category
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Update a category.
    --
    -- Version: Current Version 0.1
    -- Previous Version :  None
    -- Notes  : Stub Version
    --
    -- END OF comments
     l_api_name              CONSTANT VARCHAR2(30)      := 'Update_Category';
     -- On addition of any Required parameters the major version needs
     -- to change i.e. for eg. 1.X to 2.X.
     -- On addition of any Optional parameters the minor version needs
     -- to change i.e. for eg. X.6 to X.7.
     l_api_version           CONSTANT NUMBER    := 1.0;
     l_row_count             NUMBER;

     -- General variables
     l_category_rec     INV_ITEM_CATEGORY_PUB.category_rec_type;
     l_success BOOLEAN; --boolean for descr. flex valiation


    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT       Update_Category_PUB;


        IF NOT FND_API.Compatible_API_Call (l_api_version,
                                                p_api_version   ,
                                                l_api_name      ,
                                                G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- Initialize API message list if necessary.
        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;

        IF (l_debug = 1) THEN
        mdebug('Tracing....1');
        END IF;

        -- To process the Input record for any invalid values provided.
        Preprocess_Category_Rec(G_UPDATE, p_category_rec, l_category_rec) ;
        Flex_Validate(G_UPDATE, l_category_rec);


        /* Need for Descriptive Flex validation

        l_attribute_category := l_category_rec.attribute_category;
        l_attribute1  := l_category_rec.attribute1 ;
        l_attribute2  := l_category_rec.attribute2 ;
        l_attribute3  := l_category_rec.attribute3 ;
        l_attribute4  := l_category_rec.attribute4 ;
        l_attribute5  := l_category_rec.attribute5 ;
        l_attribute6  := l_category_rec.attribute6 ;
        l_attribute7  := l_category_rec.attribute7 ;
        l_attribute8  := l_category_rec.attribute8 ;
        l_attribute9  := l_category_rec.attribute9 ;
        l_attribute10 := l_category_rec.attribute10;
        l_attribute11 := l_category_rec.attribute11;
        l_attribute12 := l_category_rec.attribute12;
        l_attribute13 := l_category_rec.attribute13;
        l_attribute14 := l_category_rec.attribute14;
        l_attribute15 := l_category_rec.attribute15;
         */


        --Final call for insertion.
        MTL_CATEGORIES_PKG.Update_Row(
              X_CATEGORY_ID          =>   l_category_rec.category_id,
              X_DESCRIPTION          =>   l_category_rec.description,
              X_STRUCTURE_ID         =>   l_category_rec.structure_id,
              X_DISABLE_DATE         =>   l_category_rec.disable_date,
              X_WEB_STATUS           =>   l_category_rec.web_status,--Bug: 2430879
              X_SUPPLIER_ENABLED_FLAG =>  l_category_rec.supplier_enabled_flag,--Bug: 2645153
              X_SEGMENT1             =>   l_category_rec.segment1 ,
              X_SEGMENT2             =>   l_category_rec.segment2 ,
              X_SEGMENT3             =>   l_category_rec.segment3 ,
              X_SEGMENT4             =>   l_category_rec.segment4 ,
              X_SEGMENT5             =>   l_category_rec.segment5 ,
              X_SEGMENT6             =>   l_category_rec.segment6 ,
              X_SEGMENT7             =>   l_category_rec.segment7 ,
              X_SEGMENT8             =>   l_category_rec.segment8 ,
              X_SEGMENT9             =>   l_category_rec.segment9 ,
              X_SEGMENT10            =>   l_category_rec.segment10 ,
              X_SEGMENT11            =>   l_category_rec.segment11 ,
              X_SEGMENT12            =>   l_category_rec.segment12 ,
              X_SEGMENT13            =>   l_category_rec.segment13 ,
              X_SEGMENT14            =>   l_category_rec.segment14 ,
              X_SEGMENT15            =>   l_category_rec.segment15 ,
              X_SEGMENT16            =>   l_category_rec.segment16 ,
              X_SEGMENT17            =>   l_category_rec.segment17 ,
              X_SEGMENT18            =>   l_category_rec.segment18 ,
              X_SEGMENT19            =>   l_category_rec.segment19 ,
              X_SEGMENT20            =>   l_category_rec.segment20 ,
              X_SUMMARY_FLAG         =>   l_category_rec.summary_flag,
              X_ENABLED_FLAG         =>   l_category_rec.enabled_flag,
              X_START_DATE_ACTIVE    =>   l_category_rec.start_date_active,
              X_END_DATE_ACTIVE      =>   l_category_rec.end_date_active,
              X_ATTRIBUTE_CATEGORY   =>   l_category_rec.attribute_category,
              X_ATTRIBUTE1           =>   l_category_rec.attribute1 ,
              X_ATTRIBUTE2           =>   l_category_rec.attribute2 ,
              X_ATTRIBUTE3           =>   l_category_rec.attribute3 ,
              X_ATTRIBUTE4           =>   l_category_rec.attribute4 ,
              X_ATTRIBUTE5           =>   l_category_rec.attribute5 ,
              X_ATTRIBUTE6           =>   l_category_rec.attribute6 ,
              X_ATTRIBUTE7           =>   l_category_rec.attribute7 ,
              X_ATTRIBUTE8           =>   l_category_rec.attribute8 ,
              X_ATTRIBUTE9           =>   l_category_rec.attribute9 ,
              X_ATTRIBUTE10          =>   l_category_rec.attribute10,
              X_ATTRIBUTE11          =>   l_category_rec.attribute11,
              X_ATTRIBUTE12          =>   l_category_rec.attribute12,
              X_ATTRIBUTE13          =>   l_category_rec.attribute13,
              X_ATTRIBUTE14          =>   l_category_rec.attribute14,
              X_ATTRIBUTE15          =>   l_category_rec.attribute15,
              X_LAST_UPDATE_DATE     =>   sysdate,
              X_LAST_UPDATED_BY      =>   fnd_global.user_id,
              X_LAST_UPDATE_LOGIN    =>   fnd_global.login_id
              );

           IF (l_debug = 1) THEN
           mdebug('Updated Category: '||To_char(l_category_rec.category_id));
           END IF;

        IF (l_debug = 1) THEN
        mdebug('Update_Category:: Tracing....10');
        END IF;

          -- Standard check of p_commit.
        IF FND_API.To_Boolean( p_commit ) THEN
                COMMIT WORK;
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;
        -- Standard call to get message count and if count is 1,
        -- get message info.
        -- The client will directly display the x_msg_data (which is already
        -- translated) if the x_msg_count = 1;
        -- Else i.e if  x_msg_count > 1, client will call the FND_MSG_PUB.Get
        -- Server-side procedure to access the messages, and consolidate them
        -- and display (or) to display one message after another.
        FND_MSG_PUB.Count_And_Get
                (       p_count        =>      x_msg_count,
                        p_data         =>      x_msg_data
                );
     EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO Update_Category_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get
                (       p_count        =>      x_msg_count,
                        p_data         =>      x_msg_data
                );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO Update_Category_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count        =>      x_msg_count,
                        p_data         =>      x_msg_data
                );
        WHEN OTHERS THEN
                ROLLBACK TO Update_Category_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                        FND_MSG_PUB.Add_Exc_Msg
                        (       G_PKG_NAME          ,
                                l_api_name
                        );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (       p_count        =>      x_msg_count,
                        p_data         =>      x_msg_data
                );



  END Update_Category;
  ----------------------------------------------------------------------------


  -- 3. Update_Category_Description
  ----------------------------------------------------------------------------
  PROCEDURE Update_Category_Description
  (
    p_api_version      IN   NUMBER ,
    p_init_msg_list    IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit           IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status    OUT  NOCOPY VARCHAR2 ,
    x_errorcode        OUT  NOCOPY NUMBER,
    x_msg_count        OUT  NOCOPY NUMBER ,
    x_msg_data         OUT  NOCOPY VARCHAR2 ,
    p_category_id      IN   NUMBER,
    p_description      IN   VARCHAR2
    -- deleted as this can be picked up from the environment.
    --p_language         IN   VARCHAR2
  )
  IS
    -- Start OF comments
    -- API name  : Update_Category_Description
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Update a category description in the specified language.
    --
    -- Version: Current Version 0.1
    -- Previous Version :  None
    -- Notes  : Stub Version
    -- END OF comments
     l_api_name              CONSTANT VARCHAR2(30)      := 'Update_Category_Description';
     -- On addition of any Required parameters the major version needs
     -- to change i.e. for eg. 1.X to 2.X.
     -- On addition of any Optional parameters the minor version needs
     -- to change i.e. for eg. X.6 to X.7.
     l_api_version           CONSTANT NUMBER    := 1.0;
     l_row_count             NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT       Update_Category_Desc_PUB;


        -- Check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (l_api_version,
                                                p_api_version   ,
                                                l_api_name      ,
                                                G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- Initialize API message list if necessary.
        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;

        UPDATE mtl_categories_tl
        SET
             description = p_description,
             last_update_date = Sysdate,
             last_updated_by = fnd_global.user_id,
             last_update_login = fnd_global.login_id,
             source_lang = userenv('LANG')
         WHERE  category_id = p_category_id
        AND  userenv('LANG') IN (language, source_lang) ;

        IF (sql%notfound) THEN
            fnd_message.set_name('INV','INV_VALID_CAT');
            fnd_msg_pub.ADD;
            IF (l_debug = 1) THEN
            mdebug('Trying to Update a non-existant Category.');
            END IF;
            RAISE NO_DATA_FOUND;
        END IF;

          -- Standard check of p_commit.
        IF FND_API.To_Boolean( p_commit ) THEN
                COMMIT WORK;
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;
        -- Standard call to get message count and if count is 1,
        -- get message info.
        -- The client will directly display the x_msg_data (which is already
        -- translated) if the x_msg_count = 1;
        -- Else i.e if  x_msg_count > 1, client will call the FND_MSG_PUB.Get
        -- Server-side procedure to access the messages, and consolidate them
        -- and display (or) to display one message after another.
        FND_MSG_PUB.Count_And_Get
                (       p_count        =>      x_msg_count,
                        p_data         =>      x_msg_data
                );

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO Update_Category_Desc_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get
                (       p_count        =>      x_msg_count,
                        p_data         =>      x_msg_data
                );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO Update_Category_Desc_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count        =>      x_msg_count,
                        p_data         =>      x_msg_data
                );
        WHEN OTHERS THEN
                ROLLBACK TO Update_Category_Desc_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                        FND_MSG_PUB.Add_Exc_Msg
                        (       G_PKG_NAME          ,
                                l_api_name
                        );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (       p_count        =>      x_msg_count,
                        p_data         =>      x_msg_data
                );

  END Update_Category_Description;
  ----------------------------------------------------------------------------

  -- 4. Delete_Category
  ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------
-- Deletion of categories is not supported.
-- ----------------------------------------------------------------------

  PROCEDURE Delete_Category
  (
    p_api_version      IN   NUMBER ,
    p_init_msg_list    IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit           IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status    OUT  NOCOPY VARCHAR2 ,
    x_errorcode        OUT  NOCOPY NUMBER,
    x_msg_count        OUT  NOCOPY NUMBER ,
    x_msg_data         OUT  NOCOPY VARCHAR2 ,
    p_category_id      IN   NUMBER
  )
  IS
    -- Start OF comments
    -- API name  : Delete_Category
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Delete a category.
    --
    -- Version: Current Version 0.1
    -- Previous Version :  None
    -- Notes  : Stub Version
    --
    -- END OF comments
     l_api_name              CONSTANT VARCHAR2(30)      := 'Delete_Category';
     -- On addition of any Required parameters the major version needs
     -- to change i.e. for eg. 1.X to 2.X.
     -- On addition of any Optional parameters the minor version needs
     -- to change i.e. for eg. X.6 to X.7.
     l_api_version           CONSTANT NUMBER    := 1.0;
     l_row_count             NUMBER;
     l_category_assignment_exists VARCHAR(1);
     l_default_category_exists    VARCHAR(1);
     l_valid_category_exists      VARCHAR(1);

     CURSOR category_assignment_exists(p_category_id NUMBER) IS
       SELECT 'x'
       FROM dual
         WHERE exists
         ( SELECT category_id
           FROM mtl_item_categories
           WHERE category_id = p_category_id
           );

     CURSOR default_category_exists(p_category_id NUMBER) IS
       SELECT 'x'
       FROM dual
         WHERE exists
         ( SELECT default_category_id
           FROM mtl_category_sets_b
           WHERE default_category_id = p_category_id
           );


     CURSOR valid_category_exists(p_category_id NUMBER) IS
       SELECT 'x'
       FROM dual
         WHERE exists
         ( SELECT category_id
           FROM mtl_category_set_valid_cats
           WHERE category_id = p_category_id
           );


    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT       Delete_Category_PUB;

        -- Check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (l_api_version,
                                                p_api_version   ,
                                                l_api_name      ,
                                                G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- Initialize API message list if necessary.
        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;

        OPEN category_assignment_exists(p_category_id);
        FETCH category_assignment_exists INTO l_category_assignment_exists;
        IF (category_assignment_exists%NOTFOUND) THEN
           IF (l_debug = 1) THEN
              mdebug('Can Delete: Category not part of any Category Assignment');
           END IF;
        END IF;
        CLOSE category_assignment_exists;
        IF (l_category_assignment_exists = 'x') THEN
          fnd_message.set_name('INV','INV_CATEGORY_ASSIGNED');
          fnd_msg_pub.ADD;
          IF (l_debug = 1) THEN
          mdebug('Cannot delete: Category part of a Category Assignment');
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        OPEN default_category_exists(p_category_id);
        FETCH default_category_exists INTO l_default_category_exists;
        IF (default_category_exists%NOTFOUND) THEN
           IF (l_debug = 1) THEN
              mdebug('Can Delete: Category not a default category');
           END IF;
        END IF;
        CLOSE default_category_exists;
        IF (l_default_category_exists = 'x') THEN
          fnd_message.set_name('INV','INV_CATEGORY_DEFAULT');
          fnd_msg_pub.ADD;
         IF (l_debug = 1) THEN
         mdebug('Cannot delete: Category specified is a default category to one of the Category Sets.');
         END IF;
         RAISE FND_API.G_EXC_ERROR;
        END IF;

        OPEN valid_category_exists(p_category_id);
        FETCH  valid_category_exists INTO l_valid_category_exists;
        IF (valid_category_exists%NOTFOUND) THEN
           IF (l_debug = 1) THEN
              mdebug('Can Delete: Category not part of a Valid category set');
           END IF;
        END IF;
        CLOSE valid_category_exists;
        IF (l_valid_category_exists = 'x') THEN
          fnd_message.set_name('INV','INV_CATEGORY_IN_USE');
          fnd_msg_pub.ADD;
         IF (l_debug = 1) THEN
         mdebug('Cannot delete: Category specified is part of a valid category set');
         END IF;
         RAISE FND_API.G_EXC_ERROR;
        END IF;

        delete from mtl_categories_tl
        where  category_id = p_category_id ;

        if (sql%notfound) then
          fnd_message.set_name('INV','INV_VALID_CAT');
          fnd_msg_pub.ADD;
          IF (l_debug = 1) THEN
             mdebug('Trying to delete non-existant Category Id from MTL_CATEGORIES_TL.');
          END IF;
          RAISE NO_DATA_FOUND;
        end if;

        delete from mtl_categories_b
        where  category_id = p_category_id ;

        if (sql%notfound) then
          fnd_message.set_name('INV','INV_VALID_CAT');
          fnd_msg_pub.ADD;
          IF (l_debug = 1) THEN
             mdebug('Trying to delete non-existant Category Id from MTL_CATEGORIES_B.');
          END IF;
          RAISE NO_DATA_FOUND;
        end if;

        IF (l_debug = 1) THEN
           mdebug('Category deleted successfully: '||p_category_id);
        END IF;
        -- Standard check of p_commit.
        IF FND_API.To_Boolean( p_commit ) THEN
                COMMIT WORK;
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;
        -- Standard call to get message count and if count is 1,
        -- get message info.
        -- The client will directly display the x_msg_data (which is already
        -- translated) if the x_msg_count = 1;
        -- Else i.e if  x_msg_count > 1, client will call the FND_MSG_PUB.Get
        -- Server-side procedure to access the messages, and consolidate them
        -- and display (or) to display one message after another.
        FND_MSG_PUB.Count_And_Get
                (       p_count        =>      x_msg_count,
                        p_data         =>      x_msg_data
                );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO Delete_Category_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get
                (       p_count        =>      x_msg_count,
                        p_data         =>      x_msg_data
                );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO Delete_Category_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count        =>      x_msg_count,
                        p_data         =>      x_msg_data
                );
        WHEN OTHERS THEN
                ROLLBACK TO Delete_Category_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                        FND_MSG_PUB.Add_Exc_Msg
                        (       G_PKG_NAME          ,
                                l_api_name
                        );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (       p_count        =>      x_msg_count,
                        p_data         =>      x_msg_data
                );


  END Delete_Category;

  ----------------------------------------------------------------------------

  -- 5. Create_Category_Assignment
  --  Bug: 2451359, All the validations are taken care in the Pvt pkg,so
  --  Calling private pkg instead.
  ----------------------------------------------------------------------------
  PROCEDURE Create_Category_Assignment
  (
    p_api_version       IN   NUMBER,
    p_init_msg_list     IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit            IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status     OUT  NOCOPY VARCHAR2,
    x_errorcode         OUT  NOCOPY NUMBER,
    x_msg_count         OUT  NOCOPY NUMBER,
    x_msg_data          OUT  NOCOPY VARCHAR2,
    p_category_id       IN   NUMBER,
    p_category_set_id   IN   NUMBER,
    p_inventory_item_id IN   NUMBER,
    p_organization_id   IN   NUMBER
  )
  IS
    -- Start OF comments
    -- API name  : Create_Category_Assignment
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Create an item category assignment.
    --
    -- Version: Current Version 0.1
    -- Previous Version :  None
    -- Notes  : Stub Version
    --
    -- END OF comments
     l_api_name              CONSTANT VARCHAR2(30)      := 'Create_Category_Assignment';
     -- On addition of any Required parameters the major version needs
     -- to change i.e. for eg. 1.X to 2.X.
     -- On addition of any Optional parameters the minor version needs
     -- to change i.e. for eg. X.6 to X.7.
     l_api_version           CONSTANT NUMBER := 1.0;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN

        -- Standard Start of API savepoint
        SAVEPOINT       Create_Category_Assignment_PUB;

        -- Check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (l_api_version,
                                                p_api_version   ,
                                                l_api_name      ,
                                                G_PKG_NAME)
        THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- Initialize API message list if necessary.
        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;
        INV_ITEM_MSG.set_Message_Mode('PLSQL');

        IF FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN
         INV_ITEM_MSG.set_Message_Level(INV_ITEM_MSG.g_Level_Warning);
        END IF;

        INV_ITEM_CATEGORY_PVT.Create_Category_Assignment
        (
           p_api_version        => p_api_version
        ,  p_init_msg_list      => p_init_msg_list
        ,  p_commit             => p_commit
        ,  p_validation_level   => INV_ITEM_CATEGORY_PVT.g_VALIDATE_ALL
        ,  p_inventory_item_id  => p_inventory_item_id
        ,  p_organization_id    => p_organization_id
        ,  p_category_set_id    => p_category_set_id
        ,  p_category_id        => p_category_id
        ,  x_return_status      => x_return_status
        ,  x_msg_count          => x_msg_count
        ,  x_msg_data           => x_msg_data
        );

       --add by geguo business event enhancement 8351807
       BEGIN

         IF (l_debug = 1) THEN
             mdebug('begin Raise EGO_WF_WRAPPER_PVT.G_ITEM_CAT_ASSIGN_EVENT business event');
         END IF;
         IF (x_return_status = fnd_api.g_RET_STS_SUCCESS) THEN

           INV_ITEM_EVENTS_PVT.Raise_Events (
             p_commit             => FND_API.To_Boolean(p_commit)
             ,p_event_name        => 'EGO_WF_WRAPPER_PVT.G_ITEM_CAT_ASSIGN_EVENT'
             ,p_dml_type          => 'CREATE'
             ,p_inventory_item_id => p_inventory_item_id
             ,p_organization_id   => p_organization_id
             ,p_category_set_id   => p_category_set_id
             ,p_category_id       => p_category_id
             ,p_old_category_id   => null
             );
         END IF;
         IF (l_debug = 1) THEN
             mdebug('end Raise EGO_WF_WRAPPER_PVT.G_ITEM_CAT_ASSIGN_EVENT business event');
         END IF;

         EXCEPTION
           WHEN OTHERS THEN
             IF (l_debug = 1) THEN
               mdebug('error occured when Raise EGO_WF_WRAPPER_PVT.G_ITEM_CAT_ASSIGN_EVENT business event');
             END IF;
       END;
        --mdebug('Create_Category_Assignment: Done!!');
          -- Standard check of p_commit.
        IF FND_API.To_Boolean( p_commit ) THEN
                COMMIT WORK;
        END IF;

      INV_ITEM_MSG.Write_List;
      FND_MSG_PUB.Count_And_Get
                (       p_count        =>      x_msg_count,
                        p_data         =>      x_msg_data
                );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO Create_Category_Assignment_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get
                (       p_count        =>      x_msg_count,
                        p_data         =>      x_msg_data
                );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO Create_Category_Assignment_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count        =>      x_msg_count,
                        p_data         =>      x_msg_data
                );
        WHEN OTHERS THEN
                ROLLBACK TO Create_Category_Assignment_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                        FND_MSG_PUB.Add_Exc_Msg
                        (       G_PKG_NAME          ,
                                l_api_name
                        );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (       p_count        =>      x_msg_count,
                        p_data         =>      x_msg_data
                );

  END Create_Category_Assignment;
  ----------------------------------------------------------------------------


  -- 6. Delete_Category_Assignment
  ----------------------------------------------------------------------------
  PROCEDURE Delete_Category_Assignment
  (
    p_api_version       IN   NUMBER,
    p_init_msg_list     IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit            IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status     OUT  NOCOPY VARCHAR2,
    x_errorcode         OUT  NOCOPY NUMBER,
    x_msg_count         OUT  NOCOPY NUMBER,
    x_msg_data          OUT  NOCOPY VARCHAR2,
    p_category_id       IN   NUMBER,
    p_category_set_id   IN   NUMBER,
    p_inventory_item_id IN   NUMBER,
    p_organization_id   IN   NUMBER
  )
  IS
    -- Start OF comments
    -- API name  : Delete_Category_Assignment
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Delete an item category assignment.
    --
    -- Version: Current Version 0.1
    -- Previous Version :  None
    -- Notes  : Stub Version
    --
    -- END OF comments
     l_api_name              CONSTANT VARCHAR2(30)      := 'Delete_Category_Assignment';
     -- On addition of any Required parameters the major version needs
     -- to change i.e. for eg. 1.X to 2.X.
     -- On addition of any Optional parameters the minor version needs
     -- to change i.e. for eg. X.6 to X.7.
     l_api_version           CONSTANT NUMBER    := 1.0;
     l_row_count             NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT       Delete_Category_Assignment_PUB;

        -- Check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (l_api_version,
                                                p_api_version   ,
                                                l_api_name      ,
                                                G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- Initialize API message list if necessary.
        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;
--Added code for bug 2527058
        INV_ITEM_MSG.set_Message_Mode('PLSQL');

        IF FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN
         INV_ITEM_MSG.set_Message_Level(INV_ITEM_MSG.g_Level_Warning);
        END IF;

        INV_ITEM_CATEGORY_PVT.Delete_Category_Assignment
        (
           p_api_version        => p_api_version
        ,  p_init_msg_list      => p_init_msg_list
        ,  p_commit             => p_commit
        ,  p_inventory_item_id  => p_inventory_item_id
        ,  p_organization_id    => p_organization_id
        ,  p_category_set_id    => p_category_set_id
        ,  p_category_id        => p_category_id
        ,  x_return_status      => x_return_status
        ,  x_msg_count          => x_msg_count
        ,  x_msg_data           => x_msg_data
        );

/*      IF (l_debug = 1) THEN
        mdebug('Delete_Category_Assignment: Tracing...1');
        END IF;

        DELETE FROM mtl_item_categories
        WHERE category_set_id = p_category_set_id
          AND organization_id = p_organization_id
          AND inventory_item_id =  p_inventory_item_id
          AND category_id = p_category_id;

        IF (SQL%NOTFOUND) THEN
           IF (l_debug = 1) THEN
           mdebug('The specified Category Assignment not found');
           END IF;
           RAISE NO_DATA_FOUND;
        END IF;
*/
--Ended code for bug 2527058
        IF (l_debug = 1) THEN
        mdebug('Delete_Category_Assignment: Done!!');
        END IF;

       --add by geguo business event enhancement 8351807
       BEGIN
         IF (l_debug = 1) THEN
             mdebug('begin Raise EGO_WF_WRAPPER_PVP.G_ITEM_CAT_ASSIGN_EVENT business event');
         END IF;

         dbms_output.put_line('return status: '|| x_return_status);
         IF (x_return_status = fnd_api.g_RET_STS_SUCCESS) THEN
           INV_ITEM_EVENTS_PVT.Raise_Events (
             p_commit             => FND_API.To_Boolean(p_commit)
             ,p_event_name        => 'EGO_WF_WRAPPER_PVT.G_ITEM_CAT_ASSIGN_EVENT'
             ,p_dml_type          => 'DELETE'
             ,p_inventory_item_id => p_inventory_item_id
             ,p_organization_id   => p_organization_id
             ,p_category_set_id   => p_category_set_id
             ,p_category_id       => p_category_id
             ,p_old_category_id   => null    --add by geguo.
             );
         END IF;
         IF (l_debug = 1) THEN
             mdebug('end Raise EGO_WF_WRAPPER_PVP.G_ITEM_CAT_ASSIGN_EVENT business event');
         END IF;

         EXCEPTION
           WHEN OTHERS THEN
             IF (l_debug = 1) THEN
               mdebug('error occured when Raise EGO_WF_WRAPPER_PVT.G_ITEM_CAT_ASSIGN_EVENT business event');
             END IF;
       END;

      -- Standard check of p_commit.
        IF FND_API.To_Boolean( p_commit ) THEN
                COMMIT WORK;
        END IF;

--      x_return_status := FND_API.G_RET_STS_SUCCESS;
        INV_ITEM_MSG.Write_List;
        -- Standard call to get message count and if count is 1,
        -- get message info.
        -- The client will directly display the x_msg_data (which is already
        -- translated) if the x_msg_count = 1;
        -- Else i.e if  x_msg_count > 1, client will call the FND_MSG_PUB.Get
        -- Server-side procedure to access the messages, and consolidate them
        -- and display (or) to display one message after another.
        FND_MSG_PUB.Count_And_Get
                (       p_count        =>      x_msg_count,
                        p_data         =>      x_msg_data
                );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO Delete_Category_Assignment_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get
                (       p_count        =>      x_msg_count,
                        p_data         =>      x_msg_data
                );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO Delete_Category_Assignment_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count        =>      x_msg_count,
                        p_data         =>      x_msg_data
                );
        WHEN OTHERS THEN
                ROLLBACK TO Delete_Category_Assignment_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                        FND_MSG_PUB.Add_Exc_Msg
                        (       G_PKG_NAME          ,
                                l_api_name
                        );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (       p_count        =>      x_msg_count,
                        p_data         =>      x_msg_data
                );

  END Delete_Category_Assignment;
  -----------------------------------------------------------------------------
  -- 7. Get_Category_Rec_Type
  ----------------------------------------------------------------------------
  FUNCTION Get_Category_Rec_Type
    RETURN INV_ITEM_CATEGORY_PUB.CATEGORY_REC_TYPE IS
    l_category_rec_type INV_ITEM_CATEGORY_PUB.CATEGORY_REC_TYPE ;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    RETURN l_category_rec_type;
  END;

  -----------------------------------------------------------------------------
  -- 8. Validate_iProcurements_flags
  --Bug: 2645153 validating structure and iProcurement flags
  ----------------------------------------------------------------------------
  PROCEDURE Validate_iProcurements_flags
  (
    x_category_rec  IN INV_ITEM_CATEGORY_PUB.CATEGORY_REC_TYPE
   ) IS

  l_po_structure_id NUMBER;
  --Bug: 2645153 added coide to get purchasing category structure id
  CURSOR get_po_structure_id IS
    SELECT STRUCTURE_ID
     FROM MTL_CATEGORY_SETS MCS,
          MTL_DEFAULT_CATEGORY_SETS MDCS
     WHERE  FUNCTIONAL_AREA_ID = 2
      AND    MCS.CATEGORY_SET_ID = MDCS.CATEGORY_SET_ID;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   BEGIN
        IF (l_debug = 1) THEN
        mdebug('checking supplier enabled flag information provided'|| x_category_rec.supplier_enabled_flag);
        END IF;
           IF x_category_rec.supplier_enabled_flag NOT IN (g_YES,g_MISS_CHAR) THEN -- g_NO is modifed to g_YES for bug#6278190
                fnd_message.set_name('INV','INV_NOT_VALID_FLAG');
                fnd_message.set_token('COLUMN_NAME', 'SUPPLIER_ENABLED_FLAG');
                fnd_msg_pub.ADD;
                RAISE fnd_api.g_EXC_UNEXPECTED_ERROR;
                IF (l_debug = 1) THEN
                mdebug('Invalid supplier enabled flag information provided');
                END IF;
           END IF;
        IF (l_debug = 1) THEN
        mdebug('checking web status flag information provided');
        END IF;
/*Bug: 4494727 Commenting out the following IF condition
           IF x_category_rec.web_status NOT IN (g_YES,g_MISS_CHAR)  THEN
                fnd_message.set_name('INV','INV_NOT_VALID_FLAG');
                fnd_message.set_token('COLUMN_NAME', 'WEB_STATUS');
                fnd_msg_pub.ADD;
                RAISE fnd_api.g_EXC_UNEXPECTED_ERROR;
                IF (l_debug = 1) THEN
                mdebug('Invalid web status flag information provided');
                END IF;
           END IF;
*/
           IF  (x_category_rec.supplier_enabled_flag = g_NO) --OR  Bug: 4494727
--                (x_category_rec.web_status = g_YES)
           THEN
             OPEN get_po_structure_id;
             FETCH get_po_structure_id INTO l_po_structure_id;
             IF (get_po_structure_id%NOTFOUND) THEN
                fnd_message.set_name('INV','INV_NO_DEFAULT_CSET');
                fnd_msg_pub.ADD;
                IF (l_debug = 1) THEN
                mdebug('No Default purchasing category set  provided');
                END IF;
                CLOSE  get_po_structure_id;
                RAISE fnd_api.g_EXC_UNEXPECTED_ERROR;
             ELSE
              IF (l_po_structure_id <> x_category_rec.structure_id) THEN
               IF  (x_category_rec.supplier_enabled_flag = g_NO) THEN
                fnd_message.set_name('INV','INV_SUP_ENABLED_PO_CAT_ONLY');
                fnd_msg_pub.ADD;
               END IF;
/*Bug: 4494727      Commenting out the following IF condition
               IF  (x_category_rec.web_status = g_YES) THEN
                fnd_message.set_name('INV','INV_CAT_ENABLED_PO_CAT_ONLY');
                fnd_msg_pub.ADD;
               END IF;
*/
                IF (l_debug = 1) THEN
                   mdebug('Only purchasing cat can be viewable by supplier');
                END IF;
                CLOSE  get_po_structure_id;
                RAISE fnd_api.g_EXC_UNEXPECTED_ERROR;
              END IF;
             END IF;
             CLOSE  get_po_structure_id;
          END IF; --if flag = 'Y'
 END Validate_iProcurements_flags;

  ----------------------------------------------------------------------------
  -- 9.  Create Valid Category
  -- Bug: 3093555
  -- API to create a valid Category in Category Sets
  ----------------------------------------------------------------------------
  PROCEDURE Create_Valid_Category(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_category_set_id     IN  NUMBER,
    p_category_id         IN  NUMBER,
    p_parent_category_id  IN  NUMBER,
    x_return_status       OUT  NOCOPY VARCHAR2,
    x_errorcode           OUT  NOCOPY NUMBER,
    x_msg_count           OUT  NOCOPY NUMBER,
    x_msg_data            OUT  NOCOPY VARCHAR2
  ) IS
    -- Start OF comments
    -- API name  : Create_Valid_Category
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Create a record in mtl_category_set_valid_cats.
    --
    -- Version: Current Version 1.0
    -- Previous Version :  None
    -- Notes  : Stub Version
    --
    -- END OF comments
    l_api_name    CONSTANT VARCHAR2(30)  := 'Create_Valid_Category';
    -- On addition of any Required parameters the major version needs
    -- to change i.e. for eg. 1.X to 2.X.
    -- On addition of any Optional parameters the minor version needs
    -- to change i.e. for eg. X.6 to X.7.
    l_api_version CONSTANT NUMBER         := 1.0;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    -- who column variables
    l_user_id        mtl_category_set_valid_cats.created_by%TYPE;
    l_login_id       mtl_category_set_valid_cats.last_update_login%TYPE;
    l_request_id     mtl_category_set_valid_cats.request_id%TYPE;
    l_prog_appl_id   mtl_category_set_valid_cats.program_application_id%TYPE;
    l_program_id     mtl_category_set_valid_cats.program_id%TYPE;
  BEGIN
    IF l_debug = 1 THEN
      mdebug('Create_Valid_Category: Tracing...1');
    END IF;
    -- Standard Start of API savepoint
    IF FND_API.To_Boolean( p_commit ) THEN
      SAVEPOINT    Create_Valid_Category_PUB;
    END IF;
    -- Check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME) THEN
    IF l_debug = 1 THEN
      mdebug('Create_Valid_Category: Invalid API Call');
    END IF;
      RAISE FND_API.g_EXC_ERROR;
    END IF;
    -- Initialize API message list if necessary.
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    IF validate_category_set_params
        (p_validation_type    => G_INSERT
        ,p_category_set_id    => p_category_set_id
        ,p_category_id        => p_category_id
        ,p_parent_category_id => p_parent_category_id
        ,p_calling_api        => l_api_name
        ) THEN
      IF l_debug = 1 THEN
        mdebug('Create_Valid_Category: Inserting data into category sets ');
      END IF;
      l_user_id  := fnd_global.user_id;
      l_login_id := fnd_global.login_id;
      IF l_login_id = -1 THEN
        l_login_id := fnd_global.conc_login_id;
      END IF;
      l_request_id         := fnd_global.conc_request_id;
      l_prog_appl_id       := fnd_global.prog_appl_id;
      l_program_id         := fnd_global.conc_program_id;
      INSERT INTO mtl_category_set_valid_cats
        ( category_set_id
        , category_id
        , parent_category_id
        , created_by
        , creation_date
        , last_updated_by
        , last_update_date
        , last_update_login
        , request_id
        , program_application_id
        , program_id
        , program_update_date
        )
      VALUES
        ( p_category_set_id
        , p_category_id
        , p_parent_category_id
        , l_user_id
        , SYSDATE
        , l_user_id
        , SYSDATE
        , l_login_id
        , l_request_id
        , l_prog_appl_id
        , l_program_id
        , SYSDATE
      );
    ELSE
      -- passed parameters are invalid
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Standard call to get message count and if count is 1,
    -- get message info.
    -- The client will directly display the x_msg_data (which is already
    -- translated) if the x_msg_count = 1;
    -- Else i.e if  x_msg_count > 1, client will call the FND_MSG_PUB.Get
    -- Server-side procedure to access the messages, and consolidate them
    -- and display (or) to display one message after another.
    FND_MSG_PUB.Count_And_Get
        (       p_count        =>      x_msg_count,
                p_data         =>      x_msg_data
        );

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF l_debug = 1 THEN
          mdebug('Create_Valid_Category: Apps Exception raised');
        END IF;
        IF FND_API.To_Boolean( p_commit ) THEN
          ROLLBACK TO Create_Valid_Category_PUB;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
        (       p_count        =>      x_msg_count,
                p_data         =>      x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF l_debug = 1 THEN
          mdebug('Create_Valid_Category: Apps Unexpected Error');
        END IF;
        IF FND_API.To_Boolean( p_commit ) THEN
          ROLLBACK TO Create_Valid_Category_PUB;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
        (       p_count        =>      x_msg_count,
                p_data         =>      x_msg_data
        );
    WHEN OTHERS THEN
        IF l_debug = 1 THEN
          mdebug('Create_Valid_Category: Exception -- OTHERS ');
        END IF;
        IF FND_API.To_Boolean( p_commit ) THEN
          ROLLBACK TO Create_Valid_Category_PUB;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF      FND_MSG_PUB.Check_Msg_Level
                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
          FND_MSG_PUB.Add_Exc_Msg
          (     G_PKG_NAME          ,
                l_api_name
          );
        END IF;
        FND_MSG_PUB.Count_And_Get
        (       p_count        =>      x_msg_count,
                p_data         =>      x_msg_data
        );
  END Create_Valid_Category;

  ----------------------------------------------------------------------------
  -- 10.  Update Category
  -- Bug: 3093555
  -- API to update a valid Category
  ----------------------------------------------------------------------------
  PROCEDURE Update_Valid_Category(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_category_set_id     IN  NUMBER,
    p_category_id         IN  NUMBER,
    p_parent_category_id  IN  NUMBER,
    x_return_status       OUT  NOCOPY VARCHAR2,
    x_errorcode           OUT  NOCOPY NUMBER,
    x_msg_count           OUT  NOCOPY NUMBER,
    x_msg_data            OUT  NOCOPY VARCHAR2
  ) IS
    -- Start OF comments
    -- API name  : Update_Valid_Category
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Update record in mtl_category_set_valid_cats.
    --
    -- Version: Current Version 1.0
    -- Previous Version :  None
    -- Notes  : Stub Version
    --
    -- END OF comments
    l_api_name    CONSTANT VARCHAR2(30)  := 'Update_Valid_Category';
    -- On addition of any Required parameters the major version needs
    -- to change i.e. for eg. 1.X to 2.X.
    -- On addition of any Optional parameters the minor version needs
    -- to change i.e. for eg. X.6 to X.7.
    l_api_version CONSTANT NUMBER         := 1.0;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_user_id        mtl_category_set_valid_cats.created_by%TYPE;
    l_login_id       mtl_category_set_valid_cats.last_update_login%TYPE;
  BEGIN
    IF l_debug = 1 THEN
      mdebug('Update_Valid_Category: Tracing...1');
    END IF;
    -- Standard Start of API savepoint
    IF FND_API.To_Boolean( p_commit ) THEN
      SAVEPOINT    Update_Valid_Category_PUB;
    END IF;
    -- Check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME) THEN
      IF l_debug = 1 THEN
        mdebug('Update_Valid_Category: Invalid API call');
      END IF;
      RAISE FND_API.g_EXC_ERROR;
    END IF;
    -- Initialize API message list if necessary.
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF validate_category_set_params
        (p_validation_type    => G_UPDATE
        ,p_category_set_id    => p_category_set_id
        ,p_category_id        => p_category_id
        ,p_parent_category_id => p_parent_category_id
        ,p_calling_api        => l_api_name
        ) THEN
      l_user_id  := fnd_global.user_id;
      l_login_id := fnd_global.login_id;
      IF l_login_id = -1 THEN
        l_login_id := fnd_global.conc_login_id;
      END IF;
      IF l_debug = 1 THEN
        mdebug('Update_Valid_Category: About to update the category record');
      END IF;
      UPDATE  mtl_category_set_valid_cats
      SET parent_category_id = p_parent_category_id
         ,last_updated_by    = l_user_id
         ,last_update_date   = SYSDATE
         ,last_update_login  = l_login_id
      WHERE category_set_id = p_category_set_id
       AND category_id = p_category_id;
      IF (SQL%NOTFOUND) THEN
        IF l_debug = 1 THEN
          mdebug('Update_Valid_Category: Record not available for update');
        END IF;
        fnd_message.set_name('INV','INV_CATEGORY_UNAVAIL_UPDATE');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_EXC_UNEXPECTED_ERROR;
      END IF;
    ELSE
      -- passed parameters are invalid
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Standard call to get message count and if count is 1,
    -- get message info.
    -- The client will directly display the x_msg_data (which is already
    -- translated) if the x_msg_count = 1;
    -- Else i.e if  x_msg_count > 1, client will call the FND_MSG_PUB.Get
    -- Server-side procedure to access the messages, and consolidate them
    -- and display (or) to display one message after another.
    FND_MSG_PUB.Count_And_Get
        (       p_count        =>      x_msg_count,
                p_data         =>      x_msg_data
        );

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF l_debug = 1 THEN
          mdebug('Update_Valid_Category: Apps Exception raised');
        END IF;
        IF FND_API.To_Boolean( p_commit ) THEN
          ROLLBACK TO Update_Valid_Category_PUB;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
        (       p_count        =>      x_msg_count,
                p_data         =>      x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF l_debug = 1 THEN
          mdebug('Update_Valid_Category: Apps Unexpected Error');
        END IF;
        IF FND_API.To_Boolean( p_commit ) THEN
          ROLLBACK TO Update_Valid_Category_PUB;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
        (       p_count        =>      x_msg_count,
                p_data         =>      x_msg_data
        );
    WHEN OTHERS THEN
        IF l_debug = 1 THEN
          mdebug('Update_Valid_Category: Exception -- OTHERS ');
        END IF;
        IF FND_API.To_Boolean( p_commit ) THEN
          ROLLBACK TO Update_Valid_Category_PUB;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF      FND_MSG_PUB.Check_Msg_Level
                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       G_PKG_NAME          ,
                        l_api_name
                );
        END IF;
        FND_MSG_PUB.Count_And_Get
        (       p_count        =>      x_msg_count,
                p_data         =>      x_msg_data
        );
  END Update_Valid_Category;

  ----------------------------------------------------------------------------
  -- 11.  Delete Category
  -- Bug: 3093555
  -- API to Delete a valid Category
  ----------------------------------------------------------------------------
  PROCEDURE Delete_Valid_Category(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_category_set_id     IN  NUMBER,
    p_category_id         IN  NUMBER,
    x_return_status       OUT  NOCOPY VARCHAR2,
    x_errorcode           OUT  NOCOPY NUMBER,
    x_msg_count           OUT  NOCOPY NUMBER,
    x_msg_data            OUT  NOCOPY VARCHAR2
  ) IS
    -- Start OF comments
    -- API name  : Delete_Valid_Category
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Delete the record from mtl_category_set_valid_cats.
    --
    -- Version: Current Version 1.0
    -- Previous Version :  None
    -- Notes  : Stub Version
    --
    -- END OF comments
    l_api_name    CONSTANT VARCHAR2(30)  := 'Delete_Valid_Category';
    -- On addition of any Required parameters the major version needs
    -- to change i.e. for eg. 1.X to 2.X.
    -- On addition of any Optional parameters the minor version needs
    -- to change i.e. for eg. X.6 to X.7.
    l_api_version CONSTANT NUMBER         := 1.0;
    l_count        NUMBER;
    l_debug        NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_description  mtl_categories_vl.description%TYPE;
    l_category_id  mtl_category_set_valid_cats.category_id%TYPE;
    l_def_category_id    mtl_category_sets_b.default_category_id%TYPE;
    l_hrchy_enabled   mtl_category_sets_b.hierarchy_enabled%TYPE;

    CURSOR c_get_cat_desc (cp_category_id IN  NUMBER) IS
    SELECT description
    FROM mtl_categories_vl
    WHERE category_id =  cp_category_id;

    --Added for bug 5219692
    CURSOR c_get_items_in_cat (cp_category_id      IN  NUMBER
                              ,cp_category_set_id  IN NUMBER) IS
    SELECT category_id
    FROM   mtl_item_categories item_cat
    WHERE  item_cat.category_id     = cp_category_id
      AND  item_cat.category_set_id = cp_category_set_id
      AND rownum = 1;

    CURSOR c_get_items_in_cat_hrchy (cp_category_id      IN  NUMBER
                              ,cp_category_set_id  IN NUMBER) IS
    SELECT valid_cats.category_id
    FROM   mtl_category_set_valid_cats  valid_cats
    WHERE EXISTS
        (SELECT 'X'
         FROM   mtl_item_categories item_cat
         WHERE  item_cat.category_id = valid_cats.category_id
           AND  item_cat.category_set_id = cp_category_set_id
        )
    CONNECT BY PRIOR
           valid_cats.category_id = valid_cats.parent_category_id
       AND valid_cats.category_set_id =  cp_category_set_id
    START WITH
           valid_cats.category_id = cp_category_id
       AND category_set_id = cp_category_set_id
    AND rownum = 1;

   --Added for bug 5219692
   CURSOR c_check_default_cat (cp_category_id  IN  NUMBER
                              ,cp_category_set_id IN NUMBER) IS
   SELECT cat_sets.default_category_id
   FROM   mtl_category_sets_b cat_sets
   WHERE cat_sets.category_set_id        = p_category_set_id
     AND cat_sets.default_category_id    = p_category_id
     AND NVL(cat_sets.validate_flag,'N') = 'Y';

   CURSOR c_check_default_cat_hrchy (cp_category_id  IN  NUMBER
                                    ,cp_category_set_id IN NUMBER) IS
   SELECT cat_sets.default_category_id
   FROM   mtl_category_sets_b cat_sets
   WHERE cat_sets.category_set_id = p_category_set_id
     AND EXISTS
        (SELECT 'X'
         FROM   mtl_category_set_valid_cats check_cats
         WHERE  check_cats.category_id = cat_sets.default_category_id
         CONNECT BY PRIOR
                check_cats.category_id = check_cats.parent_category_id
            AND check_cats.category_set_id = cp_category_set_id
         START WITH
                check_cats.category_id = cp_category_id
            AND check_cats.category_set_id = cp_category_set_id
        )
    AND NVL(cat_sets.validate_flag,'N') = 'Y';


  BEGIN
    IF l_debug = 1 THEN
      mdebug('Delete_Valid_Category: Tracing...1');
    END IF;
    -- Standard Start of API savepoint
    IF FND_API.To_Boolean( p_commit ) THEN
      SAVEPOINT    Delete_Valid_Category_PUB;
    END IF;
    -- Check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME) THEN
      IF l_debug = 1 THEN
        mdebug('Delete_Valid_Category: Invalid API call');
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- Initialize API message list if necessary.
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF (p_category_set_id  IS NULL OR  p_category_id IS NULL) THEN
      IF l_debug = 1 THEN
        mdebug('Delete_Valid_Category: Mandatory parameters missing');
      END IF;
      fnd_message.set_name('INV','INV_MISSING_REQUIRED_PARAMETER');
      fnd_msg_pub.ADD;
      RAISE fnd_api.G_EXC_ERROR;
    END IF;

    IF NOT get_category_set_type(p_category_set_id => p_category_set_id
                                ,p_category_id     => p_category_id
				,x_hrchy_enabled   => l_hrchy_enabled) THEN
      IF l_debug = 1 THEN
        mdebug('Delete_Valid_Category: Record not available for deletion');
      END IF;
      fnd_message.set_name('INV','INV_CATEGORY_UNAVAIL_DELETE');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_EXC_ERROR;
    END IF;

    -- check if the user tries to delete default cateogy of the category set
    IF UPPER(l_hrchy_enabled) = 'Y' THEN
       OPEN c_check_default_cat_hrchy (cp_category_id => p_category_id
                                      ,cp_category_set_id => p_category_set_id);
       FETCH c_check_default_cat_hrchy INTO l_def_category_id;
       IF c_check_default_cat_hrchy%NOTFOUND THEN
         l_def_category_id := NULL;
       END IF;
       CLOSE c_check_default_cat_hrchy;
    ELSE
       OPEN c_check_default_cat(cp_category_id => p_category_id
                               ,cp_category_set_id => p_category_set_id);
       FETCH c_check_default_cat INTO l_def_category_id;
       IF c_check_default_cat%NOTFOUND THEN
         l_def_category_id := NULL;
       END IF;
       CLOSE c_check_default_cat;
    END IF;

    IF l_def_category_id IS NOT NULL THEN
      -- default category is in the hierarchy
      IF l_debug = 1 THEN
        mdebug('Delete_Valid_Category: Cannot delete default category');
      END IF;
      OPEN c_get_cat_desc (cp_category_id => l_def_category_id);
      FETCH c_get_cat_desc INTO l_description;
      IF c_get_cat_desc%NOTFOUND THEN
        l_description := NULL;
      END IF;
      fnd_message.set_name('INV','INV_DELETE_DEF_CAT_ERR');
      fnd_message.set_token('CATEGORY_NAME', l_description);
      fnd_msg_pub.ADD;
      RAISE fnd_api.G_EXC_ERROR;
    END IF;

    -- check if there are any items associated to the category / category set
    IF UPPER(l_hrchy_enabled) = 'Y' THEN
       OPEN c_get_items_in_cat_hrchy (cp_category_id     => p_category_id
                                     ,cp_category_set_id => p_category_set_id);
       FETCH c_get_items_in_cat_hrchy INTO l_category_id;
       IF c_get_items_in_cat_hrchy%NOTFOUND THEN
         l_category_id := NULL;
       END IF;
       CLOSE c_get_items_in_cat_hrchy;
    ELSE
       OPEN c_get_items_in_cat (cp_category_id     => p_category_id
                               ,cp_category_set_id => p_category_set_id);
       FETCH c_get_items_in_cat INTO l_category_id;
       IF c_get_items_in_cat%NOTFOUND THEN
         l_category_id := NULL;
       END IF;
      CLOSE c_get_items_in_cat;
    END IF;

    IF l_category_id IS NULL THEN
      IF l_debug = 1 THEN
        mdebug('Delete_Valid_Category: No items associated! Delete now');
      END IF;

      IF UPPER(l_hrchy_enabled) = 'Y' THEN
         DELETE mtl_category_set_valid_cats delete_cats
         WHERE category_set_id = p_category_set_id
           AND EXISTS
             (SELECT 'X'
              FROM  mtl_category_set_valid_cats
              WHERE category_id = delete_cats.category_id
              CONNECT BY PRIOR category_id = parent_category_id
                     AND category_set_id = p_category_set_id
              START WITH category_id = p_category_id
                    AND category_set_id = p_category_set_id
             );
       ELSE --Added else part for bug 5219692
         DELETE mtl_category_set_valid_cats delete_cats
         WHERE category_set_id = p_category_set_id
	   AND category_id     = p_category_id;

       END IF;
    ELSE
      IF l_debug = 1 THEN
        mdebug('Delete_Valid_Category: Items ASSOCIATED!! ');
      END IF;
      OPEN c_get_cat_desc (cp_category_id => l_def_category_id);
      FETCH c_get_cat_desc INTO l_description;
      IF c_get_cat_desc%NOTFOUND THEN
        l_description := NULL;
      END IF;
      fnd_message.set_name('INV','INV_CATEGORY_ITEMS_EXIST');
      fnd_message.set_token('CATEGORY_NAME', l_description);
      fnd_msg_pub.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Standard call to get message count and if count is 1,
    -- get message info.
    -- The client will directly display the x_msg_data (which is already
    -- translated) if the x_msg_count = 1;
    -- Else i.e if  x_msg_count > 1, client will call the FND_MSG_PUB.Get
    -- Server-side procedure to access the messages, and consolidate them
    -- and display (or) to display one message after another.
    FND_MSG_PUB.Count_And_Get
        (       p_count        =>      x_msg_count,
                p_data         =>      x_msg_data
        );

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF l_debug = 1 THEN
          mdebug('Delete_Valid_Category: Apps Exception raised');
        END IF;
        IF FND_API.To_Boolean( p_commit ) THEN
          ROLLBACK TO Delete_Valid_Category_PUB;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
        (       p_count        =>      x_msg_count,
                p_data         =>      x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF l_debug = 1 THEN
          mdebug('Delete_Valid_Category: Apps Unexpected Error');
        END IF;
        IF FND_API.To_Boolean( p_commit ) THEN
          ROLLBACK TO Delete_Valid_Category_PUB;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
        (       p_count        =>      x_msg_count,
                p_data         =>      x_msg_data
        );
    WHEN OTHERS THEN
        IF l_debug = 1 THEN
          mdebug('Delete_Valid_Category: Exception -- OTHERS ');
        END IF;
        IF FND_API.To_Boolean( p_commit ) THEN
          ROLLBACK TO Delete_Valid_Category_PUB;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF c_get_items_in_cat%ISOPEN THEN
          CLOSE c_get_items_in_cat;
        END IF;
        IF      FND_MSG_PUB.Check_Msg_Level
                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       G_PKG_NAME          ,
                        l_api_name
                );
        END IF;
        FND_MSG_PUB.Count_And_Get
        (       p_count        =>      x_msg_count,
                p_data         =>      x_msg_data
        );
  END Delete_Valid_Category;

  ----------------------------------------------------------------------------
  --  12. Process_dml_on_row
  --  Bug: 5023883, Create/Update/Delete to the EGO tables
  ----------------------------------------------------------------------------
  PROCEDURE Process_Dml_On_Row
  (
    p_api_version         IN  NUMBER,
    p_category_set_id     IN  NUMBER,
    p_category_id         IN  NUMBER,
    p_mode                IN  VARCHAR2,
    x_return_status       OUT  NOCOPY VARCHAR2,
    x_errorcode           OUT  NOCOPY NUMBER,
    x_msg_count           OUT  NOCOPY NUMBER,
    x_msg_data            OUT  NOCOPY VARCHAR2
   ) IS

    l_pk_column_name_value_pairs   EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_data_column_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_attr_group_id                NUMBER;

   BEGIN

     /*Initialize the PK column array and the attribute data array */
      l_pk_column_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                          EGO_COL_NAME_VALUE_PAIR_OBJ('CATEGORY_SET_ID',
						      p_category_set_id));

      l_data_column_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                           EGO_COL_NAME_VALUE_PAIR_OBJ('CATEGORY_ID', p_category_id));

      EGO_USER_ATTRS_DATA_PVT.Perform_DML_On_Row(
                   p_api_version                  => 1.0
                  ,p_object_name                 => 'EGO_CATEGORY_SET'
                  ,p_application_id              => 431
                  ,p_attr_group_type             => 'EGO_PRODUCT_CATEGORY_SET'
                  ,p_attr_group_name             => 'SalesAndMarketing'
                  ,p_pk_column_name_value_pairs  => l_pk_column_name_value_pairs
                  ,p_class_code_name_value_pairs => NULL
                  ,p_data_level_name_value_pairs => l_data_column_name_value_pairs
                  ,p_attr_name_value_pairs       => null
		  ,p_mode                        => p_mode
                  ,p_use_def_vals_on_insert      => FND_API.G_TRUE
		  ,x_return_status               => x_return_status
                  ,x_errorcode                   => x_errorcode
                  ,x_msg_count                   => x_msg_count
                  ,x_msg_data                    => x_msg_data );
   EXCEPTION

      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_data := 'Executing - '||G_PKG_NAME||'.Process_Dml_On_Row '||SQLERRM;

   END Process_Dml_On_Row;

   --* Procedure Update_Category_Assignment added for Bug #3991044
   ----------------------------------------------------------------------------
   -- 13.  Update Category Assignment
   -- Bug: 3991044
   -- API to Update a valid Item Category Assignment
   -- All the validations are taken care in the Pvt pkg,
   -- so calling private pkg instead.
   ----------------------------------------------------------------------------
   PROCEDURE Update_Category_Assignment
   (
     p_api_version       IN   NUMBER,
     p_init_msg_list     IN   VARCHAR2 ,
     p_commit            IN   VARCHAR2 ,
     p_category_id       IN   NUMBER,
     p_old_category_id   IN   NUMBER,
     p_category_set_id   IN   NUMBER,
     p_inventory_item_id IN   NUMBER,
     p_organization_id   IN   NUMBER,
     x_return_status     OUT  NOCOPY VARCHAR2,
     x_errorcode         OUT  NOCOPY NUMBER,
     x_msg_count         OUT  NOCOPY NUMBER,
     x_msg_data          OUT  NOCOPY VARCHAR2
   )
   IS
     -- Start OF comments
     -- API name  : Delete_Category_Assignment
     -- TYPE      : Public
     -- Pre-reqs  : None
     -- FUNCTION  : Delete an item category assignment.
     --
     -- Version: Current Version 0.1
     -- Previous Version :  None
     -- Notes  : Stub Version
     --
     -- END OF comments
      l_api_name                     CONSTANT VARCHAR2(30)      := 'Update_Category_Assignment';
      -- On addition of any Required parameters the major version needs
      -- to change i.e. for eg. 1.X to 2.X.
      -- On addition of any Optional parameters the minor version needs
      -- to change i.e. for eg. X.6 to X.7.
      l_api_version           CONSTANT NUMBER   := 1.0;
      l_row_count            NUMBER;
     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   BEGIN
        -- Standard Start of API savepoint
      SAVEPOINT Update_Category_Assignment_PUB;

        -- Check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (l_api_version,
                                                p_api_version   ,
                                                l_api_name      ,
                                                G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
        -- Initialize API message list if necessary.
        -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
      END IF;

         INV_ITEM_MSG.set_Message_Mode('PLSQL');

      IF FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN
          INV_ITEM_MSG.set_Message_Level(INV_ITEM_MSG.g_Level_Warning);
      END IF;

         INV_ITEM_CATEGORY_PVT.Update_Category_Assignment
         (
           p_api_version        => p_api_version
        ,  p_init_msg_list      => p_init_msg_list
        ,  p_commit             => p_commit
        ,  p_inventory_item_id  => p_inventory_item_id
        ,  p_organization_id    => p_organization_id
        ,  p_category_set_id    => p_category_set_id
        ,  p_category_id        => p_category_id
        ,  p_old_category_id    => p_old_category_id
        ,  x_return_status      => x_return_status
        ,  x_msg_count          => x_msg_count
        ,  x_msg_data           => x_msg_data
        );


      IF (l_debug = 1) THEN
           mdebug('Update_Category_Assignment: Done!!');
      END IF;

      --add by geguo business event enhancement 8351807
      BEGIN
         IF (l_debug = 1) THEN
            mdebug('begin Raise EGO_WF_WRAPPER_PVT.G_ITEM_CAT_ASSIGN_EVENT business event');
         END IF;
         IF (x_return_status = fnd_api.g_RET_STS_SUCCESS) THEN
           INV_ITEM_EVENTS_PVT.Raise_Events (
             p_commit             => FND_API.To_Boolean(p_commit)
             ,p_event_name        => 'EGO_WF_WRAPPER_PVT.G_ITEM_CAT_ASSIGN_EVENT'
             ,p_dml_type          => 'UPDATE'
             ,p_inventory_item_id => p_inventory_item_id
             ,p_organization_id   => p_organization_id
             ,p_category_set_id   => p_category_set_id
             ,p_category_id       => p_category_id
             ,p_old_category_id   => p_old_category_id
             );
         END IF;

         IF (l_debug = 1) THEN
             mdebug('end Raise EGO_WF_WRAPPER_PVT.G_ITEM_CAT_ASSIGN_EVENT business event');
         END IF;

         EXCEPTION
           WHEN OTHERS THEN
             IF (l_debug = 1) THEN
               mdebug('error occured when Raise EGO_WF_WRAPPER_PVT.G_ITEM_CAT_ASSIGN_EVENT business event');
             END IF;
       END;
         -- Standard check of p_commit.
      IF FND_API.To_Boolean( p_commit ) THEN
                COMMIT WORK;
      END IF;

---    Bug 6272365 Start
---      x_return_status := FND_API.G_RET_STS_SUCCESS;
	INV_ITEM_MSG.Write_List;
---    Bug 6272365 End
      -- Standard call to get message count and if count is 1,
      -- get message info.
      -- The client will directly display the x_msg_data (which is already
      -- translated) if the x_msg_count = 1;
      -- Else i.e if  x_msg_count > 1, client will call the FND_MSG_PUB.Get
      -- Server-side procedure to access the messages, and consolidate them
      -- and display (or) to display one message after another.
      FND_MSG_PUB.Count_And_Get
                (       p_count        =>      x_msg_count,
                        p_data         =>      x_msg_data
                );
      EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO Update_Category_Assignment_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get
                (       p_count        =>      x_msg_count,
                        p_data         =>      x_msg_data
                );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO Update_Category_Assignment_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count        =>      x_msg_count,
                        p_data         =>      x_msg_data
                );
        WHEN OTHERS THEN
                ROLLBACK TO Update_Category_Assignment_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                        FND_MSG_PUB.Add_Exc_Msg
                        (       G_PKG_NAME          ,
                                l_api_name
                        );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (       p_count        =>      x_msg_count,
                        p_data         =>      x_msg_data
                );

   END Update_Category_Assignment;
   --* End of code for Bug #3991044

  /* Add this procedure by geguo for bug 8547305 */
  PROCEDURE Get_Category_Id_From_Cat_Rec(
    p_category_rec     IN   INV_ITEM_CATEGORY_PUB.CATEGORY_REC_TYPE,
    x_category_id      OUT  NOCOPY NUMBER,
    x_return_status    OUT  NOCOPY VARCHAR2,
    x_msg_data         OUT  NOCOPY VARCHAR2
  )IS
     l_category_rec INV_ITEM_CATEGORY_PUB.CATEGORY_REC_TYPE;
     l_category_id NUMBER;
     l_structure_id NUMBER;
     l_success BOOLEAN;
     l_concat_segs VARCHAR2(2000) ;
     l_n_segments NUMBER ;
     l_segment_array FND_FLEX_EXT.SegmentArray;
     l_delim VARCHAR2(10);
     l_indx        NUMBER;
     l_msg_text    VARCHAR2(1000);

     CURSOR segment_count(p_structure_id NUMBER) IS
        SELECT count(segment_num)
        FROM fnd_id_flex_segments
        WHERE application_id = G_INVENTORY_APP_ID
        AND id_flex_code = G_CAT_FLEX_CODE
        AND id_flex_num = p_structure_id
        AND (enabled_flag = 'Y' OR NVL(g_eni_upgarde_flag,'N') = 'Y');-- Added for 11.5.10 ENI Upgrade

     CURSOR c_get_segments(cp_flex_num NUMBER) IS
        SELECT application_column_name,rownum
        FROM   fnd_id_flex_segments
        WHERE  application_id = 401
          AND  id_flex_code   = 'MCAT'
          AND  id_flex_num    = cp_flex_num
          AND  enabled_flag   = 'Y'
        ORDER BY segment_num ASC;

     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

  BEGIN
    --Pre-Process the passed in category record.
    Preprocess_Category_Rec(G_INSERT, p_category_rec, l_category_rec) ;

    l_structure_id := l_category_rec.structure_id;
    OPEN segment_count(l_structure_id);
    FETCH segment_count INTO l_n_segments;
    IF (segment_count%NOTFOUND) THEN
       IF (l_debug = 1) THEN
          mdebug('The Number of segments not found');
       END IF;
    END IF;
    CLOSE segment_count;

    l_delim  := fnd_flex_ext.get_delimiter(G_INVENTORY_APP_SHORT_NAME,
                                           G_CAT_FLEX_CODE,
                                           l_structure_id);
    IF l_delim is NULL then
       fnd_message.set_name('OFA','FA_BUDGET_NO_SEG_DELIM');
       fnd_msg_pub.ADD;
       IF (l_debug = 1) THEN
         mdebug('Delimiter is NULL...Error');
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_indx := 1;
    FOR c_segments in c_get_segments(l_structure_id) LOOP
      IF c_segments.application_column_name = 'SEGMENT1' THEN
         l_segment_array(l_indx):= l_category_rec.segment1;
      ELSIF c_segments.application_column_name = 'SEGMENT2' THEN
         l_segment_array(l_indx):= l_category_rec.segment2;
      ELSIF c_segments.application_column_name = 'SEGMENT3' THEN
         l_segment_array(l_indx):= l_category_rec.segment3;
      ELSIF c_segments.application_column_name = 'SEGMENT4' THEN
         l_segment_array(l_indx):= l_category_rec.segment4;
      ELSIF c_segments.application_column_name = 'SEGMENT5' THEN
         l_segment_array(l_indx):= l_category_rec.segment5;
      ELSIF c_segments.application_column_name = 'SEGMENT6' THEN
         l_segment_array(l_indx):= l_category_rec.segment6;
      ELSIF c_segments.application_column_name = 'SEGMENT7' THEN
         l_segment_array(l_indx):= l_category_rec.segment7;
      ELSIF c_segments.application_column_name = 'SEGMENT8' THEN
         l_segment_array(l_indx):= l_category_rec.segment8;
      ELSIF c_segments.application_column_name = 'SEGMENT9' THEN
         l_segment_array(l_indx):= l_category_rec.segment9;
      ELSIF c_segments.application_column_name = 'SEGMENT10' THEN
         l_segment_array(l_indx):= l_category_rec.segment10;
      ELSIF c_segments.application_column_name = 'SEGMENT11' THEN
         l_segment_array(l_indx):= l_category_rec.segment11;
      ELSIF c_segments.application_column_name = 'SEGMENT12' THEN
         l_segment_array(l_indx):= l_category_rec.segment12;
      ELSIF c_segments.application_column_name = 'SEGMENT13' THEN
         l_segment_array(l_indx):= l_category_rec.segment13;
      ELSIF c_segments.application_column_name = 'SEGMENT14' THEN
         l_segment_array(l_indx):= l_category_rec.segment14;
      ELSIF c_segments.application_column_name = 'SEGMENT15' THEN
         l_segment_array(l_indx):= l_category_rec.segment15;
      ELSIF c_segments.application_column_name = 'SEGMENT16' THEN
         l_segment_array(l_indx):= l_category_rec.segment16;
      ELSIF c_segments.application_column_name = 'SEGMENT17' THEN
         l_segment_array(l_indx):= l_category_rec.segment17;
      ELSIF c_segments.application_column_name = 'SEGMENT18' THEN
         l_segment_array(l_indx):= l_category_rec.segment18;
      ELSIF c_segments.application_column_name = 'SEGMENT19' THEN
         l_segment_array(l_indx):= l_category_rec.segment19;
      ELSIF c_segments.application_column_name = 'SEGMENT20' THEN
         l_segment_array(l_indx):= l_category_rec.segment20;
      END IF;
      l_indx := l_indx+1;
    END LOOP;

    l_concat_segs :=fnd_flex_ext.concatenate_segments(l_n_segments,
                                                      l_segment_array,
                                                      l_delim);

    IF (l_debug = 1) THEN
      mdebug('Delim       : '||l_delim);
      mdebug('Flex code   : '||G_CAT_FLEX_CODE);
      mdebug('struct#     : '||l_structure_id);
      mdebug('# of segs   : '||to_char(l_n_segments));
      mdebug('Concat segs : '||l_concat_segs);
    END IF;

    l_success  :=   fnd_flex_keyval.validate_segs(
                            operation  => 'FIND_COMBINATION',
                            appl_short_name => G_INVENTORY_APP_SHORT_NAME,
                            key_flex_code => G_CAT_FLEX_CODE,
                            structure_number => l_structure_id,
                            concat_segments => l_concat_segs
                            );
    IF l_success THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_category_id := FND_FLEX_KEYVAL.combination_id;
    ELSE

      x_msg_data := FND_FLEX_KEYVAL.error_message;
      FND_MESSAGE.Set_Name('FND','FLEX-NO DYNAMIC INSERTS');
      l_msg_text := FND_MESSAGE.Get();

      IF (INSTR(x_msg_data,l_msg_text) > 0) THEN
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_category_id := -1;
      ELSE
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_data := 'Executing - '||G_PKG_NAME||'.get_category_id_from_cat_rec: '||SQLERRM;

  END Get_Category_Id_From_Cat_Rec;


END INV_ITEM_CATEGORY_PUB;

/
