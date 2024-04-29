--------------------------------------------------------
--  DDL for Package Body FEM_WEBADI_HIER_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_WEBADI_HIER_UTILS_PVT" AS
/* $Header: FEMVADIHIERUTILB.pls 120.2 2007/10/26 10:31:35 lkiran ship $*/

------------------------------
-- Declare Global variables --
------------------------------
G_PKG_NAME CONSTANT VARCHAR2(30) := 'FEM_WEBADI_HIER_UTILS_PVT' ;
--
-- Global variables to handle population
-- of Hier Header info only once.
--
--
------------------------------
-- Write Private Procedures --
------------------------------
/*===========================================================================+
               Procedure Name       : Upload_Hierarchy_Header
+===========================================================================*/
PROCEDURE log_message
(p_debug_message IN VARCHAR2
)
IS
  --
  PRAGMA AUTONOMOUS_TRANSACTION ;
  --
BEGIN
  --
  -- Put your debug message here.
  NULL ;
  --COMMIT ;
  --
END ;

PROCEDURE Delete_Old_Run
( p_hierarchy_object_name       IN VARCHAR2
, p_hierarchy_obj_def_disp_name IN VARCHAR2
)
IS
  --
  l_delete_str VARCHAR2(4000) := NULL ;
  l_status     VARCHAR2(4)    := 'LOAD' ;
  --
BEGIN
  --
  -- Delete from fem_hier_value_sets_t table
  --
  DELETE FROM
    fem_hier_value_sets_t hiervset
  WHERE
    hiervset.hierarchy_object_name      = p_hierarchy_object_name
    AND hiervset.value_set_display_code = g_global_val_tbl(1).value_set_display_code;

  --
  -- Delete from intf_hierarchy_table_name table
  --
  l_delete_str := 'DELETE FROM ' ||
                    g_global_val_tbl(1).hierarchy_intf_table_name|| ' hier' ||
                  ' WHERE ' ||
                  '   hier.hierarchy_object_name              = ' ||
                  '     :b_hierarchy_object_name ' ||
                  '   AND hier.hierarchy_obj_def_display_name = ' ||
                  '     :b_hier_obj_def_display_name ' ;
  --
  --
  EXECUTE IMMEDIATE
    l_delete_str
  USING
    p_hierarchy_object_name
  , p_hierarchy_obj_def_disp_name;
  --
  -- Delete from fem_hier_dim_grps_t table
  --
  DELETE FROM
    fem_hier_dim_grps_t dimgrp
  WHERE
    dimgrp.hierarchy_object_name = p_hierarchy_object_name;

END Delete_Old_Run;

/*===========================================================================+
Procedure Name       : Upload_Hierarchy_Header
Parameters           :
IN                   : p_api_version                  NUMBER
                       p_init_msg_lis                 VARCHAR2
                       p_commit                       VARCHAR2
                       p_intf_hierarchy_table_name    VARCHAR2
                       p_value_set_required_flag      VARCHAR2
                       p_dimension_varchar_label      VARCHAR2
                       p_hierarchy_object_name        VARCHAR2
                       p_hierarchy_obj_def_disp_name  VARCHAR2
                       p_folder_name                  VARCHAR2
                       p_hierarchy_type_code          VARCHAR2
                       p_multi_top_flag               VARCHAR2
                       p_multi_value_set_flag         VARCHAR2
                       p_calendar_display_code        VARCHAR2
                       p_hierarchy_usage_code         VARCHAR2
                       p_group_sequence_enforced_code VARCHAR2
                       p_effective_start_date         DATE
                       p_effective_end_date           DATE
                       p_language                     VARCHAR2
OUT                  : x_return_status                VARCHAR2
                       x_msg_count                    NUMBER
                       x_msg_data                     VARCHAR2

Description          : Populates Hierarchy Header information.

Modification History :
Date        Name       Desc
----------  ---------  -------------------------------------------------------
10/05/2005  SHTRIPAT   Created.
----------  ---------  -------------------------------------------------------
+===========================================================================*/
PROCEDURE Upload_Hierarchy_Header
( x_return_status                OUT NOCOPY VARCHAR2
, x_msg_count                    OUT NOCOPY NUMBER
, x_msg_data                     OUT NOCOPY VARCHAR2
, p_api_version                  IN         NUMBER
, p_init_msg_list                IN         VARCHAR2
, p_commit                       IN         VARCHAR2
, p_intf_hierarchy_table_name    IN         VARCHAR2
, p_value_set_required_flag      IN         VARCHAR2
, p_dimension_varchar_label      IN         VARCHAR2
, p_hierarchy_object_name        IN         VARCHAR2
, p_hierarchy_obj_def_disp_name  IN         VARCHAR2
, p_folder_name                  IN         VARCHAR2
, p_hierarchy_type_code          IN         VARCHAR2
, p_multi_top_flag               IN         VARCHAR2
, p_multi_value_set_flag         IN         VARCHAR2
, p_calendar_display_code        IN         VARCHAR2
, p_hierarchy_usage_code         IN         VARCHAR2
, p_group_sequence_enforced_code IN         VARCHAR2
, p_effective_start_date         IN         DATE
, p_effective_end_date           IN         DATE
, p_language                     IN         VARCHAR2
)
IS
  --
  l_api_name CONSTANT   VARCHAR2(30) := 'Upload_Hierarchy_Header' ;
  --
  l_return_status       VARCHAR2(1) ;
  l_msg_count           NUMBER ;
  l_msg_data            VARCHAR2(2000) ;
  --
  l_record_count        NUMBER := -1 ;
  --
  l_flattened_rows_flag VARCHAR2(1)  := 'N' ;
  l_status              VARCHAR2(30) := NULL;
  --
  l_dim_migration_flag  VARCHAR2(1)  := NULL ;
  --
BEGIN
  --
  SAVEPOINT Upload_Hierarchy_Header ;
  --

  BEGIN
    SELECT STATUS
    INTO   l_status
    FROM   FEM_HIERARCHIES_T
    WHERE  HIERARCHY_OBJECT_NAME = p_hierarchy_object_name
    AND    HIER_OBJ_DEF_DISPLAY_NAME = p_hierarchy_obj_def_disp_name;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;
  END;

  IF (l_status is null)
  THEN

    INSERT
    INTO
      fem_hierarchies_t
      ( hierarchy_object_name
      , folder_name
      , language
      , dimension_varchar_label
      , hierarchy_type_code
      , group_sequence_enforced_code
      , multi_top_flag
      , multi_value_set_flag
      , hierarchy_usage_code
      , flattened_rows_flag
      , status
      , hier_obj_def_display_name
      , effective_start_date
      , effective_end_date
      , calendar_display_code
      , created_by_dim_migration_flag
      )
    VALUES
    ( p_hierarchy_object_name
    , p_folder_name
    , p_language
    , p_dimension_varchar_label
    , p_hierarchy_type_code
    , p_group_sequence_enforced_code
    , p_multi_top_flag
    , p_multi_value_set_flag
    , p_hierarchy_usage_code
    , l_flattened_rows_flag
    , 'LOAD'
    , p_hierarchy_obj_def_disp_name
    , p_effective_start_date
    , p_effective_end_date
    , p_calendar_display_code
    , l_dim_migration_flag
    ) ;

  ELSIF (l_status <> 'LOAD')
  THEN

    UPDATE
      fem_hierarchies_t hier
    SET
      hier.hierarchy_type_code           = p_hierarchy_type_code
    , hier.multi_top_flag                = p_multi_top_flag
    , hier.multi_value_set_flag          = p_multi_value_set_flag
    , hier.hierarchy_usage_code          = p_hierarchy_usage_code
    , hier.group_sequence_enforced_code  = p_group_sequence_enforced_code
    , hier.effective_start_date          = p_effective_start_date
    , hier.effective_end_date            = p_effective_end_date
    , hier.folder_name                   = p_folder_name
    , hier.dimension_varchar_label       = p_dimension_varchar_label
    , language                           = p_language
    , status                             = 'LOAD'
    WHERE
      hier.hierarchy_object_name         = p_hierarchy_object_name
      AND hier.hier_obj_def_display_name = p_hierarchy_obj_def_disp_name ;

    Delete_Old_Run
    ( p_hierarchy_object_name       => p_hierarchy_object_name
    , p_hierarchy_obj_def_disp_name => p_hierarchy_obj_def_disp_name
    ) ;

  END IF;
  --
  IF FND_API.To_Boolean ( p_commit )
  THEN
    COMMIT ;
  END IF ;
  --
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS ;
  --
  -- Commenting out the Exception block to
  -- propogate the exact exception back to
  -- Web ADI.
  -- Needs discussion.
/*EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Upload_Hierarchy_Header ;
    --
    x_return_status := FND_API.G_RET_STS_ERROR ;
    --
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data
    ) ;
    --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Upload_Hierarchy_Header ;
    --
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data
    ) ;
    --
  WHEN OTHERS THEN
    ROLLBACK TO Upload_Hierarchy_Header ;
    --
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( p_pkg_name       => G_PKG_NAME,
        p_procedure_name => l_api_name
      ) ;
    END IF;
    --
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data
    ) ;
    --*/
END Upload_Hierarchy_Header ;

/*===========================================================================+
Procedure Name       : Insert_HierInfo_forTime_Dim
Parameters           :
IN                   : p_hierarchy_object_name       VARCHAR2
                       p_hierarchy_obj_def_disp_name VARCHAR2
                       p_parent_display_code         VARCHAR2
                       p_child_display_code          VARCHAR2
                       p_language                    VARCHAR2
OUT                  : x_return_status               VARCHAR2
                       x_msg_count                   NUMBER
                       x_msg_data                    VARCHAR2

Description          : Populates Hierarchy Detail information
                       for Time Dimension.

Modification History :
Date        Name       Desc
----------  ---------  -------------------------------------------------------
10/05/2005  SHTRIPAT   Created.
----------  ---------  -------------------------------------------------------
+===========================================================================*/
PROCEDURE Insert_HierInfo_forTime_Dim
( x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
, p_hierarchy_object_name       IN         VARCHAR2
, p_hierarchy_obj_def_disp_name IN         VARCHAR2
, p_parent_display_code         IN         VARCHAR2
, p_child_display_code          IN         VARCHAR2
, p_child_grp_disp_code         IN         VARCHAR2
, p_parent_grp_disp_code        IN         VARCHAR2
, p_language                    IN         VARCHAR2
)
IS
  --
  l_api_name CONSTANT        VARCHAR2(30) := 'Insert_HierInfo_forTime_Dim' ;
  --
  l_grp_dtl_sql              VARCHAR2(4000) ; -- Dimension Group Detail sql
  --
  l_parnt_grp_disp_code
    fem_dimension_grps_b.dimension_group_display_code%TYPE := NULL ;
  l_parnt_grp_seq
    fem_dimension_grps_b.dimension_group_seq%TYPE          := NULL ;
  l_child_grp_disp_code
    fem_dimension_grps_b.dimension_group_display_code%TYPE := NULL ;
  l_child_grp_seq
    fem_dimension_grps_b.dimension_group_seq%TYPE          := NULL ;
  --
  l_disp_order_num_sql       VARCHAR2(4000) := NULL ;
  l_next_disp_order_num      NUMBER ;
  l_required_flag            VARCHAR2(1)    := 'Y' ;
  l_dimension_id             NUMBER         := NULL ;
  --
  l_parent_cp_end_date       DATE   := NULL ;
  l_parent_period_num        NUMBER := NULL ;
  l_child_cp_end_date        DATE   := NULL ;
  l_child_period_num         NUMBER := NULL ;
  --
  l_end_date_label  CONSTANT VARCHAR2(19) := 'CAL_PERIOD_END_DATE' ;
  l_gl_period_label CONSTANT VARCHAR2(13) := 'GL_PERIOD_NUM' ;
  --
  l_hier_t_insert_sql        VARCHAR2(4000) := NULL ;
  l_hier_t_update_sql        VARCHAR2(4000) := NULL ;
  --
  l_language                 VARCHAR2(50) := USERENV('LANG') ;
  l_err_message_text         VARCHAR2(4000) ;
  --
  l_status                   VARCHAR2(4)  := 'LOAD' ;
  --
  -- Cursor to retrieve date_assign_value and number_assign_value
  -- from CAL_PERIOD_ATTR table for given display_code
  CURSOR l_cal_period_csr
         ( display_code    VARCHAR2
         , dim_id          NUMBER
         , end_date_label  VARCHAR2
         , gl_period_label VARCHAR2
         )
  IS
  SELECT
    cpattr.date_assign_value
  , cpattr.number_assign_value
  , dimattr.attribute_varchar_label
  FROM
    fem_dim_attributes_b dimattr
  , fem_cal_periods_attr cpattr
  WHERE
    cpattr.cal_period_id     = display_code
    AND cpattr.version_id    = ( SELECT
                                   attrver.version_id
                                 FROM
                                   fem_dim_attr_versions_b attrver
                                 WHERE
                                   attrver.attribute_id             =
                                     cpattr.attribute_id
                                   AND attrver.default_version_flag =
                                     l_required_flag
                               )
    AND cpattr.attribute_id  = dimattr.attribute_id
    AND dimattr.dimension_id = dim_id
    AND ( dimattr.attribute_varchar_label = end_date_label
          OR
          dimattr.attribute_varchar_label = gl_period_label
        ) ;
  --
BEGIN
  --

  SAVEPOINT Insert_HierInfo_forTime_Dim ;
  --
  l_dimension_id := g_global_val_tbl(1).dimension_id ;
  --
  -- Retrieve l_parent_cp_end_date and l_parent_period_num
  FOR l_cal_period_csr_rec IN l_cal_period_csr ( p_parent_display_code
                                               , l_dimension_id
                                               , l_end_date_label
                                               , l_gl_period_label
                                               )
  LOOP
    --
    IF ( l_cal_period_csr_rec.attribute_varchar_label = l_end_date_label )
    THEN
      l_parent_cp_end_date := l_cal_period_csr_rec.date_assign_value ;
    ELSE
      l_parent_period_num  := l_cal_period_csr_rec.number_assign_value ;
    END IF ;
    --
  END LOOP ;
  --
  -- Retrieve the next display_order_number from hier_intf table.
  l_disp_order_num_sql := 'SELECT' ||
                          '  NVL(MAX(hier_intf.display_order_num), 0)' ||
                          ' FROM ' ||
                           g_global_val_tbl(1).hierarchy_intf_table_name ||
                           ' hier_intf ' ||
                           'WHERE ' ||
                             'hier_intf.parent_cal_period_end_date = :1' ||
                             ' AND hier_intf.parent_cal_period_number' ||
                             '  = :2' ;
  --
  BEGIN
    --
    EXECUTE IMMEDIATE
      l_disp_order_num_sql
    INTO
      l_next_disp_order_num
    USING
      l_parent_cp_end_date
    , l_parent_period_num ;
    --
    l_next_disp_order_num := l_next_disp_order_num + 1 ;
    --
  END ;
  --
  -- If p_child_disply_code <> p_parent_display_code, then
  -- repeat the above logic to find out l_child_cp_end_date
  -- and l_child_period_num
  IF ( p_child_display_code <> p_parent_display_code )
  THEN
    --
    FOR l_cal_period_csr_rec IN l_cal_period_csr ( p_child_display_code
                                                 , l_dimension_id
                                                 , l_end_date_label
                                                 , l_gl_period_label
                                                 )
    LOOP
      --
      IF ( l_cal_period_csr_rec.attribute_varchar_label = l_end_date_label )
      THEN
        l_child_cp_end_date := l_cal_period_csr_rec.date_assign_value ;
      ELSE
        l_child_period_num  := l_cal_period_csr_rec.number_assign_value ;
      END IF ;
      --
    END LOOP ;
    --
  ELSE
    --
      l_child_cp_end_date := l_parent_cp_end_date ;
      l_child_period_num  := l_parent_period_num ;
    --
  END IF ;
  --
  -- Prepare insert sql for hier_t table.
  l_hier_t_insert_sql := 'INSERT INTO ' ||
                         g_global_val_tbl(1).hierarchy_intf_table_name ||
                         '( hierarchy_object_name'||
                         ', hierarchy_obj_def_display_name' ||
                         ', parent_cal_period_end_date' ||
                         ', parent_cal_period_number' ||
                         ', child_cal_period_end_date' ||
                         ', child_cal_period_number' ||
                         ', parent_dim_grp_display_code' ||
                         ', child_dim_grp_display_code' ||
                         ', calendar_display_code' ||
                         ', display_order_num' ||
                         ', language' ||
                         ', status' ||
                         ')' ||
                         'VALUES' ||
                         '( :hier_obj_name' ||
                         ', :hier_obj_def_disp_name' ||
                         ', :parent_cal_period_end_date' ||
                         ', :parent_cp_number' ||
                         ', :child_cp_end_date' ||
                         ', :child_cp_number' ||
                         ', :parent_dim_grp_disp_code' ||
                         ', :child_dim_grp_disp_code' ||
                         ', :calendar_disp_code' ||
                         ', :disp_order_num' ||
                         ', :lang' ||
                         ', :stts' ||
                         ')' ;
  --
  BEGIN
    --
    EXECUTE IMMEDIATE
      l_hier_t_insert_sql
    USING
      p_hierarchy_object_name
    , p_hierarchy_obj_def_disp_name
    , l_parent_cp_end_date
    , l_parent_period_num
    , l_child_cp_end_date
    , l_child_period_num
    , p_parent_grp_disp_code
    , p_child_grp_disp_code
    , g_global_val_tbl(1).calendar_display_code
    , l_next_disp_order_num
    , p_language
    , 'LOAD' ;
  --
  EXCEPTION
    --
    WHEN DUP_VAL_ON_INDEX THEN
      --
      l_hier_t_update_sql := 'UPDATE ' ||
                               g_global_val_tbl(1).hierarchy_intf_table_name ||
                             ' SET ' ||
                             '   calendar_display_code = ' ||
                             '     :b_calendar_display_code' ||
                             ' , display_order_num     = ' ||
                             '     :b_display_order_num' ||
                             ' , language              = :b_language ' ||
                             ' , status                = :b_status' ||
                             ' WHERE ' ||
                             '   hierarchy_object_name              = ' ||
                             '     :b_hierarchy_object_name ' ||
                             '   AND hierarchy_obj_def_display_name = ' ||
                             '     :b_hier_obj_def_disp_name ' ||
                             '   AND parent_dim_grp_display_code    = ' ||
                             '     :b_parent_dim_grp_disp_code ' ||
                             '   AND parent_cal_period_end_date     = ' ||
                             '     :b_parent_cal_period_end_date ' ||
                             '   AND parent_cal_period_number       = ' ||
                             '     :b_parent_cal_period_number ' ||
                             '   AND child_dim_grp_display_code     = ' ||
                             '     :b_child_dim_grp_display_code ' ||
                             '   AND child_cal_period_end_date      = ' ||
                             '     :b_child_cal_period_end_date ' ||
                             '   AND child_cal_period_number        = ' ||
                             '     :b_child_cal_period_number' ;

      EXECUTE IMMEDIATE
        l_hier_t_update_sql
      USING
        g_global_val_tbl(1).calendar_display_code
      , l_next_disp_order_num
      , p_language
      , 'LOAD'
      , p_hierarchy_object_name
      , p_hierarchy_obj_def_disp_name
      , p_parent_grp_disp_code
      , l_parent_cp_end_date
      , l_parent_period_num
      , p_child_grp_disp_code
      , l_child_cp_end_date
      , l_child_period_num ;
      --
  END ;
  --
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS ;
  --
  -- Commenting out the Exception block to
  -- propogate the exact exception back to
  -- Web ADI.
  -- Needs discussion.
/*EXCEPTION
  --
  WHEN OTHERS THEN
    ROLLBACK TO Insert_HierInfo_forTime_Dim ;
    --
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( p_pkg_name       => G_PKG_NAME,
        p_procedure_name => l_api_name
      ) ;
    END IF;
    --
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data
    ) ;
    --*/
END Insert_HierInfo_forTime_Dim ;

/*===========================================================================+
Procedure Name       : Insert_HierInfo_forNonTime_Dim
Parameters           :
IN                   : p_hierarchy_object_name       VARCHAR2
                       p_hierarchy_obj_def_disp_name VARCHAR2
                       p_parent_display_code         VARCHAR2
                       p_child_display_code          VARCHAR2
                       p_language                    VARCHAR2
OUT                  : x_return_status               VARCHAR2
                       x_msg_count                   NUMBER
                       x_msg_data                    VARCHAR2

Description          : Populates Hierarchy Detail information
                       for Non Time dimensions.

Modification History :
Date        Name       Desc
----------  ---------  -------------------------------------------------------
10/05/2005  SHTRIPAT   Created.
----------  ---------  -------------------------------------------------------
+===========================================================================*/
PROCEDURE Insert_HierInfo_forNonTime_Dim
( x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
, p_hierarchy_object_name       IN         VARCHAR2
, p_hierarchy_obj_def_disp_name IN         VARCHAR2
, p_parent_display_code         IN         VARCHAR2
, p_child_display_code          IN         VARCHAR2
, p_language                    IN         VARCHAR2
)
IS
  --
  l_api_name CONSTANT        VARCHAR2(30)   :=
    'Insert_HierInfo_forNonTime_Dim' ;
  --
  --Bug#5959147: Increase variable size to match db col size
  l_parent_vs_disp_code      VARCHAR2(150)   := NULL ;
  l_child_vs_disp_code       VARCHAR2(150)   := NULL ;
  --
  l_disp_order_num_sql       VARCHAR2(4000) := NULL ;
  l_next_disp_order_num      NUMBER ;
  --
  l_hier_t_ins_select_clause VARCHAR2(4000) := NULL ;
  l_hier_t_ins_values_clause VARCHAR2(4000) := NULL ;
  l_hier_t_insert_sql        VARCHAR2(4000) := NULL ;
  --
  l_hier_t_upd_set_clause    VARCHAR2(4000) := NULL ;
  l_hier_t_upd_where_clause  VARCHAR2(4000) := NULL ;
  l_hier_t_update_sql        VARCHAR2(4000) := NULL ;
  --
  l_status                   VARCHAR2(4)    := 'LOAD' ;
  --
BEGIN
  --
  SAVEPOINT Insert_HierInfo_forNonTime_Dim ;
  --
  -- Now populate hierarchy_intf_table_name table.
  IF ( g_global_val_tbl(1).value_set_required_flag = 'Y' )
  THEN
    --
    l_parent_vs_disp_code := g_global_val_tbl(1).value_set_display_code ;
    l_child_vs_disp_code  := g_global_val_tbl(1).value_set_display_code ;
    --
    -- fem_hier_value_sets_t is an interface table that designates
    -- the value sets for Analytic dimension hierarchies that will
    -- be loaded using the Dimension Hierarchy Loader.
    -- This will be done only when creating new hierarchies of any
    -- dimension except for the Calendar Period.
    BEGIN
      INSERT FIRST
      WHEN ( cnt = 0 ) THEN
      INTO
        fem_hier_value_sets_t
        ( hierarchy_object_name
        , value_set_display_code
        , language
        , status
        )
      VALUES
      ( p_hierarchy_object_name
      , l_parent_vs_disp_code  -- Reusing the display code. Nothing special.
      , p_language
      , l_status
      )
      SELECT
        COUNT(1) AS cnt
      FROM
        fem_hier_value_sets_t hiervs
      WHERE
        hiervs.hierarchy_object_name      = p_hierarchy_object_name
        AND hiervs.value_set_display_code = l_parent_vs_disp_code ;
      --
      IF ( SQL%ROWCOUNT = 0 ) -- Record already exists.
      THEN
        --
        UPDATE
          fem_hier_value_sets_t hiervset
        SET
          hiervset.language = p_language
        , hiervset.status   = l_status
        WHERE
          hiervset.hierarchy_object_name      = p_hierarchy_object_name
          AND hiervset.value_set_display_code = l_parent_vs_disp_code ;
        --
      END IF ;
    END ;
    --
  END IF ;
  --
  -- Retrieve the next display_order_number from hier_intf table.
  l_disp_order_num_sql := 'SELECT' ||
                          '  NVL(MAX(hier_intf.display_order_num), 0)' ||
                          ' FROM ' ||
                           g_global_val_tbl(1).hierarchy_intf_table_name ||
                           ' hier_intf' ||
                           ' WHERE' ||
                             ' hier_intf.parent_display_code = :disp_code ' ;
  --
  BEGIN
    --
    EXECUTE IMMEDIATE
      l_disp_order_num_sql
    INTO
      l_next_disp_order_num
    USING
      p_parent_display_code ;
    --
    l_next_disp_order_num := l_next_disp_order_num + 1 ;
    --
  END ;
  --
  -- Prepare insert sql for hier_t table.
  l_hier_t_ins_select_clause := 'INSERT INTO ' ||
                                g_global_val_tbl(1).hierarchy_intf_table_name ||
                                '( hierarchy_object_name'||
                                ', hierarchy_obj_def_display_name' ||
                                ', parent_display_code' ||
                                ', child_display_code' ||
                                ', display_order_num' ||
                                ', language' ||
                                ', status' ;
  --
  l_hier_t_ins_values_clause := 'VALUES' ||
                                '( :hier_obj_name' ||
                                ', :hier_obj_def_disp_name' ||
                                ', :parent_disp_code' ||
                                ', :child_disp_code' ||
                                ', :disp_order_num' ||
                                ', :lang' ||
                                ', :stts' ;
  --
  l_hier_t_upd_set_clause    := 'UPDATE ' ||
                                g_global_val_tbl(1).hierarchy_intf_table_name ||
                                ' SET ' ||
                                '   display_order_num = :b_display_order_num' ||
                                ' , language          = :b_language' ||
                                ' , status            = :b_status' ;
  --
  l_hier_t_upd_where_clause  := ' WHERE ' ||
                                '   hierarchy_object_name         = ' ||
                                '   :b_hierarchy_object_name ' ||
                                '   AND hierarchy_obj_def_display_name = ' ||
                                '  :b_hier_obj_def_display_name ' ||
                                '  AND parent_display_code            = ' ||
                                '   :b_parent_display_code ' ||
                                '  AND child_display_code             = ' ||
                                '   :b_child_display_code ' ;
  --
  IF (  g_global_val_tbl(1).value_set_required_flag = 'Y' )
  THEN
    --
    l_hier_t_ins_select_clause := l_hier_t_ins_select_clause ||
                                  ', parent_value_set_display_code' ||
                                  ', child_value_set_display_code' ||
                                  ')' ;
    --
    l_hier_t_ins_values_clause := l_hier_t_ins_values_clause ||
                                  ', :parent_vs_disp_code' ||
                                  ', :child_vs_disp_code' ||
                                  ')' ;
    --
    l_hier_t_insert_sql := l_hier_t_ins_select_clause ||
                           l_hier_t_ins_values_clause ;
    --
    BEGIN
    --
      EXECUTE IMMEDIATE
        l_hier_t_insert_sql
      USING
        p_hierarchy_object_name
      , p_hierarchy_obj_def_disp_name
      , p_parent_display_code
      , p_child_display_code
      , l_next_disp_order_num
      , p_language
      , 'LOAD'
      , l_parent_vs_disp_code
      , l_child_vs_disp_code ;
      --
    EXCEPTION
      --
      WHEN DUP_VAL_ON_INDEX THEN
        --
        l_hier_t_upd_where_clause := l_hier_t_upd_where_clause ||
                                      ' AND parent_value_set_display_code = ' ||
                                      '   :b_parent_value_set_disp_code ' ||
                                      ' AND child_value_set_display_code  = ' ||
                                      '   :b_child_value_set_disp_code' ;
        --
        l_hier_t_update_sql       := l_hier_t_upd_set_clause ||
                                     l_hier_t_upd_where_clause ;
        --
        EXECUTE IMMEDIATE
          l_hier_t_update_sql
        USING
         l_next_disp_order_num
       , p_language
       , 'LOAD'
       , p_hierarchy_object_name
       , p_hierarchy_obj_def_disp_name
       , p_parent_display_code
       , p_child_display_code
       , l_parent_vs_disp_code
       , l_child_vs_disp_code ;
       --
    END ;
    --
  ELSE
    --
    l_hier_t_insert_sql := l_hier_t_ins_select_clause ||
                           ')' ||
                           l_hier_t_ins_values_clause ||
                           ')' ;
    --
    BEGIN
    --
      EXECUTE IMMEDIATE
        l_hier_t_insert_sql
      USING
        p_hierarchy_object_name
      , p_hierarchy_obj_def_disp_name
      , p_parent_display_code
      , p_child_display_code
      , l_next_disp_order_num
      , p_language
      , 'LOAD' ;
      --
    EXCEPTION
      --
      WHEN DUP_VAL_ON_INDEX THEN
        --
        l_hier_t_update_sql := l_hier_t_upd_set_clause ||
                               l_hier_t_upd_where_clause ;
        --
        EXECUTE IMMEDIATE
          l_hier_t_update_sql
        USING
          l_next_disp_order_num
       , p_language
       , 'LOAD'
       , p_hierarchy_object_name
       , p_hierarchy_obj_def_disp_name
       , p_parent_display_code
       , p_child_display_code ;
       --
    END ;
    --
  END IF ;
  --
  -- Commenting out the Exception block to
  -- propogate the exact exception back to
  -- Web ADI.
  -- Needs discussion.
/*EXCEPTION
  --
  WHEN OTHERS THEN
    ROLLBACK TO Upload_Hierarchy_Details ;
    --
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( p_pkg_name       => G_PKG_NAME,
        p_procedure_name => l_api_name
      ) ;
    END IF;
    --
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data
    ) ;
    --*/
END Insert_HierInfo_forNonTime_Dim ;

/*===========================================================================+
Procedure Name       : Upload_Hierarchy_Details
Parameters           :
IN                   : p_api_version                  NUMBER
                       p_init_msg_lis                 VARCHAR2
                       p_commit                       VARCHAR2
                       p_intf_hierarchy_table_name    VARCHAR2
                       p_value_set_required_flag      VARCHAR2
                       p_dimension_varchar_label      VARCHAR2
                       p_hierarchy_object_name        VARCHAR2
                       p_hierarchy_obj_def_disp_name  VARCHAR2
                       p_folder_name                  VARCHAR2
                       p_hierarchy_type_code          VARCHAR2
                       p_multi_top_flag               VARCHAR2
                       p_multi_value_set_flag         VARCHAR2
                       p_calendar_display_code        VARCHAR2
                       p_hierarchy_usage_code         VARCHAR2
                       p_group_sequence_enforced_code VARCHAR2
                       p_effective_start_date         DATE
                       p_effective_end_date           DATE
                       p_language                     VARCHAR2
OUT                  : x_return_status                VARCHAR2
                       x_msg_count                    NUMBER
                       x_msg_data                     VARCHAR2

Description          : Populates Hierarchy Detail information.

Modification History :
Date        Name       Desc
----------  ---------  -------------------------------------------------------
10/05/2005  SHTRIPAT   Created.
----------  ---------  -------------------------------------------------------
+===========================================================================*/
PROCEDURE Upload_Hierarchy_Details
( x_return_status                 OUT NOCOPY VARCHAR2
, x_msg_count                     OUT NOCOPY NUMBER
, x_msg_data                      OUT NOCOPY VARCHAR2
, p_api_version                   IN         NUMBER
, p_init_msg_list                 IN         VARCHAR2
, p_commit                        IN         VARCHAR2
, p_language                      IN         VARCHAR2
, p_hierarchy_object_name         IN         VARCHAR2
, p_hierarchy_obj_def_disp_name   IN         VARCHAR2
, p_sequence_enforced_code        IN         VARCHAR2
, p_calendar_display_code         IN         VARCHAR2
, p_parent_display_code           IN         VARCHAR2
, p_child_display_code            IN         VARCHAR2
)
IS
  --
  l_api_name CONSTANT        VARCHAR2(30) := 'Upload_Hierarchy_Details' ;
  --
  l_return_status            VARCHAR2(1) ;
  l_msg_count                NUMBER ;
  l_msg_data                 VARCHAR2(2000) ;
  --
  l_grp_dtl_sql              VARCHAR2(4000) ; -- Dimension Group Detail sql
  --
  l_parnt_grp_disp_code
    fem_dimension_grps_b.dimension_group_display_code%TYPE := NULL ;
  l_parnt_grp_seq
    fem_dimension_grps_b.dimension_group_seq%TYPE          := NULL ;
  l_child_grp_disp_code
    fem_dimension_grps_b.dimension_group_display_code%TYPE := NULL ;
  l_child_grp_seq
    fem_dimension_grps_b.dimension_group_seq%TYPE          := NULL ;
  --
  l_disp_order_num_sql       VARCHAR2(4000) := NULL ;
  l_next_disp_order_num      NUMBER ;
  l_required_flag            VARCHAR2(1)    := 'Y' ;
  l_dimension_id             NUMBER         := NULL ;
  --
  l_parent_cp_end_date       DATE           := NULL ;
  l_parent_period_num        NUMBER         := NULL ;
  --
  l_end_date_label  CONSTANT VARCHAR2(19)   := 'CAL_PERIOD_END_DATE' ;
  l_gl_period_label CONSTANT VARCHAR2(13)   := 'GL_PERIOD_NUM' ;
  --
  l_language                 VARCHAR2(50)   := USERENV('LANG') ;
  l_err_message_text         VARCHAR2(4000) ;
  --
  l_status                   VARCHAR2(4)    := 'LOAD' ;
  --
BEGIN
  --
  SAVEPOINT Upload_Hierarchy_Details ;
  --
  --! STEP 1 !--
  -- If a hierarchy does not use Groups
  IF ( p_sequence_enforced_code <> 'NO_GROUPS' )
  THEN
    --
    -- Frame the sql to retrieve parent_group_display_code, parent_group_seq
    -- and child_group_display_code, child_group_seq.
    l_grp_dtl_sql := 'SELECT' ||
                     '  dimgrp.dimension_group_display_code' ||
                     ', dimgrp.dimension_group_seq ' ||
                     'FROM' ||
                     '  ' || g_global_val_tbl(1).member_b_table_name ||
                     ' dimmem' ||
                     ', fem_dimension_grps_b dimgrp ' ||
                     'WHERE' ||
                     '  dimmem.'||
                     g_global_val_tbl(1).member_display_code_col ||
                     ' = :b_display_code' ||
                     ' AND dimmem.dimension_group_id =' ||
                     '   dimgrp.dimension_group_id' ;
    --
    BEGIN
      --
      -- Run the query for child_display_code.
      EXECUTE IMMEDIATE
        l_grp_dtl_sql
      INTO
        l_child_grp_disp_code
      , l_child_grp_seq
      USING
        p_child_display_code;
      --
    END ;
    --
    -- Now do Insert/Update in fem_hier_dim_grps_t table
    -- with l_child_grp_disp_code.
    BEGIN
      --
      INSERT
      INTO
        fem_hier_dim_grps_t
        ( hierarchy_object_name
        , language
        , status
        , dimension_group_display_code
        )
      VALUES
      ( p_hierarchy_object_name
      , l_language
      , l_status
      , l_child_grp_disp_code
      ) ;
      --
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        --
        UPDATE
          fem_hier_dim_grps_t hiergrp
        SET
          hiergrp.language = l_language
        , hiergrp.status   = l_status
        WHERE
          hiergrp.dimension_group_display_code = l_child_grp_disp_code
          AND hiergrp.hierarchy_object_name    = p_hierarchy_object_name ;
        --
    END ;
    --
    -- If p_parent_display_code and p_child_display_code
    -- are different, get the details for p_parent_display_code
    -- and do the DML in fem_hier_dim_grps_t.
    IF ( p_parent_display_code <> p_child_display_code )
    THEN
      --
      BEGIN
        --
        -- Run the query for parent_display_code.
        EXECUTE IMMEDIATE
          l_grp_dtl_sql
        INTO
          l_parnt_grp_disp_code
        , l_parnt_grp_seq
        USING
          p_parent_display_code ;
        --
        INSERT
        INTO
          fem_hier_dim_grps_t
          ( hierarchy_object_name
          , language
          , status
          , dimension_group_display_code
          )
        VALUES
        ( p_hierarchy_object_name
        , l_language
        , l_status
        , l_parnt_grp_disp_code
        ) ;
        --
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          --
          UPDATE
            fem_hier_dim_grps_t hiergrp
          SET
            hiergrp.language = l_language
          , hiergrp.status   = l_status
          WHERE
            hiergrp.dimension_group_display_code = l_parnt_grp_disp_code
            AND hiergrp.hierarchy_object_name    = p_hierarchy_object_name ;
          --
      END ;
      --
    ELSE
      -- Since parent_display_code and p_child_code are same,
      -- assign l_parnt_grp_disp_code and l_parnt_grp_seq
      -- to l_child_grp_disp_code and l_child_grp_seq respectivily.
      l_parnt_grp_disp_code := l_child_grp_disp_code ;
      l_parnt_grp_seq       := l_child_grp_seq ;
    END IF ;
    --
  END IF ;
  --
  --! STEP 2 !--
  -- Now populate hierarchy_intf_table_name table.

  -- If not a TIME dimension, then proceed.
  IF ( g_global_val_tbl(1).dimension_type_code <> 'TIME' )
  THEN
    --
    Insert_HierInfo_forNonTime_Dim
    ( x_return_status               => l_return_status
    , x_msg_count                   => l_msg_count
    , x_msg_data                    => l_msg_data
    , p_hierarchy_object_name       => p_hierarchy_object_name
    , p_hierarchy_obj_def_disp_name => p_hierarchy_obj_def_disp_name
    , p_parent_display_code         => p_parent_display_code
    , p_child_display_code          => p_child_display_code
    , p_language                    => l_language
    ) ;
    --
  ELSE -- If TIME dimension then proceed.
    --
    Insert_HierInfo_forTime_Dim
    ( x_return_status               => l_return_status
    , x_msg_count                   => l_msg_count
    , x_msg_data                    => l_msg_data
    , p_hierarchy_object_name       => p_hierarchy_object_name
    , p_hierarchy_obj_def_disp_name => p_hierarchy_obj_def_disp_name
    , p_parent_display_code         => p_parent_display_code
    , p_child_display_code          => p_child_display_code
    , p_child_grp_disp_code         => l_child_grp_disp_code
    , p_parent_grp_disp_code        => l_parnt_grp_disp_code
    , p_language                    => l_language
    ) ;
    --
  END IF ;
  --
  IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS )
  THEN
    RAISE FND_API.G_EXC_ERROR ;
  END IF ;
  --
  IF ( FND_API.To_Boolean (p_commit) )
  THEN
    COMMIT ;
  END IF ;
  --
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS ;
  --
  -- Commenting out the Exception block to
  -- propogate the exact exception back to
  -- Web ADI.
  -- Needs discussion.
/*EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Upload_Hierarchy_Details ;
    --
    x_return_status := FND_API.G_RET_STS_ERROR ;
    --
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data
    ) ;
    --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Upload_Hierarchy_Details ;
    --
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data
    ) ;
    --
  WHEN OTHERS THEN
    ROLLBACK TO Upload_Hierarchy_Details ;
    --
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( p_pkg_name       => G_PKG_NAME,
        p_procedure_name => l_api_name
      ) ;
    END IF;
    --
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data
    ) ;
    --*/
END Upload_Hierarchy_Details ;

/*===========================================================================+
Procedure Name       : Populate_Dim_Metadata_Info
Parameters           :
IN                   : p_dimension_varchar_label VARCHAR2
OUT                  : x_return_status           VARCHAR2

Description          : Populates global variables with metadata information
                       of the supplied p_dimension_varchar_label.

Modification History :
Date        Name       Desc
----------  ---------  -------------------------------------------------------
09/23/2005  SHTRIPAT   Created.
----------  ---------  -------------------------------------------------------
+===========================================================================*/
PROCEDURE Populate_Dim_Metadata_Info
( x_return_status           OUT NOCOPY VARCHAR2
, p_dimension_varchar_label IN         VARCHAR2
)
IS
  --
  -- Retrieve the metadata information of
  -- the supplied p_dimension_varchar_label.
  CURSOR l_Ret_Dim_Metadata_csr
  IS
  SELECT
    dimension_id
  , intf_member_b_table_name
  , intf_member_tl_table_name
  , intf_attribute_table_name
  , member_b_table_name
  , member_display_code_col
  , member_name_col
  , hierarchy_table_name
  , dimension_type_code
  , group_use_code
  , value_set_required_flag
  FROM
    fem_xdim_dimensions_vl xDimVL
  WHERE
    xDimVL.dimension_varchar_label = p_dimension_varchar_label ;
  --
  -- Retrieve the value_set_display_code for given ledger_id
  -- and dimension_id.
  CURSOR l_VS_Disp_Code_csr
  IS
  SELECT
    VS.value_set_display_code
  FROM
    fem_Value_Sets_vl VS
  WHERE
    VS.value_set_id = ( FEM_DIMENSION_UTIL_PKG.Dimension_Value_Set_Id
                        ( g_global_val_tbl(1).dimension_id -- p_dimension_id
                        , g_global_val_tbl(1).ledger_id    -- p_ledger_id
                        )
                      ) ;
  --
BEGIN
  --
  -- Populate global variables with Dimemension metadata.
  FOR l_ret_dim_metadata_csr_rec IN l_Ret_Dim_Metadata_csr
  LOOP
    g_global_val_tbl(1).dimension_id              :=
      l_ret_dim_metadata_csr_rec.dimension_id ;
    g_global_val_tbl(1).dimension_varchar_label   :=
      p_dimension_varchar_label ;
    g_global_val_tbl(1).intf_member_b_table_name :=
      l_ret_dim_metadata_csr_rec.intf_member_b_table_name ;
    g_global_val_tbl(1).intf_member_tl_table_name :=
      l_ret_dim_metadata_csr_rec.intf_member_tl_table_name ;
    g_global_val_tbl(1).intf_attribute_table_name :=
      l_ret_dim_metadata_csr_rec.intf_attribute_table_name ;
    g_global_val_tbl(1).member_b_table_name       :=
      l_ret_dim_metadata_csr_rec.member_b_table_name ;
    g_global_val_tbl(1).member_display_code_col   :=
      l_ret_dim_metadata_csr_rec.member_display_code_col ;
    g_global_val_tbl(1).member_name_col           :=
      l_ret_dim_metadata_csr_rec.member_name_col ;
    g_global_val_tbl(1).hierarchy_intf_table_name :=
      l_ret_dim_metadata_csr_rec.hierarchy_table_name || '_T' ;
    g_global_val_tbl(1).dimension_type_code       :=
      NVL( l_ret_dim_metadata_csr_rec.dimension_type_code, 'XYZ' ) ;
    g_global_val_tbl(1).group_use_code            :=
      NVL( l_ret_dim_metadata_csr_rec.group_use_code, 'NOT_SUPPORTED' ) ;
    g_global_val_tbl(1).value_set_required_flag   :=
      NVL( l_ret_dim_metadata_csr_rec.value_set_required_flag, 'N' ) ;
  END LOOP ;
  --
  -- Get the Value_Set_Display_code if
  -- g_global_val_tbl(1).value_set_required_flag is Y.
  g_global_val_tbl(1).value_set_display_code := NULL ;
  IF ( g_global_val_tbl(1).value_set_required_flag = 'Y' )
  THEN
    --
    FOR l_VS_Disp_Code_csr_rec IN l_VS_Disp_Code_csr
    LOOP
      --
      g_global_val_tbl(1).value_set_display_code :=
        l_VS_Disp_Code_csr_rec.value_set_display_code ;
      --
    END LOOP ;
    --
  END IF ;
  --
  g_global_val_tbl(1).dim_grp_disp_code := NULL ;
  -- If group_use_code is <> NOT_SUPPORTED, then
  -- assign the global variable.
  IF ( g_global_val_tbl(1).group_use_code <> 'NOT_SUPPORTED' )
  THEN
    g_global_val_tbl(1).dim_grp_disp_code :=
      g_global_val_tbl(1).group_use_code ;
  END IF ;
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS ;
  --
  -- Commenting out the Exception block to
  -- propogate the exact exception back to
  -- Web ADI.
  -- Needs discussion.
/*EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Populate_Dim_Metadata_Info ;
    --
    x_return_status := FND_API.G_RET_STS_ERROR ;
    --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Populate_Dim_Metadata_Info ;
    --
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --
  WHEN OTHERS THEN
    ROLLBACK TO Populate_Dim_Metadata_Info ;
    --
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --*/
END Populate_Dim_Metadata_Info ;

-----------------------------
-- Write Public Procedures --
-----------------------------

/*===========================================================================+
Procedure Name       : Upload_Hierarchy_Interface
Parameters           :
IN                   : p_folder_name                 VARCHAR2
                       p_hierarchy_type_code         VARCHAR2
                       p_multi_top_flag              VARCHAR2
                       p_multi_value_set_flag        VARCHAR2
                       p_calendar_display_code       VARCHAR2
                       p_hierarchy_usage_code        VARCHAR2
                       p_effective_start_date        DATE
                       p_effective_end_date          DATE
                       p_value_set_display_code      VARCHAR2
                       p_language                    VARCHAR2
                       p_dimension_varchar_label     VARCHAR2
                       p_hierarchy_object_name       VARCHAR2
                       p_hierarchy_obj_def_disp_name VARCHAR2
                       p_parent_display_code         VARCHAR2
                       p_child_display_code          VARCHAR2
                       p_create_level                VARCHAR2
OUT                  : None

Description          : This program writes hierarchy details information
                       to the dimension hierarchy interface tables.
Modification History :
Date        Name       Desc
----------  ---------  -------------------------------------------------------
10/04/2005  SHTRIPAT   Created.
----------  ---------  -------------------------------------------------------
+===========================================================================*/

PROCEDURE Upload_Hierarchy_Interface
( p_folder_name                 IN VARCHAR2
, p_dimension_varchar_label     IN VARCHAR2
, p_hierarchy_object_name       IN VARCHAR2
, p_hierarchy_obj_def_disp_name IN VARCHAR2
, p_ledger_id                   IN NUMBER
, p_calendar_display_code       IN VARCHAR2
, p_group_seq_enforced_code     IN VARCHAR2  -- p_use_level_flag
, p_effective_start_date        IN DATE
, p_effective_end_date          IN DATE
, p_hierarchy_usage_code        IN VARCHAR2
, p_hierarchy_type_code         IN VARCHAR2
, p_multi_top_flag              IN VARCHAR2
, p_multi_value_set_flag        IN VARCHAR2
, p_parent_display_code         IN VARCHAR2
, p_child_display_code          IN VARCHAR2
)
IS
  --
  l_api_name CONSTANT    VARCHAR2(30) := 'Upload_Hierarchy_Interface' ;
  --
  l_return_status        VARCHAR2(1) ;
  l_msg_count            NUMBER ;
  l_msg_data             VARCHAR2(2000) ;
  --
  l_grp_seq_enfrced_code fem_hierarchies_t.group_sequence_enforced_code%TYPE ;
  --
--
BEGIN
  --
  -- Populate global variables with metadata information of
  -- the supplied p_dimension_varchar_label.
  -- This will be done only if it has not already been done.
  -- Other APIs can reuse the populated global variables.
  IF ( ( g_global_val_tbl.EXISTS(1)
         AND
         ( g_global_val_tbl(1).dimension_varchar_label <>
           p_dimension_varchar_label OR
               g_global_val_tbl(1).ledger_id <> p_ledger_id )
       )
       OR
       g_global_val_tbl.COUNT = 0
     )
  THEN
    --
    g_global_val_tbl(1).ledger_id             := p_ledger_id ;
    g_global_val_tbl(1).calendar_display_code := p_calendar_display_code ;
    --
    Populate_Dim_Metadata_Info
    ( x_return_status           => l_return_status
    , p_dimension_varchar_label => p_dimension_varchar_label
    ) ;

    IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS )
    THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF ;
    --
  END IF ;
  --
  g_global_val_tbl(1).ledger_id             := p_ledger_id ;
  g_global_val_tbl(1).calendar_display_code := p_calendar_display_code ;
  --
  -- Upload_Hierarchy_Header Start

  Upload_Hierarchy_Header
  ( x_return_status                => l_return_status
  , x_msg_count                    => l_msg_count
  , x_msg_data                     => l_msg_data
  , p_api_version                  => 1.0
  , p_init_msg_list                => FND_API.g_false
  , p_commit                       => FND_API.g_false
  , p_intf_hierarchy_table_name    =>
      g_global_val_tbl(1).hierarchy_intf_table_name
  , p_value_set_required_flag      =>
      g_global_val_tbl(1).value_set_required_flag
  , p_dimension_varchar_label      => p_dimension_varchar_label
  , p_hierarchy_object_name        => p_hierarchy_object_name
  , p_hierarchy_obj_def_disp_name  => p_hierarchy_obj_def_disp_name
  , p_folder_name                  => p_folder_name
  , p_hierarchy_type_code          => 'OPEN'
  , p_multi_top_flag               => p_multi_top_flag
  , p_multi_value_set_flag         => p_multi_value_set_flag
  , p_calendar_display_code        => p_calendar_display_code
  , p_hierarchy_usage_code         => 'STANDARD'
  , p_group_sequence_enforced_code => p_group_seq_enforced_code
  , p_effective_start_date         => p_effective_start_date
  , p_effective_end_date           => p_effective_end_date
  , p_language                     => USERENV('LANG')
  ) ;
  --
  IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS )
  THEN
    RAISE FND_API.G_EXC_ERROR ;
  END IF ;
  --
  -- Upload_Hierarchy_Header Done.
  --
  -- Upload_Hierarchy_Details Start.
  --
  Upload_Hierarchy_Details
  ( x_return_status               => l_return_status
  , x_msg_count                   => l_msg_count
  , x_msg_data                    => l_msg_data
  , p_api_version                 => 1.0
  , p_init_msg_list               => FND_API.g_false
  , p_commit                      => FND_API.g_false
  , p_language                    => USERENV('LANG')
  , p_hierarchy_object_name       => p_hierarchy_object_name
  , p_hierarchy_obj_def_disp_name => p_hierarchy_obj_def_disp_name
  , p_sequence_enforced_code      => p_group_seq_enforced_code
  , p_calendar_display_code       => p_parent_display_code
  , p_parent_display_code         =>
      NVL( p_parent_display_code, p_child_display_code )
  , p_child_display_code          => p_child_display_code
  ) ;

  IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS )
  THEN
    RAISE FND_API.G_EXC_ERROR ;
  END IF ;
  --
  -- Upload_Hierarchy_Details Done.
  --
  -- Commenting out the Exception block to
  -- propogate the exact exception back to
  -- Web ADI.
  -- Needs discussion.
/*EXCEPTION
  WHEN others THEN
    --
    -- *********************
    -- ***** IMPORTANT *****
    -- *********************
    -- For the time being, using Raise_Exception
    -- to raise the exception to Excel. Need to
    -- decide the text of error message.
    APP_EXCEPTION.Raise_Exception
    ( -20102
    , 'Last successful activity was:: ' || g_prev_activity || ',' ||
      'Last activity was:: ' || g_curr_activity
    ) ;
    --APP_EXCEPTION.Raise_Exception ;
    --*/
END Upload_Hierarchy_Interface ;
--


END FEM_WEBADI_HIER_UTILS_PVT ;

/
