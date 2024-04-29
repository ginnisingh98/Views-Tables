--------------------------------------------------------
--  DDL for Package Body FEM_HIER_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_HIER_UTILS_PVT" AS
/* $Header: FEMVDHUB.pls 120.7.12000000.3 2007/08/08 16:20:50 gdonthir ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30) := 'FEM_HIER_UTILS_PVT';

  -- Global Variables
  --

  --
  -- WHO columns variables
  --
  g_current_date           DATE   := sysdate                     ;
  g_current_user_id        NUMBER := NVL(Fnd_Global.User_Id , 0) ;
  g_current_login_id       NUMBER := NVL(Fnd_Global.Login_Id, 0) ;

  -- Type definition for cursor
  TYPE dhm_cur_type is REF CURSOR;

  -- Global PL/SQL types
  TYPE g_member_id_tbl_type is TABLE of FEM_PRODUCTS_HIER.PARENT_ID%TYPE
                                       index by BINARY_INTEGER;
  TYPE g_depth_num_tbl_type is
              TABLE of FEM_PRODUCTS_HIER.PARENT_DEPTH_NUM%TYPE
                                       index by BINARY_INTEGER;
  TYPE g_value_set_id_tbl_type is
            TABLE of FEM_PRODUCTS_HIER.PARENT_VALUE_SET_ID%TYPE
                                       index by BINARY_INTEGER;
  TYPE g_single_depth_tbl_type is
             TABLE of FEM_PRODUCTS_HIER.SINGLE_DEPTH_FLAG%TYPE
                                       index by BINARY_INTEGER;
  TYPE g_disp_ordnum_tbl_type is
             TABLE of FEM_PRODUCTS_HIER.DISPLAY_ORDER_NUM%TYPE
                                       index by BINARY_INTEGER;
  TYPE g_weight_pct_tbl_type is
                 TABLE of FEM_PRODUCTS_HIER.WEIGHTING_PCT%TYPE
                                       index by BINARY_INTEGER;


/*===========================================================================+
 |                     PROCEDURE Flatten_Focus_Node                          |
 +===========================================================================*/

--
-- The API to flatten  the immediate children of the focus node specified.
-- This API is being called when nodes are added at the same level to a
-- focus node.
--

PROCEDURE Flatten_Focus_Node
(
  p_api_version           IN           NUMBER ,
  p_init_msg_list         IN           VARCHAR2 := FND_API.G_FALSE ,
  p_commit                IN           VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level      IN           NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  x_return_status         OUT  NOCOPY  VARCHAR2 ,
  x_msg_count             OUT  NOCOPY  NUMBER   ,
  x_msg_data              OUT  NOCOPY  VARCHAR2 ,
  --
  p_hier_obj_defn_id      IN           NUMBER,
  p_hier_table_name       IN           VARCHAR2,
  p_focus_node            IN           NUMBER,
  p_focus_value_set_id    IN           NUMBER
)

is

-- Cursor to find out if the hierarchy corresponding to the
-- hierarchy version provided, can be flattened or not.

Cursor l_hier_csr is
  Select fh.flattened_rows_flag,
         fod.display_name
    from fem_hierarchies fh, fem_object_definition_vl fod
   where fod.object_definition_id = p_hier_obj_defn_id
     and fod.object_id = fh.hierarchy_obj_id;


  --
  l_api_name          CONSTANT VARCHAR2(30)   := 'Flatten_Focus_Node' ;
  l_api_version       CONSTANT NUMBER         :=  1.0;
  --

  --TYPE dhm_cur_type is REF CURSOR;
  dhm_chi_cur dhm_cur_type;
  dhm_par_cur dhm_cur_type;

  -- PL/SQL tables to fetch details from appropriate
  -- queries.
  l_parent_ids_tbl                    g_member_id_tbl_type;
  l_parent_depthnums_tbl              g_depth_num_tbl_type;
  l_parent_valueset_ids_tbl           g_value_set_id_tbl_type;
  l_child_ids_tbl                     g_member_id_tbl_type;
  l_child_depthnums_tbl               g_depth_num_tbl_type;
  l_child_valueset_ids_tbl            g_value_set_id_tbl_type;
  l_single_depth_flag_tbl             g_single_depth_tbl_type;
  l_display_order_num_tbl             g_disp_ordnum_tbl_type;
  l_weighting_pct_tbl                 g_weight_pct_tbl_type;

  l_flattened_rows_flag               varchar2(1);
  l_hier_defn_name                    varchar2(150);
  l_fl_child_stmt                     varchar2(1500);
  l_add_merg_stmt                     varchar2(2500);
  l_focus_node_stmt                   varchar2(1500);
  ins_stmt                            varchar2(2500);
  l_stat                              number := 1;

  l_child_id                          number;
  l_child_depth_num                   number;
  l_child_valueset_id                 number;
  l_display_order_num                 number;
  l_weighting_pct                     number;

BEGIN
  --
  SAVEPOINT Flatten_Focus_Node_Pvt ;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS ;
  --

  l_flattened_rows_flag := 'N';

  For l_hier_csr_rec in l_hier_csr
  Loop
      l_flattened_rows_flag := l_hier_csr_rec.flattened_rows_flag;
      l_hier_defn_name      := l_hier_csr_rec.display_name;
  End Loop;

  -- If hierarchy does not require to be flattened
  -- throws an error message .
  if (l_flattened_rows_flag  = 'N') then
	FND_MESSAGE.SET_NAME('FEM','FEM_DHM_CANNOT_FLATTEN_HIER');
	FND_MESSAGE.SET_TOKEN('HIER_DEFN_NAME',l_hier_defn_name );
	FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR ;
  end if;

  if (p_focus_value_set_id is not null) then

     l_focus_node_stmt := 'Delete '||p_hier_table_name||
                          ' where hierarchy_obj_def_id = :1 '||
                          ' and parent_id = :2 '||
                          ' and parent_value_set_id = :3 '||
                          ' and child_id =  :4 '||
                          ' and child_value_set_id = :5 '||
                          ' and single_depth_flag = ''N''';

     EXECUTE IMMEDIATE l_focus_node_stmt
           using p_hier_obj_defn_id, p_focus_node, p_focus_value_set_id,
                                     p_focus_node, p_focus_value_set_id;

     l_fl_child_stmt := 'Select child_id,'||
                        'child_depth_num, child_value_set_id,'||
                        'single_depth_flag,display_order_num, '||
                        'weighting_pct from '||p_hier_table_name||
                        ' where hierarchy_obj_def_id = '||p_hier_obj_defn_id||
                        ' and parent_id = '||p_focus_node||
                        ' and parent_value_set_id = '||p_focus_value_set_id||
                        ' and single_depth_flag = ''Y''';

     open dhm_chi_cur for l_fl_child_stmt;
     Loop
           Fetch dhm_chi_cur bulk collect into  l_child_ids_tbl,
                   l_child_depthnums_tbl,l_child_valueset_ids_tbl,
                   l_single_depth_flag_tbl,l_display_order_num_tbl,
                   l_weighting_pct_tbl limit 100;

           if l_child_ids_tbl.count = 0 then
               exit;
           else
               For i in 1..l_child_ids_tbl.count
               Loop

                 l_child_id            := l_child_ids_tbl(i);
                 l_child_depth_num     := l_child_depthnums_tbl(i);
                 l_child_valueset_id   := l_child_valueset_ids_tbl(i);
                 l_display_order_num   := l_display_order_num_tbl(i);
                 l_weighting_pct       := l_weighting_pct_tbl(i);
                 l_display_order_num   := l_display_order_num_tbl(i);
                 l_weighting_pct       := l_weighting_pct_tbl(i);

                 l_add_merg_stmt := 'Merge into '||p_hier_table_name||
                    ' hierA '||
                    ' using (Select parent_id,parent_depth_num ,'||
                    ' parent_value_set_id , hierarchy_obj_def_id '||
                    ' From '||p_hier_table_name||
                    ' where   hierarchy_obj_def_id = :1 '||
                    ' and child_id = :2 '||
                    ' and child_value_set_id = :3 '||
                    ' and not (parent_id = child_id  and '||
                    ' parent_value_set_id = child_value_set_id) '||
                    ' union '||
                    ' Select child_id parent_id, '||
                    ' child_depth_num parent_depth_num , '||
                    ' child_value_set_id parent_value_set_id, '||
                    ' hierarchy_obj_def_id '||
                    '  from '||p_hier_table_name||
                    ' where   hierarchy_obj_def_id = :A '||
                    ' and child_id = :B '||
                    ' and child_value_set_id = :C '||
                    ' and parent_id = :D '||
                    ' and parent_value_set_id = :E '||
                    ' and not (parent_id = child_id  and '||
                    ' parent_value_set_id = child_value_set_id) ' ||  --) hierB'||

                    -- Start Bug#4022561
                    /* Do not insert leaf node flattened entries
                     * for nodes that have children
                     */

                    ' and not exists ( select 1 from ' || p_hier_table_name || ' Z ' ||
                    ' where z.hierarchy_obj_def_id = ' || p_hier_obj_defn_id ||
                    ' and z.parent_id = ' || l_child_id  ||
                    ' and z.parent_value_set_id = ' || l_child_valueset_id ||
                    ' and z.single_depth_flag = ''Y'' )) hierB '||

                    -- End Bug#4022561

                    ' on (hierA.parent_id = hierB.parent_id and '||
                    ' hierA.parent_value_set_id = hierB.parent_value_set_id '||
                    ' and  hierA.child_id  = :4 and '||
                    ' hierA.child_value_set_id  = :5 and '||
                    ' hierA.hierarchy_obj_def_id = '||
                    ' hierB.hierarchy_obj_def_id  )'||
                    ' when matched then update set parent_depth_num = '||
                    ' hierB.parent_depth_num '||
                    ' when not matched then '||
                    ' Insert ' ||  --Bug#4240532, Provide column list for insert stmt
                    ' (       '||
                    'HIERARCHY_OBJ_DEF_ID, '||
                    'PARENT_DEPTH_NUM, '||
                    'PARENT_ID, '||
                    'PARENT_VALUE_SET_ID, '||
                    'CHILD_DEPTH_NUM, '||
                    'CHILD_ID, '||
                    'CHILD_VALUE_SET_ID, '||
                    'SINGLE_DEPTH_FLAG,'||
                    'DISPLAY_ORDER_NUM,'||
                    'WEIGHTING_PCT, ' ||
                    'CREATION_DATE,'||
                    'CREATED_BY, '||
                    'LAST_UPDATED_BY,'||
                    'LAST_UPDATE_DATE,'||
                    'LAST_UPDATE_LOGIN, '||
                    'OBJECT_VERSION_NUMBER) ' ||
                    ' values '||
                    ' ( :6, hierB.parent_depth_num, hierB.parent_id, '||
                    '  hierB.parent_value_set_id, :7, :8, :9, :10,'||
                    '  :11, :12, :13, :14, :15, :16, :17,:18) ';

                 EXECUTE IMMEDIATE  l_add_merg_stmt
                 USING p_hier_obj_defn_id,p_focus_node,p_focus_value_set_id,
                 p_hier_obj_defn_id,l_child_id,l_child_valueset_id,
                 p_focus_node,p_focus_value_set_id,
                 l_child_id,l_child_valueset_id,p_hier_obj_defn_id,
                 l_child_depth_num, l_child_id, l_child_valueset_id,
                 'N',l_display_order_num, l_weighting_pct, g_current_date,
                 g_current_user_id, g_current_user_id, g_current_date,
                 g_current_login_id,l_stat;

               End Loop;
         end if;
   End Loop;


 else -- if value set id is null
     l_focus_node_stmt := 'Delete '||p_hier_table_name||
                          ' where hierarchy_obj_def_id = :1 '||
                          ' and parent_id = :2 '||
                          ' and child_id =  :4 '||
                          ' and single_depth_flag = ''N''';

     EXECUTE IMMEDIATE l_focus_node_stmt
           using p_hier_obj_defn_id, p_focus_node, p_focus_node;

     l_fl_child_stmt := 'Select child_id,'||
                        'child_depth_num, '||
                        'single_depth_flag,display_order_num, '||
                        'weighting_pct from '||p_hier_table_name||
                        ' where hierarchy_obj_def_id = '||p_hier_obj_defn_id||
                        ' and parent_id = '||p_focus_node||
                        ' and single_depth_flag = ''Y''';

     open dhm_chi_cur for l_fl_child_stmt;
     Loop
         Fetch dhm_chi_cur bulk collect into  l_child_ids_tbl,
                 l_child_depthnums_tbl,
                 l_single_depth_flag_tbl,l_display_order_num_tbl,
                 l_weighting_pct_tbl limit 100;

         if l_child_ids_tbl.count = 0 then
             exit;
         else
             For i in 1..l_child_ids_tbl.count
             Loop

                 l_child_id            := l_child_ids_tbl(i);
                 l_child_depth_num     := l_child_depthnums_tbl(i);
                 l_display_order_num   := l_display_order_num_tbl(i);
                 l_weighting_pct       := l_weighting_pct_tbl(i);
                 l_display_order_num   := l_display_order_num_tbl(i);
                 l_weighting_pct       := l_weighting_pct_tbl(i);

                 l_add_merg_stmt := 'Merge into '||p_hier_table_name||
                    ' hierA '||
                    ' using (Select parent_id,parent_depth_num ,'||
                    '  hierarchy_obj_def_id '||
                    ' From '||p_hier_table_name||
                    ' where   hierarchy_obj_def_id = :1 '||
                    ' and child_id = :2 '||
                    ' and parent_id <> child_id  '||
                    ' union '||
                    ' Select child_id parent_id, '||
                    ' child_depth_num parent_depth_num , '||
                    ' hierarchy_obj_def_id '||
                    '  from '||p_hier_table_name||
                    ' where   hierarchy_obj_def_id = :A '||
                    ' and child_id = :B '||
                    ' and parent_id <> child_id  '||
                    ' and parent_id = : C ' || -- hierB '||

                    -- Start Bug#4022561
                    /* Do not insert leaf node flattened entries
                     * for nodes that have children
                     */

                    ' and not exists ( select 1 from ' || p_hier_table_name || ' Z ' ||
                    ' where z.hierarchy_obj_def_id = ' || p_hier_obj_defn_id ||
                    ' and z.parent_id = ' || l_child_id  ||
                    ' and z.single_depth_flag = ''Y'' )) hierB '||

                    -- End Bug#4022561

                    ' on (hierA.parent_id = hierB.parent_id and '||
                    ' hierA.child_id  = :3 and '||
                    ' hierA.hierarchy_obj_def_id = '||
                    ' hierB.hierarchy_obj_def_id  )'||
                    ' when matched then update set parent_depth_num = '||
                    ' hierB.parent_depth_num '||
                    ' when not matched then '||
                    ' Insert  '|| --Bug#4240532, Provide column list for insert stmt
                    ' (       '||
                    'HIERARCHY_OBJ_DEF_ID, '||
                    'PARENT_DEPTH_NUM, '||
                    'PARENT_ID, '||
                    'CHILD_DEPTH_NUM, '||
                    'CHILD_ID, '||
                    'SINGLE_DEPTH_FLAG,'||
                    'DISPLAY_ORDER_NUM,'||
                    'WEIGHTING_PCT, ' ||
                    'CREATION_DATE,'||
                    'CREATED_BY, '||
                    'LAST_UPDATED_BY,'||
                    'LAST_UPDATE_DATE,'||
                    'LAST_UPDATE_LOGIN, '||
                    'OBJECT_VERSION_NUMBER) '||
                    ' values( :4, hierB.parent_depth_num, hierB.parent_id, '||
                    '   :5, :6, :7, :8, :9, :10,'||
                    '   :11, :12, :13, :14, :15) ';


                 EXECUTE IMMEDIATE  l_add_merg_stmt
                 USING p_hier_obj_defn_id,p_focus_node,
                 p_hier_obj_defn_id, l_child_id, p_focus_node,
                 l_child_id,p_hier_obj_defn_id,
                 l_child_depth_num, l_child_id,
                 'N',l_display_order_num, l_weighting_pct, g_current_date,
                 g_current_user_id, g_current_user_id, g_current_date,
                 g_current_login_id,l_stat;



            End Loop;
         end if;
   End Loop;

 end if; -- If value set is not applicable.

  --
  -- End standard API section.
  --

  --
  -- Down below are again the standard end and exception sections of the API.
  --

  --
  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;
  --
  FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
 			      p_data  => x_msg_data );
  --
EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Flatten_Focus_Node_Pvt ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
				p_data  => x_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Flatten_Focus_Node_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
				p_data  => x_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Flatten_Focus_Node_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name);
    END if;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
				p_data  => x_msg_data );
   --

end Flatten_Focus_Node;

/*===========================================================================+
 |                     PROCEDURE Flatten_Whole_Hier_Version                  |
 +===========================================================================*/

--
-- The API to flatten a complete hierarchy version.
-- This API  gines all possible root nodes of a given
-- hierarchy version and for each top root node
-- calls the Flatten_Focus_Node_Tree api to
-- flatten all the nodes under the specific root.
--

PROCEDURE Flatten_Whole_Hier_Version
(
  p_api_version           IN           NUMBER ,
  p_init_msg_list         IN           VARCHAR2 := FND_API.G_FALSE ,
  p_commit                IN           VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level      IN           NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  x_return_status         OUT  NOCOPY  VARCHAR2 ,
  x_msg_count             OUT  NOCOPY  NUMBER   ,
  x_msg_data              OUT  NOCOPY  VARCHAR2 ,
  --
  p_hier_obj_defn_id      IN           NUMBER
)
is



  dhm_top_cur  dhm_cur_type;
  dhm_chi_cur  dhm_cur_type;
  dhm_flat_cur dhm_cur_type;

  l_top_nodes_tbl                           g_member_id_tbl_type;
  ltopvsids                                 g_value_set_id_tbl_type;
  l_parent_ids_tbl                          g_member_id_tbl_type;
  l_parent_depthnums_tbl                    g_depth_num_tbl_type;
  l_parent_valueset_ids_tbl                 g_value_set_id_tbl_type;
  l_child_ids_tbl                           g_member_id_tbl_type;
  l_child_depthnums_tbl                     g_depth_num_tbl_type;
  l_child_valueset_ids_tbl                  g_value_set_id_tbl_type;
  l_single_depth_flag_tbl                   g_single_depth_tbl_type;
  l_display_order_num_tbl                   g_disp_ordnum_tbl_type;
  l_weighting_pct_tbl                       g_weight_pct_tbl_type;
  --
  l_flattened_rows_flag               varchar2(1);
  l_hier_defn_name                    varchar2(150);
  l_hier_table_name                   varchar2(30);
  l_all_child_stmt                    varchar2(1500);
  l_hier_top_stmt                     varchar2(1500);
  l_hier_flat_stmt                    varchar2(1500);
  l_merg_stmt                         varchar2(2500);
  l_stat                              number := 1;
  l_flat_count                        number := 0;

  l_dimension_id                      number;
  l_value_set_required_flag           varchar2(1);
  l_child_id                          number;
  l_child_depth_num                   number;
  l_child_valueset_id                 number;
  l_display_order_num                 number;
  l_weighting_pct                     number;
  l_flattened                         varchar2(6)  := FND_API.G_FALSE;
  --
  l_api_name          CONSTANT VARCHAR2(30)   := 'Flatten_Whole_Hier_Version' ;
  l_api_version       CONSTANT NUMBER         :=  1.0;

   --
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;

BEGIN

  -- Bug # 3562336 : Removed Savepoint as the commit is now being
  -- done in Flatten_Focus_Node_Tree after every merged row

  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS ;
  --

  l_flattened_rows_flag := 'N';

-- Cursor to find out if the hierarchy corresponding to the
-- hierarchy version provided, can be flattened or not.

  For l_hier_csr_rec in
  ( Select fh.flattened_rows_flag,
         fh.dimension_id,
         fod.display_name
    from fem_hierarchies fh, fem_object_definition_vl fod
   where fod.object_definition_id = p_hier_obj_defn_id
     and fod.object_id = fh.hierarchy_obj_id)
  Loop
      l_flattened_rows_flag := l_hier_csr_rec.flattened_rows_flag;
      l_dimension_id        := l_hier_csr_rec.dimension_id;
      l_hier_defn_name      := l_hier_csr_rec.display_name;
  End Loop;


  -- If hierarchy does not require to be flattened
  -- throws an error message .
  if (l_flattened_rows_flag = 'N') then
	FND_MESSAGE.SET_NAME('FEM','FEM_DHM_CANNOT_FLATTEN_HIER');
	FND_MESSAGE.SET_TOKEN('HIER_DEFN_NAME',l_hier_defn_name );
	FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR ;
  end if;

  For l_dim_csr_rec in
  (
   Select hierarchy_table_name,
          value_set_required_flag
    from fem_xdim_dimensions
   where dimension_id = l_dimension_id
  )
  Loop
    l_hier_table_name := l_dim_csr_rec.hierarchy_table_name;
    l_value_set_required_flag := l_dim_csr_rec.value_set_required_flag;
  End Loop;

  -- Cursor to find if the hierarchy has ever been
  -- flattened

  l_flat_count     := 0;
  l_hier_flat_stmt := 'Select 1 '||
                      ' from '||l_hier_table_name||
                      ' where hierarchy_obj_def_id = :1 ' ||
                      '   and parent_id <> child_id '||
                      '   and single_depth_flag = ''N''';

  open dhm_flat_cur for l_hier_flat_stmt using p_hier_obj_defn_id;

  Loop
     Fetch dhm_flat_cur into l_flat_count;
     if l_flat_count <>  0 then
        l_flattened  := FND_API.G_TRUE;
     end if;
     exit;
  End Loop;

 if (l_value_set_required_flag = 'Y') then
  -- Cursor to find the top nodes (root nodes)
  -- of the given hierarchy version.
  l_hier_top_stmt  := 'Select parent_id , parent_value_set_id '||
                      '  from  '||l_hier_table_name||
                      ' where hierarchy_obj_def_id = :1 ' ||
                      '   and parent_id = child_id '||
                      '   and parent_value_set_id = child_value_set_id '||
                      '   and single_depth_flag = ''Y''';


  open dhm_top_cur for l_hier_top_stmt using p_hier_obj_defn_id;
  Loop
    Fetch dhm_top_cur bulk collect into  l_top_nodes_tbl, ltopvsids;
    if l_top_nodes_tbl.count = 0 then
       exit;
    end if;
  For i in 1..l_top_nodes_tbl.count
  Loop

    -- Bug # 3562336 : Added p_commit to Flatten_Focus_Node_Tree call

   Flatten_Focus_Node_Tree
   (
     p_api_version         => 1.0,
     x_return_status       => l_return_status,
     x_msg_count           => l_msg_count,
     x_msg_data            => l_msg_data,
     p_commit              => FND_API.G_TRUE,
     --
     p_hier_obj_defn_id    => p_hier_obj_defn_id,
     p_hier_table_name     => l_hier_table_name,
     p_focus_node          => l_top_nodes_tbl(i),
     p_focus_value_set_id  => ltopvsids(i)
   ) ;

   -- Bug # 3562336 : Changed the return status check to
   -- "<> FND_API.G_RET_STS_SUCCESS " from "= FND_API.G_RET_STS_ERROR"

   if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR ;
   end if;

  End Loop; -- For Loop Top Nodes
  End Loop; -- Outer Loop Top Nodes

 else
  -- Cursor to find the top nodes (root nodes)
  -- of the given hierarchy version.
  l_hier_top_stmt  := 'Select parent_id '||
                      '  from  '||l_hier_table_name||
                      ' where hierarchy_obj_def_id = :1 ' ||
                      '   and parent_id = child_id '||
                      '   and single_depth_flag = ''Y''';

  open dhm_top_cur for l_hier_top_stmt using p_hier_obj_defn_id;
  Loop
    Fetch dhm_top_cur bulk collect into  l_top_nodes_tbl;
    if l_top_nodes_tbl.count = 0 then
       exit;
    end if;
  For i in 1..l_top_nodes_tbl.count
  Loop

  -- Bug # 3562336 : Added p_commit to Flatten_Focus_Node_Tree call

   Flatten_Focus_Node_Tree
   (
     p_api_version         => 1.0,
     x_return_status       => l_return_status,
     x_msg_count           => l_msg_count,
     x_msg_data            => l_msg_data,
     p_commit              => FND_API.G_TRUE,
     --
     p_hier_obj_defn_id    => p_hier_obj_defn_id,
     p_hier_table_name     => l_hier_table_name,
     p_focus_node          => l_top_nodes_tbl(i),
     p_focus_value_set_id  => NULL
    ) ;

   -- Bug # 3562336 : Changed the return status check to
   -- "<> FND_API.G_RET_STS_SUCCESS " from "= FND_API.G_RET_STS_ERROR"

   if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR ;
   end if;

  End Loop; -- For Loop Top Nodes
  End Loop; -- Outer Loop Top Nodes

 end if;
  -- To set the completion of the Hierarchy Version explosion.
  Update fem_hier_definitions
    set flattened_rows_completion_code = 'COMPLETED',
        last_updated_by                = g_current_user_id,
        last_update_date               = g_current_date,
        last_update_login              = g_current_login_id,
        object_version_number          = object_version_number + 1
   where hierarchy_obj_def_id          = p_hier_obj_defn_id;

  --
  --
  -- End standard API section.
  --

  --
  -- Down below are again the standard end and exception sections of the API.
  --

  --
  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;
  --
  FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
			      p_data  => x_msg_data );
  --
EXCEPTION

  -- Bug # 3562336 : Remove exceptions other than 'WHEN OTHERS'

  WHEN OTHERS THEN

    -- Bug # 3562336 : Remove Rollback statement as Savepoint is not
    -- needed anymore

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name);
    END if;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
				p_data  => x_msg_data );
   --

end Flatten_Whole_Hier_Version;

/*===========================================================================+
 |                     PROCEDURE Flatten_Focus_Node_Tree                     |
 +===========================================================================*/

--
-- The API to flatten the tree under a given node with respect to the whole
-- hierarchy .This api is normally used during the 'Move' operation, when
-- a node along with its children is moved under a focus node. Given the
-- focus node and the node added along with descendants, this api aims
-- to flatten the new structure with respect to the whole hierarchy.
--

PROCEDURE Flatten_Focus_Node_Tree
(
  p_api_version           IN           NUMBER ,
  p_init_msg_list         IN           VARCHAR2 := FND_API.G_FALSE ,
  p_commit                IN           VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level      IN           NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  x_return_status         OUT  NOCOPY  VARCHAR2 ,
  x_msg_count             OUT  NOCOPY  NUMBER   ,
  x_msg_data              OUT  NOCOPY  VARCHAR2 ,
  --
  p_hier_obj_defn_id      IN           NUMBER,
  p_hier_table_name       IN           VARCHAR2,
  p_focus_node            IN           NUMBER,
  p_focus_value_set_id    IN           NUMBER
) is

  dhm_chi_cur  dhm_cur_type;
  dhm_leaf_cur dhm_cur_type;

  l_top_nodes_tbl                     g_member_id_tbl_type;
  l_parent_ids_tbl                    g_member_id_tbl_type;
  l_parent_depthnums_tbl              g_depth_num_tbl_type;
  l_parent_valueset_ids_tbl           g_value_set_id_tbl_type;
  l_child_ids_tbl                     g_member_id_tbl_type;
  l_child_depthnums_tbl               g_depth_num_tbl_type;
  l_child_valueset_ids_tbl            g_value_set_id_tbl_type;
  l_single_depth_flag_tbl             g_single_depth_tbl_type;
  l_display_order_num_tbl             g_disp_ordnum_tbl_type;
  l_weighting_pct_tbl                 g_weight_pct_tbl_type;
  --
  lnparentids                         g_member_id_tbl_type;
  lnparentdepthnums                   g_depth_num_tbl_type;
  lnparentvaluesetids                 g_value_set_id_tbl_type;
  lnchildids                          g_member_id_tbl_type;
  lnchilddepthnums                    g_depth_num_tbl_type;
  lnchildvaluesetids                  g_value_set_id_tbl_type;
  lndisplayordernum                   g_disp_ordnum_tbl_type;
  lnweightingpct                      g_weight_pct_tbl_type;
  --
  l_child_id                          number;
  l_leaf_parent_id                    number;
  l_parent_id                         number;
  l_parent_valueset_id                number;
  l_child_depth_num                   number;
  l_child_valueset_id                 number;
  l_single_depth_flag                 varchar2(1);
  l_display_order_num                 number;
  l_weighting_pct                     number;
  l_all_child_stmt                    varchar2(1500);
  l_leaf_flat_stmt                    varchar2(1500);
  l_leaf_child_stmt                   varchar2(1500);
  l_merg_stmt                         varchar2(2500);
  l_stat                              number := 1;
  n                                   number := 1;

  --
  l_api_name          CONSTANT VARCHAR2(30)   := 'Flatten_Focus_Node_Tree' ;
  l_api_version       CONSTANT NUMBER         :=  1.0;

BEGIN

  -- Bug # 3562336 : Removed Savepoint as the commit is now being done
  -- after every merged row instead of committing rows at the end of the
  -- procedure

  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS ;
  --

  if (p_focus_value_set_id is not null) then

    -- Start Bug#4022561

     /* Remove any leaf node flattenned entries
      * of focus node
      */


      execute immediate 'DELETE FROM ' || p_hier_table_name ||
                        ' WHERE hierarchy_obj_def_id = ' || p_hier_obj_defn_id ||
                        ' AND parent_id = ' || p_focus_node ||
                        ' AND parent_id = child_id ' ||
                        ' AND parent_value_set_id = ' || p_focus_value_set_id ||
                        ' AND child_value_set_id = parent_value_set_id ' ||
                        ' AND single_depth_flag = ''N'' ';


    -- End Bug#4022561




  -- Cursor Statement to fetch all the children of the current top node.
  l_all_child_stmt := 'SELECT h.parent_id, h.parent_value_set_id, '||
                      ' h.child_id , h.child_depth_num, '||
                     ' h.display_order_num ,h.child_value_set_id,' ||
                     ' h.weighting_pct '||
                     'FROM ' || p_hier_table_name || ' h ' ||
                     'WHERE h.hierarchy_obj_def_id = :1 AND ' ||
                     ' NOT ( h.parent_id =  h.child_id AND '||
                     ' h.parent_value_set_id = h.child_value_set_id) '||
                     'START WITH h.parent_id = :2 AND ' ||
                     ' h.parent_value_set_id = :3 AND ' ||
                     'h.hierarchy_obj_def_id = :4 AND ' ||
                     'h.single_depth_flag = ''Y'' AND ' ||
                     ' NOT ( h.parent_id =  h.child_id AND '||
                     ' h.parent_value_set_id = h.child_value_set_id) '||
                     'CONNECT BY PRIOR h.child_id = h.parent_id AND ' ||
                     ' PRIOR h.child_value_set_id = h.parent_value_set_id '||
                     ' AND h.hierarchy_obj_def_id = :5 AND ' ||
                     'h.single_depth_flag = ''Y'' AND ' ||
                     ' NOT ( h.parent_id =  h.child_id AND '||
                     ' h.parent_value_set_id = h.child_value_set_id) '||
                     'ORDER BY level ';

  open dhm_chi_cur for l_all_child_stmt
  using p_hier_obj_defn_id, p_focus_node, p_focus_value_set_id,
                p_hier_obj_defn_id, p_hier_obj_defn_id;
  Loop

    -- Bug # 3562336 : Changed bulk fetch statements limit
    -- from 100 to 500

    Fetch dhm_chi_cur bulk collect into l_parent_ids_tbl,
           l_parent_valueset_ids_tbl,
           l_child_ids_tbl,l_child_depthnums_tbl, l_display_order_num_tbl,
           l_child_valueset_ids_tbl,l_weighting_pct_tbl limit 500;

    if l_child_ids_tbl.count = 0 then
       exit;
    end if;

    n := 0;
    For m in 1..l_child_ids_tbl.count
    Loop
      l_child_id            := l_child_ids_tbl(m);
      l_parent_id           := l_parent_ids_tbl(m);
      l_parent_valueset_id  := l_parent_valueset_ids_tbl(m);
      l_child_depth_num     := l_child_depthnums_tbl(m);
      l_child_valueset_id   := l_child_valueset_ids_tbl(m);
      l_display_order_num   := l_display_order_num_tbl(m);
      l_weighting_pct       := l_weighting_pct_tbl(m);
      l_child_depth_num     := l_child_depthnums_tbl(m);
      l_display_order_num   := l_display_order_num_tbl(m);
      l_weighting_pct       := l_weighting_pct_tbl(m);

      -- To find if the node has children
      l_leaf_child_stmt := 'Select child_id '||
                           ' from '||p_hier_table_name||
                           ' where hierarchy_obj_def_id = :1'||
                            ' and parent_id = :2 '||
                           ' and parent_value_set_id = :3 ';


      open dhm_leaf_cur for l_leaf_child_stmt
         using p_hier_obj_defn_id,l_child_id,l_child_valueset_id;

      Loop
       Fetch dhm_leaf_cur into l_leaf_parent_id;
       if dhm_leaf_cur%rowcount = 0 then
          n := n + 1;
          lnparentdepthnums(n)   := l_child_depth_num;
          lnparentids(n)         := l_child_id;
          lnparentvaluesetids(n) := l_child_valueset_id;
          lnchildids(n)          := l_child_id;
          lnchilddepthnums(n)    := l_child_depth_num;
          lnchildvaluesetids(n)  := l_child_valueset_id;
          lndisplayordernum(n)   := l_display_order_num;
          lnweightingpct(n)      := l_weighting_pct;
       end if;
      exit;
      End Loop;

      l_merg_stmt := 'Merge into '||p_hier_table_name||' hierA '||
                    ' using (Select parent_id,parent_depth_num ,'||
                    ' parent_value_set_id , hierarchy_obj_def_id '||
                    ' From '||p_hier_table_name||
                    ' where   hierarchy_obj_def_id = :1 '||
                    ' and  child_id =  :2 '||
                    ' and  child_value_set_id =  :3 '||
                    ' and not ( parent_id =  child_id and '||
                    ' parent_value_set_id = child_value_set_id)) hierB '||
                     ' on (hierA.parent_id = hierB.parent_id and '||
                     ' hierA.parent_value_set_id = hierB.parent_value_set_id '||
                     ' and  hierA.child_id  = :4 and '||
                     ' hierA.child_value_set_id  = :5 and '||
                     ' hierA.hierarchy_obj_def_id = '||
                     ' hierB.hierarchy_obj_def_id  )'||
                    ' when matched then update set parent_depth_num = '||
                    ' hierB.parent_depth_num '||
                    ' when not matched then '||
                    ' Insert ' || --Bug#4240532, Provide column list for insert stmt
                    ' (       '||
                    'HIERARCHY_OBJ_DEF_ID, '||
                    'PARENT_DEPTH_NUM, '||
                    'PARENT_ID, '||
                    'PARENT_VALUE_SET_ID, '||
                    'CHILD_DEPTH_NUM, '||
                    'CHILD_ID, '||
                    'CHILD_VALUE_SET_ID, '||
                    'SINGLE_DEPTH_FLAG,'||
                    'DISPLAY_ORDER_NUM,'||
                    'WEIGHTING_PCT, ' ||
                    'CREATION_DATE,'||
                    'CREATED_BY, '||
                    'LAST_UPDATED_BY,'||
                    'LAST_UPDATE_DATE,'||
                    'LAST_UPDATE_LOGIN, '||
                    'OBJECT_VERSION_NUMBER) '||
                    ' values '||
                    ' ( :6, hierB.parent_depth_num, hierB.parent_id, '||
                    '  hierB.parent_value_set_id, :7, :8, :9, :10,'||
                    '  :11, :12, :13, :14, :15, :16, :17 ,:18) ';

      /*l_merg_stmt := 'Merge into '||p_hier_table_name||' hierA '||
                     ' using (Select parent_id , parent_depth_num , '||
                     ' parent_value_set_id  , child_id, hierarchy_obj_def_id '||
                     ' From '|| p_hier_table_name||
                     ' where   hierarchy_obj_def_id = :1 '||
                     ' and     single_depth_flag = ''Y'''||
                     ' and     parent_id <> child_id '||
                     ' and     level <> 1 '||
                     ' start with child_id = :2 '||
                     ' and hierarchy_obj_def_id = :3 '||
                     ' and single_depth_flag = ''Y'' '||
                     ' and  parent_id <> child_id '||
                     ' connect by prior parent_id  = child_id '||
                     ' and hierarchy_obj_def_id =  :4 '||
                     ' and     single_depth_flag = ''Y'''||
                     ' and  parent_id <> child_id ) hierB'||
                     ' on (hierA.parent_id = hierB.parent_id and '||
                     '     hierA.child_id  = :x and '||
                     ' hierA.hierarchy_obj_def_id = '||
                     ' hierB.hierarchy_obj_def_id  )'||
                     ' when matched then update set parent_depth_num = '||
                     ' hierB.parent_depth_num '||
                     ' when not matched then '||
                     ' Insert  values '||
                     ' ( :5,hierB.parent_depth_num,hierB.parent_id,'||
                     '  hierB.parent_value_set_id,:6,:7,:8,:9,:10,'||
                     '  :11,:12,:13,:14,:15, :16,:17 ) '; */


       EXECUTE IMMEDIATE  l_merg_stmt
       USING p_hier_obj_defn_id,l_parent_id,l_parent_valueset_id,
             l_child_id,l_child_valueset_id,p_hier_obj_defn_id,
             l_child_depth_num, l_child_id, l_child_valueset_id,
             'N',l_display_order_num, l_weighting_pct, g_current_date,
             g_current_user_id, g_current_user_id, g_current_date,
             g_current_login_id,l_stat;


      -- Bug # 3562336 : Commit after every insert/update to avoid
      -- rollback segment capacity issues

      IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
      END IF;

    End Loop;


   --Bug#4240532, Provide column list for insert stmt

   l_leaf_flat_stmt := 'Insert into '||p_hier_table_name||
                       ' (       '||
                       'HIERARCHY_OBJ_DEF_ID, '||
                       'PARENT_DEPTH_NUM, '||
                       'PARENT_ID, '||
                       'PARENT_VALUE_SET_ID, '||
                       'CHILD_DEPTH_NUM, '||
                       'CHILD_ID, '||
                       'CHILD_VALUE_SET_ID, '||
                       'SINGLE_DEPTH_FLAG,'||
                       'DISPLAY_ORDER_NUM,'||
                       'WEIGHTING_PCT, ' ||
                       'CREATION_DATE,'||
                       'CREATED_BY, '||
                       'LAST_UPDATED_BY,'||
                       'LAST_UPDATE_DATE,'||
                       'LAST_UPDATE_LOGIN, '||
                       'OBJECT_VERSION_NUMBER) '||
                       ' values '||
                       '( :1, '||
                       '  :lparentdepthnum,'||
                       '  :lparentid,'||
                       '  :lparentvaluesetid,'||
                       '  :2, :3,:4,:5,:6,:7,:8,:9,:10,:11,:12,:13)' ;

    Forall k in 1..n
      EXECUTE immediate l_leaf_flat_stmt
                USING p_hier_obj_defn_id,lnparentdepthnums(k),
                      lnparentids(k), lnparentvaluesetids(k),
                      lnchilddepthnums(k),lnchildids(k),lnchildvaluesetids(k),
                      'N',lndisplayordernum(k),
                      lnweightingpct(k), g_current_date,
                      g_current_user_id,g_current_user_id,
                      g_current_date,g_current_login_id,l_stat;


    -- Bug # 3562336 : Commit after every insert/update to avoid
    -- rollback segment capacity issues

    IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
    END IF;

  End Loop;
 else -- if p_focus_value_set_id is null


   -- Start Bug#4022561

     /* Remove any leaf node flattenned entries
      * of focus node
      */

      execute immediate 'DELETE FROM ' || p_hier_table_name ||
                        ' WHERE hierarchy_obj_def_id = ' || p_hier_obj_defn_id ||
                        ' AND parent_id = ' || p_focus_node ||
                        ' AND parent_id = child_id ' ||
                        ' AND single_depth_flag = ''N'' ';


    -- End Bug#4022561

  -- Cursor Statement to fetch all the children of the current top node.
  l_all_child_stmt := 'SELECT h.parent_id, '||
                      ' h.child_id , h.child_depth_num, '||
                     ' h.display_order_num ,'||
                     ' h.weighting_pct '||
                     'FROM ' || p_hier_table_name || ' h ' ||
                     'WHERE h.hierarchy_obj_def_id = :1 AND ' ||
                     ' h.parent_id <>  h.child_id '||
                     'START WITH h.parent_id = :2 AND ' ||
                     'h.hierarchy_obj_def_id = :4 AND ' ||
                     'h.single_depth_flag = ''Y'' AND ' ||
                     ' h.parent_id <>  h.child_id '||
                     'CONNECT BY PRIOR h.child_id = h.parent_id AND ' ||
                     'h.hierarchy_obj_def_id = :5 AND ' ||
                     'h.single_depth_flag = ''Y'' AND ' ||
                     ' h.parent_id <>  h.child_id '||
                     'ORDER BY level ';

  open dhm_chi_cur for l_all_child_stmt
  using p_hier_obj_defn_id, p_focus_node,
                p_hier_obj_defn_id, p_hier_obj_defn_id;
  Loop

    -- Bug # 3562336 : Changed bulk fetch statements limit from
    -- 100 to 500

    Fetch dhm_chi_cur bulk collect into l_parent_ids_tbl,
           l_child_ids_tbl,l_child_depthnums_tbl, l_display_order_num_tbl,
           l_weighting_pct_tbl limit 500;

    if l_child_ids_tbl.count = 0 then
       exit;
    end if;

    n := 0;
    For m in 1..l_child_ids_tbl.count
    Loop
      l_child_id            := l_child_ids_tbl(m);
      l_parent_id           := l_parent_ids_tbl(m);
      l_child_depth_num     := l_child_depthnums_tbl(m);
      l_display_order_num   := l_display_order_num_tbl(m);
      l_weighting_pct       := l_weighting_pct_tbl(m);
      l_child_depth_num     := l_child_depthnums_tbl(m);
      l_display_order_num   := l_display_order_num_tbl(m);
      l_weighting_pct       := l_weighting_pct_tbl(m);

      -- To find if the node has children
      -- To find if the node has children
      l_leaf_child_stmt := 'Select child_id '||
                           ' from '||p_hier_table_name||
                           ' where hierarchy_obj_def_id = :1'||
                            ' and parent_id = :2 ';

      open dhm_leaf_cur for l_leaf_child_stmt
         using p_hier_obj_defn_id,l_child_id;

      Loop
       Fetch dhm_leaf_cur into l_leaf_parent_id;
       if dhm_leaf_cur%rowcount = 0 then
          n := n + 1;
          lnparentdepthnums(n)   := l_child_depth_num;
          lnparentids(n)         := l_child_id;
          lnchildids(n)          := l_child_id;
          lnchilddepthnums(n)    := l_child_depth_num;
          lndisplayordernum(n)   := l_display_order_num;
          lnweightingpct(n)      := l_weighting_pct;
       end if;
      exit;
      End Loop;

      l_merg_stmt := 'Merge into '||p_hier_table_name||' hierA '||
                    ' using (Select parent_id,parent_depth_num ,'||
                    ' hierarchy_obj_def_id '||
                    ' From '||p_hier_table_name||
                    ' where   hierarchy_obj_def_id = :1 '||
                    ' and  child_id =  :2 '||
                    ' and parent_id <>  child_id ) hierB '||
                     ' on (hierA.parent_id = hierB.parent_id '||
                     ' and  hierA.child_id  = :3 and '||
                     ' hierA.hierarchy_obj_def_id = '||
                     ' hierB.hierarchy_obj_def_id  )'||
                    ' when matched then update set parent_depth_num = '||
                    ' hierB.parent_depth_num '||
                    ' when not matched then '||
                    ' Insert ' || --Bug#4240532, Provide column list for insert stmt
                    ' (       '||
                    'HIERARCHY_OBJ_DEF_ID, '||
                    'PARENT_DEPTH_NUM, '||
                    'PARENT_ID, '||
                    'CHILD_DEPTH_NUM, '||
                    'CHILD_ID, '||
                    'SINGLE_DEPTH_FLAG,'||
                    'DISPLAY_ORDER_NUM,'||
                    'WEIGHTING_PCT, ' ||
                    'CREATION_DATE,'||
                    'CREATED_BY, '||
                    'LAST_UPDATED_BY,'||
                    'LAST_UPDATE_DATE,'||
                    'LAST_UPDATE_LOGIN, '||
                    'OBJECT_VERSION_NUMBER) '||
                    ' values '||
                    ' ( :6, hierB.parent_depth_num, hierB.parent_id, '||
                    '   :7, :8, :9, :10,'||
                    '  :11, :12, :13, :14, :15, :16, :17 ) ';

       EXECUTE IMMEDIATE  l_merg_stmt
       USING p_hier_obj_defn_id,l_parent_id,
             l_child_id,p_hier_obj_defn_id,
             l_child_depth_num, l_child_id,
             'N',l_display_order_num, l_weighting_pct,
             g_current_date, g_current_user_id,
             g_current_user_id, g_current_date,
             g_current_login_id,l_stat;

      -- Bug # 3562336 : Commit after every insert/update to avoid
      -- rollback segment capacity issues

      IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
      END iF;


    End Loop;


   --Bug#4240532, Provide column list for insert stmt

   l_leaf_flat_stmt := 'Insert into '||p_hier_table_name||
                       ' (       '||
                       'HIERARCHY_OBJ_DEF_ID, '||
                       'PARENT_DEPTH_NUM, '||
                       'PARENT_ID, '||
                       'CHILD_DEPTH_NUM, '||
                       'CHILD_ID, '||
                       'SINGLE_DEPTH_FLAG,'||
                       'DISPLAY_ORDER_NUM,'||
                       'WEIGHTING_PCT, ' ||
                       'CREATION_DATE,'||
                       'CREATED_BY, '||
                       'LAST_UPDATED_BY,'||
                       'LAST_UPDATE_DATE,'||
                       'LAST_UPDATE_LOGIN, '||
                       'OBJECT_VERSION_NUMBER) '||
                       ' values '||
                       '( :1, '||
                       '  :lparentdepthnum,'||
                       '  :lparentid,'||
                       '  :2, :3,:4,:5,:6,:7,:8,:9,:10,:11,:12)' ;

    Forall k in 1..n
      EXECUTE immediate l_leaf_flat_stmt
                USING p_hier_obj_defn_id,lnparentdepthnums(k),
                      lnparentids(k),
                      lnchilddepthnums(k),lnchildids(k),
                      'N',lndisplayordernum(k),
                      lnweightingpct(k), g_current_date,
                      g_current_user_id,g_current_user_id,
                      g_current_date,g_current_login_id,l_stat;


    -- Bug # 3562336 : Commit after every insert/update to avoid
    -- rollback segment capacity issues

    IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
    END IF;


  End Loop;
 end if;


  --
  -- End standard API section.
  --

  --
  -- Down below are again the standard end and exception sections of the API.
  --

  --
  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;
  --
  FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
			      p_data  => x_msg_data );
  --
EXCEPTION
  -- Bug # 3562336 : Remove exceptions other than 'WHEN OTHERS'

  WHEN OTHERS THEN

    -- Bug # 3562336 : Remove Rollback statement as Savepoint is
    -- not needed anymore

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name);
    END if;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
				p_data  => x_msg_data );
   --

End Flatten_Focus_Node_Tree;

PROCEDURE Unflatten_Focus_Node_Tree
(
  p_api_version                 IN           NUMBER ,
  p_init_msg_list               IN           VARCHAR2 := FND_API.G_FALSE ,
  p_commit                      IN           VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level            IN           NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  x_return_status               OUT  NOCOPY  VARCHAR2 ,
  x_msg_count                   OUT  NOCOPY  NUMBER   ,
  x_msg_data                    OUT  NOCOPY  VARCHAR2 ,
  --
  p_hier_obj_defn_id            IN           NUMBER,
  p_hier_table_name             IN           VARCHAR2,
  p_focus_node                  IN           NUMBER  ,
  p_focus_value_set_id          IN           NUMBER ,
  p_parent_id                   IN           NUMBER    ,
  p_parent_value_set_id         IN           NUMBER ,
  p_imm_child_id                IN           NUMBER,
  p_imm_child_value_set_id      IN           NUMBER,
  p_operation                   IN           VARCHAR2
) is
  --
  l_chi_stmt                     varchar2(1500);
  l_del_stmt                     varchar2(1500);
  l_child_ids_tbl                g_member_id_tbl_type;
  l_child_valueset_ids_tbl       g_value_set_id_tbl_type;

  --TYPE dhm_cur_type is REF CURSOR;
  dhm_chi_cur dhm_cur_type;


  -- Start Bug#4022561

  l_imm_parent_csr dhm_cur_type;
  l_imm_parent_child_csr dhm_cur_type;
  l_imm_child_csr dhm_cur_type;
  l_root_csr dhm_cur_type;


  l_parent_id               NUMBER;
  l_parent_value_set_id     NUMBER := 0;
  l_parent_depth_num        NUMBER;
  l_child_id                NUMBER;
  l_child_value_set_id      NUMBER;
  l_child_depth_num         NUMBER := 1;
  l_display_order_num       NUMBER;
  l_imm_child_flag          VARCHAR2(1) := 'N';
  l_stat                    NUMBER := 1;
  l_leaf_flat_stmt          VARCHAR2(1500);
  l_weighting_pct           NUMBER;
  l_select_stmt             VARCHAR2(1000);
  l_imm_delete_stmt         VARCHAR2(1000);


  -- End Bug#4022561

  --
  l_api_name          CONSTANT VARCHAR2(30)   := 'Unflatten_Focus_Node_Tree' ;
  l_api_version       CONSTANT NUMBER         :=  1.0;

BEGIN
  --
  SAVEPOINT Unflatten_Focus_Node_Tree_Pvt ;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS ;

  if (p_focus_value_set_id is not null) then


     -- Start Bug#4022561

     /* Remove any flattened entries of the immediate
      * children of the deleted member
      */

     IF(p_operation = 'RemoveImmChildren') THEN
       l_imm_delete_stmt := 'DELETE FROM ' || p_hier_table_name ||
                     ' WHERE hierarchy_obj_def_id = :1 ' ||
                     ' AND child_id = :2 ' ||
                     ' AND child_value_set_id = :3 ' ||
                     ' AND single_depth_flag = ''N''';


        EXECUTE IMMEDIATE l_imm_delete_stmt
          using p_hier_obj_defn_id , p_imm_child_id,
          p_imm_child_value_set_id;

        RETURN;

     END IF;

     -- End Bug#4022561

     l_chi_stmt := 'Select child_id, child_value_set_id '||
                   '  from '||p_hier_table_name||
                   ' where  hierarchy_obj_def_id = '||p_hier_obj_defn_id||
                   ' and    parent_id  = :1 '||
                   ' and    parent_value_set_id = :2 '||
                   ' and    single_depth_flag = ''N''';

     l_del_stmt := 'Delete '||p_hier_table_name||
                   ' where  hierarchy_obj_def_id = '||p_hier_obj_defn_id||
                   ' and    child_id  = :1 '||
                   ' and    child_value_set_id = :2 '||
                   ' and    single_depth_flag = ''N''';

     /* Bug#4022561
      * Bind the cursor dhm_chi_cur
      */

     open dhm_chi_cur for l_chi_stmt
      using p_focus_node,p_focus_value_set_id;
     Loop
       Fetch dhm_chi_cur bulk collect into  l_child_ids_tbl,
                         l_child_valueset_ids_tbl limit 500;

       if l_child_ids_tbl.count = 0 then
           exit;
       end if;

       Forall i in 1..l_child_ids_tbl.count
          EXECUTE IMMEDIATE l_del_stmt
          using l_child_ids_tbl(i), l_child_valueset_ids_tbl(i);

      commit;
     End Loop;

      -- Start Bug#4022561

      /* Check if the immediate parent of the deleted
       * member has any other children. If not,insert a leaf
       * entry for the parent node only if it is not a root.
       */



       l_select_stmt := ' SELECT h.child_depth_num ' ||
                        ' FROM ' || p_hier_table_name || ' h ' ||
                        ' WHERE h.hierarchy_obj_def_id = :1 AND ' ||
                        ' h.child_id = :2 AND h.child_value_set_id = :3 AND ' ||
                        ' h.single_depth_flag = ''Y'' ';

       OPEN l_root_csr for l_select_stmt
         USING p_hier_obj_defn_id,p_parent_id, p_parent_value_set_id;
         FETCH l_root_csr
           into l_child_depth_num;
        CLOSE l_root_csr;

       IF(l_child_depth_num <> 1) -- Not a root node
       THEN

         l_select_stmt := ' SELECT ''Y'' FROM DUAL WHERE EXISTS ( ' ||
                          ' SELECT 1 FROM ' || p_hier_table_name ||
                          ' WHERE hierarchy_obj_def_id = :1 ' ||
                          ' AND parent_id = :2 ' ||
                          ' AND child_id <> :3 ' ||
                          ' AND parent_value_set_id = :4 ' ||
                          ' AND single_depth_flag = ''Y'' )';

         OPEN l_imm_parent_child_csr for l_select_stmt
           USING p_hier_obj_defn_id, p_parent_id,
                 p_focus_node,p_parent_value_set_id;
           FETCH l_imm_parent_child_csr
           into l_imm_child_flag;
         CLOSE l_imm_parent_child_csr;





         IF(l_imm_child_flag <> 'Y') -- No children.Insert leaf row.
         THEN

           /* Fetch parent's parent data.
            * The display_order_number, weighting_pct
            * fetched here will be used while
            * inserting leaf row.*/

           l_select_stmt := ' SELECT parent_id, parent_depth_num, ' ||
                          ' child_id, child_depth_num, ' ||
                          ' parent_value_set_id, child_value_set_id, ' ||
                          ' display_order_num,weighting_pct ' ||
                          ' FROM ' || p_hier_table_name || ' h ' ||
                          ' WHERE h.hierarchy_obj_def_id = :1 ' ||
                          ' AND h.child_id = :2 ' ||
                          ' AND h.child_value_set_id = :3 ' ||
                          ' AND h.single_depth_flag = ''Y'' ';

          OPEN l_imm_parent_csr for l_select_stmt
            USING p_hier_obj_defn_id, p_parent_id,p_parent_value_set_id;
          LOOP
            FETCH l_imm_parent_csr
             into l_parent_id, l_parent_depth_num,l_child_id, l_child_depth_num,
             l_parent_value_set_id,l_child_value_set_id,l_display_order_num,l_weighting_pct;
            EXIT WHEN l_imm_parent_csr%NOTFOUND;
          END LOOP;
          CLOSE l_imm_parent_csr;

           --Bug#4240532, Provide column list for insert stmt

           l_leaf_flat_stmt := ' INSERT INTO '|| p_hier_table_name ||
                               ' (       '||
                               'HIERARCHY_OBJ_DEF_ID, '||
                               'PARENT_DEPTH_NUM, '||
                               'PARENT_ID, '||
                               'PARENT_VALUE_SET_ID, '||
                               'CHILD_DEPTH_NUM, '||
                               'CHILD_ID, '||
                               'CHILD_VALUE_SET_ID, '||
                               'SINGLE_DEPTH_FLAG,'||
                               'DISPLAY_ORDER_NUM,'||
                               'WEIGHTING_PCT, ' ||
                               'CREATION_DATE,'||
                               'CREATED_BY, '||
                               'LAST_UPDATED_BY,'||
                               'LAST_UPDATE_DATE,'||
                               'LAST_UPDATE_LOGIN, '||
                               'OBJECT_VERSION_NUMBER) '||
                               ' values '||
                               '( :1, '||
                               '  :lparentdepthnum,'||
                               '  :lparentid,'||
                               '  :lparentvaluesetid,'||
                               '  :2, :3,:4,:5,:6,:7,:8,:9,:10,:11,:12,:13)' ;
           EXECUTE immediate l_leaf_flat_stmt
                USING p_hier_obj_defn_id,l_child_depth_num,
                      l_child_id,l_child_value_set_id,
                      l_child_depth_num ,l_child_id,l_child_value_set_id,
                      'N',l_display_order_num,
                      l_weighting_pct, g_current_date,
                      g_current_user_id,g_current_user_id,
                      g_current_date,g_current_login_id,l_stat;
         END IF;
     END IF;




     /* Remove flattened entries of the focus node
      * where focus node is the child
      */

     execute immediate 'Delete '||p_hier_table_name||
                       ' where  hierarchy_obj_def_id = '||p_hier_obj_defn_id||
                       ' and    child_id  =  '||p_focus_node ||
                       ' and    child_value_set_id =  '||p_focus_value_set_id||
                       ' and    single_depth_flag = ''N''';
     -- End Bug#4022561




  else

    -- Start Bug#4022561

    /* Remove any flattened entries of the immediate
     * children of the deleted member
     */

    IF(p_operation = 'RemoveImmChildren') THEN
       l_imm_delete_stmt := 'DELETE FROM ' || p_hier_table_name ||
                     ' WHERE hierarchy_obj_def_id = :1 ' ||
                     ' AND child_id = :2 ' ||
                     ' AND single_depth_flag = ''N''';


        EXECUTE IMMEDIATE l_imm_delete_stmt
          using p_hier_obj_defn_id , p_imm_child_id;

        RETURN;

     END IF;

     -- End Bug#4022561


     l_chi_stmt := 'Select child_id '||
                   '  from '||p_hier_table_name||
                   ' where  hierarchy_obj_def_id = '||p_hier_obj_defn_id||
                   ' and    parent_id  = :1 '||
                   ' and    single_depth_flag = ''N''';

     l_del_stmt := 'Delete '||p_hier_table_name||
                   ' where  hierarchy_obj_def_id = '||p_hier_obj_defn_id||
                   ' and    child_id  = :1 '||
                   ' and    single_depth_flag = ''N''';

     open dhm_chi_cur for l_chi_stmt
      using p_focus_node;
     Loop
       Fetch dhm_chi_cur bulk collect into  l_child_ids_tbl limit 500;

       if l_child_ids_tbl.count = 0 then
           exit;
       end if;

       Forall i in 1..l_child_ids_tbl.count
         EXECUTE IMMEDIATE l_del_stmt
         using l_child_ids_tbl(i);

      commit;
     End Loop;

     -- Start Bug#4022561

      /* Check if the immediate parent of the deleted
       * member has any other children. If not,insert a leaf
       * entry for the parent node only if it is not a root.
       */



       l_select_stmt := ' SELECT h.child_depth_num ' ||
                        ' FROM ' || p_hier_table_name || ' h ' ||
                        ' WHERE h.hierarchy_obj_def_id = :1 AND ' ||
                        ' h.child_id = :2 AND ' ||
                        ' h.single_depth_flag = ''Y'' ';

       OPEN l_root_csr for l_select_stmt
         USING p_hier_obj_defn_id,p_parent_id;
         FETCH l_root_csr
           into l_child_depth_num;
        CLOSE l_root_csr;

       IF(l_child_depth_num <> 1) -- Not a root node
       THEN

         l_select_stmt := ' SELECT ''Y'' FROM DUAL WHERE EXISTS ( ' ||
                          ' SELECT 1 FROM ' || p_hier_table_name ||
                          ' WHERE hierarchy_obj_def_id = :1 ' ||
                          ' AND parent_id = :2 ' ||
                          ' AND child_id <> :3 ' ||
                          ' AND single_depth_flag = ''Y'' )';

         OPEN l_imm_parent_child_csr for l_select_stmt
           USING p_hier_obj_defn_id, p_parent_id,
                 p_focus_node;
           FETCH l_imm_parent_child_csr
           into l_imm_child_flag;
         CLOSE l_imm_parent_child_csr;





         IF(l_imm_child_flag <> 'Y') -- No children.Insert leaf row.
         THEN

           /* Fetch parent's parent data.
            * The display_order_number, weighting_pct
            * fetched here will be used while
            * inserting leaf row.*/

           l_select_stmt := ' SELECT parent_id, parent_depth_num, ' ||
                          ' child_id, child_depth_num, ' ||
                          ' display_order_num,weighting_pct ' ||
                          ' FROM ' || p_hier_table_name || ' h ' ||
                          ' WHERE h.hierarchy_obj_def_id = :1 ' ||
                          ' AND h.child_id = :2 ' ||
                          ' AND h.single_depth_flag = ''Y'' ';

          OPEN l_imm_parent_csr for l_select_stmt
            USING p_hier_obj_defn_id, p_parent_id;
          LOOP
            FETCH l_imm_parent_csr
             into l_parent_id, l_parent_depth_num,l_child_id, l_child_depth_num,
             l_display_order_num,l_weighting_pct;
            EXIT WHEN l_imm_parent_csr%NOTFOUND;
          END LOOP;
          CLOSE l_imm_parent_csr;

          --Bug#4240532, Provide column list for insert stmt

           l_leaf_flat_stmt := 'INSERT INTO '||p_hier_table_name||
                               ' (       '||
                               'HIERARCHY_OBJ_DEF_ID, '||
                               'PARENT_DEPTH_NUM, '||
                               'PARENT_ID, '||
                               'CHILD_DEPTH_NUM, '||
                               'CHILD_ID, '||
                               'SINGLE_DEPTH_FLAG,'||
                               'DISPLAY_ORDER_NUM,'||
                               'WEIGHTING_PCT, ' ||
                               'CREATION_DATE,'||
                               'CREATED_BY, '||
                               'LAST_UPDATED_BY,'||
                               'LAST_UPDATE_DATE,'||
                               'LAST_UPDATE_LOGIN, '||
                               'OBJECT_VERSION_NUMBER) '||
                               ' values '||
                               '( :1, '||
                               '  :lparentdepthnum,'||
                               '  :lparentid,'||
                               '  :2, :3,:4,:5,:6,:7,:8,:9,:10,:11,:12)' ;


            EXECUTE immediate l_leaf_flat_stmt
                USING p_hier_obj_defn_id,l_child_depth_num,
                      l_child_id,
                      l_child_depth_num ,l_child_id,
                      'N',l_display_order_num,
                      l_weighting_pct, g_current_date,
                      g_current_user_id,g_current_user_id,
                      g_current_date,g_current_login_id,l_stat;
         END IF;
     END IF;



     /* Remove flattened entries of the focus node
      * where focus node is the child
      */

     execute immediate 'Delete '||p_hier_table_name||
                       ' where  hierarchy_obj_def_id = '||p_hier_obj_defn_id||
                       ' and    child_id  =  '||p_focus_node ||
                       ' and    single_depth_flag = ''N''';
     -- End Bug#4022561





   end if;

  --
  -- End standard API section.
  --

  --
  -- Down below are again the standard end and exception sections of the API.
  --

  --
  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;
  --
  FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
			      p_data  => x_msg_data );
  --
EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Unflatten_Focus_Node_Tree_Pvt ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
				p_data  => x_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Unflatten_Focus_Node_Tree_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
				p_data  => x_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Unflatten_Focus_Node_Tree_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name);
    END if;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
				p_data  => x_msg_data );
   --

End Unflatten_Focus_Node_Tree;

/*===========================================================================+
 |                     PROCEDURE Flatten_Whole_Hier_Version_CP               |
 +===========================================================================*/

--
-- The concurrent program to flatten the whole hierarchy version.
--

PROCEDURE Flatten_Whole_Hier_Version_CP
(
  errbuf                  OUT  NOCOPY  VARCHAR2  ,
  retcode                 OUT  NOCOPY  VARCHAR2  ,
  --
  p_hierarchy_id          IN           NUMBER   ,
  p_hier_obj_defn_id      IN           NUMBER
)
IS

  --
  l_api_name       CONSTANT VARCHAR2(30)   := 'Flatten_Whole_Hier_Version_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  --
  l_return_status  VARCHAR2(1);
  l_msg_count      number;
  l_msg_data       varchar2(2000);

BEGIN

  retcode := 0 ;
  Flatten_Whole_Hier_Version
  (
     p_api_version       => 1.0,
     x_return_status     => l_return_status  ,
     x_msg_count         => l_msg_count,
     x_msg_data          => l_msg_data,
     --
     p_hier_obj_defn_id  => p_hier_obj_defn_id
  );

  COMMIT WORK;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     --
     retcode := 2 ;
     COMMIT WORK ;
     --
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     retcode := 2 ;
     COMMIT WORK ;
     --
  WHEN OTHERS THEN

      --
     IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      --
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
                               l_api_name  ) ;
     END IF ;
     --
     retcode := 2 ;
     COMMIT WORK ;
     --

End Flatten_Whole_Hier_Version_CP;


/*===========================================================================+
 |                     PROCEDURE Flatten_Focus_Node_CP                       |
 +===========================================================================*/

--
-- The concurrent program
-- flattens  the immediate children of the
-- focus node specified if the operation is 'Add'
-- flattens all the child nodes under the focus
-- node tree if the operation is 'Move'
-- Unflattens or deletes flattening details
-- of all the child nodes under the given
-- focus node tree if the operation is 'Remove'.
--

PROCEDURE Flatten_Focus_Node_CP
(
  errbuf                        OUT  NOCOPY  VARCHAR2  ,
  retcode                       OUT  NOCOPY  VARCHAR2  ,
  --
  p_hier_obj_defn_id            IN           NUMBER    ,
  p_hier_table_name             IN           VARCHAR2  ,
  p_focus_node                  IN           NUMBER    ,
  p_focus_value_set_id          IN           NUMBER    ,
  p_parent_id                   IN           NUMBER    ,
  p_parent_value_set_id         IN           NUMBER    ,
  p_imm_child_id                IN           NUMBER    ,
  p_imm_child_value_set_id      IN           NUMBER    ,
  p_operation                   IN           VARCHAR2
)
IS

  --
  l_api_name       CONSTANT VARCHAR2(30)   := 'Flatten_Focus_Node_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  --
  l_return_status  VARCHAR2(1);
  l_msg_count      number;
  l_msg_data       varchar2(2000);

BEGIN

  retcode := 0 ;

  if (p_operation = 'Add') then
     Flatten_Focus_Node
     (
         p_api_version          => 1.0,
         x_return_status        => l_return_status  ,
         x_msg_count            => l_msg_count,
         x_msg_data             => l_msg_data,
         --
         p_hier_obj_defn_id     => p_hier_obj_defn_id,
         p_hier_table_name      => p_hier_table_name,
         p_focus_node           => p_focus_node,
         p_focus_value_set_id   => p_focus_value_set_id
     );

    if l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR ;
    end if;

  elsif (p_operation = 'Move') then
     Flatten_Focus_Node_Tree
     (
         p_api_version         => 1.0,
         x_return_status       => l_return_status  ,
         x_msg_count           => l_msg_count,
         x_msg_data            => l_msg_data,
         --
         p_hier_obj_defn_id    => p_hier_obj_defn_id,
         p_hier_table_name     => p_hier_table_name,
         p_focus_node          => p_focus_node,
         p_focus_value_set_id  => p_focus_value_set_id
     );
  elsif (p_operation = 'Remove') then
     Unflatten_Focus_Node_Tree
     (
         p_api_version                => 1.0,
         x_return_status              => l_return_status  ,
         x_msg_count                  => l_msg_count,
         x_msg_data                   => l_msg_data,
         --
         p_hier_obj_defn_id           => p_hier_obj_defn_id,
         p_hier_table_name            => p_hier_table_name,
         p_focus_node                 => p_focus_node,
         p_focus_value_set_id         => p_focus_value_set_id,
         p_parent_id                  => p_parent_id,
         p_parent_value_set_id        => p_parent_value_set_id,
         p_imm_child_id               => p_imm_child_id,
         p_imm_child_value_set_id     => p_imm_child_value_set_id,
         p_operation                  => p_operation
      );

  -- Start Bug#4022561

  elsif (p_operation = 'RemoveImmChildren') then
     Unflatten_Focus_Node_Tree
     (
         p_api_version                => 1.0,
         x_return_status              => l_return_status  ,
         x_msg_count                  => l_msg_count,
         x_msg_data                   => l_msg_data,
         --
         p_hier_obj_defn_id           => p_hier_obj_defn_id,
         p_hier_table_name            => p_hier_table_name,
         p_focus_node                 => p_focus_node,
         p_focus_value_set_id         => p_focus_value_set_id,
         p_parent_id                  => p_parent_id,
         p_parent_value_set_id        => p_parent_value_set_id,
         p_imm_child_id               => p_imm_child_id,
         p_imm_child_value_set_id     => p_imm_child_value_set_id,
         p_operation                  => p_operation
      );

  -- End Bug#4022561

  end if;

  COMMIT WORK;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     --
     retcode := 2 ;
     COMMIT WORK ;
     --
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     retcode := 2 ;
     COMMIT WORK ;
     --
  WHEN OTHERS THEN

      --
     IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      --
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
                               l_api_name  ) ;
     END IF ;
     --
     retcode := 2 ;
     COMMIT WORK ;
     --

End Flatten_Focus_Node_CP;

/*===========================================================================+
 |                     PROCEDURE Insert_Root_Node                            |
 +===========================================================================*/
--
-- The API to insert Root Nodes.
--
PROCEDURE Insert_Root_Node (
			p_api_version         	IN    		NUMBER ,
  			p_init_msg_list       	IN    		VARCHAR2 := FND_API.G_FALSE ,
  			p_commit              	IN    		VARCHAR2 := FND_API.G_FALSE ,
  			p_validation_level    	IN    		NUMBER  := FND_API.G_VALID_LEVEL_FULL ,
  			p_return_status       	OUT NOCOPY   	VARCHAR2 ,
  			p_msg_count           	OUT NOCOPY   	NUMBER  ,
  			p_msg_data            	OUT NOCOPY   	VARCHAR2 ,
  			p_rowid	                IN OUT NOCOPY	VARCHAR2,
                        p_vs_required_flag      IN          	VARCHAR2,
 			p_hier_table_name 	IN 		VARCHAR2,
			p_hier_obj_def_id 	IN 		NUMBER,
			p_parent_depth_num 	IN 		NUMBER,
			p_parent_id 		IN 		NUMBER,
			p_parent_value_set_id 	IN 		NUMBER,
			p_child_depth_num 	IN 		NUMBER,
			p_child_id 		IN 		NUMBER,
			p_child_value_set_id 	IN 		NUMBER,
			p_single_depth_flag 	IN 		VARCHAR2,
			p_display_order_num 	IN 		NUMBER,
			p_weighting_pct 	IN 		NUMBER ) IS

l_sql_stmt VARCHAR2(2000);
l_creation_date  DATE  ;
l_created_by   NUMBER ;
l_last_update_date  DATE  ;
l_last_Updated_by   NUMBER ;
l_last_update_login  NUMBER ;

BEGIN

 SAVEPOINT Insert_Root_Node_Pvt ;


 IF FND_API.to_Boolean ( p_init_msg_list ) THEN

  FND_MSG_PUB.initialize ;

 END IF;

 p_return_status := FND_API.G_RET_STS_SUCCESS ;
 l_creation_date := SYSDATE ;
 l_last_update_date := SYSDATE;
 l_last_Updated_by := FND_GLOBAL.User_Id;
 l_created_by := FND_GLOBAL.User_Id;
 l_last_update_login := FND_GLOBAL.Login_Id ;

 IF p_vs_required_flag = 'Y' THEN
   l_sql_stmt := 'INSERT INTO '||p_hier_table_name||
        ' (       '||
	'HIERARCHY_OBJ_DEF_ID, '||
	'PARENT_DEPTH_NUM, '||
	'PARENT_ID, '||
	'PARENT_VALUE_SET_ID, '||
	'CHILD_DEPTH_NUM, '||
	'CHILD_ID, '||
	'CHILD_VALUE_SET_ID, '||
	'SINGLE_DEPTH_FLAG,'||
	'DISPLAY_ORDER_NUM,'||
	'CREATION_DATE,'||
	'CREATED_BY, '||
	'LAST_UPDATED_BY,'||
	'LAST_UPDATE_DATE,'||
	'LAST_UPDATE_LOGIN, '||
	'OBJECT_VERSION_NUMBER) '||
     ' VALUES ('||
	p_hier_obj_def_id||','||
	p_parent_depth_num||','||
	p_parent_id||','||
	p_parent_value_set_id||','||
	p_child_depth_num||','||
	p_child_id||','||
	p_child_value_set_id||','''||
	p_single_depth_flag||''','||
	p_display_order_num||','''||
	sysdate||''','||
	l_created_by||','||
	l_last_Updated_by||','''||
	sysdate||''','||
	l_last_update_login ||','||1||')';
  ELSE
   l_sql_stmt := 'INSERT INTO '||p_hier_table_name||
        ' (       '||
	'HIERARCHY_OBJ_DEF_ID, '||
	'PARENT_DEPTH_NUM, '||
	'PARENT_ID, '||
	'CHILD_DEPTH_NUM, '||
	'CHILD_ID, '||
	'SINGLE_DEPTH_FLAG,'||
	'DISPLAY_ORDER_NUM,'||
	'CREATION_DATE,'||
	'CREATED_BY, '||
	'LAST_UPDATED_BY,'||
	'LAST_UPDATE_DATE,'||
	'LAST_UPDATE_LOGIN, '||
	'OBJECT_VERSION_NUMBER) '||
     ' VALUES ('||
	p_hier_obj_def_id||','||
	p_parent_depth_num||','||
	p_parent_id||','||
	p_child_depth_num||','||
	p_child_id||','''||
	p_single_depth_flag||''','||
	p_display_order_num||','''||
	sysdate||''','||
	l_created_by||','||
	l_last_Updated_by||','''||
	sysdate||''','||
	l_last_update_login ||','||1||')';
  END IF;
  execute immediate l_sql_stmt;

  IF (sql%notfound) then

   RAISE no_data_found;

  END IF;

 IF FND_API.To_Boolean ( p_commit ) THEN

  COMMIT WORK;

 END iF;

 FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			   p_data => p_msg_data );

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN

  ROLLBACK TO Insert_Root_Node_Pvt ;

  p_return_status := FND_API.G_RET_STS_ERROR;

  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data => p_msg_data );

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

  ROLLBACK TO Insert_Root_Node_Pvt ;
  p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data => p_msg_data );

 WHEN OTHERS THEN

  ROLLBACK TO Insert_Root_Node_Pvt ;
  p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data => p_msg_data );


END Insert_Root_Node;

/*===========================================================================+
 |                     PROCEDURE Launch_Dup_Hier_Process                     |
 +===========================================================================*/
--
-- The concurrent program to duplicate a Hierarchy.
--

PROCEDURE Launch_Dup_Hier_Process(ERRBUFF	IN OUT NOCOPY VARCHAR2,
				  RETCODE	IN OUT NOCOPY VARCHAR2,
				  p_hier_table_name       IN VARCHAR2,
			          p_src_hier_obj_id 	  IN NUMBER,
				  p_dest_hier_name IN VARCHAR2,
				  p_dest_hier_desc in VARCHAR2,
				  p_dest_hier_folder_id IN NUMBER,
				  p_src_hier_version_id IN NUMBER,
				  p_dest_version_name IN VARCHAR2,
				  p_dest_version_desc IN VARCHAR2,
				  p_dest_start_date IN VARCHAR2,
				  p_dest_end_date IN VARCHAR2)
is

l_msg_count NUMBER;
l_return_status VARCHAR2(1);
l_msg_data VARCHAR2(630);
l_dest_start_date DATE;
l_dest_end_date DATE;

begin

  l_dest_start_date := fnd_date.canonical_to_date(p_dest_start_date);
  l_dest_end_date := fnd_date.canonical_to_date(p_dest_end_date);

  duplicate_hierarchy (p_api_version => 1.0,
                       p_return_status => l_return_status,
		       p_msg_count => l_msg_count,
		       p_msg_data => l_msg_data,
		       p_hier_table_name => p_hier_table_name,
		       p_src_hier_obj_id => p_src_hier_obj_id,
		       p_dest_hier_name => p_dest_hier_name,
		       p_dest_hier_desc => p_dest_hier_desc,
		       p_dest_hier_folder_id => p_dest_hier_folder_id,
		       p_src_hier_version_id => p_src_hier_version_id,
		       p_dest_version_name => p_dest_version_name,
		       p_dest_version_desc => p_dest_version_desc,
		       p_dest_start_date => l_dest_start_date,
		       p_dest_end_date => l_dest_end_date);

  if l_return_status in ('U', 'E') then
    RETCODE := 2;
    ERRBUFF := l_msg_data;
  else
    RETCODE := 0;
    ERRBUFF := l_msg_data;
  end if;

end Launch_Dup_Hier_Process;

/*===========================================================================+
 |                     PROCEDURE Duplicate_Hierarchy                         |
 +===========================================================================*/

--
-- The API to duplicate a Hierarchy.
--
PROCEDURE Duplicate_Hierarchy (
                               p_api_version         	IN    		NUMBER ,
                               p_init_msg_list       	IN    		VARCHAR2 := FND_API.G_FALSE ,
                               p_commit              	IN    		VARCHAR2 := FND_API.G_FALSE ,
                               p_validation_level    	IN    		NUMBER  := FND_API.G_VALID_LEVEL_FULL ,
                               p_return_status       	OUT NOCOPY   	VARCHAR2 ,
                               p_msg_count           	OUT NOCOPY   	NUMBER  ,
                               p_msg_data            	OUT NOCOPY   	VARCHAR2 ,
                               p_hier_table_name 	IN 		VARCHAR2,
                               p_src_hier_obj_id 	IN 		NUMBER,
                               p_dest_hier_name        IN 		VARCHAR2,
                               p_dest_hier_desc        IN 		VARCHAR2,
                               p_dest_hier_folder_id   IN 		NUMBER,
                               p_src_hier_version_id 	IN 		NUMBER,
                               p_dest_version_name     IN 		VARCHAR2,
                               p_dest_version_desc     IN 		VARCHAR2,
                               p_dest_start_date       IN      	DATE,
                               p_dest_end_date         IN      	DATE) IS

l_creation_date     DATE  ;
l_created_by        NUMBER ;
l_last_update_date  DATE  ;
l_last_Updated_by   NUMBER ;
l_last_update_login NUMBER ;

l_new_object_id     NUMBER;
l_row_id            ROWID;

l_api_name          CONSTANT VARCHAR2(30)   := 'Duplicate_Hierarchy' ;
l_api_version       CONSTANT NUMBER         :=  1.0;

l_hier_dim_groups_rec FEM_HIER_DIMENSION_GRPS%rowtype;
l_object_catalog_details_rec FEM_OBJECT_CATALOG_VL%rowtype;
l_hier_details_rec FEM_HIERARCHIES%rowtype;

cursor l_hier_dim_groups_csr (p_hierarchy_obj_id in NUMBER)
is
select *
from   fem_hier_dimension_grps
where  hierarchy_obj_id = p_hierarchy_obj_id;

cursor l_hier_value_sets_csr (p_hierarchy_obj_id in NUMBER)
is
select *
from   fem_hier_value_sets
where  hierarchy_obj_id = p_hierarchy_obj_id;

cursor l_hier_details_csr (p_hierarchy_obj_id in NUMBER)
is
select *
from   fem_hierarchies
where  hierarchy_obj_id = p_hierarchy_obj_id;

cursor l_object_catalog_details_csr (p_object_id in NUMBER)
is
select *
from   fem_object_catalog_vl
where  object_id = p_object_id;

begin

  SAVEPOINT Dup_Hier_Pvt ;

  if not FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
  then
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  end if;

  if FND_API.to_Boolean ( p_init_msg_list ) then
    FND_MSG_PUB.initialize ;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS ;

  l_creation_date := SYSDATE ;
  l_last_update_date := SYSDATE;
  l_last_Updated_by := FND_GLOBAL.User_Id;
  l_created_by := FND_GLOBAL.User_Id;
  l_last_update_login := FND_GLOBAL.Login_Id ;

  open l_object_catalog_details_csr (p_object_id => p_src_hier_obj_id);
  fetch l_object_catalog_details_csr into l_object_catalog_details_rec;
  close l_object_catalog_details_csr;

  open l_hier_details_csr (p_hierarchy_obj_id => p_src_hier_obj_id);
  fetch l_hier_details_csr into l_hier_details_rec;
  close l_hier_details_csr;

  select fem_object_id_seq.nextval
  into l_new_object_id
  from dual;

-- dbms_output.put_line('duplicate_hierarchy: l_new_object_id = '||l_new_object_id);
  FEM_OBJECT_CATALOG_PKG.insert_row(
        X_ROWID => l_row_id,
        X_OBJECT_ID => l_new_object_id,
        X_OBJECT_TYPE_CODE => l_object_catalog_details_rec.object_type_code,
        X_FOLDER_ID => p_dest_hier_folder_id,
        X_LOCAL_VS_COMBO_ID => l_object_catalog_details_rec.local_vs_combo_id,
        X_OBJECT_ACCESS_CODE => l_object_catalog_details_rec.object_access_code,
        X_OBJECT_ORIGIN_CODE => l_object_catalog_details_rec.object_origin_code,
        X_OBJECT_VERSION_NUMBER => 1,
        X_OBJECT_NAME => p_dest_hier_name,
        X_DESCRIPTION => p_dest_hier_desc,
        X_CREATION_DATE => l_creation_date,
        X_CREATED_BY => l_created_by,
        X_LAST_UPDATE_DATE => l_last_update_date,
        X_LAST_UPDATED_BY => l_last_updated_by,
        X_LAST_UPDATE_LOGIN => l_last_update_login);

  INSERT INTO fem_hierarchies
  (hierarchy_obj_id,
   dimension_id,
   hierarchy_type_code,
   group_sequence_enforced_code,
   multi_top_flag,
   financial_category_flag,
   value_set_id, -- ??? may go away
   calendar_id,
   period_type,
   personal_flag,
   flattened_rows_flag,
   hierarchy_usage_code,

   multi_value_set_flag,
   object_version_number,
   creation_date,
   created_by,
   last_updated_by,
   last_update_date,
   last_update_login)
  VALUES
  (l_new_object_id,
   l_hier_details_rec.dimension_id,
   l_hier_details_rec.hierarchy_type_code,
   l_hier_details_rec.group_sequence_enforced_code,
   l_hier_details_rec.multi_top_flag,
   l_hier_details_rec.financial_category_flag,
   l_hier_details_rec.value_set_id, -- ??? may go away
   l_hier_details_rec.calendar_id,
   l_hier_details_rec.period_type,
   l_hier_details_rec.personal_flag,
   l_hier_details_rec.flattened_rows_flag,
   l_hier_details_rec.hierarchy_usage_code,
   l_hier_details_rec.multi_value_set_flag,
   1,
   l_creation_date,
   l_created_by,
   l_last_updated_by,
   l_last_update_date,
   l_last_update_login);


  for l_hier_dim_groups_rec in l_hier_dim_groups_csr (p_hierarchy_obj_id => p_src_hier_obj_id) loop

    INSERT INTO fem_hier_dimension_grps
    (dimension_group_id,
     hierarchy_obj_id,
     relative_dimension_group_seq,
     creation_date,
     created_by,
     last_updated_by,
     last_update_date,
     last_update_login,
     object_version_number)
    VALUES
    (l_hier_dim_groups_rec.dimension_group_id,
     l_new_object_id,
     l_hier_dim_groups_rec.relative_dimension_group_seq,
     l_creation_date,
     l_created_by,
     l_last_updated_by,
     l_last_update_date,
     l_last_update_login,
     1);

  end loop;

  for l_hier_value_sets_rec in l_hier_value_sets_csr (p_hierarchy_obj_id => p_src_hier_obj_id) loop

    INSERT INTO fem_hier_value_sets
    (hierarchy_obj_id,
     value_set_id,
     creation_date,
     created_by,
     last_updated_by,
     last_update_date,
     last_update_login,
     object_version_number)
     VALUES
     (l_new_object_id,
      l_hier_value_sets_rec.value_set_id,
      l_creation_date,
      l_created_by,
      l_last_updated_by,
      l_last_update_date,
      l_last_update_login,
      1);

  end loop;
-- dbms_output.put_line('duplicate_hierarchy: calling dup_hier_version...');

  duplicate_hier_version(p_api_version => 1.0,
			 p_return_status => p_return_status,
			 p_msg_count => p_msg_count,
			 p_msg_data => p_msg_data,
			 p_hier_table_name => p_hier_table_name,
			 p_src_hier_obj_id => p_src_hier_obj_id,
			 p_dest_hier_obj_id => l_new_object_id,
			 p_src_hier_version_id => p_src_hier_version_id,
			 p_dest_version_name => p_dest_version_name,
			 p_dest_version_desc => p_dest_version_desc,
			 p_dest_start_date => p_dest_start_date,
			 p_dest_end_date => p_dest_end_date);

  if p_return_status <> 'S' then
    RAISE FND_API.G_EXC_ERROR;
  end if;

 FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			   p_data => p_msg_data );

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
  ROLLBACK TO Dup_Hier_Pvt;
  p_return_status := FND_API.G_RET_STS_ERROR;
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data => p_msg_data );

p_msg_data := sqlerrm;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  ROLLBACK TO Dup_Hier_Pvt ;
  p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data => p_msg_data );

p_msg_data := sqlerrm;
 WHEN OTHERS THEN
  ROLLBACK TO Dup_Hier_Pvt ;
  p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data => p_msg_data );

p_msg_data := sqlerrm;
end Duplicate_Hierarchy;


/*===========================================================================+
 |                     PROCEDURE Dup_Cost_Object_Hier_Data                   |
 +===========================================================================*/

--
-- The API to duplicate Cost Object Hier Data from one version to another.
--
PROCEDURE Dup_Cost_Object_Hier_Data(
              x_return_status   OUT NOCOPY VARCHAR2,
	      x_msg_count       OUT NOCOPY NUMBER,
	      x_msg_data        OUT NOCOPY VARCHAR2,
              p_hierarchy_id    IN  NUMBER,
              p_src_version_id  IN  NUMBER,
              p_dest_version_id IN  NUMBER)
IS

l_new_relationship_id   NUMBER;

l_return_status       VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_msg_count           NUMBER;
l_msg_data            VARCHAR2(2000);

l_src_version_start_date   DATE;
l_dest_version_start_date  DATE;

-- Cursor to find out all the relationships that are available in the
-- destination Hier. Version date range but not in source Hier. Version date
-- range. These relationships will be removed from the destination Hier.
-- Version.

CURSOR l_dest_version_hier_data_csr(c_hierarchy_id  IN NUMBER,
             c_src_version_start_date  IN DATE,
             c_dest_version_start_date IN DATE)
IS
 SELECT  parent_id,
         child_id,
         child_sequence_num
 FROM    fem_cost_objects_hier
 WHERE   hierarchy_obj_id = c_hierarchy_id
 AND     c_dest_version_start_date
                           BETWEEN effective_start_date AND effective_end_date
 MINUS
 SELECT  parent_id,
         child_id,
         child_sequence_num
 FROM    fem_cost_objects_hier
 WHERE   hierarchy_obj_id = c_hierarchy_id
 AND     c_src_version_start_date
                            BETWEEN effective_start_date AND effective_end_date;

-- Cursor to find out all the relationships that are available in the
-- source Hier. Version date range but not in destination Hier. Version date
-- range. These relationships will be added to the destination Hier.
-- Version.

CURSOR l_src_version_hier_data_csr(c_hierarchy_id  IN NUMBER,
             c_src_version_start_date  IN DATE,
             c_dest_version_start_date IN DATE)
IS
 SELECT parent_id,
        child_id,
        display_order_num,
        bom_reference,
        parent_qty,
        child_qty,
        yield_percentage
 FROM   fem_cost_objects_hier fcoh,
        fem_cost_obj_hier_qty fcohq
 WHERE  hierarchy_obj_id = c_hierarchy_id
 AND    fcoh.relationship_id = fcohq.relationship_id
 AND    c_src_version_start_date
                            BETWEEN effective_start_date AND effective_end_date
 MINUS
 SELECT parent_id,
        child_id,
        display_order_num,
        bom_reference,
        parent_qty,
        child_qty,
        yield_percentage
 FROM   fem_cost_objects_hier fcoh,
        fem_cost_obj_hier_qty fcohq
 WHERE  hierarchy_obj_id = c_hierarchy_id
 AND    fcoh.relationship_id = fcohq.relationship_id
 AND    c_dest_version_start_date
                            BETWEEN effective_start_date AND effective_end_date;

CURSOR l_hier_ver_detail_csr (c_version_id IN NUMBER)
IS
 SELECT effective_start_date
 FROM   fem_object_definition_b
 WHERE  object_definition_id = c_version_id;

BEGIN

  SAVEPOINT Dup_Cost_Object_Hier_Data_Pvt;

  OPEN l_hier_ver_detail_csr (c_version_id => p_src_version_id);
  FETCH l_hier_ver_detail_csr INTO l_src_version_start_date;
  CLOSE l_hier_ver_detail_csr;

  OPEN l_hier_ver_detail_csr (c_version_id => p_dest_version_id);
  FETCH l_hier_ver_detail_csr INTO l_dest_version_start_date;
  CLOSE l_hier_ver_detail_csr;

  FOR l_dest_version_hier_data_rec IN l_dest_version_hier_data_csr
                       (c_hierarchy_id => p_hierarchy_id,
                        c_src_version_start_date => l_src_version_start_date,
                        c_dest_version_start_date => l_dest_version_start_date)
  LOOP

    remove_relation(p_api_version => 1.0,
        x_return_status => l_return_status,
        x_msg_count => l_msg_count,
        x_msg_data => l_msg_data,
	p_hierarchy_id => p_hierarchy_id,
	p_version_id => p_dest_version_id,
	p_parent_id => l_dest_version_hier_data_rec.parent_id,
	p_child_id => l_dest_version_hier_data_rec.child_id,
	p_child_sequence_num => l_dest_version_hier_data_rec.child_sequence_num,
	p_hier_table_name => 'FEM_COST_OBJECTS_HIER',
        p_remove_all_children_flag => 'N');

    IF l_return_status = FND_API.G_RET_STS_ERROR
    THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;

  END LOOP;

  FOR l_src_version_hier_data_rec IN l_src_version_hier_data_csr
                       (c_hierarchy_id => p_hierarchy_id,
                        c_src_version_start_date => l_src_version_start_date,
                        c_dest_version_start_date => l_dest_version_start_date)
  LOOP

    Add_Relation(p_api_version => 1.0,
            x_return_status => l_return_status,
            x_msg_count => l_msg_count,
            x_msg_data => l_msg_data,
            p_hierarchy_id => p_hierarchy_id,
            p_version_id => p_dest_version_id,
            p_parent_id => l_src_version_hier_data_rec.parent_id,
            p_parent_qty => l_src_version_hier_data_rec.parent_qty,
            p_child_id => l_src_version_hier_data_rec.child_id,
            p_child_qty => l_src_version_hier_data_rec.child_qty,
            p_yield_pct => l_src_version_hier_data_rec.yield_percentage,
            p_bom_reference => l_src_version_hier_data_rec.bom_reference,
            p_display_order_num=>l_src_version_hier_data_rec.display_order_num,
            p_hier_table_name => 'FEM_COST_OBJECTS_HIER');

    IF l_return_status = FND_API.G_RET_STS_ERROR
    THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;

  END LOOP;

  x_return_status := FND_API.G_RET_STS_SUCCESS ;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Dup_Cost_Object_Hier_Data_Pvt ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
				p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Dup_Cost_Object_Hier_Data_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
				p_data  => x_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Dup_Cost_Object_Hier_Data_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
				p_data  => x_msg_data );

END Dup_Cost_Object_Hier_Data;

/*===========================================================================+
 |                     PROCEDURE Copy_Hier_Data                              |
 +===========================================================================*/

--
-- The API to copy Hierarchy Data from one Hierarchy to another.
--
PROCEDURE Copy_Hier_Data( p_return_status  OUT NOCOPY VARCHAR2,
			  p_msg_count      OUT NOCOPY NUMBER,
			  p_msg_data       OUT NOCOPY VARCHAR2,
			  p_hier_table_name IN VARCHAR2,
			  p_src_hier_obj_id IN NUMBER,

			  p_dest_hier_obj_id IN NUMBER,
			  p_src_hier_version_id  IN NUMBER,
			  p_dest_hier_version_id IN NUMBER)
is
TYPE t_rowid   			is TABLE OF VARCHAR2(50);
TYPE t_parent_depth_num 	is TABLE OF fem_products_hier.parent_depth_num%TYPE;
TYPE t_parent_id  		is TABLE OF fem_products_hier.parent_id%TYPE;
TYPE t_parent_value_set_id 	is TABLE OF fem_products_hier.parent_value_set_id%TYPE;
TYPE t_child_depth_num 		is TABLE OF fem_products_hier.child_depth_num%TYPE;
TYPE t_child_id   		is TABLE OF fem_products_hier.child_id%TYPE;
TYPE t_child_value_set_id   	is TABLE OF fem_products_hier.child_value_set_id%TYPE;
TYPE t_single_depth_flag    	is TABLE OF fem_products_hier.single_depth_flag%TYPE;
TYPE t_display_order_num    	is TABLE OF fem_products_hier.display_order_num%TYPE;
TYPE t_weighting_pct    	is TABLE OF fem_products_hier.weighting_pct%TYPE;

t_row_id		t_rowid;
t_prnt_depth_num 	t_parent_depth_num;
t_prnt_id  		t_parent_id;
t_prnt_value_set_id 	t_parent_value_set_id;
t_chld_depth_num 	t_child_depth_num;
t_chld_id   		t_child_id;
t_chld_value_set_id   	t_child_value_set_id;
t_sngle_depth_flag    	t_single_depth_flag;
t_dspy_order_num    	t_display_order_num;
t_wt_pct    	        t_weighting_pct;

-- The following is for Cost Object Hierarchy Data.
TYPE t_co_rowid 		is TABLE OF VARCHAR2(50);
TYPE t_co_relationship_id	is TABLE OF fem_cost_objects_hier.relationship_id%TYPE;
TYPE t_co_effective_start_date	is TABLE OF fem_cost_objects_hier.effective_start_date%TYPE;
TYPE t_co_hierarchy_obj_id      is TABLE OF fem_cost_objects_hier.hierarchy_obj_id%TYPE;
TYPE t_co_parent_id             is TABLE OF fem_cost_objects_hier.parent_id%TYPE;
TYPE t_co_child_id              is TABLE OF fem_cost_objects_hier.child_id%TYPE;
TYPE t_co_child_sequence_num    is TABLE OF fem_cost_objects_hier.child_sequence_num%TYPE;
TYPE t_co_display_order_num     is TABLE OF fem_cost_objects_hier.display_order_num%TYPE;
TYPE t_co_effective_end_date    is TABLE OF fem_cost_objects_hier.effective_end_date%TYPE;
TYPE t_co_bom_reference         is TABLE OF fem_cost_objects_hier.bom_reference%TYPE;

TYPE t_co_dataset_code          is TABLE OF fem_cost_obj_hier_qty.dataset_code%TYPE;
TYPE t_co_cal_period_id         is TABLE OF fem_cost_obj_hier_qty.cal_period_id%TYPE;
TYPE t_co_parent_qty            is TABLE OF fem_cost_obj_hier_qty.parent_qty%TYPE;
TYPE t_co_child_qty             is TABLE OF fem_cost_obj_hier_qty.child_qty%TYPE;
TYPE t_co_yield_percentage      is TABLE OF fem_cost_obj_hier_qty.yield_percentage%TYPE;

t_co_row_id             t_co_rowid;
t_co_rel_id             t_co_relationship_id;
t_co_eff_start_date     t_co_effective_start_date;
t_co_hier_obj_id        t_co_hierarchy_obj_id;
t_co_prnt_id            t_co_parent_id;
t_co_chld_id            t_co_child_id;
t_co_chld_sequence_num  t_co_child_sequence_num;
t_co_disp_order_num     t_co_display_order_num;
t_co_eff_end_date       t_co_effective_end_date;
t_co_bom_ref            t_co_bom_reference;

t_co_ds_code            t_co_dataset_code;
t_co_cal_per_id         t_co_cal_period_id;
t_co_prnt_qty           t_co_parent_qty;
t_co_chld_qty           t_co_child_qty;

t_co_yld_percentage     t_co_yield_percentage;

l_version_start_date    DATE;

l_creation_date     DATE  := sysdate;
l_created_by        NUMBER := fnd_global.user_id;
l_last_update_date  DATE  := sysdate;
l_last_Updated_by   NUMBER := fnd_global.user_id;
l_last_update_login NUMBER := fnd_global.login_id;

BEGIN

-- dbms_output.put_line('copy_hier_data: start ...');

  SAVEPOINT Copy_Hier_Data_Pvt;

  if p_hier_table_name = 'FEM_PRODUCTS_HIER' then

    select rowid,
           parent_depth_num,
           parent_id,
	   parent_value_set_id,
	   child_depth_num,
	   child_id,
	   child_value_set_id,
	   single_depth_flag,
	   display_order_num,
	   weighting_pct
    bulk collect into
           t_row_id,
	   t_prnt_depth_num,
	   t_prnt_id,
	   t_prnt_value_set_id,
	   t_chld_depth_num,
	   t_chld_id,
	   t_chld_value_set_id,
	   t_sngle_depth_flag,
	   t_dspy_order_num,
	   t_wt_pct
  from     fem_products_hier
  where    hierarchy_obj_def_id = p_src_hier_version_id;

    FORALL rec in t_row_id.FIRST..t_row_id.LAST

    INSERT INTO fem_products_hier
	   ( hierarchy_obj_def_id,
	     parent_depth_num,
	     parent_id ,
	     parent_value_set_id,
	     child_depth_num,
	     child_id,
	     child_value_set_id ,
	     single_depth_flag,
	     display_order_num ,
	     weighting_pct,
	     creation_date ,
	     created_by ,
	     last_updated_by ,
	     last_update_date ,
	     last_update_login ,
	     object_version_number)
    VALUES (p_dest_hier_version_id,
            t_prnt_depth_num(rec),
            t_prnt_id(rec),
	    t_prnt_value_set_id(rec),
	    t_chld_depth_num(rec),
	    t_chld_id(rec),
	    t_chld_value_set_id(rec),
	    t_sngle_depth_flag(rec),
	    t_dspy_order_num(rec),
	    t_wt_pct(rec),
	    l_creation_date,
	    l_created_by,
	    l_last_updated_by,
	    l_last_update_date,
	    l_last_update_login,
	    1);

  elsif p_hier_table_name = 'FEM_CHANNELS_HIER' then

    select rowid,
           parent_depth_num,
           parent_id,
	   parent_value_set_id,
	   child_depth_num,
	   child_id,
	   child_value_set_id,
	   single_depth_flag,
	   display_order_num,
	   weighting_pct
    bulk collect into
           t_row_id,
	   t_prnt_depth_num,
	   t_prnt_id,
	   t_prnt_value_set_id,
	   t_chld_depth_num,
	   t_chld_id,
	   t_chld_value_set_id,
	   t_sngle_depth_flag,
	   t_dspy_order_num,
	   t_wt_pct
  from     fem_channels_hier
  where    hierarchy_obj_def_id = p_src_hier_version_id;

    FORALL rec in t_row_id.FIRST..t_row_id.LAST

    INSERT INTO fem_channels_hier
	   ( hierarchy_obj_def_id,
	     parent_depth_num,
	     parent_id ,
	     parent_value_set_id,
	     child_depth_num,
	     child_id,
	     child_value_set_id ,
	     single_depth_flag,
	     display_order_num ,
	     weighting_pct,
	     creation_date ,
	     created_by ,
	     last_updated_by ,
	     last_update_date ,
	     last_update_login ,
	     object_version_number)
    VALUES (p_dest_hier_version_id,
            t_prnt_depth_num(rec),
            t_prnt_id(rec),
	    t_prnt_value_set_id(rec),
	    t_chld_depth_num(rec),
	    t_chld_id(rec),
	    t_chld_value_set_id(rec),
	    t_sngle_depth_flag(rec),
	    t_dspy_order_num(rec),
	    t_wt_pct(rec),
	    l_creation_date,
	    l_created_by,
	    l_last_updated_by,
	    l_last_update_date,
	    l_last_update_login,
	    1);

  elsif p_hier_table_name = 'FEM_CCTR_ORGS_HIER' then

    select rowid,
           parent_depth_num,
           parent_id,
	   parent_value_set_id,
	   child_depth_num,
	   child_id,
	   child_value_set_id,
	   single_depth_flag,
	   display_order_num,
	   weighting_pct
    bulk collect into
           t_row_id,
	   t_prnt_depth_num,
	   t_prnt_id,
	   t_prnt_value_set_id,
	   t_chld_depth_num,
	   t_chld_id,
	   t_chld_value_set_id,
	   t_sngle_depth_flag,
	   t_dspy_order_num,
	   t_wt_pct
  from     fem_cctr_orgs_hier
  where    hierarchy_obj_def_id = p_src_hier_version_id;

    FORALL rec in t_row_id.FIRST..t_row_id.LAST

    INSERT INTO fem_cctr_orgs_hier
	   ( hierarchy_obj_def_id,
	     parent_depth_num,
	     parent_id ,
	     parent_value_set_id,
	     child_depth_num,
	     child_id,
	     child_value_set_id ,
	     single_depth_flag,
	     display_order_num ,
	     weighting_pct,
	     creation_date ,
	     created_by ,
	     last_updated_by ,
	     last_update_date ,
	     last_update_login ,
	     object_version_number)
    VALUES (p_dest_hier_version_id,
            t_prnt_depth_num(rec),
            t_prnt_id(rec),
	    t_prnt_value_set_id(rec),
	    t_chld_depth_num(rec),
	    t_chld_id(rec),
	    t_chld_value_set_id(rec),
	    t_sngle_depth_flag(rec),
	    t_dspy_order_num(rec),
	    t_wt_pct(rec),
	    l_creation_date,
	    l_created_by,
	    l_last_updated_by,
	    l_last_update_date,
	    l_last_update_login,
	    1);

  elsif p_hier_table_name = 'FEM_CUSTOMERS_HIER' then

    select rowid,
           parent_depth_num,
           parent_id,
	   parent_value_set_id,
	   child_depth_num,
	   child_id,
	   child_value_set_id,
	   single_depth_flag,
	   display_order_num,
	   weighting_pct
    bulk collect into
           t_row_id,
	   t_prnt_depth_num,
	   t_prnt_id,
	   t_prnt_value_set_id,
	   t_chld_depth_num,
	   t_chld_id,
	   t_chld_value_set_id,
	   t_sngle_depth_flag,
	   t_dspy_order_num,
	   t_wt_pct
  from     fem_customers_hier
  where    hierarchy_obj_def_id = p_src_hier_version_id;

    FORALL rec in t_row_id.FIRST..t_row_id.LAST

    INSERT INTO fem_customers_hier
	   ( hierarchy_obj_def_id,
	     parent_depth_num,
	     parent_id ,
	     parent_value_set_id,
	     child_depth_num,
	     child_id,
	     child_value_set_id ,
	     single_depth_flag,
	     display_order_num ,
	     weighting_pct,
	     creation_date ,
	     created_by ,
	     last_updated_by ,
	     last_update_date ,
	     last_update_login ,
	     object_version_number)
    VALUES (p_dest_hier_version_id,
            t_prnt_depth_num(rec),
            t_prnt_id(rec),
	    t_prnt_value_set_id(rec),
	    t_chld_depth_num(rec),
	    t_chld_id(rec),
	    t_chld_value_set_id(rec),
	    t_sngle_depth_flag(rec),
	    t_dspy_order_num(rec),
	    t_wt_pct(rec),
	    l_creation_date,
	    l_created_by,
	    l_last_updated_by,
	    l_last_update_date,
	    l_last_update_login,
	    1);

  elsif p_hier_table_name = 'FEM_ENTITIES_HIER' then

    select rowid,
           parent_depth_num,
           parent_id,
	   parent_value_set_id,
	   child_depth_num,
	   child_id,
	   child_value_set_id,
	   single_depth_flag,
	   display_order_num,
	   weighting_pct
    bulk collect into
           t_row_id,
	   t_prnt_depth_num,
	   t_prnt_id,
	   t_prnt_value_set_id,
	   t_chld_depth_num,
	   t_chld_id,
	   t_chld_value_set_id,
	   t_sngle_depth_flag,
	   t_dspy_order_num,
	   t_wt_pct
  from     fem_entities_hier
  where    hierarchy_obj_def_id = p_src_hier_version_id;

    FORALL rec in t_row_id.FIRST..t_row_id.LAST

    INSERT INTO fem_entities_hier
	   ( hierarchy_obj_def_id,
	     parent_depth_num,
	     parent_id ,
	     parent_value_set_id,
	     child_depth_num,
	     child_id,
	     child_value_set_id ,
	     single_depth_flag,
	     display_order_num ,
	     weighting_pct,
	     creation_date ,
	     created_by ,
	     last_updated_by ,
	     last_update_date ,
	     last_update_login ,
	     object_version_number)
    VALUES (p_dest_hier_version_id,
            t_prnt_depth_num(rec),
            t_prnt_id(rec),
	    t_prnt_value_set_id(rec),
	    t_chld_depth_num(rec),
	    t_chld_id(rec),
	    t_chld_value_set_id(rec),
	    t_sngle_depth_flag(rec),
	    t_dspy_order_num(rec),
	    t_wt_pct(rec),
	    l_creation_date,
	    l_created_by,
	    l_last_updated_by,
	    l_last_update_date,
	    l_last_update_login,
	    1);

  elsif p_hier_table_name = 'FEM_GEOGRAPHY_HIER' then

    select rowid,
           parent_depth_num,
           parent_id,
	   parent_value_set_id,
	   child_depth_num,
	   child_id,
	   child_value_set_id,
	   single_depth_flag,
	   display_order_num,
	   weighting_pct
    bulk collect into
           t_row_id,
	   t_prnt_depth_num,
	   t_prnt_id,
	   t_prnt_value_set_id,
	   t_chld_depth_num,
	   t_chld_id,
	   t_chld_value_set_id,
	   t_sngle_depth_flag,
	   t_dspy_order_num,
	   t_wt_pct
  from     fem_geography_hier
  where    hierarchy_obj_def_id = p_src_hier_version_id;

    FORALL rec in t_row_id.FIRST..t_row_id.LAST

    INSERT INTO fem_geography_hier
	   ( hierarchy_obj_def_id,
	     parent_depth_num,
	     parent_id ,
	     parent_value_set_id,
	     child_depth_num,
	     child_id,
	     child_value_set_id ,
	     single_depth_flag,
	     display_order_num ,
	     weighting_pct,
	     creation_date ,
	     created_by ,
	     last_updated_by ,

	     last_update_date ,
	     last_update_login ,
	     object_version_number)
    VALUES (p_dest_hier_version_id,
            t_prnt_depth_num(rec),
            t_prnt_id(rec),
	    t_prnt_value_set_id(rec),
	    t_chld_depth_num(rec),
	    t_chld_id(rec),
	    t_chld_value_set_id(rec),
	    t_sngle_depth_flag(rec),
	    t_dspy_order_num(rec),
	    t_wt_pct(rec),
	    l_creation_date,
	    l_created_by,
	    l_last_updated_by,
	    l_last_update_date,
	    l_last_update_login,
	    1);

  elsif p_hier_table_name = 'FEM_LN_ITEMS_HIER' then

    select rowid,
           parent_depth_num,
           parent_id,
	   parent_value_set_id,
	   child_depth_num,
	   child_id,
	   child_value_set_id,
	   single_depth_flag,
	   display_order_num,
	   weighting_pct

    bulk collect into
           t_row_id,
	   t_prnt_depth_num,
	   t_prnt_id,
	   t_prnt_value_set_id,
	   t_chld_depth_num,
	   t_chld_id,
	   t_chld_value_set_id,
	   t_sngle_depth_flag,
	   t_dspy_order_num,
	   t_wt_pct
  from     fem_ln_items_hier
  where    hierarchy_obj_def_id = p_src_hier_version_id;

    FORALL rec in t_row_id.FIRST..t_row_id.LAST

    INSERT INTO fem_ln_items_hier
	   ( hierarchy_obj_def_id,
	     parent_depth_num,
	     parent_id ,
	     parent_value_set_id,
	     child_depth_num,
	     child_id,
	     child_value_set_id ,
	     single_depth_flag,
	     display_order_num ,
	     weighting_pct,
	     creation_date ,
	     created_by ,
	     last_updated_by ,
	     last_update_date ,
	     last_update_login ,
	     object_version_number)
    VALUES (p_dest_hier_version_id,
            t_prnt_depth_num(rec),
            t_prnt_id(rec),
	    t_prnt_value_set_id(rec),
	    t_chld_depth_num(rec),
	    t_chld_id(rec),
	    t_chld_value_set_id(rec),
	    t_sngle_depth_flag(rec),
	    t_dspy_order_num(rec),
	    t_wt_pct(rec),
	    l_creation_date,
	    l_created_by,
	    l_last_updated_by,
	    l_last_update_date,
	    l_last_update_login,
	    1);


  elsif p_hier_table_name = 'FEM_NAT_ACCTS_HIER' then

    select rowid,
           parent_depth_num,
           parent_id,
	   parent_value_set_id,
	   child_depth_num,
	   child_id,
	   child_value_set_id,
	   single_depth_flag,
	   display_order_num,
	   weighting_pct
    bulk collect into
           t_row_id,
	   t_prnt_depth_num,
	   t_prnt_id,
	   t_prnt_value_set_id,
	   t_chld_depth_num,
	   t_chld_id,
	   t_chld_value_set_id,
	   t_sngle_depth_flag,
	   t_dspy_order_num,
	   t_wt_pct
  from     fem_nat_accts_hier
  where    hierarchy_obj_def_id = p_src_hier_version_id;

    FORALL rec in t_row_id.FIRST..t_row_id.LAST

    INSERT INTO fem_nat_accts_hier
	   ( hierarchy_obj_def_id,
	     parent_depth_num,
	     parent_id ,
	     parent_value_set_id,
	     child_depth_num,
	     child_id,
	     child_value_set_id ,
	     single_depth_flag,
	     display_order_num ,
	     weighting_pct,
	     creation_date ,
	     created_by ,
	     last_updated_by ,
	     last_update_date ,
	     last_update_login ,
	     object_version_number)
    VALUES (p_dest_hier_version_id,
            t_prnt_depth_num(rec),
            t_prnt_id(rec),
	    t_prnt_value_set_id(rec),
	    t_chld_depth_num(rec),
	    t_chld_id(rec),
	    t_chld_value_set_id(rec),
	    t_sngle_depth_flag(rec),
	    t_dspy_order_num(rec),
	    t_wt_pct(rec),
	    l_creation_date,
	    l_created_by,
	    l_last_updated_by,
	    l_last_update_date,
	    l_last_update_login,
	    1);

  elsif p_hier_table_name = 'FEM_PROJECTS_HIER' then

    select rowid,
           parent_depth_num,
           parent_id,
	   parent_value_set_id,
	   child_depth_num,
	   child_id,
	   child_value_set_id,
	   single_depth_flag,
	   display_order_num,
	   weighting_pct
    bulk collect into
           t_row_id,
	   t_prnt_depth_num,
	   t_prnt_id,
	   t_prnt_value_set_id,
	   t_chld_depth_num,
	   t_chld_id,
	   t_chld_value_set_id,
	   t_sngle_depth_flag,
	   t_dspy_order_num,
	   t_wt_pct
  from     fem_projects_hier
  where    hierarchy_obj_def_id = p_src_hier_version_id;

    FORALL rec in t_row_id.FIRST..t_row_id.LAST

    INSERT INTO fem_projects_hier
	   ( hierarchy_obj_def_id,
	     parent_depth_num,
	     parent_id ,
	     parent_value_set_id,
	     child_depth_num,
	     child_id,
	     child_value_set_id ,
	     single_depth_flag,
	     display_order_num ,
	     weighting_pct,
	     creation_date ,
	     created_by ,
	     last_updated_by ,
	     last_update_date ,
	     last_update_login ,
	     object_version_number)
    VALUES (p_dest_hier_version_id,
            t_prnt_depth_num(rec),
            t_prnt_id(rec),
	    t_prnt_value_set_id(rec),
	    t_chld_depth_num(rec),
	    t_chld_id(rec),
	    t_chld_value_set_id(rec),
	    t_sngle_depth_flag(rec),
	    t_dspy_order_num(rec),
	    t_wt_pct(rec),
	    l_creation_date,
	    l_created_by,
	    l_last_updated_by,
	    l_last_update_date,
	    l_last_update_login,
	    1);

  elsif p_hier_table_name = 'FEM_TASKS_HIER' then

    select rowid,
           parent_depth_num,
           parent_id,
	   parent_value_set_id,
	   child_depth_num,
	   child_id,
	   child_value_set_id,
	   single_depth_flag,
	   display_order_num,
	   weighting_pct
    bulk collect into
           t_row_id,
	   t_prnt_depth_num,
	   t_prnt_id,
	   t_prnt_value_set_id,
	   t_chld_depth_num,
	   t_chld_id,
	   t_chld_value_set_id,
	   t_sngle_depth_flag,
	   t_dspy_order_num,
	   t_wt_pct
  from     fem_tasks_hier
  where    hierarchy_obj_def_id = p_src_hier_version_id;

    FORALL rec in t_row_id.FIRST..t_row_id.LAST

    INSERT INTO fem_tasks_hier
	   ( hierarchy_obj_def_id,
	     parent_depth_num,
	     parent_id ,
	     parent_value_set_id,
	     child_depth_num,
	     child_id,
	     child_value_set_id ,
	     single_depth_flag,
	     display_order_num ,
	     weighting_pct,
	     creation_date ,
	     created_by ,
	     last_updated_by ,
	     last_update_date ,
	     last_update_login ,
	     object_version_number)
    VALUES (p_dest_hier_version_id,
            t_prnt_depth_num(rec),
            t_prnt_id(rec),
	    t_prnt_value_set_id(rec),
	    t_chld_depth_num(rec),
	    t_chld_id(rec),
	    t_chld_value_set_id(rec),
	    t_sngle_depth_flag(rec),
	    t_dspy_order_num(rec),
	    t_wt_pct(rec),
	    l_creation_date,
	    l_created_by,
	    l_last_updated_by,
	    l_last_update_date,
	    l_last_update_login,
	    1);

  elsif p_hier_table_name = 'FEM_PROJECTS_HIER' then

    select rowid,
           parent_depth_num,
           parent_id,
	   parent_value_set_id,
	   child_depth_num,
	   child_id,
	   child_value_set_id,
	   single_depth_flag,
	   display_order_num,
	   weighting_pct
    bulk collect into
           t_row_id,
	   t_prnt_depth_num,
	   t_prnt_id,
	   t_prnt_value_set_id,
	   t_chld_depth_num,
	   t_chld_id,
	   t_chld_value_set_id,
	   t_sngle_depth_flag,
	   t_dspy_order_num,
	   t_wt_pct
  from     fem_projects_hier
  where    hierarchy_obj_def_id = p_src_hier_version_id;

    FORALL rec in t_row_id.FIRST..t_row_id.LAST

    INSERT INTO fem_projects_hier
	   ( hierarchy_obj_def_id,
	     parent_depth_num,
	     parent_id ,
	     parent_value_set_id,
	     child_depth_num,
	     child_id,
	     child_value_set_id ,
	     single_depth_flag,
	     display_order_num ,
	     weighting_pct,
	     creation_date ,
	     created_by ,
	     last_updated_by ,
	     last_update_date ,
	     last_update_login ,
	     object_version_number)
    VALUES (p_dest_hier_version_id,
            t_prnt_depth_num(rec),
            t_prnt_id(rec),
	    t_prnt_value_set_id(rec),
	    t_chld_depth_num(rec),
	    t_chld_id(rec),
	    t_chld_value_set_id(rec),
	    t_sngle_depth_flag(rec),
	    t_dspy_order_num(rec),
	    t_wt_pct(rec),
	    l_creation_date,
	    l_created_by,
	    l_last_updated_by,
	    l_last_update_date,
	    l_last_update_login,
	    1);

  elsif p_hier_table_name = 'FEM_USER_DIM1_HIER' then

    select rowid,
           parent_depth_num,
           parent_id,
	   parent_value_set_id,
	   child_depth_num,
	   child_id,
	   child_value_set_id,
	   single_depth_flag,
	   display_order_num,
	   weighting_pct
    bulk collect into
           t_row_id,
	   t_prnt_depth_num,
	   t_prnt_id,
	   t_prnt_value_set_id,
	   t_chld_depth_num,
	   t_chld_id,
	   t_chld_value_set_id,
	   t_sngle_depth_flag,
	   t_dspy_order_num,
	   t_wt_pct
  from     fem_user_dim1_hier
  where    hierarchy_obj_def_id = p_src_hier_version_id;

    FORALL rec in t_row_id.FIRST..t_row_id.LAST

    INSERT INTO fem_user_dim1_hier
	   ( hierarchy_obj_def_id,
	     parent_depth_num,
	     parent_id ,
	     parent_value_set_id,
	     child_depth_num,
	     child_id,
	     child_value_set_id ,
	     single_depth_flag,
	     display_order_num ,
	     weighting_pct,
	     creation_date ,
	     created_by ,
	     last_updated_by ,
	     last_update_date ,
	     last_update_login ,
	     object_version_number)
    VALUES (p_dest_hier_version_id,
            t_prnt_depth_num(rec),
            t_prnt_id(rec),
	    t_prnt_value_set_id(rec),
	    t_chld_depth_num(rec),
	    t_chld_id(rec),
	    t_chld_value_set_id(rec),
	    t_sngle_depth_flag(rec),
	    t_dspy_order_num(rec),
	    t_wt_pct(rec),
	    l_creation_date,
	    l_created_by,
	    l_last_updated_by,
	    l_last_update_date,
	    l_last_update_login,
	    1);

  elsif p_hier_table_name = 'FEM_USER_DIM2_HIER' then

    select rowid,
           parent_depth_num,
           parent_id,
	   parent_value_set_id,
	   child_depth_num,
	   child_id,
	   child_value_set_id,
	   single_depth_flag,
	   display_order_num,
	   weighting_pct
    bulk collect into
           t_row_id,
	   t_prnt_depth_num,
	   t_prnt_id,
	   t_prnt_value_set_id,
	   t_chld_depth_num,
	   t_chld_id,
	   t_chld_value_set_id,
	   t_sngle_depth_flag,
	   t_dspy_order_num,
	   t_wt_pct
  from     fem_user_dim2_hier
  where    hierarchy_obj_def_id = p_src_hier_version_id;

    FORALL rec in t_row_id.FIRST..t_row_id.LAST

 --Bug#5528200: Corrected typo. Should be dim2 not dim3!
    INSERT INTO fem_user_dim2_hier
	   ( hierarchy_obj_def_id,
	     parent_depth_num,
	     parent_id ,
	     parent_value_set_id,
	     child_depth_num,
	     child_id,
	     child_value_set_id ,
	     single_depth_flag,
	     display_order_num ,
	     weighting_pct,
	     creation_date ,
	     created_by ,
	     last_updated_by ,
	     last_update_date ,
	     last_update_login ,
	     object_version_number)
    VALUES (p_dest_hier_version_id,
            t_prnt_depth_num(rec),
            t_prnt_id(rec),
	    t_prnt_value_set_id(rec),
	    t_chld_depth_num(rec),
	    t_chld_id(rec),
	    t_chld_value_set_id(rec),
	    t_sngle_depth_flag(rec),
	    t_dspy_order_num(rec),
	    t_wt_pct(rec),
	    l_creation_date,
	    l_created_by,
	    l_last_updated_by,
	    l_last_update_date,
	    l_last_update_login,
	    1);

  elsif p_hier_table_name = 'FEM_USER_DIM3_HIER' then

    select rowid,
           parent_depth_num,
           parent_id,
	   parent_value_set_id,
	   child_depth_num,
	   child_id,
	   child_value_set_id,
	   single_depth_flag,
	   display_order_num,
	   weighting_pct
    bulk collect into
           t_row_id,
	   t_prnt_depth_num,
	   t_prnt_id,
	   t_prnt_value_set_id,
	   t_chld_depth_num,
	   t_chld_id,
	   t_chld_value_set_id,
	   t_sngle_depth_flag,
	   t_dspy_order_num,
	   t_wt_pct
  from     fem_user_dim3_hier
  where    hierarchy_obj_def_id = p_src_hier_version_id;

    FORALL rec in t_row_id.FIRST..t_row_id.LAST

    INSERT INTO fem_user_dim3_hier
	   ( hierarchy_obj_def_id,
	     parent_depth_num,
	     parent_id ,
	     parent_value_set_id,
	     child_depth_num,
	     child_id,
	     child_value_set_id ,
	     single_depth_flag,
	     display_order_num ,
	     weighting_pct,
	     creation_date ,
	     created_by ,
	     last_updated_by ,
	     last_update_date ,
	     last_update_login ,
	     object_version_number)
    VALUES (p_dest_hier_version_id,
            t_prnt_depth_num(rec),
            t_prnt_id(rec),
	    t_prnt_value_set_id(rec),
	    t_chld_depth_num(rec),
	    t_chld_id(rec),
	    t_chld_value_set_id(rec),
	    t_sngle_depth_flag(rec),
	    t_dspy_order_num(rec),
	    t_wt_pct(rec),
	    l_creation_date,
	    l_created_by,
	    l_last_updated_by,
	    l_last_update_date,
	    l_last_update_login,
	    1);
  elsif p_hier_table_name = 'FEM_USER_DIM4_HIER' then

    select rowid,
           parent_depth_num,
           parent_id,
	   parent_value_set_id,
	   child_depth_num,
	   child_id,
	   child_value_set_id,
	   single_depth_flag,
	   display_order_num,
	   weighting_pct
    bulk collect into
           t_row_id,
	   t_prnt_depth_num,
	   t_prnt_id,
	   t_prnt_value_set_id,
	   t_chld_depth_num,
	   t_chld_id,
	   t_chld_value_set_id,
	   t_sngle_depth_flag,
	   t_dspy_order_num,
	   t_wt_pct
  from     fem_user_dim4_hier
  where    hierarchy_obj_def_id = p_src_hier_version_id;

    FORALL rec in t_row_id.FIRST..t_row_id.LAST

    INSERT INTO fem_user_dim4_hier
	   ( hierarchy_obj_def_id,
	     parent_depth_num,
	     parent_id ,
	     parent_value_set_id,
	     child_depth_num,
	     child_id,
	     child_value_set_id ,
	     single_depth_flag,
	     display_order_num ,
	     weighting_pct,
	     creation_date ,
	     created_by ,
	     last_updated_by ,
	     last_update_date ,
	     last_update_login ,
	     object_version_number)
    VALUES (p_dest_hier_version_id,
            t_prnt_depth_num(rec),
            t_prnt_id(rec),
	    t_prnt_value_set_id(rec),
	    t_chld_depth_num(rec),
	    t_chld_id(rec),
	    t_chld_value_set_id(rec),
	    t_sngle_depth_flag(rec),
	    t_dspy_order_num(rec),
	    t_wt_pct(rec),
	    l_creation_date,
	    l_created_by,
	    l_last_updated_by,
	    l_last_update_date,
	    l_last_update_login,
	    1);
  elsif p_hier_table_name = 'FEM_USER_DIM5_HIER' then

    select rowid,
           parent_depth_num,
           parent_id,
	   parent_value_set_id,
	   child_depth_num,
	   child_id,
	   child_value_set_id,
	   single_depth_flag,
	   display_order_num,
	   weighting_pct
    bulk collect into
           t_row_id,
	   t_prnt_depth_num,
	   t_prnt_id,
	   t_prnt_value_set_id,
	   t_chld_depth_num,
	   t_chld_id,
	   t_chld_value_set_id,
	   t_sngle_depth_flag,
	   t_dspy_order_num,
	   t_wt_pct
  from     fem_user_dim5_hier
  where    hierarchy_obj_def_id = p_src_hier_version_id;

    FORALL rec in t_row_id.FIRST..t_row_id.LAST

    INSERT INTO fem_user_dim5_hier
	   ( hierarchy_obj_def_id,
	     parent_depth_num,
	     parent_id ,
	     parent_value_set_id,
	     child_depth_num,
	     child_id,
	     child_value_set_id ,
	     single_depth_flag,
	     display_order_num ,
	     weighting_pct,
	     creation_date ,
	     created_by ,
	     last_updated_by ,
	     last_update_date ,
	     last_update_login ,
	     object_version_number)
    VALUES (p_dest_hier_version_id,
            t_prnt_depth_num(rec),
            t_prnt_id(rec),
	    t_prnt_value_set_id(rec),
	    t_chld_depth_num(rec),
	    t_chld_id(rec),
	    t_chld_value_set_id(rec),
	    t_sngle_depth_flag(rec),
	    t_dspy_order_num(rec),
	    t_wt_pct(rec),
	    l_creation_date,
	    l_created_by,
	    l_last_updated_by,
	    l_last_update_date,
	    l_last_update_login,
	    1);
  elsif p_hier_table_name = 'FEM_USER_DIM6_HIER' then

    select rowid,
           parent_depth_num,
           parent_id,
	   parent_value_set_id,
	   child_depth_num,
	   child_id,
	   child_value_set_id,
	   single_depth_flag,
	   display_order_num,
	   weighting_pct
    bulk collect into
           t_row_id,
	   t_prnt_depth_num,
	   t_prnt_id,
	   t_prnt_value_set_id,
	   t_chld_depth_num,
	   t_chld_id,
	   t_chld_value_set_id,
	   t_sngle_depth_flag,
	   t_dspy_order_num,
	   t_wt_pct
  from     fem_user_dim6_hier
  where    hierarchy_obj_def_id = p_src_hier_version_id;

    FORALL rec in t_row_id.FIRST..t_row_id.LAST

    INSERT INTO fem_user_dim6_hier
	   ( hierarchy_obj_def_id,
	     parent_depth_num,
	     parent_id ,
	     parent_value_set_id,
	     child_depth_num,
	     child_id,
	     child_value_set_id ,
	     single_depth_flag,
	     display_order_num ,
	     weighting_pct,
	     creation_date ,
	     created_by ,
	     last_updated_by ,
	     last_update_date ,
	     last_update_login ,
	     object_version_number)
    VALUES (p_dest_hier_version_id,
            t_prnt_depth_num(rec),
            t_prnt_id(rec),
	    t_prnt_value_set_id(rec),
	    t_chld_depth_num(rec),
	    t_chld_id(rec),
	    t_chld_value_set_id(rec),
	    t_sngle_depth_flag(rec),
	    t_dspy_order_num(rec),
	    t_wt_pct(rec),
	    l_creation_date,
	    l_created_by,
	    l_last_updated_by,
	    l_last_update_date,
	    l_last_update_login,
	    1);
  elsif p_hier_table_name = 'FEM_USER_DIM7_HIER' then

    select rowid,
           parent_depth_num,
           parent_id,
	   parent_value_set_id,
	   child_depth_num,
	   child_id,
	   child_value_set_id,
	   single_depth_flag,
	   display_order_num,
	   weighting_pct
    bulk collect into
           t_row_id,
	   t_prnt_depth_num,
	   t_prnt_id,
	   t_prnt_value_set_id,
	   t_chld_depth_num,
	   t_chld_id,
	   t_chld_value_set_id,
	   t_sngle_depth_flag,
	   t_dspy_order_num,
	   t_wt_pct
  from     fem_user_dim7_hier
  where    hierarchy_obj_def_id = p_src_hier_version_id;

    FORALL rec in t_row_id.FIRST..t_row_id.LAST

    INSERT INTO fem_user_dim7_hier
	   ( hierarchy_obj_def_id,
	     parent_depth_num,
	     parent_id ,
	     parent_value_set_id,
	     child_depth_num,
	     child_id,
	     child_value_set_id ,
	     single_depth_flag,
	     display_order_num ,
	     weighting_pct,
	     creation_date ,
	     created_by ,
	     last_updated_by ,
	     last_update_date ,
	     last_update_login ,
	     object_version_number)
    VALUES (p_dest_hier_version_id,
            t_prnt_depth_num(rec),
            t_prnt_id(rec),
	    t_prnt_value_set_id(rec),
	    t_chld_depth_num(rec),
	    t_chld_id(rec),
	    t_chld_value_set_id(rec),
	    t_sngle_depth_flag(rec),
	    t_dspy_order_num(rec),
	    t_wt_pct(rec),
	    l_creation_date,
	    l_created_by,
	    l_last_updated_by,
	    l_last_update_date,
	    l_last_update_login,
	    1);
  elsif p_hier_table_name = 'FEM_USER_DIM8_HIER' then

    select rowid,
           parent_depth_num,
           parent_id,
	   parent_value_set_id,
	   child_depth_num,
	   child_id,
	   child_value_set_id,
	   single_depth_flag,
	   display_order_num,
	   weighting_pct
    bulk collect into
           t_row_id,
	   t_prnt_depth_num,
	   t_prnt_id,
	   t_prnt_value_set_id,
	   t_chld_depth_num,
	   t_chld_id,
	   t_chld_value_set_id,
	   t_sngle_depth_flag,
	   t_dspy_order_num,
	   t_wt_pct
  from     fem_user_dim8_hier
  where    hierarchy_obj_def_id = p_src_hier_version_id;

    FORALL rec in t_row_id.FIRST..t_row_id.LAST

    INSERT INTO fem_user_dim8_hier
	   ( hierarchy_obj_def_id,
	     parent_depth_num,
	     parent_id ,
	     parent_value_set_id,
	     child_depth_num,
	     child_id,
	     child_value_set_id ,
	     single_depth_flag,
	     display_order_num ,
	     weighting_pct,
	     creation_date ,
	     created_by ,
	     last_updated_by ,
	     last_update_date ,
	     last_update_login ,
	     object_version_number)
    VALUES (p_dest_hier_version_id,
            t_prnt_depth_num(rec),
            t_prnt_id(rec),
	    t_prnt_value_set_id(rec),
	    t_chld_depth_num(rec),
	    t_chld_id(rec),
	    t_chld_value_set_id(rec),
	    t_sngle_depth_flag(rec),
	    t_dspy_order_num(rec),
	    t_wt_pct(rec),
	    l_creation_date,
	    l_created_by,
	    l_last_updated_by,
	    l_last_update_date,
	    l_last_update_login,
	    1);
  elsif p_hier_table_name = 'FEM_USER_DIM9_HIER' then

    select rowid,
           parent_depth_num,
           parent_id,
	   parent_value_set_id,
	   child_depth_num,
	   child_id,
	   child_value_set_id,
	   single_depth_flag,
	   display_order_num,
	   weighting_pct
    bulk collect into
           t_row_id,
	   t_prnt_depth_num,
	   t_prnt_id,
	   t_prnt_value_set_id,
	   t_chld_depth_num,
	   t_chld_id,
	   t_chld_value_set_id,
	   t_sngle_depth_flag,
	   t_dspy_order_num,
	   t_wt_pct
  from     fem_user_dim9_hier
  where    hierarchy_obj_def_id = p_src_hier_version_id;

    FORALL rec in t_row_id.FIRST..t_row_id.LAST

    INSERT INTO fem_user_dim9_hier
	   ( hierarchy_obj_def_id,
	     parent_depth_num,
	     parent_id ,
	     parent_value_set_id,
	     child_depth_num,
	     child_id,
	     child_value_set_id ,
	     single_depth_flag,
	     display_order_num ,
	     weighting_pct,
	     creation_date ,
	     created_by ,
	     last_updated_by ,
	     last_update_date ,
	     last_update_login ,
	     object_version_number)
    VALUES (p_dest_hier_version_id,
            t_prnt_depth_num(rec),
            t_prnt_id(rec),
	    t_prnt_value_set_id(rec),
	    t_chld_depth_num(rec),
	    t_chld_id(rec),
	    t_chld_value_set_id(rec),
	    t_sngle_depth_flag(rec),
	    t_dspy_order_num(rec),
	    t_wt_pct(rec),
	    l_creation_date,
	    l_created_by,
	    l_last_updated_by,
	    l_last_update_date,
	    l_last_update_login,
	    1);

  elsif p_hier_table_name = 'FEM_USER_DIM10_HIER' then

    select rowid,
           parent_depth_num,
           parent_id,
	   parent_value_set_id,
	   child_depth_num,
	   child_id,
	   child_value_set_id,
	   single_depth_flag,
	   display_order_num,
	   weighting_pct
    bulk collect into
           t_row_id,
	   t_prnt_depth_num,
	   t_prnt_id,
	   t_prnt_value_set_id,
	   t_chld_depth_num,
	   t_chld_id,
	   t_chld_value_set_id,
	   t_sngle_depth_flag,
	   t_dspy_order_num,
	   t_wt_pct
  from     fem_user_dim10_hier
  where    hierarchy_obj_def_id = p_src_hier_version_id;

    FORALL rec in t_row_id.FIRST..t_row_id.LAST

    INSERT INTO fem_user_dim10_hier
	   ( hierarchy_obj_def_id,
	     parent_depth_num,
	     parent_id ,
	     parent_value_set_id,
	     child_depth_num,
	     child_id,
	     child_value_set_id ,
	     single_depth_flag,
	     display_order_num ,
	     weighting_pct,
	     creation_date ,
	     created_by ,
	     last_updated_by ,
	     last_update_date ,
	     last_update_login ,
	     object_version_number)
    VALUES (p_dest_hier_version_id,
            t_prnt_depth_num(rec),
            t_prnt_id(rec),
	    t_prnt_value_set_id(rec),
	    t_chld_depth_num(rec),
	    t_chld_id(rec),
	    t_chld_value_set_id(rec),
	    t_sngle_depth_flag(rec),
	    t_dspy_order_num(rec),
	    t_wt_pct(rec),
	    l_creation_date,
	    l_created_by,
	    l_last_updated_by,
	    l_last_update_date,
	    l_last_update_login,
	    1);


  elsif p_hier_table_name = 'FEM_CAL_PERIODS_HIER' then

    select rowid,
           parent_depth_num,
           parent_id,
	   child_depth_num,
	   child_id,
	   single_depth_flag,
	   display_order_num,
	   weighting_pct
    bulk collect into
           t_row_id,
	   t_prnt_depth_num,
	   t_prnt_id,
	   t_chld_depth_num,
	   t_chld_id,
	   t_sngle_depth_flag,
	   t_dspy_order_num,
	   t_wt_pct
  from     fem_cal_periods_hier
  where    hierarchy_obj_def_id = p_src_hier_version_id;

    FORALL rec in t_row_id.FIRST..t_row_id.LAST

    INSERT INTO fem_cal_periods_hier
	   ( hierarchy_obj_def_id,
	     parent_depth_num,
	     parent_id ,
	     child_depth_num,
	     child_id,
	     single_depth_flag,
	     display_order_num ,
	     weighting_pct,
	     creation_date ,
	     created_by ,
	     last_updated_by ,
	     last_update_date ,
	     last_update_login ,
	     object_version_number)
    VALUES (p_dest_hier_version_id,
            t_prnt_depth_num(rec),
            t_prnt_id(rec),
	    t_chld_depth_num(rec),
	    t_chld_id(rec),
	    t_sngle_depth_flag(rec),
	    t_dspy_order_num(rec),
	    t_wt_pct(rec),
	    l_creation_date,
	    l_created_by,
	    l_last_updated_by,
	    l_last_update_date,
	    l_last_update_login,
	    1);

  elsif p_hier_table_name = 'FEM_COST_OBJECTS_HIER' then

    SELECT effective_start_date
    INTO l_version_start_date
    FROM fem_object_definition_b
    WHERE object_definition_id = p_src_hier_version_id ;

    SELECT fcoh.rowid,
           fem_cost_objects_hier_s.NEXTVAL,
           effective_start_date,
	   parent_id,
	   child_id,
	   child_sequence_num,
	   display_order_num,
	   effective_end_date,
	   bom_reference,
	   dataset_code,
	   cal_period_id,
	   parent_qty,
	   child_qty,
	   yield_percentage
    BULK COLLECT INTO
           t_co_row_id,
           t_co_rel_id,
	   t_co_eff_start_date,
	   t_co_prnt_id,
	   t_co_chld_id,
	   t_co_chld_sequence_num,
	   t_co_disp_order_num,
	   t_co_eff_end_date,
	   t_co_bom_ref,
	   t_co_ds_code,
	   t_co_cal_per_id,
	   t_co_prnt_qty,
	   t_co_chld_qty,
	   t_co_yld_percentage
    FROM   fem_cost_objects_hier fcoh,
           fem_cost_obj_hier_qty fcohq
    WHERE  fcoh.relationship_id = fcohq.relationship_id
    AND    hierarchy_obj_id = p_src_hier_obj_id
    AND    l_version_start_date BETWEEN effective_start_date
                 AND effective_end_date;

    FORALL rec in t_co_row_id.FIRST..t_co_row_id.LAST

      INSERT INTO fem_cost_objects_hier
      (relationship_id,
       effective_start_date,
       hierarchy_obj_id,
       parent_id,
       child_id,
       child_sequence_num,
       display_order_num,
       effective_end_date,
       bom_reference,
       creation_date,
       created_by ,
       last_updated_by ,
       last_update_date ,
       last_update_login ,
       object_version_number)
       VALUES
       (t_co_rel_id(rec),
        t_co_eff_start_date(rec),
        p_dest_hier_obj_id,
	t_co_prnt_id(rec),
	t_co_chld_id(rec),
	t_co_chld_sequence_num(rec),
	t_co_disp_order_num(rec),
	t_co_eff_end_date(rec),
	t_co_bom_ref(rec),
        l_creation_date,
        l_created_by,
        l_last_updated_by,
        l_last_update_date,
        l_last_update_login,
        1);

    FORALL rec in t_co_row_id.FIRST..t_co_row_id.LAST

       INSERT INTO fem_cost_obj_hier_qty
       (relationship_id,
        dataset_code,
	cal_period_id,
	child_qty,
	parent_qty,
	yield_percentage,
        creation_date,
        created_by ,
        last_updated_by ,
        last_update_date ,
        last_update_login ,
        object_version_number)
	VALUES
	(t_co_rel_id(rec),
	 t_co_ds_code(rec),
	 t_co_cal_per_id(rec),
	 t_co_chld_qty(rec),
	 t_co_prnt_qty(rec),
	 t_co_yld_percentage(rec),
         l_creation_date,
         l_created_by,
         l_last_updated_by,
         l_last_update_date,
         l_last_update_login,
         1);

  elsif p_hier_table_name = 'FEM_ACTIVITIES_HIER' then

    SELECT rowid,
           parent_depth_num,
           parent_id,
	   child_depth_num,
	   child_id,
	   single_depth_flag,
	   display_order_num,
	   weighting_pct
    BULK COLLECT INTO
           t_row_id,
	   t_prnt_depth_num,
	   t_prnt_id,
	   t_chld_depth_num,
	   t_chld_id,
	   t_sngle_depth_flag,
	   t_dspy_order_num,
	   t_wt_pct
  FROM     fem_activities_hier
  WHERE    hierarchy_obj_def_id = p_src_hier_version_id;

    FORALL rec IN t_row_id.FIRST..t_row_id.LAST

    INSERT INTO fem_activities_hier
	   ( hierarchy_obj_def_id,
	     parent_depth_num,
	     parent_id ,
	     child_depth_num,
	     child_id,
	     single_depth_flag,
	     display_order_num ,
	     weighting_pct,
	     creation_date ,
	     created_by ,
	     last_updated_by ,
	     last_update_date ,
	     last_update_login ,
	     object_version_number)
    VALUES (p_dest_hier_version_id,
            t_prnt_depth_num(rec),
            t_prnt_id(rec),
	    t_chld_depth_num(rec),
	    t_chld_id(rec),
	    t_sngle_depth_flag(rec),
	    t_dspy_order_num(rec),
	    t_wt_pct(rec),
	    l_creation_date,
	    l_created_by,
	    l_last_updated_by,
	    l_last_update_date,
	    l_last_update_login,
	    1);

  end if;

  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			   p_data => p_msg_data );

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
  ROLLBACK TO Copy_Hier_Data_Pvt ;
  p_return_status := FND_API.G_RET_STS_ERROR;
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data => p_msg_data );

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  ROLLBACK TO Copy_Hier_Data_Pvt ;
  p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data => p_msg_data );

 WHEN OTHERS THEN
  ROLLBACK TO Copy_Hier_Data_Pvt ;
  p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data => p_msg_data );

END Copy_Hier_Data;

/*===========================================================================+
 |                     PROCEDURE Launch_Dup_Hier_Ver_Process                 |
 +===========================================================================*/

--
-- The concurrent program to duplicate a Hierarchy Version.
--
PROCEDURE Launch_Dup_Hier_Ver_Process(ERRBUFF	IN OUT	NOCOPY VARCHAR2,
				  RETCODE	IN OUT  NOCOPY VARCHAR2,
				  p_hier_table_name       IN VARCHAR2,
			          p_src_hier_obj_id 	  IN NUMBER,
				  p_src_hier_version_id IN NUMBER,
				  p_dest_version_name IN VARCHAR2,
				  p_dest_version_desc IN VARCHAR2,
				  p_dest_start_date IN VARCHAR2,
				  p_dest_end_date IN VARCHAR2)
is
l_msg_count NUMBER;
l_return_status VARCHAR2(1);
l_msg_data VARCHAR2(630);
l_dest_start_date DATE;
l_dest_end_date DATE;

begin

  l_dest_start_date := fnd_date.canonical_to_date(p_dest_start_date);
  l_dest_end_date := fnd_date.canonical_to_date(p_dest_end_date);

  duplicate_hier_version (p_api_version => 1.0,
                          p_return_status => l_return_status,
   		          p_msg_count => l_msg_count,
		          p_msg_data => l_msg_data,
		          p_hier_table_name => p_hier_table_name,
		          p_src_hier_obj_id => p_src_hier_obj_id,
		          p_src_hier_version_id => p_src_hier_version_id,
                          p_dest_hier_obj_id => p_src_hier_obj_id,
		          p_dest_version_name => p_dest_version_name,
		          p_dest_version_desc => p_dest_version_desc,
		          p_dest_start_date => l_dest_start_date,
		          p_dest_end_date => l_dest_end_date);

  if l_return_status in ('U', 'E') then
    RETCODE := 2;
    ERRBUFF := l_msg_data;
  else
    RETCODE := 0;
    ERRBUFF := l_msg_data;
  end if;

end Launch_Dup_Hier_Ver_Process;


/*===========================================================================+
 |                     PROCEDURE Duplicate_Hier_Version                      |
 +===========================================================================*/

--
-- The API to duplicate a Hierarchy Version.
--
PROCEDURE Duplicate_Hier_Version(
			p_api_version         	IN    		NUMBER ,
  			p_init_msg_list       	IN    		VARCHAR2 := FND_API.G_FALSE ,
  			p_commit              	IN    		VARCHAR2 := FND_API.G_FALSE ,
  			p_validation_level    	IN    		NUMBER  := FND_API.G_VALID_LEVEL_FULL ,
  			p_return_status       	OUT NOCOPY   	VARCHAR2 ,
  			p_msg_count           	OUT NOCOPY   	NUMBER  ,
  			p_msg_data            	OUT NOCOPY   	VARCHAR2 ,
                        p_hier_table_name       IN      	VARCHAR2,
			p_src_hier_obj_id 	IN 		NUMBER,
  			p_src_hier_version_id 	IN 		NUMBER,
  			p_dest_hier_obj_id 	IN 		NUMBER,
                        p_dest_version_name     IN 		VARCHAR2,
                        p_dest_version_desc     IN 		VARCHAR2,
                        p_dest_start_date       IN      	DATE,
                        p_dest_end_date         IN      	DATE) IS

l_creation_date     DATE  := sysdate;
l_created_by        NUMBER := fnd_global.user_id;
l_last_update_date  DATE  := sysdate;
l_last_Updated_by   NUMBER := fnd_global.user_id;
l_last_update_login NUMBER := fnd_global.login_id;

l_new_version_id    NUMBER;

l_object_definition_rec FEM_OBJECT_DEFINITION_VL%rowtype;
l_row_id            ROWID;

l_api_name          CONSTANT VARCHAR2(30)   := 'Duplicate_Hier_Version' ;
l_api_version       CONSTANT NUMBER         :=  1.0;

l_hier_versioning_type_code    VARCHAR2(30);

CURSOR l_object_definition_csr (p_version_id IN NUMBER)
IS
SELECT *
FROM   fem_object_definition_vl
WHERE  object_definition_id = p_version_id;

CURSOR l_dimension_detail_csr (c_hierarchy_id IN NUMBER)
IS
SELECT hier_versioning_type_code
FROM   fem_xdim_dimensions
WHERE  dimension_id = (SELECT dimension_id
	               FROM   fem_hierarchies
	               WHERE  hierarchy_obj_id = c_hierarchy_id);

begin

  SAVEPOINT Dup_Hier_Version_Pvt;

  if not FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
  then
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  end if;

  if FND_API.to_Boolean ( p_init_msg_list ) then
    FND_MSG_PUB.initialize ;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS ;

  -- Added for Bug:3737462
  -- The following call ensures that when duplicating a version there is no overlap in
  -- the date ranges of existing versions.

  FEM_BUSINESS_RULE_PVT.checkoverlapobjdefs(p_obj_id => p_dest_hier_obj_id,
                                            p_exclude_obj_def_id => null,
                                            p_effective_start_date => p_dest_start_date,
                                            p_effective_end_date => p_dest_end_date,
                                            x_return_status => p_return_status,
                                            x_msg_count => p_msg_count,
                                            x_msg_data => p_msg_data);

  if p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RAISE FND_API.G_EXC_ERROR ;
  end if;

  open l_object_definition_csr (p_version_id => p_src_hier_version_id);
  fetch l_object_definition_csr into l_object_definition_rec;
  close l_object_definition_csr;

  select fem_object_definition_id_seq.nextval
  into l_new_version_id
  from dual;

  FEM_OBJECT_DEFINITION_PKG.INSERT_ROW (X_ROWID => l_row_id,
     X_OBJECT_DEFINITION_ID => l_new_version_id,
     X_OBJECT_VERSION_NUMBER => 1,
     X_OBJECT_ID => p_dest_hier_obj_id,
     X_EFFECTIVE_START_DATE => p_dest_start_date,
     X_EFFECTIVE_END_DATE => p_dest_end_date,
     X_OBJECT_ORIGIN_CODE => l_object_definition_rec.object_origin_code,
     X_APPROVAL_STATUS_CODE => l_object_definition_rec.approval_status_code,
     X_OLD_APPROVED_COPY_FLAG => l_object_definition_rec.old_approved_copy_flag,
     X_OLD_APPROVED_COPY_OBJ_DEF_ID => l_object_definition_rec.old_approved_copy_obj_def_id,
     X_APPROVED_BY => l_object_definition_rec.approved_by,
     X_APPROVAL_DATE => l_object_definition_rec.approval_date,
     X_DISPLAY_NAME => p_dest_version_name,
     X_DESCRIPTION => p_dest_version_desc,
     X_CREATION_DATE => l_creation_date,
     X_CREATED_BY => l_created_by,
     X_LAST_UPDATE_DATE => l_last_update_date,
     X_LAST_UPDATED_BY => l_last_updated_by,
     X_LAST_UPDATE_LOGIN => l_last_update_login);

  INSERT INTO fem_hier_definitions
  (hierarchy_obj_def_id,
   flattened_rows_completion_code,
   created_by,
   creation_date,
   last_updated_by,
   last_update_date,
   last_update_login,
   object_version_number)
  VALUES
  (l_new_version_id,
   'COMPLETED',
   l_created_by,
   l_creation_date,
   l_last_updated_by,
   l_last_update_date,
   l_last_update_login,
   1);

  -- If the Hierarchy Versioning Type is RELATION then we do not copy the
  -- Hierarchy "Data" but only the "Header" info about the Hierarchy.
  -- NOTE: Currently, this is applicable only for Cost Object Hierarchies.

  OPEN l_dimension_detail_csr (c_hierarchy_id => p_src_hier_obj_id);
  FETCH l_dimension_detail_csr INTO l_hier_versioning_type_code;
  CLOSE l_dimension_detail_csr;

  IF l_hier_versioning_type_code <> 'RELATION' OR
     (p_src_hier_obj_id <> p_dest_hier_obj_id AND
              l_hier_versioning_type_code = 'RELATION')   THEN

    copy_hier_data(p_return_status => p_return_status,
                   p_msg_count => p_msg_count,
                   p_msg_data => p_msg_data,
    	  	   p_hier_table_name => p_hier_table_name,
  		   p_src_hier_obj_id => p_src_hier_obj_id,
  		   p_dest_hier_obj_id => p_dest_hier_obj_id,
  		   p_src_hier_version_id => p_src_hier_version_id,
  		   p_dest_hier_version_id => l_new_version_id);

  ELSIF (p_src_hier_obj_id = p_dest_hier_obj_id AND
           l_hier_versioning_type_code = 'RELATION')  THEN

    Dup_Cost_Object_Hier_Data(x_return_status => p_return_status,
	                      x_msg_count => p_msg_count,
	                      x_msg_data => p_msg_data,
                              p_hierarchy_id => p_src_hier_obj_id,
                              p_src_version_id => p_src_hier_version_id,
                              p_dest_version_id =>  l_new_version_id);

  END IF;


  if p_return_status <> 'S' then
    RAISE FND_API.G_EXC_ERROR;
  end if;


 FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			   p_data => p_msg_data );

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
  ROLLBACK TO Dup_Hier_Version_Pvt ;
  p_return_status := FND_API.G_RET_STS_ERROR;
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data => p_msg_data );

p_msg_data := sqlerrm;
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  ROLLBACK TO Dup_Hier_Version_Pvt ;
  p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data => p_msg_data );

p_msg_data := sqlerrm;
 WHEN OTHERS THEN
  ROLLBACK TO Dup_Hier_Version_Pvt ;
  p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data => p_msg_data );

p_msg_data := sqlerrm;
end duplicate_hier_version;


/*===========================================================================+
 |                     FUNCTION Can_Delete_Hier_Version                      |
 +===========================================================================*/

--
-- This function returns 'N' if the concurrent request is submitted for deleting
-- a Hierarchy Version.
--

FUNCTION can_delete_hier_version (p_hier_version_id IN NUMBER, p_folder_id IN NUMBER)
return VARCHAR2 AS

l_delete_status VARCHAR2(1) := 'Y';
l_hier_version_status VARCHAR2(30);
l_write_status VARCHAR2(1);
begin

  SELECT flattened_rows_completion_code
  INTO l_hier_version_status
  FROM fem_hier_definitions
  WHERE hierarchy_obj_def_id = p_hier_version_id;

  SELECT WRITE_FLAG
  INTO l_write_status
  FROM FEM_USER_FOLDERS
  WHERE FOLDER_ID = p_folder_id
  AND USER_ID = FND_GLOBAL.USER_ID ;

  if l_hier_version_status = 'PENDING_DELETION' then
    l_delete_status := 'N';
  end if;
  if l_write_status <> 'Y' then
    l_delete_status := 'N';
  end if;

  return l_delete_status;
exception
  when NO_DATA_FOUND then --Bug#4320272
  return 'N';

  when OTHERS then
  return l_delete_status;

end can_delete_hier_version;

-- WIP - The following is a clugy way of determining if a Hierarchy
-- is in PENDING_DELETION status. Should think of a better approach
-- like having a status column in FEM_HIERARCHIES.

/*===========================================================================+
 |                     FUNCTION Can_View_Ver_Detail                      |
 +===========================================================================*/

--
-- This function returns 'N' if the concurrent request is submitted for fetching details of
-- a Hierarchy Version.
--

FUNCTION can_view_ver_detail (p_hier_version_id IN NUMBER)
return VARCHAR2 AS

l_detail_status VARCHAR2(1) := 'Y';
l_hier_version_status VARCHAR2(30);

begin

  SELECT flattened_rows_completion_code
  INTO l_hier_version_status
  FROM fem_hier_definitions
  WHERE hierarchy_obj_def_id = p_hier_version_id;

  if l_hier_version_status = 'PENDING_DELETION' then
    l_detail_status := 'N';
    return l_detail_status ;
  else
    return l_detail_status ;
  end if;

exception
  when NO_DATA_FOUND then --Bug#4320272
  return 'N';

  when OTHERS then
  return l_detail_status;

end can_view_ver_detail;

-- WIP - The following is a clugy way of determining if a Hierarchy
-- is in PENDING_DELETION status. Should think of a better approach
-- like having a status column in FEM_HIERARCHIES.

/*===========================================================================+
 |                     FUNCTION Can_Duplicate_Hier_Version                      |
 +===========================================================================*/

--
-- This function returns 'N' if the concurrent request is submitted for duplicating
-- a Hierarchy Version.
--

FUNCTION can_duplicate_hier_version (p_hier_version_id IN NUMBER)
return VARCHAR2 AS

l_duplicate_status VARCHAR2(1) := 'Y';
l_hier_version_status VARCHAR2(30);

begin

  SELECT flattened_rows_completion_code
  INTO l_hier_version_status
  FROM fem_hier_definitions
  WHERE hierarchy_obj_def_id = p_hier_version_id;

  if l_hier_version_status = 'PENDING_DELETION' then
    l_duplicate_status := 'N';
    return l_duplicate_status ;
  else
    return l_duplicate_status ;
  end if;

exception
  when NO_DATA_FOUND then --Bug#4320272
  return 'N';

  when OTHERS then
  return l_duplicate_status;

end can_duplicate_hier_version;

-- WIP - The following is a clugy way of determining if a Hierarchy
-- is in PENDING_DELETION status. Should think of a better approach
-- like having a status column in FEM_HIERARCHIES.

/*===========================================================================+
 |                     FUNCTION is_hier_ver_deleted                         |
 +===========================================================================*/
--
-- This function returns 'N' if the concurrent request is submitted for deleting
-- a Hierarchy version.
--

FUNCTION is_hier_ver_deleted (p_hier_ver_id IN NUMBER)
return VARCHAR2 AS

l_delete_status VARCHAR2(1) := 'Y';
l_hier_version_status VARCHAR2(30);

begin

  SELECT flattened_rows_completion_code
  INTO l_hier_version_status
  FROM fem_hier_definitions
  WHERE hierarchy_obj_def_id = p_hier_ver_id;

  if l_hier_version_status = 'PENDING_DELETION' then
    l_delete_status := 'N';
    return l_delete_status ;
  else
    return l_delete_status ;
  end if;

exception
  when NO_DATA_FOUND then --Bug#4320272
  return 'N';

  when OTHERS then
  return l_delete_status;

end is_hier_ver_deleted;

/*===========================================================================+
 |                     FUNCTION is_hier_deleted                     |
 +===========================================================================*/

--
-- This function returns 'N' if the concurrent request is submitted for deleting
-- a Hierarchy.
--

FUNCTION is_hier_deleted (p_hierarchy_id IN NUMBER)
return VARCHAR2 AS

l_delete_status VARCHAR2(1) := 'Y';
l_hier_status VARCHAR2(30);

begin

  SELECT distinct flattened_rows_completion_code
  INTO l_hier_status
  FROM fem_hier_definitions hierDef,
       fem_object_definition_b objDef
  WHERE hierDef.hierarchy_obj_def_id = objDef.object_definition_id
  AND objDef.object_id = p_hierarchy_id;


  if l_hier_status = 'PENDING_DELETION' then
    l_delete_status := 'N';
  end if;

  return l_delete_status;
exception
  when NO_DATA_FOUND then --Bug#4320272
  return 'N';

  when OTHERS then
  return l_delete_status;

end is_hier_deleted;


/*===========================================================================+
 |                     FUNCTION Can_Delete_Hierarchy                     |
 +===========================================================================*/

--
-- This function returns 'N' if the concurrent request is submitted for deleting
-- a Hierarchy.
--


FUNCTION can_delete_hierarchy (p_hierarchy_id IN NUMBER, p_folder_id IN NUMBER)
return VARCHAR2 AS

l_delete_status VARCHAR2(1) := 'Y';
l_hier_status VARCHAR2(30);
l_write_status VARCHAR2(1);

begin

  SELECT distinct flattened_rows_completion_code
  INTO l_hier_status
  FROM fem_hier_definitions hierDef,
       fem_object_definition_b objDef
  WHERE hierDef.hierarchy_obj_def_id = objDef.object_definition_id
  AND objDef.object_id = p_hierarchy_id;

  SELECT WRITE_FLAG
  INTO l_write_status
  FROM FEM_USER_FOLDERS
  WHERE FOLDER_ID = p_folder_id
  AND USER_ID = FND_GLOBAL.USER_ID ;

  if l_hier_status = 'PENDING_DELETION' then
    l_delete_status := 'N';
  end if;
  if l_write_status <> 'Y' then
    l_delete_status := 'N';
  end if;

  return l_delete_status;
exception
  when NO_DATA_FOUND then --Bug#4320272
  return 'N';

  when OTHERS then
  return l_delete_status;
end can_delete_hierarchy;

/*===========================================================================+
 |                     PROCEDURE Launch_Del_Hier_Process                     |
 +===========================================================================*/

--
-- The concurrent program to Delete a Hierarchy.
--
PROCEDURE Launch_Del_Hier_Process(ERRBUFF	IN OUT	NOCOPY VARCHAR2,
				  RETCODE	IN OUT  NOCOPY VARCHAR2,
				  p_hier_table_name       IN VARCHAR2,
			          p_hier_obj_id 	  IN NUMBER)
is

l_msg_count NUMBER;
l_msg_data VARCHAR2(630);
l_return_status VARCHAR2(1);
l_current_hier_status VARCHAR2(30);


begin

  --Get the previous status of 'flattened_rows_completion_code'

  SAVEPOINT Launch_Delete_Hier;

  -- Bug:4042475
  -- When deleting the Hierarchy we set the status of all the versions
  -- of the Hierarchy to PENDING_DELETION

  UPDATE fem_hier_definitions
  SET flattened_rows_completion_code = 'PENDING_DELETION'
  WHERE hierarchy_obj_def_id in (select object_definition_id
                                 from fem_object_definition_vl
                                 where object_id = p_hier_obj_id);

  delete_hierarchy (p_api_version => 1.0,
                       p_return_status => l_return_status,
		       p_msg_count => l_msg_count,
		       p_msg_data => l_msg_data,
		       p_hier_table_name => p_hier_table_name,
		       p_hier_obj_id => p_hier_obj_id);

  if l_return_status in ('U', 'E') then

    -- If the Hierarchy delete fails for some reason,the status of
    -- "flattened_rows_completion_code" will be 'PENDING DELETION'
    -- for all its versions.

    ROLLBACK TO Launch_Delete_Hier;

    RETCODE := 2;
    ERRBUFF := l_msg_data;

    FND_FILE.put_line(FND_FILE.OUTPUT, l_msg_data);
    FND_FILE.put_line(FND_FILE.LOG, l_msg_data);

  else

    RETCODE := 0;
    ERRBUFF := l_msg_data;
  end if;

   --Bug:4042475

  --The follwoing update statement may not update any rows as
  --Delete is already done.

  UPDATE fem_hier_definitions
  SET flattened_rows_completion_code = 'COMPLETE'
  WHERE hierarchy_obj_def_id in (select object_definition_id
                                 from fem_object_definition_vl
                                 where object_id = p_hier_obj_id);

  commit;

end Launch_Del_Hier_Process;

/*===========================================================================+
 |                     PROCEDURE Delete_Hierarchy                            |
 +===========================================================================*/

--
-- The API to delete a Hierarchy.
--
PROCEDURE Delete_Hierarchy(
                        p_api_version           IN              NUMBER ,
                        p_init_msg_list         IN              VARCHAR2 := FND_API.G_FALSE ,
                        p_commit                IN              VARCHAR2 := FND_API.G_FALSE ,
                        p_validation_level      IN              NUMBER  := FND_API.G_VALID_LEVEL_FULL ,
                        p_return_status         OUT NOCOPY      VARCHAR2 ,
                        p_msg_count             OUT NOCOPY      NUMBER  ,
                        p_msg_data              OUT NOCOPY      VARCHAR2 ,
                        p_hier_table_name       IN              VARCHAR2,
                        p_hier_obj_id           IN              NUMBER )
is

cursor obj_def_csr (p_object_id IN NUMBER)
is
select object_definition_id
from   fem_object_definition_vl
where  object_id = p_object_id;

l_sql_stmt VARCHAR2(2000);
l_delete_allowed BOOLEAN;

l_api_name          CONSTANT VARCHAR2(30)   := 'Delete_Hierarchy' ;
l_api_version       CONSTANT NUMBER         :=  1.0;

begin

  SAVEPOINT Delete_Hierarachy_Pvt;

  if not FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
  then
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  end if;

  if FND_API.to_Boolean ( p_init_msg_list ) then
    FND_MSG_PUB.initialize ;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS ;


  delete_hier_version( p_api_version => p_api_version,
                       p_return_status => p_return_status,
  	               p_msg_count => p_msg_count,
  		       p_msg_data => p_msg_data,
  		       p_hier_table_name => p_hier_table_name,
  	  	       p_hier_obj_id => p_hier_obj_id,
                       p_hier_version_id => NULL);

  if p_return_status <> 'S' then
    RAISE FND_API.G_EXC_ERROR;
  end if;

  DELETE FROM fem_hier_dimension_grps
  WHERE hierarchy_obj_id = p_hier_obj_id;

  DELETE FROM fem_hier_value_sets
  WHERE hierarchy_obj_id = p_hier_obj_id;

  DELETE FROM fem_hierarchies
  WHERE hierarchy_obj_id = p_hier_obj_id;

  IF FND_API.To_Boolean ( p_commit ) THEN

   COMMIT WORK;

  END iF;

  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
  			     p_data => p_msg_data );

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN

  ROLLBACK TO Delete_Hierarachy_Pvt ;

  p_return_status := FND_API.G_RET_STS_ERROR;

  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data => p_msg_data );

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

  ROLLBACK TO Delete_Hierarachy_Pvt ;
  p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data => p_msg_data );

 WHEN OTHERS THEN

  ROLLBACK TO Delete_Hierarachy_Pvt ;
  p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data => p_msg_data );

end Delete_Hierarchy;

/*===========================================================================+
 |                     PROCEDURE Launch_Del_Hier_Ver_Process                 |
 +===========================================================================*/

--
-- The concurrent program to delete a Hierarchy Version.
--
PROCEDURE Launch_Del_Hier_Ver_Process(ERRBUFF       IN OUT  NOCOPY VARCHAR2,
				      RETCODE       IN OUT  NOCOPY VARCHAR2,
				      p_hier_table_name   IN VARCHAR2,
			              p_hier_obj_id 	  IN NUMBER,
			              p_hier_version_id   IN NUMBER)
is

l_msg_count NUMBER;
l_return_status VARCHAR2(1);
l_msg_data VARCHAR2(630);
l_current_hier_status VARCHAR2(30);

begin

  --Get the previous status of 'flattened_rows_completion_code'

  SELECT flattened_rows_completion_code
  INTO l_current_hier_status
  FROM fem_hier_definitions
  WHERE hierarchy_obj_def_id = p_hier_version_id;

  --Bug:4042475

  UPDATE fem_hier_definitions
  SET flattened_rows_completion_code = 'PENDING_DELETION'
  WHERE hierarchy_obj_def_id = p_hier_version_id;

  commit;

  delete_hier_version (p_api_version => 1.0,
                       p_return_status => l_return_status,
		       p_msg_count => l_msg_count,
		       p_msg_data => l_msg_data,
		       p_hier_table_name => p_hier_table_name,
		       p_hier_obj_id => p_hier_obj_id,
		       p_hier_version_id => p_hier_version_id);

  if l_return_status in ('U', 'E') then

    --Retain the initial status when there is any error.

    UPDATE fem_hier_definitions
    SET flattened_rows_completion_code = l_current_hier_status
    WHERE hierarchy_obj_def_id = p_hier_version_id;

    commit;

    RETCODE := 2;
    ERRBUFF := l_msg_data;

    FND_FILE.put_line(FND_FILE.OUTPUT, l_msg_data);
    FND_FILE.put_line(FND_FILE.LOG, l_msg_data);

  else

    RETCODE := 0;
    ERRBUFF := l_msg_data;

  end if;

  --Bug:4042475

  UPDATE fem_hier_definitions
  SET flattened_rows_completion_code = 'COMPLETE'
  WHERE hierarchy_obj_def_id = p_hier_version_id;

  commit;

end Launch_Del_Hier_Ver_Process;

/*===========================================================================+
 |                     PROCEDURE Delete_Hier_Version                         |
 +===========================================================================*/

--
-- The API to Delete Hierarchy Version.
--
PROCEDURE Delete_Hier_Version(
     p_api_version       IN              NUMBER ,
     p_init_msg_list     IN              VARCHAR2 := FND_API.G_FALSE ,
     p_commit            IN              VARCHAR2 := FND_API.G_FALSE ,
     p_validation_level  IN              NUMBER  := FND_API.G_VALID_LEVEL_FULL ,
     p_return_status     OUT NOCOPY      VARCHAR2 ,
     p_msg_count         OUT NOCOPY      NUMBER  ,
     p_msg_data          OUT NOCOPY      VARCHAR2 ,
     p_hier_table_name   IN              VARCHAR2,
     p_hier_obj_id       IN              NUMBER,
     p_hier_version_id   IN              NUMBER)
IS

CURSOR obj_def_csr (p_object_id IN NUMBER)
IS
SELECT object_definition_id
FROM   fem_object_definition_vl
WHERE  object_id = p_object_id;

CURSOR other_version_exists_csr (p_object_id IN NUMBER,
                          p_version_id IN NUMBER)
IS
SELECT 'Y' FROM dual
WHERE EXISTs
 (SELECT 1
  FROM fem_object_catalog_vl obj,
       fem_object_definition_vl ver
  WHERE obj.object_id = ver.object_id
  AND  ver.object_definition_id <> p_version_id
  AND  ver.object_id = p_object_id);

CURSOR l_cost_obj_detail_csr (c_hierarchy_id IN NUMBER,
                              c_version_id IN NUMBER)
IS
 SELECT  parent_id,
         child_id,
         child_sequence_num
 FROM    fem_cost_objects_hier
 WHERE   hierarchy_obj_id = c_hierarchy_id
 AND     (SELECT effective_start_date
          FROM   fem_object_definition_b
          WHERE  object_definition_id = c_version_id) BETWEEN
                   effective_start_date AND effective_end_date;

l_sql_stmt          VARCHAR2(2000);
l_dummy             VARCHAR2(1) := 'N';
l_delete_allowed    BOOLEAN;

l_api_name          CONSTANT VARCHAR2(30)   := 'Delete_Hier_Version' ;
l_api_version       CONSTANT NUMBER         :=  1.0;

begin

  SAVEPOINT Delete_Hier_Version_Pvt;

  if not FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  then
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  end if;

  if FND_API.to_Boolean ( p_init_msg_list ) then
    FND_MSG_PUB.initialize ;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS ;

  -- If p_hier_version_id = NULL then we want to delete all the versions
  -- for the given p_hier_obj_id.

  IF p_hier_version_id is NULL THEN

    FOR obj_def_rec IN obj_def_csr (p_object_id => p_hier_obj_id) LOOP

      DELETE FROM fem_hier_definitions
      WHERE hierarchy_obj_def_id = obj_def_rec.object_definition_id;

      IF p_hier_table_name = 'FEM_COST_OBJECTS_HIER' THEN

        DELETE FROM fem_cost_obj_hier_qty
        WHERE relationship_id IN (SELECT relationship_id
                                  FROM fem_cost_objects_hier
                                  WHERE hierarchy_obj_id = p_hier_obj_id);

        DELETE FROM fem_cost_objects_hier
        WHERE hierarchy_obj_id = p_hier_obj_id;

      ELSE

        l_sql_stmt := 'DELETE FROM '||p_hier_table_name||
            ' WHERE hierarchy_obj_def_id = '||obj_def_rec.object_definition_id;

        execute immediate l_sql_stmt;

      END IF;

      FEM_BUSINESS_RULE_PVT.DeleteObjectDefinition
                            (p_object_type_code => 'HIERARCHY',
                             p_obj_def_id => obj_def_rec.object_definition_id,
			     x_return_status => p_return_status,
			     x_msg_count => p_msg_count,
			     x_msg_data => p_msg_data);

      if p_return_status = FND_API.G_RET_STS_ERROR then

        raise FND_API.G_EXC_ERROR;

      elsif p_return_status = FND_API.G_RET_STS_UNEXP_ERROR then

        raise FND_API.G_EXC_UNEXPECTED_ERROR;

      end if;

    END LOOP;

  ELSE

  -- If p_hier_version_id is not NULL then we want to delete the specific
  -- Hier. Version.
    IF p_hier_table_name = 'FEM_COST_OBJECTS_HIER' THEN

      FOR  l_cost_obj_detail_rec IN
                          l_cost_obj_detail_csr(c_hierarchy_id => p_hier_obj_id,
                                              c_version_id => p_hier_version_id)
      LOOP

        remove_relation(p_api_version => 1.0,
            x_return_status => p_return_status,
            x_msg_count => p_msg_count,
            x_msg_data => p_msg_data,
	    p_hierarchy_id => p_hier_obj_id,
	    p_version_id => p_hier_version_id,
	    p_parent_id => l_cost_obj_detail_rec.parent_id,
	    p_child_id => l_cost_obj_detail_rec.child_id,
	    p_child_sequence_num => l_cost_obj_detail_rec.child_sequence_num,
	    p_hier_table_name => 'FEM_COST_OBJECTS_HIER',
	    p_remove_all_children_flag => 'N');

      END LOOP;

    ELSE

      l_sql_stmt := 'DELETE FROM '||p_hier_table_name||
        ' WHERE hierarchy_obj_def_id = '||p_hier_version_id;

      execute immediate l_sql_stmt;

    END IF; -- p_hier_table_name = 'FEM_COST_OBJECTS_HIER'

    DELETE FROM fem_hier_definitions
    WHERE hierarchy_obj_def_id = p_hier_version_id;

    FEM_BUSINESS_RULE_PVT.DeleteObjectDefinition
               (p_object_type_code => 'HIERARCHY',
                p_obj_def_id => p_hier_version_id,
  		x_return_status => p_return_status,
	        x_msg_count => p_msg_count,
	        x_msg_data => p_msg_data);

    if p_return_status = FND_API.G_RET_STS_ERROR then

      raise FND_API.G_EXC_ERROR;


    elsif p_return_status = FND_API.G_RET_STS_UNEXP_ERROR then

      raise FND_API.G_EXC_UNEXPECTED_ERROR;

    end if;

   END IF;

   IF FND_API.To_Boolean ( p_commit ) THEN

  COMMIT WORK;

 END iF;

 FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                           p_data => p_msg_data );

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN

  ROLLBACK TO Delete_Hier_Version_Pvt ;

  p_return_status := FND_API.G_RET_STS_ERROR;

  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data => p_msg_data );

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

  ROLLBACK TO Delete_Hier_Version_Pvt ;
  p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data => p_msg_data );

 WHEN OTHERS THEN

  ROLLBACK TO Delete_Hier_Version_Pvt ;
  p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data => p_msg_data );


end Delete_Hier_Version;

/*===========================================================================+
 |                     PROCEDURE Remove_Nodes                                |
 +===========================================================================*/

--
-- The API to remove a node along with its descendant.
--
PROCEDURE Remove_Nodes
(
  p_api_version                IN       NUMBER,
  p_init_msg_list              IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                     IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level           IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status              OUT  NOCOPY      VARCHAR2,
  x_msg_count                  OUT  NOCOPY      NUMBER,
  x_msg_data                   OUT  NOCOPY      VARCHAR2,
  --
  p_version_id                 IN       NUMBER,
  p_member_id                  IN       NUMBER,
  p_value_set_id               IN       NUMBER,
  p_hier_table_name            IN       VARCHAR2,
  p_value_set_required_flag    IN       VARCHAR2,
  p_flatten_rows_flag          IN       VARCHAR2,
  p_user_id                    IN       NUMBER
)
IS
  --
  l_api_name    CONSTANT VARCHAR2(30) := 'Remove_Nodes';
  l_api_version CONSTANT NUMBER := 1.0;
  --

  TYPE l_dhm_csr_type is REF CURSOR;
  l_hier_csr l_dhm_csr_type;
  l_root_csr l_dhm_csr_type;
  l_dspl_csr l_dhm_csr_type;

  -- Start Bug#4022561

  l_imm_parent_csr l_dhm_csr_type;
  l_imm_child_csr  l_dhm_csr_type;

  -- End Bug#4022561



  TYPE l_member_id_tbl_type is TABLE of
    FEM_PRODUCTS_HIER.CHILD_ID%TYPE index by BINARY_INTEGER;

  TYPE l_depth_num_tbl_type is TABLE of
    FEM_PRODUCTS_HIER.CHILD_DEPTH_NUM%TYPE index by BINARY_INTEGER;

  TYPE l_value_set_id_tbl_type is TABLE of
    FEM_PRODUCTS_HIER.CHILD_VALUE_SET_ID%TYPE index by BINARY_INTEGER;

  TYPE l_dis_ord_num_tbl_type is TABLE of
    FEM_PRODUCTS_HIER.DISPLAY_ORDER_NUM%TYPE index by BINARY_INTEGER;

  l_child_id_tbl            l_member_id_tbl_type;
  l_child_value_set_id_tbl  l_value_set_id_tbl_type;
  l_child_depth_num_tbl     l_depth_num_tbl_type;
  l_display_order_num_tbl   l_dis_ord_num_tbl_type;

  -- Start Bug#4022561

  l_imm_child_id_tbl  l_member_id_tbl_type;
  l_imm_child_value_set_id_tbl l_value_set_id_tbl_type;

  -- End Bug#4022561

  l_parent_id               NUMBER;
  l_parent_value_set_id     NUMBER := 0;
  l_parent_depth_num        NUMBER;
  l_child_id                NUMBER;
  l_child_value_set_id      NUMBER;
  l_child_depth_num         NUMBER := 1;
  l_display_order_num       NUMBER;
  l_row_count               NUMBER;
  l_req_id                  NUMBER;
  l_rowid                   VARCHAR2(20);
  l_select_stmt             VARCHAR2(1000);
  l_delete_stmt             VARCHAR2(1000);
  l_update_stmt             VARCHAR2(1000);
  l_return_status           VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);

BEGIN
  --
  SAVEPOINT Hier_Operation_Pvt ;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS ;
  --

  IF (p_value_set_required_flag IS NULL OR p_value_set_required_flag = 'N')
  THEN
    -- Get the whole hierarchy to be removed from the source down

    l_select_stmt := 'SELECT h.child_id, h.child_depth_num, ' ||
                     'h.display_order_num ' ||
                     'FROM ' || p_hier_table_name || ' h ' ||
                     'WHERE h.hierarchy_obj_def_id = :1 AND ' ||
                     'h.child_id = :2 AND h.single_depth_flag = ''Y'' ' ||
                     'UNION ' ||
                     'SELECT h.child_id, h.child_depth_num, ' ||
                     'h.display_order_num ' ||
                     'FROM ' || p_hier_table_name || ' h ' ||
                     'WHERE h.hierarchy_obj_def_id = :3 AND ' ||
                     'h.parent_id <> h.child_id ' ||
                     'START WITH h.parent_id = :4 AND ' ||
                     'h.hierarchy_obj_def_id = :5 AND ' ||
                     'h.single_depth_flag = ''Y'' AND ' ||
                     'h.parent_depth_num <> h.child_depth_num ' ||
                     'CONNECT BY PRIOR h.child_id = h.parent_id AND ' ||
                     'h.hierarchy_obj_def_id = :6 AND ' ||
                     'h.single_depth_flag = ''Y'' AND ' ||
                     'h.parent_depth_num <> h.child_depth_num ' ||
                     'ORDER BY child_depth_num DESC';

    OPEN l_hier_csr for l_select_stmt
      USING p_version_id, p_member_id, p_version_id, p_member_id,
            p_version_id, p_version_id;
      FETCH l_hier_csr BULK COLLECT
        into l_child_id_tbl, l_child_depth_num_tbl, l_display_order_num_tbl;

      l_row_count := l_hier_csr%ROWCOUNT;
    CLOSE l_hier_csr;

    IF (l_row_count < 1)
    THEN
      raise no_data_found;
    END IF;

    -- Find out whether the member is a root node or not,
    -- and find out the display order num.
    -- This is necessary since the query to find out the display number
    -- is different

    l_select_stmt := 'SELECT h.parent_id, h.parent_depth_num, ' ||
                     'h.child_depth_num, h.display_order_num ' ||
                     'FROM ' || p_hier_table_name || ' h ' ||
                     'WHERE h.hierarchy_obj_def_id = :1 AND ' ||
                     'h.child_id = :2 AND h.single_depth_flag = ''Y'' ';

    OPEN l_root_csr for l_select_stmt
      USING p_version_id, p_member_id;
      FETCH l_root_csr
        into l_parent_id, l_parent_depth_num, l_child_depth_num,
             l_display_order_num;
    CLOSE l_root_csr;

    l_delete_stmt := 'DELETE FROM ' || p_hier_table_name ||
                     ' WHERE hierarchy_obj_def_id = :1' ||
                     ' AND child_id = :2' ||
                     ' AND child_depth_num = :3' ||
                     ' AND single_depth_flag = ''Y''';

    l_update_stmt := 'Update ' || p_hier_table_name || ' ' ||
                     'SET display_order_num = display_order_num - 1, ' ||
                     'object_version_number = object_version_number + 1, ' ||
                     'last_updated_by = :1, ' ||
                     'last_update_date = :2' ||
                     'WHERE hierarchy_obj_def_id = :3 ' ||
                     'AND child_id = :4 ' ||
                     'AND child_depth_num = :5 ' ||
                     'AND single_depth_flag = ''Y''';


    IF (l_child_depth_num = 1)
    THEN

      -- root node
      -- Find out all the root nodes whoes display order number is larger
      -- than the focus member's display order num. Then decrease 1 from the
      -- current display order number.

      l_select_stmt := 'SELECT child_id ' ||
                       'FROM ' || p_hier_table_name || ' ' ||
                       'WHERE hierarchy_obj_def_id = :1 ' ||
                       'AND parent_id = child_id ' ||
                       'AND single_depth_flag = ''Y'' ' ||
                       'AND display_order_num > :2 ';

      OPEN l_dspl_csr for l_select_stmt
        USING p_version_id, l_display_order_num;
      LOOP
        FETCH l_dspl_csr INTO l_child_id;
        EXIT WHEN l_dspl_csr%NOTFOUND;

        -- update root level nodes display order num
        execute immediate l_update_stmt
          using p_user_id, sysdate, p_version_id, l_child_id, 1;
      END LOOP;
      CLOSE l_dspl_csr;

    ELSE

      -- not a root node
      -- Find out all the sibling nodes whoes display order number is larger
      -- than the focus member's display order num. Then decrease 1 from the
      -- current display order number.

      l_select_stmt := 'SELECT child_id, child_depth_num ' ||
                       'FROM ' || p_hier_table_name || ' ' ||
                       'WHERE hierarchy_obj_def_id = :1 ' ||
                       'AND parent_id = :2 ' ||
                       'AND single_depth_flag = ''Y'' ' ||
                       'AND NOT (parent_id = child_id ' ||
                       'AND parent_depth_num = child_depth_num) ' ||
                       'AND display_order_num > :3 ';

      OPEN l_dspl_csr for l_select_stmt
        USING p_version_id, l_parent_id, l_display_order_num;
      LOOP
        FETCH l_dspl_csr INTO l_child_id,l_child_depth_num;
        EXIT WHEN l_dspl_csr%NOTFOUND;

        execute immediate l_update_stmt
          using p_user_id, sysdate, p_version_id, l_child_id,
                l_child_depth_num;

      END LOOP;
      CLOSE l_dspl_csr;

      -- Start Bug#4022561

      IF(p_flatten_rows_flag = 'Y')
      THEN

        /*
         * Fetch all the immediate children
         * of the 'to be deleted' member
         */


        l_select_stmt := ' SELECT child_id ' ||
                      ' FROM ' || p_hier_table_name ||
                      ' WHERE hierarchy_obj_def_id = :1 ' ||
                      ' AND parent_id = :2 ' ||
                      ' AND single_depth_flag = ''Y''';

        OPEN l_imm_child_csr for l_select_stmt
        USING p_version_id, p_member_id;

          FETCH l_imm_child_csr BULK COLLECT
           into l_imm_child_id_tbl;

        CLOSE l_imm_child_csr;




        /* Also fetch the immediate parent info of the
         * 'to be deleted' member. This will be passed
         * to unflatten_focus_node_tree() where leaf node
         * entry for parent node will be inserted depending
         * upon whether the parent has any other children and
         * it is a root node or not.
         */



        l_select_stmt := ' SELECT parent_id ' ||
                       ' FROM ' || p_hier_table_name || ' h ' ||
                       ' WHERE h.hierarchy_obj_def_id = :1 ' ||
                       ' AND h.child_id = :2 ' ||
                       ' AND h.single_depth_flag = ''Y'' ';

        OPEN l_imm_parent_csr FOR l_select_stmt
          USING p_version_id, p_member_id;
        LOOP
          FETCH l_imm_parent_csr
            into l_parent_id;
          EXIT WHEN l_imm_parent_csr%NOTFOUND;
        END LOOP;
        CLOSE l_imm_parent_csr;

      END IF; -- End flatten_rows_flag

      -- End Bug#4022561

    END IF;

    -- Delete the whole hierarchy from the focus node down

    -- Begin bug fix# 3916681. Moved the check to validate for the
    -- last root to the HierVerDetailsAMImpl.checkChilsExists().

    FORALL i in l_child_id_tbl.FIRST .. l_child_id_tbl.LAST
      execute immediate l_delete_stmt
        using p_version_id, l_child_id_tbl(i), l_child_depth_num_tbl(i);

   -- End bug fix# 3916681.


  ELSE

    -- Get the whole hierarchy to be removed from the source down

    l_select_stmt := 'SELECT h.child_id, h.child_value_set_id, ' ||
                     'h.child_depth_num, h.display_order_num ' ||
                     'FROM ' || p_hier_table_name || ' h ' ||
                     'WHERE h.hierarchy_obj_def_id = :1 AND ' ||
                     'h.child_id = :2 AND h.child_value_set_id = :3 AND ' ||
                     'h.single_depth_flag = ''Y'' ' ||
                     'UNION ' ||
                     'SELECT h.child_id, h.child_value_set_id, ' ||
                     'h.child_depth_num, h.display_order_num ' ||
                     'FROM ' || p_hier_table_name || ' h ' ||
                     'WHERE h.hierarchy_obj_def_id = :4 AND ' ||
                     'NOT (h.parent_id = h.child_id AND ' ||
                     'h.parent_value_set_id = h.child_value_set_id) ' ||
                     'START WITH h.parent_id = :5 AND ' ||
                     'h.parent_value_set_id = :6 AND ' ||
                     'h.hierarchy_obj_def_id = :7 AND ' ||
                     'h.single_depth_flag = ''Y'' AND ' ||
                     'h.parent_depth_num <> h.child_depth_num ' ||
                     'CONNECT BY PRIOR h.child_id = h.parent_id AND ' ||
                     'PRIOR h.child_value_set_id = h.parent_value_set_id ' ||
                     'AND ' ||
                     'h.hierarchy_obj_def_id = :8 AND ' ||
                     'h.single_depth_flag = ''Y'' AND ' ||
                     'h.parent_depth_num <> h.child_depth_num ' ||
                     'ORDER BY child_depth_num DESC';

    OPEN l_hier_csr for l_select_stmt
      USING p_version_id, p_member_id, p_value_set_id,
            p_version_id, p_member_id, p_value_set_id,
            p_version_id, p_version_id;
      FETCH l_hier_csr BULK COLLECT
        into l_child_id_tbl, l_child_value_set_id_tbl, l_child_depth_num_tbl,
             l_display_order_num_tbl;

      l_row_count := l_hier_csr%ROWCOUNT;
    CLOSE l_hier_csr;

    IF (l_row_count < 1)
    THEN
      raise no_data_found;
    END IF;

    -- Find out whether the member is a root node or not,
    -- and find out the display order num
    -- This is necessary since the query to find out the display number
    -- is different

    l_select_stmt := 'SELECT h.parent_id, h.parent_value_set_id, ' ||
                     'h.parent_depth_num, h.child_depth_num, ' ||
                     'h.display_order_num ' ||
                     'FROM ' || p_hier_table_name || ' h ' ||
                     'WHERE h.hierarchy_obj_def_id = :1 AND ' ||
                     'h.child_id = :2 AND h.child_value_set_id = :3 AND ' ||
                     'h.single_depth_flag = ''Y'' ';

    OPEN l_root_csr for l_select_stmt
      USING p_version_id, p_member_id, p_value_set_id;
      FETCH l_root_csr
       into l_parent_id, l_parent_value_set_id, l_parent_depth_num,
            l_child_depth_num, l_display_order_num;
    CLOSE l_root_csr;

    l_delete_stmt := 'DELETE FROM ' || p_hier_table_name ||
                     ' WHERE hierarchy_obj_def_id = :1' ||
                     ' AND child_id = :2' ||
                     ' AND child_value_set_id = :3 ' ||
                     ' AND child_depth_num = :4' ||
                     ' AND single_depth_flag = ''Y''';

    l_update_stmt := 'Update ' || p_hier_table_name || ' ' ||
                     'SET display_order_num = display_order_num - 1, ' ||
                     'object_version_number = object_version_number + 1, ' ||
                     'last_updated_by = :1, ' ||
                     'last_update_date = :2' ||
                     'WHERE hierarchy_obj_def_id = :3 ' ||
                     'AND child_id = :4 ' ||
                     'AND child_value_set_id = :5 ' ||
                     'AND child_depth_num = :6 ' ||
                     'AND single_depth_flag = ''Y''';

    IF (l_child_depth_num = 1)
    THEN
      -- root node
      -- Find out all the root nodes whoes display order number is larger
      -- than the focus member's display order num. Then decrease 1 from the
      -- current display order number.

      l_select_stmt := 'SELECT child_id, child_value_set_id ' ||
                       'FROM ' || p_hier_table_name || ' ' ||
                       'WHERE hierarchy_obj_def_id = :1 ' ||
                       'AND parent_id = child_id ' ||
                       'AND parent_value_set_id = child_value_set_id ' ||
                       'AND single_depth_flag = ''Y'' ' ||
                       'AND display_order_num > :2 ';

      OPEN l_dspl_csr for l_select_stmt
        USING p_version_id, l_display_order_num;
      LOOP
        FETCH l_dspl_csr INTO l_child_id, l_child_value_set_id;
        EXIT WHEN l_dspl_csr%NOTFOUND;

        -- update root level nodes display order num
        execute immediate l_update_stmt
          using p_user_id, sysdate, p_version_id, l_child_id,
                l_child_value_set_id, 1;
      END LOOP;
      CLOSE l_dspl_csr;


    ELSE
      -- Not a root.
      -- Find out all the sibling nodes whoes display order number is larger
      -- than the focus member's display order num. Then decrease 1 from the
      -- current display order number.

      l_select_stmt := 'SELECT child_id, child_value_set_id, ' ||
                       'child_depth_num ' ||
                       'FROM ' || p_hier_table_name || ' ' ||
                       'WHERE hierarchy_obj_def_id = :1 ' ||
                       'AND parent_id = :2 ' ||
                       'AND parent_value_set_id = :3 ' ||
                       'AND single_depth_flag = ''Y'' ' ||
                       'AND NOT(parent_id = child_id ' ||
                       'AND parent_value_set_id = child_value_set_id ' ||
                       'AND parent_depth_num = child_depth_num) ' ||
                       'AND display_order_num > :4 ';

      OPEN l_dspl_csr for l_select_stmt
        USING p_version_id, l_parent_id,
              l_parent_value_set_id, l_display_order_num;
      LOOP
        FETCH l_dspl_csr
          INTO l_child_id, l_child_value_set_id, l_child_depth_num;
        EXIT WHEN l_dspl_csr%NOTFOUND;

        execute immediate l_update_stmt
          using p_user_id, sysdate, p_version_id, l_child_id,
                l_child_value_set_id, l_child_depth_num;

      END LOOP;
      CLOSE l_dspl_csr;

      -- Start Bug#4022561

      IF(p_flatten_rows_flag = 'Y')
      THEN

        /*
         * Fetch all the immediate children
         * of the 'to be deleted' member
         */


        l_select_stmt := ' SELECT child_id, child_value_set_id ' ||
                      ' FROM ' || p_hier_table_name ||
                      ' WHERE hierarchy_obj_def_id = :1 ' ||
                      ' AND parent_id = :2 ' ||
                      ' AND parent_value_set_id = :3 ' ||
                      ' AND single_depth_flag = ''Y''';

        OPEN l_imm_child_csr for l_select_stmt
        USING p_version_id, p_member_id,p_value_set_id;

          FETCH l_imm_child_csr BULK COLLECT
           into l_imm_child_id_tbl,l_imm_child_value_set_id_tbl;

        CLOSE l_imm_child_csr;


        /* Also fetch the immediate parent info of the
         * 'to be deleted' member. This will be passed
         * to unflatten_focus_node_tree() where leaf node
         * entry for parent node will be inserted depending
         * upon whether the parent has any other children and
         * it is a root node or not.
         */



        l_select_stmt := ' SELECT parent_id, parent_value_set_id ' ||
                       ' FROM ' || p_hier_table_name || ' h ' ||
                       ' WHERE h.hierarchy_obj_def_id = :1 ' ||
                       ' AND h.child_id = :2 ' ||
                       ' AND h.child_value_set_id = :3 ' ||
                       ' AND h.single_depth_flag = ''Y'' ';

        OPEN l_imm_parent_csr FOR l_select_stmt
          USING p_version_id, p_member_id, p_value_set_id;
        LOOP
          FETCH l_imm_parent_csr
            into l_parent_id,l_parent_value_set_id;
          EXIT WHEN l_imm_parent_csr%NOTFOUND;
        END LOOP;
        CLOSE l_imm_parent_csr;

      END IF; -- End flatten_rows_flag

      -- End Bug#4022561



    END IF;

    -- Delete the whole hierarchy from the focus node down

	-- Begin bug fix# 3916681. Moved the check to validate for the
        -- last root to the HierVerDetailsAMImpl.checkChilsExists().

      FORALL i in l_child_id_tbl.FIRST .. l_child_id_tbl.LAST
      execute immediate l_delete_stmt
        using p_version_id, l_child_id_tbl(i),
              l_child_value_set_id_tbl(i), l_child_depth_num_tbl(i);

   -- End bug fix# 3916681.

  END IF;

  IF FND_API.To_Boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;

  IF (p_flatten_rows_flag = 'Y')
  THEN
    l_req_id :=  FND_REQUEST.SUBMIT_REQUEST
                 (application   =>  'FEM',
                  program       =>  'DHMHVMFL',
                  description   =>  NULL,
                  start_time    =>  NULL,
                  sub_request   =>  FALSE,
                  argument1     =>  p_version_id,
                  argument2     =>  p_hier_table_name,
                  argument3     =>  p_member_id,
                  argument4     =>  p_value_set_id,
                  argument5     =>  l_parent_id,
                  argument6     =>  l_parent_value_set_id,
                  argument7     =>  NULL,
                  argument8     =>  NULL,
                  argument9     =>  'Remove');

    -- Start Bug#4022561

    /* Since we can't pass args of type pl/sql
     * collection to FND_REQUEST.SUBMIT_REQUEST,
     * submit as many concurrent requests as the
     * the no. of immediate children of the
     * 'to be deleted member'.
     */

    IF(l_imm_child_id_tbl.COUNT > 0 ) THEN
       FOR i in l_imm_child_id_tbl.FIRST .. l_imm_child_id_tbl.LAST
       LOOP
         l_req_id :=  FND_REQUEST.SUBMIT_REQUEST
                     (application   =>  'FEM',
                      program       =>  'DHMHVMFL',
                      description   =>  NULL,
                      start_time    =>  NULL,
                      sub_request   =>  FALSE,
                      argument1     =>  p_version_id,
                      argument2     =>  p_hier_table_name,
                      argument3     =>  p_member_id,
                      argument4     =>  p_value_set_id,
                      argument5     =>  NULL,
                      argument6     =>  NULL,
                      argument7     =>  l_imm_child_id_tbl(i),
                      argument8     =>  l_imm_child_value_set_id_tbl(i),
                      argument9     =>  'RemoveImmChildren');
      END LOOP;
   END IF;

   -- End Bug#4022561
  END IF;

EXCEPTION

  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Hier_Operation_Pvt ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
				p_data  => x_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Hier_Operation_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );
  --
  WHEN NO_DATA_FOUND THEN
   --Bug#4878100
   ROLLBACK TO Hier_Operation_Pvt ;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MESSAGE.SET_NAME('FEM', 'FEM_DHM_MEM_DELETED_ERR');
   FND_MSG_PUB.ADD;

  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Hier_Operation_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name);
    END if;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
				p_data  => x_msg_data );
   --

END Remove_Nodes;

/*===========================================================================+
 |                     PROCEDURE Move_Nodes                                  |
 +===========================================================================*/

--
-- The API to move a node along with its descendant to another node.
--
PROCEDURE Move_Nodes
(
  p_api_version                IN       NUMBER,
  p_init_msg_list              IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                     IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level           IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status              OUT  NOCOPY      VARCHAR2,
  x_msg_count                  OUT  NOCOPY      NUMBER,
  x_msg_data                   OUT  NOCOPY      VARCHAR2,
  --
  p_version_id                 IN       NUMBER,
  p_source_member_id           IN       NUMBER,
  p_source_value_set_id        IN       NUMBER,
  p_dest_member_id             IN       NUMBER,
  p_dest_value_set_id          IN       NUMBER,
  p_hier_table_name            IN       VARCHAR2,
  p_value_set_required_flag    IN       VARCHAR2,
  p_flatten_rows_flag          IN       VARCHAR2,
  p_user_id                    IN       NUMBER
)
IS
  --
  l_api_name    CONSTANT VARCHAR2(30) := 'Move_Nodes';
  l_api_version CONSTANT NUMBER := 1.0;
  --

  TYPE l_dhm_csr_type is REF CURSOR;
  l_src_node_csr l_dhm_csr_type;
  l_whl_hier_csr l_dhm_csr_type;
  l_dpth_csr     l_dhm_csr_type;
  l_leaf_csr     l_dhm_csr_type;

  TYPE l_member_id_tbl_type is TABLE of
    FEM_PRODUCTS_HIER.CHILD_ID%TYPE index by BINARY_INTEGER;

  TYPE l_depth_num_tbl_type is TABLE of
    FEM_PRODUCTS_HIER.CHILD_DEPTH_NUM%TYPE index by BINARY_INTEGER;

  TYPE l_value_set_id_tbl_type is TABLE of
    FEM_PRODUCTS_HIER.CHILD_VALUE_SET_ID%TYPE index by BINARY_INTEGER;

  TYPE l_dis_ord_num_tbl_type is TABLE of
    FEM_PRODUCTS_HIER.DISPLAY_ORDER_NUM%TYPE index by BINARY_INTEGER;

  TYPE l_weighting_pct_tbl_type is TABLE of
    FEM_PRODUCTS_HIER.WEIGHTING_PCT%TYPE index by BINARY_INTEGER;

  l_parent_id_tbl               l_member_id_tbl_type;
  l_parent_value_set_id_tbl     l_value_set_id_tbl_type;
  l_parent_depth_num_tbl        l_depth_num_tbl_type;
  l_child_id_tbl                l_member_id_tbl_type;
  l_child_value_set_id_tbl      l_value_set_id_tbl_type;
  l_child_depth_num_tbl         l_depth_num_tbl_type;
  l_display_order_num_tbl       l_dis_ord_num_tbl_type;
  l_weighting_pct_tbl           l_weighting_pct_tbl_type;
  l_parent_depth_num            NUMBER;
  l_child_depth_num             NUMBER := 0;
  l_display_order_num           NUMBER;
  l_depth_gap                   NUMBER;
  l_old_child_depth_num         NUMBER;
  l_weighting_pct               NUMBER(3,2);
  l_last_update_login           NUMBER:= FND_GLOBAL.Login_Id ;
  l_detailed_row_count          NUMBER := 0;
  l_leaf_row_count              NUMBER := 0;
  l_req_id                      NUMBER;
  l_rowid                       VARCHAR2(20);
  l_select_stmt                 VARCHAR2(1000);
  l_insert_stmt                 VARCHAR2(1000);
  l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(2000);
BEGIN
  --
  SAVEPOINT Hier_Operation_Pvt ;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS ;
  --

  -- Recorde the whole hierarchy from the source node down. Remove the
  -- hierarchy that was recorderd previously. Then add then back as
  -- children of the destination member.

  IF (p_value_set_required_flag IS NULL OR p_value_set_required_flag = 'N')
  THEN

    -- Find the child depth num and weighting pct that will be used
    -- to add the souce node to the destination node

    l_select_stmt := 'SELECT child_depth_num, weighting_pct ' ||
                     'FROM ' || p_hier_table_name || ' ' ||
                     'WHERE hierarchy_obj_def_id = :1 AND child_id = :2 ' ||
                     'AND single_depth_flag = ''Y''';

    OPEN l_src_node_csr for l_select_stmt
      USING p_version_id, p_source_member_id;
      FETCH l_src_node_csr
        into l_old_child_depth_num, l_weighting_pct;
    CLOSE l_src_node_csr;

    -- Find the whole hierarchy from the source node down (Do not include
    -- the dource node).

    l_select_stmt := 'SELECT parent_id, parent_depth_num, ' ||
                     'child_id, child_depth_num, ' ||
                     'display_order_num, weighting_pct ' ||
                     'FROM ' || p_hier_table_name || ' ' ||
                     'WHERE hierarchy_obj_def_id = :1 AND ' ||
                     'parent_id <> child_id ' ||
                     'START WITH parent_id = :2 AND ' ||
                     'hierarchy_obj_def_id = :3 AND ' ||
                     'single_depth_flag = ''Y'' AND ' ||
                     'parent_depth_num <> child_depth_num ' ||
                     'CONNECT BY PRIOR child_id = parent_id AND ' ||
                     'hierarchy_obj_def_id = :4 AND ' ||
                     'single_depth_flag = ''Y'' AND ' ||
                     'parent_depth_num <> child_depth_num ' ||
                     'ORDER BY child_depth_num DESC';

    OPEN l_whl_hier_csr for l_select_stmt
      USING p_version_id, p_source_member_id, p_version_id, p_version_id;
      FETCH l_whl_hier_csr BULK COLLECT
        into l_parent_id_tbl, l_parent_depth_num_tbl,
             l_child_id_tbl, l_child_depth_num_tbl,
             l_display_order_num_tbl, l_weighting_pct_tbl;

      l_detailed_row_count := l_whl_hier_csr%ROWCOUNT;
    CLOSE l_whl_hier_csr;

    -- Remove the whole hierarchy from the source node down (including source)

    Remove_Nodes(
      p_api_version                => 1.0,
      p_init_msg_list              => FND_API.G_FALSE,
      p_commit                     => FND_API.G_FALSE,
      p_validation_level           => p_validation_level,
      x_return_status              => l_return_status,
      x_msg_count                  => l_msg_count,
      x_msg_data                   => l_msg_data,
      p_version_id                 => p_version_id,
      p_member_id                  => p_source_member_id,
      p_value_set_id               => p_source_value_set_id,
      p_hier_table_name            => p_hier_table_name,
      p_value_set_required_flag    => p_value_set_required_flag,
      p_flatten_rows_flag          => p_flatten_rows_flag,
      p_user_id                    => p_user_id);

    IF l_return_status = FND_API.G_RET_STS_ERROR
    THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;

    -- Get the max display number of the children of the destination member.
    -- If the destination member is a leaf level node, no record will be
    -- returned. If this is the case, child_depth_num will be 0 (default value)

    l_select_stmt := 'SELECT parent_depth_num, child_depth_num, ' ||
                     'max(display_order_num) ' ||
                     'FROM ' || p_hier_table_name || ' ' ||
                     'WHERE hierarchy_obj_def_id = :1 ' ||
                     'AND parent_id = :2 ' ||
                     'AND single_depth_flag = ''Y'' ' ||
                     'GROUP BY child_depth_num, parent_depth_num ' ||
                     'ORDER BY child_depth_num DESC, parent_depth_num DESC';

    OPEN l_dpth_csr for l_select_stmt
      USING p_version_id, p_dest_member_id;
      Fetch l_dpth_csr
        into l_parent_depth_num, l_child_depth_num, l_display_order_num;
    CLOSE l_dpth_csr;

    IF (l_parent_depth_num = l_child_depth_num)
    THEN
      -- if root node
      l_child_depth_num := l_child_depth_num + 1;
      l_display_order_num := 1;

    ELSIF (l_child_depth_num = 0)
    THEN
      -- if leaf level node
      -- The current depth number is not yet known. Use the destination member
      -- id to find out what the current depth number is and then use it as the
      -- parent depth number of the future child to be

      l_select_stmt := 'SELECT child_depth_num ' ||
                       'FROM ' || p_hier_table_name || ' ' ||
                       'WHERE hierarchy_obj_def_id = :1 ' ||
                       'AND child_id = :2 ' ||
                       'AND NOT(parent_id = child_id ' ||
                       'AND parent_depth_num = child_depth_num) ' ||
                       'AND single_depth_flag = ''Y''';

      OPEN l_leaf_csr for l_select_stmt
        USING p_version_id, p_dest_member_id;
        Fetch l_leaf_csr
          into l_parent_depth_num;
      CLOSE l_leaf_csr;

      l_display_order_num := 1;
      l_child_depth_num := l_parent_depth_num + 1;
    ELSE
      -- intermediate node
      l_display_order_num := l_display_order_num + 1;
    END IF;

    l_depth_gap := l_child_depth_num - l_old_child_depth_num;


   /*Bug#4181214
    *Remove any flattenned entries between dest and source node
    *If flatten_focus_node_tree doesn't remove this entry before
    *the below insert stmt is executed, we get a unique key violation.
    */


    execute immediate 'DELETE FROM ' || p_hier_table_name ||
                        ' WHERE hierarchy_obj_def_id = ' || p_version_id ||
                        ' AND parent_id = ' || p_dest_member_id ||
                        ' AND child_id =  ' || p_source_member_id ||
                        ' AND single_depth_flag = ''N''';


    l_insert_stmt := 'INSERT INTO '||p_hier_table_name||
                     ' (       '||
                     'HIERARCHY_OBJ_DEF_ID, '||
                     'PARENT_DEPTH_NUM, '||
                     'PARENT_ID, '||
                     'CHILD_DEPTH_NUM, '||
                     'CHILD_ID, '||
                     'SINGLE_DEPTH_FLAG,'||
                     'DISPLAY_ORDER_NUM,'||
                     'WEIGHTING_PCT, ' ||
                     'CREATION_DATE,'||
                     'CREATED_BY, '||
                     'LAST_UPDATED_BY,'||
                     'LAST_UPDATE_DATE,'||
                     'LAST_UPDATE_LOGIN, '||
                     'OBJECT_VERSION_NUMBER) '||
                     ' VALUES ('||
                     ':1,'||
                     ':2,'||
                     ':3,'||
                     ':4,'||
                     ':5,'||
                     ':6,'||
                     ':7,'||
                     ':8,'||
                     ':9,'||
                     p_user_id||','||
                     p_user_id||','||
                     ':10,'||
                     l_last_update_login ||','||1||')';

    -- insert the top source node to the destionation node

    execute immediate l_insert_stmt
      using p_version_id,
            l_parent_depth_num, p_dest_member_id,
            l_child_depth_num, p_source_member_id,
            'Y', l_display_order_num, l_weighting_pct,
            sysdate, sysdate;

    -- When there are children in the source member, update the depth numbers
    -- by the gap between the destination and source member.

    IF (l_detailed_row_count > 0)
    THEN
      FOR i in l_parent_depth_num_tbl.FIRST .. l_parent_depth_num_tbl.LAST
      LOOP
        l_parent_depth_num_tbl(i) := l_parent_depth_num_tbl(i) + l_depth_gap;
        l_child_depth_num_tbl(i) := l_child_depth_num_tbl(i) + l_depth_gap;
      END LOOP;

      FORALL i in l_parent_id_tbl.FIRST .. l_parent_id_tbl.LAST
        execute immediate l_insert_stmt
          using p_version_id,
                l_parent_depth_num_tbl(i), l_parent_id_tbl(i),
                l_child_depth_num_tbl(i), l_child_id_tbl(i),
                'Y', l_display_order_num_tbl(i), l_weighting_pct_tbl(i),
                sysdate, sysdate;
    END IF;

  ELSE

    -- Find the child depth num and weighting pct that will be used
    -- to add the souce node to the destination node

    l_select_stmt := 'SELECT child_depth_num, weighting_pct ' ||
                     'FROM ' || p_hier_table_name || ' ' ||
                     'WHERE hierarchy_obj_def_id = :1 AND ' ||
                     'child_id = :2 AND child_value_set_id = :3 AND ' ||
                     'single_depth_flag = ''Y''';

    OPEN l_src_node_csr for l_select_stmt
      USING p_version_id, p_source_member_id, p_source_value_set_id;
      FETCH l_src_node_csr
        into l_old_child_depth_num, l_weighting_pct;
    CLOSE l_src_node_csr;

    -- Find the whole hierarchy from the source node down. (Do not include
    -- source node.)

    l_select_stmt := 'SELECT parent_id, parent_value_set_id, ' ||
                     'parent_depth_num, ' ||
                     'child_id, child_value_set_id, child_depth_num, ' ||
                     'display_order_num, weighting_pct ' ||
                     'FROM ' || p_hier_table_name || ' ' ||
                     'WHERE hierarchy_obj_def_id = :1 AND ' ||
                     'NOT (parent_id = child_id AND ' ||
                     'parent_value_set_id = child_value_set_id) ' ||
                     'START WITH parent_id = :2 AND ' ||
                     'parent_value_set_id = :3 AND ' ||
                     'hierarchy_obj_def_id = :4 AND ' ||
                     'single_depth_flag = ''Y'' AND ' ||
                     'parent_depth_num <> child_depth_num ' ||
                     'CONNECT BY PRIOR child_id = parent_id AND ' ||
                     'PRIOR child_value_set_id = parent_value_set_id AND ' ||
                     'hierarchy_obj_def_id = :5 AND ' ||
                     'single_depth_flag = ''Y'' AND ' ||
                     'parent_depth_num <> child_depth_num ' ||
                     'ORDER BY child_depth_num DESC';

    OPEN l_whl_hier_csr for l_select_stmt
      USING p_version_id, p_source_member_id, p_source_value_set_id,
            p_version_id, p_version_id;
      FETCH l_whl_hier_csr BULK COLLECT
        into l_parent_id_tbl, l_parent_value_set_id_tbl, l_parent_depth_num_tbl,
             l_child_id_tbl, l_child_value_set_id_tbl, l_child_depth_num_tbl,
             l_display_order_num_tbl, l_weighting_pct_tbl;

      l_detailed_row_count := l_whl_hier_csr%ROWCOUNT;
    CLOSE l_whl_hier_csr;

    -- Remove the whole hierarchy from the source node down (including source)

    Remove_Nodes(
      p_api_version                => 1.0,
      p_init_msg_list              => FND_API.G_FALSE,
      p_commit                     => FND_API.G_FALSE,
      p_validation_level           => p_validation_level,
      x_return_status              => l_return_status,
      x_msg_count                  => l_msg_count,
      x_msg_data                   => l_msg_data,
      p_version_id                 => p_version_id,
      p_member_id                  => p_source_member_id,
      p_value_set_id               => p_source_value_set_id,
      p_hier_table_name            => p_hier_table_name,
      p_value_set_required_flag    => p_value_set_required_flag,
      p_flatten_rows_flag          => p_flatten_rows_flag,
      p_user_id                    => p_user_id);

    IF l_return_status = FND_API.G_RET_STS_ERROR
    THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;

    -- Get the max display number of the children of the destination member.
    -- If the destination member is a leaf level node, no record will be
    -- returned. If this is the case, child_depth_num will be 0 (default value)

    l_select_stmt := 'SELECT parent_depth_num, child_depth_num, ' ||
                     'max(display_order_num) ' ||
                     'FROM ' || p_hier_table_name || ' ' ||
                     'WHERE hierarchy_obj_def_id = :1 ' ||
                     'AND parent_id = :2 ' ||
                     'AND parent_value_set_id = :3 ' ||
                     'AND single_depth_flag = ''Y'' ' ||
                     'GROUP BY child_depth_num, parent_depth_num ' ||
                     'ORDER BY child_depth_num DESC, parent_depth_num DESC';

    OPEN l_dpth_csr for l_select_stmt
      USING p_version_id, p_dest_member_id, p_dest_value_set_id;
      Fetch l_dpth_csr
        into l_parent_depth_num, l_child_depth_num, l_display_order_num;
    CLOSE l_dpth_csr;

    IF (l_parent_depth_num = l_child_depth_num)
    THEN
      -- if root node
      l_child_depth_num := l_child_depth_num + 1;
      l_display_order_num := 1;

    ELSIF (l_child_depth_num = 0)
    THEN
      -- if leaf level node
      -- The current depth number is not yet known. Use the destination member
      -- id to find out what the current depth number is and then use it as the
      -- parent depth number of the future child to be

      l_select_stmt := 'SELECT child_depth_num ' ||
                       'FROM ' || p_hier_table_name || ' ' ||
                       'WHERE hierarchy_obj_def_id = :1 ' ||
                       'AND child_id = :2 ' ||
                       'AND child_value_set_id = :3 ' ||
                       'AND NOT(parent_id = child_id ' ||
                       'AND parent_value_set_id = child_value_set_id ' ||
                       'AND parent_depth_num = child_depth_num) ' ||
                       'AND single_depth_flag = ''Y''';

      OPEN l_leaf_csr for l_select_stmt
        USING p_version_id, p_dest_member_id, p_dest_value_set_id;
        Fetch l_leaf_csr into l_parent_depth_num;
      CLOSE l_leaf_csr;

      l_display_order_num := 1;
      l_child_depth_num := l_parent_depth_num + 1;
    ELSE
      -- intermediate node
      l_display_order_num := l_display_order_num + 1;
    END IF;

    l_depth_gap := l_child_depth_num - l_old_child_depth_num;


   /*Bug#4181214
    *Remove any flattenned entries between dest and source node
    *If flatten_focus_node_tree doesn't remove this entry before
    *the below insert stmt is executed, we get a unique key violation.
    */


    execute immediate 'DELETE FROM ' || p_hier_table_name ||
                        ' WHERE hierarchy_obj_def_id = ' || p_version_id ||
                        ' AND parent_id = ' || p_dest_member_id ||
                        ' AND child_id =  ' || p_source_member_id ||
                        ' AND parent_value_set_id = ' || p_dest_value_set_id ||
                        ' AND child_value_set_id = ' || p_source_value_set_id  ||
                        ' AND single_depth_flag = ''N''';

    l_insert_stmt := 'INSERT INTO '||p_hier_table_name||
                     ' (       '||
                     'HIERARCHY_OBJ_DEF_ID, '||
                     'PARENT_DEPTH_NUM, '||
                     'PARENT_ID, '||
                     'PARENT_VALUE_SET_ID, '||
                     'CHILD_DEPTH_NUM, '||
                     'CHILD_ID, '||
                     'CHILD_VALUE_SET_ID, '||
                     'SINGLE_DEPTH_FLAG,'||
                     'DISPLAY_ORDER_NUM,'||
                     'WEIGHTING_PCT, ' ||
                     'CREATION_DATE,'||
                     'CREATED_BY, '||
                     'LAST_UPDATED_BY,'||
                     'LAST_UPDATE_DATE,'||
                     'LAST_UPDATE_LOGIN, '||
                     'OBJECT_VERSION_NUMBER) '||
                     ' VALUES ('||
                     ':1,'||
                     ':2,'||
                     ':3,'||
                     ':4,'||
                     ':5,'||
                     ':6,'||
                     ':7,'||
                     ':8,'||
                     ':9,'||
                     ':10,'||
                     ':11,'||
                     p_user_id||','||
                     p_user_id||','||
                     ':12,'||
                     l_last_update_login ||','||1||')';

    -- insert the top source node to the destionation node
    execute immediate l_insert_stmt
      using p_version_id,
            l_parent_depth_num, p_dest_member_id, p_dest_value_set_id,
            l_child_depth_num, p_source_member_id, p_source_value_set_id,
            'Y', l_display_order_num, l_weighting_pct,
            sysdate, sysdate;

    -- When there are children in the source member, update the depth numbers
    -- by the gap between the destination and source member.

    IF (l_detailed_row_count > 0)
    THEN
      FOR i in l_parent_depth_num_tbl.FIRST .. l_parent_depth_num_tbl.LAST
      LOOP
        l_parent_depth_num_tbl(i) := l_parent_depth_num_tbl(i) + l_depth_gap;
        l_child_depth_num_tbl(i) := l_child_depth_num_tbl(i) + l_depth_gap;
      END LOOP;

      FORALL i in l_parent_id_tbl.FIRST .. l_parent_id_tbl.LAST
        execute immediate l_insert_stmt
          using p_version_id,
                l_parent_depth_num_tbl(i),
                l_parent_id_tbl(i),
                l_parent_value_set_id_tbl(i),
                l_child_depth_num_tbl(i),
                l_child_id_tbl(i),
                l_child_value_set_id_tbl(i),
                'Y',
                l_display_order_num_tbl(i),
                l_weighting_pct_tbl(i),
                sysdate,
                sysdate;
    END IF;

  END IF;

  IF FND_API.To_Boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;

  IF (p_flatten_rows_flag = 'Y')
  THEN
    -- Bug#4022561

    /* Pass destination member as the param
     * instead of the source member. The hierarchy
     * needs to be flattened w.r.t to the dest member.
     */

    l_req_id :=  FND_REQUEST.SUBMIT_REQUEST
                 (application   =>  'FEM',
                  program       =>  'DHMHVMFL',
                  description   =>  NULL,
                  start_time    =>  NULL,
                  sub_request   =>  FALSE,
                  argument1     =>  p_version_id,
                  argument2     =>  p_hier_table_name,
                  argument3     =>  p_dest_member_id,
                  argument4     =>  p_dest_value_set_id,
                  argument5     =>  NULL,
                  argument6     =>  NULL,
                  argument7     =>  NULL,
                  argument8     =>  NULL,
                  argument9     =>  'Move');
  END IF;

EXCEPTION

  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Hier_Operation_Pvt ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
				p_data  => x_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Hier_Operation_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
				p_data  => x_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Hier_Operation_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name);
    END if;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
				p_data  => x_msg_data );
   --

END Move_Nodes;

/*===========================================================================+
 |                     PROCEDURE Add_Nodes                                   |
 +===========================================================================*/

--
-- The API to add a list of nodes under a focus node.
--
PROCEDURE Add_Nodes
(
  p_api_version                IN       NUMBER,
  p_init_msg_list              IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                     IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level           IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status              OUT  NOCOPY      VARCHAR2,
  x_msg_count                  OUT  NOCOPY      NUMBER,
  x_msg_data                   OUT  NOCOPY      VARCHAR2,
  --
  p_version_id                 IN       NUMBER,
  p_parent_member_id           IN       NUMBER,
  p_parent_value_set_id        IN       NUMBER,
  p_child_members              IN       FEM_DHM_MEMBER_TAB_TYP,
  p_user_id                    IN       NUMBER,
  p_hier_table_name            IN       VARCHAR2,
  p_value_set_required_flag    IN       VARCHAR2,
  p_flatten_rows_flag          IN       VARCHAR2
)
IS
  --
  l_api_name    CONSTANT VARCHAR2(30) := 'Add_Nodes';
  l_api_version CONSTANT NUMBER := 1.0;
  --

  TYPE l_dhm_csr_type is REF CURSOR;
  l_dpth_csr l_dhm_csr_type;
  l_leaf_csr l_dhm_csr_type;

  l_parent_depth_num    NUMBER;
  l_child_depth_num     NUMBER := 0;
  l_display_order_num   NUMBER;
  l_req_id              NUMBER;
  l_rowid               VARCHAR2(20);
  l_select_depth_stmt   VARCHAR2(1000);
  l_return_status       VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);
BEGIN
  --
  SAVEPOINT Hier_Operation_Pvt ;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS ;
  --

  -- Get the max display order number of the children of the destination
  -- member. Then add a node as a child of the destination member using the
  -- next max display order number.

  IF (p_value_set_required_flag IS NULL OR p_value_set_required_flag = 'N')
  THEN

    -- Get the max display number of the children of the destination member.
    -- If the destination member is a leaf level node, no record will be
    -- returned. If this is the case, child_depth_num will be 0 (default value)

    l_select_depth_stmt := 'SELECT parent_depth_num, child_depth_num, ' ||
                           'max(display_order_num) ' ||
                           'FROM ' || p_hier_table_name || ' ' ||
                           'WHERE hierarchy_obj_def_id = :1 ' ||
                           'AND parent_id = :2 ' ||
                           'AND single_depth_flag = ''Y'' ' ||
                           'GROUP BY child_depth_num, parent_depth_num ' ||
                           'ORDER BY child_depth_num DESC, ' ||
                           'parent_depth_num DESC';

    OPEN l_dpth_csr for l_select_depth_stmt
      USING p_version_id, p_parent_member_id;
      Fetch l_dpth_csr
        into l_parent_depth_num, l_child_depth_num, l_display_order_num;
    CLOSE l_dpth_csr;

    IF (l_parent_depth_num = l_child_depth_num)
    THEN
      -- if root node
      l_child_depth_num := l_child_depth_num + 1;
      l_display_order_num := 1;

    ELSIF (l_child_depth_num = 0)
    THEN

      -- if leaf level node
      -- The current depth number is not yet known. Use the destination member
      -- id to find out what the current depth number is and then use it as the
      -- parent depth number of the future child to be

      l_select_depth_stmt := 'SELECT child_depth_num ' ||
                             'FROM ' || p_hier_table_name || ' ' ||
                             'WHERE hierarchy_obj_def_id = :1 ' ||
                             'AND child_id = :2 ' ||
                             'AND NOT (parent_id = child_id ' ||
                             'AND parent_depth_num = child_depth_num) ' ||
                             'AND single_depth_flag = ''Y''';

      OPEN l_leaf_csr for l_select_depth_stmt
        USING p_version_id, p_parent_member_id;
        Fetch l_leaf_csr into l_parent_depth_num;
      CLOSE l_leaf_csr;

      l_display_order_num := 1;
      l_child_depth_num := l_parent_depth_num + 1;

    ELSE

      -- intermediate node
      l_display_order_num := l_display_order_num + 1;

    END IF;

  ELSE

    -- Get the max display number of the children of the destination member.
    -- If the destination member is a leaf level node, no record will be
    -- returned. If this is the case, child_depth_num will be 0 (default value)

    l_select_depth_stmt := 'SELECT parent_depth_num, child_depth_num, ' ||
                           'max(display_order_num) ' ||
                           'FROM ' || p_hier_table_name || ' ' ||
                           'WHERE hierarchy_obj_def_id = :1 ' ||
                           'AND parent_id = :2 ' ||
                           'AND parent_value_set_id = :3 ' ||
                           'AND single_depth_flag = ''Y'' ' ||
                           'GROUP BY child_depth_num, parent_depth_num ' ||
                           'ORDER BY child_depth_num DESC, ' ||
                           'parent_depth_num DESC';

    OPEN l_dpth_csr for l_select_depth_stmt
      USING p_version_id, p_parent_member_id, p_parent_value_set_id;
      Fetch l_dpth_csr
        into l_parent_depth_num, l_child_depth_num, l_display_order_num;
    CLOSE l_dpth_csr;

    IF (l_parent_depth_num = l_child_depth_num)
    THEN
      -- if root node
      l_child_depth_num := l_child_depth_num + 1;
      l_display_order_num := 1;

    ELSIF (l_child_depth_num = 0)
    THEN

      -- if leaf level node
      -- The current depth number is not yet known. Use the destination member
      -- id to find out what the current depth number is and then use it as the
      -- parent depth number of the future child to be

      l_select_depth_stmt := 'SELECT child_depth_num ' ||
                             'FROM ' || p_hier_table_name || ' ' ||
                             'WHERE hierarchy_obj_def_id = :1 ' ||
                             'AND child_id = :2 ' ||
                             'AND child_value_set_id = :3 ' ||
                             'AND NOT(parent_id = child_id ' ||
                             'AND parent_value_set_id = child_value_set_id ' ||
                             'AND parent_depth_num = child_depth_num) ' ||
                             'AND single_depth_flag = ''Y''';

      OPEN l_leaf_csr for l_select_depth_stmt
        USING p_version_id, p_parent_member_id, p_parent_value_set_id;
        Fetch l_leaf_csr
          into l_parent_depth_num;
      CLOSE l_leaf_csr;

      l_display_order_num := 1;
      l_child_depth_num := l_parent_depth_num + 1;

    ELSE

      -- intermediate node
      l_display_order_num := l_display_order_num + 1;

    END IF;
  END IF;

  -- Add a node as a child of the destination member using the next display
  -- order number.

  FOR i IN 1..p_child_members.COUNT
  LOOP
    insert_root_node(p_api_version         => 1.0,
                     p_init_msg_list       => FND_API.G_FALSE,
                     p_commit              => FND_API.G_FALSE,
                     p_validation_level    => p_validation_level,
                     p_return_status       => l_return_status,
                     p_msg_count           => l_msg_count,
                     p_msg_data            => l_msg_data,
                     p_rowid               => l_rowid,
                     p_vs_required_flag    => p_value_set_required_flag,
                     p_hier_table_name     => p_hier_table_name,
                     p_hier_obj_def_id     => p_version_id,
                     p_parent_depth_num    => l_parent_depth_num,
                     p_parent_id           => p_parent_member_id,
                     p_parent_value_set_id => p_parent_value_set_id,
                     p_child_depth_num     => l_child_depth_num,
                     p_child_id            => p_child_members(i).member_id,
                     p_child_value_set_id  => p_child_members(i).value_set_id,
                     p_single_depth_flag   => 'Y',
                     p_display_order_num   => l_display_order_num,
                     p_weighting_pct       => NULL);

    l_display_order_num := l_display_order_num + 1;

    IF l_return_status = FND_API.G_RET_STS_ERROR
    THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
  END LOOP;

  IF FND_API.To_Boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;

  IF (p_flatten_rows_flag = 'Y')
  THEN
    l_req_id :=  FND_REQUEST.SUBMIT_REQUEST
                 (application   =>  'FEM',
                  program       =>  'DHMHVMFL',
                  description   =>  NULL,
                  start_time    =>  NULL,
                  sub_request   =>  FALSE,
                  argument1     =>  p_version_id,
                  argument2     =>  p_hier_table_name,
                  argument3     =>  p_parent_member_id,
                  argument4     =>  p_parent_value_set_id,
                  argument5     =>  NULL,
                  argument6     =>  NULL,
                  argument7     =>  NULL,
                  argument8     =>  NULL,
                  argument9     =>  'Add');
  END IF;

EXCEPTION

  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Hier_Operation_Pvt ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
				p_data  => x_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Hier_Operation_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
				p_data  => x_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Hier_Operation_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name);
    END if;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
				p_data  => x_msg_data );
   --

END Add_Nodes;

/*===========================================================================+
 |                     PROCEDURE Add_Rooot_nodes                             |
 +===========================================================================*/

--
-- The API to add a list of nodes to the root.
--
PROCEDURE Add_Root_Nodes
(
  p_api_version                IN       NUMBER,
  p_init_msg_list              IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                     IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level           IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status              OUT  NOCOPY      VARCHAR2,
  x_msg_count                  OUT  NOCOPY      NUMBER,
  x_msg_data                   OUT  NOCOPY      VARCHAR2,
  --
  p_version_id                 IN       NUMBER,
  p_child_members              IN       FEM_DHM_MEMBER_TAB_TYP,
  p_user_id                    IN       NUMBER,
  p_hier_table_name            IN       VARCHAR2,
  p_value_set_required_flag    IN       VARCHAR2
)
IS
  --
  l_api_name    CONSTANT VARCHAR2(30) := 'Add_Root_Nodes';
  l_api_version CONSTANT NUMBER := 1.0;
  --

  TYPE l_dhm_csr_type is REF CURSOR;
  l_dhm_csr l_dhm_csr_type;

  l_display_order_num  NUMBER := 0;
  l_rowid              VARCHAR2(20);
  l_select_stmt        VARCHAR2(1000);
  l_return_status      VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(2000);
BEGIN
  --
  SAVEPOINT Hier_Operation_Pvt ;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS ;
  --

  -- Find out the max display order number.

  IF (p_value_set_required_flag IS NULL OR p_value_set_required_flag = 'N')
  THEN

    l_select_stmt := 'SELECT max(display_order_num) ' ||
                     'FROM ' || p_hier_table_name || ' ' ||
                     'WHERE hierarchy_obj_def_id = :1 ' ||
                     'AND parent_id = child_id ' ||
                     'AND parent_depth_num = child_depth_num ' ||
                     'AND child_depth_num = 1 ' ||
                     'AND single_depth_flag = ''Y''';

    OPEN l_dhm_csr for l_select_stmt
      USING p_version_id;
      Fetch l_dhm_csr
        into l_display_order_num;
    CLOSE l_dhm_csr;

  ELSE

    l_select_stmt := 'SELECT max(display_order_num) ' ||
                     'FROM ' || p_hier_table_name || ' ' ||
                     'WHERE hierarchy_obj_def_id = :1 ' ||
                     'AND parent_id = child_id ' ||
                     'AND parent_value_set_id = child_value_set_id ' ||
                     'AND parent_depth_num = child_depth_num ' ||
                     'AND child_depth_num = 1 ' ||
                     'AND single_depth_flag = ''Y''';

    OPEN l_dhm_csr for l_select_stmt
      USING p_version_id;
      Fetch l_dhm_csr
        into l_display_order_num;
    CLOSE l_dhm_csr;

  END IF;

  -- Determine the next display order number. Then add a root node to the
  -- hierarchy by the next display order number.

  l_display_order_num := l_display_order_num + 1;

  FOR i IN 1..p_child_members.COUNT
  LOOP
    insert_root_node(
      p_api_version         => 1.0,
      p_init_msg_list       => FND_API.G_FALSE,
      p_commit              => FND_API.G_FALSE,
      p_validation_level    => p_validation_level,
      p_return_status       => l_return_status,
      p_msg_count           => l_msg_count,
      p_msg_data            => l_msg_data,
      p_rowid               => l_rowid,
      p_vs_required_flag    => p_value_set_required_flag,
      p_hier_table_name     => p_hier_table_name,
      p_hier_obj_def_id     => p_version_id,
      p_parent_depth_num    => 1,
      p_parent_id           => p_child_members(i).member_id,
      p_parent_value_set_id => p_child_members(i).value_set_id,
      p_child_depth_num     => 1,
      p_child_id            => p_child_members(i).member_id,
      p_child_value_set_id  => p_child_members(i).value_set_id,
      p_single_depth_flag   => 'Y',
      p_display_order_num   => l_display_order_num,
      p_weighting_pct       => NULL);

    l_display_order_num := l_display_order_num + 1;

    IF l_return_status = FND_API.G_RET_STS_ERROR
    THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
  END LOOP;

  IF FND_API.To_Boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;

EXCEPTION

  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Hier_Operation_Pvt ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
				p_data  => x_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Hier_Operation_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
				p_data  => x_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Hier_Operation_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name);
    END if;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
				p_data  => x_msg_data );
   --

END Add_Root_Nodes;

--
-- Update Hierarchy Display Sequence numbbers
--
procedure  Hier_Member_Sequence_Update (
  p_api_version               IN       NUMBER ,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY      VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY      NUMBER   ,
  p_msg_data                  OUT  NOCOPY      VARCHAR2 ,
  --
  p_new_display_order_num     IN    NUMBER ,
  p_hierarchy_table_name      IN    VARCHAR2 ,
  p_hierarchy_obj_def_id      IN    NUMBER ,
  p_parent_id                 IN    NUMBER ,
  p_parent_value_set_id       IN    NUMBER ,
  p_child_id                  IN    NUMBER ,
  p_child_value_set_id        IN    NUMBER
) IS

begin
 --
 SAVEPOINT Update_Row_Pvt ;

 IF FND_API.to_Boolean ( p_init_msg_list ) THEN
  FND_MSG_PUB.initialize ;
 END IF;
 --
 p_return_status := FND_API.G_RET_STS_SUCCESS ;

 if (p_parent_value_set_id <= 0 AND p_child_value_set_id <= 0) then
   execute immediate 'update ' || p_hierarchy_table_name ||
                   ' SET DISPLAY_ORDER_NUM = ' || p_new_display_order_num ||
                   ' where hierarchy_obj_def_id = ' || p_hierarchy_obj_def_id || ' AND ' ||
                   ' parent_id = ' || p_parent_id || ' AND ' ||
                   ' child_id = ' || p_child_id;
 else
   execute immediate 'update ' || p_hierarchy_table_name ||
                   ' SET DISPLAY_ORDER_NUM = ' || p_new_display_order_num ||
                   ' where hierarchy_obj_def_id = ' || p_hierarchy_obj_def_id || ' AND ' ||
                   ' parent_id = ' || p_parent_id || ' AND ' ||
                   ' parent_value_set_id = ' || p_parent_value_set_id || ' AND ' ||
                   ' child_value_set_id = ' || p_child_value_set_id || ' AND ' ||
                   ' child_id = ' || p_child_id;
 END IF;

 IF (sql%notfound) then
   RAISE no_data_found;
 END IF;

 IF FND_API.To_Boolean ( p_commit ) THEN
  COMMIT WORK;
 END iF;
 --
 FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			   p_data => p_msg_data );
 --
EXCEPTION
 --
 WHEN FND_API.G_EXC_ERROR THEN
  --
  ROLLBACK TO Update_Row_Pvt ;
  p_return_status := FND_API.G_RET_STS_ERROR;
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data => p_msg_data );

 --
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  --
  ROLLBACK TO Update_Row_Pvt ;
--  DBMS_OUTPUT.PUT_LINE('error: '|| SQLCODE);
  p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data => p_msg_data );
 --

 WHEN OTHERS THEN
  --
--  DBMS_OUTPUT.PUT_LINE('error: '|| SQLCODE);
  ROLLBACK TO Update_Row_Pvt ;
  p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  --

  --
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data => p_msg_data );

END Hier_Member_Sequence_Update;


/*===========================================================================+
 |                     FUNCTION Is_Lowest_Group                              |
 +===========================================================================*/

--
-- This API find out whether the dimension group is the lowest level of the
-- Hierarchy. If it is, return 'Y'. If the dimension group and hierarchy
-- combination cannot be found in the fem_hier_dimension_grps table, it assumes
-- that the hierarchy does not use group then return 'N'.

FUNCTION Is_Lowest_Group
(
  p_hierarchy_obj_id           IN        NUMBER,
  p_dimension_group_id         IN        NUMBER
)
RETURN VARCHAR2 AS

  l_is_lowest_group            VARCHAR2(1) := 'N';

BEGIN

  FOR l_rec_seq
  IN
  (
    SELECT a.relative_dimension_group_seq
    FROM   fem_hier_dimension_grps a
    WHERE  a.hierarchy_obj_id = p_hierarchy_obj_id AND
           a.dimension_group_id = p_dimension_group_id AND
           NOT EXISTS
           (
             SELECT b.dimension_group_id,
                    b.hierarchy_obj_id,
                    b.relative_dimension_group_seq
             FROM   fem_hier_dimension_grps b
             WHERE  b.hierarchy_obj_id = a.hierarchy_obj_id AND
                    b.relative_dimension_group_seq >
                      a.relative_dimension_group_seq
           )
  )
  LOOP
    l_is_lowest_group := 'Y';
  END LOOP;

  RETURN l_is_lowest_group;
END Is_Lowest_Group;


/*===========================================================================+
 |                     FUNCTION Is_Highest_Group                              |
 +===========================================================================*/

--
-- This API find out whether the dimension group is the highest level of the
-- Hierarchy. If it is, return 'Y'. If the dimension group and hierarchy
-- combination cannot be found in the fem_hier_dimension_grps table, it assumes
-- that the hierarchy does not use group then return 'N'.

FUNCTION Is_Highest_Group
(
  p_hierarchy_obj_id           IN        NUMBER,
  p_dimension_group_id         IN        NUMBER
)
RETURN VARCHAR2 AS

  l_is_highest_group            VARCHAR2(1) := 'N';

BEGIN

  FOR l_rec_seq
  IN
  (
    SELECT a.relative_dimension_group_seq
    FROM   fem_hier_dimension_grps a
    WHERE  a.hierarchy_obj_id = p_hierarchy_obj_id AND
           a.dimension_group_id = p_dimension_group_id AND
           NOT EXISTS
           (
             SELECT b.dimension_group_id,
                    b.hierarchy_obj_id,
                    b.relative_dimension_group_seq
             FROM   fem_hier_dimension_grps b
             WHERE  b.hierarchy_obj_id = a.hierarchy_obj_id AND
                    b.relative_dimension_group_seq <
                      a.relative_dimension_group_seq
           )
  )
  LOOP
    l_is_highest_group := 'Y';
  END LOOP;

  RETURN l_is_highest_group;
END Is_Highest_Group;

/*===========================================================================+
 |                     FUNCTION Is_Reorder_Allowed                           |
 +===========================================================================*/

--
-- This API find out whether the reorder should be allowed for a node.
-- For regular user: It checks whether there is a child node.
--                   If there is a child node, returns 'Y'; otherwise 'N'.
-- For Secure user: It checks whether there is a shared member node.
--                  If there is a shared member node, returns 'Y';
--                  otherwise 'N'.
-- Do not pass value for p_member_id or pass 0 when check root nodes.

FUNCTION Is_Reorder_Allowed
(
  p_dimension_id               IN        NUMBER,
  p_hierarchy_obj_id           IN        NUMBER,
  p_hierarchy_obj_def_id       IN        NUMBER,
  p_member_id                  IN        NUMBER := 0,
  p_value_set_id               IN        NUMBER,
  p_user_mode                  IN        VARCHAR2,
  p_comp_dim_flag              IN        VARCHAR2 := 'N'
)
RETURN VARCHAR2 AS

  TYPE l_dhm_csr_type          is REF CURSOR                       ;
  l_dhm_csr                    l_dhm_csr_type                      ;

  l_stmt                       VARCHAR2(2000)                      ;
  l_member_col                 VARCHAR2(30)                        ;
  l_member_vl_object_name      VARCHAR2(30)                        ;
  l_hierarchy_table_name       VARCHAR2(30)                        ;
  l_per_hierarchy_table_name   VARCHAR2(30)                        ;
  l_value_set_required_flag    VARCHAR2(1)                         ;
  l_is_reorder_allowed         VARCHAR2(1)    := 'N'               ;
  l_user_id                    NUMBER         := FND_GLOBAL.User_Id;

BEGIN

  -- Find out the metadata information.

  SELECT MEMBER_COL,
         MEMBER_VL_OBJECT_NAME,
         HIERARCHY_TABLE_NAME,
         PERSONAL_HIERARCHY_TABLE_NAME,
         VALUE_SET_REQUIRED_FLAG
    INTO l_member_col,
         l_member_vl_object_name,
         l_hierarchy_table_name,
         l_per_hierarchy_table_name,
         l_value_set_required_flag
  FROM   FEM_XDIM_DIMENSIONS_VL
  WHERE  DIMENSION_ID = p_dimension_id;

 IF p_comp_dim_flag = 'N' then -- BOR project - added the check condition
  -- Construct select statement
  IF (p_member_id is null OR p_member_id = 0)
  THEN
    -- construct select statement for root node
    IF (l_value_set_required_flag = 'Y')
    THEN
      l_stmt := 'SELECT ''Y'' FROM DUAL WHERE EXISTS ( ' ||
                'SELECT H.CHILD_ID ';

      -- Will need to use different hierarchy table for secure user
      IF (p_user_mode IS NOT NULL AND p_user_mode = 'SECURED')
      THEN
        l_stmt := l_stmt ||
                  'FROM ' || l_per_hierarchy_table_name || ' H, ';
      ELSE
        l_stmt := l_stmt ||
                  'FROM ' || l_hierarchy_table_name || ' H, ';
      END IF;

      l_stmt := l_stmt ||
                '     ' || l_member_vl_object_name || ' DIM ' ||
                'WHERE  H.HIERARCHY_OBJ_DEF_ID = :1 AND ' ||
                '       H.PARENT_ID = H.CHILD_ID AND ' ||
                '       H.PARENT_VALUE_SET_ID = H.CHILD_VALUE_SET_ID AND ' ||
                '       H.PARENT_DEPTH_NUM = H.CHILD_DEPTH_NUM AND ' ||
                '       H.PARENT_DEPTH_NUM = 1 AND ' ||
                '       H.SINGLE_DEPTH_FLAG = ''Y'' AND ' ||
                '       EXISTS ' ||
                '       ( ' ||
                '         SELECT HVS.VALUE_SET_ID ' ||
                '         FROM   FEM_HIER_VALUE_SETS HVS ' ||
                '         WHERE PARENT_VALUE_SET_ID = HVS.VALUE_SET_ID AND ' ||
                '         HVS.HIERARCHY_OBJ_ID = :2 ' ||
                '       ) AND ' ||
                '       H.CHILD_ID = DIM.' || l_member_col || ' AND ' ||
                '       H.CHILD_VALUE_SET_ID = DIM.VALUE_SET_ID ';

      -- Need to consider personal member if it is EPB user
      IF (p_user_mode IS NOT NULL AND p_user_mode = 'SECURED')
      THEN
        l_stmt := l_stmt || 'AND ' ||
                  '       DIM.CREATED_BY = :3 )';

        OPEN l_dhm_csr for l_stmt
          USING p_hierarchy_obj_def_id,
                p_hierarchy_obj_id,
                l_user_id;
          Fetch l_dhm_csr
            into l_is_reorder_allowed;
        CLOSE l_dhm_csr;

      ELSE
        l_stmt := l_stmt || ')';

        OPEN l_dhm_csr for l_stmt
          USING p_hierarchy_obj_def_id,
                p_hierarchy_obj_id;
          Fetch l_dhm_csr
            into l_is_reorder_allowed;
        CLOSE l_dhm_csr;

      END IF;

    ELSE
      -- construct select statement for dimension not using value set

      l_stmt := 'SELECT ''Y'' FROM DUAL WHERE EXISTS ( ' ||
                'SELECT H.CHILD_ID ';

      -- Will need to use different hierarchy table for secure user
      IF (p_user_mode IS NOT NULL AND p_user_mode = 'SECURED')
      THEN
        l_stmt := l_stmt ||
                  'FROM ' || l_per_hierarchy_table_name || ' H, ';
      ELSE
        l_stmt := l_stmt ||

                  'FROM ' || l_hierarchy_table_name || ' H, ';
      END IF;

      l_stmt := l_stmt ||
                '     ' || l_member_vl_object_name || ' DIM ' ||
                'WHERE  H.HIERARCHY_OBJ_DEF_ID = :1 AND ' ||
                '       H.PARENT_ID = H.CHILD_ID AND ' ||
                '       H.PARENT_DEPTH_NUM = H.CHILD_DEPTH_NUM AND ' ||
                '       H.PARENT_DEPTH_NUM = 1 AND ' ||
                '       H.SINGLE_DEPTH_FLAG = ''Y'' AND ' ||
                '       H.CHILD_ID = DIM.' || l_member_col || ' ';


      -- Need to consider personal member if it is EPB user
      IF (p_user_mode IS NOT NULL AND p_user_mode = 'SECURED')
      THEN
        l_stmt := l_stmt || 'AND ' ||
                  '       DIM.CREATED_BY = :2 )';

        OPEN l_dhm_csr for l_stmt
          USING p_hierarchy_obj_def_id,
                l_user_id;
          Fetch l_dhm_csr
            into l_is_reorder_allowed;
        CLOSE l_dhm_csr;

      ELSE
        l_stmt := l_stmt || ')';

        OPEN l_dhm_csr for l_stmt
          USING p_hierarchy_obj_def_id;
          Fetch l_dhm_csr
            into l_is_reorder_allowed;
          CLOSE l_dhm_csr;
      END IF;

    END IF;

  ELSE
    -- construct select statement for intermediate node
    IF (l_value_set_required_flag = 'Y')
    THEN
      l_stmt := 'SELECT ''Y'' FROM DUAL WHERE EXISTS ( ' ||
                'SELECT H.CHILD_ID ';

      -- Will need to use different hierarchy table for secure user
      IF (p_user_mode IS NOT NULL AND p_user_mode = 'SECURED')
      THEN
        l_stmt := l_stmt ||
                  'FROM ' || l_per_hierarchy_table_name || ' H, ';
      ELSE
        l_stmt := l_stmt ||
                  'FROM ' || l_hierarchy_table_name || ' H, ';
      END IF;

      l_stmt := l_stmt ||
                '     ' || l_member_vl_object_name || ' DIM ' ||
                'WHERE  H.HIERARCHY_OBJ_DEF_ID = :1 AND ' ||
                '       H.PARENT_ID = :2 AND ' ||
                '       H.PARENT_VALUE_SET_ID = :3 AND ' ||
                '       H.SINGLE_DEPTH_FLAG = ''Y'' AND '||
                '       NOT (H.PARENT_ID = H.CHILD_ID AND ' ||
                '       H.PARENT_VALUE_SET_ID = H.CHILD_VALUE_SET_ID) AND ' ||
                '       H.CHILD_ID = DIM.' || l_member_col || ' AND ' ||
                '       H.CHILD_VALUE_SET_ID = DIM.VALUE_SET_ID ';

      -- Need to consider personal member if it is EPB user
      IF (p_user_mode IS NOT NULL AND p_user_mode = 'SECURED')
      THEN
        l_stmt := l_stmt || 'AND ' ||
                  '       DIM.CREATED_BY = :4 )';

        OPEN l_dhm_csr for l_stmt
          USING p_hierarchy_obj_def_id,
                p_member_id,
                p_value_set_id,
                l_user_id;
          Fetch l_dhm_csr
            into l_is_reorder_allowed;
        CLOSE l_dhm_csr;

      ELSE
        l_stmt := l_stmt || ')';

        OPEN l_dhm_csr for l_stmt
          USING p_hierarchy_obj_def_id,
                p_member_id,
                p_value_set_id;
          Fetch l_dhm_csr
            into l_is_reorder_allowed;
        CLOSE l_dhm_csr;

      END IF;

    ELSE
      -- construct select statement for dimension not using value set

      l_stmt := 'SELECT ''Y'' FROM DUAL WHERE EXISTS ( ' ||
                'SELECT H.CHILD_ID ';

      -- Will need to use different hierarchy table for secure user
      IF (p_user_mode IS NOT NULL AND p_user_mode = 'SECURED')
      THEN
        l_stmt := l_stmt ||
                  'FROM ' || l_per_hierarchy_table_name || ' H, ';
      ELSE
        l_stmt := l_stmt ||
                  'FROM ' || l_hierarchy_table_name || ' H, ';
      END IF;

      l_stmt := l_stmt ||
                '     ' || l_member_vl_object_name || ' DIM ' ||
                'WHERE  H.HIERARCHY_OBJ_DEF_ID = :1 AND ' ||
                '       H.PARENT_ID = :2 AND ' ||
                '       H.SINGLE_DEPTH_FLAG = ''Y'' AND ' ||
                '       H.PARENT_ID <> H.CHILD_ID AND ' ||
                '       H.CHILD_ID = DIM.' || l_member_col || ' ';

      -- Need to consider personal member if it is EPB user
      IF (p_user_mode IS NOT NULL AND p_user_mode = 'SECURED')
      THEN
        l_stmt := l_stmt || 'AND ' ||
                  '       DIM.CREATED_BY = :3 )';

        OPEN l_dhm_csr for l_stmt
          USING p_hierarchy_obj_def_id,
                p_member_id,
                l_user_id;
          Fetch l_dhm_csr
            into l_is_reorder_allowed;
        CLOSE l_dhm_csr;

      ELSE
        l_stmt := l_stmt || ')';

        OPEN l_dhm_csr for l_stmt
          USING p_hierarchy_obj_def_id,
                p_member_id;
          Fetch l_dhm_csr
            into l_is_reorder_allowed;
          CLOSE l_dhm_csr;
      END IF;

    END IF;
  END IF;

 ELSE -- BOR project - if p_comp_dim_flag = 'Y' then

  -- Construct select statement
    -- construct select statement for root node

      l_stmt := 'SELECT ''Y'' FROM DUAL WHERE EXISTS ( ' ||
                'SELECT CO.COST_OBJECT_ID ';

      -- Will need to use different hierarchy table for secure user

        l_stmt := l_stmt ||
                  'FROM ' || l_member_vl_object_name || ' CO ';

      l_stmt := l_stmt ||
                'WHERE  CO.COST_OBJECT_ID =  :1 AND ' ||
                '       EXISTS (SELECT 1 ' ||
                '       FROM '||l_hierarchy_table_name||' H2, '||
				'       FEM_OBJECT_DEFINITION_VL OD, '||
				'       FEM_HIER_VALUE_SETS VS '||
				'       WHERE (H2.PARENT_ID = CO.COST_OBJECT_ID) AND '||
				'       H2.HIERARCHY_OBJ_ID = OD.OBJECT_ID AND '||
				'       OD.EFFECTIVE_START_DATE BETWEEN H2.EFFECTIVE_START_DATE AND H2.EFFECTIVE_END_DATE '||
				'       AND OD.OBJECT_DEFINITION_ID = :2 AND '||
				'       H2.HIERARCHY_OBJ_ID = :3 AND '||
				'       CO.LOCAL_VS_COMBO_ID =  VS.VALUE_SET_ID AND '||
                '       H2.HIERARCHY_OBJ_ID = VS.HIERARCHY_OBJ_ID))';

        OPEN l_dhm_csr for l_stmt
          USING p_member_id,
		        p_hierarchy_obj_def_id,
                p_hierarchy_obj_id;
          Fetch l_dhm_csr
            into l_is_reorder_allowed;
        CLOSE l_dhm_csr;

  END IF;
  RETURN l_is_reorder_allowed;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN l_is_reorder_allowed;

END Is_Reorder_Allowed;

/*===========================================================================+
 |                     PROCEDURE Circular_Ref_Check                          |
 +===========================================================================*/
-- API to check for circular references when adding a new Relation to an
-- existing Hierarchy.

PROCEDURE Circular_Ref_Check
(p_hierarchy_id        IN NUMBER,
 p_parent_id           IN NUMBER,
 p_child_id            IN NUMBER,
 x_return_status              OUT  NOCOPY      VARCHAR2,
 x_msg_count                  OUT  NOCOPY      NUMBER,
 x_msg_data                   OUT  NOCOPY      VARCHAR2)
IS

 TYPE number_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
 th_parent_id                number_type;

 l_sql_err_code              NUMBER;
 l_parent_display_code       VARCHAR2(2000);
 l_child_display_code        VARCHAR2(2000);

 CURSOR l_circ_ref_check_csr(c_hierarchy_id IN NUMBER,
                             c_child_id     IN NUMBER)
 IS
 SELECT parent_id
 FROM (SELECT parent_id,
              child_id
       FROM   fem_cost_objects_hier
       WHERE hierarchy_obj_id = c_hierarchy_id)
 START WITH child_id = c_child_id
 CONNECT BY PRIOR parent_id = child_id;

/*
 SELECT parent_id
 FROM   fem_cost_objects_hier
 WHERE  hierarchy_obj_id = c_hierarchy_id
 START WITH child_id = c_child_id
 CONNECT BY PRIOR parent_id = child_id ;
*/

 CURSOR l_cost_object_csr(c_cost_object_id IN NUMBER)
 IS
 SELECT cost_object_display_code
 FROM   fem_cost_objects
 WHERE  cost_object_id = c_cost_object_id;

BEGIN

  OPEN l_circ_ref_check_csr(c_hierarchy_id => p_hierarchy_id,
                            c_child_id     => p_child_id);
  FETCH l_circ_ref_check_csr BULK COLLECT INTO th_parent_id;
  CLOSE l_circ_ref_check_csr;

EXCEPTION
  WHEN OTHERS THEN
    l_sql_err_code := SQLCODE;

    IF l_sql_err_code = -1436 THEN

      CLOSE l_circ_ref_check_csr;

      OPEN l_cost_object_csr(c_cost_object_id => p_parent_id);
      FETCH l_cost_object_csr INTO l_parent_display_code;
      CLOSE l_cost_object_csr;

      OPEN l_cost_object_csr(c_cost_object_id => p_child_id);
      FETCH l_cost_object_csr INTO l_child_display_code;
      CLOSE l_cost_object_csr;

      -- Message: "Addition of CHILD_DISPLAY_CODE to PARENT_DISPLAY_CODE
      -- causes a circular reference in the Hierarchy."

      FND_MESSAGE.SET_NAME('FEM','FEM_DHM_CIRC_REF_ERROR');
      FND_MESSAGE.SET_TOKEN('PARENT_DISPLAY_CODE',
                            l_parent_display_code);
      FND_MESSAGE.SET_TOKEN('CHILD_DISPLAY_CODE',
                            l_child_display_code);

      FND_MSG_PUB.Add;

    END IF;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Circular_Ref_Check;

/*===========================================================================+
 |                     PROCEDURE Add_Relation                                |
 +===========================================================================*/

--
-- The API to add a single Relation to a Hierarchy.
-- NOTE: This is currently used for Cost Object Hierarchies.
--
PROCEDURE Add_Relation(
  p_api_version                IN       NUMBER,
  p_init_msg_list              IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                     IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level           IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status              OUT  NOCOPY      VARCHAR2,
  x_msg_count                  OUT  NOCOPY      NUMBER,
  x_msg_data                   OUT  NOCOPY      VARCHAR2,
  --
  p_hierarchy_id               IN       NUMBER,
  p_version_id                 IN       NUMBER,
  p_parent_id                  IN       NUMBER,
  p_parent_qty                 IN       NUMBER,
  p_child_id                   IN       NUMBER,
  p_child_qty                  IN       NUMBER,
  p_yield_pct                  IN       NUMBER,
  p_bom_reference              IN       VARCHAR2,
  p_display_order_num          IN       NUMBER,
  p_hier_table_name            IN       VARCHAR2
)
IS
  l_api_name    CONSTANT VARCHAR2(30) := 'Add_Relation';
  l_api_version CONSTANT NUMBER := 1.0;

  l_new_relationship_id  NUMBER;
  l_effective_start_date DATE;
  l_effective_end_date   DATE;

  l_is_first_version     NUMBER := 0;
  l_is_prior_version     VARCHAR2(1) := 'N';

  l_child_sequence_num   NUMBER;

  l_cal_period_id        NUMBER := FND_PROFILE.Value_Specific('FEM_PERIOD',FND_GLOBAL.USER_ID);
  --l_dataset_code         NUMBER := -999;

  --Bug#4252397: Fetch dataset code from profile.
  l_dataset_code         NUMBER := FND_PROFILE.Value_Specific('FEM_DATASET',FND_GLOBAL.USER_ID);

  CURSOR l_hier_ver_details_csr (c_version_id IN NUMBER)
  IS
  SELECT effective_start_date,
         effective_end_date
  FROM   fem_object_definition_b
  WHERE  object_definition_id = c_version_id;

  -- WIP - May have to change the logic to find
  -- if there is only one version so far.
  CURSOR l_is_first_version_csr (c_hierarchy_id IN NUMBER)
  IS
  SELECT COUNT(*)
  FROM   fem_object_definition_b
  WHERE  object_id = c_hierarchy_id;

  CURSOR l_is_prior_version_csr (c_hierarchy_id IN NUMBER,
                               c_version_id   IN NUMBER)
  IS
  SELECT 'Y' FROM dual
  WHERE EXISTS( SELECT 1
                FROM fem_object_definition_b a,
                     fem_object_definition_b b
                WHERE a.object_id = b.object_id
                AND   a.object_id = c_hierarchy_id
                AND   b.object_definition_id = c_version_id
                AND   a.effective_start_date > b.effective_end_date);

BEGIN

  SAVEPOINT Add_Relation_Pvt;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --

   ----- Start: Bug#5895840: Raising an exception and later catching it and throwing an error message
 	   ----- if there is no fem:period or fem:dataset profile set for the user

  IF(l_cal_period_id IS NULL) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF(l_dataset_code IS NULL) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;
 ---- End: Bug#5895840


  IF p_hier_table_name = 'FEM_COST_OBJECTS_HIER' THEN

    OPEN l_is_first_version_csr(c_hierarchy_id => p_hierarchy_id);
    FETCH l_is_first_version_csr INTO l_is_first_version;
    CLOSE l_is_first_version_csr;

    OPEN l_is_prior_version_csr(c_hierarchy_id => p_hierarchy_id,
                              c_version_id => p_version_id);
    FETCH l_is_prior_version_csr INTO l_is_prior_version;
    CLOSE l_is_prior_version_csr;

    l_child_sequence_num := 1;

    FOR l_max_child_seq_num_rec IN
    (  SELECT NVL(MAX(child_sequence_num),0) child_sequence_num
       FROM   fem_cost_objects_hier
       WHERE  hierarchy_obj_id = p_hierarchy_id
       AND    parent_id = p_parent_id
       AND    child_id = p_child_id)
    LOOP
      l_child_sequence_num := l_max_child_seq_num_rec.child_sequence_num + 1;
    END LOOP;

    IF l_is_first_version = 1  THEN

      l_effective_start_date := TO_DATE('01/01/1900', 'MM/DD/YYYY');
      l_effective_end_date := TO_DATE('01/01/2500', 'MM/DD/YYYY');

    ELSIF l_is_prior_version = 'Y' THEN

      OPEN l_hier_ver_details_csr (c_version_id => p_version_id);
      FETCH l_hier_ver_details_csr
                             INTO l_effective_start_date, l_effective_end_date;
      CLOSE l_hier_ver_details_csr;

    ELSE -- <adding to the latest version>

      OPEN l_hier_ver_details_csr (c_version_id => p_version_id);
      FETCH l_hier_ver_details_csr
                             INTO l_effective_start_date, l_effective_end_date;
      CLOSE l_hier_ver_details_csr;

      l_effective_end_date := TO_DATE('01/01/2500', 'MM/DD/YYYY');

    END IF;

    SELECT fem_cost_objects_hier_s.NEXTVAL
    INTO   l_new_relationship_id
    FROM   dual;

    INSERT INTO fem_cost_objects_hier
    (relationship_id,
     effective_start_date,
     hierarchy_obj_id,
     parent_id,
     child_id,
     child_sequence_num,
     display_order_num,
     effective_end_date,
     bom_reference,
     creation_date,
     created_by,
     last_updated_by,
     last_update_date,
     last_update_login,
     object_version_number)
     VALUES
     (l_new_relationship_id,
      l_effective_start_date,
      p_hierarchy_id,
      p_parent_id,
      p_child_id,
      l_child_sequence_num,
      p_display_order_num,
      l_effective_end_date,
      p_bom_reference,
      g_current_date,
      g_current_user_id,
      g_current_user_id,
      g_current_date,
      g_current_login_id,
      1);

     INSERT INTO fem_cost_obj_hier_qty
     (relationship_id,
      dataset_code,
      cal_period_id,
      child_qty,
      parent_qty,
      yield_percentage,
      creation_date,
      created_by,
      last_updated_by,
      last_update_date,
      last_update_login,
      object_version_number)
     VALUES
     (l_new_relationship_id,
      l_dataset_code,
      l_cal_period_id,
      p_child_qty,
      p_parent_qty,
      p_yield_pct,
      g_current_date,
      g_current_user_id,
      g_current_user_id,
      g_current_date,
      g_current_login_id,
      1);

    Circular_Ref_Check(p_hierarchy_id => p_hierarchy_id,
                       p_parent_id => p_parent_id,
                       p_child_id => p_child_id,
                       x_return_status => x_return_status,
                       x_msg_count => x_msg_count,
                       x_msg_data => x_msg_data);


    IF x_return_status = FND_API.G_RET_STS_ERROR
    THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;

  END IF;

  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END iF;

  x_return_status := FND_API.G_RET_STS_SUCCESS ;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN

     ---- Start : Bug#5895840
 	   IF(l_cal_period_id IS NULL) THEN
 	      FND_MESSAGE.SET_NAME('FEM','FEM_DHM_CREATE_REL_PROFILE_ERR');
 	      FND_MSG_PUB.ADD;
 	   END IF;

 	   IF(l_dataset_code IS NULL) THEN
 	      FND_MESSAGE.SET_NAME('FEM','FEM_DHM_CREATE_REL_DATASET_ERR');
 	      FND_MSG_PUB.ADD;
 	   END IF;
     ---- End: Bug#5895840

    ROLLBACK TO Add_Relation_Pvt ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
				p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Add_Relation_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
				p_data  => x_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Add_Relation_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
				p_data  => x_msg_data );

END Add_Relation;

/*===========================================================================+
 |                     PROCEDURE Add_Relations                               |
 +===========================================================================*/

--
-- The API to add a set of Relations to a Hierarchy.
-- NOTE: This is currently used for Cost Object Hierarchies.
--
PROCEDURE Add_Relations(
  p_api_version                IN       NUMBER,
  p_init_msg_list              IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                     IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level           IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status              OUT  NOCOPY      VARCHAR2,
  x_msg_count                  OUT  NOCOPY      NUMBER,
  x_msg_data                   OUT  NOCOPY      VARCHAR2,
  --
  p_hierarchy_id               IN       NUMBER,
  p_version_id                 IN       NUMBER,
  p_hier_table_name            IN       VARCHAR2,
  p_relation_details_tbl       IN       FEM_DHM_HIER_NODE_TAB_TYP
)
IS

  l_api_name    CONSTANT VARCHAR2(30) := 'Add_Relations';
  l_api_version CONSTANT NUMBER := 1.0;

  l_relations_tab_type           FEM_DHM_HIER_NODE_TAB_TYP;

  l_return_status       VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);

BEGIN

  SAVEPOINT Add_Relations_Pvt;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --

  l_relations_tab_type := p_relation_details_tbl;

  FOR i IN 1..l_relations_tab_type.COUNT
  LOOP

    Add_Relation(p_api_version => 1.0,
                 x_return_status => l_return_status,
                 x_msg_count => l_msg_count,
                 x_msg_data => l_msg_data,
                 p_hierarchy_id => p_hierarchy_id,
                 p_version_id => p_version_id,
                 p_parent_id => l_relations_tab_type(i).parent_id,
                 p_parent_qty => l_relations_tab_type(i).parent_qty,
                 p_child_id => l_relations_tab_type(i).child_id,
                 p_child_qty => l_relations_tab_type(i).child_qty,
                 p_yield_pct => l_relations_tab_type(i).yield_pct,
                 p_bom_reference => l_relations_tab_type(i).bom_reference,
                 p_display_order_num=>l_relations_tab_type(i).display_order_num,
                 p_hier_table_name => p_hier_table_name);

    IF l_return_status = FND_API.G_RET_STS_ERROR
    THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;

  END LOOP;

  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END iF;

  x_return_status := FND_API.G_RET_STS_SUCCESS ;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Add_Relations_Pvt ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Add_Relations_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Add_Relations_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );
END Add_Relations;

/*===========================================================================+
 |                     PROCEDURE Reset_Child_Seq_Num                         |
 +===========================================================================*/
-- API to reset the Child Sequence Numbers in  Cost Object Hierarchies after
-- a node is removed.

PROCEDURE Reset_Child_Seq_Num
(p_hierarchy_id        IN NUMBER,
 p_parent_id           IN NUMBER,
 p_child_id            IN NUMBER,
 p_curr_ver_start_date IN DATE)
IS

 l_child_sequence_num  NUMBER := 1;
BEGIN

  FOR x_rec IN (SELECT child_sequence_num, parent_id, child_id
                FROM fem_cost_objects_hier
                WHERE hierarchy_obj_id = p_hierarchy_id
                AND parent_id = p_parent_id
                AND child_id = p_child_id
                AND p_curr_ver_start_date
                       BETWEEN effective_start_date AND effective_end_date
                ORDER BY child_sequence_num)

  LOOP

    UPDATE fem_cost_objects_hier
    SET    child_sequence_num = l_child_sequence_num
    WHERE  hierarchy_obj_id = p_hierarchy_id
    AND    parent_id = x_rec.parent_id
    AND    child_id = x_rec.child_id
    AND    child_sequence_num = x_rec.child_sequence_num
    AND    p_curr_ver_start_date
                            BETWEEN effective_start_date AND effective_end_date;

    l_child_sequence_num := l_child_sequence_num + 1;

  END LOOP;

END Reset_Child_Seq_Num;

/*===========================================================================+
 |                     PROCEDURE Remove_Relation                             |
 +===========================================================================*/

--
-- The API to remove a Relation from a Hierarchy.
-- NOTE: This is currently used for Cost Object Hierarchies.
--
PROCEDURE Remove_Relation(
  p_api_version                IN        NUMBER,
  p_init_msg_list              IN        VARCHAR2 := FND_API.G_FALSE,
  p_commit                     IN        VARCHAR2 := FND_API.G_FALSE,
  p_validation_level           IN        NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status              OUT  NOCOPY      VARCHAR2,
  x_msg_count                  OUT  NOCOPY      NUMBER,
  x_msg_data                   OUT  NOCOPY      VARCHAR2,
  --
  p_hierarchy_id               IN        NUMBER,
  p_version_id                 IN        NUMBER,
  p_parent_id                  IN        NUMBER,
  p_child_id                   IN        NUMBER,
  p_child_sequence_num         IN        NUMBER,
  p_hier_table_name            IN        VARCHAR2,
  p_remove_all_children_flag   IN        VARCHAR
)
IS

  l_api_name    CONSTANT VARCHAR2(30) := 'Remove_Relation';
  l_api_version CONSTANT NUMBER := 1.0;

  l_new_relationship_id         NUMBER;
  l_parent_id                   NUMBER;
  l_child_id                    NUMBER;
  l_child_sequence_num          NUMBER;
  l_display_order_num           NUMBER := 10; -- WIP
  l_bom_reference               VARCHAR2(30) := 'wip';

  l_curr_version_start_date     DATE;
  l_curr_version_end_date       DATE;
  l_prior_version_exists        VARCHAR2(1) := 'N';
  l_later_version_exists        VARCHAR2(1) := 'N';

  CURSOR l_prior_version_exists_csr (c_hierarchy_id IN NUMBER,
                                     c_eff_start_date IN DATE)
  IS
  SELECT 'Y' FROM dual
  WHERE EXISTS( SELECT 1
                FROM fem_object_definition_b
                WHERE object_id = c_hierarchy_id
                AND   effective_start_date < c_eff_start_date);

  CURSOR l_later_version_exists_csr(c_hierarchy_id  IN NUMBER,
                                    c_eff_end_date IN DATE)
  IS
  SELECT 'Y' FROM dual
  WHERE EXISTS (SELECT 1
                FROM   fem_object_definition_vl a
                WHERE  object_id = c_hierarchy_id
                AND    effective_end_date > c_eff_end_date);

  CURSOR l_version_details_csr (c_version_id IN NUMBER)
  IS
  SELECT effective_start_date, effective_end_date
  FROM   fem_object_definition_b
  WHERE  object_definition_id = c_version_id;

  CURSOR l_all_children_csr (c_hierarchy_id IN NUMBER,
                             c_parent_id    IN NUMBER)
  IS
  SELECT child_id, bom_reference, child_sequence_num, display_order_num
  FROM   fem_cost_objects_hier
  WHERE  hierarchy_obj_id = c_hierarchy_id
  AND    parent_id = c_parent_id;

BEGIN

  SAVEPOINT Remove_Relation_Pvt;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;

  IF p_hier_table_name = 'FEM_COST_OBJECTS_HIER' THEN

    l_parent_id := p_parent_id;
    l_child_id := p_child_id;
    l_child_sequence_num := p_child_sequence_num;

  /******************************************************************
   The following is the pseudo code for the Remove_Relation() API:
   ---------------------------------------------------------------
    if prior_version_exists = N then
      if later_version_exists = N then
        if remove_all_children = Y then
          <delete all the children of the given parent>
        else
          <delete just the given relation>
        end if
      else
        if remove_all_children = Y then
          <update set startDate = curr_ver_end_date+1 for all children>
        else
          <update set startDate = curr_ver_end_date+1 for the given relation>
        end if
      end if
    else
      if remove_all_children = Y then
        <update set endDate = curr_ver_start_date-1 for all children>
      else
        <update set endDate = curr_ver_start_date-1 for the given relation>
      end if
      if later_version_exists = Y then
        if remove_all_children = Y then
          <insert new record with startDate = curr_ver_end_date+1 for all chil.>
        else
          <insert new record with startDate = curr_ver_end_date+1 for the given
            relation>
        end if
      end if
    end if
  *******************************************************************/

    OPEN l_version_details_csr(c_version_id => p_version_id);
    FETCH l_version_details_csr INTO l_curr_version_start_date,
                                 l_curr_version_end_date;
    CLOSE l_version_details_csr;
    --
    OPEN l_prior_version_exists_csr (c_hierarchy_id => p_hierarchy_id,
                                 c_eff_start_date => l_curr_version_start_date);
    FETCH l_prior_version_exists_csr INTO l_prior_version_exists;
    CLOSE l_prior_version_exists_csr;
    --
    OPEN l_later_version_exists_csr (c_hierarchy_id => p_hierarchy_id,
                                   c_eff_end_date => l_curr_version_end_date);
    FETCH l_later_version_exists_csr INTO l_later_version_exists;
    CLOSE l_later_version_exists_csr;
    --

    IF l_prior_version_exists <> 'Y' THEN

      IF l_later_version_exists = 'Y' THEN

        IF p_remove_all_children_flag = 'Y' THEN

          UPDATE fem_cost_objects_hier
          SET effective_start_date = l_curr_version_end_date + 1,
	      last_update_date = g_current_date,
	      last_updated_by = g_current_user_id,
	      last_update_login = g_current_login_id,
	      object_version_number = object_version_number + 1
          WHERE hierarchy_obj_id = p_hierarchy_id
          AND parent_id = l_parent_id
          AND l_curr_version_start_date
                          BETWEEN effective_start_date AND effective_end_date;

	ELSE

          UPDATE fem_cost_objects_hier
          SET effective_start_date = l_curr_version_end_date + 1,
              last_update_date = g_current_date,
              last_updated_by = g_current_user_id,
              last_update_login = g_current_login_id,
              object_version_number = object_version_number + 1
  	  WHERE hierarchy_obj_id = p_hierarchy_id
  	  AND parent_id = l_parent_id
  	  AND child_id = l_child_id
	  AND child_sequence_num = l_child_sequence_num
        AND l_curr_version_start_date
                           BETWEEN effective_start_date AND effective_end_date;

        END IF;

      ELSE -- l_later_version_exists = N

        IF p_remove_all_children_flag = 'Y' THEN

          DELETE FROM fem_cost_objects_hier
	  WHERE hierarchy_obj_id = p_hierarchy_id
    	  AND parent_id = l_parent_id;

          DELETE FROM fem_cost_obj_hier_qty
          WHERE relationship_id = (SELECT relationship_id
                                   FROM fem_cost_objects_hier
  	    		           WHERE hierarchy_obj_id = p_hierarchy_id
  	  		           AND parent_id = l_parent_id);

        ELSE

          DELETE FROM fem_cost_objects_hier
          WHERE hierarchy_obj_id = p_hierarchy_id
          AND    parent_id = l_parent_id
          AND    child_id = l_child_id
          AND    child_sequence_num = l_child_sequence_num;

          DELETE FROM fem_cost_obj_hier_qty
          WHERE relationship_id = (SELECT relationship_id
                                   FROM fem_cost_objects_hier
                                   WHERE hierarchy_obj_id = p_hierarchy_id
                                   AND parent_id = l_parent_id
                                   AND  child_id = l_child_id
                                   AND child_sequence_num=l_child_sequence_num);

        END IF; -- p_remove_all_children_flag

      END IF; -- l_later_version_exists

    ELSE -- there is a prior version

      IF p_remove_all_children_flag = 'Y' THEN

        UPDATE fem_cost_objects_hier
        SET    effective_end_date = (l_curr_version_start_date - 1),
               last_update_date = g_current_date,
               last_updated_by = g_current_user_id,
               last_update_login = g_current_login_id,
               object_version_number = object_version_number + 1
        WHERE  hierarchy_obj_id = p_hierarchy_id
        AND    parent_id = l_parent_id;

        IF sql%NOTFOUND THEN

          DELETE FROM fem_cost_objects_hier
          WHERE hierarchy_obj_id = p_hierarchy_id
          AND   parent_id = l_parent_id
          AND   child_sequence_num = l_child_sequence_num;

        END IF;


      ELSE

        UPDATE fem_cost_objects_hier
        SET    effective_end_date = (l_curr_version_start_date - 1),
               last_update_date = g_current_date,
               last_updated_by = g_current_user_id,
               last_update_login = g_current_login_id,
               object_version_number = object_version_number + 1
        WHERE  hierarchy_obj_id = p_hierarchy_id
        AND    parent_id = l_parent_id
        AND    child_id = l_child_id
        AND    child_sequence_num = l_child_sequence_num;

        IF sql%NOTFOUND THEN

          DELETE FROM fem_cost_objects_hier
          WHERE hierarchy_obj_id = p_hierarchy_id
          AND   parent_id = l_parent_id
          AND   child_id = l_child_id
          AND   child_sequence_num = l_child_sequence_num;

        END IF;

      END IF;

      IF l_later_version_exists = 'Y' THEN

        IF p_remove_all_children_flag = 'Y' THEN

          FOR l_all_children_rec IN l_all_children_csr
                                 (c_hierarchy_id => p_hierarchy_id,
                                  c_parent_id => l_parent_id) LOOP

            SELECT fem_cost_objects_hier_s.NEXTVAL
            INTO   l_new_relationship_id
            FROM   dual;

            INSERT INTO fem_cost_objects_hier
            (relationship_id,
             effective_start_date,
             hierarchy_obj_id,
             parent_id,
             child_id,
             child_sequence_num,
             display_order_num,
             effective_end_date,
             bom_reference,
             creation_date,
             created_by,
             last_updated_by,
             last_update_date,
             last_update_login,
             object_version_number)
            VALUES
            (l_new_relationship_id,
             l_curr_version_end_date+1,
             p_hierarchy_id,
             l_parent_id,
             l_all_children_rec.child_id,
             l_all_children_rec.child_sequence_num,
             l_all_children_rec.display_order_num,
             TO_DATE('01/01/2500','mm/dd/yyyy'),
             l_all_children_rec.bom_reference,
             g_current_date,
             g_current_user_id,
             g_current_user_id,
             g_current_date,
             g_current_login_id,
             1);

          END LOOP;

        ELSE

          SELECT fem_cost_objects_hier_s.NEXTVAL
          INTO   l_new_relationship_id
          FROM   dual;

          INSERT INTO fem_cost_objects_hier
          (relationship_id,
           effective_start_date,
           hierarchy_obj_id,
           parent_id,
           child_id,
           child_sequence_num,
           display_order_num,
           effective_end_date,
           bom_reference,
           creation_date,
           created_by,
           last_updated_by,
           last_update_date,
           last_update_login,
           object_version_number)
          VALUES
          (l_new_relationship_id,
           l_curr_version_end_date+1,
           p_hierarchy_id,
           l_parent_id,
           l_child_id,
           l_child_sequence_num,
           l_display_order_num,
           TO_DATE('01/01/2500','mm/dd/yyyy'),
           l_bom_reference,
           g_current_date,
           g_current_user_id,
           g_current_user_id,
           g_current_date,
           g_current_login_id,
           1);

        END IF;
      END IF;

    END IF;
/*
    reset_child_seq_num(p_hierarchy_id => p_hierarchy_id,
                        p_parent_id => l_parent_id,
                        p_child_id => l_child_id,
                        p_curr_ver_start_date => l_curr_version_start_date);
*/
  END IF;

  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END iF;

  x_return_status := FND_API.G_RET_STS_SUCCESS ;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Remove_Relation_Pvt ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Remove_Relation_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Remove_Relation_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );
END Remove_Relation;

/*===========================================================================+
 |                     PROCEDURE Update_Relation                             |
 +===========================================================================*/

--
-- The API to update a Relation in a Hierarchy.
-- NOTE: This is currently used for Cost Object Hierarchies.
--
PROCEDURE Update_Relation(
  p_api_version                IN        NUMBER,
  p_init_msg_list              IN        VARCHAR2 := FND_API.G_FALSE,
  p_commit                     IN        VARCHAR2 := FND_API.G_FALSE,
  p_validation_level           IN        NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status              OUT  NOCOPY      VARCHAR2,
  x_msg_count                  OUT  NOCOPY      NUMBER,
  x_msg_data                   OUT  NOCOPY      VARCHAR2,
  --
  p_hierarchy_id               IN        NUMBER,
  p_version_id                 IN        NUMBER,
  p_parent_id                  IN        NUMBER,
  p_parent_qty                 IN        NUMBER,
  p_child_id                   IN        NUMBER,
  p_child_qty                  IN        NUMBER,
  p_child_sequence_num         IN        NUMBER,
  p_yield_pct                  IN        NUMBER,
  p_bom_reference              IN        VARCHAR2,
  p_display_order_num          IN        NUMBER,
  p_hier_table_name            IN        VARCHAR2
)
IS

  l_api_name    CONSTANT VARCHAR2(30) := 'Update_Relation';
  l_api_version CONSTANT NUMBER := 1.0;

  l_relationship_id      NUMBER;
  l_version_start_date   DATE;

  -- Bug#5723800 : Begin
  l_dataset_code  NUMBER      := FND_PROFILE.VALUE_SPECIFIC('FEM_DATASET',FND_GLOBAL.USER_ID);
  l_cal_period_id NUMBER      := FND_PROFILE.VALUE_SPECIFIC('FEM_PERIOD',FND_GLOBAL.USER_ID);
  l_insert_flag   VARCHAR2(1) := 'Y';
  l_creation_date DATE        := SYSDATE;
  l_last_update_date DATE     := SYSDATE;
  l_last_Updated_by  NUMBER   := FND_GLOBAL.User_Id;
  l_created_by NUMBER         := FND_GLOBAL.User_Id;
  l_last_update_login NUMBER  := FND_GLOBAL.Login_Id;
  -- Bug#5723800 : End

  CURSOR l_version_csr (c_version_id IN NUMBER)
  IS
  SELECT effective_start_date
  FROM   fem_object_definition_b
  WHERE  object_definition_id = c_version_id;

  CURSOR l_relation_csr (c_hierarchy_id       IN NUMBER,
                       c_parent_id          IN NUMBER,
                       c_child_id           IN NUMBER,
		       c_child_sequence_num IN NUMBER,
                       c_version_start_date IN DATE)
  IS
  SELECT relationship_id
  FROM   fem_cost_objects_hier
  WHERE  hierarchy_obj_id = c_hierarchy_id
  AND    parent_id = c_parent_id
  AND    child_id = c_child_id
  AND    child_sequence_num = c_child_sequence_num
  AND    c_version_start_date BETWEEN effective_start_date
                  AND effective_end_date;

BEGIN

  SAVEPOINT Update_Relation_Pvt;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;

  IF p_hier_table_name = 'FEM_COST_OBJECTS_HIER' THEN

    OPEN l_version_csr(c_version_id => p_version_id);
    FETCH l_version_csr INTO l_version_start_date;
    CLOSE l_version_csr;

    OPEN l_relation_csr (c_hierarchy_id => p_hierarchy_id,
                       c_parent_id => p_parent_id,
		       c_child_id => p_child_id,
		       c_child_sequence_num => p_child_sequence_num,
                       c_version_start_date => l_version_start_date);

    FETCH l_relation_csr INTO l_relationship_id;
    CLOSE l_relation_Csr;

    -- Bug#5723800 : Begin
    BEGIN
     SELECT 'N' into l_insert_flag from fem_cost_obj_hier_qty
     WHERE  relationship_id = l_relationship_id and
     dataset_code = l_dataset_code and
     cal_period_id = l_cal_period_id;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN NULL;
    END;
    -- Bug#5723800 : End


    UPDATE fem_cost_objects_hier
    SET    bom_reference = p_bom_reference
    WHERE  relationship_id = l_relationship_id;

    -- Bug#5723800 : Begin
    IF l_insert_flag <> 'N' then
       INSERT into fem_cost_obj_hier_qty
       (relationship_id,
        dataset_code,
	cal_period_id,
	child_qty,
	parent_qty,
	yield_percentage,
        creation_date,
        created_by ,
        last_updated_by ,
        last_update_date ,
        last_update_login ,
        object_version_number)
       values(
       l_relationship_id,
       l_dataset_code,
       l_cal_period_id,
       p_child_qty,
       p_parent_qty,
       p_yield_pct,
       l_creation_date,
       l_created_by,
       l_last_updated_by,
       l_last_update_date,
       l_last_update_login,
       1);
    ELSE
    -- Bug#5723800 : End
     UPDATE fem_cost_obj_hier_qty
     SET    parent_qty = p_parent_qty,
            child_qty = p_child_qty,
            yield_percentage = p_yield_pct
     WHERE  relationship_id = l_relationship_id
     -- Bug#5723800 : Begin
     AND dataset_code = l_dataset_code
     AND cal_period_id = l_cal_period_id;
    END IF;
    -- Bug#5723800 : End

  END IF;

  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END iF;

  x_return_status := FND_API.G_RET_STS_SUCCESS ;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Update_Relation_Pvt ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Update_Relation_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Update_Relation_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );
END Update_Relation;

/*===========================================================================+
 |                     PROCEDURE Update_Relations                            |
  +===========================================================================*/

  --
  -- The API to update multiple Relations in a Hierarchy.
  -- NOTE: This is currently used for Cost Object Hierarchies.
  --
PROCEDURE Update_Relations(
  p_api_version                IN        NUMBER,
  p_init_msg_list              IN        VARCHAR2 := FND_API.G_FALSE,
  p_commit                     IN        VARCHAR2 := FND_API.G_FALSE,
  p_validation_level           IN        NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status              OUT  NOCOPY      VARCHAR2,
  x_msg_count                  OUT  NOCOPY      NUMBER,
  x_msg_data                   OUT  NOCOPY      VARCHAR2,
  --
  p_hierarchy_id               IN        NUMBER,
  p_version_id                 IN        NUMBER,
  p_hier_table_name            IN        VARCHAR2,
  p_relation_details_tbl       IN        FEM_DHM_HIER_NODE_TAB_TYP
)
IS

  l_api_name    CONSTANT VARCHAR2(30) := 'Update_Relations';
  l_api_version CONSTANT NUMBER := 1.0;

  l_relations_tab_type           FEM_DHM_HIER_NODE_TAB_TYP;

  l_return_status       VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);

BEGIN

  SAVEPOINT Update_Relations_Pvt;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;

  l_relations_tab_type := p_relation_details_tbl;

  FOR i IN 1..l_relations_tab_type.COUNT
  LOOP

    Update_Relation(p_api_version => 1.0,
                 x_return_status => l_return_status,
                 x_msg_count => l_msg_count,
                 x_msg_data => l_msg_data,
                 p_hierarchy_id => p_hierarchy_id,
                 p_version_id => p_version_id,
                 p_child_sequence_num
                                  => l_relations_tab_type(i).child_sequence_num,
                 p_parent_id => l_relations_tab_type(i).parent_id,
                 p_parent_qty => l_relations_tab_type(i).parent_qty,
                 p_child_id => l_relations_tab_type(i).child_id,
                 p_child_qty => l_relations_tab_type(i).child_qty,
                 p_yield_pct => l_relations_tab_type(i).yield_pct,
                 p_display_order_num
                                   => l_relations_tab_type(i).display_order_num,
                 p_bom_reference => l_relations_tab_type(i).bom_reference,
                 p_hier_table_name => p_hier_table_name);

    IF l_return_status = FND_API.G_RET_STS_ERROR
    THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;

  END LOOP;

  x_return_status := FND_API.G_RET_STS_SUCCESS ;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Update_Relations_Pvt ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Update_Relations_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Update_Relations_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );
END Update_Relations;

/*===========================================================================+
 |                     PROCEDURE Move_Relation                               |
 +===========================================================================*/
-- API to move a Relation from one node to another.

PROCEDURE Move_Relation(
  p_api_version                IN        NUMBER,
  p_init_msg_list              IN        VARCHAR2 := FND_API.G_FALSE,
  p_commit                     IN        VARCHAR2 := FND_API.G_FALSE,
  p_validation_level           IN        NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status              OUT  NOCOPY      VARCHAR2,
  x_msg_count                  OUT  NOCOPY      NUMBER,
  x_msg_data                   OUT  NOCOPY      VARCHAR2,
  --
  p_hierarchy_id               IN        NUMBER,
  p_version_id                 IN        NUMBER,
  p_hier_table_name            IN        VARCHAR2,
  p_child_id                   IN        NUMBER,
  p_src_parent_id              IN        NUMBER,
  p_dest_parent_id             IN        NUMBER,
  p_child_sequence_num         IN        NUMBER)
IS

  l_api_name    CONSTANT VARCHAR2(30) := 'Move_Relation';
  l_api_version CONSTANT NUMBER := 1.0;

  l_return_status       VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);

  l_relationship_id     NUMBER;
  l_display_order_num   NUMBER;
  l_bom_reference       VARCHAR2(30);
  l_dataset_code        NUMBER;
  l_cal_period_id       NUMBER;
  l_child_qty           NUMBER;
  l_parent_qty          NUMBER;
  l_yield_pct           NUMBER;

  CURSOR l_relation_details_csr(c_hierarchy_id IN NUMBER,
                                c_version_id IN NUMBER,
                                c_parent_id IN NUMBER,
                                c_child_id IN NUMBER,
                                c_child_sequence_num IN NUMBER)
  IS
  SELECT relationship_id,
         display_order_num,
         bom_reference
  FROM   fem_cost_objects_hier
  WHERE  hierarchy_obj_id = c_hierarchy_id
  AND    parent_id = c_parent_id
  AND    child_id = c_child_id
  AND    child_sequence_num = c_child_sequence_num;

  CURSOR l_hier_qty_details_csr(c_relationship_id  IN NUMBER)
  IS
  SELECT dataset_code,
         cal_period_id,
         child_qty,
         parent_qty,
         yield_percentage
  FROM   fem_cost_obj_hier_qty
  WHERE  relationship_id = c_relationship_id;

BEGIN

  SAVEPOINT Move_Relation_Pvt;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --

  IF p_hier_table_name = 'FEM_COST_OBJECTS_HIER' THEN

    OPEN l_relation_details_csr(c_hierarchy_id => p_hierarchy_id,
                                c_version_id => p_version_id,
                                c_parent_id => p_src_parent_id,
                                c_child_id => p_child_id,
                                c_child_sequence_num => p_child_sequence_num);
    FETCH l_relation_details_csr INTO l_relationship_id,
                                      l_display_order_num,
                                      l_bom_reference;
    CLOSE l_relation_details_csr;

    OPEN l_hier_qty_details_csr(c_relationship_id => l_relationship_id);
    FETCH l_hier_qty_details_csr INTO l_dataset_code,
                                      l_cal_period_id,
                                      l_child_qty,
                                      l_parent_qty,
                                      l_yield_pct;
    CLOSE l_hier_qty_details_csr;

    Remove_Relation(p_api_version => '1.0',
                    x_return_status => l_return_status,
                    x_msg_count => l_msg_count,
                    x_msg_data => l_msg_data,
                    p_hierarchy_id => p_hierarchy_id,
                    p_version_id => p_version_id,
		    p_parent_id => p_src_parent_id,
		    p_child_id => p_child_id,
		    p_child_sequence_num => p_child_sequence_num,
                    p_hier_table_name => p_hier_table_name,
                    p_remove_all_children_flag => 'N');

    IF l_return_status = FND_API.G_RET_STS_ERROR
    THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;

    Add_Relation(p_api_version => '1.0',
                 x_return_status => l_return_status,
                 x_msg_count => l_msg_count,
                 x_msg_data => l_msg_data,
                 p_hierarchy_id => p_hierarchy_id,
                 p_version_id => p_version_id,
                 p_parent_id => p_dest_parent_id,
                 p_parent_qty => l_parent_qty,
                 p_child_id => p_child_id,
                 p_child_qty => l_child_qty,
                 p_yield_pct => l_yield_pct,
                 p_bom_reference => l_bom_reference,
                 p_display_order_num => l_display_order_num,
                 p_hier_table_name => p_hier_table_name);

    IF l_return_status = FND_API.G_RET_STS_ERROR
    THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;

  END IF;

  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END iF;

  x_return_status := FND_API.G_RET_STS_SUCCESS ;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Move_Relation_Pvt ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Move_Relation_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Move_Relation_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );
END Move_Relation;

/*===========================================================================+
 |                     PROCEDURE Flatten_Whole_Hierarchy                     |
 +===========================================================================*/

--
-- The API to flatten a complete Hierarchy.
--

PROCEDURE Flatten_Whole_Hierarchy
(
  p_api_version           IN           NUMBER ,
  p_init_msg_list         IN           VARCHAR2 := FND_API.G_FALSE ,
  p_commit                IN           VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level      IN           NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  x_return_status         OUT  NOCOPY  VARCHAR2 ,
  x_msg_count             OUT  NOCOPY  NUMBER   ,
  x_msg_data              OUT  NOCOPY  VARCHAR2 ,
  p_hierarchy_id          IN           NUMBER
)
IS

 CURSOR l_hier_version_csr (c_hierarchy_id IN NUMBER)
 IS
 SELECT object_definition_id
 FROM   fem_object_definition_b
 WHERE  object_id = c_hierarchy_id;

 l_api_name          CONSTANT VARCHAR2(30)   := 'Flatten_Whole_Hierarchy' ;
 l_api_version       CONSTANT NUMBER         :=  1.0;

 l_return_status       VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
 l_msg_count           NUMBER;
 l_msg_data            VARCHAR2(2000);

BEGIN

  SAVEPOINT Flatten_Whole_Hierarchy_Pvt;

  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS ;

  FOR l_hier_version_rec IN l_hier_version_csr(c_hierarchy_id => p_hierarchy_id)
  LOOP

    Flatten_Whole_Hier_Version
        (p_api_version => '1.0',
	 x_return_status => l_return_status,
	 x_msg_count => l_msg_count,
	 x_msg_data => l_msg_data,
	 p_hier_obj_defn_id => l_hier_version_rec.object_definition_id);

    IF l_return_status = FND_API.G_RET_STS_ERROR
    THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;

  END LOOP;

  UPDATE fem_hier_definitions
  SET    flattened_rows_completion_code = 'COMPLETED'
  WHERE  hierarchy_obj_def_id IN
     (SELECT object_definition_id
      FROM   fem_object_definition_b
      WHERE  object_id = p_hierarchy_id);

  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END iF;

  x_return_status := FND_API.G_RET_STS_SUCCESS ;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Flatten_Whole_Hierarchy_Pvt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
				p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Flatten_Whole_Hierarchy_Pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
				p_data  => x_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Flatten_Whole_Hierarchy_Pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
				p_data  => x_msg_data );

END Flatten_Whole_Hierarchy;

/*===========================================================================+
 |                     PROCEDURE Flatten_Whole_Hierarchy_CP                  |
 +===========================================================================*/

--
-- The concurrent program to flatten the whole Hierarchy.
--

PROCEDURE Flatten_Whole_Hierarchy_CP
(
  errbuf                  OUT  NOCOPY  VARCHAR2  ,
  retcode                 OUT  NOCOPY  VARCHAR2  ,
  p_hierarchy_id          IN           NUMBER
)
IS

  --
  l_api_name       CONSTANT VARCHAR2(30)   := 'Flatten_Whole_Hierarchy_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  --
  l_return_status  VARCHAR2(1);
  l_msg_count      number;
  l_msg_data       varchar2(2000);

BEGIN

  Flatten_Whole_Hierarchy
  (
     p_api_version       => 1.0,
     x_return_status     => l_return_status  ,
     x_msg_count         => l_msg_count,
     x_msg_data          => l_msg_data,
     p_hierarchy_id  => p_hierarchy_id);

   if l_return_status in ('U', 'E') then  --Bug#5004662
        retcode := 2;
      else
        retcode := 0;
      end if;    --End Bug#5004662

     errbuf := l_msg_data;

  COMMIT WORK;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     --
     retcode := 2 ;
     COMMIT WORK ;
     --
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     retcode := 2 ;
     COMMIT WORK ;
     --
  WHEN OTHERS THEN

      --
     IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      --
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
                               l_api_name  ) ;
     END IF ;
     --
     retcode := 2 ;
     commIT WORK ;
     --

End Flatten_Whole_Hierarchy_CP;

/*===========================================================================+
 |                     FUNCTION Get_Version_Access_Code                      |
 +===========================================================================*/
--
--  The procedure checks if data lock exists for the version with 'W'
--  access code.

FUNCTION Get_Version_Access_Code
(
  p_version_id           IN        NUMBER,
  p_object_access_code   IN        VARCHAR2
)
RETURN VARCHAR2 AS

  l_object_access_code             VARCHAR2(1) := 'R';

BEGIN

  IF p_object_access_code = 'W' then
     fem_pl_pkg.obj_def_data_edit_lock_exists(p_version_id,l_object_access_code);

     IF l_object_access_code = 'T' then
        l_object_access_code := 'R';
     ELSE
        l_object_access_code := 'W';
     END IF;
  END IF;

  RETURN l_object_access_code;
END Get_Version_Access_Code;



/*===========================================================================+
 |                     FUNCTION Can_Update_Hierarchy                         |
 +===========================================================================*/
--
--  The function checks if the hierarchy can be updated by the
--  current user or not. Returns 'E' if it can be updated, 'D' otherwise.
--


FUNCTION Can_Update_Hierarchy
(
p_object_access_code    IN VARCHAR2,
p_hier_created_by       IN VARCHAR2
)
RETURN VARCHAR2 AS

begin

if p_hier_created_by=g_current_user_id then
      return 'E';

else

 if p_object_access_code='W' then
    return 'E';
 else
   return 'D';
 end if;

end if;

end Can_Update_Hierarchy;

FUNCTION is_hier_vs_deleteable
(
p_hierarchy_id IN NUMBER,
p_value_set_id IN NUMBER,
p_hier_table IN VARCHAR2
)
RETURN VARCHAR2 AS

l_access_sql VARCHAR2(300);
l_result NUMBER := 0;

begin

l_access_sql := ' SELECT COUNT(*) FROM DUAL WHERE EXISTS ' ||
 	        ' (SELECT 1 FROM ' || p_hier_table || ' WHERE ' ||
 	        ' HIERARCHY_OBJ_DEF_ID IN (SELECT OBJECT_DEFINITION_ID ' ||
 	        ' FROM FEM_OBJECT_DEFINITION_B WHERE OBJECT_ID = :1) ' ||
 	        ' AND CHILD_VALUE_SET_ID = :2) ';
EXECUTE IMMEDIATE l_access_sql INTO l_result USING p_hierarchy_id, p_value_set_id;
IF l_result <> 0 THEN
  RETURN 'N';
ELSE
  RETURN 'Y';
END IF;

end is_hier_vs_deleteable;


end FEM_HIER_UTILS_PVT;

/
