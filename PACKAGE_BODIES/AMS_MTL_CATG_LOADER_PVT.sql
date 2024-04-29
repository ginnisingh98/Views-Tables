--------------------------------------------------------
--  DDL for Package Body AMS_MTL_CATG_LOADER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_MTL_CATG_LOADER_PVT" AS
/* $Header: amsvmcab.pls 120.2 2006/01/11 04:42:36 inanaiah noship $ */

-- Start of Comments
--
-- NAME
--   Load_Inv_Category
--
-- PURPOSE
--   This procedure is created to as a concurrent program which
--   will load inventory categories into ams denorm table.
--
-- NOTES
--
--
-- HISTORY
--   07/01/2002         ABHOLA       Created
-- End of Comments

PROCEDURE Load_Inv_Category
                        (errbuf        OUT NOCOPY    VARCHAR2,
                         retcode       OUT NOCOPY    NUMBER)

IS
valid_ccid  boolean ;

/**  USE DISABLE DATE
-- cursor c1 is select category_id, structure_id
--               from mtl_categories_vl
--     where    ENABLED_FLAG = 'Y'
--               and      nvl(START_DATE_ACTIVE,sysdate) <= sysdate
--               and      nvl(END_DATE_ACTIVE,sysdate)  >= sysdate ;
***/


 cursor c1 is select category_id, structure_id
               from mtl_categories_vl
     where  nvl(DISABLE_DATE,sysdate)  >= sysdate ;

c1_rec c1%ROWTYPE;


/*****cursor get_lang is select language_code
                     from fnd_languages
                    where installed_flag in ('I','B');
l_language VARCHAR2(20); ****/


cursor get_cat_b is select count(*) from  AMS_MTL_CATEGORIES_DENORM_B;

cursor get_cat_tl is select count(*) from  AMS_MTL_CATEGORIES_DENORM_TL;

lcount NUMBER;


begin

/*****  OPEN get_lang;
FETCH get_lang INTO l_language;
CLOSE get_lang; ******/

OPEN get_cat_b;
FETCH get_cat_b into lcount;
CLOSE get_cat_b;

 if (lcount > 1) then

    delete from AMS_MTL_CATEGORIES_DENORM_B;

 end if;

OPEN get_cat_tl;
FETCH get_cat_tl into lcount;
CLOSE get_cat_tl;

 if (lcount > 1) then

    delete from AMS_MTL_CATEGORIES_DENORM_TL;

 end if;


OPEN get_cat_b;
FETCH get_cat_b into lcount;
CLOSE get_cat_b;


for c1_rec IN c1 LOOP

valid_ccid := FND_FLEX_KEYVAL.validate_ccid(appl_short_name => 'INV',
                        key_flex_code           => 'MCAT',
                        structure_number        => c1_rec.structure_id,
                        combination_id          => c1_rec.category_id);
                if (valid_ccid) then


                        INSERT INTO  AMS_MTL_CATEGORIES_DENORM_B (
                          CATEGORY_ID      ,
                          STRUCTURE_ID   ,
                          LAST_UPDATE_DATE  ,
                          LAST_UPDATED_BY  ,
                          CREATION_DATE  ,
                          CREATED_BY    ,
                          LAST_UPDATE_LOGIN ,
                          concatenated_ids   )
                          VALUES (
                          c1_rec.category_id,
                           c1_rec.structure_id,
                           sysdate,
                           FND_GLOBAL.user_id,
                           sysdate,
                           FND_GLOBAL.user_id,
                           FND_GLOBAL.conc_login_id,
                          FND_FLEX_KEYVAL.concatenated_values
                          );

                        insert into  AMS_MTL_CATEGORIES_DENORM_TL (
                          CATEGORY_ID      ,
                          LANGUAGE   ,
                          SOURCE_LANG     ,
                          LAST_UPDATE_DATE ,
                          LAST_UPDATED_BY   ,
                          CREATION_DATE      ,
                          CREATED_BY         ,
                          LAST_UPDATE_LOGIN  ,
                          concatenated_description )
    SELECT
                          c1_rec.category_id,
                          l.language_code,
                          USERENV('LANG'),
                          sysdate,
                          FND_GLOBAL.user_id,
                          sysdate,
                          FND_GLOBAL.user_id,
                          FND_GLOBAL.conc_login_id,
                          FND_FLEX_KEYVAL.concatenated_descriptions
                          FROM     fnd_languages l
      WHERE  l.installed_flag IN ('I', 'B')
      AND NOT EXISTS (SELECT   NULL
                      FROM     AMS_MTL_CATEGORIES_DENORM_TL t
                      WHERE  t.category_id = c1_rec.category_id
                      AND t.language = l.language_code);


                else


                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Invalid Category '||to_char(c1_rec.category_id) );

                end if;

END LOOP;

retcode := 0;

commit;

EXCEPTION
WHEN OTHERS THEN

  retcode := 1;

END;

-- ===========================================
-- ADD_LANGUAGE
--=============================================
procedure ADD_LANGUAGE
is
begin
  delete from AMS_MTL_CATEGORIES_DENORM_TL T
  where not exists
    (select NULL
    from AMS_MTL_CATEGORIES_DENORM_B B
    where B.CATEGORY_ID = T.CATEGORY_ID
    );

  update AMS_MTL_CATEGORIES_DENORM_TL T set (
      CATEGORY_ID
    ) = (select
      B.CATEGORY_ID
    from AMS_MTL_CATEGORIES_DENORM_TL B
    where B.CATEGORY_ID = T.CATEGORY_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CATEGORY_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CATEGORY_ID,
      SUBT.LANGUAGE
    from AMS_MTL_CATEGORIES_DENORM_TL SUBB, AMS_MTL_CATEGORIES_DENORM_TL SUBT
    where SUBB.CATEGORY_ID = SUBT.CATEGORY_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.CATEGORY_ID <> SUBT.CATEGORY_ID
  ));


     INSERT INTO   AMS_MTL_CATEGORIES_DENORM_TL (
          CATEGORY_ID      ,
          LANGUAGE   ,
          SOURCE_LANG     ,
          LAST_UPDATE_DATE ,
          LAST_UPDATED_BY   ,
          CREATION_DATE      ,
          CREATED_BY         ,
          LAST_UPDATE_LOGIN  ,
          concatenated_description )
   SELECT
            B.CATEGORY_ID,
           l.language_code,
           B.SOURCE_LANG,
            B.LAST_UPDATE_DATE,
           B.LAST_UPDATED_BY,
           B.CREATION_DATE,
           B.CREATED_BY,
           B.LAST_UPDATE_LOGIN,
           B.concatenated_description
  from AMS_MTL_CATEGORIES_DENORM_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMS_MTL_CATEGORIES_DENORM_TL T
    where T.CATEGORY_ID = B.CATEGORY_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

end ADD_LANGUAGE;


PROCEDURE UPGRADE_INTEREST_TYPES
                        (errbuf        OUT NOCOPY    VARCHAR2,
                         retcode       OUT NOCOPY    NUMBER)
IS
   CURSOR c_get_comp
   IS
   SELECT interest_type_id,Competitor_product_id
   ,COMPETITOR_PRODUCT_NAME
   FROM ams_competitor_products_vl
   WHERE interest_type_id is not null;

   l_interest_type_id    NUMBER;
   l_competitor_prod_id  NUMBER;
   l_comp_name VARCHAR2(240);

   CURSOR c_get_category
   IS
   SELECT PRODUCT_CATEGORY_ID
   ,PRODUCT_CAT_SET_ID
   FROM as_interest_types_b
   where interest_type_id = l_interest_type_id;

   l_cat_rec c_get_category%ROWTYPE;

   CURSOR c_get_interest_type
   IS
   SELECT interest_type
   FROM as_interest_types_tl
   where interest_type_id = l_interest_type_id
   and language = userenv('LANG');

   l_interest_type varchar2(80);

   i NUMBER := 0;

BEGIN
   OPEN c_get_comp;
   LOOP
      FETCH c_get_comp INTO l_interest_type_id,l_competitor_prod_id,l_comp_name;
      EXIT WHEN c_get_comp%NOTFOUND;

      OPEN c_get_category;
      FETCH c_get_category INTO l_cat_rec;

      IF c_get_category%FOUND
      AND l_cat_rec.product_category_id is not null
      AND l_cat_rec.product_cat_set_id is not null
      THEN
         UPDATE ams_competitor_products_b
         SET category_id = l_cat_rec.product_category_id
         ,category_set_id = l_cat_rec.product_cat_set_id
         WHERE competitor_product_id = l_competitor_prod_id;
      ELSE

         OPEN c_get_interest_type;
         FETCH c_get_interest_type INTO l_interest_type;
         CLOSE c_get_interest_type;
         IF ( i=0) THEN
           FND_MESSAGE.Set_Name('AMS', 'AMS_API_INTEREST_TYPE_MISSING');
           FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.Get());
           -- Category Mapping is missing for the following Interest Types in the as_interest_types:
         END IF;
         FND_MESSAGE.Set_Name('AMS', 'AMS_INTEREST_TYPE_ASSOC_COMP');
         -- Interest Type NAME ( Id: ID) associated with the COMPNAME (Competitor_Id: COMPID).
         FND_MESSAGE.Set_Token('NAME',l_interest_type);
         FND_MESSAGE.Set_Token('ID',l_interest_type_id);
         FND_MESSAGE.Set_Token('COMPNAME',l_comp_name);
         FND_MESSAGE.Set_Token('COMPID',l_competitor_prod_id);
         FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.Get());
         i := i+1;
      END IF;
      CLOSE c_get_category;
   END LOOP;
   CLOSE c_get_comp;

retcode := 0;

commit;

EXCEPTION
WHEN OTHERS THEN

  retcode := 1;

END UPGRADE_INTEREST_TYPES;

PROCEDURE UPGRADE_CATEGORIES
                        (errbuf        OUT NOCOPY    VARCHAR2,
                         retcode       OUT NOCOPY    NUMBER)
IS

   CURSOR c_get_cat
   IS
   SELECT activity_product_id,category_set_id
   ,category_id, act_product_used_by_id, arc_act_product_used_by
   FROM ams_act_products act
   WHERE level_type_code = 'FAMILY'
   and category_id is not null
   and category_set_id is not null
   and category_set_id not in (select distinct category_set_id
          from ENI_PROD_DEN_HRCHY_PARENTS_V);

   l_activity_product_id    NUMBER;
   l_category_set_id  NUMBER;
   l_category_id  NUMBER;
   l_obj_id NUMBER;
   l_obj_type VARCHAR2(10);


   CURSOR c_get_map_cat
   IS
   SELECT dt.target_catg_id cat_id, hd.target_catg_set_id cat_set_id
   FROM ego_catg_map_hdrs_b hd
   ,ego_catg_map_dtls dt
   WHERE hd.source_catg_set_id = l_category_set_id
   AND dt.source_catg_id = l_category_id
   AND hd.catg_map_id = dt.catg_map_id;

   l_cat_rec c_get_map_cat%ROWTYPE;

   CURSOR c_get_cat_name( cat_id IN NUMBER)
   IS
   SELECT description
   from mtl_categories_vl
   where category_id = cat_id ;

   l_cat_name_rec c_get_cat_name%ROWTYPE;
   i number := 0;

BEGIN

   OPEN c_get_cat;
   LOOP
      FETCH c_get_cat INTO l_activity_product_id,l_category_set_id,l_category_id,l_obj_id,l_obj_type;
      EXIT WHEN c_get_cat%NOTFOUND;

      OPEN c_get_cat_name(l_category_id);
      FETCH c_get_cat_name INTO l_cat_name_rec.description ;
      CLOSE c_get_cat_name;

      OPEN c_get_map_cat;
      FETCH c_get_map_cat INTO l_cat_rec;

      IF c_get_map_cat%FOUND
      THEN
         UPDATE ams_act_products
         SET category_id = l_cat_rec.cat_id
         ,category_set_id = l_cat_rec.cat_set_id
         WHERE activity_product_id = l_activity_product_id;
      ELSE
         IF (i = 0) THEN
           FND_MESSAGE.Set_Name('AMS', 'AMS_API_CAT_MAPPING_MISSING');
           -- Category Mapping is missing for the following:
           FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.Get());
         END IF;
         FND_MESSAGE.Set_Name('AMS', 'AMS_API_CAT_ASSOC_OBJECT');
         -- NAME ( Id: ID) category associated with the object OBJTYPE (ObjId: OBJID).
         FND_MESSAGE.Set_Token('NAME',l_cat_name_rec.description);
         FND_MESSAGE.Set_Token('ID',l_category_id);
         FND_MESSAGE.Set_Token('OBJTYPE',l_obj_type);
         FND_MESSAGE.Set_Token('OBJID',l_obj_id);
         FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.Get());
         i := i+1;
      END IF;
      CLOSE c_get_map_cat;
   END LOOP;
   CLOSE c_get_cat;

   -- R12 : Changes due to Marketing Requirement for data migration
   BEGIN

     UPDATE AMS_ACT_PRODUCTS A
     SET (A.CATEGORY_ID, A.CATEGORY_SET_ID) =
                         (SELECT B.CATEGORY_ID, B.CATEGORY_SET_ID
                            FROM MTL_ITEM_CATEGORIES B,
                                 MTL_DEFAULT_CATEGORY_SETS D
                           WHERE B.INVENTORY_ITEM_ID = A.INVENTORY_ITEM_ID
                             AND B.ORGANIZATION_ID = A.ORGANIZATION_ID
                             AND D.CATEGORY_SET_ID = B.CATEGORY_SET_ID
                             AND D.FUNCTIONAL_AREA_ID = 11)
     WHERE A.CATEGORY_ID IS NULL
     AND A.LEVEL_TYPE_CODE = 'PRODUCT'
     AND ARC_ACT_PRODUCT_USED_BY IN ('CAMP','CSCH');

   END;

retcode := 0;

commit;

EXCEPTION
WHEN OTHERS THEN

  retcode := 1;

END UPGRADE_CATEGORIES;


END AMS_MTL_CATG_LOADER_PVT;

/
