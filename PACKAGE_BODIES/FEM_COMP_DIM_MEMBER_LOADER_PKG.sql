--------------------------------------------------------
--  DDL for Package Body FEM_COMP_DIM_MEMBER_LOADER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_COMP_DIM_MEMBER_LOADER_PKG" AS
/* $Header: femcompdimldrb.plb 120.6 2006/09/08 14:29:01 navekuma noship $ */


PROCEDURE Pre_Process (x_pre_process_status OUT NOCOPY VARCHAR2
                       ,p_execution_mode IN VARCHAR2
                       ,p_dimension_varchar_label IN VARCHAR2);

PROCEDURE Get_Display_Codes (p_dimension_varchar_label IN VARCHAR2,
                             p_structure_id            IN NUMBER);

PROCEDURE Metadata_Initialize(p_dimension_varchar_label IN VARCHAR2);



/*===========================================================================
|     This Procedure is to intialize the TABLE TYPE variable which stores
|     the flex field information of the Activity and Cost Objects
|
|
|     The TABLE TYPE variable holds the following values for each
|     component Dimension
|
|       ATTRIBUTE                      VALUE
|
|       dimension_varchar_label         Component Dimension varchar label
|       dimension_id                    -999
|       member_col                      null
|       member_display_code_col         null
|       member_b_table_name             null
|       value_set_required_flag         null
|       member_sql                      null
|
|
|     PARAMETER INFORMATION
|
|     p_dimension_varchar_label     The Varchar Label of Composite Dimension
|
|     MODIFICATION HISTORY
|      sshanmug     11-May-05       Created.
|
============================================================================*/

  PROCEDURE Metadata_Initialize(p_dimension_varchar_label IN VARCHAR2)

    IS

    c_proc_name CONSTANT VARCHAR2(20) := 'Metadata_Initialize';
    i NUMBER; -- counting variable for no:of segments of Flex Field

    BEGIN

     fem_engines_pkg.tech_message (
             p_severity  => c_log_level_1
	         ,p_module   => c_block||'.'||c_proc_name||'.Begin'
             ,p_msg_text => 'Dimension'||p_dimension_varchar_label);

    ----------------------------------------------------------------------------
    --Clean the previous Values
    ----------------------------------------------------------------------------

     t_component_dim_dc.DELETE;

    ----------------------------------------------------------------------------
    -- "t_component_dim_dc" is a TABLE TYPE which holds the display code
    -- values of all the component dimension members of Activity/Cost Object
    ----------------------------------------------------------------------------

	 IF p_dimension_varchar_label = 'COST_OBJECT' THEN

      t_component_dim_dc(1)  := 'FINANCIAL_ELEM_DISPLAY_CODE';
      t_component_dim_dc(2)  := 'LEDGER_DISPLAY_CODE';
      t_component_dim_dc(3)  := 'PRODUCT_DISPLAY_CODE';
      t_component_dim_dc(4)  := 'CCTR_ORG_DISPLAY_CODE';
      t_component_dim_dc(5)  := 'CUSTOMER_DISPLAY_CODE';
      t_component_dim_dc(6)  := 'CHANNEL_DISPLAY_CODE';
      t_component_dim_dc(7)  := 'PROJECT_DISPLAY_CODE';
      t_component_dim_dc(8)  := 'USER_DIM1_DISPLAY_CODE';
      t_component_dim_dc(9)  := 'USER_DIM2_DISPLAY_CODE';
      t_component_dim_dc(10) := 'USER_DIM3_DISPLAY_CODE';
      t_component_dim_dc(11) := 'USER_DIM4_DISPLAY_CODE';
      t_component_dim_dc(12) := 'USER_DIM5_DISPLAY_CODE';
      t_component_dim_dc(13) := 'USER_DIM6_DISPLAY_CODE';
      t_component_dim_dc(14) := 'USER_DIM7_DISPLAY_CODE';
      t_component_dim_dc(15) := 'USER_DIM8_DISPLAY_CODE';
      t_component_dim_dc(16) := 'USER_DIM9_DISPLAY_CODE';
      t_component_dim_dc(17) := 'USER_DIM10_DISPLAY_CODE';

	  --------------------------------------------------------------------------
	  --As per Cost Object HLD, the Cost Object FF can have 17 segments and
	  --hence initializing it to 17
	  --------------------------------------------------------------------------
	  i := 17;


     ELSIF p_dimension_varchar_label = 'ACTIVITY' THEN

      t_component_dim_dc(1)  := 'TASK_DISPLAY_CODE';
      t_component_dim_dc(2)  := 'CCTR_ORG_DISPLAY_CODE';
      t_component_dim_dc(3)  := 'CUSTOMER_DISPLAY_CODE';
      t_component_dim_dc(4)  := 'CHANNEL_DISPLAY_CODE';
      t_component_dim_dc(5)  := 'PRODUCT_DISPLAY_CODE';
      t_component_dim_dc(6)  := 'PROJECT_DISPLAY_CODE';
      t_component_dim_dc(7)  := 'USER_DIM1_DISPLAY_CODE';
      t_component_dim_dc(8)  := 'USER_DIM2_DISPLAY_CODE';
      t_component_dim_dc(9)  := 'USER_DIM3_DISPLAY_CODE';
      t_component_dim_dc(10) := 'USER_DIM4_DISPLAY_CODE';
      t_component_dim_dc(11) := 'USER_DIM5_DISPLAY_CODE';
      t_component_dim_dc(12) := 'USER_DIM6_DISPLAY_CODE';
      t_component_dim_dc(13) := 'USER_DIM7_DISPLAY_CODE';
      t_component_dim_dc(14) := 'USER_DIM8_DISPLAY_CODE';
      t_component_dim_dc(15) := 'USER_DIM9_DISPLAY_CODE';
      t_component_dim_dc(16) := 'USER_DIM10_DISPLAY_CODE';

	  --------------------------------------------------------------------------
	  --As per Activity HLD, the Cost Object FF can have 16 segments and
	  --hence initializing it to 16
	  --------------------------------------------------------------------------
       i := 16;

     END IF;

     ---------------------------------------------------------------------------
     --Initialize the TABLE TYPE variable 't_metadata' with default values.
     ---------------------------------------------------------------------------

    FOR j IN 1 .. i LOOP

         t_metadata(j).dimension_varchar_label := NULL;
         t_metadata(j).member_display_code_col := t_component_dim_dc(j);
         t_metadata(j).dimension_id := -999;
         t_metadata(j).member_col := NULL;
         t_metadata(j).member_b_table_name := NULL;
         t_metadata(j).value_set_required_flag := NULL;
         t_metadata(j).member_sql := NULL;

     END LOOP;

	 fem_engines_pkg.tech_message (
             p_severity  => c_log_level_1
	         ,p_module   => c_block||'.'||c_proc_name||'.End'
             ,p_msg_text => 'Dimension'||p_dimension_varchar_label);

     EXCEPTION

     WHEN others THEN

      fem_engines_pkg.tech_message (
             p_severity  => c_log_level_4
	         ,p_module   => c_block||'.'||c_proc_name||'.Exception'
             ,p_msg_text => 'Dimension'||p_dimension_varchar_label||
							'Code'||SQLCODE||'Err'||SQLERRM);

      RAISE e_terminate;

    END Metadata_Initialize;


/*===========================================================================+
 | PROCEDURE
 |              Get_Display_Code
 |
 | DESCRIPTION
 |    This procedure concatenates the individual component dimension members
 |   of the Composite Dimensions(Activity and Cost Objects).
 |
 |     The component dimension members are concatenated to form a
 |   single Composite Dimension Member.The component dimension members
 |   are separated by the delimiter of the corresponding flex filed.
 |
 |ARGUMENTS  : IN:
 |
 |  p_dimension_varchar_label - Composite Dimension Name
 |  p_structure_id            - FF structure Code
 |
 | MODIFICATION HISTORY
 |    Aturlapa     06-APR-05  Created
 |    sshanmug     11-May-05  Generalised the common piece of code both AC/CO.
 +===========================================================================*/

  PROCEDURE Get_Display_Codes (p_dimension_varchar_label IN VARCHAR2,
                               p_structure_id            IN NUMBER)

   IS

     c_proc_name CONSTANT VARCHAR2(20) := 'Get_Display_Codes';

     -- FF Details
     l_segment_delimiter VARCHAR2(1);
     p_ff_code_activity  VARCHAR2(4) := 'FEAC';
     p_ff_code_cost VARCHAR2(4) := 'FECO';

     --Counting Variable
     v_last_row NUMBER;

   BEGIN

    fem_engines_pkg.tech_message (
             p_severity  => c_log_level_1
	         ,p_module   => c_block||'.'||c_proc_name||'.Begin'
             ,p_msg_text => 'Dimension'||p_dimension_varchar_label);

    ----------------------------------------------------------------------------
    --Get the count of records in the interface table (this fetch)
    ----------------------------------------------------------------------------

    v_last_row := t_status.COUNT;

    ----------------------------------------------------------------------------
    --Clean the previous Values
    ----------------------------------------------------------------------------

    t_display_code.DELETE;

    ----------------------------------------------------------------------------
    --Get the segment delimiter
    ----------------------------------------------------------------------------

    IF p_dimension_varchar_label = 'COST_OBJECT' THEN

	  l_segment_delimiter := FND_FLEX_EXT.GET_DELIMITER('FEM',p_ff_code_cost,
                                                    p_structure_id);
    ELSIF p_dimension_varchar_label = 'ACTIVITY' THEN

	  l_segment_delimiter := FND_FLEX_EXT.GET_DELIMITER('FEM',p_ff_code_activity,
                                                    p_structure_id);
    END IF;



    FOR i IN 1..v_last_row LOOP

      --------------------------------------------------------------------------
      -- Concatenate only rows with STATUS = 'LOAD'
      --------------------------------------------------------------------------

      IF t_status(i) = 'LOAD' THEN

        IF p_dimension_varchar_label = 'COST_OBJECT' THEN

          ----------------------------------------------------------------------
          --Fin Elem and Ledger are mandatory for CO hence it is concatenated
          ----------------------------------------------------------------------

          t_display_code(i) := t_fin_elem_dc(i) || l_segment_delimiter;
          t_display_code(i) := t_display_code(i) || t_ledger_dc(i);

          ----------------------------------------------------------------------
          --Concatenate other segments only if they are not null.
          ----------------------------------------------------------------------

          IF t_product_dc(i) IS NOT NULL THEN
          t_display_code(i) := t_display_code(i) ||
                             l_segment_delimiter||t_product_dc(i);
          END IF;
          IF t_cctr_org_dc(i) IS NOT NULL THEN
          t_display_code(i) := t_display_code(i) ||
                             l_segment_delimiter||t_cctr_org_dc(i);
          END IF;
          IF t_customer_dc(i) IS NOT NULL THEN
          t_display_code(i) := t_display_code(i) ||
                             l_segment_delimiter||t_customer_dc(i);
          END IF;
		  IF t_channel_dc(i) IS NOT NULL THEN
          t_display_code(i) := t_display_code(i) ||
                             l_segment_delimiter||t_channel_dc(i);
          END IF;
          IF t_project_dc(i) IS NOT NULL THEN
          t_display_code(i) := t_display_code(i) ||
                             l_segment_delimiter||t_project_dc(i);
          END IF;

        ELSIF p_dimension_varchar_label = 'ACTIVITY' THEN

          ----------------------------------------------------------------------
          --Task is mandatory for Activity hence it is concatenated
          ----------------------------------------------------------------------

          t_display_code(i) := t_task_dc(i);

         -----------------------------------------------------------------------
         --Concatenate other segments only if they are not null.
         -----------------------------------------------------------------------

         IF t_cctr_org_dc(i) IS NOT NULL THEN
            t_display_code(i) := t_display_code(i) ||
                             l_segment_delimiter||t_cctr_org_dc(i);
         END IF;
         IF t_customer_dc(i) IS NOT NULL THEN
            t_display_code(i) := t_display_code(i) ||
                             l_segment_delimiter||t_customer_dc(i);
         END IF;
         IF t_channel_dc(i) IS NOT NULL THEN
            t_display_code(i) := t_display_code(i) ||
                             l_segment_delimiter||t_channel_dc(i);
         END IF;
         IF t_product_dc(i) IS NOT NULL THEN
           t_display_code(i) := t_display_code(i) ||
                             l_segment_delimiter||t_product_dc(i);
         END IF;
         IF t_project_dc(i) IS NOT NULL THEN
            t_display_code(i) := t_display_code(i) ||
                             l_segment_delimiter||t_project_dc(i);
         END IF;

        END IF;

        ------------------------------------------------------------------------
        -- The following component Dimensions are common for both Activity and
        -- Cost Object. Hence it will be common code for both dimensions.
        ------------------------------------------------------------------------

         IF t_user_dim1_dc(i) IS NOT NULL THEN
            t_display_code(i) := t_display_code(i) ||
                             l_segment_delimiter||t_user_dim1_dc(i);
         END IF;
         IF t_user_dim2_dc(i) IS NOT NULL THEN
            t_display_code(i) := t_display_code(i) ||
                             l_segment_delimiter||t_user_dim2_dc(i);
         END IF;
         IF t_user_dim3_dc(i) IS NOT NULL THEN
            t_display_code(i) := t_display_code(i) ||
                             l_segment_delimiter||t_user_dim3_dc(i);
         END IF;
         IF t_user_dim4_dc(i) IS NOT NULL THEN
            t_display_code(i) := t_display_code(i) ||
                             l_segment_delimiter||t_user_dim4_dc(i);
         END IF;
         IF t_user_dim5_dc(i) IS NOT NULL THEN
            t_display_code(i) := t_display_code(i) ||
                             l_segment_delimiter||t_user_dim5_dc(i);
         END IF;
         IF t_user_dim6_dc(i) IS NOT NULL THEN
           t_display_code(i) := t_display_code(i) ||
                               l_segment_delimiter||t_user_dim6_dc(i);
         END IF;
         IF t_user_dim7_dc(i) IS NOT NULL THEN
             t_display_code(i) := t_display_code(i) ||
                             l_segment_delimiter||t_user_dim7_dc(i);
         END IF;
         IF t_user_dim8_dc(i) IS NOT NULL THEN
           t_display_code(i) := t_display_code(i) ||
                             l_segment_delimiter||t_user_dim8_dc(i);
         END IF;
         IF t_user_dim9_dc(i) IS NOT NULL THEN
            t_display_code(i) := t_display_code(i) ||
                             l_segment_delimiter||t_user_dim9_dc(i);
         END IF;
         IF t_user_dim10_dc(i) IS NOT NULL THEN
            t_display_code(i) := t_display_code(i) ||
                             l_segment_delimiter||t_user_dim10_dc(i);
         END IF;

      ELSE

       t_display_code(i) := NULL;

      END IF; -- STATUS = 'LOAD'

    END LOOP;

   -----------------------------------------------------------------------------
   ---End Concatenate the segments
   -----------------------------------------------------------------------------

       fem_engines_pkg.tech_message (
             p_severity  => c_log_level_1
	         ,p_module   => c_block||'.'||c_proc_name||'.End'
             ,p_msg_text => 'Dimension'||p_dimension_varchar_label);

  EXCEPTION

    WHEN others THEN
      fem_engines_pkg.tech_message (
             p_severity  => c_log_level_4
	         ,p_module   => c_block||'.'||c_proc_name||'.Exception'
             ,p_msg_text => 'Dimension'||p_dimension_varchar_label||
							'Code'||SQLCODE||'Err'||SQLERRM);

      RAISE e_terminate;

  END Get_Display_Codes;

/*===========================================================================+
 | PROCEDURE
 |              pre_process
 |
 | DESCRIPTION
 |
 |     This Procedure is used to get the flexfield information of the composite
 | Dimensions (Activity and Cost Object).It populates the component dimension
 | information into a TABLE TYPE variable.
 |
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |
 |              p_execution_mode - 'S'(Snapshot) / 'E'(Error Reprocessing) Mode.
 |              p_dimension_varchar_label - Indicates the Dimension
 |
 |              OUT:
 |
 |              x_pre_process_status - Status of the Procedure.
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 |    Aturlapa        31-MAR-05  Created
 |    sshanmug        10-May-05  Incorporated the comments from Nico.
 +===========================================================================*/

  PROCEDURE Pre_Process (x_pre_process_status OUT NOCOPY VARCHAR2
                         ,p_execution_mode IN VARCHAR2
                         ,p_dimension_varchar_label IN VARCHAR2)
   IS

   c_proc_name CONSTANT varchar2(20) := 'Pre_Process';

   -- variable to get the status of AC/CO FF Definition.
   l_dim_active_flag VARCHAR2(1);

   BEGIN

     -- Initialize the return status
     x_pre_process_status := 'SUCCESS';

     fem_engines_pkg.tech_message (
             p_severity  => c_log_level_1
	         ,p_module   => c_block||'.'||c_proc_name||'.Begin'
             ,p_msg_text => 'Mode'||p_execution_mode
			                      ||'Dimension'||p_dimension_varchar_label);

     --------------------------------------------------------------------------
     -- Check whether the AC/CO structure is defined or not
     -- Raise the Exception if the AC / CO Structure is not freezed.
     --------------------------------------------------------------------------
     BEGIN

       SELECT dimension_active_flag
       INTO l_dim_active_flag
       FROM Fem_Xdim_Dimensions_VL
       WHERE dimension_varchar_label = p_dimension_varchar_label;

     EXCEPTION

	   WHEN no_data_found THEN
	     fem_engines_pkg.tech_message (
             p_severity  => c_log_level_4
	         ,p_module   => c_block||'.'||c_proc_name||'.Freeze_Exception'
             ,p_msg_text => 'Dimension'||p_dimension_varchar_label||
							'Code'||SQLCODE||'Err'||SQLERRM);
     END;

     IF l_dim_active_flag = 'N' THEN

	   fem_engines_pkg.tech_message (
             p_severity  => c_log_level_5
	         ,p_module   => c_block||'.'||c_proc_name
             ,p_msg_text => 'Dimension'||p_dimension_varchar_label||' Flex Field
			  Definition Not Freezed');

	   RAISE e_no_structure_defined;
     END IF;

     ---------------------------------------------------------------------------
     --Clean up the MetaData Variable
     ---------------------------------------------------------------------------

     t_metadata.DELETE;

     ---------------------------------------------------------------------------
     --Initialize the TABLE TYPE Variable which holds the metadata information
     ---------------------------------------------------------------------------
     Metadata_Initialize(p_dimension_varchar_label);

     fem_engines_pkg.tech_message (
             p_severity  => c_log_level_1
	         ,p_module   => c_block||'.'||c_proc_name
             ,p_msg_text => 'After Metadata_Initialize');

     IF p_dimension_varchar_label = 'COST_OBJECT' THEN

	  -------------------------------------------------------------------------
       --This loop runs for all the component Dimension members of
       --the Cost Object Dimension and populates their details into
       --'t_metadata' variable
       -------------------------------------------------------------------------

       FOR c_metadata_cost IN (
          SELECT x.dimension_id
          ,x.member_col
          ,x.member_display_code_col
          ,x.member_b_table_name
          ,x.value_set_required_flag
          FROM FEM_COLUMN_REQUIREMNT_B c
          ,FEM_XDIM_DIMENSIONS x
          WHERE c.dimension_id = x.dimension_id
          AND c.cost_obj_dim_component_flag = 'Y'
          ORDER BY 1 )
          LOOP
            FOR i IN 1 .. t_metadata.COUNT LOOP
       	    IF c_metadata_cost.member_display_code_col = t_component_dim_dc(i) THEN
              t_metadata(i).dimension_id := c_metadata_cost.dimension_id;
              t_metadata(i).dimension_varchar_label := CASE t_component_dim_dc(i)
                                          WHEN 'FINANCIAL_ELEM_DISPLAY_CODE' THEN 'FINANCIAL_ELEMENT'
                                          WHEN 'LEDGER_DISPLAY_CODE'         THEN 'LEDGER'
                                          WHEN 'PRODUCT_DISPLAY_CODE'        THEN 'PRODUCT'
                                          WHEN 'CCTR_ORG_DISPLAY_CODE'       THEN 'COMPANY_COST_CENTER_ORG'
                                          WHEN 'CUSTOMER_DISPLAY_CODE'       THEN 'CUSTOMER'
                                          WHEN 'CHANNEL_DISPLAY_CODE'        THEN 'CHANNEL'
                                          WHEN 'PROJECT_DISPLAY_CODE'        THEN 'PROJECT'
                                          WHEN 'USER_DIM1_DISPLAY_CODE'      THEN 'USER_DIM1'
                                          WHEN 'USER_DIM2_DISPLAY_CODE'      THEN 'USER_DIM2'
                                          WHEN 'USER_DIM3_DISPLAY_CODE'      THEN 'USER_DIM3'
                                          WHEN 'USER_DIM4_DISPLAY_CODE'      THEN 'USER_DIM4'
                                          WHEN 'USER_DIM5_DISPLAY_CODE'      THEN 'USER_DIM5'
                                          WHEN 'USER_DIM6_DISPLAY_CODE'      THEN 'USER_DIM6'
                                          WHEN 'USER_DIM7_DISPLAY_CODE'      THEN 'USER_DIM7'
                                          WHEN 'USER_DIM8_DISPLAY_CODE'      THEN 'USER_DIM8'
                                          WHEN 'USER_DIM9_DISPLAY_CODE'      THEN 'USER_DIM9'
                                          WHEN 'USER_DIM10_DISPLAY_CODE'     THEN 'USER_DIM10'
                                          ELSE NULL
                                        END;
              t_metadata(i).member_col := c_metadata_cost.member_col;
              t_metadata(i).member_b_table_name :=
                                            c_metadata_cost.member_b_table_name;
              t_metadata(i).value_set_required_flag :=
                              c_metadata_cost.value_set_required_flag;
              t_metadata(i).member_sql :=
              ' SELECT '||c_metadata_cost.member_col||
              ' FROM '||c_metadata_cost.member_b_table_name||
              ' WHERE enabled_flag = ''Y'''||
              ' AND '||c_metadata_cost.member_display_code_col||' = :b_dc_val';

              IF (c_metadata_cost.value_set_required_flag = 'Y') THEN
                t_metadata(i).member_sql := t_metadata(i).member_sql||
				                         ' AND value_set_id = :b_value_set_id';
              END IF;
       	    END IF;
            END LOOP;
          END LOOP;

        -------------------------------------------------------------------------
        -- Build Engine SQL --
        -------------------------------------------------------------------------

        g_select_statement :=
         'SELECT b.rowid,'||
         ' GLOBAL_VS_COMBO_DISPLAY_CODE,'||
         ' financial_elem_display_code,'||
         ' ledger_display_code,'||
         ' product_display_code,'||
         ' CCTR_ORG_DISPLAY_CODE,'||
         ' customer_display_code,'||
         ' channel_display_code,'||
         ' project_display_code,'||
         ' user_dim1_display_code,'||
         ' user_dim2_display_code,'||
         ' user_dim3_display_code,'||
         ' user_dim4_display_code,'||
         ' user_dim5_display_code,'||
         ' user_dim6_display_code,'||
         ' user_dim7_display_code,'||
         ' user_dim8_display_code,'||
         ' user_dim9_display_code,'||
         ' user_dim10_display_code,'||
         ' status'||
         ' FROM FEM_COST_OBJECTS_T B'||
         ' WHERE {{data_slice}} ';

     ELSIF p_dimension_varchar_label = 'ACTIVITY' THEN

       -------------------------------------------------------------------------
       --Initialize the TABLE TYPE Variable which holds the metadata information
       -------------------------------------------------------------------------

       Metadata_Initialize(p_dimension_varchar_label);

       -------------------------------------------------------------------------
       --Thid loop runs for all the component Dimension members of
       --the Activity Dimension and populates their details into
       --'t_metadata' variable
       -------------------------------------------------------------------------

       FOR c_metadata_activity IN (
         SELECT x.dimension_id
         ,x.member_col
         ,x.member_display_code_col
         ,x.member_b_table_name
         ,x.value_set_required_flag
         FROM FEM_COLUMN_REQUIREMNT_B c
         ,FEM_XDIM_DIMENSIONS x
         WHERE c.dimension_id = x.dimension_id
         AND c.activity_dim_component_flag = 'Y'
         ORDER BY 1 )
        LOOP
           FOR i IN 1 .. t_metadata.COUNT LOOP
             IF c_metadata_activity.member_display_code_col
			                                       = t_component_dim_dc(i) THEN
             t_metadata(i).dimension_id := c_metadata_activity.dimension_id;
             t_metadata(i).dimension_varchar_label := CASE t_component_dim_dc(i)
                                          WHEN 'TASK_DISPLAY_CODE'           THEN 'TASK'
                                          WHEN 'CCTR_ORG_DISPLAY_CODE'       THEN 'COMPANY_COST_CENTER_ORG'
                                          WHEN 'CUSTOMER_DISPLAY_CODE'       THEN 'CUSTOMER'
                                          WHEN 'CHANNEL_DISPLAY_CODE'        THEN 'CHANNEL'
                                          WHEN 'PRODUCT_DISPLAY_CODE'        THEN 'PRODUCT'
                                          WHEN 'PROJECT_DISPLAY_CODE'        THEN 'PROJECT'
                                          WHEN 'USER_DIM1_DISPLAY_CODE'      THEN 'USER_DIM1'
                                          WHEN 'USER_DIM2_DISPLAY_CODE'      THEN 'USER_DIM2'
                                          WHEN 'USER_DIM3_DISPLAY_CODE'      THEN 'USER_DIM3'
                                          WHEN 'USER_DIM4_DISPLAY_CODE'      THEN 'USER_DIM4'
                                          WHEN 'USER_DIM5_DISPLAY_CODE'      THEN 'USER_DIM5'
                                          WHEN 'USER_DIM6_DISPLAY_CODE'      THEN 'USER_DIM6'
                                          WHEN 'USER_DIM7_DISPLAY_CODE'      THEN 'USER_DIM7'
                                          WHEN 'USER_DIM8_DISPLAY_CODE'      THEN 'USER_DIM8'
                                          WHEN 'USER_DIM9_DISPLAY_CODE'      THEN 'USER_DIM9'
                                          WHEN 'USER_DIM10_DISPLAY_CODE'     THEN 'USER_DIM10'
                                          ELSE NULL
                                        END;
             t_metadata(i).member_col := c_metadata_activity.member_col;
             t_metadata(i).member_b_table_name :=
                                      c_metadata_activity.member_b_table_name;
             t_metadata(i).value_set_required_flag :=
                                    c_metadata_activity.value_set_required_flag;
             t_metadata(i).member_sql :=
             ' SELECT '||c_metadata_activity.member_col||
             ' FROM '||c_metadata_activity.member_b_table_name||
             ' WHERE enabled_flag = ''Y'''||
             ' AND '||c_metadata_activity.member_display_code_col||' = :b_dc_val';

               IF (c_metadata_activity.value_set_required_flag = 'Y') THEN
                 t_metadata(i).member_sql := t_metadata(i).member_sql||
				                          ' AND value_set_id = :b_value_set_id';
               END IF;
             END IF;
           END LOOP;
         END LOOP;

       -------------------------------------------------------------------------
       -- Build Engine SQL --
       -------------------------------------------------------------------------

       g_select_statement :=
         'SELECT b.rowid,'||
         ' GLOBAL_VS_COMBO_DISPLAY_CODE,'||
         ' TASK_DISPLAY_CODE,'||
         ' CCTR_ORG_DISPLAY_CODE,'||
         ' customer_display_code,'||
         ' channel_display_code,'||
         ' product_display_code,'||
         ' project_display_code,'||
         ' user_dim1_display_code,'||
         ' user_dim2_display_code,'||
         ' user_dim3_display_code,'||
         ' user_dim4_display_code,'||
         ' user_dim5_display_code,'||
         ' user_dim6_display_code,'||
         ' user_dim7_display_code,'||
         ' user_dim8_display_code,'||
         ' user_dim9_display_code,'||
         ' user_dim10_display_code,'||
         ' status'||
         ' FROM FEM_ACTIVITIES_T B'||
         ' WHERE {{data_slice}} ';
	 END IF;

	 --Need to confirm with Nico
   /*  IF (p_execution_mode = 'S') THEN
      g_select_statement := g_select_statement||' AND status = ''LOAD''';
     END IF; */

     fem_engines_pkg.tech_message (
       p_severity  => c_log_level_1
	   ,p_module   => c_block||'.'||c_proc_name||'.End'
       ,p_msg_text => 'Mode'||p_execution_mode
	                     ||'Dimension'||p_dimension_varchar_label);

   EXCEPTION

     WHEN e_no_structure_defined THEN

       fem_engines_pkg.tech_message (
          p_severity => c_log_level_4
          ,p_module => c_block||'.'||c_proc_name||'.Exception'
          ,p_app_name => c_fem
          ,p_msg_name => G_NO_STRUCTURE_DEFINED
          ,P_TOKEN1 => 'OPERATION'
          ,P_VALUE1 => p_dimension_varchar_label);

       x_pre_process_status := 'ERROR';

      WHEN others THEN

       fem_engines_pkg.tech_message (
             p_severity  => c_log_level_4
	         ,p_module   => c_block||'.'||c_proc_name||'.Exception'
             ,p_msg_text => 'Mode'||p_execution_mode||
                            'Dimension'||p_dimension_varchar_label||
							'Code'||SQLCODE||'Err'||SQLERRM);

       x_pre_process_status := 'ERROR';

   END Pre_Process;

 /*===========================================================================+
 | PROCEDURE
 |              process_rows
 |
 | DESCRIPTION
 |
 |             This procedure is used to process all the rows in the interface
 |  table of composite dimensions (FEM_ACTIVITIES_T/FEM_COST_OBJECTS_T) and
 |  performs various validations on these records,concatenate the component
 |  dimension members and inserts only the valid records into the member table
 |  of Composite Dimensions.The invalid records will be processed in
 |  'Error Reproceesing' Mode.
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
 |    Aturlapa    31-MAR-05  Created
 |    sshanmug    17-MAY-05  Incorporated comments from Nico
 |    sshanmug    09-Jun-05  Changed the signature of the Process_Rows as
 |                           per 'Bind Variable Push MP Framework'
 |    navekuma    25-Apr-06  Bug#4736810 error counts not appearing in Concurrent Log.
 +===========================================================================*/

   PROCEDURE Process_Rows(p_eng_sql IN VARCHAR2
                      ,p_slc_pred IN VARCHAR2
                      ,p_proc_num IN VARCHAR2
                      ,p_part_code IN VARCHAR2
                      ,p_fetch_limit IN NUMBER
                      ,p_dimension_varchar_label IN VARCHAR2
                      ,p_execution_mode IN VARCHAR2
                      ,p_structure_id IN NUMBER
                      ,p_req_id IN NUMBER )
   IS

   c_proc_name CONSTANT VARCHAR2(20) := 'Process_Rows';

   lv_status VARCHAR2(200);

   v_fetch_limit NUMBER;
   v_rows_processed NUMBER :=0;  --Bug#4736810
   v_rows_rejected NUMBER :=0;
   v_rows_loaded NUMBER :=0;

   v_cost_object_dc FEM_COST_OBJECTS.cost_object_display_code%TYPE;
   v_activity_dc FEM_ACTIVITIES.activity_display_code%TYPE;

   v_cost_structure_id NUMBER;
   v_activity_structure_id NUMBER;

   v_select_stmt LONG;
   v_data_slc VARCHAR2(4000);

   v_update_stmt VARCHAR2(4000);
   v_delete_stmt VARCHAR2(4000);
   v_member_table_name VARCHAR2(200);

   v_CREATED_BY        NUMBER := fnd_global.user_id;
   v_LAST_UPDATED_BY   NUMBER := fnd_global.user_id;
   v_LAST_UPDATE_LOGIN NUMBER := fnd_global.login_id;

   v_last_row   NUMBER;
   v_mbr_last_row NUMBER;

   --Needed for Pre_Process
   x_pre_process_status VARCHAR2(30);

   -- Follwoing 3 params are needed for FEM_DIM_UTILS_PVT.Check_Unique_Member
   v_return_status  VARCHAR2(20);
   v_msg_count NUMBER;
   v_msg_data VARCHAR2(200);

   l_count NUMBER;-- var to keep track of invalid values for each validation
   l_validation_sql VARCHAR2(2000);
 -- MP variables
 	    v_loop_counter                    NUMBER;
 	    v_slc_id                          NUMBER;
 	    v_slc_val1                        VARCHAR2(100);
 	    v_slc_val2                        VARCHAR2(100);
 	    v_slc_val3                        VARCHAR2(100);
 	    v_slc_val4                        VARCHAR2(100);
 	    v_mp_status                       VARCHAR2(30);
 	    v_mp_message                      VARCHAR2(4000);
 	    v_num_vals                        NUMBER;
 	    v_part_name                       VARCHAR2(4000);
 	    p_part_name                       VARCHAR2(4000);
 	    v_status                          NUMBER;
 	    v_message                         VARCHAR2(4000);

  ----------------------------------------
  -- Ref cursors used in this Procedure --
  ----------------------------------------

  TYPE cv_curs IS REF CURSOR;
    cv_get_rows cv_curs;
    cv_get_invalid_fin_elems cv_curs;
    cv_get_invalid_ledgers cv_curs;
    cv_get_invalid_gvscs cv_curs;
    cv_get_invalid_comp_dims cv_curs;


  ------------------------------------------
  -- DML Statements used in the procedure --
  -------------------------------------------

   v_insert_cost_stmt CONSTANT LONG :=
   'INSERT INTO FEM_COST_OBJECTS ('||
   ' COST_OBJECT_ID, '||
   ' COST_OBJECT_DISPLAY_CODE, '||
   ' SUMMARY_FLAG, '||
   ' START_DATE_ACTIVE, '||
   ' END_DATE_ACTIVE, '||
   ' COST_OBJECT_STRUCTURE_ID, '||
   ' LOCAL_VS_COMBO_ID, '||
   ' UOM_CODE, '||
   ' FINANCIAL_ELEM_ID, '||
   ' LEDGER_ID, '||
   ' PRODUCT_ID, '||
   ' COMPANY_COST_CENTER_ORG_ID, '||
   ' CUSTOMER_ID, '||
   ' CHANNEL_ID, '||
   ' PROJECT_ID, '||
   ' USER_DIM1_ID, '||
   ' USER_DIM2_ID, '||
   ' USER_DIM3_ID, '||
   ' USER_DIM4_ID, '||
   ' USER_DIM5_ID, '||
   ' USER_DIM6_ID, '||
   ' USER_DIM7_ID, '||
   ' USER_DIM8_ID, '||
   ' USER_DIM9_ID, '||
   ' USER_DIM10_ID, '||
   ' SEGMENT1, '||
   ' SEGMENT2, '||
   ' SEGMENT3, '||
   ' SEGMENT4, '||
   ' SEGMENT5, '||
   ' SEGMENT6, '||
   ' SEGMENT7, '||
   ' SEGMENT8, '||
   ' SEGMENT9, '||
   ' SEGMENT10, '||
   ' SEGMENT11, '||
   ' SEGMENT12, '||
   ' SEGMENT13, '||
   ' SEGMENT14, '||
   ' SEGMENT15, '||
   ' SEGMENT16, '||
   ' SEGMENT17, '||
   ' SEGMENT18, '||
   ' SEGMENT19, '||
   ' SEGMENT20, '||
   ' SEGMENT21, '||
   ' SEGMENT22, '||
   ' SEGMENT23, '||
   ' SEGMENT24, '||
   ' SEGMENT25, '||
   ' SEGMENT26, '||
   ' SEGMENT27, '||
   ' SEGMENT28, '||
   ' SEGMENT29, '||
   ' SEGMENT30, '||
   ' CREATION_DATE, '||
   ' CREATED_BY, '||
   ' LAST_UPDATED_BY, '||
   ' LAST_UPDATE_DATE, '||
   ' LAST_UPDATE_LOGIN, '||
   ' OBJECT_VERSION_NUMBER, '||
   ' ENABLED_FLAG, '||
   ' PERSONAL_FLAG, '||
   ' READ_ONLY_FLAG )'||
   ' SELECT fem_cost_objects_s.nextval,'||
          ' :b_COST_OBJECT_DISPLAY_CODE, '||
          ' :b_SUMMARY_FLAG, '||
          ' :b_START_DATE_ACTIVE, '||
          ' :b_END_DATE_ACTIVE, '||
          ' :b_COST_OBJECT_STRUCTURE_ID, '||
          ' :b_LOCAL_VS_COMBO_ID, '||
          ' :b_UOM_CODE, '||
          ' :b_FINANCIAL_ELEM_ID, '||
          ' :b_LEDGER_ID, '||
          ' :b_PRODUCT_ID, '||
          ' :b_COMPANY_COST_CENTER_ORG_ID, '||
          ' :b_CUSTOMER_ID, '||
          ' :b_CHANNEL_ID, '||
          ' :b_PROJECT_ID, '||
          ' :b_USER_DIM1_ID, '||
          ' :b_USER_DIM2_ID, '||
          ' :b_USER_DIM3_ID, '||
          ' :b_USER_DIM4_ID, '||
          ' :b_USER_DIM5_ID, '||
          ' :b_USER_DIM6_ID, '||
          ' :b_USER_DIM7_ID, '||
          ' :b_USER_DIM8_ID, '||
          ' :b_USER_DIM9_ID, '||
          ' :b_USER_DIM10_ID, '||
          ' :b_SEGMENT1, '||
          ' :b_SEGMENT2, '||
          ' :b_SEGMENT3, '||
          ' :b_SEGMENT4, '||
          ' :b_SEGMENT5, '||
          ' :b_SEGMENT6, '||
          ' :b_SEGMENT7, '||
          ' :b_SEGMENT8, '||
          ' :b_SEGMENT9, '||
          ' :b_SEGMENT10, '||
          ' :b_SEGMENT11, '||
          ' :b_SEGMENT12, '||
          ' :b_SEGMENT13, '||
          ' :b_SEGMENT14, '||
          ' :b_SEGMENT15, '||
          ' :b_SEGMENT16, '||
          ' :b_SEGMENT17, '||
          ' :b_SEGMENT18, '||
          ' :b_SEGMENT19, '||
          ' :b_SEGMENT20, '||
          ' :b_SEGMENT21, '||
          ' :b_SEGMENT22, '||
          ' :b_SEGMENT23, '||
          ' :b_SEGMENT24, '||
          ' :b_SEGMENT25, '||
          ' :b_SEGMENT26, '||
          ' :b_SEGMENT27, '||
          ' :b_SEGMENT28, '||
          ' :b_SEGMENT29, '||
          ' :b_SEGMENT30, '||
          ' :b_CREATION_DATE, '||
          ' :b_CREATED_BY, '||
          ' :b_LAST_UPDATED_BY, '||
          ' :b_LAST_UPDATE_DATE, '||
          ' :b_LAST_UPDATE_LOGIN, '||
          ' :b_OBJECT_VERSION_NUMBER, '||
          ' :b_ENABLED_FLAG, '||
          ' :b_PERSONAL_FLAG, '||
          ' :b_read_only_flag '||
          ' FROM dual'||
          ' WHERE :b_status = ''LOAD''';

  v_insert_activity_stmt CONSTANT LONG :=
   'INSERT INTO FEM_ACTIVITIES ('||
   ' ACTIVITY_ID, '||
   ' ACTIVITY_DISPLAY_CODE, '||
   ' SUMMARY_FLAG, '||
   ' START_DATE_ACTIVE, '||
   ' END_DATE_ACTIVE, '||
   ' ACTIVITY_STRUCTURE_ID, '||
   ' LOCAL_VS_COMBO_ID, '||
   ' TASK_ID, '||
   ' COMPANY_COST_CENTER_ORG_ID, '||
   ' CUSTOMER_ID, '||
   ' CHANNEL_ID, '||
   ' PRODUCT_ID, '||
   ' PROJECT_ID, '||
   ' USER_DIM1_ID, '||
   ' USER_DIM2_ID, '||
   ' USER_DIM3_ID, '||
   ' USER_DIM4_ID, '||
   ' USER_DIM5_ID, '||
   ' USER_DIM6_ID, '||
   ' USER_DIM7_ID, '||
   ' USER_DIM8_ID, '||
   ' USER_DIM9_ID, '||
   ' USER_DIM10_ID, '||
   ' SEGMENT1, '||
   ' SEGMENT2, '||
   ' SEGMENT3, '||
   ' SEGMENT4, '||
   ' SEGMENT5, '||
   ' SEGMENT6, '||
   ' SEGMENT7, '||
   ' SEGMENT8, '||
   ' SEGMENT9, '||
   ' SEGMENT10, '||
   ' SEGMENT11, '||
   ' SEGMENT12, '||
   ' SEGMENT13, '||
   ' SEGMENT14, '||
   ' SEGMENT15, '||
   ' SEGMENT16, '||
   ' SEGMENT17, '||
   ' SEGMENT18, '||
   ' SEGMENT19, '||
   ' SEGMENT20, '||
   ' SEGMENT21, '||
   ' SEGMENT22, '||
   ' SEGMENT23, '||
   ' SEGMENT24, '||
   ' SEGMENT25, '||
   ' SEGMENT26, '||
   ' SEGMENT27, '||
   ' SEGMENT28, '||
   ' SEGMENT29, '||
   ' SEGMENT30, '||
   ' CREATION_DATE, '||
   ' CREATED_BY, '||
   ' LAST_UPDATED_BY, '||
   ' LAST_UPDATE_DATE, '||
   ' LAST_UPDATE_LOGIN, '||
   ' OBJECT_VERSION_NUMBER, '||
   ' ENABLED_FLAG, '||
   ' PERSONAL_FLAG, '||
   ' READ_ONLY_FLAG )'||
   ' SELECT fem_activities_s.nextval,'||
          ' :b_ACTIVITY_DISPLAY_CODE, '||
          ' :b_SUMMARY_FLAG, '||
          ' :b_START_DATE_ACTIVE, '||
          ' :b_END_DATE_ACTIVE, '||
          ' :b_ACTIVITY_STRUCTURE_ID, '||
          ' :b_LOCAL_VS_COMBO_ID, '||
          ' :b_TASK_ID, '||
          ' :b_COMPANY_COST_CENTER_ORG_ID, '||
          ' :b_CUSTOMER_ID, '||
          ' :b_CHANNEL_ID, '||
          ' :b_PRODUCT_ID, '||
          ' :b_PROJECT_ID, '||
          ' :b_USER_DIM1_ID, '||
          ' :b_USER_DIM2_ID, '||
          ' :b_USER_DIM3_ID, '||
          ' :b_USER_DIM4_ID, '||
          ' :b_USER_DIM5_ID, '||
          ' :b_USER_DIM6_ID, '||
          ' :b_USER_DIM7_ID, '||
          ' :b_USER_DIM8_ID, '||
          ' :b_USER_DIM9_ID, '||
          ' :b_USER_DIM10_ID, '||
          ' :b_SEGMENT1, '||
          ' :b_SEGMENT2, '||
          ' :b_SEGMENT3, '||
          ' :b_SEGMENT4, '||
          ' :b_SEGMENT5, '||
          ' :b_SEGMENT6, '||
          ' :b_SEGMENT7, '||
          ' :b_SEGMENT8, '||
          ' :b_SEGMENT9, '||
          ' :b_SEGMENT10, '||
          ' :b_SEGMENT11, '||
          ' :b_SEGMENT12, '||
          ' :b_SEGMENT13, '||
          ' :b_SEGMENT14, '||
          ' :b_SEGMENT15, '||
          ' :b_SEGMENT16, '||
          ' :b_SEGMENT17, '||
          ' :b_SEGMENT18, '||
          ' :b_SEGMENT19, '||
          ' :b_SEGMENT20, '||
          ' :b_SEGMENT21, '||
          ' :b_SEGMENT22, '||
          ' :b_SEGMENT23, '||
          ' :b_SEGMENT24, '||
          ' :b_SEGMENT25, '||
          ' :b_SEGMENT26, '||
          ' :b_SEGMENT27, '||
          ' :b_SEGMENT28, '||
          ' :b_SEGMENT29, '||
          ' :b_SEGMENT30, '||
          ' :b_CREATION_DATE, '||
          ' :b_CREATED_BY, '||
          ' :b_LAST_UPDATED_BY, '||
          ' :b_LAST_UPDATE_DATE, '||
          ' :b_LAST_UPDATE_LOGIN, '||
          ' :b_OBJECT_VERSION_NUMBER, '||
          ' :b_ENABLED_FLAG, '||
          ' :b_PERSONAL_FLAG, '||
          ' :b_read_only_flag '||
          ' FROM dual'||
          ' WHERE :b_status = ''LOAD''';

  v_update_cost_stmt CONSTANT VARCHAR2(4000) :=
  'UPDATE FEM_COST_OBJECTS_T '||
  ' SET status = :b_status'||
  ' WHERE rowid = :b_rowid';

  v_update_activity_stmt CONSTANT VARCHAR2(4000) :=
  'UPDATE FEM_ACTIVITIES_T '||
  ' SET status = :b_status'||
  ' WHERE rowid = :b_rowid';

  v_delete_cost_stmt CONSTANT VARCHAR2(4000) :=
  'DELETE FROM FEM_COST_OBJECTS_T '||
  ' WHERE rowid = :b_rowid'||
  ' AND   :b_status = ''LOAD''';

  v_delete_activity_stmt CONSTANT VARCHAR2(4000) :=
  'DELETE FROM FEM_ACTIVITIES_T '||
  ' WHERE rowid = :b_rowid'||
  ' AND   :b_status = ''LOAD''';


   BEGIN

   fem_engines_pkg.tech_message(
             p_severity  => c_log_level_2
             ,p_module   => c_block||'.'||c_proc_name||'.Begin'
             ,p_msg_text => 'Execution Mode' || p_execution_mode||
			                'Dimension' || p_dimension_varchar_label);


   --------------------------------------------------------------------------
   -- This procedure gets the flexfield info of the Composite Dimension
   -- and populates the TABLE Type variable
   --------------------------------------------------------------------------

   Pre_Process (x_pre_process_status
                ,p_execution_mode
                ,p_dimension_varchar_label);



   fem_engines_pkg.tech_message(
             p_severity  => c_log_level_5
             ,p_module   => c_block||'.'||c_proc_name||'.After Pre_Process'
             ,p_msg_text => 'Pre_Process Error '||x_pre_process_status);


   --------------------------------------------------------------------------
   -- Check for the error message from procedure pre-process
   --------------------------------------------------------------------------


   IF x_pre_process_status = 'ERROR' THEN

	 fem_engines_pkg.tech_message (
             p_severity  => c_log_level_4
	         ,p_module   => c_block||'.'||c_proc_name||'Pre_Process Error'
             ,p_msg_text => 'Code'||SQLCODE||'Err'||SQLERRM);

     RAISE e_terminate;

   END IF;

   -----------------------------------------------------------------------------
   --Initialize MultiProcessing variables
   -----------------------------------------------------------------------------

   v_data_slc := p_slc_pred;

   IF v_data_slc IS NULL THEN
     v_data_slc := '1=1';
   END IF;

   IF (p_fetch_limit IS NOT NULL) THEN
     v_fetch_limit := p_fetch_limit;
   ELSE
     v_fetch_limit := c_fetch_limit;
   END IF;

   -----------------------------------------------------------------------------
   -- Add data slice to select statement
   -----------------------------------------------------------------------------

   --  v_select_stmt := REPLACE(p_eng_sql,'{{data_slice}}',v_data_slc);

   v_select_stmt := REPLACE(g_select_statement,'{{data_slice}}',v_data_slc);

   -----------------------------------------------------------------------------
   --Assign the update/delete statement according to the dimension
   -----------------------------------------------------------------------------


   IF (p_dimension_varchar_label = 'COST_OBJECT') THEN
     v_update_stmt := v_update_cost_stmt;
     v_delete_stmt := v_delete_cost_stmt;
     v_member_table_name := 'fem_cost_objects_t';

   ELSIF (p_dimension_varchar_label = 'ACTIVITY') THEN
     v_update_stmt := v_update_activity_stmt;
     v_delete_stmt := v_delete_activity_stmt;
     v_member_table_name := 'fem_activities_t';

   END IF;


   fem_engines_pkg.tech_message (
             p_severity  => c_log_level_1
	         ,p_module   => c_block||'.'||c_proc_name
             ,p_msg_text => 'v_update_stmt '||v_update_stmt||
			                'v_member_table_name '||v_member_table_name);


   fem_engines_pkg.tech_message (
             p_severity  => c_log_level_1
	         ,p_module   => c_block||'.'||c_proc_name
             ,p_msg_text => 'v_delete_stmt '||v_delete_stmt||
		                    'v_member_table_name '||v_member_table_name);
     LOOP

    FEM_Multi_Proc_Pkg.Get_Data_Slice(
 	         x_slc_id => v_slc_id,
 	         x_slc_val1 => v_slc_val1,
 	         x_slc_val2 => v_slc_val2,
 	         x_slc_val3 => v_slc_val3,
 	         x_slc_val4 => v_slc_val4,
 	         x_num_vals  => v_num_vals,
 	         x_part_name => v_part_name,
 	         p_req_id => p_req_id,
 	         p_proc_num => p_proc_num);

    fem_engines_pkg.tech_message (
                  p_severity  => c_log_level_1
                  ,p_module=> c_block||'.'||c_proc_name||'.Get_Data_Slice'
                  ,p_msg_text => 'v_slc_id '||v_slc_id||
                  'v_slc_val2'||v_slc_val2||
				  'v_slc_val3'|| v_slc_val3||'v_slc_val4'|| v_slc_val4||
                  'v_num_vals'|| v_num_vals||'v_part_name'|| v_part_name||
                  'p_req_id'|| p_req_id||
                  'p_proc_num'|| p_proc_num);

   EXIT WHEN (v_slc_id IS NULL);

IF (p_part_code > 0) AND
   (NVL(v_part_name,'null') <> NVL(p_part_name,'null'))
THEN
   v_part_name := p_part_name;
   v_select_stmt := REPLACE(v_select_stmt,'{{table_partition}}',v_part_name);
END IF;

   -----------------------------------------------------------------------------
   -- In Error Reprocessing mode, update status to LOAD
   -----------------------------------------------------------------------------

   IF (p_execution_mode = 'E') THEN


        IF (v_num_vals = 4)
        THEN
          EXECUTE IMMEDIATE
     ' UPDATE '||v_member_table_name||' b'||
     ' SET status = ''LOAD'''||
     ' WHERE status <> ''LOAD'''||
     ' AND '||v_data_slc
              USING v_slc_val1,v_slc_val2,v_slc_val3,v_slc_val4;
        ELSIF (v_num_vals = 3)
        THEN
          EXECUTE IMMEDIATE
     ' UPDATE '||v_member_table_name||' b'||
     ' SET status = ''LOAD'''||
     ' WHERE status <> ''LOAD'''||
     ' AND '||v_data_slc
              USING v_slc_val1,v_slc_val2,v_slc_val3;
        ELSIF (v_num_vals = 2)
        THEN
        EXECUTE IMMEDIATE
     ' UPDATE '||v_member_table_name||' b'||
     ' SET status = ''LOAD'''||
     ' WHERE status <> ''LOAD'''||
     ' AND '||v_data_slc
              USING v_slc_val1,v_slc_val2;
        ELSIF (v_num_vals = 1)
        THEN
           EXECUTE IMMEDIATE
     ' UPDATE '||v_member_table_name||' b'||
     ' SET status = ''LOAD'''||
     ' WHERE status <> ''LOAD'''||
     ' AND '||v_data_slc
              USING v_slc_val1;
        ELSE
           EXIT;
        END IF;
     fem_engines_pkg.tech_message (
             p_severity  => c_log_level_1
	         ,p_module   => c_block||'.'||c_proc_name||'.Error Reproceesing Mode'
             ,p_msg_text => 'v_data_slc '||v_data_slc||
		                    'v_member_table_name'||v_member_table_name);
   END IF;


/*------------------------------------------------------------------------------
    VALIDATION#1

    This validation checks whether the values in GLOBAL_VS_COMBO_DISPLAY_CODE
    column of interface table is valid.
-------------------------------------------------------------------------------*/

     fem_engines_pkg.tech_message (
             p_severity  => c_log_level_1
	         ,p_module   => c_block||'.'||c_proc_name||'.Start of Validation#1'
             ,p_msg_text => 'v_data_slc '||v_data_slc||
		                    'v_member_table_name'||v_member_table_name);


   l_count :=0 ;
   l_validation_sql:=     ' SELECT B.rowid '||
	 ' FROM '||v_member_table_name||' B'||
	 ' WHERE not exists '||
     ' (SELECT 1 FROM fem_global_vs_combos_b g '||
	 ' WHERE B.global_vs_combo_display_code= g.global_vs_combo_display_code)'||
     ' AND B.status = ''LOAD'''||
      -- ' AND 1=1';
     ' AND '||v_data_slc;


  IF (v_num_vals = 4)
THEN
   OPEN cv_get_invalid_gvscs FOR
      l_validation_sql
      USING v_slc_val1,v_slc_val2,v_slc_val3,v_slc_val4;
ELSIF (v_num_vals = 3)
THEN
   OPEN cv_get_invalid_gvscs FOR
      l_validation_sql
      USING v_slc_val1,v_slc_val2,v_slc_val3;
ELSIF (v_num_vals = 2)
THEN
   OPEN cv_get_invalid_gvscs FOR
      l_validation_sql
      USING v_slc_val1,v_slc_val2;
ELSIF (v_num_vals = 1)
THEN
   OPEN cv_get_invalid_gvscs FOR
      l_validation_sql
      USING v_slc_val1;
ELSE
   EXIT;
END IF;

   LOOP
     EXIT WHEN cv_get_invalid_gvscs%NOTFOUND;
     FETCH cv_get_invalid_gvscs BULK COLLECT
     INTO t_rowid
     LIMIT v_fetch_limit;

     -- local var which holds the no : of invalid values

     l_count := l_count + t_rowid.COUNT;

     --Get the count of no : of records this fetch
	 v_last_row := t_rowid.COUNT;

	 IF (v_last_row IS NOT NULL) THEN
       lv_status := 'INVALID_GVSC';

	   FORALL i IN 1..v_last_row
         EXECUTE IMMEDIATE v_update_stmt USING lv_status,t_rowid(i);
       t_rowid.DELETE;
       COMMIT;


	 END IF; -- v_last_row

   END LOOP;

   fem_engines_pkg.tech_message (
          p_severity  => c_log_level_1
          ,p_module   => c_block||'.'||c_proc_name||'.Validation#1 - End'
          ,p_msg_text => 'v_data_slc '||v_data_slc||
                         'v_member_table_name'||v_member_table_name||
						 'No:of Invalid Records'|| l_count);


   CLOSE cv_get_invalid_gvscs;

/*------------------------------------------------------------------------------
VALIDATION#2:

            ***This is only for Cost Object Dimension ***

1. The members of the Financial Element should have the value of
COST_OBJECT_UNIT_FLAG attribute as 'Y' and  'DATA_TYPE_CODE' attribute
as 'RATE"

2.The Members of Ledger Dimension and Global_VS_Combo Column should be in sync.
-------------------------------------------------------------------------------*/

   IF p_dimension_varchar_label = 'COST_OBJECT' THEN

     FOR c_attr IN (
       SELECT a.attribute_id
       ,v.version_id
       ,a.attribute_varchar_label
       ,a.dimension_id
       FROM fem_dim_attributes_vl a
       ,fem_dim_attr_versions_vl v
       WHERE a.attribute_id = v.attribute_id
       AND v.default_version_flag = 'Y'
       AND (
       (a.attribute_varchar_label IN ('COST_OBJECT_UNIT_FLAG','DATA_TYPE_CODE')
        AND a.dimension_id = 12) -- Financial Element
       OR
       (a.attribute_varchar_label IN ('GLOBAL_VS_COMBO')
        AND a.dimension_id = 7) -- Ledger
       )
       AND v.default_version_flag = 'Y' )
       LOOP
         IF c_attr.dimension_id = 12 THEN -- Financial Element

		   IF c_attr.attribute_varchar_label = 'COST_OBJECT_UNIT_FLAG' THEN

		     l_count :=0 ;
                     l_validation_sql:=  ' SELECT b.rowid'||
			 ' FROM fem_cost_objects_t b'||
			 ' ,fem_fin_elems_attr a'||
			 ' ,fem_fin_elems_vl m'||
			 ' WHERE a.financial_elem_id = m.financial_elem_id'||
			 ' AND m.financial_elem_display_code = b.financial_elem_display_code'||
			 ' AND a.attribute_id = '||c_attr.attribute_id||
			 ' AND a.version_id = '||c_attr.version_id||
			 ' AND a.dim_attribute_varchar_member <> ''Y'''||
			 ' AND b.status = ''LOAD'''||
			 ' AND '||v_data_slc;

                      IF (v_num_vals = 4)
                      THEN
                         OPEN cv_get_invalid_fin_elems FOR
                            l_validation_sql
                            USING v_slc_val1,v_slc_val2,v_slc_val3,v_slc_val4;
                      ELSIF (v_num_vals = 3)
                      THEN
                         OPEN cv_get_invalid_fin_elems FOR
                            l_validation_sql
                            USING v_slc_val1,v_slc_val2,v_slc_val3;
                      ELSIF (v_num_vals = 2)
                      THEN
                         OPEN cv_get_invalid_fin_elems FOR
                            l_validation_sql
                            USING v_slc_val1,v_slc_val2;
                      ELSIF (v_num_vals = 1)
                      THEN
                         OPEN cv_get_invalid_fin_elems FOR
                            l_validation_sql
                            USING v_slc_val1;
                      ELSE
                         EXIT;
                      END IF;

             LOOP

			 EXIT WHEN cv_get_invalid_fin_elems%NOTFOUND;
			 FETCH cv_get_invalid_fin_elems BULK COLLECT
			 INTO  t_rowid
			 LIMIT v_fetch_limit;

	         -- local var which holds the no : of invalid values

             l_count := l_count + t_rowid.COUNT;

			 v_last_row := t_rowid.COUNT;

			 IF (v_last_row IS NOT NULL) THEN
	           lv_status := 'INVALID_FIN_ELEMS_NOT_COUC_FLAG';
               FORALL i IN 1..v_last_row
               EXECUTE IMMEDIATE v_update_stmt USING lv_status,t_rowid(i);
			 END IF; -- v_last_row

             END LOOP;

             CLOSE cv_get_invalid_fin_elems;

             fem_engines_pkg.tech_message (
                        p_severity  => c_log_level_1
                        ,p_module => c_block||'.'||c_proc_name||'.Validation#2.1'
                        ,p_msg_text => 'v_data_slc '||v_data_slc||
                        'v_member_table_name'||v_member_table_name||
						'No:of Invalid Records'|| l_count);

	/*	   ELSE  -- DATA_TYPE_CODE = 'RATE'

		     l_count :=0 ;

             OPEN cv_get_invalid_fin_elems FOR
    		 ' SELECT b.rowid'||
             ' FROM fem_cost_objects_t b'||
             ' ,fem_fin_elems_attr a'||
             ' ,fem_fin_elems_vl m'||
             ' WHERE a.financial_elem_id = m.financial_elem_id'||
             ' AND m.financial_elem_display_code = b.financial_elem_display_code'||
             ' AND a.attribute_id = '||c_attr.attribute_id||
             ' AND a.version_id = '||c_attr.version_id||
             ' AND a.dim_attribute_varchar_member <> ''RATE'''||
             ' AND b.status = ''LOAD'''||
             ' AND '||v_data_slc;

			 LOOP

		     EXIT WHEN cv_get_invalid_fin_elems%NOTFOUND;
             FETCH cv_get_invalid_fin_elems BULK COLLECT
			 INTO t_rowid
			 LIMIT v_fetch_limit;

			 -- local var which holds the no : of invalid values

             l_count := l_count + t_rowid.COUNT;

             v_last_row := t_rowid.COUNT;
             IF (v_last_row IS NOT NULL) THEN
               lv_status := 'INVALID_FIN_ELEMS_NOT_RATE_DATA_TYPE';
               FORALL i IN 1..v_last_row
                 EXECUTE IMMEDIATE v_update_stmt USING lv_status,t_rowid(i);
             END IF; -- v_last_row

			 END LOOP;

             CLOSE cv_get_invalid_fin_elems;

             fem_engines_pkg.tech_message (
                        p_severity  => c_log_level_1
                        ,p_module => c_block||'.'||c_proc_name||'.Validation#2.2'
                        ,p_msg_text => 'v_data_slc '||v_data_slc||
                        'v_member_table_name'||v_member_table_name||
						'No:of Invalid Records'|| l_count);*/

		   END IF; -- attribute_varchar_label = 'COST_OBJECT_UNIT_FLAG'

         ELSE --- if the dimension_id = 7(ledger)

           l_count :=0 ;
           l_validation_sql :=            ' SELECT b.rowid'||
           ' FROM fem_cost_objects_t b'||
           ' WHERE NOT EXISTS ('||
           '  SELECT 1'||
           '  FROM fem_ledgers_b l'||
           '  ,fem_ledgers_attr a'||
           '  ,fem_global_vs_combos_b g'||
           '  WHERE l.ledger_display_code = b.ledger_display_code'||
           '  AND a.ledger_id = l.ledger_id'||
           '  AND a.attribute_id = '||c_attr.attribute_id||
           '  AND a.version_id = '||c_attr.version_id||
           '  AND a.dim_attribute_numeric_member = g.global_vs_combo_id'||
           '  AND g.global_vs_combo_display_code = b.global_vs_combo_display_code'||
           ' )'||
           ' AND status = ''LOAD'''||
           ' AND '||v_data_slc;


           IF (v_num_vals = 4)
          THEN
             OPEN cv_get_invalid_ledgers FOR
                l_validation_sql
                USING v_slc_val1,v_slc_val2,v_slc_val3,v_slc_val4;
          ELSIF (v_num_vals = 3)
          THEN
             OPEN cv_get_invalid_ledgers FOR
                l_validation_sql
                USING v_slc_val1,v_slc_val2,v_slc_val3;
          ELSIF (v_num_vals = 2)
          THEN
             OPEN cv_get_invalid_ledgers FOR
                l_validation_sql
                USING v_slc_val1,v_slc_val2;
          ELSIF (v_num_vals = 1)
          THEN
             OPEN cv_get_invalid_ledgers FOR
                l_validation_sql
                USING v_slc_val1;
          ELSE
             EXIT;
          END IF;
           LOOP

		   EXIT WHEN cv_get_invalid_ledgers%NOTFOUND;
           FETCH cv_get_invalid_ledgers BULK COLLECT
		   INTO  t_rowid
		   LIMIT v_fetch_limit;

		   -- local var which holds the no : of invalid values

		   l_count := l_count + t_rowid.COUNT;

		   v_last_row := t_rowid.COUNT;

           IF (v_last_row IS NOT NULL) THEN
             lv_status := 'INVALID_LEDGER_FOR_GVSC';
              FORALL i IN 1..v_last_row
                EXECUTE IMMEDIATE v_update_stmt USING lv_status,t_rowid(i);
           END IF; -- v_last_row

           END LOOP;

		   CLOSE cv_get_invalid_ledgers;

		   fem_engines_pkg.tech_message (
                       p_severity  => c_log_level_1
                       ,p_module=> c_block||'.'||c_proc_name||'.Validation#2.3'
                       ,p_msg_text => 'v_data_slc '||v_data_slc||
                       'v_member_table_name'||v_member_table_name||
		        	   'No:of Invalid Records'|| l_count);

         END IF; -- dimension_id = 7(ledger)

         t_rowid.DELETE;

       END LOOP; -- c_attr

   END IF; --- p_dimension_varchar_label = 'COST_OBJECT'

   COMMIT;
/*------------------------------------------------------------------------------
VALIDATION#3:

--This validation ensures that the strucutre of the composite
--dimension flex field is in synch with the records of the interface table.
--(ie) Those component dimensions defined as a part of FlexField should only
--have the 'DISPLAY_CODE' values in the interface table.Other component
--dimension's display code values should be null.Moreover the display code of
--component dimension which is a part of Flex Field Definition should not be
-- null(Inverse of the above scenario).

------------------------------------------------------------------------------*/

  l_count := 0;

  FOR i IN 1..t_metadata.COUNT LOOP  -- Loop within the component dimensions

    IF (t_metadata(i).dimension_id <> -999) THEN
      l_validation_sql:=      ' SELECT b.rowid '||
      ' FROM '||v_member_table_name||' b'||
      ' WHERE '||t_metadata(i).member_display_code_col||' is null'||
      ' AND status = ''LOAD'''||
      ' AND '||v_data_slc;


      IF (v_num_vals = 4)
      THEN
         OPEN cv_get_invalid_comp_dims FOR
            l_validation_sql
            USING v_slc_val1,v_slc_val2,v_slc_val3,v_slc_val4;
      ELSIF (v_num_vals = 3)
      THEN
         OPEN cv_get_invalid_comp_dims FOR
            l_validation_sql
            USING v_slc_val1,v_slc_val2,v_slc_val3;
      ELSIF (v_num_vals = 2)
      THEN
         OPEN cv_get_invalid_comp_dims FOR
            l_validation_sql
            USING v_slc_val1,v_slc_val2;
      ELSIF (v_num_vals = 1)
      THEN
         OPEN cv_get_invalid_comp_dims FOR
            l_validation_sql
            USING v_slc_val1;
      ELSE
         EXIT;
      END IF;

    ELSE
      l_validation_sql:=	  ' SELECT b.rowid '||
	  ' FROM '||v_member_table_name||' b'||
	  ' WHERE '||t_metadata(i).member_display_code_col||' is not null'||
	  ' AND status = ''LOAD'''||
	  ' AND '||v_data_slc;


        IF (v_num_vals = 4)
      THEN
         OPEN cv_get_invalid_comp_dims FOR
            l_validation_sql
            USING v_slc_val1,v_slc_val2,v_slc_val3,v_slc_val4;
      ELSIF (v_num_vals = 3)
      THEN
         OPEN cv_get_invalid_comp_dims FOR
            l_validation_sql
            USING v_slc_val1,v_slc_val2,v_slc_val3;
      ELSIF (v_num_vals = 2)
      THEN
         OPEN cv_get_invalid_comp_dims FOR
            l_validation_sql
            USING v_slc_val1,v_slc_val2;
      ELSIF (v_num_vals = 1)
      THEN
         OPEN cv_get_invalid_comp_dims FOR
            l_validation_sql
            USING v_slc_val1;
      ELSE
         EXIT;
      END IF;

    END IF;

    LOOP
      EXIT WHEN cv_get_invalid_comp_dims%NOTFOUND;
      FETCH cv_get_invalid_comp_dims BULK COLLECT
      INTO t_rowid
      LIMIT v_fetch_limit;

      -- local var which holds the no : of invalid values

      l_count := l_count + t_rowid.COUNT;

      v_last_row := t_rowid.COUNT;

      IF (v_last_row IS NOT NULL) THEN

        lv_status := 'INVALID_STR_'||t_metadata(i).member_display_code_col;

        FORALL i IN 1..v_last_row
          EXECUTE IMMEDIATE v_update_stmt USING lv_status,t_rowid(i);
          t_rowid.DELETE;

      END IF; -- v_last_row

    END LOOP; -- cursor

    CLOSE cv_get_invalid_comp_dims;

   -- END IF;

  END LOOP; -- FOR LOOP

  COMMIT;

  fem_engines_pkg.tech_message (
                  p_severity  => c_log_level_1
                  ,p_module=> c_block||'.'||c_proc_name||'.Validation#3'
                  ,p_msg_text => 'v_data_slc '||v_data_slc||
                  'v_member_table_name'||v_member_table_name||
				  'No:of Invalid Records'|| l_count);

  ------------------------------------------------------------------------------
  -- end of Validation # 3
  ------------------------------------------------------------------------------

  ------------------------------------------------------------------------------
  -- Start processing Rows from Interface table.
  -- Open the cursor to get the rows from interface table
  ------------------------------------------------------------------------------
  --Bind Variable Push


  IF (v_num_vals = 4)
  THEN
     OPEN cv_get_rows FOR
        v_select_stmt
        USING v_slc_val1,v_slc_val2,v_slc_val3,v_slc_val4;
  ELSIF (v_num_vals = 3)
  THEN
     OPEN cv_get_rows FOR
        v_select_stmt
        USING v_slc_val1,v_slc_val2,v_slc_val3;
  ELSIF (v_num_vals = 2)
  THEN
     OPEN cv_get_rows FOR
        v_select_stmt
        USING v_slc_val1,v_slc_val2;
  ELSIF (v_num_vals = 1)
  THEN
     OPEN cv_get_rows FOR
        v_select_stmt
        USING v_slc_val1;
  ELSE
     EXIT;
  END IF;


  LOOP
    EXIT WHEN cv_get_rows%NOTFOUND;
    IF p_dimension_varchar_label = 'COST_OBJECT' THEN
      FETCH cv_get_rows BULK COLLECT
	  INTO    t_rowid,
              t_global_vs_combo_dc,
              t_fin_elem_dc,
              t_ledger_dc,
              t_product_dc,
              t_cctr_org_dc,
              t_customer_dc,
              t_channel_dc,
              t_project_dc,
              t_user_dim1_dc,
              t_user_dim2_dc,
              t_user_dim3_dc,
              t_user_dim4_dc,
              t_user_dim5_dc,
              t_user_dim6_dc,
              t_user_dim7_dc,
              t_user_dim8_dc,
              t_user_dim9_dc,
              t_user_dim10_dc,
              t_status
	  LIMIT v_fetch_limit;

    ELSIF p_dimension_varchar_label = 'ACTIVITY' THEN
      FETCH cv_get_rows BULK COLLECT
	  INTO    t_rowid,
              t_global_vs_combo_dc,
              t_task_dc,
              t_cctr_org_dc,
              t_customer_dc,
              t_channel_dc,
              t_product_dc,
              t_project_dc,
              t_user_dim1_dc,
              t_user_dim2_dc,
              t_user_dim3_dc,
              t_user_dim4_dc,
              t_user_dim5_dc,
              t_user_dim6_dc,
              t_user_dim7_dc,
              t_user_dim8_dc,
              t_user_dim9_dc,
              t_user_dim10_dc,
              t_status
	  LIMIT v_fetch_limit;

    END IF; -- End of Fetch rows

    -- Get the no:of rows this fetch
	v_mbr_last_row := t_status.COUNT;

    fem_engines_pkg.tech_message (
                  p_severity  => c_log_level_1
                  ,p_module=> c_block||'.'||c_proc_name||'.Validation#3'
                  ,p_msg_text => 'v_data_slc '||v_data_slc||
                  'v_member_table_name'||v_member_table_name||
				  'No:of Invalid Records'|| l_count);

     /*  IF (x_rows_loaded IS NULL) THEN
           x_rows_loaded := 0;
        END IF;

        x_rows_loaded := x_rows_loaded + v_mbr_last_row; */


/*------------------------------------------------------------------------------
VALIDATION#4:
-- The Member Ids of component dimension members are populated in the
-- following piece of code.
-- If the member is not present in the component dimension member table
-- that row will be marked as invalid.
------------------------------------------------------------------------------*/

   -- Loop within the number of records in interface table
	FOR j IN 1..v_mbr_last_row   LOOP
    -- Initialize the TABLE TYPE Varible
      t_channel_id(j)   := NULL;
      t_cctr_org_id(j)  := NULL;
      t_customer_id(j)  := NULL;
      t_fin_elem_id(j)  := NULL;
      t_ledger_id(j)    := NULL;
      t_product_id(j)   := NULL;
      t_project_id(j)   := NULL;
      t_task_id(j)      := NULL;
      t_user_dim1_id(j) := NULL;
      t_user_dim2_id(j) := NULL;
      t_user_dim3_id(j) := NULL;
      t_user_dim4_id(j) := NULL;
      t_user_dim5_id(j) := NULL;
      t_user_dim6_id(j) := NULL;
      t_user_dim7_id(j) := NULL;
      t_user_dim8_id(j) := NULL;
      t_user_dim9_id(j) := NULL;
      t_user_dim10_id(j):= NULL;

	  t_global_vs_combo_id(j) := -1;

      FOR i IN 1..t_metadata.COUNT LOOP

        IF (t_metadata(i).dimension_id <> '-999') AND (t_status(j) = 'LOAD')THEN

		  FOR c_value_set IN (
            SELECT g.dimension_id
			       ,g.value_set_id
                   ,g.global_vs_combo_id
            FROM FEM_GLOBAL_VS_COMBO_DEFS g,
                 FEM_GLOBAL_VS_COMBOS_b m
            WHERE g.global_vs_combo_id = m.global_vs_combo_id
            AND g.dimension_id = t_metadata(i).dimension_id
            AND m.global_vs_combo_display_code =  t_global_vs_combo_dc(j)
            ORDER BY 1)
          LOOP

          t_global_vs_combo_id(j) := c_value_set.global_vs_combo_id;

		  --Ledger is not handled here as it is non VSR Dimension

          CASE t_metadata(i).member_display_code_col

          WHEN 'FINANCIAL_ELEM_DISPLAY_CODE' THEN

				BEGIN
                  EXECUTE IMMEDIATE t_metadata(i).member_sql
                          INTO  t_fin_elem_id(j)
                          USING  t_fin_elem_dc(j),c_value_set.value_set_id;

                EXCEPTION
                  WHEN no_data_found THEN
                    t_status(j) := 'INVALID_FIN_ELEM';
                END;

          WHEN 'TASK_DISPLAY_CODE' THEN

				BEGIN
                  EXECUTE IMMEDIATE t_metadata(i).member_sql
                            INTO  t_task_id(j)
                            USING t_task_dc(j),c_value_set.value_set_id;

                EXCEPTION
                  WHEN no_data_found THEN
                    t_status(j) := 'INVALID_TASK';
                END;

          WHEN 'CHANNEL_DISPLAY_CODE' THEN

 				BEGIN
                  EXECUTE IMMEDIATE t_metadata(i).member_sql
                          INTO  t_channel_id(j)
                          USING t_channel_dc(j), c_value_set.value_set_id;

                EXCEPTION
                  WHEN no_data_found THEN
                    t_status(j) := 'INVALID_CHANNEL';
                END;

          WHEN 'CCTR_ORG_DISPLAY_CODE' THEN

				BEGIN
                  EXECUTE IMMEDIATE t_metadata(i).member_sql
                          INTO  t_cctr_org_id(j)
                          USING  t_cctr_org_dc(j),c_value_set.value_set_id;

                EXCEPTION
                  WHEN no_data_found THEN
                    t_status(j) := 'INVALID_CCTR_ORG';
                END;

          WHEN 'CUSTOMER_DISPLAY_CODE' THEN

				BEGIN
                  EXECUTE IMMEDIATE t_metadata(i).member_sql
                          INTO  t_customer_id(j)
                          USING t_customer_dc(j),c_value_set.value_set_id;

                EXCEPTION
                  WHEN no_data_found THEN
                    t_status(j) := 'INVALID_CUSTOMER';
                END;

          WHEN 'PRODUCT_DISPLAY_CODE' THEN

				BEGIN
                  EXECUTE IMMEDIATE t_metadata(i).member_sql
                         INTO  t_product_id(j)
                         USING t_product_dc(j),c_value_set.value_set_id;

                EXCEPTION
                  WHEN no_data_found THEN
                   t_status(j) := 'INVALID_PRODUCT';
                END;

          WHEN 'PROJECT_DISPLAY_CODE' THEN

				BEGIN
                  EXECUTE IMMEDIATE t_metadata(i).member_sql
                           INTO  t_project_id(j)
                           USING t_project_dc(j),c_value_set.value_set_id;

                EXCEPTION
                  WHEN no_data_found THEN
                    t_status(j) := 'INVALID_PROJECT';
                END;

          WHEN 'USER_DIM1_DISPLAY_CODE' THEN

				BEGIN
                  EXECUTE IMMEDIATE t_metadata(i).member_sql
                          INTO  t_user_dim1_id(j)
                          USING t_user_dim1_dc(j),c_value_set.value_set_id;

                EXCEPTION
                  WHEN no_data_found THEN
                    t_status(j) := 'INVALID_USER_DIM1';
                END;

          WHEN 'USER_DIM2_DISPLAY_CODE' THEN

				BEGIN
                  EXECUTE IMMEDIATE t_metadata(i).member_sql
                          INTO  t_user_dim2_id(j)
                          USING t_user_dim2_dc(j),c_value_set.value_set_id;

                EXCEPTION
                  WHEN no_data_found THEN
                    t_status(j) := 'INVALID_USER_DIM2';
                END;

          WHEN 'USER_DIM3_DISPLAY_CODE' THEN

				BEGIN
                  EXECUTE IMMEDIATE t_metadata(i).member_sql
                          INTO  t_user_dim3_id(j)
                          USING t_user_dim3_dc(j),c_value_set.value_set_id;

                EXCEPTION
                  WHEN no_data_found THEN
                    t_status(j) := 'INVALID_USER_DIM3';
                END;

          WHEN 'USER_DIM4_DISPLAY_CODE' THEN

				BEGIN
                  EXECUTE IMMEDIATE t_metadata(i).member_sql
                          INTO  t_user_dim4_id(j)
                          USING t_user_dim4_dc(j),c_value_set.value_set_id;

                EXCEPTION
                  WHEN no_data_found THEN
                    t_status(j) := 'INVALID_USER_DIM4';
                END;

          WHEN 'USER_DIM5_DISPLAY_CODE' THEN

				BEGIN
                  EXECUTE IMMEDIATE t_metadata(i).member_sql
                          INTO  t_user_dim5_id(j)
                          USING t_user_dim5_dc(j),c_value_set.value_set_id;

                EXCEPTION
                  WHEN no_data_found THEN
                    t_status(j) := 'INVALID_USER_DIM5';
                END;

          WHEN 'USER_DIM6_DISPLAY_CODE' THEN

				BEGIN
                  EXECUTE IMMEDIATE t_metadata(i).member_sql
                          INTO  t_user_dim6_id(j)
                          USING t_user_dim6_dc(j),c_value_set.value_set_id;

                EXCEPTION
                  WHEN no_data_found THEN
                    t_status(j) := 'INVALID_USER_DIM6';
                END;

          WHEN 'USER_DIM7_DISPLAY_CODE' THEN

				BEGIN
                  EXECUTE IMMEDIATE t_metadata(i).member_sql
                          INTO  t_user_dim7_id(j)
                          USING t_user_dim7_dc(j),c_value_set.value_set_id;

                EXCEPTION
                  WHEN no_data_found THEN
                    t_status(j) := 'INVALID_USER_DIM7';
                END;

          WHEN 'USER_DIM8_DISPLAY_CODE' THEN

				BEGIN
                  EXECUTE IMMEDIATE t_metadata(i).member_sql
                          INTO  t_user_dim8_id(j)
                          USING t_user_dim8_dc(j),c_value_set.value_set_id;

                EXCEPTION
                  WHEN no_data_found THEN
                    t_status(j) := 'INVALID_USER_DIM8';
                END;

          WHEN 'USER_DIM9_DISPLAY_CODE' THEN

				BEGIN
                  EXECUTE IMMEDIATE t_metadata(i).member_sql
                          INTO  t_user_dim9_id(j)
                          USING t_user_dim9_dc(j),c_value_set.value_set_id;

                EXCEPTION
                  WHEN no_data_found THEN
                    t_status(j) := 'INVALID_USER_DIM9';
                END;

          WHEN 'USER_DIM10_DISPLAY_CODE' THEN

				BEGIN
                  EXECUTE IMMEDIATE t_metadata(i).member_sql
                          INTO  t_user_dim10_id(j)
                          USING t_user_dim10_dc(j),c_value_set.value_set_id;

                EXCEPTION
                  WHEN no_data_found THEN
                    t_status(j) := 'INVALID_USER_DIM10';
                END;

          ELSE NULL;

          END CASE;

          END LOOP; -- c_value_Set

      END IF;

         /* IF (t_status(j) <> 'LOAD') THEN
            x_rows_rejected := x_rows_rejected + 1;
          END IF;*/

       --Bug :4690847 : Removed to comment to populate the ledger_id
        IF p_dimension_varchar_label = 'COST_OBJECT'
              AND t_metadata(i).member_display_code_col = 'LEDGER_DISPLAY_CODE'
              AND t_status(j) = 'LOAD' THEN
          BEGIN
            SELECT ledger_id
			INTO t_ledger_id(j)
			FROM fem_ledgers_vl
		    WHERE ledger_display_code = t_ledger_dc(j);

		     EXECUTE IMMEDIATE t_metadata(i).member_sql
                          INTO  t_ledger_id(j)
                          USING t_ledger_dc(j);

          EXCEPTION
            WHEN no_data_found THEN
              t_status(j) := 'INVALID_LEDGER';
          END;

        END IF; -- if dim_id <> -999


      END LOOP; --1..17(i)




      --------------------------------------------------------------------------
      -- Initialize UOM_CODE column for cost objects
      --------------------------------------------------------------------------

      IF p_dimension_varchar_label = 'COST_OBJECT'  THEN

        IF (t_product_id(j) IS NOT NULL) AND (t_status(j) = 'LOAD') THEN
          BEGIN
            SELECT prod.dim_attribute_varchar_member AS uom_code
            INTO   t_uom_code(j)
            FROM   fem_products_attr prod,
                   fem_dim_attributes_b attr,
                   fem_dim_attr_versions_vl ver
            WHERE  prod.product_id = t_product_id(j)
				   AND  prod.attribute_id = attr.attribute_id
				   AND  prod.version_id = ver.version_id
				   AND  attr.attribute_varchar_label = 'PRODUCT_UOM'
				   AND  ver.attribute_id = attr.attribute_id
				   AND  ver.default_version_flag = 'Y';
          EXCEPTION
            WHEN no_data_found THEN
              BEGIN
                SELECT default_member_display_code INTO t_uom_code(j)
                FROM   Fem_Xdim_Dimensions_VL
                WHERE  dimension_varchar_label = 'UOM';

                IF t_uom_code(j) IS NULL THEN
                t_status(j) := 'INVALID_COST_OBJ_DEFAULT_UOM' ;
                END IF;
              END;
            END;

        ELSE  -- prodcut dimension is not a component dimension or invalid members

          SELECT default_member_display_code INTO t_uom_code(j)
          FROM   Fem_Xdim_Dimensions_VL
          WHERE  dimension_varchar_label = 'UOM';

          IF t_uom_code(j) IS NULL THEN
            IF t_status(j) = 'LOAD' THEN
              t_status(j) := 'INVALID_COST_OBJ_DEFAULT_UOM' ;
            END IF;
          END IF;

        END IF;  -- UOM code

      END IF;  -- Cost Object

	END LOOP; -- 1...v_member_last_row.(j)

	fem_engines_pkg.tech_message (
                  p_severity  => c_log_level_1
                  ,p_module=> c_block||'.'||c_proc_name||'.Validation#4 - End');


    ----------------------------------------------------------------------------
    -- Get the concatenated display code
    -----------------------------------------------------------------------------

     Get_Display_Codes(p_dimension_varchar_label, p_structure_id);

   ----------------------------------------------------------------------------
    -- VALIDATION#5
    -- check for existence of unique member (eliminate unique records in
    -- set of records selected for insertion)
	-- (ie) The following combination must be unique
	--  Display Code + GVSC id
    -----------------------------------------------------------------------------

    FOR i IN 1..v_mbr_last_row LOOP
      FOR j IN (i+1) .. v_mbr_last_row LOOP
        IF  t_display_code(i) =  t_display_code(j)
		        AND t_global_vs_combo_id(i) = t_global_vs_combo_id(j) THEN
          t_status(i) := 'MEMBER_EXISTS';
        END IF;
      END LOOP;
    END LOOP;


    fem_engines_pkg.tech_message (
                  p_severity  => c_log_level_1
                  ,p_module=> c_block||'.'||c_proc_name||'.Validation#5 - End');

    ----------------------------------------------------------------------------
    -- VALIDATION#6
    -- Check for uniqueness of records in the interface table and
    -- Composite Dimension member table
    -- Bug:4465969 : Change in signature of 'Check_Unique_Member' API
    ----------------------------------------------------------------------------

    FOR i IN 1..v_mbr_last_row LOOP
      IF t_status(i) = 'LOAD' THEN

	    FEM_DIM_UTILS_PVT.Check_Unique_Member( p_api_version => 1.0,
                        p_return_status => v_return_status,
                        p_msg_count => v_msg_count,
                        p_msg_data => v_msg_data,
                        p_comp_dim_flag => 'Y',
                        p_member_name => NULL,
                        p_member_display_code => t_display_code(i),
                        p_dimension_varchar_label => p_dimension_varchar_label,
                        p_value_set_id => NULL,
                        p_global_vs_combo_id => t_global_vs_combo_id(i),
                        p_member_group_id => NULL,
                        p_member_id => NULL);

	    IF v_return_status =  FND_API.G_RET_STS_ERROR THEN
	      t_status(i) := 'MEMBER_EXISTS';
	    END IF;
      END IF;
    END LOOP;


    fem_engines_pkg.tech_message (
                  p_severity  => c_log_level_1
                  ,p_module=> c_block||'.'||c_proc_name||'.Validation#6 - End');

    ----------------------------------------------------------------------------
    -- Insert the valid record into composite dimension member table
    ----------------------------------------------------------------------------

    IF p_dimension_varchar_label = 'COST_OBJECT' THEN
      FORALL i IN 1..v_mbr_last_row
        EXECUTE IMMEDIATE v_insert_cost_stmt
        USING t_display_code(i),
              'N',
              sysdate,
              sysdate,
              p_structure_id,
              t_global_vs_combo_id(i),
              t_uom_code(i),
              t_fin_elem_id(i),
              t_ledger_id(i),
              t_product_id(i),
              t_cctr_org_id(i),
              t_customer_id(i),
              t_channel_id(i),
              t_project_id(i),
              t_user_dim1_id(i),
              t_user_dim2_id(i),
              t_user_dim3_id(i),
              t_user_dim4_id(i),
              t_user_dim5_id(i),
              t_user_dim6_id(i),
              t_user_dim7_id(i),
              t_user_dim8_id(i),
              t_user_dim9_id(i),
              t_user_dim10_id(i),
              t_fin_elem_dc(i),
              t_ledger_dc(i),
              t_product_dc(i),
              t_cctr_org_dc(i),
              t_customer_dc(i),
              t_channel_dc(i),
              t_project_dc(i),
              t_user_dim1_dc(i),
              t_user_dim2_dc(i),
              t_user_dim3_dc(i),
              t_user_dim4_dc(i),
              t_user_dim5_dc(i),
              t_user_dim6_dc(i),
              t_user_dim7_dc(i),
              t_user_dim8_dc(i),
              t_user_dim9_dc(i),
              t_user_dim10_dc(i),
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              sysdate,
              v_CREATED_BY,
              v_LAST_UPDATED_BY,
              sysdate,
              v_LAST_UPDATE_LOGIN,
              1,
              'Y',
              'N',
              'N',
              t_status(i);

    ELSIF p_dimension_varchar_label = 'ACTIVITY' THEN
      FORALL i IN 1..v_mbr_last_row
        EXECUTE IMMEDIATE v_insert_activity_stmt
        USING t_display_code(i),
              'N',
              sysdate,
              sysdate,
              p_structure_id,
              t_global_vs_combo_id(i),
              t_task_id(i),
              t_cctr_org_id(i),
              t_customer_id(i),
              t_channel_id(i),
              t_product_id(i),
              t_project_id(i),
              t_user_dim1_id(i),
              t_user_dim2_id(i),
              t_user_dim3_id(i),
              t_user_dim4_id(i),
              t_user_dim5_id(i),
              t_user_dim6_id(i),
              t_user_dim7_id(i),
              t_user_dim8_id(i),
              t_user_dim9_id(i),
              t_user_dim10_id(i),
              t_task_dc(i),
              t_cctr_org_dc(i),
              t_customer_dc(i),
              t_channel_dc(i),
              t_product_dc(i),
              t_project_dc(i),
              t_user_dim1_dc(i),
              t_user_dim2_dc(i),
              t_user_dim3_dc(i),
              t_user_dim4_dc(i),
              t_user_dim5_dc(i),
              t_user_dim6_dc(i),
              t_user_dim7_dc(i),
              t_user_dim8_dc(i),
              t_user_dim9_dc(i),
              t_user_dim10_dc(i),
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              sysdate,
              v_CREATED_BY,
              v_LAST_UPDATED_BY,
              sysdate,
              v_LAST_UPDATE_LOGIN,
              1,
              'Y',
              'N',
              'N',
              t_status(i);

    END IF; -- Actvity / Cost Object

    ----------------------------------------------------------------------------
    --Populate the parameters for logging
    ----------------------------------------------------------------------------
    v_rows_loaded := v_rows_loaded + SQL%ROWCOUNT;
    v_rows_processed := v_rows_processed  + cv_get_rows%ROWCOUNT;
    v_rows_rejected := v_rows_rejected + (v_rows_processed - v_rows_loaded);
    --Bug#4736810



    ----------------------------------------------------------------------------
    -- This is common for both Activity and Cost Object
    -- Update the 'STATUS' column of Interface table
    -- Delete the  insertes rows from interface tables ((ie) STATUS = LOAD )
    ----------------------------------------------------------------------------

    FORALL i IN 1..v_mbr_last_row
      EXECUTE IMMEDIATE v_update_stmt USING t_status(i),t_rowid(i);

    FORALL i IN 1..v_mbr_last_row
      EXECUTE IMMEDIATE v_delete_stmt USING t_rowid(i),t_status(i);

  END LOOP; --- Bulk fetch from interface tables.

  CLOSE cv_get_rows;


  fem_engines_pkg.tech_message (
             p_severity  => c_log_level_4
	         ,p_module   => c_block||'.'||c_proc_name
             ,p_msg_text => 'Dimension'||p_dimension_varchar_label||
                            'Data Slice'||v_data_slc||
                            'Rows Processed'||v_rows_processed||
                            'Rows Loaded'||v_rows_loaded||
                            'Rows Rejected'||v_rows_rejected );

  --x_rows_rejected := get_mp_rows_rejected (x_rows_rejected)

  --------------------------
  -- Commit the transaaction
  --------------------------

   COMMIT;

   --------------------------------------------
   -- Delete Collections for Next Bulk Fetch --
   --------------------------------------------

   t_fin_elem_id.DELETE;
   t_ledger_id.DELETE;
   t_rowid.DELETE;
   t_global_vs_combo_id.DELETE;
   t_task_id.DELETE;
   t_cctr_org_id.DELETE;
   t_channel_id.DELETE;
   t_customer_id.DELETE;
   t_product_id.DELETE;
   t_project_id.DELETE;
   t_user_dim1_id.DELETE;
   t_user_dim2_id.DELETE;
   t_user_dim3_id.DELETE;
   t_user_dim4_id.DELETE;
   t_user_dim5_id.DELETE;
   t_user_dim6_id.DELETE;
   t_user_dim7_id.DELETE;
   t_user_dim8_id.DELETE;
   t_user_dim9_id.DELETE;
   t_user_dim10_id.DELETE;
   t_global_vs_combo_dc.DELETE;
   t_task_dc.DELETE;
   t_cctr_org_dc.DELETE;
   t_channel_dc.DELETE;
   t_customer_dc.DELETE;
   t_product_dc.DELETE;
   t_project_dc.DELETE;
   t_fin_elem_dc.DELETE;
   t_ledger_dc.DELETE;
   t_user_dim1_dc.DELETE;
   t_user_dim2_dc.DELETE;
   t_user_dim3_dc.DELETE;
   t_user_dim4_dc.DELETE;
   t_user_dim5_dc.DELETE;
   t_user_dim6_dc.DELETE;
   t_user_dim7_dc.DELETE;
   t_user_dim8_dc.DELETE;
   t_user_dim9_dc.DELETE;
   t_user_dim10_dc.DELETE;
   t_display_code.DELETE;
   t_status.DELETE;

IF (v_rows_rejected > 0)
THEN
   FEM_ENGINES_PKG.PUT_MESSAGE
    (p_app_name => 'FEM',
     p_msg_name => 'FEM_DATAX_LDR_BAD_DATA_ERR',
     p_token1 => 'COUNT',
     p_value1 => v_rows_rejected);
  v_message := FND_MSG_PUB.GET(p_encoded => c_false);
  fem_engines_pkg.tech_message (
             p_severity  => c_log_level_2
	         ,p_module   => c_block||'.'||c_proc_name
             ,p_msg_text =>'FEM_DATAX_LDR_BAD_DATA_ERR');


   v_status := 0;
END IF;


FEM_Multi_Proc_Pkg.Post_Data_Slice(
  p_req_id => p_req_id,
  p_slc_id => v_slc_id,
  p_status => v_status,
  p_message => v_message,
  p_rows_processed => v_rows_processed,
  p_rows_loaded => v_rows_loaded,
  p_rows_rejected => v_rows_rejected);

END LOOP;


   EXCEPTION
      WHEN e_terminate THEN

       fem_engines_pkg.tech_message(
	             p_severity  => c_log_level_4
	             ,p_module   => c_block||'.'||c_proc_name||'Exception');

       IF cv_get_rows%ISOPEN THEN
         CLOSE cv_get_rows;
       END IF;

       IF cv_get_invalid_fin_elems%ISOPEN THEN
         CLOSE cv_get_invalid_fin_elems;
       END IF;

       IF cv_get_invalid_ledgers%ISOPEN THEN
         CLOSE cv_get_invalid_ledgers;
       END IF;

       IF cv_get_invalid_gvscs%ISOPEN THEN
         CLOSE cv_get_invalid_gvscs;
       END IF;

       IF cv_get_invalid_comp_dims%ISOPEN THEN
         CLOSE cv_get_invalid_comp_dims;
       END IF;

       RAISE FEM_DIM_MEMBER_LOADER_PKG.e_main_terminate;

     WHEN OTHERS THEN
       fem_engines_pkg.tech_message (
             p_severity  => c_log_level_4
	         ,p_module   => c_block||'.'||c_proc_name||'.Exception'
             ,p_msg_text => 'Dimension'||p_dimension_varchar_label||
							'Code'||SQLCODE||'Err'||SQLERRM);

       IF cv_get_rows%ISOPEN THEN
         CLOSE cv_get_rows;
       END IF;

       IF cv_get_invalid_fin_elems%ISOPEN THEN
         CLOSE cv_get_invalid_fin_elems;
       END IF;

       IF cv_get_invalid_ledgers%ISOPEN THEN
         CLOSE cv_get_invalid_ledgers;
       END IF;

       IF cv_get_invalid_gvscs%ISOPEN THEN
         CLOSE cv_get_invalid_gvscs;
       END IF;

       IF cv_get_invalid_comp_dims%ISOPEN THEN
         CLOSE cv_get_invalid_comp_dims;
       END IF;

       RAISE FEM_DIM_MEMBER_LOADER_PKG.e_main_terminate;

   END process_rows;

/***************************************************************************/

END FEM_COMP_DIM_MEMBER_LOADER_PKG;

/
