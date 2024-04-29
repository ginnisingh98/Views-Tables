--------------------------------------------------------
--  DDL for Package Body FEM_SETUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_SETUP_PKG" AS
/*  $Header: fem_setup_pkg.plb 120.3.12000000.2 2007/08/16 18:22:43 srawat ship $        */

 /*===========================================================================+
 | PROCEDURE
 |
 |
 | DESCRIPTION
 |
 |             This procedure is used to register the segments for Activity
 |             Flex Field.
 |
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  :
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/


 PROCEDURE register_activity_ff(p_api_version   IN  NUMBER,
                                p_init_msg_list IN  VARCHAR2,
                                p_commit        IN  VARCHAR2,
                                p_encoded       IN  VARCHAR2,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_msg_count     OUT NOCOPY NUMBER,
                                x_msg_data      OUT NOCOPY VARCHAR2) AS

    CURSOR select_activity_obj_cur IS
       SELECT column_name,
              DECODE(column_name,'TASK_ID',                    'Task',
                                 'COMPANY_COST_CENTER_ORG_ID', 'Organization',
                                 'CUSTOMER_ID',                'Customer',
                                 'CHANNEL_ID',                 'Channel',
                                 'PRODUCT_ID',                 'Product',
                                 'PROJECT_ID',                 'Project',
                                 'USER_DIM1_ID',               'User dimension 1',
                                 'USER_DIM2_ID',               'User dimension 2',
                                 'USER_DIM3_ID',               'User dimension 3',
                                 'USER_DIM4_ID',               'User dimension 4',
                                 'USER_DIM5_ID',               'User dimension 5',
                                 'USER_DIM6_ID',               'User dimension 6',
                                 'USER_DIM7_ID',               'User dimension 7',
                                 'USER_DIM8_ID',               'User dimension 8',
                                 'USER_DIM9_ID',               'User dimension 9',
                                 'USER_DIM10_ID',              'User dimension 10',
                                 'UNKNOWN') user_column_name,
              DECODE(column_name,'TASK_ID',                    DECODE(activity_dim_component_flag,'Y','SEGMENT1','UNKNOWN'),
                                 'COMPANY_COST_CENTER_ORG_ID', DECODE(activity_dim_component_flag,'Y','SEGMENT2','UNKNOWN'),
                                 'CUSTOMER_ID',                DECODE(activity_dim_component_flag,'Y','SEGMENT3','UNKNOWN'),
                                 'CHANNEL_ID',                 DECODE(activity_dim_component_flag,'Y','SEGMENT4','UNKNOWN'),
                                 'PRODUCT_ID',                 DECODE(activity_dim_component_flag,'Y','SEGMENT5','UNKNOWN'),
                                 'PROJECT_ID',                 DECODE(activity_dim_component_flag,'Y','SEGMENT6','UNKNOWN'),
                                 'USER_DIM1_ID',               DECODE(activity_dim_component_flag,'Y','SEGMENT7','UNKNOWN'),
                                 'USER_DIM2_ID',               DECODE(activity_dim_component_flag,'Y','SEGMENT8','UNKNOWN'),
                                 'USER_DIM3_ID',               DECODE(activity_dim_component_flag,'Y','SEGMENT9','UNKNOWN'),
                                 'USER_DIM4_ID',               DECODE(activity_dim_component_flag,'Y','SEGMENT10','UNKNOWN'),
                                 'USER_DIM5_ID',               DECODE(activity_dim_component_flag,'Y','SEGMENT11','UNKNOWN'),
                                 'USER_DIM6_ID',               DECODE(activity_dim_component_flag,'Y','SEGMENT12','UNKNOWN'),
                                 'USER_DIM7_ID',               DECODE(activity_dim_component_flag,'Y','SEGMENT13','UNKNOWN'),
                                 'USER_DIM8_ID',               DECODE(activity_dim_component_flag,'Y','SEGMENT14','UNKNOWN'),
                                 'USER_DIM9_ID',               DECODE(activity_dim_component_flag,'Y','SEGMENT15','UNKNOWN'),
                                 'USER_DIM10_ID',              DECODE(activity_dim_component_flag,'Y','SEGMENT16','UNKNOWN'),
                                 'UNKNOWN') act_segment_num,
              vs_member_vl_object_name vs_name
       FROM   fem_column_requiremnt_b fcr,
              fem_xdim_dimensions fxd
       WHERE  fcr.dimension_id = fxd.dimension_id
         AND  fcr.activity_dim_component_flag = 'Y'
      ORDER BY act_segment_num; --Bug#4209065

    j                   NUMBER := 0;

    act_ff_rec          fnd_flex_key_api.flexfield_type;
    act_str_rec         fnd_flex_key_api.structure_type;
    act_seg_rec         fnd_flex_key_api.segment_type;

    dummy_rec           fnd_flex_key_api.structure_type;

    find_act_defn       BOOLEAN := TRUE;

    l_column_name       VARCHAR2(500);

    l_api_version       NUMBER;
    l_init_msg_list     VARCHAR2(1);
    l_commit            VARCHAR2(1);
    l_encoded           VARCHAR2(1);

    l_api_name          CONSTANT VARCHAR2(30) := 'register_activity_ff';


BEGIN

  l_api_version   := NVL(p_api_version, c_api_version);
  l_init_msg_list := NVL(p_init_msg_list, c_false);
  l_commit        := NVL(p_commit, c_false);
  l_encoded       := NVL(p_encoded, c_true);

  x_return_status := c_success;

  fem_engines_pkg.tech_message (p_severity  => g_log_level_1
                                  ,p_module   => g_block||'.'||l_api_name
                                  ,p_msg_text => 'Begin');

      --------------------
      --Query the elements
      --------------------

      FOR sel_act_cost_obj_rec IN select_activity_obj_cur
      LOOP

         IF sel_act_cost_obj_rec.user_column_name <> 'UNKNOWN' THEN
            l_column_name := sel_act_cost_obj_rec.column_name;

            --------------------------------
            --Get handle to FF and structure
            --------------------------------

            IF find_act_defn THEN
               -- If the set_session_mode is not used, handle to FF and structure returns NULL
               fnd_flex_key_api.set_session_mode('seed_data');
               act_ff_rec := fnd_flex_key_api.find_flexfield('FEM','FEAC');
               act_str_rec := fnd_flex_key_api.find_structure(act_ff_rec,'Activity Flexfield');
               find_act_defn := FALSE;
            END IF;

            ------------------------------------
            --End Get handle to FF and structure
            ------------------------------------

            j := j + 1;

            -----------------------------------------------
            --Register the new segments to the FF structure
            -----------------------------------------------

  	    fem_engines_pkg.tech_message (p_severity  => g_log_level_2
                                         ,p_module   => g_block||'.'||l_api_name
                                         ,p_msg_text => 'Register New Segment');

            act_seg_rec := fnd_flex_key_api.new_segment(flexfield => act_ff_rec,
                                                        structure => act_str_rec,
                                                        segment_name => l_column_name,
                                                        description => l_column_name,
                                                        column_name => sel_act_cost_obj_rec.act_segment_num,
                                                        segment_number => j,
                                                        enabled_flag => 'Y',
                                                        displayed_flag => 'Y',
                                                        indexed_flag => 'Y',
                                                        value_set => sel_act_cost_obj_rec.vs_name,
                                                        default_type => NULL,
                                                        default_value => NULL,
                                                        required_flag => 'Y',
                                                        security_flag => 'N',
                                                        range_code => NULL,
                                                        display_size => 25,
                                                        description_size => 50,
                                                        concat_size => 25,
                                                        lov_prompt => l_column_name,
                                                        window_prompt => sel_act_cost_obj_rec.user_column_name,
                                                        runtime_property_function => null,
                                                        additional_where_clause => null );

            ---------------------------------------------------
            --End Register the new segments to the FF structure
            ---------------------------------------------------

            ----------------------------------
            --Add the segment to the structure
            ----------------------------------

             fem_engines_pkg.tech_message (p_severity  => g_log_level_2
                                           ,p_module   => g_block||'.'||l_api_name
                                           ,p_msg_text => 'Add New Segment to structure');

              fnd_flex_key_api.add_segment(flexfield => act_ff_rec,
                                           structure => act_str_rec,
                                           segment => act_seg_rec);

            --------------------------------------
            --End Add the segment to the structure
            --------------------------------------

         END IF;

      END LOOP;

      ------------------------
      --End Query the elements
      ------------------------

  ----------------------------
  --Compile FF definition FEAC
  ----------------------------

  IF j > 0 THEN

     fem_engines_pkg.tech_message (p_severity  => g_log_level_2
                                  ,p_module   => g_block||'.'||l_api_name
                                  ,p_msg_text => 'Compiling the flexfield definition');

     compile_ff( p_api_version => l_api_version,
                 p_init_msg_list => l_init_msg_list,
                 p_commit => l_commit,
                 p_encoded => l_encoded,
                 x_return_status => x_return_status,
                 x_msg_count => x_msg_count,
                 x_msg_data => x_msg_data,
                 p_ff_name => 'FEAC',
                 p_comdim_ff_rec => act_ff_rec,
                 p_comdim_str_rec => act_str_rec);
  END IF;

  --------------------------------
  --End Compile FF definition FEAC
  --------------------------------

  fem_engines_pkg.tech_message (p_severity  => g_log_level_1
                                  ,p_module   => g_block||'.'||l_api_name
                                  ,p_msg_text => 'End');


  EXCEPTION
    WHEN OTHERS THEN

       x_return_status := c_error;

       fem_engines_pkg.tech_message (p_severity  => g_log_level_4
                                  ,p_module   => g_block||'.'||l_api_name
                                  ,p_msg_text => 'Exception');

       -- Bug#6331569: Add message logging.
       IF fnd_flex_key_api.message IS NOT NULL THEN
         fem_engines_pkg.tech_message ( p_severity  => g_log_level_4
                                       ,p_module   => g_block||'.'||l_api_name
                                       ,p_msg_text => fnd_flex_key_api.message);
       END IF;

       fnd_msg_pub.count_and_get(p_encoded => p_encoded,
                                 p_count => x_msg_count,
                                 p_data => x_msg_data);

  END register_activity_ff;

 /*===========================================================================+
 | PROCEDURE
 |
 |
 | DESCRIPTION
 |
 |             This procedure is used to register the flex field for Cost Object
 |
 |
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  :
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/



 PROCEDURE register_cost_ff(p_api_version   IN  NUMBER,
                            p_init_msg_list IN  VARCHAR2,
                            p_commit        IN  VARCHAR2,
                            p_encoded       IN  VARCHAR2,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count     OUT NOCOPY NUMBER,
                            x_msg_data      OUT NOCOPY VARCHAR2) AS

    CURSOR select_cost_obj_cur IS
       SELECT column_name,
              DECODE(column_name,'FINANCIAL_ELEM_ID',          'Financial Element',
				         'LEDGER_ID',                  'Ledger',
                                 'PRODUCT_ID',                 'Product',
                                 'COMPANY_COST_CENTER_ORG_ID', 'Organization',
                                 'CUSTOMER_ID',                'Customer',
                                 'CHANNEL_ID',                 'Channel',
                                 'PROJECT_ID',                 'Project',
                                 'USER_DIM1_ID',               'User dimension 1',
                                 'USER_DIM2_ID',               'User dimension 2',
                                 'USER_DIM3_ID',               'User dimension 3',
                                 'USER_DIM4_ID',               'User dimension 4',
                                 'USER_DIM5_ID',               'User dimension 5',
                                 'USER_DIM6_ID',               'User dimension 6',
                                 'USER_DIM7_ID',               'User dimension 7',
                                 'USER_DIM8_ID',               'User dimension 8',
                                 'USER_DIM9_ID',               'User dimension 9',
                                 'USER_DIM10_ID',              'User dimension 10',
                                 'UNKNOWN') user_column_name,
              DECODE(column_name,'FINANCIAL_ELEM_ID',          DECODE(cost_obj_dim_component_flag,'Y','SEGMENT1','UNKNOWN'),
                                 'LEDGER_ID',                  DECODE(cost_obj_dim_component_flag,'Y','SEGMENT2','UNKNOWN'),
                                 'PRODUCT_ID',                 DECODE(cost_obj_dim_component_flag,'Y','SEGMENT3','UNKNOWN'),
                                 'COMPANY_COST_CENTER_ORG_ID', DECODE(cost_obj_dim_component_flag,'Y','SEGMENT4','UNKNOWN'),
                                 'CUSTOMER_ID',                DECODE(cost_obj_dim_component_flag,'Y','SEGMENT5','UNKNOWN'),
                                 'CHANNEL_ID',                 DECODE(cost_obj_dim_component_flag,'Y','SEGMENT6','UNKNOWN'),
                                 'PROJECT_ID',                 DECODE(cost_obj_dim_component_flag,'Y','SEGMENT7','UNKNOWN'),
                                 'USER_DIM1_ID',               DECODE(cost_obj_dim_component_flag,'Y','SEGMENT8','UNKNOWN'),
                                 'USER_DIM2_ID',               DECODE(cost_obj_dim_component_flag,'Y','SEGMENT9','UNKNOWN'),
                                 'USER_DIM3_ID',               DECODE(cost_obj_dim_component_flag,'Y','SEGMENT10','UNKNOWN'),
                                 'USER_DIM4_ID',               DECODE(cost_obj_dim_component_flag,'Y','SEGMENT11','UNKNOWN'),
                                 'USER_DIM5_ID',               DECODE(cost_obj_dim_component_flag,'Y','SEGMENT12','UNKNOWN'),
                                 'USER_DIM6_ID',               DECODE(cost_obj_dim_component_flag,'Y','SEGMENT13','UNKNOWN'),
                                 'USER_DIM7_ID',               DECODE(cost_obj_dim_component_flag,'Y','SEGMENT14','UNKNOWN'),
                                 'USER_DIM8_ID',               DECODE(cost_obj_dim_component_flag,'Y','SEGMENT15','UNKNOWN'),
                                 'USER_DIM9_ID',               DECODE(cost_obj_dim_component_flag,'Y','SEGMENT16','UNKNOWN'),
                                 'USER_DIM10_ID',              DECODE(cost_obj_dim_component_flag,'Y','SEGMENT17','UNKNOWN'),
                                 'UNKNOWN') cost_segment_num,
              vs_member_vl_object_name vs_name
       FROM   fem_column_requiremnt_b fcr,
              fem_xdim_dimensions fxd
       WHERE  fcr.dimension_id = fxd.dimension_id
         AND  cost_obj_dim_component_flag = 'Y'
      ORDER BY cost_segment_num; --Bug#4209065

    k                   NUMBER := 0;

    cost_ff_rec         fnd_flex_key_api.flexfield_type;
    cost_str_rec        fnd_flex_key_api.structure_type;
    cost_seg_rec        fnd_flex_key_api.segment_type;

    find_cost_defn      BOOLEAN := TRUE;

    l_column_name       VARCHAR2(500);

    l_api_version       NUMBER;
    l_init_msg_list     VARCHAR2(1);
    l_commit            VARCHAR2(1);
    l_encoded           VARCHAR2(1);

    l_api_name          CONSTANT VARCHAR2(30) := 'register_cost_ff';

BEGIN

  l_api_version   := NVL(p_api_version, c_api_version);
  l_init_msg_list := NVL(p_init_msg_list, c_false);
  l_commit        := NVL(p_commit, c_false);
  l_encoded       := NVL(p_encoded, c_true);

  x_return_status := c_success;

  fem_engines_pkg.tech_message (p_severity  => g_log_level_1
                                  ,p_module   => g_block||'.'||l_api_name
                                  ,p_msg_text => 'Begin');


      --------------------
      --Query the elements
      --------------------

      FOR sel_act_cost_obj_rec IN select_cost_obj_cur
      LOOP

         IF sel_act_cost_obj_rec.user_column_name <> 'UNKNOWN' THEN
            l_column_name := sel_act_cost_obj_rec.column_name;

               --------------------------------
               --Get handle to FF and structure
               -----------------------------------------

               IF find_cost_defn THEN
                  --If the set_session_mode is not used, handle to FF and structure returns NULL
                  fnd_flex_key_api.set_session_mode('customer_data');
                  cost_ff_rec := fnd_flex_key_api.find_flexfield('FEM','FECO');
                  cost_str_rec := fnd_flex_key_api.find_structure(cost_ff_rec,'Cost Object Flexfield');
                  find_cost_defn := FALSE;
               END IF;

               ------------------------------------
               --End Get handle to FF and structure
               ------------------------------------

               k := k + 1;

               -----------------------------------------------
               --Register the new segments to the FF structure
               -----------------------------------------------

     	         fem_engines_pkg.tech_message (p_severity  => g_log_level_2
                                            ,p_module   => g_block||'.'||l_api_name
                                            ,p_msg_text => 'Register New Segment');

               cost_seg_rec := fnd_flex_key_api.new_segment(flexfield => cost_ff_rec,
                                                            structure => cost_str_rec,
                                                            segment_name => l_column_name,
                                                            description => l_column_name,
                                                            column_name => sel_act_cost_obj_rec.cost_segment_num,
                                                            segment_number => k,
                                                            enabled_flag => 'Y',
                                                            displayed_flag => 'Y',
                                                            indexed_flag => 'Y',
                                                            value_set => sel_act_cost_obj_rec.vs_name,
                                                            default_type => NULL,
                                                            default_value => NULL,
                                                            required_flag => 'Y',
                                                            security_flag => 'N',
                                                            range_code => NULL,
                                                            display_size => 25,
                                                            description_size => 50,
                                                            concat_size => 25,
                                                            lov_prompt => l_column_name,
                                                            window_prompt => sel_act_cost_obj_rec.user_column_name,
                                                            runtime_property_function => null,
                                                            additional_where_clause => null );

              ---------------------------------------------------
              --End Register the new segments to the FF structure
              ---------------------------------------------------

              ----------------------------------
              --Add the segment to the structure
              ----------------------------------

               fem_engines_pkg.tech_message (p_severity  => g_log_level_2
                                            ,p_module   => g_block||'.'||l_api_name
                                            ,p_msg_text => 'Add New Segment to structure');

               fnd_flex_key_api.add_segment(flexfield => cost_ff_rec,
	                                      structure => cost_str_rec,
                                            segment => cost_seg_rec);

              --------------------------------------
              --End Add the segment to the structure
              --------------------------------------

         END IF;

      END LOOP;

      ------------------------
      --End Query the elements
      ------------------------

  IF k > 0 THEN

     fem_engines_pkg.tech_message (p_severity  => g_log_level_2
                                  ,p_module   => g_block||'.'||l_api_name
                                  ,p_msg_text => 'Compiling the flexfield definition');

     compile_ff( p_api_version => l_api_version,
                 p_init_msg_list => l_init_msg_list,
                 p_commit => l_commit,
                 p_encoded => l_encoded,
                 x_return_status => x_return_status,
                 x_msg_count => x_msg_count,
                 x_msg_data => x_msg_data,
                 p_ff_name => 'FECO',
                 p_comdim_ff_rec => cost_ff_rec,
                 p_comdim_str_rec => cost_str_rec);
  END IF;

  fem_engines_pkg.tech_message (p_severity  => g_log_level_1
                                  ,p_module   => g_block||'.'||l_api_name
                                  ,p_msg_text => 'End');

  EXCEPTION
    WHEN OTHERS THEN
       x_return_status := c_error;

       fem_engines_pkg.tech_message (p_severity  => g_log_level_4
                                  ,p_module   => g_block||'.'||l_api_name
                                  ,p_msg_text => 'Exception');

       -- Bug#6331569: Add message logging.
       IF fnd_flex_key_api.message IS NOT NULL THEN
         fem_engines_pkg.tech_message ( p_severity  => g_log_level_4
                                       ,p_module   => g_block||'.'||l_api_name
                                       ,p_msg_text => fnd_flex_key_api.message);
       END IF;

       fnd_msg_pub.count_and_get(p_encoded => p_encoded,
                                 p_count => x_msg_count,
                                 p_data => x_msg_data);

  END register_cost_ff;

 /*===========================================================================+
 | PROCEDURE
 |            compile_ff
 |
 | DESCRIPTION
 |
 |             This procedure is used to compile the flex field after adding
 | the new segments.
 |
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  :
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

 PROCEDURE compile_ff(p_api_version   IN  NUMBER,
                      p_init_msg_list IN  VARCHAR2,
                      p_commit        IN  VARCHAR2,
                      p_encoded       IN  VARCHAR2,
                      x_return_status OUT NOCOPY VARCHAR2,
                      x_msg_count     OUT NOCOPY NUMBER,
                      x_msg_data      OUT NOCOPY VARCHAR2,
                      p_ff_name       IN  VARCHAR2,
                      p_comdim_ff_rec IN  fnd_flex_key_api.flexfield_type,
                      p_comdim_str_rec IN fnd_flex_key_api.structure_type) AS

    mod_structure     fnd_flex_key_api.structure_type;
    orig_structure    fnd_flex_key_api.structure_type;
    request_id        NUMBER;

    l_flex_num            NUMBER;
    l_flex_structure_code VARCHAR2(30);

    l_api_version       NUMBER;
    l_init_msg_list     VARCHAR2(1);
    l_commit            VARCHAR2(1);
    l_encoded           VARCHAR2(1);

    l_api_name          CONSTANT VARCHAR2(30) := 'compile_ff';


    CURSOR  get_flex_num_cur IS
      SELECT id_flex_num,id_flex_structure_code
      FROM   fnd_id_flex_structures
      WHERE  application_id = 274
        AND  id_flex_code = p_ff_name;

  BEGIN

       l_api_version   := NVL(p_api_version, c_api_version);
       l_init_msg_list := NVL(p_init_msg_list, c_false);
       l_commit        := NVL(p_commit, c_false);
       l_encoded       := NVL(p_encoded, c_true);

       x_return_status := c_success;

       ----------------------------
       -- Freeze the FF definition
       ----------------------------

       orig_structure := p_comdim_str_rec;

       fem_engines_pkg.tech_message (p_severity  => g_log_level_2
                                    ,p_module   => g_block||'.'||l_api_name
                                    ,p_msg_text => 'Modifying the structure to set flags');

       mod_structure := fnd_flex_key_api.new_structure(flexfield => p_comdim_ff_rec,
                        -- Bug#6331569: Explicitly pass structure code.
                        structure_code => orig_structure.structure_code,
                                                     	 structure_title => orig_structure.structure_name,
                                                 	 description => orig_structure.description,
                                                 	 view_name => orig_structure.view_name,
                                                 	 freeze_flag => 'Y',
                                                 	 enabled_flag => 'Y',
                                                 	 segment_separator => orig_structure.segment_separator,
                                                 	 cross_val_flag => 'N',
                                                 	 freeze_rollup_flag => 'N',
                                                 	 dynamic_insert_flag => 'Y',
                                                 	 shorthand_enabled_flag => 'N',
                                                 	 shorthand_prompt => '',
                                                 	 shorthand_length => NULL);

        fnd_flex_key_api.modify_structure(flexfield => p_comdim_ff_rec,
                                          original => orig_structure,
                                          modified => mod_structure);

       --------------------------------
       -- End Freeze the FF definition
       --------------------------------

        fnd_global.apps_initialize(fnd_global.user_id,
                                   fnd_global.resp_id,
                                   fnd_global.resp_appl_id);

       ----------------
       -- Get ID FF Num
       ----------------

       OPEN  get_flex_num_cur;
       FETCH get_flex_num_cur INTO l_flex_num,l_flex_structure_code ;
       CLOSE get_flex_num_cur;

       --------------------
       -- End Get ID FF Num
       --------------------

       ---------------------
       -- Compile flexfield
       ---------------------

       fem_engines_pkg.tech_message (p_severity  => g_log_level_2
                                    ,p_module   => g_block||'.'||l_api_name
                                    ,p_msg_text => 'Compiling the flexfield through SRS');

       request_id := fnd_request.submit_request('FND',
                                                'FDFCMPK',
                                                'Compiling Flexfield',
                                                 SYSDATE,
                                                 FALSE,
                                                 'K',
                                                 'FEM',
                                                 p_ff_name,
                                                 TO_CHAR(l_flex_num));

      IF request_id = 0 THEN
         fnd_message.retrieve(x_msg_data);
         fnd_message.raise_error;
      END IF;

      ------------------------
      -- End Compile flexfield
      ------------------------

      -------------------------------------------------------------
      -- Update FEM_XDIM_DIMENSIONS_VL with FLEX_FIELD Information
      -------------------------------------------------------------

     fem_engines_pkg.tech_message (p_severity  => g_log_level_2
                                  ,p_module   => g_block||'.'||l_api_name
                                  ,p_msg_text => 'Updating fem_xdim_dimensions with FF details');

      IF p_ff_name = 'FEAC' THEN
         UPDATE fem_xdim_dimensions
         SET    id_flex_num = l_flex_num ,
                id_flex_structure_code = l_flex_structure_code,
                id_flex_code= p_ff_name
         WHERE  dimension_id = 10;
      ELSIF p_ff_name = 'FECO' THEN
         UPDATE fem_xdim_dimensions
	   SET    id_flex_num = l_flex_num ,
                id_flex_structure_code = l_flex_structure_code,
                id_flex_code= p_ff_name
         WHERE  dimension_id = 11;
      END IF;

     fem_engines_pkg.tech_message (p_severity  => g_log_level_1
                                  ,p_module   => g_block||'.'||l_api_name
                                  ,p_msg_text => 'End');

    EXCEPTION
      WHEN OTHERS THEN
         x_return_status := c_error;

         fem_engines_pkg.tech_message (p_severity  => g_log_level_4
                                  ,p_module   => g_block||'.'||l_api_name
                                  ,p_msg_text => 'Exception');

         -- Bug#6331569: Add message logging.
         IF fnd_flex_key_api.message IS NOT NULL THEN
           fem_engines_pkg.tech_message ( p_severity  => g_log_level_4
                                         ,p_module   => g_block||'.'||l_api_name
                                         ,p_msg_text => fnd_flex_key_api.message);
         END IF;

         fnd_msg_pub.count_and_get(p_encoded => p_encoded,
                                   p_count => x_msg_count,
                                   p_data => x_msg_data);

 END compile_ff;
------------------------------------------------------------------------
/*
 PROCEDURE validate_proc_key(p_api_version   IN  NUMBER,
                             p_init_msg_list IN  VARCHAR2,
                             p_commit        IN  VARCHAR2,
                             p_encoded       IN  VARCHAR2,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_msg_count     OUT NOCOPY NUMBER,
                             x_msg_data      OUT NOCOPY VARCHAR2,
                             p_col_list_rec  IN  fem_col_list_arr_typ ,
                             p_table_name    IN  VARCHAR2) AS

   TYPE proc_list_arr IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

   proc_list_rec  proc_list_arr;

   l_raise_error  BOOLEAN := FALSE;
   i              NUMBER  := 0;
   j              NUMBER  := 0;

   found          BOOLEAN := FALSE;

   l_api_version  NUMBER;
   l_init_msg_list VARCHAR2(1);
   l_commit       VARCHAR2(1);
   l_encoded      VARCHAR2(1);

   l_api_name     CONSTANT VARCHAR2(30) := 'validate_proc_key';

 BEGIN

   l_api_version   := NVL(p_api_version, c_api_version);
   l_init_msg_list := NVL(p_init_msg_list, c_false);
   l_commit        := NVL(p_commit, c_false);
   l_encoded       := NVL(p_encoded, c_true);

   x_return_status := c_success;

   SELECT column_name
     BULK COLLECT INTO proc_list_rec
   FROM   fem_tab_column_prop
   WHERE  table_name = p_table_name
     AND  column_property_code = 'PROCESSING_KEY';

   IF proc_list_rec.COUNT <> p_col_list_rec.COUNT THEN
      l_raise_error := TRUE;
   END IF;

   IF NOT l_raise_error THEN
      FOR i IN proc_list_rec.FIRST..proc_list_rec.LAST LOOP
          FOR j IN 1..p_col_list_rec.COUNT LOOP
              IF proc_list_rec(i) = p_col_list_rec(j).col_name THEN
                 found := TRUE;
                 EXIT;
              END IF;
          END LOOP;
          IF NOT found THEN
             l_raise_error := TRUE;
             EXIT;
          ELSE
             found := FALSE;
          END IF;
      END LOOP;
   END IF;

   IF l_raise_error THEN
      x_return_status := c_error;
   END IF;

   fnd_msg_pub.count_and_get(p_count => x_msg_count,
                             p_data  => x_msg_data);

   EXCEPTION
     WHEN OTHERS THEN
        x_return_status := c_error;

        fnd_msg_pub.count_and_get(p_encoded => p_encoded,
                                  p_count => x_msg_count,
                                  p_data => x_msg_data);

 END validate_proc_key;
*/
 /*===========================================================================+
 | PROCEDURE
 |              validate_proc_key
 |
 | DESCRIPTION
 |
 |             This procedure is used by PFT/FEM Engines to check whether the
 | component dimensions of Activity/Cost Object is not part of the table's
 | processing key.
 |
 |
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  :
 |
 |       p_dimension_varchar_label - ACTIVITY/COST_OBJECT
 |       p_table_name              - Processing Table.
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 |    sshanmug    09-Jun-05  Bug:4475823 - modifications/fixes for improved
 |                           integration with the Rollup Engine (FEM) and
 |                           Activity Rate Engine (PFT)
 +===========================================================================*/

 PROCEDURE validate_proc_key(p_api_version       IN  NUMBER,
                             p_init_msg_list     IN  VARCHAR2,
                             p_commit            IN  VARCHAR2,
                             p_encoded           IN  VARCHAR2,
                             x_return_status     OUT NOCOPY VARCHAR2,
                             x_msg_count         OUT NOCOPY NUMBER,
                             x_msg_data          OUT NOCOPY VARCHAR2,
                             p_dimension_varchar_label IN VARCHAR2,
                             p_table_name        IN  VARCHAR2) AS

   i               NUMBER  := 0;
   j               NUMBER  := 0;

   found           BOOLEAN := FALSE;

   l_api_version   NUMBER;
   l_init_msg_list VARCHAR2(1);
   l_commit        VARCHAR2(1);
   l_encoded       VARCHAR2(1);
   l_exists        VARCHAR2(1);

   l_api_name      CONSTANT VARCHAR2(30) := 'validate_proc_key';


   CURSOR l_inv_act_dim_column_cur IS
    SELECT comp.column_name
    FROM fem_column_requiremnt_b comp
    WHERE comp.activity_dim_component_flag = 'Y'
    AND NOT EXISTS (
      SELECT 1
      FROM fem_tab_column_prop proc
      WHERE proc.table_name = p_table_name
      AND proc.column_property_code = 'PROCESSING_KEY'
      AND proc.column_name = comp.column_name
    );

  CURSOR l_inv_co_dim_column_cur IS
    SELECT comp.column_name
    FROM fem_column_requiremnt_b comp
    WHERE comp.cost_obj_dim_component_flag = 'Y'
    AND NOT EXISTS (
      SELECT 1
      FROM fem_tab_column_prop proc
      WHERE proc.table_name = p_table_name
      AND proc.column_property_code = 'PROCESSING_KEY'
      AND proc.column_name = comp.column_name
    );



 BEGIN

   l_api_version   := NVL(p_api_version, c_api_version);
   l_init_msg_list := NVL(p_init_msg_list, c_false);
   l_commit        := NVL(p_commit, c_false);
   l_encoded       := NVL(p_encoded, c_true);

   x_return_status := c_success;

   fem_engines_pkg.tech_message (
             p_severity  => g_log_level_1
	    ,p_module    => g_block||'.'||l_api_name||'.Begin'
            ,p_msg_text => 'Dimension'||p_dimension_varchar_label);


   IF p_dimension_varchar_label = 'ACTIVITY' THEN

    FOR l_inv_act_dim_column_rec IN l_inv_act_dim_column_cur LOOP

      -- If a record is returned in the l_inv_act_dim_column_cur, then that
      -- component dimension is not part of the table's processing key.

      x_return_status := c_error;

      FND_MESSAGE.set_name('FEM', 'FEM_COMP_ENG_PROCESS_KEY_ERROR');
      FND_MESSAGE.set_token('DIMENSION',
        FEM_DIMENSION_UTIL_PKG.Get_Dimension_Name(p_dimension_varchar_label));
      FND_MESSAGE.set_token('TABLE', p_table_name);
      FND_MESSAGE.set_token('COLUMN_NAME',
                           l_inv_act_dim_column_rec.column_name);
      FND_MSG_PUB.Add;

    END LOOP;

   ELSIF p_dimension_varchar_label = 'COST_OBJECT' THEN

    FOR l_inv_co_dim_column_rec IN l_inv_co_dim_column_cur LOOP

      -- If a record is returned in the l_inv_co_dim_column_cur, then that
      -- component dimension is not part of the table's processing key.

      x_return_status := c_error;

      FND_MESSAGE.set_name('FEM', 'FEM_COMP_ENG_PROCESS_KEY_ERROR');
      FND_MESSAGE.set_token('DIMENSION',
        FEM_DIMENSION_UTIL_PKG.Get_Dimension_Name(p_dimension_varchar_label));
      FND_MESSAGE.set_token('TABLE', p_table_name);
      FND_MESSAGE.set_token('COLUMN_NAME',
                           l_inv_co_dim_column_rec.column_name);
      FND_MSG_PUB.Add;

    END LOOP;

   END IF;

   FND_MSG_PUB.Count_And_Get(
    p_count   => x_msg_count
    ,p_data   => x_msg_data);

   fem_engines_pkg.tech_message (
             p_severity  => g_log_level_1
	    ,p_module    => g_block||'.'||l_api_name||'.End'
            ,p_msg_text => 'Dimension'||p_dimension_varchar_label);

 EXCEPTION

   WHEN OTHERS THEN
    x_return_status := c_error;

    FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count
      ,p_data   => x_msg_data );

   fem_engines_pkg.tech_message (
             p_severity  => g_log_level_4
	    ,p_module    => g_block||'.'||l_api_name||'.Exception'
            ,p_msg_text => 'Dimension'||p_dimension_varchar_label);

 END validate_proc_key;

 /*===========================================================================+
 | PROCEDURE
 |            delete_flexfield
 |
 | DESCRIPTION
 |
 |             This procedure is used to delete the flex field structure which
 |  was created after freezing the FF definition.
 |
 |
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  :
 |
 | p_dimension_varchar_label - ACTIVITY/COST_OBJECT
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 |  18-May-06     sshanmug          Bug:5224927: Flexfield Delete
 |                                  API for EPF Refresh Engine.
 |
 +===========================================================================*/


 PROCEDURE delete_flexfield(p_api_version   IN  NUMBER,
                      p_init_msg_list IN  VARCHAR2,
                      p_commit        IN  VARCHAR2,
                      p_encoded       IN  VARCHAR2,
                      x_return_status OUT NOCOPY VARCHAR2,
                      x_msg_count     OUT NOCOPY NUMBER,
                      x_msg_data      OUT NOCOPY VARCHAR2,
                      p_dimension_varchar_label IN VARCHAR2)

AS

   l_api_version       NUMBER;
   l_init_msg_list     VARCHAR2(1);
   l_commit            VARCHAR2(1);
   l_encoded           VARCHAR2(1);

   l_api_name          CONSTANT VARCHAR2(30) := 'delete_flexfield';

BEGIN

  ----------------------------------------------------------------
  --Initialize API call
  ----------------------------------------------------------------

  l_api_version   := NVL(p_api_version, c_api_version);
  l_init_msg_list := NVL(p_init_msg_list, c_false);
  l_commit        := NVL(p_commit, c_false);
  l_encoded       := NVL(p_encoded, c_true);

  -- Standard call to check for call compatibility

  IF NOT FND_API.Compatible_API_Call (
    p_current_version_number => l_api_version
    ,p_caller_version_number => p_api_version
    ,p_api_name              => l_api_name
    ,p_pkg_name              => 'fem_setup_pkg'
    ) THEN

    raise FND_API.G_EXC_UNEXPECTED_ERROR;

  END IF;

  -- Initialize Message Stack on FND_MSG_PUB

  IF(FND_API.To_Boolean(p_init_msg_list)) THEN

    FND_MSG_PUB.Initialize;

  END IF;

  -- Initialize the OUT parameter

  x_return_status := c_success;

  fem_engines_pkg.tech_message (
             p_severity  => g_log_level_1
            ,p_module    => g_block||'.'||l_api_name||'.Begin'
            ,p_msg_text => 'Dimension'||p_dimension_varchar_label);

  -- If the set_session_mode is not used, handle to FF and structure returns NULL

  fnd_flex_key_api.set_session_mode('customer_data');

  ----------------------------------------------------------------
  -- Delete the Flexfield
  ----------------------------------------------------------------

  IF p_dimension_varchar_label = 'ACTIVITY' THEN

    fem_engines_pkg.tech_message (p_severity  => g_log_level_1
                                  ,p_module   => g_block||'.'||l_api_name
                                  ,p_msg_text => 'Deleting FF');

    fnd_flex_key_api.delete_flexfield('FEM','FEAC');

  ELSE              -- DIMENSION IS COST OBJECT

    fem_engines_pkg.tech_message (p_severity  => g_log_level_1
                                  ,p_module   => g_block||'.'||l_api_name
                                  ,p_msg_text => 'Deleting FF');

    fnd_flex_key_api.delete_flexfield('FEM','FECO');

  END IF;

  -----------------------
  -- Finalize API Call --
  -----------------------

  -- Standard check of p_commit

  IF FND_API.To_Boolean(p_commit) THEN

    commit work;

  END IF;

  -- Standard call to get message count and if count is 1, get message info

  FND_MSG_PUB.Count_And_Get (
    p_count => x_msg_count
    ,p_data => x_msg_data
  );

  fem_engines_pkg.tech_message (p_severity  => g_log_level_1
                                  ,p_module   => g_block||'.'||l_api_name
                                  ,p_msg_text => 'End');

EXCEPTION

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

  x_return_status := c_error;

  fem_engines_pkg.tech_message (p_severity  => g_log_level_4
                                ,p_module   => g_block||'.'||l_api_name
                                ,p_msg_text => 'Exception');

  FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count
      ,p_data   => x_msg_data   );


WHEN OTHERS THEN

  x_return_status := c_error;

  fem_engines_pkg.tech_message (p_severity  => g_log_level_4
                                ,p_module   => g_block||'.'||l_api_name
                                ,p_msg_text => 'Exception');

  FND_MSG_PUB.Count_And_Get (p_encoded => p_encoded,
                             p_count => x_msg_count,
                             p_data => x_msg_data);

END delete_flexfield;

END fem_setup_pkg;

/
