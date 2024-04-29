--------------------------------------------------------
--  DDL for Package Body ZX_FC_MIGRATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_FC_MIGRATE_PKG" AS
/* $Header: zxfcmigrateb.pls 120.71.12010000.4 2009/06/11 08:51:50 srajapar ship $ */

l_multi_org_flag fnd_product_groups.multi_org_flag%type;
l_org_id NUMBER(15);

/*THIS IS THE COMMON PROCEDURE USED TO INSERT THE GLOBAL DESCRIPTIVE FLEXI FIELD PROMPT VALUE*/
PROCEDURE GDF_PROMPT_INSERT(
   p_classification_code   IN  ZX_FC_CODES_B.CLASSIFICATION_CODE%TYPE,
  p_classification_name    IN  ZX_FC_CODES_TL.CLASSIFICATION_NAME%TYPE,
  p_country_code           IN  ZX_FC_CODES_B.COUNTRY_CODE%TYPE,
  p_tax_event_class_code   IN  ZX_EVENT_CLASSES_VL.TAX_EVENT_CLASS_CODE%TYPE
  );

/* COMMON PROCEDURE USED TO ASSOCIATE THE ITEMS */
PROCEDURE ASSOCIATE_ITEMS(
  p_global_attribute_category     IN  varchar2);

 Procedure Update_Category_Set (p_category_set_name IN VARCHAR2,
                                p_category_set_id   IN NUMBER);

G_CLASSIFICATION_TYPE_ID       zx_fc_types_b.classification_type_id%type;
G_CLASSIFICATION_TYPE_CODE     zx_fc_types_b.classification_type_code%type;
G_CLASSIFICATION_TYPE_NAME     zx_fc_types_tl.classification_type_name%type;
G_CLASSIFICATION_TYP_CATEG_COD zx_fc_codes_denorm_b.classification_type_categ_code%type;
G_DELIMITER                    zx_fc_types_b.delimiter%type;

TYPE NUM_TAB is table of number          index by binary_integer;
TYPE VAR30_TAB is table of varchar2(30)  index by binary_integer;

CURSOR G_C_GET_TYPES_INFO(X_CLASSIFICATION_TYPE_CODE zx_fc_types_b.CLASSIFICATION_TYPE_CODE%type) is
    SELECT
    TYPE.CLASSIFICATION_TYPE_ID,
    TYPE.CLASSIFICATION_TYPE_CODE,
    TYPE.CLASSIFICATION_TYPE_NAME,
    TYPE.Classification_Type_Categ_Code,
    TYPE.DELIMITER
    FROM ZX_FC_TYPES_VL TYPE
     WHERE TYPE.CLASSIFICATION_TYPE_CODE = X_CLASSIFICATION_TYPE_CODE;

/*===========================================================================+
|  Procedure:    CREATE_CATEGORY_SETS                                 |
|  Description:                                                       |
|                                                                     |
|  ARGUMENTS  :                                                       |
|                                                                     |
|                                                                     |
|   History                                                           |
|    rguerrer   Created                                               |
|                                                                     |
+===========================================================================*/


 Procedure Create_Category_Sets  IS

  p_category_set   mtl_category_sets_b.Category_set_ID%TYPE;
  p_flexfield      FND_FLEX_KEY_API.FLEXFIELD_TYPE;
  p_structure_id   FND_FLEX_KEY_API.STRUCTURE_TYPE;
  v_structure_id   FND_FLEX_KEY_API.STRUCTURE_TYPE;
  l_segment        FND_FLEX_KEY_API.segment_type;
  p_StatCode_Segment    FND_FLEX_KEY_API.segment_type;
  l_flex_exists         Boolean;
  l_structure_exists    Boolean;
  l_segment_exists      Boolean;
  p_StatCode_struct     FND_FLEX_KEY_API.STRUCTURE_TYPE;
  msg                   VARCHAR2(1000);
  l_category_set_id     mtl_category_sets_b.Category_set_ID%TYPE;

  l_structure_id  NUMBER;
  l_control_level NUMBER;
  l_row_id        VARCHAR2(100);
  l_next_val      NUMBER;

 Begin

   fnd_flex_key_api.set_session_mode('seed_data');
   l_flex_exists:= FALSE;

  l_flex_exists:= fnd_flex_key_api.flexfield_exists(appl_short_name => 'INV',flex_code => 'MCAT',flex_title => 'Item Categories');

  If l_flex_exists Then
     p_flexfield:= fnd_flex_key_api.find_flexfield(appl_short_name => 'INV',flex_code => 'MCAT');

  BEGIN
   p_StatCode_struct:= fnd_flex_key_api.find_structure(p_flexfield,'STATISTICAL_CODE');
   l_structure_exists:=TRUE;

    EXCEPTION
      WHEN OTHERS THEN
      msg := 'ERROR: struct not found' || fnd_flex_key_api.message;
      l_structure_exists:=FALSE;
   END;

   IF NOT l_structure_exists THEN
   BEGIN
   p_StatCode_struct:=fnd_flex_key_api.new_structure(flexfield => p_flexfield,
           structure_code => 'STATISTICAL_CODE',
           structure_title => 'Statistical Code',
           description =>  'Statistical Code',
           view_name  => NULL,
           freeze_flag =>  'Y',
           enabled_flag => 'Y',
           segment_separator => '.',
           cross_val_flag => 'N',
           freeze_rollup_flag=> 'N',
           dynamic_insert_flag => 'N',
           shorthand_enabled_flag => 'N',
           shorthand_prompt  => NULL,
           shorthand_length  => NULL   );

    fnd_flex_key_api.add_structure(p_flexfield,p_StatCode_struct);


       BEGIN
       -- Coded needed to instantiate the Structure
        p_statcode_struct:= fnd_flex_key_api.find_structure(p_flexfield,'STATISTICAL_CODE');
       l_structure_exists:=TRUE;

        EXCEPTION
        WHEN OTHERS THEN
        msg := SUBSTR('ERROR: struct not found' || fnd_flex_key_api.message,1,225);
       END;

    EXCEPTION
      WHEN OTHERS THEN
      msg := substr('ERROR: ' || fnd_flex_key_api.message,1,225);
   END;

  END IF;

   IF l_structure_exists THEN

   BEGIN
     p_StatCode_Segment:= fnd_flex_key_api.find_segment(flexfield=> p_flexfield,structure=> p_StatCode_struct,segment_name=>'Code');
     l_segment_exists:=TRUE;
    EXCEPTION
      WHEN OTHERS THEN
      msg := substr('ERROR: ' || fnd_flex_key_api.message,1,225);
      l_segment_exists:=FALSE;
   END;

   IF NOT l_segment_exists THEN
     BEGIN
     p_StatCode_Segment:= fnd_flex_key_api.new_segment(flexfield => p_flexfield,
         structure => p_StatCode_struct,
         segment_name => 'Code',
         description  => 'Code',
         column_name  => 'SEGMENT1',
         segment_number => 10,
         enabled_flag  => 'Y',
         displayed_flag => 'Y',
         indexed_flag => 'Y',
         value_set   => '30 Characters',
         default_type => NULL,
         default_value => NULL,
         required_flag  =>'Y',
         security_flag  => 'N',
         range_code => NULL,
         display_size => 25,
         description_size => 50,
         concat_size => 25,
         lov_prompt => 'Code',
         window_prompt => 'Code',
         runtime_property_function => NULL,
         additional_where_clause =>   NULL);

      EXCEPTION
      WHEN OTHERS THEN
      msg :=  SUBSTR('ERROR: ' || fnd_flex_key_api.message,1,225);
     END;

     BEGIN
      fnd_flex_key_api.add_segment(p_flexfield,p_StatCode_struct,p_StatCode_Segment);
      l_segment_exists:=TRUE;
      EXCEPTION
      WHEN OTHERS THEN
      msg := SUBSTR('ERROR: ' || fnd_flex_key_api.message,1,225);
      l_segment_exists:=FALSE;
     END;
    END IF;

   END IF; -- Structure available for segment

   End If; -- Flexfield Exists.

   IF l_segment_exists THEN

     SELECT FIFS.ID_FLEX_NUM
     INTO l_structure_id
     FROM FND_ID_FLEX_STRUCTURES FIFS
     WHERE FIFS.ID_FLEX_CODE = 'MCAT'
   AND FIFS.APPLICATION_ID = 401
   AND FIFS.ID_FLEX_STRUCTURE_CODE = 'STATISTICAL_CODE';

   BEGIN
      SELECT category_set_ID, structure_id
      INTO l_category_set_id, l_structure_id
     FROM mtl_category_sets
     WHERE Category_Set_Name ='STATISTICAL_CODE';
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
     l_category_set_id := NULL;
   END;

     IF l_category_set_id IS NULL THEN

     SELECT MTL_CATEGORY_SETS_S.NEXTVAL into l_next_val from dual;
     -- Assuming Master Organization Control level
     -- Bug 6441455, X_CONTROL_LEVEL - Passing 2 for Org control

       MTL_CATEGORY_SETS_PKG.INSERT_ROW (
         X_ROWID => l_row_id,
         X_CATEGORY_SET_ID         => l_next_val,
         X_CATEGORY_SET_NAME       => 'STATISTICAL_CODE',
         X_DESCRIPTION             => 'Statistical Code',
         X_STRUCTURE_ID            => l_structure_id,
         X_VALIDATE_FLAG           => 'N',
         X_MULT_ITEM_CAT_ASSIGN_FLAG   => 'N',
         X_CONTROL_LEVEL_UPDT_FLAG     => 'Y',
         X_MULT_ITEM_CAT_UPDT_FLAG     => 'Y',
         X_VALIDATE_FLAG_UPDT_FLAG     => 'Y',
         X_HIERARCHY_ENABLED           => 'N',
         X_CONTROL_LEVEL               => 2,
         X_DEFAULT_CATEGORY_ID         => null,
         X_LAST_UPDATE_DATE            => SYSDATE,
         X_LAST_UPDATED_BY             => 0,
         X_CREATION_DATE               => SYSDATE,
         X_CREATED_BY                  => 0,
         X_LAST_UPDATE_LOGIN           => 0 );
       END IF;

 -- Update the descriptions to set them in correct Language, Source Lang.
        Update_Category_Set ('STATISTICAL_CODE',l_category_set_id);

   END IF;

 END;


 Procedure Create_Category_Set (p_structure_code IN VARCHAR2,
                                p_structure_desc IN VARCHAR2,
                                p_category_set_name IN VARCHAR2,
                                p_category_set_desc IN VARCHAR2 )
 IS

  p_category_set   mtl_category_sets_b.Category_set_ID%TYPE;
  p_flexfield      FND_FLEX_KEY_API.FLEXFIELD_TYPE;
  p_structure_id   FND_FLEX_KEY_API.STRUCTURE_TYPE;
  v_structure_id   FND_FLEX_KEY_API.STRUCTURE_TYPE;
  l_segment        FND_FLEX_KEY_API.segment_type;
  p_StatCode_Segment    FND_FLEX_KEY_API.segment_type;
  l_flex_exists         Boolean;
  l_structure_exists    Boolean;
  l_segment_exists      Boolean;
  p_StatCode_struct     FND_FLEX_KEY_API.STRUCTURE_TYPE;
  msg                   VARCHAR2(1000);
  l_category_set_id     mtl_category_sets_b.Category_set_ID%TYPE;

  l_structure_id  NUMBER;
  l_control_level NUMBER;
  l_row_id        VARCHAR2(100);
  l_next_val      NUMBER;

 Begin

   fnd_flex_key_api.set_session_mode('seed_data');
   l_flex_exists:= FALSE;

  l_flex_exists:= fnd_flex_key_api.flexfield_exists(appl_short_name => 'INV',flex_code => 'MCAT',flex_title => 'Item Categories');

  If l_flex_exists Then
    p_flexfield:= fnd_flex_key_api.find_flexfield(appl_short_name => 'INV',flex_code => 'MCAT');

    BEGIN
     p_StatCode_struct:= fnd_flex_key_api.find_structure(p_flexfield,p_structure_code);
     l_structure_exists:=TRUE;

    EXCEPTION
      WHEN OTHERS THEN
        msg := 'ERROR: struct not found' || fnd_flex_key_api.message;
        l_structure_exists:=FALSE;
    END;

    IF NOT l_structure_exists THEN
      BEGIN
        p_StatCode_struct:=fnd_flex_key_api.new_structure(flexfield => p_flexfield,
             structure_code => p_structure_code,
             structure_title => p_structure_desc,
             description =>  p_structure_desc,
             view_name  => NULL,
             freeze_flag =>  'Y',
             enabled_flag => 'Y',
             segment_separator => '.',
             cross_val_flag => 'N',
             freeze_rollup_flag=> 'N',
             dynamic_insert_flag => 'N',
             shorthand_enabled_flag => 'N',
             shorthand_prompt  => NULL,
             shorthand_length  => NULL   );

        fnd_flex_key_api.add_structure(p_flexfield,p_StatCode_struct);


        BEGIN
         -- Code needed to instantiate the Structure
          p_statcode_struct:= fnd_flex_key_api.find_structure(p_flexfield,p_structure_code);
          l_structure_exists:=TRUE;

        EXCEPTION
          WHEN OTHERS THEN
            msg := SUBSTR('ERROR: struct not found' || fnd_flex_key_api.message,1,225);
        END;

      EXCEPTION
        WHEN OTHERS THEN
        msg := substr('ERROR: ' || fnd_flex_key_api.message,1,225);
      END;

    END IF;

   IF l_structure_exists THEN

     BEGIN
       p_StatCode_Segment:= fnd_flex_key_api.find_segment(flexfield=> p_flexfield,structure=> p_StatCode_struct,segment_name=>'Code');
       l_segment_exists:=TRUE;
     EXCEPTION
       WHEN OTHERS THEN
         msg := substr('ERROR: ' || fnd_flex_key_api.message,1,225);
         l_segment_exists:=FALSE;
     END;

     IF NOT l_segment_exists THEN
       BEGIN
         p_StatCode_Segment:= fnd_flex_key_api.new_segment(flexfield => p_flexfield,
           structure => p_StatCode_struct,
           segment_name => 'Code',
           description  => 'Code',
           column_name  => 'SEGMENT1',
           segment_number => 10,
           enabled_flag  => 'Y',
           displayed_flag => 'Y',
           indexed_flag => 'Y',
           value_set   => '30 Characters',
           default_type => NULL,
           default_value => NULL,
           required_flag  =>'Y',
           security_flag  => 'N',
           range_code => NULL,
           display_size => 25,
           description_size => 50,
           concat_size => 25,
           lov_prompt => 'Code',
           window_prompt => 'Code',
           runtime_property_function => NULL,
           additional_where_clause =>   NULL);

       EXCEPTION
         WHEN OTHERS THEN
           msg :=  SUBSTR('ERROR: ' || fnd_flex_key_api.message,1,225);
       END;

       BEGIN
         fnd_flex_key_api.add_segment(p_flexfield,p_StatCode_struct,p_StatCode_Segment);
         l_segment_exists:=TRUE;
       EXCEPTION
         WHEN OTHERS THEN
           msg := SUBSTR('ERROR: ' || fnd_flex_key_api.message,1,225);
           l_segment_exists:=FALSE;
       END;
     END IF;

   END IF; -- Structure available for segment

  End If; -- Flexfield Exists.

  IF l_segment_exists THEN

     SELECT FIFS.ID_FLEX_NUM
     INTO l_structure_id
     FROM FND_ID_FLEX_STRUCTURES FIFS
     WHERE FIFS.ID_FLEX_CODE = 'MCAT'
       AND FIFS.APPLICATION_ID = 401
       AND FIFS.ID_FLEX_STRUCTURE_CODE = p_structure_code;

    BEGIN
       SELECT category_set_ID, structure_id
      INTO l_category_set_id, l_structure_id
     FROM mtl_category_sets
     WHERE Category_Set_Name = p_category_set_name;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_category_set_id := NULL;
    END;

    IF l_category_set_id IS NULL THEN
      -- 8593634 hard coding id's to be used for specific category sets
      IF p_category_set_name = 'FISCAL_CLASSIFICATION' THEN
        l_next_val := 1100000209;
      ELSIF p_category_set_name = 'INTENDED_USE' THEN
        l_next_val := 1100000211;
      ELSE
        SELECT MTL_CATEGORY_SETS_S.NEXTVAL into l_next_val from dual;
      END IF;

     -- Assuming Master Organization Control level
     -- Bug 6441455, X_CONTROL_LEVEL - Passing 2 for Org control

       MTL_CATEGORY_SETS_PKG.INSERT_ROW (
         X_ROWID => l_row_id,
         X_CATEGORY_SET_ID         => l_next_val,
         X_CATEGORY_SET_NAME       => p_category_set_name,
         X_DESCRIPTION             => p_category_set_desc,
         X_STRUCTURE_ID            => l_structure_id,
         X_VALIDATE_FLAG           => 'N',
         X_MULT_ITEM_CAT_ASSIGN_FLAG   => 'N',
         X_CONTROL_LEVEL_UPDT_FLAG     => 'Y',
         X_MULT_ITEM_CAT_UPDT_FLAG     => 'Y',
         X_VALIDATE_FLAG_UPDT_FLAG     => 'Y',
         X_HIERARCHY_ENABLED           => 'N',
         X_CONTROL_LEVEL               => 2,
         X_DEFAULT_CATEGORY_ID         => null,
         X_LAST_UPDATE_DATE            => SYSDATE,
         X_LAST_UPDATED_BY             => 0,
         X_CREATION_DATE               => SYSDATE,
         X_CREATED_BY                  => 0,
         X_LAST_UPDATE_LOGIN           => 0 );
       END IF;

 -- Update the descriptions to set them in correct Language, Source Lang.
       Update_Category_Set (p_category_set_name,l_category_set_id);

   END IF;

 END;


  Procedure Update_Category_Set (p_category_set_name IN VARCHAR2,
                                 p_category_set_id   IN NUMBER)
  IS
    msg                 VARCHAR2(1000);
    l_structure_id      NUMBER;
    l_control_level     NUMBER;
    l_context           VARCHAR2(500);
    l_global_att        VARCHAR2(500);
    l_category_status   VARCHAR2(500);
 Begin

  IF P_CATEGORY_SET_NAME = 'STATISTICAL_CODE' THEN
    l_context :='JE.HU.APINXWKB.FINAL';
    l_global_att := 'GLOBAL_ATTRIBUTE6';
  ELSIF P_CATEGORY_SET_NAME = 'WINE_CIGARRETE_CATEGORY' THEN
    l_context :='JA.TW.ARXRWMAI.CASH_RECEIPTS';
    l_global_att := 'GLOBAL_ATTRIBUTE2';
  ELSIF P_CATEGORY_SET_NAME = 'FISCAL_CLASSIFICATION' THEN
    l_context :='JL.BR.ARXSDML.Additional';
    l_global_att := 'GLOBAL_ATTRIBUTE1';
  ELSIF P_CATEGORY_SET_NAME = 'INTENDED_USE' THEN
    l_context :='JL.AR.APXINWKB.INVOICES';
    l_global_att := 'GLOBAL_ATTRIBUTE10';
  END IF;

  update MTL_CATEGORY_SETS_TL MS set (
    SOURCE_LANG ,
    LANGUAGE   ,
    CATEGORY_SET_NAME  ,
    DESCRIPTION   ,
    LAST_UPDATE_DATE ,
    LAST_UPDATED_BY  ,
    LAST_UPDATE_LOGIN ) =
      (SELECT
         SOURCE_LANG ,
         LANGUAGE  ,
         P_CATEGORY_SET_NAME,
         FORM_LEFT_PROMPT,
         SYSDATE,
         0,
         0
      FROM FND_DESCR_FLEX_COL_USAGE_TL FL
      WHERE FL.LANGUAGE= MS.LANGUAGE
      AND DESCRIPTIVE_FLEX_CONTEXT_CODE = l_context
      AND APPLICATION_COLUMN_NAME = l_global_att)
  where  CATEGORY_SET_ID = P_CATEGORY_SET_ID;

  EXCEPTION WHEN OTHERS THEN
   l_category_status :='NOTEXISTS';

 end;


/*===========================================================================+
|  Procedure:    CREATE_MTL_CATEGORIES                                      |
|  Description:  This Procedure  describes data migration for               |
|                LOOKUPS To Item Categories                                 |
|                                                                           |
|  ARGUMENTS  :                                                             |
|                                                                           |
|  NOTES                                                                    |
|                                                                           |
|  History                                                                  |
|    zmohiudd  Created                                                      |
|                                                                           |
+===========================================================================*/

PROCEDURE CREATE_MTL_CATEGORIES (
  l_lookup_type      IN VARCHAR2,
  l_category_name    IN VARCHAR2,
  l_category_status  OUT NOCOPY VARCHAR2,
  l_category_set     OUT NOCOPY mtl_category_sets_b.Category_set_ID%TYPE,
  l_structure_id     OUT NOCOPY mtl_category_sets_b.structure_id%TYPE )
IS
    p_category_set   MTL_CATEGORY_SETS_B.CATEGORY_SET_ID%TYPE;
    p_structure_id      mtl_category_sets_b.structure_id%TYPE;
    l_category_set_exists BOOLEAN;

BEGIN

  /* Get the Seeded Item Category Set Value */
  BEGIN
    SELECT Category_set_ID, structure_id
    INTO p_category_set, p_structure_id
    FROM mtl_category_sets
    WHERE Category_Set_Name =l_category_name;

     l_category_set_exists :=TRUE;
     l_category_status :='EXISTS';

    EXCEPTION WHEN NO_DATA_FOUND THEN
      l_category_set_exists :=FALSE;
      l_category_status :='NOTEXISTS';
      p_category_set:=NULL;
       p_structure_id:=NULL;
  END;
   l_category_set:= p_category_set;
   l_structure_id:= p_structure_id;

 /* Create Categories */
  IF l_category_set_exists=TRUE THEN

  INSERT INTO MTL_CATEGORIES_B(
  CATEGORY_ID,
  STRUCTURE_ID,
  DISABLE_DATE,
  SUMMARY_FLAG,
  ENABLED_FLAG,
  WEB_STATUS,
  SUPPLIER_ENABLED_FLAG,
  START_DATE_ACTIVE,
  END_DATE_ACTIVE,
  SEGMENT1,
  CREATED_BY,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  CREATION_DATE,
  LAST_UPDATE_LOGIN
  )
  SELECT
    mtl_categories_s.nextval,
   p_structure_id,
   fnd.End_date_active,
   'N',
   'Y',
   'N',
   'N',
   start_date_active,
   NULL,
   fnd.LOOKUP_CODE,
   fnd_global.user_id,
   SYSDATE,
   fnd_global.user_id,
   SYSDATE,
   FND_GLOBAL.CONC_LOGIN_ID
  FROM     fnd_lookup_values fnd
  WHERE   lookup_type = l_lookup_type
      AND language=userenv('lang') -- Bug 6441455
      AND  enabled_flag = 'Y'
    AND NOT EXISTS
   (select 'Y' from  mtl_categories_b m where m.structure_id = p_structure_id
   and m.segment1=fnd.lookup_code);

 /* Create same languages existing in the Lookup Type */
   INSERT INTO MTL_CATEGORIES_TL(
    CATEGORY_ID,
    LANGUAGE,
    SOURCE_LANG,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN)
   SELECT mtl.category_id,
    fnd.LANGUAGE,
    fnd.source_lang,
    fnd.Meaning,
    SYSDATE,
    fnd_global.user_id,
    SYSDATE,
    fnd_global.user_id,
    FND_GLOBAL.CONC_LOGIN_ID
   FROM  fnd_lookup_values fnd, mtl_categories_b mtl
   WHERE lookup_type = l_lookup_type
   AND   FND.lookup_code = mtl.segment1
   AND NOT EXISTS
   (select 'Y' FROM  mtl_categories_tl m
       where m.category_id= mtl.category_id
       and m.language=fnd.language);

  END IF;

  EXCEPTION WHEN OTHERS THEN
   l_category_status :='NOTEXISTS';

END CREATE_MTL_CATEGORIES;

/*===========================================================================+
|  Procedure:    MTL_SYSTEM_ITEMS                                           |
|  Description:  This Procedure  describes data migration for               |
|                Fiscal Classification migration for                        |
|                MTL_SYSTEM_ITEMS.                                          |
|            Migration of Item Associations                                 |
|                                                                           |
|  ARGUMENTS  :                                                             |
|                                                                           |
|  NOTES                                                                    |
|                                                                           |
|  History                                                                  |
|    zmohiudd  Created                                                      |
|                                                                           |
+===========================================================================*/

PROCEDURE MTL_SYSTEM_ITEMS IS

  p_flexfield        FND_FLEX_KEY_API.FLEXFIELD_TYPE;

  l_structure_id    mtl_category_sets_b.structure_id%TYPE;
  l_category_status      VARCHAR2(200);
  l_category_set         mtl_category_sets_b.Category_set_ID%TYPE;

  l_Inventory_Category_Set     mtl_category_sets_vl.Category_set_ID%TYPE;
  l_Item_id         Number;
  l_Item_organization_id      Number;
  l_record_type        zx_Fc_types_b.record_type_code%type;

  l_classification_name       fnd_lookup_values.meaning%type;

  l_lookup_code        fnd_lookup_values.lookup_code%type;
  l_meaning         fnd_lookup_values.meaning%type;
  l_language        fnd_lookup_values.language%type;
  l_start_date_active      fnd_lookup_values.start_date_active%type;
  l_end_date_active      fnd_lookup_values.end_date_active%type;
  l_source_lang        fnd_lookup_values.source_lang%type;
  i           integer:=0;
  l_fc_id          zx_fc_codes_b.classification_id%type;
  l_return_status        varchar2(200);
  l_errorcode        number;
  l_msg_count        number;
  l_MSG_DATA        varchar2(200);


BEGIN

   arp_util_tax.debug( ' MTL_SYSTEM_ITEMS.. (+) ' );

-- Bug # 5300607. We need to remove Inventory installed check.
-- IF Zx_Migrate_Util.IS_INSTALLED('INV') = 'Y' THEN

   -- If Hungary is installed then
   IF Is_Country_Installed(7002, 'jehuloc') THEN

  arp_util_tax.debug( 'Initialized the category set value.. ');

  -- Call Create Categories
  Create_Category_Sets;
  CREATE_MTL_CATEGORIES('JGZZ_STATISTICAL_CODE','STATISTICAL_CODE',l_category_status,l_category_set,l_structure_id);

  -- Call a common procedure to create FC Types
  FC_TYPE_INSERT('STATISTICAL_CODE','Statistical Code',l_category_set);

  /* Create Association to items move to zxitemcatmig.sql   */

  /* Regime Association to Fiscal Type */

  arp_util_tax.debug( 'Creating the regime association to fiscal type.. ');

  INSERT ALL INTO  ZX_FC_TYPES_REG_ASSOC
    (Tax_regime_code,
    classification_type_code,
    effective_FROM,
    effective_to,
    record_type_code,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login,
    classif_regime_id,
    object_version_number)
  VALUES
    (tax_regime_code,
    'STATISTICAL_CODE',
    SYSDATE,
    NULL,
    'MIGRATED',
    fnd_global.user_id,
    SYSDATE,
    fnd_global.user_id,
    SYSDATE,
    FND_GLOBAL.CONC_LOGIN_ID,
    zx_fc_types_reg_assoc_s.nextval,
    1)
  SELECT   unique tax_regime_code
  FROM ZX_RATES_B rates,
       AP_TAX_CODES_ALL codes
  WHERE
             codes.tax_id                    = nvl(rates.source_id, rates.tax_rate_id) and
             codes.global_attribute_category = 'JE.HU.APXTADTC.TAX_ORIGIN' and
             rates.record_type_code          = 'MIGRATED' and
             not exists
             (select null from ZX_FC_TYPES_REG_ASSOC
              where classification_type_code = 'STATISTICAL_CODE' and
                    tax_regime_code          = rates.tax_regime_code);

   END IF; -- End of Hungary installed Checking

   -- If Argentina is installed then
   IF Is_Country_Installed(7004, 'jlarloc') THEN

  --Bug # 3587896
  /* Create Codes under Intended Use Fiscal Classifications */
  arp_util_tax.debug( 'Creating the Codes under Intended Use Fiscal Classifications ');

  FC_CODE_FROM_FND_LOOKUP('INTENDED_USE','JLZZ_AP_DESTINATION_CODE','AR',NULL,NULL,NULL,1);

   END IF;

   -- If Hungary is installed then
   IF Is_Country_Installed(7002, 'jehuloc') THEN

  /* Create Codes under Product Category Statistical Code */
  arp_util_tax.debug( 'Creating the Statistical Code.. ');

  --select zx_fc_codes_b_s.nextval into l_fc_id from dual;

  FIRST_LEVEL_FC_CODE_INSERT('PRODUCT_CATEGORY','STATISTICAL_CODE','Statistical Code',NULL,l_fc_id);

  FC_CODE_FROM_FND_LOOKUP('PRODUCT_CATEGORY','JGZZ_STATISTICAL_CODE',NULL,l_fc_id,'STATISTICAL_CODE','Statistical Code',2);

  arp_util_tax.debug( ' MTL_SYSTEM_ITEMS end of hungary ');

   END IF;

   -- If Brazil is installed then
   IF ( Is_Country_Installed(7004, 'jlbrloc') or Is_Country_Installed(7004, 'jlarloc') or
        Is_Country_Installed(7004, 'jlcoloc') )THEN

  --Bug# 3588145
  -- Insert the FISCAL CLASSIFICATION CODE for BRAZIL in level one
  FIRST_LEVEL_FC_CODE_INSERT('PRODUCT_CATEGORY','FISCAL CLASSIFICATION CODE',
           'Fiscal Classification Code',NULL,l_fc_id);

  -- Insert into second level

   OPEN G_C_GET_TYPES_INFO('PRODUCT_CATEGORY');

  FETCH G_C_GET_TYPES_INFO  INTO
      G_CLASSIFICATION_TYPE_ID,
      G_CLASSIFICATION_TYPE_CODE,
      G_CLASSIFICATION_TYPE_NAME,
      G_CLASSIFICATION_TYP_CATEG_COD,
      G_DELIMITER;

  CLOSE G_C_GET_TYPES_INFO;
        /* Removed the reference to obsolete object JL_BR_PO_FISC_CLASSIF_ALL. Bug # 5150296 */
  INSERT
  INTO ZX_FC_CODES_B
      (classification_type_code,
      classification_id,
      classification_code,
      effective_from,
      effective_to,
      parent_classification_code,
      parent_classification_id,
      country_code,
      record_type_code,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
                  object_version_number)
  (  SELECT
            'PRODUCT_CATEGORY',
      zx_fc_codes_b_s.nextval,
      lookups.LOOKUP_CODE fc_code,
      nvl(START_DATE_ACTIVE, to_date('01/01/1951','DD/MM/YYYY')) effective_from,
      END_DATE_ACTIVE effective_to,
      'FISCAL CLASSIFICATION CODE',--parent_classification_code
      l_fc_id,           --parent_classification_id
      'BR',
      'MIGRATED',
      fnd_global.user_id,
      SYSDATE,
      fnd_global.user_id,
      SYSDATE,
      FND_GLOBAL.CONC_LOGIN_ID,
      1
     FROM
      FND_LOOKUPS lookups
    WHERE
      lookups.LOOKUP_TYPE = 'JLZZ_AR_TX_FISCAL_CLASS_CODE'
    AND     NOT EXISTS  -- this condition makes sure we dont duplicate data
          (select NULL from  ZX_FC_CODES_B Codes where
      codes.classification_type_code = 'PRODUCT_CATEGORY'
      and codes.parent_classification_id = nvl(l_fc_id,codes.parent_classification_id)
      and codes.classification_code = lookups.lookup_code )
  );


  INSERT ALL INTO ZX_FC_CODES_TL
      (CLASSIFICATION_ID,
      CLASSIFICATION_NAME,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      LANGUAGE,
      SOURCE_LANG)
  VALUES (classification_id,
        CASE WHEN fc_name = UPPER(fc_name)
         THEN    Initcap(fc_name)
         ELSE
           fc_name
         END,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.user_id,
      SYSDATE,
      FND_GLOBAL.CONC_LOGIN_ID,
      LANGUAGE,
      SOURCE_LANGUAGE)
  INTO ZX_FC_CODES_DENORM_B(
     CLASSIFICATION_TYPE_ID,
     CLASSIFICATION_TYPE_CODE,
     CLASSIFICATION_TYPE_NAME,
     CLASSIFICATION_TYPE_CATEG_CODE,
     CLASSIFICATION_ID,
     CLASSIFICATION_CODE,
     CLASSIFICATION_NAME,
     LANGUAGE,
     EFFECTIVE_FROM,
     EFFECTIVE_TO,
     ENABLED_FLAG,
     ANCESTOR_ID,
     ANCESTOR_CODE,
     ANCESTOR_NAME,
     CONCAT_CLASSIF_CODE,
     CONCAT_CLASSIF_NAME,
     CLASSIFICATION_CODE_LEVEL,
     COUNTRY_CODE,
     SEGMENT1,
     SEGMENT2,
     SEGMENT3,
     SEGMENT4,
     SEGMENT5,
     SEGMENT6,
     SEGMENT7,
     SEGMENT8,
     SEGMENT9,
     SEGMENT10,
     SEGMENT1_NAME,
     SEGMENT2_NAME,
     SEGMENT3_NAME,
     SEGMENT4_NAME,
     SEGMENT5_NAME,
     SEGMENT6_NAME,
     SEGMENT7_NAME,
     SEGMENT8_NAME,
     SEGMENT9_NAME,
     SEGMENT10_NAME,
     CREATED_BY,
     CREATION_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN,
     LAST_UPDATE_DATE,
     REQUEST_ID,
     PROGRAM_ID,
     PROGRAM_APPLICATION_ID,
     PROGRAM_LOGIN_ID,
     RECORD_TYPE_CODE)
  VALUES (
    G_CLASSIFICATION_TYPE_ID,
    G_CLASSIFICATION_TYPE_CODE,
    G_CLASSIFICATION_TYPE_NAME,
    G_CLASSIFICATION_TYP_CATEG_COD,
    classification_id,
    fc_code,
    fc_name,
    LANGUAGE,
    effective_from,
    effective_to,
    'Y',
    l_fc_id,
    'FISCAL CLASSIFICATION CODE',
    'Fiscal Classification Code',
    'FISCAL CLASSIFICATION CODE'||G_DELIMITER||fc_code,
    'Fiscal Classification Code'||G_DELIMITER||fc_name,
    2,
    'BR',
    'FISCAL CLASSIFICATION CODE',
    fc_code,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    'Fiscal Classification Code',
    fc_name,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    fnd_global.user_id,
    SYSDATE,
    fnd_global.user_id,
    FND_GLOBAL.CONC_LOGIN_ID,
    sysdate,
    FND_GLOBAL.CONC_REQUEST_ID,
    fnd_global.CONC_PROGRAM_ID,
    235,
    FND_GLOBAL.CONC_LOGIN_ID,
    'MIGRATED')

    SELECT
      FL.LOOKUP_CODE fc_code,
      FL.MEANING fc_name,
      nvl(START_DATE_ACTIVE,to_date('01/01/1951','DD/MM/YYYY')) effective_from,
      END_DATE_ACTIVE effective_to,
      FL.LANGUAGE LANGUAGE,
      FL.SOURCE_LANG SOURCE_LANGUAGE,
      codes.classification_id
    FROM
      ZX_FC_CODES_b Codes,
      FND_LOOKUP_VALUES FL,
      FND_LANGUAGES L
    WHERE
       Codes.classification_type_code = 'PRODUCT_CATEGORY'
    AND     Codes.parent_classification_id=l_fc_id
    AND     Codes.classification_code = FL.lookup_code
    AND     Codes.RECORD_TYPE_CODE = 'MIGRATED'
    AND     FL.LOOKUP_TYPE = 'JLZZ_AR_TX_FISCAL_CLASS_CODE'
    AND     FL.VIEW_APPLICATION_ID = 0
    AND     FL.SECURITY_GROUP_ID = 0
    AND     FL.language=L.language_code(+)
    AND     L.INSTALLED_FLAG in ('I', 'B')
    AND     NOT EXISTS  -- this condition makes sure we dont duplicate data
          (select NULL
          from ZX_FC_CODES_DENORM_B codes
          where  codes.classification_type_code = G_CLASSIFICATION_TYPE_CODE
        and codes.classification_code = fl.lookup_code
        and codes.ancestor_id = nvl(l_fc_id,codes.ancestor_id)
        and codes.language = l.language_code);

  arp_util_tax.debug( ' Calling the bulk api to create categories..(+)');

  Create_Category_Set ('FISCAL_CLASSIFICATION',
                       'Fiscal Classification',
                       'FISCAL_CLASSIFICATION',
                       'Fiscal Classification');

  CREATE_MTL_CATEGORIES('JLZZ_AR_TX_FISCAL_CLASS_CODE', 'FISCAL_CLASSIFICATION',
                        l_category_status,l_category_set, l_structure_id);

        -- Call a common procedure to create FC Types
  FC_TYPE_INSERT('FISCAL_CLASSIFICATION','Fiscal Classification Code',l_category_set);

  -- Create Regime Association for 'FISCAL CLASSIFICATION CODE'
  arp_util_tax.debug( 'Creating the regime association to fiscal type.. ');

  INSERT ALL INTO
  ZX_FC_TYPES_REG_ASSOC
    (Tax_regime_code,
    classification_type_code,
    effective_FROM,
    effective_to,
    record_type_code,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login,
    classif_regime_id,
    object_version_number)

  VALUES
    (TAX_REGIME_CODE,
    'FISCAL_CLASSIFICATION',
    SYSDATE,
    NULL,
    'MIGRATED',
    fnd_global.user_id,
    SYSDATE,
    fnd_global.user_id,
    SYSDATE,
    FND_GLOBAL.CONC_LOGIN_ID,
    zx_fc_types_reg_assoc_s.nextval,
    1)
  SELECT
    unique tax_regime_code
  FROM ZX_RATES_B rates,
       AP_TAX_CODES_ALL codes
  WHERE
             codes.tax_id                    = nvl(rates.source_id, rates.tax_rate_id) and
             codes.global_attribute_category = 'JL.BR.INVIDITM.AR.Fiscal' and
             rates.record_type_code          = 'MIGRATED' and
             not exists
             (select null from ZX_FC_TYPES_REG_ASSOC
              where classification_type_code = 'FISCAL_CLASSIFICATION' and
                    tax_regime_code          = rates.tax_regime_code);


  arp_util_tax.debug( ' Calling the bulk api to create categories..(-)');

  END IF; -- End of Brazil checking

arp_util_tax.debug( 'MTL_SYSTEM_ITEMS (-) ');

END MTL_SYSTEM_ITEMS ;

/*===========================================================================+
|  Procedure:    FC_ENTITIES                                                |
|  Description:  This Procedure  describes data migration for               |
|                Fiscal Classification migration for source of              |
|                GDF's on AP and AR.                                        |
|                                                                           |
|  ARGUMENTS  :                                                             |
|                                                                           |
|  NOTES                                                                    |
|                                                                           |
|  History                                                                  |
|    zmohiudd      Created                                                  |
|    Venkat  14th May 04  Creation of Reporting Type and  Reporting         |
|         Usage for FISCAL PRINTER and CAI NUMBER                           |
|            Bug # 3587896                                                  |
|    Venkat  18th Aug 04  Added code for o2c setup migration                |
|        Bug # 3811144 (handling of translation                             |
|        record issue in _TL table)                                         |
+===========================================================================*/

PROCEDURE FC_ENTITIES IS

  CURSOR c_wine_category IS
    SELECT Category_set_ID
    FROM   mtl_category_sets
    WHERE  Category_Set_Name ='WINE_CIGARRETE_CATEGORY';

  l_LANGUAGE          zx_fc_types_tl.language%type;
  l_fc_id            zx_fc_codes_b.classification_id%type;
  p_category_set          mtl_category_sets_vl.Category_set_ID%TYPE;
  p_flexfield              FND_FLEX_KEY_API.FLEXFIELD_TYPE;
  p_structure_id          FND_FLEX_KEY_API.STRUCTURE_TYPE;
  v_structure_id          FND_FLEX_KEY_API.STRUCTURE_TYPE;
  v_classification_code        zx_fc_codes_b.classification_code%type;
  v_classification_name        zx_fc_codes_tl.classification_name%type;
  v_effective_from        date;
  v_effective_to          date;
  v_language          zx_fc_codes_tl.language%type;
  v_RECORD_TYPE          zx_Fc_codes_b.RECORD_TYPE_CODE%type;

BEGIN

   arp_util_tax.debug( ' FC_ENTITIES .. (+) ' );

   -- If Brazil is installed then
   IF Is_Country_Installed(7004, 'jlbrloc') THEN

  /* Create Codes under User Defined Fiscal Classifications */

  --Bug # 3588145
  arp_util_tax.debug( 'Creating the Codes under User Defined Fiscal Classifications ');

  OPEN G_C_GET_TYPES_INFO('USER_DEFINED');

  FETCH G_C_GET_TYPES_INFO INTO
      G_CLASSIFICATION_TYPE_ID,
      G_CLASSIFICATION_TYPE_CODE,
      G_CLASSIFICATION_TYPE_NAME,
      G_CLASSIFICATION_TYP_CATEG_COD,
      G_DELIMITER;

  CLOSE G_C_GET_TYPES_INFO;

  INSERT
  INTO ZX_FC_CODES_B
      (classification_type_code,
      classification_id,
      classification_code,
      effective_from,
      effective_to,
      parent_classification_code,
      parent_classification_id,
      country_code,
      record_type_code,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
    object_version_number)
  (SELECT    'USER_DEFINED',
      zx_fc_codes_b_s.nextval,
      cfo_code,
      creation_date,
      null,
      null,----parent_classification_code
      null,----parent_classification_id
      'BR',
      'MIGRATED',
      fnd_global.user_id,
      SYSDATE,
      fnd_global.user_id,
      SYSDATE,
      FND_GLOBAL.CONC_LOGIN_ID,
      1
  FROM   JL_BR_AP_OPERATIONS JLBR
  WHERE   NOT EXISTS
     -- this condition makes sure we dont duplicate data
    (select NULL from  ZX_FC_CODES_B Codes where
      codes.classification_type_code = 'USER_DEFINED'
      and codes.parent_classification_id is null
      and codes.classification_code = jlbr.cfo_code)
  );


  INSERT ALL
  INTO ZX_FC_CODES_TL
      (CLASSIFICATION_ID,
      CLASSIFICATION_NAME,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      LANGUAGE,
      SOURCE_LANG)
  VALUES   (classification_id,
      CASE WHEN Meaning = UPPER(Meaning)
      THEN    Initcap(Meaning)
      ELSE
           Meaning
      END,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.user_id,
      SYSDATE,
      FND_GLOBAL.CONC_LOGIN_ID,
      lang_code,
      userenv('LANG'))
  INTO ZX_FC_CODES_DENORM_B(
     CLASSIFICATION_TYPE_ID,
     CLASSIFICATION_TYPE_CODE,
     CLASSIFICATION_TYPE_NAME,
     CLASSIFICATION_TYPE_CATEG_CODE,
     CLASSIFICATION_ID,
     CLASSIFICATION_CODE,
     CLASSIFICATION_NAME,
     LANGUAGE,
     EFFECTIVE_FROM,
     EFFECTIVE_TO,
     ENABLED_FLAG,
     ANCESTOR_ID,
     ANCESTOR_CODE,
     ANCESTOR_NAME,
     CONCAT_CLASSIF_CODE,
     CONCAT_CLASSIF_NAME,
     CLASSIFICATION_CODE_LEVEL,
     COUNTRY_CODE,
     SEGMENT1,
     SEGMENT2,
     SEGMENT3,
     SEGMENT4,
     SEGMENT5,
     SEGMENT6,
     SEGMENT7,
     SEGMENT8,
     SEGMENT9,
     SEGMENT10,
     SEGMENT1_NAME,
     SEGMENT2_NAME,
     SEGMENT3_NAME,
     SEGMENT4_NAME,
     SEGMENT5_NAME,
     SEGMENT6_NAME,
     SEGMENT7_NAME,
     SEGMENT8_NAME,
     SEGMENT9_NAME,
     SEGMENT10_NAME,
     CREATED_BY,
     CREATION_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN,
     LAST_UPDATE_DATE,
     REQUEST_ID,
     PROGRAM_ID,
     PROGRAM_APPLICATION_ID,
     PROGRAM_LOGIN_ID,
     RECORD_TYPE_CODE)
  VALUES (
    G_CLASSIFICATION_TYPE_ID,
    G_CLASSIFICATION_TYPE_CODE,
    G_CLASSIFICATION_TYPE_NAME,
    G_CLASSIFICATION_TYP_CATEG_COD,
    classification_id,
    Code,
    Meaning,
    lang_code,
    creation_date,
    null,
    'Y',
    null,
    null,
    null,
    Code,
    Meaning,
    1,
    'BR',
    Code,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Meaning,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    fnd_global.user_id,
    SYSDATE,
    fnd_global.user_id,
    FND_GLOBAL.CONC_LOGIN_ID,
    sysdate,
    FND_GLOBAL.CONC_REQUEST_ID,
    fnd_global.CONC_PROGRAM_ID,
    235,
    FND_GLOBAL.CONC_LOGIN_ID,
    'MIGRATED')
  SELECT  cfo_code Code,
    cfo_description Meaning,
    JLBR.creation_date ,
    l.language_code lang_code,
    codes.classification_id
  FROM  ZX_FC_CODES_B Codes,
    JL_BR_AP_OPERATIONS JLBR,
    FND_LANGUAGES L
  WHERE
    Codes.classification_type_code = G_CLASSIFICATION_TYPE_CODE
    and  Codes.parent_classification_id is null
    AND  Codes.classification_code=JLBR.cfo_code
    AND  Codes.RECORD_TYPE_CODE = 'MIGRATED'
    AND  L.INSTALLED_FLAG in ('I', 'B')
    AND  NOT EXISTS  -- this condition makes sure we dont duplicate data
    (select NULL from ZX_FC_CODES_DENORM_B codes
     where codes.classification_type_code = G_CLASSIFICATION_TYPE_CODE
           and codes.classification_code = JLBR.cfo_code
           and codes.ancestor_id is null
           and codes.language = l.language_code);

  arp_util_tax.debug( 'Create OPERATION FISCAL CODE under the Transaction Business Category Type-Level 2: BR');

  -- Insert the GDF under TBC FC TYPE - 2nd level
  GDF_PROMPT_INSERT('OPERATION FISCAL CODE', 'Operation Fiscal Code', 'BR', 'PURCHASE_TRANSACTION');

  OPEN G_C_GET_TYPES_INFO('TRX_BUSINESS_CATEGORY');

  FETCH G_C_GET_TYPES_INFO INTO
      G_CLASSIFICATION_TYPE_ID,
      G_CLASSIFICATION_TYPE_CODE,
      G_CLASSIFICATION_TYPE_NAME,
      G_CLASSIFICATION_TYP_CATEG_COD,
      G_DELIMITER;

  CLOSE G_C_GET_TYPES_INFO;


  --Create a Code under the Transaction Business Category Type, 3rd Level

  arp_util_tax.debug( 'Create Code under the Transaction Business Category Type-Level 3: BR');

  INSERT
  INTO ZX_FC_CODES_B (
    classification_type_code,
    classification_id,
    classification_code,
    effective_from,
    effective_to,
    parent_classification_code,
    parent_classification_id,
    Country_code,
    record_type_code,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login,
    object_version_number
        )
  SELECT
    'TRX_BUSINESS_CATEGORY',
    zx_fc_codes_b_s.nextval,
    cfo_code ,
    ap_op.creation_date,
    null,
    fc.classification_code,--parent_classification_code
    fc.classification_id,  --parent_classification_id
    'BR',
    'MIGRATED',
    fnd_global.user_id,
    SYSDATE,
    fnd_global.user_id,
    SYSDATE,
    FND_GLOBAL.CONC_LOGIN_ID,
    1
  FROM
    JL_BR_AP_OPERATIONS ap_op,
    ZX_FC_CODES_DENORM_B fc,
    ZX_EVENT_CLASSES_VL event
  WHERE
    fc.classification_type_code = 'TRX_BUSINESS_CATEGORY'
    and fc.classification_code='OPERATION FISCAL CODE'
    and fc.ancestor_code = event.tax_event_class_code
    and fc.language = userenv('LANG')
    and fc.classification_code_level = 2
                and event.tax_event_class_code = 'PURCHASE_TRANSACTION'
                and   NOT EXISTS  -- this condition makes sure we dont duplicate data
          ( select NULL from  ZX_FC_CODES_B Codes where
      codes.classification_type_code = 'TRX_BUSINESS_CATEGORY'
      and codes.parent_classification_id =
        nvl(fc.classification_id,codes.parent_classification_id)
      and codes.classification_code = ap_op.cfo_code );

  INSERT ALL
  INTO ZX_FC_CODES_TL
    (CLASSIFICATION_ID,
    CLASSIFICATION_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG)
  VALUES  (classification_id,
        CASE WHEN Meaning = UPPER(Meaning)
         THEN    Initcap(Meaning)
         ELSE
           Meaning
         END,
    fnd_global.user_id,
    SYSDATE,
    fnd_global.user_id,
    SYSDATE,
    FND_GLOBAL.CONC_LOGIN_ID,
    lang_code,
    userenv('LANG'))
  INTO ZX_FC_CODES_DENORM_B(
    CLASSIFICATION_TYPE_ID,
    CLASSIFICATION_TYPE_CODE,
    CLASSIFICATION_TYPE_NAME,
    CLASSIFICATION_TYPE_CATEG_CODE,
    CLASSIFICATION_ID,
    CLASSIFICATION_CODE,
    CLASSIFICATION_NAME,
    LANGUAGE,
    EFFECTIVE_FROM,
    EFFECTIVE_TO,
    ENABLED_FLAG,
    ANCESTOR_ID,
    ANCESTOR_CODE,
    ANCESTOR_NAME,
    CONCAT_CLASSIF_CODE,
    CONCAT_CLASSIF_NAME,
    CLASSIFICATION_CODE_LEVEL,
    COUNTRY_CODE,
    SEGMENT1,
    SEGMENT2,
    SEGMENT3,
    SEGMENT4,
    SEGMENT5,
    SEGMENT6,
    SEGMENT7,
    SEGMENT8,
    SEGMENT9,
    SEGMENT10,
    SEGMENT1_NAME,
    SEGMENT2_NAME,
    SEGMENT3_NAME,
    SEGMENT4_NAME,
    SEGMENT5_NAME,
    SEGMENT6_NAME,
    SEGMENT7_NAME,
    SEGMENT8_NAME,
    SEGMENT9_NAME,
    SEGMENT10_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    REQUEST_ID,
    PROGRAM_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_LOGIN_ID,
    RECORD_TYPE_CODE)
    VALUES (
    G_CLASSIFICATION_TYPE_ID,
    G_CLASSIFICATION_TYPE_CODE,
    G_CLASSIFICATION_TYPE_NAME,
    G_CLASSIFICATION_TYP_CATEG_COD,
    classification_id,
    Code,
    Meaning,
    lang_code,
    creation_date,
    null,
    'Y',
    parent_fc_id,
    parent_fc_code,
    parent_fc_name,
    tax_event_class_code ||G_DELIMITER || parent_fc_code || G_DELIMITER || Code,
    Name || G_DELIMITER || parent_fc_name || G_DELIMITER || Meaning,
    3,
    'BR',
    tax_event_class_code,
    parent_fc_code,
    Code,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Name,
    parent_fc_name,
    Meaning,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    fnd_global.user_id,
    SYSDATE,
    fnd_global.user_id,
    FND_GLOBAL.CONC_LOGIN_ID,
    sysdate,
    FND_GLOBAL.CONC_REQUEST_ID,
    fnd_global.CONC_PROGRAM_ID,
    235,
    FND_GLOBAL.CONC_LOGIN_ID,
    'MIGRATED')

  SELECT  cfo_code Code,
    cfo_description Meaning,
    tax_event_class_code,
    event.tax_event_class_name name,
    fc.classification_id as parent_fc_id,
    fc.classification_code as parent_fc_code,
    fc.classification_name as parent_fc_name,
    ap_op.creation_date,
    codes.classification_id,
    l.language_code lang_code
  FROM
    ZX_FC_CODES_DENORM_B fc,
    ZX_FC_CODES_B Codes,
    JL_BR_AP_OPERATIONS ap_op,
    FND_LANGUAGES L,
    ZX_EVENT_CLASSES_VL event
  WHERE
        fc.classification_type_code = 'TRX_BUSINESS_CATEGORY'
    and fc.classification_code='OPERATION FISCAL CODE'
    and fc.language = userenv('LANG')
    and fc.ancestor_code = event.tax_event_class_code
                and event.tax_event_class_code = 'PURCHASE_TRANSACTION'
    and fc.classification_code_level = 2

    and Codes.classification_type_code = G_CLASSIFICATION_TYPE_CODE
          and Codes.parent_classification_id = fc.classification_id
          and Codes.classification_code = ap_op.cfo_code
                and Codes.RECORD_TYPE_CODE = 'MIGRATED'
          and L.INSTALLED_FLAG in ('I', 'B')

          AND NOT EXISTS  -- this condition makes sure we dont duplicate data
                    (select NULL from ZX_FC_CODES_DENORM_B codes where
               codes.classification_type_code = G_CLASSIFICATION_TYPE_CODE
          and codes.classification_code = ap_op.cfo_code
          and codes.ancestor_id = nvl(fc.classification_id,codes.ancestor_id)
          and codes.language = l.language_code);


   END IF; -- End of Brazil checking

   -- If Taiwan is installed then
   IF Is_Country_Installed(7000, 'jatwloc') THEN


  -- Deductible Type Extract - Under Level 2

  arp_util_tax.debug( 'Create the Deductible type extract for country : TAIWAN ');
  FC_CODE_GDF_INSERT('DEDUCTIBLE TYPE','Deductible Type','TW','JATW_DEDUCTIBLE_TYPE','PURCHASE_TRANSACTION','MIGRATED');

  -- Document Subtype GUI Extract

  arp_util_tax.debug( 'Create the Document Subtype GUI Extract for country : TAIWAN ');


  /* Create rows for Parent Records */

  OPEN G_C_GET_TYPES_INFO('DOCUMENT_SUBTYPE');

  FETCH G_C_GET_TYPES_INFO  INTO
      G_CLASSIFICATION_TYPE_ID,
      G_CLASSIFICATION_TYPE_CODE,
      G_CLASSIFICATION_TYPE_NAME,
      G_CLASSIFICATION_TYP_CATEG_COD,
      G_DELIMITER;

  CLOSE G_C_GET_TYPES_INFO;

  FIRST_LEVEL_FC_CODE_INSERT('DOCUMENT_SUBTYPE','GUI TYPE','Government Uniform Invoice Type','TW',l_fc_id);


  /* Create Codes on level 2*/

  arp_util_tax.debug( 'Create Codes on level 2 for country : TAIWAN ');

  INSERT
  INTO ZX_FC_CODES_B (
    classification_type_code,
    classification_id,
    classification_code,
    effective_from,
    effective_to,
    parent_classification_code,
    parent_classification_id,
    Country_code,
    record_type_code,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login,
    object_version_number)
  SELECT
    'DOCUMENT_SUBTYPE',
    zx_fc_codes_b_s.nextval,
    lookup_code,      --classification_code
    nvl(start_date_active,to_date('01/01/1951','DD/MM/YYYY')),  --effective_from
    end_date_active,    --effective_to
    'GUI TYPE',      --parent_classification_code
    l_fc_id,      --parent_classification_id
    'TW',
    'MIGRATED',
    fnd_global.user_id,
    SYSDATE,
    fnd_global.user_id,
    SYSDATE,
    FND_GLOBAL.CONC_LOGIN_ID,
    1

  FROM   FND_LOOKUP_VALUES lookups
  WHERE
        lookups.lookup_type='JATW_GUI_TYPE'
        AND     LANGUAGE = userenv('LANG')
  AND  NOT EXISTS  -- this condition makes sure we dont duplicate data
    (select NULL from  ZX_FC_CODES_B Codes where
          codes.classification_type_code = 'DOCUMENT_SUBTYPE'
      and codes.parent_classification_id =
        nvl(l_fc_id,codes.parent_classification_id)
      and codes.classification_code = lookups.lookup_code
    );

  INSERT ALL INTO
   ZX_FC_CODES_TL(
    CLASSIFICATION_ID,
    CLASSIFICATION_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG)
  VALUES
    (classification_id,
        CASE WHEN Meaning = UPPER(Meaning)
         THEN    Initcap(Meaning)
         ELSE
           Meaning
         END,
    fnd_global.user_id,
    SYSDATE,
    fnd_global.user_id,
    SYSDATE,
    FND_GLOBAL.CONC_LOGIN_ID,
    language,
    source_lang)

  INTO  ZX_FC_CODES_DENORM_B
    (CLASSIFICATION_TYPE_ID,
    CLASSIFICATION_TYPE_CODE,
    CLASSIFICATION_TYPE_NAME,
    CLASSIFICATION_TYPE_CATEG_CODE,
    CLASSIFICATION_ID,
    CLASSIFICATION_CODE,
    CLASSIFICATION_NAME,
    LANGUAGE,
    EFFECTIVE_FROM,
    EFFECTIVE_TO,
    ENABLED_FLAG,
    ANCESTOR_ID,
    ANCESTOR_CODE,
    ANCESTOR_NAME,
    CONCAT_CLASSIF_CODE,
    CONCAT_CLASSIF_NAME,
    CLASSIFICATION_CODE_LEVEL,
    COUNTRY_CODE,
    SEGMENT1,
    SEGMENT2,
    SEGMENT3,
    SEGMENT4,
    SEGMENT5,
    SEGMENT6,
    SEGMENT7,
    SEGMENT8,
    SEGMENT9,
    SEGMENT10,
    SEGMENT1_NAME,
    SEGMENT2_NAME,
    SEGMENT3_NAME,
    SEGMENT4_NAME,
    SEGMENT5_NAME,
    SEGMENT6_NAME,
    SEGMENT7_NAME,
    SEGMENT8_NAME,
    SEGMENT9_NAME,
    SEGMENT10_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    REQUEST_ID,
    PROGRAM_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_LOGIN_ID,
    RECORD_TYPE_CODE)
    VALUES (
    G_CLASSIFICATION_TYPE_ID,
    G_CLASSIFICATION_TYPE_CODE,
    G_CLASSIFICATION_TYPE_NAME,
    G_CLASSIFICATION_TYP_CATEG_COD,
    classification_id,
    lookup_code,
    Meaning,
    language,
    start_date_active,
    end_date_active,
    enabled_flag,
    l_fc_id,
    'GUI TYPE',
    'Government Uniform Invoice Type',
    'GUI TYPE' || G_DELIMITER || lookup_code,
    'Government Uniform Invoice Type' || G_DELIMITER || Meaning,
    2,
    'TW',
    'GUI TYPE',
    lookup_code,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    'Government Uniform Invoice Type',
    Meaning,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    fnd_global.user_id,
    SYSDATE,
    fnd_global.user_id,
    FND_GLOBAL.CONC_LOGIN_ID,
    sysdate,
    FND_GLOBAL.CONC_REQUEST_ID,
    fnd_global.CONC_PROGRAM_ID,
    235,
    FND_GLOBAL.CONC_LOGIN_ID,
    'MIGRATED')
  SELECT
    lookup_code,
    meaning,
    nvl(start_date_active,to_date('01/01/1951','DD/MM/YYYY')) start_date_active,
    end_date_active,
    source_lang,
    language,
    lv.enabled_flag,
    classification_id
  FROM
    ZX_FC_CODES_B Codes,
    FND_LOOKUP_VALUES LV,
    FND_LANGUAGES L
  WHERE
        Codes.classification_type_code = G_CLASSIFICATION_TYPE_CODE
    AND Codes.parent_classification_id = l_fc_id
          AND Codes.classification_code = LV.lookup_code
          AND Codes.RECORD_TYPE_CODE IN ('MIGRATED','SEEDED')
    AND LV.VIEW_APPLICATION_ID = 7000
    AND LV.SECURITY_GROUP_ID = 0
    AND LV.lookup_type='JATW_GUI_TYPE'
    AND LV.language=L.language_code(+)
    AND L.INSTALLED_FLAG in ('I', 'B')
    AND NOT EXISTS  -- this condition makes sure we dont duplicate data
       (select NULL from ZX_FC_CODES_DENORM_B codes where
          codes.classification_type_code = G_CLASSIFICATION_TYPE_CODE
      and codes.classification_code = lv.lookup_code
      and codes.ancestor_id = nvl(l_fc_id,codes.ancestor_id)
      and codes.language = l.language_code);

  /*
    Wine/ Cigarette Extract
  */

  arp_util_tax.debug( 'Create Wine/ Cigarette Extract for country : TAIWAN ');

  /* Get the Seeded Item Category Set Value */
  Create_Category_Set ('WINE_CIGARRETE_CATEGORY',
                       'Wine Cigarrete',
                       'WINE_CIGARRETE_CATEGORY',
                       'Wine Cigarrete');
  p_category_set := Null;

  OPEN C_WINE_CATEGORY;

  fetch C_WINE_CATEGORY
  INTO  p_category_set;

  IF p_category_set is not null then

    -- Call a common procedure to create FC Types
    FC_TYPE_INSERT('WINE CIGARETTE','Wine Cigarette',p_category_set);

  END IF;

  close C_WINE_CATEGORY;

  SELECT
    'WINE CIGARETTE',
    'Wine Cigarette',
    sysdate,
    Null,
    'US',
    'MIGRATED'
  INTO
    V_classification_code,
    V_classification_name,
    V_effective_from,
    V_effective_to,
    V_language,
    V_RECORD_TYPE
  FROM DUAl;

  FIRST_LEVEL_FC_CODE_INSERT('PRODUCT_CATEGORY','WINE CIGARETTE','Wine Cigarette','TW',l_fc_id);


   END IF; -- End of Taiwan checking

   arp_util_tax.debug( ' FC_ENTITIES ...(-) ' );

END FC_ENTITIES;

/*===========================================================================+
|  Procedure:    COUNTRY_DEFAULT                                            |
|  Description:  This Procedure  describes data migration for               |
|                Fiscal Classification migration for                        |
|                COUNTRY_DEFAULT                                            |
|                                                                           |
|  ARGUMENTS  :                                                             |
|                                                                           |
|  NOTES                                                                    |
|                                                                           |
|  History                                                                  |
|    zmohiudd  Created                                                      |
|                                                                           |
+===========================================================================*/


PROCEDURE COUNTRY_DEFAULT IS

BEGIN

  arp_util_tax.debug( ' COUNTRY_DEFAULT .. (+) ' );

  If Zx_Migrate_Util.IS_INSTALLED('INV') = 'Y'  then

     -- If Hungary is installed then
     IF Is_Country_Installed(7002, 'jehuloc') THEN

    arp_util_tax.debug( ' Creating data for Hungary..' );

    INSERT INTO ZX_FC_COUNTRY_DEFAULTS (
      COUNTRY_CODE,
      PRIMARY_INVENTORY_CATEGORY_SET,
      INTENDED_USE_DEFAULT,
      PRODUCT_CATEG_DEFAULT,
      RECORD_TYPE_CODE,
      COUNTRY_DEFAULTS_ID,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      object_version_number)
    SELECT
      'HU',
      OWNER_ID_NUM,
      Null,
      Null,
      'MIGRATED',
      zx_fc_country_defaults_s.nextval,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.user_id,
      SYSDATE,
      FND_GLOBAL.CONC_LOGIN_ID,
      1
    FROM   ZX_FC_TYPES_B
    WHERE
          classification_type_code = 'STATISTICAL_CODE'
      and classification_type_categ_code ='PRODUCT_FISCAL_CLASS'
    AND    NOT EXISTS
      (SELECT 1 FROM ZX_FC_COUNTRY_DEFAULTS WHERE COUNTRY_CODE = 'HU');

     END IF;

     -- If Poland is installed then
     IF Is_Country_Installed(7002, 'jeplloc') THEN

    arp_util_tax.debug( ' Creating data for Poland..' );

    INSERT INTO ZX_FC_COUNTRY_DEFAULTS (
      COUNTRY_CODE,
      PRIMARY_INVENTORY_CATEGORY_SET,
      INTENDED_USE_DEFAULT,
      PRODUCT_CATEG_DEFAULT,
      RECORD_TYPE_CODE,
      COUNTRY_DEFAULTS_ID,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      object_version_number)
    SELECT
      'PL',
      OWNER_ID_NUM,
      Null,
      Null,
      'MIGRATED',
      zx_fc_country_defaults_s.nextval,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.user_id,
      SYSDATE,
      FND_GLOBAL.CONC_LOGIN_ID,
      1
    FROM   ZX_FC_TYPES_B
    WHERE
          classification_type_code = 'STATISTICAL_CODE'
      and classification_type_categ_code ='PRODUCT_FISCAL_CLASS'
     AND    NOT EXISTS
                          (SELECT 1 FROM ZX_FC_COUNTRY_DEFAULTS WHERE COUNTRY_CODE = 'PL');


     END IF; -- End of Poland checking

           IF Is_Country_Installed(7004, 'jlarloc') THEN

                arp_util_tax.debug( ' Creating data for Argentina..' );

                INSERT INTO ZX_FC_COUNTRY_DEFAULTS (
                        COUNTRY_CODE,
                        PRIMARY_INVENTORY_CATEGORY_SET,
                        INTENDED_USE_DEFAULT,
                        PRODUCT_CATEG_DEFAULT,
                        RECORD_TYPE_CODE,
                        COUNTRY_DEFAULTS_ID,
                        created_by,
                        creation_date,
                        last_updated_by,
                        last_update_date,
                        last_update_login,
                        object_version_number)
               SELECT
                        'AR',
                        OWNER_ID_NUM,
                        Null,
                        Null,
                        'MIGRATED',
                        zx_fc_country_defaults_s.nextval,
                        fnd_global.user_id,
                        SYSDATE,
                        fnd_global.user_id,
                        SYSDATE,
                        FND_GLOBAL.CONC_LOGIN_ID,
                        1
                FROM    ZX_FC_TYPES_B
                WHERE   classification_type_code = 'FISCAL_CLASSIFICATION'
                        and classification_type_categ_code ='PRODUCT_FISCAL_CLASS'
                AND    NOT EXISTS
                        (SELECT 1 FROM ZX_FC_COUNTRY_DEFAULTS WHERE COUNTRY_CODE = 'AR');
           END IF;


           -- If Hungary is installed then
           IF Is_Country_Installed(7004, 'jlbrloc') THEN

                arp_util_tax.debug( ' Creating data for Brazil..' );

                INSERT INTO ZX_FC_COUNTRY_DEFAULTS (
                        COUNTRY_CODE,
                        PRIMARY_INVENTORY_CATEGORY_SET,
                        INTENDED_USE_DEFAULT,
                        PRODUCT_CATEG_DEFAULT,
                        RECORD_TYPE_CODE,
                        COUNTRY_DEFAULTS_ID,
                        created_by,
                        creation_date,
                        last_updated_by,
                        last_update_date,
                        last_update_login,
                        object_version_number)
                SELECT
                        'BR',
                        OWNER_ID_NUM,
                        Null,
                        Null,
                        'MIGRATED',
                        zx_fc_country_defaults_s.nextval,
                        fnd_global.user_id,
                        SYSDATE,
                        fnd_global.user_id,
                        SYSDATE,
                        FND_GLOBAL.CONC_LOGIN_ID,
                        1
                FROM    ZX_FC_TYPES_B
                WHERE   classification_type_code = 'FISCAL_CLASSIFICATION'
                        and classification_type_categ_code ='PRODUCT_FISCAL_CLASS'
                AND    NOT EXISTS
                        (SELECT 1 FROM ZX_FC_COUNTRY_DEFAULTS WHERE COUNTRY_CODE = 'BR');
           END IF;

          IF Is_Country_Installed(7004, 'jlcoloc') THEN

                arp_util_tax.debug( ' Creating data for Colombia..' );
                INSERT INTO ZX_FC_COUNTRY_DEFAULTS (
                        COUNTRY_CODE,
                        PRIMARY_INVENTORY_CATEGORY_SET,
                        INTENDED_USE_DEFAULT,
                        PRODUCT_CATEG_DEFAULT,
                        RECORD_TYPE_CODE,
                        COUNTRY_DEFAULTS_ID,
                        created_by,
                        creation_date,
                        last_updated_by,
                        last_update_date,
                        last_update_login,
                        object_version_number)
                SELECT
                        'CO',
                        OWNER_ID_NUM,
                        Null,
                        Null,
                        'MIGRATED',
                        zx_fc_country_defaults_s.nextval,
                        fnd_global.user_id,
                        SYSDATE,
                        fnd_global.user_id,
                        SYSDATE,
                        FND_GLOBAL.CONC_LOGIN_ID,
                        1
                FROM    ZX_FC_TYPES_B
                WHERE  classification_type_code = 'FISCAL_CLASSIFICATION'
                        and classification_type_categ_code ='PRODUCT_FISCAL_CLASS'
                AND    NOT EXISTS
                        (SELECT 1 FROM ZX_FC_COUNTRY_DEFAULTS WHERE COUNTRY_CODE = 'CO');
           END IF;

  End if; -- End of Inventory checking

  arp_util_tax.debug( ' COUNTRY_DEFAULT .. (-) ' );

END COUNTRY_DEFAULT ;

/*THIS IS THE COMMON PROCEDURE USED TO INSERT THE FIRST LEVEL FC CODES*/

PROCEDURE FIRST_LEVEL_FC_CODE_INSERT(
  p_classification_type_code   IN  ZX_FC_CODES_B.CLASSIFICATION_TYPE_CODE%TYPE,
   p_classification_code     IN  ZX_FC_CODES_B.CLASSIFICATION_CODE%TYPE,
   p_classification_name     IN  ZX_FC_CODES_TL.CLASSIFICATION_NAME%TYPE,
   p_country_code      IN  ZX_FC_CODES_B.COUNTRY_CODE%TYPE,
   x_fc_id       OUT NOCOPY ZX_FC_CODES_B.CLASSIFICATION_ID%TYPE
   )
IS

BEGIN

  arp_util_tax.debug('FIRST_LEVEL_FC_CODE_INSERT(+)');
  arp_util_tax.debug('p_classification_type_code = ' || p_classification_type_code);
  arp_util_tax.debug('p_classification_code = ' || p_classification_code);

   OPEN G_C_GET_TYPES_INFO(p_classification_type_code);

  FETCH G_C_GET_TYPES_INFO  INTO
      G_CLASSIFICATION_TYPE_ID,
      G_CLASSIFICATION_TYPE_CODE,
      G_CLASSIFICATION_TYPE_NAME,
      G_CLASSIFICATION_TYP_CATEG_COD,
      G_DELIMITER;

  CLOSE G_C_GET_TYPES_INFO;

  --select zx_fc_codes_b_s.nextval into x_fc_id from dual;

  INSERT
  INTO ZX_FC_CODES_B (
      classification_type_code,
      classification_id,
      classification_code,
      effective_from,
      effective_to,
      parent_classification_code,
      Country_code,
      record_type_code,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      object_version_number)
  SELECT
      p_classification_type_code,
      zx_fc_codes_b_s.nextval,
      p_classification_code,
      Sysdate,
      Null,
      Null,         ---parent_classification_code
      p_country_code,
      'SEEDED',
      120,
      SYSDATE,
      fnd_global.user_id,
      SYSDATE,
      FND_GLOBAL.CONC_LOGIN_ID,
      1
  FROM DUAL
  WHERE NOT EXISTS
    (select NULL from  ZX_FC_CODES_B Codes where
          codes.classification_type_code = p_classification_type_code
      and codes.parent_classification_id is null
      and codes.classification_code = p_classification_code
    );

  INSERT ALL
  INTO ZX_FC_CODES_TL(
      CLASSIFICATION_ID,
      CLASSIFICATION_NAME,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      LANGUAGE,
      SOURCE_LANG)
  VALUES
      (classification_id,    --Gives the classification id information
          CASE WHEN p_classification_name = UPPER(p_classification_name)
           THEN    Initcap(p_classification_name)
           ELSE
             p_classification_name
           END,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.user_id,
      SYSDATE,
      FND_GLOBAL.CONC_LOGIN_ID,
      lang_code,
      userenv('LANG'))
  INTO  ZX_FC_CODES_DENORM_B
      (CLASSIFICATION_TYPE_ID,
      CLASSIFICATION_TYPE_CODE,
      CLASSIFICATION_TYPE_NAME,
      CLASSIFICATION_TYPE_CATEG_CODE,
      CLASSIFICATION_ID,
      CLASSIFICATION_CODE,
      CLASSIFICATION_NAME,
      LANGUAGE,
      EFFECTIVE_FROM,
      EFFECTIVE_TO,
      ENABLED_FLAG,
      ANCESTOR_ID,
      ANCESTOR_CODE,
      ANCESTOR_NAME,
      CONCAT_CLASSIF_CODE,
      CONCAT_CLASSIF_NAME,
      CLASSIFICATION_CODE_LEVEL,
      COUNTRY_CODE,
      SEGMENT1,
      SEGMENT2,
      SEGMENT3,
      SEGMENT4,
      SEGMENT5,
      SEGMENT6,
      SEGMENT7,
      SEGMENT8,
      SEGMENT9,
      SEGMENT10,
      SEGMENT1_NAME,
      SEGMENT2_NAME,
      SEGMENT3_NAME,
      SEGMENT4_NAME,
      SEGMENT5_NAME,
      SEGMENT6_NAME,
      SEGMENT7_NAME,
      SEGMENT8_NAME,
      SEGMENT9_NAME,
      SEGMENT10_NAME,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      LAST_UPDATE_DATE,
      REQUEST_ID,
      PROGRAM_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_LOGIN_ID,
      RECORD_TYPE_CODE)
    VALUES (
      G_CLASSIFICATION_TYPE_ID,
      G_CLASSIFICATION_TYPE_CODE,
      G_CLASSIFICATION_TYPE_NAME,
      G_CLASSIFICATION_TYP_CATEG_COD,
      classification_id,
      p_classification_code,
      p_classification_name,
      lang_code,
      sysdate,
      null,
      'Y',
      null,
      null,
      null,
      p_classification_code,    --Concatenated classification code
      p_classification_name,    --Concatenated classification name
      1,
      p_country_code,
      p_classification_code,
      Null,
      Null,
      Null,
      Null,
      Null,
      Null,
      Null,
      Null,
      Null,
      p_classification_name,
      Null,
      Null,
      Null,
      Null,
      Null,
      Null,
      Null,
      Null,
      Null,
      120,
      SYSDATE,
      fnd_global.user_id,
      FND_GLOBAL.CONC_LOGIN_ID,
      sysdate,
      FND_GLOBAL.CONC_REQUEST_ID,
      fnd_global.CONC_PROGRAM_ID,
      235,
      FND_GLOBAL.CONC_LOGIN_ID,
      'SEEDED')
    select
            language_code lang_code, fc_codes.classification_id
    from
            fnd_languages l,
      zx_fc_codes_b fc_codes
    where
            l.installed_flag in ('I', 'B')
                  and fc_codes.classification_type_code = p_classification_type_code
      and fc_codes.parent_classification_id is null
      and fc_codes.classification_code = p_classification_code

    AND     NOT EXISTS  -- this condition makes sure we dont duplicate data
      (select NULL from ZX_FC_CODES_DENORM_B CODES where
          codes.classification_type_code = p_classification_type_code
      and codes.classification_code = p_classification_code
      and codes.ancestor_id is null
      and codes.LANGUAGE = L.LANGUAGE_CODE);

  -- Find and return the classification id
  SELECT
        classification_id into x_fc_id
  from
        ZX_FC_CODES_B Codes
  where
        codes.classification_type_code = p_classification_type_code
        and codes.parent_classification_id is null
        and codes.classification_code = p_classification_code;

  arp_util_tax.debug('FIRST_LEVEL_FC_CODE_INSERT(-)');

END FIRST_LEVEL_FC_CODE_INSERT;



/*THIS IS THE COMMON PROCEDURE USED TO INSERT VALUES BASED UPON THE LOOKUP TYPE */

PROCEDURE FC_CODE_FROM_FND_LOOKUP(
  p_classification_type_code   IN  ZX_FC_CODES_B.CLASSIFICATION_TYPE_CODE%TYPE,
   p_lookup_type      IN  FND_LOOKUP_VALUES.LOOKUP_TYPE%TYPE,
  p_country_code      IN  ZX_FC_CODES_B.COUNTRY_CODE%TYPE,
        p_parent_fc_id      IN  ZX_FC_CODES_B.CLASSIFICATION_ID%TYPE,
  p_ancestor_code      IN  ZX_FC_CODES_DENORM_B.ANCESTOR_CODE%TYPE,
  p_ancestor_name      IN  ZX_FC_CODES_DENORM_B.ANCESTOR_NAME%TYPE,
  p_classification_code_level  IN  ZX_FC_CODES_DENORM_B.CLASSIFICATION_CODE_LEVEL%TYPE)
  IS

BEGIN

  arp_util_tax.debug('FC_CODE_FROM_FND_LOOKUP(+)');

  arp_util_tax.debug('p_classification_type_code = ' || p_classification_type_code);
  arp_util_tax.debug('p_lookup_type = ' || p_lookup_type);

   OPEN G_C_GET_TYPES_INFO(p_classification_type_code);

  FETCH G_C_GET_TYPES_INFO  INTO
      G_CLASSIFICATION_TYPE_ID,
      G_CLASSIFICATION_TYPE_CODE,
      G_CLASSIFICATION_TYPE_NAME,
      G_CLASSIFICATION_TYP_CATEG_COD,
      G_DELIMITER;

  CLOSE G_C_GET_TYPES_INFO;

  INSERT
  INTO ZX_FC_CODES_B
      (classification_type_code,
      classification_id,
      classification_code,
      effective_from,
      effective_to,
      parent_classification_code,
      parent_classification_id,
      country_code,
      record_type_code,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      object_version_number)
  SELECT    p_classification_type_code,
      zx_fc_codes_b_s.nextval,
      lookup_code,
      nvl(start_date_active,to_date('01/01/1951','DD/MM/YYYY')),
      end_date_active,
      p_ancestor_code,----parent_classification_code
      p_parent_fc_id,-----parent_classification_id
      p_country_code,
      'MIGRATED',
      fnd_global.user_id,
      SYSDATE,
      fnd_global.user_id,
      SYSDATE,
      FND_GLOBAL.CONC_LOGIN_ID,
      1
  FROM     FND_LOOKUP_VALUES lookups
  WHERE
    lookups.lookup_type=p_lookup_type
        AND     LANGUAGE = userenv('LANG')
  AND  lookups.enabled_flag = 'Y'
  AND  NOT EXISTS  -- this condition makes sure we dont duplicate data
    (select NULL from  ZX_FC_CODES_B Codes where
          codes.classification_type_code = p_classification_type_code
      and ( codes.parent_classification_id = p_parent_fc_id or
            p_parent_fc_id is null )
      and codes.classification_code = lookups.lookup_code
    );

  INSERT ALL INTO
          ZX_FC_CODES_TL
      (CLASSIFICATION_ID,
      CLASSIFICATION_NAME,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      LANGUAGE,
      SOURCE_LANG)
  VALUES   (classification_id,
        CASE WHEN Meaning = UPPER(Meaning)
         THEN    Initcap(Meaning)
         ELSE
           Meaning
         END,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.user_id,
      SYSDATE,
      FND_GLOBAL.CONC_LOGIN_ID,
      language,
      SOURCE_LANG)
  INTO ZX_FC_CODES_DENORM_B(
     CLASSIFICATION_TYPE_ID,
     CLASSIFICATION_TYPE_CODE,
     CLASSIFICATION_TYPE_NAME,
     CLASSIFICATION_TYPE_CATEG_CODE,
     CLASSIFICATION_ID,
     CLASSIFICATION_CODE,
     CLASSIFICATION_NAME,
     LANGUAGE,
     EFFECTIVE_FROM,
     EFFECTIVE_TO,
     ENABLED_FLAG,
     ANCESTOR_ID,
     ANCESTOR_CODE,
     ANCESTOR_NAME,
     CONCAT_CLASSIF_CODE,
     CONCAT_CLASSIF_NAME,
     CLASSIFICATION_CODE_LEVEL,
     COUNTRY_CODE,
     SEGMENT1,
     SEGMENT2,
     SEGMENT3,
     SEGMENT4,
     SEGMENT5,
     SEGMENT6,
     SEGMENT7,
     SEGMENT8,
     SEGMENT9,
     SEGMENT10,
     SEGMENT1_NAME,
     SEGMENT2_NAME,
     SEGMENT3_NAME,
     SEGMENT4_NAME,
     SEGMENT5_NAME,
     SEGMENT6_NAME,
     SEGMENT7_NAME,
     SEGMENT8_NAME,
     SEGMENT9_NAME,
     SEGMENT10_NAME,
     CREATED_BY,
     CREATION_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN,
     LAST_UPDATE_DATE,
     REQUEST_ID,
     PROGRAM_ID,
     PROGRAM_APPLICATION_ID,
     PROGRAM_LOGIN_ID,
     RECORD_TYPE_CODE)
  VALUES (
    G_CLASSIFICATION_TYPE_ID,
    G_CLASSIFICATION_TYPE_CODE,
    G_CLASSIFICATION_TYPE_NAME,
    G_CLASSIFICATION_TYP_CATEG_COD,
    classification_id,
    lookup_code,
    Meaning,
    Language,
    start_date_active,
    end_date_active,
    enabled_flag,
    p_parent_fc_id,
    p_ancestor_code,
    p_ancestor_name,
    nvl2(p_ancestor_code,
      p_ancestor_code||G_DELIMITER||lookup_code,
      lookup_code),
    nvl2(p_ancestor_name,
      p_ancestor_name||G_DELIMITER||Meaning,
      Meaning),
    p_classification_code_level,
    p_country_code,
    nvl(p_ancestor_code, lookup_code),          -- Segment1
    nvl2(p_ancestor_code, lookup_code, null),   -- Segment2
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    nvl(p_ancestor_name, Meaning),        -- Segment1 Name
    nvl2(p_ancestor_name, Meaning, null), -- Segment2 Name
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    fnd_global.user_id,
    SYSDATE,
    fnd_global.user_id,
    FND_GLOBAL.CONC_LOGIN_ID,
    sysdate,
    FND_GLOBAL.CONC_REQUEST_ID,
    fnd_global.CONC_PROGRAM_ID,
    235,
    FND_GLOBAL.CONC_LOGIN_ID,
    'MIGRATED')
  SELECT  lookup_code,
    Meaning,
    Language,
    source_lang,
    nvl(start_date_active,to_date('01/01/1951','DD/MM/YYYY')) start_date_active,
    end_date_active,
    fl.enabled_flag,
    Codes.classification_id
  FROM
    zx_fc_codes_b Codes,
    fnd_lookup_values fl,
    fnd_languages l
  WHERE

    codes.classification_type_code = p_classification_type_code
  and   (codes.parent_classification_id = p_parent_fc_id or
           p_parent_fc_id is null)
  and   codes.classification_code = fl.lookup_code
  AND     Codes.RECORD_TYPE_CODE = 'MIGRATED'
  and  fl.lookup_type = p_lookup_type
  AND  fl.enabled_flag = 'Y'  -- need to check again
  AND  fl.language=l.language_code(+)
  AND     l.INSTALLED_FLAG in ('I', 'B')

  AND  NOT EXISTS  -- this condition makes sure we dont duplicate data
    (select NULL from ZX_FC_CODES_DENORM_B codes where
      codes.classification_type_code = G_CLASSIFICATION_TYPE_CODE
        and codes.classification_code = fl.lookup_code
        and (codes.ancestor_id = p_parent_fc_id or
             p_parent_fc_id is null)
        and codes.language = l.language_code);

  arp_util_tax.debug('FC_CODE_FROM_FND_LOOKUP(-)');

END FC_CODE_FROM_FND_LOOKUP;


/*THIS IS THE COMMON PROCEDURE USED TO PERFORM INSERTS BASED ON THE GLOBAL DESCRIPTIVE FLEXI FIELDS
  This procedure is called from zxcfctbc.ldt file also */

PROCEDURE FC_CODE_GDF_INSERT(
   p_classification_code     IN  ZX_FC_CODES_B.CLASSIFICATION_CODE%TYPE,
  p_classification_name    IN  ZX_FC_CODES_TL.CLASSIFICATION_NAME%TYPE,
  p_country_code      IN  ZX_FC_CODES_B.COUNTRY_CODE%TYPE,
  p_lookup_type      IN  FND_LOOKUP_VALUES.LOOKUP_TYPE%TYPE,
  p_tax_event_class_code    IN  ZX_EVENT_CLASSES_VL.TAX_EVENT_CLASS_CODE%TYPE,
  p_record_type_code              IN  ZX_FC_CODES_B.RECORD_TYPE_CODE%TYPE
  )

  IS

  BEGIN

  arp_util_tax.debug('FC_CODE_GDF_INSERT(+)');

  arp_util_tax.debug('p_classification_code = ' || p_classification_code);
  arp_util_tax.debug('p_lookup_type = ' || p_lookup_type);


  OPEN G_C_GET_TYPES_INFO('TRX_BUSINESS_CATEGORY');

  fetch G_C_GET_TYPES_INFO into

  G_CLASSIFICATION_TYPE_ID,
  G_CLASSIFICATION_TYPE_CODE,
  G_CLASSIFICATION_TYPE_NAME,
  G_CLASSIFICATION_TYP_CATEG_COD,
  G_DELIMITER;

  CLOSE G_C_GET_TYPES_INFO;

  --Insert the GDF prompt in second level
  GDF_PROMPT_INSERT(p_classification_code, p_classification_name, p_country_code, p_tax_event_class_code);

  /*
  Create a Code under the Transaction Business Category Type, 3rd Level
  */

  arp_util_tax.debug( 'Create Code under the Transaction Business Category Type-Level 3: ' || p_country_code);

  INSERT
  INTO ZX_FC_CODES_B (
    classification_type_code,
    classification_id,
    classification_code,
    effective_from,
    effective_to,
    parent_classification_code,
    parent_classification_id,
    Country_code,
    record_type_code,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login,
    object_version_number)
  SELECT
    'TRX_BUSINESS_CATEGORY',
    zx_fc_codes_b_s.nextval,
    lookup_code,
    nvl(start_date_active,to_date('01/01/1951','DD/MM/YYYY')) start_date_active,
    end_date_active,
    fc.classification_code ,---parent_classification_code
    fc.classification_id,   ---parent_classification_id
    p_country_code,
    p_record_type_code,
    decode(p_record_type_code, 'SEEDED', 120, fnd_global.user_id),
    SYSDATE,
    decode(p_record_type_code, 'SEEDED', 120, fnd_global.user_id),
    SYSDATE,
    decode(p_record_type_code, 'SEEDED', 0, fnd_global.conc_login_id),
    1
  FROM
    ZX_FC_CODES_DENORM_B fc,
    ZX_EVENT_CLASSES_VL event,
    FND_LOOKUP_VALUES FL
  WHERE
        fc.classification_type_code = 'TRX_BUSINESS_CATEGORY'
    and fc.classification_code=p_classification_code
    and fc.language = userenv('LANG')
    and fc.ancestor_code = event.tax_event_class_code
    and fc.classification_code_level = 2
    and fl.lookup_type = p_lookup_type
    and fl.enabled_flag = 'Y'
    and fl.language = userenv('LANG')
                and event.tax_event_class_code = p_tax_event_class_code
          and NOT EXISTS  -- this condition makes sure we dont duplicate data
       (select NULL from  ZX_FC_CODES_B Codes where
          codes.classification_type_code = 'TRX_BUSINESS_CATEGORY'
      and codes.parent_classification_id =
        nvl(fc.classification_id,codes.parent_classification_id)
      and codes.classification_code = fl.lookup_code
        );


  INSERT ALL
  INTO ZX_FC_CODES_TL
    (CLASSIFICATION_ID,
    CLASSIFICATION_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG)
  VALUES  (classification_id,
        CASE WHEN Meaning = UPPER(Meaning)
         THEN    Initcap(Meaning)
         ELSE
           Meaning
         END,
    decode(p_record_type_code, 'SEEDED', 120, fnd_global.user_id),
    SYSDATE,
    decode(p_record_type_code, 'SEEDED', 120, fnd_global.user_id),
    SYSDATE,
    decode(p_record_type_code, 'SEEDED', 0, fnd_global.conc_login_id),
    language,
    SOURCE_LANG)
  INTO ZX_FC_CODES_DENORM_B(
    CLASSIFICATION_TYPE_ID,
    CLASSIFICATION_TYPE_CODE,
    CLASSIFICATION_TYPE_NAME,
    CLASSIFICATION_TYPE_CATEG_CODE,
    CLASSIFICATION_ID,
    CLASSIFICATION_CODE,
    CLASSIFICATION_NAME,
    LANGUAGE,
    EFFECTIVE_FROM,
    EFFECTIVE_TO,
    ENABLED_FLAG,
    ANCESTOR_ID,
    ANCESTOR_CODE,
    ANCESTOR_NAME,
    CONCAT_CLASSIF_CODE,
    CONCAT_CLASSIF_NAME,
    CLASSIFICATION_CODE_LEVEL,
    COUNTRY_CODE,
    SEGMENT1,
    SEGMENT2,
    SEGMENT3,
    SEGMENT4,
    SEGMENT5,
    SEGMENT6,
    SEGMENT7,
    SEGMENT8,
    SEGMENT9,
    SEGMENT10,
    SEGMENT1_NAME,
    SEGMENT2_NAME,
    SEGMENT3_NAME,
    SEGMENT4_NAME,
    SEGMENT5_NAME,
    SEGMENT6_NAME,
    SEGMENT7_NAME,
    SEGMENT8_NAME,
    SEGMENT9_NAME,
    SEGMENT10_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    REQUEST_ID,
    PROGRAM_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_LOGIN_ID,
    RECORD_TYPE_CODE)
    VALUES (
    G_CLASSIFICATION_TYPE_ID,
    G_CLASSIFICATION_TYPE_CODE,
    G_CLASSIFICATION_TYPE_NAME,
    G_CLASSIFICATION_TYP_CATEG_COD,
    classification_id,
    lookup_code,
    meaning,
    Language,
    start_date_active,
    end_date_active,
    enabled_flag,
    parent_fc_id,
    parent_fc_code,
    parent_fc_name,
    tax_event_class_code ||G_DELIMITER || parent_fc_code || G_DELIMITER || lookup_code,
    Name || G_DELIMITER || parent_fc_name || G_DELIMITER || Meaning,
    3,
    p_country_code,
    tax_event_class_code,
    parent_fc_code,
    lookup_code,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Name,
    parent_fc_name,
    Meaning,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    decode(p_record_type_code, 'SEEDED', 120, fnd_global.user_id),
    SYSDATE,
    decode(p_record_type_code, 'SEEDED', 120, fnd_global.user_id),
    decode(p_record_type_code, 'SEEDED', 0, fnd_global.conc_login_id),
    sysdate,
    FND_GLOBAL.CONC_REQUEST_ID,
    fnd_global.CONC_PROGRAM_ID,
    235,
    FND_GLOBAL.CONC_LOGIN_ID,
    p_record_type_code)
  SELECT
    lookup_code,
    meaning,
    nvl(start_date_active,to_date('01/01/1951','DD/MM/YYYY')) start_date_active,
    end_date_active,
    tax_event_class_code,
    event.tax_event_class_name name,
    fc.classification_id as parent_fc_id,
    fc.classification_code as parent_fc_code,
    fc.classification_name as parent_fc_name,
    fl.language,
    fl.source_lang,
    fl.enabled_flag,
    Codes.classification_id

  FROM
    ZX_FC_CODES_DENORM_B fc,
    ZX_FC_CODES_b Codes,
    ZX_EVENT_CLASSES_VL event,
    FND_LOOKUP_VALUES FL,
                FND_LANGUAGES L
  WHERE fc.classification_type_code = 'TRX_BUSINESS_CATEGORY'
    and fc.classification_code=p_classification_code
    and fc.language = userenv('LANG')
    and fc.ancestor_code = event.tax_event_class_code
    and fc.classification_code_level = 2
    and Codes.classification_type_code = 'TRX_BUSINESS_CATEGORY'
    and Codes.parent_classification_id = fc.classification_id
    and Codes.classification_code = FL.lookup_code
      and Codes.record_type_code = p_record_type_code
        and event.tax_event_class_code = p_tax_event_class_code
    and lookup_type = p_lookup_type
    and FL.enabled_flag = 'Y'
    and FL.language=L.language_code(+)
    and L.INSTALLED_FLAG in ('I', 'B')
    and NOT EXISTS  -- this condition makes sure we dont duplicate data
           (  select NULL from ZX_FC_CODES_DENORM_B codes
              where codes.classification_type_code = G_CLASSIFICATION_TYPE_CODE
            and codes.classification_code = fl.lookup_code
            and codes.ancestor_id = nvl(fc.classification_id,codes.ancestor_id)
            and codes.language = l.language_code);

  arp_util_tax.debug('FC_CODE_GDF_INSERT(-)');

END FC_CODE_GDF_INSERT;


/*THIS IS THE COMMON PROCEDURE USED TO INSERT THE GLOBAL DESCRIPTIVE FLEXI FIELD PROMPT VALUE*/

PROCEDURE GDF_PROMPT_INSERT(
   p_classification_code     IN  ZX_FC_CODES_B.CLASSIFICATION_CODE%TYPE,
  p_classification_name    IN  ZX_FC_CODES_TL.CLASSIFICATION_NAME%TYPE,
  p_country_code      IN  ZX_FC_CODES_B.COUNTRY_CODE%TYPE,
  p_tax_event_class_code    IN  ZX_EVENT_CLASSES_VL.TAX_EVENT_CLASS_CODE%TYPE
  )

  IS

  BEGIN

  arp_util_tax.debug('GDF_PROMPT_INSERT(+)');

  arp_util_tax.debug('p_classification_code = ' || p_classification_code);

  arp_util_tax.debug( 'Create the Second Level of Classification Codes for :'||p_country_code);

  OPEN G_C_GET_TYPES_INFO('TRX_BUSINESS_CATEGORY');

  fetch G_C_GET_TYPES_INFO into

  G_CLASSIFICATION_TYPE_ID,
  G_CLASSIFICATION_TYPE_CODE,
  G_CLASSIFICATION_TYPE_NAME,
  G_CLASSIFICATION_TYP_CATEG_COD,
  G_DELIMITER;

  CLOSE G_C_GET_TYPES_INFO;

  INSERT
  INTO ZX_FC_CODES_B
    (classification_type_code,
     classification_id,
     classification_code,
     effective_from,
     effective_to,
     parent_classification_code,
     parent_classification_id,
     country_code,
     record_type_code,
     created_by,
     creation_date,
     last_updated_by,
     last_update_date,
     last_update_login,
     object_version_number)
  SELECT
    'TRX_BUSINESS_CATEGORY',  --classification_type_code
    zx_fc_codes_b_s.nextval,  --classification_id
    p_classification_code,    --classification_code
    sysdate,      --effective_from
    null,        --effective_to
    event.tax_event_class_code,  --parent_classification_code
    fc.classification_id,    --parent_classification_id
    p_country_code,      --country_code
    'SEEDED',      --record_type_code
    120,
    sysdate,
    fnd_global.user_id,
    sysdate,
    fnd_global.conc_login_id,
    1
  FROM
    ZX_FC_CODES_B fc,
    ZX_EVENT_CLASSES_B event
  WHERE
        fc.classification_type_code = 'TRX_BUSINESS_CATEGORY'
    and fc.parent_classification_id is null
    and fc.classification_code=event.tax_event_class_code
                and event.tax_event_class_code = p_tax_event_class_code
    and not exists  -- this condition makes sure we dont duplicate data
       (select NULL from  ZX_FC_CODES_B Codes where
          codes.classification_type_code = 'TRX_BUSINESS_CATEGORY'
      and codes.parent_classification_id =
        nvl(fc.classification_id,codes.parent_classification_id)
      and codes.classification_code = p_classification_code
        );

  INSERT ALL
  INTO ZX_FC_CODES_TL
    (CLASSIFICATION_ID,
    CLASSIFICATION_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG)
  VALUES(
    classification_id,
        CASE WHEN p_classification_name = UPPER(p_classification_name)
         THEN    Initcap(p_classification_name)
         ELSE
           p_classification_name
         END,
    fnd_global.user_id,
    sysdate,
    fnd_global.user_id,
    sysdate,
    fnd_global.conc_login_id,
    lang_code,
    userenv('LANG'))

  INTO ZX_FC_CODES_DENORM_B(
    CLASSIFICATION_TYPE_ID,
    CLASSIFICATION_TYPE_CODE,
    CLASSIFICATION_TYPE_NAME,
    CLASSIFICATION_TYPE_CATEG_CODE,
    CLASSIFICATION_ID,
    CLASSIFICATION_CODE,
    CLASSIFICATION_NAME,
    LANGUAGE,
    EFFECTIVE_FROM,
    EFFECTIVE_TO,
    ENABLED_FLAG,
    ANCESTOR_ID,
    ANCESTOR_CODE,
    ANCESTOR_NAME,
    CONCAT_CLASSIF_CODE,
    CONCAT_CLASSIF_NAME,
    CLASSIFICATION_CODE_LEVEL,
    COUNTRY_CODE,
    SEGMENT1,
    SEGMENT2,
    SEGMENT3,
    SEGMENT4,
    SEGMENT5,
    SEGMENT6,
    SEGMENT7,
    SEGMENT8,
    SEGMENT9,
    SEGMENT10,
    SEGMENT1_NAME,
    SEGMENT2_NAME,
    SEGMENT3_NAME,
    SEGMENT4_NAME,
    SEGMENT5_NAME,
    SEGMENT6_NAME,
    SEGMENT7_NAME,
    SEGMENT8_NAME,
    SEGMENT9_NAME,
    SEGMENT10_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    REQUEST_ID,
    PROGRAM_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_LOGIN_ID,
    RECORD_TYPE_CODE)
    VALUES (
    G_CLASSIFICATION_TYPE_ID,
    G_CLASSIFICATION_TYPE_CODE,
    G_CLASSIFICATION_TYPE_NAME,
    G_CLASSIFICATION_TYP_CATEG_COD,
    classification_id,                    --CLASSIFICATION_ID
    p_classification_code,                 --CLASSIFICATION_CODE
    p_classification_name,              --CLASSIFICATION_NAME
    lang_code,            --LANGUAGE
    sysdate,            --EFFECTIVE_FROM
    null,              --EFFECTIVE_TO
    'Y',              --ENABLED_FLAG
    parent_fc_id,            --ANCESTOR_ID
    tax_event_class_code,          --ANCESTOR_CODE
    Name,              --ANCESTOR_NAME
    tax_event_class_code ||G_DELIMITER ||
       p_classification_code,          --CONCAT_CLASSIF_CODE
    Name || G_DELIMITER ||
    p_classification_name ,         --CONCAT_CLASSIF_NAME
    2,              --CLASSIFICATION_CODE_LEVEL
    p_country_code,              --COUNTRY_CODE
    tax_event_class_code,          --SEGMENT1
    p_classification_code,            --SEGMENT2
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Name,               --SEGMENT1_NAME
    p_classification_name ,               --SEGMENT2_NAME
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    120,
    sysdate,
    fnd_global.user_id,
    fnd_global.conc_login_id,
    sysdate,
    fnd_global.conc_request_id,
    fnd_global.conc_program_id,
    235,
    fnd_global.conc_login_id,
    'SEEDED')
  SELECT
    event.tax_event_class_code,
    event.tax_event_class_name name,
    fc.classification_id as parent_fc_id,
    zx.classification_id as classification_id,
    L.language_code lang_code
  FROM
    ZX_FC_CODES_B fc,
    ZX_FC_CODES_B zx,
    ZX_EVENT_CLASSES_TL event,
    FND_LANGUAGES L
  WHERE
         fc.classification_type_code = 'TRX_BUSINESS_CATEGORY'
    and  fc.parent_classification_id is null
    and  fc.classification_code=event.tax_event_class_code
                and  event.tax_event_class_code = p_tax_event_class_code
    and  zx.classification_type_code = 'TRX_BUSINESS_CATEGORY'
    and  zx.parent_classification_id = fc.classification_id
    and  zx.classification_code = p_classification_code
    and  (zx.RECORD_TYPE_CODE = 'MIGRATED' OR zx.RECORD_TYPE_CODE = 'SEEDED')
    and  event.language = L.language_code(+)
    and  L.INSTALLED_FLAG in ('I', 'B')
          and  NOT EXISTS  -- this condition makes sure we dont duplicate data
          ( select NULL from ZX_FC_CODES_DENORM_B codes
            where
                codes.classification_type_code = G_CLASSIFICATION_TYPE_CODE
      and codes.classification_code = p_classification_code
      and codes.ancestor_id = nvl(fc.classification_id,codes.ancestor_id)
      and codes.language = l.language_code
          );

  arp_util_tax.debug('GDF_PROMPT_INSERT(-)');

END GDF_PROMPT_INSERT;


/* COMMON PROCEDURE USED TO ASSOCIATE THE ITEMS */
PROCEDURE ASSOCIATE_ITEMS(p_global_attribute_category
      in  varchar2) IS
BEGIN

  arp_util_tax.debug('ASSOCIATE_ITEMS(+)');

  arp_util_tax.debug('p_global_attribute_category = ' || p_global_attribute_category);

  /* Regime Association to Fiscal Type */
  INSERT ALL INTO
  ZX_FC_TYPES_REG_ASSOC
  (       Tax_regime_code,
    Classification_type_code,
    effective_from,
    effective_to,
    Record_type_code,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login,
    classif_regime_id,
    object_version_number)
  VALUES
  (       TAX_REGIME_CODE,
    'STATISTICAL CODE',
    SYSDATE,
    NULL,
    'MIGRATED',
    fnd_global.user_id,
    SYSDATE,
    fnd_global.user_id,
    SYSDATE,
    FND_GLOBAL.CONC_LOGIN_ID,
    zx_fc_types_reg_assoc_s.nextval,
    1)
  Select  unique
    tax_regime_code
  FROM ZX_RATES_B rates,
       AP_TAX_CODES_ALL codes
  WHERE
             codes.tax_id                    = nvl(rates.source_id, rates.tax_rate_id) and
             codes.global_attribute_category = p_global_attribute_category and
             rates.record_type_code          = 'MIGRATED' and
             not exists
             (select null from ZX_FC_TYPES_REG_ASSOC
              where classification_type_code = 'STATISTICAL CODE' and
                    tax_regime_code          = rates.tax_regime_code);

  arp_util_tax.debug('ASSOCIATE_ITEMS(-)');

End Associate_items;


/* COMMON PROCEDURE USED TO INSERT THE FC TYPES */
PROCEDURE FC_TYPE_INSERT(
   p_classification_type_code   IN  ZX_FC_TYPES_B.CLASSIFICATION_TYPE_CODE%TYPE,
   p_classification_type_name   IN  ZX_FC_TYPES_TL.CLASSIFICATION_TYPE_NAME%TYPE,
   p_owner_id_num      IN  ZX_FC_TYPES_B.OWNER_ID_NUM%TYPE
) IS
BEGIN

  arp_util_tax.debug('Creating the fiscal classification types ');

  arp_util_tax.debug('p_classification_type_code = ' || p_classification_type_code);

  INSERT
  INTO ZX_FC_TYPES_B(
    classification_type_id,
    classification_type_code,
    classification_type_categ_code,
    effective_from,
    effective_to,
    classification_type_level_code,
    owner_table_code,
    owner_id_num,
    start_position,
    num_characters,
    record_type_code,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login,
    object_version_number)
  (SELECT
    zx_fc_types_b_s.nextval,
    p_classification_type_code,
    'PRODUCT_FISCAL_CLASS',
    sysdate,
    null,
    1,
    'MTL_CATEGORY_SETS_B',
    p_owner_id_num,
    1,
    400,
    'MIGRATED',
    fnd_global.user_id,
    SYSDATE,
    fnd_global.user_id,
    SYSDATE,
    FND_GLOBAL.CONC_LOGIN_ID,
    1
  FROM dual
  WHERE NOT EXISTS
    (SELECT null from ZX_FC_TYPES_B
     WHERE  classification_type_code = p_classification_type_code
            and classification_type_categ_code = 'PRODUCT_FISCAL_CLASS')
  );


  INSERT
  INTO ZX_FC_TYPES_TL(
    CLASSIFICATION_TYPE_ID,
    CLASSIFICATION_TYPE_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG)
  (select
    classification_type_id,
        CASE WHEN p_classification_type_name = UPPER(p_classification_type_name)
         THEN    Initcap(p_classification_type_name)
         ELSE
           p_classification_type_name
         END,
    fnd_global.user_id,
    SYSDATE,
    fnd_global.user_id,
    SYSDATE,
    FND_GLOBAL.CONC_LOGIN_ID,
    language_code,
    userenv('LANG')

  FROM FND_LANGUAGES L,
       ZX_FC_TYPES_B Types
  where
           Types.classification_type_code = p_classification_type_code
       and Types.classification_type_categ_code = 'PRODUCT_FISCAL_CLASS'
       --and Types.record_type_code = 'MIGRATED'
       and l.installed_flag in ('I', 'B')
       and NOT EXISTS  -- this condition makes sure we dont duplicate data
         (select NULL from ZX_FC_TYPES_TL T
          where T.CLASSIFICATION_TYPE_ID = Types.CLASSIFICATION_TYPE_ID
        and T.LANGUAGE = L.LANGUAGE_CODE)
  );

  -- Insert records into Determining Factors table

  INSERT INTO ZX_DETERMINING_FACTORS_B (
                      DETERMINING_FACTOR_ID,
          DETERMINING_FACTOR_CODE,
          DETERMINING_FACTOR_CLASS_CODE,
          VALUE_SET,
          TAX_PARAMETER_CODE,
          DATA_TYPE_CODE,
          TAX_FUNCTION_CODE,
          RECORD_TYPE_CODE,
          TAX_REGIME_DET_FLAG,
          TAX_SUMMARIZATION_FLAG,
          TAX_RULES_FLAG,
          TAXABLE_BASIS_FLAG,
          TAX_CALCULATION_FLAG,
          INTERNAL_FLAG,
          RECORD_ONLY_FLAG,
          REQUEST_ID,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          OBJECT_VERSION_NUMBER)

        (SELECT  Zx_Determining_Factors_B_S.nextval,
          p_classification_type_code,
          'PRODUCT_FISCAL_CLASS',
          NULL,
          NULL,
          'ALPHANUMERIC',
          NULL,
          'MIGRATED',
          'N',        --TAX_REGIME_DET_FLAG
          'Y',        --TAX_SUMMARIZATION_FLAG
          'Y',        --TAX_RULES_FLAG
          'N',        --TAXABLE_BASIS_FLAG
          'N',        --TAX_CALCULATION_FLAG
          'Y',        --INTERNAL_FLAG
          'N',        --RECORD_ONLY_FLAG
          NULL,
          SYSDATE,
          FND_GLOBAL.USER_ID,
          SYSDATE,
          FND_GLOBAL.USER_ID,
          FND_GLOBAL.CONC_LOGIN_ID,
          1
    FROM dual
    WHERE NOT EXISTS
      (SELECT null from ZX_DETERMINING_FACTORS_B
       WHERE DETERMINING_FACTOR_CODE = p_classification_type_code
             AND DETERMINING_FACTOR_CLASS_CODE = 'PRODUCT_FISCAL_CLASS')
    );

  INSERT INTO ZX_DET_FACTORS_TL (
                       DETERMINING_FACTOR_NAME,
           DETERMINING_FACTOR_DESC,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN,
           DETERMINING_FACTOR_ID,
           LANGUAGE,
           SOURCE_LANG)
    (SELECT
    CASE WHEN p_classification_type_name = UPPER(p_classification_type_name)
         THEN    Initcap(p_classification_type_name)
         ELSE
                 p_classification_type_name
         END,
           NULL,
           SYSDATE,
           FND_GLOBAL.USER_ID,
           SYSDATE,
           FND_GLOBAL.USER_ID,
           FND_GLOBAL.CONC_LOGIN_ID,
           detFactors.DETERMINING_FACTOR_ID,
           L.LANGUAGE_CODE,
           userenv('LANG')

      FROM FND_LANGUAGES L,
           ZX_DETERMINING_FACTORS_B detFactors
      WHERE
       detFactors.DETERMINING_FACTOR_CODE = p_classification_type_code
         and detFactors.DETERMINING_FACTOR_CLASS_CODE = 'PRODUCT_FISCAL_CLASS'
         --and detFactors.RECORD_TYPE_CODE = 'MIGRATED'
         and l.installed_flag in ('I', 'B')
         and NOT EXISTS  -- this condition makes sure we dont duplicate data
      (select NULL from ZX_DET_FACTORS_TL T
      where T.DETERMINING_FACTOR_ID = detFactors.DETERMINING_FACTOR_ID
      and T.LANGUAGE = L.LANGUAGE_CODE)
    );


END FC_TYPE_INSERT;

PROCEDURE FC_PARTY_TYPE_INSERT(
   p_classification_type_code   IN  ZX_FC_TYPES_B.CLASSIFICATION_TYPE_CODE%TYPE,
   p_classification_type_name   IN  ZX_FC_TYPES_TL.CLASSIFICATION_TYPE_NAME%TYPE,
   p_tca_class             IN  VARCHAR2) IS

BEGIN
    -- Get the Party Classification ID

  arp_util_tax.debug('Creating the party fiscal classification types ');

  arp_util_tax.debug('p_classification_type_code = ' || p_classification_type_code);

  INSERT
  INTO ZX_FC_TYPES_B(
    classification_type_id,
    classification_type_code,
    classification_type_categ_code,
    effective_from,
    effective_to,
    classification_type_level_code,
    owner_table_code,
    owner_id_char,
    start_position,
    num_characters,
    record_type_code,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login,
    object_version_number)
  (SELECT
    zx_fc_types_b_s.nextval,
    p_classification_type_code,
    'PARTY_FISCAL_CLASS',
    sysdate,
    null,
    1,
    'HZ_CLASS_CATEGORY',
    p_tca_class,
    NULL,
    NULL,
    'MIGRATED',
    fnd_global.user_id,
    SYSDATE,
    fnd_global.user_id,
    SYSDATE,
    FND_GLOBAL.CONC_LOGIN_ID,
    1
  FROM dual
  WHERE NOT EXISTS
    (SELECT null from ZX_FC_TYPES_B
     WHERE  classification_type_code = p_classification_type_code
            and classification_type_categ_code = 'PARTY_FISCAL_CLASS')
  );


  INSERT
  INTO ZX_FC_TYPES_TL(
    CLASSIFICATION_TYPE_ID,
    CLASSIFICATION_TYPE_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG)
  (select
    classification_type_id,
        CASE WHEN p_classification_type_name = UPPER(p_classification_type_name)
         THEN    Initcap(p_classification_type_name)
         ELSE
           p_classification_type_name
         END,
    fnd_global.user_id,
    SYSDATE,
    fnd_global.user_id,
    SYSDATE,
    FND_GLOBAL.CONC_LOGIN_ID,
    language_code,
    userenv('LANG')

  FROM FND_LANGUAGES L,
       ZX_FC_TYPES_B Types
  where
           Types.classification_type_code = p_classification_type_code
       and Types.classification_type_categ_code = 'PARTY_FISCAL_CLASS'
       --and Types.record_type_code = 'MIGRATED'
       and l.installed_flag in ('I', 'B')
       and NOT EXISTS  -- this condition makes sure we dont duplicate data
         (select NULL from ZX_FC_TYPES_TL T
          where T.CLASSIFICATION_TYPE_ID = Types.CLASSIFICATION_TYPE_ID
        and T.LANGUAGE = L.LANGUAGE_CODE)
  );

  -- Insert records into Determining Factors table

  INSERT INTO ZX_DETERMINING_FACTORS_B (
                      DETERMINING_FACTOR_ID,
          DETERMINING_FACTOR_CODE,
          DETERMINING_FACTOR_CLASS_CODE,
          VALUE_SET,
          TAX_PARAMETER_CODE,
          DATA_TYPE_CODE,
          TAX_FUNCTION_CODE,
          RECORD_TYPE_CODE,
          TAX_REGIME_DET_FLAG,
          TAX_SUMMARIZATION_FLAG,
          TAX_RULES_FLAG,
          TAXABLE_BASIS_FLAG,
          TAX_CALCULATION_FLAG,
          INTERNAL_FLAG,
          RECORD_ONLY_FLAG,
          REQUEST_ID,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          OBJECT_VERSION_NUMBER)

        (SELECT  Zx_Determining_Factors_B_S.nextval,
          p_classification_type_code,
          'PARTY_FISCAL_CLASS',
          NULL,
          NULL,
          'ALPHANUMERIC',
          NULL,
          'MIGRATED',
          'N',        --TAX_REGIME_DET_FLAG
          'Y',        --TAX_SUMMARIZATION_FLAG
          'Y',        --TAX_RULES_FLAG
          'N',        --TAXABLE_BASIS_FLAG
          'N',        --TAX_CALCULATION_FLAG
          'Y',        --INTERNAL_FLAG
          'N',        --RECORD_ONLY_FLAG
          NULL,
          SYSDATE,
          FND_GLOBAL.USER_ID,
          SYSDATE,
          FND_GLOBAL.USER_ID,
          FND_GLOBAL.CONC_LOGIN_ID,
          1
    FROM dual
    WHERE NOT EXISTS
      (SELECT null from ZX_DETERMINING_FACTORS_B
       WHERE DETERMINING_FACTOR_CODE = p_classification_type_code
             AND DETERMINING_FACTOR_CLASS_CODE = 'PARTY_FISCAL_CLASS')
    );

  INSERT INTO ZX_DET_FACTORS_TL (
                       DETERMINING_FACTOR_NAME,
           DETERMINING_FACTOR_DESC,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN,
           DETERMINING_FACTOR_ID,
           LANGUAGE,
           SOURCE_LANG)
    (SELECT
          CASE WHEN p_classification_type_name = UPPER(p_classification_type_name)
           THEN    Initcap(p_classification_type_name)
           ELSE
             p_classification_type_name
           END,
           NULL,
           SYSDATE,
           FND_GLOBAL.USER_ID,
           SYSDATE,
           FND_GLOBAL.USER_ID,
           FND_GLOBAL.CONC_LOGIN_ID,
           detFactors.DETERMINING_FACTOR_ID,
           L.LANGUAGE_CODE,
           userenv('LANG')
      FROM FND_LANGUAGES L,
           ZX_DETERMINING_FACTORS_B detFactors
      WHERE detFactors.DETERMINING_FACTOR_CODE = p_classification_type_code
         and detFactors.DETERMINING_FACTOR_CLASS_CODE = 'PARTY_FISCAL_CLASS'
         --and detFactors.RECORD_TYPE_CODE = 'MIGRATED'
         and l.installed_flag in ('I', 'B')
         and NOT EXISTS  -- this condition makes sure we dont duplicate data
      (select NULL from ZX_DET_FACTORS_TL T
      where T.DETERMINING_FACTOR_ID = detFactors.DETERMINING_FACTOR_ID
      and T.LANGUAGE = L.LANGUAGE_CODE)
    );


END FC_PARTY_TYPE_INSERT;

/* PROCEDURE USED TO INSERT THE FC TYPES/CODES FOR AP ENTITIES */

 PROCEDURE ZX_MIGRATE_AP IS

  l_fc_id        zx_fc_codes_b.classification_id%type;

  l_structure_id    mtl_category_sets_b.structure_id%TYPE;
    l_category_status   VARCHAR2(200);
  l_category_set         mtl_category_sets_b.Category_set_ID%TYPE;

BEGIN

    arp_util_tax.debug('ZX_MIGRATE_AP(+)');

    --Bug # 3587896
    IF Is_Country_Installed(7004, 'jlarloc') THEN

  arp_util_tax.debug('Mapping the INTENDED_USE FC Type to category set value.. ');

        Create_Category_Set ('INTENDED_USE',
                             'Intended Use',
                             'INTENDED_USE',
                             'Intended Use');

        CREATE_MTL_CATEGORIES('JLZZ_AP_DESTINATION_CODE', 'INTENDED_USE',
                         l_category_status, l_category_set, l_structure_id);

  BEGIN

     If Zx_Migrate_Util.IS_INSTALLED('INV') = 'Y' THEN

    SELECT   category_set_id
    Into l_category_set
    FROM   mtl_category_sets_vl
    WHERE   category_set_name ='INTENDED_USE';

       UPDATE ZX_FC_TYPES_B
    SET owner_table_code   = 'MTL_CATEGORY_SETS_B',
    owner_id_num    = l_category_set,
    start_position    = 1,
    num_characters    = 400,
    last_update_date        = sysdate,
    last_updated_by         = fnd_global.user_id,
    object_version_number   = object_version_number + 1
          WHERE
    classification_type_code = 'INTENDED_USE' and
    classification_type_categ_code = 'INTENDED_USE_CLASSIFICATION';

     END IF;

        EXCEPTION
                WHEN OTHERS THEN
      arp_util_tax.debug('Error while getting category set id for INTENDED_USE ');
        END;

    END IF;-- Argentina Installed

  -- If Poland is installed then
    IF Is_Country_Installed(7002, 'jeplloc') THEN

  /*   Call Inventory Item Categories BULK API   */
  arp_util_tax.debug( 'Calling the inventory item category BULK API ');
  Create_Category_Sets;

  CREATE_MTL_CATEGORIES('JGZZ_STATISTICAL_CODE', 'STATISTICAL_CODE',l_category_status, l_category_set, l_structure_id);

  /* Create Association to items   Moved to zxitemcatmig.sql  */

  /* Regime Association to Fiscal Type */

  INSERT ALL INTO ZX_FC_TYPES_REG_ASSOC
    (Tax_regime_code,
    Classification_type_code,
    effective_from,
    effective_to,
    Record_type_code,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login,
    classif_regime_id,
    object_version_number)
  VALUES
    (TAX_REGIME_CODE,
    'STATISTICAL_CODE',
    SYSDATE,
    NULL,
    'MIGRATED',
    fnd_global.user_id,
    SYSDATE,
    fnd_global.user_id,
    SYSDATE,
    FND_GLOBAL.CONC_LOGIN_ID,
    zx_fc_types_reg_assoc_s.NEXTVAL,
    1)
  SELECT
    unique tax_regime_code
  FROM ZX_RATES_B rates,
       AP_TAX_CODES_ALL codes
  WHERE
       codes.tax_id                    = nvl(rates.source_id, rates.tax_rate_id) and
       codes.global_attribute_category = 'JE.PL.APXTADTC.TAX_ORIGIN' and
       rates.record_type_code          = 'MIGRATED' and
       not exists
       (select null from ZX_FC_TYPES_REG_ASSOC
        where classification_type_code = 'STATISTICAL_CODE' and
        tax_regime_code          = rates.tax_regime_code);

   END IF; -- End of Poland checking


   -- If Spain is installed then
   IF Is_Country_Installed(7002, 'jeesloc') THEN

  /* Create the Second Level of Classification Codes */
  arp_util_tax.debug( 'Create the Second Level of Classification Codes : SPAIN ');
  FC_CODE_GDF_INSERT('INVOICE TYPE','Invoice Type','ES','JEES_INVOICE_CATEGORY', 'PURCHASE_TRANSACTION','MIGRATED');
        -- Bug # 5219856
  FC_CODE_GDF_INSERT('INVOICE TYPE','Invoice Type','ES','JEES_INVOICE_CATEGORY', 'SALES_TRANSACTION','MIGRATED');

   END IF;


   -- If France is installed then
   IF Is_Country_Installed(7002, 'jefrloc') THEN

  arp_util_tax.debug( 'Create the First Level of Classification Codes : FRANCE ');

  OPEN G_C_GET_TYPES_INFO('DOCUMENT_SUBTYPE');

  FETCH G_C_GET_TYPES_INFO  INTO
      G_CLASSIFICATION_TYPE_ID,
      G_CLASSIFICATION_TYPE_CODE,
      G_CLASSIFICATION_TYPE_NAME,
      G_CLASSIFICATION_TYP_CATEG_COD,
      G_DELIMITER;

  CLOSE  G_C_GET_TYPES_INFO;

  FIRST_LEVEL_FC_CODE_INSERT('DOCUMENT_SUBTYPE','DEDUCTION TAX RULE','Deduction Tax Rule','FR',l_fc_id);

  /*
  Create Codes (level 2) under the Document Subtype for France Fiscal Type.
   */

  arp_util_tax.debug( 'Create the Document Subtype for Fiscal Type : FRANCE ');

  INSERT
  INTO ZX_FC_CODES_B (
    classification_type_code,
    classification_id,
    classification_code,
    effective_from,
    effective_to,
    parent_classification_code,
    parent_classification_id,
    country_code,
    record_type_code,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login,
    object_version_number)
  SELECT
    'DOCUMENT_SUBTYPE',
    zx_fc_codes_b_s.nextval,
    flex_value,
    nvl(start_date_active,to_date('01/01/1951','DD/MM/YYYY')),
    end_date_active,
    'DEDUCTION TAX RULE',--parent_classification_code
    l_fc_id,--parent_classification_id
    'FR',
    'MIGRATED',
    fnd_global.user_id,
    SYSDATE,
    fnd_global.user_id,
    SYSDATE,
    FND_GLOBAL.CONC_LOGIN_ID,
    1
  FROM
    FND_FLEX_VALUES V,
    fnd_flex_value_sets vs
  WHERE  v.FLEX_VALUE_SET_ID = vs.FLEX_VALUE_SET_id
    AND vs.FLEX_VALUE_SET_NAME ='JE_FR_TAX_RULE'
    AND v.enabled_flag = 'Y'
    AND NOT EXISTS
    (select NULL from ZX_FC_CODES_B Codes where
          codes.classification_type_code = 'DOCUMENT_SUBTYPE'
      and codes.parent_classification_id =
        nvl(l_fc_id,codes.parent_classification_id)
      and codes.classification_code = v.flex_value
    );

  INSERT ALL
  INTO ZX_FC_CODES_TL(
    CLASSIFICATION_ID,
    CLASSIFICATION_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG)
  VALUES
    (classification_id,
        CASE WHEN flex_value = UPPER(flex_value)
         THEN    Initcap(flex_value)
         ELSE
           flex_value
         END,
    fnd_global.user_id,
    SYSDATE,
    fnd_global.user_id,
    SYSDATE,
    FND_GLOBAL.CONC_LOGIN_ID,
    lang_code,
    userenv('LANG'))
  INTO  ZX_FC_CODES_DENORM_B
    (CLASSIFICATION_TYPE_ID,
    CLASSIFICATION_TYPE_CODE,
    CLASSIFICATION_TYPE_NAME,
    CLASSIFICATION_TYPE_CATEG_CODE,
    CLASSIFICATION_ID,
    CLASSIFICATION_CODE,
    CLASSIFICATION_NAME,
    LANGUAGE,
    EFFECTIVE_FROM,
    EFFECTIVE_TO,
    ENABLED_FLAG,
    ANCESTOR_ID,
    ANCESTOR_CODE,
    ANCESTOR_NAME,
    CONCAT_CLASSIF_CODE,
    CONCAT_CLASSIF_NAME,
    CLASSIFICATION_CODE_LEVEL,
    COUNTRY_CODE,
    SEGMENT1,
    SEGMENT2,
    SEGMENT3,
    SEGMENT4,
    SEGMENT5,
    SEGMENT6,
    SEGMENT7,
    SEGMENT8,
    SEGMENT9,
    SEGMENT10,
    SEGMENT1_NAME,
    SEGMENT2_NAME,
    SEGMENT3_NAME,
    SEGMENT4_NAME,
    SEGMENT5_NAME,
    SEGMENT6_NAME,
    SEGMENT7_NAME,
    SEGMENT8_NAME,
    SEGMENT9_NAME,
    SEGMENT10_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    REQUEST_ID,
    PROGRAM_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_LOGIN_ID,
    RECORD_TYPE_CODE)
    VALUES (
    G_CLASSIFICATION_TYPE_ID,
    G_CLASSIFICATION_TYPE_CODE,
    G_CLASSIFICATION_TYPE_NAME,
    G_CLASSIFICATION_TYP_CATEG_COD,
    classification_id,
    flex_value,
    flex_value,
    lang_code,
    start_date_active,
    end_date_active,
    enabled_flag,
    l_fc_id,
    'DEDUCTION TAX RULE',
    'Deduction Tax Rule',
    'DEDUCTION TAX RULE' || G_DELIMITER || flex_value,
    'Deduction Tax Rule' || G_DELIMITER || flex_value,
    2,
    'FR',
    'DEDUCTION TAX RULE',
    flex_value,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    'Deduction Tax Rule',
    flex_value,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    fnd_global.user_id,
    SYSDATE,
    fnd_global.user_id,
    FND_GLOBAL.CONC_LOGIN_ID,
    sysdate,
    FND_GLOBAL.CONC_REQUEST_ID,
    fnd_global.CONC_PROGRAM_ID,
    235,
    FND_GLOBAL.CONC_LOGIN_ID,
    'MIGRATED')
  SELECT
    flex_value,
    nvl(start_date_active,to_date('01/01/1951','DD/MM/YYYY')) start_date_active,
    end_date_active,
    Codes.classification_id,
    L.language_code lang_code,
    v.enabled_flag
  FROM
    ZX_FC_CODES_B Codes,
    FND_FLEX_VALUES V,
    fnd_flex_value_sets vs,
    FND_LANGUAGES L

  WHERE
        codes.classification_type_code = G_CLASSIFICATION_TYPE_CODE
          AND codes.parent_classification_id = l_fc_id
    AND codes.classification_code = v.flex_value
    AND Codes.RECORD_TYPE_CODE IN('MIGRATED', 'SEEDED')
    and v.FLEX_VALUE_SET_ID = vs.FLEX_VALUE_SET_id
    and vs.FLEX_VALUE_SET_NAME ='JE_FR_TAX_RULE'
    AND v.enabled_flag = 'Y'
    AND L.INSTALLED_FLAG in ('I', 'B')
    AND NOT EXISTS  -- this condition makes sure we dont duplicate data
        (select NULL from ZX_FC_CODES_DENORM_B codes
           where
      codes.classification_type_code = G_CLASSIFICATION_TYPE_CODE
      and codes.classification_code = v.flex_value
      and codes.ancestor_id = nvl(l_fc_id,codes.ancestor_id)
      and codes.language = l.language_code);

   END IF; -- End of France Checking

   -- If Chile is installed then
   IF Is_Country_Installed(7004, 'jlclloc') THEN

  -- Begin for CHILE..
  /* Create rows for Parent Records */

  arp_util_tax.debug( 'Create rows for Parent Records for country : CHILE ');

  OPEN G_C_GET_TYPES_INFO('DOCUMENT_SUBTYPE');

  FETCH G_C_GET_TYPES_INFO INTO
        G_CLASSIFICATION_TYPE_ID,
        G_CLASSIFICATION_TYPE_CODE,
        G_CLASSIFICATION_TYPE_NAME,
        G_CLASSIFICATION_TYP_CATEG_COD,
        G_DELIMITER;

  CLOSE  G_C_GET_TYPES_INFO;
  FIRST_LEVEL_FC_CODE_INSERT('DOCUMENT_SUBTYPE','DOCUMENT TYPE','Document Type','CL',l_fc_id);

  /*  Create a Code under the Document Subtype Fiscal Type.  */

  arp_util_tax.debug( 'Create a Code under the Document Subtype Fiscal Type for country : CHILE ');

   INSERT
  INTO ZX_FC_CODES_B (
      classification_type_code,
      classification_id,
      classification_code,
      effective_from,
      effective_to,
      parent_classification_code,
      parent_classification_id,
      country_code,
      record_type_code,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      object_version_number)
  SELECT
      'DOCUMENT_SUBTYPE',
      zx_fc_codes_b_s.nextval,
      lookup_code,
      nvl(start_date_active,to_date('01/01/1951','DD/MM/YYYY')),
      end_date_active,
      'DOCUMENT TYPE',--parent_classification_code
      l_fc_id,        --parent_classification_id
      'CL',
      'MIGRATED',
      fnd_global.user_id,
      SYSDATE,
      fnd_global.user_id,
      SYSDATE,
      FND_GLOBAL.CONC_LOGIN_ID,
      1

  FROM     FND_LOOKUPS lookups
  WHERE

      lookups.lookup_type='JLCL_AP_DOCUMENT_TYPE'
  AND    NOT EXISTS  -- this condition makes sure we dont duplicate data
      (select NULL from  ZX_FC_CODES_B Codes where
           codes.classification_type_code = 'DOCUMENT_SUBTYPE'
       and codes.parent_classification_id = nvl(l_fc_id,codes.parent_classification_id)
       and codes.classification_code = lookups.lookup_code
       );

  INSERT ALL
  INTO ZX_FC_CODES_TL(

      CLASSIFICATION_ID,
      CLASSIFICATION_NAME,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      LANGUAGE,
      SOURCE_LANG)
  VALUES
      (classification_id,
      meaning,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.user_id,
      SYSDATE,
      FND_GLOBAL.CONC_LOGIN_ID,
      language,
      source_lang)

  INTO  ZX_FC_CODES_DENORM_B

      (CLASSIFICATION_TYPE_ID,
      CLASSIFICATION_TYPE_CODE,
      CLASSIFICATION_TYPE_NAME,
      CLASSIFICATION_TYPE_CATEG_CODE,
      CLASSIFICATION_ID,
      CLASSIFICATION_CODE,
      CLASSIFICATION_NAME,
      LANGUAGE,
      EFFECTIVE_FROM,
      EFFECTIVE_TO,
      ENABLED_FLAG,
      ANCESTOR_ID,
      ANCESTOR_CODE,
      ANCESTOR_NAME,
      CONCAT_CLASSIF_CODE,
      CONCAT_CLASSIF_NAME,
      CLASSIFICATION_CODE_LEVEL,
      COUNTRY_CODE,
      SEGMENT1,
      SEGMENT2,
      SEGMENT3,
      SEGMENT4,
      SEGMENT5,
      SEGMENT6,
      SEGMENT7,
      SEGMENT8,
      SEGMENT9,
      SEGMENT10,
      SEGMENT1_NAME,
      SEGMENT2_NAME,
      SEGMENT3_NAME,
      SEGMENT4_NAME,
      SEGMENT5_NAME,
      SEGMENT6_NAME,
      SEGMENT7_NAME,
      SEGMENT8_NAME,
      SEGMENT9_NAME,
      SEGMENT10_NAME,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      LAST_UPDATE_DATE,
      REQUEST_ID,
      PROGRAM_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_LOGIN_ID,
      RECORD_TYPE_CODE)
      VALUES (
      G_CLASSIFICATION_TYPE_ID,
      G_CLASSIFICATION_TYPE_CODE,
      G_CLASSIFICATION_TYPE_NAME,
      G_CLASSIFICATION_TYP_CATEG_COD,
      classification_id,
      lookup_code,
      Meaning,
      language,
      start_date_active,
      end_date_active,
      enabled_flag,
      l_fc_id,
      'DOCUMENT TYPE',
      'Document Type',
      'DOCUMENT TYPE' || G_DELIMITER || lookup_code,
      'Document Type' || G_DELIMITER || Meaning,
      2,
      'CL',
      'DOCUMENT TYPE',
      lookup_code,
      Null,
      Null,
      Null,
      Null,
      Null,
      Null,
      Null,
      Null,
      'Document Type',
      Meaning,
      Null,
      Null,
      Null,
      Null,
      Null,
      Null,
      Null,
      Null,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.user_id,
      FND_GLOBAL.CONC_LOGIN_ID,
      sysdate,
      FND_GLOBAL.CONC_REQUEST_ID,
      fnd_global.CONC_PROGRAM_ID,
      235,
      FND_GLOBAL.CONC_LOGIN_ID,
      'MIGRATED')
  SELECT
      lookup_code,
      meaning,
      nvl(start_date_active,to_date('01/01/1951','DD/MM/YYYY')) start_date_active,
      end_date_active,
      source_lang,
      language,
      lv.enabled_flag,
      classification_id
  FROM
      ZX_FC_CODES_B codes,
      FND_LOOKUP_VALUES LV,
      FND_LANGUAGES L
  WHERE
      codes.classification_type_code = G_CLASSIFICATION_TYPE_CODE
    AND     codes.parent_classification_id = nvl(l_fc_id,parent_classification_id)
    AND     Codes.classification_code = LV.lookup_code
    AND  (Codes.RECORD_TYPE_CODE = 'MIGRATED'  OR Codes.RECORD_TYPE_CODE = 'SEEDED')
    AND  VIEW_APPLICATION_ID = 0
    AND  SECURITY_GROUP_ID = 0
    AND  Lookup_type= 'JLCL_AP_DOCUMENT_TYPE'
    AND  LV.LANGUAGE=L.LANGUAGE_CODE(+)
    AND     L.INSTALLED_FLAG in ('I', 'B')
    AND  NOT EXISTS  -- this condition makes sure we dont duplicate data
          (select NULL
        from  ZX_FC_CODES_DENORM_B codes
        where
              codes.classification_type_code = G_CLASSIFICATION_TYPE_CODE
        and   codes.classification_code = lv.lookup_code
        and   codes.ancestor_id = nvl(l_fc_id,codes.ancestor_id)
        and   codes.language = l.language_code);

    END IF; -- End for Chile checking

    arp_util_tax.debug('ZX_MIGRATE_AP(-)');

END ZX_MIGRATE_AP;


/* PROCEDURE USED TO INSERT THE FC TYPES/CODES FOR AR ENTITIES */

PROCEDURE ZX_MIGRATE_AR IS

BEGIN
   arp_util_tax.debug('ZX_MIGRATE_AR(+)');

   -- If Hungary is installed then
   IF Is_Country_Installed(7002, 'jehuloc') THEN

    /* Create Association to items for 'STATISTICAL_CODE',*/
    -- Call the common procedure to associate the items for 'JE.HU.INVIDITM.STAT_CODE'
    -- this one done for items and regimes
    Associate_items('JE.HU.INVIDITM.STAT_CODE');

    -- Call the common procedure to associate the items for 'JE.HU.ARXSTDML.STAT_CODE.
    -- i.e For AR Credit Memo Lines

      -- this one done for items and regimes ???
    Associate_items('JE.HU.ARXSTDML.STAT_CODE');

   END IF;

   -- If Poland is installed then
   IF Is_Country_Installed(7002, 'jeplloc') THEN

    /*
    Statistical Code is a shared Classification, then when this Type Code is migrated for Hungary ,
    we are also migrating for Poland, however the association needs to be performed for PL as well.
    */

    --Call the common procedure to associate the items for 'JE.PL.INVIDITM.STAT_CODE'
    -- this one done for items and regimes
    Associate_items('JE.PL.INVIDITM.STAT_CODE');

    --Call the common procedure to associate the items for 'JE. PL.ARXSTDML.STAT_CODE.
    --i.e For AR Credit Memo Lines

        -- this one done for items and regimes ??? ???
    Associate_items('JE.PL.ARXSTDML.STAT_CODE');

   END IF;

  -- Create Regime Association for 'FISCAL CLASSIFICATION CODE'
  INSERT ALL INTO
  ZX_FC_TYPES_REG_ASSOC
    (Tax_regime_code,
    classification_type_code,
    effective_FROM,
    effective_to,
    record_type_code,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login,
    classif_regime_id,
    object_version_number)
  VALUES
    (
    tax_regime_code,
    'FISCAL_CLASSIFICATION',
    SYSDATE,
    NULL,
    'MIGRATED',
    fnd_global.user_id,
    SYSDATE,
    fnd_global.user_id,
    SYSDATE,
    FND_GLOBAL.CONC_LOGIN_ID,
    zx_fc_types_reg_assoc_s.NEXTVAL,
    1)

  SELECT   unique
    tax_regime_code
  FROM
    zx_rates_b rates,
    zx_party_tax_profile ptp
  WHERE
    rates.content_owner_id = ptp.party_tax_profile_id and
    ptp.party_type_code = 'OU' and
    ptp.party_id in
        (SELECT unique decode(l_multi_org_flag,'N',l_org_id,org_id)
           FROM ar_system_parameters_all
          WHERE  global_attribute_category in ('JL.CO.ARXSYSPA.SYS_PARAMETERS',
           'JL.BR.ARXSYSPA.Additional Info','JL.AR.ARXSYSPA.SYS_PARAMETERS')) and
    not exists
        (select null from ZX_FC_TYPES_REG_ASSOC
          where classification_type_code = 'FISCAL_CLASSIFICATION' and
                tax_regime_code          = rates.tax_regime_code);

  -- Create the Second Level of Classification Codes for Transaction Condition Class
  arp_util_tax.debug( 'Create the Second Level of Classification Codes for Transaction Condition Class');

  OPEN G_C_GET_TYPES_INFO('TRX_BUSINESS_CATEGORY');
        FETCH G_C_GET_TYPES_INFO INTO
       G_CLASSIFICATION_TYPE_ID,
       G_CLASSIFICATION_TYPE_CODE,
       G_CLASSIFICATION_TYPE_NAME,
       G_CLASSIFICATION_TYP_CATEG_COD,
       G_DELIMITER;
  CLOSE G_C_GET_TYPES_INFO;

  INSERT
  INTO ZX_FC_CODES_B
    (classification_type_code,
     classification_id,
     classification_code,
     effective_from,
     effective_to,
     parent_classification_code,
     parent_classification_id,
     country_code,
     record_type_code,
     created_by,
     creation_date,
     last_updated_by,
     last_update_date,
     last_update_login,
     object_version_number)
  SELECT
    'TRX_BUSINESS_CATEGORY',  --classification_type_code
    zx_fc_codes_b_s.nextval,  --classification_id
    lookups.fc_code,      --classification_code
    lookups.effective_from,    --effective_from
    lookups.effective_to,    --effective_to
    event.tax_event_class_code,  --parent_classification_code
    fc.classification_id,    --parent_classification_id
    NULL,        --country_code is null to share AR,BR,CO country
    'MIGRATED',      --record_type_code
    fnd_global.user_id,
    sysdate,
    fnd_global.user_id,
    sysdate,
    fnd_global.conc_login_id,
    1

  FROM

  ZX_FC_CODES_B fc,
  ZX_EVENT_CLASSES_VL event,
   (SELECT
      lookups.LOOKUP_CODE fc_code,
      nvl(START_DATE_ACTIVE,to_date('01/01/1951','DD/MM/YYYY')) effective_from,
      END_DATE_ACTIVE effective_to
    FROM FND_LOOKUPS lookups
    WHERE
      (lookups.LOOKUP_TYPE = 'TRANSACTION_CLASS' or
       lookups.LOOKUP_TYPE = 'TRANSACTION_REASON')
     ) lookups

  WHERE
        fc.classification_type_code = 'TRX_BUSINESS_CATEGORY'
    and fc.parent_classification_id is null
    and fc.classification_code=event.tax_event_class_code
    and event.tax_event_class_code = 'SALES_TRANSACTION'
    AND  NOT EXISTS  -- this condition makes sure we dont duplicate data
          (select NULL from  ZX_FC_CODES_B Codes where
          codes.classification_type_code = 'TRX_BUSINESS_CATEGORY'
      and codes.parent_classification_id = fc.classification_id
      and codes.classification_code = lookups.fc_code
           );


  INSERT ALL
  INTO ZX_FC_CODES_TL
    (CLASSIFICATION_ID,
    CLASSIFICATION_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG)
  VALUES(
    classification_id,
        CASE WHEN fc_name = UPPER(fc_name)
         THEN    Initcap(fc_name)
         ELSE
           fc_name
         END,
    fnd_global.user_id,
    sysdate,
    fnd_global.user_id,
    sysdate,
    fnd_global.conc_login_id,
    LANGUAGE,
    SOURCE_LANGUAGE)

  INTO ZX_FC_CODES_DENORM_B(
    CLASSIFICATION_TYPE_ID,
    CLASSIFICATION_TYPE_CODE,
    CLASSIFICATION_TYPE_NAME,
    CLASSIFICATION_TYPE_CATEG_CODE,
    CLASSIFICATION_ID,
    CLASSIFICATION_CODE,
    CLASSIFICATION_NAME,
    LANGUAGE,
    EFFECTIVE_FROM,
    EFFECTIVE_TO,
    ENABLED_FLAG,
    ANCESTOR_ID,
    ANCESTOR_CODE,
    ANCESTOR_NAME,
    CONCAT_CLASSIF_CODE,
    CONCAT_CLASSIF_NAME,
    CLASSIFICATION_CODE_LEVEL,
    COUNTRY_CODE,
    SEGMENT1,
    SEGMENT2,
    SEGMENT3,
    SEGMENT4,
    SEGMENT5,
    SEGMENT6,
    SEGMENT7,
    SEGMENT8,
    SEGMENT9,
    SEGMENT10,
    SEGMENT1_NAME,
    SEGMENT2_NAME,
    SEGMENT3_NAME,
    SEGMENT4_NAME,
    SEGMENT5_NAME,
    SEGMENT6_NAME,
    SEGMENT7_NAME,
    SEGMENT8_NAME,
    SEGMENT9_NAME,
    SEGMENT10_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    REQUEST_ID,
    PROGRAM_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_LOGIN_ID,
    RECORD_TYPE_CODE)
    VALUES (
    G_CLASSIFICATION_TYPE_ID,
    G_CLASSIFICATION_TYPE_CODE,
    G_CLASSIFICATION_TYPE_NAME,
    G_CLASSIFICATION_TYP_CATEG_COD,
    classification_id,        --CLASSIFICATION_ID
    fc_code,             --CLASSIFICATION_CODE
    fc_name,                --CLASSIFICATION_NAME
    LANGUAGE,            --LANGUAGE
    effective_from,            --EFFECTIVE_FROM
    effective_to,            --EFFECTIVE_TO
    enabled_flag,                --ENABLED_FLAG
    parent_fc_id,            --ANCESTOR_ID
    tax_event_class_code,          --ANCESTOR_CODE
    Name,              --ANCESTOR_NAME
    tax_event_class_code ||G_DELIMITER ||
       fc_code,              --CONCAT_CLASSIF_CODE
    Name || G_DELIMITER || fc_name,       --CONCAT_CLASSIF_NAME
    2,              --CLASSIFICATION_CODE_LEVEL
    NULL,                    --country_code is null to share AR,BR,CO country
    tax_event_class_code,          --SEGMENT1
    fc_code,                        --SEGMENT2
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Name,               --SEGMENT1_NAME
    fc_name,                      --SEGMENT2_NAME
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    fnd_global.user_id,
    sysdate,
    fnd_global.user_id,
    fnd_global.conc_login_id,
    sysdate,
    fnd_global.conc_request_id,
    fnd_global.conc_program_id,
    235,
    fnd_global.conc_login_id,
    'MIGRATED')
  SELECT
    codes.fc_code,
    codes.fc_name,
    codes.effective_from,
    codes.effective_to,
    codes.source_language ,
    codes.language        ,
    event.tax_event_class_code,
    event.tax_event_class_name name,
    fc.classification_id as parent_fc_id,
    codes.classification_id,
    codes.enabled_flag
  FROM

  ZX_FC_CODES_B fc,
  ZX_EVENT_CLASSES_VL event,

  (SELECT
        FL.LOOKUP_CODE fc_code,
        FL.MEANING fc_name,
        nvl(start_date_active, to_date('01/01/1951','DD/MM/YYYY')) effective_from,
        END_DATE_ACTIVE effective_to,
        FL.SOURCE_LANG source_language,
        FL.LANGUAGE    language,
        Codes.classification_id,
        Codes.parent_classification_id,
        fl.enabled_flag,
        ROW_NUMBER()
              OVER (PARTITION BY lookup_code, language
                    ORDER BY nvl(start_date_active, to_date('01/01/1951','DD/MM/YYYY'))) AS count_num
   FROM
        ZX_FC_CODES_b Codes,
        FND_LOOKUP_VALUES FL,
        FND_LANGUAGES L
  WHERE
        Codes.classification_type_code = 'TRX_BUSINESS_CATEGORY'
  AND   Codes.classification_code = FL.lookup_code
  AND   Codes.RECORD_TYPE_CODE = 'MIGRATED'
  AND   (FL.LOOKUP_TYPE = 'TRANSACTION_CLASS' OR
         FL.LOOKUP_TYPE = 'TRANSACTION REASON')
  AND   (VIEW_APPLICATION_ID = 0 OR VIEW_APPLICATION_ID=201)
  AND   SECURITY_GROUP_ID = 0
  AND   FL.language=L.language_code(+)
  AND   L.INSTALLED_FLAG in ('I', 'B')
  ) codes

  WHERE
        fc.classification_type_code = 'TRX_BUSINESS_CATEGORY'
    and fc.parent_classification_id is null
    and fc.classification_code = event.tax_event_class_code
    and fc.classification_id = codes.parent_classification_id
    and event.tax_event_class_code = 'SALES_TRANSACTION'
    and codes.count_num = 1
    AND   NOT EXISTS  -- this condition makes sure we dont duplicate data
        (select NULL from ZX_FC_CODES_DENORM_B denorm
         where
              denorm.classification_type_code = G_CLASSIFICATION_TYPE_CODE
          and denorm.classification_code = codes.fc_code
          and denorm.ancestor_id = fc.classification_id
          and denorm.language = codes.language);


  arp_util_tax.debug('ZX_MIGRATE_AR(-)');

END ZX_MIGRATE_AR;


/*===========================================================================+
|  Function:     Is_Country_Installed                                       |
|  Description:  This function returns true if the passed application id    |
|                and country is installed.                                  |
|                                                                           |
|  ARGUMENTS  : Application id, Module Short Name                           |
|                                                                           |
|                                                                           |
|  History                                                                  |
|   28-Sep-04   Venkat                Initial Version                       |
|                                                                           |
+===========================================================================*/


FUNCTION Is_Country_Installed(
    p_application_id IN fnd_module_installations.APPLICATION_ID%TYPE,
    p_module_short_name IN fnd_module_installations.MODULE_SHORT_NAME%TYPE
    )
    RETURN BOOLEAN IS

    l_status        FND_PRODUCT_INSTALLATIONS.STATUS%TYPE;
    l_db_status     FND_PRODUCT_INSTALLATIONS.DB_STATUS%TYPE;

BEGIN

  arp_util_tax.debug( ' Is_Country_Installed .. (+) ' );

  BEGIN
    SELECT  STATUS, DB_STATUS
      into l_status, l_db_status
    FROM
      FND_MODULE_INSTALLATIONS
    WHERE
      APPLICATION_ID    = p_application_id AND
      MODULE_SHORT_NAME = p_module_short_name;
  EXCEPTION
                WHEN OTHERS THEN
                   arp_util_tax.debug('Error while getting status and db status value from fnd_module_installations');
  END;

  IF (nvl(l_status,'N') in ('I','S') or
      nvl(l_db_status,'N') in ('I','S')) THEN
    return TRUE;
  ELSE
    return FALSE;
  END IF;

  arp_util_tax.debug( ' Is_Country_Installed .. (-) ' );

END Is_Country_Installed;


/*===========================================================================+
|  Procedure:    ZX_GDF_TO_ARMEMO                                           |
|  Description:  Existing GDFs on memo lines will be migrated to Product    |
|             Category column of AR memo lines                              |
|  ARGUMENTS  :                                                             |
|                                                                           |
|  NOTES                                                                    |
|                                                                           |
|  History                                                                  |
|                                                                           |
|   28-Sep-04   Venkat      Initial Version                                 |
|                                                                           |
+===========================================================================*/

PROCEDURE ZX_GDF_TO_ARMEMO_LINES IS

BEGIN
  arp_util_tax.debug( ' ZX_GDF_TO_ARMEMO_LINES .. (+) ' );

        -- Bug#8304834- update tax_product_category from
        -- global_attribute1 only if it is null
        --
  -- If Hungary is installed then migrate Statistical Code GDF
  IF Is_Country_Installed(7002, 'jehuloc') THEN
    UPDATE   ar_memo_lines_all_b
     SET   tax_product_category = global_attribute1
     WHERE  global_attribute_category = 'JE.HU.ARXSTDML.STAT_CODE'
       AND   tax_product_category IS NULL;
  END IF;

  -- If Poland is installed then migrate Statistical Code GDF
  IF Is_Country_Installed(7002, 'jeplloc') THEN
     UPDATE   ar_memo_lines_all_b
     SET   tax_product_category = substrb(global_attribute1,1,48)
     WHERE  global_attribute_category = 'JE.PL.ARXSTDML.STAT_CODE'
       AND   tax_product_category IS NULL;
  END IF;

  -- If Argentina is installed then migrate Fiscal Classification Code GDF
  IF Is_Country_Installed(7004, 'jlarloc') THEN
     UPDATE   ar_memo_lines_all_b
     SET   tax_product_category = global_attribute1
     WHERE  global_attribute_category = 'JL.AR.ARXSTDML.AR_MEMO_LINES'
       AND   tax_product_category IS NULL;
  END IF;

  -- If Brazil is installed then migrate Fiscal Classification Code GDF
  IF Is_Country_Installed(7004, 'jlbrloc')THEN
     UPDATE   ar_memo_lines_all_b
     SET   tax_product_category = global_attribute1
     WHERE  global_attribute_category = 'JL.BR.ARXSDML.Additional'
       AND   tax_product_category IS NULL;
  END IF;

     -- If Colombia is installed then migrate Fiscal Classification Code GDF
  IF Is_Country_Installed(7004, 'jlcoloc') THEN
     UPDATE   ar_memo_lines_all_b
     SET   tax_product_category = global_attribute1
     WHERE  global_attribute_category = 'JL.CO.ARXSTDML.AR_MEMO_LINES'
       AND   tax_product_category IS NULL;
  END IF;

   arp_util_tax.debug( ' ZX_GDF_TO_ARMEMO_LINES .. (-) ' );


END ZX_GDF_TO_ARMEMO_LINES;


/*===========================================================================+
|  Procedure:    CREATE_SEEDED_FC_TYPES                                     |
|  Description:  Used to Create the FC Types for fresh install              |
|             Called from Country Defaults UI                               |
|  ARGUMENTS  :  Country Code                                               |
|                                                                           |
|  History                                                                  |
|                                                                           |
|   23-May-05   Venkat      Initial Version                                 |
|                                                                           |
+===========================================================================*/

PROCEDURE CREATE_SEEDED_FC_TYPES(p_country_code        IN VARCHAR2,
                                 x_category_set        OUT NOCOPY NUMBER,
                                 x_category_set_name   OUT NOCOPY VARCHAR2,
                                 x_return_status       OUT NOCOPY VARCHAR2
                                )
IS

  l_structure_id     mtl_category_sets_b.structure_id%TYPE;
  l_category_status  varchar2(200);

BEGIN

    x_return_status := 'S';

  -- If Inventory is installed then
  IF Zx_Migrate_Util.IS_INSTALLED('INV') = 'Y' THEN

    IF p_country_code = 'HU' OR p_country_code = 'PL' THEN

      -- Call Create Categories
      Create_Category_Sets;
      CREATE_MTL_CATEGORIES('JGZZ_STATISTICAL_CODE','STATISTICAL_CODE',
                            l_category_status,x_category_set,l_structure_id);

      -- Call a common procedure to create FC Types
      FC_TYPE_INSERT('STATISTICAL_CODE','Statistical Code',x_category_set);

    END IF;


    IF p_country_code = 'AR' OR p_country_code = 'BR' OR p_country_code = 'CO' THEN

      Create_Category_Set ('FISCAL_CLASSIFICATION',
                           'Fiscal Classification',
                           'FISCAL_CLASSIFICATION',
                           'Fiscal Classification');
      CREATE_MTL_CATEGORIES('JLZZ_AR_TX_FISCAL_CLASS_CODE', 'FISCAL_CLASSIFICATION',
                  l_category_status,x_category_set, l_structure_id);
      -- Call a common procedure to create FC Types
      FC_TYPE_INSERT('FISCAL_CLASSIFICATION','Fiscal Classification Code',x_category_set);

    END IF;


    IF p_country_code = 'TW' THEN

      Create_Category_Set ('WINE_CIGARRETE_CATEGORY',
                           'Wine Cigarrete',
                           'WINE_CIGARRETE_CATEGORY',
                           'Wine Cigarrete');
      BEGIN
        SELECT Category_set_ID INTO x_category_set
        FROM   mtl_category_sets
        WHERE  Category_Set_Name ='WINE_CIGARRETE_CATEGORY';
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
        x_category_set := NULL;
      END;

      IF x_category_set is not null then
        -- Call a common procedure to create FC Types
        FC_TYPE_INSERT('WINE CIGARETTE','Wine Cigarette',x_category_set);
      END IF;

    END IF;

    IF x_category_set is not null then
      SELECT category_set_name INTO x_category_set_name FROM MTL_CATEGORY_SETS_VL
            WHERE  category_set_id = x_category_set and rownum = 1;
    END IF;

    -- Update the record type, created by and last updated by values
    UPDATE ZX_FC_TYPES_B SET record_type_code = 'SEEDED', created_by = 120,
           last_updated_by = 120, last_update_login = 0
    WHERE  classification_type_code in ('STATISTICAL_CODE', 'FISCAL_CLASSIFICATION', 'WINE CIGARETTE') and
           classification_type_categ_code = 'PRODUCT_FISCAL_CLASS';

    UPDATE ZX_DETERMINING_FACTORS_B SET record_type_code = 'SEEDED', created_by = 120,
           last_updated_by = 120, last_update_login = 0
    WHERE  determining_factor_code in ('STATISTICAL_CODE', 'FISCAL_CLASSIFICATION', 'WINE CIGARETTE') and
           determining_factor_class_code = 'PRODUCT_FISCAL_CLASS';

    END IF;

EXCEPTION
  WHEN OTHERS THEN
      x_return_status := 'E';

END CREATE_SEEDED_FC_TYPES;


PROCEDURE OKL_MIGRATION IS
      p_flexfield        FND_FLEX_KEY_API.FLEXFIELD_TYPE;
      l_structure_id    mtl_category_sets_b.structure_id%TYPE;
      l_category_status   VARCHAR2(200);
      l_category_set         mtl_category_sets_b.Category_set_ID%TYPE;
      l_Inventory_Category_Set     mtl_category_sets_vl.Category_set_ID%TYPE;
      l_Item_id         Number;
      l_Item_organization_id      Number;
      l_record_type        zx_Fc_types_b.record_type_code%type;
      l_classification_name       fnd_lookup_values.meaning%type;
      l_lookup_code        fnd_lookup_values.lookup_code%type;
      l_meaning         fnd_lookup_values.meaning%type;
      l_language        fnd_lookup_values.language%type;
      l_start_date_active      fnd_lookup_values.start_date_active%type;
      l_end_date_active      fnd_lookup_values.end_date_active%type;
      l_source_lang        fnd_lookup_values.source_lang%type;
      l_fc_id          zx_fc_codes_b.classification_id%type;
      l_return_status        varchar2(200);
--      l_errorcode        number;
--      l_msg_count        number;
--      l_MSG_DATA        varchar2(200);
      p_category_set   mtl_category_sets_b.Category_set_ID%TYPE;
      p_structure_id   FND_FLEX_KEY_API.STRUCTURE_TYPE;
      l_segment        FND_FLEX_KEY_API.segment_type;
      p_StatCode_Segment    FND_FLEX_KEY_API.segment_type;
      p_StatCode_Segmentnew    FND_FLEX_KEY_API.segment_type;
      l_flex_exists         Boolean;
      l_structure_exists    Boolean;
      l_segment_exists      Boolean;
      p_StatCode_struct    FND_FLEX_KEY_API.STRUCTURE_TYPE;
      msg                   VARCHAR2(1000);
      l_category_set_id         mtl_category_sets_b.Category_set_ID%TYPE;
--      l_control_level NUMBER;
--      l_row_id        VARCHAR2(100);
--      l_next_val      NUMBER;

BEGIN

   arp_util_tax.debug( 'OKL Migration ... (+) ' );
/* Check for Inventory Installed or not, if so, create under Inventory, if not Create Product Category */

 IF Zx_Migrate_Util.IS_INSTALLED('INV') = 'Y' THEN

   -- OKL MIGRATION
   -- Category Set should had been created as a pre requesite before migration
   -- Create Categories and Fiscal Type for OKL Category Set.

    CREATE_MTL_CATEGORIES('AR_TAX_PRODUCT_FISCAL_CLASS','Product Fiscal Class - Leasing',l_category_status,l_category_set,l_structure_id);

  -- Call a common procedure to create FC Types
  IF l_category_status = 'EXISTS' then

  arp_util_tax.debug( 'Creating Lease Product Fiscal Type');

    FC_TYPE_INSERT('LEASE_MGT_PROD_FISC_CLASS','Lease Management Product Fiscal Class',l_category_set);

   --  Regime Association

  INSERT ALL INTO  ZX_FC_TYPES_REG_ASSOC
    (Tax_regime_code,
    classification_type_code,
    effective_FROM,
    effective_to,
    record_type_code,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login,
    classif_regime_id,
    object_version_number)
  VALUES
    (tax_regime_code,
    'LEASE_MGT_PROD_FISC_CLASS',
    SYSDATE,
    NULL,
    'MIGRATED',
    fnd_global.user_id,
    SYSDATE,
    fnd_global.user_id,
    SYSDATE,
    FND_GLOBAL.CONC_LOGIN_ID,
    zx_fc_types_reg_assoc_s.nextval,
    1)
  SELECT   unique rates.tax_regime_code
  FROM ZX_RATES_B rates,
       AR_VAT_TAX_ALL_B codes
  WHERE codes.vat_tax_id        = nvl(rates.source_id, rates.tax_rate_id) and
        codes.leasing_flag  = 'Y' and
        rates.record_type_code          = 'MIGRATED' and
        not exists
          (select null from ZX_FC_TYPES_REG_ASSOC
            where classification_type_code = 'LEASE_MGT_PROD_FISC_CLASS'
              and   tax_regime_code          = rates.tax_regime_code);

    --  Disable Lookup Type
    --  Change the Flexfield Structure Segment value Set.
  BEGIN
       fnd_flex_key_api.set_session_mode('seed_data');
   l_flex_exists:= FALSE;

  l_flex_exists:= fnd_flex_key_api.flexfield_exists(appl_short_name => 'INV',flex_code => 'MCAT',flex_title => 'Item Categories');

  If l_flex_exists Then
     p_flexfield:= fnd_flex_key_api.find_flexfield(appl_short_name => 'INV',flex_code => 'MCAT');

      BEGIN
       p_StatCode_struct:= fnd_flex_key_api.find_structure(p_flexfield,'AR_TAX_PRODUCT_FISCAL_CLASS');
       l_structure_exists:=TRUE;
       EXCEPTION
         WHEN OTHERS THEN
         msg := 'ERROR: struct not found' || fnd_flex_key_api.message;
         l_structure_exists:=FALSE;
      END;

    IF l_structure_exists THEN
    -- find current segment
      BEGIN
       p_StatCode_Segment:= fnd_flex_key_api.find_segment(flexfield=> p_flexfield,structure=> p_StatCode_struct,segment_name=>'Product Fiscal Classification');
       l_segment_exists:=TRUE;
      EXCEPTION
       WHEN OTHERS THEN
       msg := substr('ERROR: ' || fnd_flex_key_api.message,1,225);
       l_segment_exists:=FALSE;
      END;

    IF l_segment_exists THEN
    -- Create new segment wich will replace the definition of current.
       BEGIN
       p_StatCode_Segment:= fnd_flex_key_api.new_segment(flexfield => p_flexfield,
           structure => p_StatCode_struct,
           segment_name => 'Product Fiscal Classification',
           description  => 'Product Fiscal Classification',
           column_name  => 'SEGMENT1',
           segment_number => 1,
           enabled_flag  => 'Y',
           displayed_flag => 'Y',
           indexed_flag => 'Y',
           value_set   => '30 Characters',
           default_type => NULL,
           default_value => NULL,
           required_flag  =>'Y',
           security_flag  => 'N',
           range_code => NULL,
           display_size => 30,
           description_size => 50,
           concat_size => 25,
           lov_prompt => 'Product Fiscal Classification',
           runtime_property_function => NULL,
           additional_where_clause =>   NULL);

        EXCEPTION
        WHEN OTHERS THEN
        msg :=  SUBSTR('ERROR: ' || fnd_flex_key_api.message,1,225);
       END;

       BEGIN
--        fnd_flex_key_api.add_segment(p_flexfield,p_StatCode_struct,p_StatCode_Segment);
     fnd_flex_key_api.modify_segment(p_flexfield, p_StatCode_struct, p_StatCode_Segment, p_StatCode_Segmentnew);
        l_segment_exists:=TRUE;
        EXCEPTION
        WHEN OTHERS THEN
        msg := SUBSTR('ERROR: ' || fnd_flex_key_api.message,1,225);
        l_segment_exists:=FALSE;
       END;

      END IF; -- Segment
    End if; -- Structure
  End If; -- Flex

 END;

   END IF;
 END IF; -- Check for Inventory installed

     -- Create Party Fiscal Type
     FC_PARTY_TYPE_INSERT('LEASE_MGT_PTY_FISC_CLASS','Lease Management Party Fiscal Class','AR_TAX_PARTY_FISCAL_CLASS');

    -- Create User Defined Codes

  arp_util_tax.debug( 'Creating the Codes under User Defined Fiscal Classifications ');

  OPEN G_C_GET_TYPES_INFO('USER_DEFINED');

  FETCH G_C_GET_TYPES_INFO INTO
      G_CLASSIFICATION_TYPE_ID,
      G_CLASSIFICATION_TYPE_CODE,
      G_CLASSIFICATION_TYPE_NAME,
      G_CLASSIFICATION_TYP_CATEG_COD,
      G_DELIMITER;

  CLOSE G_C_GET_TYPES_INFO;

  INSERT
  INTO ZX_FC_CODES_B
      (classification_type_code,
      classification_id,
      classification_code,
      effective_from,
      effective_to,
      parent_classification_code,
      parent_classification_id,
      country_code,
      record_type_code,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
    object_version_number)
  (SELECT    'USER_DEFINED',
      zx_fc_codes_b_s.nextval,
      lookup_code,      --classification_code
      nvl(start_date_active,sysdate),  --effective_from
      end_date_active,    --effective_to
      null,----parent_classification_code
      null,----parent_classification_id
      null,
      'MIGRATED',
      fnd_global.user_id,
      SYSDATE,
      fnd_global.user_id,
      SYSDATE,
      FND_GLOBAL.CONC_LOGIN_ID,
      1
  FROM   FND_LOOKUP_VALUES lookups
  WHERE  lookups.lookup_type='AR_TAX_TRX_BUSINESS_CATEGORY'
    AND     LANGUAGE = userenv('LANG')
  AND NOT EXISTS
     -- this condition makes sure we dont duplicate data
    (select NULL from  ZX_FC_CODES_B Codes where
      codes.classification_type_code = 'USER_DEFINED'
      and codes.parent_classification_id is null
      and codes.classification_code = lookups.lookup_code)
  );

  INSERT ALL
  INTO ZX_FC_CODES_TL
      (CLASSIFICATION_ID,
      CLASSIFICATION_NAME,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      LANGUAGE,
      SOURCE_LANG)
  VALUES   (classification_id,
        CASE WHEN Meaning = UPPER(Meaning)
         THEN    Initcap(Meaning)
         ELSE
           Meaning
         END,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.user_id,
      SYSDATE,
      FND_GLOBAL.CONC_LOGIN_ID,
      language,
      source_lang)
  INTO ZX_FC_CODES_DENORM_B(
     CLASSIFICATION_TYPE_ID,
     CLASSIFICATION_TYPE_CODE,
     CLASSIFICATION_TYPE_NAME,
     CLASSIFICATION_TYPE_CATEG_CODE,
     CLASSIFICATION_ID,
     CLASSIFICATION_CODE,
     CLASSIFICATION_NAME,
     LANGUAGE,
     EFFECTIVE_FROM,
     EFFECTIVE_TO,
     ENABLED_FLAG,
     ANCESTOR_ID,
     ANCESTOR_CODE,
     ANCESTOR_NAME,
     CONCAT_CLASSIF_CODE,
     CONCAT_CLASSIF_NAME,
     CLASSIFICATION_CODE_LEVEL,
     COUNTRY_CODE,
     SEGMENT1,
     SEGMENT2,
     SEGMENT3,
     SEGMENT4,
     SEGMENT5,
     SEGMENT6,
     SEGMENT7,
     SEGMENT8,
     SEGMENT9,
     SEGMENT10,
     SEGMENT1_NAME,
     SEGMENT2_NAME,
     SEGMENT3_NAME,
     SEGMENT4_NAME,
     SEGMENT5_NAME,
     SEGMENT6_NAME,
     SEGMENT7_NAME,
     SEGMENT8_NAME,
     SEGMENT9_NAME,
     SEGMENT10_NAME,
     CREATED_BY,
     CREATION_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN,
     LAST_UPDATE_DATE,
     REQUEST_ID,
     PROGRAM_ID,
     PROGRAM_APPLICATION_ID,
     PROGRAM_LOGIN_ID,
     RECORD_TYPE_CODE)
  VALUES (
    G_CLASSIFICATION_TYPE_ID,
    G_CLASSIFICATION_TYPE_CODE,
    G_CLASSIFICATION_TYPE_NAME,
    G_CLASSIFICATION_TYP_CATEG_COD,
    classification_id,
    lookup_code,
    Meaning,
    language,
    nvl(start_date_active,sysdate),  --effective_from
    end_date_active,    --effective_to
    'Y',
    null,
    null,
    null,
    lookup_code,
    Meaning,
    1,
    NULL,
    lookup_code,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Meaning,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    Null,
    fnd_global.user_id,
    SYSDATE,
    fnd_global.user_id,
    FND_GLOBAL.CONC_LOGIN_ID,
    sysdate,
    FND_GLOBAL.CONC_REQUEST_ID,
    fnd_global.CONC_PROGRAM_ID,
    235,
    FND_GLOBAL.CONC_LOGIN_ID,
    'MIGRATED')
  SELECT
    lookup_code,
    meaning,
    nvl(start_date_active,sysdate) start_date_active,
    end_date_active,
    source_lang,
    language,
    lv.enabled_flag,
    classification_id
  FROM
    ZX_FC_CODES_B Codes,
    FND_LOOKUP_VALUES LV,
    FND_LANGUAGES L
  WHERE
        Codes.classification_type_code = G_CLASSIFICATION_TYPE_CODE
    AND Codes.parent_classification_id is null
    AND Codes.classification_code = lv.lookup_code
    AND Codes.RECORD_TYPE_CODE IN ('MIGRATED','SEEDED')
    AND LV.VIEW_APPLICATION_ID = 222
    AND LV.SECURITY_GROUP_ID = 0
    AND LV.lookup_type='AR_TAX_TRX_BUSINESS_CATEGORY'
    AND LV.language=L.language_code(+)
    AND L.INSTALLED_FLAG in ('I', 'B')
    AND NOT EXISTS  -- this condition makes sure we dont duplicate data
       (select NULL from ZX_FC_CODES_DENORM_B codes where
          codes.classification_type_code = G_CLASSIFICATION_TYPE_CODE
      and codes.classification_code = lv.lookup_code
      and codes.ancestor_id is null
      and codes.language = l.language_code);

    --  Disable Lookup Type
     -- Create Country defaults ?
   arp_util_tax.debug( 'OKL Migration ... (-) ' );

END OKL_MIGRATION;



/*===========================================================================+
|  Procedure:    ZX_FC_MIGRATE                                              |
|  Description:  This is the main procedure of fiscal classification        |
|         migration.                                                        |
|  ARGUMENTS  :                                                             |
|                                                                           |
|  NOTES                                                                    |
|                                                                           |
|  History                                                                  |
|    zmohiudd  Created                                                      |
|                                                                           |
+===========================================================================*/


PROCEDURE ZX_FC_MIGRATE IS

BEGIN

   arp_util_tax.debug( ' ZX_FC_MIGRATE .. (+) ' );
   arp_util_tax.debug( ' Now calling MTL system items ..  ' );

   ZX_FC_MIGRATE_PKG.MTL_SYSTEM_ITEMS;

   arp_util_tax.debug( ' Now calling FC Entities ..  ' );

   ZX_FC_MIGRATE_PKG.FC_ENTITIES;

   arp_util_tax.debug( ' Now calling Migrate AP ..  ' );

   If Zx_Migrate_Util.IS_INSTALLED('AP') = 'Y' THEN
     ZX_MIGRATE_AP;
   End if;

   arp_util_tax.debug( ' Now calling Migrate AR ..  ' );

   If Zx_Migrate_Util.IS_INSTALLED('AR') = 'Y' THEN
     ZX_MIGRATE_AR;
   End if;

   arp_util_tax.debug( ' Now calling Migrate OKL ..  ' );
   OKL_MIGRATION;

   arp_util_tax.debug( ' Now calling country default.. ' );

   ZX_FC_MIGRATE_PKG.COUNTRY_DEFAULT;

   arp_util_tax.debug( ' Now calling ZX_GDF_TO_ARMEMO_LINES...' );

   ZX_GDF_TO_ARMEMO_LINES;

   arp_util_tax.debug('ZX_FC_MIGRATE_PKG...(-)');

END ZX_FC_MIGRATE;

BEGIN

   SELECT NVL(MULTI_ORG_FLAG,'N')  INTO L_MULTI_ORG_FLAG FROM
   FND_PRODUCT_GROUPS;

   IF L_MULTI_ORG_FLAG  = 'N' THEN

     FND_PROFILE.GET('ORG_ID',L_ORG_ID);

     IF L_ORG_ID IS NULL THEN
       arp_util_tax.debug('MO: Operating Units site level profile option value not set , resulted in Null Org Id');
     END IF;
   ELSE
     L_ORG_ID := NULL;
   END IF;



EXCEPTION
WHEN OTHERS THEN
    arp_util_tax.debug('Exception in constructor of Fiscal Classification '||sqlerrm);

END ZX_FC_MIGRATE_PKG ;

/
