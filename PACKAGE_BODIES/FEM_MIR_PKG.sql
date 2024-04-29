--------------------------------------------------------
--  DDL for Package Body FEM_MIR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_MIR_PKG" AS
/* $Header: FEM_MIRB.pls 120.5 2007/05/04 05:53:18 pkakkar ship $  */

c_module_pkg                 CONSTANT  VARCHAR2(80) := 'fem.plsql.FEM_MIR_PKG';
c_exp_could_not_found_err    CONSTANT  VARCHAR2(30) := 'fem_exp_could_not_found';
c_imp_could_not_found_err    CONSTANT  VARCHAR2(30) := 'fem_imp_could_not_found';
c_imp_more_rows_found_err    CONSTANT  VARCHAR2(30) := 'fem_imp_more_rows_found';
c_exp_more_rows_found_err    CONSTANT  VARCHAR2(30) := 'fem_exp_more_rows_found';
c_gdc_hier_dim_not_found_err CONSTANT
                                       VARCHAR2(30):='fem_gdc_hier_dim_not_found';
c_par_child_gdc_not_found_err        CONSTANT
                           VARCHAR2(30):='fem_parent_child_gdc_not_found';
c_vsid_or_vscode_null                CONSTANT
                           VARCHAR2(30):='fem_impexp_vs_id_or_code_null';
c_vsid_dim_not_found_err             CONSTANT
                           VARCHAR2(30):='fem_impexp_vsid_dim_not_found';
c_gl_period_num_not_found_err        CONSTANT
                           VARCHAR2(30):='fem_impexp_gl_pnum_not_found';
c_calp_end_date_not_found_err        CONSTANT
                           VARCHAR2(30):='fem_impexp_calenddate_not_fnd';
c_tab_name_not_found_err             CONSTANT
                           VARCHAR2(30):='fem_impexp_tab_name_not_found';
c_impexp_mig_fail_err                CONSTANT
                           VARCHAR2(30):='fem_impexp_mig_fail_err';

e_insert_az_request_fail   EXCEPTION;
e_ins_import_file_dsc_fail EXCEPTION;
e_bad_obj_def_id           EXCEPTION;

e_az_insert_error         EXCEPTION;
e_fem_insert_error        EXCEPTION;

c_insert_fail_err                    CONSTANT
                           VARCHAR2(30):='fem_impexp_insert_fail_err';
c_obj_def_id_not_found_err           CONSTANT
                           VARCHAR2(30):='fem_impexp_objdefid_not_found';
c_unexpected_error                  CONSTANT
                           VARCHAR2(30):='fem_unexpected_error';


/*============================================================================+
 | FUNCTION
 |   Get_Dim_Group_Display_Code
 |
 | DESCRIPTION
 |   This Function returns the Dimension Group Display Code for a given
 |   Dimension Varchar Label and Dimension Group ID.
 |   This Method will be used in queries so that's why method is not using Out
 |   Parameters like x_return_status,x_message_count,x_msg_data to get the status
 |
 |  SCOPE - PUBLIC
 +============================================================================*/

FUNCTION Get_Dim_Group_Display_Code(
  p_dimension_varchar_label     IN  VARCHAR2,
  p_dimension_group_id          IN  NUMBER
) RETURN VARCHAR2

IS

l_grp_display_code            VARCHAR2(150):=NULL ;
l_api_name 	        CONSTANT  VARCHAR2(30) := 'Get_Dim_Group_Display_Code';
l_prg_msg                     VARCHAR2(2000);

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
     p_severity  => c_log_level_2
     ,p_module   => c_module_pkg||'.'||l_api_name
     ,p_msg_text => 'Begining Function'
  );


  SELECT A.dimension_group_display_code
  INTO l_grp_display_code
  FROM fem_dimension_grps_b A,
       fem_dimensions_b B
  WHERE A.DIMENSION_GROUP_ID = p_dimension_group_id
  AND B.dimension_id = A.dimension_id
  AND B.dimension_varchar_label = p_dimension_varchar_label;

  FEM_ENGINES_PKG.Tech_Message (
        p_severity  => c_log_level_2
        ,p_module   => c_module_pkg||'.'||l_api_name
        ,p_msg_text => 'Ending Function'
  );

RETURN l_grp_display_code;

EXCEPTION

  WHEN NO_DATA_FOUND THEN

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => c_log_level_4
      ,p_module   => c_module_pkg||'.'||l_api_name
      ,p_msg_text => 'Dimension Group Display Code does not Exists for '||
      	             'given Dimension Group ID and Dimension'
       );

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => c_exp_could_not_found_err
      ,p_token1   => 'API_NAME'
      ,p_value1   => l_api_name
      ,p_token2   => 'DISPLAY_ID'
      ,p_value2   => p_dimension_group_id
      );

    RETURN l_grp_display_code;

  WHEN TOO_MANY_ROWS THEN

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => c_log_level_4
      ,p_module   => c_module_pkg||'.'||l_api_name
      ,p_msg_text => 'Dimension Group ID returned more than 1 '||
           			'Dimension Group display code'
      );

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => c_exp_more_rows_found_err
      ,p_token1   => 'API_NAME'
      ,p_value1   => l_api_name
      ,p_token2   => 'DISPLAY_ID'
      ,p_value2   => p_dimension_group_id
       );

    RETURN l_grp_display_code;

  WHEN OTHERS THEN

    l_prg_msg := SQLERRM;

    FEM_ENGINES_PKG.Tech_Message (
                     p_severity  => c_log_level_6
                     ,p_module   => c_module_pkg||'.'||l_api_name
                     ,p_msg_text => l_prg_msg
            );


    RETURN l_grp_display_code;

END Get_Dim_Group_Display_Code;

/*============================================================================+
 | FUNCTION
 |   Get_Dim_Group_Display_Code
 |
 | DESCRIPTION
 |   This Function returns the Dimension Group Display Code for a given
 |   Dimension ID and Dimension Group ID
 |   This Method will be used in queries so that's why method is not using Out
 |   Parameters like x_return_status,x_message_count,x_msg_data to get the status
 |
 |  SCOPE - PUBLIC
 +============================================================================*/

FUNCTION Get_Dim_Group_Display_Code(
  p_dimension_id                IN  NUMBER,
  p_dimension_group_id          IN  NUMBER
) RETURN VARCHAR2

IS

l_grp_display_code          VARCHAR2(150) :=NULL;
l_api_name        CONSTANT	VARCHAR2(30) := 'Get_Dim_Group_Display_Code';
l_prg_msg                   VARCHAR2(2000);

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
     p_severity  => c_log_level_2
     ,p_module   => c_module_pkg||'.'||l_api_name
     ,p_msg_text => 'Begining Function'
  );


  SELECT A.dimension_group_display_code
  INTO l_grp_display_code
  FROM fem_dimension_grps_b A,
       fem_dimensions_b B
  WHERE A.DIMENSION_GROUP_ID = p_dimension_group_id
  AND B.dimension_id = A.dimension_id
  AND B.dimension_id = p_dimension_id;

  FEM_ENGINES_PKG.Tech_Message (
        p_severity  => c_log_level_2
        ,p_module   => c_module_pkg||'.'||l_api_name
        ,p_msg_text => 'Ending function'
  );

RETURN l_grp_display_code;

EXCEPTION

  WHEN NO_DATA_FOUND THEN

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => c_log_level_4
      ,p_module   => c_module_pkg||'.'||l_api_name
      ,p_msg_text => 'Dimension Group Display Code does not Exists for '||
        	         'given Dimension Group ID and Dimension'
      );

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => c_exp_could_not_found_err
      ,p_token1   => 'API_NAME'
      ,p_value1   => l_api_name
      ,p_token2   => 'DISPLAY_ID'
      ,p_value2   => p_dimension_group_id
     );

    RETURN l_grp_display_code;

  WHEN TOO_MANY_ROWS THEN

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => c_log_level_4
      ,p_module   => c_module_pkg||'.'||l_api_name
      ,p_msg_text => 'Dimension Group ID returned more than 1 '||
           			'Dimension Group display code'
     );

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => c_exp_more_rows_found_err
      ,p_token1   => 'API_NAME'
      ,p_value1   => l_api_name
      ,p_token2   => 'DISPLAY_ID'
      ,p_value2   => p_dimension_group_id
     );

    RETURN l_grp_display_code;

  WHEN OTHERS THEN

    l_prg_msg := SQLERRM;

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => c_log_level_6
      ,p_module   => c_module_pkg||'.'||l_api_name
      ,p_msg_text => l_prg_msg
     );

    RETURN l_grp_display_code;


END Get_Dim_Group_Display_Code;

/*============================================================================+
 | FUNCTION
 |   Get_Dim_Group_Id
 |
 | DESCRIPTION
 |   This Function returns the Dimension Group ID for a given
 |   Dimension Varchar Label and Dimension Group Display Code
 |
 |  SCOPE - PUBLIC
 +============================================================================*/

FUNCTION Get_Dim_Group_Id(
  p_api_version                  IN  NUMBER     DEFAULT 1.0,
  p_init_msg_list                IN  VARCHAR2   DEFAULT c_false,
  p_commit                       IN  VARCHAR2   DEFAULT c_false,
  p_encoded                      IN  VARCHAR2   DEFAULT c_true,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_dimension_varchar_label      IN  VARCHAR2,
  p_dim_group_display_code       IN  VARCHAR2
) RETURN NUMBER

IS

l_dimension_group_id  	        NUMBER(9)    := -1 ;
l_api_name 	CONSTANT	VARCHAR2(30) := 'Get_Dim_Group_Id';
l_prg_msg                       VARCHAR2(2000);

BEGIN

FEM_ENGINES_PKG.Tech_Message (
     p_severity  => c_log_level_2
     ,p_module   => c_module_pkg||'.'||l_api_name
     ,p_msg_text => 'Begining Function'
  );

x_return_status := FND_API.G_RET_STS_SUCCESS;

  SELECT A.DIMENSION_GROUP_ID
  INTO l_dimension_group_id
  FROM fem_dimension_grps_b A,
       fem_dimensions_b B
  WHERE A.DIMENSION_GROUP_DISPLAY_CODE = p_dim_group_display_code
  AND B.dimension_id = A.dimension_id
  AND B.dimension_varchar_label = p_dimension_varchar_label;

FEM_ENGINES_PKG.Tech_Message (
        p_severity  => c_log_level_2
        ,p_module   => c_module_pkg||'.'||l_api_name
        ,p_msg_text => 'Ending Function'
  );

RETURN l_dimension_group_id;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => c_log_level_4
      ,p_module   => c_module_pkg||'.'||l_api_name
      ,p_msg_text => 'Dimension Group ID does not Exists for '||
           			'given Dimension Group display code and Dimension'
       );

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => c_imp_could_not_found_err
      ,p_token1   => 'API_NAME'
      ,p_value1   => l_api_name
      ,p_token2   => 'DISPLAY_CODE'
      ,p_value2   => p_dim_group_display_code
      );

    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN l_dimension_group_id;

  WHEN TOO_MANY_ROWS THEN
    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => c_log_level_4
      ,p_module   => c_module_pkg||'.'||l_api_name
      ,p_msg_text => 'Dimension Group display code returned more than 1 '||
           			  'Dimension Group Id'
      );

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => c_imp_more_rows_found_err
      ,p_token1   => 'API_NAME'
      ,p_value1   => l_api_name
      ,p_token2   => 'DISPLAY_CODE'
      ,p_value2   => p_dim_group_display_code
      );

    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN l_dimension_group_id;

  WHEN OTHERS THEN

    l_prg_msg := SQLERRM;

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => c_log_level_6
      ,p_module   => c_module_pkg||'.'||l_api_name
      ,p_msg_text => l_prg_msg
      );

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RETURN l_dimension_group_id;

END Get_Dim_Group_Id;

/*============================================================================+
 | FUNCTION
 |   Get_Dim_Group_Id
 |
 | DESCRIPTION
 |   This Function returns the Dimension Group ID for a given
 |   Dimension ID and Dimension Group Display Code
 |
 |  SCOPE - PUBLIC
 +============================================================================*/

FUNCTION Get_Dim_Group_Id(
  p_api_version                  IN  NUMBER     DEFAULT 1.0,
  p_init_msg_list                IN  VARCHAR2   DEFAULT c_false,
  p_commit                       IN  VARCHAR2   DEFAULT c_false,
  p_encoded                      IN  VARCHAR2   DEFAULT c_true,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_dimension_id                 IN  NUMBER,
  p_dim_group_display_code       IN  VARCHAR2
) RETURN NUMBER

IS

l_dimension_group_id  	        NUMBER(9)    := -1 ;
l_api_name 	CONSTANT	VARCHAR2(30) := 'Get_Dim_Group_Id';
l_prg_msg                       VARCHAR2(2000);

BEGIN

FEM_ENGINES_PKG.Tech_Message (
     p_severity  => c_log_level_2
     ,p_module   => c_module_pkg||'.'||l_api_name
     ,p_msg_text => 'Begining Function'
  );

x_return_status := FND_API.G_RET_STS_SUCCESS;

  SELECT A.DIMENSION_GROUP_ID
  INTO l_dimension_group_id
  FROM fem_dimension_grps_b A,
       fem_dimensions_b B
  WHERE A.DIMENSION_GROUP_DISPLAY_CODE = p_dim_group_display_code
  AND B.dimension_id = A.dimension_id
  AND B.dimension_id = p_dimension_id;

FEM_ENGINES_PKG.Tech_Message (
        p_severity  => c_log_level_2
        ,p_module   => c_module_pkg||'.'||l_api_name
        ,p_msg_text => 'End'
  );

RETURN l_dimension_group_id;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => c_log_level_4
      ,p_module   => c_module_pkg||'.'||l_api_name
      ,p_msg_text => 'Dimension Group ID does not Exists for '||
          			'given Dimension Group display code and Dimension'
       );

    FEM_ENGINES_PKG.User_Message (
       p_app_name  => G_FEM
       ,p_msg_name => c_imp_could_not_found_err
       ,p_token1   => 'API_NAME'
       ,p_value1   => l_api_name
       ,p_token2   => 'DISPLAY_CODE'
       ,p_value2   => p_dim_group_display_code
       );

    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN l_dimension_group_id;

  WHEN TOO_MANY_ROWS THEN
    FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_4
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => 'Dimension Group display code returned more than 1 '||
                      'Dimension Group Id'
      );

    FEM_ENGINES_PKG.User_Message (
       p_app_name  => G_FEM
       ,p_msg_name => c_imp_more_rows_found_err
       ,p_token1   => 'API_NAME'
       ,p_value1   => l_api_name
       ,p_token2   => 'DISPLAY_CODE'
       ,p_value2   => p_dim_group_display_code
      );

    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN l_dimension_group_id;

  WHEN OTHERS THEN

    l_prg_msg := SQLERRM;

    FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_6
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => l_prg_msg
      );

   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RETURN l_dimension_group_id;

END Get_Dim_Group_Id;

/*============================================================================+
 | FUNCTION
 |   Hier_Dim_Grp_Exists
 |
 | DESCRIPTION
 |   This Function returns True/False depending upon whether a given dimension group
 |   display code exists with a given Hierarchy Name and Dimension Varchar Label
 |
 |  SCOPE - PUBLIC
 +============================================================================*/

FUNCTION Hier_Dim_Grp_Exists(
  p_api_version                  IN  NUMBER     DEFAULT 1.0,
  p_init_msg_list                IN  VARCHAR2   DEFAULT c_false,
  p_commit                       IN  VARCHAR2   DEFAULT c_false,
  p_encoded                      IN  VARCHAR2   DEFAULT c_true,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_dimension_varchar_label      IN  VARCHAR2,
  p_hierarchy_name               IN  VARCHAR2,
  p_dim_group_display_code       IN  VARCHAR2
) RETURN VARCHAR2

IS

l_dim_group_display_code            VARCHAR2(150);
l_api_name 	              CONSTANT  VARCHAR2(30) := 'Hier_Dim_Grp_Exists';
l_prg_msg                           VARCHAR2(2000);
--------------------------------
--"T" corresponds to True
--"F" corresponds to False
l_hier_dim_grp_exists                 VARCHAR2(1) :='F';--Setting it To False
--------------------------------
BEGIN

  FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_2
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => 'Begining Function'
    );

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SELECT B.DIMENSION_GROUP_DISPLAY_CODE
  INTO l_dim_group_display_code
  FROM fem_object_catalog_vl A,
       fem_dimension_grps_b B,
       fem_hier_dimension_grps C,
       fem_dimensions_b D
  WHERE D.dimension_varchar_label = p_dimension_varchar_label
  AND D.DIMENSION_ID=B.DIMENSION_ID
  AND A.OBJECT_NAME = p_hierarchy_name
  AND B.DIMENSION_GROUP_DISPLAY_CODE = p_dim_group_display_code
  AND A.OBJECT_ID=C.HIERARCHY_OBJ_ID
  AND B.DIMENSION_GROUP_ID=C.DIMENSION_GROUP_ID ;

  FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_2
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => 'Ending Function'
    );

 l_hier_dim_grp_exists:='T';--Setting it to True
RETURN l_hier_dim_grp_exists ;

EXCEPTION

  WHEN NO_DATA_FOUND THEN

    FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_4
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => 'Dimension Group Display Code does not exists for '||
       			       'given dimension varchar label and given hierarchy'
       );
    FEM_ENGINES_PKG.User_Message (
       p_app_name  => G_FEM
       ,p_msg_name => c_gdc_hier_dim_not_found_err
       ,p_token1   => 'API_NAME'
       ,p_value1   =>  l_api_name
       ,p_token2   => 'DIMENSION_NAME'
       ,p_value2   => p_dimension_varchar_label
       ,p_token3   => 'HIERARCHY'
       ,p_value3   => p_hierarchy_name
       );

    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN l_hier_dim_grp_exists;

  WHEN TOO_MANY_ROWS THEN

    FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_4
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => 'More than 1 dim group display code exists with '||
               			'given hierarchy and dimension '
       );

    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN l_hier_dim_grp_exists;

  WHEN OTHERS THEN

    l_prg_msg := SQLERRM;

    FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_6
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => l_prg_msg
      );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RETURN l_hier_dim_grp_exists;

END Hier_Dim_Grp_Exists;

/*============================================================================+
 | FUNCTION
 |   Validate_Hier_Dim_Grps_Order
 |
 | DESCRIPTION
 |   This Function returns true/false,depending on whether relation b/w two dimension
 |   group display codes is Parent-Child or Child-Parent for a given Dimension Varchar
 |   Label and given Hierarchy.
 |
 |  SCOPE - PUBLIC
 +============================================================================*/

FUNCTION Validate_Hier_Dim_Grps_Order(
  p_api_version                          IN  NUMBER     DEFAULT 1.0,
  p_init_msg_list                        IN  VARCHAR2   DEFAULT c_false,
  p_commit                               IN  VARCHAR2   DEFAULT c_false,
  p_encoded                              IN  VARCHAR2   DEFAULT c_true,
  x_return_status                        OUT NOCOPY VARCHAR2,
  x_msg_count                            OUT NOCOPY NUMBER,
  x_msg_data                             OUT NOCOPY VARCHAR2,
  p_dimension_varchar_label              IN  VARCHAR2,
  p_hierarchy_name                       IN  VARCHAR2,
  p_parent_dim_grp_dsp_code              IN  VARCHAR2,
  p_child_dim_grp_dsp_code               IN  VARCHAR2
) RETURN VARCHAR2

IS

l_count_parent                 NUMBER:=1;
l_count_child                  NUMBER:=1;
l_parent_group_id              NUMBER(9);
l_child_group_id               NUMBER(9);

l_api_name     CONSTANT        VARCHAR2(30) := 'Validate_Hier_Dim_Grps_Order';
l_prg_msg                      VARCHAR2(2000);
--------------------------------
--"T" corresponds to True
--"F" corresponds to False
l_val_hier_dim_grps_order      VARCHAR2(1):='F';--Setting to False by Default
--------------------------------
BEGIN

  l_parent_group_id := Get_Dim_Group_Id(x_return_status           =>x_return_status
                                       ,x_msg_count               =>x_msg_count
                                       ,x_msg_data                =>x_msg_data
                                       ,p_dimension_varchar_label =>p_dimension_varchar_label
                                       ,p_dim_group_display_code  =>p_parent_dim_grp_dsp_code
                                       );

  l_child_group_id  := Get_Dim_Group_Id(x_return_status           =>x_return_status
                                       ,x_msg_count               =>x_msg_count
                                       ,x_msg_data                =>x_msg_data
                                       ,p_dimension_varchar_label =>p_dimension_varchar_label
                                       ,p_dim_group_display_code  =>p_child_dim_grp_dsp_code
                                       );

  SELECT A.relative_dimension_group_seq,
         C.relative_dimension_group_seq
  INTO l_count_parent
       ,l_count_child
  FROM fem_hier_dimension_grps A
       ,fem_object_catalog_vl B
       ,fem_hier_dimension_grps C
  WHERE B.object_name = p_hierarchy_name
  AND A.hierarchy_obj_id=B.object_id
  AND A.dimension_group_id = l_parent_group_id
  AND C.hierarchy_obj_id=B.object_id
  AND C.dimension_group_id = l_child_group_id;

  IF(l_count_parent<=l_count_child) THEN

    l_val_hier_dim_grps_order:='T';--Setting it to True

    RETURN l_val_hier_dim_grps_order;

  ELSE

    RETURN l_val_hier_dim_grps_order;

  END IF;

EXCEPTION

  WHEN NO_DATA_FOUND THEN

    FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_4
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => 'Either of Parent or Child dimension group display code is '||
        		       'not associated with given Hierarchy for given dimension'
             );
   FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => c_par_child_gdc_not_found_err
      ,p_token1   => 'API_NAME'
      ,p_value1   => l_api_name
      ,p_token2   => 'DIMENSION_NAME'
      ,p_value2   => p_dimension_varchar_label
      ,p_token3   => 'HIERARCHY'
      ,p_value3   => p_hierarchy_name
           );

    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN l_val_hier_dim_grps_order;

  WHEN TOO_MANY_ROWS THEN

    FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_4
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => 'More than 1 row returned for the given main query'
       );

    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN l_val_hier_dim_grps_order;

 WHEN OTHERS THEN

   l_prg_msg := SQLERRM;

   FEM_ENGINES_PKG.Tech_Message (
      p_severity  => c_log_level_6
      ,p_module   => c_module_pkg||'.'||l_api_name
      ,p_msg_text => l_prg_msg
      );
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   RETURN l_val_hier_dim_grps_order;

END;

/*============================================================================+
 | FUNCTION
 |   Get_Dim_Attr_Varchar_label
 |
 | DESCRIPTION
 |   Returns the Attribute Varchar Label for a given Attribute ID
 |   This Method will be used in queries so that's why, method is not using Out
 |   Parameters like x_return_status,x_message_count,x_msg_data to get the status
 |
 |  SCOPE - PUBLIC
 +============================================================================*/


FUNCTION Get_Dim_Attr_Varchar_label (
  p_attribute_id                IN  NUMBER
) RETURN VARCHAR2

IS

l_attribute_varchar_label          VARCHAR2(30) :=NULL;
l_api_name 	             CONSTANT  VARCHAR2(30) :='Get_Dim_Attr_Varchar_label';
l_prg_msg                          VARCHAR2(2000);

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
     p_severity  => c_log_level_2
     ,p_module   => c_module_pkg||'.'||l_api_name
     ,p_msg_text => 'Begining Function'
    );

  SELECT attribute_varchar_label
  INTO l_attribute_varchar_label
  FROM fem_dim_attributes_b
  WHERE attribute_id=p_attribute_id;

  FEM_ENGINES_PKG.Tech_Message (
      p_severity  => c_log_level_2
      ,p_module   => c_module_pkg||'.'||l_api_name
      ,p_msg_text => 'Ending function'
    );

RETURN l_attribute_varchar_label;

EXCEPTION

  WHEN NO_DATA_FOUND THEN

    FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_4
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => 'Attribute varchar label does not'||
        		       ' Exists for given attribute ID'
       );

    FEM_ENGINES_PKG.User_Message (
       p_app_name  => G_FEM
       ,p_msg_name => c_exp_could_not_found_err
       ,p_token1   => 'API_NAME'
       ,p_value1   => l_api_name
       ,p_token2   => 'DISPLAY_ID'
       ,p_value2   => p_attribute_id
       );

    RETURN l_attribute_varchar_label;

  WHEN TOO_MANY_ROWS THEN

    FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_4
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => 'Attribute ID returned more than 1 '||
               			'Attribute varchar label'
       );

    FEM_ENGINES_PKG.User_Message (
       p_app_name  => G_FEM
       ,p_msg_name => c_exp_more_rows_found_err
       ,p_token1   => 'API_NAME'
       ,p_value1   => l_api_name
       ,p_token2   => 'DISPLAY_ID'
       ,p_value2   => p_attribute_id
       );

    RETURN l_attribute_varchar_label;

  WHEN OTHERS THEN

    l_prg_msg := SQLERRM;

    FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_6
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => l_prg_msg
       );
    RETURN l_attribute_varchar_label;

END Get_Dim_Attr_Varchar_label;

/*============================================================================+
 | FUNCTION
 |   Get_Dim_Attribute_ID
 |
 | DESCRIPTION
 |   This Function returns the Attribute ID for a given Dimension Varchar Label
 |   and attribute varchar label
 |
 |  SCOPE - PUBLIC
 +============================================================================*/


FUNCTION Get_Dim_Attribute_ID (
  p_api_version                   IN  NUMBER     DEFAULT 1.0
  ,p_init_msg_list                IN  VARCHAR2   DEFAULT FND_API.G_FALSE
  ,p_commit                       IN  VARCHAR2   DEFAULT FND_API.G_FALSE
  ,p_encoded                      IN  VARCHAR2   DEFAULT FND_API.G_TRUE
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
  ,p_dimension_varchar_label      IN  VARCHAR2
  ,p_dim_attribute_varchar_label  IN  VARCHAR2
) RETURN NUMBER

IS

l_dim_attribute_id           NUMBER(9)    := -1;
l_api_name 	   CONSTANT  VARCHAR2(30) := 'Get_Dim_Attribute_ID';
l_prg_msg                    VARCHAR2(2000);

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_2
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => 'Begining Function'
    );

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SELECT B.attribute_id
  INTO l_dim_attribute_id
  FROM fem_dimensions_b A,
       fem_dim_attributes_b B
  WHERE a.dimension_varchar_label = p_dimension_varchar_label
  AND B.dimension_id = A.dimension_id
  AND B.attribute_varchar_label = p_dim_attribute_varchar_label;

  FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_2
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => 'End'
    );

RETURN l_dim_attribute_id;

EXCEPTION

  WHEN NO_DATA_FOUND THEN

    FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_4
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => 'Attribute ID does not exists for given '||
       			       'attribute varchar label and dimension'
       );

    FEM_ENGINES_PKG.User_Message (
       p_app_name  => G_FEM
       ,p_msg_name => c_imp_could_not_found_err
       ,p_token1   => 'API_NAME'
       ,p_value1   => l_api_name
       ,p_token2   => 'DISPLAY_CODE'
       ,p_value2   => p_dim_attribute_varchar_label
        );

    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN l_dim_attribute_id;

  WHEN TOO_MANY_ROWS THEN

    FEM_ENGINES_PKG.Tech_Message (
        p_severity  => c_log_level_4
        ,p_module   => c_module_pkg||'.'||l_api_name
        ,p_msg_text => 'Attribute varchar label returned more than 1 '||
                       'attribute ID for given dimension'
        );

    FEM_ENGINES_PKG.User_Message (
        p_app_name  => G_FEM
        ,p_msg_name => c_imp_more_rows_found_err
        ,p_token1   => 'API_NAME'
        ,p_value1   => l_api_name
        ,p_token2   => 'DISPLAY_CODE'
         ,p_value2   => p_dim_attribute_varchar_label
        );

    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN l_dim_attribute_id;

  WHEN OTHERS THEN

    l_prg_msg := SQLERRM;

    FEM_ENGINES_PKG.Tech_Message (
        p_severity  => c_log_level_6
        ,p_module   => c_module_pkg||'.'||l_api_name
        ,p_msg_text => l_prg_msg
        );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RETURN l_dim_attribute_id;

END Get_Dim_Attribute_ID;

/*============================================================================+
 | FUNCTION
 |   Get_Dim_Attribute_ID
 |
 | DESCRIPTION
 |   This Function returns the Attribute ID for a given Dimension ID and
 |   Attribute varchar label
 |
 |  SCOPE - PUBLIC
 +============================================================================*/

FUNCTION Get_Dim_Attribute_ID (
  p_api_version                   IN  NUMBER     DEFAULT 1.0
  ,p_init_msg_list                IN  VARCHAR2   DEFAULT FND_API.G_FALSE
  ,p_commit                       IN  VARCHAR2   DEFAULT FND_API.G_FALSE
  ,p_encoded                      IN  VARCHAR2   DEFAULT FND_API.G_TRUE
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
  ,p_dimension_id                 IN  NUMBER
  ,p_dim_attribute_varchar_label  IN  VARCHAR2
) RETURN NUMBER

IS

l_dim_attribute_id           NUMBER(9)    := -1;
l_api_name 	       CONSTANT  VARCHAR2(30) := 'Get_Dim_Attribute_ID';
l_prg_msg                    VARCHAR2(2000);

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_2
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => 'Begining Function'
    );

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SELECT attribute_id
  INTO l_dim_attribute_id
  FROM fem_dim_attributes_b
  WHERE dimension_id = p_dimension_id
  AND attribute_varchar_label = p_dim_attribute_varchar_label;

  FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_2
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => 'End'
    );

RETURN l_dim_attribute_id;

EXCEPTION

  WHEN NO_DATA_FOUND THEN

    FEM_ENGINES_PKG.Tech_Message (
        p_severity  => c_log_level_4
        ,p_module   => c_module_pkg||'.'||l_api_name
        ,p_msg_text => 'Attribute ID does not Exists for given '||
        		       ' attribute varchar label and dimension'
            );

    FEM_ENGINES_PKG.User_Message (
        p_app_name  => G_FEM
        ,p_msg_name => c_imp_could_not_found_err
        ,p_token1   => 'API_NAME'
        ,p_value1   => l_api_name
        ,p_token2   => 'DISPLAY_CODE'
        ,p_value2   => p_dim_attribute_varchar_label
           );

    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN l_dim_attribute_id;

  WHEN TOO_MANY_ROWS THEN

    FEM_ENGINES_PKG.Tech_Message (
        p_severity  => c_log_level_4
        ,p_module   => c_module_pkg||'.'||l_api_name
        ,p_msg_text => 'Attribute varchar label returned more than 1 '||
              			'attribute id for given dimension'
          );

    FEM_ENGINES_PKG.User_Message (
        p_app_name  => G_FEM
        ,p_msg_name => c_imp_more_rows_found_err
        ,p_token1   => 'API_NAME'
        ,p_value1   => l_api_name
        ,p_token2   => 'DISPLAY_CODE'
        ,p_value2   => p_dim_attribute_varchar_label
         );

    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN l_dim_attribute_id;

  WHEN OTHERS THEN

    l_prg_msg := SQLERRM;

    FEM_ENGINES_PKG.Tech_Message (
        p_severity  => c_log_level_6
        ,p_module   => c_module_pkg||'.'||l_api_name
        ,p_msg_text => l_prg_msg
         );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RETURN l_dim_attribute_id;

END Get_Dim_Attribute_ID;

/*============================================================================+
 | FUNCTION
 |   Get_Dim_Attr_Ver_Display_Code
 |
 | DESCRIPTION
 |   This Function returns the Attribute Version Display Code for a given
 |   Attribute ID and Verion ID
 |   This Method will be used in queries so that's why method is not using Out
 |   Parameters like x_return_status,x_message_count,x_msg_data to get the status
 |
 |  SCOPE - PUBLIC
 +============================================================================*/

FUNCTION Get_Dim_Attr_Ver_Display_Code (
  p_attribute_id                IN  NUMBER
  ,p_version_id                 IN  NUMBER
) RETURN VARCHAR2

IS

l_attr_ver_display_code           VARCHAR2(150) := NULL;
l_api_name 	  CONSTANT        VARCHAR2(30) := 'Get_Dim_Attr_Ver_Display_Code';
l_prg_msg                         VARCHAR2(2000);

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_2
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => 'Begining Function'
    );

  SELECT version_display_code
  INTO l_attr_ver_display_code
  FROM fem_dim_attr_versions_b
  WHERE attribute_id = p_attribute_id
  AND version_id = p_version_id;

  FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_2
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => 'End'
    );

RETURN l_attr_ver_display_code;

EXCEPTION

  WHEN NO_DATA_FOUND THEN

    FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_4
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => 'Attribute Version Display Code does not'||
          			' Exists for given Attribute ID and Attribute'
        );

    FEM_ENGINES_PKG.User_Message (
       p_app_name  => G_FEM
       ,p_msg_name => c_exp_could_not_found_err
       ,p_token1   => 'API_NAME'
       ,p_value1   => l_api_name
       ,p_token2   => 'DISPLAY_ID'
       ,p_value2   => p_version_id
        );

    RETURN l_attr_ver_display_code;

  WHEN TOO_MANY_ROWS THEN

    FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_4
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => 'Version ID returned more than 1 '||
               		  'Version display code for given Attribute'
        );

    FEM_ENGINES_PKG.User_Message (
       p_app_name  => G_FEM
       ,p_msg_name => c_exp_more_rows_found_err
       ,p_token1   => 'API_NAME'
       ,p_value1   => l_api_name
       ,p_token2   => 'DISPLAY_ID'
       ,p_value2   => p_version_id
        );

    RETURN l_attr_ver_display_code;

  WHEN OTHERS THEN

    l_prg_msg := SQLERRM;

    FEM_ENGINES_PKG.Tech_Message (
        p_severity  => c_log_level_6
        ,p_module   => c_module_pkg||'.'||l_api_name
        ,p_msg_text => l_prg_msg
        );
    RETURN l_attr_ver_display_code;

END Get_Dim_Attr_Ver_Display_Code;

/*============================================================================+
 | FUNCTION
 |   Get_Dim_Attr_Ver_Display_Code
 |
 | DESCRIPTION
 |   This Function returns the Attribute Version Display Code for a given
 |   Attribute Varchar Label and Verion ID
 |   This Method will be used in queries so that's why method is not using Out
 |   Parameters like x_return_status,x_message_count,x_msg_data to get the status
 |
 |  SCOPE - PUBLIC
 +============================================================================*/

FUNCTION Get_Dim_Attr_Ver_Display_Code (
  p_dim_attr_varchar_label        IN  VARCHAR2
  ,p_version_id                   IN  NUMBER
) RETURN VARCHAR2

IS

l_attr_ver_display_code          VARCHAR2(150) := NULL;
l_api_name 	           CONSTANT  VARCHAR2(30) := 'Get_Dim_Attr_Ver_Display_Code';
l_prg_msg                        VARCHAR2(2000);
BEGIN

  FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_2
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => 'Begining Function'
    );

  SELECT a.version_display_code
  INTO l_attr_ver_display_code
  FROM fem_dim_attr_versions_b A,
       fem_dim_attributes_b B
  WHERE b.attribute_varchar_label = p_dim_attr_varchar_label
  AND a.attribute_id = B.attribute_id
  AND a.version_id = p_version_id ;

  FEM_ENGINES_PKG.Tech_Message (
     p_severity  => c_log_level_2
     ,p_module   => c_module_pkg||'.'||l_api_name
     ,p_msg_text => 'End'
    );

RETURN l_attr_ver_display_code;

EXCEPTION

  WHEN NO_DATA_FOUND THEN

    FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_4
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => 'Attribute Version Display Code does not'||
           		       ' Exists for given Version Id and Attribute '
           );

    FEM_ENGINES_PKG.User_Message (
        p_app_name  => G_FEM
       ,p_msg_name => c_exp_could_not_found_err
       ,p_token1   => 'API_NAME'
       ,p_value1   => l_api_name
       ,p_token2   => 'DISPLAY_ID'
       ,p_value2   => p_version_id
           );

    RETURN l_attr_ver_display_code;

  WHEN TOO_MANY_ROWS THEN

    FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_4
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => 'Attribute Version ID returned more than 1 '||
               			'version display code for given attribute'
            );

    FEM_ENGINES_PKG.User_Message (
        p_app_name  => G_FEM
       ,p_msg_name => c_exp_more_rows_found_err
       ,p_token1   => 'API_NAME'
       ,p_value1   => l_api_name
       ,p_token2   => 'DISPLAY_ID'
       ,p_value2   => p_version_id
           );

    RETURN l_attr_ver_display_code;

  WHEN OTHERS THEN

    l_prg_msg := SQLERRM;

    FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_6
       ,p_module   => c_module_pkg||'.'||l_api_name
        ,p_msg_text => l_prg_msg
            );
    RETURN l_attr_ver_display_code;

END Get_Dim_Attr_Ver_Display_Code;

/*============================================================================+
 | FUNCTION
 |   Get_Dim_Attr_Version_ID
 |
 | DESCRIPTION
 |   This Function returns the Attribute Version ID for a given
 |   Attribute varchar label and attribute version display code
 |
 |  SCOPE - PUBLIC
 +============================================================================*/

FUNCTION Get_Dim_Attr_Version_ID (
  p_api_version                   IN  NUMBER     DEFAULT 1.0
  ,p_init_msg_list                IN  VARCHAR2   DEFAULT FND_API.G_FALSE
  ,p_commit                       IN  VARCHAR2   DEFAULT FND_API.G_FALSE
  ,p_encoded                      IN  VARCHAR2   DEFAULT FND_API.G_TRUE
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
  ,p_dim_attr_varchar_label       IN  VARCHAR2
  ,p_dim_attr_ver_display_code    IN  VARCHAR2
) RETURN NUMBER

IS

l_dim_attr_version_id 	           NUMBER := -1;
l_api_name 	   CONSTANT        VARCHAR2(30) := 'Get_Dim_Attr_Version_ID';
l_prg_msg                          VARCHAR2(2000);

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_2
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => 'Begining Function'
    );

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SELECT A.version_id
  INTO l_dim_attr_version_id
  FROM fem_dim_attr_versions_b A,
       fem_dim_attributes_b B
  WHERE B.attribute_varchar_label = p_dim_attr_varchar_label
  AND A.attribute_id = B.attribute_id
  AND A.version_display_code = p_dim_attr_ver_display_code;

  FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_2
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => 'End'
    );

RETURN l_dim_attr_version_id;

EXCEPTION

  WHEN NO_DATA_FOUND THEN

    FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_4
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => 'Attribute Version ID does not Exists '||
           	      'for given Version Display Code and Attribute'
           );

    FEM_ENGINES_PKG.User_Message (
       p_app_name  => G_FEM
       ,p_msg_name => c_imp_could_not_found_err
       ,p_token1   => 'API_NAME'
       ,p_value1   => l_api_name
       ,p_token2   => 'DISPLAY_CODE'
       ,p_value2   => p_dim_attr_ver_display_code
          );

    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN l_dim_attr_version_id;

  WHEN TOO_MANY_ROWS THEN

    FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_4
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => 'Version Display code returned more than 1 '||
               	      'Version ID for given Attribute '
          );

    FEM_ENGINES_PKG.User_Message (
       p_app_name  => G_FEM
       ,p_msg_name => c_imp_more_rows_found_err
       ,p_token1   => 'API_NAME'
       ,p_value1   => l_api_name
       ,p_token2   => 'DISPLAY_CODE'
       ,p_value2   => p_dim_attr_ver_display_code
          );

    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN l_dim_attr_version_id;

  WHEN OTHERS THEN

    l_prg_msg := SQLERRM;

    FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_6
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => l_prg_msg
          );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RETURN l_dim_attr_version_id;

END Get_Dim_Attr_Version_ID;

/*============================================================================+
 | FUNCTION
 |   Get_Dim_Attr_Version_ID
 |
 | DESCRIPTION
 |   This Function returns the Attribute Version ID for a given
 |   Attribute ID and attribute version display code
 |
 |  SCOPE - PUBLIC
 +============================================================================*/

FUNCTION Get_Dim_Attr_Version_ID (
  p_api_version                   IN  NUMBER     DEFAULT 1.0
  ,p_init_msg_list                IN  VARCHAR2   DEFAULT FND_API.G_FALSE
  ,p_commit                       IN  VARCHAR2   DEFAULT FND_API.G_FALSE
  ,p_encoded                      IN  VARCHAR2   DEFAULT FND_API.G_TRUE
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
  ,p_dim_attribute_id             IN  NUMBER
  ,p_dim_attr_ver_display_code    IN  VARCHAR2
) RETURN NUMBER

IS

l_dim_attr_version_id 	          NUMBER := -1;
l_api_name 	 CONSTANT         VARCHAR2(30) := 'Get_Dim_Attr_Version_ID';
l_prg_msg                         VARCHAR2(2000);

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_2
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => 'Begining Function'
    );

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SELECT version_id
  INTO l_dim_attr_version_id
  FROM fem_dim_attr_versions_b
  WHERE attribute_id = p_dim_attribute_id
  AND version_display_code = p_dim_attr_ver_display_code;

  FEM_ENGINES_PKG.Tech_Message (
      p_severity  => c_log_level_2
      ,p_module   => c_module_pkg||'.'||l_api_name
      ,p_msg_text => 'End'
    );

RETURN l_dim_attr_version_id;

EXCEPTION

  WHEN NO_DATA_FOUND THEN

    FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_4
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => 'Attribute Version ID does not Exists for '||
                      'given Attribute Version Display Code and Attribute ID'
       );

    FEM_ENGINES_PKG.User_Message (
       p_app_name  => G_FEM
       ,p_msg_name => c_imp_could_not_found_err
       ,p_token1   => 'API_NAME'
       ,p_value1   => l_api_name
       ,p_token2   => 'DISPLAY_CODE'
       ,p_value2   => p_dim_attr_ver_display_code
       );

    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN l_dim_attr_version_id;

  WHEN TOO_MANY_ROWS THEN

    FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_4
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => 'Attribute Version Display Code returned more than 1 '||
               	      'Version ID for given Attribute ID'
       );

    FEM_ENGINES_PKG.User_Message (
       p_app_name  => G_FEM
       ,p_msg_name => c_imp_more_rows_found_err
       ,p_token1   => 'API_NAME'
       ,p_value1   => l_api_name
       ,p_token2   => 'DISPLAY_CODE'
       ,p_value2   => p_dim_attr_ver_display_code
       );

    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN l_dim_attr_version_id;

  WHEN OTHERS THEN

    l_prg_msg := SQLERRM;

    FEM_ENGINES_PKG.Tech_Message (
        p_severity  => c_log_level_6
        ,p_module   => c_module_pkg||'.'||l_api_name
        ,p_msg_text => l_prg_msg
       );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RETURN l_dim_attr_version_id;

END Get_Dim_Attr_Version_ID;

/*============================================================================+
 | FUNCTION
 |   Get_Dim_Member_Display_Code
 |
 | DESCRIPTION
 |   This Function returns the Member Display Code for a given
 |   Dimension ID and Member ID
 |   This Method will be used in queries so that's why method is not using Out
 |   Parameters like x_return_status,x_message_count,x_msg_data to get the status
 |
 |  SCOPE - PUBLIC
 +============================================================================*/

FUNCTION Get_Dim_Member_Display_Code (
  p_dimension_id                  IN  NUMBER
  ,p_member_id                    IN  NUMBER
) RETURN VARCHAR2
IS

  l_member_display_code            VARCHAR2(150):= NULL;
  l_api_name 	    CONSTANT       VARCHAR2(30) := 'Get_Dim_Member_Display_Code';
  l_prg_msg                        VARCHAR2(2000);
BEGIN

  FEM_ENGINES_PKG.Tech_Message (
      p_severity  => c_log_level_2
      ,p_module   => c_module_pkg||'.'||l_api_name
      ,p_msg_text => 'Begining Function'
      );

  SELECT FEM_DIMENSION_UTIL_PKG.Get_Dim_Member_Display_Code(
                                  XDIM.dimension_id
    				  ,p_member_id
    				  ,DECODE(XDIM.value_set_required_flag
      				  ,'Y',
      				  FEM_DIMENSION_UTIL_PKG.Dimension_Value_Set_Id(XDIM.dimension_id)
      				  ,NULL)
  				 )
  INTO l_member_display_code
  FROM fem_xdim_dimensions_vl XDIM
  WHERE XDIM.dimension_id = p_dimension_id;

  FEM_ENGINES_PKG.Tech_Message (
      p_severity  => c_log_level_2
      ,p_module   => c_module_pkg||'.'||l_api_name
      ,p_msg_text => 'Ending Function'
      );

RETURN l_member_display_code;

EXCEPTION

  WHEN NO_DATA_FOUND THEN

    FEM_ENGINES_PKG.Tech_Message (
        p_severity  => c_log_level_4
        ,p_module   => c_module_pkg||'.'||l_api_name
        ,p_msg_text => 'Dimension Member Display Code does not Exists'||
           			'for given Dimension member ID and Dimension'
       );

    FEM_ENGINES_PKG.User_Message (
       p_app_name  => G_FEM
       ,p_msg_name => c_exp_could_not_found_err
       ,p_token1   => 'API_NAME'
       ,p_value1   => l_api_name
       ,p_token2   => 'DISPLAY_ID'
       ,p_value2   => p_member_id
       );

    RETURN l_member_display_code;

  WHEN TOO_MANY_ROWS THEN

    FEM_ENGINES_PKG.Tech_Message (
        p_severity  => c_log_level_4
        ,p_module   => c_module_pkg||'.'||l_api_name
        ,p_msg_text => 'Dimension Member ID returned more than 1 '||
               	       'Dimension Member display code'
       );

    FEM_ENGINES_PKG.User_Message (
        p_app_name  => G_FEM
        ,p_msg_name => c_exp_more_rows_found_err
        ,p_token1   => 'API_NAME'
        ,p_value1   => l_api_name
        ,p_token2   => 'DISPLAY_ID'
        ,p_value2   => p_member_id
       );

    RETURN l_member_display_code;

  WHEN OTHERS THEN

    l_prg_msg := SQLERRM;

    FEM_ENGINES_PKG.Tech_Message (
        p_severity  => c_log_level_6
        ,p_module   => c_module_pkg||'.'||l_api_name
        ,p_msg_text => l_prg_msg
      );
    RETURN l_member_display_code;

END Get_Dim_Member_Display_Code;

/*============================================================================+
 | FUNCTION
 |   Get_Dim_Member_Display_Code
 |
 | DESCRIPTION
 |   This Function returns the Member Display Code for a given
 |   Dimension varchar Label and Member ID
 |   This Method will be used in queries so that's why method is not using Out
 |   Parameters like x_return_status,x_message_count,x_msg_data to get the status
 |
 |  SCOPE - PUBLIC
 +============================================================================*/

FUNCTION Get_Dim_Member_Display_Code (
  p_dimension_varchar_label       IN  VARCHAR2
  ,p_member_id                    IN  NUMBER
) RETURN VARCHAR2
IS

  l_member_display_code         VARCHAR2(150):= NULL ;
  l_api_name 	  CONSTANT      VARCHAR2(30) := 'Get_Dim_Member_Display_Code';
  l_prg_msg                     VARCHAR2(2000);
BEGIN

  FEM_ENGINES_PKG.Tech_Message (
      p_severity  => c_log_level_2
      ,p_module   => c_module_pkg||'.'||l_api_name
      ,p_msg_text => 'Begining Function'
      );

  SELECT FEM_DIMENSION_UTIL_PKG.Get_Dim_Member_Display_Code(
                      		  XDIM.dimension_id
    				  ,p_member_id
    				  ,DECODE(XDIM.value_set_required_flag
                                  ,'Y'
                                  ,FEM_DIMENSION_UTIL_PKG.Dimension_Value_Set_Id(XDIM.dimension_id)
      				  ,NULL)
  				 )
  INTO l_member_display_code
  FROM fem_xdim_dimensions_vl XDIM
  WHERE XDIM.dimension_varchar_label = p_dimension_varchar_label;

   FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_2
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => 'Ending Function'
       );

RETURN l_member_display_code;

EXCEPTION

  WHEN NO_DATA_FOUND THEN

     FEM_ENGINES_PKG.Tech_Message (
         p_severity  => c_log_level_4
         ,p_module   => c_module_pkg||'.'||l_api_name
         ,p_msg_text => 'Dimension Member Display Code does not'||
           		' Exists for given Dimension member ID and Dimension'
            );

     FEM_ENGINES_PKG.User_Message (
         p_app_name  => G_FEM
         ,p_msg_name => c_exp_could_not_found_err
         ,p_token1   => 'API_NAME'
         ,p_value1   => l_api_name
         ,p_token2   => 'DISPLAY_ID'
         ,p_value2   => p_member_id
            );

    RETURN l_member_display_code;

  WHEN TOO_MANY_ROWS THEN

    FEM_ENGINES_PKG.Tech_Message (
        p_severity  => c_log_level_4
        ,p_module   => c_module_pkg||'.'||l_api_name
        ,p_msg_text => 'Dimension Member ID returned more than 1 '||
                       'Dimension Member display code'
           );

     FEM_ENGINES_PKG.User_Message (
         p_app_name  => G_FEM
         ,p_msg_name => c_exp_more_rows_found_err
         ,p_token1   => 'API_NAME'
         ,p_value1   => l_api_name
         ,p_token2   => 'DISPLAY_ID'
         ,p_value2   => p_member_id
            );

    RETURN l_member_display_code;

  WHEN OTHERS THEN

    l_prg_msg := SQLERRM;

    FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_6
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => l_prg_msg
           );
    RETURN l_member_display_code;

END Get_Dim_Member_Display_Code;

/*============================================================================+
 | FUNCTION
 |   Get_Dim_Member_ID
 |
 | DESCRIPTION
 |   This Function returns the Member ID for a given Dimension
 |   Varchar Label and Member Display Code
 |
 |  SCOPE - PUBLIC
 +============================================================================*/

FUNCTION Get_Dim_Member_ID (
  p_api_version                   IN  NUMBER     DEFAULT 1.0
  ,p_init_msg_list                IN  VARCHAR2   DEFAULT FND_API.G_FALSE
  ,p_commit                       IN  VARCHAR2   DEFAULT FND_API.G_FALSE
  ,p_encoded                      IN  VARCHAR2   DEFAULT FND_API.G_TRUE
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
  ,p_dimension_varchar_label      IN  VARCHAR2
  ,p_member_display_code          IN  VARCHAR2
  ) RETURN NUMBER

IS

  l_member_id                     NUMBER;
  l_value_set_id                  NUMBER;
  l_value_set_display_code        VARCHAR2(150);

  l_return_status                 VARCHAR2(1);
  l_msg_count                     NUMBER;
  l_msg_data                      VARCHAR2(240);
  l_api_name 	    CONSTANT      VARCHAR2(30) := 'Get_Dim_Member_ID';
  l_prg_msg                       VARCHAR2(2000);

BEGIN

  l_member_id := -1;
  l_value_set_id := NULL;
  l_value_set_display_code := NULL;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FEM_ENGINES_PKG.Tech_Message (
        p_severity  => c_log_level_2
        ,p_module   => c_module_pkg||'.'||l_api_name
        ,p_msg_text => 'Begining Function'
       );

  SELECT DECODE(XDIM.value_set_required_flag
		,'Y'
                ,FEM_DIMENSION_UTIL_PKG.Dimension_Value_Set_Id(XDIM.dimension_id)
    		,NULL
    		)
  INTO l_value_set_id
  FROM fem_xdim_dimensions_vl XDIM
  WHERE XDIM.dimension_varchar_label = p_dimension_varchar_label;

  FEM_ENGINES_PKG.Tech_Message (
        p_severity  => c_log_level_1
        ,p_module   => c_module_pkg||'.'||l_api_name
        ,p_msg_text => 'The Value Set ID is '||l_value_set_id
      );

  IF (l_value_set_id IS NOT NULL) THEN
  ------------------------------
  --Get Value Set Display Code
  ------------------------------
    SELECT value_set_display_code
    INTO l_value_set_display_code
    FROM fem_value_sets_b
    WHERE value_set_id = l_value_set_id;

  FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_1
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => ' The Value Set Display Code for '||l_value_set_id||
      		     ' is '||l_value_set_display_code
      );

  END IF;
-------------------------------
--Get Member ID
-------------------------------
  l_member_id := FEM_DIMENSION_UTIL_PKG.Get_Dim_Member_ID (
      p_api_version                  => 1.0
      ,p_init_msg_list               => p_init_msg_list
      ,p_commit                      => p_commit
      ,p_encoded                     => p_encoded
      ,x_return_status               => l_return_status
      ,x_msg_count                   => l_msg_count
      ,x_msg_data                    => l_msg_data
      ,p_dimension_varchar_label     => p_dimension_varchar_label
      ,p_member_display_code         => p_member_display_code
      ,p_member_vs_display_code      => l_value_set_display_code
    );

  x_return_status:=l_return_status;

  FEM_ENGINES_PKG.Tech_Message (
     p_severity  => c_log_level_2
     ,p_module   => c_module_pkg||'.'||l_api_name
     ,p_msg_text => 'Ending Function'
       );

RETURN l_member_id;

EXCEPTION

  WHEN NO_DATA_FOUND THEN

    FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_4
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => 'Either of the Value Set ID or '||
                      'Value Set Code is null '
          );

   FEM_ENGINES_PKG.User_Message (
       p_app_name  => G_FEM
       ,p_msg_name => c_vsid_or_vscode_null
       ,p_token1   => 'API_NAME'
       ,p_value1   => l_api_name
          );

    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN l_member_id;

  WHEN TOO_MANY_ROWS THEN

        FEM_ENGINES_PKG.Tech_Message (
             p_severity  => c_log_level_4
             ,p_module   => c_module_pkg||'.'||l_api_name
             ,p_msg_text => 'Value Set ID returned more than 1 '||
               		    'Value Set display code or Vice Versa'
         );

    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN l_member_id;

  WHEN OTHERS THEN

      l_prg_msg := SQLERRM;

          FEM_ENGINES_PKG.Tech_Message (
             p_severity  => c_log_level_6
             ,p_module   => c_module_pkg||'.'||l_api_name
             ,p_msg_text => l_prg_msg
         );

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RETURN l_member_id;

END Get_Dim_Member_ID;

/*============================================================================+
 | FUNCTION
 |   Get_Dim_Member_ID
 |
 | DESCRIPTION
 |   This Function returns the Member ID for a given Dimension ID
 |   and Member Display Code
 |
 |  SCOPE - PUBLIC
 +============================================================================*/

FUNCTION Get_Dim_Member_ID (
  p_api_version                   IN  NUMBER     DEFAULT 1.0
  ,p_init_msg_list                IN  VARCHAR2   DEFAULT FND_API.G_FALSE
  ,p_commit                       IN  VARCHAR2   DEFAULT FND_API.G_FALSE
  ,p_encoded                      IN  VARCHAR2   DEFAULT FND_API.G_TRUE
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
  ,p_dimension_id                 IN  NUMBER
  ,p_member_display_code          IN  VARCHAR2
  ) RETURN NUMBER
IS

  l_dimension_varchar_label       VARCHAR2(30);
  l_member_id                     NUMBER;
  l_value_set_id                  NUMBER;
  l_value_set_display_code        VARCHAR2(150);

  l_return_status                 VARCHAR2(1);
  l_msg_count                     NUMBER;
  l_msg_data                      VARCHAR2(240);
  l_api_name         CONSTANT 	  VARCHAR2(30) := 'Get_Dim_Member_ID';
  l_prg_msg                       VARCHAR2(2000);

  e_bad_dim_id                    EXCEPTION;
  e_bad_vs_id                     EXCEPTION;
  e_bad_vs_dim_id                 EXCEPTION;
  e_too_many_vs_codes             EXCEPTION;

BEGIN

  l_member_id := -1;
  l_value_set_id := NULL;
  l_value_set_display_code := NULL;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FEM_ENGINES_PKG.Tech_Message (
        p_severity  => c_log_level_2
        ,p_module   => c_module_pkg||'.'||l_api_name
        ,p_msg_text => 'Begining Function'
       );

-------------------------------------
--Getting The Dimension Varchar Label
-------------------------------------
BEGIN
  SELECT dimension_varchar_label
  INTO   l_dimension_varchar_label
  FROM   fem_xdim_dimensions_vl
  WHERE dimension_id = p_dimension_id;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    RAISE e_bad_dim_id;

END;

  BEGIN
    -------------------------------
    --Getting Value Set ID
    -------------------------------
    SELECT DECODE(XDIM.value_set_required_flag
           ,'Y'
           ,FEM_DIMENSION_UTIL_PKG.Dimension_Value_Set_Id(XDIM.dimension_id)
           ,NULL
           )
    INTO l_value_set_id
    FROM fem_xdim_dimensions_vl XDIM
    WHERE XDIM.dimension_id = p_dimension_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    RAISE e_bad_vs_dim_id;

  END;

  FEM_ENGINES_PKG.Tech_Message (
        p_severity  => c_log_level_1
        ,p_module   => c_module_pkg||'.'||l_api_name
        ,p_msg_text => 'The Value Set ID is '||l_value_set_id
       );

--------------------------------
--Getting Value Set Display Code
--------------------------------

  IF (l_value_set_id IS NOT NULL) THEN
    BEGIN
      SELECT value_set_display_code
      INTO l_value_set_display_code
      FROM fem_value_sets_b
      WHERE value_set_id = l_value_set_id;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE e_bad_vs_id;

      WHEN TOO_MANY_ROWS THEN
        RAISE e_too_many_vs_codes;

    END;
    FEM_ENGINES_PKG.Tech_Message (
         p_severity  => c_log_level_1
         ,p_module   => c_module_pkg||'.'||l_api_name
         ,p_msg_text => 'The Value Set Code for '||l_value_set_id||
       		        ' is ' || l_value_set_display_code
        );

   END IF;

  ---------------------------------
  --Getting Member Id
  ---------------------------------
  l_member_id := FEM_DIMENSION_UTIL_PKG.Get_Dim_Member_ID (
    p_api_version                  => 1.0
    ,p_init_msg_list               => p_init_msg_list
    ,p_commit                      => p_commit
    ,p_encoded                     => p_encoded
    ,x_return_status               => l_return_status
    ,x_msg_count                   => l_msg_count
    ,x_msg_data                    => l_msg_data
    ,p_dimension_varchar_label     => l_dimension_varchar_label
    ,p_member_display_code         => p_member_display_code
    ,p_member_vs_display_code      => l_value_set_display_code
  );

  x_return_status := l_return_status;

  FEM_ENGINES_PKG.Tech_Message (
        p_severity  => c_log_level_2
        ,p_module   => c_module_pkg||'.'||l_api_name
        ,p_msg_text => 'Ending Function'
       );

RETURN l_member_id;

EXCEPTION

  WHEN e_bad_dim_id THEN

    FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_4
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => 'Dimension Varchar Label Does NOT Exists '||
             	      'for given Dimension ID '
             );

   FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => c_exp_could_not_found_err
      ,p_token1   => 'API_NAME'
      ,p_value1   => l_api_name
      ,p_token2   => 'DISPLAY_ID'
      ,p_value2   => p_dimension_id
             );

    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN l_member_id;

  WHEN e_bad_vs_id THEN

    FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_4
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => 'Value Set Code Does NOT Exists '||
             	      'for given Value Set ID '
             );
   FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => c_exp_could_not_found_err
      ,p_token1   => 'API_NAME'
      ,p_value1   => l_api_name
      ,p_token2   => 'DISPLAY_ID'
      ,p_value2   => l_value_set_id
             );

    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN l_member_id;

  WHEN e_bad_vs_dim_id THEN

    FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_4
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => 'Value Set ID does NOT exists for '||
           	      'given Dimension ID '
            );

   FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => c_vsid_dim_not_found_err
      ,p_token1   => 'API_NAME'
      ,p_value1   => l_api_name
      ,p_token2   => 'DIMENSION'
      ,p_value2   => p_dimension_id
             );

    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN l_member_id;

  WHEN e_too_many_vs_codes THEN

    FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_4
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => 'Value Set ID returned more than 1 '||
               	      'Value Set display code '
            );

    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN l_member_id;

  WHEN OTHERS THEN

      l_prg_msg := SQLERRM;

      FEM_ENGINES_PKG.Tech_Message (
         p_severity  => c_log_level_6
         ,p_module   => c_module_pkg||'.'||l_api_name
         ,p_msg_text => l_prg_msg
            );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RETURN l_member_id;

END Get_Dim_Member_ID;

/*============================================================================+
 | FUNCTION
 |   Get_Value_Set_Display_Code
 |
 | DESCRIPTION
 |   This Function returns the value Set Display Code for a given
 |   Value Set ID
 |   This Method will be used in queries so that's why method is not using Out
 |   Parameters like x_return_status,x_message_count,x_msg_data to get the status
 |
 |  SCOPE - PUBLIC
 +============================================================================*/

FUNCTION Get_Value_Set_Display_Code (
  p_value_set_id                  IN  NUMBER
   ) RETURN VARCHAR2

IS

l_value_set_display_code  VARCHAR2(150):= NULL;
l_api_name 	  CONSTANT    VARCHAR2(30) := 'Get_Value_Set_Display_Code';
l_prg_msg                 VARCHAR2(2000);

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
        p_severity  => c_log_level_2
        ,p_module   => c_module_pkg||'.'||l_api_name
        ,p_msg_text => 'Begining Function'
       );

  SELECT value_set_display_code
  INTO l_value_set_display_code
  FROM fem_value_sets_b
  WHERE value_set_id= p_value_set_id;

  FEM_ENGINES_PKG.Tech_Message (
        p_severity  => c_log_level_2
        ,p_module   => c_module_pkg||'.'||l_api_name
        ,p_msg_text => 'Ending Function'
       );
RETURN l_value_set_display_code;

EXCEPTION

  WHEN NO_DATA_FOUND THEN

     FEM_ENGINES_PKG.Tech_Message (
        p_severity  => c_log_level_4
        ,p_module   => c_module_pkg||'.'||l_api_name
        ,p_msg_text => 'Value Set Display Code does not'||
           			' Exists for given Value Set ID'
          );

     FEM_ENGINES_PKG.User_Message (
        p_app_name  => G_FEM
        ,p_msg_name => c_exp_could_not_found_err
        ,p_token1   => 'API_NAME'
        ,p_value1   => l_api_name
        ,p_token2   => 'DISPLAY_ID'
        ,p_value2   => p_value_set_id
           );

    RETURN l_value_set_display_code;

  WHEN TOO_MANY_ROWS THEN

    FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_4
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => 'Value Set ID returned more than 1 '||
               			    'Value Set display code'
          );

    FEM_ENGINES_PKG.User_Message (
       p_app_name  => G_FEM
       ,p_msg_name => c_exp_more_rows_found_err
       ,p_token1   => 'API_NAME'
       ,p_value1   => l_api_name
       ,p_token2   => 'DISPLAY_ID'
       ,p_value2   => p_value_set_id
          );

    RETURN l_value_set_display_code;

  WHEN OTHERS THEN

    l_prg_msg := SQLERRM;

    FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_6
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => l_prg_msg
          );
    RETURN l_value_set_display_code;

END Get_Value_Set_Display_Code;

/*============================================================================+
 | FUNCTION
 |   Get_Value_Set_ID
 |
 | DESCRIPTION
 |   This Function returns the value Set ID for a given
 |   Value Set Display Code
 |
 |  SCOPE - PUBLIC
 +============================================================================*/

FUNCTION Get_Value_Set_ID (
  p_api_version                   IN  NUMBER     DEFAULT 1.0
  ,p_init_msg_list                IN  VARCHAR2   DEFAULT FND_API.G_FALSE
  ,p_commit                       IN  VARCHAR2   DEFAULT FND_API.G_FALSE
  ,p_encoded                      IN  VARCHAR2   DEFAULT FND_API.G_TRUE
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
  ,p_value_set_display_code       IN  VARCHAR2
   ) RETURN NUMBER
IS

l_value_set_id    		   NUMBER   := -1;
l_api_name 	     CONSTANT  VARCHAR2(30) := 'Get_Value_Set_Id';
l_prg_msg                  VARCHAR2(2000);

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FEM_ENGINES_PKG.Tech_Message (
      p_severity  => c_log_level_2
      ,p_module   => c_module_pkg||'.'||l_api_name
      ,p_msg_text => 'Begining Function'
     );


  SELECT value_set_id
  INTO l_value_set_id
  FROM fem_value_sets_b
  WHERE value_set_display_code= p_value_set_display_code;

  FEM_ENGINES_PKG.Tech_Message (
      p_severity  => c_log_level_2
      ,p_module   => c_module_pkg||'.'||l_api_name
      ,p_msg_text => 'Ending Function'
    );

RETURN l_value_set_id;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
   FEM_ENGINES_PKG.Tech_Message (
      p_severity  => c_log_level_4
      ,p_module   => c_module_pkg||'.'||l_api_name
      ,p_msg_text => 'Value Set Display Code does not'||
         		      ' Exists for given Value Set ID'
          );

    FEM_ENGINES_PKG.User_Message (
       p_app_name  => G_FEM
       ,p_msg_name => c_imp_could_not_found_err
       ,p_token1   => 'API_NAME'
       ,p_value1   => l_api_name
       ,p_token2   => 'DISPLAY_CODE'
       ,p_value2   => p_value_set_display_code
          );

    x_return_status := FND_API.G_RET_STS_ERROR;

    RETURN l_value_set_id;

  WHEN TOO_MANY_ROWS THEN
    FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_4
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => 'Value Set Code returned more than 1 '||
               	      'Value Set ID'
          );

    FEM_ENGINES_PKG.User_Message (
       p_app_name  => G_FEM
       ,p_msg_name => c_imp_more_rows_found_err
       ,p_token1   => 'API_NAME'
       ,p_value1   => l_api_name
       ,p_token2   => 'DISPLAY_CODE'
       ,p_value2   => p_value_set_display_code
          );

    x_return_status := FND_API.G_RET_STS_ERROR;

    RETURN l_value_set_id;

  WHEN OTHERS THEN

   l_prg_msg := SQLERRM;

   FEM_ENGINES_PKG.Tech_Message (
      p_severity  => c_log_level_6
      ,p_module   => c_module_pkg||'.'||l_api_name
      ,p_msg_text => l_prg_msg
          );

   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   RETURN l_value_set_id;

END Get_Value_Set_ID;

/*============================================================================+
 | FUNCTION
 |   Get_Gl_Period_Num
 |
 | DESCRIPTION
 |   This Function returns the GL Period Number for a given
 |   Calendar Period ID,specifically designed for handling Calendar Period Dimension
 |   This Method will be used in queries so that's why method is not using Out
 |   Parameters like x_return_status,x_message_count,x_msg_data to get the status
 |
 |  SCOPE - PUBLIC
 +============================================================================*/

FUNCTION Get_Gl_Period_Num(
   p_cal_period_id                 IN NUMBER
   ) RETURN NUMBER

IS
l_gl_period_num           NUMBER := -1;
l_api_name      CONSTANT  VARCHAR2(30):= 'Get_Gl_Period_Num';
l_prg_msg                 VARCHAR2(2000);
BEGIN

  FEM_ENGINES_PKG.Tech_Message (
        p_severity  => c_log_level_2
        ,p_module   => c_module_pkg||'.'||l_api_name
        ,p_msg_text => 'Begining Function'
       );

  SELECT CALP_ATTR.number_assign_value
  INTO l_gl_period_num
  FROM fem_cal_periods_attr calp_attr
  ,fem_dim_attributes_b ATTR
  ,fem_dim_attr_versions_b VER
  ,fem_xdim_dimensions_vl XDIM
  WHERE XDIM.dimension_varchar_label = 'CAL_PERIOD'
  AND ATTR.dimension_id = XDIM.dimension_id
  AND ATTR.attribute_varchar_label = 'GL_PERIOD_NUM'
  AND VER.attribute_id = ATTR.attribute_id
  AND VER.default_version_flag = 'Y'
  AND CALP_ATTR.cal_period_id = p_cal_period_id
  AND CALP_ATTR.attribute_id = ATTR.attribute_id
  AND CALP_ATTR.version_id = VER.version_id;

  FEM_ENGINES_PKG.Tech_Message (
        p_severity  => c_log_level_2
        ,p_module   => c_module_pkg||'.'||l_api_name
        ,p_msg_text => 'Ending Function'
       );
RETURN l_gl_period_num;

EXCEPTION

  WHEN NO_DATA_FOUND THEN

     FEM_ENGINES_PKG.Tech_Message (
        p_severity  => c_log_level_4
        ,p_module   => c_module_pkg||'.'||l_api_name
        ,p_msg_text => 'GL Peroid number does not Exists for '||
           			'cal period ID'
          );

    FEM_ENGINES_PKG.User_Message (
       p_app_name  => G_FEM
       ,p_msg_name => c_gl_period_num_not_found_err
       ,p_token1   => 'API_NAME'
       ,p_value1   => l_api_name
       ,p_token2   => 'CAL_PERIOD_ID'
       ,p_value2   => p_cal_period_id
          );

    RETURN l_gl_period_num;

  WHEN TOO_MANY_ROWS THEN

    FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_4
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => 'More than 1 records exists for given '||
               			    'dimension and cal period ID'
          );
    RETURN l_gl_period_num;

  WHEN OTHERS THEN

    l_prg_msg := SQLERRM;

    FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_6
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => l_prg_msg
          );
    RETURN l_gl_period_num;

END Get_Gl_Period_Num;

/*============================================================================+
 | FUNCTION
 |   Get_Cal_Period_End_Date
 |
 | DESCRIPTION
 |   This Function returns the Calendar Period End Date for a given
 |   Calendar Period ID,specifically designed for handling Calendar Period Dimension
 |   This Method will be used in queries so that's why method is not using Out
 |   Parameters like x_return_status,x_message_count,x_msg_data to get the status
 |
 | SCOPE - PUBLIC
 +============================================================================*/

FUNCTION Get_Cal_Period_End_Date(
  p_cal_period_id                 IN NUMBER
   ) RETURN DATE

IS
l_cal_period_end_date           DATE;
l_api_name            CONSTANT  VARCHAR2(30):= 'Get_Cal_Period_End_Date';
l_prg_msg                        VARCHAR2(2000);
BEGIN

  FEM_ENGINES_PKG.Tech_Message (
        p_severity  => c_log_level_2
        ,p_module   => c_module_pkg||'.'||l_api_name
        ,p_msg_text => 'Begining Function'
       );

  SELECT CALP_ATTR.date_assign_value
  INTO l_cal_period_end_date
  FROM fem_cal_periods_attr calp_attr
  ,fem_dim_attributes_b ATTR
  ,fem_dim_attr_versions_b VER
  ,fem_xdim_dimensions_vl XDIM
  WHERE XDIM.dimension_varchar_label = 'CAL_PERIOD'
  AND ATTR.dimension_id = XDIM.dimension_id
  AND ATTR.attribute_varchar_label = 'CAL_PERIOD_END_DATE'
  AND VER.attribute_id = ATTR.attribute_id
  AND VER.default_version_flag = 'Y'
  AND CALP_ATTR.cal_period_id = p_cal_period_id
  AND CALP_ATTR.attribute_id = ATTR.attribute_id
  AND CALP_ATTR.version_id = VER.version_id;

  FEM_ENGINES_PKG.Tech_Message (
        p_severity  => c_log_level_2
        ,p_module   => c_module_pkg||'.'||l_api_name
        ,p_msg_text => 'Ending Function'
       );
RETURN l_cal_period_end_date;

EXCEPTION

  WHEN NO_DATA_FOUND THEN

     FEM_ENGINES_PKG.Tech_Message (
        p_severity  => c_log_level_4
        ,p_module   => c_module_pkg||'.'||l_api_name
        ,p_msg_text => 'Cal Peroid End Date does not Exists for '||
           	       'given cal period ID'
          );

     FEM_ENGINES_PKG.User_Message (
        p_app_name  => G_FEM
        ,p_msg_name => c_calp_end_date_not_found_err
        ,p_token1   => 'API_NAME'
        ,p_value1   => l_api_name
        ,p_token2   => 'CAL_PERIOD_ID'
        ,p_value2   => p_cal_period_id
          );

    RETURN l_cal_period_end_date;

  WHEN TOO_MANY_ROWS THEN

    FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_4
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => 'More than 1 records exists for given '||
               	      'dimension and cal period ID'
          );
    RETURN l_cal_period_end_date;

  WHEN OTHERS THEN

    l_prg_msg := SQLERRM;

    FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_6
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => l_prg_msg
          );
    RETURN l_cal_period_end_date;

END Get_Cal_Period_End_Date;


/*============================================================================+
 | FUNCTION
 |   Get_Object_ID
 |
 | DESCRIPTION
 |   This Function returns Object ID corresponding to given
 |   Object Definition ID
 |
 | SCOPE - PUBLIC
 +============================================================================*/

FUNCTION Get_Object_ID (
  p_api_version                   IN  NUMBER     DEFAULT 1.0
  ,p_init_msg_list                IN  VARCHAR2   DEFAULT FND_API.G_FALSE
  ,p_commit                       IN  VARCHAR2   DEFAULT FND_API.G_FALSE
  ,p_encoded                      IN  VARCHAR2   DEFAULT FND_API.G_TRUE
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
  ,p_object_def_id                IN  NUMBER
   ) RETURN NUMBER
IS

l_object_id    		   NUMBER   := -1;
l_api_name 	  CONSTANT VARCHAR2(30) := 'Get_Object_ID';
l_prg_msg                  VARCHAR2(2000);

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FEM_ENGINES_PKG.Tech_Message (
      p_severity  => c_log_level_2
      ,p_module   => c_module_pkg||'.'||l_api_name
      ,p_msg_text => 'Begining Function'
     );


  SELECT object_id
  INTO l_object_id
  FROM fem_object_definition_vl
  WHERE object_definition_id = p_object_def_id;

  FEM_ENGINES_PKG.Tech_Message (
      p_severity  => c_log_level_2
      ,p_module   => c_module_pkg||'.'||l_api_name
      ,p_msg_text => 'Ending Function'
    );

RETURN l_object_id;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
   FEM_ENGINES_PKG.Tech_Message (
      p_severity  => c_log_level_4
      ,p_module   => c_module_pkg||'.'||l_api_name
      ,p_msg_text => 'Object ID does not'||
         	      ' Exists for given Object Def ID'
          );
   FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => c_obj_def_id_not_found_err
      ,p_token1   => 'API_NAME'
      ,p_value1   => l_api_name
      ,p_token2   => 'OBJ_ID'
      ,p_value2   => p_object_def_id
          );
    x_return_status := FND_API.G_RET_STS_ERROR;

    RETURN l_object_id;

  WHEN TOO_MANY_ROWS THEN
    FEM_ENGINES_PKG.Tech_Message (
       p_severity  => c_log_level_4
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => 'Object Def ID returned more than 1 '||
               	      'Objects ID'
          );

    x_return_status := FND_API.G_RET_STS_ERROR;

    RETURN l_object_id;

  WHEN OTHERS THEN

   l_prg_msg := SQLERRM;

   FEM_ENGINES_PKG.Tech_Message (
      p_severity  => c_log_level_6
      ,p_module   => c_module_pkg||'.'||l_api_name
      ,p_msg_text => l_prg_msg
          );

   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   RETURN l_object_id;

END Get_Object_ID;

/*============================================================================+
 | FUNCTION
 |   Get_Dimension_Id
 |
 | DESCRIPTION
 |   This Function returns the Dimension ID corresponding to a
 |   Dimension_Varchar_Label
 |
 |  SCOPE - PUBLIC
 +============================================================================*/

FUNCTION Get_Dimension_Id(
  p_api_version                   IN  NUMBER     DEFAULT 1.0
  ,p_init_msg_list                IN  VARCHAR2   DEFAULT FND_API.G_FALSE
  ,p_commit                       IN  VARCHAR2   DEFAULT FND_API.G_FALSE
  ,p_encoded                      IN  VARCHAR2   DEFAULT FND_API.G_TRUE
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
  ,p_dimension_varchar_label     IN  VARCHAR2
) RETURN NUMBER

IS

l_dimension_id                NUMBER := -1;
l_api_name 	        CONSTANT  VARCHAR2(30) := 'Get_Dimension_Id';
l_prg_msg                     VARCHAR2(2000);

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
     p_severity  => c_log_level_2
     ,p_module   => c_module_pkg||'.'||l_api_name
     ,p_msg_text => 'Begining Function'
  );
 x_return_status := FND_API.G_RET_STS_SUCCESS;

 SELECT dimension_id
 INTO   l_dimension_id
 FROM  fem_dimensions_vl
 WHERE dimension_varchar_label = p_dimension_varchar_label;

  FEM_ENGINES_PKG.Tech_Message (
        p_severity  => c_log_level_2
        ,p_module   => c_module_pkg||'.'||l_api_name
        ,p_msg_text => 'Ending Function'
  );

x_return_status := FND_API.G_RET_STS_SUCCESS;

RETURN l_dimension_id;

EXCEPTION

  WHEN OTHERS THEN

    l_prg_msg := SQLERRM;

    FEM_ENGINES_PKG.Tech_Message (
                     p_severity  => c_log_level_6
                     ,p_module   => c_module_pkg||'.'||l_api_name
                     ,p_msg_text => l_prg_msg
            );
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN l_dimension_id;

END Get_Dimension_Id;

END FEM_MIR_PKG;

/
