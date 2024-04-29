--------------------------------------------------------
--  DDL for Package Body FEM_DIM_PRS_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_DIM_PRS_UTILS_PVT" AS
/* $Header: FEMVDPMB.pls 120.0 2005/06/06 21:21:08 appldev noship $ */

  G_PKG_NAME            constant varchar2(30) := 'FEM_DIM_PRS_UTILS_PVT';

/* ---------------------- Private Routine prototypes  -----------------------*/

CURSOR g_xdim_csr (c_dimension_id in number)
IS
select dim.dimension_id
   ,dim.dimension_varchar_label
   ,xdim.member_b_table_name
   ,xdim.member_tl_table_name
   ,xdim.attribute_table_name
   ,xdim.member_col
   ,xdim.personal_hierarchy_table_name
from fem_dimensions_b dim
   ,fem_xdim_dimensions xdim
where xdim.dimension_id = dim.dimension_id
and xdim.hier_editor_managed_flag  = 'Y'
and xdim.read_only_flag  = 'N'
and xdim.composite_dimension_flag ='N'
and xdim.dimension_active_flag = 'Y'
and (
     ((c_dimension_id is not null) and (dim.dimension_id = c_dimension_id))
     or ( c_dimension_id is null )
    )
ORDER BY dim.dimension_id ;


PROCEDURE Purge_Personal_Members_Pvt
( p_xdim_rec           IN          g_xdim_csr%ROWTYPE,
  p_user_id            IN          number
);

/* ------------------ End Private Routines prototypes  ----------------------*/


/*===========================================================================+
 |                             PROCEDURE pd                                  |
 +===========================================================================*/
PROCEDURE pd( p_message   IN     VARCHAR2)
IS
BEGIN
  NULL ;
  --DBMS_OUTPUT.Put_Line(p_message) ;
END pd ;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                         PROCEDURE Purge_Personal_Metadata                 |
 +===========================================================================*/
PROCEDURE Purge_Personal_Metadata
( p_api_version         IN          NUMBER
  ,p_init_msg_list      IN          VARCHAR2    := NULL
  ,p_commit             IN          VARCHAR2    := NULL
  ,p_validation_level   IN          NUMBER      := 0
  ,p_user_id            IN          VARCHAR2    := NULL
  ,p_dimension_id       IN          NUMBER      := NULL
  ,x_return_status      OUT NOCOPY  VARCHAR2
  ,x_msg_count          OUT NOCOPY  NUMBER
  ,x_msg_data           OUT NOCOPY  VARCHAR2
)
IS
  --
  l_api_name             constant varchar2(30)  := 'Purge_Personal_Metadata';
  l_api_version          constant number        :=  1.0;

  l_return_status        varchar2(1);
  l_msg_count            number;
  l_msg_data             varchar2(240);

  l_user_id              number;
  l_dimension_id         number;
  l_pers_hier_table_name varchar2(30);
  --
  CURSOR l_hier_obj_csr
  IS
  SELECT hierarchy_obj_id
  FROM   fem_hierarchies
  WHERE  dimension_id         =   l_dimension_id
  AND    hierarchy_usage_code =  'PLANNING'
  AND    hierarchy_type_code  <> 'DAG'
  AND    personal_flag        =  'Y'
  AND    created_by           =   l_user_id ;
  --
BEGIN

  -- API Savepoint
  savepoint Purge_Personal_Metadata_Pvt;

  -- Call to check for call compatibility
  if not FND_API.Compatible_Api_Call(
    l_api_version
    ,p_api_version
    ,l_api_name
    ,G_PKG_NAME
  ) then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Initialize API message list if necessary
  if p_init_msg_list = 'Y' then
    FND_MSG_PUB.Initialize;
  end if;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Default the user id if it is null
  if (p_user_id is not null) then
    l_user_id := p_user_id;
  else
    l_user_id := FND_GLOBAL.user_id;
  end if;

  -- Every record in the XDimension cursor must be processed.
  -- If a null is passed for dimension id, all dimensions are processed.
  -- If a valid dimension id is passed, only that dimension is processed.
  FOR l_xdim_rec in g_xdim_csr (c_dimension_id => p_dimension_id)
  LOOP

    l_dimension_id := l_xdim_rec.dimension_id;

    -- First Delete Personal Hierarchies
    l_pers_hier_table_name := l_xdim_rec.personal_hierarchy_table_name;

    if (l_pers_hier_table_name is not null) then

      for l_hier_obj_rec in l_hier_obj_csr loop

        --pd('l_pers_hier_table_name:' || l_pers_hier_table_name);
        --pd('hierarchy_obj_id:' || l_hier_obj_rec.hierarchy_obj_id);
        FEM_HIER_UTILS_PVT.Delete_Hierarchy (
          p_api_version       => 1.0
          ,p_hier_table_name  => l_pers_hier_table_name
          ,p_hier_obj_id      => l_hier_obj_rec.hierarchy_obj_id
          ,p_return_status    => l_return_status
          ,p_msg_count        => l_msg_count
          ,p_msg_data         => l_msg_data
        );

        if (l_return_status = FND_API.G_RET_STS_ERROR) then
          raise FND_API.G_EXC_ERROR;
        elsif (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;

      end loop;

    end if;

    -- Second, Delete Personal Members
    Purge_Personal_Members_Pvt (
      p_xdim_rec  => l_xdim_rec
      ,p_user_id  => l_user_id
    );

    -- Third, Delete Personal Groups
    delete from fem_dim_attr_grps
    where dimension_group_id in (
      select dimension_group_id
      from fem_dimension_grps_b
      where dimension_id = l_dimension_id
      and personal_flag = 'Y'
      and created_by = l_user_id
    );

    delete from fem_dimension_grps_tl
    where dimension_group_id in (
      select dimension_group_id
      from fem_dimension_grps_b
      where dimension_id = l_dimension_id
      and personal_flag = 'Y'
      and created_by = l_user_id
    );

    delete from fem_dimension_grps_b
    where dimension_id = l_dimension_id
    and personal_flag = 'Y'
    and created_by = l_user_id;

    -- Last, Delete Personal Attributes
    delete from fem_dim_attr_versions_tl avt
    where exists (
      select null
      from fem_dim_attr_versions_b avb
        ,fem_dim_attributes_b ab
      where avb.version_id = avt.version_id
      --and avb.personal_flag = 'Y'
      --and avb.created_by = l_user_id
      and ab.attribute_id = avb.attribute_id
      and ab.dimension_id = l_dimension_id
      and ab.personal_flag = 'Y'
      and ab.created_by = l_user_id
    );

    delete from fem_dim_attr_versions_b
    --where personal_flag = 'Y'
    --and created_by = l_user_id
    where attribute_id in (
      select attribute_id
      from fem_dim_attributes_b
      where dimension_id = l_dimension_id
      and personal_flag = 'Y'
      and created_by = l_user_id
    );

    delete from fem_dim_attributes_tl
    where attribute_id in (
      select attribute_id
      from fem_dim_attributes_b
      where dimension_id = l_dimension_id
      and personal_flag = 'Y'
      and created_by = l_user_id
    );

    delete from fem_dim_attributes_b
    where dimension_id = l_dimension_id
    and personal_flag = 'Y'
    and created_by = l_user_id;

  end loop;

  -- Check for p_commit
  if p_commit = 'Y' then
    commit work;
  end if;

  -- Call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(
    p_count => x_msg_count
    ,p_data => x_msg_data
  );

EXCEPTION

  when FND_API.G_EXC_ERROR then
    rollback to Purge_Personal_Metadata_Pvt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count
      ,p_data   => x_msg_data
    );

  when FND_API.G_EXC_UNEXPECTED_ERROR then
    rollback to Purge_Personal_Metadata_Pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count
      ,p_data   => x_msg_data
    );

  when others then
    rollback to Purge_Personal_Metadata_Pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    if (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) then
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    end if;
    FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count
      ,p_data   => x_msg_data
    );

END Purge_Personal_Metadata;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                       PROCEDURE Purge_Personal_Members_Pvt                |
 +===========================================================================*/
PROCEDURE Purge_Personal_Members_Pvt
( p_xdim_rec           IN          g_xdim_csr%ROWTYPE,
  p_user_id            IN          number
)
IS
  l_api_name          CONSTANT VARCHAR2(30)   := 'Purge_Personal_Members_Pvt';
  l_dimension_varchar_label    FEM_DIMENSIONS_B.dimension_varchar_label%TYPE;
  l_sql_stmt                   VARCHAR2(2000) := NULL;
BEGIN

  l_dimension_varchar_label := p_xdim_rec.dimension_varchar_label;

  if (l_dimension_varchar_label = 'CAL_PERIOD') then

    -- delete from fem_<xdim>_attr
    delete from fem_cal_periods_attr
    where cal_period_id in (
      select cal_period_id
      from fem_cal_periods_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_tl
    delete from fem_cal_periods_tl
    where cal_period_id in (
      select cal_period_id
      from fem_cal_periods_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_b
    delete from fem_cal_periods_b
    where personal_flag = 'Y'
    and created_by = p_user_id;

  elsif (l_dimension_varchar_label = 'NATURAL_ACCOUNT') then

    -- delete from fem_<xdim>_attr
    delete from fem_nat_accts_attr
    where natural_account_id in (
      select natural_account_id
      from fem_nat_accts_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_tl
    delete from fem_nat_accts_tl
    where natural_account_id in (
      select natural_account_id
      from fem_nat_accts_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_b
    delete from fem_nat_accts_b
    where personal_flag = 'Y'
    and created_by = p_user_id;

  elsif (l_dimension_varchar_label = 'PRODUCT') then

    -- delete from fem_<xdim>_attr
    delete from fem_products_attr
    where product_id in (
      select product_id
      from fem_products_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_tl
    delete from fem_products_tl
    where product_id in (
      select product_id
      from fem_products_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_b
    delete from fem_products_b
    where personal_flag = 'Y'
    and created_by = p_user_id;

  elsif (l_dimension_varchar_label = 'OBJECT') then

    null;
    -- OBJECT is not an XDimension with standard _ATTR, _TL, and _B tables

  elsif (l_dimension_varchar_label = 'DATASET') then

    -- delete from fem_<xdim>_attr
    delete from fem_datasets_attr
    where dataset_code in (
      select dataset_code
      from fem_datasets_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_tl
    delete from fem_datasets_tl
    where dataset_code in (
      select dataset_code
      from fem_datasets_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_b
    delete from fem_datasets_b
    where personal_flag = 'Y'
    and created_by = p_user_id;

  elsif (l_dimension_varchar_label = 'SOURCE_SYSTEM') then

    -- No fem_<xdim>_attr table

    -- delete from fem_<xdim>_tl
    delete from fem_source_systems_tl
    where source_system_code in (
      select source_system_code
      from fem_source_systems_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_b
    delete from fem_source_systems_b
    where personal_flag = 'Y'
    and created_by = p_user_id;

  elsif (l_dimension_varchar_label = 'LEDGER') then

    -- delete from fem_<xdim>_attr
    delete from fem_ledgers_attr
    where ledger_id in (
      select ledger_id
      from fem_ledgers_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_tl
    delete from fem_ledgers_tl
    where ledger_id in (
      select ledger_id
      from fem_ledgers_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_b
    delete from fem_ledgers_b
    where personal_flag = 'Y'
    and created_by = p_user_id;

  elsif (l_dimension_varchar_label = 'COMPANY_COST_CENTER_ORG') then

    -- delete from fem_<xdim>_attr
    delete from fem_cctr_orgs_attr
    where company_cost_center_org_id in (
      select company_cost_center_org_id
      from fem_cctr_orgs_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_tl
    delete from fem_cctr_orgs_tl
    where company_cost_center_org_id in (
      select company_cost_center_org_id
      from fem_cctr_orgs_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_b
    delete from fem_cctr_orgs_b
    where personal_flag = 'Y'
    and created_by = p_user_id;

  elsif (l_dimension_varchar_label = 'CURRENCY') then

    -- not supported in DHM
    null;

  elsif (l_dimension_varchar_label = 'ACTIVITY') then

    -- No personal activity hierarhies
    null;

  elsif (l_dimension_varchar_label = 'COST_OBJECT') then

    -- No personal cost object hierarhies
    null;

  elsif (l_dimension_varchar_label = 'FINANCIAL_ELEMENT') then

    -- delete from fem_<xdim>_attr
    delete from fem_fin_elems_attr
    where financial_elem_id in (
      select financial_elem_id
      from fem_fin_elems_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_tl
    delete from fem_fin_elems_tl
    where financial_elem_id in (
      select financial_elem_id
      from fem_fin_elems_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_b
    delete from fem_fin_elems_b
    where personal_flag = 'Y'
    and created_by = p_user_id;

  elsif (l_dimension_varchar_label = 'CHANNEL') then

    -- delete from fem_<xdim>_attr
    delete from fem_channels_attr
    where channel_id in (
      select channel_id
      from fem_channels_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_tl
    delete from fem_channels_tl
    where channel_id in (
      select channel_id
      from fem_channels_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_b
    delete from fem_channels_b
    where personal_flag = 'Y'
    and created_by = p_user_id;

  elsif (l_dimension_varchar_label = 'LINE_ITEM') then

    -- delete from fem_<xdim>_attr
    delete from fem_ln_items_attr
    where line_item_id in (
      select line_item_id
      from fem_ln_items_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_tl
    delete from fem_ln_items_tl
    where line_item_id in (
      select line_item_id
      from fem_ln_items_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_b
    delete from fem_ln_items_b
    where personal_flag = 'Y'
    and created_by = p_user_id;

  elsif (l_dimension_varchar_label = 'PROJECT') then

    -- delete from fem_<xdim>_attr
    delete from fem_projects_attr
    where project_id in (
      select project_id
      from fem_projects_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_tl
    delete from fem_projects_tl
    where project_id in (
      select project_id
      from fem_projects_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_b
    delete from fem_projects_b
    where personal_flag = 'Y'
    and created_by = p_user_id;

  elsif (l_dimension_varchar_label = 'CUSTOMER') then

    -- delete from fem_<xdim>_attr
    delete from fem_customers_attr
    where customer_id in (
      select customer_id
      from fem_customers_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_tl
    delete from fem_customers_tl
    where customer_id in (
      select customer_id
      from fem_customers_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_b
    delete from fem_customers_b
    where personal_flag = 'Y'
    and created_by = p_user_id;

  elsif (l_dimension_varchar_label = 'ENTITY') then

    -- delete from fem_<xdim>_attr
    delete from fem_entities_attr
    where entity_id in (
      select entity_id
      from fem_entities_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_tl
    delete from fem_entities_tl
    where entity_id in (
      select entity_id
      from fem_entities_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_b
    delete from fem_entities_b
    where personal_flag = 'Y'
    and created_by = p_user_id;

  elsif (l_dimension_varchar_label = 'GEOGRAPHY') then

    -- delete from fem_<xdim>_attr
    delete from fem_geography_attr
    where geography_id in (
      select geography_id
      from fem_geography_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_tl
    delete from fem_geography_tl
    where geography_id in (
      select geography_id
      from fem_geography_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_b
    delete from fem_geography_b
    where personal_flag = 'Y'
    and created_by = p_user_id;

  elsif (l_dimension_varchar_label = 'TASK') then

    -- delete from fem_<xdim>_attr
    delete from fem_tasks_attr
    where task_id in (
      select task_id
      from fem_tasks_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_tl
    delete from fem_tasks_tl
    where task_id in (
      select task_id
      from fem_tasks_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_b
    delete from fem_tasks_b
    where personal_flag = 'Y'
    and created_by = p_user_id;

  elsif (l_dimension_varchar_label = 'BUDGET') then

    -- delete from fem_<xdim>_attr
    delete from fem_budgets_attr
    where budget_id in (
      select budget_id
      from fem_budgets_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_tl
    delete from fem_budgets_tl
    where budget_id in (
      select budget_id
      from fem_budgets_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_b
    delete from fem_budgets_b
    where personal_flag = 'Y'
    and created_by = p_user_id;

  elsif (l_dimension_varchar_label = 'USER_DIM1') then

    -- delete from fem_<xdim>_attr
    delete from fem_user_dim1_attr
    where user_dim1_id in (
      select user_dim1_id
      from fem_user_dim1_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_tl
    delete from fem_user_dim1_tl
    where user_dim1_id in (
      select user_dim1_id
      from fem_user_dim1_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_b
    delete from fem_user_dim1_b
    where personal_flag = 'Y'
    and created_by = p_user_id;

  elsif (l_dimension_varchar_label = 'USER_DIM2') then

    -- delete from fem_<xdim>_attr
    delete from fem_user_dim2_attr
    where user_dim2_id in (
      select user_dim2_id
      from fem_user_dim2_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_tl
    delete from fem_user_dim2_tl
    where user_dim2_id in (
      select user_dim2_id
      from fem_user_dim2_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_b
    delete from fem_user_dim2_b
    where personal_flag = 'Y'
    and created_by = p_user_id;

  elsif (l_dimension_varchar_label = 'USER_DIM3') then

    -- delete from fem_<xdim>_attr
    delete from fem_user_dim3_attr
    where user_dim3_id in (
      select user_dim3_id
      from fem_user_dim3_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_tl
    delete from fem_user_dim3_tl
    where user_dim3_id in (
      select user_dim3_id
      from fem_user_dim3_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_b
    delete from fem_user_dim3_b
    where personal_flag = 'Y'
    and created_by = p_user_id;

  elsif (l_dimension_varchar_label = 'USER_DIM4') then

    -- delete from fem_<xdim>_attr
    delete from fem_user_dim4_attr
    where user_dim4_id in (
      select user_dim4_id
      from fem_user_dim4_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_tl
    delete from fem_user_dim4_tl
    where user_dim4_id in (
      select user_dim4_id
      from fem_user_dim4_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_b
    delete from fem_user_dim4_b
    where personal_flag = 'Y'
    and created_by = p_user_id;

 elsif (l_dimension_varchar_label = 'USER_DIM5') then

    -- delete from fem_<xdim>_attr
    delete from fem_user_dim5_attr
    where user_dim5_id in (
      select user_dim5_id
      from fem_user_dim5_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_tl
    delete from fem_user_dim5_tl
    where user_dim5_id in (
      select user_dim5_id
      from fem_user_dim5_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_b
    delete from fem_user_dim5_b
    where personal_flag = 'Y'
    and created_by = p_user_id;

  elsif (l_dimension_varchar_label = 'USER_DIM6') then

    -- delete from fem_<xdim>_attr
    delete from fem_user_dim6_attr
    where user_dim6_id in (
      select user_dim6_id
      from fem_user_dim6_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_tl
    delete from fem_user_dim6_tl
    where user_dim6_id in (
      select user_dim6_id
      from fem_user_dim6_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_b
    delete from fem_user_dim6_b
    where personal_flag = 'Y'
    and created_by = p_user_id;

  elsif (l_dimension_varchar_label = 'USER_DIM7') then

    -- delete from fem_<xdim>_attr
    delete from fem_user_dim7_attr
    where user_dim7_id in (
      select user_dim7_id
      from fem_user_dim7_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_tl
    delete from fem_user_dim7_tl
    where user_dim7_id in (
      select user_dim7_id
      from fem_user_dim7_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_b
    delete from fem_user_dim7_b
    where personal_flag = 'Y'
    and created_by = p_user_id;

  elsif (l_dimension_varchar_label = 'USER_DIM8') then

    -- delete from fem_<xdim>_attr
    delete from fem_user_dim8_attr
    where user_dim8_id in (
      select user_dim8_id
      from fem_user_dim8_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_tl
    delete from fem_user_dim8_tl
    where user_dim8_id in (
      select user_dim8_id
      from fem_user_dim8_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_b
    delete from fem_user_dim8_b
    where personal_flag = 'Y'
    and created_by = p_user_id;

  elsif (l_dimension_varchar_label = 'USER_DIM9') then

    -- delete from fem_<xdim>_attr
    delete from fem_user_dim9_attr
    where user_dim9_id in (
      select user_dim9_id
      from fem_user_dim9_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_tl
    delete from fem_user_dim9_tl
    where user_dim9_id in (
      select user_dim9_id
      from fem_user_dim9_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_b
    delete from fem_user_dim9_b
    where personal_flag = 'Y'
    and created_by = p_user_id;

  elsif (l_dimension_varchar_label = 'USER_DIM10') then

    -- delete from fem_<xdim>_attr
    delete from fem_user_dim10_attr
    where user_dim10_id in (
      select user_dim10_id
      from fem_user_dim10_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_tl
    delete from fem_user_dim10_tl
    where user_dim10_id in (
      select user_dim10_id
      from fem_user_dim10_b
      where personal_flag = 'Y'
      and created_by = p_user_id
    );

    -- delete from fem_<xdim>_b
    delete from fem_user_dim10_b
    where personal_flag = 'Y'
    and created_by = p_user_id;

  else

    l_sql_stmt := NULL;

    -- delete from fem_<xdim>_attr
    if (p_xdim_rec.attribute_table_name is not null) then
      l_sql_stmt :=
        'delete from '|| p_xdim_rec.attribute_table_name ||
        ' where ' || p_xdim_rec.member_col ||
        ' in ( select ' || p_xdim_rec.member_col ||
        ' from ' || p_xdim_rec.member_b_table_name ||
        ' where personal_flag = ''Y''' ||
        ' and created_by = ' || p_user_id ||
        ' )';
      execute immediate l_sql_stmt;
    end if;

    -- delete from fem_<xdim>_tl
    if (p_xdim_rec.member_tl_table_name is not null) then
      l_sql_stmt :=
        'delete from '|| p_xdim_rec.member_tl_table_name ||
        ' where ' || p_xdim_rec.member_col ||
        ' in ( select ' || p_xdim_rec.member_col ||
        ' from ' || p_xdim_rec.member_b_table_name ||
        ' where personal_flag = ''Y''' ||
        ' and created_by = ' || p_user_id ||
        ' )';
      execute immediate l_sql_stmt;
    end if;

    -- delete from fem_<xdim>_b
    l_sql_stmt :=
      'delete from '|| p_xdim_rec.member_b_table_name ||
      ' where personal_flag = ''Y''' ||
      ' and created_by = ' || p_user_id;
    execute immediate l_sql_stmt;

    l_sql_stmt := NULL;

  end if;

EXCEPTION
  WHEN OTHERS THEN
    IF l_sql_stmt IS NOT NULL THEN
      FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('PKG_NAME',       g_pkg_name);
      FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME', l_api_name) ;
      FND_MESSAGE.SET_TOKEN('ERROR_TEXT',l_sql_stmt);
      FND_MSG_PUB.Add;
    END IF;
    RAISE;
END Purge_Personal_Members_Pvt ;
/*---------------------------------------------------------------------------*/


END FEM_DIM_PRS_UTILS_PVT;

/
