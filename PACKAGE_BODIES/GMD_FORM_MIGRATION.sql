--------------------------------------------------------
--  DDL for Package Body GMD_FORM_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_FORM_MIGRATION" AS
/* $Header: GMDFMIGB.pls 120.1 2005/08/12 06:18:41 txdaniel noship $  pxkumar*/

  PROCEDURE  Insert_form_status
   IS
    /* Need to migrate data from fm_form_mst to fm_form_mst_vl */
    CURSOR formula_cur_vl IS
      SELECT  * from fm_form_mst m1
      WHERE  EXISTS ( Select 1
                        from fm_form_mst
                       Where formula_no = m1.formula_no AND
                             formula_vers = m1.formula_vers AND
                             formula_status IS NULL);

    /* BUG # 2562689 - Cursor that gets all formulas that have
       inactive items */
    CURSOR get_inactive_item_formula IS
      SELECT   distinct d.formula_id
      FROM     ic_item_mst i, fm_matl_dtl d
      WHERE    i.item_id = d.item_id
      AND      i.delete_mark = 1
      GROUP BY d.formula_id;

    l_formula_id          NUMBER;
    l_orgn_code           VARCHAR2(6);
    l_formula_status      GMD_STATUS.status_code%type;
    formula_rowid         VARCHAR2(32);
    l_total_output_qty    NUMBER;
    l_total_input_qty     NUMBER;
    l_uom                 VARCHAR2(4);
    l_return_val          NUMBER;
    l_return_status       varchar2(1);
    l_msg_data            varchar2(240);
    l_msg_count           NUMBER;
    error_msg             varchar2(240);
    /* TKW 6/25/2002 B2428431 */
    l_fm_desc             fm_form_mst.formula_desc1%TYPE;

    l_inactive_ind        NUMBER;

    TOTAL_OUTPUT_NOT_CALC EXCEPTION ;

  BEGIN

   /* Update the apps.fm_form_mst  with appropriate status and qty values */
   FOR formula_rec IN formula_cur_vl LOOP
     BEGIN
     /* get the qty and uoms */
     GMD_COMMON_VAL.CALCULATE_TOTAL_QTY (
         formula_id       => formula_rec.formula_id ,
         x_product_qty    => l_total_output_qty     ,
         x_ingredient_qty => l_total_input_qty      ,
         x_uom            => l_uom                  ,
         x_msg_count      => l_msg_count            ,
         x_msg_data       => l_msg_data             ,
         x_return_status  => l_return_status);

     /* function to get formula status */
     l_return_val := GMDFMVAL_PUB.locked_effectivity_val(formula_rec.formula_id);
     IF (l_return_val <> 0) THEN
        l_formula_status := '900';
     ELSE
        l_formula_status := '700';
     END IF;

     /* If this formula is marked for purge or incative set the status to obsolete */
     l_inactive_ind   := formula_rec.inactive_ind;

     /* bug 2912872 Seting the inactive formulas to active*/
     IF (formula_rec.inactive_ind = 1) THEN
        l_formula_status := '1000';
        l_inactive_ind   := 0;
     END IF;

     IF (formula_rec.delete_mark = 1) THEN
        l_formula_status := '1000';
     END IF;

     /* TKW 6/25/2002 B2428431 Concatenate formula number and version if formula desc is null */
     IF (formula_rec.FORMULA_DESC1 is null) THEN
        l_fm_desc := formula_rec.formula_no || ' ' || formula_rec.formula_vers;
     ELSE
        l_fm_desc := formula_rec.formula_desc1;
     END IF;

     /* Define the creation and owner orgn values */
     l_orgn_code :=  fnd_profile.value_specific('GEMMS_DEFAULT_ORGN',formula_rec.created_by);

     /* Call the formula update MLS API*/
     UPDATE fm_form_mst_b
     SET    orgn_code          = l_orgn_code,
            total_output_qty   = l_total_output_qty,
            total_input_qty    = l_total_input_qty,
            formula_uom        = l_uom,
            formula_status     = l_formula_status,
            owner_id           = formula_rec.created_by,
            inactive_ind       = l_inactive_ind
     WHERE  formula_id = formula_rec.formula_id;

     IF formula_rec.FORMULA_DESC1 IS NULL THEN
       UPDATE fm_form_mst_tl
       SET    formula_desc1 = l_fm_desc
       WHERE  formula_id = formula_rec.formula_id
       AND    userenv('LANG') IN (language, source_lang);
     END IF;
   EXCEPTION
     WHEN TOTAL_OUTPUT_NOT_CALC THEN
       error_msg := 'The Total Output Quantity for this formula cannot be calculated';
       GMD_RECIPE_MIGRATION.insert_message (p_source_table => 'FM_FORM_MST'
                                   ,p_target_table => 'FM_FORM_MST'
                                   ,p_source_id    => formula_rec.formula_id
                                   ,p_target_id    => formula_rec.formula_id
                                   ,p_message      => error_msg
                                   ,p_error_type   => 'E');
     WHEN OTHERS THEN
       error_msg := SQLERRM;
       GMD_RECIPE_MIGRATION.insert_message (p_source_table => 'FM_FORM_MST'
                                   ,p_target_table => 'FM_FORM_MST'
                                   ,p_source_id    => formula_rec.formula_id
                                   ,p_target_id    => formula_rec.formula_id
                                   ,p_message      => error_msg
                                   ,p_error_type   => 'U');
   END; /* End prior to end loop */
   END LOOP;

   /* Bug # 2562689 - Obsolete all formulas whose item are inactive */
   FOR get_inactive_form_rec IN get_inactive_item_formula LOOP
       UPDATE fm_form_mst_b
       SET    formula_status = '1000'
       WHERE  formula_id = get_inactive_form_rec.formula_id;
   END LOOP;

  END Insert_form_status ;

  PROCEDURE  MIGRATE_FORMULA_DETAIL IS
    error_msg VARCHAR2(240);
  BEGIN
    /*Bug  2980227 - Thomas Daniel */
    /*Fixed the following code for not resetting the values for customers who are upgrading */
    /*Introduced the NVL statements to update the defaults only if they were not filled in earlier */
    -- FOR my_rec IN (select * from fm_matl_dtl) LOOP

    BEGIN
        UPDATE  fm_matl_dtl
        SET     contribute_step_qty_ind = NVL(contribute_step_qty_ind, 'Y'),
                scale_multiple  = NVL(scale_multiple, 0),
                scale_rounding_variance = NVL(scale_rounding_variance, 0),
                contribute_yield_ind = NVL(contribute_yield_ind, 'Y');

        /*The customers who are migrating from FP prior to G would have only scale types as */
        /*0 or 1 so the decode is not required for setting the contribute to yield ind */
        -- = decode(my_rec.scale_type,0,'Y',1,'Y',2,'N',3,'N')
        -- where   formulaline_id = my_rec.formulaline_id;

    EXCEPTION
        WHEN OTHERS THEN
          error_msg := SQLERRM;
          GMD_RECIPE_MIGRATION.insert_message (p_source_table => 'FM_MATL_DTL'
                                   ,p_target_table => 'FM_MATL_DTL'
                                   ,p_source_id    => NULL
                                   ,p_target_id    => NULL
                                   ,p_message      => error_msg
                                   ,p_error_type   => 'U');
    END;
    -- END LOOP;
  END MIGRATE_FORMULA_DETAIL;

END GMD_FORM_MIGRATION;

/
