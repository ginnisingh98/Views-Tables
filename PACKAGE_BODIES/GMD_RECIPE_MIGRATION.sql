--------------------------------------------------------
--  DDL for Package Body GMD_RECIPE_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_RECIPE_MIGRATION" AS
/* $Header: GMDRMIGB.pls 120.4 2006/09/19 14:37:13 txdaniel noship $ */
   PROCEDURE migrate_recipe (
      p_api_version              IN       	NUMBER,
      p_init_msg_list            IN       	VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       	VARCHAR2 := fnd_api.g_false,
      x_return_status            OUT NOCOPY     VARCHAR2,
      x_msg_count                OUT NOCOPY     NUMBER,
      x_msg_data                 OUT NOCOPY     VARCHAR2,
      p_recipe_no_choice         IN       	VARCHAR2 )
   IS
      /* This cursor extracts distinct formula - routing combination to create Recipes as
         formulas */
      CURSOR formula_cur
      IS
         SELECT   h.formula_no,
                  h.formula_vers,
                  e.routing_id,
                  e.formula_id,
                  h.formula_desc1
             FROM fm_form_eff_bak e,
                  fm_form_mst_b h
            WHERE NOT EXISTS ( SELECT 1
                                 FROM gmd_recipe_eff_assoc
                                WHERE fmeff_id = e.fmeff_id )
              AND e.formula_id = h.formula_id
         GROUP BY h.formula_no,
                  h.formula_vers,
                  e.routing_id,
                  e.formula_id,
                  h.formula_desc1
         ORDER BY h.formula_no,
                  h.formula_vers;

      /* This cursor extracts distinct formula - routing combination to create Recipes as
         items */
      CURSOR product_cur
      IS
         SELECT   i.item_no,
                  e.formula_id,
                  e.routing_id,
                  i.item_desc1
             FROM fm_form_mst_b h,
                  fm_form_eff_bak e,
                  fm_matl_dtl m,
                  ic_item_mst i
            WHERE NOT EXISTS ( SELECT 1
                                 FROM gmd_recipe_eff_assoc
                                WHERE fmeff_id = e.fmeff_id )
              AND e.formula_id = m.formula_id
              AND e.formula_id = h.formula_id
              AND m.item_id = i.item_id
              AND m.line_no = 1
              AND m.line_type = 1
         GROUP BY i.item_no,
                  e.formula_id,
                  e.routing_id,
                  i.item_desc1
         ORDER BY i.item_no;

      /* Extracts routing step and line information from fm_rout_mtl_bak table */
      CURSOR recipe_material_cur
      IS
         SELECT   rm.routingstep_no,
                  rm.formulaline_id,
                  rm.routing_id,
                  rm.formula_id,
                  rm.text_code,
                  rm.last_updated_by,
                  rm.created_by,
                  rm.last_update_date,
                  rm.creation_date,
                  rm.last_update_login
             FROM fm_rout_mtl_bak rm
            WHERE rm.routingstep_no IS NOT NULL
              AND NOT EXISTS ( SELECT 1
                                 FROM gmd_recipe_step_materials
                                WHERE formulaline_id = rm.formulaline_id
                                  AND EXISTS ( SELECT recipe_id
                                                 FROM gmd_recipes
                                                WHERE formula_id = rm.formula_id
                                                  AND routing_id = rm.routing_id ))
         GROUP BY rm.routingstep_no,
                  rm.formulaline_id,
                  rm.routing_id,
                  rm.formula_id,
                  rm.text_code,
                  rm.last_updated_by,
                  rm.created_by,
                  rm.last_update_date,
                  rm.creation_date,
                  rm.last_update_login;

   /* Get the duplicate effectivity ids */
   /* Get all effectivities where the only difference is the customer id */
   /* To create a customer specific effectivity, in past a new effectivity for that
      customer would be created.  However, now with the new GMD model customer specific effectivities
      are stored in a recipe-customer table */
   CURSOR get_dup_cust_eff
   IS
      SELECT   orgn_code,
               item_id,
               formula_use,
               end_date,
               start_date,
               min_qty,
               max_qty,
               std_qty,
               item_um,
               preference,
               routing_id,
               formula_id,
            /* Thomas - Bug 2562007, duplicate rows with delete mark are needed */
            -- delete_mark,
               COUNT (* ) eff_dup_count
          FROM fm_form_eff
       /* Thomas - Bug 2562007,Their may be duplicates without customer id */
       -- WHERE cust_id IS NOT NULL
      GROUP BY orgn_code,
               item_id,
               formula_use,
               end_date,
               start_date,
               min_qty,
               max_qty,
               std_qty,
               item_um,
               preference,
               routing_id,
               formula_id
            -- delete_mark
        HAVING COUNT (* ) > 1;

      /* Check if recipe customer exists */
      Cursor check_recipe_cust_exists(v_recipe_id NUMBER, v_customer_id NUMBER) IS
        SELECT 1
           FROM sys.DUAL
          WHERE EXISTS ( SELECT 1
                           FROM gmd_recipe_customers
                          WHERE recipe_id = v_recipe_id
                            AND customer_id = v_customer_id);

      /* Check if recipe step material exists */
      Cursor check_step_mat_exists(v_recipe_id NUMBER, v_formulaline_id NUMBER) IS
        SELECT 1
           FROM sys.DUAL
          WHERE EXISTS ( SELECT 1
                           FROM gmd_recipe_step_materials
                          WHERE recipe_id = v_recipe_id
                            AND formulaline_id = v_formulaline_id);

      /* Get all invalid validity rules */
      CURSOR get_invalid_validity_rules
      IS
         SELECT recipe_validity_rule_id,
                item_id
           FROM gmd_recipe_validity_rules;

      /* Check if the item id exists in ic_item_mst table */
      CURSOR get_valid_item ( v_item_id NUMBER )
      IS
         SELECT 1
           FROM sys.DUAL
          WHERE EXISTS ( SELECT 1
                           FROM ic_item_mst
                          WHERE item_id = v_item_id
                            AND delete_mark = 0 );

      /* Get the costing details based on effectivities that have cost rollup done */
      CURSOR cm_cmpt_dtl_cur (pfmeff_id NUMBER )
      IS
         SELECT *
           FROM cm_cmpt_dtl
          WHERE fmeff_id = pfmeff_id;

      /* Defining all local variables  */
      l_recipe_id            gmd_recipes.recipe_id%TYPE            := 0;
      l_routingstep_id       NUMBER                                := 0;
      l_recipe_no            gmd_recipes.recipe_no%TYPE            := NULL;
      l_recipe_version       gmd_recipes.recipe_version%TYPE       := 0;
      l_recipe_status        gmd_recipes.recipe_status%TYPE        := '700';
      l_counter              NUMBER                                := 0;
      l_cm_counter           NUMBER                                := 0;
      l_recipe_vr_id         NUMBER                                := 0;
      l_return_val           NUMBER                                := 0;
      l_item_count           NUMBER                                := 0;
      l_dup_counter          NUMBER                                := 0;
      l_fmeff_id             NUMBER;
      l_dummy_id             NUMBER;
      l_owner_orgn           VARCHAR2(4);
      l_creation_orgn        VARCHAR2(4);
      l_delete_mark          NUMBER(5);
      l_creation_date        DATE;
      l_created_by           NUMBER(15);
      l_last_updated_by      NUMBER(15);
      l_last_update_date     DATE;
      l_last_update_login    NUMBER(15);
      l_text_code            NUMBER(15);
      l_owner_id             NUMBER(15);
      l_creation_orgn_code   VARCHAR2 ( 4 );
      l_owner_orgn_code      VARCHAR2 ( 4 );
      l_msg_data             VARCHAR2 ( 240 );
      l_msg_count            NUMBER;
      l_return_status        VARCHAR2 ( 1 );
      l_return_code          NUMBER;
      error_msg              VARCHAR2 ( 240 );
   BEGIN
      /*  Define Savepoint */
      SAVEPOINT recipe_migration;

      /* Irrespective of the whether recipes are named based on formulas
         or items, the number of recipes created should remain the same.
         However, the number of recipe_no's might be different
         in the two cases
      */

      /* Step 1 : To migrate data into the Recipe Header table  */
      IF ( UPPER ( p_recipe_no_choice ) = 'FORMULA' )
      THEN
         FOR formula_rec IN formula_cur
         LOOP
            BEGIN
               /* intialize the return status */
               x_return_status            := 'S';

               /* Compare the new recipe_no with the previous record */
               /* If it is a new one, the recipe version is 1 */
               /* else the recipe version is incremented by 1 */

               /* Since the cursor is grouped and ordered by formula no and version */
               /* the recipe no and version assignments would work fine. */
               /* Thomas - Bug 2562007, Removed the TRIM condition to migrate the formulae */
               /* as they were defined */
               IF ( ( l_recipe_no ) <> ( formula_rec.formula_no ))
               THEN
                  l_recipe_no       :=  formula_rec.formula_no;
                  l_recipe_version  := 1;
               ELSE
                  l_recipe_no       := formula_rec.formula_no;
                  l_recipe_version  := l_recipe_version + 1;
               END IF;


               /* ================================ */
               /* Based on Recipe_no and Recipe_version check if a recipe */
               /* already exists in the database */
               /* ================================= */
               gmd_recipe_val.recipe_name (
                   p_api_version                => 1.0,
                  p_init_msg_list               => fnd_api.g_false,
                  p_commit                      => fnd_api.g_false,
                  p_recipe_no                   => l_recipe_no,
                  p_recipe_version              => l_recipe_version,
                  x_return_status               => l_return_status,
                  x_msg_count                   => l_msg_count,
                  x_msg_data                    => l_msg_data,
                  x_return_code                 => l_return_code,
                  x_recipe_id                   => l_recipe_id );

               IF ( l_recipe_id IS NOT NULL )
               THEN
                  x_return_status            := fnd_api.g_ret_sts_error;
                  /* Thomas - Bug 2562007, Added the following loggin of message */
                  insert_message (p_source_table => 'FM_FORM_MST'
                                 ,p_target_table => 'GMD_RECIPES'
                                 ,p_source_id    => l_recipe_no
                                 ,p_target_id    => l_recipe_version
                                 ,p_message      => 'Recipe:'||l_recipe_no||' Version:'||l_recipe_version||' already exists.'
                                 ,p_error_type   => 'U');
               END IF;

               IF ( x_return_status = 'S' )
               THEN

                 /* Get the recipe id from the sequence */
                 SELECT gmd_recipe_id_s.NEXTVAL
                   INTO l_recipe_id
                   FROM sys.DUAL;
                 /* function gmdfmval_pub.locked_effectivity_val gets the recipe status */
                 /* This function return non zero value when the effectivity is locked */

                 l_return_val := gmdfmval_pub.locked_effectivity_val (
                                                      formula_rec.formula_id );

                 IF ( l_return_val <> 0 )
                 THEN
                    l_recipe_status            := '900';
                 ELSE
                    l_recipe_status            := '700';
                 END IF;

                 /* Derive the delete mark and WHO column values */
                 /* Bug 3503706 - Created separate SQL statements
                    to derive delete mark and Who columns
                 */
                 SELECT Min(delete_mark)
                   INTO l_delete_mark
                   FROM fm_form_eff_bak
                  WHERE formula_id = formula_rec.formula_id
                    AND NVL ( routing_id, -999 ) =
                                           NVL ( formula_rec.routing_id, -999 );

                 SELECT creation_date,
                        created_by,
                        last_updated_by,
                        last_update_date,
                        last_update_login,
                        created_by
                   INTO l_creation_date,
                        l_created_by,
                        l_last_updated_by,
                        l_last_update_date,
                        l_last_update_login,
                        l_owner_id
                   FROM fm_form_eff_bak
                  WHERE formula_id = formula_rec.formula_id
                    AND NVL ( routing_id, -999 ) =
                                           NVL ( formula_rec.routing_id, -999 )
                    AND ROWNUM = 1;

                 /* Define the creation and owner orgn values from profile values */

                 l_creation_orgn_code  :=
                     TRIM (fnd_profile.value_specific ('GEMMS_DEFAULT_ORGN' ,
                                                                l_created_by ));
                 l_owner_orgn_code :=
                     TRIM (fnd_profile.value_specific ('GEMMS_DEFAULT_ORGN' ,
                                                                  l_owner_id ));

                 INSERT INTO gmd_recipes_b (recipe_id, recipe_no, recipe_version, owner_orgn_code, creation_orgn_code,
                                            formula_id, routing_id, recipe_status, calculate_step_quantity, owner_id,
                                            delete_mark, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
                 VALUES                    (l_recipe_id, l_recipe_no, l_recipe_version, l_owner_orgn_code, l_creation_orgn_code,
                                            formula_rec.formula_id, formula_rec.routing_id, l_recipe_status, 0, l_owner_id,
                                            l_delete_mark, l_creation_date, l_created_by, l_last_update_date, l_last_updated_by, l_last_update_login);

                 INSERT INTO gmd_recipes_tl (recipe_id, recipe_description, source_lang, created_by, creation_date,
                                             last_updated_by, last_update_date, last_update_login, language
                                            )
                 SELECT l_recipe_id, formula_rec.formula_desc1, userenv('lang'), l_created_by, l_creation_date,
                        l_last_updated_by, l_last_update_date, l_last_update_login, l.language_code
                 FROM fnd_languages l
                 WHERE l.installed_flag in ('I', 'B')
                 AND NOT EXISTS (SELECT null
                                 FROM gmd_recipes_tl t
                                 WHERE t.recipe_id = l_recipe_id
                                 AND t.language = l.language_code);
               END IF;

            EXCEPTION
               WHEN OTHERS
               THEN
                  error_msg  := SQLERRM;
                  insert_message (p_source_table => 'FM_FORM_EFF'
                                 ,p_target_table => 'GMD_RECIPES'
                                 ,p_source_id    => formula_rec.formula_id
                                 ,p_target_id    => l_recipe_id
                                 ,p_message      => error_msg
                                 ,p_error_type   => 'U');
            END;        /* End prior to end loop */
         END LOOP;      /* loop completed for all distinct formula- routings */
      /* ******************* End of Formula selection ********************** */
      ELSIF ( UPPER ( p_recipe_no_choice ) = 'PRODUCT' )
      THEN
         FOR product_rec IN product_cur
         LOOP
            BEGIN
               /* initialize the return status */
               x_return_status            := 'S';

               /* Compare the new recipe_no with the previous record */
               /* If it is a new one, the recipe version is 1 */
               /* else the recipe version is inremented by 1 */

               /* Since the cursor is grouped and ordered by item no */
               IF ( TRIM ( l_recipe_no ) <> TRIM ( product_rec.item_no ))
               THEN
                  l_recipe_no       := TRIM ( product_rec.item_no );
                  l_recipe_version  := 1;
               ELSE
                  l_recipe_no       := TRIM ( product_rec.item_no );
                  l_recipe_version  :=   l_recipe_version + 1;
               END IF;


               /* ================================ */
               /* Based on Recipe_no and Recipe_version check if a recipe */
               /* already exists in the database */
               /* ================================= */
               gmd_recipe_val.recipe_name (
                   p_api_version                => 1.0,
                  p_init_msg_list               => fnd_api.g_false,
                  p_commit                      => fnd_api.g_false,
                  p_recipe_no                   => l_recipe_no,
                  p_recipe_version              => l_recipe_version,
                  x_return_status               => l_return_status,
                  x_msg_count                   => l_msg_count,
                  x_msg_data                    => l_msg_data,
                  x_return_code                 => l_return_code,
                  x_recipe_id                   => l_recipe_id );

               IF ( l_recipe_id IS NOT NULL )
               THEN
                  x_return_status            := fnd_api.g_ret_sts_error;
               END IF;

               /* Get the recipe id from sequence */

               SELECT gmd_recipe_id_s.NEXTVAL
                 INTO l_recipe_id
                 FROM sys.DUAL;
               /* function gmdfmval_pub.locked_effectivity_val gets the recipe status */
               /* This function return non zero value when the effectivity is locked */

               l_return_val  :=  gmdfmval_pub.locked_effectivity_val (
                                                       product_rec.formula_id );

               IF ( l_return_val <> 0 )
               THEN
                  l_recipe_status            := '900';
               ELSE
                  l_recipe_status            := '700';
               END IF;

               /* get the delete mark and WHO columns */
                 /* Bug 3503706 - Created separate SQL statements
                    to derive delete mark and Who columns
                 */
                 SELECT Min(delete_mark)
                   INTO l_delete_mark
                   FROM fm_form_eff_bak
                  WHERE formula_id = product_rec.formula_id
                    AND NVL ( routing_id, -999 ) =
                                           NVL ( product_rec.routing_id, -999 );

                 SELECT creation_date,
                        created_by,
                        last_updated_by,
                        last_update_date,
                        last_update_login,
                        created_by
                   INTO l_creation_date,
                        l_created_by,
                        l_last_updated_by,
                        l_last_update_date,
                        l_last_update_login,
                        l_owner_id
                   FROM fm_form_eff_bak
                  WHERE formula_id = product_rec.formula_id
                    AND NVL ( routing_id, -999 ) =
                                           NVL ( product_rec.routing_id, -999 )
                    AND ROWNUM = 1;

               /* Define the creation and owner orgn values from profile values */

               l_creation_orgn_code       :=
                     TRIM (fnd_profile.value_specific ('GEMMS_DEFAULT_ORGN' ,
                                                                l_created_by ));
               l_owner_orgn_code          :=
                     TRIM (fnd_profile.value_specific ( 'GEMMS_DEFAULT_ORGN' ,
                                                                  l_owner_id ));

               /* Insert into the recipe header table */
               IF ( x_return_status = 'S' )
               THEN
                 INSERT INTO gmd_recipes_b (recipe_id, recipe_no, recipe_version, owner_orgn_code, creation_orgn_code,
                                            formula_id, routing_id, recipe_status, calculate_step_quantity, owner_id,
                                            delete_mark, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
                 VALUES                    (l_recipe_id, l_recipe_no, l_recipe_version, l_owner_orgn_code, l_creation_orgn_code,
                                            product_rec.formula_id, product_rec.routing_id, l_recipe_status, 0, l_owner_id,
                                            l_delete_mark, l_creation_date, l_created_by, l_last_update_date, l_last_updated_by, l_last_update_login);

                 INSERT INTO gmd_recipes_tl (recipe_id, recipe_description, source_lang, created_by, creation_date,
                                             last_updated_by, last_update_date, last_update_login, language
                                            )
                 SELECT l_recipe_id, product_rec.item_desc1, userenv('lang'), l_created_by, l_creation_date,
                        l_last_updated_by, l_last_update_date, l_last_update_login, l.language_code
                 FROM fnd_languages l
                 WHERE l.installed_flag in ('I', 'B')
                 AND NOT EXISTS (SELECT null
                                 FROM gmd_recipes_tl t
                                 WHERE t.recipe_id = l_recipe_id
                                 AND t.language = l.language_code);

               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  error_msg  := SQLERRM;
                  insert_message (p_source_table => 'FM_FORM_EFF'
                                 ,p_target_table => 'GMD_RECIPES'
                                 ,p_source_id    => product_rec.item_no
                                 ,p_target_id    => l_recipe_id
                                 ,p_message      => error_msg
                                 ,p_error_type   => 'U');

            END;   /* End prior to end loop */
         END LOOP;
      /* ******************* End of item - recipe selection ********************** */
      END IF;

      /* *******************Step Common to either selection **************** */

      /* Step 2: Create an association table */
      /* Loop thro every fmeff_id in the fm_form_eff table */
      /* Based on the formula and routing id we could derive the recipe_id from recipe_header. */

      /* We need to use an association table GMD_RECIPE_EFF_ASSOC that relates fmeff_id  */
      /* to the recipe_id and validity rule id */

      INSERT INTO gmd_recipe_eff_assoc
                  (  fmeff_id,
                    recipe_id,
                    orgn_code,
                    item_id,
                    formula_use,
                    end_date,
                    start_date,
                    inv_min_qty,
                    inv_max_qty,
                    min_qty,
                    max_qty,
                    std_qty,
                    item_um,
                    preference,
                    routing_id,
                    formula_id,
                    cust_id,
                    creation_date,
                    last_update_date,
                    created_by,
                    last_updated_by,
                    delete_mark,
                    text_code,
                    trans_cnt,
                    last_update_login,
                    recipe_validity_rule_id )
         SELECT eff.fmeff_id fmeff_id,
                rec.recipe_id,
                eff.orgn_code,
                eff.item_id,
                eff.formula_use,
                eff.end_date,
                eff.start_date,
                eff.inv_min_qty,
                eff.inv_max_qty,
                eff.min_qty,
                eff.max_qty,
                eff.std_qty,
                eff.item_um,
                eff.preference,
                eff.routing_id,
                eff.formula_id,
                eff.cust_id,
                eff.creation_date,
                eff.last_update_date,
                eff.created_by,
                eff.last_updated_by,
                eff.delete_mark,
                eff.text_code,
                eff.trans_cnt,
                eff.last_update_login,
                eff.fmeff_id vr_id
           FROM fm_form_eff_bak eff,
                gmd_recipes_b rec
          WHERE NOT EXISTS ( SELECT 1
                               FROM gmd_recipe_eff_assoc
                              WHERE fmeff_id = eff.fmeff_id )
            AND rec.formula_id = eff.formula_id
            AND NVL ( rec.routing_id, -111 ) = NVL ( eff.routing_id, -111 );

      /* Step 3 */
      /* Migrate data into the GMD_RECIPE_CUSTOMERS table */
      FOR recipe_cust_rec IN (SELECT   a.recipe_id,
                                       a.cust_id,
                                       a.created_by,
                                       a.creation_date,
                                       a.last_updated_by,
                                       a.last_update_login,
                                       a.text_code,
                                       a.last_update_date
                                  FROM gmd_recipe_eff_assoc a
                                 WHERE NOT EXISTS ( SELECT 1
                                                      FROM gmd_recipe_customers
                                                     WHERE recipe_id = a.recipe_id
                                                       AND customer_id = a.cust_id )
                                   AND cust_id IS NOT NULL
                              GROUP BY a.cust_id,
                                       a.recipe_id,
                                       a.created_by,
                                       a.creation_date,
                                       a.last_updated_by,
                                       a.last_update_login,
                                       a.text_code,
                                       a.last_update_date ) LOOP

           OPEN  check_recipe_cust_exists(recipe_cust_rec.recipe_id,
                                          recipe_cust_rec.cust_id);
           FETCH check_recipe_cust_exists INTO  l_dummy_id;
             IF (check_recipe_cust_exists%NOTFOUND) THEN
                 INSERT INTO gmd_recipe_customers
                             (  recipe_id,
                               customer_id,
                               created_by,
                               creation_date,
                               last_updated_by,
                               last_update_login,
                               text_code,
                               last_update_date )
                       VALUES ( recipe_cust_rec.recipe_id,
                               recipe_cust_rec.cust_id,
                               recipe_cust_rec.created_by,
                               recipe_cust_rec.creation_date,
                               recipe_cust_rec.last_updated_by,
                               recipe_cust_rec.last_update_login,
                               recipe_cust_rec.text_code,
                               recipe_cust_rec.last_update_date );
              END IF;
            CLOSE check_recipe_cust_exists;
      END LOOP; /* for recipe customers */

      /* Step 4 :  */
      /* Migrate data into gmd_recipe_validity_rules table */
      /* All effectvities are inserted into the validity rules table */

      INSERT INTO gmd_recipe_validity_rules
                  (  recipe_validity_rule_id,
                    recipe_id,
                    orgn_code,
                    item_id,
                    recipe_use,
                    preference,
                    start_date,
                    end_date,
                    min_qty,
                    max_qty,
                    std_qty,
                    item_um,
                    inv_min_qty,
                    inv_max_qty,
                    text_code,
                    created_by,
                    creation_date,
                    last_updated_by,
                    last_update_date,
                    last_update_login,
                    delete_mark,
                    validity_rule_status )
         SELECT fmeff_id,
                recipe_id,
                orgn_code,
                item_id,
                formula_use,
                preference,
                start_date,
                end_date,
                min_qty,
                max_qty,
                std_qty,
                item_um,
                inv_min_qty,
                inv_max_qty,
                text_code,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login,
                delete_mark,
                gmdfmval_pub.gmd_effectivity_locked_status ( fmeff_id )
           FROM gmd_recipe_eff_assoc
          WHERE NOT EXISTS ( SELECT 1
                               FROM gmd_recipe_validity_rules
                              WHERE recipe_validity_rule_id = fmeff_id );

      /* Step 5 */
      /* Migrate data into the Recipe Materials Step table from
         fm_rout_mtl_bak table    */
      FOR recipe_material_rec IN recipe_material_cur
      LOOP
         BEGIN
            IF ( recipe_material_rec.routing_id IS NOT NULL )
            THEN
               SELECT recipe_id
                 INTO l_recipe_id
                 FROM gmd_recipes_b
                WHERE formula_id = recipe_material_rec.formula_id
                  AND routing_id = recipe_material_rec.routing_id
                  AND ROWNUM = 1;
            ELSE
               SELECT DISTINCT recipe_id
                 INTO l_recipe_id
                 FROM gmd_recipes_b
                WHERE formula_id = recipe_material_rec.formula_id
                  AND routing_id IS NULL
                  AND ROWNUM = 1;
            END IF;

            /* Important based on the routingstep_no and routing_id get the  */
            /* routingstep_id */

            SELECT routingstep_id
              INTO l_routingstep_id
              FROM fm_rout_dtl
             WHERE routing_id = recipe_material_rec.routing_id
               AND routingstep_no = recipe_material_rec.routingstep_no
               AND ROWNUM = 1;

            /* Check for unique constraints on this table */
            OPEN  check_step_mat_exists(l_recipe_id,
                                        recipe_material_rec.formulaline_id);
            FETCH check_step_mat_exists INTO  l_dummy_id;
              IF (check_step_mat_exists%NOTFOUND) THEN
                 INSERT INTO gmd_recipe_step_materials
                             (  recipe_id,
                               routingstep_id,
                               formulaline_id,
                               creation_date,
                               created_by,
                               last_updated_by,
                               last_update_date,
                               last_update_login )
                      VALUES (  l_recipe_id,
                               l_routingstep_id,
                               recipe_material_rec.formulaline_id,
                               recipe_material_rec.creation_date,
                               recipe_material_rec.created_by,
                               recipe_material_rec.last_updated_by,
                               recipe_material_rec.last_update_date,
                               recipe_material_rec.last_update_login );

              END IF;
            CLOSE check_step_mat_exists;

         EXCEPTION
            WHEN OTHERS
            THEN
               error_msg := SQLERRM;
               insert_message (p_source_table => 'FM_ROUT_MTL'
                              ,p_target_table => 'GMD_RECIPE_STEP_MATERIALS'
                              ,p_source_id    => recipe_material_rec.formulaline_id
                              ,p_target_id    => recipe_material_rec.formulaline_id
                              ,p_message      => error_msg
                              ,p_error_type   => 'U');
         END;                                       /* End prior to end loop */
      END LOOP;

      /* Step 6:  Obsolete VRs and recipes that are based on Obsolted formulas
         During formula migartion we had obsoleted formulas whose items
         are inactive. Recipes and VRs that use this formula are also obsoleted */
      UPDATE gmd_recipes_b
      SET    recipe_status = '1000'
      WHERE  formula_id IN (SELECT formula_id
                            FROM   fm_form_mst_b
                            WHERE  formula_Status = '1000');

      /* Obsolete Vrs that are based on obsoleted Recipes */
      UPDATE gmd_recipe_validity_rules
      SET    validity_rule_status = '1000'
      WHERE  recipe_id IN (SELECT  recipe_id
                            FROM   gmd_recipes_b
                            WHERE  recipe_Status = '1000');

      /* Step 7: Update all tables that use fmeff_id - with VR id */
      /* Validate duplicate effectivity customers */
      FOR get_dup_eff_rec IN get_dup_cust_eff
      LOOP  /* All dup effectivity groups - loop eff 1*/
        /* Get the duplicate effectivity ids for diffent customers */

         /* initialize the dup effectivity counter */
        l_dup_counter := 0;
       /* changed fm_form_eff to _bak as it was deleting new recipes */
        FOR update_eff_rec IN
                            (SELECT fmeff_id
                               FROM fm_form_eff_bak
                              WHERE NVL(orgn_code,fnd_api.g_miss_char) =
                                       NVL(get_dup_eff_rec.orgn_code,
                                                           fnd_api.g_miss_char )
                                AND item_id = get_dup_eff_rec.item_id
                                AND formula_use = get_dup_eff_rec.formula_use
                                /* Thomas - Bug 2562007, Added NVL condition as end date could be null */
                                AND NVL(end_date, fnd_api.g_miss_date) = NVL(get_dup_eff_rec.end_date, fnd_api.g_miss_date)
                                AND start_date = get_dup_eff_rec.start_date
                                AND min_qty = get_dup_eff_rec.min_qty
                                AND max_qty = get_dup_eff_rec.max_qty
                                AND std_qty = get_dup_eff_rec.std_qty
                                AND item_um = get_dup_eff_rec.item_um
                                AND preference = get_dup_eff_rec.preference
                                AND NVL ( routing_id, fnd_api.g_miss_num ) =
                                       NVL (get_dup_eff_rec.routing_id,
                                                            fnd_api.g_miss_num )
                                AND formula_id = get_dup_eff_rec.formula_id
                                /* Thomas - Bug 2562007, Commented out the following checking */
                                /* and added the order by clause */
                                -- AND delete_mark = get_dup_eff_rec.delete_mark
                                -- AND cust_id IS NOT NULL
                                ORDER BY delete_mark, cust_id desc, fmeff_id)

         LOOP  /* dupplicate effectivities for a given group - loop eff 2 */
           IF (l_dup_counter = 0) THEN
              l_fmeff_id := update_eff_rec.fmeff_id;
           END IF;
           /* Skip the first row */
           /* for e.g if the select i.e loop eff 2 above returns fmeff_id
              101, 102 and 103 as duplicate ids we want delete 102 and 103
              from the VR table so we skip the 1st row that returns 101*/
           /* Thomas - Bug 2562007, Changed the l_dup_counter from > 1 to > 0 */
           IF (l_dup_counter > 0) THEN
               BEGIN
                 UPDATE pm_btch_hdr
                    SET fmeff_id = l_fmeff_id
                  WHERE fmeff_id = update_eff_rec.fmeff_id;

                 UPDATE gl_item_cst
                    SET fmeff_id = l_fmeff_id
                  WHERE fmeff_id = update_eff_rec.fmeff_id;

                 UPDATE gmp_form_eff
                    SET fmeff_id = l_fmeff_id
                  WHERE fmeff_id = update_eff_rec.fmeff_id;

                 /* Since table cm_cmpt_dtl could have many fmeff_ids
                    row to be updated the system might run out of rollback segment
                    space - to prevent this we provide regular interval commits */
                 SELECT NVL ( COUNT (* ), 0 )
                   INTO l_cm_counter
                   FROM cm_cmpt_dtl
                  WHERE fmeff_id = update_eff_rec.fmeff_id;

                 FOR k IN cm_cmpt_dtl_cur ( update_eff_rec.fmeff_id )
                 LOOP
                    UPDATE cm_cmpt_dtl
                       SET fmeff_id = l_fmeff_id
                     WHERE fmeff_id = update_eff_rec.fmeff_id
                       AND ROWNUM < 51;
                    COMMIT;
                    SAVEPOINT recipe_migration;
                    IF ( cm_cmpt_dtl_cur%ROWCOUNT > l_cm_counter/50 )
                    THEN
                       l_cm_counter  := 0;
                       EXIT;
                    END IF;
                 END LOOP;
                 /* Increment the counter */
                 l_counter   :=   l_counter + 1;
                 IF ( l_counter > 5 )
                 THEN
                    COMMIT;
                    SAVEPOINT recipe_migration;
                    l_counter := 0;
                 END IF;

                 /* Delete duplicate VR id from gmd_recipe_validity_rule table */
                 DELETE
                 FROM   gmd_recipe_validity_rules
                 WHERE  recipe_validity_rule_id = update_eff_rec.fmeff_id;

                 insert_message (p_source_table => 'FM_FORM_EFF'
                                ,p_target_table => 'GMD_RECIPE_VALIDITY_RULES'
                                ,p_source_id    => update_eff_rec.fmeff_id
                                ,p_target_id    => l_fmeff_id
                                ,p_message      => 'Deleted effectivity:'||update_eff_rec.fmeff_id||' Updated with effectivity:'||l_fmeff_id
                                ,p_error_type   => 'E');
               EXCEPTION
                 WHEN OTHERS
                 THEN
                    error_msg := SQLERRM;
                    insert_message (p_source_table => 'GMD_RECIPE_EFF_ASSOC'
                                   ,p_target_table => 'PM_BTCH_HDR - CM_CMPT_DTL - GL_ITEM_CST - GMP_FORM_EFF'
                                   ,p_source_id    => l_fmeff_id
                                   ,p_target_id    => update_eff_rec.fmeff_id
                                   ,p_message      => error_msg
                                   ,p_error_type   => 'U');
               END;    /* End prior to end loop */
           END IF; /* l_dup_counter > 1 */

           /* increment this counter */
           l_dup_counter := l_dup_counter + 1;

         END LOOP; /* End loop for duplicate eff 2 */
      END LOOP; /* End loop for duplicate eff 1 */
   EXCEPTION
      WHEN OTHERS
      THEN
        ROLLBACK TO recipe_migration;
        error_msg := SQLERRM;
        insert_message (p_source_table => 'Old GMD tables'
                       ,p_target_table => 'New GMD tables'
                       ,p_source_id    => 'Unknown'
                       ,p_target_id    => 'Unknown'
                       ,p_message      => error_msg
                       ,p_error_type   => 'U');
         x_return_status  := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
             p_count                      => x_msg_count,
            p_data                        => x_msg_data );
   END migrate_recipe;

   PROCEDURE insert_message (
      p_source_table       IN   VARCHAR2,
      p_target_table       IN   VARCHAR2,
      p_source_id          IN   VARCHAR2,
      p_target_id	   IN	VARCHAR2,
      p_message            IN   VARCHAR2,
      p_error_type         IN   VARCHAR2
   ) IS
      PRAGMA autonomous_transaction;
   BEGIN
     INSERT INTO gmd_migration
     (  migration_id,
        source_table,
        target_table,
        source_id,
        target_id,
        message_text )
      SELECT gmd_request_id_s.NEXTVAL,
        p_source_table,
        p_target_table,
        p_source_id,
        p_target_id,
        p_message
     FROM DUAL;
     COMMIT;
   END insert_message;

   PROCEDURE qty_update_fxd_scaling IS
   CURSOR fixed_scaling IS
      SELECT grv.item_id, fmd.qty,fmd.item_um base_um, grv.std_qty, grv.item_um conv_um,
             recipe_validity_rule_id rule_id, grv.min_qty, grv.max_qty
        FROM fm_form_mst_b ffm,
             fm_matl_dtl fmd,
             gmd_recipes_b gr,
             gmd_recipe_validity_rules grv
       WHERE ffm.formula_id = fmd.formula_id
         AND ffm.formula_id = gr.formula_id
         AND grv.orgn_code = ffm.orgn_code
         AND grv.recipe_id = gr.recipe_id
         AND fmd.scale_type = 0
         AND fmd.line_type = 1
         AND (   grv.max_qty <> fmd.qty
              OR grv.min_qty <> fmd.qty
              OR grv.std_qty <> fmd.qty
             )
         AND grv.item_id = fmd.item_id;
        x_out_qty   NUMBER;
   BEGIN
      FOR x_rec IN fixed_scaling LOOP
        /* Update only those records whose quantities are incorrect, depending upon the UOM's */
         IF x_rec.base_um = x_rec.conv_um THEN
           UPDATE gmd_recipe_validity_rules
            SET max_qty = x_rec.qty,
                min_qty = x_rec.qty,
                std_qty = x_rec.qty
           WHERE recipe_validity_rule_id = x_rec.rule_id;
         ELSE
         /*Calling the UOM conversation package, if the prduct UOM then the effectivitity UOM */
         /*gmicuom.icuomcv(p_item_id,p_lot_id,P_min_qty,P_item_um,P_inv_item_um,X_inv_min_qty)*/
           gmicuom.icuomcv (
              x_rec.item_id,
              0,
              x_rec.qty,
              x_rec.base_um,
              x_rec.conv_um,
              x_out_qty
            );

           IF (   x_rec.min_qty <> x_out_qty
             OR x_rec.max_qty <> x_out_qty
             OR x_rec.std_qty <> x_out_qty
            ) THEN
            UPDATE gmd_recipe_validity_rules
               SET max_qty = x_out_qty,
                   min_qty = x_out_qty,
                   std_qty = x_out_qty
             WHERE recipe_validity_rule_id = x_rec.rule_id;
           END IF;
        END IF;
     END LOOP;
   END qty_update_fxd_scaling;


END gmd_recipe_migration;

/
