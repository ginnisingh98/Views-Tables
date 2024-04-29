--------------------------------------------------------
--  DDL for Package Body GMD_LM_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_LM_MIGRATION" AS
/* $Header: GMDLMMGB.pls 120.3 2005/10/05 08:49:43 txdaniel noship $ */

  P_run_id   NUMBER;
  P_line_no  NUMBER DEFAULT 0;

/* ***************************************************************
 * PROCEDURE generate_tech_parm_id
 *
 * Synopsis    : generate_tech_parm_id
 *
 * Description : From OPM_PF K and above the technical parameters
 *               base and translation table includes a surrogate key
 *               tech_parm_id.  This surrogate needs to be populated
 *               using a sequence generator.
 *
 * History     :
 *               Shyam Sitaraman    03/10/03   Initial Implementation
 * *************************************************************** */
 PROCEDURE generate_tech_parm_id IS
   CURSOR C_get_tech_parms IS
    SELECT
      B.tech_parm_name,
      B.orgn_code
   FROM GMD_TECH_PARAMETERS_B B
   WHERE B.orgn_code IS NOT NULL
   AND   B.tech_parm_id = 0;

   l_row_id  VARCHAR2(40);
   l_tech_parm_id NUMBER;

 BEGIN

   FOR C_get_tech_parms_rec IN C_get_tech_parms LOOP
     SELECT gmd_tech_parm_id_s.nextval INTO l_tech_parm_id
     FROM   sys.dual;

     /* Create tech_parm_id for the hdr table - lm_tech_hdr */
     UPDATE gmd_tech_parameters_b
     SET    tech_parm_id   = l_tech_parm_id
     WHERE  tech_parm_name = C_get_tech_parms_rec.tech_parm_name
     AND    orgn_code      = C_get_tech_parms_rec.orgn_code;

     UPDATE gmd_tech_parameters_tl
     SET    tech_parm_id   = l_tech_parm_id
     WHERE  tech_parm_name = C_get_tech_parms_rec.tech_parm_name
     AND    orgn_code      = C_get_tech_parms_rec.orgn_code;

     /* Create tech_parm_id for the dtl table - lm_tech_dtl */
     UPDATE lm_tech_dtl
     SET    tech_parm_id   = l_tech_parm_id
     WHERE  tech_parm_name = C_get_tech_parms_rec.tech_parm_name
     AND    orgn_code      = C_get_tech_parms_rec.orgn_code;

     /* Create tech_parm_id for LM_SPRD_TEC */
     UPDATE lm_sprd_tec
     SET    tech_parm_id = l_tech_parm_id
     WHERE  tech_parm_name = C_get_tech_parms_rec.tech_parm_name
     AND    orgn_code      = C_get_tech_parms_rec.orgn_code;

     /* Create tech_parm_id for lm_sprd_prm */
     UPDATE lm_sprd_prm
     SET    tech_parm_id = l_tech_parm_id
     WHERE  tech_parm_name = C_get_tech_parms_rec.tech_parm_name
     AND    orgn_code      = C_get_tech_parms_rec.orgn_code;

   END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      P_line_no := P_line_no + 1;
      GMA_MIGRATION.gma_insert_message (p_run_id => p_run_id
                                       ,p_table_name => 'GMD_TECH_PARAMETERS'
                                       ,p_db_error => sqlerrm
                                       ,p_param1 => NULL
                                       ,p_param2 => NULL
                                       ,p_param3 => NULL
                                       ,p_param4 => NULL
                                       ,p_param5 => NULL
                                       ,p_message_token => 'GMA_MIGRATION_DB_ERROR'
                                       ,p_message_type => 'D'
                                       ,p_line_no => P_line_no
                                       ,p_position=> 1
                                       ,p_base_message=> NULL);

 END generate_tech_parm_id;

/* ***************************************************************
 * PROCEDURE populate_lm_sprd_dtl_sec_qty
 *
 * Synopsis    : populate_lm_sprd_dtl_sec_qty
 *
 * Description : Get all items from lm_sprd_dtl that has dual uom
 *               and derives the secondary qty a (i.e the qty value
 *               converted from primary to secondary uom).
 *
 *
 * History     :
 *               Shyam Sitaraman    03/10/03   Initial Implementation
 * *************************************************************** */
 PROCEDURE populate_lm_sprd_dtl_sec_qty IS
   CURSOR C_check_Item_dual_ind(vItem_id NUMBER) IS
     SELECT item_um2
     FROM   ic_item_mst_b
     Where  item_id = vItem_id
     AND    dualum_ind > 0;

   CURSOR C_get_lm_sprd_dtl IS
     SELECT *
     FROM   lm_sprd_dtl;

   l_dual_um   ic_item_mst_b.item_um2%TYPE;

 BEGIN
   FOR lm_sprd_dtl_rec IN  C_get_lm_sprd_dtl  LOOP
     OPEN  C_check_Item_dual_ind(lm_sprd_dtl_rec.Item_id);
     FETCH C_check_Item_dual_ind INTO l_dual_um;
       IF C_check_Item_dual_ind%FOUND THEN
          UPDATE lm_sprd_dtl
          SET    secondary_qty = GMICUOM.UOM_CONVERSION (lm_sprd_dtl_rec.Item_id,0,
                                                         lm_sprd_dtl_rec.qty,
                                                         lm_sprd_dtl_rec.item_um,
                                                         l_dual_um,0),
                 secondary_um  = l_dual_um
          WHERE  line_id = lm_sprd_dtl_rec.line_id
          AND    sprd_id = lm_sprd_dtl_rec.sprd_id;
       END IF;
     CLOSE C_check_Item_dual_ind;
   END LOOP;
 EXCEPTION
    WHEN OTHERS THEN
      P_line_no := P_line_no + 1;
      GMA_MIGRATION.gma_insert_message (p_run_id => p_run_id
                                       ,p_table_name => 'LM_SPRD_DTL'
                                       ,p_db_error => sqlerrm
                                       ,p_param1 => NULL
                                       ,p_param2 => NULL
                                       ,p_param3 => NULL
                                       ,p_param4 => NULL
                                       ,p_param5 => NULL
                                       ,p_message_token => 'GMA_MIGRATION_DB_ERROR'
                                       ,p_message_type => 'D'
                                       ,p_line_no => P_line_no
                                       ,p_position=> 1
                                       ,p_base_message=> NULL);
 END populate_lm_sprd_dtl_sec_qty;


/* ***************************************************************
 * PROCEDURE populate_parsed_expressions
 *
 * Synopsis    : populate_parsed_expressions
 *
 * Description : Populates the gmd_parsed_expression table with
 *               existing technical parmeters that are of non
 *               expression and expression type.
 *
 *
 * History     :
 *               Shyam Sitaraman    03/10/03   Initial Implementation
 * *************************************************************** */
 PROCEDURE populate_parsed_expressions IS

   CURSOR C_get_exp_tech_parm IS
     SELECT *
     FROM gmd_tech_parameters_b
     WHERE data_type = 4 OR data_type = 11
     ORDER by tech_parm_id;

   l_return_status  VARCHAR2(1) := 'S';
   l_msg_data	    VARCHAR2(2000);
   l_msg_index	    NUMBER(5);
   l_user_id	    NUMBER(15);
 BEGIN
  l_user_id := FND_PROFILE.VALUE('USER_ID');
   -- Insert all expressions
   FOR get_exp_rec IN C_get_exp_tech_parm LOOP
     FND_PROFILE.PUT('USER_ID', get_exp_rec.created_by);
     gmd_expression_mig_util.parse_expression (
       p_orgn_code     => get_exp_rec.orgn_code      ,
       p_tech_parm_id  => get_exp_rec.tech_parm_id   ,
       p_expression    => get_exp_rec.expression_char ,
       x_return_status => l_return_status );
     IF l_return_status <> FND_API.g_ret_sts_success THEN
        FND_MSG_PUB.GET(p_msg_index => 1,
                        p_data => l_msg_data,
                        p_encoded => 'F',
                        p_msg_index_out => l_msg_index);
        P_line_no := P_line_no + 1;
        GMA_MIGRATION.gma_insert_message (p_run_id => p_run_id
                                         ,p_table_name => 'GMD_PARSED_EXPRESSION'
                                         ,p_db_error => l_msg_data
                                         ,p_param1 => get_exp_rec.tech_parm_name
                                         ,p_param2 => get_exp_rec.orgn_code
                                         ,p_param3 => NULL
                                         ,p_param4 => NULL
                                         ,p_param5 => NULL
                                         ,p_message_token => 'GMA_MIGRATION_DB_ERROR'
                                         ,p_message_type => 'D'
                                         ,p_line_no => P_line_no
                                         ,p_position=> 1
                                         ,p_base_message=> NULL);
     END IF;
   END LOOP;
   IF l_user_id IS NOT NULL THEN
     FND_PROFILE.PUT('USER_ID', l_user_id);
   END IF;
 EXCEPTION
    WHEN OTHERS THEN
      P_line_no := P_line_no + 1;
      GMA_MIGRATION.gma_insert_message (p_run_id => p_run_id
                                       ,p_table_name => 'GMD_PARSED_EXPRESSION'
                                       ,p_db_error => sqlerrm
                                       ,p_param1 => NULL
                                       ,p_param2 => NULL
                                       ,p_param3 => NULL
                                       ,p_param4 => NULL
                                       ,p_param5 => NULL
                                       ,p_message_token => 'GMA_MIGRATION_DB_ERROR'
                                       ,p_message_type => 'D'
                                       ,p_line_no => P_line_no
                                       ,p_position=> 1
                                       ,p_base_message=> NULL);
 END populate_parsed_expressions;

/* ***************************************************************
 * PROCEDURE insert_gmd_tech_seq_hdr
 *
 * Synopsis    : insert_gmd_tech_seq_hdr(xTech_seq_id)
 *
 * Description : This function cannot be called independently. It gets
 *               called within Procedure insert_gmd_tech_seq_comps.
 *               It inserts a row in gmd_tech_sequence_hdr table  and
 *               it returns the Tech_seq_id, which is used to insert the
 *               details in gmd_tech_sequence_dtl table.
 * History     :
 *               Shyam Sitaraman    02/28/03   Initial Implementation
 * *************************************************************** */
 PROCEDURE insert_gmd_tech_seq_hdr(x_tech_seq_id OUT NOCOPY NUMBER) IS
 BEGIN
   SELECT gmd_tech_seq_id_s.nextval INTO x_tech_seq_id
   FROM   sys.dual;

   INSERT INTO gmd_technical_sequence_hdr
      ( tech_seq_id
      , orgn_code
      , item_id
      , category_id
      , delete_mark
      , text_code
      , creation_date
      , created_by
      , last_update_date
      , last_updated_by
      , last_update_login
   )  SELECT
        x_tech_seq_id
      , v_lm_prlt_asc_rec.orgn_code
      , null
      , null
      , v_lm_prlt_asc_rec.delete_mark
      , v_lm_prlt_asc_rec.text_code
      , v_lm_prlt_asc_rec.creation_date
      , v_lm_prlt_asc_rec.created_by
      , v_lm_prlt_asc_rec.last_update_date
      , v_lm_prlt_asc_rec.last_updated_by
      , v_lm_prlt_asc_rec.last_update_login
     FROM
        sys.dual
     WHERE NOT EXISTS (SELECT 1
                       FROM   gmd_technical_sequence_hdr
                       WHERE  orgn_code = v_lm_prlt_asc_rec.orgn_code);
  EXCEPTION
    WHEN OTHERS THEN
      P_line_no := P_line_no + 1;
      GMA_MIGRATION.gma_insert_message (p_run_id => p_run_id
                                       ,p_table_name => 'GMD_TECHNICAL_SEQUENCE_HDR'
                                       ,p_db_error => sqlerrm
                                       ,p_param1 => NULL
                                       ,p_param2 => NULL
                                       ,p_param3 => NULL
                                       ,p_param4 => NULL
                                       ,p_param5 => NULL
                                       ,p_message_token => 'GMA_MIGRATION_DB_ERROR'
                                       ,p_message_type => 'D'
                                       ,p_line_no => P_line_no
                                       ,p_position=> 1
                                       ,p_base_message=> NULL);
 END insert_gmd_tech_seq_hdr;

/* ***************************************************************
 * PROCEDURE insert_gmd_tech_seq_dtl
 *
 * Synopsis    : insert_gmd_tech_seq_dtl(10,'DENSITY',1);
 *
 * Description : This function cannot be called independently. It gets
 *               called within Procedure insert_gmd_tech_seq_comps.
 *               After it inserts rows in gmd_tech_sequence_dtl table.
 * History     :
 *               Shyam Sitaraman    02/28/03   Initial Implementation
 * *************************************************************** */
 PROCEDURE insert_gmd_tech_seq_dtl( vTech_seq_id     NUMBER) IS

   CURSOR C_get_tech_parm_id(vtech_parm_name VARCHAR2
                            ,vorgn_code      VARCHAR2) IS
     SELECT tech_parm_id
     FROM   gmd_tech_parameters_b
     WHERE  tech_parm_name = vtech_parm_name
     AND    orgn_code      = vorgn_code;

   l_tech_parm_id        NUMBER;
   E_Tech_parm_Not_Found EXCEPTION;
 BEGIN
   IF (vTech_seq_id IS NOT NULL) THEN
     /* Get the tech parm id */
     OPEN C_get_tech_parm_id(v_lm_prlt_asc_rec.tech_parm_name
                            ,v_lm_prlt_asc_rec.orgn_code);
     FETCH C_get_tech_parm_id INTO l_tech_parm_id;
       IF C_get_tech_parm_id%NOTFOUND THEN
         RAISE E_Tech_parm_Not_Found;
       END IF;
     CLOSE C_get_tech_parm_id;

     INSERT INTO gmd_technical_sequence_dtl
        ( tech_seq_id
        , tech_parm_id
        , sort_seq
        , text_code
        , creation_date
        , created_by
        , last_update_date
        , last_updated_by
        , last_update_login )
     SELECT
          vTech_seq_id
        , l_tech_parm_id
        , v_lm_prlt_asc_rec.sort_seq
        , v_lm_prlt_asc_rec.text_code
        , v_lm_prlt_asc_rec.creation_date
        , v_lm_prlt_asc_rec.created_by
        , v_lm_prlt_asc_rec.last_update_date
        , v_lm_prlt_asc_rec.last_updated_by
        , v_lm_prlt_asc_rec.last_update_login
     FROM sys.dual
     WHERE NOT EXISTS
       (SELECT 1 FROM gmd_technical_sequence_dtl
        WHERE  tech_parm_id = l_tech_parm_id
        AND    tech_seq_id  = vTech_seq_id);
   END IF;

  EXCEPTION
    WHEN E_Tech_parm_Not_Found THEN
      P_line_no := P_line_no + 1;
      GMA_MIGRATION.gma_insert_message (p_run_id => p_run_id
                                       ,p_table_name => 'GMD_TECHNICAL_SEQUENCE_DTL'
                                       ,p_db_error => sqlerrm
                                       ,p_param1 => v_lm_prlt_asc_rec.tech_parm_name
                                       ,p_param2 => v_lm_prlt_asc_rec.orgn_code
                                       ,p_param3 => NULL
                                       ,p_param4 => NULL
                                       ,p_param5 => NULL
                                       ,p_message_token => 'GMD_TECH_PARM_NOTFOUND'
                                       ,p_message_type => 'D'
                                       ,p_line_no => P_line_no
                                       ,p_position=> 1
                                       ,p_base_message=> NULL);

    WHEN OTHERS THEN
      P_line_no := P_line_no + 1;
      GMA_MIGRATION.gma_insert_message (p_run_id => p_run_id
                                       ,p_table_name => 'GMD_TECHNICAL_SEQUENCE_DTL'
                                       ,p_db_error => sqlerrm
                                       ,p_param1 => NULL
                                       ,p_param2 => NULL
                                       ,p_param3 => NULL
                                       ,p_param4 => NULL
                                       ,p_param5 => NULL
                                       ,p_message_token => 'GMA_MIGRATION_DB_ERROR'
                                       ,p_message_type => 'D'
                                       ,p_line_no => P_line_no
                                       ,p_position=> 1
                                       ,p_base_message=> NULL);
 END insert_gmd_tech_seq_dtl;

/* ***************************************************************
 * PROCEDURE insert_gmd_tech_seq_comps
 *
 * Synopsis    : insert_gmd_tech_seq_comps;
 *
 * Description : This procedure can be called independently.  Although
 *               it is recommended to call the main program (procedure)
 *               GMD_LM_MIGRATION.Run which in turn calls this procedure.
 *               Data from lm_prlt_asc is sorted based on orgn_code.
 *               For each header row it calls procedure insert_gmd_tech_seq_hdr
 *               and for all details for this header it call procedure
 *               insert_gmd_tech_seq_dtl.
 *
 * History     :
 *               Shyam Sitaraman    02/28/03   Initial Implementation
 * *************************************************************** */
 PROCEDURE insert_gmd_tech_seq_comps IS
   CURSOR C_get_lm_prlt_asc IS
     SELECT *
     FROM   lm_prlt_asc_bak
     ORDER BY orgn_code;
   l_orgn_code    VARCHAR2(4);
   l_tech_seq_id  NUMBER;
 BEGIN
   OPEN  C_get_lm_prlt_asc;
   FETCH C_get_lm_prlt_asc INTO v_lm_prlt_asc_rec;
     WHILE (C_get_lm_prlt_asc%FOUND) LOOP
       IF (v_lm_prlt_asc_rec.orgn_code = l_orgn_code) THEN
         -- Hdr row already inserted, only insert in the detail table
         insert_gmd_tech_seq_dtl(l_tech_seq_id);
       ELSE
         -- Insert this row in the header table
         insert_gmd_tech_seq_hdr(x_tech_seq_id => l_tech_seq_id);
         -- Assign the unique key (orgn code value)
         l_orgn_code := v_lm_prlt_asc_rec.orgn_code;
         -- Then insert this row in the detail table
         insert_gmd_tech_seq_dtl(l_tech_seq_id);
       END IF;
       FETCH C_get_lm_prlt_asc INTO v_lm_prlt_asc_rec;
     END LOOP;
   CLOSE C_get_lm_prlt_asc;

  EXCEPTION
    WHEN OTHERS THEN
      P_line_no := P_line_no + 1;
      GMA_MIGRATION.gma_insert_message (p_run_id => p_run_id
                                       ,p_table_name => 'GMD_TECHNICAL_SEQUENCE_HDR'
                                       ,p_db_error => sqlerrm
                                       ,p_param1 => NULL
                                       ,p_param2 => NULL
                                       ,p_param3 => NULL
                                       ,p_param4 => NULL
                                       ,p_param5 => NULL
                                       ,p_message_token => 'GMA_MIGRATION_DB_ERROR'
                                       ,p_message_type => 'D'
                                       ,p_line_no => P_line_no
                                       ,p_position=> 1
                                       ,p_base_message=> NULL);
 END insert_gmd_tech_seq_comps;


/* ***************************************************************
 * PROCEDURE insert_gmd_tech_data_hdr
 *
 * Synopsis    : insert_gmd_tech_data_hdr(xTech_data_id)
 *
 * Description : This function cannot be called independently. It gets
 *               called within Procedure insert_gmd_tech_data_comps.
 *               It inserts a row in gmd_technical_data_hdr table and also
 *               returns the Tech_data_id, which is used to insert
 *               details in gmd_technical_data_dtl table.
 * History     :
 *               Shyam Sitaraman    02/28/03   Initial Implementation
 * *************************************************************** */
 PROCEDURE insert_gmd_tech_data_hdr(x_tech_data_id OUT NOCOPY NUMBER) IS

 BEGIN
   SELECT gmd_tech_data_id_s.nextval INTO x_tech_data_id
   FROM   sys.dual;

   INSERT INTO gmd_technical_data_hdr
      ( tech_data_id
      , orgn_code
      , item_id
      , lot_id
      , formula_id
      , batch_id
      , delete_mark
      , text_code
      , creation_date
      , created_by
      , last_update_date
      , last_updated_by
      , last_update_login
   ) SELECT
        x_tech_data_id
      , v_lm_item_dat_rec.orgn_code
      , v_lm_item_dat_rec.item_id
      , Decode(v_lm_item_dat_rec.lot_id, 0, Null, v_lm_item_dat_rec.lot_id)
      , Decode(v_lm_item_dat_rec.formula_id, 0, Null, v_lm_item_dat_rec.formula_id)
      , Null
      , v_lm_item_dat_rec.delete_mark
      , v_lm_item_dat_rec.text_code
      , v_lm_item_dat_rec.creation_date
      , v_lm_item_dat_rec.created_by
      , v_lm_item_dat_rec.last_update_date
      , v_lm_item_dat_rec.last_updated_by
      , v_lm_item_dat_rec.last_update_login
       FROM
        sys.dual
     WHERE NOT EXISTS (SELECT 1
                       FROM   gmd_technical_data_hdr
                       WHERE  orgn_code = v_lm_item_dat_rec.orgn_code
                       AND    item_id   = v_lm_item_dat_rec.item_id);

  EXCEPTION

    WHEN OTHERS THEN
      P_line_no := P_line_no + 1;
      GMA_MIGRATION.gma_insert_message (p_run_id => p_run_id
                                       ,p_table_name => 'GMD_TECHNICAL_DATA_HDR'
                                       ,p_db_error => sqlerrm
                                       ,p_param1 => NULL
                                       ,p_param2 => NULL
                                       ,p_param3 => NULL
                                       ,p_param4 => NULL
                                       ,p_param5 => NULL
                                       ,p_message_token => 'GMA_MIGRATION_DB_ERROR'
                                       ,p_message_type => 'D'
                                       ,p_line_no => P_line_no
                                       ,p_position=> 1
                                       ,p_base_message=> NULL);
 END insert_gmd_tech_data_hdr;

/* ***************************************************************
 * PROCEDURE insert_gmd_tech_data_dtl
 *
 * Synopsis    : insert_gmd_tech_data_dtl(1,'DENSITY');
 *
 * Description : This function cannot be called independently. It gets
 *               called within Procedure insert_gmd_tech_data_comps.
 *               After it inserts rows in gmd_technical_data_dtl table.
 * History     :
 *               Shyam Sitaraman    02/28/03   Initial Implementation
 * *************************************************************** */
 PROCEDURE insert_gmd_tech_data_dtl(vTech_data_id NUMBER) IS

   CURSOR C_get_tech_parm_id(vtech_parm_name VARCHAR2
                            ,vorgn_code      VARCHAR2) IS
     SELECT tech_parm_id
     FROM   gmd_tech_parameters_b
     WHERE  tech_parm_name = vtech_parm_name
     AND    orgn_code      = vorgn_code;

   l_tech_parm_id        NUMBER;
   E_Tech_parm_Not_Found EXCEPTION;

 BEGIN
   IF (vTech_data_id IS NOT NULL) THEN

     /* Get the tech parm id */
     OPEN C_get_tech_parm_id(v_lm_item_dat_rec.tech_parm_name
                            ,v_lm_item_dat_rec.orgn_code);
     FETCH C_get_tech_parm_id INTO l_tech_parm_id;
       IF C_get_tech_parm_id%NOTFOUND THEN
         RAISE E_Tech_parm_Not_Found;
       END IF;
     CLOSE C_get_tech_parm_id;

     INSERT INTO gmd_technical_data_dtl
        ( tech_data_id
        , tech_parm_id
        , sort_seq
        , text_data
        , num_data
        , boolean_data
        , text_code
        , creation_date
        , created_by
        , last_update_date
        , last_updated_by
        , last_update_login
        )
     SELECT
          vTech_data_id
        , l_tech_parm_id
        , v_lm_item_dat_rec.sort_seq
        , v_lm_item_dat_rec.text_data
        , v_lm_item_dat_rec.num_data
        , v_lm_item_dat_rec.boolean_data
        , v_lm_item_dat_rec.text_code
        , v_lm_item_dat_rec.creation_date
        , v_lm_item_dat_rec.created_by
        , v_lm_item_dat_rec.last_update_date
        , v_lm_item_dat_rec.last_updated_by
        , v_lm_item_dat_rec.last_update_login
     FROM sys.dual
     WHERE NOT EXISTS
       (SELECT 1 FROM gmd_technical_data_dtl
        WHERE  tech_parm_id   = l_tech_parm_id
        AND    tech_data_id   = vTech_data_id);
   END IF;

  EXCEPTION
     WHEN E_Tech_parm_Not_Found THEN
      P_line_no := P_line_no + 1;
      GMA_MIGRATION.gma_insert_message (p_run_id => p_run_id
                                       ,p_table_name => 'GMD_TECHNICAL_DATA_HDR'
                                       ,p_db_error => sqlerrm
                                       ,p_param1 => NULL
                                       ,p_param2 => NULL
                                       ,p_param3 => NULL
                                       ,p_param4 => NULL
                                       ,p_param5 => NULL
                                       ,p_message_token => 'GMA_MIGRATION_DB_ERROR'
                                       ,p_message_type => 'D'
                                       ,p_line_no => P_line_no
                                       ,p_position=> 1
                                       ,p_base_message=> NULL);

    WHEN OTHERS THEN
      P_line_no := P_line_no + 1;
      GMA_MIGRATION.gma_insert_message (p_run_id => p_run_id
                                       ,p_table_name => 'GMD_TECHNICAL_DATA_DTL'
                                       ,p_db_error => sqlerrm
                                       ,p_param1 => NULL
                                       ,p_param2 => NULL
                                       ,p_param3 => NULL
                                       ,p_param4 => NULL
                                       ,p_param5 => NULL
                                       ,p_message_token => 'GMA_MIGRATION_DB_ERROR'
                                       ,p_message_type => 'D'
                                       ,p_line_no => P_line_no
                                       ,p_position=> 1
                                       ,p_base_message=> NULL);
 END insert_gmd_tech_data_dtl;

/* ***************************************************************
 * PROCEDURE insert_gmd_tech_data_comps
 *
 * Synopsis    : insert_gmd_tech_data_comps;
 *
 * Description : This procedure can be called independently.  Although
 *               it is recommended to call the main program (procedure)
 *               GMD_LM_MIGRATION.Run which in turn calls this procedure.
 *               Data from lm_item_data is sorted based on orgn_code and
 *               item_id.  For each header row it calls procedure
 *               insert_gmd_tech_data_hdr and for all details for this
 *               header it call procedure insert_gmd_tech_data_dtl.
 *
 * History     :
 *               Shyam Sitaraman    02/28/03   Initial Implementation
 * *************************************************************** */
 PROCEDURE insert_gmd_tech_data_comps IS
   CURSOR C_get_lm_item_dat IS
     SELECT *
     FROM   lm_item_dat_bak
     ORDER BY orgn_code, item_id;
   l_orgn_code    VARCHAR2(4);
   l_item_id      NUMBER;
   l_formula_id   NUMBER;
   l_lot_id       NUMBER;
   l_tech_data_id  NUMBER;
   l_tech_parm_id  NUMBER;
 BEGIN
   OPEN  C_get_lm_item_dat;
   FETCH C_get_lm_item_dat INTO v_lm_item_dat_rec;
     WHILE (C_get_lm_item_dat%FOUND) LOOP
       IF ((v_lm_item_dat_rec.orgn_code = l_orgn_code) AND
           (v_lm_item_dat_rec.item_id = l_item_id)) THEN
         -- Hdr row already inserted, only insert in the detail table
         insert_gmd_tech_data_dtl(l_tech_data_id);
       ELSE
         -- Insert this row in the header table
         insert_gmd_tech_data_hdr(x_tech_data_id => l_tech_data_id);

         -- Assign the unique key (orgn code value)
         l_orgn_code := v_lm_item_dat_rec.orgn_code;
         l_item_id   := v_lm_item_dat_rec.item_id;

         -- Then insert this row in the detail table
         insert_gmd_tech_data_dtl(l_tech_data_id);
       END IF;
       FETCH C_get_lm_item_dat INTO v_lm_item_dat_rec;
     END LOOP;
   CLOSE C_get_lm_item_dat;
  EXCEPTION
    WHEN OTHERS THEN
      P_line_no := P_line_no + 1;
      GMA_MIGRATION.gma_insert_message (p_run_id => p_run_id
                                       ,p_table_name => 'GMD_TECHNICAL_DATA_HDR'
                                       ,p_db_error => sqlerrm
                                       ,p_param1 => NULL
                                       ,p_param2 => NULL
                                       ,p_param3 => NULL
                                       ,p_param4 => NULL
                                       ,p_param5 => NULL
                                       ,p_message_token => 'GMA_MIGRATION_DB_ERROR'
                                       ,p_message_type => 'D'
                                       ,p_line_no => P_line_no
                                       ,p_position=> 1
                                       ,p_base_message=> NULL);
 END insert_gmd_tech_data_comps;


/* ***************************************************************
 * PROCEDURE Run
 *
 * Synopsis    : GMD_LM_MIGRATION.run;
 *
 * Description : Main Program - it calls procedure insert_gmd_tech_seq_comps
 *               and insert_gmd_tech_data_comps. It also creates the rows in
 *               GMA TABLE called gma_migration_log that would list out all
 *               existing entity instances that might have problems migrating
 *               over to the New process parameter tables.
 *
 * History     :
 *               Shyam Sitaraman    02/28/03   Initial Implementation
 * *************************************************************** */
 PROCEDURE run IS
  BEGIN
    P_run_id := GMA_MIGRATION.gma_migration_start
                (p_app_short_name => 'GMD'
                ,p_mig_name => 'GMD_LM_MIGRATION');
    GMD_LM_MIGRATION.generate_tech_parm_id;
    GMD_LM_MIGRATION.populate_lm_sprd_dtl_sec_qty;
    GMD_LM_MIGRATION.populate_parsed_expressions;
    GMD_LM_MIGRATION.insert_gmd_tech_seq_comps;
    GMD_LM_MIGRATION.insert_gmd_tech_data_comps;
    GMA_MIGRATION.gma_migration_end (l_run_id => p_run_id);
  END run;


END GMD_LM_MIGRATION;

/
